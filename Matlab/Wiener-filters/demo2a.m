clear all;
load ../images.mat;
clc;

i = [-7 -6 -5 -4];

for j = 1:4
	y2n = y2 + (10^i(j))*(randn(size(y2)));
	x2hat = invfilter(y2n,estMask(x1,y1),1);
	error = (x2hat-x2).^2;
	J(j) = mean(error(:));
end

figure
plot(i,J);

title('Mean square error of inverse filter with noise')
xlabel('i')
ylabel('Mean square error')
grid on
matlab2tikz('../report/figures/inversenoise.tex','showinfo',false);