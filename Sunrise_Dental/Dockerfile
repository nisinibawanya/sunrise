FROM tomcat:10.1-jdk21-temurin
RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY src/main/webapp /usr/local/tomcat/webapps/ROOT
COPY src/main/java /tmp/src/main/java
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes && \
javac -cp "/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/*"\
-d /usr/local/tomcat/webapps/ROOT/WEB-INF/classes \
$(find /tmp/src/main/java -name "*.java" ! -path "*/test/*")
EXPOSE 8080
