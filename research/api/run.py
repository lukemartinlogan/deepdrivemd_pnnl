from pegasus_conversion import Conversion
from utils import Utils

class args():
    workflow_yml = None
    replica_yml = None
    transformation_yml = None

args = args()
args.workflow_yml = 'ddmd_workflow_360k.yml'

obj = Conversion()
obj.args = args
obj.import_dax()
obj.get_jdep()

df_md = Utils.read_tazer_stats('tazer_stat/ddmd/tazer/')
G, _pos = Utils.get_graph(obj, df_md)

