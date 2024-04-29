--------------------------------------------------------
--  DDL for Package INV_MO_CANCEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MO_CANCEL_PVT" AUTHID CURRENT_USER AS
  /* $Header: INVMOCNS.pls 120.0.12010000.2 2008/07/29 12:53:13 ptkumar ship $ */

  /**
    * Cancel Move Order Line is called by a Source when it is cancelled so
    * that the associated Move Order Line is also cancelled.
    * <p>
    * Cancelling a Move Order Line by the Source (9) is not same as Closing a
    * Move Order Line (5). Neither it is similar to the status Cancelled (6).
    * The user doesnt have access to a Closed Move Order Line. But a MO Line
    * Cancelled by Source can still be transacted. However, the transfer
    * doesnt go towards the Source. It is treated as a Subinventory Transfer.
    * <p>
    * Reservations if any are delinked from the Allocation. First, the Reservations
    * not yet detailed are deleted if the Source says so. Then the Detailed Qty of
    * the Reservations are decremented and Delete Reservations is passed as TRUE, then
    * the Reservation Qty is also decremented.  <br>
    * For a pure Inventory Organization, the Allocations are not deleted as there
    * is no way to determine whether the allocation is picked or not.
    * For a WMS Organization, because of the advent of Task Status, allocations can
    * be deleted for all statuses other than Active (9) and Loaded (4). <br>
    * If all the Allocations are deleted, then the Line is Closed (5). Otherwise the
    * Line Status is set to Cancelled by Source (9).
    * <p>
    * Shipping calls this procedure when a Delivery Line that is Released
    * to Warehouse is Cancelled. <br>
    * WIP calls this procedure when the Job/Schedule is Cancelled.
    * <p>
    * @param x_return_status         Return Status
    * @param x_msg_count             Message Count in the Stack
    * @param x_msg_data              Message if the Count is 1
    * @param p_line_id               Move Order Line ID
    * @param p_delete_reservations   Delete Reservations (Y/N)
    * @param p_txn_source_line_id    Transaction Source Line ID
    * @param p_delivery_detail_id    Delivery Detail ID
    */
  PROCEDURE cancel_move_order_line(
    x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_line_id             IN            NUMBER
  , p_delete_reservations IN            VARCHAR2
  , p_txn_source_line_id  IN            NUMBER DEFAULT NULL
  , p_delete_alloc        IN            VARCHAR2 DEFAULT NULL--ER3969328: CI project
  , p_delivery_detail_id  IN            NUMBER DEFAULT NULL -- planned crossdocking project
  );

  /**
    * Reduce Move Order Quantity is called from Shipping when the quantity on a
    * sales order line is reduced, leading to the quantity on a Delivery Detail
    * being reduced. It reduces the required_quantity column on the MO Line by
    * the passed reduction qty.
    * The Required Qty is the quantity needed by shipping to fulfill the sales order.
    * Any quantity transacted in excess of the Required Qty will be moved to staging,
    * but will not be reserved or shipped to the customer. Since the
    * sales order line quantity has been reduced, the Qty reserved for the SO
    * should also be reduced. Some reservations are reduced here, and some are reduced
    * in Finalize_Pick_Confirm (INVVTROB.pls).
    * If WMS is installed, undispatched tasks may be deleted, since these tasks are no
    * longer necessary.
    * <p>
    * @param x_return_status          Return Status
    * @param x_msg_count              Message Count in the Stack
    * @param x_msg_data               Message if the Count is 1
    * @param p_line_id                Move Order Line ID
    * @param p_reduction_quantity     Reduction Quantity
    * @param p_sec_reduction_quantity Secondary Reduction Quantity
    * @param p_txn_source_line_id     Transaction Source Line ID
    * @param p_delivery_detail_id    Delivery Detail ID
    */
  PROCEDURE reduce_move_order_quantity(
    x_return_status          OUT NOCOPY    VARCHAR2
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , p_line_id                IN            NUMBER
  , p_reduction_quantity     IN            NUMBER
  , p_sec_reduction_quantity IN            NUMBER DEFAULT NULL
  , p_txn_source_line_id     IN            NUMBER DEFAULT NULL
  , p_delivery_detail_id     IN            NUMBER DEFAULT NULL -- planned crossdocking project
  );
--Bug 7190635, Added a parameter to check whether the call is for ATO serial picking.
  PROCEDURE reduce_rsv_allocation(
    x_return_status           OUT NOCOPY    VARCHAR2
  , x_msg_count               OUT NOCOPY    NUMBER
  , x_msg_data                OUT NOCOPY    VARCHAR2
  , p_transaction_temp_id     IN            NUMBER
  , p_quantity_to_delete      IN            NUMBER
  , p_sec_quantity_to_delete  IN            NUMBER DEFAULT NULL
  , p_ato_serial_pick         IN            VARCHAR2 DEFAULT NULL
  );

  PROCEDURE update_mol_carton_group(
    x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_cnt            OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  , p_line_id            IN            NUMBER
  , p_carton_grouping_id IN            NUMBER
  );
END inv_mo_cancel_pvt;

/
