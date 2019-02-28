function [newCandidate, newMask] = tracking_generateNewCandidates(plant, testMask, combinedMask, smallLeaf, template, templateMask)

mask = testMask - combinedMask.*testMask;
mask(mask > 0.5) = 1;
mask(mask < 0.5) = 0;
mask1 = imopen(mask, ones(smallLeaf));

if sum(mask1(:)) == 0
    newCandidate = [];
    newMask = [];
else
    [x, y] = find(testMask==1);
    Cx = mean(x);
    Cy = mean(y);
    plant1=plant.*double(mask1);
    testIm = edge(plant1, 'canny');
    
    [m, n] = size(testIm);
    [nShape, nScale, nDirection] = size(template);
    chamferMatchingDistanceValue = zeros(nShape*nScale*nDirection, 8);
    Theta = nan(nShape*nScale*nDirection, 1);
    [distanceMap, ~] = bwdist(testIm);
    p = 0;

    for sh = 1 : nShape 
        for s = 1 : nScale
            for d = 1 : nDirection
                temp = template{sh, s, d};
                tempMask = templateMask{sh, s, d};
                [tm, tn] = size(temp);
                
                if sum(tempMask(:)) > sum(mask1(:))*1.2 || sum(tempMask(:))<sum(mask1(:))*0.8
                    continue
                else if (tm<m/2 && tn<n/2)
                        scoreMap = imfilter(double(distanceMap), double(temp))/sum(temp(:));
                        p = p + 1; 

                        rr = ceil(tm/2);
                        cc = ceil(tn/2);
                        r1 = round(m/4);
                        r2 = round(m/2);
                        r3 = round(m*3/4);
                        c1 = round(n/4);
                        c2 = round(n/2);
                        c3 = round(n*3/4);

                        switch d
                            case {1}
                                minTemplateScore = min(min(scoreMap(rr:r2, c1:c3)));
                                [indexX, indexY] = find(scoreMap(rr:r2, c1:c3)==minTemplateScore);
                                start_x = indexX(1);
                                start_y = indexY(1)+c1-cc-1;
                            case {2,3,4,5,6}
                                minTemplateScore = min(min(scoreMap(rr:r2, cc:c2)));
                                [indexX, indexY] = find(scoreMap(rr:r2, cc:c2)==minTemplateScore);
                                start_x = indexX(1);
                                start_y = indexY(1);
                            case {7}
                                minTemplateScore = min(min(scoreMap(r1:r3, cc:c2)));
                                [indexX, indexY] = find(scoreMap(r1:r3, cc:c2)==minTemplateScore);
                                start_x = indexX(1)+r1-rr-1;
                                start_y = indexY(1);
                            case {8,9,10,11,12}
                                minTemplateScore = min(min(scoreMap(r2:m-rr, cc:c2)));
                                [indexX, indexY] = find(scoreMap(r2:m-rr, cc:c2)==minTemplateScore);
                                start_x = indexX(1)+r2-rr-1;
                                start_y = indexY(1);
                            case {13}
                                minTemplateScore = min(min(scoreMap(r2:m-rr, c1:c3)));
                                [indexX, indexY] = find(scoreMap(r2:m-rr, c1:c3)==minTemplateScore);
                                start_x = indexX(1)+r2-rr-1;
                                start_y = indexY(1)+c1-cc-1;
                            case {14,15,16,17,18}
                                minTemplateScore = min(min(scoreMap(r2:m-rr, c2:n-cc)));
                                [indexX, indexY] = find(scoreMap(r2:m-rr, c2:n-cc)==minTemplateScore);
                                start_x = indexX(1)+r2-rr-1;
                                start_y = indexY(1)+c2-cc-1;
                            case {19}
                                minTemplateScore = min(min(scoreMap(r1:r3, c2:n-cc)));
                                [indexX, indexY] = find(scoreMap(r1:r3, c2:n-cc)==minTemplateScore);
                                start_x = indexX(1)+r1-rr-1;
                                start_y = indexY(1)+c2-cc-1;
                            case {20,21,22,23,24}
                                minTemplateScore = min(min(scoreMap(rr:r2, c2:n-cc)));
                                [indexX, indexY] = find(scoreMap(rr:r2, c2:n-cc)==minTemplateScore);
                                start_x = indexX(1);
                                start_y = indexY(1)+c2-cc-1;
                        end
                        
                         [start_x, start_y] = data_adjustWithinImage(scoreMap, start_x, start_y);
                        chamferMatchingDistanceValue(p, :) = [sh, s, d, start_x, start_y, tm, tn, minTemplateScore];

                        % angel difference
                        [x1, y1] = find(tempMask==1);
                        deltaX = mean(x1) + start_x - 1 - Cx;
                        deltaY = mean(y1) + start_y - 1 - Cy;

                        XY = sqrt(deltaX^2 + deltaY^2);
                        theta0 = asin(abs(deltaY)/XY);

                        switch [num2str(deltaX<=0), num2str(deltaY<=0)]
                            case '11'
                                theta1 = theta0;
                            case '01'
                                theta1 = pi - theta0;
                            case '00'
                                theta1 = pi + theta0;
                            case '10'
                                theta1 = 2*pi - theta0;
                        end    
                        Theta(p) = abs(theta1 - (d-1)*15/180*pi);
                    end
                end
            end
        end
    end
    
    if p==0
        newCandidate = [];
        newMask = [];
    else
        candidate = chamferMatchingDistanceValue(1:p, :);
        newCandidate = zeros(size(candidate));
        newMask = cell(size(candidate, 1), 1);
        scores = candidate(1:p, 8) + Theta(1:p);

        residue = mask1;
        newL = 0;
        while sum(residue(:))~=0
            [minScore, index] = min(scores);
            
            if minScore==inf
                break
            end

            if minScore > 5 || Theta(index)>45/180*pi
                break
            else
                tempMask = templateMask{candidate(index,1), candidate(index,2), candidate(index,3)};
                [x, y] = find(tempMask==1);
                residue1 = residue;
                residue(sub2ind(size(residue), x+candidate(index,4)-1, y+candidate(index,5)-1)) = 0;
                residue2 = imerode(residue, ones(smallLeaf));
                residue = imdilate(residue2, ones(smallLeaf));
                
                delta = residue - residue1;
                if sum(delta(:))~=0
                    newL = newL + 1;
                    newCandidate(newL, :) = candidate(index, :);
                    mask = zeros(size(testMask));
                    mask(sub2ind(size(residue1), x+candidate(index,4)-1, y+candidate(index,5)-1)) = 1;
                    newMask{newL} = mask;
                end
                scores(index) = inf;
            end
        end

        newCandidate = newCandidate(1:newL, :);
        newMask = newMask(1:newL);
    end
end

if ~exist('newCandidate', 'var')
    newCandidate = [];
end

if ~exist('newMask', 'var')
    newMask = [];
end


    
