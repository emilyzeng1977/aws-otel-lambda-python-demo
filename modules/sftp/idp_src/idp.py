import boto3
import json
import os
import datetime
import structlog
import logging

structlog.configure(
    processors=[
        structlog.processors.add_log_level,
        structlog.processors.JSONRenderer(),
    ],
    wrapper_class=structlog.make_filtering_bound_logger(logging._nameToLevel[os.environ.get("log_level", "INFO").upper()])
)


def lambda_handler(event, context):
    lnog = structlog.get_logger(
        function_name=context.function_name,
        function_version=context.function_version,
        request_id=context.aws_request_id
    )
    start_time = datetime.datetime.now()

    try:
        BUCKETNAME = os.environ['bucketname']
        TRANSFERACCESSROLE = os.environ['transferaccessrole']
    except KeyError as e:
        log.fatal(
            "Missing an environment variable",
            missing=e.args[0],
            duration_ms=(datetime.datetime.now() -
                         start_time).total_seconds() * 1000
        )
        return {}

    data_ret = {}
    public_keys = []
    user = {}
    user_sub = ""

    # Check if password based authentication or not
    if event.get("password", "") != "":
        # We do not support password-based auth, only public-key.
        log.warn(
            f"Password-based access attempt from {event['username']} was rejected",
            duration_ms=(datetime.datetime.now() -
                         start_time).total_seconds() * 1000
        )
        return {}
    else:
        if event["protocol"] == 'SFTP':
            # Public key-based authentication
            log.info(
                f"SFTP Authentication initiated for {event['username']}",
                duration_ms=(datetime.datetime.now() -
                             start_time).total_seconds() * 1000
            )

            # Iterate through available identity pools to find the user
            cognito = boto3.client('cognito-idp')
            paginator = cognito.get_paginator('list_user_pools')
            full_pool_list = []
            found_users = []  # we gather the results in a list, in case there are duplicates
            pools = paginator.paginate(MaxResults=20)
            for p in pools:
                full_pool_list.extend(p['UserPools'])
            try:
                for pool in full_pool_list:
                    pool_user_list = cognito.list_users(
                        UserPoolId=pool['Id'],
                        Filter=f"username = \"{event['username']}\""
                    )
                    found_users.extend(pool_user_list['Users'])
            except cognito.exceptions.InvalidParameterException as e:
                log.error(
                    "Invalid Parameter",
                    exception=e,
                    duration_ms=(datetime.datetime.now() -
                                 start_time).total_seconds() * 1000
                )
                return {}
            if len(found_users) > 1:
                log.error(
                    f"Found {len(found_users)} users called {event['username']}",
                    duration_ms=(datetime.datetime.now() -
                                 start_time).total_seconds() * 1000
                )
                return {}
            elif len(found_users) == 0:
                log.warn(
                    f"Found no users called {event['username']}, denying access",
                    duration_ms=(datetime.datetime.now() -
                                 start_time).total_seconds() * 1000
                )
                return {}

            user = found_users[0]  # We found just one user, as it should be.
            if not user['Enabled']:
                log.warn(
                    f"Disabled user {event['username']} attemped access, but we denied",
                    duration_ms=(datetime.datetime.now() -
                                 start_time).total_seconds() * 1000
                )
                return {}
            user_sub = [x['Value']
                        for x in user['Attributes'] if x['Name'] == 'sub'][0]

            # We have a user, now let's find their public keys!
            try:
                public_keys = [
                    i['Value'] for i in user['Attributes'] if i['Name'].endswith("public_keys")
                ][0].split("\n")
            except IndexError:
                log.warn(
                    f"No SSH public keys found for user {event['username']}, denying access",
                    duration_ms=(datetime.datetime.now() -
                                 start_time).total_seconds() * 1000
                )
                return {}
            data_ret["PublicKeys"] = public_keys
            data_ret["Role"] = TRANSFERACCESSROLE
        else:
            # We only support SFTP
            log.warn(
                f"Non-SFTP access attempt was rejected",
                duration_ms=(datetime.datetime.now() -
                             start_time).total_seconds() * 1000
            )
            return {}
        directorymapping = [
            {"Entry": "/", "Target": f"/{BUCKETNAME}/{user_sub}"}
        ]
        data_pol = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "AllowListAccessToBucket",
                    "Action": [
                        "s3:List*"
                    ],
                    "Effect": "Allow",
                    "Resource": [
                        f"arn:aws:s3:::{BUCKETNAME}",
                        f"arn:aws:s3:::{BUCKETNAME}/*"
                    ],
                    "Condition": {
                        "StringLike": {
                            "s3:prefix": [
                                f"{user_sub}/*",
                                user_sub
                            ]
                        }
                    }
                },
                {
                    "Sid": "TransferDataBucketAccess",
                    "Effect": "Allow",
                    "Action": [
                        "s3:PutObject",
                        "s3:PutObjectAcl",
                        "s3:GetObject",
                        "s3:GetObjectAcl",
                        "s3:GetObjectVersion",
                        "s3:GetBucketLocation",
                        "s3:List*"
                    ],
                    "Resource": [
                        f"arn:aws:s3:::{BUCKETNAME}/{user_sub}",
                        f"arn:aws:s3:::{BUCKETNAME}/{user_sub}/*"
                    ]
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "kms:GenerateDataKey*",
                        "kms:Decrypt",
                        "kms:Encrypt"
                    ],
                    "Resource": "*"
                }
            ]
        }
        data_ret["Policy"] = json.dumps(data_pol)
        data_ret["HomeDirectoryType"] = "LOGICAL"
        data_ret["HomeDirectoryDetails"] = json.dumps(directorymapping)
        log.debug(
            "End of function reached",
            payload=data_ret,
            duration_ms=(datetime.datetime.now() -
                         start_time).total_seconds() * 1000
        )
        return data_ret
