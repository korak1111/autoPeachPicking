function harvest_peach(gen3)
    global f c
    f = kinova_api_wrapper;
    c = constants;
    % Grab Peach
    f.toggle_tool_state(gen3, c.CLOSE_GRIPPER);

    % Move down
    command = f.get_curr_pose(gen3);
    command(3) = command(3) - 0.02;
    f.set_arm_pose(gen3, command);

    % Get current joint angles
    command = f.get_curr_joint_angles(gen3);

    % Rotate gripper by 65 degrees
    command(7) = command(7) + 65;
    f.set_joint_angles(gen3, command);
    % Reverse
    command(7) = command(7) - 65;
    f.set_joint_angles(gen3, command);

    % Pull 20 cm away from the tree
    command = f.get_curr_joint_angles(gen3);
    command(1) = command(1) - 0.2;
    f.set_joint_angles(gen3, command);

end