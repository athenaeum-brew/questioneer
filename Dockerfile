# Use an official Tomcat base image with JDK 21
FROM tomcat:latest

# Add the WAR file to the webapps directory
COPY target/questioneer.war /usr/local/tomcat/webapps/

# Expose the port on which Tomcat is running
EXPOSE 8080

# Set the default command to run Tomcat
CMD ["catalina.sh", "run"]
