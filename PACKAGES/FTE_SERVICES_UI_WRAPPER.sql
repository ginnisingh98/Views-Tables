--------------------------------------------------------
--  DDL for Package FTE_SERVICES_UI_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_SERVICES_UI_WRAPPER" AUTHID CURRENT_USER AS
/* $Header: FTEUIWPS.pls 120.0 2005/06/29 19:02:07 jishen noship $ */

 c_precedence_low  CONSTANT NUMBER := 180;
 c_precedence_mid  CONSTANT NUMBER := 200;
 c_precedence_high CONSTANT NUMBER := 220;


  TYPE LANE_REC IS RECORD (
  	LANE_ID			NUMBER,
 	SERVICE_NUMBER 		VARCHAR2(100),
 	RATE_CHART_TYPE 	VARCHAR2(100),
  	TRANSPORT_MODE		VARCHAR2(100),
  	START_DATE_ACTIVE	DATE,
  	END_DATE_ACTIVE		DATE,
  	CARRIER_ID		NUMBER,
  	SERVICE_TYPE_CODE	VARCHAR2(100),
  	ORIGIN_ID		NUMBER,
  	DESTINATION_ID		NUMBER,
  	LANE_TYPE		VARCHAR2(100)
  );

  TYPE LANE_TABLE IS TABLE OF
       LANE_REC
       INDEX BY BINARY_INTEGER;

  TYPE rate_chart_header_rec IS RECORD (
  	CHART_NAME 		VARCHAR2(100),
  	CURRENCY_CODE 		VARCHAR2(100),
  	CARRIER_ID	    	NUMBER,
 	SERVICE_LEVEL		VARCHAR2(100),
  	LIST_HEADER_ID		NUMBER,
  	START_DATE_ACTIVE 	DATE,
  	END_DATE_ACTIVE		DATE,
	DESCRIPTION		VARCHAR2(2000)
  );

  TYPE rate_chart_header_table IS TABLE OF
       rate_chart_header_rec
       INDEX BY BINARY_INTEGER;

  g_list_header_id	NUMBER;

  TYPE rate_chart_line_rec IS RECORD (
	LINE_NUM		NUMBER,
	TYPE			VARCHAR2(100),
	SUBTYPE			VARCHAR2(100),
	RATE_TYPE		VARCHAR2(30),
	BREAK_TYPE		VARCHAR2(30),
	ORIGIN_ID		NUMBER,
	DEST_ID			NUMBER,
	CATG_ID			NUMBER,
	SERVICE_CODE		VARCHAR2(100),
	MULTI_FLAG		VARCHAR2(10),
  	RATE_BASIS	 	VARCHAR2(30),
  	RATE_BASIS_UOM 		VARCHAR2(30),
  	DIST_TYPE		VARCHAR2(100),
  	VEHICLE_TYPE		NUMBER,
  	RATE			NUMBER,
  	MIN_CHARGE		NUMBER,
  	START_DATE		DATE,
  	END_DATE		DATE,
	DESCRIPTION		VARCHAR2(200)
  );

  TYPE rate_chart_line_table IS TABLE OF
       rate_chart_line_rec
       INDEX BY BINARY_INTEGER;

  TYPE rate_chart_break_rec IS RECORD (
	BREAK_HEADER_INDEX	NUMBER,
	LOWER			NUMBER,
	UPPER			NUMBER,
	RATE_TYPE		VARCHAR2(30),
	RATE			NUMBER
  );

  TYPE rate_chart_break_table IS TABLE OF
       rate_chart_break_rec
       INDEX BY BINARY_INTEGER;

  TYPE tl_line_rec IS RECORD (
	LINE_NUM		NUMBER,
	TYPE			VARCHAR2(100),
	REGION_CODE		NUMBER,
	BASIS			VARCHAR2(30),
	BASIS_UOM_CODE		VARCHAR2(30),
	CHARGE			NUMBER,
	MIN_CHARGE		NUMBER,
	START_DATE		DATE,
	END_DATE		DATE,
	FREE_STOPS		NUMBER,
	FIRST_STOP		NUMBER,
	SECOND_STOP		NUMBER,
	THIRD_STOP		NUMBER,
	FOURTH_STOP		NUMBER,
	FIFTH_STOP		NUMBER,
	ADD_STOPS		NUMBER
  );

  TYPE tl_line_table IS TABLE OF
       tl_line_rec
       INDEX BY BINARY_INTEGER;



  --------------------------------------------------------
  -- PROCEDURE EDIT_TL_SERVICES
  --
  -- Purpose: convert UI data into pl/sql tables and insert into the database
  --
  -- IN parameters:
  --	1. p_init_msg_list:
  --	2. p_transaction_type:
  --	3. p_lane_table:		lane table info
  -- 	4. p_rate_chart_header_table:	rate chart header info
  --	5. p_rate_chart_line_table:	rate chart line info
  --
  -- OUT parameters:
  -- 	1. x_status:
  --	2. x_error_msg:
  --------------------------------------------------------
  PROCEDURE Edit_TL_Services(
		P_INIT_MSG_LIST  		IN 	 	VARCHAR2,
		P_TRANSACTION_TYPE  		IN		VARCHAR2,
		P_LANE_TABLE			IN		LANE_TABLE,
		P_RATE_CHART_HEADER_TABLE 	IN   		rate_chart_header_table,
		P_RATE_CHART_LINE_TABLE		IN		rate_chart_line_table,
		X_STATUS			OUT NOCOPY	NUMBER,
		X_ERROR_MSG			OUT NOCOPY	VARCHAR2
	);

  --------------------------------------------------------
  -- PROCEDURE RATE_CHART_WRAPPER
  --
  -- Purpose: convert UI data into pl/sql tables and insert into the database
  --
  -- IN parameters:
  --	1. p_header_table:	header info table
  --	2. p_line_table:	line info table
  --	3. p_break_table:	break info table
  -- 	4. p_chart_type:	the chart type (RC or MOD)
  --
  -- OUT parameters:
  -- 	1. x_status:	status, -1 means no error
  --	2. x_error_msg:	error message if any
  --------------------------------------------------------
  PROCEDURE RATE_CHART_WRAPPER( p_header_table 	IN rate_chart_header_table,
			        p_line_table 	IN rate_chart_line_table,
			        p_break_table 	IN rate_chart_break_table,
				p_chart_type	IN VARCHAR2,
			        x_status	OUT NOCOPY NUMBER,
			        x_error_msg	OUT NOCOPY VARCHAR2);

  --------------------------------------------------------
  -- PROCEDURE TL_SURCHARGE_WRAPPER
  --
  -- Purpose: convert UI data into pl/sql tables and insert into the database
  --
  -- IN parameters:
  --	1. p_header_table:	header info table
  --	2. p_tl_line_table:	line info table
  --	3. p_break_table:	break info table
  --
  -- OUT parameters:
  -- 	1. x_status:	status, -1 means no error
  --	2. x_error_msg:	error message if any
  --------------------------------------------------------
  PROCEDURE TL_SURCHARGE_WRAPPER( p_header_table 	IN	rate_chart_header_table,
				  p_tl_line_table 	IN	tl_line_table,
			          p_break_table 	IN 	rate_chart_break_table,
				  p_action		IN	VARCHAR2,
			          x_status	OUT NOCOPY NUMBER,
			          x_error_msg	OUT NOCOPY VARCHAR2);

END FTE_SERVICES_UI_WRAPPER;

 

/
