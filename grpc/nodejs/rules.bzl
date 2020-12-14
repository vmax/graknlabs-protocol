def _ts_proto_compile_impl(ctx):
    inputs = []
    outputs = []
    for dep in ctx.attr.deps:
        for src in dep[ProtoInfo].direct_sources:
            inputs.append(src)
            outputs.append(
                ctx.actions.declare_file(
                    src.path.replace('.proto', '_pb.d.ts')
                )
            )
            outputs.append(
                ctx.actions.declare_file(
                    src.path.replace('.proto', '_pb.js')
                )
            )
    x = "bazel-out/k8-fastbuild/bin/grpc/nodejs"
#    protoc_inputs, input_manifests = ctx.resolve_tools(tools=[ctx.attr._protoc_gen_ts])
#    print(protoc_inputs, input_manifests)
    ctx.actions.run_shell(
        inputs = inputs, # + protoc_inputs.to_list(),
        outputs = outputs,
        command = "env && {} --plugin='protoc-gen-ts={}' \
                  --js_out='import_style=commonjs,binary:./{}/' \
                  --grpc_out='grpc_js:./{}/' \
                  --ts_out='grpc_js:./{}/' \
                  --proto_path=. {};".format(
                  ctx.executable._grpc_tools_node_protoc.path,
                  ctx.executable._protoc_gen_ts.path,
                  x, x, x,
                  " ".join([x.path for x in inputs])
        ),
        tools = [
            ctx.executable._grpc_tools_node_protoc,
            ctx.executable._protoc_gen_ts,
        ],
        use_default_shell_env=True,
#        input_manifests=input_manifests/home/vmax/.cache/bazel/_bazel_vmax/f5ec9b17120117a1765910564b878c2f/execroot/graknlabs_protocol/bazel-out/host/bin/grpc/nodejs/_grpc_tools_node_protoc.module_mappings.json
    )
    return DefaultInfo(files = depset(outputs))


ts_proto_compile = rule(
    attrs = {
        "deps": attr.label_list(
            providers = [ProtoInfo],
        ),
        "_grpc_tools_node_protoc": attr.label(
            executable = True,
            cfg = "host",
            default="//grpc/nodejs:grpc_tools_node_protoc",
        ),
        "_protoc_gen_ts": attr.label(
            executable = True,
            allow_files = True,
            cfg = "host",
            default=Label("@rules_typescript_proto_deps//grpc_tools_node_protoc_ts/bin:protoc-gen-ts"),
        )
    },
    implementation = _ts_proto_compile_impl,
)


