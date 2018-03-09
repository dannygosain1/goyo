import model_kfold as mkf
from sklearn import svm
from sklearn.ensemble import RandomForestClassifier
import coremltools
import argparse
import pandas
import extract_features
from sklearn.metrics import accuracy_score


def main(args):
	raw = pandas.read_csv(args.raw_data_file)
	features = extract_features.generate_features(raw).values
	features_labels = features[:,0]
	feature_data = features[:,1:]

	data = mkf.load_files(args.feature_dir)
	target = data[:, 0]
	fvs = data[:, 1:]
	svm = mkf.SVM(500)
	forest = RandomForestClassifier(max_depth=3)

	svm.fit(fvs, target)
	forest.fit(fvs, target)

	svm_res = svm.predict(feature_data)
	forest_res = forest.predict(feature_data)
	print("Accuracy of svm: {}".format(accuracy_score(svm_res, features_labels)))
	print("Accuracy of random forest: {}".format(accuracy_score(forest_res, features_labels)))


if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="Save models")
	parser.add_argument('--features', type=str,  dest="feature_dir", help='the relative filepath of feature dir')
	parser.add_argument('--raw_data', type=str,  dest="raw_data_file", help='the relative filepath of the raw data')
	args = parser.parse_args()
	main(args)
