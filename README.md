# Share Your DREAM Friday — Railway Deployment Guide

This repository contains everything you need to deploy your recovered WordPress site on [Railway](https://railway.com) using Docker. This is a clean, secure setup that replaces your old HostGator hosting.

---

## Why Railway Instead of HostGator?

| Feature | HostGator Shared | Railway |
|---|---|---|
| **Estimated Monthly Cost** | ~$10–$15/month | ~$5–$10/month |
| **Isolation** | Shared server with other sites | Your own Docker container |
| **Security** | Shared PHP environment | Isolated container, no shared risk |
| **Scalability** | Fixed resources | Scales automatically |
| **Deployments** | FTP/cPanel | Git push to deploy |
| **Persistent Storage** | cPanel file manager | Persistent volumes |
| **Database** | Shared MySQL | Dedicated MySQL container |
| **SSL/HTTPS** | Paid add-on or Let's Encrypt | Free, automatic |
| **Custom Domain** | Yes | Yes |

---

## Repository Structure

```
railway-wordpress/
├── Dockerfile                  # Builds the WordPress Docker image
├── railway.toml                # Railway deployment configuration
├── .env.example                # Template for environment variables
├── .gitignore                  # Files to exclude from git
├── README.md                   # This guide
├── wordpress-config/
│   ├── php.ini                 # Custom PHP settings (memory, uploads)
│   └── apache.conf             # Custom Apache settings (security headers, caching)
└── scripts/
    ├── import-database.sh      # Imports your SQL dump into Railway MySQL
    └── update-site-url.sh      # Updates the WordPress site URL after migration
```

---

## Step-by-Step Deployment Guide

### Prerequisites

Before you begin, you will need:
- A free [Railway account](https://railway.com) (no credit card required for the trial)
- [Git](https://git-scm.com/) installed on your computer
- A [GitHub account](https://github.com) (Railway deploys from GitHub)
- The Railway CLI (optional but recommended for database import)

---

### Step 1: Create a GitHub Repository

1. Go to [github.com](https://github.com) and create a **new private repository**. Name it something like `shareyourdreamfriday-railway`.
2. Do **not** initialize it with a README (you already have one here).
3. Copy the contents of this `railway-wordpress/` folder into your new repository.
4. Commit and push all the files to GitHub.

```bash
# Example commands (run in the railway-wordpress/ directory)
git init
git add .
git commit -m "Initial Railway WordPress deployment setup"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/shareyourdreamfriday-railway.git
git push -u origin main
```

---

### Step 2: Create a New Railway Project

1. Log in to [railway.com](https://railway.com).
2. Click **"New Project"**.
3. Select **"Deploy from GitHub repo"**.
4. Connect your GitHub account if prompted, then select the repository you just created.
5. Railway will detect the `Dockerfile` and begin building automatically. **Wait for the build to complete** before proceeding.

---

### Step 3: Add a MySQL Database Service

Your WordPress site needs a database. Railway makes this easy.

1. In your Railway project canvas, click the **"+"** button (or right-click the canvas).
2. Select **"Database"** → **"Add MySQL"**.
3. Railway will spin up a dedicated MySQL container and automatically generate secure credentials for it.
4. **Link the database to your WordPress service:** Click on your WordPress service, go to the **"Variables"** tab, and click **"Add Variable Reference"**. Add references to the MySQL service variables as shown in the `.env.example` file.

---

### Step 4: Configure Environment Variables

In your Railway project, click on your **WordPress service**, then go to the **"Variables"** tab. Add the following variables:

| Variable Name | Value |
|---|---|
| `WORDPRESS_DB_HOST` | `${{MySQL.MYSQL_HOST}}:${{MySQL.MYSQL_PORT}}` |
| `WORDPRESS_DB_NAME` | `${{MySQL.MYSQL_DATABASE}}` |
| `WORDPRESS_DB_USER` | `${{MySQL.MYSQL_USER}}` |
| `WORDPRESS_DB_PASSWORD` | `${{MySQL.MYSQL_PASSWORD}}` |
| `WORDPRESS_AUTH_KEY` | *(Generate at [wp salt API](https://api.wordpress.org/secret-key/1.1/salt/))* |
| `WORDPRESS_SECURE_AUTH_KEY` | *(Generate at [wp salt API](https://api.wordpress.org/secret-key/1.1/salt/))* |
| `WORDPRESS_LOGGED_IN_KEY` | *(Generate at [wp salt API](https://api.wordpress.org/secret-key/1.1/salt/))* |
| `WORDPRESS_NONCE_KEY` | *(Generate at [wp salt API](https://api.wordpress.org/secret-key/1.1/salt/))* |
| `WORDPRESS_AUTH_SALT` | *(Generate at [wp salt API](https://api.wordpress.org/secret-key/1.1/salt/))* |
| `WORDPRESS_SECURE_AUTH_SALT` | *(Generate at [wp salt API](https://api.wordpress.org/secret-key/1.1/salt/))* |
| `WORDPRESS_LOGGED_IN_SALT` | *(Generate at [wp salt API](https://api.wordpress.org/secret-key/1.1/salt/))* |
| `WORDPRESS_NONCE_SALT` | *(Generate at [wp salt API](https://api.wordpress.org/secret-key/1.1/salt/))* |
| `WORDPRESS_DEBUG` | `false` |

> **Tip:** Visit [https://api.wordpress.org/secret-key/1.1/salt/](https://api.wordpress.org/secret-key/1.1/salt/) to generate all 8 salt values at once. Each time you visit the page, it generates a new unique set.

---

### Step 5: Attach a Persistent Volume for Uploads

This is critical. Without a persistent volume, your uploaded images and media files will be **deleted every time the container restarts**.

1. In your Railway project canvas, right-click and select **"Add Volume"**.
2. Name it `wordpress-uploads`.
3. Connect it to your **WordPress service**.
4. Set the **Mount Path** to `/var/www/html/wp-content/uploads`.
5. Railway will redeploy your service with the volume attached.

---

### Step 6: Import Your Database

You have two options for importing your database.

**Option A: Using the Railway CLI (Recommended)**

1. Install the Railway CLI: `npm install -g @railway/cli`
2. Log in: `railway login`
3. Link your project: `railway link` (run this in your project directory)
4. Run the import script:
   ```bash
   chmod +x scripts/import-database.sh
   ./scripts/import-database.sh /path/to/eeidde_wrdp3.sql
   ```

**Option B: Using TablePlus or DBeaver (GUI)**

1. In your Railway project, click on the **MySQL service**.
2. Go to the **"Connect"** tab and copy the **Public URL** connection string.
3. Open a database GUI tool like [TablePlus](https://tableplus.com/) (free) or [DBeaver](https://dbeaver.io/) (free).
4. Create a new connection using the credentials from the Railway MySQL "Connect" tab.
5. Use the GUI tool's import feature to import your `eeidde_wrdp3.sql` file.

---

### Step 7: Update the Site URL

After importing the database, the WordPress `siteurl` and `home` options still point to `http://shareyourdreamfriday.com`. You need to update them to your new Railway URL.

**Find your Railway URL:** In your WordPress service, go to the **"Settings"** tab and look for the **"Domains"** section. Copy the auto-generated Railway domain (e.g., `https://your-service-name.up.railway.app`).

**Option A: Using the Script**
```bash
chmod +x scripts/update-site-url.sh
./scripts/update-site-url.sh https://your-service-name.up.railway.app
```

**Option B: Manually via MySQL**

Connect to your MySQL service and run:
```sql
UPDATE wp_options
SET option_value = 'https://your-service-name.up.railway.app'
WHERE option_name IN ('siteurl', 'home');
```

---

### Step 8: Add Your Custom Domain

Once the site is working on the Railway domain, you can point your real domain to it.

1. In your WordPress service, go to **"Settings"** → **"Domains"**.
2. Click **"Add Custom Domain"** and enter `shareyourdreamfriday.com`.
3. Railway will provide you with a **CNAME record** to add to your domain's DNS settings.
4. Log in to wherever your domain is registered (e.g., GoDaddy, Namecheap, Cloudflare) and add the CNAME record.
5. DNS changes can take up to 24 hours to propagate, but usually take only a few minutes.
6. Once the domain is verified, run the URL update script again with your real domain:
   ```bash
   ./scripts/update-site-url.sh https://shareyourdreamfriday.com
   ```
7. Railway automatically provisions a free SSL certificate for your custom domain.

---

### Step 9: Import Your Content (Posts & Pages)

After your site is live, import your posts and pages using the XML file provided.

1. Log in to your WordPress admin dashboard (`https://your-domain.com/wp-admin`).
2. Go to **Tools → Import**.
3. Find **"WordPress"** and click **"Install Now"**, then **"Run Importer"**.
4. Upload the `shareyourdreamfriday.wordpress.xml` file provided separately.
5. **Check the box** to "Download and import file attachments" — this will pull your original images.
6. Click **"Submit"**.

---

### Step 10: Security Hardening (Final Step)

Install these plugins immediately after the site is live:

1. **Wordfence Security** — Firewall and malware scanner.
2. **UpdraftPlus** — Automated backups to Google Drive or Dropbox.
3. **WP Super Cache** or **W3 Total Cache** — Performance caching.
4. **Limit Login Attempts Reloaded** — Blocks brute-force login attacks.

---

## Estimated Monthly Cost on Railway

For a low-traffic personal blog like this site, the estimated Railway cost is:

| Service | Estimated Cost |
|---|---|
| WordPress container (idle/low traffic) | ~$2–$4/month |
| MySQL database | ~$1–$2/month |
| Persistent volume (5 GB) | ~$0.25/month |
| **Total** | **~$5–$8/month** |

This is significantly cheaper than HostGator's shared hosting plans, and you get a fully isolated, containerized environment that is far more secure.

---

## Troubleshooting

**Site shows "Error establishing a database connection"**
- Verify all `WORDPRESS_DB_*` environment variables are set correctly in Railway.
- Ensure the MySQL service is running (check its logs in Railway).

**Uploaded images are not persisting after redeploy**
- Verify the persistent volume is attached to the WordPress service with the mount path `/var/www/html/wp-content/uploads`.

**Site URL is wrong / redirecting incorrectly**
- Run the `update-site-url.sh` script with your correct domain.
- Clear any browser cache and WordPress cache after updating.

**WordPress is not sending emails**
- Railway containers cannot send email directly. Install the **WP Mail SMTP** plugin and configure it with a free [Brevo](https://www.brevo.com/) (formerly Sendinblue) or [Mailgun](https://www.mailgun.com/) account.
