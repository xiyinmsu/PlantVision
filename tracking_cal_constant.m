function [combinedMask, tempMasks] = tracking_cal_constant(Template, TemplateMask, testMask, S0, leafID)

nLeaf = numel(TemplateMask);
tempMasks = cell(nLeaf, 1);
combinedMask = zeros(1,length(testMask(:)));

for i = 1 : nLeaf
    if leafID(i) ~= 0
        temp = Template{i};
        tempMask = TemplateMask{i};
        [y0, x0] = meshgrid(1:size(testMask,2), 1:size(testMask,1));
        y0 = y0(:);
        x0 = x0(:);

        theta0 = S0(i, 1);
        r0 = S0(i, 2);
        tx0 = S0(i, 3) + mean(temp(:,1));
        ty0 = S0(i, 4) + mean(temp(:,2));

        newXY = [cos(theta0), sin(theta0); -sin(theta0), cos(theta0)]*[((x0-tx0)/r0)';((y0-ty0)/r0)'] + repmat([mean(temp(:,1));mean(temp(:,2))], 1, numel(x0));

        T = interp2(double(tempMask), newXY(2, :), newXY(1, :));
        T(isnan(T))=0; 

        combinedMask = combinedMask + T;
        tempMasks{i} = reshape(T, size(testMask,1), size(testMask,2));
    end
end

combinedMask = reshape(combinedMask, size(testMask,1),size(testMask,2));

