function J1 = tracking_cal_objective(distanceMap, margin, Template, newS, leafID)

nLeaf = numel(Template);
J1 = zeros(nLeaf, 1);

for i = 1 : nLeaf
    if leafID(i) ~= 0
        theta0 = newS(i, 1);
        r0 = newS(i, 2);
        tx0 = newS(i, 3);
        ty0 = newS(i, 4);

        temp = Template{i};

        % modification
        tx0 = tx0 + mean(temp(:,1));
        ty0 = ty0 + mean(temp(:,2));
        x0 = temp(:,1) - mean(temp(:,1));
        y0 = temp(:,2) - mean(temp(:,2));

        newXY = [cos(theta0), -sin(theta0); sin(theta0), cos(theta0)]*[x0';y0']*r0 + repmat([tx0;ty0], 1, numel(x0));
        x1 = newXY(1, :)';
        y1 = newXY(2, :)';

        D = interp2(distanceMap, y1+margin, x1+margin);
        D(isnan(D)) = 20;

        J1(i) = mean(D);
    end
end


