modelOptions.useShift        = false;
modelOptions.predictionType  = 'sd2';
modelOptions.normalizeY      = true;
modelOptions.modelType = 'modelPool';
opts.modelType = 'modelPool';

modelOptions.parameterSets = {struct('covFcn',{'{@covSEiso}', '{@covSEard}', '{@covSEard}', '{@covSEard}', '{@covSEard}', '{@covSEiso}', '{@covMaterniso, 3}', '{@covMaterniso, 5}', '{@covMaterniso, 3}', '{@covMaterniso, 5}', '{@covMaterniso, 3}'},'trainsetType', {'nearest', 'clustering', 'clustering', 'allPoints', 'clustering', 'allPoints', 'nearest', 'allPoints', 'allPoints', 'clustering', 'clustering'},'trainRange', {1, 1, 1, 0.999, 1, 0.999, 1, 1, 0.999, 1, 1},'trainsetSizeMax', {'20*dim', '5*dim', '10*dim', '5*dim', '5*dim', '5*dim', '20*dim', '5*dim', '20*dim', '10*dim', '15*dim'},'meanFcn',{'meanConst', 'meanConst', 'meanConst', 'meanConst', 'meanLinear', 'meanLinear', 'meanConst', 'meanConst', 'meanConst', 'meanLinear', 'meanLinear'},'trainAlgorithm',{'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon'},'hyp' ,{struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147])},'nBestPoints',{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})};

% Full factorial design of the following parameters                          
modelOptions.bestModelSelection = { 'rdeAll', 'rdeOrig' };
modelOptions.historyLength      = { 3, 5, 7 };
modelOptions.minTrainedModelsPercentilForModelChoice = {0.25, 0.5};
modelOptions.maxGenerationShiftForModelChoice = {0, 2};
                          