function P = pixel_to_coordinates(gen3, depth, i, j, move_depth)

    
    %depth = 630;
    f = kinova_api_wrapper;

    %Get RGB camera parameters
    [isOk, RGB_intrinsic] = gen3.GetIntrinsicParameters(1);
    if ~isOk
        error('Failed to acquire Intrinsic Parameters for RGB sensor.');
    end

    %Get depth camera parameters
    [isOk, Depth_intrinsic] = gen3.GetIntrinsicParameters(2);
    if ~isOk
        error('Failed to acquire Intrinsic Parameters for depth sensor.');
    end

    %Get another set of parameters...
    [isOk, Extrinsic] = gen3.GetExtrinsicParameters();
    if ~isOk
        error('Failed to acquire Extrinsic Parameters.');
    end

    fx = 4.88;
    fy = 4.88;

    %Resolution
    %1280x720
    x_res = 1920;
    y_res = 1080;

    %Transformation matrix from depth camera frame to RGB camera frame
    %T_DE = [1, 0, 0, -0.02750;
    %        0, 1, 0, -0.06600+0.05639;
    %        0, 0, 1, 0;
    %        0, 0, 0, 1];

    %w_array = [0; 0; depth/1000; 0];
    %w_array = T_DE*w_array
    %w = w_array(3);

    %i = 1460; %pixel
    %j = 765; %pixel

    %i = 1025;
    %j = 960;

    %i_in=0; %Left-right if orineted with gripper +L, -R
    %j_in=0; %Up- Down , +UP, - Down
    %w_in=depth-170; %Depth, +Out, - retract

    % Centers at (0, 0), top left (-1280, -720), bottom right (1280, 720)
    %i = i_in-0.25; %x location of pixel from vision system
    %j =j_in-184.8; %y location of pixel from vision system
    % i =-0.25, j= -184.8
    %i = i_in;
    %j = j_in;

    %Convert pixel location to relative to center
    %i = x_res/2 - i
    %j = y_res/2 - j

    %Flip picture horizontally and vertically
    i = -i;
    j = -j;

    % -181.7 is depth 0, > -181.7 forward, < -181.7 backward

    w = depth;
    %w = w_in-178; %get depth from depth camera
    %p = 0.0081; %Scalar multiplier - 0.0081
    p = 0.002; %was 0.0006 %%Can modify this
    gripper_length = 0.160;%+0.053; %May need to be adjusted...

    u = (fx-w)/fx*i*p/1000; %convert to m
    v = (fy-w)/fy*j*p/1000; % convert to m

    %Cordinates in reference to colour sensor
    %P_C = [u; v; w/1000; 1]
    if (move_depth)
        P_C = [u; v; w/1000; 1];
    else
        P_C = [u; v; 0; 1];
        gripper_length = 0;
    end

    %Transformation matrix to camera frame - may not need this
    T_SC = [1, 0, 0, 0;
            0, 1, 0, 0;
            0, 0, 1, fx/1000;
            0, 0, 0, 1];

    %Transformation matrix from colour camera frame to end effector
    T_CE = [1, 0, 0, 0;
            0, 1, 0, -0.05639;
            0, 0, 1, 0.00305;
            0, 0, 0, 1];

    %Transformation matrix from depth camera frame to end effector
    T_DE = [1, 0, 0, -0.02750;
            0, 1, 0, -0.06600;
            0, 0, 1, 0.00305;
            0, 0, 0, 1];


    %Transformation matrix from end effector to gripper
    T_EG = [1, 0, 0, 0;
            0, 1, 0, 0.02; %was 0.04 %% Can modify this
            0, 0, 1, -gripper_length;
            0, 0, 0, 1];

    T_1 = [1, 0, 0, 0;
            0, -1, 0, 0;
            0, 0, -1, 0.1564;
            0, 0, 0, 1];
    T_2 = [1, 0, 0, 0;
            0, 0, -1, 0.0054;
            0, 1, 0, -0.1284;
            0, 0, 0, 1];
    T_3 = [1, 0, 0, 0;
            0, 0, 1, -0.2104;
            0, -1, 0, -0.0064;
            0, 0, 0, 1];
    T_4 = [1, 0, 0, 0;
            0, 0, -1, -0.0064;
            0, 1, 0, -0.2104;
            0, 0, 0, 1];
    T_5 = [1, 0, 0, 0;
            0, 0, 1, -0.2084;
            0, -1, 0, -0.0064;
            0, 0, 0, 1];
    T_6 = [1, 0, 0, 0;
            0, 0, -1, 0;
            0, 1, 0, -0.1059;
            0, 0, 0, 1];
    T_7 = [1, 0, 0, 0;
            0, 0, 1, -0.1059;
            0, -1, 0, 0;
            0, 0, 0, 1];
    T_Int = [1, 0, 0, 0;
            0, -1, 0, 0;
            0, 0, -1, -0.0615;
            0, 0, 0, 1];

    %Coordinates in reference to gripper location
    %P_G = T_EG * T_CE * T_SC * P_C
    P_G = T_EG*P_C;
    %P_G = T_SC * P_C;

    %Coordinates in reference to base location
    %P = T_1*T_2*T_3*T_4*T_5*T_6*T_7*T_Int*P_C


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
