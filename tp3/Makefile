.PHONY: sonar-up sonar-down sonar-logs sonar-setup

sonar-up:
	docker compose up -d

sonar-down:
	docker compose down

sonar-logs:
	docker logs -f sonarqube

sonar-setup:
	chmod +x setup.sh && ./setup.sh
