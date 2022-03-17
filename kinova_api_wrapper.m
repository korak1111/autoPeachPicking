
classdef kinova_api_wrapper
    % Properties and methods used for interfacing with the Kinova Gen3

    properties(SetAccess=private)
        vidRGB
        vidDepth
    end
    
    properties (Constant)
        % Arm in starting position to begin looking for peaches
        HOME_POSITION = [175.61 48.36 14.26 311.46 173.46 88.66 283.78];
        % Collection area position (0,0) located in top left corner of tray
        COLLECTION_POSITION = [160.73 64.31 58.17 298.78 246.62 38.73 283.79];
        % Position for end sequence clapping
        CLAP_POSITION = [175.64 49.96 14.65 314 250 55 279.86];
        % Gripper Commands
        OPEN_GRIPPER = 0;
        CLOSE_GRIPPER = 1;
        % Capture Mode
        RGB = 'RGB';
        DEPTH = 'DEPTH';
        RGB_DEPTH = 'RGB_DEPTH';
        % Resolution
        RGB_RESOLUTION = [1920 1080];
    end

    methods
        function [obj, gen3] = run_initalization(obj)
            Simulink.importExternalCTypes(which('kortex_wrapper_data.h'));
            gen3 = kortex();
            gen3.ip_address = '192.168.1.10';
            gen3.user = 'admin';
            gen3.password = 'admin';
        
            isOk = gen3.CreateRobotApisWrapper();
        
            if isOk
               disp('You are connected to the robot!'); 
            else
               error('Failed to establish a valid connection!');
            end
        
            % --- Connect to vision module --- %
            imaqregister('C:\Program Files\Kinova\Vision Imaq\kinova_vision_imaq.dll');

            % --- Initialize RGB Video --- %
            obj.vidRGB = videoinput('kinova_vision_imaq', 1, 'RGB24');
            obj.vidRGB.FramesPerTrigger = 1;

            srcRGB = getselectedsource(obj.vidRGB);
            srcRGB.CloseConnectionOnStop = 'Enabled';
            srcRGB.ResetROIOnResolutionChange = 'Disabled';

            % --- Initialize Depth Video --- %
            obj.vidDepth = videoinput('kinova_vision_imaq', 2, 'MONO16');
            obj.vidDepth.FramesPerTrigger = 1;

            srcDepth = getselectedsource(obj.vidDepth);
            srcDepth.CloseConnectionOnStop = 'Enabled';
            srcDepth.ResetROIOnResolutionChange = 'Disabled';
        end

        function capture_img(obj, mode)
            % imaqreset;
            % imaqhwinfo;

            if strcmp(mode, obj.RGB) || strcmp(mode, obj.RGB_DEPTH)
                rgbData = getsnapshot(obj.vidRGB);
                imwrite(rgbData, 'rgb_img.png')
            end
            if strcmp(mode, obj.DEPTH) || strcmp(mode, obj.RGB_DEPTH)
                depthData = getsnapshot(obj.vidDepth);
                imwrite(depthData, 'depth_img.png')
            end
        end

        function curr_pose = get_curr_pose(obj, gen3)
            [~, baseFb, ~, ~] = gen3.SendRefreshFeedback();
            curr_pose = baseFb.tool_pose;
        end
        
        function curr_joint_angles = get_curr_joint_angles(obj, gen3)
            [~, ~, actuatorsFb, ~] = gen3.SendRefreshFeedback();
            curr_joint_angles = actuatorsFb.position;
        end
        
        function intrinsic_paramters = get_intrinsic_parameters(obj, gen3)
            [~, RGB_intrinsic] = gen3.GetIntrinsicParameters(1);
            intrinsic_paramters = RGB_intrinsic;
        end

        function set_arm_pose(obj, gen3, command)
            cartCmd = command;
            constraintType = int32(0);
            speeds = [0, 0]; % use default value
            duration = 0; % use default value
             
            gen3.SendCartesianPose(cartCmd, constraintType, speeds, duration);
        
            status = 1;
            while status
                
                [isOk,~, ~, ~] = gen3.SendRefreshFeedback();
                pause(1);
        
                if isOk  
                    [~,status] = gen3.GetMovementStatus();
                else
                    disp('Command error.');
                end
            end
        end

        function set_joint_angles(obj, gen3, command)
            jointCmd = command;
            constraintType = int32(0);
            speed = 0; % use default value
            duration = 0; % use default value
        
            gen3.SendJointAngles(jointCmd, constraintType, speed, duration);
        
            status = 1;
            while status
                [isOk, ~, ~, ~] = gen3.SendRefreshFeedback();
                pause(1)
        
                if isOk
                    [~,status] = gen3.GetMovementStatus();
                else
                    disp('Command error.');
                end
            end
        end

        function toggle_tool_state(obj, gen3, command)
            toolCmd = command;
            toolMode = int32(3);
            toolDuration = 0; % use default value
        
            isOk = gen3.SendToolCommand(toolMode, toolDuration, toolCmd);    
            pause(1)
            
            if ~isOk
                error('Command Error.');
            end
        end

         function cleanup_on_teardown(obj, gen3)
            delete(obj.vidRGB);
            delete(obj.vidDepth);
            gen3.DestroyRobotApisWrapper();
         end
    end
end