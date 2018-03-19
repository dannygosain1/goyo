import model_kfold as mkf
from sklearn import svm
from sklearn.ensemble import RandomForestClassifier
import coremltools
import argparse
from sklearn import tree
import pydot

def main(args):
    input_features = [
        'fsr_med',
        'x_mean',
        'y_mean',
        'z_mean',
        'x_var',
        'y_var',
        'z_var'
    ]

    output_features = [0,1]

    data = mkf.load_files(args.feature_dir)
    target = data[:, 0]
    fvs = data[:, 1:8]
    forest = RandomForestClassifier(max_depth=3)

    target = target.astype(int)
    forest.fit(fvs, target)

    i_tree = 0
    for tree_in_forest in forest.estimators_:
        with open('tree_' + str(i_tree) + '.dot', 'w') as my_file:
            my_file = tree.export_graphviz(tree_in_forest, out_file = my_file)
        i_tree = i_tree + 1

    for i in range(0,i_tree):
        dot_file = "tree_%s.dot" % str(i)
        output_file = "tree_%s.png" % str(i)
        (graph,) = pydot.graph_from_dot_file(dot_file)
        graph.write_png(output_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Save models")
    parser.add_argument('--features', type=str,  dest="feature_dir", help='the relative filepath of feature dir')
    args = parser.parse_args()

    main(args)
