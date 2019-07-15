# Multi-threaded Mandelbrot with WebAssembly

A simple demonstration of WebAssembly threads - for further details see the [associated blog post](https://blog.scottlogic.com/2019/07/15/multithreaded-webassembly.html).

## Development

Using the WebAssembly Binary Toolkit ...

```
wat2wasm --enable-threads mandelbrot.wat -o mandelbrot.wasm
```
