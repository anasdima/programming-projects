function [overall_silhouette cluster_silhouette] = evaluate_cluster(s)

 tic;
 M = csvread(s,1,0);
 a = size(M);
 columns = a(2);
 K = M(:,1:(columns-1));
 clusters = M(:,columns);
 
 point_silhouette = silhouette(K,clusters); 
 L = horzcat(point_silhouette,clusters);
 cluster_silhouette = ones(1,max(clusters)+1);
 for i = 1:max(clusters)+1
    d = L( L(:,2)== i-1, 1);
    cluster_silhouette(i) = mean(d);
 end
 
 
 
 overall_silhouette = mean(cluster_silhouette);
 display(overall_silhouette);
 
 b(1) = overall_silhouette;
 %b(2:length(cluster_silhouette)+1) = cluster_silhouette;
 string=[s '_silhouette.txt'];
 dlmwrite(string,b)
 toc;

          
  
 
 