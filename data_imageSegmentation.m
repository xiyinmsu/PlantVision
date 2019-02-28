function [plantIm, testIm, testMask, margin] = data_imageSegmentation(inputIm, threshold, para)          

inputIm(isnan(inputIm)) = 0;
f = fspecial('gaussian');
plantIm = imfilter(double(inputIm), f);  
plantIm = medfilt2(plantIm, [3,3]);     
 
bw0 = im2bw(inputIm, threshold);
bw = bwmorph(bw0, 'clean');

[x, y] = find(bw==1);
foreground = inputIm(sub2ind(size(inputIm), x, y));

if  mean(foreground)*0.000015 - 0.003 < threshold
    t = threshold;
else
    t = mean(foreground)*0.000015 - 0.003;
end

bw = im2bw(inputIm, t);
bw = bwmorph(bw, 'clean');

e1 = edge(bw, 'sobel');

testIm = e1;
testMask = double(bw);

if nargin==3 && strcmp(para, 'Crop')
    [~, margin] = data_cropBinaryImage(testMask, 3);
    plantIm = plantIm(margin(1)+1:end-margin(3), margin(2)+1:end-margin(4));
    testIm = testIm(margin(1)+1:end-margin(3), margin(2)+1:end-margin(4));
    testMask = testMask(margin(1)+1:end-margin(3), margin(2)+1:end-margin(4));
else
    margin = [0,0,0,0];
end
