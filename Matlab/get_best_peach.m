function found_peach = get_best_peach(gen3, peach_coordinates)
    global f c 
    
    f = kinova_api_wrapper;
    c = constants;
    command = f.get_curr_pose(gen3);
    best_dist=inf;
    best_n=0;
    disp(peach_coordinates)

    for n=1:size(peach_coordinates, 1)
        abs_x = abs(command(1)-peach_coordinates(n,1));
        abs_y = abs(command(2)-peach_coordinates(n,2));
        dist=sqrt(abs_x^2 + abs_y^2);
        
        if dist<best_dist
            best_dist=dist;
            best_n=n;
        end
    end
    found_peach = peach_coordinates(best_n, :);
end