function [J, J1, J2, J3, J4] = alignment_calculateObjective(B, S, D, M, A, C, lamda1, lamda2, lamda3)

J1 = B'*S/sum(B);
J2 = lamda1*sum((M'-atan(C*B'*A-C*0.5)/pi-1/2).^2)/numel(M);  
J3 = lamda2*sum(B);
J4 = lamda3*B'*D/sum(B);

J = J1 + J2 + J3 + J4;

