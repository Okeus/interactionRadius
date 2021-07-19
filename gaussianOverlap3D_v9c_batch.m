%gaussianOverlap3D_v9c_batch.m
%Example usage:
% for u=1:80
%    gaussianOverlap3D_v9c_batch(u)
% end

%function gaussianOverlap3D_v9c_batch(arr_idx)
function gaussianOverlap3D_v9c_batch()
    %parpool(4)
    %opts=parforOptions(parcluster('local'));
	%gpuDevice
    %istr='sub'
	%istr='add'
    tic
	istr='thr'
    sfact=4;
	datetime('now')
    xx=sfact*256;
    yy=sfact*256;
    zz=sfact*256;
    
    cx=round(xx/2); cy=round(yy/2); cz=round(zz/2);
    nn=xx*yy*zz;
    ci=0;
    cf=0.002;
    dc=cf/10;
    Nm=round(cf/(4/3*pi*(sfact*sfact*sfact))*(xx*yy*zz)); %most number of particles for h$
        
    pcnt=1;
    summ2=length(ci+dc:dc:cf);
    summ1=length(2:9);
    summ_out=zeros([summ1 summ2]);
    for rf=2:1:9
        for conc=ci+dc:dc:cf
            idx_mat(pcnt,1)=rf;
            idx_mat(pcnt,2)=conc;
            pcnt=pcnt+1;
        end
    end
    disp(size(idx_mat));
    aaa=str2num(getenv('SLURM_ARRAY_TASK_ID'));
    %aaa=arr_idx;
    radi=idx_mat(aaa,1);
    
    cnt=1;
    pts=ones([Nm,3]); %array of central coordinates of guassians
    dd=zeros([Nm 1]);
    while(cnt<=Nm)
        x=randi(xx);y=randi(yy);z=randi(zz);
        xyz=[x y z];
        t1=(pts(1:cnt,1)-xyz(1,1)).^2;
        t2=(pts(1:cnt,2)-xyz(1,2)).^2;
        t3=(pts(1:cnt,3)-xyz(1,3)).^2;
        dd(1:cnt)=(t1+t2+t3);
        dd=sqrt(dd);
        %if(dd(1:cnt,1)> radi) %check that all points are more than X pixels from next nearest point.
        if(dd(1:cnt,1)> 2*sfact) %check that all points are more than X pixels from next nearest point.
            pts(cnt,1)=x; pts(cnt,2)=y;pts(cnt,3)=z;
            cnt=cnt+1;
        end
    end
    pts_xyz=pts;
      
    oi=zeros([xx,yy,zz]);  %single gaussian element at center of image
    %zr=zeros([xx,zz,zz,2]);
    for i=1:xx
        for j=1:yy
            for k=1:zz
%             d2=(i-cx)*(i-cx)+(j-cy)*(j-cy)+(k-cz)*(k-cz);
%             if (d2>sfact)
%                  oi(i,j,k)=255*exp(-((i-cx)*(i-cx)+(j-cy)*(j-cy)+(k-cz)*(k-cz))/(2*sfact*radi(1)*sfact*radi(1)));
%             end
                %oi(i,j,k)=255*exp(-((i-cx)*(i-cx)+(j-cy)*(j-cy)
                oi(i,j,k)=255*exp(-((i-cx)*(i-cx)+(j-cy)*(j-cy)+(k-cz)*(k-cz))/(2*sfact*radi(1)*sfact*radi(1)));  %using 90% as interaction radius rather than 63%
            end
        end
    end
    r4=4*sfact*radi
    B=oi(cx-r4:cx+r4,cy-r4:cy+r4,cz-r4:cz+r4);
    Bmax=max(B(:));

    summ=zeros([1 summ2]);
    conc=idx_mat(aaa,2);
    conc_10000=10000*conc;
    %oi3=zeros([xx,yy,zz]);
    disp(['conc: ',num2str(conc),', interaction radius: ',num2str(radi),' um']);
    cnt=1;
    N=round(conc/(4/3*pi*sfact*sfact*sfact)*(xx*yy*zz));
    [ru,cu]=size(pts_xyz);
    N1=ru;
    N2=N;
    rN=N1-N2;
    rand_rN=randperm(N1,rN);
    pts=pts_xyz;
    pts(rand_rN,:)=[];
    [cnt,ccc]=size(pts);

    [rr,cc]=size(pts);
    A=zeros([xx,yy,zz]);
    for j=1:rr
        a1=pts_xyz(j,1);
        a2=pts_xyz(j,2);
        a3=pts_xyz(j,3);
        A(a1,a2,a3)=1;
    end
    whos
    %B=gpuArray(B);
    %B=distributed(B);
    %B=tall(B);
    %A=gpuArray(A);
    %A=distributed(A);
    %A=tall(A);
    C=convn(A,B,'same');
    C(C>Bmax)=Bmax;
    [rr,cc]=size(pts_xyz);
    
    %This seems to have an error.....
%     for j=1:rr          
%         try
%             a1=pts_xyz(j,1);
%             a2=pts_xyz(j,2);
%             a3=pts_xyz(j,3);
%             C(a1-k:a1+k,a2-k:a2+k,a3-k:a3+k)=0;
%         catch ME
%             disp(ME)
%         end
%     end
    
    asum=sum(C,'all');
    summ=gather(asum)
    C2=gather(C(:,:,100));
    imagesc(C2)
	xstr=strcat('slice_',num2str(radi),'_',num2str(conc_10000),'_',num2str(sfact));
	xstr=strcat(xstr,'.jpg')
	saveas(gcf,xstr) %save slice 100 to see distribution profile.
    if istr=='add'
		 astr=strcat('batch_v9c_add_nofill_',num2str(radi),'_',num2str(conc_10000),'_',num2str(sfact));
	end
	if istr=='sub'
		 astr=strcat('batch_v9c_sub_nofill_',num2str(radi),'_',num2str(conc_10000),'_',num2str(sfact));
	end
	if istr=='thr'
		 astr=strcat('batch_v9c_thr_nofill_',num2str(radi),'_',num2str(conc_10000),'_',num2str(sfact));
	end
	astr=strcat(astr,'.mat');
    save(astr,'summ')
    format long
    disp(summ)
    datetime('now')
    toc
    clear all
end



