function [nPlant, PlantIDs, PlantLocations, Filenames] = data_readInputTextFile(inputPath)

disp('reading input files and save into MATLAB variables')

fid = fopen(inputPath);
tline = fgetl(fid);

nPlant = str2double(tline);
PlantIDs = zeros(nPlant, 2);
PlantLocations = zeros(nPlant, 4);

for pt = 1 : nPlant
    tline = fgetl(fid);
    index = find(isspace(tline));
    PlantIDs(pt, 1) = str2double(tline(1:index(1)-1));
    PlantIDs(pt, 2) = str2double(tline(index(1)+1:index(2)-1));
    PlantLocations(pt, 1) = str2double(tline(index(2)+1:index(3)-1));
    PlantLocations(pt, 2) = str2double(tline(index(3)+1:index(4)-1));
    PlantLocations(pt, 3) = str2double(tline(index(4)+1:index(5)-1));
    PlantLocations(pt, 4) = str2double(tline(index(5)+1:end));
end

tline = fgetl(fid);
nImage = 0;
while ischar(tline)
    nImage = nImage + 1;
    files{nImage} = tline;
    tline = fgetl(fid);
end

Filenames = files(end:-1:1);
disp(['number of images: ', num2str(nImage)])
disp(['number of plants: ', num2str(nPlant)])

