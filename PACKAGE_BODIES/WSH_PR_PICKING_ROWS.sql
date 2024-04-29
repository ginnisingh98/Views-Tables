--------------------------------------------------------
--  DDL for Package Body WSH_PR_PICKING_ROWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PR_PICKING_ROWS" AS
/* $Header: WSHPRPRB.pls 115.14 99/07/16 08:20:06 porting ship  $ */

--
-- Package
--   	WSH_PR_PICKING_ROWS
--
-- Purpose
--	This package does the following:
--	- Open and fetch unreleased line details cursor
--	- Open and fetch backorderd line details cursor
--	- Open and fetch non-shippable lines cursor
--	- Merges unreleased and backordered lines
--	- Provides a table of the eligible release rows
--	  to the client Pro*C program
--

  --
  -- PACKAGE CONSTANTS
  --

	SUCCESS			CONSTANT  BINARY_INTEGER := 0;
	FAILURE			CONSTANT  BINARY_INTEGER := -1;
	DONE			CONSTANT  BINARY_INTEGER := 2;
	SS_MODEL_REFETCH        CONSTANT  BINARY_INTEGER := 5;

  --
  -- PACKAGE VARIABLES
  --

	initialized				BOOLEAN := FALSE;

	-- Track local PL/SQL table information
	current_line				BINARY_INTEGER := 1;
	current_sync_line			BINARY_INTEGER := 1;
	first_line				relRecTyp;
	first_sync_line				relRecTyp;
	sync_line_id				BINARY_INTEGER;
	MAX_LINES				BINARY_INTEGER := 52;

	-- Track SQL buffers and cursors
	unreleased_SQL				VARCHAR2(10000);
	u_cursor				INTEGER;
	backordered_SQL				VARCHAR2(10000);
	b_cursor				INTEGER;
	sync_SQL				VARCHAR2(10000);
	s_cursor				INTEGER;
	non_ship_SQL				VARCHAR2(10000);
	ns_cursor				INTEGER;
	sreq_SQL    				VARCHAR2(10000);
	sreq_cursor				INTEGER;

	backorder_mode				VARCHAR2(1);
	primary_rsr				VARCHAR2(30);
	v_ignore				INTEGER;

        -- Determine if this is the first time Get_Line_Details_Pvt is called
	first_call_gld				VARCHAR2(1) := 'Y';

	-- When re-fetching due to large model/ship set sizes, to make sure
	-- only enough to lines to make up the model are fetched when it is
	-- larger than 50
	ss_model_fetch_mode                     BOOLEAN;
	model_sync_line                         BINARY_INTEGER;

	-- To keep track of non_ship lines refetch mode
	ns_lines_refetch_mode			BOOLEAN;

	-- Column variables for DBMS_SQL package for mapping to selected values from cursors

	-- Unreleased lines					-- Backordered lines
        u_line_id                         BINARY_INTEGER;	b_line_id                         BINARY_INTEGER;
        u_header_id                       BINARY_INTEGER;	b_header_id               	  BINARY_INTEGER;
        u_org_id                          BINARY_INTEGER;	b_org_id                          BINARY_INTEGER;
        u_ato_flag                        VARCHAR2(1);		b_ato_flag                        VARCHAR2(1);
        u_line_detail_id                  BINARY_INTEGER;	b_line_detail_id                  BINARY_INTEGER;
        u_ship_model_complete             VARCHAR2(1);		b_ship_model_complete             VARCHAR2(1);
        u_ship_set_number                 BINARY_INTEGER;	b_ship_set_number                 BINARY_INTEGER;
        u_parent_line_id                  BINARY_INTEGER;	b_parent_line_id                  BINARY_INTEGER;
        u_ld_warehouse_id                 BINARY_INTEGER;	b_ld_warehouse_id                 BINARY_INTEGER;
        u_ship_to_site_use_id             BINARY_INTEGER;	b_ship_to_site_use_id             BINARY_INTEGER;
        u_ship_to_contact_id              BINARY_INTEGER;	b_ship_to_contact_id              BINARY_INTEGER;
        u_ship_method_code                VARCHAR2(30);		b_ship_method_code                VARCHAR2(30);
        u_shipment_priority               VARCHAR2(30);		b_shipment_priority               VARCHAR2(30);
        u_departure_id                    BINARY_INTEGER;	b_departure_id                    BINARY_INTEGER;
        u_delivery_id                     BINARY_INTEGER;	b_delivery_id                     BINARY_INTEGER;
        u_item_type_code                  VARCHAR2(30);  	b_item_type_code                  VARCHAR2(30);
        u_schedule_date                   BINARY_INTEGER;	b_schedule_date                   BINARY_INTEGER;
        u_ordered_quantity                BINARY_INTEGER;	b_ordered_quantity                BINARY_INTEGER;
        u_cancelled_quantity              BINARY_INTEGER;	b_cancelled_quantity              BINARY_INTEGER;
        u_l_inventory_item_id             BINARY_INTEGER;	b_l_inventory_item_id             BINARY_INTEGER;
        u_ld_inventory_item_id            BINARY_INTEGER;	b_ld_inventory_item_id            BINARY_INTEGER;
	u_customer_item_id		  BINARY_INTEGER;	b_customer_item_id		  BINARY_INTEGER;
	u_dep_plan_required_flag	  VARCHAR2(1);		b_dep_plan_required_flag	  VARCHAR2(1);
        u_shipment_schedule_line_id       BINARY_INTEGER;	b_shipment_schedule_line_id       BINARY_INTEGER;
        u_unit_code                       VARCHAR2(3);   	b_unit_code                       VARCHAR2(3);
        u_line_type_code                  VARCHAR2(30);  	b_line_type_code                  VARCHAR2(30);
        u_component_code                  VARCHAR2(1000);	b_component_code                  VARCHAR2(1000);
        u_standard_comp_freeze_date	  VARCHAR2(15);  	b_standard_comp_freeze_date  	  VARCHAR2(15);
        u_order_number                    BINARY_INTEGER;	b_order_number                    BINARY_INTEGER;
        u_order_type_id                   BINARY_INTEGER;	b_order_type_id                   BINARY_INTEGER;
        u_customer_id                     BINARY_INTEGER;	b_customer_id                     BINARY_INTEGER;
        u_invoice_to_site_use_id          BINARY_INTEGER;	b_invoice_to_site_use_id          BINARY_INTEGER;
        u_planned_departure_date_d        BINARY_INTEGER;	b_planned_departure_date_d        BINARY_INTEGER;
        u_planned_departure_date_t        BINARY_INTEGER; 	b_planned_departure_date_t        BINARY_INTEGER;
	u_master_container_id		  BINARY_INTEGER;	b_master_container_id		  BINARY_INTEGER;
	u_detail_container_id		  BINARY_INTEGER;	b_detail_container_id		  BINARY_INTEGER;
	u_load_seq_number		  BINARY_INTEGER;	b_load_seq_number		  BINARY_INTEGER;
	u_invoice_value			  NUMBER;		b_invoice_value			  NUMBER;

	-- Demand synchronized
	s_line_id			  BINARY_INTEGER;
	s_header_id			  BINARY_INTEGER;
	s_org_id			  BINARY_INTEGER;
	s_ato_flag			  VARCHAR2(1);
	s_line_detail_id		  BINARY_INTEGER;
	s_ship_model_complete		  VARCHAR2(1);
	s_ship_set_number		  BINARY_INTEGER;
	s_parent_line_id		  BINARY_INTEGER;
	s_ld_warehouse_id		  BINARY_INTEGER;
	s_ship_to_site_use_id		  BINARY_INTEGER;
	s_ship_to_contact_id		  BINARY_INTEGER;
	s_ship_method_code		  VARCHAR2(30);
	s_shipment_priority		  VARCHAR2(30);
	s_departure_id			  BINARY_INTEGER;
	s_delivery_id			  BINARY_INTEGER;
	s_schedule_date			  BINARY_INTEGER;
	s_customer_item_id		  BINARY_INTEGER;
	s_dep_plan_required_flag	  VARCHAR2(1);
	s_order_number			  BINARY_INTEGER;
	s_order_type_id			  BINARY_INTEGER;
	s_customer_id			  BINARY_INTEGER;
	s_invoice_to_site_use_id	  BINARY_INTEGER;
	s_master_container_id		  BINARY_INTEGER;
	s_detail_container_id		  BINARY_INTEGER;
	s_load_seq_number		  BINARY_INTEGER;

	-- Non-ship lines
        n_line_id                         BINARY_INTEGER;
        n_header_id                       BINARY_INTEGER;
        n_line_detail_id                  BINARY_INTEGER;
	n_org_id			  BINARY_INTEGER;

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --

  --
  -- FORWARD DECLERATIONS
  --
  FUNCTION Open_Unreleased_SQL_Cursor RETURN BINARY_INTEGER;
  FUNCTION Open_Backordered_SQL_Cursor RETURN BINARY_INTEGER;
  FUNCTION Open_Non_Shippable_SQL_cursor RETURN BINARY_INTEGER;
  FUNCTION Open_Execute_Cursor (
		p_mode		IN	VARCHAR2
  ) RETURN BINARY_INTEGER;
  FUNCTION Get_Line_Details_Pvt RETURN BINARY_INTEGER;
  PROCEDURE Map_Col_Value(p_source IN VARCHAR2);
  PROCEDURE Insert_RL_Row(p_source IN VARCHAR2);

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

  FUNCTION Init
  RETURN BINARY_INTEGER IS

  cs		BINARY_INTEGER;

  BEGIN

	WSH_UTIL.Write_Log('Starting WSH_PR_PICKING_ROWS.Init');

	IF initialized = TRUE THEN
	  WSH_UTIL.Write_Log('Package already initialized for session');
	  RETURN SUCCESS;
	END IF;

	-- Store the backorder mode for the session
	backorder_mode := WSH_PR_PICKING_SESSION.backorders_flag;
	IF backorder_mode NOT IN ('E','I','O') THEN
	  WSH_UTIL.Write_Log('Invalid backorder mode.');
	  RETURN FAILURE;
	END IF;

	-- Get the primary release sequence rule attribute
	primary_rsr := WSH_PR_PICKING_SESSION.primary_rsr;

	-- If backorders are excluded or included, must process unreleased lines
	IF backorder_mode in ('E', 'I') THEN
	  WSH_UTIL.Write_Log('Calling Open_Unreleased_SQL_Cursor...');
	  cs := Open_Unreleased_SQL_Cursor;
	  IF cs = FAILURE THEN
	    WSH_UTIL.Write_Log('Error in Open_Unreleased_SQL_Cursor');
	    RETURN FAILURE;
	  END IF;
	END IF;

	-- If backorders are included or only, must process backordered lines
	IF backorder_mode in ('I', 'O') THEN
	  WSH_UTIL.Write_Log('Calling Open_Backordered_SQL_Cursor...');
	  cs := Open_Backordered_SQL_Cursor;
	  IF cs = FAILURE THEN
	    WSH_UTIL.Write_Log('Error in Open_Backordered_SQL_Cursor');
	    RETURN FAILURE;
	  END IF;
	END IF;

	ss_model_fetch_mode := FALSE;
	ns_lines_refetch_mode := FALSE;

	--
	-- Make sure the first_line record has header_id set to -1
	-- This is used to determine whether the Get_Line_Details
	-- is called for the first time or not. The first_line is set
	-- as a dummy line
	--
	first_line.header_id := -1;
	first_sync_line.header_id := -1;

	initialized := TRUE;
	RETURN SUCCESS;

  END Init;


  --
  -- Name
  --   FUNCTION Get_Row_Count
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

  FUNCTION Get_Size
  RETURN BINARY_INTEGER IS

  BEGIN

	RETURN release_table.count;

  END Get_Size;


  --
  -- Name
  --   FUNCTION Open_Unreleased_SQL_Cursor
  --
  -- Purpose
  --   This function calls WSH_PR_PICKING_SESSION to create the dynamic SQL
  --   statement for unreleased lines, calls open_execute_cursor to open,
  --   parse and execute the cursor for unreleased lines.
  --
  -- Return Values
  --   -1 => Failure
  --    0 => Success
  --
  -- Notes
  --

  FUNCTION Open_Unreleased_SQL_Cursor
  RETURN BINARY_INTEGER IS

	cs		BINARY_INTEGER;

  BEGIN
	WSH_UTIL.Write_Log('Starting WSH_PICKING_ROWS.Open_Unreleased_SQL_Cursor');

	-- Call to dynamically create SQL for unreleased lines
	WSH_UTIL.Write_Log('Calling WSH_PR_PICKING_SESSION.Unreleased_Line_Details...');
	cs := WSH_PR_PICKING_SESSION.Unreleased_Line_Details;
	IF cs = FAILURE THEN
	  WSH_UTIL.Write_Log('Error in WSH_PR_PICKING_SESSION.Unreleased_Line_Details');
	  RETURN FAILURE;
	END IF;

	-- Fetch the unreleased_SQL string
	WSH_UTIL.Write_Log('Calling WSH_PR_PICKING_SESSION.Get_Session_Value for unreleased SQL');
	unreleased_SQL := WSH_PR_PICKING_SESSION.Get_Session_Value('UNRELEASED_SQL');
	IF unreleased_SQL = '-1' THEN
	  WSH_UTIL.Write_Log('Error in call to WSH_PR_PICKING_SESSION.Get_Session_Value');
	  RETURN FAILURE;
	END IF;

	-- Call package to process buffer into cursor for parsing and executing
	cs := Open_Execute_Cursor('UNRELEASED');
	IF cs = FAILURE THEN
	  WSH_UTIL.Write_Log('Error in Open_Execute_Cursor');
	  RETURN FAILURE;
	END IF;

	RETURN SUCCESS;

  END Open_Unreleased_SQL_Cursor;


  --
  -- Name
  --   FUNCTION Open_Backordered_SQL_Cursor
  --
  -- Purpose
  --   This function calls WSH_PR_PICKING_SESSION to create the dynamic SQL
  --   statement for backordered lines, calls open_execute_cursor to open,
  --   parse and execute the cursor for backordered lines.
  --
  -- Return Values
  --   -1 => Failure
  --    0 => Success
  --
  -- Notes
  --

  FUNCTION Open_Backordered_SQL_Cursor
  RETURN BINARY_INTEGER IS

	cs		BINARY_INTEGER;

  BEGIN
	-- Call to dynamically create SQL for backordered lines
	WSH_UTIL.Write_Log('Starting WSH_PICKING_ROWS.Open_Backordered_SQL_Cursor');
	WSH_UTIL.Write_Log('Calling WSH_PR_PICKING_SESSION.Backordered_Line_Details');
	cs := WSH_PR_PICKING_SESSION.Backordered_Line_Details;
	IF cs = FAILURE THEN
	  WSH_UTIL.Write_Log('Error in WSH_PR_PICKING_SESSION.Backordered_Line_Details');
	  RETURN FAILURE;
	END IF;

	-- Fetch the backordered_SQL string
	WSH_UTIL.Write_Log('Calling WSH_PR_PICKING_SESSION.Get_Session_Value for backordered SQL');
	backordered_SQL := WSH_PR_PICKING_SESSION.Get_Session_Value('BACKORDERED_SQL');
	IF backordered_SQL = '-1' THEN
	  WSH_UTIL.Write_Log('Error in call to WSH_PR_PICKING_SESSION.Get_Session_Value');
	  RETURN FAILURE;
	END IF;

	-- Call package to process buffer into cursor for parsing and executing
	cs := Open_Execute_Cursor('BACKORDERED');
	IF cs = FAILURE THEN
	  WSH_UTIL.Write_Log('Error in Open_Execute_Cursor');
	  RETURN FAILURE;
	END IF;

	RETURN SUCCESS;

  END Open_Backordered_SQL_Cursor;


  --
  -- Name
  --   FUNCTION Open_Non_Shippable_SQL_Cursor
  --
  -- Purpose
  --   This function calls WSH_PR_PICKING_SESSION to create the dynamic SQL
  --   statement for non-shippable lines, calls open_execute_cursor to open,
  --   parse and execute the cursor for non-shippable lines.
  --
  -- Return Values
  --   -1 => Failure
  --    0 => Success
  --
  -- Notes
  --

  FUNCTION Open_Non_Shippable_SQL_Cursor
  RETURN BINARY_INTEGER IS

	cs		BINARY_INTEGER;

  BEGIN
	-- Call to dynamically create non_ship_SQL statement based on session
	-- variables
	WSH_UTIL.Write_Log('Starting WSH_PICKING_ROWS.Open_Non_Shippable_SQL_Cursor');
	WSH_UTIL.Write_Log('Calling WSH_PR_PICKING_SESSION.Non_Shippable_Line_Details');
	cs := WSH_PR_PICKING_SESSION.Non_Shippable_Lines;
	IF cs = FAILURE THEN
	  WSH_UTIL.Write_Log('Error in WSH_PR_PICKING_SESSION.Non_Shippable_Lines');
	  RETURN FAILURE;
	END IF;

	-- Fetch the non_ship_SQL string
	WSH_UTIL.Write_Log('Calling WSH_PR_PICKING_SESSION.Get_Session_Value for non-ship SQL');
	non_ship_SQL := WSH_PR_PICKING_SESSION.Get_Session_Value('NON_SHIP_SQL');
	IF non_ship_SQL = '-1' THEN
	  WSH_UTIL.Write_Log('Error in call to WSH_PR_PICKING_SESSION.Get_Session_Value');
	  RETURN FAILURE;
	END IF;

	-- Call package to process buffer into cursor for parsing and executing
	cs := Open_Execute_Cursor('NON_SHIPPABLE');
	IF cs = FAILURE THEN
	  WSH_UTIL.Write_Log('Error in Open_Execute_Cursor');
	  RETURN FAILURE;
	END IF;

	RETURN SUCCESS;

  END Open_Non_Shippable_SQL_Cursor;


  --
  -- Name
  --   FUNCTION Open_Execute_cursor
  --
  -- Purpose
  --  This routine opens the appropriate cursor, parses and executes it
  --  based on the parameter passed to it. It does this for unreleased,
  --  backordered and non-ship lines.
  --  It also binds the variables in the cursor to the release criteria values
  --
  -- Arguments
  --  p_mode specifies what cursor to use.
  --
  -- Return Values
  --   -1 => Failure
  --    0 => Success
  --
  -- Notes
  --

  FUNCTION Open_Execute_Cursor (
		   p_mode		IN	VARCHAR2
  )
  RETURN BINARY_INTEGER IS

	cs		BINARY_INTEGER;

  BEGIN
	WSH_UTIL.Write_Log('Starting WSH_PR_PICKING_ROWS.Open_Execute_Cursor');
	IF p_mode = 'UNRELEASED' THEN
	  -- Open a cursor for unreleased_SQL
	  WSH_UTIL.Write_Log('Processing unreleased cursor');
	  u_cursor := DBMS_SQL.Open_Cursor;

	  -- Parse the cursor
	  WSH_UTIL.Write_Log('Parsing unreleased cursor');
	  DBMS_SQL.Parse(u_cursor, unreleased_SQL, DBMS_SQL.v7);

	  -- Identify the column numbers with variable
	  WSH_UTIL.Write_Log('Column definition for unreleased cursor');
	  DBMS_SQL.Define_Column(u_cursor, 1,  u_line_id);
	  DBMS_SQL.Define_Column(u_cursor, 2,  u_header_id);
	  DBMS_SQL.Define_Column(u_cursor, 3,  u_org_id);
	  DBMS_SQL.Define_Column(u_cursor, 4,  u_ato_flag, 1);
	  DBMS_SQL.Define_Column(u_cursor, 5,  u_line_detail_id);
	  DBMS_SQL.Define_Column(u_cursor, 6,  u_ship_model_complete, 1);
	  DBMS_SQL.Define_Column(u_cursor, 7,  u_ship_set_number);
	  DBMS_SQL.Define_Column(u_cursor, 8,  u_parent_line_id);
	  DBMS_SQL.Define_Column(u_cursor, 9,  u_ld_warehouse_id);
	  DBMS_SQL.Define_Column(u_cursor, 10, u_ship_to_site_use_id);
	  DBMS_SQL.Define_Column(u_cursor, 11, u_ship_to_contact_id);
	  DBMS_SQL.Define_Column(u_cursor, 12, u_ship_method_code, 30);
	  DBMS_SQL.Define_Column(u_cursor, 13, u_shipment_priority, 30);
	  DBMS_SQL.Define_Column(u_cursor, 14, u_departure_id);
	  DBMS_SQL.Define_Column(u_cursor, 15, u_delivery_id);
	  DBMS_SQL.Define_Column(u_cursor, 16, u_item_type_code, 30);
	  DBMS_SQL.Define_Column(u_cursor, 17, u_schedule_date);
	  DBMS_SQL.Define_Column(u_cursor, 18, u_ordered_quantity);
	  DBMS_SQL.Define_Column(u_cursor, 19, u_cancelled_quantity);
	  DBMS_SQL.Define_Column(u_cursor, 20, u_l_inventory_item_id);
	  DBMS_SQL.Define_Column(u_cursor, 21, u_ld_inventory_item_id);
	  DBMS_SQL.Define_Column(u_cursor, 22, u_customer_item_id);
	  DBMS_SQL.Define_Column(u_cursor, 23, u_dep_plan_required_flag, 1);
	  DBMS_SQL.Define_Column(u_cursor, 24, u_shipment_schedule_line_id);
	  DBMS_SQL.Define_Column(u_cursor, 25, u_unit_code, 3);
	  DBMS_SQL.Define_Column(u_cursor, 26, u_line_type_code, 30);
	  DBMS_SQL.Define_Column(u_cursor, 27, u_component_code, 1000);
	  DBMS_SQL.Define_Column(u_cursor, 28, u_standard_comp_freeze_date, 15);
	  DBMS_SQL.Define_Column(u_cursor, 29, u_order_number);
	  DBMS_SQL.Define_Column(u_cursor, 30, u_order_type_id);
	  DBMS_SQL.Define_Column(u_cursor, 31, u_customer_id);
	  DBMS_SQL.Define_Column(u_cursor, 32, u_invoice_to_site_use_id);
	  DBMS_SQL.Define_Column(u_cursor, 33, u_planned_departure_date_d);
	  DBMS_SQL.Define_Column(u_cursor, 34, u_planned_departure_date_t);
	  DBMS_SQL.Define_Column(u_cursor, 35, u_master_container_id);
	  DBMS_SQL.Define_Column(u_cursor, 36, u_detail_container_id);
	  DBMS_SQL.Define_Column(u_cursor, 37, u_load_seq_number);
	  DBMS_SQL.Define_Column(u_cursor, 38, u_invoice_value);


	  -- Bind release criteria values
	  WSH_UTIL.Write_Log('Binding unreleased cursor');

	  IF (wsh_pr_picking_session.header_id <> 0) THEN
	    WSH_UTIL.Write_Log('X_header_id = ' || to_char(wsh_pr_picking_session.header_id));
	    DBMS_SQL.Bind_Variable(u_cursor, ':X_header_id',
					   wsh_pr_picking_session.header_id);
	  END IF;
	  WSH_UTIL.Write_Log('X_order_type_id = ' || to_char(wsh_pr_picking_session.order_type_id));
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_order_type_id',
					   wsh_pr_picking_session.order_type_id);
	  IF (wsh_pr_picking_session.customer_id <> 0) THEN
	    WSH_UTIL.Write_Log('X_customer_id = ' || to_char(wsh_pr_picking_session.customer_id));
	    DBMS_SQL.Bind_Variable(u_cursor, ':X_customer_id',
					   wsh_pr_picking_session.customer_id);
	  END IF;

	  IF (wsh_pr_picking_session.order_line_id <> 0) THEN
	    WSH_UTIL.Write_Log('X_order_line_id = ' || to_char(wsh_pr_picking_session.order_line_id));
	    DBMS_SQL.Bind_Variable(u_cursor, ':X_order_line_id',
					   wsh_pr_picking_session.order_line_id);
	  END IF;

	  WSH_UTIL.Write_Log('X_ship_set_number = ' || to_char(wsh_pr_picking_session.ship_set_number));
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_ship_set_number',
					   wsh_pr_picking_session.ship_set_number);
	  WSH_UTIL.Write_Log('X_ship_site_use_id = ' || to_char(wsh_pr_picking_session.ship_site_use_id));
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_ship_site_use_id',
					   wsh_pr_picking_session.ship_site_use_id);
	  WSH_UTIL.Write_Log('X_ship_method_code = ' || wsh_pr_picking_session.ship_method_code);
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_ship_method_code',
					   wsh_pr_picking_session.ship_method_code);
	  WSH_UTIL.Write_Log('X_warehouse_id = ' || to_char(wsh_pr_picking_session.warehouse_id));
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_warehouse_id',
					   wsh_pr_picking_session.warehouse_id);
	  WSH_UTIL.Write_Log('X_subinventory = ' || wsh_pr_picking_session.subinventory);
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_subinventory',
					   wsh_pr_picking_session.subinventory);
	  WSH_UTIL.Write_Log('X_shipment_priority = ' || wsh_pr_picking_session.shipment_priority);
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_shipment_priority',
					   wsh_pr_picking_session.shipment_priority);
	  WSH_UTIL.Write_Log('X_from_request_date = ' || to_char(wsh_pr_picking_session.from_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_from_request_date',
					   to_char(wsh_pr_picking_session.from_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_to_request_date = ' || to_char(wsh_pr_picking_session.to_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_to_request_date',
					   to_char(wsh_pr_picking_session.to_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_from_sched_ship_date = ' || to_char(wsh_pr_picking_session.from_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_from_sched_ship_date',
					   to_char(wsh_pr_picking_session.from_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_to_sched_ship_date = ' || to_char(wsh_pr_picking_session.to_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_to_sched_ship_date',
					   to_char(wsh_pr_picking_session.to_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_existing_rsvs_only_flag = ' || wsh_pr_picking_session.existing_rsvs_only_flag);
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_existing_rsvs_only_flag',
					   wsh_pr_picking_session.existing_rsvs_only_flag);
	  WSH_UTIL.Write_Log('X_inventory_item_id = ' || to_char(wsh_pr_picking_session.inventory_item_id));
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_inventory_item_id',
					   wsh_pr_picking_session.inventory_item_id);
	  WSH_UTIL.Write_Log('X_reservations = ' || wsh_pr_picking_session.reservations);
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_reservations',
					   wsh_pr_picking_session.reservations);
	  WSH_UTIL.Write_Log('X_departure_id = ' || to_char(wsh_pr_picking_session.departure_id));
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_departure_id',
					   wsh_pr_picking_session.departure_id);
	  IF (wsh_pr_picking_session.delivery_id <> 0) THEN
	    WSH_UTIL.Write_Log('X_delivery_id = ' || to_char(wsh_pr_picking_session.delivery_id));
	    DBMS_SQL.Bind_Variable(u_cursor, ':X_delivery_id',
					   wsh_pr_picking_session.delivery_id);
	  END IF;
	  WSH_UTIL.Write_Log('X_include_planned_lines = ' || wsh_pr_picking_session.include_planned_lines);
	  DBMS_SQL.Bind_Variable(u_cursor, ':X_include_planned_lines',
					   wsh_pr_picking_session.include_planned_lines);

	  -- Execute the cursor
	  WSH_UTIL.Write_Log('Executing unreleased cursor');
	  v_ignore := DBMS_SQL.Execute(u_cursor);

	ELSIF p_mode= 'BACKORDERED' THEN
	  -- Open a cursor for backordered_SQL
	  WSH_UTIL.Write_Log('Processing backordered cursor');
	  b_cursor := DBMS_SQL.Open_Cursor;

	  -- Parse the cursor
	  WSH_UTIL.Write_Log('Parsing backordered cursor');
	  DBMS_SQL.Parse(b_cursor, backordered_SQL, DBMS_SQL.v7);

	  -- Identify the column numbers with variable
	  WSH_UTIL.Write_Log('Column definition for backordered cursor');
	  DBMS_SQL.Define_Column(b_cursor, 1,  b_line_id);
	  DBMS_SQL.Define_Column(b_cursor, 2,  b_header_id);
	  DBMS_SQL.Define_Column(b_cursor, 3,  b_org_id);
	  DBMS_SQL.Define_Column(b_cursor, 4,  b_ato_flag, 1);
	  DBMS_SQL.Define_Column(b_cursor, 5,  b_line_detail_id);
	  DBMS_SQL.Define_Column(b_cursor, 6,  b_ship_model_complete, 1);
	  DBMS_SQL.Define_Column(b_cursor, 7,  b_ship_set_number);
	  DBMS_SQL.Define_Column(b_cursor, 8,  b_parent_line_id);
	  DBMS_SQL.Define_Column(b_cursor, 9,  b_ld_warehouse_id);
	  DBMS_SQL.Define_Column(b_cursor, 10, b_ship_to_site_use_id);
	  DBMS_SQL.Define_Column(b_cursor, 11, b_ship_to_contact_id);
	  DBMS_SQL.Define_Column(b_cursor, 12, b_ship_method_code, 30);
	  DBMS_SQL.Define_Column(b_cursor, 13, b_shipment_priority, 30);
	  DBMS_SQL.Define_Column(b_cursor, 14, b_departure_id);
	  DBMS_SQL.Define_Column(b_cursor, 15, b_delivery_id);
	  DBMS_SQL.Define_Column(b_cursor, 16, b_item_type_code, 30);
	  DBMS_SQL.Define_Column(b_cursor, 17, b_schedule_date);
	  DBMS_SQL.Define_Column(b_cursor, 18, b_ordered_quantity);
	  DBMS_SQL.Define_Column(b_cursor, 19, b_cancelled_quantity);
	  DBMS_SQL.Define_Column(b_cursor, 20, b_l_inventory_item_id);
	  DBMS_SQL.Define_Column(b_cursor, 21, b_ld_inventory_item_id);
	  DBMS_SQL.Define_Column(b_cursor, 22, b_customer_item_id);
	  DBMS_SQL.Define_Column(b_cursor, 23, b_dep_plan_required_flag, 1);
	  DBMS_SQL.Define_Column(b_cursor, 24, b_shipment_schedule_line_id);
	  DBMS_SQL.Define_Column(b_cursor, 25, b_unit_code, 3);
	  DBMS_SQL.Define_Column(b_cursor, 26, b_line_type_code, 30);
	  DBMS_SQL.Define_Column(b_cursor, 27, b_component_code, 1000);
	  DBMS_SQL.Define_Column(b_cursor, 28, b_standard_comp_freeze_date, 15);
	  DBMS_SQL.Define_Column(b_cursor, 29, b_order_number);
	  DBMS_SQL.Define_Column(b_cursor, 30, b_order_type_id);
	  DBMS_SQL.Define_Column(b_cursor, 31, b_customer_id);
	  DBMS_SQL.Define_Column(b_cursor, 32, b_invoice_to_site_use_id);
	  DBMS_SQL.Define_Column(b_cursor, 33, b_planned_departure_date_d);
	  DBMS_SQL.Define_Column(b_cursor, 34, b_planned_departure_date_t);
	  DBMS_SQL.Define_Column(b_cursor, 35, b_master_container_id);
	  DBMS_SQL.Define_Column(b_cursor, 36, b_detail_container_id);
	  DBMS_SQL.Define_Column(b_cursor, 37, b_load_seq_number);
	  DBMS_SQL.Define_Column(b_cursor, 38, b_invoice_value);

	  -- Bind release criteria values
	  WSH_UTIL.Write_Log('Binding backordered cursor');

	  IF (wsh_pr_picking_session.header_id <> 0) THEN
	    WSH_UTIL.Write_Log('X_header_id = ' || to_char(wsh_pr_picking_session.header_id));
	    DBMS_SQL.Bind_Variable(b_cursor, ':X_header_id',
					   wsh_pr_picking_session.header_id);
	  END IF;
	  WSH_UTIL.Write_Log('X_order_type_id = ' || to_char(wsh_pr_picking_session.order_type_id));
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_order_type_id',
					   wsh_pr_picking_session.order_type_id);
	  IF (wsh_pr_picking_session.customer_id <> 0) THEN
	    WSH_UTIL.Write_Log('X_customer_id = ' || to_char(wsh_pr_picking_session.customer_id));
	    DBMS_SQL.Bind_Variable(b_cursor, ':X_customer_id',
					   wsh_pr_picking_session.customer_id);
	  END IF;

	  IF (wsh_pr_picking_session.order_line_id <> 0) THEN
	    WSH_UTIL.Write_Log('X_order_line_id = ' || to_char(wsh_pr_picking_session.order_line_id));
	    DBMS_SQL.Bind_Variable(b_cursor, ':X_order_line_id',
					   wsh_pr_picking_session.order_line_id);
	   END IF;

	  WSH_UTIL.Write_Log('X_ship_set_number = ' || to_char(wsh_pr_picking_session.ship_set_number));
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_ship_set_number',
					   wsh_pr_picking_session.ship_set_number);
	  WSH_UTIL.Write_Log('X_ship_site_use_id = ' || to_char(wsh_pr_picking_session.ship_site_use_id));
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_ship_site_use_id',
					   wsh_pr_picking_session.ship_site_use_id);
	  WSH_UTIL.Write_Log('X_ship_method_code = ' || wsh_pr_picking_session.ship_method_code);
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_ship_method_code',
					   wsh_pr_picking_session.ship_method_code);
	  WSH_UTIL.Write_Log('X_warehouse_id = ' || to_char(wsh_pr_picking_session.warehouse_id));
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_warehouse_id',
					   wsh_pr_picking_session.warehouse_id);
	  WSH_UTIL.Write_Log('X_subinventory = ' || wsh_pr_picking_session.subinventory);
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_subinventory',
					   wsh_pr_picking_session.subinventory);
	  WSH_UTIL.Write_Log('X_shipment_priority = ' || wsh_pr_picking_session.shipment_priority);
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_shipment_priority',
					   wsh_pr_picking_session.shipment_priority);
	  WSH_UTIL.Write_Log('X_from_request_date = ' || to_char(wsh_pr_picking_session.from_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_from_request_date',
					   to_char(wsh_pr_picking_session.from_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_to_request_date = ' || to_char(wsh_pr_picking_session.to_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_to_request_date',
					   to_char(wsh_pr_picking_session.to_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_from_sched_ship_date = ' || to_char(wsh_pr_picking_session.from_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_from_sched_ship_date',
					   to_char(wsh_pr_picking_session.from_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_to_sched_ship_date = ' || to_char(wsh_pr_picking_session.to_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_to_sched_ship_date',
					   to_char(wsh_pr_picking_session.to_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_existing_rsvs_only_flag = ' || wsh_pr_picking_session.existing_rsvs_only_flag);
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_existing_rsvs_only_flag',
					   wsh_pr_picking_session.existing_rsvs_only_flag);
	  WSH_UTIL.Write_Log('X_inventory_item_id = ' || to_char(wsh_pr_picking_session.inventory_item_id));
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_inventory_item_id',
					   wsh_pr_picking_session.inventory_item_id);
	  WSH_UTIL.Write_Log('X_reservations = ' || wsh_pr_picking_session.reservations);
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_reservations',
					   wsh_pr_picking_session.reservations);
	  WSH_UTIL.Write_Log('X_departure_id = ' || to_char(wsh_pr_picking_session.departure_id));
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_departure_id',
					   wsh_pr_picking_session.departure_id);
	  IF (wsh_pr_picking_session.delivery_id <> 0) THEN
	    WSH_UTIL.Write_Log('X_delivery_id = ' || to_char(wsh_pr_picking_session.delivery_id));
	    DBMS_SQL.Bind_Variable(b_cursor, ':X_delivery_id',
					   wsh_pr_picking_session.delivery_id);
	  END IF;
	  WSH_UTIL.Write_Log('X_include_planned_lines = ' || wsh_pr_picking_session.include_planned_lines);
	  DBMS_SQL.Bind_Variable(b_cursor, ':X_include_planned_lines',
					   wsh_pr_picking_session.include_planned_lines);

	  -- Execute the cursor
	  WSH_UTIL.Write_Log('Executing backordered cursor');
	  v_ignore := DBMS_SQL.Execute(b_cursor);

	ELSIF p_mode = 'SYNC' THEN

	  -- Open a cursor for sync_SQL
	  WSH_UTIL.Write_Log('Processing sync cursor');
	  s_cursor := DBMS_SQL.Open_Cursor;

	  -- Parse the cursor
	  WSH_UTIL.Write_Log('Parsing sync cursor');
	  DBMS_SQL.Parse(s_cursor, sync_SQL, DBMS_SQL.v7);

	  -- Identify the column numbers with variable
	  WSH_UTIL.Write_Log('Column definition for sync cursor');
	  DBMS_SQL.Define_Column(s_cursor, 1,  s_line_id);
	  DBMS_SQL.Define_Column(s_cursor, 2,  s_header_id);
	  DBMS_SQL.Define_Column(s_cursor, 3,  s_org_id);
	  DBMS_SQL.Define_Column(s_cursor, 4,  s_ato_flag, 1);
	  DBMS_SQL.Define_Column(s_cursor, 5,  s_line_detail_id);
	  DBMS_SQL.Define_Column(s_cursor, 6,  s_ship_model_complete, 1);
	  DBMS_SQL.Define_Column(s_cursor, 7,  s_ship_set_number);
	  DBMS_SQL.Define_Column(s_cursor, 8,  s_parent_line_id);
	  DBMS_SQL.Define_Column(s_cursor, 9,  s_ld_warehouse_id);
	  DBMS_SQL.Define_Column(s_cursor, 10, s_ship_to_site_use_id);
	  DBMS_SQL.Define_Column(s_cursor, 11, s_ship_to_contact_id);
	  DBMS_SQL.Define_Column(s_cursor, 12, s_ship_method_code, 30);
	  DBMS_SQL.Define_Column(s_cursor, 13, s_shipment_priority, 30);
	  DBMS_SQL.Define_Column(s_cursor, 14, s_departure_id);
	  DBMS_SQL.Define_Column(s_cursor, 15, s_delivery_id);
	  DBMS_SQL.Define_Column(s_cursor, 16, s_schedule_date);
	  DBMS_SQL.Define_Column(s_cursor, 17, s_customer_item_id);
	  DBMS_SQL.Define_Column(s_cursor, 18, s_dep_plan_required_flag, 1);
	  DBMS_SQL.Define_Column(s_cursor, 19, s_order_number);
	  DBMS_SQL.Define_Column(s_cursor, 20, s_order_type_id);
	  DBMS_SQL.Define_Column(s_cursor, 21, s_customer_id);
	  DBMS_SQL.Define_Column(s_cursor, 22, s_invoice_to_site_use_id);
	  DBMS_SQL.Define_Column(s_cursor, 23, s_master_container_id);
	  DBMS_SQL.Define_Column(s_cursor, 24, s_detail_container_id);
	  DBMS_SQL.Define_Column(s_cursor, 25, s_load_seq_number);

	  -- Bind release criteria values
	  WSH_UTIL.Write_Log('Binding sync cursor');

	  WSH_UTIL.Write_Log('X_p_param_1 = ' || to_char(wsh_pr_picking_session.sync_line_id));
	  DBMS_SQL.Bind_Variable(s_cursor, ':X_p_param_1',
					   wsh_pr_picking_session.sync_line_id);
	  WSH_UTIL.Write_Log('X_warehouse_id = ' || to_char(wsh_pr_picking_session.warehouse_id));
	  DBMS_SQL.Bind_Variable(s_cursor, ':X_warehouse_id',
					   wsh_pr_picking_session.warehouse_id);
	  WSH_UTIL.Write_Log('X_subinventory = ' || wsh_pr_picking_session.subinventory);
	  DBMS_SQL.Bind_Variable(s_cursor, ':X_subinventory',
					   wsh_pr_picking_session.subinventory);
	  WSH_UTIL.Write_Log('X_from_request_date = ' || to_char(wsh_pr_picking_session.from_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(s_cursor, ':X_from_request_date',
					   to_char(wsh_pr_picking_session.from_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_to_request_date = ' || to_char(wsh_pr_picking_session.to_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(s_cursor, ':X_to_request_date',
					   to_char(wsh_pr_picking_session.to_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_from_sched_ship_date = ' || to_char(wsh_pr_picking_session.from_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(s_cursor, ':X_from_sched_ship_date',
					   to_char(wsh_pr_picking_session.from_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_to_sched_ship_date = ' || to_char(wsh_pr_picking_session.to_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(s_cursor, ':X_to_sched_ship_date',
					   to_char(wsh_pr_picking_session.to_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_existing_rsvs_only_flag = ' || wsh_pr_picking_session.existing_rsvs_only_flag);
	  DBMS_SQL.Bind_Variable(s_cursor, ':X_existing_rsvs_only_flag',
					   wsh_pr_picking_session.existing_rsvs_only_flag);
	  WSH_UTIL.Write_Log('X_inventory_item_id = ' || to_char(wsh_pr_picking_session.inventory_item_id));
	  DBMS_SQL.Bind_Variable(s_cursor, ':X_inventory_item_id',
					   wsh_pr_picking_session.inventory_item_id);
	  WSH_UTIL.Write_Log('X_reservations = ' || wsh_pr_picking_session.reservations);
	  DBMS_SQL.Bind_Variable(s_cursor, ':X_reservations',
					   wsh_pr_picking_session.reservations);
	  WSH_UTIL.Write_Log('X_departure_id = ' || to_char(wsh_pr_picking_session.departure_id));
	  DBMS_SQL.Bind_Variable(s_cursor, ':X_departure_id',
					   wsh_pr_picking_session.departure_id);
	  IF (wsh_pr_picking_session.delivery_id <> 0) THEN
	    WSH_UTIL.Write_Log('X_delivery_id = ' || to_char(wsh_pr_picking_session.delivery_id));
	    DBMS_SQL.Bind_Variable(s_cursor, ':X_delivery_id',
					   wsh_pr_picking_session.delivery_id);
	  END IF;
	  WSH_UTIL.Write_Log('X_include_planned_lines = ' || wsh_pr_picking_session.include_planned_lines);
	  DBMS_SQL.Bind_Variable(s_cursor, ':X_include_planned_lines',
					   wsh_pr_picking_session.include_planned_lines);

	  -- Execute the cursor
	  WSH_UTIL.Write_Log('Executing sync cursor');
	  v_ignore := DBMS_SQL.Execute(s_cursor);

	ELSIF p_mode = 'NON_SHIPPABLE' THEN
	  -- Open a cursor for non_ship_SQL
	  WSH_UTIL.Write_Log('Processing non-ship cursor');
	  ns_cursor := DBMS_SQL.Open_Cursor;

	  -- Parse the cursor
	  WSH_UTIL.Write_Log('Parsing non-ship cursor');
	  DBMS_SQL.Parse(ns_cursor, non_ship_SQL, DBMS_SQL.v7);

	  WSH_UTIL.Write_Log('Column definition for non-ship cursor');
	  DBMS_SQL.Define_Column(ns_cursor, 1,  n_line_id);
	  DBMS_SQL.Define_Column(ns_cursor, 2,  n_header_id);
	  DBMS_SQL.Define_Column(ns_cursor, 3,  n_line_detail_id);
	  DBMS_SQL.Define_Column(ns_cursor, 4,  n_org_id);

	  -- Bind release criteria values
	  WSH_UTIL.Write_Log('Binding non-ship cursor');

	  WSH_UTIL.Write_Log('X_request_id = ' || to_char(wsh_pr_picking_session.request_id));
	  DBMS_SQL.Bind_Variable(ns_cursor, ':X_request_id',
					   wsh_pr_picking_session.request_id);

	  IF (wsh_pr_picking_session.header_id <> 0) THEN
	    WSH_UTIL.Write_Log('X_header_id = ' || to_char(wsh_pr_picking_session.header_id));
	    DBMS_SQL.Bind_Variable(ns_cursor, ':X_header_id',
					   wsh_pr_picking_session.header_id);
	  END IF;
	  WSH_UTIL.Write_Log('X_order_type_id = ' || to_char(wsh_pr_picking_session.order_type_id));
	  DBMS_SQL.Bind_Variable(ns_cursor, ':X_order_type_id',
					   wsh_pr_picking_session.order_type_id);
	  IF (wsh_pr_picking_session.customer_id <> 0) THEN
	    WSH_UTIL.Write_Log('X_customer_id = ' || to_char(wsh_pr_picking_session.customer_id));
	    DBMS_SQL.Bind_Variable(ns_cursor, ':X_customer_id',
					   wsh_pr_picking_session.customer_id);
	  END IF;

	  IF (wsh_pr_picking_session.order_line_id <> 0) THEN
	    WSH_UTIL.Write_Log('X_order_line_id = ' || to_char(wsh_pr_picking_session.order_line_id));
	    DBMS_SQL.Bind_Variable(ns_cursor, ':X_order_line_id',
					   wsh_pr_picking_session.order_line_id);
	  END IF;

	  WSH_UTIL.Write_Log('X_ship_set_number = ' || to_char(wsh_pr_picking_session.ship_set_number));
	  DBMS_SQL.Bind_Variable(ns_cursor, ':X_ship_set_number',
					   wsh_pr_picking_session.ship_set_number);
	  WSH_UTIL.Write_Log('X_warehouse_id = ' || to_char(wsh_pr_picking_session.warehouse_id));
	  DBMS_SQL.Bind_Variable(ns_cursor, ':X_warehouse_id',
					   wsh_pr_picking_session.warehouse_id);
	  WSH_UTIL.Write_Log('X_from_request_date = ' || to_char(wsh_pr_picking_session.from_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(ns_cursor, ':X_from_request_date',
					   to_char(wsh_pr_picking_session.from_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_to_request_date = ' || to_char(wsh_pr_picking_session.to_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(ns_cursor, ':X_to_request_date',
					   to_char(wsh_pr_picking_session.to_request_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_from_sched_ship_date = ' || to_char(wsh_pr_picking_session.from_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(ns_cursor, ':X_from_sched_ship_date',
					   to_char(wsh_pr_picking_session.from_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_to_sched_ship_date = ' || to_char(wsh_pr_picking_session.to_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  DBMS_SQL.Bind_Variable(ns_cursor, ':X_to_sched_ship_date',
					   to_char(wsh_pr_picking_session.to_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	  WSH_UTIL.Write_Log('X_inventory_item_id = ' || to_char(wsh_pr_picking_session.inventory_item_id));
	  DBMS_SQL.Bind_Variable(ns_cursor, ':X_inventory_item_id',
					   wsh_pr_picking_session.inventory_item_id);
	  IF (wsh_pr_picking_session.departure_id <> 0) THEN
	    WSH_UTIL.Write_Log('X_departure_id = ' || to_char(wsh_pr_picking_session.departure_id));
	    DBMS_SQL.Bind_Variable(ns_cursor, ':X_departure_id',
					   wsh_pr_picking_session.departure_id);
	  END IF;
	  IF (wsh_pr_picking_session.delivery_id <> 0) THEN
	    WSH_UTIL.Write_Log('X_delivery_id = ' || to_char(wsh_pr_picking_session.delivery_id));
	    DBMS_SQL.Bind_Variable(ns_cursor, ':X_delivery_id',
					   wsh_pr_picking_session.delivery_id);
	  END IF;

	  -- Execute the cursor
	  WSH_UTIL.Write_Log('Executing non-ship cursor');
	  v_ignore := DBMS_SQL.Execute(ns_cursor);

	ELSE
	  WSH_UTIL.Write_Log('Invalid mode for Open_Execute_Cursor');
	  RETURN FAILURE;
	END IF;

	RETURN SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      Close_Cursors;
      WSH_UTIL.Default_Handler('WSH_PR_PICKING_ROWS.Open_Execute_Cursor');
      RETURN FAILURE;

  END Open_Execute_Cursor;


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
		call_parameters			IN OUT	intTabTyp)
	IS

	i		BINARY_INTEGER;
	cs		BINARY_INTEGER;
        custom_line BINARY_INTEGER;

  BEGIN
	WSH_UTIL.Write_Log('In Get_Line_Details');
	-- handle uninitialized package errors here
	IF initialized = FALSE THEN
	   WSH_UTIL.Write_Log('The package must be initialized before use');
	   call_parameters(2) := FAILURE;
	   RETURN;
	END IF;

	-- Clear the table and initialize table index
	IF release_table.count <> 0 THEN
	  call_parameters.delete;
	  release_table.delete;
	  current_line := 1;
	END IF;

	-- If called after the first time, place the last row fetched in previous
	-- call as the first row, since it was not returned in the previous call
	IF first_line.header_id <> -1 THEN
	  release_table(current_line) := first_line;
	  current_line := current_line + 1;
	END IF;

        WSH_UTIL.Write_Log('Fetching Customer specified lines');

        custom_line := WSH_PR_CUSTOM.PROCESS_LINES;

        IF ( custom_line >1 ) THEN
           MAX_LINES :=  custom_line + 2 ;
        END IF ;
        WSH_UTIL.Write_Log('Custom Lines set to  ' || to_char(custom_line));
        WSH_UTIL.Write_Log('Setting MAX_LINES to ' || to_char(MAX_LINES));

        IF ss_model_fetch_mode = FALSE THEN
          LOOP
            IF current_line < MAX_LINES THEN
              -- Inserts the next line detail into release_table
              cs := Get_Line_Details_Pvt;
              IF cs = FAILURE THEN
                WSH_UTIL.Write_Log('Failed in Get_Line_Details_Pvt');
		call_parameters(2) := FAILURE;
		RETURN;
              ELSIF cs = DONE THEN
                WSH_UTIL.Write_Log('Fetched all lines');
                EXIT;
              END IF;
            ELSE
              WSH_UTIL.Write_Log('Testing for incomplete model');
              model_sync_line := 0;
              IF (release_table(current_line - 1).item_type_code = 'MODEL' or
                  release_table(current_line - 1).item_type_code = 'KIT' or
                  release_table(current_line - 1).parent_line_id > 0) THEN
                  IF release_table(current_line - 1).parent_line_id > 0 THEN
                    model_sync_line := release_table(current_line - 1).parent_line_id;
                  ELSE
                    model_sync_line := release_table(current_line - 1).line_id;
                  END IF;
              END IF;
              WSH_UTIL.Write_Log('Parent model line_id is ' || to_char(model_sync_line));
              IF (((release_table(current_line - 1).ship_set_number > 0) and
                   (release_table(current_line - 1).ship_set_number =
                    release_table(current_line - 2).ship_set_number) and
                   (release_table(current_line - 1).header_id =
                    release_table(current_line - 2).header_id)) or
                  (model_sync_line > 0 and
                   (release_table(current_line - 2).line_id = model_sync_line or
                    release_table(current_line - 2).parent_line_id = model_sync_line))) THEN
                WSH_UTIL.Write_Log('Large model or ss, entering MODEL FETCH MODE');
                ss_model_fetch_mode := TRUE;
                EXIT;
              ELSE
                first_line := release_table(current_line - 1);
                release_table.delete(current_line - 1);
                current_line := current_line - 1;
                EXIT;
              END IF;
            END IF;
          END LOOP;
        END IF;

        IF ss_model_fetch_mode = TRUE THEN
          LOOP
            WSH_UTIL.Write_Log('In model fetch mode for model ' ||
                                to_char(model_sync_line));
            IF current_line <= 101 THEN
              -- We are still in the midst of a ship set or a large model,
              -- so continue to fetch lines
              -- Inserts the next line detail into release_table
              cs := Get_Line_Details_Pvt;
              IF cs = FAILURE THEN
                WSH_UTIL.Write_Log('Failed in Get_Line_Details_Pvt');
                ss_model_fetch_mode := FALSE;
                model_sync_line := 0;
		call_parameters(2) := FAILURE;
		RETURN;
              ELSIF cs = DONE THEN
                WSH_UTIL.Write_Log('Fetched all lines');
                ss_model_fetch_mode := FALSE;
                model_sync_line := 0;
                EXIT;
              END IF;

              IF (((release_table(current_line - 1).ship_set_number > 0) and
                   (release_table(current_line - 1).ship_set_number =
                    release_table(current_line - 2).ship_set_number) and
                   (release_table(current_line - 1).header_id =
                    release_table(current_line - 2).header_id)) or
                  (model_sync_line > 0 and
                   (release_table(current_line - 1).line_id = model_sync_line or
                    release_table(current_line - 1).parent_line_id = model_sync_line))) THEN
                null;
              ELSE
                -- fetched an entire model, so return to wshpgld
                WSH_UTIL.Write_Log('Entire large model fetched, exit MODEL FETCH MODE');
                ss_model_fetch_mode := FALSE;
                model_sync_line := 0;
                first_line := release_table(current_line - 1);
                release_table.delete(current_line - 1);
                current_line := current_line - 1;
                EXIT;
              END IF;
            ELSE
              -- Reached the end of buffer, but not model, must
              -- return rows and indicate to C program to refetch
              WSH_UTIL.Write_Log('Setting to MODEL RE-FETCH MODE for large model');
              first_line := release_table(current_line - 1);
              release_table.delete(current_line - 1);
              current_line := current_line - 1;
              call_parameters(3) := SS_MODEL_REFETCH;
              EXIT;
            END IF;
          END LOOP;
        END IF;


	-- Setup return values
	FOR i IN 1..release_table.count LOOP
	  line_id(i) := release_table(i).line_id;
	  header_id(i) := release_table(i).header_id;
	  org_id(i) := release_table(i).org_id;
	  ato_flag(i) := release_table(i).ato_flag;
	  line_detail_id(i) := release_table(i).line_detail_id;
	  ship_model_complete(i) := release_table(i).ship_model_complete;
	  ship_set_number(i) := release_table(i).ship_set_number;
	  parent_line_id(i) := release_table(i).parent_line_id;
	  ld_warehouse_id(i) := release_table(i).ld_warehouse_id;
	  ship_to_site_use_id(i) := release_table(i).ship_to_site_use_id;
	  ship_to_contact_id(i) := release_table(i).ship_to_contact_id;
	  ship_method_code(i) := release_table(i).ship_method_code;
	  shipment_priority(i) := release_table(i).shipment_priority;
	  departure_id(i) := release_table(i).departure_id;
	  delivery_id(i) := release_table(i).delivery_id;
	  item_type_code(i) := release_table(i).item_type_code;
	  schedule_date(i) := release_table(i).schedule_date;
	  ordered_quantity(i) := release_table(i).ordered_quantity;
	  cancelled_quantity(i) := release_table(i).cancelled_quantity;
	  l_inventory_item_id(i) := release_table(i).l_inventory_item_id;
	  ld_inventory_item_id(i) := release_table(i).ld_inventory_item_id;
	  customer_item_id(i) := release_table(i).customer_item_id;
	  dep_plan_required_flag(i) := release_table(i).dep_plan_required_flag;
	  shipment_schedule_line_id(i) := release_table(i).shipment_schedule_line_id;
	  unit_code(i) := release_table(i).unit_code;
	  line_type_code(i) := release_table(i).line_type_code;
	  component_code(i) := release_table(i).component_code;
	  standard_comp_freeze_date(i) := release_table(i).standard_comp_freeze_date;
	  order_number(i) := release_table(i).order_number;
	  order_type_id(i) := release_table(i).order_type_id;
	  customer_id(i) := release_table(i).customer_id;
	  invoice_to_site_use_id(i) := release_table(i).invoice_to_site_use_id;
	  master_container_item_id(i) := release_table(i).master_container_item_id;
	  detail_container_item_id(i) := release_table(i).detail_container_item_id;
	  load_seq_number(i) := release_table(i).load_seq_number;
	  backorder_line(i) := release_table(i).backorder_line;
	  primary_rsr_switch(i) := release_table(i).primary_rsr_switch;
	END LOOP;
	call_parameters(1) := release_table.count;
	IF cs = DONE THEN
	  call_parameters(2) := DONE;
	  -- Reinitialize the first line marker since we have fetched all rows for
	  -- reuse later with non-shippable lines
	  first_line.header_id := -1;
	  IF release_table.count > 0 THEN
	    IF ss_model_fetch_mode = FALSE THEN
	      primary_rsr_switch(release_table.count) := 1;
	    END IF;
	  END IF;
	ELSE
	  call_parameters(2) := SUCCESS;
	END IF;

  EXCEPTION
    WHEN OTHERS THEN
      Close_Cursors;
      WSH_UTIL.Default_Handler('WSH_PR_PICKING_ROWS.Get_Line_Details');
      call_parameters(2) := FAILURE;

  END Get_Line_Details;


  --
  -- Name
  --   FUNCTION Get_Line_Details_Pvt
  --
  -- Purpose
  --   This function fetches rows from each of the cursors for unreleased and
  --   backordered lines, performs a merge sort and inserts the next row in
  --   the release_table table based on the release sequence rule. It also
  --   indiactes in a column if there is a change in the most significant
  --   criteria in the release sequence rule.
  --
  -- Notes
  --

  FUNCTION Get_Line_Details_Pvt
  RETURN BINARY_INTEGER IS

	next_line		VARCHAR2(1);
	empty_cursor		VARCHAR2(1) := '';
	cs			BINARY_INTEGER;
	line			BINARY_INTEGER;

  BEGIN

    --
    -- Fetch unreleased lines only
    --
    line := 1;
    IF backorder_mode = 'E' THEN
      IF DBMS_SQL.Fetch_Rows(u_cursor) > 0 THEN
        Map_Col_Value('u');
        Insert_RL_Row('u');
	RETURN SUCCESS;
      ELSE
	DBMS_SQL.Close_Cursor(u_cursor);
	RETURN DONE;
      END IF;

    --
    -- Fetch backordered lines only
    --
    ELSIF backorder_mode = 'O' THEN

      line := 2;
      IF DBMS_SQL.Fetch_Rows(b_cursor) > 0 THEN
        Map_Col_Value('b');
        Insert_RL_Row('b');
	RETURN SUCCESS;
      ELSE
	DBMS_SQL.Close_Cursor(b_cursor);
	RETURN DONE;
      END IF;
    --
    -- Fetch both unreleased and backordered lines, and compare
    --
    ELSIF backorder_mode = 'I' THEN

      -- Fetch row from unreleased lines cursor
      line := 3;
      IF first_call_gld = 'Y' THEN
      line := 4;
	IF DBMS_SQL.Fetch_Rows(u_cursor) > 0 THEN
	  line := 41;
	  Map_Col_Value('u');
	ELSE
	  WSH_UTIL.Write_Log('Closing cursor u');
	  DBMS_SQL.Close_Cursor(u_cursor);
	END IF;

      line := 5;
	IF DBMS_SQL.Fetch_Rows(b_cursor) > 0 THEN
	  Map_Col_Value('b');
	ELSE
	  WSH_UTIL.Write_Log('Closing cursor b');
	  DBMS_SQL.Close_Cursor(b_cursor);
	END IF;

      line := 6;
	IF NOT DBMS_SQL.Is_Open(u_cursor) AND NOT DBMS_SQL.Is_Open(b_cursor) THEN
	  first_call_gld := 'N';
	  RETURN DONE;
	END IF;

      line := 7;
	IF NOT DBMS_SQL.Is_Open(u_cursor) THEN
	  Insert_RL_Row('b');
	  first_call_gld := 'N';
	  RETURN SUCCESS;
	END IF;

      line := 8;
	IF NOT DBMS_SQL.Is_Open(b_cursor) THEN
	  line := 81;
	  Insert_RL_Row('u');
	  first_call_gld := 'N';
	  RETURN SUCCESS;
	END IF;
	first_call_gld := 'N';
      END IF;

      line := 9;
      IF NOT DBMS_SQL.Is_Open(b_cursor) THEN
        IF DBMS_SQL.Fetch_Rows(u_cursor) > 0 THEN
	  Map_Col_Value('u');
	  Insert_RL_Row('u');
	  RETURN SUCCESS;
        ELSE
	  DBMS_SQL.Close_Cursor(u_cursor);
	  RETURN DONE;
        END IF;
      ELSIF NOT DBMS_SQL.Is_Open(u_cursor) THEN
      line := 10;
        IF DBMS_SQL.Fetch_Rows(b_cursor) > 0 THEN
	  Map_Col_Value('b');
	  Insert_RL_Row('b');
	  RETURN SUCCESS;
        ELSE
	  DBMS_SQL.Close_Cursor(b_cursor);
	  RETURN DONE;
        END IF;
      ELSE
      line := 11;
        next_line := WSH_PR_PICKING_SESSION.Get_Next_Line_Detail(u_invoice_value,
								 b_invoice_value,
								 u_order_number,
								 b_order_number,
								 u_schedule_date,
								 b_schedule_date,
								 u_planned_departure_date_d,
								 u_planned_departure_date_t,
								 b_planned_departure_date_d,
								 b_planned_departure_date_t,
								 u_shipment_priority,
								 b_shipment_priority);

	IF next_line = 'u' THEN
	  Insert_RL_Row('u');
	  IF DBMS_SQL.Fetch_Rows(u_cursor) > 0 THEN
	    Map_Col_Value('u');
	    RETURN SUCCESS;
          ELSE
	    DBMS_SQL.Close_Cursor(u_cursor);
	    Insert_RL_Row('b');
	    RETURN SUCCESS;
          END IF;
	ELSIF next_line = 'b' THEN
	  Insert_RL_Row('b');
	  IF DBMS_SQL.Fetch_Rows(b_cursor) > 0 THEN
	    Map_Col_Value('b');
	    RETURN SUCCESS;
          ELSE
	    DBMS_SQL.Close_Cursor(b_cursor);
	    Insert_RL_Row('u');
	    RETURN SUCCESS;
          END IF;
	END IF;

      line := 12;
	IF NOT DBMS_SQL.Is_Open(u_cursor) AND NOT DBMS_SQL.Is_Open(b_cursor) THEN
	  RETURN DONE;
	END IF;

      END IF;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      Close_Cursors;
      WSH_UTIL.Write_Log(to_char(line));
      WSH_UTIL.Default_Handler('WSH_PR_PICKING_ROWS.Get_Line_Details_Pvt');
      RETURN FAILURE;

  END Get_Line_Details_Pvt;


  --
  -- Name
  --   PROCEDURE Map_Col_Value
  --
  -- Purpose
  --   This function maps the column value from the cursor
  --   to the variable (based on the source) after each fetch
  --   row call to DBMS_SQL. Utility to go with DBMS_SQL.
  --
  -- Arguments
  --   p_source - indicates whether to map the value for
  --              backordered lines ('b') or unreleased
  --              lines ('u')
  --
  -- Notes
  --

  PROCEDURE Map_Col_Value(
		   p_source		IN	VARCHAR2
  ) IS

	cs		BINARY_INTEGER;

  BEGIN
	IF p_source = 'u' THEN
	  DBMS_SQL.Column_Value(u_cursor, 1,  u_line_id);
	  DBMS_SQL.Column_Value(u_cursor, 2,  u_header_id);
	  DBMS_SQL.Column_Value(u_cursor, 3,  u_org_id);
	  DBMS_SQL.Column_Value(u_cursor, 4,  u_ato_flag);
	  DBMS_SQL.Column_Value(u_cursor, 5,  u_line_detail_id);
	  DBMS_SQL.Column_Value(u_cursor, 6,  u_ship_model_complete);
	  DBMS_SQL.Column_Value(u_cursor, 7,  u_ship_set_number);
	  DBMS_SQL.Column_Value(u_cursor, 8,  u_parent_line_id);
	  DBMS_SQL.Column_Value(u_cursor, 9,  u_ld_warehouse_id);
	  DBMS_SQL.Column_Value(u_cursor, 10, u_ship_to_site_use_id);
	  DBMS_SQL.Column_Value(u_cursor, 11, u_ship_to_contact_id);
	  DBMS_SQL.Column_Value(u_cursor, 12, u_ship_method_code);
	  DBMS_SQL.Column_Value(u_cursor, 13, u_shipment_priority);
	  DBMS_SQL.Column_Value(u_cursor, 14, u_departure_id);
	  DBMS_SQL.Column_Value(u_cursor, 15, u_delivery_id);
	  DBMS_SQL.Column_Value(u_cursor, 16, u_item_type_code);
	  DBMS_SQL.Column_Value(u_cursor, 17, u_schedule_date);
	  DBMS_SQL.Column_Value(u_cursor, 18, u_ordered_quantity);
	  DBMS_SQL.Column_Value(u_cursor, 19, u_cancelled_quantity);
	  DBMS_SQL.Column_Value(u_cursor, 20, u_l_inventory_item_id);
	  DBMS_SQL.Column_Value(u_cursor, 21, u_ld_inventory_item_id);
	  DBMS_SQL.Column_Value(u_cursor, 22, u_customer_item_id);
	  DBMS_SQL.Column_Value(u_cursor, 23, u_dep_plan_required_flag);
	  DBMS_SQL.Column_Value(u_cursor, 24, u_shipment_schedule_line_id);
	  DBMS_SQL.Column_Value(u_cursor, 25, u_unit_code);
	  DBMS_SQL.Column_Value(u_cursor, 26, u_line_type_code);
	  DBMS_SQL.Column_Value(u_cursor, 27, u_component_code);
	  DBMS_SQL.Column_Value(u_cursor, 28, u_standard_comp_freeze_date);
	  DBMS_SQL.Column_Value(u_cursor, 29, u_order_number);
	  DBMS_SQL.Column_Value(u_cursor, 30, u_order_type_id);
	  DBMS_SQL.Column_Value(u_cursor, 31, u_customer_id);
	  DBMS_SQL.Column_Value(u_cursor, 32, u_invoice_to_site_use_id);
	  DBMS_SQL.Column_Value(u_cursor, 33, u_planned_departure_date_d);
	  DBMS_SQL.Column_Value(u_cursor, 34, u_planned_departure_date_t);
	  DBMS_SQL.Column_Value(u_cursor, 35, u_master_container_id);
	  DBMS_SQL.Column_Value(u_cursor, 36, u_detail_container_id);
	  DBMS_SQL.Column_Value(u_cursor, 37, u_load_seq_number);
	  DBMS_SQL.Column_Value(u_cursor, 38, u_invoice_value);
	ELSIF p_source = 'b' THEN
	  DBMS_SQL.Column_Value(b_cursor, 1,  b_line_id);
	  DBMS_SQL.Column_Value(b_cursor, 2,  b_header_id);
	  DBMS_SQL.Column_Value(b_cursor, 3,  b_org_id);
	  DBMS_SQL.Column_Value(b_cursor, 4,  b_ato_flag);
	  DBMS_SQL.Column_Value(b_cursor, 5,  b_line_detail_id);
	  DBMS_SQL.Column_Value(b_cursor, 6,  b_ship_model_complete);
	  DBMS_SQL.Column_Value(b_cursor, 7,  b_ship_set_number);
	  DBMS_SQL.Column_Value(b_cursor, 8,  b_parent_line_id);
	  DBMS_SQL.Column_Value(b_cursor, 9,  b_ld_warehouse_id);
	  DBMS_SQL.Column_Value(b_cursor, 10, b_ship_to_site_use_id);
	  DBMS_SQL.Column_Value(b_cursor, 11, b_ship_to_contact_id);
	  DBMS_SQL.Column_Value(b_cursor, 12, b_ship_method_code);
	  DBMS_SQL.Column_Value(b_cursor, 13, b_shipment_priority);
	  DBMS_SQL.Column_Value(b_cursor, 14, b_departure_id);
	  DBMS_SQL.Column_Value(b_cursor, 15, b_delivery_id);
	  DBMS_SQL.Column_Value(b_cursor, 16, b_item_type_code);
	  DBMS_SQL.Column_Value(b_cursor, 17, b_schedule_date);
	  DBMS_SQL.Column_Value(b_cursor, 18, b_ordered_quantity);
	  DBMS_SQL.Column_Value(b_cursor, 19, b_cancelled_quantity);
	  DBMS_SQL.Column_Value(b_cursor, 20, b_l_inventory_item_id);
	  DBMS_SQL.Column_Value(b_cursor, 21, b_ld_inventory_item_id);
	  DBMS_SQL.Column_Value(b_cursor, 22, b_customer_item_id);
	  DBMS_SQL.Column_Value(b_cursor, 23, b_dep_plan_required_flag);
	  DBMS_SQL.Column_Value(b_cursor, 24, b_shipment_schedule_line_id);
	  DBMS_SQL.Column_Value(b_cursor, 25, b_unit_code);
	  DBMS_SQL.Column_Value(b_cursor, 26, b_line_type_code);
	  DBMS_SQL.Column_Value(b_cursor, 27, b_component_code);
	  DBMS_SQL.Column_Value(b_cursor, 28, b_standard_comp_freeze_date);
	  DBMS_SQL.Column_Value(b_cursor, 29, b_order_number);
	  DBMS_SQL.Column_Value(b_cursor, 30, b_order_type_id);
	  DBMS_SQL.Column_Value(b_cursor, 31, b_customer_id);
	  DBMS_SQL.Column_Value(b_cursor, 32, b_invoice_to_site_use_id);
	  DBMS_SQL.Column_Value(b_cursor, 33, b_planned_departure_date_d);
	  DBMS_SQL.Column_Value(b_cursor, 34, b_planned_departure_date_t);
	  DBMS_SQL.Column_Value(b_cursor, 35, b_master_container_id);
	  DBMS_SQL.Column_Value(b_cursor, 36, b_detail_container_id);
	  DBMS_SQL.Column_Value(b_cursor, 37, b_load_seq_number);
	  DBMS_SQL.Column_Value(b_cursor, 38, b_invoice_value);
	ELSIF p_source = 's' THEN
	  DBMS_SQL.Column_Value(s_cursor, 1,  s_line_id);
	  DBMS_SQL.Column_Value(s_cursor, 2,  s_header_id);
	  DBMS_SQL.Column_Value(s_cursor, 3,  s_org_id);
	  DBMS_SQL.Column_Value(s_cursor, 4,  s_ato_flag);
	  DBMS_SQL.Column_Value(s_cursor, 5,  s_line_detail_id);
	  DBMS_SQL.Column_Value(s_cursor, 6,  s_ship_model_complete);
	  DBMS_SQL.Column_Value(s_cursor, 7,  s_ship_set_number);
	  DBMS_SQL.Column_Value(s_cursor, 8,  s_parent_line_id);
	  DBMS_SQL.Column_Value(s_cursor, 9,  s_ld_warehouse_id);
	  DBMS_SQL.Column_Value(s_cursor, 10, s_ship_to_site_use_id);
	  DBMS_SQL.Column_Value(s_cursor, 11, s_ship_to_contact_id);
	  DBMS_SQL.Column_Value(s_cursor, 12, s_ship_method_code);
	  DBMS_SQL.Column_Value(s_cursor, 13, s_shipment_priority);
	  DBMS_SQL.Column_Value(s_cursor, 14, s_departure_id);
	  DBMS_SQL.Column_Value(s_cursor, 15, s_delivery_id);
	  DBMS_SQL.Column_Value(s_cursor, 16, s_schedule_date);
	  DBMS_SQL.Column_Value(s_cursor, 17, s_customer_item_id);
	  DBMS_SQL.Column_Value(s_cursor, 18, s_dep_plan_required_flag);
	  DBMS_SQL.Column_Value(s_cursor, 19, s_order_number);
	  DBMS_SQL.Column_Value(s_cursor, 20, s_order_type_id);
	  DBMS_SQL.Column_Value(s_cursor, 21, s_customer_id);
	  DBMS_SQL.Column_Value(s_cursor, 22, s_invoice_to_site_use_id);
	  DBMS_SQL.Column_Value(s_cursor, 23, s_master_container_id);
	  DBMS_SQL.Column_Value(s_cursor, 24, s_detail_container_id);
	  DBMS_SQL.Column_Value(s_cursor, 25, s_load_seq_number);
	ELSIF p_source = 'n' THEN
	  DBMS_SQL.Column_Value(ns_cursor, 1,  n_line_id);
	  DBMS_SQL.Column_Value(ns_cursor, 2,  n_header_id);
	  DBMS_SQL.Column_Value(ns_cursor, 3,  n_line_detail_id);
	  DBMS_SQL.Column_Value(ns_cursor, 4,  n_org_id);
	END IF;

	RETURN;

  END Map_Col_Value;


  --
  -- Name
  --   PROCEDURE Insert_RL_Row
  --
  -- Purpose
  --   This function inserts a row from the source variables
  --   specified by p_source into release_table table. It also
  --   determines whether there is a switch in the most
  --   significant criteria of the release sequence rule.
  --
  -- Arguments
  --   p_source - indicates whether to insert a row for
  --              backordered lines ('b') or unreleased
  --              lines ('u')
  --
  -- Notes
  --

  PROCEDURE Insert_RL_Row(
		   p_source		IN	VARCHAR2
  ) IS

	cs		BINARY_INTEGER;

  BEGIN
	WSH_UTIL.Write_Log('--------------------');
	IF p_source = 's' THEN
	  WSH_UTIL.Write_Log('Current line is ' || to_char(current_sync_line));
	ELSE
	  WSH_UTIL.Write_Log('Current line is ' || to_char(current_line));
	END IF;
	IF p_source = 'u' THEN
	  release_table(current_line).line_id := u_line_id;
	  release_table(current_line).header_id := u_header_id;
	  release_table(current_line).org_id := u_org_id;
	  release_table(current_line).ato_flag := u_ato_flag;
	  release_table(current_line).line_detail_id := u_line_detail_id;
	  release_table(current_line).ship_model_complete := u_ship_model_complete;
	  release_table(current_line).ship_set_number := u_ship_set_number;
	  release_table(current_line).parent_line_id := u_parent_line_id;
	  release_table(current_line).ld_warehouse_id := u_ld_warehouse_id;
	  release_table(current_line).ship_to_site_use_id := u_ship_to_site_use_id;
	  release_table(current_line).ship_to_contact_id := u_ship_to_contact_id;
	  release_table(current_line).ship_method_code := u_ship_method_code;
	  release_table(current_line).shipment_priority := u_shipment_priority;
	  release_table(current_line).departure_id := u_departure_id;
	  release_table(current_line).delivery_id := u_delivery_id;
	  release_table(current_line).item_type_code := u_item_type_code;
	  release_table(current_line).schedule_date := u_schedule_date;
	  release_table(current_line).ordered_quantity := u_ordered_quantity;
	  release_table(current_line).cancelled_quantity := u_cancelled_quantity;
	  release_table(current_line).l_inventory_item_id := u_l_inventory_item_id;
	  release_table(current_line).ld_inventory_item_id := u_ld_inventory_item_id;
	  release_table(current_line).customer_item_id := u_customer_item_id;
	  release_table(current_line).dep_plan_required_flag := u_dep_plan_required_flag;
	  release_table(current_line).shipment_schedule_line_id := u_shipment_schedule_line_id;
	  release_table(current_line).unit_code := u_unit_code;
	  release_table(current_line).line_type_code := u_line_type_code;
	  release_table(current_line).component_code := u_component_code;
	  release_table(current_line).standard_comp_freeze_date := u_standard_comp_freeze_date;
	  release_table(current_line).order_number := u_order_number;
	  release_table(current_line).order_type_id := u_order_type_id;
	  release_table(current_line).customer_id := u_customer_id;
	  release_table(current_line).invoice_to_site_use_id := u_invoice_to_site_use_id;
	  release_table(current_line).planned_departure_date_d := u_planned_departure_date_d;
	  release_table(current_line).planned_departure_date_t := u_planned_departure_date_t;
	  release_table(current_line).master_container_item_id := u_master_container_id;
	  release_table(current_line).detail_container_item_id := u_detail_container_id;
	  release_table(current_line).load_seq_number := u_load_seq_number;
	  release_table(current_line).invoice_value := u_invoice_value;
	  release_table(current_line).backorder_line := 0;

	  WSH_UTIL.Write_Log('Row Description:');
	  WSH_UTIL.Write_Log('header_id = ' || to_char(u_header_id) || ' line_id = ' || to_char(u_line_id) ||
			     ' line_detail_id = ' || to_char(u_line_detail_id));
	ELSIF p_source = 'b' THEN
	  release_table(current_line).line_id := b_line_id;
	  release_table(current_line).header_id := b_header_id;
	  release_table(current_line).org_id := b_org_id;
	  release_table(current_line).ato_flag := b_ato_flag;
	  release_table(current_line).line_detail_id := b_line_detail_id;
	  release_table(current_line).ship_model_complete := b_ship_model_complete;
	  release_table(current_line).ship_set_number := b_ship_set_number;
	  release_table(current_line).parent_line_id := b_parent_line_id;
	  release_table(current_line).ld_warehouse_id := b_ld_warehouse_id;
	  release_table(current_line).ship_to_site_use_id := b_ship_to_site_use_id;
	  release_table(current_line).ship_to_contact_id := b_ship_to_contact_id;
	  release_table(current_line).ship_method_code := b_ship_method_code;
	  release_table(current_line).shipment_priority := b_shipment_priority;
	  release_table(current_line).departure_id := b_departure_id;
	  release_table(current_line).delivery_id := b_delivery_id;
	  release_table(current_line).item_type_code := b_item_type_code;
	  release_table(current_line).schedule_date := b_schedule_date;
	  release_table(current_line).ordered_quantity := b_ordered_quantity;
	  release_table(current_line).cancelled_quantity := b_cancelled_quantity;
	  release_table(current_line).l_inventory_item_id := b_l_inventory_item_id;
	  release_table(current_line).ld_inventory_item_id := b_ld_inventory_item_id;
	  release_table(current_line).customer_item_id := b_customer_item_id;
	  release_table(current_line).dep_plan_required_flag := b_dep_plan_required_flag;
	  release_table(current_line).shipment_schedule_line_id := b_shipment_schedule_line_id;
	  release_table(current_line).unit_code := b_unit_code;
	  release_table(current_line).line_type_code := b_line_type_code;
	  release_table(current_line).component_code := b_component_code;
	  release_table(current_line).standard_comp_freeze_date := b_standard_comp_freeze_date;
	  release_table(current_line).order_number := b_order_number;
	  release_table(current_line).order_type_id := b_order_type_id;
	  release_table(current_line).customer_id := b_customer_id;
	  release_table(current_line).invoice_to_site_use_id := b_invoice_to_site_use_id;
	  release_table(current_line).planned_departure_date_d := b_planned_departure_date_d;
	  release_table(current_line).planned_departure_date_t := b_planned_departure_date_t;
	  release_table(current_line).master_container_item_id := b_master_container_id;
	  release_table(current_line).detail_container_item_id := b_detail_container_id;
	  release_table(current_line).load_seq_number := b_load_seq_number;
	  release_table(current_line).invoice_value := b_invoice_value;
	  release_table(current_line).backorder_line := 1;

	  WSH_UTIL.Write_Log('Row Description');
	  WSH_UTIL.Write_Log('header_id = ' || to_char(b_header_id) || ' line_id = ' || to_char(b_line_id) ||
			     ' pick_line_detail_id = ' || to_char(b_line_detail_id));

	ELSIF p_source = 's' THEN
	  sync_table(current_sync_line).line_id := s_line_id;
	  sync_table(current_sync_line).header_id := s_header_id;
	  sync_table(current_sync_line).org_id := s_org_id;
	  sync_table(current_sync_line).ato_flag := s_ato_flag;
	  sync_table(current_sync_line).line_detail_id := s_line_detail_id;
	  sync_table(current_sync_line).ship_model_complete := s_ship_model_complete;
	  sync_table(current_sync_line).ship_set_number := s_ship_set_number;
	  sync_table(current_sync_line).parent_line_id := s_parent_line_id;
	  sync_table(current_sync_line).ld_warehouse_id := s_ld_warehouse_id;
	  sync_table(current_sync_line).ship_to_site_use_id := s_ship_to_site_use_id;
	  sync_table(current_sync_line).ship_to_contact_id := s_ship_to_contact_id;
	  sync_table(current_sync_line).ship_method_code := s_ship_method_code;
	  sync_table(current_sync_line).shipment_priority := s_shipment_priority;
	  sync_table(current_sync_line).departure_id := s_departure_id;
	  sync_table(current_sync_line).delivery_id := s_delivery_id;
	  sync_table(current_sync_line).schedule_date := s_schedule_date;
	  sync_table(current_sync_line).customer_item_id := s_customer_item_id;
	  sync_table(current_sync_line).dep_plan_required_flag := s_dep_plan_required_flag;
	  sync_table(current_sync_line).order_number := s_order_number;
	  sync_table(current_sync_line).order_type_id := s_order_type_id;
	  sync_table(current_sync_line).customer_id := s_customer_id;
	  sync_table(current_sync_line).invoice_to_site_use_id := s_invoice_to_site_use_id;
	  sync_table(current_sync_line).master_container_item_id := s_master_container_id;
	  sync_table(current_sync_line).detail_container_item_id := s_detail_container_id;
	  sync_table(current_sync_line).load_seq_number := s_load_seq_number;

	  WSH_UTIL.Write_Log('Sync Line Row Description:');
	  WSH_UTIL.Write_Log('header_id = ' || to_char(s_header_id) || ' line_id = ' || to_char(s_line_id) ||
			     ' line_detail_id = ' || to_char(s_line_detail_id));


	  current_sync_line := current_sync_line + 1;
	  RETURN;
	ELSIF p_source = 'n' THEN
	  release_table(current_line).line_id := n_line_id;
	  release_table(current_line).header_id := n_header_id;
	  release_table(current_line).line_detail_id := n_line_detail_id;
	  release_table(current_line).org_id := n_org_id;

	  WSH_UTIL.Write_Log('Non-Ship Line Row Description:');
	  WSH_UTIL.Write_Log('header_id = ' || to_char(n_header_id) || ' line_id = ' || to_char(n_line_id) ||
			     ' line_detail_id = ' || to_char(n_line_detail_id));

	  current_line := current_line + 1;
	  RETURN;

	END IF;

	IF current_line <> 1 THEN
	  IF (((primary_rsr = 'INVOICE_VALUE')
	        AND (release_table(current_line).invoice_value <> release_table(current_line - 1).invoice_value)) OR
 	     ((primary_rsr = 'ORDER_NUMBER')
	        AND (release_table(current_line).order_number <> release_table(current_line - 1).order_number)) OR
	     ((primary_rsr = 'SCHEDULE_DATE')
	        AND (release_table(current_line).schedule_date <> release_table(current_line - 1).schedule_date)) OR
	     ((primary_rsr = 'DEPARTURE')
	        AND ((release_table(current_line).planned_departure_date_d <>
		      release_table(current_line - 1).planned_departure_date_d) OR
		     (release_table(current_line).planned_departure_date_t <>
		      release_table(current_line - 1).planned_departure_date_t))) OR
	     ((primary_rsr = 'SHIPMENT_PRIORITY')
	        AND (release_table(current_line).shipment_priority <>
		     release_table(current_line - 1).shipment_priority))) THEN
	          WSH_UTIL.Write_Log('--RSR Switch--');
	          release_table(current_line - 1).primary_rsr_switch := 1;
	    ELSE
		  release_table(current_line - 1).primary_rsr_switch := 0;
	  END IF;
	END IF;

	current_line := current_line + 1;

  END Insert_RL_Row;


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
  ) RETURN BINARY_INTEGER IS

	cs			BINARY_INTEGER;

  BEGIN

    WSH_UTIL.Write_Log('Setting sync_line_id to ' || to_char(p_sync_line_id));
    wsh_pr_picking_session.sync_line_id := p_sync_line_id;

    -- Call to dynamically create SQL for Sync Lines
    WSH_UTIL.Write_Log('Calling WSH_PR_PICKING_SESSION.Sync_Details...');
    cs := WSH_PR_PICKING_SESSION.Sync_Details;
    IF cs = FAILURE THEN
      WSH_UTIL.Write_Log('Error in WSH_PR_PICKING_SESSION.Sync_Details');
      RETURN FAILURE;
    END IF;

    -- Fetch the Sync Lines SQL
    WSH_UTIL.Write_Log('Calling WSH_PR_PICKING_SESSION.Get_Session_Value for sync SQL');
    sync_SQL := WSH_PR_PICKING_SESSION.Get_Session_Value('SYNC_SQL');
    IF sync_SQL = '-1' THEN
      WSH_UTIL.Write_Log('Error in call to WSH_PR_PICKING_SESSION.Get_Session_Value');
      RETURN FAILURE;
    END IF;

    -- Call package to process buffer into cursor for parsing and executing
    cs := Open_Execute_Cursor('SYNC');
    IF cs = FAILURE THEN
      WSH_UTIL.Write_Log('Error in Open_Execute_Cursor');
      RETURN FAILURE;
    END IF;

    -- Initialize first_sync_line for each call to set_sync_line
    -- since we are processing a different line for sync-ing
    first_sync_line.header_id := -1;

    RETURN SUCCESS;

  END Set_Sync_Line;


  --
  -- Name
  --   Function Set_Request_lines
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
  ) RETURN BINARY_INTEGER IS
	cs	BINARY_INTEGER;
  BEGIN

	cs := WSH_PR_PICKING_SESSION.Construct_SQL('SET REQUEST');
	IF cs = FAILURE THEN
	  WSH_UTIL.Write_Log('Error in Construct SQL');
	  RETURN FAILURE;
	END IF;
	sreq_SQL := WSH_PR_PICKING_SESSION.Get_Session_Value('SET_REQUEST_SQL');
	sreq_cursor := DBMS_SQL.Open_Cursor;
	DBMS_SQL.Parse(sreq_cursor, sreq_SQL, DBMS_SQL.v7);

	WSH_UTIL.Write_Log('Binding Set Request ID cursor');

	WSH_UTIL.Write_Log('X_request_id = ' || to_char(wsh_pr_picking_session.request_id));
	DBMS_SQL.Bind_Variable(sreq_cursor, ':X_request_id',
			       wsh_pr_picking_session.request_id);
	WSH_UTIL.Write_Log('X_sync_line_id = ' || to_char(p_sync_line_id));
	DBMS_SQL.Bind_Variable(sreq_cursor, ':X_sync_line_id',
			       p_sync_line_id);
	WSH_UTIL.Write_Log('X_from_request_date = ' || to_char(wsh_pr_picking_session.from_request_date,'YYYY/MM/DD HH24:MI:SS'));
	DBMS_SQL.Bind_Variable(sreq_cursor, ':X_from_request_date',
			       to_char(wsh_pr_picking_session.from_request_date,'YYYY/MM/DD HH24:MI:SS'));
	WSH_UTIL.Write_Log('X_to_request_date = ' || to_char(wsh_pr_picking_session.to_request_date,'YYYY/MM/DD HH24:MI:SS'));
	DBMS_SQL.Bind_Variable(sreq_cursor, ':X_to_request_date',
			       to_char(wsh_pr_picking_session.to_request_date,'YYYY/MM/DD HH24:MI:SS'));
	WSH_UTIL.Write_Log('X_inventory_item_id = ' || to_char(wsh_pr_picking_session.inventory_item_id));
	DBMS_SQL.Bind_Variable(sreq_cursor, ':X_inventory_item_id',
			       wsh_pr_picking_session.inventory_item_id);
	WSH_UTIL.Write_Log('X_warehouse_id = ' || to_char(wsh_pr_picking_session.warehouse_id));
	DBMS_SQL.Bind_Variable(sreq_cursor, ':X_warehouse_id',
			       wsh_pr_picking_session.warehouse_id);
	WSH_UTIL.Write_Log('X_from_sched_ship_date = ' || to_char(wsh_pr_picking_session.from_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	DBMS_SQL.Bind_Variable(sreq_cursor, ':X_from_sched_ship_date',
			       to_char(wsh_pr_picking_session.from_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	WSH_UTIL.Write_Log('X_to_sched_ship_date = ' || to_char(wsh_pr_picking_session.to_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));
	DBMS_SQL.Bind_Variable(sreq_cursor, ':X_to_sched_ship_date',
			       to_char(wsh_pr_picking_session.to_sched_ship_date,'YYYY/MM/DD HH24:MI:SS'));

	v_ignore := DBMS_SQL.Execute(sreq_cursor);
	WSH_UTIL.Write_Log('Updated ' || to_char(v_ignore) || ' lines in model');
	DBMS_SQL.Close_Cursor(sreq_cursor);
	RETURN SUCCESS;

	EXCEPTION
	  WHEN OTHERS THEN
	    Close_Cursors;
	    WSH_UTIL.Default_Handler('WSH_PR_PICKING_ROWS.Open_Execute_Cursor');
	    RETURN FAILURE;

  END Set_Request_Lines;

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
  ) IS

	i			BINARY_INTEGER;
	cs			BINARY_INTEGER;

  BEGIN
	WSH_UTIL.Write_Log('Starting WSH_PICKING_ROWS.Get_Sync_Line_Details');

	-- handle uninitialized package errors here
	IF initialized = FALSE THEN
	   WSH_UTIL.Write_Log('The package must be initialized before use');
	   call_parameters(2) := FAILURE;
	   RETURN;
	END IF;

	-- Clear the table and initialize table index
	IF sync_table.count <> 0 THEN
	  call_parameters.delete;
	  sync_table.delete;
	  current_sync_line := 1;
	END IF;

	-- If called after the first time, place the last row fetched in previous
	-- call as the first row, since it was not returned in the previous call
	IF first_sync_line.header_id <> -1 THEN
	  sync_table(current_sync_line) := first_sync_line;
	  current_sync_line := current_sync_line + 1;
	END IF;

	LOOP
	  IF current_sync_line < MAX_LINES THEN
	    -- Inserts the next line detail into sync_table

	    IF DBMS_SQL.Fetch_Rows(s_cursor) > 0 THEN
	      Map_Col_Value('s');
	      Insert_RL_Row('s');
	      cs := SUCCESS;
      	    ELSE
	      DBMS_SQL.Close_Cursor(s_cursor);
              cs := DONE;
            END IF;

	    IF cs = DONE THEN
	      WSH_UTIL.Write_Log('Fetched all lines');
	      EXIT;
	    END IF;
	  ELSE
	    first_sync_line := sync_table(current_sync_line - 1);
	    sync_table.delete(current_sync_line - 1);
	    current_sync_line := current_sync_line - 1;
	    EXIT;
	  END IF;
	END LOOP;

	-- Setup return values
	FOR i IN 1..sync_table.count LOOP
	  line_id(i) := sync_table(i).line_id;
	  header_id(i) := sync_table(i).header_id;
	  org_id(i) := sync_table(i).org_id;
	  ato_flag(i) := sync_table(i).ato_flag;
	  line_detail_id(i) := sync_table(i).line_detail_id;
	  ship_model_complete(i) := sync_table(i).ship_model_complete;
	  ship_set_number(i) := sync_table(i).ship_set_number;
	  parent_line_id(i) := sync_table(i).parent_line_id;
	  ld_warehouse_id(i) := sync_table(i).ld_warehouse_id;
	  ship_to_site_use_id(i) := sync_table(i).ship_to_site_use_id;
	  ship_to_contact_id(i) := sync_table(i).ship_to_contact_id;
	  ship_method_code(i) := sync_table(i).ship_method_code;
	  shipment_priority(i) := sync_table(i).shipment_priority;
	  departure_id(i) := sync_table(i).departure_id;
	  delivery_id(i) := sync_table(i).delivery_id;
	  schedule_date(i) := sync_table(i).schedule_date;
	  customer_item_id(i) := sync_table(i).customer_item_id;
	  dep_plan_required_flag(i) := sync_table(i).dep_plan_required_flag;
	  order_number(i) := sync_table(i).order_number;
	  order_type_id(i) := sync_table(i).order_type_id;
	  customer_id(i) := sync_table(i).customer_id;
	  invoice_to_site_use_id(i) := sync_table(i).invoice_to_site_use_id;
	  master_container_item_id(i) := sync_table(i).master_container_item_id;
	  detail_container_item_id(i) := sync_table(i).detail_container_item_id;
	  load_seq_number(i) := sync_table(i).load_seq_number;
	END LOOP;
	call_parameters(1) := sync_table.count;

	IF cs = DONE THEN
	  call_parameters(2) := DONE;
	ELSE
	  call_parameters(2) := SUCCESS;
	END IF;

  EXCEPTION
    WHEN OTHERS THEN
      Close_Cursors;
      WSH_UTIL.Default_Handler('WSH_PR_PICKING_ROWS.Get_Sync_Line_Details');
      call_parameters(2) := FAILURE;

  END Get_Sync_Line_Details;


  --
  -- Name
  --   PROCEDURE Get_Non_Ship_Lines
  --
  -- Purpose
  --   This procedure fetches all the non-shippable lines that need to
  --   be passed through Pick Release.
  --
  -- Arguments
  --    All the column values needed for non ship lines and call_parameters
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
  ) IS

    i		BINARY_INTEGER;
    cs		BINARY_INTEGER;

  BEGIN
	WSH_UTIL.Write_Log('In Get_Non_Ship_lines');
	-- handle uninitialized package errors here
	IF initialized = FALSE THEN
	   WSH_UTIL.Write_Log('The package must be initialized before use');
	   call_parameters(2) := FAILURE;
	   RETURN;
	END IF;

	IF ns_lines_refetch_mode = FALSE THEN
	  -- Process non-shippable lines
	  WSH_UTIL.Write_Log('Calling Open_non_Shippable_SQL_Cursor...');
	  cs := Open_Non_Shippable_SQL_Cursor;
	  IF cs = FAILURE THEN
	    WSH_UTIL.Write_Log('Error in Open_Non_Shippable_SQL_Cursor');
	    call_parameters(2) := FAILURE;
	    RETURN;
	  END IF;
	END IF;

	-- Clear the table and initialize table index
	IF release_table.count <> 0 THEN
	  call_parameters.delete;
	  release_table.delete;
	  current_line := 1;
	END IF;

	-- If called after the first time, place the last row fetched in previous
	-- call as the first row, since it was not returned in the previous call
	IF first_line.header_id <> -1 THEN
	  release_table(current_line) := first_line;
	  current_line := current_line + 1;
	END IF;

	LOOP
	  IF current_line < MAX_LINES THEN
	    -- Fetch lines from the non-shippable cursor

	    IF DBMS_SQL.Fetch_Rows(ns_cursor) > 0 THEN
	      Map_Col_Value('n');
	      Insert_RL_Row('n');
	      cs := SUCCESS;
      	    ELSE
	      DBMS_SQL.Close_Cursor(ns_cursor);
              cs := DONE;
            END IF;

	    IF cs = FAILURE THEN
	      WSH_UTIL.Write_Log('Failed in Get_Non_Ship_Lines');
	      call_parameters(2) := FAILURE;
	      RETURN;
	    ELSIF cs = DONE THEN
	      WSH_UTIL.Write_Log('Fetched all lines');
	      EXIT;
	    END IF;
	  ELSE
	    first_line := release_table(current_line - 1);
	    release_table.delete(current_line - 1);
	    current_line := current_line - 1;
	    ns_lines_refetch_mode := TRUE;
	    EXIT;
	  END IF;
	END LOOP;

	-- Setup return values
	FOR i IN 1..release_table.count LOOP
	  line_id(i) := release_table(i).line_id;
	  header_id(i) := release_table(i).header_id;
	  line_detail_id(i) := release_table(i).line_detail_id;
	  org_id(i) := release_table(i).org_id;
	END LOOP;
	call_parameters(1) := release_table.count;
	IF cs = DONE THEN
	  call_parameters(2) := DONE;
	ELSE
	  call_parameters(2) := SUCCESS;
	END IF;

  EXCEPTION
    WHEN OTHERS THEN
      Close_Cursors;
      WSH_UTIL.Default_Handler('WSH_PR_PICKING_ROWS.Get_Non_Ship_Lines');
      call_parameters(2) := FAILURE;

  END Get_Non_Ship_Lines;


  --
  -- Name
  --   PROCEDURE Close_Cursors
  --
  -- Purpose
  --   This procedure closes all the cursors that may have been
  --   opened to process pick release eligible lines.
  --
  -- Arguments
  --
  -- Notes
  --

  PROCEDURE Close_Cursors IS

  BEGIN

      IF DBMS_SQL.Is_Open(u_cursor) THEN
	DBMS_SQL.Close_Cursor(u_cursor);
      END IF;
      IF DBMS_SQL.Is_Open(b_cursor) THEN
	DBMS_SQL.Close_Cursor(b_cursor);
      END IF;
      IF DBMS_SQL.Is_Open(s_cursor) THEN
	DBMS_SQL.Close_Cursor(s_cursor);
      END IF;
      IF DBMS_SQL.Is_Open(ns_cursor) THEN
	DBMS_SQL.Close_Cursor(ns_cursor);
      END IF;
      IF DBMS_SQL.Is_Open(sreq_cursor) THEN
	DBMS_SQL.Close_Cursor(sreq_cursor);
      END IF;

  END Close_Cursors;

END WSH_PR_PICKING_ROWS;

/
