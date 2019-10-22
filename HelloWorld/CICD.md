# CI Part
* Checkout code from git hub to jenkins workspace using jenkins git plugin
* Create a bundle of apigee using below command
`mvn clean package`
* create a zip of the complete source code using below command
* `zip -r <zip-filename> <directory>`
* For our case it will be
`zip -r HelloWorld.zip ./`     
* Publish the zipped file to nexus using below command
```
mvn deploy:deploy-file \
    -DgroupId=test.com \
    -DartifactId=HelloWorld \
    -Dversion=1.0 \
    -Dpackaging=zip \
    -Dfile=HelloWorld.zip \
    -DrepositoryId=nexus-apigee \
    -Durl=http://localhost:8081/repository/apigee
```

#CD Part

* Download zip file from nexus repository
* Use below command
```
curl -X GET "http://localhost:8081/service/rest/v1/search/assets/download?repository=apigee&maven.groupId=test.com&maven.artifactId=HelloWorld&maven.baseVersion=1.0&maven.extension=zip" -H "accept: application/json" \
    -v -L -o HelloWorld.zip
```
* unzip the file to a directory 
` unzip -d /tmp/HelloWorld HelloWorld.zip`
* cd to the directory where you unzipped the file.
* Deploy using maven to apigee
```
mvn install -Dapigee.hosturl=<hostUrl> \
            -Dapigee.org=<org> \
            -Dapigee.apiversion=V1 \
            -Dapigee.env=<environment> \
            -Dapigee.username=<username> \
            -Dapigee.password=<password> \
            -Dapigee.config.dir=resources/edge
```



