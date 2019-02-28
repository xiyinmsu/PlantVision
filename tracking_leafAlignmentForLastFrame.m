function [Template, TemplateMask, TemplateTip, Theta, leafID, deltaTXs, deltaTYs, S0] = tracking_leafAlignmentForLastFrame(testIm, testMask, template, templateMask, templateTip, foregroundRatio, alpha, lamda1, lamda2, lamda3, C)

[chamferMatchingDistanceValue, matchingPixels, matchingTips] = alignment_chamferMatchingForAllTemplates(testIm, template, templateTip);                
[M, A, S, D, candidate, edges, tips] = alignment_initialization(chamferMatchingDistanceValue, matchingPixels, matchingTips, testMask, template, templateMask, foregroundRatio);               

maxiter = size(candidate, 1);
B0 = ones(maxiter, 1);

[LP, ~, ~, ~, ~]  = alignment_gradientDescent(candidate, edges, tips, M, A, S, D, B0, maxiter, alpha, lamda1, lamda2, lamda3, C, testMask, templateMask);            

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







