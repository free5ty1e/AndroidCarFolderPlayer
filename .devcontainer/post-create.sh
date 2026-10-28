#!/bin/bash
set -e

echo "Initializing Android Command Line Tools..."
ANDROID_HOME="/home/node/android-sdk"
mkdir -p "$ANDROID_HOME/cmdline-tools"

# Download latest Android Command Line Tools (SDK components)
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
curl -sSL "$CMDLINE_TOOLS_URL" -o /tmp/cmdline-tools.zip
unzip -q /tmp/cmdline-tools.zip -d /tmp/
mv /tmp/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"
rm /tmp/cmdline-tools.zip

# Set up environment variables permanently for the user
echo "export ANDROID_HOME=$ANDROID_HOME" >> ~/.bashrc
echo "export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools" >> ~/.bashrc

# Accept Android SDK licenses
yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses > /dev/null 2>&1 || true

echo "Installing Pi coding agent via npm..."
npm install -g --ignore-scripts @earendil-works/pi-coding-agent

echo "Devcontainer environment ready!"
