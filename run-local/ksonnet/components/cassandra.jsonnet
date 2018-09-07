local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components.cassandra;

std.prune(std.native("renderHelmChart")(
   // registry name
   "helm-incubator",
   // chart name
   "cassandra",
   // chart version
   params.version,
   // chart values overrides
   params.values,
   // component name
   params.name,
 ))
