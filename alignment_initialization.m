function  [Mg, Mb, S, D, candidate, edges, tips] = alignment_initialization(chamferMatchingDistanceValue, matchingPixels, matchingTips, testMask, template, templateMask, foregroundRatio)

num = size(chamferMatchingDistanceValue, 1);

testMask = double(testMask);
Mb = zeros(num, numel(testMask));
S = zeros(num, 1);
L = zeros(num, 1);
D = zeros(num, 1);
candidate = zeros(size(chamferMatchingDistanceValue));
edges = cell(num, 1);
tips = zeros(num, size(matchingTips, 2));

[xx, yy] = find(testMask==1);
Cx = mean(xx);
Cy = mean(yy);
constant = sqrt(size(testMask, 1)^2 + size(testMask, 2)^2)/2;

n = 0;
for i = 1 : num
    leaf = chamferMatchingDistanceValue(i, :);
    sh = leaf(1);
    s = leaf(2);
    d = leaf(3);
    sx = leaf(4);
    sy = leaf(5);
    h = leaf(6);
    w = leaf(7);

    temp = template{sh, s, d};
    [x, y] = find(temp==1);

% weighted according to the distance to the center
    deltaX = mean(x) + sx - 1 - Cx;
    deltaY = mean(y) + sy - 1 - Cy;
    D0 = (sin((d-1)*15/180*pi) * sqrt(deltaX^2+deltaY^2) + deltaY).^2/constant;
    
% angel difference    
    XY = sqrt(deltaX^2 + deltaY^2);
    theta0 = asin(abs(deltaY)/XY);
    
%     switch [num2str(deltaX<=0), num2str(deltaY<=0)]
%         case '11'
%             theta1 = theta0;
%         case '01'
%             theta1 = pi - theta0;
%         case '00'
%             theta1 = pi + theta0;
%         case '10'
%             theta1 = 2*pi - theta0;
%     end    
%     theta = abs(theta1 - (d-1)*15/180*pi);
    
    tempMask = templateMask{sh, s, d};
    mask = zeros(size(testMask));
    mask(sx:sx+h-1, sy:sy+w-1) = tempMask;
    foregroundMask = sum(sum(mask.*testMask));
    if foregroundMask/sum(tempMask(:)) < foregroundRatio
        continue
%     else if theta > 45/180*pi  % delete those leaves when the angel difference is larger than 45 degrees
%             continue
        else
            n = n + 1;
            candidate(n, :) = chamferMatchingDistanceValue(i, :);
            tips(n, :) = matchingTips(i, :);        
            edges{n} = matchingPixels{i};        
            S(n) = chamferMatchingDistanceValue(i, 8);
            Mb(n, :) = mask(:);    
            D(n) = D0;
            
            leafLength = sqrt((matchingTips(i, 1) - matchingTips(i, 3)).^2 + (matchingTips(i, 2) - matchingTips(i, 4)).^2);
            L(n) = leafLength;
            
%         end
    end
end

Mg = testMask(:);
Mb = Mb(1:n, :);
S = S(1:n);
L = L(1:n);
L = L/max(L);
D = D(1:n);
candidate = candidate(1:n, :);
edges = edges(1:n, :);
tips = tips(1:n, :);



