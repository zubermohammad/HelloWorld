# Deployment command

If you want to deploy Apigee Proxy without any checks use below maven command directly.
```
mvn clean install -Dusername=<username> -Dpassword=<password> -Dorg=<orgName> \
 -Denv=<apigeeEnv> \
 -Dapigee.config.options=update \
 -P<profile> \
 -Dapigee.config.dir=<directory of configurations>

```

This script checks for existance of organization, environment and few other checks as well.
* Allows undeploy of a revision
* Allows deleting of a proxy

```
./deploy.sh -o <organization> \
    -e <environment> \
    -a <apigee-options> \
    -ac <apigee-config-options> \
    -r <apigee-proxy-revision> \
    -od <override Delay incase apigee-options is override> \
    -u <username> \
    -p <password> \
    -P <apigee-profile> 
```

For displaying help 

```
./deploy.sh -h
```
```
Usage: ./deploy.sh [option...] [option value]

   -a, --apigeeOption         Apigee action default value is 'validate'
      clean (this option will delete the last deployed revision in an environment),
      validate (this option will validate a bundle before importing
      inactive (this option will import the bundle without activating the bundle)
      override (this option is used for seamless deployment and should be supplied with apigee.override.delay parameter
      update (this option will update the revision)
      undeploy (this option will undeploy the revision)
      remove (this option will undeploy the latest revision and delete the proxy)
   -ac, --apigeeConfigOption  Apigee configuration deployment option default value is 'update'
       create (Create the configurations)
       update (Update the configuration if it exists else create)
       delete (Deletes the configuration if it exists)
       sync   (Deletes and recreates the configuration)
       none   (No action taken for configurations)
   -e, --environment          Apigee environment where to deploy (default value is 'default')
   -o, --organization         *Apigee organization
   -od, --overrideDelay       Override delay when using apigeeOption as override
   -r, --revision             *Revision number of API proxy(required only if -a option has values 'update' or 'undeploy'
   -u, --username             *Apigee username
   -p, --password             *Apigee password
   -P, --profile              *Deployment profile configured in shared-pom.xml
   -h, --help                 Display this help message

* Marked options are required

```