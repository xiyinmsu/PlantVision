function [template, templateMask, templateTip] = GenerateTemplates(Leaves, scales, nDirect, threshold, visual)
% GenerateTemplates: generate leaf templates with specified parameters
% INPUT:
% - Leaves: nShape*1 cell contains leaf templates with different shapes
% - scales: nSclae*1 vector indicate the scales for all templates. Leaves
% will be scaled to speficied scales. 
% - nDirect: a scale value indicate the number of directions
% - threshold: threshold for binary segmentation 
% - visual: binary value to indicate whether to visualize the result or not
%   default is 0.
% 
% OUTPUT: 
% - template: nShape*nScale*nDirect cell contains all template edges. 
% - templateMask: the same size as template where contains all template
% masks. 
% - templateTip: the same size as template where contains all tip
% information of each template. 

if nargin == 4
    visual = 0;
end

nShape = numel(Leaves);
nScale = length(scales);
angle = 360/nDirect;

template = cell(nShape, nScale, nDirect);
templateMask = cell(nShape, nScale, nDirect);
templateTip = cell(nShape, nScale, nDirect);

for sh = 1 : nShape
    leaf1 = Leaves{sh};    
    for s = 1 : nScale
        leaf2 = imresize(leaf1, scales(s), 'bicubic');
        for d = 1 : nDirect
            an = (d-1)*angle;
            leaf3 = imrotate(leaf2, an);
            bw = im2bw(leaf3, threshold); 
            bw1 = cropBinaryImage(bw, 2, 'equal');
            e1 = edge(bw1, 'canny');
            
            templateMask{sh, s, d} = bw1;
            template{sh, s, d} = e1;
            
            [x, y] = find(e1==1);
            x0 = mean(x);
            y0 = mean(y);
            
            dist1 = abs((x0-x) - tan(an/180*pi+pi/2)*(y-y0));
            [~, index1] = sort(dist1);
            x1 = x(index1(1));
            y1 = y(index1(1));
            for i = 2 : numel(index1)
                if abs(x0-(x1+x(index1(i)))/2) < 5 && abs(y0-(y1+y(index1(i)))/2) < 5
                    x2 = x(index1(i));
                    y2 = y(index1(i));
                    break
                end
            end
            
            switch d
                case {1}
                    if x1 < x2
                        tip = [x1, y1; x2, y2];
                    else
                        tip = [x2, y2; x1, y1];
                    end
                case {2,3,4,5,6,7,8,9,10,11,12}
                    if y1 < y2
                        tip = [x1, y1; x2, y2];
                    else
                        tip = [x2, y2; x1, y1];
                    end
                case 13
                    if x1 > x2
                        tip = [x1, y1; x2, y2];
                    else
                        tip = [x2, y2; x1, y1];
                    end
                case {14,15,16,17,18,19,20,21,22,23,24}
                    if y1 > y2
                        tip = [x1, y1; x2, y2];
                    else
                        tip = [x2, y2; x1, y1];
                    end
            end
            templateTip{sh, s, d} = tip;
            
            if visual            
                figure(1),imshow(~e1)
                hold on
                plot(tip(1,2), tip(1,1), 'r+')
                plot(tip(2,2), tip(2,1), 'g*')
                hold off
                pause(0.1)
%                 close
            end
            disp([num2str(sh), '-', num2str(s), '-', num2str(d)])
        end
    end
end

% save('template.mat', 'template', 'templateMask')
% save('templateTip.mat', 'templateTip')

