--------------------------------------------------------
--  DDL for Package BSC_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UTILITY" AUTHID CURRENT_USER AS
/*$Header: BSCUTILS.pls 120.24 2007/10/04 14:29:31 sirukull ship $ */
/*===========================================================================+
 |               Copyright (c) 1995 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 |  12-NOV-03    Bug #3232366                                                |
 |  09-AUG-2004 sawu  Added API Get_Default_Internal_Name for bug#3819855    |
 |  18-AUG-2004 ADRAO Fixed Bug#3831815                                      |
 |  01-OCT-2004 ashankar Fixed Bug#3908204                                   |
 |  05-OCT-2004 ankgoel  Bug#3933075 Moved C_BSC_UNDERSCORE here from        |
 |                       BSCCRUDS.pls                                        |
 |  08-APR-2005 kyadamak Added function get_valid_bsc_master_tbl_name() for  |
 |                       bug# 4290359                                        |
 |  18-JYL-2005 ppandey    added Dimension entity validation APIs            |
 |  11-AUG-2005 ppandey  Bug #4324947 Validation for Dim,Dim Obj in Rpt      |
 |  01-SEP-2005 adrao    Added API Get_Responsibility_Key for Bug#4563456    |
 |  06-SEP-2005 KYADMAK  added constant for bug#4593321                      |
 |  13-Sep-2005 sawu  Bug#4602231: Broken is_internal_dim into component apis|
 |  05-Oct-2005 ashankar Bug#      Added the method Get_User_Time            |
 |  02-Jan-2006 akoduri Bug#4611303 - Support For Enable/Disable All         |
 |                       In Report Designer                                  |
 | 05-JAN-06    ppandey  Enh#4860106 Defined Is_More as a public function    |
 | 13-JAN-06    adrao                                                        |
 | The following APIs have been added as a part of the Enhancement#3909868   |
 |                                                                           |
 |  Validate_Plsql_For_Report                                                |
 |      -- actual api to validation the pl/sql for the report                |
 |  Get_Plsql_Parameters                                                     |
 |      -- gets the pl/sql report for the passed pl/sql procedure            |
 |  Remove_Repeating_Comma                                                   |
 |      -- Removes and parses repeating comma's                              |
 |  Validate_PLSQL                                                           |
 |      -- Validates existentially the pl/sql package anderformes some       |
 |         validation apis                                                   |
 |  Obtain_Report_Query                                                      |
 |      -- Does the job of actually getting the Report query                 |
 |  Insert_Into_Query_Table                                                  |
 |      -- An API to insert into the PL/SQL table.                           |
 |  Do_DDL_AT                                                                |
 |      -- Autonously call DDL statements, used in our case for creating     |
 |         and dropping views                                                |
 |  Validate_Sql_String                                                      |
 |      -- Validate's if a SQL string is ok by creating a view               |
 |  Sort_String                                                              |
 |     -- sorts a comma separated string values                              |
 |                                                                           |
 |  19-JUN-2006 adrao   Added util API Create_Unique_Comma_List &            |
 |                      Get_Unique_List for Bug#5300060                      |
 |     09-feb-2007 ashankar Simulation Tree Enhacement 5386112               |
 |  21-MAR-2007 akoduri Copy Indicator Enh#5943238                           |
 +===========================================================================*/
/*----------------------------------------------------------------------------
 FILE NAME

    BSCUTILS.pls

 PACKAGE NAME

    bsc_utility

 DESCRIPTION

    Contains debuging and utility functions and procedures.

 PUBLIC PROCEDURES/FUNCTIONS

 HISTORY
 15-JAN-1999    Srinivasan Jandyala Created
 22-JAN-1999    Alex Yang       Added Do_SQL() procedure
 29-MAR-2001    Srini               Added PROCEDURE update_edw_flag.
 21-DEC-2001    Mario-Jair Campos   Added procedures:  get_dataset_id
                               get_kpi_dim_levels
 27-DEC-2001    Srini                   Added function:get_kpi_dim_level_short_names
 12-MAR-2002    M. Jair Campos      Added system time stamp function.
 23-APR-2003    mdamle          Added the toStringArray and ToNumberArray
 23-APR-2003    mdamle          Added the Add_To_Fnd_Msg_Stack
 27-FEB-2004    adeulgao fixed bug#3431750
 16-JUN-2004    ADRAO added API Is_BSC_Licensed() for Bug#3764205
 21-DEC-2004    adrao added type DIMOBJ_SHORT_NAME_CLASS for Bug#4079898
 31-MAR-2005    adrao added API is_Mix_Dim_Objects_Allowed
 24-JAN-2006    ankgoel     Bug#4954663 Show Info text for AG to PL/SQL or VB conversion
 08-FEB-2006    akoduri     Bug#4956836 Updating dim object cache should
                            invalidate AK Cache also
 04-OCT-2007    sirukull  Bug#6406844. Comparing Leapyear daily periodicity  |
   			  data with non-leapyear data.			     |

 ----------------------------------------------------------------------------*/
-----------------------------------------------------------------------------
-- Public Variables
-----------------------------------------------------------------------------
-- Linefeed character
--
CRLF                CONSTANT VARCHAR2(1) := '
';

YES                     CONSTANT VARCHAR2(1) := 'Y';
NO                      CONSTANT VARCHAR2(1) := 'N';

MSG_LEVEL_BASIC         CONSTANT NUMBER := 0;
MSG_LEVEL_TIMING        CONSTANT NUMBER := 1;
MSG_LEVEL_DEBUG         CONSTANT NUMBER := 2;
MSG_LEVEL_DEBUG2        CONSTANT NUMBER := 3;
MSG_LEVEL_DEVELOP       CONSTANT NUMBER := 10;
NO_IND_DIM_OBJ_LIMIT    CONSTANT NUMBER := 10;

PRODUCTION_MODE        CONSTANT VARCHAR2(10) := 'PRODUCTION';
PROTOTYPE_MODE         CONSTANT VARCHAR2(9)  := 'PROTOTYPE';
INVALID_MODE           CONSTANT VARCHAR2(9)  := 'INVALID';
BSC_APP_ID             CONSTANT NUMBER  := 271;
INVALID_CUST_VIEW_NAME CONSTANT VARCHAR2(25) := 'INVALID_INTERNAL_NAME';
BSC_CUSTOM_VIEW        CONSTANT VARCHAR2(25) := 'CUSTOMVIEW';

MAX_DIM_IN_DIM_SET      CONSTANT NUMBER := 20;  -- Added for the Maximum number of Dimension Object that can exist
                                                -- within a Dimension Set for Bug# 3141813
msg_level       NUMBER := MSG_LEVEL_DEVELOP;


c_BSC               CONSTANT VARCHAR2(3) := 'BSC';

c_ADV_SUMMARIZATION_LEVEL       CONSTANT VARCHAR2(32) := 'BSC_ADVANCED_SUMMARIZATION_LEVEL';

c_BSC_MEASURE          CONSTANT VARCHAR(11) := 'BSC_MEASURE';
c_BSC_DIMENSION        CONSTANT VARCHAR(13) := 'BSC_DIMENSION';
c_BSC_DIM_OBJ          CONSTANT VARCHAR(11) := 'BSC_DIM_OBJ';
C_BSC_MEASURE_SHORT_NAME CONSTANT VARCHAR2(7) := 'BSC_MES';
C_BSC_UNDERSCORE       CONSTANT VARCHAR2(5) := 'BSC_';

-- Added for Enhancement #3947903
c_PMF              CONSTANT VARCHAR2(3) := 'PMF';
c_CALENDAR         CONSTANT VARCHAR2(30) := 'CALENDAR';
c_DIMENSION        CONSTANT VARCHAR2(9)  :=  'DIMENSION';
c_DIM_OBJ          CONSTANT VARCHAR2(7)  :=  'DIM_OBJ';
c_DIM_OBJ_REL      CONSTANT VARCHAR2(16) :=  'DIM_OBJ_RELATION';
c_MEASURE          CONSTANT VARCHAR2(7)  :=  'MEASURE';

c_CREATE          CONSTANT VARCHAR2(6)   :=  'CREATE';
c_UPDATE          CONSTANT VARCHAR2(6)   :=  'UPDATE';
c_DELETE          CONSTANT VARCHAR2(6)   :=  'DELETE';

c_MIXED_DIM_OBJS  CONSTANT VARCHAR2(14)   :=  'MIXED_DIM_OBJS';

-- added for Dimension entity validations
c_DIMENSION_OBJECT CONSTANT VARCHAR2(30) := 'DIMENSION_OBJECT';

-- BSC AND BIS RESPONSIBILITIES
c_BSC_Manager    CONSTANT VARCHAR2(11) :=  'BSC_Manager';
c_BSC_DESIGNER   CONSTANT VARCHAR2(12) :=  'BSC_DESIGNER';
c_BSC_PMD_USER   CONSTANT VARCHAR2(12) :=  'BSC_PMD_USER';
c_BIS_BID_RESP   CONSTANT VARCHAR2(12) :=  'BIS_BID_RESP';
c_BIS_DBI_ADMIN  CONSTANT VARCHAR2(13) :=  'BIS_DBI_ADMIN';

-- BIS Report Constants
C_ATTRIBUTE_CATEGORY  CONSTANT VARCHAR2(22)     := 'BIS PM Viewer';
C_REPORT_TYPE_MDS     CONSTANT VARCHAR2(22)     := 'MULTIPLE_DATA_SOURCE';
C_REPORT_TYPE_TABLE   CONSTANT VARCHAR2(20)     := 'TABLE_DATA_SOURCE';

---
C_MEASURE_SOURCE_CDS      CONSTANT VARCHAR2(22)  := 'CDS';
C_MEASURE_TYPE_CDS_SCORE  CONSTANT VARCHAR2(22)  := 'CDS_SCORE';
C_MEASURE_TYPE_CDS_PERF   CONSTANT VARCHAR2(22)  := 'CDS_PERF';
C_MEASURE_SOURCE_CDS_CALC CONSTANT VARCHAR2(22)  := 'CDS_CALC';

C_ATTRTYPE_MEASURE           CONSTANT  VARCHAR2(30)  := 'MEASURE';
C_ATTRTYPE_MEASURE_NO_TARGET CONSTANT  VARCHAR2(30)  := 'MEASURE_NOTARGET';
C_BUCKET_MEASURE             CONSTANT  VARCHAR2(30)  := 'BUCKET_MEASURE';
C_SUB_MEASURE                CONSTANT  VARCHAR2(30)  := 'SUB MEASURE';
C_MULTIPLE_DATA_SOURCE       CONSTANT  VARCHAR2(30)  := 'MULTIPLE_DATA_SOURCE';


TYPE varchar_tabletype IS TABLE OF varchar2(32000) INDEX BY binary_integer;

-- added for Bug#4079898
TYPE DIMOBJ_SHORT_NAME_CLASS IS VARRAY(20) OF BIS_LEVELS.SHORT_NAME%TYPE;


-- added for Enh to Validate PL/SQL procedure.
TYPE PARAMETER_CLASS IS VARRAY(30) OF VARCHAR2(1024);

C_REPORT_PARAMETER_CLASS CONSTANT PARAMETER_CLASS :=  PARAMETER_CLASS (
 'BIS_CURRENT_ASOF_DATE',
 'BIS_CURRENT_EFFECTIVE_END_DATE',
 'BIS_CURRENT_EFFECTIVE_START_DATE',
 'BIS_CURRENT_REPORT_START_DATE',
 'BIS_CUR_REPORT_START_DATE',
 'BIS_FXN_NAME',
 'BIS_ICX_SESSION_ID',
 'BIS_PERIOD_TYPE',
 'BIS_PREVIOUS_ASOF_DATE',
 'BIS_PREVIOUS_EFFECTIVE_END_DATE',
 'BIS_PREVIOUS_EFFECTIVE_START_DATE',
 'BIS_PREVIOUS_REPORT_START_DATE',
 'BIS_PREV_REPORT_START_DATE',
 'BIS_P_ASOF_DATE',
 'BIS_REGION_CODE',
 'BIS_SELECTED_TOP_MANAGER',
 'BIS_TIME_COMPARISON_TYPE',
 'BIS_TOP_MANAGERS',
 'ORDERBY',
 'PERIOD_TYPE',
 'TIME_COMPARISON_TYPE',
 'VIEW_BY',
 '_LOCAL_TIME_PARAM');


/*
Constants for package parser
*/

C_PACKAGE_BODY CONSTANT VARCHAR2(20) := 'PACKAGE BODY';
C_PACKAGE_SPECIFICATION CONSTANT VARCHAR2(20) := 'PACKAGE';
C_PACKAGE_OWNER CONSTANT VARCHAR2(20) := 'APPS';
C_PLSQL_TOKEN_FUNCTION CONSTANT VARCHAR2(30) := 'FUNCTION';
C_PACKAGE_STATUS_VALID VARCHAR2(20) := 'VALID';
C_PACKAGE_STATUS_INVALID VARCHAR2(20) := 'INVALID';
C_PLSQL_TOKEN_PROCEDURE CONSTANT VARCHAR2(30) := 'PROCEDURE';



-----------------------------------------------------------------------------
-- Debugging functions
-----------------------------------------------------------------------------
PROCEDURE enable_debug;
PROCEDURE enable_debug( buffer_size NUMBER );
PROCEDURE disable_debug;
PROCEDURE print_debug( line IN VARCHAR2 ) ;
PROCEDURE print_debug( str VARCHAR2, print_level NUMBER );
PROCEDURE print_fcn_label( p_label VARCHAR2 );
PROCEDURE print_fcn_label2( p_label VARCHAR2 );

-----------------------------------------------------------------------------
TYPE t_array_of_number IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

TYPE t_array_of_varchar2 IS TABLE OF VARCHAR2(32000)
    INDEX BY BINARY_INTEGER;
-----------------------------------------------------------------------------
--
-- x_mode:
--    'N': no insert.
--    'I': insert into BSC_MESSAGE_LOGS immediately.
--
Procedure Debug(
    x_calling_fn    IN  Varchar2,
    x_debug_msg IN  Varchar2 := NULL,
    x_mode      IN  Varchar2 := 'N'
);


-----------------------------------------------------------------------------
-- database Functions/Procedures
-----------------------------------------------------------------------------
PROCEDURE close_cursor(p_cursor_handle IN OUT NOCOPY NUMBER);

Procedure Do_SQL(
    x_sql_stmt  IN  Varchar2,
    x_calling_fn    IN  Varchar2
);

Procedure Do_Rollback;

-----------------------------------------------------------------------------
-- Procedure: update_edw_flag (for BSC v5.0)
-----------------------------------------------------------------------------

-- Purpose: To ENABLE/DISABLE bsc_sys_init.property_code = 'EDW_INSTALLED'.
--          This procedure is called by BUILDER.
--
-- Arguments
--
--  h_call_proc_name: Calling Function/Procedure name.
--  h_mode:           ENABLE/DISABLE mode.
--
-----------------------------------------------------------------------------

PROCEDURE update_edw_flag(
            h_call_proc_name  IN VARCHAR2,
            h_mode            IN VARCHAR2);

-----------------------------------------------------------------------------
-- Function: is_edw_installed (for BSC v5.0)
-----------------------------------------------------------------------------

-- Purpose: To ENABLE/DISABLE menu item 'EDW' in Builder. This function will
--          check if EDW and BSC patch are installed. If they are, then
--          Builder will show menu item 'EDW' enabled, otherwise, disabled.
--
--          This function is called by BUILDER.
--
-- Arguments
--
--  h_call_proc_name: Calling Function/Procedure name.
--
-- Return code
--
--  1 = EDW installed
--  0 = EDW not installed
--
-----------------------------------------------------------------------------

FUNCTION is_edw_installed(h_call_proc_name IN VARCHAR2) RETURN NUMBER;

-----------------------------------------------------------------------------

/* The following function is used to get the dataset id for an analysis
   option.  A function is needed to do this because of the way
   BSC_KPI_ANALYSIS_MEASURES_B handles analysis option ids, it has different
   columns for the different analysis groups.  This Function in a way
   normalizes these columns.
   Parameters for the function are:  BSC KPI Id, Analysis Option group Id,
                                     Analysis Option Id.
*/

function get_dataset_id(
  p_kpi_id              number
 ,p_option_group_id     number
 ,p_option_id       number
) return number;

-----------------------------------------------------------------------------

/*  The following function is used to obtain the dimension levels for a given
    Analysis Option.  This function returns all dimension levels in a single
    string.
*/

function get_kpi_dim_levels(
  p_kpi_id              number
 ,p_dim_set_id          number
) return varchar2;

function get_kpi_dim_level_short_names(
  p_kpi_id              number
 ,p_dim_set_id          number
) return varchar2;

function get_system_timestamp (
  x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY     number
 ,x_msg_data        OUT NOCOPY  varchar2
) return varchar2;

function get_session_error(
  x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) return varchar2;


FUNCTION ListToNumericArray(
    x_string IN VARCHAR2,
    x_number_array IN OUT NOCOPY t_array_of_number,
        x_separator IN VARCHAR2
    ) RETURN NUMBER;

FUNCTION ListToStringArray(
    x_string IN VARCHAR2,
    x_array IN OUT NOCOPY t_array_of_varchar2,
        x_separator IN VARCHAR2
    ) RETURN NUMBER;

PROCEDURE Add_To_Fnd_Msg_Stack
(p_error_tbl        IN  BIS_UTILITIES_PUB.ERROR_TBL_TYPE
,x_msg_count        OUT NOCOPY     NUMBER
,x_msg_data         OUT NOCOPY     VARCHAR2
,x_return_status    OUT NOCOPY     VARCHAR2
);

FUNCTION is_Internal_User RETURN BOOLEAN;

/**************************************************************************************
   FUNCTION get_Next_DispName

   Function to generated names as required by Bug 3137260 , for example if Country
   is passed we will get 'Country 1' if 'Country 5' is passed, we will get
   'Country 6', if 'Country A' is passed, we will get 'Country A 1', etc.
**************************************************************************************/

FUNCTION get_Next_DispName
(
    p_Alias        IN   VARCHAR2
) RETURN VARCHAR2;

FUNCTION get_Next_Name (
   p_Name           IN   VARCHAR2
  ,p_Max_Count      IN   NUMBER
  ,p_Table_Name     IN   VARCHAR2
  ,p_Column_Name    IN   VARCHAR2
  ,p_Character      IN   CHAR
) RETURN VARCHAR2;

/*********************************************************************************
  This function is used to get no of independent dimension objects in a dimension set
  of a given objective
/*********************************************************************************/
FUNCTION get_nof_independent_dimobj
(       p_kpi_id IN NUMBER
    ,   p_dim_set_id IN NUMBER
)RETURN NUMBER;
/*********************************************************************************/


/*********************************************************************************
                            FUNCTION isBscInProductionMode
*********************************************************************************/

FUNCTION isBscInProductionMode
RETURN BOOLEAN;
/*********************************************************************************/
FUNCTION is_MV_Exists(
    p_MV_Name  IN VARCHAR2
) RETURN BOOLEAN;
/*********************************************************************************/
FUNCTION is_View_Exists(
    p_View_Name  IN VARCHAR2
) RETURN BOOLEAN;
/*********************************************************************************/
FUNCTION is_Table_Exists(
    p_Table_Name  IN VARCHAR2
) RETURN BOOLEAN;
/*********************************************************************************/
FUNCTION is_Table_View_Exists(
    p_Table_View_Name  IN VARCHAR2
) RETURN BOOLEAN;
/*********************************************************************************/
FUNCTION get_owner_for_object(
  p_object_name IN VARCHAR2
) RETURN VARCHAR2;
/*********************************************************************************/
FUNCTION is_Indicator_In_Production(
    p_kpi_id  IN NUMBER
) RETURN BOOLEAN;
/*********************************************************************************/
FUNCTION Is_BSC_Licensed
RETURN VARCHAR2;
/*********************************************************************************/
FUNCTION Is_Adv_Summarization_Enabled
RETURN VARCHAR2;
/*********************************************************************************/
FUNCTION Get_Default_Internal_Name(
  p_type IN VARCHAR2
)RETURN VARCHAR2;
/*********************************************************************************/

/*********************************************************************************
         API TO PARSE THE COMMA SEPARATED BASE PERIODS
*********************************************************************************/
PROCEDURE Parse_String
(
     p_List          VARCHAR2
  ,  p_Separator    VARCHAR2
  ,  p_List_Data     OUT NOCOPY BSC_UTILITY.varchar_tabletype
  ,  p_List_number   OUT NOCOPY NUMBER
);

FUNCTION get_Next_Alias
(
  p_Alias        IN   VARCHAR2
) RETURN VARCHAR2;

/*********************************************************************************
         API TO CHECK IF MIXED DIMENSION OBJECTS SHOULD BE ALLOWED AT THE
         DIMENSION AND DIMENSION SET LEVEL
*********************************************************************************/

FUNCTION is_Mix_Dim_Objects_Allowed
RETURN VARCHAR2;

FUNCTION get_valid_bsc_master_tbl_name
(
 p_short_name IN VARCHAR2
)
RETURN VARCHAR2;


FUNCTION Is_Time_Period_Type (
    p_Dimension_Short_Name        IN VARCHAR2
  , p_Dimension_Object_Short_Name IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION is_dim_time_period_type (
  p_dimension_short_name  IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Is_Dim_Object_Periodicity_Type (
    p_Dimension_Object_Short_Name IN VARCHAR2
) RETURN VARCHAR2;


/*
    Dimension Designer validation APIs for multiple entity
*/
PROCEDURE Enable_Dimensions_Entity (
    p_Entity_Type           IN VARCHAR2
  , p_Entity_Short_Names     IN VARCHAR2
  , p_Entity_Action_Type    IN VARCHAR2
  , x_Return_Status         OUT NOCOPY VARCHAR2
  , x_Msg_Count             OUT NOCOPY NUMBER
  , x_Msg_Data              OUT NOCOPY VARCHAR2
);

/*
    Dimension Designer validation APIs
    This API returns "S" under x_Return_Status if the Dimension
    entity can be enabled, else it returns "E" or "U" with
    a valid error message text
*/
PROCEDURE Enable_Dimension_Entity (
    p_Entity_Type           IN VARCHAR2
  , p_Entity_Short_Name     IN VARCHAR2
  , p_Entity_Action_Type    IN VARCHAR2
  , p_Entity_Name           IN VARCHAR2
  , x_Return_Status         OUT NOCOPY VARCHAR2
  , x_Msg_Count             OUT NOCOPY NUMBER
  , x_Msg_Data              OUT NOCOPY VARCHAR2
);

PROCEDURE Check_Weighted_Dimension (
  p_Dim_Short_Names  IN VARCHAR2
, x_Return_Status    OUT NOCOPY VARCHAR2
, x_Msg_Count        OUT NOCOPY NUMBER
, x_Msg_Data         OUT NOCOPY VARCHAR2
);

FUNCTION Is_More
(  p_comma_sep_values  IN  OUT NOCOPY  VARCHAR2
  ,x_value             OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN;

/****************************************************************************************************
This functions returns an unique time based short name .
It Prefixes the word based on type of the object sent in parameter p_Object_Type
****************************************************************************************************/

FUNCTION Get_Unique_Sht_Name_By_Obj_Typ(p_Object_Type IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION Is_Internal_Dimension(p_Short_Name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION Is_Dim_In_AKReport(
    p_Short_Name     IN VARCHAR2
  , p_Entity_Type    IN VARCHAR2 := c_MIXED_DIM_OBJS
)
RETURN VARCHAR2;

PROCEDURE Is_Dim_Obj_In_AKReport(
    p_Short_Names      IN VARCHAR2
  , x_region_codes     OUT NOCOPY FND_TABLE_OF_VARCHAR2_30
  , x_Return_Status    OUT NOCOPY VARCHAR2
  , x_Msg_Count        OUT NOCOPY NUMBER
  , x_Msg_Data         OUT NOCOPY VARCHAR2
);

FUNCTION Get_Report_Name(
    p_Region_Code     IN VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Get_Responsibility_Key RETURN VARCHAR2;

/****************************************************************************************************
These three apis are taken from Is_Internal_Dim. They are required for fixes of bug#4602231
where the Dimension LOV window will only call Is_Internal_AG_Dim and Is_Internal_BIS_Import_Dim
to boost LOV performance. Is_Internal_WKPI_Dim is causing performance issue since it queries
ak_regions without using indexed columns.
****************************************************************************************************/
FUNCTION Is_Internal_AG_Dim(p_Short_Name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION Is_Internal_BIS_Import_Dim(p_Short_Name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION Is_Internal_WKPI_Dim(p_Short_Name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION Is_Internal_VB_Dim(p_Short_Name IN VARCHAR2) RETURN VARCHAR2;


-- added for Bug#4599432
FUNCTION Is_Measure_Seeded (p_Short_Name IN VARCHAR2) RETURN VARCHAR2;


FUNCTION Get_User_Time
(
    p_current_user_time  IN DATE
  , p_date_format        IN VARCHAR2
) RETURN VARCHAR2;


/****************************************************************************************************

 Implementation of SQL Parser Starts from here


 Current Implementation Algorithm
 --------------------------------

 STEP#1: Validate the PL/SQL Procedure passed down from the API
   STEP#1A: Existential check
   STEP#1B: Check if the package has both spec/body
   STEP#1C: Check if the package body/speck has any errors

 STEP#2: Obtain the parameter to pass to the PL/SQL package.
****************************************************************************************************/

PROCEDURE Validate_Plsql_For_Report (
    p_Region_Code           IN VARCHAR2
  , p_Region_Application_Id IN VARCHAR2
  , p_Plsql_Function        IN VARCHAR2
  , p_Attribute_Code        IN VARCHAR2
  , p_Attribute1            IN VARCHAR2
  , p_Attribute2            IN VARCHAR2
  , p_Attribute3            IN VARCHAR2
  , p_Default_Values        IN VARCHAR2
  , x_Return_Status         OUT NOCOPY VARCHAR2
  , x_Msg_Count             OUT NOCOPY NUMBER
  , x_Msg_Data              OUT NOCOPY VARCHAR2
);

-- This API returns the parameter being used for a PL/SQL API, which should have the one parameter
-- and should take the type BIS_PMV_PAGE_PARAMETER_TBL
PROCEDURE Get_Plsql_Parameters (
     p_Report_Function   IN VARCHAR2
   , x_Parameter_1       OUT NOCOPY VARCHAR2
   , x_Parameter_2       OUT NOCOPY VARCHAR2
   , x_Parameter_3       OUT NOCOPY VARCHAR2
   , x_Parameter_1_type  OUT NOCOPY VARCHAR2
   , x_Parameter_2_type  OUT NOCOPY VARCHAR2
   , x_Parameter_3_type  OUT NOCOPY VARCHAR2
   , x_Parameter_1_var   OUT NOCOPY VARCHAR2
   , x_Parameter_2_var   OUT NOCOPY VARCHAR2
   , x_Parameter_3_var   OUT NOCOPY VARCHAR2
);


-- this API trims all moving comma's to a single comma.
FUNCTION Remove_Repeating_Comma (
    p_String IN VARCHAR2
) RETURN VARCHAR2;

-- this API does an existential validation on the PL/SQL Package/function.
PROCEDURE Validate_PLSQL (
    p_Plsql_Function        IN VARCHAR2
  , x_Return_Status         OUT NOCOPY VARCHAR2
  , x_Msg_Count             OUT NOCOPY NUMBER
  , x_Msg_Data              OUT NOCOPY VARCHAR2
);

PROCEDURE Obtain_Report_Query (
    p_Region_Code           IN VARCHAR2
  , p_Region_Application_Id IN VARCHAR2
  , p_Plsql_Function        IN VARCHAR2
  , p_Attribute_Code        IN VARCHAR2
  , p_Attribute1            IN VARCHAR2
  , p_Attribute2            IN VARCHAR2
  , p_Attribute3            IN VARCHAR2
  , p_Default_Values        IN VARCHAR2
  , x_Custom_Sql            OUT NOCOPY VARCHAR2
  , x_Custom_Output         OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
  , x_Custom_Columns        OUT NOCOPY VARCHAR2
  , x_Return_Status         OUT NOCOPY VARCHAR2
  , x_Msg_Count             OUT NOCOPY NUMBER
  , x_Msg_Data              OUT NOCOPY VARCHAR2
);

PROCEDURE Insert_Into_Query_Table (
    x_Param_Table IN OUT NOCOPY BIS_PMV_PAGE_PARAMETER_TBL
  , p_Parameter_Name  IN VARCHAR2
  , p_Parameter_Id    IN VARCHAR2
  , p_Parameter_Value IN VARCHAR2
  , p_Dimension       IN VARCHAR2
  , p_Period_Date     IN DATE
  , p_Operator        IN VARCHAR2
);


-- Procedure to perform transactions autonomously
PROCEDURE Do_DDL_AT(
     p_Statement           IN VARCHAR2,
     p_Statement_Type      IN INTEGER,
     p_Object_Name         IN VARCHAR2,
     p_Fnd_Apps_Schema     IN VARCHAR2,
     p_Apps_Short_Name     IN VARCHAR2
);

PROCEDURE Validate_Sql_String (
    p_Sql_String     IN  VARCHAR2
  , x_Columns        OUT NOCOPY VARCHAR2
  , x_Return_Status  OUT NOCOPY VARCHAR2
  , x_Msg_Count      OUT NOCOPY NUMBER
  , x_Msg_Data       OUT NOCOPY VARCHAR2
);

FUNCTION Sort_String (
  p_String IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION is_bsc_measure_convertible (
  p_dataset_id   IN  NUMBER
, p_region_code  IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION is_src_col_in_formulas (
  p_Source_Col  IN  VARCHAR2
) RETURN VARCHAR2;

/*****************************************************
UTILITY FUNCTION TO RETURN A UNIQUE MERGED LIST
*****************************************************/

FUNCTION Create_Unique_Comma_List (
  p_List1 IN VARCHAR2,
  p_List2 IN VARCHAR2
) RETURN VARCHAR2;

/*****************************************************************************
UTILITY FUNCTION TO RETURN A UNIQUE LIST of TYPE BSC_UTILITY.VARCHAR_TABLETYPE
******************************************************************************/
FUNCTION Get_Unique_List (p_List IN BSC_UTILITY.VARCHAR_TABLETYPE)
RETURN BSC_UTILITY.varchar_tabletype;

FUNCTION is_Calculated_kpi
(
  p_Measure_Short_Name     IN  VARCHAR2
)RETURN VARCHAR2;


FUNCTION Is_Meas_Used_In_Targets
(
  p_Dataset_Id        IN    BSC_SYS_DATASETS_VL.dataset_id%TYPE
) RETURN VARCHAR2;


FUNCTION Is_Wam_Kpi
(
  p_dataset_id    IN   BSC_SYS_DATASETS_VL.dataset_id%TYPE
)RETURN VARCHAR2;


FUNCTION is_Calculated_kpi
(
  p_dataset_id     IN  BSC_SYS_DATASETS_B.dataset_id%TYPE
)RETURN VARCHAR2;


FUNCTION Is_Report_Primary_Data_Source
(
  p_Indicator        IN    BSC_KPIS_B.indicator%TYPE
 ,p_Dataset_Id       IN    BSC_SYS_DATASETS_B.dataset_id%TYPE
) RETURN VARCHAR2;

FUNCTION Is_Meas_Used_In_Wam_Report
(
  p_dataset_id   IN   BSC_SYS_DATASETS_B.dataset_id%TYPE
)RETURN VARCHAR2;


PROCEDURE comp_leapyear_prioryear(
  p_calid IN NUMBER,
  p_cyear IN NUMBER,
  p_pyear IN NUMBER,
  x_result OUT nocopy NUMBER
 );
END BSC_UTILITY;

/
