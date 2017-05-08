exp_id = 'exp_doubleEC_MP_09_noisy';
exp_description = 'MP, 2D, MSE, Copy of DTC_23 - Surrogate CMA-ES, fixed DTS 0.05 (merged code) with sd2, 2-10D, DTIterations={1}, PreSampleSize=0.75, criterion={sd2}, 2pop, noisy functions';

% BBOB/COCO framework settings

bbobParams = { ...
  'dimensions',         { 2 }, ...
  'functions',          num2cell(101:106), ...      % all functions: num2cell(1:24)
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
parameterSets = struct();

parameterSets(1).covFcn = '{@covSEard}';
parameterSets(1).trainsetType = 'nearest';
parameterSets(1).trainRange = 1;
parameterSets(1).trainsetSizeMax = '5*dim';
parameterSets(1).meanFcn = 'meanLinear';
parameterSets(1).trainAlgorithm = 'fmincon';
parameterSets(1).hyp.lik = -4.605170;
parameterSets(1).hyp.cov = [-0.693147; 0.693147];
parameterSets(2).covFcn = '{@covSEiso}';
parameterSets(2).trainsetType = 'allPoints';
parameterSets(2).trainRange = 1;
parameterSets(2).trainsetSizeMax = '5*dim';
parameterSets(2).meanFcn = 'meanLinear';
parameterSets(2).trainAlgorithm = 'fmincon';
parameterSets(2).hyp.lik = -4.605170;
parameterSets(2).hyp.cov = [-0.693147; 0.693147];
parameterSets(3).covFcn = '{@covSEard}';
parameterSets(3).trainsetType = 'clustering';
parameterSets(3).trainRange = 0.999;
parameterSets(3).trainsetSizeMax = '5*dim';
parameterSets(3).meanFcn = 'meanLinear';
parameterSets(3).trainAlgorithm = 'fmincon';
parameterSets(3).hyp.lik = -4.605170;
parameterSets(3).hyp.cov = [-0.693147; 0.693147];
parameterSets(4).covFcn = '{@covMaterniso, 5}';
parameterSets(4).trainsetType = 'allPoints';
parameterSets(4).trainRange = 1;
parameterSets(4).trainsetSizeMax = '5*dim';
parameterSets(4).meanFcn = 'meanConst';
parameterSets(4).trainAlgorithm = 'fmincon';
parameterSets(4).hyp.lik = -4.605170;
parameterSets(4).hyp.cov = [-0.693147; 0.693147];
parameterSets(5).covFcn = '{@covMaterniso, 3}';
parameterSets(5).trainsetType = 'allPoints';
parameterSets(5).trainRange = 1;
parameterSets(5).trainsetSizeMax = '15*dim';
parameterSets(5).meanFcn = 'meanConst';
parameterSets(5).trainAlgorithm = 'fmincon';
parameterSets(5).hyp.lik = -4.605170;
parameterSets(5).hyp.cov = [-0.693147; 0.693147];
parameterSets(6).covFcn = '{@covMaterniso, 5}';
parameterSets(6).trainsetType = 'clustering';
parameterSets(6).trainRange = 1;
parameterSets(6).trainsetSizeMax = '5*dim';
parameterSets(6).meanFcn = 'meanConst';
parameterSets(6).trainAlgorithm = 'fmincon';
parameterSets(6).hyp.lik = -4.605170;
parameterSets(6).hyp.cov = [-0.693147; 0.693147];
parameterSets(7).covFcn = '{@covMaterniso, 3}';
parameterSets(7).trainsetType = 'clustering';
parameterSets(7).trainRange = 0.999;
parameterSets(7).trainsetSizeMax = '10*dim';
parameterSets(7).meanFcn = 'meanLinear';
parameterSets(7).trainAlgorithm = 'fmincon';
parameterSets(7).hyp.lik = -4.605170;
parameterSets(7).hyp.cov = [-0.693147; 0.693147];

modelParams = { ...
    'retrainPeriod',      { 1 }, ...
    'bestModelSelection', { 'mse' }, ...
    'historyLength',      { 3 }, ...
    'minTrainedModelsPercentileForModelChoice', {0.25},...
    'maxGenerationShiftForModelChoice', {0},...
    'predictionType',     { 'sd2' }, ...
    'useShift',           { false }, ...
    'normalizeY',         { true }, ...
    'parameterSets',      { parameterSets }...
    };

% CMA-ES parameters

cmaesParams = { ...
  'PopSize',            { '(8+floor(6*log(N)))' }, ...        %, '(8 + floor(6*log(N)))'};
  'Restarts',           { 50 }, ...
  'DispModulo',         { 0 }, ...
};

logDir = '/storage/plzen1/home/juranja3/public';
