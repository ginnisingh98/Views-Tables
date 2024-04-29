--------------------------------------------------------
--  DDL for Package Body PJI_PMV_PROFITABILITY_TREND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PMV_PROFITABILITY_TREND" AS
/* $Header: PJIRF05B.pls 120.4 2005/10/11 18:10:45 appldev noship $ */

/*
** ----------------------------------------------------------
** Procedure: Get_SQL_PJI_REP_PP5
** This procedure returns sql statement generated by the base
** engine api and view by as a out parameter for the report
** PJI_REP_PP5.
** ----------------------------------------------------------
*/
PROCEDURE Get_SQL_PJI_REP_PP5(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
BEGIN
    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
			, P_SELECT_LIST =>
				'  FACT.REVENUE  "PJI_REP_MSR_1"
				, FACT.PY_REVENUE  "PJI_REP_MSR_2"
				, FACT.REV_CHANGE_PERCENT  "PJI_REP_MSR_3"
				, FACT.MARGIN_PERCENT  "PJI_REP_MSR_4"
				, FACT.PY_MARGIN_PERCENT  "PJI_REP_MSR_5"
				, FACT.MAR_CHANGE_PERCENT  "PJI_REP_MSR_6"
				, FACT.MARGIN  "PJI_REP_MSR_8"
				, FACT.PY_MARGIN  "PJI_REP_MSR_9"
				, FACT.PY_REVENUE  "PJI_REP_MSR_11"
				, FACT.REVENUE  "PJI_REP_MSR_10"
				, FACT.PY_MARGIN_PERCENT  "PJI_REP_MSR_12"
				, FACT.MARGIN_PERCENT  "PJI_REP_MSR_13" '
            , P_SQL_STATEMENT => x_PMV_Sql
            , P_PMV_OUTPUT => x_PMV_Output
			, P_REGION_CODE => 'PJI_REP_PP5'
			, P_PLSQL_DRIVER => 'PJI_PMV_PROFITABILITY_TREND.PLSQLDriver_PJI_REP_PP5'
			, P_PLSQL_DRIVER_PARAMS => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
			  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
			  ', <<CURRENCY+FII_CURRENCIES>>'||
			  ', <<AS_OF_DATE>>'||
			  ', <<PERIOD_TYPE>>'||
			  ', <<VIEW_BY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CODE>>'||
			  ', NULL'||
                                  ', NULL'||
                                  ', NULL'||
                                  ', <<PROJECT REVENUE CATEGORY+PJI_REVENUE_CATEGORIES>>'||
                                  ', <<PROJECT REVENUE CATEGORY+CLASS_CODE>>'||
                                  ', NULL'
);
END Get_SQL_PJI_REP_PP5;

/*
** ----------------------------------------------------------
** Procedure: Get_SQL_PJI_REP_PP6
** This procedure returns sql statement generated by the base
** engine api and view by as a out parameter for the report
** PJI_REP_PP6.
** ----------------------------------------------------------
*/
PROCEDURE Get_SQL_PJI_REP_PP6(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
l_PMV_Rec			BIS_QUERY_ATTRIBUTES;
BEGIN
    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
			, P_SELECT_LIST =>
				' FACT.REVENUE  "PJI_REP_MSR_1"
				, FACT.PY_REVENUE  "PJI_REP_MSR_2"
				, FACT.REV_CHANGE_PERCENT  "PJI_REP_MSR_3"
				, FACT.MARGIN_PERCENT  "PJI_REP_MSR_4"
				, FACT.PY_MARGIN_PERCENT  "PJI_REP_MSR_5"
				, FACT.MAR_CHANGE_PERCENT  "PJI_REP_MSR_6"
				, FACT.MARGIN  "PJI_REP_MSR_8"
				, FACT.PY_MARGIN  "PJI_REP_MSR_9"
				, FACT.REVENUE  "PJI_REP_MSR_10"
				, FACT.MARGIN_PERCENT  "PJI_REP_MSR_11" '
            , P_SQL_STATEMENT => x_PMV_Sql
            , P_PMV_OUTPUT => x_PMV_Output
			, P_REGION_CODE => 'PJI_REP_PP6'
			, P_PLSQL_DRIVER => 'PJI_PMV_PROFITABILITY_TREND.PLSQLDriver_PJI_REP_PP5'
			, P_PLSQL_DRIVER_PARAMS => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
			  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
			  ', <<CURRENCY+FII_CURRENCIES>>'||
			  ', <<AS_OF_DATE>>'||
			  ', <<PERIOD_TYPE>>'||
			  ', <<VIEW_BY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CODE>>'||
			  ', :PJI_EXTRA_BND_01'||
                                  ', NULL'||
                                  ', NULL'||
                                  ', <<PROJECT REVENUE CATEGORY+PJI_REVENUE_CATEGORIES>>'||
                                  ', <<PROJECT REVENUE CATEGORY+CLASS_CODE>>'||
                                  ', NULL'
                      );

	l_PMV_Rec:=BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
	l_PMV_Rec.attribute_name:=':PJI_EXTRA_BND_01';
	l_PMV_Rec.attribute_value:='FISCAL';
	l_PMV_Rec.attribute_type:=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	l_PMV_Rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

	x_PMV_Output.EXTEND();
	x_PMV_Output(x_PMV_Output.COUNT):=l_PMV_Rec;

END Get_SQL_PJI_REP_PP6;

/*
** ----------------------------------------------------------
** Procedure: Get_SQL_PJI_REP_PP7
** This procedure returns sql statement generated by the base
** engine api and view by as a out parameter for the report
** PJI_REP_PP7.
** ----------------------------------------------------------
*/
PROCEDURE Get_SQL_PJI_REP_PP7(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
BEGIN
    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
            , P_SQL_STATEMENT => x_PMV_Sql
			, P_SELECT_LIST =>
				' FACT.COST  "PJI_REP_MSR_1"
				, FACT.PY_COST  "PJI_REP_MSR_2"
				, FACT.CST_CHANGE_PERCENT  "PJI_REP_MSR_3"
				, FACT.COST  "PJI_REP_MSR_4" '
            , P_PMV_OUTPUT => x_PMV_Output
            , P_REGION_CODE => 'PJI_REP_PP7'
            , P_PLSQL_DRIVER => 'PJI_PMV_PROFITABILITY_TREND.PLSQLDriver_PJI_REP_PP5'
            , P_PLSQL_DRIVER_PARAMS => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
			  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
			  ', <<CURRENCY+FII_CURRENCIES>>'||
			  ', <<AS_OF_DATE>>'||
			  ', <<PERIOD_TYPE>>'||
			  ', <<VIEW_BY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CODE>>'||
			  ', NULL'||
                                  ', <<PROJECT EXPENDITURE TYPE+PJI_EXP_CATEGORIES>>'||
                                  ', <<PROJECT EXPENDITURE TYPE+PJI_EXP_TYPES>>'||
                                  ', NULL'||
                                  ', NULL'||
                                  ', <<PROJECT WORK TYPE+PJI_WORK_TYPES>> '
                   );
END Get_SQL_PJI_REP_PP7;

/*
** ----------------------------------------------------------
** Procedure: Get_SQL_PJI_REP_PP8
** This procedure returns sql statement generated by the base
** engine api and view by as a out parameter for the report
** PJI_REP_PP8.
** ----------------------------------------------------------
*/
PROCEDURE Get_SQL_PJI_REP_PP8(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
l_PMV_Rec			BIS_QUERY_ATTRIBUTES;
BEGIN
    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
            , P_SQL_STATEMENT => x_PMV_Sql
			, P_SELECT_LIST =>
				' FACT.COST  "PJI_REP_MSR_1"
				, FACT.PY_COST  "PJI_REP_MSR_2"
				, FACT.CST_CHANGE_PERCENT  "PJI_REP_MSR_3"
				, FACT.COST  "PJI_REP_MSR_4" '
            , P_PMV_OUTPUT => x_PMV_Output
            , P_REGION_CODE => 'PJI_REP_PP8'
            , P_PLSQL_DRIVER => 'PJI_PMV_PROFITABILITY_TREND.PLSQLDriver_PJI_REP_PP5'
            , P_PLSQL_DRIVER_PARAMS => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
			  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
			  ', <<CURRENCY+FII_CURRENCIES>>'||
			  ', <<AS_OF_DATE>>'||
			  ', <<PERIOD_TYPE>>'||
			  ', <<VIEW_BY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CODE>>'||
			  ', :PJI_EXTRA_BND_01'||
                                  ', <<PROJECT EXPENDITURE TYPE+PJI_EXP_CATEGORIES>>'||
                                  ', <<PROJECT EXPENDITURE TYPE+PJI_EXP_TYPES>>'||
                                  ', NULL'||
                                  ', NULL'||
                                  ', <<PROJECT WORK TYPE+PJI_WORK_TYPES>> '
                      );

	l_PMV_Rec:=BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
	l_PMV_Rec.attribute_name:=':PJI_EXTRA_BND_01';
	l_PMV_Rec.attribute_value:='FISCAL';
	l_PMV_Rec.attribute_type:=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	l_PMV_Rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

	x_PMV_Output.EXTEND();
	x_PMV_Output(x_PMV_Output.COUNT):=l_PMV_Rec;
END Get_SQL_PJI_REP_PP8;

/*
** ----------------------------------------------------------
** Function: PLSQLDriver_PJI_REP_PP5
** This table function is called from select statement
** generated by PJI engine. The function returns pl/sql table
** of records which have to be displayed in the pmv report.
** Following are the reports to which this function caters:
** 1. PJI_REP_PP5 - Project Profitability Trend
** 2. PJI_REP_PP6 - Project Profitability Cumulative Trend
** 3. PJI_REP_PP7 - Project Cost Trend
** 4. PJI_REP_PP8 - Project Cost Cumulative Trend
** ----------------------------------------------------------
*/
FUNCTION PLSQLDriver_PJI_REP_PP5(
  p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
, p_Organization			IN VARCHAR2
, p_Currency_Type			IN VARCHAR2
, p_As_Of_Date			IN NUMBER
, p_Period_Type 			IN VARCHAR2
, p_View_BY 			IN VARCHAR2
, p_Classifications		IN VARCHAR2 DEFAULT NULL
, p_Class_Codes			IN VARCHAR2 DEFAULT NULL
, p_Report_Type			IN VARCHAR2 DEFAULT NULL

, p_Expenditure_Category        IN VARCHAR2 DEFAULT NULL
, p_Expenditure_Type            IN VARCHAR2 DEFAULT NULL
, p_Revenue_Category            IN VARCHAR2 DEFAULT NULL
, p_Revenue_Type                IN VARCHAR2 DEFAULT NULL
, p_Work_Type                   IN VARCHAR2 DEFAULT NULL

)RETURN PJI_REP_PP5_TBL
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_Total_Prj_Profitablity_Tab	PJI_REP_PP5_TBL:=PJI_REP_PP5_TBL();
l_Parse_Class_Codes		VARCHAR2(1);
l_Report_Cost_Type		VARCHAR2(2);

l_Revenue			NUMBER:=0;
l_Cost			NUMBER:=0;
l_Margin			NUMBER:=0;
l_Margin_Percent		NUMBER:=0;

l_PY_Revenue		NUMBER:=0;
l_PY_Cost			NUMBER:=0;
l_PY_Margin			NUMBER:=0;
l_PY_Margin_Percent 	NUMBER:=0;

l_Rev_Change_Percent	NUMBER:=0;
l_Cst_Change_Percent	NUMBER:=0;
l_Mar_Change_Percent	NUMBER:=0;

l_Total_Revenue		NUMBER:=0;
l_Total_Cost		NUMBER:=0;
l_Total_Margin		NUMBER:=0;

l_Total_PY_Revenue	NUMBER:=0;
l_Total_PY_Cost		NUMBER:=0;
l_Total_PY_Margin		NUMBER:=0;

l_Top_Organization_Name		VARCHAR2(240);

l_Convert_Classification        VARCHAR2(1);
l_Convert_Expenditure_Type      VARCHAR2(1);
l_Convert_Event_Revenue_Type    VARCHAR2(1);
l_Convert_Work_Type             VARCHAR2(1);

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
	PJI_PMV_ENGINE.Convert_Time(p_As_Of_Date=>p_As_Of_Date, p_Period_Type=>p_Period_Type, p_View_BY=>p_View_BY, p_Parse_Prior=>'Y',p_Report_Type=>p_Report_Type);

      l_Convert_Classification := PJI_PMV_ENGINE.Convert_Classification(p_Classifications, p_Class_Codes, p_View_BY);
      l_Convert_Expenditure_Type := PJI_PMV_ENGINE.Convert_Expenditure_Type(p_Expenditure_Category, p_Expenditure_Type, p_View_BY);
      l_Convert_Event_Revenue_Type := PJI_PMV_ENGINE.Convert_Event_Revenue_Type(p_Revenue_Category, p_Revenue_Type, p_View_BY );
      l_Convert_Work_Type := PJI_PMV_ENGINE.Convert_Work_Type(p_Work_Type, p_View_BY);
      l_curr_record_type_id:=PJI_PMV_ENGINE.Convert_Currency_Record_Type(p_Currency_Type);

	/*
	** Determine the fact tables you choose to run the database
	** query on ( this step is what we call manual query re-write).
	*/


		/*
		** Code the SQL statement for all of the following conditions
		** 1. Current Year
		** 2. Prior Year
		** 3. SQL to generate rows with zero's for the view by dimension
		** Bulk-Collect the output into a pl/sql table to be returned to
		** pmv.
		*/

/*
** ORG Processing ---------------------------------------------------+
*/


/* ----------------------------- Case 1 truth table ------------------------------------ */

        IF (l_Convert_Classification = 'N')
         and (l_Convert_Expenditure_Type = 'N')
         and (l_Convert_Event_Revenue_Type = 'N')
         and (l_Convert_Work_Type = 'N')
          THEN


		SELECT PJI_REP_PP5(
		  TIME_ID
		, SUM( REVENUE )
		, SUM( COST )
		, SUM( REVENUE-COST )
		, SUM( PY_REVENUE )
		, SUM( PY_COST )
		, SUM( PY_REVENUE-PY_COST )
		, 0, 0, 0, 0, 0)
		BULK COLLECT INTO l_Total_Prj_Profitablity_Tab
		FROM (
			 SELECT /*+ ORDERED */
				  TIME.name time_id
				 , TIME.order_by_id   time_key
				 , revenue revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_fp_orgo_f_mv FCT
				 , pji_pmv_org_dim_tmp HOU
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
				 , 0 revenue
				 , 0 cost
				 , revenue  py_revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_fp_orgo_f_mv FCT
				 , pji_pmv_org_dim_tmp HOU
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
				 , 0 revenue
				 , 0 cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;

/*
** -- PROJECT CLASSIFICATION Processing ---------------------------------------------------+
*/


/* -----------------------------------  Case 2 truth table   -------------------------------------  */

        ELSIF (l_Convert_Expenditure_Type = 'N')
         and (l_Convert_Event_Revenue_Type = 'N')
         and (l_Convert_Work_Type = 'N')

          THEN


		SELECT PJI_REP_PP5(
		  TIME_ID
		, SUM( REVENUE )
		, SUM( COST )
		, SUM( REVENUE-COST )
		, SUM( PY_REVENUE )
		, SUM( PY_COST )
		, SUM( PY_REVENUE-PY_COST )
		, 0, 0, 0, 0, 0)
		BULK COLLECT INTO l_Total_Prj_Profitablity_Tab
		FROM (
			 SELECT /*+ ORDERED */
				  TIME.name time_id
				 , TIME.order_by_id   time_key
				 , revenue revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_pmv_cls_dim_tmp CLS
				 , pji_fp_clso_f_mv FCT
				 , pji_pmv_org_dim_tmp HOU
			 WHERE
				 FCT.project_org_id = HOU.id
				 AND FCT.project_organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                                 AND FCT.calendar_type = TIME.calendar_type
				 AND FCT.project_class_id = CLS.id
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 revenue
				 , 0 cost
				 , revenue  py_revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_pmv_cls_dim_tmp CLS
				 , pji_fp_clso_f_mv FCT
				 , pji_pmv_org_dim_tmp HOU
			 WHERE
				 FCT.project_org_id = HOU.id
				 AND FCT.project_organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                                 AND FCT.calendar_type = TIME.calendar_type
				 AND FCT.project_class_id = CLS.id
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 revenue
				 , 0 cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;

/*
** Expenditure or Revenue Type Processing ---------------------------------------------------+
*/

/* -----------------------------------  Case 3 truth table   -------------------------------------  */

        ELSIF (l_Convert_Classification = 'N')
         and (l_Convert_Work_Type = 'N')
          THEN
		SELECT PJI_REP_PP5(
		  TIME_ID
		, SUM( REVENUE )
		, SUM( COST )
		, SUM( REVENUE-COST )
		, SUM( PY_REVENUE )
		, SUM( PY_COST )
		, SUM( PY_REVENUE-PY_COST )
		, 0, 0, 0, 0, 0)
		BULK COLLECT INTO l_Total_Prj_Profitablity_Tab
		FROM (
			 SELECT /*+ ORDERED */
				  TIME.name time_id
				 , TIME.order_by_id   time_key
				 , revenue revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_pmv_et_rt_dim_tmp ET
				 , PJI_FP_ORGO_ET_F_MV FCT
				 , pji_pmv_org_dim_tmp HOU
			 WHERE
				 FCT.org_id = HOU.id
				 AND FCT.organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                                 AND FCT.calendar_type = TIME.calendar_type
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')

				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 revenue
				 , 0 cost
				 , revenue  py_revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_pmv_et_rt_dim_tmp ET
				 , PJI_FP_ORGO_ET_F_MV FCT
				 , pji_pmv_org_dim_tmp HOU
			 WHERE
				 FCT.org_id = HOU.id
				 AND FCT.organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                                 AND FCT.calendar_type = TIME.calendar_type
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 revenue
				 , 0 cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;

/*
**  Work Type Processing ---------------------------------------------------+
*/

/* -----------------------------------  Case 4 truth table   -------------------------------------  */

        ELSIF (l_Convert_Classification = 'N')
         and  (l_Convert_Expenditure_Type = 'N')
         and  (l_Convert_Event_Revenue_Type = 'N')
          THEN
		SELECT PJI_REP_PP5(
		  TIME_ID
		, SUM( REVENUE )
		, SUM( COST )
		, SUM( REVENUE-COST )
		, SUM( PY_REVENUE )
		, SUM( PY_COST )
		, SUM( PY_REVENUE-PY_COST )
		, 0, 0, 0, 0, 0)
		BULK COLLECT INTO l_Total_Prj_Profitablity_Tab
		FROM (
			 SELECT /*+ ORDERED */
				  TIME.name time_id
				 , TIME.order_by_id   time_key
				 , null revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_pmv_wt_dim_tmp WT
				 , PJI_FP_ORGO_ET_WT_F_MV FCT
				 , pji_pmv_org_dim_tmp HOU
			 WHERE
				 FCT.org_id = HOU.id
				 AND FCT.organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                                 AND FCT.calendar_type = TIME.calendar_type
				 AND FCT.work_type_id = WT.id
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 revenue
				 , 0 cost
				 , null  py_revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_pmv_wt_dim_tmp WT
				 , PJI_FP_ORGO_ET_WT_F_MV FCT
				 , pji_pmv_org_dim_tmp HOU
			 WHERE
				 FCT.org_id = HOU.id
				 AND FCT.organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                                 AND FCT.calendar_type = TIME.calendar_type
				 AND FCT.work_type_id = WT.id
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 revenue
				 , 0 cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;

/*
** Project classification and Expenditure or Revenue Type Processing ---------------------------------+
*/

/* -----------------------------------  Case 5 truth table   -------------------------------------  */

        ELSIF (l_Convert_Work_Type = 'N')
          THEN
		SELECT PJI_REP_PP5(
		  TIME_ID
		, SUM( REVENUE )
		, SUM( COST )
		, SUM( REVENUE-COST )
		, SUM( PY_REVENUE )
		, SUM( PY_COST )
		, SUM( PY_REVENUE-PY_COST )
		, 0, 0, 0, 0, 0)
		BULK COLLECT INTO l_Total_Prj_Profitablity_Tab
		FROM (
			 SELECT /*+ ORDERED */
				  TIME.name time_id
				 , TIME.order_by_id   time_key
				 , revenue revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_pmv_cls_dim_tmp CLS
				 , pji_pmv_et_rt_dim_tmp ET
				 , PJI_FP_CLSO_ET_F_MV FCT
				 , pji_pmv_org_dim_tmp HOU
			 WHERE
				 FCT.project_org_id = HOU.id
				 AND FCT.project_organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                                 AND FCT.calendar_type = TIME.calendar_type
				 AND FCT.project_class_id = CLS.id
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 revenue
				 , 0 cost
				 , revenue  py_revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_pmv_cls_dim_tmp CLS
				 , pji_pmv_et_rt_dim_tmp ET
				 , PJI_FP_CLSO_ET_F_MV FCT
				 , pji_pmv_org_dim_tmp HOU
			 WHERE
				 FCT.project_org_id = HOU.id
				 AND FCT.project_organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                                 AND FCT.calendar_type = TIME.calendar_type
				 AND FCT.project_class_id = CLS.id
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 revenue
				 , 0 cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;

/*
** Expenditure or Revenue Type and Work Type Processing -----------------------------------------+
*/

/* -----------------------------------  Case 6 truth table   -------------------------------------  */

        ELSIF (l_Convert_Classification = 'N')
          THEN

		SELECT PJI_REP_PP5(
		  TIME_ID
		, SUM( REVENUE )
		, SUM( COST )
		, SUM( REVENUE-COST )
		, SUM( PY_REVENUE )
		, SUM( PY_COST )
		, SUM( PY_REVENUE-PY_COST )
		, 0, 0, 0, 0, 0)
		BULK COLLECT INTO l_Total_Prj_Profitablity_Tab
		FROM (
			 SELECT /*+ ORDERED */
				  TIME.name time_id
				 , TIME.order_by_id   time_key
				 , null revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_pmv_et_rt_dim_tmp ET
				 , pji_pmv_wt_dim_tmp WT
				 , PJI_FP_ORGO_ET_WT_F_MV FCT
				 , pji_pmv_org_dim_tmp HOU
			 WHERE
				 FCT.org_id = HOU.id
				 AND FCT.organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                                 AND FCT.calendar_type = TIME.calendar_type
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
				AND FCT.WORK_TYPE_ID = WT.ID
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 revenue
				 , 0 cost
				 , null  py_revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_pmv_et_rt_dim_tmp ET
				 , pji_pmv_wt_dim_tmp WT
				 , PJI_FP_ORGO_ET_WT_F_MV FCT
				 , pji_pmv_org_dim_tmp HOU
			 WHERE
				 FCT.org_id = HOU.id
				 AND FCT.organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                                 AND FCT.calendar_type = TIME.calendar_type
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
				AND FCT.WORK_TYPE_ID = WT.ID
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 revenue
				 , 0 cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;

/*
**  Project classification and Work Type Processing -----------------------------------------------+
*/

/* -----------------------------------  Case 7 truth table   -------------------------------------  */

        ELSIF (l_Convert_Expenditure_Type = 'N')
          and (l_Convert_Event_Revenue_Type = 'N')
          THEN

		SELECT PJI_REP_PP5(
		  TIME_ID
		, SUM( REVENUE )
		, SUM( COST )
		, SUM( REVENUE-COST )
		, SUM( PY_REVENUE )
		, SUM( PY_COST )
		, SUM( PY_REVENUE-PY_COST )
		, 0, 0, 0, 0, 0)
		BULK COLLECT INTO l_Total_Prj_Profitablity_Tab
		FROM (
			 SELECT /*+ ORDERED */
				  TIME.name time_id
				 , TIME.order_by_id   time_key
				 , null revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_pmv_cls_dim_tmp CLS
				 , pji_pmv_wt_dim_tmp WT
				 , PJI_FP_CLSO_ET_WT_F_MV FCT
				 , pji_pmv_org_dim_tmp HOU
			 WHERE
				 FCT.project_org_id = HOU.id
				 AND FCT.project_organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                                 AND FCT.calendar_type = TIME.calendar_type
				 AND FCT.project_class_id = CLS.id
				AND FCT.WORK_TYPE_ID = WT.ID
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 revenue
				 , 0 cost
				 , null  py_revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_pmv_cls_dim_tmp CLS
				 , pji_pmv_wt_dim_tmp WT
				 , PJI_FP_CLSO_ET_WT_F_MV FCT
				 , pji_pmv_org_dim_tmp HOU
			 WHERE
				 FCT.project_org_id = HOU.id
				 AND FCT.project_organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                                 AND FCT.calendar_type = TIME.calendar_type
				 AND FCT.project_class_id = CLS.id
				AND FCT.WORK_TYPE_ID = WT.ID
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 revenue
				 , 0 cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;

/*
** Project classification and Expenditure or Revenue Type and Work Type Processing ----------------+
*/

/* -----------------------------------  Case 8 truth table   -------------------------------------  */

        ELSE
		SELECT PJI_REP_PP5(
		  TIME_ID
		, SUM( REVENUE )
		, SUM( COST )
		, SUM( REVENUE-COST )
		, SUM( PY_REVENUE )
		, SUM( PY_COST )
		, SUM( PY_REVENUE-PY_COST )
		, 0, 0, 0, 0, 0)
		BULK COLLECT INTO l_Total_Prj_Profitablity_Tab
		FROM (
			 SELECT /*+ ORDERED */
				  TIME.name time_id
				 , TIME.order_by_id   time_key
				 , null revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_pmv_cls_dim_tmp CLS
				 , pji_pmv_et_rt_dim_tmp ET
				 , pji_pmv_wt_dim_tmp WT
				 , PJI_FP_CLSO_ET_WT_F_MV FCT
				 , pji_pmv_org_dim_tmp HOU
			 WHERE
				 FCT.project_org_id = HOU.id
				 AND FCT.project_organization_id = HORG.id
				 AND FCT.time_id = TIME.id
				 AND TIME.id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                                 AND FCT.calendar_type = TIME.calendar_type
				 AND FCT.project_class_id = CLS.id
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
				AND FCT.WORK_TYPE_ID = WT.ID
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 revenue
				 , 0 cost
				 , null  py_revenue
				 , DECODE(l_Report_Cost_Type,'RC', raw_cost,'BC', burdened_cost) py_cost
			 FROM
				   pji_pmv_time_dim_tmp TIME
				 , pji_pmv_orgz_dim_tmp HORG
				 , pji_pmv_cls_dim_tmp CLS
				 , pji_pmv_et_rt_dim_tmp ET
				 , pji_pmv_wt_dim_tmp WT
				 , PJI_FP_CLSO_ET_WT_F_MV FCT
				 , pji_pmv_org_dim_tmp HOU
			 WHERE
				 FCT.project_org_id = HOU.id
				 AND FCT.project_organization_id = HORG.id
				 AND FCT.time_id = TIME.prior_id
				 AND TIME.prior_id IS NOT NULL
				 AND FCT.period_type_id = TIME.period_type
                                 AND FCT.calendar_type = TIME.calendar_type
				 AND FCT.project_class_id = CLS.id
				AND FCT.EXP_EVT_TYPE_ID = ET.ID
                                AND ET.record_type = decode(l_Convert_Expenditure_Type,'Y','ET',l_Convert_Event_Revenue_Type,'Y','RT')
				AND FCT.WORK_TYPE_ID = WT.ID
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 UNION ALL
			 SELECT
				 name		    time_id
				 , order_by_id	time_key
				 , 0 revenue
				 , 0 cost
				 , 0 py_revenue
				 , 0 py_cost
			 FROM pji_pmv_time_dim_tmp
			 WHERE name <> '-1')
		 GROUP BY
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;


	END IF;

	FOR i in 1..l_Total_Prj_Profitablity_Tab.COUNT
	LOOP
		IF p_Report_Type = 'FISCAL' THEN
			l_Revenue:=l_Revenue+l_Total_Prj_Profitablity_Tab(i).REVENUE;
			l_Cost:=l_Cost+l_Total_Prj_Profitablity_Tab(i).COST;
			l_Margin:=l_Margin+l_Total_Prj_Profitablity_Tab(i).MARGIN;
			l_PY_Revenue:=l_PY_Revenue+l_Total_Prj_Profitablity_Tab(i).PY_REVENUE;
			l_PY_Cost:=l_PY_Cost+l_Total_Prj_Profitablity_Tab(i).PY_COST;
			l_PY_Margin:=l_PY_Margin+l_Total_Prj_Profitablity_Tab(i).PY_MARGIN;

			l_Total_Prj_Profitablity_Tab(i).REVENUE:=l_Revenue;
			l_Total_Prj_Profitablity_Tab(i).COST:=l_Cost;
			l_Total_Prj_Profitablity_Tab(i).MARGIN:=l_Margin;
			l_Total_Prj_Profitablity_Tab(i).PY_REVENUE:=l_PY_Revenue;
			l_Total_Prj_Profitablity_Tab(i).PY_COST:=l_PY_Cost;
			l_Total_Prj_Profitablity_Tab(i).PY_MARGIN:=l_PY_Margin;
		END IF;

		IF NVL(l_Total_Prj_Profitablity_Tab(i).REVENUE,0) <> 0 THEN
			l_Total_Prj_Profitablity_Tab(i).MARGIN_PERCENT := 100*
			(l_Total_Prj_Profitablity_Tab(i).MARGIN/l_Total_Prj_Profitablity_Tab(i).REVENUE);
		ELSE
			l_Total_Prj_Profitablity_Tab(i).MARGIN_PERCENT := NULL;
		END IF;
		IF NVL(l_Total_Prj_Profitablity_Tab(i).PY_REVENUE,0) <> 0 THEN
		l_Total_Prj_Profitablity_Tab(i).PY_MARGIN_PERCENT := 100*
			(l_Total_Prj_Profitablity_Tab(i).PY_MARGIN/l_Total_Prj_Profitablity_Tab(i).PY_REVENUE);
				l_Total_Prj_Profitablity_Tab(i).REV_CHANGE_PERCENT := 100*
			((l_Total_Prj_Profitablity_Tab(i).REVENUE-l_Total_Prj_Profitablity_Tab(i).PY_REVENUE)
			/ABS(l_Total_Prj_Profitablity_Tab(i).PY_REVENUE));
		ELSE
			l_Total_Prj_Profitablity_Tab(i).PY_MARGIN_PERCENT := NULL;
			l_Total_Prj_Profitablity_Tab(i).REV_CHANGE_PERCENT := NULL;
		END IF;
		IF NVL(l_Total_Prj_Profitablity_Tab(i).PY_COST,0) <> 0 THEN
			l_Total_Prj_Profitablity_Tab(i).CST_CHANGE_PERCENT := 100*
			((l_Total_Prj_Profitablity_Tab(i).COST-l_Total_Prj_Profitablity_Tab(i).PY_COST)
			/ABS(l_Total_Prj_Profitablity_Tab(i).PY_COST));
		ELSE
			l_Total_Prj_Profitablity_Tab(i).CST_CHANGE_PERCENT := NULL;
		END IF;

		l_Total_Prj_Profitablity_Tab(i).MAR_CHANGE_PERCENT :=
		l_Total_Prj_Profitablity_Tab(i).MARGIN_PERCENT-l_Total_Prj_Profitablity_Tab(i).PY_MARGIN_PERCENT;

		/*
		** The below portion of the code is commented
		** because the trend reports donot have totals.
		*/
		/*
		l_Total_Revenue := l_Total_Revenue + NVL(l_Total_Prj_Profitablity_Tab(i).REVENUE, 0);
		l_Total_Cost := l_Total_Cost + NVL(l_Total_Prj_Profitablity_Tab(i).COST, 0);
		l_Total_Margin := l_Total_Margin + NVL(l_Total_Prj_Profitablity_Tab(i).MARGIN, 0);
		l_Total_PY_Revenue := l_Total_PY_Revenue + NVL(l_Total_Prj_Profitablity_Tab(i).PY_REVENUE, 0);
		l_Total_PY_Cost := l_Total_PY_Cost + NVL(l_Total_Prj_Profitablity_Tab(i).PY_COST, 0);
		l_Total_PY_Margin := l_Total_PY_Margin + NVL(l_Total_Prj_Profitablity_Tab(i).PY_MARGIN, 0);
		*/
	END LOOP;

	/*
	** Return the bulk collected table back to pmv.
	*/

	COMMIT;
	RETURN l_Total_Prj_Profitablity_Tab;

END PLSQLDriver_PJI_REP_PP5;



END PJI_PMV_PROFITABILITY_TREND;

/