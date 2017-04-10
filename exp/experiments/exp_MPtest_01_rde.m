modelOptions.useShift        = false;
modelOptions.predictionType  = 'sd2';
modelOptions.normalizeY      = true;
modelOptions.modelType = 'modelPool';
opts.modelType = 'modelPool';

modelOptions.parameterSets = { struct('covFcn',{'{@covSEard}','{@covSEard}','{@covSEard}','{@covSEiso}','{@covSEard}','{@covSEiso}','{@covSEard}','{@covSEard}','{@covSEard}','{@covSEiso}','{@covSEiso}','{@covSEard}','{@covSEard}','{@covMaterniso,5}','{@covMaterniso,3}','{@covMaterniso,3}','{@covMaterniso,3}','{@covMaterniso,3}','{@covSEard}','{@covMaterniso,3}','{@covMaterniso,5}'},'trainsetType',{'nearest','nearest','nearest','nearest','nearest','nearest','allPoints','allPoints','allPoints','allPoints','allPoints','clustering','clustering','allPoints','allPoints','allPoints','allPoints','clustering','nearestToPopulation','nearestToPopulation','nearestToPopulation'}, 'trainRange',{1,1,1,1,1,1,1,1,0.9990,0.9990,0.9990,0.9990,0.9990,1,1,1,1,1,1,1,1},'trainSetSizeMax',{'10*dim','20*dim','15*dim','5*dim','10*dim','15*dim','10*dim','5*dim','5*dim','5*dim','10*dim','10*dim','20*dim','5*dim','10*dim','20*dim','15*dim','10*dim','10*dim','20*dim','5*dim'}, 'meanFcn',{'meanConst','meanConst','meanConst','meanLinear','meanLinear','meanLinear','meanConst','meanLinear','meanConst','meanConst','meanLinear','meanConst','meanConst','meanConst','meanConst','meanConst','meanLinear','meanConst','meanConst','meanConst','meanLinear'}, 'trainAlgorithm',{'fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon'}) };

% Full factorial design of the following parameters                          
modelOptions.bestModelSelection = { 'rdeAll', 'rdeOrig' };
modelOptions.historyLength      = { 3, 5, 7 };
modelOptions.minTrainedModelsPercentilForModelChoice = {0.25, 0.5};
modelOptions.maxGenerationShiftForModelChoice = {0, 2};
                          