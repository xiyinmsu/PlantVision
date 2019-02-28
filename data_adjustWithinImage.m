function [x, y] = data_adjustWithinImage(im, x0, y0)

[m, n] = size(im);

x = round(x0);
y = round(y0);

x(x<=0) = 1;
x(x>m) = m;
y(y<=0) = 1;
y(y>n) = n;
