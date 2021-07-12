sd=10;
sfact=4;
%fun = @(x,y,z) (1/((sqrt(2*pi)^(3/2))*sd*sd*sd))*exp(-(x.*x+y.*y+z.*z)/(2*sd*sd));
fun = @(x,y,z) exp(-(x.*x+y.*y+z.*z)/(2*sd*sfact*sd*sfact));
xmin=-128*sfact;
xmax=128*sfact;
ymin=-128*sfact;
ymax=128*sfact;
zmin=-128*sfact;
zmax=128*sfact;
q1 = integral3(fun,xmin,xmax,ymin,ymax,zmin,zmax)
xmin=-1*sfact*sd;
xmax=1*sfact*sd;
ymin=-1*sfact*sd;
ymax=1*sfact*sd;
zmin=-1*sfact*sd;
zmax=1*sfact*sd;
q2 = integral3(fun,xmin,xmax,ymin,ymax,zmin,zmax);
q3=q2/q1
%q1 should be 1
%q2 should be 0.68
xx=sfact*256;
yy=sfact*256;
zz=sfact*256;
oi=zeros([xx,yy,zz]);  %single gaussian element at center of image
oi_68=oi;
cx=round(xx/2); cy=round(yy/2); cz=round(zz/2);
 for i=1:xx
    for j=1:yy
        for k=1:zz
            d2=sqrt((i-cx)*(i-cx)+(j-cy)*(j-cy)+(k-cz)*(k-cz));
            if (d2<=1*sd*sfact)
                 oi_68(i,j,k)=exp(-((i-cx)*(i-cx)+(j-cy)*(j-cy)+(k-cz)*(k-cz))/(2*sfact*sd*sfact*sd));
            end
            oi(i,j,k)=exp(-((i-cx)*(i-cx)+(j-cy)*(j-cy)+(k-cz)*(k-cz))/(2*sfact*sd*sfact*sd));  %using 90% as interaction radius rather than 63%
        end
    end
 end
sum_oi=sum(oi(:))
sum_68=sum(oi_68(:))
sum_68/sum_oi