# Automated Backup

Project URL : https://roadmap.sh/projects/automated-backups

An automated MongoDB backup solution that periodically dumps the database and uploads backups to Cloudflare R2, orchestrated via Terraform, and triggered by GitHub Actions on a schedule.

## Project structure

```
.github/workflows/          # CI/CD pipeline
  github_actions.yml        # Scheduled backup job (every 5 minutes)
terraform/                  # AWS infrastructure
  main.tf                   # EC2 instance
  network/                  # VPC, subnet, routes
  security/                 # Security group rules
keys/                       # SSH keys used by Terraform
setup.sh                    # MongoDB installation script
```

## How it works

### Architecture

The system runs on a single EC2 instance with:
- **MongoDB** database storing test data
- **mongodump** to backup database snapshots
- **rclone** to upload backups to Cloudflare R2 (S3-compatible object storage)
- **GitHub Actions** to trigger backups on a schedule

### Backup workflow

1. GitHub Actions scheduler triggers every 5 minutes.
2. SSH into the EC2 instance.
3. Run `mongodump` on the `testdb.testCollection` database/collection.
4. Compress the dump to gzip format with timestamp.
5. Upload the compressed backup to Cloudflare R2 using rclone.

Backup naming: `dump_github_action_YYYY-MM-DD_HH_MM.gz`

### MongoDB setup

The `setup.sh` script:
- Installs MongoDB 7.0
- Downloads sample test data (zips.json)
- Imports the data into `testdb.testCollection`

## Infrastructure

### Terraform (AWS)

- **VPC + subnet + route table** in `terraform/network/`.
- **Security group** in `terraform/security/` allowing SSH (22), HTTP (80), and port 3000.
- **EC2 instance** provisioned in `terraform/main.tf` using a provided AMI and instance type.
- **Key pair** created from `keys/key.pub`.

## CI/CD (GitHub Actions)

Pipeline in `.github/workflows/github_actions.yml`:

- **Trigger**: Every 5 minutes via cron schedule (`*/5 * * * *`).
- **Action**: SSH into the instance and execute backup commands.
- **Upload**: Backup file copied to Cloudflare R2.

Secrets required:
- `HOST` — EC2 public IP or DNS
- `USERNAME` — SSH user (e.g., ubuntu)
- `KEY` — SSH private key
- `PORT` — SSH port (usually 22)
- rclone configured with R2 credentials in `~/.config/rclone/rclone.conf`

## Deployment workflow

1. **Provision infrastructure** with Terraform in `terraform/`.
2. **Install MongoDB** on the instance using `setup.sh`.
3. **Configure rclone** on the instance with Cloudflare R2 credentials.
4. **Push to GitHub** to activate the scheduled backups.

## Notes

- Backups are stored in gzip format to save storage space.
- R2 integration requires rclone to be installed and configured on the EC2 instance.
- The backup runs every 5 minutes, which may create many files; consider adjusting the cron schedule for production use.
