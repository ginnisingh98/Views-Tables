--------------------------------------------------------
--  DDL for Package BIS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_UTIL" AUTHID CURRENT_USER as
/* $Header: BISUTILS.pls 120.20 2007/04/02 10:18:12 ashankar ship $ */

G_PKG_NAME  Varchar2(30) := 'BIS_UTIL';
G_SHORT_NAME_LEN  Number := 20;
G_BIS_REPORT_TYPE VARCHAR2(100) := 'BISVIEWER';
G_BIS_CACHE_REPORT_TYPE VARCHAR2(100) := 'BISCACHE';
G_ORACLE_REPORT_TYPE VARCHAR2(100) := 'ORAREPORT';

G_SEED_DATAMERGE_USERID  NUMBER := 1;
G_BSC_APP_ID  NUMBER :=  271;

G_FUNC_PARAMETER_PORTLET    VARCHAR2(30) := 'PARAMETER';
G_FUNC_TABLE_PORTLET        VARCHAR2(30) := 'TABLE';
G_FUNC_GRAPH_PORTLET        VARCHAR2(30) := 'GRAPH';
G_FUNC_GENERIC_OA_PORTLET VARCHAR2(30) := 'GENERIC_PORTLET';
G_FUNC_RELATED_LINKS_PORTLET    VARCHAR2(30) := 'RELATED_LINKS';
G_FUNC_KPI_LIST         VARCHAR2(30) := 'KPI_LIST';
G_FUNC_PAGE         VARCHAR2(30) := 'PAGE';
G_FUNC_REPORT           VARCHAR2(30) := 'REPORT';
G_FUNC_CUSTOM_VIEW      VARCHAR2(30) := 'CUSTOMVIEW';
G_FUNC_URL_PORTLET      VARCHAR2(30) := 'URL';

G_ALTER_TABLE   VARCHAR2(30) := 'ALTER';
G_DROP_TABLE    VARCHAR2(30) := 'DROP';

C_FF_PARAM_PARAMETERS   VARCHAR2(30) := 'pParameters';
C_CHAR_PLUS             VARCHAR2(2)  := '+';
C_CHAR_AT_THE_RATE      VARCHAR2(2)  := '@';
C_PARAM_SEP             VARCHAR2(2)  := '&';
C_CHAR_TILDE            VARCHAR2(2)  := '~';
C_CHAR_CARROT           VARCHAR2(2)  := '^';

--
-- Data Types: Records
--
TYPE BIS_Report_Rec_Type IS RECORD
( Report_Type          VARCHAR2(240) := BIS_UTIL.G_BIS_REPORT_TYPE
, ReportFN_Name        VARCHAR2(240)
, Region_Code          VARCHAR2(240)
, Report_Resp_ID       VARCHAR2(240)
, Report_Params        VARCHAR2(32000)
);
--
TYPE BIS_Cached_Report_Rec_Type IS RECORD
( Report_Type          VARCHAR2(240) := BIS_UTIL.G_BIS_CACHE_REPORT_TYPE
, Report_Identifier    VARCHAR2(240)
);
--
TYPE Oracle_Report_Rec_Type IS RECORD
( Report_Type          VARCHAR2(240) := BIS_UTIL.G_ORACLE_REPORT_TYPE
, Report_Name          VARCHAR2(240)
, Report_Params        VARCHAR2(32000)
, Report_Resp_ID       NUMBER
);
--

-- Data Types: Tables
--
TYPE BIS_Report_Tbl_Type IS TABLE OF BIS_Report_Rec_Type
INDEX BY BINARY_INTEGER;
--
TYPE BIS_Cached_Report_Tbl_Type IS TABLE OF BIS_Cached_Report_Rec_Type
INDEX BY BINARY_INTEGER;
--
TYPE Oracle_Report_Tbl_Type IS TABLE OF Oracle_Report_Rec_Type
INDEX BY BINARY_INTEGER;
--
TYPE Report_URL_Tbl_Type IS TABLE OF VARCHAR2(32000)
INDEX BY BINARY_INTEGER;

G_DEF_Report_URL_Tbl Report_URL_Tbl_Type;

-- Procedures
--

PROCEDURE  Validate_For_Update
( p_last_update_date  IN   DATE
 ,p_owner             IN   VARCHAR2
 ,p_force_mode        IN   BOOLEAN
 ,p_table_name        IN   VARCHAR2
 ,p_key_value         IN   VARCHAR2
 ,x_ret_code          OUT  NOCOPY  BOOLEAN
 ,x_return_status     OUT  NOCOPY  VARCHAR2
 ,x_msg_data          OUT  NOCOPY  VARCHAR2
);

PROCEDURE Get_Update_Date_For_Owner
( p_owner          IN         VARCHAR2
 ,p_last_update_date       IN         VARCHAR2
 ,x_file_last_update_date  OUT NOCOPY DATE
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2
);


Procedure Validate_Short_Name (
   p_short_name     IN  VARCHAR2
  ,x_return_status  OUT NOCOPY  Varchar2
  ,x_msg_count          OUT NOCOPY  NUMBER
  ,x_msg_data           OUT NOCOPY     Varchar2) ;

-- For 11.5.1 Corrective actions with BIS Reports
--
-- Parameters -
--   IN
--    Item_Type        :the workflow item type
--    wf_process       :the corrective action (workflow process)
--    notify_resp_name :the responsibility to be notified
--    report_type      :BIS_UTIL.G_ORACLE_REPORT_TYPE for
--                      Oracle Developer2k reports
--                     :BIS_UTIL.G_BIS_REPORT_TYPE for
--                      BIS Generated reports
--                     :BIS_UTIL.G_BIS_CACHE_REPORT_TYPE for
--                      BIS Cached reports
--    reportFN_name    :the function name of your report
--                      example: 'BIS_PRODUCT_QUALITY'
--    region_code      :the AK region code for your report
--                      example: 'PRODUCT_QUALITY'
--    report_resp_id   :the responsibility the report is secured by
--    report_identifier :the Concurrent Request ID
--   OUT NOCOPY
--    return_status: S = corrective action started successfully
--                   E = expected error; corrective action not started
--                   U = unexpected error; corrective action not started

Procedure Start_Workflow
(p_exception_message     IN Varchar2
,p_msg_subject           IN Varchar2
,p_exception_date        IN date
,p_item_type             IN Varchar2
,p_wf_process            IN Varchar2
,p_notify_resp_name      IN Varchar2
,p_BIS_Report_Tbl        IN BIS_UTIL.BIS_Report_Tbl_Type
,p_BIS_Cached_Report_Tbl IN BIS_UTIL.BIS_Cached_Report_Tbl_Type
,x_return_status         OUT NOCOPY Varchar2);

-- For 11.5.1 Corrective actions with Oracle Reports
--
-- Parameters -
--   IN
--    Item_Type        :the workflow item type
--    wf_process       :the corrective action (workflow process)
--    notify_resp_name :the responsibility to be notified
--    report_typeN     :BIS_UTIL.G_ORACLE_REPORT_TYPE for
--                      Oracle Developer2k reports
--                     :BIS_UTIL.G_BIS_REPORT_TYPE for
--                      BIS Generated reports
--    report_nameN     :the name of your report (example: WSHDOCCT).
--    report_paramN    :the parameters used by your report
--                      (example: 'p_warehouse='|| to_char(l_organization_id))
--    report_respN_id  :the responsibility the report is secured by
--   OUT NOCOPY
--    return_status: S = corrective action started successfully
--                   E = expected error; corrective action not started
--                   U = unexpected error; corrective action not started

Procedure Start_Workflow
(p_exception_message IN Varchar2
,p_msg_subject       IN Varchar2
,p_exception_date    IN date
,p_item_type         IN Varchar2
,p_wf_process        IN Varchar2
,p_notify_resp_name  IN Varchar2
,p_Oracle_Report_Tbl IN BIS_UTIL.Oracle_Report_Tbl_Type
,x_return_status    OUT NOCOPY      Varchar2);

-- For 11.5 Corrective actions with Oracle Reports
--
-- Parameters -
--   IN
--    Item_Type        :the workflow item type
--    wf_process       :the corrective action (workflow process)
--    notify_resp_name :the responsibility to be notified
--    report_nameN     :the name of your report (example: WSHDOCCT).
--    report_paramN    :the parameters used by your report
--                      (example: 'p_warehouse='|| to_char(l_organization_id))
--    report_respN_id  :the responsibility the report is secured by
--   OUT NOCOPY
--    return_status: S = corrective action started successfully
--                   E = expected error; corrective action not started
--                   U = unexpected error; corrective action not started

Procedure Strt_Wf_Process
   (p_exception_message Varchar2
   ,p_msg_subject       Varchar2
   ,p_exception_date    date
   ,p_item_type         Varchar2
   ,p_wf_process        Varchar2
   ,p_notify_resp_name  Varchar2
   ,p_report_name1      Varchar2 default null
   ,p_report_param1     Varchar2 default null
   ,p_report_resp1_id   number   default null
   ,p_report_name2      Varchar2 default null
   ,p_report_param2     Varchar2 default null
   ,p_report_resp2_id   number   default null
   ,p_report_name3      Varchar2 default null
   ,p_report_param3     Varchar2 default null
   ,p_report_resp3_id   number   default null
   ,p_report_name4      Varchar2 default null
   ,p_report_param4     Varchar2 default null
   ,p_report_resp4_id   number   default null
   ,x_return_status OUT NOCOPY      Varchar2
   ,p_report_app1_id    number   default null
   ,p_report_app2_id    number   default null
   ,p_report_app3_id    number   default null
   ,p_report_app4_id    number   default null);

-- 1.2.x corrective actions
--
Procedure Strt_Wf_Process
   (p_exception_message Varchar2
   ,p_msg_subject       Varchar2
   ,p_exception_date    date
   ,p_wf_process        Varchar2
   ,p_report_name1      Varchar2 default null
   ,p_report_param1     Varchar2 default null
   ,p_report_name2      Varchar2 default null
   ,p_report_param2     Varchar2 default null
   ,p_report_name3      Varchar2 default null
   ,p_report_param3     Varchar2 default null
   ,p_report_name4      Varchar2 default null
   ,p_report_param4     Varchar2 default null
   ,p_role          Varchar2
   ,p_responsibility_id number
   ,x_return_status OUT NOCOPY Varchar2
   ,p_application_id    number default null);

PROCEDURE Get_Time_Level_Value
( p_Date               IN DATE default SYSDATE
, p_Target_Level_ID    IN NUMBER
, p_Organization_ID    IN NUMBER
, x_Time_Level_Value   OUT NOCOPY VARCHAR2
, x_Return_Status      OUT NOCOPY VARCHAR2
);


PROCEDURE Get_Time_Level_Value
( p_Date               IN DATE default SYSDATE
, p_Target_Level_ID    IN NUMBER
, p_Organization_ID    IN VARCHAR2
, x_Time_Level_Value   OUT NOCOPY VARCHAR2
, x_Return_Status      OUT NOCOPY VARCHAR2
);


/* Procedure Name : Get_Eps
   Profiles BIS_EPS_SHARES_IN_ISSUE : Shares in Issue
            BIS_EPS_EST_TAX_RATE    : Estimated Tax Rate
   Parameters
     IN  p_change_in_income : Change in Income
     Out NOCOPY p_change_in_eps : where EPS :=
                             (Change in Income *(1-(Estimated tax rate/100)))
                                     / Shares In Issue;
         p_result  0 - Success
                   1 - Shares in Issue not defined or <= 0
                         p_exception_msg Set to message text for message
                                BIS_SHARES_IN_ISSUE_UNDEFINED
                   2 - tax rate not defined
                         p_exception_msg Set to message text for message
                                BIS_EST_TAX_RATE_UNDEFINED
                   3 - Unexpected error, p_exception_msg is set with internal
                       oracle error message
         p_exception_msg := Internal Error Set to sqlerrmc in case of an
                              Internal Exception
*/
Procedure Get_EPS
         ( p_change_in_income   in Number
         ,p_change_in_eps     out NOCOPY Number
         ,p_result  out NOCOPY Number
         ,p_exception_msg OUT NOCOPY Varchar2);

function EPS_PRECISION_FORMAT_MASK
         ( currency_code in varchar2
         , field_length  in number)

         return VARCHAR2;

-- To start the workflow engine
--
Procedure Start_Workflow_Engine
(p_exception_message IN Varchar2
,p_msg_subject       IN Varchar2
,p_exception_date    IN date
,p_item_type         IN Varchar2
,p_wf_process        IN Varchar2
,p_notify_resp_name  IN Varchar2
,p_live_report_url_tbl   IN BIS_UTIL.Report_URL_Tbl_Type
   Default G_DEF_Report_URL_Tbl
,p_cached_report_url_tbl IN BIS_UTIL.Report_URL_Tbl_Type
   Default G_DEF_Report_URL_Tbl
,x_return_status     OUT NOCOPY VARCHAR2
);

-- Build BIS generated report URL
--
Procedure Build_Report_URL
( p_report_type      IN VARCHAR2 default BIS_UTIL.G_BIS_REPORT_TYPE
, p_reportFN_name    IN Varchar2
, p_region_code      IN Varchar2
, p_report_resp_id   IN VARCHAR2
, p_report_params    IN VARCHAR2
, x_report_url       OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
);

-- Build BIS cached report URL
--
Procedure Build_Report_URL
( p_report_type        IN VARCHAR2 default BIS_UTIL.G_BIS_CACHE_REPORT_TYPE
, p_report_identifier  IN VARCHAR2
, x_report_url         OUT NOCOPY VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
);

-- Build regular Oracle report URL
--
Procedure Build_Report_URL
( p_report_type      IN VARCHAR2 default BIS_UTIL.G_ORACLE_REPORT_TYPE
, p_report_name      IN Varchar2
, p_report_params    IN Varchar2
, p_report_resp_id   IN NUMBER
, x_report_url       OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, p_report_app_id    IN NUMBER default null
);

FUNCTION show_application
( p_application_id  IN NUMBER
, p_created_by  IN  NUMBER
)
RETURN NUMBER;

FUNCTION show_application
( p_application_id  IN NUMBER
)
RETURN NUMBER;

FUNCTION is_dev_env_set
RETURN BOOLEAN;

FUNCTION is_internal_customer
RETURN BOOLEAN;

FUNCTION get_default_application_id
RETURN NUMBER;

FUNCTION get_object_type
( p_function_type  IN FND_FORM_FUNCTIONS.type%TYPE
, p_parameters     IN FND_FORM_FUNCTIONS.parameters%TYPE
, p_web_html_call  IN FND_FORM_FUNCTIONS.web_html_call%TYPE
)
RETURN VARCHAR2;

FUNCTION Get_Apps_Id_By_Short_Name (p_Application_Short_Name IN VARCHAR2) RETURN NUMBER;

FUNCTION get_dim_objects_by_dim
( p_dimension  IN VARCHAR2
, p_allow_all          IN VARCHAR2 := FND_API.G_FALSE --Added for bug 5250723
, p_append_short_names IN VARCHAR2 := FND_API.G_TRUE
)
RETURN VARCHAR2;

PROCEDURE save_prototype_values
( p_dim_object  IN VARCHAR2
, p_PV_array    IN BIS_STRING_ARRAY
);

FUNCTION get_Pages_Using_ParamPortlet
( p_Region_Code    IN  VARCHAR2
, x_Return_Status  OUT NOCOPY VARCHAR2
, x_Msg_Count      OUT NOCOPY NUMBER
, x_Msg_Data       OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE get_default_dim_object_value
( p_dim_object  IN VARCHAR2
, p_dimension   IN VARCHAR2
, p_id          IN VARCHAR2
, x_id          OUT NOCOPY VARCHAR2
, x_value       OUT NOCOPY VARCHAR2
);

PROCEDURE get_parent_objects
( p_dep_object_name       IN VARCHAR2
, p_dep_object_type       IN VARCHAR2
, p_parent_object_type    IN VARCHAR2
, x_parent_objects        OUT NOCOPY VARCHAR2
, x_parent_object_owners  OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
);

PROCEDURE get_parent_objects
( p_dep_object_name       IN VARCHAR2
, p_dep_object_type       IN VARCHAR2
, p_parent_object_type    IN VARCHAR2
, x_parent_objects        OUT NOCOPY VARCHAR2
, x_parent_user_objects   OUT NOCOPY VARCHAR2
, x_parent_object_owners  OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
);

FUNCTION get_dims_for_region(
  x_RegionCode IN VARCHAR2
 )
 RETURN VARCHAR2;

PROCEDURE Check_Portlet_Dependency(
  p_portlet_func_name    IN             VARCHAR2
, p_portlet_type         IN             VARCHAR2
, x_parent_obj_exist     OUT NOCOPY     VARCHAR2
, x_parent_obj_list      OUT NOCOPY     VARCHAR2
, x_return_status        OUT NOCOPY     VARCHAR2
, x_msg_count            OUT NOCOPY     NUMBER
, x_msg_data             OUT NOCOPY     VARCHAR2
);

/* procedure to check dependency for objects like Graph, Custom View, etc
   Return the full list of dependency if p_list_dependency = FND_API.G_TRUE
   */

PROCEDURE Check_Object_Dependency(
   p_param_search_string   IN         VARCHAR2
  ,p_obj_portlet_type      IN         VARCHAR2
  ,p_list_dependency       IN         VARCHAR2
  ,x_exist_dependency      OUT NOCOPY VARCHAR2
  ,x_dep_obj_list          OUT NOCOPY VARCHAR2
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
);

PROCEDURE get_respId_for_measure_report (
  p_function_name  IN VARCHAR2
, p_region_code    IN VARCHAR2
, p_owner          IN VARCHAR2
, x_resp_id        OUT NOCOPY NUMBER
, x_sec_grp_id     OUT NOCOPY NUMBER
);

FUNCTION inv_dim_dimlevel_rel (
  p_comma_sep_dim_dimlevel IN VARCHAR2
)
RETURN VARCHAR2;


FUNCTION is_Seeded  (
  p_created_By IN NUMBER
)
RETURN NUMBER;

FUNCTION is_Seeded  (
  p_created_By IN NUMBER
, p_TrueValue  IN VARCHAR2
, p_FalseValue IN VARCHAR2
)
RETURN VARCHAR2;

FUNCTION is_dim_plus_dimlevel_invalid (
  p_dim_plus_dimlevel IN VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE get_previous_asofdate
( p_dimensionlevel        IN   VARCHAR2
, p_time_comparison_type  IN   VARCHAR2
, p_asof_date             IN   DATE
, x_prev_asofdate         OUT  NOCOPY DATE
, x_return_status         OUT  NOCOPY VARCHAR2
, x_msg_count             OUT  NOCOPY NUMBER
, x_msg_data              OUT  NOCOPY VARCHAR2
);

FUNCTION get_measure_name(
  p_region_code  IN VARCHAR2,
  p_attribute1   IN VARCHAR2,
  p_attribute2   IN VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE get_next_measure_data_source
( p_measure_short_name     IN   VARCHAR2
, p_current_region_code    IN   VARCHAR2
, p_current_region_appid   IN   NUMBER
, x_next_region_code       OUT  NOCOPY VARCHAR2
, x_next_region_appid      OUT  NOCOPY NUMBER
, x_next_source_attrcode   OUT  NOCOPY VARCHAR2
, x_next_source_appid      OUT  NOCOPY NUMBER
, x_next_compare_attrcode  OUT  NOCOPY VARCHAR2
, x_next_compare_appid     OUT  NOCOPY NUMBER
, x_next_function_name     OUT  NOCOPY VARCHAR2 --Bug 5495960
, x_next_enable_link       OUT  NOCOPY VARCHAR2 --Bug 5495960
);


FUNCTION get_dimen_by_dim_object
( p_dim_lev_short_name  IN VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Is_Simulation_Report
(
  p_region_code     IN ak_regions.region_code%TYPE
)RETURN VARCHAR2;


FUNCTION Get_Default_Value_From_Params
(
   p_parameters     IN    FND_FORM_FUNCTIONS_VL.parameters%TYPE
 , p_attribute2     IN    AK_REGION_ITEMS_VL.attribute2%TYPE
)RETURN VARCHAR2;



end BIS_UTIL;

/
