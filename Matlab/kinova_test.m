
clc

global f c peaches_picked

f = kinova_api_wrapper;
c = constants;
peaches_picked = 0;

gen3 = f.run_initalization();
terminate = false;

while ~terminate
    terminate = pick_peaches(gen3);
end

% f.toggle_tool_state(gen3, c.OPEN_GRIPPER);

gen3.DestroyRobotApisWrapper();


function terminate = pick_peaches(gen3)
    global f c peaches_picked

    terminate = false;

%     f.set_joint_angles(gen3, c.TABLE_POSITION);
    f.set_joint_angles(gen3, c.HOME_POSITION);

%     f.toggle_tool_state(gen3, c.OPEN_GRIPPER);
    
    %% --- Vision Method --- %%
%     capture_img(c.RGB_DEPTH);
%     peach_pixels = read_coordinates_from_file() %Get pixel Locatoins

%     if (peaches_picked == 4) || isempty(peach_pixels) %Terimantion Condtions
    if (peaches_picked == 4)
        terminate = true;
        return
    end

    depth_img = imread('depth_img.png');
    peach_coordinates = [];

    %% Determine which peach to pick 
    
%     for n=1:size(peach_pixels,1)
%         x_RGB_res = 1920;
%         y_RGB_res = 1080;
%         x_depth_res = 480;
%         y_depth_res = 270;
% 
%         x = peach_pixels(n,1);
%         y = peach_pixels(n,2);
% 
%         x_depth = round(x*x_depth_res/x_RGB_res)+1;
%         y_depth = round(y*y_depth_res/y_RGB_res)+1;
%     
%         depth = double(depth_img(y_depth, x_depth));
% 
%         curr_coord = pixel_to_coordinates(gen3, depth, x, y, 0);
%         peach_coordinates = [peach_coordinates; transpose(curr_coord)];
% 
%     end

%     found_peach = get_best_peach(gen3, peach_coordinates);
    found_peach = [-0.751 0.127 0.376];

    
    % Get current cartesian pose of tool      
    curr_pose = f.get_curr_pose(gen3);
    
    % Create command to move tool to peach position while keeping the
    % existing tool orientation
    command = [found_peach(1), found_peach(2), found_peach(3), ...
        curr_pose(4), curr_pose(5), curr_pose(6)];
    
    % Move to peach location
    f.set_arm_pose(gen3, command);

    curr_pose = f.get_curr_pose(gen3);
    
%     if sum(curr_pose == command) ~= length(command)
%         f.set_joint_angles(gen3, c.HOME_POSITION);
%     end
% 
%     while sum(curr_pose == command) ~= length(command)
%     %     Move forward 10cm and try again
%     
%         update_pose = curr_pose;
%         update_pose(1) = update_pose(1) - 0.1;
%     
%         f.set_arm_pose(gen3, update_pose);
%         
%         curr_pose = f.get_curr_pose(gen3)
%     
%         f.set_arm_pose(gen3, command);
%     
%         curr_pose = f.get_curr_pose(gen3)
%     
%     end
    
    harvest_peach(gen3);
%     

    f.set_joint_angles(gen3, c.COLLECTION_POSITION);

    % Move to collection position and drop peach in tray
    new_collection_position = update_collection(gen3, peaches_picked);
    f.set_arm_pose(gen3, new_collection_position); 

    curr_pose = f.get_curr_pose(gen3);

    peaches_picked = peaches_picked +1;
    f.toggle_tool_state(gen3, c.OPEN_GRIPPER);

    f.set_joint_angles(gen3, c.HOME_POSITION);
% 

end

function harvest_peach(gen3)
    global f c
    % Grab Peach
    f.toggle_tool_state(gen3, c.CLOSE_GRIPPER);

    command = f.get_curr_pose(gen3);
    command(3) = command(3) - 0.02;
    f.set_arm_pose(gen3, command);

    % Get current joint angles
    command = f.get_curr_joint_angles(gen3);
    % Rotate gripper by 45 degrees
    command(7) = command(7) + 65;
    
    % Command joint movement to twist gripper
    f.set_joint_angles(gen3, command);
    
    % Get current cartesian pose
    command = f.get_curr_pose(gen3);
    % Move gripper down 5cm
    command(3) = command(3) - 0.03;
    % Pull 5cm away from the tree
    command(1) = command(1) + 0.2;
    
    % Command movement to pull down
    f.set_arm_pose(gen3, command);
end

% 
% % capture_img(c.RGB_DEPTH);
% depth_img = imread('depth_img.png');
% rgb_img = imread('rgb_img.png');
% 
% % h = imshow(rgb_img);
% % hp = impixelinfo;
% 
% %x = 1460; %pixel
% %y = 765; %pixel
% 
% x = 340;
% y = 950;
% 
% x_RGB_res = 1920;
% y_RGB_res = 1080;
% x_depth_res = 480;
% y_depth_res = 270;
% 
% x_depth = round(x*x_depth_res/x_RGB_res)+1;
% y_depth = round(y*y_depth_res/y_RGB_res)+1;
% 
% %depth = double(depth_img(y_depth, x_depth))
% depth = 630;
% 
% P = pixel_to_coordinates(gen3, depth, x, y, 0);
% 
% curr_pose = f.get_curr_pose(gen3);
% command = [curr_pose(1) + P(1), curr_pose(2) + P(2), curr_pose(3) + P(3), curr_pose(4), curr_pose(5), curr_pose(6)]


% f.set_arm_pose(gen3, command);
% 
% curr_pose = f.get_curr_pose(gen3);

% while sum(curr_pose == command) ~= length(command)
% %     Move forward 10cm and try again

%     update_pose = curr_pose;
%     update_pose(1) = update_pose(1) - 0.1;
% 
%     f.set_arm_pose(gen3, update_pose);
%     
%     curr_pose = f.get_curr_pose(gen3)
% 
%     f.set_arm_pose(gen3, command);
% 
%     curr_pose = f.get_curr_pose(gen3)

% end

% [-0.758 0.145 0.362];

