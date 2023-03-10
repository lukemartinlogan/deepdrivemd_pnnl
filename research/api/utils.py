import networkx as nx
import pandas as pd
import glob
import os

metric = 'weighted_access_size'
metric_ = metric + ' (sum)'

filtered_file_ext = ['h5', 'pt']

class Utils:
    
    @staticmethod
    def stat_to_df(fname):
        df = pd.read_csv(fname, sep=' ', names=['block_idx', 'frequency', 'access_size'], skiprows=1)
        return df
    
    @staticmethod
    def read_tazer_stats(dpath):

        agg_sum = {'frequency':'sum', 'access_size':'sum', 'weighted_access_size': 'sum'}
        agg_avg = {'frequency':'mean', 'access_size':'mean', 'weighted_access_size': 'mean'}
        agg_sum_rename = {'frequency': 'frequency (sum)', 
                          'access_size': 'access_size (sum)', 
                          'weighted_access_size': 'weighted_access_size (sum)'}
        agg_avg_rename = {'frequency': 'frequency (avg)', 
                          'access_size': 'access_size (avg)',
                          'weighted_access_size': 'weighted_access_size (avg)'}

        df_all = {}

        for fpath in glob.glob(dpath + "/*/*_stat"):

            # ignore trace stats but for r/w stat
            if fpath[-10:] == "trace_stat":
                continue
            df = Utils.stat_to_df(fpath)
            if df.empty is True:
                continue

            df['weighted_access_size'] = df['frequency'] * df['access_size']
            task_name = os.path.basename(os.path.dirname(fpath))
            stat_filename = os.path.basename(fpath)
            series = df.agg(agg_sum)
            df_sum = pd.DataFrame(series).transpose().rename(columns=agg_sum_rename)
            series = df.agg(agg_avg)
            df_avg = pd.DataFrame(series).transpose().rename(columns=agg_avg_rename)
            df = pd.concat([df_sum, df_avg], axis=1)
            if task_name in df_all:
                if stat_filename in df_all[task_name]:
                    print(fname, "==duplicate==")
                df_all[task_name][stat_filename] = df
            else:
                df_all[task_name] = {stat_filename: df}

        return df_all

    @staticmethod
    def get_graph(data, df, metric_=metric_):
        print("Building a graph with this metric:", metric_)
        _pos = (0, -1)
        G = nx.DiGraph()
        prev_v = 1
        cnt = 0
        for k, v in data.ordered_by_val.items():
            if prev_v == v:
                cnt += 1
            else:
                cnt = 0
            if cnt > 10000:
                prev_v = v
                continue
            t_info = data.retrieve_cmd_info(k)
            tname = os.path.basename(t_info['exec'])
            tnodename = "%s (%s)" % (tname, k)
            if prev_v == v:
                _pos = (_pos[0], _pos[1] + 1)
            else:
                _pos = (v + 2, 0)
            G.add_node(tnodename, ntype='task', pos=_pos)
            #rint(tnodename)
            prev_v = v
            __pos = _pos
            for ftype in ['inputs', 'outputs']:

                bnames = [x for x in t_info[ftype] if x.split('.')[1] in filtered_file_ext]
                __pos = (_pos[0] + 2.5, __pos[1])
                for bname in bnames:
                    sname = bname + "_r_stat" if ftype == 'inputs' else bname + "_w_stat"
                    if tname not in df:
                        print (tname, "--missing--")
                        continue
                    if sname not in df[tname]:
                        print(tname, sname , "==missing==")
                        continue
                    stat = df[tname][sname]
                    frequency = stat[metric_][0]
                    frequency_sum = stat['frequency (sum)'][0]
                    if G.has_node(bname) is False:
                        G.add_node(bname, pos=__pos)
                        __pos = (__pos[0], __pos[1] + 1)
                    if ftype == 'inputs':
                        G.add_edge(bname, tnodename, value=frequency, frequency_sum=frequency_sum)
                    else:
                        G.add_edge(tnodename, bname, value=frequency, frequency_sum=frequency_sum)
            _pos = (_pos[0], __pos[1])
            #_pos = (_pos[0] + 1, 0) 
        return G, _pos
