% Run this once in the command window
% imaqregister('C:\Program Files\Kinova\Vision Imaq\kinova_vision_imaq.dll');

function capture_rgb_and_depth_img
    imaqreset;
    imaqhwinfo;
    
    % --- Display the Color Device Video --- %
    vid1 = videoinput('kinova_vision_imaq', 1, 'RGB24');
    vid1.FramesPerTrigger = 1;
    src1 = getselectedsource(vid1);
    
    % Change device properties
    src1.CloseConnectionOnStop = 'Enabled';
    src1.ResetROIOnResolutionChange = 'Disabled';
    
    preview(vid1);
    rgbData = getsnapshot(vid1);
    imwrite(rgbData, 'rbg_img.png')
    
    closepreview(vid1);
    delete(vid1);
    
    % --- Display the Depth Device Raw Video --- %
    vid2 = videoinput('kinova_vision_imaq', 2, 'MONO16');
    vid2.FramesPerTrigger = 1;
    src2 = getselectedsource(vid2);
    
    % Change device properties
    src2.CloseConnectionOnStop = 'Enabled';
    src2.ResetROIOnResolutionChange = 'Disabled';
    
    preview(vid2);
    depthData = getsnapshot(vid2);
    imwrite(depthData, 'depth_img.png')
    
    % Depth units in mm
    
    depthData(135, 240)
    
    closepreview(vid2);
    delete(vid2);
end