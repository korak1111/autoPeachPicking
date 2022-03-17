
k = kinova_api_wrapper;
p = peach_picking;
peaches_picked = 0;
terminate = p.RUNNING;

[k, gen3] = k.run_initalization();

k.toggle_tool_state(gen3, k.OPEN_GRIPPER);
k.set_joint_angles(gen3, k.HOME_POSITION);

while strcmp(terminate, p.RUNNING)
    [terminate, peaches_picked] = pick_peaches(gen3, k, p, peaches_picked);
end

p.end_sequence(gen3, terminate);

k.cleanup_on_teardown(gen3);


function [terminate, peaches_picked] = pick_peaches(gen3, k, p, peaches_picked)
    k.capture_img(k.RGB_DEPTH);

    disp("Running Neural Network");
    % Wait to recieve peach pixel locations of identified peaches 
    peach_pixels = p.read_coordinates_from_file()
    disp("Image Recognition Complete");

    % Exit if there are no peaches identified or the collection try is full
    if peaches_picked == 4
        terminate = p.COLLECTION_TRAY_FULL;
        return
    elseif isempty(peach_pixels)
        terminate = p.OUT_OF_PEACHES;
        return
    else
        terminate = p.RUNNING;
    end

    % Calculate the closest peach to the gripper
    closest_peach = p.get_closest_peach(gen3, peach_pixels);
    x = closest_peach(1);
    y = closest_peach(2);

    depth = p.get_depth(x, y);

    % Move to peach
    peach_offset = p.pixel_to_coordinates(gen3, depth, x, y);
    curr_pose = k.get_curr_pose(gen3);
    command = [curr_pose(1) + peach_offset(1), curr_pose(2) + peach_offset(2), ...
        curr_pose(3) + peach_offset(3), curr_pose(4), curr_pose(5), curr_pose(6)];
    k.set_arm_pose(gen3, command);     

    p.harvest_peach(gen3);

    % Move to collection position and drop peach in tray
    k.set_joint_angles(gen3, k.HOME_POSITION);
    k.set_joint_angles(gen3, k.COLLECTION_POSITION);

    p.update_collection_position(gen3, peaches_picked);

    k.toggle_tool_state(gen3, k.OPEN_GRIPPER);

    peaches_picked = peaches_picked + 1;

    k.set_joint_angles(gen3, k.HOME_POSITION);
end