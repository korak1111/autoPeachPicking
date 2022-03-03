
CAMERA_POSITION = [[1 2 3 4 5 6 7]; [1 2 3 4 5 6 7]; [1 2 3 4 5 6 7]; 
    [1 2 3 4 5 6 7]; [1 2 3 4 5 6 7]; [1 2 3 4 5 6 7]];
count = 1;

for i = 1:length(CAMERA_POSITION)
    f.set_joint_angles(gen3, CAMERA_POSITION(i));
    
    capture_image(count);
    count = count + 1;
    
    command = f.get_curr_pose(gen3);
    command(7) = command(7) + 45;
    
    f.set_joint_angles(gen3, command);
    
    capture_image(count);
    count = count + 1;
    
    command = f.get_curr_pose(gen3);
    command(7) = command(7) - 90;
    
    f.set_joint_angles(gen3, command);
    
    capture_image(count);
    count = count + 1;
end

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
    imwrite(rgbData, sprintf('rgb_img%d.png', count));
    
    closepreview(vid1);
    delete(vid1);
end
