--------------------------------------------------------
--  DDL for Package WSH_DETAILS_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DETAILS_VALIDATIONS" AUTHID CURRENT_USER as
/* $Header: WSHDDVLS.pls 120.4.12010000.2 2009/12/03 13:59:58 mvudugul ship $ */


TYPE MinMaxInRecType is RECORD (
     api_version_number       NUMBER DEFAULT 1.0,
     source_code              WSH_DELIVERY_DETAILS.SOURCE_CODE%TYPE, -- mandatory parameter
     line_id                  NUMBER, -- source_line_id
     source_header_id         NUMBER, -- Bug 2181132 new field
     source_line_set_id       NUMBER,
     ship_tolerance_above     NUMBER,
     ship_tolerance_below     NUMBER,
     action_flag              VARCHAR2(1) DEFAULT 'P',
     lock_flag                VARCHAR2(1) DEFAULT 'N',
     quantity_uom             VARCHAR2(3),
     quantity_uom2            VARCHAR2(3)
     );

TYPE MinMaxOutRecType is RECORD (
     quantity_uom             VARCHAR2(3),
     min_remaining_quantity   NUMBER,
     max_remaining_quantity   NUMBER,
     quantity2_uom            VARCHAR2(3),
     min_remaining_quantity2  NUMBER,
     max_remaining_quantity2  NUMBER
     );

TYPE MinMaxInOutRecType is RECORD (
     dummy_quantity           NUMBER
     );

-- Bug 2181132
-- change p_out_attributes to x_out_attributes
PROCEDURE Get_Min_Max_Tolerance_Quantity
                ( p_in_attributes           IN     MinMaxInRecType,
                  x_out_attributes          OUT NOCOPY     MinMaxOutRecType,
                  p_inout_attributes        IN OUT NOCOPY  MinMaxInOutRecType,
                  x_return_status           OUT NOCOPY     VARCHAR2,
                  x_msg_count               OUT NOCOPY     NUMBER,
                  x_msg_data                OUT NOCOPY     VARCHAR2
                );


-- Procedure:   check_unassign_from_delivery .
-- Parameters:  p_detailrows
--              x_return_status
-- Description: This procedure checks if the list of delivery details
--              can be unassigned from the delivery they are unassigned to.

PROCEDURE check_unassign_from_delivery(
  p_detail_rows   IN  wsh_util_core.id_tab_type,
  x_return_status OUT NOCOPY  VARCHAR2) ;

--
--  Function:    serial_num_ctl_req
--  Parameters:  p_inventory_item_id
--               p_org_id
--  Description: This function returns a boolean value to
--               indicate if the inventory item in that org is
--               requires a serial number or not
--


FUNCTION serial_num_ctl_req(p_inventory_item_id number, p_org_id number) return BOOLEAN;

-----------------------------------------------------------------------------
--
-- FUNCTION:        Trx_ID
-- Parameters:      p_mode, p_source_line_id, p_source_document_type_id
-- Returns:         number
-- Trx_ID:          It reurns the trx_id depending on the given mode, source
--                  line id and source_document_type_id
-----------------------------------------------------------------------------

FUNCTION trx_id(
    p_mode varchar2,
    p_source_line_id number,
    p_source_document_type_id number) return number;

-- 2467416
PROCEDURE purge_crd_chk_tab;

--
--  Procedure:   Check_Shipped_Quantity
--  Parameters:  p_ship_above_tolerance number,
--               p_requested_quantity number,
--               p_picked_quantity    number,
--               p_shipped_quantity number,
--               p_cycle_count_quantity number,
--               x_return_status       OUT VARCHAR2
--  Description: This procedure validates the entered shipped quantity

PROCEDURE check_shipped_quantity(
    p_ship_above_tolerance IN  number,
    p_requested_quantity   IN  number,
    p_picked_quantity      IN  NUMBER,
    p_shipped_quantity     IN  number,
    p_cycle_count_quantity IN  number,
    x_return_status        OUT NOCOPY  VARCHAR2);

--
--  Procedure:   Check_Cycle_Count_Quantity
--  Parameters:  p_ship_above_tolerance number,
--               p_requested_quantity number,
--               p_picked_quantity    number,
--               p_shipped_quantity number,
--               p_cycle_count_quantity number,
--               x_return_status       OUT VARCHAR2
--  Description: This procedure validates the entered cycle count quantity

PROCEDURE check_cycle_count_quantity(
    p_ship_above_tolerance IN  number,
    p_requested_quantity   IN  number,
    p_picked_quantity      IN  NUMBER,
    p_shipped_quantity     IN  number,
    p_cycle_count_quantity IN  number,
    x_return_status        OUT NOCOPY  VARCHAR2);

/*   Validates and returns the quantity in this manner (the caller does not need
  to adjust the result):
  This routine checks to make sure that the input quantity precision does
  not exceed the decimal precision. Max Precision is: 10 digits before the
  decimall point and 9 digits after the decimal point.
  The routine also makes sure that if the item is serial number controlled,
  the the quantity in primary UOM is an integer number.
  The routine also makes sure that if the item's indivisible_flag is set
  to yes, then the item quantity is an integer in the primary UOM
  The routine also checks if the profile, INV:DETECT TRUNCATION, is set
  to yes, the item quantity in primary UOM also obeys max precision and that
  it is not zero.
  The procedure retruns a correct output quantity in the transaction UOM,
  returns the primary quantity and returns a status of success, failure, or
  warning */
PROCEDURE check_decimal_quantity(
  p_item_id number,
  p_organization_id number,
  p_input_quantity number,
  p_uom_code varchar2,
  x_output_quantity out NOCOPY  number,
  x_return_status  out NOCOPY  varchar2 ,
  p_top_model_line_id  number default NULL,
  p_max_decimal_digits IN NUMBER DEFAULT NULL );
     -- Bug 1890220 : Added p_top_model_line_id at the end so that it works even if its called
     -- without the parameter

-----------------------------------------------------------------------------
--
-- Procedure:   check_assign_del_multi
-- Parameters:    p_detail_rows
--                  x_del_params
--        x_return_status
-- Description:     Checks for if it is ok to group delivery details
--                  together for assign to a single delivery. The procedure
--                  returns an error and sets appropriate messages if any
--                  assignment cannot happen. If assignment is possible then
--                  it returns a table of delivery matching parameters.
--
-----------------------------------------------------------------------------

PROCEDURE check_assign_del_multi(
  p_detail_rows   IN  wsh_util_core.id_tab_type,
  x_del_params    OUT NOCOPY  wsh_delivery_autocreate.grp_attr_rec_type,
  x_return_status OUT NOCOPY  VARCHAR2);


-----------------------------------------------------------------------------
--
-- Procedure:   check_credit_holds
-- Parameters:    p_detail_id
--                  p_activity_type - 'PICK','PACK','SHIP'
--                  p_source_line_id - optional
--                  p_source_header_id - optional
--                  p_init_flag - 'Y' initializes the table of bad header ids
--        x_return_status
-- Description:     Checks if there are any credit checks or holds on a line.
--                  Returns a status of FND_API.G_RET_STS_SUCCESS if no such
--                  checks or holds exist
--
-----------------------------------------------------------------------------

PROCEDURE check_credit_holds(
  p_detail_id     IN  NUMBER,
  p_activity_type IN  VARCHAR2,
  p_source_line_id IN NUMBER DEFAULT NULL,
  p_source_header_id IN NUMBER DEFAULT NULL,
        p_source_code      IN  VARCHAR2,
  p_init_flag     IN  VARCHAR2 DEFAULT 'Y',
  x_return_status OUT NOCOPY  VARCHAR2);


-----------------------------------------------------------------------------
--
-- Procedure:   check_quantity_to_pick
-- Parameters:    p_order_line_id,   - order line being picked
--                      p_quantity_to_pick - quantity to transact that
--                                           will be checked
--                      x_allowed_flag - 'Y' = allowed, 'N' = not allowed
--                      x_max_quantity_allowed - maximum quantity
--                                               that can be picked
--                      x_avail_req_quantity - req quantity not yet staged
--      x_return_status
-- Description:     Checks if the quantity to pick is within overshipment
--                      tolerance, based on the quantities requested and
--                      staged and assignments to deliveries or containers.
--                      Also returns the maximum quantity allowed to pick.
-- -- History    :      HW OPM added x_max_quantity2_allowed and x_avail_req_quantity and p_quantity2_to_pick
-----------------------------------------------------------------------------

PROCEDURE check_quantity_to_pick(
        p_order_line_id          IN  NUMBER,
        p_quantity_to_pick       IN  NUMBER,
        p_quantity2_to_pick      IN  NUMBER DEFAULT NULL,
        x_allowed_flag           OUT NOCOPY  VARCHAR2,
        x_max_quantity_allowed   OUT NOCOPY  NUMBER,
        x_max_quantity2_allowed  OUT NOCOPY  NUMBER,
  x_avail_req_quantity     OUT NOCOPY  NUMBER,
  x_avail_req_quantity2    OUT NOCOPY  NUMBER,
  x_return_status          OUT NOCOPY  VARCHAR2);
--
-- overloaded check_quantity_to_pick since INV patch G is not
-- dependant on WSH patch G.
--

PROCEDURE check_quantity_to_pick(
        p_order_line_id          IN  NUMBER,
        p_quantity_to_pick       IN  NUMBER,
        x_allowed_flag           OUT NOCOPY  VARCHAR2,
        x_max_quantity_allowed   OUT NOCOPY  NUMBER,
        x_avail_req_quantity     OUT NOCOPY  NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2);

--
-- Procedure:           check_zero_req_confirm
-- Parameters:          p_delivery_id      - delivery being confirmed
--                      x_return_status
-- Description:         Ensure that delivery details with zero requested
--                      quantities will not be alone after Ship Confirm.
--

PROCEDURE check_zero_req_confirm(
        p_delivery_id          IN  NUMBER,
        x_return_status        OUT NOCOPY  VARCHAR2);



--
--  Procedure:    Get_Disabled_List
--
--  Parameters:   p_detail_id -- ID for delivery detail
--            p_delivery_id -- delivery the delivery is assigned to
--                p_list_type -- 'FORM', will return list of form field names
--                          'TABLE', will return list of table column names
--                x_return_status  -- return status for execution of this API
--                x_msg_count
--                x_msg_data
--
PROCEDURE Get_Disabled_List(
  p_delivery_detail_id             IN   NUMBER
, p_delivery_id               IN    NUMBER
, p_list_type                           IN   VARCHAR2
, x_return_status                  OUT NOCOPY   VARCHAR2
, x_disabled_list                  OUT NOCOPY   WSH_UTIL_CORE.column_tab_type
, x_msg_count                           OUT NOCOPY    NUMBER
, x_msg_data                            OUT NOCOPY   VARCHAR2
, p_caller IN VARCHAR2 DEFAULT NULL --public api changes
);

--Harmonizing Project
TYPE DetailActionsRec  IS RECORD(
released_status    wsh_delivery_details.released_status%TYPE,
container_flag     wsh_delivery_details.container_flag%TYPE,
source_code        wsh_delivery_details.source_code%TYPE,
caller          VARCHAR2(100),
action_not_allowed      VARCHAR2(100),
org_type        VARCHAR2(30),
message_name    VARCHAR2(2000),
line_direction  VARCHAR2(30),
ship_from_location_id NUMBER,   -- J-IB-NPARIKH
otm_enabled WSH_SHIPPING_PARAMETERS.otm_enabled%TYPE  -- OTM R12 - org specificBug#5399341
);
-- A Column called message_name has been added to the record
-- "DetailActionsRec" so that we can set the exact message
-- for each record as to why an action is not valid.
-- The message_name will contain the message short name
-- and appended with its respective tokens with
-- "-" as a separator between the message name and the
-- tokens and a "," seperator between each of
-- the tokens.

TYPE DetailActionsTabType IS TABLE of  DetailActionsRec  INDEX BY BINARY_INTEGER;

TYPE detail_rec_type IS RECORD
  (delivery_detail_id    NUMBER,
   organization_id       NUMBER,
   released_status       VARCHAR2(32000),
   container_flag        VARCHAR2(32000),
   source_code           VARCHAR2(32000),
   lpn_id                NUMBER,
   line_direction        VARCHAR2(30),
   ship_from_location_id NUMBER,  -- J-IB-NPARIKH
   move_order_line_id    WSH_DELIVERY_DETAILS.MOVE_ORDER_LINE_ID%TYPE, -- R12, X-dock project
   otm_enabled           WSH_SHIPPING_PARAMETERS.otm_enabled%TYPE,   -- OTM R12 - org specific.Bug#5399341
   client_id             NUMBER     -- LSP PROJECT :
);

TYPE detail_rec_tab_type IS TABLE OF detail_rec_type INDEX BY BINARY_INTEGER;

TYPE ValidateQuantityAttrRecType IS RECORD
      (
      delivery_detail_id     NUMBER,
      requested_quantity     NUMBER,
      requested_quantity2    NUMBER,
      picked_quantity        NUMBER,
      picked_quantity2       NUMBER,
      shipped_quantity       NUMBER,
      shipped_quantity2      NUMBER,
      cycle_count_quantity   NUMBER,
      cycle_count_quantity2  NUMBER,
      requested_quantity_uom VARCHAR2(3),
      requested_quantity_uom2 VARCHAR2(3),
      ship_tolerance_above   NUMBER,
      inventory_item_id      NUMBER,
      organization_id        NUMBER,
      serial_quantity        NUMBER,
      inv_ser_control_code   VARCHAR2(1),
      serial_number          VARCHAR2(30),
      transaction_temp_id    NUMBER,
      top_model_line_id      NUMBER,
-- for Load tender add fields
      net_weight             NUMBER,
      gross_weight           NUMBER,
      volume                 NUMBER,
      weight_uom_code        VARCHAR2(3),
      volume_uom_code        VARCHAR2(3),
-- end of Load tender add fields
      unmark_serial_server   VARCHAR2(1) DEFAULT 'Y',
      unmark_serial_form     VARCHAR2(1)
-- HW OPMCONV - Removed process_flag
      );

PROCEDURE Is_Action_Enabled(
                p_del_detail_rec_tab    IN      detail_rec_tab_type,
                p_action                IN      VARCHAR2,
                p_caller                IN      VARCHAR2,
                p_deliveryid                IN      NUMBER DEFAULT null,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_valid_ids             OUT NOCOPY      wsh_util_core.id_tab_type,
                x_error_ids             OUT NOCOPY      wsh_util_core.id_tab_type,
                x_valid_index_tab       OUT NOCOPY      wsh_util_core.id_tab_type );

--
-- Overloaded procedure
--
PROCEDURE Get_Disabled_List  (
  p_delivery_detail_rec   IN  WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type
, p_delivery_id           IN  NUMBER
, p_in_rec		  IN  WSH_GLBL_VAR_STRCT_GRP.detailInRecType
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, x_delivery_detail_rec   OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type
);

PROCEDURE Init_Detail_Actions_Tbl (
  p_action                   IN                VARCHAR2
, x_detail_actions_tab       OUT  NOCOPY             DetailActionsTabType
, x_return_status            OUT  NOCOPY             VARCHAR2
);

Procedure Validate_Shipped_CC_Quantity
    (
    p_flag          IN       VARCHAR2,
    x_det_rec       IN OUT NOCOPY  ValidateQuantityAttrRecType,
    x_return_status OUT NOCOPY     VARCHAR2,
    x_msg_count     OUT NOCOPY     NUMBER,
    x_msg_data      OUT NOCOPY     VARCHAR2
    );

--Harmonizing Project

-- HW Harmonization project for OPM
Procedure Validate_Shipped_CC_Quantity2
    (
    p_flag          IN       VARCHAR2,
    x_det_rec       IN OUT NOCOPY  ValidateQuantityAttrRecType,
    x_return_status OUT NOCOPY     VARCHAR2,
    x_msg_count     OUT NOCOPY     NUMBER,
    x_msg_data      OUT NOCOPY     VARCHAR2
    );

--for Load Tender Project
/*
-----------------------------------------------------------------------------
   PROCEDURE  : Compare_Detail_Attributes
   PARAMETERS : p_old_table - Table of old records
                p_new_table - Table of new records
                p_entity - entity name -DELIVERY_DETAIL
                p_action_code - action code for each action
                p_phase - 1 for Before the action is performed, 2 for after.
                p_caller - where is this API being called from
                x_changed_id - Table of Changed ids
                x_return_status - Return Status
  DESCRIPTION : This procedure compares the attributes for each entity.
                For Delivery Detail,attributes are - weight/volume,quantity,
                delivery,parent_delivery_detail
                Added for Load Tender Project
------------------------------------------------------------------------------
*/
PROCEDURE compare_detail_attributes
  (p_old_table     IN wsh_interface.deliverydetailtab,
   p_new_table     IN wsh_interface.deliverydetailtab,
   p_action_code   IN VARCHAR2,
   p_phase         IN NUMBER,
   p_caller        IN VARCHAR2,
   x_changed_id_tab OUT NOCOPY wsh_util_core.id_tab_type,
   x_return_status OUT NOCOPY VARCHAR2
   );

--End for Load Tender Project


-- ----------------------------------------------------------------------
-- Procedure:   validate_secondary_quantity
-- Parameters:
--
-- Description:
--  ----------------------------------------------------------------------
-- HW OPMCONV - Added p_caller parameter
PROCEDURE validate_secondary_quantity
            (
               p_delivery_detail_id  IN              NUMBER,
               x_quantity            IN OUT NOCOPY   NUMBER,
               x_quantity2           IN OUT NOCOPY   NUMBER,
               p_caller              IN              VARCHAR2,
               x_return_status       OUT    NOCOPY   VARCHAR2,
               x_msg_count           OUT    NOCOPY   NUMBER,
               x_msg_data            OUT    NOCOPY   VARCHAR2
            );

-- HW OPMCONV - Added new function to check if line
/*
-----------------------------------------------------------------------------
   FUNCTION   : is_split_allowed
   PARAMETERS : p_delivery_detail_id - delivery detail id
                p_organization_id    - organization id
                p_inventory_item_id  - inventory item id
                p_released_status    - released status for this wdd line

  DESCRIPTION : This function checks if delivery detail line
                is eligible for a split
                e.g if delivery detail has an item that is lot
                indivisible and it's staged, split actions will not be permitted
------------------------------------------------------------------------------
*/
FUNCTION is_split_allowed(
           p_delivery_detail_id  IN  NUMBER,
           p_organization_id     IN  NUMBER,
           p_inventory_item_id   IN  NUMBER,
           p_released_status     IN  VARCHAR2) RETURN BOOLEAN;
/*
-----------------------------------------------------------------------------
   FUNCTION   : is_cycle_count_allowed
   PARAMETERS : p_delivery_detail_id - delivery detail id
                p_organization_id    - organization id
                p_inventory_item_id  - inventory item id
                p_released_status    - released status for this wdd line
                p_picked_qty         - total allocated qty for this wdd line
                p_cycle_qty          - qty to be cycle counted

  DESCRIPTION : This function checks if delivery detail line
                is eligible for a cycle count.
                e.g if delivery detail has an item that is lot
                indivisible and it's staged, only picked qty cycle count is allowed
------------------------------------------------------------------------------
*/
FUNCTION is_cycle_count_allowed(
           p_delivery_detail_id  IN  NUMBER,
           p_organization_id     IN  NUMBER,
           p_inventory_item_id   IN  NUMBER,
           p_released_status     IN  VARCHAR2,
           p_picked_qty          IN  NUMBER,
           p_cycle_qty           IN  NUMBER) RETURN BOOLEAN;

END WSH_DETAILS_VALIDATIONS;

/
