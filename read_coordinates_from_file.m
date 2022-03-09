function peach_pixels = read_coordinates_from_file()
    file_name='coords.txt';
    
    
    while ~isfile(file_name) %wait for txt file
        %disp("Waiting for file");
    end
    
    pause(1)
    try
        raw_data=dlmread(file_name);
    catch
%         In case of no peach
        peach_pixels=[];
        return
    end

    
    peach_pixels=[];
    for n=1:size(raw_data)
        temp=[raw_data(n,2)*1920, raw_data(n,3)*1080];
        peach_pixels = [peach_pixels; temp];

    end
%     peach_pixels=peach_pixels;
    delete(file_name);
end
    
