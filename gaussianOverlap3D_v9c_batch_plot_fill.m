close all
%instr='sub';
%instr='add';
instr='thr';
sfact=4;
ci=0;  %This has no droplets or white pixels.
cf=0.002;  %This is maximum concentration
dc=cf/10;
conc=ci+dc:dc:cf;
conc=[0 conc];
figure
hold on
title('3D Subadditive Random Gaussian Overlap')

if instr=='thr'
	title('3D Convolution Kernel Random Gaussian Overlap')
end
if instr=='add'
	title('3D Additive Random Gaussian Overlap')
end
if instr=='sub'
	title('3D Subadditive Random Gaussian Overlap')
end
xlabel('Concentration, %v/v')
ylabel('Norm. Pixel Sum');
grid on; grid minor;
arr=zeros([10 10]);
zcnt=1;
for zz=2:1:9
	ycnt=1;
	for yy=10000*(ci+dc:dc:cf)
    		try
      		  	astr1=num2str(zz);
			astr2=num2str(yy);
			if instr=='thr'
				astr=strcat('./sums/batch_v9c_thr_nofill_',astr1)
			end
			if instr=='sub'
				astr=strcat('batch_v7_sub_fill_',astr1)
			end
			if instr=='add'
				astr=strcat('batch_v7_add_fill_',astr1)
        		end
			%astr=strcat('batch_sub_',astr1);
			astr=strcat(astr,'_');
			astr=strcat(astr,astr2);
            astr=strcat(astr,'_');
			astr=strcat(astr,num2str(sfact));
            astr=strcat(astr,'.mat');
       			disp(astr);
			vv=load(astr);
			arr(zcnt,ycnt)=vv.summ;
    		catch
        		continue
    		end
		ycnt=ycnt+1;
	end
	zcnt=zcnt+1;
end

disp('summations')
disp(arr)
[r,c]=size(arr)
disp('normalized arrays')
%disp(arr/max(arr(:)))
disp(arr/(255*sfact*256*sfact*256*sfact*256))

ucnt=1;
for rr=2:1:9
	CC={'k','k','k','k','b','r','g','y',[.5 .6 .7],[.8 .2 .6],[.3 .8 .1],[.1 .9 .3],[.2 .2 .8]};
	x=(ci+dc:dc:cf);
	x=[0 x];
	y=arr(ucnt,:);
	y=[0 y];
	bstr=strcat(num2str(rr*2.5),' um')
	%plot(100*x,y/max(arr(:)),'DisplayName',bstr)
	plot(100*x,y/(255*sfact*256*sfact*256*sfact*256),'DisplayName',bstr,'LineWidth',1)
	ucnt=ucnt+1;
end

c1=[0 0.048 0.09 0.13 0.17 0.2];
a1=[0.512 0.637 0.752 0.804 0.846 0.873];
a1b=a1-a1(1)
c2=[0.0 0.0645 0.125 0.1818 0.235 0.2857];
a2=[0.606 0.700 0.764 0.790 0.854 0.856];
a2b=a2-a2(1)
%c3=[0 0.066 0.13 0.186];
c3=[0 0.066 0.186];
%a3=[0.80992 1.2585 1.0767 1.5648];
a3=[0.80992 1.2585 1.5648];
a3=a3*.004/.005;  %slice thickness was 4mm in transverse plane.  .005 by default.
a3b=a3-a3(1)
c4=[0 0.066 0.13 0.186 0.24 0.2905];
a4=[0.4613 0.7311 0.8899 1.2382 1.4176 1.4754];
a4=a4*.004/.005;  %slice thickness was 4mm in transverse plane.  .005 by default.
a4b=a4-a4(1)

std_a1=[0.020536 0.026153 0.04472 0.041587 0.051916 0.049517];
std_a2=[0.046348 0.029879 0.027727 0.022378 0.012962 0.053655];
%std_a3=[0.04981 0.10827 0.071885 0.071631];
std_a3=[0.04981 0.10827 0.071631];
std_a3=std_a3*.004/.005;  %slice thickness was 4mm in transverse plane.  .005 by default.
std_a4=[0.1428 0.1641 0.1176 0.0486 0.0831 0.0996];
std_a4=std_a4*.004/.005;  %slice thickness was 4mm in transverse plane.  .005 by default.


b1=0.4682
c01=0.1324

b2=0.315
c02=0.1814

cc=0:0.01:0.2;
f1=b1*(1-exp(-cc/c01));
f2=b2*(1-exp(-cc/c02));

fun3r = @(c3r,c3)c3r(1)*(1-exp(-c3/c3r(2)))
c0 = [0.1,0.2];
lb = [.001,.001];
ub = [inf,inf];
c3r = lsqcurvefit(fun3r,c0,c3,a3b,lb,ub)
c3r(1)
c3r(2)

fun4r = @(c4r,c4)c4r(1)*(1-exp(-c4/c4r(2)))
c0 = [0.1,0.2];
lb = [.001,.001];
ub = [0.9,inf];  %Had to set limit on dose reponse as the data did not converge on an asymptote.
c4r = lsqcurvefit(fun4r,c0,c4,a4b,lb,ub)
c4r(1)
c4r(2)

plot(cc,f1/b1,'r.','DisplayName','Condition 1','LineWidth',1,'MarkerSize',10)
plot(cc,f2/b2,'b.','DisplayName','Condition 2','LineWidth',1,'MarkerSize',10)
%plot(cc,fun3r(c3r,cc)/c3r(1),'g.','DisplayName','Condition 3','LineWidth',1)
plot(cc,fun4r(c4r,cc)/c4r(1),'m.','DisplayName','Condition 3','LineWidth',1,'MarkerSize',10)
legend('show','Location','southeast')
ylim([0 1.05])

%saveas(gcf,'gaussianOverlap3D_v6_sub_batch_plot_std1.jpg')
if instr=='thr'
	saveas(gcf,'gaussianOverlap3D_v9c_thr_batch_plot_std1_sfact4.jpg')
end
if instr=='sub'
	saveas(gcf,'gaussianOverlap3D_v7_sub_batch_plot_std1.jpg')
end
if instr=='add'
	saveas(gcf,'gaussianOverlap3D_v7_add_batch_plot_std1.jpg')
end
