import sys

def lambda_handler(event, context):
    print(event)
    print("hello_world123", file = sys.stdout)

    return {
        'statusCode': 200,
        # 'body': json.dumps(request_info)
    }
