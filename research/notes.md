-*-Mode: markdown;-*-
-----------------------------------------------------------------------------

Vision
=============================================================================

Enabling productive and performant application coupling to generate converged workflows on distributed and heterogeneous computing platforms. Performance monitoring and analysis of data movement and locality to develop execution feedback templates to workflow runtime that reduce data access bottlenecks.


Potential for performance improvement
=============================================================================

* Opportunities: Combine task placement and staging. Remain within I/O
  interface.

  - Big: Ensure locality when realizing dependences
    - locality types: direct, neighborhoods
    - where to stage: i.e., here, near, remote (when forced)
    - what to stage: i.e., subsets of output to avoid whole-file dependency

  - Possibly big: write elimination for unnecessary/unused data

  - Some: Prefetching
  
  - Little: Write buffering


Workflow characterization for task placement and staging
=============================================================================

* Outline:
  0. Assume:
    - workflow tasks use file-based coupling
    - workflow manages task dependencies

  1. Capture and characterize data flow graph
  2. Identify opportunities for data locality
  3. Generate templates to improve data locality via task placement/staging
  

1. Capture and characterize data flow graph
   (With RADICAL, an explicit dependence graph is already available.)

  - Characterization:
    - dependence types (see below) for locality patterns of
      dependencies: e.g., direct, neighborhoods

    - data sizes/volume for importance of dependence

    - future: 
      dependence precision (eg, portion of file is read)
      data access patterns within file (how to stage each file)


  - Dependence types:
    - series:       single-writer, single reader
    - fork/fan-out: single-writer, multiple reader
    - join/fan-in:  aggregation/reduction
    - fork+join

  - Task memory pressure (potential for memory-based staging)


2. Identify opportunities for data locality

   - Analyze locality patterns
   - Generate RADICAL tags to affect scheduler's task placement
   
   - tag each vertex, ie, equivalence class of vertices

3. Generate templates to improve data locality via task placement/staging

   - Instantiate Hermes (or Tazer) daemons
   - Run workflow with adjusted RADICAL task schedule/mappings
   - Template provides hints to improve staging (what and where)


* Related Work

  - Flux: Overcoming Scheduling Challenges for Exascale Workflows:
    https://ieeexplore.ieee.org/abstract/document/8638377

  - Scalable I/O-Aware Job Scheduling for Burst Buffer Enabled HPC Clusters: schedule tasks based on a model of I/O contention
    https://dl.acm.org/doi/10.1145/2907294.2907316

  - PRIONN: Prediction Runtime and IO using Neural Networks
    https://doi.org/10.1145/3225058.3225091


Comparing ADIOS and RADICAL
=============================================================================

RADICAL
----------------------------------------

1. Scheduling: RADICAL schedules tasks as dependences are resolved

   Dependencies have one source and one sink. This means that any
   conceptual joins or forks must be appropriately converted and the
   join/fork operator implemented by the user as an
   aggregator/duplicator.
   
   Tasks are nodes. Files are edges.
   
   > Radical provides a callback to make sure `n` tasks are finished before moving to the next phase, i.e., EnTK's stage post_exec, and the related example is [here](https://radicalentk.readthedocs.io/en/stable/adv_examples/adapt_ta.html). However, this feature isn't exactly to permit a "dependence". Radical model provides a task placement only, and the data management is responsible by a user application, how to implement coupling or dependence.


2. Task assignent:
   - By default, tasks execute on any available node
   - User can assign tags to tasks and request that only certain nodes
     execute certain tags.


ADIOS (+ RADICAL) model
----------------------------------------

1. Scheduling:
   - Reserve some nodes for ADIOS servers
   - RADICAL schedules tasks as dependences are resolved (bp-files)

2. Dependencies are implemented with producer/consumer pipes with one
   producer and one consumer.

   - Producers block until their value is copied to the pipe

   - Consumers poll (block) until a new value (record) is available.
     No notify as in publish-subscribe.
     
     > Check for new value: [the read_step method](https://github.com/DeepDriveMD/DeepDriveMD-pipeline/blob/c0073303a824b66fe1d0b64a53ad76bfde223848/deepdrivemd/data/stream/adios_utils.py#L44) and [the adios BeginStep](https://adios2.readthedocs.io/en/latest/components/components.html?#beginstep)
     
   - Pipes are implemented with special files (bp-file)
  
3. A pipe can hold multiple producer values. This means producers can
   run at different rates than consumers. One can set a limit on the
   pipe buffers, after which producer operations block (or drop
   values).
   
   Implication: ADIOS could permit some tasks to complete more quickly
   than with RADICAL, but the overall logical critical path could
   easily be the same.
   
   Note: In this ADIOS version, there is one bp-file per file in
   RADICAL version. However, multiple tasks could use same bp-file.

4. At joins, consumers must check that all incoming dependence edges
   have been resolved.

[[Question]] If RADICAL is managing scheduling, why are there aggregators that poll on their source data?
> While the simulations keep running in the ADIOS model, the aggregator needs to find out if there are new data to process proactively i.e., polling. In RADICAL only model, the aggregator presumes that new data (files) produced from the simulation, as earlier tasks (simulation) were terminated to come to itself in the workflow pipeline. 
