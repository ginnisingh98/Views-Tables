--------------------------------------------------------
--  DDL for Package Body PJI_PMV_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PMV_COST" AS
/* $Header: PJIRF06B.pls 120.7 2006/01/24 16:53:53 appldev noship $ */


G_Report_Cost_Type VARCHAR2(2);


/*
** Contract Projects Cost Summary
*/

PROCEDURE GET_SQL_PJI_REP_PC10(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
		    , x_PMV_Sql OUT NOCOPY VARCHAR2
       	            , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
	IS
	l_Err_Message   VARCHAR2(3200);
	l_PMV_Sql       VARCHAR2(3200);
BEGIN

            PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
				, P_SELECT_LIST =>'
                  COST                         "PJI_REP_MSR_1"
                , COST                         "PJI_REP_MSR_19"
                , CT_COST                      "PJI_REP_MSR_2"
                , COST_CHANGE_PRCNT            "PJI_REP_MSR_3"
                , BILL_COST                    "PJI_REP_MSR_4"
                , BILL_COST                    "PJI_REP_MSR_20"
                , CT_BILL_COST                 "PJI_REP_MSR_5"
                , BILL_COST_CHANGE_PRCNT       "PJI_REP_MSR_6"
                , BILL_PRCNT_OF_COST           "PJI_REP_MSR_7"
                , BILL_PRCNT_OF_COST           "PJI_REP_MSR_23"
                , CT_BILL_PRCNT_OF_COST        "PJI_REP_MSR_8"
                , PRCNT_OF_COST_CHANGE         "PJI_REP_MSR_9"
                , BUDGET                       "PJI_REP_MSR_10"
                , CT_BUDGET                    "PJI_REP_MSR_11"
                , BUDGET_CHANGE_PRCNT          "PJI_REP_MSR_12"
                , BILL_COST_PRCNT_OF_BUDGET    "PJI_REP_MSR_13"
                , BILL_COST_PRCNT_OF_BUDGET    "PJI_REP_MSR_21"
                , CT_BILL_COST_PRCNT_OF_BUDGET "PJI_REP_MSR_14"
                , CT_BILL_COST_PRCNT_OF_BUDGET "PJI_REP_MSR_22"
                , CHANGE                       "PJI_REP_MSR_15"
                , NON_BILL_COST                "PJI_REP_MSR_16"
                , NON_BILL_COST                "PJI_REP_MSR_24"
                , CT_NON_BILL_COST             "PJI_REP_MSR_17"
                , NON_BILL_COST_CHANGE_PRCNT   "PJI_REP_MSR_18"
                , FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1"
                , FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_2"
                , FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_3"
                , FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_4"
                , FACT.PJI_REP_TOTAL_5 "PJI_REP_TOTAL_5"
                , FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_6"
                , FACT.PJI_REP_TOTAL_7 "PJI_REP_TOTAL_7"
                , FACT.PJI_REP_TOTAL_8 "PJI_REP_TOTAL_8"
                , FACT.PJI_REP_TOTAL_9 "PJI_REP_TOTAL_9"
                , FACT.PJI_REP_TOTAL_10 "PJI_REP_TOTAL_10"
                , FACT.PJI_REP_TOTAL_11 "PJI_REP_TOTAL_11"
                , FACT.PJI_REP_TOTAL_12 "PJI_REP_TOTAL_12"
                , FACT.PJI_REP_TOTAL_13 "PJI_REP_TOTAL_13"
                , FACT.PJI_REP_TOTAL_14 "PJI_REP_TOTAL_14"
                , FACT.PJI_REP_TOTAL_15 "PJI_REP_TOTAL_15"
                , FACT.PJI_REP_TOTAL_16 "PJI_REP_TOTAL_16"
                , FACT.PJI_REP_TOTAL_17 "PJI_REP_TOTAL_17"
                , FACT.PJI_REP_TOTAL_18 "PJI_REP_TOTAL_18"
           	, FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_19"
                , FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_20"
                , FACT.PJI_REP_TOTAL_13 "PJI_REP_TOTAL_21"
                , FACT.PJI_REP_TOTAL_7  "PJI_REP_TOTAL_23"
                , FACT.PJI_REP_TOTAL_16 "PJI_REP_TOTAL_24"'
                	, P_SQL_STATEMENT => x_PMV_Sql
           		, P_PMV_OUTPUT => x_PMV_Output
				, p_Region_Code => 'PJI_REP_PC10'
				, p_PLSQL_Driver => 'PJI_PMV_COST.PLSQLDriver_PJI_REP_PC10'
				, p_PLSQL_Driver_Params =>
                  '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
				  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
				  ', <<CURRENCY+FII_CURRENCIES>>'||
				  ', <<AS_OF_DATE>>'||
     	          ', <<TIME_COMPARISON_TYPE>>'||
				  ', <<PERIOD_TYPE>>'||
				  ', <<VIEW_BY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CODE>> '||
				  ', <<PROJECT EXPENDITURE TYPE+PJI_EXP_CATEGORIES>> '||
				  ', <<PROJECT EXPENDITURE TYPE+PJI_EXP_TYPES>> '||
				  ', <<PROJECT WORK TYPE+PJI_WORK_TYPES>> '
                        );

END GET_SQL_PJI_REP_PC10;


/*
** Contract Projects Cost Trend
*/

PROCEDURE Get_SQL_PJI_REP_PC11 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql    OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
BEGIN
    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
            , P_SQL_STATEMENT => x_PMV_Sql
			, P_SELECT_LIST =>
				 'FACT.COST     "PJI_REP_MSR_1"
                 ,FACT.COST     "PJI_REP_MSR_19"
                 ,FACT.ct_COST  "PJI_REP_MSR_2"
                 ,FACT.ct_COST  "PJI_REP_MSR_20"
                 ,FACT.COST_CHANGE_PRCNT "PJI_REP_MSR_3"
                 ,FACT.BILL_COST "PJI_REP_MSR_4"
                 ,FACT.BILL_COST "PJI_REP_MSR_21"
                 ,FACT.ct_BILL_COST "PJI_REP_MSR_5"
                 ,FACT.ct_BILL_COST "PJI_REP_MSR_22"
                 ,FACT.BILL_COST_CHANGE_PRCNT "PJI_REP_MSR_6"
                 ,FACT.BILL_PRCNT_OF_COST     "PJI_REP_MSR_7"
                 ,FACT.ct_BILL_PRCNT_OF_COST  "PJI_REP_MSR_8"
                 ,FACT.PRCNT_OF_COST_CHANGE   "PJI_REP_MSR_9"
                 ,FACT.BUDGET                 "PJI_REP_MSR_10"
                 ,FACT.ct_BUDGET              "PJI_REP_MSR_11"
                 ,FACT.BUDGET_CHANGE_PRCNT    "PJI_REP_MSR_12"
                 ,FACT.BILL_COST_PRCNT_OF_BUDGET    "PJI_REP_MSR_13"
                 ,FACT.BILL_COST_PRCNT_OF_BUDGET    "PJI_REP_MSR_23"
                 ,FACT.ct_BILL_COST_PRCNT_OF_BUDGET "PJI_REP_MSR_14"
                 ,FACT.ct_BILL_COST_PRCNT_OF_BUDGET "PJI_REP_MSR_24"
                 ,FACT.CHANGE                 "PJI_REP_MSR_15"
                 ,FACT.NON_BILL_COST          "PJI_REP_MSR_16"
                 ,FACT.ct_NON_BILL_COST       "PJI_REP_MSR_17"
                 ,FACT.NON_BILL_COST_CHANGE_PRCNT "PJI_REP_MSR_18"'
            , P_PMV_OUTPUT => x_PMV_Output
            , P_REGION_CODE => 'PJI_REP_PC11'
            , P_PLSQL_DRIVER => 'PJI_PMV_COST.PLSQLDriver_PJI_REP_PC11'
            , P_PLSQL_DRIVER_PARAMS => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
			  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
			  ', <<CURRENCY+FII_CURRENCIES>>'||
			  ', <<AS_OF_DATE>>'||
			  ', <<PERIOD_TYPE>>'||
			  ', <<VIEW_BY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CODE>>'||
			  ', <<PROJECT EXPENDITURE TYPE+PJI_EXP_CATEGORIES>> '||
			  ', <<PROJECT EXPENDITURE TYPE+PJI_EXP_TYPES>> '||
			  ', <<PROJECT WORK TYPE+PJI_WORK_TYPES>> ');

END Get_SQL_PJI_REP_PC11;


/*
**  Contract Project Cost Detail
*/


PROCEDURE GET_SQL_PJI_REP_PC13(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
	     , x_PMV_Sql OUT NOCOPY VARCHAR2
         , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
	IS
	l_Err_Message   VARCHAR2(3200);
	l_PMV_Sql       VARCHAR2(3200);
	BEGIN

              PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
				, P_SELECT_LIST =>
				  ' FACT.PROJECT_ID             "PJI_REP_MSR_18"
				  , FACT.PROJECT_NAME           "VIEWBY"
				  , FACT.PROJECT_NUMBER         "PJI_REP_MSR_2"
				  , FACT.URL_PARAMETERS01       "PJI_REP_MSR_10"
                                  , FACT.URL_PARAMETERS01       "PJI_REP_MSR_30"
				  , FACT.PRIMARY_CUSTOMER_NAME  "PJI_REP_MSR_3"
				  , FACT.PROJECT_TYPE           "PJI_REP_MSR_4"
				  , FACT.ORGANIZATION_NAME      "PJI_REP_MSR_5"
				  , FACT.PERSON_MANAGER_NAME    "PJI_REP_MSR_6"
				  , FACT.COST                   "PJI_REP_MSR_8"
				  , FACT.BILL_COST              "PJI_REP_MSR_16"
				  , FACT.BILL_COST_PRCNT_OF_COST  "PJI_REP_MSR_17"
				  , FACT.BUDGET                   "PJI_REP_MSR_12"
				  , FACT.BILL_PRCNT_OF_BUDGET_COST  "PJI_REP_MSR_13"
				  , FACT.NON_BILL_COST              "PJI_REP_MSR_14"
				  , FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1"
				  , FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_2"
				  , FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_3"
				  , FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_4"
				  , FACT.PJI_REP_TOTAL_5 "PJI_REP_TOTAL_5"
            	  , FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_6" '
            		, P_SQL_STATEMENT => x_PMV_Sql
	           		, P_PMV_OUTPUT => x_PMV_Output
				, p_Region_Code => 'PJI_REP_PC13'
				, p_PLSQL_Driver => 'PJI_PMV_COST.PLSQLDriver_PJI_REP_PC13'
				, p_PLSQL_Driver_Params => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
				  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
				  ', <<CURRENCY+FII_CURRENCIES>>'||
				  ', <<AS_OF_DATE>>'||
				  ', <<PERIOD_TYPE>>'||
				  ', <<VIEW_BY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
				  ', <<PROJECT CLASSIFICATION+CLASS_CODE>> '||
				  ', <<PROJECT+PJI_PROJECTS>> '||
				  ', <<PROJECT EXPENDITURE TYPE+PJI_EXP_CATEGORIES>> '||
				  ', <<PROJECT EXPENDITURE TYPE+PJI_EXP_TYPES>> '||
				  ', <<PROJECT WORK TYPE+PJI_WORK_TYPES>> '
                        );
END GET_SQL_PJI_REP_PC13;

/*
**  Capital Project Cost Cumulative Trend
*/


PROCEDURE Get_SQL_PJI_REP_PC12(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql    OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
l_PMV_Rec			BIS_QUERY_ATTRIBUTES;
BEGIN
    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
			, P_SELECT_LIST =>
				' FACT.COST                     "PJI_REP_MSR_1"
                , FACT.COST                     "PJI_REP_MSR_19"
                , FACT.CT_COST                  "PJI_REP_MSR_2"
                , FACT.CT_COST                  "PJI_REP_MSR_20"
                , FACT.COST_CHANGE_PRCNT        "PJI_REP_MSR_3"
                , FACT.BILL_COST                "PJI_REP_MSR_4"
                , FACT.BILL_COST                "PJI_REP_MSR_21"
                , FACT.CT_BILL_COST             "PJI_REP_MSR_5"
                , FACT.CT_BILL_COST             "PJI_REP_MSR_22"
                , FACT.BILL_COST_CHANGE_PRCNT   "PJI_REP_MSR_6"
                , FACT.BILL_PRCNT_OF_COST       "PJI_REP_MSR_7"
                , FACT.CT_BILL_PRCNT_OF_COST    "PJI_REP_MSR_8"
                , FACT.PRCNT_OF_COST_CHANGE     "PJI_REP_MSR_9"
                , FACT.BUDGET                   "PJI_REP_MSR_10"
                , FACT.CT_BUDGET                "PJI_REP_MSR_11"
                , FACT.BUDGET_CHANGE_PRCNT      "PJI_REP_MSR_12"
                , FACT.BILL_COST_PRCNT_OF_BUDGET     "PJI_REP_MSR_13"
                , FACT.BILL_COST_PRCNT_OF_BUDGET     "PJI_REP_MSR_23"
                , FACT.CT_BILL_COST_PRCNT_OF_BUDGET  "PJI_REP_MSR_14"
                , FACT.CT_BILL_COST_PRCNT_OF_BUDGET  "PJI_REP_MSR_24"
                , FACT.CHANGE                       "PJI_REP_MSR_15"
                , FACT.NON_BILL_COST                 "PJI_REP_MSR_16"
                , FACT.CT_Non_Bill_Cost             "PJI_REP_MSR_17"
                , FACT.NON_BILL_COST_CHANGE_PRCNT   "PJI_REP_MSR_18"'
            , P_SQL_STATEMENT => x_PMV_Sql
            , P_PMV_OUTPUT => x_PMV_Output
			, P_REGION_CODE => 'PJI_REP_PC12'
			, P_PLSQL_DRIVER => 'PJI_PMV_COST.PLSQLDriver_PJI_REP_PC11'
			, P_PLSQL_DRIVER_PARAMS => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
			  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
			  ', <<CURRENCY+FII_CURRENCIES>>'||
			  ', <<AS_OF_DATE>>'||
			  ', <<PERIOD_TYPE>>'||
			  ', <<VIEW_BY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CODE>>'||
			  ', :PJI_EXTRA_BND_01'||
              ', NULL '||
			  ', NULL '||
			  ', NULL ');

	l_PMV_Rec:=BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
	l_PMV_Rec.attribute_name:=':PJI_EXTRA_BND_01';
	l_PMV_Rec.attribute_value:='FISCAL';
	l_PMV_Rec.attribute_type:=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	l_PMV_Rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

	x_PMV_Output.EXTEND();
	x_PMV_Output(x_PMV_Output.COUNT):=l_PMV_Rec;

END Get_SQL_PJI_REP_PC12;

/* -------------------------------------------------------------+
** -- PLSQL DRIVERS
*/ -------------------------------------------------------------+


FUNCTION  PLSQLDriver_PJI_REP_PC10(
           p_Operating_Unit		        IN VARCHAR2 DEFAULT NULL
         , p_Organization		        IN VARCHAR2
         , p_Currency_Type		        IN VARCHAR2
         , p_As_of_Date                 IN NUMBER
         , p_Time_Comparison_Type       IN VARCHAR2
         , p_Period_Type 		        IN VARCHAR2
         , p_View_BY 			        IN VARCHAR2
         , p_Classifications	        IN VARCHAR2 DEFAULT NULL
         , p_Class_Codes		        IN VARCHAR2 DEFAULT NULL
         , p_Expenditure_Category       IN VARCHAR2 DEFAULT NULL
         , p_Expenditure_Type       IN VARCHAR2 DEFAULT NULL
         , p_Work_Type              IN VARCHAR2 DEFAULT NULL
         )  RETURN PJI_REP_PC10_TBL
	IS
       PRAGMA AUTONOMOUS_TRANSACTION;
/*
**  -- Local Variable Declaration
*/

l_Cost                NUMBER:=0;
l_CT_Cost             NUMBER:=0;
l_Bill_Cost           NUMBER:=0;
l_CT_Bill_Cost        NUMBER:=0;
l_Budget              NUMBER:=0;
l_CT_Budget           NUMBER:=0;
l_Non_Bill_Cost       NUMBER:=0;
l_CT_Non_Bill_Cost    NUMBER:=0;

l_TO_Cost                NUMBER:=0;
l_TO_CT_Cost             NUMBER:=0;
l_TO_Bill_Cost           NUMBER:=0;
l_TO_CT_Bill_Cost        NUMBER:=0;
l_TO_Budget              NUMBER:=0;
l_TO_CT_Budget           NUMBER:=0;
l_TO_Non_Bill_Cost       NUMBER:=0;
l_TO_CT_Non_Bill_Cost    NUMBER:=0;

l_Top_Org_Index			    NUMBER;
l_Top_Organization_Name		VARCHAR2(240);

l_Convert_Classification    VARCHAR2(1);
l_Convert_Expenditure_Type  VARCHAR2(1);
l_Convert_Work_Type         VARCHAR2(1);
l_curr_record_type_id           NUMBER:= 1;

/*
**        -- PL/SQL Declaration
*/
	l_lines_tab		PJI_REP_PC10_TBL := PJI_REP_PC10_TBL();

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
                                        , P_VIEW_BY              => p_View_BY);

	PJI_PMV_ENGINE.Convert_Organization(p_TOP_ORGANIZATION_ID   => p_Organization
                                      , p_VIEW_BY               => p_View_BY
							          , p_Top_Organization_Name => l_Top_Organization_Name);

		PJI_PMV_ENGINE.Convert_Time(P_AS_OF_DATE    => p_As_of_Date
      	                                , P_PERIOD_TYPE  =>  p_Period_Type
            	                        , P_VIEW_BY      =>  p_View_By
                  	                    , P_PARSE_PRIOR  =>  NULL
                        	            , P_REPORT_TYPE  =>  'DBI'
                              	        , P_COMPARATOR   =>  p_Time_Comparison_Type
                                    	, P_PARSE_ITD    =>  NULL
	                                    , P_FULL_PERIOD_FLAG => 'Y'
      	                              );
/*
** -- Conditionally Execute ORG, CLASS, EXPENDITURE_TYPE, WORK_TYPE Processing  --------------------------------+
*/

l_Convert_Classification := PJI_PMV_ENGINE.Convert_Classification
                            (p_Classifications, p_Class_Codes, p_View_BY);

l_Convert_Expenditure_Type := PJI_PMV_ENGINE.Convert_Expenditure_Type
                            (p_Expenditure_Category, p_Expenditure_Type, p_View_BY);

l_Convert_Work_Type := PJI_PMV_ENGINE.Convert_Work_Type
                            (p_Work_Type, p_View_BY);

l_curr_record_type_id:=PJI_PMV_ENGINE.Convert_Currency_Record_Type(p_Currency_Type);

/*
** ORGANIZATION Processing: No parameter other than Organization is specified
*/

IF      l_Convert_Classification = 'N'
  AND   l_Convert_Expenditure_Type = 'N'
  AND   l_Convert_Work_Type = 'N'
THEN
            SELECT PJI_REP_PC10
                      ( ORG_ID
                      , ORGANIZATION_ID
                      , PROJECT_CLASS_ID
                      , EXPENDITURE_CATEGORY
                      , EXPENDITURE_TYPE_ID
                      , WORK_TYPE_ID
                      , SUM ( COST )
                      , SUM ( CT_COST )
                      , NULL
                      , SUM ( BILL_COST  )
                      , SUM ( CT_BILL_COST  )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( BUDGET  )
                      , SUM ( CT_BUDGET )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( NON_BILL_COST )
                      , SUM ( CT_NON_BILL_COST )
                      , NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , '-1'                     as EXPENDITURE_CATEGORY
            , '-1'                     as EXPENDITURE_TYPE_ID
            , '-1'                     as WORK_TYPE_ID
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)          AS COST
            , 0 CT_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)     AS BILL_COST
            , 0 CT_BILL_COST
            , DECODE(TIME.amount_type,2,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CON_CURR_BGT_BRDN_COST,
                                                        'RC', FCT.CON_CURR_BGT_RAW_COST, 0),0) AS BUDGET
            , 0 CT_BUDGET
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS NON_BILL_COST
 	        , 0 CT_NON_BILL_COST
    FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_FP_ORGO_F_MV FCT
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			fct.org_id = hou.id
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , '-1'                     as EXPENDITURE_CATEGORY
            , '-1'                     as EXPENDITURE_TYPE_ID
            , '-1'                     as WORK_TYPE_ID
            , 0  AS COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)   AS CT_COST
            , 0  AS BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)  AS CT_BILL_COST
            , 0  AS BUDGET
            , DECODE(TIME.amount_type,2,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CON_CURR_BGT_BRDN_COST,
                                                        'RC', FCT.CON_CURR_BGT_RAW_COST, 0),0) AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS CT_NON_BILL_COST
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
		UNION ALL -- FORCE Creation of Org rows
SELECT        HOU.NAME          AS ORG_ID
            , '-1'              AS ORGANIZATION_ID
            , '-1'              AS PROJECT_CLASS_ID
            , '-1'              AS EXPENDITURE_CATEGORY
            , '-1'              AS EXPENDITURE_TYPE_ID
            , '-1'              AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORG_DIM_TMP HOU
		WHERE    HOU.NAME <> '-1'
                UNION ALL  -- FORCE Creation of Organization Rows
SELECT        '-1'                AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , '-1'                     as EXPENDITURE_CATEGORY
            , '-1'                     as EXPENDITURE_TYPE_ID
            , '-1'                     as WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
                ) WHERE 1=1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
            EXPENDITURE_TYPE_ID,WORK_TYPE_ID;

ELSIF      l_Convert_Classification = 'Y'
  AND   l_Convert_Expenditure_Type = 'N'
  AND   l_Convert_Work_Type = 'N'
THEN
            SELECT PJI_REP_PC10
                      ( ORG_ID
                      , ORGANIZATION_ID
                      , PROJECT_CLASS_ID
                      , EXPENDITURE_CATEGORY
                      , EXPENDITURE_TYPE_ID
                      , WORK_TYPE_ID
                      , SUM ( COST )
                      , SUM ( CT_COST )
                      , NULL
                      , SUM ( BILL_COST  )
                      , SUM ( CT_BILL_COST  )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( BUDGET  )
                      , SUM ( CT_BUDGET )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( NON_BILL_COST )
                      , SUM ( CT_NON_BILL_COST )
                      , NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , CLS.NAME                 AS PROJECT_CLASS_ID
            , '-1'                     as EXPENDITURE_CATEGORY
            , '-1'                     as EXPENDITURE_TYPE_ID
            , '-1'                     as WORK_TYPE_ID
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0) AS COST
            , 0 CT_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0) AS BILL_COST
            , 0 CT_BILL_COST
            , DECODE(TIME.amount_type,2,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CON_CURR_BGT_BRDN_COST,
                                                        'RC', FCT.CON_CURR_BGT_RAW_COST, 0),0) AS BUDGET
            , 0 CT_BUDGET
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS NON_BILL_COST
 	        , 0 CT_NON_BILL_COST
    FROM
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
			, PJI_FP_CLSO_F_MV FCT
            , PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			        FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                AND FCT.PROJECT_CLASS_ID = CLS.ID
		UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , CLS.NAME                 AS PROJECT_CLASS_ID
            , '-1'                     AS EXPENDITURE_CATEGORY
            , '-1'                     AS EXPENDITURE_TYPE_ID
            , '-1'                     AS WORK_TYPE_ID
            , 0  AS COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)   AS CT_COST
            , 0  AS BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)  AS CT_BILL_COST
            , 0  AS BUDGET
            , DECODE(TIME.amount_type,2,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CON_CURR_BGT_BRDN_COST,
                                                        'RC', FCT.CON_CURR_BGT_RAW_COST, 0),0) AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS CT_NON_BILL_COST
		FROM
				PJI_PMV_TCMP_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_CLS_DIM_TMP CLS
                , PJI_FP_CLSO_F_MV FCT
				, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			        FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
              	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		        AND FCT.PROJECT_CLASS_ID = CLS.ID
        UNION ALL -- FORCE Creation of Org rows
SELECT        HOU.NAME          AS ORG_ID
            , '-1'              AS ORGANIZATION_ID
            , '-1'              AS PROJECT_CLASS_ID
            , '-1'              AS EXPENDITURE_CATEGORY
            , '-1'              AS EXPENDITURE_TYPE_ID
            , '-1'              AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORG_DIM_TMP HOU
		WHERE    HOU.NAME <> '-1'
                UNION ALL  -- FORCE Creation of Organization Rows
SELECT        '-1'                AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , '-1'                     as EXPENDITURE_CATEGORY
            , '-1'                     as EXPENDITURE_TYPE_ID
            , '-1'                     as WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
        UNION ALL
SELECT        '-1'                AS ORG_ID
            , '-1'                AS ORGANIZATION_ID
            , CLS.NAME            AS PROJECT_CLASS_ID
            , '-1'                AS EXPENDITURE_CATEGORY
            , '-1'                AS EXPENDITURE_TYPE_ID
            , '-1'                AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_CLS_DIM_TMP CLS
		WHERE    CLS.NAME <> '-1'
                ) WHERE 1=1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
            EXPENDITURE_TYPE_ID,WORK_TYPE_ID;

/*
** ORGANIZATION AND EXPENDITURE CATEGORY/TYPE Processing:
** Only Organization and Expenditure Category/Type is specified
*/

ELSIF   l_Convert_Classification = 'N'
  AND   l_Convert_Expenditure_Type = 'Y'
  AND   l_Convert_Work_Type = 'N'
THEN
            SELECT PJI_REP_PC10
                      ( ORG_ID
                      , ORGANIZATION_ID
                      , PROJECT_CLASS_ID
                      , EXPENDITURE_CATEGORY
                      , EXPENDITURE_TYPE_ID
                      , WORK_TYPE_ID
                      , SUM ( COST )
                      , SUM ( CT_COST )
                      , NULL
                      , SUM ( BILL_COST  )
                      , SUM ( CT_BILL_COST  )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( BUDGET  )
                      , SUM ( CT_BUDGET )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( NON_BILL_COST )
                      , SUM ( CT_NON_BILL_COST )
                      , NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , '-1'                     as WORK_TYPE_ID
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)          AS COST
            , 0 CT_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)     AS BILL_COST
            , 0 CT_BILL_COST
            , NULL AS BUDGET
            , NULL AS CT_BUDGET
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS NON_BILL_COST
 	        , 0 CT_NON_BILL_COST
    FROM
    		PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_ORGO_ET_F_MV FCT
			, PJI_PMV_ORG_DIM_TMP HOU
	WHERE
			FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
	            AND EXP_EVT_TYPE_ID= ET.ID
                and ET.record_type = 'ET'
    	UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , '-1'                     AS WORK_TYPE_ID
            , 0  AS COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)   AS CT_COST
            , 0  AS BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)  AS CT_BILL_COST
            , NULL AS BUDGET
            , NULL AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS CT_NON_BILL_COST
		FROM
			PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_ORGO_ET_F_MV FCT
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			        FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
              	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		        AND FCT.EXP_EVT_TYPE_ID = ET.ID
                and ET.record_type = 'ET'
        UNION ALL -- FORCE Creation of Org rows
SELECT        HOU.NAME          AS ORG_ID
            , '-1'              AS ORGANIZATION_ID
            , '-1'              AS PROJECT_CLASS_ID
            , '-1'              AS EXPENDITURE_CATEGORY
            , '-1'              AS EXPENDITURE_TYPE_ID
            , '-1'              AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORG_DIM_TMP HOU
		WHERE    HOU.NAME <> '-1'
                UNION ALL  -- FORCE Creation of Organization Rows
SELECT        '-1'                AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , '-1'                     as EXPENDITURE_CATEGORY
            , '-1'                     as EXPENDITURE_TYPE_ID
            , '-1'                     as WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
        UNION ALL
SELECT        '-1'                AS ORG_ID
            , '-1'                AS ORGANIZATION_ID
            , '-1'                AS PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , '-1'                AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ET_RT_DIM_TMP ET
		WHERE    ET.NAME <> '-1'
                ) WHERE 1=1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
            EXPENDITURE_TYPE_ID,WORK_TYPE_ID;

/*
** ORGANIZATION AND WORK TYPE Processing:
** Only Organization and Work Type is specified
*/

ELSIF      l_Convert_Classification = 'N'
  AND   l_Convert_Expenditure_Type = 'N'
  AND   l_Convert_Work_Type = 'Y'
THEN
            SELECT PJI_REP_PC10
                      ( ORG_ID
                      , ORGANIZATION_ID
                      , PROJECT_CLASS_ID
                      , EXPENDITURE_CATEGORY
                      , EXPENDITURE_TYPE_ID
                      , WORK_TYPE_ID
                      , SUM ( COST )
                      , SUM ( CT_COST )
                      , NULL
                      , SUM ( BILL_COST  )
                      , SUM ( CT_BILL_COST  )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( BUDGET  )
                      , SUM ( CT_BUDGET )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( NON_BILL_COST )
                      , SUM ( CT_NON_BILL_COST )
                      , NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , '-1'                     AS EXPENDITURE_CATEGORY
            , '-1'                     AS EXPENDITURE_TYPE_ID
            , WT.NAME                  AS WORK_TYPE_ID
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)          AS COST
            , 0 CT_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)     AS BILL_COST
            , 0 CT_BILL_COST
            , NULL AS BUDGET
            , NULL AS CT_BUDGET
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS NON_BILL_COST
 	        , 0 CT_NON_BILL_COST
    FROM
    		PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_WT_DIM_TMP WT
            , PJI_FP_ORGO_ET_WT_F_MV FCT
			, PJI_PMV_ORG_DIM_TMP HOU
	WHERE
			FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
	            AND WORK_TYPE_ID= WT.ID
    	UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , '-1'                     AS EXPENDITURE_CATEGORY
            , '-1'                     AS EXPENDITURE_TYPE_ID
            , WT.NAME                  AS WORK_TYPE_ID
            , 0  AS COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)   AS CT_COST
            , 0  AS BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)  AS CT_BILL_COST
            , NULL AS BUDGET
            , NULL AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS CT_NON_BILL_COST
		FROM
			PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_WT_DIM_TMP WT
            , PJI_FP_ORGO_ET_WT_F_MV FCT
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			        FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
              	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		        AND FCT.WORK_TYPE_ID = WT.ID
        UNION ALL -- FORCE Creation of Org rows
SELECT        HOU.NAME          AS ORG_ID
            , '-1'              AS ORGANIZATION_ID
            , '-1'              AS PROJECT_CLASS_ID
            , '-1'              AS EXPENDITURE_CATEGORY
            , '-1'              AS EXPENDITURE_TYPE_ID
            , '-1'              AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORG_DIM_TMP HOU
		WHERE    HOU.NAME <> '-1'
                UNION ALL  -- FORCE Creation of Organization Rows
SELECT        '-1'                AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , '-1'                     as EXPENDITURE_CATEGORY
            , '-1'                     as EXPENDITURE_TYPE_ID
            , '-1'                     as WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
        UNION ALL
SELECT        '-1'                AS ORG_ID
            , '-1'                AS ORGANIZATION_ID
            , '-1'                AS PROJECT_CLASS_ID
            , '-1'                AS EXPENDITURE_CATEGORY
            , '-1'                AS EXPENDITURE_TYPE_ID
            , WT.NAME             AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_WT_DIM_TMP WT
		WHERE    WT.NAME <> '-1'
                ) WHERE 1=1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
            EXPENDITURE_TYPE_ID,WORK_TYPE_ID;


/*
** ORGANIZATION, CLASSIFICATION AND EXPENDITURE CATEGORY/TYPE Processing:
** Only Organization, Classification and Expenditure Category/Type is specified
*/

ELSIF      l_Convert_Classification = 'Y'
    AND    l_Convert_Expenditure_Type = 'Y'
    AND    l_Convert_Work_Type = 'N'
THEN
            SELECT PJI_REP_PC10
                      ( ORG_ID
                      , ORGANIZATION_ID
                      , PROJECT_CLASS_ID
                      , EXPENDITURE_CATEGORY
                      , EXPENDITURE_TYPE_ID
                      , WORK_TYPE_ID
                      , SUM ( COST )
                      , SUM ( CT_COST )
                      , NULL
                      , SUM ( BILL_COST  )
                      , SUM ( CT_BILL_COST  )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( BUDGET  )
                      , SUM ( CT_BUDGET )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( NON_BILL_COST )
                      , SUM ( CT_NON_BILL_COST )
                      , NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , CLS.NAME                 AS PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , '-1'                     AS WORK_TYPE_ID
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)          AS COST
            , 0 CT_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)     AS BILL_COST
            , 0 CT_BILL_COST
            , NULL AS BUDGET
            , NULL AS CT_BUDGET
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS NON_BILL_COST
 	        , 0 CT_NON_BILL_COST
    FROM
    		  PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_CLSO_ET_F_MV FCT
            , PJI_PMV_CLS_DIM_TMP CLS
			, PJI_PMV_ORG_DIM_TMP HOU
	WHERE
			FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
	            AND PROJECT_CLASS_ID= CLS.ID
        and FCT.EXP_EVT_TYPE_ID = ET.ID
        and ET.record_type = 'ET'
        UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , CLS.NAME                 AS PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , '-1'                     AS WORK_TYPE_ID
            , 0  AS COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)   AS CT_COST
            , 0  AS BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)  AS CT_BILL_COST
            , NULL AS BUDGET
            , NULL AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS CT_NON_BILL_COST
		FROM
			PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_CLSO_ET_F_MV FCT
			, PJI_PMV_CLS_DIM_TMP CLS
            , PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			        FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
              	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
	            AND PROJECT_CLASS_ID = CLS.ID
        and FCT.EXP_EVT_TYPE_ID = ET.ID
        and ET.record_type = 'ET'
        UNION ALL -- FORCE Creation of Org rows
SELECT        HOU.NAME          AS ORG_ID
            , '-1'              AS ORGANIZATION_ID
            , '-1'              AS PROJECT_CLASS_ID
            , '-1'              AS EXPENDITURE_CATEGORY
            , '-1'              AS EXPENDITURE_TYPE_ID
            , '-1'              AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORG_DIM_TMP HOU
		WHERE    HOU.NAME <> '-1'
                UNION ALL  -- FORCE Creation of Organization Rows
SELECT        '-1'                AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , '-1'                     as EXPENDITURE_CATEGORY
            , '-1'                     as EXPENDITURE_TYPE_ID
            , '-1'                     as WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
UNION ALL
SELECT        '-1'             AS ORG_ID
            , '-1'             AS ORGANIZATION_ID
            , CLS.NAME         AS PROJECT_CLASS_ID
            , '-1'             AS EXPENDITURE_CATEGORY
            , '-1'             AS EXPENDITURE_TYPE_ID
            , '-1'             AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_CLS_DIM_TMP CLS
		WHERE    CLS.NAME <> '-1'
UNION ALL
SELECT        '-1'             AS ORG_ID
            , '-1'             AS ORGANIZATION_ID
            , '-1'             AS PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , '-1'             AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ET_RT_DIM_TMP ET
		WHERE    ET.NAME <> '-1'
                ) WHERE 1=1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
            EXPENDITURE_TYPE_ID,WORK_TYPE_ID;



ELSIF   l_Convert_Classification = 'N'
  AND   l_Convert_Expenditure_Type = 'Y'
  AND   l_Convert_Work_Type = 'Y'
THEN
            SELECT PJI_REP_PC10
                      ( ORG_ID
                      , ORGANIZATION_ID
                      , PROJECT_CLASS_ID
                      , EXPENDITURE_CATEGORY
                      , EXPENDITURE_TYPE_ID
                      , WORK_TYPE_ID
                      , SUM ( COST )
                      , SUM ( CT_COST )
                      , NULL
                      , SUM ( BILL_COST  )
                      , SUM ( CT_BILL_COST  )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( BUDGET  )
                      , SUM ( CT_BUDGET )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( NON_BILL_COST )
                      , SUM ( CT_NON_BILL_COST )
                      , NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , WT.NAME                  AS WORK_TYPE_ID
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)          AS COST
            , 0 CT_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)     AS BILL_COST
            , 0 CT_BILL_COST
            , NULL AS BUDGET
            , NULL AS CT_BUDGET
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS NON_BILL_COST
 	        , 0 CT_NON_BILL_COST
    FROM
    		  PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_ORGO_ET_WT_F_MV FCT
            , PJI_PMV_WT_DIM_TMP WT
			, PJI_PMV_ORG_DIM_TMP HOU
	WHERE
			FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
	            AND WORK_TYPE_ID= WT.ID
        and FCT.EXP_EVT_TYPE_ID = ET.ID
        and ET.record_type = 'ET'
        UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , WT.NAME                  AS WORK_TYPE_ID
            , 0  AS COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)   AS CT_COST
            , 0  AS BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)  AS CT_BILL_COST
            , NULL AS BUDGET
            , NULL AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS CT_NON_BILL_COST
		FROM
    		  PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_ORGO_ET_WT_F_MV FCT
            , PJI_PMV_WT_DIM_TMP WT
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			        FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
              	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
	            AND WORK_TYPE_ID = WT.ID
        and FCT.EXP_EVT_TYPE_ID = ET.ID
        and ET.record_type = 'ET'
        UNION ALL -- FORCE Creation of Org rows
SELECT        HOU.NAME          AS ORG_ID
            , '-1'              AS ORGANIZATION_ID
            , '-1'              AS PROJECT_CLASS_ID
            , '-1'              AS EXPENDITURE_CATEGORY
            , '-1'              AS EXPENDITURE_TYPE_ID
            , '-1'              AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORG_DIM_TMP HOU
		WHERE    HOU.NAME <> '-1'
                UNION ALL  -- FORCE Creation of Organization Rows
SELECT        '-1'                AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , '-1'                     as EXPENDITURE_CATEGORY
            , '-1'                     as EXPENDITURE_TYPE_ID
            , '-1'                     as WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
UNION ALL
SELECT        '-1'        AS ORG_ID
            , '-1'        AS ORGANIZATION_ID
            , '-1'        AS PROJECT_CLASS_ID
            , '-1'        AS EXPENDITURE_CATEGORY
            , '-1'        AS EXPENDITURE_TYPE_ID
            , WT.NAME     AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_WT_DIM_TMP WT
		WHERE    WT.NAME <> '-1'
UNION ALL
SELECT        '-1'             AS ORG_ID
            , '-1'             AS ORGANIZATION_ID
            , '-1'             AS PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , '-1'             AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ET_RT_DIM_TMP ET
		WHERE    ET.NAME <> '-1'
                ) WHERE 1=1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
            EXPENDITURE_TYPE_ID,WORK_TYPE_ID;

ELSIF   l_Convert_Classification = 'Y'
  AND   l_Convert_Expenditure_Type = 'N'
  AND   l_Convert_Work_Type = 'Y'
THEN
            SELECT PJI_REP_PC10
                      ( ORG_ID
                      , ORGANIZATION_ID
                      , PROJECT_CLASS_ID
                      , EXPENDITURE_CATEGORY
                      , EXPENDITURE_TYPE_ID
                      , WORK_TYPE_ID
                      , SUM ( COST )
                      , SUM ( CT_COST )
                      , NULL
                      , SUM ( BILL_COST  )
                      , SUM ( CT_BILL_COST  )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( BUDGET  )
                      , SUM ( CT_BUDGET )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( NON_BILL_COST )
                      , SUM ( CT_NON_BILL_COST )
                      , NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , CLS.NAME                 AS PROJECT_CLASS_ID
            , '-1'             AS EXPENDITURE_CATEGORY
            , '-1'             AS EXPENDITURE_TYPE_ID
            , WT.NAME                  AS WORK_TYPE_ID
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)          AS COST
            , 0 CT_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)     AS BILL_COST
            , 0 CT_BILL_COST
            , NULL AS BUDGET
            , NULL AS CT_BUDGET
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS NON_BILL_COST
 	        , 0 CT_NON_BILL_COST
    FROM
    		  PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
            , PJI_FP_CLSO_ET_WT_F_MV FCT
            , PJI_PMV_WT_DIM_TMP WT
			, PJI_PMV_ORG_DIM_TMP HOU
	WHERE
			FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
	            AND WORK_TYPE_ID= WT.ID
        and FCT.PROJECT_CLASS_ID = CLS.ID
        UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , CLS.NAME                 AS PROJECT_CLASS_ID
            , '-1'             AS EXPENDITURE_CATEGORY
            , '-1'             AS EXPENDITURE_TYPE_ID
            , WT.NAME                     AS WORK_TYPE_ID
            , 0  AS COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)   AS CT_COST
            , 0  AS BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)  AS CT_BILL_COST
            , NULL AS BUDGET
            , NULL AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS CT_NON_BILL_COST
		FROM
    		  PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
            , PJI_FP_CLSO_ET_WT_F_MV FCT
            , PJI_PMV_WT_DIM_TMP WT
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			        FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
              	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
	            AND WORK_TYPE_ID = WT.ID
        and FCT.PROJECT_CLASS_ID = CLS.ID
        UNION ALL -- FORCE Creation of Org rows
SELECT        HOU.NAME          AS ORG_ID
            , '-1'              AS ORGANIZATION_ID
            , '-1'              AS PROJECT_CLASS_ID
            , '-1'              AS EXPENDITURE_CATEGORY
            , '-1'              AS EXPENDITURE_TYPE_ID
            , '-1'              AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORG_DIM_TMP HOU
		WHERE    HOU.NAME <> '-1'
                UNION ALL  -- FORCE Creation of Organization Rows
SELECT        '-1'                AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , '-1'                     as EXPENDITURE_CATEGORY
            , '-1'                     as EXPENDITURE_TYPE_ID
            , '-1'                     as WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
UNION ALL
SELECT        '-1'        AS ORG_ID
            , '-1'        AS ORGANIZATION_ID
            , '-1'        AS PROJECT_CLASS_ID
            , '-1'        AS EXPENDITURE_CATEGORY
            , '-1'        AS EXPENDITURE_TYPE_ID
            , WT.NAME     AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_WT_DIM_TMP WT
		WHERE    WT.NAME <> '-1'
UNION ALL
SELECT        '-1'             AS ORG_ID
            , '-1'             AS ORGANIZATION_ID
            , CLS.NAME             AS PROJECT_CLASS_ID
            , '-1'             AS EXPENDITURE_CATEGORY
            , '-1'             AS EXPENDITURE_TYPE_ID
            , '-1'             AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_CLS_DIM_TMP CLS
		WHERE    CLS.NAME <> '-1'
                ) WHERE 1=1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
            EXPENDITURE_TYPE_ID,WORK_TYPE_ID;
ELSE

            SELECT PJI_REP_PC10
                      ( ORG_ID
                      , ORGANIZATION_ID
                      , PROJECT_CLASS_ID
                      , EXPENDITURE_CATEGORY
                      , EXPENDITURE_TYPE_ID
                      , WORK_TYPE_ID
                      , SUM ( COST )
                      , SUM ( CT_COST )
                      , NULL
                      , SUM ( BILL_COST  )
                      , SUM ( CT_BILL_COST  )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( BUDGET  )
                      , SUM ( CT_BUDGET )
                      , NULL
                      , NULL
                      , NULL
                      , NULL
                      , SUM ( NON_BILL_COST )
                      , SUM ( CT_NON_BILL_COST )
                      , NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL
                      , NULL , NULL , NULL , NULL , NULL, NULL )
           BULK COLLECT INTO l_lines_tab
           FROM
	      ( SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , CLS.NAME                 AS PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , WT.NAME                  AS WORK_TYPE_ID
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)          AS COST
            , 0 CT_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)     AS BILL_COST
            , 0 CT_BILL_COST
            , NULL AS BUDGET
            , NULL AS CT_BUDGET
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS NON_BILL_COST
 	        , 0 CT_NON_BILL_COST
    FROM
    		  PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_CLSO_ET_WT_F_MV FCT
            , PJI_PMV_CLS_DIM_TMP CLS
            , PJI_PMV_WT_DIM_TMP WT
			, PJI_PMV_ORG_DIM_TMP HOU
	WHERE
			FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
	            AND WORK_TYPE_ID= WT.ID
        and FCT.PROJECT_CLASS_ID = CLS.ID
        and FCT.EXP_EVT_TYPE_ID = ET.ID
        and ET.record_type = 'ET'
        UNION ALL -- PRIOR Actuals
                SELECT /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , CLS.NAME                 AS PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , WT.NAME                     AS WORK_TYPE_ID
            , 0  AS COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST, 0),0)   AS CT_COST
            , 0  AS BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.BILL_RAW_COST, 0),0)  AS CT_BILL_COST
            , NULL AS BUDGET
            , NULL AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', FCT.CONTRACT_BRDN_COST - FCT.BILL_BURDENED_COST,
                                                        'RC', FCT.CONTRACT_RAW_COST - FCT.BILL_RAW_COST,0), 0) AS CT_NON_BILL_COST
		FROM
    		  PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_CLSO_ET_WT_F_MV FCT
            , PJI_PMV_CLS_DIM_TMP CLS
            , PJI_PMV_WT_DIM_TMP WT
			, PJI_PMV_ORG_DIM_TMP HOU
		WHERE
			        FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
              	AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
	            AND WORK_TYPE_ID = WT.ID
        and FCT.PROJECT_CLASS_ID = CLS.ID
        and FCT.EXP_EVT_TYPE_ID = ET.ID
        and ET.record_type = 'ET'
        UNION ALL -- FORCE Creation of Org rows
SELECT        HOU.NAME          AS ORG_ID
            , '-1'              AS ORGANIZATION_ID
            , '-1'              AS PROJECT_CLASS_ID
            , '-1'              AS EXPENDITURE_CATEGORY
            , '-1'              AS EXPENDITURE_TYPE_ID
            , '-1'              AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORG_DIM_TMP HOU
		WHERE    HOU.NAME <> '-1'
                UNION ALL  -- FORCE Creation of Organization Rows
SELECT        '-1'                AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , '-1'                     as EXPENDITURE_CATEGORY
            , '-1'                     as EXPENDITURE_TYPE_ID
            , '-1'                     as WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ORGZ_DIM_TMP HORG
		WHERE    HORG.NAME <> '-1'
UNION ALL
SELECT        '-1'        AS ORG_ID
            , '-1'        AS ORGANIZATION_ID
            , '-1'        AS PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , '-1'        AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_ET_RT_DIM_TMP ET
		WHERE    ET.NAME <> '-1'
UNION ALL
SELECT        '-1'        AS ORG_ID
            , '-1'        AS ORGANIZATION_ID
            , '-1'        AS PROJECT_CLASS_ID
            , '-1'        AS EXPENDITURE_CATEGORY
            , '-1'        AS EXPENDITURE_TYPE_ID
            , WT.NAME     AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_WT_DIM_TMP WT
		WHERE    WT.NAME <> '-1'

UNION ALL
SELECT        '-1'             AS ORG_ID
            , '-1'             AS ORGANIZATION_ID
            , CLS.NAME             AS PROJECT_CLASS_ID
            , '-1'             AS EXPENDITURE_CATEGORY
            , '-1'             AS EXPENDITURE_TYPE_ID
            , '-1'             AS WORK_TYPE_ID
            , 0  AS COST
            , 0  AS CT_COST
            , 0  AS BILL_COST
            , 0  AS CT_BILL_COST
            , 0  AS BUDGET
            , 0  AS CT_BUDGET
            , 0  AS NON_BILL_COST
            , 0  AS CT_NON_BILL_COST
		FROM	 PJI_PMV_CLS_DIM_TMP CLS
		WHERE    CLS.NAME <> '-1'
                ) WHERE 1=1
            GROUP BY ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
            EXPENDITURE_TYPE_ID,WORK_TYPE_ID;

 END IF;

FOR i in 1..l_lines_tab.COUNT
LOOP
	IF p_View_By = 'OG' THEN
				IF l_lines_tab(i).ORGANIZATION_ID = l_Top_Organization_Name THEN
					l_Top_Org_Index:=i;

l_TO_Cost               := NVL(l_lines_tab(i).COST,0);
l_TO_CT_Cost            := NVL(l_lines_tab(i).CT_COST,0);
l_TO_Bill_Cost          := NVL(l_lines_tab(i).BILL_COST,0);
l_TO_CT_Bill_Cost       := NVL(l_lines_tab(i).CT_BILL_COST,0);
l_TO_Budget             := NVL(l_lines_tab(i).BUDGET,0);
l_TO_CT_Budget          := NVL(l_lines_tab(i).CT_BUDGET,0);
l_TO_Non_Bill_Cost      := NVL(l_lines_tab(i).NON_BILL_COST,0);
l_TO_CT_Non_Bill_Cost   := NVL(l_lines_tab(i).CT_NON_BILL_COST,0);

	ELSE

	    l_Cost:=l_Cost + NVL(l_lines_tab(i).COST,0);
	    l_CT_Cost:=l_CT_Cost + NVL(l_lines_tab(i).CT_COST,0);

		l_Bill_Cost		:=l_Bill_Cost + NVL(l_lines_tab(i).BILL_COST,0);
		l_CT_Bill_Cost	:=l_CT_Bill_Cost + NVL(l_lines_tab(i).CT_BILL_COST,0);

		l_Budget		:=l_Budget + NVL(l_lines_tab(i).BUDGET,0);
		l_CT_Budget 	:=l_CT_Budget + NVL(l_lines_tab(i).CT_BUDGET,0);

 	  	l_Non_Bill_Cost		:=l_Non_Bill_Cost + NVL(l_lines_tab(i).NON_BILL_COST,0);
		l_CT_Non_Bill_Cost	:=l_CT_Non_Bill_Cost + NVL(l_lines_tab(i).CT_NON_BILL_COST,0);


END IF;
ELSE
		l_Cost		:=l_Cost + NVL(l_lines_tab(i).COST,0);
        l_CT_Cost	:=l_CT_Cost + NVL(l_lines_tab(i).CT_COST,0);
		l_Bill_Cost		:=l_Bill_Cost + NVL(l_lines_tab(i).BILL_COST,0);
        l_CT_Bill_Cost	:=l_CT_Bill_Cost + NVL(l_lines_tab(i).CT_BILL_COST,0);
	    l_Budget        :=l_Budget + NVL(l_lines_tab(i).BUDGET,0);
		l_CT_Budget	    :=l_CT_Budget + NVL(l_lines_tab(i).CT_BUDGET,0);
 	  	l_Non_Bill_Cost	    :=l_Non_Bill_Cost + NVL(l_lines_tab(i).NON_BILL_COST,0);
 	  	l_CT_Non_Bill_Cost	:=l_CT_Non_Bill_Cost + NVL(l_lines_tab(i).CT_NON_BILL_COST,0);

END IF;

		IF NVL(l_lines_tab(i).CT_COST, 0) <> 0 THEN
			l_lines_tab(i).COST_CHANGE_PRCNT := 100 * (l_lines_tab(i).COST -
			l_lines_tab(i).CT_COST) / ABS( l_lines_tab(i).CT_COST);
		ELSE
			l_lines_tab(i).COST_CHANGE_PRCNT := NULL;
		END IF;

		IF NVL(l_lines_tab(i).CT_BILL_COST, 0) <> 0 THEN
			l_lines_tab(i).BILL_COST_CHANGE_PRCNT := 100 * (l_lines_tab(i).BILL_COST -
			l_lines_tab(i).CT_BILL_COST) / ABS( l_lines_tab(i).CT_BILL_COST);
		ELSE
			l_lines_tab(i).BILL_COST_CHANGE_PRCNT := NULL;
		END IF;

		IF NVL(l_lines_tab(i).COST, 0) <> 0 THEN
			l_lines_tab(i).BILL_PRCNT_OF_COST := 100 * (l_lines_tab(i).BILL_COST)  /
            ABS( l_lines_tab(i).COST);
		ELSE
			l_lines_tab(i).BILL_PRCNT_OF_COST := NULL;
		END IF;

		IF NVL(l_lines_tab(i).CT_COST, 0) <> 0 THEN
			l_lines_tab(i).CT_BILL_PRCNT_OF_COST := 100 * (l_lines_tab(i).CT_BILL_COST)  /
            ABS( l_lines_tab(i).CT_COST);
		ELSE
			l_lines_tab(i).CT_BILL_PRCNT_OF_COST := NULL;
		END IF;


        l_lines_tab(i).PRCNT_OF_COST_CHANGE := l_lines_tab(i).BILL_PRCNT_OF_COST -
			l_lines_tab(i).CT_BILL_PRCNT_OF_COST ;


		IF NVL(l_lines_tab(i).CT_BUDGET, 0) <> 0 THEN
			l_lines_tab(i).BUDGET_CHANGE_PRCNT := 100 * (l_lines_tab(i).BUDGET -
			l_lines_tab(i).CT_BUDGET) / ABS( l_lines_tab(i).CT_BUDGET);
		ELSE
			l_lines_tab(i).BUDGET_CHANGE_PRCNT := NULL;
		END IF;

		IF NVL(l_lines_tab(i).BUDGET, 0) <> 0 THEN
			l_lines_tab(i).BILL_COST_PRCNT_OF_BUDGET := 100 *
			(l_lines_tab(i).BILL_COST) / ABS( l_lines_tab(i).BUDGET);
		ELSE
			l_lines_tab(i).BILL_COST_PRCNT_OF_BUDGET := NULL;
		END IF;

		IF NVL(l_lines_tab(i).CT_BUDGET, 0) <> 0 THEN
			l_lines_tab(i).CT_BILL_COST_PRCNT_OF_BUDGET := 100 *
			(l_lines_tab(i).CT_BILL_COST) / ABS( l_lines_tab(i).CT_BUDGET);
		ELSE
			l_lines_tab(i).CT_BILL_COST_PRCNT_OF_BUDGET := NULL;
		END IF;

			l_lines_tab(i).CHANGE :=
			l_lines_tab(i).BILL_COST_PRCNT_OF_BUDGET - l_lines_tab(i).CT_BILL_COST_PRCNT_OF_BUDGET;


		IF NVL(l_lines_tab(i).CT_NON_BILL_COST, 0) <> 0 THEN
			l_lines_tab(i).NON_BILL_COST_CHANGE_PRCNT  := 100 * (l_lines_tab(i).NON_BILL_COST -
			l_lines_tab(i).CT_NON_BILL_COST) / ABS( l_lines_tab(i).CT_NON_BILL_COST);
		ELSE
			l_lines_tab(i).NON_BILL_COST_CHANGE_PRCNT := NULL;
		END IF;
END LOOP;


IF p_View_By = 'OG' THEN

  	l_lines_tab(l_Top_Org_Index).COST
       		:=NVL(l_lines_tab(l_Top_Org_Index).COST,0)-l_Cost;
  	l_lines_tab(l_Top_Org_Index).CT_COST
       		:=NVL(l_lines_tab(l_Top_Org_Index).CT_COST,0)-l_CT_Cost;

  	l_lines_tab(l_Top_Org_Index).BILL_COST
       		:=NVL(l_lines_tab(l_Top_Org_Index).BILL_COST,0)-l_Bill_Cost;
  	l_lines_tab(l_Top_Org_Index).CT_BILL_COST
       		:=NVL(l_lines_tab(l_Top_Org_Index).CT_BILL_COST,0)-l_CT_Bill_Cost;

  	l_lines_tab(l_Top_Org_Index).BUDGET
       		:=NVL(l_lines_tab(l_Top_Org_Index).BUDGET,0)-l_Budget;
  	l_lines_tab(l_Top_Org_Index).CT_BUDGET
       		:=NVL(l_lines_tab(l_Top_Org_Index).CT_BUDGET,0)-l_CT_Budget;

	l_lines_tab(l_Top_Org_Index).NON_BILL_COST
	        :=NVL(l_lines_tab(l_Top_Org_Index).NON_BILL_COST,0)-l_Non_Bill_Cost;
	l_lines_tab(l_Top_Org_Index).CT_NON_BILL_COST
	        :=NVL(l_lines_tab(l_Top_Org_Index).CT_NON_BILL_COST,0)-l_CT_Non_Bill_Cost;


-- 1, 4 *************************************************************************************--
 		IF NVL(l_lines_tab(l_Top_Org_Index).CT_COST, 0) <> 0 THEN
			l_lines_tab(l_Top_Org_Index).COST_CHANGE_PRCNT := 100 * (l_lines_tab(l_Top_Org_Index).COST -
			l_lines_tab(l_Top_Org_Index).CT_COST) / ABS( l_lines_tab(l_Top_Org_Index).CT_COST);

			l_lines_tab(l_Top_Org_Index).CT_BILL_PRCNT_OF_COST := 100 * (l_lines_tab(l_Top_Org_Index).CT_BILL_COST)  /
            ABS( l_lines_tab(l_Top_Org_Index).CT_COST);

		ELSE
			l_lines_tab(l_Top_Org_Index).COST_CHANGE_PRCNT := NULL;
			l_lines_tab(l_Top_Org_Index).CT_BILL_PRCNT_OF_COST := NULL;

		END IF;
-- 2 ************************************************************************************--
		IF NVL(l_lines_tab(l_Top_Org_Index).CT_BILL_COST, 0) <> 0 THEN
			l_lines_tab(l_Top_Org_Index).BILL_COST_CHANGE_PRCNT := 100 * (l_lines_tab(l_Top_Org_Index).BILL_COST -
			l_lines_tab(l_Top_Org_Index).CT_BILL_COST) / ABS( l_lines_tab(l_Top_Org_Index).CT_BILL_COST);
		ELSE
			l_lines_tab(l_Top_Org_Index).BILL_COST_CHANGE_PRCNT := NULL;
		END IF;
-- 3 *************************************************************************************--
		IF NVL(l_lines_tab(l_Top_Org_Index).COST, 0) <> 0 THEN
			l_lines_tab(l_Top_Org_Index).BILL_PRCNT_OF_COST := 100 * (l_lines_tab(l_Top_Org_Index).BILL_COST)  /
            ABS( l_lines_tab(l_Top_Org_Index).COST);
		ELSE
			l_lines_tab(l_Top_Org_Index).BILL_PRCNT_OF_COST := NULL;
		END IF;
-- 5 *************************************************************************************--

        l_lines_tab(l_Top_Org_Index).PRCNT_OF_COST_CHANGE := l_lines_tab(l_Top_Org_Index).BILL_PRCNT_OF_COST -
			l_lines_tab(l_Top_Org_Index).CT_BILL_PRCNT_OF_COST ;

-- 6, 8 *************************************************************************************--
		IF NVL(l_lines_tab(l_Top_Org_Index).CT_BUDGET, 0) <> 0 THEN
			l_lines_tab(l_Top_Org_Index).BUDGET_CHANGE_PRCNT := 100 * (l_lines_tab(l_Top_Org_Index).BUDGET -
			l_lines_tab(l_Top_Org_Index).CT_BUDGET) / ABS( l_lines_tab(l_Top_Org_Index).CT_BUDGET);

			l_lines_tab(l_Top_Org_Index).CT_BILL_COST_PRCNT_OF_BUDGET := 100 *
			(l_lines_tab(l_Top_Org_Index).CT_BILL_COST) / ABS( l_lines_tab(l_Top_Org_Index).CT_BUDGET);

		ELSE
			l_lines_tab(l_Top_Org_Index).BUDGET_CHANGE_PRCNT := NULL;
			l_lines_tab(l_Top_Org_Index).BILL_COST_PRCNT_OF_BUDGET := NULL;

		END IF;
-- 7 *************************************************************************************--
		IF NVL(l_lines_tab(l_Top_Org_Index).BUDGET, 0) <> 0 THEN
			l_lines_tab(l_Top_Org_Index).BILL_COST_PRCNT_OF_BUDGET := 100 *
			(l_lines_tab(l_Top_Org_Index).BILL_COST) / ABS( l_lines_tab(l_Top_Org_Index).BUDGET);
		ELSE
			l_lines_tab(l_Top_Org_Index).BILL_COST_PRCNT_OF_BUDGET := NULL;
		END IF;
-- 9 *************************************************************************************--
			l_lines_tab(l_Top_Org_Index).CHANGE :=
			l_lines_tab(l_Top_Org_Index).BILL_COST_PRCNT_OF_BUDGET - l_lines_tab(l_Top_Org_Index).CT_BILL_COST_PRCNT_OF_BUDGET;
-- 10 *************************************************************************************--
		IF NVL(l_lines_tab(l_Top_Org_Index).CT_NON_BILL_COST, 0) <> 0 THEN
			l_lines_tab(l_Top_Org_Index).NON_BILL_COST_CHANGE_PRCNT  := 100 * (l_lines_tab(l_Top_Org_Index).NON_BILL_COST -
			l_lines_tab(l_Top_Org_Index).CT_NON_BILL_COST) / ABS( l_lines_tab(l_Top_Org_Index).CT_NON_BILL_COST);
		ELSE
			l_lines_tab(l_Top_Org_Index).NON_BILL_COST_CHANGE_PRCNT := NULL;
		END IF;
--*************************************************************************************--

		IF      NVL( l_lines_tab(l_Top_Org_Index).COST, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).CT_COST, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).BILL_COST, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).CT_BILL_COST, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).BUDGET, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).CT_BUDGET, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).NON_BILL_COST, 0 ) = 0
			AND NVL( l_lines_tab(l_Top_Org_Index).CT_NON_BILL_COST, 0 ) = 0
		THEN
			l_lines_tab.DELETE(l_Top_Org_Index);
		END IF;

        l_Cost:=l_TO_Cost;
		l_CT_Cost:=l_TO_CT_Cost;

        l_Bill_Cost:=l_TO_Bill_Cost;
        l_CT_Bill_Cost:=l_TO_CT_Bill_Cost;

        l_Budget:=l_To_Budget;
        l_CT_Budget:=l_TO_CT_Budget;

		l_Non_Bill_Cost:=l_TO_Non_Bill_Cost;
        l_CT_Non_Bill_Cost:=l_TO_CT_Non_Bill_Cost;

	END IF;

	IF l_lines_tab.COUNT > 0 THEN
	FOR i in l_lines_tab.FIRST..l_lines_tab.LAST
	LOOP
		IF l_lines_tab.EXISTS(i) THEN
			l_lines_tab(i).PJI_REP_TOTAL_1:=l_Cost;
			l_lines_tab(i).PJI_REP_TOTAL_2:=l_CT_Cost;

            IF NVL(l_CT_Cost, 0) <> 0 THEN
			l_lines_tab(i).PJI_REP_TOTAL_3
            :=(l_Cost-l_CT_Cost)*100/ABS(l_CT_Cost);
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_3:=NULL;
			END IF;

            l_lines_tab(i).PJI_REP_TOTAL_4:=l_Bill_Cost;
            l_lines_tab(i).PJI_REP_TOTAL_5:=l_CT_Bill_Cost;

			IF NVL(l_CT_Bill_Cost, 0) <> 0 THEN
			l_lines_tab(i).PJI_REP_TOTAL_6
            :=(l_Bill_Cost-l_CT_Bill_Cost)*100/ABS(l_CT_Bill_Cost);
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_6:=NULL;
			END IF;

			IF NVL(l_Bill_Cost, 0) <> 0 THEN
			l_lines_tab(i).PJI_REP_TOTAL_7
            :=(l_Bill_Cost)*100/ABS(l_Cost);
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_7:=NULL;
			END IF;

			IF NVL(l_CT_Bill_Cost, 0) <> 0 THEN
			l_lines_tab(i).PJI_REP_TOTAL_8
            :=(l_CT_Bill_Cost)*100/ABS(l_CT_Cost);
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_8:=NULL;
			END IF;

            l_lines_tab(i).PJI_REP_TOTAL_9:= l_lines_tab(i).PJI_REP_TOTAL_7 -
                l_lines_tab(i).PJI_REP_TOTAL_8;

            l_lines_tab(i).PJI_REP_TOTAL_10:= l_Budget;
            l_lines_tab(i).PJI_REP_TOTAL_11:= l_CT_Budget;

			IF NVL(l_CT_Budget, 0) <> 0 THEN
			l_lines_tab(i).PJI_REP_TOTAL_12
            :=(l_Budget-l_CT_Budget)*100/ABS(l_CT_Budget);
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_12:=NULL;
			END IF;


			IF NVL(l_Budget, 0) <> 0 THEN
			l_lines_tab(i).PJI_REP_TOTAL_13
            :=(l_Bill_Cost)*100/ABS(l_Budget);
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_13:=NULL;
			END IF;


			IF NVL(l_CT_Budget, 0) <> 0 THEN
			l_lines_tab(i).PJI_REP_TOTAL_14
            :=(l_CT_Bill_Cost)*100/ABS(l_CT_Budget);
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_14:=NULL;
			END IF;


            l_lines_tab(i).PJI_REP_TOTAL_15:=l_lines_tab(i).PJI_REP_TOTAL_13 -
                    l_lines_tab(i).PJI_REP_TOTAL_14;

            l_lines_tab(i).PJI_REP_TOTAL_16:=l_Non_Bill_Cost;
            l_lines_tab(i).PJI_REP_TOTAL_17:=l_CT_Non_Bill_Cost;

			IF NVL(l_CT_Non_Bill_Cost, 0) <> 0 THEN
			l_lines_tab(i).PJI_REP_TOTAL_18
            :=(l_Non_Bill_Cost-l_CT_Non_Bill_Cost)*100/ABS(l_CT_Non_Bill_Cost);
			ELSE
				l_lines_tab(i).PJI_REP_TOTAL_18:=NULL;
			END IF;


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
 END PLSQLDriver_PJI_REP_PC10;


/*
** Contract Projects Trend Report and Contract Cumulative Trend Report
*/

FUNCTION PLSQLDriver_PJI_REP_PC11(
  p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
, p_Organization		IN VARCHAR2
, p_Currency_Type		IN VARCHAR2
, p_As_Of_Date			IN NUMBER
, p_Period_Type 		IN VARCHAR2
, p_View_BY 			IN VARCHAR2
, p_Classifications		IN VARCHAR2 DEFAULT NULL
, p_Class_Codes			IN VARCHAR2 DEFAULT NULL
, p_Report_Type			IN VARCHAR2 DEFAULT NULL
, p_Expenditure_Category   IN VARCHAR2 DEFAULT NULL
, p_Expenditure_Type       IN VARCHAR2 DEFAULT NULL
, p_Work_Type              IN VARCHAR2 DEFAULT NULL
)RETURN PJI_REP_PC11_TBL
IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_Project_Cost_Trend_Tab	PJI_REP_PC11_TBL:=PJI_REP_PC11_TBL();

l_Parse_Class_Codes		VARCHAR2(1);
l_Report_Cost_Type		VARCHAR2(2);

l_Cost                       NUMBER:=0;
l_CT_Cost                    NUMBER:=0;
l_Cost_Change_Prcnt          NUMBER:=0;

l_Bill_Cost		     NUMBER:=0;
l_CT_Bill_Cost	             NUMBER:=0;
l_Bill_Cost_Change_Prcnt     NUMBER:=0;

l_Bill_Prcnt_Of_Cost         NUMBER:=0;
l_CT_Bill_Prcnt_Of_Cost      NUMBER:=0;
l_Prcnt_Of_Cost_Change       NUMBER:=0;

l_Budget                     NUMBER:=0;
l_CT_Budget                  NUMBER:=0;
l_Budget_Change_Prcnt        NUMBER:=0;

l_Bill_Cost_Prcnt_Of_Budget     NUMBER:=0;
l_CT_Bill_Cost_Prcnt_Of_Budget  NUMBER:=0;
l_Change                        NUMBER:=0;

l_Non_Bill_Cost                 NUMBER:=0;
l_CT_Non_Bill_Cost              NUMBER:=0;
l_Non_Bill_Cost_Change_Prcnt    NUMBER:=0;

l_Top_Organization_Name		VARCHAR2(240);

l_Convert_Classification    VARCHAR2(1);
l_Convert_Expenditure_Type  VARCHAR2(1);
l_Convert_Work_Type         VARCHAR2(1);
l_curr_record_type_id           NUMBER:= 1;

BEGIN
	BEGIN
		SELECT report_cost_type
		INTO l_Report_Cost_Type
		FROM pji_system_settings;
	EXCEPTION
WHEN NO_DATA_FOUND THEN
	l_Report_Cost_Type:='RC';
END;

	/*
	** Place a call to all the parse API's which parse the
	** parameters passed by PMV and populate all the
	** temporary tables.
	*/
	PJI_PMV_ENGINE.Convert_Operating_Unit(p_Operating_Unit_IDS=>p_Operating_Unit, p_View_BY=>p_View_BY);
	PJI_PMV_ENGINE.Convert_Organization(p_Top_Organization_ID=>p_Organization, p_View_BY=>p_View_BY, p_Top_Organization_Name=>l_Top_Organization_Name);
	PJI_PMV_ENGINE.Convert_Time(p_As_Of_Date   => p_As_Of_Date,
	                            p_Period_Type  => p_Period_Type,
	                            p_View_BY      => p_View_BY,
	                            p_Parse_Prior  => 'Y',
	                            p_Report_Type  => p_Report_Type,
	                            p_Comparator   => NULL,
	                            p_Parse_ITD    =>  NULL,
	                            p_Full_Period_Flag => 'Y');


    l_Convert_Classification := PJI_PMV_ENGINE.Convert_Classification
                            (p_Classifications, p_Class_Codes, p_View_BY);

    l_Convert_Expenditure_Type := PJI_PMV_ENGINE.Convert_Expenditure_Type
                            (p_Expenditure_Category, p_Expenditure_Type, p_View_BY);
    l_Convert_Work_Type := PJI_PMV_ENGINE.Convert_Work_Type(p_Work_Type, p_View_BY);

    l_curr_record_type_id:=PJI_PMV_ENGINE.Convert_Currency_Record_Type(p_Currency_Type);
/*
** ORGANIZATION Processing: No parameter other than Organization is specified
*/

IF   (l_Convert_Classification ='N')
 AND (l_Convert_Expenditure_Type = 'N')
 AND (l_Convert_Work_Type = 'N')
THEN
		SELECT PJI_REP_PC11(
		  TIME_ID
          , SUM( COST )
          , SUM( CT_COST )
          , NULL
          , SUM( BILL_COST )
          , SUM( CT_BILL_COST )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM ( BUDGET )
          , SUM ( CT_BUDGET )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM( NON_BILL_COST )
          , SUM( CT_Non_Bill_Cost )
          , NULL)
		BULK COLLECT INTO l_Project_Cost_Trend_Tab
		FROM (
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost
		                          ,'BC', contract_brdn_cost),0) cost
				 , 0 CT_COST
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                           'BC', bill_burdened_cost),0) bill_cost
				 , 0 CT_BILL_COST
                 , DECODE(NVL(TIME.amount_type,2),2,
                 DECODE(l_Report_Cost_Type,'RC', con_curr_bgt_raw_cost,
                                           'BC', con_curr_bgt_brdn_cost),0) budget
	             , 0 CT_BUDGET
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost - bill_raw_cost,
                                             'BC', contract_brdn_cost - bill_burdened_cost),0) non_bill_cost
                 , 0 CT_Non_Bill_Cost
             FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_FP_ORGO_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.org_id = HOU.id
				 AND FCT.organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                 AND FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 cost
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost ,'BC', contract_brdn_cost),0) CT_COST
                 , 0 bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                           'BC', bill_burdened_cost),0) CT_BILL_COST
	             , 0 budget
                 , DECODE(NVL(TIME.amount_type,2),2,
                 DECODE(l_Report_Cost_Type,'RC', con_curr_bgt_raw_cost,
                                           'BC', con_curr_bgt_brdn_cost),0) CT_BUDGET
                 , 0 non_bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost -  bill_raw_cost,
                                           'BC', contract_brdn_cost - bill_burdened_cost),0) CT_Non_Bill_Cost
			 FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_FP_ORGO_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				     FCT.org_id = HOU.id
				 AND FCT.organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
				 AND FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 cost
				 , 0 CT_COST
				 , 0 bill_cost
				 , 0 CT_BILL_COST
                 , 0 budget
                 , 0 CT_BUDGET
				 , 0 non_bill_cost
                 , 0 CT_Non_Bill_Cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;

/*
** ORGANIZATION AND CLASSIFICATION Processing:
** Only Organization and Classification is specified
*/

ELSIF
       (l_Convert_Classification ='Y')
AND    (l_Convert_Expenditure_Type = 'N')
AND    (l_Convert_Work_Type = 'N')
THEN
		SELECT PJI_REP_PC11(
		  TIME_ID
          , SUM( COST )
          , SUM( CT_COST )
          , NULL
          , SUM( BILL_COST )
          , SUM( CT_BILL_COST )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM ( BUDGET )
          , SUM ( CT_BUDGET )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM( NON_BILL_COST )
          , SUM( CT_Non_Bill_Cost )
          , NULL)
		BULK COLLECT INTO l_Project_Cost_Trend_Tab
		FROM (
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost ,'BC', contract_brdn_cost),0) cost
				 , 0 CT_COST
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                           'BC', bill_burdened_cost),0) bill_cost
				 , 0 CT_BILL_COST
                 , DECODE(NVL(TIME.amount_type,2),2,
                 DECODE(l_Report_Cost_Type,'RC', con_curr_bgt_raw_cost,
                                           'BC', con_curr_bgt_brdn_cost),0) budget
	             , 0 CT_BUDGET
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost - bill_raw_cost,
                                           'BC', contract_brdn_cost - bill_burdened_cost),0) non_bill_cost
                 , 0 CT_Non_Bill_Cost
             FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_CLS_DIM_TMP CLS
				 , PJI_FP_CLSO_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.PROJECT_ORG_ID = HOU.id
				 AND FCT.PROJECT_organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                 AND FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			     AND FCT.PROJECT_CLASS_ID = CLS.ID
             UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 cost
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost ,'BC', contract_brdn_cost),0) CT_COST
                 , 0 bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                           'BC', bill_burdened_cost),0) CT_BILL_COST
                 , 0 budget
                 , DECODE(NVL(TIME.amount_type,2),2,
                 DECODE(l_Report_Cost_Type,'RC', con_curr_bgt_raw_cost,
                                           'BC', con_curr_bgt_brdn_cost),0) CT_BUDGET
                 , 0 non_bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost -  bill_raw_cost,
                                           'BC', contract_brdn_cost - bill_burdened_cost),0) CT_Non_Bill_Cost
			 FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_CLS_DIM_TMP CLS
				 , PJI_FP_CLSO_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.PROJECT_org_id = HOU.id
				 AND FCT.PROJECT_organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
				 AND FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                AND FCT.PROJECT_CLASS_ID = CLS.ID
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 cost
				 , 0 CT_COST
				 , 0 bill_cost
				 , 0 CT_BILL_COST
				 , 0 budget
				 , 0 CT_BUDGET
				 , 0 non_bill_cost
                 , 0 CT_Non_Bill_Cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;

/*
** ORGANIZATION AND EXPENDITURE CATEGORY/TYPE Processing:
** Only Organization and Expenditure Category/Type is specified
*/

ELSIF
       (l_Convert_Classification ='N')
AND    (l_Convert_Expenditure_Type = 'Y')
AND    (l_Convert_Work_Type = 'N')
THEN

		SELECT PJI_REP_PC11(
		  TIME_ID
          , SUM( COST )
          , SUM( CT_COST )
          , NULL
          , SUM( BILL_COST )
          , SUM( CT_BILL_COST )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM( BUDGET )
          , SUM( CT_BUDGET )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM( NON_BILL_COST )
          , SUM( CT_Non_Bill_Cost )
          , NULL)
		BULK COLLECT INTO l_Project_Cost_Trend_Tab
		FROM (
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost ,'BC', contract_brdn_cost),0) cost
				 , 0 CT_COST
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                             'BC', bill_burdened_cost),0) bill_cost
				 , 0 CT_BILL_COST
                 , NULL AS budget
	         , NULL AS ct_budget
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost - bill_raw_cost,
                                           'BC', contract_brdn_cost - bill_burdened_cost),0) non_bill_cost
                 , 0 CT_Non_Bill_Cost
             FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_ET_RT_DIM_TMP ET
				 , PJI_FP_ORGO_ET_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.org_id = HOU.id
				 AND FCT.organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                 AND FCT.calendar_type = TIME.calendar_type
		 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                 AND ET.record_type = 'ET'
             UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id time_key
				 , 0 cost
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost ,'BC', contract_brdn_cost),0) CT_COST
                 , 0 bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                           'BC', bill_burdened_cost),0) CT_BILL_COST
                 , NULL AS budget
                 , NULL AS CT_BUDGET
                 , 0 non_bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost - bill_raw_cost,
                                           'BC', contract_brdn_cost - bill_burdened_cost),0) CT_Non_Bill_Cost
			 FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_ET_RT_DIM_TMP ET
				 , PJI_FP_ORGO_ET_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.org_id = HOU.id
				 AND FCT.organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
				 AND FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                 AND ET.record_type = 'ET'
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 cost
				 , 0 CT_COST
				 , 0 bill_cost
				 , 0 CT_BILL_COST
				 , NULL AS budget
				 , NULL AS CT_BUDGET
				 , 0 non_bill_cost
                 , 0 CT_Non_Bill_Cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;

/*
** ORGANIZATION AND WORK TYPE Processing:
** Only Organization and Work Type is specified
*/

ELSIF
       (l_Convert_Classification ='N')
AND    (l_Convert_Expenditure_Type = 'N')
AND    (l_Convert_Work_Type = 'Y')
THEN

		SELECT PJI_REP_PC11(
		  TIME_ID
          , SUM( COST )
          , SUM( CT_COST )
          , NULL
          , SUM( BILL_COST )
          , SUM( CT_BILL_COST )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM( BUDGET )
          , SUM( CT_BUDGET )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM( NON_BILL_COST )
          , SUM( CT_Non_Bill_Cost )
          , NULL)
		BULK COLLECT INTO l_Project_Cost_Trend_Tab
		FROM (
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost ,'BC', contract_brdn_cost),0) cost
				 , 0 CT_COST
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                             'BC', bill_burdened_cost),0) bill_cost
				 , 0 CT_BILL_COST
                 , NULL AS budget
                 , NULL AS CT_BUDGET
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost - bill_raw_cost,
                                             'BC', contract_brdn_cost - bill_burdened_cost),0) non_bill_cost
                 , 0 CT_Non_Bill_Cost
             FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_WT_DIM_TMP WT
				 , PJI_FP_ORGO_ET_WT_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.org_id = HOU.id
				 AND FCT.organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                 AND FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.WORK_TYPE_ID = WT.ID
             UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 cost
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost ,
		                           'BC', contract_brdn_cost),0) CT_COST
                 , 0 bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                           'BC', bill_burdened_cost),0) CT_BILL_COST
                 , NULL AS budget
                 , NULL AS CT_BUDGET
                 , 0 non_bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost - bill_raw_cost,
                                           'BC', contract_brdn_cost - bill_burdened_cost),0) CT_Non_Bill_Cost
			 FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_WT_DIM_TMP WT
				 , PJI_FP_ORGO_ET_WT_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.org_id = HOU.id
				 AND FCT.organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
				 AND FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.WORK_TYPE_ID = WT.ID
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 cost
				 , 0 CT_COST
				 , 0 bill_cost
				 , 0 CT_BILL_COST
				 , NULL AS budget
				 , NULL AS CT_BUDGET
				 , 0 non_bill_cost
                 , 0 CT_Non_Bill_Cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;


/*
** ORGANIZATION, CLASSIFICATION AND EXPENDITURE CATEGORY/TYPE Processing:
** Only Organization, Classification and Expenditure Category/Type is specified
*/

ELSIF
       (l_Convert_Classification ='Y')
AND    (l_Convert_Expenditure_Type = 'Y')
AND    (l_Convert_Work_Type = 'N')
THEN
		SELECT PJI_REP_PC11(
		  TIME_ID
          , SUM( COST )
          , SUM( CT_COST )
          , NULL
          , SUM( BILL_COST )
          , SUM( CT_BILL_COST )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM( BUDGET )
          , SUM( CT_BUDGET )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM( NON_BILL_COST )
          , SUM( CT_Non_Bill_Cost )
          , NULL)
		BULK COLLECT INTO l_Project_Cost_Trend_Tab
		FROM (
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost ,'BC', contract_brdn_cost),0) cost
				 , 0 CT_COST
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                           'BC', bill_burdened_cost),0) bill_cost
				 , 0 CT_BILL_COST
                 , NULL AS budget
                 , NULL AS CT_BUDGET
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost - bill_raw_cost,
                                           'BC', contract_brdn_cost - bill_burdened_cost),0) non_bill_cost
                 , 0 CT_Non_Bill_Cost
             FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_ET_RT_DIM_TMP ET
				 , PJI_FP_CLSO_ET_F_MV FCT
                 , PJI_PMV_CLS_DIM_TMP CLS
                 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.PROJECT_org_id = HOU.id
				 AND FCT.PROJECT_organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                 AND FCT.calendar_type = TIME.calendar_type
		 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.PROJECT_CLASS_ID = CLS.ID
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                 AND ET.record_type = 'ET'
             UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 cost
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost ,
		                           'BC', contract_brdn_cost),0) CT_COST
                 , 0 bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                             'BC', bill_burdened_cost),0) CT_BILL_COST
                 , NULL AS budget
                 , NULL AS CT_BUDGET
                 , 0 non_bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost - bill_raw_cost,
                                           'BC', contract_brdn_cost - bill_burdened_cost),0) CT_Non_Bill_Cost
			 FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_ET_RT_DIM_TMP ET
				 , PJI_FP_CLSO_ET_F_MV FCT
                 , PJI_PMV_CLS_DIM_TMP CLS
                 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.PROJECT_org_id = HOU.id
				 AND FCT.PROJECT_organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
				 AND FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.PROJECT_CLASS_ID = CLS.ID
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                 AND ET.record_type = 'ET'
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 cost
				 , 0 CT_COST
				 , 0 bill_cost
				 , 0 CT_BILL_COST
				 , NULL AS budget
				 , NULL AS CT_BUDGET
				 , 0 non_bill_cost
                 , 0 CT_Non_Bill_Cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;

/*
** ORGANIZATION, EXPENDITURE CATEGORY/TYPE AND WORK TYPE Processing:
** Only Organization, Expenditure Category/Type and Work Type is specified
*/

ELSIF
       (l_Convert_Classification ='N')
AND    (l_Convert_Expenditure_Type = 'Y')
AND    (l_Convert_Work_Type = 'Y')
THEN
		SELECT PJI_REP_PC11(
		  TIME_ID
          , SUM( COST )
          , SUM( CT_COST )
          , NULL
          , SUM( BILL_COST )
          , SUM( CT_BILL_COST )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM( BUDGET )
          , SUM( CT_BUDGET )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM( NON_BILL_COST )
          , SUM( CT_Non_Bill_Cost )
          , NULL)
		BULK COLLECT INTO l_Project_Cost_Trend_Tab
		FROM (
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost,
		                           'BC', contract_brdn_cost),0) cost
				 , 0 CT_COST
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                           'BC', bill_burdened_cost),0) bill_cost
				 , 0 CT_BILL_COST
                 , NULL AS budget
	         , NULL AS CT_BUDGET
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost - bill_raw_cost,
                                           'BC', contract_brdn_cost - bill_burdened_cost),0) non_bill_cost
                 , 0 CT_Non_Bill_Cost
             FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_ET_RT_DIM_TMP ET
				 , PJI_FP_ORGO_ET_WT_F_MV FCT
                 , PJI_PMV_WT_DIM_TMP WT
                 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.org_id = HOU.id
				 AND FCT.organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                 AND FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                 AND FCT.WORK_TYPE_ID = WT.ID
                 and ET.record_type = 'ET'
             UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 cost
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost ,'BC', contract_brdn_cost),0) CT_COST
                 , 0 bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                           'BC', bill_burdened_cost),0) CT_BILL_COST
                 , NULL AS budget
                 , NULL AS CT_BUDGET
                 , 0 non_bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost - bill_raw_cost,
                                           'BC', contract_brdn_cost - bill_burdened_cost),0) CT_Non_Bill_Cost
			 FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_ET_RT_DIM_TMP ET
				 , PJI_FP_ORGO_ET_WT_F_MV FCT
                 , PJI_PMV_WT_DIM_TMP WT
                 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.org_id = HOU.id
				 AND FCT.organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
				 AND FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                 AND FCT.WORK_TYPE_ID = WT.ID
                 and ET.record_type = 'ET'
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 cost
				 , 0 CT_COST
				 , 0 bill_cost
				 , 0 CT_BILL_COST
				 , NULL AS budget
				 , NULL AS CT_BUDGET
				 , 0 non_bill_cost
                 , 0 CT_Non_Bill_Cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;

/*
** ORGANIZATION, CLASSIFICATION AND WORK TYPE Processing:
** Only Organization, Classification and Work Type is specified
*/

ELSIF
       (l_Convert_Classification ='Y')
AND    (l_Convert_Expenditure_Type = 'N')
AND    (l_Convert_Work_Type = 'Y')
THEN
		SELECT PJI_REP_PC11(
		  TIME_ID
          , SUM( COST )
          , SUM( CT_COST )
          , NULL
          , SUM( BILL_COST )
          , SUM( CT_BILL_COST )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM( BUDGET )
          , SUM( CT_BUDGET )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM( NON_BILL_COST )
          , SUM( CT_Non_Bill_Cost )
          , NULL)
		BULK COLLECT INTO l_Project_Cost_Trend_Tab
		FROM (
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost ,'BC', contract_brdn_cost),0) cost
				 , 0 CT_COST
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                           'BC', bill_burdened_cost),0) bill_cost
				 , 0 CT_BILL_COST
                 , NULL AS budget
	             , NULL AS CT_BUDGET
                 , DECODE(NVL(TIME.amount_type,1),1,
                  DECODE(l_Report_Cost_Type,'RC', contract_raw_cost - bill_raw_cost,
                                            'BC', contract_brdn_cost - bill_burdened_cost),0) non_bill_cost
                 , 0 CT_Non_Bill_Cost
             FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_CLS_DIM_TMP CLS
				 , PJI_FP_CLSO_ET_WT_F_MV FCT
                 , PJI_PMV_WT_DIM_TMP WT
                 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.PROJECT_org_id = HOU.id
				 AND FCT.PROJECT_organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                 AND FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.PROJECT_CLASS_ID = CLS.ID
                 AND FCT.WORK_TYPE_ID = WT.ID
             UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 cost
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost ,'BC', contract_brdn_cost),0) CT_COST
                 , 0 bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                           'BC', bill_burdened_cost),0) CT_BILL_COST
                 , NULL AS budget
                 , NULL AS CT_BUDGET
                 , 0 non_bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost - bill_raw_cost,
                                           'BC', contract_brdn_cost - bill_burdened_cost),0) CT_Non_Bill_Cost
			 FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_CLS_DIM_TMP CLS
				 , PJI_FP_CLSO_ET_WT_F_MV FCT
                 , PJI_PMV_WT_DIM_TMP WT
                 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.PROJECT_org_id = HOU.id
				 AND FCT.PROJECT_organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
				 AND FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.PROJECT_CLASS_ID = CLS.ID
                 AND FCT.WORK_TYPE_ID = WT.ID
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 cost
				 , 0 CT_COST
				 , 0 bill_cost
				 , 0 CT_BILL_COST
				 , NULL AS budget
				 , NULL AS CT_BUDGET
				 , 0 non_bill_cost
                 , 0 CT_Non_Bill_Cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;


/*
** ORGANIZATION, CLASSIFICATION, EXPENDITURE CATEGORY/TYPE AND WORK TYPE Processing:
** All Parameters specified: Organization, Classification, Expenditure Category/Type
** and Work Type is specified
*/

ELSE
		SELECT PJI_REP_PC11(
		  TIME_ID
          , SUM( COST )
          , SUM( CT_COST )
          , NULL
          , SUM( BILL_COST )
          , SUM( CT_BILL_COST )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM( BUDGET )
          , SUM( CT_BUDGET )
          , NULL
          , NULL
          , NULL
          , NULL
          , SUM( NON_BILL_COST )
          , SUM( CT_Non_Bill_Cost )
          , NULL)
		BULK COLLECT INTO l_Project_Cost_Trend_Tab
		FROM (
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost ,'BC', contract_brdn_cost),0) cost
				 , 0 CT_COST
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                           'BC', bill_burdened_cost),0) bill_cost
				 , 0 CT_BILL_COST
                 , NULL AS budget
	         , NULL AS CT_BUDGET
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost - bill_raw_cost,
                                             'BC', contract_brdn_cost - bill_burdened_cost),0) non_bill_cost
                 , 0 CT_Non_Bill_Cost
             FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_ET_RT_DIM_TMP ET
				 , PJI_FP_CLSO_ET_WT_F_MV FCT
                 , PJI_PMV_CLS_DIM_TMP CLS
                 , PJI_PMV_WT_DIM_TMP WT
                 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.PROJECT_org_id = HOU.id
				 AND FCT.PROJECT_organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                 AND FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.PROJECT_CLASS_ID = CLS.ID
                 AND FCT.WORK_TYPE_ID = WT.ID
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                 AND ET.record_type = 'ET'
             UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 cost
		 , DECODE(NVL(TIME.amount_type,1),1,
		 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost ,'BC', contract_brdn_cost),0) CT_COST
                 , 0 bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', bill_raw_cost,
                                           'BC', bill_burdened_cost),0) CT_BILL_COST
                 , NULL AS budget
                 , NULL AS CT_BUDGET
                 , 0 non_bill_cost
                 , DECODE(NVL(TIME.amount_type,1),1,
                 DECODE(l_Report_Cost_Type,'RC', contract_raw_cost - bill_raw_cost,
                                           'BC', contract_brdn_cost - bill_burdened_cost),0) CT_Non_Bill_Cost
			 FROM
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_ET_RT_DIM_TMP ET
				 , PJI_FP_CLSO_ET_WT_F_MV FCT
                 , PJI_PMV_CLS_DIM_TMP CLS
                 , PJI_PMV_WT_DIM_TMP WT
                 , PJI_PMV_ORG_DIM_TMP HOU
			 WHERE
				 FCT.PROJECT_org_id = HOU.id
				 AND FCT.PROJECT_organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
				 AND FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.PROJECT_CLASS_ID = CLS.ID
                 AND FCT.WORK_TYPE_ID = WT.ID
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                 AND ET.record_type = 'ET'
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 cost
				 , 0 CT_COST
				 , 0 bill_cost
				 , 0 CT_BILL_COST
				 , NULL AS budget
				 , NULL AS CT_BUDGET
				 , 0 non_bill_cost
                 , 0 CT_Non_Bill_Cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;

	END IF;

FOR i in 1..l_Project_Cost_Trend_Tab.COUNT
	LOOP
		IF p_Report_Type = 'FISCAL' THEN
	l_Cost             := l_Cost         + l_Project_Cost_Trend_Tab(i).COST;
	l_CT_COST          := l_CT_COST      + l_Project_Cost_Trend_Tab(i).CT_COST;
	l_Bill_Cost        := l_Bill_Cost    + l_Project_Cost_Trend_Tab(i).BILL_COST;
	l_CT_BILL_COST     := l_CT_BILL_COST + l_Project_Cost_Trend_Tab(i).CT_BILL_COST;
    l_Budget           := l_Budget       + l_Project_Cost_Trend_Tab(i).BUDGET;
    l_CT_BUDGET        := l_CT_BUDGET    + l_Project_Cost_Trend_Tab(i).CT_BUDGET;
    l_Non_Bill_Cost    := l_Non_Bill_Cost    + l_Project_Cost_Trend_Tab(i).NON_BILL_COST;
    l_CT_Non_Bill_Cost := l_CT_Non_Bill_Cost + l_Project_Cost_Trend_Tab(i).CT_NON_BILL_COST;

	l_Project_Cost_Trend_Tab(i).COST         :=l_Cost;
	l_Project_Cost_Trend_Tab(i).CT_COST      :=l_CT_COST;
	l_Project_Cost_Trend_Tab(i).BILL_COST    :=l_Bill_Cost;
    l_Project_Cost_Trend_Tab(i).CT_BILL_COST :=l_CT_BILL_COST;
	l_Project_Cost_Trend_Tab(i).BUDGET       :=l_Budget;
	l_Project_Cost_Trend_Tab(i).CT_BUDGET    :=l_CT_BUDGET;
	l_Project_Cost_Trend_Tab(i).NON_BILL_COST    :=l_Non_Bill_Cost;
    l_Project_Cost_Trend_Tab(i).CT_NON_BILL_COST :=l_CT_Non_Bill_Cost;


        END IF;

		IF NVL(l_Project_Cost_Trend_Tab(i).CT_COST,0) <> 0 THEN
				l_Project_Cost_Trend_Tab(i).COST_CHANGE_PRCNT := 100*
			((l_Project_Cost_Trend_Tab(i).COST-l_Project_Cost_Trend_Tab(i).CT_COST)
			/ABS(l_Project_Cost_Trend_Tab(i).CT_COST));
		ELSE
			l_Project_Cost_Trend_Tab(i).COST_CHANGE_PRCNT := NULL;
		END IF;

		IF NVL(l_Project_Cost_Trend_Tab(i).CT_BILL_COST,0) <> 0 THEN
			l_Project_Cost_Trend_Tab(i).BILL_COST_CHANGE_PRCNT := 100*
			((l_Project_Cost_Trend_Tab(i).BILL_COST-l_Project_Cost_Trend_Tab(i).CT_BILL_COST)
			/ABS(l_Project_Cost_Trend_Tab(i).CT_BILL_COST));
		ELSE
			l_Project_Cost_Trend_Tab(i).BILL_COST_CHANGE_PRCNT := NULL;
		END IF;


		IF NVL(l_Project_Cost_Trend_Tab(i).COST,0) <> 0 THEN
			l_Project_Cost_Trend_Tab(i).BILL_PRCNT_OF_COST := 100*
			((l_Project_Cost_Trend_Tab(i).BILL_COST)
			/ABS(l_Project_Cost_Trend_Tab(i).COST));
		ELSE
			l_Project_Cost_Trend_Tab(i).BILL_PRCNT_OF_COST := NULL;
		END IF;

		IF NVL(l_Project_Cost_Trend_Tab(i).CT_COST,0) <> 0 THEN
			l_Project_Cost_Trend_Tab(i).CT_BILL_PRCNT_OF_COST := 100*
			((l_Project_Cost_Trend_Tab(i).CT_BILL_COST)
			/ABS(l_Project_Cost_Trend_Tab(i).CT_COST));
		ELSE
			l_Project_Cost_Trend_Tab(i).CT_BILL_PRCNT_OF_COST := NULL;
		END IF;

	   l_Project_Cost_Trend_Tab(i).PRCNT_OF_COST_CHANGE :=
			l_Project_Cost_Trend_Tab(i).BILL_PRCNT_OF_COST
			 -  l_Project_Cost_Trend_Tab(i).CT_BILL_PRCNT_OF_COST;

		IF NVL(l_Project_Cost_Trend_Tab(i).CT_BUDGET,0) <> 0 THEN
			l_Project_Cost_Trend_Tab(i).BUDGET_CHANGE_PRCNT := 100*
			((l_Project_Cost_Trend_Tab(i).BUDGET -
                            l_Project_Cost_Trend_Tab(i).CT_BUDGET)
			/ABS(l_Project_Cost_Trend_Tab(i).CT_BUDGET));
		ELSE
			l_Project_Cost_Trend_Tab(i).BUDGET_CHANGE_PRCNT := NULL;
		END IF;

		IF NVL(l_Project_Cost_Trend_Tab(i).BUDGET,0) <> 0 THEN
			l_Project_Cost_Trend_Tab(i).BILL_COST_PRCNT_OF_BUDGET := 100*
			((l_Project_Cost_Trend_Tab(i).BILL_COST)
           /ABS(l_Project_Cost_Trend_Tab(i).BUDGET));
		ELSE
			l_Project_Cost_Trend_Tab(i).BILL_COST_PRCNT_OF_BUDGET := NULL;
		END IF;

		IF NVL(l_Project_Cost_Trend_Tab(i).CT_BUDGET,0) <> 0 THEN
			l_Project_Cost_Trend_Tab(i).CT_BILL_COST_PRCNT_OF_BUDGET := 100*
			((l_Project_Cost_Trend_Tab(i).CT_BILL_COST)
           /ABS(l_Project_Cost_Trend_Tab(i).CT_BUDGET));
		ELSE
			l_Project_Cost_Trend_Tab(i).CT_BILL_COST_PRCNT_OF_BUDGET := NULL;
		END IF;

	   l_Project_Cost_Trend_Tab(i).CHANGE :=
			l_Project_Cost_Trend_Tab(i).BILL_COST_PRCNT_OF_BUDGET
			 -  l_Project_Cost_Trend_Tab(i).CT_BILL_COST_PRCNT_OF_BUDGET;

		IF NVL(l_Project_Cost_Trend_Tab(i).CT_Non_Bill_Cost,0) <> 0 THEN
			l_Project_Cost_Trend_Tab(i).NON_BILL_COST_CHANGE_PRCNT := 100*
			((l_Project_Cost_Trend_Tab(i).NON_BILL_COST -
                            l_Project_Cost_Trend_Tab(i).CT_Non_Bill_Cost)
			/ABS(l_Project_Cost_Trend_Tab(i).CT_Non_Bill_Cost));
		ELSE
			l_Project_Cost_Trend_Tab(i).NON_BILL_COST_CHANGE_PRCNT := NULL;
		END IF;

		/*
		** The below portion of the code is commented
		** because the trend reports donot have totals.
		*/
		/*
		l_Total_Revenue := l_Total_Revenue + NVL(l_Total_Prj_Profitablity_Tab(i).REVENUE, 0);
		l_Total_Cost := l_Total_Cost + NVL(l_Total_Prj_Profitablity_Tab(i).COST, 0);
		l_Total_Margin := l_Total_Margin + NVL(l_Total_Prj_Profitablity_Tab(i).MARGIN, 0);
		l_Total_CT_Revenue := l_Total_CT_Revenue + NVL(l_Total_Prj_Profitablity_Tab(i).CT_REVENUE, 0);
		l_Total_CT_COST := l_Total_CT_COST + NVL(l_Total_Prj_Profitablity_Tab(i).CT_COST, 0);
		l_Total_CT_Margin := l_Total_CT_Margin + NVL(l_Total_Prj_Profitablity_Tab(i).CT_MARGIN, 0);
		*/
	END LOOP;

	/*
	** Return the bulk collected table back to pmv.
	*/

	COMMIT;
	RETURN l_Project_Cost_Trend_Tab;

END PLSQLDriver_PJI_REP_PC11;



/*********************************************************************************
**********************************************************************************
**
**
** Projects Contract Cost Detail Report
**
**
**********************************************************************************
**********************************************************************************
*/


FUNCTION  PLSQLDriver_PJI_REP_PC13(
           p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
         , p_Organization		IN VARCHAR2
         , p_Currency_Type		IN VARCHAR2
         , p_As_of_Date         IN NUMBER
         , p_Period_Type 		IN VARCHAR2
         , p_View_BY 			IN VARCHAR2
         , p_Classifications	IN VARCHAR2 DEFAULT NULL
         , p_Class_Codes		IN VARCHAR2 DEFAULT NULL
         , p_Project_IDS		IN VARCHAR2 DEFAULT NULL
         , p_Expenditure_Category   IN VARCHAR2 DEFAULT NULL
         , p_Expenditure_Type       IN VARCHAR2 DEFAULT NULL
         , p_Work_Type              IN VARCHAR2 DEFAULT NULL
         )  RETURN PJI_REP_PC13_TBL
	IS

        PRAGMA AUTONOMOUS_TRANSACTION;

/*
**         PL/SQL Declaration
*/
	l_detail_tab		PJI_REP_PC13_TBL := PJI_REP_PC13_TBL();

	l_Cost				         NUMBER := 0;
	l_Bill_Cost	                 NUMBER := 0;
	l_Bill_Cost_Prcnt_Of_Cost	 NUMBER := 0;
	l_Budget	                 NUMBER := 0;
	l_Bill_Cost_Prcnt_Of_Budget  NUMBER := 0;
	l_Non_Bill_Cost	             NUMBER := 0;

        l_Convert_Classification        VARCHAR2(1);
        l_Convert_Expenditure_Type      VARCHAR2(1);
        l_Convert_Work_Type             VARCHAR2(1);
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

   l_Convert_Classification :=
       PJI_PMV_ENGINE.Convert_Classification(p_Classifications, p_Class_Codes, p_View_BY);
   l_Convert_Expenditure_Type :=
       PJI_PMV_ENGINE.Convert_Expenditure_Type(p_Expenditure_Category, p_Expenditure_Type, p_View_BY);
   l_Convert_Work_Type :=
       PJI_PMV_ENGINE.Convert_Work_Type(p_Work_Type, p_View_BY);

   l_curr_record_type_id:=PJI_PMV_ENGINE.Convert_Currency_Record_Type(p_Currency_Type);

	IF p_Project_IDS IS NULL THEN

/*
			BEGIN
                        DELETE pji_pmv_prj_dim_tmp;

                        INSERT INTO pji_pmv_prj_dim_tmp (id, name)
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
			END;

*/

			BEGIN
				DELETE pji_pmv_prj_dim_tmp;

				IF p_Classifications IS NOT NULL THEN
                        INSERT INTO pji_pmv_prj_dim_tmp (id, name)
						SELECT DISTINCT prj.project_id, '-1' name
						FROM
						  pji_project_classes PJM
						, (SELECT project_id
						   FROM pji_project_classes
						   WHERE class_category = '$PROJECT_TYPE$CONTRACT') PJC
						, pji_pmv_cls_dim_tmp PTM
						, pji_pmv_orgz_dim_tmp org
						, pa_projects_all prj
						WHERE 1=1
						AND pjm.project_class_id = ptm.id
						AND prj.project_id = pjc.project_id
						AND prj.project_id = pjm.project_id
						AND prj.carrying_out_organization_id = org.ID;
				ELSE
                        INSERT INTO pji_pmv_prj_dim_tmp (id, name)
                        SELECT DISTINCT prj.project_id, '-1' name
                        FROM
                        pji_project_classes PJM
                        , pji_pmv_orgz_dim_tmp org
                        , pa_projects_all prj
                        WHERE
                            prj.project_id = pjm.project_id
                        AND prj.carrying_out_organization_id = org.ID
                        AND pjm.class_category = '$PROJECT_TYPE$CONTRACT';
			   END IF;
			END;
	ELSE
	PJI_PMV_ENGINE.Convert_Project(P_PROJECT_IDS=>p_Project_IDS
						, P_VIEW_BY =>p_View_BY);
	END IF;
/*
** ORG Processing ---------------------------------------------------+
*/
        IF (l_Convert_Classification = 'N')
       and (l_Convert_Expenditure_Type = 'N')
       and (l_Convert_Work_Type = 'N')
          THEN
			SELECT PJI_REP_PC13 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM (COST)
            , SUM (BILL_COST)
            , NULL
            , SUM (BUDGET)
            , NULL
            , SUM(NON_BILL_COST)
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost, 0), 0) AS COST
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.bill_burdened_cost,
                                                        'RC', fct.bill_raw_cost, 0), 0) AS BILL_COST
					, DECODE(NVL(TIME.amount_type,2),2,
                            DECODE(G_Report_Cost_Type,  'BC', fct.CURR_BGT_BURDENED_COST,
                                                        'RC', fct.CURR_BGT_RAW_COST, 0), 0) AS BUDGET
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.BURDENED_COST - fct.bill_burdened_cost,
                                                        'RC', fct.RAW_COST -  fct.bill_raw_cost, 0), 0) AS NON_BILL_COST

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
**	  -- CLASS Processing ---------------------------------------------------+
*/
 ELSIF  (l_Convert_Classification = 'Y')
 and (l_Convert_Expenditure_Type = 'N')
 and (l_Convert_Work_Type = 'N')
THEN
			SELECT PJI_REP_PC13 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM (COST)
            , SUM (BILL_COST)
            , NULL
            , SUM (BUDGET)
            , NULL
            , SUM(NON_BILL_COST)
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost, 0), 0) AS COST
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.bill_burdened_cost,
                                                        'RC', fct.bill_raw_cost, 0), 0) AS BILL_COST
					, DECODE(NVL(TIME.amount_type,2),2,
                            DECODE(G_Report_Cost_Type,  'BC', fct.CURR_BGT_BURDENED_COST,
                                                        'RC', fct.CURR_BGT_RAW_COST, 0), 0) AS BUDGET
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.BURDENED_COST - fct.bill_burdened_cost,
                                                        'RC', fct.RAW_COST -  fct.bill_raw_cost, 0), 0) AS NON_BILL_COST

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
**
** Expenditure Type Processing
**
*/

ELSIF  (l_Convert_Classification = 'N')
and (l_Convert_Expenditure_Type = 'Y')
and (l_Convert_Work_Type = 'N')
     THEN
			SELECT PJI_REP_PC13 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM (COST)
            , SUM (BILL_COST)
            , NULL
            , SUM (BUDGET)
            , NULL
            , SUM(NON_BILL_COST)
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost, 0), 0) AS COST
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.bill_burdened_cost,
                                                        'RC', fct.bill_raw_cost, 0), 0) AS BILL_COST
					, NULL AS BUDGET
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.BURDENED_COST - fct.bill_burdened_cost,
                                                        'RC', fct.RAW_COST -  fct.bill_raw_cost, 0), 0) AS NON_BILL_COST

					FROM   PJI_PMV_TIME_DIM_TMP TIME
						, PJI_PMV_PRJ_DIM_TMP PRJ
						, PJI_PMV_ET_RT_DIM_TMP ET
						, PJI_FP_PROJ_ET_F FCT
						, PJI_PMV_ORG_DIM_TMP HOU
					WHERE  1=1
					AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
					AND FCT.PROJECT_ID = PRJ.ID
					AND FCT.EXP_EVT_TYPE_ID = ET.ID
					AND ET.record_type ='ET'
					AND FCT.PROJECT_ORG_ID = HOU.ID
					AND FCT.TIME_ID = TIME.ID
					AND TIME.ID IS NOT NULL
					AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
					AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
					) FCT
                	GROUP BY PROJECT_ID,ORGANIZATION_ID;
/*
**
** Work Type Processing
**
*/

ELSIF (l_Convert_Classification = 'N')
and (l_Convert_Expenditure_Type = 'N')
 and (l_Convert_Work_Type = 'Y')
          THEN

			SELECT PJI_REP_PC13 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM (COST)
            , SUM (BILL_COST)
            , NULL
            , SUM (BUDGET)
            , NULL
            , SUM(NON_BILL_COST)
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost, 0), 0) AS COST
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.bill_burdened_cost,
                                                        'RC', fct.bill_raw_cost, 0), 0) AS BILL_COST
					, NULL AS BUDGET
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.BURDENED_COST - fct.bill_burdened_cost,
                                                        'RC', fct.RAW_COST -  fct.bill_raw_cost, 0), 0) AS NON_BILL_COST

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
**
**  Classification and Expenditure Type Processing
**
*/

ELSIF   (l_Convert_Classification = 'Y')
   and  (l_Convert_Expenditure_Type = 'Y')
    and (l_Convert_Work_Type = 'N')
    THEN

			SELECT PJI_REP_PC13 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM (COST)
            , SUM (BILL_COST)
            , NULL
            , SUM (BUDGET)
            , NULL
            , SUM(NON_BILL_COST)
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost, 0), 0) AS COST
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.bill_burdened_cost,
                                                        'RC', fct.bill_raw_cost, 0), 0) AS BILL_COST
					, NULL AS BUDGET
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.BURDENED_COST - fct.bill_burdened_cost,
                                                        'RC', fct.RAW_COST -  fct.bill_raw_cost, 0), 0) AS NON_BILL_COST

					FROM   PJI_PMV_TIME_DIM_TMP TIME
						, PJI_PMV_PRJ_DIM_TMP PRJ
						, PJI_PMV_ET_RT_DIM_TMP ET
						, PJI_FP_PROJ_ET_F FCT
						, PJI_PMV_ORG_DIM_TMP HOU
					WHERE  1=1
					AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
					AND FCT.PROJECT_ID = PRJ.ID
					AND FCT.EXP_EVT_TYPE_ID = ET.ID
					AND ET.record_type ='ET'
					AND FCT.PROJECT_ORG_ID = HOU.ID
					AND FCT.TIME_ID = TIME.ID
					AND TIME.ID IS NOT NULL
					AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
					AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
					) FCT
			GROUP BY PROJECT_ID,ORGANIZATION_ID;
/*
**
**  Expenditure Type and Work Type Processing
**
*/

ELSIF (l_Convert_Classification = 'N')
and (l_Convert_Expenditure_Type = 'Y')
 and (l_Convert_Work_Type = 'Y')
          THEN

			SELECT PJI_REP_PC13 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM (COST)
            , SUM (BILL_COST)
            , NULL
            , SUM (BUDGET)
            , NULL
            , SUM(NON_BILL_COST)
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost, 0), 0) AS COST
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.bill_burdened_cost,
                                                        'RC', fct.bill_raw_cost, 0), 0) AS BILL_COST
					, NULL AS BUDGET
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.BURDENED_COST - fct.bill_burdened_cost,
                                                        'RC', fct.RAW_COST -  fct.bill_raw_cost, 0), 0) AS NON_BILL_COST

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
					AND ET.record_type ='ET'
					AND FCT.WORK_TYPE_ID = WT.ID
					AND FCT.PROJECT_ORG_ID = HOU.ID
					AND FCT.TIME_ID = TIME.ID
					AND TIME.ID IS NOT NULL
					AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
					AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
					) FCT
			GROUP BY PROJECT_ID,ORGANIZATION_ID;
/*
**
**  Classification and Work Type Processing
**
*/

ELSIF (l_Convert_Classification = 'Y')
and (l_Convert_Expenditure_Type = 'N')
 and (l_Convert_Work_Type = 'Y')
	THEN		SELECT PJI_REP_PC13 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM (COST)
            , SUM (BILL_COST)
            , NULL
            , SUM (BUDGET)
            , NULL
            , SUM(NON_BILL_COST)
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost, 0), 0) AS COST
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.bill_burdened_cost,
                                                        'RC', fct.bill_raw_cost, 0), 0) AS BILL_COST
					, NULL AS BUDGET
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.BURDENED_COST - fct.bill_burdened_cost,
                                                        'RC', fct.RAW_COST -  fct.bill_raw_cost, 0), 0) AS NON_BILL_COST

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

ELSE

			SELECT PJI_REP_PC13 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM (COST)
            , SUM (BILL_COST)
            , NULL
            , SUM (BUDGET)
            , NULL
            , SUM(NON_BILL_COST)
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost, 0), 0) AS COST
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.bill_burdened_cost,
                                                        'RC', fct.bill_raw_cost, 0), 0) AS BILL_COST
					, NULL AS BUDGET
					, DECODE(TIME.amount_type,1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.BURDENED_COST - fct.bill_burdened_cost,
                                                        'RC', fct.RAW_COST -  fct.bill_raw_cost, 0), 0) AS NON_BILL_COST

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
					AND ET.record_type ='ET'
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


		IF NVL(l_detail_tab(i).COST, 0) <> 0 THEN
			l_detail_tab(i).BILL_COST_PRCNT_OF_COST := 100*((l_detail_tab(i).BILL_COST)/ABS(l_detail_tab(i).COST));
		ELSE
			l_detail_tab(i).BILL_COST_PRCNT_OF_COST := NULL;
		END IF;

		IF NVL(l_detail_tab(i).BUDGET, 0) <> 0 THEN
			l_detail_tab(i).BILL_PRCNT_OF_BUDGET_COST := 100*((l_detail_tab(i).BILL_COST)/ABS(l_detail_tab(i).BUDGET));
		ELSE
			l_detail_tab(i).BILL_PRCNT_OF_BUDGET_COST := NULL;
		END IF;

		l_Cost          := l_Cost           + NVL(l_detail_tab(i).COST , 0);
		l_Bill_Cost     := l_Bill_Cost      + NVL(l_detail_tab(i).BILL_COST, 0);
		l_Budget        := l_Budget         + NVL(l_detail_tab(i).BUDGET , 0);
		l_Non_Bill_Cost := l_Non_Bill_Cost  + NVL(l_detail_tab(i).NON_BILL_COST , 0);

	END LOOP;

	FOR i IN 1..l_detail_tab.COUNT

	LOOP
		l_detail_tab(i).PJI_REP_TOTAL_1:=l_Cost;
		l_detail_tab(i).PJI_REP_TOTAL_2:=l_Bill_Cost;
		l_detail_tab(i).PJI_REP_TOTAL_4:=l_Budget;
		l_detail_tab(i).PJI_REP_TOTAL_6:=l_Non_Bill_Cost;

		IF NVL(l_detail_tab(i).PJI_REP_TOTAL_1, 0) <> 0 THEN
			l_detail_tab(i).PJI_REP_TOTAL_3 := 100*((l_detail_tab(i).PJI_REP_TOTAL_2)/ABS(l_detail_tab(i).PJI_REP_TOTAL_1));
		ELSE
			l_detail_tab(i).PJI_REP_TOTAL_3 := NULL;
		END IF;

		IF NVL(l_detail_tab(i).PJI_REP_TOTAL_4, 0) <> 0 THEN
			l_detail_tab(i).PJI_REP_TOTAL_5 := 100*((l_detail_tab(i).PJI_REP_TOTAL_2)/ABS(l_detail_tab(i).PJI_REP_TOTAL_4));
		ELSE
			l_detail_tab(i).PJI_REP_TOTAL_5 := NULL;
		END IF;

	END LOOP;

/*
** Return the bulk collected table back to pmv.
*/

  COMMIT;

 RETURN l_detail_tab;


END PLSQLDriver_PJI_REP_PC13;


END PJI_PMV_COST;

/
