--------------------------------------------------------
--  DDL for Package Body PJI_PMV_DFLT_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PMV_DFLT_PARAMS" AS
  /* $Header: PJIRX02B.pls 115.29 2004/06/04 12:34:49 aljain noship $ */

G_Default_Org_Dimension_Level   VARCHAR2(150):='PJI_REP_DIM_2';
G_Org_Hierarchy_Name            VARCHAR2(100):='ORGANIZATION^PJI_ORGANIZATIONS';
G_Default_Compare_To            VARCHAR2(150):='TIME_COMPARISON_TYPE+YEARLY';
G_Default_Revenue_At_Risk_Only  VARCHAR2(3)  :='N';
G_Duration_Type                 VARCHAR2(150):='CUMULATIVE';
G_SQL_Error_Message 		VARCHAR2(2000);
G_As_Of_Date                    VARCHAR2(30):=to_char(SYSDATE,'DD-MON-YYYY');

---*****************************************************************************
-- Project  Default Parameter Values Started by Monika
-- ****************************************************************************

 ---********************************************************************
---	Common Functions for all Reports
---********************************************************************
---********************************************************************
-- PJI_REP_DIM_2 (function 1: common for all )
---********************************************************************
FUNCTION PJI_REP_DIM_2  return varchar2
	IS
	l_org_dimension_id	   VARCHAR2(150);
	Begin
		l_org_dimension_id  :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Organization_ID;
		return l_org_dimension_id;
	END PJI_REP_DIM_2;


---********************************************************************
-- AS_OF_DATE (function 2: common for all )
---********************************************************************
FUNCTION AS_OF_DATE   return varchar2
	IS
	l_As_Of_Date               VARCHAR2(30);
	Begin
	          l_As_Of_Date         :=G_As_Of_Date;
	          return  l_As_Of_Date;
        END  AS_OF_DATE;



 ---*********************************************************************************************
--	Profitability Reports
 ---*********************************************************************************************


 ---******************************************************************************************************
 -- TIME+FII_TIME_ENT_YEAR_FROM (function 3: common for all under profitability except PP5 and PP6 -else condition)
 ---********************************************************************************************************
FUNCTION Profitability_PP_Time_Year   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Profitability');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	IF l_period_id ='FII_TIME_ENT_YEAR' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END  Profitability_PP_Time_Year;

 ---*******************************************************************************************************
 -- TIME+FII_TIME_ENT_QTR_FROM(function 4: common for all under profitability except PP5 and PP6 -else condition)
 ---*******************************************************************************************************
FUNCTION Profitability_PP_Time_Qtr   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Profitability');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF  l_period_id ='FII_TIME_ENT_QTR' then
		  return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END  Profitability_PP_Time_Qtr;

 ---************************************************************************************************************
 --TIME+FII_TIME_ENT_PERIOD_FROM(function 5: common for all under profitability except PP5 and PP6 -else condition)
 ---**************************************************************************************************************
FUNCTION Profitability_PP_Time_Period   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Profitability');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF  l_period_id ='FII_TIME_ENT_PERIOD' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END  Profitability_PP_Time_Period;

 ---*******************************************************************************************************
 -- TIME+FII_TIME_WEEK_FROM(function 6: common for all under profitability except PP5 and PP6 -else condition)
 ---********************************************************************************************************
FUNCTION Profitability_PP_Time_Week   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Profitability');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF   l_period_id = 'FII_TIME_WEEK' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END  Profitability_PP_Time_Week;


 ---***********************************************************************************************************
 -- TIME+FII_TIME_ENT_PERIOD_FROM(function 7: for PP5 and PP6  under profitability -if condition )
 ---***********************************************************************************************************
FUNCTION Profitability_PP56_Time   return varchar2
	IS
	l_Ent_Per_ID_Value         NUMBER;
	Begin
			  PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Profitability');
		        l_Ent_Per_ID_Value  :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Ent_Period_ID_Value;
			return TO_CHAR(l_Ent_Per_ID_Value);
	END  Profitability_PP56_Time;


--********************************************************************
-- YEARLY(function 8: For PP1 and PP2  under profitability)
---********************************************************************
FUNCTION Profitability_PP12_Yearly   return varchar2
	IS
	l_Default_Compare_To       VARCHAR2(150);
	Begin
			PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Profitability');
			l_Default_Compare_To :=G_Default_Compare_To;
	   	       return l_Default_Compare_To;
	END  Profitability_PP12_Yearly;


---********************************************************************
 -- PJI_REP_DIM_27(function 9: common for all under profitability)
---********************************************************************
FUNCTION Profitability_PP_PjiRepDim27   return varchar2
	IS
	l_Currency_ID              VARCHAR2(150);
	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Profitability');
	         l_currency_id       :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Currency_ID;
	         return l_Currency_ID;
	END  Profitability_PP_PjiRepDim27 ;


 ---*********************************************************************************************
--	Availablity Reports
 ---*********************************************************************************************

---******************************************************************************************************
 -- TIME+FII_TIME_ENT_YEAR_FROM (function 10: common for RA1,RA3,RA5)
 ---********************************************************************************************************
FUNCTION Availability_RA_Time_Year   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		  PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Resource Availability');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	IF l_period_id ='FII_TIME_ENT_YEAR' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END   Availability_RA_Time_Year;

 ---*******************************************************************************************************
 -- TIME+FII_TIME_ENT_QTR_FROM(function 11: common for RA1,RA3,RA5)
 ---*******************************************************************************************************
FUNCTION Availability_RA_Time_Qtr   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Resource Availability');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF  l_period_id ='FII_TIME_ENT_QTR' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END  Availability_RA_Time_Qtr;

 ---************************************************************************************************************
 -- TIME+FII_TIME_ENT_PERIOD_FROM(function 12: common for RA1,RA3,RA5)
 ---**************************************************************************************************************
FUNCTION Availability_RA_Time_Period   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Resource Availability');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF  l_period_id ='FII_TIME_ENT_PERIOD' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END Availability_RA_Time_Period;

 ---*******************************************************************************************************
 -- TIME+FII_TIME_WEEK_FROM(function 13: common for RA1,RA3,RA5)
 ---********************************************************************************************************
FUNCTION Availability_RA_Time_Week   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Resource Availability');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF   l_period_id = 'FII_TIME_WEEK' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END  Availability_RA_Time_Week;


---********************************************************************
 -- PJI_REP_DIM_28(function 14: common for all under availability)
---********************************************************************
FUNCTION Availability_RA_PjiRepDim28   return varchar2
	IS
	l_Availability_Threshold            VARCHAR2(150);
	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Resource Availability');
		  l_Availability_Threshold:=PJI_PMV_DFLT_PARAMS_PVT.Derive_Avail_Threshold;
		 return l_Availability_Threshold;
	END  Availability_RA_PjiRepDim28 ;


---********************************************************************
 -- PJI_REP_DIM_29(function 15: RA3 for availability)
---********************************************************************
FUNCTION Availability_RA_PjiRepDim29   return varchar2
	IS
	l_Duration_Type                     VARCHAR2(150);
	Begin
		   PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Resource Availability');
		     l_Duration_Type      :=G_Duration_Type;
		 return l_Duration_Type;
	END  Availability_RA_PjiRepDim29 ;

---********************************************************************
 --FII_TIME_WEEK_FROM(function 16: RA4 for availability)
---********************************************************************
FUNCTION Availability_RA_FiiTimeWeek   return varchar2
	IS
	l_EntWeek_ID_Value                  NUMBER;
	Begin
		    PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Resource Availability');
		    l_EntWeek_ID_Value      :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Week_ID_Value;
		 return TO_CHAR(l_EntWeek_ID_Value);
	END  Availability_RA_FiiTimeWeek ;

--************************************************************************************************
-- Cost
--*************************************************************************************************
  ---*****************************************************************************************************
 -- TIME+FII_TIME_ENT_PERIOD_FROM(function 17: for PP7 and PP8  under Cost  -if condition )
 ---*******************************************************************************************************
FUNCTION Cost_PP78_Time   return varchar2
	IS
	l_Ent_Per_ID_Value         NUMBER;
	Begin
		PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Cost');
	        l_Ent_Per_ID_Value  :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Ent_Period_ID_Value;
		return TO_CHAR(l_Ent_Per_ID_Value);
	END  Cost_PP78_Time ;

---******************************************************************************************************
 -- TIME+FII_TIME_ENT_YEAR_FROM (function 18: common for all except PP7 and PP8 -else)
 ---********************************************************************************************************
FUNCTION Cost_PP_Time_Year   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Cost');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	IF l_period_id ='FII_TIME_ENT_YEAR' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END   Cost_PP_Time_Year;

 ---*******************************************************************************************************
 -- TIME+FII_TIME_ENT_QTR_FROM(function 19: common for all except PP7 and PP8 -else)
 ---*******************************************************************************************************
FUNCTION Cost_PP_Time_Qtr   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Cost');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF  l_period_id ='FII_TIME_ENT_QTR' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END  Cost_PP_Time_Qtr;

 ---************************************************************************************************************
 -- TIME+FII_TIME_ENT_PERIOD_FROM(function 20: common for all except PP7 and PP8 -else)
 ---**************************************************************************************************************
FUNCTION Cost_PP_Time_Period   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Cost');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF  l_period_id ='FII_TIME_ENT_PERIOD' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END Cost_PP_Time_Period;

 ---*******************************************************************************************************
 -- TIME+FII_TIME_WEEK_FROM(function 21: common for all except PP7 and PP8 -else)
 ---********************************************************************************************************
FUNCTION Cost_PP_Time_Week   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Cost');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF   l_period_id = 'FII_TIME_WEEK' then
	       return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END  Cost_PP_Time_Week;

 --********************************************************************
-- YEARLY(function 22: For PP4,PC6 and PC10  under Cost)
---********************************************************************
FUNCTION Cost_P4610_Yearly   return varchar2
	IS
	l_Default_Compare_To       VARCHAR2(150);
	Begin
		PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Cost');
		l_Default_Compare_To :=G_Default_Compare_To;
	       return l_Default_Compare_To;
	END  Cost_P4610_Yearly;

---********************************************************************
 -- PJI_REP_DIM_27(function 23: common for all under Cost)
---********************************************************************
FUNCTION Cost_PP_PjiRepDim27   return varchar2
	IS
	l_Currency_ID              VARCHAR2(150);
	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Cost');
	        l_currency_id       :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Currency_ID;
		 return l_Currency_ID;
	END  Cost_PP_PjiRepDim27 ;
--*************************************************************************************
-- Bookings_Backlog
--*****************************************************************************************
  ---*********************************************************************************************************************************
 -- TIME+FII_TIME_ENT_PERIOD_FROM(function 24: for PB2,PB02 and PB03  under Bookings_Backlog  -if condition )
 ---*********************************************************************************************************************************
FUNCTION Bookings_Backlog20203_Time   return varchar2
	IS
	l_Ent_Per_ID_Value         NUMBER;
	Begin
		PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Bookings and Backlog');
	        l_Ent_Per_ID_Value  :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Ent_Period_ID_Value;
		return TO_CHAR(l_Ent_Per_ID_Value);
	END  Bookings_Backlog20203_Time ;

---******************************************************************************************************
 -- TIME+FII_TIME_ENT_YEAR_FROM (function 25: common for all except PB2,PB02 and PB03  -else)
 ---********************************************************************************************************
FUNCTION Bookings_Backlog_Time_Year   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Bookings and Backlog');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	IF l_period_id ='FII_TIME_ENT_YEAR' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END  Bookings_Backlog_Time_Year;

 ---*******************************************************************************************************
 -- TIME+FII_TIME_ENT_QTR_FROM(function 26: common for all except PB2,PB02 and PB03  -else)
 ---*******************************************************************************************************
FUNCTION Bookings_Backlog_Time_Qtr   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Bookings and Backlog');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF  l_period_id ='FII_TIME_ENT_QTR' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END  Bookings_Backlog_Time_Qtr;

 ---************************************************************************************************************
 -- TIME+FII_TIME_ENT_PERIOD_FROM(function 27: common for all except PB2,PB02 and PB03  -else)
 ---**************************************************************************************************************
FUNCTION Bookings_Backlog_Time_Period   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Bookings and Backlog');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF  l_period_id ='FII_TIME_ENT_PERIOD' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END Bookings_Backlog_Time_Period;

 ---*******************************************************************************************************
 -- TIME+FII_TIME_WEEK_FROM(function 28: common for all except PB2,PB02 and PB03  -else)
 ---********************************************************************************************************
FUNCTION Bookings_Backlog_Time_Week   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Bookings and Backlog');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF   l_period_id = 'FII_TIME_WEEK' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END  Bookings_Backlog_Time_Week;

---********************************************************************************
 -- PJI_REP_DIM_27(function 29: common for all under Bookings Backlog)
---********************************************************************************
FUNCTION Bookings_Backlog_PjiRepDim27   return varchar2
	IS
	l_Currency_ID              VARCHAR2(150);
	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Bookings and Backlog');
	         l_currency_id       :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Currency_ID;
		 return l_Currency_ID;
	END  Bookings_Backlog_PjiRepDim27 ;

---********************************************************************************
 -- PJI_REP_DIM_33(function 30:  for PBB2 under Bookings Backlog)
---********************************************************************************
FUNCTION Bookings_BacklogBB2_Dim33  return varchar2
	IS
	l_Revenue_At_Risk_Only      VARCHAR2(150);
	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Bookings and Backlog');
	         l_Revenue_At_Risk_Only  :=G_Default_Revenue_At_Risk_Only;
		 return l_Revenue_At_Risk_Only;
	END Bookings_BacklogBB2_Dim33	;

 --********************************************************************
-- YEARLY(function 31: PBB1 under Bookings Backlog)
---********************************************************************
FUNCTION Bookings_BacklogBB1_Yearly   return varchar2
	IS
	l_Default_Compare_To       VARCHAR2(150);
	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Project Bookings and Backlog');
		l_Default_Compare_To :=G_Default_Compare_To;
		   return l_Default_Compare_To;
	END  Bookings_BacklogBB1_Yearly;

--***********************************************************************
-- Default Utilization
--************************************************************************

 --********************************************************************
-- YEARLY(function 32: for UAP1 and U1 under Utilization)
---********************************************************************
FUNCTION Utilization_UAP1U1_Yearly   return varchar2
	IS
	l_Default_Compare_To       VARCHAR2(150);
	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Resource Utilization');
		l_Default_Compare_To :=G_Default_Compare_To;
		   return l_Default_Compare_To;
	END  Utilization_UAP1U1_Yearly;

  ---*********************************************************************************************************************************
 -- TIME+FII_TIME_ENT_PERIOD_FROM(function 33: for U2 under Utilization -if condition )
 ---*********************************************************************************************************************************
FUNCTION Utilization_U2_Time   return varchar2
	IS
	l_Ent_Per_ID_Value         NUMBER;
	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Resource Utilization');
	        l_Ent_Per_ID_Value  :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Ent_Period_ID_Value;
		return TO_CHAR(l_Ent_Per_ID_Value);
	END  Utilization_U2_Time ;

---******************************************************************************************************
 -- TIME+FII_TIME_ENT_YEAR_FROM (function 34: common for all except U2  -else)
 ---********************************************************************************************************
FUNCTION Utilization_Time_Year   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Resource Utilization');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	IF l_period_id ='FII_TIME_ENT_YEAR' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END  Utilization_Time_Year;

 ---*******************************************************************************************************
 -- TIME+FII_TIME_ENT_QTR_FROM(function 35: common for all except U2  -else)
 ---*******************************************************************************************************
FUNCTION Utilization_Time_Qtr   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Resource Utilization');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF  l_period_id ='FII_TIME_ENT_QTR' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END  Utilization_Time_Qtr;

 ---************************************************************************************************************
 -- TIME+FII_TIME_ENT_PERIOD_FROM(function 36: common for all except U2  -else)
 ---**************************************************************************************************************
FUNCTION Utilization_Time_Period   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Resource Utilization');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF  l_period_id ='FII_TIME_ENT_PERIOD' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END Utilization_Time_Period;

 ---*******************************************************************************************************
 -- TIME+FII_TIME_WEEK_FROM(function 37: common for all except U2  -else)
 ---********************************************************************************************************
FUNCTION Utilization_Time_Week   return varchar2
	IS
	l_Period_ID                VARCHAR2(150);
	l_Period_ID_Value          NUMBER;

	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Resource Utilization');
		l_Period_ID         :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID;
		l_Period_ID_Value   :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Period_ID_Value;

	 IF   l_period_id = 'FII_TIME_WEEK' then
		   return TO_CHAR(l_Period_Id_Value);
	ELSE
		 return null;
	END IF;
	END Utilization_Time_Week;

---********************************************************************
 -- PJI_REP_DIM_27(function 38: common for all under Utilization)
---********************************************************************
FUNCTION Utilization_PjiRepDim27   return varchar2
	IS
	l_Currency_ID              VARCHAR2(150);
	Begin
		 PJI_PMV_DFLT_PARAMS_PVT.InitParameters ('Resource Utilization');
	      l_currency_id       :=PJI_PMV_DFLT_PARAMS_PVT.Derive_Currency_ID;
		 return l_Currency_ID;
	END  Utilization_PjiRepDim27 ;




---********************************************************************
-- Project  Default Parameter Values Ended by Monika
-- ********************************************************************

-- *****************************************
--  Package Initialization Code
-- *****************************************
BEGIN
	PJI_PMV_DFLT_PARAMS_PVT.InitEnvironment;
EXCEPTION
	WHEN OTHERS THEN
		RAISE;
END PJI_PMV_DFLT_PARAMS;


/
