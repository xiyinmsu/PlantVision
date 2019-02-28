function [PlantLocations, PlantNames] = data_readLocationFile(filePath)

fid = fopen(filePath);
tline = fgetl(fid);

PlantLocations = zeros(50,4);
PlantNames = cell(50, 1);
n = 0;
while ischar(tline)
    n = n + 1;
    index = find(tline=='_');
    x = str2double(tline(1:index(1)-1));
    y = str2double(tline(index(1)+1:index(2)-1));
    w = str2double(tline(index(2)+1:index(3)-1));
    
    in = index(3)+1;
    while ~isnan(str2double(tline(in)))
        in = in + 1;
    end
    
    h = str2double(tline(index(3)+1:in-1));
    
    if x < 1
        x = 1;
    end
    if y <1
        y = 1;
    end
    
    PlantLocations(n, :) = [x, y, w, h];
    PlantNames{n} = tline(in+1:end);
    tline = fgetl(fid);
end

PlantLocations = PlantLocations(1:n, :);
PlantNames = PlantNames(1:n);











