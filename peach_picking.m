classdef peach_picking
    % Properties and methods used for identifying, harvesting, and
    % collecting peaches
    
    properties (Constant)
        k = kinova_api_wrapper
        collection_tray_size = [2 2]
        collection_tray_delta_x = 0.125;
        collection_tray_delta_y = 0.125;
    end

    methods (Static)
        function peach_pixels = read_coordinates_from_file()
            file_name = 'coords.txt';
            
            while ~isfile(file_name)
                disp("Waiting for file")
            end
            
            peach_pixels = readmatrix(file_name);
            delete(file_name)
        end
    end

    methods
        function kinova_clap(obj, gen3)
            obj.k.set_joint_angles(gen3, obj.k.HOME_POSITION);
        
            for n=1:6
    	        obj.k.toggle_tool_state(gen3, obj.k.OPEN_GRIPPER);
    	        obj.k.toggle_tool_state(gen3, obj.k.CLOSE_GRIPPER);
            end
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

        function position = update_collection_position(obj, peaches_picked)
            position = f.COLLECTION_POSITION;

            i = mod(peaches_picked, obj.collection_tray_size(1)) + 1;
            j = floor(peaches_picked/obj.collection_tray_size(2)) + 1;

            for x = 1:i-1
                position(1) = position(1) - delta_x;
            end
            
            for y = 1:j-1
                position(2) = position(2) + delta_y; 
            end
        end
    end
end