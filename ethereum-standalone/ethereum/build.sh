# If you don't want to build 'geth' from sources, uncomment the following three lines.
apk add --update --no-cache ca-certificates geth
rm /root/.ethereum/build.sh
exit

# So we can get to the internet.
apk add --update --no-cache ca-certificates

# So we can build 'geth'.
apk add --no-cache --virtual .build-deps \
  git openssh make go gcc musl-dev linux-headers

# Get the latest 'geth' code. We do this because the package may not
# be (probably isn't) up to date with the current production level geth.
git clone --depth=1 https://github.com/ethereum/go-ethereum /go-ethereum

# Build 'geth' and move it to bin.
cd /go-ethereum && make geth
mv /go-ethereum/build/bin/geth /usr/local/bin

# Remove stuff we don't need to make our image nice and small.
rm -rf /go /usr/local/go /usr/lib/go /go-ethereum /root/.ethereum/build.sh
apk del .build-deps
