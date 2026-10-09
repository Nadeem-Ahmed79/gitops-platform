package main

workload_kinds := {"Deployment", "Rollout"}

deny contains msg if {
	input.kind in workload_kinds
	some c in input.spec.template.spec.containers
	not c.resources.limits.memory
	msg := sprintf("%s/%s: container '%s' must set resources.limits.memory", [input.kind, input.metadata.name, c.name])
}

deny contains msg if {
	input.kind in workload_kinds
	not input.spec.template.spec.securityContext.runAsNonRoot == true
	msg := sprintf("%s/%s: pod must set securityContext.runAsNonRoot to true", [input.kind, input.metadata.name])
}

deny contains msg if {
	input.kind in workload_kinds
	some c in input.spec.template.spec.containers
	not c.securityContext.readOnlyRootFilesystem == true
	msg := sprintf("%s/%s: container '%s' must set readOnlyRootFilesystem to true", [input.kind, input.metadata.name, c.name])
}

deny contains msg if {
	input.kind in workload_kinds
	some c in input.spec.template.spec.containers
	endswith(c.image, ":latest")
	msg := sprintf("%s/%s: container '%s' must not use the :latest tag", [input.kind, input.metadata.name, c.name])
}
