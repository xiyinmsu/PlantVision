function MultiLeafTracking(inputData, smallSize, largeSize)
% INPUTDATA is the string path of .txt file saved the plant information
% SMALLSIZE and LARGESIZE is the scale of template size
% default value is 1 and 12.

if nargin == 1
    smallSize = 1;
    largeSize = 12;
end

load('Data/templates.mat')
template = template(:, smallSize:largeSize, :);
templateTip = templateTip(:, smallSize:largeSize, :);
templateMask = templateMask(:, smallSize:largeSize, :);

% parameters for alignment
foregroundRatio = 0.85;
threshold = 0.002; % for image segmentation

% parameters for tracking
maxiter = 80;
alpha2 = 0.01; 
belta1 = 1;
belta2 = 10;
smallLeaf = 5 + 3*smallSize; % smallest leaf to keep

[nPlant, plantIDs, PlantLocations, Filenames] = data_readInputTextFile(inputData);
nImage = numel(Filenames);
tips = cell(nPlant, nImage);
edges = cell(nPlant, nImage);
areas = cell(nPlant, nImage);
for pt = 1 : nPlant
    rg = PlantLocations(pt, :);

    for im = 1 : nImage
        inputIm = imread(Filenames{im});
        plant = inputIm(rg(1): rg(1)+rg(3)-1, rg(2):rg(2)+rg(4)-1);
        f = fspecial('gaussian');
        plantIm = imfilter(plant, f);
        [plantIm, testIm, testMask, ~] = data_imageSegmentation(plantIm, threshold);  
        if im == 1 
            disp(['Plant:' num2str(plantIDs(pt,:)), ': leaf alignment on the last frame'])
            [Template, TemplateMask, TemplateTip, Theta, leafID, deltaTXs, deltaTYs, S0] = tracking_leafAlignmentForLastFrame(testIm, testMask, template, templateMask, templateTip, foregroundRatio);
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
      
        [EP, LP, TP, leafID, Area, S0] = tracking_generateLeafInformation(testIm, Template, TemplateTip, AllMasks, leafID, newS, smallLeaf);
        displayResult(LP, EP, TP, testIm, leafID)
        tips{pt, im} = TP;
        edges{pt, im} = EP;
        areas{pt, im} = Area;     
        
        file = Filenames{im};
        disp(['tracking plant: ' num2str(plantIDs(pt,:)), ' : ', file])
    end
   disp(['tracking done for Plant: ', num2str(plantIDs(pt,:))])
end
save('results.mat', 'tips', 'edges', 'areas')

pause(0.5)
disp('tracking done for all Plants')
pause(0.5)
disp('count leaves in each image')

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
    disp([file, ' : ', num2str(num), ' leaves'])
end


