#!/usr/bin/env bash
set -Eeuo pipefail

echo ""
echo "This scripts may request sudo privileges in order to:"
echo " - Install Docker if its missing."
echo " - Install gettext (envsubst)."
echo " - Create data directories with correct permissions."
echo ""
echo "You can review this scripts before running it."
echo ""
echo "Requesting sudo access to initialize StarterLab..."
sudo -v
echo ""
echo ""
echo ""
echo "StarterLab Setup"
echo "================"
echo ""


# Detect OS

if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Cannot detect operating system."
    exit 1
fi

echo "Detected OS: $DISTRO"

# Install dependencies

echo ""
echo "Checking dependencies..."

INSTALL_DOCKER=false
INSTALL_GETTEXT=false

if ! command -v docker &>/dev/null; then
    INSTALL_DOCKER=true
fi

if ! command -v envsubst &>/dev/null; then
    INSTALL_GETTEXT=true
fi

if $INSTALL_DOCKER || $INSTALL_GETTEXT; then
    echo " Installing missing dependencies..."
fi

DISTRO=$(echo "$ID" | tr '[:upper:]' '[:lower:]')

case "$DISTRO" in
    ubuntu|debian)
        sudo apt update

        if $INSTALL_DOCKER; then
            sudo apt install -y docker.io docker-compose
        fi

        if $INSTALL_GETTEXT; then
            sudo apt install -y gettext
        fi
        ;;

    arch)
        if $INSTALL_DOCKER; then
            sudo pacman -Sy --noconfirm docker docker-compose
        fi

        if $INSTALL_GETTEXT; then
            sudo pacman -Sy --noconfirm gettext
        fi
        ;;

    fedora)
        if $INSTALL_DOCKER; then
            sudo dnf install -y docker docker-compose-plugin
        fi

        if $INSTALL_GETTEXT; then
            sudo dnf install -y gettext
        fi
        ;;

    *)
        echo "Unsupported distro: $DISTRO"
        exit 1
        ;;
esac

if command -v systemctl >/dev/null 2>&1; then
    if ! systemctl is-active --quiet docker; then 
        echo "Starting Docker..."
        sudo systemctl enable docker
        sudo systemctl start docker
    fi
else 
    echo "systemd not detected, skipping Docker service management."
fi

# Ask user configuration

echo ""
echo "Configuration"
echo "============="


if [[ "$1" == "--non-interactive" ]]; then
    PORT=8080
    ENABLE_VAULT=y
    ENABLE_GITEA=y
    ENABLE_GRAFANA=y
else

    read -rp "Port for StarterLab [8080]:" PORT
    PORT=${PORT:-8080}

    if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
        echo "Invalid port."
        exit 1
    fi

    read -rp "Enable Vaultwarden? (Y/n):" ENABLE_VAULT
    ENABLE_VAULT=${ENABLE_VAULT:-Y}

    read -rp "Enable Gitea? (Y/n):" ENABLE_GITEA
    ENABLE_GITEA=${ENABLE_GITEA:-Y}

    read -rp "Enable Grafana? (Y/n):" ENABLE_Grafana
    ENABLE_GRAFANA=${ENABLE_GRAFANA:-Y}
fi

# Create .env

echo ""
echo "Generating environment configuration"

if [ -f ".env" ]; then
    echo ".env already exists in project root. Skipping creation"
else
    echo "Writing configuration to .env"

    cat > .env <<EOF
PORT=$PORT

HOME_HOST=home.localhost
VAULT_HOST=vault.localhost
GITEA_HOST=gitea.localhost
GRAFANA_HOST=grafana.localhost

ENABLE_VAULTWARDEN=$ENABLE_VAULT
ENABLE_GITEA=$ENABLE_GITEA
ENABLE_GRAFANA=$ENABLE_GRAFANA
EOF
fi



# Create data directories

echo ""
echo "Creating data directories"

mkdir -p data/gitea
mkdir -p data/grafana
mkdir -p data/vaultwarden

# Set permissions

echo ""
echo "Setting container permissions..."

sudo chown -R 1000:1000 data/vaultwarden || true
sudo chown -R 1000:1000 data/gitea || true
sudo chown -R 472:472 data/grafana || true
sudo chown -R $(id -u):$(id -g) data || true

echo ""
echo "You may need to log out and back in for Docker permissions"

# Finish

echo ""
echo "Setup complete!"
echo ""
echo "Start StarterLab with:"
echo ""
echo "./scripts/start.sh"
echo ""
