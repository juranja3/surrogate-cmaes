classdef ModelPool < Model
    properties    % derived from abstract class "Model"
        dim                   % dimension of the input space X (determined from x_mean)
        trainGeneration = -1; % # of the generation when the model was built
        trainMean             % mean of the generation when the model was trained
        trainSigma            % sigma of the generation when the model was trained
        trainBD               % BD of the generation when the model was trained
        dataset               % .X and .y
        useShift = false;
        shiftMean             % vector of the shift in the X-space
        shiftY = 0;           % shift in the f-space
        predictionType        % type of prediction (f-values, PoI, EI)
        transformCoordinates  % transform X-space
        stateVariables        % variables needed for sampling new points as CMA-ES do
        
        % ModelPool specific properties
        archive
        modelOptions
        models
        modelsCount
        bestModel
        bestModelsHistory
        retrainPeriod
        lastTrainingGeneration = 0;
        historyLength
        xMean
    end
    
    methods (Access = public)
        function obj = ModelPool(modelOptions, xMean, archive)
            obj.modelOptions = modelOptions;
            obj.xMean = xMean;
            obj.archive = archive;
            obj.modelsCount = size(modelOptions.parameterSets,2);
            assert(obj.modelsCount ~= 0, 'ModelPool(): No model provided!');
            obj.models = GpModel.empty;
            obj.bestModelsHistory = zeros(1,obj.modelsCount);
            %create the models
            for i=1:obj.modelsCount
                options = modelOptions.parameterSets(i);
                obj.models(end+1) = ModelFactory.createModel('gp',options,xMean);
            end
            obj.bestModel=0;
            
            obj.historyLength = modelOptions.historyLength;
            obj.retrainPeriod = modelOptions.retrainPeriod;
            obj.predictionType = modelOptions.predictionType;
        end
        
        function nData = getNTrainData(obj)
            nData = 0;
            %Training of models is handled inside this class, so this
            %method is no longer required
        end
        
        function obj = trainModel(obj, X, y, xMean, generation)
            
            obj.trainMean = xMean;
            obj.dataset.X = X;
            obj.dataset.y = y;
            obj.trainGeneration = generation;
            
            %nechat poslat data z archivu
            %natrenovat
            for i=1:obj.modelsCount
                obj.models(i) = obj.models(i).trainModel(X, y, xMean, generation);
            end
            %ulozit do modelpoolu
            obj.chooseBestModel();
        end
        
        function obj = train(obj, ~, ~, stateVariables, sampleOpts)
            if (size(obj.archive.gens,1)==0)
                warning('ModelPool.train(): Empty set retrieved form archive.');
            else
                for i=1:obj.modelsCount
                    generations=obj.lastTrainingGeneration+1:obj.archive.gens(end);
                    trainSet = obj.archive.getDataFromGenerations(generations);
                    if (size(trainSet,2)==0)
                        
                    end
                    circshift(obj.models(i),1,1);
                    if (size(obj.models(i))<obj.historyLength)
                        obj.models(i,end+1) = obj.models(i,1);
                    end
                    obj.models(i,1) = obj.models(i,2)...
                        .train(trainSet, stateVariables, sampleOpts);
                end
                obj.bestModel = chooseBestModel();
                obj.lastTrainingGeneration = obj.archive.gens(end);
            end
        end
        
        function [y, sd2] = modelPredict(obj, X)
            [y,sd2] = obj.models(obj.bestModel,1).modelPredict(X);
        end
        
    end
    
    methods (Access = public)
        function bestModelIndex = chooseBestModel(obj)
            bestModelIndex = 1;
            likelihood = obj.models(1,1).trainLikelihood;
            for i=2:obj.modelsCount
                if (obj.models(i).trainLikelihood < likelihood)
                    likelihood = obj.models(i,1).trainLikelihood;
                    bestModelIndex = i;
                end
            end
            obj.bestModelsHistory(bestModelIndex) = obj.bestModelsHistory(bestModelIndex)+1;
        end
    end
    
    
end