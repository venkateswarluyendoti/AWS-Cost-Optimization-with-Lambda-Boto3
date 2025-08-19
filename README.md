# AWS Cloud Cost Optimization - Identifying Stale Resources

## Identifying Stale EBS Snapshots

In this project, we'll create a Lambda function that identifies EBS snapshots that are no longer associated with any active EC2 instance and deletes them to save on storage costs.

### Description:

The Lambda function fetches all EBS snapshots owned by the same account ('self') and also retrieves a list of active EC2 instances (running and stopped). For each snapshot, it checks if the associated volume (if exists) is not associated with any active instance. If it finds a stale snapshot, it deletes it, effectively optimizing storage costs.

### Steps for implementation:

Task:1
```bash
>> Open AWS Console and create one ec2 instance with the name of test-ec2 --> Ubuntu and t2.micro --> select keypair --> launch instance.
>> Come back to Ec2 Dashboard and Click on Snapshots --> Create Snapshot --> VolumeID(choose) --> Description(test) --> Click on Snapshot.
>> Go to aws console --> Click on lambda --> Choose functions --> Click on Create function --> Name (cost-optimization-ebs-snapshot) --> Runtime(python 3.10) --> Click on Create function --> copy ebs_stale_snapshots.py file --> go to lambda environment --> paste it in test environment and save --> then click on deploy button --> click on test --> Event name (test) --> save --> click on test --> but it is failed --> Because the running time is only 3 seconds and it is also failing for some permissions issue --> Click on edit and increase the default execution time to 10 seconds --> save.
```
## !Note: Please don't delete this entire setup, like EBS snapshots or volumes that you are creating as part of this project it will incur costs, so please delete the instance.
```bash
>> Now again click on configuration --> choose permissions --> click on role name with the new tab --> we are going to give it describe snapshots and delete snapshots --> click on add permissions --> choose attach policies --> we can click on create policy --> click on ec2 --> search snapshot --> select DescribeSnapshot and DeleteSnapshot --> Resources select All --> Next policy name(cost-optimization-ebs) --> create policy --> come back to role name --> Add permissions --> Attach policies --> search cost-optimization-ebs --> select cost-optimization -->click on add permissions --> come back to lambda function --> click on code --> click on test --> status(Failed) -->go to role name as IAM --> Add permissions --> Attach policies --> click on create policy --> choose Ec2 --> select DescribeVolumes and DescribeInstances --> Next --> policy name(ec2-permissions) --> click on create policy --> come back to role name --> click on Add permissions --> Attach policies --> search ec2 and select ec2-permissions --> Add permission --> come back to lambda function --> once again click on Test --> status(succeeded).
```

### >> Go to ec2 instances --> select test-ec2 and terminate the instance.

## !!Note: We can implement this project with the scope of we can create multiple instances and multiple snapshots, try out multiple scenarios ourself, we need to understand the concept.

###  >> We can refresh the page. Now, we can see the instance and volume both are deleted except snapshot --> go to the lambda function and click on Test again --> we can see the Deleted EBS snapshot, as its associated volume was not found.

### >> Now we will consider this snapshot as a stale snapshot, and we'll delete it.

### >> This is the way you can manage the cloud cost optimization in our AWS accounts as a DevOps and cloud engineer.

```bash
Task:2
 >> Go to ec2 dashboard and go to volumes and click on create volume --> size(1GB) --> create volume.
 >> Go to ec2 dashboard and click on snapshots --> create snapshots --> VolumeID(choose) --> create snapshot --> refresh page.
 >> Go to lambda function and click on Test --> status(succeeded) --> go to ec2 dashboard and click on refresh then we can observe only snapshot is deleted but voulume is constant why because we have written this in such a way that if the snapshot belongs to a volume that is not attached to any ec2 instance then delete snapshot, if the snapshot is still if it belongs to volume that is not attached to any ec2 instance just go ahead and delete it.
```

### SCOPE:
```bash
>> We can use the same example to create 100 snapshots here, and all the 100 snapshots will be deleted in one single go.
>> similarly, we will write lambda functions for S3 buckets, we will write lambda functions for RDS instances, EKS instances, and whatever we would like to do in our requirement.
```



