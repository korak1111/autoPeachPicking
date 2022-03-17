classdef peach_picking
    % Properties and methods used for identifying, harvesting, and
    % collecting peaches
    
    properties (Constant)
        k = kinova_api_wrapper
        DEPTH_FOV = [110 116 257 154];
        COLLECTION_TRAY_SIZE = [2 2]
        COLLECTION_TRAY_DELTA_X = 0.125
        COLLECTION_TRAY_DELTA_Y = 0.125
        % Terminate Modes
        RUNNING = 'RUNNING'
        OUT_OF_PEACHES = 'OUT_OF_PEACHES'
        COLLECTION_TRAY_FULL = 'COLLECTION_TRAY_FULL'
        % Coordinate Handshake File Name
        FILE_NAME = 'coords.txt'
    end

    methods
        function peach_pixels = read_coordinates_from_file(obj, gen3)            
            while ~isfile(obj.FILE_NAME)
                %disp("Waiting for file");
            end
            
            pause(1)
            peach_pixels=[];
            try
                raw_data=dlmread(obj.FILE_NAME);
            catch
                % In case of no peach
                delete(obj.FILE_NAME);
                return
            end

            for n=1:size(raw_data)
                temp=[raw_data(n,2) * obj.k.RGB_RESOLUTION(1), ...
                    raw_data(n,3) * obj.k.RGB_RESOLUTION(2), ...
                    raw_data(n,4) * obj.k.RGB_RESOLUTION(1), ...
                    raw_data(n,5) * obj.k.RGB_RESOLUTION(2)];
                peach_pixels = [peach_pixels; temp];  
            end
        
            delete(obj.FILE_NAME);
        end

        function kinova_clap(obj, gen3)
            obj.k.set_joint_angles(gen3, obj.k.CLAP_POSITION);
        
            for n=1:6
    	        obj.k.toggle_tool_state(gen3, obj.k.OPEN_GRIPPER);
    	        obj.k.toggle_tool_state(gen3, obj.k.CLOSE_GRIPPER);
            end
        end

        function harvest_peach(obj, gen3)
            % Grab Peach
            obj.k.toggle_tool_state(gen3, obj.k.CLOSE_GRIPPER);
        
            % Pull down slightly to eliminate slack
            pose_cmd = obj.k.get_curr_pose(gen3);
            pose_cmd(3) = pose_cmd(3) - 0.02;
            obj.k.set_arm_pose(gen3, pose_cmd);
        
            % Rotate gripper by 65 degrees
            joint_cmd = obj.k.get_curr_joint_angles(gen3);
            joint_cmd(7) = joint_cmd(7) + 65;
            obj.k.set_joint_angles(gen3, joint_cmd);
            
            % Move away from the tree
            pose_cmd = obj.k.get_curr_pose(gen3);
            % Move down 2cm
            pose_cmd(3) = pose_cmd(3) - 0.02;
            % Pull 20cm away from the tree
            pose_cmd(1) = pose_cmd(1) - 0.2;
            obj.k.set_arm_pose(gen3, pose_cmd);
        end

        function closest_peach = get_closest_peach(obj, gen3, coordinates)
            min_dist = inf;
            idx_closest_peach = 0;
            curr_pose = obj.k.get_curr_pose(gen3);
        
            for idx = 1:size(coordinates, 1)
                abs_x = abs(curr_pose(1) - coordinates(idx,1));
                abs_y = abs(curr_pose(2) - coordinates(idx,2));
                curr_dist = sqrt(abs_x^2 + abs_y^2);

                if curr_dist < min_dist
                    min_dist = curr_dist;
                    idx_closest_peach = idx;
                end
            end

            closest_peach = coordinates(idx_closest_peach, :);
        end

        function depth = get_depth(obj, x, y)
            % Crop depth image to RGB FOV
            depth_img = imread('depth_img.png');
            depth_img = imcrop(depth_img, obj.DEPTH_FOV);
        
            x_depth = round(x*(size(depth_img, 2)/obj.k.RGB_RESOLUTION(1)));
            y_depth = round(y*(size(depth_img, 1)/obj.k.RGB_RESOLUTION(2)));

            count = 0;
            depthSum = 0;
        
            % Average depth readings found in 7x7 array
            for i = (y_depth-3):(y_depth+3)
                for j = (x_depth-3):(x_depth+3)
                    if(depth_img(i,j) > 0)
                        depthSum = depthSum + uint64(depth_img(i,j));
                        count = count + 1;
                    end
                end
            end
               
            depth = double(depthSum / count);
        end

        function update_collection_position(obj, gen3, peaches_picked)
            position = obj.k.get_curr_pose(gen3);

            i = mod(peaches_picked, obj.COLLECTION_TRAY_SIZE(1)) + 1;
            j = floor(peaches_picked / obj.COLLECTION_TRAY_SIZE(2)) + 1;

            for x = 1:i-1
                position(1) = position(1) + obj.COLLECTION_TRAY_DELTA_X;
            end
            
            for y = 1:j-1
                position(2) = position(2) - obj.COLLECTION_TRAY_DELTA_Y; 
            end

            obj.k.set_arm_pose(gen3, position); 
        end

        function P = pixel_to_coordinates(obj, gen3, depth, i, j)
            RGB_intrinsic = obj.k.get_intrinsic_parameters(gen3);
        
            fx = RGB_intrinsic.focal_length_x;
            fy = RGB_intrinsic.focal_length_y;

            ppx = obj.k.RGB_RESOLUTION(1)/2;
            ppy = obj.k.RGB_RESOLUTION(2)/2;
        
            u = -(i-ppx)/fx*depth/1000;
            v = -(j-ppy)/fy*depth/1000;

            P_C = [u; v; depth/1000; 1];

            x_offset = -0.04; % right + / left -
            gripper_length = 0.17; % Reduce to go further

            if j <= 350
                y_offset = -0.055; % Increase to go up
            elseif j > 350 && j < 900
                y_offset = -0.055;
            else
                y_offset = -0.075;
            end
        
            %Transformation matrix from end effector to gripper
            T_EG = [1, 0, 0, -x_offset;
                    0, 1, 0, y_offset;
                    0, 0, 1, -gripper_length;
                    0, 0, 0, 1];
        
            %Coordinates in reference to gripper location
            P_G = T_EG*P_C;
        
            curr_pose = obj.k.get_curr_pose(gen3);
            alpha = curr_pose(4);
            beta = curr_pose(5);
            gamma = curr_pose(6);
        
            R = [cosd(alpha)*cosd(beta), cosd(alpha)*sind(beta)*sind(gamma) - sind(alpha)*cosd(gamma), cosd(alpha)*sind(beta)*cosd(gamma) + sind(alpha)*sind(gamma);
                 sind(alpha)*cosd(beta), sind(alpha)*sind(beta)*sind(gamma) + cosd(alpha)*cosd(gamma), sind(alpha)*sind(beta)*cosd(gamma) - cosd(alpha)*sind(gamma);
                 -sind(beta), cosd(beta)*sind(gamma), cosd(beta)*cosd(gamma)];
            P_G = [P_G(1); P_G(2); P_G(3)];
            P = R*P_G;
        end

        function end_sequence(obj, gen3, terminate)

            if strcmp(terminate, obj.COLLECTION_TRAY_FULL)
                obj.kinova_clap(gen3)
                disp("Task completed sucessfully");
                
            elseif strcmp(terminate, obj.OUT_OF_PEACHES)
                disp("Out of Peaches")
            else
                disp("Unkown Error")
            end
        end
    end
end