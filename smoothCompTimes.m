       
function ans = smoothCompTimes(analysis, maxjmp)
maxjump = maxjmp;
jumpsize = cat(1, [0,0],abs(diff(analysis.MouseLoc))>=maxjump);

mouse_x_index = find(jumpsize(:,1) > 0);
mouse_y_index = find(jumpsize(:,2) > 0);

x1 = [];
y1 = [];
x2 = [];
y2 = [];
for j = 1:length(mouse_x_index)
     if sum(analysis.CompartmentTimes{1} == mouse_x_index(j)*2) > 0
            x1 = horzcat(x1, find(analysis.CompartmentTimes{1} == mouse_x_index(j)*2));
     end
     if sum(analysis.CompartmentTimes{2} == mouse_x_index(j)*2) > 0
            x2 = horzcat(x2, find(analysis.CompartmentTimes{2} == mouse_x_index(j)*2));
     end
end

for j = 1:length(mouse_y_index)
     if sum(analysis.CompartmentTimes{1} == mouse_y_index(j)*2) > 0
            y1 = horzcat(y1, find(analysis.CompartmentTimes{1} == mouse_y_index(j)*2));
     end
     if sum(analysis.CompartmentTimes{2} == mouse_y_index(j)*2) > 0
            y2 = horzcat(y2, find(analysis.CompartmentTimes{2} == mouse_y_index(j)*2));
     end
end
      
ind_1 = [x1 y1];
ind_1 = sort(ind_1);
ind_1 = unique(ind_1);

ind_2 = [x2 y2];
ind_2 = sort(ind_2);
ind_2 = unique(ind_2);


analysis.CompartmentTimes{1}(ind_1) = [];
analysis.CompartmentTimes{2}(ind_2) = [];
ans = cell(1,2);
ans{1} = analysis.CompartmentTimes{1};
ans{2} = analysis.CompartmentTimes{2};
end

