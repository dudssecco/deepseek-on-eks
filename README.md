# 🔷 Deepseek on EKS

This repository contains the infrastructure and configuration to run the Deepseek model on Kubernetes (EKS) using Ollama within pods. The project includes the configuration of the WebUI for a graphical interface, facilitating the management and monitoring of the model. The necessary instructions and files to reproduce the environment are documented and versioned for easy replication and scalability.

## Technologies 

- Kubernetes: For container orchestration on EKS (Elastic Kubernetes Service).
- Terraform: For infrastructure automation as code (IaC), especially for provisioning the EKS cluster and AWS resources.
- Docker: For creating and managing containers for Ollama and WebUI.
- Ollama: Framework used to run the Deepseek machine learning model.
- WebUI: Graphical interface for monitoring and interacting with the model.
- AWS: For providing cloud infrastructure, including EKS, Docker image storage, and other necessary resources.

## Installation

### Requirements:

- Terraform installed and configured on your local machine.
- An AWS account configured with permission to create and manage EKS clusters.
- AWS CLI configured on your local machine.
- kubectl installed to interact with Kubernetes.

### 1. Clone this repository

```
git clone https://github.com/dudssecco/deepseek-on-eks/
cd deepseek-on-eks
```

#### Update the Terraform variables as needed:

- cluster_name – Define the name of your EKS cluster.
- bucket_name – Specify the S3 bucket name if required.
- region – Choose the AWS region where the infrastructure will be deployed.
- ssh-key – Set your SSH key for node access.


### 2. Configure your AWS account

```
aws_access_key = "YOUR_ACCESS_KEY"
aws_secret_key = "YOUR_SECRET_KEY"
region = "YOUR_REGION"
```

### 3. Initialize terraform and apply the terraform plan to provision the infrastructure

```
terraform init
```
```
terraform apply
```
Terraform will automatically create the necessary resources, such as the EKS cluster, network configurations, and IAM roles.

### 4. After provisioning the infrastructure, configure kubectl to access your EKS cluster

```
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

### 5. Check if the Node were created correctly:

```
kubectl get nodes
```

### 6. Apply the Kubernetes deployment files for Ollama and WebUI

- For Ollama and WebUI in ClusterIP:
```
kubectl apply -f deployment-deepseek.yaml
```
```
kubectl apply -f deployment-webui.yaml
```

- For Ollama and WebUI in LoadBalancer:
```
kubectl apply -f deployment-deepseek-lb.yaml
```
```
kubectl apply -f deployment-webui-lb.yaml
```

#### 6.1. Check if the pods were created correctly:
```
kubectl get pods -n deepseek
```

#### 6.2. Check if the services were created correctly:
```
kubectl get svc -n deepseek
```

### 7. Check if the load balancers are working correctly

- For Ollama:
```
curl http://<External-IP>:11434
```

- For WebUI:
```
curl http://<External-IP>:8080
```

### 8. Run Ollama Model

- Access the Ollama pod via bash to run the model:
```
kubectl exec -it <OLLAMA_POD_NAME> -- bash
```

- Acess the list of models:
```
ollama list  
```

- Run the desired model:
```
ollama run <MODEL_NAME>  
```

### 9. Open your WebUI in the browser, select your model, and enjoy!

Just grab the external URL from your LoadBalancer service and paste it into the browser.

![Screenshot 2025-03-03 at 14 08 05](https://github.com/user-attachments/assets/15a5b92f-1a1d-49cc-b312-0846bb970c35)















