function Filenames = data_preprocessTestImages(imagePath)

files = dir([imagePath, '*_Fmp.tif']);
nImage = numel(files);
Filenames = cell(nImage, 1);

if imagePath(end)~='\'
    imagePath = [imagePath, '\'];
end

order = zeros(nImage, 1);
for im = 1 : nImage
    filename = files(im).name;
    index = find(filename=='_');
    order(im) = str2double(filename(index(1)+1:index(2)-1));
end

[~, Index] = sort(order);

for im = 1 : nImage
    Filenames{im} = [imagePath, files(Index(im)).name];
end


    
