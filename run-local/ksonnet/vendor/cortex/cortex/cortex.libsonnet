local k = import 'k.libsonnet';
local service = k.core.v1.service;
local servicePort = k.core.v1.service.mixin.spec.portsType;
local deployment = k.apps.v1beta1.deployment;

{
  parts:: {
    service(name, labels, restPort=3000, grpcPort=9095)::
      service.new(
        name, labels, [
          servicePort.new(restPort, restPort).withName('rest'),
        ]
      ) + service.mixin.metadata.withLabels(labels),
    deployment(name, labels, replicas, containers, imagePullSecrets=[])::
      deployment.new(
        name,
        replicas,
        containers,
        labels
      )
      + deployment.mixin.spec.template.metadata.withAnnotations({
        'prometheus.io/scrape': 'true',
      })
      + deployment.mixin.metadata.withLabels(labels)
      + deployment.mixin.spec.selector.withMatchLabels(labels)
      + deployment.mixin.spec.strategy.withType('RollingUpdate')
      + deployment.mixin.spec.strategy.rollingUpdate.withMaxSurge(1)
      + deployment.mixin.spec.strategy.rollingUpdate.withMaxUnavailable(1)
      + deployment.mixin.spec.template.spec.withImagePullSecrets(imagePullSecrets),
  },
}
