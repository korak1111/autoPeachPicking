clc
global f c peaches_picked 
%% Intialization
f = kinova_api_wrapper;
c = constants;
peaches_picked = 0;
terminate = false;

gen3 = f.run_initalization();

f.set_joint_angles(gen3, c.HOME_POSITION);
f.toggle_tool_state(gen3, c.CLOSE_GRIPPER);
f.toggle_tool_state(gen3, c.OPEN_GRIPPER);
%% Loop
while ~terminate
    terminate = pick_peaches2(gen3, peaches_picked);
    peaches_picked = peaches_picked +1;
end
%% Teardown
if peaches_picked==4
    make_it_clap(gen3);
    disp("Task completed sucessfully");
else
    disp("Out of Peaches")
end
gen3.DestroyRobotApisWrapper();
