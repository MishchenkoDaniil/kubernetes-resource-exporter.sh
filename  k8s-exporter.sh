NS=$(kubectl get ns -A -o jsonpath='{.items[*].metadata.name}' | tr -s ' ' '\n')

for NAMESPACE in $NS
do
  APP_NAMES=$(kubectl get -n $NAMESPACE svc,deployment,hpa,statefulset -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | sort | uniq)

  for APP_NAME in $APP_NAMES
  do
    # Retrieve YAML definitions for the Ingress, Service, and Deployment objects for the current application
    INGRESS_YAML=$(kubectl get -n $NAMESPACE ingress $APP_NAME -o yaml | sed '/resourceVersion:/d; /uid:/d; /creationTimestamp:/d; /generation:/d; /deployment.kubernetes.io\/revision:/d; /annotations:\n *kubectl.kubernetes.io\/restartedAt:/d; /securityContext: {}/d;' | sed '/annotations:/{N; /meta.helm.sh\/release-name:/d; /meta.helm.sh\/release-namespace:/d;};' | awk '/apiVersion:/{print "---";}{print}'| sed '/status:/{N;N;N;d;}' | sed '/autoscaling.alpha.kubernetes.io\/behavior:/, /autoscaling.alpha.kubernetes.io\/metrics:/d')

    SERVICE_YAML=$(kubectl get -n $NAMESPACE svc $APP_NAME -o yaml | sed '/protocol:/d; /nodePort:/d; /terminationMessagePath: \/dev\/termination-log/,+1d; /terminationMessagePolicy:/d; /^ *progressDeadlineSeconds:/d; /^ *revisionHistoryLimit:/d; /strategy:/,/^$/d; /externalTrafficPolicy:/d; /internalTrafficPolicy:/d; /ipFamilies:/,+1d; /ipFamilyPolicy:/d; /resourceVersion:/d; /clusterIPs:/,+1d; /clusterIP:/d; /sessionAffinity:/d; /uid:/d; /creationTimestamp:/d; /generation:/d; /deployment.kubernetes.io\/revision:/d; /annotations:\n *kubectl.kubernetes.io\/restartedAt:/d; /securityContext: {}/d;' | sed '/annotations:/{N; /meta.helm.sh\/release-name:/d; /meta.helm.sh\/release-namespace:/d;};' | awk '/apiVersion:/{print "---";}{print}'| sed '/status:/{N;N;N;d;}' | sed '/autoscaling.alpha.kubernetes.io\/behavior:/, /autoscaling.alpha.kubernetes.io\/metrics:/d')

    DEPLOYMENT_YAML=$(kubectl get -n $NAMESPACE deployment $APP_NAME -o yaml | sed '/dnsPolicy:/d; /restartPolicy:/d; /schedulerName:/d; /serviceAccount:/d; /serviceAccountName:/d; /terminationGracePeriodSeconds:/d; /type:/d; /observedGeneration:/d; /readyReplicas:/d; /^ *revisionHistoryLimit:/d; /^ *progressDeadlineSeconds:/d; /terminationMessagePath: \/dev\/termination-log/,+1d; /terminationMessagePolicy:/d; /lastUpdateTime:/,+2d; /message:/d; /reason:/d; /message:/d; /reason:/d; /replicas:/d; /updatedReplicas:/d; /resourceVersion:/d; /uid:/d; /creationTimestamp:/d; /generation:/d; /deployment.kubernetes.io\/revision:/d; /annotations:\n *kubectl.kubernetes.io\/restartedAt:/d; /securityContext: {}/d;' | sed '/annotations:/{N; /meta.helm.sh\/release-name:/d; /meta.helm.sh\/release-namespace:/d;};' | awk '/apiVersion:/{print "---";}{print}'| sed '/status:/{N;N;N;d;}' | sed '/autoscaling.alpha.kubernetes.io\/behavior:/, /autoscaling.alpha.kubernetes.io\/metrics:/d')
    
    HPA_YAML=$(kubectl get -n $NAMESPACE hpa $APP_NAME -o yaml | sed '/lastScaleTime:/d; /resourceVersion:/d; /uid:/d; /creationTimestamp:/d; /generation:/d; /deployment.kubernetes.io\/revision:/d; /annotations:\n *kubectl.kubernetes.io\/restartedAt:/d; /securityContext: {}/d; /annotations:/{N; /meta.helm.sh\/release-name:/d; /meta.helm.sh\/release-namespace:/d;};' | awk '/apiVersion:/{print "---";}{print}'| sed '/status:/{N;N;N;d;};' | sed '/autoscaling.alpha.kubernetes.io\/behavior:/, /autoscaling.alpha.kubernetes.io\/metrics:/d; ')
    
    STATEFULSET_YAML=$(kubectl get -n $NAMESPACE statefulset $APP_NAME -o yaml | sed '/dnsPolicy:/d; /restartPolicy:/d; /schedulerName:/d; /serviceAccount:/d; /serviceAccountName:/d; /terminationGracePeriodSeconds:/d; /type:/d; /observedGeneration:/d; /readyReplicas:/d; /^ *revisionHistoryLimit:/d; /^ *progressDeadlineSeconds:/d; /terminationMessagePath: \/dev\/termination-log/,+1d; /terminationMessagePolicy:/d; /lastUpdateTime:/,+2d; /message:/d; /reason:/d; /message:/d; /reason:/d; /replicas:/d; /updatedReplicas:/d; /resourceVersion:/d; /uid:/d; /creationTimestamp:/d; /generation:/d; /deployment.kubernetes.io\/revision:/d; /annotations:\n *kubectl.kubernetes.io\/restartedAt:/d; /securityContext: {}/d;' | sed '/annotations:/{N; /meta.helm.sh\/release-name:/d; /meta.helm.sh\/release-namespace:/d;};' | awk '/apiVersion:/{print "---";}{print}'| sed '/status:/{N;N;N;d;}' | sed '/autoscaling.alpha.kubernetes.io\/behavior:/, /autoscaling.alpha.kubernetes.io\/metrics:/d')
    
    # # create directory for the current application
    # mkdir -p $NAMESPACE/$APP_NAME

    # # write YAML definitions for the Ingress, Service, Deployment, HPA, and StatefulSet objects to a file in the application directory
    # echo "$INGRESS_YAML" > $NAMESPACE/$APP_NAME/ingress.yaml
    # echo "$SERVICE_YAML" > $NAMESPACE/$APP_NAME/service.yaml
    # echo "$DEPLOYMENT_YAML" > $NAMESPACE/$APP_NAME/deployment.yaml
    # echo "$HPA_YAML" > $NAMESPACE/$APP_NAME/hpa_temp.yaml | sed '/scaleTargetRef:/,/---/ {/---/d;}' $NAMESPACE/$APP_NAME/hpa_temp.yaml > $NAMESPACE/$APP_NAME/hpa.yaml && rm $NAMESPACE/$APP_NAME/hpa_temp.yaml
    # echo "$STATEFULSET_YAML" > $NAMESPACE/$APP_NAME/statefulset.yaml

    # Output all YAML definitions for the current application to a single file
    # echo "$INGRESS_YAML" >> "$NAMESPACE-$APP_NAME-temp.yaml"
    echo "$SERVICE_YAML" >> "$NAMESPACE-$APP_NAME-temp.yaml"
    echo "$DEPLOYMENT_YAML" >> "$NAMESPACE-$APP_NAME-temp.yaml"
    echo "$HPA_YAML" >> "$NAMESPACE-$APP_NAME-temp.yaml"
    echo "$STATEFULSET_YAML" >> "$NAMESPACE-$APP_NAME-temp.yaml"
    sed '/scaleTargetRef:/,/---/ {/---/d;}' "$NAMESPACE-$APP_NAME-temp.yaml" > "$NAMESPACE-$APP_NAME.yaml" && rm $NAMESPACE-$APP_NAME-temp.yaml

  done
done
