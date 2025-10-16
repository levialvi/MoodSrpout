SHELL := /bin/zsh

# Usage: make deploy MSG="your commit message" BRANCH=main
deploy:
	@MSG="${MSG}" BRANCH="${BRANCH}" ./scripts/deploy.sh


