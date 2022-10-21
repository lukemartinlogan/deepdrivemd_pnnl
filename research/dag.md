# Strategy based on DAG

| DAG | Co-scheduling | Caching | Staging (async) | Pre-fetching |
| --- | ------------- | ------- | --------------- | ------------ |
| Vertex with degree 1 | |      | Yes               |              |
| Vertices conntected within 2 edges | Yes |      |             |              |
| Vertices connected within 5 degree | | Yes     |             | Yes             |

- Co-scheduling: tasks placed jointly to ensure less data movement
- Caching: considering time gaps between tasks, data can be re-used in cache
- Staging: data in a leaf node can be stored slowly and asynchronously since no use afterward
- Pre-fetching: considering different arrival (written) time of files from parallel tasks, move data near future tasks

* Data lifecycle changes how to store (intermediate/permanent) files
