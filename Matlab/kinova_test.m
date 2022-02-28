
% Home starting position of robot
HOME_POSITION = [277 350 91 275 354 347 93];
% Peach collection area position
COLLECTION_POSITION = [277 5 78 220 351 359 93];
% Gripper Commands
OPEN_GRIPPER = 1;
CLOSE_GRIPPER = -1;

% Connect to robot and api
gen3 = connect();

GripperFeedback.Elements(8).Elements(4)

% toolOpen(gen3);
% 
% pause(2)
% 
% toolClose(gen3);

% % Move to home position
% joint(gen3, HOME_POSITION);
% 
% % Open gripper
% tool(gen3, OPEN_GRIPPER);
% 
% % Found peach
% found_pech = [-0.33 -0.48 0.52];
% 
% % Get current tool pose
% curr_pose = get_curr_pose(gen3);
% 
% % Create cart_cmd and send to move tool to that position while keeping the
% % exiisting tool orientation
% command = [found_pech(1), found_pech(2), found_pech(3), curr_pose(4), curr_pose(5), curr_pose(6)];
% 
% % Move to peach location
% command_cartesian(gen3, command);
%  
% % Close the gripper
% tool(gen3, CLOSE_GRIPPER);
% 
% % ---- Harvet Method ----- %
% curr_position = get_curr_position(gen3);
% 
% pause(3)
% 
% command = curr_position;
% % Rotate gripper 45 degrees in x dir
% command(7) = command(7) + 45;
% % Pull down 15 degrees
% command(6) = command(6) - 15;
% 
% % Command movement to remove peach
% joint(gen3, command);
% 
% pause(3)
% % ---- Collection Method ----- %
% % Comand movement to return peach to collection area
% command_cartesian(gen3, COLLECTION_POSITION);
% 
% % Release Gripper
% tool(gen3, OPEN_GRIPPER);
% 
% pause(2)
% 
% % Return to Home position
% joint(gen3, HOME_POSITION);

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
end

function gen3 = toolOpen(gen3)
    toolCmd = 1;
    toolCommand = int32(2);
    toolDuration = 0; 

    isOk = gen3.SendToolCommand(toolCommand, toolDuration, toolCmd);
    
    if isOk
        disp('Command sent to the gripper. Wait for the gripper to open.')
    else
        error('Command Error.');
    end
end


function gen3 = toolClose(gen3)
    % 1 fully close, 0 fully open
    toolCmd = 0.36;
    toolCommand = int32(3);
    toolDuration = 0;
    
    [~, ~, ~, interconnectFb] = gen3.SendRefreshFeedback();
    disp(interconnectFb.gripper_feedback.motor(1))
    current = interconnectFb.gripper_feedback.motor(1).current_motor
    
    isOk = gen3.SendToolCommand(toolCommand, toolDuration, toolCmd);
    
    [~, ~, ~, interconnectFb] = gen3.SendRefreshFeedback();
    disp(interconnectFb.gripper_feedback.motor(1))
    current = interconnectFb.gripper_feedback.motor(1).current_motor
    
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
        pause(2)

        if isOk
            disp('Command sent to the robot. Wait for the robot to stop moving.');
            
            [~,status] = gen3.GetMovementStatus();
            disp(status)
        else
            disp('Command error.');
        end
    end
end

function command_cartesian(gen3, command)
    % coords i.e [0.2, 0.3, 0.5, 90, 0, 90]
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

% function waitUntilIdle(gen3)
%     [~,status] = gen3.GetMovementStatus();
% 
%     while status
%         gen3.SendRefreshFeedback();
%         pause(1);
%         [~,status] = gen3.GetMovementStatus();
%     end
%     
%     disp(status)
% end

function curr_pose = get_curr_pose(gen3)
    [~, baseFb, ~, ~] = gen3.SendRefreshFeedback();
    curr_pose = baseFb.tool_pose;
end

function jointAngles = get_curr_position(gen3)
    [~, ~, actuatorsFb, ~] = gen3.SendRefreshFeedback();
    jointAngles = actuatorsFb.position;
end

function force = getGripperMotorForce(gen3)
    [~, ~, ~, interconnectFb] = gen3.SendRefreshFeedback();
    disp(interconnectFb.gripper_feedback.motor(1))
    force = interconnectFb.gripper_feedback.motor(1).force;
end
