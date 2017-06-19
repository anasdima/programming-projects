clear all;
clc;

maxSize = 9;

avgElapsed = zeros(1,maxSize);
complexity = zeros(1,maxSize);
N = zeros(1,maxSize);
for k = 1:maxSize
	N(k) = 2^(k+1);
	im = rand(N(k));
	timeVal = tic;
	for i = 1:100	
		fft2(im);
	end
	avgElapsed(k) = toc(timeVal)/100;
	complexity(k) = N(k)*N(k) * log(N(k)*N(k));
end

figure
[hAx,hLine1,hLine2] = plotyy(N,avgElapsed,N,complexity);

title('demo1a: fft2 speed - complexity graph')
xlabel('Matrix Size (N)')

ylabel(hAx(1),'Average Time (sec)') % left y-axis
ylabel(hAx(2),'Computational Complexity O(N)') % right y-axis

set(hAx(1),'YLim', [avgElapsed(1) avgElapsed(end)]);
set(hAx(1),'YTick', 0:0.001:avgElapsed(end));
grid on
matlab2tikz('../figures/fft2_speed_complexity.tex','showinfo',false);

