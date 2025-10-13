# AWS Cloud Cost Optimization - Identifying Stale Resources

[![GitHub Repo](https://img.shields.io/badge/GitHub-Repo-blue?logo=github)](https://github.com/venkateswarluyendoti/AWS-Cost-Optimization-with-Lambda-Boto3)  
**Based on and extended from Abhishek Veeramalla's AWS Cost Optimization series.**  
This project uses AWS Lambda and Boto3 to identify and delete stale EBS snapshots (no longer tied to active EC2 instances), optimizing storage costs. The original approach tests with one instance for simplicity. We've extended it to handle multiple instances (e.g., 5 snapshots deleted at once) to demonstrate scalability and robustness.

## Project Overview
- **Goal**: Automate stale EBS snapshot cleanup to save costs (~$0.05/GB/month).
- **Key Features**:
  - Fetches owned snapshots and active EC2 volumes.
  - Deletes snapshots with no active volume association.
  - Supports single or multiple snapshots via a loop.
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
  <img width="1916" height="702" alt="Screenshot 2025-10-13 111714" src="https://github.com/user-attachments/assets/65f2f3e4-b104-4866-b22a-3e56a6bf01b3" />


2. **Create Snapshot**  
   - EC2 > Volumes > Select root volume > Actions > Create snapshot.  
   - Description: "test".  
   - Wait for "Completed" in EC2 > Snapshots. Note Snapshot ID.  
   <img width="1913" height="332" alt="Screenshot 2025-10-13 112012" src="https://github.com/user-attachments/assets/bea4a50f-56d9-49d3-b68f-91126868985a" />


3. **Deploy Lambda Function**  
   - AWS Console > Lambda > Functions > Create function.  
   - Name: `cost-optimization-ebs-snapshot`.  
   - Runtime: Python 3.10.  
   - Create function > Paste `snapshot_cleaner.py` (below) in editor > Click "Deploy".  
   <img width="1914" height="726" alt="Screenshot 2025-10-13 094958" src="https://github.com/user-attachments/assets/a1ed6d9b-ea74-467d-9334-679ec64148da" />
   <img width="1919" height="705" alt="Screenshot 2025-10-13 112224" src="https://github.com/user-attachments/assets/5c444c44-12ce-4138-902e-2f2660ea074b" />



4. **Set Handler and Timeout**  
   - Code tab > Edit runtime settings > Handler: `snapshot_cleaner.lambda_handler`.  
   - Configuration > General > Edit > Timeout: 10 seconds.  
   - Save.
    <img width="1914" height="706" alt="Screenshot 2025-10-13 093933" src="https://github.com/user-attachments/assets/e3e2a4ff-8634-4f60-b6a7-98245bdbf31a" />

    - “Click on Edit and rename it to snapshot_cleaner.lambda_handler.” 
      
  
    <img width="1910" height="711" alt="Screenshot 2025-10-13 094018" src="https://github.com/user-attachments/assets/0b04a597-5ca6-4313-a166-99eaabc3aaf7" />
    
    <img width="1919" height="447" alt="Screenshot 2025-10-13 094049" src="https://github.com/user-attachments/assets/11f444de-bf8a-4834-9505-611e2dbe7f83" />

    - “Click on Edit and increase the timeout value up to 10 seconds.” 
      
    
<img width="1915" height="707" alt="Screenshot 2025-10-13 094115" src="https://github.com/user-attachments/assets/8fc9110c-6e0c-4d58-ba82-45279105c46a" />





   
5. **Configure IAM Permissions**  
   - Lambda > Configuration > Permissions > Role name (opens IAM).  
   - Add permissions > Create policy:  
     - Service: EC2 > Actions: DescribeSnapshots, DeleteSnapshot > Resources: * > Name: `cost-optimization-ebs` > Create.  
   - Add permissions > Create policy:  
     - Service: EC2 > Actions: DescribeVolumes, DescribeInstances > Resources: * > Name: `ec2-permissions` > Create.  
   - Attach both policies to the role.
     <img width="1916" height="704" alt="Screenshot 2025-10-13 094246" src="https://github.com/user-attachments/assets/87a5a978-9da9-4116-8310-56c0137b19b0" />
     <img width="1919" height="725" alt="Screenshot 2025-10-13 094322" src="https://github.com/user-attachments/assets/c0fcbd5e-edce-4cb3-be62-c69985966014" />
     <img width="1914" height="703" alt="Screenshot 2025-10-13 094346" src="https://github.com/user-attachments/assets/c3170cf9-033b-4434-8905-1ae72b1f5072" />
     <img width="1917" height="465" alt="Screenshot 2025-10-13 094440" src="https://github.com/user-attachments/assets/1a42f2ce-2f28-42a8-bcac-bc3ff2242d36" />
     <img width="1915" height="466" alt="Screenshot 2025-10-13 094501" src="https://github.com/user-attachments/assets/02cd7cad-2ddf-4d32-88de-9beab13dbbda" />
     <img width="1913" height="892" alt="Screenshot 2025-10-13 094549" src="https://github.com/user-attachments/assets/c320e689-1210-49d8-9d7a-d63da237abbd" />
     <img width="1916" height="538" alt="Screenshot 2025-10-13 094633" src="https://github.com/user-attachments/assets/5df22fec-219c-45ab-a2e4-3689bdf91d25" />
<img width="1918" height="591" alt="Screenshot 2025-10-13 094655" src="https://github.com/user-attachments/assets/d7ed2603-e66a-4414-81c1-92bcd7ab5fe2" />
<img width="1904" height="885" alt="Screenshot 2025-10-13 094734" src="https://github.com/user-attachments/assets/5a68723e-7a6c-4de0-a80b-c312de74aed4" />
<img width="1912" height="902" alt="Screenshot 2025-10-13 094757" src="https://github.com/user-attachments/assets/e3221646-e4b5-4718-84ef-0e1844146b4d" />






 


6. **Test Function**  
   - Test tab > Event name: `test` > JSON: `{}` > Save > Test.  
   - Initial status may fail (permissions); retest after permissions.  
  
7. **Terminate Instance**  
   - EC2 > Instances > Select `test-ec2` > Instance state > Terminate.  
   - Verify volume deleted (EC2 > Volumes).  
   <img width="1903" height="714" alt="Screenshot 2025-10-13 112258" src="https://github.com/user-attachments/assets/c8451e95-96ba-461f-a5f9-86547aead7eb" />
<img width="1914" height="472" alt="Screenshot 2025-10-13 112351" src="https://github.com/user-attachments/assets/03e890de-9df4-449c-8f41-37dee29f511c" />


8. **Retest and Verify**  
   - Lambda > Test > Run.  
   - Logs (CloudWatch): Expect "Deleted stale snapshot: snap-xxx".  
   - EC2 > Snapshots: Confirm deletion.  
   <img width="1919" height="730" alt="Screenshot 2025-10-13 112414" src="https://github.com/user-attachments/assets/5e6dc7c6-e166-4493-bfef-22dc7d09c223" />


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
  <img width="1908" height="911" alt="Screenshot 2025-10-13 091506" src="https://github.com/user-attachments/assets/4a0320c0-63c5-4e23-a940-e6170aa5be97" />
  <img width="1910" height="872" alt="Screenshot 2025-10-13 091546" src="https://github.com/user-attachments/assets/f1173eaf-b742-4c3d-b126-c740fed45ee5" />
  <img width="1910" height="725" alt="Screenshot 2025-10-13 093142" src="https://github.com/user-attachments/assets/b08c9843-b3f7-439d-a252-15a55098e92a" />
 



2. **Create 5 Snapshots**  
   - EC2 > Volumes > For each volume: Actions > Create snapshot.  
   - Description: "Test snapshot [volume-id]".  
   - Wait for "Completed" in EC2 > Snapshots. Note 5 Snapshot IDs.
   <img width="1912" height="474" alt="Screenshot 2025-10-13 093253" src="https://github.com/user-attachments/assets/e9bb9b19-025b-4930-81f7-8c7995697008" />   
  <img width="1910" height="613" alt="Screenshot 2025-10-13 093321" src="https://github.com/user-attachments/assets/5ad5a4f0-7602-42ac-92c6-f1409b16cb1b" />
  <img width="1919" height="711" alt="Screenshot 2025-10-13 093427" src="https://github.com/user-attachments/assets/d9de5b42-4f6e-4f54-a0e4-282a3c412116" />
  <img width="1907" height="698" alt="Screenshot 2025-10-13 093657" src="https://github.com/user-attachments/assets/62a4c5c2-4f68-46b3-8119-c71f2110a393" />



3. **Deploy and Test Lambda (Same Setup)**  
   - Reuse Lambda function > Paste updated code (below) > Deploy.  
   - Initial test: Succeeds, no deletions yet.  
   <img width="1915" height="704" alt="Screenshot 2025-10-13 093808" src="https://github.com/user-attachments/assets/a900580a-8492-4d9a-8680-819a11b5ed74" />
  <img width="1914" height="726" alt="Screenshot 2025-10-13 094958" src="https://github.com/user-attachments/assets/b546e7db-8174-4c18-a1e5-d9fd18d397f7" />
  <img width="1915" height="817" alt="Screenshot 2025-10-13 095208" src="https://github.com/user-attachments/assets/3439a589-1ff0-449d-8df9-f3b9c1ac95c1" />
  <img width="1913" height="725" alt="Screenshot 2025-10-13 095319" src="https://github.com/user-attachments/assets/271cde90-f386-4213-ab09-38c7e5cc26a7" />
  <img width="1914" height="889" alt="Screenshot 2025-10-13 095419" src="https://github.com/user-attachments/assets/bf8c2be1-0931-45d1-b6dd-e198b06ddef8" />






4. **Terminate Instances**  
   - EC2 > Instances > Select all 5 > Instance state > Terminate.  
   - Verify volumes deleted (EC2 > Volumes). If not, delete manually.  
  <img width="1915" height="741" alt="Screenshot 2025-10-13 095940" src="https://github.com/user-attachments/assets/b1bcfdaa-e249-4940-ba56-ba680fe20d66" />
  <img width="1919" height="515" alt="Screenshot 2025-10-13 100128" src="https://github.com/user-attachments/assets/ab42f81d-64e1-445a-89c1-1959c60c9a5d" />



5. **Retest and Verify**  
   - Wait 5-10 minutes for propagation.  
   - Lambda > Test > Run.  
   - Logs: "Found 5 snapshots", "Active volumes: set()", 5x "Deleted stale snapshot: snap-xxx".  
   - EC2 > Snapshots: All 5 gone.  
   <img width="1919" height="816" alt="Screenshot 2025-10-13 100230" src="https://github.com/user-attachments/assets/8b7f610c-d385-40c2-b02f-991c3cf0718c" />
   <img width="1919" height="900" alt="Screenshot 2025-10-13 100351" src="https://github.com/user-attachments/assets/f6b26d22-137c-4fec-894d-61d5aa3e0cf5" />
<img width="1914" height="348" alt="Screenshot 2025-10-13 100415" src="https://github.com/user-attachments/assets/de02619f-c8f7-4063-81e0-c7b4429ef3a9" />
<img width="1907" height="676" alt="Screenshot 2025-10-13 100808" src="https://github.com/user-attachments/assets/b66eac3d-f0af-48ef-8d83-9c74ed954104" />



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
```

### Upload Tips: Paste directly in Lambda editor > Handler: snapshot_cleaner.lambda_handler > Runtime: Python 3.10 > Deploy.

## Additional Testing (Task 2 from Original)
Test with a detached volume to understand behavior.

1. Create Detached Volume

EC2 > Volumes > Create volume > Size: 1GB > Create volume.

<img width="1919" height="731" alt="Screenshot 2025-10-13 105025" src="https://github.com/user-attachments/assets/5ae2d4ca-7a2c-40ea-a146-9ef1a38b96f7" />


2. Create Snapshot

EC2 > Snapshots > Create snapshot > Select new volume > Create.
Refresh to confirm.
<img width="1908" height="891" alt="Screenshot 2025-10-13 105201" src="https://github.com/user-attachments/assets/f92db53e-5d0e-4fd4-bd29-f598317fa0ae" />



3. Test Lambda

Lambda > Test > Run.
Logs: Success; snapshot deleted, volume persists (not attached).
<img width="1912" height="840" alt="Screenshot 2025-10-13 105259" src="https://github.com/user-attachments/assets/ea98b834-8554-4d77-a7fd-7dc5c85e2889" />
<img width="1909" height="336" alt="Screenshot 2025-10-13 105431" src="https://github.com/user-attachments/assets/eab5af1d-9ed7-4ff3-bb40-d62ad44b29e6" />





Why: Code deletes snapshots tied to unattached volumes, leaving volumes intact.

## Scope and Extensions

- Scale Up: Create 100 snapshots—deleted in one run.
- Further Ideas: Lambda for S3 (empty buckets), RDS (unused DBs), EKS (idle clusters). Add age-based filters.
- Production Tips: Weekly runs, CloudWatch alarms, VPC security.

## Cleanup

- Terminate instances/volumes/snapshots.
- Delete Lambda, IAM policies, EventBridge rule (if added).
- !Note: Resources incur costs—clean up immediately!


## Credits

- Inspired by Abhishek Veeramalla's AWS Cost Optimization series (single-instance focus).
- Extended for multi-testing by [venkateswarluyendoti/Repo Contributor].

## Repository Files

- snapshot_cleaner.py: [Enhanced Lambda Code (snapshot_cleaner.py)].
- README.md: [AWS-Cost-Optimization-with-Lambda-Boto3].


