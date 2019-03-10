clear all;
fileID = fopen('Dataset/P_1.txt','r');
riD  = fopen('Dataset/Q_1.txt','r');
sizeA = [3 Inf];
formatSpec = '%f %f';

P = fscanf(fileID,formatSpec,sizeA);
Q = fscanf(riD,formatSpec,sizeA);
P = P';
Q = Q';

P_m = repmat(mean(P),size(P,1),1);
Q_m = repmat(mean(Q),size(P,1),1);

P_o = P;
Q_o = Q;

P = P-P_m;
Q = Q-Q_m;

n = 1;

%Creating a descriptor for each of the sets of points. 

[Idx,DP] = knnsearch(P,P,'K',n);
[Idx,DQ] = knnsearch(Q,Q,'K',n);
Idx_f  = [];

%Looking for closest matches between descriptors. 
for  i = 1:size(DP,1)
    [Idx,D] = knnsearch(DP,DQ(i,:));
    DP(Idx,:) = [-Inf]*n;
    Idx_f = [Idx_f,Idx];

end
%%
%Arranging points of P according to descriptor matches. 
P = P(Idx_f,:);
Pi = P(1:end,:);
Qi = Q(1:end,:);

S = Pi'*Qi;
[U,e,V] = svd(S);
R = V*U';

R0  = R;
%%
P1 = (R*P')';
Q1 = Q;
for i = 1:10
    P_m1 = repmat(mean(P),size(P,1),1);
    Q_m1 = repmat(mean(Q),size(P,1),1);
    P1 = P1 - P_m1;
    Q1 = Q1 - Q_m1;
    [Idx,D] = knnsearch(P1,Q1);
    P1 = P1(Idx,:);
    Q1 = Q1;
    S = P1'*Q1;
    [U,e,V] = svd(S);
    R1 = V*U';
    R  = R*R1;
end

t = Q_m(1,:)'-R*P_m(1,:)';

P_e = (R*P_o'+t)';
scatter3(P_e(:,1),P_e(:,2),P_e(:,3));
title('After refinement P');
figure;
scatter3(P_o(:,1),P_o(:,2),P_o(:,3));
title('Pre-refinement-P');
figure;
scatter3(Q_o(:,1),Q_o(:,2),Q_o(:,3));
title('Q');
