--------------------------------------------------------
--  DDL for Package INV_MATERIAL_STATUS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MATERIAL_STATUS_GRP" AUTHID CURRENT_USER as
/* $Header: INVMSGRS.pls 120.6.12010000.7 2012/01/03 10:05:05 sadibhat ship $ */

g_allow_status_entry VARCHAR2(3)   := NVL(fnd_profile.VALUE('INV_ALLOW_ONHAND_STATUS_ENTRY'), 'N');  /* Material status enhancement - Tracking bug: 13519864 */

------------------------------------------------------------------------------
-- Function
--   is_trx_allowed
--
-- Description
--  check to see if the input status allows the input transaction
--  type or not
--
-- Return
--        'Y': allowed or any error occurred
--        'N': disallowed
-- Input Paramters
--
--   p_status_id                input status id
--   p_transaction_type_id      input transaction_type
--
-- Output Parameters
--   x_return_status            = fnd_api.g_ret_sts_success, if succeeded
--                              = fnd_api.g_ret_sts_exc_error, if an expected
--                              error occurred
--                              = fnd_api.g_ret_sts_unexp_error, if
--                              an unexpected error occurred
--
--   x_msg_count                Number of error message in the error message
--                              list
--
--   x_msg_data                 If the number of error message in the error
--                              message list is one, the error message
--                              is in this output parameter
--
------------------------------------------------------------------------------

FUNCTION  is_trx_allowed
  (
     p_status_id                 IN NUMBER
   , p_transaction_type_id       IN NUMBER
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   ) return varchar2;
------------------------------------------------------------------------------
--LPN Status Project
-- Function
--   is_status_applicable_lpns
--
-- Description
--  check to see for the validation of the on-hand status for this transaction
--
-- Return
--    0 would indicate that both the validations are successful and the transaction can be performed
--    1 would indicate that the transaction would result in Mixed Status in the LPN
--                 or in the other LPNs in the Outer LPN or in the Outer LPN itself.
--                 The message WMS_RESULTS_MIXED_STATUS is thrown to the user
--    2 indicate that this transaction is not allowed for the status of the source material or for the destination
--                 The message WMS_DISALLOW_TRANSACTION is thrown to the user
--
-- Input Paramters
--
--   p_wms_installed            input WMS Installed parameter
--   p_trx_status_enabled       input transaction status enabled or not
--   p_trx_type_id		input transaction type
--   p_lot_status_enabled	input lot status enabled or not
--   p_serial_status_enabled	input serial status or not
--   p_organization_id		input organization id
--   p_inventory_item_id	input inventory item identifier
--   p_sub_code			input subinventory
--   p_locator_id		input locator
--   p_lot_number		input lot number
--   p_serial_number		input serial number
--   p_object_type		input object type
--   p_fromlpn_id		input from LPN ID
--   p_xfer_lpn_id		input transfer LPN ID
--   p_xfer_sub_code		input transfer sub-inventory code
--   p_xfer_locator_id		input transfer locator
--   p_xfer_org_id		input transfer organization
------------------------------------------------------------------------------



FUNCTION is_status_applicable_lpns
	            (p_wms_installed              IN VARCHAR2,
                           p_trx_status_enabled        IN NUMBER,
                           p_trx_type_id                    IN NUMBER,
                           p_lot_status_enabled         IN VARCHAR2,
                           p_serial_status_enabled    IN VARCHAR2,
                           p_organization_id              IN NUMBER,
                           p_inventory_item_id         IN NUMBER,
                           p_sub_code                        IN VARCHAR2,
                           p_locator_id                       IN NUMBER,
                           p_lot_number                     IN VARCHAR2,
                           p_serial_number                 IN VARCHAR2,
                           p_object_type                     IN VARCHAR2,
			   p_fromlpn_id	             IN NUMBER,
			   p_xfer_lpn_id	             IN NUMBER,
			   p_xfer_sub_code		IN VARCHAR2,
			   p_xfer_locator_id	        IN NUMBER,
			   p_xfer_org_id		IN NUMBER)
RETURN NUMBER;
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Procedure
--   get_lot_serial_status_control
--
-- Description
--  Inquire if the item is under lot status controlled, serial status controlled
--  and corresponding default statuses
--
-- Input Paramters
--
--   p_organization_id             organization the item resides in
--   p_inventory_item_id           given item id we query for
--
-- Output Parameters
--   x_return_status            = fnd_api.g_ret_sts_success, if succeeded
--                              = fnd_api.g_ret_sts_exc_error, if an expected
--                              error occurred
--                              = fnd_api.g_ret_sts_unexp_error, if
--                              an unexpected error occurred
--
--   x_msg_count                Number of error message in the error message
--                              list
--
--   x_msg_data                 If the number of error message in the error
--                              message list is one, the error message
--                              is in this output parameter
--   x_lot_status_enabled       Indicate if the item is lot status controlled
--                              'Y': YES    'N': NO
--   x_default_lot_status_id    default lot status ID
--   x_serial_status_enabled    Indicate if the item is serial status controlled
--                              'Y': YES    'N': NO
--   x_default_serial_status_id    default serial status ID
------------------------------------------------------------------------------
PROCEDURE get_lot_serial_status_control
(
     p_organization_id                  IN NUMBER
   , p_inventory_item_id                IN NUMBER
   , x_return_status                    OUT NOCOPY VARCHAR2
   , x_msg_count                        OUT NOCOPY NUMBER
   , x_msg_data                         OUT NOCOPY VARCHAR2
   , x_lot_status_enabled               OUT NOCOPY VARCHAR2
   , x_default_lot_status_id            OUT NOCOPY NUMBER
   , x_serial_status_enabled            OUT NOCOPY VARCHAR2
   , x_default_serial_status_id         OUT NOCOPY NUMBER
);

------------------------------------------------------------------------------
-- Function
-- is_status_applicable
--
-- Description
--  check if the sub, locator, lot, serial is applicable for certain transaction type
--  based on its status
--
-- Input Paramters
--
--   p_wms_installed               Indicate if WMS is installed
--                                 passing 'TRUE' or 'FALSE'
--   p_trx_status_enabled          Indicate if the transaction type is status control
--                                 Enabled or not
--                                 passing 1 for enabled, 2 for disabled
--                                 this is optional, passing this value can increase the
--                                 the processing speed
--   p_trx_type_id                 transaction type id
--   p_lot_status_enabled          Indicate if the item is lot status control
--                                 Enabled or not
--                                 passing 'Y' for enabled, 'N' for disabled
--                                 this is optional, passing this value can increase the
--                                 the processing speed
--   p_serial_status_enabled       Indicate if the item is serial status control
--                                 Enabled or not
--                                 passing 'Y' for enabled, 'N' for disabled
--                                 this is optional, passing this value can increase the
--                                 the processing speed
--   p_organization_id             organization id the item resides in
--   p_inventory_item_id           given item id we query for
--   p_sub_code                    subinventory code
--   p_locator_id                  locator id
--   p_lot_number                  lot number
--   p_serial_number               serial number
--   p_lpn_id                      lpn_id -- Onhand Material Status Support
--   p_object_type                 this parameter is for performance purpose
--                                 must be specified to get the proper function
--                                 'Z' checking zone (subinventory)
--                                 'L' checking locator
--                                 'O' checking lot
--                                 'S' checking serial
--                                 'A' checking all including sub, locator, lot, serial
--
--
--  Return:
--     'Y'  the given object's status allow the given transaction type or any error occurred
--     'N'  the given object's status disallow the given transaction type
--
-- Usage:
--    p_wms_installed must be specified.
--    TO check any object (sub, locator, lot or serial) is applicable or not,
--    p_trx_type_id, p_organization_id, p_object_type must be specified.
--    Additionally,
--    to check subinventory, p_sub_code must be specified;
--    to check locator, p_locator_id must be specified;
--    to check lot,p_inventory_item_id, p_lot_number must be specified
--    to check serial, p_inventory_item_id, p_serial_number must be specified
--
--    p_trx_status_enabled is optional for all checkings
--    p_lot_status_enabledled is optional for checking lot status,
--    p_serial_status_enabled is optional for checking serial status
--    The default value is NULL for all input parameters except p_wms_installed
-------------------------------------------------------------------------------------------------------

Function is_status_applicable(p_wms_installed           IN VARCHAR2:=NULL,
                           p_trx_status_enabled         IN NUMBER:=NULL,
                           p_trx_type_id                IN NUMBER:=NULL,
                           p_lot_status_enabled         IN VARCHAR2:=NULL,
                           p_serial_status_enabled      IN VARCHAR2:=NULL,
                           p_organization_id            IN NUMBER:=NULL,
                           p_inventory_item_id          IN NUMBER:=NULL,
                           p_sub_code                   IN VARCHAR2:=NULL,
                           p_locator_id                 IN NUMBER:=NULL,
                           p_lot_number                 IN VARCHAR2:=NULL,
                           p_serial_number              IN VARCHAR2:=NULL,
                           p_object_type                IN VARCHAR2:=NULL)
return varchar2;

------------------------------------------------------------------------------
-- Overloaded function for the Onhand Material Status Support
-- Function      is_status_applicable
-- Description   overloaded function.
-- p_lpn_id    new parameter lpn_id
-------------------------------------------------------------------------------------------------------

Function is_status_applicable(p_wms_installed           IN VARCHAR2:=NULL,
                           p_trx_status_enabled         IN NUMBER:=NULL,
                           p_trx_type_id                IN NUMBER:=NULL,
                           p_lot_status_enabled         IN VARCHAR2:=NULL,
                           p_serial_status_enabled      IN VARCHAR2:=NULL,
                           p_organization_id            IN NUMBER:=NULL,
                           p_inventory_item_id          IN NUMBER:=NULL,
                           p_sub_code                   IN VARCHAR2:=NULL,
                           p_locator_id                 IN NUMBER:=NULL,
                           p_lot_number                 IN VARCHAR2:=NULL,
                           p_serial_number              IN VARCHAR2:=NULL,
                           p_object_type                IN VARCHAR2:=NULL,
                           p_lpn_id                     IN NUMBER) -- Onhand Material Status Support
return varchar2;

------------------------------------------------------------------------------

-- Procedure
-- update_status
--
-- Description
--  update status of  sub, locator, lot, serial
--
-- Input Paramters
--   p_api_version_number       API version number (current version is 1.0)
--   p_init_msg_lst             Whether initialize the error message list or
--                              not.
--                              Should be fnd_api.g_false or fnd_api.g_true
--   p_update_method               update method, refer to the global constant
--                                 definition in INVMSPUB.pls
--   p_status_id                   status_id which should be changed to
--   p_organization_id             organization the item resides in
--   p_inventory_item_id           given item id we query for
--   p_sub_code                    subinventory code
--   p_locator_id                  locator id
--   p_lot_number                  lot number
--   p_serial_number               serial number
--   p_lpn_id                      lpn id -- Onhand Material Status Support
--   p_object_type                 this parameter is for performance purpose
--                                 must be specified for the proper function
--                                 'Z' checking zone (subinventory)
--                                 'L' checking locator
--                                 'O' checking lot
--                                 'S' checking serial
--   p_update_reason_id            update reason id which is a primary key in
-- 				   MTL_transaction_reasons
--   p_initial_status_flag         To track the first status assigned to the entity.

----------------------------------------------------------------------------------------
PROCEDURE update_status
  (  p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_update_method              IN NUMBER
   , p_status_id                  IN NUMBER
   , p_organization_id            IN NUMBER
   , p_inventory_item_id          IN NUMBER:=NULL
   , p_sub_code                   IN VARCHAR2:=NULL
   , p_locator_id                 IN NUMBER:=NULL
   , p_lot_number                 IN VARCHAR2:=NULL
   , p_serial_number              IN VARCHAR2:=NULL
   , p_to_serial_number           IN VARCHAR2:=NULL
   , p_object_type                IN VARCHAR2
   , p_update_reason_id           IN NUMBER:=NULL
   , p_lpn_id                     IN NUMBER:=NULL -- Onhand Material Status Support
   , p_initial_status_flag        IN VARCHAR2:='N' -- Onhand Material Status Support
   );

----------------------------------------------------------------------------------------
--Function added for Bug# 2879164
FUNCTION loc_valid_for_item(p_loc_id             NUMBER:=NULL,
                            p_org_id             NUMBER:=NULL,
                            p_inventory_item_id  NUMBER:=NULL,
                            p_sub_code           VARCHAR2:=NULL)
RETURN VARCHAR2;
----------------------------------------------------------------------------------------
--Function added for Bug# 2879164
FUNCTION sub_valid_for_item(p_org_id             NUMBER:=NULL,
                            p_inventory_item_id  NUMBER:=NULL,
                            p_sub_code           VARCHAR2:=NULL)
RETURN VARCHAR2;
-----------------------------------------------------------------------------------------
-- Function added for On-hand Material Status support.
-- This function returns the defaul material status for an onhand record in the table MOQD.
-- Bug 12747846 : Added three new fields: p_txn_source_id, p_txn_source_type_id, p_txn_type_id
FUNCTION get_default_status( p_organization_id        IN NUMBER,
                             p_inventory_item_id      IN NUMBER,
			     p_sub_code               IN VARCHAR2,
			     p_loc_id                 IN NUMBER :=NULL,
			     p_lot_number             IN VARCHAR2 :=NULL,
			     p_lpn_id                 IN NUMBER := NULL,
                             p_transaction_action_id  IN NUMBER := NULL,
			     p_src_status_id          IN NUMBER := NULL,
                             p_lock_id                IN NUMBER := 0,
                             p_header_id              IN NUMBER :=NULL,
                             p_txn_source_id          IN NUMBER := NULL,
                             p_txn_source_type_id     IN NUMBER := NULL,
                             p_txn_type_id            IN NUMBER := NULL,
			     m_status_id              IN NUMBER := NULL)  --Material Status Enhancement - Tracking bug: 13519864
RETURN NUMBER;
-----------------------------------------------------------------------------------------

-- Function added for On-hand Material Status support.
-- This function returns the defaul material status for an onhand record in the table MOQD
-- for the concurrent program.

Function get_default_status_conc(p_organization_id        IN NUMBER,
                                 p_inventory_item_id      IN NUMBER,
			         p_sub_code               IN VARCHAR2,
			         p_loc_id                 IN NUMBER :=NULL,
			         p_lot_number             IN VARCHAR2 :=NULL,
			         p_lpn_id                 IN NUMBER := NULL)
RETURN NUMBER;
-----------------------------------------------------------------------------------------

-- Function added for On-hand Material Status support.
-- This function checks whether an item is locator controlled or not.
FUNCTION  get_locator_control
   (  p_org_id              NUMBER
    , p_inventory_item_id   NUMBER
    , p_sub_code            VARCHAR2
   ) RETURN NUMBER;


-----------------------------------------------------------------------------------------
-- Function added for On-hand Material Status support.
-- This function returns the transaction action id for a given transaction type id.
FUNCTION get_action_id( p_trx_type_id NUMBER)
RETURN NUMBER;

-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
--Bug #6633612, Adding following procedure for onhand status support project
PROCEDURE get_onhand_status_id
        ( p_organization_id       IN NUMBER
         ,p_inventory_item_id     IN NUMBER
         ,p_subinventory_code     IN VARCHAR2
         ,p_locator_id            IN NUMBER := NULL
         ,p_lot_number            IN VARCHAR2 := NULL
         ,p_lpn_id                IN NUMBER := NULL
         ,x_onhand_status_id      OUT NOCOPY NUMBER );
------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
--Bug #6633612, Adding following procedure for onhand status support project
-- This procedure validates the material status with respect to transfer transactions
PROCEDURE check_move_diff_status(
            p_org_id                IN NUMBER
          , p_inventory_item_id     IN NUMBER
          , p_subinventory_code     IN VARCHAR2
          , p_locator_id            IN NUMBER    DEFAULT NULL
          , p_transfer_org_id       IN NUMBER    DEFAULT NULL
          , p_transfer_subinventory IN VARCHAR2  DEFAULT NULL
          , p_transfer_locator_id   IN NUMBER    DEFAULT NULL
          , p_lot_number            IN VARCHAR2  DEFAULT NULL
          , p_transaction_action_id IN NUMBER
          , p_object_type           IN VARCHAR2
          , p_lpn_id                IN NUMBER    DEFAULT NULL
          , p_demand_src_header_id  IN NUMBER    DEFAULT NULL
          , p_revision              IN VARCHAR2  DEFAULT NULL
	  , p_primary_quantity      IN NUMBER    DEFAULT 0             --Added for bug 7833080
          , x_return_status         OUT NOCOPY VARCHAR2
          , x_msg_count             OUT NOCOPY NUMBER
          , x_msg_data              OUT NOCOPY VARCHAR2
          , x_post_action           OUT NOCOPY  VARCHAR2
);
--added the spec for the procedure for getting the lpn status as a part of lpn status project
------------------------------------------------------------------------------
-- Procedure
--   get_lpn_status
--
-- Description
--  To get the status of a LPN

-- Input Paramters
--
--    p_organization_id = organization id of the lpn
--    p_lpn_id   = lpn id of the lpn
--    p_sub_code = subinventory code of the lpn
--    p_loc_id   = locator id of lpn
--    p_lpn_context = Lpn context

--
-- Output Parameters
--  x_return_status_id = status id if LPN has unique status else -1
-- x_return_status_code = status code it lpn has unique status else translated message for 'Mixed'
------------------------------------------------------------------------------

PROCEDURE get_lpn_status
            (
            p_organization_id IN     NUMBER,
            p_lpn_id          IN     NUMBER,
            p_sub_code        IN     VARCHAR2 := NULL,
            p_loc_id          IN     NUMBER := NULL,
            p_lpn_context     IN     NUMBER,
            x_return_status_id OUT NOCOPY   NUMBER,
            x_return_status_code OUT NOCOPY VARCHAR2
            );

-----------------------------------------------------------------------------------------
/* -- LPN Status Project --*/
FUNCTION Status_Commingle_Check (
            p_item_id                     IN            NUMBER
          , p_lot_number                  IN            VARCHAR2 := NULL
          , p_org_id                      IN            NUMBER
          , p_trx_action_id               IN            NUMBER
          , p_subinv_code                 IN            VARCHAR2
          , p_tosubinv_code               IN            VARCHAR2 := NULL
          , p_locator_id                  IN            NUMBER := NULL
          , p_tolocator_id                IN            NUMBER := NULL
          , p_xfr_org_id                  IN            NUMBER := NULL
          , p_from_lpn_id                 IN            NUMBER := NULL
          , p_cnt_lpn_id                  IN            NUMBER := NULL
          , p_xfr_lpn_id                  IN            NUMBER := NULL )

RETURN VARCHAR2;
----------------------------------------------------------------------------------------
FUNCTION is_trx_allow_lpns(
p_wms_installed              IN VARCHAR2,
p_trx_status_enabled         IN NUMBER,
p_trx_type_id                IN NUMBER,
p_lot_status_enabled         IN VARCHAR2,
p_serial_status_enabled      IN VARCHAR2,
p_organization_id            IN NUMBER,
p_inventory_item_id          IN NUMBER,
p_sub_code                   IN VARCHAR2,
p_locator_id                 IN NUMBER,
p_lot_number                 IN VARCHAR2,
p_serial_number              IN VARCHAR2,
p_object_type                IN VARCHAR2,
p_fromlpn_id	             IN NUMBER,
p_xfer_lpn_id	             IN NUMBER,
p_xfer_sub_code		     IN VARCHAR2,
p_xfer_locator_id	     IN NUMBER,
p_xfer_org_id		     IN NUMBER)
RETURN NUMBER;
----------------------------------------------------------------------------------------
-- Function added for On-hand Material Status support, Bug 6798024
-- This will insert the newly created onhand record's status into the
-- history table:mtl_material_status_history
Procedure insert_status_history(p_organization_id        IN NUMBER,
                                p_inventory_item_id      IN NUMBER,
			        p_sub_code               IN VARCHAR2,
			        p_loc_id                 IN NUMBER :=NULL,
			        p_lot_number             IN VARCHAR2 :=NULL,
			        p_lpn_id                 IN NUMBER := NULL,
			        p_status_id              IN NUMBER := NULL,
                                p_lock_id                IN NUMBER := 0);
----------------------------------------------------------------------------------------
/* Bug 6918409: Added a wrapper to call the is_trx_allowed function */
FUNCTION  is_trx_allowed_wrap
  (
     p_status_id                 IN NUMBER
   , p_transaction_type_id       IN NUMBER
   ) return varchar2;
-----------------------------------------------------------------------------------------
--Function added for Bug#7626228
FUNCTION sub_loc_valid_for_item(p_org_id             NUMBER:=NULL,
                                   p_inventory_item_id  NUMBER:=NULL,
                                   p_sub_code           VARCHAR2:=NULL,
                                   p_loc_id             NUMBER:=NULL,
                                   p_restrict_sub_code  NUMBER:=NULL,
                                   p_restrict_loc_code  NUMBER:=NULL)
RETURN VARCHAR2;
END INV_MATERIAL_STATUS_GRP;

/
