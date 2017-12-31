#!/usr/bin/env sh
set -eu

case ${1} in
    app:start)
        sleep 10
        
        cat /etc/hosts

        echo '[INFO] Prepare bookstack environment' && \
            cd /var/www/ && \
            php artisan migrate --force
        
        echo "[INFO] Starting services via runit"
        exec /sbin/runsvdir -P /etc/service
        ;;
    app:help)
        echo 'Available options:'
        echo ' app:start        - Starts and monitors a collection of runit services'
        echo ' app:help         - Displays the help'
        echo ' [command]        - Execute the specified command, eg. bash.'
        ;;
    *)
        exec "$@"
        ;;
esac 

