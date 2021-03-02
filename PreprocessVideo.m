function  PreprocessVideo(fn)
%SPOCK hates videos. Prerocess and save individual files and then delete
%afterwards

%save as individual images
% load(fn);
% COUNT = 1;
% [savepath,savefn] = fileparts(Movie_fn);
% Film = VideoReader(Movie_fn);
% for k=StartingFrame:dsFactor:EndingFrame
%    img = read(Film,k);
%    filename = ([savepath filesep savefn,sprintf('%d.jpg',COUNT)]);
%    imwrite(img,filename)    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)   
%    if mod(COUNT,10)==0
%       fprintf('\t%d out of %d Complete\n',COUNT,floor((EndingFrame-StartingFrame)/dsFactor));
%    end   
%    COUNT = COUNT+1;
% end

load(fn);
Film = VideoReader(Movie_fn);
COUNT=1;
for k=StartingFrame:dsFactor:EndingFrame
  cdataBW_ThresholdValue=im2bw(read(Film,k),ThresholdValue);
  [savepath,savefn] = fileparts(Movie_fn);     
  save([savepath filesep savefn,sprintf('%d.mat',COUNT)],'cdataBW_ThresholdValue');
   if mod(COUNT,10)==0
      fprintf('\t%d out of %d Complete\n',COUNT,floor((EndingFrame-StartingFrame)/dsFactor));
   end   
   COUNT = COUNT+1;
end
end