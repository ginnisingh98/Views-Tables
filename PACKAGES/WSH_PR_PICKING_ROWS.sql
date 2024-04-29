--------------------------------------------------------
--  DDL for Package WSH_PR_PICKING_ROWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PR_PICKING_ROWS" AUTHID CURRENT_USER AS
/* $Header: WSHPRPRS.pls 115.2 99/07/16 08:20:09 porting ship $ */

--
-- Package
--   	WSH_PR_PICKING_ROWS
--
-- Purpose
--	This package does the following:
--	- Open and fetch unreleased line details cursor
--	- Open and fetch backorderd line details cursor
--	- Open and fetch non-shippable lines cursor
--
-- History
--      16-SEP-96    RSHIVRAM    Created
--

  --
  -- PACKAGE TYPES
  --
	TYPE relRecTyp IS RECORD (
		line_id				BINARY_INTEGER,
		header_id			BINARY_INTEGER,
		org_id				BINARY_INTEGER,
		ato_flag			VARCHAR2(1),
		line_detail_id			BINARY_INTEGER,
		ship_model_complete		VARCHAR2(1),
		ship_set_number			BINARY_INTEGER,
		parent_line_id			BINARY_INTEGER,
		ld_warehouse_id			BINARY_INTEGER,
		ship_to_site_use_id		BINARY_INTEGER,
		ship_to_contact_id		BINARY_INTEGER,
		ship_method_code		VARCHAR2(30),
		shipment_priority		VARCHAR2(30),
		departure_id			BINARY_INTEGER,
		delivery_id			BINARY_INTEGER,
		item_type_code			VARCHAR2(30),
		schedule_date			BINARY_INTEGER,
		ordered_quantity		BINARY_INTEGER,
		cancelled_quantity		BINARY_INTEGER,
		l_inventory_item_id		BINARY_INTEGER,
		ld_inventory_item_id		BINARY_INTEGER,
		customer_item_id		BINARY_INTEGER,
		dep_plan_required_flag		VARCHAR2(1),
		shipment_schedule_line_id	BINARY_INTEGER,
		unit_code			VARCHAR2(3),
		line_type_code			VARCHAR2(30),
		component_code			VARCHAR2(1000),
		standard_comp_freeze_date	VARCHAR2(15),
		order_number			BINARY_INTEGER,
		order_type_id			BINARY_INTEGER,
		customer_id			BINARY_INTEGER,
		invoice_to_site_use_id		BINARY_INTEGER,
		planned_departure_date_d	BINARY_INTEGER,	 -- day component of departure date
		planned_departure_date_t	BINARY_INTEGER,  -- time component of departure date
		master_container_item_id	BINARY_INTEGER,
		detail_container_item_id	BINARY_INTEGER,
		invoice_value			NUMBER,
		load_seq_number			BINARY_INTEGER,
		backorder_line			BINARY_INTEGER,
		primary_rsr_switch		BINARY_INTEGER
	);

	TYPE relRecTabTyp IS TABLE OF relRecTyp INDEX BY BINARY_INTEGER;
	TYPE intTabTyp IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
	TYPE cflagTabTyp IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
	TYPE cnameTabTyp IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
	TYPE ccodeTabTyp IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
	TYPE cbufTabTyp IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
	TYPE cdateTabTyp IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;

  --
  -- PUBLIC VARIABLES
  --
	release_table				relRecTabTyp;
	sync_table				relrecTabTyp;

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --

  --
  -- Name
  --   FUNCTION Init
  --
  -- Purpose
  --   This function, based on the mode opens appropriate cursors.
  --
  -- Return Values
  --   -1 => Failure
  --    0 => Success
  --
  -- Notes
  --

  FUNCTION Init RETURN BINARY_INTEGER;

  --
  -- Name
  --   FUNCTION Get_Size
  --
  -- Purpose
  --   This function returns the number of rows returned in the
  --   previous call to Get_Line_Details
  --
  -- Return Values
  --    Number of rows fetched in previous call
  --
  -- Notes
  --

  FUNCTION Get_Size RETURN BINARY_INTEGER;

  --
  -- Name
  --   PROCEDURE Get_Line_Details
  --
  -- Purpose
  --   This routine returns information about the lines that
  --   are eligible for release. They are placed in a table.
  --   It controls the number of lines to be fetched and
  --   provided to the client. The default value is set at 50.
  --   This may be modified by the first parameter if it is not 0.
  --   It also indicates whether there are any more lines to be
  --   retrieved.
  --
  -- Arguments
  --    All the column values and call_parameters
  --    Call_parameters(2) transalates as
  --   -1 => Failure
  --    0 => Success, but there are more rows to be fetched
  --    2 => Success, no more rows to fetch
  --    Call_parameters(1) is the size
  --
  -- Notes
  --

  PROCEDURE Get_Line_Details(
	line_id				OUT	intTabTyp,
	header_id			OUT	intTabTyp,
	org_id				OUT	intTabTyp,
	ato_flag			OUT	cflagTabTyp,
	line_detail_id			OUT	intTabTyp,
	ship_model_complete		OUT	cflagTabTyp,
	ship_set_number			OUT	intTabTyp,
	parent_line_id                  OUT	intTabTyp,
	ld_warehouse_id			OUT	intTabTyp,
	ship_to_site_use_id		OUT	intTabTyp,
	ship_to_contact_id		OUT	intTabTyp,
	ship_method_code		OUT	cnameTabTyp,
	shipment_priority		OUT	cnameTabTyp,
	departure_id			OUT	intTabTyp,
	delivery_id			OUT	intTabTyp,
	item_type_code			OUT	cnameTabTyp,
	schedule_date			OUT	intTabTyp,
	ordered_quantity		OUT	intTabTyp,
	cancelled_quantity		OUT	intTabTyp,
	l_inventory_item_id		OUT	intTabTyp,
	ld_inventory_item_id		OUT	intTabTyp,
	customer_item_id		OUT	intTabTyp,
	dep_plan_required_flag		OUT	cflagTabTyp,
	shipment_schedule_line_id	OUT	intTabTyp,
	unit_code			OUT	ccodeTabTyp,
	line_type_code			OUT	cnameTabTyp,
	component_code			OUT	cbufTabTyp,
	standard_comp_freeze_date	OUT	cdateTabTyp,
	order_number			OUT	intTabTyp,
	order_type_id			OUT	intTabTyp,
	customer_id			OUT	intTabTyp,
	invoice_to_site_use_id		OUT	intTabTyp,
	master_container_item_id	OUT	intTabTyp,
	detail_container_item_id	OUT	intTabTyp,
	load_seq_number			OUT	intTabTyp,
	backorder_line			OUT	intTabTyp,
	primary_rsr_switch		OUT	intTabTyp,
	call_parameters			IN OUT	intTabTyp
  );


  --
  -- Name
  --   FUNCTION Set_Sync_Line
  --
  -- Purpose
  --   This routine sets up the sync_line_id to fetch the
  --   records that have been demand synchronized.
  --
  -- Arguments
  --
  -- Notes
  --

  FUNCTION Set_Sync_Line(
		p_sync_line_id 		IN	BINARY_INTEGER
  ) RETURN BINARY_INTEGER;


  --
  -- Name
  --   PROCEDURE Get_Sync_Line_Details
  --
  -- Purpose
  --   This routine returns lines that heve been BOM exploded and/or
  --   Demand synchronized for a particular line.
  --
  -- Arguments
  --    All the column values and call_parameters
  --    Call_parameters(2) transalates as
  --   -1 => Failure
  --    0 => Success, but there are more rows to be fetched
  --    2 => Success, no more rows to fetch
  --    Call_parameters(1) is the size
  --
  -- Notes
  --

  PROCEDURE Get_Sync_Line_Details(
	line_id				OUT	intTabTyp,
	header_id			OUT	intTabTyp,
	org_id				OUT	intTabTyp,
	ato_flag			OUT	cflagTabTyp,
	line_detail_id			OUT	intTabTyp,
	ship_model_complete		OUT	cflagTabTyp,
	ship_set_number			OUT	intTabTyp,
	parent_line_id                  OUT	intTabTyp,
	ld_warehouse_id			OUT	intTabTyp,
	ship_to_site_use_id		OUT	intTabTyp,
	ship_to_contact_id		OUT	intTabTyp,
	ship_method_code		OUT	cnameTabTyp,
	shipment_priority		OUT	cnameTabTyp,
	departure_id			OUT	intTabTyp,
	delivery_id			OUT	intTabTyp,
	schedule_date			OUT	intTabTyp,
	customer_item_id		OUT	intTabTyp,
	dep_plan_required_flag		OUT	cflagTabTyp,
	order_number			OUT	intTabTyp,
	order_type_id			OUT	intTabTyp,
	customer_id			OUT	intTabTyp,
	invoice_to_site_use_id		OUT	intTabTyp,
	master_container_item_id	OUT	intTabTyp,
	detail_container_item_id	OUT	intTabTyp,
	load_seq_number			OUT	intTabTyp,
	call_parameters			IN OUT	intTabTyp
  );


  --
  -- Name
  --   Function Set_Request_Lines
  --
  -- Purpose
  --   Set request_id for non-ship lines that belong to the
  --   same warehouse and match the same other release criteria
  --   to be marked as Not Applicable later
  --
  -- Arguments
  --   p_sync_line_id => Sync line for the mode
  --
  -- Return Values
  --   0 => Success
  --  -1 => Failure
  --

  FUNCTION Set_Request_Lines(
	p_sync_line_id		IN	BINARY_INTEGER
  ) RETURN BINARY_INTEGER;


  --
  -- Name
  --   PROCEDURE Get_Non_Ship_Lines
  --
  -- Purpose
  --   This procedure fetches all the non-shippable lines that need to
  --   be passed through Pick Release.
  --
  -- Arguments
  --    All the column values and call_parameters
  --    Call_parameters(2) transalates as
  --   -1 => Failure
  --    0 => Success, but there are more rows to be fetched
  --    2 => Success, no more rows to fetch
  --    Call_parameters(1) is the size
  --
  -- Notes
  --

  PROCEDURE Get_Non_Ship_Lines(
	line_id				OUT	intTabTyp,
	header_id			OUT	intTabTyp,
	line_detail_id			OUT	intTabTyp,
	org_id				OUT	intTabTyp,
	call_parameters			IN OUT	intTabTyp
  );


  --
  -- Name
  --   PROCEDURE Close_Cursors
  --
  -- Purpose
  --   This function closes all the cursors that may have been
  --   opened to process pick release eligible lines.
  --
  -- Arguments
  --
  -- Notes
  --

  PROCEDURE Close_Cursors;

END WSH_PR_PICKING_ROWS;

 

/
