#!/bin/bash
# ============================================================
# update-site-url.sh
# Run this script after importing your database to update
# the WordPress site URL to your new Railway domain.
#
# USAGE:
#   chmod +x scripts/update-site-url.sh
#   ./scripts/update-site-url.sh https://your-domain.com
# ============================================================

set -e

NEW_URL="${1}"

if [ -z "${NEW_URL}" ]; then
    echo "ERROR: Please provide your new site URL."
    echo "Usage: ./scripts/update-site-url.sh https://your-domain.com"
    exit 1
fi

# Remove trailing slash if present
NEW_URL="${NEW_URL%/}"

echo "=============================================="
echo " WordPress Site URL Update Script"
echo "=============================================="
echo ""
echo "Updating WordPress site URL to: ${NEW_URL}"
echo ""

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "ERROR: Railway CLI is not installed."
    echo "Install it with: npm install -g @railway/cli"
    exit 1
fi

echo "Updating siteurl and home options in wp_options..."

railway run --service MySQL -- bash -c \
    "mysql -u \$MYSQL_USER -p\$MYSQL_PASSWORD \$MYSQL_DATABASE -e \
    \"UPDATE wp_options SET option_value='${NEW_URL}' WHERE option_name IN ('siteurl', 'home');\""

echo ""
echo "Done! Site URL updated to: ${NEW_URL}"
echo ""
echo "IMPORTANT: If your old site used http:// and your new"
echo "site uses https://, you should also run a search-replace"
echo "on the post content. Install the 'Better Search Replace'"
echo "plugin in WordPress to do this safely."
