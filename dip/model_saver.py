import model_kfold as mkf
from sklearn import svm
from sklearn.ensemble import RandomForestClassifier
import coremltools
import argparse


def main(args):
	input_features = [
        'fsr_med',
        'x_mean',
        'y_mean',
        'z_mean',
        'x_var',
        'y_var',
        'z_var',
        'x_energy',
        'y_energy',
        'z_energy'
    ]

	output_features = [0,1]

	data = mkf.load_files(args.feature_dir)
	target = data[:, 0]
	fvs = data[:, 1:]
	svm = mkf.SVM(500)
	forest = RandomForestClassifier(max_depth=3)

	target = target.astype(int)
	svm.fit(fvs, target)
	forest.fit(fvs, target)

	#save them
	svm_coreml =  coremltools.converters.sklearn.convert(
		svm, input_features, "is_walking"
	)
	forest_coreml = coremltools.converters.sklearn.convert(forest)

	svm_coreml.save('svm.mlmodel')
	forest_coreml.save('random_forest.mlmodel')



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Save models")
    parser.add_argument('--features', type=str,  dest="feature_dir", help='the relative filepath of feature dir')
    args = parser.parse_args()

    main(args)
