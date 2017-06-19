function out = pca2_explore(M,pct)

% pct is a fraction of 100 ( 90%, 95% etc. )



[coefs,scores,variances,t2] = princomp(M);

var_pct = 100*variances/sum(variances);
plot(var_pct);
xlabel('Dimension No.');
ylabel('Percentage of Initial Variance');
hold on;

S=0;
k=1;
for i=1:length(var_pct)
    S=S+var_pct(i);
    if S >= pct
        k=i;
        break;
    end
end
stem(k,25,'r')



