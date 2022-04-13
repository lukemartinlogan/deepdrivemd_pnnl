-*-Mode: markdown;-*-
-----------------------------------------------------------------------------

Vision
=============================================================================

Enabling productive and performant application coupling to generate converged workflows on distributed and heterogeneous computing platforms. Performance monitoring and analysis of data movement and locality to develop execution feedback templates to workflow runtime that reduce data access bottlenecks.

* Assumptions:
  - workflow tasks uses files for coupling
  - workflow (or workflow manager) correctly manages file dependences

* Outline:
  1. Capture data flow graph
  2. Assess producer/consumer locality
  3. Generate templates that improve locality of rproducer/consumer tasks (new mapping) and use hierarchical staging to exploit locality


Potential for performance improvement & Workflow assessment
=============================================================================

* Opportunities: Combine task placement and staging. Remain within I/O
  interface.

  - Big: Ensure locality when realizing dependences
    - where to stage: i.e., here, near, remote (when forced)
    - what to stage: i.e., subsets of output to avoid whole-file dependency

    - locality types: direct, neighborhoods

  - Possibly big: write elimination for unnecessary/unused data

  - Some: Prefetching
  
  - Little: Write buffering

* Questions
  - Lifecycle of data
    - dependence types (read/write)
    - data sizes/volume
    - access patterns
    - locality patterns
    
  - Task memory pressure (potential for memory-based staging)


Comparing ADIOS and RADICAL
=============================================================================

- ADIOS model

  1. Dependencies have one source and one sink. This means that any
     conceptual joins or forks must be appropriately converted and the
     join/fork operator implemented by the user as an
     aggregator/duplicator.
  
  2. Dependencies are implemented with producer/consumer pipes with
     one producer and one consumer.

     - Producers block until their value is copied to the pipe
     - Consumers poll (block) (i.e., no notify as in publish/subscribe)
  
  3. A pipe can hold multiple producer values. This means producers can
     run at different rates than consumers. One can set a limit on the
     pipe buffers, after which producer operations block (or drop values).
    
  4. Pipes are implemented with special files ('bp' file)

  5. At joins, consumers must check that all incoming dependence edges have been resolved.

  ? Can a consumer check for a new value in a bp file? Or just the bp file's existence?

  ? Is there any locality between producer and consumer?


- Radical model

  - I think (1) is the same as with ADIOS.
  
  ? Does Radical permit a "dependence" to have multiple values? Presumably no.
  
  ? Does Radical have a notion of signaling a consumer task? Presumably "no" as the notion of "signal" is different from "launch task with the assumption that input files are available". That is, in Radical, an aggregator task is launched when all inputs are available.
  > [hyungro] No signaling mechanism is correct in general, but it looks like there are/were experimental features through zmq which provide pub/sub and push/pull types. for example, [this](https://github.com/radical-cybertools/radical.pilot/blob/devel/examples/misc/rp_app_master.py) and [that](https://github.com/radical-cybertools/radical.utils/tree/devel/src/radical/utils/zmq)
  
  ? Implication: ADIOS could permit the simulation to complete much more quickly than with Radical, but the overall logical critical path is the same. The critical path with ADIOS may be more efficient by avoiding file system more.

