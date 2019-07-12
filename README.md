# Mix&Match Infrastructure
A project to manage setting up the infrastructure to build, run, monitor, analyze, and
reproduce experiments.

**This is the code used to create the infrastructure to run experiments associated with our Mix&Match paper:**
- Here's the associated code to run experiments: https://github.com/matthewfaw/mixnmatch
- Here's a link to the paper: <INSERT-LINK-HERE>
  
_Please cite the above paper if this code is used in any publication._
  
## How-To

More specifically, this project is used to setup a Kubernetes cluster
running on Google Cloud that uses:
- Jenkins to build the experiment code
- Kubeflow to easily tune hyperparameters in parallel using Katib
- The Kubernetes Dashboard to interact with the cluster in an easy way
- Grafana/Prometheus to provide fine-grained memory usage monitoring

The project assumes that the following environment variables are set:
- `JENKINS_ADMIN_PW`: The base64 encoded password you'd like to use for Jenkins (user is `admin`)
- `GRAFANA_ADMIN_PW`: The base64 encoded password you'd like to use for Grafana (user is `admin`)
- `JENKINS_BACKUP_BUCKET`: The Google cloud storage bucket where Jenkins backups will be placed/already exist. e.g. `gs://derp/backups`
- `GKE_CLUSTER_NAME`: The desired name of the GKE cluster that will be created
- `GCLOUD_DATASET_BUCKET_BASE`: The base bucket name where experiment datasets/results are stored
- `GIT_REPO_SSH`: The git repo ssh e.g. `git@github.com:{username}/{project}.git`
- `GIT_BRANCH`: The git branch to pull from

If these environment variables aren't set, random ones will be generated and stored as k8s secrets.

In order to set up the environment, run the following command:

`./setup.sh <GCLOUD_SVC_ACCOUNT_FILE> <KAGGLE_CREDS_FILE> <GIT_PRIVATE_CREDS_FILE> <GIT_KNOWN_HOSTS_FILE> <EXISTING_JENKINS_PVC>`

where each of the arguments correspond to:
- `<GCLOUD_SVC_ACCOUNT_FILE>`: The path the gcloud service account file which has read/write permissions to google cloud storage and google container service
- `<KAGGLE_CREDS_FILE>`: The path to the Kaggle credientials file with access to all datasets you'd like to download
- `<GIT_PRIVATE_CREDS_FILE>`: The path to the git private credentials file with access to the Github account you'd like to use
- `<GIT_KNOWN_HOSTS_FILE>`: The path to the corresponding git known hosts file
- `<EXISTING_JENKINS_PVC>`: The name of the existing jenkins persistent volume claim, if one exists. Leave blank if you'd like to create a new one

To open the k8s dashboard, run:

`./open_dashboard.sh`

To get a token to open the k8s dashboard, run:

`./get_dashboard_token.sh`

and the token can then be pasted into the login page.

To setup a jupyter deployment with the experiment data, run

`./setup_jupyter.sh <DATASET_ID> <EXPERIMENT_ID>`

and the jupyter notebook with the associated data will be available by running:

`kubectl port-forward svc/jupyter-notebook-<DATASET_ID> 8988`

and opening `localhost:8988` in a web browser.

## License

**This project is licensed under the terms of the Apache 2.0 License.**
