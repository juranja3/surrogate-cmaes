modelOptions.useShift        = false;
modelOptions.predictionType  = 'sd2';
modelOptions.normalizeY      = true;
modelOptions.modelType = 'modelPool';
opts.modelType = 'modelPool';

modelOptions.parameterSets = {struct('covFcn', {'{@covSEard}', '{@covSEiso}', '{@covSEard}', '{@covMaterniso, 3}', '{@covMaterniso, 3}', '{@covMaterniso, 5}', '{@covMaterniso, 5}', '{@covMaterniso, 5}', '{@covMaterniso, 3}', '{@covMaterniso, 3}', '{@covMaterniso, 3}', '{@covSEard}'}, 'trainsetType', {'clustering', 'clustering', 'clustering', 'nearest', 'nearest', 'nearest', 'allPoints', 'allPoints', 'clustering', 'clustering', 'clustering', 'nearestToPopulation'}, 'trainRange', {1, 1, 0.999, 1, 1, 0.999, 1, 1, 1, 0.999, 0.999, 1}, 'trainsetSizeMax', {'20*dim', '5*dim', '5*dim', '5*dim', '20*dim', '15*dim', '5*dim', '20*dim', '10*dim', '10*dim', '5*dim', '15*dim'}, 'meanFcn', {'meanConst', 'meanLinear', 'meanLinear', 'meanLinear', 'meanLinear', 'meanConst', 'meanLinear', 'meanLinear', 'meanConst', 'meanConst', 'meanLinear', 'meanLinear'}, 'trainAlgorithm', {'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon'}, 'hyp', {struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147])}, 'nBestPoints', {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})};

% Full factorial design of the following parameters                          
modelOptions.bestModelSelection = { 'rdeAll', 'rdeOrig' };
modelOptions.historyLength      = { 3, 5, 7 };
modelOptions.minTrainedModelsPercentilForModelChoice = {0.25, 0.5};
modelOptions.maxGenerationShiftForModelChoice = {0, 2};
                          