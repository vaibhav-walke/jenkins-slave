FROM centos:centos6
MAINTAINER Cuong Tran "cuong.tran@gmail.com"

# Enable EPEL
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

ENV VERSION 1.0
ENV JENKINS_SWARM_VERSION 1.21
ENV MAVEN_VERSION 3.1.1
ENV HOME /home/jenkins

RUN yum -y install sudo tar passwd openssh-server git
RUN yum -y install java-1.6.0-openjdk java-1.6.0-openjdk-devel
RUN yum -y install xorg-x11-server-Xvfb x11vnc
RUN yum -y install firefox

# SSH
EXPOSE 22 5999

RUN sed 's/UsePAM yes/UsePAM no/' -i /etc/ssh/sshd_config
RUN sed 's/#PermitRootLogin yes/PermitRootLogin yes/' -i /etc/ssh/sshd_config
RUN sed 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' -i /etc/ssh/sshd_config
RUN /etc/init.d/sshd restart

# Jenkins
RUN useradd -c "Jenkins Slave user" -d $HOME -m jenkins
RUN echo 'root:1111' | chpasswd
RUN echo 'jenkins:1111' | chpasswd
RUN su - jenkins -c "mkdir $HOME/.ssh"
RUN chown jenkins:jenkins -R $HOME/.ssh
RUN chmod 0700 $HOME/.ssh

RUN sed 's/Defaults *requiretty/#Defaults    requiretty/' -i /etc/sudoers
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Swarm plugin
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar \
  && chmod 755 /usr/share/jenkins
COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh

# Maven
RUN curl -sSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/local \
	&& ln -s /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven \
	&& ln -s /usr/local/maven/bin/mvn /usr/local/bin

ENV MAVEN_HOME /usr/local/maven
ENV JAVA_HOME  /usr/lib/jvm/java/

# Firefox
RUN mkdir ~/.vnc

VOLUME /home/jenkins
ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]
