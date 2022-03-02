clc
clear all
file_name='coords.txt';

while ~isfile(file_name) %wait for txt file
    disp("Waiting for file")
end

peach_coords=dlmread(file_name);
delete(file_name)
    
