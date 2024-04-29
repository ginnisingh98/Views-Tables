--------------------------------------------------------
--  DDL for Package Body PJI_PMV_BACKLOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PMV_BACKLOG" AS
/* $Header: PJIRF03B.pls 120.5 2005/10/11 18:23:16 appldev noship $ */

PROCEDURE Get_SQL_PJI_REP_PB1(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY  VARCHAR2
                    , x_PMV_Output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL)
IS
l_Err_Message	VARCHAR2(3200);
l_PMV_Sql       VARCHAR2(3200);
BEGIN
	PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl,
    P_SELECT_LIST =>'FACT.BACKLOG_NOT_STARTED  	"PJI_REP_MSR_1",
                    FACT.ACTIVE_BACKLOG  		"PJI_REP_MSR_2",
                    FACT.DORMANT_BACKLOG  		"PJI_REP_MSR_3",
                    FACT.TOTAL_ENDING_BACKLOG  	"PJI_REP_MSR_4",
                    FACT.PRIOR_TOTAL_ENDING_BACKLOG	"PJI_REP_MSR_5",
                    FACT.CHANGE_PERCENTAGE		"PJI_REP_MSR_6",
                    FACT.TOTAL_BOOKINGS_ITD		"PJI_REP_MSR_7",
                    FACT.BACKLOG_PERCENT_OF_BOOKINGS	"PJI_REP_MSR_8",
                    FACT.LOST_BACKLOG  			"PJI_REP_MSR_9",
                    FACT.REVENUE_AT_RISK			"PJI_REP_MSR_10",
                    FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1",
                    FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_2",
                    FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_3",
                    FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_4",
                    FACT.PJI_REP_TOTAL_5 "PJI_REP_TOTAL_5",
                    FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_6",
                    FACT.PJI_REP_TOTAL_7 "PJI_REP_TOTAL_7",
                    FACT.PJI_REP_TOTAL_8 "PJI_REP_TOTAL_8",
                    FACT.PJI_REP_TOTAL_9 "PJI_REP_TOTAL_9",
                    FACT.PJI_REP_TOTAL_10 "PJI_REP_TOTAL_10"'
		 	, P_SQL_STATEMENT => x_PMV_Sql
       		, P_PMV_OUTPUT => x_PMV_Output
			, P_REGION_CODE => 'PJI_REP_PB1'
			, P_PLSQL_DRIVER => 'PJI_PMV_BACKLOG.PLSQLDriver_PB1'
			, P_PLSQL_DRIVER_PARAMS => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
			  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
			  ', <<CURRENCY+FII_CURRENCIES>>'||
			  ', <<AS_OF_DATE>>'||
			  ', <<PERIOD_TYPE>>'||
			  ', <<VIEW_BY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CODE>> ');
END Get_SQL_PJI_REP_PB1;

PROCEDURE Get_SQL_PJI_REP_PB2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY  VARCHAR2
                    , x_PMV_Output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL)
IS
l_Err_Message	VARCHAR2(3200);
l_PMV_Sql       VARCHAR2(3200);
BEGIN
 PJI_PMV_ENGINE.Generate_SQL(P_PAGE_PARAMETER_TBL => p_page_parameter_tbl,
 P_SELECT_LIST => 'FACT.BEGINNING_BACKLOG	    "PJI_REP_MSR_1",
                    FACT.ORIGINAL_BOOKINGS	    "PJI_REP_MSR_2",
                    FACT.ADDITIONAL_BOOKINGS	"PJI_REP_MSR_3",
                    FACT.BOOKINGS_ADJUSTMENTS	"PJI_REP_MSR_4",
                    FACT.CANCELLATIONS		    "PJI_REP_MSR_5",
                    FACT.TOTAL_NET_BOOKINGS		"PJI_REP_MSR_6",
                    FACT.ACCRUED_REVENUE		"PJI_REP_MSR_7",
                    FACT.ENDING_REVENUE_AT_RISK	"PJI_REP_MSR_14",
                    FACT.ENDING_LOST_BACKLOG	"PJI_REP_MSR_8",
                    FACT.ENDING_BACKLOG		    "PJI_REP_MSR_9",
                    FACT.PRIOR_YEAR			    "PJI_REP_MSR_10",
                    FACT.ENDING_BACKLOG		    "PJI_REP_MSR_13",
                    FACT.CHANGE			        "PJI_REP_MSR_11"'
 	     , P_SQL_STATEMENT => x_PMV_Sql
             , P_PMV_OUTPUT => x_PMV_Output
             , P_REGION_CODE => 'PJI_REP_PB2'
             , P_PLSQL_DRIVER => 'PJI_PMV_BACKLOG.PLSQLDriver_PB2'
             , P_PLSQL_DRIVER_PARAMS => '  <<ORGANIZATION+FII_OPERATING_UNITS>>'||
			  ', <<ORGANIZATION+PJI_ORGANIZATIONS>>'||
			  ', <<CURRENCY+FII_CURRENCIES>>'||
			  ', <<AS_OF_DATE>>'||
			  ', <<PERIOD_TYPE>>'||
			  ', <<VIEW_BY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CATEGORY>>'||
			  ', <<PROJECT CLASSIFICATION+CLASS_CODE>> ');
END Get_SQL_PJI_REP_PB2;

--**********************************************************************
--   Project Backlog Summary - PB1
--**********************************************************************

FUNCTION PLSQLDriver_PB1(
  p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
, p_Organization		IN VARCHAR2
, p_Currency_Type		IN VARCHAR2
, p_As_Of_Date  		IN NUMBER
, p_Period_Type 		IN VARCHAR2
, p_View_BY 			IN VARCHAR2
, p_Classifications		IN VARCHAR2 DEFAULT NULL
, p_Class_Codes			IN VARCHAR2 DEFAULT NULL
)RETURN PJI_REP_PB1_TBL
IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_Total_AC_Backlog_Tab		PJI_REP_PB1_TBL:=PJI_REP_PB1_TBL();
l_Parse_Class_Codes		    VARCHAR2(1);

l_Top_Org_Index                 NUMBER:=0;
l_Top_Organization_Name         VARCHAR2(240);

/* Variables for TOTALS calculation*/

l_Backlog_Not_Started         NUMBER:=0;
l_Active_Backlog              NUMBER:=0;
l_Dormant_Backlog             NUMBER:=0;
l_Total_Ending_Backlog        NUMBER:=0;
l_Prior_Total_Ending_Backlog  NUMBER:=0;
l_Total_Bookings_Itd          NUMBER:=0;
l_Lost_Backlog                NUMBER:=0;
l_Revenue_At_Risk             NUMBER:=0;
l_Change_Percentage           NUMBER:=0;
l_Backlog_Percent_Of_Bookings NUMBER:=0;

l_curr_record_type_id         NUMBER:= 1;

x_Backlog_Not_Started         NUMBER:=0;
x_Active_Backlog              NUMBER:=0;
x_Dormant_Backlog             NUMBER:=0;
x_Total_Ending_Backlog        NUMBER:=0;
x_Prior_Total_Ending_Backlog  NUMBER:=0;
x_Total_Bookings_Itd          NUMBER:=0;
x_Lost_Backlog                NUMBER:=0;
x_Revenue_At_Risk             NUMBER:=0;
x_Change_Percentage           NUMBER:=0;


BEGIN
	/*
	** Place a call to all the parse API's which parse the
	** parameters passed by PMV and populate all the
	** temporary tables.
	*/
	PJI_PMV_ENGINE.Convert_Operating_Unit(p_Operating_Unit, p_View_BY);
	PJI_PMV_ENGINE.Convert_Organization(P_TOP_ORGANIZATION_ID => p_Organization,
                                        P_VIEW_BY => p_View_BY,
                                        p_Top_Organization_Name => l_Top_Organization_Name);
    	PJI_PMV_ENGINE.Convert_Time(p_As_Of_Date, p_Period_Type, p_View_By, 'Y', NULL, NULL,'Y');

	l_curr_record_type_id:=PJI_PMV_ENGINE.Convert_Currency_Record_Type(p_Currency_Type);

	/*
	** Determine the fact tables you choose to run the database
	** query on ( this step is what we call manual query re-write).
	*/
    	IF PJI_PMV_ENGINE.Convert_Classification(p_Classifications, p_Class_Codes, p_View_BY) = 'N' THEN
		/*
		** Code the SQL statement for all of the following conditions
		** 1. Current Year
		** 2. Prior Year
		** 3. SQL to generate rows with zero's for the view by dimension
		** Bulk-Collect the output into a pl/sql table to be returned to
		** pmv.
		*/
		SELECT PJI_REP_PB1( ORG_ID
			, ORGANIZATION_ID
			, TIME_ID
			, TIME_KEY
			, PROJECT_CLASS_ID
            , SUM( BACKLOG_NOT_STARTED )
			, SUM( ACTIVE_BACKLOG )
			, SUM( DORMANT_BACKLOG )
			, SUM( TOTAL_ENDING_BACKLOG )
			, SUM( PRIOR_TOTAL_ENDING_BACKLOG )
			, 0
            , SUM( TOTAL_BOOKINGS_ITD )
			, 0
            , SUM( LOST_BACKLOG )
       		, SUM( REVENUE_AT_RISK )
	        , 0
            , 0
            , 0
            , 0
            , 0
            , 0
            , 0
            , 0
            , 0
            , 0)
        BULK COLLECT INTO l_Total_AC_Backlog_Tab
		FROM
			( SELECT /*+ ORDERED */
				  HOU.NAME				ORG_ID
				, HORG.NAME				ORGANIZATION_ID
				, TIME.NAME				TIME_ID
				, DECODE(p_View_BY,'TM',TIME.ORDER_BY_ID,-1)	TIME_KEY
				, '-1'					PROJECT_CLASS_ID
				, DORMANT_BACKLOG_START 		                            BACKLOG_NOT_STARTED
				, ACTIVE_BACKLOG
				, DORMANT_BACKLOG_INACTIV               DORMANT_BACKLOG
				, DORMANT_BACKLOG_INACTIV
                   		  	+ ACTIVE_BACKLOG
                   			+ DORMANT_BACKLOG_START         TOTAL_ENDING_BACKLOG
				, 0                    	                PRIOR_TOTAL_ENDING_BACKLOG
				, 0 CHANGE_PERCENTAGE
                , INITIAL_FUNDING_AMOUNT
                    			+ ADDITIONAL_FUNDING_AMOUNT
                    			+ FUNDING_ADJUSTMENT_AMOUNT
                    			+ CANCELLED_FUNDING_AMOUNT      TOTAL_BOOKINGS_ITD
			    , 0 BACKLOG_PERCENT_OF_BOOKINGS
            	, LOST_BACKLOG				                                LOST_BACKLOG
				, REVENUE_AT_RISK
     	        , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
			FROM
				 PJI_PMV_ITD_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_AC_ORGO_F_MV FCT
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			UNION ALL
			SELECT /*+ ORDERED */
				  HOU.NAME					ORG_ID
				, HORG.NAME					ORGANIZATION_ID
				, TIME.NAME					TIME_ID
				, DECODE(p_View_BY,'TM',TIME.ORDER_BY_ID,-1)	TIME_KEY
				, '-1'	PROJECT_CLASS_ID
				, 0		BACKLOG_NOT_STARTED
				, 0		ACTIVE_BACKLOG
				, 0		DORMANT_BACKLOG
				, 0		TOTAL_ENDING_BACKLOG
				, DORMANT_BACKLOG_INACTIV
                   		   + ACTIVE_BACKLOG
                   		   + DORMANT_BACKLOG_START              PRIOR_TOTAL_ENDING_BACKLOG
				, 0 CHANGE_PERCENTAGE
                , 0					TOTAL_BOOKINGS_ITD
				, 0 BACKLOG_PERCENT_OF_BOOKINGS
                , 0					LOST_BACKLOG
				, 0     				REVENUE_AT_RISK
    	        , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
			FROM
				 PJI_PMV_ITD_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_AC_ORGO_F_MV FCT
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                		AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			UNION ALL
			SELECT NAME 	ORG_ID
				, '-1'	ORGANIZATION_ID
				, '-1'	TIME_ID
				, -1		TIME_KEY
				, '-1'		PROJECT_CLASS_ID
			    , 0		BACKLOG_NOT_STARTED
				, 0		ACTIVE_BACKLOG
				, 0		DORMANT_BACKLOG
				, 0		TOTAL_ENDING_BACKLOG
				, 0     PRIOR_TOTAL_ENDING_BACKLOG
				, 0 CHANGE_PERCENTAGE
                , 0		TOTAL_BOOKINGS_ITD
				, 0 BACKLOG_PERCENT_OF_BOOKINGS
                , 0		LOST_BACKLOG
				, 0     REVENUE_AT_RISK
	            , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
			FROM PJI_PMV_ORG_DIM_TMP
			WHERE NAME <> '-1'
			UNION ALL
			SELECT '-1' ORG_ID
				, NAME	ORGANIZATION_ID
				, '-1'	TIME_ID
				, -1	TIME_KEY
				, '-1'	PROJECT_CLASS_ID
                , 0		BACKLOG_NOT_STARTED
				, 0		ACTIVE_BACKLOG
				, 0		DORMANT_BACKLOG
				, 0		TOTAL_ENDING_BACKLOG
				, 0    	PRIOR_TOTAL_ENDING_BACKLOG
				, 0 CHANGE_PERCENTAGE
                , 0		TOTAL_BOOKINGS_ITD
				, 0 BACKLOG_PERCENT_OF_BOOKINGS
                , 0		LOST_BACKLOG
				, 0    	REVENUE_AT_RISK
	            , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
               FROM PJI_PMV_ORGZ_DIM_TMP
			WHERE NAME <> '-1'
			UNION ALL
            SELECT  '-1' 	ORG_ID
				, '-1'	ORGANIZATION_ID
				, NAME	TIME_ID
				, ID	TIME_KEY
				, '-1'	PROJECT_CLASS_ID
                		, 0	BACKLOG_NOT_STARTED
				, 0	ACTIVE_BACKLOG
				, 0	DORMANT_BACKLOG
				, 0	TOTAL_ENDING_BACKLOG
				, 0 PRIOR_TOTAL_ENDING_BACKLOG
				, 0 CHANGE_PERCENTAGE
                , 0	TOTAL_BOOKINGS_ITD
				, 0 BACKLOG_PERCENT_OF_BOOKINGS
                , 0	LOST_BACKLOG
				, 0 REVENUE_AT_RISK
       	        , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
   	FROM PJI_PMV_TIME_DIM_TMP
	WHERE NAME <> '-1')
	GROUP BY
		ORG_ID
		, ORGANIZATION_ID
		, TIME_KEY
		, TIME_ID
		, PROJECT_CLASS_ID;
	ELSE
		/*
		** Code the SQL statement for all of the following conditions
		** 1. Current Year
		** 2. Prior Year
		** 3. SQL to generate rows with zero's for the view by dimension
		*/
		SELECT PJI_REP_PB1
            ( ORG_ID
			, ORGANIZATION_ID
			, TIME_ID
			, TIME_KEY
			, PROJECT_CLASS_ID
            , SUM( BACKLOG_NOT_STARTED )
			, SUM( ACTIVE_BACKLOG )
			, SUM( DORMANT_BACKLOG )
			, SUM( TOTAL_ENDING_BACKLOG )
			, SUM( PRIOR_TOTAL_ENDING_BACKLOG )
			, 0
            , SUM( TOTAL_BOOKINGS_ITD )
			, 0
            , SUM( LOST_BACKLOG )
            , SUM( REVENUE_AT_RISK )
	        , 0
            , 0
            , 0
            , 0
            , 0
            , 0
            , 0
            , 0
            , 0
            , 0 )
		BULK COLLECT INTO l_Total_AC_Backlog_Tab
		FROM
			( SELECT /*+ ORDERED */
				  HOU.NAME				ORG_ID
				, HORG.NAME				ORGANIZATION_ID
				, TIME.NAME				TIME_ID
				, DECODE(p_View_BY,'TM',TIME.ORDER_BY_ID,-1)	TIME_KEY
				, CLS.NAME					PROJECT_CLASS_ID
				, DORMANT_BACKLOG_START 	                BACKLOG_NOT_STARTED
				, ACTIVE_BACKLOG
               			, DORMANT_BACKLOG_INACTIV                       DORMANT_BACKLOG
				, DORMANT_BACKLOG_INACTIV
                		+ ACTIVE_BACKLOG
                		+ DORMANT_BACKLOG_START                 TOTAL_ENDING_BACKLOG
				, 0                    	                        PRIOR_TOTAL_ENDING_BACKLOG
				, 0 CHANGE_PERCENTAGE
                , INITIAL_FUNDING_AMOUNT
               			+ ADDITIONAL_FUNDING_AMOUNT
               			+ FUNDING_ADJUSTMENT_AMOUNT
               			+ CANCELLED_FUNDING_AMOUNT	    	TOTAL_BOOKINGS_ITD
				, 0 BACKLOG_PERCENT_OF_BOOKINGS
                , LOST_BACKLOG				        LOST_BACKLOG
				, REVENUE_AT_RISK
	            , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
			FROM    PJI_PMV_ITD_DIM_TMP TIME
				    , PJI_PMV_ORGZ_DIM_TMP HORG
				    , PJI_PMV_CLS_DIM_TMP CLS
				    , PJI_AC_CLSO_F_MV FCT
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
				  HOU.NAME					ORG_ID
				, HORG.NAME					ORGANIZATION_ID
				, TIME.NAME					TIME_ID
				, DECODE(p_View_BY,'TM',TIME.ORDER_BY_ID,-1)	TIME_KEY
				, CLS.NAME					PROJECT_CLASS_ID
				, 0		BACKLOG_NOT_STARTED
				, 0		ACTIVE_BACKLOG
				, 0		DORMANT_BACKLOG
				, 0		TOTAL_ENDING_BACKLOG
				, DORMANT_BACKLOG_INACTIV
                  			+ ACTIVE_BACKLOG
                   			+ DORMANT_BACKLOG_START   		PRIOR_TOTAL_ENDING_BACKLOG
				, 0 CHANGE_PERCENTAGE
                , 0						TOTAL_BOOKINGS_ITD
				, 0 BACKLOG_PERCENT_OF_BOOKINGS
                , 0						LOST_BACKLOG
				, 0     				REVENUE_AT_RISK
	            , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
			FROM
				PJI_PMV_ITD_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_CLS_DIM_TMP CLS
				, PJI_AC_CLSO_F_MV FCT
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
			SELECT NAME 	ORG_ID
				, '-1'	ORGANIZATION_ID
				, '-1'	TIME_ID
				, -1		TIME_KEY
				, '-1'	PROJECT_CLASS_ID
                		, 0		BACKLOG_NOT_STARTED
				, 0		ACTIVE_BACKLOG
				, 0		DORMANT_BACKLOG
				, 0		TOTAL_ENDING_BACKLOG
				, 0    	PRIOR_TOTAL_ENDING_BACKLOG
				, 0 CHANGE_PERCENTAGE
                , 0		TOTAL_BOOKINGS_ITD
				, 0 BACKLOG_PERCENT_OF_BOOKINGS
                , 0		LOST_BACKLOG
				, 0    	REVENUE_AT_RISK
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
               FROM PJI_PMV_ORG_DIM_TMP
			WHERE NAME <> '-1'
			UNION ALL
			SELECT '-1' ORG_ID
				, NAME	ORGANIZATION_ID
				, '-1'	TIME_ID
				, -1	TIME_KEY
				, '-1'	PROJECT_CLASS_ID
                		, 0		BACKLOG_NOT_STARTED
				, 0		ACTIVE_BACKLOG
				, 0		DORMANT_BACKLOG
				, 0		TOTAL_ENDING_BACKLOG
				, 0    	PRIOR_TOTAL_ENDING_BACKLOG
				, 0 CHANGE_PERCENTAGE
                , 0		TOTAL_BOOKINGS_ITD
				, 0 BACKLOG_PERCENT_OF_BOOKINGS
                , 0		LOST_BACKLOG
				, 0    	REVENUE_AT_RISK
	            , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
               FROM PJI_PMV_ORGZ_DIM_TMP
			WHERE NAME <> '-1'
			UNION ALL
			SELECT  '-1' 	ORG_ID
				, '-1'	ORGANIZATION_ID
				, NAME	TIME_ID
				, ID		TIME_KEY
				, '-1'		PROJECT_CLASS_ID
                , 0		BACKLOG_NOT_STARTED
				, 0		ACTIVE_BACKLOG
				, 0		DORMANT_BACKLOG
				, 0		TOTAL_ENDING_BACKLOG
				, 0    	PRIOR_TOTAL_ENDING_BACKLOG
				, 0 CHANGE_PERCENTAGE
                , 0		TOTAL_BOOKINGS_ITD
				, 0 BACKLOG_PERCENT_OF_BOOKINGS
                , 0		LOST_BACKLOG
				, 0    	REVENUE_AT_RISK
	            , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                FROM PJI_PMV_TIME_DIM_TMP
			WHERE NAME <> '-1'
			UNION ALL
			SELECT  '-1' 	ORG_ID
				, '-1'	ORGANIZATION_ID
				, '-1'	TIME_ID
				, -1		TIME_KEY
				, NAME		PROJECT_CLASS_ID
                , 0		BACKLOG_NOT_STARTED
				, 0		ACTIVE_BACKLOG
				, 0		DORMANT_BACKLOG
				, 0		TOTAL_ENDING_BACKLOG
				, 0     PRIOR_TOTAL_ENDING_BACKLOG
				, 0 CHANGE_PERCENTAGE
                , 0		TOTAL_BOOKINGS_ITD
				, 0 BACKLOG_PERCENT_OF_BOOKINGS
                , 0		LOST_BACKLOG
				, 0     REVENUE_AT_RISK
	            , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
                , 0
            FROM PJI_PMV_CLS_DIM_TMP
			WHERE NAME <> '-1') FACT
		GROUP BY
			ORG_ID
			, ORGANIZATION_ID
			, TIME_KEY
			, TIME_ID
			, PROJECT_CLASS_ID;
	END IF;

FOR i in 1..l_Total_AC_Backlog_Tab.COUNT
    LOOP
        IF p_View_By = 'OG' THEN
            IF l_Total_AC_Backlog_Tab(i).ORGANIZATION_ID = l_Top_Organization_Name THEN
                l_Top_Org_Index:=i;

            x_Backlog_Not_Started   :=NVL(l_Total_AC_Backlog_Tab(i).BACKLOG_NOT_STARTED,0);
            x_Active_Backlog        :=NVL(l_Total_AC_Backlog_Tab(i).ACTIVE_BACKLOG,0);
            x_Dormant_Backlog       :=NVL(l_Total_AC_Backlog_Tab(i).DORMANT_BACKLOG,0);
            x_Total_Ending_Backlog       :=NVL(l_Total_AC_Backlog_Tab(i).TOTAL_ENDING_BACKLOG,0);
            x_Prior_Total_Ending_Backlog :=NVL(l_Total_AC_Backlog_Tab(i).PRIOR_TOTAL_ENDING_BACKLOG,0);
            x_Total_Bookings_Itd  :=NVL(l_Total_AC_Backlog_Tab(i).TOTAL_BOOKINGS_ITD,0);
            x_Lost_Backlog        :=NVL(l_Total_AC_Backlog_Tab(i).LOST_BACKLOG,0);
            x_Revenue_At_Risk     :=NVL(l_Total_AC_Backlog_Tab(i).REVENUE_AT_RISK,0);


            ELSE

            l_Backlog_Not_Started :=l_Backlog_Not_Started +
                        NVL(l_Total_AC_Backlog_Tab(i).BACKLOG_NOT_STARTED,0);
            l_Active_Backlog      :=l_Active_Backlog +
                        NVL(l_Total_AC_Backlog_Tab(i).ACTIVE_BACKLOG,0);
            l_Dormant_Backlog     :=l_Dormant_Backlog +
                        NVL(l_Total_AC_Backlog_Tab(i).DORMANT_BACKLOG,0);
            l_Total_Ending_Backlog   :=l_Total_Ending_Backlog +
                        NVL(l_Total_AC_Backlog_Tab(i).TOTAL_ENDING_BACKLOG,0);
            l_Prior_Total_Ending_Backlog:=l_Prior_Total_Ending_Backlog +
                        NVL(l_Total_AC_Backlog_Tab(i).PRIOR_TOTAL_ENDING_BACKLOG,0);
            l_Total_Bookings_Itd   :=l_Total_Bookings_Itd +
                        NVL(l_Total_AC_Backlog_Tab(i).TOTAL_BOOKINGS_ITD,0);
            l_Lost_Backlog        :=l_Lost_Backlog +
                        NVL(l_Total_AC_Backlog_Tab(i).LOST_BACKLOG,0);
            l_Revenue_At_Risk   :=l_Revenue_At_Risk +
                        NVL(l_Total_AC_Backlog_Tab(i).REVENUE_AT_RISK,0);
            END IF;
         ELSE
            l_Backlog_Not_Started :=l_Backlog_Not_Started +
                        NVL(l_Total_AC_Backlog_Tab(i).BACKLOG_NOT_STARTED,0);
            l_Active_Backlog      :=l_Active_Backlog +
                        NVL(l_Total_AC_Backlog_Tab(i).ACTIVE_BACKLOG,0);
            l_Dormant_Backlog     :=l_Dormant_Backlog +
                        NVL(l_Total_AC_Backlog_Tab(i).DORMANT_BACKLOG,0);
            l_Total_Ending_Backlog   :=l_Total_Ending_Backlog +
                        NVL(l_Total_AC_Backlog_Tab(i).TOTAL_ENDING_BACKLOG,0);
            l_Prior_Total_Ending_Backlog:=l_Prior_Total_Ending_Backlog +
                        NVL(l_Total_AC_Backlog_Tab(i).PRIOR_TOTAL_ENDING_BACKLOG,0);
            l_Total_Bookings_Itd   :=l_Total_Bookings_Itd +
                        NVL(l_Total_AC_Backlog_Tab(i).TOTAL_BOOKINGS_ITD,0);
            l_Lost_Backlog        :=l_Lost_Backlog +
                        NVL(l_Total_AC_Backlog_Tab(i).LOST_BACKLOG,0);
            l_Revenue_At_Risk   :=l_Revenue_At_Risk +
                        NVL(l_Total_AC_Backlog_Tab(i).REVENUE_AT_RISK,0);
    END IF;

    IF NVL(l_Total_AC_Backlog_Tab(i).PRIOR_TOTAL_ENDING_BACKLOG, 0)=0 THEN
         l_Total_AC_Backlog_Tab(i).CHANGE_PERCENTAGE:= NULL;
    ELSE
         l_Total_AC_Backlog_Tab(i).CHANGE_PERCENTAGE:=
        (l_Total_AC_Backlog_Tab(i).TOTAL_ENDING_BACKLOG
            -l_Total_AC_Backlog_Tab(i).PRIOR_TOTAL_ENDING_BACKLOG)*100
                /ABS(l_Total_AC_Backlog_Tab(i).PRIOR_TOTAL_ENDING_BACKLOG);
    END IF;
    IF  NVL(l_Total_AC_Backlog_Tab(i).TOTAL_BOOKINGS_ITD, 0)=0 THEN
                l_Total_AC_Backlog_Tab(i).BACKLOG_PERCENT_OF_BOOKINGS :=NULL;
    ELSE
        l_Total_AC_Backlog_Tab(i).BACKLOG_PERCENT_OF_BOOKINGS:=
               l_Total_AC_Backlog_Tab(i).TOTAL_ENDING_BACKLOG*100
               /l_Total_AC_Backlog_Tab(i).TOTAL_BOOKINGS_ITD;
    END IF;
END LOOP;

IF p_View_by ='OG' THEN
   l_Total_AC_Backlog_Tab(l_Top_Org_Index).BACKLOG_NOT_STARTED
            :=NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).BACKLOG_NOT_STARTED,0)
             - l_Backlog_Not_Started;
   l_Total_AC_Backlog_Tab(l_Top_Org_Index).ACTIVE_BACKLOG
            :=NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).ACTIVE_BACKLOG,0)
             - l_Active_Backlog;
   l_Total_AC_Backlog_Tab(l_Top_Org_Index).DORMANT_BACKLOG
            :=NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).DORMANT_BACKLOG,0)
            - l_Dormant_Backlog;
   l_Total_AC_Backlog_Tab(l_Top_Org_Index).TOTAL_ENDING_BACKLOG
            :=NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).TOTAL_ENDING_BACKLOG,0)
            - l_Total_Ending_Backlog;
   l_Total_AC_Backlog_Tab(l_Top_Org_Index).PRIOR_TOTAL_ENDING_BACKLOG
            :=NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).PRIOR_TOTAL_ENDING_BACKLOG,0)
            - l_Prior_Total_Ending_Backlog;
   l_Total_AC_Backlog_Tab(l_Top_Org_Index).TOTAL_BOOKINGS_ITD
            :=NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).TOTAL_BOOKINGS_ITD,0)
            - l_Total_Bookings_Itd;
   l_Total_AC_Backlog_Tab(l_Top_Org_Index).LOST_BACKLOG
            :=NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).LOST_BACKLOG,0)
            - l_Lost_Backlog;
   l_Total_AC_Backlog_Tab(l_Top_Org_Index).REVENUE_AT_RISK
            :=NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).REVENUE_AT_RISK,0)
            - l_Revenue_At_Risk;

    IF NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).PRIOR_TOTAL_ENDING_BACKLOG, 0)=0 THEN
         l_Total_AC_Backlog_Tab(l_Top_Org_Index).CHANGE_PERCENTAGE:= NULL;
    ELSE
         l_Total_AC_Backlog_Tab(l_Top_Org_Index).CHANGE_PERCENTAGE:=
        (l_Total_AC_Backlog_Tab(l_Top_Org_Index).TOTAL_ENDING_BACKLOG
            -l_Total_AC_Backlog_Tab(l_Top_Org_Index).PRIOR_TOTAL_ENDING_BACKLOG)*100
                /ABS(l_Total_AC_Backlog_Tab(l_Top_Org_Index).PRIOR_TOTAL_ENDING_BACKLOG);
    END IF;
    IF  NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).TOTAL_BOOKINGS_ITD, 0)=0 THEN
                l_Total_AC_Backlog_Tab(l_Top_Org_Index).BACKLOG_PERCENT_OF_BOOKINGS :=NULL;
    ELSE
        l_Total_AC_Backlog_Tab(l_Top_Org_Index).BACKLOG_PERCENT_OF_BOOKINGS:=
               l_Total_AC_Backlog_Tab(l_Top_Org_Index).TOTAL_ENDING_BACKLOG*100
               /l_Total_AC_Backlog_Tab(l_Top_Org_Index).TOTAL_BOOKINGS_ITD;
    END IF;

IF
    NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).BACKLOG_NOT_STARTED,0)=0 AND
    NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).ACTIVE_BACKLOG,0)=0 AND
    NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).DORMANT_BACKLOG,0)=0 AND
    NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).TOTAL_ENDING_BACKLOG,0)=0 AND
    NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).PRIOR_TOTAL_ENDING_BACKLOG,0)=0 AND
    NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).TOTAL_BOOKINGS_ITD,0)=0 AND
    NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).LOST_BACKLOG,0)=0 AND
    NVL(l_Total_AC_Backlog_Tab(l_Top_Org_Index).REVENUE_AT_RISK,0)=0

THEN
    l_Total_AC_Backlog_Tab.DELETE(l_Top_Org_Index);
 END IF;

            l_Backlog_Not_Started        :=x_Backlog_Not_Started;
            l_Active_Backlog             :=x_Active_Backlog;
            l_Dormant_Backlog            :=x_Dormant_Backlog;
            l_Total_Ending_Backlog       :=x_Total_Ending_Backlog;
            l_Prior_Total_Ending_Backlog :=x_Prior_Total_Ending_Backlog;
            l_Total_Bookings_Itd         :=x_Total_Bookings_Itd;
            l_Lost_Backlog               :=x_Lost_Backlog;
            l_Revenue_At_Risk            :=x_Revenue_At_Risk;

END IF;



IF l_Total_AC_Backlog_Tab.COUNT >0 THEN
  FOR i in l_Total_AC_Backlog_Tab.FIRST..l_Total_AC_Backlog_Tab.LAST
      LOOP
        IF l_Total_AC_Backlog_Tab.EXISTS(i) THEN
                    l_Total_AC_Backlog_Tab(i).PJI_REP_TOTAL_1:= l_Backlog_Not_Started;
                    l_Total_AC_Backlog_Tab(i).PJI_REP_TOTAL_2:= l_Active_Backlog;
                    l_Total_AC_Backlog_Tab(i).PJI_REP_TOTAL_3:= l_Dormant_Backlog;
                    l_Total_AC_Backlog_Tab(i).PJI_REP_TOTAL_4:= l_Total_Ending_Backlog;
                    l_Total_AC_Backlog_Tab(i).PJI_REP_TOTAL_5:= l_Prior_Total_Ending_Backlog;
                    l_Total_AC_Backlog_Tab(i).PJI_REP_TOTAL_7:= l_Total_Bookings_Itd;
                    l_Total_AC_Backlog_Tab(i).PJI_REP_TOTAL_9:= l_Lost_Backlog;
                    l_Total_AC_Backlog_Tab(i).PJI_REP_TOTAL_10:=l_Revenue_At_Risk;

        IF l_Prior_Total_Ending_Backlog = 0 THEN
        l_Total_AC_Backlog_Tab(i).PJI_REP_TOTAL_6 :=NULL;
          ELSE
        l_Total_AC_Backlog_Tab(i).PJI_REP_TOTAL_6:=
                    (l_Total_Ending_Backlog - l_Prior_Total_Ending_Backlog)*100
                    /ABS(l_Prior_Total_Ending_Backlog);
        END IF;

        IF l_Total_Bookings_Itd = 0 THEN
        l_Total_AC_Backlog_Tab(i).PJI_REP_TOTAL_8 :=NULL;
          ELSE
        l_Total_AC_Backlog_Tab(i).PJI_REP_TOTAL_8 :=
                    (l_Total_Ending_Backlog)*100/(l_Total_Bookings_Itd);
        END IF;
     END IF;
  END LOOP;
END IF;
	/*
	** Return the bulk collected table back to pmv.
	*/
	COMMIT;
	RETURN l_Total_AC_Backlog_Tab;
END PLSQLDriver_PB1;


--**********************************************************************
--   Project Backlog Trend - PB2
--**********************************************************************

FUNCTION PLSQLDriver_PB2 (
  p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
, p_Organization		IN VARCHAR2
, p_Currency_Type		IN VARCHAR2
, p_As_Of_Date          IN NUMBER
, p_Period_Type 		IN VARCHAR2
, p_View_BY 			IN VARCHAR2
, p_Classifications		IN VARCHAR2 DEFAULT NULL
, p_Class_Codes			IN VARCHAR2 DEFAULT NULL
) RETURN PJI_REP_PB2_TBL
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_Backlog_Trend_Tab		PJI_REP_PB2_TBL:=PJI_REP_PB2_TBL();
l_Parse_Class_Codes		      VARCHAR2(1);
l_Ending_Backlog_itd          NUMBER;
l_Ending_Lost_Backlog_itd     NUMBER;
l_Ending_Revenue_at_Risk_itd  NUMBER;
l_Ending_Prior_Backlog_itd    NUMBER;

l_Top_Organization_Name		VARCHAR2(240);
l_curr_record_type_id           NUMBER:= 1;

BEGIN
	/*
	** Place a call to all the parse API's which parse the
	** parameters passed by PMV and populate all the
	** temporary tables.
	*/
	PJI_PMV_ENGINE.Convert_Operating_Unit(p_Operating_Unit, p_View_BY);
	PJI_PMV_ENGINE.Convert_Organization(p_Top_Organization_ID=>p_Organization, p_View_BY=>p_View_BY, p_Top_Organization_Name=>l_Top_Organization_Name);
	PJI_PMV_ENGINE.Convert_Time(p_As_Of_Date, p_Period_Type, p_View_By, 'Y', NULL, NULL, 'Y');

	l_curr_record_type_id:=PJI_PMV_ENGINE.Convert_Currency_Record_Type(p_Currency_Type);
	/*
	** Determine the fact tables you choose to run the database
	** query on ( this step is what we call manual query re-write).
	*/
	IF PJI_PMV_ENGINE.Convert_Classification(p_Classifications, p_Class_Codes, p_View_BY) = 'N' THEN
		/*
		** Code the SQL statement for all of the following conditions
		** 1. Current Year
		** 2. Prior Year
		** 3. SQL to generate rows with zero's for the view by dimension
		** Bulk-Collect the output into a pl/sql table to be returned to
		** pmv.
		*/
		SELECT PJI_REP_PB2( ORG_ID
			, ORGANIZATION_ID
			, TIME_ID
			, TIME_KEY
			, PROJECT_CLASS_ID
			, 0
            , SUM( ORIGINAL_BOOKINGS )
			, SUM( ADDITIONAL_BOOKINGS )
			, SUM( BOOKINGS_ADJUSTMENTS )
			, -SUM( CANCELLATIONS )
			, SUM( TOTAL_NET_BOOKINGS )
			, SUM( ACCRUED_REVENUE )
       		, SUM( PRIOR_YEAR )
       		, SUM( ENDING_LOST_BACKLOG )
       		, SUM( ENDING_BACKLOG )
       		, SUM( ENDING_REVENUE_AT_RISK)
       		, SUM( LOST_BACKLOG )
       		, SUM( BACKLOG )
       		, SUM( REVENUE_AT_RISK )
            , 0 )
        BULK COLLECT INTO l_Backlog_Trend_Tab
		FROM
			( SELECT /*+ ORDERED */
				  HOU.NAME				ORG_ID
				, HORG.NAME				ORGANIZATION_ID
				, TIME.NAME				TIME_ID
				, DECODE(p_View_BY, 'TM', TIME.ORDER_BY_ID, -1)	TIME_KEY
				, '-1'					PROJECT_CLASS_ID
				, 0
                , INITIAL_FUNDING_AMOUNT            ORIGINAL_BOOKINGS
               	, ADDITIONAL_FUNDING_AMOUNT         ADDITIONAL_BOOKINGS
				, FUNDING_ADJUSTMENT_AMOUNT         BOOKINGS_ADJUSTMENTS
           		, CANCELLED_FUNDING_AMOUNT          CANCELLATIONS
				, INITIAL_FUNDING_AMOUNT
                   			+ ADDITIONAL_FUNDING_AMOUNT
                   			+ FUNDING_ADJUSTMENT_AMOUNT
                   			+ CANCELLED_FUNDING_AMOUNT	TOTAL_NET_BOOKINGS
				, REVENUE	                            ACCRUED_REVENUE
				, 0                                 	PRIOR_YEAR
           		, 0                                     ENDING_LOST_BACKLOG
           		, 0                                     ENDING_BACKLOG
           		, 0                                 	ENDING_REVENUE_AT_RISK
           		, LOST_BACKLOG
		    	, DORMANT_BACKLOG_INACTIV
                  			+ ACTIVE_BACKLOG
                   			+ DORMANT_BACKLOG_START     BACKLOG
       			, REVENUE_AT_RISK                       REVENUE_AT_RISK
                , 0
            FROM
				PJI_PMV_TIME_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_AC_ORGO_F_MV FCT
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			UNION ALL
			SELECT /*+ ORDERED */
				  HOU.NAME					ORG_ID
				, HORG.NAME					ORGANIZATION_ID
				, TIME.NAME					TIME_ID
				, DECODE(p_View_BY,'TM',TIME.ORDER_BY_ID,-1)	TIME_KEY
				, '-1'	PROJECT_CLASS_ID
				, 0
                , 0	ORIGINAL_BOOKINGS
				, 0	ADDITIONAL_BOOKINGS
				, 0	BOOKINGS_ADJUSTMENTS
				, 0	CANCELLATIONS
				, 0	TOTAL_NET_BOOKINGS
				, 0	ACCRUED_REVENUE
				, DORMANT_BACKLOG_INACTIV
                			+ ACTIVE_BACKLOG
                  			+ DORMANT_BACKLOG_START     PRIOR_YEAR
           		, 0                                     ENDING_LOST_BACKLOG
           		, 0                                     ENDING_BACKLOG
           		, 0                                 	ENDING_REVENUE_AT_RISK
           		, 0                                     LOST_BACKLOG
    	    	, 0                                     BACKLOG
           		, 0                                     REVENUE_AT_RISK
                , 0
               FROM
				PJI_PMV_TIME_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_AC_ORGO_F_MV FCT
				, PJI_PMV_ORG_DIM_TMP HOU

			WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                		AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id
			UNION ALL
        SELECT  '-1' 	ORG_ID
				, '-1'	ORGANIZATION_ID
				, NAME	TIME_ID
				, ORDER_BY_ID		TIME_KEY
				, '-1'	PROJECT_CLASS_ID
			   	, 0
                , 0	ORIGINAL_BOOKINGS
				, 0	ADDITIONAL_BOOKINGS
				, 0	BOOKINGS_ADJUSTMENTS
				, 0	CANCELLATIONS
				, 0 TOTAL_NET_BOOKINGS
				, 0	ACCRUED_REVENUE
				, 0 PRIOR_YEAR
           		, 0 ENDING_LOST_BACKLOG
           		, 0 ENDING_BACKLOG
           		, 0 ENDING_REVENUE_AT_RISK
           		, 0 LOST_BACKLOG
    	    	, 0 BACKLOG
           		, 0 REVENUE_AT_RISK
           	    , 0
            FROM PJI_PMV_TIME_DIM_TMP
			WHERE NAME <> '-1')
    GROUP BY
		ORG_ID
		, ORGANIZATION_ID
		, TIME_KEY
		, TIME_ID
		, PROJECT_CLASS_ID ORDER BY TIME_KEY ASC;

SELECT  /*+ ORDERED */
	SUM( DORMANT_BACKLOG_INACTIV
             + ACTIVE_BACKLOG
             + DORMANT_BACKLOG_START ), SUM(LOST_BACKLOG), SUM(REVENUE_AT_RISK)
INTO    l_Ending_Backlog_itd, l_Ending_Lost_Backlog_itd, l_Ending_Revenue_at_Risk_itd
FROM   	PJI_PMV_ITD_DIM_TMP TIME
	    , PJI_PMV_ORGZ_DIM_TMP HORG
	    , PJI_AC_ORGO_F_MV FCT
	    , PJI_PMV_ORG_DIM_TMP HOU
WHERE
		FCT.ORG_ID = HOU.ID
		AND FCT.ORGANIZATION_ID = HORG.ID
		AND FCT.TIME_ID = TIME.ID
		AND TIME.ID IS NOT NULL
		AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
        AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
		AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id;
SELECT /*+ ORDERED */  SUM( DORMANT_BACKLOG_INACTIV
              + ACTIVE_BACKLOG
              + DORMANT_BACKLOG_START )
INTO    l_Ending_Prior_Backlog_itd
FROM   	PJI_PMV_ITD_DIM_TMP TIME
	, PJI_PMV_ORGZ_DIM_TMP HORG
	, PJI_AC_ORGO_F_MV FCT
	, PJI_PMV_ORG_DIM_TMP HOU
WHERE
				FCT.ORG_ID = HOU.ID
				AND FCT.ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.PRIOR_ID
				AND TIME.PRIOR_ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id;
	ELSE
		/*
		** Code the SQL statement for all of the following conditions
		** 1. Current Year
		** 2. Prior Year
		** 3. SQL to generate rows with zero's for the view by dimension
		*/
		SELECT PJI_REP_PB2( ORG_ID
			, ORGANIZATION_ID
			, TIME_ID
			, TIME_KEY
			, PROJECT_CLASS_ID
			, 0
            , SUM( ORIGINAL_BOOKINGS )
			, SUM( ADDITIONAL_BOOKINGS )
			, SUM( BOOKINGS_ADJUSTMENTS )
			, -SUM( CANCELLATIONS )
			, SUM( TOTAL_NET_BOOKINGS )
			, SUM( ACCRUED_REVENUE )
        	, SUM( PRIOR_YEAR )
        	, SUM( ENDING_LOST_BACKLOG )
            , SUM( ENDING_BACKLOG )
            , SUM( ENDING_REVENUE_AT_RISK)
            , SUM( LOST_BACKLOG )
            , SUM( BACKLOG )
            , SUM( REVENUE_AT_RISK )
		    , 0 )
        BULK COLLECT INTO l_Backlog_Trend_Tab
		FROM
			( SELECT /*+ ORDERED */
				  HOU.NAME				ORG_ID
				, HORG.NAME				ORGANIZATION_ID
				, TIME.NAME				TIME_ID
				, DECODE(p_View_BY, 'TM',TIME.ORDER_BY_ID, -1)	TIME_KEY
				, CLS.NAME					PROJECT_CLASS_ID
				, 0
                , INITIAL_FUNDING_AMOUNT            ORIGINAL_BOOKINGS
           			, ADDITIONAL_FUNDING_AMOUNT         ADDITIONAL_BOOKINGS
				, FUNDING_ADJUSTMENT_AMOUNT         BOOKINGS_ADJUSTMENTS
            			, CANCELLED_FUNDING_AMOUNT          CANCELLATIONS
	        		, INITIAL_FUNDING_AMOUNT
                    			+ ADDITIONAL_FUNDING_AMOUNT
                    			+ FUNDING_ADJUSTMENT_AMOUNT
                    			+ CANCELLED_FUNDING_AMOUNT	TOTAL_NET_BOOKINGS
				, REVENUE	                                ACCRUED_REVENUE
				, 0                                 	PRIOR_YEAR
                , 0                                     ENDING_LOST_BACKLOG
                , 0                                     ENDING_BACKLOG
                , 0                                 	ENDING_REVENUE_AT_RISK
                , LOST_BACKLOG
				, DORMANT_BACKLOG_INACTIV
                  		+ ACTIVE_BACKLOG
                   		+ DORMANT_BACKLOG_START                 BACKLOG
                , REVENUE_AT_RISK                       REVENUE_AT_RISK
			    , 0
            FROM
				PJI_PMV_TIME_DIM_TMP TIME
				,PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_CLS_DIM_TMP CLS
				, PJI_AC_CLSO_F_MV FCT
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
				  HOU.NAME					ORG_ID
				, HORG.NAME					ORGANIZATION_ID
				, TIME.NAME					TIME_ID
				, DECODE(p_View_BY,'TM',TIME.ORDER_BY_ID,-1)	TIME_KEY
				, '-1'	PROJECT_CLASS_ID
				, 0
                , 0	ORIGINAL_BOOKINGS
				, 0	ADDITIONAL_BOOKINGS
				, 0	BOOKINGS_ADJUSTMENTS
				, 0	CANCELLATIONS
				, 0	TOTAL_NET_BOOKINGS
				, 0	ACCRUED_REVENUE
                , DORMANT_BACKLOG_INACTIV
                 			+ ACTIVE_BACKLOG
                   			+ DORMANT_BACKLOG_START   	PRIOR_YEAR
                , 0                                     ENDING_LOST_BACKLOG
                , 0                                     ENDING_BACKLOG
                , 0                                 	ENDING_REVENUE_AT_RISK
                , 0                                     LOST_BACKLOG
			    , 0                                     BACKLOG
                , 0                                     REVENUE_AT_RISK
			    , 0
            FROM
				PJI_PMV_TIME_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_CLS_DIM_TMP CLS
				, PJI_AC_CLSO_F_MV FCT
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
			SELECT  '-1' 	ORG_ID
				, '-1'	ORGANIZATION_ID
				, NAME	TIME_ID
				, ORDER_BY_ID		TIME_KEY
				, '-1'	PROJECT_CLASS_ID
          		, 0
                , 0	ORIGINAL_BOOKINGS
				, 0	ADDITIONAL_BOOKINGS
				, 0	BOOKINGS_ADJUSTMENTS
				, 0	CANCELLATIONS
				, 0 TOTAL_NET_BOOKINGS
				, 0	ACCRUED_REVENUE
				, 0 PRIOR_YEAR
                , 0 ENDING_LOST_BACKLOG
                , 0 ENDING_BACKLOG
               	, 0 ENDING_REVENUE_AT_RISK
                , 0 LOST_BACKLOG
			    , 0 BACKLOG
                , 0 REVENUE_AT_RISK
                , 0
            FROM PJI_PMV_TIME_DIM_TMP
			WHERE NAME <> '-1'
        ) FACT
		GROUP BY
			ORG_ID
			, ORGANIZATION_ID
			, TIME_KEY
			, TIME_ID
			, PROJECT_CLASS_ID ORDER BY TIME_KEY ASC;

SELECT /*+ ORDERED */  SUM( DORMANT_BACKLOG_INACTIV
            + ACTIVE_BACKLOG
            + DORMANT_BACKLOG_START), SUM(LOST_BACKLOG), SUM(REVENUE_AT_RISK)
INTO        l_Ending_Backlog_itd,
            l_Ending_Lost_Backlog_itd,
            l_Ending_Revenue_at_Risk_itd
            FROM
				PJI_PMV_ITD_DIM_TMP TIME
				, PJI_PMV_ORGZ_DIM_TMP HORG
				, PJI_PMV_CLS_DIM_TMP CLS
				, PJI_AC_CLSO_F_MV FCT
				, PJI_PMV_ORG_DIM_TMP HOU
			WHERE
				FCT.PROJECT_ORG_ID = HOU.ID
				AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				AND FCT.TIME_ID = TIME.ID
				AND TIME.ID IS NOT NULL
				AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                		AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				AND FCT.PROJECT_CLASS_ID = CLS.ID
				AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id;
SELECT  /*+ ORDERED */
	SUM( DORMANT_BACKLOG_INACTIV
              + ACTIVE_BACKLOG
              + DORMANT_BACKLOG_START)
    INTO    l_Ending_Prior_Backlog_itd
                FROM
		        	PJI_PMV_ITD_DIM_TMP TIME
					, PJI_PMV_ORGZ_DIM_TMP HORG
		        	, PJI_PMV_CLS_DIM_TMP CLS
		        	, PJI_AC_CLSO_F_MV FCT
		        	, PJI_PMV_ORG_DIM_TMP HOU

			WHERE
				        FCT.PROJECT_ORG_ID = HOU.ID
				        AND FCT.PROJECT_ORGANIZATION_ID = HORG.ID
				        AND FCT.TIME_ID = TIME.PRIOR_ID
					AND TIME.PRIOR_ID IS NOT NULL
				        AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
                        		AND FCT.CALENDAR_TYPE = TIME.CALENDAR_TYPE
				        AND FCT.PROJECT_CLASS_ID = CLS.ID
				        AND bitand(fct.curr_record_type_id, l_curr_record_type_id) = l_curr_record_type_id;
END IF;

 FOR i IN l_Backlog_Trend_Tab.FIRST..l_Backlog_Trend_Tab.LAST
 LOOP

         IF i=1 THEN  l_Backlog_Trend_Tab(i).ENDING_BACKLOG         := l_Backlog_Trend_Tab(i).BACKLOG + nvl(l_Ending_Backlog_itd,0);
                      l_Backlog_Trend_Tab(i).PRIOR_YEAR             := l_Backlog_Trend_Tab(i).PRIOR_YEAR + nvl(l_Ending_Prior_Backlog_itd,0);
                      l_Backlog_Trend_Tab(i).ENDING_LOST_BACKLOG    := l_Backlog_Trend_Tab(i).LOST_BACKLOG + nvl(l_Ending_Lost_Backlog_itd,0);
                      l_Backlog_Trend_Tab(i).ENDING_REVENUE_AT_RISK := l_Backlog_Trend_Tab(i).REVENUE_AT_RISK + nvl(l_Ending_Revenue_at_Risk_itd,0);

         ELSE
        l_Backlog_Trend_Tab(i).ENDING_BACKLOG :=
                            l_Backlog_Trend_Tab(i-1).ENDING_BACKLOG
                            + l_Backlog_Trend_Tab(i).BACKLOG;
        l_Backlog_Trend_Tab(i).PRIOR_YEAR :=
                            l_Backlog_Trend_Tab(i-1).PRIOR_YEAR
                            + l_Backlog_Trend_Tab(i).PRIOR_YEAR;
        l_Backlog_Trend_Tab(i).ENDING_LOST_BACKLOG :=
                      l_Backlog_Trend_Tab(i-1).ENDING_LOST_BACKLOG
                        + l_Backlog_Trend_Tab(1).LOST_BACKLOG;
        l_Backlog_Trend_Tab(i).ENDING_REVENUE_AT_RISK :=
                      l_Backlog_Trend_Tab(i-1).ENDING_REVENUE_AT_RISK
                        + l_Backlog_Trend_Tab(i).REVENUE_AT_RISK;

        END IF;
END LOOP;

FOR i in 1..l_Backlog_Trend_Tab.COUNT
   LOOP
      l_Backlog_Trend_Tab(i).BEGINNING_BACKLOG :=
                l_Backlog_Trend_Tab(i).ENDING_BACKLOG-
                                l_Backlog_Trend_Tab(i).BACKLOG;
    IF
      l_Backlog_Trend_Tab(i).PRIOR_YEAR=0 THEN
            l_Backlog_Trend_Tab(i).CHANGE :=NULL;
     ELSE
       l_Backlog_Trend_Tab(i).CHANGE :=
       (l_Backlog_Trend_Tab(i).ENDING_BACKLOG - l_Backlog_Trend_Tab(i).PRIOR_YEAR)*100/
       ABS(l_Backlog_Trend_Tab(i).PRIOR_YEAR);
    END IF;
END LOOP;

/*
** Return the bulk collected table back to pmv.
*/
COMMIT;
RETURN l_Backlog_Trend_Tab;
END PLSQLDriver_PB2;

END;


/
