function [LP, EP, TP, optB, newOrder] = alignment_gradientDescent(candidate, edges, tips, M, A, S, D, testMask, templateMask, Parameters)      

if nargin == 9
    alpha = 0.001;
    lambda1 = 50;
    lambda2 = 0.1;
    lambda3 = 1;
    C = 3;
else
    alpha = Parameters.alpha;
    lamda1 = Parameters.lamda1;
    lamda2 = Parameters.lamda2;
    lamda3 = Parameters.lamda3;
    C = Parameters.C;
end

maxiter = size(candidate, 1);
B0 = ones(maxiter, 1);

niter = 1;
B = B0;
optB = Inf(length(B0), 1);
order = zeros(length(B0), 1);
number = 0;

Mg = M;
J = zeros(maxiter, 5);
while niter <= maxiter
    g = alignment_cal_grad(B, S, D, M, A, C, lamda1, lamda2, lamda3);
    B = B - alpha*g;
    newB = B ;

    newB1 = newB;
    newB1(optB==1) = Inf;
    newB1(optB==0) = Inf;
    [~, index] = min(newB1);
    
    newB_1 = newB;
    newB_1(index(1)) = 1;
    [J_1, J1_1, J2_1, J3_1, J4_1] = alignment_calculateObjective(newB_1, S, D, M, A, C, lamda1, lamda2, lamda3);

    newB_0 = newB;
    newB_0(index(1)) = 0;
    [J_0, J1_0, J2_0, J3_0, J4_0] = alignment_calculateObjective(newB_0, S, D, M, A, C, lamda1, lamda2, lamda3);

    if J_1 < J_0
        flipB = 1;
        number = number + 1;
        order(number) = index(1);
        J(niter, :) = [J_1, J1_1, J2_1, J3_1, J4_1];
    else
        flipB = 0;
        J(niter, :) = [J_0, J1_0, J2_0, J3_0, J4_0];
    end
    
    optB(index(1)) = flipB;
    
    newB(optB==1) = 1;
    newB(optB==0) = 0;
    niter = niter + 1;
    B = newB;       
end


M0 = optB'*A;
overlap = (M0*Mg)/sum(Mg);

while overlap <= 0.9
    optJ = alignment_calculateObjective(optB, S, D, M, A, C, lamda1, lamda2, lamda3);
    index = find(optB==0);
    newJ = Inf(numel(index), 1);
    
    for i = 1 : numel(index)
        in = index(i);       
        newB = optB;
        newB(in) = 1;
        newJ(i) = alignment_calculateObjective(newB, S, D, M, A, C, lamda1, lamda2, lamda3);
    end
    
    [minJ, minIn] = min(newJ);
    
    if minJ < optJ
        optB(index(minIn)) = 1;
        number = number + 1;
        order(number) = index(minIn);
    else
        break
    end
    
    M0 = optB'*A;
    overlap = M0*Mg/sum(Mg);
end


index0 = find(optB==1);
for i = 1 : length(index0)
    newB = optB;
    newB(index0(i)) = 0;
    newJ = alignment_calculateObjective(newB, S, D, M, A, C, lamda1, lamda2, lamda3);
    optJ = alignment_calculateObjective(optB, S, D, M, A, C, lamda1, lamda2, lamda3); 

    if newJ < optJ
        optB(index0(i)) = 0;
        number = number - 1;
        order(order==index0(i)) = [];
    end
end


% Check the overlap of each leaf with other leaves
M0 = optB'*A;
nLeaf = sum(optB);
index1 = find(optB==1);
for i = 1 : nLeaf
    in = index1(i);
    temp = templateMask{candidate(in,1), candidate(in,2), candidate(in,3)};
    [x, y] = find(temp==1);
    mask0 = zeros(size(testMask));
    mask0(sub2ind(size(testMask), x+candidate(in,4)-1, y+candidate(in,5)-1)) = 1;
    
    residue = M0' - mask0(:);
    overlap = sum(sum(mask0(:).*residue))/sum(mask0(:));
    if overlap > 0.5 
        optB(in) = 0;
    end
    M0 = optB'*A;
end


% save and return the result
order = order(1:number);
index1 = find(optB==1);
LP = candidate(index1, :);
EP = edges(index1);
TP = tips(index1, :);

newOrder = zeros(size(order));

for l = 1 : size(LP, 1)
    in = index1(l);
    newIn = find(order==in);
    newOrder(l) = newIn;
end




