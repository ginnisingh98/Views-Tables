--------------------------------------------------------
--  DDL for Package BSC_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UPDATE" AUTHID CURRENT_USER AS
/* $Header: BSCDUPDS.pls 120.1 2005/11/16 12:26:13 meastmon noship $ */
--
-- Global Constants
--
-- Process name
PC_INCREMENTAL_PROCESS CONSTANT VARCHAR2(1) := 'I';
PC_LOADER_PROCESS CONSTANT VARCHAR2(1) := 'L';
PC_YEAR_CHANGE_PROCESS CONSTANT VARCHAR2(1) := 'Y';
PC_DELETE_KPI_DATA_PROCESS CONSTANT VARCHAR2(1) := 'D';
PC_REFRESH_EDW_DIMENSION CONSTANT VARCHAR2(1) := 'M';
PC_LOAD_DIMENSIONS CONSTANT VARCHAR2(1) := 'P';

-- Process status
PC_PENDING_STATUS 	CONSTANT VARCHAR2(1) := 'P';
PC_RUNNING_STATUS 	CONSTANT VARCHAR2(1) := 'R';
PC_ERROR_STATUS   	CONSTANT VARCHAR2(1) := 'E';
PC_COMPLETED_STATUS   	CONSTANT VARCHAR2(1) := 'C';

-- Input tables status
LC_PENDING_STATUS 	CONSTANT VARCHAR2(1) := 'P';
LC_RUNNING_STATUS 	CONSTANT VARCHAR2(1) := 'R';
LC_ERROR_STATUS   	CONSTANT VARCHAR2(1) := 'E';
LC_NO_DATA_STATUS   	CONSTANT VARCHAR2(1) := 'N';
LC_COMPLETED_STATUS   	CONSTANT VARCHAR2(1) := 'C';

-- Input tables stages
LC_PENDING_STAGE 	CONSTANT VARCHAR2(1) := 'P';
LC_UPLOADED_STAGE 	CONSTANT VARCHAR2(1) := 'U';
LC_VALIDATED_STAGE 	CONSTANT VARCHAR2(1) := 'V';
LC_BASE_UPDATED_STAGE 	CONSTANT VARCHAR2(1) := 'B';
LC_SYSTEM_UPDATED_STAGE CONSTANT VARCHAR2(1) := 'S';
LC_COMPLETED_STAGE      CONSTANT VARCHAR2(1) := 'C';

-- Input tables error codes
LC_INVALID_CODES_ERR 		CONSTANT VARCHAR2(25) := 'INVALID_CODES_ERR';
LC_PROGRAM_ERR	 		CONSTANT VARCHAR2(25) := 'PROGRAM_ERR';
LC_UPLOAD_OPEN_ERR      	CONSTANT VARCHAR2(25) := 'UPLOAD_OPEN_ERR';
LC_UPLOAD_NUM_COLS_ERR  	CONSTANT VARCHAR2(25) := 'UPLOAD_NUM_COLS_ERR';
LC_UPLOAD_INV_KEY_ERR   	CONSTANT VARCHAR2(25) := 'UPLOAD_INV_KEY_ERR';
LC_UPLOAD_INSERT_ERR    	CONSTANT VARCHAR2(25) := 'UPLOAD_INSERT_ERR';
LC_UPLOAD_NOT_FOUND_ERR 	CONSTANT VARCHAR2(25) := 'UPLOAD_NOT_FOUND_ERR';
LC_UPLOAD_EXCEL_ERR     	CONSTANT VARCHAR2(25) := 'UPLOAD_EXCEL_ERR';
LC_UPLOAD_SP_NOT_FOUND_ERR 	CONSTANT VARCHAR2(25) := 'UPLOAD_SP_NOT_FOUND_ERR';
LC_UPLOAD_SP_INVALID_ERR 	CONSTANT VARCHAR2(25) := 'UPLOAD_SP_INVALID_ERR';
LC_UPLOAD_SP_EXECUTION_ERR	CONSTANT VARCHAR2(25) := 'UPLOAD_SP_EXECUTION_ERR';

--
-- Global variables
--
g_debug_flag VARCHAR2(3);

g_session_id NUMBER;
g_user_id NUMBER;
g_schema_name VARCHAR2(30);

g_indicators BSC_UPDATE_UTIL.t_array_of_number;
g_num_indicators NUMBER;
g_kpi_mode BOOLEAN;
g_keep_input_table_data varchar2(20);

--Bug#4681065
g_warning BOOLEAN;

--
-- Procedures and Functions
--

/*===========================================================================+
|
|   Name:          Can_Calculate_Sys_Table
|
|   Description:   This function returns TRUE when the given system table
|                  can be calculated. The table can be calculated if all tables
|                  from where the table is originated and are part of current
|                  process have been calculated previously.
|                  The tables that have been calculated previously are in the
|                  array x_calculated_sys_tables.
|
|   Parameters:
|
|   Returns:       If some error occurr this function returns NULL
|
|   Notes:
|
+============================================================================*/
FUNCTION Can_Calculate_Sys_Table(
	x_system_table IN VARCHAR2,
	x_calculated_sys_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_calculated_sys_tables IN NUMBER,
        x_system_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_system_tables IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Can_Load_Dim_Table
|
|   Description:   This function returns TRUE when the given dimension table
|                  can be loaded. The table can be loaded if all the parent
|                  tables which are part of current process have been loaded
|                  previously.
|                  The tables that have been loaded previously are in the
|                  array x_loaded_tables.
|
|   Parameters:
|
|   Returns:       If some error occurr this function returns NULL
|
|   Notes:
|
+============================================================================*/
FUNCTION Can_Load_Dim_Table(
	x_dim_table IN VARCHAR2,
	x_loaded_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_loaded_tables IN NUMBER,
        x_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_dim_tables IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Configure_Periodicity_Calc
|
|   Description:   This function configure the periodicity calculation
|                  in the given base table. It looks all the periodicities
|                  required in the dependent tables.
|                  Returns False in case of error along with the error
|                  message in x_error_message
|
|   Notes:
|
+============================================================================*/
FUNCTION Configure_Periodicity_Calc(
    p_base_table IN VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Configure_Periodicity_Calc_VB
|
|   Description:   This procedure configure the periodicity calculation
|                  in the given base table. It looks all the periodicities
|                  required in the dependent tables.
|                  It is called from Metadata Optmizer.
|                  In case of error, it insert the error message in
|                  BSC_MESSAGE_LOGS.
|
|   Notes:
|
+============================================================================*/
PROCEDURE Configure_Periodicity_Calc_VB(
    p_base_table IN VARCHAR2
);


/*===========================================================================+
|
|   Name:          Configure_Profit_Calc
|
|   Description:   This function configure the profit calculation in the
|                  base tables that require this calculation.
|                  Returns False in case of error along with the error
|                  message in x_error_message
|
|   Notes:
|
+============================================================================*/
FUNCTION Configure_Profit_Calc(
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Configure_Profit_Calc_VB
|
|   Description:   This procedure configure the profit calculation in the
|                  base tables that require this calculation.
|                  It is called from Metadata Optmizer.
|                  In case of error, it insert the error message in
|                  BSC_MESSAGE_LOGS.
|
|   Notes:
|
+============================================================================*/
PROCEDURE Configure_Profit_Calc_VB;


/*===========================================================================+
|
|   Name:          Execute_Update_Process
|
|   Description:   This is the main procedure that runs the update process.
|		   If some error ocurrs the error message is written in
|		   BSC_MESSAGE_LOGS table with TYPE = 0.
|
|   Parameters:    x_process_id   - Process ID
|                  x_process_name - Process name: 'L' - Load input tables
|                                                 'Y' - Year change process
|                                                 'D' - Delete kpis data
|                  x_parameter_1 - Defaults to NULL. Applies only for delete
|                                  kpis data process. In this case this
|                                  parameter contains a list of kpi codes
|                                  that are the indicators whose data is
|                                  going to be deleted.
|
|   Returns:
|
|   Notes:         The process to be run is in BSC_DB_PROCESS_CONTROL table
|		   with pending status. The input tables are registered in
|		   BSC_DB_LOADER_CONTROL table with the corresponding process id.
|
+============================================================================*/
PROCEDURE Execute_Update_Process (
        x_process_id IN NUMBER,
	x_process_name IN VARCHAR2,
	x_parameter_1 IN VARCHAR2
	);


/*===========================================================================+
|
|   Name:          Execute_Year_Change_Process
|
|   Description:   This function executrs the year change process for the given
|                  calendar.
|
|   Parameters:
|                  x_calendar_id: calendar id (-1 for BSC calendar)
|
|   Returns:       Return true if the process completres successfully.
|                  Otherwise returns FALSE.
|
+============================================================================*/
FUNCTION Execute_Year_Change_Process (
	x_calendar_id IN NUMBER
	) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Execute_Year_Change_Process_AT(
	x_calendar_id IN NUMBER
	)  RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Exists_Prototype_Indicators
|
|   Description:   This function say if there is any indicator in prototype
|		   mode. In this case Loader cannot continue until Metadata
|		   be run on that indicators.
|
|   Parameters:
|
|   Returns:
|		   Return TRUE if there is any indicator in prototype mode.
|		   Otherwise return FALSE.
|		   If some error occurs return NULL.
|
|   Notes:
|
+============================================================================*/
FUNCTION Exists_Prototype_Indicators RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Flag_Last_Stage_Input_Table
|
|   Description:   This function set the last stage flag of the given input
|                  table of the current process.
|
|   Parameters:	   x_input_table - input table name
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Flag_Last_Stage_Input_Table(
	x_input_table IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Base_Table_Of_Input_Table
|
|   Description:   This function return in the parameter x_base_table
|                  the base table of the input table given in the parameter
|                  x_input_table.
|
|   Parameters:	   x_input_table - input table name
|                  x_base_table  - base table name
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Base_Table_Of_Input_Table(
	x_input_table IN VARCHAR2,
        x_base_table OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_EDW_Dims_In_Input_Tables
|
|   Description:   This function initialize the array x_edw_dim_tables
|                  with the name of the edw dimensions in the input tables
|                  that belong to the current process.
|
|   Parameters:	   x_edw_dim_tables     - array to return the dimension tables
|                  x_num_edw_dim_tables - number of dimension tables in the array
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_EDW_Dims_In_Input_Tables (
	x_edw_dim_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_edw_dim_tables IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Indicators_To_Color
|
|   Description:   This function returns in the array x_color_indicators the
|                  indicators to be colored because some table
|                  that use the indicator was calculated.
|
|   Parameters:	   x_base_tables_to_color - base tables to identify which
|                                           indicators need to be colored
|                  x_num_base_tables_to_color  - number of base tables
|                  x_color_indicators - array where this function put the
|                                       indicator to color
|                  x_num_color_indicators - number of indicators
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Indicators_To_Color(
	x_base_tables_to_color IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_base_tables_to_color IN NUMBER,
        x_color_indicators IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
        x_num_color_indicators IN OUT NOCOPY NUMBER
        ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Last_Stage_Input_Table
|
|   Description:   This function return in the parameter x_last_stage
|                  the last stage of the input table. The last stage has a
|                  flag in the column last_stage_flag of bsc_db_loader_control
|                  table. One input table has only one flagged row.
|
|   Parameters:	   x_input_table - input table name
|                  x_last_stage - last stage of the input table. If the input
|                                 table still doesn't have last stage then
|                                 the function set it to '?'.
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Last_Stage_Input_Table(
	x_input_table IN VARCHAR2,
        x_last_stage OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Process_Id
|
|   Description:   This function returns the process id to be executed.
|                  If the porcess identified by x_process_id has pending status
|                  then this is the process to be executed. Otherwise, this function
|                  creates a new process with the same configuration of the given one
|                  (example, same input tables, or same kpis to be deleted)
|
|		   If the given process does not exists then retunrns -1.
|
|   Parameters:	   x_process_id   - Process id
|                  x_process_name - Process name
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return NULL. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Process_Id (
	x_process_id IN NUMBER,
	x_process_name IN VARCHAR2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Process_Input_Tables
|
|   Description:   This function initialize the array x_input_tables
|                  with the name of the input tables that belong to the
|                  current process and its status is the given in the
|                  parameter x_status.
|                  (see bsc_db_loader_control)
|
|   Parameters:	   x_input_tables     - array to return the input tables
|                  x_num_input_tables - number of input tables returned
|                  x_status - status
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Process_Input_Tables (
	x_input_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_input_tables IN OUT NOCOPY NUMBER,
        x_status IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Init_Env_Values
|
|   Description:   This function get the session id, user id and schema name
|                  in the global variables g_session_id, g_user_id and
|                  g_schema_name.
|
|   Returns: 	   If any error occurs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE.
|
|   Notes:
|
+============================================================================*/
FUNCTION Init_Env_Values RETURN BOOLEAN;



/*===========================================================================+
|
|   Name:          Import_ITables_From_DBSrc
|
|   Description:   This function import data into input tables from database
|                  sources (i.e stored procedures)
|
|   Returns: 	   If any error occurs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE.
|
|   Notes:
|
+============================================================================*/
FUNCTION Import_ITables_From_DBSrc(
	x_input_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_input_tables IN NUMBER
	) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Import_ITables_From_DBSrc_AT(
	x_input_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_input_tables IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Import_ITable_StoredProc
|
|   Description:   This function import data into the input table from a
|                  stored procedure.
|
|   Returns: 	   If any error occurs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE.
|
|   Notes:
|
+============================================================================*/
FUNCTION Import_ITable_StoredProc(
	x_input_table IN VARCHAR2,
	x_stored_proc IN VARCHAR2
	) RETURN BOOLEAN;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Import_ITable_StoredProc_AT
+============================================================================*/
FUNCTION Import_ITable_StoredProc_AT(
	x_input_table IN VARCHAR2,
	x_stored_proc IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Insert_Affected_Tables
|
|   Description:   This recursive function insert into the array
|                  x_affected_tables the tables in the graph that are
|                  affected by tables in the array x_tables.
|
|   Parameters:    x_tables -array of table names
|                  x_num_tables -number of tables
|                  x_affected_tables - array to add the affected tables
|                  x_num_affected_tables - number of tables
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|   Notes:
|
+============================================================================*/
FUNCTION Insert_Affected_Tables (
	x_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_tables IN NUMBER,
        x_affected_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_affected_tables IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Load_Dim_Input_Tables
|
|   Description:   This function loads data into dimension tables from the
|                  input tables given in the array
|
|   Parameters:	   x_input_tables     - array of input tables to be processed
|                  x_num_input_tables - number of input tables
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Load_Dim_Input_Tables(
	x_input_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_input_tables IN NUMBER
	) RETURN BOOLEAN;


--AW_INTEGRATION: New function
/*===========================================================================+
|
|   Name:          Load_Dims_Into_AW
|
|   Description:   This function loads the given dimensions into AW
|                  It does in a proper oder parents first then the childs.
|
+============================================================================*/
FUNCTION Load_Dims_Into_AW(
    x_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_dim_tables IN NUMBER
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Process_Input_Tables
|
|   Description:   This function runs the input tables update process.
|                  This function process the input tables in the array
|                  x_input_tables.
|
|   Parameters:	   x_input_tables     - array of input tables to be processed
|                  x_num_input_tables - number of input tables
|                  x_start_from        - 0 The process starts from input
|                                       tables. This means that the program
|                                       takes input tables, make codes
|                                       validation, updates base tables, etc.
|                                     - 1 The process starts from system tables.
|                                       input tables given in the array already
|                                       are updated and the process starts
|                                       calculating the system tables affected
|                                       by those input tables.
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Process_Input_Tables(
	x_input_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_input_tables IN NUMBER,
	x_start_from IN NUMBER
	) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Process_Input_Tables_AT(
	x_input_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_input_tables IN NUMBER,
	x_start_from IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Refresh_System_MVs
|
|   Description:   Refresh the materialized views in the system that depends
|                  on the given base tables. It has to do it in the right order
|
|                  In case of error returns FALSE the error messase.
|
|   Notes:
|
+============================================================================*/
FUNCTION Refresh_System_MVs(
    p_base_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    p_num_base_tables IN NUMBER
) RETURN BOOLEAN;

FUNCTION Refresh_System_MVs_Mig(
    p_base_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    p_num_base_tables IN NUMBER
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Run_Concurrent_Loader
|
|   Description:   This procedure is to run the loader as a concurrent
|                  program from VB tools
|
|   Parameters:    ERRBUF	This is a required argument. It is used
|                               to return any error message.
|                  RETCODE	This is a required argument. It is used
|                               to return completion status: 0 for success
|                               1 for success with warnings and 2 for error.
|                               After the concurrent program runs, the
|                               concurrent manager writes the contents of both
|                               ERRBUF and RETCODE to the log file associated
|                               with the concurrent request.
|                  x_process_id   - Process id
|                  x_process_name - Process name: 'L' - Load input tables
|                                                 'Y' - Year change process
|                                                 'D' - Delete kpis data
|                                                 'I' - Incremental
|                  x_parameter_1 - Defaults to NULL. Applies only for delete
|                                  kpis data process. In this case this
|                                  parameter contains a list of kpi codes
|                                  that are the indicators whose data is
|                                  going to be deleted.
|
|   Note: For Standard Request Submission we only allow to pass x_process_name = 'L'
|         and x_parameter_1 = NULL (Use Run_Concurrent_Loader_Apps)
|
+============================================================================*/
PROCEDURE Run_Concurrent_Loader (
        ERRBUF OUT NOCOPY VARCHAR2,
	RETCODE OUT NOCOPY VARCHAR2,
        x_process_id IN VARCHAR2,
	x_process_name IN VARCHAR2,
	x_parameter_1 IN VARCHAR2
	);


/*===========================================================================+
|
|   Name:          Run_Concurrent_Loader_Apps
|
|   Description:   This procedure is to run the loader as a concurrent
|                  program from standard request submission
|
|   Parameters:    ERRBUF	This is a required argument. It is used
|                               to return any error message.
|                  RETCODE	This is a required argument. It is used
|                               to return completion status: 0 for success
|                               1 for success with warnings and 2 for error.
|                               After the concurrent program runs, the
|                               concurrent manager writes the contents of both
|                               ERRBUF and RETCODE to the log file associated
|                               with the concurrent request.
|		   x_process_id Process Id
|
|   Note: For Standard Request Submission we only allow to pass x_process_name = 'L'
|         and x_parameter_1 = NULL
|
+============================================================================*/
PROCEDURE Run_Concurrent_Loader_Apps (
        ERRBUF OUT NOCOPY VARCHAR2,
	RETCODE OUT NOCOPY VARCHAR2,
        x_process_id IN VARCHAR2
	);
 PROCEDURE Run_Concurrent_Loader_Apps (
        ERRBUF OUT NOCOPY VARCHAR2,
	RETCODE OUT NOCOPY VARCHAR2,
        x_process_id IN VARCHAR2,
        x_load_dim_affected_indicators varchar2
	);

/*===========================================================================+
|
|   Name:          Run_Concurrent_Loader_Dim_Apps
|
|   Description:   This procedure is to run the loader of dimension tables
|                  as a concurrent program from standard request submission
|
|   Parameters:    ERRBUF	This is a required argument. It is used
|                               to return any error message.
|                  RETCODE	This is a required argument. It is used
|                               to return completion status: 0 for success
|                               1 for success with warnings and 2 for error.
|                               After the concurrent program runs, the
|                               concurrent manager writes the contents of both
|                               ERRBUF and RETCODE to the log file associated
|                               with the concurrent request.
|		   x_process_id Process Id
|
+============================================================================*/
PROCEDURE Run_Concurrent_Loader_Dim_Apps (
        ERRBUF OUT NOCOPY VARCHAR2,
	RETCODE OUT NOCOPY VARCHAR2,
        x_process_id IN VARCHAR2
	);

/*===========================================================================+
|
|   Name:          Run_change_current_year
|
|   Description:   This procedure is to run the change current year process
|
|   Parameters:    ERRBUF	This is a required argument. It is used
|                               to return any error message.
|                  RETCODE	This is a required argument. It is used
|                               to return completion status: 0 for success
|                               1 for success with warnings and 2 for error.
|                               After the concurrent program runs, the
|                               concurrent manager writes the contents of both
|                               ERRBUF and RETCODE to the log file associated
|                               with the concurrent request.
|      This is the new procedure to change current year
|      This is same as calling Submit Request to Load Input Tables (VB) (Flag = Y)
|      This is for new OA UI. this api in contrast to
|      Submit Request to Load Input Tables (VB) (Flag = Y)
|      will acquire lock. Submit Request to Load Input Tables (VB) (Flag = Y)  is launched from VB
|      where the lock is already there with VB
|	   x_process_id Process Id
|
+============================================================================*/
/*

*/
PROCEDURE Run_change_current_year (
ERRBUF OUT NOCOPY VARCHAR2,
RETCODE OUT NOCOPY VARCHAR2,
x_process_id IN VARCHAR2,
x_calendars IN VARCHAR2
);

/*===========================================================================+
|
|   Name:          Load_Indicators_Data
|
|   Description:   This procedure is to run the loader for the input
|                  tables used by the given indicators.
|
|   Parameters:    ERRBUF	This is a required argument. It is used
|                               to return any error message.
|                  RETCODE	This is a required argument. It is used
|                               to return completion status: 0 for success
|                               1 for success with warnings and 2 for error.
|                               After the concurrent program runs, the
|                               concurrent manager writes the contents of both
|                               ERRBUF and RETCODE to the log file associated
|                               with the concurrent request.
|		   x_indicators List of indicators. Example: 3001,3002,3004
|
+============================================================================*/
PROCEDURE Load_Indicators_Data (
        ERRBUF OUT NOCOPY VARCHAR2,
	RETCODE OUT NOCOPY VARCHAR2,
        x_indicators IN VARCHAR2,
        x_load_affected_indicators varchar2
	);



/*===========================================================================+
|
|   Name:          Load_Indicators_Dims
|
|   Description:   This procedure is to run the loader for the input
|                  tables for dimensions used by the given indicators.
|
|   Parameters:    ERRBUF	This is a required argument. It is used
|                               to return any error message.
|                  RETCODE	This is a required argument. It is used
|                               to return completion status: 0 for success
|                               1 for success with warnings and 2 for error.
|                               After the concurrent program runs, the
|                               concurrent manager writes the contents of both
|                               ERRBUF and RETCODE to the log file associated
|                               with the concurrent request.
|		   x_indicators List of indicators. Example: 3001,3002,3004
|
+============================================================================*/
PROCEDURE Load_Indicators_Dims (
        ERRBUF OUT NOCOPY VARCHAR2,
	RETCODE OUT NOCOPY VARCHAR2,
        x_indicators IN VARCHAR2,
        x_load_dim_affected_indicators varchar2
	);


/*===========================================================================+
|
|   Name:          Delete_Indicators_Data
|
|   Description:   This procedure is to run the loader to delete the data
|                  of the given indicators.
|
|   Parameters:    ERRBUF	This is a required argument. It is used
|                               to return any error message.
|                  RETCODE	This is a required argument. It is used
|                               to return completion status: 0 for success
|                               1 for success with warnings and 2 for error.
|                               After the concurrent program runs, the
|                               concurrent manager writes the contents of both
|                               ERRBUF and RETCODE to the log file associated
|                               with the concurrent request.
|		   x_indicators List of indicators. Example: 3001,3002,3004
|
+============================================================================*/
PROCEDURE Delete_Indicators_Data (
        ERRBUF OUT NOCOPY VARCHAR2,
	RETCODE OUT NOCOPY VARCHAR2,
        x_indicators IN VARCHAR2,
        x_keep_input_table_data IN VARCHAR2
	);


/*===========================================================================+
|
|   Name:          Get_Input_Tables_Kpis
|
|   Description:   This procedure returns in the array x_input_tables
|                  the input tables used by the indicators given in the
|                  array x_indicators
|
+============================================================================*/
FUNCTION Get_Input_Tables_Kpis(
	x_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_indicators IN NUMBER,
        x_input_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_input_tables IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Dim_Input_Tables_Kpis
|
|   Description:   This procedure returns in the array x_input_tables
|                  the dimension input tables used by the indicators given
|                  in the array x_indicators
|
+============================================================================*/
FUNCTION Get_Dim_Input_Tables_Kpis(
	x_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_indicators IN NUMBER,
        x_input_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_input_tables IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Set_PStatus_Finished
|
|   Description:   This function set the status of the current process to
|                  the given status. Additionally, set the end time to SYSDATE.
|
|   Parameters:	   x_status 	- status
|
|   Returns: 	   If any error occurs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Set_PStatus_Finished(
	x_status IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Set_PStatus_Running
|
|   Description:   This function set the status of the current process to
|		   - Running - and update the field LOG_FILE_LOCATION with
|		   the complete name of the log file. Additionally, set the
|		   start time to SYSDATE.
|
|   Parameters:
|
|   Returns: 	   If any error occurs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Set_PStatus_Running RETURN BOOLEAN;


--LOCKING: new function
FUNCTION Update_Indicator_Period (
    x_indicator IN NUMBER
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Update_Indicators_Periods
|
|   Description:   This function update the current period of all indicators
|                  The current period of an indicator is the minimun current
|                  period of the tables used by the indicator.
|
|   Parameters:
|
|   Returns: 	   If any error occurs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Update_Indicators_Periods RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Update_Stage_Input_Table
|
|   Description:   This function set the stage of input table of the
|                  current process to x_target_stage.
|
|   Parameters:	   x_input_table   - input table name
|                  x_target_stage  - target stage
|
|   Returns: 	   If any error occurs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Update_Stage_Input_Table(
	x_input_table IN VARCHAR2,
        x_target_stage IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Update_Stage_Input_Tables
|
|   Description:   This function set the stage of input tables of the
|                  current process whose current status is x_current_status
|                  to x_target_stage. Additionally, if the parameter
|                  x_last_stage_flag is TRUE, set the last stage flag to 1.
|
|   Parameters:	   x_current_status - current status
|                  x_target_stage  - target stage
|                  x_last_stage_flag - indicates of the new stage is going
|                                      to be the last stage
|
|   Returns: 	   If any error occurs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Update_Stage_Input_Tables(
	x_current_status IN VARCHAR2,
	x_target_stage IN VARCHAR2,
	x_last_stage_flag IN BOOLEAN
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Update_Status_All_Input_Tables
|
|   Description:   This function set the status of all input tables of the
|                  current process whose current status is x_current_status
|                  to x_target_status. Additionally set the error code to
|                  x_error_code if it is provided.
|
|   Parameters:	   x_current_status   - current status
|                  x_target_status - target status
|                  x_error_code - error code
|
|   Returns: 	   If any error occurs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Update_Status_All_Input_Tables(
	x_current_status IN VARCHAR2,
	x_target_status IN VARCHAR2,
	x_error_code IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Update_Status_Input_Table
|
|   Description:   This function set the status of input table of the
|                  current process to x_target_status. Additionally set the
|                  error code to x_error_code if it is provided.
|
|   Parameters:	   x_input_table   - input table
|                  x_target_status - target status
|                  x_error_code - error code
|
|   Returns: 	   If any error occurs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Update_Status_Input_Table(
	x_input_table IN VARCHAR2,
        x_target_status IN VARCHAR2,
	x_error_code IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Write_Result_Log
|
|   Description:   This function write the result of the update input tables
|                  process into the log file. This includes status of each
|                  input table, invalid codes and new current periods
|
|   Returns: 	   If any error occurs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Write_Result_Log RETURN BOOLEAN;

/*===========================================================================+
| FUNCTION Wait_For_Requests
+============================================================================*/
FUNCTION Wait_For_Requests(
    x_requests IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_requests IN NUMBER
) RETURN BOOLEAN;

function get_kpi_for_input_tables(
x_input_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
x_num_input_tables IN NUMBER,
x_indicators IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
x_num_indicators IN OUT NOCOPY NUMBER
)return boolean;

function get_kpi_for_input_tables(
x_input_table varchar2,
x_indicators IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
x_num_indicators IN OUT NOCOPY NUMBER
)return boolean;

function value_in_array(
x_value number,
x_array BSC_UPDATE_UTIL.t_array_of_number,
x_num_array NUMBER
)return boolean;

/*===========================================================================+
| FUNCTION Get_Indicator_List
+============================================================================*/
function Get_Indicator_List(
x_number_array IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number
)return number;

--Fix bug#4681065
PROCEDURE Write_Warning_Kpis_In_Prot (
    x_system_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_system_tables IN NUMBER
);

END BSC_UPDATE;

 

/
