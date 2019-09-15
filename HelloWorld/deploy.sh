#!/bin/bash
# Display usage help
display_help() {
    echo "Usage: $0 [option...] [option value]" >&2
    echo
    echo "   -a, --apigeeOption         Apigee action default value is 'validate'"
    echo "      clean (this option will delete the last deployed revision in an environment),"
    echo "      validate (this option will validate a bundle before importing"
    echo "      inactive (this option will import the bundle without activating the bundle)"
    echo "      override (this option is used for seamless deployment and should be supplied with apigee.override.delay parameter"
    echo "      update (this option will update the revision)"
    echo "      undeploy (this option will undeploy the revision)"
    echo "      remove (this option will undeploy the latest revision and delete the proxy)"
    echo "   -ac, --apigeeConfigOption  Apigee configuration deployment option default value is 'update'"
    echo "       create (Create the configurations)"
    echo "       update (Update the configuration if it exists else create)"
    echo "       delete (Deletes the configuration if it exists)"
    echo "       sync   (Deletes and recreates the configuration)"
    echo "       none   (No action taken for configurations)"
    echo "   -e, --environment          Apigee environment where to deploy (default value is 'default')"
    echo "   -o, --organization         *Apigee organization"
    echo "   -od, --overrideDelay       Override delay when using apigeeOption as override"
    echo "   -r, --revision             *Revision number of API proxy(required only if -a option has values 'update' or 'undeploy'"
    echo "   -u, --username             *Apigee username"
    echo "   -p, --password             *Apigee password"
    echo "   -P, --profile              *Deployment profile configured in shared-pom.xml"
    echo "   -h, --help                 Display this help message"
    echo 
    echo "* Marked options are required"
    echo
    # echo some stuff here for the -a or --add-options 
    exit 1
}

# Keeping options in alphabetical order makes it easy to add more.

apigee_org=""
apigee_env="default"
username=""
password=""
apigee_options="validate"
apigee_config_options="update"
profile=""
revision=""
overrideDelay=0
while :
do
    case "$1" in
        -a | --apigeeOption)
            apigee_options="$2"
            shift 2
            ;;
        -ac | --apigeeConfigOptions)
            apigee_config_options="$2"
            shift 2
            ;;
        -e | --environment)
            apigee_env="$2"
            shift 2
            ;;
        -o | --organization)
            apigee_org="$2"
            shift 2
            ;;
        -od | --overrideDelay)
            overrideDelay="$2"
            shift 2
            ;;
        -p | --password)
            password="$2"
            shift 2
            ;;
        -P | --profile)
            profile="$2"
            shift 2
            ;;
        -h | --help)
            display_help  # Call your function
            # no shifting needed here, we're done.
            exit 0
            ;;
        -r | --revision)
            revision="$2"
            shift 2
            ;;
        -u | --user)
            username="$2" # You may want to check validity of $2
            shift 2
            ;;
        -v | --verbose)
            #  It's better to assign a string, than a number like "verbose=1"
            #  because if you're debugging the script with "bash -x" code like this:
            #
            #    if [ "$verbose" ] ...
            #
            #  You will see:
            #
            #    if [ "verbose" ] ...
            #
                #  Instead of cryptic
            #
            #    if [ "1" ] ...
            #
            verbose="verbose"
            shift
            ;;
        --) # End of all options
            shift
            break
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            exit 1
            ;;
        *)  # No more options
            break
            ;;
    esac   
done

if [ "$apigee_org" == "" ]; then
    echo "Organization name is required"
    display_help
    exit 1
fi

if [ "$username" == "" ]; then
    echo "Username is required"
    display_help
    exit 1
fi

if [ "$password" == "" ]; then
    echo "Password is required"
    display_help
    exit 1
fi

if [ "$profile" == "" ]; then
    echo "Profile is required"
    display_help
    exit 1
fi

if [ "$apigee_options" == "update" ] || [ "$apigee_options" == "undeploy" ]; then
    if [ "$revision" == "" ]; then
        echo "Revision number of proxy is required for update or undeploy options"
        exit 1
    fi
fi

echo "Organization : $apigee_org"
echo "Environment : $apigee_env"
echo "Username : $username"
echo "Profile : $profile"


# Extract proxy name from POM.xml which will be used for deployment
proxy_name=`sed -n 's:.*<name>\(.*\)</name>.*:\1:p' pom.xml`
if [[ $proxy_name = AT* ]]; then
    echo "Proxy name is compliant with SWCI"
else
    echo "Proxy name is not compliant with SWCI"
    echo "Proxy name: $proxy_name"
    exit 1
fi

profile_index=0
profile_index=`sed -n 's:.*<apigee.profile>\(.*\)</apigee.profile>.*:\1:p' ../shared-pom.xml | awk "/$profile/{ print NR;}" `

if [ "$profile_index" == "" ]; then
    echo "profile not found in shared-pom.xml"
    exit 1
fi
profile_index=`expr $profile_index - 1`
urls=`sed -n 's:.*<apigee.hosturl>\(.*\)</apigee.hosturl>.*:\1:p' ../shared-pom.xml `

IFS=$'\n'; read -d '' -ra hosturls <<< "$urls"
# echo "${hosturls[*]}"

apigee_hosturl=${hosturls[$profile_index]}


org_exists=`curl "${apigee_hosturl}/v1/o/${apigee_org}" -H "Accept: application/xml" -u "$username:$password" `

if [ "$org_exists" == "" ]; then
    echo "Organization: $apigee_org does not exists or you don't have permission"
    exit 1
fi

env_exists=`sed -n 's:.*<Environment>\(.*\)</Environment>.*:\1:p' <<< "$org_exists" | awk "/$apigee_env/{ print NR;}"`
echo "$env_exists"
if [ "$env_exists" == "" ]; then
    echo "Environment is not available in organization $apigee_org"
    exit 1
fi


echo "#####################################"
echo "        Starting Deployment          "
echo "#####################################"

if [ "$apigee_options" == "undeploy" ]; then
    undeploy_revision=`curl -X DELETE "$apigee_hosturl/v1/o/${apigee_org}/e/${apigee_env}/apis/${proxy_name}/revisions/${revision}/deployments" -u "$username:$password" -H "Accept: application/xml"`
    if [ "$undeploy_revision" == "" ]; then
        echo "Proxy undeploy operation failed"
        exit 1
    fi
    exit 0
fi

if [ "$apigee_options" == "remove" ]; then
    mvn clean install -Dorg=$apigee_org -Denv=$apigee_env \
        -Dapigee.options="clean" -Dusername=$username -Dpassword=$password -P$profile
    
    proxy_exists=`curl -X GET "$apigee_hosturl/v1/o/$apigee_org/apis/$proxy_name" -H "Accept: application/xml" -u "$username:$password"`
    if grep -q "ApplicationDoesNotExist" <<< "$proxy_exists" ; then
        echo "$proxy_exists"
        echo "Proxy is removed or does not exists"
        exit 0
    fi
    remove_done=`curl -X DELETE "$apigee_hosturl/v1/o/$apigee_org/apis/$proxy_name" -H "Accept: application/xml" -u "$username:$password"`
    echo "$remove_done"
    if [ "$remove_done" == "" ]; then
        echo "Proxy removal failed"
        exit 1
    fi
    exit 0
fi

if [ "$apigee_options" == "update" ]; then
    mvn clean install -Dorg=$apigee_org -Denv=$apigee_env \
        -Dapigee.options=$apigee_options -Dapigee.config.options=$apigee_config_options \ 
        -Dapigee.revision=$revision \
        -Dusername=$username -Dpassword=$password -P$profile
fi

if [ "$apigee_options" == "inactive" ]; then
    mvn clean install -Dorg=$apigee_org -Denv=$apigee_env \
        -Dapigee.options=inactive -Dapigee.config.options=$apigee_config_options \
        -Dusername=$username -Dpassword=$password -P$profile
fi

if [ "$apigee_options" == "validate" ]; then
    mvn clean install -Dorg=$apigee_org -Denv=$apigee_env \
        -Dapigee.options=validate -Dapigee.config.options=$apigee_config_options \
        -Dusername=$username -Dpassword=$password -P$profile
fi

if [ "$apigee_options" == "override" ]; then
    if [ "$overrideDelay" == "" ]; then
        echo "Override delay is required with this 'override' option"
        exit 1
    fi
    mvn clean install -Dorg=$apigee_org -Denv=$apigee_env \
        -Dapigee.options=override -Dapigee.config.options=$apigee_config_options \
        -Dapigee.override.delay=$overrideDelay \
        -Dusername=$username -Dpassword=$password -P$profile 
fi
# End of file