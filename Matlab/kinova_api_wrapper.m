
classdef kinova_api_wrapper
    % Class containing methods used for interfacing with Kinova api
    methods (Static)
        function gen3 = run_initalization()
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
        
            % Connect to vision module
            imaqregister('C:\Program Files\Kinova\Vision Imaq\kinova_vision_imaq.dll');
        end
    end

    methods
        function gen3 = toggle_tool_state(gen3, command)
            % 1 fully close, 0 fully open
            toolCmd = command;
            toolMode = int32(3);
            toolDuration = 0; 
        
            isOk = gen3.SendToolCommand(toolMode, toolDuration, toolCmd);
        
            pause(1)
            
            if isOk
                disp('Command sent to the gripper. Wait for the gripper to open.')
            else
                error('Command Error.');
            end
        end
        
        function set_joint_angles(gen3, command)
            jointCmd = command;
            constraintType = int32(0);
            speed = 0;
            duration = 0;
        
            gen3.SendJointAngles(jointCmd, constraintType, speed, duration);
        
            status = 1;
            while status
                
                [isOk,~, ~, ~] = gen3.SendRefreshFeedback();
                pause(1)
        
                if isOk
                    disp('Command sent to the robot. Wait for the robot to stop moving.');
                    
                    [~,status] = gen3.GetMovementStatus();
                else
                    disp('Command error.');
                end
            end
        end
        
        function set_arm_pose(gen3, command)
            cartCmd = command;
            constraintType = int32(0);
            speeds = [0, 0];
            duration = 0;
             
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
        
        function curr_pose = get_curr_pose(gen3)
            [~, baseFb, ~, ~] = gen3.SendRefreshFeedback();
            curr_pose = baseFb.tool_pose;
        end
        
        function curr_joint_angles = get_curr_joint_angles(gen3)
            [~, ~, actuatorsFb, ~] = gen3.SendRefreshFeedback();
            curr_joint_angles = actuatorsFb.position;
        end
    end
end