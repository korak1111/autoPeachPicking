% Home starting position of robot
HOME_POSITION = [303 37 120 228 64 50 0];
% Peach collection area position
COLLECTION_POSITION = [0 15 180 230 0 55 90];
% Threshold for arm current at standard operation in A
STD_OP_ARM_CURRENT = 1;


gen3Kinova = connect();

% Move to home position
joint(gen3Kinova, HOME_POSITION);


pause(5)

% Open gripper
tool(gen3Kinova, 1);

pause(2)

% Found peach
found_pech = [0.06 0.44 0.54];

% Get current tool pose
curr_pose = get_curr_pose(gen3Kinova);

% Create cart_cmd and send to move tool to that position
command = [found_pech(1), found_pech(2), found_pech(3), curr_pose(4), curr_pose(5), curr_pose(6)]

pause(2)

% Move to peach location
command = [-0.327 0.353 0.388 -97.2 -96.7 83.2];
command_cartesian(gen3Kinova, command)

pause(10)
 
% Close the gripper
tool(gen3Kinova, -1)

pause(3)

% curr_position = get_curr_position(gen3Kinova);
% 
% command = curr_position;

% Rotate gripper 45 degrees in x dir
command(5) = command(5) + 45;
% Pull down
% command(3) = command(3) - 0.05;


command_cartesian(gen3Kinova, command);

function gen3Kinova = connect()
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
end
    

function gen3Kinova = tool(gen3Kinova, command)

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

function joint(gen3Kinova, command)
    jointCmd = command;
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

function command_cartesian(gen3Kinova, command)
    % coords i.e [0.2, 0.3, 0.5, 90, 0, 90]
    cartCmd = command;
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


function curr_pose = get_curr_pose(gen3Kinova)
    [~, baseFb, ~, ~] = gen3Kinova.SendRefreshFeedback();
    disp(baseFb)
    curr_pose = baseFb.tool_pose;
end

function jointAngles = get_curr_position(gen3Kinova)
    [~, ~, actuatorsFb, ~] = gen3Kinova.SendRefreshFeedback();
    jointAngles = actuatorsFb.position;
end
