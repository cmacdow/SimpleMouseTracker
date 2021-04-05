
count = 0;
when_change = [];
for i = 1:(length(analysis.CompartmentTimes{2})-1)
    if ((analysis.CompartmentTimes{2}(i+1) - analysis.CompartmentTimes{2}(i)) > 60)
        for j = 1:length(analysis.CompartmentTimes{1})
             if (analysis.CompartmentTimes{1}(j) >= (analysis.CompartmentTimes{2}(i)+ 10)) && (analysis.CompartmentTimes{1}(j) < (analysis.CompartmentTimes{2}(i) + 120))
                    count = count + 1;
                    when_change = vertcat(when_change, analysis.CompartmentTimes{2}(i));
                    break;
             end
        end
    end
end

count1 = 0;
when_change1 = [];

for i = 1:(length(analysis.CompartmentTimes{1})-1)
    if ((analysis.CompartmentTimes{1}(i+1) - analysis.CompartmentTimes{1}(i)) > 60)
        for j = 1:length(analysis.CompartmentTimes{2})
             if (analysis.CompartmentTimes{2}(j) >= (analysis.CompartmentTimes{1}(i) +10)) && (analysis.CompartmentTimes{2}(j) < (analysis.CompartmentTimes{1}(i) + 120))
                    count1 = count1 + 1;
                    when_change1 = vertcat(when_change1, analysis.CompartmentTimes{1}(i));
                    break;
             end
        end
    end
end

2:27
         163 comp(2) 82 83=969
        199 (comp1) (1:10)

jumps1 = 0;
diff1 = [];
index_jump1 = [];
time_jump1 = [];

for i = 1:(length(analysis.CompartmentTimes{1})-1)
    if ((analysis.CompartmentTimes{1}(i+1) - analysis.CompartmentTimes{1}(i)) > 30)
       jumps1 = jumps1 +1;
       diff1 = horzcat(diff1, (analysis.CompartmentTimes{1}(i+1) - analysis.CompartmentTimes{1}(i)))
       time_jump1 = vertcat(time_jump1, analysis.CompartmentTimes{1}(i));
       index = find(analysis.CompartmentTimes{1} == analysis.CompartmentTimes{1}(i));
       index_jump1 = vertcat(index_jump1, index);
    end
end

jumps2 = 0;
diff2 = [];
index_jump2 = [];
time_jump2 = [];
for i = 1:(length(analysis.CompartmentTimes{2})-1)
    if ((analysis.CompartmentTimes{2}(i+1) - analysis.CompartmentTimes{2}(i)) > 30)
       jumps2 = jumps2 +1;
       diff2 = horzcat(diff2, (analysis.CompartmentTimes{2}(i+1) - analysis.CompartmentTimes{2}(i)));
       time_jump2 = vertcat(time_jump2, analysis.CompartmentTimes{2}(i));
       index = find(analysis.CompartmentTimes{2} == analysis.CompartmentTimes{2}(i));
       index_jump2 = vertcat(index_jump2, index);
    end
end
matrix = zeros(length(time_jump1), length(time_jump2))
for i = 1:length(time_jump1)
    for j = 1:length(time_jump2)
        matrix(i,j) = time_jump2(j) - time_jump1(i)
    end
end

        comp1 = analysis.CompartmentTimes{1};
        comp2 = analysis.CompartmentTimes{2};
        
        
        
        
count = 0;
whencomp2 = [];
for i = 1:length(time_jump2)
    time_jump_min = time_jump2(i) +10;
    time_jump_max = time_jump2(i) + 100;
    for j = 1:(length(analysis.CompartmentTimes{1})-1)
        if (analysis.CompartmentTimes{1}(j) > time_jump_min) & (analysis.CompartmentTimes{1}(j) < time_jump_max)
            count = count + 1;
            whencomp2 = vertcat(whencomp2, analysis.CompartmentTimes{1}(j))
            break;
        end
    end
end




        20
        
        
       