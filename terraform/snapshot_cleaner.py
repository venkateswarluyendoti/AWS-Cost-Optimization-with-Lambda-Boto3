import boto3

ec2 = boto3.client('ec2')

def get_active_volumes():
    instances = ec2.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running', 'stopped']}])['Reservations']
    volumes = set()
    for reservation in instances:
        for instance in reservation['Instances']:
            volumes.update([vol['Ebs']['VolumeId'] for vol in instance.get('BlockDeviceMappings', []) if 'Ebs' in vol])
    print(f"Active volumes: {volumes}")  # Log for debugging
    return volumes

def clean_snapshots():
    snapshots = ec2.describe_snapshots(OwnerIds=['self'])['Snapshots']
    print(f"Found {len(snapshots)} snapshots")  # Log for debugging
    active_volumes = get_active_volumes()
    for snap in snapshots:
        volume_id = snap.get('VolumeId')
        print(f"Checking snapshot {snap['SnapshotId']} with VolumeId {volume_id}")  # Log for debugging
        if volume_id and volume_id not in active_volumes:
            ec2.delete_snapshot(SnapshotId=snap['SnapshotId'])
            print(f"Deleted stale snapshot: {snap['SnapshotId']}")

def lambda_handler(event, context):
    clean_snapshots()
    return {'statusCode': 200, 'body': 'Snapshots cleaned'}