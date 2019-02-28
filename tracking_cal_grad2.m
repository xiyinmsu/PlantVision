% function [theta2, rx2, ry2, tx2, ty2] = tracking_cal_grad2(temp, combinedMask, testMask, deltaTX, deltaTY, theta0, rx0, ry0, tx0, ty0)
function [theta2, r2, tx2, ty2] = tracking_cal_grad2(temp, combinedMask, testMask, deltaTX, deltaTY, theta0, r0, tx0, ty0)

[y0, x0] = meshgrid(1:size(testMask,2), 1:size(testMask,1));
y0 = y0(:);
x0 = x0(:);

delta = 2*(combinedMask - testMask)/numel(testMask);
constant = delta(sub2ind(size(testMask), x0, y0));

tx0 = tx0 + mean(temp(:,1));
ty0 = ty0 + mean(temp(:,2));
% newXY = [cos(theta0), sin(theta0); -sin(theta0), cos(theta0)]*[((x0-tx0)/rx0)';((y0-ty0)/ry0)'] + repmat([mean(temp(:,1));mean(temp(:,2))], 1, numel(x0));
newXY = [cos(theta0), sin(theta0); -sin(theta0), cos(theta0)]*[((x0-tx0)/r0)';((y0-ty0)/r0)'] + repmat([mean(temp(:,1));mean(temp(:,2))], 1, numel(x0));
x1 = newXY(1, :)';
y1 = newXY(2, :)';

X1 = interp2(deltaTX, y1, x1);
Y1 = interp2(deltaTY, y1, x1);
X1(isnan(X1))=0;
Y1(isnan(Y1))=0;


XDtheta = (x0-tx0)/r0*(-sin(theta0)) + (y0-ty0)/r0*cos(theta0);
XDr = -((x0-tx0)*cos(theta0) + (y0-ty0)*sin(theta0))/(r0^2);
XDtx = -cos(theta0)/r0;
XDty = -sin(theta0)/r0;

YDtheta = (x0-tx0)/r0*(-cos(theta0)) + (y0-ty0)/r0*(-sin(theta0));
YDr = ((x0-tx0)*sin(theta0) - (y0-ty0)*cos(theta0))/(r0^2);
YDtx = sin(theta0)/r0;
YDty = -cos(theta0)/r0;

theta2 = constant'*(X1.*XDtheta + Y1.*YDtheta);
r2 = constant'*(X1.*XDr + Y1.*YDr);   
tx2 = constant'*(X1.*XDtx + Y1.*YDtx);
ty2 = constant'*(X1.*XDty + Y1.*YDty);


% 5 parameters
% XDtheta = (x0-tx0)/rx0*(-sin(theta0)) + (y0-ty0)/ry0*cos(theta0);
% XDrx = -(x0-tx0)*cos(theta0)/(rx0^2);
% XDry = -(y0-ty0)*sin(theta0)/(ry0^2);
% XDtx = -cos(theta0)/rx0;
% XDty = -sin(theta0)/ry0;
% 
% YDtheta = (x0-tx0)/rx0*(-cos(theta0)) + (y0-ty0)/ry0*(-sin(theta0));
% YDrx = (x0-tx0)*sin(theta0)/(rx0^2);
% YDry = -(y0-ty0)*cos(theta0)/(ry0^2);
% YDtx = sin(theta0)/rx0;
% YDty = -cos(theta0)/ry0;
% 
% theta2 = constant'*(X1.*XDtheta + Y1.*YDtheta);
% rx2 = constant'*(X1.*XDrx + Y1.*YDrx);
% ry2 = constant'*(X1.*XDry + Y1.*YDry);   
% tx2 = constant'*(X1.*XDtx + Y1.*YDtx);
% ty2 = constant'*(X1.*XDty + Y1.*YDty);
% 
% 

