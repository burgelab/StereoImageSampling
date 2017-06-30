function plotLRSIimageANDdisparity(LimgCrp,RimgCrp,LdspCrp,RdspCrp,dspRms,ttl)

% function plotLRSIimageANDdisparity(LimgCrp,RimgCrp,LdspCrp,RdspCrp,dspRms,ttl)
%
%   example call:
%
% plots LE & RE image patches, and disparity patches if passed
%
% LimgCrp:  left eye luminance patch
% RimgCrp:  right eye luminance patch
% LdspCrp:  left eye disparity patch
% RdspCrp:  right eye disparity patch
% dspRms:   disparity contrast of patch
% ttl:      custom title

% CHOOSE NUMBER OF SUBPLOTS BASED ON WHETHER DISPARITY PATCHES WILL BE PLOTTED
if ~exist('LdspCrp','var') || isempty(LdspCrp) || ~exist('RdspCrp','var') || isempty(RdspCrp),
     bPLOTdsp = 0; subplotRC = [1,6];
else bPLOTdsp = 1; subplotRC = [2,6];
end
if ~exist('ttl','var') || isempty(ttl), ttl = 'Luminance'; end

% PATCH SIZE (ROW, COL)
PszRC  = size(LimgCrp);
% PATCH SIZE (X, Y)
PszXY  = fliplr(PszRC);
% PIXEL CENTER
PctrXY = floor(PszXY/2 + 1);

% OPEN FIGURE
if     bPLOTdsp == 1
    figure(901); set(gcf,'position',[1249 263 696 543]);
elseif bPLOTdsp == 0
    figure(902); set(gcf,'position',[1249 1 695 245]);
end
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % PLOT LUMINANCE PATCHES %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % LE IMG
    subplot(subplotRC(1),subplotRC(2),[1 2]); cla;
    imagesc(LimgCrp.^.4); colormap(gca,'gray'); hold on;
    plot(PctrXY(1),PctrXY(2),'.','color','y','MarkerSize',2); 
    plot(PctrXY(1),PctrXY(2),'s','color','y','MarkerSize',10); 
    if subplotRC(1)==1, xlabel('LE');end
    set(gca,'xtick',[],'ytick',[]); hold on; axis image;
    % RE IMG
    subplot(subplotRC(1),subplotRC(2),[3 4]); cla;
    imagesc(RimgCrp.^.4); colormap(gca,'gray'); hold on; 
    plot(PctrXY(1),PctrXY(2),'.','color','y','MarkerSize',2); 
    plot(PctrXY(1),PctrXY(2),'s','color','y','MarkerSize',10);
    if subplotRC(1)==1, xlabel('RE');end
    set(gca,'xtick',[],'ytick',[]); axis image;  
    title(ttl); 
    % LE IMG
    subplot(subplotRC(1),subplotRC(2),[5 6]); cla;
    imagesc(LimgCrp.^.4); colormap(gca,'gray'); hold on;
    plot(PctrXY(1),PctrXY(2),'.','color','y','MarkerSize',2);
    plot(PctrXY(1),PctrXY(2),'s','color','y','MarkerSize',10);
    if subplotRC(1)==1, xlabel('LE'); end
    set(gca,'xtick',[],'ytick',[]); axis image;

if bPLOTdsp == 1
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % PLOT DISPARITY PATCHES %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % LE DSP
    subplot(subplotRC(1),subplotRC(2),[7 8]); cla;
    imagesc(LdspCrp); caxis([-10 10]); colormap(gca,cmapBWR); hold on; 
    plot(PctrXY(1),PctrXY(2),'.','color','k','MarkerSize',2); hold on;
    plot(PctrXY(1),PctrXY(2),'s','color','k','MarkerSize',10); 
    xlabel(['LE']); set(gca,'xtick',[],'ytick',[]); axis image;
    % RE DSP
    subplot(subplotRC(1),subplotRC(2),[9 10]); cla;
    imagesc(RdspCrp); caxis([-10 10]); colormap(gca,cmapBWR); hold on; 
    plot(PctrXY(1),PctrXY(2),'.','color','k','MarkerSize',2); 
    plot(PctrXY(1),PctrXY(2),'s','color','k','MarkerSize',10); 
    xlabel(['RE']); set(gca,'xtick',[],'ytick',[]); axis image;  
    title(['Disparity Contrast: ' num2str(dspRms,'%.2f') ' arcmin']); 
    % LE DSP
    subplot(subplotRC(1),subplotRC(2),[11 12]); cla;
    imagesc(LdspCrp); caxis([-10 10]);  colormap(gca,cmapBWR); hold on;
    plot(PctrXY(1),PctrXY(2),'.','color','k','MarkerSize',2);
    plot(PctrXY(1),PctrXY(2),'s','color','k','MarkerSize',10);
    xlabel(['LE']); set(gca,'xtick',[],'ytick',[]); axis image;
    % ADD COLORBAR
    h = colorbar; set(h,'position',[0.9225 0.1284 0.0187 0.3044]);
    
end

