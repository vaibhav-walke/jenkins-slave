# Jenkins swarm slave

A [Jenkins swarm](https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin) slave.

## Running

To run a Docker container passing [any parameters](https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin#SwarmPlugin-AvailableOptions) to the slave

	docker run -d ctran/jenkins-slave -master http://jenkins:8080 \
		-username jenkins -password jenkins \
		-executors 1 \
		-mode exclusive \
		-labels it \
		-name slave-001 \
		-description $HOSTNAME

# Building

	docker build -t ctran/jenkins-slave .