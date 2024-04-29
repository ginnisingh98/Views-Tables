--------------------------------------------------------
--  DDL for Package INV_REPLENISH_DETAIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_REPLENISH_DETAIL_PUB" AUTHID CURRENT_USER AS
  /* $Header: INVTOTXS.pls 120.2.12000000.1 2007/01/17 16:32:02 appldev ship $ */

  --  variables representing missing records and tables

  --G_MISS_DETAIL_REC        INV_AUTODETAIL.pp_row;
  --G_MISS_DETAIL_REC_TBL    INV_AUTODETAIL.pp_row_table;
  --G_MISS_SERIAL_REC        INV_AUTODETAIL.serial_row;
  --G_MISS_SERIAL_REC_TBL    INV_AUTODETAIL.serial_row_table;

  --  procedure

  PROCEDURE line_details_pub(
    p_line_id               IN            NUMBER := fnd_api.g_miss_num
  , x_number_of_rows        OUT NOCOPY    NUMBER
  , x_detailed_qty          OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_revision              OUT NOCOPY    VARCHAR2
  , x_locator_id            OUT NOCOPY    NUMBER
  , x_transfer_to_location  OUT NOCOPY    NUMBER
  , x_lot_number            OUT NOCOPY    VARCHAR2
  , x_expiration_date       OUT NOCOPY    DATE
  , x_transaction_temp_id   OUT NOCOPY    NUMBER
  , p_transaction_header_id IN            NUMBER
  , p_transaction_mode      IN            NUMBER
  , p_move_order_type       IN            NUMBER
  , p_serial_flag           IN            VARCHAR2
  , p_plan_tasks            IN            BOOLEAN DEFAULT FALSE
  , p_auto_pick_confirm     IN            BOOLEAN DEFAULT NULL
  , p_commit                IN            BOOLEAN DEFAULT FALSE
  );

-- HW INVCONV - overleoaded procedure
 PROCEDURE line_details_pub(
    p_line_id               IN            NUMBER := fnd_api.g_miss_num
  , x_number_of_rows        OUT NOCOPY    NUMBER
  , x_detailed_qty          OUT NOCOPY    NUMBER
  , x_detailed_qty2         OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_revision              OUT NOCOPY    VARCHAR2
  , x_locator_id            OUT NOCOPY    NUMBER
  , x_transfer_to_location  OUT NOCOPY    NUMBER
  , x_lot_number            OUT NOCOPY    VARCHAR2
  , x_expiration_date       OUT NOCOPY    DATE
  , x_transaction_temp_id   OUT NOCOPY    NUMBER
  , p_transaction_header_id IN            NUMBER
  , p_transaction_mode      IN            NUMBER
  , p_move_order_type       IN            NUMBER
  , p_serial_flag           IN            VARCHAR2
  , p_plan_tasks            IN            BOOLEAN DEFAULT FALSE
  , p_auto_pick_confirm     IN            BOOLEAN DEFAULT NULL
  , p_commit                IN            BOOLEAN DEFAULT FALSE
  );



  PROCEDURE assign_expenditure_org(p_transaction_temp_id NUMBER);

-- HW INVCONV Added Qty2
  PROCEDURE delete_details(
    p_transaction_temp_id   IN            NUMBER
  , p_move_order_line_id    IN            NUMBER
  , p_reservation_id        IN            NUMBER
  , p_transaction_quantity  IN            NUMBER
  , p_transaction_quantity2 IN            NUMBER default FND_API.G_MISS_NUM
  , p_primary_trx_qty       IN            NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , p_delete_temp_records   IN            BOOLEAN default TRUE /*Bug#5505709*/
  );

  PROCEDURE clear_block_cancel(p_trx_header_id IN NUMBER, p_success IN OUT NOCOPY BOOLEAN);

  PROCEDURE CLEAR_RECORD(p_trx_tmp_id IN NUMBER, p_success IN OUT NOCOPY BOOLEAN);

  PROCEDURE split_line_details(
    p_transaction_temp_id  IN            NUMBER
  , p_missing_quantity     IN            NUMBER
  , p_detailed_quantity    IN            NUMBER
  , p_transaction_quantity IN            NUMBER
  , x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  );

  PROCEDURE auto_pick_confirm(
    p_line_id         IN            NUMBER
  , p_move_order_type IN            NUMBER
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
  );

  PROCEDURE changed_from_subinventory(
    p_reservation_id      IN            NUMBER
  , p_transaction_temp_id IN            NUMBER
  , p_old_subinventory    IN            VARCHAR2
  , p_new_subinventory    IN            VARCHAR2
  , p_new_locator_id      IN            NUMBER
  , x_to_reservation_id   OUT NOCOPY    NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  );

  PROCEDURE reserve_unconfirm_qty(
    p_reservation_id   IN            NUMBER
  , p_missing_quantity IN            NUMBER
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  );

  --Check_Shipping_Tolerances
  --
  -- This API checks to make sure that transacting the current allocation
  -- does not exceed shipping tolerances.
  -- p_line_id : the move order line id.
  -- p_quantity: the quantity to be transacted
  -- x_allowed: 'Y' if txn is allowed, 'N' otherwise


  PROCEDURE check_shipping_tolerances(
    x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , x_allowed       OUT NOCOPY    VARCHAR2
  , x_max_quantity  OUT NOCOPY    NUMBER
  , p_line_id       IN            NUMBER
  , p_quantity      IN            NUMBER
  );

  -- OVPK
  -- Get_Overpick_Qty
  --
  -- This API will take 2 input parameters
  -- 1. p_transaction_temp_id
  -- 2. p_overpicked_qty
  -- This API will return
  -- 1. x_ovpk_allowed
  -- 2. x_max_qty_allowed
  -- x_ovpk_allowed will be 0 if overpicking is not allowed
  -- x_ovpk_allowed will be 1 if overpicking is allowed
  -- x_max_qty_allowed will return the max qty that can be picked for that task

  -- For Manufacturing Component Pick - Move Order type 5,
  --     Replenishment                - Move Order type 2,
  --     Requisition                  - Move Order type 1
  -- where there is no tolerance set on the quantity that can be picked,
  -- this procedure will return x_max_qty_allowed as -1

  PROCEDURE get_overpick_qty(
    p_transaction_temp_id IN            NUMBER
  , p_overpicked_qty      IN            NUMBER
  , x_ovpk_allowed        OUT NOCOPY    NUMBER
  , x_max_qty_allowed     OUT NOCOPY    NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  );

  -- OVPK
  -- Check_Overpick
  --
  -- This API will take 9 input parameters
  --   1. p_transaction_temp_id
  --   2. p_overpicked_qty
  --   3. p_item_id
  --   4. p_rev
  --   5. p_lot_num
  --   6. p_lot_exp_date
  --   7. p_sub
  --   8. p_locator_id
  --   9. p_lpn_id
  -- The procedure check_overpick will be called from the client java file
  -- This API check_overpick will in turn call Get_Overpick_Qty to find
  --    a) Is overpicking allowed for given Org, MO type and transaction_temp_id ?
  --    b) What is the max quantity that can be overpicked ?
  -- It will then log the appropriate error message if the user encounters such a state,
  -- such as 'Overpicking not allowed' or 'Insufficient stock' or 'Shipping Tolerance exceeded'
  -- Otherwise it will update QUANTITY_DETAILED in MTRL (if it is not a bulk picked task)
  -- and return control to the calling routine, with x_check_overpick_passed set to 'Y'
  -- thereby allowing him to overpick.
  -- This API will also return x_ovpk_error_code
  -- This OUT param will return 1 for error INV_OVERPICK_NOT_ALLOWED
  --                            2 for error INV_LACK_MTRL_TO_OVERPICK
  --                            3 for error INV_OVERSHIP_TOLERANCE

  PROCEDURE check_overpick(
    p_transaction_temp_id   IN            NUMBER
  , p_overpicked_qty        IN            NUMBER
  , p_item_id               IN            NUMBER
  , p_rev                   IN            VARCHAR2
  , p_lot_num               IN            VARCHAR2
  , p_lot_exp_date          IN            DATE
  , p_sub                   IN            VARCHAR2
  , p_locator_id            IN            NUMBER
  , p_lpn_id                IN            NUMBER
  , x_check_overpick_passed OUT NOCOPY    VARCHAR
  , x_ovpk_error_code       OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  );


  -- OVPK
  -- Check_Overpick(Overloaded procedure)
  --
  -- This API will take 10 input parameters
  --   1. p_transaction_temp_id
  --   2. p_overpicked_qty
  --   3. p_item_id
  --   4. p_rev
  --   5. p_lot_num
  --   6. p_lot_exp_date
  --   7. p_sub
  --   8. p_locator_id
  --   9. p_lpn_id
  --   10 p_att
  -- The procedure check_overpick will be called from the client java file
  -- This API check_overpick will in turn call Get_Overpick_Qty to find
  --    a) Is overpicking allowed for given Org, MO type and transaction_temp_id ?
  --    b) What is the max quantity that can be overpicked ?
  -- It will then log the appropriate error message if the user encounters such a state,
  -- such as 'Overpicking not allowed' or 'Insufficient stock' or 'Shipping Tolerance exceeded'
  -- Otherwise it will update QUANTITY_DETAILED in MTRL (if it is not a bulk picked task)
  -- and return control to the calling routine, with x_check_overpick_passed set to 'Y'
  -- thereby allowing him to overpick.
  -- This API will also return x_ovpk_error_code
  -- This OUT param will return 1 for error INV_OVERPICK_NOT_ALLOWED
  --                            2 for error INV_LACK_MTRL_TO_OVERPICK
  --                            3 for error INV_OVERSHIP_TOLERANCE

  PROCEDURE check_overpick(
    p_transaction_temp_id   IN            NUMBER
  , p_overpicked_qty        IN            NUMBER
  , p_item_id               IN            NUMBER
  , p_rev                   IN            VARCHAR2
  , p_lot_num               IN            VARCHAR2
  , p_lot_exp_date          IN            DATE
  , p_sub                   IN            VARCHAR2
  , p_locator_id            IN            NUMBER
  , p_lpn_id                IN            NUMBER
  , p_att                   IN            NUMBER
  , x_check_overpick_passed OUT NOCOPY    VARCHAR
  , x_ovpk_error_code       OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  );

-- OVPK - APL
-- This API is similar to get_overpick_qty
-- But this API will also do the MTLT level check for overpicking
-- which is not there in get_overpick_qty
-- The additional IN parameter needed here is p_lot_num
  PROCEDURE get_overpick_qty_lot(
    p_transaction_temp_id IN            NUMBER
  , p_overpicked_qty      IN            NUMBER
  , p_lot_num             IN            VARCHAR2
  , x_ovpk_allowed        OUT NOCOPY    NUMBER
  , x_max_qty_allowed     OUT NOCOPY    NUMBER
  , x_other_mtlt          OUT NOCOPY    NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  );

-- OVPK - APL
-- This API is simliar to check_overpick except that it calls
-- get_overpick_qty_lot instead of get_overpick_qty
-- This API must be called when doing the MTLT level
-- check for overpicking.
  PROCEDURE check_overpick_lot(
    p_transaction_temp_id   IN            NUMBER
  , p_overpicked_qty        IN            NUMBER
  , p_item_id               IN            NUMBER
  , p_rev                   IN            VARCHAR2
  , p_lot_num               IN            VARCHAR2
  , p_lot_exp_date          IN            DATE
  , p_sub                   IN            VARCHAR2
  , p_locator_id            IN            NUMBER
  , p_lpn_id                IN            NUMBER
  , x_check_overpick_passed OUT NOCOPY    VARCHAR
  , x_ovpk_error_code       OUT NOCOPY    NUMBER
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  );

END inv_replenish_detail_pub;

 

/
