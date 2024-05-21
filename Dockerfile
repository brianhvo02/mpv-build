FROM emscripten/emsdk:latest as build
WORKDIR /src

ARG BUILD_FLAGS

RUN <<EOF
    apt-get update
    apt-get install -y ninja-build automake libtool gperf gettext autopoint llvm pkg-config
    pip3 install meson
EOF

RUN <<EOF
    emsdk install tot
    emsdk activate tot
    npm --prefix "$EMSDK/upstream/emscripten" install
EOF

COPY . .

RUN ./update
RUN ./build $BUILD_FLAGS
RUN ./install

FROM emscripten/emsdk:latest
RUN <<EOF
    emsdk install tot
    emsdk activate tot
    npm --prefix "$EMSDK/upstream/emscripten" install
EOF
COPY --from=build /src/build_libs /src/build_libs
ENTRYPOINT ["bash"]
