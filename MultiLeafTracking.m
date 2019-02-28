function MultiLeafTracking(inputPath, outputPath, smallSize, largeSize)
% function format: MultiLeafTracking(inputPath, outputPath, smallSize, largeSize)
% INPUTPATH is the string path of .txt file saved the plant information
% OUTPUTPATH is the path to save output txt files
% SMALLSIZE and LARGESIZE is the scale of template size
% default value is 1 and 12.

if nargin == 2
    smallSize = 1;
    largeSize = 12;
end

load('template.mat')
load('templateTip.mat')
template = template(:, smallSize:largeSize, :);
templateTip = templateTip(:, smallSize:largeSize, :);

% parameters for alignment
foregroundRatio = 0.85;
threshold = 0.002; % for image segmentation
alpha1 = 0.001; % step size for gradient descent 
lamda1 = 25;
lamda2 = 0.2;
lamda3 = 2;
C = 3;

% parameters for tracking
maxiter = 80;
alpha2 = 0.01; 
belta1 = 1;
belta2 = 10;
smallLeaf = 5 + 3*smallSize; % smallest leaf to keep


[nPlant, plantIDs, PlantLocations, Filenames] = data_readInputTextFile(inputPath);
nImage = numel(Filenames);
edges = cell(nPlant, nImage);
areas = cell(nPlant, nImage);

for pt = 1 : nPlant
    rg = PlantLocations(pt, :);

    for im = 1 : nImage
        inputIm = imread(Filenames{im});
        plant = inputIm(rg(1): rg(1)+rg(3)-1, rg(2):rg(2)+rg(4)-1);
        f = fspecial('gaussian');
        plantIm = imfilter(plant, f);       
        [testIm, testMask] = data_imageSegmentation(plantIm, threshold);  
  
        if im == 1 
            disp(['Plant:' num2str(plantIDs(pt,:)), ': leaf alignment on the last frame'])
            [Template, TemplateMask, TemplateTip, Theta, leafID, deltaTXs, deltaTYs, S0] = tracking_leafAlignmentForLastFrame(testIm, testMask, template, templateMask, templateTip, foregroundRatio, alpha1, lamda1, lamda2, lamda3, C);
            disp(['Plant:' num2str(plantIDs(pt,:)), ': generate ', num2str(numel(Template)), ' leaves for tracking'])
        end
       
        [~, newS, combinedMask, tempMasks] = tracking_GradientDescent3(testIm, testMask, Template, deltaTXs, deltaTYs, TemplateMask, Theta, leafID, alpha2, maxiter, belta1, belta2, S0);

        if im == 1
            AllMasks = tempMasks;
        else
            nLeaf = length(leafID);
            for i = 1 : nLeaf
                if leafID(i)~=0
                    AllMasks{i} = tempMasks{i};
                end
            end
        end

        [newCandidate, newMask] = tracking_generateNewCandidates(plantIm, testMask, combinedMask, smallLeaf, template, templateMask); 
       
        if ~isempty(newCandidate)
            [leafID, newS, deltaTXs, deltaTYs, Theta, Template, TemplateMask, TemplateTip, AllMasks] = tracking_renewTemplates(newCandidate, newMask, testIm, testMask, template, templateMask, templateTip, leafID, newS, deltaTXs, deltaTYs, Theta, Template, TemplateMask, TemplateTip, AllMasks, smallLeaf);  
        end
      
        [EP, ~, ~, leafID, Area, S0] = tracking_generateLeafInformation(testIm, Template, TemplateTip, AllMasks, leafID, newS, smallLeaf);
        edges{pt, im} = EP;
        areas{pt, im} = Area;     
        
        file = Filenames{im};
        index = find(file=='\');
        disp(['tracking _ ', 'Plant: ' num2str(plantIDs(pt,:)), ' : ', file(index(end)+1:end)])
    end
   disp(['tracking done for Plant: ', num2str(plantIDs(pt,:))])
end

pause(0.5)
disp('tracking done for all Plants')
pause(0.5)
disp('calculate how many leaves are there in one image')

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
    disp([file(index(end)+1:end), ' : ', num2str(num), ' leaves'])
end

disp('start to write .txt files')

% write output files
for im = 1 : nImage
    index = find(Filenames{im}=='\');
    file = Filenames{im}(index(end)+1:end-4);
    mkdir(outputPath);
    fid = fopen([outputPath, file, '.bin'], 'wb');
    leafNum = allLeafNum(im);
    fwrite(fid, leafNum, 'uint16');
    
    for pt = 1 : nPlant
        ptID = plantIDs(pt, :);
        EP = edges{pt, im};
        Area = areas{pt, im};
        nLeaf = numel(EP);
        
        for i = 1 : nLeaf
            if ~isempty(EP{i})
                leafInfo = EP{i};
                nPoints = size(leafInfo, 1);
                nNum = 5 + nPoints*2;
                temp = leafInfo';
                temp = temp(:)';
                fwrite(fid, [nNum, ptID, i, Area(i), 1, temp], 'uint16');  
            end 
        end
    end
    
    fclose(fid);
    disp(['write done: ', Filenames{im}(index(end)+1:end-4), '.txt'])
end
        




