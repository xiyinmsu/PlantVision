function [LP, EP, TP, MEP, MTP] = alignment_chamferMatchingForAllTemplates(testIm, template, templateTip)

[row_testIm, col_testIm] = size(testIm);
[nShape, nScale, nDirection] = size(template);
nTip = size(templateTip{1,1,1}, 1);

LP = zeros(nShape*nScale*nDirection, 8);
EP = cell(nShape*nScale*nDirection, 1);
TP = zeros(nShape*nScale*nDirection, nTip*2);
MEP = EP;
MTP = TP;

[distanceMap, edgePixelPositionMap] = bwdist(testIm);
p = 0;
figure(1)
imshow(~testIm)
hold on
for sh = 1 : nShape 
    for s = 1 : nScale
        for d = 1 : nDirection
            temp = template{sh, s, d};
            [row_template, col_template] = size(temp);
            rr = ceil(row_template/2);
            cc = ceil(col_template/2);

            if (row_template<row_testIm/2 && col_template<col_testIm/2)
                p = p + 1; 
                [xx, yy] = find(temp==1);
                scoreMap = imfilter(double(distanceMap), double(temp))/sum(temp(:));
                scoreMap1 = scoreMap(rr:row_testIm-rr, cc:col_testIm-cc);
                [minScore, index] = min(scoreMap1(:));
                [start_x, start_y] = ind2sub(size(scoreMap1), index);
                LP(p, :) = [sh, s, d, start_x, start_y, row_template, col_template, minScore];
                
                xx = xx + start_x - 1;
                yy = yy + start_y - 1;
                EP{p} = [xx, yy];
                [xx1, yy1] = ind2sub(size(testIm), edgePixelPositionMap(sub2ind(size(testIm), xx, yy)));
                MEP{p} = [xx1, yy1];
               
                tip = templateTip{sh, s, d} + repmat([start_x-1, start_y-1], 2, 1);
                tip0 = tip';
                TP(p, :) = tip0(:)';
                [tip_x, tip_y] = ind2sub(size(testIm), edgePixelPositionMap(sub2ind(size(testIm), tip(:,1), tip(:,2))));
                tip1 = [tip_x, tip_y]';
                tip2 = tip1(:);
                MTP(p, :) = tip2';
                
                plot(yy, xx, 'r*')
            end
        end
    end    
end

LP = LP(1:p, :);
EP = EP(1:p);
TP = TP(1:p, :);
MEP = MEP(1:p);
MTP = MTP(1:p, :);

                

