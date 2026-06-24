.PHONY: jenkins-up jenkins-down jenkins-logs jenkins-password jenkins-setup

jenkins-up:
	docker compose up -d

jenkins-down:
	docker compose down

jenkins-logs:
	docker logs -f jenkins

jenkins-password:
	docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

jenkins-setup:
	chmod +x setup.sh && ./setup.sh
