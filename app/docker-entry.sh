#!/bin/bash
config=/mattermost/config/config.json
export DB_HOST="${DB_HOST:-db}"
export DB_PORT_5432_TCP_PORT="${DB_PORT_5432_TCP_PORT:-5432}"
export MM_USERNAME="${MM_USERNAME:-mmuser}"
export MM_PASSWORD="${MM_PASSWORD:-mmuser_password}"
export MM_DBNAME="${MM_DBNAME:-mattermost}"

export EMAIL_SIGN_UP="${EMAIL_SIGN_UP:-true}"
export EMAIL_NOTIFICATIONS="${EMAIL_NOTIFICATIONS:-false}"
export EMAIL_VERIFICATION="${EMAIL_VERIFICATION:-false}"
export EMAIL_PUSH_NOTIFICATION="${EMAIL_PUSH_NOTIFICATION:-false}"

export ENABLE_INCOMING_WEBHOOKS="${ENABLE_INCOMING_WEBHOOKS:-false}"
export ENABLE_OUTGOING_WEBHOOKS="${ENABLE_OUTGOING_WEBHOOKS:-false}"
export ENABLE_POST_USERNAME_OVERRIDE="${ENABLE_POST_USERNAME_OVERRIDE:-false}"

export GITLAB="${GITLAB:-false}"




cat << ENV_FILE > $config
{
    "ServiceSettings": {
        "ListenAddress": ":80",
        "MaximumLoginAttempts": 10,
        "SegmentDeveloperKey": "",
        "GoogleDeveloperKey": "",
        "EnableOAuthServiceProvider": false,
        "EnableIncomingWebhooks": ${ENABLE_INCOMING_WEBHOOKS},
        "EnableOutgoingWebhooks": ${ENABLE_OUTGOING_WEBHOOKS},
        "EnablePostUsernameOverride": ${ENABLE_POST_USERNAME_OVERRIDE},
        "EnablePostIconOverride": false,
        "EnableTesting": false,
        "EnableSecurityFixAlert": true
    },
    "TeamSettings": {
        "SiteName": "Mattermost",
        "MaxUsersPerTeam": 50,
        "EnableTeamCreation": true,
        "EnableUserCreation": true,
        "RestrictCreationToDomains": "",
        "RestrictTeamNames": true,
        "EnableTeamListing": false
    },
    "SqlSettings": {
        "DriverName": "postgres",
        "DataSource": "postgres://${MM_USERNAME}:${MM_PASSWORD}@${DB_HOST}:${DB_PORT}/${MM_DBNAME}?sslmode=disable&connect_timeout=10",
        "DataSourceReplicas": [],
        "MaxIdleConns": 10,
        "MaxOpenConns": 10,
        "Trace": false,
        "AtRestEncryptKey": "7rAh6iwQCkV4cA1Gsg3fgGOXJAQ43QVg"
    },
    "LogSettings": {
        "EnableConsole": false,
        "ConsoleLevel": "INFO",
        "EnableFile": true,
        "FileLevel": "INFO",
        "FileFormat": "",
        "FileLocation": ""
    },
    "FileSettings": {
        "DriverName": "local",
        "Directory": "/mattermost/data/",
        "EnablePublicLink": true,
        "PublicLinkSalt": "A705AklYF8MFDOfcwh3I488G8vtLlVip",
        "ThumbnailWidth": 120,
        "ThumbnailHeight": 100,
        "PreviewWidth": 1024,
        "PreviewHeight": 0,
        "ProfileWidth": 128,
        "ProfileHeight": 128,
        "InitialFont": "luximbi.ttf",
        "AmazonS3AccessKeyId": "",
        "AmazonS3SecretAccessKey": "",
        "AmazonS3Bucket": "",
        "AmazonS3Region": ""
    },
    "EmailSettings": {
        "EnableSignUpWithEmail": ${EMAIL_SIGN_UP},
        "SendEmailNotifications": ${EMAIL_NOTIFICATIONS},
        "RequireEmailVerification": ${EMAIL_VERIFICATION},
        "FeedbackName": "${EMAIL_NAME}",
        "FeedbackEmail": "${EMAIL}",
        "SMTPUsername": "${SMTP_USER}",
        "SMTPPassword": "${SMTP_PASS}",
        "SMTPServer": "${SMTP_SERVER}",
        "SMTPPort": "${SMTP_PORT}",
        "ConnectionSecurity": "${CONNECTION}",
        "InviteSalt": "bjlSR4QqkXFBr7TP4oDzlfZmcNuH9YoS",
        "PasswordResetSalt": "vZ4DcKyVVRlKHHJpexcuXzojkE5PZ5eL",
        "ApplePushServer": "",
        "ApplePushCertPublic": "",
        "ApplePushCertPrivate": ""
        "SendPushNotifications": ${EMAIL_PUSH_NOTIFICATION},
        "PushNotificationServer": "${EMAIL_PUSH_NOTIFICATION_SERVER}",
        "PushNotificationContents": "${EMAIL_PUSH_NOTIFICATION_CONTENTS}"
    },
    "RateLimitSettings": {
        "EnableRateLimiter": true,
        "PerSec": 10,
        "MemoryStoreSize": 10000,
        "VaryByRemoteAddr": true,
        "VaryByHeader": ""
    },
    "PrivacySettings": {
        "ShowEmailAddress": true,
        "ShowFullName": true
    },
    "GitLabSettings": {
        "Enable": ${GITLAB},
        "Secret": "${SECRET}",
        "Id": "${ID}",
        "Scope": "${SCOPE}",
        "AuthEndpoint": "${AUTH}",
        "TokenEndpoint": "${TOKEN}",
        "UserApiEndpoint": "${USER}"
    }
}
ENV_FILE

#echo -ne "Configure database connection..."
#if [ ! -f $config ]
#then
#    cp /config.template.json $config
#    sed -Ei "s/DB_HOST/$DB_HOST/" $config
#    sed -Ei "s/DB_PORT/$DB_PORT_5432_TCP_PORT/" $config
#    sed -Ei "s/MM_USERNAME/$MM_USERNAME/" $config
#    sed -Ei "s/MM_PASSWORD/$MM_PASSWORD/" $config
#    sed -Ei "s/MM_DBNAME/$MM_DBNAME/" $config
#    echo OK
#else
#    echo SKIP
#fi

echo "Wait until database $DB_HOST:$DB_PORT_5432_TCP_PORT is ready..."
until nc -z $DB_HOST $DB_PORT_5432_TCP_PORT
do
    sleep 1
done

# Wait to avoid "panic: Failed to open sql connection pq: the database system is starting up"
sleep 1

echo "Starting platform"
cd /mattermost/bin
./platform $*
