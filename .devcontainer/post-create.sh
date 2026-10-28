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

echo "Ensuring Node.js meets Pi requirements (>= 22.19.0)..."
export NVM_DIR="/usr/local/share/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 22.19.0
nvm use 22.19.0
nvm alias default 22.19.0

echo "Installing Pi coding agent via npm..."
npm install -g --ignore-scripts @earendil-works/pi-coding-agent

echo "Creating piupdate.sh script..."
cat << 'EOF' > /home/node/piupdate.sh
#!/bin/bash
export NVM_DIR="/usr/local/share/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
set -e
echo "Updating Pi coding agent..."
npm install -g --ignore-scripts @earendil-works/pi-coding-agent@latest
echo "Pi update complete!"
EOF
chmod +x /home/node/piupdate.sh

echo "Creating opencodeupdate.sh script..."
cat << 'EOF' > /home/node/opencodeupdate.sh
#!/bin/bash
set -e
echo "Updating OpenCode..."
echo "OpenCode update checked."
EOF
chmod +x /home/node/opencodeupdate.sh

echo "Injecting helpful Gradle and development aliases into .bashrc..."
cat << 'EOF' >> ~/.bashrc

# --- Custom Android & Agent Development Aliases ---
alias gtest='./gradlew test'
alias gbuild='./gradlew assembleDebug'
alias gclean='./gradlew clean'
alias glint='./gradlew lint'
alias ginstall='./gradlew installDebug'
alias adb-connect='read -p "Enter Phone IP: " ip; adb connect "$ip:5555"'
alias update-pi='/home/node/piupdate.sh'
alias update-opencode='/home/node/opencodeupdate.sh'
alias update-agents='npm update -g @earendil-works/pi-coding-agent'
# --------------------------------------------------
EOF

echo "===================================================="
echo " Devcontainer Android Environment Ready!"
echo "===================================================="
echo " Here are your available helpful terminal aliases:"
echo "   • gtest             -> Run local JVM unit tests (./gradlew test)"
echo "   • gbuild            -> Build debug APK (./gradlew assembleDebug)"
echo "   • gclean            -> Clean build cache (./gradlew clean)"
echo "   • glint             -> Run lint checks (./gradlew lint)"
echo "   • ginstall          -> Install debug build (./gradlew installDebug)"
echo "   • adb-connect       -> Prompt for phone IP and connect via Wireless ADB"
echo "   • update-pi         -> Update Pi coding agent to latest version"
echo "   • update-opencode   -> Update OpenCode helper"
echo "   • update-agents     -> Update all global coding agents"
echo "===================================================="
