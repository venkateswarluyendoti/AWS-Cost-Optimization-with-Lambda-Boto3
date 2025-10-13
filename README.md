# AWS Cloud Cost Optimization - Identifying Stale Resources

[![GitHub Repo](https://img.shields.io/badge/GitHub-Repo-blue?logo=github)](https://github.com/venkateswarluyendoti/AWS-Cost-Optimization-with-Lambda-Boto3)  
**Based on and extended from Abhishek Veeramalla's AWS Cost Optimization series.**  
This project uses AWS Lambda and Boto3 to identify and delete stale EBS snapshots (no longer tied to active EC2 instances), optimizing storage costs. The original approach tests with one instance for simplicity. We've extended it to handle multiple instances (e.g., 5 snapshots deleted at once) to demonstrate scalability and robustness.

## Project Overview
- **Goal**: Automate stale EBS snapshot cleanup to save costs (~$0.05/GB/month).
- **Key Features**:
  - Fetches owned snapshots and active EC2 volumes.
  - Deletes snapshots with no active volume association.
  - Supports single or multiple snapshots via loop.
  - Includes logging for debugging.
- **Why This Matters**: Prevents cost leakage from unused snapshots in dev/test environments.
- **Cost**: Free-tier friendly (t2.micro, low Lambda usage).

## Single-Instance Testing (Original Approach by Abhishek Veeramalla)
Start with a single EC2 instance to learn the core concept.

### Implementation Steps
1. **Create EC2 Instance**  
   - Open AWS Console > EC2 > Launch instances.  
   - Name: `test-ec2`.  
   - AMI: Ubuntu Server 24.04 LTS.  
   - Type: t2.micro.  
   - Select key pair (or create new).  
   - Storage: 8 GiB gp3 (enable "Delete on termination").  
   - Launch instance and wait for "Running".  
   - **Screenshot**: [Insert screenshot of EC2 launch configuration here]

2. **Create Snapshot**  
   - EC2 > Volumes > Select root volume > Actions > Create snapshot.  
   - Description: "test".  
   - Wait for "Completed" in EC2 > Snapshots. Note Snapshot ID.  
   - **Screenshot**: [Insert screenshot of snapshot creation here]

3. **Deploy Lambda Function**  
   - AWS Console > Lambda > Functions > Create function.  
   - Name: `cost-optimization-ebs-snapshot`.  
   - Runtime: Python 3.10.  
   - Create function > Paste `snapshot_cleaner.py` (below) in editor > Click "Deploy".  
   - **Screenshot**: [Insert screenshot of Lambda creation and code paste here]

4. **Set Handler and Timeout**  
   - Code tab > Edit runtime settings > Handler: `snapshot_cleaner.lambda_handler`.  
   - Configuration > General > Edit > Timeout: 10 seconds.  
   - Save.  
   - **Screenshot**: [Insert screenshot of handler and timeout settings here]

5. **Configure IAM Permissions**  
   - Lambda > Configuration > Permissions > Role name (opens IAM).  
   - Add permissions > Create policy:  
     - Service: EC2 > Actions: DescribeSnapshots, DeleteSnapshot > Resources: * > Name: `cost-optimization-ebs` > Create.  
   - Add permissions > Create policy:  
     - Service: EC2 > Actions: DescribeVolumes, DescribeInstances > Resources: * > Name: `ec2-permissions` > Create.  
   - Attach both policies to role.  
   - **Screenshot**: [Insert screenshot of IAM policy creation and attachment here]

6. **Test Function**  
   - Test tab > Event name: `test` > JSON: `{}` > Save > Test.  
   - Initial status may fail (permissions); retest after permissions.  
   - **Screenshot**: [Insert screenshot of initial test failure here]

7. **Terminate Instance**  
   - EC2 > Instances > Select `test-ec2` > Instance state > Terminate.  
   - Verify volume deleted (EC2 > Volumes).  
   - **Screenshot**: [Insert screenshot of terminated instance here]

8. **Retest and Verify**  
   - Lambda > Test > Run.  
   - Logs (CloudWatch): Expect "Deleted stale snapshot: snap-xxx".  
   - EC2 > Snapshots: Confirm deletion.  
   - **Screenshot**: [Insert screenshot of successful test logs here]

**!Note**: Don’t delete this setup (snapshots/volumes) until cleanup to avoid confusion; it incurs costs—delete later.

## Multi-Instance Testing (Extended Approach)
Scale to 5 instances/snapshots to test bulk deletion and scalability.

### Implementation Steps
1. **Create 5 EC2 Instances**  
   - EC2 > Launch instances.  
   - Name: `test-instance` (auto-numbers 1-5).  
   - AMI: Ubuntu Server 24.04 LTS.  
   - Type: t2.micro.  
   - Storage: 8 GiB gp3 (enable "Delete on termination").  
   - Number of instances: 5.  
   - Launch and wait for "Running".  
   - **Screenshot**: [Insert screenshot of EC2 launch with 5 instances here]

2. **Create 5 Snapshots**  
   - EC2 > Volumes > For each volume: Actions > Create snapshot.  
   - Description: "Test snapshot [volume-id]".  
   - Wait for "Completed" in EC2 > Snapshots. Note 5 Snapshot IDs.  
   - **Screenshot**: [Insert screenshot of multiple snapshots here]

3. **Deploy and Test Lambda (Same Setup)**  
   - Reuse Lambda function > Paste updated code (below) > Deploy.  
   - Initial test: Succeeds, no deletions yet.  
   - **Screenshot**: [Insert screenshot of Lambda code update here]

4. **Terminate Instances**  
   - EC2 > Instances > Select all 5 > Instance state > Terminate.  
   - Verify volumes deleted (EC2 > Volumes). If not, delete manually.  
   - **Screenshot**: [Insert screenshot of terminated instances and volumes here]

5. **Retest and Verify**  
   - Wait 5-10 minutes for propagation.  
   - Lambda > Test > Run.  
   - Logs: "Found 5 snapshots", "Active volumes: set()", 5x "Deleted stale snapshot: snap-xxx".  
   - EC2 > Snapshots: All 5 gone.  
   - **Screenshot**: [Insert screenshot of logs showing 5 deletions here]

**Difference**: Logs show multi-deletion; cost savings more visible (~25% in Cost Explorer).

## Enhanced Lambda Code (`snapshot_cleaner.py`)
Paste into Lambda editor. Includes logging for debugging.

```python
import boto3

ec2 = boto3.client('ec2')

def get_active_volumes():
    instances = ec2.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running', 'stopped']}])['Reservations']
    volumes = set()
    for reservation in instances:
        for instance in reservation['Instances']:
            volumes.update([vol['Ebs']['VolumeId'] for vol in instance.get('BlockDeviceMappings', []) if 'Ebs' in vol])
    print(f"Active volumes: {volumes}")  # Debug log
    return volumes

def clean_snapshots():
    snapshots = ec2.describe_snapshots(OwnerIds=['self'])['Snapshots']
    print(f"Found {len(snapshots)} snapshots")  # Debug log
    active_volumes = get_active_volumes()
    for snap in snapshots:
        volume_id = snap.get('VolumeId')
        print(f"Checking snapshot {snap['SnapshotId']} with VolumeId {volume_id}")  # Debug log
        if volume_id and volume_id not in active_volumes:
            ec2.delete_snapshot(SnapshotId=snap['SnapshotId'])
            print(f"Deleted stale snapshot: {snap['SnapshotId']}")

def lambda_handler(event, context):
    clean_snapshots()
    return {'statusCode': 200, 'body': 'Snapshots cleaned'}


Upload Tips: Paste directly in Lambda editor > Handler: snapshot_cleaner.lambda_handler > Runtime: Python 3.10 > Deploy.

# Additional Testing (Task 2 from Original)
Test with a detached volume to understand behavior.

1. Create Detached Volume

EC2 > Volumes > Create volume > Size: 1GB > Create volume.
Screenshot: [Insert screenshot of volume creation here]


2. Create Snapshot

EC2 > Snapshots > Create snapshot > Select new volume > Create.
Refresh to confirm.
Screenshot: [Insert screenshot of snapshot creation here]


3. Test Lambda

Lambda > Test > Run.
Logs: Success; snapshot deleted, volume persists (not attached).
Screenshot: [Insert screenshot of logs for detached volume test here]



Why: Code deletes snapshots tied to unattached volumes, leaving volumes intact.

Scope and Extensions

Scale Up: Create 100 snapshots—deleted in one run.
Further Ideas: Lambda for S3 (empty buckets), RDS (unused DBs), EKS (idle clusters). Add age-based filters.
Production Tips: Weekly runs, CloudWatch alarms, VPC security.

Cleanup

Terminate instances/volumes/snapshots.
Delete Lambda, IAM policies, EventBridge rule (if added).
!Note: Resources incur costs—clean up immediately!
Screenshot: [Insert screenshot of cleanup confirmation here]

Credits

Inspired by Abhishek Veeramalla's AWS Cost Optimization series (single-instance focus).
Extended for multi-testing by [Your Name/Repo Contributor].

Repository Files

snapshot_cleaner.py: Enhanced Lambda script.
README.md: This file.