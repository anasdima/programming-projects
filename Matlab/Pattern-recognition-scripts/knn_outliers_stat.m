function out = knn_outliers_stat(s,destination,K,p)

clc;
M = csvread(s,1,0);
a = size(M);
rows=a(1);
columns = a(2);
[IDM,D] = knnsearch(M,M,'K',K,'Distance','euclidean','BucketSize',30);
d = D(:,K);
[sorted_d indices] = sort(d,'descend');

fid = fopen(s);
C = textscan(fid, repmat('%s',1,columns), 'delimiter',',', 'CollectOutput',true);  
fclose(fid);
C=C{1};
for i=1:columns
  first_line{i} = C{(i-1)*rows+i};
end



k = ceil(p * length(sorted_d));
 	

if k~=0
  threshold = k;
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

csvwrite_with_headers(destination,M_clean,first_line);


