N=10;
zp=zeros(N,N);
op=ones(N,N);

r0=repmat(zp,1,8);

f1=r0; f1(:,N*2+1:N*6)=repmat(op,1,4);
f2=r0; f2(:,N*2+1:N*3)=op;
f3=r0; f3(:,N*2+1:N*5)=repmat(op,1,3);
f=[r0; f1; f2;f2;f3;f2;f2;f2; r0];
figure(1);imshow(f);

r0=repmat(zp,1,7);
t1=r0; t1(:,N*1+1:N*6)=repmat(op,1,5);
t2=r0; t2(:,N*3+1:N*4)=op;
t=[r0; t1; t2;t2;t2;t2;t2;t2; r0];
figure(2);imshow(t);

ft=[f t];
figure(3);imshow(ft);