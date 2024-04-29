--------------------------------------------------------
--  DDL for Package Body WSH_PR_PICKING_SESSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PR_PICKING_SESSION" AS
/* $Header: WSHPRPSB.pls 115.23 99/08/18 17:46:23 porting ship $ */

--
-- Package
--   	WSH_PR_PICKING_SESSION
--
-- Purpose
--      This package does the following:
--	- Maintain all the session variables for Pick Release
--      - Construct SQL statements to fetch backordered picking
--        line details, unreleased line details, non-shippable
--        lines satisfying the release criteria.
--      - Provides API to retrieve session values
--

  --
  -- PACKAGE TYPES
  --

	TYPE rsrTyp IS RECORD (
		attribute	BINARY_INTEGER,
		attribute_name	VARCHAR2(30),
		priority	BINARY_INTEGER,
		sort_order	VARCHAR2(4)
	);

	TYPE rsrTabTyp IS TABLE OF rsrTyp INDEX BY BINARY_INTEGER;

  --
  -- PACKAGE CONSTANTS
  --

	-- Reflect status of calls to functions and procedures
	SUCCESS			CONSTANT  BINARY_INTEGER := 0;
	FAILURE			CONSTANT  BINARY_INTEGER := -1;

	-- Indicates the pick slip printing mode
	IMMEDIATE_PRINT_PS	CONSTANT  BINARY_INTEGER := 2;
	DEFERRED_PRINT_PS	CONSTANT  BINARY_INTEGER := 3;

	-- Indicates what attributes are used in Release Sequence
        -- Rules
	C_INVOICE_VALUE		CONSTANT  BINARY_INTEGER := 1;
	C_ORDER_NUMBER		CONSTANT  BINARY_INTEGER := 2;
	C_SCHEDULE_DATE		CONSTANT  BINARY_INTEGER := 3;
	C_DEPARTURE		CONSTANT  BINARY_INTEGER := 4;
	C_SHIPMENT_PRIORITY	CONSTANT  BINARY_INTEGER := 5;

  --
  -- PACKAGE VARIABLES
  --

	initialized				BOOLEAN := FALSE;
	ordered_rsr				rsrTabTyp;
	total_release_criteria			BINARY_INTEGER;
	unreleased_SQL				VARCHAR2(10000) := NULL;
	backordered_SQL				VARCHAR2(10000) := NULL;
	non_ship_SQL				VARCHAR2(10000) := NULL;
	sync_SQL				VARCHAR2(10000) := NULL;
	sreq_SQL				VARCHAR2(10000) := NULL;
	orderby_SQL				VARCHAR2(500)   := NULL;
	invoice_value_flag			VARCHAR2(1) := 'N';
	print_ps_mode_param			VARCHAR2(1);
	print_ps_mode				BINARY_INTEGER;
	use_order_header			BOOLEAN := FALSE;
	error_message				VARCHAR2(240);

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --

  --
  -- FORWARD DECLERATIONS
  --
  PROCEDURE Process_Buffer(
		p_buffer_name		IN	VARCHAR2,
		p_buffer_text		IN	VARCHAR2
  );


  --
  -- Name
  --   FUNCTION Init
  --
  -- Purpose
  --   This function initializes variables for the session:
  --   - Retrieves criteria for the batch and sets up session
  --     variables
  --   - Locks row for the batch
  --   - Update who columns for the batch
  --
  -- Arguments
  --   p_batch_id	- batch to be processed
  --   p_reservations	- reservations flag
  --
  -- Return Values
  --  -1 => Failure
  --   0 => Success
  --
  -- Notes
  --

  FUNCTION Init(
		   p_batch_id			IN	BINARY_INTEGER,
                   p_request_id			IN	BINARY_INTEGER,
                   p_application_id		IN	BINARY_INTEGER,
                   p_program_id			IN	BINARY_INTEGER,
                   p_user_id			IN	BINARY_INTEGER,
                   p_login_id			IN	BINARY_INTEGER,
                   p_reservations		IN	BINARY_INTEGER,
                   p_backorders_flag		IN OUT	VARCHAR2,
		   p_header_id          	IN OUT  BINARY_INTEGER,
		   p_ship_set_number    	IN OUT  BINARY_INTEGER,
		   p_order_type_id		IN OUT	BINARY_INTEGER,
		   p_warehouse_id		IN OUT	BINARY_INTEGER,
		   p_customer_id 		IN OUT	BINARY_INTEGER,
		   p_ship_site_use_id		IN OUT	BINARY_INTEGER,
		   p_shipment_priority		IN OUT	VARCHAR2,
		   p_ship_method_code		IN OUT	VARCHAR2,
		   p_from_request_date   	IN OUT	VARCHAR2,
		   p_to_request_date     	IN OUT	VARCHAR2,
		   p_from_sched_ship_date	IN OUT	VARCHAR2,
		   p_to_sched_ship_date		IN OUT	VARCHAR2,
		   p_existing_rsvs_only_flag	IN OUT	VARCHAR2,
		   p_subinventory		IN OUT	VARCHAR2,
		   p_inventory_item_id		IN OUT	BINARY_INTEGER,
		   p_departure_id		IN OUT	BINARY_INTEGER,
		   p_delivery_id 		IN OUT	BINARY_INTEGER,
		   p_pick_slip_rule_id		IN OUT	BINARY_INTEGER,
		   p_release_seq_rule_id	IN OUT	BINARY_INTEGER,
		   p_report_set_id		IN OUT	BINARY_INTEGER,
		   p_include_planned_lines	IN OUT	VARCHAR2,
		   p_partial_allowed_flag	IN OUT	VARCHAR2,
		   p_print_ps_mode		IN OUT	BINARY_INTEGER
  )
  RETURN BINARY_INTEGER IS

	-- cursor to get batch parameter information
	/*  Note: print_flag indicates the report_set_id */
	CURSOR	get_lock_batch(x_batch_id IN BINARY_INTEGER) IS
	SELECT	NAME,
		BACKORDERS_ONLY_FLAG,
		NVL(RELEASE_SEQ_RULE_ID, -1),
		NVL(PICK_SLIP_RULE_ID, -1),
		NVL(PARTIAL_ALLOWED_FLAG, 'N'),
		NVL(INCLUDE_PLANNED_LINES, 'N'),
		NVL(CUSTOMER_ID, 0),
		NVL(DATE_REQUESTED_FROM, NULL),
		NVL(DATE_REQUESTED_TO, NULL),
		NVL(EXISTING_RSVS_ONLY_FLAG, 'N'),
		NVL(HEADER_ID, 0),
		NVL(INVENTORY_ITEM_ID, 0),
		NVL(DEPARTURE_ID, 0),
		NVL(DELIVERY_ID, 0),
		NVL(ORDER_TYPE_ID, 0),
		NVL(SCHEDULED_SHIPMENT_DATE_FROM, NULL),
		NVL(SCHEDULED_SHIPMENT_DATE_TO, NULL),
		NVL(SHIPMENT_PRIORITY_CODE, ''),
		NVL(SHIP_METHOD_CODE, ''),
		NVL(SHIP_SET_NUMBER, 0),
		NVL(SITE_USE_ID, 0),
		NVL(SUBINVENTORY, ''),
		NVL(WAREHOUSE_ID, -1),
		NVL(ORG_ID, -3114),
		NVL(AUTOCREATE_DELIVERY_FLAG,'N'),
		NVL(ORDER_LINE_ID, 0),
		TO_NUMBER(NVL(PRINT_FLAG, '-1'))
	FROM	SO_PICKING_BATCHES_ALL
	WHERE	BATCH_ID = x_batch_id
	FOR UPDATE OF BATCH_ID NOWAIT;

	-- cursor to fetch release sequence rule info
	CURSOR	rel_seq_rule(x_rsr_id IN BINARY_INTEGER) IS
	SELECT	NAME,
		NVL(ORDER_ID_PRIORITY, -1),
		DECODE(ORDER_ID_SORT, 'A', 'ASC', 'D', 'DESC', ''),
		NVL(INVOICE_VALUE_PRIORITY, -1),
		DECODE(INVOICE_VALUE_SORT, 'A', 'ASC', 'D', 'DESC', ''),
		NVL(SCHEDULE_DATE_PRIORITY, -1),
		DECODE(SCHEDULE_DATE_SORT, 'A', 'ASC', 'D', 'DESC', ''),
		NVL(SHIPMENT_PRI_PRIORITY, -1),
		DECODE(SHIPMENT_PRI_SORT, 'A', 'ASC', 'D', 'DESC', ''),
		NVL(DEPARTURE_PRIORITY, -1),
		DECODE(DEPARTURE_SORT, 'A', 'ASC', 'D', 'DESC', '')
	FROM	WSH_RELEASE_SEQ_RULES
	WHERE	RELEASE_SEQ_RULE_ID = x_rsr_id
	AND	SYSDATE BETWEEN TRUNC(NVL(START_DATE_ACTIVE, SYSDATE)) AND
			        NVL(END_DATE_ACTIVE, TRUNC(SYSDATE)+1);

	-- cursor to determine if pick slip rule contains order number
	CURSOR  order_ps_group(x_psr_id IN BINARY_INTEGER) IS
	SELECT  NVL(ORDER_NUMBER_FLAG,'N')
	FROM    WSH_PICK_SLIP_RULES
	WHERE   PICK_SLIP_RULE_ID = x_psr_id
	AND     SYSDATE BETWEEN TRUNC(NVL(START_DATE_ACTIVE, SYSDATE)) AND
			        NVL(END_DATE_ACTIVE, TRUNC(SYSDATE)+1);

	-- cursor to determine print pick slip mode parameter
        CURSOR ps_mode_param(x_org_id IN BINARY_INTEGER) IS
	SELECT NVL(PRINT_PICK_SLIP_MODE, 'E')
        FROM   WSH_PARAMETERS
	WHERE  ORGANIZATION_ID = x_org_id;

	-- cursor to get line information
	CURSOR get_line_info(x_line_id In BINARY_INTEGER) IS
	SELECT HEADER_ID, NVL(PARENT_LINE_ID, -1)
	FROM   SO_LINES_ALL
	WHERE  LINE_ID = x_line_id;

	record_locked				EXCEPTION;
	PRAGMA EXCEPTION_INIT(record_locked, -54);

	use_order_ps				VARCHAR2(1);
	invoice_value_priority			BINARY_INTEGER;
	order_number_priority			BINARY_INTEGER;
	schedule_date_priority			BINARY_INTEGER;
	departure_priority			BINARY_INTEGER;
	shipment_pri_priority			BINARY_INTEGER;
	invoice_value_sort			VARCHAR2(4);
	order_number_sort			VARCHAR2(4);
	schedule_date_sort			VARCHAR2(4);
	departure_sort				VARCHAR2(4);
	shipment_pri_sort			VARCHAR2(4);
	v_header_id				BINARY_INTEGER;
	v_parent_line_id			BINARY_INTEGER;
	i					BINARY_INTEGER;
	j					BINARY_INTEGER;
	temp_rsr				rsrTyp;
	cs					BINARY_INTEGER;

  BEGIN

	WSH_UTIL.Write_Log('Starting WSH_PR_PICKING_SESSION.Init');

	IF initialized = TRUE THEN
	   RETURN SUCCESS;
	END IF;

	-- initialize the WHO session variables
	request_id := p_request_id;
	WSH_UTIL.Write_Log('request_id = ' || to_char(request_id));
	application_id := p_application_id;
	WSH_UTIL.Write_Log('application_id = ' || to_char(application_id));
	program_id := p_program_id;
	WSH_UTIL.Write_Log('program_id = ' || to_char(program_id));
	user_id := p_user_id;
	WSH_UTIL.Write_Log('user_id = ' || to_char(user_id));
	login_id := p_login_id;
	WSH_UTIL.Write_Log('login_id = ' || to_char(login_id));


	-- initialize other session variables
	batch_id := p_batch_id;
	IF p_reservations = 1 THEN
	  reservations := 'Y';
	ELSE
	  reservations := 'N';
	END IF;

	WSH_UTIL.Write_Log('Fetching release criteria for batch');

	-- fetch release criteria for the batch and lock row
	OPEN	get_lock_batch(p_batch_id);
	FETCH	get_lock_batch
	INTO	batch_name,
		backorders_flag,
		release_seq_rule_id,
		pick_slip_rule_id,
		partial_allowed_flag,
		include_planned_lines,
		customer_id,
		from_request_date,
		to_request_date,
		existing_rsvs_only_flag,
		header_id,
		inventory_item_id,
		departure_id,
		delivery_id,
		order_type_id,
		from_sched_ship_date,
		to_sched_ship_date,
		shipment_priority,
		ship_method_code,
		ship_set_number,
		ship_site_use_id,
		subinventory,
		warehouse_id,
		org_id,
		autocreate_deliveries,
		order_line_id,
		report_set_id;

	-- handle batch does not exist condition
	IF get_lock_batch%NOTFOUND THEN
	   WSH_UTIL.Write_Log('Batch ID ' || to_char(p_batch_id) || ' does not exist.');
	   RETURN FAILURE;
	END IF;

	IF get_lock_batch%ISOPEN THEN
	  CLOSE get_lock_batch;
	END IF;

	WSH_UTIL.Write_Log('Pick Release parameters are...');

	-- set all the out variables
	p_backorders_flag := backorders_flag;
	WSH_UTIL.Write_Log('backorders_flag = ' || p_backorders_flag);

	p_header_id := header_id;
	WSH_UTIL.Write_Log('header_id = ' || to_char(p_header_id));

	p_ship_set_number := ship_set_number;
	WSH_UTIL.Write_Log('ship_set_number = ' || to_char(p_ship_set_number));

	p_order_type_id := order_type_id;
	WSH_UTIL.Write_Log('order_type_id = ' || to_char(p_order_type_id));

	p_warehouse_id := warehouse_id;
	WSH_UTIL.Write_Log('warehouse_id = ' || to_char(p_warehouse_id));

	p_customer_id := customer_id;
	WSH_UTIL.Write_Log('customer_id = ' || to_char(p_customer_id));

	p_ship_site_use_id := ship_site_use_id;
	WSH_UTIL.Write_Log('ship_site_use_id = ' || to_char(p_ship_site_use_id));

	p_shipment_priority := shipment_priority;
	WSH_UTIL.Write_Log('shipment_priority = ' || p_shipment_priority);

	p_ship_method_code := ship_method_code;
	WSH_UTIL.Write_Log('ship_method_code = ' || p_ship_method_code);

	p_from_request_date := to_char(from_request_date, 'YYYY/MM/DD HH24:MI:SS');
	WSH_UTIL.Write_Log('from_request_date = ' || p_from_request_date);

	p_to_request_date := to_char(to_request_date, 'YYYY/MM/DD HH24:MI:SS');
	WSH_UTIL.Write_Log('to_request_date = ' || p_to_request_date);

	p_from_sched_ship_date := to_char(from_sched_ship_date, 'YYYY/MM/DD HH24:MI:SS');
	WSH_UTIL.Write_Log('from_sched_ship_date = ' || p_from_sched_ship_date);

	p_to_sched_ship_date := to_char(to_sched_ship_date, 'YYYY/MM/DD HH24:MI:SS');
	WSH_UTIL.Write_Log('to_sched_ship_date = ' || p_to_sched_ship_date);

	p_existing_rsvs_only_flag := existing_rsvs_only_flag;
	WSH_UTIL.Write_Log('existing_rsvs_only_flag = ' || p_existing_rsvs_only_flag);

	p_subinventory := subinventory;
	WSH_UTIL.Write_Log('subinventory = ' || p_subinventory);

	p_inventory_item_id := inventory_item_id;
	WSH_UTIL.Write_Log('inventory_item_id = ' || to_char(p_inventory_item_id));

	p_departure_id := departure_id;
	WSH_UTIL.Write_Log('departure_id = ' || to_char(p_departure_id));

	p_delivery_id := delivery_id;
	WSH_UTIL.Write_Log('delivery_id = ' || to_char(p_delivery_id));

	p_pick_slip_rule_id := pick_slip_rule_id;
	WSH_UTIL.Write_Log('pick_slip_rule_id = ' || to_char(p_pick_slip_rule_id));

	p_release_seq_rule_id := release_seq_rule_id;
	WSH_UTIL.Write_Log('release_seq_rule_id = ' || to_char(p_release_seq_rule_id));

	p_report_set_id := report_set_id;
	WSH_UTIL.Write_Log('report_set_id = ' || to_char(p_report_set_id));

	p_include_planned_lines := include_planned_lines;
	WSH_UTIL.Write_Log('include_planned_lines = ' || p_include_planned_lines);

	p_partial_allowed_flag := partial_allowed_flag;
	WSH_UTIL.Write_Log('partial_allowed_flag = ' || p_partial_allowed_flag);

	WSH_UTIL.Write_Log('autocreate_delivery_flag = ' || autocreate_deliveries);

	WSH_UTIL.Write_Log('order_line_id = ' || order_line_id);

	--
	-- Validating order_line_id
	--

	IF order_line_id <> 0 THEN

	  OPEN	get_line_info(order_line_id);
	  FETCH	get_line_info
	  INTO	v_header_id,
		v_parent_line_id;

	  IF get_line_info%NOTFOUND THEN
	    WSH_UTIL.Write_Log('Order Line ID ' || to_char(order_line_id) || 'does not exist');
	    RETURN FAILURE;
	  END IF;

	  IF v_header_id <> header_id THEN
	    WSH_UTIL.Write_Log('Order Line ID ' || to_char(order_line_id) || 'does not belong to');
	    WSH_UTIL.Write_Log('Order Header ID ' || to_char(header_id));
	    RETURN FAILURE;
	  END IF;

	  IF v_parent_line_id <> -1 THEN
	    WSH_UTIL.Write_Log('Order Line ID ' || to_char(order_line_id) || 'is not a top model line');
	    RETURN FAILURE;
	  END IF;

	  IF get_line_info%ISOPEN THEN
	    CLOSE       get_line_info;
	  END IF;

	END IF;

	--
	-- If warehouse id is NULL (-1), must error out here since Pick Release
	-- is warehouse specific.
	--
	IF p_warehouse_id = -1 THEN
	  WSH_UTIL.Write_Log('Warehouse is not available for this batch.');
	  WSH_UTIL.Write_Log('Cannot release batch.');
	  RETURN FAILURE;
	END IF;

	WSH_UTIL.Write_Log('Fetching release sequence rule information for the batch');

	-- fetch release sequence rule parameters
	OPEN	rel_seq_rule(release_seq_rule_id);
	FETCH	rel_seq_rule
	INTO	release_seq_rule_name,
		order_number_priority,
		order_number_sort,
		invoice_value_priority,
		invoice_value_sort,
		schedule_date_priority,
		schedule_date_sort,
		shipment_pri_priority,
		shipment_pri_sort,
		departure_priority,
		departure_sort;

	-- handle release sequence rule does not exist
	IF rel_seq_rule%NOTFOUND THEN
	  WSH_UTIL.Write_Log('Release sequence rule ID ' || to_char(release_seq_rule_id) || ' does not exist.');
	  RETURN FAILURE;
	END IF;
	IF rel_seq_rule%ISOPEN THEN
	  CLOSE rel_seq_rule;
	END IF;

	-- initialize the release sequence rule parameters
	i := 1;
	IF (invoice_value_priority <> -1) THEN
	   use_order_header := TRUE;
	   ordered_rsr(i).attribute := C_INVOICE_VALUE;
	   ordered_rsr(i).attribute_name := 'INVOICE_VALUE';
	   -- initialize the invoice_value_flag to be used as part
	   -- of building the select statement
	   invoice_value_flag := 'Y';
	   ordered_rsr(i).priority := invoice_value_priority;
	   ordered_rsr(i).sort_order := invoice_value_sort;
	   i := i + 1;
	END IF;
	IF (order_number_priority <> -1) THEN
	   use_order_header := TRUE;
	   ordered_rsr(i).attribute := C_ORDER_NUMBER;
	   ordered_rsr(i).attribute_name := 'ORDER_NUMBER';
	   ordered_rsr(i).priority := order_number_priority;
	   ordered_rsr(i).sort_order := order_number_sort;
	   i := i + 1;
	END IF;
	IF (schedule_date_priority <> -1) THEN
	   ordered_rsr(i).attribute := C_SCHEDULE_DATE;
	   ordered_rsr(i).attribute_name := 'SCHEDULE_DATE';
	   ordered_rsr(i).priority := schedule_date_priority;
	   ordered_rsr(i).sort_order := schedule_date_sort;
	   i := i + 1;
	END IF;
	IF (departure_priority <> -1) THEN
	   ordered_rsr(i).attribute := C_DEPARTURE;
	   ordered_rsr(i).attribute_name := 'DEPARTURE';
	   ordered_rsr(i).priority := departure_priority;
	   ordered_rsr(i).sort_order := departure_sort;
	   i := i + 1;
	END IF;
	IF (shipment_pri_priority <> -1) THEN
	   ordered_rsr(i).attribute := C_SHIPMENT_PRIORITY;
	   ordered_rsr(i).attribute_name := 'SHIPMENT_PRIORITY';
	   ordered_rsr(i).priority := shipment_pri_priority;
	   ordered_rsr(i).sort_order := shipment_pri_sort;
	   i := i + 1;
	END IF;
	total_release_criteria := i - 1;

	-- sort the table for release sequence rule according to priority
	FOR i IN 1..total_release_criteria LOOP
	   FOR j IN i+1..total_release_criteria LOOP
	      IF (ordered_rsr(j).priority < ordered_rsr(i).priority) THEN
		 temp_rsr := ordered_rsr(j);
		 ordered_rsr(j) := ordered_rsr(i);
		 ordered_rsr(i) := temp_rsr;
	      END IF;
	   END LOOP;
	END LOOP;

	-- determine the most significant release sequence rule attribute
	primary_rsr := ordered_rsr(1).attribute_name;
	WSH_UTIL.Write_Log('Primary release rule is ' || primary_rsr);

	-- print release sequence rule information for debugging purposes
	FOR i IN 1..total_release_criteria LOOP
	   WSH_UTIL.Write_Log('attribute = ' || ordered_rsr(i).attribute_name || ' ' ||
				    'priority = ' || to_char(ordered_rsr(i).priority) || ' ' ||
				    'sort = ' || ordered_rsr(i).sort_order );
	END LOOP;

	WSH_UTIL.Write_Log('Determining if order number is in grouping rule...');
	OPEN order_ps_group(pick_slip_rule_id);
	FETCH order_ps_group
        INTO  use_order_ps;
	IF order_ps_group%NOTFOUND THEN
	  use_order_ps := 'N';
	END IF;
	IF order_ps_group%ISOPEN THEN
	  CLOSE order_ps_group;
	END IF;

	WSH_UTIL.Write_Log('Determining print pick slip parameter...');

        -- Use warehouse_id and not org_id, as the Shipping Parameters table
        -- is Warehouse (i.e. Organization ID) specific, and not specific
        -- to any Operating Unit/Org

	OPEN ps_mode_param(warehouse_id);
	FETCH ps_mode_param INTO print_ps_mode_param;
        IF ps_mode_param%NOTFOUND THEN
	  print_ps_mode_param := 'E';
	END IF;
	IF ps_mode_param%ISOPEN THEN
	  CLOSE ps_mode_param;
	END IF;

	IF ((ordered_rsr(1).attribute IN (C_INVOICE_VALUE, C_ORDER_NUMBER))
	    AND (print_ps_mode_param = 'I') AND (use_order_ps = 'Y')) THEN
	  print_ps_mode := IMMEDIATE_PRINT_PS;
	  WSH_UTIL.Write_Log('Print Pick slip mode is Immediate');
	ELSE
	  print_ps_mode := DEFERRED_PRINT_PS;
	  WSH_UTIL.Write_Log('Print Pick slip mode is Deferred');
	END IF;

	p_print_ps_mode := print_ps_mode;

	WSH_UTIL.Write_Log('Updating request id for batch');

	-- Update picking batch setting request id and other who parameters

        -- Use the parameters passed to the Init Function, instead of using the
	-- column names in the = conditions of the SQL. That is use
	-- p_user_id , p_program_id , p_request_id , p_login_id and p_batch_id and p_application_id

	UPDATE SO_PICKING_BATCHES_ALL
        SET REQUEST_ID = p_request_id,
        PROGRAM_APPLICATION_ID = p_application_id,
        PROGRAM_ID = p_program_id,
        PROGRAM_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = p_user_id,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = p_login_id
            WHERE BATCH_ID = p_batch_id
                AND (REQUEST_ID IS NULL OR REQUEST_ID = p_request_id);

	IF SQL%NOTFOUND THEN
	  WSH_UTIL.Write_Log('Picking Batch ' || to_char(p_batch_id) || ' does not exist ');
	  WSH_UTIL.Write_Log('or another pick release request has already released this batch');
	END IF;

	-- package WSH_PR_PICKING_SESSION has been initialized
	initialized := TRUE;

        RETURN SUCCESS;

	EXCEPTION
	  -- handle unable to lock situation
	  WHEN record_locked THEN
	    WSH_UTIL.Write_Log('Could not lock Batch ID ' || to_char(p_batch_id) || ' for update.');
	    RETURN FAILURE;

	  -- handle other errors
	  WHEN OTHERS THEN
	    IF get_lock_batch%ISOPEN THEN
	      CLOSE get_lock_batch;
	    END IF;
	    IF get_line_info%ISOPEN THEN
	      CLOSE     get_line_info;
	    END IF;
	    IF rel_seq_rule%ISOPEN THEN
	      CLOSE rel_seq_rule;
	    END IF;
	    IF order_ps_group%ISOPEN THEN
	      CLOSE order_ps_group;
	    END IF;
	    IF ps_mode_param%ISOPEN THEN
	      CLOSE ps_mode_param;
	    END IF;

	    WSH_UTIL.Default_Handler('WSH_PR_PICKING_SESSION.Init','');
	    RETURN FAILURE;

  END Init;


  --
  -- Name
  --   FUNCTION SRS_Picking_Batch
  --
  -- Purpose
  --   This function inserts a picking batch for SRS
  --
  -- Arguments
  --
  -- Return Values
  --  -1 => Failure
  --   0 => Success
  --
  -- Notes
  --

  FUNCTION SRS_Picking_Batch (
                   p_user_id			IN	BINARY_INTEGER,
                   p_login_id			IN	BINARY_INTEGER,
		   p_batch_prefix		IN	VARCHAR2,
		   p_new_batch_id		IN OUT	BINARY_INTEGER,
		   p_rule_name			IN	VARCHAR2,
		   p_doc_set			IN	VARCHAR2
  )
  RETURN BINARY_INTEGER IS

    CURSOR  doc_set(x_doc_set_id IN BINARY_INTEGER) IS
    SELECT  COUNT(*)
    FROM    SO_REPORT_SETS
    WHERE   REPORT_SET_ID = x_doc_set_id
    AND     SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
    AND     NVL(END_DATE_ACTIVE, SYSDATE+1);

    CURSOR  pick_rule(x_rule_name IN VARCHAR2) IS
    SELECT  COUNT(*)
    FROM    SO_PICKING_RULES
    WHERE   PICKING_RULE = x_rule_name
    AND     SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
    AND     NVL(END_DATE_ACTIVE, SYSDATE+1);

    CURSOR  get_default_psr(x_rule_name IN VARCHAR2) IS
    SELECT  par.pick_slip_rule_id
    FROM    WSH_PARAMETERS par,
            SO_PICKING_RULES rules
    WHERE   rules.picking_rule = x_rule_name
    AND     rules.warehouse_id = par.organization_id;

    CURSOR  get_default_rsr(x_rule_name IN VARCHAR2) IS
    SELECT  par.release_seq_rule_id
    FROM    WSH_PARAMETERS par,
            SO_PICKING_RULES rules
    WHERE   rules.picking_rule = x_rule_name
    AND     rules.warehouse_id = par.organization_id;

    x_batch_name	VARCHAR2(30);
    x_batch_id		BINARY_INTEGER;
    count_temp		BINARY_INTEGER;
    default_psr		NUMBER;
    default_rsr		NUMBER;

    -- Declared these variables for Fetching Operating Org
    operating_org       NUMBER;
    org_id_char1        VARCHAR2(30);
    org_found_flag      BOOLEAN;

  BEGIN

    -- Fetch the current Operating Org . If no operating org was returned by the function below
    -- indicated by org_found_flag = FALSE, then we set the operating org to NULL , otherwise to its
    -- fetched value.
    FND_PROFILE.GET_SPECIFIC( 'ORG_ID' , NULL , NULL , NULL , org_id_char1 , org_found_flag );
    IF org_found_flag = TRUE THEN
      operating_org := to_number(org_id_char1);
    ELSE
      operating_org := NULL;
    END IF;

    -- Validate Document Set
    IF p_doc_set IS NULL THEN
      WSH_UTIL.Write_Log('No Document Set specified');
    ELSE
      OPEN doc_set(to_number(p_doc_set));
      FETCH doc_set INTO count_temp;
      IF doc_set%NOTFOUND THEN
        WSH_UTIL.Write_Log('The document set ' || p_doc_set || ' is not in valid period');
      ELSE
        WSH_UTIL.Write_Log('The document set is valid');
      END IF;
    END IF;

    -- Validate Picking Rule

    OPEN pick_rule(p_rule_name);
    FETCH pick_rule INTO count_temp;
    IF pick_rule%NOTFOUND THEN
      WSH_UTIL.Write_Log('The picking rule '|| p_rule_name ||
			 ' does not exist or has expired');
      RETURN FAILURE;
    END IF;

    -- Get default Pick Slip Grouping Rule and Release
    -- Sequence Rule for warehouse
    OPEN get_default_psr(p_rule_name);
    FETCH get_default_psr INTO default_psr;
    IF get_default_psr%NOTFOUND THEN
      default_psr := NULL;
    END IF;

    OPEN get_default_rsr(p_rule_name);
    FETCH get_default_rsr INTO default_rsr;
    IF get_default_rsr%NOTFOUND THEN
      default_rsr := NULL;
    END IF;

    -- Create a unique picking batch name

    WHILE TRUE LOOP
      SELECT SO_PICKING_BATCHES_S.NEXTVAL
      INTO   x_batch_id
      FROM DUAL;

      p_new_batch_id := x_batch_id;

      IF p_batch_prefix IS NULL THEN
        x_batch_name := to_char(x_batch_id);
      ELSE
        x_batch_name := p_batch_prefix || '-' || to_char(x_batch_id);
      END IF;

      -- Check if batch already exists with this name
      WSH_UTIL.Write_Log('Checking batch name ' || x_batch_name);
      SELECT  COUNT(*)
      INTO    count_temp
      FROM    SO_PICKING_BATCHES_ALL
      WHERE   NAME = x_batch_name;

      IF count_temp = 0 THEN
        EXIT;
      END IF;

    END LOOP;

    -- Insert the new picking batch

    INSERT INTO SO_PICKING_BATCHES_ALL
       (BATCH_ID,
	CREATION_DATE,
	CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        NAME,
        PRINT_FLAG,
        BACKORDERS_ONLY_FLAG,
        EXISTING_RSVS_ONLY_FLAG,
        SHIPMENT_PRIORITY_CODE,
        HEADER_ID,
        ORDER_TYPE_ID,
        WAREHOUSE_ID,
        CUSTOMER_ID,
        SITE_USE_ID,
        SHIP_METHOD_CODE,
        SUBINVENTORY,
        SHIP_SET_NUMBER,
        INVENTORY_ITEM_ID,
        DATE_REQUESTED_FROM,
        DATE_REQUESTED_TO,
        SCHEDULED_SHIPMENT_DATE_FROM,
        SCHEDULED_SHIPMENT_DATE_TO,
	PICK_SLIP_RULE_ID,
	RELEASE_SEQ_RULE_ID,
	PARTIAL_ALLOWED_FLAG,
	INCLUDE_PLANNED_LINES,
        AUTOCREATE_DELIVERY_FLAG,
	ORG_ID)
    SELECT x_batch_id,
           SYSDATE,
           p_user_id,
           SYSDATE,
           p_user_id,
           p_login_id,
           x_batch_name,
	   decode(p_doc_set, '-1', NULL, p_doc_set),
           BACKORDERS_ONLY_FLAG,
           NVL(EXISTING_RSVS_ONLY_FLAG, 'N'),
           SHIPMENT_PRIORITY_CODE,
           HEADER_ID,
           ORDER_TYPE_ID,
           WAREHOUSE_ID,
           CUSTOMER_ID,
           SITE_USE_ID,
           SHIP_METHOD_CODE,
           SUBINVENTORY,
           SHIP_SET_NUMBER,
           INVENTORY_ITEM_ID,
           DECODE(DATE_REQUESTED_FROM, TO_DATE (1,'J'), TRUNC(SYSDATE),
                  DATE_REQUESTED_FROM),
           DECODE(DATE_REQUESTED_TO, TO_DATE (1,'J'), TRUNC(SYSDATE),
                  DATE_REQUESTED_TO),
           DECODE(SCHEDULED_SHIPMENT_DATE_FROM,TO_DATE (1,'J'), TRUNC(SYSDATE),
                  SCHEDULED_SHIPMENT_DATE_FROM),
           DECODE(SCHEDULED_SHIPMENT_DATE_TO,TO_DATE (1,'J'), TRUNC(SYSDATE),
                  SCHEDULED_SHIPMENT_DATE_TO),
	   NVL(PICK_SLIP_RULE_ID, default_psr),
	   NVL(RELEASE_SEQ_RULE_SET_ID, default_rsr),
	   PARTIAL_ALLOWED_FLAG,
	   INCLUDE_PLANNED_LINES_FLAG,
           AUTOCREATE_DELIVERY_FLAG,
	   operating_org   -- Insert Operating Org
    FROM   SO_PICKING_RULES
    WHERE  PICKING_RULE = p_rule_name;

    WSH_UTIL.Write_Log('Inserted batch name ' || x_batch_name
                          || ' with batch_id ' ||
                       to_char(p_new_batch_id));

    RETURN SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      WSH_UTIL.Default_Handler('WSH_PR_PICKING_SESSION.Launc_Doc_Set','');
      RETURN FAILURE;

  END SRS_Picking_Batch;


  --
  -- Name
  --   FUNCTION Unreleased_Line_Details
  --
  -- Purpose
  --   This function creates the unreleased line details SQL
  --   statement
  --
  -- Return Values
  --  -1 => Failure
  --   0 => Success
  --
  -- Notes
  --

  FUNCTION Unreleased_Line_Details
  RETURN BINARY_INTEGER IS

	cs		BINARY_INTEGER;

  BEGIN
	-- handle uninitialized package errors here
	IF initialized = FALSE THEN
	   WSH_UTIL.Write_Log('The package must be initialized before use');
	   RETURN FAILURE;
	END IF;

	IF unreleased_SQL IS NULL THEN
	  cs := Construct_SQL('UNRELEASED');
	  IF cs = FAILURE THEN
	    RETURN FAILURE;
	  END IF;
	  RETURN SUCCESS;
	END IF;

  END Unreleased_Line_Details;


  --
  -- Name
  --   FUNCTION Backordered_Line_Details
  --
  -- Purpose
  --   This function creates the backordered line details SQL
  --   statement
  --
  -- Return Values
  --  -1 => Failure
  --   0 => Success
  --
  -- Notes
  --

  FUNCTION Backordered_Line_Details
  RETURN BINARY_INTEGER IS

	cs		BINARY_INTEGER;

  BEGIN
	-- handle uninitialized package errors here
	IF initialized = FALSE THEN
	   WSH_UTIL.Write_Log('The package must be initialized before use');
	   RETURN FAILURE;
	END IF;

	IF backordered_SQL IS NULL THEN
	  cs := Construct_SQL('BACKORDERED');
	  IF cs = FAILURE THEN
	    RETURN FAILURE;
	  END IF;
	  RETURN SUCCESS;
	END IF;

  END Backordered_Line_Details;


  --
  -- Name
  --   FUNCTION Sync_Details
  --
  -- Purpose
  --   This function creates the SQL statement to fetch
  --   BOM exploded/demand synchronized line details
  --
  -- Return Values
  --  -1 => Failure
  --   0 => Success
  --
  -- Notes
  --

  FUNCTION Sync_Details
  RETURN BINARY_INTEGER IS

	cs		BINARY_INTEGER;

  BEGIN
	-- handle uninitialized package errors here
	IF initialized = FALSE THEN
	   WSH_UTIL.Write_Log('The package must be initialized before use');
	   RETURN FAILURE;
	END IF;

	cs := Construct_SQL('SYNC');
	IF cs = FAILURE THEN
	  RETURN FAILURE;
	END IF;
	RETURN SUCCESS;

  END Sync_Details;


  --
  -- Name
  --   FUNCTION Non_Shippable_Lines
  --
  -- Purpose
  --   This function creates the non-shippable lines SQL
  --   statement
  --
  -- Return Values
  --  -1 => Failure
  --   0 => Success
  --
  -- Notes
  --

  FUNCTION Non_Shippable_Lines
  RETURN BINARY_INTEGER IS

	cs		BINARY_INTEGER;

  BEGIN
	-- handle uninitialized package errors here
	IF initialized = FALSE THEN
	   WSH_UTIL.Write_Log('The package must be initialized before use');
	   RETURN FAILURE;
	END IF;

	cs := Construct_SQL('NON_SHIPPABLE');
	IF cs = FAILURE THEN
	  RETURN FAILURE;
	END IF;

	RETURN SUCCESS;

  END Non_Shippable_Lines;

  --
  -- Name
  --   FUNCTION Construct_SQL
  --
  -- Purpose
  --   This function creates the actual SQL statement based on a
  --   parameter passed to it which determines if it is UNRELEASED,
  --   BACKORDERED or NON_SHIPPABLE.
  --
  -- Arguments
  --   p_sql_type is determine what kind of SQL to create
  --
  -- Notes
  --

  FUNCTION Construct_SQL(
		p_sql_type		IN	VARCHAR2
  )
  RETURN BINARY_INTEGER IS

	cs		BINARY_INTEGER;
	i		BINARY_INTEGER;

  BEGIN
	-- Create unreleased SQL statement
	IF (p_sql_type = 'UNRELEASED') THEN
	  unreleased_SQL := '';
	  Process_Buffer('u', ' SELECT ');
	  Process_Buffer('u', ' L.LINE_ID, ');
	  Process_Buffer('u', ' H.HEADER_ID, ');
	  Process_Buffer('u', ' NVL(H.ORG_ID, -3114), ');
	  Process_Buffer('u', ' L.ATO_FLAG, ');
	  Process_Buffer('u', ' LD.LINE_DETAIL_ID, ');
	  Process_Buffer('u', ' L.SHIP_MODEL_COMPLETE_FLAG, ');
	  Process_Buffer('u', ' NVL(L.SHIP_SET_NUMBER, -9), ');
	  Process_Buffer('u', ' NVL(L.PARENT_LINE_ID, 0), ');
	  Process_Buffer('u', ' NVL(LD.WAREHOUSE_ID, -1), ');
	  Process_Buffer('u', ' NVL(NVL(L.SHIP_TO_SITE_USE_ID, H.SHIP_TO_SITE_USE_ID), -1), ');
	  Process_Buffer('u', ' NVL(NVL(L.SHIP_TO_CONTACT_ID, H.SHIP_TO_CONTACT_ID), -1), ');
	  Process_Buffer('u', ' NVL(L.SHIP_METHOD_CODE, H.SHIP_METHOD_CODE), ');
	  Process_Buffer('u', ' NVL(L.SHIPMENT_PRIORITY_CODE, H.SHIPMENT_PRIORITY_CODE), ');
	  Process_Buffer('u', ' NVL(LD.DEPARTURE_ID, -1), ');
	  Process_Buffer('u', ' NVL(LD.DELIVERY_ID, -1), ');
	  Process_Buffer('u', ' L.ITEM_TYPE_CODE, ');
	  Process_Buffer('u', ' TO_NUMBER(TO_CHAR( LD.SCHEDULE_DATE, ''J'' )), ');
	  Process_Buffer('u', ' L.ORDERED_QUANTITY, ');
	  Process_Buffer('u', ' L.CANCELLED_QUANTITY, ');
	  Process_Buffer('u', ' L.INVENTORY_ITEM_ID, ');
	  Process_Buffer('u', ' LD.INVENTORY_ITEM_ID, ');
	  Process_Buffer('u', ' NVL(LD.CUSTOMER_ITEM_ID, -1), ');
	  Process_Buffer('u', ' LD.DEP_PLAN_REQUIRED_FLAG, ');
	  Process_Buffer('u', ' NVL(L.SHIPMENT_SCHEDULE_LINE_ID,0), ');
	  Process_Buffer('u', ' L.UNIT_CODE, ');
	  Process_Buffer('u', ' L.LINE_TYPE_CODE, ');
	  Process_Buffer('u', ' L.COMPONENT_CODE, ');
	  Process_Buffer('u', ' NVL(TO_CHAR(L.STANDARD_COMPONENT_FREEZE_DATE,''YYYY/MM/DD HH24:MI''),''''), ');
	  Process_Buffer('u', ' H.ORDER_NUMBER, ');
	  Process_Buffer('u', ' H.ORDER_TYPE_ID, ');
	  Process_Buffer('u', ' H.CUSTOMER_ID, ');
	  Process_Buffer('u', ' H.INVOICE_TO_SITE_USE_ID, ');
	  Process_Buffer('u', ' DECODE( DP.PLANNED_DEPARTURE_DATE, NULL, TO_NUMBER( ');
	  Process_Buffer('u', ' 	TO_CHAR(DP.PLANNED_DEPARTURE_DATE,''J'' ) ), 9999999 ), ');
	  Process_Buffer('u', ' DECODE( DP.PLANNED_DEPARTURE_DATE, NULL, TO_NUMBER( ');
	  Process_Buffer('u', '         TO_CHAR(DP.PLANNED_DEPARTURE_DATE,''SSSSS'')), 0), ');
	  Process_Buffer('u', ' NVL(LD.MASTER_CONTAINER_ITEM_ID, -1), ');
	  Process_Buffer('u', ' NVL(LD.DETAIL_CONTAINER_ITEM_ID, -1), ');
	  Process_Buffer('u', ' NVL(LD.LOAD_SEQ_NUMBER, -1) , ');
	  IF invoice_value_flag = 'Y' THEN
	    Process_Buffer('u',' WSH_PR_CUSTOM.OUTSTANDING_ORDER_VALUE(H.HEADER_ID) ');
	  ELSE
	    Process_Buffer('u',' -1');
	  END IF;
	  Process_Buffer('u', ' FROM	WSH_DELIVERIES DL, ');
	  Process_Buffer('u', '         WSH_DEPARTURES DP, ');
	  Process_Buffer('u', ' 	SO_LINE_DETAILS LD, ');
	  Process_Buffer('u', ' 	SO_HEADERS_ALL H, ');
	  IF (header_id <> 0 OR departure_id <> 0 OR order_line_id <>0) THEN
	    Process_Buffer('u', ' 	SO_LINES_ALL L ');
	  ELSE
	    -- inline view to use index on S2. This is for performance improvement.
	    Process_Buffer('u', ' 	(SELECT * FROM SO_LINES_ALL SL');
	    Process_Buffer('u', ' 	    WHERE SL.S2 IN (18,5) AND ');
	    Process_Buffer('u', ' 	    ROWNUM > 0) L ');
	  END IF;
	  Process_Buffer('u', ' WHERE L.HEADER_ID = H.HEADER_ID ');
	  Process_Buffer('u', ' AND   L.LINE_ID = LD.LINE_ID ');
	  Process_Buffer('u', ' AND   LD.DEPARTURE_ID = DP.DEPARTURE_ID (+)  ');
	  Process_Buffer('u', ' AND   LD.DELIVERY_ID = DL.DELIVERY_ID (+) ');
	  Process_Buffer('u', ' AND   L.LINE_TYPE_CODE IN (''REGULAR'',''DETAIL'') ');
	  Process_Buffer('u', ' AND   L.SOURCE_TYPE_CODE = ''INTERNAL'' ');
	  Process_Buffer('u', ' AND   L.ITEM_TYPE_CODE IN ');
	  Process_Buffer('u', '        (''KIT'',''MODEL'',''CLASS'',''STANDARD'') ');
	  Process_Buffer('u', ' AND NOT ((L.ITEM_TYPE_CODE = ''STANDARD'') AND ');
	  Process_Buffer('u', '	         (NVL(L.PARENT_LINE_ID,-9) = -9) AND ');
	  Process_Buffer('u', '          (NVL(L.ATO_FLAG,''N'') = ''N'') AND ');
	  Process_Buffer('u', '	         (LD.SHIPPABLE_FLAG || '''' = ''N'')) ');
	  Process_Buffer('u', ' AND    NVL(L.CANCELLED_QUANTITY,0) < L.ORDERED_QUANTITY ');
	  Process_Buffer('u', ' AND    L.ATO_LINE_ID IS NULL ');
	  Process_Buffer('u', ' AND    L.OPEN_FLAG || '''' = ''Y'' ');
	  Process_Buffer('u', ' AND    H.OPEN_FLAG || '''' = ''Y'' ');
	  Process_Buffer('u', ' AND    LD.RELEASED_FLAG || '''' = ''N'' ');
	  Process_Buffer('u', ' AND    LD.SCHEDULE_DATE IS NOT NULL ');

	  Process_Buffer('u', ' AND    ((L.STANDARD_COMPONENT_FREEZE_DATE IS NOT NULL ');
	  Process_Buffer('u', '          AND   DECODE(L.ATO_FLAG,''N'', ');
	  Process_Buffer('u', '                 LD.SHIPPABLE_FLAG,''Y'') || '''' = ''Y'') ');
	  Process_Buffer('u', '          OR ');
	  Process_Buffer('u', '         (L.STANDARD_COMPONENT_FREEZE_DATE IS NULL ');
	  Process_Buffer('u', '          AND  (LD.INCLUDED_ITEM_FLAG || '''' = ''N'' ');
	  Process_Buffer('u', '                OR   LD.SHIPPABLE_FLAG || '''' = ''Y''))) ');

	  IF (header_id <> 0 OR departure_id <> 0 OR order_line_id <> 0) THEN
	    Process_Buffer('u', ' AND    L.S2+0 IN (18, 5) ');
	  END IF;

	  -- Following conditions use bind variables
	  -- The columns which have indexes are included in the SQL statement conditionally
	  -- This is done so that the index will be used

	  IF (header_id <> 0 AND order_line_id = 0) THEN
	    Process_Buffer('u', ' AND H.HEADER_ID = :X_header_id ' || ' ');
	  ELSIF (header_id <> 0 AND order_line_id <> 0) THEN
	    Process_Buffer('u', ' AND H.HEADER_ID + 0 = :X_header_id ' || ' ');
	  END IF;

	  Process_Buffer('u', ' AND (H.ORDER_TYPE_ID = :X_order_type_id OR :X_order_type_id = 0) ' || ' ');

	  IF (customer_id <> 0) THEN
	    Process_Buffer('u', ' AND H.CUSTOMER_ID = :X_customer_id ' || ' ');
	  END IF;

	  IF (order_line_id <> 0) THEN
	    Process_Buffer('u', ' AND L.LINE_ID = :X_order_line_id ' || ' ');
	   END IF;

	  Process_Buffer('u', ' AND (L.SHIP_SET_NUMBER = :X_ship_set_number OR :X_ship_set_number = 0) ' || ' ');

	  Process_Buffer('u', ' AND (NVL(L.SHIP_TO_SITE_USE_ID,H.SHIP_TO_SITE_USE_ID) = :X_ship_site_use_id ' || ' ');
	  Process_Buffer('u', ' 	OR  :X_ship_site_use_id = 0) ' || ' ');

	  Process_Buffer('u', ' AND (NVL(L.SHIP_METHOD_CODE,H.SHIP_METHOD_CODE) =  :X_ship_method_code ' || ' ');
	  Process_Buffer('u', ' 	OR  :X_ship_method_code IS NULL) ' || ' ');

	  -- Make sure that lines to be shipped out of a particular warehouse is picked up
	  Process_Buffer('u', ' AND (LD.WAREHOUSE_ID = :X_warehouse_id OR :X_warehouse_id = -1) ' ||  ' ');

	  Process_Buffer('u', ' AND (LD.SUBINVENTORY = :X_subinventory OR :X_subinventory IS NULL)' || ' ' );

	  Process_Buffer('u', ' AND (L.SHIPMENT_PRIORITY_CODE = :X_shipment_priority ' || ' ');
	  Process_Buffer('u', ' 	OR :X_shipment_priority IS NULL) ' || ' ');

	  Process_Buffer('u', ' AND (NVL(L.DATE_REQUESTED_CURRENT, H.DATE_REQUESTED_CURRENT) >= ');
	  Process_Buffer('u', ' 	to_date(:X_from_request_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_from_request_date IS NULL) ' || ' ');

	  Process_Buffer('u', ' AND (NVL(L.DATE_REQUESTED_CURRENT, H.DATE_REQUESTED_CURRENT) <= ');
	  Process_Buffer('u', ' 	to_date(:X_to_request_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_to_request_date IS NULL) ' || ' ');

	  Process_Buffer('u', ' AND (LD.SCHEDULE_DATE >= ');
	  Process_Buffer('u', ' 	to_date(:X_from_sched_ship_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_from_sched_ship_date IS NULL) ' || ' ');

	  Process_Buffer('u', ' AND (LD.SCHEDULE_DATE <= ');
	  Process_Buffer('u', ' 	to_date(:X_to_sched_ship_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_to_sched_ship_date IS NULL) ' || ' ');

	  -- if existing_rsvs_only_flag is not 'Y', the following condition always returns true
	  Process_Buffer('u', ' AND ((LD.RESERVABLE_FLAG = ''Y'' ');
	  Process_Buffer('u', ' 	AND LD.SCHEDULE_STATUS_CODE IN ( ''RESERVED'', ''SUPPLY RESERVED'' )) ');
	  Process_Buffer('u', ' 	 OR NVL(:X_existing_rsvs_only_flag,''X'') <> ''Y'') ');

	  Process_Buffer('u', ' AND (L.INVENTORY_ITEM_ID + 0 = :X_inventory_item_id  ');
	  Process_Buffer('u', ' 	OR :X_inventory_item_id = 0) ' || ' ');

	  Process_Buffer('u', ' AND  (L.ATO_FLAG = ''N'' OR :X_reservations <> ''N'') ' || ' ');

	  -- Handling departures and deliveries

	  IF (departure_id <> 0) THEN
	    Process_Buffer('u', ' AND LD.DEPARTURE_ID = :X_departure_id ' || ' ');
	    Process_Buffer('u', ' AND NVL(DL.STATUS_CODE, ''XX'') = ''PL'' ');
	  END IF;

	  IF (delivery_id <> 0) THEN
	    Process_Buffer('u', ' AND LD.DELIVERY_ID = :X_delivery_id ' || ' ');
	  END IF;

	  Process_Buffer('u', ' AND ((NVL(LD.DEPARTURE_ID, -99) = -99 ');
	  Process_Buffer('u', ' 	AND NVL(LD.DELIVERY_ID, -99) = -99) ');
	  Process_Buffer('u', ' 	OR :X_include_planned_lines <> ''N'' OR :X_departure_id <> 0) ');

	  Process_Buffer('u', ' AND (((NVL(LD.DEP_PLAN_REQUIRED_FLAG,''N'') = ''Y'') ');
	  Process_Buffer('u', ' 	AND NVL(DP.STATUS_CODE, ''XX'') = ''PL'') ');
	  Process_Buffer('u', ' 	OR  (NVL(LD.DEP_PLAN_REQUIRED_FLAG,''N'') = ''N'')) ');

	  -- Determine the order by clause
	  orderby_SQL := ' ORDER BY ';
	  WSH_UTIL.Write_Log(orderby_SQL);

	  FOR i IN 1..total_release_criteria LOOP
	    IF (ordered_rsr(i).attribute = C_INVOICE_VALUE) THEN
	      Process_Buffer('o', ' WSH_PR_CUSTOM.OUTSTANDING_ORDER_VALUE(H.HEADER_ID) ' || ordered_rsr(i).sort_order || ', ');
	      Process_Buffer('o',  ' H.HEADER_ID ASC ' || ', ');
	    ELSIF (ordered_rsr(i).attribute = C_ORDER_NUMBER) THEN
	      Process_Buffer('o', ' H.HEADER_ID ' || ordered_rsr(i).sort_order || ', ');
	    ELSIF (ordered_rsr(i).attribute = C_SCHEDULE_DATE) THEN
	      Process_Buffer('o', ' TO_NUMBER(TO_CHAR(LD.SCHEDULE_DATE,''J'')) ' || ordered_rsr(i).sort_order || ', ');
	    ELSIF (ordered_rsr(i).attribute = C_DEPARTURE) THEN
	      Process_Buffer('o',  ' NVL(DP.PLANNED_DEPARTURE_DATE, SYSDATE) ' || ordered_rsr(i).sort_order || ', ');
	    ELSIF (ordered_rsr(i).attribute = C_SHIPMENT_PRIORITY) THEN
	      Process_Buffer('o',  ' NVL(L.SHIPMENT_PRIORITY_CODE,H.SHIPMENT_PRIORITY_CODE) ' || ordered_rsr(i).sort_order || ', ');
	    END IF;
	  END LOOP;

	  -- Must add this for easy grouping of ship sets and smc components
	  IF use_order_header = FALSE THEN
	    Process_Buffer('o',  ' H.HEADER_ID, ');
	  END IF;
	  Process_Buffer('o',  ' NVL(L.SHIP_SET_NUMBER, 99999999), ');
	  Process_Buffer('o',  ' L.SHIP_MODEL_COMPLETE_FLAG DESC, ');
	  Process_Buffer('o',  ' NVL(L.PARENT_LINE_ID,L.LINE_ID), ');
	  Process_Buffer('o',  ' LD.WAREHOUSE_ID, ');
	  Process_Buffer('o',  ' NVL(L.SHIP_TO_SITE_USE_ID,  H.SHIP_TO_SITE_USE_ID), ');
	  Process_Buffer('o',  ' NVL(L.SHIP_METHOD_CODE, H.SHIP_METHOD_CODE) ');

	  unreleased_SQL := unreleased_SQL || orderby_SQL;

	ELSIF (p_sql_type = 'BACKORDERED') THEN

	  backordered_SQL := '';
	  Process_Buffer('b', ' SELECT ');
	  Process_Buffer('b', ' PL.PICKING_LINE_ID, ');
	  Process_Buffer('b', ' H.HEADER_ID, ');
	  Process_Buffer('b', ' NVL(H.ORG_ID, -3114), ');
	  Process_Buffer('b', ' L.ATO_FLAG, ');
	  Process_Buffer('b', ' PLD.PICKING_LINE_DETAIL_ID, ');
	  Process_Buffer('b', ' L.SHIP_MODEL_COMPLETE_FLAG, ');
	  Process_Buffer('b', ' NVL(L.SHIP_SET_NUMBER, -9), ');
	  Process_Buffer('b', ' NVL(L.PARENT_LINE_ID, 0), ');
	  Process_Buffer('b', ' NVL(PLD.WAREHOUSE_ID, NVL(PL.WAREHOUSE_ID, -1)), ');
	  Process_Buffer('b', ' NVL(NVL(NVL(PL.SHIP_TO_SITE_USE_ID, L.SHIP_TO_SITE_USE_ID), ');
	  Process_Buffer('b', ' H.SHIP_TO_SITE_USE_ID), -1), ');
	  Process_Buffer('b', ' NVL(NVL(NVL(PL.SHIP_TO_CONTACT_ID, L.SHIP_TO_CONTACT_ID), ');
	  Process_Buffer('b', ' H.SHIP_TO_CONTACT_ID), -1), ');
	  Process_Buffer('b', ' NVL(PL.SHIP_METHOD_CODE, L.SHIP_METHOD_CODE), ');
	  Process_Buffer('b', ' NVL(PL.SHIPMENT_PRIORITY_CODE, L.SHIPMENT_PRIORITY_CODE), ');
	  Process_Buffer('b', ' NVL(PLD.DEPARTURE_ID, -1), ');
	  Process_Buffer('b', ' NVL(PLD.DELIVERY_ID, -1), ');
	  Process_Buffer('b', ' L.ITEM_TYPE_CODE, ');
	  Process_Buffer('b', ' TO_NUMBER(TO_CHAR( PLD.SCHEDULE_DATE, ''J'' )), ');
	  Process_Buffer('b', ' PL.ORIGINAL_REQUESTED_QUANTITY, ');
	  Process_Buffer('b', ' PL.CANCELLED_QUANTITY, ');
	  Process_Buffer('b', ' L.INVENTORY_ITEM_ID, ');
	  Process_Buffer('b', ' PL.INVENTORY_ITEM_ID, ');
	  Process_Buffer('b', ' NVL(PL.CUSTOMER_ITEM_ID, -1), ');
	  Process_Buffer('b', ' PL.DEP_PLAN_REQUIRED_FLAG, ');
	  Process_Buffer('b', ' NVL(L.SHIPMENT_SCHEDULE_LINE_ID,0), ');
	  Process_Buffer('b', ' PL.UNIT_CODE, ');
	  Process_Buffer('b', ' L.LINE_TYPE_CODE, ');
	  Process_Buffer('b', ' L.COMPONENT_CODE, ');
	  Process_Buffer('b', ' NVL(TO_CHAR(L.STANDARD_COMPONENT_FREEZE_DATE,''YYYY/MM/DD HH24:MI''),''''), ');
	  Process_Buffer('b', ' H.ORDER_NUMBER, ');
	  Process_Buffer('b', ' H.ORDER_TYPE_ID, ');
	  Process_Buffer('b', ' H.CUSTOMER_ID, ');
	  Process_Buffer('b', ' H.INVOICE_TO_SITE_USE_ID, ');
	  Process_Buffer('b', ' DECODE( DP.PLANNED_DEPARTURE_DATE, NULL, TO_NUMBER( ');
	  Process_Buffer('b', ' 	TO_CHAR(DP.PLANNED_DEPARTURE_DATE,''J'' ) ), 9999999 ), ');
	  Process_Buffer('b', ' DECODE( DP.PLANNED_DEPARTURE_DATE, NULL, TO_NUMBER( ');
	  Process_Buffer('b', '         TO_CHAR(DP.PLANNED_DEPARTURE_DATE,''SSSSS'')), 0), ');
	  Process_Buffer('b', ' NVL(PLD.MASTER_CONTAINER_ITEM_ID, -1), ');
	  Process_Buffer('b', ' NVL(PLD.DETAIL_CONTAINER_ITEM_ID, -1), ');
	  Process_Buffer('b', ' NVL(PLD.LOAD_SEQ_NUMBER, -1), ');
	  IF invoice_value_flag = 'Y' THEN
	    Process_Buffer('b',' WSH_PR_CUSTOM.OUTSTANDING_ORDER_VALUE(H.HEADER_ID) ');
	  ELSE
	    Process_Buffer('b',' -1');
	  END IF;
	  Process_Buffer('b', ' FROM	WSH_DELIVERIES DL, ');
	  Process_Buffer('b', ' 	WSH_DEPARTURES DP, ');
	  Process_Buffer('b', ' 	SO_PICKING_LINE_DETAILS PLD, ');
	  IF (header_id <> 0 OR departure_id <> 0 OR order_line_id <> 0) THEN
	    Process_Buffer('b', ' 	SO_LINES_ALL L, ');
	  ELSE
	    -- inline view to use index on S3. This is for performance improvement.
	    Process_Buffer('b', ' 	(SELECT * FROM SO_LINES_ALL SL');
	    Process_Buffer('b', ' 	    WHERE SL.S3 IN (18,5) AND ');
	    Process_Buffer('b', ' 	    ROWNUM > 0) L, ');
	  END IF;
	  Process_Buffer('b', ' 	SO_HEADERS_ALL H, ');
	  Process_Buffer('b', ' 	SO_PICKING_LINES_ALL PL ');
	  Process_Buffer('b', ' WHERE PL.PICKING_HEADER_ID + 0 = 0 ');
	  Process_Buffer('b', ' AND   PL.ORDER_LINE_ID = L.LINE_ID ');
	  Process_Buffer('b', ' AND   PL.PICKING_LINE_ID = PLD.PICKING_LINE_ID ');
	  Process_Buffer('b', ' AND   L.HEADER_ID = H.HEADER_ID ');
	  Process_Buffer('b', ' AND   PLD.DEPARTURE_ID = DP.DEPARTURE_ID (+)  ');
	  Process_Buffer('b', ' AND   PLD.DELIVERY_ID = DL.DELIVERY_ID (+) ');
	  Process_Buffer('b', ' AND   L.LINE_TYPE_CODE IN (''REGULAR'',''DETAIL'') ');
	  Process_Buffer('b', ' AND   L.SOURCE_TYPE_CODE = ''INTERNAL'' ');
	  Process_Buffer('b', ' AND   NVL(PL.CANCELLED_QUANTITY,0) < PL.ORIGINAL_REQUESTED_QUANTITY ');
	  Process_Buffer('b', ' AND   L.ATO_LINE_ID IS NULL ');
	  Process_Buffer('b', ' AND   L.OPEN_FLAG || '''' = ''Y'' ');
	  Process_Buffer('b', ' AND   H.OPEN_FLAG || '''' = ''Y'' ');
	  Process_Buffer('b', ' AND   PLD.RELEASED_FLAG || '''' = ''N'' ');
	  Process_Buffer('b', ' AND   PLD.SCHEDULE_DATE IS NOT NULL ');

	  IF (header_id <> 0 OR departure_id <> 0 OR order_line_id <> 0) THEN
	    Process_Buffer('b', ' AND    L.S3+0 IN (18, 5) ');
	  END IF;

	  -- Following conditions use bind variables
	  -- The columns which have indexes are included in the SQL statement conditionally
	  -- This is done so that the index will be used

	  IF (header_id <> 0 AND order_line_id = 0) THEN
	    Process_Buffer('b', ' AND H.HEADER_ID = :X_header_id ' || ' ');
	  ELSIF (header_id <> 0 AND order_line_id <> 0) THEN
	    Process_Buffer('b', ' AND H.HEADER_ID+0 = :X_header_id ' || ' ');
	  END IF;

	  Process_Buffer('b', ' AND (H.ORDER_TYPE_ID = :X_order_type_id OR :X_order_type_id = 0) ' || ' ');

	  IF (customer_id <> 0) THEN
	    Process_Buffer('b', ' AND H.CUSTOMER_ID = :X_customer_id ' || ' ');
	  END IF;

	  IF (order_line_id <> 0) THEN
	    Process_Buffer('b', ' AND L.LINE_ID = :X_order_line_id ' || ' ');
	  END IF;

	  Process_Buffer('b', ' AND (L.SHIP_SET_NUMBER = :X_ship_set_number OR :X_ship_set_number = 0) ' || ' ');

	  Process_Buffer('b', ' AND (NVL(NVL(PL.SHIP_TO_SITE_USE_ID,L.SHIP_TO_SITE_USE_ID), ');
	  Process_Buffer('b', '         H.SHIP_TO_SITE_USE_ID) = :X_ship_site_use_id ' || ' ');
	  Process_Buffer('b', ' 	OR  :X_ship_site_use_id = 0) ' || ' ');

	  Process_Buffer('b', ' AND (NVL(NVL(PL.SHIP_METHOD_CODE,L.SHIP_METHOD_CODE), ');
	  Process_Buffer('b', '         H.SHIP_METHOD_CODE) =  :X_ship_method_code ' || ' ');
	  Process_Buffer('b', ' 	OR  :X_ship_method_code IS NULL) ' || ' ');

	  -- Make sure that lines to be shipped out of a particular warehouse is picked up
	  Process_Buffer('b', ' AND (PLD.WAREHOUSE_ID = :X_warehouse_id OR :X_warehouse_id = -1) ' ||  ' ');

	  Process_Buffer('b', ' AND (PLD.SUBINVENTORY = :X_subinventory OR :X_subinventory IS NULL)' || ' ' );

	  Process_Buffer('b', ' AND (NVL(PL.SHIPMENT_PRIORITY_CODE,L.SHIPMENT_PRIORITY_CODE) = ');
	  Process_Buffer('b', ' 	:X_shipment_priority OR :X_shipment_priority IS NULL) ' || ' ');

	  Process_Buffer('b', ' AND (NVL(L.DATE_REQUESTED_CURRENT, H.DATE_REQUESTED_CURRENT) >= ');
	  Process_Buffer('b', ' 	to_date(:X_from_request_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_from_request_date IS NULL) ' || ' ');

	  Process_Buffer('b', ' AND (NVL(L.DATE_REQUESTED_CURRENT, H.DATE_REQUESTED_CURRENT) <= ');
	  Process_Buffer('b', ' 	to_date(:X_to_request_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_to_request_date IS NULL) ' || ' ');

	  Process_Buffer('b', ' AND (PLD.SCHEDULE_DATE >= ');
	  Process_Buffer('b', ' 	to_date(:X_from_sched_ship_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_from_sched_ship_date IS NULL) ' || ' ');

	  Process_Buffer('b', ' AND (PLD.SCHEDULE_DATE <= ');
	  Process_Buffer('b', ' 	to_date(:X_to_sched_ship_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_to_sched_ship_date IS NULL) ' || ' ');

	  -- if X_existing_rsvs_only_flag is not 'Y', the following condition always returns true
	  Process_Buffer('b', ' AND ((PLD.RESERVABLE_FLAG = ''Y'' ');
	  Process_Buffer('b', ' 	AND PLD.SCHEDULE_STATUS_CODE IN ( ''RESERVED'', ''SUPPLY RESERVED'' )) ');
	  Process_Buffer('b', ' 	 OR NVL(:X_existing_rsvs_only_flag,''X'') <> ''Y'') ');

	  Process_Buffer('b', ' AND (PL.INVENTORY_ITEM_ID + 0 = :X_inventory_item_id  ');
	  Process_Buffer('b', ' 	OR :X_inventory_item_id = 0) ' || ' ');

	  Process_Buffer('b', ' AND  (L.ATO_FLAG = ''N'' OR :X_reservations <> ''N'') ' || ' ');

	  -- Handling departures and deliveries

	  IF (departure_id <> 0) THEN
	    Process_Buffer('b', ' AND PLD.DEPARTURE_ID = :X_departure_id ' || ' ');
	    Process_Buffer('b', ' AND NVL(DL.STATUS_CODE, ''XX'') = ''PL'' ');
	  END IF;

	  IF (delivery_id <> 0) THEN
	    Process_Buffer('b', ' AND PLD.DELIVERY_ID = :X_delivery_id ' || ' ');
	  END IF;

	  Process_Buffer('b', ' AND ((NVL(PLD.DEPARTURE_ID, -99) = -99 ');
	  Process_Buffer('b', ' 	AND NVL(PLD.DELIVERY_ID, -99) = -99) ');
	  Process_Buffer('b', ' 	OR :X_include_planned_lines <> ''N'' OR :X_departure_id <> 0) ');

	  Process_Buffer('b', ' AND (((NVL(PL.DEP_PLAN_REQUIRED_FLAG,''N'') = ''Y'') ');
	  Process_Buffer('b', '        AND NVL(DP.STATUS_CODE, ''XX'') = ''PL'') ');
	  Process_Buffer('b', '     OR (NVL(PL.DEP_PLAN_REQUIRED_FLAG,''N'') = ''N'')) ');

	  -- Determine the order by clause
	  orderby_SQL := ' ORDER BY ';
	  WSH_UTIL.Write_Log(orderby_SQL);

	  FOR i IN 1..total_release_criteria LOOP
	    IF (ordered_rsr(i).attribute = C_INVOICE_VALUE) THEN
	      Process_Buffer('o', ' WSH_PR_CUSTOM.OUTSTANDING_ORDER_VALUE(H.HEADER_ID) ' || ordered_rsr(i).sort_order || ', ');
	      Process_Buffer('o', ' H.HEADER_ID ASC ' || ', ');
	    ELSIF (ordered_rsr(i).attribute = C_ORDER_NUMBER) THEN
	      Process_Buffer('o', ' H.HEADER_ID ' || ordered_rsr(i).sort_order || ', ');
	    ELSIF (ordered_rsr(i).attribute = C_SCHEDULE_DATE) THEN
	      Process_Buffer('o', ' TO_NUMBER(TO_CHAR(PLD.SCHEDULE_DATE,''J'')) ' || ordered_rsr(i).sort_order || ', ');
	    ELSIF (ordered_rsr(i).attribute = C_DEPARTURE) THEN
	      Process_Buffer('o', ' NVL(DP.PLANNED_DEPARTURE_DATE, SYSDATE) ' || ordered_rsr(i).sort_order || ', ');
	    ELSIF (ordered_rsr(i).attribute = C_SHIPMENT_PRIORITY) THEN
	      Process_Buffer('o', ' NVL(L.SHIPMENT_PRIORITY_CODE,H.SHIPMENT_PRIORITY_CODE) ' || ordered_rsr(i).sort_order || ', ');
	    END IF;
	  END LOOP;

	  -- Must add this for easy grouping of ship sets and smc components
	  IF use_order_header = FALSE THEN
	    Process_Buffer('o',  ' H.HEADER_ID, ');
	  END IF;
	  Process_Buffer('o', ' NVL(L.SHIP_SET_NUMBER, 99999999), ');
	  Process_Buffer('o', ' L.SHIP_MODEL_COMPLETE_FLAG DESC, ');
	  Process_Buffer('o', ' NVL(L.PARENT_LINE_ID,L.LINE_ID), ');
	  Process_Buffer('o', ' PLD.WAREHOUSE_ID, ');
	  Process_Buffer('o', ' NVL(L.SHIP_TO_SITE_USE_ID,  H.SHIP_TO_SITE_USE_ID), ');
	  Process_Buffer('o', ' NVL(L.SHIP_METHOD_CODE, H.SHIP_METHOD_CODE) ');

	  backordered_SQL := backordered_SQL || orderby_SQL;

	ELSIF (p_sql_type = 'SYNC') THEN
	  sync_SQL := '';
	  Process_Buffer('s', ' SELECT ');
	  Process_Buffer('s', ' L.LINE_ID, ');
	  Process_Buffer('s', ' H.HEADER_ID, ');
	  Process_Buffer('s', ' NVL(H.ORG_ID, -3114), ');
	  Process_Buffer('s', ' L.ATO_FLAG, ');
	  Process_Buffer('s', ' LD.LINE_DETAIL_ID, ');
	  Process_Buffer('s', ' L.SHIP_MODEL_COMPLETE_FLAG, ');
	  Process_Buffer('s', ' NVL(L.SHIP_SET_NUMBER, -9), ');
	  Process_Buffer('s', ' NVL(L.PARENT_LINE_ID, 0), ');
	  Process_Buffer('s', ' NVL(LD.WAREHOUSE_ID, -1), ');
	  Process_Buffer('s', ' NVL(NVL(L.SHIP_TO_SITE_USE_ID, H.SHIP_TO_SITE_USE_ID), -1), ');
	  Process_Buffer('s', ' NVL(NVL(L.SHIP_TO_CONTACT_ID, H.SHIP_TO_CONTACT_ID), -1), ');
	  Process_Buffer('s', ' NVL(L.SHIP_METHOD_CODE, H.SHIP_METHOD_CODE), ');
	  Process_Buffer('s', ' NVL(L.SHIPMENT_PRIORITY_CODE, H.SHIPMENT_PRIORITY_CODE), ');
	  Process_Buffer('s', ' NVL(LD.DEPARTURE_ID, -1), ');
	  Process_Buffer('s', ' NVL(LD.DELIVERY_ID, -1), ');
	  Process_Buffer('s', ' TO_NUMBER(TO_CHAR( LD.SCHEDULE_DATE, ''J'' )), ');
	  Process_Buffer('s', ' NVL(LD.CUSTOMER_ITEM_ID, -1), ');
	  Process_Buffer('s', ' LD.DEP_PLAN_REQUIRED_FLAG, ');
	  Process_Buffer('s', ' H.ORDER_NUMBER, ');
	  Process_Buffer('s', ' H.ORDER_TYPE_ID, ');
	  Process_Buffer('s', ' H.CUSTOMER_ID, ');
	  Process_Buffer('s', ' H.INVOICE_TO_SITE_USE_ID, ');
	  Process_Buffer('s', ' NVL(LD.MASTER_CONTAINER_ITEM_ID, -1), ');
	  Process_Buffer('s', ' NVL(LD.DETAIL_CONTAINER_ITEM_ID, -1), ');
	  Process_Buffer('s', ' NVL(LD.LOAD_SEQ_NUMBER, -1) ');
	  Process_Buffer('s', ' FROM	WSH_DELIVERIES DL, ');
	  Process_Buffer('s', ' 	WSH_DEPARTURES DP, ');
	  Process_Buffer('s', ' 	SO_LINE_DETAILS LD, ');
	  Process_Buffer('s', ' 	SO_HEADERS_ALL H, ');
	  Process_Buffer('s', ' 	SO_LINES_ALL L ');
	  Process_Buffer('s', ' WHERE L.HEADER_ID = H.HEADER_ID ');
	  Process_Buffer('s', ' AND   L.LINE_ID = LD.LINE_ID ');
	  Process_Buffer('s', ' AND   LD.DEPARTURE_ID = DP.DEPARTURE_ID (+)  ');
	  Process_Buffer('s', ' AND   LD.DELIVERY_ID = DL.DELIVERY_ID (+) ');
	  Process_Buffer('s', ' AND   L.LINE_TYPE_CODE IN (''REGULAR'',''DETAIL'') ');
	  Process_Buffer('s', ' AND   L.SOURCE_TYPE_CODE = ''INTERNAL'' ');
	  Process_Buffer('s', ' AND    NVL(L.CANCELLED_QUANTITY,0) < L.ORDERED_QUANTITY ');
	  Process_Buffer('s', ' AND    L.ATO_LINE_ID IS NULL ');
	  Process_Buffer('s', ' AND    L.OPEN_FLAG || '''' = ''Y'' ');
	  Process_Buffer('s', ' AND    H.OPEN_FLAG || '''' = ''Y'' ');
	  Process_Buffer('s', ' AND    LD.RELEASED_FLAG || '''' = ''N'' ');
	  Process_Buffer('s', ' AND    LD.SHIPPABLE_FLAG = ''Y'' ');
	  Process_Buffer('s', ' AND    LD.SCHEDULE_DATE IS NOT NULL ');

	  Process_Buffer('s', ' AND    DECODE(L.ATO_FLAG,''Y'', ');
	  Process_Buffer('s', '        DECODE(LD.SCHEDULE_STATUS_CODE,''RESERVED'',''Y'',''N''),''X'') = ');
	  Process_Buffer('s', '        DECODE(L.ATO_FLAG,''Y'',''Y'',''X'') ');

	  Process_Buffer('s', ' AND    L.LINE_ID IN ');
	  Process_Buffer('s', '       (SELECT L1.LINE_ID FROM SO_LINES_ALL L1 ');
	  Process_Buffer('s', '        WHERE L1.LINE_ID = :X_p_param_1 ');
	  Process_Buffer('s', '        UNION ');
	  Process_Buffer('s', '        SELECT L2.LINE_ID FROM SO_LINES_ALL L2 ');
	  Process_Buffer('s', '        WHERE L2.PARENT_LINE_ID = :X_p_param_1) ');

	  Process_Buffer('s', ' AND    L.S2 IN (18,5) ');

	  -- Make sure that lines to be shipped out of a particular warehouse is picked up
	  Process_Buffer('s', ' AND (LD.WAREHOUSE_ID = :X_warehouse_id OR :X_warehouse_id = -1) ' ||  ' ');

	  Process_Buffer('s', ' AND (LD.SUBINVENTORY = :X_subinventory OR :X_subinventory IS NULL)' || ' ' );

	  Process_Buffer('s', ' AND (NVL(L.DATE_REQUESTED_CURRENT, H.DATE_REQUESTED_CURRENT) >= ');
	  Process_Buffer('s', ' 	to_date(:X_from_request_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_from_request_date IS NULL) ' || ' ');

	  Process_Buffer('s', ' AND (NVL(L.DATE_REQUESTED_CURRENT, H.DATE_REQUESTED_CURRENT) <= ');
	  Process_Buffer('s', ' 	to_date(:X_to_request_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_to_request_date IS NULL) ' || ' ');

	  Process_Buffer('s', ' AND (LD.SCHEDULE_DATE >= ');
	  Process_Buffer('s', ' 	to_date(:X_from_sched_ship_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_from_sched_ship_date IS NULL) ' || ' ');

	  Process_Buffer('s', ' AND (LD.SCHEDULE_DATE <= ');
	  Process_Buffer('s', ' 	to_date(:X_to_sched_ship_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_to_sched_ship_date IS NULL) ' || ' ');

	  -- if X_existing_rsvs_only_flag is not 'Y', the following condition always returns true
	  Process_Buffer('s', ' AND ((LD.RESERVABLE_FLAG = ''Y'' ');
	  Process_Buffer('s', ' 	AND LD.SCHEDULE_STATUS_CODE IN ( ''RESERVED'', ''SUPPLY RESERVED'' )) ');
	  Process_Buffer('s', ' 	 OR NVL(:X_existing_rsvs_only_flag,''X'') <> ''Y'') ');

	  Process_Buffer('s', ' AND (L.INVENTORY_ITEM_ID + 0 = :X_inventory_item_id  ');
	  Process_Buffer('s', ' 	OR :X_inventory_item_id = 0) ' || ' ');

	  Process_Buffer('s', ' AND  (L.ATO_FLAG = ''N'' OR :X_reservations <> ''N'') ' || ' ');

	  -- Handling departures and deliveries

	  IF (departure_id <> 0) THEN
	    Process_Buffer('s', ' AND LD.DEPARTURE_ID = :X_departure_id ' || ' ');
	    Process_Buffer('s', ' AND NVL(DL.STATUS_CODE, ''XX'') = ''PL'' ');
	  END IF;

	  IF (delivery_id <> 0) THEN
	    Process_Buffer('s', ' AND LD.DELIVERY_ID = :X_delivery_id ' || ' ');
	  END IF;

	  Process_Buffer('s', ' AND ((NVL(LD.DEPARTURE_ID, -99) = -99 ');
	  Process_Buffer('s', ' 	AND NVL(LD.DELIVERY_ID, -99) = -99) ');
	  Process_Buffer('s', ' 	OR :X_include_planned_lines <> ''N'' OR :X_departure_id <> 0) ');

	  Process_Buffer('s', ' AND (((NVL(LD.DEP_PLAN_REQUIRED_FLAG,''N'') = ''Y'') ');
	  Process_Buffer('s', '        AND NVL(DP.STATUS_CODE, ''XX'') = ''PL'') ');
	  Process_Buffer('s', '      OR (NVL(LD.DEP_PLAN_REQUIRED_FLAG,''N'') = ''N'')) ');

	ELSIF (p_sql_type = 'NON_SHIPPABLE') THEN
	  --
	  -- This statement selects service and non-shippable standard lines
	  --

	  non_ship_SQL := '';
	  Process_Buffer('n', ' SELECT ');
	  Process_Buffer('n', ' L.LINE_ID, ');
	  Process_Buffer('n', ' H.HEADER_ID, ');
	  Process_Buffer('n', ' NVL(LD.LINE_DETAIL_ID, -1), ');
	  Process_Buffer('n', ' NVL(H.ORG_ID, -3114) ');
	  Process_Buffer('n', ' FROM	SO_LINE_DETAILS LD, ');
	  Process_Buffer('n', ' 	SO_HEADERS_ALL H, ');
	  Process_Buffer('n', ' 	SO_LINES_ALL L ');
	  Process_Buffer('n', ' WHERE L.HEADER_ID = H.HEADER_ID ');
	  Process_Buffer('n', ' AND   L.LINE_ID = LD.LINE_ID(+) ');
	  Process_Buffer('n', ' AND   L.SOURCE_TYPE_CODE = ''INTERNAL'' ');
	  Process_Buffer('n', ' AND    NVL(L.CANCELLED_QUANTITY,0) < L.ORDERED_QUANTITY ');
	  Process_Buffer('n', ' AND    L.OPEN_FLAG || '''' = ''Y'' ');
	  Process_Buffer('n', ' AND    H.OPEN_FLAG || '''' = ''Y'' ');
	  Process_Buffer('n', ' AND    NVL(LD.RELEASED_FLAG, ''N'') = ''N'' ');
	  Process_Buffer('n', ' AND   (L.ITEM_TYPE_CODE = ''SERVICE'' ');
	  Process_Buffer('n', '        OR (L.ITEM_TYPE_CODE = ''STANDARD'' ');
	  Process_Buffer('n', ' 	   AND NOT EXISTS  ');
	  Process_Buffer('n', '                ( SELECT XX.LINE_ID FROM ');
	  Process_Buffer('n', '                  SO_LINE_DETAILS XX ');
	  Process_Buffer('n', '                  WHERE ');
	  Process_Buffer('n', '                  XX.SHIPPABLE_FLAG || '''' = ''Y'' ');
	  Process_Buffer('n', '                  AND XX.LINE_ID = L.LINE_ID)) ');
          Process_Buffer('n', '        OR (L.ITEM_TYPE_CODE IN (''MODEL'',''KIT'',''CLASS'') ');
	  Process_Buffer('n', '            AND L.REQUEST_ID = :X_request_id ');
          Process_Buffer('n', '            AND NOT EXISTS ( ');
          Process_Buffer('n', '                   SELECT ''shippable component for a model'' ');
          Process_Buffer('n', '                   FROM  SO_LINES_ALL L2, ');
          Process_Buffer('n', '                         SO_LINE_DETAILS LD2 ');
          Process_Buffer('n', '                   WHERE L2.LINE_ID = NVL(L.PARENT_LINE_ID,L.LINE_ID) ');
          Process_Buffer('n', '                   AND   L2.LINE_ID = LD2.LINE_ID ');
          Process_Buffer('n', '                   AND   LD2.RELEASED_FLAG = ''N'' ');
          Process_Buffer('n', '                   AND   LD2.SHIPPABLE_FLAG = ''Y'' ');
          Process_Buffer('n', '                   UNION ');
          Process_Buffer('n', '                   SELECT ''shippable component for model components'' ');
          Process_Buffer('n', '                   FROM  SO_LINES_ALL L3, ');
          Process_Buffer('n', '                         SO_LINE_DETAILS LD3 ');
          Process_Buffer('n', '                   WHERE L3.PARENT_LINE_ID = NVL(L.PARENT_LINE_ID,L.LINE_ID) ');
          Process_Buffer('n', '                   AND   L3.LINE_ID = LD3.LINE_ID ');
          Process_Buffer('n', '                   AND   LD3.RELEASED_FLAG = ''N'' ');
          Process_Buffer('n', '                   AND   LD3.SHIPPABLE_FLAG = ''Y''))) ');

	  IF (header_id <> 0 OR customer_id <> 0 OR order_line_id <> 0) THEN
	    Process_Buffer('n', ' AND    L.S2+0 = 18 ');
	  ELSE
	    Process_Buffer('n', ' AND    L.S2 = 18 ');
	  END IF;

	  -- Following conditions use bind variables
	  -- The columns which have indexes are included in the SQL statement conditionally
	  -- This is done so that the index will be used

	  IF (header_id <> 0 AND order_line_id = 0) THEN
	    Process_Buffer('n', ' AND H.HEADER_ID = :X_header_id ' || ' ');
	  ELSIF (header_id <> 0 AND order_line_id <> 0) THEN
	    Process_Buffer('n', ' AND H.HEADER_ID+0 = :X_header_id ' || ' ');
	  END IF;

	  Process_Buffer('n', ' AND (H.ORDER_TYPE_ID = :X_order_type_id OR :X_order_type_id = 0) ' || ' ');

	  IF (customer_id <> 0) THEN
	    Process_Buffer('n', ' AND H.CUSTOMER_ID = :X_customer_id ' || ' ');
	  END IF;

	  IF (order_line_id <> 0) THEN
	    Process_Buffer('n', 'AND   L.LINE_ID = :X_order_line_id ' || ' ');
	  END IF;

	  Process_Buffer('n', ' AND (L.SHIP_SET_NUMBER = :X_ship_set_number OR :X_ship_set_number = 0) ' || ' ');

	  -- Make sure that lines to be shipped out of a particular warehouse is picked up
	  Process_Buffer('n', ' AND (NVL(LD.WAREHOUSE_ID, :X_warehouse_id) = :X_warehouse_id OR :X_warehouse_id = -1) ' ||  ' ');

	  Process_Buffer('n', ' AND (NVL(L.DATE_REQUESTED_CURRENT, H.DATE_REQUESTED_CURRENT) >= ');
	  Process_Buffer('n', ' 	to_date(:X_from_request_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_from_request_date IS NULL) ' || ' ');

	  Process_Buffer('n', ' AND (NVL(L.DATE_REQUESTED_CURRENT, H.DATE_REQUESTED_CURRENT) <= ');
	  Process_Buffer('n', ' 	to_date(:X_to_request_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_to_request_date IS NULL) ' || ' ');

	  Process_Buffer('n', ' AND (NVL(LD.SCHEDULE_DATE,to_date(:X_from_sched_ship_date,''YYYY/MM/DD HH24:MI:SS'')) >= ');
	  Process_Buffer('n', ' 	to_date(:X_from_sched_ship_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_from_sched_ship_date IS NULL) ' || ' ');

	  Process_Buffer('n', ' AND (NVL(LD.SCHEDULE_DATE,to_date(:X_to_sched_ship_date,''YYYY/MM/DD HH24:MI:SS'')) <= ');
	  Process_Buffer('n', ' 	to_date(:X_to_sched_ship_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_to_sched_ship_date IS NULL) ' || ' ');

	  Process_Buffer('n', ' AND (L.INVENTORY_ITEM_ID + 0 = :X_inventory_item_id  ');
	  Process_Buffer('n', ' 	OR :X_inventory_item_id = 0) ' || ' ');

	  -- Handling departures and deliveries

	  IF (departure_id <> 0) THEN
	    -- select non-ship lines from orders in departure
	    Process_Buffer('n', ' AND EXISTS (SELECT LD1.LINE_DETAIL_ID ');
	    Process_Buffer('n', '     FROM SO_LINES_ALL L1, ');
	    Process_Buffer('n', '          SO_LINE_DETAILS LD1,  ');
	    Process_Buffer('n', '          WSH_DEPARTURES D1  ');
	    Process_Buffer('n', '     WHERE LD1.LINE_ID = L1.LINE_ID ');
	    Process_Buffer('n', '     AND   L1.HEADER_ID = L.HEADER_ID ');
	    Process_Buffer('n', '     AND   LD1.DEPARTURE_ID = D1.DEPARTURE_ID ' || ' ');
	    Process_Buffer('n', '     AND   D1.DEPARTURE_ID = :X_departure_id ' || ' ');
	    Process_Buffer('n', '     AND   NVL(D1.STATUS_CODE, ''XX'') = ''PL'') ');
	  END IF;

	  IF (delivery_id <> 0) THEN
	    -- select non-ship lines from orders in delivery
	    Process_Buffer('n', ' AND EXISTS (SELECT LD1.LINE_DETAIL_ID ');
	    Process_Buffer('n', '     FROM SO_LINES_ALL L1, SO_LINE_DETAILS LD1 ');
	    Process_Buffer('n', '     WHERE LD1.LINE_ID = L1.LINE_ID ');
	    Process_Buffer('n', '     AND   L1.HEADER_ID = L.HEADER_ID ');
	    Process_Buffer('n', '     AND   LD1.DELIVERY = :X_delivery_id) ' || ' ');
	  END IF;

	  -- Determine the order by clause
	  Process_Buffer('n', ' ORDER BY ');
	  Process_Buffer('n',  ' H.HEADER_ID ASC ');

	ELSIF (p_sql_type = 'SET REQUEST') THEN
	  sreq_SQL := '';
	  Process_Buffer('sreq',' UPDATE SO_LINES_ALL L ');
	  Process_Buffer('sreq',' SET    L.REQUEST_ID = :X_request_id ');
	  Process_Buffer('sreq',' WHERE  L.LINE_ID IN ');
	  Process_Buffer('sreq','      (SELECT	L2.LINE_ID ');
	  Process_Buffer('sreq',' 	FROM	SO_HEADERS_ALL H, ');
	  Process_Buffer('sreq',' 		SO_LINES_ALL L2 ');
	  Process_Buffer('sreq',' 	WHERE L2.LINE_ID = :X_sync_line_id ');
	  Process_Buffer('sreq',' 	AND   L2.HEADER_ID = H.HEADER_ID ');
	  Process_Buffer('sreq',' 	AND   (NVL(L2.DATE_REQUESTED_CURRENT, H.DATE_REQUESTED_CURRENT) >=  ');
	  Process_Buffer('sreq','       	to_date(:X_from_request_date,''YYYY/MM/DD HH24:MI:SS'') OR  ');
	  Process_Buffer('sreq',' 			:X_from_request_date IS NULL) ');
	  Process_Buffer('sreq',' 	AND   (NVL(L2.DATE_REQUESTED_CURRENT, H.DATE_REQUESTED_CURRENT) <=  ');
	  Process_Buffer('sreq',' 		to_date(:X_to_request_date,''YYYY/MM/DD HH24:MI:SS'') OR ');
	  Process_Buffer('sreq',' 			:X_to_request_date IS NULL)  ');
	  Process_Buffer('sreq',' 	UNION ');
	  Process_Buffer('sreq',' 	SELECT L3.LINE_ID ');
	  Process_Buffer('sreq',' 	FROM  SO_HEADERS_ALL H, ');
	  Process_Buffer('sreq',' 	SO_LINES_ALL L3 ');
	  Process_Buffer('sreq',' 	WHERE L3.PARENT_LINE_ID = :X_sync_line_id ');
	  Process_Buffer('sreq',' 	AND   L3.HEADER_ID = H.HEADER_ID ');
	  Process_Buffer('sreq',' 	AND   (NVL(L3.DATE_REQUESTED_CURRENT, H.DATE_REQUESTED_CURRENT) >=  ');
	  Process_Buffer('sreq',' 		to_date(:X_from_request_date,''YYYY/MM/DD HH24:MI:SS'') OR  ');
	  Process_Buffer('sreq',' 			:X_from_request_date IS NULL) ');
	  Process_Buffer('sreq',' 	AND   (NVL(L3.DATE_REQUESTED_CURRENT, H.DATE_REQUESTED_CURRENT) <=  ');
	  Process_Buffer('sreq',' 		to_date(:X_to_request_date,''YYYY/MM/DD HH24:MI:SS'') OR ');
	  Process_Buffer('sreq',' 			:X_to_request_date IS NULL))  ');
	  Process_Buffer('sreq', ' AND    (L.INVENTORY_ITEM_ID + 0 = :X_inventory_item_id  ');
	  Process_Buffer('sreq', '      OR :X_inventory_item_id = 0) ');
	  Process_Buffer('sreq', ' AND EXISTS (SELECT ''a line detail'' ');
	  Process_Buffer('sreq', '           FROM	SO_LINE_DETAILS LD ');
	  Process_Buffer('sreq', '           WHERE	LD.LINE_ID = L.LINE_ID ');
	  Process_Buffer('sreq', '           AND (NVL(LD.WAREHOUSE_ID, :X_warehouse_id) = :X_warehouse_id OR :X_warehouse_id = -1) ');
	  Process_Buffer('sreq', '             AND (NVL(LD.SCHEDULE_DATE,to_date(:X_from_sched_ship_date,''YYYY/MM/DD HH24:MI:SS'')) >= ');
	  Process_Buffer('sreq', '           to_date(:X_from_sched_ship_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_from_sched_ship_date IS NULL) ');
	  Process_Buffer('sreq', '             AND (NVL(LD.SCHEDULE_DATE,to_date(:X_to_sched_ship_date,''YYYY/MM/DD HH24:MI:SS'')) <= ');
	  Process_Buffer('sreq', '           to_date(:X_to_sched_ship_date,''YYYY/MM/DD HH24:MI:SS'') OR :X_to_sched_ship_date IS NULL)) ');
	ELSE
	  WSH_UTIL.Write_Log('Invalid parameter');
	  RETURN FAILURE;
	END IF;

	RETURN SUCCESS;

  END Construct_SQL;


  --
  -- Name
  --   FUNCTION Get_Next_Line_Detail
  --
  -- Purpose
  --   This function compares attributes of two line details
  --   passed to it and returns the one that should be
  --   processed earlier based on the release sequence rule.
  --
  -- Arguments
  --   Attributes of a line that determine the order of
  --   releasing the lines. These are used in conjunction
  --   with the release sequence rule.
  --
  -- Return Values
  --  'u' => unreleased line
  --  'b' => backordered line
  --  other values => Error
  --
  -- Notes
  --

  FUNCTION Get_Next_Line_Detail(
	u_invoice_value			IN	BINARY_INTEGER,
	b_invoice_value			IN	BINARY_INTEGER,
	u_order_number			IN	BINARY_INTEGER,
	b_order_number			IN	BINARY_INTEGER,
	u_schedule_date			IN	BINARY_INTEGER,
	b_schedule_date			IN	BINARY_INTEGER,
	u_departure_date_d		IN	BINARY_INTEGER,
	u_departure_date_t		IN	BINARY_INTEGER,
	b_departure_date_d		IN	BINARY_INTEGER,
	b_departure_date_t		IN	BINARY_INTEGER,
	u_shipment_pri			IN	VARCHAR2,
	b_shipment_pri			IN	VARCHAR2
  )
  RETURN VARCHAR2 IS

  i		BINARY_INTEGER;

  BEGIN
	--
	-- Compares releases sequence rule attribute and
	-- return the next one based on the sort order
	-- of the attribute.
	--

	FOR i in 1..total_release_criteria LOOP

	  -- Compare invoice values
	  IF ordered_rsr(i).attribute = C_INVOICE_VALUE THEN
	    IF ordered_rsr(i).sort_order = 'DESC' THEN
	      IF u_invoice_value > b_invoice_value THEN
	        RETURN 'u';
	      ELSIF u_invoice_value < b_invoice_value THEN
	        RETURN 'b';
	      END IF;
	    ELSIF ordered_rsr(i).sort_order = 'ASC' THEN
	      IF u_invoice_value > b_invoice_value THEN
	        RETURN 'b';
	      ELSIF u_invoice_value < b_invoice_value THEN
	        RETURN 'u';
	      END IF;
	    END IF;

	  -- Compare order number
	  ELSIF ordered_rsr(i).attribute = C_ORDER_NUMBER THEN
	    IF ordered_rsr(i).sort_order = 'DESC' THEN
	      IF u_order_number > b_order_number THEN
	        RETURN 'u';
	      ELSIF u_order_number < b_order_number THEN
	        RETURN 'b';
	      END IF;
	    ELSIF ordered_rsr(i).sort_order = 'ASC' THEN
	      IF u_order_number > b_order_number THEN
	        RETURN 'b';
	      ELSIF u_order_number < b_order_number THEN
	        RETURN 'u';
	      END IF;
	    END IF;

	  -- Compare schedule dates
	  ELSIF ordered_rsr(i).attribute = C_SCHEDULE_DATE THEN
	    IF ordered_rsr(i).sort_order = 'DESC' THEN
	      IF u_schedule_date > b_schedule_date THEN
	        RETURN 'u';
	      ELSIF u_schedule_date < b_schedule_date THEN
	        RETURN 'b';
	      END IF;
	    ELSIF ordered_rsr(i).sort_order = 'ASC' THEN
	      IF u_schedule_date > b_schedule_date THEN
	        RETURN 'b';
	      ELSIF u_schedule_date < b_schedule_date THEN
	        RETURN 'u';
	      END IF;
	    END IF;

	  -- Compare departure
	  ELSIF ordered_rsr(i).attribute = C_DEPARTURE  THEN
	    IF ordered_rsr(i).sort_order = 'DESC' THEN
	      IF u_departure_date_d > b_departure_date_d THEN
	        RETURN 'u';
	      ELSIF u_departure_date_d < b_departure_date_d THEN
	        RETURN 'b';
	      ELSIF u_departure_date_t > b_departure_date_t THEN
		RETURN 'u';
	      ELSIF u_departure_date_t < b_departure_date_t THEN
		RETURN 'b';
	      END IF;
	    ELSIF ordered_rsr(i).sort_order = 'ASC' THEN
	      IF u_departure_date_d > b_departure_date_d THEN
	        RETURN 'b';
	      ELSIF u_departure_date_d < b_departure_date_d THEN
	        RETURN 'u';
	      ELSIF u_departure_date_t > b_departure_date_t THEN
		RETURN 'b';
	      ELSIF u_departure_date_t < b_departure_date_t THEN
		RETURN 'u';
	      END IF;
	    END IF;

	  -- Compare shipment priority
	  ELSIF ordered_rsr(i).attribute = C_SHIPMENT_PRIORITY THEN
	    IF ordered_rsr(i).sort_order = 'DESC' THEN
	      IF u_shipment_pri > b_shipment_pri THEN
	        RETURN 'u';
	      ELSIF u_shipment_pri < b_shipment_pri THEN
	        RETURN 'b';
	      END IF;
	    ELSIF ordered_rsr(i).sort_order = 'ASC' THEN
	      IF u_shipment_pri > b_shipment_pri THEN
	        RETURN 'b';
	      ELSIF u_shipment_pri < b_shipment_pri THEN
	        RETURN 'u';
	      END IF;
	    END IF;
	  END IF;
	END LOOP;

        -- at this point they are the same in all attributes
	RETURN 'u';

  END Get_Next_Line_Detail;


  --
  -- Name
  --   PROCEDURE Process Buffer
  --
  -- Purpose
  --   This procedure processes a line of text, by first writing to the
  --   log file and then concatenating it to the required SQL buffer
  --
  -- Arguments
  --   p_buffer_name identifies which buffer to append to.
  --                 'u' -> Unreleased_SQL
  --                 'b' -> Backordered_SQL
  --                 'o' -> Orderby_SQL
  --                 'n' -> Non_ship_SQL
  --   p_buffer_text identifies the text to process
  --
  -- Notes
  --

  PROCEDURE Process_Buffer(
		p_buffer_name		IN	VARCHAR2,
		p_buffer_text		IN	VARCHAR2
  ) IS

  cs		BINARY_INTEGER;

  BEGIN
	WSH_UTIL.Write_Log(p_buffer_text);
	IF p_buffer_name = 'u' THEN
	  Unreleased_SQL := Unreleased_SQL || p_buffer_text;
	ELSIF p_buffer_name = 'b' THEN
	  Backordered_SQL := Backordered_SQL || p_buffer_text;
	ELSIF p_buffer_name = 's' THEN
	  sync_SQL := sync_SQL || p_buffer_text;
	ELSIF p_buffer_name = 'o' THEN
	  Orderby_SQL := Orderby_SQL || p_buffer_text;
        ELSIF p_buffer_name = 'n' THEN
          Non_Ship_SQL := Non_Ship_SQL || p_buffer_text;
        ELSIF p_buffer_name = 'sreq' THEN
          sreq_SQL := sreq_SQL || p_buffer_text;
	ELSE
	  RETURN;
	END IF;

  END Process_Buffer;


  --
  -- Name
  --   FUNCTION Launch_Doc_Set
  --
  -- Purpose
  --   This function launches the document set for pick release
  --
  -- Return Values
  --  -1 => Failure
  --   0 => Success
  --
  -- Notes
  --

  FUNCTION Launch_Doc_Set
  RETURN BINARY_INTEGER IS

    cs		BOOLEAN;
    message	VARCHAR2(2000);

  BEGIN

	IF report_set_id <> -1 THEN

	  WSH_DOC_SETS.Print_Document_Sets(
				X_report_set_id => report_set_id,
				P_BATCH_ID => batch_id,
				P_PROG_REQUEST_ID => request_id,
				P_BATCH_NAME => batch_name,
				P_WAREHOUSE_ID => warehouse_id,
				message_string => message,
				status => cs);
	  IF cs = FALSE THEN
	    WSH_UTIL.Write_Log('Error in WSH_DOC_SETS.Print_Document_Sets');
	    WSH_UTIL.Write_Log(message);
	    RETURN FAILURE;
	  END IF;

	ELSE
	  WSH_UTIL.Write_Log('Invalid documnet set');
	  return FAILURE;
	END IF;

	RETURN SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      WSH_UTIL.Default_Handler('WSH_PR_PICKING_SESSION.Launc_Doc_Set','');
      RETURN FAILURE;

  END;

  --
  -- Name
  --   FUNCTION Get_Session_Value
  --
  -- Purpose
  --   This function returns session values that may be used by other
  --   packages
  --
  -- Arguments
  --   p_token - attribute whose value needs to be determined
  --
  -- Return Values
  --   The value of the token in VARCHAR2 format
  --
  -- Notes
  --

  FUNCTION Get_Session_Value(
		   p_token		IN	VARCHAR2
  )
  RETURN VARCHAR2 IS

	cs				BINARY_INTEGER;

  BEGIN
	-- handle uninitialized package errors here
	IF initialized = FALSE THEN
	   WSH_UTIL.Write_Log('The package must be initialized before use');
	   RETURN FAILURE;
	END IF;

	IF p_token = 'UNRELEASED_SQL' THEN
	   RETURN unreleased_SQL;
	ELSIF p_token = 'BACKORDERED_SQL' THEN
	   RETURN backordered_SQL;
	ELSIF p_token = 'SYNC_SQL' THEN
	   RETURN sync_SQL;
	ELSIF p_token = 'NON_SHIP_SQL' THEN
	   RETURN non_ship_SQL;
	ELSIF p_token = 'SET_REQUEST_SQL' THEN
	   RETURN sreq_SQL;
	ELSE
	   -- handle invalid token
	   WSH_UTIL.Write_Log('Invalid Token ' || p_token);
	   RETURN to_char(FAILURE);
	END IF;

	RETURN SUCCESS;

  END Get_Session_Value;

END WSH_PR_PICKING_SESSION;

/
