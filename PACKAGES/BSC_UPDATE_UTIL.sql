--------------------------------------------------------
--  DDL for Package BSC_UPDATE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UPDATE_UTIL" AUTHID CURRENT_USER AS
/* $Header: BSCDUTIS.pls 120.6 2007/02/08 09:41:31 ankgoel ship $ */

--  Global constans
G_PKG_NAME CONSTANT VARCHAR2(30) := 'BSC_UPDATE_UTIL';

G_BSC CONSTANT              VARCHAR2(3)     := 'BSC';
G_BIA CONSTANT              VARCHAR2(3)     := 'BIA';
G_PMF CONSTANT              VARCHAR2(3)     := 'PMF';
G_PMV CONSTANT              VARCHAR2(3)     := 'PMV';

G_BSC_PATCH  CONSTANT       BSC_SYS_INIT.Property_Code%TYPE    := 'PATCH_NUMBER';
G_BIA_PATCH  CONSTANT       BSC_SYS_INIT.Property_Code%TYPE    := 'BIA_PATCH_NUM';
G_PMF_PATCH  CONSTANT       BSC_SYS_INIT.Property_Code%TYPE    := 'PMF_PATCH_NUM';
G_PMV_PATCH  CONSTANT       BSC_SYS_INIT.Property_Code%TYPE    := 'PMV_PATCH_NUM';

--
-- Global Types
--
TYPE t_array_of_number IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

-- BSC-BIS-DIMENSIONS: Changin the size of this array since key columns could be longer
TYPE t_array_of_varchar2 IS TABLE OF VARCHAR2(4000)
    INDEX BY BINARY_INTEGER;

TYPE t_periodicity_rec IS RECORD (
    calendar_id NUMBER,
    db_column_name VARCHAR2(30),
    edw_flag NUMBER,
    periodicity_type NUMBER,
    yearly_flag NUMBER,
    period_col_name VARCHAR2(15),
    sub_period_col_name	VARCHAR2(15)
);

TYPE t_array_periodicities IS TABLE OF t_periodicity_rec
    INDEX BY BINARY_INTEGER;

TYPE t_calendar_rec IS RECORD (
    edw_flag NUMBER,
    fiscal_year NUMBER,
    source VARCHAR2(10),
    start_year NUMBER,
    start_month NUMBER,
    start_day NUMBER
);

TYPE t_array_calendars IS TABLE OF t_calendar_rec
    INDEX BY BINARY_INTEGER;

TYPE t_periodicity_rel IS RECORD (
    periodicity_id NUMBER,
    source_periodicity_id NUMBER
);

TYPE t_array_periodicity_rels IS TABLE OF t_periodicity_rel
    INDEX BY BINARY_INTEGER;

TYPE t_kpi_rec IS RECORD (
    indicator NUMBER,
    prototype_flag NUMBER
);

TYPE t_array_kpis IS TABLE OF t_kpi_rec
    INDEX BY BINARY_INTEGER;

TYPE t_temp_table_col_rec IS RECORD (
    column_name VARCHAR2(30),
    data_type VARCHAR2(30),
    data_size NUMBER,
    add_to_index VARCHAR2(1)
);

TYPE t_array_temp_table_cols IS TABLE OF t_temp_table_col_rec
    INDEX BY BINARY_INTEGER;

--
-- Global Variables
--

-- G_Disable_Base_Index:
-- Flag to indicate whether to disable basic table index or not upon
-- updating the basic system table from the input table.  If this option
-- is set to YES, index on the basic table primary key will be disabled
-- before bulk insert/update operations are performed on the basic
-- table.  Disabling the index improves the speed of record insertion,
-- but not the update operations.  Index will be enabled again after
-- the bulk insert/update operations are completed.  Once this flag is set
-- to YES, all the basic table indexes will be disabled before the
-- insert/update operations and re-enabled after the SQL operations,
-- until the flag is explicitly set back to NO.  If the flag value is set
-- to NO, index is not disabled nor enabled.  By default, the flag is
-- set to YES to improve performance of insertion.

/* Now in the client side.
G_Disable_Base_Index    VARCHAR2(3) := 'NO';
*/

g_array_periodicities t_array_periodicities;
g_array_calendars t_array_calendars;
g_array_periodicity_rels t_array_periodicity_rels;

-- G_Current_Fiscal_Yr:
-- Current fiscal year.  This variable corresponds to the global variable,
-- Ano_Act in the Visual Basic Update Process code.  This PL/SQL global
-- variable value should be set, when Visual Basic Update Process code
-- sets the global variable value, Ano_Act.

G_Current_Fiscal_Yr     NUMBER;

--parallelism.
g_parallel boolean;


/*===========================================================================+
|
|   Name:          CloneBSCPeriodicitybyCalendar
|
|   Description:   This create new periodicity for this calendar from the
|                  BSC base periodicity of Gregorian Calendar(calendar_id =1)
|                  To be called from VB. Insert any error in BSC_MESSAGE_LOGS
|
|   Parameters:	 x_calendar_id - calendar id
|
|
|   Notes:
|
+============================================================================*/
PROCEDURE CloneBSCPeriodicitybyCalendar(
	x_calendar_id NUMBER
	);


/*===========================================================================+
|
|   Name:          Create_Unique_Index
|
|   Description:   This function creates a unique index on the given table.
|
|   Parameters:	   x_table_name - table name
|                  x_index_name - index name
|                  x_lst_columns - list of columns of the primary key
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Create_Unique_Index(
	x_table_name IN VARCHAR2,
        x_index_name IN VARCHAR2,
        x_lst_columns IN VARCHAR2,
        x_tbs_type IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
| FUNCTION getSmallerColumnList
| Added for Bug 4099338
+============================================================================*/
 function getSmallerColumnList(h_lst_cols_index in varchar2) return varchar2;


/*===========================================================================+
|
|   Name:          Create_Global_Temp_Table
|
|   Description:   This function creates the given global temporary table.
|                  If the table already exists with the same structure
|                  then we do not create it again.
|
+============================================================================*/
FUNCTION Create_Global_Temp_Table(
        x_table_name IN VARCHAR2,
	x_table_columns IN BSC_UPDATE_UTIL.t_array_temp_table_cols,
        x_num_columns IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Create_Permanent_Table
|
|   Description:   This function creates the given table.
|                  If the table already exists with the same structure
|                  then we do not create it again.
|
+============================================================================*/
FUNCTION Create_Permanent_Table(
        x_table_name IN VARCHAR2,
	x_table_columns IN BSC_UPDATE_UTIL.t_array_temp_table_cols,
        x_num_columns IN NUMBER,
        x_tablespace IN VARCHAR2,
        x_idx_tablespace IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Decompose_Numeric_List
|
|   Description:   This function decompose a string into a number array and
|                  returns the number of items in the array.
|                  Example:
|                  If x_string = '3001, 3002, 3003' and x_separator = ','
|                  then x_number_array = 3001|3002|3003 and retunrs 3
|
|   Notes:
|
+============================================================================*/
FUNCTION Decompose_Numeric_List(
	x_string IN VARCHAR2,
	x_number_array IN OUT NOCOPY t_array_of_number,
        x_separator IN VARCHAR2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Decompose_Varchar2_List
|
|   Description:   This function decompose a string into a varchar2 array and
|                  returns the number of items in the array.
|                  Example:
|                  If x_string = 'table1, table2, table3' and x_separator = ','
|                  then x_array = 'table1'|'table2'|'table3' and retunrs 3
|
|   Notes:
|
+============================================================================*/
FUNCTION Decompose_Varchar2_List(
	x_string IN VARCHAR2,
	x_array IN OUT NOCOPY t_array_of_varchar2,
        x_separator IN VARCHAR2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Drop_Index
|
|   Description:   This function drop given index.
|
|   Parameters:	   x_index_name - index name
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Drop_Index(
	x_index_name IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Drop_Table
|
|   Description:   This function drop given table if exists.
|
|   Parameters:	   x_table_name - table name
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Drop_Table(
	x_table_name IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Execute_Immediate
|
|   Description:   Execute the given sql statmentent
|
|   Parameters:	   x_sql - sql statement
|
|   Notes:
|
+============================================================================*/
PROCEDURE Execute_Immediate(
	x_sql IN VARCHAR2
	);

--ENH_B_TABLES_PERF: new procedure
PROCEDURE Execute_Immediate(
	x_sql IN clob
	);

--Fix bug#3875046
/*===========================================================================+
|
|   Name:          Execute_Immediate
|
|   Description:   Execute the given sql statmentent. Returns SQL%ROWCOUNT
|
|   Parameters:	   x_sql - sql statement
|
|   Notes:
|
+============================================================================*/
FUNCTION Execute_Immediate(
	x_sql IN VARCHAR2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Execute_Immediate
|
|   Description:   Execute the given sql statmentent
|
|   Parameters:	   x_sql - sql statement
|
|   Notes:
|
+============================================================================*/
PROCEDURE Execute_Immediate(
	x_sql IN VARCHAR2,
        x_bind_vars_values IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_bind_vars IN NUMBER
);

-- ENH_B_TABLES_PERF: new procedure
PROCEDURE Execute_Immediate(
	x_sql IN clob,
        x_bind_vars_values IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_bind_vars IN NUMBER
);

--Fix bug#3875046
/*===========================================================================+
|
|   Name:          Execute_Immediate
|
|   Description:   Execute the given sql statmentent. Returns SQL%ROWCOUNT
|
|   Parameters:	   x_sql - sql statement
|
|   Notes:
|
+============================================================================*/
FUNCTION Execute_Immediate(
	x_sql IN VARCHAR2,
        x_bind_vars_values IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_bind_vars IN NUMBER
) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Execute_Immediate
|
|   Description:   Execute the given sql statmentent
|
|   Parameters:	   x_sql - sql statement
|
|   Notes:
|
+============================================================================*/
PROCEDURE Execute_Immediate(
	x_sql IN VARCHAR2,
        x_bind_vars_values IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_bind_vars IN NUMBER
);


-- ENH_B_TABLES_PERF: new procedure
PROCEDURE Execute_Immediate(
	x_sql IN clob,
        x_bind_vars_values IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_bind_vars IN NUMBER
);

--Fix bug#3875046
/*===========================================================================+
|
|   Name:          Execute_Immediate
|
|   Description:   Execute the given sql statmentent. Returns SQL%ROWCOUNT
|
|   Parameters:	   x_sql - sql statement
|
|   Notes:
|
+============================================================================*/
FUNCTION Execute_Immediate(
	x_sql IN VARCHAR2,
        x_bind_vars_values IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_bind_vars IN NUMBER
) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Exist_Periodicity_Rel
|
|   Description:   Return TRUE is there is relation between the given
|                  periodicity id  and source periodicity id.
|                  It looks in the global array g_array_periodicity_rels

|   Notes:
|
+============================================================================*/
FUNCTION Exist_Periodicity_Rel(
    x_periodicity_id IN NUMBER,
    x_source_periodicity_id IN NUMBER
    ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Calendar_EDW_Flag
|
|   Description:   This function returns the edw flag of the given calendar
|
|   Parameters:	   x_calendar_id: calendar id
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Calendar_EDW_Flag(
	x_calendar_id IN NUMBER
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Calendar_Source
|
|   Description:   This function returns the source ('PMF' or 'BSC') of
|                  the given calendar
|
|   Parameters:	   x_calendar_id: calendar id
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Calendar_Source(
	x_calendar_id IN NUMBER
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_Calendar_Fiscal_Year
|
|   Description:   This function returns the current fiscal year of the given
|                  calendar
|
|   Parameters:	   x_calendar_id: calendar id
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Calendar_Fiscal_Year(
	x_calendar_id IN NUMBER
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Calendar_Id
|
|   Description:   This function returns the calendar id of the given
|                  periodicity.
|
|   Parameters:	   x_periodicity_id: periodicity id
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Calendar_Id(
	x_periodicity_id IN NUMBER
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Calendar_Name
|
|   Description:   This function returns the name of the given calendar
|
|   Parameters:	   x_calendar_id: calendar id
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Calendar_Name(
	x_calendar_id IN NUMBER
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_Calendar_Start_Date
|
|   Description:   This function returns the start date of current fiscal year
|                  of the given calendar.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Calendar_Start_Date(
	x_calendar_id IN NUMBER,
	x_current_fy IN NUMBER,
	x_start_year OUT NOCOPY NUMBER,
	x_start_month OUT NOCOPY NUMBER,
	x_start_day OUT NOCOPY NUMBER
      ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Calendar_Table_Col_Name
|
|   Description:   This function returns the name of the column of
|                  bsc_db_calendar table that has the values for the given
|                  periodicity.
|
|   Parameters:	   x_periodicity_id
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Calendar_Table_Col_Name(
	x_periodicity_id IN NUMBER
	) RETURN VARCHAR2;


--AW_INTEGRATION: New function
FUNCTION Get_Dim_Level_Table_Name(
	x_level_pk_col IN VARCHAR2
) RETURN VARCHAR2;

--AW_INTEGRATION: New function
FUNCTION Get_Dim_Level_View_Name(
	x_level_pk_col IN VARCHAR2
) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_EDW_Materialized_View_Name
|
|   Description:   This function returns the name of the materialized view
|                  of the given table
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_EDW_Materialized_View_Name(
	x_table_name IN VARCHAR2
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_EDW_Union_View_Name
|
|   Description:   This function returns the name of the union view
|                  of the given table
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_EDW_Union_View_Name(
	x_table_name IN VARCHAR2
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_Free_Div_Zero_Expression
|
|   Description:   This function return a expression that is a modification of
|                  the given expression to make it division by zero safe.
|                  Uses DECODE in the denominator to prevent division by zero.
|
|   Parameters:	   x_expression
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Free_Div_Zero_Expression(
	x_expression IN VARCHAR2
	) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Get_Free_Div_Zero_Expression, WNDS);


/*===========================================================================+
|
|   Name:          Get_Indic_Range_Of_Years
|
|   Description:   This function get the number of years and number of
|                  previous years that the indicator uses for the given
|                  periodicity.
|
|   Parameters:    x_indicator		- indicator code
|                  x_periodicity        - periodicity id
|                  x_num_of_years	- parameter to return number of years
|                  x_previous_years	- parameter to return number of previous
|					  years.
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Indic_Range_Of_Years(
	x_indicator IN NUMBER,
        x_periodicity IN NUMBER,
        x_num_of_years OUT NOCOPY NUMBER,
	x_previous_years OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Information_Data_Columns
|
|   Description:   This function fill the following arrays with the information
|                  of all data columns of the table:
|
|                  x_data_columns  - data column names
|                  x_data_formulas - source formula of data columns
|                  x_data_proj_methods - projection methods of data columns
|                  x_data_measure_types - measure type of data columns (1:Total
|                                         2:Balance)
|
|                  Set the parameter x_num_data_columns with the number of
|                  data columns of the table.
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Information_Data_Columns(
	x_table IN VARCHAR2,
	x_data_columns IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_data_formulas IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_data_proj_methods IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
        x_data_measure_types IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
	x_num_data_columns IN OUT NOCOPY NUMBER) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Information_Key_Columns
|
|   Description:   This function fill the following arrays with the information
|                  of all key columns of the table:
|
|                  x_key_columns       - key column names
|                  x_key_dim_tables    - dimension table name for key columns
|                  x_source_columns    - source of key columns
|                  x_source_dim_tables - dimension table name for source columns
|                  Set the parameter x_num_key_columns with the number of
|                  key columns of the table.
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Information_Key_Columns(
	x_table IN VARCHAR2,
	x_key_columns IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_key_dim_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_source_columns IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_source_dim_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_key_columns IN OUT NOCOPY NUMBER) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Init_Variable_Value
|
|   Description:   This function returns in x_variable_value parameter the
|                  value of the INIT variable whose name is given in
|                  x_variable_name parameter.
|
|   Parameters:	   x_variable_name - name of the INIT variable
|                  x_variable_value - argument to set the value of the
|                                     variable
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Init_Variable_Value(
	x_variable_name IN VARCHAR2,
        x_variable_value OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Input_Table_Source
|
|   Description:   This function returns the source type and source name
|                  of the given input table.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Input_Table_Source(
	x_input_table IN VARCHAR2,
	x_source_type OUT NOCOPY NUMBER,
	x_source_name OUT NOCOPY VARCHAR2
      ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Installed_Languages
|
|   Description:   Fill the array x_languages with the installed languages.
|                  Returns the number of installed languages.
|                  Returns -1 in case of error.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Installed_Languages(
	x_languages IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Lookup_Value
|
|   Description:   This function returns the LOOKUP value of the given
|                  LOOKUP type and LOOKUP code
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Lookup_Value(
	x_lookup_type IN VARCHAR2,
        x_lookup_code IN VARCHAR2
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_Message
|
|   Description:   This function returns the translated message
|                  of the given message code
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Message(
	x_message_name IN VARCHAR2
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Get_Num_Periods_Periodicity
|
|   Description:   This function returns the number of periods of the given
|                  periodicity.
|
|   Parameters:	   x_peridiocity - periodicity code
|                  x_current_fy - current fical year
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return NULL.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Num_Periods_Periodicity(
	x_periodicity IN NUMBER,
	x_current_fy IN NUMBER
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Period_Cols_Names
|
|   Description:   This function gets period and subperiod columns names
|                  for the given periodicity. This information is stored
|                  in the columns PERIOD_COL_NAME and SUBPERIOD_COL_NAME
|                  of BSC_SYS_PERIODICITIES table.
|
|   Parameters:	   x_periodicity_id - periodicity id
|                  x_period_col_name - period column name
|                  x_subperiod_col_name - subperiod column name
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Period_Cols_Names(
	x_periodicity_cod IN NUMBER,
        x_period_col_name OUT NOCOPY VARCHAR2,
        x_subperiod_col_name OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Period_Other_Periodicity
|
|   Description:   This function gets period corresponding to the given
|                  period of a source periodicity.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Period_Other_Periodicity(
	p_periodicity_id IN NUMBER,
        p_calendar_id IN NUMBER,
        p_yearly_flag IN NUMBER,
        p_current_fy IN NUMBER,
        p_source_periodicity_id IN NUMBER,
        p_source_period IN NUMBER
        ) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Periodicity_EDW_Flag
|
|   Description:   This function returns the EDW flag of the given
|                  periodicity.
|
|   Parameters:	   x_periodicity_id: periodicity id
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Periodicity_EDW_Flag(
	x_periodicity_id IN NUMBER
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Periodicity_Type
|
|   Description:   This function returns the periodicity type of the given
|                  periodicity.
|
|   Parameters:	   x_periodicity_id: periodicity id
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Periodicity_Type(
	x_periodicity_id IN NUMBER
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Periodicity_Yearly_Flag
|
|   Description:   This function returns the yearly flag of the given
|                  periodicity.
|
|   Parameters:	   x_periodicity_id: periodicity id
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Periodicity_Yearly_Flag(
	x_periodicity_id IN NUMBER
	) RETURN NUMBER;



/*===========================================================================+
|
|   Name:          Get_Source_Periodicities
|
|   Description:   This function returns the source periodicities of the given
|                  periodicity in the array x_source_periodicities.
|                  It reads from the global array g_array_periodicity_rels
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Source_Periodicities(
    x_periodicity_id IN NUMBER,
    x_source_periodicities IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number
    ) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Table_EDW_Flag
|
|   Description:   This function returns the EDW flag of the table.
|
|   Parameters:	   x_table_name - table name
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Table_EDW_Flag(
	x_table_name IN VARCHAR2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Table_Generation_Type
|
|   Description:   This function returns the generation type of the table.
|                  The generation type of a table is stored in
|                  the column GENERATION_TYPE of BSC_DB_TABLES table.
|
|   Parameters:	   x_table_name - table name
|
|   Returns: 	   Return the table generation type.
|                  If any error ocurrs, this function add the error message
|		   to the error stack and return NULL.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Table_Generation_Type(
	x_table_name IN VARCHAR2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Table_Type
|
|   Description:   This function returns the table type of the table.
|                  The table type is stored in the column TABLE_TYPE of
|                  BSC_DB_TABLES table.
|
|   Parameters:	   x_table_name - table name
|
|   Returns: 	   Return the table type.
|                  If any error ocurrs, this function add the error message
|		   to the error stack and return NULL.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Table_Type(
	x_table_name IN VARCHAR2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Table_Periodicity
|
|   Description:   This function returns the periodicity code of the given
|                  table. The periodicity of a table is stored in the column
|                  PERIODICITY_ID of BSC_DB_TABLES table.
|
|   Parameters:	   x_table_name - table name
|
|   Returns: 	   Return the table periodicity code.
|                  If any error ocurrs, this function add the error message
|		   to the error stack and return NULL.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Table_Periodicity(
	x_table_name IN VARCHAR2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Get_Table_Range_Of_Years
|
|   Description:   This function get the number of years and number of
|                  previous years that the table uses.
|
|   Parameters:    x_table_name		- table name
|                  x_num_of_years	- parameter to return number of years
|                  x_previous_years	- parameter to return number of previous
|					  years.
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Table_Range_Of_Years(
	x_table_name IN VARCHAR2,
        x_num_of_years OUT NOCOPY NUMBER,
	x_previous_years OUT NOCOPY NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Kpis_Using_Table
|
|   Description:   This function return an array with the Kpis using directly
|                  the given table and their prototype flag.
|                  It consider SB tables created for targets
|                  at different levels as tables used direclty by the indicator.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Kpis_Using_Table(
    x_table_name IN VARCHAR2,
    x_kpis IN OUT NOCOPY t_array_kpis
) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Is_Kpi_In_Production
|
|   Description:   This function returns TRUE is the indicator is in production
|                  (prototype_flag in 0, 6, 7)
|   Notes:
|
+============================================================================*/
FUNCTION Is_Kpi_In_Production(
    x_kpi IN NUMBER
) RETURN BOOLEAN;

/*===========================================================================+
|
|   Name:          Is_Kpi_Measure_In_Production
|
|   Description:   This function returns TRUE is the kpi measure is in production
|                  (prototype_flag = 7)
|   Notes:
|
+============================================================================*/
/*FUNCTION Is_Kpi_Measure_In_Production (
  p_objective_id   IN NUMBER
, p_kpi_measure_id IN NUMBER
) RETURN BOOLEAN;*/


/*===========================================================================+
|
|   Name:          Get_Table_Target_Flag
|
|   Description:   This function returns the Target flag of the table.
|
|   Parameters:	   x_table_name - table name
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Table_Target_Flag(
	x_table_name IN VARCHAR2
	) RETURN NUMBER;


/*===========================================================================+
|
|   Name:          Init_Calendar_Tables
|
|   Description:   This function populate the tables BSC_DB_CALENDAR,
|                  and BSC_DB_WEEK_MAPS.
|
|   Parameters:    x_action = 1 Drop indexes on calendar tables (commit)
|                  x_action = 2 Populate calendar tables (no commit)
|                  x_action = 3 Create indexes on calendar tables (commit)
|                  x_action = NULL Execute all steps
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Init_Calendar_Tables (
      x_calendar_id IN NUMBER,
      x_action IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Init_Calendar_Tables
|
+============================================================================*/
FUNCTION Init_Calendar_Tables (
      x_calendar_id IN NUMBER
	) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Init_Calendar_Tables_AT(
    x_calendar_id IN NUMBER
    ) RETURN BOOLEAN;


-- ENH_B_TABLES_PERF: new function
/*===========================================================================+
| FUNCTION Is_Base_Table
+============================================================================*/
FUNCTION Is_Base_Table(
	x_table_name IN VARCHAR2
) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Is_EDW_Kpi_Table
|
|   Description:   This function TREU if the given table is used directly
|                  by a EDW KPI
|
|   Parameters:    x_table_name Table name
|
|   Notes:
|
+============================================================================*/
FUNCTION Is_EDW_Kpi_Table(
	x_table_name IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Item_Belong_To_Array_Number
|
|   Description:   This function says if a item belong to an array
|
|   Parameters:	   x_item 	- item name
|                  x_array 	- array
|                  x_num_items  - number of item in the array
|
|   Returns: 	   Return TRUE if the item belong to the array. Otherwise
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
|   Name:          Item_Belong_To_Array_Varchar2
|
|   Description:   This function says if a item belong to an array
|
|   Parameters:	   x_item 	- item name
|                  x_array 	- array
|                  x_num_items  - number of item in the array
|
|   Returns: 	   Return TRUE if the item belong to the array. Otherwise
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


--LOCKING: New procedure
PROCEDURE Load_Calendar_Into_AW_AT(
    x_calendar_id IN NUMBER
);


/*===========================================================================+
|
|   Name:          Load_Periodicity_Rels
|
|   Description:   This function load in the array g_array_periodicity_rels()
|                  all the relationships between periodicities
|
+============================================================================*/
FUNCTION Load_Periodicity_Rels RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Make_Lst_Cond_Join
|
|   Description:   This function return a list with the condition for a
|                  join between two tables.
|                  Example: x_table_1 = 'table1'
|                           x_key_columns_1 = 'col11'|'col12'|...|'col1N'
|                           x_table_2 = 'table2'
|                           x_key_columns_2 = 'col21'|'col22'|...|'col2N'
|                           x_separator = 'AND'
|
|                           list = 'table1.col11 = table2.col21 AND
|                                   table2.col12 = table2.col22 AND
|                                   ...
|                                   table1.col1N = table2.col2N'
|
|   Parameters:	   x_table_1 		- name of table 1
|                  x_key_columns_1 	- array with table 1 columns
|                  x_table_2		- name of table 2
|                  x_key_columns_2	- array with table 2 columns
|                  x_num_key_columns	- number of columns
|                  x_separator          - boolean operator (AND, OR)
|
|   Notes:
|
+============================================================================*/
FUNCTION Make_Lst_Cond_Join(
	x_table_1 IN VARCHAR2,
	x_key_columns_1 IN t_array_of_varchar2,
        x_table_2 IN VARCHAR2,
        x_key_columns_2 IN t_array_of_varchar2,
        x_num_key_columns IN NUMBER,
        x_separator IN VARCHAR2
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Make_Lst_Cond_Left_Join
|
|   Description:   This function return a list with the condition for a left
|                  join between two tables.
|                  Example: x_table_1 = 'table1'
|                           x_key_columns_1 = 'col11'|'col12'|...|'col1N'
|                           x_table_2 = 'table2'
|                           x_key_columns_2 = 'col21'|'col22'|...|'col2N'
|                           x_separator = 'AND'
|
|                           list = 'table1.col11 = table2.col21 (+) AND
|                                   table2.col12 = table2.col22 (+) AND
|                                   ...
|                                   table1.col1N = table2.col2N'
|
|   Parameters:	   x_table_1 		- name of table 1
|                  x_key_columns_1 	- array with table 1 columns
|                  x_table_2		- name of table 2
|                  x_key_columns_2	- array with table 2 columns
|                  x_num_key_columns	- number of columns
|                  x_separator          - boolean operator (AND, OR)
|
|   Notes:
|
+============================================================================*/
FUNCTION Make_Lst_Cond_Left_Join(
	x_table_1 IN VARCHAR2,
	x_key_columns_1 IN t_array_of_varchar2,
        x_table_2 IN VARCHAR2,
        x_key_columns_2 IN t_array_of_varchar2,
        x_num_key_columns IN NUMBER,
        x_separator IN VARCHAR2
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Make_Lst_Cond_Null
|
|   Description:   This function return a list with the null condition.
|                  Example: x_table = 'table'
|                           x_key_columns = 'col1'|'col2'|...|'colN'
|                           x_separator = 'AND'
|
|                           list = 'table.col1 IS NULL AND
|                                   table.col2 IS NULL AND
|                                   ...
|                                   table.colN IS NULL'
|
|   Parameters:	   x_table 		- name of table
|                  x_key_columns 	- array with table columns
|                  x_num_key_columns	- number of columns
|                  x_separator          - boolean operator (AND, OR)
|
|   Notes:
|
+============================================================================*/
FUNCTION Make_Lst_Cond_Null(
	x_table IN VARCHAR2,
	x_key_columns IN t_array_of_varchar2,
        x_num_key_columns IN NUMBER,
        x_separator IN VARCHAR2
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Make_Lst_Cond_Number
|
|   Description:   This function return a list with the number condition.
|                  Example: x_column = 'column'
|                           x_values = 1,2'
|                           x_separator = 'AND'
|
|                           list = 'column=1 AND column=2'
|
|   Parameters:	   x_column 		- column name
|                  x_values	 	- array with numeric values
|                  x_num_values		- number of values
|                  x_separator          - boolean operator (AND, OR)
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
|   Name:          Make_Lst_Description
|
|   Description:   This function return a description with the items in the array.
|                  Example: x_array = 'column1'|'column2'|...|'columnN'
|                           x_data_type = NUMBER
|                           list = 'column1 NUMBER, column2 NUMBER, ..., columnN NUMBER'
|
|   Parameters:	   x_array 	- array
|                  x_num_items  - number of items in the array
|                  x_data_type  - data type
|
|   Notes:
|
+============================================================================*/
FUNCTION Make_Lst_Description(
	x_array IN t_array_of_varchar2,
	x_num_items IN NUMBER,
        x_data_type IN VARCHAR2
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Make_Lst_From_Array_Varchar2
|
|   Description:   This function return a list with the items in the array.
|                  Example: x_array = 'item1'|'item2'|...|'itemN'
|                           list = 'item1, item2, ..., itemN'
|
|   Parameters:	   x_array 	- array
|                  x_num_items  - number of items in the array
|
|   Notes:
|
+============================================================================*/
FUNCTION Make_Lst_From_Array_Varchar2(
	x_array IN t_array_of_varchar2,
	x_num_items IN NUMBER
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Make_Lst_Fixed_Column
|
|   Description:   This function return a list with fixed column name.
|                  Example: x_fixed_column_name = 'KEY', x_num_items = 5
|                           list = KEY1, KEY2, KEY3, KEY4, KEY5'
|
|   Parameters:
|                  x_num_items  - number of items in the array
|
|   Notes:
|
+============================================================================*/
FUNCTION Make_Lst_Fixed_Column(
        x_fixed_column_name IN VARCHAR2,
	x_num_items IN NUMBER
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Make_Lst_Table_Column
|
|   Description:   This function return a list like this:
|                  Example: x_table_name = 'table'
|                           x_columns = 'col1'|'col2'|...|'colN'
|                           list = 'table.col1, table.col2, ..., table.colN'
|
|   Parameters:	   x_table_name	- table name
|                  x_columns  - array of column names
|                  x_num_columns - number of columns
|
|   Notes:
|
+============================================================================*/
FUNCTION Make_Lst_Table_Column(
        x_table_name IN VARCHAR2,
	x_columns IN t_array_of_varchar2,
	x_num_columns IN NUMBER
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Populate_Bsc_Db_Calendar
|
|   Description:   Populates the table BSC_DB_CALENDAR for the given calendar
|                  for predefined periodicities.
|
|   Parameters:    X_Current_Fiscal_Yr	- Current fiscal year
|                  X_Fy_Start_Yr        - Calendar year for the current fiscal
|                                         year start date.
|                  X_Fy_Start_Mth	- Calendar month for the current fiscal
|			                  year start date.
|		   X_Fy_Start_Day       - Calendar day for the current fiscal
|			                  year start date.
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Populate_Bsc_Db_Calendar(
      x_calendar_id           NUMBER,
	X_Current_Fiscal_Yr	NUMBER,
	X_Fy_Start_Yr		NUMBER,
	X_Fy_Start_Mth		NUMBER,
	X_Fy_Start_Day		NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Populate_Bsc_Db_Week_Maps
|
|   Description:   Populates the table BSC_DB_WEEK_MAPS for the given calendar.
|
|   Parameters:
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Populate_Bsc_Db_Week_Maps(
	x_calendar_id IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Populate_Bsc_Sys_Periods_Tl
|
|   Description:   Populates the table BSC_SYS_PERIODS_TL for the given calendar.
|
|   Parameters:
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Populate_Bsc_Sys_Periods_Tl(
	x_calendar_id IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Populate_Calendar_Tables
|
|   Description:   This is a procedure that populate the calendar tables
|		   If some error ocurrs the error message is written in
|		   BSC_MESSAGE_LOGS table with TYPE = 0.
|                  This procedure is to be called from VB.
|
|   Parameters:    x_action = 1 Drop indexes on calendar tables (commit)
|                  x_action = 2 Populate calendar tables (no commit)
|                  x_action = 3 Create indexes on calendar tables (commit)
|                  x_action = NULL Execute all steps
|
|   Returns:
|
+============================================================================*/
PROCEDURE Populate_Calendar_Tables (
      x_calendar_id IN NUMBER,
	x_action IN NUMBER
	);


/*===========================================================================+
|
|   Name:          Populate_Calendar_Tables
|
+============================================================================*/
PROCEDURE Populate_Calendar_Tables (
      x_calendar_id IN NUMBER
	);


--Fix bug#4508980 : this api is provided to be called from OAF Calendar UI
-- Note that from now on, load reporting calendar and load calendar into aw will be done in GDB
/*===========================================================================+
| PROCEDURE Populate_Calendar_Tables
+============================================================================*/
PROCEDURE Populate_Calendar_Tables (
    p_commit         VARCHAR2,
    p_calendar_id    NUMBER,
    x_return_status  OUT NOCOPY  VARCHAR2,
    x_msg_count      OUT NOCOPY  NUMBER,
    x_msg_data       OUT NOCOPY  VARCHAR2
);


/*===========================================================================+
|
|   Name:          Replace_Token
|
|   Description:   This function returns the message replacin the given token.
|
|   Notes:
|
+============================================================================*/
FUNCTION Replace_Token(
	x_message IN VARCHAR2,
	x_token_name IN VARCHAR2,
	x_token_value IN VARCHAR2
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Set_Calendar_Fiscal_Year
|
|   Description:   Set the given fiscal year for the calendar.
|
|   Parameters:	   x_calendar_id: Calendar id
|                  x_fiscal_year: new fiscal year
|
|   Notes:
|
+============================================================================*/
FUNCTION Set_Calendar_Fiscal_Year(
	x_calendar_id IN NUMBER,
        x_fiscal_year IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Table_Exists
|
|   Description:   Checks whether the specific table exists in the
|		   database.
|
|   Parameters:	   X_Table - Table name.
|
|   Returns:	   TRUE - Table exists in the database.
|		   FALSE - Table does not exist in the database.
|
|   Notes:
|
+============================================================================*/
FUNCTION Table_Exists(
	X_Table			VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Table_Has_Any_Row
|
|   Description:   This function say if there is any row in a table that
|                  accomplishes with the given condition.
|
|   Parameters:	   x_table_name - Table name.
|                  x_condition - condition
|
|   Returns:	   TRUE - Table has any row that accomplish the condition
|		   FALSE - Table doesn't have any row.
|                  NULL - There was some error executing the function
|
|   Notes:
|
+============================================================================*/
FUNCTION Table_Has_Any_Row(
	x_table_name IN VARCHAR2,
        x_condition IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Table_Has_Any_Row
|
+============================================================================*/
FUNCTION Table_Has_Any_Row(
	x_table_name IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Truncate_Table
|
|   Description:   Truncates the given table
|
|   Parameters:	   x_table_name - Table name.
|
|   Notes:
|
+============================================================================*/
PROCEDURE Truncate_Table(
        x_table_name IN VARCHAR2
	);

--LOCKING: new procedure
PROCEDURE Truncate_Table_AT(
        x_table_name IN VARCHAR2
	);


/*===========================================================================+
|
|   Name:          Update_AnualPeriodicity_Src
|
|   Description:   This function creates a unique index on the given table.
|
|   Parameters:	   x_table_name - table name
|		   x_calendar_id - Calendar id
|		   x_periodicity_id - Periodicity id to add/update or delete
|		Action	       - 1: Add-Update   2: Delete
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
	PROCEDURE Update_AnualPeriodicity_Src(
		x_calendar_id NUMBER,
		x_periodicity_id NUMBER,
		x_action NUMBER
		);
/*===========================================================================+
|
|   Name:          Update_Kpi_Period_Name
|
|   Description:   This function update the period name in BSC_KPI_DEFAULTS_TL
|                  with the name of the current period of the given indicator
|
|   Parameters:	   x_indicator
|
|   Returns:	   FALSE there was an error
|
|   Notes:
|
+============================================================================*/
FUNCTION Update_Kpi_Period_Name(
	x_indicator IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Update_Kpi_Time_Stamp
|
|   Description:   Update the time stamp of the given Kpi
|
|   Parameters:	   indicator - kpi code
|
|   Notes:
|
+============================================================================*/
PROCEDURE Update_Kpi_Time_Stamp(
	x_indicator IN NUMBER
	);


/*===========================================================================+
|
|   Name:          Update_Kpi_Time_Stamp
|
|   Description:   Update the time stamp of the Kpis based on the given condition
|
|   Parameters:	   x_condition - Example: 'indicator = 3001 or indicator = 3017'
|
|   Notes:
|
+============================================================================*/
PROCEDURE Update_Kpi_Time_Stamp(
	x_condition IN VARCHAR2
	);


/*===========================================================================+
|
|   Name:          Update_Kpi_Tab_Time_Stamp
|
|   Description:   Update the time stamp of the tab which the given kpi belongs to.
|
|   Parameters:	   indicator - kpi code
|
|   Notes:
|
+============================================================================*/
PROCEDURE Update_Kpi_Tab_Time_Stamp(
	x_indicator IN NUMBER
	);


/*===========================================================================+
|
|   Name:          Update_Kpi_Tab_Time_Stamp
|
|   Description:   Update the time stamp of the tab which the given kpi belongs to.
|                  The given kpis are given in the condition
|
|   Parameters:	   x_condition - Example: 'indicator = 3001 or indicator = 3017'
|
|   Notes:
|
+============================================================================*/
PROCEDURE Update_Kpi_Tab_Time_Stamp(
	x_condition IN VARCHAR2
	);


/*===========================================================================+
|
|   Name:          Update_Kpi_Table_Time_Stamp
|
|   Description:   Update the time stamp of the kpis that read directly from
|                  the given table
|
|   Parameters:	   x_condition - Example: 'indicator = 3001 or indicator = 3017'
|
|   Notes:
|
+============================================================================*/
PROCEDURE Update_Kpi_Table_Time_Stamp(
	x_table_name IN VARCHAR2
	);


/*===========================================================================+
|
|   Name:          Update_System_Time_Stamp
|
|   Description:   Update the system time stamp
|
|   Parameters:
|
|   Notes:
|
+============================================================================*/
PROCEDURE Update_System_Time_Stamp;


/*===========================================================================+
|
|   Name:          Verify_Custom_Periodicity
|
|   Description:   It check that there are records for all fiscal years
|                  in BSC_SYS_PERIODS. In case a fiscal year dont have
|                  records, it generate them automatically taking the
|                  parameters of the current fiscal year.
|                  After that it updates the corresponding column
|                  in BSC_DB_CALENDAR table.
|
|   Parameters:	 x_calendar_id  - calendar id
|                  x_periodicity_id - periodicity id
|                  x_custom_code - 1 (based on start and end date)
|                                  2 (based on start and end period of a base periodicity)
|
|   Returns: 	If any error occurs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Verify_Custom_Periodicity(
	x_calendar_id IN NUMBER,
	x_periodicity_id IN NUMBER,
	x_custom_code IN NUMBER
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Write_Init_Variable_Value
|
|   Description:   This function write in the table INIT the given value for
|                  of the given variable. If the variable doesn't exist then
|                  it's added. Otherwise it's updated.
|
|   Parameters:	   x_variable_name - name of the INIT variable
|                  x_variable_value - variable value
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Write_Init_Variable_Value(
	x_variable_name IN VARCHAR2,
	x_variable_value IN VARCHAR2
	) RETURN BOOLEAN;

/*===========================================================================+
|
|   Name:          is_parallel
|
|   Description:   this function checks to see if parallelism is enabled
|
|   Parameters:
|
|   Returns: 	  true if parallelism is set. false otherwise
|
|   Notes:
|
+============================================================================*/
function is_parallel return boolean;

/*******************************************************************************
********************************************************************************/
FUNCTION set_Product_Version
(   p_Product     IN  VARCHAR2
  , p_Version     IN  VARCHAR2
) RETURN BOOLEAN;

/*******************************************************************************
********************************************************************************/
FUNCTION get_Product_Version
(
    p_Product     IN  VARCHAR2
) RETURN VARCHAR2;


-- AW_INTEGRATION: New function
/*===========================================================================+
|
|   Name:          Is_Table_For_AW_Kpi
|
|   Description:   This function returns TRUE is the given table is used
|                  by any AW indicator. Otherwise returns FALSE.
|                  The given table can be base, t, or summary table.
|
+============================================================================*/
FUNCTION Is_Table_For_AW_Kpi(
	x_table_name IN VARCHAR2
	) RETURN BOOLEAN;


-- AW_INTEGRATION: New function
/*===========================================================================+
|
|   Name:          Get_Kpi_Impl_Type
|
|   Description:   This function returns the implementation type of the given
|                  indicator: 0 summary tables, 1 MVs, 2 AWs
|
+============================================================================*/
FUNCTION Get_Kpi_Impl_Type(
    x_kpi IN NUMBER
) RETURN NUMBER;


-- AW_INTEGRATION: New function
FUNCTION Exists_AW_Kpi RETURN BOOLEAN;

-- AW_INTEGRATION: New function
FUNCTION Calendar_Used_In_AW_Kpi(
	x_calendar_id IN VARCHAR2
	) RETURN BOOLEAN;

TYPE t_kpi_dim_props_rec IS RECORD (
  dim_set_id         bsc_kpi_analysis_options_b.dim_set_id%TYPE,
  comp_level_pk_col  bsc_kpi_dim_levels_b.level_pk_col%TYPE
);

PROCEDURE Get_Kpi_Dim_Props (
  p_objective_id    IN NUMBER
, p_kpi_measure_id  IN NUMBER
, x_dim_props_rec   OUT NOCOPY BSC_UPDATE_UTIL.t_kpi_dim_props_rec
);

FUNCTION Get_Measure_Formula (
  p_objective_id    IN NUMBER
, p_kpi_measure_id  IN NUMBER  := NULL
, p_sim_objective   IN BOOLEAN := FALSE
)
RETURN VARCHAR2;

FUNCTION Get_Color_By_Total (
  p_objective_id    IN NUMBER
, p_kpi_measure_id  IN NUMBER  := NULL
)
RETURN NUMBER;

FUNCTION get_ytd_flag (
  p_objective_id    IN NUMBER
, p_kpi_measure_id  IN NUMBER
)
RETURN NUMBER;

FUNCTION Get_Apply_Color_Flag (
  p_objective_id    IN NUMBER
, p_kpi_measure_id  IN NUMBER  := NULL
)
RETURN NUMBER;

END BSC_UPDATE_UTIL;

/
