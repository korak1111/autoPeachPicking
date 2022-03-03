
function peach_pixels = read_coordinates_from_file()
    file_name='coords.txt';
    
    while ~isfile(file_name) %wait for txt file
        disp("Waiting for file")
    end
    
    peach_pixels=dlmread(file_name);
    delete(file_name)
end
    
