exp_id = 'exp_doubleEC_ada_01';
exp_description = 'Surrogate CMA-ES model using double-trained EC with sd2 criterion and GPs with double population, and adaptive original ratio updates; 5 and 10D -- for testing purposes with extended logging';

% BBOB/COCO framework settings

bbobParams = { ...
  'dimensions',         { 5, 10 }, ...
  'functions',          { 2, 3, 4, 6, 7, 8, 13, 24 }, ...      % all functions: num2cell(1:24)
  'opt_function',       { @opt_s_cmaes }, ...
  'instances',          { [1:5 41:50] }, ...    % default is [1:5, 41:50]
  'maxfunevals',        { '150 * dim' }, ...
  'resume',             { true }, ...
};

% Surrogate manager parameters

surrogateParams = { ...
  'evoControl',         { 'doubletrained' }, ...    % 'none', 'individual', 'generation', 'restricted'
  'observers',          { {'DTScreenStatistics', 'DTFileStatistics'} },... % logging observers
  'modelType',          { 'gp' }, ...               % 'gp', 'rf', 'bbob'
  'updaterType',        { 'rankDiff' }, ...         % OrigRatioUpdater
  'evoControlPreSampleSize', { 0 }, ...             % {0.25, 0.5, 0.75}, will be multip. by lambda
  'evoControlIndividualExtension', { [] }, ...      % will be multip. by lambda
  'evoControlBestFromExtension', { [] }, ...        % ratio of expanded popul.
  'evoControlTrainRange', { 10 }, ...               % will be multip. by sigma
  'evoControlTrainNArchivePoints', { '15*dim' },... % will be myeval()'ed, 'nRequired', 'nEvaluated', 'lambda', 'dim' can be used
  'evoControlSampleRange', { 1 }, ...               % will be multip. by sigma
  'evoControlOrigGenerations', { [] }, ...
  'evoControlModelGenerations', { [] }, ...
  'evoControlValidatePoints', { [] }, ...
  'evoControlRestrictedParam', { 0.05 }, ...
};

% Model parameters

modelParams = { ...
  'useShift',           { false }, ...
  'predictionType',     { 'sd2' }, ...
  'trainAlgorithm',     { 'fmincon' }, ...
  'covFcn',             { '{@covMaterniso, 5}' }, ...
  'hyp',                { struct('lik', log(0.01), 'cov', log([0.5; 2])) }, ...
  'nBestPoints',        { 0 }, ...
  'minLeaf',            { 2 }, ...
  'inputFraction',      { 1 }, ...
  'normalizeY',         { true }, ...
};

% CMA-ES parameters

cmaesParams = { ...
  'PopSize',            { '(8 + floor(6*log(N)))' }, ...        %, '(8 + floor(6*log(N)))'};
  'Restarts',           { 50 }, ...
  'DispModulo',         { 0 }, ...
};

logDir = '/storage/plzen1/home/bajeluk/public';
