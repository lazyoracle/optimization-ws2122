x0 = [0,0];
[x,fval,exitflag,output] = fminunc(@rosenbrockwithgrad,x0);
x
fval