--------------------------------------------------------
--  DDL for Package Body WSH_PR_PICKING_OBJECTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PR_PICKING_OBJECTS" AS
/* $Header: WSHPRPOB.pls 115.9 99/07/16 08:19:59 porting ship  $ */

--
-- Package
--   	WSH_PR_PICKING_OBJECTS
--
-- Purpose
--	This package does the following:
--	- Determines whether a new picking header or pick slip number
--        is to be created.
--	- Inserts a new picking header if necessary
--	- Inserts picking lines
--      - Inserts picking line details
--

  --
  -- PACKAGE CONSTANTS
  --

	SUCCESS			CONSTANT  BINARY_INTEGER := 0;
	FAILURE			CONSTANT  BINARY_INTEGER := -1;

	RESOFF			CONSTANT  BINARY_INTEGER := 1;
	NONTRANS		CONSTANT  BINARY_INTEGER := 2;
	RESERVABLE		CONSTANT  BINARY_INTEGER := 3;
	TRANSNONRES		CONSTANT  BINARY_INTEGER := 4;
	BACKORDER		CONSTANT  BINARY_INTEGER := 5;

	UNRELEASED_LINE		CONSTANT  BINARY_INTEGER := 1;
	BACKORDER_LINE		CONSTANT  BINARY_INTEGER := 2;

  --
  -- PACKAGE VARIABLES
  --

	initialized				BOOLEAN := FALSE;

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --

  --
  -- FORWARD DECLERATIONS
  --
  FUNCTION Insert_Picking_Line (
			p_picking_line_id		IN 	BINARY_INTEGER,
			p_component_code		IN	VARCHAR2,
			p_component_ratio		IN	BINARY_INTEGER,
			p_component_sequence_id		IN	BINARY_INTEGER,
			p_config_item_flag		IN	VARCHAR2,
			p_date_requested		IN	DATE,
			p_demand_class			IN	VARCHAR2,
			p_included_item_flag		IN	VARCHAR2,
			p_inventory_item_id		IN	BINARY_INTEGER,
			p_customer_item_id		IN	BINARY_INTEGER,
			p_original_line_detail_id	IN	BINARY_INTEGER,
			p_order_line_id			IN	BINARY_INTEGER,
			p_original_requested_quantity	IN	BINARY_INTEGER,
			p_pick_header_id		IN	BINARY_INTEGER,
			p_requested_quantity		IN	BINARY_INTEGER,
			p_schedule_date			IN	DATE,
			p_sequence_number		IN	BINARY_INTEGER,
			p_shipment_priority_code	IN	VARCHAR2,
			p_ship_method_code		IN	VARCHAR2,
			p_ship_to_contact_id		IN	BINARY_INTEGER,
			p_ship_to_site_use_id		IN	BINARY_INTEGER,
			p_unit_code			IN	VARCHAR2,
			p_warehouse_id			IN	BINARY_INTEGER,
			p_org_id			IN	BINARY_INTEGER
  )  RETURN BINARY_INTEGER;

  FUNCTION Insert_Picking_Line_Details (
			p_mode				IN	BINARY_INTEGER,
			p_ps_number			IN	BINARY_INTEGER,
			p_departure_id			IN	BINARY_INTEGER,
			p_delivery_id			IN OUT	BINARY_INTEGER,
			p_dep_plan_required_flag	IN	VARCHAR2,
			p_autoscheduled_flag		IN	VARCHAR2,
			p_customer_requested_lot_flag	IN	VARCHAR2,
			p_ccid				IN	BINARY_INTEGER,
			p_order_line_id			IN	BINARY_INTEGER,
			p_master_container_item_id	IN	BINARY_INTEGER,
			p_detail_container_item_id	IN	BINARY_INTEGER,
			p_inventory_item_id		IN	BINARY_INTEGER,
			p_load_seq_number		IN	BINARY_INTEGER,
			p_autodetail_group_id		IN	BINARY_INTEGER,
			p_delivery			IN	BINARY_INTEGER,
			p_demand_class			IN	VARCHAR2,
			p_picking_line_id		IN 	BINARY_INTEGER,
			p_requested_quantity		IN	BINARY_INTEGER,
			p_reservable_flag		IN	VARCHAR2,
			p_schedule_date			IN	DATE,
			p_schedule_level		IN	VARCHAR2,
			p_schedule_status_code		IN	VARCHAR2,
			p_subinventory			IN	VARCHAR2,
			p_transactable_flag		IN	VARCHAR2,
			p_released_flag			IN	VARCHAR2,
			p_warehouse_id			IN	BINARY_INTEGER
  ) RETURN BINARY_INTEGER;

  FUNCTION Insert_Order_Line_Detail (
			p_original_line_detail_id	IN	BINARY_INTEGER,
			p_new_line_detail_id		IN OUT	BINARY_INTEGER,
			p_quantity			IN	BINARY_INTEGER,
			p_new_delivery			IN      BINARY_INTEGER
  ) RETURN BINARY_INTEGER;

  FUNCTION Process_Key (
		p_mode				IN 	VARCHAR2,
		p_header_id			IN	BINARY_INTEGER,
		p_customer_id			IN 	BINARY_INTEGER,
		p_ship_method_code			IN 	VARCHAR2,
		p_ship_to_site_use_id		IN 	BINARY_INTEGER,
		p_shipment_priority		IN 	VARCHAR2,
		p_subinventory			IN 	VARCHAR2,
		p_departure_id			IN 	BINARY_INTEGER,
		p_delivery_id			IN OUT	BINARY_INTEGER,
		p_warehouse_id			IN 	BINARY_INTEGER,
		new_flag			IN OUT  VARCHAR2
  )  RETURN BINARY_INTEGER;

  --
  -- Name
  --   FUNCTION Init
  --
  -- Purpose
  --   This function initializes the who variables, g_reservations variable,
  --   and the g_use_ variables to be used in determining the how to group
  --   pick slips.
  --
  -- Return Values
  --   -1 => Failure
  --    0 => Success
  --

  FUNCTION Init
  RETURN BINARY_INTEGER IS
	CURSOR ps_rule (x_psr_id IN BINARY_INTEGER) IS
	SELECT NVL(ORDER_NUMBER_FLAG, 'N'),
	       NVL(SUBINVENTORY_FLAG, 'N'),
	       NVL(CUSTOMER_FLAG, 'N'),
	       NVL(SHIP_TO_FLAG, 'N'),
	       NVL(CARRIER_FLAG, 'N'),
	       NVL(SHIPMENT_PRIORITY_FLAG, 'N'),
	       NVL(DEPARTURE_FLAG, 'N'),
	       NVL(DELIVERY_FLAG, 'N')
	FROM   WSH_PICK_SLIP_RULES
	WHERE  PICK_SLIP_RULE_ID = x_psr_id;

	CURSOR get_autocreate_del_orders(x_warehouse_id IN BINARY_INTEGER) IS
        SELECT NVL(AUTOCREATE_DEL_ORDERS_FLAG, 'Y')
        FROM   WSH_PARAMETERS
        WHERE  organization_id = x_warehouse_id;

  BEGIN
	WSH_UTIL.Write_Log('Starting WSH_PR_PICKING_OBJECTS.Init');
	IF initialized = TRUE THEN
	  RETURN SUCCESS;
	END IF;

	-- Initialize who parameters
	g_login_id := WSH_PR_PICKING_SESSION.login_id;
	g_user_id := WSH_PR_PICKING_SESSION.user_id;
	g_program_id := WSH_PR_PICKING_SESSION.program_id;
	g_request_id := WSH_PR_PICKING_SESSION.request_id;
	g_application_id := WSH_PR_PICKING_SESSION.application_id;
	g_batch_id := WSH_PR_PICKING_SESSION.batch_id;
	g_pick_slip_rule_id := WSH_PR_PICKING_SESSION.pick_slip_rule_id;
	g_reservations := WSH_PR_PICKING_SESSION.reservations;
	g_warehouse_id := WSH_PR_PICKING_SESSION.warehouse_id;
	g_autocreate_deliveries := WSH_PR_PICKING_SESSION.autocreate_deliveries;

	-- Clear tables to track unique picking headers and pick slip numbers
	g_ps_table.delete;
	g_ph_table.delete;

	-- fetch information on pick slip grouping rule
	OPEN	ps_rule(g_pick_slip_rule_id);
	FETCH	ps_rule
	INTO	g_use_order_ps,
		g_use_sub_ps,
		g_use_customer_ps,
		g_use_ship_to_ps,
		g_use_carrier_ps,
		g_use_ship_priority_ps,
		g_use_departure_ps,
		g_use_delivery_ps;

	IF ps_rule%NOTFOUND THEN
	  WSH_UTIL.Write_Log('Warning: Pick slip rule '
                               || to_char(g_pick_slip_rule_id) ||
			     ' does not exist');
	  RETURN FAILURE;
	END IF;

        -- fetch autocreate deliveries order rule
        OPEN    get_autocreate_del_orders(g_warehouse_id);
        FETCH   get_autocreate_del_orders
        INTO    g_use_autocreate_del_orders;

        IF get_autocreate_del_orders%NOTFOUND THEN
          WSH_UTIL.Write_Log('Warning: No autocreate rule will use Y');
          g_use_autocreate_del_orders := 'Y';
        END IF;

        CLOSE ps_rule;
        CLOSE get_autocreate_del_orders;

	initialized := TRUE;

	RETURN SUCCESS;

	EXCEPTION
	  WHEN OTHERS THEN
	    WSH_UTIL.DEFAULT_HANDLER('WSH_PR_PICKING_OBJECTS.Init', 'Error in Init');
	  IF ps_rule%ISOPEN THEN
              CLOSE ps_rule;
            END IF;
            IF get_autocreate_del_orders%ISOPEN THEN
              CLOSE get_autocreate_del_orders;
            END IF;
	    RETURN FAILURE;

  END Init;


  --
  -- Name
  --   FUNCTION Insert_Lines
  --
  -- Purpose
  --   This function inserts picking headers, picking lines,
  --   picking line details and order lines if applicable.
  --
  -- Return Values
  --    -1 => Failure
  --     0 => Success
  --

  FUNCTION Insert_lines(
		p_backorder_line		IN	BINARY_INTEGER,
		p_order_header_id		IN	BINARY_INTEGER,
		p_org_id			IN	BINARY_INTEGER,
		p_customer_id			IN	BINARY_INTEGER,
		p_ship_to_site_use_id		IN	BINARY_INTEGER,
		p_component_code		IN	VARCHAR2,
		p_component_ratio		IN	BINARY_INTEGER,
		p_component_sequence_id		IN	BINARY_INTEGER,
		p_date_requested		IN	DATE,
		p_included_item_flag		IN	VARCHAR2,
		p_inventory_item_id		IN	BINARY_INTEGER,
		p_original_line_detail_id	IN	BINARY_INTEGER,
		p_order_line_id			IN	BINARY_INTEGER,
		p_original_requested_quantity	IN	BINARY_INTEGER,
		p_requested_quantity		IN	BINARY_INTEGER,
		p_schedule_date			IN	DATE,
		p_sequence_number		IN	BINARY_INTEGER,
		p_shipment_priority_code	IN	VARCHAR2,
		p_ship_method_code		IN	VARCHAR2,
		p_ship_to_contact_id		IN	BINARY_INTEGER,
		p_unit_code			IN	VARCHAR2,
		p_warehouse_id			IN	BINARY_INTEGER,
		p_delivery			IN	BINARY_INTEGER,
		p_demand_class			IN	VARCHAR2,
		p_reservable_flag		IN	VARCHAR2,
		p_schedule_level		IN	BINARY_INTEGER,
		p_schedule_status_code		IN	VARCHAR2,
		p_subinventory			IN	VARCHAR2,
		p_autodetailed_quantity		IN	BINARY_INTEGER,
		p_transactable_flag		IN	VARCHAR2,
		p_config_item_flag		IN	VARCHAR2,
		p_customer_requested_lot_flag	IN	VARCHAR2,
		p_departure_id			IN	BINARY_INTEGER,
		p_delivery_id			IN OUT	BINARY_INTEGER,
		p_dep_plan_required_flag	IN	VARCHAR2,
		p_customer_item_id		IN	BINARY_INTEGER,
		p_master_container_item_id	IN	BINARY_INTEGER,
		p_detail_container_item_id	IN	BINARY_INTEGER,
		p_load_seq_number		IN	BINARY_INTEGER,
		p_ccid				IN	BINARY_INTEGER,
		p_autodetail_group_id		IN	BINARY_INTEGER,
		p_autobackorder			IN	VARCHAR2,
		p_picking_line_id		IN OUT	BINARY_INTEGER,
		p_abo_picking_line_id		IN OUT	BINARY_INTEGER,
		p_picking_header_id		IN OUT	BINARY_INTEGER,
		p_new_line_detail_id		IN OUT	BINARY_INTEGER,
		p_new_delivery			IN OUT	BINARY_INTEGER,
		p_abo_recs			IN OUT	BINARY_INTEGER,
		p_pld_recs			IN OUT	BINARY_INTEGER,
		p_old_recs			IN OUT	BINARY_INTEGER
  )
  RETURN BINARY_INTEGER IS

  CURSOR res_sub (x_ccid		IN BINARY_INTEGER,
		  x_order_line_id	IN BINARY_INTEGER,
		  x_delivery		IN BINARY_INTEGER,
		  x_autodetail_group_id IN BINARY_INTEGER) IS
  SELECT DISTINCT SUBINVENTORY
  FROM   MTL_DEMAND
  WHERE  DEMAND_SOURCE_HEADER_ID = x_ccid
  AND    DEMAND_SOURCE_TYPE IN (2,8)
  AND    DEMAND_SOURCE_LINE = to_char(x_order_line_id)
  AND    DEMAND_SOURCE_DELIVERY = to_char(x_delivery)
  AND    AUTODETAIL_GROUP_ID = x_autodetail_group_id
  AND    NVL(LINE_ITEM_QUANTITY,0) <> 0
  AND    PARENT_DEMAND_ID IS NOT NULL
  AND    RESERVATION_TYPE = 2;

  CURSOR nores_sub (x_ccid		IN BINARY_INTEGER,
		    x_order_line_id	IN BINARY_INTEGER,
		    x_delivery		IN BINARY_INTEGER) IS
  SELECT DISTINCT SUBINVENTORY
  FROM   MTL_DEMAND
  WHERE  DEMAND_SOURCE_HEADER_ID = x_ccid
  AND    DEMAND_SOURCE_TYPE IN (2,8)
  AND    DEMAND_SOURCE_LINE = to_char(x_order_line_id)
  AND    DEMAND_SOURCE_DELIVERY = to_char(x_delivery)
  AND    AUTODETAIL_GROUP_ID IS NULL
  AND    NVL(LINE_ITEM_QUANTITY,0) <> 0
  AND    PARENT_DEMAND_ID IS NOT NULL;

  new_flag		VARCHAR2(1) := 'Y';
  ph_id			BINARY_INTEGER;
  x_pl_id			BINARY_INTEGER;
  ps_number		BINARY_INTEGER;
  current_sub		VARCHAR2(30);
  rc			BINARY_INTEGER;
  x_delivery_id 	BINARY_INTEGER := NULL;

  BEGIN
	WSH_UTIL.Write_Log('In Insert_Lines...');

	-- Initialize out variables
	p_picking_line_id := 0;
	p_abo_picking_line_id := 0;
	p_picking_header_id := 0;
	p_new_delivery := 0;
	p_abo_recs := 0;
	p_pld_recs := 0;
	p_old_recs := 0;

	IF p_backorder_line = UNRELEASED_LINE THEN
	  WSH_UTIL.Write_Log('Processing unreleased line');
	ELSIF p_backorder_line = BACKORDER_LINE THEN
	  WSH_UTIL.Write_Log('Processing backordered line');
	END IF;

	-- Determine if a new picking_header_id needs to be created
	ph_id := Process_Key(
			'PICKING_HEADER_ID',
			p_order_header_id,
			p_customer_id,
			p_ship_method_code,
			p_ship_to_site_use_id,
			p_shipment_priority_code,
			p_subinventory,
			p_departure_id,
			p_delivery_id,
			p_warehouse_id,
			new_flag);

	IF ph_id = FAILURE THEN
	  WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Process_Key');
	  RETURN FAILURE;
	END IF;

	-- Create new picking header if necessary
	IF new_flag = 'Y' THEN
	  WSH_UTIL.Write_Log('Inserting picking header ' || to_char(ph_id));
	  INSERT INTO SO_PICKING_HEADERS_ALL (
		PICKING_HEADER_ID,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		PROGRAM_APPLICATION_ID,
         	PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		REQUEST_ID,
		BATCH_ID,
         	ORDER_HEADER_ID,
		WAREHOUSE_ID,
		SHIP_TO_SITE_USE_ID,
		STATUS_CODE,
		PICK_SLIP_NUMBER,
		SHIP_METHOD_CODE,
		DATE_RELEASED,
		ORG_ID)
          VALUES (
		ph_id,
		sysdate,
		g_user_id,
		sysdate,
		g_user_id,
		g_login_id,
		g_application_id,
		g_program_id,
		sysdate,
		g_request_id,
		g_batch_id,
		p_order_header_id,
		p_warehouse_id,
		p_ship_to_site_use_id,
		'OPEN',
		-1,
		p_ship_method_code,
		sysdate,
		decode(p_org_id, -3114, NULL, p_org_id));
	END IF;

	p_picking_header_id := ph_id;

	-- If autocreate deliveries is on, d	etermine delivery to use
	IF ((g_autocreate_deliveries = 'Y') AND
	    (p_departure_id = -1) AND
	    (p_delivery_id = -1)) THEN
	   p_delivery_id := WSH_PR_CREATE_DELIVERIES.Get_Delivery(
				p_order_header_id,
				p_ship_to_site_use_id,
				p_ship_method_code,
				p_warehouse_id);
	   IF p_delivery_id = -1 THEN
	     WSH_UTIL.Write_Log('Invalid delivery id, ignoring...');
	   END IF;
	END IF;

	-- If reservations are off
	IF g_reservations = 'N' THEN
	  WSH_UTIL.Write_Log('Reservations are off');
	  -- Determine the pick slip number
	  ps_number := Process_Key (
		'PICK_SLIP_NUMBER',
		p_order_header_id,
		p_customer_id,
		p_ship_method_code,
		p_ship_to_site_use_id,
		p_shipment_priority_code,
		p_subinventory,
		p_departure_id,
		p_delivery_id,
		p_warehouse_id,
		new_flag);

	  WSH_UTIL.Write_Log('Pick Slip Number is ' || to_char(ps_number));

	  IF ps_number = FAILURE THEN
	    WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Process_Key');
	    RETURN FAILURE;
	  END IF;

	  SELECT SO_PICKING_LINES_S.NEXTVAL
	  INTO x_pl_id
	  FROM DUAL;

	  rc := Insert_Picking_Line (
		x_pl_id,
		p_component_code,
		p_component_ratio,
		p_component_sequence_id,
		NULL,
		p_date_requested,
		p_demand_class,
		p_included_item_flag,
		p_inventory_item_id,
		p_customer_item_id,
		p_original_line_detail_id,
		p_order_line_id,
		p_original_requested_quantity,
		ph_id,
		p_original_requested_quantity,
		p_schedule_date,
		p_sequence_number,
		p_shipment_priority_code,
		p_ship_method_code,
		p_ship_to_contact_id,
		p_ship_to_site_use_id,
		p_unit_code,
		p_warehouse_id,
		p_org_id);

	  IF rc = FAILURE THEN
	    WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Insert_Lines');
	    RETURN FAILURE;
	  END IF;

	  p_picking_line_id := x_pl_id;

	  IF p_transactable_flag = 'Y' THEN
	    OPEN  nores_sub(p_ccid, p_order_line_id, p_delivery);
	    FETCH nores_sub INTO  current_sub;
	    IF nores_sub%NOTFOUND THEN
	      WSH_UTIL.Write_Log('Could not fine a subinventory in nores_sub');
	      current_sub := NULL;
	    ELSE
	      WSH_UTIL.Write_Log('Using Subinventory ' || current_sub ||
				 ' for Transactable, Non-reservable');
	    END IF;
	    CLOSE nores_sub;

	    -- Determine the pick slip number
	    ps_number := Process_Key (
			'PICK_SLIP_NUMBER',
			p_order_header_id,
			p_customer_id,
			p_ship_method_code,
			p_ship_to_site_use_id,
			p_shipment_priority_code,
			current_sub,
			p_departure_id,
			p_delivery_id,
			p_warehouse_id,
			new_flag);

	    WSH_UTIL.Write_Log('Pick Slip Number is ' || to_char(ps_number));

	    IF ps_number = FAILURE THEN
	      WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Process_Key');
	      RETURN FAILURE;
	    END IF;

	    rc := Insert_Picking_Line_Details (
			TRANSNONRES,
			ps_number,
			p_departure_id,
			p_delivery_id,
			p_dep_plan_required_flag,
			'Y',
			NULL,
			p_ccid,
			p_order_line_id,
			p_master_container_item_id,
			p_detail_container_item_id,
			p_inventory_item_id,
			p_load_seq_number,
			p_autodetail_group_id,
			p_delivery,
			p_demand_class,
			x_pl_id,
			p_original_requested_quantity,
			p_reservable_flag,
			p_schedule_date,
			p_schedule_level,
			'DEMANDED',
			current_sub,
			p_transactable_flag,
			NULL,
			p_warehouse_id);
	  ELSE
	    rc := Insert_Picking_Line_Details (
			RESOFF,
			ps_number,
			p_departure_id,
			p_delivery_id,
			p_dep_plan_required_flag,
			NULL,
			p_customer_requested_lot_flag,
			p_ccid,
			p_order_line_id,
			p_master_container_item_id,
			p_detail_container_item_id,
			p_inventory_item_id,
			p_load_seq_number,
			p_autodetail_group_id,
			p_delivery,
			p_demand_class,
			x_pl_id,
			p_original_requested_quantity,
			p_reservable_flag,
			p_schedule_date,
			p_schedule_level,
			p_schedule_status_code,
			current_sub,
			p_transactable_flag,
			NULL,
			p_warehouse_id);

	  END IF;

	  IF rc = FAILURE THEN
	    WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Insert_Lines');
	    RETURN FAILURE;
	  END IF;

	p_pld_recs := p_pld_recs + rc;

	ELSIF g_reservations = 'Y' THEN	/* Reservations on */

	  WSH_UTIL.Write_Log('Reservations are on');

	  -- Process transactable and reservable lines
	  IF ((p_transactable_flag = 'Y') AND (p_reservable_flag = 'Y'))THEN
	    WSH_UTIL.Write_Log('Transactable and Reservable');

	    IF p_autodetailed_quantity > 0 THEN
	      -- Insert picking line
	      SELECT SO_PICKING_LINES_S.NEXTVAL
	      INTO x_pl_id
	      FROM DUAL;

	      rc := Insert_Picking_Line (
			x_pl_id,
			p_component_code,
			p_component_ratio,
			p_component_sequence_id,
			p_config_item_flag,
			p_date_requested,
			p_demand_class,
			p_included_item_flag,
			p_inventory_item_id,
			p_customer_item_id,
			p_original_line_detail_id,
			p_order_line_id,
			p_original_requested_quantity,
			ph_id,
			p_requested_quantity,
			p_schedule_date,
			p_sequence_number,
			p_shipment_priority_code,
			p_ship_method_code,
			p_ship_to_contact_id,
			p_ship_to_site_use_id,
			p_unit_code,
			p_warehouse_id,
			p_org_id);

	      IF rc = FAILURE THEN
	        WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Insert_Lines');
	        RETURN FAILURE;
	      END IF;

	      p_picking_line_id := x_pl_id;

	      -------------------------------------------------------------------------
	      -- Since pick slip numbers might depend on subinventories, the picking
	      -- line details to be inserted when using subinventory as part of the
	      -- pick slip grouping rule is slightly different.
	      -------------------------------------------------------------------------
	      IF g_use_sub_ps = 'Y' THEN
		OPEN  res_sub(p_ccid, p_order_line_id, p_delivery, p_autodetail_group_id);
		LOOP
		  FETCH res_sub INTO  current_sub;
		  EXIT WHEN res_sub%NOTFOUND;
		  -- Determine the pick slip number
		  ps_number := Process_Key (
			'PICK_SLIP_NUMBER',
			p_order_header_id,
			p_customer_id,
			p_ship_method_code,
			p_ship_to_site_use_id,
			p_shipment_priority_code,
			current_sub,
			p_departure_id,
			p_delivery_id,
			p_warehouse_id,
			new_flag);

		  WSH_UTIL.Write_Log('Pick Slip Number is ' || to_char(ps_number));

		  IF ps_number = FAILURE THEN
		    WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Process_Key');
		    RETURN FAILURE;
		  END IF;

		  rc := Insert_Picking_Line_Details (
				RESERVABLE,
				ps_number,
				p_departure_id,
				p_delivery_id,
				p_dep_plan_required_flag,
				'Y',
				p_customer_requested_lot_flag,
				p_ccid,
				p_order_line_id,
				p_master_container_item_id,
				p_detail_container_item_id,
				p_inventory_item_id,
				p_load_seq_number,
				p_autodetail_group_id,
				p_delivery,
				p_demand_class,
				x_pl_id,
				p_original_requested_quantity,
				p_reservable_flag,
				p_schedule_date,
				p_schedule_level,
				p_schedule_status_code,
				current_sub,
				p_transactable_flag,
				NULL,
				p_warehouse_id);

		  IF rc = FAILURE THEN
		    WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Insert_Lines');
		    RETURN FAILURE;
		  END IF;

		p_pld_recs := p_pld_recs + rc;

		END LOOP;
		CLOSE res_sub;

	      ELSE	/* IF NOT g_use_sub_ps */
		-- Determine the pick slip number
		ps_number := Process_Key (
			'PICK_SLIP_NUMBER',
			p_order_header_id,
			p_customer_id,
			p_ship_method_code,
			p_ship_to_site_use_id,
			p_shipment_priority_code,
			p_subinventory,
			p_departure_id,
			p_delivery_id,
			p_warehouse_id,
			new_flag);

		WSH_UTIL.Write_Log('Pick Slip Number is ' || to_char(ps_number));

		IF ps_number = FAILURE THEN
		  WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Process_Key');
		  RETURN FAILURE;
		END IF;

		rc := Insert_Picking_Line_Details (
				RESERVABLE,
				ps_number,
				p_departure_id,
				p_delivery_id,
				p_dep_plan_required_flag,
				'Y',
				p_customer_requested_lot_flag,
				p_ccid,
				p_order_line_id,
				p_master_container_item_id,
				p_detail_container_item_id,
				p_inventory_item_id,
				p_load_seq_number,
				p_autodetail_group_id,
				p_delivery,
				p_demand_class,
				x_pl_id,
				p_original_requested_quantity,
				p_reservable_flag,
				p_schedule_date,
				p_schedule_level,
				p_schedule_status_code,
				p_subinventory,
				p_transactable_flag,
				NULL,
				p_warehouse_id);

		IF rc = FAILURE THEN
		  WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Insert_Lines');
		  RETURN FAILURE;
		END IF;

		p_pld_recs := p_pld_recs + rc;

	      END IF; /* g_use_sub_ps */

	    END IF; /* p_autodetailed_quantity >0 */

	    ---------------------------------------------------------------------
	    -- If partial reservation was made, must split the order line detail
	    -- or create a new backorder picking line
	    ------------------------------------------------------------------
	    IF ((p_autodetailed_quantity <> p_original_requested_quantity) AND
	       (p_autodetailed_quantity > 0)) THEN

	      WSH_UTIL.Write_Log('Incomplete Reservations made');

	      IF p_backorder_line = BACKORDER_LINE THEN
		-- Create a picking line for the remaining quantity with
		-- picking header id = 0
		SELECT SO_PICKING_LINES_S.NEXTVAL
		INTO x_pl_id
		FROM DUAL;

		rc := Insert_Picking_Line (
			x_pl_id,
			p_component_code,
			p_component_ratio,
			p_component_sequence_id,
			p_config_item_flag,
			p_date_requested,
			p_demand_class,
			p_included_item_flag,
			p_inventory_item_id,
			p_customer_item_id,
			p_original_line_detail_id,
			p_order_line_id,
			p_original_requested_quantity,
			0,
			p_original_requested_quantity -
			p_autodetailed_quantity,
			p_schedule_date,
			p_sequence_number,
			p_shipment_priority_code,
			p_ship_method_code,
			p_ship_to_contact_id,
			p_ship_to_site_use_id,
			p_unit_code,
			p_warehouse_id,
			p_org_id);

		IF rc = FAILURE THEN
		  WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Insert_Lines');
		  RETURN FAILURE;
		END IF;

		p_abo_picking_line_id := x_pl_id;
		WSH_UTIL.Write_Log('Backorder picking_line_id = ' ||
			to_char(p_abo_picking_line_id));

		IF p_autodetailed_quantity = 0 THEN
		  p_new_delivery := 0;
		ELSE
		  SELECT SO_DELIVERIES_S.NEXTVAL
		  INTO   p_new_delivery
		  FROM   DUAL;
		END IF;

		rc := Insert_Picking_Line_Details (
				BACKORDER,
				NULL,
				NULL,
				x_delivery_id,
				p_dep_plan_required_flag,
				NULL,
				NULL,
				p_ccid,
				p_order_line_id,
				p_master_container_item_id,
				p_detail_container_item_id,
				p_inventory_item_id,
				p_load_seq_number,
				p_autodetail_group_id,
				p_new_delivery,
				p_demand_class,
				x_pl_id,
				p_original_requested_quantity -
				p_autodetailed_quantity,
				p_reservable_flag,
				p_schedule_date,
				p_schedule_level,
				'DEMANDED',
				p_subinventory,
				p_transactable_flag,
				'N',
				p_warehouse_id);

		IF rc = FAILURE THEN
		  WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Insert_Lines');
		  RETURN FAILURE;
		END IF;

		WSH_UTIL.Write_Log('Picking Line Detail created with delivery = ' || to_char(p_new_delivery));

		p_abo_recs := p_abo_recs + rc;

	      ELSIF p_backorder_line = UNRELEASED_LINE THEN
		IF p_autodetailed_quantity > 0 THEN
		  SELECT SO_DELIVERIES_S.NEXTVAL
		  INTO p_new_delivery
		  FROM DUAL;

		  -- Create a new order line detail
		  rc := Insert_Order_Line_Detail (
				p_original_line_detail_id,
				p_new_line_detail_id,
				p_original_requested_quantity -
				p_autodetailed_quantity,
				p_new_delivery);

		  IF rc = FAILURE THEN
		    WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Insert_Lines');
		    RETURN FAILURE;
		  END IF;

		  WSH_UTIL.Write_Log('Order Line Detail created with delivery = ' || to_char(p_new_delivery));

		  p_old_recs := p_old_recs + rc;

		END IF;

	      ELSE
		WSH_UTIL.Write_Log('Invalid line status');
		RETURN FAILURE;

	      END IF; /* p_backorder_line = 'Y' */

	    END IF; /* p_autodetailed_quantity <> p_original_requested_quantity */

	  ELSIF (p_transactable_flag = 'Y') AND (p_reservable_flag = 'N') THEN

	    WSH_UTIL.Write_Log('Transactable, Not Reservable');

	    -- Insert picking line
	    SELECT SO_PICKING_LINES_S.NEXTVAL
	    INTO x_pl_id
	    FROM DUAL;

	    rc := Insert_Picking_Line (
				x_pl_id,
				p_component_code,
				p_component_ratio,
				p_component_sequence_id,
				p_config_item_flag,
				p_date_requested,
				p_demand_class,
				p_included_item_flag,
				p_inventory_item_id,
				p_customer_item_id,
				p_original_line_detail_id,
				p_order_line_id,
				p_original_requested_quantity,
				ph_id,
				p_original_requested_quantity,
				p_schedule_date,
				p_sequence_number,
				p_shipment_priority_code,
				p_ship_method_code,
				p_ship_to_contact_id,
				p_ship_to_site_use_id,
				p_unit_code,
				p_warehouse_id,
				p_org_id);

	    IF rc = FAILURE THEN
	      WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Insert_Lines');
	      RETURN FAILURE;
	    END IF;

	    OPEN  nores_sub(p_ccid, p_order_line_id, p_delivery);
	    FETCH nores_sub INTO  current_sub;
	    IF nores_sub%NOTFOUND THEN
	      WSH_UTIL.Write_Log('Could not fine a subinventory in nores_sub');
	      current_sub := NULL;
	    ELSE
	      WSH_UTIL.Write_Log('Using Subinventory ' || current_sub ||
				 ' for Transactable, Non-reservable');
	    END IF;
	    CLOSE nores_sub;

	    -- Determine the pick slip number
	    ps_number := Process_Key (
			'PICK_SLIP_NUMBER',
			p_order_header_id,
			p_customer_id,
			p_ship_method_code,
			p_ship_to_site_use_id,
			p_shipment_priority_code,
			current_sub,
			p_departure_id,
			p_delivery_id,
			p_warehouse_id,
			new_flag);

	    WSH_UTIL.Write_Log('Pick Slip Number is ' || to_char(ps_number));

	    IF ps_number = FAILURE THEN
	      WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Process_Key');
	      RETURN FAILURE;
	    END IF;

	    rc := Insert_Picking_Line_Details (
				TRANSNONRES,
				ps_number,
				p_departure_id,
				p_delivery_id,
				p_dep_plan_required_flag,
				'Y',
				NULL,
				p_ccid,
				p_order_line_id,
				p_master_container_item_id,
				p_detail_container_item_id,
				p_inventory_item_id,
				p_load_seq_number,
				p_autodetail_group_id,
				p_delivery,
				p_demand_class,
				x_pl_id,
				p_original_requested_quantity,
				p_reservable_flag,
				p_schedule_date,
				p_schedule_level,
				'DEMANDED',
				current_sub,
				p_transactable_flag,
				NULL,
				p_warehouse_id);

	    IF rc = FAILURE THEN
	      WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Insert_Lines');
	      RETURN FAILURE;
	    END IF;

	  ELSIF (p_transactable_flag = 'N') THEN

	    WSH_UTIL.Write_Log('Not Transactable');

	    -- Determine the pick slip number
	    ps_number := Process_Key (
			'PICK_SLIP_NUMBER',
			p_order_header_id,
			p_customer_id,
			p_ship_method_code,
			p_ship_to_site_use_id,
			p_shipment_priority_code,
			p_subinventory,
			p_departure_id,
			p_delivery_id,
			p_warehouse_id,
			new_flag);

	    WSH_UTIL.Write_Log('Pick Slip Number is ' || to_char(ps_number));

	    IF ps_number = FAILURE THEN
	      WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Process_Key');
	      RETURN FAILURE;
	    END IF;

	    SELECT SO_PICKING_LINES_S.NEXTVAL
	    INTO x_pl_id
	    FROM DUAL;

	    rc := Insert_Picking_Line (
			x_pl_id,
			p_component_code,
			p_component_ratio,
			p_component_sequence_id,
			'Y',
			p_date_requested,
			p_demand_class,
			p_included_item_flag,
			p_inventory_item_id,
			p_customer_item_id,
			p_original_line_detail_id,
			p_order_line_id,
			p_original_requested_quantity,
			ph_id,
			p_original_requested_quantity,
			p_schedule_date,
			p_sequence_number,
			p_shipment_priority_code,
			p_ship_method_code,
			p_ship_to_contact_id,
			p_ship_to_site_use_id,
			p_unit_code,
			p_warehouse_id,
			p_org_id);

	    IF rc = FAILURE THEN
	      WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Insert_Lines');
	      RETURN FAILURE;
	    END IF;

	    rc := Insert_Picking_Line_Details (
			NONTRANS,
			ps_number,
			p_departure_id,
			p_delivery_id,
			p_dep_plan_required_flag,
			NULL,
			p_customer_requested_lot_flag,
			p_ccid,
			p_order_line_id,
			p_master_container_item_id,
			p_detail_container_item_id,
			p_inventory_item_id,
			p_load_seq_number,
			p_autodetail_group_id,
			p_delivery,
			p_demand_class,
			x_pl_id,
			p_original_requested_quantity,
			p_reservable_flag,
			p_schedule_date,
			p_schedule_level,
			p_schedule_status_code,
			p_subinventory,
			p_transactable_flag,
			NULL,
			p_warehouse_id);

	    IF rc = FAILURE THEN
	      WSH_UTIL.Write_Log('WSH_PR_PICKING_OBJECTS: Error in Insert_Lines');
	      RETURN FAILURE;
	    END IF;

	  END IF; /* Reservable, transactable etc */
	END IF; /* reservations */

	RETURN SUCCESS;

	EXCEPTION
	  WHEN OTHERS THEN
	    IF res_sub%ISOPEN THEN
	      CLOSE res_sub;
	    END IF;
	    IF nores_sub%ISOPEN THEN
	      CLOSE res_sub;
	    END IF;
	    WSH_UTIL.Default_Handler('WSH_PR_PICKING_OBJECTS.Insert_Lines');
	    RETURN FAILURE;

  END Insert_Lines;


  --
  -- Name
  --   FUNCTION Insert_Picking_Line
  --
  -- Purpose
  --   This function inserts a picking line based on
  --   the parameters passed to it.
  --
  -- Return Values
  --    -1 => Failure
  --     0 => Success
  --

  FUNCTION Insert_Picking_Line (
			p_picking_line_id		IN 	BINARY_INTEGER,
			p_component_code		IN	VARCHAR2,
			p_component_ratio		IN	BINARY_INTEGER,
			p_component_sequence_id		IN	BINARY_INTEGER,
			p_config_item_flag		IN	VARCHAR2,
			p_date_requested		IN	DATE,
			p_demand_class			IN	VARCHAR2,
			p_included_item_flag		IN	VARCHAR2,
			p_inventory_item_id		IN	BINARY_INTEGER,
			p_customer_item_id		IN	BINARY_INTEGER,
			p_original_line_detail_id	IN	BINARY_INTEGER,
			p_order_line_id			IN	BINARY_INTEGER,
			p_original_requested_quantity	IN	BINARY_INTEGER,
			p_pick_header_id		IN	BINARY_INTEGER,
			p_requested_quantity		IN	BINARY_INTEGER,
			p_schedule_date			IN	DATE,
			p_sequence_number		IN	BINARY_INTEGER,
			p_shipment_priority_code	IN	VARCHAR2,
			p_ship_method_code		IN	VARCHAR2,
			p_ship_to_contact_id		IN	BINARY_INTEGER,
			p_ship_to_site_use_id		IN	BINARY_INTEGER,
			p_unit_code			IN	VARCHAR2,
			p_warehouse_id			IN	BINARY_INTEGER,
			p_org_id			IN	BINARY_INTEGER
  )
  RETURN BINARY_INTEGER IS
  BEGIN

	WSH_UTIL.Write_Log('--------------------');
	WSH_UTIL.Write_Log('Inserting Picking Line');
	WSH_UTIL.Write_Log('picking_line_id =  ' || to_char(p_picking_line_id) ||
			   ' picking_header_id =  ' || to_char(p_pick_header_id));
	WSH_UTIL.Write_Log('order_line_id =  ' || to_char(p_order_line_id) ||
			   ' original_line_detail_id =  ' || to_char(p_original_line_detail_id));
	WSH_UTIL.Write_Log('requested_quantity =  ' || to_char(p_requested_quantity));
	WSH_UTIL.Write_Log('--------------------');

	INSERT INTO SO_PICKING_LINES_ALL (
		PICKING_LINE_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		REQUEST_ID,
		COMPONENT_CODE,
		COMPONENT_RATIO,
		COMPONENT_SEQUENCE_ID,
		CONFIGURATION_ITEM_FLAG,
		DATE_REQUESTED,
		DEMAND_CLASS_CODE,
		INCLUDED_ITEM_FLAG,
		INVENTORY_ITEM_ID,
		CUSTOMER_ITEM_ID,
		LINE_DETAIL_ID,
		ORDER_LINE_ID,
		ORIGINAL_REQUESTED_QUANTITY,
		PICKING_HEADER_ID,
		REQUESTED_QUANTITY,
		SCHEDULE_DATE,
		SEQUENCE_NUMBER,
		SHIPMENT_PRIORITY_CODE,
		SHIP_METHOD_CODE,
		SHIP_TO_CONTACT_ID,
		SHIP_TO_SITE_USE_ID,
		UNIT_CODE,
		WAREHOUSE_ID,
		ORG_ID)
	VALUES (
		p_picking_line_id,
		g_user_id,
		SYSDATE,
		g_user_id,
		SYSDATE,
		g_login_id,
		g_application_id,
		g_program_id,
		SYSDATE,
		g_request_id,
		p_component_code,
		p_component_ratio,
		p_component_sequence_id,
		p_config_item_flag,
		p_date_requested,
		p_demand_class,
		p_included_item_flag,
		p_inventory_item_id,
		decode(p_customer_item_id,
		       -1, NULL,
		       p_customer_item_id),
		p_original_line_detail_id,
		p_order_line_id,
		p_original_requested_quantity,
		p_pick_header_id,
		p_requested_quantity,
		p_schedule_date,
		p_sequence_number,
		p_shipment_priority_code,
		p_ship_method_code,
		DECODE(p_ship_to_contact_id,
		       -1, NULL,
		       p_ship_to_contact_id),
		DECODE(p_ship_to_site_use_id,
		       -1, NULL,
		       p_ship_to_site_use_id),
		p_unit_code,
		p_warehouse_id,
		decode(p_org_id, -3114, NULL, p_org_id));

	RETURN SUCCESS;

	EXCEPTION
	  WHEN OTHERS THEN
	    WSH_UTIL.Default_Handler('WSH_PR_PICKING_OBJECTS.Insert_Picking_Line');
	    RETURN FAILURE;

  END Insert_Picking_Line;


  --
  -- Name
  --   FUNCTION Insert_Picking_Line_Details
  --
  -- Purpose
  --   This function inserts picking line details based on
  --   the parameters passed to it.
  --
  -- Return Values
  --    -1 => Failure
  --     0 => Success
  --

  FUNCTION Insert_Picking_Line_Details (
			p_mode				IN	BINARY_INTEGER,
			p_ps_number			IN	BINARY_INTEGER,
			p_departure_id			IN	BINARY_INTEGER,
			p_delivery_id			IN OUT	BINARY_INTEGER,
			p_dep_plan_required_flag	IN	VARCHAR2,
			p_autoscheduled_flag		IN	VARCHAR2,
			p_customer_requested_lot_flag	IN	VARCHAR2,
			p_ccid				IN	BINARY_INTEGER,
			p_order_line_id			IN	BINARY_INTEGER,
			p_master_container_item_id	IN	BINARY_INTEGER,
			p_detail_container_item_id	IN	BINARY_INTEGER,
			p_inventory_item_id		IN	BINARY_INTEGER,
			p_load_seq_number		IN	BINARY_INTEGER,
			p_autodetail_group_id		IN	BINARY_INTEGER,
			p_delivery			IN	BINARY_INTEGER,
			p_demand_class			IN	VARCHAR2,
			p_picking_line_id		IN 	BINARY_INTEGER,
			p_requested_quantity		IN	BINARY_INTEGER,
			p_reservable_flag		IN	VARCHAR2,
			p_schedule_date			IN	DATE,
			p_schedule_level		IN	VARCHAR2,
			p_schedule_status_code		IN	VARCHAR2,
			p_subinventory			IN	VARCHAR2,
			p_transactable_flag		IN	VARCHAR2,
			p_released_flag			IN	VARCHAR2,
			p_warehouse_id			IN	BINARY_INTEGER
  )
  RETURN BINARY_INTEGER IS

  rows_inserted		BINARY_INTEGER;
  l_dpw_assigned_flag	VARCHAR2(1);
  default_subinventory  VARCHAR2(10);

  BEGIN
	WSH_UTIL.Write_Log('--------------------');
	WSH_UTIL.Write_Log('Mode is ' || to_char(p_mode));

	IF p_departure_id = -1 AND p_delivery_id = -1 THEN
	  l_dpw_assigned_flag := 'N';
	ELSE
	  l_dpw_assigned_flag := NULL;
	END IF;

        -- Get default subinventory, if not already set
	IF p_reservable_flag = 'N' THEN
          default_subinventory := WSH_DEL_OI_CORE.DEFAULT_SUBINVENTORY (
				p_warehouse_id,
				p_inventory_item_id);
        END IF;

	IF p_mode in (RESOFF, NONTRANS) THEN
	  INSERT INTO SO_PICKING_LINE_DETAILS (
		PICKING_LINE_DETAIL_ID,
		PICK_SLIP_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		REQUEST_ID,
		AUTOSCHEDULED_FLAG,
		DEPARTURE_ID,
		DELIVERY_ID,
		MASTER_CONTAINER_ITEM_ID,
		DETAIL_CONTAINER_ITEM_ID,
		LOAD_SEQ_NUMBER,
		DPW_ASSIGNED_FLAG,
		DELIVERY,
		DEMAND_CLASS_CODE,
		PICKING_LINE_ID,
		REQUESTED_QUANTITY,
		RESERVABLE_FLAG,
		SCHEDULE_DATE,
		SCHEDULE_LEVEL,
		SCHEDULE_STATUS_CODE,
		SUBINVENTORY,
		TRANSACTABLE_FLAG,
		WAREHOUSE_ID,
		MVT_STAT_STATUS)
	  VALUES (
		SO_PICKING_LINE_DETAILS_S.NEXTVAL,
		p_ps_number,
		g_user_id,
		SYSDATE,
		g_user_id,
		SYSDATE,
		g_login_id,
		g_application_id,
		g_program_id,
		SYSDATE,
		g_request_id,
		decode(p_mode,NONTRANS,'Y',NULL),
		decode(p_departure_id, -1, NULL, p_departure_id),
		decode(p_delivery_id, -1, NULL, p_delivery_id),
		decode(p_master_container_item_id, -1, NULL, p_master_container_item_id),
		decode(p_detail_container_item_id, -1, NULL, p_detail_container_item_id),
		DECODE(p_load_seq_number,
		       -1, NULL,
		       p_load_seq_number),
		l_dpw_assigned_flag,
		p_delivery,
		p_demand_class,
		p_picking_line_id,
		p_requested_quantity,
		p_reservable_flag,
		p_schedule_date,
		p_schedule_level,
		p_schedule_status_code,
		nvl(p_subinventory, decode(p_reservable_flag, 'N', default_subinventory, NULL)),
		p_transactable_flag,
		p_warehouse_id,
		'NEW');

	  rows_inserted := SQL%ROWCOUNT;

	ELSIF p_mode = RESERVABLE THEN
	  INSERT INTO SO_PICKING_LINE_DETAILS (
		PICKING_LINE_DETAIL_ID,
		PICK_SLIP_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		REQUEST_ID,
		AUTOSCHEDULED_FLAG,
		CUSTOMER_REQUESTED_LOT_FLAG,
		DEPARTURE_ID,
		DELIVERY_ID,
		MASTER_CONTAINER_ITEM_ID,
		DETAIL_CONTAINER_ITEM_ID,
		LOAD_SEQ_NUMBER,
		DPW_ASSIGNED_FLAG,
		DELIVERY,
		DEMAND_CLASS_CODE,
		DEMAND_ID,
		INVENTORY_LOCATION_ID,
		LOT_NUMBER,
		PICKING_LINE_ID,
		REQUESTED_QUANTITY,
		RESERVABLE_FLAG,
		REVISION,
		SCHEDULE_DATE,
		SCHEDULE_LEVEL,
		SCHEDULE_STATUS_CODE,
		SUBINVENTORY,
		SUPPLY_SOURCE_HEADER_ID,
		SUPPLY_SOURCE_TYPE,
		TRANSACTABLE_FLAG,
		WAREHOUSE_ID,
		MVT_STAT_STATUS)
	  SELECT
		SO_PICKING_LINE_DETAILS_S.NEXTVAL,
		p_ps_number,
		g_user_id,
		SYSDATE,
		g_user_id,
		SYSDATE,
		g_login_id,
		g_application_id,
		g_program_id,
		SYSDATE,
		g_request_id,
		'Y',
		p_customer_requested_lot_flag,
		decode(p_departure_id, -1, NULL, p_departure_id),
		decode(p_delivery_id, -1, NULL, p_delivery_id),
		decode(p_master_container_item_id, -1, NULL, p_master_container_item_id),
		decode(p_detail_container_item_id, -1, NULL, p_detail_container_item_id),
		DECODE(p_load_seq_number,
		       -1, NULL,
		       p_load_seq_number),
		l_dpw_assigned_flag,
		D.DEMAND_SOURCE_DELIVERY,
		D.DEMAND_CLASS,
		D.DEMAND_ID,
		D.LOCATOR_ID,
		D.LOT_NUMBER,
		p_picking_line_id,
		D.LINE_ITEM_QUANTITY,
		p_reservable_flag,
		D.REVISION,
		D.REQUIREMENT_DATE,
		p_schedule_level,
		'RESERVED',
		D.SUBINVENTORY,
		D.SUPPLY_SOURCE_HEADER_ID,
		D.SUPPLY_SOURCE_TYPE,
		p_transactable_flag,
		D.ORGANIZATION_ID,
		'NEW'
	  FROM 	MTL_DEMAND D
	  WHERE	D.DEMAND_SOURCE_HEADER_ID = p_ccid
	  AND	D.DEMAND_SOURCE_TYPE IN (2,8)
	  AND	D.DEMAND_SOURCE_LINE = to_char(p_order_line_id)
	  AND	D.DEMAND_SOURCE_DELIVERY = to_char(p_delivery)
	  AND	D.AUTODETAIL_GROUP_ID = p_autodetail_group_id
	  AND	NVL(D.LINE_ITEM_QUANTITY,0) <> 0
	  AND	D.PARENT_DEMAND_ID IS NOT NULL
	  AND	D.RESERVATION_TYPE = 2
	  AND	D.SUBINVENTORY = DECODE(g_use_sub_ps, 'Y', p_subinventory, D.SUBINVENTORY);

	  rows_inserted := SQL%ROWCOUNT;

	ELSIF p_mode = TRANSNONRES THEN
	  INSERT INTO SO_PICKING_LINE_DETAILS (
		PICKING_LINE_DETAIL_ID,
		PICK_SLIP_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		REQUEST_ID,
		AUTOSCHEDULED_FLAG,
		CUSTOMER_REQUESTED_LOT_FLAG,
		DEPARTURE_ID,
		DELIVERY_ID,
		MASTER_CONTAINER_ITEM_ID,
		DETAIL_CONTAINER_ITEM_ID,
		LOAD_SEQ_NUMBER,
		DPW_ASSIGNED_FLAG,
		DELIVERY,
		DEMAND_CLASS_CODE,
		DEMAND_ID,
		INVENTORY_LOCATION_ID,
		LOT_NUMBER,
		PICKING_LINE_ID,
		REQUESTED_QUANTITY,
		RESERVABLE_FLAG,
		REVISION,
		SCHEDULE_DATE,
		SCHEDULE_LEVEL,
		SCHEDULE_STATUS_CODE,
		SUBINVENTORY,
		SUPPLY_SOURCE_HEADER_ID,
		SUPPLY_SOURCE_TYPE,
		TRANSACTABLE_FLAG,
		WAREHOUSE_ID,
		MVT_STAT_STATUS)
	  SELECT
		SO_PICKING_LINE_DETAILS_S.NEXTVAL,
		p_ps_number,
		g_user_id,
		SYSDATE,
		g_user_id,
		SYSDATE,
		g_login_id,
		g_application_id,
		g_program_id,
		SYSDATE,
		g_request_id,
		'Y',
		p_customer_requested_lot_flag,
		decode(p_departure_id, -1, NULL, p_departure_id),
		decode(p_delivery_id, -1, NULL, p_delivery_id),
		decode(p_master_container_item_id, -1, NULL, p_master_container_item_id),
		decode(p_detail_container_item_id, -1, NULL, p_detail_container_item_id),
		DECODE(p_load_seq_number,
		       -1, NULL,
		       p_load_seq_number),
		l_dpw_assigned_flag,
		D.DEMAND_SOURCE_DELIVERY,
		D.DEMAND_CLASS,
		D.DEMAND_ID,
		D.LOCATOR_ID,
		D.LOT_NUMBER,
		p_picking_line_id,
		D.LINE_ITEM_QUANTITY,
		p_reservable_flag,
		D.REVISION,
		D.REQUIREMENT_DATE,
		p_schedule_level,
		'DEMANDED',
		nvl(D.SUBINVENTORY, decode(p_reservable_flag, 'N', default_subinventory, NULL)),
		D.SUPPLY_SOURCE_HEADER_ID,
		D.SUPPLY_SOURCE_TYPE,
		p_transactable_flag,
		D.ORGANIZATION_ID,
		'NEW'
	  FROM 	MTL_DEMAND D
	  WHERE	D.DEMAND_SOURCE_HEADER_ID = p_ccid
	  AND	D.DEMAND_SOURCE_TYPE IN (2,8)
	  AND	D.DEMAND_SOURCE_LINE = to_char(p_order_line_id)
	  AND	D.DEMAND_SOURCE_DELIVERY = to_char(p_delivery)
	  AND	D.AUTODETAIL_GROUP_ID IS NULL
	  AND	NVL(D.LINE_ITEM_QUANTITY,0) <> 0
	  AND	D.PARENT_DEMAND_ID IS NOT NULL
	  AND	nvl(D.SUBINVENTORY, -99) = DECODE(g_use_sub_ps, 'Y', nvl(p_subinventory, -99), nvl(D.SUBINVENTORY, -99));

	  rows_inserted := SQL%ROWCOUNT;

	ELSIF p_mode = BACKORDER THEN
	  INSERT INTO SO_PICKING_LINE_DETAILS (
		PICKING_LINE_DETAIL_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		REQUEST_ID,
		DPW_ASSIGNED_FLAG,
		RELEASED_FLAG,
		DELIVERY,
		DEMAND_CLASS_CODE,
		PICKING_LINE_ID,
		REQUESTED_QUANTITY,
		RESERVABLE_FLAG,
		SCHEDULE_DATE,
		SCHEDULE_LEVEL,
		SCHEDULE_STATUS_CODE,
		SUBINVENTORY,
		TRANSACTABLE_FLAG,
		WAREHOUSE_ID,
		MVT_STAT_STATUS)
	  VALUES (
		SO_PICKING_LINE_DETAILS_S.NEXTVAL,
		g_user_id,
		SYSDATE,
		g_user_id,
		SYSDATE,
		g_login_id,
		g_application_id,
		g_program_id,
		SYSDATE,
		g_request_id,
		'N',
		'N',
		p_delivery,
		p_demand_class,
		p_picking_line_id,
		p_requested_quantity,
		p_reservable_flag,
		p_schedule_date,
		p_schedule_level,
		'DEMANDED',
		p_subinventory,
		p_transactable_flag,
		p_warehouse_id,
		'NEW');

	  rows_inserted := SQL%ROWCOUNT;

	ELSE
	  WSH_UTIL.Write_Log('Invalid picking line detail insertion mode');
	  RETURN FAILURE;
	END IF;

	WSH_UTIL.Write_Log('Inserted ' || to_char(rows_inserted) ||
			   ' picking_line_details for picking_line '|| to_char(p_picking_line_id));

	IF rows_inserted = 0 THEN
	  RETURN FAILURE;
	ELSE
	  RETURN rows_inserted;
	END IF;

	EXCEPTION
	  WHEN OTHERS THEN
	    WSH_UTIL.Default_Handler('WSH_PR_PICKING_OBJECTS.Insert_Picking_Line_Details',
				     to_char(p_mode));
	    RETURN FAILURE;

  END Insert_Picking_Line_Details;


  --
  -- Name
  --   FUNCTION Insert_Order_Line_Detail
  --
  -- Purpose
  --   This function inserts an order line detail for the
  --   remaining quantity.
  --
  -- Return Values
  --    -1 => Failure
  --     0 => Success
  --

  FUNCTION Insert_Order_Line_Detail (
			p_original_line_detail_id	IN	BINARY_INTEGER,
			p_new_line_detail_id		IN OUT	BINARY_INTEGER,
			p_quantity			IN	BINARY_INTEGER,
			p_new_delivery			IN 	BINARY_INTEGER
  ) RETURN BINARY_INTEGER IS

	rows_inserted		BINARY_INTEGER;

  BEGIN
	WSH_UTIL.Write_Log('--------------------');
	WSH_UTIL.Write_Log('Inserting new order line detail');

	SELECT SO_LINE_DETAILS_S.NEXTVAL
	INTO p_new_line_detail_id
	FROM DUAL;

	INSERT INTO SO_LINE_DETAILS (
		LINE_DETAIL_ID,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		LINE_ID,
		INVENTORY_ITEM_ID,
		INCLUDED_ITEM_FLAG,
		COMPONENT_SEQUENCE_ID,
		COMPONENT_CODE,
		COMPONENT_RATIO,
		SHIPPABLE_FLAG,
		TRANSACTABLE_FLAG,
		RESERVABLE_FLAG,
		UNIT_CODE,
		RELEASED_FLAG,
		REQUIRED_FOR_REVENUE_FLAG,
		QUANTITY,
		WAREHOUSE_ID,
		DEMAND_CLASS_CODE,
		SCHEDULE_DATE,
		REVISION,
		LOT_NUMBER,
		SUBINVENTORY,
		CUSTOMER_REQUESTED_LOT_FLAG,
		SCHEDULE_STATUS_CODE,
		SCHEDULE_LEVEL_CODE,
		QUANTITY_SVRID,
		WAREHOUSE_SVRID,
		DEMAND_CLASS_SVRID,
		DATE_SVRID,
		REVISION_SVRID,
		LOT_SVRID,
		SUBINVENTORY_SVRID,
		CUSTOMER_REQUESTED_SVRID,
		DF_SVRID,
		CONTEXT,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		DELIVERY,
		WIP_RESERVED_QUANTITY,
		WIP_COMPLETED_QUANTITY,
		SUPPLY_SOURCE_TYPE,
		SUPPLY_SOURCE_HEADER_ID,
                DEPARTURE_ID,
                DELIVERY_ID,
                DPW_ASSIGNED_FLAG,
		UPDATE_FLAG,
		INVENTORY_LOCATION_ID,
		CONFIGURATION_ITEM_FLAG,
		LATEST_ACCEPTABLE_DATE,
		LATEST_ACCEPTABLE_DATE_SVRID,
		DEP_PLAN_REQUIRED_FLAG,
		CUSTOMER_ITEM_ID,
		LOAD_SEQ_NUMBER
		)
	SELECT  p_new_line_detail_id,
		SYSDATE,
		g_user_id,
		SYSDATE,
		g_user_id,
		g_login_id,
		LINE_ID,
		INVENTORY_ITEM_ID,
		INCLUDED_ITEM_FLAG,
		COMPONENT_SEQUENCE_ID,
		COMPONENT_CODE,
		COMPONENT_RATIO,
		SHIPPABLE_FLAG,
		TRANSACTABLE_FLAG,
		RESERVABLE_FLAG,
		UNIT_CODE,
		'N',
		REQUIRED_FOR_REVENUE_FLAG,
		p_quantity,
		WAREHOUSE_ID,
		DEMAND_CLASS_CODE,
		SCHEDULE_DATE,
		REVISION,
		LOT_NUMBER,
		SUBINVENTORY,
		CUSTOMER_REQUESTED_LOT_FLAG,
		SCHEDULE_STATUS_CODE,
		SCHEDULE_LEVEL_CODE,
		QUANTITY_SVRID,
		WAREHOUSE_SVRID,
		DEMAND_CLASS_SVRID,
		DATE_SVRID,
		REVISION_SVRID,
		LOT_SVRID,
		SUBINVENTORY_SVRID,
		CUSTOMER_REQUESTED_SVRID,
		DF_SVRID,
		CONTEXT,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		p_new_delivery,
		WIP_RESERVED_QUANTITY,
		WIP_COMPLETED_QUANTITY,
		SUPPLY_SOURCE_TYPE,
		SUPPLY_SOURCE_HEADER_ID,
                DEPARTURE_ID,
                DELIVERY_ID,
                DPW_ASSIGNED_FLAG,
		UPDATE_FLAG,
		INVENTORY_LOCATION_ID,
		CONFIGURATION_ITEM_FLAG,
		LATEST_ACCEPTABLE_DATE,
		LATEST_ACCEPTABLE_DATE_SVRID,
		DEP_PLAN_REQUIRED_FLAG,
		CUSTOMER_ITEM_ID,
		LOAD_SEQ_NUMBER
	FROM SO_LINE_DETAILS
	WHERE line_detail_id = p_original_line_detail_id;

	rows_inserted := SQL%ROWCOUNT;

	WSH_UTIL.Write_Log('Inserted ' || to_char(rows_inserted) ||
			   ' order_line_detail = ' || to_char(p_new_line_detail_id));

	RETURN rows_inserted;

	EXCEPTION
	  WHEN OTHERS THEN
	    WSH_UTIL.Default_Handler('WSH_PR_PICKING_OBJECTS.Insert_Order_Line_Detail');
	    RETURN FAILURE;

  END Insert_Order_Line_Detail;


  --
  -- Name
  --   FUNCTION Process_Key
  --
  -- Purpose
  --   This function returns the picking_header_id, or
  --   the pick slip number to be used for the picking
  --   headers and picking lines.
  --
  -- Return Values
  --   Pick Slip Number or Picking Header ID based on mode.
  --

  FUNCTION Process_Key (
		p_mode				IN 	VARCHAR2,
		p_header_id			IN	BINARY_INTEGER,
		p_customer_id			IN 	BINARY_INTEGER,
		p_ship_method_code		IN 	VARCHAR2,
		p_ship_to_site_use_id		IN 	BINARY_INTEGER,
		p_shipment_priority		IN 	VARCHAR2,
		p_subinventory			IN 	VARCHAR2,
		p_departure_id			IN 	BINARY_INTEGER,
		p_delivery_id			IN OUT	BINARY_INTEGER,
		p_warehouse_id			IN 	BINARY_INTEGER,
		new_flag			IN OUT  VARCHAR2
  )
  RETURN BINARY_INTEGER IS

  key 		VARCHAR2(200);
  x_value		BINARY_INTEGER;
  found		BOOLEAN;
  tab_size 	BINARY_INTEGER;
  i		BINARY_INTEGER;

  BEGIN
	found := FALSE;
	new_flag := 'N';
	IF p_mode = 'PICK_SLIP_NUMBER' THEN
	  -- Construct Key
	  key := 'r';
	  IF (g_use_order_ps = 'Y') THEN
	    key := key || to_char(p_header_id);
	  END IF;
	  IF (g_use_sub_ps = 'Y') THEN
	    key := key || p_subinventory;
	  END IF;
	  IF (g_use_customer_ps = 'Y') THEN
	    key := key || to_char(p_customer_id);
	  END IF;
	  IF (g_use_ship_to_ps = 'Y') THEN
	    key := key || to_char(p_ship_to_site_use_id);
	  END IF;
	  IF (g_use_carrier_ps = 'Y') THEN
	    key := key || p_ship_method_code;
	  END IF;
	  IF (g_use_ship_priority_ps = 'Y') THEN
	    key := key || p_shipment_priority;
	  END IF;
	  IF (g_use_departure_ps = 'Y') THEN
	    key := key || to_char(p_departure_id);
	  END IF;
	  IF (g_use_delivery_ps = 'Y') THEN
	    key := key || to_char(p_delivery_id);
	  END IF;
	  -- Implicitly use warehouse
	  key := key || to_char(p_warehouse_id);

	  -- Find key in table
	  FOR i IN 1..g_ps_table.count LOOP
	    IF g_ps_table(i).key = key THEN
	      x_value := g_ps_table(i).value;
	      found := TRUE;
	      EXIT;
	    END IF;
	  END LOOP;

	  IF found THEN
	    RETURN x_value;
	  ELSE
	    SELECT SO_PICKING_HEADERS_S.NEXTVAL
            INTO x_value
            FROM DUAL;
	    tab_size := g_ps_table.count;
	    g_ps_table(tab_size+1).key := key;
	    g_ps_table(tab_size+1).value := x_value;
	    new_flag := 'Y';
	    RETURN x_value;
	  END IF;

	ELSIF p_mode = 'PICKING_HEADER_ID' THEN
	  -- Construct Key
	  key := 'r' || to_char(p_header_id) || to_char(p_warehouse_id) ||
		 to_char(p_ship_to_site_use_id) || p_shipment_priority ||
		 p_ship_method_code;

	  -- Find key in table
	  FOR i IN 1..g_ph_table.count LOOP
	    IF g_ph_table(i).key = key THEN
	      x_value := g_ph_table(i).value;
	      found := TRUE;
	      EXIT;
	    END IF;
	  END LOOP;

	  IF found THEN
	    RETURN x_value;
	  ELSE
	    SELECT SO_PICKING_HEADERS_S.NEXTVAL
            INTO x_value
            FROM DUAL;
	    tab_size := g_ph_table.count;
	    g_ph_table(tab_size+1).key := key;
	    g_ph_table(tab_size+1).value := x_value;
	    new_flag := 'Y';
	    RETURN x_value;
	  END IF;

	END IF;

	EXCEPTION
	  WHEN OTHERS THEN
	    WSH_UTIL.Default_Handler('WSH_PR_PICKING_OBJECTS.Process_Key');
	    RETURN FAILURE;

  END Process_Key;

END WSH_PR_PICKING_OBJECTS;

/
