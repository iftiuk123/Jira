
# Pull base image.
FROM java:8-jre

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
ENV JAVA_OPTS="-Xms2048m -Xmx2048m"
ENV JIRA_HOME="/home/ec2-user/jira_home/"

ARG jiradbpasswordarg

# Downloading confluence artifact form ATB Nexus and unzipping
RUN mkdir nexus_artifact
RUN mkdir jira-installation
ADD http://nexus.agiletrailblazers.com/repository/jira/atlassian-jira-software-7.3.4.zip /nexus_artifact/atlassian-jira-software-7.3.4.zip
RUN unzip /nexus_artifact/atlassian-jira-software-7.3.4.zip -d /jira-installation
RUN mkdir -p /home/ec2-user/jira_home;

# Removing artifact
RUN rm -rf /nexus_artifact/;

# Removing pre existing config files
RUN rm -rf /jira-installation/atlassian-jira-software-7.3.4-standalone/conf/server.xml
RUN rm -rf /jira-installation/atlassian-jira-software-7.3.4-standalone/bin/check-java.sh

# Adding config files
ADD server.xml /jira-installation/atlassian-jira-software-7.3.4-standalone/conf/server.xml
ADD check-java.sh /jira-installation/atlassian-jira-software-7.3.4-standalone/bin/check-java.sh
ADD dbconfig.xml /home/ec2-user/jira_home/dbconfig.xml
RUN sed -i "s/jiradbpassword/"$jiradbpasswordarg"/g" /home/ec2-user/jira_home/dbconfig.xml

# Provide execution permission
RUN chmod +x /jira-installation/atlassian-jira-software-7.3.4-standalone/bin/start-jira.sh
RUN chmod +x /jira-installation/atlassian-jira-software-7.3.4-standalone/bin/check-java.sh
RUN chmod +x /jira-installation/atlassian-jira-software-7.3.4-standalone/bin/catalina.sh
RUN chmod 755 /jira-installation/atlassian-jira-software-7.3.4-standalone/bin/start-jira.sh
#RUN useradd --create-home --comment "Account for running JIRA" --shell /bin/bash jira
RUN export _RUNJAVA=java
USER jira

EXPOSE 8080

# Start Jira
CMD ./jira-installation/atlassian-jira-software-7.3.4-standalone/bin/startup.sh && tail -f ./jira-installation/atlassian-jira-software-7.3.4-standalone/logs/catalina.out
