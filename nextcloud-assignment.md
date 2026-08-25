# Instructions on how to complete the nextcloud on kubernetes assignment

### Start this assignment as soon as possible
*The more you wait, the more the server gets overloaded and prone to breaking*

## Step 1 - Create a tailscale account (if you dont have one already)

Go to the [Tailscale website](https://tailscale.com) and click on "Get started - i'ts free!".
Follow the account creation steps. It does not matter how you create your account. You could even use your personal email if you prefer.
When creating the account, it will prompt you to add your first machine, do not do that yet and just click on skip this step.

After that, go to the DNS page, which is under "Network" on the left side bar.
You can rename your tailnet there if you want. The names are randomly chosen - often are longer than just the default name.
At the botton of the page, click on "Enable HTTPS..." and then click on enable to confirm.

## Step 2 - Update your server

Open powershell (or Putty), and enter `ssh student@{ip} -p {port}` where {ip} is your server ip and {port} is your port. The default password is "changeme".
You will need to update the server and do a reboot to make sure everything works fine.
```sh
sudo pacman -Syu
sudo reboot # reboot could take up to 5 minutes
```
Also make sure the DNS works
```sh
ping google.ca # if the pings work you can continue
```
If the pings dont work, update your DNS server
```sh
echo "nameserver 9.9.9.9" > /etc/resolv.conf
```

## Step 3 - Connect your laptop and server to your tailnet

First, install tailscale on your laptop, or the device you will be using to access the server. You can install tailscale on as many devices as you want (the limit is 100 devices).

Now to install tailscale on your server.
You will need to create an Auth Key. This can be found under settings on the left side bar on the tailscale console.
Click on Generate auth key and the confirm the creation using the default settings. **Make sure to copy your auth key now as you wont be able to later**

Now, log in to your server. 
Open powershell (or Putty), and enter `ssh student@{ip} -p {port}` where {ip} is your server ip and {port} is your port. The default password is "changeme".
Once inside the server, create an alternate user account. This is used because often, the student account will just deny you entry to your server.
```sh
sudo -i # make sure to be root before running the following commands
useradd -m {name} # create the account with a home directory
passwd {name} # give the user a password for sudo and ssh access
echo "{user} ALL=(ALL:ALL) ALL" > /etc/sudoers.d/{user} # give that user sudo priviledges
passwd student # also dont forget to change the password for the student account
```
Now that you have created a user, you can install tailscale
```sh
pacman -S tailscale # assuming you are still root
sudo tailscale up --authkey={auth key} # paste in your auth key here
```
Verify that tailscale is installed and running
```sh
ip a s tailscale0 # make sure it has an ip
```
Also check your admin console in tailscale and you see both your laptop and the server. You can change the ipv4 address of either machine to make it easier to remember (or use the DNS name).
Log in to the server using tailscale from your laptop
```powershell
ssh {user}@{tailscale ip} # use the user you createed earlier from now on. You dont need to specify the port when using tailscale.
```
If you are able to log in, you can continue the assignment from home.
Finally, we must set up a tailscale funnel for nextcloud.
```sh
sudo tailscale funnel --bg http://127.0.0.1:11000 # on the server
```
This will allow us to access the nextcloud website from any device, even without tailscale.

## Step 4 - Create NFS storage

Now, we need to setup NFS storage. Install the NFS Utils package and enable the service.
You should do all the following steps as your own user and not root unless stated.
```sh
sudo pacman -S nfs-utils # install nfs utils
sudo systemctl enable --now nfs-server # enable and start the nfs server service
```
Next we must create the nfs directory and export it.
```sh
sudo mkdir -p /srv/nfs/nextcloud
sudo echo "/srv/nfs/nextcloud *(rw,async,no_subtree_check,no_root_squash,insecure,fsid=0)" > /etc/exports # or you could edit the file manually
sudo exportfs -rav
```

## Step 5 - Install K3S

For this step, we will need to install k3s from the AUR (Arch User Repository)
```sh
sudo pacman -S git fakeroot # install requirements
git clone https://aur.archlinux.org/k3s-bin.git && cd k3s-bin # clone the k3s repository from the AUR
makepkg -si # build k3s
```
And now enable the service.
```sh
sudo systemctl enable --now k3s
```

Now, wait for the node and containers to start before proceeding
```sh
sudo k3s kubectl get nodes # should have a status of Ready
sudo k3s kubectl get pods -A # should have 7 pods that have status of Running or 0/1 Completed
```
*It can take a bit for them to create.*

## Step 6 - Install Helm

Use pacman to install Helm
```sh
sudo pacman -S helm
```

Create some required directories
```sh
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
```

Now, install the NFS provisioner
```sh
helm repo add nfs-subdir https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-storage nfs-subdir/nfs-subdir-external-provisioner --set nfs.server=127.0.0.1 --set nfs.path=/srv/nfs/nextcloud
```

Wait until the pod says Running
```sh
sudo watch k3s kubectl get pods -A
```

Now, make NFS the default storageclass
```sh
sudo k3s kubectl patch storageclass nfs-client -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
sudo k3s kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

Verify that the change worked
```sh
sudo k3s kubectl get storageclass
```

## Step 7 - Install Nextcloud

Take note of you tailscale funnel
```sh
tailscale funnel status # you will need the DNS name
```

Now, download the values.yaml for nextcloud
```sh
wget https://raw.githubusercontent.com/nextcloud/all-in-one/main/nextcloud-aio-helm-chart/values.yaml
```

Edit the values.yaml and change all of the values that are marked with TODO. The APACHE_PORT must also be changed to 11000.
**Make sure none of your password contain `@` or `!`**
```sh
vim values.yaml
```
```yaml
DATABASE_PASSWORD:           # TODO! This needs to be a unique and good password!
EUROOFFICE_SECRET:           # TODO! This needs to be a unique and good password!
FULLTEXTSEARCH_PASSWORD:           # TODO! This needs to be a unique and good password!
HP_SHARED_KEY:           # TODO! This needs to be a unique and good password!
IMAGINARY_SECRET:           # TODO! This needs to be a unique and good password!
NC_DOMAIN: yourdomain.com          # TODO! Set this to the tailscale domain. Exclude the https:// it must be only the domain.
NEXTCLOUD_PASSWORD:           # TODO! This is the password of the initially created Nextcloud admin with username admin.
ONLYOFFICE_SECRET:           # TODO! This needs to be a unique and good password!
RECORDING_SECRET:           # TODO! This needs to be a unique and good password!
REDIS_PASSWORD:           # TODO! This needs to be a unique and good password!
SIGNALING_SECRET:           # TODO! This needs to be a unique and good password!
TALK_INTERNAL_SECRET:           # TODO! This needs to be a unique and good password!
TIMEZONE: America/Toronto          # TODO! This is the timezone that your containers will use.
TURN_SECRET:           # TODO! This needs to be a unique and good password!
WHITEBOARD_SECRET:           # TODO! This needs to be a unique and good password!

APACHE_PORT: 443
```

Next, add the Nextcloud repo
```sh
helm repo add nextcloud-aio https://nextcloud.github.io/all-in-one/
```
And install Nextcloud
```sh
helm install nextcloud-aio nextcloud-aio/nextcloud-aio-helm-chart -f values.yaml
```

This is the part that will take the longest. Sometimes it can take up to an hour.
Before waiting, you can make sure it is all working:
```sh
sudo k3s kubectl get pv # Check if container storage volumes were successfully assigned
sudo k3s kubectl get pods -A # Check status of all containers
sudo watch k3s kubectl get pods -A # Monitor status of all containers (press CTRL-C to exit)
sudo k3s kubectl logs -n default deployment/nextcloud-aio-nextcloud -f # Follow the logs of the nextcloud container (press CTRL-C to exit)
sudo k3s kubectl logs -n default deployment/nextcloud-aio-database -f # Follow the logs of the database container (press CTRL-C to exit)
sudo k3s kubectl logs -n default deployment/nextcloud-aio-apache --tail=50 # Dump the logs of the apache container
```
**Run these two commands right after deploying Nextcloud**
```sh
sudo k3s kubectl patch deployment nextcloud-aio-nextcloud -n default --type=json -p='[
  {"op": "remove", "path": "/spec/template/spec/containers/0/livenessProbe"}
]' # Patch the nextcloud container to stop kubernetes from killing it

sudo k3s kubectl patch deployment nextcloud-aio-database -n default --type=json -p='[
  {"op": "remove", "path": "/spec/template/spec/containers/0/livenessProbe"}
]' # Patch the database container to stop kubernetes from killing it
```
If the nextcloud container logs seem stuck at Initializing Nextcloud, dont touch anything it is just taking a long time and everything is working

The important one to look out for is the database container. If you get the error `FATAL: role "oc_nextcloud" does not exist` follow these steps:
```sh
helm uninstall nextcloud-aio # Delete Nextcloud helm deployment
sudo k3s kubectl delete pvc --all # Delete all pvc and pv
sudo systemctl disable --now k3s nfs-server # Stop the k3s and NFS service
sudo umount -f -l $(mount | grep nextcloud | awk '{print $3}') # Unmount any leftover mounts
sudo rm -rf /srv/nfs/nextcloud/* /srv/nfs/nextcloud/.* 2>/dev/null # Delete all NFS files
sudo systemctl enable --now k3s nfs-server # Re-enable k3s and NFS service
helm install nextcloud-aio nextcloud-aio/nextcloud-aio-helm-chart -f values.yaml # Reinstall Nextcloud AIO

# Re-patch deployments
sudo k3s kubectl patch deployment nextcloud-aio-nextcloud -n default --type=json -p='[
  {"op": "remove", "path": "/spec/template/spec/containers/0/livenessProbe"}
]'

sudo k3s kubectl patch deployment nextcloud-aio-database -n default --type=json -p='[
  {"op": "remove", "path": "/spec/template/spec/containers/0/livenessProbe"}
]'

```
Then wait again for the deployment to complete.

Once everything is working you can visit your tailscale funnel URL and you should be prompted to log in. The username is `admin` and the password is the password you set in values.yaml.

The server is extremely slow so if something seems to be loading for a long time its fine, just give it time.

Rebooting after everything is complete can take up to 10-15 minutes.
