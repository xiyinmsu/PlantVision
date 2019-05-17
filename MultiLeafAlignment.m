function [LP, EP, TP, testIm1, margin] = MultiLeafAlignment(testIm, testMask, template, templateMask, templateTip, Parameters)
% INPUT:
% - testIm: a binary matrix of the edge map 
% - testMask: a foreground mask 
% - template, templateMask, templateTip: are cells containing all template
% information, their sizes should be the same. 
% - Parameters: all parameter setting for this algorithm, default is the
% setting for fluorescence images. 
% 
% OUTPUT:
% - LP: leaf location information, N*8 matrix, each row represent the 
% information of one leaf template, [1,2,3] indicate the indexs for each
% template, [4,5] indicate the location of the leaf on the image, [6,7] 
% indicate the size of the template[8] is the chamfer matching distance. 
% - EP: N*1 cell containing edges of each transformed leaf template. 
% - TP; N*4 matrix where each row represent the two tips of each leaf.  
    

if nargin == 5
    foregroundRatio = 0.85;
    marg = 3; % margin to crop test image
else
    foregroundRatio = Parameters.foregroundRatio;
    marg = Parameters.marg;
end
    
[testIm1, marg_new] = cropBinaryImage(testIm, marg);
testMask1 = testMask(margin_new(1)+1:end-marg_new(3), marg_new(2)+1:end-marg_new(4));

[chamferMatchingDistanceValue, matchingPixels, matchingTips] = alignment_chamferMatching(testIm1, testMask1, template, templateMask, templateTip);

[M, A, S, D, candidate, edges, tips] = alignment_initialization(chamferMatchingDistanceValue, matchingPixels, matchingTips, testMask1, template, templateMask, foregroundRatio);

[LP, EP, TP]  = alignment_gradientDescent(candidate, edges, tips, M, A, S, D, testMask1, templateMask); 


