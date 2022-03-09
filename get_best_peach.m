function found_peach = get_best_peach(gen3, peach_coordinates)
    global f c;
    
    f = kinova_api_wrapper;
    c = constants;
%     command = f.get_curr_pose(gen3);
    best_dist=inf;
    best_n=0;
    %disp(peach_coordinates)
    x_res = 1920;
    y_res = 1080;

    for n=1:size(peach_coordinates, 1)
        abs_x = abs(peach_coordinates(n,1)-(x_res/2));
        abs_y = abs(peach_coordinates(n,2)-(y_res/2));
        dist=sqrt(abs_x^2 + abs_y^2);
        
        if dist<best_dist
            best_dist=dist;
            best_n=n;
        end
    end
    found_peach = peach_coordinates(best_n, :);
end