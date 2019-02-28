function displayResult(LP, EP, TP, testIm, leafID)
    
if nargin == 4
    leafID = 1 : numel(EP);
end
nLeaf = numel(leafID);

figure(1)
imshow(~testIm)
hold on
for leaf = 1 : nLeaf
    if leafID(leaf)~=0 
        leaf_x = LP(leaf, 4);
        leaf_y = LP(leaf, 5);
        leaf_h = LP(leaf, 6);
        leaf_w = LP(leaf, 7);

        if sum(LP(leaf, 4:7))>0
            rectangle('Position', [leaf_y, leaf_x, leaf_w, leaf_h],  'LineWidth', 1, 'EdgeColor', 'b')
            plot(EP{leaf}(:,2), EP{leaf}(:,1), 'r.')
            plot(TP(leaf, 2), TP(leaf, 1), 'y*', 'LineWidth', 2)
            plot(TP(leaf, 4), TP(leaf, 3), 'g*', 'LineWidth', 2)
            
            if nargin == 5
                text(mean(EP{leaf}(:,2)), mean(EP{leaf}(:,1)), num2str(leafID(leaf)), 'FontSize', 12)
            end
        end
    end
end



        


