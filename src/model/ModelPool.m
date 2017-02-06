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
        choosingCriterium
        retrainPeriod
        historyLength
        trainRanges
        xMean
    end
    
    methods (Access = public)
        function obj = ModelPool(modelOptions, xMean, archive)
            obj.modelPoolOptions = modelOptions;
            obj.xMean = xMean;
            obj.archive = archive;
            obj.modelsCount = size(modelOptions.parameterSets,2);
            assert(obj.modelsCount ~= 0, 'ModelPool(): No model provided!');
            obj.historyLength = modelOptions.historyLength;
            obj.models = cell(obj.modelsCount,obj.historyLength);
            obj.bestModelsHistory = zeros(1,obj.modelsCount);
            obj.dim       = size(xMean, 2);
            obj.shiftMean = zeros(1, obj.dim);
            obj.shiftY    = 0;
            obj.stdY  = 1;
            obj.trainRanges = zeros(1, obj.modelsCount);
            %create the models
            for i=1:obj.modelsCount
                options = modelOptions.parameterSets(i);
                obj.models{i,1} = ModelFactory.createModel('gp',options,xMean);
                obj.trainRanges(i) = ModelPool.calculateTrainRange(options.trainRange, obj.dim);
            end
            obj.retrainPeriod = modelOptions.retrainPeriod;
            obj.predictionType = modelOptions.predictionType;
            obj.bestModel=1;
            
            obj.options.normalizeY = defopts(modelOptions, 'normalizeY', true);
            
            % general model prediction options
            obj.predictionType = defopts(modelOptions, 'predictionType', 'fValues');
            obj.transformCoordinates = defopts(modelOptions, 'transformCoordinates', true);
            obj.dimReduction = defopts(modelOptions, 'dimReduction', 1);
            
        end
        
        function nData = getNTrainData(obj)
            nData=obj.models{1,1}.getNTrainData();
            for i=2:obj.modelsCount
                nData = min(nData,obj.models{i,1}.getNTrainData());
            end
        end
        
        function obj = trainModel(obj, paramX, paramY, xMean, generation)
            
            if (mod(generation,obj.retrainPeriod)==0)
                trainedModelsCount=0;
                for i=1:obj.modelsCount
                    if strcmpi(obj.modelPoolOptions.parameterSets(i).trainsetType,'parameters')
                        X = paramX;
                        y = paramY;
                    else
                        switch lower(obj.modelPoolOptions.parameterSets(i).trainsetType)
                            case 'allpoints'
                                generations=1:generation;
                                [X,y]=obj.archive.getDataFromGenerations(generations);
                            case 'clustering'
                                
                            case 'nearest'
                                
                            case 'nearesttopopulation'
                        end
                        
                        if obj.transformCoordinates
                            %XTransf =( (obj.trainSigma * obj.trainBD) \ X')';
                        else
                            %XTransf = X;
                        end
                    end
                    
                    nTrainData = obj.models{i,1}.getNTrainData();
                    
                    if (nTrainData < size(X,1))
                        
                        newModel = ModelFactory.createModel('gp',obj.modelPoolOptions.parameterSets(i),xMean);
                        newModel = newModel.trainModel(X, y, xMean, generation);
                        if (newModel.isTrained())
                            % Test that we don't have a constant model
                            %[~, xTestValid] = sampleCmaesNoFitness(sigma, lambda, stateVariables, sampleOpts);
                            %yPredict = newModel.predict(xTestValid');
                            %if (max(yPredict) - min(yPredict) < MIN_RESPONSE_DIFFERENCE)
                            %    obj.models{i,1).trainGeneration = -1;
                            if (false)
                                
                            else
                                trainedModelsCount=trainedModelsCount+1;
                                obj.models(i,:) = circshift(obj.models(i,:),[1,1]);
                                obj.models{i,1} = newModel;
                            end
                        end
                    end
                end
                
                obj.trainGeneration = generation;
                [obj.bestModel,obj.choosingCriterium] = obj.chooseBestModel();
                
                obj.stdY = obj.models{obj.bestModel,1}.stdY;
                obj.options = obj.models{obj.bestModel,1}.options;
                obj.hyp = obj.models{obj.bestModel,1}.hyp;
                obj.meanFcn = obj.models{obj.bestModel,1}.meanFcn;
                obj.covFcn = obj.models{obj.bestModel,1}.covFcn;
                obj.likFcn = obj.models{obj.bestModel,1}.likFcn;
                obj.infFcn = obj.models{obj.bestModel,1}.infFcn;
                obj.nErrors = obj.models{obj.bestModel,1}.nErrors;
                obj.trainLikelihood = obj.models{obj.bestModel,1}.trainLikelihood;
                
                obj.shiftY = obj.models{obj.bestModel,1}.shiftY;
                obj.trainMean = obj.models{obj.bestModel,1}.trainMean;
                
                obj.dataset = obj.models{obj.bestModel,1}.dataset;
                
                %if (trainedModelsCount==0)
                %    warning('ModelPool.trainModel(): trainedModelsCount == 0');
                %end
            end
        end
        
        function [y, sd2] = modelPredict(obj, X)
            [y,sd2] = obj.models{obj.bestModel,1}.modelPredict(X);
        end
        
    end
    
    methods (Access = public)
        function [bestModelIndex, choosingCriterium] = chooseBestModel(obj)
            lastGeneration = max(obj.archive.gens);
            choosingCriterium = Inf(obj.modelsCount,1);
            if (isempty(lastGeneration))
                lastGeneration = 0;
            end
            switch lower(obj.modelPoolOptions.bestModelSelection)
                case 'likelihood'
                    for i=1:obj.modelsCount
                        choosingCriterium(i) = obj.models{i,1}.trainLikelihood;
                    end
                case 'rdeorig'
                    for i=1:obj.modelsCount
                        generations = obj.models{i,1}.trainGeneration+1:lastGeneration;
                        [X,yArchive] = obj.archive.getDataFromGenerations(generations);
                        if (size(X,1)~=0)
                            nonEmptyCount = sum(~cellfun('isempty',obj.models(i,:)));
                            %because we test the oldest models
                            [yModel, ~] = obj.models{i,nonEmptyCount}.modelPredict(X);
                            if (size(yArchive)==size(yModel))
                                choosingCriterium(i) = errRankMu(yModel,yArchive,size(yArchive,1));
                            end
                        end
                    end
                case 'rdeall'
                    %sample more point
                    %create 2 vectors - 1 with models predictions and 1
                    %with orig + model predictions
                    %compute rde
                case 'mse'
                    for i=1:obj.modelsCount
                        generations=obj.models{i,1}.trainGeneration+1:lastGeneration;
                        [X,yArchive] = obj.archive.getDataFromGenerations(generations);
                        if (size(X,1)~=0)
                            nonEmptyCount = sum(~cellfun('isempty',obj.models(i,:)));
                            %because we test the oldest models
                            [yModel, ~] = obj.models{i,nonEmptyCount}.modelPredict(X);
                            if (size(yArchive)==size(yModel))
                                choosingCriterium(i) = immse(yArchive,yModel);
                            end
                        end
                    end
                otherwise
                    error(['ModelPool.chooseBestModel: ' obj.modelPoolOptions.bestModelSelection ' -- no such option available']);
            end
            [~,bestModelIndex] = min(choosingCriterium);
            obj.bestModelsHistory(bestModelIndex) = obj.bestModelsHistory(bestModelIndex)+1;
        end
    end
    
    methods (Static)
        function result = calculateTrainRange(percentile, dimension)
            result = chi2inv(percentile,dimension);
        end
    end
end