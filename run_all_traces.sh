#!/bin/bash

singlecore_traces=( "GemsFDTD_109B"
"GemsFDTD_712B"
"GemsFDTD_716B"
"astar_163B"
"astar_23B"
"astar_313B"
"bwaves_1609B"
"bwaves_1861B"
"bwaves_98B"
"bzip2_183B"
"bzip2_259B"
"bzip2_281B"
"cactusADM_1039B"
"cactusADM_1495B"
"cactusADM_734B"
"calculix_2655B"
"calculix_2670B"
"calculix_3812B"
"gamess_196B"
"gamess_247B"
"gamess_316B"
"gcc_13B"
"gcc_39B"
"gcc_56B"
"gobmk_135B"
"gobmk_60B"
"gobmk_76B"
"gromacs_0B"
"gromacs_1B"
"h264ref_178B"
"h264ref_273B"
"h264ref_351B"
"hmmer_397B"
"hmmer_546B"
"hmmer_7B"
"lbm_1004B"
"lbm_564B"
"lbm_94B"
"leslie3d_1116B"
"leslie3d_1186B"
"leslie3d_94B"
"libquantum_1210B"
"libquantum_1735B"
"libquantum_964B"
"mcf_158B"
"mcf_250B"
"mcf_46B"
"milc_360B"
"milc_409B"
"milc_744B"
"namd_1907B"
"namd_400B"
"namd_851B"
"omnetpp_17B"
"omnetpp_340B"
"omnetpp_4B"
"perlbench_105B"
"perlbench_135B"
"perlbench_53B"
"povray_250B"
"povray_437B"
"povray_711B"
"sjeng_1109B"
"sjeng_1966B"
"sjeng_358B"
"soplex_205B"
"soplex_217B"
"soplex_66B"
"sphinx3_1339B"
"sphinx3_2520B"
"sphinx3_883B"
"tonto_2049B"
"tonto_2834B"
"tonto_422B"
"wrf_1212B"
"wrf_1228B"
"wrf_1650B"
"xalancbmk_748B"
"xalancbmk_768B"
"xalancbmk_99B"
"zeusmp_100B"
"zeusmp_300B"
"zeusmp_600B" )

multicore_traces=( "cassandra_phase0"
"cassandra_phase1"
"cassandra_phase2"
"cassandra_phase3"
"cassandra_phase4"
"cassandra_phase5"
"classification_phase0"
"classification_phase1"
"classification_phase2"
"classification_phase3"
"classification_phase4"
"classification_phase5"
"cloud9_phase0"
"cloud9_phase1"
"cloud9_phase2"
"cloud9_phase3"
"cloud9_phase4"
"cloud9_phase5"
"nutch_phase0"
"nutch_phase1"
"nutch_phase2"
"nutch_phase3"
"nutch_phase4"
"nutch_phase5" )
#"streaming_phase0"
#"streaming_phase1"
#"streaming_phase2"
#"streaming_phase3"
#"streaming_phase4"
#"streaming_phase5" )

warmup=1
simulation=100
batch=4
type=0

while getopts b:w:s:t: flag
do
    case "${flag}" in
        w) warmup=${OPTARG};;
        s) simulation=${OPTARG};;
        b) batch=${OPTARG};;
		t) type=${OPTARG};;
		*) echo "Invalid option: -$flag" ;;
	esac
done
echo "Warmup: ${warmup}000000";
echo "Simulation: ${simulation}000000";
echo "Batch size: $batch";

if [[ $type -eq 0 ]] 
then
	echo "Type: Single core traces"
elif [[ $type -eq 1 ]]
then
	echo "Type: Multicore traces"
fi

if [[ $type -eq 0 ]]
then
	for trace in "${singlecore_traces[@]}"
	do
		echo "$trace"
		
		if grep -Fxq "ChampSim completed all CPUs" "results/${trace}.txt"
		then
			continue
		fi
		
		
		bin/champsim --warmup_instructions "${warmup}000000" --simulation_instructions "${simulation}000000" "traces/${trace}.trace.xz" > "results/${trace}.txt" &

		num_jobs=( $(jobs -p | wc -l) )
		if [[ $num_jobs -ge $batch ]]
		then
			echo Reached max, waiting
			wait -n
		fi
	done
fi

if [[ $type -eq 1 ]]
then
	for trace in "${multicore_traces[@]}"
	do
		echo "$trace"
		bin/champsim --warmup_instructions "${warmup}000000" --simulation_instructions "${simulation}000000" -cloudsuite -traces "traces/${trace}_core0.trace.xz" "traces/${trace}_core1.trace.xz" "traces/${trace}_core2.trace.xz" "traces/${trace}_core3.trace.xz" > "results/${trace}.txt" &

		num_jobs=( $(jobs -p | wc -l) )
		if [[ $num_jobs -ge $batch ]]
		then
			echo Reached max, waiting
			wait -n
		fi
	done
fi
