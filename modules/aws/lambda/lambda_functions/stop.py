import boto3
import os

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    instance_ids = os.environ["INSTANCE_IDS"].split(",")
    ec2.stop_instances(InstanceIds=instance_ids)
    return {"message": f"Stopped instances: {instance_ids}"}
