% function [g, g1, g2, g3, g4] = alignment_cal_grad(B, S, L, D, M, A, C, lamda1, lamda2, lamda3)

function [g, g1, g2, g3, g4] = alignment_cal_grad(B, S, D, M, A, C, lamda1, lamda2, lamda3)
% function [g, g1, g2, g3, g4] = alignment_cal_grad(B, S, D, M, W, A, C, lamda1, lamda2, lamda3)

% flag = iscell(M);
% 
% if flag
%     L = numel(M);
%     nCan = numel(B);
% 
%     G1 = zeros(nCan, L);
%     G2 = zeros(nCan, L);
% 
%     for l = 1 : L
%         G2(:, l) = C*A * ( -2*(M{l}'-(atan(C*B'*A - C*0.5)/pi + 0.5)) ./ ( pi*(1+(C*B'*A - C*0.5).^2)) )' /numel(M{l}) ;
%         G1(:, l) = -B'*S{l}/(sum(B)^2)*sign(B) + S{l}/(sum(B));
%     end
% 
%     g1 = mean(G1, 2);
%     g2 = lamda1*mean(G2, 2);
%     g3 = lamda2*sign(B);
% 
%     g  = g1 + g2 + g3;
% else
    
    J1 = C*A * ( -2*(M'-(atan(C*B'*A - C*0.5)/pi + 0.5)) ./ ( pi*(1+(C*B'*A - C*0.5).^2)) )' /numel(M) ;
%     J1 = 2*(-A)*(M - (B'*A)')/numel(M) ; % without atan
    
    g1 = -B'*S/(sum(B)^2)*sign(B) + S/(sum(B));
    g2 = lamda1*J1;
    g3 = lamda2*sign(B);
%     g3 = lamda2*L;
    g4 = lamda3*(-B'*D/(sum(B)^2)*sign(B) + D/(sum(B)));

    g  = g1 + g2 + g3 + g4;
% end





