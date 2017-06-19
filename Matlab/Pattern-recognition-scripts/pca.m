function out = pca2(s,pct,destination)

% pct is a fraction of 100 ( 90%, 95% etc. )


M = csvread(s,1,0);
a = size(M);
rows=a(1);
columns = a(2);
fid = fopen(s);
C = textscan(fid, repmat('%s',1,columns), 'delimiter',',', 'CollectOutput',true);  
fclose(fid);
C=C{1};



[coefs,scores,variances,t2] = princomp(M);

var_pct = 100*variances/sum(variances);
plot(var_pct);
xlabel('Dimension No.');
ylabel('Percentage of Initial Variance');

S=0;
k=1;
for i=1:length(var_pct)
    S=S+var_pct(i);
    if S >= pct
        k=i;
        break;
    end
end

out = scores(:,1:k);
for i=1:k
  first_line{i} = C{(i-1)*rows+i};
end

csvwrite_with_headers(destination,out,first_line);