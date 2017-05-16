%% Initialize variables
leaf_type = 'original';
% Define templates
t_svm = templateSVM('Standardize',1);
t_knn = templateKNN('NumNeighbors',3,'Standardize',1);
classes = {'Healthy','BLS','CBSV','CMV','RMD','GMD'};
angle = 45;

% Define models and test percentages
%model_templates={t_svm,t_knn};
model_templates={t_knn};
model_names={'KNN'};
%model_names={'SVM','KNN','Inception'};
nModels=length(model_templates);
%test_percentage = [0.4];
test_percentage = [0.2,0.4,0.5,0.6,0.8];
nSplits=length(test_percentage);
%% Load bottleneck data
[healthy, disease] = load_data_cassava(leaf_type);
        
%% Run 'nRuns' loops and write results out to file each time
accuracy = zeros(nSplits,nModels);

%numFeats = size(disease,2)-1;
data = [healthy;disease];
nSamples=size(data,1);
rng(7);     % For reproducibility

for n = 1:nModels
    for split = 1:nSplits
        % define model template and name
        model = model_templates{n};
        model_name = model_names{n};
        % define test percentage
        test_perc = test_percentage(split);
        % Randomly permute samples 
        Data = data(randperm(nSamples),:);
        % Split data into training/test sets
        [tr_features,tr_labels,test_features,test_labels] = split_data( Data, test_perc );
        %% Train Learner
        if n == 3
            mdl = fitcensemble(tr_features,tr_labels,'Method','Bag','NumLearningCycles',200,'Learners',t_tree);
        else
            mdl = fitcecoc(tr_features,tr_labels,'Learners',model);
        end

        %% Make Predictions
        test_predictions = predict(mdl,test_features);
        accuracy(split,n) = sum(test_predictions == test_labels)/length(test_predictions)
        %% Save Confusion Matrix and Results
        save_results(accuracy(split,n), model_name, leaf_type );
        save_confusion_matrix(test_predictions, test_labels, test_perc, leaf_type, model_name, classes, angle);
    end
end

