local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components.glab;

local cortex = import 'cortex/cortex/cortex.libsonnet';
local util = import 'cortex/cortex/util.libsonnet';
local k = import 'k.libsonnet';
local container = k.apps.v1beta1.deployment.mixin.spec.template.spec.containersType;
local port = container.portsType;

local image = params.imageBase + params.cortexComponent + ':' + params.imageTag;

local imagePullSecrets =
  if std.objectHas(params, 'imagePullSecrets') then params.imagePullSecrets else [];

local labels = {
  system: params.system,
  name: params.name,
};

local svcContainer =
  container.new(params.name, image)
  .withPorts([
    port.new(params.restPort),
  ])
  .withArgs([
    '-rest.port=' + params.restPort,
  ])
  .withEnv([
    util.envVar.plain('JAEGER_AGENT_HOST', 'localhost'),
  ])
  + container.mixin.resources.withRequests({ cpu: '100m', memory: '250Mi' })
  + util.probe.httpGet(type='readiness', period=5, timeout=2, delay=10, success=1, failure=3, path='/health', port=params.restPort, scheme='HTTP')
  + util.probe.httpGet(type='liveness', period=5, timeout=2, delay=10, success=1, failure=3, path='/health', port=params.restPort, scheme='HTTP');

k.core.v1.list.new([
  cortex.parts.service(params.name, labels, params.restPort),
  cortex.parts.deployment(params.name, labels, params.replicas, [svcContainer, util.jaegerContainer], imagePullSecrets),
])
