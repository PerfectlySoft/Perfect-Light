clear
HUB=/tmp/perfect
pushd .
rm -rf $HUB
mkdir -p $HUB

function mirror_ex() {
	cd /tmp/perfect
	REPO=$1
	VEND=$2
	RELEASES=$VEND/$REPO/releases
	TAGS=/$RELEASES/tag/
	GITHUB=https://github.com
	LATEST=$(curl -s $GITHUB/$RELEASES | grep $TAGS | head -n 1 | sed 's/[-|\ |\"|\=|\<|\>|\/|a-z|A-Z]//g')
	echo "Caching $VEND/$REPO:$LATEST"
	curl -s -L "$GITHUB/$VEND/$REPO/archive/$LATEST.tar.gz" -o /tmp/a.tgz
	tar xzf /tmp/a.tgz
	rm -rf /tmp/a.tgz
	mv $REPO-$LATEST $REPO
	cd $REPO
}

function mirror() {
	mirror_ex $1 PerfectlySoft
}

function reversion() {
	rm -rf .git
	git init >> /dev/null
	git add *  >> /dev/null
	git commit -m "slim"  >> /dev/null
	VERSION=$(git log|awk '$1=="commit" {print $2}')
	git tag $LATEST $VERSION  >> /dev/null
}

mirror Perfect-LinuxBridge
reversion

mirror Perfect
tee Package.swift << EOF >> /dev/null
import PackageDescription
var urls = [String]()
#if os(Linux)
urls += ["$HUB/Perfect-LinuxBridge"]
#endif
let package = Package(
	name: "PerfectLib",	targets: [],
	dependencies: urls.map { .Package(url: \$0, majorVersion: 3) }
)
EOF
reversion

mirror Perfect-COpenSSL
reversion

mirror Perfect-COpenSSL-Linux
reversion

mirror Perfect-Thread
tee Package.swift << EOF >> /dev/null
import PackageDescription
var urls = [String]()
#if os(Linux)
urls += ["$HUB/Perfect-LinuxBridge"]
#endif
let package = Package(
	name: "PerfectThread",	targets: [],
	dependencies: urls.map { .Package(url: \$0, majorVersion: 3) }
)
EOF
reversion

mirror Perfect-Crypto
reversion
tee Package.swift << EOF >> /dev/null
import PackageDescription
#if os(Linux)
	let cOpenSSLRepo = "$HUB/Perfect-COpenSSL-Linux"
#else
	let cOpenSSLRepo = "$HUB/Perfect-COpenSSL"
#endif
let package = Package( name: "PerfectCrypto", targets: [],
    dependencies: [
		.Package(url: "$HUB/Perfect", majorVersion: 3),
		.Package(url: "$HUB/Perfect-Thread", majorVersion: 3),
		.Package(url: cOpenSSLRepo, majorVersion: 3)
	]
)
EOF
reversion

mirror Perfect-Net
reversion
tee Package.swift << EOF >> /dev/null
import PackageDescription
var urls: [String] = ["$HUB/Perfect-Crypto", "$HUB/Perfect-Thread"]
#if os(Linux)
	urls += ["$HUB/Perfect-LinuxBridge"]
#endif
let package = Package(
    name: "PerfectNet", targets: [],
    dependencies:  urls.map { .Package(url: \$0, majorVersion: 3) }
)
EOF
reversion

mirror Perfect-HTTP
reversion
tee Package.swift << EOF >> /dev/null
import PackageDescription
var urls: [String] = ["$HUB/Perfect", "$HUB/Perfect-Net"]
#if os(Linux)
	urls += ["$HUB/Perfect-LinuxBridge"]
#endif
let package = Package(
    name: "PerfectHTTP", targets: [],
    dependencies:  urls.map { .Package(url: \$0, majorVersion: 3) }
)
EOF
reversion

mirror Perfect-CZlib-src
cd PerfectCZlib
rm -rf amiga contrib doc examples msdoc nintendods old os400 qnx test watcom win32
cd ..
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(
    name: "PerfectCZlib", targets: [],
    dependencies:  [],
 		exclude: ["contrib", "test", "examples"]
)
EOF
reversion

mirror Perfect-HTTPServer
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(
	name: "PerfectHTTPServer",
	targets: [
		Target(name: "PerfectCHTTPParser", dependencies: []),
		Target(name: "PerfectHTTPServer", dependencies: ["PerfectCHTTPParser"]),
	],
	dependencies: [
		.Package(url: "$HUB/Perfect-Net", majorVersion: 3),
		.Package(url: "$HUB/Perfect-HTTP", majorVersion: 3),
		.Package(url: "$HUB/Perfect-CZlib-src", majorVersion: 0)
	]
)
EOF
reversion

mirror Perfect-libcurl
reversion

mirror Perfect-CURL
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(
	name: "PerfectCURL",
	targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-libcurl", majorVersion: 2),
		.Package(url: "$HUB/Perfect-HTTP", majorVersion: 3),
	]
)
EOF
reversion

mirror_ex SwiftMoment iamjono
rm -rf *.playground *.xcodeproj Tests *.md
reversion

mirror Perfect-Logger
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(
	name: "PerfectLogger",
	targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect", majorVersion: 3),
		.Package(url: "$HUB/SwiftMoment", majorVersion: 1),
		.Package(url: "$HUB/Perfect-CURL", majorVersion: 3),
	]
)
EOF
reversion

mirror_ex JSONConfig iamjono
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(
    name: "JSONConfig",
    targets: [],
    dependencies: [
        .Package(url: "$HUB/Perfect", majorVersion: 3)
	]
)
EOF
reversion

mirror_ex SwiftRandom iamjono
reversion

mirror Perfect-RequestLogger
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(
	name: "PerfectRequestLogger",
	targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-Logger", majorVersion: 3),
		.Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3),
		.Package(url: "$HUB/SwiftRandom", majorVersion: 0),
	]
)
EOF
reversion

mirror Perfect-Mustache
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(
	name: "PerfectMustache",
	targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-HTTP", majorVersion: 3),
	]
)
EOF
reversion

mirror Perfect-SMTP
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(
    name: "PerfectSMTP", dependencies: [
    .Package(url: "$HUB/Perfect-CURL", majorVersion: 3)
  ]
)
EOF
reversion

mirror Perfect-libpq
reversion

mirror Perfect-libpq-linux
reversion

mirror Perfect-PostgreSQL
tee Package.swift << EOF >> /dev/null
import PackageDescription
#if os(OSX)
let url = "$HUB/Perfect-libpq"
#else
let url = "$HUB/Perfect-libpq-linux"
#endif
let package = Package(
    name: "PerfectPostgreSQL", targets: [],
    dependencies: [
        .Package(url: url, majorVersion: 2)
    ])
EOF
reversion

mirror PerfectTemplate
tee Package.swift << EOF >> /dev/null
import PackageDescription
let package = Package(
	name: "PerfectTemplate",
	targets: [],
	dependencies: [
		.Package(url: "$HUB/Perfect-HTTPServer", majorVersion: 3),
	]
)
EOF
reversion

# Clean up
popd


