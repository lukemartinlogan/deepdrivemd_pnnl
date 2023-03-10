import os, glob
import numpy as np
import pandas as pd
import networkx as nx

class DataLife:

    def __init__(self, G=None):
        self.utils = Utils
        self.G = G

    def max_volume(self, G, weight='volume'):
        """Returns the edge tuples by identifying maximum volume in a
        directed acyclic graph (DAG).

        If `G` has edges with `volume` attribute the edge data are used as
        weight values.

        Parameters
        ----------
        G : NetworkX DiGraph
            A directed acyclic graph (DAG)

        weight : str, optional
            Edge data key to use for weight

        Returns
        -------
        list
            edge tuples
        """
        path = nx.dag_longest_path(G, weight)
        path_edges = list(zip(path,path[1:]))
        return path_edges


    def mismatch_rate(self, G, rate='rate', threshold=.9):
        """Returns the python dictionary by identifying mismatched data rates in a
        directed acyclic graph (DAG).

        If `G` has edges with `rate` attribute the edge data are used as
        weight values.

        Parameters
        ----------
        G : NetworkX DiGraph
            A directed acyclic graph (DAG)

        rate : str, optional
            Edge data key to use for weight

        threshold: float, optional
            value between 0 to 1 to cut off mismatch, default .9

        Returns
        -------
        dictionary
            key:
                node name
            value:
                in_rate: float, incoming data rate (avg.)
                out_rate: float, outgoing data rate (avg.)
                in_edges: list, incoming edge tuples
                out_edges: list, outgoing edge tuples
        """
        res = {}
        for n, attr in G.nodes(data=True):
            if  'ntype' in attr and attr['ntype'] == 'task':
                continue
            in_edges = [x for x in G.in_edges(n, data=True)]
            out_edges = [x for x in G.out_edges(n, data=True)]
            in_rate_mean = np.mean([attr[rate] for u, v, attr in (in_edges)])
            out_rate_mean = np.mean([attr[rate] for u, v, attr in (out_edges)])
            if np.isnan(in_rate_mean) or np.isnan(out_rate_mean):
                continue
            print(in_rate_mean, out_rate_mean)
            if in_rate_mean > out_rate_mean:
                if (out_rate_mean / in_rate_mean) < threshold:
                    continue
            else:
                if (in_rate_mean / out_rate_mean) < threshold:
                    continue
            res[n] = {'in_rate': in_rate_mean,
                     'out_rate': out_rate_mean,
                     'in_edges': [(u, v) for u, v, a in in_edges],
                      'out_edges': [(u, v) for u, v, a in out_edges]}
        return res

    def leaf_file_node(self, G, partial=.0):
        """Returns the python dictionary by identifying non-use of dataset in a
        directed acyclic graph (DAG).

        If `G` has edges with `volume` attribute the edge data are used as
        weight values.

        Parameters
        ----------
        G : NetworkX DiGraph
            A directed acyclic graph (DAG)

        partial : float, optional
            value between 0 and 1 to detect subset-use, default .0

        Returns
        -------
        dictionary
            key:
                node name
            value:
                out_edges: edge tuples
                volume_used: total size of subset data (sum)
        """
        res = {}
        vol = 'volume'
        for n, attr in G.nodes(data=True):
            if  'ntype' in attr and attr['ntype'] == 'task':
                continue
            out_edges = G.out_edges(n)
            if len(out_edges) == 0:
                # OutEdgeDataView([])
                try:
                    res[n]['out_edges'] = out_edges
                    res[n]['volume_used'] = 0
                except:
                    res[n] = {'out_edges': out_edges,
                              'volume_used' : 0 }
            elif partial:
                out_edges = G.out_edges(n, data=True)
                out_vol_sum = sum([attr[vol] for u, v, attr in (out_edges)])
                if out_vol_sum / attr[vol] < partial:
                    try:
                        res[n]['out_edges'] = out_edges
                        res[n]['volume_used'] = out_vol_sum
                    except:
                        res[n] = {'out_edges': out_edges,
                                 'volume_used': out_vol_sum}

        return res

    def partial_leaf_file_node(self, G, partial=.5):
        """Returns the python dictionary by identifying non-use of dataset in a
        directed acyclic graph (DAG).

        If `G` has edges with `volume` attribute the edge data are used as
        weight values.

        Parameters
        ----------
        G : NetworkX DiGraph
            A directed acyclic graph (DAG)

        partial : float, optional
            value between 0 and 1 to detect subset-use, default .5

        Returns
        -------
        dictionary
            key:
                node name
            value:
                out_edges: edge tuples
                volume_used: total size of subset data (sum)
        """
        return self.leaf_node(G, partial)

    def spatial_temporal_locality(self, G):
        """
        requres block ids (offset) to align tasks in order
        TBD


        """
        pass


    def producer_consumer_tasks(self, G):
        """Returns all paths in the graph G between producer and consumer
        task nodes.

        A producer-consumer path is a path between source node (producer)
        and target node (consumer) with no repeated nodes.


        Parameters
        ----------
        G : NetworkX DiGraph
            A directed acyclic graph (DAG)

        Returns
        -------
        list
            path
        """
        res = []
        for n, attr in G.nodes(data=True):
            if  'ntype' in attr and attr['ntype'] != 'task':
                continue
            producer_n = n
            data_n = [x[1] for x in G.edges(producer_n)]
            consumer_n = set()
            for x in data_n:
                consumer_n.update(set([x[1] for x in G.edges(x)]))
            for consumer in consumer_n:
                paths = [x for x in nx.all_simple_paths(G, producer_n, consumer, cutoff=2)]
                res += paths
        return res
