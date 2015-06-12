# openproject-docker
## Content
- Debian Jessy
- openproject 4.1
- mysql server

## How to build
```bash
docker build -t alain75007/openproject .
```

## How to run 
```bash
docker run -d --name openproject -p 22004:22 -p 10004:8080 alain75007/openproject
````

# After install
```bash
ssh openproject@127.0.0.1 -p 22004
sudo su

cd /home/openproject/openproject
[openproject@all] cp config/configuration.yml.example config/configuration.yml

```

Now, edit the configuration.yml file as you like.

````
    production:                          #main level
        email_delivery_method: :smtp       #settings for the production environment
        smtp_address: smtp.gmail.com
        smtp_port: 587
        smtp_domain: smtp.gmail.com
        smtp_user_name: ***@gmail.com
        smtp_password: ****
        smtp_enable_starttls_auto: true
        smtp_authentication: plain
````

Add this line into configuration.yml file at the of of file for better performance of OpenProject:

```bash
        rails_cache_store: :memcache
````

Then restart the container

````
docker stop
docker start
````
# openproject-docker
