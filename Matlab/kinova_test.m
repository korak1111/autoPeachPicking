% Home starting position of robot
HOME_POSITION = [227 36 177 280 8 16 180];
% Peach collection area position
COLLECTION_POSITION = [0 15 180 230 0 55 90];
% Threshold for arm current at standard operation in A
STD_OP_ARM_CURRENT = 1;


Simulink.importExternalCTypes(which('kortex_wrapper_data.h'));
gen3Kinova = kortex();
gen3Kinova.ip_address = '192.168.1.10';
gen3Kinova.user = 'admin';
gen3Kinova.password = 'admin';

isOk = gen3Kinova.CreateRobotApisWrapper();
if isOk
   disp('You are connected to the robot!'); 
else
   error('Failed to establish a valid connection!');
end

jointCmd = HOME_POSITION;
constraintType = int32(0);
speed = 0;
duration = 0;

isOk = gen3Kinova.SendJointAngles(jointCmd, constraintType, speed, duration);

if isOk
    disp('Command sent to the robot. Wait for the robot to stop moving.');
else
    disp('Command error.');
end
