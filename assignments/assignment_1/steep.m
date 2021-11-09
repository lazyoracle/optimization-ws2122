function x_next = steep(f, grad_f, x_k)
% function to implement the steepest descent
% f is the function to minimize
% grad_f is the derivative
% x_k is the current estimate

s_k = -grad_f(x_k);
alpha_k = armijo_alphak(f, grad_f, x_k, s_k);
x_next = x_k + alpha_k * s_k;

end