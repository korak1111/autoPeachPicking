
classdef constants
    % Class containing constants used in peach picking
    properties (Constant)
%% Arm Locations
        % Arm resting on table
        TABLE_POSITION = [272.98 86.37 173.84 244.56 359.57 109.91 98.39];
        % Arm in starting position to begin looking for peaches
        %HOME_POSITION = [2.6 46.43 356.22 214.97 162.74 347.51 282.18];
        %HOME_POSITION_2 = [353.44 60.62 345.78 269.2 192.9 63.1 252.52];
        HOME_POSITION = [175.61 48.36 14.26 311.46 173.46 88.66 283.78];
        % Peach collection area position (0, 0)
        COLLECTION_POSITION = [157.69 34.67 105.23 281.97 143.55 349.03 338.34]; %fix to cartesian
%% Gripper Commands
        OPEN_GRIPPER = 0;
        CLOSE_GRIPPER = 1;
        PARTIAL_CLOSE_GRIPPER = 0.75;
%% Capture Mode
        RGB = 'rgb';
        DEPTH = 'depth';
        RGB_DEPTH = 'rgb_depth';

        MAX_DEPTH = 750;
        MIN_DEPTH = 750;

        X_RES = 1920;
        Y_RES = 1080;
    end
end