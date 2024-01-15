gcloud auth activate-service-account --key-file=credentials.json
$myJson = Get-Content ./.env/credentials.json -Raw | ConvertFrom-Json
$client_email = $myJson.client_email
$project_id = $myJson.project_id
gcloud config set account $client_email
gcloud components install gke-gcloud-auth-plugin
gcloud container clusters get-credentials evershop-cluster --project $project_id --region europe-west1
kubectl apply -f ./kubernetes/secrets.yaml
kubectl create secret generic cloudsql-instance-credentials --from-file=./.env/credentials.json
$deploymentFile = Get-Content ./kubernetes/deployment.yaml -Raw
$deploymentFileModified = $deploymentFile -replace '<PROJECT_ID>', $project_id
$deploymentFileModified | Set-Content ./kubernetes/deployment-temp.yaml
kubectl apply -f ./kubernetes/deployment-temp.yaml
kubectl apply -f ./kubernetes/service.yaml
Remove-Item ./kubernetes/deployment-temp.yaml
