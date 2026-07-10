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

# ----------------- Write Cube.js Config and Schema -----------------
echo "Writing CubeJS configuration and schema files..."
mkdir -p "$SCRIPT_DIR/cube/schema"

cat <<'EOF' > "$SCRIPT_DIR/cube/cube.js"
/* eslint-env es2022 */

const TENANT_MEMBERS = ["FeedbackRecords.tenantId"];
const REQUIRED_SCOPE = "xm:cube:query";

function assertRequiredEnvironmentVariable(name) {
  const value = process.env[name];

  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`${name} is required to run Cube`);
  }
}

assertRequiredEnvironmentVariable("CUBEJS_API_SECRET");

function getStringClaim(securityContext, claim) {
  const value = securityContext?.[claim];
  if (typeof value !== "string") {
    return null;
  }

  const trimmedValue = value.trim();
  return trimmedValue.length > 0 ? trimmedValue : null;
}

function getRequiredStringClaim(securityContext, claim) {
  const value = getStringClaim(securityContext, claim);

  if (!value) {
    throw new Error(`Cube query rejected: missing ${claim} security context`);
  }

  return value;
}

function collectFilterMembers(filters) {
  if (!Array.isArray(filters)) {
    return [];
  }

  return filters.flatMap((filter) => [
    ...(typeof filter?.member === "string" ? [filter.member] : []),
    ...(typeof filter?.dimension === "string" ? [filter.dimension] : []),
    ...collectFilterMembers(filter?.and),
    ...collectFilterMembers(filter?.or),
  ]);
}

function collectOrderMembers(order) {
  if (!order) {
    return [];
  }

  if (Array.isArray(order)) {
    return order
      .map((orderEntry) => (Array.isArray(orderEntry) ? orderEntry[0] : null))
      .filter((member) => typeof member === "string");
  }

  if (typeof order === "object") {
    return Object.keys(order);
  }

  return [];
}

function collectTimeDimensionMembers(timeDimensions) {
  if (!Array.isArray(timeDimensions)) {
    return [];
  }

  return timeDimensions
    .map((timeDimension) => timeDimension?.dimension)
    .filter((dimension) => typeof dimension === "string");
}

function collectQueryMembers(query) {
  const cubeQuery = query ?? {};
  const members = [
    ...(Array.isArray(cubeQuery.measures) ? cubeQuery.measures : []),
    ...(Array.isArray(cubeQuery.dimensions) ? cubeQuery.dimensions : []),
    ...(Array.isArray(cubeQuery.segments) ? cubeQuery.segments : []),
    ...collectTimeDimensionMembers(cubeQuery.timeDimensions),
    ...collectFilterMembers(cubeQuery.filters),
    ...collectOrderMembers(cubeQuery.order),
  ].filter((member) => typeof member === "string");

  return Array.from(new Set(members)).sort((a, b) => a.localeCompare(b));
}

function assertValidSecurityContext(securityContext) {
  const tenantId = getRequiredStringClaim(securityContext, "tenantId");
  const feedbackDirectoryId = getRequiredStringClaim(securityContext, "feedbackDirectoryId");
  const workspaceId = getRequiredStringClaim(securityContext, "workspaceId");
  const scope = getRequiredStringClaim(securityContext, "scope");

  if (scope !== REQUIRED_SCOPE) {
    throw new Error("Cube query rejected: invalid Cube query scope");
  }
  if (tenantId !== feedbackDirectoryId) {
    throw new Error("Cube query rejected: tenantId/feedbackDirectoryId mismatch");
  }

  return {
    tenantId,
    feedbackDirectoryId,
    workspaceId,
    organizationId: getRequiredStringClaim(securityContext, "organizationId"),
    userId: getRequiredStringClaim(securityContext, "userId"),
    requestId: getRequiredStringClaim(securityContext, "jti"),
    source: getRequiredStringClaim(securityContext, "source"),
  };
}

function assertNoCallerTenantMember(query) {
  for (const member of collectQueryMembers(query)) {
    if (TENANT_MEMBERS.includes(member)) {
      throw new Error("Cube query rejected: tenant filters are enforced by Cube");
    }
  }
}

function logCubeQueryAuditEvent(context, query, { error, status = "success" } = {}) {
  const errorName = error instanceof Error ? error.name : undefined;
  const errorMessage = error instanceof Error ? error.message : error ? String(error) : undefined;

  console.log(
    JSON.stringify({
      type: "audit",
      event: "cube.query",
      status,
      timestamp: new Date().toISOString(),
      tenantId: context.tenantId,
      feedbackDirectoryId: context.feedbackDirectoryId,
      workspaceId: context.workspaceId,
      organizationId: context.organizationId,
      userId: context.userId,
      requestId: context.requestId,
      source: context.source,
      members: collectQueryMembers(query),
      ...(errorName ? { errorName } : {}),
      ...(errorMessage ? { errorMessage } : {}),
    })
  );
}

function logCubeQuerySecurityContextFailure(query, error) {
  console.log(
    JSON.stringify({
      type: "audit",
      event: "cube.query",
      status: "failure",
      timestamp: new Date().toISOString(),
      members: collectQueryMembers(query),
      errorName: error instanceof Error ? error.name : undefined,
      errorMessage: error instanceof Error ? error.message : String(error),
    })
  );
}

function queryRewrite(query, rewriteContext) {
  const cubeQuery = query ?? {};
  let context;

  try {
    context = assertValidSecurityContext(rewriteContext?.securityContext);
  } catch (error) {
    logCubeQuerySecurityContextFailure(cubeQuery, error);
    throw error;
  }

  try {
    assertNoCallerTenantMember(cubeQuery);
  } catch (error) {
    logCubeQueryAuditEvent(context, cubeQuery, { error, status: "failure" });
    throw error;
  }

  const queriedCubePrefixes = new Set(collectQueryMembers(cubeQuery).map((member) => member.split(".")[0]));
  const rewrittenQuery = {
    ...cubeQuery,
    filters: [
      ...(Array.isArray(cubeQuery.filters) ? cubeQuery.filters : []),
      ...TENANT_MEMBERS.filter((member) => queriedCubePrefixes.has(member.split(".")[0])).map(
        (member) => ({
          member,
          operator: "equals",
          values: [context.tenantId],
        })
      ),
    ],
  };

  logCubeQueryAuditEvent(context, rewrittenQuery);
  return rewrittenQuery;
}

module.exports = {
  queryRewrite,
};
EOF

cat <<'EOF' > "$SCRIPT_DIR/cube/schema/FeedbackRecords.js"
cube(`FeedbackRecords`, {
  sql: `SELECT * FROM feedback_records`,

  measures: {
    count: {
      type: `count`,
      description: `Total number of feedback responses`,
    },

    uniqueRespondents: {
      type: `countDistinct`,
      sql: `${CUBE}.user_id`,
      description: `Number of unique users who provided feedback`,
    },

    uniqueResponses: {
      type: `countDistinct`,
      sql: `${CUBE}.submission_id`,
      description: `Number of unique survey submissions (a submission can produce multiple feedback records)`,
    },

    promoterCount: {
      type: `count`,
      filters: [{ sql: `${CUBE}.field_type = 'nps' AND ${CUBE}.value_number >= 9` }],
      description: `Number of NPS promoters (score 9-10)`,
    },

    detractorCount: {
      type: `count`,
      filters: [{ sql: `${CUBE}.field_type = 'nps' AND ${CUBE}.value_number BETWEEN 0 AND 6` }],
      description: `Number of NPS detractors (score 0-6)`,
    },

    passiveCount: {
      type: `count`,
      filters: [{ sql: `${CUBE}.field_type = 'nps' AND ${CUBE}.value_number BETWEEN 7 AND 8` }],
      description: `Number of NPS passives (score 7-8)`,
    },

    npsScore: {
      type: `number`,
      sql: `
        CASE
          WHEN COUNT(CASE WHEN ${CUBE}.field_type = 'nps' AND ${CUBE}.value_number IS NOT NULL THEN 1 END) = 0 THEN NULL
          ELSE ROUND(
            (
              (COUNT(CASE WHEN ${CUBE}.field_type = 'nps' AND ${CUBE}.value_number >= 9 THEN 1 END)::numeric -
               COUNT(CASE WHEN ${CUBE}.field_type = 'nps' AND ${CUBE}.value_number BETWEEN 0 AND 6 THEN 1 END)::numeric)
              / COUNT(CASE WHEN ${CUBE}.field_type = 'nps' AND ${CUBE}.value_number IS NOT NULL THEN 1 END)::numeric
            ) * 100,
            2
          )
        END
      `,
      description: `Net Promoter Score: ((Promoters - Detractors) / Answered NPS responses) * 100. NULL when there are no answered NPS responses.`,
    },

    npsAverage: {
      type: `avg`,
      sql: `${CUBE}.value_number`,
      filters: [{ sql: `${CUBE}.field_type = 'nps'` }],
      description: `Average NPS rating (0-10)`,
    },

    csatCount: {
      type: `count`,
      filters: [{ sql: `${CUBE}.field_type = 'csat' AND ${CUBE}.value_number IS NOT NULL` }],
      description: `Number of answered CSAT responses (dismissed responses excluded).`,
    },

    csatSatisfiedCount: {
      type: `count`,
      filters: [{ sql: `${CUBE}.field_type = 'csat' AND ${CUBE}.value_number >= 4` }],
      description: `Number of satisfied CSAT responses (top-2-box on the 1-5 scale)`,
    },

    csatDissatisfiedCount: {
      type: `count`,
      filters: [{ sql: `${CUBE}.field_type = 'csat' AND ${CUBE}.value_number BETWEEN 1 AND 2` }],
      description: `Number of dissatisfied CSAT responses (bottom-2-box on the 1-5 scale)`,
    },

    csatNeutralCount: {
      type: `count`,
      filters: [{ sql: `${CUBE}.field_type = 'csat' AND ${CUBE}.value_number = 3` }],
      description: `Number of neutral CSAT responses (middle box on the 1-5 scale)`,
    },

    csatScore: {
      type: `number`,
      sql: `
        CASE
          WHEN COUNT(CASE WHEN ${CUBE}.field_type = 'csat' AND ${CUBE}.value_number IS NOT NULL THEN 1 END) = 0 THEN NULL
          ELSE ROUND(
            (
              COUNT(CASE WHEN ${CUBE}.field_type = 'csat' AND ${CUBE}.value_number >= 4 THEN 1 END)::numeric
              / COUNT(CASE WHEN ${CUBE}.field_type = 'csat' AND ${CUBE}.value_number IS NOT NULL THEN 1 END)::numeric
            ) * 100,
            2
          )
        END
      `,
      description: `CSAT Score: % of answered CSAT responses rated 4 or 5 (top-2-box on the 1-5 scale). NULL when there are no answered CSAT responses.`,
    },

    csatAverage: {
      type: `avg`,
      sql: `${CUBE}.value_number`,
      filters: [{ sql: `${CUBE}.field_type = 'csat'` }],
      description: `Average CSAT rating (1-5)`,
    },

    cesCount: {
      type: `count`,
      filters: [{ sql: `${CUBE}.field_type = 'ces' AND ${CUBE}.value_number IS NOT NULL` }],
      description: `Number of answered CES responses (dismissed responses excluded).`,
    },

    cesAverage: {
      type: `avg`,
      sql: `${CUBE}.value_number`,
      filters: [{ sql: `${CUBE}.field_type = 'ces'` }],
      description: `Average CES rating (scale is 1-5 or 1-7 depending on the question)`,
    },
  },

  dimensions: {
    id: {
      sql: `id`,
      type: `string`,
      primaryKey: true,
    },

    sourceType: {
      sql: `source_type`,
      type: `string`,
      description: `Source type of the feedback (e.g., nps_campaign, survey)`,
    },

    sourceName: {
      sql: `source_name`,
      type: `string`,
      description: `Human-readable name of the source`,
    },

    fieldType: {
      sql: `field_type`,
      type: `string`,
      description: `Type of feedback field (e.g., nps, text, rating)`,
    },

    fieldLabel: {
      sql: `field_label`,
      type: `string`,
      description: `Human-readable label of the question/field (e.g., "How satisfied are you with support?")`,
    },

    fieldGroupLabel: {
      sql: `field_group_label`,
      type: `string`,
      description: `Label of the parent composite question for matrix/ranking rows`,
    },

    language: {
      sql: `language`,
      type: `string`,
      description: `Response language code (e.g., "en", "de"). NULL when language is "default".`,
    },

    collectedAt: {
      sql: `collected_at`,
      type: `time`,
      description: `Timestamp when the feedback was collected`,
    },

    createdAt: {
      sql: `created_at`,
      type: `time`,
      description: `Timestamp when the feedback record was created in Hub`,
    },

    updatedAt: {
      sql: `updated_at`,
      type: `time`,
      description: `Timestamp when the feedback record was last updated in Hub`,
    },

    valueNumber: {
      sql: `value_number`,
      type: `number`,
      description: `Numeric answer value (NPS 0-10, CSAT 1-5, CES 1-5 or 1-7, rating, generic number). Pair with a fieldType filter to keep scales consistent.`,
    },

    valueText: {
      sql: `value_text`,
      type: `string`,
      description: `Text answer value (open text, or the label of a multiple-choice / categorical answer). Pair with a fieldType filter to keep types consistent.`,
    },

    valueBoolean: {
      sql: `value_boolean`,
      type: `boolean`,
      description: `Boolean answer value (yes/no questions). Pair with a fieldType filter.`,
    },

    valueDate: {
      sql: `value_date`,
      type: `time`,
      description: `Date answer value (e.g., "preferred meeting date"). Pair with a fieldType filter.`,
    },

    responseId: {
      sql: `submission_id`,
      type: `string`,
      description: `Unique identifier linking related feedback records (submission_id in Hub)`,
    },

    userId: {
      sql: `user_id`,
      type: `string`,
      description: `Identifier of the user who provided feedback`,
    },

    tenantId: {
      sql: `tenant_id`,
      type: `string`,
      description: `Tenant ID linking to FeedbackDirectory`,
    },
  },
});
EOF

# ----------------- Launch Docker Compose -----------------
echo "Deploying Docker Compose stack using temporary environment..."

sudo ENV_FILE=".env.tmp" docker compose up -d

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
