# Package error notes

## MDAnalysis
Version 2.1.0 has compilation error
Changes to MDAnalysis==2.0.0

MDAnalysis==2.1.0 error:
```
Collecting MDAnalysis
  Using cached MDAnalysis-2.1.0.tar.gz (3.5 MB)
  Installing build dependencies ... done
  Getting requirements to build wheel ... error
  error: subprocess-exited-with-error
  
  × Getting requirements to build wheel did not run successfully.
  │ exit code: 1
  ╰─> [58 lines of output]
      
      Error compiling Cython file:
      ------------------------------------------------------------
      ...
          array_wrapper = ArrayWrapper()
          array_wrapper.set_data(<void*> data_ptr, <int*> &dim[0], dim.size, data_type)
      
          cdef np.ndarray ndarray = np.array(array_wrapper, copy=False)
          # Assign our object to the 'base' of the ndarray object
          ndarray.base = <PyObject*> array_wrapper
                 ^
      ------------------------------------------------------------
      
      MDAnalysis/lib/formats/cython_util.pyx:115:11: Assignment to a read-only property
      Attempting to autodetect OpenMP support... Compiler supports OpenMP
      Will attempt to use Cython.
      Compiling MDAnalysis/lib/formats/libdcd.pyx because it changed.
      Compiling MDAnalysis/lib/c_distances.pyx because it changed.
      Compiling MDAnalysis/lib/c_distances_openmp.pyx because it changed.
      Compiling MDAnalysis/lib/qcprot.pyx because it changed.
      Compiling MDAnalysis/lib/formats/libmdaxdr.pyx because it changed.
      Compiling MDAnalysis/lib/formats/cython_util.pyx because it changed.
      Compiling MDAnalysis/analysis/encore/cutils.pyx because it changed.
      Compiling MDAnalysis/analysis/encore/clustering/affinityprop.pyx because it changed.
      Compiling MDAnalysis/analysis/encore/dimensionality_reduction/stochasticproxembed.pyx because it changed.
      Compiling MDAnalysis/lib/_cutil.pyx because it changed.
      Compiling MDAnalysis/lib/_augment.pyx because it changed.
      Compiling MDAnalysis/lib/nsgrid.pyx because it changed.
      [ 1/12] Cythonizing MDAnalysis/analysis/encore/clustering/affinityprop.pyx
      [ 2/12] Cythonizing MDAnalysis/analysis/encore/cutils.pyx
      [ 3/12] Cythonizing MDAnalysis/analysis/encore/dimensionality_reduction/stochasticproxembed.pyx
      [ 4/12] Cythonizing MDAnalysis/lib/_augment.pyx
      [ 5/12] Cythonizing MDAnalysis/lib/_cutil.pyx
      [ 6/12] Cythonizing MDAnalysis/lib/c_distances.pyx
      [ 7/12] Cythonizing MDAnalysis/lib/c_distances_openmp.pyx
      [ 8/12] Cythonizing MDAnalysis/lib/formats/cython_util.pyx
      Traceback (most recent call last):
        File "/home/mtang11/miniconda3/envs/hermes_openmm7_ddmd/lib/python3.7/site-packages/pip/_vendor/pep517/in_process/_in_process.py", line 351, in <module>
          main()
        File "/home/mtang11/miniconda3/envs/hermes_openmm7_ddmd/lib/python3.7/site-packages/pip/_vendor/pep517/in_process/_in_process.py", line 333, in main
          json_out['return_val'] = hook(**hook_input['kwargs'])
        File "/home/mtang11/miniconda3/envs/hermes_openmm7_ddmd/lib/python3.7/site-packages/pip/_vendor/pep517/in_process/_in_process.py", line 118, in get_requires_for_build_wheel
          return hook(config_settings)
        File "/tmp/pip-build-env-kkdzf3l0/overlay/lib/python3.7/site-packages/setuptools/build_meta.py", line 341, in get_requires_for_build_wheel
          return self._get_build_requires(config_settings, requirements=['wheel'])
        File "/tmp/pip-build-env-kkdzf3l0/overlay/lib/python3.7/site-packages/setuptools/build_meta.py", line 323, in _get_build_requires
          self.run_setup()
        File "/tmp/pip-build-env-kkdzf3l0/overlay/lib/python3.7/site-packages/setuptools/build_meta.py", line 488, in run_setup
          self).run_setup(setup_script=setup_script)
        File "/tmp/pip-build-env-kkdzf3l0/overlay/lib/python3.7/site-packages/setuptools/build_meta.py", line 338, in run_setup
          exec(code, locals())
        File "<string>", line 590, in <module>
        File "<string>", line 453, in extensions
        File "/tmp/pip-build-env-kkdzf3l0/overlay/lib/python3.7/site-packages/Cython/Build/Dependencies.py", line 1134, in cythonize
          cythonize_one(*args)
        File "/tmp/pip-build-env-kkdzf3l0/overlay/lib/python3.7/site-packages/Cython/Build/Dependencies.py", line 1301, in cythonize_one
          raise CompileError(None, pyx_file)
      Cython.Compiler.Errors.CompileError: MDAnalysis/lib/formats/cython_util.pyx
      [end of output]
  
  note: This error originates from a subprocess, and is likely not a problem with pip.
error: subprocess-exited-with-error

× Getting requirements to build wheel did not run successfully.
│ exit code: 1
╰─> See above for output.

note: This error originates from a subprocess, and is likely not a problem with pip.
(hermes_openmm7_ddmd) mtang11@ares:~/scripts/deepdrivemd$ pip update
ERROR: unknown command "update"
(hermes_openmm7_ddmd) mtang11@ares:~/scripts/deepdrivemd$ pip upgrade
ERROR: unknown command "upgrade"
(hermes_openmm7_ddmd) mtang11@ares:~/scripts/deepdrivemd$ conda update conda

PackageNotInstalledError: Package is not installed in prefix.
  prefix: /home/mtang11/miniconda3/envs/hermes_openmm7_ddmd
  package name: conda
```

## pydantic
Changes topydantic==1.9.0
pydantic-2.1.1 has below error:
```
/home/mtang11/miniconda3/envs/hermes_openmm7_ddmd/lib/python3.7/site-packages/MDAnalysis/coordinates/chemfiles.py:108: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
  MIN_CHEMFILES_VERSION = LooseVersion("0.9")
Traceback (most recent call last):
  File "/home/mtang11/scripts/deepdrivemd/deepdrivemd/sim/openmm/run_openmm.py", line 20, in <module>
    from deepdrivemd.sim.openmm.config import OpenMMConfig
  File "/home/mtang11/scripts/deepdrivemd/deepdrivemd/sim/openmm/config.py", line 5, in <module>
    from deepdrivemd.config import MolecularDynamicsTaskConfig
  File "/home/mtang11/scripts/deepdrivemd/deepdrivemd/config.py", line 5, in <module>
    from pydantic import BaseSettings as _BaseSettings
  File "/home/mtang11/miniconda3/envs/hermes_openmm7_ddmd/lib/python3.7/site-packages/pydantic/__init__.py", line 210, in __getattr__
    return _getattr_migration(attr_name)
  File "/home/mtang11/miniconda3/envs/hermes_openmm7_ddmd/lib/python3.7/site-packages/pydantic/_migration.py", line 290, in wrapper
    '`BaseSettings` has been moved to the `pydantic-settings` package. '
pydantic.errors.PydanticImportError: `BaseSettings` has been moved to the `pydantic-settings` package. See https://docs.pydantic.dev/2.1.1/migration/#basesettings-has-moved-to-pydantic-settings for more details.

For further information visit https://errors.pydantic.dev/2.1.1/u/import-error
```
