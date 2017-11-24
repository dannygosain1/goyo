import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import GaussianNB
import argparse

def main(args):
	# top data

	walk6_top_csv = np.loadtxt ('feature_vectors/walk6top_standard.csv', delimiter=",")
	walk5_top_csv = np.loadtxt ('feature_vectors/walk5top_standard.csv', delimiter=",")
	walk_predict_csv = np.loadtxt('{0}'.format(args.data), delimiter=",")
	walk6_top_target = walk6_top_csv[:, 0]
	walk6_top_data = walk6_top_csv[:, 1:]
	walk5_top_target = walk5_top_csv[:, 0]
	walk5_top_data = walk5_top_csv[:, 1:]
	training_target = np.concatenate([walk5_top_target, walk6_top_target])
	training_set = np.concatenate([walk5_top_data, walk6_top_data])

	walk_predict_target = walk_predict_csv[:, 0]
	walk_predict_data = walk_predict_csv[:, 1:]
	#data_train, data_test, target_train, target_test = train_test_split(walk6_top_data, walk6_top_target, test_size = 0.4)

	gnb = GaussianNB()

	walk_predict_pred = gnb.fit(training_set, training_target).predict(walk_predict_data)
	print("Number of mislabeled points from top sensor with standard features out of a total %d points : %d" % (walk_predict_data.shape[0],(walk_predict_target != walk_predict_pred).sum()))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Demo model test")
    parser.add_argument('--data', default='demo/standard_features.csv', type=str,  dest="data", help='data to test model against') 
    args = parser.parse_args()
    main(args)