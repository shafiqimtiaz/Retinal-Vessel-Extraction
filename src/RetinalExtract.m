function bloodVessels = RetinalExtract(inImg, threshold)

%Sobel's Templates
h1=[-1 -2 -1;
     0  0  0;
     1  2  1];
h2=[-1 0 1;
    -2 0 2;
    -1 0 1];

%Spatial Filtering by Sobel's Templates
t1=filter2(h1,inImg);
t2=filter2(h2,inImg);

s=size(inImg);
bloodVessels=zeros(s(1),s(2));
temp=zeros(1,2);

for i=1:s(1)
    for j=1:s(2)
        temp(1)=t1(i,j);temp(2)=t2(i,j);
        if(max(temp)>threshold)
            bloodVessels(i,j)=max(temp);
        end
    end
end
