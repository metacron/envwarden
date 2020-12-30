![](https://raw.githubusercontent.com/metacron/envwarden/master/assets/icon-left-font-narrow.png "envwarden")

# ${envwarden}
Manage your server secrets with [Bitwarden](https://bitwarden.com/)

## How?

Get your secure environment variables from Bitwarden onto your server.

`envwarden` searches your Bitwarden vault for items matching
a search criteria (defaults to 'envwarden').
Then it goes through all custom fields on every item found
and make them available as envirnoment variables.

## Fork

This fork aims to build a GitHub Action container image to pull secrets from Bitwarden.

### Install with Docker

* `docker pull ghcr.io/metacron/envwarden:latest`

## Usage

### Adding secrets to Bitwarden

![](https://raw.githubusercontent.com/metacron/envwarden/master/assets/bitwarden-item-screenshot.png "bitwarden item for envwarden")

* Filter by organization id and collection id
* Add custom fields for each secure environment variable you need
  (fields can be text, hidden or boolean)
* **If any of your secure notes have _ character, it'll be considered an environment var and its contents will be set as value**
* You can add as many fields as you need, and you can also create
  multiple items, as long as they match the same search term
  (their secrets would be combined)
* You can also copy attachments on the searched items to a destination folder
* You should use separate logins for each environment, and ideally limit server
  access to only the secrets it needs, but it's up to you how to manage it

### Getting secrets onto your workflow

```yaml
jobs:

  my_job:
  
  steps:

    - name: Load secrets using envwarden (Bitwarden as sensitive-data vault)
      uses: docker://ghcr.io/metacron/envwarden:unstable
      id: vars
      timeout-minutes: 30
      env:
        # Bitwarden API key
        BW_CLIENTID: ${{ secrets.BW_CLIENTID }}
        BW_CLIENTSECRET: ${{ secrets.BW_CLIENTSECRET }}

        # Master password to unlock vault
        BW_PASSWORD: ${{ secrets.BW_PASSWORD }}

        # Organization ID filter
        BW_ORGANIZATIONID: ${{ secrets.BW_ORGANIZATIONID }}
        # Collection ID filter (you can use one collection for each environment)
        BW_COLLECTIONID: ${{ secrets.BW_PRODUCTION_COLLECTION_ID }}

    - name: Generate configuration files
      shell: bash
      env:
        GCP_JSON_CREDENTIALS: ${{ steps.vars.outputs.GCP_JSON_CREDENTIALS }}
      run: |
        echo "$GCP_JSON_CREDENTIALS" > gcp_credentials.json
```

### Running with Docker

You can provide your Bitwarden username and password using three methods:

```bash
# 1. Passing as environment to Docker
docker run --rm -it \
  -e BW_CLIENTID="" \
  -e BW_CLIENTSECRET="" \
  -e BW_PASSWORD="" \
  -e BW_ORGANIZATIONID="" \
  -e BW_COLLECTIONID="" \
  envwarden:latest /bin/sh

# 2. Interact with envwarden
envwarden -h
```

### Importing secrets to Kubernetes

[with just 3 lines of bash](https://blog.gingerlime.com/2019/envwarden-and-kubernetes-secrets/)

## Notes

`envwarden` is a very simple bash script that wraps around the `bw` CLI. You can inspect it to make sure it's secure and
doesn't leak your secrets in any way. I tried to keep it as simple as possible, and also secure.

`eval` is generally dangerous to run, but the script makes an effort to protect against command injection.
`--dotenv` might be a slightly safer option if your application can work with `.env` files. Besides that, if you're
worried about command injection from people who have write access to your secrets, you might have bigger problems to
worry about, and perhaps `envwarden` isn't for you :)

`envwarden` would login and sync on every invocation. This isn't the fastest, but ideally you only need to run this when
you bootstrap a new system, when you deploy, or when you need to refresh your secrets (in all cases, it probably makes
sense to fetch the fresh secrets anyway).

`envwarden` is still experimental. Please use at your own risk. Feedback is welcome.

`envwarden` is not affiliated or connected to Bitwarden or its creators 8bit Solutions LLC in any way.
