function trackingResultVisulization(PlantLocations, Dataset, edges, savepath)

if nargin == 4
    saveResult = 1;
    if savepath(end)~='\'
        savepath = [savepath, '\'];
        mkdir(savepath)
    end
else
    saveResult = 0;
end     
    
nPlant = size(PlantLocations, 1);
nImage = numel(Dataset.Image);

for pt = 1 : nPlant
    rg = PlantLocations(pt, :);
    
    if saveResult
        mkdir([savepath, num2str(pt), '\'])
    end

    for im = nImage:-1:1
        inputIm = Dataset.Image{im};
        plant = inputIm(rg(2): rg(2)+rg(4)-1, rg(1):rg(1)+rg(3)-1);
        
        figure(1)
        imshow(plant)
        hold on
        EP = edges{pt, im};
        for i = 1 : length(EP)
            if ~isempty(EP{i})
                plot(EP{i}(:,2), EP{i}(:,1), 'r*')
            end
        end
        
        if saveResult        
            file0 = Dataset.Filenames{im}(1:end-4);
            saveas(1, [savepath, num2str(pt), '\',  file0, '.jpg'])
            close
        else
            pause(0.5)
            close
        end
    end
end

       
