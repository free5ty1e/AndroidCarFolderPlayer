#!/bin/bash
set -e

echo "Initializing Android SDK and Command Line Tools..."
ANDROID_HOME="/home/node/android-sdk"
mkdir -p "$ANDROID_HOME/cmdline-tools"

# Download latest Android Command Line Tools
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
curl -sSL "$CMDLINE_TOOLS_URL" -o /tmp/cmdline-tools.zip
unzip -q /tmp/cmdline-tools.zip -d /tmp/
mv /tmp/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"
rm /tmp/cmdline-tools.zip

# Set environment variables permanently for the node user
echo "export ANDROID_HOME=$ANDROID_HOME" >> ~/.bashrc
echo "export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools" >> ~/.bashrc

# Export for current session execution
export ANDROID_HOME="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

# Accept SDK licenses automatically
yes | sdkmanager --licenses > /dev/null 2>&1 || true

echo "Installing Android platform-tools, platforms (API 34/35), and build-tools..."
sdkmanager "platform-tools" "platforms;android-34" "platforms;android-35" "build-tools;34.0.0" "build-tools;35.0.0"

echo "Installing Pi coding agent via npm..."
npm install -g --ignore-scripts @earendil-works/pi-coding-agent

echo "Devcontainer Android development environment ready!"
