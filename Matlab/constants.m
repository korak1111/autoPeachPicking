
classdef constants
    % Class containing constants used in peach picking
    properties (Constant)
        % Arm resting on table
        TABLE_POSITION = [272.98 86.37 173.84 244.56 359.57 109.91 98.39];
        % Arm in starting position to begin looking for peaches
        HOME_POSITION = [2.6 46.43 356.22 214.97 162.74 347.51 282.18];
        % Peach collection area position (0, 0)
        COLLECTION_POSITION = [0.11 11.34 180.48 246.48 185.44 50.35 84.22];
        % Gripper Commands
        OPEN_GRIPPER = 0;
        CLOSE_GRIPPER = 1;
        PARTIAL_CLOSE_GRIPPER = 0.75;
        % Capture Mode
        RGB = 'rgb';
        DEPTH = 'depth';
        RGB_DEPTH = 'rgb_depth';
    end
end