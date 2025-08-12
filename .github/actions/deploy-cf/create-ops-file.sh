# Hardcode Noble compiled releases ops file
OPS_FILE="$WORKSPACE/use-compiled-releases-noble.yml"

cat >"$OPS_FILE" <<'EOF'
- type: replace
  path: /releases/name=bpm
  value:
    name: bpm
    version: dev.1754985465
    url: s3://cflinuxfs5test/noble-releases/bpm-release/bpm-release-dev.1754985465.tgz
    sha1: e5d7999b07765f5feba4f7b24721e13bf8188382
- type: replace
  path: /releases/name=capi
  value:
    name: capi
    version: dev.1754985485
    url: s3://cflinuxfs5test/noble-releases/capi-release/capi-release-dev.1754985485.tgz
    sha1: 151c7c9fac575a50e14491f3cecff9bee22bf61b
- type: replace
  path: /releases/name=cf-networking
  value:
    name: cf-networking
    version: dev.1754985537
    url: s3://cflinuxfs5test/noble-releases/cf-networking-release/cf-networking-release-dev.1754985537.tgz
    sha1: 6b24eca568aeea9cd21e81e7b50303c42e5a825b
- type: replace
  path: /releases/name=diego
  value:
    name: diego
    version: dev.1754985578
    url: s3://cflinuxfs5test/noble-releases/diego-release/diego-release-dev.1754985578.tgz
    sha1: 342d1149951e96e5e724de408fe032b7d16a9aca
- type: replace
  path: /releases/name=garden-runc
  value:
    name: garden-runc
    version: dev.1754985628
    url: s3://cflinuxfs5test/noble-releases/garden-runc-release/garden-runc-release-dev.1754985628.tgz
    sha1: d87d35297fbd7086d01892f8b91d242c06c22b0a
- type: replace
  path: /releases/name=log-cache
  value:
    name: log-cache
    version: dev.1754985667
    url: s3://cflinuxfs5test/noble-releases/log-cache-release/log-cache-release-dev.1754985667.tgz
    sha1: 6b77d927ac29b2353ef50c18ea60de03d34f8463
- type: replace
  path: /releases/name=loggregator
  value:
    name: loggregator
    version: dev.1754985683
    url: s3://cflinuxfs5test/noble-releases/loggregator-release/loggregator-release-dev.1754985683.tgz
    sha1: 691295c19766f6687e1f63862d26ef7f006eee3a
- type: replace
  path: /releases/name=nats
  value:
    name: nats
    version: dev.1754985697
    url: s3://cflinuxfs5test/noble-releases/nats-release/nats-release-dev.1754985697.tgz
    sha1: 3bb16d1392304e0e12b1c66332a9a4e7b4eb2d31
- type: replace
  path: /releases/name=routing
  value:
    name: routing
    version: dev.1754985711
    url: s3://cflinuxfs5test/noble-releases/routing-release/routing-release-dev.1754985711.tgz
    sha1: 8c9fc310d5cefdab07f5c7eda0689184d64540b8
- type: replace
  path: /releases/name=silk
  value:
    name: silk
    version: dev.1754985733
    url: s3://cflinuxfs5test/noble-releases/silk-release/silk-release-dev.1754985733.tgz
    sha1: 490d7d83b126a7f03dbb086e2ed2ac4a1e947a09
- type: replace
  path: /releases/name=statsd-injector
  value:
    name: statsd-injector
    version: dev.1754985748
    url: s3://cflinuxfs5test/noble-releases/statsd-injector-release/statsd-injector-release-dev.1754985748.tgz
    sha1: 0d72fa9b6d9daaa2af1b6772c707a510ff05e30b
- type: replace
  path: /releases/name=syslog
  value:
    name: syslog
    version: dev.1754985759
    url: s3://cflinuxfs5test/noble-releases/syslog-release/syslog-release-dev.1754985759.tgz
    sha1: 357e69976ab5a3fe4c90f0f31366bc1578b43f5b
EOF

echo "=== Noble compiled releases ops file generated: $OPS_FILE ==="
cat "$OPS_FILE"
