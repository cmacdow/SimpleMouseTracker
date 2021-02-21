figure
hold on
imshow(firstFrame)
hold on
scatter(MouseLoc(:,1),MouseLoc(:,2),'r','.'); %Zone one is the stranger animal 
% for i = 1:length(MouseLoc)
%     scatter(MouseLoc(i,1),MouseLoc(i,2),'r','.')
%     hold on
%     drawnow
% end
% scatter(MouseLoc(:,1),MouseLoc(:,2),'r','.')
for i = 1:length(InteractionTimes{1,2})/2
var = InteractionTimes{1,2}(i) - StartingFrame;
scatter(MouseLoc(var,1),MouseLoc(var,2),'b','*')
hold on
% drawnow
end

for i = 1:length(InteractionTimes{1,1})/2
var = InteractionTimes{1,1}(i) - StartingFrame;
scatter(MouseLoc(var,1),MouseLoc(var,2),'g','*')
hold on
% drawnow
end

