--------------------------------------------------------
--  DDL for Package INV_QTY_MANAGEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_QTY_MANAGEMENT" AUTHID CURRENT_USER AS
/* $Header: INVQTYMS.pls 120.1 2005/06/11 12:39:05 appldev  $ */


-- Logical Flow
-- ------------
-- The first time the user enters the txn qty/UOM the current serial and
-- lot quantity and the previous transaction quantity are all null.
-- If the item is not under lot or serial control, it will allow the user
-- to change the txn qty/UOM to anything and set the p_prev_txn_qty equal
-- to p_txn_qty and set the p_total_lot_qty, p_total_serial_qty
-- to zero.
-- If the item is lot controlled, it will not allow the user to enter the
-- transaction quantity which is more than the current lot quantity.
-- If the item is not lot controlled but is serial controlled then the
-- transaction qty cannot be less than the current number of serial numbers
-- entered. For all comparisons, p_txn_qty would be converted to
-- the base UOM using the p_txn_uom.
-- if p_txn_qty = p_total_lot_qty then done flag = 'T'
--
   -- p_txn_qty is the current transaction quantity entered. It is both
   -- because if the quantity is not allowed to change, we should restore
   -- it back to the previous transaction quantity value stored in
   -- p_prev_txn_uom.
   --
   -- p_txn_uom_code is the UOM CODE for the txn qty and it would
   -- also be the UOM in which the p_prev_txn_qty is specified.
   --
   -- p_txn_unit_of_measure is the UNIT OF MEASURE in which the
   -- txn qty is specified. It can be null if the p_txn_uom_code is
   -- not null.
   --
   -- p_primary_uom_code is the primary uom for the item. It can be null
   -- in which case the uom is found from the item and org info provided
   --
   -- p_total_lot_qty stores the total number of lot quantity already
   -- entered in the primary UOM.
   --
   -- p_total_serial_qty stores the total number of serial numbers
   -- specified for the lot number if item is also lot controlled
   -- otherwise for just serial controlled items, it just stores the
   -- number of serial numbers specified for the txn qty.
   --
   -- x_error_code returns E for error and C for success
   -- x_error_message returns the message
PROCEDURE when_txn_qty_entered(p_txn_qty             IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			       p_txn_uom_code        IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			       p_txn_unit_of_measure IN     VARCHAR2,
			       p_prev_txn_qty        IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			       p_serial_control_code IN     NUMBER,
			       p_lot_control_code    IN     NUMBER,
			       p_primary_uom_code    IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			       p_organization_id     IN     NUMBER,
			       p_inventory_item_id   IN     NUMBER,
			       p_total_lot_qty       IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			       p_total_serial_qty    IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			       x_done                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			       x_error_code             OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			       x_error_message          OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			       p_txn_action_id       IN     NUMBER);



-- Logical Flow
-- ------------
-- if the item is not serial controlled, then lot quantity can be allowed
-- to change to a value upto the current transaction quantity minus the
-- current total lot quantity on the higher side and upto zero  on the
-- lower side. Otherwise it will show an error.
-- If the item is also serial controlled then the lower limit would change
-- to the total serial qty already entered for the item and lot and the
-- higher limit remains the same.
-- For a non serialized item if the change is successful,
-- then the total_lot_qty is incremented by the p_current_lot_qty and
-- the prev_lot_qty is updated to the new lot quantity.
-- If the item is serial and lot control then the total_lot_qty deos not
-- change as it would be incremented when the serial numbers are entered.
-- For any errors, the current lot quantity is changed to the previous
-- lot quantity.
--
--
  -- p_txn_qty current transaction quantity on the UI
  --
  -- p_txn_uom_code current transaction UOM
  --
  -- p_current_lot_qty current lot quantity on the UI. If it is not correct
  -- it is updated to the older value otherwise it retains the new value.
  --
  -- p_prev_lot_qty previous lot quantity entered stored in the txn UOM
  --
  -- p_total_lot_qty stores the number of lots entered into the system
  -- it is updated as serial numbers are entered for a lot/serial controlled
  -- item and updated here with the new lot quantity if the item is just
  -- lot controlled. It is in base UOM
  --
  -- p_total_serial_qty is the quantity in the base UOM of the number of
  -- serial numbers entered on the UI for the current lot. It MUST be reset
  -- to zero when a new lot is created for proper operation.
PROCEDURE when_lot_qty_entered(p_txn_qty             IN     NUMBER,
			       p_txn_uom_code        IN     VARCHAR2,
			       p_primary_uom_code    IN     VARCHAR2,
			       p_inventory_item_id   IN     NUMBER,
			       p_lot_control_code    IN     NUMBER,
			       p_serial_control_code IN     NUMBER,
			       p_current_lot_qty     IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			       p_prev_lot_qty        IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			       p_total_lot_qty       IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			       p_total_serial_qty    IN     NUMBER,
			       x_done                IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			       x_lot_done               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			       x_error_code             OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			       x_error_message          OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


PROCEDURE when_lot_num_entered(p_total_serial_qty IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			       p_serial_number_control_code IN NUMBER);


-- Logical Flow
-- ------------
-- If the item is not lot controlled then total_serial_qty is incremented
-- by the number of serial numbers entered based on the range or individual
-- serials entered. p_total_lot_qty is not changed at all.
-- If the item is also lot controlled then the p_total_lot_qty is
-- incremented by the number of serial numbers entered and so is
-- p_total_serial_qty.
PROCEDURE when_srl_num_entered(p_txn_qty             IN     NUMBER,
			       p_txn_uom_code        IN     VARCHAR2,
			       p_primary_uom_code    IN     VARCHAR2,
			       p_inventory_item_id   IN     NUMBER,
			       p_current_lot_qty     IN     NUMBER,
			       p_lot_control_code    IN     NUMBER,
			       p_serial_control_code IN     NUMBER,
			       p_from_serial         IN     VARCHAR2,
			       p_to_serial           IN     VARCHAR2,
			       p_total_lot_qty       IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			       p_total_serial_qty    IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			       x_done                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			       x_lot_done               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			       x_error_code             OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			       x_error_message          OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			       p_txn_action_id       IN     NUMBER);



END inv_qty_management;

 

/
