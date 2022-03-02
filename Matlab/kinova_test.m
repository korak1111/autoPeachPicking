
clc

global f c

f = kinova_api_wrapper;
c = constants;

gen3 = f.run_initalization();

% pick_peaches(gen3);

capture_img(c.RGB)
%     
peach_coords = read_coordinates_from_file();


gen3.DestroyRobotApisWrapper();


function pick_peaches(gen3)
    f.set_joint_angles(gen3, c.TABLE_POSITION);
    f.set_joint_angles(gen3, c.HOME_POSITION);
    
    f.toggle_tool_state(gen3, c.OPEN_GRIPPER);
    
    % --- Vision Method --- %
    capture_img(c.RGB_DEPTH)
    
    % peach_coords = read_coordinates_from_file();

    found_pech = [-0.68 -0.052 0.45];
    
    % Get current cartesian pose of tool      
    curr_pose = f.get_curr_pose(gen3);
    
    % Create command to move tool to peach position while keeping the
    % existing tool orientation
    command = [found_pech(1), found_pech(2), found_pech(3), 
        curr_pose(4), curr_pose(5), curr_pose(6)];
    
    % Move to peach location
    f.set_arm_pose(gen3, command);
     
    f.toggle_tool_state(gen3, c.CLOSE_GRIPPER);
    
    harvest_peach(gen3);
    
    % Move to collection position and drop peach in tray
    f.set_joint_angles(gen3, c.COLLECTION_POSITION);
    f.toggle_tool_state(gen3, c.OPEN_GRIPPER);

    f.set_joint_angles(gen3, c.HOME_POSITION);
end

function harvest_peach(gen3)
    % Get current joint angles
    command = get_curr_joint_angles(gen3);
    % Rotate gripper by 45 degrees
    command(7) = command(7) + 45;
    
    % Command joint movement to twist gripper
    f.set_joint_angles(gen3, command);
    
    % Get current cartesian pose
    command = get_curr_pose(gen3);
    % Move gripper down 15cm
    command(3) = command(3) - 0.15;
    
    % Command movement to pull down
    f.set_arm_pose(gen3, command);
end

