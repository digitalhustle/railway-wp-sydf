#!/bin/bash
# ============================================================
# import-database.sh
# Run this script ONCE after Railway has deployed your MySQL
# service to import your existing database content.
#
# PREREQUISITES:
#   1. Install the Railway CLI: npm install -g @railway/cli
#   2. Log in: railway login
#   3. Link your project: railway link
#   4. Have your SQL dump file ready (e.g., eeidde_wrdp3.sql)
#
# USAGE:
#   chmod +x scripts/import-database.sh
#   ./scripts/import-database.sh /path/to/eeidde_wrdp3.sql
# ============================================================

set -e

SQL_FILE="${1}"

if [ -z "${SQL_FILE}" ]; then
    echo "ERROR: Please provide the path to your SQL dump file."
    echo "Usage: ./scripts/import-database.sh /path/to/your-database.sql"
    exit 1
fi

if [ ! -f "${SQL_FILE}" ]; then
    echo "ERROR: SQL file not found at: ${SQL_FILE}"
    exit 1
fi

echo "=============================================="
echo " Railway WordPress Database Import Script"
echo "=============================================="
echo ""
echo "This script will import your WordPress database"
echo "into the Railway MySQL service."
echo ""
echo "SQL File: ${SQL_FILE}"
echo ""

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "ERROR: Railway CLI is not installed."
    echo "Install it with: npm install -g @railway/cli"
    exit 1
fi

echo "Step 1: Connecting to Railway MySQL service..."
echo "Running: railway run mysql < ${SQL_FILE}"
echo ""
echo "NOTE: This may take a few minutes depending on database size."
echo ""

# Import the database via Railway's tunnel
railway run --service MySQL -- bash -c "mysql -u \$MYSQL_USER -p\$MYSQL_PASSWORD \$MYSQL_DATABASE" < "${SQL_FILE}"

echo ""
echo "=============================================="
echo " Database import complete!"
echo "=============================================="
echo ""
echo "IMPORTANT: After import, you must update the"
echo "site URL in the database to match your new"
echo "Railway domain. Run the following command:"
echo ""
echo "  railway run --service MySQL -- bash -c \\"
echo "    \"mysql -u \\\$MYSQL_USER -p\\\$MYSQL_PASSWORD \\\$MYSQL_DATABASE -e \\"
echo "    \\\"UPDATE wp_options SET option_value='https://YOUR-RAILWAY-DOMAIN.railway.app'"
echo "    WHERE option_name IN ('siteurl', 'home');\\\"\""
echo ""
echo "Replace YOUR-RAILWAY-DOMAIN with your actual Railway domain."
