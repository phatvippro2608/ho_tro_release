#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=========================================================="
echo " Starting Khaosat VLUTE (Formbricks Custom Build) Docker "
echo "=========================================================="

# Create mount directories if they don't exist
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
mkdir -p "$SCRIPT_DIR/uploads"
mkdir -p "$SCRIPT_DIR/saml-connection"

# Load environment variables from .env file if it exists
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "Loading environment variables from $SCRIPT_DIR/.env..."
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ ! "$line" =~ ^# ]] && [[ -n "$line" ]]; then
            eval "export $line" 2>/dev/null || export "$line"
        fi
    done < "$SCRIPT_DIR/.env"
elif [ -f "$REPO_ROOT/.env" ]; then
    echo "Loading environment variables from $REPO_ROOT/.env..."
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ ! "$line" =~ ^# ]] && [[ -n "$line" ]]; then
            eval "export $line" 2>/dev/null || export "$line"
        fi
    done < "$REPO_ROOT/.env"
fi

# Create a temporary environment file in the same directory
TEMP_ENV="$SCRIPT_DIR/.env.tmp"

# Ensure the temp file is deleted on exit (even in case of errors)
cleanup() {
    rm -f "$TEMP_ENV"
    echo "Cleaned up temporary environment file: $TEMP_ENV"
}
trap cleanup EXIT

# ----------------- Defaults & Environment Variables -----------------

# Basics
WEBAPP_URL=${WEBAPP_URL:-"http://localhost:3000/khao-sat"}
NEXTAUTH_URL=${NEXTAUTH_URL:-"http://localhost:3000/khao-sat"}
LOG_LEVEL=${LOG_LEVEL:-"info"}

# Generate secure random secrets on the fly if not provided
generate_secret() {
    openssl rand -hex 32 2>/dev/null || od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n'
}

ENCRYPTION_KEY=${ENCRYPTION_KEY:-$(generate_secret)}
NEXTAUTH_SECRET=${NEXTAUTH_SECRET:-$(generate_secret)}
CRON_SECRET=${CRON_SECRET:-$(generate_secret)}

# Databases
DATABASE_URL=${DATABASE_URL:-"postgresql://postgres:postgres@postgres:5432/formbricks?schema=public"}
REDIS_URL=${REDIS_URL:-"redis://redis:6379"}

# Hub
HUB_API_URL=${HUB_API_URL:-"http://hub:8080"}
HUB_API_KEY=${HUB_API_KEY:-$(generate_secret)}
HUB_DATABASE_URL=${HUB_DATABASE_URL:-"postgresql://postgres:postgres@postgres:5432/hub?sslmode=disable"}

# Cube Analytics
CUBEJS_API_URL=${CUBEJS_API_URL:-"http://cube:4000"}
CUBEJS_API_SECRET=${CUBEJS_API_SECRET:-$(generate_secret)}
CUBEJS_JWT_ISSUER=${CUBEJS_JWT_ISSUER:-"formbricks-web"}
CUBEJS_JWT_AUDIENCE=${CUBEJS_JWT_AUDIENCE:-"formbricks-cube"}

# Disabled features (Defaults to secure/isolated settings)
EMAIL_VERIFICATION_DISABLED=${EMAIL_VERIFICATION_DISABLED:-"1"}
PASSWORD_RESET_DISABLED=${PASSWORD_RESET_DISABLED:-"1"}
TELEMETRY_DISABLED=${TELEMETRY_DISABLED:-"1"}

# Keycloak & OIDC SSO Settings (Empty defaults)
KEYCLOAK_CLIENT_ID=${KEYCLOAK_CLIENT_ID:-""}
KEYCLOAK_CLIENT_SECRET=${KEYCLOAK_CLIENT_SECRET:-""}
KEYCLOAK_BASE_URL=${KEYCLOAK_BASE_URL:-"https://sso.vlute.edu.vn"}
KEYCLOAK_REALM=${KEYCLOAK_REALM:-"vlute"}
KEYCLOAK_REDIRECT_URI=${KEYCLOAK_REDIRECT_URI:-"http://localhost:3000/api/auth/callback/openid"}

OIDC_CLIENT_ID=${OIDC_CLIENT_ID:-""}
OIDC_CLIENT_SECRET=${OIDC_CLIENT_SECRET:-""}
OIDC_DISPLAY_NAME=${OIDC_DISPLAY_NAME:-"VLUTE SSO"}
OIDC_ISSUER=${OIDC_ISSUER:-"https://sso.vlute.edu.vn/realms/vlute"}
OIDC_SIGNING_ALGORITHM=${OIDC_SIGNING_ALGORITHM:-"RS256"}

EMAIL_AUTH_DISABLED=${EMAIL_AUTH_DISABLED:-"0"}
SSO_ADMIN_EMAILS=${SSO_ADMIN_EMAILS:-"phatnt@vlute.edu.vn"}
SSO_STAFF_DOMAIN=${SSO_STAFF_DOMAIN:-"vlute.edu.vn"}

# Student / Training API (Đào tạo)
STUDENT_API_HOST=${STUDENT_API_HOST:-"https://daotao.vlute.edu.vn"}
STUDENT_API_TOKEN=${STUDENT_API_TOKEN:-""}

# Base Path
BASE_PATH=${BASE_PATH:-"/khao-sat"}
NEXT_PUBLIC_BASE_PATH=${NEXT_PUBLIC_BASE_PATH:-$BASE_PATH}

# Firebase Configuration (defaults to KT_thong_tin_ca_nhan credentials if not provided)
FIREBASE_API_KEY=${FIREBASE_API_KEY:-"AIzaSyAfuntel3rL3Kqu7La6kqMLHZKiyTJpHBI"}
FIREBASE_AUTH_DOMAIN=${FIREBASE_AUTH_DOMAIN:-"vlute-app.firebaseapp.com"}
FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID:-"vlute-app"}
FIREBASE_STORAGE_BUCKET=${FIREBASE_STORAGE_BUCKET:-"vlute-app.firebasestorage.app"}
FIREBASE_MESSAGING_SENDER_ID=${FIREBASE_MESSAGING_SENDER_ID:-"595081063177"}
FIREBASE_APP_ID=${FIREBASE_APP_ID:-"1:595081063177:web:cd3e2767dc30f2d24581d8"}
FIREBASE_MEASUREMENT_ID=${FIREBASE_MEASUREMENT_ID:-"G-DEP0DDKV3Y"}

NEXT_PUBLIC_FIREBASE_API_KEY=${NEXT_PUBLIC_FIREBASE_API_KEY:-$FIREBASE_API_KEY}
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=${NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN:-$FIREBASE_AUTH_DOMAIN}
NEXT_PUBLIC_FIREBASE_PROJECT_ID=${NEXT_PUBLIC_FIREBASE_PROJECT_ID:-$FIREBASE_PROJECT_ID}
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=${NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET:-$FIREBASE_STORAGE_BUCKET}
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=${NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID:-$FIREBASE_MESSAGING_SENDER_ID}
NEXT_PUBLIC_FIREBASE_APP_ID=${NEXT_PUBLIC_FIREBASE_APP_ID:-$FIREBASE_APP_ID}
NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID=${NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID:-$FIREBASE_MEASUREMENT_ID}

# ----------------- Write to Temporary File -----------------
cat <<EOF > "$TEMP_ENV"
WEBAPP_URL=$WEBAPP_URL
NEXTAUTH_URL=$NEXTAUTH_URL
ENCRYPTION_KEY=$ENCRYPTION_KEY
NEXTAUTH_SECRET=$NEXTAUTH_SECRET
CRON_SECRET=$CRON_SECRET
LOG_LEVEL=$LOG_LEVEL

DATABASE_URL=$DATABASE_URL
REDIS_URL=$REDIS_URL

HUB_API_KEY=$HUB_API_KEY
HUB_API_URL=$HUB_API_URL
HUB_DATABASE_URL=$HUB_DATABASE_URL

CUBEJS_API_URL=$CUBEJS_API_URL
CUBEJS_API_SECRET=$CUBEJS_API_SECRET
CUBEJS_JWT_ISSUER=$CUBEJS_JWT_ISSUER
CUBEJS_JWT_AUDIENCE=$CUBEJS_JWT_AUDIENCE

EMAIL_VERIFICATION_DISABLED=$EMAIL_VERIFICATION_DISABLED
PASSWORD_RESET_DISABLED=$PASSWORD_RESET_DISABLED
TELEMETRY_DISABLED=$TELEMETRY_DISABLED

KEYCLOAK_CLIENT_ID=$KEYCLOAK_CLIENT_ID
KEYCLOAK_CLIENT_SECRET=$KEYCLOAK_CLIENT_SECRET
KEYCLOAK_BASE_URL=$KEYCLOAK_BASE_URL
KEYCLOAK_REALM=$KEYCLOAK_REALM
KEYCLOAK_REDIRECT_URI=$KEYCLOAK_REDIRECT_URI

OIDC_CLIENT_ID=$OIDC_CLIENT_ID
OIDC_CLIENT_SECRET=$OIDC_CLIENT_SECRET
OIDC_DISPLAY_NAME=$OIDC_DISPLAY_NAME
OIDC_ISSUER=$OIDC_ISSUER
OIDC_SIGNING_ALGORITHM=$OIDC_SIGNING_ALGORITHM

EMAIL_AUTH_DISABLED=$EMAIL_AUTH_DISABLED
SSO_ADMIN_EMAILS=$SSO_ADMIN_EMAILS
SSO_STAFF_DOMAIN=$SSO_STAFF_DOMAIN

STUDENT_API_HOST=$STUDENT_API_HOST
STUDENT_API_TOKEN=$STUDENT_API_TOKEN

BASE_PATH=$BASE_PATH
NEXT_PUBLIC_BASE_PATH=$NEXT_PUBLIC_BASE_PATH

FIREBASE_API_KEY=$FIREBASE_API_KEY
FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN
FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID
FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET
FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID
FIREBASE_APP_ID=$FIREBASE_APP_ID
FIREBASE_MEASUREMENT_ID=$FIREBASE_MEASUREMENT_ID

NEXT_PUBLIC_FIREBASE_API_KEY=$NEXT_PUBLIC_FIREBASE_API_KEY
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=$NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN
NEXT_PUBLIC_FIREBASE_PROJECT_ID=$NEXT_PUBLIC_FIREBASE_PROJECT_ID
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=$NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=$NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID
NEXT_PUBLIC_FIREBASE_APP_ID=$NEXT_PUBLIC_FIREBASE_APP_ID
NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID=$NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID
EOF

# ----------------- Launch Docker Compose -----------------
echo "Deploying Docker Compose stack using temporary environment..."

if docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
else
    echo "Error: Neither 'docker compose' nor 'docker-compose' was found on this system!" >&2
    exit 1
fi

ENV_FILE=".env.tmp" $COMPOSE_CMD -f "$SCRIPT_DIR/compose.yml" up -d

echo "----------------------------------------------------------"
echo " Success! Khaosat VLUTE services are starting."
echo " Web app is accessible at: $WEBAPP_URL"
echo "----------------------------------------------------------"

# Optional self-cleanup of installer files on the host disk
if [ "$CLEANUP_FILES" = "1" ] || [ "$1" = "--cleanup" ]; then
    echo "Cleaning up installer files (run.sh and compose.yml) from host..."
    rm -f "$SCRIPT_DIR/compose.yml"
    rm -f "$0"
    echo "Cleanup complete. Containers will continue running via docker daemon."
fi
