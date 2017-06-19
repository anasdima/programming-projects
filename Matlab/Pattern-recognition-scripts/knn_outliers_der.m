function out=knn_outliers_der(s,K,dest)

clc;
                     
M = csvread(s,1,0);
a = size(M);
rows=a(1);
columns = a(2);
                     
fid = fopen(s);
C = textscan(fid, repmat('%s',1,columns), 'delimiter',',', 'CollectOutput',true);  
fclose(fid);
C=C{1};
for i=1:columns
  first_line{i} = C{(i-1)*rows+i}
end



[IDM,D] = knnsearch(M,M,'K',K,'Distance','euclidean','BucketSize',50);
d = D(:,K);
[sorted_d indices] = sort(d,'descend');
der = -diff(sorted_d);
m = mean(der);
st = std(der);
                    
[sorted_der indices_der] = sort(der,'ascend');
k=0;
for i=1:length(der)
    if sorted_der(i) >= m + st
        k = i;
        break;
    end
end
                     

if k~=0
  threshold = indices_der(k);
  out(1:threshold) = indices(1:threshold);
  out = sort(out,'ascend');
else
    error('Error');
end
              
counter=1;
for i=1:rows
    if   counter > length(out) || i~= out(counter)
        M_clean(i-(counter-1),:) = M(i,:);
    else
        counter = counter+1;
    end
end

csvwrite_with_headers(s,M_clean,first_line);





