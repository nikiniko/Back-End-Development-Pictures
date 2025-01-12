#!/bin/bash
echo "****************************************"
echo " Setting up Capstone Environment"
echo "****************************************"

echo "Installing Python 3.9 or newer and Virtual Environment"
sudo apt-get update
if command -v python3 >/dev/null 2>&1; then
    CURRENT_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    REQUIRED_VERSION="3.9"
    if [ "$CURRENT_VERSION" != "$REQUIRED_VERSION" ] && [ "$(printf '%s\n' "$REQUIRED_VERSION" "$CURRENT_VERSION" | sort -V | head -n1)" = "$CURRENT_VERSION" ]; then
        echo "Updating Python to version $REQUIRED_VERSION..."
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3.9 python3.9-venv
    else
        echo "Python version $CURRENT_VERSION is already installed and is more recent than $REQUIRED_VERSION. No update required."
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python$(echo "$CURRENT_VERSION" | cut -d. -f1-2)-venv
    fi
else
    echo "Python is not installed. Installing Python $REQUIRED_VERSION..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3.9 python3.9-venv
fi


echo "Checking the Python version..."
python3 --version

echo "Creating a Python virtual environment"
python3 -m venv ~/venv

echo "Configuring the developer environment..."
echo "# DevOps Capstone Project additions" >> ~/.bashrc
echo "export GITHUB_ACCOUNT=$GITHUB_ACCOUNT" >> ~/.bashrc
echo 'export PS1="\[\e]0;\u:\W\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ "' >> ~/.bashrc
echo "source ~/venv/bin/activate" >> ~/.bashrc

echo "Installing Python dependencies..."
sudo apt-get install -y python$(echo "$CURRENT_VERSION" | cut -d. -f1-2)-dev #build-essential libpq-dev
source ~/venv/bin/activate && python$(echo "$CURRENT_VERSION" | cut -d. -f1-2) -m pip install --upgrade pip wheel
source ~/venv/bin/activate && pip install -r requirements.txt
source ~/venv/bin/activate && pip install pytest  # Add this line for pytest

echo "Starting the Postgres Docker container..."
make db

echo "Checking the Postgres Docker container..."
sudo apt-get install -y docker.io
docker ps

echo "****************************************"
echo " Capstone Environment Setup Complete"
echo "****************************************"
echo ""
echo "Use 'exit' to close this terminal and open a new one to initialize the environment"
echo ""
