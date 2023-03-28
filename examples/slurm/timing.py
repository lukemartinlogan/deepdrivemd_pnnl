from glob import glob
import sys, os

base_path = ""
if len(sys.argv) > 1:
    base_path = (sys.argv[1])

md_path = os.path.join(base_path, "molecular_dynamics_runs/*/*/task*log")
md_flist = glob(md_path)

md_stats = []
for fname in md_flist:
    with open(fname, 'r') as f:
        cont = f.read()
        lines = cont.split("\n")
        t_min, t_max = float('inf'), 0
        timing = 0
        for line in lines:
            try:
                _, _, _, timing, _ = line.split("|",4)
            except:
                continue
            timing = float(timing)
            t_min = min(t_min, timing)
            t_max = max(t_max, timing)

        if timing:
            md_stats.append(t_max - t_min)
print("md run avg:", sum(md_stats)/len(md_stats))

# Agg stat
#agg_path='molecular_dynamics_runs/stage0000/task0011/task0000_AGGREGATE.log'
agg_paths=glob(os.path.join(base_path, "molecular_dynamics_runs/stage*/task*/task*_AGGREGATE.log"))
for agg_path in agg_paths:
    with open(agg_path, 'r') as f:
        cont = f.read()
        lines = cont.split("\n")
        captured_time = 0
        for line in lines:
            if line[:4] == "real":
                captured_time = line.split()[1]
                break
        print("agg time:", captured_time)

# Train stat
# 1675101568.8220203
sample_train_time = "1675101568.8220203"
train_paths=glob(os.path.join(base_path, "machine_learning_runs/stage*/task*/task*_TRAINING.log"))
train_stats = []
for train_path in train_paths:
    with open(train_path, 'r') as f:
        cont = f.read()
        lines = cont.split("\n")
        for line in lines:
            if len(line) <= len(sample_train_time):
                try:
                    lfloat = float(line)
                except:
                    continue
                train_stats.append(lfloat)
    if len(train_stats) >= 2:
        print("train avg:", (train_stats[1]) - (train_stats[0]))

# Inference stat
inf_paths=glob(os.path.join(base_path, 'inference_runs/stage*/task*/task*_INFERENCE.log'))
inf_stats=[]
for inf_path in inf_paths:
    with open(inf_path, 'r') as f:
        cont = f.read()
        lines = cont.split("\n")
        t_min, t_max = float('inf'), 0
        timing = 0
        for line in lines:
            try:
                _, _, _, timing, _ = line.split("|",4)
            except:
                continue
            timing = float(timing)
            t_min = min(t_min, timing)
            t_max = max(t_max, timing)

        if timing:
            inf_stats.append(t_max - t_min)
    print("inf run avg:", inf_stats[0])

