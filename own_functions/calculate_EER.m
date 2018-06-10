function EER = calculate_EER(matches_array)
% Biometric security system algorithm used to predetermine the threshold 
% values for its false acceptance rate and its false rejection rate. 
% When the rates are equal, the common value is referred to as the 
% equal error rate. The value indicates that the proportion of false 
% acceptances is equal to the proportion of false rejections. 
% The lower this value, the higher the accuracy of the biometric system.

% Parameters:
%  matches_array     -    n x n array containing match percentages

% Returns:
%  EER               -    Equal Error Rate

[data_count, ~] = size(matches_array);
FRR = [];
FAR = [];
Fadd = [];
max_threshold = 100;
pMatches = 0;
ppMatches = 0;
ii = 0;
match_candidates_total = (floor(data_count/4) * 16);
non_match_canditates_total = floor(data_count)^2 - match_candidates_total;


for threshold = 0 : 0.01 : max_threshold
    for n = 1 : 4 : (floor(data_count) - 3) 
        % match_canditates -> combinations that should match.
        match_candidates = matches_array(n:n+3,n:n+3);             
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
    pMatches = 0;
    
    % False Acceptance Rate
    FA = (non_match_canditates_total - ppMatches)/non_match_canditates_total * 100;
    FAR(ii,:) = [threshold, FA];
    ppMatches = 0;
    
    Fadd(ii,:) = [threshold, FR + FA];
end

% caculating minimum of added values. This is done instead of the
% intersection between the curves, because we dont have perfect parabolas.
[~, minind] = min(Fadd);
minval = Fadd(minind(2),:);

EER = minval(2)/2;

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



