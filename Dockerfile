FROM emscripten/emsdk:latest as build
WORKDIR /src
ARG BUILD_FLAGS
COPY . .

RUN <<EOF
    apt-get update
    apt-get install -y ninja-build automake libtool gperf gettext autopoint llvm pkg-config
    pip3 install meson
EOF

RUN <<EOF
    emsdk install tot
    emsdk activate tot
    rm -rf /emsdk/upstream/emscripten
    git clone https://github.com/brianhvo02/emscripten.git /emsdk/upstream/emscripten
    git -C /emsdk/upstream/emscripten switch wasmfs
    /emsdk/upstream/emscripten/bootstrap
    emcc -lembind -sUSE_PTHREADS -sFULL_ES3 -sWASM_BIGINT -sWASMFS -sPROXY_TO_PTHREAD dummy/dummy.cpp -o dummy/dummy.js
EOF

RUN ./update
RUN ./build $BUILD_FLAGS
RUN ./install

FROM emscripten/emsdk:latest
RUN <<EOF
    apt-get update
    apt-get install -y pkg-config
    emsdk install tot
    emsdk activate tot
    rm -rf /emsdk/upstream/emscripten
EOF
COPY --from=build /emsdk/upstream/emscripten /emsdk/upstream/emscripten
COPY --from=build /src/build_libs /src/build_libs
ENTRYPOINT ["bash"]
