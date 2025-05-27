# STEP 1
sudo apt update # makes that its up to date
sudo apt install nano -y # installed text editor, it could be also vim
sudo apt install git -y # installed git
# pull the repo
git clone https://github.com/saif-mohtasib-cloudflare-test/web-service-python.git
cd web-service-python
# installed python3-pip and virtual env vars
sudo apt install python3-pip python3-venv -y
python3 -m venv venv
source venv/bin/activate
# make sure that the gunicorn in the requirements file before running it
pip install -r requirements.txt
# installed nginx
sudo apt install nginx -y
sudo nano /etc/nginx/sites-available/web-service-python
# added the needed routing and the configs to use nginx this file should copied and pasted
#server {
#    listen 80;
#    server_name CHANGE THIS TO THE VM EXTERNAL IP;
#
#    location / {
#        proxy_pass http://localhost:8080;
#        proxy_set_header Host $host;
#        proxy_set_header X-Real-IP $remote_addr;
#    }
#}

# link the current config to the nginx enabled sites
sudo ln -s /etc/nginx/sites-available/web-service-python /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

gunicorn --bind 127.0.0.1:8080 main:app

# Step 2
sudo nano /etc/nginx/sites-available/web-service-python
# Change the server name to be the suffix (proxy) and the domain name
# The reload nginx
sudo nginx -t
sudo systemctl reload nginx

# Step 3
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d proxy.honeywagonfilms.com

# Step 4
# Stage 1
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
sudo mv cloudflared-linux-amd64 /usr/local/bin/cloudflared
sudo chmod +x /usr/local/bin/cloudflared
# Once successful, execute this:
cloudflared tunnel login

# Step 4
# Stage 2
cloudflared tunnel create your-tunnel-name # i used for the first hf and for the second hfs
sudo mkdir -p /etc/cloudflared
sudo nano /etc/cloudflared/config.yml
# this the configuration for the funnel
#tunnel:tunnel-id # tunnel id was printed on terminal in the previous step
#credentials-file: /home/you_user/.cloudflared/tunnel-id.json # same tunnel id, your_user
#ingress:
#  - hostname: tunnel.yourdoaminname.com
#    service: http://localhost:8080
#  - service: http_status:404
# this could be done as well from the dashboard

# create a new record type CNAME, name tunnel
cloudflared tunnel route dns hf-tunnel tunnel.honeywagonfilms.com
cloudflared tunnel run hf-tunnel

# Step 6
cd web-service-python/
git pull origin main
source venv/bin/activate
ps aux | grep gunicorn
kill -9 PSID  # replace PSID with the ids that the grep returns
gunicorn --bind 127.0.0.1:8080 main:app # start the app again
