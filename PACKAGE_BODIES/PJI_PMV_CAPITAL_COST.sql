--------------------------------------------------------
--  DDL for Package Body PJI_PMV_CAPITAL_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PMV_CAPITAL_COST" as
/* $Header: PJIRF07B.pls 120.7.12010000.3 2009/05/08 09:56:00 paljain ship $ */

G_Report_Cost_Type VARCHAR2(2);

/*
*********************************
** Capital Projects Cost Summary
*********************************
*/

procedure GET_SQL_PJI_REP_PC6(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL
		            , x_PMV_Sql out nocopy VARCHAR2
       	            , x_PMV_Output out nocopy BIS_QUERY_ATTRIBUTES_TBL)
	is
	l_Err_Message   VARCHAR2(3200);
	l_PMV_Sql       VARCHAR2(3200);
begin

  PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
 , P_SELECT_LIST =>
          'FACT.COST "PJI_REP_MSR_1" , FACT.COST "PJI_REP_MSR_19"
          , FACT.CT_COST "PJI_REP_MSR_2" , FACT.COST_CHANGE_PRCNT "PJI_REP_MSR_3"
          , FACT.CAP_COST "PJI_REP_MSR_4" , FACT.CAP_COST "PJI_REP_MSR_20"
          , FACT.CT_CAP_COST "PJI_REP_MSR_5" , FACT.CAP_COST_CHANGE_PRCNT "PJI_REP_MSR_6"
          , FACT.PRCNT_OF_COST "PJI_REP_MSR_7" , FACT.PRCNT_OF_COST "PJI_REP_MSR_21"
          , FACT.CT_PRCNT_OF_COST "PJI_REP_MSR_8" , FACT.PRCNT_OF_COST_CHANGE "PJI_REP_MSR_9"
          , FACT.EXPENSE "PJI_REP_MSR_10" , FACT.EXPENSE "PJI_REP_MSR_22"
          , FACT.CT_EXPENSE "PJI_REP_MSR_11" , FACT.EXPENSE_CHANGE_PRCNT "PJI_REP_MSR_12"
          , FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1" , FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_2"
          , FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_3" , FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_4"
          , FACT.PJI_REP_TOTAL_5 "PJI_REP_TOTAL_5" , FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_6"
          , FACT.PJI_REP_TOTAL_7 "PJI_REP_TOTAL_7" , FACT.PJI_REP_TOTAL_8 "PJI_REP_TOTAL_8"
          , FACT.PJI_REP_TOTAL_9 "PJI_REP_TOTAL_9" , FACT.PJI_REP_TOTAL_10 "PJI_REP_TOTAL_10"
          , FACT.PJI_REP_TOTAL_11 "PJI_REP_TOTAL_11" , FACT.PJI_REP_TOTAL_12 "PJI_REP_TOTAL_12"
          , FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_16"
          , FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_17"
          , FACT.PJI_REP_TOTAL_7 "PJI_REP_TOTAL_18"'
           		, P_SQL_STATEMENT => x_PMV_Sql
           		, P_PMV_OUTPUT => x_PMV_Output
				, p_Region_Code =>  'PJI_REP_PC6'
				, p_PLSQL_Driver => 'PJI_PMV_CAPITAL_COST.PLSQLDriver_PJI_REP_PC6'
				, p_PLSQL_Driver_Params =>
                  ' <<ORGANIZATION+FII_OPERATING_UNITS>>'||
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
end GET_SQL_PJI_REP_PC6;

/*
*******************************
**  Capital Project Cost Trend
*******************************
*/


procedure Get_SQL_PJI_REP_PC7 (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql    out nocopy VARCHAR2
                    , x_PMV_Output out nocopy BIS_QUERY_ATTRIBUTES_TBL)
is
begin
    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl
            , P_SQL_STATEMENT => x_PMV_Sql
			, P_SELECT_LIST =>       'FACT.COST                     "PJI_REP_MSR_1"
                                    , FACT.COST                     "PJI_REP_MSR_19"
                                    , FACT.CT_COST                  "PJI_REP_MSR_2"
                                    , FACT.CT_COST                  "PJI_REP_MSR_20"
                                    , FACT.COST_CHANGE_PRCNT        "PJI_REP_MSR_3"
                                    , FACT.CAP_COST                 "PJI_REP_MSR_4"
                                    , FACT.CAP_COST                 "PJI_REP_MSR_21"
                                    , FACT.CT_CAP_COST              "PJI_REP_MSR_5"
                                    , FACT.CT_CAP_COST              "PJI_REP_MSR_22"
                                    , FACT.CAP_COST_CHANGE_PRCNT    "PJI_REP_MSR_6"
                                    , FACT.PRCNT_OF_COST            "PJI_REP_MSR_7"
                                    , FACT.CT_PRCNT_OF_COST         "PJI_REP_MSR_8"
                                    , FACT.PRCNT_OF_COST_CHANGE     "PJI_REP_MSR_9"
                                    , FACT.EXPENSE                  "PJI_REP_MSR_10"
				, FACT.EXPENSE                  "PJI_REP_MSR_24"
                                    , FACT.CT_EXPENSE               "PJI_REP_MSR_11"
				, FACT.CT_EXPENSE               "PJI_REP_MSR_25"
                                    , FACT.EXPENSE_CHANGE_PRCNT     "PJI_REP_MSR_12" '
                                , P_PMV_OUTPUT => x_PMV_Output
            , P_REGION_CODE  => 'PJI_REP_PC7'
            , P_PLSQL_DRIVER => 'PJI_PMV_CAPITAL_COST.PLSQLDriver_PJI_REP_PC7'
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
              ', NULL');
end Get_SQL_PJI_REP_PC7;

/*
**  Capital Project Cost Cumulative Trend
*/


PROCEDURE Get_SQL_PJI_REP_PC8(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY VARCHAR2
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
                , FACT.CAP_COST                 "PJI_REP_MSR_4"
                , FACT.CAP_COST                 "PJI_REP_MSR_21"
                , FACT.CT_CAP_COST              "PJI_REP_MSR_5"
                , FACT.CT_CAP_COST              "PJI_REP_MSR_22"
                , FACT.CAP_COST_CHANGE_PRCNT    "PJI_REP_MSR_6"
                , FACT.PRCNT_OF_COST            "PJI_REP_MSR_7"
                , FACT.CT_PRCNT_OF_COST         "PJI_REP_MSR_8"
                , FACT.PRCNT_OF_COST_CHANGE     "PJI_REP_MSR_9"
                , FACT.EXPENSE                  "PJI_REP_MSR_10"
		, FACT.EXPENSE                  "PJI_REP_MSR_24"
                , FACT.CT_EXPENSE               "PJI_REP_MSR_11"
		, FACT.CT_EXPENSE               "PJI_REP_MSR_25"
                , FACT.EXPENSE_CHANGE_PRCNT     "PJI_REP_MSR_12" '
            , P_SQL_STATEMENT => x_PMV_Sql
            , P_PMV_OUTPUT => x_PMV_Output
			, P_REGION_CODE => 'PJI_REP_PC8'
			, P_PLSQL_DRIVER => 'PJI_PMV_CAPITAL_COST.PLSQLDriver_PJI_REP_PC7'
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
              ', NULL');

	l_PMV_Rec:=BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
	l_PMV_Rec.attribute_name:=':PJI_EXTRA_BND_01';
	l_PMV_Rec.attribute_value:='FISCAL';
	l_PMV_Rec.attribute_type:=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	l_PMV_Rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

	x_PMV_Output.EXTEND();
	x_PMV_Output(x_PMV_Output.COUNT):=l_PMV_Rec;

END Get_SQL_PJI_REP_PC8;

/*
** Projects Capital Cost Detail Report
*/


PROCEDURE GET_SQL_PJI_REP_PC9(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
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
				  , FACT.URL_PARAMETERS01       "PJI_REP_MSR_20"
                                  , FACT.URL_PARAMETERS01       "PJI_REP_MSR_30"
				  , FACT.PRIMARY_CUSTOMER_NAME  "PJI_REP_MSR_3"
				  , FACT.PROJECT_TYPE           "PJI_REP_MSR_4"
				  , FACT.ORGANIZATION_NAME      "PJI_REP_MSR_5"
				  , FACT.PERSON_MANAGER_NAME    "PJI_REP_MSR_6"
				  , FACT.COST                   "PJI_REP_MSR_8"
				  , FACT.CAPITAL_COST              "PJI_REP_MSR_16"
				  , FACT.CAP_COST_PERCENT_OF_COST  "PJI_REP_MSR_17"
				  , FACT.EXPENSE                   "PJI_REP_MSR_12"
				  , FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1"
				  , FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_2"
				  , FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_3"
				  , FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_4"'
            		, P_SQL_STATEMENT => x_PMV_Sql
	           		, P_PMV_OUTPUT => x_PMV_Output
				, p_Region_Code => 'PJI_REP_PC9'
				, p_PLSQL_Driver => 'PJI_PMV_CAPITAL_COST.PLSQLDriver_PJI_REP_PC9'
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
END GET_SQL_PJI_REP_PC9;


/* -------------------------------------------------------------+
** -- PLSQL DRIVERS
*/ -------------------------------------------------------------+


function  PLSQLDriver_PJI_REP_PC6(
           p_Operating_Unit		in VARCHAR2 default null
         , p_Organization		in VARCHAR2
         , p_Currency_Type		in VARCHAR2
         , p_As_of_Date         in NUMBER
         , p_Time_Comparison_Type       in VARCHAR2
         , p_Period_Type 		in VARCHAR2
         , p_View_BY 			in VARCHAR2
         , p_Classifications	in VARCHAR2 default null
         , p_Class_Codes		in VARCHAR2 default null
         , p_Expenditure_Category   IN VARCHAR2 DEFAULT NULL
         , p_Expenditure_Type       IN VARCHAR2 DEFAULT NULL
         , p_Work_Type              IN VARCHAR2 DEFAULT NULL
         )  return PJI_REP_PC6_TBL
	is

 pragma autonomous_transaction;

/*
**  -- Local Variable Declaration
*/

l_Cost                    NUMBER:=0;
l_CT_Cost                 NUMBER:=0;
l_Cost_Change_Prcnt       NUMBER:=0;
l_Cap_Cost                NUMBER:=0;
l_CT_Cap_Cost             NUMBER:=0;
l_Cap_Cost_Change_Prcnt   NUMBER:=0;
l_Prcnt_Of_Cost           NUMBER:=0;
l_CT_Prcnt_Of_Cost        NUMBER:=0;
l_Prcnt_Of_Cost_Change    NUMBER:=0;
l_Expense                 NUMBER:=0;
l_CT_Expense              NUMBER:=0;
l_Expense_Change_Prcnt    NUMBER:=0;

l_TO_Cost                    NUMBER:=0;
l_TO_CT_Cost                 NUMBER:=0;
l_TO_Cost_Change_Prcnt       NUMBER:=0;
l_TO_Cap_Cost                NUMBER:=0;
l_TO_CT_Cap_Cost             NUMBER:=0;
l_TO_Cap_Cost_Change_Prcnt   NUMBER:=0;
l_TO_Prcnt_Of_Cost           NUMBER:=0;
l_TO_CT_Prcnt_Of_Cost        NUMBER:=0;
l_TO_Prcnt_Of_Cost_Change    NUMBER:=0;
l_TO_Expense                 NUMBER:=0;
l_TO_CT_Expense              NUMBER:=0;
l_TO_Expense_Change_Prcnt    NUMBER:=0;

l_Top_Org_Index			    NUMBER;
l_Top_Organization_Name		VARCHAR2(240);

l_Convert_Classification    VARCHAR2(1);
l_Convert_Expenditure_Type  VARCHAR2(1);
l_Convert_Work_Type         VARCHAR2(1);
l_curr_record_type_id       NUMBER:= 1;

/*
**        -- PL/SQL Declaration
*/
	l_lines_tab		PJI_REP_PC6_TBL := PJI_REP_PC6_TBL();


begin
    begin
	    select report_cost_type
		    into G_Report_Cost_Type
		    from pji_system_settings;
	    exception
	    when NO_DATA_FOUND then
	    	G_Report_Cost_Type:='RC';
    end;

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

PJI_PMV_ENGINE.Convert_Time(P_AS_OF_DATE    => p_As_of_Date
      	                                  , P_PERIOD_TYPE  => p_Period_Type
            	                          , P_VIEW_BY      => p_View_By
                  	                      , P_PARSE_PRIOR  => null
                        	              , P_REPORT_TYPE  => 'DBI'
                              	          , P_COMPARATOR   => p_Time_Comparison_Type
                                    	  , P_PARSE_ITD    => null
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

    select PJI_REP_PC6  ( ORG_ID
                        , ORGANIZATION_ID
                        , PROJECT_CLASS_ID
                        , EXPENDITURE_CATEGORY
                        , EXPENDITURE_TYPE_ID
                        , WORK_TYPE_ID
                        , SUM ( COST )
                        , SUM ( CT_COST )
                        , SUM ( COST_CHANGE_PRCNT )
                        , SUM ( CAP_COST )
                        , SUM ( CT_CAP_COST )
                        , SUM ( CAP_COST_CHANGE_PRCNT )
                        , SUM ( PRCNT_OF_COST )
                        , SUM ( CT_PRCNT_OF_COST )
                        , SUM ( PRCNT_OF_COST_CHANGE )
                        , SUM ( EXPENSE )
                        , SUM ( CT_EXPENSE )
                        , SUM ( EXPENSE_CHANGE_PRCNT )
                        , null,  null,  null,  null,  null, null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null,  null )
           bulk collect into l_lines_tab
           from
	      ( select /*+ ORDERED */
              HOU.NAME                 as ORG_ID
            , HORG.NAME                as ORGANIZATION_ID
            , '-1'                     as PROJECT_CLASS_ID
            , '-1'                     as EXPENDITURE_CATEGORY
            , '-1'                     as EXPENDITURE_TYPE_ID
            , '-1'                     as WORK_TYPE_ID
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,  'BC', FCT.CAPITAL_BRDN_COST,
                                              'RC', FCT.CAPITAL_RAW_COST),0)  as COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', FCT.CAPITALIZABLE_BRDN_COST,
                  'RC', FCT.CAPITALIZABLE_RAW_COST),0) CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                  'RC', NVL(FCT.CAPITAL_RAW_COST,0) -  NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE   --8301412
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
 	from
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_FP_ORGO_F_MV FCT
			, PJI_PMV_ORG_DIM_TMP HOU
    where
			FCT.ORG_ID = HOU.ID
		and FCT.ORGANIZATION_ID = HORG.ID
		and FCT.TIME_ID = TIME.ID
		and TIME.ID is not null
		and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
union all -- PRIOR Actuals
          select /*+ ORDERED */
              HOU.NAME                 as ORG_ID
            , HORG.NAME                as ORGANIZATION_ID
            , '-1'                     as PROJECT_CLASS_ID
            , '-1'                     as EXPENDITURE_CATEGORY
            , '-1'                     as EXPENDITURE_TYPE_ID
            , '-1'                     as WORK_TYPE_ID
            , 0   as COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITAL_BRDN_COST,
                 'RC', FCT.CAPITAL_RAW_COST),0)  as CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITALIZABLE_BRDN_COST,
                 'RC', FCT.CAPITALIZABLE_RAW_COST),0)  as CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                 'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0)  as CT_EXPENSE --8301412
            , 0 EXPENSE_CHANGE_PRCNT
		from
				PJI_PMV_TCMP_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_FP_ORGO_F_MV FCT
				, PJI_PMV_ORG_DIM_TMP HOU
		where
			    FCT.ORG_ID = HOU.ID
		    and FCT.ORGANIZATION_ID = HORG.ID
			and FCT.TIME_ID = TIME.ID
			and TIME.ID is not null
			and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
			AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
		union all -- FORCE Creation of Org rows
select        HOU.NAME          as ORG_ID
            , '-1'              as ORGANIZATION_ID
            , '-1'              as PROJECT_CLASS_ID
            , '-1'              as EXPENDITURE_CATEGORY
            , '-1'              as EXPENDITURE_TYPE_ID
            , '-1'              as WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from
         PJI_PMV_ORG_DIM_TMP HOU
		where    HOU.NAME <> '-1'
                union all  -- FORCE Creation of Organization Rows
select        '-1'                as ORG_ID
            , HORG.NAME           as ORGANIZATION_ID
            , '-1'                as PROJECT_CLASS_ID
            , '-1'              as EXPENDITURE_CATEGORY
            , '-1'              as EXPENDITURE_TYPE_ID
            , '-1'              as WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_ORGZ_DIM_TMP HORG
		where    HORG.NAME <> '-1'
                ) WHERE 1 = 1
            group by ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
                     EXPENDITURE_TYPE_ID, WORK_TYPE_ID;

/*
** ORGANIZATION AND CLASSIFICATION Processing:
** Only Organization and Classification is specified
*/

ELSIF
        l_Convert_Classification = 'Y'
  AND   l_Convert_Expenditure_Type = 'N'
  AND   l_Convert_Work_Type = 'N'
THEN
    select PJI_REP_PC6  ( ORG_ID
                        , ORGANIZATION_ID
                        , PROJECT_CLASS_ID
                        , EXPENDITURE_CATEGORY
                        , EXPENDITURE_TYPE_ID
                        , WORK_TYPE_ID
                        , SUM ( COST )
                        , SUM ( CT_COST )
                        , SUM ( COST_CHANGE_PRCNT )
                        , SUM ( CAP_COST )
                        , SUM ( CT_CAP_COST )
                        , SUM ( CAP_COST_CHANGE_PRCNT )
                        , SUM ( PRCNT_OF_COST )
                        , SUM ( CT_PRCNT_OF_COST )
                        , SUM ( PRCNT_OF_COST_CHANGE )
                        , SUM ( EXPENSE )
                        , SUM ( CT_EXPENSE )
                        , SUM ( EXPENSE_CHANGE_PRCNT )
                        , null,  null,  null,  null,  null, null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null,  null )
           bulk collect into l_lines_tab
           from
	      ( select /*+ ORDERED */
              HOU.NAME                 as ORG_ID
            , HORG.NAME                as ORGANIZATION_ID
            , CLS.NAME                 as PROJECT_CLASS_ID
            , '-1'                     AS EXPENDITURE_CATEGORY
            , '-1'                     AS EXPENDITURE_TYPE_ID
            , '-1'                     AS WORK_TYPE_ID
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,  'BC', FCT.CAPITAL_BRDN_COST,
                                              'RC', FCT.CAPITAL_RAW_COST),0)  as COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', FCT.CAPITALIZABLE_BRDN_COST,
                  'RC', FCT.CAPITALIZABLE_RAW_COST),0) CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                  'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE    --8301412
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
 	from
			  PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_CLS_DIM_TMP CLS
            , PJI_FP_CLSO_F_MV FCT
            , PJI_PMV_ORG_DIM_TMP HOU
		where
			fct.PROJECT_ORG_ID = HOU.ID
		and FCT.PROJECT_ORGANIZATION_ID = HORG.ID
		and FCT.TIME_ID = TIME.ID
		and TIME.ID is not null
		and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
        and FCT.PROJECT_CLASS_ID = CLS.ID
union all -- PRIOR Actuals
          select /*+ ORDERED */
              HOU.NAME                 as ORG_ID
            , HORG.NAME                as ORGANIZATION_ID
            , CLS.NAME                 as PROJECT_CLASS_ID
            , '-1'                     AS EXPENDITURE_CATEGORY
            , '-1'                     AS EXPENDITURE_TYPE_ID
            , '-1'                     AS WORK_TYPE_ID
            , 0   as COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITAL_BRDN_COST,
                 'RC', FCT.CAPITAL_RAW_COST),0)  as CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITALIZABLE_BRDN_COST,
                 'RC', FCT.CAPITALIZABLE_RAW_COST),0)  as CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                 'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0)  as CT_EXPENSE --8301412
            , 0 EXPENSE_CHANGE_PRCNT
		from
		PJI_PMV_TCMP_DIM_TMP TIME
		, PJI_PMV_ORGZ_DIM_TMP HORG
                , PJI_PMV_CLS_DIM_TMP CLS
                , PJI_FP_CLSO_F_MV FCT
                , PJI_PMV_ORG_DIM_TMP HOU
		where
			    FCT.PROJECT_ORG_ID = HOU.ID
			and FCT.PROJECT_ORGANIZATION_ID = HORG.ID
			and FCT.TIME_ID = TIME.ID
			and TIME.ID is not null
			and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
            and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
			AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
    		and FCT.PROJECT_CLASS_ID = CLS.ID
		union all -- FORCE Creation of Org rows
select        HOU.NAME          AS ORG_ID
            , '-1'              AS ORGANIZATION_ID
            , '-1'              AS PROJECT_CLASS_ID
            , '-1'              AS EXPENDITURE_CATEGORY
            , '-1'              AS EXPENDITURE_TYPE_ID
            , '-1'              AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from
         PJI_PMV_ORG_DIM_TMP HOU
		where    HOU.NAME <> '-1'
   union all  -- FORCE Creation of Organization Rows
select        '-1'           AS ORG_ID
            , NAME           AS ORGANIZATION_ID
            , '-1'           AS PROJECT_CLASS_ID
            , '-1'           AS EXPENDITURE_CATEGORY
            , '-1'           AS EXPENDITURE_TYPE_ID
            , '-1'           AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_ORGZ_DIM_TMP HORG
		where    HORG.NAME <> '-1'
  union all  -- FORCE Creation of Class Rows
select        '-1'           AS ORG_ID
            , '-1'           AS ORGANIZATION_ID
            , CLS.NAME       AS PROJECT_CLASS_ID
            , '-1'           AS EXPENDITURE_CATEGORY
            , '-1'           AS EXPENDITURE_TYPE_ID
            , '-1'           AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_CLS_DIM_TMP CLS
		where    CLS.NAME <> '-1'
                ) WHERE 1 = 1
           group by ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID,
                    EXPENDITURE_CATEGORY, EXPENDITURE_TYPE_ID, WORK_TYPE_ID;

/*
** ORGANIZATION AND EXPENDITURE CATEGORY/TYPE Processing:
** Only Organization and Expenditure Category/Type is specified
*/

ELSIF
        l_Convert_Classification = 'N'
  AND   l_Convert_Expenditure_Type = 'Y'
  AND   l_Convert_Work_Type = 'N'
THEN
    select PJI_REP_PC6  ( ORG_ID
                        , ORGANIZATION_ID
                        , PROJECT_CLASS_ID
                        , EXPENDITURE_CATEGORY
                        , EXPENDITURE_TYPE_ID
                        , WORK_TYPE_ID
                        , SUM ( COST )
                        , SUM ( CT_COST )
                        , SUM ( COST_CHANGE_PRCNT )
                        , SUM ( CAP_COST )
                        , SUM ( CT_CAP_COST )
                        , SUM ( CAP_COST_CHANGE_PRCNT )
                        , SUM ( PRCNT_OF_COST )
                        , SUM ( CT_PRCNT_OF_COST )
                        , SUM ( PRCNT_OF_COST_CHANGE )
                        , SUM ( EXPENSE )
                        , SUM ( CT_EXPENSE )
                        , SUM ( EXPENSE_CHANGE_PRCNT )
                        , null,  null,  null,  null,  null, null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null,  null )
           bulk collect into l_lines_tab
           from
	      ( select /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , '-1'                                               AS WORK_TYPE_ID
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,  'BC', FCT.CAPITAL_BRDN_COST,
                                              'RC', FCT.CAPITAL_RAW_COST),0)  AS COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', FCT.CAPITALIZABLE_BRDN_COST,
                  'RC', FCT.CAPITALIZABLE_RAW_COST),0) CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                  'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE   --8301412
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
 	from
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_ORGO_ET_F_MV FCT
			, PJI_PMV_ORG_DIM_TMP HOU
		where
			FCT.ORG_ID = HOU.ID
		and FCT.ORGANIZATION_ID = HORG.ID
		and FCT.TIME_ID = TIME.ID
		and TIME.ID is not null
		and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
        and FCT.EXP_EVT_TYPE_ID = ET.ID
        and ET.record_type = 'ET'
union all -- PRIOR Actuals
          select /*+ ORDERED */
              HOU.NAME                 as ORG_ID
            , HORG.NAME                as ORGANIZATION_ID
            , '-1'                     as PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , '-1'                                               AS WORK_TYPE_ID
            , 0   as COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITAL_BRDN_COST,
                 'RC', FCT.CAPITAL_RAW_COST),0)  as CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITALIZABLE_BRDN_COST,
                 'RC', FCT.CAPITALIZABLE_RAW_COST),0)  as CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                 'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0)  as CT_EXPENSE --8301412
            , 0 EXPENSE_CHANGE_PRCNT
		from
			PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_ORGO_ET_F_MV FCT
			, PJI_PMV_ORG_DIM_TMP HOU
		where
			    FCT.ORG_ID = HOU.ID
			and FCT.ORGANIZATION_ID = HORG.ID
			and FCT.TIME_ID = TIME.ID
			and TIME.ID is not null
			and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
           	and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
            and FCT.EXP_EVT_TYPE_ID = ET.ID
			AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
            and ET.record_type = 'ET'
		union all -- FORCE Creation of Org rows
select        HOU.NAME         as ORG_ID
            , '-1'             as ORGANIZATION_ID
            , '-1'             as PROJECT_CLASS_ID
            , '-1'             AS EXPENDITURE_CATEGORY
            , '-1'             AS EXPENDITURE_TYPE_ID
            , '-1'             AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from
         PJI_PMV_ORG_DIM_TMP HOU
		where    HOU.NAME <> '-1'
                union all  -- FORCE Creation of Organization Rows
select        '-1'             AS ORG_ID
            , HORG.NAME        AS ORGANIZATION_ID
            , '-1'             AS PROJECT_CLASS_ID
            , '-1'             AS EXPENDITURE_CATEGORY
            , '-1'             AS EXPENDITURE_TYPE_ID
            , '-1'             AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_ORGZ_DIM_TMP HORG
		where    HORG.NAME <> '-1'
                union all  -- FORCE Creation of Expenditure Type Rows
select        '-1'           as ORG_ID
            , '-1'           as ORGANIZATION_ID
            , '-1'           as PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')             AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')             AS EXPENDITURE_TYPE_ID
            , '-1'                                               AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_ET_RT_DIM_TMP ET
		where    ET.NAME <> '-1'
                ) WHERE 1 = 1
            group by ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
            EXPENDITURE_TYPE_ID, WORK_TYPE_ID;

/*
** ORGANIZATION AND WORK TYPE Processing:
** Only Organization and Work Type is specified
*/

ELSIF
        l_Convert_Classification = 'N'
  AND   l_Convert_Expenditure_Type = 'N'
  AND   l_Convert_Work_Type = 'Y'
THEN
    select PJI_REP_PC6  ( ORG_ID
                        , ORGANIZATION_ID
                        , PROJECT_CLASS_ID
                        , EXPENDITURE_CATEGORY
                        , EXPENDITURE_TYPE_ID
                        , WORK_TYPE_ID
                        , SUM ( COST )
                        , SUM ( CT_COST )
                        , SUM ( COST_CHANGE_PRCNT )
                        , SUM ( CAP_COST )
                        , SUM ( CT_CAP_COST )
                        , SUM ( CAP_COST_CHANGE_PRCNT )
                        , SUM ( PRCNT_OF_COST )
                        , SUM ( CT_PRCNT_OF_COST )
                        , SUM ( PRCNT_OF_COST_CHANGE )
                        , SUM ( EXPENSE )
                        , SUM ( CT_EXPENSE )
                        , SUM ( EXPENSE_CHANGE_PRCNT )
                        , null,  null,  null,  null,  null, null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null,  null )
           bulk collect into l_lines_tab
           from
	      ( select /*+ ORDERED */
              HOU.NAME                 as ORG_ID
            , HORG.NAME                as ORGANIZATION_ID
            , '-1'                     as PROJECT_CLASS_ID
            , '-1'                     AS EXPENDITURE_CATEGORY
            , '-1'                     AS EXPENDITURE_TYPE_ID
            , WT.NAME                  AS WORK_TYPE_ID
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,  'BC', FCT.CAPITAL_BRDN_COST,
                                              'RC', FCT.CAPITAL_RAW_COST),0)  as COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', FCT.CAPITALIZABLE_BRDN_COST,
                  'RC', FCT.CAPITALIZABLE_RAW_COST),0) CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                  'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE    --8301412
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
 	from
		PJI_PMV_TIME_DIM_TMP TIME
		, PJI_PMV_ORGZ_DIM_TMP HORG
		, PJI_PMV_WT_DIM_TMP WT
            , PJI_FP_ORGO_ET_WT_F_MV FCT
		, PJI_PMV_ORG_DIM_TMP HOU
where
			FCT.ORG_ID = HOU.ID
		and FCT.ORGANIZATION_ID = HORG.ID
		and FCT.TIME_ID = TIME.ID
		and TIME.ID is not null
		and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
        and FCT.WORK_TYPE_ID = WT.ID
UNION ALL -- PRIOR Actuals
          select /*+ ORDERED */
              HOU.NAME                 AS ORG_ID
            , HORG.NAME                AS ORGANIZATION_ID
            , '-1'                     AS PROJECT_CLASS_ID
            , '-1'                     AS EXPENDITURE_CATEGORY
            , '-1'                     AS EXPENDITURE_TYPE_ID
            , WT.NAME                  AS WORK_TYPE_ID
            , 0                        AS COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITAL_BRDN_COST,
                 'RC', FCT.CAPITAL_RAW_COST),0)  AS CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITALIZABLE_BRDN_COST,
                 'RC', FCT.CAPITALIZABLE_RAW_COST),0)  AS CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                 'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) as CT_EXPENSE  --8301412
            , 0 EXPENSE_CHANGE_PRCNT
		from
			PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_WT_DIM_TMP WT
            , PJI_FP_ORGO_ET_WT_F_MV FCT
			, PJI_PMV_ORG_DIM_TMP HOU
		where
			FCT.ORG_ID = HOU.ID
		and FCT.ORGANIZATION_ID = HORG.ID
		and FCT.TIME_ID = TIME.ID
		and TIME.ID is not null
		and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
        and FCT.WORK_TYPE_ID = WT.ID
		union all -- FORCE Creation of Org rows
select        HOU.NAME          AS ORG_ID
            , '-1'              AS ORGANIZATION_ID
            , '-1'              AS PROJECT_CLASS_ID
            , '-1'              AS EXPENDITURE_CATEGORY
            , '-1'              AS EXPENDITURE_TYPE_ID
            , '-1'              AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from
         PJI_PMV_ORG_DIM_TMP HOU
		where    HOU.NAME <> '-1'
  union all  -- FORCE Creation of Organization Rows
select        '-1'                AS ORG_ID
            , HORG.NAME           AS ORGANIZATION_ID
            , '-1'                AS PROJECT_CLASS_ID
            , '-1'                AS EXPENDITURE_CATEGORY
            , '-1'                AS EXPENDITURE_TYPE_ID
            , '-1'                AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_ORGZ_DIM_TMP HORG
		where    HORG.NAME <> '-1'
                union all  -- FORCE Creation of Work Type Rows
select        '-1'           as ORG_ID
            , '-1'           as ORGANIZATION_ID
            , '-1'           as PROJECT_CLASS_ID
            , '-1'           AS EXPENDITURE_CATEGORY
            , '-1'           AS EXPENDITURE_TYPE_ID
            , WT.NAME        AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_WT_DIM_TMP WT
		where    WT.NAME <> '-1'
                )
            group by ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
             EXPENDITURE_TYPE_ID, WORK_TYPE_ID;
/*
** ORGANIZATION, CLASSIFICATION AND EXPENDITURE CATEGORY/TYPE Processing:
** Only Organization, Classification and Expenditure Category/Type is specified
*/

ELSIF
        l_Convert_Classification = 'Y'
  AND   l_Convert_Expenditure_Type = 'Y'
  AND   l_Convert_Work_Type = 'N'
THEN
    select PJI_REP_PC6  ( ORG_ID
                        , ORGANIZATION_ID
                        , PROJECT_CLASS_ID
                        , EXPENDITURE_CATEGORY
                        , EXPENDITURE_TYPE_ID
                        , WORK_TYPE_ID
                        , SUM ( COST )
                        , SUM ( CT_COST )
                        , SUM ( COST_CHANGE_PRCNT )
                        , SUM ( CAP_COST )
                        , SUM ( CT_CAP_COST )
                        , SUM ( CAP_COST_CHANGE_PRCNT )
                        , SUM ( PRCNT_OF_COST )
                        , SUM ( CT_PRCNT_OF_COST )
                        , SUM ( PRCNT_OF_COST_CHANGE )
                        , SUM ( EXPENSE )
                        , SUM ( CT_EXPENSE )
                        , SUM ( EXPENSE_CHANGE_PRCNT )
                        , null,  null,  null,  null,  null, null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null,  null )
           bulk collect into l_lines_tab
           from
	      ( select /*+ ORDERED */
              HOU.NAME                 as ORG_ID
            , HORG.NAME                as ORGANIZATION_ID
            , CLS.NAME                 as PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')            AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')            AS EXPENDITURE_TYPE_ID
            , '-1'                                              AS WORK_TYPE_ID
            , decode(NVL(TIME.amount_type,1),1,
                decode(G_Report_Cost_Type,  'BC', FCT.CAPITAL_BRDN_COST,
                                            'RC', FCT.CAPITAL_RAW_COST),0)  as COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', FCT.CAPITALIZABLE_BRDN_COST,
                  'RC', FCT.CAPITALIZABLE_RAW_COST),0) CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                  'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE    --8301412
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
 	from
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_CLSO_ET_F_MV FCT
			, PJI_PMV_CLS_DIM_TMP CLS
		    , PJI_PMV_ORG_DIM_TMP HOU
		where
			FCT.PROJECT_ORG_ID = HOU.ID
		and FCT.PROJECT_ORGANIZATION_ID = HORG.ID
		and FCT.TIME_ID = TIME.ID
		and TIME.ID is not null
		and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
        and FCT.EXP_EVT_TYPE_ID = ET.ID
        and FCT.PROJECT_CLASS_ID = CLS.ID
union all -- PRIOR Actuals
          select /*+ ORDERED */
              HOU.NAME                                AS ORG_ID
            , HORG.NAME                               AS ORGANIZATION_ID
            , CLS.NAME                                AS PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')  AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')  AS EXPENDITURE_TYPE_ID
            , '-1'                                    AS WORK_TYPE_ID
            , 0   as COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITAL_BRDN_COST,
                 'RC', FCT.CAPITAL_RAW_COST),0)  as CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITALIZABLE_BRDN_COST,
                 'RC', FCT.CAPITALIZABLE_RAW_COST),0)  as CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                 'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0)  as CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from
			PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
			, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_CLSO_ET_F_MV FCT
			, PJI_PMV_CLS_DIM_TMP CLS
		    , PJI_PMV_ORG_DIM_TMP HOU
		where
			FCT.PROJECT_ORG_ID = HOU.ID
		and FCT.PROJECT_ORGANIZATION_ID = HORG.ID
		and FCT.TIME_ID = TIME.ID
		and TIME.ID is not null
		and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
        and FCT.EXP_EVT_TYPE_ID = ET.ID
        and FCT.PROJECT_CLASS_ID = CLS.ID
		union all -- FORCE Creation of Org rows
select        NAME          as ORG_ID
            , '-1'              as ORGANIZATION_ID
            , '-1'              as PROJECT_CLASS_ID
            , '-1'  AS EXPENDITURE_CATEGORY
            , '-1'  AS EXPENDITURE_TYPE_ID
            , '-1'                                    AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from
         PJI_PMV_ORG_DIM_TMP HOU
		where    HOU.NAME <> '-1'
                union all  -- FORCE Creation of Organization Rows
select        '-1'                as ORG_ID
            , HORG.NAME           as ORGANIZATION_ID
            , '-1'  AS PROJECT_CLASS_ID
            , '-1'  AS EXPENDITURE_CATEGORY
            , '-1'  AS EXPENDITURE_TYPE_ID
            , '-1'  AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_ORGZ_DIM_TMP HORG
		where    HORG.NAME <> '-1'
                union all  -- FORCE Creation of Project Class Rows
select        '-1'   as ORG_ID
            , '-1'   as ORGANIZATION_ID
            , CLS.NAME   as PROJECT_CLASS_ID
            , '-1'  AS EXPENDITURE_CATEGORY
            , '-1'  AS EXPENDITURE_TYPE_ID
            , '-1'                                    AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_CLS_DIM_TMP CLS
		where    CLS.NAME <> '-1'
       union all  -- FORCE Creation of Expenditure Category/Type Rows
select        '-1'           as ORG_ID
            , '-1'           as ORGANIZATION_ID
            , '-1'           as PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')  AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')  AS EXPENDITURE_TYPE_ID
            , '-1'                                    AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_ET_RT_DIM_TMP ET
		where    ET.NAME <> '-1'
                ) WHERE 1=1
            group by ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
            EXPENDITURE_TYPE_ID, WORK_TYPE_ID;

/*
** ORGANIZATION, EXPENDITURE CATEGORY/TYPE AND WORK TYPE Processing:
** Only Organization, Expenditure Category/Type and Work Type is specified
*/

ELSIF
      l_Convert_Classification = 'N'
  AND   l_Convert_Expenditure_Type = 'Y'
  AND   l_Convert_Work_Type = 'Y'
THEN
    select PJI_REP_PC6  ( ORG_ID
                        , ORGANIZATION_ID
                        , PROJECT_CLASS_ID
                        , EXPENDITURE_CATEGORY
                        , EXPENDITURE_TYPE_ID
                        , WORK_TYPE_ID
                        , SUM ( COST )
                        , SUM ( CT_COST )
                        , SUM ( COST_CHANGE_PRCNT )
                        , SUM ( CAP_COST )
                        , SUM ( CT_CAP_COST )
                        , SUM ( CAP_COST_CHANGE_PRCNT )
                        , SUM ( PRCNT_OF_COST )
                        , SUM ( CT_PRCNT_OF_COST )
                        , SUM ( PRCNT_OF_COST_CHANGE )
                        , SUM ( EXPENSE )
                        , SUM ( CT_EXPENSE )
                        , SUM ( EXPENSE_CHANGE_PRCNT )
                        , null,  null,  null,  null,  null, null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null,  null )
           bulk collect into l_lines_tab
           from
	      ( select /*+ ORDERED */
              HOU.NAME                 as ORG_ID
            , HORG.NAME                as ORGANIZATION_ID
            , '-1'                     as PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')            AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')            AS EXPENDITURE_TYPE_ID
            , WT.NAME                                           AS WORK_TYPE_ID
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,  'BC', FCT.CAPITAL_BRDN_COST,
                                              'RC', FCT.CAPITAL_RAW_COST),0)  as COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', FCT.CAPITALIZABLE_BRDN_COST,
                  'RC', FCT.CAPITALIZABLE_RAW_COST),0) CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                  'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE      --8301412
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
 	from
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
    		, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_ORGO_ET_WT_F_MV FCT
			, PJI_PMV_WT_DIM_TMP WT
		    , PJI_PMV_ORG_DIM_TMP HOU
		where
			FCT.ORG_ID = HOU.ID
		and FCT.ORGANIZATION_ID = HORG.ID
		and FCT.TIME_ID = TIME.ID
		and TIME.ID is not null
		and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
        and FCT.WORK_TYPE_ID = WT.ID
        and FCT.EXP_EVT_TYPE_ID = ET.ID
union all -- PRIOR Actuals
          select /*+ ORDERED */
              HOU.NAME                 as ORG_ID
            , HORG.NAME                as ORGANIZATION_ID
            , '-1'                     as PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')            AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')            AS EXPENDITURE_TYPE_ID
            , WT.NAME                                           AS WORK_TYPE_ID
            , 0   as COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITAL_BRDN_COST,
                 'RC', FCT.CAPITAL_RAW_COST),0)  as CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITALIZABLE_BRDN_COST,
                 'RC', FCT.CAPITALIZABLE_RAW_COST),0)  as CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                 'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0)  as CT_EXPENSE --8301412
            , 0 EXPENSE_CHANGE_PRCNT
		from
	      PJI_PMV_TCMP_DIM_TMP TIME
            , PJI_PMV_ORGZ_DIM_TMP HORG
    	    , PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_ORGO_ET_WT_F_MV FCT
	    , PJI_PMV_WT_DIM_TMP WT
	    , PJI_PMV_ORG_DIM_TMP HOU
	 where
			FCT.ORG_ID = HOU.ID
		and FCT.ORGANIZATION_ID = HORG.ID
		and FCT.TIME_ID = TIME.ID
		and TIME.ID is not null
		and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        and FCT.CALENDAR_TYPE  = TIME.CALENDAR_TYPE
		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
        and FCT.WORK_TYPE_ID   = WT.ID
        and FCT.EXP_EVT_TYPE_ID = ET.ID
	union all -- FORCE Creation of Org rows
select        HOU.NAME          as ORG_ID
            , '-1'              as ORGANIZATION_ID
            , '-1'              as PROJECT_CLASS_ID
            , '-1'            AS EXPENDITURE_CATEGORY
            , '-1'            AS EXPENDITURE_TYPE_ID
            , '-1'            AS WORK_TYPE
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from
         PJI_PMV_ORG_DIM_TMP HOU
		where    HOU.NAME <> '-1'
                union all  -- FORCE Creation of Organization Rows
select        '-1'            AS ORG_ID
            , HORG.NAME       AS ORGANIZATION_ID
            , '-1'            AS PROJECT_CLASS_ID
            , '-1'            AS EXPENDITURE_CATEGORY
            , '-1'            AS EXPENDITURE_TYPE_ID
            , '-1'            AS WORK_TYPE
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_ORGZ_DIM_TMP HORG
		where    HORG.NAME <> '-1'
        union all
select        '-1'          as ORG_ID
            , '-1'              as ORGANIZATION_ID
            , '-1'              as PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')            AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')            AS EXPENDITURE_TYPE_ID
            , '-1'                                           AS WORK_TYPE
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from
         PJI_PMV_ET_RT_DIM_TMP ET
		where    ET.NAME <> '-1'
        union all
select        '-1'       as ORG_ID
            , '-1'            as ORGANIZATION_ID
            , '-1'            as PROJECT_CLASS_ID
            , '-1'            AS EXPENDITURE_CATEGORY
            , '-1'            AS EXPENDITURE_TYPE_ID
            , WT.NAME         AS WORK_TYPE
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from
         PJI_PMV_WT_DIM_TMP WT
		where    WT.NAME <> '-1'
        ) WHERE 1=1
            group by ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
            EXPENDITURE_TYPE_ID, WORK_TYPE_ID;
/*
** ORGANIZATION, CLASSIFICATION AND WORK TYPE Processing:
** Only Organization, Classification and Work Type is specified
*/

ELSIF
      l_Convert_Classification = 'Y'
  AND   l_Convert_Expenditure_Type = 'N'
  AND   l_Convert_Work_Type = 'Y'
THEN
    select PJI_REP_PC6  ( ORG_ID
                        , ORGANIZATION_ID
                        , PROJECT_CLASS_ID
                        , EXPENDITURE_CATEGORY
                        , EXPENDITURE_TYPE_ID
                        , WORK_TYPE_ID
                        , SUM ( COST )
                        , SUM ( CT_COST )
                        , SUM ( COST_CHANGE_PRCNT )
                        , SUM ( CAP_COST )
                        , SUM ( CT_CAP_COST )
                        , SUM ( CAP_COST_CHANGE_PRCNT )
                        , SUM ( PRCNT_OF_COST )
                        , SUM ( CT_PRCNT_OF_COST )
                        , SUM ( PRCNT_OF_COST_CHANGE )
                        , SUM ( EXPENSE )
                        , SUM ( CT_EXPENSE )
                        , SUM ( EXPENSE_CHANGE_PRCNT )
                        , null,  null,  null,  null,  null, null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null,  null )
           bulk collect into l_lines_tab
           from
	      ( select /*+ ORDERED */
              HOU.NAME                 as ORG_ID
            , HORG.NAME                as ORGANIZATION_ID
            , CLS.NAME                 as PROJECT_CLASS_ID
            , '-1'            AS EXPENDITURE_CATEGORY
            , '-1'            AS EXPENDITURE_TYPE_ID
            , WT.NAME         AS WORK_TYPE_ID
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,  'BC', FCT.CAPITAL_BRDN_COST,
                                              'RC', FCT.CAPITAL_RAW_COST),0)  as COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', FCT.CAPITALIZABLE_BRDN_COST,
                  'RC', FCT.CAPITALIZABLE_RAW_COST),0) CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                  'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE   --8301412
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
 	from
	PJI_PMV_TIME_DIM_TMP TIME
	, PJI_PMV_ORGZ_DIM_TMP HORG
   	, PJI_PMV_CLS_DIM_TMP CLS
        , PJI_FP_CLSO_ET_WT_F_MV FCT
    	, PJI_PMV_WT_DIM_TMP WT
	    , PJI_PMV_ORG_DIM_TMP HOU
		where
			FCT.PROJECT_ORG_ID = HOU.ID
		and FCT.PROJECT_ORGANIZATION_ID = HORG.ID
		and FCT.TIME_ID = TIME.ID
		and TIME.ID is not null
		and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
        and FCT.WORK_TYPE_ID = WT.ID
        and FCT.PROJECT_CLASS_ID = CLS.ID
union all -- PRIOR Actuals
          select /*+ ORDERED */
              HOU.NAME                 as ORG_ID
            , HORG.NAME                as ORGANIZATION_ID
            , CLS.NAME                 as PROJECT_CLASS_ID
            , '-1'            AS EXPENDITURE_CATEGORY
            , '-1'            AS EXPENDITURE_TYPE_ID
            , WT.NAME         AS WORK_TYPE_ID
            , 0   as COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITAL_BRDN_COST,
                 'RC', FCT.CAPITAL_RAW_COST),0)  as CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITALIZABLE_BRDN_COST,
                 'RC', FCT.CAPITALIZABLE_RAW_COST),0)  as CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                 'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0)  as CT_EXPENSE --8301412
            , 0 EXPENSE_CHANGE_PRCNT
		from
			PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
    		, PJI_PMV_CLS_DIM_TMP CLS
            , PJI_FP_CLSO_ET_WT_F_MV FCT
			, PJI_PMV_WT_DIM_TMP WT
		    , PJI_PMV_ORG_DIM_TMP HOU
		where
			FCT.PROJECT_ORG_ID = HOU.ID
		and FCT.PROJECT_ORGANIZATION_ID = HORG.ID
		and FCT.TIME_ID = TIME.ID
		and TIME.ID is not null
		and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
        and FCT.WORK_TYPE_ID = WT.ID
        and FCT.PROJECT_CLASS_ID = CLS.ID
		union all -- FORCE Creation of Org rows
select        HOU.NAME          as ORG_ID
            , '-1'              as ORGANIZATION_ID
            , '-1'              as PROJECT_CLASS_ID
            , '-1'            AS EXPENDITURE_CATEGORY
            , '-1'            AS EXPENDITURE_TYPE_ID
            , '-1'         AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from
         PJI_PMV_ORG_DIM_TMP HOU
		where    HOU.NAME <> '-1'
                union all  -- FORCE Creation of Organization Rows
select        '-1'                as ORG_ID
            , HORG.NAME           as ORGANIZATION_ID
            , '-1'                as PROJECT_CLASS_ID
            , '-1'            AS EXPENDITURE_CATEGORY
            , '-1'            AS EXPENDITURE_TYPE_ID
            , '-1'        AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_ORGZ_DIM_TMP HORG
where    HORG.NAME <> '-1'
		union all -- FORCE Creation of Org rows
select        '-1'            AS ORG_ID
            , '-1'            AS ORGANIZATION_ID
            , CLS.NAME        AS PROJECT_CLASS_ID
            , '-1'            AS EXPENDITURE_CATEGORY
            , '-1'            AS EXPENDITURE_TYPE_ID
            , '-1'            AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_CLS_DIM_TMP CLS
where    CLS.NAME <> '-1'
		union all -- FORCE Creation of Org rows
select        '-1'            AS ORG_ID
            , '-1'            AS ORGANIZATION_ID
            , '-1'            AS PROJECT_CLASS_ID
            , '-1'            AS EXPENDITURE_CATEGORY
            , '-1'            AS EXPENDITURE_TYPE_ID
            , WT.NAME         AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_WT_DIM_TMP WT
where    WT.NAME <> '-1'
     ) group by ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
     EXPENDITURE_TYPE_ID,WORK_TYPE_ID;

/*
** ORGANIZATION, CLASSIFICATION, EXPENDITURE CATEGORY/TYPE AND WORK TYPE Processing:
** All Parameters specified: Organization, Classification, Expenditure Category/Type
** and Work Type is specified
*/


ELSE
    select PJI_REP_PC6  ( ORG_ID
                        , ORGANIZATION_ID
                        , PROJECT_CLASS_ID
                        , EXPENDITURE_CATEGORY
                        , EXPENDITURE_TYPE_ID
                        , WORK_TYPE_ID
                        , SUM ( COST )
                        , SUM ( CT_COST )
                        , SUM ( COST_CHANGE_PRCNT )
                        , SUM ( CAP_COST )
                        , SUM ( CT_CAP_COST )
                        , SUM ( CAP_COST_CHANGE_PRCNT )
                        , SUM ( PRCNT_OF_COST )
                        , SUM ( CT_PRCNT_OF_COST )
                        , SUM ( PRCNT_OF_COST_CHANGE )
                        , SUM ( EXPENSE )
                        , SUM ( CT_EXPENSE )
                        , SUM ( EXPENSE_CHANGE_PRCNT )
                        , null,  null,  null,  null,  null, null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null , null , null , null
                        , null , null,  null )
           bulk collect into l_lines_tab
           from
	      ( select /*+ ORDERED */
              HOU.NAME        as ORG_ID
            , HORG.NAME       as ORGANIZATION_ID
            , CLS.NAME        as PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')            AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')            AS EXPENDITURE_TYPE_ID
            , WT.NAME         AS WORK_TYPE_ID
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,  'BC', FCT.CAPITAL_BRDN_COST,
                                              'RC', FCT.CAPITAL_RAW_COST),0)  as COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', FCT.CAPITALIZABLE_BRDN_COST,
                  'RC', FCT.CAPITALIZABLE_RAW_COST),0) CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , decode(NVL(TIME.amount_type,1),1,
                  decode(G_Report_Cost_Type,
                  'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                  'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE     --8301412
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
 	from
			PJI_PMV_TIME_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
    		, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_CLSO_ET_WT_F_MV FCT
			, PJI_PMV_CLS_DIM_TMP CLS
		    , PJI_PMV_WT_DIM_TMP WT
		    , PJI_PMV_ORG_DIM_TMP HOU
		where
			FCT.PROJECT_ORG_ID = HOU.ID
		and FCT.PROJECT_ORGANIZATION_ID = HORG.ID
		and FCT.TIME_ID = TIME.ID
		and TIME.ID is not null
		and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
        and FCT.WORK_TYPE_ID = WT.ID
        and FCT.PROJECT_CLASS_ID = CLS.ID
        and FCT.EXP_EVT_TYPE_ID  = ET.ID
        and ET.record_type = 'ET'
union all -- PRIOR Actuals
          select /*+ ORDERED */
              HOU.NAME                 as ORG_ID
            , HORG.NAME                as ORGANIZATION_ID
            , CLS.NAME            as PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')            AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')            AS EXPENDITURE_TYPE_ID
            , WT.NAME       AS WORK_TYPE_ID
            , 0   as COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITAL_BRDN_COST,
                 'RC', FCT.CAPITAL_RAW_COST),0)  as CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', FCT.CAPITALIZABLE_BRDN_COST,
                 'RC', FCT.CAPITALIZABLE_RAW_COST),0)  as CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , decode(NVL(TIME.amount_type,1),1,
                 decode(G_Report_Cost_Type,
                 'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                 'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0)  as CT_EXPENSE --8301412
            , 0 EXPENSE_CHANGE_PRCNT
		from
			PJI_PMV_TCMP_DIM_TMP TIME
			, PJI_PMV_ORGZ_DIM_TMP HORG
    		, PJI_PMV_ET_RT_DIM_TMP ET
            , PJI_FP_CLSO_ET_WT_F_MV FCT
			, PJI_PMV_CLS_DIM_TMP CLS
		    , PJI_PMV_WT_DIM_TMP WT
		    , PJI_PMV_ORG_DIM_TMP HOU
		where
			FCT.PROJECT_ORG_ID = HOU.ID
		and FCT.PROJECT_ORGANIZATION_ID = HORG.ID
		and FCT.TIME_ID = TIME.ID
		and TIME.ID is not null
		and FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        and FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
        and FCT.WORK_TYPE_ID = WT.ID
        and FCT.PROJECT_CLASS_ID = CLS.ID
        and FCT.EXP_EVT_TYPE_ID  = ET.ID
        and ET.record_type = 'ET'
union all -- FORCE Creation of Org rows
select        HOU.NAME    AS ORG_ID
            , '-1'        AS ORGANIZATION_ID
            , '-1'        AS PROJECT_CLASS_ID
            , '-1'        AS EXPENDITURE_CATEGORY
            , '-1'        AS EXPENDITURE_TYPE_ID
            , '-1'        AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from
         PJI_PMV_ORG_DIM_TMP HOU
		where    HOU.NAME <> '-1'
                union all  -- FORCE Creation of Organization Rows
select        '-1'                as ORG_ID
            , HORG.NAME  AS ORGANIZATION_ID
            , '-1'  AS PROJECT_CLASS_ID
            , '-1'  AS EXPENDITURE_CATEGORY
            , '-1'  AS EXPENDITURE_TYPE_ID
            , '-1'  AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_ORGZ_DIM_TMP HORG
		where    HORG.NAME <> '-1'
union all
select        '-1'                as ORG_ID
            , '-1'  AS ORGANIZATION_ID
            , CLS.NAME            as PROJECT_CLASS_ID
            , '-1'            AS EXPENDITURE_CATEGORY
            , '-1'            AS EXPENDITURE_TYPE_ID
            , '-1'       AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_CLS_DIM_TMP CLS
		where    CLS.NAME <> '-1'
        union all
select        '-1'  as ORG_ID
            , '-1'  AS ORGANIZATION_ID
            , '-1'           as PROJECT_CLASS_ID
            , decode(p_view_by, 'EC', ET.name, '-1')            AS EXPENDITURE_CATEGORY
            , decode(p_view_by, 'ET', ET.name, '-1')            AS EXPENDITURE_TYPE_ID
            , '-1'       AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_ET_RT_DIM_TMP ET
		where    ET.NAME <> '-1'
        union all
select        '-1'                as ORG_ID
            , '-1'  AS ORGANIZATION_ID
            , '-1'  AS PROJECT_CLASS_ID
            , '-1'  AS EXPENDITURE_CATEGORY
            , '-1'  AS EXPENDITURE_TYPE_ID
            , WT.NAME  AS WORK_TYPE_ID
            , 0 COST
            , 0 CT_COST
            , 0 COST_CHANGE_PRCNT
            , 0 CAP_COST
            , 0 CT_CAP_COST
            , 0 CAP_COST_CHANGE_PRCNT
            , 0 PRCNT_OF_COST
            , 0 CT_PRCNT_OF_COST
            , 0 PRCNT_OF_COST_CHANGE
            , 0 EXPENSE
            , 0 CT_EXPENSE
            , 0 EXPENSE_CHANGE_PRCNT
		from	 PJI_PMV_WT_DIM_TMP WT
		where    WT.NAME <> '-1'
                ) where 1=1
group by ORG_ID, ORGANIZATION_ID, PROJECT_CLASS_ID, EXPENDITURE_CATEGORY,
EXPENDITURE_TYPE_ID, WORK_TYPE_ID;

END IF;

for i in 1..l_lines_tab.COUNT
loop
	if p_View_By = 'OG' then
				if l_lines_tab(i).ORGANIZATION_ID = l_Top_Organization_Name then
					l_Top_Org_Index:=i;

            l_TO_Cost            := nvl(l_lines_tab(i).COST,0);
            l_TO_CT_Cost         := nvl(l_lines_tab(i).CT_COST,0);
            l_TO_Cap_Cost        := nvl(l_lines_tab(i).CAP_COST,0);
            l_TO_CT_Cap_Cost     := nvl(l_lines_tab(i).CT_CAP_COST,0);
            l_TO_Expense         := nvl(l_lines_tab(i).EXPENSE,0);
            l_TO_CT_Expense      := nvl(l_lines_tab(i).CT_EXPENSE,0);

	else
            l_Cost            := l_Cost + nvl(l_lines_tab(i).COST,0);
            l_CT_Cost         := l_CT_Cost + nvl(l_lines_tab(i).CT_COST,0);
            l_Cap_Cost        := l_Cap_Cost + nvl(l_lines_tab(i).CAP_COST,0);
            l_CT_Cap_Cost     := l_CT_Cap_Cost + nvl(l_lines_tab(i).CT_CAP_COST,0);
            l_Expense         := l_Expense + nvl(l_lines_tab(i).EXPENSE,0);
            l_CT_Expense      := l_CT_Expense + nvl(l_lines_tab(i).CT_EXPENSE,0);

end if;
else
            l_Cost            := l_Cost + nvl(l_lines_tab(i).COST,0);
            l_CT_Cost         := l_CT_Cost + nvl(l_lines_tab(i).CT_COST,0);
            l_Cap_Cost        := l_Cap_Cost + nvl(l_lines_tab(i).CAP_COST,0);
            l_CT_Cap_Cost     := l_CT_Cap_Cost + nvl(l_lines_tab(i).CT_CAP_COST,0);
            l_Expense         := l_Expense + nvl(l_lines_tab(i).EXPENSE,0);
            l_CT_Expense      := l_CT_Expense + nvl(l_lines_tab(i).CT_EXPENSE,0);
end if;

		if nvl(l_lines_tab(i).CT_COST, 0) <> 0 then
			l_lines_tab(i).COST_CHANGE_PRCNT := 100 * (l_lines_tab(i).COST -
			l_lines_tab(i).CT_COST) / abs( l_lines_tab(i).CT_COST);
		else
			l_lines_tab(i).COST_CHANGE_PRCNT := null;
		end if;

		if nvl(l_lines_tab(i).CT_CAP_COST, 0) <> 0 then
			l_lines_tab(i).CAP_COST_CHANGE_PRCNT := 100 *
            (l_lines_tab(i).CAP_COST -
			l_lines_tab(i).CT_CAP_COST) / abs( l_lines_tab(i).CT_CAP_COST);
		else
			l_lines_tab(i).CAP_COST_CHANGE_PRCNT := null;
		end if;


		if nvl(l_lines_tab(i).COST, 0) <> 0 then
			l_lines_tab(i).PRCNT_OF_COST := 100 *
            (l_lines_tab(i).CAP_COST) / abs( l_lines_tab(i).COST);
		else
			l_lines_tab(i).PRCNT_OF_COST := null;
		end if;


		if nvl(l_lines_tab(i).CT_COST, 0) <> 0 then
			l_lines_tab(i).CT_PRCNT_OF_COST := 100 *
            (l_lines_tab(i).CT_CAP_COST) / abs( l_lines_tab(i).CT_COST);
		else
			l_lines_tab(i).CT_PRCNT_OF_COST := null;
		end if;


       l_lines_tab(i).PRCNT_OF_COST_CHANGE :=
            l_lines_tab(i).PRCNT_OF_COST - l_lines_tab(i).CT_PRCNT_OF_COST;

 		if nvl(l_lines_tab(i).CT_EXPENSE, 0) <> 0 then
			l_lines_tab(i).EXPENSE_CHANGE_PRCNT := 100 *
            (l_lines_tab(i).EXPENSE - l_lines_tab(i).CT_EXPENSE )
            / abs( l_lines_tab(i).CT_EXPENSE);
		else
			l_lines_tab(i).EXPENSE_CHANGE_PRCNT := null;
		end if;
end loop;


if p_View_By = 'OG' then
  	l_lines_tab(l_Top_Org_Index).COST
       		:=nvl(l_lines_tab(l_Top_Org_Index).COST,0)-l_Cost;

		l_lines_tab(l_Top_Org_Index).CT_COST
	        :=nvl(l_lines_tab(l_Top_Org_Index).CT_COST,0)-l_CT_Cost;

		l_lines_tab(l_Top_Org_Index).CAP_COST
	        :=nvl(l_lines_tab(l_Top_Org_Index).CAP_COST,0)-l_Cap_Cost;

	    l_lines_tab(l_Top_Org_Index).CT_CAP_COST
            :=nvl(l_lines_tab(l_Top_Org_Index).CT_CAP_COST,0)-l_CT_Cap_Cost;

	    l_lines_tab(l_Top_Org_Index).EXPENSE
            :=nvl(l_lines_tab(l_Top_Org_Index).EXPENSE,0)-l_Expense;

	    l_lines_tab(l_Top_Org_Index).CT_EXPENSE
            :=nvl(l_lines_tab(l_Top_Org_Index).CT_EXPENSE,0)-l_CT_Expense;

		if nvl(l_lines_tab(l_Top_Org_Index).CT_COST, 0) <> 0 then
			l_lines_tab(l_Top_Org_Index).COST_CHANGE_PRCNT := 100 * (l_lines_tab(l_Top_Org_Index).COST -
			l_lines_tab(l_Top_Org_Index).CT_COST) / abs( l_lines_tab(l_Top_Org_Index).CT_COST);
		else
			l_lines_tab(l_Top_Org_Index).COST_CHANGE_PRCNT := null;
		end if;

		if nvl(l_lines_tab(l_Top_Org_Index).CT_CAP_COST, 0) <> 0 then
			l_lines_tab(l_Top_Org_Index).CAP_COST_CHANGE_PRCNT := 100 *
            (l_lines_tab(l_Top_Org_Index).CAP_COST -
			l_lines_tab(l_Top_Org_Index).CT_CAP_COST) / abs( l_lines_tab(l_Top_Org_Index).CT_CAP_COST);
		else
			l_lines_tab(l_Top_Org_Index).CAP_COST_CHANGE_PRCNT := null;
		end if;

		if nvl(l_lines_tab(l_Top_Org_Index).COST, 0) <> 0 then
			l_lines_tab(l_Top_Org_Index).PRCNT_OF_COST := 100 *
            (l_lines_tab(l_Top_Org_Index).CAP_COST) / abs( l_lines_tab(l_Top_Org_Index).COST);
		else
			l_lines_tab(l_Top_Org_Index).PRCNT_OF_COST := null;
		end if;

		if nvl(l_lines_tab(l_Top_Org_Index).CT_COST, 0) <> 0 then
			l_lines_tab(l_Top_Org_Index).CT_PRCNT_OF_COST := 100 *
            (l_lines_tab(l_Top_Org_Index).CT_CAP_COST) / abs( l_lines_tab(l_Top_Org_Index).CT_COST);
		else
			l_lines_tab(l_Top_Org_Index).CT_PRCNT_OF_COST := null;
		end if;

       l_lines_tab(l_Top_Org_Index).PRCNT_OF_COST_CHANGE :=
            l_lines_tab(l_Top_Org_Index).PRCNT_OF_COST - l_lines_tab(l_Top_Org_Index).CT_PRCNT_OF_COST;

 		if nvl(l_lines_tab(l_Top_Org_Index).CT_EXPENSE, 0) <> 0 then
			l_lines_tab(l_Top_Org_Index).EXPENSE_CHANGE_PRCNT := 100 *
            (l_lines_tab(l_Top_Org_Index).EXPENSE - l_lines_tab(l_Top_Org_Index).CT_EXPENSE )
            / abs( l_lines_tab(l_Top_Org_Index).CT_EXPENSE);
		else
			l_lines_tab(l_Top_Org_Index).EXPENSE_CHANGE_PRCNT := null;
		end if;

		if          nvl( l_lines_tab(l_Top_Org_Index).COST, 0 ) = 0
			and nvl( l_lines_tab(l_Top_Org_Index).CT_COST, 0 ) = 0
			and nvl( l_lines_tab(l_Top_Org_Index).COST_CHANGE_PRCNT, 0 ) = 0
			and nvl( l_lines_tab(l_Top_Org_Index).CAP_COST, 0 ) = 0
			and nvl( l_lines_tab(l_Top_Org_Index).CT_CAP_COST, 0 ) = 0
			and nvl( l_lines_tab(l_Top_Org_Index).CAP_COST_CHANGE_PRCNT, 0 ) = 0
			and nvl( l_lines_tab(l_Top_Org_Index).PRCNT_OF_COST, 0 ) = 0
			and nvl( l_lines_tab(l_Top_Org_Index).PRCNT_OF_COST_CHANGE, 0 ) = 0
			and nvl( l_lines_tab(l_Top_Org_Index).EXPENSE, 0 ) = 0
			and nvl( l_lines_tab(l_Top_Org_Index).CT_EXPENSE, 0 ) = 0
   			and nvl( l_lines_tab(l_Top_Org_Index).EXPENSE_CHANGE_PRCNT, 0 ) = 0

		then
			l_lines_tab.DELETE(l_Top_Org_Index);
		end if;

    l_Cost                   :=l_TO_Cost;
    l_CT_Cost                :=l_TO_CT_Cost;
    l_Cap_Cost               :=l_TO_Cap_Cost;
    l_CT_Cap_Cost            :=l_TO_CT_Cap_Cost;
    l_Expense                :=l_TO_Expense;
    l_CT_Expense             :=l_TO_CT_Expense;

end if;

/*
**  "Totals" Logic is Here
*/

  if l_lines_tab.COUNT > 0 then
	for i in l_lines_tab.FIRST..l_lines_tab.LAST
	loop
		if l_lines_tab.EXISTS(i) then

			l_lines_tab(i).PJI_REP_TOTAL_1  := l_Cost;
			l_lines_tab(i).PJI_REP_TOTAL_2  := l_CT_Cost;
			l_lines_tab(i).PJI_REP_TOTAL_4  := l_Cap_Cost;
			l_lines_tab(i).PJI_REP_TOTAL_5  := l_CT_Cap_Cost;
			l_lines_tab(i).PJI_REP_TOTAL_10 := l_Expense;
			l_lines_tab(i).PJI_REP_TOTAL_11 := l_CT_Expense;

			if nvl(l_CT_Cost, 0) <> 0 then
			l_lines_tab(i).PJI_REP_TOTAL_3:=(l_Cost-l_CT_Cost)*100/l_CT_Cost;
			else
				l_lines_tab(i).PJI_REP_TOTAL_3:=null;
			end if;

			if nvl(l_CT_Cap_Cost, 0) <> 0 then
			l_lines_tab(i).PJI_REP_TOTAL_6:=(l_Cap_Cost-l_CT_Cap_Cost)*100/l_CT_Cap_Cost;
			else
				l_lines_tab(i).PJI_REP_TOTAL_6:=null;
			end if;

  			if nvl(l_Cost, 0) <> 0 then
			l_lines_tab(i).PJI_REP_TOTAL_7:=(l_Cap_Cost)*100/l_Cost;
			else
				l_lines_tab(i).PJI_REP_TOTAL_7:=null;
			end if;


			if nvl(l_CT_Cost, 0) <> 0 then
			l_lines_tab(i).PJI_REP_TOTAL_8:=(l_CT_Cap_Cost)*100/l_CT_Cost;
			else
				l_lines_tab(i).PJI_REP_TOTAL_8:=null;
			end if;

			l_lines_tab(i).PJI_REP_TOTAL_9:=l_lines_tab(i).PJI_REP_TOTAL_7 -l_lines_tab(i).PJI_REP_TOTAL_8;


			if nvl(l_CT_Expense, 0) <> 0 then
			l_lines_tab(i).PJI_REP_TOTAL_12:=(l_Expense - l_CT_Expense)*100/l_CT_Expense;
			else
				l_lines_tab(i).PJI_REP_TOTAL_12:=null;
			end if;
		end if;
	end loop;
end if;

/*
** ---------------------------------------------------+
** --	 Return the bulk collected table back to pmv.-+
** ---------------------------------------------------+
*/

	   COMMIT;
    return l_lines_tab;
 end PLSQLDriver_PJI_REP_PC6;


/*
** Capital Cost Trend Report and Capital Cost Cumulative Trend Report
*/


function PLSQLDriver_PJI_REP_PC7(
  p_Operating_Unit		IN VARCHAR2 default null
, p_Organization		IN VARCHAR2
, p_Currency_Type		IN VARCHAR2
, p_As_Of_Date			IN NUMBER
, p_Period_Type 		IN VARCHAR2
, p_View_BY 			IN VARCHAR2
, p_Classifications		IN VARCHAR2 default null
, p_Class_Codes			IN VARCHAR2 default null
, p_Report_Type			   IN VARCHAR2 default null
, p_Expenditure_Category   IN VARCHAR2 DEFAULT NULL
, p_Expenditure_Type       IN VARCHAR2 DEFAULT NULL
, p_Work_Type              IN VARCHAR2 DEFAULT NULL
)return PJI_REP_PC7_TBL
is
pragma autonomous_transaction;

l_Project_Cost_Trend_Tab	PJI_REP_PC7_TBL:=PJI_REP_PC7_TBL();

l_Parse_Class_Codes		VARCHAR2(1);
l_Report_Cost_Type		VARCHAR2(2);

l_Cost                    NUMBER:=0;
l_CT_Cost                 NUMBER:=0;
l_Cost_Change_Prcnt       NUMBER:=0;
l_Cap_Cost                NUMBER:=0;
l_CT_Cap_Cost             NUMBER:=0;
l_Cap_Cost_Change_Prcnt   NUMBER:=0;
l_Prcnt_Of_Cost           NUMBER:=0;
l_CT_Prcnt_Of_Cost        NUMBER:=0;
l_Prcnt_Of_Cost_Change    NUMBER:=0;
l_Expense                 NUMBER:=0;
l_CT_Expense              NUMBER:=0;
l_Expense_Change_Prcnt    NUMBER:=0;

l_Top_Organization_Name		VARCHAR2(240);

l_Convert_Classification    VARCHAR2(1);
l_Convert_Expenditure_Type  VARCHAR2(1);
l_Convert_Work_Type         VARCHAR2(1);
l_curr_record_type_id       NUMBER:= 1;

begin
	begin
		select report_cost_type
		into G_Report_Cost_Type
		from pji_system_settings;
	exception
when NO_DATA_FOUND then
	G_Report_Cost_Type:='RC';
end;

	/*
	** Place a call to all the parse API's which parse the
	** parameters passed by PMV and populate all the
	** temporary tables.
	*/

	PJI_PMV_ENGINE.Convert_Operating_Unit(p_Operating_Unit_IDS=>p_Operating_Unit, p_View_BY=>p_View_BY);
	PJI_PMV_ENGINE.Convert_Organization(p_Top_Organization_ID=>p_Organization, p_View_BY=>p_View_BY, p_Top_Organization_Name=>l_Top_Organization_Name);
	PJI_PMV_ENGINE.Convert_Time(p_As_Of_Date=>p_As_Of_Date, p_Period_Type=>p_Period_Type, p_View_BY=>p_View_BY, p_Parse_Prior=>'Y',p_Report_Type=>p_Report_Type);

	/*
	** Determine the fact tables you choose to run the database
	** query on ( this step is what we call manual query re-write).
	*/

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
		select PJI_REP_PC7(
          TIME_ID
         , SUM ( COST )
         , SUM ( CT_COST )
         , SUM ( COST_CHANGE_PRCNT )
         , SUM ( CAP_COST )
         , SUM ( CT_CAPITAL_COST )
         , SUM ( CAP_COST_CHANGE_PRCNT )
         , SUM ( PRCNT_OF_COST )
         , SUM ( CT_PRCNT_OF_COST )
         , SUM ( PRCNT_OF_COST_CHANGE )
         , SUM ( EXPENSE )
         , SUM ( CT_EXPENSE )
         , SUM ( Expense_CHANGE_PRCNT )
         , NULL, NULL, NULL, NULL, NULL, NULL)
bulk collect into l_Project_Cost_Trend_Tab
		from (
			 select /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
                 , decode(NVL(TIME.amount_type,1),1,
                       decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                                 'BC', capital_brdn_cost),0) cost
		 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,'RC', FCT.CAPITALIZABLE_RAW_COST,
                                                    'BC', FCT.CAPITALIZABLE_BRDN_COST),0) CAP_COST
                 , 0 CT_CAPITAL_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                             'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE --8291796
                 , 0 CT_EXPENSE
                 , 0 EXPENSE_CHANGE_PRCNT
			 from
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_FP_ORGO_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 where
				 FCT.ORG_ID = HOU.ID
				 AND FCT.ORGANIZATION_ID = HORG.ID
				 AND FCT.TIME_ID = TIME.ID
				 AND TIME.ID IS NOT NULL
				 AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                 AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 union all
			 select /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 COST
                 , decode(NVL(TIME.amount_type,1),1,
			  decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                                    'BC', capital_brdn_cost),0) CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAPITAL_COST
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', FCT.CAPITALIZABLE_BRDN_COST,
                             'RC', FCT.CAPITALIZABLE_RAW_COST),0)   CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                             'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) CT_EXPENSE --8291796
                 , 0 EXPENSE_CHANGE_PRCNT
        	 from
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_FP_ORGO_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 where
				 FCT.org_id = HOU.id
				 and FCT.organization_id = HORG.id
				 and FCT.time_id = TIME.prior_id
				 and TIME.prior_id is not null
				 and FCT.period_type_id = TIME.period_type
				 and FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 union all
			 select
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 COST
				 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAP_COST
                 , 0 CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , 0 CT_EXPENSE
                 , 0 Expense_CHANGE_PRCNT
        	 from pji_pmv_time_dim_tmp time
			 where name <> '-1')
		 group by
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
		select PJI_REP_PC7(
          TIME_ID
         , SUM ( COST )
         , SUM ( CT_COST )
         , SUM ( COST_CHANGE_PRCNT )
         , SUM ( CAP_COST )
         , SUM ( CT_CAPITAL_COST )
         , SUM ( CAP_COST_CHANGE_PRCNT )
         , SUM ( PRCNT_OF_COST )
         , SUM ( CT_PRCNT_OF_COST )
         , SUM ( PRCNT_OF_COST_CHANGE )
         , SUM ( EXPENSE )
         , SUM ( CT_EXPENSE )
         , SUM ( Expense_CHANGE_PRCNT )
         , NULL, NULL, NULL, NULL, NULL, NULL)
bulk collect into l_Project_Cost_Trend_Tab
		from (
			 select /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
                 , decode(NVL(TIME.amount_type,1),1,
				  decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                                            'BC', capital_brdn_cost),0) cost
				 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , decode(NVL(TIME.amount_type,1),1,
                         decode(G_Report_Cost_Type,'RC', FCT.CAPITALIZABLE_RAW_COST,
                                                   'BC', FCT.CAPITALIZABLE_BRDN_COST),0) CAP_COST
                 , 0 CT_CAPITAL_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                             'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE --8291796
                 , 0 CT_EXPENSE
                 , 0 EXPENSE_CHANGE_PRCNT
			 from
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_CLS_DIM_TMP CLS
				 , PJI_FP_CLSO_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 where
				 FCT.PROJECT_ORG_ID = HOU.ID
				 AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				 AND FCT.TIME_ID = TIME.ID
				 AND TIME.ID IS NOT NULL
				 AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                 AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				 AND FCT.PROJECT_CLASS_ID = CLS.ID
                 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
             union all
			 select /*+ ORDERED */
		   TIME.name time_id
		 , TIME.order_by_id   time_key
		 , 0 COST
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                                    'BC', capital_brdn_cost),0) CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAPITAL_COST
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', FCT.CAPITALIZABLE_BRDN_COST,
                             'RC', FCT.CAPITALIZABLE_RAW_COST),0)   CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                             'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) CT_EXPENSE --8291796
                 , 0 EXPENSE_CHANGE_PRCNT
        	 from
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_CLS_DIM_TMP CLS
				 , PJI_FP_CLSO_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 where
				 FCT.PROJECT_org_id = HOU.id
				 and FCT.PROJECT_organization_id = HORG.id
				 and FCT.time_id = TIME.prior_id
				 and TIME.prior_id is not null
				 and FCT.period_type_id = TIME.period_type
				 and FCT.calendar_type = TIME.calendar_type
				 AND FCT.PROJECT_CLASS_ID =  CLS.ID
                 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			 union all
			 select
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 COST
				 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAP_COST
                 , 0 CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , 0 CT_EXPENSE
                 , 0 Expense_CHANGE_PRCNT
        	 from pji_pmv_time_dim_tmp time
			 where name <> '-1')
		 group by
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
		select PJI_REP_PC7(
          TIME_ID
         , SUM ( COST )
         , SUM ( CT_COST )
         , SUM ( COST_CHANGE_PRCNT )
         , SUM ( CAP_COST )
         , SUM ( CT_CAPITAL_COST )
         , SUM ( CAP_COST_CHANGE_PRCNT )
         , SUM ( PRCNT_OF_COST )
         , SUM ( CT_PRCNT_OF_COST )
         , SUM ( PRCNT_OF_COST_CHANGE )
         , SUM ( EXPENSE )
         , SUM ( CT_EXPENSE )
         , SUM ( Expense_CHANGE_PRCNT )
         , NULL, NULL, NULL, NULL, NULL, NULL)
bulk collect into l_Project_Cost_Trend_Tab
		from (
			 select /*+ ORDERED */
				   TIME.name time_id
		 , TIME.order_by_id   time_key
                 , decode(NVL(TIME.amount_type,1),1,
			 decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                                   'BC', capital_brdn_cost),0) cost
		 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , decode(NVL(TIME.amount_type,1),1,
                         decode(G_Report_Cost_Type,'RC', FCT.CAPITALIZABLE_RAW_COST,
                                                   'BC', FCT.CAPITALIZABLE_BRDN_COST),0) CAP_COST
                 , 0 CT_CAPITAL_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                             'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE --8291796
                 , 0 CT_EXPENSE
                 , 0 EXPENSE_CHANGE_PRCNT
			 from
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_ET_RT_DIM_TMP ET
				 , PJI_FP_ORGO_ET_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 where
				 FCT.ORG_ID = HOU.ID
				 AND FCT.ORGANIZATION_ID = HORG.ID
				 AND FCT.TIME_ID = TIME.ID
				 AND TIME.ID IS NOT NULL
				 AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                 AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                 AND ET.record_type = 'ET'
             union all
			 select /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 COST
                 , decode(NVL(TIME.amount_type,1),1,
				 decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                             'BC', capital_brdn_cost),0) CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAPITAL_COST
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', FCT.CAPITALIZABLE_BRDN_COST,
                             'RC', FCT.CAPITALIZABLE_RAW_COST),0)   CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                             'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) CT_EXPENSE --8291796
                 , 0 EXPENSE_CHANGE_PRCNT
        	 from
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_ET_RT_DIM_TMP ET
				 , PJI_FP_ORGO_ET_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 where
				 FCT.org_id = HOU.id
				 and FCT.organization_id = HORG.id
				 and FCT.time_id = TIME.prior_id
				 and TIME.prior_id is not null
				 and FCT.period_type_id = TIME.period_type
				 and FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and FCT.EXP_EVT_TYPE_ID = ET.ID
                and ET.record_type = 'ET'
			 union all
			 select
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 COST
				 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAP_COST
                 , 0 CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , 0 CT_EXPENSE
                 , 0 Expense_CHANGE_PRCNT
        	 from pji_pmv_time_dim_tmp time
			 where name <> '-1')
		 group by
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
		select PJI_REP_PC7(
          TIME_ID
         , SUM ( COST )
         , SUM ( CT_COST )
         , SUM ( COST_CHANGE_PRCNT )
         , SUM ( CAP_COST )
         , SUM ( CT_CAPITAL_COST )
         , SUM ( CAP_COST_CHANGE_PRCNT )
         , SUM ( PRCNT_OF_COST )
         , SUM ( CT_PRCNT_OF_COST )
         , SUM ( PRCNT_OF_COST_CHANGE )
         , SUM ( EXPENSE )
         , SUM ( CT_EXPENSE )
         , SUM ( Expense_CHANGE_PRCNT )
         , NULL, NULL, NULL, NULL, NULL, NULL)
bulk collect into l_Project_Cost_Trend_Tab
		from (
			 select /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
                 , decode(NVL(TIME.amount_type,1),1,
			 decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                                   'BC', capital_brdn_cost),0) cost
		 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , decode(NVL(TIME.amount_type,1),1,
                       decode(G_Report_Cost_Type,'RC', FCT.CAPITALIZABLE_RAW_COST,
                                                 'BC', FCT.CAPITALIZABLE_BRDN_COST),0) CAP_COST
                 , 0 CT_CAPITAL_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , decode(NVL(TIME.amount_type,1),1,
                       decode(G_Report_Cost_Type,
                             'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                             'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE --8291796
                 , 0 CT_EXPENSE
                 , 0 EXPENSE_CHANGE_PRCNT
			 from
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_WT_DIM_TMP WT
				 , PJI_FP_ORGO_ET_WT_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 where
				 FCT.ORG_ID = HOU.ID
				 AND FCT.ORGANIZATION_ID = HORG.ID
				 AND FCT.TIME_ID = TIME.ID
				 AND TIME.ID IS NOT NULL
				 AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                 AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.WORK_TYPE_ID = WT.ID
             union all
			 select /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 COST
                 , decode(NVL(TIME.amount_type,1),1,
                                  decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                                            'BC', capital_brdn_cost),0) CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAPITAL_COST
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', FCT.CAPITALIZABLE_BRDN_COST,
                             'RC', FCT.CAPITALIZABLE_RAW_COST),0)   CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                             'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) CT_EXPENSE --8291796
                 , 0 EXPENSE_CHANGE_PRCNT
        	 from
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_WT_DIM_TMP WT
				 , PJI_FP_ORGO_ET_WT_F_MV FCT
				 , PJI_PMV_ORG_DIM_TMP HOU
			 where
				 FCT.org_id = HOU.id
				 and FCT.organization_id = HORG.id
				 and FCT.time_id = TIME.prior_id
				 and TIME.prior_id is not null
				 and FCT.period_type_id = TIME.period_type
				 and FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                and FCT.WORK_TYPE_ID = WT.ID
			 union all
			 select
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 COST
				 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAP_COST
                 , 0 CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , 0 CT_EXPENSE
                 , 0 Expense_CHANGE_PRCNT
        	 from pji_pmv_time_dim_tmp time
			 where name <> '-1')
		 group by
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
		select PJI_REP_PC7(
          TIME_ID
         , SUM ( COST )
         , SUM ( CT_COST )
         , SUM ( COST_CHANGE_PRCNT )
         , SUM ( CAP_COST )
         , SUM ( CT_CAPITAL_COST )
         , SUM ( CAP_COST_CHANGE_PRCNT )
         , SUM ( PRCNT_OF_COST )
         , SUM ( CT_PRCNT_OF_COST )
         , SUM ( PRCNT_OF_COST_CHANGE )
         , SUM ( EXPENSE )
         , SUM ( CT_EXPENSE )
         , SUM ( Expense_CHANGE_PRCNT )
         , NULL, NULL, NULL, NULL, NULL, NULL)
bulk collect into l_Project_Cost_Trend_Tab
		from (
			 select /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
                 , decode(NVL(TIME.amount_type,1),1,
                       decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                                 'BC', capital_brdn_cost),0) cost
				 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , decode(NVL(TIME.amount_type,1),1,
                      decode(G_Report_Cost_Type,'RC', FCT.CAPITALIZABLE_RAW_COST,
                                                'BC', FCT.CAPITALIZABLE_BRDN_COST),0) CAP_COST
                 , 0 CT_CAPITAL_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                             'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE
			     --8291796
                 , 0 CT_EXPENSE
                 , 0 EXPENSE_CHANGE_PRCNT
			 from
		   PJI_PMV_TIME_DIM_TMP TIME
		 , PJI_PMV_ORGZ_DIM_TMP HORG
		 , PJI_PMV_CLS_DIM_TMP CLS
                 , PJI_PMV_ET_RT_DIM_TMP ET
		 , PJI_FP_CLSO_ET_F_MV FCT
                 , PJI_PMV_ORG_DIM_TMP HOU
			 where
				 FCT.PROJECT_ORG_ID = HOU.ID
				 AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				 AND FCT.TIME_ID = TIME.ID
				 AND TIME.ID IS NOT NULL
				 AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                 AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.PROJECT_CLASS_ID = CLS.ID
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                 AND ET.record_type = 'ET'
             union all
			 select /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 COST
                  , decode(NVL(TIME.amount_type,1),1,
                        decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                                  'BC', capital_brdn_cost),0) CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAPITAL_COST
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', FCT.CAPITALIZABLE_BRDN_COST,
                             'RC', FCT.CAPITALIZABLE_RAW_COST),0)   CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                             'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) CT_EXPENSE --8291796
                 , 0 EXPENSE_CHANGE_PRCNT
        	 from
		   PJI_PMV_TIME_DIM_TMP TIME
		 , PJI_PMV_ORGZ_DIM_TMP HORG
		 , PJI_PMV_CLS_DIM_TMP CLS
                 , PJI_PMV_ET_RT_DIM_TMP ET
		 , PJI_FP_CLSO_ET_F_MV FCT
                 , PJI_PMV_ORG_DIM_TMP HOU
			 where
				 FCT.PROJECT_org_id = HOU.id
				 and FCT.PROJECT_organization_id = HORG.id
				 and FCT.time_id = TIME.prior_id
				 and TIME.prior_id is not null
				 and FCT.period_type_id = TIME.period_type
				 and FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.PROJECT_CLASS_ID = CLS.ID
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                 AND ET.record_type = 'ET'
			 union all
			 select
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 COST
				 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAP_COST
                 , 0 CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , 0 CT_EXPENSE
                 , 0 Expense_CHANGE_PRCNT
        	 from pji_pmv_time_dim_tmp time
			 where name <> '-1')
		 group by
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
		select PJI_REP_PC7(
          TIME_ID
         , SUM ( COST )
         , SUM ( CT_COST )
         , SUM ( COST_CHANGE_PRCNT )
         , SUM ( CAP_COST )
         , SUM ( CT_CAPITAL_COST )
         , SUM ( CAP_COST_CHANGE_PRCNT )
         , SUM ( PRCNT_OF_COST )
         , SUM ( CT_PRCNT_OF_COST )
         , SUM ( PRCNT_OF_COST_CHANGE )
         , SUM ( EXPENSE )
         , SUM ( CT_EXPENSE )
         , SUM ( Expense_CHANGE_PRCNT )
         , NULL, NULL, NULL, NULL, NULL, NULL)
bulk collect into l_Project_Cost_Trend_Tab
		from (
			 select /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
                 , decode(NVL(TIME.amount_type,1),1,
                         decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                                   'BC', capital_brdn_cost),0) cost
		 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , decode(NVL(TIME.amount_type,1),1,
                        decode(G_Report_Cost_Type,'RC', FCT.CAPITALIZABLE_RAW_COST,
                                                  'BC', FCT.CAPITALIZABLE_BRDN_COST),0) CAP_COST
                 , 0 CT_CAPITAL_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                             'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE  --8291796
                 , 0 CT_EXPENSE
                 , 0 EXPENSE_CHANGE_PRCNT
			 from
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_ET_RT_DIM_TMP ET
				 , PJI_FP_ORGO_ET_WT_F_MV FCT
                 , PJI_PMV_WT_DIM_TMP WT
                 , PJI_PMV_ORG_DIM_TMP HOU
			 where
				 FCT.ORG_ID = HOU.ID
				 AND FCT.ORGANIZATION_ID = HORG.ID
				 AND FCT.TIME_ID = TIME.ID
				 AND TIME.ID IS NOT NULL
				 AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                 AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                 AND FCT.WORK_TYPE_ID = WT.ID
                 and ET.record_type = 'ET'
             union all
			 select /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 COST
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                                    'BC', capital_brdn_cost),0) CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAPITAL_COST
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', FCT.CAPITALIZABLE_BRDN_COST,
                             'RC', FCT.CAPITALIZABLE_RAW_COST),0)   CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                             'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) CT_EXPENSE --8291796
                 , 0 EXPENSE_CHANGE_PRCNT
        	 from
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_ET_RT_DIM_TMP ET
				 , PJI_FP_ORGO_ET_WT_F_MV FCT
                 , PJI_PMV_WT_DIM_TMP WT
                 , PJI_PMV_ORG_DIM_TMP HOU
			 where
    				 FCT.org_id = HOU.id
				 and FCT.organization_id = HORG.id
				 and FCT.time_id = TIME.prior_id
				 and TIME.prior_id is not null
				 and FCT.period_type_id = TIME.period_type
				 and FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                 AND FCT.WORK_TYPE_ID = WT.ID
                 and ET.record_type = 'ET'
			 union all
			 select
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 COST
				 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAP_COST
                 , 0 CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , 0 CT_EXPENSE
                 , 0 Expense_CHANGE_PRCNT
        	 from pji_pmv_time_dim_tmp time
			 where name <> '-1')
		 group by
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
		select PJI_REP_PC7(
          TIME_ID
         , SUM ( COST )
         , SUM ( CT_COST )
         , SUM ( COST_CHANGE_PRCNT )
         , SUM ( CAP_COST )
         , SUM ( CT_CAPITAL_COST )
         , SUM ( CAP_COST_CHANGE_PRCNT )
         , SUM ( PRCNT_OF_COST )
         , SUM ( CT_PRCNT_OF_COST )
         , SUM ( PRCNT_OF_COST_CHANGE )
         , SUM ( EXPENSE )
         , SUM ( CT_EXPENSE )
         , SUM ( Expense_CHANGE_PRCNT )
         , NULL, NULL, NULL, NULL, NULL, NULL)
bulk collect into l_Project_Cost_Trend_Tab
		from (
		 select /*+ ORDERED */
		   TIME.name time_id
		 , TIME.order_by_id   time_key
                 , decode(NVL(TIME.amount_type,1),1,
                        decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                                  'BC', capital_brdn_cost),0) cost
		 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , decode(NVL(TIME.amount_type,1),1,
                      decode(G_Report_Cost_Type,'RC', FCT.CAPITALIZABLE_RAW_COST,
                                                'BC', FCT.CAPITALIZABLE_BRDN_COST),0) CAP_COST
                 , 0 CT_CAPITAL_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                             'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE  --8291796
                 , 0 CT_EXPENSE
                 , 0 EXPENSE_CHANGE_PRCNT
		 from
		   PJI_PMV_TIME_DIM_TMP TIME
		 , PJI_PMV_ORGZ_DIM_TMP HORG
		 , PJI_PMV_CLS_DIM_TMP CLS
		 , PJI_FP_CLSO_ET_WT_F_MV FCT
                 , PJI_PMV_WT_DIM_TMP WT
                 , PJI_PMV_ORG_DIM_TMP HOU
		 where
				 FCT.PROJECT_ORG_ID = HOU.ID
				 AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				 AND FCT.TIME_ID = TIME.ID
				 AND TIME.ID IS NOT NULL
				 AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                 AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.WORK_TYPE_ID = WT.ID
                 AND FCT.PROJECT_CLASS_ID = CLS.ID
             union all
			 select /*+ ORDERED */
		   TIME.name time_id
		 , TIME.order_by_id   time_key
		 , 0 COST
                 , decode(NVL(TIME.amount_type,1),1,
                        decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                                  'BC', capital_brdn_cost),0) CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAPITAL_COST
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', FCT.CAPITALIZABLE_BRDN_COST,
                             'RC', FCT.CAPITALIZABLE_RAW_COST),0)   CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                             'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) CT_EXPENSE --8291796
                 , 0 EXPENSE_CHANGE_PRCNT
        	 from
				   PJI_PMV_TIME_DIM_TMP TIME
				 , PJI_PMV_ORGZ_DIM_TMP HORG
				 , PJI_PMV_CLS_DIM_TMP CLS
				 , PJI_FP_CLSO_ET_WT_F_MV FCT
                 , PJI_PMV_WT_DIM_TMP WT
                 , PJI_PMV_ORG_DIM_TMP HOU
			 where
				 FCT.PROJECT_org_id = HOU.id
				 and FCT.PROJECT_organization_id = HORG.id
				 and FCT.time_id = TIME.prior_id
				 and TIME.prior_id is not null
				 and FCT.period_type_id = TIME.period_type
				 and FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.PROJECT_CLASS_ID = CLS.ID
                 AND FCT.WORK_TYPE_ID = WT.ID
			 union all
			 select
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 COST
				 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAP_COST
                 , 0 CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , 0 CT_EXPENSE
                 , 0 Expense_CHANGE_PRCNT
        	 from pji_pmv_time_dim_tmp time
			 where name <> '-1')
		 group by
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;
/*
** ORGANIZATION, CLASSIFICATION, EXPENDITURE CATEGORY/TYPE AND WORK TYPE Processing:
** All Parameters specified: Organization, Classification, Expenditure Category/Type
** and Work Type is specified
*/

ELSE
		select PJI_REP_PC7(
          TIME_ID
         , SUM ( COST )
         , SUM ( CT_COST )
         , SUM ( COST_CHANGE_PRCNT )
         , SUM ( CAP_COST )
         , SUM ( CT_CAPITAL_COST )
         , SUM ( CAP_COST_CHANGE_PRCNT )
         , SUM ( PRCNT_OF_COST )
         , SUM ( CT_PRCNT_OF_COST )
         , SUM ( PRCNT_OF_COST_CHANGE )
         , SUM ( EXPENSE )
         , SUM ( CT_EXPENSE )
         , SUM ( Expense_CHANGE_PRCNT )
         , NULL, NULL, NULL, NULL, NULL, NULL)
bulk collect into l_Project_Cost_Trend_Tab
		from (
			 select /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
                 , decode(NVL(TIME.amount_type,1),1,
                     decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                               'BC', capital_brdn_cost),0) cost
		 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , decode(NVL(TIME.amount_type,1),1,
                       decode(G_Report_Cost_Type,'RC', FCT.CAPITALIZABLE_RAW_COST,
                                                 'BC', FCT.CAPITALIZABLE_BRDN_COST),0) CAP_COST
                 , 0 CT_CAPITAL_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                              'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                              'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) EXPENSE  --8291796
                 , 0 CT_EXPENSE
                 , 0 EXPENSE_CHANGE_PRCNT
		 from
		   PJI_PMV_TIME_DIM_TMP TIME
		 , PJI_PMV_ORGZ_DIM_TMP HORG
		 , PJI_PMV_ET_RT_DIM_TMP ET
		 , PJI_FP_CLSO_ET_WT_F_MV FCT
                 , PJI_PMV_CLS_DIM_TMP CLS
                 , PJI_PMV_WT_DIM_TMP WT
                 , PJI_PMV_ORG_DIM_TMP HOU
			 where
		 FCT.PROJECT_ORG_ID = HOU.ID
		 AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
		 AND FCT.TIME_ID = TIME.ID
		 AND TIME.ID IS NOT NULL
		 AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                 AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.WORK_TYPE_ID = WT.ID
                 AND FCT.PROJECT_CLASS_ID = CLS.ID
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                and ET.record_type = 'ET'
             union all
			 select /*+ ORDERED */
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 COST
                 , decode(NVL(TIME.amount_type,1),1,
                      decode(G_Report_Cost_Type,'RC', capital_raw_cost,
                                                'BC', capital_brdn_cost),0) CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAPITAL_COST
                 , decode(NVl(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                             'BC', FCT.CAPITALIZABLE_BRDN_COST,
                             'RC', FCT.CAPITALIZABLE_RAW_COST),0)   CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , decode(NVL(TIME.amount_type,1),1,
                          decode(G_Report_Cost_Type,
                                 'BC', NVL(FCT.CAPITAL_BRDN_COST,0) - NVL(FCT.CAPITALIZABLE_BRDN_COST,0),
                                 'RC', NVL(FCT.CAPITAL_RAW_COST,0) - NVL(FCT.CAPITALIZABLE_RAW_COST,0)),0) CT_EXPENSE --8291796
                 , 0 EXPENSE_CHANGE_PRCNT
        	 from
		   PJI_PMV_TIME_DIM_TMP TIME
		 , PJI_PMV_ORGZ_DIM_TMP HORG
		 , PJI_PMV_ET_RT_DIM_TMP ET
		 , PJI_FP_CLSO_ET_WT_F_MV FCT
                 , PJI_PMV_CLS_DIM_TMP CLS
                 , PJI_PMV_WT_DIM_TMP WT
                 , PJI_PMV_ORG_DIM_TMP HOU
			 where
				 FCT.PROJECT_org_id = HOU.id
				 and FCT.PROJECT_organization_id = HORG.id
				 and FCT.time_id = TIME.prior_id
				 and TIME.prior_id is not null
				 and FCT.period_type_id = TIME.period_type
				 and FCT.calendar_type = TIME.calendar_type
				 AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
                 AND FCT.WORK_TYPE_ID = WT.ID
                 AND FCT.PROJECT_CLASS_ID = CLS.ID
                 AND FCT.EXP_EVT_TYPE_ID = ET.ID
                and ET.record_type = 'ET'
			 union all
			 select
				   TIME.name time_id
				 , TIME.order_by_id   time_key
				 , 0 COST
				 , 0 CT_COST
                 , 0 COST_CHANGE_PRCNT
                 , 0 CAP_COST
                 , 0 CT_CAP_COST
                 , 0 CAP_COST_CHANGE_PRCNT
                 , 0 PRCNT_OF_COST
                 , 0 CT_PRCNT_OF_COST
                 , 0 PRCNT_OF_COST_CHANGE
                 , 0 EXPENSE
                 , 0 CT_EXPENSE
                 , 0 Expense_CHANGE_PRCNT
        	 from pji_pmv_time_dim_tmp time
			 where name <> '-1')
		 group by
		   TIME_KEY
		 , TIME_ID ORDER BY TIME_KEY ASC;
	end if;

for i in 1..l_Project_Cost_Trend_Tab.COUNT
	loop
		if p_Report_Type = 'FISCAL' then

            l_Cost        := l_Cost       + l_Project_Cost_Trend_Tab(i).COST;
            l_CT_Cost     := l_CT_Cost    + l_Project_Cost_Trend_Tab(i).CT_COST;
            l_Cap_Cost    :=l_Cap_Cost    + l_Project_Cost_Trend_Tab(i).CAP_COST;
            l_CT_Cap_Cost :=l_CT_Cap_Cost + l_Project_Cost_Trend_Tab(i).CT_CAP_COST;
            l_Expense     :=l_Expense     + l_Project_Cost_Trend_Tab(i).EXPENSE;
            l_CT_Expense  :=l_CT_Expense  + l_Project_Cost_Trend_Tab(i).CT_EXPENSE;

			l_Project_Cost_Trend_Tab(i).COST         :=l_Cost;
			l_Project_Cost_Trend_Tab(i).CT_COST      :=l_CT_Cost;
			l_Project_Cost_Trend_Tab(i).CAP_COST     :=l_Cap_Cost;
            l_Project_Cost_Trend_Tab(i).CT_CAP_COST  :=l_CT_Cap_Cost;
            l_Project_Cost_Trend_Tab(i).EXPENSE      :=l_Expense;
            l_Project_Cost_Trend_Tab(i).CT_EXPENSE   :=l_CT_Expense;

       end if;

		if nvl(l_Project_Cost_Trend_Tab(i).CT_COST,0) <> 0 then
				l_Project_Cost_Trend_Tab(i).COST_CHANGE_PRCNT := 100*
			((l_Project_Cost_Trend_Tab(i).COST-l_Project_Cost_Trend_Tab(i).CT_COST)
			/abs(l_Project_Cost_Trend_Tab(i).CT_COST));
		else
			l_Project_Cost_Trend_Tab(i).COST_CHANGE_PRCNT := null;
		end if;

		if nvl(l_Project_Cost_Trend_Tab(i).CT_CAP_COST,0) <> 0 then
				l_Project_Cost_Trend_Tab(i).CAP_COST_CHANGE_PRCNT := 100*
			((l_Project_Cost_Trend_Tab(i).CAP_COST-l_Project_Cost_Trend_Tab(i).CT_CAP_COST)
			/abs(l_Project_Cost_Trend_Tab(i).CT_CAP_COST));
		else
			l_Project_Cost_Trend_Tab(i).CAP_COST_CHANGE_PRCNT := null;
		end if;

		if nvl(l_Project_Cost_Trend_Tab(i).COST,0) <> 0 then
				l_Project_Cost_Trend_Tab(i).PRCNT_OF_COST := 100*
			((l_Project_Cost_Trend_Tab(i).CAP_COST)
			/abs(l_Project_Cost_Trend_Tab(i).COST));
		else
			l_Project_Cost_Trend_Tab(i).PRCNT_OF_COST := null;
		end if;

		if nvl(l_Project_Cost_Trend_Tab(i).CT_COST,0) <> 0 then
				l_Project_Cost_Trend_Tab(i).CT_PRCNT_OF_COST := 100*
			((l_Project_Cost_Trend_Tab(i).CT_CAP_COST)
			/abs(l_Project_Cost_Trend_Tab(i).CT_COST));
		else
			l_Project_Cost_Trend_Tab(i).CT_PRCNT_OF_COST := null;
		end if;

		l_Project_Cost_Trend_Tab(i).PRCNT_OF_COST_CHANGE :=
				l_Project_Cost_Trend_Tab(i).PRCNT_OF_COST -
                				l_Project_Cost_Trend_Tab(i).CT_PRCNT_OF_COST;

		if nvl(l_Project_Cost_Trend_Tab(i).CT_EXPENSE,0) <> 0 then
				l_Project_Cost_Trend_Tab(i).EXPENSE_CHANGE_PRCNT := 100*
			((l_Project_Cost_Trend_Tab(i).EXPENSE - l_Project_Cost_Trend_Tab(i).CT_EXPENSE)
			/abs(l_Project_Cost_Trend_Tab(i).CT_EXPENSE));
		else
			l_Project_Cost_Trend_Tab(i).EXPENSE_CHANGE_PRCNT := null;
		end if;
	END LOOP;
COMMIT;
RETURN l_Project_Cost_Trend_Tab;
END PLSQLDriver_PJI_REP_PC7;


/*
** Projects Capital Cost Detail Report
*/


FUNCTION  PLSQLDriver_PJI_REP_PC9(
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
         )  RETURN PJI_REP_PC9_TBL
	IS

        PRAGMA AUTONOMOUS_TRANSACTION;

/*
**         PL/SQL Declaration
*/
	l_detail_tab		PJI_REP_PC9_TBL := PJI_REP_PC9_TBL();

	l_Cost				        NUMBER := 0;
	l_Capital_Cost			    NUMBER := 0;
	l_Cap_Cost_Percent_Of_Cost	NUMBER := 0;
	l_Expense	                NUMBER := 0;


l_Convert_Classification    VARCHAR2(1);
l_Convert_Expenditure_Type  VARCHAR2(1);
l_Convert_Work_Type         VARCHAR2(1);
l_curr_record_type_id       NUMBER:= 1;
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

	l_Convert_Classification := PJI_PMV_ENGINE.Convert_Classification
                            (p_Classifications, p_Class_Codes, p_View_BY);

    l_Convert_Expenditure_Type := PJI_PMV_ENGINE.Convert_Expenditure_Type
                            (p_Expenditure_Category, p_Expenditure_Type, p_View_BY);

    l_Convert_Work_Type := PJI_PMV_ENGINE.Convert_Work_Type
                            (p_Work_Type, p_View_BY);
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
							WHERE class_category = '$PROJECT_TYPE$CAPITAL') PJC
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
                        AND pjm.class_category = '$PROJECT_TYPE$CAPITAL';

		   END IF;
		END;

	ELSE
	PJI_PMV_ENGINE.Convert_Project(P_PROJECT_IDS=>p_Project_IDS
						, P_VIEW_BY =>p_View_BY);
	END IF;

/*
**           ORG Processing
*/

 IF  (l_Convert_Classification = 'N')
 and (l_Convert_Expenditure_Type = 'N')
 and (l_Convert_Work_Type = 'N')
          THEN
	SELECT PJI_REP_PC9 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM (COST)
            , SUM (CAPITAL_COST)
            , NULL
            , SUM (EXPENSE)
            , NULL
            , NULL
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
		  FCT.PROJECT_ID                                             AS PROJECT_ID
		, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
		, DECODE(NVL(TIME.amount_type,1),1,
                DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                            'RC', fct.raw_cost, 0), 0) AS COST
		, DECODE(NVL(TIME.amount_type,1),1,
                DECODE(G_Report_Cost_Type,  'BC', fct.capitalizable_brdn_cost,
                                            'RC', fct.capitalizable_raw_cost, 0), 0)  AS CAPITAL_COST
                , DECODE(NVL(TIME.amount_type,1),1,
                DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost - fct.capitalizable_brdn_cost,
                                            'RC', fct.raw_cost - fct.capitalizable_raw_cost, 0), 0) AS EXPENSE
		FROM  PJI_PMV_TIME_DIM_TMP TIME
    		, PJI_PMV_ORGZ_DIM_TMP HORG
                , PJI_PMV_PRJ_DIM_TMP PRJ
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
			SELECT PJI_REP_PC9 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(COST)
			, SUM(CAPITAL_COST)
			, NULL
			, SUM(EXPENSE)
			, NULL
			, NULL
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(NVL(TIME.amount_type,1),1,
                        DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                    'RC', fct.raw_cost),0)   AS COST
					, DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.capitalizable_brdn_cost,
                                                        'RC', fct.capitalizable_raw_cost),0)  AS CAPITAL_COST
			        , DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost - fct.capitalizable_brdn_cost,
                                                        'RC', fct.raw_cost - fct.capitalizable_raw_cost),0) AS EXPENSE
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
        	SELECT PJI_REP_PC9 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(COST)
			, SUM(CAPITAL_COST)
			, NULL
			, SUM(EXPENSE)
			, NULL
			, NULL
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost),0) AS COST
					, DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.capitalizable_brdn_cost,
                                                        'RC', fct.capitalizable_raw_cost),0)  AS CAPITAL_COST
			        , DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost - fct.capitalizable_brdn_cost,
                                                        'RC', fct.raw_cost - fct.capitalizable_raw_cost),0) AS EXPENSE
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
        	SELECT PJI_REP_PC9 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(COST)
			, SUM(CAPITAL_COST)
			, NULL
			, SUM(EXPENSE)
			, NULL
			, NULL
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost),0) AS COST
					, DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.capitalizable_brdn_cost,
                                                        'RC', fct.capitalizable_raw_cost),0)  AS CAPITAL_COST
			        , DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost - fct.capitalizable_brdn_cost,
                                                        'RC', fct.raw_cost - fct.capitalizable_raw_cost),0) AS EXPENSE
					FROM   PJI_PMV_TIME_DIM_TMP TIME
						, PJI_PMV_WT_DIM_TMP WT
						, PJI_PMV_PRJ_DIM_TMP PRJ
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
       	SELECT PJI_REP_PC9 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(COST)
			, SUM(CAPITAL_COST)
			, NULL
			, SUM(EXPENSE)
			, NULL
			, NULL
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost),0) AS COST
					, DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.capitalizable_brdn_cost,
                                                        'RC', fct.capitalizable_raw_cost),0)  AS CAPITAL_COST
			        , DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost - fct.capitalizable_brdn_cost,
                                                        'RC', fct.raw_cost - fct.capitalizable_raw_cost),0) AS EXPENSE
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
          	SELECT PJI_REP_PC9 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(COST)
			, SUM(CAPITAL_COST)
			, NULL
			, SUM(EXPENSE)
			, NULL
			, NULL
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost),0) AS COST
					, DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.capitalizable_brdn_cost,
                                                        'RC', fct.capitalizable_raw_cost),0)  AS CAPITAL_COST
			        , DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost - fct.capitalizable_brdn_cost,
                                                        'RC', fct.raw_cost - fct.capitalizable_raw_cost),0) AS EXPENSE
					FROM   PJI_PMV_TIME_DIM_TMP TIME
						, PJI_PMV_ET_RT_DIM_TMP ET
						, PJI_PMV_WT_DIM_TMP WT
						, PJI_PMV_PRJ_DIM_TMP PRJ
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
          THEN

       	SELECT PJI_REP_PC9 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(COST)
			, SUM(CAPITAL_COST)
			, NULL
			, SUM(EXPENSE)
			, NULL
			, NULL
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost), 0) AS COST
					, DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.capitalizable_brdn_cost,
                                                        'RC', fct.capitalizable_raw_cost), 0)  AS CAPITAL_COST
			        , DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost - fct.capitalizable_brdn_cost,
                                                        'RC', fct.raw_cost - fct.capitalizable_raw_cost), 0) AS EXPENSE
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
SELECT PJI_REP_PC9 (PROJECT_ID
			, NULL
			, NULL
			, PJI_PMV_UTIL.Drill_To_Proj_Perf_URL(PROJECT_ID, l_curr_record_type_id, p_As_of_Date,p_Period_Type)
			, NULL
			, NULL
			, ORGANIZATION_ID
			, NULL
			, SUM(COST)
			, SUM(CAPITAL_COST)
			, NULL
			, SUM(EXPENSE)
			, NULL
			, NULL
			, 0, 0, 0, 0, 0, 0)
			BULK COLLECT INTO l_detail_tab
			FROM
				(SELECT  /*+ ORDERED */
					  FCT.PROJECT_ID                                             AS PROJECT_ID
					, FCT.PROJECT_ORGANIZATION_ID                                AS ORGANIZATION_ID
					, DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost,
                                                        'RC', fct.raw_cost),0) AS COST
					, DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.capitalizable_brdn_cost,
                                                        'RC', fct.capitalizable_raw_cost),0)  AS CAPITAL_COST
			        , DECODE(NVL(TIME.amount_type,1),1,
                            DECODE(G_Report_Cost_Type,  'BC', fct.burdened_cost - fct.capitalizable_brdn_cost,
                                                        'RC', fct.raw_cost - fct.capitalizable_raw_cost),0) AS EXPENSE
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
			l_detail_tab(i).CAP_COST_PERCENT_OF_COST := 100*((l_detail_tab(i).CAPITAL_COST)/ABS(l_detail_tab(i).COST));
		ELSE
			l_detail_tab(i).CAP_COST_PERCENT_OF_COST := NULL;
		END IF;

		l_Cost     := l_Cost     + NVL(l_detail_tab(i).COST , 0);
		l_Capital_Cost := l_Capital_Cost + NVL(l_detail_tab(i).CAPITAL_COST, 0);
		l_Expense  := l_Expense  + NVL(l_detail_tab(i).EXPENSE , 0);

	END LOOP;

	FOR i IN 1..l_detail_tab.COUNT
	LOOP
		l_detail_tab(i).PJI_REP_TOTAL_1:=l_Cost;
		l_detail_tab(i).PJI_REP_TOTAL_2:=l_Capital_Cost;
		l_detail_tab(i).PJI_REP_TOTAL_4:=l_Expense;


		IF NVL(l_detail_tab(i).PJI_REP_TOTAL_1, 0) <> 0 THEN
			l_detail_tab(i).PJI_REP_TOTAL_3 := 100*((l_detail_tab(i).PJI_REP_TOTAL_2)/ABS(l_detail_tab(i).PJI_REP_TOTAL_1));
		ELSE
			l_detail_tab(i).PJI_REP_TOTAL_3 := NULL;
		END IF;

	END LOOP;
/*
** Return the bulk collected table back to pmv.
*/
COMMIT;
RETURN l_detail_tab;


END PLSQLDriver_PJI_REP_PC9;


end PJI_PMV_CAPITAL_COST;

/
