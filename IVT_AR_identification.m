for year=1980:1:2019; %change to whatever year you want
for k=1:1:12 %change to whatever months you want

if k<10
formatSpec_ivte = '<path_to_file>/ivte%d0%d.nc';
formatSpec_ivtn = '<path_to_file>/ivtn%d0%d.nc';
else
formatSpec_ivte = '<path_to_file>/ivte%d%d.nc';
formatSpec_ivtn = '<path_to_file>/ivtn%d%d.nc';
end
str_ivte = sprintf(formatSpec_ivte,year,k);
str_ivtn = sprintf(formatSpec_ivtn,year,k);

%Variable names are for ERA5, change if needed
ivte1=ncread(str_ivte,'p71.162');
ivtn1=ncread(str_ivtn,'p72.162');
lat=ncread(str_ivte,'latitude');
lon=ncread(str_ivte,'longitude');
ivte1=permute(ivte1,[2 1 3]);
ivtn1=permute(ivtn1,[2 1 3]);

%This is for regridding to a coarser grid, comment out if needed
%note that AR250 will not run on a global ERA5 0.25 degree grid (not enough memory). You don't need it to be that fine res anyuway to identify ARs
%y is lat range you want, x is lon range you want
y=[-90:1:0];
x=[0:1:360];
[Xq,Yq]=meshgrid(x,y);
T=squeeze(length(ivte1(1,1,:)));
for t=1:1:T

        ivte(:,:,t)=interp2(lon,lat,ivte1(:,:,t),Xq,Yq);
        ivtn(:,:,t)=interp2(lon,lat,ivtn1(:,:,t),Xq,Yq);

end

%this calculates IVT 
for t=1:1:T

ivt_o(:,:,t)=sqrt((ivte(:,:,t).^2+ivtn(:,:,t).^2));

%to account for discontinuity of dateline
ivt=[ivt_o(:,:,t),ivt_o(:,1:10,t)];
%This identifies ARs. Make sure REID_ARalgorithm_v3 file is in the same directory. Function input is as follows [dataset,IVT threshold, start lat, end lat, lat resolution (degrees), start lon, end lon (370 to account for dateline), lon resolution (degrees),min length (2000km is common), aspect ratio (2 is common)]  
ar_binary500(:,:,t)=REID_ARalgorithm_v3(ivt,500,-90,0,1,0,370,1,2000,2);
ar_binary250(:,:,t)=REID_ARalgorithm_v3(ivt,250,-90,0,1,0,370,1,2000,2);
ivt_save(:,:,t)=ivt(:,1:360); %this cuts of the extra padding that was needed for the dateline issue
end
ar_binary500=ar_binary500(:,1:360,:);
ar_binary250=ar_binary250(:,1:360,:);

%create netcdf


time=[1:1:T]';

if k<10
%change the file name to whatever, but this is the ARTMIP format
format='ERA5.ar_tag.Reid.6hr.SH_1deg.%d0%d.nc';
else
format='ERA5.ar_tag.Reid.6hr.SH_1deg.%d%d.nc';
end
myfile=sprintf(format,year,k);

%change the dimensions where needed
%ar_binary_tag500
nccreate(myfile,'ar_binary_tag500','Dimensions',{'lat',91,'lon',361,'Time',T},'DataType','double');
ncwrite(myfile,'ar_binary_tag500',ar_binary500);
ncwriteatt(myfile,'ar_binary_tag500','description','binary mask of ARs with 500 threshold');

%ar_binary_tag250
nccreate(myfile,'ar_binary_tag250','Dimensions',{'lat',91,'lon',361,'Time',T},'DataType','double');
ncwrite(myfile,'ar_binary_tag250',ar_binary250);
ncwriteatt(myfile,'ar_binary_tag250','description','binary mask of ARs with 250 threshold');


%ivt
nccreate(myfile,'ivt','Dimensions',{'lat',91,'lon',361,'Time',T},'DataType','double');
ncwrite(myfile,'ivt',ivt_save);
ncwriteatt(myfile,'ivt','description','IVT field kg/m/s');
y=y';
%latitude
nccreate(myfile,'lat','Dimensions',{'lat',91});
ncwrite(myfile,'lat',y);
ncwriteatt(myfile,'lat','standard_name','latitude')
ncwriteatt(myfile,'lat','long_name','latitude')
ncwriteatt(myfile,'lat','units','degrees_north')

x=x';
%longitude
nccreate(myfile,'lon','Dimensions',{'lon',361});
ncwrite(myfile,'lon',x);
ncwriteatt(myfile,'lon','standard_name','longitude')
ncwriteatt(myfile,'lon','long_name','longitude')
ncwriteatt(myfile,'lon','units','degrees_east')


%time
nccreate(myfile,'time','Dimensions',{'time',T});
ncwrite(myfile,'time',time);
ncwriteatt(myfile,'time','standard_name','time')
ncwriteatt(myfile,'time','long_name','time')
ncwriteatt(myfile,'time','units','date of month')

clearvars -except year
end
end
