exp_id = 'exp_doubleEC_MP_01';
exp_description = 'MP, 2D, Copy of DTC_23 - Surrogate CMA-ES, fixed DTS 0.05 (merged code) with sd2, 2-10D, DTIterations={1}, PreSampleSize=0.75, criterion={sd2}, 2pop, noisy functions';

% BBOB/COCO framework settings

bbobParams = { ...
  'dimensions',         { 2 }, ...
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
    'historyLength',      { 7 }, ...
    'minTrainedModelsPercentileForModelChoice', {0.25},...
    'maxGenerationShiftForModelChoice', {2},...
    'predictionType',     { 'sd2' }, ...
    'useShift',           { false }, ...
    'normalizeY',         { true }, ...
    'parameterSets', {struct(...
      'covFcn',{'{@covSEiso}', '{@covSEard}', '{@covSEard}', '{@covSEard}', '{@covSEard}', '{@covSEiso}', '{@covMaterniso, 3}', '{@covMaterniso, 5}', '{@covMaterniso, 3}', '{@covMaterniso, 5}', '{@covMaterniso, 3}'},...
      'trainsetType', {'nearest', 'clustering', 'clustering', 'allPoints', 'clustering', 'allPoints', 'nearest', 'allPoints', 'allPoints', 'clustering', 'clustering'},...
      'trainRange', {1, 1, 1, 0.999, 1, 0.999, 1, 1, 0.999, 1, 1},...
      'trainsetSizeMax', {'20*dim', '5*dim', '10*dim', '5*dim', '5*dim', '5*dim', '20*dim', '5*dim', '20*dim', '10*dim', '15*dim'},'meanFcn',{'meanConst', 'meanConst', 'meanConst', 'meanConst', 'meanLinear', 'meanLinear', 'meanConst', 'meanConst', 'meanConst', 'meanLinear', 'meanLinear'},...
      'trainAlgorithm',{'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon', 'fmincon'},...
      'hyp' ,{struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147]), struct('lik', -4.605170, 'cov', [-0.693147; 0.693147])})},...
    };



% CMA-ES parameters

cmaesParams = { ...
  'PopSize',            { '(8+floor(6*log(N)))' }, ...        %, '(8 + floor(6*log(N)))'};
  'Restarts',           { 50 }, ...
  'DispModulo',         { 0 }, ...
};

logDir = '/storage/plzen1/home/juranja3/public';
