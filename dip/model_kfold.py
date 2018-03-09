import os
import numpy as np
import pandas as pd
from scipy import stats
import argparse
import extract_features as ef
from sklearn.model_selection import train_test_split
from sklearn.model_selection import KFold
from sklearn.naive_bayes import GaussianNB
from sklearn.cluster import KMeans
from sklearn.neighbors import KNeighborsClassifier
from sklearn import svm
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
from sklearn.metrics import f1_score


def train_folds(num_folds, algorithm, training_data, training_data_class, test_data):
    kf = KFold(n_splits=num_folds)
    results = []
    for tr, ts in kf.split(training_data):
        algorithm.fit(training_data[tr], training_data_class[tr])
        p = algorithm.predict(test_data)
        results.append(p)
    return np.array(results)

def vote_on_predictions(results):
    num_folds, num_predictions = results.shape
    final_predictions = []
    for i in range(num_predictions):
        preds = [fold[i] for fold in results]
        final_predictions.append(stats.mode(np.array(preds)).mode[0])
    return final_predictions

def load_files(feature_dir):
    files = os.listdir(feature_dir)
    files = list(map(lambda file: "{0}/{1}".format(feature_dir, file), files))
    data = pd.concat((pd.read_csv(f) for f in files))
    return data.values

def kNN(k):
    return KNeighborsClassifier(n_neighbors=k)

def SVM(c):
    return svm.SVC(C=c, kernel='rbf', gamma=100)

def main(args):
    #load data
    if args.raw_data_dir is not None:
        raw_data_files = os.listdir(args.raw_data_dir)
        print("Generating features from data files")
        features = map(lambda raw_file: ef.generate_features(pd.read_csv("data/{0}".format(raw_file))), raw_data_files)
        data = pd.concat(features).values
        print("Done generating features")
    elif args.feature_dir is not None:
        data = load_files(args.feature_dir)

    names = ["3nn", "5nn", "7nn", "SVM", "D Tree", "Random Forest"]
    results = [pd.DataFrame(columns=['accuracy', 'precision', 'recall', 'f1'], dtype=np.float_) for _ in range(len(names))]
    for _ in range(args.iters):
        data_train, data_test, target_train, target_test = train_test_split(data[:, 1:], data[:, 0], test_size = 0.3)

        nn_3 = kNN(3)
        nn_5 = kNN(5)
        nn_7 = kNN(7)
        svm = SVM(500)
        dtree = DecisionTreeClassifier(max_depth=3)
        forest = RandomForestClassifier(max_depth=3)
        classifiers = [nn_3, nn_5, nn_7, svm, dtree, forest]
    
        for i, (name, clf, result) in enumerate(zip(names, classifiers, results)):
            k_predictions = train_folds(5, clf, data_train, target_train, data_test)
            prediction = vote_on_predictions(k_predictions)
            results[i] = result.append({
                    'accuracy': accuracy_score(target_test, prediction), 
                    'precision': precision_score(target_test, prediction), 
                    'recall': recall_score(target_test, prediction), 
                    'f1': f1_score(target_test, prediction)
                }, ignore_index=True)




    # base = np.ones(target_test.shape)
    # print("Profile for base")
    # print("Accuracy Score: {0}".format(accuracy_score(target_test, base)))
    # print("Precision Score: {0}".format(precision_score(target_test, base)))
    # print("Recall Score: {0}".format(recall_score(target_test, base)))
    # print("F1 Score: {0}".format(f1_score(target_test, base)))
    # print()
    for name, res in zip(names, results):
        print("Results for %s" % name) 
        print(res)
        print(res.mean(axis=0))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run Models")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--features', type=str,  dest="feature_dir", help='the relative filepath of feature dir')
    group.add_argument('--raws', type=str,  dest="raw_data_dir", help='the relative filepaths of the raw data dir')
    parser.add_argument('--iterations', type=int, dest="iters", help='number of times to re-run with random test split', default=1)
    args = parser.parse_args()

    main(args)
