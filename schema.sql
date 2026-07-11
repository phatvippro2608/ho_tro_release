-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateExtension
CREATE EXTENSION IF NOT EXISTS "vector";

-- CreateEnum
CREATE TYPE "PipelineTriggers" AS ENUM ('responseCreated', 'responseUpdated', 'responseFinished');

-- CreateEnum
CREATE TYPE "WebhookSource" AS ENUM ('user', 'zapier', 'make', 'n8n', 'activepieces');

-- CreateEnum
CREATE TYPE "ContactAttributeType" AS ENUM ('default', 'custom');

-- CreateEnum
CREATE TYPE "ContactAttributeDataType" AS ENUM ('string', 'number', 'date');

-- CreateEnum
CREATE TYPE "SurveyStatus" AS ENUM ('draft', 'inProgress', 'paused', 'completed');

-- CreateEnum
CREATE TYPE "SurveyAttributeFilterCondition" AS ENUM ('equals', 'notEquals');

-- CreateEnum
CREATE TYPE "SurveyQuotaAction" AS ENUM ('endSurvey', 'continueSurvey');

-- CreateEnum
CREATE TYPE "ResponseQuotaLinkStatus" AS ENUM ('screenedIn', 'screenedOut');

-- CreateEnum
CREATE TYPE "SurveyType" AS ENUM ('link', 'app');

-- CreateEnum
CREATE TYPE "displayOptions" AS ENUM ('displayOnce', 'displayMultiple', 'displaySome', 'respondMultiple');

-- CreateEnum
CREATE TYPE "SurveyScriptMode" AS ENUM ('add', 'replace');

-- CreateEnum
CREATE TYPE "ActionType" AS ENUM ('code', 'noCode');

-- CreateEnum
CREATE TYPE "IntegrationType" AS ENUM ('googleSheets', 'notion', 'airtable', 'slack');

-- CreateEnum
CREATE TYPE "DataMigrationStatus" AS ENUM ('pending', 'applied', 'failed');

-- CreateEnum
CREATE TYPE "WidgetPlacement" AS ENUM ('bottomLeft', 'bottomRight', 'topLeft', 'topRight', 'center');

-- CreateEnum
CREATE TYPE "SurveyOverlay" AS ENUM ('none', 'light', 'dark');

-- CreateEnum
CREATE TYPE "OrganizationRole" AS ENUM ('owner', 'manager', 'member', 'billing');

-- CreateEnum
CREATE TYPE "ApiKeyPermission" AS ENUM ('read', 'write', 'manage');

-- CreateEnum
CREATE TYPE "IdentityProvider" AS ENUM ('email', 'github', 'google', 'azuread', 'openid', 'saml');

-- CreateEnum
CREATE TYPE "TeamUserRole" AS ENUM ('admin', 'contributor');

-- CreateEnum
CREATE TYPE "WorkspaceTeamPermission" AS ENUM ('read', 'readWrite', 'manage');

-- CreateEnum
CREATE TYPE "ChartType" AS ENUM ('area', 'bar', 'line', 'pie', 'big_number');

-- CreateEnum
CREATE TYPE "FeedbackSourceType" AS ENUM ('formbricks_survey', 'csv');

-- CreateEnum
CREATE TYPE "FeedbackSourceStatus" AS ENUM ('active', 'paused', 'error');

-- CreateEnum
CREATE TYPE "HubFieldType" AS ENUM ('text', 'categorical', 'nps', 'csat', 'ces', 'rating', 'number', 'boolean', 'date');

-- CreateTable
CREATE TABLE "Webhook" (
    "id" TEXT NOT NULL,
    "name" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "url" TEXT NOT NULL,
    "source" "WebhookSource" NOT NULL DEFAULT 'user',
    "workspaceId" TEXT NOT NULL,
    "triggers" "PipelineTriggers"[],
    "surveyIds" TEXT[],
    "secret" TEXT,

    CONSTRAINT "Webhook_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContactAttribute" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "attributeKeyId" TEXT NOT NULL,
    "contactId" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "valueNumber" DOUBLE PRECISION,
    "valueDate" TIMESTAMP(3),

    CONSTRAINT "ContactAttribute_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContactAttributeKey" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "isUnique" BOOLEAN NOT NULL DEFAULT false,
    "key" TEXT NOT NULL,
    "name" TEXT,
    "description" TEXT,
    "type" "ContactAttributeType" NOT NULL DEFAULT 'custom',
    "dataType" "ContactAttributeDataType" NOT NULL DEFAULT 'string',
    "workspaceId" TEXT NOT NULL,

    CONSTRAINT "ContactAttributeKey_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Contact" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "workspaceId" TEXT NOT NULL,

    CONSTRAINT "Contact_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Response" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finished" BOOLEAN NOT NULL DEFAULT false,
    "surveyId" TEXT NOT NULL,
    "contactId" TEXT,
    "endingId" TEXT,
    "data" JSONB NOT NULL DEFAULT '{}',
    "variables" JSONB NOT NULL DEFAULT '{}',
    "ttc" JSONB NOT NULL DEFAULT '{}',
    "meta" JSONB NOT NULL DEFAULT '{}',
    "contactAttributes" JSONB,
    "singleUseId" TEXT,
    "language" TEXT,
    "displayId" TEXT,

    CONSTRAINT "Response_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Tag" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,
    "workspaceId" TEXT NOT NULL,

    CONSTRAINT "Tag_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TagsOnResponses" (
    "responseId" TEXT NOT NULL,
    "tagId" TEXT NOT NULL,

    CONSTRAINT "TagsOnResponses_pkey" PRIMARY KEY ("responseId","tagId")
);

-- CreateTable
CREATE TABLE "Display" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "surveyId" TEXT NOT NULL,
    "contactId" TEXT,

    CONSTRAINT "Display_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SurveyTrigger" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "surveyId" TEXT NOT NULL,
    "actionClassId" TEXT NOT NULL,

    CONSTRAINT "SurveyTrigger_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SurveyAttributeFilter" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "attributeKeyId" TEXT NOT NULL,
    "surveyId" TEXT NOT NULL,
    "condition" "SurveyAttributeFilterCondition" NOT NULL,
    "value" TEXT NOT NULL,

    CONSTRAINT "SurveyAttributeFilter_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Survey" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,
    "redirectUrl" TEXT,
    "type" "SurveyType" NOT NULL DEFAULT 'app',
    "workspaceId" TEXT NOT NULL,
    "createdBy" TEXT,
    "status" "SurveyStatus" NOT NULL DEFAULT 'draft',
    "welcomeCard" JSONB NOT NULL DEFAULT '{"enabled": false}',
    "questions" JSONB NOT NULL DEFAULT '[]',
    "blocks" JSONB[] DEFAULT ARRAY[]::JSONB[],
    "endings" JSONB[] DEFAULT ARRAY[]::JSONB[],
    "hiddenFields" JSONB NOT NULL DEFAULT '{"enabled": false}',
    "variables" JSONB NOT NULL DEFAULT '[]',
    "displayOption" "displayOptions" NOT NULL DEFAULT 'displayOnce',
    "recontactDays" INTEGER,
    "displayLimit" INTEGER,
    "inlineTriggers" JSONB,
    "autoClose" INTEGER,
    "autoComplete" INTEGER,
    "delay" INTEGER NOT NULL DEFAULT 0,
    "publishOn" TIMESTAMP(3),
    "closeOn" TIMESTAMP(3),
    "surveyClosedMessage" JSONB,
    "segmentId" TEXT,
    "academicSemesterId" TEXT,
    "workspaceOverwrites" JSONB,
    "styling" JSONB,
    "singleUse" JSONB DEFAULT '{"enabled": false, "isEncrypted": true}',
    "isVerifyEmailEnabled" BOOLEAN NOT NULL DEFAULT false,
    "isSingleResponsePerEmailEnabled" BOOLEAN NOT NULL DEFAULT false,
    "isBackButtonHidden" BOOLEAN NOT NULL DEFAULT false,
    "isAutoProgressingEnabled" BOOLEAN NOT NULL DEFAULT false,
    "isCaptureIpEnabled" BOOLEAN NOT NULL DEFAULT false,
    "isLocked" BOOLEAN NOT NULL DEFAULT false,
    "pin" TEXT,
    "displayPercentage" DECIMAL(65,30),
    "showLanguageSwitch" BOOLEAN,
    "recaptcha" JSONB DEFAULT '{"enabled": false, "threshold":0.1}',
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "slug" TEXT,
    "customHeadScripts" TEXT,
    "customHeadScriptsMode" "SurveyScriptMode" DEFAULT 'add',

    CONSTRAINT "Survey_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SurveyQuota" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "surveyId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "limit" INTEGER NOT NULL,
    "logic" JSONB NOT NULL DEFAULT '{}',
    "action" "SurveyQuotaAction" NOT NULL,
    "endingCardId" TEXT,
    "countPartialSubmissions" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "SurveyQuota_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ResponseQuotaLink" (
    "responseId" TEXT NOT NULL,
    "quotaId" TEXT NOT NULL,
    "status" "ResponseQuotaLinkStatus" NOT NULL,

    CONSTRAINT "ResponseQuotaLink_pkey" PRIMARY KEY ("responseId","quotaId")
);

-- CreateTable
CREATE TABLE "SurveyFollowUp" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "surveyId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "trigger" JSONB NOT NULL,
    "action" JSONB NOT NULL,

    CONSTRAINT "SurveyFollowUp_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ActionClass" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "type" "ActionType" NOT NULL,
    "key" TEXT,
    "noCodeConfig" JSONB,
    "workspaceId" TEXT NOT NULL,

    CONSTRAINT "ActionClass_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Integration" (
    "id" TEXT NOT NULL,
    "type" "IntegrationType" NOT NULL,
    "config" JSONB NOT NULL,
    "workspaceId" TEXT NOT NULL,

    CONSTRAINT "Integration_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DataMigration" (
    "id" TEXT NOT NULL,
    "started_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finished_at" TIMESTAMP(3),
    "name" TEXT NOT NULL,
    "status" "DataMigrationStatus" NOT NULL,

    CONSTRAINT "DataMigration_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Workspace" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,
    "legacyEnvironmentId" TEXT,
    "organizationId" TEXT NOT NULL,
    "styling" JSONB NOT NULL DEFAULT '{"allowStyleOverwrite":true}',
    "config" JSONB NOT NULL DEFAULT '{}',
    "recontactDays" INTEGER NOT NULL DEFAULT 7,
    "linkSurveyBranding" BOOLEAN NOT NULL DEFAULT true,
    "inAppSurveyBranding" BOOLEAN NOT NULL DEFAULT true,
    "placement" "WidgetPlacement" NOT NULL DEFAULT 'bottomRight',
    "clickOutsideClose" BOOLEAN NOT NULL DEFAULT true,
    "overlay" "SurveyOverlay" NOT NULL DEFAULT 'none',
    "logo" JSONB,
    "appSetupCompleted" BOOLEAN NOT NULL DEFAULT false,
    "customHeadScripts" TEXT,

    CONSTRAINT "Workspace_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Organization" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,
    "whitelabel" JSONB NOT NULL DEFAULT '{}',
    "isAISmartToolsEnabled" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "Organization_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OrganizationBilling" (
    "organization_id" TEXT NOT NULL,
    "stripe_customer_id" TEXT,
    "limits" JSONB NOT NULL,
    "usage_cycle_anchor" TIMESTAMP(3),
    "stripe" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OrganizationBilling_pkey" PRIMARY KEY ("organization_id")
);

-- CreateTable
CREATE TABLE "Membership" (
    "organizationId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "accepted" BOOLEAN NOT NULL DEFAULT false,
    "role" "OrganizationRole" NOT NULL DEFAULT 'member',

    CONSTRAINT "Membership_pkey" PRIMARY KEY ("userId","organizationId")
);

-- CreateTable
CREATE TABLE "Invite" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT,
    "organizationId" TEXT NOT NULL,
    "creatorId" TEXT NOT NULL,
    "acceptorId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "role" "OrganizationRole" NOT NULL DEFAULT 'member',
    "teamIds" TEXT[] DEFAULT ARRAY[]::TEXT[],

    CONSTRAINT "Invite_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ApiKey" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdBy" TEXT,
    "lastUsedAt" TIMESTAMP(3),
    "label" TEXT NOT NULL,
    "hashedKey" TEXT NOT NULL,
    "lookupHash" TEXT,
    "organizationId" TEXT NOT NULL,
    "organizationAccess" JSONB NOT NULL DEFAULT '{}',

    CONSTRAINT "ApiKey_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ApiKeyWorkspace" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "apiKeyId" TEXT NOT NULL,
    "workspaceId" TEXT NOT NULL,
    "permission" "ApiKeyPermission" NOT NULL,

    CONSTRAINT "ApiKeyWorkspace_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Account" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT,
    "provider" TEXT NOT NULL,
    "providerAccountId" TEXT NOT NULL,
    "access_token" TEXT,
    "refresh_token" TEXT,
    "expires_at" INTEGER,
    "ext_expires_in" INTEGER,
    "token_type" TEXT,
    "scope" TEXT,
    "id_token" TEXT,
    "session_state" TEXT,
    "password" TEXT,
    "accessTokenExpiresAt" TIMESTAMP(3),
    "refreshTokenExpiresAt" TIMESTAMP(3),

    CONSTRAINT "Account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Session" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "sessionToken" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "expires" TIMESTAMP(3) NOT NULL,
    "ipAddress" TEXT,
    "userAgent" TEXT,

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "VerificationToken" (
    "identifier" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "expires" TIMESTAMP(3) NOT NULL
);

-- CreateTable
CREATE TABLE "TwoFactor" (
    "id" TEXT NOT NULL,
    "secret" TEXT NOT NULL,
    "backupCodes" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "verified" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "TwoFactor_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "jwks" (
    "id" TEXT NOT NULL,
    "publicKey" TEXT NOT NULL,
    "privateKey" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL,
    "expiresAt" TIMESTAMP(3),

    CONSTRAINT "jwks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "oauthClient" (
    "id" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "clientSecret" TEXT,
    "disabled" BOOLEAN DEFAULT false,
    "skipConsent" BOOLEAN,
    "enableEndSession" BOOLEAN,
    "subjectType" TEXT,
    "scopes" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "userId" TEXT,
    "createdAt" TIMESTAMP(3),
    "updatedAt" TIMESTAMP(3),
    "name" TEXT,
    "uri" TEXT,
    "icon" TEXT,
    "contacts" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "tos" TEXT,
    "policy" TEXT,
    "softwareId" TEXT,
    "softwareVersion" TEXT,
    "softwareStatement" TEXT,
    "redirectUris" TEXT[],
    "postLogoutRedirectUris" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "tokenEndpointAuthMethod" TEXT,
    "grantTypes" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "responseTypes" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "public" BOOLEAN,
    "type" TEXT,
    "requirePKCE" BOOLEAN,
    "referenceId" TEXT,
    "metadata" JSONB,

    CONSTRAINT "oauthClient_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "oauthAccessToken" (
    "id" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "sessionId" TEXT,
    "userId" TEXT,
    "referenceId" TEXT,
    "refreshId" TEXT,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL,
    "scopes" TEXT[],

    CONSTRAINT "oauthAccessToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "oauthRefreshToken" (
    "id" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "sessionId" TEXT,
    "userId" TEXT NOT NULL,
    "referenceId" TEXT,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL,
    "revoked" TIMESTAMP(3),
    "authTime" TIMESTAMP(3),
    "scopes" TEXT[],

    CONSTRAINT "oauthRefreshToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "oauthConsent" (
    "id" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "userId" TEXT,
    "referenceId" TEXT,
    "scopes" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "oauthConsent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PasswordResetToken" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "token_hash" TEXT NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "userId" TEXT NOT NULL,

    CONSTRAINT "PasswordResetToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "email_verified" BOOLEAN NOT NULL DEFAULT false,
    "twoFactorSecret" TEXT,
    "twoFactorEnabled" BOOLEAN NOT NULL DEFAULT false,
    "backupCodes" TEXT,
    "password" TEXT,
    "identityProvider" "IdentityProvider" NOT NULL DEFAULT 'email',
    "identityProviderAccountId" TEXT,
    "groupId" TEXT,
    "notificationSettings" JSONB NOT NULL DEFAULT '{}',
    "locale" TEXT NOT NULL DEFAULT 'en-US',
    "lastLoginAt" TIMESTAMP(3),
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Segment" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "isPrivate" BOOLEAN NOT NULL DEFAULT true,
    "filters" JSONB NOT NULL DEFAULT '[]',
    "workspaceId" TEXT NOT NULL,

    CONSTRAINT "Segment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Language" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "code" TEXT NOT NULL,
    "alias" TEXT,
    "workspaceId" TEXT NOT NULL,

    CONSTRAINT "Language_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SurveyLanguage" (
    "languageId" TEXT NOT NULL,
    "surveyId" TEXT NOT NULL,
    "default" BOOLEAN NOT NULL DEFAULT false,
    "enabled" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "SurveyLanguage_pkey" PRIMARY KEY ("languageId","surveyId")
);

-- CreateTable
CREATE TABLE "Team" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,
    "organizationId" TEXT NOT NULL,

    CONSTRAINT "Team_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TeamUser" (
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "teamId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "role" "TeamUserRole" NOT NULL,

    CONSTRAINT "TeamUser_pkey" PRIMARY KEY ("teamId","userId")
);

-- CreateTable
CREATE TABLE "WorkspaceTeam" (
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "workspaceId" TEXT NOT NULL,
    "teamId" TEXT NOT NULL,
    "permission" "WorkspaceTeamPermission" NOT NULL DEFAULT 'read',

    CONSTRAINT "WorkspaceTeam_pkey" PRIMARY KEY ("workspaceId","teamId")
);

-- CreateTable
CREATE TABLE "Chart" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,
    "type" "ChartType" NOT NULL,
    "workspaceId" TEXT NOT NULL,
    "query" JSONB NOT NULL DEFAULT '{}',
    "config" JSONB NOT NULL DEFAULT '{}',
    "createdBy" TEXT,
    "feedbackDirectoryId" TEXT NOT NULL,

    CONSTRAINT "Chart_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Dashboard" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,
    "workspaceId" TEXT NOT NULL,
    "createdBy" TEXT,

    CONSTRAINT "Dashboard_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DashboardWidget" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "dashboardId" TEXT NOT NULL,
    "chartId" TEXT NOT NULL,
    "layout" JSONB NOT NULL DEFAULT '{"x":0,"y":0,"w":4,"h":3}',
    "order" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "DashboardWidget_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FeedbackSource" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,
    "type" "FeedbackSourceType" NOT NULL,
    "status" "FeedbackSourceStatus" NOT NULL DEFAULT 'active',
    "workspaceId" TEXT NOT NULL,
    "feedbackDirectoryId" TEXT NOT NULL,
    "last_sync_at" TIMESTAMP(3),
    "created_by" TEXT,

    CONSTRAINT "FeedbackSource_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FeedbackSourceFormbricksMapping" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "feedback_source_id" TEXT NOT NULL,
    "workspaceId" TEXT NOT NULL,
    "surveyId" TEXT NOT NULL,
    "elementId" TEXT NOT NULL,
    "hubFieldType" "HubFieldType" NOT NULL,
    "custom_field_label" TEXT,

    CONSTRAINT "FeedbackSourceFormbricksMapping_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FeedbackSourceFieldMapping" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "feedback_source_id" TEXT NOT NULL,
    "workspaceId" TEXT NOT NULL,
    "source_field_id" TEXT NOT NULL,
    "target_field_id" TEXT NOT NULL,
    "static_value" TEXT,

    CONSTRAINT "FeedbackSourceFieldMapping_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FeedbackDirectory" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,
    "isArchived" BOOLEAN NOT NULL DEFAULT false,
    "organizationId" TEXT NOT NULL,

    CONSTRAINT "FeedbackDirectory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FeedbackDirectoryWorkspace" (
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "feedbackDirectoryId" TEXT NOT NULL,
    "workspaceId" TEXT NOT NULL,

    CONSTRAINT "FeedbackDirectoryWorkspace_pkey" PRIMARY KEY ("feedbackDirectoryId","workspaceId")
);

-- CreateTable
CREATE TABLE "AcademicSemester" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "id_hocky_namhoc" TEXT NOT NULL,
    "ten_hoc_ky" TEXT NOT NULL,
    "ten_nam_hoc" TEXT NOT NULL,
    "thoi_gian_bd_hk" TIMESTAMP(3) NOT NULL,
    "thoi_gian_kt_hk" TIMESTAMP(3) NOT NULL,
    "workspaceId" TEXT NOT NULL,

    CONSTRAINT "AcademicSemester_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudentSurveyTarget" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "academicSemesterId" TEXT NOT NULL,
    "mssv" TEXT NOT NULL,
    "ho_ten" TEXT NOT NULL,
    "hoc_phan" TEXT NOT NULL,
    "ma_hoc_phan" TEXT NOT NULL DEFAULT '',
    "ma_lop_hp" TEXT NOT NULL,
    "ho_ten_gv" TEXT NOT NULL,
    "diem_he_4" DOUBLE PRECISION,
    "diem_he_10" DOUBLE PRECISION,
    "diem_chu" TEXT,

    CONSTRAINT "StudentSurveyTarget_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TargetGroup" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "key" TEXT,
    "workspaceId" TEXT,
    "emails" TEXT NOT NULL DEFAULT '',

    CONSTRAINT "TargetGroup_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "_SurveyToTargetGroup" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_SurveyToTargetGroup_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateIndex
CREATE INDEX "Webhook_workspaceId_idx" ON "Webhook"("workspaceId");

-- CreateIndex
CREATE INDEX "ContactAttribute_attributeKeyId_value_idx" ON "ContactAttribute"("attributeKeyId", "value");

-- CreateIndex
CREATE INDEX "ContactAttribute_attributeKeyId_valueNumber_idx" ON "ContactAttribute"("attributeKeyId", "valueNumber");

-- CreateIndex
CREATE INDEX "ContactAttribute_attributeKeyId_valueDate_idx" ON "ContactAttribute"("attributeKeyId", "valueDate");

-- CreateIndex
CREATE UNIQUE INDEX "ContactAttribute_contactId_attributeKeyId_key" ON "ContactAttribute"("contactId", "attributeKeyId");

-- CreateIndex
CREATE INDEX "ContactAttributeKey_workspaceId_created_at_idx" ON "ContactAttributeKey"("workspaceId", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "ContactAttributeKey_key_workspaceId_key" ON "ContactAttributeKey"("key", "workspaceId");

-- CreateIndex
CREATE INDEX "Contact_workspaceId_idx" ON "Contact"("workspaceId");

-- CreateIndex
CREATE UNIQUE INDEX "Response_displayId_key" ON "Response"("displayId");

-- CreateIndex
CREATE INDEX "Response_created_at_idx" ON "Response"("created_at");

-- CreateIndex
CREATE INDEX "Response_surveyId_created_at_idx" ON "Response"("surveyId", "created_at");

-- CreateIndex
CREATE INDEX "Response_contactId_created_at_idx" ON "Response"("contactId", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "Response_surveyId_singleUseId_key" ON "Response"("surveyId", "singleUseId");

-- CreateIndex
CREATE INDEX "Tag_workspaceId_idx" ON "Tag"("workspaceId");

-- CreateIndex
CREATE UNIQUE INDEX "Tag_workspaceId_name_key" ON "Tag"("workspaceId", "name");

-- CreateIndex
CREATE INDEX "Display_surveyId_idx" ON "Display"("surveyId");

-- CreateIndex
CREATE INDEX "Display_contactId_created_at_idx" ON "Display"("contactId", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "SurveyTrigger_surveyId_actionClassId_key" ON "SurveyTrigger"("surveyId", "actionClassId");

-- CreateIndex
CREATE INDEX "SurveyAttributeFilter_attributeKeyId_idx" ON "SurveyAttributeFilter"("attributeKeyId");

-- CreateIndex
CREATE UNIQUE INDEX "SurveyAttributeFilter_surveyId_attributeKeyId_key" ON "SurveyAttributeFilter"("surveyId", "attributeKeyId");

-- CreateIndex
CREATE UNIQUE INDEX "Survey_slug_key" ON "Survey"("slug");

-- CreateIndex
CREATE INDEX "Survey_workspaceId_updated_at_idx" ON "Survey"("workspaceId", "updated_at");

-- CreateIndex
CREATE INDEX "Survey_segmentId_idx" ON "Survey"("segmentId");

-- CreateIndex
CREATE INDEX "Survey_status_publishOn_idx" ON "Survey"("status", "publishOn");

-- CreateIndex
CREATE INDEX "Survey_status_closeOn_idx" ON "Survey"("status", "closeOn");

-- CreateIndex
CREATE UNIQUE INDEX "Survey_id_workspaceId_key" ON "Survey"("id", "workspaceId");

-- CreateIndex
CREATE UNIQUE INDEX "SurveyQuota_surveyId_name_key" ON "SurveyQuota"("surveyId", "name");

-- CreateIndex
CREATE INDEX "ResponseQuotaLink_quotaId_status_idx" ON "ResponseQuotaLink"("quotaId", "status");

-- CreateIndex
CREATE INDEX "ActionClass_workspaceId_created_at_idx" ON "ActionClass"("workspaceId", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "ActionClass_key_workspaceId_key" ON "ActionClass"("key", "workspaceId");

-- CreateIndex
CREATE UNIQUE INDEX "ActionClass_name_workspaceId_key" ON "ActionClass"("name", "workspaceId");

-- CreateIndex
CREATE INDEX "Integration_workspaceId_idx" ON "Integration"("workspaceId");

-- CreateIndex
CREATE UNIQUE INDEX "Integration_type_workspaceId_key" ON "Integration"("type", "workspaceId");

-- CreateIndex
CREATE UNIQUE INDEX "DataMigration_name_key" ON "DataMigration"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Workspace_legacyEnvironmentId_key" ON "Workspace"("legacyEnvironmentId");

-- CreateIndex
CREATE UNIQUE INDEX "Workspace_organizationId_name_key" ON "Workspace"("organizationId", "name");

-- CreateIndex
CREATE UNIQUE INDEX "OrganizationBilling_stripe_customer_id_key" ON "OrganizationBilling"("stripe_customer_id");

-- CreateIndex
CREATE INDEX "Membership_organizationId_idx" ON "Membership"("organizationId");

-- CreateIndex
CREATE INDEX "Invite_email_organizationId_idx" ON "Invite"("email", "organizationId");

-- CreateIndex
CREATE INDEX "Invite_organizationId_idx" ON "Invite"("organizationId");

-- CreateIndex
CREATE UNIQUE INDEX "ApiKey_lookupHash_key" ON "ApiKey"("lookupHash");

-- CreateIndex
CREATE INDEX "ApiKey_organizationId_idx" ON "ApiKey"("organizationId");

-- CreateIndex
CREATE INDEX "ApiKeyWorkspace_workspaceId_idx" ON "ApiKeyWorkspace"("workspaceId");

-- CreateIndex
CREATE UNIQUE INDEX "ApiKeyWorkspace_apiKeyId_workspaceId_key" ON "ApiKeyWorkspace"("apiKeyId", "workspaceId");

-- CreateIndex
CREATE INDEX "Account_userId_idx" ON "Account"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "Account_provider_providerAccountId_key" ON "Account"("provider", "providerAccountId");

-- CreateIndex
CREATE UNIQUE INDEX "Session_sessionToken_key" ON "Session"("sessionToken");

-- CreateIndex
CREATE INDEX "Session_userId_idx" ON "Session"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "VerificationToken_identifier_token_key" ON "VerificationToken"("identifier", "token");

-- CreateIndex
CREATE UNIQUE INDEX "TwoFactor_userId_key" ON "TwoFactor"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "oauthClient_clientId_key" ON "oauthClient"("clientId");

-- CreateIndex
CREATE INDEX "oauthClient_userId_idx" ON "oauthClient"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "oauthAccessToken_token_key" ON "oauthAccessToken"("token");

-- CreateIndex
CREATE INDEX "oauthAccessToken_clientId_idx" ON "oauthAccessToken"("clientId");

-- CreateIndex
CREATE INDEX "oauthAccessToken_sessionId_idx" ON "oauthAccessToken"("sessionId");

-- CreateIndex
CREATE INDEX "oauthAccessToken_userId_idx" ON "oauthAccessToken"("userId");

-- CreateIndex
CREATE INDEX "oauthAccessToken_refreshId_idx" ON "oauthAccessToken"("refreshId");

-- CreateIndex
CREATE UNIQUE INDEX "oauthRefreshToken_token_key" ON "oauthRefreshToken"("token");

-- CreateIndex
CREATE INDEX "oauthRefreshToken_clientId_idx" ON "oauthRefreshToken"("clientId");

-- CreateIndex
CREATE INDEX "oauthRefreshToken_sessionId_idx" ON "oauthRefreshToken"("sessionId");

-- CreateIndex
CREATE INDEX "oauthRefreshToken_userId_idx" ON "oauthRefreshToken"("userId");

-- CreateIndex
CREATE INDEX "oauthConsent_clientId_idx" ON "oauthConsent"("clientId");

-- CreateIndex
CREATE INDEX "oauthConsent_userId_idx" ON "oauthConsent"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "PasswordResetToken_token_hash_key" ON "PasswordResetToken"("token_hash");

-- CreateIndex
CREATE UNIQUE INDEX "PasswordResetToken_userId_key" ON "PasswordResetToken"("userId");

-- CreateIndex
CREATE INDEX "PasswordResetToken_expires_at_idx" ON "PasswordResetToken"("expires_at");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "Segment_workspaceId_idx" ON "Segment"("workspaceId");

-- CreateIndex
CREATE UNIQUE INDEX "Segment_workspaceId_title_key" ON "Segment"("workspaceId", "title");

-- CreateIndex
CREATE UNIQUE INDEX "Language_workspaceId_code_key" ON "Language"("workspaceId", "code");

-- CreateIndex
CREATE INDEX "SurveyLanguage_surveyId_idx" ON "SurveyLanguage"("surveyId");

-- CreateIndex
CREATE UNIQUE INDEX "Team_organizationId_name_key" ON "Team"("organizationId", "name");

-- CreateIndex
CREATE INDEX "TeamUser_userId_idx" ON "TeamUser"("userId");

-- CreateIndex
CREATE INDEX "WorkspaceTeam_teamId_idx" ON "WorkspaceTeam"("teamId");

-- CreateIndex
CREATE INDEX "Chart_workspaceId_created_at_idx" ON "Chart"("workspaceId", "created_at");

-- CreateIndex
CREATE INDEX "Chart_feedbackDirectoryId_idx" ON "Chart"("feedbackDirectoryId");

-- CreateIndex
CREATE UNIQUE INDEX "Chart_workspaceId_name_key" ON "Chart"("workspaceId", "name");

-- CreateIndex
CREATE INDEX "Dashboard_workspaceId_created_at_idx" ON "Dashboard"("workspaceId", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "Dashboard_workspaceId_name_key" ON "Dashboard"("workspaceId", "name");

-- CreateIndex
CREATE INDEX "DashboardWidget_dashboardId_order_idx" ON "DashboardWidget"("dashboardId", "order");

-- CreateIndex
CREATE UNIQUE INDEX "DashboardWidget_dashboardId_chartId_key" ON "DashboardWidget"("dashboardId", "chartId");

-- CreateIndex
CREATE INDEX "FeedbackSource_type_idx" ON "FeedbackSource"("type");

-- CreateIndex
CREATE INDEX "FeedbackSource_feedbackDirectoryId_idx" ON "FeedbackSource"("feedbackDirectoryId");

-- CreateIndex
CREATE UNIQUE INDEX "FeedbackSource_id_workspaceId_key" ON "FeedbackSource"("id", "workspaceId");

-- CreateIndex
CREATE UNIQUE INDEX "FeedbackSource_workspaceId_name_key" ON "FeedbackSource"("workspaceId", "name");

-- CreateIndex
CREATE INDEX "FeedbackSourceFormbricksMapping_workspaceId_surveyId_idx" ON "FeedbackSourceFormbricksMapping"("workspaceId", "surveyId");

-- CreateIndex
CREATE INDEX "FeedbackSourceFormbricksMapping_surveyId_idx" ON "FeedbackSourceFormbricksMapping"("surveyId");

-- CreateIndex
CREATE UNIQUE INDEX "FeedbackSourceFormbricksMapping_workspaceId_feedback_source_key" ON "FeedbackSourceFormbricksMapping"("workspaceId", "feedback_source_id", "surveyId", "elementId");

-- CreateIndex
CREATE UNIQUE INDEX "FeedbackSourceFieldMapping_workspaceId_feedback_source_id_s_key" ON "FeedbackSourceFieldMapping"("workspaceId", "feedback_source_id", "source_field_id", "target_field_id");

-- CreateIndex
CREATE UNIQUE INDEX "FeedbackDirectory_organizationId_name_key" ON "FeedbackDirectory"("organizationId", "name");

-- CreateIndex
CREATE INDEX "FeedbackDirectoryWorkspace_workspaceId_idx" ON "FeedbackDirectoryWorkspace"("workspaceId");

-- CreateIndex
CREATE UNIQUE INDEX "AcademicSemester_id_hocky_namhoc_key" ON "AcademicSemester"("id_hocky_namhoc");

-- CreateIndex
CREATE INDEX "AcademicSemester_workspaceId_idx" ON "AcademicSemester"("workspaceId");

-- CreateIndex
CREATE INDEX "StudentSurveyTarget_academicSemesterId_idx" ON "StudentSurveyTarget"("academicSemesterId");

-- CreateIndex
CREATE INDEX "StudentSurveyTarget_mssv_idx" ON "StudentSurveyTarget"("mssv");

-- CreateIndex
CREATE INDEX "TargetGroup_workspaceId_idx" ON "TargetGroup"("workspaceId");

-- CreateIndex
CREATE INDEX "_SurveyToTargetGroup_B_index" ON "_SurveyToTargetGroup"("B");

-- AddForeignKey
ALTER TABLE "Webhook" ADD CONSTRAINT "Webhook_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContactAttribute" ADD CONSTRAINT "ContactAttribute_attributeKeyId_fkey" FOREIGN KEY ("attributeKeyId") REFERENCES "ContactAttributeKey"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContactAttribute" ADD CONSTRAINT "ContactAttribute_contactId_fkey" FOREIGN KEY ("contactId") REFERENCES "Contact"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContactAttributeKey" ADD CONSTRAINT "ContactAttributeKey_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contact" ADD CONSTRAINT "Contact_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Response" ADD CONSTRAINT "Response_surveyId_fkey" FOREIGN KEY ("surveyId") REFERENCES "Survey"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Response" ADD CONSTRAINT "Response_contactId_fkey" FOREIGN KEY ("contactId") REFERENCES "Contact"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Response" ADD CONSTRAINT "Response_displayId_fkey" FOREIGN KEY ("displayId") REFERENCES "Display"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Tag" ADD CONSTRAINT "Tag_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TagsOnResponses" ADD CONSTRAINT "TagsOnResponses_responseId_fkey" FOREIGN KEY ("responseId") REFERENCES "Response"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TagsOnResponses" ADD CONSTRAINT "TagsOnResponses_tagId_fkey" FOREIGN KEY ("tagId") REFERENCES "Tag"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Display" ADD CONSTRAINT "Display_surveyId_fkey" FOREIGN KEY ("surveyId") REFERENCES "Survey"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Display" ADD CONSTRAINT "Display_contactId_fkey" FOREIGN KEY ("contactId") REFERENCES "Contact"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SurveyTrigger" ADD CONSTRAINT "SurveyTrigger_surveyId_fkey" FOREIGN KEY ("surveyId") REFERENCES "Survey"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SurveyTrigger" ADD CONSTRAINT "SurveyTrigger_actionClassId_fkey" FOREIGN KEY ("actionClassId") REFERENCES "ActionClass"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SurveyAttributeFilter" ADD CONSTRAINT "SurveyAttributeFilter_attributeKeyId_fkey" FOREIGN KEY ("attributeKeyId") REFERENCES "ContactAttributeKey"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SurveyAttributeFilter" ADD CONSTRAINT "SurveyAttributeFilter_surveyId_fkey" FOREIGN KEY ("surveyId") REFERENCES "Survey"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Survey" ADD CONSTRAINT "Survey_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Survey" ADD CONSTRAINT "Survey_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Survey" ADD CONSTRAINT "Survey_segmentId_fkey" FOREIGN KEY ("segmentId") REFERENCES "Segment"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Survey" ADD CONSTRAINT "Survey_academicSemesterId_fkey" FOREIGN KEY ("academicSemesterId") REFERENCES "AcademicSemester"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SurveyQuota" ADD CONSTRAINT "SurveyQuota_surveyId_fkey" FOREIGN KEY ("surveyId") REFERENCES "Survey"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ResponseQuotaLink" ADD CONSTRAINT "ResponseQuotaLink_responseId_fkey" FOREIGN KEY ("responseId") REFERENCES "Response"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ResponseQuotaLink" ADD CONSTRAINT "ResponseQuotaLink_quotaId_fkey" FOREIGN KEY ("quotaId") REFERENCES "SurveyQuota"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SurveyFollowUp" ADD CONSTRAINT "SurveyFollowUp_surveyId_fkey" FOREIGN KEY ("surveyId") REFERENCES "Survey"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ActionClass" ADD CONSTRAINT "ActionClass_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Integration" ADD CONSTRAINT "Integration_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Workspace" ADD CONSTRAINT "Workspace_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OrganizationBilling" ADD CONSTRAINT "OrganizationBilling_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Membership" ADD CONSTRAINT "Membership_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Membership" ADD CONSTRAINT "Membership_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invite" ADD CONSTRAINT "Invite_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invite" ADD CONSTRAINT "Invite_creatorId_fkey" FOREIGN KEY ("creatorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invite" ADD CONSTRAINT "Invite_acceptorId_fkey" FOREIGN KEY ("acceptorId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ApiKey" ADD CONSTRAINT "ApiKey_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ApiKeyWorkspace" ADD CONSTRAINT "ApiKeyWorkspace_apiKeyId_fkey" FOREIGN KEY ("apiKeyId") REFERENCES "ApiKey"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ApiKeyWorkspace" ADD CONSTRAINT "ApiKeyWorkspace_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Account" ADD CONSTRAINT "Account_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TwoFactor" ADD CONSTRAINT "TwoFactor_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "oauthClient" ADD CONSTRAINT "oauthClient_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "oauthAccessToken" ADD CONSTRAINT "oauthAccessToken_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "oauthClient"("clientId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "oauthAccessToken" ADD CONSTRAINT "oauthAccessToken_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "Session"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "oauthAccessToken" ADD CONSTRAINT "oauthAccessToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "oauthAccessToken" ADD CONSTRAINT "oauthAccessToken_refreshId_fkey" FOREIGN KEY ("refreshId") REFERENCES "oauthRefreshToken"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "oauthRefreshToken" ADD CONSTRAINT "oauthRefreshToken_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "oauthClient"("clientId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "oauthRefreshToken" ADD CONSTRAINT "oauthRefreshToken_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "Session"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "oauthRefreshToken" ADD CONSTRAINT "oauthRefreshToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "oauthConsent" ADD CONSTRAINT "oauthConsent_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "oauthClient"("clientId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "oauthConsent" ADD CONSTRAINT "oauthConsent_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PasswordResetToken" ADD CONSTRAINT "PasswordResetToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Segment" ADD CONSTRAINT "Segment_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Language" ADD CONSTRAINT "Language_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SurveyLanguage" ADD CONSTRAINT "SurveyLanguage_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "Language"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SurveyLanguage" ADD CONSTRAINT "SurveyLanguage_surveyId_fkey" FOREIGN KEY ("surveyId") REFERENCES "Survey"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Team" ADD CONSTRAINT "Team_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TeamUser" ADD CONSTRAINT "TeamUser_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TeamUser" ADD CONSTRAINT "TeamUser_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkspaceTeam" ADD CONSTRAINT "WorkspaceTeam_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkspaceTeam" ADD CONSTRAINT "WorkspaceTeam_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Chart" ADD CONSTRAINT "Chart_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Chart" ADD CONSTRAINT "Chart_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Chart" ADD CONSTRAINT "Chart_feedbackDirectoryId_fkey" FOREIGN KEY ("feedbackDirectoryId") REFERENCES "FeedbackDirectory"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Dashboard" ADD CONSTRAINT "Dashboard_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Dashboard" ADD CONSTRAINT "Dashboard_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DashboardWidget" ADD CONSTRAINT "DashboardWidget_dashboardId_fkey" FOREIGN KEY ("dashboardId") REFERENCES "Dashboard"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DashboardWidget" ADD CONSTRAINT "DashboardWidget_chartId_fkey" FOREIGN KEY ("chartId") REFERENCES "Chart"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FeedbackSource" ADD CONSTRAINT "FeedbackSource_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FeedbackSource" ADD CONSTRAINT "FeedbackSource_feedbackDirectoryId_fkey" FOREIGN KEY ("feedbackDirectoryId") REFERENCES "FeedbackDirectory"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FeedbackSource" ADD CONSTRAINT "FeedbackSource_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FeedbackSourceFormbricksMapping" ADD CONSTRAINT "FeedbackSourceFormbricksMapping_feedback_source_id_workspa_fkey" FOREIGN KEY ("feedback_source_id", "workspaceId") REFERENCES "FeedbackSource"("id", "workspaceId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FeedbackSourceFormbricksMapping" ADD CONSTRAINT "FeedbackSourceFormbricksMapping_surveyId_workspaceId_fkey" FOREIGN KEY ("surveyId", "workspaceId") REFERENCES "Survey"("id", "workspaceId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FeedbackSourceFieldMapping" ADD CONSTRAINT "FeedbackSourceFieldMapping_feedback_source_id_workspaceId_fkey" FOREIGN KEY ("feedback_source_id", "workspaceId") REFERENCES "FeedbackSource"("id", "workspaceId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FeedbackDirectory" ADD CONSTRAINT "FeedbackDirectory_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FeedbackDirectoryWorkspace" ADD CONSTRAINT "FeedbackDirectoryWorkspace_feedbackDirectoryId_fkey" FOREIGN KEY ("feedbackDirectoryId") REFERENCES "FeedbackDirectory"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FeedbackDirectoryWorkspace" ADD CONSTRAINT "FeedbackDirectoryWorkspace_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AcademicSemester" ADD CONSTRAINT "AcademicSemester_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentSurveyTarget" ADD CONSTRAINT "StudentSurveyTarget_academicSemesterId_fkey" FOREIGN KEY ("academicSemesterId") REFERENCES "AcademicSemester"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TargetGroup" ADD CONSTRAINT "TargetGroup_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_SurveyToTargetGroup" ADD CONSTRAINT "_SurveyToTargetGroup_A_fkey" FOREIGN KEY ("A") REFERENCES "Survey"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_SurveyToTargetGroup" ADD CONSTRAINT "_SurveyToTargetGroup_B_fkey" FOREIGN KEY ("B") REFERENCES "TargetGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

