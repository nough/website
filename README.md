# Bristol Hackspace website

The website is built using Flask and uses mosparo spam detection for forms.

A blog section is provided using content authored in a Django CMS that is available at this [repository](https://github.com/bristolhackspace/website-django-cms).

## Prerequisites

To run this code locally it is assumed you have installed:

- git
- pyenv (to allow selection of virtual python environments)
- pip

## Running Locally

### Clone the repo

```bash
git clone https://github.com/bristolhackspace/website.git

cd website
```

### Create example config file

This is a one-off config, if you already created the file you can skip this step.

```bash
mkdir instance
cd instance
cat << 'EOF' > config.toml
#Fake
MOSPARO_ENABLED = false
MOSPARO_HOST="localhost"
MOSPARO_PUBLIC_KEY="0x000"
MOSPARO_PRIVATE_KEY="0x001"
MOSPARO_UUID="12345"
SECRET_KEY='01234567890'
EOF
```

Verify the contents of the config.toml

```bash
cat config.toml
```

### Set virtual environment

Ensure you are in the project root and create a virtual environment.

Select a Python 3.11 version, first check what versions are installed:

```bash
pyenv versions
  system
  3.10.13
* 3.11.8 (set by /Users/username/.pyenv/version)
  3.12.2
```

Install a Python 3.11 version if one is not listed:

```bash
pyenv local 3.11.8
python --version
```

create the virtual environment:

```bash
python -m venv .venv

# Activate it (macOS/Linux)
source .venv/bin/activate

# or on Windows PowerShell
# .venv\Scripts\Activate.ps1

# Update pip
pip install --upgrade pip
```

### Install the project

From the project root:

```bash
pip install -r requirements.txt
```

### Configure Flask environment variables

```bash
# On macOS/Linux (bash/zsh)
export FLASK_APP=hackspace_website:create_app
export FLASK_ENV=development

# On Windows PowerShell
# $env:FLASK_APP = "hackspace_website:create_app"
# $env:FLASK_ENV = "development"
```

### Run the development server

Check you are in the root of the project.

```bash
flask run

 * Serving Flask app 'hackspace_website:create_app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://127.0.0.1:5000
```

With the server running, in a browser navigate to: http://127.0.0.1:5000


# Container!

### Clone the repo

```bash
git clone https://github.com/bristolhackspace/website.git

cd website
```

### Create example config file

This is a one-off config, if you already created the file you can skip this step.

```bash
mkdir instance
cd instance
cat << 'EOF' > config.toml
#Fake
MOSPARO_ENABLED = false
MOSPARO_HOST="localhost"
MOSPARO_PUBLIC_KEY="0x000"
MOSPARO_PRIVATE_KEY="0x001"
MOSPARO_UUID="12345"
SECRET_KEY='01234567890'
EOF
```

Verify the contents of the config.toml

```bash
cat config.toml
```

### Build the container and stand it up.

You can stand up the container with `podman-compose up --build`

Alternatively, build the container with `podman build . -t latest` and then follow the Quadlet instructions below to stand up the service containers.
```
cp -r .config ~
systemctl --user daemon-reload
systemctl --user start website.service
systemctl --user start nginx.service
systemctl --user status website.service nginx.service
```
And to kill those services and clean them up
```
systemctl --user stop website.service nginx.service
rm ~/.config/containers/systemd/website.service
rm ~/.config/containers/systemd/nginx.service
rm ~/.config/containers/systemd/nginx.network
systemctl --user daemon-reload
podman network prune
```

### SSL

you'll need ssl certs if you want to use ssl (and don't have them set up for your dev environment yet). I do NOT recommend using this in production - HS already has a working certificate process.
```
# Interactive
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365 -subj '/CN=localhost' -nodes

# Non-interactive and 10 years expiration
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname"
```
https://stackoverflow.com/questions/10175812/how-can-i-generate-a-self-signed-ssl-certificate-using-openssl

# Gunicorn

Started implementing gunicorn WSGI server for production use, as you don't want to be running flask as a production server (it tells you that itself!). 

Managed to get it running manually by going in to the podman-compose container with `podman exec -it website_website_1 sh` and running the command `gunicorn -w 4 'hackspace_website:create_app()' -b 0.0.0.0`. This was then able to be accessed both external to the container (on the host machine, if hte ports were open) and through nginx.

Tried updating the dockerfile with the new entrypoint, but not yet been able to get this to work.