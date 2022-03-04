
classdef constants
    % Class containing constants used in peach picking
    properties (Constant)
        % Arm resting on table
        TABLE_POSITION = [272.98 86.37 173.84 244.56 359.57 109.91 98.39];
        % Arm in starting position to begin looking for peaches
        HOME_POSITION = [2.6 46.43 356.22 214.97 162.74 347.51 282.18];
        % Peach collection area position (0, 0)
        COLLECTION_POSITION_1 = [0.11 11.34 180.48 246.48 185.44 50.35 84.22];
        COLLECTION_POSITION_2 =[341.01 359.23 175.47 230.44 186.29 45.98 76.15];
        COLLECTION_POSITION_3 =[345.15 12.73 178.8 246.49 185.82 47.79 84.19];
        COLLECTION_POSITION_4 =[0.56 358.95 180.16 229.56 185.93 46.22 83.55];
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