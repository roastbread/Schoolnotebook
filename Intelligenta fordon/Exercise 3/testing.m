
LINEMODEL = [0, 0, 2425, 0;
             2425, 0, 2425, 3640;
             2425, 3640, 0, 3640;
             0, 3640, 0, 0]
rot_mat = [0, -1; 1, 0] 
for i = 1: 4
       p1(i,1:2) = LINEMODEL(i,1:2);
       p2(i,1:2) = LINEMODEL(i,3:4);
       Lin(i,1:2) = p2(i,1:2)-p1(i,1:2);
       u(i,1:2) = ((rot_mat*Lin(i,1:2)')/norm(Lin(i,1:2)));
       dista(i) = dot(u(i,1:2), p1(i,1:2));
end


a = [1,1,0,0];
b = [1,2,3,4]';

ab=a*b
ba = b*a

c = [-3, 5, -7, -11]
abs(c)