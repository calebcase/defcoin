FROM ubuntu:16.04 as builder
WORKDIR /src/github.com/calebcase/defcoin
RUN apt-get update && \
		apt-get install -y \
			build-essential \
			libssl-dev \
			libboost-all-dev \
			libdb++-dev \
			libminiupnpc-dev \
			pwgen
COPY src src
COPY share share
RUN cd src && \
		make -f makefile.unix -e PIE=1
RUN mkdir /root/.defcoin && \
		printf '%s\n%s\n' "rpcuser=defcoinrpc" "rpcpassword=$(pwgen 64)" > /root/.defcoin/defcoin.conf && \
		chmod 600 /root/.defcoin/defcoin.conf

FROM ubuntu:16.04
RUN apt-get update && \
		apt-get install -y \
			libboost1.58 \
			libdb5.3++ \
			libminiupnpc10 \
			libssl1.0.0
COPY --from=builder /src/github.com/calebcase/defcoin/src/defcoind /bin/defcoind
COPY --from=builder /root/.defcoin /root/.defcoin
CMD ["/bin/defcoind"]
