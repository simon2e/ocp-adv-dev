

oc new-project pr-ocp-adv-dev-nexus --description="Shared Nexus" --display-name="Shared Nexus"

oc new-app sonatype/nexus3:latest

oc expose svc nexus3

oc rollout pause dc nexus3

oc patch dc nexus3 --patch='{ "spec": { "strategy": { "type": "Recreate" }}}'

oc set resources dc nexus3 --limits=memory=2Gi --requests=memory=1Gi

oc create -f pvc-nexus3.yml

oc set volume dc/nexus3 --add --overwrite --name=nexus3-volume-1 --mount-path=/nexus-data/ --type persistentVolumeClaim --claim-name=nexus-pvc

oc set probe dc/nexus3 --liveness --failure-threshold 3 --initial-delay-seconds 60 -- echo ok

oc set probe dc/nexus3 --readiness --failure-threshold 3 --initial-delay-seconds 60 --get-url=http://:8081/repository/maven-public/

oc rollout resume dc nexus3

curl -o setup_nexus3.sh -s https://raw.githubusercontent.com/wkulhanek/ocp_advanced_development_resources/master/nexus/setup_nexus3.sh

chmod +x setup_nexus3.sh

./setup_nexus3.sh admin admin123 http://$(oc get route nexus3 --template='{{ .spec.host }}')

rm setup_nexus3.sh

oc expose dc nexus3 --port=5000 --name=nexus-registry

oc create route edge nexus-registry --service=nexus-registry --port=5000

oc get routes -n pr-ocp-adv-dev-nexus


