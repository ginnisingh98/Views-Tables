--------------------------------------------------------
--  DDL for Package WMS_SEARCH_ORDER_GLOBALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_SEARCH_ORDER_GLOBALS_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSSOGBS.pls 120.1 2005/07/18 05:21:47 ajohnson noship $ */

-- File        : WMSSOGBS.pls
-- Content     : WMS_SEARCH_ORDER_GLOBALS_PVT package body
-- Description : This API is created  to store Rules Engine Process flow
--               Variabls. This API  Gobal Variable will be updated by
---              WMS_RULES_ENGINE_PVT  and to be refrenced by WMSRLSIM.fmb

-- Notes       :
-- List of  Pl/SQL Tables,Functions and  Procedures
--
-- TYPE  pre_suggestions_record  IS RECORD
-- TYPE pre_suggestions_record_tbl  IS TABLE
-- FUNCTION get_object_type ( engine_type IN VARCHAR2) RETURN  VARCHAR2;
-- FUNCTION get_object_name ( engine_type IN VARCHAR2, org_id number) RETURN  VARCHAR2;
-- FUNCTION get_strategy_name ( engine_type IN VARCHAR2, org_id IN NUMBER)  RETURN  VARCHAR2;
-- FUNCTION get_rule_name ( engine_type IN VARCHAR2, org_id IN NUMBER)  RETURN  VARCHAR2;
-- FUNCTION get_costgroup_name ( engine_type IN VARCHAR2 , org_id IN NUMBER ) RETURN  VARCHAR2;
-- FUNCTION get_costgroup_desc( engine_type IN VARCHAR2, org_id IN NUMBER ) RETURN  VARCHAR2;
-- FUNCTION get_costgroup_desc( engine_type IN VARCHAR2, org_id IN NUMBER ) RETURN  VARCHAR2;
-- FUNCTION  IS_Object_selected(..) return ;
-- FUNCTION  IS_BO_Object_selected(..) return ;
-- Procedure  init_global_variables;
-- procedure simulate_rules( mo_line_id ..);
-- procedure insert_trace_header(..);
-- procedure insert_trace_lines(..)
-- Procedure insert_headers_row;
-- Procedure insert_lines_row;
-- procedure delete_trace_rows;
-- procedure insert_txn_trace_rows(p_txn_header_id, p_insert_lot_flag, p_insert_serial_flag);
-- Procedure set_global_variables (p_move_order_line_id );
-- Created By  : Grao 06/21/01    Created
-- ---------   ------  ------------------------------------------

---- Trace Global Variables ------------

G_PICK_HEADER_ID 		NUMBER   := 0 ;
G_PUTAWAY_HEADER_ID		NUMBER   := 0 ;




  --- Pick Search order Global Variables

G_PICK_BUSINESS_OBJECT_ID       NUMBER := NULL;
G_PICK_OBJECT                   VARCHAR2(50);
G_PICK_PK1_VALUE                VARCHAR2(150);
G_PICK_PK2_VALUE                VARCHAR2(150);
G_PICK_PK3_VALUE                VARCHAR2(150);
G_PICK_PK4_VALUE                VARCHAR2(150);
G_PICK_PK5_VALUE                VARCHAR2(150);
G_PICK_STRATEGY_ID              NUMBER := NULL;
G_PICK_RULE_ID                  NUMBER := NULL;

G_PICK_SEQ_NUM                  NUMBER := NULL;


  --- Putaway  Search order Global Variables

G_PUTAWAY_BUSINESS_OBJECT_ID    NUMBER := NULL;
G_PUTAWAY_OBJECT                VARCHAR2(50);
G_PUTAWAY_PK1_VALUE             VARCHAR2(150);
G_PUTAWAY_PK2_VALUE             VARCHAR2(150);
G_PUTAWAY_PK3_VALUE             VARCHAR2(150);
G_PUTAWAY_PK4_VALUE             VARCHAR2(150);
G_PUTAWAY_PK5_VALUE             VARCHAR2(150);
G_PUTAWAY_STRATEGY_ID           NUMBER := NULL;
G_PUTAWAY_RULE_ID               NUMBER := NULL;

G_PUTAWAY_SEQ_NUM               NUMBER := NULL;


  --- Cost Group Search order Global Variables

G_COSTGROUP_BUSINESS_OBJECT_ID  NUMBER := NULL;
G_COSTGROUP_OBJECT               VARCHAR2(50);
G_COSTGROUP_PK1_VALUE           VARCHAR2(150);
G_COSTGROUP_PK2_VALUE           VARCHAR2(150);
G_COSTGROUP_PK3_VALUE           VARCHAR2(150);
G_COSTGROUP_PK4_VALUE           VARCHAR2(150);
G_COSTGROUP_PK5_VALUE           VARCHAR2(150);
G_COSTGROUP_STRATEGY_ID         NUMBER := NULL;
G_COSTGROUP_RULE_ID             NUMBER := NULL;

G_COSTGROUP_SEQ_NUM             NUMBER := NULL;


G_COSTGROUP_ID                  NUMBER := NULL;
-------------------------- To identify if Trace records or created for Simulation mode or Rule Execution Mode
---- Default Non Simulation mode 'N' and for Simulation mode 'Y'
G_SIMULATION_MODE            VARCHAR2(1) DEFAULT 'N' ;

---------------------------------------------------------------------
-- Record type definition for a rule trace record in cache
--  Values for
--
-- Other Value used for these Flags are 'P' Partial Success and 'V' Default Value

--  same_subinv_loc_flag        Default NULL, Success - 'Y'  Failure - 'N'
--  ATT_qty_flag                Default NULL, Success - 'Y'  Failure - 'N'
--  consist_string_flag         Default NULL, Success - 'Y'  Failure - 'N'
--  order_string_flag           Default NULL, Success - 'Y'  Failure - 'N'
--  Material_status_flag        Default NULL, Success - 'Y'  Failure - 'N'
--  Pick_UOM_flag               Default NULL, Success - 'Y'  Failure - 'N'
--  partial_pick_flag           Default NULL, Success - 'Y'  Failure - 'N'
--  Serial_number_used_flag     Default NULL, Success - 'Y'  Failure - 'N'
--  CG_comingle_flag            Default NULL, Success - 'Y'  Failure - 'N'

TYPE  pre_suggestions_record  IS RECORD
  (
  revision                      wms_transactions_temp.revision%TYPE,
  quantity                      wms_transactions_temp.transaction_quantity%TYPE,
  lot_number                    wms_transactions_temp.lot_number%TYPE,
  lot_expiration_date           wms_transactions_temp.lot_expiration_date%TYPE,
  serial_number                 wms_transactions_temp.serial_number%TYPE,
  subinventory_code             wms_transactions_temp.from_subinventory_code%TYPE,
  locator_id                    wms_transactions_temp.from_locator_id%TYPE,
  lpn_id                        wms_transactions_temp.lpn_id%TYPE,
  cost_group_id                 wms_transactions_temp.to_cost_group_id%TYPE,
  uom_code                      VARCHAR2(3),
  remaining_qty                 wms_transactions_temp.transaction_quantity%TYPE,
  ATT_qty                       wms_transactions_temp.transaction_quantity%TYPE,
  suggested_qty                 wms_transactions_temp.transaction_quantity%TYPE,
  -- LG convergence added
  secondary_qty                 wms_transactions_temp.secondary_quantity%TYPE,
  secondary_remaining_qty       wms_transactions_temp.secondary_quantity%TYPE,
  secondary_att_qty             wms_transactions_temp.secondary_quantity%TYPE,
  secondary_suggested_qty       wms_transactions_temp.secondary_quantity%TYPE,
  secondary_uom_code            VARCHAR2(3),
  grade_code                    VARCHAR2(150),
  -- End of LG convergence
  same_subinv_loc_flag          VARCHAR2(1),
  ATT_qty_flag                  VARCHAR2(1),
  consist_string_flag           VARCHAR2(1),
  order_string_flag             VARCHAR2(1),
  Material_status_flag          VARCHAR2(1),
  Pick_UOM_flag                 VARCHAR2(1),
  partial_pick_flag             VARCHAR2(1),
  Serial_number_used_flag       VARCHAR2(1),
  entire_lpn_flag               VARCHAR2(1),
  CG_comingle_flag              VARCHAR2(1),
  comments			VARCHAR2(2000)
   );


--------------------------------------------------------------------
-- Definition of table types for the caches
TYPE pre_suggestions_record_tbl  IS TABLE OF pre_suggestions_record
  INDEX BY BINARY_INTEGER;

-- LG convergence
TYPE  available_inventory_record  IS RECORD
(
  revision                      VARCHAR2(30)
 ,lot_number                    VARCHAR2(80)
 ,lot_expiration_date           date
 ,subinventory_code             varchar2(30)
 ,locator_id                    NUMBER
 ,cost_group_id                 NUMBER
 ,transaction_uom               varchar2(5)
 ,lpn_id                        NUMBER
 ,serial_number                 VARCHAR2(30)
 ,onhand_qty                    NUMBER
 ,secondary_onhand_qty          NUMBER
 ,grade_code                    VARCHAR2(150)
 ,consist_string                VARCHAR2(200)
 ,order_by_string               VARCHAR2(200)
);

-- Definition of table types for the caches
TYPE available_inventory_tbl  IS TABLE OF available_inventory_record
  INDEX BY BINARY_INTEGER;

g_available_inv_tbl  WMS_SEARCH_ORDER_GLOBALS_PVT.available_inventory_tbl;
-- end of LG convergence

-----------------------------------------
---  Function to get the business_object_type name based on the G_PICK_BUSINESS_OBJECT_ID /
---- G_PUTAWAY_BUSINESS_OBJECT_ID/G_COSTGROUP_BUSINESS_OBJECT_ID
---  G_PICK_BUSINESS_OBJECT_ID / G_PUTAWAY_BUSINESS_OBJECT_IDis /
---- G_COSTGROUP_BUSINESS_OBJECT_ID get updated by Rules Engine API


  FUNCTION get_object_type
     ( engine_type IN VARCHAR2)
    RETURN  VARCHAR2;
-----------------------------------------
---  Function to get the object_ name based on the G_PICK_BUSINESS_OBJECT_ID /
---- G_PUTAWAY_BUSINESS_OBJECT_ID/G_COSTGROUP_BUSINESS_OBJECT_ID
---  G_PICK_BUSINESS_OBJECT_ID / G_PUTAWAY_BUSINESS_OBJECT_IDis /
---- G_COSTGROUP_BUSINESS_OBJECT_ID , ORGANIZATIONS_ID, PK_VALUES get updated by Rules Engine API



  FUNCTION get_object_name
     ( engine_type IN VARCHAR2,
       org_id number)
    RETURN  VARCHAR2;

--- Function to get the Strategy name based on the G_PICK_STRATEGY_ID /G_PUTAWAY_STRATEGY_ID
--- G_PICK_STRATEGY_ID /G_PUTAWAY_STRATEGY_ID  is get updated by Rules Engine API

 FUNCTION get_strategy_name
     ( engine_type IN VARCHAR2
          , org_id IN NUMBER
            )
 RETURN  VARCHAR2;


-- Function to get the Rule name based on the  G_COSTGROUP_RULE_ID
-- G_COSTGROUP_RULE_ID    is get updated by Rules Engine API


 FUNCTION get_rule_name
     ( engine_type IN VARCHAR2
          , org_id IN NUMBER
            )
 RETURN  VARCHAR2;


-- Function to get the Cost Group name based on the  G_COSTGROUP_ID
-- G_COSTGROUP_ID  is updated by Rules Engine API


 FUNCTION get_costgroup_name
     ( engine_type IN VARCHAR2
          , org_id IN NUMBER
            )
 RETURN  VARCHAR2;

-- Function to get the Cost Group Desc based on the  G_COSTGROUP_ID
-- G_COSTGROUP_ID  is updated by Rules Engine API


 FUNCTION get_costgroup_desc
     ( engine_type IN VARCHAR2
          , org_id IN NUMBER
            )
 RETURN  VARCHAR2;

 ---- Initilize All Global Variables
 ----
 Procedure  init_global_variables;

 ---- Call Rules Engine - Create Suggestions ---
 ---------------------------------------------

 procedure simulate_rules
        ( p_mo_line_id 	       IN   VARCHAR2,
          p_simulation_flag      IN   NUMBER,
          p_simulation_id        IN   NUMBER,
          x_msg_data             OUT  NOCOPY varchar2,
          x_return_status        OUT  NOCOPY varchar2,
          x_return_status_qty    OUT  NOCOPY varchar2
         );

----------------Insert into Trace header table ------

 procedure insert_trace_header
  (
    p_api_version         	in  NUMBER
   ,p_init_msg_list       	in  VARCHAR2  DEFAULT fnd_api.g_false
   ,p_validation_level    	in  NUMBER   DEFAULT fnd_api.g_valid_level_full
   ,x_return_status       	out NOCOPY VARCHAR2
   ,x_msg_count           	out NOCOPY NUMBER
   ,x_msg_data            	out NOCOPY VARCHAR2
   ,x_header_id 		out NOCOPY NUMBER
   ,p_pick_header_id 	        in  NUMBER
   ,p_move_order_line_id        in  NUMBER
   ,p_total_qty                 in  NUMBER
   ,p_secondary_total_qty       in  NUMBER
   ,p_type_code 		in  NUMBER
   ,p_business_object_id        in  NUMBER
   ,p_object_id 		in  NUMBER
   ,p_strategy_id       	in  NUMBER
  );

 --------------- Insert into trace lines table -------

 procedure insert_trace_lines
  (
    p_api_version         	in  NUMBER
   ,p_init_msg_list       	in  VARCHAR2  DEFAULT fnd_api.g_false
   ,p_validation_level    	in  NUMBER   DEFAULT fnd_api.g_valid_level_full
   ,x_return_status       	out NOCOPY VARCHAR2
   ,x_msg_count           	out NOCOPY number
   ,x_msg_data            	out NOCOPY varchar2
   ,p_header_id  		in  NUMBER
   ,p_rule_id                   in  NUMBER
   ,p_pre_suggestions           IN  WMS_SEARCH_ORDER_GLOBALS_PVT.pre_suggestions_record_tbl
    );
--------------------- called  internally to insert  a single row into trace headers
 Procedure   insert_headers_row
     (
     x_header_id  		IN  NUMBER,
     x_pick_header_id           IN  NUMBER,
     x_move_order_line_id	IN  NUMBER,
     x_total_qty                IN  NUMBER,
     x_secondary_total_qty      IN  NUMBER,                         -- new
     x_type_code                IN  NUMBER,
     x_business_object_id       IN  NUMBER,
     x_object_id                IN  NUMBER,
     x_strategy_id              IN  NUMBER,
     x_last_updated_by          IN  NUMBER,
     x_last_update_date         IN  DATE ,
     x_created_by               IN  NUMBER ,
     x_creation_date            IN  DATE   ,
     x_last_update_login        IN  NUMBER ,
     x_object_name              IN  VARCHAR2,
     x_simulation_mode          IN  VARCHAR2,
     x_sid                      IN  NUMBER
        ) ;

--------------------- called  internally to insert  a single row into trace lines
Procedure   insert_lines_row
     (
       x_header_id                       IN  NUMBER
      ,x_line_id                         IN  NUMBER
      ,x_rule_id                         IN  NUMBER
      ,x_quantity                        IN  NUMBER
      ,x_revision                        IN  VARCHAR2
      ,x_lot_number                      IN  VARCHAR2
      ,x_lot_expiration_date             IN  DATE
      ,x_serial_number                   IN  VARCHAR2
      ,x_subinventory_code               IN  VARCHAR2
      ,x_locator_id                      IN  NUMBER
      ,x_lpn_id                          IN  NUMBER
      ,x_cost_group_id                   IN  NUMBER
      ,x_uom_code                        IN  VARCHAR2
      ,x_remaining_qty                   IN  NUMBER
      ,x_ATT_qty                         IN  NUMBER
      ,x_suggested_qty                   IN  NUMBER
      ,x_sec_uom_code                    IN  VARCHAR2                  -- new
      ,x_sec_qty                         IN  NUMBER                    -- new
      ,x_sec_ATT_qty                     IN  NUMBER                    -- new
      ,x_sec_suggested_qty               IN  NUMBER                    -- new
      ,x_grade_code                      IN  VARCHAR2                  -- new
      ,x_same_subinv_loc_flag            IN  VARCHAR2
      ,x_ATT_qty_flag                    IN  VARCHAR2
     , x_consist_string_flag             IN  VARCHAR2
     , x_order_string_flag               IN  VARCHAR2
      ,x_Material_status_flag            IN  VARCHAR2
      ,x_Pick_UOM_flag                   IN  VARCHAR2
      ,x_partial_pick_flag               IN  VARCHAR2
      ,x_Serial_number_used_flag         IN  VARCHAR2
      ,x_CG_comingle_flag                IN  VARCHAR2
      ,x_entire_lpn_flag                 IN  VARCHAR2
      ,x_comments                        IN  VARCHAR2
      ,x_creation_date                   IN  DATE
      ,x_created_by                      IN  NUMBER
      ,x_last_update_date                IN  DATE
      ,x_last_updated_by                 IN  NUMBER
      ,x_last_update_login               IN  NUMBER
         ) ;
-----------------------------------
-- Function that return 'TRUE' and 'FALSE' if the passed item_id is
-- in Global Variables

 FUNCTION  IS_Object_selected ( p_move_order_line_id number,
                                p_engine_type Varchar2,
                                p_object_type varchar2,
                                p_object_id number )
   RETURN  VARCHAR2;
-------------- Overloaded Function --------------
FUNCTION  IS_BO_Object_selected ( p_move_order_line_id number,
                                p_engine_type Varchar2,
                                p_object_type varchar2,
                                p_object Varchar2 )
   RETURN  VARCHAR2;

PROCEDURE DELETE_TRACE_ROWS;

---------------------------------------------------
--- This procedure call is used to populate records into
--- Three temp table one for each material suggestions, lot numbers
--- and serial number tables. Lot and Serial Tables will be populated
--- based on the lot_insert_flag and serial_insert_flags
--- '0' - for no records to be inserted and '1' for records to be inserted
--- The data in these three tables will be used by Run Time trace form

 procedure insert_txn_trace_rows(
    p_api_version               in  NUMBER
   ,p_init_msg_list             in  VARCHAR2  DEFAULT fnd_api.g_false
   ,p_validation_level          in  NUMBER    DEFAULT fnd_api.g_valid_level_full
   ,x_return_status             out NOCOPY VARCHAR2
   ,x_msg_count                 out NOCOPY number
   ,x_msg_data                  out NOCOPY varchar2
   ,p_txn_header_id             in  number
   ,p_insert_lot_flag           in  number
   ,p_insert_serial_flag        in  number);

---------------------------------------------------------------------------------------
---- This procedure is used by 'Run time trace form' to set the
---- global variables based on WMS_RULE_TRACE_HEADERS record for a given move order
---- so that the actual traceed path could be shown in the form.

procedure set_global_variables(
    p_move_order_line_id        in  NUMBER
   ,p_trace_date                in  DATE
   ,x_return_status             out NOCOPY VARCHAR2);
-------------------------------------------------
--- get Pick or Putaway header id from global variables

 FUNCTION get_trace_line_header_id
     ( engine_type IN VARCHAR2 )
    RETURN  NUMBER;

 FUNCTION get_strategy_id( p_rule_type IN NUMBER )
    RETURN  NUMBER;

   FUNCTION get_rule_id( p_rule_type IN NUMBER )
    RETURN  NUMBER;


 FUNCTION get_seq_num ( p_rule_type IN NUMBER )
    RETURN  NUMBER;



END; -- Package Specification WMS_SEARCH_ORDER_GLOBALS_PVT

 

/
