Setup nexus and maven conf in settings.xml
copy this settings.xml to .m2 folder of Maven installation.
Upload the shared-pom in nexus repository using below command.
```
cd HelloWorld/shared-pom/

mvn deploy:deploy-file \
  -DpomFile=pom.xml \
  -Dpackaging=pom   \
  -DrepositoryId=nexus-apigee   \
  -Durl=http://localhost:8081/repository/apigee  \
  -Dfile=pom.xml

```

Build and deploy the api proxy

```
cd HelloWorld/
mvn clean install -Papigee \
    -Dusername=orgnization_username \
    -Dpassword=organization_password \
    -Dorg=organization_name  \
    -Denv=environment_name  \
    -Dapigee.config.file=./edge.json 

```
