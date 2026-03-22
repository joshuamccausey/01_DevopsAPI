# DevopsAPI Project

## OVERVIEW
I am writing this application to primarily practice the skills required to be a devops engineer. The goal will be to write a simply API in Python that you can interact with through the CLI.

## REQUIREMENTS
This API will be stateless so no database is required. I am not concerned about overall efficency and am moreso thinking about the pieces of the application as a whole and how they fit together.
The following tools will be utilized (subject to change at time of writing).
- Docker for containerization
- Git for version management
- AWS for hosting
- Terraform for IaC
- Github Actions for CI/CD
- Gunicorn for request hanlding
- FastAPI for backend logic (Was Django, see UPDATE 03-01-26 7:58AM)
- Custom code for API application

## UPDATES
This file is being written on 03-01-2026. I am adding this section because as this is primaryily a learning project, I want an area to update my goals and requirements so that I can track my improvment in understanding.

### 03-03-26 UPDATE
I have my main.py code running as expected. It utilizes the API provided by openweathermap.org and collects the client zip through the GET reqest /current_weather/{location} and then returns a string including the average temp in F and the general description of conditions.
APIs in use:
https://openweathermap.org/api/geocoding-api?collection=other
https://openweathermap.org/current?collection=current_forecast

### 03-09-26 UPDATE
I have completed my dockerfile that properly packages my source code along with dependancies. The image has been built and uploaded to my private docker repository but can be run using "docker run -d -p 8080:8000 joshuamccausey/01_devopsapi". This will open up port 8080 on the host VM and send the traffic to the container. I just tested this and it ran successfully. I was able to send a GET request using "curl {HOST-IP}:8080/current_weather/{zip}

### 03-12-26 UPDATE
Today, I was able to finish my Terraform code to setup the required networking infrastructure. I have setup a VPC, subnet, gateway, and routing table to allow the EC2 VM to access the internet and have whitelisted access to my personal IP address. I whitelisted inbound for port 22 (SSH) as well as port 8000 (FastAPI listening port). Once that was all completed, I was able to generate an SSH key using ssh_key_pair and get it assigned to my EC2 VM through the terraform code. This allowed me to SSH into the VM, install Docker, generate another SSH key which I could use to authenticate with my Github account and make the code pull. I then built the docker image for the project, ran it using "docker run -d -p 8000:8000 01_devopsapi_prod" and then was able to make API calls to the docker container from my home IP. At this point, the only piece I have integrated would be CI/CD using GitHub Actions.

### 03-22-26 UPDATE
As of this morning, this project is officially completed. Now, upon new git push actions into the main branch, the Workflow file will get read (ci_cd.yml) and then GitHub will do the following:
- Spin up Ubuntu VM to run the workflow file on
- Connect to AWS and setup a SSH key to push into the EC2 instance later
- Delete exisiting infra
- Spin up new infra including EC2 instance with SSH key pushed into the environment
    - The Terraform code does most of the work here including installing Docker and Github into the production VM
- SSH into EC2 instance
- Clone GitHub repository
- Build docker image
- Run docker image
- Print docker logs
All key's within this environemnt including AWS, SSH, etc are stored within GitHub as secrets and then called upon through the workflow file.