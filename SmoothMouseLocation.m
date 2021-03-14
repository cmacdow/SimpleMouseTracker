function MouseLoc = SmoothMouseLocation(MouseLoc,maxjump)

if nargin <2
    maxjump = 50;
end

%remove large jumps, iterate until no more found
jumpsize = cat(1, [0,0],abs(diff(MouseLoc))>=maxjump);
MouseLoc(jumpsize==1)=NaN;
MouseLoc = fillmissing(MouseLoc,'nearest');

%now interate along smaller jumps
jumpsize =1;
while sum(jumpsize>0)
    jumpsize = cat(1, [0,0],abs(diff(MouseLoc))>=maxjump);
    MouseLoc(jumpsize==1)=NaN;
    MouseLoc = fillmissing(MouseLoc,'linear');
end

end