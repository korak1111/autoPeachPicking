
clc

global f c peaches_picked

f = kinova_api_wrapper;
c = constants;
peaches_picked = 0;

gen3 = f.run_initalization();
while ~terminate
% terminate = pick_peaches(gen3);
end


gen3.DestroyRobotApisWrapper();


function terminate = pick_peaches(gen3)
    global f c peaches_picked
    f.set_joint_angles(gen3, c.TABLE_POSITION);
    f.set_joint_angles(gen3, c.HOME_POSITION);
    
    f.toggle_tool_state(gen3, c.OPEN_GRIPPER);
    
    %% --- Vision Method --- %%
    capture_img(c.RGB_DEPTH)
    peach_pixels = read_coordinates_from_file(); %Get pixel Locatoins
    % from File

    if (peaches_picked == 4) || isempty(peach_coords) %Terimantion Condtions
        terminate = true;
        return
    end

    %% Determine which peach to pick 
    
    for n=1:size(peach_pixels,1)
        curr_coord = pixel_to_coordinates(gen3, peach_pixels(n,:), depth);
        peach_coordinates = [peach_coordinates; curr_coord];
    end

    found_peach = get_best_peach(gen3, peach_coordinates)
%     found_pech = [-0.68 -0.052 0.45];

    
    % Get current cartesian pose of tool      
    curr_pose = f.get_curr_pose(gen3);
    
    % Create command to move tool to peach position while keeping the
    % existing tool orientation
    command = [found_pech(1), found_pech(2), found_pech(3), 
        curr_pose(4), curr_pose(5), curr_pose(6)];
    
    % Move to peach location
    f.set_arm_pose(gen3, command);
    
    harvest_peach(gen3);
    
    % Move to collection position and drop peach in tray
    new_collection_position = update_collection(gen3, peaches_picked);
    f.set_joint_angles(gen3, new_collection_position); 
    peaches_picked = peaches_picked +1;
    f.toggle_tool_state(gen3, c.OPEN_GRIPPER);

    f.set_joint_angles(gen3, c.HOME_POSITION);


end

function harvest_peach(gen3)
    global f c
    % Grab Peach
    f.toggle_tool_state(gen3, c.CLOSE_GRIPPER);
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

