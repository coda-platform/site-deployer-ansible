# deploy-scripts

Deployment scripts for the different CODA components.

## Bootstrap

All below steps must be run as «root» by using `sudo su -`.

### Install package dependencies

Ensure `curl` is installed:

```bash
yum install -y curl
```

### Export proxy

If current host doesn't have direct internet access and needs to use a proxy, simply
adjust PROXY variable and export:

```bash
export PROXY=http://<hostname>:<port>

export HTTP_PROXY=${PROXY}
export HTTPS_PROXY=${PROXY}
export http_proxy=${PROXY}
export https_proxy=${PROXY}
```

Also, ensure that the following URL is whitelisted in your proxy server:
-  https://license.aidbox.app

### Bootstrapping

Download the bootstrap script and execute it:

```bash
curl -s https://raw.githubusercontent.com/coda-platform/site-deployer-ansible/main/scripts/bootstrap.sh \
     -o bootstrap.sh

bash bootstrap.sh
```

At the end, you'll be asked a few questions necessary to complete the bootstrap process:

- Your SITE ID, provided by CODA
- Your VAULT PASSWORD, provided by CODA
- Proxy server, only if needed for bootstrapping process.
