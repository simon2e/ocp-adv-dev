

oc new-project pr-ocp-adv-dev-gogs --description="Shared Gogs" --display-name="Shared Gogs"

oc new-app postgresql-persistent --param POSTGRESQL_DATABASE=gogs --param POSTGRESQL_USER=gogs --param POSTGRESQL_PASSWORD=gogs --param VOLUME_CAPACITY=4Gi -lapp=postgresql_gogs

oc new-app wkulhanek/gogs:11.34 -lapp=gogs

oc create -f pvc-gogs.yml

oc set volume dc/gogs --add --overwrite --name=gogs-volume-1 --mount-path=/data/ --type persistentVolumeClaim --claim-name=gogs-data

oc expose svc gogs

oc get route gogs

http://gogs-pr-ocp-adv-dev-gogs.apps.na37.openshift.opentlc.com


oc exec $(oc get pod | grep "^gogs" | awk '{print $1}') -- cat /opt/gogs/custom/conf/app.ini >$HOME/app.ini

oc create configmap gogs --from-file=$HOME/app.ini

oc set volume dc/gogs --add --overwrite --name=config-volume -m /opt/gogs/custom/conf/ -t configmap --configmap-name=gogs


