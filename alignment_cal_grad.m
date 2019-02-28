function [g, g1, g2, g3, g4] = alignment_cal_grad(B, S, D, M, A, C, lamda1, lamda2, lamda3)
   
    J1 = C*A * ( -2*(M'-(atan(C*B'*A - C*0.5)/pi + 0.5)) ./ ( pi*(1+(C*B'*A - C*0.5).^2)) )' /numel(M) ;
   
    g1 = -B'*S/(sum(B)^2)*sign(B) + S/(sum(B));
    g2 = lamda1*J1;
    g3 = lamda2*sign(B);
    g4 = lamda3*(-B'*D/(sum(B)^2)*sign(B) + D/(sum(B)));

    g  = g1 + g2 + g3 + g4;





