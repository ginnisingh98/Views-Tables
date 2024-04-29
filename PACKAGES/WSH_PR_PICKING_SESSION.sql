--------------------------------------------------------
--  DDL for Package WSH_PR_PICKING_SESSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PR_PICKING_SESSION" AUTHID CURRENT_USER AS
/* $Header: WSHPRPSS.pls 115.2 99/07/16 08:20:15 porting ship $ */

--
-- Package
--   	WSH_PR_PICKING_SESSION
--
-- Purpose
--      This package does the following:
--	- Maintain all the session variables for Pick Release
--      - Construct SQL statements to fetch backorderd picking
--        line details, unreleased line details, non-shippable
--        lines satisfying the release criteria.
--      - Provides API to retrieve session values
--

  --
  -- PACKAGE VARIABLES
  --
	header_id				BINARY_INTEGER;
	order_type_id				BINARY_INTEGER;
	batch_id				BINARY_INTEGER;
	batch_name				VARCHAR2(30);
	warehouse_id				BINARY_INTEGER;
	org_id					BINARY_INTEGER;
	customer_id				BINARY_INTEGER;
	ship_site_use_id			BINARY_INTEGER;
	shipment_priority			VARCHAR2(30);
	ship_method_code			VARCHAR2(30);
	from_request_date			DATE;
	to_request_date				DATE;
        from_sched_ship_date			DATE;
	to_sched_ship_date			DATE;
	existing_rsvs_only_flag			VARCHAR2(1);
	subinventory				VARCHAR2(10);
	ship_set_number				BINARY_INTEGER;
	inventory_item_id			BINARY_INTEGER;
	pick_slip_rule_id			BINARY_INTEGER;
	release_seq_rule_id			BINARY_INTEGER;
	release_seq_rule_name			VARCHAR2(30);
	departure_id				BINARY_INTEGER;
	delivery_id				BINARY_INTEGER;
	report_set_id				BINARY_INTEGER;
	include_planned_lines			VARCHAR2(1);
	backorders_flag				VARCHAR2(1);
	partial_allowed_flag			VARCHAR2(1);
	autocreate_deliveries			VARCHAR2(1);
	order_line_id				BINARY_INTEGER;
	reservations				VARCHAR2(1);
	primary_rsr				VARCHAR2(30) := '';
	application_id				BINARY_INTEGER;
	program_id				BINARY_INTEGER;
	request_id				BINARY_INTEGER;
	user_id					BINARY_INTEGER;
	login_id				BINARY_INTEGER;
	sync_line_id				BINARY_INTEGER;

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --

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
  RETURN BINARY_INTEGER;

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
  RETURN BINARY_INTEGER;


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

  FUNCTION Unreleased_Line_Details RETURN BINARY_INTEGER;


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

  FUNCTION Backordered_Line_Details RETURN BINARY_INTEGER;


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
  RETURN BINARY_INTEGER;


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

  FUNCTION Non_Shippable_Lines RETURN BINARY_INTEGER;

  --
  -- Name
  --   FUNCTION Construct_SQL
  --
  -- Purpose
  --   This function creates the actual SQL statement based on a
  --   parameter passed to it.
  --
  -- Arguments
  --   p_sql_type is determine what kind of SQL to create
  --
  -- Notes
  --

  FUNCTION Construct_SQL(
		p_sql_type		IN	VARCHAR2
  )
  RETURN BINARY_INTEGER;

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
  RETURN VARCHAR2;


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

  FUNCTION Launch_Doc_Set RETURN BINARY_INTEGER;


  --
  -- Name
  --   FUNCTION Get_Session_Value
  --
  -- Purpose
  --   This function returns session values for other packages
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
  RETURN VARCHAR2;


END WSH_PR_PICKING_SESSION;

 

/
