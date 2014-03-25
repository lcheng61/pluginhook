VERSION = 0.1.1

build: pluginhook

pluginhook:
	go build -o pluginhook
	GOOS=linux go build -o pluginhook.linux

test: build
	PLUGIN_PATH=./tests/plugins BIN=./pluginhook tests/run_tests.sh

package-deb: clean build test
	rm -rf package
	mkdir -p package/bin
	mv pluginhook.linux package/bin/pluginhook
	cd package && fpm -s dir -t deb -n pluginhook -v ${VERSION} --prefix /usr/local bin

package-rpm: clean build test
	rm -rf package
	mkdir -p package/bin
	mv pluginhook.linux package/bin/pluginhook
	cd package && fpm -s dir -t rpm -n pluginhook -v ${VERSION} --prefix /usr/local bin

clean:
	rm -rf pluginhook pluginhook.linux

release: package-deb
	s3cmd -P put package/pluginhook_${VERSION}_amd64.deb s3://progrium-pluginhook
