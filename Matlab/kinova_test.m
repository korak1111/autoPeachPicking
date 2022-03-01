
%clear all
clc
% Robot laying on table rest position
% TABLE_POSITION = [-0.014 0.589 0.001 91.2 1.5 174.5] % cart coords
TABLE_POSITION = [272.98 86.37 173.84 244.56 359.57 109.91 98.39];
% Home starting position of robot
% HOME_POSITION = [-0.434 -0.025 0.453 -90.2 176.6 86.7]; % cart coords
HOME_POSITION = [2.6 46.43 356.22 214.97 162.74 347.51 282.18];
% Peach collection area position (0, 0)
% COLLECTION_POSITION = [0.632 -0.037 0.169 -176.2 1.4 92.1]; % cart coords
COLLECTION_POSITION = [0.11 11.34 180.48 246.48 185.44 50.35 84.22];
% Gripper Commands
OPEN_GRIPPER = 0; CLOSE_GRIPPER = 1;

% Connect to robot and api
gen3 = connect();

% Move to tabletop position
joint(gen3, TABLE_POSITION);

% Move to home position
joint(gen3, HOME_POSITION);

tool(gen3, OPEN_GRIPPER);
 
% Found peach
found_pech = [-0.68 -0.052 0.45];

% Get current tool pose
curr_pose = get_curr_pose(gen3);

% Create cart_cmd and send to move tool to that position while keeping the
% existing tool orientation
command = [found_pech(1), found_pech(2), found_pech(3), curr_pose(4), curr_pose(5), curr_pose(6)];

% Move to peach location
command_cartesian(gen3, command);
 
% Close the gripper
tool(gen3, CLOSE_GRIPPER);

% ---- Harvet Method ----- %
command = get_curr_position(gen3);
% Rotate gripper by 45 degrees
command(7) = command(7) + 45;

% Command joint movement to twist gripper
joint(gen3, command);

command = get_curr_pose(gen3);
% Move gripper down 15cm
command(3) = command(3) - 0.15;

% Command movement to pull down
command_cartesian(gen3, command);

% ---- Collection Method ----- %
% Comand movement to return peach to collection area
joint(gen3, COLLECTION_POSITION);

% Release Gripper
tool(gen3, OPEN_GRIPPER);

% Return to Home position
joint(gen3, HOME_POSITION);

gen3.DestroyRobotApisWrapper();

function gen3 = connect()
    Simulink.importExternalCTypes(which('kortex_wrapper_data.h'));
    gen3 = kortex();
    gen3.ip_address = '192.168.1.10';
    gen3.user = 'admin';
    gen3.password = 'admin';

    isOk = gen3.CreateRobotApisWrapper();

    if isOk
       disp('You are connected to the robot!'); 
    else
       error('Failed to establish a valid connection!');
    end

    % Connect to vision module
    imaqregister('C:\Program Files\Kinova\Vision Imaq\kinova_vision_imaq.dll');
end

function gen3 = tool(gen3, command)
    % 1 fully close, 0 fully open
    toolCmd = command;
    toolMode = int32(3);
    toolDuration = 0; 

    isOk = gen3.SendToolCommand(toolMode, toolDuration, toolCmd);

    pause(1)
    
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

    status = 1;
    while status
        
        [isOk,~, ~, ~] = gen3.SendRefreshFeedback();
        pause(1)

        if isOk
            disp('Command sent to the robot. Wait for the robot to stop moving.');
            
            [~,status] = gen3.GetMovementStatus();
        else
            disp('Command error.');
        end
    end
end

function command_cartesian(gen3, command)
    cartCmd = command;
    constraintType = int32(0);
    speeds = [0, 0];
    duration = 0;
     
    isOk = gen3.SendCartesianPose(cartCmd, constraintType, speeds, duration);

    status = 1;
    while status
        
        [isOk,~, ~, ~] = gen3.SendRefreshFeedback();
        pause(1);

        if isOk
            disp('Command sent to the robot. Wait for the robot to stop moving.');
            
            [~,status] = gen3.GetMovementStatus();
        else
            disp('Command error.');
        end
    end
end

function curr_pose = get_curr_pose(gen3)
    [~, baseFb, ~, ~] = gen3.SendRefreshFeedback();
    curr_pose = baseFb.tool_pose;
end

function jointAngles = get_curr_position(gen3)
    [~, ~, actuatorsFb, ~] = gen3.SendRefreshFeedback();
    jointAngles = actuatorsFb.position;
end
