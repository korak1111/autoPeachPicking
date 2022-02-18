% Home starting position of robot
HOME_POSITION = [0 15 180 230 0 55 90];
% Peach collection area position
COLLECTION_POSITION = [0 15 180 230 0 55 90];
% Threshold for arm current at standard operation in A
STD_OP_ARM_CURRENT = 1;

% Connect to robot
connect()
% Go to home starting position
send_joint_angle(HOME_POSITION)

% Look for peaches
% While peaches are found
% Tmp, replace with reading from file
found_pech = [0.2, 0.2, 0.2];

% Open the gripper
control_gripper(1)

% Get current tool pose
curr_pose = get_curr_pose();

% Create cart_cmd and send to move tool to that position
command = [found_pech(1), found_pech(2), found_pech(3), curr_pose(4), curr_pose(5), curr_pose(6)];
command_cartesian(command)

% Close the gripper
control_gripper(-1)

% Rotate gripper 45 degrees in x dir
command(4) = command(4) + 45;
% Pull down
command(3) = command(3) - 0.05;

command_cartesian(command)

% Check current to see if peach is still attached
arm_current = get_arm_current();

% If the peach is still attached move back to the peach poisition
% and open the gripper. Otherwise move to the collection area and
% open the gripper
if arm_current > STD_OP_ARM_CURRENT
    command(3) = command(3) + 0.05;
    command(4) = command(4) - 45;
    command_cartesian(command)
    control_gripper(1)
else
    command_cartesian(COLLECTION_POSITION)
    control_gripper(1)
end

% Go back to home position
command_cartesian(COLLECTION_POSITION)


function connect()
    Simulink.importExternalCTypes('mex-wrapper/include/kortex_wrapper_data.h');
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
end

function send_joint_angle(coords)
    jointCmd = coords;
    
    constraintType = int32(0);
    speed = 0;
    duration = 0;
    
    isOk = gen3Kinova.SendJointAngles(jointCmd, constraintType, speed, duration);
     
    if isOk
        disp('Command sent to the robot. Wait for the robot to stop moving.');
    else
        disp('Command error.');
    end
end

function control_gripper(command)
    % toolCmd: 1 is open, -1 is close
    toolCmd = command;
    toolCommand = int32(2);
    toolDuration = 0; 

    isOk = gen3Kinova.SendToolCommand(toolCommand, toolDuration, toolCmd);
    if isOk
        disp('Command sent to the gripper. Wait for the gripper to open.')
    else
        error('Command Error.');
    end
end

function command_cartesian(coords)
    % coords i.e [0.2, 0.3, 0.5, 90, 0, 90]
    cartCmd = coords
    constraintType = int32(0);
    speeds = [0, 0];
    duration = 0;
     
    isOk = gen3Kinova.SendCartesianPose(cartCmd, constraintType, speeds, duration);
     
    if isOk
        disp('Command sent to the robot. Wait for robot to finish motion and stop');
    else
        error('Command Error.');
    end
end

function pose = get_curr_pose()
    [~,baseFb, ~, ~] = gen3Kinova.SendRefreshFeedback();
    pose = baseFb.tool_pose;
end

function current = get_arm_current)
    [~,baseFb, ~, ~] = gen3Kinova.SendRefreshFeedback();
    current = baseFb.arm_current;
end

function exit_session()
    isOk = gen3Kinova.DestroyRobotApisWrapper();
    clear
end
