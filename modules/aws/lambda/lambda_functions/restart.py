import boto3
import os

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    instance_ids = os.environ["INSTANCE_IDS"].split(",")
    ec2.reboot_instances(InstanceIds=instance_ids)
    return {"message": f"Restarted instances: {instance_ids}"}
