--------------------------------------------------------
--  DDL for Package WMS_ITEM_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_ITEM_LOAD" AUTHID CURRENT_USER AS
/* $Header: WMSTKILS.pls 120.1 2006/01/31 08:40:08 gayu noship $ */

TYPE t_genref IS REF CURSOR;

--      Name: get_available_qty
--
--      Input parameters:
--       p_organization_id     Organization ID
--       p_lpn_id              LPN ID
--       p_inventory_item_id   Inventory Item ID
--       p_revision            Revision
--       p_prim_uom_code       Primary UOM code for the item
--       p_uom_code            UOM Code to return qty in
--
--      Output parameters:
--       x_return_status
--           if the pre_process_load API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages
--               in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--       x_available_qty
--           Returns the available quantity for the given item and revision
--           combination within the LPN.  The quantity returned will be in
--           the UOM of the inputted value.
--
PROCEDURE get_available_qty
  (p_organization_id      IN    NUMBER            ,
   p_lpn_id               IN    NUMBER            ,
   p_inventory_item_id    IN    NUMBER            ,
   p_revision             IN    VARCHAR2 := NULL  ,
   p_prim_uom_code        IN    VARCHAR2          ,
   p_uom_code             IN    VARCHAR2          ,
   x_return_status        OUT   NOCOPY VARCHAR2   ,
   x_msg_count            OUT   NOCOPY NUMBER     ,
   x_msg_data             OUT   NOCOPY VARCHAR2   ,
   x_available_qty        OUT   NOCOPY NUMBER     ,
   x_total_qty            OUT   NOCOPY NUMBER);--Added for bug 5000292

--      Name: get_available_lot_qty
--
--      Input parameters:
--       p_organization_id     Organization ID
--       p_lpn_id              LPN ID
--       p_inventory_item_id   Inventory Item ID
--       p_revision            Revision
--       p_lot_number          Lot Number
--       p_prim_uom_code       Primary UOM code for the item
--       p_uom_code            UOM Code to return qty in
--
--      Output parameters:
--       x_return_status
--           if the pre_process_load API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages
--               in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--       x_available_lot_qty
--           Returns the available quantity for the given item, revision
--           and lot combination within the LPN.  The quantity returned
--           will be in the UOM of the inputted value.
PROCEDURE get_available_lot_qty
  (p_organization_id      IN    NUMBER            ,
   p_lpn_id               IN    NUMBER            ,
   p_inventory_item_id    IN    NUMBER            ,
   p_revision             IN    VARCHAR2 := NULL  ,
   p_lot_number           IN    VARCHAR2          ,
   p_prim_uom_code        IN    VARCHAR2          ,
   p_uom_code             IN    VARCHAR2          ,
   x_return_status        OUT   NOCOPY VARCHAR2   ,
   x_msg_count            OUT   NOCOPY NUMBER     ,
   x_msg_data             OUT   NOCOPY VARCHAR2   ,
   x_available_lot_qty    OUT   NOCOPY NUMBER);


--      Name: pre_process_load
--
--      Input parameters:
--       p_organization_id     Organization ID
--       p_lpn_id              Source LPN ID
--       p_inventory_item_id   Inventory Item ID
--       p_revision            Revision (optional)
--       p_lot_number          Lot Number (optional)
--       p_quantity            Quantity
--       p_uom_code            UOM Code
--       p_user_id             User ID
--       p_into_lpn_id         Into LPN ID
--       p_serial_txn_temp_id  Serial Transaction Temp ID to link against
--                             MSNT records for serials that were loaded.
--                             The MSN records will have the group mark ID
--                             set to this value and the MSNT records will
--                             be inserted with a transaction temp ID
--                             equal to this value. (optional only for
--                             serial controlled items)
--
--      IN OUT parameters:
--       p_txn_header_id       Transaction header ID to use if a value
--                             is passed in.  -999 will be the default
--                             value if no header ID exists yet from the
--                             java mobile UI
--
--      Output parameters:
--       x_return_status
--           if the pre_process_load API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages
--               in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--
--      Functions: This API will insert appropriate dummy MMTT records for the
--                 item load details entered.  MTLT and MSNT records will
--                 also be inserted as needed.  This will store all of the
--                 item load details first and use the same transaction
--                 header ID to tie them all together (in the case of
--                 multiple lots and serials during one item load cycle).
--                 This is so we can have all the MMTT records needed and
--                 just call either the receiving TM or Inventory TM once
--                 to process them.  This procedure will match the item
--                 load details to the appropriate move order line(s) and
--                 insert MMTT records which tie back to the matched move
--                 order line(s).
PROCEDURE pre_process_load
  (p_organization_id      IN   NUMBER              ,
   p_lpn_id               IN   NUMBER              ,
   p_inventory_item_id    IN   NUMBER              ,
   p_revision             IN   VARCHAR2 := NULL    ,
   p_lot_number           IN   VARCHAR2 := NULL    ,
   p_quantity             IN   NUMBER              ,
   p_uom_code             IN   VARCHAR2            ,
   --laks
   p_sec_quantity         IN   NUMBER              ,
   p_sec_uom_code         IN   VARCHAR2            ,
   p_user_id              IN   NUMBER              ,
   p_into_lpn_id          IN   NUMBER              ,
   p_serial_txn_temp_id   IN   NUMBER := NULL      ,
   p_txn_header_id        IN OUT NOCOPY NUMBER     ,
   x_return_status        OUT  NOCOPY VARCHAR2     ,
   x_msg_count            OUT  NOCOPY NUMBER       ,
   x_msg_data             OUT  NOCOPY VARCHAR2);


--      Name: process_load
--
--      Input parameters:
--       p_txn_header_id       Transaction header ID
--       p_serial_txn_temp_id  Serial Transaction Temp ID for the serials
--                             which were marked during counting.  Passing
--                             this value here so that the temporary MSNT
--                             records inserted for marked serials can be
--                             deleted if the item load was for serials.
--       p_lpn_context         LPN Context so we know if we are working
--                             with RCV, INV, or WIP LPN's.
--       p_lpn_id              LPN ID
--       p_into_lpn_id         Into LPN ID
--       p_organization_id     Organization ID
--       p_user_id             User ID
--       p_eqp_ins             Equipment Instance
--
--      Output parameters:
--       x_return_status
--           if the process_load API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages
--               in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--
--      Functions: This API will process all of the MMTT records with
--                 the given transaction header ID inserted by the prior
--                 call to the pre_process_load procedure.  For a receiving
--                 item load, we will call wms_rcv_pup_pvt.pack_unpack_split
--                 which will deal with splitting the move order lines,
--                 inserting the appropriate RTI, MTLI, and MSNI records
--                 needed to call the receiving manager.  This procedure
--                 will be called in a mode that will not invoke the
--                 Receiving TM.  Suggestions_PUB will be called for each
--                 move order line created and returned from this
--                 procedure.  Finally, the receiving manager will be
--                 called which has an implicit COMMIT prior to the call.
PROCEDURE process_load
  (p_txn_header_id        IN   NUMBER              ,
   p_serial_txn_temp_id   IN   NUMBER := NULL      ,
   p_lpn_context          IN   NUMBER              ,
   p_lpn_id		  IN   NUMBER              ,
   p_into_lpn_id          IN   NUMBER              ,
   p_organization_id      IN   NUMBER              ,
   p_user_id              IN   NUMBER              ,
   p_eqp_ins              IN   VARCHAR2            ,
   x_return_status        OUT  NOCOPY VARCHAR2     ,
   x_msg_count            OUT  NOCOPY NUMBER       ,
   x_msg_data             OUT  NOCOPY VARCHAR2);


--      Name: unmark_serials
--
--      Input parameters:
--       p_serial_txn_temp_id  Serial Transaction Temp ID for the serials
--                             which were marked during counting.
--       p_organization_id     Organization ID
--       p_inventory_item_id   Inventory Item ID
--
--      Output parameters:
--       x_return_status
--           if the process_load API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages
--               in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--
--      Functions: Unmark the serials that were marked during item load.
--                 This is called in case the RCV TM was called and it
--                 errored out.  Since a commit is done, we cannot do a
--                 rollback.  The serials that were marked during loading
--                 must be unmarked and the temporary MSNT records inserted
--                 will be deleted.
PROCEDURE unmark_serials
  (p_serial_txn_temp_id   IN   NUMBER              ,
   p_organization_id      IN   NUMBER              ,
   p_inventory_item_id    IN   NUMBER              ,
   x_return_status        OUT  NOCOPY VARCHAR2     ,
   x_msg_count            OUT  NOCOPY NUMBER       ,
   x_msg_data             OUT  NOCOPY VARCHAR2);


--      Name: cleanup_ATF
--
--      Input parameters:
--       p_txn_header_id       Transaction header ID for dummy MMTT's that
--                             were inserted in the call to pre_process_load
--       p_lpn_context         LPN Context so we know if we are working
--                             with RCV, INV, or WIP LPN's.
--       p_lpn_id              LPN ID from which we performed the item load
--       p_organization_id     Organization ID
--       p_rcv_tm_called       Boolean indicating if the RCV TM was called already
--
--      Output parameters:
--       x_return_status
--           if the process_load API succeeds, the value is
--		    fnd_api.g_ret_sts_success;
--           if there is an expected error, the value is
--		    fnd_api.g_ret_sts_error;
--           if there is an unexpected error, the value is
--		    fnd_api.g_ret_sts_unexp_error;
--       x_msg_count
--           if there are one or more errors, the number of error messages
--               in the buffer
--       x_msg_data
--           if there is one and only one error, the error message
--       (See fnd_api package for more details about the above output parameters)
--
--      Functions: For receiving, this will call the ATF runtime API
--                 Cleanup_Operation_Instance for each MMTT task record
--                 that was activated.  This is in order to  rollback the WDT records
--                 that were inserted and to revert the ATF operations done
--                 when the operation was activated previously in the call
--                 to process_load.  For inventory and WIP, this will call
--                 the ATF runtime API delete_dispatched_task which will
--                 autonomously delete the WDT record that was inserted.
--                 The rest of the ATF operation stuff is cleaned up
--                 through a rollback.
PROCEDURE cleanup_ATF
  (p_txn_header_id        IN   NUMBER              ,
   p_lpn_context          IN   NUMBER              ,
   p_lpn_id		  IN   NUMBER              ,
   p_organization_id      IN   NUMBER              ,
   p_rcv_tm_called        IN   BOOLEAN             ,
   x_return_status        OUT  NOCOPY VARCHAR2     ,
   x_msg_count            OUT  NOCOPY NUMBER       ,
   x_msg_data             OUT  NOCOPY VARCHAR2);


END WMS_ITEM_LOAD;

 

/
