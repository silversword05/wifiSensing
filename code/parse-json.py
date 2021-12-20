import json
import csv

file_object = open('../data/images/autogluon/metrics.json');
json_object = json.load(file_object);

rmse = dict()
r2_score = dict()

scenarios = dict()
scenarios['distance'] = dict()
scenarios['lineofsight'] = dict()
scenarios['diff-room'] = dict()

for dataset in range( 10,15):
	metrics = json_object[str(dataset)];
	for model in metrics:
		if model in rmse:
			rmse[model] += metrics[model]['root_mean_squared_error']
			if dataset == 11 or dataset == 14:
				if model in scenarios['distance']:
					scenarios['distance'][model] += metrics[model]['root_mean_squared_error']
				else:
					scenarios['distance'][model] = metrics[model]['root_mean_squared_error']
			elif dataset == 12 or dataset == 15:
					if model in scenarios['diff-room']:
						scenarios['diff-room'][model] += metrics[model]['root_mean_squared_error']
					else:
						scenarios['diff-room'][model] = metrics[model]['root_mean_squared_error']
			else:
					if model in scenarios['lineofsight']:
						scenarios['lineofsight'][model] += metrics[model]['root_mean_squared_error']
					else:
						scenarios['lineofsight'][model] = metrics[model]['root_mean_squared_error']
		else:
			rmse[model] = metrics[model]['root_mean_squared_error']
		if model in r2_score:
			r2_score[model] += metrics[model]['r2']
		else:
			r2_score[model] = metrics[model]['r2']

print(rmse)
print(r2_score)
with open('../data/images/autogluon/autogluon-metrics.csv','w') as f:
	for model in rmse:
		f.write("%s,%s,%s\n"%("rmse",model,rmse[model]));
	for model in r2_score:
		f.write("%s,%s,%s\n"%("r2",model,r2_score[model]));

with open('../data/images/autogluon/autogluon-scenario-metrics.csv','w') as f:
	for scenario in scenarios:
		for model in scenarios[scenario]:
			f.write("%s,%s,%s\n"%(scenario,model,scenarios[scenario][model]));
