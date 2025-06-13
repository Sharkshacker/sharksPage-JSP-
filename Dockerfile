FROM tomcat:9.0

COPY ROOT/ /usr/local/tomcat/webapps/ROOT/

ENV TZ=Asia/Seoul

EXPOSE 8080
