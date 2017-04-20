modelOptions.useShift        = false;
modelOptions.predictionType  = 'sd2';
modelOptions.normalizeY      = true;
modelOptions.modelType = 'modelPool';
opts.modelType = 'modelPool';

modelOptions.parameterSets = {struct('covFcn', {'{@covSEiso}', '{@covSEard}', '{@covSEiso}', '{@covSEard}', '{@covMaterniso, 5}', '{@covMaterniso, 5}', '{@covMaterniso, 3}', '{@covMaterniso, 3}', '{@covMaterniso, 5}', '{@covMaterniso, 3}', '{@covMaterniso, 3}', '{@covSEard}', '{@covMaterniso, 3}'},'trainsetType', {'nearest', 'allPoints', 'clustering', 'clustering', 'nearest', 'nearest', 'allPoints', 'allPoints', 'clustering', 'clustering', 'clustering', 'nearestToPopulation', 'nearestToPopulation'},'trainRange', {1, 1, 0.999, 0.999, 1, 0.999, 1, 1, 1, 0.999, 0.999, 1, 1},'trainsetSizeMax', {'10*dim', '5*dim', '5*dim', '20*dim', '20*dim', '5*dim', '10*dim', '5*dim', '15*dim', '10*dim', '10*dim', '20*dim', '15*dim'},'meanFcn', {'meanLinear', 'meanConst', 'meanConst', 'meanConst', 'meanLinear', 'meanConst', 'meanConst', 'meanLinear', 'meanConst', 'meanConst', 'meanLinear', 'meanLinear', 'meanLinear'},'trainAlgorithm', {'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon'},'hyp', {struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147])})};

% Full factorial design of the following parameters                          
modelOptions.bestModelSelection = { 'mse' };
modelOptions.historyLength      = { 3, 5, 7 };
modelOptions.minTrainedModelsPercentilForModelChoice = {0.25, 0.5};
modelOptions.maxGenerationShiftForModelChoice = {0, 2};
                          