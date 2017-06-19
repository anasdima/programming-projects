clear all;
clc;

maxSize = 11;
N = zeros(1,maxSize);
h = [2.3900 1.8300; 1.2300 2.3900];

avgElapsed_old = zeros(1,maxSize);

for k = 1:maxSize
	N(k) = 2^(k+1);
	im = rand(N(k));
	timeVal = tic;
	for i = 1:100	
		myconv2_old(h,im);
	end
	avgElapsed_old(k) = toc(timeVal)/100;
end

avgElapsed = zeros(1,maxSize);

for k = 1:maxSize
	im = rand(N(k));
	timeVal = tic;
	for i = 1:100	
		myconv2(h,im);
	end
	avgElapsed(k) = toc(timeVal)/100;
end

figure
plot(N,avgElapsed_old,N,avgElapsed);

title('myconv2 vectorization results')
xlabel('Matrix Size (N)')
ylabel('Average Time (sec)')
legend('semi-vectorized','fully vectorized')
grid on
matlab2tikz('../figures/vectorization.tex','showinfo',false);

