#!/bin/bash

set -e

# Colors
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
END="\e[0m"

function header() {
    echo -e "${BLUE}\n===== $1 =====${END}"
}

function success() {
    echo -e "${GREEN}✔ $1 installed successfully${END}"
}

function error() {
    echo -e "${RED}✖ $1 installation failed${END}"
}

# Update system
header "Updating system"
apt update -y && apt upgrade -y

# Install Git
install_git() {
    header "Installing Git"
    apt install -y git && success "Git" || error "Git"
}

# Install Docker
install_docker() {
    header "Installing Docker"
    apt install -y docker.io
    systemctl enable docker
    systemctl start docker
    usermod -aG docker $USER
    success "Docker"
}

# Install Docker Compose
install_docker_compose() {
    header "Installing Docker Compose"
    apt install -y docker-compose && success "Docker Compose" || error "Docker Compose"
}

# Install AWS CLI
install_awscli() {
    header "Installing AWS CLI"
    apt install -y awscli && success "AWS CLI" || error "AWS CLI"
}

# Install kubectl
install_kubectl() {
    header "Installing kubectl"
    curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    success "kubectl"
}

# Install eksctl
install_eksctl() {
    header "Installing eksctl"
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    mv /tmp/eksctl /usr/local/bin
    success "eksctl"
}

# Install Helm
install_helm() {
    header "Installing Helm"
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    success "Helm"
}

# Install Terraform
install_terraform() {
    header "Installing Terraform"
    apt install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
        | tee /etc/apt/sources.list.d/hashicorp.list
    apt update && apt install -y terraform
    success "Terraform"
}

# Install Nginx
install_nginx() {
    header "Installing Nginx"
    apt install -y nginx
    systemctl enable nginx
    systemctl start nginx
    success "Nginx"
}

# Install MySQL
install_mysql() {
    header "Installing MySQL"
    apt install -y mysql-server
    systemctl enable mysql
    systemctl start mysql
    success "MySQL"
}

# Install PostgreSQL
install_postgres() {
    header "Installing PostgreSQL"
    apt install -y postgresql postgresql-contrib
    systemctl enable postgresql
    systemctl start postgresql
    success "PostgreSQL"
}

# Install Ansible
install_ansible() {
    header "Installing Ansible"
    apt install -y ansible && success "Ansible" || error "Ansible"
}

# Install Jenkins
install_jenkins() {
    header "Installing Jenkins"
    apt install -y openjdk-17-jdk
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | tee \
      /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
      https://pkg.jenkins.io/debian-stable binary/ | tee \
      /etc/apt/sources.list.d/jenkins.list > /dev/null
    apt update
    apt install -y jenkins
    systemctl enable jenkins
    systemctl start jenkins
    success "Jenkins"
}

# Install Maven
install_maven() {
    header "Installing Maven"
    apt install -y maven && success "Maven" || error "Maven"
}

# Install Tomcat
install_tomcat() {
    header "Installing Tomcat"
    apt install -y tomcat9 tomcat9-admin
    systemctl enable tomcat9
    systemctl start tomcat9
    success "Tomcat"
}

# Install SonarQube (basic setup)
install_sonarqube() {
    header "Installing SonarQube"
    apt install -y openjdk-17-jdk unzip wget
    cd /opt
    wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.3.0.82913.zip
    unzip sonarqube-*.zip
    mv sonarqube-* sonarqube
    success "SonarQube (manual start required)"
}

# Menu
while true; do
    echo -e "\nSelect packages to install:"
    echo "1. Git"
    echo "2. Docker"
    echo "3. Docker Compose"
    echo "4. AWS CLI"
    echo "5. kubectl"
    echo "6. eksctl"
    echo "7. Helm"
    echo "8. Terraform"
    echo "9. Nginx"
    echo "10. MySQL"
    echo "11. PostgreSQL"
    echo "12. Ansible"
    echo "13. Jenkins"
    echo "14. Maven"
    echo "15. Tomcat"
    echo "16. SonarQube"
    echo "17. Install ALL"
    echo "0. Exit"

    read -p "Enter choice: " choice

    case $choice in
        1) install_git ;;
        2) install_docker ;;
        3) install_docker_compose ;;
        4) install_awscli ;;
        5) install_kubectl ;;
        6) install_eksctl ;;
        7) install_helm ;;
        8) install_terraform ;;
        9) install_nginx ;;
        10) install_mysql ;;
        11) install_postgres ;;
        12) install_ansible ;;
        13) install_jenkins ;;
        14) install_maven ;;
        15) install_tomcat ;;
        16) install_sonarqube ;;
        17)
            install_git
            install_docker
            install_docker_compose
            install_awscli
            install_kubectl
            install_eksctl
            install_helm
            install_terraform
            install_nginx
            install_mysql
            install_postgresdevops-installer.sh
            install_ansible
            install_jenkins
            install_maven
            install_tomcat
            install_sonarqube
            ;;
        0) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done