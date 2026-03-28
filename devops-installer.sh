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
apt install -y curl wget unzip 

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
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip > /dev/null
    sudo ./aws/install && success "AWS CLI" || error "AWS CLI"
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
    apt update && apt install -y terraform > /dev/null
    success "Terraform"
}

# Install Nginx
install_nginx() {
    header "Installing Nginx"
    apt install -y nginx > /dev/null
    systemctl enable nginx
    systemctl start nginx
    success "Nginx"
}

# Install MySQL
install_mysql() {
    header "Installing MySQL"
    apt install -y mysql-server > /dev/null
    systemctl enable mysql
    systemctl start mysql
    success "MySQL"
}

# Install PostgreSQL
install_postgres() {
    header "Installing PostgreSQL"
    apt install -y postgresql postgresql-contrib > /dev/null
    systemctl enable postgresql
    systemctl start postgresql
    success "PostgreSQL"
}

# Install Ansible
install_ansible() {
    header "Installing Ansible"
    apt install -y ansible > /dev/null && success "Ansible" || error "Ansible"
}

# Install Jenkins
install_jenkins() {
    header "Installing Jenkins"
    apt install -y openjdk-17-jdk > /dev/null
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt update -y > /dev/null
    sudo apt install -y jenkins > /dev/null
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    success "Jenkins"
}

# Install Maven
install_maven() {
    header "Installing Maven"
    apt install -y maven > /dev/null&& success "Maven" || error "Maven"
}

# Install Tomcat
install_tomcat() {
    header "Installing Tomcat"
    apt install -y tomcat9 tomcat9-admin > /dev/null
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
    unzip sonarqube-*.zip > /dev/null
    mv sonarqube-* sonarqube
    success "SonarQube (manual start required)"
}

# Install Prometheus (basic setup)
install_prometheus() {
    header "Installing Prometheus"
    useradd --no-create-home --shell /bin/false prometheus
    cd /opt
    VERSION=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep tag_name | cut -d '"' -f4)
    wget https://github.com/prometheus/prometheus/releases/download/${VERSION}/prometheus-${VERSION#v}.linux-amd64.tar.gz
    tar xvf prometheus-*.linux-amd64.tar.gz > /dev/null
    rm prometheus-*.linux-amd64.tar.gz
    mv prometheus-* prometheus
    chown -R prometheus:prometheus /opt/prometheus
    cd prometheus
    mv prometheus promtool /usr/local/bin/
    mkdir -p /etc/prometheus
    mkdir -p /var/lib/prometheus
    cp prometheus.yml /etc/prometheus/
    chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
    sudo bash -c 'cat <<EOF > /etc/systemd/system/prometheus.service
    [Unit]
    Description=Prometheus Service
    After=network-online.target

    [Service]
    User=prometheus
    ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/
    Restart=always

    [Install]
    WantedBy=default.target
    EOF'
    systemctl daemon-reload
    systemctl start prometheus.service
    systemctl enable prometheus.service
    success "Prometheus"
}

# Install Node Exporter (basic setup)
install_node_exporter() {
    header "Installing Node Exporter"
    useradd --no-create-home --shell /bin/false node_exporter
    cd /opt
    VERSION=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep tag_name | cut -d '"' -f4)
    wget https://github.com/prometheus/node_exporter/releases/download/${VERSION}/node_exporter-${VERSION#v}.linux-amd64.tar.gz
    tar xvf node_exporter-*.linux-amd64.tar.gz > /dev/null
    rm node_exporter-*.linux-amd64.tar.gz
    mv node_exporter-* node_exporter
    mv node_exporter/node_exporter /usr/local/bin/
    chown -R node_exporter:node_exporter /opt/node_exporter
    sudo bash -c 'cat <<EOF > /etc/systemd/system/node_exporter.service
    [Unit]
    Description=Node Exporter Service
    After=network-online.target

    [Service]
    User=node_exporter
    ExecStart=/usr/local/bin/node_exporter
    Restart=always  

    [Install]
    WantedBy=default.target
    EOF'
    systemctl daemon-reload
    systemctl start node_exporter.service
    systemctl enable node_exporter.service
    success "Node Exporter"
}

# Install Alertmanager (basic setup)
install_alertmanager() {
    header "Installing Alertmanager"
    useradd --no-create-home --shell /bin/false alertmanager
    cd /opt
    VERSION=$(curl -s https://api.github.com/repos/prometheus/alertmanager/releases/latest | grep tag_name | cut -d '"' -f4)
    wget https://github.com/prometheus/alertmanager/releases/download/${VERSION}/alertmanager-${VERSION#v}.linux-amd64.tar.gz
    tar xvf alertmanager-*.linux-amd64.tar.gz > /dev/null
    rm alertmanager-*.linux-amd64.tar.gz
    mv alertmanager-* alertmanager
    mv alertmanager/alertmanager /usr/local/bin/
    chown -R alertmanager:alertmanager /opt/alertmanager
    sudo bash -c 'cat <<EOF > /etc/systemd/system/alertmanager.service
    [Unit]
    Description=Alertmanager Service
    After=network-online.target 

    [Service]
    User=alertmanager
    ExecStart=/usr/local/bin/alertmanager \
    --config.file=/opt/alertmanager/alertmanager.yml \
    --storage.path=/opt/alertmanager/data
    Restart=always

    [Install]
    WantedBy=default.target
    EOF'
    systemctl daemon-reload
    systemctl start alertmanager.service
    systemctl enable alertmanager.service
    success "Alertmanager"
}

# Install grafana (basic setup)
install_grafana() {
    header "Installing Grafana"
    apt install -y apt-transport-https software-properties-common > /dev/null
    wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
    echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
    apt update -y
    apt install -y grafana > /dev/null
    systemctl daemon-reload
    systemctl enable grafana-server.service
    systemctl start grafana-server.service
    success "Grafana"
}

# install netstat
install_netstat() {
    header "Installing net-tools (for netstat)"
    apt install -y net-tools > /dev/null && success "net-tools" || error "net-tools"
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
    echo "17. Prometheus"
    echo "18. Node Exporter"
    echo "19. Alertmanager"
    echo "20. Grafana"
    echo "21. net-tools (for netstat)"
    echo "22. Install ALL"
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
        17) install_prometheus ;;  
        18) install_node_exporter ;;
        19) install_alertmanager ;;
        20) install_grafana ;;
        21) install_netstat ;;   
        22)
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
            install_prometheus
            install_node_exporter
            install_alertmanager
            install_grafana
            install_netstat
            ;;
        0) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done