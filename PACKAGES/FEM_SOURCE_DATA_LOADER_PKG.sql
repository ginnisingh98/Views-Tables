--------------------------------------------------------
--  DDL for Package FEM_SOURCE_DATA_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_SOURCE_DATA_LOADER_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_srcdata_ldr.pls 120.1 2006/08/18 11:01:55 hkaniven noship $ */


PROCEDURE Main (
  errbuf                OUT NOCOPY  VARCHAR2,
  retcode               OUT NOCOPY  VARCHAR2,
  p_obj_def_id          IN          VARCHAR2,
  p_exec_mode           IN          VARCHAR2,
  p_ledger_id           IN          VARCHAR2,
  p_cal_period_id       IN          VARCHAR2,
  p_dataset_code        IN          VARCHAR2,
  p_source_system_code  IN          VARCHAR2
);

PROCEDURE Validate_Loader_Parameters (
  p_obj_def_id          IN          NUMBER,
  p_exec_mode           IN          VARCHAR2,
  p_ledger_id           IN          NUMBER,
  p_cal_period_id       IN          NUMBER,
  p_dataset_code        IN          NUMBER,
  p_source_system_code  IN          NUMBER,
  x_object_id           OUT NOCOPY  NUMBER,
  x_table_name          OUT NOCOPY  VARCHAR2,
  x_calp_dim_grp_dc     OUT NOCOPY  VARCHAR2,
  x_cal_per_end_date    OUT NOCOPY  DATE,
  x_cal_per_number      OUT NOCOPY  NUMBER,
  x_dataset_dc          OUT NOCOPY  VARCHAR2,
  x_source_system_dc    OUT NOCOPY  VARCHAR2,
  x_ledger_dc           OUT NOCOPY  VARCHAR2,
  x_return_status       OUT NOCOPY  VARCHAR2
);

PROCEDURE Register_Process_Execution (
  p_object_id           IN          NUMBER,
  p_obj_def_id          IN          NUMBER,
  p_table_name          IN          VARCHAR2,
  p_exec_mode           IN          VARCHAR2,
  p_ledger_id           IN          NUMBER,
  p_cal_period_id       IN          NUMBER,
  p_dataset_code        IN          NUMBER,
  p_source_system_code  IN          NUMBER,
  p_request_id          IN          NUMBER,
  p_user_id             IN          NUMBER,
  p_login_id            IN          NUMBER,
  p_program_id          IN          NUMBER,
  p_program_application_id IN       NUMBER,
  x_prev_req_id         OUT NOCOPY  NUMBER,
  x_exec_state          OUT NOCOPY  VARCHAR2,
  x_return_status       OUT NOCOPY  VARCHAR2
);

PROCEDURE Populate_xDim_Info_Tbl(
  p_table_name          IN          VARCHAR2,
  p_ledger_id           IN          NUMBER,
  x_return_status       OUT NOCOPY  VARCHAR2
);

PROCEDURE Set_MP_Condition (
  p_exec_mode                IN          VARCHAR2,
  p_calp_dim_grp_dc          IN          VARCHAR2,
  p_cal_per_end_date         IN          DATE,
  p_cal_per_number           IN          NUMBER,
  p_dataset_dc               IN          VARCHAR2,
  p_source_system_dc         IN          VARCHAR2,
  p_ledger_dc                IN          VARCHAR2,
  x_condition                OUT NOCOPY  VARCHAR2,
  x_return_status            OUT NOCOPY  VARCHAR2
);

-- Added p_exec_mode as a parameter for Replacement mode Support
PROCEDURE Prepare_Dynamic_Sql (
  p_object_id                IN          NUMBER,
  p_exec_mode                IN          VARCHAR2,
  p_request_id               IN          NUMBER,
  p_ledger_id                IN          NUMBER,
  p_cal_period_id            IN          NUMBER,
  p_dataset_code             IN          NUMBER,
  p_source_system_code       IN          NUMBER,
  p_interface_table_name     IN          VARCHAR2,
  p_target_table_name        IN          VARCHAR2,
  p_condition                IN          VARCHAR2,
  x_insert_interim_sql       OUT NOCOPY  VARCHAR2,
  x_update_interim_error_sql OUT NOCOPY  VARCHAR2,
  x_insert_target_sql        OUT NOCOPY  VARCHAR2,
  x_return_status            OUT NOCOPY  VARCHAR2
);

PROCEDURE Process_Data (
  p_eng_sql                  IN  VARCHAR2,
  p_data_slice_predicate     IN  VARCHAR2,
  p_process_number           IN  NUMBER,
  p_partition_code           IN  NUMBER,
  p_fetch_limit              IN  NUMBER,
  p_request_id               IN  VARCHAR2,
  p_exec_mode                IN  VARCHAR2,
  p_target_table_name        IN  VARCHAR2,
  p_interface_table_name     IN  VARCHAR2,
  p_object_id                IN  NUMBER,
  p_ledger_id                IN  VARCHAR2,
  p_cal_period_id            IN  NUMBER,
  p_dataset_code             IN  NUMBER,
  p_source_system_code       IN  NUMBER,
  p_schema_name              IN  VARCHAR2,
  p_condition                IN  VARCHAR2
);

PROCEDURE Post_Process (
  p_object_id                IN         NUMBER,
  p_obj_def_id               IN         NUMBER,
  p_table_name               IN         VARCHAR2,
  p_exec_mode                IN         VARCHAR2,
  p_ledger_id                IN         NUMBER,
  p_cal_period_id            IN         NUMBER,
  p_dataset_code             IN         NUMBER,
  p_source_system_code       IN         NUMBER,
  p_exec_status              IN         VARCHAR2,
  p_request_id               IN         NUMBER,
  p_user_id                  IN         NUMBER,
  p_login_id                 IN         NUMBER,
  x_return_status            OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Put_Messages (
   p_msg_count       IN   NUMBER,
   p_msg_data        IN   VARCHAR2
);

PROCEDURE  Validate_Obj_Def (
  p_api_version            IN  NUMBER,
  p_object_type            IN  VARCHAR2,
  p_obj_def_id             IN  NUMBER,
  x_object_id              OUT NOCOPY NUMBER,
  x_table_name             OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
);

PROCEDURE  Validate_Table (
  p_api_version            IN  NUMBER,
  p_object_type            IN  VARCHAR2,
  p_table_name             IN  VARCHAR2,
  p_table_classification   IN  VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
);

PROCEDURE  Validate_Exec_Mode (
  p_api_version            IN  NUMBER,
  p_object_type            IN  VARCHAR2,
  p_exec_mode              IN  VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
);

PROCEDURE  Validate_Ledger (
  p_api_version            IN  NUMBER,
  p_object_type            IN  VARCHAR2,
  p_ledger_id              IN  NUMBER,
  x_ledger_dc              OUT NOCOPY VARCHAR2,
  x_ledger_calendar_id     OUT NOCOPY NUMBER,
  x_ledger_per_hier_obj_def_id OUT NOCOPY NUMBER,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
);

PROCEDURE  Validate_Cal_Period (
  p_api_version            IN  NUMBER,
  p_object_type            IN  VARCHAR2,
  p_cal_period_id          IN  NUMBER,
  p_ledger_id              IN  NUMBER,
  p_ledger_calendar_id     IN  NUMBER,
  p_ledger_per_hier_obj_def_id IN NUMBER,
  x_calp_dim_grp_dc        OUT NOCOPY VARCHAR2,
  x_cal_per_end_date       OUT NOCOPY DATE,
  x_cal_per_number         OUT NOCOPY NUMBER,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
);

PROCEDURE  Validate_Dataset (
  p_api_version            IN  NUMBER,
  p_object_type            IN  VARCHAR2,
  p_dataset_code           IN  NUMBER,
  x_dataset_dc             OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
);

PROCEDURE  Validate_Source_System (
  p_api_version            IN  NUMBER,
  p_object_type            IN  VARCHAR2,
  p_source_system_code     IN  NUMBER,
  x_source_system_dc       OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
);

END FEM_SOURCE_DATA_LOADER_PKG;

 

/
