% function [theta1, rx1, ry1, tx1, ty1] = tracking_cal_grad1(obj1, temp, deltaDX, deltaDY, margin, theta0, rx0, ry0, tx0, ty0)
function [theta1, r1, tx1, ty1] = tracking_cal_grad1(temp, deltaDX, deltaDY, margin, theta0, r0, tx0, ty0)

tx0 = tx0 + mean(temp(:,1));
ty0 = ty0 + mean(temp(:,2));
x0 = temp(:, 1) - mean(temp(:,1));
y0 = temp(:, 2) - mean(temp(:,2));

% newXY = [cos(theta0), -sin(theta0); sin(theta0), cos(theta0)]*[x0';y0'].*repmat([rx0; ry0], 1, numel(x0)) + repmat([tx0;ty0], 1, numel(x0));
newXY = [cos(theta0), -sin(theta0); sin(theta0), cos(theta0)]*[x0';y0']*r0 + repmat([tx0;ty0], 1, numel(x0));
x1 = newXY(1, :)';
y1 = newXY(2, :)';

%[m, n] = size(deltaDX);
%[X, Y] = meshgrid(1:n, 1:m);

X1 = interp2(deltaDX, y1+margin, x1+margin);
Y1 = interp2(deltaDY, y1+margin, x1+margin);
X1(isnan(X1))=0;
Y1(isnan(Y1))=0;


XDtheta = x0*r0*(-sin(theta0)) - y0*r0*cos(theta0);
XDr = cos(theta0)*x0 - sin(theta0)*y0;
% XDtx = 1;
% XDty = 0;

YDtheta = x0*r0*(cos(theta0)) - y0*r0*sin(theta0);
YDr = sin(theta0)*x0 + cos(theta0)*y0;
% YDtx = 0;
% YDty = 1;

theta1 = mean(X1.*XDtheta + Y1.*YDtheta);
r1 = mean(X1.*XDr + Y1.*YDr);
tx1 = mean(X1);
ty1 = mean(Y1);




% XDtheta = x0*rx0*(-sin(theta0)) - y0*rx0*cos(theta0);
% XDrx = cos(theta0)*x0 - sin(theta0)*y0;
% % XDry = 0;
% % XDtx = 1;
% % XDty = 0;
% 
% YDtheta = x0*ry0*(cos(theta0)) - y0*ry0*sin(theta0);
% % YDrx = 0;
% YDry = sin(theta0)*x0 + cos(theta0)*y0;
% % YDtx = 0;
% % YDty = 1;
% 
% 
% theta1 = mean(X1.*XDtheta + Y1.*YDtheta);
% rx1 = mean(X1.*XDrx);
% ry1 = mean(Y1.*YDry);
% tx1 = mean(X1);
% ty1 = mean(Y1);



% change on rx
% theta1 = mean(X1.*XDtheta + Y1.*YDtheta)/(rx0+eps);
% % rx1 = mean(X1.*XDrx);
% ry1 = mean(Y1.*YDry)/(rx0+eps);
% tx1 = mean(X1)/(rx0+eps);
% ty1 = mean(Y1)/(rx0+eps);
% 
% rx1 = (mean(X1.*XDrx)*rx0 + obj1)/(rx0^2+eps);





