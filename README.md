# Deepseek on EKS

## Description

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
git clone https://github.com/dudssecco/deepseek-on-eks/edit/main/README.md
cd deepseek-on-eks
```
