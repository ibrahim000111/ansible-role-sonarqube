# Sonar Config

If you need to...
- Build a new AMI image, go for Packer section
- Test a new image build locally (before deploying to AWS), go for Vagrant section
- Change Sonar configuration before testing locally, go for Sonar configuration section
- Change how to OS behaves, go for Ansible section 
- Deploy a new instance of Sonar >> Go for Deploying a new Sonar

### Sonar configuration files

The ansible roles listed below will configure Sonar. The plugins this Sonar uses can be found at: <code>ansible_config/roles/ansible-role-sonar/defaults/main.yml</code>.

## Other tools - how this repository works

### Packer

Packer is a tool to create an image (AMI on AWS)

IMPORTANT! Make sure following line on file <code>ansible_config/roles/ansible-role-sonar/default/main.yml</code> is like this before creating your new image with Packer. Using 0.0.0.0 is only for personal testing:
> sonar_web_host: 127.0.0.1

Running packer:
1. <code>packer build -var AWS_VARS_HERE packer_config.json</code>

Checkout the file <code>packer_config.json</code> to see how packer will create your SO image and AWS instructions for it


### Ansible

Ansible is a tool to configure our OS as we want it to be.

You can run ansible with: <code>ansible playbook site.yml</code>. See examples at <code>Vagrantfile</code> and <code>packer_config.json</code>

The main file for this folder is <code>ansible_config/site.yml</code>. This file calls all the roles in "roles" folder

#### Ansible roles:

The roles folder has the Ansible configuration for:
1. Add Java PPA
2. Role - Install Java JDK 8
3. Role - Install Sonar (with plugins)
4. Role - Install HAProxy to handle the server TLS

### Vagrant - build your Sonar image locally

Vagrantfile is used to local tests only. This is a pre-step before creating the image on AWS with Packer

IMPORTANT! For you new Vagrant image to work locally, go to file <code>ansible_config/roles/ansible-role-sonar/default/main.yml</code> and change the following line to be:
> sonar_web_host: 0.0.0.0

#### Vagrant commands:

- Have vagrant installed (like sudo apt install vagrant) and Oracle's VirtualBox

- How to run: navigate to root of this repo and run <code>sudo vagrant up</code>. After everything is complete, it will create a Sonar acessible from your host machine at <code>localhost:5555</code> and <code>localhost:6666</code>

This will create a virtual machine and will install everything listed on the Vagrantfile

- How to SSH into the created machine: run <code>sudo vagrant ssh</code>

- How to destroy the VM: run <code>sudo vagrant destroy</code>


## Redeploying Sonar - activating TLS (https) and SSO afterwards

Once you need to change configurations and deploy a new Sonar instance, you should:

1. Test your configurations manually. Once everything is set
2. Apply your configurations the same way you did manually but now using Ansible and its roles
3. Test it locally using Vagrant. Once everything is set
4. Use packer to build your new image at AWS
5. Create a new VM pointing to your external IP

### Once you have your machine up and running, connect through SSH to perform the last manual steps: TLS and SSO Google authentication:

1. Generate the .pem certificate file with <code>cat cert1.pem privkey1.pem > fullkey.pem</code>. Remember to remove the empty row that is kept inside the generated fullkey.pem between the two certificates. To look at the file use <code>cat fullkey.pem</code>
2. Move the generated file to folder <code>/home/ubuntu/sonar/</code>
3. Restart HAProxy with <code>sudo service haproxy restart</code>

You'll only have to perform the following tasks if you have changed the database on the backend. All the data is stored in the database.
4. Log in to jenkins using regular admin credentials. Go to "Administration" > "Configuration" > "Security". And fill in the following information (like in the image below):
> * Enabled = true
> * OAuth Client ID = your-Google-generated-URL.apps.googleusercontent.com
> * OAuth Client Secret = googleS3cr3t
> * Allowed domain = mysonar.com
> * Force user authentication: true

5. Save. Then Logout from the admin user, and login once again with your regular @mysonar.com user

#### Troubleshooting redeployment:

1. Do not forget to keep <code>?sslmode=require&gssEncMode=disable</code> in the end of your connection string when passing the parameter to Ansible on Vagrantfile or packerfile. It's important to avoid a bug between Sonar 8.5+ and Azure Postgres Services