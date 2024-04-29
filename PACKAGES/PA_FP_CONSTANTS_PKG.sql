--------------------------------------------------------
--  DDL for Package PA_FP_CONSTANTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_CONSTANTS_PKG" AUTHID CURRENT_USER AS
/* $Header: PAFPCNTS.pls 120.0 2005/05/31 03:15:18 appldev noship $ */

Invalid_Arg_Exc Exception ;
Just_Ret_Exc    Exception ; /* This exception can be used to do the
processing typically done before exiting a procedure in one place
(the exception part of this exception handling). This is to avoid
repeating things done during exit of procedure before every RETURN
statement for apis that have multiple return statements.
For eg: Reset_curr_function debug call.  */
MC_Conversion_Failed_Exc Exception;   -- WEBADI UT

G_PREF_COST_ONLY                CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'COST_ONLY';
G_PREF_REVENUE_ONLY             CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'REVENUE_ONLY';
G_PREF_COST_AND_REV_SAME        CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'COST_AND_REV_SAME';
G_PREF_COST_AND_REV_SEP         CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'COST_AND_REV_SEP';

G_BUDGET_ENTRY_LEVEL_TOP        CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'T';
G_BUDGET_ENTRY_LEVEL_LOWEST     CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'L';
G_BUDGET_ENTRY_LEVEL_M          CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'M';
G_BUDGET_ENTRY_LEVEL_PROJECT    CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'P';

G_TASK_PLAN_LEVEL_TOP           CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'TOP';
G_TASK_PLAN_LEVEL_LOWEST        CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'LOWEST';
G_TASK_PLAN_LEVEL_UNPLANNED     CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'UNPLANNED';

G_OPTION_LEVEL_PROJECT          CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PROJECT';
G_OPTION_LEVEL_PLAN_TYPE        CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PLAN_TYPE';
G_OPTION_LEVEL_PLAN_VERSION     CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PLAN_VERSION';

G_RATE_DATE_TYPE_START_DATE     CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'START_DATE';
G_RATE_DATE_TYPE_END_DATE       CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'END_DATE';
G_RATE_DATE_TYPE_FIXED_DATE     CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'FIXED_DATE';

G_BUCKETING_PERIOD_CODE_SE      CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'SE';
G_BUCKETING_PERIOD_CODE_PE      CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PE';
G_BUCKETING_PERIOD_CODE_SD      CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'SD';
G_BUCKETING_PERIOD_CODE_PD      CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PD';

G_ELEMENT_TYPE_COST             CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'COST';
G_ELEMENT_TYPE_REVENUE          CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'REVENUE';
G_ELEMENT_TYPE_ALL              CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'ALL';

G_TIME_PHASED_CODE_P            CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'P';
G_TIME_PHASED_CODE_G            CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'G';
G_TIME_PHASED_CODE_R            CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'R';
G_TIME_PHASED_CODE_N            CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'N';

G_PERIOD_TYPE_PA                CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PA';
G_PERIOD_TYPE_GL                CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'GL';

G_CALLING_MODULE_FIN_PLAN       CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'FINANCIAL_PLANNING';
G_CALLING_MODULE_ORG_FORECAST   CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'ORG_FORECAST';
G_CALLING_MODULE_BUDGET         CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'BUDGET';

G_USER_ENTERED                  CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'USER_ENTERED';
G_ROLLED_UP                     CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'ROLLED_UP';

G_RESOURCE_PLANNING_LEVEL_R     CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'R';
G_RESOURCE_PLANNING_LEVEL_G     CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'G';

G_MARGIN_DERIVED_FROM_CODE_R    CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'R';
G_MARGIN_DERIVED_FROM_CODE_B    CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'B';

G_PLAN_CLASS_BUDGET             CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'BUDGET';
G_PLAN_CLASS_FORECAST           CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'FORECAST';

G_AMOUNT_SOURCE_MANUAL_M        CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'M';
G_AMOUNT_SOURCE_ACTUALS_A       CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'A';
G_AMOUNT_SOURCE_COPY_P          CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'P';

G_OBJECT_TYPE_ORG_FORECAST      CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'ORG_FORECAST';
G_OBJECT_TYPE_FIN_PLAN          CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'FIN_PLAN';
G_OBJECT_TYPE_RES_ASSIGNMENT    CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'RES_ASSIGNMENT';

G_BUDGET_STATUS_SUBMITTED       CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'S';
G_BUDGET_STATUS_WORKING         CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'W';
G_BUDGET_STATUS_BASELINED       CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'B';

G_CURRENCY_TYPE_TRANSACTION     CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'TRANSACTION';
G_CURRENCY_TYPE_PROJECT         CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PROJECT';
G_CURRENCY_TYPE_PROJFUNC        CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PROJ_FUNCTIONAL';

G_LABOR_HRS_FROM_CODE_COST      CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'COST';
G_LABOR_HRS_FROM_CODE_REVENUE   CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'REVENUE';

/* others not defined in lookups are */
G_ELEMENT_TYPE_BOTH             CONSTANT VARCHAR2(30) := 'BOTH';
G_ELEMENT_LEVEL_TASK            CONSTANT VARCHAR2(30) := 'TASK';
G_ELEMENT_LEVEL_RESOURCE        CONSTANT VARCHAR2(30) := 'RESOURCE';

G_UNIT_OF_MEASURE_HOURS         CONSTANT VARCHAR2(30) := 'HOURS';
G_UNCLASSIFIED                  CONSTANT VARCHAR2(30) := 'UNCLASSIFIED';
G_UNCATEGORIZED                 CONSTANT VARCHAR2(30) := 'UNCATEGORIZED';

G_DATA_SOURCE_BUDGET_LINE       CONSTANT VARCHAR2(30) := 'BUDGET_LINES';
G_DATA_SOURCE_ROLLUP_TMP        CONSTANT VARCHAR2(30) := 'ROLLUP_TMP';
G_DATA_SOURCE_ORG_FORECAST      CONSTANT VARCHAR2(30) := 'ORG_FORECAST';
G_DATA_SOURCE_COPY_ACTUAL       CONSTANT VARCHAR2(30) := 'COPY_ACTUAL' ;

/*****
G_CALLING_MODULE_FIN_PLAN       CONSTANT VARCHAR2(30) := 'FIN_PLAN';
G_CALLING_MODULE_ORG_FORECAST   CONSTANT VARCHAR2(30) := 'ORG_FORECAST';
*****/

G_PD_PROFILE_FIN_PLANNING       CONSTANT VARCHAR2(30) := 'FINANCIAL_PLANNING';
G_PD_PROFILE_ORG_FORECAST       CONSTANT VARCHAR2(30) := 'ORG_FORECAST';

G_AMOUNT_TYPE_COST              CONSTANT VARCHAR2(30) := 'COST';
G_AMOUNT_TYPE_RAW_COST          CONSTANT VARCHAR2(30) := 'RAW_COST';
G_AMOUNT_TYPE_BURD_COST         CONSTANT VARCHAR2(30) := 'BURDENED_COST';
G_AMOUNT_TYPE_REVENUE           CONSTANT VARCHAR2(30) := 'REVENUE';
G_AMOUNT_TYPE_QUANTITY          CONSTANT VARCHAR2(30) := 'QUANTITY';

G_DEBUG_LEVEL1                  CONSTANT NUMBER := 1;
G_DEBUG_LEVEL2                  CONSTANT NUMBER := 2;
G_DEBUG_LEVEL3                  CONSTANT NUMBER := 3;
G_DEBUG_LEVEL4                  CONSTANT NUMBER := 4;
G_DEBUG_LEVEL5                  CONSTANT NUMBER := 5;
/* newly added  constants */

G_VERSION_TYPE_COST             CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'COST';
G_VERSION_TYPE_REVENUE          CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'REVENUE';
G_VERSION_TYPE_ALL              CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'ALL';

G_BUDGET_TYPE_CODE_AC           CONSTANT VARCHAR2(30) := 'AC';
G_BUDGET_TYPE_CODE_AR           CONSTANT VARCHAR2(30) := 'AR';
G_BUDGET_TYPE_CODE_FC           CONSTANT VARCHAR2(30) := 'FC';
G_BUDGET_TYPE_CODE_FR           CONSTANT VARCHAR2(30) := 'FR';

G_BUDGET_AMOUNT_CODE_C          CONSTANT VARCHAR2(30) := 'C';
G_BUDGET_AMOUNT_CODE_R          CONSTANT VARCHAR2(30) := 'R';

G_CALLING_CONTEXT_EDIT		CONSTANT VARCHAR2(30) := 'EDIT' ;
G_CALLING_CONTEXT_VIEW		CONSTANT VARCHAR2(30) := 'VIEW' ;
G_CALLING_CONTEXT_OTHER_CURR    CONSTANT VARCHAR2(30) := 'EDIT_ANOTHER_CURRENCY';

/* Constants for calling context in auto baseline apis*/
G_CREATE_DRAFT       CONSTANT VARCHAR2(30) := 'CREATE_DRAFT' ;
G_AUTOMATIC_BASELINE CONSTANT VARCHAR2(30) := 'AUTOMATIC_BASELINE' ;
/* Constants for calling context in auto baseline apis*/

/*Constants created to indicate the contexts */
G_CR_UP_PLAN_TYPE_PAGE  	CONSTANT VARCHAR2(30) := 'CR_UP_PLAN_TYPE_PAGE';
G_AMG_API                       CONSTANT VARCHAR2(30) := 'AMG_API';
G_WEBADI                        CONSTANT VARCHAR2(30) := 'WEBADI' ;
G_AMG_API_HEADER                CONSTANT VARCHAR2(30) := 'AMG_API_HEADER' ;
G_AMG_API_DETAIL                CONSTANT VARCHAR2(30) := 'AMG_API_DETAIL' ;
G_EDIT_PLAN_LINE_PAGE           CONSTANT VARCHAR2(30) := 'EDIT_PLAN_LINE_PAGE' ;

G_IMPACTED_TASK_LEVEL_T         CONSTANT VARCHAR2(30) := 'T';
G_IMPACTED_TASK_LEVEL_M         CONSTANT VARCHAR2(30) := 'M';
G_IMPACTED_TASK_LEVEL_L         CONSTANT VARCHAR2(30) := 'L';

/*Constants for validating conversion attributes for AMG*/
G_RATE_TYPE_NULL                CONSTANT VARCHAR2(30) := 'RATE_TYPE_NULL';
G_RATE_TYPE_USER                CONSTANT VARCHAR2(30) := 'User';
G_VALID_CONV_ATTR               CONSTANT VARCHAR2(30) := 'VALID_CONV_ATTR';
G_RATE_DATE_NULL                CONSTANT VARCHAR2(30) := 'RATE_DATE_NULL';
G_RATE_DATE_TYPE_NULL           CONSTANT VARCHAR2(30) := 'RATE_DATE_TYPE_NULL';
G_NULL_ATTR                     CONSTANT VARCHAR2(30) := 'NULL_ATTR';

G_COST_TOKEN_MESSAGE            CONSTANT VARCHAR2(30) := 'PA_FP_CURR_ATTRS_COST';
G_REV_TOKEN_MESSAGE             CONSTANT VARCHAR2(30) := 'PA_FP_CURR_ATTRS_REVENUE';
G_PROJECT_TOKEN_MESSAGE         CONSTANT VARCHAR2(30) := 'PA_FP_CURR_ATTRS_PROJECT';
G_PROJFUNC_TOKEN_MESSAGE        CONSTANT VARCHAR2(30) := 'PA_FP_CURR_ATTRS_PROJ_FUNC';

G_RATE_NULL                     CONSTANT VARCHAR2(30) := 'RATE_NULL';


/* constants for pa_budget_versions.plan_processing_code for period profile refresh */
G_PLAN_PROC_CODE_P		CONSTANT VARCHAR2(30) := 'P';
G_PLAN_PROC_CODE_E		CONSTANT VARCHAR2(30) := 'E';
G_PLAN_PROC_CODE_G		CONSTANT VARCHAR2(30) := 'G';
G_PLAN_PROC_CODE_PPP		CONSTANT VARCHAR2(30) := 'PPP';
G_PLAN_PROC_CODE_PPE		CONSTANT VARCHAR2(30) := 'PPE';
G_PLAN_PROC_CODE_PPG		CONSTANT VARCHAR2(30) := 'PPG';

/* Added for bug 3099706 */
-- Following variable is NOT a constant, it is being used as a global variable
-- in PA_AGREEMENT_PUB and PA_BUDGET_PVT packages.

G_CALLED_FROM_AGREEMENT_PUB	VARCHAR2(1) := 'N';



/*Constants Added for FPM Dev - tracking Bug 3354518*/
G_RESOURCE_CLASS_CODE_EQUIP         CONSTANT VARCHAR2(30) := 'EQUIPMENT';
G_RESOURCE_CLASS_CODE_FIN           CONSTANT VARCHAR2(30) := 'FINANCIAL_ELEMENTS';
G_RESOURCE_CLASS_CODE_MAT           CONSTANT VARCHAR2(30) := 'MATERIAL_ITEMS';
G_RESOURCE_CLASS_CODE_PPL           CONSTANT VARCHAR2(30) := 'PEOPLE';
G_CONTEXT_ACTUAL                    CONSTANT VARCHAR2(30) := 'ACTUAL';
G_QUANTITY_EFFORT                   CONSTANT VARCHAR2(30) := 'EFFORT';
G_CONTEXT_PLANNED                   CONSTANT VARCHAR2(30) := 'PLANNED';
G_SYS_STATUS_APPROVED               CONSTANT VARCHAR2(30) := 'CI_APPROVED';
G_CALLING_MODULE_WORKPLAN           CONSTANT VARCHAR2(30) := 'WORKPLAN';
G_CALLING_MODULE_TASK               CONSTANT VARCHAR2(30) := 'TASK_ASSIGNMENT';
G_CALLING_MODULE_FORECAST           CONSTANT VARCHAR2(30) := 'FORECAST';
G_CALC_API_RESOURCE_CONTEXT         CONSTANT VARCHAR2(30) := 'RESOURCE_ASSIGNMENT';
G_CALC_API_BUDGET_LINE              CONSTANT VARCHAR2(30) := 'BUDGET_LINE';
G_VERSION_NAME_WORKPLAN             CONSTANT VARCHAR2(30) := 'WORKPLAN_VERSION';

G_CI_VERSION_AMOUNTS                CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'CI_VERSION_AMOUNTS';
G_PARTIAL_IMPL_VERSION_AMOUNTS      CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PARTIAL_IMPL_VERSION_AMOUNTS';
G_PLAN_TYPE_CWV_AMOUNTS             CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'PLAN_TYPE_CWV_AMOUNTS';
G_BV_IMPL_AMT                       CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'BV_IMPL_AMT';
G_BV_TOTAL                          CONSTANT PA_LOOKUPS.LOOKUP_CODE%TYPE := 'BV_TOTAL';

END PA_FP_CONSTANTS_PKG;

 

/