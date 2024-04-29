--------------------------------------------------------
--  DDL for Package INV_TRANSFER_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TRANSFER_ORDER_PVT" AUTHID CURRENT_USER AS
  /* $Header: INVVTROS.pls 120.1.12010000.1 2008/07/24 01:53:04 appldev ship $ */

  --  Global for reference type

  g_ref_type_kanban       CONSTANT NUMBER           := 1;
  g_ref_type_minmax       CONSTANT NUMBER           := 2;
  g_ref_type_internal_req CONSTANT NUMBER           := 3;

  /*Patchset J feature constants added for Healthcare Project*/
  G_REF_TYPE_REPL_COUNT   CONSTANT NUMBER           := 10;
  G_REF_TYPE_REORD_POINT  CONSTANT NUMBER           := 11;

  -- Added for G-I Merge
  G_WMS_I_OR_ABOVE        BOOLEAN;

  --  Start of Comments
  --  API name    Process_Transfer_Order
  --  Type        Private
  --  Function
  --
  --  Pre-reqs
  --
  --  Parameters
  --
  --  Version     Current version = 1.0
  --              Initial version = 1.0
  --
  --  Notes
  --
  --  End of Comments

  PROCEDURE increment_max_line_number;

  PROCEDURE reset_max_line_number;

  FUNCTION get_next_header_id(p_organization_id NUMBER := NULL)
    RETURN NUMBER;

  FUNCTION unique_order(p_organization_id IN NUMBER, p_request_number IN VARCHAR2)
    RETURN BOOLEAN;

  FUNCTION unique_line(
    p_organization_id IN NUMBER
  , p_header_id IN NUMBER
  , p_line_number IN NUMBER)
    RETURN BOOLEAN;

  /*Procedure Get_Reservations(
      x_return_status             OUT VARCHAR2,
      x_msg_count                 OUT NUMBER,
      x_msg_data                  OUT VARCHAR2,
      p_source_header_id          IN NUMBER,
      p_source_line_id            IN NUMBER,
      p_source_delivery_id        IN NUMBER,
      p_organization_id           IN NUMBER,
      p_inventory_item_id         IN NUMBER,
      p_subinventory_code         IN VARCHAR2 := FND_API.G_MISS_CHAR,
      p_locator_id                IN NUMBER := FND_API.G_MISS_NUM,
      p_revision                  IN VARCHAR2 := FND_API.G_MISS_CHAR,
      p_lot_number                IN VARCHAR2 := FND_API.G_MISS_CHAR,
      p_serial_number             IN VARCHAR2 := FND_API.G_MISS_CHAR,
      x_mtl_reservation_tbl       OUT INV_RESERVATION_GLOBAL.MTL_RESERVATION_TBL_TYPE
  );
  */

  PROCEDURE process_transfer_order(
    p_api_version_number IN     NUMBER
  , p_init_msg_list      IN     VARCHAR2 := fnd_api.g_false
  , p_commit             IN     VARCHAR2 := fnd_api.g_false
  , p_validation_level   IN     NUMBER := fnd_api.g_valid_level_full
  , p_control_rec        IN     inv_globals.control_rec_type := inv_globals.g_miss_control_rec
  , x_return_status      OUT    NOCOPY VARCHAR2
  , x_msg_count          OUT    NOCOPY NUMBER
  , x_msg_data           OUT    NOCOPY VARCHAR2
  , p_trohdr_rec         IN     inv_move_order_pub.trohdr_rec_type := inv_move_order_pub.g_miss_trohdr_rec
  , p_trohdr_val_rec     IN     inv_move_order_pub.trohdr_val_rec_type := inv_move_order_pub.g_miss_trohdr_val_rec
  , p_old_trohdr_rec     IN     inv_move_order_pub.trohdr_rec_type := inv_move_order_pub.g_miss_trohdr_rec
  , p_trolin_tbl         IN     inv_move_order_pub.trolin_tbl_type := inv_move_order_pub.g_miss_trolin_tbl
  , p_trolin_val_tbl     IN     inv_move_order_pub.trolin_val_tbl_type := inv_move_order_pub.g_miss_trolin_val_tbl
  , p_old_trolin_tbl     IN     inv_move_order_pub.trolin_tbl_type := inv_move_order_pub.g_miss_trolin_tbl
  , x_trohdr_rec         IN OUT    NOCOPY inv_move_order_pub.trohdr_rec_type
  , x_trolin_tbl         IN OUT    NOCOPY inv_move_order_pub.trolin_tbl_type
  , p_delete_mmtt        IN     VARCHAR2 DEFAULT 'YES' --Added bug3524130
  );

  --  Start of Comments
  --  API name    Lock_Transfer_Order
  --  Type        Private
  --  Function
  --
  --  Pre-reqs
  --
  --  Parameters
  --
  --  Version     Current version = 1.0
  --              Initial version = 1.0
  --
  --  Notes
  --
  --  End of Comments

  PROCEDURE lock_transfer_order(
    p_api_version_number IN     NUMBER
  , p_init_msg_list      IN     VARCHAR2 := fnd_api.g_false
  , x_return_status      OUT    NOCOPY VARCHAR2
  , x_msg_count          OUT    NOCOPY NUMBER
  , x_msg_data           OUT    NOCOPY VARCHAR2
  , p_trohdr_rec         IN     inv_move_order_pub.trohdr_rec_type := inv_move_order_pub.g_miss_trohdr_rec
  , p_trolin_tbl         IN     inv_move_order_pub.trolin_tbl_type := inv_move_order_pub.g_miss_trolin_tbl
  , x_trohdr_rec         IN OUT    NOCOPY inv_move_order_pub.trohdr_rec_type
  , x_trolin_tbl         IN OUT    NOCOPY inv_move_order_pub.trolin_tbl_type
  );

  --  Start of Comments
  --  API name    Get_Transfer_Order
  --  Type        Private
  --  Function
  --
  --  Pre-reqs
  --
  --  Parameters
  --
  --  Version     Current version = 1.0
  --              Initial version = 1.0
  --
  --  Notes
  --
  --  End of Comments

  PROCEDURE get_transfer_order(
    p_api_version_number IN     NUMBER
  , p_init_msg_list      IN     VARCHAR2 := fnd_api.g_false
  , x_return_status      OUT    NOCOPY VARCHAR2
  , x_msg_count          OUT    NOCOPY NUMBER
  , x_msg_data           OUT    NOCOPY VARCHAR2
  , p_header_id          IN     NUMBER
  , x_trohdr_rec         OUT    NOCOPY inv_move_order_pub.trohdr_rec_type
  , x_trolin_tbl         OUT    NOCOPY inv_move_order_pub.trolin_tbl_type
  );

  FUNCTION validate_from_subinventory(
    p_from_subinventory_code       IN VARCHAR2
  , p_organization_id              IN NUMBER
  , p_inventory_item_id            IN NUMBER
  , p_transaction_type_id          IN NUMBER
  , p_restrict_subinventories_code IN NUMBER
  )
    RETURN BOOLEAN;

  g_from_sub inv_validate.sub; -- this is used to store the from sub object
                               -- so that it can be used for to sub validation

  FUNCTION validate_to_subinventory(
    p_to_subinventory_code         IN VARCHAR2
  , p_organization_id              IN NUMBER
  , p_inventory_item_id            IN NUMBER
  , p_transaction_type_id          IN NUMBER
  , p_restrict_subinventories_code IN NUMBER
  , p_asset_item                   IN VARCHAR2
  , p_from_sub_asset               IN NUMBER
  )
    RETURN BOOLEAN;

  --Update_Txn_Source_Line
  --
  -- This procedure updates the move order line indicated by p_line_id
  -- with a new transaction source line id (p_new_source_line_id).
  -- It also updates all of the allocation lines with the new source line id.
  -- This procedure is called from Shipping when the delivery detail is split
  -- after pick release has occurred, but before pick confirm.
  PROCEDURE update_txn_source_line(p_line_id IN NUMBER, p_new_source_line_id IN NUMBER);

  -- Name
  --    PROCEDURE Finalize_Pick_Confirm
  --
  -- Purpose
  --    This procedure is a call back procedure to be called from transaction
  --    processor after it successfully transact the move order line detail
  --    to do update move order line, update shipping and update reservation
  -- Input parameters
  --    p_transaction_temp_id - move order line detail id
  --    p_transaction_id      - transaction id for each move order line detail
  -- Output Parameters
  --    x_return_status - fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_success,
  --                      fnd_api.g_ret_unexp_error
  --    x_msg-count - number of error messages in the buffer
  --    x_msg_data  - error messages
  --
  PROCEDURE finalize_pick_confirm(
    p_init_msg_list       IN     VARCHAR2 := fnd_api.g_false
  , x_return_status       OUT    NOCOPY VARCHAR2
  , x_msg_count           OUT    NOCOPY NUMBER
  , x_msg_data            OUT    NOCOPY VARCHAR2
  , p_transaction_temp_id IN     NUMBER
  , p_transaction_id      IN     NUMBER
  ,p_xfr_transaction_id         IN NUMBER DEFAULT NULL

  );
 --Bug 2684668
  -- Bug 2640757: Fill Kill Enhancement
  PROCEDURE kill_move_order(
    x_return_status OUT NOCOPY VARCHAR2
  , x_msg_count OUT NOCOPY NUMBER
  , x_msg_data OUT NOCOPY VARCHAR2
  , p_transaction_header_id NUMBER);

  -- Bug 1620576
  -- This procedure is called from inltpu to delete the table
  -- mo_picked_quantity_tbl;
  -- This procedure is called everytime mmtt records are deleted in
  -- inltpu.
  PROCEDURE clear_picked_quantity;

  -- This procedure deletes any unstaged reservations for a sales order if
  -- there are only staged or shipped line delivery detail lines for that order
  PROCEDURE clean_reservations(
    p_source_line_id IN NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  , x_msg_count OUT NOCOPY NUMBER
  , x_msg_data OUT NOCOPY VARCHAR2);

  -- This procedure is called to update the mtl_transaction_lots_temp table
  -- before the mmtt record gets updated
  PROCEDURE update_lots_temp(
    x_return_status    OUT NOCOPY VARCHAR2
  , x_msg_data         OUT NOCOPY VARCHAR2
  , x_msg_count        OUT NOCOPY NUMBER
  , p_operation            VARCHAR2
  , p_item_id              NUMBER
  , p_org_id               NUMBER
  , p_trx_temp_id          NUMBER
  , p_cancel_qty           NUMBER
  , p_trx_uom              VARCHAR2
  , p_primary_uom          VARCHAR2
  , p_last_updated_by      NUMBER
  , p_last_update_date     DATE
  , p_creation_date        DATE
  , p_created_by           NUMBER
  );

  --Procedure called to update mtl_serial_numbers_temp table
  --when the sales order quantity changes.
  -- Bug 2195303
  PROCEDURE update_serial_temp(
    x_return_status OUT NOCOPY VARCHAR2
  , x_msg_data      OUT NOCOPY VARCHAR2
  , x_msg_count     OUT NOCOPY NUMBER
  , p_operation         VARCHAR2
  , p_trx_temp_id       NUMBER
  , p_cancel_qty        NUMBER
  );

 --As part of fix for bug 2867490, we need to create the following procedure
 --This procedure does the needful to adjust the serial numbers in MSNT
 --in case of overpicking. It could either update/delete MSNT range
 --or delete the single serial number from MSNT
 --INPUT parameters are
 --p_transaction_temp_id (if lot+serial then serial_txn_temp_id)
 --p_qty is the picked quantity corresponding to txn_temp_id

PROCEDURE adjust_serial_numbers_in_MSNT(
    p_transaction_temp_id IN NUMBER,
    p_qty IN NUMBER);

END inv_transfer_order_pvt;

/
