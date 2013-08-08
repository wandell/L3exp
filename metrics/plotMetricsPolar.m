function hpol = plotMetricsPolar(rho,labels,line_style)

% Custom function to plot metrics in a polar form
% This is modified from Matlab's function 'polar', 
%
% rho is distance from origin to plot on each spoke.  1 is the outside
% circle.  Values larger than 1.1 are clipped to 1.1.
%
% labels is cell array containing strings to label each spoke.  Names
% should correspond with the data in rho.
%
% line style is string specifying how to draw data line that connects the
% spokes  (typically this is the color)


%% Check inputs
rho(end+1) = rho(1);    % following code needs ndeltaE at end also
rho(rho>1.1) = 1.1;     % clip large values at 1.1
rho(rho<0) = 0;         % replace negative values with 0

if nargin == 1
    line_style = 'auto';
end


%%
% get hold state
cax = newplot;
next = lower(get(cax,'NextPlot'));
hold_state = ishold;

% get x-axis text color so grid is in same color
tc = get(cax,'xcolor');
ls = get(cax,'gridlinestyle');

% Hold on to current Text defaults, reset them to the
% Axes' font attributes so tick marks use them.
fAngle  = get(cax, 'DefaultTextFontAngle');
fName   = get(cax, 'DefaultTextFontName');
fSize   = get(cax, 'DefaultTextFontSize');
fWeight = get(cax, 'DefaultTextFontWeight');
fUnits  = get(cax, 'DefaultTextUnits');
set(cax, 'DefaultTextFontAngle',  get(cax, 'FontAngle'), ...
    'DefaultTextFontName',   get(cax, 'FontName'), ...
    'DefaultTextFontSize',   get(cax, 'FontSize'), ...
    'DefaultTextFontWeight', get(cax, 'FontWeight'), ...
    'DefaultTextUnits','data')



numofeval=length(rho)-1;
theta = 0:(2*pi)/numofeval:2*pi;    %angles to equally space around circle
    
    
    
% only do grids if hold is off
if ~hold_state

% make a radial grid
    hold on;
    hhh=plot([-1 -1 1 1],[-1 1 1 -1]);
    set(gca,'dataaspectratio',[1 1 1],'plotboxaspectratiomode','auto')
    v = [get(cax,'xlim') get(cax,'ylim')];
    ticks = sum(get(cax,'ytick')>=0);
    delete(hhh);
% check radial limits and ticks
    rmin = 0; rmax = v(4); rticks = max(ticks-1,2);
    if rticks > 5   % see if we can reduce the number
        if rem(rticks,2) == 0
            rticks = rticks/2;
        elseif rem(rticks,3) == 0
            rticks = rticks/3;
        end
    end

% define a circle
    th = 0:pi/50:2*pi;
    xunit = cos(th);
    yunit = sin(th);
% now really force points on x/y axes to lie on them exactly
    inds = 1:(length(th)-1)/4:length(th);
    xunit(inds(2:2:4)) = zeros(2,1);
    yunit(inds(1:2:5)) = zeros(3,1);
% plot background if necessary
    if ~isstr(get(cax,'color')),
       patch('xdata',xunit*rmax,'ydata',yunit*rmax, ...
             'edgecolor',tc,'facecolor',get(gca,'color'),...
             'handlevisibility','off');
    end
    
%% draw radial circles
    radiuslabellocation = 82;   %degrees from horizontal to place radius label

    cosangle = cos(radiuslabellocation*pi/180);
    sinangle = sin(radiuslabellocation*pi/180);
    rinc = (rmax-rmin)/rticks;
    for i=(rmin+rinc):rinc:rmax
        hhh = plot(xunit*i,yunit*i,ls,'color',tc,'linewidth',1,...
                   'handlevisibility','off');
%         text((i+rinc/20)*cosangle,(i+rinc/20)*sinangle, ...
%             ['  ' num2str(i)],'verticalalignment','bottom',...
%             'handlevisibility','off')
    end
    set(hhh,'linestyle','-') % Make outer circle solid

%% plot spokes
    
    % transform data to Cartesian coordinates.    
    cst = cos(theta); snt = sin(theta);
    cs = [-cst; cst];
    sn = [-snt; snt];
    plot(rmax*cs,rmax*sn,ls,'color',tc,'linewidth',1,...
         'handlevisibility','off')

%% label spokes
    rt = 1.1*rmax;
    for i = 1:(length(theta)-1)
        label = labels{i};
        text(rt*cst(i),rt*snt(i),label,...
                 'horizontalalignment','center',...
                 'handlevisibility','off');        
    end

% set view to 2-D
    view(2);
% set axis limits
    axis(rmax*[-1 1 -1.15 1.15]);
end

% Reset defaults.
set(cax, 'DefaultTextFontAngle', fAngle , ...
    'DefaultTextFontName',   fName , ...
    'DefaultTextFontSize',   fSize, ...
    'DefaultTextFontWeight', fWeight, ...
    'DefaultTextUnits',fUnits );

xx = rho.*cos(theta);
yy = rho.*sin(theta);

% plot data on top of grid
if strcmp(line_style,'auto')
    q = plot(xx,yy, 'LineWidth', 2);
else
    q = plot(xx,yy,line_style, 'LineWidth', 2);
end
if nargout > 0
    hpol = q;
end
if ~hold_state
    set(gca,'dataaspectratio',[1 1 1]), axis off; set(cax,'NextPlot',next);
end
set(get(gca,'xlabel'),'visible','on')
set(get(gca,'ylabel'),'visible','on')
