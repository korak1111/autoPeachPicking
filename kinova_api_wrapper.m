
classdef kinova_api_wrapper
    % Properties and methods used for interfacing with the Kinova Gen3

    properties(SetAccess=private)
        vidRGB
        vidDepth
    end
    
    properties (Constant)
        % Arm resting on table
        TABLE_POSITION = [272.98 86.37 173.84 244.56 359.57 109.91 98.39];
        % Arm in starting position to begin looking for peaches
        HOME_POSITION = [2.6 46.43 356.22 214.97 162.74 347.51 282.18];
        % Collection area position (0,0) located in top left corner of tray
        COLLECTION_POSITION = [0.11 11.34 180.48 246.48 185.44 50.35 84.22];
        % Gripper Commands
        OPEN_GRIPPER = 0;
        CLOSE_GRIPPER = 1;
        % Capture Mode
        RGB = 'rgb';
        DEPTH = 'depth';
        RGB_DEPTH = 'rgb_depth';
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

        function capture_img(mode)
            % imaqreset;
            % imaqhwinfo;
            
            if strcmp(mode, obj.k.RGB) || strcmp(mode, obj.k.RGB_DEPTH)
                rgbData = getsnapshot(obj.k.vidRGB);
                imwrite(rgbData, 'rgb_img.png')
            end
            if strcmp(mode, c.DEPTH) || strcmp(mode, c.RGB_DEPTH)
                depthData = getsnapshot(obj.k.vidDepth);
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
                    disp('Command sent to the robot. Wait for the robot to stop moving.');
                    
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
                    disp('Command sent to the robot. Wait for the robot to stop moving.');
                    
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
            
            if isOk
                disp('Command sent to the gripper. Wait for the gripper to open.')
            else
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