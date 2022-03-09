function make_it_clap(gen3)
	global f c 
 	f = kinova_api_wrapper;
    c = constants;
    f.set_joint_angles(gen3, c.HOME_POSITION);

    for n=1:6
    	f.toggle_tool_state(gen3, c.OPEN_GRIPPER);
    	f.toggle_tool_state(gen3, c.CLOSE_GRIPPER);
    end
