
global k p

k = kinova_api_wrapper;
p = peach_picking;
peaches_picked = 0;
terminate = false;

gen3 = k.run_initalization();

k.set_joint_angles(gen3, k.TABLE_POSITION);

while ~terminate
    [terminate, peaches_picked] = pick_peaches(gen3, peaches_picked);
end
pick_peaches(gen3);

k.cleanup_on_teardown(gen3);


function [terminate, peaches_picked] = pick_peaches(gen3, peaches_picked)
    % Move arm to home position and open gripper
    k.set_joint_angles(gen3, c.HOME_POSITION);
    k.toggle_tool_state(gen3, c.OPEN_GRIPPER);

    % Capture rgb and depth images
    k.capture_img(k.RGB_DEPTH);

    % Wait to recieve peach pixel location of identified peaches 
    peach_pixels = k.read_coordinates_from_file();

    % Exit if there are no peaches identified or the collection try is full
    if peaches_picked == 4 || isempty(peach_pixels)
        terminate = true;
        return
    end

    peach_coords = zeros(size(peach_pixels));

    % Convert each found peach to coordinate locations
    for i = 1:size(peach_pixels)
        % --- Depth Calculation --- %

        peach_coords(i) = 0; % insert found coordinate from depth
    end

    % Calculate the closest peach to the gripper
    closest_peach = k.get_closest_peach(gen3, peach_coords);

    % --- Depth Movement --- %
    % insert move to center peach and then move in to grab peach
          

    harvest_peach(gen3);

    % Move to collection position and drop peach in tray
    k.set_joint_angles(gen3, c.COLLECTION_POSITION);
    collection_position = p.update_collection_position(gen3, peaches_picked);
    k.set_arm_pose(gen3, collection_position); 

    k.toggle_tool_state(gen3, c.OPEN_GRIPPER);

    peaches_picked = peaches_picked +1;

    k.set_joint_angles(gen3, c.HOME_POSITION);
end

function harvest_peach(gen3)
    % Grab Peach
    k.toggle_tool_state(gen3, k.CLOSE_GRIPPER);

    % Pull down slightly to eliminate slack
    pose_cmd = k.get_curr_pose(gen3);
    pose_cmd(3) = pose_cmd(3) - 0.02;
    k.set_arm_pose(gen3, pose_cmd);

    % Rotate gripper by 45 degrees
    joint_cmd = k.get_curr_joint_angles(gen3);
    joint_cmd(7) = joint_cmd(7) + 65;
    k.set_joint_angles(gen3, joint_cmd);
    
    % Move away from the tree
    pose_cmd = k.get_curr_pose(gen3);
    % Move down 3cm
    pose_cmd(3) = pose_cmd(3) - 0.03;
    % Pull 20cm away from the tree
    pose_cmd(1) = pose_cmd(1) + 0.2;
    k.set_arm_pose(gen3, pose_cmd);
end
