syms x;
f(x) = -4 * (x^2) - 1;
subplot(2,2,1);
fplot(f);
title('f(x)');

subplot(2,2,2);
fplot(-f);
title('-f(x)');

subplot(2,2,3);
fplot(-(x^2));
title('-(x^2)');

subplot(2,2,4);
fplot((x^2));
title('x^2');
