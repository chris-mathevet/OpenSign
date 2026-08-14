#!/bin/bash

APACHEFILE="opensign.conf"
APACHEFILEPATH="/etc/apache2/sites-available/"

OPENSIGN_PORT="8080"
MONGO_PORT="27018"
CLIENT_PORT="3000"

HOST_URL=""

INSTALLATION_PATH="/etc/opensign-install"

MONGO_USER="opensignadmin"

SMTP_HOST=""
SMTP_PORT=""
SMTP_MAIL="ne-pas-repondre@inlibro.com"
UPDATE=0

if [ -f /inlibro/bin/librairie_inlibro.sh ]; then
    . /inlibro/bin/librairie_inlibro.sh
elif [ -f ./librairie_inlibro.sh ]; then
    . ./librairie_inlibro.sh
else
    alias rouge='echo'
    alias vert='echo'
    alias bleu='echo'
fi

function help(){
    echo """
Script d'installation de OpenSign

Options:
    -h | --help :                           Afficher ce message

    -u | --host-url [argument]:             Valeur de la variable d'environement stockant l'host d'opensign

    -o | --opensign-port [argument]:        Port pour l'API backend OpenSign (Défaut : $OPENSIGN_PORT)
    -m | --mongo-port [argument]:           Port pour mongoDB (Défaut : $MONGO_PORT)
    -c | --client-port [argument]:          Port pour l'interface utilisateur OpenSign (Défaut : $CLIENT_PORT)

    -p | --installation-path [argument]:    Chemin vers le répertoire d'installation (Crée si inexistant, Défaut : $INSTALLATION_PATH)

    --smtp-host [argument]:                 Host SMTP (Le port SMTP doit être fourni avec --smtp-port)
    --smtp-port [argument]:                 Port SMTP (L'host SMTP doit être fourni avec --smtp-host)
    --smtp-mail [argument]:                 Adresse courriel utilisé pour l'envoie de courriel automatique (Défaut : $SMTP_MAIL)

    --update :                              Mets à jour les conteneurs serveurs et client avec les dernières versions des images
    --uninstall :                           Désinstalle OpenSign et son répertoire d'installation
    --true-uninstall :                      Désinstalle OpenSign et son répertoire d'installation et la base de donnée montée
"""
}

function uninstall() {
    local true_uninstall=$1
    local OPTION=""

    if [ $true_uninstall -gt 0 ]; then
        OPTION="-v"
    fi

    docker compose -f "$INSTALLATION_PATH/docker-compose.yml" down $OPTION
    rm -r "$INSTALLATION_PATH"

    a2dissite "$APACHEFILE"
    sudo systemctl reload apache2
    sudo rm "$APACHEFILEPATH$APACHEFILE"
    vert "Désinstalation terminée"
}

function port_est_valide() {
    local port="$1"

    [[ "$port" =~ ^[0-9]+$ ]] && (( port >= 1 && port <= 65535 ))
}

function port_est_utilise() {
    local port="$1"

    ss -lutn | awk '{print $5}' | grep -qE "[:.]${port}$"
}

function port_all_test(){
    local port="$1"
    local port_name="$2"

    if ! port_est_valide "$port"; then
        help
        rouge "Le port précisé pour $port_name ($port) n'est pas valide."
        exit 1
    elif port_est_utilise "$port"; then
        help
        rouge "Le port précisé pour $port_name ($port) est déjà utilisé."
        exit 1
    fi
}

if [ "$(id -u)" != "0" ]; then
    help
    rouge "Vous devez être root (sudo) pour executer ce script."
    exit 1
fi

OPTIONS=$(getopt -o hu:o:m:c:p: \
    --long help,host-url:,opensign-port:,mongo-port:,client-port:,installation-path:,smtp-host:,smtp-port:,smtp-mail:,update,uninstall,true-uninstall \
    -n "$0" -- "$@")

if [ $? -ne 0 ]; then
    rouge "Erreur lors du parsing des options"
    exit 1
fi

eval set -- "$OPTIONS"

while true; do
    case "$1" in
        -h|--help)
            help
            exit 0
            ;;
        -u|--host-url)
            HOST_URL="$2"
            shift 2
            ;;
        -o|--opensign-port)
            OPENSIGN_PORT="$2"
            shift 2
            ;;
        -m|--mongo-port)
            MONGO_PORT="$2"
            shift 2
            ;;
        -c|--client-port)
            CLIENT_PORT="$2"
            shift 2
            ;;
        -p|--installation-path)
            INSTALLATION_PATH="$2"
            shift 2
            ;;
        --smtp-host)
            SMTP_HOST="$2"
            shift 2
            ;;
        --smtp-port)
            SMTP_PORT="$2"
            shift 2
            ;;
        --smtp-mail)
            SMTP_MAIL="$2"
            shift 2
            ;;
        --update)
            UPDATE=1
            shift
            ;;
        --uninstall)
            uninstall 0
            exit 0
            ;;
        --true-uninstall)
            uninstall 1
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            rouge "Option inconnue"
            exit 1
            ;;
    esac
done

# MISE A JOUR
if [ "$UPDATE" -eq 1 ]; then
    bleu "Mise à jour des conteneurs"
    sudo docker cp ./apps/OpenSignServer/files/. OpenSignServer-container:/usr/src/app/files/
    docker compose -f "$INSTALLATION_PATH/docker-compose.yml" up --force-recreate --no-deps -d server client
    exit 0
fi

if [ -z "$HOST_URL" ]; then
    help
    rouge "Vous devez préciser un URL"
    exit 1
fi

MONGO_PASSWORD=$(openssl rand -hex 24)

port_all_test "$OPENSIGN_PORT" "l'API backend OpenSign"
port_all_test "$MONGO_PORT" "mongoDB"
port_all_test "$CLIENT_PORT" "l'interface utilisateur OpenSign"

iptables -C INPUT -p tcp --dport "$MONGO_PORT" -j DROP 2>/dev/null \
    || iptables -A INPUT -p tcp --dport "$MONGO_PORT" -j DROP

iptables -C DOCKER-USER -p tcp --dport "$MONGO_PORT" -j DROP 2>/dev/null \
    || iptables -A DOCKER-USER -p tcp --dport "$MONGO_PORT" -j DROP

mkdir -p "$INSTALLATION_PATH"

cp ./template-docker-compose.yml "$INSTALLATION_PATH/docker-compose.yml"
cp ./template-opensign.conf "$APACHEFILEPATH$APACHEFILE"
cp ".env.local_dev" "$INSTALLATION_PATH/.env.prod"

sed -i "s|{OPENSIGN_HOST_URL}|$HOST_URL|g" "$INSTALLATION_PATH/docker-compose.yml"

sed -i "s|8080:|$OPENSIGN_PORT:|g" "$INSTALLATION_PATH/docker-compose.yml"
sed -i "s|27018:|$MONGO_PORT:|g" "$INSTALLATION_PATH/docker-compose.yml"
sed -i "s|3000:|$CLIENT_PORT:|g" "$INSTALLATION_PATH/docker-compose.yml"

sed -i "s|{OPENSIGN_HOST_URL}|$HOST_URL|g" "$APACHEFILEPATH$APACHEFILE"
sed -i "s|{OPENSIGN_PORT}|$OPENSIGN_PORT|g" "$APACHEFILEPATH$APACHEFILE"
sed -i "s|{CLIENT_PORT}|$CLIENT_PORT|g" "$APACHEFILEPATH$APACHEFILE"

sed -i "s|^MONGODB_URI=.*|MONGODB_URI=mongodb://$MONGO_USER:$MONGO_PASSWORD@mongo-container:27017/OpenSignDB?authSource=admin|" "$INSTALLATION_PATH/.env.prod"
sed -i "s|{ADMIN_USERNAME}|$MONGO_USER|g" "$INSTALLATION_PATH/docker-compose.yml"
sed -i "s|{ADMIN_PASSWORD}|$MONGO_PASSWORD|g" "$INSTALLATION_PATH/docker-compose.yml"

# SMTP
if [[ ! -z "$SMTP_HOST" ]] && [[ ! -z "$SMTP_PORT" ]]; then
    sed -i "s|^SMTP_ENABLE=.*|SMTP_ENABLE=true|" "$INSTALLATION_PATH/.env.prod"
    sed -i "s|^SMTP_HOST=.*|SMTP_HOST=$SMTP_HOST|" "$INSTALLATION_PATH/.env.prod"
    sed -i "s|^SMTP_PORT=.*|SMTP_PORT=$SMTP_PORT|" "$INSTALLATION_PATH/.env.prod"
    sed -i "s|^SMTP_USER_EMAIL=.*|SMTP_USER_EMAIL=$SMTP_MAIL|" "$INSTALLATION_PATH/.env.prod"
    sed -i "s|^SMTP_PASS=.*|SMTP_PASS= |" "$INSTALLATION_PATH/.env.prod"
else
    bleu "L'Hote SMTP et/ou le port SMTP n'ont pas été fournit, désactivation de la configuration SMTP"
    sed -i "s|^SMTP_ENABLE=.*|SMTP_ENABLE=false|" "$INSTALLATION_PATH/.env.prod"
fi

# PATCH
docker compose -f "$INSTALLATION_PATH/docker-compose.yml" up --force-recreate -d

chmod 600 "$INSTALLATION_PATH/.env.prod"
chmod 600 "$INSTALLATION_PATH/docker-compose.yml"

a2ensite "$APACHEFILE"
systemctl reload apache2

vert "Installation terminée, veuillez creer l'utilisateur administrateur ici : $HOST_URL/addadmin"