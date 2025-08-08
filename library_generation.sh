######## Build library ########

source install/local_setup.bash
ros2 run micro_ros_setup build_firmware.sh $(pwd)/toolchain.cmake $(pwd)/colcon.meta

######## Copy built library and include headers into firmware development workspace  ########

FIRMWARE_DEV_PATH="/home/truongdang/Documents/micro_ros_documentation/firmware_development"

find firmware/build/include/ -name "*.c"  -delete

rm -rf "${FIRMWARE_DEV_PATH}/libmicroros/"
mkdir -p "${FIRMWARE_DEV_PATH}/libmicroros/include"

cp -R firmware/build/include/* "${FIRMWARE_DEV_PATH}/libmicroros/include"
cp -R firmware/build/libmicroros.a "${FIRMWARE_DEV_PATH}/libmicroros/libmicroros.a"

######## Fix include paths  ########

pushd firmware/mcu_ws > /dev/null
    INCLUDE_ROS2_PACKAGES=$(colcon list | awk '{print $1}' | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}')
popd > /dev/null

for var in ${INCLUDE_ROS2_PACKAGES}; do
    rsync -r "${FIRMWARE_DEV_PATH}/libmicroros/include/${var}/${var}/" "${FIRMWARE_DEV_PATH}/libmicroros/include/${var}/"
    rm -rf "${FIRMWARE_DEV_PATH}/libmicroros/include/${var}/${var}"
done
