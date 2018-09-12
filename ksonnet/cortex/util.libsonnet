local k = import 'k.libsonnet';
local container = k.apps.v1beta1.deployment.mixin.spec.template.spec.containersType;
local port = container.portsType;

local jaeger =
  container.new('jaeger-agent', 'jaegertracing/jaeger-agent')
  .withCommand([
    '/go/bin/agent-linux',
    '--collector.host-port=jaeger-collector.default.svc:14267',
  ])
  .withPorts([
    port.newNamed(5775, 'j0-noscrape').withProtocol('UDP'),
    port.newNamed(5778, 'j1-noscrape').withProtocol('TCP'),
    port.newNamed(6831, 'j2-noscrape').withProtocol('UDP'),
    port.newNamed(6832, 'j3-noscrape').withProtocol('UDP'),
  ])
  .withImagePullPolicy('Always');

{
  jaegerContainer:: jaeger,
  probe:: {
    httpGet(type='readiness', period=5, timeout=2, delay=3, success=1, failure=3, path='/', port=80, scheme='HTTP')::
      if type == 'readiness' then
        { readinessProbe: $.probe.internals(period, timeout, delay, success, failure) + $.probe.withHTTPGet(path, port, scheme) }
      else
        { livenessProbe: $.probe.internals(period, timeout, delay, success, failure) + $.probe.withHTTPGet(path, port, scheme) },
    internals(period, timeout, delay, success, failure):: {
      periodSeconds: period,
      timeoutSeconds: timeout,
      initialDelaySeconds: delay,
      successThreshold: success,
      failureThreshold: failure,
    },
    withHTTPGet(path='/', port=80, scheme='HTTPS')::
      {
        httpGet: {
          path: path,
          port: port,
          scheme: scheme,
        },
      },
  },
  envVar:: {
    fromSecret(name, secretName, secretKey): {
      name: name,
      valueFrom: {
        secretKeyRef: { name: secretName, key: secretKey },
      },
    },
    plain(name, value): {
      name: name,
      value: value,
    },
  },
}
