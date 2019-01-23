IMAGE="nvcr.io/nvidia/tensorflow"
TAG="18.12-py3"
GPUNAME="RTX2080Ti"
declare -a cnnmodel=("resnet50" "inception3" "vgg16" "alexnet" "resnet152")

# echo "---------- $GPUNAME CNN benchmark ----------"
# BATCHSIZE="32"
# for CNNMODEL in "${cnnmodel[@]}"; do 
# for NUMGPU in 1 ; do
# echo "benchmarking $CNNMODEL with $NUMGPU GPU (Batch size $BATCHSIZE)..."
# docker run --runtime=nvidia --rm -it \
#   --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 \
#   -v $(pwd):/workspace/pwd \
#   -w /workspace/pwd/benchmarks/scripts/tf_cnn_benchmarks \
#   $IMAGE:$TAG \
#   python tf_cnn_benchmarks.py \
#   --num_gpus=$NUMGPU \
#   --batch_size=$BATCHSIZE \
#   --model=$CNNMODEL \
#   --variable_update=parameter_server \
#   > train_$CNNMODEL\_batch$BATCHSIZE\_x$NUMGPU\_$GPUNAME.log
# echo "Done!"
# done; done

echo "---------- OFFICIAL TF $GPUNAME CNN benchmark ----------"
BATCHSIZE="64"
VARUPDATE="parameter_server"
LPS="gpu"
for CNNMODEL in "${cnnmodel[@]}"; do 
if [ "$CNNMODEL" = "alexnet" ]; then
  BATCHSIZE="512"
  VARUPDATE="replicated"
  LPG="gpu"
  else
  BATCHSIZE="64"
  LPS="cpu"
fi
if [ "$CNNMODEL" = "vgg16" ]; then
  VARUPDATE="replicated"
  LPS="gpu"
fi
for NUMGPU in 1 2 4 8 ; do
echo "benchmarking $CNNMODEL with $NUMGPU GPU (Batch size $BATCHSIZE)..."

docker run --runtime=nvidia --rm -it \
  --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 \
  -v $(pwd):/workspace/pwd \
  -w /workspace/pwd/benchmarks/scripts/tf_cnn_benchmarks \
  $IMAGE:$TAG \
  python tf_cnn_benchmarks.py \
  --num_gpus=$NUMGPU \
  --batch_size=$BATCHSIZE \
  --model=$CNNMODEL \
  --variable_update=$VARUPDATE \
  --local_parameter_device=$LPS \
  > train_$CNNMODEL\_batch$BATCHSIZE\_x$NUMGPU\_$GPUNAME.log
echo "Done!"
done; done
