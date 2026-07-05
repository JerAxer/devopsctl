#!/usr/bin/env bash
# modules/docker.sh

echo -e "${BLUE}===== DOCKER MANAGER =====${NC}"
echo "1) List containers  2) Prune unused  3) Run Nginx test"
read -p "Choice: " dc
case $dc in
    1) docker ps -a ;;
    2) confirm "Remove all unused containers/images?" && docker system prune -af ;;
    3) docker run -d -p 8080:80 --name test-nginx nginx; echo "Nginx running on port 8080" ;;
esac
log "INFO" "Docker command executed."