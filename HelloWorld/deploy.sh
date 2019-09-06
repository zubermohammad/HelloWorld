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
    echo "   -ac, --apigeeConfigOption  Apigee configuration deployment option default value is 'update'"
    echo "       create (Create the configurations)"
    echo "       update (Update the configuration if it exists else create)"
    echo "       delete (Deletes the configuration if it exists)"
    echo "       sync   (Deletes and recreates the configuration)"
    echo "       none   (No action taken for configurations)"
    echo "   -e, --environment          Apigee environment where to deploy (default value is 'default')"
    echo "   -o, --organization         *Apigee organization"
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

echo "Organization : $apigee_org"
echo "Environment : $apigee_env"
echo "Username : $username"
echo "Profile : $profile"
echo ""

# Extract proxy name from POM.xml which will be used for deployment
proxy_name=`sed -n 's:.*<name>\(.*\)</name>.*:\1:p' pom.xml`

if [[ $proxy_name = AT* ]]; then
    echo "Proxy name is compliant with SWCI"
else
    echo "Proxy name is not compliant with SWCI"
    echo "Proxy name: $proxy_name"
    exit 1
fi


echo "#####################################"
echo "        Starting Deployment          "
echo "#####################################"

mvn clean install -Dorg=$apigee_org -Denv=$apigee_env \
    -Dapigee.options=$apigee_options -Dapigee.config.options=$apigee_config_options \
    -Dusername=$username -Dpassword=$password -P$profile

# End of file