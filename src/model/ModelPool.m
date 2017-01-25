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
        historyLength
        xMean
        trainLikelihood
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
            obj.dim       = size(xMean, 2);
            obj.shiftMean = zeros(1, obj.dim);
            obj.shiftY    = 0;
            
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
            nData=0;
            for i=1:obj.modelsCount
                nData = max(nData,obj.models(i,1).getNTrainData());
            end
        end
        
        function obj = trainModel(obj, X, y, xMean, generation)
            if (mod(generation,obj.retrainPeriod)==0)
                generations=obj.trainGeneration+1:generation;
                [X2,y2]=obj.archive.getDataFromGenerations(generations);
                obj.trainMean = xMean;
                obj.dataset.X = X;
                obj.dataset.y = y;
                for i=1:obj.modelsCount
                    nTrainData = obj.models(i,1).getNTrainData();
                    if (nTrainData>size(X,1))
                        warning('ModelPool.trainModel(): not enough data for model no. %d.',i);
                    else
                        %TODO:choose the data
                        modelXData = X(1:nTrainData,:);
                        modelYData = y(1:nTrainData,:);
                        
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