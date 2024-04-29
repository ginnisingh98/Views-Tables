--------------------------------------------------------
--  DDL for Package BSC_UPDATE_BASE_V2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UPDATE_BASE_V2" AUTHID CURRENT_USER AS
/* $Header: BSCDBV2S.pls 120.0 2005/10/25 14:07:57 eperkov noship $ */

--
-- Procedures and Fuctions
--

FUNCTION Calculate_Base_Table (
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_correction_flag IN BOOLEAN,
    x_aw_flag IN BOOLEAN
 ) RETURN BOOLEAN;

FUNCTION Calculate_Base_Table_AT (
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_correction_flag IN BOOLEAN,
    x_aw_flag IN BOOLEAN
 ) RETURN BOOLEAN;

PROCEDURE Calc_New_Period_Input_Table(
    x_input_table IN VARCHAR2,
    x_periodicity IN NUMBER,
    x_current_fy IN NUMBER,
    x_period OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
);

PROCEDURE Calc_New_Period_Base_Table(
    x_base_table IN VARCHAR2,
    x_periodicity IN NUMBER,
    x_current_fy IN NUMBER,
    x_per_input_table IN NUMBER,
    x_current_per_base_table OUT NOCOPY NUMBER,
    x_per_base_table OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
);

PROCEDURE Calc_Projection(
    x_base_table IN VARCHAR2,
    x_proj_table IN VARCHAR2,
    x_aw_flag IN BOOLEAN,
    x_change_vector_value IN NUMBER,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_period IN NUMBER,
    x_current_fy IN NUMBER,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_proj_methods IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_data_columns IN NUMBER,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_parallel_jobs IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
);

FUNCTION Create_Generic_Temp_Tables
RETURN BOOLEAN;

FUNCTION Create_Generic_Temp_Tables_AT
RETURN BOOLEAN;

PROCEDURE  Create_Proc_Load_Tbl_MV(
    x_proc_name IN VARCHAR2,
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_period IN NUMBER,
    x_old_current_period IN NUMBER,
    x_current_fy IN NUMBER,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_key_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_formulas IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_measure_types IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_data_columns IN NUMBER,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_num_partitions IN NUMBER,
    x_parallel_jobs IN VARCHAR2,
    x_rowid_table IN VARCHAR2,
    x_num_loads IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Proc_Load_Tbl_SUM_AW(
    x_proc_name IN VARCHAR2,
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_aw_flag IN BOOLEAN,
    x_change_vector_value IN NUMBER,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_period IN NUMBER,
    x_current_fy IN NUMBER,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_key_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_data_columns IN NUMBER,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_num_partitions IN NUMBER,
    x_parallel_jobs IN VARCHAR2,
    x_rowid_table IN VARCHAR2,
    x_num_loads IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Types_For_MV_Load(
    x_base_table IN VARCHAR2,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_data_columns IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
);

FUNCTION Get_Base_Proj_Tbl_Name(
    x_base_table IN VARCHAR2
) RETURN VARCHAR2;

PROCEDURE Init_Bsc_Db_Calendar_Temp(
    x_base_table IN VARCHAR2,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_period IN NUMBER,
    x_current_fy IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
);

PROCEDURE Init_Bsc_Db_Calendar_Temp_Proj(
    x_base_table IN VARCHAR2,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_period IN NUMBER,
    x_current_fy IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
);

PROCEDURE Load_Input_Table_Inc(
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_aw_flag IN BOOLEAN,
    x_change_vector_value IN NUMBER,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_period IN NUMBER,
    x_old_current_period IN NUMBER,
    x_current_fy IN NUMBER,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_key_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_formulas IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_measure_types IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_data_columns IN NUMBER,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_num_partitions IN NUMBER,
    x_parallel_jobs IN VARCHAR2,
    x_rowid_table IN VARCHAR2,
    x_num_loads IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
);

PROCEDURE Load_Input_Table_Initial(
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_aw_flag IN BOOLEAN,
    x_change_vector_value IN NUMBER,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_period IN NUMBER,
    x_current_fy IN NUMBER,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_key_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_formulas IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_measure_types IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_data_columns IN NUMBER,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_num_partitions IN NUMBER,
    x_parallel_jobs IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
);

PROCEDURE Calc_Higher_Periodicities(
    x_base_table IN VARCHAR2,
    x_periodicity IN NUMBER,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_formulas IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_measure_types IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_data_columns IN NUMBER,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_parallel_jobs IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Base_Table_Job (
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_correction_flag IN BOOLEAN,
    x_aw_flag IN BOOLEAN,
    x_change_vector_value IN NUMBER,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_fy IN NUMBER,
    x_current_period IN NUMBER,
    x_old_current_period IN NUMBER,
    x_proj_table IN VARCHAR2,
    x_rowid_table IN VARCHAR2,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_num_partitions IN NUMBER,
    x_num_loads IN NUMBER,
    x_job_name IN VARCHAR2
 );

PROCEDURE Update_Base_Table (
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_correction_flag IN BOOLEAN,
    x_aw_flag IN BOOLEAN,
    x_change_vector_value IN NUMBER,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_fy IN NUMBER,
    x_current_period IN NUMBER,
    x_old_current_period IN NUMBER,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_key_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_formulas IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_proj_methods IN BSC_UPDATE_UTIL.t_array_of_number,
    x_data_measure_types IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_data_columns IN NUMBER,
    x_proj_table IN VARCHAR2,
    x_rowid_table IN VARCHAR2,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_num_partitions IN NUMBER,
    x_num_loads IN NUMBER,
    x_parallel_jobs IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
 );


END BSC_UPDATE_BASE_V2;

 

/
