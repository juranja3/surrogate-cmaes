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
        
        
        % GpModel specific fields
        stdY                  % standard deviation of Y in training set, for normalizing output
        options
        hyp
        meanFcn
        covFcn
        likFcn
        infFcn
        nErrors
        trainLikelihood
        
        % ModelPool specific properties
        dimReduction
        modelPoolOptions
        archive
        models
        modelsCount
        bestModel
        bestModelsHistory
        retrainPeriod
        historyLength
        xMean
    end
    
    methods (Access = public)
        function obj = ModelPool(modelOptions, xMean, archive)
            obj.modelPoolOptions = modelOptions;
            obj.xMean = xMean;
            obj.archive = archive;
            obj.modelsCount = size(modelOptions.parameterSets,2);
            assert(obj.modelsCount ~= 0, 'ModelPool(): No model provided!');
            obj.models = GpModel.empty;
            obj.bestModelsHistory = zeros(1,obj.modelsCount);
            obj.dim       = size(xMean, 2);
            obj.shiftMean = zeros(1, obj.dim);
            obj.shiftY    = 0;
            obj.stdY  = 1;
            %create the models
            for i=1:obj.modelsCount
                options = modelOptions.parameterSets(i);
                obj.models(end+1) = ModelFactory.createModel('gp',options,xMean);
            end
            obj.historyLength = modelOptions.historyLength;
            obj.retrainPeriod = modelOptions.retrainPeriod;
            obj.predictionType = modelOptions.predictionType;
            obj.bestModel=1;
            
            obj.options.normalizeY = defopts(modelOptions, 'normalizeY', true);
            
            % general model prediction options
            obj.predictionType = defopts(modelOptions, 'predictionType', 'fValues');
            obj.transformCoordinates = defopts(modelOptions, 'transformCoordinates', true);
            obj.dimReduction = defopts(modelOptions, 'dimReduction', 1);
            
            obj = obj.copyVariablesFromBestModel();
        end
        
        function nData = getNTrainData(obj)
            nData=0;
            for i=1:obj.modelsCount
                nData = max(nData,obj.models(i,1).getNTrainData());
            end
        end
        
        function obj = trainModel(obj, X, y, xMean, generation)
            
            if (mod(generation,obj.retrainPeriod)==0)
                generations=obj.trainGeneration+1:generation;
                [X2,y2]=obj.archive.getDataFromGenerations(generations);
                
                for i=1:obj.modelsCount
                    nTrainData = obj.models(i,1).getNTrainData();
                    %Todo: rework, only 1 model needs to be trained,
                    %models that were not trained in previous trainModel
                    %calls should be trained in next call with more data
                    if (nTrainData>size(X,1))
                        warning('ModelPool.trainModel(): not enough data for model no. %d.',i);
                    else
                        %TODO:choose the data
                        %modelXData = X(1:nTrainData,:);
                        %modelYData = y(1:nTrainData,:);
                        modelXData = X;
                        modelYData = y;
                        circshift(obj.models(i),1,1);
                        if (size(obj.models(i))<obj.historyLength)
                            obj.models(i,end+1) = obj.models(i,1);
                        end
                        obj.models(i,1) = obj.models(i,2)...
                            .trainModel(modelXData, modelYData, xMean, generation);
                    end
                end
                
                obj.trainGeneration = generation;
                obj.bestModel = obj.chooseBestModel();
                obj = obj.copyVariablesFromBestModel();
                obj.dataset.X = obj.models(obj.bestModel,1).dataset.X;
                obj.dataset.y = obj.models(obj.bestModel,1).dataset.y;
                
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
        
        %used to simulate the behavior of the best GpModel
        function obj = copyVariablesFromBestModel(obj)

            obj.stdY = obj.models(obj.bestModel,1).stdY;
            obj.options = obj.models(obj.bestModel,1).options;
            obj.hyp = obj.models(obj.bestModel,1).hyp;
            obj.meanFcn = obj.models(obj.bestModel,1).meanFcn;
            obj.covFcn = obj.models(obj.bestModel,1).covFcn;
            obj.likFcn = obj.models(obj.bestModel,1).likFcn;
            obj.infFcn = obj.models(obj.bestModel,1).infFcn;
            obj.nErrors = obj.models(obj.bestModel,1).nErrors;
            obj.trainLikelihood = obj.models(obj.bestModel,1).trainLikelihood;
            
            obj.shiftY = obj.models(obj.bestModel,1).shiftY;
            obj.trainMean = obj.models(obj.bestModel,1).trainMean;
        end
    end
    
    
end