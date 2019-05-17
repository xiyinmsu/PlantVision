function [Template, TemplateMask, TemplateTip, Theta, leafID, deltaTXs, deltaTYs, S0] = tracking_leafAlignmentForLastFrame(testIm, testMask, template, templateMask, templateTip, foregroundRatio)

[chamferMatchingDistanceValue, matchingPixels, matchingTips] = alignment_chamferMatchingForAllTemplates(testIm, template, templateTip);                
[M, A, S, D, candidate, edges, tips] = alignment_initialization(chamferMatchingDistanceValue, matchingPixels, matchingTips, testMask, template, templateMask, foregroundRatio);               

[LP, ~, ~, ~, ~]  = alignment_gradientDescent(candidate, edges, tips, M, A, S, D, testMask, templateMask); 

[Template, TemplateMask, TemplateTip, Theta] = tracking_generateTemplateInformation(testIm, template, templateMask, templateTip, LP);

leafID = 1 : size(LP, 1);
fx = [-1; 1];
fy = [-1, 1];

nLeaf = length(leafID);
S0 = zeros(nLeaf, 4);
S0(:, 2) = 1;   % initialize S parameters, scale r=1

deltaTXs = cell(nLeaf, 1);
deltaTYs = cell(nLeaf, 1);
for i = 1 : nLeaf
    tempMask = TemplateMask{i};
    deltaTXs{i} = imfilter(double(tempMask), fx);
    deltaTYs{i} = imfilter(double(tempMask), fy);
end







