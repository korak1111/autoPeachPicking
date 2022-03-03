
CAMERA_POSITION = [[345.31 90.48 4.88 271.78 190.21 101.33 270.6]; 
    [48.7 75.04 309.52 273.19 161.44 68.87 224.56];
    [76.58 74.49 286.94 275.33 148.35 41.23 221.99]; 
    [67.1 127.56 286.98 270.07 164.56 57.35 184.65];];

% [199.95 17.98 216.32 340.93 285.4 241.71 123.22];
%     [214.37 54.76 215.13 282.01 273.34 244.97 216.72];
%     [187.58 310.66 210.61 220.73 319.97 320.81 173.43];
%     [181.93 284.13 98.12 239.00 201.06 57.24 178.3]; 
%     [172.69 352.05 181.1 310.91 173.77 89.93 271.51];
%     [221.58 42.29 216.32 287.74 252.88 253.37 195.64];

count = 19;

global f 
f = kinova_api_wrapper;

gen3 = f.run_initalization();



for i = 1:length(CAMERA_POSITION)
    f.set_joint_angles(gen3, CAMERA_POSITION(i,:));
    
    capture_image(count);
    count = count + 1;
    
    command = f.get_curr_joint_angles(gen3);
    command(7) = command(7) + 45;
    
    f.set_joint_angles(gen3, command);
    
    capture_image(count);
    count = count + 1;
    
    command = f.get_curr_joint_angles(gen3);
    command(7) = command(7) - 90;
    
    f.set_joint_angles(gen3, command);
    
    capture_image(count);
    count = count + 1;
end

gen3.DestroyRobotApisWrapper();


function capture_image(count)
    % --- Display the Color Device Video --- %
    vid1 = videoinput('kinova_vision_imaq', 1, 'RGB24');
    vid1.FramesPerTrigger = 1;
    src1 = getselectedsource(vid1);
    
    % Change device properties
    src1.CloseConnectionOnStop = 'Enabled';
    src1.ResetROIOnResolutionChange = 'Disabled';
    
    preview(vid1);
    rgbData = getsnapshot(vid1);
    imwrite(rgbData, sprintf('dataset/rgb_img%d.png', count));
    
    closepreview(vid1);
    delete(vid1);
end
