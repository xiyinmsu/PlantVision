function [croppedIm, margin] = data_cropBinaryImage(bw, marg)

if nargin==1
    marg = 0;
end

[m, n] = size(bw);
[row, col] = find(bw~=0);

row = sort(row);
col = sort(col);

if min(row) - marg <= 0
    up = 0;
    start_row = 1;
else
    up = min(row) - marg - 1;
    start_row = min(row) - marg;
end

if min(col) - marg <= 0
    left = 0;
    start_col = 1;
else
    left = min(col) - marg - 1;
    start_col = min(col) - marg;
end

if max(row) + marg > m
    down = 0;
    end_row = m;
else
    down = m -(max(row) + marg);
    end_row = max(row) + marg;
end

if max(col) + marg > n
    right = 0;
    end_col = n;
else
    right = n - (max(col) + marg);
    end_col = max(col) + marg;
end

croppedIm = bw(start_row:end_row, start_col:end_col);
margin = [up, left, down, right];

