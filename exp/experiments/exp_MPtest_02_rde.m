modelOptions.useShift        = false;
modelOptions.predictionType  = 'sd2';
modelOptions.normalizeY      = true;
modelOptions.modelType = 'modelPool';
opts.modelType = 'modelPool';

modelOptions.parameterSets = { struct('covFcn',{'{@covSEard}','{@covSEard}','{@covSEard}','{@covSEiso}','{@covSEard}','{@covSEiso}','{@covSEard}','{@covSEard}','{@covSEiso}','{@covSEiso}','{@covSEard}','{@covMaterniso,3}','{@covMaterniso,3}','{@covMaterniso,3}','{@covMaterniso,5}','{@covMaterniso,3}','{@covMaterniso,3}','{@covMaterniso,5}','{@covMaterniso,3}','{@covMaterniso,3}','{@covMaterniso,5}','{@covMaterniso,3}'},'trainsetType',{'nearest','nearest','nearest','nearest','allPoints','allPoints','allPoints','nearest','clustering','allPoints','clustering','nearest','nearest','nearest','nearest','allPoints','allPoints','allPoints','allPoints','clustering','clustering','nearestToPopulation'}, 'trainRange',{1,1,1,1,1,1,1,0.9990,1,0.9990,0.9990,1,1,1,1,1,1,1,1,0.9990,0.9990,1},'trainSetSizeMax',{'5*dim','15*dim','5*dim','20*dim','5*dim','5*dim','10*dim','10*dim','5*dim','20*dim','20*dim','10*dim','15*dim','20*dim','15*dim','5*dim','10*dim','10*dim','15*dim','10*dim','20*dim','5*dim'}, 'meanFcn',{'meanConst','meanConst','meanLinear','meanLinear','meanConst','meanConst','meanConst','meanConst','meanConst','meanConst','meanConst','meanConst','meanConst','meanLinear','meanLinear','meanConst','meanConst','meanConst','meanConst','meanConst','meanConst','meanConst'}, 'trainAlgorithm',{'fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon','fmincon'}) };

% Full factorial design of the following parameters                          
modelOptions.bestModelSelection = { 'rdeAll', 'rdeOrig' };
modelOptions.historyLength      = { 3, 5, 7 };
modelOptions.minTrainedModelsPercentilForModelChoice = {0.25, 0.5};
modelOptions.maxGenerationShiftForModelChoice = {0, 2};
                          