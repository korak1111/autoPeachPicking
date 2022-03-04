function new_collection_position= update_collection(gen3, peaches_picked)
    global f c 
    f = kinova_api_wrapper;
    c = constants;
    % new_collection_position = f.get_curr_pose(gen3);
    new_collection_position = COLLECTION_POSITION_1;
    
    % Just using joint angles now, delta x and y dont matter.
    % delta_x = 0.125;
    % delta_y = 0.125;

    if peaches_picked == 1
        new_collection_position = COLLECTION_POSITION_2;
        % new_collection_position(1) = new_collection_position(1) - delta_x;
    elseif peaches_picked == 2
        new_collection_position = COLLECTION_POSITION_3
        % new_collection_position(2) = new_collection_position(2) + delta_y; 
    elseif peaches_picked == 3
        new_collection_position = COLLECTION_POSITION_4
        % new_collection_position(1) = new_collection_position(1) - delta_x;
        % new_collection_position(2) = new_collection_position(2) + delta_y;        
    end

    
end