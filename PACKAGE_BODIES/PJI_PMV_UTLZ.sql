--------------------------------------------------------
--  DDL for Package Body PJI_PMV_UTLZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PMV_UTLZ" AS
/* $Header: PJIRR02B.pls 120.2 2005/12/07 20:53:36 appldev ship $ */

PROCEDURE Get_SQL_PJI_REP_UAP1(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
BEGIN

    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL  => p_page_parameter_tbl
                               ,P_SELECT_LIST         =>
                               ' FACT.BILL_HOURS_PERCENT     "PJI_REP_MSR_3",
                                 FACT.CHANGE_PERCENT_2       "PJI_REP_MSR_20",
                                 FACT.ACT_UTIL_PERCENT       "PJI_REP_MSR_2",
                                 FACT.CHANGE_PERCENT_1       "PJI_REP_MSR_10",
                                 FACT.RES_HOURS_PERCENT      "PJI_REP_MSR_4",
                                 FACT.CHANGE_PERCENT_3       "PJI_REP_MSR_21",
                                 FACT.ACTUAL_UTIL_HOURS      "PJI_REP_MSR_5",
                                 FACT.ACTUAL_DENOMINATOR     "PJI_REP_MSR_6",
                                 FACT.RESOURCE_HOURS         "PJI_REP_MSR_7",
                                 FACT.TOTAL_RESOURCE_HOURS   "PJI_REP_MSR_8",
                                 FACT.BILLABLE_HOURS         "PJI_REP_MSR_9",
                                 FACT.PRIOR_ACTUAL_UTIL_HOURS  "PJI_REP_MSR_11",
                                 FACT.PRIOR_ACTUAL_DENOMINATOR "PJI_REP_MSR_12",
                                 FACT.PRIOR_RESOURCE_HOURS   "PJI_REP_MSR_13",
                                 FACT.PRIOR_TOTAL_RESOURCE_HOURS "PJI_REP_MSR_14",
                                 FACT.PRIOR_BILLABLE_HOURS   "PJI_REP_MSR_15",
                                 FACT.PRIOR_RES_HOURS_PERCENT "PJI_REP_MSR_16",
                                 FACT.PRIOR_ACT_UTIL_PERCENT  "PJI_REP_MSR_17",
                                 FACT.PRIOR_BILL_HOURS_PERCENT "PJI_REP_MSR_18",
                                 FACT.BILL_HOURS_PERCENT     "PJI_REP_MSR_19",
                                 FACT.ACT_UTIL_PERCENT       "PJI_REP_MSR_22",
                                 FACT.RES_HOURS_PERCENT      "PJI_REP_MSR_23",
                                 FACT.PJI_REP_TOTAL_1        "PJI_REP_TOTAL_1",
                                 FACT.PJI_REP_TOTAL_2        "PJI_REP_TOTAL_2",
                                 FACT.PJI_REP_TOTAL_3        "PJI_REP_TOTAL_3",
                                 FACT.PJI_REP_TOTAL_4        "PJI_REP_TOTAL_4",
                                 FACT.PJI_REP_TOTAL_5        "PJI_REP_TOTAL_5",
                                 FACT.PJI_REP_TOTAL_6        "PJI_REP_TOTAL_6",
                                 FACT.PJI_REP_TOTAL_7        "PJI_REP_TOTAL_7",
                                 FACT.PJI_REP_TOTAL_8        "PJI_REP_TOTAL_8",
                                 FACT.PJI_REP_TOTAL_9        "PJI_REP_TOTAL_9",
                                 FACT.PJI_REP_TOTAL_1        "PJI_REP_TOTAL_12",
                                 FACT.PJI_REP_TOTAL_3        "PJI_REP_TOTAL_14",
                                 FACT.PJI_REP_TOTAL_5        "PJI_REP_TOTAL_16" '
                               ,P_SQL_STATEMENT       => x_PMV_Sql
                               ,P_PMV_OUTPUT          => x_PMV_Output,
                                P_REGION_CODE         => 'PJI_REP_UAP1',
                                P_PLSQL_DRIVER        => 'PJI_PMV_UTLZ.PLSQLDriver_U1',
                                P_PLSQL_DRIVER_PARAMS =>   '<<ORGANIZATION+FII_OPERATING_UNITS>>, ' ||
                                                           '<<ORGANIZATION+PJI_ORGANIZATIONS>>, ' ||
                                                           '<<AS_OF_DATE>>, ' ||
                                                           '<<PERIOD_TYPE>>, ' ||
                                                           '<<TIME_COMPARISON_TYPE>>, ' ||
                                                           '<<VIEW_BY>>');
END Get_SQL_PJI_REP_UAP1;


PROCEDURE Get_SQL_PJI_REP_U1(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
BEGIN

    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL  => p_page_parameter_tbl
                               ,P_SELECT_LIST         =>
                               ' FACT.ACT_UTIL_PERCENT        "PJI_REP_MSR_1",
                                 FACT.CHANGE_PERCENT_1        "PJI_REP_MSR_19",
                                 FACT.SCH_UTIL_PERCENT        "PJI_REP_MSR_2",
                                 FACT.SCH_VAR_PERCENT         "PJI_REP_MSR_10",
                                 FACT.BILL_HOURS_PERCENT      "PJI_REP_MSR_3",
                                 FACT.CHANGE_PERCENT_2        "PJI_REP_MSR_20",
                                 FACT.MISSING_HOURS           "PJI_REP_MSR_4",
                                 FACT.MISSING_HOURS_PERCENT   "PJI_REP_MSR_21",
                                 FACT.ACTUAL_UTIL_HOURS       "PJI_REP_MSR_5",
                                 FACT.ACTUAL_DENOMINATOR      "PJI_REP_MSR_6",
                                 FACT.SCHEDULED_UTIL_HOURS    "PJI_REP_MSR_7",
                                 FACT.SCHEDULED_DENOMINATOR   "PJI_REP_MSR_8",
                                 FACT.BILLABLE_HOURS          "PJI_REP_MSR_9",
                                 FACT.PRIOR_ACTUAL_UTIL_HOURS "PJI_REP_MSR_11",
                                 FACT.PRIOR_ACTUAL_DENOMINATOR "PJI_REP_MSR_12",
                                 FACT.PRIOR_SCH_UTIL_HOURS    "PJI_REP_MSR_13",
                                 FACT.PRIOR_SCHEDULED_DENOMINATOR "PJI_REP_MSR_14",
                                 FACT.PRIOR_BILLABLE_HOURS    "PJI_REP_MSR_15",
                                 FACT.PRIOR_MISSING_HOURS     "PJI_REP_MSR_16",
                                 FACT.PRIOR_ACT_UTIL_PERCENT  "PJI_REP_MSR_17",
                                 FACT.PRIOR_BILL_HOURS_PERCENT "PJI_REP_MSR_18",
                                 FACT.ACT_UTIL_PERCENT         "PJI_REP_MSR_23",
                                 FACT.SCH_UTIL_PERCENT         "PJI_REP_MSR_24",
                                 FACT.BILL_HOURS_PERCENT       "PJI_REP_MSR_25",
                                 FACT.MISSING_HOURS            "PJI_REP_MSR_26",
                                 FACT.PJI_REP_TOTAL_3          "PJI_REP_TOTAL_1",
                                 FACT.PJI_REP_TOTAL_8          "PJI_REP_TOTAL_2",
                                 FACT.PJI_REP_TOTAL_10         "PJI_REP_TOTAL_3",
                                 FACT.PJI_REP_TOTAL_12         "PJI_REP_TOTAL_4",
                                 FACT.PJI_REP_TOTAL_1          "PJI_REP_TOTAL_5",
                                 FACT.PJI_REP_TOTAL_7          "PJI_REP_TOTAL_6",
                                 FACT.PJI_REP_TOTAL_13         "PJI_REP_TOTAL_7",
                                 FACT.PJI_REP_TOTAL_11         "PJI_REP_TOTAL_8" '
                               ,P_SQL_STATEMENT       => x_PMV_Sql
                               ,P_PMV_OUTPUT          => x_PMV_Output,
                                P_REGION_CODE         => 'PJI_REP_U1',
                                P_PLSQL_DRIVER        => 'PJI_PMV_UTLZ.PLSQLDriver_U1',
                                P_PLSQL_DRIVER_PARAMS =>   '<<ORGANIZATION+FII_OPERATING_UNITS>>, ' ||
                                                           '<<ORGANIZATION+PJI_ORGANIZATIONS>>, ' ||
                                                           '<<AS_OF_DATE>>, ' ||
                                                           '<<PERIOD_TYPE>>, ' ||
                                                           '<<TIME_COMPARISON_TYPE>>, ' ||
                                                           '<<VIEW_BY>>,'||
                                       '<<PROJECT WORK TYPE+PJI_UTIL_CATEGORIES>>, ' ||
                                       '<<PROJECT WORK TYPE+PJI_WORK_TYPES>>, ' ||
                                       '<<PROJECT JOB LEVEL+PJI_JOB_LEVELS>>');
END Get_SQL_PJI_REP_U1;


PROCEDURE Get_SQL_PJI_REP_U2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
BEGIN

    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL  => p_page_parameter_tbl
                               ,P_SELECT_LIST         =>
                               ' FACT.ACTUAL_CAPACITY_HOURS  "PJI_REP_MSR_1",
                                 FACT.MISSING_HOURS  "PJI_REP_MSR_2",
		                         FACT.ACTUAL_UTILIZATION_HOURS  "PJI_REP_MSR_3",
		                         FACT.ACT_UTIL_PERCENT  "PJI_REP_MSR_4",
		                         FACT.BILL_UTIL_PERCENT  "PJI_REP_MSR_6",
		                         FACT.NONBILL_UTIL_PERCENT  "PJI_REP_MSR_7",
		                         FACT.TRAINING_PERCENT  "PJI_REP_MSR_20",
		                         FACT.SCHEDULED_CAPACITY_HOURS  "PJI_REP_MSR_5",
		                         FACT.CONF_SCHEDULED_HOURS  "PJI_REP_MSR_8",
		                         FACT.PROV_SCHEDULED_HOURS  "PJI_REP_MSR_9",
		                         FACT.SCHEDULED_UTILIZATION_HOURS  "PJI_REP_MSR_10",
		                         FACT.SCH_UTIL_PERCENT  "PJI_REP_MSR_17",
		                         FACT.PRIOR_UTIL_PERCENT  "PJI_REP_MSR_18",
		                         FACT.BILLABLE_HOURS  "PJI_REP_MSR_11",
		                         FACT.NONBILLABLE_HOURS  "PJI_REP_MSR_12",
		                         FACT.TRAINING_HOURS  "PJI_REP_MSR_13",
		                         FACT.PRIOR_ACTUAL_UTIL_HOURS  "PJI_REP_MSR_14",
		                         FACT.PRIOR_ACTUAL_DENOMINATOR  "PJI_REP_MSR_15",
		                         FACT.SCHEDULED_DENOMINATOR  "PJI_REP_MSR_19",
		                         FACT.ACTUAL_DENOMINATOR  "PJI_REP_MSR_23",
		                         FACT.PRIOR_UTIL_PERCENT  "PJI_REP_MSR_24",
		                         FACT.ACT_UTIL_PERCENT  "PJI_REP_MSR_25",
		                         FACT.SCH_UTIL_PERCENT  "PJI_REP_MSR_26" '
                               ,P_SQL_STATEMENT       => x_PMV_Sql
                               ,P_PMV_OUTPUT          => x_PMV_Output,
                                P_REGION_CODE         => 'PJI_REP_U2',
                                P_PLSQL_DRIVER        => 'PJI_PMV_UTLZ.PLSQLDriver_U2',
                                P_PLSQL_DRIVER_PARAMS =>   '<<ORGANIZATION+FII_OPERATING_UNITS>>, ' ||
                                                           '<<ORGANIZATION+PJI_ORGANIZATIONS>>, ' ||
                                                           '<<AS_OF_DATE>>, ' ||
                                                           '<<PERIOD_TYPE>>, ' ||
                                                           '<<VIEW_BY>>');
END Get_SQL_PJI_REP_U2;


PROCEDURE Get_SQL_PJI_REP_U3(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
BEGIN

    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL  => p_page_parameter_tbl
                               ,P_SELECT_LIST         =>
                               ' FACT.ACTUAL_HOURS  "PJI_REP_MSR_11",
		                         FACT.CAPACITY_HOURS  "PJI_REP_MSR_16",
		                         FACT.MISSING_HOURS  "PJI_REP_MSR_15",
		                         FACT.UTILIZATION_HOURS  "PJI_REP_MSR_1",
		                         FACT.UTIL_PERCENT  "PJI_REP_MSR_2",
		                         FACT.BILL_PERCENT  "PJI_REP_MSR_3",
		                         FACT.NON_BILL_PERCENT  "PJI_REP_MSR_4",
		                         FACT.TRAINING_PERCENT  "PJI_REP_MSR_5",
		                         FACT.PRIOR_ACTUAL_HOURS  "PJI_REP_MSR_12",
		                         FACT.PRIOR_CAPACITY_HOURS  "PJI_REP_MSR_19",
		                         FACT.PRIOR_UTIL_PERCENT  "PJI_REP_MSR_20",
		                         FACT.PRIOR_BILL_PERCENT  "PJI_REP_MSR_21",
		                         FACT.PRIOR_NON_BILL_PERCENT  "PJI_REP_MSR_22",
		                         FACT.PRIOR_TRAINING_PERCENT  "PJI_REP_MSR_23",
		                         FACT.PRIOR_BILL_PERCENT  "PJI_REP_MSR_10",
		                         FACT.BILL_PERCENT  "PJI_REP_MSR_30",
		                         FACT.PRIOR_NON_BILL_PERCENT  "PJI_REP_MSR_8",
		                         FACT.NON_BILL_PERCENT  "PJI_REP_MSR_9",
		                         FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1",
		                         FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_2",
		                         FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_3",
		                         FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_4",
		                         FACT.PJI_REP_TOTAL_5 "PJI_REP_TOTAL_5",
		                         FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_6",
		                         FACT.PJI_REP_TOTAL_7 "PJI_REP_TOTAL_7",
		                         FACT.PJI_REP_TOTAL_8 "PJI_REP_TOTAL_8",
		                         FACT.PJI_REP_TOTAL_9 "PJI_REP_TOTAL_9",
		                         FACT.PJI_REP_TOTAL_10 "PJI_REP_TOTAL_10",
		                         FACT.PJI_REP_TOTAL_11 "PJI_REP_TOTAL_11",
		                         FACT.PJI_REP_TOTAL_12 "PJI_REP_TOTAL_12",
		                         FACT.PJI_REP_TOTAL_13 "PJI_REP_TOTAL_13",
		                         FACT.PJI_REP_TOTAL_14 "PJI_REP_TOTAL_14" '
                               ,P_SQL_STATEMENT       => x_PMV_Sql
                               ,P_PMV_OUTPUT          => x_PMV_Output,
                                P_REGION_CODE         => 'PJI_REP_U3',
                                P_PLSQL_DRIVER        => 'PJI_PMV_UTLZ.PLSQLDriver_U3',
                                P_PLSQL_DRIVER_PARAMS =>   '<<ORGANIZATION+FII_OPERATING_UNITS>>, ' ||
                                                           '<<ORGANIZATION+PJI_ORGANIZATIONS>>, ' ||
                                                           '<<AS_OF_DATE>>, ' ||
                                                           '<<PERIOD_TYPE>>, ' ||
                                                           '<<VIEW_BY>>,'||
                                       '<<PROJECT WORK TYPE+PJI_UTIL_CATEGORIES>>, ' ||
                                       '<<PROJECT WORK TYPE+PJI_WORK_TYPES>>, ' ||
                                       '<<PROJECT JOB LEVEL+PJI_JOB_LEVELS>>');
END Get_SQL_PJI_REP_U3;


PROCEDURE Get_SQL_PJI_REP_U4(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_PMV_Rec           BIS_QUERY_ATTRIBUTES;
BEGIN

    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL  => p_page_parameter_tbl
                               ,P_SELECT_LIST         =>
                               ' FACT.SCHEDULED_HOURS  "PJI_REP_MSR_17",
                           		 FACT.SCHEDULED_CAPACITY_HOURS  "PJI_REP_MSR_18",
                           		 FACT.SCHEDULED_UTIL_HOURS  "PJI_REP_MSR_1",
                           		 FACT.PROVISIONAL_HOURS  "PJI_REP_MSR_2",
                           		 FACT.PRIOR_SCHEDULED_HOURS  "PJI_REP_MSR_3",
                           		 FACT.SCH_UTIL_PERCENT  "PJI_REP_MSR_4",
                           		 FACT.BILL_UTIL_PERCENT  "PJI_REP_MSR_7",
                           		 FACT.NONBILL_UTIL_PERCENT  "PJI_REP_MSR_5",
                           		 FACT.UNASSIGNED_PERCENT  "PJI_REP_MSR_6",
                           		 FACT.TRAINING_PERCENT  "PJI_REP_MSR_13",
                           		 FACT.PROV_BILL_PERCENT  "PJI_REP_MSR_11",
                           		 FACT.PROV_NONBILL_PERCENT  "PJI_REP_MSR_12",
                           		 FACT.PRIOR_SCH_UTIL_PERCENT  "PJI_REP_MSR_14",
                           		 FACT.PRIOR_BILL_UTIL_PERCENT  "PJI_REP_MSR_15",
                           		 FACT.PRIOR_NONBILL_UTIL_PERCENT  "PJI_REP_MSR_16",
                           		 FACT.PRIOR_BILL_UTIL_PERCENT  "PJI_MSR2",
                           		 FACT.BILL_UTIL_PERCENT  "PJI_REP_MSR_29",
                           		 FACT.PRIOR_NONBILL_UTIL_PERCENT  "PJI_MSR3",
                           		 FACT.NONBILL_UTIL_PERCENT  "PJI_MSR1",
                           		 FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1",
                           		 FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_2",
                           		 FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_3",
                           		 FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_4",
                           		 FACT.PJI_REP_TOTAL_7 "PJI_REP_TOTAL_5",
                           		 FACT.PJI_REP_TOTAL_8 "PJI_REP_TOTAL_6",
                           		 FACT.PJI_REP_TOTAL_9 "PJI_REP_TOTAL_7",
                           		 FACT.PJI_REP_TOTAL_10 "PJI_REP_TOTAL_8",
                           		 FACT.PJI_REP_TOTAL_11 "PJI_REP_TOTAL_9",
                           		 FACT.PJI_REP_TOTAL_12 "PJI_REP_TOTAL_10",
                           		 FACT.PJI_REP_TOTAL_13 "PJI_REP_TOTAL_11",
                           		 FACT.PJI_REP_TOTAL_14 "PJI_REP_TOTAL_12",
                           		 FACT.PJI_REP_TOTAL_15 "PJI_REP_TOTAL_13",
                           		 FACT.PJI_REP_TOTAL_16 "PJI_REP_TOTAL_14",
                           		 FACT.PJI_REP_TOTAL_17 "PJI_REP_TOTAL_15" '
                               ,P_SQL_STATEMENT       => x_PMV_Sql
                               ,P_PMV_OUTPUT          => x_PMV_Output,
                                P_REGION_CODE         => 'PJI_REP_U4',
                                P_PLSQL_DRIVER        => 'PJI_PMV_UTLZ.PLSQLDriver_U4',
                                P_PLSQL_DRIVER_PARAMS =>   '<<ORGANIZATION+FII_OPERATING_UNITS>>, ' ||
                                                           '<<ORGANIZATION+PJI_ORGANIZATIONS>>, ' ||
                                                           '<<AS_OF_DATE>>, ' ||
                                                           '<<PERIOD_TYPE>>, ' ||
                                                           '<<VIEW_BY>>,'||
                                       '<<PROJECT WORK TYPE+PJI_UTIL_CATEGORIES>>, ' ||
                                       '<<PROJECT WORK TYPE+PJI_WORK_TYPES>>, ' ||
                                       '<<PROJECT JOB LEVEL+PJI_JOB_LEVELS>>');

    l_PMV_Rec:=BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    l_PMV_Rec.attribute_name:=':PJI_EXTRA_BND_01';
    l_PMV_Rec.attribute_value:='FALSE'; -- replace with the literal being passed.
    l_PMV_Rec.attribute_type:=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_PMV_Rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

    x_PMV_Output.EXTEND();
    x_PMV_Output(x_PMV_Output.COUNT):=l_PMV_Rec;

END Get_SQL_PJI_REP_U4;


PROCEDURE Get_SQL_PJI_REP_U5(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_PMV_Rec           BIS_QUERY_ATTRIBUTES;
BEGIN

    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL  => p_page_parameter_tbl
                               ,P_SELECT_LIST         =>
                               ' FACT.EXPECTED_HOURS  "PJI_REP_MSR_17",
		                         FACT.EXPECTED_CAPACITY_HOURS  "PJI_REP_MSR_18",
		                         FACT.EXP_ACT_UTIL_PERCENT  "PJI_REP_MSR_1",
		                         FACT.EXP_SCH_UTIL_PERCENT  "PJI_REP_MSR_2",
		                         FACT.EXP_UTIL_PERCENT  "PJI_REP_MSR_3",
		                         FACT.PROV_SCH_UTIL_PERCENT  "PJI_REP_MSR_4",
		                         FACT.EXP_TOTAL_UTIL_PERCENT  "PJI_REP_MSR_6",
		                         FACT.PRIOR_ACT_UTIL_PERCENT  "PJI_REP_MSR_7",
		                         FACT.EXP_UTIL_PERCENT  "PJI_REP_MSR_23",
		                         FACT.EXP_TOTAL_UTIL_PERCENT  "PJI_REP_MSR_24",
		                         FACT.PJI_REP_TOTAL_5 "PJI_REP_TOTAL_1",
		                         FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_2",
		                         FACT.PJI_REP_TOTAL_18 "PJI_REP_TOTAL_3",
		                         FACT.PJI_REP_TOTAL_19 "PJI_REP_TOTAL_4",
		                         FACT.PJI_REP_TOTAL_20 "PJI_REP_TOTAL_5",
		                         FACT.PJI_REP_TOTAL_21 "PJI_REP_TOTAL_6",
		                         FACT.PJI_REP_TOTAL_22 "PJI_REP_TOTAL_7",
		                         FACT.PJI_REP_TOTAL_23 "PJI_REP_TOTAL_8" '
                               ,P_SQL_STATEMENT       => x_PMV_Sql
                               ,P_PMV_OUTPUT          => x_PMV_Output,
                                P_REGION_CODE         => 'PJI_REP_U5',
                                P_PLSQL_DRIVER        => 'PJI_PMV_UTLZ.PLSQLDriver_U4',
                                P_PLSQL_DRIVER_PARAMS =>   '<<ORGANIZATION+FII_OPERATING_UNITS>>, ' ||
                                                           '<<ORGANIZATION+PJI_ORGANIZATIONS>>, ' ||
                                                           '<<AS_OF_DATE>>, ' ||
                                                           '<<PERIOD_TYPE>>, ' ||
                                                           '<<VIEW_BY>>,'||
                                       '<<PROJECT WORK TYPE+PJI_UTIL_CATEGORIES>>, ' ||
                                       '<<PROJECT WORK TYPE+PJI_WORK_TYPES>>, ' ||
                                       '<<PROJECT JOB LEVEL+PJI_JOB_LEVELS>>');

    l_PMV_Rec:=BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    l_PMV_Rec.attribute_name:=':PJI_EXTRA_BND_01';
    l_PMV_Rec.attribute_value:='TRUE'; -- replace with the literal being passed.
    l_PMV_Rec.attribute_type:=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_PMV_Rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

    x_PMV_Output.EXTEND();
    x_PMV_Output(x_PMV_Output.COUNT):=l_PMV_Rec;

END Get_SQL_PJI_REP_U5;


FUNCTION PLSQLDriver_U1 (
   p_operating_unit        IN VARCHAR2 DEFAULT NULL,
   p_organization          IN VARCHAR2,
   p_as_of_date            IN NUMBER,
   p_period_type           IN VARCHAR2,
   p_comparator_type       IN VARCHAR2,
   p_view_by               IN VARCHAR2,
   p_utilization_category  IN VARCHAR2 DEFAULT NULL,
   p_work_type             IN VARCHAR2 DEFAULT NULL,
   p_job_level             IN VARCHAR2 DEFAULT NULL
)  RETURN PJI_REP_U1_TBL
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   l_u1_tbl                         PJI_REP_U1_TBL:=PJI_REP_U1_TBL();
   l_util_category_flag             VARCHAR2(1);
   l_job_flag                       VARCHAR2(1);
   l_denominator                    VARCHAR2(25);
   l_labor_unit                     VARCHAR2(40);
   l_sequence                       NUMBER;
   l_actual_capacity_hours          NUMBER := 0;
   l_missing_hours                  NUMBER := 0;
   l_actual_util_hours              NUMBER := 0;
   l_billable_hours                 NUMBER := 0;
   l_scheduled_util_hours           NUMBER := 0;
   l_scheduled_capacity_hours       NUMBER := 0;
   l_resource_hours                 NUMBER := 0;
   l_total_resource_hours           NUMBER := 0;
   l_actual_denominator             NUMBER := 0;
   l_scheduled_denominator          NUMBER := 0;
   l_prior_actual_capacity_hours    NUMBER := 0;
   l_prior_missing_hours            NUMBER := 0;
   l_prior_actual_util_hours        NUMBER := 0;
   l_prior_billable_hours           NUMBER := 0;
   l_prior_sch_util_hours           NUMBER := 0;
   l_prior_sch_capacity_hours       NUMBER := 0;
   l_prior_resource_hours           NUMBER := 0;
   l_prior_total_resource_hours     NUMBER := 0;
   l_prior_actual_denominator       NUMBER := 0;
   l_prior_scheduled_denominator    NUMBER := 0;
   l_Top_Org_Index                  NUMBER;
   l_Top_Organization_Name          VARCHAR2(240);

BEGIN
   PJI_PMV_ENGINE.Convert_Operating_Unit (p_operating_unit, p_view_by);
   PJI_PMV_ENGINE.Convert_Time (p_as_of_date, p_period_type, p_view_by, 'Y', 'DBI', p_comparator_type, 'N');
   l_util_category_flag := PJI_PMV_ENGINE.Convert_Util_Category(p_work_type, p_utilization_category, p_view_by);
   l_job_flag := PJI_PMV_ENGINE.Convert_Job_Level(null, p_job_level, p_view_by);

   /*
    * Get Utilization percentage denominator profile value
    */
   BEGIN
     SELECT fnd_profile.value('PA_ORG_UTIL_DEF_CALC_METHOD')
     INTO l_denominator
     from dual;

     EXCEPTION WHEN NO_DATA_FOUND THEN
         l_denominator := 'CAPACITY';
   END;

   /*
    * Get report labor unit
    */
   BEGIN
     select report_labor_units
     into l_labor_unit
     from pji_system_settings;

   EXCEPTION WHEN OTHERS THEN
         l_labor_unit := null;
   END;

   SELECT seq
   INTO l_sequence
   FROM pji_mt_buckets
   WHERE bucket_set_code = 'PJI_RESOURCE_AVAILABILITY'
   AND default_flag = 'Y';

   IF l_util_category_flag = 'N' AND l_job_flag = 'N' THEN

      PJI_PMV_ENGINE.Convert_Organization(P_TOP_ORGANIZATION_ID   => p_Organization
                                     , P_VIEW_BY               => p_view_by
                                     , P_TOP_ORGANIZATION_NAME => l_Top_Organization_Name );

      SELECT PJI_REP_U1(org_id,
                        organization_id,
                        time_id,
                        time_key,
                        util_category_id,
                        work_type_id,
                        job_level_id,
                        sum(actual_capacity_hours),
                        sum(missing_hours),
                        sum(actual_util_hours),
                        sum(billable_hours),
                        sum(scheduled_util_hours),
                        sum(scheduled_capacity_hours),
                        sum(resource_hours),
                        sum(total_resource_hours),
                        sum(decode(l_denominator, 'CAPACITY', actual_capacity_hours, actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', scheduled_capacity_hours, actual_hours)),
                        sum(prior_actual_capacity_hours),
                        sum(prior_missing_hours),
                        sum(prior_actual_util_hours),
                        sum(prior_billable_hours),
                        sum(prior_sch_util_hours),
                        sum(prior_sch_capacity_hours),
                        sum(prior_resource_hours),
                        sum(prior_total_resource_hours),
                        sum(decode(l_denominator, 'CAPACITY', prior_actual_capacity_hours, prior_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', prior_sch_capacity_hours, prior_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,null
                        )
      BULK COLLECT INTO l_u1_tbl
      FROM ( /* Bug 3515594 */
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  horg.name                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  (capacity_hrs - reduce_capacity_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1) actual_capacity_hours,
                  missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1) missing_hours,
                  total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          actual_util_hours,
                  bill_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          billable_hours,
                  conf_wtd_org_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          scheduled_util_hours,
                  (capacity_hrs - reduce_capacity_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          scheduled_capacity_hours,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          actual_hours,
                  conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          scheduled_hours,
                  DECODE (l_sequence, 1, available_hrs_bkt1_s,
                                      2, available_hrs_bkt2_s,
                                      3, available_hrs_bkt3_s,
                                      4, available_hrs_bkt4_s,
                                      5, available_hrs_bkt5_s)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          resource_hours,
                  capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          total_resource_hours,
                  0                                       prior_actual_capacity_hours,
                  0                                       prior_missing_hours,
		  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_sch_capacity_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours,
                  0                                       prior_resource_hours,
                  0                                       prior_total_resource_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_RM_ORGO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.id is not null
             AND hou.id = imp.org_id
           UNION ALL
	   /* Bug 3515594 */
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  horg.name                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_capacity_hours,
                  0                                       missing_hours,
		  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       scheduled_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       resource_hours,
                  0                                       total_resource_hours,
                  (capacity_hrs - reduce_capacity_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_actual_capacity_hours,
                  missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_missing_hours,
                  total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_actual_util_hours,
                  bill_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_billable_hours,
                  conf_wtd_org_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_sch_util_hours,
                  (capacity_hrs - reduce_capacity_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_sch_capacity_hours,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_actual_hours,
                  conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_scheduled_hours,
                  DECODE (l_sequence, 1, available_hrs_bkt1_s,
                                      2, available_hrs_bkt2_s,
                                      3, available_hrs_bkt3_s,
                                      4, available_hrs_bkt4_s,
                                      5, available_hrs_bkt5_s)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_resource_hours,
                  capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_total_resource_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TCMP_DIM_TMP time,
                PJI_RM_ORGO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND hou.id = imp.org_id
           UNION ALL
           SELECT '-1'                                    org_id,
                  name                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_capacity_hours,
                  0                                       missing_hours,
                  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       scheduled_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       resource_hours,
                  0                                       total_resource_hours,
                  0                                       prior_actual_capacity_hours,
                  0                                       prior_missing_hours,
                  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_sch_capacity_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours,
                  0                                       prior_resource_hours,
                  0                                       prior_total_resource_hours
           FROM PJI_PMV_ORGZ_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  name                                    time_id,
                  order_by_id                             time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_capacity_hours,
                  0                                       missing_hours,
                  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_utilization_hours,
                  0                                       scheduled_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       resource_hours,
                  0                                       total_resource_hours,
                  0                                       prior_actual_capacity_hours,
                  0                                       prior_missing_hours,
                  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_sch_capacity_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours,
                  0                                       prior_resource_hours,
                  0                                       prior_total_resource_hours
           FROM PJI_PMV_TIME_DIM_TMP
           WHERE name <> '-1'
           )
           GROUP BY org_id,
		     organization_id,
		     time_id,
		     time_key,
		     util_category_id,
                     work_type_id,
		     job_level_id;

   ELSIF l_job_flag = 'N' THEN

      PJI_PMV_ENGINE.Convert_Organization(P_TOP_ORGANIZATION_ID   => p_Organization
                                     , P_VIEW_BY               => p_view_by
                                     , P_TOP_ORGANIZATION_NAME => l_Top_Organization_Name );


      SELECT PJI_REP_U1(org_id,
                        organization_id,
                        time_id,
                        time_key,
                        util_category_id,
                        work_type_id,
                        job_level_id,
                        sum(capacity_hours-act_reduce_capacity_hours),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, missing_hours)),
                        sum(actual_util_hours),
                        sum(billable_hours),
                        sum(scheduled_util_hours),
                        sum(capacity_hours-sch_reduce_capacity_hours),
                        0,           -- resource_hours
                        0,           -- total_resource_hours,
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-act_reduce_capacity_hours, total_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-sch_reduce_capacity_hours, total_actual_hours)),
                        sum(prior_act_capacity_hours-prior_act_red_capacity_hours),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, prior_missing_hours)),
                        sum(prior_actual_util_hours),
                        sum(prior_billable_hours),
                        sum(prior_sch_util_hours),
                        sum(prior_act_capacity_hours-prior_act_red_capacity_hours),
                        0,           -- prior_resource_hours
                        0,           -- prior_total_resource_hours
                        sum(decode(l_denominator, 'CAPACITY', prior_act_capacity_hours-prior_act_red_capacity_hours,
                           prior_total_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', prior_act_capacity_hours-prior_act_red_capacity_hours,
                           prior_total_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,null)
      BULK COLLECT INTO l_u1_tbl
      FROM ( /* Bug 3515594 */
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  horg.name                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  decode(p_view_by, 'UC', wt.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', wt.name, '-1')  work_type_id,
                  '-1'                                    job_level_id,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
                  (fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                          actual_util_hours,

                  (fct.bill_hrs_a * worktype.org_utilization_percentage / 100)
                                 / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          billable_hours,
                  (fct.conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                          scheduled_util_hours,
                  0                                       sch_reduce_capacity_hours,
                  fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          actual_hours,
                  fct.conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          scheduled_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
                  null                                    prior_missing_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_WT_DIM_TMP wt,
                PJI_RM_WTO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_WORK_TYPES_B worktype,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND wt.id = worktype.work_type_id
             AND fct.work_type_id = wt.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.id is not null
             AND hou.id = imp.org_id
           UNION ALL
	   /* Bug 3515594 */
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  horg.name                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  decode(p_view_by, 'UC', wt.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', wt.name, '-1')  work_type_id,
                  '-1'                                    job_level_id,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       sch_reduce_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
                  null                                    prior_missing_hours,
		  0 					  prior_total_actual_hours,
                  (fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1))
                  * worktype.org_utilization_percentage / 100
                                                          prior_actual_util_hours,
                  (fct.bill_hrs_a * worktype.org_utilization_percentage / 100)
                                 / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_billable_hours,
                  (fct.conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                          prior_sch_util_hours,
                  fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_actual_hours,
                  fct.conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_scheduled_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TCMP_DIM_TMP time,
                PJI_PMV_WT_DIM_TMP wt,
                PJI_RM_WTO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_WORK_TYPES_B worktype,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND wt.id = worktype.work_type_id
             AND fct.work_type_id = wt.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND hou.id = imp.org_id
           UNION ALL
           SELECT '-1'                                    org_id,
                  name                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
		  null                                    missing_hours,
		  0 					  total_actual_hours,
                  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       sch_reduce_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
                  null                                    prior_missing_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM PJI_PMV_ORGZ_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  decode(p_view_by, 'UC', name, '-1')     util_category_id,
                  decode(p_view_by, 'WT', name, '-1')     work_type_id,
                  '-1'                                    job_level_id,
                 -- 0                                       actual_capacity_hours,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
                  0 					  total_actual_hours,
		  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       sch_reduce_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
                  null                                    prior_missing_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM PJI_PMV_WT_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  name                                    time_id,
                  order_by_id                             time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       sch_reduce_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
                  null                                    prior_missing_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM PJI_PMV_TIME_DIM_TMP
           WHERE name <> '-1'
           UNION ALL  -- added for current year capacity_hours
           SELECT
                  FACT.org_id,
                  FACT.organization_id,
                  FACT.time_id,
                  FACT.time_key,
                  decode(p_view_by, 'UC', WT.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', WT.name, '-1')  work_type_id,
                  '-1'                                    job_level_id,
                  FACT.capacity_hours,
                  FACT.reduce_capacity_hrs_a              act_reduce_capacity_hours,
                  FACT.missing_hrs_a                      missing_hours,
		  FACT.total_actual_hours                 total_actual_hours,
		  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  FACT.reduce_capacity_hrs_s              sch_reduce_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
                  null                                    prior_missing_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM
	    /* Bug 3515594 */
            (SELECT /*+ ORDERED */
                     hou.name                                org_id,
                     horg.name                               organization_id,
                     time.name                               time_id,
                     DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                     fct.capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                             capacity_hours,
                     fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                             total_actual_hours,
                     fct.missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
							     missing_hrs_a,
                     fct.reduce_capacity_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                             reduce_capacity_hrs_a,
                     fct.reduce_capacity_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                             reduce_capacity_hrs_s
             FROM PJI_PMV_ORGZ_DIM_TMP horg,
                  PJI_PMV_TIME_DIM_TMP time,
                  PJI_RM_ORGO_F_MV fct,
                  PJI_PMV_ORG_DIM_TMP hou,
                  PA_IMPLEMENTATIONS_ALL imp
             WHERE fct.expenditure_org_id = hou.id
             AND   fct.expenditure_organization_id = horg.id
             AND   fct.time_id = time.id
             AND   fct.period_type_id = time.period_type
             AND   fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND   time.id is not null
             AND   hou.id = imp.org_id )         FACT,
             (SELECT distinct WT.name
              FROM   PJI_PMV_WT_DIM_TMP wt )     WT
           UNION ALL  -- added for prior year capacity_hours
	   /* Bug 3515594 */
           SELECT
                  FACT.org_id,
                  FACT.organization_id,
                  FACT.time_id,
                  FACT.time_key,
                  decode(p_view_by, 'UC', WT.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', WT.name, '-1')  work_type_id,
                  '-1'                                    job_level_id,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
		  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       sch_reduce_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  FACT.capacity_hours                     prior_act_capacity_hours,
                  FACT.reduce_capacity_hrs_a              prior_act_red_capacity_hours,
                  FACT.missing_hrs_a                      prior_missing_hours,
		  FACT.total_actual_hours    		  prior_total_actual_hours,
                  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM
            (SELECT /*+ ORDERED */
                     hou.name                                org_id,
                     horg.name                               organization_id,
                     time.name                               time_id,
                     DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                     fct.capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          capacity_hours,
		     fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                             total_actual_hours,
		     fct.missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          missing_hrs_a,
                     fct.reduce_capacity_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          reduce_capacity_hrs_a
             FROM PJI_PMV_ORGZ_DIM_TMP horg,
                  PJI_PMV_TCMP_DIM_TMP time,
                  PJI_RM_ORGO_F_MV fct,
                  PJI_PMV_ORG_DIM_TMP hou,
                  PA_IMPLEMENTATIONS_ALL imp
             WHERE fct.expenditure_org_id = hou.id
             AND   fct.expenditure_organization_id = horg.id
             AND   fct.time_id = time.id
             AND   fct.period_type_id = time.period_type
             AND   fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND   hou.id = imp.org_id )         FACT,
             (SELECT distinct WT.name
              FROM   PJI_PMV_WT_DIM_TMP wt )     WT
           )
           GROUP BY org_id,
		     organization_id,
		     time_id,
		     time_key,
		     util_category_id,
             work_type_id,
		     job_level_id;


   ELSIF l_util_category_flag = 'N' THEN

      PJI_PMV_ENGINE.Convert_Organization(P_TOP_ORGANIZATION_ID   => p_Organization
                                        , P_VIEW_BY               => p_view_by
                                        , P_TOP_ORGANIZATION_NAME => l_Top_Organization_Name );


      SELECT PJI_REP_U1(org_id,
                        organization_id,
                        time_id,
                        time_key,
                        util_category_id,
                        work_type_id,
                        job_level_id,
                        sum(capacity_hrs - reduce_capacity_hrs_a),
                        --null,
                        sum(missing_hours),
                        sum(actual_util_hours),
                        sum(billable_hours),
                        sum(scheduled_util_hours),
                        sum(capacity_hrs - reduce_capacity_hrs_s),
                        0,           -- resource_hours
                        0,           -- total_resource_hours,
                        sum(decode(l_denominator, 'CAPACITY', capacity_hrs - reduce_capacity_hrs_a, actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hrs - reduce_capacity_hrs_s, actual_hours)),
                        sum (prior_capacity_hours - prior_reduce_capacity_hrs_a),
                        sum(prior_missing_hours),
                        --null,
                        sum(prior_actual_util_hours),
                        sum(prior_billable_hours),
                        sum(prior_sch_util_hours),
                        sum(prior_capacity_hours - prior_reduce_capacity_hrs_s),
                        0,           -- prior_resource_hours
                        0,           -- prior_total_resource_hours
                        sum(decode(l_denominator, 'CAPACITY', prior_capacity_hours - prior_reduce_capacity_hrs_a, prior_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', prior_capacity_hours - prior_reduce_capacity_hrs_s, prior_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,null
                        )
      /* Bug 3515594 */
      BULK COLLECT INTO l_u1_tbl
      FROM (
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  horg.name                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  job.name                                job_level_id,
                  capacity_hrs                            capacity_hrs,
                  reduce_capacity_hrs_a                   reduce_capacity_hrs_a,
                  missing_hrs_a                           missing_hours,
                  total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          actual_util_hours,
                  bill_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          billable_hours,
                  conf_wtd_org_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          scheduled_util_hours,
                  reduce_capacity_hrs_s                   reduce_capacity_hrs_s,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          actual_hours,
                  conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          scheduled_hours,
                  0                                       prior_capacity_hours,
                  0                                       prior_reduce_capacity_hrs_a,
                  0                                       prior_reduce_capacity_hrs_s,
                  0                                       prior_missing_hours,
                  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_JB_DIM_TMP job,
                PJI_RM_JOBO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.job_id = job.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.id is not null
             AND hou.id = imp.org_id
           UNION ALL
	   /* Bug 3515594 */
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  horg.name                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  job.name                                job_level_id,
                  0                                       capacity_hours,
                  0                                       reduce_capacity_hrs_a,
                  0                                       reduce_capacity_hrs_s,
                  0                                       missing_hours,
                  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_capacity_hours,
                  reduce_capacity_hrs_a                   prior_reduce_capacity_hrs_a,
                  missing_hrs_a                           prior_missing_hours,
                  total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_actual_util_hours,
                  bill_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_billable_hours,
                  conf_wtd_org_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_sch_util_hours,
                  reduce_capacity_hrs_s                   prior_reduce_capacity_hrs_s,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_actual_hours,
                  conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_scheduled_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TCMP_DIM_TMP time,
                PJI_PMV_JB_DIM_TMP job,
                PJI_RM_JOBO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.job_id = job.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND hou.id = imp.org_id
           UNION ALL
           SELECT '-1'                                    org_id,
                  name                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       capacity_hours,
                  0                                       reduce_capacity_hrs_a,
                  0                                       reduce_capacity_hrs_s,
                  null                                    missing_hours,
                  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_capacity_hours,
                  0                                       prior_reduce_capacity_hrs_a,
                  0                                       prior_reduce_capacity_hrs_s,
                  null                                    prior_missing_hours,
                  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM PJI_PMV_ORGZ_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  name                                    job_level_id,
                  0                                       capacity_hours,
                  0                                       reduce_capacity_hrs_a,
                  0                                       reduce_capacity_hrs_s,
                  null                                    missing_hours,
                  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_capacity_hours,
                  0                                       prior_reduce_capacity_hrs_a,
                  0                                       prior_reduce_capacity_hrs_s,
                  null                                    prior_missing_hours,
                  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM PJI_PMV_JB_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  name                                    time_id,
                  order_by_id                             time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       capacity_hours,
                  0                                       reduce_capacity_hrs_a,
                  0                                       reduce_capacity_hrs_s,
                  null                                    missing_hours,
                  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_capacity_hours,
                  0                                       prior_reduce_capacity_hrs_a,
                  0                                       prior_reduce_capacity_hrs_s,
                  null                                    prior_missing_hours,
                  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM PJI_PMV_TIME_DIM_TMP
           WHERE name <> '-1'
           )
           GROUP BY org_id,
		    organization_id,
		    time_id,
		    time_key,
		    util_category_id,
            work_type_id,
		    job_level_id;

   ELSE

      PJI_PMV_ENGINE.Convert_Organization( p_Organization, p_view_by);

      SELECT PJI_REP_U1(org_id,
                        organization_id,
                        time_id,
                        time_key,
                        util_category_id,
                        work_type_id,
                        job_level_id,
                        sum(capacity_hours-act_reduce_capacity_hours),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, missing_hours)),
                        sum(actual_util_hours),
                        sum(billable_hours),
                        sum(scheduled_util_hours),
                        sum(capacity_hours-sch_reduce_capacity_hours),
                        0,           -- resource_hours
                        0,           -- total_resource_hours,
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-act_reduce_capacity_hours, total_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-sch_reduce_capacity_hours, total_actual_hours)),
                        sum(prior_act_capacity_hours-prior_act_red_capacity_hours),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, prior_missing_hours)),
                        sum(prior_actual_util_hours),
                        sum(prior_billable_hours),
                        sum(prior_sch_util_hours),
                        sum(prior_act_capacity_hours-prior_act_red_capacity_hours),
                        0,           -- prior_resource_hours
                        0,           -- prior_total_resource_hours
                        sum(decode(l_denominator, 'CAPACITY', prior_act_capacity_hours-prior_act_red_capacity_hours,
                           prior_total_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', prior_act_capacity_hours-prior_act_red_capacity_hours,
                           prior_total_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,null
                        )
	/* Bug 3515594 */
      BULK COLLECT INTO l_u1_tbl
      FROM (
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  horg.name                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  decode(p_view_by, 'UC', wt.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', wt.name, '-1')  work_type_id,

                  job.name                                job_level_id,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
  		  0 					  total_actual_hours,
                  (fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                          actual_util_hours,

                  (fct.bill_hrs_a * worktype.org_utilization_percentage / 100)
                                 / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          billable_hours,
                  (fct.conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                          scheduled_util_hours,
                  0                                       sch_reduce_capacity_hours,
                  fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          actual_hours,
                  fct.conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          scheduled_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
                  null                                    prior_missing_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
               -- 0                                       prior_sch_capacity_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_WT_DIM_TMP wt,
                PJI_RM_RES_WT_F fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PJI_PMV_JB_DIM_TMP job,
                PA_WORK_TYPES_B worktype,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND wt.id = worktype.work_type_id
             AND fct.work_type_id = wt.id
             AND fct.job_id = job.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.id is not null
             AND hou.id = imp.org_id
           UNION ALL
	   /* Bug 3515594 */
           SELECT  /*+ ORDERED */
                  hou.name                                org_id,
                  horg.name                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  decode(p_view_by, 'UC', wt.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', wt.name, '-1')  work_type_id,

                  job.name                                job_level_id,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       sch_reduce_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
                  null                                    prior_missing_hours,
  		  0 					  prior_total_actual_hours,
                  (fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                          prior_actual_util_hours,
                  (fct.bill_hrs_a * worktype.org_utilization_percentage / 100)
                                 / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_billable_hours,
                  (fct.conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                          prior_sch_util_hours,
                  fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_actual_hours,
                  fct.conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_scheduled_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TCMP_DIM_TMP time,
                PJI_PMV_WT_DIM_TMP wt,
                PJI_RM_RES_WT_F fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PJI_PMV_JB_DIM_TMP job,
                PA_WORK_TYPES_B worktype,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND wt.id = worktype.work_type_id
             AND fct.work_type_id = wt.id
             AND fct.job_id = job.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND hou.id = imp.org_id
           UNION ALL
           SELECT '-1'                                    org_id,
                  name                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       sch_reduce_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
                  null                                    prior_missing_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM PJI_PMV_ORGZ_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  decode(p_view_by, 'UC', name, '-1')     util_category_id,
                  decode(p_view_by, 'WT', name, '-1')     work_type_id,
                  '-1'                                    job_level_id,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       sch_reduce_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
                  null                                    prior_missing_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM PJI_PMV_WT_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_typd_id,
                  name                                    job_level_id,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       sch_reduce_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
                  null                                    prior_missing_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM PJI_PMV_JB_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  name                                    time_id,
                  order_by_id                             time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
                  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       sch_reduce_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
                  null                                    prior_missing_hours,
		  0 					  prior_total_actual_hours,
                  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM PJI_PMV_TIME_DIM_TMP
           WHERE name <> '-1'
           UNION ALL  -- added for current year capacity_hours
	   /* Bug 3515594 */
           SELECT
                  FACT.org_id,
                  FACT.organization_id,
                  FACT.time_id,
                  FACT.time_key,
                  decode(p_view_by, 'UC', WT.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', WT.name, '-1')  work_type_id,
                  FACT.job_level_id                       job_level_id,
                  FACT.capacity_hours,
                  FACT.reduce_capacity_hrs_a              act_reduce_capacity_hours,
                  FACT.missing_hrs_a                      missing_hours,
		  FACT.total_actual_hours		  total_actual_hours,
		  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  FACT.reduce_capacity_hrs_s              sch_reduce_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
                  null                                    prior_missing_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM
            (SELECT /*+ ORDERED */
                     hou.name                                org_id,
                     horg.name                               organization_id,
                     time.name                               time_id,
                     job.name                                job_level_id,
                     DECODE(p_view_by, 'TM', time.id, -1)    time_key,

                     capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          capacity_hours,
                     total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          total_actual_hours,
                     missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          missing_hrs_a,
                     reduce_capacity_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          reduce_capacity_hrs_a,
                     reduce_capacity_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          reduce_capacity_hrs_s
             FROM PJI_PMV_ORGZ_DIM_TMP horg,
                  PJI_PMV_TIME_DIM_TMP time,
                  PJI_PMV_JB_DIM_TMP   job,
                  PJI_RM_JOB_F_MV fct,
                  PJI_PMV_ORG_DIM_TMP hou,
                  PA_IMPLEMENTATIONS_ALL imp
             WHERE fct.expenditure_org_id = hou.id
             AND   fct.expenditure_organization_id = horg.id
             AND   fct.time_id = time.id
             AND   time.id is not null
             AND   fct.job_id  = job.id
             AND   fct.period_type_id = time.period_type
             AND   fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND   hou.id = imp.org_id )         FACT,
             (SELECT distinct WT.name
              FROM   PJI_PMV_WT_DIM_TMP wt )     WT
           UNION ALL  -- added for prior year capacity_hours
	   /* Bug 3515594 */
           SELECT
                  FACT.org_id,
                  FACT.organization_id,
                  FACT.time_id,
                  FACT.time_key,
                  decode(p_view_by, 'UC', WT.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', WT.name, '-1')  work_type_id,
                  FACT.job_level_id                       job_level_id,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       actual_util_hours,
                  0                                       billable_hours,
                  0                                       scheduled_util_hours,
                  0                                       sch_reduce_capacity_hours,
                  0                                       actual_hours,
                  0                                       scheduled_hours,
                  FACT.capacity_hours                     prior_act_capacity_hours,
                  FACT.prior_reduce_capacity_hrs_a        prior_act_red_capacity_hours,
                  FACT.missing_hrs_a                      prior_missing_hours,
		  FACT.total_actual_hours                 prior_total_actual_hours,
		  0                                       prior_actual_util_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_sch_util_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_scheduled_hours
           FROM
            (SELECT /*+ ORDERED */
                     hou.name                                org_id,
                     horg.name                               organization_id,
                     time.name                               time_id,
                     DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                     job.name                                job_level_id,
                     capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          capacity_hours,

                     total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          total_actual_hours,

		     missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          missing_hrs_a,
                     reduce_capacity_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_reduce_capacity_hrs_a
             FROM PJI_PMV_ORGZ_DIM_TMP horg,
                  PJI_PMV_TCMP_DIM_TMP time,
                  PJI_PMV_JB_DIM_TMP job,
                  PJI_RM_JOB_F_MV fct,
                  PJI_PMV_ORG_DIM_TMP hou,
                  PA_IMPLEMENTATIONS_ALL imp
             WHERE fct.expenditure_org_id = hou.id
             AND   fct.expenditure_organization_id = horg.id
             AND   fct.time_id = time.id
             AND   fct.job_id  = job.id
             AND   fct.period_type_id = time.period_type
             AND   fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND   hou.id = imp.org_id )         FACT,
             (SELECT distinct WT.name
              FROM   PJI_PMV_WT_DIM_TMP wt )     WT
           )
           GROUP BY org_id,
		     organization_id,
		     time_id,
		     time_key,
		     util_category_id,
             work_type_id,
		     job_level_id;

   END IF;


     FOR i in 1..l_u1_tbl.COUNT
       LOOP

         IF p_View_By = 'OG' AND ( l_job_flag = 'N' OR l_util_category_flag = 'N' )
            AND l_u1_tbl(i).ORGANIZATION_ID = l_Top_Organization_Name   THEN

              l_Top_Org_Index:=i;
         ELSE
              l_actual_capacity_hours          := l_actual_capacity_hours       + nvl(l_u1_tbl(i).ACTUAL_CAPACITY_HOURS,0);
              l_missing_hours                  := l_missing_hours               + nvl(l_u1_tbl(i).MISSING_HOURS,0);
              l_actual_util_hours              := l_actual_util_hours           + nvl(l_u1_tbl(i).ACTUAL_UTIL_HOURS,0);
              l_billable_hours                 := l_billable_hours              + nvl(l_u1_tbl(i).BILLABLE_HOURS,0);
              l_scheduled_util_hours           := l_scheduled_util_hours        + nvl(l_u1_tbl(i).SCHEDULED_UTIL_HOURS,0);
              l_scheduled_capacity_hours       := l_scheduled_capacity_hours    + nvl(l_u1_tbl(i).SCHEDULED_CAPACITY_HOURS,0);
              l_resource_hours                 := l_resource_hours              + nvl(l_u1_tbl(i).RESOURCE_HOURS,0);
              l_total_resource_hours           := l_total_resource_hours        + nvl(l_u1_tbl(i).TOTAL_RESOURCE_HOURS,0);
              l_actual_denominator             := l_actual_denominator          + nvl(l_u1_tbl(i).ACTUAL_DENOMINATOR,0);
              l_scheduled_denominator          := l_scheduled_denominator       + nvl(l_u1_tbl(i).SCHEDULED_DENOMINATOR,0);
              l_prior_actual_capacity_hours    := l_prior_actual_capacity_hours + nvl(l_u1_tbl(i).PRIOR_ACTUAL_CAPACITY_HOURS,0);
              l_prior_missing_hours            := l_prior_missing_hours         + nvl(l_u1_tbl(i).PRIOR_MISSING_HOURS,0);
              l_prior_actual_util_hours        := l_prior_actual_util_hours     + nvl(l_u1_tbl(i).PRIOR_ACTUAL_UTIL_HOURS,0);
              l_prior_billable_hours           := l_prior_billable_hours        + nvl(l_u1_tbl(i).PRIOR_BILLABLE_HOURS,0);
              l_prior_sch_util_hours           := l_prior_sch_util_hours        + nvl(l_u1_tbl(i).PRIOR_SCH_UTIL_HOURS,0);
              l_prior_sch_capacity_hours       := l_prior_sch_capacity_hours    + nvl(l_u1_tbl(i).PRIOR_SCH_CAPACITY_HOURS,0);
              l_prior_resource_hours           := l_prior_resource_hours        + nvl(l_u1_tbl(i).PRIOR_RESOURCE_HOURS,0);
              l_prior_total_resource_hours     := l_prior_total_resource_hours  + nvl(l_u1_tbl(i).PRIOR_TOTAL_RESOURCE_HOURS,0);
              l_prior_actual_denominator       := l_prior_actual_denominator    + nvl(l_u1_tbl(i).PRIOR_ACTUAL_DENOMINATOR,0);
              l_prior_scheduled_denominator    := l_prior_scheduled_denominator + nvl(l_u1_tbl(i).PRIOR_SCHEDULED_DENOMINATOR,0);

              --Calculated columns processing is done below
              --The l_Top_org is not done here
              IF nvl(l_u1_tbl(i).prior_total_resource_hours,0) <> 0 THEN
                l_u1_tbl(i).prior_res_hours_percent := 100 * (l_u1_tbl(i).prior_resource_hours / l_u1_tbl(i).prior_total_resource_hours);
              ELSE
                l_u1_tbl(i).prior_res_hours_percent := NULL;
              END IF;

              IF nvl(l_u1_tbl(i).prior_actual_denominator,0) <> 0 THEN
                l_u1_tbl(i).prior_act_util_percent := 100 * (l_u1_tbl(i).prior_actual_util_hours / l_u1_tbl(i).prior_actual_denominator);
                l_u1_tbl(i).prior_bill_hours_percent := 100 * (l_u1_tbl(i).prior_billable_hours / l_u1_tbl(i).prior_actual_denominator);
              ELSE
                l_u1_tbl(i).prior_act_util_percent := NULL;
                l_u1_tbl(i).prior_bill_hours_percent := NULL;
              END IF;

              IF nvl(l_u1_tbl(i).actual_denominator,0) <> 0 THEN
                l_u1_tbl(i).bill_hours_percent := 100 * (l_u1_tbl(i).billable_hours / l_u1_tbl(i).actual_denominator);
                l_u1_tbl(i).act_util_percent := 100 * (l_u1_tbl(i).actual_util_hours / l_u1_tbl(i).actual_denominator);
              ELSE
                l_u1_tbl(i).bill_hours_percent := NULL;
                l_u1_tbl(i).act_util_percent := NULL;
              END IF;

              IF nvl(l_u1_tbl(i).total_resource_hours,0) <> 0 THEN
                l_u1_tbl(i).res_hours_percent := 100 * (l_u1_tbl(i).resource_hours / l_u1_tbl(i).total_resource_hours);
              ELSE
                l_u1_tbl(i).res_hours_percent := NULL;
              END IF;

              --TODO:Does the change need to be null when both values are null??
		      l_u1_tbl(i).change_percent_1 := nvl(l_u1_tbl(i).act_util_percent,0) - nvl(l_u1_tbl(i).prior_act_util_percent,0);
		      l_u1_tbl(i).change_percent_2 := nvl(l_u1_tbl(i).bill_hours_percent,0) - nvl(l_u1_tbl(i).prior_bill_hours_percent,0);
	   	      l_u1_tbl(i).change_percent_3 := nvl(l_u1_tbl(i).res_hours_percent,0) - nvl(l_u1_tbl(i).prior_res_hours_percent,0);

              --Columns for U1 only
              IF nvl(l_u1_tbl(i).scheduled_denominator,0) <> 0 THEN
                l_u1_tbl(i).sch_util_percent := 100 * (l_u1_tbl(i).scheduled_util_hours / l_u1_tbl(i).scheduled_denominator);
              ELSE
                l_u1_tbl(i).sch_util_percent := NULL;
              END IF;

              IF nvl(l_u1_tbl(i).prior_missing_hours,0) <> 0 THEN
                l_u1_tbl(i).missing_hours_percent := 100 * ((l_u1_tbl(i).missing_hours - l_u1_tbl(i).prior_missing_hours)/ l_u1_tbl(i).prior_missing_hours);
              ELSE
                l_u1_tbl(i).missing_hours_percent := NULL;
              END IF;

              l_u1_tbl(i).sch_var_percent := nvl(l_u1_tbl(i).act_util_percent,0) - nvl(l_u1_tbl(i).sch_util_percent,0);

        END IF; --p_view_by

      END LOOP;

      --Processing for l_top_org_index
      IF p_View_By = 'OG' AND ( l_job_flag = 'N' OR l_util_category_flag = 'N' ) THEN

           l_u1_tbl(l_Top_Org_Index).ACTUAL_CAPACITY_HOURS          :=   l_u1_tbl(l_Top_Org_Index).ACTUAL_CAPACITY_HOURS         - l_actual_capacity_hours;
     	   l_u1_tbl(l_Top_Org_Index).MISSING_HOURS                  :=   l_u1_tbl(l_Top_Org_Index).MISSING_HOURS                 - l_missing_hours;
		   l_u1_tbl(l_Top_Org_Index).ACTUAL_UTIL_HOURS              :=   l_u1_tbl(l_Top_Org_Index).ACTUAL_UTIL_HOURS             - l_actual_util_hours;
 		   l_u1_tbl(l_Top_Org_Index).BILLABLE_HOURS                 :=   l_u1_tbl(l_Top_Org_Index).BILLABLE_HOURS                - l_billable_hours;
		   l_u1_tbl(l_Top_Org_Index).SCHEDULED_UTIL_HOURS           :=   l_u1_tbl(l_Top_Org_Index).SCHEDULED_UTIL_HOURS          - l_scheduled_util_hours;
		   l_u1_tbl(l_Top_Org_Index).SCHEDULED_CAPACITY_HOURS       :=   l_u1_tbl(l_Top_Org_Index).SCHEDULED_CAPACITY_HOURS      - l_scheduled_capacity_hours;
		   l_u1_tbl(l_Top_Org_Index).RESOURCE_HOURS                 :=   l_u1_tbl(l_Top_Org_Index).RESOURCE_HOURS                - l_resource_hours;
		   l_u1_tbl(l_Top_Org_Index).TOTAL_RESOURCE_HOURS           :=   l_u1_tbl(l_Top_Org_Index).TOTAL_RESOURCE_HOURS          - l_total_resource_hours;
		   l_u1_tbl(l_Top_Org_Index).ACTUAL_DENOMINATOR             :=   l_u1_tbl(l_Top_Org_Index).ACTUAL_DENOMINATOR            - l_actual_denominator;
		   l_u1_tbl(l_Top_Org_Index).SCHEDULED_DENOMINATOR          :=   l_u1_tbl(l_Top_Org_Index).SCHEDULED_DENOMINATOR         - l_scheduled_denominator;
		   l_u1_tbl(l_Top_Org_Index).PRIOR_ACTUAL_CAPACITY_HOURS    :=   l_u1_tbl(l_Top_Org_Index).PRIOR_ACTUAL_CAPACITY_HOURS   - l_prior_actual_capacity_hours;
		   l_u1_tbl(l_Top_Org_Index).PRIOR_MISSING_HOURS            :=   l_u1_tbl(l_Top_Org_Index).PRIOR_MISSING_HOURS           - l_prior_missing_hours;
		   l_u1_tbl(l_Top_Org_Index).PRIOR_ACTUAL_UTIL_HOURS        :=   l_u1_tbl(l_Top_Org_Index).PRIOR_ACTUAL_UTIL_HOURS       - l_prior_actual_util_hours;
		   l_u1_tbl(l_Top_Org_Index).PRIOR_BILLABLE_HOURS           :=   l_u1_tbl(l_Top_Org_Index).PRIOR_BILLABLE_HOURS          - l_prior_billable_hours;
		   l_u1_tbl(l_Top_Org_Index).PRIOR_SCH_UTIL_HOURS           :=   l_u1_tbl(l_Top_Org_Index).PRIOR_SCH_UTIL_HOURS          - l_prior_sch_util_hours;
		   l_u1_tbl(l_Top_Org_Index).PRIOR_SCH_CAPACITY_HOURS       :=   l_u1_tbl(l_Top_Org_Index).PRIOR_SCH_CAPACITY_HOURS      - l_prior_sch_capacity_hours;
		   l_u1_tbl(l_Top_Org_Index).PRIOR_RESOURCE_HOURS           :=   l_u1_tbl(l_Top_Org_Index).PRIOR_RESOURCE_HOURS          - l_prior_resource_hours;
		   l_u1_tbl(l_Top_Org_Index).PRIOR_TOTAL_RESOURCE_HOURS     :=   l_u1_tbl(l_Top_Org_Index).PRIOR_TOTAL_RESOURCE_HOURS    - l_prior_total_resource_hours;
		   l_u1_tbl(l_Top_Org_Index).PRIOR_ACTUAL_DENOMINATOR       :=   l_u1_tbl(l_Top_Org_Index).PRIOR_ACTUAL_DENOMINATOR      - l_prior_actual_denominator;
		   l_u1_tbl(l_Top_Org_Index).PRIOR_SCHEDULED_DENOMINATOR    :=   l_u1_tbl(l_Top_Org_Index).PRIOR_SCHEDULED_DENOMINATOR   - l_prior_scheduled_denominator;

           --Calculated columns processing for l_top_org
           IF nvl(l_u1_tbl(l_Top_Org_Index).prior_total_resource_hours,0) <> 0 THEN
             l_u1_tbl(l_Top_Org_Index).prior_res_hours_percent := 100 * (l_u1_tbl(l_Top_Org_Index).prior_resource_hours / l_u1_tbl(l_Top_Org_Index).prior_total_resource_hours);
           ELSE
              l_u1_tbl(l_Top_Org_Index).prior_res_hours_percent := NULL;
           END IF;

           IF nvl(l_u1_tbl(l_Top_Org_Index).prior_actual_denominator,0) <> 0 THEN
             l_u1_tbl(l_Top_Org_Index).prior_act_util_percent := 100 * (l_u1_tbl(l_Top_Org_Index).prior_actual_util_hours / l_u1_tbl(l_Top_Org_Index).prior_actual_denominator);
             l_u1_tbl(l_Top_Org_Index).prior_bill_hours_percent := 100 * (l_u1_tbl(l_Top_Org_Index).prior_billable_hours / l_u1_tbl(l_Top_Org_Index).prior_actual_denominator);
           ELSE
             l_u1_tbl(l_Top_Org_Index).prior_act_util_percent := NULL;
             l_u1_tbl(l_Top_Org_Index).prior_bill_hours_percent := NULL;
           END IF;

           IF nvl(l_u1_tbl(l_Top_Org_Index).actual_denominator,0) <> 0 THEN
             l_u1_tbl(l_Top_Org_Index).bill_hours_percent := 100 * (l_u1_tbl(l_Top_Org_Index).billable_hours / l_u1_tbl(l_Top_Org_Index).actual_denominator);
             l_u1_tbl(l_Top_Org_Index).act_util_percent := 100 * (l_u1_tbl(l_Top_Org_Index).actual_util_hours / l_u1_tbl(l_Top_Org_Index).actual_denominator);
           ELSE
             l_u1_tbl(l_Top_Org_Index).bill_hours_percent := NULL;
             l_u1_tbl(l_Top_Org_Index).act_util_percent := NULL;
           END IF;

           IF nvl(l_u1_tbl(l_Top_Org_Index).total_resource_hours,0) <> 0 THEN
             l_u1_tbl(l_Top_Org_Index).res_hours_percent := 100 * (l_u1_tbl(l_Top_Org_Index).resource_hours / l_u1_tbl(l_Top_Org_Index).total_resource_hours);
           ELSE
             l_u1_tbl(l_Top_Org_Index).res_hours_percent := NULL;
           END IF;

           --TODO:Does the change need to be null when both values are null??
		   l_u1_tbl(l_Top_Org_Index).change_percent_1 := nvl(l_u1_tbl(l_Top_Org_Index).act_util_percent,0) - nvl(l_u1_tbl(l_Top_Org_Index).prior_act_util_percent,0);
		   l_u1_tbl(l_Top_Org_Index).change_percent_2 := nvl(l_u1_tbl(l_Top_Org_Index).bill_hours_percent,0) - nvl(l_u1_tbl(l_Top_Org_Index).prior_bill_hours_percent,0);
	   	   l_u1_tbl(l_Top_Org_Index).change_percent_3 := nvl(l_u1_tbl(l_Top_Org_Index).res_hours_percent,0) - nvl(l_u1_tbl(l_Top_Org_Index).prior_res_hours_percent,0);

           --Columns for U1 only
           IF nvl(l_u1_tbl(l_Top_Org_Index).scheduled_denominator,0) <> 0 THEN
             l_u1_tbl(l_Top_Org_Index).sch_util_percent := 100 * (l_u1_tbl(l_Top_Org_Index).scheduled_util_hours / l_u1_tbl(l_Top_Org_Index).scheduled_denominator);
           ELSE
             l_u1_tbl(l_Top_Org_Index).sch_util_percent := NULL;
           END IF;

           IF nvl(l_u1_tbl(l_Top_Org_Index).prior_missing_hours,0) <> 0 THEN
             l_u1_tbl(l_Top_Org_Index).missing_hours_percent := 100 * ((l_u1_tbl(l_Top_Org_Index).missing_hours - l_u1_tbl(l_Top_Org_Index).prior_missing_hours)/ l_u1_tbl(l_Top_Org_Index).prior_missing_hours);
           ELSE
             l_u1_tbl(l_Top_Org_Index).missing_hours_percent := NULL;
           END IF;

           l_u1_tbl(l_Top_Org_Index).sch_var_percent := nvl(l_u1_tbl(l_Top_Org_Index).act_util_percent,0) - nvl(l_u1_tbl(l_Top_Org_Index).sch_util_percent,0);

      END IF; --end p_view_by = OG

   --Update local variables to include top level org for grand total
    IF l_Top_Org_Index is not null THEN

      l_actual_capacity_hours          := l_actual_capacity_hours       + nvl(l_u1_tbl(l_Top_Org_Index).ACTUAL_CAPACITY_HOURS,0);
      l_missing_hours                  := l_missing_hours               + nvl(l_u1_tbl(l_Top_Org_Index).MISSING_HOURS,0);
      l_actual_util_hours              := l_actual_util_hours           + nvl(l_u1_tbl(l_Top_Org_Index).ACTUAL_UTIL_HOURS,0);
      l_billable_hours                 := l_billable_hours              + nvl(l_u1_tbl(l_Top_Org_Index).BILLABLE_HOURS,0);
      l_scheduled_util_hours           := l_scheduled_util_hours        + nvl(l_u1_tbl(l_Top_Org_Index).SCHEDULED_UTIL_HOURS,0);
      l_scheduled_capacity_hours       := l_scheduled_capacity_hours    + nvl(l_u1_tbl(l_Top_Org_Index).SCHEDULED_CAPACITY_HOURS,0);
      l_resource_hours                 := l_resource_hours              + nvl(l_u1_tbl(l_Top_Org_Index).RESOURCE_HOURS,0);
      l_total_resource_hours           := l_total_resource_hours        + nvl(l_u1_tbl(l_Top_Org_Index).TOTAL_RESOURCE_HOURS,0);
      l_actual_denominator             := l_actual_denominator          + nvl(l_u1_tbl(l_Top_Org_Index).ACTUAL_DENOMINATOR,0);
      l_scheduled_denominator          := l_scheduled_denominator       + nvl(l_u1_tbl(l_Top_Org_Index).SCHEDULED_DENOMINATOR,0);
      l_prior_actual_capacity_hours    := l_prior_actual_capacity_hours + nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_ACTUAL_CAPACITY_HOURS,0);
      l_prior_missing_hours            := l_prior_missing_hours         + nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_MISSING_HOURS,0);
      l_prior_actual_util_hours        := l_prior_actual_util_hours     + nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_ACTUAL_UTIL_HOURS,0);
      l_prior_billable_hours           := l_prior_billable_hours        + nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_BILLABLE_HOURS,0);
      l_prior_sch_util_hours           := l_prior_sch_util_hours        + nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_SCH_UTIL_HOURS,0);
      l_prior_sch_capacity_hours       := l_prior_sch_capacity_hours    + nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_SCH_CAPACITY_HOURS,0);
      l_prior_resource_hours           := l_prior_resource_hours        + nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_RESOURCE_HOURS,0);
      l_prior_total_resource_hours     := l_prior_total_resource_hours  + nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_TOTAL_RESOURCE_HOURS,0);
      l_prior_actual_denominator       := l_prior_actual_denominator    + nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_ACTUAL_DENOMINATOR,0);
      l_prior_scheduled_denominator    := l_prior_scheduled_denominator + nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_SCHEDULED_DENOMINATOR,0);
    END IF;

   IF l_u1_tbl.COUNT > 0 THEN
   FOR i IN 1..l_u1_tbl.COUNT
	LOOP

      IF l_u1_tbl.EXISTS(i) THEN

        /*Bug 2836444*/
        --Capacity is denormalized when context is view by UC or WT
        IF p_view_by = 'UC' OR p_view_by = 'WT' THEN

          l_actual_denominator := l_u1_tbl(i).ACTUAL_DENOMINATOR;
          l_scheduled_denominator := l_u1_tbl(i).SCHEDULED_DENOMINATOR;
          l_prior_actual_denominator := l_u1_tbl(i).PRIOR_ACTUAL_DENOMINATOR;

        END IF;

        IF nvl(l_actual_denominator,0) <> 0 THEN

          l_u1_tbl(i).PJI_REP_TOTAL_1      := (l_billable_hours/l_actual_denominator)*100;
          l_u1_tbl(i).PJI_REP_TOTAL_3      := (l_actual_util_hours/l_actual_denominator)*100;

        END IF;

        IF nvl(l_prior_actual_denominator,0) <> 0 THEN

          l_u1_tbl(i).PJI_REP_TOTAL_2      := (l_prior_billable_hours/l_prior_actual_denominator)*100;
          l_u1_tbl(i).PJI_REP_TOTAL_4      := (l_prior_actual_util_hours/l_prior_actual_denominator)*100;

        END IF;

        IF nvl(l_total_resource_hours,0) <> 0 THEN

          l_u1_tbl(i).PJI_REP_TOTAL_5      := (l_resource_hours/l_total_resource_hours)*100;

        END IF;

        IF nvl(l_prior_total_resource_hours,0) <> 0 THEN

          l_u1_tbl(i).PJI_REP_TOTAL_6      := (l_prior_resource_hours/l_prior_total_resource_hours)*100;

        END IF;

        l_u1_tbl(i).PJI_REP_TOTAL_7 := l_u1_tbl(i).PJI_REP_TOTAL_1 - l_u1_tbl(i).PJI_REP_TOTAL_2;
        l_u1_tbl(i).PJI_REP_TOTAL_8 := l_u1_tbl(i).PJI_REP_TOTAL_3 - l_u1_tbl(i).PJI_REP_TOTAL_4;
        l_u1_tbl(i).PJI_REP_TOTAL_9 := l_u1_tbl(i).PJI_REP_TOTAL_5 - l_u1_tbl(i).PJI_REP_TOTAL_6;

        --Columns for U1 only
        IF nvl(l_scheduled_denominator,0) <> 0 THEN

          l_u1_tbl(i).PJI_REP_TOTAL_10      := (l_scheduled_util_hours/l_scheduled_denominator)*100;

        END IF;

        IF nvl(l_prior_missing_hours,0) <> 0 THEN

          l_u1_tbl(i).PJI_REP_TOTAL_11      := ((l_missing_hours- l_prior_missing_hours)/l_prior_missing_hours)*100;

        END IF;

        l_u1_tbl(i).PJI_REP_TOTAL_12 := l_u1_tbl(i).PJI_REP_TOTAL_3 - l_u1_tbl(i).PJI_REP_TOTAL_10;

        l_u1_tbl(i).PJI_REP_TOTAL_13 := l_missing_hours;

      END IF; -- l_u1_tbl.EXISTS(i)
	END LOOP;
    END IF; --l_u1_tbl.COUNT > 0

    IF l_Top_Org_Index is not null THEN
        --Delete record for top org if all values are 0 or null
        IF  nvl(l_u1_tbl(l_Top_Org_Index).ACTUAL_CAPACITY_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).MISSING_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).ACTUAL_UTIL_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).BILLABLE_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).SCHEDULED_UTIL_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).SCHEDULED_CAPACITY_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).RESOURCE_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).TOTAL_RESOURCE_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).ACTUAL_DENOMINATOR,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).SCHEDULED_DENOMINATOR,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_ACTUAL_CAPACITY_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_MISSING_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_ACTUAL_UTIL_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_BILLABLE_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_SCH_UTIL_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_SCH_CAPACITY_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_RESOURCE_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_TOTAL_RESOURCE_HOURS,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_ACTUAL_DENOMINATOR,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).PRIOR_SCHEDULED_DENOMINATOR,0) = 0 AND
            nvl(l_u1_tbl(l_Top_Org_Index).prior_res_hours_percent,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).prior_act_util_percent,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).prior_bill_hours_percent,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).bill_hours_percent,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).act_util_percent ,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).res_hours_percent,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).change_percent_1,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).change_percent_2,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).change_percent_3,0) = 0 AND
            nvl(l_u1_tbl(l_Top_Org_Index).sch_util_percent ,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).missing_hours_percent,0) = 0 AND
			nvl(l_u1_tbl(l_Top_Org_Index).sch_var_percent,0) = 0
         THEN
            l_u1_tbl.DELETE(l_Top_Org_Index);
         END IF;
    END IF;

	/*
	 ** Return the bulk collected table back to pmv.
	 */

   COMMIT;
   RETURN l_u1_tbl;

END PLSQLDriver_U1;

FUNCTION PLSQLDriver_U2 (
   p_operating_unit        IN VARCHAR2 DEFAULT NULL,
   p_organization          IN VARCHAR2,
   p_as_of_date            IN NUMBER,
   p_period_type           IN VARCHAR2,
   p_view_by               IN VARCHAR2
)  RETURN PJI_REP_U2_TBL
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   l_u2_tbl                         PJI_REP_U2_TBL:=PJI_REP_U2_TBL();
   l_denominator                    VARCHAR2(25);
   l_labor_unit                     VARCHAR2(40);
   l_Top_Org_Index                  NUMBER;
   l_Top_Organization_Name          VARCHAR2(240);
BEGIN
   PJI_PMV_ENGINE.Convert_Operating_Unit (p_operating_unit, p_view_by);
   PJI_PMV_ENGINE.Convert_Organization(P_TOP_ORGANIZATION_ID   => p_Organization
                                     , P_VIEW_BY               => p_view_by
                                     , P_TOP_ORGANIZATION_NAME => l_Top_Organization_Name );
   PJI_PMV_ENGINE.Convert_Time (p_as_of_date, p_period_type, p_view_by, 'Y');

   /*
    * Get Utilization percentage denominator profile value
    */
   BEGIN
     SELECT fnd_profile.value('PA_ORG_UTIL_DEF_CALC_METHOD')
     INTO l_denominator
     from dual;

     EXCEPTION WHEN NO_DATA_FOUND THEN
         l_denominator := 'CAPACITY';
   END;

   /*
    * Get report labor unit
    */
   BEGIN
     select report_labor_units
     into l_labor_unit
     from pji_system_settings;

   EXCEPTION WHEN OTHERS THEN
         l_labor_unit := null;
   END;

   SELECT PJI_REP_U2(org_id,
                     organization_id,
                     time_id,
                     time_key,
                     sum(actual_capacity_hours),
                     sum(missing_hours),
                     sum(actual_utilization_hours),
                     sum(billable_hours),
                     sum(nonbillable_hours),
                     sum(training_hours),
                     sum(scheduled_capacity_hours),
                     sum(conf_scheduled_hours),
                     sum(prov_scheduled_hours),
                     sum(scheduled_utilization_hours),
                     sum(decode(l_denominator, 'CAPACITY', actual_capacity_hours, actual_hours)),
                     sum(decode(l_denominator, 'CAPACITY', scheduled_capacity_hours, actual_hours)),
                     sum(prior_actual_util_hours),
                     sum(prior_actual_capacity_hours),
                     sum(decode(l_denominator, 'CAPACITY', prior_actual_capacity_hours, prior_actual_hours)),
                        null,null,null,null,null,null)
   BULK COLLECT INTO l_u2_tbl
   /* Bug 3515594 */
   FROM (
        SELECT /*+ ORDERED */
               hou.name                                       org_id,
               horg.name                                      organization_id,
               time.name                                      time_id,
               DECODE(p_view_by, 'TM', time.order_by_id, -1)  time_key,
               (capacity_hrs - reduce_capacity_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                              actual_capacity_hours,
               missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                              missing_hours,
               total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                              actual_utilization_hours,
               bill_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                              billable_hours,
               (total_wtd_org_hrs_a - bill_wtd_org_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                              nonbillable_hours,
               training_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                              training_hours,
               (capacity_hrs - reduce_capacity_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                              scheduled_capacity_hours,
               conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                              conf_scheduled_hours,
               prov_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                              prov_scheduled_hours,
               conf_wtd_org_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                              scheduled_utilization_hours,
               total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                              actual_hours,
               0                                              prior_actual_util_hours,
               0                                              prior_actual_capacity_hours,
               0                                              prior_actual_hours
        FROM PJI_PMV_ORGZ_DIM_TMP horg,
             PJI_PMV_TIME_DIM_TMP time,
             PJI_RM_ORGO_F_MV fct,
             PJI_PMV_ORG_DIM_TMP hou,
             PA_IMPLEMENTATIONS_ALL imp
        WHERE fct.expenditure_org_id = hou.id
          AND fct.expenditure_organization_id = horg.id
          AND fct.time_id = time.id
          AND fct.period_type_id = time.period_type
          AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
          AND time.id is not null
          AND hou.id = imp.org_id
        UNION ALL
	/* Bug 3515594 */
        SELECT /*+ ORDERED */
               hou.name                                       org_id,
               horg.name                                      organization_id,
               time.name                                      time_id,
               DECODE(p_view_by, 'TM', time.order_by_id, -1)  time_key,
               0                                              actual_capacity_hours,
               0                                              missing_hours,
               0                                              actual_utilization_hours,
               0                                              billable_hours,
               0                                              nonbillable_hours,
               0                                              training_hours,
               0                                              scheduled_capacity_hours,
               0                                              conf_scheduled_hours,
               0                                              prov_scheduled_hours,
               0                                              scheduled_utilization_hours,
               0                                              actual_hours,
               total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                              prior_actual_util_hours,
               (capacity_hrs - reduce_capacity_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                              prior_actual_capacity_hours,
               total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                              prior_actual_hours
        FROM PJI_PMV_ORGZ_DIM_TMP horg,
             PJI_PMV_TIME_DIM_TMP time,
             PJI_RM_ORGO_F_MV fct,
             PJI_PMV_ORG_DIM_TMP hou,
             PA_IMPLEMENTATIONS_ALL imp
        WHERE fct.expenditure_org_id = hou.id
          AND fct.expenditure_organization_id = horg.id
          AND fct.time_id = time.prior_id
          AND fct.period_type_id = time.period_type
          AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
          AND time.prior_id is not null
          AND hou.id = imp.org_id
        UNION ALL
        SELECT '-1'                                           org_id,
               '-1'                                           organization_id,
               name                                           time_id,
               order_by_id                                    time_key,
               0                                              actual_capacity_hours,
               0                                              missing_hours,
               0                                              actual_utilization_hours,
               0                                              billable_hours,
               0                                              nonbillable_hours,
               0                                              training_hours,
               0                                              scheduled_capacity_hours,
               0                                              conf_scheduled_hours,
               0                                              prov_scheduled_hours,
               0                                              scheduled_utilization_hours,
               0                                              actual_hours,
               0                                              prior_actual_util_hours,
               0                                              prior_actual_capacity_hours,
               0                                              prior_actual_hours
        FROM PJI_PMV_TIME_DIM_TMP
        WHERE name <> '-1'
        )
        GROUP BY org_id,
                  organization_id,
                  time_key,
                  time_id ORDER BY TIME_KEY ASC;

   FOR i in 1..l_u2_tbl.COUNT
   LOOP

      --Calculated columns processing is done below
      IF nvl(l_u2_tbl(i).actual_denominator,0) <> 0 THEN
        l_u2_tbl(i).act_util_percent     := 100 * (l_u2_tbl(i).actual_utilization_hours / l_u2_tbl(i).actual_denominator);
        l_u2_tbl(i).bill_util_percent    := 100 * (l_u2_tbl(i).billable_hours / l_u2_tbl(i).actual_denominator);
        l_u2_tbl(i).nonbill_util_percent := 100 * (l_u2_tbl(i).nonbillable_hours / l_u2_tbl(i).actual_denominator);
        l_u2_tbl(i).training_percent     := 100 * (l_u2_tbl(i).training_hours / l_u2_tbl(i).actual_denominator);

      ELSE
        l_u2_tbl(i).act_util_percent     := NULL;
        l_u2_tbl(i).bill_util_percent    := NULL;
        l_u2_tbl(i).nonbill_util_percent := NULL;
		l_u2_tbl(i).training_percent     := NULL;

      END IF;

      IF nvl(l_u2_tbl(i).scheduled_denominator,0) <> 0 THEN
        l_u2_tbl(i).sch_util_percent     := 100 * (l_u2_tbl(i).scheduled_utilization_hours / l_u2_tbl(i).scheduled_denominator);
      ELSE
        l_u2_tbl(i).sch_util_percent     := NULL;
      END IF;

      IF nvl(l_u2_tbl(i).prior_actual_denominator,0) <> 0 THEN
        l_u2_tbl(i).prior_util_percent     := 100 * (l_u2_tbl(i).prior_actual_util_hours / l_u2_tbl(i).prior_actual_denominator);
      ELSE
        l_u2_tbl(i).prior_util_percent     := NULL;
      END IF;

   END LOOP;

   COMMIT;
   RETURN l_u2_tbl;

END PLSQLDriver_U2;

FUNCTION PLSQLDriver_U3 (
   p_operating_unit        IN VARCHAR2 DEFAULT NULL,
   p_organization          IN VARCHAR2,
   p_as_of_date            IN NUMBER,
   p_period_type           IN VARCHAR2,
   p_view_by               IN VARCHAR2,
   p_utilization_category  IN VARCHAR2 DEFAULT NULL,
   p_work_type             IN VARCHAR2 DEFAULT NULL,
   p_job_level             IN VARCHAR2 DEFAULT NULL
)  RETURN PJI_REP_U3_TBL
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   l_u3_tbl                         PJI_REP_U3_TBL:=PJI_REP_U3_TBL();
   l_util_category_flag             VARCHAR2(1);
   l_job_flag                       VARCHAR2(1);
   l_denominator                    VARCHAR2(25);
   l_labor_unit                     VARCHAR2(40);
   l_actual_hours                   NUMBER := 0;
   l_capacity_hours                 NUMBER := 0;
   l_missing_hours                  NUMBER := 0;
   l_utilization_hours              NUMBER := 0;
   l_billable_hours                 NUMBER := 0;
   l_nonbillable_hours              NUMBER := 0;
   l_training_hours                 NUMBER := 0;
   l_actual_denominator             NUMBER := 0;
   l_prior_actual_hours             NUMBER := 0;
   l_prior_capacity_hours           NUMBER := 0;
   l_prior_utilization_hours        NUMBER := 0;
   l_prior_billable_hours           NUMBER := 0;
   l_prior_nonbillable_hours        NUMBER := 0;
   l_prior_training_hours           NUMBER := 0;
   l_prior_actual_denominator       NUMBER := 0;
   l_Top_Org_Index                  NUMBER;
   l_Top_Organization_Name          VARCHAR2(240);
BEGIN
   PJI_PMV_ENGINE.Convert_Operating_Unit (p_operating_unit, p_view_by);
   PJI_PMV_ENGINE.Convert_Time (p_as_of_date, p_period_type, p_view_by, 'Y');
   l_util_category_flag := PJI_PMV_ENGINE.Convert_Util_Category(p_work_type, p_utilization_category, p_view_by);
   l_job_flag := PJI_PMV_ENGINE.Convert_Job_Level(null, p_job_level, p_view_by);

   /*
    * Get Utilization percentage denominator profile value
    */
   BEGIN
     SELECT fnd_profile.value('PA_ORG_UTIL_DEF_CALC_METHOD')
     INTO l_denominator
     from dual;

     EXCEPTION WHEN NO_DATA_FOUND THEN
         l_denominator := 'CAPACITY';
   END;

   /*
    * Get report labor unit
    */
   BEGIN
     select report_labor_units
     into l_labor_unit
     from pji_system_settings;

   EXCEPTION WHEN OTHERS THEN
         l_labor_unit := null;
   END;

   IF l_util_category_flag = 'N' AND l_job_flag = 'N' THEN

      PJI_PMV_ENGINE.Convert_Organization(P_TOP_ORGANIZATION_ID   => p_Organization
                                        , P_VIEW_BY               => p_view_by
                                        , P_TOP_ORGANIZATION_NAME => l_Top_Organization_Name );


      SELECT PJI_REP_U3(org_id,
                        organization_id,
                        time_id,
                        time_key,
                        util_category_id,
                        work_type_id,
                        job_level_id,
                        sum(actual_hours),
                        sum(capacity_hours),
                        sum(missing_hours),
                        sum(utilization_hours),
                        sum(billable_hours),
                        sum(nonbillable_hours),
                        sum(training_hours),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours, actual_hours)),
                        sum(prior_actual_hours),
                        sum(prior_capacity_hours),
                        sum(prior_utilization_hours),
                        sum(prior_billable_hours),
                        sum(prior_nonbillable_hours),
                        sum(prior_training_hours),
                        sum(decode(l_denominator, 'CAPACITY', prior_capacity_hours, prior_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null
                        )
      BULK COLLECT INTO l_u3_tbl
      /* Bug 3515594 */
      FROM (
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  horg.name                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          actual_hours,
                  (capacity_hrs - reduce_capacity_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          capacity_hours,
                  missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          missing_hours,
                  total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          utilization_hours,
                  bill_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          billable_hours,
                  (total_wtd_org_hrs_a - bill_wtd_org_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          nonbillable_hours,
                  training_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_capacity_hours,
                  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_RM_ORGO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.id is not null
             AND hou.id = imp.org_id
           UNION ALL
	   /* Bug 3515594 */
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  horg.name                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       missing_hours,
                  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_actual_hours,
                  (capacity_hrs - reduce_capacity_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_capacity_hours,
                  total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_utilization_hours,
                  bill_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_billable_hours,
                  (total_wtd_org_hrs_a - bill_wtd_org_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_nonbillable_hours,
                  training_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_training_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_RM_ORGO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.time_id = time.prior_id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.prior_id is not null
             AND hou.id = imp.org_id
           UNION ALL
           SELECT '-1'                                    org_id,
                  name                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       missing_hours,
                  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_capacity_hours,
                  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_ORGZ_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  name                                    time_id,
                  order_by_id                             time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       missing_hours,
                  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_capacity_hours,
                  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_TIME_DIM_TMP
           WHERE name <> '-1'
           )
           GROUP BY org_id,
		    organization_id,
		    time_id,
		    time_key,
		    util_category_id,
            work_type_id,
		    job_level_id;

   ELSIF l_job_flag = 'N' THEN

      PJI_PMV_ENGINE.Convert_Organization(P_TOP_ORGANIZATION_ID   => p_Organization
                                     , P_VIEW_BY               => p_view_by
                                     , P_TOP_ORGANIZATION_NAME => l_Top_Organization_Name );


      SELECT PJI_REP_U3(org_id,
                        organization_id,
                        time_id,
                        time_key,
                        util_category_id,
                        work_type_id,
                        job_level_id,
                        sum(actual_hours),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, capacity_hours-act_reduce_capacity_hours)),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, missing_hours)),
                        sum(utilization_hours),
                        sum(billable_hours),
                        sum(nonbillable_hours),
                        sum(training_hours),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-act_reduce_capacity_hours, total_actual_hours)),
                        sum(prior_actual_hours),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, prior_act_capacity_hours-prior_act_red_capacity_hours)),
                        sum(prior_utilization_hours),
                        sum(prior_billable_hours),
                        sum(prior_nonbillable_hours),
                        sum(prior_training_hours),
                        sum(decode(l_denominator, 'CAPACITY', prior_act_capacity_hours-prior_act_red_capacity_hours,
                            prior_total_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null
                        )
      BULK COLLECT INTO l_u3_tbl
      /* Bug 3515594 */
      FROM (
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  horg.name                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  decode(p_view_by, 'UC', wt.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', wt.name, '-1')  work_type_id,
                  '-1'                                    job_level_id,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          actual_hours,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
		  null                                    missing_hours,
		  0 					  total_actual_hours,
		  fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1) *
                  worktype.org_utilization_percentage / 100
                                                          utilization_hours,
                  (fct.bill_hrs_a * worktype.org_utilization_percentage / 100)
                                 / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          billable_hours,
                  ((fct.total_hrs_a - fct.bill_hrs_a) * worktype.org_utilization_percentage / 100)
                                                     / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          nonbillable_hours,
                  (CASE WHEN worktype.training_flag = 'Y' THEN
                  fct.total_hrs_a
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_act_capacity_hours,
		  0                                       prior_act_red_capacity_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_WT_DIM_TMP wt,
                PJI_RM_WTO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_WORK_TYPES_B worktype,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND wt.id = worktype.work_type_id
             AND fct.work_type_id = wt.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.id is not null
             AND hou.id = imp.org_id
           UNION ALL
	   /* Bug 3515594 */
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  horg.name                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  decode(p_view_by, 'UC', wt.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', wt.name, '-1')  work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_actual_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
		  0 					  prior_total_actual_hours,
		  (fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                          prior_utilization_hours,
                  (fct.bill_hrs_a * worktype.org_utilization_percentage / 100)
                                 / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_billable_hours,
                  ((fct.total_hrs_a-fct.bill_hrs_a) * worktype.org_utilization_percentage / 100)
                                                   / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_nonbillable_hours,
                  (CASE WHEN worktype.training_flag = 'Y' THEN
                  fct.total_hrs_a
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_training_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_WT_DIM_TMP wt,
                PJI_RM_WTO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_WORK_TYPES_B worktype,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND wt.id = worktype.work_type_id
             AND fct.work_type_id = wt.id
             AND fct.time_id = time.prior_id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.prior_id is not null
             AND hou.id = imp.org_id
           UNION ALL
           SELECT '-1'                                    org_id,
                  name                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_ORGZ_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  decode(p_view_by, 'UC', name, '-1')     util_category_id,
                  decode(p_view_by, 'WT', name, '-1')     work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_act_capacity_hours,
		  0                                       prior_act_red_capacity_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_WT_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  name                                    time_id,
                  order_by_id                             time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_TIME_DIM_TMP
           WHERE name <> '-1'
           UNION ALL  -- added for current year capacity_hours
           SELECT
                  FACT.org_id,
                  FACT.organization_id,
                  FACT.time_id,
                  FACT.time_key,
                  decode(p_view_by, 'UC', WT.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', WT.name, '-1')  work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_hours,
                  FACT.capacity_hours,
                  FACT.reduce_capacity_hrs_a              act_reduce_capacity_hours,
                  FACT.missing_hrs_a                      missing_hours,
		  FACT.total_actual_hours                 total_actual_hours,
		  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM
	   /* Bug 3515594 */
            (SELECT /*+ ORDERED */
                     hou.name                                org_id,
                     horg.name                               organization_id,
                     time.name                               time_id,
                     DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                     fct.capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          capacity_hours,
                     fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          total_actual_hours,

		     fct.missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          missing_hrs_a,
                     fct.reduce_capacity_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          reduce_capacity_hrs_a
             FROM PJI_PMV_ORGZ_DIM_TMP horg,
                  PJI_PMV_TIME_DIM_TMP time,
                  PJI_RM_ORGO_F_MV fct,
                  PJI_PMV_ORG_DIM_TMP hou,
                  PA_IMPLEMENTATIONS_ALL imp
             WHERE fct.expenditure_org_id = hou.id
             AND   fct.expenditure_organization_id = horg.id
             AND   fct.time_id = time.id
             AND   fct.period_type_id = time.period_type
             AND   fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND   time.id is not null
             AND   hou.id = imp.org_id )         FACT,
             (SELECT distinct WT.name
              FROM   PJI_PMV_WT_DIM_TMP wt )     WT
           UNION ALL  -- added for prior year capacity_hours
           SELECT
                  FACT.org_id,
                  FACT.organization_id,
                  FACT.time_id,
                  FACT.time_key,
                  decode(p_view_by, 'UC', WT.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', WT.name, '-1')  work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  FACT.capacity_hours                     prior_act_capacity_hours,
                  FACT.reduce_capacity_hrs_a              prior_act_red_capacity_hours,
		  FACT.total_actual_hours		  prior_total_actual_hours,
		  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM
	   /* Bug 3515594 */
            (SELECT /*+ ORDERED */
                     hou.name                                org_id,
                     horg.name                               organization_id,
                     time.name                               time_id,
                     DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                     fct.capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          capacity_hours,
                     fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          total_actual_hours,

		     fct.reduce_capacity_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          reduce_capacity_hrs_a
             FROM PJI_PMV_ORGZ_DIM_TMP horg,
                  PJI_PMV_TIME_DIM_TMP time,
                  PJI_RM_ORGO_F_MV fct,
                  PJI_PMV_ORG_DIM_TMP hou,
                  PA_IMPLEMENTATIONS_ALL imp
             WHERE fct.expenditure_org_id = hou.id
             AND   fct.expenditure_organization_id = horg.id
             AND   fct.time_id = time.prior_id
             AND   fct.period_type_id = time.period_type
             AND   fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND   time.prior_id is not null
             AND   hou.id = imp.org_id )         FACT,
             (SELECT distinct WT.name
              FROM   PJI_PMV_WT_DIM_TMP wt )     WT
           )
           GROUP BY org_id,
		    organization_id,
		    time_id,
		    time_key,
		    util_category_id,
            work_type_id,
		    job_level_id;


   ELSIF l_util_category_flag = 'N' THEN

      PJI_PMV_ENGINE.Convert_Organization(P_TOP_ORGANIZATION_ID   => p_Organization
                                     , P_VIEW_BY               => p_view_by
                                     , P_TOP_ORGANIZATION_NAME => l_Top_Organization_Name );


      SELECT PJI_REP_U3(org_id,
                        organization_id,
                        time_id,
                        time_key,
                        util_category_id,
                        work_type_id,
                        job_level_id,
                        sum(actual_hours),
                        sum(capacity_hours - reduce_capacity_hrs_a),
                        sum(missing_hours),
                        sum(utilization_hours),
                        sum(billable_hours),
                        sum(nonbillable_hours),
                        sum(training_hours),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours - reduce_capacity_hrs_a, actual_hours)),
                        sum(prior_actual_hours),
                        sum(prior_capacity_hours - prior_reduce_capacity_hrs_a),
                        sum(prior_utilization_hours),
                        sum(prior_billable_hours),
                        sum(prior_nonbillable_hours),
                        sum(prior_training_hours),
                        sum(decode(l_denominator, 'CAPACITY', prior_capacity_hours - prior_reduce_capacity_hrs_a, prior_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null
                        )
      BULK COLLECT INTO l_u3_tbl
      /* Bug 3515594 */
      FROM (
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  horg.name                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  job.name                                job_level_id,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          actual_hours,
                  capacity_hrs                            capacity_hours,
                  reduce_capacity_hrs_a                   reduce_capacity_hrs_a,
                  missing_hrs_a                           missing_hours,
                  total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          utilization_hours,
                  bill_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          billable_hours,
                  (total_wtd_org_hrs_a - bill_wtd_org_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          nonbillable_hours,
                  training_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_capacity_hours,
                  0                                       prior_reduce_capacity_hrs_a,
                  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_JB_DIM_TMP job,
                PJI_RM_JOBO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.job_id = job.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.id is not null
             AND hou.id = imp.org_id
           UNION ALL
	   /* Bug 3515594 */
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  horg.name                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  job.name                                job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       reduce_capacity_hrs_a,
                  null                                    missing_hours,
                  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_actual_hours,
                  capacity_hrs                            prior_capacity_hours,
                  reduce_capacity_hrs_a                   prior_reduce_capacity_hrs_a,
                  total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_utilization_hours,
                  bill_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_billable_hours,
                  (total_wtd_org_hrs_a - bill_wtd_org_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_nonbillable_hours,
                  training_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_training_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_JB_DIM_TMP job,
                PJI_RM_JOBO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.job_id = job.id
             AND fct.time_id = time.prior_id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.prior_id is not null
             AND hou.id = imp.org_id
           UNION ALL
           SELECT '-1'                                    org_id,
                  name                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       reduce_capacity_hrs_a,
                  null                                    missing_hours,
                  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_capacity_hours,
                  0                                       prior_reduce_capacity_hrs_a,
                  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_ORGZ_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  name                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       reduce_capacity_hrs_a,
                  null                                    missing_hours,
                  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_capacity_hours,
                  0                                       prior_reduce_capacity_hrs_a,
                  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_JB_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  name                                    time_id,
                  order_by_id                             time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       reduce_capacity_hrs_a,
                  null                                    missing_hours,
                  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_capacity_hours,
                  0                                       prior_reduce_capacity_hrs_a,
                  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_TIME_DIM_TMP
           WHERE name <> '-1'
           )
           GROUP BY org_id,
		    organization_id,
		    time_id,
		    time_key,
		    util_category_id,
            work_type_id,
		    job_level_id;

   ELSE

      PJI_PMV_ENGINE.Convert_Organization(p_Organization, p_view_by);


      SELECT PJI_REP_U3(org_id,
                        organization_id,
                        time_id,
                        time_key,
                        util_category_id,
                        work_type_id,
                        job_level_id,
                        sum(actual_hours),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, capacity_hours-act_reduce_capacity_hours)),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, missing_hours)),
                        sum(utilization_hours),
                        sum(billable_hours),
                        sum(nonbillable_hours),
                        sum(training_hours),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-act_reduce_capacity_hours, total_actual_hours)),
                        sum(prior_actual_hours),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, prior_act_capacity_hours-prior_act_red_capacity_hours)),
                        sum(prior_utilization_hours),
                        sum(prior_billable_hours),
                        sum(prior_nonbillable_hours),
                        sum(prior_training_hours),
                        sum(decode(l_denominator, 'CAPACITY', prior_act_capacity_hours-prior_act_red_capacity_hours,
                            prior_total_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null)
      BULK COLLECT INTO l_u3_tbl
      /* Bug 3515594 */
      FROM (
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  decode(p_view_by, 'OG', horg.name, -1)                               organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  decode(p_view_by, 'UC', wt.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', wt.name, '-1')  work_type_id,
                  decode(p_view_by, 'JL', job.name , '-1') job_level_id,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          actual_hours,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
                  (fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                          utilization_hours,
                  (fct.bill_hrs_a * worktype.org_utilization_percentage / 100)
                                 / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          billable_hours,
                  ((fct.total_hrs_a - fct.bill_hrs_a) * worktype.org_utilization_percentage / 100)
                                                     / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          nonbillable_hours,
                  (CASE WHEN worktype.training_flag = 'Y' THEN
                  fct.total_hrs_a
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_WT_DIM_TMP wt,
                PJI_RM_RES_WT_F fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PJI_PMV_JB_DIM_TMP job,
                PA_WORK_TYPES_B worktype,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND wt.id = worktype.work_type_id
             AND fct.work_type_id = wt.id
             AND fct.job_id = job.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.id is not null
             AND hou.id = imp.org_id
           UNION ALL
	   /* Bug 3515594 */
           SELECT /*+ ORDERED */
                  hou.name                                org_id,
                  decode(p_view_by, 'OG', horg.name, -1)  organization_id,
                  time.name                               time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                  decode(p_view_by, 'UC', wt.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', wt.name, '-1')  work_type_id,
                  decode(p_view_by, 'JL', job.name , '-1') job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_actual_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
		  0 					  prior_total_actual_hours,
		  fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1) *
                  worktype.org_utilization_percentage / 100
                                                          prior_utilization_hours,
                  (fct.bill_hrs_a * worktype.org_utilization_percentage / 100)
                                 / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_billable_hours,
                  ((fct.total_hrs_a-fct.bill_hrs_a) * worktype.org_utilization_percentage / 100)
                                                   / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_nonbillable_hours,
                  (CASE WHEN worktype.training_flag = 'Y' THEN
                  fct.total_hrs_a
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_training_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_WT_DIM_TMP wt,
                PJI_RM_RES_WT_F fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PJI_PMV_JB_DIM_TMP job,
                PA_WORK_TYPES_B worktype,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND wt.id = worktype.work_type_id
             AND fct.work_type_id = wt.id
             AND fct.job_id = job.id
             AND fct.time_id = time.prior_id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.prior_id is not null
             AND hou.id = imp.org_id
           UNION ALL
           SELECT '-1'                                    org_id,
                  decode(p_view_by, 'OG', name, -1)  organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_ORGZ_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  decode(p_view_by, 'UC', name, '-1')     util_category_id,
                  decode(p_view_by, 'WT', name, '-1')     work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_WT_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  '-1'                                    time_id,
                  -1                                      time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  name                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_JB_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                    org_id,
                  '-1'                                    organization_id,
                  name                                    time_id,
                  order_by_id                             time_key,
                  '-1'                                    util_category_id,
                  '-1'                                    work_type_id,
                  '-1'                                    job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
                  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                 -- 0                                     prior_capacity_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
		  0 					  prior_total_actual_hours,
		  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM PJI_PMV_TIME_DIM_TMP
           WHERE name <> '-1'
           UNION ALL  -- added for current year capacity_hours
           SELECT
                  FACT.org_id,
                  FACT.organization_id,
                  FACT.time_id,
                  FACT.time_key,
                  decode(p_view_by, 'UC', WT.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', WT.name, '-1')  work_type_id,
                  decode(p_view_by, 'JL', FACT.job_level_id , '-1') job_level_id,
                  0                                       actual_hours,
                  FACT.capacity_hours			  capacity_hours,
                  FACT.reduce_capacity_hrs_a              act_reduce_capacity_hours,
                  FACT.missing_hrs_a                      missing_hours,
		  FACT.total_actual_hours		  total_actual_hours,
		  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  0                                       prior_act_capacity_hours,
                  0                                       prior_act_red_capacity_hours,
		  0 					  prior_total_actual_hours,
                  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM
	     /* Bug 3515594 */
            (SELECT /*+ ORDERED */
                     hou.name                                org_id,
                     decode(p_view_by, 'OG', horg.name, -1)  organization_id,
                     time.name                               time_id,
                     DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                     job.name                                job_level_id,
                     fct.capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          capacity_hours,
                     fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          total_actual_hours,

		     fct.missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          missing_hrs_a,
                     fct.reduce_capacity_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          reduce_capacity_hrs_a
             FROM PJI_PMV_ORGZ_DIM_TMP horg,
                  PJI_PMV_TIME_DIM_TMP time,
                  PJI_PMV_JB_DIM_TMP   job,
                  PJI_RM_JOB_F_MV fct,
                  PJI_PMV_ORG_DIM_TMP hou,
                  PA_IMPLEMENTATIONS_ALL imp
             WHERE fct.expenditure_org_id = hou.id
             AND   fct.expenditure_organization_id = horg.id
             AND   fct.time_id = time.id
             AND   fct.period_type_id = time.period_type
             AND   fct.job_id  = job.id
             AND   fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND   time.id is not null
             AND   hou.id = imp.org_id )         FACT,
             (SELECT distinct WT.name
              FROM   PJI_PMV_WT_DIM_TMP wt )     WT
           UNION ALL  -- added for prior year capacity_hours
	   /* Bug 3515594 */
           SELECT
                  FACT.org_id,
                  FACT.organization_id,
                  FACT.time_id,
                  FACT.time_key,
                  decode(p_view_by, 'UC', WT.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', WT.name, '-1')  work_type_id,
                  decode(p_view_by, 'JL', FACT.job_level_id , '-1') job_level_id,
                  0                                       actual_hours,
                  0                                       capacity_hours,
                  0                                       act_reduce_capacity_hours,
                  null                                    missing_hours,
		  0 					  total_actual_hours,
		  0                                       utilization_hours,
                  0                                       billable_hours,
                  0                                       nonbillable_hours,
                  0                                       training_hours,
                  0                                       prior_actual_hours,
                  FACT.capacity_hours                     prior_act_capacity_hours,
                  FACT.reduce_capacity_hrs_a              prior_act_red_capacity_hours,
		  FACT.total_actual_hours		  prior_total_actual_hours,
		  0                                       prior_utilization_hours,
                  0                                       prior_billable_hours,
                  0                                       prior_nonbillable_hours,
                  0                                       prior_training_hours
           FROM
            (SELECT /*+ ORDERED */
                     hou.name                                org_id,
                     decode(p_view_by, 'OG', horg.name, -1)  organization_id,
                     time.name                               time_id,
                     DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                     job.name                                job_level_id,
                     fct.capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          capacity_hours,
                     fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          total_actual_hours,
                     fct.reduce_capacity_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          reduce_capacity_hrs_a
             FROM PJI_PMV_ORGZ_DIM_TMP horg,
                  PJI_PMV_TIME_DIM_TMP time,
                  PJI_PMV_JB_DIM_TMP   job,
                  PJI_RM_JOB_F_MV fct,
                  PJI_PMV_ORG_DIM_TMP hou,
                  PA_IMPLEMENTATIONS_ALL imp
             WHERE fct.expenditure_org_id = hou.id
             AND   fct.expenditure_organization_id = horg.id
             AND   fct.time_id = time.prior_id
             AND   fct.period_type_id = time.period_type
             AND   fct.job_id = job.id
             AND   fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND   time.prior_id is not null
             AND   hou.id = imp.org_id )         FACT,
             (SELECT distinct WT.name
              FROM   PJI_PMV_WT_DIM_TMP wt )     WT
           )
           GROUP BY org_id,
		     organization_id,
		     time_id,
		     time_key,
		     util_category_id,
             work_type_id,
		     job_level_id;

   END IF;

   /* Totals and Top level org correction*/

     FOR i in 1..l_u3_tbl.COUNT
       LOOP
         IF p_View_By = 'OG' AND ( l_job_flag = 'N' OR l_util_category_flag = 'N' )
            AND l_u3_tbl(i).ORGANIZATION_ID = l_Top_Organization_Name THEN

           l_Top_Org_Index:=i;

         ELSE

           l_actual_hours                 := l_actual_hours             + nvl(l_u3_tbl(i).actual_hours,0);
		   l_capacity_hours          	  := l_capacity_hours          	+ nvl(l_u3_tbl(i).capacity_hours,0);
		   l_missing_hours           	  := l_missing_hours           	+ nvl(l_u3_tbl(i).missing_hours,0);
		   l_utilization_hours       	  := l_utilization_hours       	+ nvl(l_u3_tbl(i).utilization_hours,0);
		   l_billable_hours          	  := l_billable_hours          	+ nvl(l_u3_tbl(i).billable_hours,0);
		   l_nonbillable_hours       	  := l_nonbillable_hours       	+ nvl(l_u3_tbl(i).nonbillable_hours,0);
		   l_training_hours          	  := l_training_hours          	+ nvl(l_u3_tbl(i).training_hours,0);
		   l_actual_denominator      	  := l_actual_denominator      	+ nvl(l_u3_tbl(i).actual_denominator,0);
		   l_prior_actual_hours      	  := l_prior_actual_hours      	+ nvl(l_u3_tbl(i).prior_actual_hours,0);
		   l_prior_capacity_hours    	  := l_prior_capacity_hours    	+ nvl(l_u3_tbl(i).prior_capacity_hours,0);
		   l_prior_utilization_hours 	  := l_prior_utilization_hours 	+ nvl(l_u3_tbl(i).prior_utilization_hours,0);
		   l_prior_billable_hours    	  := l_prior_billable_hours    	+ nvl(l_u3_tbl(i).prior_billable_hours,0);
		   l_prior_nonbillable_hours 	  := l_prior_nonbillable_hours 	+ nvl(l_u3_tbl(i).prior_nonbillable_hours,0);
		   l_prior_training_hours    	  := l_prior_training_hours    	+ nvl(l_u3_tbl(i).prior_training_hours,0);
		   l_prior_actual_denominator     := l_prior_actual_denominator	+ nvl(l_u3_tbl(i).prior_actual_denominator,0);

           --Calculated Columns processing is done below
           --The l_Top_org is not done here
           IF nvl(l_u3_tbl(i).actual_denominator,0) <> 0 THEN
             l_u3_tbl(i).util_percent := 100 * (l_u3_tbl(i).utilization_hours / l_u3_tbl(i).actual_denominator);
             l_u3_tbl(i).bill_percent := 100 * (l_u3_tbl(i).billable_hours / l_u3_tbl(i).actual_denominator);
             l_u3_tbl(i).non_bill_percent := 100 * (l_u3_tbl(i).nonbillable_hours / l_u3_tbl(i).actual_denominator);
             l_u3_tbl(i).training_percent := 100 * (l_u3_tbl(i).training_hours / l_u3_tbl(i).actual_denominator);
           ELSE
             l_u3_tbl(i).util_percent := NULL;
             l_u3_tbl(i).bill_percent := NULL;
             l_u3_tbl(i).non_bill_percent := NULL;
             l_u3_tbl(i).training_percent := NULL;
           END IF;

           IF nvl(l_u3_tbl(i).prior_actual_denominator,0) <> 0 THEN
             l_u3_tbl(i).prior_util_percent := 100 * (l_u3_tbl(i).prior_utilization_hours / l_u3_tbl(i).prior_actual_denominator);
             l_u3_tbl(i).prior_bill_percent := 100 * (l_u3_tbl(i).prior_billable_hours / l_u3_tbl(i).prior_actual_denominator);
             l_u3_tbl(i).prior_non_bill_percent := 100 * (l_u3_tbl(i).prior_nonbillable_hours / l_u3_tbl(i).prior_actual_denominator);
             l_u3_tbl(i).prior_training_percent := 100 * (l_u3_tbl(i).prior_training_hours / l_u3_tbl(i).prior_actual_denominator);
           ELSE
             l_u3_tbl(i).prior_util_percent := NULL;
             l_u3_tbl(i).prior_bill_percent := NULL;
             l_u3_tbl(i).prior_non_bill_percent := NULL;
             l_u3_tbl(i).prior_training_percent := NULL;
           END IF;

         END IF; --end p_view_by
       END LOOP;

       --Processing for Top Org
       IF p_View_By = 'OG' AND ( l_job_flag = 'N' OR l_util_category_flag = 'N' )  THEN

           l_u3_tbl(l_Top_Org_Index).actual_hours              :=  l_u3_tbl(l_Top_Org_Index).actual_hours             - l_actual_hours;
     	   l_u3_tbl(l_Top_Org_Index).capacity_hours            :=  l_u3_tbl(l_Top_Org_Index).capacity_hours           - l_capacity_hours;
		   l_u3_tbl(l_Top_Org_Index).missing_hours             :=  l_u3_tbl(l_Top_Org_Index).missing_hours            - l_missing_hours;
 		   l_u3_tbl(l_Top_Org_Index).utilization_hours         :=  l_u3_tbl(l_Top_Org_Index).utilization_hours        - l_utilization_hours;
		   l_u3_tbl(l_Top_Org_Index).billable_hours            :=  l_u3_tbl(l_Top_Org_Index).billable_hours           - l_billable_hours;
		   l_u3_tbl(l_Top_Org_Index).nonbillable_hours         :=  l_u3_tbl(l_Top_Org_Index).nonbillable_hours        - l_nonbillable_hours;
		   l_u3_tbl(l_Top_Org_Index).training_hours            :=  l_u3_tbl(l_Top_Org_Index).training_hours           - l_training_hours;
		   l_u3_tbl(l_Top_Org_Index).actual_denominator        :=  l_u3_tbl(l_Top_Org_Index).actual_denominator       - l_actual_denominator;
		   l_u3_tbl(l_Top_Org_Index).prior_actual_hours        :=  l_u3_tbl(l_Top_Org_Index).prior_actual_hours       - l_prior_actual_hours;
		   l_u3_tbl(l_Top_Org_Index).prior_capacity_hours      :=  l_u3_tbl(l_Top_Org_Index).prior_capacity_hours     - l_prior_capacity_hours;
		   l_u3_tbl(l_Top_Org_Index).prior_utilization_hours   :=  l_u3_tbl(l_Top_Org_Index).prior_utilization_hours  - l_prior_utilization_hours;
		   l_u3_tbl(l_Top_Org_Index).prior_billable_hours      :=  l_u3_tbl(l_Top_Org_Index).prior_billable_hours     - l_prior_billable_hours;
		   l_u3_tbl(l_Top_Org_Index).prior_nonbillable_hours   :=  l_u3_tbl(l_Top_Org_Index).prior_nonbillable_hours  - l_prior_nonbillable_hours;
		   l_u3_tbl(l_Top_Org_Index).prior_training_hours      :=  l_u3_tbl(l_Top_Org_Index).prior_training_hours     - l_prior_training_hours;
		   l_u3_tbl(l_Top_Org_Index).prior_actual_denominator  :=  l_u3_tbl(l_Top_Org_Index).prior_actual_denominator - l_prior_actual_denominator;

           --Calculated columns processing for Top Org
           IF nvl(l_u3_tbl(l_Top_Org_Index).actual_denominator,0) <> 0 THEN
             l_u3_tbl(l_Top_Org_Index).util_percent := 100 * (l_u3_tbl(l_Top_Org_Index).utilization_hours / l_u3_tbl(l_Top_Org_Index).actual_denominator);
             l_u3_tbl(l_Top_Org_Index).bill_percent := 100 * (l_u3_tbl(l_Top_Org_Index).billable_hours / l_u3_tbl(l_Top_Org_Index).actual_denominator);
             l_u3_tbl(l_Top_Org_Index).non_bill_percent := 100 * (l_u3_tbl(l_Top_Org_Index).nonbillable_hours / l_u3_tbl(l_Top_Org_Index).actual_denominator);
             l_u3_tbl(l_Top_Org_Index).training_percent := 100 * (l_u3_tbl(l_Top_Org_Index).training_hours / l_u3_tbl(l_Top_Org_Index).actual_denominator);
           ELSE
             l_u3_tbl(l_Top_Org_Index).util_percent := NULL;
             l_u3_tbl(l_Top_Org_Index).bill_percent := NULL;
             l_u3_tbl(l_Top_Org_Index).non_bill_percent := NULL;
             l_u3_tbl(l_Top_Org_Index).training_percent := NULL;
           END IF;

           IF nvl(l_u3_tbl(l_Top_Org_Index).prior_actual_denominator,0) <> 0 THEN
             l_u3_tbl(l_Top_Org_Index).prior_util_percent := 100 * (l_u3_tbl(l_Top_Org_Index).prior_utilization_hours / l_u3_tbl(l_Top_Org_Index).prior_actual_denominator);
             l_u3_tbl(l_Top_Org_Index).prior_bill_percent := 100 * (l_u3_tbl(l_Top_Org_Index).prior_billable_hours / l_u3_tbl(l_Top_Org_Index).prior_actual_denominator);
             l_u3_tbl(l_Top_Org_Index).prior_non_bill_percent := 100 * (l_u3_tbl(l_Top_Org_Index).prior_nonbillable_hours / l_u3_tbl(l_Top_Org_Index).prior_actual_denominator);
             l_u3_tbl(l_Top_Org_Index).prior_training_percent := 100 * (l_u3_tbl(l_Top_Org_Index).prior_training_hours / l_u3_tbl(l_Top_Org_Index).prior_actual_denominator);
           ELSE
             l_u3_tbl(l_Top_Org_Index).prior_util_percent := NULL;
             l_u3_tbl(l_Top_Org_Index).prior_bill_percent := NULL;
             l_u3_tbl(l_Top_Org_Index).prior_non_bill_percent := NULL;
             l_u3_tbl(l_Top_Org_Index).prior_training_percent := NULL;
           END IF;

       END IF; --end p_view_by


   --Update local variables to include top level org values in grand totals
   IF l_Top_Org_Index is not null THEN

      l_actual_hours                  := l_actual_hours             + nvl(l_u3_tbl(l_Top_Org_Index).actual_hours,0);
      l_capacity_hours          	  := l_capacity_hours          	+ nvl(l_u3_tbl(l_Top_Org_Index).capacity_hours,0);
      l_missing_hours           	  := l_missing_hours           	+ nvl(l_u3_tbl(l_Top_Org_Index).missing_hours,0);
      l_utilization_hours       	  := l_utilization_hours       	+ nvl(l_u3_tbl(l_Top_Org_Index).utilization_hours,0);
      l_billable_hours          	  := l_billable_hours          	+ nvl(l_u3_tbl(l_Top_Org_Index).billable_hours,0);
      l_nonbillable_hours       	  := l_nonbillable_hours       	+ nvl(l_u3_tbl(l_Top_Org_Index).nonbillable_hours,0);
      l_training_hours          	  := l_training_hours          	+ nvl(l_u3_tbl(l_Top_Org_Index).training_hours,0);
      l_actual_denominator      	  := l_actual_denominator      	+ nvl(l_u3_tbl(l_Top_Org_Index).actual_denominator,0);
      l_prior_actual_hours      	  := l_prior_actual_hours      	+ nvl(l_u3_tbl(l_Top_Org_Index).prior_actual_hours,0);
      l_prior_capacity_hours    	  := l_prior_capacity_hours    	+ nvl(l_u3_tbl(l_Top_Org_Index).prior_capacity_hours,0);
      l_prior_utilization_hours 	  := l_prior_utilization_hours 	+ nvl(l_u3_tbl(l_Top_Org_Index).prior_utilization_hours,0);
      l_prior_billable_hours    	  := l_prior_billable_hours    	+ nvl(l_u3_tbl(l_Top_Org_Index).prior_billable_hours,0);
      l_prior_nonbillable_hours 	  := l_prior_nonbillable_hours 	+ nvl(l_u3_tbl(l_Top_Org_Index).prior_nonbillable_hours,0);
      l_prior_training_hours    	  := l_prior_training_hours    	+ nvl(l_u3_tbl(l_Top_Org_Index).prior_training_hours,0);
      l_prior_actual_denominator      := l_prior_actual_denominator	+ nvl(l_u3_tbl(l_Top_Org_Index).prior_actual_denominator,0);

   END IF;

   IF l_u3_tbl.COUNT > 0 THEN
   FOR i IN 1..l_u3_tbl.COUNT
	LOOP

      IF l_u3_tbl.EXISTS(i) THEN

        --Capacity is denormalized when context is view by UC or WT
        IF p_view_by = 'UC' OR p_view_by = 'WT' THEN

          /*Bug 2836444*/

          l_actual_denominator := l_u3_tbl(i).ACTUAL_DENOMINATOR;
          l_prior_actual_denominator := l_u3_tbl(i).PRIOR_ACTUAL_DENOMINATOR;

          /*Bug 2836477*/

          l_capacity_hours    := null;
          l_missing_hours     := null;
          l_prior_capacity_hours := null;

        END IF;

        l_u3_tbl(i).PJI_REP_TOTAL_1 := l_actual_hours;
        l_u3_tbl(i).PJI_REP_TOTAL_2 := l_capacity_hours;
        l_u3_tbl(i).PJI_REP_TOTAL_3 := l_missing_hours;
        l_u3_tbl(i).PJI_REP_TOTAL_4 := l_utilization_hours;
        l_u3_tbl(i).PJI_REP_TOTAL_5 := l_prior_actual_hours;
        l_u3_tbl(i).PJI_REP_TOTAL_6 := l_prior_capacity_hours;

        IF NVL(l_actual_denominator,0) <> 0 THEN

          l_u3_tbl(i).PJI_REP_TOTAL_7      := (l_utilization_hours/l_actual_denominator)*100;
          l_u3_tbl(i).PJI_REP_TOTAL_8      := (l_billable_hours/l_actual_denominator)*100;
          l_u3_tbl(i).PJI_REP_TOTAL_9      := (l_nonbillable_hours/l_actual_denominator)*100;
          l_u3_tbl(i).PJI_REP_TOTAL_10     := (l_training_hours/l_actual_denominator)*100;

        END IF;

        IF NVL(l_prior_actual_denominator,0) <> 0 THEN

          l_u3_tbl(i).PJI_REP_TOTAL_11      := (l_prior_utilization_hours/l_prior_actual_denominator)*100;
          l_u3_tbl(i).PJI_REP_TOTAL_12      := (l_prior_billable_hours/l_prior_actual_denominator)*100;
          l_u3_tbl(i).PJI_REP_TOTAL_13      := (l_prior_nonbillable_hours/l_prior_actual_denominator)*100;
          l_u3_tbl(i).PJI_REP_TOTAL_14      := (l_prior_training_hours/l_prior_actual_denominator)*100;

        END IF;

      END IF; -- l_u3_tbl.EXISTS(i)
	END LOOP;
    END IF; --l_u3_tbl.COUNT > 0


    --Delete record for top org if all values are 0 or null
   IF l_Top_Org_Index is not null THEN
      IF  nvl(l_u3_tbl(l_Top_Org_Index).ACTUAL_HOURS,0) = 0 AND
		nvl(l_u3_tbl(l_Top_Org_Index).CAPACITY_HOURS,0) = 0 AND
		nvl(l_u3_tbl(l_Top_Org_Index).MISSING_HOURS,0) = 0 AND
		nvl(l_u3_tbl(l_Top_Org_Index).UTILIZATION_HOURS,0) = 0 AND
		nvl(l_u3_tbl(l_Top_Org_Index).PRIOR_ACTUAL_HOURS,0) = 0 AND
		nvl(l_u3_tbl(l_Top_Org_Index).PRIOR_CAPACITY_HOURS,0) = 0 AND
		nvl(l_u3_tbl(l_Top_Org_Index).UTIL_PERCENT,0) = 0 AND
		nvl(l_u3_tbl(l_Top_Org_Index).BILL_PERCENT,0) = 0 AND
		nvl(l_u3_tbl(l_Top_Org_Index).NON_BILL_PERCENT,0) = 0 AND
		nvl(l_u3_tbl(l_Top_Org_Index).TRAINING_PERCENT,0) = 0 AND
		nvl(l_u3_tbl(l_Top_Org_Index).PRIOR_UTIL_PERCENT,0) = 0 AND
		nvl(l_u3_tbl(l_Top_Org_Index).PRIOR_BILL_PERCENT,0) = 0 AND
		nvl(l_u3_tbl(l_Top_Org_Index).PRIOR_NON_BILL_PERCENT,0) = 0 AND
		nvl(l_u3_tbl(l_Top_Org_Index).PRIOR_TRAINING_PERCENT,0) = 0
      THEN
       l_u3_tbl.DELETE(l_Top_Org_Index);
      END IF;
   END IF;


   COMMIT;
   RETURN l_u3_tbl;

END PLSQLDriver_U3;

FUNCTION PLSQLDriver_U4 (
   p_operating_unit        IN VARCHAR2 DEFAULT NULL,
   p_organization          IN VARCHAR2,
   p_as_of_date            IN NUMBER,
   p_period_type           IN VARCHAR2,
   p_view_by               IN VARCHAR2,
   p_utilization_category  IN VARCHAR2 DEFAULT NULL,
   p_work_type             IN VARCHAR2 DEFAULT NULL,
   p_job_level             IN VARCHAR2 DEFAULT NULL,
   p_flag                  IN VARCHAR2
)  RETURN PJI_REP_U4_TBL
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   l_u4_tbl                           PJI_REP_U4_TBL:=PJI_REP_U4_TBL();
   l_util_category_flag               VARCHAR2(1);
   l_job_flag                         VARCHAR2(1);
   l_denominator                      VARCHAR2(25);
   l_labor_unit                       VARCHAR2(40);
   l_scheduled_hours                  NUMBER := 0;
   l_scheduled_capacity_hours         NUMBER := 0;
   l_scheduled_util_hours             NUMBER := 0;
   l_provisional_hours                NUMBER := 0;
   l_unassigned_hours                 NUMBER := 0;
   l_conf_billable_hours              NUMBER := 0;
   l_conf_nonbillable_hours           NUMBER := 0;
   l_prov_billable_hours              NUMBER := 0;
   l_prov_nonbillable_hours           NUMBER := 0;
   l_training_hours                   NUMBER := 0;
   l_expected_hours                   NUMBER := 0;
   l_expected_util_hours              NUMBER := 0;
   l_expected_total_util_hours        NUMBER := 0;
   l_actual_util_hours                NUMBER := 0;
   l_actual_capacity_hours            NUMBER := 0;
   l_expected_capacity_hours          NUMBER := 0;
   l_prov_util_hours                  NUMBER := 0;
   l_exp_ac_util_hours                NUMBER := 0;
   l_exp_sch_util_hours               NUMBER := 0;
   l_exp_ac_denominator               NUMBER := 0;
   l_exp_sch_denominator              NUMBER := 0;
   l_actual_denominator               NUMBER := 0;
   l_scheduled_denominator            NUMBER := 0;
   l_expected_denominator             NUMBER := 0;
   l_prior_scheduled_hours            NUMBER := 0;
   l_prior_sch_capacity_hours         NUMBER := 0;
   l_prior_sch_util_hours             NUMBER := 0;
   l_prior_conf_billable_hours        NUMBER := 0;
   l_prior_conf_nonbillable_hours     NUMBER := 0;
   l_prior_actual_capacity_hours      NUMBER := 0;
   l_prior_actual_util_hours          NUMBER := 0;
   l_prior_actual_denominator         NUMBER := 0;
   l_prior_scheduled_denominator      NUMBER := 0;
   l_Top_Org_Index                    NUMBER;
   l_Top_Organization_Name            VARCHAR2(240);
BEGIN
   PJI_PMV_ENGINE.Convert_Operating_Unit (p_operating_unit, p_view_by);
   IF (p_flag = 'FALSE') THEN
      PJI_PMV_ENGINE.Convert_Time (p_as_of_date, p_period_type, p_view_by, 'Y');
   ELSE PJI_PMV_ENGINE.Convert_Expected_Time (p_as_of_date, p_period_type, 'Y');
   END IF;

   l_util_category_flag := PJI_PMV_ENGINE.Convert_Util_Category(p_work_type, p_utilization_category, p_view_by);
   l_job_flag := PJI_PMV_ENGINE.Convert_Job_Level(null, p_job_level, p_view_by);

   /*
   * Get Utilization percentage denominator profile value
   */
   BEGIN
     SELECT fnd_profile.value('PA_ORG_UTIL_DEF_CALC_METHOD')
     INTO l_denominator
     from dual;

     EXCEPTION WHEN NO_DATA_FOUND THEN
         l_denominator := 'CAPACITY';
   END;

   /*
    * Get report labor unit
    */
   BEGIN
     select report_labor_units
     into l_labor_unit
     from pji_system_settings;

   EXCEPTION WHEN OTHERS THEN
         l_labor_unit := null;
   END;

   IF l_util_category_flag = 'N' AND l_job_flag = 'N' THEN

      PJI_PMV_ENGINE.Convert_Organization(P_TOP_ORGANIZATION_ID   => p_Organization
                                        , P_VIEW_BY               => p_view_by
                                        , P_TOP_ORGANIZATION_NAME => l_Top_Organization_Name );

      SELECT PJI_REP_U4(org_id,
                        organization_id,
                        time_id,
                        time_key,
                        util_category_id,
                        work_type_id,
                        job_level_id,
                        sum(scheduled_hours),
                        sum(scheduled_capacity_hours),
                        sum(scheduled_util_hours),
                        sum(provisional_hours),
                        sum(unassigned_hours),
                        sum(conf_billable_hours),
                        sum(conf_nonbillable_hours),
                        sum(prov_billable_hours),
                        sum(prov_nonbillable_hours),
                        sum(training_hours),
                        sum(expected_hours),
                        sum(expected_util_hours),
                        sum(expected_total_util_hours),
                        sum(actual_util_hours),
                        sum(actual_capacity_hours),
                        sum(expected_capacity_hours),
                        sum(prov_util_hours),
                        sum(exp_ac_util_hours),
                        sum(exp_sch_util_hours),
                        sum(decode(l_denominator, 'CAPACITY', exp_ac_capacity_hours, exp_ac_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', exp_sch_capacity_hours, exp_sch_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', actual_capacity_hours, actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', scheduled_capacity_hours, actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', expected_capacity_hours, actual_hours)),
                        sum(prior_scheduled_hours),
                        sum(prior_sch_capacity_hours),
                        sum(prior_sch_util_hours),
                        sum(prior_conf_billable_hours),
                        sum(prior_conf_nonbillable_hours),
                        sum(prior_actual_capacity_hours),
                        sum(prior_actual_util_hours),
                        sum(decode(l_denominator, 'CAPACITY', prior_actual_capacity_hours, prior_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', prior_sch_capacity_hours, prior_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null
                        )
      /* Bug 3515594 */
      BULK COLLECT INTO l_u4_tbl
      FROM (
           SELECT /*+ ORDERED */
                  hou.name                                       org_id,
                  horg.name                                      organization_id,
                  time.name                                      time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)           time_key,
                  '-1'                                           util_category_id,
                  '-1'                                           work_type_id,
                  '-1'                                           job_level_id,
                  conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 scheduled_hours,
                  (capacity_hrs - reduce_capacity_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 scheduled_capacity_hours,
                  conf_wtd_org_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 scheduled_util_hours,
                  prov_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 provisional_hours,
                  unassigned_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 unassigned_hours,
                  conf_bill_wtd_org_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 conf_billable_hours,
                  (conf_wtd_org_hrs_s - conf_bill_wtd_org_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 conf_nonbillable_hours,
                  prov_wtd_org_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prov_billable_hours,
                  (prov_wtd_org_hrs_s - prov_bill_wtd_org_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prov_nonbillable_hours,
                  training_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 training_hours,
                  decode(time.amount_type, 0, total_hrs_a, conf_hrs_s)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 expected_hours,
                  decode(time.amount_type, 0, total_wtd_org_hrs_a, conf_wtd_org_hrs_s)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 expected_util_hours,
                  decode(time.amount_type, 0, total_wtd_org_hrs_a, conf_wtd_org_hrs_s + prov_wtd_org_hrs_s)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 expected_total_util_hours,
                  decode(time.amount_type, 0, capacity_hrs-reduce_capacity_hrs_a,
                                              capacity_hrs-reduce_capacity_hrs_s)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 expected_capacity_hours,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                actual_hours,
                  total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 actual_util_hours,
                  (capacity_hrs - reduce_capacity_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 actual_capacity_hours,
                  decode(time.amount_type, 0, 0, prov_wtd_org_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prov_util_hours,
                  decode(time.amount_type, 0, total_wtd_org_hrs_a, 0) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_ac_util_hours,
                  decode(time.amount_type, 0, 0, conf_wtd_org_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_sch_util_hours,
                  decode(time.amount_type, 0, total_hrs_a, 0) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_ac_actual_hours,
                  decode(time.amount_type, 0, 0, total_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_sch_actual_hours,
                  decode(time.amount_type, 0, capacity_hrs - reduce_capacity_hrs_a, capacity_hrs)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_ac_capacity_hours,
                  decode(time.amount_type, 0, capacity_hrs, capacity_hrs - reduce_capacity_hrs_s)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_sch_capacity_hours,
                  0                                              prior_scheduled_hours,
                  0                                              prior_sch_capacity_hours,
                  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_capacity_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_RM_ORGO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.id is not null
             AND hou.id = imp.org_id
           UNION ALL
	   /* Bug 3515594 */
           SELECT /*+ ORDERED */
                  hou.name                                       org_id,
                  horg.name                                      organization_id,
                  time.name                                      time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)           time_key,
                  '-1'                                           util_category_id,
                  '-1'                                           work_type_id,
                  '-1'                                           job_level_id,
                  0                                              scheduled_hours,
                  0                                              scheduled_capacity_hours,
                  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              expected_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              actual_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              exp_ac_capacity_hours,
                  0                                              exp_sch_capacity_hours,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_scheduled_hours,
                  (capacity_hrs - reduce_capacity_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_sch_capacity_hours,
                  total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_sch_util_hours,
                  bill_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_conf_billable_hours,
                  (total_wtd_org_hrs_a - bill_wtd_org_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_conf_nonbillable_hours,
                  (capacity_hrs - reduce_capacity_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_actual_capacity_hours,
                  total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_actual_util_hours,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_actual_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_RM_ORGO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.time_id = time.prior_id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.prior_id is not null
             AND hou.id = imp.org_id
           UNION ALL
           SELECT '-1'                                           org_id,
                  name                                           organization_id,
                  '-1'                                           time_id,
                  -1                                             time_key,
                  '-1'                                           util_category_id,
                  '-1'                                           work_type_id,
                  '-1'                                           job_level_id,
                  0                                              scheduled_hours,
                  0                                              scheduled_capacity_hours,
                  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              expected_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              actual_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              exp_ac_capacity_hours,
                  0                                              exp_sch_capacity_hours,
                  0                                              prior_scheduled_hours,
                  0                                              prior_sch_capacity_hours,
                  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_capacity_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_ORGZ_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                           org_id,
                  '-1'                                           organization_id,
                  name                                           time_id,
                  order_by_id                                    time_key,
                  '-1'                                           util_category_id,
                  '-1'                                           work_type_id,
                  '-1'                                           job_level_id,
                  0                                              scheduled_hours,
                  0                                              scheduled_capacity_hours,
                  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              expected_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              actual_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              exp_ac_capacity_hours,
                  0                                              exp_sch_capacity_hours,
                  0                                              prior_scheduled_hours,
                  0                                              prior_sch_capacity_hours,
                  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_capacity_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_TIME_DIM_TMP
           WHERE name <> '-1'
           )
           GROUP BY org_id,
		     organization_id,
		     time_id,
		     time_key,
		     util_category_id,
             work_type_id,
		     job_level_id;

   ELSIF l_job_flag = 'N' THEN

      PJI_PMV_ENGINE.Convert_Organization(P_TOP_ORGANIZATION_ID   => p_Organization
                                        , P_VIEW_BY               => p_view_by
                                        , P_TOP_ORGANIZATION_NAME => l_Top_Organization_Name );

      SELECT PJI_REP_U4(org_id,
                        organization_id,
                        time_id,
                        time_key,
                        util_category_id,
                        work_type_id,
                        job_level_id,
                        sum(scheduled_hours),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, capacity_hours-sch_reduce_capacity_hours)),
                        sum(scheduled_util_hours),
                        sum(provisional_hours),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, unassigned_hours)),
                        sum(conf_billable_hours),
                        sum(conf_nonbillable_hours),
                        sum(prov_billable_hours),
                        sum(prov_nonbillable_hours),
                        sum(training_hours),
                        sum(expected_hours),
                        sum(expected_util_hours),
                        sum(expected_total_util_hours),
                        sum(actual_util_hours),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, capacity_hours-act_reduce_capacity_hours)),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, capacity_hours-exp_reduce_capacity_hours)),
                        sum(prov_util_hours),
                        sum(exp_ac_util_hours),
                        sum(exp_sch_util_hours),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-exp_ac_red_capacity_hours,
                            exp_ac_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-exp_sch_red_capacity_hours,
                            exp_ac_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-act_reduce_capacity_hours, total_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-sch_reduce_capacity_hours, total_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-exp_reduce_capacity_hours, total_actual_hours)),
                        sum(prior_scheduled_hours),
                        sum(prior_capacity_hours-prior_red_capacity_hours),
                        sum(prior_sch_util_hours),
                        sum(prior_conf_billable_hours),
                        sum(prior_conf_nonbillable_hours),
                        sum(prior_capacity_hours-prior_red_capacity_hours),
                        sum(prior_actual_util_hours),
                        sum(decode(l_denominator, 'CAPACITY', prior_capacity_hours-prior_red_capacity_hours,
                            prior_total_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', prior_capacity_hours-prior_red_capacity_hours,
                            prior_total_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null
                        )
      BULK COLLECT INTO l_u4_tbl
      /* Bug 3515594 */
      FROM (
           SELECT /*+ ORDERED */
                  hou.name                                       org_id,
                  horg.name                                      organization_id,
                  time.name                                      time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)           time_key,
                  decode(p_view_by, 'UC', wt.name, '-1')         util_category_id,
                  decode(p_view_by, 'WT', wt.name, '-1')         work_type_id,
                  '-1'                                           job_level_id,
                  conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 scheduled_hours,
                  0                                              capacity_hours,
                  0                                              sch_reduce_capacity_hours,
		  0						 total_actual_hours,
                  (fct.conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                                 scheduled_util_hours,
                  prov_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 provisional_hours,
                  unassigned_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 unassigned_hours,
                  (CASE WHEN worktype.billable_capitalizable_flag = 'Y' THEN
                  fct.conf_hrs_s * worktype.org_utilization_percentage / 100
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 conf_billable_hours,
                  (CASE WHEN worktype.billable_capitalizable_flag = 'N' THEN
                  fct.conf_hrs_s * worktype.org_utilization_percentage / 100
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 conf_nonbillable_hours,
                  (CASE WHEN worktype.billable_capitalizable_flag = 'Y' THEN
                  fct.prov_hrs_s * worktype.org_utilization_percentage / 100
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prov_billable_hours,
                  (CASE WHEN worktype.billable_capitalizable_flag = 'N' THEN
                  fct.prov_hrs_s * worktype.org_utilization_percentage / 100
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prov_nonbillable_hours,
                  (CASE WHEN worktype.training_flag = 'Y' THEN
                  fct.conf_hrs_s
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 training_hours,
                  decode(time.amount_type, 0, fct.total_hrs_a, fct.conf_hrs_s)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 expected_hours,
                  (decode(time.amount_type, 0, fct.total_hrs_a, fct.conf_hrs_s) * worktype.org_utilization_percentage / 100)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 expected_util_hours,
                  (decode(time.amount_type, 0, fct.total_hrs_a, fct.conf_hrs_s + fct.prov_hrs_s)
                  * worktype.org_utilization_percentage / 100) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 expected_total_util_hours,
                  0                                              exp_reduce_capacity_hours,
                  fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 actual_hours,
                  (fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                                 actual_util_hours,
                  0                                              act_reduce_capacity_hours,
                  (decode(time.amount_type, 0, 0, fct.prov_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                                 prov_util_hours,
                  (decode(time.amount_type, 0, fct.total_hrs_a, 0) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                                 exp_ac_util_hours,
                  (decode(time.amount_type, 0, 0, fct.conf_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                                 exp_sch_util_hours,
                  decode(time.amount_type, 0, fct.total_hrs_a, 0) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_ac_actual_hours,
                  decode(time.amount_type, 0, 0, fct.total_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_sch_actual_hours,
                  0                                              exp_ac_red_capacity_hours,
                  0                                              exp_sch_red_capacity_hours,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_red_capacity_hours,
		  0						 prior_total_actual_hours,
		  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_WT_DIM_TMP wt,
                PJI_RM_WTO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_WORK_TYPES_B worktype,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.work_type_id = wt.id
             AND wt.id = worktype.work_type_id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.id is not null
             AND hou.id = imp.org_id
           UNION ALL
	   /* Bug 3515594 */
           SELECT /*+ ORDERED */
                  hou.name                                       org_id,
                  horg.name                                      organization_id,
                  time.name                                      time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)           time_key,
                  decode(p_view_by, 'UC', wt.name, '-1')         util_category_id,
                  decode(p_view_by, 'WT', wt.name, '-1')         work_type_id,
                  '-1'                                           job_level_id,
                  0                                              scheduled_hours,
                  0                                              capacity_hours,
                  0                                              sch_reduce_capacity_hours,
		  0						 total_actual_hours,
                  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              exp_reduce_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              act_reduce_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              exp_ac_red_capacity_hours,
                  0                                              exp_sch_red_capacity_hours,
                  fct.total_hrs_a * decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_red_capacity_hours,
		  0						 prior_total_actual_hours,
		  fct.total_hrs_a * decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1) *
                  worktype.org_utilization_percentage / 100      prior_sch_util_hours,
                  (CASE WHEN worktype.billable_capitalizable_flag = 'Y' THEN
                  fct.total_hrs_a * worktype.org_utilization_percentage / 100
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_conf_billable_hours,
                  (CASE WHEN worktype.billable_capitalizable_flag = 'N' THEN
                  fct.total_hrs_a * worktype.org_utilization_percentage / 100
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_conf_nonbillable_hours,
                  fct.total_hrs_a * decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1) *
                  worktype.org_utilization_percentage / 100      prior_actual_util_hours,
                  fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_actual_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_WT_DIM_TMP wt,
                PJI_RM_WTO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_WORK_TYPES_B worktype,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.work_type_id = wt.id
             AND wt.id = worktype.work_type_id
             AND fct.time_id = time.prior_id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.prior_id is not null
             AND hou.id = imp.org_id
           UNION ALL
           SELECT '-1'                                           org_id,
                  name                                           organization_id,
                  '-1'                                           time_id,
                  -1                                             time_key,
                  '-1'                                           util_category_id,
                  '-1'                                           work_type_id,
                  '-1'                                           job_level_id,
                  0                                              scheduled_hours,
                  0                                              capacity_hours,
                  0                                              sch_reduce_capacity_hours,
		  0						 total_actual_hours,
		  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              exp_reduce_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              act_reduce_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              exp_ac_red_capacity_hours,
                  0                                              exp_sch_red_capacity_hours,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_red_capacity_hours,
		  0						 prior_total_actual_hours,
                  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_ORGZ_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                           org_id,
                  '-1'                                           organization_id,
                  '-1'                                           time_id,
                  -1                                             time_key,
                  decode(p_view_by, 'UC', name, '-1')            util_category_id,
                  decode(p_view_by, 'WT', name, '-1')            work_type_id,
                  '-1'                                           job_level_id,
                  0                                              scheduled_hours,
                  0                                              capacity_hours,
                  0                                              sch_reduce_capacity_hours,
		  0						 total_actual_hours,
		  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              exp_reduce_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              act_reduce_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              exp_ac_red_capacity_hours,
                  0                                              exp_sch_red_capacity_hours,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_red_capacity_hours,
		  0						 prior_total_actual_hours,
		  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_WT_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                           org_id,
                  '-1'                                           organization_id,
                  name                                           time_id,
                  order_by_id                                    time_key,
                  '-1'                                           util_category_id,
                  '-1'                                           work_type_id,
                  '-1'                                           job_level_id,
                  0                                              scheduled_hours,
                  0                                              capacity_hours,
                  0                                              sch_reduce_capacity_hours,
		  0						 total_actual_hours,
		  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              exp_reduce_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              act_reduce_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              exp_ac_red_capacity_hours,
                  0                                              exp_sch_red_capacity_hours,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_red_capacity_hours,
		  0						 prior_total_actual_hours,
		  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_TIME_DIM_TMP
           WHERE name <> '-1'
           UNION ALL   -- added for current year capacity_hours
           SELECT
                  FACT.org_id,
                  FACT.organization_id,
                  FACT.time_id,
                  FACT.time_key,
                  decode(p_view_by, 'UC', WT.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', WT.name, '-1')  work_type_id,
                  '-1'                                    job_level_id,
                  0                                       scheduled_hours,
                  FACT.capacity_hours,
                  FACT.sch_reduce_capacity_hours                 sch_reduce_capacity_hours,
		  FACT.total_actual_hours			 total_actual_hours,
		  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  FACT.exp_reduce_capacity_hours                 exp_reduce_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  FACT.act_reduce_capacity_hours                 act_reduce_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  FACT.exp_ac_red_capacity_hours                 exp_ac_red_capacity_hours,
                  FACT.exp_sch_red_capacity_hours                exp_sch_red_capacity_hours,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_red_capacity_hours,
		  0						 prior_total_actual_hours,
		  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM
	   /* Bug 3515594 */
            (SELECT /*+ ORDERED */
                     hou.name                                org_id,
                     horg.name                               organization_id,
                     time.name                               time_id,
                     DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                     fct.capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          capacity_hours,
                     fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          total_actual_hours,

		     fct.reduce_capacity_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          sch_reduce_capacity_hours,
                     decode(time.amount_type, 0, fct.reduce_capacity_hrs_a, fct.reduce_capacity_hrs_s)
                                               / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          exp_reduce_capacity_hours,
                     fct.reduce_capacity_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          act_reduce_capacity_hours,
                     decode(time.amount_type, 0, fct.reduce_capacity_hrs_a, 0)
                                               / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          exp_ac_red_capacity_hours,
                     decode(time.amount_type, 1, fct.reduce_capacity_hrs_s, 0)
                                               / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          exp_sch_red_capacity_hours
             FROM PJI_PMV_ORGZ_DIM_TMP horg,
                  PJI_PMV_TIME_DIM_TMP time,
                  PJI_RM_ORGO_F_MV fct,
                  PJI_PMV_ORG_DIM_TMP hou,
                  PA_IMPLEMENTATIONS_ALL imp
             WHERE fct.expenditure_org_id = hou.id
             AND   fct.expenditure_organization_id = horg.id
             AND   fct.time_id = time.id
             AND   fct.period_type_id = time.period_type
             AND   fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND   time.id is not null
             AND   hou.id = imp.org_id )         FACT,
             (SELECT distinct WT.name
              FROM   PJI_PMV_WT_DIM_TMP wt )     WT
           UNION ALL   -- added for prior year capacity_hours
           SELECT
                  FACT.org_id,
                  FACT.organization_id,
                  FACT.time_id,
                  FACT.time_key,
                  decode(p_view_by, 'UC', WT.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', WT.name, '-1')  work_type_id,
                  '-1'                                    job_level_id,
                  0                                       scheduled_hours,
                  0                                       capacity_hours,
                  0                                              sch_reduce_capacity_hours,
		  0						 total_actual_hours,
		  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              exp_reduce_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              act_reduce_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              exp_ac_red_capacity_hours,
                  0                                              exp_sch_red_capacity_hours,
                  0                                              prior_scheduled_hours,
                  FACT.capacity_hours                            prior_capacity_hours,
                  FACT.prior_red_capacity_hours                  prior_red_capacity_hours,
		  FACT.total_actual_hours			 prior_total_actual_hours,
                  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM
            (SELECT /*+ ORDERED */
                     hou.name                                org_id,
                     horg.name                               organization_id,
                     time.name                               time_id,
                     DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                     fct.capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          capacity_hours,
                     fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          total_actual_hours,
		     fct.reduce_capacity_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_red_capacity_hours
             FROM PJI_PMV_ORGZ_DIM_TMP horg,
                  PJI_PMV_TIME_DIM_TMP time,
                  PJI_RM_ORGO_F_MV fct,
                  PJI_PMV_ORG_DIM_TMP hou,
                  PA_IMPLEMENTATIONS_ALL imp
             WHERE fct.expenditure_org_id = hou.id
             AND   fct.expenditure_organization_id = horg.id
             AND   fct.time_id = time.prior_id
             AND   fct.period_type_id = time.period_type
             AND   fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND   time.prior_id is not null
             AND   hou.id = imp.org_id )         FACT,
             (SELECT distinct WT.name
              FROM   PJI_PMV_WT_DIM_TMP wt )     WT
           )
           GROUP BY org_id,
		     organization_id,
		     time_id,
		     time_key,
		     util_category_id,
                     work_type_id,
		     job_level_id;

   ELSIF l_util_category_flag = 'N' THEN

      PJI_PMV_ENGINE.Convert_Organization(P_TOP_ORGANIZATION_ID   => p_Organization
                                        , P_VIEW_BY               => p_view_by
                                        , P_TOP_ORGANIZATION_NAME => l_Top_Organization_Name );

      SELECT PJI_REP_U4(org_id,
                        organization_id,
                        time_id,
                        time_key,
                        util_category_id,
                        work_type_id,
                        job_level_id,
                        sum(scheduled_hours),
                        sum(capacity_hours - reduce_capacity_hrs_s),
                        sum(scheduled_util_hours),
                        sum(provisional_hours),
                        sum(unassigned_hours),
                        sum(conf_billable_hours),
                        sum(conf_nonbillable_hours),
                        sum(prov_billable_hours),
                        sum(prov_nonbillable_hours),
                        sum(training_hours),
                        sum(expected_hours),
                        sum(expected_util_hours),
                        sum(expected_total_util_hours),
                        sum(actual_util_hours),
                        sum(capacity_hours - reduce_capacity_hrs_a),
                        sum(capacity_hours - reduce_capacity_hrs_e),
                        sum(prov_util_hours),
                        sum(exp_ac_util_hours),
                        sum(exp_sch_util_hours),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours - exp_ac_reduce_capacity_hours, exp_ac_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours - exp_sch_reduce_capacity_hours, exp_sch_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours - reduce_capacity_hrs_a, actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours - reduce_capacity_hrs_s, actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours - reduce_capacity_hrs_e, actual_hours)),
                        sum(prior_scheduled_hours),
                        sum(prior_capacity_hours - prior_reduce_capacity_hrs_a),
                        sum(prior_sch_util_hours),
                        sum(prior_conf_billable_hours),
                        sum(prior_conf_nonbillable_hours),
                        sum(prior_capacity_hours - prior_reduce_capacity_hrs_a),
                        sum(prior_actual_util_hours),
                        sum(decode(l_denominator, 'CAPACITY', prior_capacity_hours - prior_reduce_capacity_hrs_a, prior_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', prior_capacity_hours - prior_reduce_capacity_hrs_a, prior_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null
                        )
      /* Bug 3515594 */
      BULK COLLECT INTO l_u4_tbl
      FROM (
           SELECT /*+ ORDERED */
                  hou.name                                       org_id,
                  horg.name                                      organization_id,
                  time.name                                      time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)           time_key,
                  '-1'                                           util_category_id,
                  '-1'                                           work_type_id,
                  job.name                                       job_level_id,
                  conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 scheduled_hours,
                  capacity_hrs                                   capacity_hours,
                  conf_wtd_org_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 scheduled_util_hours,
                  prov_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 provisional_hours,
                  unassigned_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 unassigned_hours,
                  conf_bill_wtd_org_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 conf_billable_hours,
                  (conf_wtd_org_hrs_s - conf_bill_wtd_org_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 conf_nonbillable_hours,
                  prov_wtd_org_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prov_billable_hours,
                  (prov_wtd_org_hrs_s - prov_bill_wtd_org_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prov_nonbillable_hours,
                  training_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 training_hours,
                  decode(time.amount_type, 0, total_hrs_a, conf_hrs_s)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 expected_hours,
                  decode(time.amount_type, 0, total_wtd_org_hrs_a, conf_wtd_org_hrs_s)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 expected_util_hours,
                  decode(time.amount_type, 0, total_wtd_org_hrs_a, conf_wtd_org_hrs_s + prov_wtd_org_hrs_s)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 expected_total_util_hours,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 actual_hours,
                  total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 actual_util_hours,
                  decode(time.amount_type, 0, 0, prov_wtd_org_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prov_util_hours,
                  decode(time.amount_type, 0, total_wtd_org_hrs_a, 0) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_ac_util_hours,
                  decode(time.amount_type, 0, 0, conf_wtd_org_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_sch_util_hours,
                  decode(time.amount_type, 0, total_hrs_a, 0) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_ac_actual_hours,
                  decode(time.amount_type, 0, 0, total_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_sch_actual_hours,
                  reduce_capacity_hrs_a
                       / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 reduce_capacity_hrs_a,
                  reduce_capacity_hrs_s
                       / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 reduce_capacity_hrs_s,
                  decode(time.amount_type, 0, reduce_capacity_hrs_a,
                                              reduce_capacity_hrs_s)
                       / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 reduce_capacity_hrs_e,
                  decode(time.amount_type, 0, reduce_capacity_hrs_a,
                                              0)
                       / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_ac_reduce_capacity_hours,
                  decode(time.amount_type, 1, reduce_capacity_hrs_s,
                                              0)
                       / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_sch_reduce_capacity_hours,
                  0                                              prior_reduce_capacity_hrs_a,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_JB_DIM_TMP job,
                PJI_RM_JOBO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.job_id = job.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.id is not null
             AND hou.id = imp.org_id
           UNION ALL
	   /* Bug 3515594 */
           SELECT /*+ ORDERED */
                  hou.name                                       org_id,
                  horg.name                                      organization_id,
                  time.name                                      time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)           time_key,
                  '-1'                                           util_category_id,
                  '-1'                                           work_type_id,
                  job.name                                       job_level_id,
                  0                                              scheduled_hours,
                  0                                              capacity_hours,
                  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              reduce_capacity_hrs_a,
                  0                                              reduce_capacity_hrs_s,
                  0                                              reduce_capacity_hrs_e,
                  0                                              exp_ac_reduce_capacity_hours,
                  0                                              exp_sch_reduce_capacity_hours,
                  reduce_capacity_hrs_a                          prior_reduce_capacity_hrs_a,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_scheduled_hours,
                  capacity_hrs                                   prior_capacity_hours,
                  total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_sch_util_hours,
                  bill_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_conf_billable_hours,
                  (total_wtd_org_hrs_a - bill_wtd_org_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_conf_nonbillable_hours,
                  total_wtd_org_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_actual_util_hours,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_actual_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_JB_DIM_TMP job,
                PJI_RM_JOBO_F_MV fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.job_id = job.id
             AND fct.time_id = time.prior_id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.prior_id is not null
             AND hou.id = imp.org_id
           UNION ALL
           SELECT '-1'                                           org_id,
                  name                                           organization_id,
                  '-1'                                           time_id,
                  -1                                             time_key,
                  '-1'                                           util_category_id,
                  '-1'                                           work_type_id,
                  '-1'                                           job_level_id,
                  0                                              scheduled_hours,
                  0                                              capacity_hours,
                  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              reduce_capacity_hrs_a,
                  0                                              reduce_capacity_hrs_s,
                  0                                              reduce_capacity_hrs_e,
                  0                                              exp_ac_reduce_capacity_hours,
                  0                                              exp_sch_reduce_capacity_hours,
                  0                                              prior_reduce_capacity_hrs_a,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_ORGZ_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                           org_id,
                  '-1'                                           organization_id,
                  '-1'                                           time_id,
                  -1                                             time_key,
                  '-1'                                           util_category_id,
                  '-1'                                           work_type_id,
                  name                                           job_level_id,
                  0                                              scheduled_hours,
                  0                                              capacity_hours,
                  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              reduce_capacity_hrs_a,
                  0                                              reduce_capacity_hrs_s,
                  0                                              reduce_capacity_hrs_e,
                  0                                              exp_ac_reduce_capacity_hours,
                  0                                              exp_sch_reduce_capacity_hours,
                  0                                              prior_reduce_capacity_hrs_a,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_JB_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                           org_id,
                  '-1'                                           organization_id,
                  name                                           time_id,
                  order_by_id                                    time_key,
                  '-1'                                           util_category_id,
                  '-1'                                           work_type_id,
                  '-1'                                           job_level_id,
                  0                                              scheduled_hours,
                  0                                              capacity_hours,
                  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              reduce_capacity_hrs_a,
                  0                                              reduce_capacity_hrs_s,
                  0                                              reduce_capacity_hrs_e,
                  0                                              exp_ac_reduce_capacity_hours,
                  0                                              exp_sch_reduce_capacity_hours,
                  0                                              prior_reduce_capacity_hrs_a,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_TIME_DIM_TMP
           WHERE name <> '-1'
           )
            GROUP BY org_id,
		     organization_id,
		     time_id,
		     time_key,
		     util_category_id,
                     work_type_id,
		     job_level_id;
   ELSE

      PJI_PMV_ENGINE.Convert_Organization(p_Organization, p_view_by);

      SELECT PJI_REP_U4(org_id,
                        organization_id,
                        time_id,
                        time_key,
                        util_category_id,
                        work_type_id,
                        job_level_id,
                        sum(scheduled_hours),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, capacity_hours-sch_reduce_capacity_hours)),
                        sum(scheduled_util_hours),
                        sum(provisional_hours),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, unassigned_hours)),
                        sum(conf_billable_hours),
                        sum(conf_nonbillable_hours),
                        sum(prov_billable_hours),
                        sum(prov_nonbillable_hours),
                        sum(training_hours),
                        sum(expected_hours),
                        sum(expected_util_hours),
                        sum(expected_total_util_hours),
                        sum(actual_util_hours),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, capacity_hours-act_reduce_capacity_hours)),
                        sum(decode (p_view_by, 'UC', null, 'WT',null, capacity_hours-exp_reduce_capacity_hours)),
                        sum(prov_util_hours),
                        sum(exp_ac_util_hours),
                        sum(exp_sch_util_hours),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-exp_ac_red_capacity_hours,
                            exp_ac_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-exp_sch_red_capacity_hours,
                            exp_ac_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-act_reduce_capacity_hours, total_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-sch_reduce_capacity_hours, total_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', capacity_hours-exp_reduce_capacity_hours, total_actual_hours)),
                        sum(prior_scheduled_hours),
                        sum(prior_capacity_hours-prior_red_capacity_hours),
                        sum(prior_sch_util_hours),
                        sum(prior_conf_billable_hours),
                        sum(prior_conf_nonbillable_hours),
                        sum(prior_capacity_hours-prior_red_capacity_hours),
                        sum(prior_actual_util_hours),
                        sum(decode(l_denominator, 'CAPACITY', prior_capacity_hours-prior_red_capacity_hours,
                            prior_total_actual_hours)),
                        sum(decode(l_denominator, 'CAPACITY', prior_capacity_hours-prior_red_capacity_hours,
                            prior_total_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null
                        )
      /* Bug 3515594 */
      BULK COLLECT INTO l_u4_tbl
      FROM (
           SELECT /*+ ORDERED */
                  hou.name                                       org_id,
                  horg.name                                      organization_id,
                  time.name                                      time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)           time_key,
                  decode(p_view_by, 'UC', wt.name, '-1')         util_category_id,
                  decode(p_view_by, 'WT', wt.name, '-1')         work_type_id,
                  job.name                                       job_level_id,
                  conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 scheduled_hours,
                  0                                              capacity_hours,
                  0                                              sch_reduce_capacity_hours,
		  0						 total_actual_hours,
                  (fct.conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100      scheduled_util_hours,
                  prov_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 provisional_hours,
                  unassigned_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 unassigned_hours,
                  (CASE WHEN worktype.billable_capitalizable_flag = 'Y' THEN
                  fct.conf_hrs_s * worktype.org_utilization_percentage / 100
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 conf_billable_hours,
                  (CASE WHEN worktype.billable_capitalizable_flag = 'N' THEN
                  fct.conf_hrs_s * worktype.org_utilization_percentage / 100
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 conf_nonbillable_hours,
                  (CASE WHEN worktype.billable_capitalizable_flag = 'Y' THEN
                  fct.prov_hrs_s * worktype.org_utilization_percentage / 100
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prov_billable_hours,
                  (CASE WHEN worktype.billable_capitalizable_flag = 'N' THEN
                  fct.prov_hrs_s * worktype.org_utilization_percentage / 100
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prov_nonbillable_hours,
                  (CASE WHEN worktype.training_flag = 'Y' THEN
                  fct.conf_hrs_s
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 training_hours,
                  decode(time.amount_type, 0, total_hrs_a, conf_hrs_s)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 expected_hours,
                  (decode(time.amount_type, 0, total_hrs_a, conf_hrs_s) * worktype.org_utilization_percentage / 100)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 expected_util_hours,
                  (decode(time.amount_type, 0, total_hrs_a, conf_hrs_s + prov_hrs_s) * worktype.org_utilization_percentage / 100)
                  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 expected_total_util_hours,
                  0                                              exp_reduce_capacity_hours,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 actual_hours,
                  (fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1))*
                  worktype.org_utilization_percentage / 100      actual_util_hours,
                  0                                              act_reduce_capacity_hours,
                  (decode(time.amount_type, 0, 0, fct.prov_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100      prov_util_hours,
                  (decode(time.amount_type, 0, fct.total_hrs_a, 0) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                                 exp_ac_util_hours,
                  (decode(time.amount_type, 0, 0, fct.conf_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100
                                                                 exp_sch_util_hours,
                  decode(time.amount_type, 0, fct.total_hrs_a, 0) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_ac_actual_hours,
                  decode(time.amount_type, 0, 0, fct.total_hrs_a) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 exp_sch_actual_hours,
                  0                                              exp_ac_red_capacity_hours,
                  0                                              exp_sch_red_capacity_hours,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_red_capacity_hours,
		  0						 prior_total_actual_hours,
		  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_WT_DIM_TMP wt,
                PJI_RM_RES_WT_F fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PJI_PMV_JB_DIM_TMP job,
                PA_WORK_TYPES_B worktype,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.work_type_id = wt.id
             AND wt.id = worktype.work_type_id
             AND fct.job_id = job.id
             AND fct.time_id = time.id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.id is not null
             AND hou.id = imp.org_id
           UNION ALL
	   /* Bug 3515594 */
           SELECT /*+ ORDERED */
                  hou.name                                       org_id,
                  horg.name                                      organization_id,
                  time.name                                      time_id,
                  DECODE(p_view_by, 'TM', time.id, -1)           time_key,
                  decode(p_view_by, 'UC', wt.name, '-1')         util_category_id,
                  decode(p_view_by, 'WT', wt.name, '-1')         work_type_id,
                  job.name                                       job_level_id,
                  0                                              scheduled_hours,
                  0                                              capacity_hours,
                  0                                              sch_reduce_capacity_hours,
		  0						 total_actual_hours,
		  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              exp_reduce_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              act_reduce_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              exp_ac_red_capacity_hours,
                  0                                              exp_sch_red_capacity_hours,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_red_capacity_hours,
		  0						 prior_total_actual_hours,
		  (fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)) *
                  worktype.org_utilization_percentage / 100      prior_sch_util_hours,
                  (CASE WHEN worktype.billable_capitalizable_flag = 'Y' THEN
                  fct.total_hrs_a * worktype.org_utilization_percentage / 100
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_conf_billable_hours,
                  (CASE WHEN worktype.billable_capitalizable_flag = 'N' THEN
                  fct.conf_hrs_s * worktype.org_utilization_percentage / 100
                  ELSE 0 END) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_conf_nonbillable_hours,
                  fct.total_hrs_a * decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1) *
                  worktype.org_utilization_percentage / 100      prior_actual_util_hours,
                  total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                 prior_actual_hours
           FROM PJI_PMV_ORGZ_DIM_TMP horg,
                PJI_PMV_TIME_DIM_TMP time,
                PJI_PMV_WT_DIM_TMP wt,
                PJI_RM_RES_WT_F fct,
                PJI_PMV_ORG_DIM_TMP hou,
                PJI_PMV_JB_DIM_TMP job,
                PA_WORK_TYPES_B worktype,
                PA_IMPLEMENTATIONS_ALL imp
           WHERE fct.expenditure_org_id = hou.id
             AND fct.expenditure_organization_id = horg.id
             AND fct.work_type_id = wt.id
             AND wt.id = worktype.work_type_id
             AND fct.job_id = job.id
             AND fct.time_id = time.prior_id
             AND fct.period_type_id = time.period_type
             AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND time.prior_id is not null
             AND hou.id = imp.org_id
           UNION ALL
           SELECT '-1'                                           org_id,
                  name                                           organization_id,
                  '-1'                                           time_id,
                  -1                                             time_key,
                  '-1'                                           util_category_id,
                  '-1'                                           work_type_id,
                  '-1'                                           job_level_id,
                  0                                              scheduled_hours,
                  0                                              capacity_hours,
                  0                                              sch_reduce_capacity_hours,
		  0						 total_actual_hours,
		  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              exp_reduce_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              act_reduce_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              exp_ac_red_capacity_hours,
                  0                                              exp_sch_red_capacity_hours,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_red_capacity_hours,
		  0						 prior_total_actual_hours,
		  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_ORGZ_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                           org_id,
                  '-1'                                           organization_id,
                  '-1'                                           time_id,
                  -1                                             time_key,
                  decode(p_view_by, 'UC', name, '-1')            util_category_id,
                  decode(p_view_by, 'WT', name, '-1')            work_type_id,
                  '-1'                                           job_level_id,
                  0                                              scheduled_hours,
                  0                                              capacity_hours,
                  0                                              sch_reduce_capacity_hours,
		  0						 total_actual_hours,
		  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              exp_reduce_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              act_reduce_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              exp_ac_red_capacity_hours,
                  0                                              exp_sch_red_capacity_hours,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_red_capacity_hours,
		  0						 prior_total_actual_hours,
		  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_WT_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                           org_id,
                  '-1'                                           organization_id,
                  '-1'                                           time_id,
                  -1                                             time_key,
                  '-1'                                           util_category_id,
                  '-1'                                           work_type_id,
                  name                                           job_level_id,
                  0                                              scheduled_hours,
                  0                                              capacity_hours,
                  0                                              sch_reduce_capacity_hours,
		  0						 total_actual_hours,
		  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              exp_reduce_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              act_reduce_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              exp_ac_red_capacity_hours,
                  0                                              exp_sch_red_capacity_hours,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_red_capacity_hours,
		  0						 prior_total_actual_hours,
                  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_JB_DIM_TMP
           WHERE name <> '-1'
           UNION ALL
           SELECT '-1'                                           org_id,
                  '-1'                                           organization_id,
                  name                                           time_id,
                  order_by_id                                    time_key,
                  '-1'                                           util_category_id,
                  '-1'                                           work_type_id,
                  '-1'                                           job_level_id,
                  0                                              scheduled_hours,
                  0                                              capacity_hours,
                  0                                              sch_reduce_capacity_hours,
		  0						 total_actual_hours,
		  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              exp_reduce_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              act_reduce_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              exp_ac_red_capacity_hours,
                  0                                              exp_sch_red_capacity_hours,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_red_capacity_hours,
		  0						 prior_total_actual_hours,
		  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM PJI_PMV_TIME_DIM_TMP
           WHERE name <> '-1'
           UNION ALL   -- added for current year capacity_hours
	   /* Bug 3515594 */
           SELECT
                  FACT.org_id,
                  FACT.organization_id,
                  FACT.time_id,
                  FACT.time_key,
                  decode(p_view_by, 'UC', WT.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', WT.name, '-1')  work_type_id,
                  FACT.job_level_id                       job_level_id,
                  0                                       scheduled_hours,
                  FACT.capacity_hours                            capacity_hours,
                  FACT.sch_reduce_capacity_hours                 sch_reduce_capacity_hours,
		  FACT.total_actual_hours			 total_actual_hours,
		  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  FACT.exp_reduce_capacity_hours                 exp_reduce_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  FACT.act_reduce_capacity_hours                 act_reduce_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  FACT.exp_ac_red_capacity_hours                 exp_ac_red_capacity_hours,
                  FACT.exp_sch_red_capacity_hours                exp_sch_red_capacity_hours,
                  0                                              prior_scheduled_hours,
                  0                                              prior_capacity_hours,
                  0                                              prior_red_capacity_hours,
		  0						 prior_total_actual_hours,
		  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM
            (SELECT /*+ ORDERED */
                     hou.name                                org_id,
                     horg.name                               organization_id,
                     time.name                               time_id,
                     DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                     job.name                                job_level_id,
                     fct.capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          capacity_hours,
                     fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          total_actual_hours,
		     fct.reduce_capacity_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          sch_reduce_capacity_hours,
                     decode(time.amount_type, 0, reduce_capacity_hrs_a, reduce_capacity_hrs_s)
                           /  decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          exp_reduce_capacity_hours,
                     fct.reduce_capacity_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          act_reduce_capacity_hours,
                     decode(time.amount_type, 0, reduce_capacity_hrs_a,0)
                           /  decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          exp_ac_red_capacity_hours,
                     decode(time.amount_type, 1, reduce_capacity_hrs_s,0)
                           /  decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          exp_sch_red_capacity_hours
             FROM PJI_PMV_ORGZ_DIM_TMP horg,
                  PJI_PMV_TIME_DIM_TMP time,
                  PJI_PMV_JB_DIM_TMP   job,
                  PJI_RM_JOB_F_MV fct,
                  PJI_PMV_ORG_DIM_TMP hou,
                  PA_IMPLEMENTATIONS_ALL imp
             WHERE fct.expenditure_org_id = hou.id
             AND   fct.expenditure_organization_id = horg.id
             AND   fct.time_id = time.id
             AND   fct.period_type_id = time.period_type
             AND   fct.job_id  = job.id
             AND   fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND   time.id is not null
             AND   hou.id = imp.org_id )         FACT,
             (SELECT distinct WT.name
              FROM   PJI_PMV_WT_DIM_TMP wt )     WT
           UNION ALL   -- added for prior year capacity_hours
	   /* Bug 3515594 */
           SELECT
                  FACT.org_id,
                  FACT.organization_id,
                  FACT.time_id,
                  FACT.time_key,
                  decode(p_view_by, 'UC', WT.name, '-1')  util_category_id,
                  decode(p_view_by, 'WT', WT.name, '-1')  work_type_id,
                  FACT.job_level_id                       job_level_id,
                  0                                       scheduled_hours,
                  0                                       capacity_hours,
                  0                                              sch_reduce_capacity_hours,
		  0						 total_actual_hours,
		  0                                              scheduled_util_hours,
                  0                                              provisional_hours,
                  0                                              unassigned_hours,
                  0                                              conf_billable_hours,
                  0                                              conf_nonbillable_hours,
                  0                                              prov_billable_hours,
                  0                                              prov_nonbillable_hours,
                  0                                              training_hours,
                  0                                              expected_hours,
                  0                                              expected_util_hours,
                  0                                              expected_total_util_hours,
                  0                                              exp_reduce_capacity_hours,
                  0                                              actual_hours,
                  0                                              actual_util_hours,
                  0                                              act_reduce_capacity_hours,
                  0                                              prov_util_hours,
                  0                                              exp_ac_util_hours,
                  0                                              exp_sch_util_hours,
                  0                                              exp_ac_actual_hours,
                  0                                              exp_sch_actual_hours,
                  0                                              exp_ac_red_capacity_hours,
                  0                                              exp_sch_red_capacity_hours,
                  0                                              prior_scheduled_hours,
                  FACT.capacity_hours                            prior_capacity_hours,
                  FACT.prior_red_capacity_hours                  prior_red_capacity_hours,
		  FACT.total_actual_hours			 prior_total_actual_hours,
		  0                                              prior_sch_util_hours,
                  0                                              prior_conf_billable_hours,
                  0                                              prior_conf_nonbillable_hours,
                  0                                              prior_actual_util_hours,
                  0                                              prior_actual_hours
           FROM
            (SELECT /*+ ORDERED */
                     hou.name                                org_id,
                     horg.name                               organization_id,
                     time.name                               time_id,
                     DECODE(p_view_by, 'TM', time.id, -1)    time_key,
                     job.name                                job_level_id,
                     fct.capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          capacity_hours,
                     fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          total_actual_hours,
		     fct.reduce_capacity_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                          prior_red_capacity_hours
             FROM PJI_PMV_ORGZ_DIM_TMP horg,
                  PJI_PMV_TIME_DIM_TMP time,
                  PJI_PMV_JB_DIM_TMP   job,
                  PJI_RM_JOB_F_MV fct,
                  PJI_PMV_ORG_DIM_TMP hou,
                  PA_IMPLEMENTATIONS_ALL imp
             WHERE fct.expenditure_org_id = hou.id
             AND   fct.expenditure_organization_id = horg.id
             AND   fct.time_id = time.prior_id
             AND   fct.period_type_id = time.period_type
             AND   fct.job_id  = job.id
             AND   fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
             AND   time.prior_id is not null
             AND   hou.id = imp.org_id )         FACT,
             (SELECT distinct WT.name
              FROM   PJI_PMV_WT_DIM_TMP wt )     WT
           )
           GROUP BY org_id,
		     organization_id,
		     time_id,
		     time_key,
		     util_category_id,
             work_type_id,
		     job_level_id;
   END IF;

   /* Correcting value of Top level Org */


     FOR i in 1..l_u4_tbl.COUNT
       LOOP
         IF p_View_By = 'OG' AND ( l_job_flag = 'N' OR l_util_category_flag = 'N' )
            AND  l_u4_tbl(i).ORGANIZATION_ID = l_Top_Organization_Name THEN

           l_Top_Org_Index:=i;

         ELSE

           l_scheduled_hours                  := l_scheduled_hours                + nvl(l_u4_tbl(i).scheduled_hours,0);
		   l_scheduled_capacity_hours    	  := l_scheduled_capacity_hours    	  +	nvl(l_u4_tbl(i).scheduled_capacity_hours,0);
		   l_scheduled_util_hours        	  := l_scheduled_util_hours        	  +	nvl(l_u4_tbl(i).scheduled_util_hours,0);
		   l_provisional_hours           	  := l_provisional_hours           	  +	nvl(l_u4_tbl(i).provisional_hours,0);
		   l_unassigned_hours            	  := l_unassigned_hours            	  +	nvl(l_u4_tbl(i).unassigned_hours,0);
		   l_conf_billable_hours         	  := l_conf_billable_hours         	  +	nvl(l_u4_tbl(i).conf_billable_hours,0);
		   l_conf_nonbillable_hours      	  := l_conf_nonbillable_hours      	  +	nvl(l_u4_tbl(i).conf_nonbillable_hours,0);
		   l_prov_billable_hours         	  := l_prov_billable_hours         	  +	nvl(l_u4_tbl(i).prov_billable_hours,0);
		   l_prov_nonbillable_hours      	  := l_prov_nonbillable_hours      	  +	nvl(l_u4_tbl(i).prov_nonbillable_hours,0);
		   l_training_hours              	  := l_training_hours              	  +	nvl(l_u4_tbl(i).training_hours,0);
		   l_expected_hours              	  := l_expected_hours              	  +	nvl(l_u4_tbl(i).expected_hours,0);
		   l_expected_util_hours         	  := l_expected_util_hours         	  +	nvl(l_u4_tbl(i).expected_util_hours,0);
		   l_expected_total_util_hours   	  := l_expected_total_util_hours   	  +	nvl(l_u4_tbl(i).expected_total_util_hours,0);
		   l_actual_util_hours           	  := l_actual_util_hours           	  +	nvl(l_u4_tbl(i).actual_util_hours,0);
		   l_actual_capacity_hours       	  := l_actual_capacity_hours       	  +	nvl(l_u4_tbl(i).actual_capacity_hours,0);
		   l_expected_capacity_hours          	  := l_expected_capacity_hours        	  + 	nvl(l_u4_tbl(i).expected_capacity_hours,0);
		   l_prov_util_hours             	  := l_prov_util_hours             	  +	nvl(l_u4_tbl(i).prov_util_hours,0);
		   l_exp_ac_util_hours           	  := l_exp_ac_util_hours           	  +	nvl(l_u4_tbl(i).exp_ac_util_hours,0);
		   l_exp_sch_util_hours          	  := l_exp_sch_util_hours          	  +	nvl(l_u4_tbl(i).exp_sch_util_hours,0);
		   l_exp_ac_denominator          	  := l_exp_ac_denominator          	  +	nvl(l_u4_tbl(i).exp_ac_denominator,0);
		   l_exp_sch_denominator         	  := l_exp_sch_denominator         	  +	nvl(l_u4_tbl(i).exp_sch_denominator,0);
		   l_actual_denominator          	  := l_actual_denominator          	  +	nvl(l_u4_tbl(i).actual_denominator,0);
		   l_scheduled_denominator       	  := l_scheduled_denominator       	  +	nvl(l_u4_tbl(i).scheduled_denominator,0);
		   l_expected_denominator        	  := l_expected_denominator        	  +	nvl(l_u4_tbl(i).expected_denominator,0);
		   l_prior_scheduled_hours       	  := l_prior_scheduled_hours       	  +	nvl(l_u4_tbl(i).prior_scheduled_hours,0);
		   l_prior_sch_capacity_hours    	  := l_prior_sch_capacity_hours    	  +	nvl(l_u4_tbl(i).prior_sch_capacity_hours,0);
		   l_prior_sch_util_hours        	  := l_prior_sch_util_hours        	  +	nvl(l_u4_tbl(i).prior_sch_util_hours,0);
		   l_prior_conf_billable_hours   	  := l_prior_conf_billable_hours   	  +	nvl(l_u4_tbl(i).prior_conf_billable_hours,0);
		   l_prior_conf_nonbillable_hours	  := l_prior_conf_nonbillable_hours	  +	nvl(l_u4_tbl(i).prior_conf_nonbillable_hours,0);
		   l_prior_actual_capacity_hours 	  := l_prior_actual_capacity_hours 	  +	nvl(l_u4_tbl(i).prior_actual_capacity_hours,0);
		   l_prior_actual_util_hours          := l_prior_actual_util_hours        + nvl(l_u4_tbl(i).prior_actual_util_hours,0);
		   l_prior_actual_denominator         := l_prior_actual_denominator       + nvl(l_u4_tbl(i).prior_actual_denominator,0);
		   l_prior_scheduled_denominator      := l_prior_scheduled_denominator    +	nvl(l_u4_tbl(i).prior_scheduled_denominator,0);

           --Calculated column processing is done below
           --L-Top-Org is not done here
           --Calculated columns for PJI_REP_U4
           IF nvl(l_u4_tbl(i).scheduled_denominator,0) <> 0 THEN
             l_u4_tbl(i).sch_util_percent := 100 * (l_u4_tbl(i).scheduled_util_hours / l_u4_tbl(i).scheduled_denominator);
             l_u4_tbl(i).bill_util_percent := 100 * (l_u4_tbl(i).conf_billable_hours / l_u4_tbl(i).scheduled_denominator);
             l_u4_tbl(i).nonbill_util_percent := 100 * (l_u4_tbl(i).conf_nonbillable_hours / l_u4_tbl(i).scheduled_denominator);
             l_u4_tbl(i).unassigned_percent := 100 * (l_u4_tbl(i).unassigned_hours / l_u4_tbl(i).scheduled_denominator);
             l_u4_tbl(i).training_percent := 100 * (l_u4_tbl(i).training_hours / l_u4_tbl(i).scheduled_denominator);
             l_u4_tbl(i).prov_bill_percent := 100 * (l_u4_tbl(i).prov_billable_hours / l_u4_tbl(i).scheduled_denominator);
             l_u4_tbl(i).prov_nonbill_percent := 100 * (l_u4_tbl(i).prov_nonbillable_hours / l_u4_tbl(i).scheduled_denominator);

           ELSE
             l_u4_tbl(i).sch_util_percent := NULL;
             l_u4_tbl(i).bill_util_percent := NULL;
			 l_u4_tbl(i).nonbill_util_percent := NULL;
			 l_u4_tbl(i).unassigned_percent := NULL;
			 l_u4_tbl(i).training_percent := NULL;
			 l_u4_tbl(i).prov_bill_percent := NULL;
			 l_u4_tbl(i).prov_nonbill_percent := NULL;

           END IF;

           IF nvl(l_u4_tbl(i).prior_scheduled_denominator,0) <> 0 THEN
             l_u4_tbl(i).prior_sch_util_percent := 100 * (l_u4_tbl(i).prior_sch_util_hours / l_u4_tbl(i).prior_scheduled_denominator);
             l_u4_tbl(i).prior_bill_util_percent := 100 * (l_u4_tbl(i).prior_conf_billable_hours / l_u4_tbl(i).prior_scheduled_denominator);
             l_u4_tbl(i).prior_nonbill_util_percent := 100 * (l_u4_tbl(i).prior_conf_nonbillable_hours / l_u4_tbl(i).prior_scheduled_denominator);
           ELSE
             l_u4_tbl(i).prior_sch_util_percent := NULL;
             l_u4_tbl(i).prior_bill_util_percent := NULL;
			 l_u4_tbl(i).prior_nonbill_util_percent := NULL;
           END IF;

           --Calculated columns for PJI_REP_U5
           IF nvl(l_u4_tbl(i).exp_ac_denominator,0) <> 0 THEN

             l_u4_tbl(i).exp_act_util_percent := 100 * (l_u4_tbl(i).exp_ac_util_hours / l_u4_tbl(i).exp_ac_denominator);

           ELSE
             l_u4_tbl(i).exp_act_util_percent := NULL;
           END IF;

           IF nvl(l_u4_tbl(i).exp_sch_denominator,0) <> 0 THEN

             l_u4_tbl(i).exp_sch_util_percent := 100 * (l_u4_tbl(i).exp_sch_util_hours / l_u4_tbl(i).exp_sch_denominator);
             l_u4_tbl(i).prov_sch_util_percent := 100 * (l_u4_tbl(i).prov_util_hours / l_u4_tbl(i).exp_sch_denominator);

           ELSE
             l_u4_tbl(i).exp_sch_util_percent := NULL;
             l_u4_tbl(i).prov_sch_util_percent := NULL;
           END IF;

           IF nvl(l_u4_tbl(i).expected_denominator,0) <> 0 THEN

             l_u4_tbl(i).exp_util_percent := 100 * (l_u4_tbl(i).expected_util_hours / l_u4_tbl(i).expected_denominator);
             l_u4_tbl(i).exp_total_util_percent := 100 * (l_u4_tbl(i).expected_total_util_hours / l_u4_tbl(i).expected_denominator);

           ELSE
             l_u4_tbl(i).exp_util_percent := NULL;
             l_u4_tbl(i).exp_total_util_percent := NULL;
           END IF;

           IF nvl(l_u4_tbl(i).prior_actual_denominator,0) <> 0 THEN

             l_u4_tbl(i).prior_act_util_percent := 100 * (l_u4_tbl(i).prior_actual_util_hours / l_u4_tbl(i).prior_actual_denominator);

           ELSE
             l_u4_tbl(i).prior_act_util_percent := NULL;
           END IF;

         END IF; --end p_view_by
       END LOOP;

       IF p_View_By = 'OG' AND ( l_job_flag = 'N' OR l_util_category_flag = 'N' )  THEN

           l_u4_tbl(l_Top_Org_Index).scheduled_hours                    :=  l_u4_tbl(l_Top_Org_Index).scheduled_hours               -  l_scheduled_hours;
		   l_u4_tbl(l_Top_Org_Index).scheduled_capacity_hours       	:= 	l_u4_tbl(l_Top_Org_Index).scheduled_capacity_hours      -  l_scheduled_capacity_hours;
		   l_u4_tbl(l_Top_Org_Index).scheduled_util_hours           	:= 	l_u4_tbl(l_Top_Org_Index).scheduled_util_hours          -  l_scheduled_util_hours;
		   l_u4_tbl(l_Top_Org_Index).provisional_hours              	:= 	l_u4_tbl(l_Top_Org_Index).provisional_hours             -  l_provisional_hours;
		   l_u4_tbl(l_Top_Org_Index).unassigned_hours               	:= 	l_u4_tbl(l_Top_Org_Index).unassigned_hours              -  l_unassigned_hours;
		   l_u4_tbl(l_Top_Org_Index).conf_billable_hours            	:= 	l_u4_tbl(l_Top_Org_Index).conf_billable_hours           -  l_conf_billable_hours;
		   l_u4_tbl(l_Top_Org_Index).conf_nonbillable_hours         	:= 	l_u4_tbl(l_Top_Org_Index).conf_nonbillable_hours        -  l_conf_nonbillable_hours;
		   l_u4_tbl(l_Top_Org_Index).prov_billable_hours            	:= 	l_u4_tbl(l_Top_Org_Index).prov_billable_hours           -  l_prov_billable_hours;
		   l_u4_tbl(l_Top_Org_Index).prov_nonbillable_hours         	:= 	l_u4_tbl(l_Top_Org_Index).prov_nonbillable_hours        -  l_prov_nonbillable_hours;
		   l_u4_tbl(l_Top_Org_Index).training_hours                 	:= 	l_u4_tbl(l_Top_Org_Index).training_hours                -  l_training_hours;
		   l_u4_tbl(l_Top_Org_Index).expected_hours                 	:= 	l_u4_tbl(l_Top_Org_Index).expected_hours                -  l_expected_hours;
		   l_u4_tbl(l_Top_Org_Index).expected_util_hours            	:= 	l_u4_tbl(l_Top_Org_Index).expected_util_hours           -  l_expected_util_hours;
		   l_u4_tbl(l_Top_Org_Index).expected_total_util_hours      	:= 	l_u4_tbl(l_Top_Org_Index).expected_total_util_hours     -  l_expected_total_util_hours;
		   l_u4_tbl(l_Top_Org_Index).actual_util_hours              	:= 	l_u4_tbl(l_Top_Org_Index).actual_util_hours             -  l_actual_util_hours;
		   l_u4_tbl(l_Top_Org_Index).actual_capacity_hours          	:= 	l_u4_tbl(l_Top_Org_Index).actual_capacity_hours         -  l_actual_capacity_hours;
		   l_u4_tbl(l_Top_Org_Index).expected_capacity_hours        	:= 	l_u4_tbl(l_Top_Org_Index).expected_capacity_hours       -  l_expected_capacity_hours;
		   l_u4_tbl(l_Top_Org_Index).prov_util_hours                	:= 	l_u4_tbl(l_Top_Org_Index).prov_util_hours               -  l_prov_util_hours;
		   l_u4_tbl(l_Top_Org_Index).exp_ac_util_hours              	:= 	l_u4_tbl(l_Top_Org_Index).exp_ac_util_hours             -  l_exp_ac_util_hours;
		   l_u4_tbl(l_Top_Org_Index).exp_sch_util_hours             	:= 	l_u4_tbl(l_Top_Org_Index).exp_sch_util_hours            -  l_exp_sch_util_hours;
		   l_u4_tbl(l_Top_Org_Index).exp_ac_denominator             	:= 	l_u4_tbl(l_Top_Org_Index).exp_ac_denominator            -  l_exp_ac_denominator;
		   l_u4_tbl(l_Top_Org_Index).exp_sch_denominator            	:= 	l_u4_tbl(l_Top_Org_Index).exp_sch_denominator           -  l_exp_sch_denominator;
		   l_u4_tbl(l_Top_Org_Index).actual_denominator             	:= 	l_u4_tbl(l_Top_Org_Index).actual_denominator            -  l_actual_denominator;
		   l_u4_tbl(l_Top_Org_Index).scheduled_denominator          	:= 	l_u4_tbl(l_Top_Org_Index).scheduled_denominator         -  l_scheduled_denominator;
		   l_u4_tbl(l_Top_Org_Index).expected_denominator           	:= 	l_u4_tbl(l_Top_Org_Index).expected_denominator          -  l_expected_denominator;
		   l_u4_tbl(l_Top_Org_Index).prior_scheduled_hours          	:= 	l_u4_tbl(l_Top_Org_Index).prior_scheduled_hours         -  l_prior_scheduled_hours;
		   l_u4_tbl(l_Top_Org_Index).prior_sch_capacity_hours       	:= 	l_u4_tbl(l_Top_Org_Index).prior_sch_capacity_hours      -  l_prior_sch_capacity_hours;
		   l_u4_tbl(l_Top_Org_Index).prior_sch_util_hours           	:= 	l_u4_tbl(l_Top_Org_Index).prior_sch_util_hours          -  l_prior_sch_util_hours;
		   l_u4_tbl(l_Top_Org_Index).prior_conf_billable_hours      	:= 	l_u4_tbl(l_Top_Org_Index).prior_conf_billable_hours     -  l_prior_conf_billable_hours;
		   l_u4_tbl(l_Top_Org_Index).prior_conf_nonbillable_hours   	:= 	l_u4_tbl(l_Top_Org_Index).prior_conf_nonbillable_hours  -  l_prior_conf_nonbillable_hours;
		   l_u4_tbl(l_Top_Org_Index).prior_actual_capacity_hours    	:= 	l_u4_tbl(l_Top_Org_Index).prior_actual_capacity_hours   -  l_prior_actual_capacity_hours;
		   l_u4_tbl(l_Top_Org_Index).prior_actual_util_hours        	:= 	l_u4_tbl(l_Top_Org_Index).prior_actual_util_hours       -  l_prior_actual_util_hours;
		   l_u4_tbl(l_Top_Org_Index).prior_actual_denominator       	:= 	l_u4_tbl(l_Top_Org_Index).prior_actual_denominator      -  l_prior_actual_denominator;
		   l_u4_tbl(l_Top_Org_Index).prior_scheduled_denominator   	    := 	l_u4_tbl(l_Top_Org_Index).prior_scheduled_denominator   -  l_prior_scheduled_denominator;

           --Calculated columns processing for l_top_org
           IF nvl(l_u4_tbl(l_Top_Org_Index).scheduled_denominator,0) <> 0 THEN
             l_u4_tbl(l_Top_Org_Index).sch_util_percent := 100 * (l_u4_tbl(l_Top_Org_Index).scheduled_util_hours / l_u4_tbl(l_Top_Org_Index).scheduled_denominator);
             l_u4_tbl(l_Top_Org_Index).bill_util_percent := 100 * (l_u4_tbl(l_Top_Org_Index).conf_billable_hours / l_u4_tbl(l_Top_Org_Index).scheduled_denominator);
             l_u4_tbl(l_Top_Org_Index).nonbill_util_percent := 100 * (l_u4_tbl(l_Top_Org_Index).conf_nonbillable_hours / l_u4_tbl(l_Top_Org_Index).scheduled_denominator);
             l_u4_tbl(l_Top_Org_Index).unassigned_percent := 100 * (l_u4_tbl(l_Top_Org_Index).unassigned_hours / l_u4_tbl(l_Top_Org_Index).scheduled_denominator);
             l_u4_tbl(l_Top_Org_Index).training_percent := 100 * (l_u4_tbl(l_Top_Org_Index).training_hours / l_u4_tbl(l_Top_Org_Index).scheduled_denominator);
             l_u4_tbl(l_Top_Org_Index).prov_bill_percent := 100 * (l_u4_tbl(l_Top_Org_Index).prov_billable_hours / l_u4_tbl(l_Top_Org_Index).scheduled_denominator);
             l_u4_tbl(l_Top_Org_Index).prov_nonbill_percent := 100 * (l_u4_tbl(l_Top_Org_Index).prov_nonbillable_hours / l_u4_tbl(l_Top_Org_Index).scheduled_denominator);

           ELSE
             l_u4_tbl(l_Top_Org_Index).sch_util_percent := NULL;
             l_u4_tbl(l_Top_Org_Index).bill_util_percent := NULL;
			 l_u4_tbl(l_Top_Org_Index).nonbill_util_percent := NULL;
			 l_u4_tbl(l_Top_Org_Index).unassigned_percent := NULL;
			 l_u4_tbl(l_Top_Org_Index).training_percent := NULL;
			 l_u4_tbl(l_Top_Org_Index).prov_bill_percent := NULL;
			 l_u4_tbl(l_Top_Org_Index).prov_nonbill_percent := NULL;

           END IF;

           IF nvl(l_u4_tbl(l_Top_Org_Index).prior_scheduled_denominator,0) <> 0 THEN
             l_u4_tbl(l_Top_Org_Index).prior_sch_util_percent := 100 * (l_u4_tbl(l_Top_Org_Index).prior_sch_util_hours / l_u4_tbl(l_Top_Org_Index).prior_scheduled_denominator);
             l_u4_tbl(l_Top_Org_Index).prior_bill_util_percent := 100 * (l_u4_tbl(l_Top_Org_Index).prior_conf_billable_hours / l_u4_tbl(l_Top_Org_Index).prior_scheduled_denominator);
             l_u4_tbl(l_Top_Org_Index).prior_nonbill_util_percent := 100 * (l_u4_tbl(l_Top_Org_Index).prior_conf_nonbillable_hours / l_u4_tbl(l_Top_Org_Index).prior_scheduled_denominator);
           ELSE
             l_u4_tbl(l_Top_Org_Index).prior_sch_util_percent := NULL;
             l_u4_tbl(l_Top_Org_Index).prior_bill_util_percent := NULL;
			 l_u4_tbl(l_Top_Org_Index).prior_nonbill_util_percent := NULL;
           END IF;

           --Calculated columns for PJI_REP_U5
           IF nvl(l_u4_tbl(l_Top_Org_Index).exp_ac_denominator,0) <> 0 THEN

             l_u4_tbl(l_Top_Org_Index).exp_act_util_percent := 100 * (l_u4_tbl(l_Top_Org_Index).exp_ac_util_hours / l_u4_tbl(l_Top_Org_Index).exp_ac_denominator);

           ELSE
             l_u4_tbl(l_Top_Org_Index).exp_act_util_percent := NULL;
           END IF;

           IF nvl(l_u4_tbl(l_Top_Org_Index).exp_sch_denominator,0) <> 0 THEN

             l_u4_tbl(l_Top_Org_Index).exp_sch_util_percent := 100 * (l_u4_tbl(l_Top_Org_Index).exp_sch_util_hours / l_u4_tbl(l_Top_Org_Index).exp_sch_denominator);
             l_u4_tbl(l_Top_Org_Index).prov_sch_util_percent := 100 * (l_u4_tbl(l_Top_Org_Index).prov_util_hours / l_u4_tbl(l_Top_Org_Index).exp_sch_denominator);

           ELSE
             l_u4_tbl(l_Top_Org_Index).exp_sch_util_percent := NULL;
             l_u4_tbl(l_Top_Org_Index).prov_sch_util_percent := NULL;
           END IF;

           IF nvl(l_u4_tbl(l_Top_Org_Index).expected_denominator,0) <> 0 THEN

             l_u4_tbl(l_Top_Org_Index).exp_util_percent := 100 * (l_u4_tbl(l_Top_Org_Index).expected_util_hours / l_u4_tbl(l_Top_Org_Index).expected_denominator);
             l_u4_tbl(l_Top_Org_Index).exp_total_util_percent := 100 * (l_u4_tbl(l_Top_Org_Index).expected_total_util_hours / l_u4_tbl(l_Top_Org_Index).expected_denominator);

           ELSE
             l_u4_tbl(l_Top_Org_Index).exp_util_percent := NULL;
             l_u4_tbl(l_Top_Org_Index).exp_total_util_percent := NULL;
           END IF;

           IF nvl(l_u4_tbl(l_Top_Org_Index).prior_actual_denominator,0) <> 0 THEN

             l_u4_tbl(l_Top_Org_Index).prior_act_util_percent := 100 * (l_u4_tbl(l_Top_Org_Index).prior_actual_util_hours / l_u4_tbl(l_Top_Org_Index).prior_actual_denominator);

           ELSE
             l_u4_tbl(l_Top_Org_Index).prior_act_util_percent := NULL;
           END IF;

        END IF; --end p_view_vy

    IF l_Top_Org_Index is not null THEN

        --Update local variables to include top level org for grand total
        l_scheduled_hours                 := l_scheduled_hours                + nvl(l_u4_tbl(l_Top_Org_Index).scheduled_hours,0);
		l_scheduled_capacity_hours    	  := l_scheduled_capacity_hours    	  +	nvl(l_u4_tbl(l_Top_Org_Index).scheduled_capacity_hours,0);
		l_scheduled_util_hours        	  := l_scheduled_util_hours        	  +	nvl(l_u4_tbl(l_Top_Org_Index).scheduled_util_hours,0);
		l_provisional_hours           	  := l_provisional_hours           	  +	nvl(l_u4_tbl(l_Top_Org_Index).provisional_hours,0);
		l_unassigned_hours            	  := l_unassigned_hours            	  +	nvl(l_u4_tbl(l_Top_Org_Index).unassigned_hours,0);
		l_conf_billable_hours         	  := l_conf_billable_hours         	  +	nvl(l_u4_tbl(l_Top_Org_Index).conf_billable_hours,0);
		l_conf_nonbillable_hours      	  := l_conf_nonbillable_hours      	  +	nvl(l_u4_tbl(l_Top_Org_Index).conf_nonbillable_hours,0);
		l_prov_billable_hours         	  := l_prov_billable_hours         	  +	nvl(l_u4_tbl(l_Top_Org_Index).prov_billable_hours,0);
		l_prov_nonbillable_hours      	  := l_prov_nonbillable_hours      	  +	nvl(l_u4_tbl(l_Top_Org_Index).prov_nonbillable_hours,0);
		l_training_hours              	  := l_training_hours              	  +	nvl(l_u4_tbl(l_Top_Org_Index).training_hours,0);
		l_expected_hours              	  := l_expected_hours              	  +	nvl(l_u4_tbl(l_Top_Org_Index).expected_hours,0);
		l_expected_util_hours         	  := l_expected_util_hours         	  +	nvl(l_u4_tbl(l_Top_Org_Index).expected_util_hours,0);
		l_expected_total_util_hours   	  := l_expected_total_util_hours   	  +	nvl(l_u4_tbl(l_Top_Org_Index).expected_total_util_hours,0);
		l_actual_util_hours           	  := l_actual_util_hours           	  +	nvl(l_u4_tbl(l_Top_Org_Index).actual_util_hours,0);
		l_actual_capacity_hours       	  := l_actual_capacity_hours       	  +	nvl(l_u4_tbl(l_Top_Org_Index).actual_capacity_hours,0);
		l_expected_capacity_hours         := l_expected_capacity_hours        + nvl(l_u4_tbl(l_Top_Org_Index).expected_capacity_hours,0);
		l_prov_util_hours             	  := l_prov_util_hours             	  +	nvl(l_u4_tbl(l_Top_Org_Index).prov_util_hours,0);
		l_exp_ac_util_hours           	  := l_exp_ac_util_hours           	  +	nvl(l_u4_tbl(l_Top_Org_Index).exp_ac_util_hours,0);
		l_exp_sch_util_hours          	  := l_exp_sch_util_hours          	  +	nvl(l_u4_tbl(l_Top_Org_Index).exp_sch_util_hours,0);
		l_exp_ac_denominator          	  := l_exp_ac_denominator          	  +	nvl(l_u4_tbl(l_Top_Org_Index).exp_ac_denominator,0);
		l_exp_sch_denominator         	  := l_exp_sch_denominator         	  +	nvl(l_u4_tbl(l_Top_Org_Index).exp_sch_denominator,0);
		l_actual_denominator          	  := l_actual_denominator          	  +	nvl(l_u4_tbl(l_Top_Org_Index).actual_denominator,0);
		l_scheduled_denominator       	  := l_scheduled_denominator       	  +	nvl(l_u4_tbl(l_Top_Org_Index).scheduled_denominator,0);
		l_expected_denominator        	  := l_expected_denominator        	  +	nvl(l_u4_tbl(l_Top_Org_Index).expected_denominator,0);
		l_prior_scheduled_hours       	  := l_prior_scheduled_hours       	  +	nvl(l_u4_tbl(l_Top_Org_Index).prior_scheduled_hours,0);
		l_prior_sch_capacity_hours    	  := l_prior_sch_capacity_hours    	  +	nvl(l_u4_tbl(l_Top_Org_Index).prior_sch_capacity_hours,0);
		l_prior_sch_util_hours        	  := l_prior_sch_util_hours        	  +	nvl(l_u4_tbl(l_Top_Org_Index).prior_sch_util_hours,0);
		l_prior_conf_billable_hours   	  := l_prior_conf_billable_hours   	  +	nvl(l_u4_tbl(l_Top_Org_Index).prior_conf_billable_hours,0);
		l_prior_conf_nonbillable_hours	  := l_prior_conf_nonbillable_hours	  +	nvl(l_u4_tbl(l_Top_Org_Index).prior_conf_nonbillable_hours,0);
		l_prior_actual_capacity_hours 	  := l_prior_actual_capacity_hours 	  +	nvl(l_u4_tbl(l_Top_Org_Index).prior_actual_capacity_hours,0);
		l_prior_actual_util_hours         := l_prior_actual_util_hours        + nvl(l_u4_tbl(l_Top_Org_Index).prior_actual_util_hours,0);
		l_prior_actual_denominator        := l_prior_actual_denominator       + nvl(l_u4_tbl(l_Top_Org_Index).prior_actual_denominator,0);
		l_prior_scheduled_denominator     := l_prior_scheduled_denominator    +	nvl(l_u4_tbl(l_Top_Org_Index).prior_scheduled_denominator,0);

    END IF;

        IF l_u4_tbl.COUNT > 0 THEN
          FOR i in 1..l_u4_tbl.COUNT LOOP

            IF l_u4_tbl.EXISTS(i) THEN

               --Capacity is denormalized when context is view by UC or WT
               IF p_view_by = 'UC' OR p_view_by = 'WT' THEN

                 /*Bug 2836444*/

                 l_scheduled_denominator       := l_u4_tbl(i).SCHEDULED_DENOMINATOR;
                 l_prior_scheduled_denominator := l_u4_tbl(i).PRIOR_SCHEDULED_DENOMINATOR;
                 l_exp_ac_denominator          := l_u4_tbl(i).EXP_AC_DENOMINATOR;
                 l_exp_sch_denominator         := l_u4_tbl(i).EXP_SCH_DENOMINATOR;
                 l_expected_denominator        := l_u4_tbl(i).EXPECTED_DENOMINATOR;
                 l_prior_actual_denominator    := l_u4_tbl(i).PRIOR_ACTUAL_DENOMINATOR;

                 /*Bug 2836477*/
                 l_scheduled_capacity_hours    := null;
                 l_expected_capacity_hours     := null;
                 l_unassigned_hours            := null;

               END IF;

               l_u4_tbl(i).PJI_REP_TOTAL_1 := l_scheduled_hours;
               l_u4_tbl(i).PJI_REP_TOTAL_2 := l_scheduled_capacity_hours;
               l_u4_tbl(i).PJI_REP_TOTAL_3 := l_scheduled_util_hours;
               l_u4_tbl(i).PJI_REP_TOTAL_4 := l_provisional_hours;
               l_u4_tbl(i).PJI_REP_TOTAL_5 := l_expected_hours;
               l_u4_tbl(i).PJI_REP_TOTAL_6 := l_expected_capacity_hours;
               l_u4_tbl(i).PJI_REP_TOTAL_7 := l_prior_scheduled_hours;


               IF nvl(l_scheduled_denominator,0) <> 0 THEN

                 l_u4_tbl(i).PJI_REP_TOTAL_8      := (l_scheduled_util_hours/l_scheduled_denominator)*100;
                 l_u4_tbl(i).PJI_REP_TOTAL_9      := (l_conf_billable_hours/l_scheduled_denominator)*100;
                 l_u4_tbl(i).PJI_REP_TOTAL_10     := (l_conf_nonbillable_hours/l_scheduled_denominator)*100;
                 l_u4_tbl(i).PJI_REP_TOTAL_11     := (l_unassigned_hours/l_scheduled_denominator)*100;
                 l_u4_tbl(i).PJI_REP_TOTAL_12     := (l_training_hours/l_scheduled_denominator)*100;
                 l_u4_tbl(i).PJI_REP_TOTAL_13     := (l_prov_billable_hours/l_scheduled_denominator)*100;
                 l_u4_tbl(i).PJI_REP_TOTAL_14     := (l_prov_nonbillable_hours/l_scheduled_denominator)*100;

               END IF;

               IF nvl(l_prior_scheduled_denominator,0) <> 0 THEN

                 l_u4_tbl(i).PJI_REP_TOTAL_15     := (l_prior_sch_util_hours/l_prior_scheduled_denominator)*100;
                 l_u4_tbl(i).PJI_REP_TOTAL_16     := (l_prior_conf_billable_hours/l_prior_scheduled_denominator)*100;
                 l_u4_tbl(i).PJI_REP_TOTAL_17     := (l_prior_conf_nonbillable_hours/l_prior_scheduled_denominator)*100;

               END IF;

               IF nvl(l_exp_ac_denominator,0) <> 0 THEN
                 l_u4_tbl(i).PJI_REP_TOTAL_18     := (l_exp_ac_util_hours/l_exp_ac_denominator)*100;
               END IF;

               IF nvl(l_exp_sch_denominator,0) <> 0 THEN
                 l_u4_tbl(i).PJI_REP_TOTAL_19     := (l_exp_sch_util_hours/l_exp_sch_denominator)*100;
                 l_u4_tbl(i).PJI_REP_TOTAL_21     := (l_prov_util_hours /l_exp_sch_denominator)*100;

               END IF;

               IF nvl(l_expected_denominator,0) <> 0 THEN
                 l_u4_tbl(i).PJI_REP_TOTAL_20     := (l_expected_util_hours/l_expected_denominator)*100;
                 l_u4_tbl(i).PJI_REP_TOTAL_22     := (l_expected_total_util_hours/l_expected_denominator)*100;

               END IF;

               IF nvl(l_prior_actual_denominator,0) <> 0 THEN
                 l_u4_tbl(i).PJI_REP_TOTAL_23     := (l_prior_actual_util_hours/l_prior_actual_denominator)*100;
               END IF;

            END IF; -- l_u4_tbl.EXISTS(i)

          END LOOP;
        END IF; --l_u4_tbl.COUNT

        --Delete record for top org if all values are 0 or null

        IF l_Top_Org_Index is not null THEN
        IF  nvl(l_u4_tbl(l_Top_Org_Index).SCHEDULED_HOURS,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).SCHEDULED_CAPACITY_HOURS,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).SCHEDULED_UTIL_HOURS,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).PROVISIONAL_HOURS,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).EXPECTED_HOURS,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).EXPECTED_CAPACITY_HOURS,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).PRIOR_SCHEDULED_HOURS,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).SCH_UTIL_PERCENT,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).BILL_UTIL_PERCENT,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).NONBILL_UTIL_PERCENT,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).UNASSIGNED_PERCENT,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).TRAINING_PERCENT,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).PROV_BILL_PERCENT,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).PROV_NONBILL_PERCENT,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).PRIOR_SCH_UTIL_PERCENT,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).PRIOR_BILL_UTIL_PERCENT,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).PRIOR_NONBILL_UTIL_PERCENT,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).EXP_ACT_UTIL_PERCENT,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).EXP_SCH_UTIL_PERCENT,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).EXP_UTIL_PERCENT,0) = 0 AND
            nvl(l_u4_tbl(l_Top_Org_Index).PROV_SCH_UTIL_PERCENT,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).EXP_TOTAL_UTIL_PERCENT,0) = 0 AND
			nvl(l_u4_tbl(l_Top_Org_Index).PRIOR_ACT_UTIL_PERCENT,0) = 0
         THEN
            l_u4_tbl.DELETE(l_Top_Org_Index);
         END IF;
         END IF;

   COMMIT;
   RETURN l_u4_tbl;

END PLSQLDriver_U4;




/*****************************************************************************
 *
 * The functions for report U6: Project Actual Utilization Detail
 *
 *****************************************************************************/

PROCEDURE Get_SQL_PJI_REP_U6(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
BEGIN

    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL  => p_page_parameter_tbl
                               ,P_SELECT_LIST         =>
                               ' FACT.RESOURCE_NAME  "VIEWBY",
                                 FACT.ACTUAL_HOURS  "PJI_REP_MSR_2",
		                         FACT.CAPACITY_HOURS  "PJI_REP_MSR_3",
		                         FACT.MISSING_HOURS  "PJI_REP_MSR_4",
		                         FACT.BILLABLE_HOURS  "PJI_REP_MSR_5",
		                         FACT.NONBILLABLE_HOURS  "PJI_REP_MSR_6",
		                         FACT.TRAINING_HOURS  "PJI_REP_MSR_7",
		                         FACT.ACT_UTIL_PERCENT  "PJI_REP_MSR_8",
		                         FACT.BILL_UTIL_PERCENT  "PJI_REP_MSR_9",
		                         FACT.NONBILL_UTIL_PERCENT  "PJI_REP_MSR_10",
		                         FACT.TRAINING_PERCENT  "PJI_REP_MSR_11",
		                         FACT.ACTUAL_WEIGHTED_HOURS  "PJI_REP_MSR_20",
		                         FACT.BILLABLE_WEIGHTED_HOURS  "PJI_REP_MSR_21",
		                         FACT.UTIL_PERCENT_DENOM_HOURS  "PJI_REP_MSR_22",
		                         FACT.RESOURCE_ID  "PJI_REP_MSR_24",
                                 FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1",
		                         FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_2",
		                         FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_3",
		                         FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_4",
		                         FACT.PJI_REP_TOTAL_5 "PJI_REP_TOTAL_5",
		                         FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_6",
		                         FACT.PJI_REP_TOTAL_7 "PJI_REP_TOTAL_7",
		                         FACT.PJI_REP_TOTAL_8 "PJI_REP_TOTAL_8",
		                         FACT.PJI_REP_TOTAL_9 "PJI_REP_TOTAL_9",
		                         FACT.PJI_REP_TOTAL_10 "PJI_REP_TOTAL_10" '
                               ,P_SQL_STATEMENT       => x_PMV_Sql
                               ,P_PMV_OUTPUT          => x_PMV_Output,
                                P_REGION_CODE         => 'PJI_REP_U6',
                                P_PLSQL_DRIVER        => 'PJI_PMV_UTLZ.PLSQLDriver_PJI_REP_U6',
                                P_PLSQL_DRIVER_PARAMS =>   '<<ORGANIZATION+FII_OPERATING_UNITS>>, ' ||
                                                           '<<ORGANIZATION+PJI_ORGANIZATIONS>>, ' ||
                                                           '<<AS_OF_DATE>>, ' ||
                                                           '<<PERIOD_TYPE>>, ' ||
                                       '<<PROJECT WORK TYPE+PJI_UTIL_CATEGORIES>>, ' ||
                                       '<<PROJECT WORK TYPE+PJI_WORK_TYPES>>, ' ||
                                       '<<PROJECT JOB LEVEL+PJI_JOB_LEVELS>>, ' ||
                                       '<<VIEW_BY>>');
END Get_SQL_PJI_REP_U6;


FUNCTION PLSQLDriver_PJI_REP_U6 (
    p_operating_unit		IN VARCHAR2 DEFAULT NULL
  , p_organization		IN VARCHAR2
  , p_as_of_date		IN NUMBER
  , p_period_type 		IN VARCHAR2
  , p_util_categories 		IN VARCHAR2 DEFAULT NULL
  , p_work_type                 IN VARCHAR2 DEFAULT NULL
  , p_job_level 		IN VARCHAR2 DEFAULT NULL
  , p_view_by                   IN VARCHAR2
)RETURN PJI_REP_U6_TBL
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_u6_tbl		PJI_REP_U6_TBL:=PJI_REP_U6_TBL();
l_job_level_param               VARCHAR2(1);
l_util_categories_param         VARCHAR2(1);
l_util_percent_denom_prof       VARCHAR(25);
l_dft_util_percent_denom_prof   VARCHAR(25) := 'CAPACITY';
l_labor_unit                    VARCHAR2(40);
l_actual_hours                  NUMBER := 0;
l_capacity_hours                NUMBER := 0;
l_missing_hours                 NUMBER := 0;
l_billable_hours                NUMBER := 0;
l_nonbillable_hours             NUMBER := 0;
l_training_hours                NUMBER := 0;
l_actual_weighted_hours         NUMBER := 0;
l_billable_weighted_hours       NUMBER := 0;
l_nonbillable_weighted_hours    NUMBER := 0;
l_util_percent_denom_hours      NUMBER := 0;

BEGIN
 /*
  * Place a call to all the parse API's which parse the parameters
  * passed by PMV and populate all the temporary tables.
  */
  PJI_PMV_ENGINE.Convert_Operating_Unit(p_operating_unit, p_view_by);
  PJI_PMV_ENGINE.Convert_Organization(p_organization, p_view_by);
  PJI_PMV_ENGINE.Convert_Time(p_as_of_date, p_period_type, p_view_by);

  l_util_categories_param := PJI_PMV_ENGINE.convert_util_category(p_work_type, p_util_categories, p_view_by);
  l_job_level_param       := PJI_PMV_ENGINE.convert_job_level(null, p_job_level, p_view_by);

 /*
  * Get Utilization percentage denominator profile value
  */
  BEGIN
    SELECT fnd_profile.value('PA_ORG_UTIL_DEF_CALC_METHOD')
    INTO l_util_percent_denom_prof
    from dual;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        l_util_percent_denom_prof := l_dft_util_percent_denom_prof;
  END;

 /*
  * Get report labor unit
  */
  BEGIN
     select report_labor_units
     into l_labor_unit
     from pji_system_settings;

  EXCEPTION WHEN OTHERS THEN
         l_labor_unit := null;
  END;


 /*
  * determine the fact tables you choose to run the database query on.
  *
  * If util_categories=null and job_level=null
  */

  IF l_util_categories_param = 'N' AND l_job_level_param = 'N' THEN

     SELECT PJI_REP_U6(      resource_name
                           , resource_id
	  		               , SUM(actual_hours)
			               , SUM(capacity_hours)
                           , SUM(missing_hours)
                           , SUM(billable_hours)
                           , SUM(nonbillable_hours)
                           , SUM(training_hours)
                           , SUM(actual_weighted_hours)
                           , SUM(billable_weighted_hours)
                           , SUM(nonbillable_weighted_hours)
                           , SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',capacity_hours,actual_hours)) ,
                             null,null,null,null,null,null,
                             null,null,null,null,null,null,
                             null,null)
     /* Bug 3515594 */
     BULK COLLECT INTO l_u6_tbl
     FROM
        (
        SELECT /*+ ORDERED */
           resd.resource_name                           resource_name
          ,fct.person_id                               resource_id
          ,fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)    actual_hours
          ,(fct.capacity_hrs-NVL(fct.reduce_capacity_hrs_a,0))
              / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)                 capacity_hours
          ,fct.missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)  missing_hours
          ,fct.bill_hrs_a  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)    billable_hours
          ,(fct.total_hrs_a-bill_hrs_a)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)                  nonbillable_hours
          ,fct.training_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1) training_hours
          ,fct.total_wtd_org_hrs_a
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)                  actual_weighted_hours
          ,fct.bill_wtd_org_hrs_a
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)                  billable_weighted_hours
          ,(fct.total_wtd_org_hrs_a-fct.bill_wtd_org_hrs_a)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)                  nonbillable_weighted_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_rm_res_f         fct
          ,pji_pmv_org_dim_tmp  hou
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
           fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.id is not null
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND hou.id = imp.org_id
        UNION ALL
        SELECT
           resd.resource_name  resource_name
          ,resd.person_id      resource_id
          ,0                   actual_hours
          ,0                   capacity_hours
          ,0                   missing_hours
          ,0                   billable_hours
          ,0                   nonbillable_hours
          ,0                   training_hours
          ,0                   actual_weighted_hours
          ,0                   billable_weighted_hours
          ,0                   nonbillable_weighted_hours
        FROM
           pa_resources_denorm resd
          ,pji_pmv_orgz_dim_tmp horg
        WHERE
           resd.resource_organization_id = horg.id
           AND resd.utilization_flag = 'Y'
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
        )
     GROUP BY resource_name, resource_id;


 /*
  * If util_categories=null and job_level<>null
  */
  ELSIF l_util_categories_param = 'N' AND l_job_level_param = 'Y' THEN

     SELECT PJI_REP_U6(      resource_name
                           , resource_id
	  		               , SUM(actual_hours)
			               , SUM(capacity_hours)
                           , SUM(missing_hours)
                           , SUM(billable_hours)
                           , SUM(nonbillable_hours)
                           , SUM(training_hours)
                           , SUM(actual_weighted_hours)
                           , SUM(billable_weighted_hours)
                           , SUM(nonbillable_weighted_hours)
                           , SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',capacity_hours,actual_hours)) ,
                             null,null,null,null,null,null,
                             null,null,null,null,null,null,
                             null,null)
     /* Bug 3515594 */
     BULK COLLECT INTO l_u6_tbl
     FROM
        (
        SELECT /*+ ORDERED */
           resd.resource_name                           resource_name
          ,fct.person_id                                resource_id
          ,fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)    actual_hours
          ,(fct.capacity_hrs-NVL(fct.reduce_capacity_hrs_a,0))
              / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)                 capacity_hours
          ,fct.missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)  missing_hours
          ,fct.bill_hrs_a  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)    billable_hours
          ,(fct.total_hrs_a-bill_hrs_a)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)                  nonbillable_hours
          ,fct.training_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1) training_hours
          ,fct.total_wtd_org_hrs_a
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)                  actual_weighted_hours
          ,fct.bill_wtd_org_hrs_a
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)                  billable_weighted_hours
          ,(fct.total_wtd_org_hrs_a-fct.bill_wtd_org_hrs_a)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)                  nonbillable_weighted_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_pmv_jb_dim_tmp   jbt
          ,pji_rm_res_f         fct
          ,pji_pmv_org_dim_tmp  hou
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
               fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.id is not null
           AND fct.job_id = jbt.id
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND hou.id = imp.org_id
        UNION ALL
        SELECT
           resource_name      resource_name
          ,resd.person_id     resource_id
          ,0                  actual_hours
          ,0                  capacity_hours
          ,0                  missing_hours
          ,0                  billable_hours
          ,0                  nonbillable_hours
          ,0                  training_hours
          ,0                  actual_weighted_hours
          ,0                  billable_weighted_hours
          ,0                  nonbillable_weighted_hours
        FROM
           pa_resources_denorm   resd
          ,pji_pmv_orgz_dim_tmp  horg
          ,pji_pmv_jb_dim_tmp    jbt
        WHERE
           resd.resource_organization_id = horg.id
           AND resd.utilization_flag = 'Y'
           AND resd.job_id = jbt.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
        )
     GROUP BY resource_name, resource_id;

 /*
  * If util_categories<>null and job_level=null
  */
  ELSIF l_util_categories_param = 'Y' AND l_job_level_param = 'N' THEN

     SELECT PJI_REP_U6     ( resource_name
                           , resource_id
	  		               , SUM(actual_hours)
                           , SUM(capacity_hours-act_reduce_capacity_hours)
                           , SUM(missing_hours)
                           , SUM(billable_hours)
                           , SUM(nonbillable_hours)
                           , SUM(training_hours)
                           , SUM(actual_weighted_hours)
                           , SUM(billable_weighted_hours)
                           , SUM(nonbillable_weighted_hours)
                           , SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',capacity_hours-act_reduce_capacity_hours,
                                 actual_hours)) ,
                             null,null,null,null,null,null,
                             null,null,null,null,null,null,
                             null,null)
     /* Bug 3515594 */
     BULK COLLECT INTO l_u6_tbl
     FROM
        (
        SELECT /*+ ORDERED */
            resource_name                                                               resource_name
           ,fct.person_id                                                               resource_id
           ,fct.total_hrs_a                                                             actual_hours
           ,0                                                                           capacity_hours
           ,0                                                                           act_reduce_capacity_hours
           ,null                                                                        missing_hours
           ,fct.bill_hrs_a
              / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      billable_hours
           ,(fct.total_hrs_a-fct.bill_hrs_a)
              / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      nonbillable_hours
           ,decode(wtb.training_flag,'Y',fct.total_hrs_a, 0)
              / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      training_hours
           ,fct.total_hrs_a * (wtb.org_utilization_percentage/100)
              / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      actual_weighted_hours
           ,fct.bill_hrs_a * (wtb.org_utilization_percentage/100)
              / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      billable_weighted_hours
           ,(fct.total_hrs_a-fct.bill_hrs_a)
            *wtb.org_utilization_percentage/100 / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                        nonbillable_weighted_hours
        FROM
            pji_pmv_orgz_dim_tmp  horg
           ,pji_pmv_time_dim_tmp  time
           ,pji_pmv_wt_dim_tmp    wt
           ,pji_rm_res_wt_f       fct
           ,pji_pmv_org_dim_tmp   hou
           ,pa_work_types_b       wtb
           ,pa_resources_denorm   resd
           ,pa_implementations_all imp
        WHERE
            fct.expenditure_org_id = hou.id
            AND fct.expenditure_organization_id = horg.id
            AND fct.time_id = time.id
            AND fct.period_type_id = time.period_type
            AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
            AND time.id is not null
            AND fct.work_type_id = wt.id
            AND wtb.work_type_id = wt.id
            AND fct.person_id = resd.person_id
            AND resd.resource_organization_id = horg.id
            AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
                resd.resource_effective_end_date
            AND hou.id = imp.org_id
        UNION ALL
        SELECT
           resource_name      resource_name
          ,resd.person_id     resource_id
          ,0                  actual_hours
          ,0                  capacity_hours
          ,0                  act_reduce_capacity_hours
          ,null               missing_hours
          ,0                  billable_hours
          ,0                  nonbillable_hours
          ,0                  training_hours
          ,0                  actual_weighted_hours
          ,0                  billable_weighted_hours
          ,0                  nonbillable_weighted_hours
        FROM
           pa_resources_denorm resd
          ,pji_pmv_orgz_dim_tmp horg
        WHERE
           resd.resource_organization_id = horg.id
           AND resd.utilization_flag = 'Y'
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date

        UNION ALL  -- added for current year capacity_hours
        SELECT  /*+ ORDERED */
           resource_name      resource_name
          ,resd.person_id     resource_id
          ,0                  actual_hours
          ,capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                              capacity_hours
          ,reduce_capacity_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                              act_reduce_capacity_hours
          ,missing_hrs_a      missing_hours
          ,0                  billable_hours
          ,0                  nonbillable_hours
          ,0                  training_hours
          ,0                  actual_weighted_hours
          ,0                  billable_weighted_hours
          ,0                  nonbillable_weighted_hours
        FROM
            pji_pmv_orgz_dim_tmp  horg
           ,pji_pmv_time_dim_tmp  time
           ,pji_rm_res_f          fct
           ,pji_pmv_org_dim_tmp   hou
           ,pa_resources_denorm   resd
           ,pa_implementations_all imp
        WHERE
            fct.expenditure_org_id = hou.id
            AND fct.expenditure_organization_id = horg.id
            AND fct.time_id = time.id
            AND fct.period_type_id = time.period_type
            AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
            AND time.id is not null
            AND fct.person_id = resd.person_id
            AND resd.resource_organization_id = horg.id
            AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
                resd.resource_effective_end_date
            AND hou.id = imp.org_id
        )
     GROUP BY resource_name, resource_id;

 /*
  * If util_categories<>null and job_level<>null
  */
  ELSIF l_util_categories_param = 'Y' AND l_job_level_param = 'Y' THEN

     SELECT PJI_REP_U6     ( resource_name
                           , resource_id
	  		   , SUM(actual_hours)
                           , SUM(capacity_hours-act_reduce_capacity_hours)
                           , SUM(missing_hours)
                           , SUM(billable_hours)
                           , SUM(nonbillable_hours)
                           , SUM(training_hours)
                           , SUM(actual_weighted_hours)
                           , SUM(billable_weighted_hours)
                           , SUM(nonbillable_weighted_hours)
                           , SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',capacity_hours-act_reduce_capacity_hours,
                                 actual_hours)) ,
                             null,null,null,null,null,null,
                             null,null,null,null,null,null,
                             null,null)
     /* Bug 3515594 */
     BULK COLLECT INTO l_u6_tbl
     FROM
        (
        SELECT /*+ ORDERED */
            resd.resource_name                                                         resource_name
           ,fct.person_id                                                              resource_id
           ,fct.total_hrs_a                                                            actual_hours
           ,0                                                                          capacity_hours
           ,0                                                                          act_reduce_capacity_hours
           ,null                                                                       missing_hours
           ,fct.bill_hrs_a
              / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     billable_hours
           ,(fct.total_hrs_a - fct.bill_hrs_a)
              / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     nonbillable_hours
           ,decode(wtb.training_flag,'Y',fct.total_hrs_a, 0)
              / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     training_hours
           ,fct.total_hrs_a * (wtb.org_utilization_percentage/100)
              / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     actual_weighted_hours
           ,fct.bill_hrs_a * (wtb.org_utilization_percentage/100)
              / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     billable_weighted_hours
           ,(fct.total_hrs_a - fct.bill_hrs_a)
            *wtb.org_utilization_percentage/100 / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       nonbillable_weighted_hours
        FROM
            pji_pmv_orgz_dim_tmp  horg
           ,pji_pmv_time_dim_tmp  time
           ,pji_pmv_wt_dim_tmp    wt
           ,pji_rm_res_wt_f       fct
           ,pji_pmv_jb_dim_tmp    jbt
           ,pji_pmv_org_dim_tmp   hou
           ,pa_work_types_b       wtb
           ,pa_resources_denorm   resd
           ,pa_implementations_all imp
        WHERE
            fct.expenditure_org_id = hou.id
            AND fct.expenditure_organization_id = horg.id
            AND fct.time_id = time.id
            AND fct.period_type_id = time.period_type
            AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
            AND time.id is not null
            AND fct.work_type_id = wt.id
            AND wtb.work_type_id = wt.id
            AND fct.job_id = jbt.id
            AND fct.person_id = resd.person_id
            AND resd.resource_organization_id = horg.id
            AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
                resd.resource_effective_end_date
            AND hou.id = imp.org_id
        UNION ALL
        SELECT
           resd.resource_name resource_name
          ,resd.person_id     resource_id
          ,0                  actual_hours
          ,0                  capacity_hours
          ,0                  act_reduce_capacity_hours
          ,null               missing_hours
          ,0                  billable_hours
          ,0                  nonbillable_hours
          ,0                  training_hours
          ,0                  actual_weighted_hours
          ,0                  billable_weighted_hours
          ,0                  nonbillable_weighted_hours
        FROM
           pa_resources_denorm   resd
          ,pji_pmv_orgz_dim_tmp  horg
          ,pji_pmv_jb_dim_tmp    jbt
        WHERE
           resd.resource_organization_id = horg.id
           AND resd.utilization_flag = 'Y'
           AND resd.job_id = jbt.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
        UNION ALL  -- added for current year capacity_hours
	/* Bug 3515594 */
        SELECT  /*+ ORDERED */
           resource_name      resource_name
          ,resd.person_id     resource_id
          ,0                  actual_hours
          ,capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                              capacity_hours
          ,reduce_capacity_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                              act_reduce_capacity_hours
          ,missing_hrs_a      missing_hours
          ,0                  billable_hours
          ,0                  nonbillable_hours
          ,0                  training_hours
          ,0                  actual_weighted_hours
          ,0                  billable_weighted_hours
          ,0                  nonbillable_weighted_hours
        FROM
            pji_pmv_orgz_dim_tmp  horg
           ,pji_pmv_time_dim_tmp  time
           ,pji_pmv_jb_dim_tmp    jbt
           ,pji_rm_res_f          fct
           ,pji_pmv_org_dim_tmp   hou
           ,pa_resources_denorm   resd
           ,pa_implementations_all imp
        WHERE
            fct.expenditure_org_id = hou.id
            AND fct.expenditure_organization_id = horg.id
            AND fct.time_id = time.id
            AND fct.period_type_id = time.period_type
            AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
            AND time.id is not null
            AND fct.person_id = resd.person_id
            AND fct.job_id = jbt.id
            AND resd.resource_organization_id = horg.id
            AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
                resd.resource_effective_end_date
            AND hou.id = imp.org_id
        )
     GROUP BY resource_name, resource_id;

  END IF;

  FOR i in 1..l_u6_tbl.COUNT
       LOOP

         l_actual_hours               := l_actual_hours                      + nvl(l_u6_tbl(i).actual_hours               ,0);
         l_capacity_hours             := l_capacity_hours                    + nvl(l_u6_tbl(i).capacity_hours             ,0);
         l_missing_hours              := l_missing_hours                     + nvl(l_u6_tbl(i).missing_hours              ,0);
         l_billable_hours             := l_billable_hours                    + nvl(l_u6_tbl(i).billable_hours             ,0);
         l_nonbillable_hours          := l_nonbillable_hours                 + nvl(l_u6_tbl(i).nonbillable_hours          ,0);
         l_training_hours             := l_training_hours                    + nvl(l_u6_tbl(i).training_hours             ,0);
         l_actual_weighted_hours      := l_actual_weighted_hours             + nvl(l_u6_tbl(i).actual_weighted_hours      ,0);
         l_billable_weighted_hours    := l_billable_weighted_hours           + nvl(l_u6_tbl(i).billable_weighted_hours    ,0);
         l_nonbillable_weighted_hours := l_nonbillable_weighted_hours        + nvl(l_u6_tbl(i).nonbillable_weighted_hours ,0);
         l_util_percent_denom_hours   := l_util_percent_denom_hours          + nvl(l_u6_tbl(i).util_percent_denom_hours   ,0);


         --Calculated columns processing is done below
         IF nvl(l_u6_tbl(i).util_percent_denom_hours,0) <> 0 THEN
           l_u6_tbl(i).act_util_percent     := 100 * (l_u6_tbl(i).actual_weighted_hours / l_u6_tbl(i).util_percent_denom_hours);
           l_u6_tbl(i).bill_util_percent    := 100 * (l_u6_tbl(i).billable_weighted_hours / l_u6_tbl(i).util_percent_denom_hours);
           l_u6_tbl(i).nonbill_util_percent := 100 * (l_u6_tbl(i).nonbillable_weighted_hours / l_u6_tbl(i).util_percent_denom_hours);
           l_u6_tbl(i).training_percent     := 100 * (l_u6_tbl(i).training_hours / l_u6_tbl(i).util_percent_denom_hours);

         ELSE
           l_u6_tbl(i).act_util_percent     := NULL;
		   l_u6_tbl(i).bill_util_percent    := NULL;
		   l_u6_tbl(i).nonbill_util_percent := NULL;
           l_u6_tbl(i).training_percent     := NULL;
         END IF;

   END LOOP;

   IF l_u6_tbl.COUNT > 0 THEN
   FOR i IN 1..l_u6_tbl.COUNT
	LOOP

      IF l_u6_tbl.EXISTS(i) THEN

        l_u6_tbl(i).PJI_REP_TOTAL_1 := l_actual_hours     ;
        l_u6_tbl(i).PJI_REP_TOTAL_2 := l_capacity_hours   ;
        l_u6_tbl(i).PJI_REP_TOTAL_3 := l_missing_hours    ;
        l_u6_tbl(i).PJI_REP_TOTAL_4 := l_billable_hours   ;
        l_u6_tbl(i).PJI_REP_TOTAL_5 := l_nonbillable_hours;
        l_u6_tbl(i).PJI_REP_TOTAL_6 := l_training_hours   ;


        IF nvl(l_util_percent_denom_hours,0) <> 0 THEN

          l_u6_tbl(i).PJI_REP_TOTAL_7      := (l_actual_weighted_hours/l_util_percent_denom_hours)*100;
          l_u6_tbl(i).PJI_REP_TOTAL_8      := (l_billable_weighted_hours/l_util_percent_denom_hours)*100;
          l_u6_tbl(i).PJI_REP_TOTAL_9      := (l_nonbillable_weighted_hours/l_util_percent_denom_hours)*100;
          l_u6_tbl(i).PJI_REP_TOTAL_10      := (l_training_hours/l_util_percent_denom_hours)*100;

        END IF;

      END IF; -- l_u6_tbl.EXISTS(i)
	END LOOP;
    END IF; --l_u6_tbl.COUNT > 0


 /*
  * Return the bulk collected table back to pmv.
  */
  COMMIT;
  RETURN l_u6_tbl;

END PLSQLDriver_PJI_REP_U6;



/*****************************************************************************
 *
 * The functions for report U7: Project Scheduled Utilization Detail
 *
 *****************************************************************************/
PROCEDURE Get_SQL_PJI_REP_U7(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
BEGIN

    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL  => p_page_parameter_tbl
                               ,P_SELECT_LIST         =>
                               ' FACT.RESOURCE_NAME  "VIEWBY",
                                 FACT.SCHEDULED_HOURS  "PJI_REP_MSR_2",
                                 FACT.CAPACITY_HOURS  "PJI_REP_MSR_3",
                                 FACT.CONFIRMED_BILLABLE_HOURS  "PJI_REP_MSR_4",
                                 FACT.CONFIRMED_NONBILLABLE_HOURS  "PJI_REP_MSR_5",
                                 FACT.PROVISIONAL_BILLABLE_HOURS  "PJI_REP_MSR_6",
                                 FACT.PROVISIONAL_NONBILLABLE_HOURS  "PJI_REP_MSR_7",
                                 FACT.TRAINING_HOURS  "PJI_REP_MSR_12",
                                 FACT.SCH_UTIL_PERCENT  "PJI_REP_MSR_8",
                                 FACT.BILL_UTIL_PERCENT  "PJI_REP_MSR_9",
                                 FACT.NONBILL_UTIL_PERCENT  "PJI_REP_MSR_10",
                                 FACT.UNASSIGNED_PERCENT  "PJI_REP_MSR_13",
                                 FACT.TRAINING_PERCENT  "PJI_REP_MSR_11",
                                 FACT.CONFIRMED_WEIGHTED_HOURS  "PJI_REP_MSR_20",
                                 FACT.BILLABLE_CONF_WEIGHTED_HOURS  "PJI_REP_MSR_21",
                                 FACT.UTIL_PERCENT_DENOM_HOURS  "PJI_REP_MSR_22",
                                 FACT.UNASSIGNED_HOURS  "PJI_REP_MSR_23",
                                 FACT.RESOURCE_ID  "PJI_REP_MSR_24",
                                 FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1",
                                 FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_2",
                                 FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_3",
                                 FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_4",
                                 FACT.PJI_REP_TOTAL_5 "PJI_REP_TOTAL_5",
                                 FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_6",
                                 FACT.PJI_REP_TOTAL_7 "PJI_REP_TOTAL_7",
                                 FACT.PJI_REP_TOTAL_8 "PJI_REP_TOTAL_8",
                                 FACT.PJI_REP_TOTAL_9 "PJI_REP_TOTAL_9",
                                 FACT.PJI_REP_TOTAL_10 "PJI_REP_TOTAL_10",
                                 FACT.PJI_REP_TOTAL_11 "PJI_REP_TOTAL_11",
                                 FACT.PJI_REP_TOTAL_12 "PJI_REP_TOTAL_12" '
                               ,P_SQL_STATEMENT       => x_PMV_Sql
                               ,P_PMV_OUTPUT          => x_PMV_Output,
                                P_REGION_CODE         => 'PJI_REP_U7',
                                P_PLSQL_DRIVER        => 'PJI_PMV_UTLZ.PLSQLDriver_PJI_REP_U7',
                                P_PLSQL_DRIVER_PARAMS =>   '<<ORGANIZATION+FII_OPERATING_UNITS>>, ' ||
                                                           '<<ORGANIZATION+PJI_ORGANIZATIONS>>, ' ||
                                                           '<<AS_OF_DATE>>, ' ||
                                                           '<<PERIOD_TYPE>>, ' ||
                                       '<<PROJECT WORK TYPE+PJI_UTIL_CATEGORIES>>, ' ||
                                       '<<PROJECT WORK TYPE+PJI_WORK_TYPES>>, ' ||
                                       '<<PROJECT JOB LEVEL+PJI_JOB_LEVELS>>, ' ||
                                       '<<VIEW_BY>>');
END Get_SQL_PJI_REP_U7;


FUNCTION PLSQLDriver_PJI_REP_U7 (
    p_operating_unit		IN VARCHAR2 DEFAULT NULL
  , p_organization		    IN VARCHAR2
  , p_as_of_date		    IN NUMBER
  , p_period_type 		    IN VARCHAR2
  , p_util_categories 		IN VARCHAR2 DEFAULT NULL
  , p_work_type             IN VARCHAR2 DEFAULT NULL
  , p_job_level 		    IN VARCHAR2 DEFAULT NULL
  , p_view_by               IN VARCHAR2
)RETURN PJI_REP_U7_TBL
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_u7_tbl		PJI_REP_U7_TBL:=PJI_REP_U7_TBL();
l_job_level_param               VARCHAR2(1);
l_util_categories_param         VARCHAR2(1);
l_util_percent_denom_prof       VARCHAR(25);
l_dft_util_percent_denom_prof   VARCHAR(25) := 'CAPACITY';
l_labor_unit                    VARCHAR2(40);
l_scheduled_hours               NUMBER := 0;
l_capacity_hours                NUMBER := 0;
l_confirmed_billable_hours      NUMBER := 0;
l_confirmed_nonbillable_hours   NUMBER := 0;
l_provisional_billable_hours    NUMBER := 0;
l_prov_nonbillable_hours NUMBER := 0;
l_training_hours                NUMBER := 0;
l_confirmed_weighted_hours      NUMBER := 0;
l_billable_conf_weighted_hours  NUMBER := 0;
l_unassigned_hours              NUMBER := 0;
l_util_percent_denom_hours      NUMBER := 0;

BEGIN
 /*
  * Place a call to all the parse API's which parse the parameters
  * passed by PMV and populate all the temporary tables.
  */
  PJI_PMV_ENGINE.Convert_Operating_Unit(p_operating_unit, p_view_by);
  PJI_PMV_ENGINE.Convert_Organization(p_organization, p_view_by);
  PJI_PMV_ENGINE.Convert_Time(p_as_of_date, p_period_type, p_view_by);

  l_util_categories_param := PJI_PMV_ENGINE.convert_util_category(p_work_type, p_util_categories, p_view_by);
  l_job_level_param       := PJI_PMV_ENGINE.convert_job_level(null, p_job_level, p_view_by);


 /*
  * Get Utilization percentage denominator profile value
  */
  BEGIN
    SELECT fnd_profile.value('PA_ORG_UTIL_DEF_CALC_METHOD')
    INTO l_util_percent_denom_prof
    from dual;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        l_util_percent_denom_prof := l_dft_util_percent_denom_prof;
  END;


 /*
  * Get report labor unit
  */
  BEGIN
     select report_labor_units
     into l_labor_unit
     from pji_system_settings;

  EXCEPTION WHEN OTHERS THEN
         l_labor_unit := null;
  END;

 -- insert into pji_pmv_generated_sql values('PLSQLDriver_PJI_REP_U7 1');
 -- commit;

 /*
  * determine the fact tables you choose to run the database query on.
  *
  * If util_categories=null and job_level=null
  */

  IF l_util_categories_param = 'N' AND l_job_level_param = 'N' THEN
     SELECT PJI_REP_U7(      resource_name
                           , resource_id
	  		               , SUM(scheduled_hours)
			               , SUM(capacity_hours)
                           , SUM(confirmed_billable_hours)
                           , SUM(confirmed_nonbillable_hours)
                           , SUM(provisional_billable_hours)
                           , SUM(provisional_nonbillable_hours)
                           , SUM(training_hours)
                           , SUM(confirmed_weighted_hours)
                           , SUM(billable_conf_weighted_hours)
                           , SUM(unassigned_hours)
                           , SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',
                                 capacity_hours,actual_hours)),
                              null,null,null,null,null,null,
                              null,null,null,null,null,null,
                              null,null,null,null,null)
     /* Bug 3515594 */
     BULK COLLECT INTO l_u7_tbl
     FROM
        (
        SELECT /*+ ORDERED */
           resd.resource_name                      resource_name
          ,fct.person_id                          resource_id
          ,fct.conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)    scheduled_hours
          ,(fct.capacity_hrs-NVL(fct.reduce_capacity_hrs_s,0))
               / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)         capacity_hours
          ,fct.conf_bill_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                            confirmed_billable_hours
          ,(fct.conf_hrs_s-conf_bill_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                            confirmed_nonbillable_hours
          ,fct.prov_bill_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                            provisional_billable_hours
          ,(fct.prov_hrs_s-fct.prov_bill_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                            provisional_nonbillable_hours
          ,fct.training_hrs_s  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)  training_hours
          ,fct.conf_wtd_org_hrs_s  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                            confirmed_weighted_hours
          ,fct.conf_bill_wtd_org_hrs_s  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                            billable_conf_weighted_hours
          ,fct.unassigned_hrs_s  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)  unassigned_hours
          ,fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)        actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_rm_res_f         fct
          ,pji_pmv_org_dim_tmp  hou
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
           fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.id is not null
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND hou.id = imp.org_id
        UNION ALL
        SELECT
           resd.resource_name  resource_name
          ,resd.person_id      resource_id
          ,0                   scheduled_hours
          ,0                   capacity_hours
          ,0                   confirmed_billable_hours
          ,0                   confirmed_nonbillable_hours
          ,0                   provisional_billable_hours
          ,0                   provisional_nonbillable_hours
          ,0                   training_hours
          ,0                   confirmed_weighted_hours
          ,0                   billable_conf_weighted_hours
          ,0                   unassigned_hours
          ,0                   actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pa_resources_denorm resd
        WHERE
           resd.resource_organization_id = horg.id
           AND resd.utilization_flag = 'Y'
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
        )
     GROUP BY resource_name, resource_id;

 /*
  * If util_categories=null and job_level<>null
  */
  ELSIF l_util_categories_param = 'N' AND l_job_level_param = 'Y' THEN
     SELECT PJI_REP_U7(      resource_name
                           , resource_id
	  		               , SUM(scheduled_hours)
			               , SUM(capacity_hours)
                           , SUM(confirmed_billable_hours)
                           , SUM(confirmed_nonbillable_hours)
                           , SUM(provisional_billable_hours)
                           , SUM(provisional_nonbillable_hours)
                           , SUM(training_hours)
                           , SUM(confirmed_weighted_hours)
                           , SUM(billable_conf_weighted_hours)
                           , SUM(unassigned_hours)
                           , SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',capacity_hours,
                             actual_hours)) ,
                              null,null,null,null,null,null,
                              null,null,null,null,null,null,
                              null,null,null,null,null)
     /* Bug 3515594 */
     BULK COLLECT INTO l_u7_tbl
     FROM
        (
        SELECT /*+ ORDERED */
           resd.resource_name                      resource_name
          ,fct.person_id                          resource_id
          ,fct.conf_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)    scheduled_hours
          ,(fct.capacity_hrs-NVL(fct.reduce_capacity_hrs_s,0))
               / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)         capacity_hours
          ,fct.conf_bill_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                            confirmed_billable_hours
          ,(fct.conf_hrs_s-conf_bill_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                            confirmed_nonbillable_hours
          ,fct.prov_bill_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                            provisional_billable_hours
          ,(fct.prov_hrs_s-fct.prov_bill_hrs_s) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                            provisional_nonbillable_hours
          ,fct.training_hrs_s  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)  training_hours
          ,fct.conf_wtd_org_hrs_s  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                            confirmed_weighted_hours
          ,fct.conf_bill_wtd_org_hrs_s  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                            billable_conf_weighted_hours
          ,fct.unassigned_hrs_s  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)  unassigned_hours
          ,fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)        actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_pmv_jb_dim_tmp   jbt
          ,pji_rm_res_f         fct
          ,pji_pmv_org_dim_tmp  hou
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
               fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.id is not null
           AND fct.job_id = jbt.id
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND hou.id = imp.org_id
        UNION ALL
        SELECT
           resd.resource_name resource_name
          ,resd.person_id     resource_id
          ,0                  scheduled_hours
          ,0                  capacity_hours
          ,0                  confirmed_billable_hours
          ,0                  confirmed_nonbillable_hours
          ,0                  provisional_billable_hours
          ,0                  provisional_nonbillable_hours
          ,0                  training_hours
          ,0                  confirmed_weighted_hours
          ,0                  billable_conf_weighted_hours
          ,0                  unassigned_hours
          ,0                  actual_hours
        FROM
           pji_pmv_orgz_dim_tmp  horg
          ,pji_pmv_jb_dim_tmp    jbt
          ,pa_resources_denorm   resd
        WHERE
               resd.resource_organization_id = horg.id
           AND resd.utilization_flag = 'Y'
           AND resd.job_id = jbt.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
        )
     GROUP BY resource_name, resource_id;

 /*
  * If util_categories<>null and job_level=null
  */
  ELSIF l_util_categories_param = 'Y' AND l_job_level_param = 'N' THEN
     SELECT PJI_REP_U7(      resource_name
                           , resource_id
	  		               , SUM(scheduled_hours)
                           , SUM(capacity_hours-sch_reduce_capacity_hours)
                           , SUM(confirmed_billable_hours)
                           , SUM(confirmed_nonbillable_hours)
                           , SUM(provisional_billable_hours)
                           , SUM(provisional_nonbillable_hours)
                           , SUM(training_hours)
                           , SUM(confirmed_weighted_hours)
                           , SUM(billable_conf_weighted_hours)
                           , SUM(unassigned_hours)
                           , SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',capacity_hours-sch_reduce_capacity_hours,
                                 actual_hours)) ,
                              null,null,null,null,null,null,
                              null,null,null,null,null,null,
                              null,null,null,null,null)
     /* Bug 3515594 */
     BULK COLLECT INTO l_u7_tbl
     FROM
        (
        SELECT /*+ ORDERED */
           resd.resource_name                      resource_name
          ,fct.person_id                           resource_id
          ,fct.conf_hrs_s                          scheduled_hours
          ,0                                                                         capacity_hours
          ,0                                                                         sch_reduce_capacity_hours
          ,decode(wtb.billable_capitalizable_flag,'Y',fct.conf_hrs_s, 0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     confirmed_billable_hours
          ,(fct.conf_hrs_s-decode(wtb.billable_capitalizable_flag,'Y',fct.conf_hrs_s, 0))
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     confirmed_nonbillable_hours
          ,decode(wtb.billable_capitalizable_flag,'Y',prov_hrs_s,0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     provisional_billable_hours
          ,(prov_hrs_s-decode(wtb.billable_capitalizable_flag,'Y',prov_hrs_s,0))
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     provisional_nonbillable_hours
          ,decode(wtb.training_flag,'Y',fct.conf_hrs_s, 0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     training_hours
          ,fct.conf_hrs_s * wtb.org_utilization_percentage/100
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     confirmed_weighted_hours
          ,decode(wtb.billable_capitalizable_flag,'Y',fct.conf_hrs_s, 0)*wtb.org_utilization_percentage/100
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     billable_conf_weighted_hours
          ,unassigned_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                      unassigned_hours
          ,fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)  actual_hours
        FROM
            pji_pmv_orgz_dim_tmp  horg
           ,pji_pmv_time_dim_tmp  time
           ,pji_pmv_wt_dim_tmp    wt
           ,pji_rm_res_wt_f       fct
           ,pji_pmv_org_dim_tmp   hou
           ,pa_work_types_b       wtb
           ,pa_resources_denorm   resd
           ,pa_implementations_all imp
        WHERE
            fct.expenditure_org_id = hou.id
            AND fct.expenditure_organization_id = horg.id
            AND fct.time_id = time.id
            AND fct.period_type_id = time.period_type
            AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
            AND time.id is not null
            AND fct.work_type_id = wt.id
            AND wtb.work_type_id = wt.id
            AND fct.person_id = resd.person_id
            AND resd.resource_organization_id = horg.id
            AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
                resd.resource_effective_end_date
            AND hou.id = imp.org_id
        UNION ALL
        SELECT
           resd.resource_name  resource_name
          ,resd.person_id      resource_id
          ,0                   scheduled_hours
          ,0                   capacity_hours
          ,0                   sch_reduce_capacity_hours
          ,0                   confirmed_billable_hours
          ,0                   confirmed_nonbillable_hours
          ,0                   provisional_billable_hours
          ,0                   provisional_nonbillable_hours
          ,0                   training_hours
          ,0                   confirmed_weighted_hours
          ,0                   billable_conf_weighted_hours
          ,0                   unassigned_hours
          ,0                   actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pa_resources_denorm resd
        WHERE
           resd.resource_organization_id = horg.id
           AND resd.utilization_flag = 'Y'
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date

        UNION ALL   -- added for current year capacity_hours
	/* Bug 3515594 */
        SELECT  /*+ ORDERED */
           resd.resource_name  resource_name
          ,resd.person_id      resource_id
          ,0                   scheduled_hours
          ,capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                               capacity_hours
          ,reduce_capacity_hrs_s / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                               sch_reduce_capacity_hours
          ,0                   confirmed_billable_hours
          ,0                   confirmed_nonbillable_hours
          ,0                   provisional_billable_hours
          ,0                   provisional_nonbillable_hours
          ,0                   training_hours
          ,0                   confirmed_weighted_hours
          ,0                   billable_conf_weighted_hours
          ,0                   unassigned_hours
          ,0                   actual_hours
        FROM
            pji_pmv_orgz_dim_tmp  horg
           ,pji_pmv_time_dim_tmp  time
           ,pji_rm_res_f          fct
           ,pji_pmv_org_dim_tmp   hou
           ,pa_resources_denorm   resd
           ,pa_implementations_all imp
        WHERE
            fct.expenditure_org_id = hou.id
            AND fct.expenditure_organization_id = horg.id
            AND fct.time_id = time.id
            AND fct.period_type_id = time.period_type
            AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
            AND time.id is not null
            AND fct.person_id = resd.person_id
            AND resd.resource_organization_id = horg.id
            AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
            resd.resource_effective_end_date
            AND hou.id = imp.org_id
        )
     GROUP BY resource_name, resource_id;

 /*
  * If util_categories<>null and job_level<>null
  */
  ELSIF l_util_categories_param = 'Y' AND l_job_level_param = 'Y' THEN
     SELECT PJI_REP_U7(      resource_name
                           , resource_id
	  		               , SUM(scheduled_hours)
                           , SUM(capacity_hours-sch_reduce_capacity_hours)
                           , SUM(confirmed_billable_hours)
                           , SUM(confirmed_nonbillable_hours)
                           , SUM(provisional_billable_hours)
                           , SUM(provisional_nonbillable_hours)
                           , SUM(training_hours)
                           , SUM(confirmed_weighted_hours)
                           , SUM(billable_conf_weighted_hours)
                           , SUM(unassigned_hours)
                           , SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',capacity_hours-sch_reduce_capacity_hours,
                                 actual_hours)) ,
                              null,null,null,null,null,null,
                              null,null,null,null,null,null,
                              null,null,null,null,null)
     /* Bug 3515594 */
     BULK COLLECT INTO l_u7_tbl
     FROM
        (
        SELECT /*+ ORDERED */
           resd.resource_name                      resource_name
          ,fct.person_id                           resource_id
          ,fct.conf_hrs_s                          scheduled_hours
          ,0                                                                           capacity_hours
          ,0                                                                           sch_reduce_capacity_hours
          ,decode(wtb.billable_capitalizable_flag,'Y',fct.conf_hrs_s, 0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      confirmed_billable_hours
          ,(fct.conf_hrs_s-decode(wtb.billable_capitalizable_flag,'Y',fct.conf_hrs_s, 0))
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      confirmed_nonbillable_hours
          ,decode(wtb.billable_capitalizable_flag,'Y',prov_hrs_s,0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      provisional_billable_hours
          ,(prov_hrs_s-decode(wtb.billable_capitalizable_flag,'Y',prov_hrs_s,0))
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      provisional_nonbillable_hours
          ,decode(wtb.training_flag,'Y',fct.conf_hrs_s, 0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      training_hours
          ,fct.conf_hrs_s * wtb.org_utilization_percentage/100
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      confirmed_weighted_hours
          ,decode(wtb.billable_capitalizable_flag,'Y',fct.conf_hrs_s, 0)*wtb.org_utilization_percentage/100
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      billable_conf_weighted_hours
          ,unassigned_hrs_s * decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       unassigned_hours
          ,fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)  actual_hours
        FROM
            pji_pmv_orgz_dim_tmp  horg
           ,pji_pmv_time_dim_tmp  time
           ,pji_pmv_wt_dim_tmp    wt
           ,pji_rm_res_wt_f       fct
           ,pji_pmv_jb_dim_tmp    jbt
           ,pji_pmv_org_dim_tmp   hou
           ,pa_work_types_b       wtb
           ,pa_resources_denorm   resd
           ,pa_implementations_all imp
        WHERE
            fct.expenditure_org_id = hou.id
            AND fct.expenditure_organization_id = horg.id
            AND fct.time_id = time.id
            AND fct.period_type_id = time.period_type
            AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
            AND time.id is not null
            AND fct.work_type_id = wt.id
            AND wtb.work_type_id = wt.id
            AND fct.job_id = jbt.id
            AND fct.person_id = resd.person_id
            AND resd.resource_organization_id = horg.id
            AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
                resd.resource_effective_end_date
            AND hou.id = imp.org_id
        UNION ALL
        SELECT
           resd.resource_name  resource_name
          ,resd.person_id      resource_id
          ,0                   scheduled_hours
          ,0                   capacity_hours
          ,0                   sch_reduce_capacity_hours
          ,0                   confirmed_billable_hours
          ,0                   confirmed_nonbillable_hours
          ,0                   provisional_billable_hours
          ,0                   provisional_nonbillable_hours
          ,0                   training_hours
          ,0                   confirmed_weighted_hours
          ,0                   billable_conf_weighted_hours
          ,0                   unassigned_hours
          ,0                   actual_hours
        FROM
           pji_pmv_orgz_dim_tmp  horg
          ,pji_pmv_jb_dim_tmp    jbt
          ,pa_resources_denorm   resd
        WHERE
           resd.resource_organization_id = horg.id
           AND resd.utilization_flag = 'Y'
           AND resd.job_id = jbt.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
        UNION ALL   -- added for current year capacity_hours
	/* Bug 3515594 */
        SELECT   /*+ ORDERED */
           resd.resource_name  resource_name
          ,resd.person_id      resource_id
          ,0                   scheduled_hours
          ,capacity_hrs * decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                               capacity_hours
          ,reduce_capacity_hrs_s * decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                               sch_reduce_capacity_hours
          ,0                   confirmed_billable_hours
          ,0                   confirmed_nonbillable_hours
          ,0                   provisional_billable_hours
          ,0                   provisional_nonbillable_hours
          ,0                   training_hours
          ,0                   confirmed_weighted_hours
          ,0                   billable_conf_weighted_hours
          ,0                   unassigned_hours
          ,0                   actual_hours
        FROM
            pji_pmv_orgz_dim_tmp  horg
           ,pji_pmv_time_dim_tmp  time
           ,pji_pmv_jb_dim_tmp    jbt
           ,pji_rm_res_f          fct
           ,pji_pmv_org_dim_tmp   hou
           ,pa_resources_denorm   resd
           ,pa_implementations_all imp
        WHERE
            fct.expenditure_org_id = hou.id
            AND fct.expenditure_organization_id = horg.id
            AND fct.time_id = time.id
            AND fct.period_type_id = time.period_type
            AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
            AND time.id is not null
            AND fct.job_id = jbt.id
            AND fct.person_id = resd.person_id
            AND resd.resource_organization_id = horg.id
            AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
                resd.resource_effective_end_date
            AND hou.id = imp.org_id
        )
     GROUP BY resource_name, resource_id;
  END IF;

  FOR i in 1..l_u7_tbl.COUNT
       LOOP

         l_scheduled_hours             := l_scheduled_hours                   + nvl(l_u7_tbl(i).scheduled_hours            ,0);
         l_capacity_hours              := l_capacity_hours                    + nvl(l_u7_tbl(i).capacity_hours             ,0);
         l_confirmed_billable_hours    := l_confirmed_billable_hours          + nvl(l_u7_tbl(i).confirmed_billable_hours   ,0);
         l_confirmed_nonbillable_hours := l_confirmed_nonbillable_hours       + nvl(l_u7_tbl(i).confirmed_nonbillable_hours,0);
         l_provisional_billable_hours  := l_provisional_billable_hours        + nvl(l_u7_tbl(i).provisional_billable_hours,0);
         l_prov_nonbillable_hours := l_prov_nonbillable_hours   + nvl(l_u7_tbl(i).provisional_nonbillable_hours,0);
         l_training_hours              := l_training_hours                    + nvl(l_u7_tbl(i).training_hours             ,0);
         l_confirmed_weighted_hours    := l_confirmed_weighted_hours          + nvl(l_u7_tbl(i).confirmed_weighted_hours   ,0);
         l_billable_conf_weighted_hours := l_billable_conf_weighted_hours     + nvl(l_u7_tbl(i).billable_conf_weighted_hours,0);
         l_unassigned_hours            := l_unassigned_hours                  + nvl(l_u7_tbl(i).unassigned_hours           ,0);
         l_util_percent_denom_hours    := l_util_percent_denom_hours          + nvl(l_u7_tbl(i).util_percent_denom_hours   ,0);

         --Calculated columns processing is done below
         IF nvl(l_u7_tbl(i).util_percent_denom_hours,0) <> 0 THEN
           l_u7_tbl(i).sch_util_percent     := 100 * (l_u7_tbl(i).confirmed_weighted_hours / l_u7_tbl(i).util_percent_denom_hours);
           l_u7_tbl(i).bill_util_percent    := 100 * (l_u7_tbl(i).billable_conf_weighted_hours / l_u7_tbl(i).util_percent_denom_hours);
           l_u7_tbl(i).nonbill_util_percent := 100 * ((l_u7_tbl(i).confirmed_weighted_hours - l_u7_tbl(i).billable_conf_weighted_hours)/ l_u7_tbl(i).util_percent_denom_hours);
           l_u7_tbl(i).unassigned_percent := 100 * (l_u7_tbl(i).unassigned_hours / l_u7_tbl(i).util_percent_denom_hours);
           l_u7_tbl(i).training_percent     := 100 * (l_u7_tbl(i).training_hours / l_u7_tbl(i).util_percent_denom_hours);

         ELSE
           l_u7_tbl(i).sch_util_percent     := NULL;
		   l_u7_tbl(i).bill_util_percent    := NULL;
		   l_u7_tbl(i).nonbill_util_percent := NULL;
           l_u7_tbl(i).unassigned_percent   := NULL;
           l_u7_tbl(i).training_percent     := NULL;
         END IF;

   END LOOP;

   IF l_u7_tbl.COUNT > 0 THEN
   FOR i IN 1..l_u7_tbl.COUNT
	LOOP

      IF l_u7_tbl.EXISTS(i) THEN

        l_u7_tbl(i).PJI_REP_TOTAL_1 := l_scheduled_hours;
        l_u7_tbl(i).PJI_REP_TOTAL_2 := l_capacity_hours;
        l_u7_tbl(i).PJI_REP_TOTAL_3 := l_confirmed_billable_hours;
        l_u7_tbl(i).PJI_REP_TOTAL_4 := l_confirmed_nonbillable_hours;
        l_u7_tbl(i).PJI_REP_TOTAL_5 := l_provisional_billable_hours;
        l_u7_tbl(i).PJI_REP_TOTAL_6 := l_prov_nonbillable_hours;
        l_u7_tbl(i).PJI_REP_TOTAL_7 := l_training_hours   ;


        IF nvl(l_util_percent_denom_hours,0) <> 0 THEN

          l_u7_tbl(i).PJI_REP_TOTAL_8      := (l_confirmed_weighted_hours/l_util_percent_denom_hours)*100;
          l_u7_tbl(i).PJI_REP_TOTAL_9      := (l_billable_conf_weighted_hours/l_util_percent_denom_hours)*100;
          l_u7_tbl(i).PJI_REP_TOTAL_10      := ((l_confirmed_weighted_hours - l_billable_conf_weighted_hours)/l_util_percent_denom_hours)*100;
          l_u7_tbl(i).PJI_REP_TOTAL_11      := (l_unassigned_hours/l_util_percent_denom_hours)*100;
          l_u7_tbl(i).PJI_REP_TOTAL_12      := (l_training_hours/l_util_percent_denom_hours)*100;

        END IF;

      END IF; -- l_u7_tbl.EXISTS(i)
	END LOOP;
    END IF; --l_u7_tbl.COUNT > 0

 /*
  * Return the bulk collected table back to pmv.
  */
  COMMIT;
  RETURN l_u7_tbl;


END PLSQLDriver_PJI_REP_U7;


/*****************************************************************************
 *
 * The functions for report U8: Project Expected Utilization Detail
 *
 *****************************************************************************/

PROCEDURE Get_SQL_PJI_REP_U8(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             , x_PMV_Sql OUT NOCOPY VARCHAR2
                             , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
BEGIN

    PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL  => p_page_parameter_tbl
                               ,P_SELECT_LIST         =>
                               ' FACT.RESOURCE_NAME  "VIEWBY",
                                 FACT.EXPECTED_HOURS  "PJI_REP_MSR_2",
		                         FACT.CAPACITY_HOURS  "PJI_REP_MSR_3",
		                         FACT.MISSING_HOURS  "PJI_REP_MSR_4",
		                         FACT.ACT_UTIL_PERCENT  "PJI_REP_MSR_5",
		                         FACT.SCH_UTIL_PERCENT  "PJI_REP_MSR_6",
		                         FACT.EXP_UTIL_PERCENT  "PJI_REP_MSR_7",
		                         FACT.PROV_SCH_UTIL_PERCENT  "PJI_REP_MSR_12",
		                         FACT.EXP_TOTAL_UTIL_PERCENT  "PJI_REP_MSR_8",
		                         FACT.PRIOR_UTIL_PERCENT  "PJI_REP_MSR_9",
		                         FACT.EXP_BILL_UTIL_PERCENT  "PJI_REP_MSR_10",
		                         FACT.EXP_NONBILL_UTIL_PERCENT  "PJI_REP_MSR_13",
		                         FACT.EXP_TRAINING_PERCENT  "PJI_REP_MSR_11",
		                         FACT.SCH_CONF_WEIGHTED_HOURS  "PJI_REP_MSR_21",
		                         FACT.SCH_PROV_WEIGHTED_HOURS  "PJI_REP_MSR_23",
		                         FACT.EXPECTED_BILL_WEIGHTED_HOURS  "PJI_REP_MSR_14",
		                         FACT.EXPECTED_TRAINING_HOURS  "PJI_REP_MSR_15",
		                         FACT.PRIOR_ACTUAL_WEIGHTED_HOURS  "PJI_REP_MSR_16",
		                         FACT.PRIOR_CAPACITY_HOURS  "PJI_REP_MSR_17",
		                         FACT.UTIL_PERCENT_DENOM_HOURS  "PJI_REP_MSR_22",
		                         FACT.PRIOR_UTIL_PERCENT_DENOM_HOURS  "PJI_REP_MSR_18",
		                         FACT.ACTUAL_WEIGHTED_HOURS  "PJI_REP_MSR_19",
		                         FACT.RESOURCE_ID  "PJI_REP_MSR_24",
		                         FACT.EXP_AC_UTIL_PERCENT_DENOM  "PJI_REP_MSR_25",
		                         FACT.EXP_SCH_UTIL_PERCENT_DENOM  "PJI_REP_MSR_26",
		                         FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1",
		                         FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_2",
		                         FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_3",
		                         FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_4",
		                         FACT.PJI_REP_TOTAL_5 "PJI_REP_TOTAL_5",
		                         FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_6",
		                         FACT.PJI_REP_TOTAL_7 "PJI_REP_TOTAL_7",
		                         FACT.PJI_REP_TOTAL_8 "PJI_REP_TOTAL_8",
		                         FACT.PJI_REP_TOTAL_9 "PJI_REP_TOTAL_9",
		                         FACT.PJI_REP_TOTAL_10 "PJI_REP_TOTAL_10",
		                         FACT.PJI_REP_TOTAL_11 "PJI_REP_TOTAL_11",
		                         FACT.PJI_REP_TOTAL_12 "PJI_REP_TOTAL_12" '
                               ,P_SQL_STATEMENT       => x_PMV_Sql
                               ,P_PMV_OUTPUT          => x_PMV_Output,
                                P_REGION_CODE         => 'PJI_REP_U8',
                                P_PLSQL_DRIVER        => 'PJI_PMV_UTLZ.PLSQLDriver_PJI_REP_U8',
                                P_PLSQL_DRIVER_PARAMS =>   '<<ORGANIZATION+FII_OPERATING_UNITS>>, ' ||
                                                           '<<ORGANIZATION+PJI_ORGANIZATIONS>>, ' ||
                                                           '<<AS_OF_DATE>>, ' ||
                                                           '<<PERIOD_TYPE>>, ' ||
                                       '<<PROJECT WORK TYPE+PJI_UTIL_CATEGORIES>>, ' ||
                                       '<<PROJECT WORK TYPE+PJI_WORK_TYPES>>, ' ||
                                       '<<PROJECT JOB LEVEL+PJI_JOB_LEVELS>>, ' ||
                                       '<<VIEW_BY>>');
END Get_SQL_PJI_REP_U8;


FUNCTION PLSQLDriver_PJI_REP_U8 (
    p_operating_unit		IN VARCHAR2 DEFAULT NULL
  , p_organization		IN VARCHAR2
  , p_as_of_date		IN NUMBER
  , p_period_type 		IN VARCHAR2
  , p_util_categories 		IN VARCHAR2 DEFAULT NULL
  , p_work_type                 IN VARCHAR2 DEFAULT NULL
  , p_job_level 		IN VARCHAR2 DEFAULT NULL
  , p_view_by                   IN VARCHAR2
)RETURN PJI_REP_U8_TBL
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_u8_tbl		PJI_REP_U8_TBL:=PJI_REP_U8_TBL();
l_job_level_param               VARCHAR2(1);
l_util_categories_param         VARCHAR2(1);
l_util_percent_denom_prof       VARCHAR(25);
l_dft_util_percent_denom_prof   VARCHAR(25) := 'CAPACITY';
l_labor_unit                    VARCHAR2(40);
l_expected_hours                     NUMBER := 0;
l_capacity_hours                     NUMBER := 0;
l_missing_hours                      NUMBER := 0;
l_actual_weighted_hours              NUMBER := 0;
l_sch_conf_weighted_hours            NUMBER := 0;
l_sch_prov_weighted_hours            NUMBER := 0;
l_expected_bill_weighted_hours       NUMBER := 0;
l_expected_training_hours            NUMBER := 0;
l_prior_actual_weighted_hours        NUMBER := 0;
l_prior_capacity_hours               NUMBER := 0;
l_util_percent_denom_hours           NUMBER := 0;
l_exp_ac_util_percent_denom          NUMBER := 0;
l_exp_sch_util_percent_denom         NUMBER := 0;
l_prior_util_denom     NUMBER := 0;
l_act_util_percent            NUMBER := 0;
l_sch_util_percent            NUMBER := 0;
l_exp_util_percent            NUMBER := 0;
l_prov_sch_util_percent       NUMBER := 0;
l_exp_total_util_percent      NUMBER := 0;
l_prior_util_percent          NUMBER := 0;
l_exp_bill_util_percent       NUMBER := 0;
l_exp_nonbill_util_percent    NUMBER := 0;
l_exp_training_percent        NUMBER := 0;

BEGIN
 /*
  * Place a call to all the parse API's which parse the parameters
  * passed by PMV and populate all the temporary tables.
  */
  PJI_PMV_ENGINE.Convert_Operating_Unit(p_operating_unit, p_view_by);
  PJI_PMV_ENGINE.Convert_Organization(p_organization, p_view_by);
  PJI_PMV_ENGINE.Convert_Expected_Time(p_as_of_date, p_period_type, 'Y');

  l_util_categories_param := PJI_PMV_ENGINE.convert_util_category(p_work_type, p_util_categories, p_view_by);
  l_job_level_param       := PJI_PMV_ENGINE.convert_job_level(null, p_job_level, p_view_by);

 /*
  * Get Utilization percentage denominator profile value
  */
  BEGIN
    SELECT fnd_profile.value('PA_ORG_UTIL_DEF_CALC_METHOD')
    INTO l_util_percent_denom_prof
    from dual;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        l_util_percent_denom_prof := l_dft_util_percent_denom_prof;
  END;


 /*
  * Get report labor unit
  */
  BEGIN
     select report_labor_units
     into l_labor_unit
     from pji_system_settings;

  EXCEPTION WHEN OTHERS THEN
         l_labor_unit := null;
  END;


 /*
  * determine the fact tables you choose to run the database query on.
  *
  * If util_categories=null and job_level=null
  */
  IF l_util_categories_param = 'N' AND l_job_level_param = 'N' THEN
     SELECT PJI_REP_U8( resource_name
                       ,resource_id
                       ,SUM(expected_hours)
                       ,SUM(capacity_hours)
                       ,SUM(missing_hours)
                       ,SUM(actual_weighted_hours)
                       ,SUM(sch_conf_weighted_hours)
                       ,SUM(sch_prov_weighted_hours)
                       ,SUM(expected_bill_weighted_hours)
                       ,SUM(expected_training_hours)
                       ,SUM(prior_actual_weighted_hours)
                       ,SUM(prior_capacity_hours)
                       ,SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',
                            capacity_hours,actual_hours))
                       ,SUM(decode(l_util_percent_denom_prof, 'CAPACITY',
                            exp_ac_capacity_hours, exp_ac_actual_hours))
                       ,SUM(decode(l_util_percent_denom_prof, 'CAPACITY',
                            exp_sch_capacity_hours, exp_sch_actual_hours))
                       ,SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',
                            prior_capacity_hours,prior_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null
                       )
     BULK COLLECT INTO l_u8_tbl
     /* Bug 3515594 */
     FROM
        (
        -- get current year values
        SELECT /*+ ORDERED */
           resd.resource_name                      resource_name
          ,fct.person_id                          resource_id
          ,DECODE(time.amount_type,0,fct.total_hrs_a,fct.conf_hrs_s)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      expected_hours
          ,(fct.capacity_hrs-DECODE(time.amount_type,0,NVL(fct.reduce_capacity_hrs_a,0),
           NVL(fct.reduce_capacity_hrs_s,0)))
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      capacity_hours
          ,fct.missing_hrs_a
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      missing_hours
          ,DECODE(time.amount_type,0,fct.total_wtd_org_hrs_a,0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      actual_weighted_hours
          ,DECODE(time.amount_type,1,conf_wtd_org_hrs_s,0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      sch_conf_weighted_hours
          ,DECODE(time.amount_type,1,prov_wtd_org_hrs_s,0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      sch_prov_weighted_hours
          ,DECODE(time.amount_type,0,fct.bill_wtd_org_hrs_a,fct.conf_bill_wtd_org_hrs_s)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      expected_bill_weighted_hours
          ,DECODE(time.amount_type,0,fct.training_hrs_a,fct.training_hrs_s)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      expected_training_hours
          ,fct.total_hrs_a * decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       actual_hours
          ,decode(time.amount_type, 0, fct.capacity_hrs - fct.reduce_capacity_hrs_a, fct.capacity_hrs)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   exp_ac_capacity_hours
          ,decode(time.amount_type, 0, fct.total_hrs_a, 0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   exp_ac_actual_hours
          ,decode(time.amount_type, 0, fct.capacity_hrs, fct.capacity_hrs - fct.reduce_capacity_hrs_s)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   exp_sch_capacity_hours
          ,decode(time.amount_type, 0, 0, fct.total_hrs_a)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   exp_sch_actual_hours
          ,0                                       prior_actual_weighted_hours
          ,0                                       prior_capacity_hours
          ,0                                       prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_rm_res_f         fct
          ,pji_pmv_org_dim_tmp  hou
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
           fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.id is not null
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND hou.id = imp.org_id
        -- get prior year values
        UNION ALL
	/* Bug 3515594 */
        SELECT /*+ ORDERED */
           resd.resource_name                      resource_name
          ,fct.person_id                          resource_id
          ,0                                       expected_hours
          ,0                                       capacity_hours
          ,0                                       missing_hours
          ,0                                       actual_weighted_hours
          ,0                                       sch_conf_weighted_hours
          ,0                                       sch_prov_weighted_hours
          ,0                                       expected_bill_weighted_hours
          ,0                                       expected_training_hours
          ,0                                       actual_hours
          ,0                                       exp_ac_capacity_hours
          ,0                                       exp_ac_actual_hours
          ,0                                       exp_sch_capacity_hours
          ,0                                       exp_sch_actual_hours
          ,fct.total_wtd_org_hrs_a
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)   prior_actual_weighted_hours
          ,(fct.capacity_hrs-NVL(fct.reduce_capacity_hrs_a,0))
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)   prior_capacity_hours
          ,fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                    prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_rm_res_f         fct
          ,pji_pmv_org_dim_tmp  hou
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
           fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.prior_id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.prior_id is not null
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND fct.expenditure_org_id = imp.org_id
        -- get the data for the resources who doens't have data
        UNION ALL
        SELECT
           resd.resource_name                      resource_name
          ,resd.person_id                          resource_id
          ,0                                       expected_hours
          ,0                                       capacity_hours
          ,0                                       missing_hours
          ,0                                       actual_weighted_hours
          ,0                                       sch_conf_weighted_hours
          ,0                                       sch_prov_weighted_hours
          ,0                                       expected_bill_weighted_hours
          ,0                                       expected_training_hours
          ,0                                       actual_hours
          ,0                                       exp_ac_capacity_hours
          ,0                                       exp_ac_actual_hours
          ,0                                       exp_sch_capacity_hours
          ,0                                       exp_sch_actual_hours
          ,0                                       prior_actual_weighted_hours
          ,0                                       prior_capacity_hours
          ,0                                       prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pa_resources_denorm resd
        WHERE
           resd.resource_organization_id = horg.id
           AND resd.utilization_flag = 'Y'
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
        )
     GROUP BY resource_name, resource_id;

 /*
  * If util_categories=null and job_level<>null
  */
  ELSIF l_util_categories_param = 'N' AND l_job_level_param = 'Y' THEN
     SELECT PJI_REP_U8( resource_name
                       ,resource_id
                       ,SUM(expected_hours)
                       ,SUM(capacity_hours)
                       ,SUM(missing_hours)
                       ,SUM(actual_weighted_hours)
                       ,SUM(sch_conf_weighted_hours)
                       ,SUM(sch_prov_weighted_hours)
                       ,SUM(expected_bill_weighted_hours)
                       ,SUM(expected_training_hours)
                       ,SUM(prior_actual_weighted_hours)
                       ,SUM(prior_capacity_hours)
                       ,SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',
                            capacity_hours,actual_hours))
                       ,SUM(decode(l_util_percent_denom_prof, 'CAPACITY',
                            exp_ac_capacity_hours, exp_ac_actual_hours))
                       ,SUM(decode(l_util_percent_denom_prof, 'CAPACITY',
                            exp_sch_capacity_hours, exp_sch_actual_hours))
                       ,SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',
                            prior_capacity_hours,prior_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null
                       )
     /* Bug 3515594 */
     BULK COLLECT INTO l_u8_tbl
     FROM
        (
        -- get current year values
        SELECT /*+ ORDERED */
           resd.resource_name                      resource_name
          ,fct.person_id                          resource_id
          ,DECODE(time.amount_type,0,fct.total_hrs_a,fct.conf_hrs_s)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      expected_hours
          ,(fct.capacity_hrs-DECODE(time.amount_type,0,NVL(fct.reduce_capacity_hrs_a,0),
           NVL(fct.reduce_capacity_hrs_s,0)))
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      capacity_hours
          ,fct.missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)                                                                                                                                 missing_hours
          ,DECODE(time.amount_type,0,fct.total_wtd_org_hrs_a,0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      actual_weighted_hours
          ,DECODE(time.amount_type,1,conf_wtd_org_hrs_s,0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      sch_conf_weighted_hours
          ,DECODE(time.amount_type,1,prov_wtd_org_hrs_s,0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      sch_prov_weighted_hours
          ,DECODE(time.amount_type,0,fct.bill_wtd_org_hrs_a,fct.conf_bill_wtd_org_hrs_s)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      expected_bill_weighted_hours
          ,DECODE(time.amount_type,0,fct.training_hrs_a,fct.training_hrs_s)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      expected_training_hours
          ,fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       actual_hours
          ,decode(time.amount_type, 0, fct.capacity_hrs - fct.reduce_capacity_hrs_a, fct.capacity_hrs)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   exp_ac_capacity_hours
          ,decode(time.amount_type, 0, fct.total_hrs_a, 0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   exp_ac_actual_hours
          ,decode(time.amount_type, 0, fct.capacity_hrs, fct.capacity_hrs - fct.reduce_capacity_hrs_s)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   exp_sch_capacity_hours
          ,decode(time.amount_type, 0, 0, fct.total_hrs_a)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   exp_sch_actual_hours
          ,0                                       prior_actual_weighted_hours
          ,0                                       prior_capacity_hours
          ,0                                       prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_pmv_jb_dim_tmp   jbt
          ,pji_rm_res_f         fct
          ,pji_pmv_org_dim_tmp  hou
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
               fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.id is not null
           AND fct.job_id = jbt.id
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND hou.id = imp.org_id
        -- get prior year values
        UNION ALL
        SELECT /*+ ORDERED */
           resd.resource_name                      resource_name
          ,fct.person_id                          resource_id
          ,0                                       expected_hours
          ,0                                       capacity_hours
          ,null                                    missing_hours
          ,0                                       actual_weighted_hours
          ,0                                       sch_conf_weighted_hours
          ,0                                       sch_prov_weighted_hours
          ,0                                       expected_bill_weighted_hours
          ,0                                       expected_traing_traing_hours
          ,0                                       actual_hours
          ,0                                       exp_ac_capacity_hours
          ,0                                       exp_ac_actual_hours
          ,0                                       exp_sch_capacity_hours
          ,0                                       exp_sch_actual_hours
          ,fct.total_wtd_org_hrs_a
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      prior_actual_weighted_hours
          ,(fct.capacity_hrs-NVL(fct.reduce_capacity_hrs_a,0))
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      prior_capacity_hours
          ,fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_pmv_jb_dim_tmp   jbt
          ,pji_rm_res_f         fct
          ,pji_pmv_org_dim_tmp  hou
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
               fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.prior_id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.prior_id is not null
           AND fct.job_id = jbt.id
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND hou.id = imp.org_id
        -- get the data for the resources who doens't have data
        UNION ALL
        SELECT
           resd.resource_name                      resource_name
          ,resd.person_id                          resource_id
          ,0                                       expected_hours
          ,0                                       capacity_hours
          ,null                                    missing_hours
          ,0                                       actual_weighted_hours
          ,0                                       sch_conf_weighted_hours
          ,0                                       sch_prov_weighted_hours
          ,0                                       expected_bill_weighted_hours
          ,0                                       expected_traing_traing_hours
          ,0                                       actual_hours
          ,0                                       exp_ac_capacity_hours
          ,0                                       exp_ac_actual_hours
          ,0                                       exp_sch_capacity_hours
          ,0                                       exp_sch_actual_hours
          ,0                                       prior_actual_weighted_hours
          ,0                                       prior_capacity_hours
          ,0                                       prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_jb_dim_tmp  jbt
          ,pa_resources_denorm resd
        WHERE
           resd.resource_organization_id = horg.id
           AND resd.utilization_flag = 'Y'
           AND resd.job_id = jbt.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
        )
     GROUP BY resource_name, resource_id;

 /*
  * If util_categories<>null and job_level=null
  */
  ELSIF l_util_categories_param = 'Y' AND l_job_level_param = 'N' THEN
     SELECT PJI_REP_U8( resource_name
                       ,resource_id
                       ,SUM(expected_hours)
                       ,SUM(capacity_hours-reduce_capacity_hours)
                       ,SUM(missing_hours)
                       ,SUM(actual_weighted_hours)
                       ,SUM(sch_conf_weighted_hours)
                       ,SUM(sch_prov_weighted_hours)
                       ,SUM(expected_bill_weighted_hours)
                       ,SUM(expected_training_hours)
                       ,SUM(prior_actual_weighted_hours)
                       ,SUM(prior_capacity_hours-prior_red_capacity_hours)
                       ,SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',
                            capacity_hours-reduce_capacity_hours,actual_hours))
                       ,SUM(decode(l_util_percent_denom_prof, 'CAPACITY',
                            capacity_hours-exp_ac_red_capacity_hours, exp_ac_actual_hours))
                       ,SUM(decode(l_util_percent_denom_prof, 'CAPACITY',
                            capacity_hours-exp_sch_red_capacity_hours, exp_sch_actual_hours))
                       ,SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',
                            prior_capacity_hours-prior_red_capacity_hours,prior_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null
                       )
     BULK COLLECT INTO l_u8_tbl
     /* Bug 3515594 */
     FROM
        (
        -- get current year values
        SELECT /*+ ORDERED */
           resd.resource_name                                            resource_name
          ,fct.person_id                                                 resource_id
          ,DECODE(time.amount_type,0,fct.total_hrs_a,fct.conf_hrs_s)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      expected_hours
          ,0                                                                           capacity_hours
          ,0                                                                           reduce_capacity_hours
          ,null                                                                        missing_hours
          ,DECODE(time.amount_type,0,fct.total_hrs_a,0)* wtb.org_utilization_percentage/100
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      actual_weighted_hours
          ,DECODE(time.amount_type,1,fct.conf_hrs_s,0)* wtb.org_utilization_percentage/100
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      sch_conf_weighted_hours
          ,DECODE(time.amount_type,1,fct.prov_hrs_s,0)* wtb.org_utilization_percentage/100
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      sch_prov_weighted_hours
          ,(case when time.amount_type=0 then
             fct.bill_hrs_a*wtb.org_utilization_percentage/100
             when time.amount_type=1 and wtb.billable_capitalizable_flag='Y' then
             fct.conf_hrs_s*wtb.org_utilization_percentage/100
             else 0 end) * decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       expected_bill_weighted_hours
          ,(case when time.amount_type=0 and wtb.training_flag='Y' then fct.total_hrs_a
             when time.amount_type=1 and wtb.training_flag='Y' then fct.conf_hrs_s
             else 0 end) / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       expected_training_hours
          ,fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       actual_hours
          ,0                                                                           exp_ac_red_capacity_hours
          ,decode(time.amount_type, 0, fct.total_hrs_a, 0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       exp_ac_actual_hours
          ,0                                                                           exp_sch_red_capacity_hours
          ,decode(time.amount_type, 0, 0, fct.total_hrs_a)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       exp_sch_actual_hours
          ,0                                                             prior_actual_weighted_hours
          ,0                                                             prior_capacity_hours
          ,0                                                             prior_red_capacity_hours
          ,0                                                             prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_pmv_wt_dim_tmp   wt
          ,pji_rm_res_wt_f      fct
          ,pji_pmv_org_dim_tmp  hou
          ,pa_work_types_b      wtb
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
           fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.id is not null
           AND fct.work_type_id = wt.id
           AND wtb.work_type_id = wt.id
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND hou.id = imp.org_id
        -- get prior year values
        UNION ALL
        SELECT
           resd.resource_name                      resource_name
          ,fct.person_id                           resource_id
          ,0                                       expected_hours
          ,0                                       capacity_hours
          ,0                                       reduce_capacity_hours
          ,null                                    missing_hours
          ,0                                       actual_weighted_hours
          ,0                                       sch_conf_weighted_hours
          ,0                                       sch_prov_weighted_hours
          ,0                                       expected_bill_weighted_hours
          ,0                                       expected_traing_hours
          ,0                                       actual_hours
          ,0                                       exp_ac_red_capacity_hours
          ,0                                       exp_ac_actual_hours
          ,0                                       exp_sch_red_capacity_hours
          ,0                                       exp_sch_actual_hours
          ,fct.total_hrs_a * wtb.org_utilization_percentage/100
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     prior_actual_weighted_hours
          ,0                                       prior_capacity_hours
          ,0                                       prior_red_capacity_hours
          ,fct.total_hrs_a  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                      prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_pmv_wt_dim_tmp   wt
          ,pji_rm_res_wt_f      fct
          ,pji_pmv_org_dim_tmp  hou
          ,pa_work_types_b      wtb
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
           fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.prior_id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.prior_id is not null
           AND fct.work_type_id = wt.id
           AND wtb.work_type_id = wt.id
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND fct.expenditure_org_id = imp.org_id
        -- get the data for the resources who doesn't have data
        UNION ALL
        SELECT
           resd.resource_name                      resource_name
          ,resd.person_id                          resource_id
          ,0                                       expected_hours
          ,0                                       capacity_hours
          ,0                                       reduce_capacity_hours
          ,null                                    missing_hours
          ,0                                       actual_weighted_hours
          ,0                                       sch_conf_weighted_hours
          ,0                                       sch_prov_weighted_hours
          ,0                                       expected_bill_weighted_hours
          ,0                                       expected_traing_hours
          ,0                                       actual_hours
          ,0                                       exp_ac_red_capacity_hours
          ,0                                       exp_ac_actual_hours
          ,0                                       exp_sch_red_capacity_hours
          ,0                                       exp_sch_actual_hours
          ,0                                       prior_actual_weighted_hours
          ,0                                       prior_capacity_hours
          ,0                                       prior_red_capacity_hours
          ,0                                       prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pa_resources_denorm resd
        WHERE
           resd.resource_organization_id = horg.id
           AND resd.utilization_flag = 'Y'
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
        UNION ALL  -- added for current year capacity_hours
	/* Bug 3515594 */
        SELECT  /*+ ORDERED */
           resd.resource_name                      resource_name
          ,resd.person_id                          resource_id
          ,0                                       expected_hours
          ,fct.capacity_hrs
                / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   capacity_hours
          ,decode(time.amount_type, 0, fct.reduce_capacity_hrs_a, reduce_capacity_hrs_s)
                / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   reduce_capacity_hours
          ,fct.missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   missing_hours
          ,0                                       actual_weighted_hours
          ,0                                       sch_conf_weighted_hours
          ,0                                       sch_prov_weighted_hours
          ,0                                       expected_bill_weighted_hours
          ,0                                       expected_traing_hours
          ,0                                       actual_hours
          ,decode(time.amount_type, 0, fct.reduce_capacity_hrs_a, 0)
                / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   exp_ac_red_capacity_hours
          ,0                                       exp_ac_actual_hours
          ,decode(time.amount_type, 1, fct.reduce_capacity_hrs_s, 0)
                / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   exp_sch_red_capacity_hours
          ,0                                       exp_sch_actual_hours
          ,0                                       prior_actual_weighted_hours
          ,0                                       prior_capacity_hours
          ,0                                       prior_red_capacity_hours
          ,0                                       prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_rm_res_f         fct
          ,pji_pmv_org_dim_tmp  hou
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
           fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.id is not null
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND hou.id = imp.org_id
        UNION ALL  -- added for prior year capacity_hours
        SELECT  /*+ ORDERED */
           resd.resource_name                      resource_name
          ,resd.person_id                          resource_id
          ,0                                       expected_hours
          ,0                                       capacity_hours
          ,0                                       reduce_capacity_hours
          ,null                                    missing_hours
          ,0                                       actual_weighted_hours
          ,0                                       sch_conf_weighted_hours
          ,0                                       sch_prov_weighted_hours
          ,0                                       expected_bill_weighted_hours
          ,0                                       expected_traing_hours
          ,0                                       actual_hours
          ,0                                       exp_ac_red_capacity_hours
          ,0                                       exp_ac_actual_hours
          ,0                                       exp_sch_red_capacity_hours
          ,0                                       exp_sch_actual_hours
          ,0                                       prior_actual_weighted_hours
          ,fct.capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   prior_capacity_hours
          ,fct.reduce_capacity_hrs_a  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   prior_red_capacity_hours
          ,0                                       prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_rm_res_f         fct
          ,pji_pmv_org_dim_tmp  hou
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
           fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.prior_id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.prior_id is not null
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND hou.id = imp.org_id

        )
     GROUP BY resource_name, resource_id;

 /*
  * If util_categories<>null and job_level<>null
  */
  ELSIF l_util_categories_param = 'Y' AND l_job_level_param = 'Y' THEN
     SELECT PJI_REP_U8( resource_name
                       ,resource_id
                       ,SUM(expected_hours)
                       ,SUM(capacity_hours-reduce_capacity_hours)
                       ,SUM(missing_hours)
                       ,SUM(actual_weighted_hours)
                       ,SUM(sch_conf_weighted_hours)
                       ,SUM(sch_prov_weighted_hours)
                       ,SUM(expected_bill_weighted_hours)
                       ,SUM(expected_training_hours)
                       ,SUM(prior_actual_weighted_hours)
                       ,SUM(prior_capacity_hours-prior_red_capacity_hours)
                       ,SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',
                            capacity_hours-reduce_capacity_hours,actual_hours))
                       ,SUM(decode(l_util_percent_denom_prof, 'CAPACITY',
                            capacity_hours-exp_ac_red_capacity_hours, exp_ac_actual_hours))
                       ,SUM(decode(l_util_percent_denom_prof, 'CAPACITY',
                            capacity_hours-exp_sch_red_capacity_hours, exp_sch_actual_hours))
                       ,SUM(DECODE(l_util_percent_denom_prof,'CAPACITY',
                            prior_capacity_hours-prior_red_capacity_hours,prior_actual_hours)),
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null,null,null,null,
                        null,null,null
                       )
     BULK COLLECT INTO l_u8_tbl
     /* Bug 3515594 */
     FROM
        (
        -- get current year values
        SELECT /*+ ORDERED */
           resd.resource_name                                            resource_name
          ,fct.person_id                                                 resource_id
          ,DECODE(time.amount_type,0,fct.total_hrs_a,fct.conf_hrs_s)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      expected_hours
          ,0                                                                           capacity_hours
          ,0                                                                           reduce_capacity_hours
          ,null                                                                        missing_hours
          ,DECODE(time.amount_type,0,fct.total_hrs_a,0)* wtb.org_utilization_percentage/100
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      actual_weighted_hours
          ,DECODE(time.amount_type,1,fct.conf_hrs_s,0)* wtb.org_utilization_percentage/100
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      sch_conf_weighted_hours
          ,DECODE(time.amount_type,1,fct.prov_hrs_s,0)* wtb.org_utilization_percentage/100
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      sch_prov_weighted_hours
          ,(case when time.amount_type=0 and wtb.billable_capitalizable_flag='Y' then
             fct.total_hrs_a*wtb.org_utilization_percentage/100
             when time.amount_type=1 and wtb.billable_capitalizable_flag='Y' then
             fct.conf_hrs_s*wtb.org_utilization_percentage/100 else 0 end)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       expected_bill_weighted_hours
          ,(case when time.amount_type=0 and wtb.training_flag='Y' then fct.total_hrs_a
             when time.amount_type=1 and wtb.training_flag='Y' then fct.conf_hrs_s else 0 end)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       expected_training_hours
          ,fct.total_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       actual_hours
          ,0                                                                           exp_ac_red_capacity_hours
          ,decode(time.amount_type, 0, fct.total_hrs_a, 0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       exp_ac_actual_hours
          ,0                                                                           exp_sch_red_capacity_hours
          ,decode(time.amount_type, 0, 0, fct.total_hrs_a)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                       exp_sch_actual_hours
          ,0                                                             prior_actual_weighted_hours
          ,0                                                             prior_capacity_hours
          ,0                                                             prior_red_capacity_hours
          ,0                                                             prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_pmv_wt_dim_tmp   wt
          ,pji_rm_res_wt_f      fct
          ,pji_pmv_jb_dim_tmp   jbt
          ,pji_pmv_org_dim_tmp  hou
          ,pa_work_types_b      wtb
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
           fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.id is not null
           AND fct.work_type_id = wt.id
           AND wtb.work_type_id = wt.id
           AND fct.job_id = jbt.id
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND hou.id = imp.org_id
        -- get prior year values
        UNION ALL
        SELECT
           resd.resource_name                      resource_name
          ,fct.person_id                           resource_id
          ,0                                       expected_hours
          ,0                                       capacity_hours
          ,0                                       reduce_capacity_hours
          ,null                                    missing_hours
          ,0                                       actual_weighted_hours
          ,0                                       sch_conf_weighted_hours
          ,0                                       sch_prov_weighted_hours
          ,0                                       expected_bill_weighted_hours
          ,0                                       expected_traing_hours
          ,0                                       actual_hours
          ,0                                       exp_ac_red_capacity_hours
          ,0                                       exp_ac_actual_hours
          ,0                                       exp_sch_red_capacity_hours
          ,0                                       exp_sch_actual_hours
          ,(fct.total_hrs_a * wtb.org_utilization_percentage/100)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     prior_actual_weighted_hours
          ,0                                       prior_capacity_hours
          ,(CASE WHEN wtb.reduce_capacity_flag = 'Y' THEN fct.total_hrs_a ELSE 0 END)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)     prior_red_capacity_hours
          ,fct.total_hrs_a  / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                                                      prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_pmv_wt_dim_tmp   wt
          ,pji_rm_res_wt_f      fct
          ,pji_pmv_jb_dim_tmp   jbt
          ,pji_pmv_org_dim_tmp  hou
          ,pa_work_types_b      wtb
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
           fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.prior_id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.prior_id is not null
           AND fct.work_type_id = wt.id
           AND wtb.work_type_id = wt.id
           AND fct.job_id = jbt.id
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND fct.expenditure_org_id = imp.org_id
        -- get the data for the resources who doesn't have data
        UNION ALL
        SELECT
           resd.resource_name                      resource_name
          ,resd.person_id                          resource_id
          ,0                                       expected_hours
          ,0                                       capacity_hours
          ,0                                       reduce_capacity_hours
          ,null                                    missing_hours
          ,0                                       actual_weighted_hours
          ,0                                       sch_conf_weighted_hours
          ,0                                       sch_prov_weighted_hours
          ,0                                       expected_bill_weighted_hours
          ,0                                       expected_traing_hours
          ,0                                       actual_hours
          ,0                                       exp_ac_red_capacity_hours
          ,0                                       exp_ac_actual_hours
          ,0                                       exp_sch_red_capacity_hours
          ,0                                       exp_sch_actual_hours
          ,0                                       prior_actual_weighted_hours
          ,0                                       prior_capacity_hours
          ,0                                       prior_red_capacity_hours
          ,0                                       prior_actual_hours
        FROM
           pa_resources_denorm resd
          ,pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_jb_dim_tmp  jbt
        WHERE
           resd.resource_organization_id = horg.id
           AND resd.utilization_flag = 'Y'
           AND resd.job_id = jbt.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date

        UNION ALL  -- added for current year capacity_hours
	/* Bug 3515594 */
        SELECT   /*+ ORDERED */
           resd.resource_name                      resource_name
          ,resd.person_id                          resource_id
          ,0                                       expected_hours
          ,fct.capacity_hrs / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   capacity_hours
          ,decode(time.amount_type, 0, fct.reduce_capacity_hrs_a, fct.reduce_capacity_hrs_s)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   reduce_capacity_hours
          ,fct.missing_hrs_a / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   missing_hours
          ,0                                       actual_weighted_hours
          ,0                                       sch_conf_weighted_hours
          ,0                                       sch_prov_weighted_hours
          ,0                                       expected_bill_weighted_hours
          ,0                                       expected_traing_hours
          ,0                                       actual_hours
          ,decode(time.amount_type, 0, fct.reduce_capacity_hrs_a, 0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   exp_ac_red_capacity_hours
          ,0                                       exp_ac_actual_hours
          ,decode(time.amount_type, 1, fct.reduce_capacity_hrs_s, 0)
             / decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)      exp_sch_red_capacity_hours
          ,0                                       exp_sch_actual_hours
          ,0                                       prior_actual_weighted_hours
          ,0                                       prior_capacity_hours
          ,0                                       prior_red_capacity_hours
          ,0                                       prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_pmv_jb_dim_tmp   jbt
          ,pji_rm_res_f         fct
          ,pji_pmv_org_dim_tmp  hou
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
           fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.id is not null
           AND fct.job_id = jbt.id
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND hou.id = imp.org_id

        UNION ALL  -- added for prior year capacity_hours
        SELECT  /*+ ORDERED */
           resd.resource_name                      resource_name
          ,resd.person_id                          resource_id
          ,0                                       expected_hours
          ,0                                       capacity_hours
          ,0                                       reduce_capacity_hours
          ,null                                    missing_hours
          ,0                                       actual_weighted_hours
          ,0                                       sch_conf_weighted_hours
          ,0                                       sch_prov_weighted_hours
          ,0                                       expected_bill_weighted_hours
          ,0                                       expected_traing_hours
          ,0                                       actual_hours
          ,0                                       exp_ac_red_capacity_hours
          ,0                                       exp_ac_actual_hours
          ,0                                       exp_sch_red_capacity_hours
          ,0                                       exp_sch_actual_hours
          ,0                                       prior_actual_weighted_hours
          ,fct.capacity_hrs * decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   prior_capacity_hours
          ,fct.reduce_capacity_hrs_a * decode(l_labor_unit, 'DAYS', imp.FTE_DAY, 'WEEKS',imp.FTE_WEEK, 1)
                                                   prior_red_capacity_hours
          ,0                                       prior_actual_hours
        FROM
           pji_pmv_orgz_dim_tmp horg
          ,pji_pmv_time_dim_tmp time
          ,pji_pmv_jb_dim_tmp   jbt
          ,pji_rm_res_f         fct
          ,pji_pmv_org_dim_tmp  hou
          ,pa_resources_denorm  resd
          ,pa_implementations_all imp
        WHERE
           fct.expenditure_org_id = hou.id
           AND fct.expenditure_organization_id = horg.id
           AND fct.time_id = time.prior_id
           AND fct.period_type_id = time.period_type
           AND fct.calendar_type  = decode(fct.period_type_id,1, 'C',time.calendar_type)
           AND time.prior_id is not null
           AND fct.job_id = jbt.id
           AND fct.person_id = resd.person_id
           AND resd.resource_organization_id = horg.id
           AND TO_DATE(p_as_of_date,'j') between resd.resource_effective_start_date and
               resd.resource_effective_end_date
           AND hou.id = imp.org_id
        )
     GROUP BY resource_name, resource_id;

    END IF;

    FOR i in 1..l_u8_tbl.COUNT
       LOOP

         l_expected_hours              := l_expected_hours                    + nvl(l_u8_tbl(i).expected_hours,0);
         l_capacity_hours              := l_capacity_hours                    + nvl(l_u8_tbl(i).capacity_hours,0);
         l_missing_hours               := l_missing_hours                     + nvl(l_u8_tbl(i).missing_hours,0);
         l_actual_weighted_hours       := l_actual_weighted_hours             + nvl(l_u8_tbl(i).actual_weighted_hours,0);
         l_sch_conf_weighted_hours     := l_sch_conf_weighted_hours           + nvl(l_u8_tbl(i).sch_conf_weighted_hours,0);
         l_sch_prov_weighted_hours     := l_sch_prov_weighted_hours           + nvl(l_u8_tbl(i).sch_prov_weighted_hours,0);
         l_expected_bill_weighted_hours := l_expected_bill_weighted_hours     + nvl(l_u8_tbl(i).expected_bill_weighted_hours,0);
         l_expected_training_hours     := l_expected_training_hours           + nvl(l_u8_tbl(i).expected_training_hours,0);
         l_prior_actual_weighted_hours := l_prior_actual_weighted_hours       + nvl(l_u8_tbl(i).prior_actual_weighted_hours,0);
         l_util_percent_denom_hours    := l_util_percent_denom_hours          + nvl(l_u8_tbl(i).util_percent_denom_hours,0);
         l_exp_ac_util_percent_denom   := l_exp_ac_util_percent_denom         + nvl(l_u8_tbl(i).exp_ac_util_percent_denom,0);
         l_exp_sch_util_percent_denom  := l_exp_sch_util_percent_denom        + nvl(l_u8_tbl(i).exp_sch_util_percent_denom,0);
         l_prior_util_denom := l_prior_util_denom + nvl(l_u8_tbl(i).prior_util_percent_denom_hours,0);

         --Calculated columns processing is done below
         IF nvl(l_u8_tbl(i).exp_ac_util_percent_denom,0) <> 0 THEN
           l_u8_tbl(i).act_util_percent     := 100 * (l_u8_tbl(i).actual_weighted_hours / l_u8_tbl(i).exp_ac_util_percent_denom);
         ELSE
           l_u8_tbl(i).act_util_percent     := NULL;
         END IF;

         IF nvl(l_u8_tbl(i).exp_sch_util_percent_denom,0) <> 0 THEN
           l_u8_tbl(i).sch_util_percent     := 100 * (l_u8_tbl(i).sch_conf_weighted_hours / l_u8_tbl(i).exp_sch_util_percent_denom);
           l_u8_tbl(i).prov_sch_util_percent := 100 * (l_u8_tbl(i).sch_prov_weighted_hours / l_u8_tbl(i).exp_sch_util_percent_denom);

         ELSE
           l_u8_tbl(i).sch_util_percent     := NULL;
           l_u8_tbl(i).prov_sch_util_percent := NULL;
         END IF;

         IF nvl(l_u8_tbl(i).util_percent_denom_hours,0) <> 0 THEN
           l_u8_tbl(i).exp_util_percent     := 100 * ((l_u8_tbl(i).actual_weighted_hours + l_u8_tbl(i).sch_conf_weighted_hours) / l_u8_tbl(i).util_percent_denom_hours);
           l_u8_tbl(i).exp_total_util_percent     := 100 * ((l_u8_tbl(i).actual_weighted_hours + l_u8_tbl(i).sch_conf_weighted_hours + l_u8_tbl(i).sch_prov_weighted_hours) / l_u8_tbl(i).util_percent_denom_hours);
           l_u8_tbl(i).exp_bill_util_percent     := 100 * ( l_u8_tbl(i).expected_bill_weighted_hours / l_u8_tbl(i).util_percent_denom_hours);
           l_u8_tbl(i).exp_nonbill_util_percent     := 100 * ((l_u8_tbl(i).actual_weighted_hours + l_u8_tbl(i).sch_conf_weighted_hours - l_u8_tbl(i).expected_bill_weighted_hours) / l_u8_tbl(i).util_percent_denom_hours);
           l_u8_tbl(i).exp_training_percent     := 100 * (l_u8_tbl(i).expected_training_hours/ l_u8_tbl(i).util_percent_denom_hours);


         ELSE
           l_u8_tbl(i).exp_util_percent     := NULL;
           l_u8_tbl(i).exp_total_util_percent := NULL;
           l_u8_tbl(i).exp_bill_util_percent    := NULL;
           l_u8_tbl(i).exp_nonbill_util_percent := NULL;
           l_u8_tbl(i).exp_training_percent     := NULL;
         END IF;

         IF nvl(l_u8_tbl(i).prior_util_percent_denom_hours,0) <> 0 THEN
           l_u8_tbl(i).prior_util_percent     := 100 * (l_u8_tbl(i).prior_actual_weighted_hours / l_u8_tbl(i).prior_util_percent_denom_hours);
         ELSE
           l_u8_tbl(i).prior_util_percent     := NULL;
         END IF;

   END LOOP;

   IF l_u8_tbl.COUNT > 0 THEN
   FOR i IN 1..l_u8_tbl.COUNT
	LOOP

      IF l_u8_tbl.EXISTS(i) THEN

        l_u8_tbl(i).PJI_REP_TOTAL_1 := l_expected_hours;
        l_u8_tbl(i).PJI_REP_TOTAL_2 := l_capacity_hours;
        l_u8_tbl(i).PJI_REP_TOTAL_3 := l_missing_hours;

        IF nvl(l_exp_ac_util_percent_denom,0) <> 0 THEN
          l_u8_tbl(i).PJI_REP_TOTAL_4      := (l_actual_weighted_hours/l_exp_ac_util_percent_denom)*100;
        END IF;

        IF nvl(l_exp_sch_util_percent_denom,0) <> 0 THEN
          l_u8_tbl(i).PJI_REP_TOTAL_5      := (l_sch_conf_weighted_hours/l_exp_sch_util_percent_denom)*100;
          l_u8_tbl(i).PJI_REP_TOTAL_7      := (l_sch_prov_weighted_hours/l_exp_sch_util_percent_denom)*100;

        END IF;

        IF nvl(l_util_percent_denom_hours,0) <> 0 THEN
          l_u8_tbl(i).PJI_REP_TOTAL_6      := ((l_actual_weighted_hours + l_sch_conf_weighted_hours)/l_util_percent_denom_hours)*100;
          l_u8_tbl(i).PJI_REP_TOTAL_8      := ((l_actual_weighted_hours + l_sch_conf_weighted_hours + l_sch_prov_weighted_hours)/l_util_percent_denom_hours)*100;
          l_u8_tbl(i).PJI_REP_TOTAL_10      := (l_expected_bill_weighted_hours/l_util_percent_denom_hours)*100;
          l_u8_tbl(i).PJI_REP_TOTAL_11      := ((l_actual_weighted_hours + l_sch_conf_weighted_hours - l_expected_bill_weighted_hours)/l_util_percent_denom_hours)*100;
          l_u8_tbl(i).PJI_REP_TOTAL_12      := (l_expected_training_hours/l_util_percent_denom_hours)*100;

        END IF;

        IF nvl(l_prior_util_denom,0) <> 0 THEN
          l_u8_tbl(i).PJI_REP_TOTAL_9      := (l_prior_actual_weighted_hours/l_prior_util_denom)*100;
        END IF;


      END IF; -- l_u8_tbl.EXISTS(i)
	END LOOP;
    END IF; --l_u8_tbl.COUNT > 0


 /*
  * Return the bulk collected table back to pmv.
  */
  COMMIT;
  RETURN l_u8_tbl;


END PLSQLDriver_PJI_REP_U8;


END PJI_PMV_UTLZ;

/
