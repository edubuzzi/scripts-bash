#!/bin/bash

echo ""
echo "========================================="
echo " UFW - Advanced Firewall Configuration"
echo "========================================="
echo ""

# Check if script is run as root
if [[ "$EUID" -ne 0 ]]; then
    echo "❌ This script must be run as root. Try: sudo $0"
    exit 1
fi

# Check if sudo is installed
if ! command -v sudo &> /dev/null; then
    echo "❌ 'sudo' is not installed. Please install it with: apt install sudo"
    exit 1
fi

# Check if ufw is installed
if ! command -v ufw &> /dev/null; then
    echo "❌ 'ufw' is not installed. Install it with: sudo apt install ufw"
    exit 1
fi

# Initial menu
echo "Select an option:"
echo "1) Continue with Firewall configuration"
echo "2) Check current UFW status"
echo "3) Exit"
echo ""
read -p "Option [1-3]: " option

case "$option" in
    1)
        # Continue with advanced configuration
        ;;
    2)
        echo ""
        echo "Current UFW status:"
        sudo ufw status verbose
        exit 0
        ;;
    3)
        echo ""
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo ""
        echo "Invalid option. Exiting..."
        exit 1
        ;;
esac

# Function to read TCP ports, just captures input
read_ports() {
    local ports=()
    while true; do
        read -p "TCP Port (e.g., 80): " port
        [[ -z "$port" ]] && break
        if [[ "$port" =~ ^[0-9]+$ ]] && ((port > 0 && port < 65536)); then
            ports+=("$port")
        else
            echo "⚠️ Invalid port! Enter a number between 1 and 65535."
        fi
    done
    echo "${ports[@]}"
}

# Set default policy for incoming connections
echo ""
read -p "Deny incoming connections by default? (y/n) [y]: " deny_in
deny_in=${deny_in:-y}  # default 'y'

# Set default policy for outgoing connections
read -p "Allow outgoing connections by default? (y/n) [y]: " allow_out
allow_out=${allow_out:-y}  # default 'y'

# Allow TCP ports
echo ""
echo "📥 TCP ports you want to ALLOW."
echo "Enter the TCP ports you want to add."
echo "For example: 22"
echo "To finish, just press ENTER without typing anything."
allow_ports=($(read_ports))

# Deny TCP ports
echo ""
echo "⛔ TCP ports you want to DENY."
echo "Enter the TCP ports you want to add."
echo "For example: 22"
echo "To finish, just press ENTER without typing anything."
deny_ports=($(read_ports))

# Show summary
echo ""
echo "================================="
echo "🔒 Configuration Summary"
echo "================================="
echo ""
echo "Default incoming policy: $( [[ "$deny_in" =~ ^[Yy]$ ]] && echo "deny" || echo "allow" )"
echo "Default outgoing policy: $( [[ "$allow_out" =~ ^[Yy]$ ]] && echo "allow" || echo "deny" )"
echo "ALLOWED ports: ${allow_ports[*]:-"None"}"
echo "DENIED ports: ${deny_ports[*]:-"None"}"
echo ""

read -p "Apply these rules? (y/n): " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔧 Applying rules..."
    echo ""

    # Apply default incoming policy
    if [[ "$deny_in" =~ ^[Yy]$ ]]; then
        sudo ufw default deny incoming
    else
        sudo ufw default allow incoming
    fi

    # Apply default outgoing policy
    if [[ "$allow_out" =~ ^[Yy]$ ]]; then
        sudo ufw default allow outgoing
    else
        sudo ufw default deny outgoing
    fi

    # Allow specified ports
    for port in "${allow_ports[@]}"; do
        echo "Allowing port $port/tcp"
        sudo ufw allow "$port"/tcp
    done

    # Deny specified ports
    for port in "${deny_ports[@]}"; do
        echo "Denying port $port/tcp"
        sudo ufw deny "$port"/tcp
    done

    # Enable the firewall
    echo ""
    sudo ufw enable

    echo ""
    echo "✅ Rules applied successfully!"
else
    echo ""
    echo "🚫 Operation cancelled."
fi
