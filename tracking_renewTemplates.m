function [leafID, newS, deltaTXs, deltaTYs, Theta, Template, TemplateMask, TemplateTip, AllMasks] = tracking_renewTemplates(newCandidate, newMask, testIm, testMask, template, templateMask, templateTip, leafID, newS, deltaTXs, deltaTYs, Theta, Template, TemplateMask, TemplateTip, AllMasks, smallLeaf)

fx = [-1; 1];
fy = [-1, 1];

newL = size(newCandidate, 1);
nLeaf = length(leafID);
for i = 1 : newL
    cand =newCandidate(i, :);
    mask = newMask{i};
    
    scores = zeros(nLeaf, 1);
    overlap = zeros(nLeaf, 1);
    for le = 1 : nLeaf
        mask1 = AllMasks{le};
        overlap(le) = sum(sum(mask.*mask1))/sum(mask(:));
        scores(le) = cand(8) - overlap(le);
    end
    
%     [maxOverlap, index] = max(overlap);
    [~, index] = min(scores);

    if overlap(index)>0.5 && leafID(index)~=0
        continue
    else
        [newTemplate, newTemplateMask, newTemplateTip, newTheta] = tracking_generateTemplateInformation(testIm, template, templateMask, templateTip, cand);
        
        if overlap(index)<0.1  % overlap with previous leaf: determine whether need to assign a new leafID or not
            Index = length(leafID)+1;
            disp('generate a new leaf')
        else
            Index = index;
        end
        
        leafID(Index) = Index;
        newS(Index, :) = [0, 1, 0, 0];

        Template{Index} = newTemplate{1};
        TemplateMask{Index} = newTemplateMask{1};
        TemplateTip(Index, :) = newTemplateTip;
        Theta(Index) = newTheta;
        deltaTXs{Index} = imfilter(double(newTemplateMask{1}), fx);
        deltaTYs{Index} = imfilter(double(newTemplateMask{1}), fy);
        AllMasks{Index} = newTemplateMask{1};
    end
end


% check the overlap and size of all leaves
nLeaf = length(leafID);
combinedMask = zeros(size(testIm));
for i = 1 : nLeaf
    if leafID(i)~=0
        combinedMask = combinedMask + AllMasks{i};
    end
end

for i = 1 : nLeaf
    if leafID(i)~=0
        mask0 = AllMasks{i};
        residue = combinedMask - mask0;
        overlap = sum(sum(mask0.*residue))/sum(mask0(:));
        if overlap > 0.5 || sum(mask0(:)) < smallLeaf^2
            leafID(i) = 0;
            newS(i, :) = 0;
        end
    end
end


        














