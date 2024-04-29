--------------------------------------------------------
--  DDL for Package INV_RESERVATION_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RESERVATION_GLOBAL" AUTHID CURRENT_USER AS
/* $Header: INVRSVGS.pls 120.1 2005/10/20 18:38:02 vipartha noship $ */
--
-- The following constants are valid demand source type ids and
-- supply source type ids.
-- They are the same as TRANSACTION_SOURCE_TYPE_ID
-- in table MTL_TXN_SOURCE_TYPES.
g_source_type_po             CONSTANT NUMBER := 1 ;
g_source_type_oe             CONSTANT NUMBER := 2 ;
g_source_type_account        CONSTANT NUMBER := 3 ;
g_source_type_trans_order    CONSTANT NUMBER := 4 ;
g_source_type_wip            CONSTANT NUMBER := 5 ;
g_source_type_account_alias  CONSTANT NUMBER := 6 ;
g_source_type_internal_req   CONSTANT NUMBER := 7 ;
g_source_type_internal_ord   CONSTANT NUMBER := 8 ;
g_source_type_cycle_count    CONSTANT NUMBER := 9 ;
g_source_type_physical_inv   CONSTANT NUMBER := 10;
g_source_type_standard_cost  CONSTANT NUMBER := 11;
g_source_type_rma            CONSTANT NUMBER := 12;
g_source_type_inv            CONSTANT NUMBER := 13;
g_source_type_req            CONSTANT NUMBER := 17;
/**** {{ R12 Enhanced reservations code changes }}****/
g_source_type_asn	     CONSTANT NUMBER := 25;
g_source_type_intransit     CONSTANT NUMBER := 26;
g_source_type_rcv            CONSTANT NUMBER := 27;
/*** End R12 ***/

/*** {{ R12 Enhanced reservations code changes }}****/
g_wip_source_type_discrete CONSTANT NUMBER := 1;
g_wip_source_type_repetitive CONSTANT NUMBER := 2;
g_wip_source_type_flow CONSTANT NUMBER := 4;
g_wip_source_type_osfm CONSTANT NUMBER := 5;
g_wip_source_type_eam CONSTANT NUMBER := 6;
g_wip_source_type_fpo CONSTANT NUMBER := 9;
g_wip_source_type_batch CONSTANT NUMBER := 10;
g_wip_source_type_cmro CONSTANT NUMBER := 15;
g_wip_source_type_depot CONSTANT NUMBER := 16;

/*** End R12 ***/
--
-- Constants for revision control code
-- same as MTL_ENG_QUANTITY QuickCode in MFG_LOOKUPS
-- see TRM for table MTL_SYSTEM_ITEMS (column REVISION_QTY_CONTROL_CODE)
g_revision_control_no  CONSTANT NUMBER := 1;
g_revision_control_yes CONSTANT NUMBER := 2;
--
-- Constants for locator control code
-- same as MTL_LOCATION_CONTROL QuickCode in MFG_LOOKUPS
-- see TRM for table MTL_SYSTEM_ITEMS (column LOCATION_CONTROL_CODE)
g_locator_control_no            CONSTANT NUMBER := 1;
g_locator_control_prespecified  CONSTANT NUMBER := 2;
g_locator_control_dynamic       CONSTANT NUMBER := 3;
g_locator_control_by_sub        CONSTANT NUMBER := 4;
g_locator_control_by_item       CONSTANT NUMBER := 5;
--
-- Constants for lot control code
-- same as MTL_LOT_CONTROL QuickCode in MFG_LOOKUPS
-- see TRM for table MTL_SYSTEM_ITEMS (column LOT_CONTROL_CODE)
g_lot_control_no                CONSTANT NUMBER := 1;
g_lot_control_yes               CONSTANT NUMBER := 2;
--
-- Constants for serial number control code
-- same as MTL_SERIAL_NUMBER QuickCode in MFG_LOOKUPS
-- see TRM for table MTL_SYSTEM_ITEMS (column SERIAL_NUMBER_CONTROL_CODE)
g_serial_control_no             CONSTANT NUMBER := 1;
g_serial_control_predefined     CONSTANT NUMBER := 2;
g_serial_control_dynamic_inv    CONSTANT NUMBER := 5;
g_serial_control_dynamic_so     CONSTANT NUMBER := 6;
--
-- The following constants can be used as value for
-- the parameter p_sort_by_req_date in the procedure
-- query_reservation in the public and private api
g_query_no_sort       CONSTANT NUMBER := 1; -- default
g_query_req_date_asc  CONSTANT NUMBER := 2; -- by requirement date ascending
g_query_req_date_desc CONSTANT NUMBER := 3; -- by requirement date descending
--Bug 2828080 Following two new constants are added for shipping for
--query_reservation_for_om_hdr_line
g_query_req_date_inv_asc CONSTANT NUMBER:=4; --by requirement date ascending and
                                                -- followed by inv controls
g_query_req_date_inv_desc CONSTANT NUMBER:=5; --by requirement date descending
                                              -- and followed by inv controls
/*** {{ R12 Enhanced reservations code changes }}****/
g_query_demand_ship_date_asc CONSTANT NUMBER:=6; --by requirement date followed by inv controls
g_query_demand_ship_date_desc CONSTANT NUMBER:=7; --by requirement date followed by inv controls
g_query_supply_rcpt_date_asc CONSTANT NUMBER:=8; --by requirement date followed by inv controls
g_query_supply_rcpt_date_desc CONSTANT NUMBER:=9; --by requirement date followed by inv controls
/*** End R12 ***/

-- The following constants can be used as value for
-- the parameter p_cancel_order_mode in the procedure
-- query_reservation in the public and private api
g_cancel_order_no     CONSTANT NUMBER := 1; -- default
g_cancel_order_yes    CONSTANT NUMBER := 2; -- Sales Order to be cancelled
--
-- Error code
-- Used by various procedure to communicate what error occurred
g_err_no_error          CONSTANT NUMBER := 0;
g_err_unexpected        CONSTANT NUMBER := 1;
g_err_fail_to_lock_rec  CONSTANT NUMBER := 2;
g_err_rec_already_exist CONSTANT NUMBER := 3;
--
--
--
-- We create 5 tables as cache info for org, item, demand, supply, and sub.
-- When we get a request to validate information, we first
-- check our cached records. If we find info there good, otherwise we get
-- the info from Db and populate the cache, ready for future use.
--
-- Definition of record types in cache
-- The attributes in the record types are named the same as the corresponding
-- columns in the underlying db tables.
--
-- record type definition for an item record in cache

-- Modified to call common API
/*TYPE item_record IS RECORD
  (
     inventory_item_id             NUMBER
   , organization_id               NUMBER
   , lot_control_code              NUMBER
   , serial_number_control_code    NUMBER
   , reservable_type               NUMBER
   , restrict_subinventories_code  NUMBER
   , restrict_locators_code        NUMBER
   , revision_qty_control_code     NUMBER
   , location_control_code         NUMBER
   , primary_uom_code              VARCHAR2(3)
   );
--
-- Record type definition for an org record in cache
TYPE organization_record IS RECORD
  (
     organization_id            NUMBER
   , negative_inv_receipt_code  NUMBER
   , project_reference_enabled  NUMBER
   , stock_locator_control_code NUMBER
   );
--
-- Record type definition for a subinventory record in cache
TYPE sub_record IS RECORD
  (
     subinventory_code    VARCHAR2(10)
   , organization_id      NUMBER
   , locator_type         NUMBER
   , quantity_tracked     NUMBER
   , asset_inventory      NUMBER
   , reservable_type      NUMBER
   );
--
*/
SUBTYPE item_record IS MTL_SYSTEM_ITEMS%ROWTYPE;
SUBTYPE organization_record IS MTL_PARAMETERS%ROWTYPE;
SUBTYPE locator_record IS MTL_ITEM_LOCATIONS%ROWTYPE;
SUBTYPE sub_record IS MTL_SECONDARY_INVENTORIES%ROWTYPE;
SUBTYPE serial_record IS MTL_SERIAL_NUMBERS%ROWTYPE;
SUBTYPE lot_record IS MTL_LOT_NUMBERS%ROWTYPE;

-- End addition for common API
-- Record type definition for a demand record in cache
TYPE demand_record IS RECORD
  (
     demand_source_type_id        NUMBER
   , demand_source_header_id      NUMBER
   , demand_source_line_id        NUMBER
   , demand_source_name           VARCHAR2(30)
   , is_valid                     NUMBER     -- currently not used
   );

-- Record type definition for a supply record in cache
TYPE supply_record IS RECORD
  (
     supply_source_type_id           NUMBER
   , supply_source_header_id         NUMBER
   , supply_source_line_id           NUMBER
   , supply_source_name              VARCHAR2(30)
   , is_valid                        NUMBER  -- currently not used
   );

/**** {{ R12 Enhanced reservations code changes }}****/
-- Record type definition for a supply record in cache
TYPE wip_record IS RECORD
  (
   wip_entity_id           NUMBER
   , wip_entity_type         NUMBER
   , wip_entity_job          VARCHAR2(15)
   );
--
TYPE wip_record_cache IS TABLE OF wip_record
  INDEX BY BINARY_INTEGER;

g_wip_record_cache wip_record_cache;
/*** End R12 ***/


-- Definition of table types for the caches
TYPE item_record_cache IS TABLE OF item_record
  INDEX BY BINARY_INTEGER;
--
TYPE organization_record_cache IS TABLE OF organization_record
  INDEX BY BINARY_INTEGER;
--
TYPE sub_record_cache IS TABLE OF sub_record
  INDEX BY BINARY_INTEGER;
--
TYPE demand_record_cache IS TABLE OF demand_record
  INDEX BY BINARY_INTEGER;
--
TYPE supply_record_cache IS TABLE OF supply_record
  INDEX BY BINARY_INTEGER;
--
-- Global variable for the caches
g_item_record_cache         item_record_cache;
g_organization_record_cache organization_record_cache;
g_sub_record_cache          sub_record_cache ;
g_demand_record_cache       demand_record_cache ;
g_supply_record_cache       supply_record_cache ;
--
-- Definition of serial number table type
/**** {{ R12 Enhanced reservations code changes }}****/
TYPE serial_number_rec_type IS RECORD
  (
   inventory_item_id NUMBER
   ,serial_number VARCHAR2(30)
   );

TYPE serial_number_tbl_type IS TABLE OF serial_number_rec_type
  INDEX BY BINARY_INTEGER;


TYPE rsv_serial_number_record IS RECORD
  (
   reservation_id          NUMBER
   ,serial_number        VARCHAR2 (30)
   );

TYPE rsv_serial_number_table IS TABLE OF rsv_serial_number_record
  INDEX BY BINARY_INTEGER;

/*** End R12 ***/

--
-- Topic
--   What is use for mtl_reservation_rec_type ? And
--   what the hell are those fnd_api.g_miss_xxx ?
--
-- The server side reservation apis use records of mtl_reservation_rec_type as
-- input and/or output parameters. The attributes are initialized to
-- fnd_api.g_miss_xxx corresponding to their datatypes. For detail discussion
-- about fnd_api.g_miss_xxx, please refers to the PLSQL Business Object API
-- Coding Standard, available from
-- http://www-apps.us.oracle.com/atg/standards/codestan.html
-- (link API Standards Draft).
--
-- Here is a short explaination for the purpose of g_miss_xxx. We have APIs
-- such as create, update, transfer, delete reservations. When user calls
-- create_reservation, he/she needs to pass all information needed to the api.
-- These information are grouped into a record type which is
-- mtl_reservation_rec_type (similar to struct in C programming language).
-- So he/she can define a variable of mtl_reservation_rec_type, assign values
-- to all attributes, and call the create_reservation api with the variable as
-- an input parameter. Some information might not be available or applicable to
-- the particular reservation the user wants to create, e.g. there is no
-- revision control for the item, so he/she passes null as the values for such
-- attributes.
-- In the case of update, the user needs to pass 2 variables of the record
-- type, one for identifying the existing reservation, one for new values of
-- updates. The user might want to change some attributes but not all.
-- For example, a module in Order Entry might to change the value of
-- demand_source_name from "For Chrismas" to "For Thanksgiving" while
-- keeps the values of all other attributes of the reservation unchanged.
-- The problem is what should be passed as the value of those attributes,
-- such as supply_source_name. If null is passed, should the api change the
-- value of supply_source_name to null, or keep it unchanged. How would the api
-- distinguishes this from the case when a module does want to change the
-- supply_source_name to null. The source of the confusion comes from the fact
-- that null can not be used to represent both "don't care/don't changed"
-- and "null". So constants like g_miss_xxx are introduced to represent
-- "don't care/don't changed". Null is considered a value for these attributes.
-- Users should use g_miss_xxx when they means "don't care/don't changed"
-- and use null when they means "value is null".
--
-- By default, all attributes are initialized to g_miss_xxx
--
--
-- Description of attributes in the record type
--  reservation_id                reservation id
--  requirement_date              requirement date of the reservation
--  organization_id               organization id of the item
--  inventory_item_id             the inventory item id of the item
--  demand_source_type_id         demand source type id (see constants above)
--  demand_source_name            demand source name
--  demand_source_header_id       demand source header id
--  demand_source_line_id         demand source line id
--  primary_uom_code              primary uom code of the item
--  primary_uom_id                primary uom id of the item
--                                (currently not used)
--  reservation_uom_code          reservation uom code of the item
--  reservation_uom_id            reservation uom id of the item
--                                (currently not used)
--  reservation_quantity          quantity in reservation uom code
--  primary_reservation_quantity  quantity in primary uom code
--  autodetail_group_id           autodetail group id
--                                (used by autodetail program)
--  external_source_code          external source code
--                                (for compatibility to early version)
--  external_source_line_id       external source line id
--                                (for compatibility to early version)
--  supply_source_type_id         supply source type id (see contants above)
--  supply_source_header_id       supply source header id
--  supply_source_line_id         supply source line id
--  supply_source_name            supply source name
--  supply_source_line_detail     supply source line detail
--  revision                      revision of the item (null if no revision
--                                control or the reservation is at the
--                                item level)
--  subinventory_code             subinventory code for the sub
--                                (null if the reservation is at the item,
--                                revision or lot level)
--  subinventory_id               not currently used
--  locator_id                    locator id for the locator
--                                (null if no locator control or
--                                the reservation is at item, revision
--                                , lot, or subinventory level)
--  lot_number                    lot number for the item
--                                (null if no lot control or the reservation
--                                is at the item , or revision level)
--  lot_number_id                 not currently used
--  pick_slip_number              pick slip number (for picking)
--  lpn_id                        license plate number (not currently used)
--  ship_ready_flag               whether the reserved item
--                               is ship ready (used by shipping)
--  crossdock_flag               indicates whether it is a crossdocked
--                               reservation
-- crossdock_criteria_id         this will hold the crossdock rule that
--                                created the reservation
-- demand_source_line_detail     demand source line detail (delivery detail
--                               id for sales order reservations
-- serial_reservation_quantity   holds the number of serials reserved
--                               against that reservation record
-- supply_receipt_date           this is the expected date when the supply
--                                 will be fulfilled
-- demand_ship_date              this is the date when the demand will be
--                               fulfilled
-- project_id                    holds the project id of the demand
--                               document
-- task_id                       holds the task_id of the demand document
-- orig_supply_source_****      holds the supply that originally created
--                              that reservation record
-- orig_demand_source_****      holds the demand that originally created
--                              that reservation record
-- The above two information is to preserve the history of the supply and
-- demand that originally created the reservation. This is used for
-- transferring the reservation back to the original document



--
-- Note
--   The current implementation of the reservation system requres that
--   reservations be made at a hierarchial fashion. The levels of the hierarchy
--   are, for top to bottom, item, revision, lot, subinventory, locator,
--   and in the future, serial number. Some levels like revision, lot,
--   locator, and serial number are optional if the corresponding contorls
--   are not enforced. You can not make a reservation at a lower level
--   without specifying the info at all higher levels. For example, to reserve
--   an item at subinventory "Stores", you need to specify the which revision
--   if the item is under revision control, and lot, if the item is under
--   lot control.
--   INVCONV
--   Add secondary_ columns for DUAL UOM
TYPE mtl_reservation_rec_type is RECORD
  (
      reservation_id                 NUMBER        := fnd_api.g_miss_num
    , requirement_date               DATE          := fnd_api.g_miss_date
    , organization_id                NUMBER        := fnd_api.g_miss_num
    , inventory_item_id              NUMBER        := fnd_api.g_miss_num
    , demand_source_type_id          NUMBER        := fnd_api.g_miss_num
    , demand_source_name             VARCHAR2(30)  := fnd_api.g_miss_char
    , demand_source_header_id        NUMBER        := fnd_api.g_miss_num
    , demand_source_line_id          NUMBER        := fnd_api.g_miss_num
    , demand_source_delivery         NUMBER        := fnd_api.g_miss_num
    , primary_uom_code               VARCHAR2(3)   := fnd_api.g_miss_char
    , primary_uom_id                 NUMBER        := fnd_api.g_miss_num
    , secondary_uom_code             VARCHAR2(3)   := fnd_api.g_miss_char
    , secondary_uom_id               NUMBER        := fnd_api.g_miss_num
    , reservation_uom_code           VARCHAR2(3)   := fnd_api.g_miss_char
    , reservation_uom_id             NUMBER        := fnd_api.g_miss_num
    , reservation_quantity           NUMBER        := fnd_api.g_miss_num
    , primary_reservation_quantity   NUMBER        := fnd_api.g_miss_num
    , secondary_reservation_quantity NUMBER        := fnd_api.g_miss_num
    , detailed_quantity              NUMBER        := fnd_api.g_miss_num
    , secondary_detailed_quantity    NUMBER        := fnd_api.g_miss_num
    , autodetail_group_id            NUMBER        := fnd_api.g_miss_num
    , external_source_code           VARCHAR2(30)  := fnd_api.g_miss_char
    , external_source_line_id        NUMBER        := fnd_api.g_miss_num
    , supply_source_type_id          NUMBER        := fnd_api.g_miss_num
    , supply_source_header_id        NUMBER        := fnd_api.g_miss_num
    , supply_source_line_id          NUMBER        := fnd_api.g_miss_num
    , supply_source_name             VARCHAR2(30)  := fnd_api.g_miss_char
    , supply_source_line_detail      NUMBER        := fnd_api.g_miss_num
    , revision                       VARCHAR2(3)   := fnd_api.g_miss_char
    , subinventory_code              VARCHAR2(10)  := fnd_api.g_miss_char
    , subinventory_id                NUMBER        := fnd_api.g_miss_num
    , locator_id                     NUMBER        := fnd_api.g_miss_num
    , lot_number                     VARCHAR2(80)  := fnd_api.g_miss_char -- INVCONV changed to 80 chars.
    , lot_number_id                  NUMBER        := fnd_api.g_miss_num
    , pick_slip_number               NUMBER        := fnd_api.g_miss_num
    , lpn_id                         NUMBER        := fnd_api.g_miss_num
    , attribute_category 	     VARCHAR2(30)  := fnd_api.g_miss_char
    , attribute1         	     VARCHAR2(150) := fnd_api.g_miss_char
    , attribute2         	     VARCHAR2(150) := fnd_api.g_miss_char
    , attribute3         	     VARCHAR2(150) := fnd_api.g_miss_char
    , attribute4         	     VARCHAR2(150) := fnd_api.g_miss_char
    , attribute5         	     VARCHAR2(150) := fnd_api.g_miss_char
    , attribute6         	     VARCHAR2(150) := fnd_api.g_miss_char
    , attribute7         	     VARCHAR2(150) := fnd_api.g_miss_char
    , attribute8         	     VARCHAR2(150) := fnd_api.g_miss_char
    , attribute9         	     VARCHAR2(150) := fnd_api.g_miss_char
    , attribute10        	     VARCHAR2(150) := fnd_api.g_miss_char
    , attribute11        	     VARCHAR2(150) := fnd_api.g_miss_char
    , attribute12        	     VARCHAR2(150) := fnd_api.g_miss_char
    , attribute13        	     VARCHAR2(150) := fnd_api.g_miss_char
    , attribute14        	     VARCHAR2(150) := fnd_api.g_miss_char
    , attribute15	             VARCHAR2(150) := fnd_api.g_miss_char
    , ship_ready_flag                NUMBER        := fnd_api.g_miss_num
  , staged_flag                    VARCHAR2(1)   := fnd_api.g_miss_char

  /**** {{ R12 Enhanced reservations code changes }}****/
  , crossdock_flag 		VARCHAR2(1) := fnd_api.g_miss_char
  , crossdock_criteria_id	NUMBER        := fnd_api.g_miss_num
  , demand_source_line_detail	NUMBER        := fnd_api.g_miss_num
  , serial_reservation_quantity	NUMBER        := fnd_api.g_miss_num
  , supply_receipt_date		DATE          := fnd_api.g_miss_date
  , demand_ship_date		DATE          := fnd_api.g_miss_date
  , project_id		NUMBER := fnd_api.g_miss_num
  , task_id 		NUMBER := fnd_api.g_miss_num
  , orig_supply_source_type_id NUMBER := fnd_api.g_miss_num
  , orig_supply_source_header_id NUMBER := fnd_api.g_miss_num
  , orig_supply_source_line_id NUMBER := fnd_api.g_miss_num
  , orig_supply_source_line_detail NUMBER := fnd_api.g_miss_num
  , orig_demand_source_type_id NUMBER := fnd_api.g_miss_num
  , orig_demand_source_header_id NUMBER := fnd_api.g_miss_num
  , orig_demand_source_line_id NUMBER := fnd_api.g_miss_num
  , orig_demand_source_line_detail NUMBER := fnd_api.g_miss_num
  , serial_number               VARCHAR2(30)  := fnd_api.g_miss_char
  -- Original supply and demand information will just be passed back as part
  --  of the reservation record. No processing or query will be based on
  --  these parameters. Before every reservation API, these parameters will
  --  be set to g_miss_num. Only the output will contain these values from
  --  the queried record
  /*** End R12 ***/

  );


-- Table type definition for an array of mtl_reservation_rec_type records.
TYPE mtl_reservation_tbl_type is TABLE OF mtl_reservation_rec_type
  INDEX BY BINARY_INTEGER;

/**** {{ R12 Enhanced reservations code changes }} ****/
TYPE mtl_maintain_rsv_rec_type is RECORD
  (
   action NUMBER
   ,organization_id NUMBER
   ,inventory_item_id NUMBER
   ,demand_source_type_id NUMBER
   ,demand_source_header_id NUMBER
   ,demand_source_line_id NUMBER
   ,demand_source_line_detail NUMBER
   ,supply_source_type_id NUMBER
   ,supply_source_header_id NUMBER
   ,supply_source_line_id NUMBER
   ,supply_source_line_detail NUMBER
   ,project_id NUMBER := NULL
   ,task_id NUMBER := NULL
   ,from_primary_uom_code VARCHAR2(3)
   ,from_transaction_uom_code VARCHAR2(3)
   ,from_primary_txn_quantity NUMBER
   ,from_transaction_quantity NUMBER
   ,to_primary_uom_code VARCHAR2(3)
   ,to_transaction_uom_code VARCHAR2(3)
   ,to_primary_txn_quantity NUMBER
   ,to_transaction_quantity NUMBER
   ,expected_quantity NUMBER
   ,expected_quantity_uom VARCHAR2(3)
   );

TYPE mtl_maintain_rsv_tbl_type is TABLE OF mtl_maintain_rsv_rec_type
  INDEX BY BINARY_INTEGER;
/*** End R12 ***/


--Table to return Failed reservations when do_check performed at commit
--original procedure is in INV_RESERVATION_PVT
TYPE mtl_failed_rsv_rec_type IS RECORD
  (
    demand_source_line_id           NUMBER  := fnd_api.g_miss_num
   ,demand_source_header_id         NUMBER  :=fnd_api.g_miss_num
   ,demand_source_name              VARCHAR2(1000) := fnd_api.g_miss_char
   ,reservation_id                  NUMBER   := fnd_api.g_miss_num
   ,Inventory_item_id                NUMBER := fnd_api.g_miss_num
   ,Organization_id                  NUMBER := fnd_api.g_miss_num
   ,Primary_reservation_quantity     NUMBER := fnd_api.g_miss_num
   );
TYPE mtl_failed_rsv_tbl_type is TABLE OF mtl_failed_rsv_rec_type  INDEX BY BINARY_INTEGER;

--
END inv_reservation_global;

 

/
