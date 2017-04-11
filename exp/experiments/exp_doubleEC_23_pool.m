exp_id = 'exp_doubleEC_23_pool';
exp_description = 'Surrogate CMA-ES, fixed DTS 0.05 (merged code) with sd2, 2-10D, DTIterations={1}, PreSampleSize=0.75, criterion={sd2,expectedRank,fvalues}, 2pop';

% BBOB/COCO framework settings

bbobParams = { ...
  'dimensions',         { 2, 5 }, ...
  'functions',          num2cell(1:24), ...      % all functions: num2cell(1:24)
  'opt_function',       { @opt_s_cmaes }, ...
  'instances',          { [1:5, 41:50] }, ...    % default is [1:5, 41:50]
  'maxfunevals',        { '250 * dim' }, ...
  'resume',             { true }, ...
};

% Surrogate manager parameters

surrogateParams = { ...
  'evoControl',         { 'doubletrained' }, ...    % 'none', 'individual', 'generation', 'restricted'
  'observers',          { {'DTScreenStatistics', 'DTFileStatistics'} },... % logging observers
  'modelType',          { 'modelPool' }, ...               % 'gp', 'rf', 'bbob'
  'updaterType',        { 'rankDiff' }, ...         % OrigRatioUpdater
  'evoControlMaxDoubleTrainIterations', { 1 }, ...
  'evoControlPreSampleSize',       { 0.75 }, ...       % {0.25, 0.5, 0.75}, will be multip. by lambda
  'evoControlOrigPointsRoundFcn',  { 'ceil' }, ...  % 'ceil', 'getProbNumber'
  'evoControlIndividualExtension', { [] }, ...      % will be multip. by lambda
  'evoControlBestFromExtension',   { [] }, ...      % ratio of expanded popul.
  'evoControlTrainRange',          { 10 }, ...      % will be multip. by sigma
  'evoControlTrainNArchivePoints', { '15*dim' },... % will be myeval()'ed, 'nRequired', 'nEvaluated', 'lambda', 'dim' can be used
  'evoControlSampleRange',         { 1 }, ...       % will be multip. by sigma
  'evoControlOrigGenerations',     { [] }, ...
  'evoControlModelGenerations',    { [] }, ...
  'evoControlValidatePoints',      { [] }, ...
  'evoControlRestrictedParam',     { 0.05 }, ...
};

% Model parameters

modelParams = { ...
    'retrainPeriod',      { 1 }, ...
    'bestModelSelection', { 'rdeAll' }, ...
    'historyLength',      { 6 }, ...
    'predictionType',     { 'sd2' }, ...
    'useShift',           { false }, ...
    'normalizeY',         { true }, ...
    'parameterSets', { struct( ...
        'trainsetType',       { 'nearestToPopulation', 'allPoints', 'nearest' }, ...
        'trainRange',         { 0.999, 0.999, 0.999 }, ...
        'trainsetSizeMax',    { '20*dim', '20*dim', '15*dim'  }, ...
        'trainAlgorithm',     { 'fmincon', 'fmincon', 'fmincon' }, ...
        'covFcn',             { '{@covMaterniso, 5}', ...
                                '{@covMaterniso, 3}', ...
                                '{@covSEiso}', }, ...
        'hyp',                { struct('lik', log(0.01), 'cov', log([0.5; 2])), ...
                                ...%struct('lik', log(0.01), 'cov', 'log([0.5*ones(obj.dim,1); 2])'),...
                                struct('lik', log(0.01), 'cov', log([0.5; 2])),...
                                struct('lik', log(0.01), 'cov', log([0.5; 2]))}, ...
        'nBestPoints',        { 0, 0, 0 }, ...
        'minLeaf',            { 2, 2, 2 }, ...
        'inputFraction',      { 1, 1, 1 }, ...
        'meanFcn',            {'meanConst', 'meanConst', 'meanConst'}...
    ) },...
    };



% CMA-ES parameters

cmaesParams = { ...
  'PopSize',            { '(8+floor(6*log(N)))' }, ...        %, '(8 + floor(6*log(N)))'};
  'Restarts',           { 50 }, ...
  'DispModulo',         { 0 }, ...
};

logDir = '/storage/plzen1/home/juranja3/public';
