# Setting up artifact repository


Enabling apis:

```
gcloud services enable artifactregistry.googleapis.com
```

## Auth

There are different ways to authenticate, but here I will talk about two strategies: impersonation and service account.

For details see:
https://cloud.google.com/artifact-registry/docs/docker/authentication


1. Impersonation is good for local development, it creates temporal auth tokens that will expire after a TTL time. 
2. Service Account implies a key that will never expire. 

For any case first a service account with proper [artifact roles](https://cloud.google.com/artifact-registry/docs/access-control) is needed.

The most important for us are:
- roles/artifactregistry.reader (for platform)
- roles/artifactregistry.writer (for platform, and ci/cd)
- roles/artifactregistry.repoAdmin (for users)

List services accounts (optional)
```
gcloud iam service-accounts list
```
Create [service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts#iam-service-accounts-create-gcloud)
```
gcloud iam service-accounts create SERVICE_ACCOUNT_ID
    --description="Artifact creator" \
    --display-name="artifact-creator"
```

Add roles:
```
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:SERVICE_ACCOUNT_ID@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.writer"
```

### 1. Impersonation

Firts of all, the user who perform the impersonation will need the role of `roles/iam.serviceAccountTokenCreator`

```
gcloud projects add-iam-policy-binding PROJECTID --member user:USER --role roles/iam.serviceAccountTokenCreator
```

Then impersonate

```
gcloud auth print-access-token \
    --impersonate-service-account ACCOUNT | docker login \
    -u oauth2accesstoken \
    --password-stdin https://LOCATION-docker.pkg.dev
```

To list repositories available:
```
gcloud artifacts repositories list
```

### 2. Service Account

Follow like https://cloud.google.com/artifact-registry/docs/docker/authentication#json-key

```
cat KEY-FILE | docker login -u KEY-TYPE --password-stdin \
		https://LOCATION-docker.pkg.dev
```

KEY-TYPE depends of format of the account key:
	- `_json_key` if you are using the service account key in JSON format as it was provided when you created the file.
  - `_json_key_base64` if you base64-encoded the all contents of the file.

Optional encoding key file as base64:

```
base64 FILE-NAME > NEW-FILE-NAME
```




