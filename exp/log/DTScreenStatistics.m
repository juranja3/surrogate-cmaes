classdef DTScreenStatistics < Observer
%SCREENSTATISTICS -- print statistics from DoubleTrainEC on screen without adaptivity
  properties
    verbosity
  end

  methods
    function obj = DTScreenStatistics(params)
      obj@Observer();
      verbosity = defopts(params, 'verbose', 5);
    end

    function notify(obj, ec, varargin)
      % get the interesting data and process them
      if (mod(ec.cmaesState.countiter, 10) == 1)
      %           #####  iter /evals(or:p,b) | Dopt |rmseR | rnkR | rnk2 |rnkVal * | Mo nD nDiR |sigm^2| aErr |smooEr| orRat| aGain|
        fprintf('####### iter /evals(or:p,b) | D_fopt. | rmseRee | rnkR | rnk2 | .rankErrValid. | M  nData | sigma^2. | aErr |smooEr| orRat| aGain|\n');
      end
      model = '.';
      nTrainData = 0;
      if (~isempty(ec.model) && ec.model.isTrained() ...
          && ec.model.trainGeneration == ec.cmaesState.countiter)
        model = '+'; nTrainData = ec.model.getTrainsetSize(); end
      if (~isempty(ec.retrainedModel) && ec.retrainedModel.isTrained() ...
          && ec.retrainedModel.trainGeneration == ec.cmaesState.countiter)
        model = '#'; nTrainData = ec.retrainedModel.getTrainsetSize(); end
      outputValues1 = [...
          ec.cmaesState.countiter, ec.counteval, sum(ec.pop.origEvaled), ...
          ec.nPresampledPoints, ec.usedBestPoints, ...
          ec.stats.fmin - ec.surrogateOpts.fopt, ...
          ec.stats.rmseReeval, ...
          ec.stats.rankErrReeval, ...
          ec.stats.rankErr2Models, ...
          ec.stats.rankErrValid ];
      outputValues2 = [...
          nTrainData, ec.stats.nDataInRange, ...
          ec.cmaesState.sigma^2 ]; % , ...
          % ec.stats.adaptErr, ...
          % ec.stats.adaptSmoothedErr, ...
          % ec.stats.lastUsedOrigRatio, ...
          % ec.stats.adaptGain ];
      outputValues1(isnan(outputValues1)) = 0.0;
      outputValues2(isnan(outputValues2)) = 0.0;
      %         #####  iter /evals(or,p) | Dopt |rmseR | rnkR | rnk2 |rnkVal * | Mo nD nDiR |sigm^2| aErr |smooEr| orRat| aGain|
      fprintf('=[DTS]= %4d /%5d(%2d:%1d,%1d) | %.1e | %.1e | %.2f | %.2f | %.2f %s | %s %2d/%3d | %.2e |\n', ... %  %.2f | %.2f | %.2f | %.2f |\n', ...
          outputValues1(:), decorateKendall(1-2*ec.stats.rankErrValid), model, outputValues2(:) ...
          );
      
      if isa(ec.model, 'ModelPool')
          if (mod(ec.cmaesState.countiter, 10) == 0)
              fprintf('Best Models History:');
              for i=1:ec.model.modelsCount
                fprintf(' %d ',ec.model.bestModelsHistory(i));
              end
              fprintf('\n');
          end
      end
    end
  end
end
