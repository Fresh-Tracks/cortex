// @apiVersion 0.0.1
// @name cortex.pkg.ingester
// @description Deploys a Cortex Ingester into your K8s environment
// @shortDescription Cortex cluster deployment
// @param name string Name to give to each of the components
// @param imageBase string Base of the image name such as 'quay.io/weaveworks/cortex-ingester'
// @param imageTag string Tag of the image to be used, such as '4728ec9' or 'latest'
// @optionalParam replicas number 1 Number of replicas to use
// @optionalParam restPort number 8080 Port to run the rest api on
// @optionalParam system string cortex System label to apply to each component

local cortex = import 'cortex-registry/cortex-pkg/cortex.libsonnet';
local util = import 'cortex-registry/cortex-pkg/cortex.libsonnet';
local k = import 'k.libsonnet';
local container = k.apps.v1beta1.deployment.mixin.spec.template.spec.containersType;
local port = container.portsType;

local imagePullSecrets =
  if std.objectHas(params, 'imagePullSecrets') then params.imagePullSecrets else [];

local labels = {
  system: params.system,
  name: params.name,
};

local svcContainer =
  container.new(params.name, params.image + ':' + params.imageTag)
  .withPorts([
    port.new(params.restPort),
    port.new(params.grpcPort),
  ])
  .withArgs([
    '-rest.port=' + params.restPort,
  ])
  .withEnv([
    ft.envVar.plain('JAEGER_AGENT_HOST', 'localhost'),
  ])
  + container.mixin.resources.withRequests({ cpu: '100m', memory: '250Mi' })
  + ft.probe.httpGet(type='readiness', period=5, timeout=2, delay=10, success=1, failure=3, path='/health', port=params.restPort, scheme='HTTP')
  + ft.probe.httpGet(type='liveness', period=5, timeout=2, delay=10, success=1, failure=3, path='/health', port=params.restPort, scheme='HTTP');

k.core.v1.list.new([
  cortex.parts.service(params.name, labels, params.restPort, params.grpcPort),
  cortex.parts.deployment(params.name, labels, params.replicas, [svcContainer, ft.jaegerContainer], imagePullSecrets),
])
