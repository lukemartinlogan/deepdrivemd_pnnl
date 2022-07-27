import adios2

class AdiosProducerConsumer:
    cfg_path = "./adios_cfg/"

    def __init__(self):
        self.stream_cfg = self.cfg_path + "adios_stream.xml"
        self.file_cfg =  self.cfg_path + "adios_file.xml"
        self.stream_name = "SimulationOutput"
        self.file_name = "Trajectory"
        self.stream_path = "md.bp"
        self.file_path = "trajectory.bp"

    def setup_conn(self):

        self._stream = adios2.open(
                name=self.stream_path,
                mode="w",
                config_file=self.stream_cfg,
                io_in_config_file=self.stream_name,
                )

        self._file = adios2.open(
                name= self.file_path,
                mode="w",
                config_file=self.file_cfg,
                io_in_config_file=self.file_name,
                )

    def put(self, data):
        for k, values in data.items():
            for v in values:
                self._stream.write(
                        k, v, list(v.shape), [0] * len(v.shape), list(v.shape)
                        )
                self._stream.end_step()
                self._file.write(
                        k, v, list(v.shape), [0] * len(v.shape), list(v.shape)
                        )
                self._file.end_step()

    def close_conn(self):
        self._stream.close()
        self._file.close()

if __name__ == "__main__":

    obj = sim_emulator.SimEmulator(n_residues = 28,
            n_atoms = 500,
            n_frames = 100,
            n_jobs= 1)
    obj.settings(output_filename = None,
            is_contact_map = True,
            is_point_cloud = False,
            is_rmsd = False,
            is_fnc = False)

    cms = obj.contact_maps()

    main(data={"contact_map":cms})
