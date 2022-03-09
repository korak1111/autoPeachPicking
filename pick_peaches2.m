function terminate = pick_peaches2(gen3, peaches_picked)
    global f c
    
    f = kinova_api_wrapper;
    c = constants;
    
    % f.set_joint_angles(gen3, c.HOME_POSITION);
    % Should already be home
    %% Take and load pictures
    capture_img(c.RGB_DEPTH, "rgb_img.png");
    depth_img = imread('depth_img.png');
    
    %% Read Coordinates File
    peach_pixels = read_coordinates_from_file();
    % Check Termination Conditions
    if (peaches_picked == 4) || isempty(peach_pixels)
        terminate = true;
        return
    end
    %% Determine Optimal Peach
    best_peach = get_best_peach(gen3, peach_pixels);
    x=best_peach(1);
    y=best_peach(2);
    
    % Calculate Depth
    depth = get_depth(x, y, depth_img);
    if depth < c.MIN_DEPTH || depth > c.MAX_DEPTH
        depth = (c.MIN_DEPTH+c.MAX_DEPTH)/2;
    end
    
    %% Center to peach
    P = pixel_to_coordinates(gen3, depth, x, y, 0);
    curr_pose = f.get_curr_pose(gen3);
    command = [curr_pose(1) + P(1), curr_pose(2) + P(2), curr_pose(3) + P(3), ...
        curr_pose(4), curr_pose(5), curr_pose(6)];
    f.set_arm_pose(gen3, command);
    
    %% %% Take and load next pictures
    capture_img(c.RGB_DEPTH, "scrap.png");
    depth_img = imread('depth_img.png');
    
    x = c.X_RES/2;
    y = c.Y_RES/2;
    depth = get_depth(x, y, depth_img);
    
    % Calculate Depth
    if depth < c.MIN_DEPTH || depth > c.MAX_DEPTH
        depth = (c.MIN_DEPTH+c.MAX_DEPTH)/2;
    end
    
    %% Approach Peach
    P = pixel_to_coordinates(gen3, depth, x, y, depth);
    
    curr_pose = f.get_curr_pose(gen3);
    command = [curr_pose(1) + P(1), curr_pose(2) + P(2), curr_pose(3) + P(3), ...
        curr_pose(4), curr_pose(5), curr_pose(6)];
    f.set_arm_pose(gen3, command);
    %% Harvest and Deposit
    harvest_peach(gen3);
    % Move to collection position and drop peach in tray
    f.set_joint_angles(gen3, c.COLLECTION_POSITION);
    
    new_collection_position = update_collection(gen3, peaches_picked);
    f.set_arm_pose(gen3, new_collection_position);
    f.toggle_tool_state(gen3, c.OPEN_GRIPPER);
    %% Go Home
    f.set_joint_angles(gen3, c.HOME_POSITION);
end