--------------------------------------------------------
--  DDL for Package INV_DETAIL_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DETAIL_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVDEUS.pls 120.4.12010000.4 2009/08/04 10:35:35 mitgupta ship $ */
--
--
-- File        : INVVDEUS.pls
-- Content     : INV_DETAIL_UTIL_PVT package spec
-- Description : utlitities used by the detailing engine (both inv and wms versions)
-- Notes       :
-- Modified    : 10/22/99 bitang created
-- Modified    : 04/04/2002 grao bug# 2286454
--
-- *****************************************************************************
-- * Detailing Request Information
-- *****************************************************************************
--
SUBTYPE g_request_line_rec_type IS mtl_txn_request_lines%ROWTYPE;
-- This record type stores some derived information, such as, revision
-- control code, etc., regarding the detailing request
--
TYPE g_request_context_rec_type IS RECORD
  (
   type_code                	 NUMBER,
   transfer_flag            	 BOOLEAN,
   transaction_action_id    	 NUMBER,
   transaction_source_type_id    NUMBER,
   item_revision_control    	 NUMBER,
   item_lot_control_code    	 NUMBER,
   item_serial_control_code 	 NUMBER,
   lot_expiration_date      	 DATE,
   primary_uom_code         	 VARCHAR2(3),
   secondary_uom_code         VARCHAR2(3),
   transaction_uom_code     	 VARCHAR2(3),
   pick_strategy_id         	 NUMBER,
   put_away_strategy_id     	 NUMBER,
   txn_header_id            	 NUMBER,
   txn_line_id              	 NUMBER,
   txn_line_detail          	 NUMBER,
   customer_id              	 NUMBER,
   customer_number          	 VARCHAR2(30),
   ship_to_location         	 NUMBER,
   shipment_number          	 NUMBER,
   freight_code             	 VARCHAR2(30),
   detail_serial                 BOOLEAN,
   item_locator_control_code     NUMBER,
   org_locator_control_code      NUMBER,
   posting_flag			 VARCHAR2(1),
   detail_any_serial		 NUMBER,
   base_uom_code		 VARCHAR2(3),
   unit_volume			 NUMBER,
   volume_uom_code		 VARCHAR2(3),
   unit_weight			 NUMBER,
   weight_uom_code    	  	 VARCHAR2(3),
   wms_task_type		 NUMBER,
   item_reservable_type		 NUMBER,
   end_assembly_pegging_code	 NUMBER
   );
--
--
-- The following record/table type is used to stores the levels
-- from which the detailing will starts.
-- The reason for having different levels is that the move order line
-- might specify a level (org,revision,lot_number,subinventory,locator)
-- while the reservations made for the same demand source might
-- exist in different level or levels.
-- [ Added the following two columns as a part of allocation of serial reserved items ]
TYPE g_detail_level_rec_type IS RECORD
  (
   revision          	 VARCHAR2(3),
   lot_number        	 VARCHAR2(80),
   subinventory_code 	 VARCHAR2(30),
   grade_code        	 VARCHAR2(150),
   locator_id        	 NUMBER,
   primary_quantity  	 NUMBER,
   transaction_quantity  NUMBER,
   secondary_quantity    NUMBER,
   reservation_id        NUMBER,
   lpn_id		 NUMBER,
   serial_number         VARCHAR2(30), /* FP: Bug 7268522 */   -- [ Added new column - serial_number  ]
   serial_resv_flag      VARCHAR2(1)     -- [ Added new column - serial_resv_flag]
   );
TYPE g_detail_level_tbl_type IS TABLE OF g_detail_level_rec_type
  INDEX BY BINARY_INTEGER;
--
--
-- *****************************************************************************
-- * Types Used For Serial Number Detailing
-- *****************************************************************************
--
-- The following defines record/table type and instance
-- to store serial number(s) used in serial number detailing
TYPE g_serial_row is RECORD
  (
   serial_identifier	NUMBER,
   inventory_item_id    NUMBER,
   organization_id      NUMBER,
   serial_number   	VARCHAR2(30)
   );
--
TYPE g_serial_row_table is TABLE OF g_serial_row
  INDEX BY BINARY_INTEGER;
--
TYPE numtabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE chartabtype30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

TYPE g_serial_row_table_rec is RECORD (
  inventory_item_id NUMTABTYPE
, organization_id   NUMTABTYPE
, serial_number     CHARTABTYPE30
, serial_status     NUMTABTYPE
);

-- Pointer to last row in g_output_serial_rows
g_serial_tbl_ptr 	NUMBER;
-- Stores serial numbers detailed
g_output_serial_rows	g_serial_row_table;
--
--
-- *****************************************************************************
-- * Types Used For Generating Output
-- *****************************************************************************
--
-- The followings define the record/table type used in
-- generating detailing output
TYPE g_output_process_rec_type IS RECORD
  (
   revision                 VARCHAR2(3)     ,
   from_subinventory_code   VARCHAR2(10)    ,
   from_locator_id          NUMBER          ,
   to_subinventory_code     VARCHAR2(10)    ,
   to_locator_id            NUMBER          ,
   lot_number               VARCHAR2(80)    ,
   lot_expiration_date      DATE            ,
   serial_number_start      VARCHAR2(30)    ,
   serial_number_end        VARCHAR2(30)    ,
   transaction_quantity     NUMBER          ,
   primary_quantity         NUMBER          ,
   secondary_quantity       NUMBER          ,
   grade_code               VARCHAR2(150)          ,
   pick_rule_id             NUMBER          ,
   put_away_rule_id         NUMBER          ,
   reservation_id           NUMBER          ,
   from_cost_group_id	    NUMBER          ,
   to_cost_group_id	    NUMBER	    ,
   lpn_id		    NUMBER
   );
TYPE g_output_process_tbl_type IS TABLE OF g_output_process_rec_type
  INDEX BY BINARY_INTEGER;
g_output_process_tbl g_output_process_tbl_type;
g_output_process_tbl_size INTEGER;
--used to enabled WMS run time logging
g_insert_lot_flag NUMBER;
g_insert_serial_flag NUMBER;
g_transaction_header_id NUMBER;
g_mo_transaction_date DATE;
--
-- *****************************************************************************
-- * Procedures and Functions
-- *****************************************************************************
--
-- *****************************************************************************
-- * Validation Related Procedures
-- *****************************************************************************
--
-- Description
--   1. validate move order line id
--   2. fetch move order line into g_mtl_txn_request_lines_rec
--   3. compute and return request context and request line record
--
PROCEDURE validate_and_init
  (x_return_status      OUT NOCOPY VARCHAR2,
   p_request_line_id    IN  NUMBER,
   p_suggest_serial     IN  VARCHAR2 DEFAULT fnd_api.g_false,
   x_request_line_rec   OUT NOCOPY g_request_line_rec_type,
   x_request_context    OUT NOCOPY g_request_context_rec_type,
   p_wave_simulation_mode IN VARCHAR2 DEFAULT 'N'
   );
--
-- *****************************************************************************
-- * Serial Number Detailing Related Procedures
-- *****************************************************************************
--
-- Description
--   Initialize the internal table that stores the serial numbers detailed
--   to empty
PROCEDURE init_output_serial_rows;
-- --------------------------------------------------------------------------
-- What does it do:
-- Given the item/organization, inventory controls, quantity for a autodetailed
-- row and also from/to serial number range info,
-- it fetches and populates available serial numbers into g_output_serial_rows.
-- --------------------------------------------------------------------------
--
PROCEDURE get_serial_numbers (
  p_inventory_item_id       IN         NUMBER
, p_organization_id         IN         NUMBER
, p_revision                IN         VARCHAR2
, p_lot_number              IN         VARCHAR2
, p_subinventory_code       IN         VARCHAR2
, p_locator_id              IN         NUMBER
, p_required_sl_qty         IN         NUMBER
, p_from_range              IN         VARCHAR2
, p_to_range                IN         VARCHAR2
, p_unit_number             IN         VARCHAR2
, p_detail_any_serial       IN         NUMBER
, p_cost_group_id           IN         NUMBER
, p_transaction_type_id     IN         NUMBER
, x_available_sl_qty        OUT NOCOPY NUMBER
, x_serial_index            OUT NOCOPY NUMBER
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_demand_source_type_id   IN         NUMBER   := null
, p_demand_source_header_id IN         NUMBER   := null
, p_demand_source_line_id   IN         NUMBER   := null
);

--
--  --------------------------------------------------------------------------
--  What does it do:
--  Sees if the passed serial number exists in our memory structure,
--  g_output_serial_rows.
--  If found, x_found = TRUE, else FALSE.
--  --------------------------------------------------------------------------
PROCEDURE search_serial_numbers
  (  p_inventory_item_id  IN   NUMBER
   , p_organization_id    IN   NUMBER
   , p_serial_number      IN   VARCHAR2
   , x_found              OUT  NOCOPY BOOLEAN
   , x_return_status      OUT  NOCOPY VARCHAR2
   , x_msg_count	  OUT  NOCOPY NUMBER
   , x_msg_data           OUT  NOCOPY VARCHAR2
   );
--
--
--  --------------------------------------------------------------------------
--  What does it do:
--  Adds the passed serial number to our memory structure for storing
--  detailed serial numbers.
--  --------------------------------------------------------------------------
PROCEDURE add_serial_number(
    p_inventory_item_id IN NUMBER
   ,p_organization_id   IN NUMBER
   ,p_serial_number     IN VARCHAR2
   ,x_serial_index      OUT NOCOPY NUMBER
   );

--  --------------------------------------------------------------------------
--  What does it do:
--  Locks the serial number passed in to keep it from being used by
--  other concurrent processes.
--  --------------------------------------------------------------------------
FUNCTION lock_serial_number(
   p_inventory_item_id IN NUMBER
  ,p_serial_number     IN VARCHAR2
  ) RETURN BOOLEAN;

-- *****************************************************************************
-- * Output generation
-- *****************************************************************************
--
-- Description
--   Initialize the output table to empty
PROCEDURE init_output_process_tbl;
--
-- Description
--   add a output record to the output table
PROCEDURE add_output ( p_output_process_rec IN g_output_process_rec_type);
--
-- Description
--   generate the suggestion records in transaction temporary tables
PROCEDURE process_output
  (x_return_status    OUT NOCOPY VARCHAR2,
   p_request_line_rec IN  g_request_line_rec_type,
   p_request_context  IN  g_request_context_rec_type,
   p_plan_tasks       IN  BOOLEAN DEFAULT FALSE
   );
--
-- *****************************************************************************
-- * Some Useful Helpers
-- *****************************************************************************
-- compute the levels to start detailing using the transaction
-- request info and reservations
-- Added x_remaining_quantity as part of the bug fix for 2286454
PROCEDURE compute_pick_detail_level
  (x_return_status         OUT NOCOPY VARCHAR2,
   p_request_line_rec      IN  g_request_line_rec_type,
   p_request_context       IN  g_request_context_rec_type,
   p_reservations          IN  inv_reservation_global.mtl_reservation_tbl_type,
   x_detail_level_tbl      IN OUT nocopy g_detail_level_tbl_type,
   x_detail_level_tbl_size OUT NOCOPY NUMBER ,
   x_remaining_quantity    OUT NOCOPY NUMBER
   );
--
-- Name        : split_prefix_num
-- Function    : Separates prefix and numeric part of a serial number
-- Pre-reqs    : none
-- Parameters  :
--  p_serial_number        in     varchar2
--  p_prefix               in/out varchar2      the prefix
--  x_num                  out    varchar2(30)  the numeric portion
-- Notes       : privat procedure for internal use only
--               needed only once serial numbers are supported
--
PROCEDURE split_prefix_num
  ( p_serial_number        IN     VARCHAR2
   ,p_prefix               IN OUT NOCOPY VARCHAR2
   ,x_num                  OUT    NOCOPY VARCHAR2
   );
--
-- Subtract two serial numbers and return the difference
FUNCTION subtract_serials
  (p_operand1      IN VARCHAR2,
   p_operand2      IN VARCHAR2
   ) RETURN NUMBER;
--
FUNCTION get_lot_expiration_date
  (p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_lot_number IN VARCHAR2)
  RETURN DATE;

FUNCTION is_sub_loc_lot_trx_allowed(
         p_transaction_type_id  IN      NUMBER
        ,p_organization_id      IN      NUMBER
        ,p_inventory_item_id    IN      NUMBER
        ,p_subinventory_code    IN      VARCHAR2
        ,p_locator_id           IN      NUMBER
        ,p_lot_number           IN      VARCHAR2
        ) RETURN VARCHAR2;

FUNCTION is_serial_trx_allowed(
         p_transaction_type_id  IN      NUMBER
        ,p_organization_id      IN      NUMBER
        ,p_inventory_item_id    IN      NUMBER
        ,p_serial_status        IN      NUMBER
        ) RETURN VARCHAR2;

PROCEDURE build_sql (
        x_return_status         OUT     NOCOPY VARCHAR2
       ,x_sql_statement         OUT     NOCOPY LONG);
FUNCTION is_sub_loc_lot_reservable(
         p_organization_id            IN NUMBER
        ,p_inventory_item_id          IN NUMBER
        ,p_subinventory_code          IN VARCHAR2
        ,p_locator_id                 IN NUMBER
        ,p_lot_number                 IN VARCHAR2
) RETURN BOOLEAN;
FUNCTION get_organization_code(
         p_organization_id            IN NUMBER
         )
Return VARCHAR2;

-- LPN Status Project
FUNCTION is_onhand_status_trx_allowed(
    p_transaction_type_id  IN NUMBER
   ,p_organization_id   IN NUMBER
   ,p_inventory_item_id IN NUMBER
   ,p_subinventory_code IN VARCHAR2
   ,p_locator_id     IN NUMBER
   ,p_lot_number     IN VARCHAR2
   ,p_lpn_id         IN NUMBER
   ) RETURN VARCHAR2;
-- LPN Status Project

PROCEDURE set_mo_transact_date (
        p_date    IN   DATE);

PROCEDURE clear_mo_transact_date;

END inv_detail_util_pvt;


/
