PATH=~/checkouts/shexSpec/shex.js/packages/shex-cli/bin/:$PATH

validate -x schemas/Cotton.shex -d data/cotton-experiment-1.ttl -m '<Experiments/1>@<Experiment.shex#Experiment>' --diagnose
echo $?
