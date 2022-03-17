
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

k = kinova_api_wrapper;

gen3 = k.run_initalization();

for i = 1:length(CAMERA_POSITION)
    pos_command = CAMERA_POSITION(i,:);
    count = move_and_capture_image(gen3, k, pos_command, count);
    
    pos_command(7) = pos_command(7) + 45;

    count = move_and_capture_image(gen3, k, pos_command, count);
    
    pos_command(7) = pos_command(7) - 90;
    
    count = move_and_capture_image(gen3, k, pos_command, count);
end

k.cleanup_on_teardown(gen3);

function count = move_and_capture_image(k, gen3, pos_command, count)
    k.set_joint_angles(gen3, pos_command);
    
    rgbData = getsnapshot(k.vidRGB);
    imwrite(rgbData, sprintf('dataset/rgb_img%d.png', count));
    
    count = count + 1;
end
