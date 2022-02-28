% Run this once in the command window
% imaqregister('<full/path/to/kinova_vision_imaq library>');

% --- Display the Color Device Video --- %
vid1 = videoinput('kinova_vision_imaq', 1, 'RGB24');
vid1.FramesPerTrigger = 1;
src1 = getselectedsource(vid1);

% Optionally, view the adaptor version
imaqhwinfo(vid1)

% Optionally, change device properties
src1.CloseConnectionOnStop = 'Enabled';
src1.Ipv4Address = '10.20.0.100';
src1.ResetROIOnResolutionChange = 'Disabled';

% Optionally, change the Region of Interest
vid1.ROIPosition = [0 0 300 200];

preview(vid1);
closepreview(vid1);
delete(vid1);

% --- Display the Depth Device Raw Video --- %
% Note: For Linux, the adaptor name is libkinova_vision_imaq
vid2 = videoinput('kinova_vision_imaq', 2, 'MONO16');
vid2.FramesPerTrigger = 1;
src2 = getselectedsource(vid2);

% Optionally, view the adaptor version
imaqhwinfo(vid2)

% Optionally, change device properties
src2.CloseConnectionOnStop = 'Enabled';
src2.Ipv4Address = '10.20.0.100';
src2.ResetROIOnResolutionChange = 'Disabled';

% Optionally, change the Region of Interest
vid2.ROIPosition = [0 0 300 200];

preview(vid2);
closepreview(vid2);
delete(vid2);

% --- Settings --- %
% SetOptionValue
% OPTION_DEPTH_UNITS	Number of meters represented by a single depth unit 
% (supported on depth sensor only: 0.0001 to 0.0100, step 0.000001)

% depthData = getsnapshot(vidDepth);
% rgbData = getsnapshot(vidRGB);

% imwrite(A,'myGray.png')

