%% Notes
% here I have three examples, split into to two cells each. The first cell
% in each pair is loading some data, the second is the actual figures.

% my first example is a figure from my present manuscript: plotting plume
% concentration

% my second example is small heat chart based on behavioral data, used as a
% reference for my simulation data.

% my third example uses a sort of random walk to generate some position 
% data, then I plot it.

%% data & equations
% comsol data

% read in the data
[fname, pname] = uigetfile('*.csv','title');
data = csvread(strcat(pname,fname));

% extract the data from the larger matrix
x = data(:,1);
y = data(:,2);
c = data(:,3);


% plume equation
% create an anonymous function to describe the concentration at all points.
% This is based on fitting the data imported above to the function 
% described below (conFunc).

% set the constants of the function:
c1 = 0.3096;
c2 = 0.1415;
c3 = 1.0;
c4 = 3.214 * 10^-5;

%the concentration function itself:
conFunc =@(x,y) ((c1 ./ sqrt(c2 + ((1525-x)./1000))) .* ...
    exp(-((y./1000 - 0.475).^ 2) ./ (c4 .* ((1525-x)./1000 + c3))));


% detection boundary
% more anonymous functions, these describe where the plume concentration is
% detectable. They were found by asking where conFunc==c_detectable
boundaryFunc1 =@(x) 1.96681.*10^-17.*(2.41508*10^19-1.*...
    sqrt(-2.09985.*10^35+8.31623.*10^31.*x).*...
    sqrt(log(1.35658914728682.*10^-13.*...
    sqrt(1.66650000000000-0.00100000000000000.*x))));
boundaryFunc2 =@(x) 1.96681.*10^-17.*(2.41508*10^19+1.*...
    sqrt(-2.09985.*10^35+8.31623.*10^31.*x).*...
    sqrt(log(1.35658914728682.*10^-13.*...
    sqrt(1.66650000000000-0.00100000000000000.*x))));

% use the boundary functions to create data for two lines, to be plotted
% over the figures:
x_boundary  = 0:1525;
y_boundary1 = boundaryFunc1(x_boundary);
y_boundary2 = boundaryFunc2(x_boundary);
z_boundary  = zeros(1,1526)+2;


%% plots

% make the figure window and hold it
figure
hold on

% set the colormap
myMap4 =[255:-(255-120)/100:120;...
    255:-(255-81)/100:81;...
    255:-(255-169)/100:169]'/255; % white to purple!

colormap(myMap4)


% plot the first panel:
subplot(2,2,1)
hold on
fsurf(conFunc,[0,1525,0,925], 'edgecolor','none') % plot the conFunc
plot3(x_boundary,y_boundary1,z_boundary,'m') % add the boundary line
plot3(x_boundary,y_boundary2,z_boundary,'m')

rectangle('Position',[0,425,1525,100],'LineStyle','--') % draw a rectangle

axis equal % normalize the axis
view(2) % set it to be a 2d/overhead view

% clean up the axis
xticks([0,1500])
yticks([0,1000])
xlim([0,1525])
ylim([0,1000])
xlabel('X')
ylabel('Y')
set(gca,'FontSize',16)

% second panel, a zoomed in version of the first
subplot(2,2,2)
hold on
fsurf(conFunc,[0,1525,450,500], 'edgecolor','none')
plot3(x_boundary,y_boundary1,z_boundary,'m')
plot3(x_boundary,y_boundary2,z_boundary,'m')
view(2)

xticks([0,1500])
yticks([450,500])
xlim([0,1525])
ylim([425,525])
xlabel('X')
ylabel('Y')
set(gca,'FontSize',16)

% third panel, plot the raw data from comsol
subplot(2,2,3)
hold on;
scatter3(x,y,c,50,c,'.') % scatter as large dots, so it looks like a surf
set(gca, 'color',[0.75 0.75 0.75]) % set the background color to grey
view(3) % 3D/angled view

xticks([0,1500])
yticks([450,500])
zticks([0,1])
xlim([0,1525])
ylim([425,525])
xlabel('X')
ylabel('Y')
zlabel('Concentration')
set(gca,'FontSize',16)

% fourth panel, a 3d view of the first panel, to compliment the 3rd panel
subplot(2,2,4)
fsurf(conFunc,[0,1525,425,525], 'edgecolor','none')
set(gca, 'color', [0.75 0.75 0.75])
zlim([0,1])
zticks([0,1])
xticks([0,1500])
yticks([450,500])
xtickformat
xlim([0,1525])
ylim([425,525])
xlabel('X')
ylabel('Y')
zlabel('Concentration')
set(gca,'FontSize',16)


%% Something completly different - heat charts!

%% some data
successData = [20 20 19; 13 15 4; 18 14 9]'./20 * 100;
tortData = 1./[0.68 0.45 0.24; 0.42 0.23 0.10; 0.42 0.30 0.22]';
STratio = successData./tortData;

% a color map
myMap4 =[255:-(255-120)/100:120;...
    255:-(255-81)/100:81;...
    255:-(255-169)/100:169]'/255; % purple!

% an empty vector, for labels -- I add lables in inkscape
nullV = {'','',''};

%% make the figures
figure
% success heat chart
h1 = heatmap(successData,...
    'Colormap',myMap4,...
    'FontSize',40,...
    'XDisplayLabels',nullV,...
    'YDisplayLabels',nullV,...
    'ColorbarVisible','on');
caxis([0,100]) % set the range of the colormap

% save to svg for post-processing in inkscape
% saveas(h1,['behavior_successHeatChart','.svg'],'svg'); 

figure
% tortuosity heat chart -- done a little differently
h2 = heatmap(tortData);
% we can control all of the properties via the handle (h2) rather than
% feeding them into the initial call
h2.Colormap = myMap4; 
h2.FontSize = 40;
h2.XDisplayLabels = nullV;
h2.YDisplayLabels = nullV;
% h2.ColorbarVisible = ='on'; % it's on by default
caxis([1,10])

% saveas(h2,['behavior_tortuosityHeatChart','.svg'],'svg'); 


figure
% ratio heat chart 
h3 = heatmap(STratio);
h3.Colormap = myMap4; 
h3.FontSize = 40;
h3.XDisplayLabels = nullV;
h3.YDisplayLabels = nullV;
caxis([0,70])

% lets make the segments of the heatmap square (taken from 
% https://www.mathworks.com/matlabcentral/answers/
% 481666-heatmap-chart-depict-squares-rather-than-rectangles ):

% Temporarily change axis units 
originalUnits = h3.Units;  % save original units (probaly normalized)
h3.Units = 'centimeters';  % any unit that will result in squares
% Get number of rows & columns
sz = size(h3.ColorData); 
% Change axis size & position;
originalPos = h3.Position; 
% make axes square (not the table cells, just the axes)
h3.Position(3:4) = min(h3.Position(3:4))*[1,1]; 
if sz(1)>sz(2)
    % make the axis size more narrow and re-center
    h3.Position(3) = h3.Position(3)*(sz(2)/sz(1)); 
    h3.Position(1) = (originalPos(1)+originalPos(3)/2)-(h3.Position(3)/2);
else
    % make the axis size shorter and re-center
    h3.Position(4) = h3.Position(4)*(sz(1)/sz(2));
    h3.Position(2) = (originalPos(2)+originalPos(4)/2)-(h3.Position(4)/2);
end
% Return axis to original units
h3.Units = originalUnits; 


% saveas(h3,['behavior_ratioHeatChart','.svg'],'svg'); 

%% a third example, plotting a track!

% go for a random walk
n=100000;
b = 10;
track = zeros(n,2); % preallocate the vector

x = 50;
y = 500;

running = true;

i=0;
while running
    i=i+1;
    
    theta = randn/2  * pi; % randomly pick an angle ~(-pi/2,pi/2)
    r = abs(randn)*10;
    
    % take a step of size r, in direction theta
    x = x + r*cos(theta);
    y = y + r*sin(theta);
    
    % keep the agent within the bounds of the arena
    if y>1000
        y = 1000;
    elseif y<0
        y = 0;
    end
    
    if x<0
        x = 0;
    elseif x>1000 || i>n % check if left arena or more than n steps
        running = false;
    end   
    
    track(i,:) = [x,y];
    
end

track(i:end,:) = []; % remove the unused portion of the vector

%% plot the track

figure
hold on;

% draw a time-averaged plume boudary
patch([0,1000,1000,0],[575,505,495,425],[0.75,0.75,0.75]) 

% plot the data, k=black, make the line a little thicker than standard
plot(track(:,1),track(:,2),'k','LineWidth',2)

% matlab likes to scale the axes to the data...which can be very misleading
% so let's set our own axis limits, and normalize. Also, for this, we don't
% need proper axis labels, so remove them.
xlim([0,1000]);
ylim([0,1000]);
axis normal
set(gca,'XColor', 'none','YColor','none') % gca = get current axes

% add some annotations, this might need tweaking depending on the random
% walk generated.

% add a scale bar
plot([100,100,200],[200,100,100],'k','LineWidth',3) % just a line/3 points
text(85,60,'10cm','FontSize',24) % text denoting what it is

% add an arrow
ar = annotation('textarrow');
ar.X = [.55,.45]; % units are relative to the corner of the window
ar.Y = [.3,.3];
ar.LineWidth = 3;
ar.String = 'Wind';
ar.FontSize = 24;

