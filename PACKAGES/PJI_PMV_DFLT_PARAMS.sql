--------------------------------------------------------
--  DDL for Package PJI_PMV_DFLT_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PMV_DFLT_PARAMS" AUTHID CURRENT_USER AS
/* $Header: PJIRX02S.pls 115.8 2004/06/04 12:35:32 aljain noship $ */


--(function 1: common for all )
FUNCTION  PJI_REP_DIM_2  return varchar2;

--(function 2: common for all )
FUNCTION AS_OF_DATE   return varchar2;

--Profitability Reports
--(function 3: common for all  except PP5 and PP6 -else condition)
FUNCTION Profitability_PP_Time_Year   return varchar2;

--(function 4: common for all  except PP5 and PP6 -else condition)
FUNCTION Profitability_PP_Time_Qtr   return varchar2;

--(function 5: common for all except PP5 and PP6 -else condition)
FUNCTION Profitability_PP_Time_Period   return varchar2;

--(function 6: common for all  except PP5 and PP6 -else condition)
FUNCTION Profitability_PP_Time_Week   return varchar2;

--(function 7: for PP5 and PP6  under profitability)
FUNCTION Profitability_PP56_Time   return varchar2;

--(function 8: For PP1 and PP2  under profitability)
FUNCTION Profitability_PP12_Yearly   return varchar2;

--(function 9: common for all under profitability)
FUNCTION Profitability_PP_PjiRepDim27   return varchar2;

--Availablity Reports
--(function 10: common for RA1,RA3,RA5)
FUNCTION Availability_RA_Time_Year   return varchar2;

--(function 11: common for RA1,RA3,RA5)
FUNCTION Availability_RA_Time_Qtr   return varchar2;

--(function 12: common for RA1,RA3,RA5)
FUNCTION Availability_RA_Time_Period   return varchar2;

--(function 13:common for RA1,RA3,RA5)
FUNCTION Availability_RA_Time_Week   return varchar2;

--(function 14: common for all under availability)
FUNCTION Availability_RA_PjiRepDim28   return varchar2;

--(function 15: RA3 for availability)
FUNCTION Availability_RA_PjiRepDim29   return varchar2;

--(function 16: RA4 for availability)
FUNCTION Availability_RA_FiiTimeWeek   return varchar2;

--Cost Reports
--(function 17: for PP7 and PP8  under Cost  -if condition )
FUNCTION Cost_PP78_Time   return varchar2;

--(function 18: common for all except PP7 and PP8 -else)
FUNCTION Cost_PP_Time_Year   return varchar2;

--(function 19: common for all except PP7 and PP8 -else)
FUNCTION Cost_PP_Time_Qtr   return varchar2;

--(function 20: common for all except PP7 and PP8 -else)
FUNCTION Cost_PP_Time_Period   return varchar2;

--(function 21: common for all except PP7 and PP8 -else)
FUNCTION Cost_PP_Time_Week   return varchar2;

--(function 22: For PP4,PC6 and PC10  under Cost)
FUNCTION Cost_P4610_Yearly   return varchar2;

--(function 23: common for all under Cost)
FUNCTION Cost_PP_PjiRepDim27   return varchar2;

--Bookings_Backlog reports
--(function 24: for PB2,PB02 and PB03  under Bookings_Backlog  -if condition )
FUNCTION Bookings_Backlog20203_Time   return varchar2;

--(function 25: common for all except PB2,PB02 and PB03  -else)
FUNCTION Bookings_Backlog_Time_Year   return varchar2;

--(function 26: common for all except PB2,PB02 and PB03  -else)
FUNCTION Bookings_Backlog_Time_Qtr   return varchar2;

--(function 27: common for all except PB2,PB02 and PB03  -else)
FUNCTION Bookings_Backlog_Time_Period   return varchar2;

--(function 28: common for all except PB2,PB02 and PB03  -else)
FUNCTION Bookings_Backlog_Time_Week   return varchar2;

--(function 29: common for all under Bookings Backlog)
FUNCTION Bookings_Backlog_PjiRepDim27   return varchar2;

--(function 30:  for PBB2 under Bookings Backlog)
FUNCTION Bookings_BacklogBB2_Dim33  return varchar2;

--(function 31: PBB1 under Bookings Backlog)
FUNCTION Bookings_BacklogBB1_Yearly   return varchar2;

--Utilization Reports
--(function 32: for UAP1 and U1 under Utilization)
FUNCTION Utilization_UAP1U1_Yearly   return varchar2;

--(function 33: for U2 under Utilization -if condition )
FUNCTION Utilization_U2_Time   return varchar2;

--(function 34: common for all except U2  -else)
FUNCTION Utilization_Time_Year   return varchar2;

--(function 35: common for all except U2  -else)
FUNCTION Utilization_Time_Qtr   return varchar2;

--(function 36: common for all except U2  -else)
FUNCTION Utilization_Time_Period   return varchar2;

--(function 37: common for all except u2  -else)
FUNCTION Utilization_Time_Week   return varchar2;

--(function 38: common for all under Utilization)
FUNCTION Utilization_PjiRepDim27   return varchar2;


END PJI_PMV_DFLT_PARAMS;



 

/
