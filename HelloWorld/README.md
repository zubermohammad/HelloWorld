# Deployment command

If you want to deploy Apigee Proxy without any checks use below maven command directly.
```
mvn clean install -Dusername=<username> -Dpassword=<password> -Dorg=<orgName> \
 -Denv=<apigeeEnv> \
 -Dapigee.config.options=update \
 -P<profile> \
 -Dapigee.config.dir=<directory of configurations>

```

# Publishing to Nexus
1.  Update the settings.xml of maven to add nexus credentials.
    1.  path to settings.xml is `<maven installation dir>/conf/settings.xml`
add below lines in settings.xml in `<servers>` tag.

``` xml
<server>
    <id>nexus-apigee</id>
    <username>username of nexus repository</username>
    <password>password of nexus repository</password>
</server>
```

2. For uploading to Nexus repository use below maven command

```
mvn deploy:deploy-file \
  -DpomFile=pom.xml \
  -Dpackaging=zip \
  -Dfile=target/ATHelloWorld-1.0.zip \
  -DrepositoryId=nexus-apigee \
  -Durl=http://localhost:8081/repository/apigee

```
* `pomFile` This parameter should be used for giving location of pom file
* `packaging` This parameter defines what is the packaging type of bundle. User `zip` in this case.
* `file` parameter is used to define bundle path
* `repositoryId` use this to provide credential id which are defined in your settings.xml
* `url` parameter is used to give the location of nexus repository.


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