% Home starting position of robot
HOME_POSITION = [303 37 120 228 64 50 0];
% Peach collection area position
COLLECTION_POSITION = [0 15 180 230 0 55 90];
% Gripper Commands
OPEN_GRIPPER = 1; CLOSE_GRIPPER = -1;

% Connect to robot and api
gen3 = connect();

% Move to home position
joint(gen3, HOME_POSITION);

% Open gripper
tool(gen3, OPEN_GRIPPER);

% Found peach
found_pech = [0.06 0.44 0.54];

% Get current tool pose
curr_pose = get_curr_pose(gen3);

% Create cart_cmd and send to move tool to that position while keeping the
% exiisting tool orientation
command = [found_pech(1), found_pech(2), found_pech(3), curr_pose(4), curr_pose(5), curr_pose(6)]

% Move to peach location
command_cartesian(gen3, command)
 
% Close the gripper
tool(gen3, CLOSE_GRIPPER)

% ---- Harvet Method ----- %
% Rotate gripper 45 degrees in x dir
% command(5) = command(5) + 45;
% Pull down 5cm
command(3) = command(3) - 0.05;

% Command movement to remove peach
command_cartesian(gen3, command);

% ---- Collection Method ----- %
% Comand movement to return peach to collection area
command_cartesian(gen3, COLLECTION_POSITION);

% Release Gripper
tool(gen3, OPEN_GRIPPER)

% Return to Home position
joint(gen3, HOME_POSITION);

function gen3 = connect()
    Simulink.importExternalCTypes(which('kortex_wrapper_data.h'));
    gen3 = kortex();
    gen3.ip_address = '192.168.1.10';
    gen3.user = 'admin';
    gen3.password = 'admin';

    isOk = gen3.CreateRobotApisWrapper();

    waitUntilIdle(gen3)

    if isOk
       disp('You are connected to the robot!'); 
    else
       error('Failed to establish a valid connection!');
    end
end

function gen3 = tool(gen3, command)
    toolCmd = command;
    toolCommand = int32(2);
    toolDuration = 0; 

    isOk = gen3.SendToolCommand(toolCommand, toolDuration, toolCmd);

    waitUntilIdle(gen3)

    if isOk
        disp('Command sent to the gripper. Wait for the gripper to open.')
    else
        error('Command Error.');
    end
end

function joint(gen3, command)
    jointCmd = command;
    constraintType = int32(0);
    speed = 0;
    duration = 0;

    isOk = gen3.SendJointAngles(jointCmd, constraintType, speed, duration);

    waitUntilIdle(gen3)

    if isOk
        disp('Command sent to the robot. Wait for the robot to stop moving.');
    else
        disp('Command error.');
    end
end

function command_cartesian(gen3, command)
    % coords i.e [0.2, 0.3, 0.5, 90, 0, 90]
    cartCmd = command;
    constraintType = int32(0);
    speeds = [0, 0];
    duration = 0;
     
    isOk = gen3.SendCartesianPose(cartCmd, constraintType, speeds, duration);

    waitUntilIdle(gen3)
     
    if isOk
        disp('Command sent to the robot. Wait for robot to finish motion and stop');
    else
        error('Command Error.');
    end
end

function waitUntilIdle(gen3)
    isMoving = gen3.GetMovementStatus();

    while isMoving
        gen3.SendRefreshFeedback();
        isMoving = gen3.GetMovementStatus();
    end
end

function curr_pose = get_curr_pose(gen3)
    [~, baseFb, ~, ~] = gen3.SendRefreshFeedback();
    disp(baseFb)
    curr_pose = baseFb.tool_pose;
end

% function jointAngles = get_curr_position(gen3)
%     [~, ~, actuatorsFb, ~] = gen3.SendRefreshFeedback();
%     jointAngles = actuatorsFb.position;
% end
