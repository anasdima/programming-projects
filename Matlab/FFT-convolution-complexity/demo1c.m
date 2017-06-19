clear all;
clc;

avgElapsed = zeros(1,9);
complexity = zeros(1,9);
N = zeros(1,9);
h = [2.3900 1.8300; 1.2300 2.3900];
for k = 1:9
	N(k) = 2^(k+1);
	x = rand(N(k));
	timeVal = tic;
	for i = 1:100
		myconv2(h,x);
	end
	avgElapsed(k) = toc(timeVal)/100;
	complexity(k) = N(k)*N(k);;
end

figure
[hAx,hLine1,hLine2] = plotyy(N,avgElapsed,N,complexity);

title('demo1c: myconv2 speed - complexity graph')
xlabel('Matrix Size (N)')

ylabel(hAx(1),'Average Time (sec)') % left y-axis
ylabel(hAx(2),'Computational Complexity O(N)') % right y-axis

grid on
matlab2tikz('../figures/myconv2_speed_complexity.tex','showinfo',false);
