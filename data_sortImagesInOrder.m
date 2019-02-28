function filenames = data_sortImagesInOrder(images)

num = numel(images);
filenames = cell(1, num);
order = zeros(1, num);

for n = 1 : num
    file = images(n).name;
    index = find(file=='_');
    order(n) = str2double(file(index(1)+1:index(2)-1));
end

[~, Index] = sort(order);

for n = 1 : num
    filenames{n} = images(Index(n)).name;
end

    
    

