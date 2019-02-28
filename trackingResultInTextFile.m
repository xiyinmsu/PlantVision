function trackingResultInTextFile(Filenames, PlantNames, PlantLocations, edges, areas, outputPath)

nImage = numel(Filenames);    
nPlant = size(PlantLocations, 1);

if outputPath(end)~='\'
    outputPath = [outputPath, '\'];
end
    
% calculate how many leaves are there in one image
allLeafNum = zeros(nImage, 1);
for im = 1 : nImage
    num = 0;
    for pt = 1 : nPlant
        EP = edges{pt, im};
        nLeaf = numel(EP);
        for i = 1 : nLeaf
            if ~isempty(EP{i})
                num = num + 1;
            end
        end
    end
    allLeafNum(im) = num;
    file = Filenames{im};
    index = find(file=='\');
    if isempty(index)
        index0 = 1;
    else
        index0 = index(end)+1;
    end
    disp([file(index0:end), ' : ', num2str(num), ' leaves'])
end

disp('start to write .txt files')
mkdir(outputPath);

% write output files
for im = 1 : nImage
    index = find(Filenames{im}=='\');
    if isempty(index)
        index0 = 1;
    else
        index0 = index(end)+1;
    end
    file = Filenames{im}(index0:end-4);
    fid = fopen([outputPath, file, '.txt'], 'w');
    leafNum = allLeafNum(im);
    fprintf(fid, '%d\t', leafNum);
    
    for pt = 1 : nPlant
        EP = edges{pt, im};
        Area = areas{pt, im};
        nLeaf = numel(EP);
        rg = PlantLocations(pt, :);
        ptname = PlantNames{pt};
        
        for i = 1 : nLeaf
            if ~isempty(EP{i})
                leafInfo = EP{i};
                leafInfo = [leafInfo(:,1)+rg(2), leafInfo(:,2)+rg(1)];
                nPoints = size(leafInfo, 1);
                nNum = 5 + nPoints*2;
                temp = leafInfo';
                fprintf(fid, '%d\t', nNum);
                fprintf(fid, '%s\t', ptname);
                fprintf(fid, '%d\t', pt);
                fprintf(fid, '%d\t%d\t%d\t', i, Area(i), 1);
                for j = 1 : size(temp,2)
                    fprintf(fid, '%d\t%d\t', temp(1,i), temp(2,i));
                end
                fprintf(fid, '\n');
%                 fwrite(fid, [nNum, pt, i, Area(i), 1, temp], 'uint16');  
            end 
        end
    end
    
    fclose(fid);
    disp(['write done: ', Filenames{im}(index0:end-4), '.txt'])
end
        

