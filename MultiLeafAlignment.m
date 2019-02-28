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
    Parameters.foregroundRatio = 0.85;
    Parameters.alpha = 0.001; % step size for gradient descent 
    Parameters.lamda1 = 50;
    Parameters.lamda2 = 0.1;
    Parameters.lamda3 = 1;
    Parameters.C = 3;
    Parameters.margin = 3; % margin to crop test image
end
    

[testIm1, margin] = cropBinaryImage(testIm, Parameters.margin);
testMask1 = testMask(margin(1)+1:end-margin(3), margin(2)+1:end-margin(4));

[chamferMatchingDistanceValue, matchingPixels, matchingTips] = alignment_chamferMatching(testIm1, testMask1, template, templateMask, templateTip);

[M, A, S, D, candidate, edges, tips] = alignment_initialization(chamferMatchingDistanceValue, matchingPixels, matchingTips, testMask1, template, templateMask, Parameters.foregroundRatio);               

[LP, EP, TP]  = alignment_gradientDescent(candidate, edges, tips, M, A, S, D, Parameters, testMask1, templateMask);        


