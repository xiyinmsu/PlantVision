function [theta1, r1, tx1, ty1] = tracking_cal_grad1(temp, deltaDX, deltaDY, margin, theta0, r0, tx0, ty0)

tx0 = tx0 + mean(temp(:,1));
ty0 = ty0 + mean(temp(:,2));
x0 = temp(:, 1) - mean(temp(:,1));
y0 = temp(:, 2) - mean(temp(:,2));

newXY = [cos(theta0), -sin(theta0); sin(theta0), cos(theta0)]*[x0';y0']*r0 + repmat([tx0;ty0], 1, numel(x0));
x1 = newXY(1, :)';
y1 = newXY(2, :)';

X1 = interp2(deltaDX, y1+margin, x1+margin);
Y1 = interp2(deltaDY, y1+margin, x1+margin);
X1(isnan(X1))=0;
Y1(isnan(Y1))=0;


XDtheta = x0*r0*(-sin(theta0)) - y0*r0*cos(theta0);
XDr = cos(theta0)*x0 - sin(theta0)*y0;

YDtheta = x0*r0*(cos(theta0)) - y0*r0*sin(theta0);
YDr = sin(theta0)*x0 + cos(theta0)*y0;

theta1 = mean(X1.*XDtheta + Y1.*YDtheta);
r1 = mean(X1.*XDr + Y1.*YDr);
tx1 = mean(X1);
ty1 = mean(Y1);


