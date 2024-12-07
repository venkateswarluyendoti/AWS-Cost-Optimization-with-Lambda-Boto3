# AWS Cloud Cost Optimization - Identifying Stale Resources

## Identifying Stale EBS Snapshots

In this example, we'll create a Lambda function that identifies EBS snapshots that are no longer associated with any active EC2 instance and deletes them to save on storage costs.

### Description:

The Lambda function fetches all EBS snapshots owned by the same account ('self') and also retrieves a list of active EC2 instances (running and stopped). For each snapshot, it checks if the associated volume (if exists) is not associated with any active instance. If it finds a stale snapshot, it deletes it, effectively optimizing storage costs.

### Steps for implementation:
>> Open AWS Console and create one ec2 instance with the name of test-ec2 --> Ubuntu and t2.micro --> select       keypair --> launch instance.
>> Come back to Ec2 Dashboard and Click on Snapshots --> Create Snapshot --> VolumeID(choose) --> Description(test) --> Click on Snapshot.
>> Go to aws console --> Click on lambda --> Choose functions --> Click on Create function --> Name (cost-optimization-ebs-snapshot) --> Runtime(python 3.10) --> Click on Create function --> copy ebs_stale_snapshots.py file --> go to lambda environment --> paste it in test environment and save --> then click on deploy button --> click on test --> Event name (test) --> save --> click on test --> but it is failed --> Because the running time is only 3 seconds and it is also failing for some permissions issue --> Click on edit and increase the default execution time to 10 seconds --> save.
!Note: Please don't delete this entire setup like EBS snapshots or volumes that you are creating as part of this project it will incur costs so please delete the instance.

>> Now again click on configuration --> choose permissions --> click on role name with the new tab --> we are going to give it describe snapshots and delete snapshots --> click on add permissions --> choose attach policies --> we can click on create policy --> click on ec2 --> search snapshot --> select DescribeSnapshot and DeleteSnapshot --> Resources select All --> Next policy name(cost-optimization-ebs) --> create policy --> come back to role name --> Add permissions --> Attach policies --> search cost-optimization-ebs --> select cost-optimization -->click on add permissions --> come back to lambda function --> click on code --> click on test --> status(Failed) -->go to role name as IAM --> Add permissions --> Attach policies --> click on create policy --> choose Ec2 --> select DescribeVolumes and DescribeInstances --> Next --> policy name(ec2-permissions) --> click on create policy --> come back to role name --> click on Add permissions --> Attach policies --> search ec2 and select ec2-permissions --> Add permission --> come back to lambda function --> once again click on Test --> status(succeeded).




