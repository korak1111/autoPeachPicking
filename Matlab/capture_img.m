
function capture_img(mode)
    imaqreset;
    imaqhwinfo;

    c = constants;
    
    if strcmp(mode, c.RGB) || strcmp(mode, c.RGB_DEPTH)
        capture_rgb_img()
    end
    if strcmp(mode, c.DEPTH) || strcmp(mode, c.RGB_DEPTH)
        capture_depth_img()
    end
end

function capture_rgb_img()
    % --- Display the Color Device Video --- %
    vid1 = videoinput('kinova_vision_imaq', 1, 'RGB24');
    vid1.FramesPerTrigger = 1;
    src1 = getselectedsource(vid1);
    
    % Change device properties
    src1.CloseConnectionOnStop = 'Enabled';
    src1.ResetROIOnResolutionChange = 'Disabled';
    
    preview(vid1);
    rgbData = getsnapshot(vid1);
    imwrite(rgbData, 'rgb_img.png')
    
    closepreview(vid1);
    delete(vid1);
end

function capture_depth_img()
    % --- Display the Depth Device Raw Video --- %
    vid2 = videoinput('kinova_vision_imaq', 2, 'MONO16');
    vid2.FramesPerTrigger = 1;
    src2 = getselectedsource(vid2);
    
    % Change device properties
    src2.CloseConnectionOnStop = 'Enabled';
    src2.ResetROIOnResolutionChange = 'Disabled';
    
    preview(vid2);
    % depthData pixel value units in mm
    depthData = getsnapshot(vid2);
    imwrite(depthData, 'depth_img.png')
    
    closepreview(vid2);
    delete(vid2);
end