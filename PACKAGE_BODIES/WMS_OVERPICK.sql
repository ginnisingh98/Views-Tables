--------------------------------------------------------
--  DDL for Package Body WMS_OVERPICK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_OVERPICK" AS
/* $Header: WMSOPICB.pls 120.1 2005/06/20 05:05:06 appldev ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'WMS_OVERPICK';


-- to turn off debugger, comment OUT NOCOPY /* file.sql.39 change */ the line 'dbms_output.put_line(msg);'
PROCEDURE mdebug(msg in varchar2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
--dbms_output.put_line('Jef: '||msg);
   null;
END;

-- This API queries the quantity_tree to find OUT NOCOPY /* file.sql.39 change */ whether there is
-- sufficient quantity to be picked in a locator .  If suffienct, the API
-- returns x_ret=1, otherwise x_ret=0.  The API also returns the avail to transact
-- qty in the same uom it was called (p_uom)


PROCEDURE validate_overpick
  ( x_return_status             OUT NOCOPY /* file.sql.39 change */ VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2, -- message text when x_msg_count>0
    x_ret                       OUT NOCOPY /* file.sql.39 change */ NUMBER,   -- returns 1 if p_qty > quantity from qty_tree
                                              -- otherwise returns 0
    x_att                       OUT NOCOPY /* file.sql.39 change */ NUMBER,   -- quantity that is avail to transact
    p_temp_id                   IN  NUMBER,   -- transaction_temp_id
    p_qty                       IN  NUMBER,   -- quantity requested
    p_uom                       IN  VARCHAR2 -- unit of measure
    )
  IS
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(250);

     -- local variables that store values from MMTT
     l_org_id NUMBER;
     l_sub VARCHAR2(10);
     l_loc_id NUMBER;
     l_item_id NUMBER;
     l_revision VARCHAR2(3);
     l_lot VARCHAR2(30);
     l_primary_uom VARCHAR2(3);

     -- local variables needed to call quantity tree and store values from MSI
     l_return_status varchar2(1);
     l_lot_control_code NUMBER;
     l_revision_qty_control_code NUMBER;
     l_serial_number_control_code NUMBER;
     l_is_lot_control BOOLEAN;
     l_is_revision_control BOOLEAN;
     l_is_serial_control BOOLEAN;
     l_qoh NUMBER;   -- qty onhand
     l_rqoh NUMBER; -- qty onhand that is reservable
     l_qr NUMBER; -- qty reserverd
     l_qs NUMBER; -- qty suggested
     l_att NUMBER; -- qty that is avail to transact
     l_atr NUMBER; -- qty that is avail to reserve (x_atr=x_rqoh - x_qr - x_qs)



    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Initialize x_ret to zero
   x_ret := 0;

   -- get input parameters for quantity tree
   SELECT organization_id, subinventory_code, locator_id, inventory_item_id, revision, lot_number
     INTO l_org_id, l_sub, l_loc_id, l_item_id, l_revision, l_lot
     FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = p_temp_id;

   SELECT lot_control_code, revision_qty_control_code, serial_number_control_code, primary_uom_code
     INTO l_lot_control_code, l_revision_qty_control_code, l_serial_number_control_code, l_primary_uom
     from mtl_system_items
     where inventory_item_id = l_item_id AND organization_id = l_org_id;

   -- check whether item is lot controlled from mtl_system_items
   IF ( (l_lot_control_code = NULL) OR (l_lot_control_code = 1))
     THEN l_is_lot_control := FALSE;
    ELSE l_is_lot_control := TRUE;
   END IF;

       -- check whether item is revision controlled from mtl_system_items
   IF ( (l_revision_qty_control_code = NULL) OR (l_revision_qty_control_code = 1))
     THEN l_is_revision_control := FALSE;
    ELSE l_is_revision_control := TRUE;
   END IF;

       -- check whether item is serial controlled from mtl_system_items
   IF ( (l_serial_number_control_code = NULL) OR (l_serial_number_control_code = 1))
     THEN l_is_serial_control := FALSE;
    ELSE l_is_serial_control := TRUE;
   END IF;


       inv_quantity_tree_pub.query_quantities
  (  p_api_version_number   	=>  1.0
   , x_return_status        	=>  l_return_status
   , x_msg_count            	=>  l_msg_count
   , x_msg_data             	=>  l_msg_data
   , p_organization_id          =>  l_org_id
   , p_inventory_item_id        =>  l_item_id
   , p_tree_mode                =>  2     -- for transaction mode
   , p_is_revision_control      =>  l_is_revision_control
   , p_is_lot_control           =>  l_is_lot_control
   , p_is_serial_control        =>  l_is_serial_control
   , p_revision             	=>  l_revision
   , p_lot_number           	=>  l_lot
   , p_subinventory_code    	=>  l_sub
   , p_locator_id           	=>  l_loc_id
   , x_qoh                  	=>  l_qoh   -- quantity onhand
   , x_rqoh                 	=>  l_rqoh  -- qty onhand that is reservable
   , x_qr                   	=>  l_qr   -- qty reserved
   , x_qs                   	=>  l_qs   -- qty suggested
   , x_att                  	=>  l_att   -- qty that is avail to transact
   , x_atr                  	=>  l_atr   -- qty that is avail to reserve
	                                   --  (x_atr=x_rqoh - x_qr - x_qs)

   );

       IF (l_debug = 1) THEN
          mdebug('In validate_pick, x_att: ' || l_att);
       END IF;
       -- convert l_att (quantity that is avail to transact) into the same UOM as
       -- the input quantity p_qty
       x_att :=
        	inv_convert.inv_um_convert( item_id 	  => l_item_id,
					    precision	  => null,
					    from_quantity => l_att,
					    from_unit	  => l_primary_uom,
					    to_unit	  => p_uom,
					    from_name	  => null,
					    to_name	  => null);

          IF (l_debug = 1) THEN
             mdebug('In validate_pick, x_converted_att: ' || x_att);
          END IF;
       -- if p_qty is greater than the avail to transact qty, return 1,
       -- otherwise return zero
	  IF (l_debug = 1) THEN
   	  mdebug('p_qty: ' || p_qty);
	  END IF;
       IF p_qty > x_att
	 THEN x_ret := 1;
	ELSE x_ret := 0;
       END IF;

END validate_overpick;
END wms_overpick ;

/
