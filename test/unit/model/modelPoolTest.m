function tests = modelPoolTest
tests = functiontests(localfunctions);
end

function testConstructor(testCase)

s = struct ( ...
  'retrainPeriod', { 1 }, ...
  'bestModelSelection', {'likelihood'}, ...
  'historyLength', {4}, ...
  'predictionType', { 'sd2' }, ...
  'useShift',           { false }, ...
  'normalizeY',         { true }, ...
  'parameterSets', { struct( ...
  'trainsetType',       { 'allpoints', 'parameters' }, ...
  'trainRange',         { 0.99, 0.999}, ...
  'trainsetSizeMax',    { 200, 20 }, ...
  'predictionType',     { 'sd2', 'sd2' }, ...
  'trainAlgorithm',     { 'fmincon', 'fmincon' }, ...
  'covFcn',             { '{@covMaterniso, 5}', '{@covMaterniso, 3}' }, ...
  'hyp',                { struct('lik', log(0.01), 'cov', log([0.5; 2])), struct('lik', log(0.01), 'cov', log([0.5; 2])) }, ...
  'nBestPoints',        { 0, 0 }, ...
  'minLeaf',            { 2, 2 }, ...
  'inputFraction',      { 1, 1 }, ...
  'normalizeY',         { true, true} ...
  )...
  }...
  );

modelPool = ModelPool(s,[0 0 0 0 0]);
verifyEqual(testCase, size(modelPool.models,1),2);
verifyEqual(testCase, size(modelPool.models,2),5);
verifyEmpty(testCase, modelPool.models{1,2});
verifyNotEmpty(testCase, modelPool.models{1,1});
verifyFalse(testCase, modelPool.isTrained());

end