function [Template, TemplateMask, TemplateTip, Theta] = tracking_generateTemplateInformation(testIm, template, templateMask, templateTip, LP)

[m, n] = size(testIm);
nTip = size(templateTip{1,1,1},1);

nLeaf = size(LP, 1);
Template = cell(nLeaf, 1);
TemplateMask = cell(nLeaf, 1);
TemplateTip = zeros(nLeaf, nTip*2);
Theta = zeros(nLeaf, 1);

for i = 1 : nLeaf
    temp = template{LP(i,1), LP(i,2), LP(i,3)};
    tempMask = templateMask{LP(i,1), LP(i,2), LP(i,3)};
    tip = templateTip{LP(i,1), LP(i,2), LP(i,3)};
    
    [x0, y0] = find(temp==1);
    x0 = x0 + LP(i, 4) - 1;
    y0 = y0 + LP(i, 5) - 1;
    
    [x1, y1] = find(tempMask==1);
    x1 = x1 + LP(i, 4) - 1;
    y1 = y1 + LP(i, 5) - 1;
    in1 = find(x1<1);
    in2 = find(y1<1);
    in3 = find(x1>m);
    in4 = find(y1>n);
    in = unique([in1(:); in2(:); in3(:); in4(:)]);
    x1(in) = [];
    y1(in) = [];
    
    mask = zeros([m,n]);
    mask(sub2ind(size(mask), x1, y1)) = 1;
    
    newTip = tip + repmat([LP(i, 4)-1, LP(i, 5)-1], nTip, 1);
    tip0 = newTip';    
    
    Template{i} = [x0, y0];
    TemplateMask{i} = mask;
    TemplateTip(i, :) = tip0(:)';
    Theta(i) = (LP(i,3)-1)*15/180*pi;
end


