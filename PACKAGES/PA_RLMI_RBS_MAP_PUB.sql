--------------------------------------------------------
--  DDL for Package PA_RLMI_RBS_MAP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RLMI_RBS_MAP_PUB" AUTHID CURRENT_USER AS
/* $Header: PAFPUT3S.pls 120.1 2005/08/19 16:31:03 mwasowic noship $ */

/* This API derives the Resource list member id and RBS element Id for the
 * given resource list Id / RBS version Id. This procedure calls resource mapping and rbs mapping API
 * depending the parameter p_process_code
 * If p_process_code = 'RES_MAP' then RLMI will be derived by calling resource mapping api
 * If p_process_code = 'RBS_MAP' then RBS element Id will be derived by caling RBS mapping api
 * The following are the possible values for these IN params
 * p_calling_process  IN   varchar2
 *                values  'BUDGET_GENERATION' , 'RBS_REFRESH' , 'COPY_PROJECT'
 * p_process_code     IN   varchar2
 *                values  'RES_MAP', 'RBS_MAP'
 * p_calling_context  IN   varchar2
 *                values  'PLSQL' , 'SELF_SERVICE'
 * p_calling_mode     IN   varchar2
 *                values   'PLSQL_TABLE', 'BUDGET_VERSION'
 *
 * NOTES
 * 1.p_txn_source_id_tab  must be populated with UNIQUE value
 * 2.If the p_calling_mode is 'BUDGET_VERSION' then values passed in plsql and system table params
 *   will be ignored
 * 3.If p_calling_context is 'SELF_SERVICE' then log messages will write to PA_DEBUG.WRITE_LOG()
 *   If p_calling_context is 'PLSQL' then log messages will write to PA_DEBUG.write_file()
 */
PROCEDURE Map_Rlmi_Rbs
( p_budget_version_id 		IN 	Number
,p_project_id 			IN 	Number          Default NULL
,p_resource_list_id		IN 	Number 		Default NULL
,p_rbs_version_id		IN	Number  	Default NULL
,p_calling_process		IN	Varchar2
,p_calling_context		IN	varchar2	Default 'PLSQL'
,p_process_code			IN	varchar2	Default 'RES_MAP'
,p_calling_mode			IN	Varchar2	Default 'PLSQL_TABLE'
,p_init_msg_list_flag		IN	Varchar2	Default 'Y'
,p_commit_flag			IN	Varchar2	Default 'N'
,p_TXN_SOURCE_ID_tab            IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_TXN_SOURCE_TYPE_CODE_tab     IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_PERSON_ID_tab                IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_JOB_ID_tab                   IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_ORGANIZATION_ID_tab          IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_VENDOR_ID_tab                IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_EXPENDITURE_TYPE_tab         IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_EVENT_TYPE_tab               IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_NON_LABOR_RESOURCE_tab       IN  PA_PLSQL_DATATYPES.Char20TabTyp Default PA_PLSQL_DATATYPES.EmptyChar20Tab
,p_EXPENDITURE_CATEGORY_tab     IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_REVENUE_CATEGORY_CODE_tab    IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_NLR_ORGANIZATION_ID_tab      IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_EVENT_CLASSIFICATION_tab     IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_SYS_LINK_FUNCTION_tab        IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_PROJECT_ROLE_ID_tab          IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_RESOURCE_CLASS_CODE_tab      IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_MFC_COST_TYPE_ID_tab         IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_RESOURCE_CLASS_FLAG_tab      IN  PA_PLSQL_DATATYPES.Char1TabTyp  Default PA_PLSQL_DATATYPES.EmptyChar1Tab
,p_FC_RES_TYPE_CODE_tab         IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_INVENTORY_ITEM_ID_tab        IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_ITEM_CATEGORY_ID_tab         IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_PERSON_TYPE_CODE_tab         IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_BOM_RESOURCE_ID_tab          IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_NAMED_ROLE_tab               IN  PA_PLSQL_DATATYPES.Char80TabTyp Default PA_PLSQL_DATATYPES.EmptyChar80Tab
,p_INCURRED_BY_RES_FLAG_tab     IN  PA_PLSQL_DATATYPES.Char1TabTyp  Default PA_PLSQL_DATATYPES.EmptyChar1Tab
,p_RATE_BASED_FLAG_tab          IN  PA_PLSQL_DATATYPES.Char1TabTyp  Default PA_PLSQL_DATATYPES.EmptyChar1Tab
,p_TXN_TASK_ID_tab              IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_TXN_WBS_ELEMENT_VER_ID_tab   IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_TXN_RBS_ELEMENT_ID_tab       IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_TXN_PLAN_START_DATE_tab      IN  PA_PLSQL_DATATYPES.DateTabTyp   Default PA_PLSQL_DATATYPES.EmptyDateTab
,p_TXN_PLAN_END_DATE_tab        IN  PA_PLSQL_DATATYPES.DateTabTyp   Default PA_PLSQL_DATATYPES.EmptyDateTab
,x_txn_source_id_tab		OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp
,x_res_list_member_id_tab       OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp
,x_rbs_element_id_tab           OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp
,x_txn_accum_header_id_tab      OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp
,x_return_status		OUT NOCOPY Varchar2
,x_msg_count			OUT NOCOPY Number
,x_msg_data			OUT NOCOPY Varchar2
) ;

/* This API will be called from Self-Service OR Java pages */
PROCEDURE Map_Rlmi_Rbs
( p_budget_version_id 		IN 	Number
,p_project_id                   IN      Number          Default NULL
,p_resource_list_id		IN 	Number 		Default NULL
,p_rbs_version_id		IN	Number  	Default NULL
,p_calling_process		IN	Varchar2
,p_calling_context		IN	varchar2	Default 'PLSQL'
,p_process_code			IN	varchar2	Default 'RES_MAP'
,p_calling_mode			IN	Varchar2	Default 'PLSQL_TABLE'
,p_init_msg_list_flag		IN	Varchar2	Default 'N'
,p_commit_flag			IN	Varchar2	Default 'N'
,p_TXN_SOURCE_ID_tab            IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_TXN_SOURCE_TYPE_CODE_tab     IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_PERSON_ID_tab                IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_JOB_ID_tab                   IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_ORGANIZATION_ID_tab          IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_VENDOR_ID_tab                IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_EXPENDITURE_TYPE_tab         IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_EVENT_TYPE_tab               IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_NON_LABOR_RESOURCE_tab       IN  system.PA_VARCHAR2_20_TBL_TYPE  Default system.PA_VARCHAR2_20_TBL_TYPE()
,p_EXPENDITURE_CATEGORY_tab     IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_REVENUE_CATEGORY_CODE_tab    IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_NLR_ORGANIZATION_ID_tab      IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_EVENT_CLASSIFICATION_tab     IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_SYS_LINK_FUNCTION_tab        IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_PROJECT_ROLE_ID_tab          IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_RESOURCE_CLASS_CODE_tab      IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_MFC_COST_TYPE_ID_tab         IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_RESOURCE_CLASS_FLAG_tab      IN  system.PA_VARCHAR2_1_TBL_TYPE   Default system.PA_VARCHAR2_1_TBL_TYPE()
,p_FC_RES_TYPE_CODE_tab         IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_INVENTORY_ITEM_ID_tab        IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_ITEM_CATEGORY_ID_tab         IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_PERSON_TYPE_CODE_tab         IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_BOM_RESOURCE_ID_tab          IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_NAMED_ROLE_tab               IN  system.PA_VARCHAR2_80_TBL_TYPE  Default system.PA_VARCHAR2_80_TBL_TYPE()
,p_INCURRED_BY_RES_FLAG_tab     IN  system.PA_VARCHAR2_1_TBL_TYPE   Default system.PA_VARCHAR2_1_TBL_TYPE()
,p_RATE_BASED_FLAG_tab          IN  system.PA_VARCHAR2_1_TBL_TYPE   Default system.PA_VARCHAR2_1_TBL_TYPE()
,p_TXN_TASK_ID_tab              IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_TXN_WBS_ELEMENT_VER_ID_tab   IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_TXN_RBS_ELEMENT_ID_tab       IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_TXN_PLAN_START_DATE_tab      IN  system.PA_DATE_TBL_TYPE         Default system.PA_DATE_TBL_TYPE()
,p_TXN_PLAN_END_DATE_tab        IN  system.PA_DATE_TBL_TYPE         Default system.PA_DATE_TBL_TYPE()
,x_txn_source_id_tab		OUT NOCOPY system.PA_NUM_TBL_TYPE
,x_res_list_member_id_tab       OUT NOCOPY system.PA_NUM_TBL_TYPE
,x_rbs_element_id_tab           OUT NOCOPY system.PA_NUM_TBL_TYPE
,x_txn_accum_header_id_tab      OUT NOCOPY system.PA_NUM_TBL_TYPE
,x_return_status		OUT NOCOPY Varchar2
,x_msg_count			OUT NOCOPY Number
,x_msg_data			OUT NOCOPY Varchar2
) ;

/* This API initializes the required variables into global variables */
PROCEDURE Init_ReqdVariables(
                p_process_code    IN  varchar2
		,p_project_id     IN  Number
                ,p_resource_list_id IN Number
                ,p_rbs_version_id   IN Number
                ,p_budget_version_id IN NUmber );

/* This API inserts records into RBS mapping tmp tables
 * the records will be inserted Based on calling mode
 */
PROCEDURE populate_rbsmap_tmp
        (p_budget_version_id    IN Number
        ,p_calling_mode         IN varchar2
        ,x_return_status        OUT NOCOPY varchar2 ); --File.Sql.39 bug 4440895

/* This API inserts records into Resource mapping tmp tables
 * the records will be inserted Based on calling mode
 */
PROCEDURE populate_resmap_tmp
        (p_budget_version_id    IN Number
        ,p_calling_mode         IN varchar2
        ,x_return_status        OUT NOCOPY varchar2 ); --File.Sql.39 bug 4440895

/* This API reads the output records from  Resource and RBS mapping tmp tables and
 * populates the output plsql and system tables
 */
PROCEDURE populate_resrbsmap_outTbls
          (p_process_code                 IN Varchar2
          ,p_calling_mode                 IN Varchar2
          ,p_resource_list_id             IN Number
          ,p_budget_version_id            IN Number
          ,x_return_status                OUT NOCOPY varchar2
          );

/* This API updates the new frozen RBS version on all affected projects.
 * Befare Calling this API, user has to populate the following global temp Table
 * with all the affected project Ids : PA_RBS_PUSH_TMP1
 * The out param x_return_status will be 'S' in case of Success, 'E'- Error , 'U' - Unexpected Errors
 */
PROCEDURE Push_RBS_Version
                (p_old_rbs_version_id    IN NUMBER
                ,p_new_rbs_version_id    IN NUMBER
                ,x_return_status         OUT NOCOPY  VARCHAR2
                ,x_msg_count             OUT NOCOPY Number
                ,x_msg_data              OUT NOCOPY Varchar2 );

END PA_RLMI_RBS_MAP_PUB ;

 

/
