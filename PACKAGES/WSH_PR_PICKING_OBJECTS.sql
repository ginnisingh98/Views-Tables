--------------------------------------------------------
--  DDL for Package WSH_PR_PICKING_OBJECTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PR_PICKING_OBJECTS" AUTHID CURRENT_USER AS
/* $Header: WSHPRPOS.pls 115.3 99/07/16 08:20:03 porting ship  $ */

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
-- History
--      16-SEP-96    RSHIVRAM    Created
--

  --
  -- PACKAGE TYPES
  --
	TYPE keyRecTyp IS RECORD (
		key		VARCHAR2(200),
		value		NUMBER
	);

	TYPE keyTabTyp IS TABLE OF keyRecTyp INDEX BY BINARY_INTEGER;

  --
  -- PUBLIC VARIABLES
  --

	g_login_id                              NUMBER;
        g_user_id                               NUMBER;
        g_program_id                            NUMBER;
        g_request_id                            NUMBER;
        g_application_id                        NUMBER;
        g_batch_id                              NUMBER;
        g_pick_slip_rule_id                     NUMBER;
        g_warehouse_id                          NUMBER;
        g_use_autocreate_del_orders             VARCHAR2(1) := 'Y';
        g_autocreate_deliveries                 VARCHAR2(1);
        g_reservations                          VARCHAR2(1) := 'Y';
        g_use_order_ps                          VARCHAR2(1) := 'N';
        g_use_sub_ps                            VARCHAR2(1) := 'N';
        g_use_customer_ps                       VARCHAR2(1) := 'N';
        g_use_ship_to_ps                        VARCHAR2(1) := 'N';
        g_use_carrier_ps                        VARCHAR2(1) := 'N';
        g_use_ship_priority_ps                  VARCHAR2(1) := 'N';
        g_use_departure_ps                      VARCHAR2(1) := 'N';
        g_use_delivery_ps                       VARCHAR2(1) := 'N';
        g_ps_table                              keyTabTyp;
        g_ph_table                              keyTabTyp;

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --

  --
  -- Name
  --   FUNCTION Init
  --
  -- Purpose
  --   This function initializes the who variables, reservations variable,
  --   and the use_ variables to be used in determining the how to group
  --   pick slips.
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
  -- Notes
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
  RETURN BINARY_INTEGER;

END WSH_PR_PICKING_OBJECTS;

 

/
