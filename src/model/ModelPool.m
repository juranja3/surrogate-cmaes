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
        sampleOpts            % options and settings for the CMA-ES sampling
        
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
        modelsCount           % number of models in the modelPool
        historyLength         % number of older models that are saved
        models                %instances of models, 2D cell array of modelscount*historyLength+1
        isModelTrained        % 2D array, 0 if model at this position in models property is trained, 1 otherwise
        bestModelIndex
        bestModelsHistory     % how many times has been each model chosen as the best one
        choosingCriterium     % mse/rde/likelihood/...
        retrainPeriod
        trainRanges
        nTrainData            % min of getNTrainData of all created models
        xMean
        switchToLikelihoodPercentile    % if percentile of oldest models that are trained
        % drops below this value, we use the likelihood of newest models
        % instead of the chosen trainsetType
        
    end
    
    methods (Access = public)
        function obj = ModelPool(modelOptions, xMean, archive)
            obj.modelPoolOptions = modelOptions;
            obj.xMean = xMean;
            obj.archive = archive;
            obj.modelsCount = length(modelOptions.parameterSets);
            assert(obj.modelsCount ~= 0, 'ModelPool(): No model provided!');
            obj.historyLength = defopts(modelOptions, 'historyLength', 4);
            obj.retrainPeriod = defopts(modelOptions, 'retrainPeriod', 1);
            obj.models = cell(obj.modelsCount,obj.historyLength+1);
            obj.isModelTrained = false(obj.modelsCount,obj.historyLength+1);
            obj.bestModelsHistory = zeros(1,obj.modelsCount);
            obj.dim       = size(xMean, 2);
            obj.shiftMean = zeros(1, obj.dim);
            obj.shiftY    = 0;
            obj.stdY      = 1;
            obj.trainRanges = zeros(1, obj.modelsCount);
            obj.switchToLikelihoodPercentile = defopts(modelOptions, 'switchToLikelihoodPercentile', 0.25);
            
            % general model prediction options
            obj.predictionType = defopts(modelOptions, 'predictionType', 'fValues');
            obj.transformCoordinates = defopts(modelOptions, 'transformCoordinates', true);
            obj.dimReduction = defopts(modelOptions, 'dimReduction', 1);
            obj.options.normalizeY = defopts(modelOptions, 'normalizeY', true);
            
            obj.nTrainData = Inf;
            for i=1:obj.modelsCount
                %create the models, calculate needed properties
                modelOptions = obj.modelPoolOptions.parameterSets(i);
                obj.models{i,1} = obj.createGpModel(i, xMean);
                obj.nTrainData = min(obj.models{i,1}.getNTrainData(),obj.nTrainData);
                obj.trainRanges(i) = ModelPool.calculateTrainRange(modelOptions.trainRange, obj.dim);
            end
            
        end
        
        function gpModel = createGpModel(obj, modelIndex, xMean)
            newModelOptions = obj.modelPoolOptions.parameterSets(modelIndex);
            newModelOptions.predictionType = obj.predictionType;
            newModelOptions.transformCoordinates = obj.transformCoordinates;
            newModelOptions.dimReduction = obj.dimReduction;
            newModelOptions.options.normalizeY = obj.options.normalizeY;
            
            gpModel = ModelFactory.createModel('gp', newModelOptions, xMean);
            
        end
        
        function nData = getNTrainData(obj)
            nData = obj.nTrainData;
        end
        
        function trained = isTrained(obj)
            % check whether the model chosen as the best in the newest generation is trained
            if (isempty(obj.isModelTrained(obj.bestModelIndex,1)))
                trained = false;
            else
                trained = obj.isModelTrained(obj.bestModelIndex,1);
            end
        end
        
        function obj = trainModel(obj, paramX, paramY, xMean, generation)
            persistent persistantBestModelsHistory;     % used because evolution strategy always creates a new modelpool
            
            if (mod(generation,obj.retrainPeriod)==0)
                
                trainedModelsCount=0;
                for i=1:obj.modelsCount
                    modelOptions = obj.modelPoolOptions.parameterSets(i);
                    trainsetType = defopts(modelOptions, 'trainsetType', 'parameters');
                    if strcmpi(trainsetType,'parameters')
                        X = paramX;
                        y = paramY;
                    else
                        %TODO: move to archive
                        switch lower(trainsetType)
                            case 'allpoints'
                                generations=1:generation;
                                [X,y]=obj.archive.getDataFromGenerations(generations);
                            case 'clustering'
                                
                            case 'nearest'
                                
                            case 'nearesttopopulation'
                        end
                        
                        if obj.transformCoordinates && size(X,1)>0
                            X = ( (obj.trainSigma * obj.trainBD) \ X')';
                        end
                        
                        trainsetSizeMax = modelOptions.trainsetSizeMax;
                        if size(X,1)> trainsetSizeMax
                            X = X(end-trainsetSizeMax+1:end,:);
                            y = y(end-trainsetSizeMax+1:end,:);
                            %remove elements from the beginning
                        end
                        %TODO: move to archive
                    end
                    
                    % minimal difference between minimal and maximal returned
                    % value to regard the model as trained; otherwise, the
                    % constant response is mark of a badly trained model
                    % and therefor it is marked as untrained
                    MIN_RESPONSE_DIFFERENCE = min(1e-8, 0.05 * (max(y) - min(y)));
                    
                    obj.models(i,:) = circshift(obj.models(i,:),[0,1]);
                    obj.isModelTrained(i,:) = circshift(obj.isModelTrained(i,:),[0,1]);
                    obj.isModelTrained(i,1) = 0;
                    obj.models{i,1} = obj.createGpModel(i, xMean);
                    obj.models{i,1} = obj.models{i,1}.trainModel(X, y, xMean, generation);
                    obj.models{i,1} = obj.copyPropertiesToGpModel(obj.models{i,1});
                    
                    if (obj.models{i,1}.isTrained())
                        % Test that we don't have a constant model
                        [~, xTestValid] = sampleCmaesNoFitness(...
                            obj.trainSigma, ...
                            obj.stateVariables.lambda, ...
                            obj.stateVariables, ...
                            obj.sampleOpts);
                        yPredict = obj.models{i,1}.predict(xTestValid');
                        if (max(yPredict) - min(yPredict) < MIN_RESPONSE_DIFFERENCE)
                            obj.models{i,1}.trainGeneration = -1;
                        else
                            trainedModelsCount=trainedModelsCount+1;
                            obj.isModelTrained(i,1) = 1;
                        end
                    end
                end
                
                if (trainedModelsCount==0)
                    warning('ModelPool.trainModel(): trainedModelsCount == 0');
                else
                    obj.trainGeneration = generation;
                    
                    [obj.bestModelIndex,obj.choosingCriterium] = obj.chooseBestModel(generation);
                    obj.bestModelsHistory(obj.bestModelIndex) = obj.bestModelsHistory(obj.bestModelIndex)+1;
                    obj = obj.copyPropertiesFromBestModel();
                    
                    if (isempty(persistantBestModelsHistory))
                        persistantBestModelsHistory = zeros(obj.modelsCount,1);
                    end
                    persistantBestModelsHistory(obj.bestModelIndex) = persistantBestModelsHistory(obj.bestModelIndex)+1;
                    obj.bestModelsHistory = persistantBestModelsHistory;
                end
            end
        end
        
        function [y, sd2] = modelPredict(obj, X)
            [y,sd2] = obj.models{obj.bestModelIndex,1}.modelPredict(X);
        end
        
        function X = getDataset_X(obj)
            X = obj.models{obj.bestModelIndex,1}.getDataset_X();
        end
        
        function y = getDataset_y(obj)
            y = obj.models{obj.bestModelIndex,1}.getDataset_y();
        end
        
    end
    
    methods (Access = public)
        function [bestModelIndex, choosingCriterium] = chooseBestModel(obj, lastGeneration)
            
            if (isempty(lastGeneration))
                lastGeneration = 0;
            end
            
            trainedPercentile = mean2(obj.isModelTrained(:,end));
            
            if trainedPercentile < obj.switchToLikelihoodPercentile ...
                    || strcmpi(obj.modelPoolOptions.bestModelSelection,'likelihood')
                choosingCriterium = obj.getLikelihood();
            else
                switch lower(obj.modelPoolOptions.bestModelSelection)
                    case 'rdeorig'
                        choosingCriterium = obj.getRdeOrig(lastGeneration);
                    case 'rdeall'
                        choosingCriterium = obj.getRdeAll();
                    case 'mse'
                        choosingCriterium = obj.getMse(lastGeneration);
                    otherwise
                        error(['ModelPool.chooseBestModel: ' obj.modelPoolOptions.bestModelSelection ' -- no such option available']);
                end
            end
            % choose the best model from trained ones according to the choosing criterium
            [~,bestModelIndex] = min(choosingCriterium(obj.isModelTrained(:,1)));
        end
        
        function obj = copyPropertiesFromBestModel(obj)
            obj.stdY = obj.models{obj.bestModelIndex,1}.stdY;
            obj.options = obj.models{obj.bestModelIndex,1}.options;
            obj.hyp = obj.models{obj.bestModelIndex,1}.hyp;
            obj.meanFcn = obj.models{obj.bestModelIndex,1}.meanFcn;
            obj.covFcn = obj.models{obj.bestModelIndex,1}.covFcn;
            obj.likFcn = obj.models{obj.bestModelIndex,1}.likFcn;
            obj.infFcn = obj.models{obj.bestModelIndex,1}.infFcn;
            obj.nErrors = obj.models{obj.bestModelIndex,1}.nErrors;
            obj.trainLikelihood = obj.models{obj.bestModelIndex,1}.trainLikelihood;
            
            obj.shiftY = obj.models{obj.bestModelIndex,1}.shiftY;
            obj.trainMean = obj.models{obj.bestModelIndex,1}.trainMean;
        end
        
        function gpModel = copyPropertiesToGpModel(obj, gpModel)
            gpModel.stateVariables = obj.stateVariables;
            gpModel.sampleOpts = obj.sampleOpts;
            gpModel.trainSigma = obj.trainSigma;
            gpModel.trainBD = obj.trainBD;
        end
        
        function choosingCriterium = getRdeOrig(obj, lastGeneration)
            choosingCriterium = Inf(obj.modelsCount,1);
            for i=1:obj.modelsCount
                generations = obj.models{i,1}.trainGeneration+1:lastGeneration;
                [X,yArchive] = obj.archive.getDataFromGenerations(generations);
                if (size(X,1)~=0)
                    if (~isempty(obj.models{i,obj.historyLength+1}))
                        %because we test the oldest models
                        [yModel, ~] = obj.models{i,obj.historyLength+1}.modelPredict(X);
                        if (size(yArchive)==size(yModel))
                            choosingCriterium(i) = errRankMu(yModel,yArchive,size(yArchive,1));
                        end
                    end
                end
            end
        end
        
        function choosingCriterium = getRdeAll(obj)
            choosingCriterium = Inf(obj.modelsCount,1);
            for i=1:obj.modelsCount
                model = obj.models{i,obj.historyLength+1};
                if ~isempty(model)
                    [~, xSample] = sampleCmaesNoFitness(...
                        model.trainSigma, ...
                        model.stateVariables.lambda, ...
                        model.stateVariables, ...
                        model.sampleOpts);
                    % get points from archive 
                    [origPoints_X, origPoints_y] = obj.archive.getDataFromGenerations(model.trainGeneration+1);
                    xSample(1:size(origPoints_X,1)) = origPoints_X(1:size(origPointsX,1));
                    ySample = model.predict(xSample');
                    yWithOrig = ySample;
                    % replace predicted values with original values
                    yWithOrig(1:size(origPoints_y,1)) = origPoints_y;
                    choosingCriterium(i) = errRankMu(ySample,yWithOrig,size(yWithOrig,1));
                end
            end
        end
        
        function choosingCriterium = getMse(obj, lastGeneration)
            choosingCriterium = Inf(obj.modelsCount,1);
            for i=1:obj.modelsCount
                generations=obj.models{i,1}.trainGeneration+1:lastGeneration;
                [X,yArchive] = obj.archive.getDataFromGenerations(generations);
                if (size(X,1)~=0)
                    if (~isempty(obj.models{i,obj.historyLength+1}))
                        %because we test the oldest models
                        [yModel, ~] = obj.models{i,obj.historyLength+1}.modelPredict(X);
                        if (size(yArchive)==size(yModel))
                            choosingCriterium(i) = immse(yArchive,yModel);
                        end
                    end
                end
            end
        end
        
        function choosingCriterium = getLikelihood(obj)
            choosingCriterium = Inf(obj.modelsCount,1);
            for i=1:obj.modelsCount
                choosingCriterium(i) = obj.models{i,1}.trainLikelihood;
            end
        end
        
    end
    
    methods (Static)
        function result = calculateTrainRange(percentile, dimension)
            result = chi2inv(percentile,dimension);
        end
    end
end