#!/bin/bash
apt-get update -y
apt-get install -y apache2

cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Terraform Web Server</title>
</head>
<body>
    <h1>Welcome to My Terraform Web Server</h1>
    <p>This EC2 instance was created using Terraform.</p>
    <p>Apache was installed automatically using EC2 user data.</p>
</body>
</html>
HTML

systemctl enable apache2
systemctl restart apache2
