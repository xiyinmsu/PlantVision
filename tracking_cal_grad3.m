function  [theta3, r3, tx3, ty3] = tracking_cal_grad3(temp, Theta, Cx, Cy, theta0, r0, tx0, ty0)

tx0 = tx0 + mean(temp(:,1));
ty0 = ty0 + mean(temp(:,2));
x0 = temp(:, 1) - mean(temp(:,1));
y0 = temp(:, 2) - mean(temp(:,2));

newXY = [cos(theta0), -sin(theta0); sin(theta0), cos(theta0)]*[x0';y0']*r0+ repmat([tx0;ty0], 1, numel(x0));
x1 = newXY(1, :);
y1 = newXY(2, :);

N = size(temp, 1);
deltaX = sum(x1)/N - Cx;
deltaY = sum(y1)/N - Cy;
S = sqrt(deltaX^2 + deltaY^2);
constant = 2*(sin(Theta+theta0)*S + deltaY);

XDtheta = x0*r0*(-sin(theta0)) - y0*r0*cos(theta0);
XDr = cos(theta0)*x0 - sin(theta0)*y0;
XDtx = ones(N, 1);
XDty = zeros(N, 1);

YDtheta = x0*r0*(cos(theta0)) - y0*r0*sin(theta0);
YDr = sin(theta0)*x0 + cos(theta0)*y0;
YDtx = zeros(N, 1);
YDty = ones(N, 1);

theta3 = constant*(cos(Theta+theta0)*S + sin(Theta+theta0)*(deltaX*mean(XDtheta) + deltaY*mean(YDtheta))/S + mean(YDtheta));
r3 = constant*(sin(Theta+theta0)*(deltaX*mean(XDr) + deltaY*mean(YDr))/S + mean(YDr));
tx3 = constant*(sin(Theta+theta0)*(deltaX*mean(XDtx) + deltaY*mean(YDtx))/S + mean(YDtx));
ty3 = constant*(sin(Theta+theta0)*(deltaX*mean(XDty) + deltaY*mean(YDty))/S + mean(YDty));





