--------------------------------------------------------
--  DDL for Package QP_DEBUG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DEBUG_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXDUTLS.pls 120.0.12010000.4 2009/09/23 08:22:27 dnema noship $ */

--  Constants used as tokens for unexpected error Debugs.

   G_PKG_NAME  CONSTANT    VARCHAR2(15):=  'QP_DEBUG_UTIL';
   G_DEBUG VARCHAR2(1)  := OE_DEBUG_PUB.G_DEBUG;

--  Global variable holding the desired debug_level.

   G_Debug_Level   NUMBER :=  FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');
   G_qp_debug        VARCHAR2(1):=  FND_PROFILE.VALUE('QP_DEBUG');

   G_CURR_PRICE_EVENT VARCHAR2(30) := null; --8932016

--  Index used by the Get function to keep track of the last fetched
--  Debug.

TYPE t_TimeType IS RECORD(
 Marker    VARCHAR2(200),
 Description VARCHAR2(2000),
 Time        NUMBER,
 CallCount    NUMBER,
 TotalTime    NUMBER,
 ParentId     NUMBER,
 IsRunning      BOOLEAN,
 Deleted     BOOLEAN,
 putLine  BOOLEAN
 );

--Summary Time Log Changes (Bug# 8933551)
TYPE t_Summery_Log IS RECORD(
 logMesg VARCHAR2(2000),
 paddingTop NUMBER,
 paddingLeft NUMBER,
 paddingBottom NUMBER
 );

 TYPE t_TimeStack IS TABLE OF t_TimeType
 INDEX BY BINARY_INTEGER;

 TYPE t_CallStack IS TABLE OF VARCHAR2(32767)
 INDEX BY BINARY_INTEGER;

  --Summary Time Log Changes (Bug# 8933551)
 TYPE t_SummarLogStack IS TABLE OF t_Summery_Log
 INDEX BY BINARY_INTEGER;

TYPE t_comm_attributes IS TABLE OF VARCHAR2(5000) INDEX BY VARCHAR2(500);

   --Summary Time Log Changes
   g_summaryLog t_SummarLogStack;
   g_comm_attribs t_comm_attributes;
   g_TimeStack     t_TimeStack;
   g_CallStack    t_CallStack;

TYPE query_list is table of VARCHAR2(32767) index by BINARY_INTEGER;

PROCEDURE write_output(x_Line IN VARCHAR2);
PROCEDURE  tstart(x_Marker IN VARCHAR2, x_Desc IN VARCHAR2 := NULL,
   x_Accumalation IN BOOLEAN := true, x_PutLine IN BOOLEAN := false);
PROCEDURE  tstop(x_Marker IN VARCHAR2);
PROCEDURE  tdump;
PROCEDURE tflush;
Function ISQPDebugOn Return Boolean;
FUNCTION IsTimeLogDebugOn Return Boolean;
Procedure print_table_data_csv (p_table_name IN VARCHAR2,
                                p_file_id IN VARCHAR2,
                                p_where_clause IN VARCHAR2 := NULL,
                                p_append IN BOOLEAN := FALSE,
  			        p_prefix_event IN BOOLEAN := TRUE);
Procedure print_query_data_csv (p_query IN VARCHAR2,
                                p_file_id IN VARCHAR2,
				 p_append IN BOOLEAN := FALSE,
				  p_prefix_event IN BOOLEAN := TRUE);
Procedure print_cursor_data_csv (p_cursor_id IN number, p_file_id IN VARCHAR2);
procedure print_querylist_data_csv (
   p_query_list in query_list,
   p_file_id IN VARCHAR2);
procedure print_support_csv(pos varchar2);
PROCEDURE print_development_csv;
PROCEDURE setCurrentEvent(currEvent varchar2); --8932016

-- Summary Time Log changes (Bug# 8933551)
PROCEDURE addSummaryTimeLog(logMessage varchar2,
                            paddingTop NUMBER := 0,
			    paddingLeft NUMBER := 0,
			    paddingBottom NUMBER := 0);
PROCEDURE dumpSummaryTimeLog;
PROCEDURE tstop(x_Marker IN VARCHAR2, x_Total_Time OUT NOCOPY NUMBER);
PROCEDURE setAttribute(pKey varchar2, pValue varchar2);
FUNCTION getAttribute(pKey varchar2) RETURN varchar2;

END QP_DEBUG_UTIL;

/
