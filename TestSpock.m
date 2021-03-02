function TestSpock()
Film = VideoReader('xylophone.mp4');
%first get to the starting point
fprintf('\njumping to starting point\n');
for i = 1:50
    cdataRGB = readFrame(Film);
fprintf('.');
end
end