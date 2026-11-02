# go-quark


Go bindings for [quark](https://github.com/elastic/quark). The Go sources are
mirrored from `src/go/quark` with `make copy-go`. The headers in `include/`
and the prebuilt per-architecture `libquark_big_$(ARCH).a` come from the
`src` submodule with `make update-quark`.

## Synthetic queue (tests and benchmarks only)

Building with the `quark_synthetic` tag adds the probe-free synthetic queue
(`OpenSyntheticQueue`, `Queue.Inject`) and links
`libquark_big_synthetic_$(ARCH).a` instead of the production archive
(`cgo_flags_synthetic.go`). Production builds never contain it.

```sh
make update-quark            # production archive, headers, Go sources
make update-quark-synthetic  # synthetic archive from the same src revision
make test-quark-libraries    # link check for both archives
```

Both targets run on Linux and need Docker.
