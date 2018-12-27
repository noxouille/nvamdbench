GPU_AMOUNT="8"
GPU_NAME="RTX2080Ti"
DOCKER_CMD="docker run -it --rm --runtime=nvidia -v $(pwd):/home -w /home -v /tmp/cifar10_data:/tmp/cifar10_data"
NGC_LINK="nvcr.io/nvidia"
TAG="18.09-py3"

# FOR AMD
DRUN="sudo docker run -it --network=host --device=/dev/kfd --device=/dev/dri --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -v $(pwd):/root/cifar10 -w /root/cifar10 -v /tmp/cifar10_data:/tmp/cifar10_data" 


echo "Downloading cifar10 data"
wget https://www.cs.toronto.edu/~kriz/cifar-10-binary.tar.gz -P /tmp/cifar10_data
tar xzvf /tmp/cifar10_data/cifar-10-binary.tar.gz -C /tmp/cifar10_data/
echo "Done!"


#----------------------------------NVIDIA------------------------------------
echo "Running Single NVIDIA GPU benchmark with TensorFlow:$TAG"
$DOCKER_CMD -e NVIDIA_VISIBLE_DEVICES=0 --shm-size=1g --ulimit memlock=-1 $NGC_LINK/tensorflow:$TAG python3 cifar10_train.py > cifar10_single_$GPU_NAME.log
echo "Done!"

# ADJUST THE NUMBER OF MULTI GPU YOU WOULD LIKE TO USE!
echo "Running $GPU_AMOUNT NVIDIA GPU benchmark with TensorFlow:$TAG"
$DOCKER_CMD -e NVIDIA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 --shm-size=1g --ulimit memlock=-1 $NGC_LINK/tensorflow:$TAG python3 cifar10_multi_gpu_train.py --num_gpus $GPU_AMOUNT > cifar10_multi_$GPU_AMOUNT\_$GPU_NAME.log
echo "Done!"


#----------------------------------AMD------------------------------------
echo "Running Single AMD GPU benchmark with rocm/tensorflow:latest"
$DRUN rocm/tensorflow:latest python3 cifar10_train.py > cifar10_single_$GPU_NAME.log
echo "Done!"

echo "Running $GPU_AMOUNT AMD GPU benchmark with rocm/tensorflow:latest"
$DRUN rocm/tensorflow:latest python3 cifar10_multi_gpu_train.py --num_gpus $GPU_AMOUNT > cifar10_multi_$GPU_AMOUNT\_$GPU_NAME.log
echo "Done!"

echo "All benchmarks done!"
