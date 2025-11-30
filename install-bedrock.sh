#!/bin/bash
cd /mnt/server

rm -f versions.html.gz *.bak

# Determine download URL
if [ -z "${BEDROCK_VERSION}" ] || [ "${BEDROCK_VERSION}" == "latest" ]; then
    echo "Downloading latest Bedrock server"
    RANDVERSION=$(echo $((1 + $RANDOM % 4000)))
    curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RANDVERSION.212 Safari/537.36" -H "Accept-Language: en" -H "Accept-Encoding: gzip, deflate" -o versions.html.gz "https://www.minecraft.net/en-us/download/server/bedrock"
    DOWNLOAD_URL=$(zgrep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' versions.html.gz)
else 
    echo "Downloading ${BEDROCK_VERSION} Bedrock server"
    DOWNLOAD_URL="https://minecraft.azureedge.net/bin-linux/bedrock-server-${BEDROCK_VERSION}.zip"
fi

DOWNLOAD_FILE=$(echo ${DOWNLOAD_URL} | cut -d"/" -f5)

# Backup config files
cp -f server.properties server.properties.bak 2>/dev/null || true
cp -f permissions.json permissions.json.bak 2>/dev/null || true
cp -f allowlist.json allowlist.json.bak 2>/dev/null || true

echo "Downloading from: $DOWNLOAD_URL"
curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RANDVERSION.212 Safari/537.36" -H "Accept-Language: en" -o "$DOWNLOAD_FILE" "$DOWNLOAD_URL"

echo "Unpacking server files"
unzip -o "$DOWNLOAD_FILE"

rm -f "$DOWNLOAD_FILE"
rm -f versions.html.gz

# Restore config files
cp -f server.properties.bak server.properties 2>/dev/null || true
cp -f permissions.json.bak permissions.json 2>/dev/null || true  
cp -f allowlist.json.bak allowlist.json 2>/dev/null || true

chmod +x bedrock_server

echo "Installation completed!"
