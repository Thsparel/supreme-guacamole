#!/bin/bash

# Install dependencies
echo "Installing dependencies..."
apt update
apt install -y zip unzip wget curl

cd /mnt/server

# Clean up previous files
rm -f versions.html.gz *.bak bedrock-server.zip

# Determine download URL
if [ -z "${BEDROCK_VERSION}" ] || [ "${BEDROCK_VERSION}" == "latest" ]; then
    echo "Downloading latest Bedrock server"
    RANDVERSION=$(echo $((1 + $RANDOM % 4000)))
    curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RANDVERSION.212 Safari/537.36" \
         -H "Accept-Language: en" \
         -H "Accept-Encoding: gzip, deflate" \
         -o versions.html.gz \
         "https://www.minecraft.net/en-us/download/server/bedrock"
    
    DOWNLOAD_URL=$(zgrep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' versions.html.gz)
    echo "Download URL: $DOWNLOAD_URL"
else 
    echo "Downloading Bedrock server version: ${BEDROCK_VERSION}"
    DOWNLOAD_URL="https://minecraft.azureedge.net/bin-linux/bedrock-server-${BEDROCK_VERSION}.zip"
fi

# Backup existing config files
cp -f server.properties server.properties.bak 2>/dev/null || true
cp -f permissions.json permissions.json.bak 2>/dev/null || true
cp -f allowlist.json allowlist.json.bak 2>/dev/null || true

# Download Bedrock server
echo "Downloading Bedrock server..."
curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RANDVERSION.212 Safari/537.36" \
     -H "Accept-Language: en" \
     -o bedrock-server.zip \
     "$DOWNLOAD_URL"

# Extract and cleanup
echo "Extracting server files..."
unzip -o bedrock-server.zip
rm -f bedrock-server.zip versions.html.gz

# Restore config files if they existed
cp -f server.properties.bak server.properties 2>/dev/null || true
cp -f permissions.json.bak permissions.json 2>/dev/null || true  
cp -f allowlist.json.bak allowlist.json 2>/dev/null || true

# Make server executable
chmod +x bedrock_server

echo "Bedrock Server installation completed!"
