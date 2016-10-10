#!/bin/bash
# create-env.sh
# Zachary Klima

grpname="kli-z-cenv-sg"
keyname="cenv-key"
amimage="ami-06b94666"
coun=3
lbn="cenv-lb"
asgn="cenv-asg"
lc="cenv-lc"

echo "Grepping instance ids..."
inst1=$(aws ec2 describe-instances | grep -o "i-[A-Za-z0-9]\{10,\}" | cut -d$'\n' -f1) &
inst2=$(aws ec2 describe-instances | grep -o "i-[A-Za-z0-9]\{10,\}" | cut -d$'\n' -f2) &
inst3=$(aws ec2 describe-instances | grep -o "i-[A-Za-z0-9]\{10,\}" | cut -d$'\n' -f3) &
wait
echo "Deleting security group..."
aws ec2 delete-security-group --group-name $grpname &
wait
echo "Deleting key pair..."
aws ec2 delete-key-pair --key-name $keyname &
wait
echo "Detaching load balancer..."
aws autoscaling detach-load-balancers --auto-scaling-group-name $asgn --load-balancer-names $lbn &
wait
echo "Deleting autoscale group..."
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $asgn --force-delete &
wait
echo "Deleting launch configuration..."
aws autoscaling delete-launch-configuration --launch-configuration-name $lc &
wait
echo "Deregistering instances from load balancer..."
aws elb deregister-instances-from-load-balancer --load-balancer-name $lbn --instances $inst1 $inst2 $inst3 &
wait
echo "Deleting listeners..."
aws elb delete-load-balancer-listeners --load-balancer-name $lbn --load-balancer-ports 22 &
aws elb delete-load-balancer-listeners --load-balancer-name $lbn --load-balancer-ports 80 &
wait
echo "Deleting load balancer..."
aws elb delete-load-balancer --load-balancer-name $lbn &
wait
echo "Terminating instances..."
aws ec2 termiante-instances --instance-ids $inst1 $inst2 $inst3 &
wait


exit 0
