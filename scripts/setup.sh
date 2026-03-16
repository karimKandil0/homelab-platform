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
if command -v sudo >/dev/null 2>&1; then
    echo "Requesting sudo access to initialize StarterLab..."
    sudo -v
    SUDO="sudo"
else
    SUDO=""
fi
echo ""
echo ""
echo ""
echo "StarterLab Setup"
echo "================"
echo ""

# CI detection

if [ "${CI:-}" = "true" ] || [ -f /.dockerenv ]; then
    INSTALL_DOCKER=false
    echo "CI/container detected - skipping Docker installation."
fi

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
        $SUDO apt update

        if $INSTALL_DOCKER; then
            $SUDO apt install -y docker.io docker-compose
        fi

        if $INSTALL_GETTEXT; then
            $SUDO apt install -y gettext
        fi
        ;;

    arch)
        if $INSTALL_DOCKER; then
            $SUDO pacman -Sy --noconfirm docker docker-compose
        fi

        if $INSTALL_GETTEXT; then
            $SUDO pacman -Sy --noconfirm gettext
        fi
        ;;

    fedora)
        if $INSTALL_DOCKER; then
            $SUDO dnf install -y docker docker-compose-plugin
        fi

        if $INSTALL_GETTEXT; then
            $SUDO dnf install -y gettext
        fi
        ;;

    nixos)
        if $INSTALL_DOCKER; then
            echo "Please install docker manually."
        fi

        if $INSTALL_GETTEXT; then
	    echo "Please install gettext manually."
	    exit 1
        fi
        ;;

    *)
        echo "Unsupported distro: $DISTRO"
        exit 1
        ;;
esac

if command -v systemctl >/dev/null 2>&1; then
    echo "systemd not detected, skipping Docker service management."
else 
    if ! systemctl is-active --quiet docker; then 
        echo "Starting Docker..."
        $SUDO systemctl enable docker
        $SUDO systemctl start docker
    fi
fi

# Ask user configuration

echo ""
echo "Configuration"
echo "============="


if [[ "${1:-}" == "--non-interactive" ]]; then
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

    # Vaultwarden variable check
    read -rp "Enable Vaultwarden? (Y/n):" ENABLE_VAULT
    ENABLE_VAULT=${ENABLE_VAULT:-Y}

    ENABLE_VAULT=$(echo "$ENABLE_VAULT" | tr '[:lower:]' '[:upper:]')
    if [[ "$ENABLE_VAULT" != "Y" && "$ENABLE_VAULT" != "N" ]]; then
        echo "Invalid input. Using default: Y"
        ENABLE_VAULT="Y"
    fi

    # Gitea variable check
    read -rp "Enable Gitea? (Y/n):" ENABLE_GITEA
    ENABLE_GITEA=${ENABLE_GITEA:-Y}

    ENABLE_GITEA=$(echo "$ENABLE_GITEA" | tr '[:lower:]' '[:upper:]')
    if [[ "$ENABLE_GITEA" != "Y" && "$ENABLE_GITEA" != "N" ]]; then
        echo "Invalid input. Using default: Y"
        ENABLE_GITEA="Y"
    fi

    # Grafana variable check
    read -rp "Enable Grafana? (Y/n):" ENABLE_GRAFANA
    ENABLE_GRAFANA=${ENABLE_GRAFANA:-Y}

    ENABLE_GRAFANA=$(echo "$ENABLE_GRAFANA" | tr '[:lower:]' '[:upper:]')
    if [[ "$ENABLE_GRAFANA" != "Y" && "$ENABLE_GRAFANA" != "N" ]]; then
        echo "Invalid input. Using default: Y"
        ENABLE_GRAFANA="Y"
    fi
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

for dir in gitea grafana prometheus vaultwarden; do
    mkdir -p "data/$dir"
done

# Set permissions

echo ""
echo "Setting container permissions..."

$SUDO chown -R 1000:1000 data/vaultwarden || true
$SUDO chown -R 1000:1000 data/gitea || true
$SUDO chown -R 472:472 data/grafana || true
$SUDO chown -R 65534:65534 data/prometheus || true

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
