function [LP, EP, TP] = alignment_chamferMatching(testIm, testMask, template, templateMask, templateTip)

[row_testIm, col_testIm] = size(testIm);
[nShape, nScale, nDirect] = size(template);
nTip = size(templateTip{1,1,1}, 1);

LP = zeros(nShape*nScale*nDirect, 8);
EP = cell(nShape*nScale*nDirect, 1);
TP = zeros(nShape*nScale*nDirect, nTip*2);

[distanceMap, ~] = bwdist(testIm);
p = 0;
for sh = 1 : nShape 
    for s = 1 : nScale
        for d = 1 : nDirect
            temp = template{sh, s, d};
            tempMask = templateMask{sh, s, d};
            [row_template, col_template] = size(temp);
            rr = ceil(row_template/2);
            cc = ceil(col_template/2);

            if (row_template<row_testIm*0.4 && col_template<col_testIm*0.4)
                p = p + 1; 
                [xx, yy] = find(temp==1);
                scoreMap = imfilter(double(distanceMap), double(temp))/sum(temp(:));
                scoreMapmask = imfilter(double(testMask), double(tempMask))/sum(tempMask(:));
                scoreMap1 = scoreMap - scoreMapmask;
                
                scoreMap1 = scoreMap1(rr:row_testIm-rr, cc:col_testIm-cc);
                [minScore, index] = min(scoreMap1(:));
                [start_x, start_y] = ind2sub(size(scoreMap1), index);
                LP(p, :) = [sh, s, d, start_x, start_y, row_template, col_template, minScore];
                
                xx = xx + start_x - 1;
                yy = yy + start_y - 1;
                EP{p} = [xx, yy];
               
                tip = templateTip{sh, s, d} + repmat([start_x-1, start_y-1], 2, 1);
                tip0 = tip';
                TP(p, :) = tip0(:)';
            end
        end
    end    
end
LP = LP(1:p, :);
EP = EP(1:p);
TP = TP(1:p, :);

