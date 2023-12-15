FROM openjdk:17-alpine

WORKDIR /keystore

RUN $JAVA_HOME/bin/keytool -genkeypair \
-dname "cn=myname, ou=mygroup, o=mycompany, c=mycountry" \
-alias baeldung -keyalg RSA -keysize 2048 \
#-storetype PKCS12 \
#-keystore /keystore/baeldung.p12 \
-keystore /keystore/baeldung.jks \
-storepass password -validity 3650

RUN $JAVA_HOME/bin/keytool -certreq \
-dname "cn=myname, ou=mygroup, o=mycompany, c=mycountry" \
-alias baeldung -keystore /keystore/baeldung.jks \
-file /keystore/baeldung.csr

RUN $JAVA_HOME/bin/keytool -import -trustcacerts -alias baeldung \
-file /keystore/baeldung.crt \
-keystore /keystore/baeldung.jks

RUN chmod -R +x * && ls

CMD ["pwd"]