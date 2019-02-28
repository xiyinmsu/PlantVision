function [OBJ, newS, combinedMask, tempMasks] = tracking_GradientDescent3(testIm, testMask, Template, deltaTXs, deltaTYs, TemplateMask, Theta, leafID, alpha0, maxiter, belta1, belta2, S0)

margin = 10;
[m, n] = size(testIm);
testIm0 = zeros(m+margin*2, n+margin*2);
testIm0(margin+1:margin+m, margin+1:margin+n) = testIm;
[distanceMap, ~] = bwdist(testIm0);
fx = [-1; 1];
fy = [-1, 1];
deltaDX = imfilter(distanceMap, fx, 'replicate');
deltaDY = imfilter(distanceMap, fy, 'replicate');

nLeaf = numel(leafID);
niter = 1;
OBJ = zeros(maxiter, 3);
newS = S0;
nStep = 10;
xyStepsize = 100;
flag = 1;

[x, y] = find(testMask==1);
Cx = mean(x);
Cy = mean(y);
d = sqrt((m/2)^2 + (n/2)^2);

belta3 = belta2/(d^2/2); % weight for J3

obJ1 = tracking_cal_objective(distanceMap, margin, Template, newS, leafID);
combinedMask = tracking_cal_constant(Template, TemplateMask, testMask, newS, leafID);
obJ2 = belta1*sum(sum((combinedMask-double(testMask)).^2))/numel(testMask);
obJ3 = tracking_cal_objective3(Template, newS, Theta, leafID, Cx, Cy);
OBJ(1, :) = [mean(obJ1(leafID~=0)), obJ2, belta3*mean(obJ3(leafID~=0))];

Dtheta = zeros(nLeaf, 1);
Dr = zeros(nLeaf, 1);
Dtx = zeros(nLeaf, 1);
Dty = zeros(nLeaf, 1);

LeafNum = sum(leafID~=0);

while niter <= maxiter && flag
    combinedMask = tracking_cal_constant(Template, TemplateMask, testMask, newS, leafID);

    for i = 1 : nLeaf
        if leafID(i)~=0
            theta0 = newS(i, 1);
            r0 = newS(i, 2);
            tx0 = newS(i, 3);
            ty0 = newS(i, 4);

            [theta1, r1, tx1, ty1] = tracking_cal_grad1(Template{i}, deltaDX, deltaDY, margin, theta0, r0, tx0, ty0);
            [theta2, r2, tx2, ty2] = tracking_cal_grad2(Template{i}, combinedMask, testMask, deltaTXs{i}, deltaTYs{i}, theta0, r0, tx0, ty0); 
            [theta3, r3, tx3, ty3] = tracking_cal_grad3(Template{i}, Theta(i), Cx, Cy, theta0, r0, tx0, ty0); 

            Dtheta(i) = theta1/LeafNum + theta2*belta1 + theta3*belta3;
            Dr(i) = r1/LeafNum + r2*belta1 + r3*belta3;
            Dtx(i) = tx1/LeafNum + tx2*belta1 + tx3*belta3;
            Dty(i) = ty1/LeafNum + ty2*belta1 + ty3*belta3;
            
        end
    end
    
    S = newS - alpha0*[Dtheta, Dr, xyStepsize*Dtx, xyStepsize*Dty]; 

    obJ1 = tracking_cal_objective(distanceMap, margin, Template, S, leafID);
    combinedMask = tracking_cal_constant(Template, TemplateMask, testMask, S, leafID);
    obJ2 = belta1*sum(sum((combinedMask-double(testMask)).^2))/numel(testMask);
    obJ3 = tracking_cal_objective3(Template, newS, Theta, leafID, Cx, Cy);

    step = 0;
    alpha = alpha0;

    while mean(obJ1(leafID~=0)) + obJ2 + belta3*mean(obJ3(leafID~=0))>= sum(OBJ(niter, :))
        if step > nStep
            flag = 0;
            break
        else
            step = step + 1;
            alpha = alpha/2;
            S = newS - alpha*[Dtheta, Dr, xyStepsize*Dtx, xyStepsize*Dty]; 
            obJ1 = tracking_cal_objective(distanceMap, margin, Template, S, leafID);
            combinedMask = tracking_cal_constant(Template, TemplateMask, testMask, S, leafID);
            obJ2 = belta1*sum(sum((combinedMask-double(testMask)).^2))/numel(testMask);
            obJ3 = tracking_cal_objective3(Template, newS, Theta, leafID, Cx, Cy);
        end
    end
    
    if flag == 0
        OBJ = OBJ(1:niter, :);
    else
        OBJ(niter+1, :) = [mean(obJ1(leafID~=0)), obJ2, belta3*mean(obJ3(leafID~=0))];
        newS = S;
    end
    
    niter = niter + 1;
end

[combinedMask, tempMasks] = tracking_cal_constant(Template, TemplateMask, testMask, newS, leafID);







