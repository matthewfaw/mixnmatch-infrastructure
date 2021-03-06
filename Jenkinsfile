def label = "slave-${UUID.randomUUID().toString()}"

podTemplate(label: label, yaml:"""
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: gcloud
    image: google/cloud-sdk:latest
    imagePullPolicy: Always
    command:
    - sh
    - -c
    - |
        gcloud auth activate-service-account --key-file=/certs/svc_account.json
        gcloud auth configure-docker -q
        while true; do
            sleep 10
        done
    tty: true
    volumeMounts:
    - name: certs
      mountPath: "/certs"
      readOnly: true
    - name: dockersock
      mountPath: "/var/run/docker.sock"
  volumes:
  - name: certs
    secret:
      secretName: gcloud-creds
  - name: dockersock
    hostPath:
      path: /var/run/docker.sock
""") {
  node(label) {
    stage("Checkout code") {
        checkout scm
        commit = sh(returnStdout: true, script: 'git rev-parse HEAD')
        commit = commit.take(7)
        sh("echo ${commit}")
    }
    stage('Dummy step') {
        sh("echo ${env.BUILD_NUMBER}")
    }
  }
}
