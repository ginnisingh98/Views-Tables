--------------------------------------------------------
--  DDL for Package Body INV_QTY_MANAGEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_QTY_MANAGEMENT" AS
/* $Header: INVQTYMB.pls 120.1 2005/06/11 12:33:17 appldev  $ */

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
			       p_txn_action_id       IN     NUMBER)
  AS
     l_rate NUMBER;    -- gets the rate of conversion from txn_uom to primary
     l_txn_qty NUMBER; -- stores the txn_qty in the primary UOM
BEGIN

   if nvl(p_prev_txn_qty,-1) = -1 THEN
   p_total_lot_qty := 0;
   p_total_serial_qty := 0;
   end if;

	x_done := 'F';


   IF p_primary_uom_code IS NULL THEN
      BEGIN
	 SELECT primary_uom_code
	   INTO p_primary_uom_code
	   FROM mtl_system_items
	  WHERE organization_id = p_organization_id
	    AND inventory_item_id = p_inventory_item_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    x_error_code := 'E';
	    x_error_message := 'Could not find primary UOM';
	    RETURN;
      END;
   END IF;

   IF p_txn_uom_code IS NULL THEN
      BEGIN
	 SELECT uom_code
	   INTO p_txn_uom_code
	   FROM mtl_item_uoms_view
	   WHERE organization_id = p_organization_id
	   AND inventory_item_id = p_inventory_item_id
	   AND unit_of_measure = p_txn_unit_of_measure;

      EXCEPTION
	 WHEN OTHERS THEN
	    x_error_code := 'E';
	    x_error_message := 'Could not find txn UOM Code';
	    RETURN;
      END;
   END IF;

   inv_convert.inv_um_conversion(p_txn_uom_code,
				 p_primary_uom_code,
				 p_inventory_item_id,
				 l_rate);

   l_txn_qty := p_txn_qty * l_rate;

  --If transaction is an issue or a transfer, and the item is serial controlled
  --then the quantity needs not even look at the lot qty and the behavior will
  --be that of a receiving transaction that is serial controlled.

  IF ((p_txn_action_id = 1 or p_txn_action_id = 2 or p_txn_action_id =3) AND
     (p_serial_control_code<>1 AND p_serial_control_code <>6)) THEN

	p_total_lot_qty := 0;
	IF l_txn_qty < p_total_serial_qty THEN
	   p_txn_qty := p_prev_txn_qty;
	   x_error_code := 'E';
	   x_error_message := 'Txn qty cannot be less the total serial qty = ' || p_total_serial_qty;
	   RETURN;
	 ELSE
	   p_prev_txn_qty := p_txn_qty;
	   IF p_txn_qty = p_total_serial_qty THEN
	      x_done := 'T';
	   END IF;
	   x_error_code := 'C';
	   x_error_message := ' ';
	   RETURN;
	END IF;


   -- if item not lot controlled and not serial controlled just update the
   -- the p_prev_txn_qty to the p_txn_qty and keep p_total_serial_qty
   -- and p_total_lot_qty both as zero.

   ELSIF p_lot_control_code = 1
     AND (p_serial_control_code = 1 or
	  p_serial_control_code = 6) THEN
      p_prev_txn_qty := p_txn_qty;
      p_total_lot_qty := 0;
      p_total_serial_qty := 0;
      x_error_code := 'C';
      x_error_message := ' ';
      x_done := 'T';
      RETURN;
      -- if the item is lot controlled but not serial controlled then
      -- make the p_total_serial_qty equal to zero, if the p_txn_qty
      -- is less than the p_total_lot_qty then error OUT NOCOPY /* file.sql.39 change */ and set the
      -- p_txn_qty equal to the p_prev_txn_qty and leave other values
      -- same. Otherwise everything is fine, update the p_prev_txn_qty
      -- to the new p_txn_qty, p_total_serial_qty to zero.
    ELSIF p_lot_control_code = 2
      AND (p_serial_control_code = 1 or
	   p_serial_control_code = 6) THEN
       p_total_serial_qty := 0;
       IF l_txn_qty < p_total_lot_qty THEN
	  p_txn_qty := p_prev_txn_qty;
	  x_error_code := 'E';
	  x_error_message := 'Txn qty cannot be less than the total lot qty = '||p_total_lot_qty;
	  RETURN;
	ELSE
	  p_prev_txn_qty := p_txn_qty;
	  IF p_txn_qty = p_total_lot_qty THEN
	     x_done := 'T';
	  END IF;
	  x_error_code := 'C';
	  x_error_message := ' ';
	  RETURN;
       END IF;
       -- if the item is not lot controlled but serial controlled
       -- make the p_total_lot_qty to zero, if the p_txn_qty is less
       -- than the the p_total_serial_qty then error OUT NOCOPY /* file.sql.39 change */ and set the
       -- p_txn_qty to the previous value and leave other values same
       -- Otherwise everything is fine and update the p_prev_txn_qty
       -- to the new p_txn_qty.
     ELSIF p_lot_control_code = 1
       AND (p_serial_control_code <> 1 and
	    p_serial_control_code <> 6) THEN
	p_total_lot_qty := 0;
	IF l_txn_qty < p_total_serial_qty THEN
	   p_txn_qty := p_prev_txn_qty;
	   x_error_code := 'E';
	   x_error_message := 'Txn qty cannot be less the total serial qty = ' || p_total_serial_qty;
	   RETURN;
	 ELSE
	   p_prev_txn_qty := p_txn_qty;
	   IF p_txn_qty = p_total_serial_qty THEN
	      x_done := 'T';
	   END IF;
	   x_error_code := 'C';
	   x_error_message := ' ';
	   RETURN;
	END IF;
      ELSE
	-- item is both lot and serial controlled
	-- he can only change this if he has entered serial numbers for the
	-- current lot which match the lot quantity and thus
	-- p_total_lot_qty would be equal to p_total_serial_qty.
	-- We cannot reset the p_total_serial_qty to zero in this case
	-- it should be reset to zero when the new lot number is entered.
	IF l_txn_qty < p_total_lot_qty THEN
	   p_txn_qty := p_prev_txn_qty;
	   x_error_code := 'E';
	   x_error_message := 'Txn qty cannot be less than the total lot qty = '||p_total_lot_qty;
	   RETURN;
	 ELSE
	   p_prev_txn_qty := p_txn_qty;
	   IF p_txn_qty = p_total_lot_qty THEN
	      x_done := 'T';
	   END IF;
	   x_error_code := 'C';
	   x_error_message := ' ';
	   RETURN;
	END IF;
     END IF;

END;


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
			       x_error_message          OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

  AS
     l_rate NUMBER;    -- gets the rate of conversion from txn_uom to primary
     l_txn_qty NUMBER; -- stores the txn_qty in the primary UOM
     l_allowed_lot_qty NUMBER;


BEGIN

   x_lot_done := 'F';
   x_done := 'F';

   x_error_message := ':txn qty:'||p_txn_qty||
     ':txn uom:'||p_txn_uom_code||
     ':primary uom:'||p_primary_uom_code||
     ':item id:'||p_inventory_item_id||
     ':lot code:'||p_lot_control_code||
     ':serial code:'||p_serial_control_code||
     ':current lot:'||p_current_lot_qty||
     ':prev lot:'||p_prev_lot_qty||
     ':total lot:'||p_total_lot_qty||
     ':total srl:'||p_total_serial_qty||
     ':x done:'||x_done;


   inv_convert.inv_um_conversion(p_txn_uom_code,
				 p_primary_uom_code,
				 p_inventory_item_id,
				 l_rate);

   l_txn_qty := p_txn_qty * l_rate;

   IF p_lot_control_code = 1 THEN
      x_error_code := 'E';
      x_error_message := 'You should not have come here';
      RETURN;
   END IF;

   -- calculates the maximum value the value can be changed to.
   l_allowed_lot_qty := (p_txn_qty - (p_total_lot_qty/l_rate));

   -- if item is not serial controlled then allow to change the lot
   -- quantity to a value equal to p_txn_qty - p_total_lot_qty and zero
   -- on the lower end.
   IF (p_serial_control_code = 1 or
       p_serial_control_code = 6) THEN
      IF p_current_lot_qty <= 0 OR
	p_current_lot_qty > l_allowed_lot_qty THEN
	 p_current_lot_qty := p_prev_lot_qty;
	 x_error_code := 'E';
	 x_error_message := 'Lot quantity should be between 1 and '||l_allowed_lot_qty;
	 RETURN;
       ELSE
	 p_prev_lot_qty := p_current_lot_qty;
	 p_total_lot_qty := p_total_lot_qty + (p_current_lot_qty * l_rate);
	 IF p_total_lot_qty = p_txn_qty THEN
	    x_done := 'T';
	 END IF;
	 x_lot_done := 'T';
	 x_error_code := 'C';
	 x_error_message := x_error_message||':finish:'||
	   ':current lot:'||p_current_lot_qty||
	   ':prev lot:'||p_prev_lot_qty||
	   ':total lot:'||p_total_lot_qty||
	   ':total srl:'||p_total_serial_qty||
	   ':x done:'||x_done;

	 RETURN;
      END IF;
    ELSE
      -- item is also serial controlled.
      -- fine if the current lot quantity is more than the serial numbers
      -- already entered for the lot and it is less than the transaction
      -- quantity minus the lot quantity entered.
      -- the total lot quantity is modified with as the serial numbers are
      -- entered for a lot and serial controlled item.
      IF p_current_lot_qty < (p_total_serial_qty/l_rate) OR
	p_current_lot_qty > l_allowed_lot_qty THEN
	 p_current_lot_qty := p_prev_lot_qty;
	 x_error_code := 'E';
	 x_error_message := 'Lot quantity should be between '||(p_total_serial_qty/l_rate)||' and '||l_allowed_lot_qty;
	 RETURN;
       ELSE
	 p_prev_lot_qty := p_current_lot_qty;
	 IF p_current_lot_qty = (p_total_serial_qty/l_rate) THEN
	    x_lot_done := 'T';
	 END IF;
	 x_error_code := 'C';
	 x_error_message := ' ';
	 RETURN;
      END IF;
   END IF;
END;



PROCEDURE when_lot_num_entered(p_total_serial_qty IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			       p_serial_number_control_code IN NUMBER)
IS
BEGIN
	IF p_serial_number_control_code <> 1 AND p_serial_number_control_code <> 6 THEN
	p_total_serial_qty := 0;
	END IF;
END when_lot_num_entered;

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
			       p_txn_action_id       IN     NUMBER)

  AS
     l_rate NUMBER;    -- gets the rate of conversion from txn_uom to primary
     l_txn_qty NUMBER; -- stores the txn_qty in the primary UOM
     l_num_serials NUMBER; -- stores the number of serials entered
     l_from_serial_num NUMBER;
     l_to_serial_num NUMBER;
     l_prefix VARCHAR2(30);

BEGIN

   x_done := 'F';
   x_lot_done := 'F';

   inv_convert.inv_um_conversion(p_txn_uom_code,
				 p_primary_uom_code,
				 p_inventory_item_id,
				 l_rate);

   l_txn_qty := p_txn_qty * l_rate;

   IF (p_serial_control_code = 1 or
       p_serial_control_code = 6) THEN
      x_error_code := 'E';
      x_error_message := 'You should not have come here';
      RETURN;
   END IF;

   IF p_to_serial IS NULL THEN
      l_num_serials := 1;
    ELSE
      inv_validate.number_from_sequence(p_from_serial,
					l_prefix,
					l_from_serial_num);
      inv_validate.number_from_sequence(p_to_serial,
					l_prefix,
					l_to_serial_num);
      l_num_serials := l_to_serial_num - l_from_serial_num + 1;
   END IF;

   IF p_from_serial IS NULL THEN
      x_error_code := 'E';
      x_error_message := 'From serial cannot be NULL';
      RETURN;
   END IF;

   --If transaction is an issue or a transfer, and the item is serial controlled
   --then the quantity needs not even look at the lot qty and the behavior will be
   --that of a receiving transaction that is serial controlled.
      IF (p_txn_action_id = 1 or p_txn_action_id = 2 or p_txn_action_id =3) AND
	  (p_serial_control_code<>1 AND p_serial_control_code <>6) THEN
	IF (p_total_serial_qty + l_num_serials) > (p_txn_qty * l_rate) THEN
	 x_error_code := 'E';
	 x_error_message := 'Max serials you can specify are '||((p_txn_qty*l_rate)-p_total_serial_qty);
	 RETURN;
       ELSE
	 p_total_serial_qty := p_total_serial_qty + l_num_serials;
	 IF p_total_serial_qty = p_txn_qty THEN
	    x_done := 'T';
	 END IF;
	 x_error_code := 'C';
	 x_error_message := ' ';
	 RETURN;
      END IF;

   -- if item is not lot controlled then just update the p_total_serial_qty
   -- by the number of serial numbers entered.
   ELSIF p_lot_control_code = 1 THEN
      IF (p_total_serial_qty + l_num_serials) > (p_txn_qty * l_rate) THEN
	 x_error_code := 'E';
	 x_error_message := 'Max serials you can specify are '||((p_txn_qty*l_rate)-p_total_serial_qty);
	 RETURN;
       ELSE
	 p_total_serial_qty := p_total_serial_qty + l_num_serials;
	 IF p_total_serial_qty = p_txn_qty THEN
	    x_done := 'T';
	 END IF;
	 x_error_code := 'C';
	 x_error_message := ' ';
	 RETURN;
      END IF;

      -- item is lot and serial controlled
      -- number of serials that can be entered are  < p_current_lot_qty
      -- minus the p_total_serial_qty
      ELSIF (p_total_serial_qty + l_num_serials) > (p_current_lot_qty *
						 l_rate)
	THEN
	 x_error_code := 'E';
	 x_error_message := 'Max serials you can specify are '||((p_current_lot_qty*l_rate)-p_total_serial_qty);
	 RETURN;
       ELSE
	 p_total_serial_qty := p_total_serial_qty + l_num_serials;
	 p_total_lot_qty := p_total_lot_qty + l_num_serials;
	 IF p_total_lot_qty = p_txn_qty THEN
	    x_done := 'T';
	    x_lot_done := 'T';
	 END IF;
	 IF p_total_lot_qty = p_total_serial_qty THEN
	    x_lot_done := 'T';
	 END IF;
	 x_error_code := 'C';
	 x_error_message := ' ';
      END IF;

END;

END inv_qty_management;

/
