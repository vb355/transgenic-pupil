% Use this script to analyze group data. Create a folder, in this case
% named group data. Within that folder create two other folders, in this
% case named intensity_mW_1 for 1 mW intensity and intensity_mW_1_8 for 1.8
% mW. Within those folders create two more folders named transgenic_flox
% and transgenic_null. Copy and paste avgsem.mat data for the corresponding
% mice into each folder. After pasting rename files so they are not
% overwritten using a naming scheme. 
clear
folder = uigetdir;
save_min = str2num(cell2mat(inputdlg('Would you like to save the minimum value file? Press 1 for yes 2 for no')));
late_compare_point = str2num(cell2mat(inputdlg('Please enter a late point to compare, or enter 0 to skip')));
cd(folder);
filePattern = fullfile(folder, '*.mat');
matfiles = dir(filePattern);
count = length(matfiles);
keepercol = 1;
for f = 1:count;
    B = matfiles(f, 1).name;
    currkeeper = load(B);
    name = char(fieldnames(currkeeper));
    holdercells(1, f) = {currkeeper.(name)};
end

for subs = 1:size(holdercells, 2);
    for frames = 1:size(holdercells{1, subs}, 1);
        result(frames, subs) = holdercells{1, subs}(frames, 2);
    end
end

result(result == 0) = NaN;


grand_avg_sem(:,1) = colon(1, length(result)).';
grand_avg_sem(:, 2) = nanmean(result, 2);
nanfinder = isnan(result);
nantrials = size(result, 2) - sum(nanfinder, 2);
grand_avg_sem(:, 3) = nanstd(result, 0, 2) ./ sqrt(nantrials);
figure
frame = grand_avg_sem(1:390, 1);
tracemean = grand_avg_sem(1:390, 2);
tracesem = grand_avg_sem(1:390, 3);
shadedErrorBar(frame, tracemean, tracesem, 'b', 0);
set(gca,'TickDir','out')
set(gca, 'box', 'off')
axis([0 400 40 120])

%compare at min point of average data
[trace_compare_point(1, 1), trace_compare_point(1, 2)] = min(grand_avg_sem(1:390, 2));



for min_finder = 1:size(result, 2);
    [mins(min_finder, 1), mins(min_finder, 2)] = min(result(1:390, min_finder));
    grand_avg_min(min_finder, 1) = result(trace_compare_point(1, 2), min_finder);
    if late_compare_point > 0;
        late_point(min_finder, 1) = result(late_compare_point, min_finder);
    else
    end
end

if save_min == 1;
    save('mins.mat', 'mins')
else
end

% derivative calculations

for derv_calc = 1:size(result, 2);
    derv_hold(:, derv_calc) = diff(result(:, derv_calc));
end

derv_avg_sem(:, 1) = colon(1, 390);
derv_avg_sem(:, 2) = nanmean(derv_hold(1:390, :), 2);
derv_avg_sem(:, 3) = std(derv_hold(1:390, :), 0, 2) ./ sqrt(size(derv_hold, 2));

%compare at min point of average data
[derv_compare_point(1, 1), derv_compare_point(1, 2)] = min(derv_avg_sem(1:390, 2));

figure

derv_frame = derv_avg_sem(:, 1);
derv_tracemean = derv_avg_sem(:, 2);
derv_tracesem = derv_avg_sem(:, 3);
shadedErrorBar(derv_frame, derv_tracemean, derv_tracesem, 'b', 0);
set(gca,'TickDir','out')
set(gca, 'box', 'off')
axis([0 400 -2.5 1])

for derv_min_finder = 1:size(derv_hold, 2);
[derv_mins(derv_min_finder, 1), derv_mins(derv_min_finder, 2)] = min(derv_hold(1:390, derv_min_finder));
derv_avg_min(derv_min_finder, 1) = derv_hold(derv_compare_point(1, 2), derv_min_finder);
end

if save_min == 1;
    save('derv_mins.mat', 'derv_mins')
    save('grand_avg_min.mat', 'grand_avg_min')
    save('derv_avg_min.mat', 'derv_avg_min')
    if late_compare_point ~= 0;
        save('late_point.mat' , 'late_point')
    else
    end
else
end