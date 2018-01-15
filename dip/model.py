import numpy as np
import pandas as pd
import argparse
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import GaussianNB
from sklearn.cluster import KMeans
from sklearn.neighbors import KNeighborsClassifier

def load_files(filenames):
	data = pd.concat((pd.read_csv(f) for f in filenames))
	return data.values

def kNN(k, train, target):
	clf = KNeighborsClassifier(n_neighbors=k)
	return clf.fit(train, target)

def NaiveBayes(train, target):
	clf = GaussianNB()
	return clf.fit(train, target)

def main(args):
	data = load_files(args.filenames)
	data_train, data_test, target_train, target_test = train_test_split(data[:,np.r_[1:3,4:13]], data[:, 3], test_size = 0.3)
	
	nn_3 = kNN(3, data_train, target_train)
	nn_5 = kNN(5, data_train, target_train)
	gnb = NaiveBayes(data_train, target_train)

	for clf  in [nn_3, nn_5, gnb]:
		pred = clf.predict(data_test)
		print("Number of mislabeled points out of a total %d points : %d" % (data_test.shape[0],(target_test != pred).sum()))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run Models")
    parser.add_argument('--filenames', nargs='+', default=["raw_demo_data_extracted_features.csv"], type=str,  dest="filenames", help='the relative filepaths')
    args = parser.parse_args()

    main(args)