%scratch

data = dff(:,:,1:2:end)+dff(:,:,2:2:end);
[data, nanpxs] = conditionDffMat(data);
data = filterstack(data, opts.fps, gp.w_filter_freq, gp.w_filter_type, 1, 0);
data = conditionDffMat(data,nanpxs);

for i = 3976:3984; imagesc(temp(:,:,i),[0,2.5]); title(sprintf('%d',i)); pause(0.1); end

temp = data;
temp(isnan(temp))=0;
temp = imgaussfilt3(temp,[0.70 0.70 0.1]);

close all; figure; hold on;
COUNT = 0;
for i = 3977:3985
    subplot(2,5,COUNT+1); imagesc(temp(:,:,i),[0,2.5]);
    title(sprintf('%d ms',COUNT*opts.fps));
    axis off; colormap magma; 
    COUNT=COUNT+1;
end

set(gcf,'position',[85         231        1837         741]);


subplot(2,5,10); imagesc(nanmax(temp,[],3),[0,10]);
title(sprintf('%d',COUNT*opts.fps));
axis off; colormap magma; 