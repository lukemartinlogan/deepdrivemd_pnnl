# Performance Characteristics of DeepDriveMD

## Overview

Prior to the recent publication at IPDPS 2022 [1], we made performance evaluation of the workflow. The figure shows scaling performance of the workflow and the four main components; simulation, aggregation, training and agent are highlighted with different color boxes in the first left sub figure (a). Other figures were made with different use cases but the I/O delays between tasks become significant to the workflow completion time. 

![perf-base](/research/figures/perf_comp.png)

## Overview of ADIOS implementation

Apart from the file-based implementation (batch style), asynchronous exeuction mode is offered via ADIOS I/O system, and the brief overview is depicted below:
![ddmd-s](/research/figures/ddmd-s.png)

[1] Brace, Alexander, Igor Yakushin, Heng Ma, Anda Trifan, Todd Munson, Ian Foster, Arvind Ramanathan, Hyungro Lee, Matteo Turilli, and Shantenu Jha. "Coupling streaming AI and HPC ensembles to achieve 100–1000× faster biomolecular simulations." In 2022 IEEE International Parallel and Distributed Processing Symposium (IPDPS), pp. 806-816. IEEE, 2022.
