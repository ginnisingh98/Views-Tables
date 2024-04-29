--------------------------------------------------------
--  DDL for Package BIS_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_UTILITIES_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVUTLS.pls 120.1 2005/12/28 06:05:52 ashankar noship $ */

--  Global constant holding the package name

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'BIS_UTILITIES_PVT';

G_RECORD_SET_SIZE CONSTANT NUMBER := 10;

G_TOP           CONSTANT varchar2(3) := 'TOP';
G_CENTER        CONSTANT varchar2(10) := 'CENTER';
G_QN            CONSTANT varchar2(1) := '?';
G_EQ            CONSTANT varchar2(1) := '=';
G_AND           CONSTANT varchar2(1) := '&';
G_BIS_SEPARATOR CONSTANT varchar2(1) := '-';


G_LANGUAGE         CONSTANT varchar2(10) := 'JavaScript';

G_ACTION_SAVE       CONSTANT varchar2(100) := 'SAVE';
G_ACTION_NEW        CONSTANT varchar2(100) := 'NEW';
G_ACTION_INDICATOR  CONSTANT varchar2(100) := 'INDICATOR';
G_ACTION_INDICATOR_SAVE CONSTANT varchar2(100) := 'INDICATOR_SAVE';
G_ACTION_VIEW_TARGETS      CONSTANT varchar2(100) := 'VIEW_TARGETS';
G_ACTION_VIEW_TARGETS_SAVE CONSTANT varchar2(100) := 'VIEW_TARGETS_SAVE';
G_ACTION_MEASURE    CONSTANT varchar2(100) := 'MEASURE';
G_ACTION_UPDATE     CONSTANT varchar2(100) := 'UPDATE';
G_ACTION_PREVIOUS   CONSTANT varchar2(100) := 'PREVIOUS';
G_ACTION_NEXT       CONSTANT varchar2(100) := 'NEXT';
G_ACTION_BACK       CONSTANT varchar2(100) := 'BACK';
G_ACTION_CANCEL     CONSTANT varchar2(100) := 'CANCEL';
G_ACTION_DONE       CONSTANT varchar2(100) := 'DONE';
G_ACTION_OK         CONSTANT varchar2(100) := 'OK';
G_ACTION_OK_SAVE    CONSTANT varchar2(100) := 'OK_SAVE';
G_ACTION_DELETE     CONSTANT varchar2(100) := 'DELETE';
G_ACTION_SECURITY   CONSTANT varchar2(100) := 'SECURITY';
G_ACTION_REVERT     CONSTANT varchar2(100) := 'REVERT';
G_ACTION_QUERY      CONSTANT varchar2(100) := 'QUERY';
G_ACTION_CHOICE     CONSTANT varchar2(100) := 'CHOICE';
G_ACTION_REFRESH        CONSTANT varchar2(100) := 'REFRESH';

G_CHILD_WINDOW_WIDTH  CONSTANT NUMBER := 700;
G_CHILD_WINDOW_HEIGHT CONSTANT NUMBER := 500;

G_BIS_APPLICATION_ID CONSTANT NUMBER := 191;
G_BIS_APPLICATION_SHORT_NAME CONSTANT VARCHAR2(10) := 'BIS';
G_BIS_REGION_CODE    CONSTANT varchar2(100) := 'BIS_KPI_PROMPTS';

G_ROUND_EDGE  CONSTANT VARCHAR2(1000) := 'ROUND';
G_FLAT_EDGE   CONSTANT VARCHAR2(1000) := 'FLAT';

G_TABLE_LEFT_MARGIN_PERCENT  CONSTANT NUMBER := 1;
G_TABLE_RIGHT_MARGIN_PERCENT CONSTANT NUMBER := 1;

-- Global Variable to flag debugging
-- debug flag; if set to 1, print debug messages, else do not.
G_DEBUG_FLAG          NUMBER;

TYPE HTML_Button_Rec_Type IS RECORD
( left_edge  varchar2(1000)      -- could be G_ROUND_EDGE or G_FLAT_EDGE
, right_edge varchar2(1000)      -- could be G_ROUND_EDGE or G_FLAT_EDGE
, disabled   varchar2(1000)      -- FND_API.G_TRUE or FND_API.G_FALSE
, label      varchar2(32000)    -- what the user sees
, href       varchar2(32000)    -- href iff disabled=FND_API.G_FALSE
);

TYPE HTML_Button_Tbl_Type IS TABLE of HTML_Button_Rec_Type
  INDEX BY BINARY_INTEGER;

TYPE HTML_Table_Element_Rec_Type IS RECORD
( row_num    number
, display_name    varchar2(200)    -- what the user sees
, href       varchar2(2000)
, align      VARCHAR2(10)
, row_span   number
, col_span   number
, attributes VARCHAR2(1000)
);

TYPE HTML_Table_Element_Tbl_Type IS TABLE of HTML_Table_Element_Rec_Type
  INDEX BY BINARY_INTEGER;

TYPE HTML_Tablerow_strings_Tbl_Type IS TABLE of VARCHAR2(32000)
  INDEX BY BINARY_INTEGER;

G_FUNCTION_SUBMIT_FORM_SAVE   CONSTANT VARCHAR(20) := 'submitForm_Save';
G_FUNCTION_SUBMIT_FORM_DELETE CONSTANT VARCHAR(20) := 'submitForm_Delete';
G_FUNCTION_SUBMIT_FORM_NEW    CONSTANT VARCHAR(20) := 'submitForm_New';
G_FUNCTION_SUBMIT_FORM_UPDATE CONSTANT VARCHAR(20) := 'submitForm_Update';
G_FUNCTION_SUBMIT_FORM_BACK   CONSTANT VARCHAR(20) := 'submitForm_Back';
G_FUNCTION_SUBMIT_FORM_NEXT   CONSTANT VARCHAR(20) := 'submitForm_Next';
G_FUNCTION_SUBMIT_FORM_CANCEL CONSTANT VARCHAR(20) := 'submitForm_Cancel';
G_FUNCTION_SUBMIT_FORM_REVERT CONSTANT VARCHAR(20) := 'submitForm_Revert';
G_FUNCTION_SUBMIT_FORM_DONE   CONSTANT VARCHAR(20) := 'submitForm_Done';
--- --- Hold-over from temporary button function change ---
---G_FUNCTION_SUBMIT_FORM_DONE   CONSTANT VARCHAR(20) := 'submitForm_Cancel';
G_FUNCTION_SUBMIT_FORM_OK     CONSTANT VARCHAR(20) := 'submitForm_OK';

-- DATE FORMAT to be used for optimistic locking
G_DATE_FORMAT VARCHAR2(200) := 'DD-MM-YYYY HH24:MI:SS';
G_DUMMY_VALUE                CONSTANT VARCHAR2(10)  := 'ABCXYZZYX';
G_NO_SELECTION_VALUE         CONSTANT VARCHAR2(10)  := 'ABCXYZZYX';

--  Functions/ Procedures

function getPrompt(p_attribute_code varchar2) return varchar2;
function getPrompt
( p_region_code in varchar2
, p_attribute_code in varchar2) return varchar2;

-- sets the html form fields according to null if they are G_MISS type

PROCEDURE PutHtmlNumberTextField
( p_field_name  varchar2
, p_number      number
);

PROCEDURE PutHtmlNumberOptionField
( p_number      number
, p_selected    varchar2 := NULL
, p_value       varchar2 := NULL
);

PROCEDURE PutHtmlNumberHiddenField
( p_field_name  varchar2
, p_number      number
);

PROCEDURE PutHtmlVarcharTextField
( p_field_name  varchar2
, p_varchar     varchar2
);

PROCEDURE PutHtmlVarcharOptionField
( p_varchar     varchar2
, p_selected    varchar2 := NULL
, p_value       varchar2 := NULL
);

PROCEDURE PutHtmlVarcharHiddenField
( p_field_name  varchar2
, p_varchar     varchar2
);

-- function to get message from msg dictionary
FUNCTION Get_FND_Message
( p_message_name IN VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Get_FND_Message
( p_message_name   IN VARCHAR2
, p_msg_param1     IN VARCHAR2
, p_msg_param1_val IN VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Get_FND_Message
( p_message_name   IN VARCHAR2
, p_msg_param1     IN VARCHAR2
, p_msg_param1_val IN VARCHAR2
, p_msg_param2     IN VARCHAR2
, p_msg_param2_val IN VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Get_FND_Message
( p_message_name   IN VARCHAR2
, p_msg_param1     IN VARCHAR2
, p_msg_param1_val IN VARCHAR2
, p_msg_param2     IN VARCHAR2
, p_msg_param2_val IN VARCHAR2
, p_msg_param3     IN VARCHAR2
, p_msg_param3_val IN VARCHAR2
)
RETURN VARCHAR2;

-- these procedures check and puts the error message on the message stack
PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_error_table       IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, x_error_table       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_token1            IN VARCHAR2
, p_value1            IN VARCHAR2
, p_error_table       IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, x_error_table       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_token1            IN VARCHAR2
, p_value1            IN VARCHAR2
, p_token2            IN VARCHAR2
, p_value2            IN VARCHAR2
, p_error_table       IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, x_error_table       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_token1            IN VARCHAR2
, p_value1            IN VARCHAR2
, p_token2            IN VARCHAR2
, p_value2            IN VARCHAR2
, p_token3            IN VARCHAR2
, p_value3            IN VARCHAR2
, p_error_table       IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, x_error_table       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- this procedure adds a message to the error table
PROCEDURE Add_Error_Message
( p_error_msg_id      IN  NUMBER    := NULL
, p_error_description IN  VARCHAR2  := NULL
, p_error_proc_name   IN VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_error_table       IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, x_error_table       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- these procedures check and puts the error message on the message stack
PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
);

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_token1            IN VARCHAR2
, p_value1            IN VARCHAR2
);

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN  VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_token1            IN VARCHAR2
, p_value1            IN VARCHAR2
, p_token2            IN VARCHAR2
, p_value2            IN VARCHAR2
);

PROCEDURE Add_Error_Message
( p_error_msg_name    IN VARCHAR2
, p_error_msg_level   IN NUMBER     := FND_MSG_PUB.G_MSG_LVL_ERROR
, p_error_proc_name   IN VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
, p_token1            IN VARCHAR2
, p_value1            IN VARCHAR2
, p_token2            IN VARCHAR2
, p_value2            IN VARCHAR2
, p_token3            IN VARCHAR2
, p_value3            IN VARCHAR2
);

-- this procedure adds a message to the error table
PROCEDURE Add_Error_Message
( p_error_msg_id      IN  NUMBER    := NULL
, p_error_description IN  VARCHAR2  := NULL
, p_error_proc_name   IN VARCHAR2  := NULL
, p_error_type        IN  VARCHAR2  := BIS_UTILITIES_PUB.G_ERROR
);
--
PROCEDURE PutStyle;

-- This function will return a string
-- The string is a html table with all the images arranged
-- properly in this table according to the buttons desired
-- make sure that the string is max length to avoid overflow problems
PROCEDURE GetButtonString
( p_Button_table in  HTML_Button_Tbl_Type
, x_str          out NOCOPY varchar2
);

-- This function starts table with the
-- standard margins on left and right
-- takes in the number of columns and rows in the table
PROCEDURE tableOpen
( p_num_row  in NUMBER
, p_num_col  in NUMBER
);

PROCEDURE tableClose;

-- these functions put javascript functions in the script with
-- standard name and action

PROCEDURE putSaveFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2 DEFAULT NULL
, p_submit_form     varchar2 DEFAULT FND_API.G_TRUE
);

PROCEDURE putDeleteFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2 DEFAULT NULL
, p_submit_form     varchar2 DEFAULT FND_API.G_TRUE
);

PROCEDURE putNewFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2 DEFAULT NULL
, p_submit_form     varchar2 DEFAULT FND_API.G_TRUE
);

PROCEDURE putUpdateFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2 DEFAULT NULL
, p_submit_form     varchar2 DEFAULT FND_API.G_TRUE
);

PROCEDURE putBackFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2 DEFAULT NULL
, p_submit_form     varchar2 DEFAULT FND_API.G_TRUE
);

PROCEDURE putNextFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2 DEFAULT NULL
, p_submit_form     varchar2 DEFAULT FND_API.G_TRUE
);

PROCEDURE putCancelFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2 DEFAULT NULL
, p_submit_form     varchar2 DEFAULT FND_API.G_TRUE
);

PROCEDURE putRevertFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2 DEFAULT NULL
, p_submit_form     varchar2 DEFAULT FND_API.G_TRUE
);

PROCEDURE putDoneFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2 DEFAULT NULL
, p_submit_form     varchar2 DEFAULT FND_API.G_TRUE
);

PROCEDURE putOkFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2 DEFAULT NULL
, p_submit_form     varchar2 DEFAULT FND_API.G_TRUE
);

PROCEDURE putFunction
( p_form_name       varchar2
, p_action_var      varchar2
, p_str             varchar2 DEFAULT NULL
, p_function_name   varchar2
, p_action          varchar2
, p_submit_form     varchar2 DEFAULT FND_API.G_TRUE
);

PROCEDURE putVerticalSpacer(p_col_num NUMBER);
PROCEDURE putGreyLine(p_col_num NUMBER);

PROCEDURE getGroupBoxString
( p_title_string IN  varchar2
, p_title_bold   IN  varchar2 := FND_API.G_FALSE
, p_data_string  IN  varchar2
, x_str          OUT NOCOPY varchar2
);

PROCEDURE getGroupBoxString
( p_title_string IN  varchar2
, p_title_bold   IN  varchar2 := FND_API.G_FALSE
, p_data_tbl     IN  BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_data_tbl     OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL

);

PROCEDURE getTableString
( p_heading_table  IN  HTML_Table_Element_Tbl_Type
, p_data_table     IN  HTML_Table_Element_Tbl_Type
, p_head_row_count IN  number
, p_data_row_count IN  number
, p_col_count      IN  NUMBER
, x_str            OUT NOCOPY varchar2
);

--Overloaded getTableString Function
PROCEDURE getTableString
(p_heading_table     IN   HTML_Table_Element_Tbl_Type
,p_data_table        IN   HTML_Table_Element_Tbl_Type
,p_head_row_count    IN   number
,p_data_row_count    IN   number
,p_col_count         IN   number
,x_str               OUT NOCOPY  HTML_Tablerow_Strings_Tbl_type
);

-- concatenate the two error tables into one
PROCEDURE concatenateErrorTables
( p_error_Tbl1 IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, p_error_Tbl2 IN  BIS_UTILITIES_PUB.Error_Tbl_Type
, x_error_Tbl  OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- function to return NULL if G_MISS_CHAR
FUNCTION CheckMissChar
( p_char IN VARCHAR2
)
RETURN VARCHAR2;

-- function to return NULL if G_MISS_NUM
FUNCTION CheckMissNum
( p_num IN NUMBER
)
RETURN NUMBER;

FUNCTION CheckMissDate
( p_date IN DATE
)
RETURN DATE;

--
FUNCTION PutNullString
( p_Str    varchar2
, p_align  varchar2
, p_rowspan NUMBER
, p_colspan NUMBER
)
return VARCHAR2;
--
-- the following functions return FND_API.G_TRUE/FND_API.G_FALSE

FUNCTION Value_Missing(
    p_value      IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION Value_Missing(
    p_value      IN NUMBER )
RETURN VARCHAR2;

FUNCTION Value_Missing(
    p_value      IN DATE )
RETURN VARCHAR2;

FUNCTION Value_Not_Missing(
    p_value      IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION Value_Not_Missing(
    p_value      IN NUMBER )
RETURN VARCHAR2;

FUNCTION Value_Not_Missing(
    p_value      IN DATE )
RETURN VARCHAR2;
FUNCTION Value_NULL(
     p_value      IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION Value_NULL(
     p_value      IN NUMBER )
RETURN VARCHAR2;

FUNCTION Value_NULL(
     p_value      IN DATE )
RETURN VARCHAR2;

FUNCTION Value_Not_NULL(
     p_value      IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION Value_Not_NULL(
     p_value      IN NUMBER )
RETURN VARCHAR2;

FUNCTION Value_Not_NULL(
     p_value      IN DATE )
RETURN VARCHAR2;

FUNCTION Value_Missing_Or_Null(  -- 2730145
    p_value      IN VARCHAR )
RETURN VARCHAR2;

FUNCTION Value_Missing_Or_Null(  -- 2730145
    p_value      IN NUMBER )
RETURN VARCHAR2;

FUNCTION Value_Missing_Or_Null(  -- 2730145
    p_value      IN DATE )
RETURN VARCHAR2;

FUNCTION Value_Not_Missing_Not_Null(  -- 2730145
    p_value      IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION Value_Not_Missing_Not_Null(  -- 2730145
    p_value      IN NUMBER )
RETURN VARCHAR2;

FUNCTION Value_Not_Missing_Not_Null(  -- 2730145
    p_value      IN DATE )
RETURN VARCHAR2;

PROCEDURE Set_Debug_Flag;

-- returns FND_API.G_TRUE is OK to convert to ID
-- else FND_API.G_FALSE
FUNCTION Convert_to_ID
( p_id         NUMBER
, p_short_name VARCHAR2
, p_name       VARCHAR2
)
return VARCHAR2;
--
--
procedure Replace_String
( p_string    IN VARCHAR2
, x_string    OUT NOCOPY VARCHAR2
);
--
function target_level_where_clause
return varchar2;

--
function target_level_where_clause
(p_user_id IN NUMBER)
return varchar2;
--
-- Fix for 2254597 starts here
function target_level_where_clause
(p_user_id                    IN NUMBER
,x_return_status              OUT NOCOPY  VARCHAR2
,x_msg_count                  OUT NOCOPY  VARCHAR2
,x_msg_data                   OUT NOCOPY  VARCHAR2
)
return varchar2;
-- Fix for 2254597 ends here
--
function Perf_measure_where_clause
return varchar2;
--
function Perf_measure_where_clause
(p_user_id IN NUMBER)
return varchar2;
--
-- Fix for 2254597 starts here
function Perf_measure_where_clause
(p_user_id                    IN NUMBER
,x_return_status              OUT NOCOPY  VARCHAR2
,x_msg_count                  OUT NOCOPY  VARCHAR2
,x_msg_data                   OUT NOCOPY  VARCHAR2
)
 return varchar2;
-- Fix for 2254597 ends here
--
PROCEDURE resequence_dim_level_values
(p_dim_values_rec   IN   BIS_TARGET_PUB.TARGET_REC_TYPE
,p_sequence_dir     IN   VARCHAR2
,x_dim_values_rec   IN OUT NOCOPY  BIS_TARGET_PUB.TARGET_REC_TYPE
,x_error_tbl        OUT NOCOPY  BIS_UTILITIES_PUB.ERROR_TBL_TYPE
);
--
PROCEDURE reseq_actual_dim_level_values
(p_dim_values_Rec   IN   BIS_ACTUAL_PUB.Actual_rec_type
,p_Sequence_dir     IN   VARCHAR2
,x_dim_values_rec   IN OUT NOCOPY  BIS_ACTUAL_PUB.Actual_rec_type
,x_error_tbl        OUT NOCOPY  BIS_UTILITIES_PUB.ERROR_TBL_TYPE
);
--
PROCEDURE resequence_dim_levels
(p_dim_level_rec    IN   BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE
,p_sequence_dir     IN   VARCHAR2
,x_dim_level_rec    IN OUT NOCOPY  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE
,x_error_tbl        OUT NOCOPY  BIS_UTILITIES_PUB.ERROR_TBL_TYPE
);
--
-- mdamle 01/12/2001 - Resequence Indicator record
PROCEDURE reseq_ind_dim_level_values
(p_dim_values_Rec   IN   BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type
,p_Sequence_dir     IN   VARCHAR2
,x_dim_values_rec   IN OUT NOCOPY  BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type
,x_error_tbl        OUT NOCOPY  BIS_UTILITIES_PUB.ERROR_TBL_TYPE
);
--
FUNCTION GET_SOURCE_FROM_DIM_LEVEL
(p_DimLevelId IN NUMBER  := NULL
,p_DimLevelShortName IN VARCHAR2 := NULL
)
RETURN VARCHAR2;
--
FUNCTION GET_TIME_DIMENSION_NAME
(p_DimLevelId IN NUMBER  := NULL
 ,p_DimLevelName IN VARCHAR2 := NULL
)
RETURN VARCHAR2;
--
FUNCTION GET_ORG_DIMENSION_NAME
(p_DimLevelId IN NUMBER := NULL
 ,p_DimLevelName IN VARCHAR2 := NULL
)
RETURN VARCHAR2;
--
FUNCTION GET_INV_LOC_DIMENSION_NAME -- 2525408
(p_DimLevelId IN NUMBER := NULL
 ,p_DimLevelName IN VARCHAR2 := NULL
)
RETURN VARCHAR2;
--
FUNCTION GET_TIME_DIMENSION_NAME_TL
(p_TargetLevelId IN NUMBER := NULL
 ,p_TargetLevelName IN VARCHAR2 := NULL
)
RETURN VARCHAR2;
--
FUNCTION GET_ORG_DIMENSION_NAME_TL
(p_TargetLevelId IN NUMBER := NULL
 ,p_TargetLevelName IN VARCHAR2 := NULL
)
RETURN VARCHAR2;
--
PROCEDURE  get_org_dim_name_tl_edw
( p_tgt_lvl_short_name   IN VARCHAR2,
  p_tgt_lvl_ID       IN NUMBER,
  x_dimension_short_name OUT NOCOPY VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_return_msg       OUT NOCOPY VARCHAR2);
--
FUNCTION GET_TIME_DIMENSION_NAME_SRC
(p_source IN  VARCHAR2
)
RETURN VARCHAR2;
--
FUNCTION GET_ORG_DIMENSION_NAME_SRC
(p_source IN  VARCHAR2
)
RETURN VARCHAR2;
--
FUNCTION GET_INV_LOC_DIMENSION_NAME_SRC --2525408
(p_source IN  VARCHAR2
)
RETURN VARCHAR2;
--
FUNCTION GET_TOTAL_DIMLEVEL_NAME
(p_dim_short_name    IN    VARCHAR2
 ,p_DimLevelId IN NUMBER := NULL
 ,p_DimLevelName IN VARCHAR2 := NULL
)
RETURN VARCHAR2;
--
FUNCTION GET_TOTAL_DIMLEVEL_NAME_SRC -- 2617369
(p_dim_short_name    IN    VARCHAR2
,p_source            IN    VARCHAR2
)
RETURN VARCHAR2;
--
FUNCTION IS_TOTAL_DIMLEVEL
( p_dim_Level_short_name    IN    VARCHAR2
 ,x_return_status           OUT NOCOPY   VARCHAR2
)
RETURN BOOLEAN;

--
FUNCTION GET_TOTAL_DIMLEVEL_NAME_TL
(p_dim_short_name    IN    VARCHAR2
 ,p_TargetLevelId IN NUMBER := NULL
 ,p_TargetLevelName IN VARCHAR2 := NULL
)
RETURN VARCHAR2;
--
FUNCTION GET_TIME_SHORT_NAME
(p_dim_level_id    IN   NUMBER
)
RETURN VARCHAR2;
--
FUNCTION GET_TIME_FROM
( p_duration         IN   NUMBER
, p_table_name       IN   VARCHAR2
, p_time             IN   VARCHAR2
, p_id               IN   VARCHAR2
, p_id_col_name      IN   VARCHAR2
, p_value_col_name   IN   VARCHAR2
, p_Org_Level_ID     IN   VARCHAR2
, p_Org_Level_Short_name IN   VARCHAR2
, p_time_level_id    IN   NUMBER
, p_time_level_sh_name IN  VARCHAR2
)
RETURN VARCHAR2;
--
FUNCTION GET_TIME_TO
( p_duration         IN   NUMBER
, p_table_name       IN   VARCHAR2
, p_time             IN   VARCHAR2
, p_id               IN   VARCHAR2
, p_id_col_name      IN   VARCHAR2
, p_value_col_name   IN   VARCHAR2
, p_Org_Level_ID     IN   VARCHAR2
, p_Org_Level_Short_name IN   VARCHAR2
, p_time_level_id    IN   NUMBER
, p_time_level_sh_name IN  VARCHAR2
)
RETURN VARCHAR2;
--
Procedure Get_Org_Info_Based_On_Source  -- what to do if org_id/short_name is missing.
( p_source       IN varchar2,
  p_org_level_id     IN varchar2,
  p_org_level_short_name IN varchar2,
  x_org_level_id     OUT NOCOPY varchar2,
  x_org_level_short_name OUT NOCOPY varchar2
);
--
Procedure Get_Time_Level_Value_ID_Minus -- where (sysdate - p_sysdate_less) is between start and end dates..
( p_source      IN varchar2,
  p_view_name       IN varchar2,
  p_id_name         IN varchar2,
  p_org_level_id    IN varchar2,
  p_org_level_short_name IN varchar2,
  p_sysdate_less    IN number,
  x_time_id     OUT NOCOPY varchar2
);
--
Procedure Get_Start_End_Dates   -- where level_value_id = p_id_value_name
( p_source      IN varchar2,    --   and level_value = p_time_value
  p_view_name       IN varchar2,    --   need to merge this and Get_Start_End_Dates2
  p_id_col_name         IN varchar2,
  p_id_value_name       IN varchar2,
  --  p_value_col_name      IN varchar2,
  --  p_time_value          IN varchar2,
  p_org_level_id    IN varchar2,
  p_org_level_short_name IN varchar2,
  x_start_date      OUT NOCOPY date,
  x_end_date        OUT NOCOPY date
);
--
Procedure Get_Time_Level_Value_ID_Date  -- where target_date is between start and end dates..
( p_source      IN varchar2,        -- this and Get_Time_Level_Value_ID1 need to be combined.
  p_view_name       IN varchar2,
  p_id_name         IN varchar2,
  p_org_level_id    IN varchar2,
  p_org_level_short_name IN varchar2,
  p_target_date     IN date,
  x_time_id     OUT NOCOPY varchar2
);
--
FUNCTION Is_Rolling_Period_Level    -- 2408906
(p_level_short_name IN VARCHAR2
)
RETURN NUMBER;
--
FUNCTION get_Roll_Period_Start_Date
( p_level_short_name    IN VARCHAR2
, p_end_date        IN DATE
)
RETURN DATE;
--
--jxyu added for enhancement #2435226
FUNCTION Get_FND_Lookup
( p_lookup_type   IN VARCHAR2
, p_lookup_code   IN VARCHAR2
)
RETURN VARCHAR2;



FUNCTION get_bis_jsp_path
RETURN VARCHAR2;-- 1898436

FUNCTION get_webdb_host
RETURN VARCHAR2; -- 1898436

FUNCTION get_webdb_port
RETURN VARCHAR2; -- 1898436


PROCEDURE get_debug_mode_profile -- 2694978
( x_is_debug_mode   OUT NOCOPY BOOLEAN
, x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
);

PROCEDURE set_debug_log_flag (  -- 2694978
  p_is_true         IN  BOOLEAN
, x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
) ;

FUNCTION is_debug_on RETURN BOOLEAN ;  -- 2694978

PROCEDURE open_debug_log ( -- 2694978
  p_file_name      IN  VARCHAR2,
  p_dir_name       IN  VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_return_msg     OUT NOCOPY VARCHAR2);

PROCEDURE close_debug_log ( -- 2694978
  p_file_name      IN  VARCHAR2,
  p_dir_name       IN  VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_return_msg     OUT NOCOPY VARCHAR2)  ;


--
-- Init_debug_log calls get_debug_mode_profile, sets the value
-- of debug flag (BIS_UTILITIES_PUB.G_IS_DEBUG) using set_debug_log_flag
-- and then opens the log file using open_debug_log.
--
PROCEDURE init_debug_log -- 2694978
( p_file_name       IN  VARCHAR2
, p_dir_name        IN  VARCHAR2
, x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
) ;

PROCEDURE init_debug_flag -- 2694978
( x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
);

PROCEDURE put(p_text IN VARCHAR2) ; -- 2694978

PROCEDURE put_line(p_text IN VARCHAR2) ; -- 2694978

FUNCTION escape_html(
  p_input IN VARCHAR2
)
RETURN VARCHAR2;

FUNCTION escape_html_input(
  p_input IN VARCHAR2
)
RETURN VARCHAR2;

FUNCTION is_valid_time_dimension_level
(
  p_bis_dimlevel_id        IN NUMBER  := NULL
, x_return_status     OUT NOCOPY VARCHAR2
)
RETURN BOOLEAN;

FUNCTION filter_quotes
(
  p_filter_string    IN VARCHAR2
)
RETURN VARCHAR2;

FUNCTION get_role_id
(
  p_role_name    IN VARCHAR2
)
RETURN NUMBER;

FUNCTION getPMVReport
(
  p_report_url  IN VARCHAR2
)
RETURN CLOB;

FUNCTION checkSWANEnabled
RETURN BOOLEAN;

END BIS_UTILITIES_PVT;

 

/
