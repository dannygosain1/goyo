import argparse
import pandas as pd

def main(args):
	print("hello")
	fsr_data = pd.read_csv(args.fsr)
	fsr_cols = ['fsr1', 'fsr2']
	fsr_keep = fsr_data[fsr_cols]
	accel_data = pd.read_csv(args.accel)
	accel_cols = ['x', 'y', 'z']
	accel_keep = accel_data[accel_cols]

	raw_data = fsr_keep.join(accel_keep)
	raw_data.to_csv('../matlab/demo/raw_data.csv')


if __name__ == '__main__':
	parser = argparse.ArgumentParser(description="Demo model test")
	parser.add_argument('--fsr')
	parser.add_argument('--accel') 
	args = parser.parse_args()
	main(args)