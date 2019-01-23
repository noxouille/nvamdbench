IMAGE="rocm/tensorflow"
TAG="latest"
GPUNAME="RADEONMI25"
declare -a cnnmodel=("resnet50" "inception3" "vgg16" "alexnet" "resnet152")

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
for NUMGPU in 1 2 4 ; do
echo "benchmarking $CNNMODEL with $NUMGPU GPU (Batch size $BATCHSIZE),"
echo "variable_update $VARUPDATE, local_parameter_device $LPS..."
sudo docker run -it \
  --network=host --device=/dev/kfd --device=/dev/dri \
  --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
  -v $(pwd):/workspace/pwd \
  -w /workspace/pwd/benchmarks/scripts/tf_cnn_benchmarks \
  $IMAGE:$TAG \
  python3 tf_cnn_benchmarks.py \
  --num_gpus=$NUMGPU \
  --batch_size=$BATCHSIZE \
  --model=$CNNMODEL \
  --variable_update=$VARUPDATE \
  --local_parameter_device=$LPS \
  > train_$CNNMODEL\_batch$BATCHSIZE\_x$NUMGPU\_$GPUNAME.log
echo "Done!"
done; done