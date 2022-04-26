import networkx as nx
from networkx.drawing.nx_agraph import write_dot, graphviz_layout
import matplotlib.pyplot as plt
G = nx.DiGraph()

md_tasks = 120
agg_tasks = 10
ml_tasks = 1
ag_tasks = 1

def add_node(G, stage_idx, task_cnt):
    for i in range(1, task_cnt + 1):
        print(i)
        G.add_node('stage{}-task{}'.format(stage_idx, i), stage_id=stage_idx, task_id=i)
        if stage_idx > 1:
            prev_stage_names = [ x for x, y in G.nodes(data=True) if y['stage_id'] == stage_idx - 1 ]
            print(prev_stage_names)
            for j in prev_stage_names:
                G.add_edge(j, 'stage{}-task{}'.format(stage_idx, i))

add_node(G, 1, md_tasks)
add_node(G, 2, agg_tasks)
add_node(G, 3, ml_tasks)
add_node(G, 4, ag_tasks)

pos =graphviz_layout(G, prog='dot')
nx.draw(G, pos, with_labels=False, arrows=True)
plt.savefig('ddmd_dag.png')
from networkx.drawing.nx_agraph import write_dot
write_dot(G, 'ddmd_dag.dot')
