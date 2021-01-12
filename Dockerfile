FROM innovanon/doom-base as builder-01
USER root
COPY --from=innovanon/zlib   /tmp/zlib.txz   /tmp/
COPY --from=innovanon/bzip2  /tmp/bzip2.txz  /tmp/
COPY --from=innovanon/xz     /tmp/xz.txz     /tmp/
RUN cat   /tmp/*.txz  \
  | tar Jxf - -i -C / \
 && rm -v /tmp/*.txz
#RUN tar xf                   /tmp/zlib.txz   -C / \
# && tar xf                   /tmp/bzip2.txz  -C / \
# && tar xf                   /tmp/xz.txz     -C / \
# && rm -v                    /tmp/zlib.txz        \
#                             /tmp/bzip2.txz       \
#                             /tmp/xz.txz
FROM builder-01 as jpeg-turbo
USER lfs
# TODO disable shared, enable static
RUN sleep 31 \
 && git clone --depth=1 --recursive \
      https://github.com/libjpeg-turbo/libjpeg-turbo.git \
 && cd                               libjpeg-turbo     \
 && mkdir -v build                                     \
 && cd       build                                     \
 && cmake .. -DCMAKE_BUILD_TYPE=Release                \
      -G Ninja                                         \
 && cd    ..                                           \
 && cmake --build build                                \
 && DESTDIR=/tmp/jpeg-turbo                            \
    cmake --build build --target install               \
 && cd          /tmp/jpeg-turbo                        \
 && tar acf       ../jpeg-turbo.txz .                  \
 && rm -rf         $LFS/sources/libjpeg-turbo

FROM scratch as final
COPY --from=jpeg-turbo /tmp/jpeg-turbo.txz /tmp/

