--------------------------------------------------------
--  DDL for Package BSC_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: BSCSMIGS.pls 120.13 2007/05/10 07:38:34 amitgupt ship $ */


C_BSC_APP_ID            CONSTANT NUMBER      := 271;

-- Global types
TYPE r_metadata_table IS RECORD (
    table_name VARCHAR2(30),
    level NUMBER,     -- 0:System level,
                            -- 1:Tab level,
                            -- 2:KPI level,
                            -- 3:Table Level (Back end)
    level_column VARCHAR2(30),    -- Example. INDICATOR, TAB_ID, etc
    level_condition VARCHAR2(200),  -- Some metadata tables has records for more than one level
                                -- example: Source_type = 1 means Tab level and source_type = 2
                                -- means KPI level. In this property you have the condition
                                -- to identify the level.
    copy_flag BOOLEAN,      -- True: Copy data to target
                            -- False: No copy data to target
    lang_flag BOOLEAN                   -- True: Language table (Generally are _TL tables)
                                        -- False: No language table
);

TYPE t_metadata_tables IS TABLE OF r_metadata_table
    INDEX BY BINARY_INTEGER;

TYPE t_array_of_number IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

TYPE t_array_of_varchar2 IS TABLE OF VARCHAR2(500)
    INDEX BY BINARY_INTEGER;

-- Global variables
g_debug_flag VARCHAR2(3) := 'NO';
g_db_link VARCHAR2(100);

-- Procedure and functions

/*===========================================================================+
|
|   Name:          Assign_Target_Responsibilities
|
|   Description:   This procedure assign the tabs and kpis to the target
|                  reponsibilities according to the source responsibilities.
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return FALSE. Otherwise return
|      TRUE.
|
+============================================================================*/
FUNCTION Assign_Target_Responsibilities RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Check_Languages_TL_Tables
|
|   Description:   Fix _TL tables according to supported languages in target system
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return FALSE. Otherwise return
|      TRUE.
|
+============================================================================*/
FUNCTION Check_Languages_TL_Tables RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Clean_Metadata_Invalid_PMF
|
|   Description:   Delete from BSC system level metadata the rows for PMF
|                  measures, dimensions and dimension levels that do not
|                  exist in the target system. Those objects are already
|                  loaded in the arrays g_invalid_pmf_measures,
|                  g_invalid_pmf_dimensions and g_invalid_pmf_dim_levels.
||
+============================================================================*/
PROCEDURE Clean_Metadata_Invalid_PMF;


/*===========================================================================+
|
|   Name:          Create_Copy_Of_Table_Def
|
|   Description:   This procedure creates a copy of table definition
|                  of given table. The given table is in the source system.
|
|   Parameters:
|                  x_table    Table name
|                  x_tbs_type           Tablespace type. This is to create
|                                       the table in the right tablespace
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return FALSE. Otherwise return
|      TRUE.
|
+============================================================================*/
FUNCTION Create_Copy_Of_Table_Def(
  x_table IN VARCHAR2,
        x_tbs_type IN VARCHAR2
  ) RETURN BOOLEAN;

-- ENH_B_TABLES_PERF: new fuction
FUNCTION Create_Copy_Of_Table_Def(
  x_table IN VARCHAR2,
        x_tbs_type IN VARCHAR2,
        x_with_partitions IN BOOLEAN
  ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Create_Copy_Of_View_Def
|
|   Description:   This procedure creates a copy of view definition
|                  of given view. The given view is in the source system.
|
|   Parameters:    x_view   View name
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return FALSE. Otherwise return
|      TRUE.
|
+============================================================================*/
FUNCTION Create_Copy_Of_View_Def(
  x_view IN VARCHAR2,
  x_replace IN BOOLEAN := TRUE
  ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Create_Dynamic_Objects
|
|   Description:   This function creates all required dynamic objects in the
|                  target system (current schema).
|                  Dynamyc objects are:
|                      - Dimension tables
|                      - Dimension filter views
|                      - Input, base, system tables.
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return FALSE. Otherwise return
|      TRUE.
|
+============================================================================*/
FUNCTION Create_Dynamic_Objects RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Create_Indexes_Dynamic_Tables
|
|   Description:   This function creates all indexes on the dynamic tables.
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return FALSE. Otherwise return
|      TRUE.
|
+============================================================================*/
FUNCTION Create_Indexes_Dynamic_Tables RETURN BOOLEAN;


-- Fix performance bug#3860149: analyze base and dimension tables
/*===========================================================================+
|
|   Name:          Analyze_Base_And_Dim_Tables
|
|   Description:   This function analyzes base and dimension tables
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return FALSE. Otherwise return
|      TRUE.
|
+============================================================================*/
FUNCTION Analyze_Base_And_Dim_Tables RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Create_Table_Indexes
|
|   Description:   This function creates on the given table the same indexes
|                  that already exist on the table in the source system
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return FALSE. Otherwise return
|      TRUE.
|
+============================================================================*/
FUNCTION Create_Table_Indexes(
  x_table IN VARCHAR2,
        x_tbs_type IN VARCHAR2
  ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Decompose_Numeric_List
|
|   Description:   This function decompose a string into a number array and
|                  returns the number of items in the array.
|
|                  Example:
|                  If x_string = '3001, 3002, 3003' and x_separator = ','
|                  then x_number_array = 3001|3002|3003 and retunrs 3
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return -1.
|
|
+============================================================================*/
FUNCTION Decompose_Numeric_List(
  x_string IN VARCHAR2,
  x_number_array IN OUT NOCOPY t_array_of_number,
        x_separator IN VARCHAR2
  ) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Delete_Metadata_Tables
|
|   Description:   This function del;ete all record from metadata tables.
|                  The metadata tables are in the global array g_metadata_tables
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return FALSE. Otherwise return
|      TRUE.
|
+============================================================================*/
FUNCTION Delete_Metadata_Tables RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Drop_Dynamic_Objects
|
|   Description:   This function drop all dynamic objects existing in the
|                  target system (current schema).
|                  Dynamyc objects are:
|                      - Dimension tables
|                      - Dimension filter views
|                      - Input, base, system tables.
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return FALSE. Otherwise return
|      TRUE.
|
+============================================================================*/
FUNCTION Drop_Dynamic_Objects RETURN BOOLEAN;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Lock_Migration
+============================================================================*/
FUNCTION Lock_Migration (
    x_process_id IN NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Execute_Migration
|
|   Description:   This procedure is to run migration process as concurrent
|                  program.
|
|   Parameters:    ERRBUF This is a required argument. It is used
|                               to return any error message.
|                  RETCODE  This is a required argument. It is used
|                               to return completion status: 0 for success
|                               1 for success with warnings and 2 for error.
|                               After the concurrent program runs, the
|                               concurrent manager writes the contents of both
|                               ERRBUF and RETCODE to the log file associated
|                               with the concurrent request.
|                  Others parameter are the parameters for Migrate_System
|
+============================================================================*/
PROCEDURE Execute_Migration (
        ERRBUF OUT NOCOPY VARCHAR2,
  RETCODE OUT NOCOPY VARCHAR2,
  x_src_responsibilities IN VARCHAR2,
        x_trg_responsibilities IN VARCHAR2,
  x_tab_filter IN VARCHAR2,
  x_kpi_filter IN VARCHAR2,
        x_overwrite IN VARCHAR2
  );


/*===========================================================================+
|
|   Name:          Get_Lst_Table_Columns
|
|   Description:   This function returns the list of columns of the given table
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return FALSE. Otherwise return
|      TRUE.
|
+============================================================================*/
FUNCTION Get_Lst_Table_Columns(
  x_table IN VARCHAR2
  ) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_Migration_Parameters
|
|   Description:   Get the migration parameters from BSC_DB_LOADER_CONTROL table
|
+============================================================================*/
PROCEDURE Get_Migration_Parameters(
        p_process_id IN VARCHAR2,
        x_src_responsibilities IN OUT NOCOPY VARCHAR2,
        x_trg_responsibilities IN OUT NOCOPY VARCHAR2,
        x_tab_filter IN OUT NOCOPY VARCHAR2,
        x_kpi_filter IN OUT NOCOPY VARCHAR2,
        x_overwrite IN OUT NOCOPY VARCHAR2,
        x_adv_mig_features IN OUT NOCOPY VARCHAR2,
        x_db_link IN OUT NOCOPY VARCHAR2
      );


/*===========================================================================+
|
|   Name:          Init_Invalid_PMF_Objects
|
|   Description:   Initialize the arrays g_invalid_pmf_measures,
|                  g_invalid_pmd_dimensions, g_invalid_pmf_dim_levels
|                  with the pmf objects used in the source but do not exist
|                  in the target.
|                  Also init the array g_invalid_kpis with the kpis
|                  using any of those invalid pmf objects.
|                  Those kpis are not migrated.
|
+============================================================================*/
PROCEDURE Init_Invalid_PMF_Objects;


/*===========================================================================+
|
|   Name:          Init_Metadata_Tables_Array
|
|   Description:   This procedure initialize the array of metadata tables
|                  (system, tab and kpis level tables)
|
+============================================================================*/
PROCEDURE Init_Metadata_Tables_Array;


/*===========================================================================+
|
|   Name:          Init_Migration_Objects_Arrays
|
|   Description:   This procedure initialize the global arrays g_mig_tabs,
|                  g_mig_kpis and g_mig_tables which contains the tabs, kpis
|                  and tables to be migrated according to the source
|                  responsibilities and tab and kpi filters
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return FALSE. Otherwise return
|      TRUE.
|
+============================================================================*/
FUNCTION Init_Migration_Objects_Arrays RETURN BOOLEAN;



/*===========================================================================+
|
|   Name:          Insert_Origin_Tables
|
|   Description:   This procedure insert into the global array g_mig_tables
|                  the origin tables of the given tables. This recursive
|                  procedure insert all the tables used by the kpis from the
|                  systenm tables to the input tables.
|
|   Parameters:    x_tables       System tables
|                  x_num_tables   Number of system tables
|
+============================================================================*/
PROCEDURE Insert_Origin_Tables(
  x_tables IN t_array_of_varchar2,
  x_num_tables IN NUMBER
  );


/*===========================================================================+
|
|   Name:          Item_Belong_To_Array_Number
|
|   Description:   This function says if a item belong to an array
|
|   Parameters:    x_item   - item name
|                  x_array  - array
|                  x_num_items  - number of item in the array
|
|   Returns:     Return TRUE if the item belong to the array. Otherwise
|                  return FALSE.
|
|   Notes:
|
+============================================================================*/
FUNCTION Item_Belong_To_Array_Number(
  x_item IN NUMBER,
  x_array IN t_array_of_number,
  x_num_items IN NUMBER
  ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Is_Base_Table
|
|   Description:   Returns TRUE is the table is a base table.
|
+============================================================================*/
FUNCTION Is_Base_Table(
  x_table_name IN VARCHAR2
  ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Is_Input_Table
|
|   Description:   Returns TRUE is the table is an input table.
|
+============================================================================*/
FUNCTION Is_Input_Table(
  x_table_name IN VARCHAR2
  ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Item_Belong_To_Array_Varchar2
|
|   Description:   This function says if a item belong to an array
|
|   Parameters:    x_item   - item name
|                  x_array  - array
|                  x_num_items  - number of item in the array
|
|   Returns:     Return TRUE if the item belong to the array. Otherwise
|                  return FALSE.
|
|   Notes:
|
+============================================================================*/
FUNCTION Item_Belong_To_Array_Varchar2(
  x_item IN VARCHAR2,
  x_array IN t_array_of_varchar2,
  x_num_items IN NUMBER
  ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Make_Lst_Cond_Number
|
|   Description:   This function returns a list with the condition:
|                  Example
|                         x_column = column
|                         x_values = val1|val2|val3
|                         x_separator = 'OR'
|
|                         list = column = val1 OR column = val2 OR column = val3
|
|   Notes:
|
+============================================================================*/
FUNCTION Make_Lst_Cond_Number(
  x_column IN VARCHAR2,
  x_values IN t_array_of_number,
        x_num_values IN NUMBER,
        x_separator IN VARCHAR2
  ) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Make_Lst_Cond_Varchar2
|
|   Description:   This function returns a list with the condition:
|                  Example
|                         x_column = column
|                         x_values = val1|val2|val3
|                         x_separator = 'OR'
|
|                         list = UPPER(column) = 'VAL1' OR UPPER(column) =
|                                'VAL2' OR UPPER(column) = 'VAL3'
|
|   Notes:
|
+============================================================================*/
FUNCTION Make_Lst_Cond_Varchar2(
  x_column IN VARCHAR2,
  x_values IN t_array_of_varchar2,
        x_num_values IN NUMBER,
        x_separator IN VARCHAR2
  ) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Migrate_Dynamic_Tables_Data
|
|   Description:   This function migrate data in dynamic tables from source
|                  system to the target system.
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return FALSE. Otherwise return
|      TRUE.
|
+============================================================================*/
FUNCTION Migrate_Dynamic_Tables_Data RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Migrate_Metadata
|
|   Description:   This function migrate metadata tables from source system
|                  to the target system.
|
|   Returns:     If any error ocurrs, this function add the error message
|      to the error stack and return FALSE. Otherwise return
|      TRUE.
|
+============================================================================*/
FUNCTION Migrate_Metadata RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Migrate_System
|
|   Description:   This procedure migrate the data for the KPIs in a source
|                  system to the target system. This procedure is call from
|                  the target system.
|
|
|   Parameters:    x_src_responsibilities Responsibilities (responsibility id)
|           in the source system. The KPIs
|                                               accessible by those responsibilities
|                                               are migrated. Use a colon-sperator
|                                               list to specify more than one
|           responsibility. Example: '1001, 1003'
|
|                  x_trg_responsibilities Per each source responsibility specified
|             in the previous parameter, the user
|                                               need to specify the corresponding
|           target responsibility.
|
|      x_tab_filter   In this parameter the user provide a subset of
|                                       Tabs accessible by source responsibilities and
|                                       only those Tabs are migrated to the target system.
|                                       If this parameter is NULL, all Tabs accessible by
|                                       source responsibilities are migrated.
|
|      x_kpi_filter   In this parameter the user provide a subset of
|                                       KPIs accessible by source responsibilities and
|                                       only those KPIs are migrated to the target system.
|                                       If this parameter is NULL, all KPIs accessible by
|                                       source responsibilities are migrated.
|
|                  x_overwrite    Defaults to 'N'. The user must pass 'Y' in order
|                                       to the migration program can overwrite the target
|                                       system.
|
|
|   Notes: If this procedure run on Non-Enterprise version, the log file is bscmig40.log
|          and is located in the common output directoy defined in the variable UTL_FILE_DIR
|          of orainit file.
|
|          In APPS this procedure run as a concurrent program. Concurrent manager writes
|          the log and output files. The user an see them using standard forms.
|
+============================================================================*/
PROCEDURE Migrate_System(
  x_src_responsibilities IN VARCHAR2,
        x_trg_responsibilities IN VARCHAR2,
  x_tab_filter IN VARCHAR2 := NULL,
  x_kpi_filter IN VARCHAR2 := NULL,
        x_overwrite IN VARCHAR2 := 'N'
  );
PROCEDURE Migrate_System_AT(
  x_src_responsibilities IN VARCHAR2,
        x_trg_responsibilities IN VARCHAR2,
  x_tab_filter IN VARCHAR2 := NULL,
  x_kpi_filter IN VARCHAR2 := NULL,
        x_overwrite IN VARCHAR2 := 'N'
  );


-- Enh#4697749
FUNCTION Remove_Custom_Dim_Objs_In_PMF RETURN BOOLEAN;

-- Enh#4697749
FUNCTION Remove_Custom_Dims_In_PMF RETURN BOOLEAN;

-- Enh#4697749
FUNCTION Remove_Custom_Measures_In_PMF RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Update_BSC_Dimensions_In_PMF
|
|   Description:   Updates description field in bis_dimensions with value
|                  from the source system. ONLY FOR BSC DIMENSIONS.
|
|   Returns:     If there is a validation error, it returns FALSE. Otherwise,
|                  returns TRUE.
|
+============================================================================*/
FUNCTION Update_BSC_Dimensions_In_PMF RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Validate_Filters
|
|   Description:   This function validate that the tabs and kpis filter
|                  have been provided in the proper format.
|                  Also, verify the kpis and tabs in hte filters being
|                  accessible by the source responsibilities.
|
|   Parameters:    x_tab_filter     Tab filter
|      x_kpi_filter     KPI filter
|                  x_validation_error   In this parameter returns the
|           validation error message.
|
|   Returns:     If there is a validation error, it returns FALSE. Otherwise,
|                  returns TRUE.
|
+============================================================================*/
FUNCTION Validate_Filters(
  x_tab_filter IN VARCHAR2,
        x_kpi_filter IN VARCHAR2,
  x_validation_error OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Validate_Responsibilities
|
|   Description:   This function validate that the source and target
|                  responsibilities have been provided in the proper format.
|                  Also, verify the the responsibilities existing in the
|                  corresponding system.
|                  Addionally, initialize the global arrays g_src_resps and
|                  g_trg_resps.
|
|   Parameters:    x_src_responsibilities Source responsibilities
|      x_trg_responsibilities Target responsibilities
|                  x_validation_error   In this parameter returns the
|           validation error message.
|
|   Returns:     If there is a validation error, it returns FALSE. Otherwise,
|                  returns TRUE.
|
+============================================================================*/
FUNCTION Validate_Responsibilities(
  x_src_responsibilities IN VARCHAR2,
        x_trg_responsibilities IN VARCHAR2,
  x_validation_error OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Validate_System_Versions
|
|   Description:   This function validate that the source and target systems
|                  are upgraded to the version in the global constant c_version.
|
|   Parameters:    x_validation_error In this parameter return the validatioon
|                                       error message.
|
|   Returns:     If there is a validation error, it returns FALSE. Otherwise,
|                  returns TRUE.
|
+============================================================================*/
FUNCTION Validate_System_Versions(
  x_validation_error OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Validate_Tables
|
|   Description:   This function validates that the tables that are going to
|                  be migrated exists in the source system.
|                  If a table does not exists then it write a message in the
|                  log file with the list of tables and affected indicators
|                  and returns false.
+============================================================================*/
FUNCTION Validate_Tables RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Exist_Table_In_Src
|
|   Description:   This function returns TRUE if the table exists in the source.
|
+============================================================================*/
FUNCTION Exist_Table_In_Src(
    x_table_name IN VARCHAR2
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Table_Generation_Type_Src
|
|   Description:   Get table generation type from bsc_db_tables in the
|                  source system
|
+============================================================================*/
FUNCTION Get_Table_Generation_Type_Src(
  x_table_name IN VARCHAR2
  ) RETURN NUMBER;


--Fix bug#4220506
PROCEDURE Write_Log_Invalid_PMF_Objects;

--Enh#4262583 migrate non-preseeded pmf objects
PROCEDURE Migrate_Custom_PMF_Dimensions;
PROCEDURE Migrate_Custom_PMF_Dim_Levels;
PROCEDURE Migrate_Custom_PMF_Measures;

PROCEDURE Retrieve_Dimension
( p_dimension_short_name IN VARCHAR2
, x_dimension_name OUT NOCOPY VARCHAR2
, x_description OUT NOCOPY VARCHAR2
, x_hide        OUT NOCOPY VARCHAR2
, x_application_id OUT NOCOPY NUMBER
, x_return_status OUT NOCOPY VARCHAR2
, x_error_msg OUT NOCOPY VARCHAR2
);
PROCEDURE Retrieve_Dimension_Level
( p_dimension_level_short_name IN VARCHAR2
, x_dimension_short_name OUT NOCOPY VARCHAR2
, x_dimension_name OUT NOCOPY VARCHAR2
, x_dimension_level_name OUT NOCOPY VARCHAR2
, x_description OUT NOCOPY VARCHAR2
, x_hide        OUT NOCOPY VARCHAR2
, x_level_values_view_name OUT NOCOPY VARCHAR2
, x_where_clause OUT NOCOPY VARCHAR2
, x_source OUT NOCOPY VARCHAR2
, x_comparison_label_code OUT NOCOPY VARCHAR2
, x_attribute_code OUT NOCOPY VARCHAR2
, x_application_id OUT NOCOPY NUMBER
, x_default_search OUT NOCOPY VARCHAR2
, x_long_lov OUT NOCOPY VARCHAR2
, x_master_level OUT NOCOPY VARCHAR2
, x_view_object_name OUT NOCOPY VARCHAR2
, x_default_values_api OUT NOCOPY VARCHAR2
, x_enabled OUT NOCOPY VARCHAR2
, x_drill_to_form_function OUT NOCOPY VARCHAR2
, x_primary_dim OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_error_msg OUT NOCOPY VARCHAR2
);
PROCEDURE Retrieve_Measure
( p_measure_short_name IN VARCHAR2
, x_measure_name OUT NOCOPY VARCHAR2
, x_description OUT NOCOPY VARCHAR2
, x_region_app_id OUT NOCOPY NUMBER
, x_source_column_app_id OUT NOCOPY NUMBER
, x_compare_column_app_id OUT NOCOPY NUMBER
, x_actual_data_source_type OUT NOCOPY VARCHAR2
, x_actual_data_source OUT NOCOPY VARCHAR2
, x_function_name OUT NOCOPY VARCHAR2
, x_comparison_source OUT NOCOPY VARCHAR2
, x_increase_in_measure OUT NOCOPY VARCHAR2
, x_enable_link OUT NOCOPY VARCHAR2
, x_enabled OUT NOCOPY VARCHAR2
, x_obsolete OUT NOCOPY VARCHAR2
, x_measure_type OUT NOCOPY VARCHAR2
, x_dimension1_short_name OUT NOCOPY VARCHAR2
, x_dimension1_name OUT NOCOPY VARCHAR2
, x_dimension2_short_name OUT NOCOPY VARCHAR2
, x_dimension2_name OUT NOCOPY VARCHAR2
, x_dimension3_short_name OUT NOCOPY VARCHAR2
, x_dimension3_name OUT NOCOPY VARCHAR2
, x_dimension4_short_name OUT NOCOPY VARCHAR2
, x_dimension4_name OUT NOCOPY VARCHAR2
, x_dimension5_short_name OUT NOCOPY VARCHAR2
, x_dimension5_name OUT NOCOPY VARCHAR2
, x_dimension6_short_name OUT NOCOPY VARCHAR2
, x_dimension6_name OUT NOCOPY VARCHAR2
, x_dimension7_short_name OUT NOCOPY VARCHAR2
, x_dimension7_name OUT NOCOPY VARCHAR2
, x_unit_of_measure_class OUT NOCOPY VARCHAR2
, x_application_id OUT NOCOPY NUMBER
, x_is_validate OUT NOCOPY VARCHAR2
, x_func_area_short_name OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_error_msg OUT NOCOPY VARCHAR2
);

-- ENH_B_TABLES_PERF: new function
FUNCTION Get_RowId_Table_Name (
    x_table_name IN VARCHAR2
) RETURN VARCHAR2;

-- ENH_B_TABLES_PERF: new function
FUNCTION Get_Proj_Table_Name (
    x_table_name IN VARCHAR2
) RETURN VARCHAR2;

-- ENH_B_TABLES_PERF: new function
FUNCTION Get_Num_Partitions (
    x_table_name IN VARCHAR2
) RETURN NUMBER;

-- ENH_B_TABLES_PERF: new function
FUNCTION Migrate_BTable_With_Partitions (
    x_base_table IN VARCHAR2,
    x_proj_table IN VARCHAR2
) RETURN BOOLEAN;

-- Enh#4697749 New procedure
FUNCTION Migrate_AK_Region(
    p_region_code IN VARCHAR2,
    x_error_msg OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

-- Enh#4697749 New procedure
FUNCTION Migrate_Form_Function(
    p_function_name IN VARCHAR2,
    x_error_msg OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

-- Fix bug#4873385
FUNCTION Get_Source_User_Id RETURN NUMBER;



PROCEDURE Migrate_Sim_Data
(
   p_commit             IN    VARCHAR2 := FND_API.G_FALSE
  ,p_Trg_indicator      IN    BSC_KPIS_B.indicator%TYPE
  ,p_Src_indicator      IN    BSC_KPIS_B.indicator%TYPE
  ,p_Region_Code        IN    VARCHAR2
  ,p_Old_Region_Code    IN    BSC_KPIS_B.short_name%TYPE
  ,p_Old_Dim_Levels     IN    FND_TABLE_OF_NUMBER
  ,p_New_Dim_Levels     IN    FND_TABLE_OF_NUMBER
  ,p_Old_Dim_Groups     IN    FND_TABLE_OF_NUMBER
  ,p_New_Dim_Groups     IN    FND_TABLE_OF_NUMBER
  ,p_Old_DataSet_Map    IN    FND_TABLE_OF_NUMBER
  ,p_New_DataSet_Map    IN    FND_TABLE_OF_NUMBER
  ,p_Target_Calendar    IN    NUMBER
  ,p_Old_Periodicities  IN    FND_TABLE_OF_NUMBER
  ,p_New_Periodicities  IN    FND_TABLE_OF_NUMBER
  ,x_return_status  OUT NOCOPY  VARCHAR2
  ,x_msg_count      OUT NOCOPY  NUMBER
  ,x_msg_data       OUT NOCOPY  VARCHAR2
);


END BSC_MIGRATION;

/
