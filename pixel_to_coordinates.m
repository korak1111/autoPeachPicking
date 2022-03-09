function P = pixel_to_coordinates(gen3, depth, i, j, move_depth)
    

    global c f

    c = constants;
    f = kinova_api_wrapper;

    %Get RGB camera parameters
    [isOk, RGB_intrinsic] = gen3.GetIntrinsicParameters(1);
    if ~isOk
        error('Failed to acquire Intrinsic Parameters for RGB sensor.');
    end

    %x_res = 1920;
    %y_res = 1080;

    %fx = 4.88;
    %fy = 4.88;
    fx = RGB_intrinsic.focal_length_x;
    fy = RGB_intrinsic.focal_length_y;

    %ppx = RGB_intrinsic.principal_point_x;
    %ppy = RGB_intrinsic.principal_point_y;

    ppx = c.X_RES/2;
    ppy = c.Y_RES/2;
    
    
    %Convert pixel location to relative to center
    %i = x_res/2 - i
    %j = y_res/2 - j

    %Flip picture horizontally and vertically
    %i = -i;
    %j = -j;

    gripper_length = 0.160; %+0.053; %May need to be adjusted...

    %u = w/fx*i/1000; %convert to m
    %v = w/fy*j/1000; % convert to m

    u = -(i-ppx)/fx*depth/1000
    v = -(j-ppy)/fy*depth/1000

    %Cordinates in reference to colour sensor
    %P_C = [u; v; w/1000; 1]
    P_C = [u; v; move_depth/1000; 1]
    %P_C = [0.4; 0; depth/1000; 1]
    if move_depth < depth
        %P_C = [u/2; v/2; move_depth/1000; 1]
        gripper_length = 0;
        y_offset = 0;
    else
        y_offset = 0.05;
        gripper_length = 0.2;
        %P_C = [u; v; move_depth/1000; 1]
    end

    %y_offset = 0;
    %Transformation matrix from end effector to gripper
    T_EG = [1, 0, 0, 0;
            0, 1, 0, -y_offset;
            0, 0, 1, -gripper_length;
            0, 0, 0, 1];

    %Coordinates in reference to gripper location
    P_G = T_EG*P_C

    curr_pose = f.get_curr_pose(gen3);
    alpha = curr_pose(4);
    beta = curr_pose(5);
    gamma = curr_pose(6);

    R = [cosd(alpha)*cosd(beta), cosd(alpha)*sind(beta)*sind(gamma) - sind(alpha)*cosd(gamma), cosd(alpha)*sind(beta)*cosd(gamma) + sind(alpha)*sind(gamma);
         sind(alpha)*cosd(beta), sind(alpha)*sind(beta)*sind(gamma) + cosd(alpha)*cosd(gamma), sind(alpha)*sind(beta)*cosd(gamma) - cosd(alpha)*sind(gamma);
         -sind(beta), cosd(beta)*sind(gamma), cosd(beta)*cosd(gamma)];
    P_G = [P_G(1); P_G(2); P_G(3)];
    P = R*P_G;
end
