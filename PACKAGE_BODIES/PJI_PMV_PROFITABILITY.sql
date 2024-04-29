--------------------------------------------------------
--  DDL for Package Body PJI_PMV_PROFITABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PMV_PROFITABILITY" AS
/* $Header: PJIRF04B.pls 120.6.12010000.7 2010/04/12 11:12:29 arbandyo ship $ */

G_Report_Cost_Type VARCHAR2(2);
G_context          VARCHAR2(10) := 'COST'; /* Added for bug 9366920 */

PROCEDURE GET_SQL_PJI_REP_PP1(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
	         		, x_PMV_Sql OUT NOCOPY VARCHAR2
                    		, x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
l_Err_Message   VARCHAR2(3200);
l_PMV_Sql       VARCHAR2(3200);
	BEGIN

         /* Set context */
         G_context := 'PROFIT'; /* Added for bug 9569573 */

		PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
				, P_SELECT_LIST =>
				  ' FACT.CT_REVENUE  "PJI_REP_MSR_14"
				  , FACT.CT_MARGIN_PERCENT  "PJI_REP_MSR_15"
				  , FACT.REVENUE  "PJI_REP_MSR_16"
				  , FACT.MARGIN_PERCENT  "PJI_REP_MSR_17"
				  , FACT.CT_BURDENED_COST  "PJI_REP_MSR_19"
				  , FACT.BURDENED_COST  "PJI_REP_MSR_8"
				  , FACT.REVENUE  "PJI_REP_MSR_1"
				  , FACT.MARGIN  "PJI_REP_MSR_2"
				  , FACT.REVENUE  "PJI_REP_MSR_7"
				  , FACT.REV_CHANGE_PERCENT  "PJI_REP_MSR_11"
				  , FACT.MARGIN  "PJI_REP_MSR_9"
				  , FACT.MAR_CHANGE_PERCENT  "PJI_REP_MSR_12"
				  , FACT.MARGIN_PERCENT  "PJI_REP_MSR_10"
				  , FACT.MAR_PERCENT_CHANGE  "PJI_REP_MSR_13"
				  , FACT.CT_MARGIN  "PJI_REP_MSR_4"
				  , FACT.MARGIN  "PJI_REP_MSR_3"
				  , FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1"
				  , FACT.PJI_REP_TOTAL_11 "PJI_REP_TOTAL_2"
				  , FACT.PJI_REP_TOTAL_14 "PJI_REP_TOTAL_3"
				  , FACT.PJI_REP_TOTAL_15 "PJI_REP_TOTAL_4"
				  , FACT.PJI_REP_TOTAL_16 "PJI_REP_TOTAL_5"
				  , FACT.PJI_REP_TOTAL_5 "PJI_REP_TOTAL_6"
				  , FACT.PJI_REP_TOTAL_12 "PJI_REP_TOTAL_7"
				  , FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_8"
				  , FACT.PJI_REP_TOTAL_11 "PJI_REP_TOTAL_9"
				  , FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_10"
				  , FACT.PJI_REP_TOTAL_9 "PJI_REP_TOTAL_11"
				  , FACT.PJI_REP_TOTAL_9 "PJI_REP_TOTAL_12"
				  , FACT.PJI_REP_TOTAL_10 "PJI_REP_TOTAL_13"
				  , FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_14"
				  , FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_15"
				  , FACT.PJI_REP_TOTAL_9 "PJI_REP_TOTAL_16" '
            		, P_SQL_STATEMENT => x_PMV_Sql
            		, P_PMV_OUTPUT => x_PMV_Output
				, p_Region_Code => 'PJI_REP_PP1'
				, p_PLSQL_Driver => 'PJI_PMV_PROFITABILITY.PLSQLDriver_PJI_REP_PPSUM'
				, p_PLSQL_Driver_Params => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
				  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
				  ', <<CURRENCY+FII_CURRENCIES>>'||
				  ', <<AS_OF_DATE>>'||
           	               ', <<TIME_COMPARISON_TYPE>>'||
				  ', <<PERIOD_TYPE>>'||
				  ', <<VIEW_BY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CODE>> '||
                                  ', NULL'||
                                  ', NULL'||
                                  ', <<PROJECT REVENUE CATEGORY+PJI_REVENUE_CATEGORIES>>'||
                                  ', <<PROJECT REVENUE CATEGORY+PJI_EXP_EVT_TYPES>>'||
                                  ', NULL'
				);
	END GET_SQL_PJI_REP_PP1;

PROCEDURE GET_SQL_PJI_REP_PP2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
	                , x_PMV_Sql OUT NOCOPY VARCHAR2
                    	, x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	l_Err_Message   VARCHAR2(3200);
	l_PMV_Sql       VARCHAR2(3200);
	BEGIN

               PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
				, P_SELECT_LIST =>
				  ' FACT.CT_FORECAST_REVENUE  "PJI_REP_MSR_14"
  				  , FACT.FCST_CT_MARGIN_PERCENT  "PJI_REP_MSR_15"
  				  , FACT.FORECAST_REVENUE  "PJI_REP_MSR_16"
  				  , FACT.FCST_MARGIN_PERCENT  "PJI_REP_MSR_17"
				  , FACT.FORECAST_BURDENED_COST  "PJI_REP_MSR_8"
				  , FACT.CT_FORECAST_BURDENED_COST  "PJI_REP_MSR_19"
				  , FACT.FORECAST_REVENUE  "PJI_REP_MSR_1"
				  , FACT.FCST_MARGIN_PERCENT  "PJI_REP_MSR_2"
				  , FACT.FORECAST_REVENUE  "PJI_REP_MSR_7"
				  , FACT.FCST_REV_CHANGE_PERCENT  "PJI_REP_MSR_11"
				  , FACT.FCST_MARGIN  "PJI_REP_MSR_9"
				  , FACT.FCST_MAR_CHANGE_PERCENT  "PJI_REP_MSR_12"
				  , FACT.FCST_MARGIN_PERCENT  "PJI_REP_MSR_10"
				  , FACT.FCST_MAR_PERCENT_CHANGE  "PJI_REP_MSR_13"
				  , FACT.FCST_CT_MARGIN  "PJI_REP_MSR_3"
				  , FACT.FCST_MARGIN  "PJI_REP_MSR_4"
				  , FACT.PJI_REP_TOTAL_7 "PJI_REP_TOTAL_1"
				  , FACT.PJI_REP_TOTAL_20 "PJI_REP_TOTAL_2"
				  , FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_3"
				  , FACT.PJI_REP_TOTAL_19 "PJI_REP_TOTAL_4"
				  , FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_5"
				  , FACT.PJI_REP_TOTAL_8 "PJI_REP_TOTAL_6"
				  , FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_7"
				  , FACT.PJI_REP_TOTAL_19 "PJI_REP_TOTAL_8"
				  , FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_9"
				  , FACT.PJI_REP_TOTAL_22 "PJI_REP_TOTAL_10"
				  , FACT.PJI_REP_TOTAL_17 "PJI_REP_TOTAL_11"
				  , FACT.PJI_REP_TOTAL_23 "PJI_REP_TOTAL_12"
				  , FACT.PJI_REP_TOTAL_19 "PJI_REP_TOTAL_13"
				  , FACT.PJI_REP_TOTAL_24 "PJI_REP_TOTAL_14"
				  , FACT.PJI_REP_TOTAL_18 "PJI_REP_TOTAL_15"
				  , FACT.PJI_REP_TOTAL_17 "PJI_REP_TOTAL_16" '
                        , P_SQL_STATEMENT => x_PMV_Sql
                        , P_PMV_OUTPUT => x_PMV_Output
				, p_Region_Code => 'PJI_REP_PP2'
				, p_PLSQL_Driver => 'PJI_PMV_PROFITABILITY.PLSQLDriver_PJI_REP_PPSUM'
				, p_PLSQL_Driver_Params => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
				  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
				  ', <<CURRENCY+FII_CURRENCIES>>'||
				  ', <<AS_OF_DATE>>'||
                          ', <<TIME_COMPARISON_TYPE>>'||
				  ', <<PERIOD_TYPE>>'||
				  ', <<VIEW_BY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CODE>> '||
                                  ', NULL'||
                                  ', NULL'||
                                  ', <<PROJECT REVENUE CATEGORY+PJI_REVENUE_CATEGORIES>>'||
                                  ', <<PROJECT REVENUE CATEGORY+PJI_EXP_EVT_TYPES>>'||
                                  ', NULL'
                        );
	END GET_SQL_PJI_REP_PP2;

PROCEDURE GET_SQL_PJI_REP_PP3(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
	            , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
	IS
l_Err_Message   VARCHAR2(3200);
l_PMV_Sql       VARCHAR2(3200);
	BEGIN

             PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
				, P_SELECT_LIST =>
				  ' FACT.AMOUNT_TYPE_LABEL  "VIEWBY"
				  , FACT.P_ACTUAL  "PJI_REP_MSR_7"
				  , FACT.P_ACTUAL1  "PJI_REP_MSR_18"
				  , FACT.P_ACTUAL2  "PJI_REP_MSR_19"
				  , FACT.PY_ACTUAL  "PJI_REP_MSR_8"
				  , FACT.PY_ACTUAL1 "PJI_REP_MSR_20"
				  , FACT.PY_ACTUAL2 "PJI_REP_MSR_21"
				  , FACT.P_CHANGE1  "PJI_REP_MSR_9"
				  , FACT.P_CHANGE11  "PJI_REP_MSR_14"
				  , FACT.P_CHANGE12  "PJI_REP_MSR_15"
				  , FACT.P_FORECAST  "PJI_REP_MSR_10"
				  , FACT.P_FORECAST1  "PJI_REP_MSR_22"
				  , FACT.P_FORECAST2  "PJI_REP_MSR_23"
				  , FACT.PY_FORECAST "PJI_REP_MSR_11"
				  , FACT.PY_FORECAST1 "PJI_REP_MSR_24"
				  , FACT.PY_FORECAST2 "PJI_REP_MSR_25"
				  , FACT.P_CHANGE2   "PJI_REP_MSR_12"
				  , FACT.P_CHANGE21  "PJI_REP_MSR_16"
				  , FACT.P_CHANGE22  "PJI_REP_MSR_17"
				  , FACT.AMOUNT_TYPE_CODE  "PJI_REP_MSR_13"
				  , FACT.P_CHANGE1  "PJI_REP_MSR_1"
				  , FACT.P_CHANGE2  "PJI_REP_MSR_2"
				  , FACT.PJI_REP_URL1  "PJI_REP_URL1"
				  , FACT.PJI_REP_URL2  "PJI_REP_URL2" '
		                  , P_SQL_STATEMENT => x_PMV_Sql
            		         , P_PMV_OUTPUT => x_PMV_Output
				 , p_Region_Code => 'PJI_REP_PP3'
				 , p_PLSQL_Driver => 'PJI_PMV_PROFITABILITY.PLSQLDriver_PJI_REP_PP3'
				 , p_PLSQL_Driver_Params => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
				  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
				  ', <<CURRENCY+FII_CURRENCIES>>'||
				  ', <<AS_OF_DATE>>'||
				  ', <<PERIOD_TYPE>>'||
				  ', <<VIEW_BY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CODE>> '||
                                  ', NULL'||
                                  ', NULL'||
                                  ', <<PROJECT REVENUE CATEGORY+PJI_REVENUE_CATEGORIES>>'||
                                  ', <<PROJECT REVENUE CATEGORY+PJI_EXP_EVT_TYPES>>'||
                                  ', NULL'
                        );
	END GET_SQL_PJI_REP_PP3;


PROCEDURE GET_SQL_PJI_REP_PP4(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
		            , x_PMV_Sql OUT NOCOPY VARCHAR2
        	            , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
	IS
	l_Err_Message   VARCHAR2(3200);
	l_PMV_Sql       VARCHAR2(3200);
BEGIN

            PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
				, P_SELECT_LIST =>
				' FACT.CT_BURDENED_COST  "PJI_REP_MSR_14"
				  , FACT.CT_FORECAST_BURDENED_COST  "PJI_REP_MSR_15"
				  , FACT.CST_CHANGE_PERCENT  "PJI_REP_MSR_1"
				  , FACT.FCST_CST_CHANGE_PERCENT  "PJI_REP_MSR_2"
				  , FACT.BURDENED_COST  "PJI_REP_MSR_3"
				  , FACT.FORECAST_BURDENED_COST  "PJI_REP_MSR_4"
				  , FACT.BURDENED_COST  "PJI_REP_MSR_8"
				  , FACT.CST_CHANGE_PERCENT  "PJI_REP_MSR_9"
				  , FACT.FORECAST_BURDENED_COST  "PJI_REP_MSR_12"
				  , FACT.FCST_CST_CHANGE_PERCENT  "PJI_REP_MSR_10"
				  , FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_1"
				  , FACT.PJI_REP_TOTAL_8 "PJI_REP_TOTAL_2"
				  , FACT.PJI_REP_TOTAL_13 "PJI_REP_TOTAL_3"
				  , FACT.PJI_REP_TOTAL_21 "PJI_REP_TOTAL_4"
				  , FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_5"
				  , FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_6"
				  , FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_7"
				  , FACT.PJI_REP_TOTAL_13 "PJI_REP_TOTAL_8"
				  , FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_9"
				  , FACT.PJI_REP_TOTAL_21 "PJI_REP_TOTAL_10" '
            		, P_SQL_STATEMENT => x_PMV_Sql
            		, P_PMV_OUTPUT => x_PMV_Output
				, p_Region_Code => 'PJI_REP_PP4'
				, p_PLSQL_Driver => 'PJI_PMV_PROFITABILITY.PLSQLDriver_PJI_REP_PPSUM'
				, p_PLSQL_Driver_Params => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
				  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
				  ', <<CURRENCY+FII_CURRENCIES>>'||
				  ', <<AS_OF_DATE>>'||
     	                     ', <<TIME_COMPARISON_TYPE>>'||
				  ', <<PERIOD_TYPE>>'||
				  ', <<VIEW_BY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CODE>> '||
                                  ', <<PROJECT EXPENDITURE TYPE+PJI_EXP_CATEGORIES>>'||
                                  ', <<PROJECT EXPENDITURE TYPE+PJI_EXP_TYPES>>'||
                                  ', NULL'||
                                  ', NULL'||
                                  ', <<PROJECT WORK TYPE+PJI_WORK_TYPES>> '

                        );
END GET_SQL_PJI_REP_PP4;



PROCEDURE GET_SQL_PJI_REP_PP9(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
	            , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
	IS
	l_Err_Message   VARCHAR2(3200);
	l_PMV_Sql       VARCHAR2(3200);
	BEGIN

 /* Set context */
         G_context := 'PROFIT'; /* Added for bug 9366920 */
              PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
				, P_SELECT_LIST =>
				  ' FACT.PROJECT_ID     "PJI_REP_MSR_18"
				  , FACT.PROJECT_NAME  "VIEWBY"
				  , FACT.PROJECT_NUMBER  "PJI_REP_MSR_2"
				  , FACT.URL_PARAMETERS01     "PJI_REP_MSR_20"
                                  , FACT.URL_PARAMETERS01     "PJI_REP_MSR_30"
				  , FACT.PRIMARY_CUSTOMER_NAME  "PJI_REP_MSR_3"
				  , FACT.PROJECT_TYPE  "PJI_REP_MSR_4"
				  , FACT.ORGANIZATION_NAME  "PJI_REP_MSR_5"
				  , FACT.PERSON_MANAGER_NAME  "PJI_REP_MSR_6"
				  , FACT.REVENUE  "PJI_REP_MSR_7"
				  , FACT.BURDENED_COST  "PJI_REP_MSR_8"
				  , FACT.MARGIN  "PJI_REP_MSR_9"
				  , FACT.FORECAST_REVENUE  "PJI_REP_MSR_11"
				  , FACT.FORECAST_BURDENED_COST  "PJI_REP_MSR_12"
				  , FACT.FORECAST_MARGIN  "PJI_REP_MSR_13"
				  , FACT.BUDGET_MARGIN  "PJI_REP_MSR_10"
				  , FACT.FORECAST_MARGIN_VARIANCE  "PJI_REP_MSR_14"
				  , FACT.CURR_BGT_REVENUE  "PJI_REP_MSR_15"
				  , FACT.CURR_BGT_BURDENED_COST  "PJI_REP_MSR_16"
				  , FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1"
				  , FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_2"
				  , FACT.PJI_REP_TOTAL_7 "PJI_REP_TOTAL_3"
				  , FACT.PJI_REP_TOTAL_5 "PJI_REP_TOTAL_4"
				  , FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_5"
				  , FACT.PJI_REP_TOTAL_10 "PJI_REP_TOTAL_6"
				  , FACT.PJI_REP_TOTAL_9 "PJI_REP_TOTAL_7"
				  , FACT.PJI_REP_TOTAL_11 "PJI_REP_TOTAL_8"
				  , FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_9"
				  , FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_10" '
            		, P_SQL_STATEMENT => x_PMV_Sql
	           		, P_PMV_OUTPUT => x_PMV_Output
				, p_Region_Code => 'PJI_REP_PP9'
				, p_PLSQL_Driver => 'PJI_PMV_PROFITABILITY.PLSQLDriver_PJI_REP_PPDTL'
				, p_PLSQL_Driver_Params => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
				  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
				  ', <<CURRENCY+FII_CURRENCIES>>'||
				  ', <<AS_OF_DATE>>'||
				  ', <<PERIOD_TYPE>>'||
				  ', <<VIEW_BY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CODE>> '||
				  ', <<PROJECT+PJI_PROJECTS>> '||
                                  ', NULL'||
                                  ', NULL'||
                                  ', <<PROJECT REVENUE CATEGORY+PJI_REVENUE_CATEGORIES>>'||
                                  ', <<PROJECT REVENUE CATEGORY+PJI_EXP_EVT_TYPES>>'||
                                  ', NULL'
                        );
END GET_SQL_PJI_REP_PP9;


PROCEDURE GET_SQL_PJI_REP_PP10(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
	            , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	l_Err_Message   VARCHAR2(3200);
	l_PMV_Sql       VARCHAR2(3200);
	BEGIN

         /* Set context
         Commented for bug 9569573
         G_context := 'PROFIT'; /* Added for bug 9366920 */

              PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
				, P_SELECT_LIST =>
				  ' FACT.PROJECT_ID       "PJI_REP_MSR18"
				  , FACT.PROJECT_NAME     "VIEWBY"
				  , FACT.PROJECT_NUMBER   "PJI_REP_MSR_2"
				  , FACT.URL_PARAMETERS01 "PJI_REP_MSR_20"
                                  , FACT.URL_PARAMETERS01     "PJI_REP_MSR_30"
				  , FACT.PRIMARY_CUSTOMER_NAME  "PJI_REP_MSR_3"
				  , FACT.PROJECT_TYPE  "PJI_REP_MSR_4"
				  , FACT.ORGANIZATION_NAME  "PJI_REP_MSR_5"
				  , FACT.PERSON_MANAGER_NAME  "PJI_REP_MSR_6"
				  , FACT.BURDENED_COST  "PJI_REP_MSR_8"
				  , FACT.CURR_BGT_BURDENED_COST  "PJI_REP_MSR_16"
				  , FACT.COST_VARIANCE  "PJI_REP_MSR_17"
				  , FACT.FORECAST_BURDENED_COST  "PJI_REP_MSR_12"
				  , FACT.FORECAST_COST_VARIANCE  "PJI_REP_MSR_13"
				  , FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_1"
				  , FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_2"
				  , FACT.PJI_REP_TOTAL_8 "PJI_REP_TOTAL_3"
				  , FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_4"
				  , FACT.PJI_REP_TOTAL_12 "PJI_REP_TOTAL_5" '
            		, P_SQL_STATEMENT => x_PMV_Sql
            		, P_PMV_OUTPUT => x_PMV_Output
				, p_Region_Code =>'PJI_REP_PP10'
				, p_PLSQL_Driver => 'PJI_PMV_PROFITABILITY.PLSQLDriver_PJI_REP_PPDTL'
				, p_PLSQL_Driver_Params => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
				  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
				  ', <<CURRENCY+FII_CURRENCIES>>'||
				  ', <<AS_OF_DATE>>'||
				  ', <<PERIOD_TYPE>>'||
				  ', <<VIEW_BY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CODE>> '||
				  ', <<PROJECT+PJI_PROJECTS>> '||
                                  ', <<PROJECT EXPENDITURE TYPE+PJI_EXP_CATEGORIES>>'||
                                  ', <<PROJECT EXPENDITURE TYPE+PJI_EXP_TYPES>>'||
                                  ', NULL'||
                                  ', NULL'||
                                  ', <<PROJECT WORK TYPE+PJI_WORK_TYPES>> '
                        );
END GET_SQL_PJI_REP_PP10;

/* -------------------------------------------------------------+
** -- PLSQL DRIVERS
*/ -------------------------------------------------------------+


/* Name:                 PLSQLDriver_PJI_REP_PP3
** Type:                 Function
**
** Description:          This function receives PM Viewer runtime query parameters
**                       and RETURNS a PL/SQL table for the PM Viewer report.
**
** 			This function is designed for the Project Profitability
**                       Detail Reports:
**                       1) Project Profitability Overview (PP3)
**
** NOTE:
**                       The PP3 report does NOT have any View-By dimensions. Therefore,
**                       the collection logic does not address view-by logic requirements.
**
** Issues:
**
**
** Called subprograms:
**                       Various PJI_PMV_ENGINE.Convert APIs
**
** Called objects:
**                       PJI_REP_PP3_TBL (table of db object PJI_REP_PP3)
**
** History:
**       21-MAY-2002	jwhite		Created.
**
**       15-JUL-2002     jwhite          As directed by Vijay, for the
**                                       PJI_PMV_ENGINE.Convert_Time API call
**                                       I removed the following parameter reference:
**
**                                           P_REPORT_TYPE  =>  'DBI'
**
*/

	FUNCTION  PLSQLDriver_PJI_REP_PP3(
         p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
         , p_Organization		IN VARCHAR2
         , p_Currency_Type		IN VARCHAR2
         , p_As_of_Date         IN NUMBER
         , p_Period_Type 		IN VARCHAR2
         , p_View_BY 			IN VARCHAR2
         , p_Classifications	IN VARCHAR2 DEFAULT NULL
         , p_Class_Codes		IN VARCHAR2 DEFAULT NULL

         , p_Expenditure_Category        IN VARCHAR2 DEFAULT NULL
         , p_Expenditure_Type            IN VARCHAR2 DEFAULT NULL
         , p_Revenue_Category            IN VARCHAR2 DEFAULT NULL
         , p_Revenue_Type                IN VARCHAR2 DEFAULT NULL
         , p_Work_Type                   IN VARCHAR2 DEFAULT NULL

         )  RETURN PJI_REP_PP3_TBL
	IS

        PRAGMA AUTONOMOUS_TRANSACTION;

/*
**  Local Variable Declaration
*/
        l_label_rev   	VARCHAR2(80) := NULL;
        l_label_cost    VARCHAR2(80) := NULL;
        l_label_margin  VARCHAR2(80) := NULL;
        l_label_mgnpct  VARCHAR2(80) := NULL; -- Margin Percentage

        l_Parse_Class_Codes VARCHAR2(1) := NULL;

		l_Top_Organization_Name VARCHAR2(240);


        i                       NUMBER       := 0;
        ln                      NUMBER       := 0;
        l_rev_P_ACTUAL          NUMBER       := 0;
        l_mgn_P_ACTUAL          NUMBER       := 0;
        l_rev_P_FORECAST        NUMBER       := 0;
        l_mgn_P_FORECAST        NUMBER       := 0;
        l_rev_PY_ACTUAL         NUMBER       := 0;
        l_mgn_PY_ACTUAL         NUMBER       := 0;
        l_rev_PY_FORECAST       NUMBER       := 0;
        l_mgn_PY_FORECAST       NUMBER       := 0;

        l_Convert_Classification        VARCHAR2(1);
        l_Convert_Event_Revenue_Type    VARCHAR2(1);
        l_Convert_Work_Type             VARCHAR2(1);
	l_curr_record_type_id           NUMBER:= 1;

/*
**  PL/SQL Declaration
*/
	l_phase_tab		PJI_REP_PP3_TBL := PJI_REP_PP3_TBL();



BEGIN

BEGIN
	SELECT report_cost_type
		INTO G_Report_Cost_Type
		FROM pji_system_settings;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		G_Report_Cost_Type:='RC';
END;

/*
**  Populate Report Labels
*/
        SELECT meaning
        INTO   l_label_rev
        FROM   pji_lookups
        WHERE  lookup_type = 'PJI_PROFITABILITY_MEASURES'
        AND    lookup_code = 'REVENUE';

        SELECT meaning
        INTO   l_label_cost
        FROM   pji_lookups
        WHERE  lookup_type = 'PJI_PROFITABILITY_MEASURES'
        AND    lookup_code = 'COST';

        SELECT meaning
        INTO   l_label_margin
        FROM   pji_lookups
        WHERE  lookup_type = 'PJI_PROFITABILITY_MEASURES'
        AND    lookup_code = 'MARGIN';

        SELECT meaning
        INTO   l_label_mgnpct
        FROM   pji_lookups
        WHERE  lookup_type = 'PJI_PROFITABILITY_MEASURES'
        AND    lookup_code = 'MARGIN_PERCENT';



/*
** Place a call to all the parse API's which parse the
** parameters passed by PMV and populate all the
** temporary tables.
*/

	PJI_PMV_ENGINE.Convert_Operating_Unit(P_OPERATING_UNIT_IDS   => p_Operating_Unit
                                                , P_VIEW_BY            => p_View_BY
                                              );


	PJI_PMV_ENGINE.Convert_Organization(P_TOP_ORGANIZATION_ID  => p_Organization
                                              , P_VIEW_BY            => p_View_BY
					  , p_Top_Organization_Name => l_Top_Organization_Name
                                            );
	PJI_PMV_ENGINE.Convert_Time(P_AS_OF_DATE    => p_As_of_Date
                                      , P_PERIOD_TYPE  =>  p_Period_Type
                                      , P_VIEW_BY      =>  p_View_By
                                      , P_PARSE_PRIOR  =>  'Y'
                                      , P_COMPARATOR   =>  NULL
                                      , P_PARSE_ITD    => NULL
                                      , P_FULL_PERIOD_FLAG => 'Y'
                                    );

      l_Convert_Classification := PJI_PMV_ENGINE.Convert_Classification(p_Classifications,

p_Class_Codes, p_View_BY);
      l_Convert_Event_Revenue_Type := PJI_PMV_ENGINE.Convert_Event_Revenue_Type(p_Revenue_Category,
p_Revenue_Type, p_View_BY );
      l_Convert_Work_Type := PJI_PMV_ENGINE.Convert_Work_Type(p_Work_Type, p_View_BY);
	l_curr_record_type_id:=PJI_PMV_ENGINE.Convert_Currency_Record_Type(p_Currency_Type);

/*
**
**      -- PHASE I: Insert Separate Current and Prior Year Rows for Revenue, Cost and Margin
*/


		/*
		** Code the SQL statement for all of the following conditions
		** 1. Current Year
		** 2. Prior Year
                **
                ** Note: This report does NOT require the generation of rows with zero's for the
                **       query parameter dimensions.
                **
		** Bulk-Collect the output into a pl/sql table to be returned to
		** pmv.
		*/


/*
** ORG Processing ---------------------------------------------------+
*/


/* ----------------------------- Case 1 truth table ------------------------------------ */

        IF (l_Convert_Classification = 'N')
         and (l_Convert_Event_Revenue_Type = 'N')
         and (l_Convert_Work_Type = 'N')
          THEN


           SELECT PJI_REP_PP3(PHASE_CODE
            ,AMOUNT_TYPE_CODE
            ,AMOUNT_TYPE_LABEL
			, SUM( P_ACTUAL )
			, NULL
			, NULL
			, SUM( PY_ACTUAL )
			, NULL
			, NULL
			, SUM( P_CHANGE1 )
			, SUM( P_CHANGE11 )
			, SUM( P_CHANGE12 )
			, SUM( P_FORECAST )
			, NULL
			, NULL
			, SUM( PY_FORECAST )
			, NULL
			, NULL
			, SUM( P_CHANGE2 )
			, SUM( P_CHANGE21 )
			, SUM( P_CHANGE22 )
            , NULL
            , NULL )
           BULK COLLECT INTO l_phase_tab
           FROM
	      ( SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
                        , 1                     AS AMOUNT_TYPE_CODE
                        , l_label_rev           AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1, revenue,0)    AS P_ACTUAL
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, DECODE(TIME.amount_type,2, forecast_revenue,0)      AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, pji_fp_orgo_f_mv fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
                SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, DECODE(TIME.amount_type,1,revenue,0)               AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, DECODE(TIME.amount_type,2,forecast_revenue,0)      AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, pji_fp_orgo_f_mv fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
              	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
               UNION ALL
	       SELECT /*+ ORDERED */
			  1          AS PHASE_CODE
                        , 2                      AS AMOUNT_TYPE_CODE
                        , l_label_cost           AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1,
                DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                            'RC', contract_raw_cost, 0),0)         AS P_ACTUAL /* Modified for bug 9366920 */
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, DECODE(TIME.amount_type,2,
                                      DECODE(G_Report_Cost_Type,  'BC', forecast_burdened_cost,
                                            'RC', forecast_raw_cost, 0),0)  AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, pji_fp_orgo_f_mv fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
			fct.org_id = hou.id
			AND FCT.ORGANIZATION_ID = HORG.ID
			AND FCT.TIME_ID = TIME.ID
			AND TIME.ID IS NOT NULL
			AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
           	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
	        AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT /*+ ORDERED */
			  1                                                 AS PHASE_CODE
            , 2                                                 AS AMOUNT_TYPE_CODE
            , l_label_cost                                      AS AMOUNT_TYPE_LABEL
			, 0                                                 AS P_ACTUAL
			, DECODE(TIME.amount_type,1,
                DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                            'RC', contract_raw_cost, 0),0)         AS P_ACTUAL /* Modified for bug 9366920 */
			, null                  AS P_CHANGE1
			, null                     AS P_CHANGE11
			, null                     AS P_CHANGE12
			, 0                     AS P_FORECAST
			, DECODE(TIME.amount_type,2,
                DECODE(G_Report_Cost_Type,  'BC', forecast_burdened_cost,
                                            'RC', forecast_raw_cost, 0),0)  AS PY_FORECAST
			, null                     AS P_CHANGE2
			, null                     AS P_CHANGE21
			, null                     AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, pji_fp_orgo_f_mv fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
			fct.org_id = hou.id
			AND FCT.ORGANIZATION_ID = HORG.ID
			AND FCT.TIME_ID = TIME.PRIOR_ID
			AND TIME.PRIOR_ID IS NOT NULL
			AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
           	        AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
			AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT /*+ ORDERED */
			  1                        AS PHASE_CODE
                        , 3                        AS AMOUNT_TYPE_CODE
                        , l_label_margin           AS AMOUNT_TYPE_LABEL
			,DECODE(TIME.amount_type,1,
			( NVL(revenue,0) - NVL(DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost, 'RC', contract_raw_cost, 0),0) ),  0) /* Modified for bug 9366920 */
			AS P_ACTUAL

			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, DECODE(TIME.amount_type,2, (nvl(forecast_revenue,0) -
            NVL( DECODE(G_Report_Cost_Type,  'BC', forecast_burdened_cost,
                                        'RC', forecast_raw_cost, 0),0)), 0)   AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
				PJI_PMV_TIME_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, pji_fp_orgo_f_mv fct
				, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
			AND FCT.ORGANIZATION_ID = HORG.ID
			AND FCT.TIME_ID = TIME.ID
			AND TIME.ID IS NOT NULL
			AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
    		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
        UNION ALL
		SELECT /*+ ORDERED */
			  1                        AS PHASE_CODE
            , 3                        AS AMOUNT_TYPE_CODE
            , l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, DECODE(TIME.amount_type,1, (nvl(revenue,0) -
                NVL(DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                            'RC', contract_raw_cost, 0),0)), 0)  AS PY_ACTUAL /* Modified for bug 9366920 */
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, DECODE(TIME.amount_type,2, (nvl(forecast_revenue,0) -
                NVL(DECODE(G_Report_Cost_Type,  'BC', forecast_burdened_cost,
                                            'RC', forecast_raw_cost, 0),0)), 0)   AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, pji_fp_orgo_f_mv fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT
			  1                       AS PHASE_CODE
            , 1                       AS AMOUNT_TYPE_CODE
            , l_label_rev             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			  1                       AS PHASE_CODE
            , 2                       AS AMOUNT_TYPE_CODE
            , l_label_cost            AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			  1                       AS PHASE_CODE
            , 3                       AS AMOUNT_TYPE_CODE
            , l_label_margin          AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                )
        WHERE 1 = 1
	GROUP BY PHASE_CODE,AMOUNT_TYPE_CODE,AMOUNT_TYPE_LABEL;

/*
** -- PROJECT CLASSIFICATION Processing ---------------------------------------------------+
*/


/* -----------------------------------  Case 2 truth table   -------------------------------------  */

        ELSIF (l_Convert_Event_Revenue_Type = 'N')
         and (l_Convert_Work_Type = 'N')

          THEN

           SELECT PJI_REP_PP3(PHASE_CODE
            ,AMOUNT_TYPE_CODE
            ,AMOUNT_TYPE_LABEL
			, SUM( P_ACTUAL )
			, NULL
			, NULL
			, SUM( PY_ACTUAL )
			, NULL
			, NULL
			, SUM( P_CHANGE1 )
			, SUM( P_CHANGE11 )
			, SUM( P_CHANGE12 )
			, SUM( P_FORECAST )
			, NULL
			, NULL
			, SUM( PY_FORECAST )
			, NULL
			, NULL
			, SUM( P_CHANGE2 )
			, SUM( P_CHANGE21 )
			, SUM( P_CHANGE22 )
			, NULL
			, NULL)
           BULK COLLECT INTO l_phase_tab
           FROM
	      ( SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1, revenue, 0)               AS P_ACTUAL
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, DECODE(TIME.amount_type,2, forecast_revenue,0)      AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, pji_fp_clso_f_mv fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                         	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, DECODE(TIME.amount_type,1, revenue, 0)               AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, DECODE(TIME.amount_type,2, forecast_revenue, 0)      AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, pji_fp_clso_f_mv fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
                SELECT /*+ ORDERED */
			  1          AS PHASE_CODE
            , 2                      AS AMOUNT_TYPE_CODE
            , l_label_cost           AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1,
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0), 0)         AS P_ACTUAL /* Modified for bug 9366920 */
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, DECODE(TIME.amount_type,2,
            DECODE(G_Report_Cost_Type,  'BC', forecast_burdened_cost,
                                        'RC', forecast_raw_cost, 0), 0)  AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, pji_fp_clso_f_mv fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
                SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 2                     AS AMOUNT_TYPE_CODE
            , l_label_cost          AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, DECODE(TIME.amount_type,1,
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0), 0)         AS PY_ACTUAL /* Modified for bug 9366920 */
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, DECODE(TIME.amount_type,2,
            DECODE(G_Report_Cost_Type,  'BC', forecast_burdened_cost,
                                        'RC', forecast_raw_cost, 0), 0)  AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM
                  PJI_PMV_TIME_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_CLS_DIM_TMP CLS
				, pji_fp_clso_f_mv fct
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
		SELECT /*+ ORDERED */
			  1                          AS PHASE_CODE
            , 3                         AS AMOUNT_TYPE_CODE
            , l_label_margin            AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1, (revenue -
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0)), 0)  AS P_ACTUAL /* Modified for bug 9366920 */
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, DECODE(TIME.amount_type,2, (forecast_revenue -
            DECODE(G_Report_Cost_Type,  'BC', forecast_burdened_cost,
                                        'RC', forecast_raw_cost, 0)), 0)   AS P_FORECAST
			, 0                                           AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, pji_fp_clso_f_mv fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
        	SELECT /*+ ORDERED */
			  1                        AS PHASE_CODE
            , 3                        AS AMOUNT_TYPE_CODE
            , l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, DECODE(TIME.amount_type,1, (revenue -
                DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                            'RC', contract_raw_cost, 0)), 0)  AS PY_ACTUAL /* Modified for bug 9366920 */
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, DECODE(TIME.amount_type,2, (forecast_revenue -
                DECODE(G_Report_Cost_Type,  'BC', forecast_burdened_cost,
                                            'RC', forecast_raw_cost, 0)), 0)   AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM	PJI_PMV_TIME_DIM_TMP TIME
          		, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_CLS_DIM_TMP CLS
				, pji_fp_clso_f_mv fct
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT
			  1                       AS PHASE_CODE
            , 1                       AS AMOUNT_TYPE_CODE
            , l_label_rev             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			1                         AS PHASE_CODE
            ,2                        AS AMOUNT_TYPE_CODE
            ,l_label_cost             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			1                         AS PHASE_CODE
            ,3                        AS AMOUNT_TYPE_CODE
            ,l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, 0                        AS PY_ACTUAL
			, null                     AS P_CHANGE1
			, null                     AS P_CHANGE11
			, null                     AS P_CHANGE12
			, 0                        AS P_FORECAST
			, 0                        AS PY_FORECAST
			, null                     AS P_CHANGE2
			, null                     AS P_CHANGE21
			, null                     AS P_CHANGE22
		FROM	dual
                )
        WHERE 1 = 1
	GROUP BY PHASE_CODE,AMOUNT_TYPE_CODE,AMOUNT_TYPE_LABEL;


/*
** Expenditure or Revenue Type Processing ---------------------------------------------------+
*/

/* -----------------------------------  Case 3 truth table   -------------------------------------  */

        ELSIF (l_Convert_Classification = 'N')
         and (l_Convert_Work_Type = 'N')
          THEN

           SELECT PJI_REP_PP3(PHASE_CODE
            ,AMOUNT_TYPE_CODE
            ,AMOUNT_TYPE_LABEL
			, SUM( P_ACTUAL )
			, NULL
			, NULL
			, SUM( PY_ACTUAL )
			, NULL
			, NULL
			, SUM( P_CHANGE1 )
			, SUM( P_CHANGE11 )
			, SUM( P_CHANGE12 )
			, SUM( P_FORECAST )
			, NULL
			, NULL
			, SUM( PY_FORECAST )
			, NULL
			, NULL
			, SUM( P_CHANGE2 )
			, SUM( P_CHANGE21 )
			, SUM( P_CHANGE22 )
			, NULL
			, NULL)
           BULK COLLECT INTO l_phase_tab
           FROM
	      ( SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1, revenue, 0)               AS P_ACTUAL
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null      AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_ORGO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                         	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, DECODE(TIME.amount_type,1, revenue, 0)               AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null      AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_ORGO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
                SELECT /*+ ORDERED */
			  1          AS PHASE_CODE
            , 2                      AS AMOUNT_TYPE_CODE
            , l_label_cost           AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1,
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0), 0)         AS P_ACTUAL /* Modified for bug 9366920 */
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null  AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_ORGO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
                SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 2                     AS AMOUNT_TYPE_CODE
            , l_label_cost          AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, DECODE(TIME.amount_type,1,
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0), 0)         AS PY_ACTUAL /* Modified for bug 9366920 */
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null  AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM
                  PJI_PMV_TIME_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_ET_RT_DIM_TMP ET
				, PJI_FP_ORGO_ET_F_MV fct
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
		SELECT /*+ ORDERED */
			  1                          AS PHASE_CODE
            , 3                         AS AMOUNT_TYPE_CODE
            , l_label_margin            AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1, (revenue -
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0)), 0)  AS P_ACTUAL /* Modified for bug 9366920 */
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null   AS P_FORECAST
			, 0                                           AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_ORGO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
        	SELECT /*+ ORDERED */
			  1                        AS PHASE_CODE
            , 3                        AS AMOUNT_TYPE_CODE
            , l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, DECODE(TIME.amount_type,1, (revenue -
                DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                            'RC', contract_raw_cost, 0)), 0)  AS PY_ACTUAL /* Modified for bug 9366920 */
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null   AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM	PJI_PMV_TIME_DIM_TMP TIME
          		, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_ORGO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT
			  1                       AS PHASE_CODE
            , 1                       AS AMOUNT_TYPE_CODE
            , l_label_rev             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			1                         AS PHASE_CODE
            ,2                        AS AMOUNT_TYPE_CODE
            ,l_label_cost             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			1                         AS PHASE_CODE
            ,3                        AS AMOUNT_TYPE_CODE
            ,l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, 0                        AS PY_ACTUAL
			, null                     AS P_CHANGE1
			, null                     AS P_CHANGE11
			, null                     AS P_CHANGE12
			, 0                        AS P_FORECAST
			, 0                        AS PY_FORECAST
			, null                     AS P_CHANGE2
			, null                     AS P_CHANGE21
			, null                     AS P_CHANGE22
		FROM	dual
                )
        WHERE 1 = 1
	GROUP BY PHASE_CODE,AMOUNT_TYPE_CODE,AMOUNT_TYPE_LABEL;

/*
**  Work Type Processing ---------------------------------------------------+
*/

/* -----------------------------------  Case 4 truth table   -------------------------------------  */

        ELSIF (l_Convert_Classification = 'N')
         and  (l_Convert_Event_Revenue_Type = 'N')
          THEN

           SELECT PJI_REP_PP3(PHASE_CODE
            ,AMOUNT_TYPE_CODE
            ,AMOUNT_TYPE_LABEL
			, SUM( P_ACTUAL )
			, NULL
			, NULL
			, SUM( PY_ACTUAL )
			, NULL
			, NULL
			, SUM( P_CHANGE1 )
			, SUM( P_CHANGE11 )
			, SUM( P_CHANGE12 )
			, SUM( P_FORECAST )
			, NULL
			, NULL
			, SUM( PY_FORECAST )
			, NULL
			, NULL
			, SUM( P_CHANGE2 )
			, SUM( P_CHANGE21 )
			, SUM( P_CHANGE22 )
			, NULL
			, NULL)
           BULK COLLECT INTO l_phase_tab
           FROM
	      ( SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, null               AS P_ACTUAL
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null      AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                         	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, null               AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null      AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
                SELECT /*+ ORDERED */
			  1          AS PHASE_CODE
            , 2                      AS AMOUNT_TYPE_CODE
            , l_label_cost           AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1,
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0), 0)         AS P_ACTUAL /* Modified for bug 9366920 */
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null  AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
                SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 2                     AS AMOUNT_TYPE_CODE
            , l_label_cost          AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, DECODE(TIME.amount_type,1,
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0), 0)         AS PY_ACTUAL /* Modified for bug 9366920 */
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null  AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM
                  PJI_PMV_TIME_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_WT_DIM_TMP WT
				, PJI_FP_ORGO_ET_WT_F_MV fct
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
		SELECT /*+ ORDERED */
			  1                          AS PHASE_CODE
            , 3                         AS AMOUNT_TYPE_CODE
            , l_label_margin            AS AMOUNT_TYPE_LABEL
			, null  AS P_ACTUAL
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null   AS P_FORECAST
			, 0                                           AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
        	SELECT /*+ ORDERED */
			  1                        AS PHASE_CODE
            , 3                        AS AMOUNT_TYPE_CODE
            , l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, null  AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null   AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM	PJI_PMV_TIME_DIM_TMP TIME
          		, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT
			  1                       AS PHASE_CODE
            , 1                       AS AMOUNT_TYPE_CODE
            , l_label_rev             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			1                         AS PHASE_CODE
            ,2                        AS AMOUNT_TYPE_CODE
            ,l_label_cost             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			1                         AS PHASE_CODE
            ,3                        AS AMOUNT_TYPE_CODE
            ,l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, 0                        AS PY_ACTUAL
			, null                     AS P_CHANGE1
			, null                     AS P_CHANGE11
			, null                     AS P_CHANGE12
			, 0                        AS P_FORECAST
			, 0                        AS PY_FORECAST
			, null                     AS P_CHANGE2
			, null                     AS P_CHANGE21
			, null                     AS P_CHANGE22
		FROM	dual
                )
        WHERE 1 = 1
	GROUP BY PHASE_CODE,AMOUNT_TYPE_CODE,AMOUNT_TYPE_LABEL;

/*
** Project classification and Expenditure or Revenue Type Processing

---------------------------------+
*/

/* -----------------------------------  Case 5 truth table   -------------------------------------  */

        ELSIF (l_Convert_Work_Type = 'N')
          THEN

           SELECT PJI_REP_PP3(PHASE_CODE
            ,AMOUNT_TYPE_CODE
            ,AMOUNT_TYPE_LABEL
			, SUM( P_ACTUAL )
			, NULL
			, NULL
			, SUM( PY_ACTUAL )
			, NULL
			, NULL
			, SUM( P_CHANGE1 )
			, SUM( P_CHANGE11 )
			, SUM( P_CHANGE12 )
			, SUM( P_FORECAST )
			, NULL
			, NULL
			, SUM( PY_FORECAST )
			, NULL
			, NULL
			, SUM( P_CHANGE2 )
			, SUM( P_CHANGE21 )
			, SUM( P_CHANGE22 )
			, NULL
			, NULL)
           BULK COLLECT INTO l_phase_tab
           FROM
	      ( SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1, revenue, 0)               AS P_ACTUAL
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null      AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_CLSO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                         	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'

				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, DECODE(TIME.amount_type,1, revenue, 0)               AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null      AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_CLSO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
                SELECT /*+ ORDERED */
			  1          AS PHASE_CODE
            , 2                      AS AMOUNT_TYPE_CODE
            , l_label_cost           AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1,
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0), 0)         AS P_ACTUAL /* Modified for bug 9366920 */
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null  AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_CLSO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
                SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 2                     AS AMOUNT_TYPE_CODE
            , l_label_cost          AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, DECODE(TIME.amount_type,1,
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0), 0)         AS PY_ACTUAL /* Modified for bug 9366920 */
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null  AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM
                  PJI_PMV_TIME_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_CLS_DIM_TMP CLS
				, PJI_PMV_ET_RT_DIM_TMP ET
				, PJI_FP_CLSO_ET_F_MV fct
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
		SELECT /*+ ORDERED */
			  1                          AS PHASE_CODE
            , 3                         AS AMOUNT_TYPE_CODE
            , l_label_margin            AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1, (revenue -
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0)), 0)  AS P_ACTUAL /* Modified for bug 9366920 */
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null   AS P_FORECAST
			, 0                                           AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_CLSO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
        	SELECT /*+ ORDERED */
			  1                        AS PHASE_CODE
            , 3                        AS AMOUNT_TYPE_CODE
            , l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, DECODE(TIME.amount_type,1, (revenue -
                DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                            'RC', contract_raw_cost, 0)), 0)  AS PY_ACTUAL /* Modified for bug 9366920 */
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null   AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM	PJI_PMV_TIME_DIM_TMP TIME
          		, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_CLS_DIM_TMP CLS
				, PJI_PMV_ET_RT_DIM_TMP ET
				, PJI_FP_CLSO_ET_F_MV fct
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT
			  1                       AS PHASE_CODE
            , 1                       AS AMOUNT_TYPE_CODE
            , l_label_rev             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			1                         AS PHASE_CODE
            ,2                        AS AMOUNT_TYPE_CODE
            ,l_label_cost             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			1                         AS PHASE_CODE
            ,3                        AS AMOUNT_TYPE_CODE
            ,l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, 0                        AS PY_ACTUAL
			, null                     AS P_CHANGE1
			, null                     AS P_CHANGE11
			, null                     AS P_CHANGE12
			, 0                        AS P_FORECAST
			, 0                        AS PY_FORECAST
			, null                     AS P_CHANGE2
			, null                     AS P_CHANGE21
			, null                     AS P_CHANGE22
		FROM	dual
                )
        WHERE 1 = 1
	GROUP BY PHASE_CODE,AMOUNT_TYPE_CODE,AMOUNT_TYPE_LABEL;

/*
** Expenditure or Revenue Type and Work Type Processing -----------------------------------------+
*/

/* -----------------------------------  Case 6 truth table   -------------------------------------  */

        ELSIF (l_Convert_Classification = 'N')
          THEN

           SELECT PJI_REP_PP3(PHASE_CODE
            ,AMOUNT_TYPE_CODE
            ,AMOUNT_TYPE_LABEL
			, SUM( P_ACTUAL )
			, NULL
			, NULL
			, SUM( PY_ACTUAL )
			, NULL
			, NULL
			, SUM( P_CHANGE1 )
			, SUM( P_CHANGE11 )
			, SUM( P_CHANGE12 )
			, SUM( P_FORECAST )
			, NULL
			, NULL
			, SUM( PY_FORECAST )
			, NULL
			, NULL
			, SUM( P_CHANGE2 )
			, SUM( P_CHANGE21 )
			, SUM( P_CHANGE22 )
			, NULL
			, NULL)
           BULK COLLECT INTO l_phase_tab
           FROM
	      ( SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, null               AS P_ACTUAL
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null      AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                         	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, null               AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null      AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND FCT.WORK_TYPE_ID = WT.ID

				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
                SELECT /*+ ORDERED */
			  1          AS PHASE_CODE
            , 2                      AS AMOUNT_TYPE_CODE
            , l_label_cost           AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1,
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0), 0)         AS P_ACTUAL /* Modified for bug 9366920 */
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null  AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
                SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 2                     AS AMOUNT_TYPE_CODE
            , l_label_cost          AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, DECODE(TIME.amount_type,1,
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0), 0)         AS PY_ACTUAL /* Modified for bug 9366920 */
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null  AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM
                  PJI_PMV_TIME_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_ET_RT_DIM_TMP ET
				, PJI_PMV_WT_DIM_TMP WT
				, PJI_FP_ORGO_ET_WT_F_MV fct
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
		SELECT /*+ ORDERED */
			  1                          AS PHASE_CODE
            , 3                         AS AMOUNT_TYPE_CODE
            , l_label_margin            AS AMOUNT_TYPE_LABEL
			, null  AS P_ACTUAL
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null   AS P_FORECAST
			, 0                                           AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
        	SELECT /*+ ORDERED */
			  1                        AS PHASE_CODE
            , 3                        AS AMOUNT_TYPE_CODE
            , l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, null  AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null   AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM	PJI_PMV_TIME_DIM_TMP TIME
          		, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT
			  1                       AS PHASE_CODE
            , 1                       AS AMOUNT_TYPE_CODE
            , l_label_rev             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			1                         AS PHASE_CODE
            ,2                        AS AMOUNT_TYPE_CODE
            ,l_label_cost             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			1                         AS PHASE_CODE
            ,3                        AS AMOUNT_TYPE_CODE
            ,l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, 0                        AS PY_ACTUAL
			, null                     AS P_CHANGE1
			, null                     AS P_CHANGE11
			, null                     AS P_CHANGE12
			, 0                        AS P_FORECAST
			, 0                        AS PY_FORECAST
			, null                     AS P_CHANGE2
			, null                     AS P_CHANGE21
			, null                     AS P_CHANGE22
		FROM	dual
                )
        WHERE 1 = 1
	GROUP BY PHASE_CODE,AMOUNT_TYPE_CODE,AMOUNT_TYPE_LABEL;

/*
**  Project classification and Work Type Processing -----------------------------------------------+
*/

/* -----------------------------------  Case 7 truth table   -------------------------------------  */

        ELSIF (l_Convert_Event_Revenue_Type = 'N')
          THEN

           SELECT PJI_REP_PP3(PHASE_CODE
            ,AMOUNT_TYPE_CODE
            ,AMOUNT_TYPE_LABEL
			, SUM( P_ACTUAL )
			, NULL
			, NULL
			, SUM( PY_ACTUAL )
			, NULL
			, NULL
			, SUM( P_CHANGE1 )
			, SUM( P_CHANGE11 )
			, SUM( P_CHANGE12 )
			, SUM( P_FORECAST )
			, NULL
			, NULL
			, SUM( PY_FORECAST )
			, NULL
			, NULL
			, SUM( P_CHANGE2 )
			, SUM( P_CHANGE21 )
			, SUM( P_CHANGE22 )
			, NULL
			, NULL)
           BULK COLLECT INTO l_phase_tab
           FROM
	      ( SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, null               AS P_ACTUAL
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null      AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_CLSO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                         	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, null               AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null      AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_CLSO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
                SELECT /*+ ORDERED */
			  1          AS PHASE_CODE
            , 2                      AS AMOUNT_TYPE_CODE
            , l_label_cost           AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1,
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0), 0)         AS P_ACTUAL /* Modified for bug 9366920 */
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null  AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_CLSO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
                SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 2                     AS AMOUNT_TYPE_CODE
            , l_label_cost          AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, DECODE(TIME.amount_type,1,
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0), 0)         AS PY_ACTUAL /* Modified for bug 9366920 */
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null  AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM
                  PJI_PMV_TIME_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_CLS_DIM_TMP CLS
				, PJI_PMV_WT_DIM_TMP WT
				, PJI_FP_CLSO_ET_WT_F_MV fct
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
		SELECT /*+ ORDERED */
			  1                          AS PHASE_CODE
            , 3                         AS AMOUNT_TYPE_CODE
            , l_label_margin            AS AMOUNT_TYPE_LABEL
			, null  AS P_ACTUAL
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null   AS P_FORECAST
			, 0                                           AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_CLSO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
        	SELECT /*+ ORDERED */
			  1                        AS PHASE_CODE
            , 3                        AS AMOUNT_TYPE_CODE
            , l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, null  AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null   AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM	PJI_PMV_TIME_DIM_TMP TIME
          		, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_CLS_DIM_TMP CLS
				, PJI_PMV_WT_DIM_TMP WT
				, PJI_FP_CLSO_ET_WT_F_MV fct
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT
			  1                       AS PHASE_CODE
            , 1                       AS AMOUNT_TYPE_CODE
            , l_label_rev             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			1                         AS PHASE_CODE
            ,2                        AS AMOUNT_TYPE_CODE
            ,l_label_cost             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			1                         AS PHASE_CODE
            ,3                        AS AMOUNT_TYPE_CODE
            ,l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, 0                        AS PY_ACTUAL
			, null                     AS P_CHANGE1
			, null                     AS P_CHANGE11
			, null                     AS P_CHANGE12
			, 0                        AS P_FORECAST
			, 0                        AS PY_FORECAST
			, null                     AS P_CHANGE2
			, null                     AS P_CHANGE21
			, null                     AS P_CHANGE22
		FROM	dual
                )
        WHERE 1 = 1
	GROUP BY PHASE_CODE,AMOUNT_TYPE_CODE,AMOUNT_TYPE_LABEL;

/*
** Project classification and Expenditure or Revenue Type and Work Type Processing ----------------+
*/

/* -----------------------------------  Case 8 truth table   -------------------------------------  */

        ELSE

           SELECT PJI_REP_PP3(PHASE_CODE
            ,AMOUNT_TYPE_CODE
            ,AMOUNT_TYPE_LABEL
			, SUM( P_ACTUAL )
			, NULL
			, NULL
			, SUM( PY_ACTUAL )
			, NULL
			, NULL
			, SUM( P_CHANGE1 )
			, SUM( P_CHANGE11 )
			, SUM( P_CHANGE12 )
			, SUM( P_FORECAST )
			, NULL
			, NULL
			, SUM( PY_FORECAST )
			, NULL
			, NULL
			, SUM( P_CHANGE2 )
			, SUM( P_CHANGE21 )
			, SUM( P_CHANGE22 )
			, NULL
			, NULL)
           BULK COLLECT INTO l_phase_tab
           FROM
	      ( SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, null               AS P_ACTUAL
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null      AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_CLSO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                         	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 1                     AS AMOUNT_TYPE_CODE
            , l_label_rev           AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, null               AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null      AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_CLSO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
                SELECT /*+ ORDERED */
			  1          AS PHASE_CODE
            , 2                      AS AMOUNT_TYPE_CODE
            , l_label_cost           AS AMOUNT_TYPE_LABEL
			, DECODE(TIME.amount_type,1,
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0), 0)         AS P_ACTUAL /* Modified for bug 9366920 */
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null  AS P_FORECAST
			, 0                     AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_CLSO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
                SELECT /*+ ORDERED */
			  1                     AS PHASE_CODE
            , 2                     AS AMOUNT_TYPE_CODE
            , l_label_cost          AS AMOUNT_TYPE_LABEL
			, 0                     AS P_ACTUAL
			, DECODE(TIME.amount_type,1,
            DECODE(G_Report_Cost_Type,  'BC', contract_brdn_cost,
                                        'RC', contract_raw_cost, 0), 0)         AS PY_ACTUAL /* Modified for bug 9366920 */
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM
                  PJI_PMV_TIME_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_CLS_DIM_TMP CLS
				, PJI_PMV_ET_RT_DIM_TMP ET
				, PJI_PMV_WT_DIM_TMP WT
				, PJI_FP_CLSO_ET_WT_F_MV fct
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL
		SELECT /*+ ORDERED */
			  1                          AS PHASE_CODE
            , 3                         AS AMOUNT_TYPE_CODE
            , l_label_margin            AS AMOUNT_TYPE_LABEL
			, null  AS P_ACTUAL
			, 0                     AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, null   AS P_FORECAST
			, 0                                           AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_CLSO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
        	SELECT /*+ ORDERED */
			  1                        AS PHASE_CODE
            , 3                        AS AMOUNT_TYPE_CODE
            , l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, null  AS PY_ACTUAL
			, null                  AS P_CHANGE1
			, null                  AS P_CHANGE11
			, null                  AS P_CHANGE12
			, 0                     AS P_FORECAST
			, null   AS PY_FORECAST
			, null                  AS P_CHANGE2
			, null                  AS P_CHANGE21
			, null                  AS P_CHANGE22
                FROM	PJI_PMV_TIME_DIM_TMP TIME
          		, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_CLS_DIM_TMP CLS
				, PJI_PMV_ET_RT_DIM_TMP ET
				, PJI_PMV_WT_DIM_TMP WT
				, PJI_FP_CLSO_ET_WT_F_MV fct
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = 'RT'
				AND FCT.WORK_TYPE_ID = WT.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL
		SELECT
			  1                       AS PHASE_CODE
            , 1                       AS AMOUNT_TYPE_CODE
            , l_label_rev             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			1                         AS PHASE_CODE
            ,2                        AS AMOUNT_TYPE_CODE
            ,l_label_cost             AS AMOUNT_TYPE_LABEL
			, 0                       AS P_ACTUAL
			, 0                       AS PY_ACTUAL
			, null                    AS P_CHANGE1
			, null                    AS P_CHANGE11
			, null                    AS P_CHANGE12
			, 0                       AS P_FORECAST
			, 0                       AS PY_FORECAST
			, null                    AS P_CHANGE2
			, null                    AS P_CHANGE21
			, null                    AS P_CHANGE22
		FROM	dual
                UNION ALL
		SELECT
			1                         AS PHASE_CODE
            ,3                        AS AMOUNT_TYPE_CODE
            ,l_label_margin           AS AMOUNT_TYPE_LABEL
			, 0                        AS P_ACTUAL
			, 0                        AS PY_ACTUAL
			, null                     AS P_CHANGE1
			, null                     AS P_CHANGE11
			, null                     AS P_CHANGE12
			, 0                        AS P_FORECAST
			, 0                        AS PY_FORECAST
			, null                     AS P_CHANGE2
			, null                     AS P_CHANGE21
			, null                     AS P_CHANGE22
		FROM	dual
                )
        WHERE 1 = 1
	GROUP BY PHASE_CODE,AMOUNT_TYPE_CODE,AMOUNT_TYPE_LABEL;

END IF; -- p_Class_Codes_Ids NOT Passed by User

/*
**        -- PHASE II: Derive ALL Ratios for Each Amount Type
**        -- At this point, there should be one row for each amount type, three all together
*/
        Ln := 3;
        FOR i IN 1..Ln LOOP
            IF (l_phase_tab(i).amount_type_code = 1)
              THEN
/*
**               -- REVENUE -----------------------------+
*/

l_phase_tab(i).P_ACTUAL1 := l_phase_tab(i).P_ACTUAL;
l_phase_tab(i).P_ACTUAL2 := NULL;
l_phase_tab(i).PY_ACTUAL1 := l_phase_tab(i).PY_ACTUAL;
l_phase_tab(i).PY_ACTUAL2 := NULL;

l_phase_tab(i).P_FORECAST1 := l_phase_tab(i).P_FORECAST;
l_phase_tab(i).P_FORECAST2 := NULL;
l_phase_tab(i).PY_FORECAST1 := l_phase_tab(i).PY_FORECAST;
l_phase_tab(i).PY_FORECAST2 := NULL;

               IF (l_phase_tab(i).PY_ACTUAL = 0)
                  THEN
                     l_phase_tab(i).P_CHANGE11 := 0;
                     l_phase_tab(i).P_CHANGE12 := NULL;
               ELSE
l_phase_tab(i).P_CHANGE11 := ROUND( ((l_phase_tab(i).P_ACTUAL -

l_phase_tab(i).PY_ACTUAL)/ABS(l_phase_tab(i).PY_ACTUAL))*100, 2) ;
  l_phase_tab(i).P_CHANGE12 := NULL;
               END IF;


               IF (l_phase_tab(i).PY_FORECAST = 0)
                  THEN
                     l_phase_tab(i).P_CHANGE21 := 0;
                     l_phase_tab(i).P_CHANGE22 := NULL;
               ELSE
  l_phase_tab(i).P_CHANGE21 := ROUND( ((l_phase_tab(i).P_FORECAST -

l_phase_tab(i).PY_FORECAST)/ABS(l_phase_tab(i).PY_FORECAST))*100, 2);
  l_phase_tab(i).P_CHANGE22 := NULL;
               END IF;

/*
**               -- Cache revenue amounts for subsequent Margin Percentage Calc
*/

               l_rev_P_ACTUAL         :=  l_phase_tab(i).P_ACTUAL;
               l_rev_P_FORECAST       :=  l_phase_tab(i).P_FORECAST;
               l_rev_PY_ACTUAL        :=  l_phase_tab(i).PY_ACTUAL;
               l_rev_PY_FORECAST      :=  l_phase_tab(i).PY_FORECAST;



            ELSIF (l_phase_tab(i).amount_type_code = 2)
              THEN
/*
**	     -- COST ---------------------------+
*/
l_phase_tab(i).P_ACTUAL1 := l_phase_tab(i).P_ACTUAL;
l_phase_tab(i).P_ACTUAL2 := NULL;
l_phase_tab(i).PY_ACTUAL1 := l_phase_tab(i).PY_ACTUAL;
l_phase_tab(i).PY_ACTUAL2 := NULL;

l_phase_tab(i).P_FORECAST1 := l_phase_tab(i).P_FORECAST;
l_phase_tab(i).P_FORECAST2 := NULL;
l_phase_tab(i).PY_FORECAST1 := l_phase_tab(i).PY_FORECAST;
l_phase_tab(i).PY_FORECAST2 := NULL;


              IF (l_phase_tab(i).PY_ACTUAL = 0)
                  THEN
                     l_phase_tab(i).P_CHANGE11 := 0;
                     l_phase_tab(i).P_CHANGE12 := NULL;

               ELSE
  l_phase_tab(i).P_CHANGE11 := ROUND( ((l_phase_tab(i).P_ACTUAL -

l_phase_tab(i).PY_ACTUAL)/ABS(l_phase_tab(i).PY_ACTUAL))*100, 2) ;
  l_phase_tab(i).P_CHANGE12 := NULL;
               END IF;


               IF (l_phase_tab(i).PY_FORECAST = 0)
                  THEN
                     l_phase_tab(i).P_CHANGE21 := 0;
                     l_phase_tab(i).P_CHANGE22 := NULL;
               ELSE
  l_phase_tab(i).P_CHANGE21 := ROUND( ((l_phase_tab(i).P_FORECAST -

l_phase_tab(i).PY_FORECAST)/ABS(l_phase_tab(i).PY_FORECAST))*100, 2);
  l_phase_tab(i).P_CHANGE22 := NULL;
               END IF;


            ELSIF (l_phase_tab(i).amount_type_code =3)
              THEN
/*
**              -- MARGIN ---------------------------+
*/
l_phase_tab(i).P_ACTUAL1 := l_phase_tab(i).P_ACTUAL;
l_phase_tab(i).P_ACTUAL2 := NULL;
l_phase_tab(i).PY_ACTUAL1 := l_phase_tab(i).PY_ACTUAL;
l_phase_tab(i).PY_ACTUAL2 := NULL;

l_phase_tab(i).P_FORECAST1 := l_phase_tab(i).P_FORECAST;
l_phase_tab(i).P_FORECAST2 := NULL;
l_phase_tab(i).PY_FORECAST1 := l_phase_tab(i).PY_FORECAST;
l_phase_tab(i).PY_FORECAST2 := NULL;

              IF (l_phase_tab(i).PY_ACTUAL = 0)
                  THEN
                     l_phase_tab(i).P_CHANGE11 := 0;
                     l_phase_tab(i).P_CHANGE12 := NULL;
               ELSE
  l_phase_tab(i).P_CHANGE11 := ROUND( ((l_phase_tab(i).P_ACTUAL -

l_phase_tab(i).PY_ACTUAL)/ABS(l_phase_tab(i).PY_ACTUAL))*100, 2) ;
  l_phase_tab(i).P_CHANGE12 := NULL;
               END IF;


               IF (l_phase_tab(i).PY_FORECAST = 0)
                  THEN
                     l_phase_tab(i).P_CHANGE21 := 0;
                     l_phase_tab(i).P_CHANGE22 := NULL;
               ELSE
  l_phase_tab(i).P_CHANGE21 := ROUND( ((l_phase_tab(i).P_FORECAST -

l_phase_tab(i).PY_FORECAST)/ABS(l_phase_tab(i).PY_FORECAST))*100, 2);
  l_phase_tab(i).P_CHANGE22 := NULL;
               END IF;

/*
**               -- Cache margin amounts for subsequent Margin Percentage Calc
*/
               l_mgn_P_ACTUAL         :=  l_phase_tab(i).P_ACTUAL;
               l_mgn_P_FORECAST       :=  l_phase_tab(i).P_FORECAST;
               l_mgn_PY_ACTUAL        :=  l_phase_tab(i).PY_ACTUAL;
               l_mgn_PY_FORECAST      :=  l_phase_tab(i).PY_FORECAST;


            END IF;


        END LOOP;

/*
**        -- PHASE III: Create the Margin Percentage Row ---------------------+
*/
        l_phase_tab.extend;


l_phase_tab(4):=PJI_REP_PP3(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                            NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                            NULL,NULL,NULL,NULL,NULL,NULL,NULL);

        i := 4;

               l_phase_tab(i).phase_code := 1;

               l_phase_tab(i).amount_type_code := 4;

               l_phase_tab(i).amount_type_label := l_label_mgnpct;

               IF (l_rev_P_ACTUAL = 0)
                 THEN

                  l_phase_tab(i).P_ACTUAL := NULL;

               ELSE

                   l_phase_tab(i).P_ACTUAL := ROUND((l_mgn_P_ACTUAL/l_rev_P_ACTUAL)*100,2);

               END IF;

               IF (l_rev_PY_ACTUAL = 0)
                 THEN

                  l_phase_tab(i).PY_ACTUAL := NULL;
               ELSE

                  l_phase_tab(i).PY_ACTUAL := ROUND((l_mgn_PY_ACTUAL/l_rev_PY_ACTUAL)*100, 2);

               END IF;

               IF ( (l_rev_P_ACTUAL = 0)
                        OR (l_rev_PY_ACTUAL = 0)
                  )
                 THEN

                 l_phase_tab(i).p_change11 := NULL;
                 l_phase_tab(i).p_change12 := 0;
               ELSE

                  l_phase_tab(i).p_change11 := NULL;
                  l_phase_tab(i).p_change12 := ROUND(

(((l_mgn_P_ACTUAL/l_rev_P_ACTUAL)*100)-((l_mgn_PY_ACTUAL/l_rev_PY_ACTUAL)*100)), 2);

               END IF;

               IF (l_rev_P_FORECAST = 0)
                 THEN

                    l_phase_tab(i).P_FORECAST := NULL;

               ELSE

                    l_phase_tab(i).P_FORECAST := ROUND((l_mgn_P_FORECAST/l_rev_P_FORECAST)*100, 2);

               END IF;


               IF (l_rev_PY_FORECAST = 0)
                 THEN

                    l_phase_tab(i).PY_FORECAST := NULL;

               ELSE

                    l_phase_tab(i).PY_FORECAST := ROUND((l_mgn_PY_FORECAST/l_rev_PY_FORECAST)*100, 2);

               END IF;


               IF ( (l_rev_P_FORECAST = 0)
                        OR (l_rev_PY_FORECAST = 0)
                  )
                 THEN

                 l_phase_tab(i).p_change21 := NULL;
                 l_phase_tab(i).p_change22 := 0;

               ELSE


  l_phase_tab(i).p_change21 := NULL;
  l_phase_tab(i).p_change22 :=  ROUND((((l_mgn_P_FORECAST/l_rev_P_FORECAST)*100) -

((l_mgn_PY_FORECAST/l_rev_PY_FORECAST)*100)), 2);

               END IF;

l_phase_tab(i).P_ACTUAL1 := NULL;
l_phase_tab(i).P_ACTUAL2 := l_phase_tab(i).P_ACTUAL;
l_phase_tab(i).PY_ACTUAL1 := NULL;
l_phase_tab(i).PY_ACTUAL2 := l_phase_tab(i).PY_ACTUAL;

l_phase_tab(i).P_FORECAST1 := NULL;
l_phase_tab(i).P_FORECAST2 := l_phase_tab(i).P_FORECAST;
l_phase_tab(i).PY_FORECAST1 := NULL;
l_phase_tab(i).PY_FORECAST2 := l_phase_tab(i).PY_FORECAST;


	 /*
	 ** Additionally, generating the drill across url to different reports.
	 */
	 FOR i IN 1..4
	 LOOP
		IF l_phase_tab(i).amount_type_label = l_label_cost THEN


l_phase_tab(i).pji_rep_url1:='pFunctionName=PJI_REP_PP10&VIEW_BY_NAME=VIEW_BY_VALUE';


l_phase_tab(i).pji_rep_url2:='pFunctionName=PJI_REP_PP10&VIEW_BY_NAME=VIEW_BY_VALUE';
		ELSE


l_phase_tab(i).pji_rep_url1:='pFunctionName=PJI_REP_PP9&VIEW_BY_NAME=VIEW_BY_VALUE';


l_phase_tab(i).pji_rep_url2:='pFunctionName=PJI_REP_PP9&VIEW_BY_NAME=VIEW_BY_VALUE';
		END IF;
	 END LOOP;




	/*
	** Return the bulk collected table back to pmv.
	*/

	   COMMIT;


           RETURN l_phase_tab;


        END PLSQLDriver_PJI_REP_PP3;









/* Name:                 PLSQLDriver_PJI_REP_PPDTL
** Type:                 Function
**
** Description:          This function receives PM Viewer runtime query parameters
**                       and RETURNS a PL/SQL table for the PM Viewer report.
**
** 			This function is designed for the Project Profitability
**                     Detail Reports:
**                       1) Project Profitability Detail (PP9)
**                       2) Project Cost Detail (PP10)
**
** NOTE:
**                       These report do NOT have any View-By dimensions. Therefore,
**                       the collection logic does not address view-by logic requirements.
**
**                       Also, double counting, which may occur if class codes are specified,
**                       is NOT permitted for these reports. As a result, if class codes are specified,
**                       then the pji_pmv_prj_dim_tmp is populated on the fly and joined in the SQL
**                       to prevent double counting.
**
** Issues:
**
**
** Called subprograms:
**                       Various PJI_PMV_ENGINE.Convert APIs
**
** Called objects:
**                       PJI_REP_PPDTL_TBL (table of db object PJI_REP_PPDTL)
**
** History:
**       03-JUN-2002	jwhite		Created.
*/

	FUNCTION  PLSQLDriver_PJI_REP_PPDTL(
         p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
         , p_Organization		IN VARCHAR2
         , p_Currency_Type		IN VARCHAR2
         , p_As_of_Date         IN NUMBER
         , p_Period_Type 		IN VARCHAR2
         , p_View_BY 			IN VARCHAR2
         , p_Classifications	IN VARCHAR2 DEFAULT NULL
         , p_Class_Codes		IN VARCHAR2 DEFAULT NULL
         , p_Project_IDS		IN VARCHAR2 DEFAULT NULL

         , p_Expenditure_Category        IN VARCHAR2 DEFAULT NULL
         , p_Expenditure_Type            IN VARCHAR2 DEFAULT NULL
         , p_Revenue_Category            IN VARCHAR2 DEFAULT NULL
         , p_Revenue_Type                IN VARCHAR2 DEFAULT NULL
         , p_Work_Type                   IN VARCHAR2 DEFAULT NULL

         )  RETURN PJI_REP_PPDTL_TBL
	IS

        PRAGMA AUTONOMOUS_TRANSACTION;

/*
**         PL/SQL Declaration
*/
	l_detail_tab		PJI_REP_PPDTL_TBL := PJI_REP_PPDTL_TBL();

	l_Total_Revenue				NUMBER := 0;
	l_Total_Cost				NUMBER := 0;
	l_Total_Bgt_Revenue			NUMBER := 0;
	l_Total_Bgt_Cost			NUMBER := 0;
	l_Total_Forecast_Revenue	NUMBER := 0;
	l_Total_Forecast_Cost		NUMBER := 0;
	l_Total_Margin				NUMBER := 0;
	l_Total_Cost_Variance		NUMBER := 0;
	l_Total_Budget_Margin		NUMBER := 0;
	l_Total_Fcst_Margin			NUMBER := 0;
	l_Total_Fcst_Margin_Variance	NUMBER := 0;
	l_Total_Fcst_Cost_Variance	NUMBER := 0;

        l_Convert_Classification        VARCHAR2(1);
        l_Convert_Expenditure_Type      VARCHAR2(1);
        l_Convert_Event_Revenue_Type    VARCHAR2(1);
        l_Convert_Work_Type             VARCHAR2(1);
        l_number                        NUMBER := 0;
	l_curr_record_type_id           NUMBER:= 1;

	BEGIN

BEGIN
	SELECT report_cost_type
		INTO G_Report_Cost_Type
		FROM pji_system_settings;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		G_Report_Cost_Type:='RC';
END;

      /*
	** Place a call to all the parse API's which parse the
	** parameters passed by PMV and populate all the
	** temporary tables.
	*/

	PJI_PMV_ENGINE.Convert_Operating_Unit(P_OPERATING_UNIT_IDS   => p_Operating_Unit
                                                , P_VIEW_BY            => p_View_BY
                                              );

	PJI_PMV_ENGINE.Convert_Organization(P_TOP_ORGANIZATION_ID  => p_Organization
                                              , P_VIEW_BY            => p_View_BY
                                            );



	PJI_PMV_ENGINE.Convert_Time(P_AS_OF_DATE    => p_As_of_Date
                                      , P_PERIOD_TYPE  =>  p_Period_Type
                                      , P_VIEW_BY      =>  p_View_By
                                      , P_PARSE_PRIOR  =>  NULL
                                      , P_PARSE_ITD    => NULL
                                      , P_FULL_PERIOD_FLAG => 'Y'
                                    );


      l_Convert_Classification := PJI_PMV_ENGINE.Convert_Classification(p_Classifications, p_Class_Codes, p_View_BY);
      l_Convert_Expenditure_Type := PJI_PMV_ENGINE.Convert_Expenditure_Type(p_Expenditure_Category, p_Expenditure_Type, p_View_BY);
      l_Convert_Event_Revenue_Type := PJI_PMV_ENGINE.Convert_Event_Revenue_Type(p_Revenue_Category, p_Revenue_Type, p_View_BY );
      l_Convert_Work_Type := PJI_PMV_ENGINE.Convert_Work_Type(p_Work_Type, p_View_BY);
	l_curr_record_type_id:=PJI_PMV_ENGINE.Convert_Currency_Record_Type(p_Currency_Type);

/*
**        PHASE I: Insert Separate Current and Prior Year Rows for Revenue, Cost and Margin
*/

	IF p_Project_IDS IS NULL THEN

/*
**		 Code the SQL statement for all of the following conditions
**		 1. Current Year
**
**		Bulk-Collect the output into a pl/sql table to be returned to
**		pmv.
**
*/
/*
**        logic builds an intersection tmp table between the class codes tmp table and the
**        project_class mapping table. The intersection table is equi-joined in the following
**         select statement.
*/
			BEGIN
                        DELETE pji_pmv_prj_dim_tmp;

                 if(l_Convert_Classification = 'Y') then
                        INSERT into  pji_pmv_prj_dim_tmp (id, name)
                        SELECT DISTINCT prj.project_id, '-1' name
                        FROM
                        pji_project_classes PJM
                        , pji_pmv_cls_dim_tmp PTM
                        , pji_pmv_orgz_dim_tmp org
                        , pa_projects_all prj
                        WHERE
                        pjm.project_class_id = ptm.id
                        AND prj.project_id = pjm.project_id
                        AND prj.carrying_out_organization_id = org.ID;
                 else
                        INSERT into  pji_pmv_prj_dim_tmp (id, name)
                        SELECT DISTINCT prj.project_id, '-1' name
                        FROM
                         pji_pmv_orgz_dim_tmp org
                        , pa_projects_all prj
                        , pa_project_types_all pt
                        WHERE
                         prj.carrying_out_organization_id = org.ID
                        AND pt.project_type = prj.project_type
                        AND decode (g_context,'PROFIT',pt.project_type_class_code,'ALL') =
                            decode (g_context,'PROFIT','CONTRACT','ALL'); /* Added for bug 9366920 */
                end if;

			END;

	ELSE
	PJI_PMV_ENGINE.Convert_Project(P_PROJECT_IDS=>p_Project_IDS
						, P_VIEW_BY =>p_View_BY);
	END IF;



/*
** ORG Processing ---------------------------------------------------+
*/


/* ----------------------------- Case 1 truth table ------------------------------------ */

        IF (l_Convert_Classification = 'N')
         and (l_Convert_Expenditure_Type = 'N')
         and (l_Convert_Event_Revenue_Type = 'N')
         and (l_Convert_Work_Type = 'N')
          THEN



			SELECT PJI_REP_PPDTL(PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(REVENUE)
			, SUM(BURDENED_COST)
			, SUM(CURR_BGT_REVENUE)
			, SUM(CURR_BGT_BURDENED_COST)
			, SUM(FORECAST_REVENUE)
			, SUM(FORECAST_BURDENED_COST)
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(TIME.amount_type,1,FCT.REVENUE, 0)                  AS REVENUE
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost, 0), 0)            AS BURDENED_COST
					, DECODE(TIME.amount_type,2,FCT.CURR_BGT_REVENUE, 0)         AS CURR_BGT_REVENUE
					, DECODE(TIME.amount_type,2,
                            DECODE(G_Report_Cost_Type,  'BC', fct.curr_bgt_burdened_cost,
                                                        'RC', fct.curr_bgt_raw_cost, 0), 0)   AS CURR_BGT_BURDENED_COST
					, DECODE(TIME.amount_type,2,FCT.FORECAST_REVENUE, 0)         AS FORECAST_REVENUE
					, DECODE(TIME.amount_type,2,
                            DECODE(G_Report_Cost_Type,  'BC', fct.forecast_burdened_cost,
                                                        'RC', fct.forecast_raw_cost, 0), 0)   AS FORECAST_BURDENED_COST
					FROM  PJI_PMV_TIME_DIM_TMP TIME
						, PJI_PMV_PRJ_DIM_TMP PRJ
						, PJI_PMV_ORGZ_DIM_TMP HORG
					        , PJI_FP_PROJ_F FCT
						, PJI_PMV_ORG_DIM_TMP HOU
					WHERE  1=1
					AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
					AND FCT.PROJECT_ID = PRJ.ID
					AND FCT.PROJECT_ORG_ID = HOU.ID
					AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
					AND FCT.TIME_ID = TIME.ID
					AND TIME.ID IS NOT NULL
					AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
					AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
					) FCT
			GROUP BY PROJECT_ID,ORGANIZATION_ID;

/*
** -- PROJECT CLASSIFICATION Processing ---------------------------------------------------+
*/


/* -----------------------------------  Case 2 truth table   -------------------------------------  */

        ELSIF (l_Convert_Expenditure_Type = 'N')
         and (l_Convert_Event_Revenue_Type = 'N')
         and (l_Convert_Work_Type = 'N')

          THEN

			SELECT PJI_REP_PPDTL(PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(REVENUE)
			, SUM(BURDENED_COST)
			, SUM(CURR_BGT_REVENUE)
			, SUM(CURR_BGT_BURDENED_COST)
			, SUM(FORECAST_REVENUE)
			, SUM(FORECAST_BURDENED_COST)
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(TIME.amount_type,1,FCT.REVENUE, 0)                  AS REVENUE
					, DECODE(TIME.amount_type,1,
                        DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                    'RC', fct.raw_cost, 0), 0)   AS BURDENED_COST
					, DECODE(TIME.amount_type,2,FCT.CURR_BGT_REVENUE, 0)         AS CURR_BGT_REVENUE
					, DECODE(TIME.amount_type,2,
                        DECODE(G_Report_Cost_Type,  'BC',fct.curr_bgt_burdened_cost,
                                                    'RC',fct.curr_bgt_raw_cost, 0), 0)   AS CURR_BGT_BURDENED_COST
					, DECODE(TIME.amount_type,2,FCT.FORECAST_REVENUE, 0)         AS FORECAST_REVENUE
					, DECODE(TIME.amount_type,2,
                        DECODE(G_Report_Cost_Type,  'BC', fct.forecast_burdened_cost,
                                                    'RC', fct.forecast_raw_cost, 0), 0)   AS FORECAST_BURDENED_COST
					FROM   PJI_PMV_TIME_DIM_TMP TIME
						, PJI_PMV_PRJ_DIM_TMP PRJ
						, PJI_FP_PROJ_F FCT
						, PJI_PMV_ORG_DIM_TMP HOU
					WHERE  1=1
					AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
					AND FCT.PROJECT_ID = PRJ.ID
					AND FCT.PROJECT_ORG_ID = HOU.ID
					AND FCT.TIME_ID = TIME.ID
					AND TIME.ID IS NOT NULL
					AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
					AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
					) FCT
			GROUP BY PROJECT_ID,ORGANIZATION_ID;

/*
** Expenditure or Revenue Type Processing ---------------------------------------------------+
*/

/* -----------------------------------  Case 3 truth table   -------------------------------------  */

        ELSIF (l_Convert_Classification = 'N')
         and (l_Convert_Work_Type = 'N')
          THEN


			SELECT PJI_REP_PPDTL(PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(REVENUE)
			, SUM(BURDENED_COST)
			, SUM(CURR_BGT_REVENUE)
			, SUM(CURR_BGT_BURDENED_COST)
			, SUM(FORECAST_REVENUE)
			, SUM(FORECAST_BURDENED_COST)
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(TIME.amount_type,1,FCT.REVENUE, 0)                  AS REVENUE
					, DECODE(TIME.amount_type,1,
                        DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                    'RC', fct.raw_cost, 0), 0)   AS BURDENED_COST
					, NULL         AS CURR_BGT_REVENUE
					, NULL   	AS CURR_BGT_BURDENED_COST
					, NULL         AS FORECAST_REVENUE
					, NULL      AS FORECAST_BURDENED_COST
					FROM   PJI_PMV_TIME_DIM_TMP TIME
						, PJI_PMV_PRJ_DIM_TMP PRJ
						, PJI_PMV_ET_RT_DIM_TMP ET
						, PJI_FP_PROJ_ET_F FCT
						, PJI_PMV_ORG_DIM_TMP HOU
					WHERE  1=1
					AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
					AND FCT.PROJECT_ID = PRJ.ID
					AND FCT.EXP_EVT_TYPE_ID = ET.ID
					AND ET.record_type =

decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
					AND FCT.PROJECT_ORG_ID = HOU.ID
					AND FCT.TIME_ID = TIME.ID
					AND TIME.ID IS NOT NULL
					AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
					AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
					) FCT
			GROUP BY PROJECT_ID,ORGANIZATION_ID;

/*
**  Work Type Processing ---------------------------------------------------+
*/

/* -----------------------------------  Case 4 truth table   -------------------------------------  */

        ELSIF (l_Convert_Classification = 'N')
         and  (l_Convert_Expenditure_Type = 'N')
         and  (l_Convert_Event_Revenue_Type = 'N')
          THEN


			SELECT PJI_REP_PPDTL(PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(REVENUE)
			, SUM(BURDENED_COST)
			, SUM(CURR_BGT_REVENUE)
			, SUM(CURR_BGT_BURDENED_COST)
			, SUM(FORECAST_REVENUE)
			, SUM(FORECAST_BURDENED_COST)
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, null                  AS REVENUE
					, DECODE(TIME.amount_type,1,
                        DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                    'RC', fct.raw_cost, 0), 0)   AS BURDENED_COST
					, NULL         AS CURR_BGT_REVENUE
					, NULL   	AS CURR_BGT_BURDENED_COST
					, NULL         AS FORECAST_REVENUE
					, NULL      AS FORECAST_BURDENED_COST
					FROM   PJI_PMV_TIME_DIM_TMP TIME
						, PJI_PMV_PRJ_DIM_TMP PRJ
						, PJI_PMV_WT_DIM_TMP WT
						, PJI_FP_PROJ_ET_WT_F FCT
						, PJI_PMV_ORG_DIM_TMP HOU
					WHERE  1=1
					AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
					AND FCT.PROJECT_ID = PRJ.ID
					AND FCT.WORK_TYPE_ID = WT.ID
					AND FCT.PROJECT_ORG_ID = HOU.ID
					AND FCT.TIME_ID = TIME.ID
					AND TIME.ID IS NOT NULL
					AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
					AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
					) FCT
			GROUP BY PROJECT_ID,ORGANIZATION_ID;

/*
** Project classification and Expenditure or Revenue Type Processing ---------------------------------+
*/

/* -----------------------------------  Case 5 truth table   -------------------------------------  */

        ELSIF (l_Convert_Work_Type = 'N')
          THEN



			SELECT PJI_REP_PPDTL(PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(REVENUE)
			, SUM(BURDENED_COST)
			, SUM(CURR_BGT_REVENUE)
			, SUM(CURR_BGT_BURDENED_COST)
			, SUM(FORECAST_REVENUE)
			, SUM(FORECAST_BURDENED_COST)
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(TIME.amount_type,1,FCT.REVENUE, 0)                  AS REVENUE
					, DECODE(TIME.amount_type,1,
                        DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                    'RC', fct.raw_cost, 0), 0)   AS BURDENED_COST
					, NULL         AS CURR_BGT_REVENUE
					, NULL   	AS CURR_BGT_BURDENED_COST
					, NULL         AS FORECAST_REVENUE
					, NULL      AS FORECAST_BURDENED_COST
					FROM   PJI_PMV_TIME_DIM_TMP TIME
						, PJI_PMV_PRJ_DIM_TMP PRJ
						, PJI_PMV_ET_RT_DIM_TMP ET
						, PJI_FP_PROJ_ET_F FCT
						, PJI_PMV_ORG_DIM_TMP HOU
					WHERE  1=1
					AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
					AND FCT.PROJECT_ID = PRJ.ID
					AND FCT.EXP_EVT_TYPE_ID = ET.ID
					AND ET.record_type =

decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
					AND FCT.PROJECT_ORG_ID = HOU.ID
					AND FCT.TIME_ID = TIME.ID
					AND TIME.ID IS NOT NULL
					AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
					AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
					) FCT
			GROUP BY PROJECT_ID,ORGANIZATION_ID;

/*
** Expenditure or Revenue Type and Work Type Processing -----------------------------------------+
*/

/* -----------------------------------  Case 6 truth table   -------------------------------------  */

        ELSIF (l_Convert_Classification = 'N')
          THEN



			SELECT PJI_REP_PPDTL(PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(REVENUE)
			, SUM(BURDENED_COST)
			, SUM(CURR_BGT_REVENUE)
			, SUM(CURR_BGT_BURDENED_COST)
			, SUM(FORECAST_REVENUE)
			, SUM(FORECAST_BURDENED_COST)
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, null                  AS REVENUE
					, DECODE(TIME.amount_type,1,
                        DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                    'RC', fct.raw_cost, 0), 0)   AS BURDENED_COST
					, NULL         AS CURR_BGT_REVENUE
					, NULL   	AS CURR_BGT_BURDENED_COST
					, NULL         AS FORECAST_REVENUE
					, NULL      AS FORECAST_BURDENED_COST
					FROM   PJI_PMV_TIME_DIM_TMP TIME
						, PJI_PMV_PRJ_DIM_TMP PRJ
						, PJI_PMV_ET_RT_DIM_TMP ET
						, PJI_PMV_WT_DIM_TMP WT
						, PJI_FP_PROJ_ET_WT_F FCT
						, PJI_PMV_ORG_DIM_TMP HOU
					WHERE  1=1
					AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
					AND FCT.PROJECT_ID = PRJ.ID
					AND FCT.EXP_EVT_TYPE_ID = ET.ID
					AND ET.record_type =

decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
					AND FCT.WORK_TYPE_ID = WT.ID
					AND FCT.PROJECT_ORG_ID = HOU.ID
					AND FCT.TIME_ID = TIME.ID
					AND TIME.ID IS NOT NULL
					AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
					AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
					) FCT
			GROUP BY PROJECT_ID,ORGANIZATION_ID;

/*
**  Project classification and Work Type Processing -----------------------------------------------+
*/

/* -----------------------------------  Case 7 truth table   -------------------------------------  */

        ELSIF (l_Convert_Expenditure_Type = 'N')
          and (l_Convert_Event_Revenue_Type = 'N')
          THEN



			SELECT PJI_REP_PPDTL(PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(REVENUE)
			, SUM(BURDENED_COST)
			, SUM(CURR_BGT_REVENUE)
			, SUM(CURR_BGT_BURDENED_COST)
			, SUM(FORECAST_REVENUE)
			, SUM(FORECAST_BURDENED_COST)
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, null                  AS REVENUE
					, DECODE(TIME.amount_type,1,
                        DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                    'RC', fct.raw_cost, 0), 0)   AS BURDENED_COST
					, NULL         AS CURR_BGT_REVENUE
					, NULL   	AS CURR_BGT_BURDENED_COST
					, NULL         AS FORECAST_REVENUE
					, NULL      AS FORECAST_BURDENED_COST
					FROM   PJI_PMV_TIME_DIM_TMP TIME
						, PJI_PMV_PRJ_DIM_TMP PRJ
						, PJI_PMV_WT_DIM_TMP WT
						, PJI_FP_PROJ_ET_WT_F FCT
						, PJI_PMV_ORG_DIM_TMP HOU
					WHERE  1=1
					AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
					AND FCT.PROJECT_ID = PRJ.ID
					AND FCT.WORK_TYPE_ID = WT.ID
					AND FCT.PROJECT_ORG_ID = HOU.ID
					AND FCT.TIME_ID = TIME.ID
					AND TIME.ID IS NOT NULL
					AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
					AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
					) FCT
			GROUP BY PROJECT_ID,ORGANIZATION_ID;

/*
** Project classification and Expenditure or Revenue Type and Work Type Processing ----------------+
*/

/* -----------------------------------  Case 8 truth table   -------------------------------------  */

        ELSE


			SELECT PJI_REP_PPDTL(PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(REVENUE)
			, SUM(BURDENED_COST)
			, SUM(CURR_BGT_REVENUE)
			, SUM(CURR_BGT_BURDENED_COST)
			, SUM(FORECAST_REVENUE)
			, SUM(FORECAST_BURDENED_COST)
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, null                  AS REVENUE
					, DECODE(TIME.amount_type,1,
                        DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                    'RC', fct.raw_cost, 0), 0)   AS BURDENED_COST
					, NULL         AS CURR_BGT_REVENUE
					, NULL   	AS CURR_BGT_BURDENED_COST
					, NULL         AS FORECAST_REVENUE
					, NULL      AS FORECAST_BURDENED_COST
					FROM   PJI_PMV_TIME_DIM_TMP TIME
						, PJI_PMV_PRJ_DIM_TMP PRJ
						, PJI_PMV_ET_RT_DIM_TMP ET
						, PJI_PMV_WT_DIM_TMP WT
						, PJI_FP_PROJ_ET_WT_F FCT
						, PJI_PMV_ORG_DIM_TMP HOU
					WHERE  1=1
					AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
					AND FCT.PROJECT_ID = PRJ.ID
					AND FCT.EXP_EVT_TYPE_ID = ET.ID
					AND ET.record_type =

decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
					AND FCT.WORK_TYPE_ID = WT.ID
					AND FCT.PROJECT_ORG_ID = HOU.ID
					AND FCT.TIME_ID = TIME.ID
					AND TIME.ID IS NOT NULL
					AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
					AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
					) FCT
			GROUP BY PROJECT_ID,ORGANIZATION_ID;


	END IF;


	FOR i IN 1..l_detail_tab.COUNT
	LOOP
		/*
		** FETCH THE PRIMARY CUSTOMER NAME AND PROJECT MANAGER NAME.
		*/



l_detail_tab(i).PRIMARY_CUSTOMER_NAME:=PA_PROJECTS_MAINT_UTILS.GET_PRIMARY_CUSTOMER_NAME(l_detail_tab(i).PROJECT_ID);


l_detail_tab(i).PERSON_MANAGER_NAME:=PA_PROJECTS_MAINT_UTILS.GET_PROJECT_MANAGER_NAME(l_detail_tab(i).PROJECT_ID);


		/*
		** FETCH THE PROJECT ATTRIBUTES.
		*/
		SELECT NAME
			, SEGMENT1
			, PROJECT_TYPE
		INTO l_detail_tab(i).PROJECT_NAME
			, l_detail_tab(i).PROJECT_NUMBER
			, l_detail_tab(i).PROJECT_TYPE
		FROM PA_PROJECTS_ALL
		WHERE PROJECT_ID = l_detail_tab(i).PROJECT_ID;


		/*
		** FETCH THE ORGANIZATION NAME.
		*/
		SELECT NAME
		INTO l_detail_tab(i).ORGANIZATION_NAME
		FROM HR_ALL_ORGANIZATION_UNITS_TL
		WHERE LANGUAGE = USERENV ('LANG')
		AND ORGANIZATION_ID = l_detail_tab(i).ORGANIZATION_NAME;

		l_detail_tab(i).MARGIN := l_detail_tab(i).REVENUE - l_detail_tab(i).BURDENED_COST;
		l_detail_tab(i).BUDGET_MARGIN := l_detail_tab(i).CURR_BGT_REVENUE - l_detail_tab(i).CURR_BGT_BURDENED_COST;
		l_detail_tab(i).FORECAST_MARGIN := l_detail_tab(i).FORECAST_REVENUE - l_detail_tab(i).FORECAST_BURDENED_COST;

		IF NVL(l_detail_tab(i).CURR_BGT_BURDENED_COST, 0) <> 0 THEN
			l_detail_tab(i).COST_VARIANCE :=

100*((l_detail_tab(i).BURDENED_COST-l_detail_tab(i).CURR_BGT_BURDENED_COST)/ABS(l_detail_tab(i).CURR_BGT_BURDENED_COST));
			l_detail_tab(i).FORECAST_COST_VARIANCE :=

100*((l_detail_tab(i).FORECAST_BURDENED_COST-l_detail_tab(i).CURR_BGT_BURDENED_COST)/ABS(l_detail_tab(i).CURR_BGT_BURDENED_COST));
		ELSE
			l_detail_tab(i).FORECAST_COST_VARIANCE := NULL;
			l_detail_tab(i).COST_VARIANCE := NULL;
		END IF;

		IF NVL(l_detail_tab(i).BUDGET_MARGIN, 0) <> 0 THEN
			l_detail_tab(i).FORECAST_MARGIN_VARIANCE :=

100*((l_detail_tab(i).FORECAST_MARGIN-l_detail_tab(i).BUDGET_MARGIN)/ABS(l_detail_tab(i).BUDGET_MARGIN));
		ELSE
			l_detail_tab(i).FORECAST_MARGIN_VARIANCE := NULL;
		END IF;

		l_Total_Revenue := l_Total_Revenue + NVL(l_detail_tab(i).REVENUE , 0);
		l_Total_Cost := l_Total_Cost + NVL(l_detail_tab(i).BURDENED_COST , 0);
		l_Total_Bgt_Revenue := l_Total_Bgt_Revenue + NVL(l_detail_tab(i).CURR_BGT_REVENUE , 0);
		l_Total_Bgt_Cost := l_Total_Bgt_Cost + NVL(l_detail_tab(i).CURR_BGT_BURDENED_COST , 0);
		l_Total_Forecast_Revenue := l_Total_Forecast_Revenue + NVL(l_detail_tab(i).FORECAST_REVENUE , 0);
		l_Total_Forecast_Cost := l_Total_Forecast_Cost + NVL(l_detail_tab(i).FORECAST_BURDENED_COST , 0);
		l_Total_Margin := l_Total_Margin + NVL(l_detail_tab(i).MARGIN , 0);
		l_Total_Budget_Margin := l_Total_Budget_Margin + NVL(l_detail_tab(i).BUDGET_MARGIN , 0);
		l_Total_Fcst_Margin := l_Total_Fcst_Margin + NVL(l_detail_tab(i).FORECAST_MARGIN , 0);
	END LOOP;

	FOR i IN 1..l_detail_tab.COUNT
	LOOP
		l_detail_tab(i).PJI_REP_TOTAL_1:=l_Total_Revenue;
		l_detail_tab(i).PJI_REP_TOTAL_2:=l_Total_Cost;
		l_detail_tab(i).PJI_REP_TOTAL_3:=l_Total_Bgt_Revenue;
		l_detail_tab(i).PJI_REP_TOTAL_4:=l_Total_Bgt_Cost;
		l_detail_tab(i).PJI_REP_TOTAL_5:=l_Total_Forecast_Revenue;
		l_detail_tab(i).PJI_REP_TOTAL_6:=l_Total_Forecast_Cost;

		l_detail_tab(i).PJI_REP_TOTAL_7:=l_detail_tab(i).PJI_REP_TOTAL_1 - l_detail_tab(i).PJI_REP_TOTAL_2;
		l_detail_tab(i).PJI_REP_TOTAL_9:=l_detail_tab(i).PJI_REP_TOTAL_3 - l_detail_tab(i).PJI_REP_TOTAL_4;
		l_detail_tab(i).PJI_REP_TOTAL_10:=l_detail_tab(i).PJI_REP_TOTAL_5 - l_detail_tab(i).PJI_REP_TOTAL_6;

		IF NVL(l_detail_tab(i).PJI_REP_TOTAL_4, 0) <> 0 THEN
			l_detail_tab(i).PJI_REP_TOTAL_8 :=

100*((l_detail_tab(i).PJI_REP_TOTAL_2-l_detail_tab(i).PJI_REP_TOTAL_4)/ABS(l_detail_tab(i).PJI_REP_TOTAL_4));
			l_detail_tab(i).PJI_REP_TOTAL_12 :=

100*((l_detail_tab(i).PJI_REP_TOTAL_6-l_detail_tab(i).PJI_REP_TOTAL_4)/ABS(l_detail_tab(i).PJI_REP_TOTAL_4));
		ELSE
			l_detail_tab(i).PJI_REP_TOTAL_8 := NULL;
			l_detail_tab(i).PJI_REP_TOTAL_12 := NULL;
		END IF;

		IF NVL(l_detail_tab(i).PJI_REP_TOTAL_9, 0) <> 0 THEN
			l_detail_tab(i).PJI_REP_TOTAL_11 :=

100*((l_detail_tab(i).PJI_REP_TOTAL_10-l_detail_tab(i).PJI_REP_TOTAL_9)/ABS(l_detail_tab(i).PJI_REP_TOTAL_9));
		ELSE
			l_detail_tab(i).PJI_REP_TOTAL_11 := NULL;
		END IF;

	END LOOP;


/*
** Return the bulk collected table back to pmv.
*/

	   COMMIT;




           RETURN l_detail_tab;


        END PLSQLDriver_PJI_REP_PPDTL;




/* Name:                 PLSQLDriver_PJI_REP_PPSUM
** Type:                 Function
**
** Description:          This function receives PM Viewer runtime query parameters
**                       and RETURNS a PL/SQL table for the PM Viewer report.
**
** 			This function is designed for the Project SUMMARY Profitability
**                       Reports:
**                       1) Project Actual Profitability (PP1)
**                       2) Project Forecast Profitability (PP2)
**                       3) Project Cost Profitability (PP4)
**
** NOTE:
**                       The Project SUMMARY Profitability reports are DBI reports.
**
** Called subprograms:
**                       Various PJI_PMV_ENGINE.Convert APIs
**
** Called objects:
**                       PJI_REP_PPSUM_TBL (table of db object PJI_REP_PPSUM)
**
** History:
**       06-JUN-2002	jwhite		Created.
*/

	FUNCTION  PLSQLDriver_PJI_REP_PPSUM(
         p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
         , p_Organization		IN VARCHAR2
         , p_Currency_Type		IN VARCHAR2
         , p_As_of_Date         IN NUMBER
         , p_Time_Comparison_Type       IN VARCHAR2
         , p_Period_Type 		IN VARCHAR2
         , p_View_BY 			IN VARCHAR2
         , p_Classifications	IN VARCHAR2 DEFAULT NULL
         , p_Class_Codes		IN VARCHAR2 DEFAULT NULL

         , p_Expenditure_Category        IN VARCHAR2 DEFAULT NULL
         , p_Expenditure_Type            IN VARCHAR2 DEFAULT NULL
         , p_Revenue_Category            IN VARCHAR2 DEFAULT NULL
         , p_Revenue_Type                IN VARCHAR2 DEFAULT NULL
         , p_Work_Type                   IN VARCHAR2 DEFAULT NULL

         )  RETURN PJI_REP_PPSUM_TBL
	IS

        PRAGMA AUTONOMOUS_TRANSACTION;

/*
**  -- Local Variable Declaration
*/

	l_Total_Revenue				NUMBER:=0;
	l_Total_Cost				NUMBER:=0;
	l_Total_Forecast_Revenue		NUMBER:=0;
	l_Total_Forecast_Cost			NUMBER:=0;
	l_Total_Margin				NUMBER:=0;

	l_CT_Total_Revenue			NUMBER:=0;
	l_CT_Total_Cost				NUMBER:=0;
	l_CT_Total_Forecast_Revenue		NUMBER:=0;
	l_CT_Total_Forecast_Cost		NUMBER:=0;
	l_CT_Total_Margin				NUMBER:=0;

	l_TO_Total_Revenue			NUMBER:=0;
	l_TO_Total_Cost			NUMBER:=0;
	l_TO_Total_Forecast_Revenue	NUMBER:=0;
	l_TO_Total_Forecast_Cost		NUMBER:=0;
	l_TO_Total_Margin			NUMBER:=0;

	l_TO_CT_Total_Revenue		NUMBER:=0;
	l_TO_CT_Total_Cost			NUMBER:=0;
	l_TO_CT_Total_Forecast_Revenue	NUMBER:=0;
	l_TO_CT_Total_Forecast_Cost	NUMBER:=0;
	l_TO_CT_Total_Margin		NUMBER:=0;

	l_Top_Org_Index			    NUMBER;
	l_Top_Organization_Name		VARCHAR2(240);

        l_Convert_Classification        VARCHAR2(1);
        l_Convert_Expenditure_Type      VARCHAR2(1);
        l_Convert_Event_Revenue_Type    VARCHAR2(1);
        l_Convert_Work_Type             VARCHAR2(1);

	l_curr_record_type_id           NUMBER:= 1;
/*
**        -- PL/SQL Declaration
*/
	l_lines_tab		PJI_REP_PPSUM_TBL := PJI_REP_PPSUM_TBL();


BEGIN
    BEGIN
	    SELECT report_cost_type
		    INTO G_Report_Cost_Type
		    FROM pji_system_settings;
	    EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	    	G_Report_Cost_Type:='RC';
    END;

/*
**  Place a call to all the parse API's which parse the
**  parameters passed by PMV and populate all the
**  temporary tables.
*/

	PJI_PMV_ENGINE.Convert_Operating_Unit(P_OPERATING_UNIT_IDS   => p_Operating_Unit
                                                , P_VIEW_BY            => p_View_BY
                                              );


	PJI_PMV_ENGINE.Convert_Organization(P_TOP_ORGANIZATION_ID  => p_Organization
                                              , P_VIEW_BY            => p_View_BY
							    , p_Top_Organization_Name => l_Top_Organization_Name
                                            );


	IF p_Time_Comparison_Type <> 'BUDGET' THEN
		PJI_PMV_ENGINE.Convert_Time(P_AS_OF_DATE    => p_As_of_Date
      	                                , P_PERIOD_TYPE  =>  p_Period_Type
            	                          , P_VIEW_BY      =>  p_View_By
                  	                    , P_PARSE_PRIOR  =>  NULL
                        	              , P_REPORT_TYPE  =>  'DBI'
                              	        , P_COMPARATOR   =>  p_Time_Comparison_Type
                                    	  , P_PARSE_ITD    => NULL
	                                      , P_FULL_PERIOD_FLAG => 'Y'
      	                              );
	ELSE
		PJI_PMV_ENGINE.Convert_Time(P_AS_OF_DATE    => p_As_of_Date
      	                                , P_PERIOD_TYPE  =>  p_Period_Type
            	                          , P_VIEW_BY      =>  p_View_By
                  	                    , P_PARSE_PRIOR  =>  NULL
                        	              , P_REPORT_TYPE  =>  NULL
                              	        , P_COMPARATOR   =>  NULL
                                    	  , P_PARSE_ITD    =>  NULL
	                                      , P_FULL_PERIOD_FLAG => 'Y'
      	                              );
	END IF;

      l_Convert_Classification := PJI_PMV_ENGINE.Convert_Classification(p_Classifications, p_Class_Codes, p_View_BY);
      l_Convert_Expenditure_Type := PJI_PMV_ENGINE.Convert_Expenditure_Type(p_Expenditure_Category, p_Expenditure_Type, p_View_BY);
      l_Convert_Event_Revenue_Type := PJI_PMV_ENGINE.Convert_Event_Revenue_Type(p_Revenue_Category, p_Revenue_Type, p_View_BY );
      l_Convert_Work_Type := PJI_PMV_ENGINE.Convert_Work_Type(p_Work_Type, p_View_BY);
	l_curr_record_type_id:=PJI_PMV_ENGINE.Convert_Currency_Record_Type(p_Currency_Type);

/*
** -- Conditionally Processing from different facts  --------------------------------+
*/


/*
**		 Code the SQL statement for all of the following conditions
**		 1. Current Year Actuals and Forecast
**		 2. Prior Year Actuals and Forecast
**               3. Prior Period Actuals and Forecast
**              4. Budget Actuals and Forecast
**
**              Prior Year and Period and Budget amounts will be stored in the
**              equivalent Compare-To (CT) columns. Compare-To budget amounts
**                are always CURR_BGT amounts.
**
**
**               UNION ALLs conditionally create zero amount records for all OUs and organizations
**                 class/codes.
**                 1) The Org select forces creates OU and organization rows.
**                 2) The Class/Code select creates OU and organization rows as well as class/code
**                    rows. The OU/organization forced rows are required because the user can
**                    VIEWBY OU/Organization and filter by Class/Code.
**
**		 Bulk-Collect the output into a pl/sql table to be returned to
**		 pmv.
*/


/*
** ORG Processing ---------------------------------------------------+
*/

/* -----------------------------------  Case 1 truth table   -------------------------------------  */

        IF (l_Convert_Classification = 'N')
         and (l_Convert_Expenditure_Type = 'N')
         and (l_Convert_Event_Revenue_Type = 'N')
         and (l_Convert_Work_Type = 'N')
          THEN


            SELECT PJI_REP_PPSUM(ORG_ID
                                 , ORGANIZATION_ID
                                 , PROJECT_CLASS_ID
				 , EXPENDITURE_CATEGORY
                                 , EXPENDITURE_TYPE_ID
                                 , REVENUE_CATEGORY
                                 , REVENUE_TYPE_ID
                                 , WORK_TYPE_ID
                                 , SUM(REVENUE)
                                 , SUM(BURDENED_COST)
                                 , SUM(FORECAST_REVENUE)
                                 , SUM(FORECAST_BURDENED_COST)
                                 , SUM(CT_REVENUE)
                                 , SUM(CT_BURDENED_COST)
                                 , SUM(CT_FORECAST_REVENUE)
                                 , SUM(CT_FORECAST_BURDENED_COST)
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					 )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , DECODE(TIME.amount_type,1,REVENUE,0)                  AS REVENUE
                                 , DECODE(TIME.amount_type,1,
                                        DECODE(G_Report_Cost_Type,  'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                                    'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0),0) AS BURDENED_COST /* Modified for bug 9366920 */
                                 , DECODE(TIME.amount_type,2,FORECAST_REVENUE,0)         AS FORECAST_REVENUE
                                 , DECODE(TIME.amount_type,2,
                                        DECODE(G_Report_Cost_Type,  'BC', fct.forecast_burdened_cost,
                                                                    'RC', fct.forecast_raw_cost, 0),0)   AS

FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_FP_ORGO_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU

		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                UNION ALL -- CURRENT Approved Budgets
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , DECODE(TIME.amount_type,2,CURR_BGT_REVENUE,0)         AS CT_REVENUE
                                 , DECODE(TIME.amount_type,2,
                                 DECODE(G_Report_Cost_Type, 'BC', fct.curr_bgt_burdened_cost,
                                                            'RC', fct.curr_bgt_raw_cost, 0)
                                                                    ,0)   AS CT_BURDENED_COST
                                 , DECODE(TIME.amount_type,2,CURR_BGT_REVENUE,0)         AS CT_FORECAST_REVENUE
                                 , DECODE(TIME.amount_type,2,
                                 DECODE(G_Report_Cost_Type, 'BC', fct.curr_bgt_burdened_cost,
                                                            'RC', fct.curr_bgt_raw_cost, 0)
                                                                    ,0)   AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_FP_ORGO_F_MV fct
				, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and p_Time_Comparison_Type = 'BUDGET'
		UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , DECODE(TIME.amount_type,1,REVENUE,0)                  AS CT_REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0),0)    AS CT_BURDENED_COST /* Modified for bug 9366920 */
                                 , DECODE(TIME.amount_type,2,FORECAST_REVENUE,0)         AS CT_FORECAST_REVENUE
                                 , DECODE(TIME.amount_type,2,
                                 DECODE(G_Report_Cost_Type, 'BC', fct.forecast_burdened_cost,
                                                            'RC', fct.forecast_raw_cost, 0),0)   AS CT_FORECAST_BURDENED_COST
		FROM
				PJI_PMV_TCMP_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_FP_ORGO_F_MV fct
				, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and p_Time_Comparison_Type <> 'BUDGET'
		UNION ALL -- FORCE Creation of Org rows
                SELECT          HOU.NAME                    AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_ORG_DIM_TMP HOU
		WHERE    HOU.NAME <> '-1'
                UNION ALL  -- FORCE Creation of Organization Rows
                SELECT           '-1'                       AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
                )
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,EXPENDITURE_TYPE_ID,REVENUE_CATEGORY,
	             REVENUE_TYPE_ID, WORK_TYPE_ID;





/*
** -- PROJECT CLASSIFICATION Processing ---------------------------------------------------+
*/


/* -----------------------------------  Case 2 truth table   -------------------------------------  */

        ELSIF (l_Convert_Expenditure_Type = 'N')
         and (l_Convert_Event_Revenue_Type = 'N')
         and (l_Convert_Work_Type = 'N')

          THEN

            SELECT PJI_REP_PPSUM(ORG_ID
                                 , ORGANIZATION_ID
                                 , PROJECT_CLASS_ID
				 , EXPENDITURE_CATEGORY
                                 , EXPENDITURE_TYPE_ID
                                 , REVENUE_CATEGORY
                                 , REVENUE_TYPE_ID
                                 , WORK_TYPE_ID
                                 , SUM(REVENUE)
                                 , SUM(BURDENED_COST)
                                 , SUM(FORECAST_REVENUE)
                                 , SUM(FORECAST_BURDENED_COST)
                                 , SUM(CT_REVENUE)
                                 , SUM(CT_BURDENED_COST)
                                 , SUM(CT_FORECAST_REVENUE)
                                 , SUM(CT_FORECAST_BURDENED_COST)
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					 )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , CLS.NAME                 AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , DECODE(TIME.amount_type,1,REVENUE, 0)                  AS REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0), 0)    AS BURDENED_COST /* Modified for bug 9366920 */
                                 , DECODE(TIME.amount_type,2,FORECAST_REVENUE, 0)         AS FORECAST_REVENUE
                                 , DECODE(TIME.amount_type,2,
                                 DECODE(G_Report_Cost_Type, 'BC', fct.forecast_burdened_cost,
                                                            'RC', fct.forecast_raw_cost, 0), 0)   AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_FP_CLSO_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.project_org_id = hou.id
				AND FCT.project_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.project_class_id = CLS.id
                UNION ALL -- CURRENT Approved Budgets
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , CLS.NAME                 AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , DECODE(TIME.amount_type,2,CURR_BGT_REVENUE, 0)         AS CT_REVENUE
                                 , DECODE(TIME.amount_type,2,
                                 DECODE(G_Report_Cost_Type, 'BC', fct.curr_bgt_burdened_cost,
                                                            'RC', fct.curr_bgt_raw_cost, 0), 0)   AS CT_BURDENED_COST
                                 , DECODE(TIME.amount_type,2,CURR_BGT_REVENUE, 0)         AS CT_FORECAST_REVENUE
                                 , DECODE(TIME.amount_type,2,
                                 DECODE(G_Report_Cost_Type, 'BC', fct.curr_bgt_burdened_cost,
                                                            'RC', fct.curr_bgt_raw_cost, 0), 0)   AS

CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
            , PJI_FP_CLSO_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.project_org_id = hou.id
				AND FCT.project_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
             	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.project_class_id = CLS.id
                and p_Time_Comparison_Type = 'BUDGET'
		UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , CLS.NAME                 AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , DECODE(TIME.amount_type,1,REVENUE, 0)                  AS CT_REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0), 0)            AS CT_BURDENED_COST /* Modified for bug 9366920 */
                                 , DECODE(TIME.amount_type,2,FORECAST_REVENUE, 0)         AS CT_FORECAST_REVENUE
                                 , DECODE(TIME.amount_type,2,
                                 DECODE(G_Report_Cost_Type, 'BC', fct.forecast_burdened_cost,
                                                            'RC', fct.forecast_raw_cost, 0), 0)   AS

CT_FORECAST_BURDENED_COST
		FROM
				PJI_PMV_TCMP_DIM_TMP TIME
                , PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_CLS_DIM_TMP CLS
				, PJI_FP_CLSO_F_MV fct
				, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.project_org_id = hou.id
				AND FCT.project_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.project_class_id = CLS.id
                and p_Time_Comparison_Type <> 'BUDGET'
		UNION ALL  -- FORCE Creation of Org Rows
                SELECT          HOU.NAME                    AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	PJI_PMV_ORG_DIM_TMP HOU
		WHERE   HOU.NAME <> '-1'
                UNION ALL -- FORCE Creation of Organization Rows
                SELECT           '-1'                       AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
                UNION ALL -- FORCE Creation of Class/Code Rows
                SELECT           '-1'                       AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , NAME                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_CLS_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
                )
           WHERE 1 = 1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,EXPENDITURE_TYPE_ID,REVENUE_CATEGORY,
	             REVENUE_TYPE_ID, WORK_TYPE_ID;

/*
** Expenditure or Revenue Type Processing ---------------------------------------------------+
*/

/* -----------------------------------  Case 3 truth table   -------------------------------------  */

        ELSIF (l_Convert_Classification = 'N')
         and (l_Convert_Work_Type = 'N')
          THEN

            SELECT PJI_REP_PPSUM(ORG_ID
                                 , ORGANIZATION_ID
                                 , PROJECT_CLASS_ID
				 , EXPENDITURE_CATEGORY
                                 , EXPENDITURE_TYPE_ID
                                 , REVENUE_CATEGORY
                                 , REVENUE_TYPE_ID
                                 , WORK_TYPE_ID
                                 , SUM(REVENUE)
                                 , SUM(BURDENED_COST)
                                 , SUM(FORECAST_REVENUE)
                                 , SUM(FORECAST_BURDENED_COST)
                                 , SUM(CT_REVENUE)
                                 , SUM(CT_BURDENED_COST)
                                 , SUM(CT_FORECAST_REVENUE)
                                 , SUM(CT_FORECAST_BURDENED_COST)
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					 )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')             AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , DECODE(TIME.amount_type,1,REVENUE, 0)                  AS REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0), 0)    AS BURDENED_COST /* Modified for bug 9366920 */
                                  , NULL         		AS FORECAST_REVENUE
                                 , NULL   			AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , NULL                        AS CT_FORECAST_REVENUE
                                 , NULL                        AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_ORGO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.exp_evt_type_id = ET.id
                and ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
                UNION ALL -- CURRENT Approved Budgets
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                 AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')             AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')	      AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0         		AS CT_REVENUE
                                 , 0			AS CT_BURDENED_COST
                                 , NULL		    	    AS CT_FORECAST_REVENUE
                                 , NULL                     AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_ORGO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
             	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.exp_evt_type_id = ET.id
                and ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
                and p_Time_Comparison_Type = 'BUDGET'
		UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                 AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')              AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , DECODE(TIME.amount_type,1,REVENUE, 0)                  AS CT_REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0), 0)            AS CT_BURDENED_COST /* Modified for bug 9366920 */
                                 , NULL         AS CT_FORECAST_REVENUE
                                 , NULL   	AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TCMP_DIM_TMP TIME
                	, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_ORGO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.exp_evt_type_id = ET.id
                and ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
                and p_Time_Comparison_Type <> 'BUDGET'
		UNION ALL  -- FORCE Creation of Org Rows
                SELECT          HOU.NAME                    AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	PJI_PMV_ORG_DIM_TMP HOU
		WHERE   HOU.NAME <> '-1'
                UNION ALL -- FORCE Creation of Organization Rows
                SELECT           '-1'                       AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
                UNION ALL -- FORCE Creation of Expenditure Category/Type Rows
                SELECT           '-1'                       AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')              AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_ET_RT_DIM_TMP ET
		WHERE    ET.NAME <> '-1'
                )
           WHERE 1 = 1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,EXPENDITURE_TYPE_ID,REVENUE_CATEGORY,
	             REVENUE_TYPE_ID, WORK_TYPE_ID;

/*
**  Work Type Processing ---------------------------------------------------+
*/

/* -----------------------------------  Case 4 truth table   -------------------------------------  */

        ELSIF (l_Convert_Classification = 'N')
         and  (l_Convert_Expenditure_Type = 'N')
         and  (l_Convert_Event_Revenue_Type = 'N')
          THEN

            SELECT PJI_REP_PPSUM(ORG_ID
                                 , ORGANIZATION_ID
                                 , PROJECT_CLASS_ID
				 , EXPENDITURE_CATEGORY
                                 , EXPENDITURE_TYPE_ID
                                 , REVENUE_CATEGORY
                                 , REVENUE_TYPE_ID
                                 , WORK_TYPE_ID
                                 , SUM(REVENUE)
                                 , SUM(BURDENED_COST)
                                 , SUM(FORECAST_REVENUE)
                                 , SUM(FORECAST_BURDENED_COST)
                                 , SUM(CT_REVENUE)
                                 , SUM(CT_BURDENED_COST)
                                 , SUM(CT_FORECAST_REVENUE)
                                 , SUM(CT_FORECAST_BURDENED_COST)
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					 )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'             	    AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , WT.NAME                     AS WORK_TYPE_ID
                                 , null                  AS REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0), 0)    AS BURDENED_COST /* Modified for bug 9366920 */
                                 , NULL         		AS FORECAST_REVENUE
                                 , NULL   			AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , NULL                        AS CT_FORECAST_REVENUE
                                 , NULL                        AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.work_type_id = WT.id
                UNION ALL -- CURRENT Approved Budgets
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                 AS PROJECT_CLASS_ID
                                 , '-1'             AS EXPENDITURE_CATEGORY
                                 , '-1'             AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , WT.NAME                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0         		AS CT_REVENUE
                                 , 0			AS CT_BURDENED_COST
                                 , NULL		    	    AS CT_FORECAST_REVENUE
                                 , NULL                     AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
             	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.work_type_id = WT.id
                and p_Time_Comparison_Type = 'BUDGET'
		UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                 AS PROJECT_CLASS_ID
                                 , '-1'             AS EXPENDITURE_CATEGORY
                                 , '-1'             AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , WT.NAME                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , null                  AS CT_REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0), 0)            AS CT_BURDENED_COST /* Modified for bug 9366920 */
                                 , NULL         AS CT_FORECAST_REVENUE
                                 , NULL   	AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TCMP_DIM_TMP TIME
                	, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.work_type_id = WT.id
                and p_Time_Comparison_Type <> 'BUDGET'
		UNION ALL  -- FORCE Creation of Org Rows
                SELECT          HOU.NAME                    AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	PJI_PMV_ORG_DIM_TMP HOU
		WHERE   HOU.NAME <> '-1'
                UNION ALL -- FORCE Creation of Organization Rows
                SELECT           '-1'                       AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
                UNION ALL -- FORCE Creation of Work Type Rows
                SELECT           '-1'                       AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'             AS EXPENDITURE_CATEGORY
                                 , '-1'             AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , WT.NAME                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_WT_DIM_TMP WT
		WHERE    WT.NAME <> '-1'
                )
           WHERE 1 = 1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,EXPENDITURE_TYPE_ID,REVENUE_CATEGORY,
	             REVENUE_TYPE_ID, WORK_TYPE_ID;

/*
** Project classification and Expenditure or Revenue Type Processing ---------------------------------+
*/

/* -----------------------------------  Case 5 truth table   -------------------------------------  */

        ELSIF (l_Convert_Work_Type = 'N')
          THEN

            SELECT PJI_REP_PPSUM(ORG_ID
                                 , ORGANIZATION_ID
                                 , PROJECT_CLASS_ID
				 , EXPENDITURE_CATEGORY
                                 , EXPENDITURE_TYPE_ID
                                 , REVENUE_CATEGORY
                                 , REVENUE_TYPE_ID
                                 , WORK_TYPE_ID
                                 , SUM(REVENUE)
                                 , SUM(BURDENED_COST)
                                 , SUM(FORECAST_REVENUE)
                                 , SUM(FORECAST_BURDENED_COST)
                                 , SUM(CT_REVENUE)
                                 , SUM(CT_BURDENED_COST)
                                 , SUM(CT_FORECAST_REVENUE)
                                 , SUM(CT_FORECAST_BURDENED_COST)
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					 )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , decode(p_view_by, 'CC', CLS.name, '-1')                     AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             	      AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')                     AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')             AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , DECODE(TIME.amount_type,1,REVENUE, 0)                  AS REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0), 0)    AS BURDENED_COST /* Modified for bug 9366920 */
                                 , NULL         		AS FORECAST_REVENUE
                                 , NULL   			AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , NULL                        AS CT_FORECAST_REVENUE
                                 , NULL                        AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_CLSO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.project_org_id = hou.id
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.project_class_id = CLS.id
                and fct.exp_evt_type_id = ET.id
                and ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
                UNION ALL -- CURRENT Approved Budgets
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , decode(p_view_by, 'CC', CLS.name, '-1')                     AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             	      AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')                     AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')             AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0         		AS CT_REVENUE
                                 , 0			AS CT_BURDENED_COST
                                 , NULL		    	    AS CT_FORECAST_REVENUE
                                 , NULL                     AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_CLSO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.project_org_id = hou.id
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.project_class_id = CLS.id
                and fct.exp_evt_type_id = ET.id
                and ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
                and p_Time_Comparison_Type = 'BUDGET'
		UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , decode(p_view_by, 'CC', CLS.name, '-1')                     AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             	      AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')                     AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')             AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , DECODE(TIME.amount_type,1,REVENUE, 0)                  AS CT_REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0), 0)            AS CT_BURDENED_COST /* Modified for bug 9366920 */
                                , NULL         AS CT_FORECAST_REVENUE
                                 , NULL   	AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_FP_CLSO_ET_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.project_org_id = hou.id
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.project_class_id = CLS.id
                and fct.exp_evt_type_id = ET.id
                and ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
                and p_Time_Comparison_Type <> 'BUDGET'
		UNION ALL  -- FORCE Creation of Org Rows
                SELECT          HOU.NAME                    AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	PJI_PMV_ORG_DIM_TMP HOU
		WHERE   HOU.NAME <> '-1'
                UNION ALL -- FORCE Creation of Organization Rows
                SELECT           '-1'                       AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
                UNION ALL -- FORCE Creation of Class/Code Rows
                SELECT           '-1'                       AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , CLS.NAME                     AS PROJECT_CLASS_ID
                                 , '-1'             AS EXPENDITURE_CATEGORY
                                 , '-1'             AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_CLS_DIM_TMP CLS
		WHERE    CLS.NAME <> '-1'
                UNION ALL -- FORCE Creation of Expenditure Category/Type Rows
                SELECT           '-1'                       AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')             AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_ET_RT_DIM_TMP ET
		WHERE    ET.NAME <> '-1'

                )
           WHERE 1 = 1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,EXPENDITURE_TYPE_ID,REVENUE_CATEGORY,
	             REVENUE_TYPE_ID, WORK_TYPE_ID;

/*
** Expenditure or Revenue Type and Work Type Processing -----------------------------------------+
*/

/* -----------------------------------  Case 6 truth table   -------------------------------------  */

        ELSIF (l_Convert_Classification = 'N')
          THEN

            SELECT PJI_REP_PPSUM(ORG_ID
                                 , ORGANIZATION_ID
                                 , PROJECT_CLASS_ID
				 , EXPENDITURE_CATEGORY
                                 , EXPENDITURE_TYPE_ID
                                 , REVENUE_CATEGORY
                                 , REVENUE_TYPE_ID
                                 , WORK_TYPE_ID
                                 , SUM(REVENUE)
                                 , SUM(BURDENED_COST)
                                 , SUM(FORECAST_REVENUE)
                                 , SUM(FORECAST_BURDENED_COST)
                                 , SUM(CT_REVENUE)
                                 , SUM(CT_BURDENED_COST)
                                 , SUM(CT_FORECAST_REVENUE)
                                 , SUM(CT_FORECAST_BURDENED_COST)
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					 )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             	      AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')                     AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')             AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , decode(p_view_by, 'WT', WT.name, '-1')                     AS WORK_TYPE_ID
                                 , null                  AS REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0), 0)    AS BURDENED_COST /* Modified for bug 9366920 */
                                 , NULL         		AS FORECAST_REVENUE
                                 , NULL   			AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , NULL                        AS CT_FORECAST_REVENUE
                                 , NULL                        AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.exp_evt_type_id = ET.id
                and ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
                and fct.work_type_id = WT.id
                UNION ALL -- CURRENT Approved Budgets
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             	      AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')                     AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')             AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , decode(p_view_by, 'WT', WT.name, '-1')                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0         		AS CT_REVENUE
                                 , 0			AS CT_BURDENED_COST
                                 , NULL		    	    AS CT_FORECAST_REVENUE
                                 , NULL                     AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.exp_evt_type_id = ET.id
                and ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
                and fct.work_type_id = WT.id
                and p_Time_Comparison_Type = 'BUDGET'
		UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             	      AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')                     AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')             AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , decode(p_view_by, 'WT', WT.name, '-1')                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , null                  AS CT_REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0), 0)            AS CT_BURDENED_COST /* Modified for bug 9366920 */
                                  , NULL         AS CT_FORECAST_REVENUE
                                 , NULL   	AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_ORGO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.exp_evt_type_id = ET.id
                and ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
                and fct.work_type_id = WT.id
                and p_Time_Comparison_Type <> 'BUDGET'
		UNION ALL  -- FORCE Creation of Org Rows
                SELECT          HOU.NAME                    AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	PJI_PMV_ORG_DIM_TMP HOU
		WHERE   HOU.NAME <> '-1'
                UNION ALL -- FORCE Creation of Organization Rows
                SELECT           '-1'                       AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
                UNION ALL -- FORCE Creation of Expenditure Category/Type Rows
                SELECT           '-1'                       AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')             AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_ET_RT_DIM_TMP ET
		WHERE    ET.NAME <> '-1'
                UNION ALL -- FORCE Creation of Work Type Rows
                SELECT           '-1'                       AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'             AS EXPENDITURE_CATEGORY
                                 , '-1'             AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , decode(p_view_by, 'WT', WT.name, '-1')                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_WT_DIM_TMP WT
		WHERE    WT.NAME <> '-1'


                )
           WHERE 1 = 1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,EXPENDITURE_TYPE_ID,REVENUE_CATEGORY,
	             REVENUE_TYPE_ID, WORK_TYPE_ID;

/*
**  Project classification and Work Type Processing -----------------------------------------------+
*/

/* -----------------------------------  Case 7 truth table   -------------------------------------  */

        ELSIF (l_Convert_Expenditure_Type = 'N')
          and (l_Convert_Event_Revenue_Type = 'N')
          THEN

            SELECT PJI_REP_PPSUM(ORG_ID
                                 , ORGANIZATION_ID
                                 , PROJECT_CLASS_ID
				 , EXPENDITURE_CATEGORY
                                 , EXPENDITURE_TYPE_ID
                                 , REVENUE_CATEGORY
                                 , REVENUE_TYPE_ID
                                 , WORK_TYPE_ID
                                 , SUM(REVENUE)
                                 , SUM(BURDENED_COST)
                                 , SUM(FORECAST_REVENUE)
                                 , SUM(FORECAST_BURDENED_COST)
                                 , SUM(CT_REVENUE)
                                 , SUM(CT_BURDENED_COST)
                                 , SUM(CT_FORECAST_REVENUE)
                                 , SUM(CT_FORECAST_BURDENED_COST)
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					 )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , decode(p_view_by, 'CC', CLS.name, '-1')                     AS PROJECT_CLASS_ID
                                 , '-1'             	    AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , decode(p_view_by, 'WT', WT.name, '-1')                     AS WORK_TYPE_ID
                                 , null                  AS REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0), 0)    AS BURDENED_COST /* Modified for bug 9366920 */
                                 , NULL         		AS FORECAST_REVENUE
                                 , NULL   			AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , NULL                        AS CT_FORECAST_REVENUE
                                 , NULL                        AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_CLSO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.project_org_id = hou.id
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.project_class_id = CLS.id
                and fct.work_type_id = WT.id
                UNION ALL -- CURRENT Approved Budgets
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , decode(p_view_by, 'CC', CLS.name, '-1')                     AS PROJECT_CLASS_ID
                                 , '-1'             	    AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , decode(p_view_by, 'WT', WT.name, '-1')                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0         		AS CT_REVENUE
                                 , 0			AS CT_BURDENED_COST
                                 , NULL		    	    AS CT_FORECAST_REVENUE
                                 , NULL                     AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_CLSO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.project_org_id = hou.id
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.project_class_id = CLS.id
                and fct.work_type_id = WT.id
                and p_Time_Comparison_Type = 'BUDGET'
		UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , decode(p_view_by, 'CC', CLS.name, '-1')                     AS PROJECT_CLASS_ID
                                 , '-1'             	      AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , decode(p_view_by, 'WT', WT.name, '-1')                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , null                  AS CT_REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0), 0)            AS CT_BURDENED_COST /* Modified for bug 9366920 */
                                 , NULL         AS CT_FORECAST_REVENUE
                                 , NULL   	AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_CLSO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.project_org_id = hou.id
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.project_class_id = CLS.id
                and fct.work_type_id = WT.id
                and p_Time_Comparison_Type <> 'BUDGET'
		UNION ALL  -- FORCE Creation of Org Rows
                SELECT          HOU.NAME                    AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	PJI_PMV_ORG_DIM_TMP HOU
		WHERE   HOU.NAME <> '-1'
                UNION ALL -- FORCE Creation of Organization Rows
                SELECT           '-1'                       AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
                UNION ALL -- FORCE Creation of Class/Code Rows
                SELECT           '-1'                       AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , decode(p_view_by, 'CC', CLS.name, '-1')                     AS PROJECT_CLASS_ID
                                 , '-1'             AS EXPENDITURE_CATEGORY
                                 , '-1'             AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_CLS_DIM_TMP CLS
		WHERE    CLS.NAME <> '-1'
                UNION ALL -- FORCE Creation of Work Type Rows
                SELECT           '-1'                       AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'             AS EXPENDITURE_CATEGORY
                                 , '-1'             AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , decode(p_view_by, 'WT', WT.name, '-1')                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_WT_DIM_TMP WT
		WHERE    WT.NAME <> '-1'


                )
           WHERE 1 = 1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,EXPENDITURE_TYPE_ID,REVENUE_CATEGORY,
	             REVENUE_TYPE_ID, WORK_TYPE_ID;

/*
** Project classification and Expenditure or Revenue Type and Work Type Processing ----------------+
*/

/* -----------------------------------  Case 8 truth table   -------------------------------------  */

        ELSE

            SELECT PJI_REP_PPSUM(ORG_ID
                                 , ORGANIZATION_ID
                                 , PROJECT_CLASS_ID
				 , EXPENDITURE_CATEGORY
                                 , EXPENDITURE_TYPE_ID
                                 , REVENUE_CATEGORY
                                 , REVENUE_TYPE_ID
                                 , WORK_TYPE_ID
                                 , SUM(REVENUE)
                                 , SUM(BURDENED_COST)
                                 , SUM(FORECAST_REVENUE)
                                 , SUM(FORECAST_BURDENED_COST)
                                 , SUM(CT_REVENUE)
                                 , SUM(CT_BURDENED_COST)
                                 , SUM(CT_FORECAST_REVENUE)
                                 , SUM(CT_FORECAST_BURDENED_COST)
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					   , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
					 )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , decode(p_view_by, 'CC', CLS.name, '-1')                     AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             	    AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')                     AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')             AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , decode(p_view_by, 'WT', WT.name, '-1')                     AS WORK_TYPE_ID
                                 , null                  AS REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0), 0)    AS BURDENED_COST /* Modified for bug 9366920 */
                                , NULL         		AS FORECAST_REVENUE
                                 , NULL   			AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , NULL                        AS CT_FORECAST_REVENUE
                                 , NULL                        AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_CLSO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.project_org_id = hou.id
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.project_class_id = CLS.id
                and fct.exp_evt_type_id = ET.id
                and ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
                and fct.work_type_id = WT.id
                UNION ALL -- CURRENT Approved Budgets
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , decode(p_view_by, 'CC', CLS.name, '-1')                     AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             	    AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')                     AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')             AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , decode(p_view_by, 'WT', WT.name, '-1')                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0         		AS CT_REVENUE
                                 , 0			AS CT_BURDENED_COST
                                 , NULL		    	    AS CT_FORECAST_REVENUE
                                 , NULL                     AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_CLSO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.project_org_id = hou.id
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.project_class_id = CLS.id
                and fct.exp_evt_type_id = ET.id
                and ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
                and fct.work_type_id = WT.id
                and p_Time_Comparison_Type = 'BUDGET'
		UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
                                 HOU.NAME                   AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , decode(p_view_by, 'CC', CLS.name, '-1')                     AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             	    AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')                     AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')             AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , decode(p_view_by, 'WT', WT.name, '-1')                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , null                  AS CT_REVENUE
                                 , DECODE(TIME.amount_type,1,
                                 DECODE(G_Report_Cost_Type, 'BC', DECODE(G_context,'PROFIT',fct.contract_brdn_cost,fct.burdened_cost) ,
                                                            'RC', DECODE(G_context,'PROFIT',fct.contract_raw_cost,fct.raw_cost), 0), 0)AS CT_BURDENED_COST
							      /* Modified for bug 9366920 */, NULL AS CT_FORECAST_REVENUE
                                 , NULL AS CT_FORECAST_BURDENED_COST
		FROM
			PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ET_RT_DIM_TMP ET
			, PJI_PMV_WT_DIM_TMP WT
			, PJI_FP_CLSO_ET_WT_F_MV fct
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.project_org_id = hou.id
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and fct.project_class_id = CLS.id
                and fct.exp_evt_type_id = ET.id
                and ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
                and fct.work_type_id = WT.id
                and p_Time_Comparison_Type <> 'BUDGET'
		UNION ALL  -- FORCE Creation of Org Rows
                SELECT          HOU.NAME                    AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , 0                        AS FORECAST_REVENUE
                                 , 0                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	PJI_PMV_ORG_DIM_TMP HOU
		WHERE   HOU.NAME <> '-1'
                UNION ALL -- FORCE Creation of Organization Rows
                SELECT           '-1'                       AS ORG_ID
                                 , HORG.NAME                AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'                     AS EXPENDITURE_CATEGORY
                                 , '-1'                     AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
                UNION ALL -- FORCE Creation of Class/Code Rows
                SELECT           '-1'                       AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , decode(p_view_by, 'CC', CLS.name, '-1')                     AS PROJECT_CLASS_ID
                                 , '-1'             AS EXPENDITURE_CATEGORY
                                 , '-1'             AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_CLS_DIM_TMP CLS
		WHERE    CLS.NAME <> '-1'
                UNION ALL -- FORCE Creation of Expenditure Category/Type Rows
                SELECT           '-1'                       AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
                                 , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
                                 , decode(p_view_by, 'RC', ET.name, '-1')             AS REVENUE_CATEGORY
                                 , decode(p_view_by, 'RT', ET.name, '-1')             AS REVENUE_TYPE_ID
                                 , '-1'                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_ET_RT_DIM_TMP ET
		WHERE    ET.NAME <> '-1'
                UNION ALL -- FORCE Creation of Work Type Rows
                SELECT           '-1'                       AS ORG_ID
                                 , '-1'                     AS ORGANIZATION_ID
                                 , '-1'                     AS PROJECT_CLASS_ID
                                 , '-1'             AS EXPENDITURE_CATEGORY
                                 , '-1'             AS EXPENDITURE_TYPE_ID
                                 , '-1'                     AS REVENUE_CATEGORY
                                 , '-1'                     AS REVENUE_TYPE_ID
                                 , decode(p_view_by, 'WT', WT.name, '-1')                     AS WORK_TYPE_ID
                                 , 0                        AS REVENUE
                                 , 0                        AS BURDENED_COST
                                 , NULL                        AS FORECAST_REVENUE
                                 , NULL                        AS FORECAST_BURDENED_COST
                                 , 0                        AS CT_REVENUE
                                 , 0                        AS CT_BURDENED_COST
                                 , 0                        AS CT_FORECAST_REVENUE
                                 , 0                        AS CT_FORECAST_BURDENED_COST
		FROM	 PJI_PMV_WT_DIM_TMP WT
		WHERE    WT.NAME <> '-1'


                )
           WHERE 1 = 1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,EXPENDITURE_TYPE_ID,REVENUE_CATEGORY,
	             REVENUE_TYPE_ID, WORK_TYPE_ID;

      END IF;-- p_Class_Codes_Ids NOT Passed by User

	FOR i in 1..l_lines_tab.COUNT
	LOOP

		IF p_View_By = 'OG' THEN
			IF l_lines_tab(i).ORGANIZATION_ID = l_Top_Organization_Name THEN
				l_Top_Org_Index:=i;

				/*
				** Storing the total values at top org level.
				*/
				l_TO_Total_Revenue :=l_lines_tab(i).REVENUE;
				l_TO_Total_Cost :=l_lines_tab(i).BURDENED_COST;
				l_TO_Total_Forecast_Revenue :=l_lines_tab(i).FORECAST_REVENUE;
				l_TO_Total_Forecast_Cost :=l_lines_tab(i).FORECAST_BURDENED_COST;

				l_TO_CT_Total_Revenue :=l_lines_tab(i).CT_REVENUE;
				l_TO_CT_Total_Cost :=l_lines_tab(i).CT_BURDENED_COST;
				l_TO_CT_Total_Forecast_Revenue :=l_lines_tab(i).CT_FORECAST_REVENUE;
				l_TO_CT_Total_Forecast_Cost :=l_lines_tab(i).CT_FORECAST_BURDENED_COST;
			ELSE
				l_Total_Revenue		:=l_Total_Revenue
                       + NVL(l_lines_tab(i).REVENUE,0);
				l_Total_Cost		:=l_Total_Cost
                       + NVL(l_lines_tab(i).BURDENED_COST,0);
				l_Total_Forecast_Revenue:=l_Total_Forecast_Revenue
                       + NVL(l_lines_tab(i).FORECAST_REVENUE,0);
				l_Total_Forecast_Cost	:=l_Total_Forecast_Cost
                       + NVL(l_lines_tab(i).FORECAST_BURDENED_COST,0);
				l_CT_Total_Revenue	:=l_CT_Total_Revenue
                       + NVL(l_lines_tab(i).CT_REVENUE,0);
				l_CT_Total_Cost		:=l_CT_Total_Cost
                       + NVL(l_lines_tab(i).CT_BURDENED_COST,0);
				l_CT_Total_Forecast_Revenue	:=l_CT_Total_Forecast_Revenue
                       + NVL(l_lines_tab(i).CT_FORECAST_REVENUE,0);
				l_CT_Total_Forecast_Cost:=l_CT_Total_Forecast_Cost
                       + NVL(l_lines_tab(i).CT_FORECAST_BURDENED_COST,0);
			END IF;
		ELSE
			l_Total_Revenue		:=l_Total_Revenue
                      + NVL(l_lines_tab(i).REVENUE,0);
			l_Total_Cost		:=l_Total_Cost
                      + NVL(l_lines_tab(i).BURDENED_COST,0);
			l_Total_Forecast_Revenue:=l_Total_Forecast_Revenue
                      + NVL(l_lines_tab(i).FORECAST_REVENUE,0);
			l_Total_Forecast_Cost	:=l_Total_Forecast_Cost
                      + NVL(l_lines_tab(i).FORECAST_BURDENED_COST,0);
			l_CT_Total_Revenue	:=l_CT_Total_Revenue
                      + NVL(l_lines_tab(i).CT_REVENUE,0);
			l_CT_Total_Cost		:=l_CT_Total_Cost
                      + NVL(l_lines_tab(i).CT_BURDENED_COST,0);
			l_CT_Total_Forecast_Revenue	:=l_CT_Total_Forecast_Revenue
                      + NVL(l_lines_tab(i).CT_FORECAST_REVENUE,0);
			l_CT_Total_Forecast_Cost:=l_CT_Total_Forecast_Cost
                      + NVL(l_lines_tab(i).CT_FORECAST_BURDENED_COST,0);
		END IF;

		l_lines_tab(i).MARGIN := l_lines_tab(i).REVENUE
			- l_lines_tab(i).BURDENED_COST;
		l_lines_tab(i).CT_MARGIN := l_lines_tab(i).CT_REVENUE
			- l_lines_tab(i).CT_BURDENED_COST;
		l_lines_tab(i).FCST_MARGIN := l_lines_tab(i).FORECAST_REVENUE
			- l_lines_tab(i).FORECAST_BURDENED_COST;
		l_lines_tab(i).FCST_CT_MARGIN := l_lines_tab(i).CT_FORECAST_REVENUE
			- l_lines_tab(i).CT_FORECAST_BURDENED_COST;


		IF NVL(l_lines_tab(i).REVENUE, 0) <> 0 THEN
			l_lines_tab(i).MARGIN_PERCENT := 100 * (l_lines_tab(i).MARGIN
				/ ABS( l_lines_tab(i).REVENUE));
		ELSE
			l_lines_tab(i).MARGIN_PERCENT := NULL;
		END IF;


		IF NVL(l_lines_tab(i).CT_REVENUE, 0) <> 0 THEN
			l_lines_tab(i).CT_MARGIN_PERCENT := 100 * (l_lines_tab(i).CT_MARGIN
				/ ABS( l_lines_tab(i).CT_REVENUE));
			l_lines_tab(i).REV_CHANGE_PERCENT := 100 * ( (l_lines_tab(i).REVENUE
				- l_lines_tab(i).CT_REVENUE)
				/ ABS( l_lines_tab(i).CT_REVENUE));
		ELSE
			l_lines_tab(i).CT_MARGIN_PERCENT := NULL;
			l_lines_tab(i).REV_CHANGE_PERCENT := NULL;
		END IF;

		IF NVL(l_lines_tab(i).CT_BURDENED_COST, 0) <> 0 THEN
			l_lines_tab(i).CST_CHANGE_PERCENT := 100 * ( (l_lines_tab(i).BURDENED_COST
				- l_lines_tab(i).CT_BURDENED_COST)
				/ ABS( l_lines_tab(i).CT_BURDENED_COST));
		ELSE
			l_lines_tab(i).CST_CHANGE_PERCENT := NULL;
		END IF;

		IF NVL(l_lines_tab(i).CT_MARGIN, 0) <> 0 THEN
			l_lines_tab(i).MAR_CHANGE_PERCENT := 100 * ( (l_lines_tab(i).MARGIN
				- l_lines_tab(i).CT_MARGIN)
				/ ABS( l_lines_tab(i).CT_MARGIN));
		ELSE
			l_lines_tab(i).MAR_CHANGE_PERCENT := NULL;
		END IF;


		IF NVL(l_lines_tab(i).FORECAST_REVENUE, 0) <> 0 THEN
			l_lines_tab(i).FCST_MARGIN_PERCENT := 100 * (l_lines_tab(i).FCST_MARGIN
				/ ABS( l_lines_tab(i).FORECAST_REVENUE));
		ELSE
			l_lines_tab(i).FCST_MARGIN_PERCENT := NULL;
		END IF;

		IF NVL(l_lines_tab(i).CT_FORECAST_REVENUE, 0) <> 0 THEN
			l_lines_tab(i).FCST_CT_MARGIN_PERCENT := 100 * (l_lines_tab(i).FCST_CT_MARGIN
				/ ABS( l_lines_tab(i).CT_FORECAST_REVENUE));
			l_lines_tab(i).FCST_REV_CHANGE_PERCENT := 100 * ( (l_lines_tab(i).FORECAST_REVENUE
				- l_lines_tab(i).CT_FORECAST_REVENUE)
				/ ABS( l_lines_tab(i).CT_FORECAST_REVENUE));
		ELSE
			l_lines_tab(i).FCST_CT_MARGIN_PERCENT := NULL;
			l_lines_tab(i).FCST_REV_CHANGE_PERCENT := NULL;
		END IF;

		IF NVL(l_lines_tab(i).CT_FORECAST_BURDENED_COST, 0) <> 0 THEN
			l_lines_tab(i).FCST_CST_CHANGE_PERCENT := 100 * ( (l_lines_tab(i).FORECAST_BURDENED_COST
				- l_lines_tab(i).CT_FORECAST_BURDENED_COST)
				/ ABS( l_lines_tab(i).CT_FORECAST_BURDENED_COST));
		ELSE
			l_lines_tab(i).FCST_CST_CHANGE_PERCENT := NULL;
		END IF;

		IF NVL(l_lines_tab(i).FCST_CT_MARGIN, 0) <> 0 THEN
			l_lines_tab(i).FCST_MAR_CHANGE_PERCENT := 100 * ( (l_lines_tab(i).FCST_MARGIN
				- l_lines_tab(i).FCST_CT_MARGIN)
				/ ABS( l_lines_tab(i).FCST_CT_MARGIN));
		ELSE
			l_lines_tab(i).FCST_MAR_CHANGE_PERCENT := NULL;
		END IF;

		l_lines_tab(i).MAR_PERCENT_CHANGE := l_lines_tab(i).MARGIN_PERCENT
			- l_lines_tab(i).CT_MARGIN_PERCENT;
		l_lines_tab(i).FCST_MAR_PERCENT_CHANGE := l_lines_tab(i).FCST_MARGIN_PERCENT
			- l_lines_tab(i).FCST_CT_MARGIN_PERCENT;
	END LOOP;


	IF p_View_By = 'OG' THEN
		l_lines_tab(l_Top_Org_Index).REVENUE
       		:=NVL(l_lines_tab(l_Top_Org_Index).REVENUE,0)-l_Total_Revenue;
		l_lines_tab(l_Top_Org_Index).BURDENED_COST
	        :=NVL(l_lines_tab(l_Top_Org_Index).BURDENED_COST,0)-l_Total_Cost;
		l_lines_tab(l_Top_Org_Index).FORECAST_REVENUE
	        :=NVL(l_lines_tab(l_Top_Org_Index).FORECAST_REVENUE,0)-l_Total_Forecast_Revenue;
		l_lines_tab(l_Top_Org_Index).FORECAST_BURDENED_COST
	        :=NVL(l_lines_tab(l_Top_Org_Index).FORECAST_BURDENED_COST,0)-l_Total_Forecast_Cost;
		l_lines_tab(l_Top_Org_Index).CT_REVENUE
	        :=NVL(l_lines_tab(l_Top_Org_Index).CT_REVENUE,0)-l_CT_Total_Revenue;
		l_lines_tab(l_Top_Org_Index).CT_BURDENED_COST
	        :=NVL(l_lines_tab(l_Top_Org_Index).CT_BURDENED_COST,0)-l_CT_Total_Cost;
		l_lines_tab(l_Top_Org_Index).CT_FORECAST_REVENUE
	        :=NVL(l_lines_tab(l_Top_Org_Index).CT_FORECAST_REVENUE,0)-l_CT_Total_Forecast_Revenue;
		l_lines_tab(l_Top_Org_Index).CT_FORECAST_BURDENED_COST
	        :=NVL(l_lines_tab(l_Top_Org_Index).CT_FORECAST_BURDENED_COST,0)-l_CT_Total_Forecast_Cost;

		l_lines_tab(l_Top_Org_Index).MARGIN := l_lines_tab(l_Top_Org_Index).REVENUE
			- l_lines_tab(l_Top_Org_Index).BURDENED_COST;
		l_lines_tab(l_Top_Org_Index).CT_MARGIN := l_lines_tab(l_Top_Org_Index).CT_REVENUE
			- l_lines_tab(l_Top_Org_Index).CT_BURDENED_COST;

		l_lines_tab(l_Top_Org_Index).FCST_MARGIN := l_lines_tab(l_Top_Org_Index).FORECAST_REVENUE
			- l_lines_tab(l_Top_Org_Index).FORECAST_BURDENED_COST;
		l_lines_tab(l_Top_Org_Index).FCST_CT_MARGIN := l_lines_tab(l_Top_Org_Index).CT_FORECAST_REVENUE
			- l_lines_tab(l_Top_Org_Index).CT_FORECAST_BURDENED_COST;

		IF NVL(l_lines_tab(l_Top_Org_Index).REVENUE, 0) <> 0 THEN
			l_lines_tab(l_Top_Org_Index).MARGIN_PERCENT := 100*(l_lines_tab(l_Top_Org_Index).MARGIN
				/ ABS( l_lines_tab(l_Top_Org_Index).REVENUE));
		ELSE
			l_lines_tab(l_Top_Org_Index).MARGIN_PERCENT := NULL;
		END IF;

		IF NVL(l_lines_tab(l_Top_Org_Index).CT_REVENUE, 0) <> 0 THEN
			l_lines_tab(l_Top_Org_Index).CT_MARGIN_PERCENT := 100*(l_lines_tab(l_Top_Org_Index).CT_MARGIN
				/ ABS( l_lines_tab(l_Top_Org_Index).CT_REVENUE));
			l_lines_tab(l_Top_Org_Index).REV_CHANGE_PERCENT := 100*((l_lines_tab(l_Top_Org_Index).REVENUE
				- l_lines_tab(l_Top_Org_Index).CT_REVENUE)/ABS( l_lines_tab(l_Top_Org_Index).CT_REVENUE));
		ELSE
			l_lines_tab(l_Top_Org_Index).CT_MARGIN_PERCENT := NULL;
			l_lines_tab(l_Top_Org_Index).REV_CHANGE_PERCENT := NULL;
		END IF;

		IF NVL(l_lines_tab(l_Top_Org_Index).CT_BURDENED_COST, 0) <> 0 THEN
			l_lines_tab(l_Top_Org_Index).CST_CHANGE_PERCENT := 100*((l_lines_tab(l_Top_Org_Index).BURDENED_COST
				- l_lines_tab(l_Top_Org_Index).CT_BURDENED_COST)/ABS(

l_lines_tab(l_Top_Org_Index).CT_BURDENED_COST));
		ELSE
			l_lines_tab(l_Top_Org_Index).CST_CHANGE_PERCENT := NULL;
		END IF;

		IF NVL(l_lines_tab(l_Top_Org_Index).CT_MARGIN, 0) <> 0 THEN
			l_lines_tab(l_Top_Org_Index).MAR_CHANGE_PERCENT := 100*((l_lines_tab(l_Top_Org_Index).MARGIN
				- l_lines_tab(l_Top_Org_Index).CT_MARGIN)/ABS( l_lines_tab(l_Top_Org_Index).CT_MARGIN));
		ELSE
			l_lines_tab(l_Top_Org_Index).MAR_CHANGE_PERCENT := NULL;
		END IF;

		IF NVL(l_lines_tab(l_Top_Org_Index).FORECAST_REVENUE, 0) <> 0 THEN
			l_lines_tab(l_Top_Org_Index).FCST_MARGIN_PERCENT := 100*(l_lines_tab(l_Top_Org_Index).FCST_MARGIN
				/ ABS( l_lines_tab(l_Top_Org_Index).FORECAST_REVENUE));
		ELSE
			l_lines_tab(l_Top_Org_Index).FCST_MARGIN_PERCENT := NULL;
		END IF;

		IF NVL(l_lines_tab(l_Top_Org_Index).CT_FORECAST_REVENUE, 0) <> 0 THEN
			l_lines_tab(l_Top_Org_Index).FCST_CT_MARGIN_PERCENT :=

100*(l_lines_tab(l_Top_Org_Index).FCST_CT_MARGIN
				/ ABS( l_lines_tab(l_Top_Org_Index).CT_FORECAST_REVENUE));
			l_lines_tab(l_Top_Org_Index).FCST_REV_CHANGE_PERCENT :=

100*((l_lines_tab(l_Top_Org_Index).FORECAST_REVENUE
				- l_lines_tab(l_Top_Org_Index).CT_FORECAST_REVENUE)/ABS(

l_lines_tab(l_Top_Org_Index).CT_FORECAST_REVENUE));
		ELSE
			l_lines_tab(l_Top_Org_Index).FCST_CT_MARGIN_PERCENT := NULL;
			l_lines_tab(l_Top_Org_Index).FCST_REV_CHANGE_PERCENT := NULL;
		END IF;

		IF NVL(l_lines_tab(l_Top_Org_Index).CT_FORECAST_BURDENED_COST, 0) <> 0 THEN
			l_lines_tab(l_Top_Org_Index).FCST_CST_CHANGE_PERCENT :=

100*((l_lines_tab(l_Top_Org_Index).FORECAST_BURDENED_COST
			- l_lines_tab(l_Top_Org_Index).CT_FORECAST_BURDENED_COST)/ABS(

l_lines_tab(l_Top_Org_Index).CT_FORECAST_BURDENED_COST));
		ELSE
			l_lines_tab(l_Top_Org_Index).FCST_CST_CHANGE_PERCENT := NULL;
		END IF;

		IF NVL(l_lines_tab(l_Top_Org_Index).FCST_CT_MARGIN, 0) <> 0 THEN
			l_lines_tab(l_Top_Org_Index).FCST_MAR_CHANGE_PERCENT :=

100*((l_lines_tab(l_Top_Org_Index).FCST_MARGIN
				- l_lines_tab(l_Top_Org_Index).FCST_CT_MARGIN)/ABS(

l_lines_tab(l_Top_Org_Index).FCST_CT_MARGIN));
		ELSE
			l_lines_tab(l_Top_Org_Index).FCST_MAR_CHANGE_PERCENT := NULL;
		END IF;

		l_lines_tab(l_Top_Org_Index).MAR_PERCENT_CHANGE := l_lines_tab(l_Top_Org_Index).MARGIN_PERCENT
			- l_lines_tab(l_Top_Org_Index).CT_MARGIN_PERCENT;
		l_lines_tab(l_Top_Org_Index).FCST_MAR_PERCENT_CHANGE := l_lines_tab(l_Top_Org_Index).FCST_MARGIN_PERCENT
			- l_lines_tab(l_Top_Org_Index).FCST_CT_MARGIN_PERCENT;

		IF NVL( l_lines_tab(l_Top_Org_Index).REVENUE, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).BURDENED_COST, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).FORECAST_REVENUE, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).FORECAST_BURDENED_COST, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).CT_REVENUE, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).CT_BURDENED_COST, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).CT_FORECAST_REVENUE, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).CT_FORECAST_BURDENED_COST, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).MARGIN, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).CT_MARGIN, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).MARGIN_PERCENT, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).CT_MARGIN_PERCENT, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).CST_CHANGE_PERCENT, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).REV_CHANGE_PERCENT, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).MAR_CHANGE_PERCENT, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).MAR_PERCENT_CHANGE, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).FCST_MARGIN, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).FCST_CT_MARGIN, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).FCST_MARGIN_PERCENT, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).FCST_CT_MARGIN_PERCENT, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).FCST_CST_CHANGE_PERCENT, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).FCST_REV_CHANGE_PERCENT, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).FCST_MAR_CHANGE_PERCENT, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).FCST_MAR_PERCENT_CHANGE, 0 ) = 0
		THEN
			l_lines_tab.DELETE(l_Top_Org_Index);
		END IF;
		l_Total_Revenue:=l_TO_Total_Revenue;
		l_Total_Cost:=l_TO_Total_Cost;
		l_Total_Forecast_Revenue:=l_TO_Total_Forecast_Revenue;
		l_Total_Forecast_Cost:=l_TO_Total_Forecast_Cost;
		l_CT_Total_Revenue:=l_TO_CT_Total_Revenue;
		l_CT_Total_Cost:=l_TO_CT_Total_Cost;
		l_CT_Total_Forecast_Revenue:=l_TO_CT_Total_Forecast_Revenue;
		l_CT_Total_Forecast_Cost:=l_TO_CT_Total_Forecast_Cost;
	END IF;

	IF l_lines_tab.COUNT > 0 THEN
	FOR i in l_lines_tab.FIRST..l_lines_tab.LAST
	LOOP
		IF l_lines_tab.EXISTS(i) THEN
			l_lines_tab(i).PJI_REP_TOTAL_1:=l_Total_Revenue;
			l_lines_tab(i).PJI_REP_TOTAL_2:=l_Total_Cost;
			l_lines_tab(i).PJI_REP_TOTAL_3:=l_Total_Forecast_Revenue;
			l_lines_tab(i).PJI_REP_TOTAL_4:=l_Total_Forecast_Cost;
			l_lines_tab(i).PJI_REP_TOTAL_5:=l_CT_Total_Revenue;
			l_lines_tab(i).PJI_REP_TOTAL_6:=l_CT_Total_Cost;
			l_lines_tab(i).PJI_REP_TOTAL_7:=l_CT_Total_Forecast_Revenue;
			l_lines_tab(i).PJI_REP_TOTAL_8:=l_CT_Total_Forecast_Cost;

			/* Actual Amount */
			l_lines_tab(i).PJI_REP_TOTAL_9:=l_Total_Revenue-l_Total_Cost; -- Total Margin
			l_lines_tab(i).PJI_REP_TOTAL_10:=l_CT_Total_Revenue-l_CT_Total_Cost; -- Total CT Margin

			IF NVL(l_Total_Revenue, 0) <> 0 THEN
				l_lines_tab(i).PJI_REP_TOTAL_11:=100*((l_Total_Revenue-l_Total_Cost)/ABS( l_Total_Revenue));

-- Margin %
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_11:=NULL;
			END IF;

			IF NVL(l_CT_Total_Revenue, 0) <> 0 THEN
				l_lines_tab(i).PJI_REP_TOTAL_12:=100*((l_CT_Total_Revenue-l_CT_Total_Cost)/ABS(

l_CT_Total_Revenue)); -- CT Margin %
				l_lines_tab(i).PJI_REP_TOTAL_14:=100*((l_Total_Revenue-l_CT_Total_Revenue)/ABS(

l_CT_Total_Revenue)); -- Revenue Change %
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_12:=NULL;
				l_lines_tab(i).PJI_REP_TOTAL_14:=NULL;
			END IF;

			IF NVL(l_CT_Total_Cost, 0) <> 0 THEN
				l_lines_tab(i).PJI_REP_TOTAL_13:=100*((l_Total_Cost-l_CT_Total_Cost)/ABS( l_CT_Total_Cost));

-- Cost Change %
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_13:=NULL;
			END IF;

			IF NVL(l_lines_tab(i).PJI_REP_TOTAL_10, 0) <> 0 THEN


l_lines_tab(i).PJI_REP_TOTAL_15:=100*((l_lines_tab(i).PJI_REP_TOTAL_9-l_lines_tab(i).PJI_REP_TOTAL_10)
					/ABS( l_lines_tab(i).PJI_REP_TOTAL_10)); -- Margin Change %
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_15:=NULL;
			END IF;

			l_lines_tab(i).PJI_REP_TOTAL_16:=l_lines_tab(i).PJI_REP_TOTAL_11-l_lines_tab(i).PJI_REP_TOTAL_12;

-- Margin % Change

			/* Forecast Amount */
			l_lines_tab(i).PJI_REP_TOTAL_17:=l_Total_Forecast_Revenue-l_Total_Forecast_Cost; -- Total Margin
			l_lines_tab(i).PJI_REP_TOTAL_18:=l_CT_Total_Forecast_Revenue-l_CT_Total_Forecast_Cost; -- Total CT Margin

			IF NVL(l_Total_Forecast_Revenue, 0) <> 0 THEN
				l_lines_tab(i).PJI_REP_TOTAL_19:=100*((l_Total_Forecast_Revenue-l_Total_Forecast_Cost)/ABS(

l_Total_Forecast_Revenue)); -- Margin %
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_19:=NULL;
			END IF;

			IF NVL(l_CT_Total_Forecast_Revenue, 0) <> 0 THEN


l_lines_tab(i).PJI_REP_TOTAL_20:=100*((l_CT_Total_Forecast_Revenue-l_CT_Total_Forecast_Cost)/ABS(

l_CT_Total_Forecast_Revenue)); -- CT Margin %


l_lines_tab(i).PJI_REP_TOTAL_22:=100*((l_Total_Forecast_Revenue-l_CT_Total_Forecast_Revenue)/ABS(

l_CT_Total_Forecast_Revenue)); -- Revenue Change %
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_20:=NULL;
				l_lines_tab(i).PJI_REP_TOTAL_22:=NULL;
			END IF;

			IF NVL(l_CT_Total_Forecast_Cost, 0) <> 0 THEN
				l_lines_tab(i).PJI_REP_TOTAL_21:=100*((l_Total_Forecast_Cost-l_CT_Total_Forecast_Cost)/ABS(

l_CT_Total_Forecast_Cost)); -- Cost Change %
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_21:=NULL;
			END IF;

			IF NVL(l_lines_tab(i).PJI_REP_TOTAL_18, 0) <> 0 THEN


l_lines_tab(i).PJI_REP_TOTAL_23:=100*((l_lines_tab(i).PJI_REP_TOTAL_17-l_lines_tab(i).PJI_REP_TOTAL_18)
					/ABS( l_lines_tab(i).PJI_REP_TOTAL_18)); -- Margin Change %
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_23:=NULL;
			END IF;

			l_lines_tab(i).PJI_REP_TOTAL_24:=l_lines_tab(i).PJI_REP_TOTAL_19-l_lines_tab(i).PJI_REP_TOTAL_20; -- Margin % Change

		END IF;
	END LOOP;
	END IF;

/*
** ---------------------------------------------------+
** --	 Return the bulk collected table back to pmv.-+
** ---------------------------------------------------+
*/
	COMMIT;


	RETURN l_lines_tab;


END PLSQLDriver_PJI_REP_PPSUM;

END PJI_PMV_PROFITABILITY;


/
