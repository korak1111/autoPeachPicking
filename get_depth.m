function depth = get_depth(x, y, depth_img)

    global c 
    c = constants;
    %x_RGB_res = 1920;
    %y_RGB_res = 1080;
    x_depth_res = 480;
    y_depth_res = 270;
 
    x_depth= [];
    y_depth = [];
    count = 0;
    sum_depth = 0;
    for i = 1:5
        if i == 1
            factorx = 0;
            factory = 0;
        elseif i == 2
            factorx = 5;
            factory = 5;
        elseif i == 3
            factorx = 5;
            factory = -5;
        elseif i == 4
            factorx = -5;
            factory = -5;
        elseif i == 5
            factorx = -5;
            factory = 5;
        end
        x_depth(i) = round(x*x_depth_res/c.X_RES)+factorx;
        y_depth(i) = round(y*y_depth_res/c.Y_RES)+factory;

        depth = double(depth_img(y_depth(i), x_depth(i)));
        if depth ~= 0
            count = count + 1;
            sum_depth = sum_depth + depth;
        end
    end
    depth = sum_depth / count;
end