function [EER, EERthreshold, ROC] = calculate_EERorROC(matches_array,varargin)
% Biometric security system algorithm used to predetermine the threshold 
% values for its false acceptance rate and its false rejection rate. 
% When the rates are equal, the common value is referred to as the 
% equal error rate. The value indicates that the proportion of false 
% acceptances is equal to the proportion of false rejections. 
% The lower this value, the higher the accuracy of the biometric system.
%
% Also calculates the ROC curve, Receiver Operating Characteristic curve,
% indicating the relation between thte true acceptance rate and the false
% acceptance rate. The ROC is calculated as the area above the ROC curve.
%
% Note -- Because our FFR is discrete in most cases, thus not a perfect
% parabola, the EER is calculated as the minimum of the sum of the FAR and
% the FFR, instead of the intersecting points.

% Parameters:
%  matches_array     -    n x n array containing match percentages
%  'showEER'         -    Shows a plot of error rate vs deciscion 
%                         threshold and the Equal Error Rate.
%  'showROC'         -    Shows a plot of the FAR vs the TAR.                         

% Returns:
%  EER               -    Equal Error Rate
%  EERthreshold      -    Corresponding threshold
%  ROC               -    Receiver Operating Characteristic                     


showROCfar_specified = strcmp('showROC', varargin);  
showEER_specified = strcmp('showEER', varargin); 


[data_count, ~] = size(matches_array);
FRR = [];
FAR = [];
TRR = [];
TAR = [];
Fadd = [];
max_threshold = 100;
pMatches = 0;
ppMatches = 0;
ii = 0;
match_candidates_total = (floor(data_count/4) * 16) - data_count;
non_match_canditates_total = floor(data_count)^2 - match_candidates_total - data_count;


for threshold = 0 : 0.01 : max_threshold
    for n = 1 : 4 : (floor(data_count) - 3) 
        % match_canditates -> combinations that should match.
        match_candidates = matches_array(n:n+3,n:n+3);
        
        match_candidates(match_candidates==-1)=[]; 
        %match_candidates = reshape(match_candidates,4,3);
        
        nMatches = length(find(match_candidates > threshold));     % number of matches above threshold
        pMatches = pMatches + nMatches;
        
        % non_match_canditates -> combinations that should not match.
        non_match_candidates1 = matches_array(n:n+3,n+4:floor(data_count));
        non_match_candidates2 = matches_array(n+4:floor(data_count),n:n+3);
        nnMatches1 = length(find(non_match_candidates1 < threshold));     
        nnMatches2 = length(find(non_match_candidates2 < threshold));    
        ppMatches = ppMatches + nnMatches1 + nnMatches2;
    end
    % False Rejection Rate
    FR = (match_candidates_total - pMatches)/match_candidates_total * 100;
    ii = ii + 1;
    FRR(ii,:) = [threshold, FR];
    
    % False Acceptance Rate
    FA = (non_match_canditates_total - ppMatches)/non_match_canditates_total * 100;
    FAR(ii,:) = [threshold, FA];
    
    % True Acceptance Rate
    TA = (pMatches)/match_candidates_total * 100;
    TAR(ii,:) = [threshold, TA];
    
    % True Rejection Rate
    TR = (ppMatches)/non_match_canditates_total * 100;
    TRR(ii,:) = [threshold, TR];
    
    pMatches = 0;
    ppMatches = 0;
    Fadd(ii,:) = [threshold, FR + FA];
end

% caculating minimum of added values. This is done instead of the
% intersection between the curves, because we dont have perfect parabolas.
[~, minind] = min(Fadd);
minval = Fadd(minind(2),:);

% return EER and corresponding threshold
EER = minval(2)/2;
EERthreshold = minval(1);

% calculate ROC
% ROC calculated by getting area above ROC curve.
ROC_curve = [FAR(:,2),TAR(:,2)];
dr = trapz(-ROC_curve(:,1),ROC_curve(:,2));
ROC = (10000 - dr)/10000 * 100;


if ~showEER_specified
   
else
    % plotting figure
    figure;
    plot(FRR(:,1),FRR(:,2))
    hold on;
    plot(FAR(:,1),FAR(:,2))
    hold on;
    y = minval(2)/2;
    line([0,max_threshold],[y,y],'Color',[0 1 0])
    hold on 
    x = minval(1); 
    line([x x],[0 100],'Color',[0 1 0])
    title(strcat('EER: ', num2str(minval(2)/2), '%'))
    xlabel('Decision threshold (%)')
    ylabel('Error rate (%)')
    legend('FRR','FAR','EER')
end


if ~showROCfar_specified
    
else
    % plotting figure
    figure;
    plot(FAR(:,2),TAR(:,2))
    hold on;
    plot(FAR(:,1),100 - TAR(:,1))
    title(strcat('ROC: ', num2str(ROC), '%'))
    xlabel('FAR (%)')
    ylabel('TAR (%)')
    legend('TAR/FAR','')
end



