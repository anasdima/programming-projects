clear all;
clc;

maxSize = 9;

avgElapsed = zeros(1,maxSize);
complexity = zeros(1,maxSize);
N = zeros(1,maxSize);
h = [2.3900 1.8300; 1.2300 2.3900];
for k = 1:maxSize
	N(k) = 2^(k+1);
	im = rand(N(k));
	timeVal = tic;
	for i = 1:100	
		conv2(h,im);
	end
	avgElapsed(k) = toc(timeVal)/100;
	complexity(k) = N(k)*N(k);
end

figure
[hAx,hLine1,hLine2] = plotyy(N,avgElapsed,N,complexity);

title('demo1b: conv2 speed - complexity graph')
xlabel('Matrix Size (N)')

ylabel(hAx(1),'Average Time (sec)') % left y-axis
ylabel(hAx(2),'Computational Complexity O(N)') % right y-axis

grid on
matlab2tikz('../figures/conv2_speed_complexity.tex','showinfo',false);

