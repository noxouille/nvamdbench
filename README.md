# Benchmark for both NVIDIA and AMD GPU

For now, only CIFAR10 was tested on RADEON MI25 (x4) and RTX 2080Ti (x8).

## How to run both single and multi GPU

First, modify the GPU name and GPU amount in the `run_bench_cifar10_all.sh`, and comment out the one you don't want to test. Then run

```bash
./run_bench_cifar10_all.sh
```