% plot sampling of profile likelihood

function arPlotPLE(jk)

global ar

if(~exist('jk','var') || isempty(jk))
    jk = find(ar.ple.run==1);
end
if(length(jk)>1)
    for j=1:length(jk)
        arPlotPLE(jk(j));
    end
    return;
end

figure(jk)
clf;

% constants
overplot = 0.1;

if(ar.config.fiterrors == 1)
    chi2s = 2*ar.ndata*log(sqrt(2*pi)) + ar.ple.chi2s{jk};
    if(isfield(ar,'scan'))
        chi2s_scan = 2*ar.ndata*log(sqrt(2*pi)) + ar.scan.chi2s{jk};
    else
        chi2s_scan = [];
    end
    chi2curr = 2*ar.ndata*log(sqrt(2*pi)) + ar.chi2fit;
    ylabeltmp = '-2*log(L)';
else
    chi2s = ar.ple.chi2s{jk};
    if(isfield(ar,'scan'))
        chi2s_scan = ar.scan.chi2s{jk};
    else
        chi2s_scan = [];
    end
    chi2curr = ar.chi2fit;
    ylabeltmp = '\chi^2';
end
ps = ar.ple.ps{jk};

dchi2 = chi2inv(1-ar.ple.alpha, ar.ple.ndof);

subplot(2,1,1);

plot(ps(:,jk), chi2s, 'k');
hold on
if(~isempty(chi2s_scan))
    plot(ps(:,jk), chi2s_scan, 'k--');
end
plot(ar.p(jk), chi2curr, '*k');

qerrors = ar.ple.errors{jk} == 0;
plot(ps(qerrors,jk), chi2s(qerrors), 'ro');
qerrors = ar.ple.errors{jk} < 0;
plot(ps(qerrors,jk), chi2s(qerrors), 'rs');
qerrors = ar.ple.errors{jk} > 1;
plot(ps(qerrors,jk), chi2s(qerrors), 'x', 'Color', [.5 .5 .5]);

% thresholds
plot(xlim, [0 0]+chi2curr+dchi2, 'r--')
text(mean(xlim), chi2curr+dchi2, sprintf('%2i%%', (1-ar.ple.alpha)*100), 'Color', 'r', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')

hold off
arSubplotStyle(gca)
spacedAxisLimits(gca, overplot)
ylabel(ylabeltmp);

if(sum(~isnan(chi2s))>0)
    % ylimtmp = [min(chi2s) chi2curr+dchi2*1.2];
    ylimtmp = [min(chi2s) max([max(chi2s)+0.1 chi2curr+dchi2])];
    % ylimtmp = [min([chi2s chi2s_scan]) max([chi2s chi2s_scan])];
    ylim([ylimtmp(1)-diff(ylimtmp)*0.1 ylimtmp(2)+diff(ylimtmp)*0.1]);
end

xtmp = xlim;

subplot(2,1,2);
notjk = 1:length(ar.p);
notjk = notjk~=jk & ar.qFit==1;

stds = std(ar.ple.ps{jk}(~isnan(ar.ple.chi2s{jk}),notjk));
[~, istds] = sort(stds, 2, 'descend');

pstmp = ps(:,notjk) - (ones(length(chi2s),1)*ar.ple.pStart(notjk));
nplot = 7;

if(length(istds)>nplot)
    plot(ps(:,jk), pstmp(:,istds(1:nplot)));
else
    plot(ps(:,jk), pstmp);
end
hold on
if(length(istds)>nplot)
    plot(ps(:,jk), pstmp(:,istds((nplot+1):end)), 'Color', [.7 .7 .7]);
end
plot([ar.ple.pStart(jk) ar.ple.pStart(jk)], ylim, 'k--')
hold off

spacedAxisLimits(gca, overplot)
xlim(xtmp);
ylabel('parameter changes');
xlabel(arNameTrafo(ar.pLabel{jk}));
ptmp = ar.pLabel(notjk);
ptmp = strrep(ptmp,'_','\_');
if(length(istds)>nplot)
    legend(ptmp{istds(1:nplot)})
else
    legend(ptmp)
end


function spacedAxisLimits(g, overplot)
[xmin xmax ymin ymax] = axisLimits(g);
xrange = xmax - xmin;
if(xrange == 0)
	xrange = 1;
end
yrange = ymax - ymin;
if(yrange == 0)
	yrange = 1;
end
xlim(g, [xmin-(xrange*overplot) xmax+(xrange*overplot)]);
ylim(g, [ymin-(yrange*overplot) ymax+(yrange*overplot)]);



function [xmin xmax ymin ymax] = axisLimits(g)
p = get(g,'Children');
xmin = nan;
xmax = nan;
ymin = nan;
ymax = nan;
for j = 1:length(p)
	if(~strcmp(get(p(j), 'Type'), 'text'))
		xmin = min([xmin toRowVector(get(p(j), 'XData'))]);
		xmax = max([xmax toRowVector(get(p(j), 'XData'))]);
		%         get(p(j), 'UData')
		%         get(p(j), 'LData')
		%         set(p(j), 'LData', get(p(j), 'LData')*2)
		if(strcmp(get(p(j), 'Type'),'hggroup'))
			ymin = min([ymin toRowVector(get(p(j), 'YData'))-toRowVector(get(p(j), 'LData'))]);
			ymax = max([ymax toRowVector(get(p(j), 'YData'))+toRowVector(get(p(j), 'UData'))]);
		else
			ymin = min([ymin toRowVector(get(p(j), 'YData'))]);
			ymax = max([ymax toRowVector(get(p(j), 'YData'))]);
		end
	end
end



function b = toRowVector(a)
b = a(:)';

