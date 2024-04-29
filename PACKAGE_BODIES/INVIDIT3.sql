--------------------------------------------------------
--  DDL for Package Body INVIDIT3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVIDIT3" AS
/* $Header: INVIDI3B.pls 120.9.12010000.16 2011/11/25 07:33:25 jewen ship $ */

-- This procedure performs several queries to determine
--  if attributes are updateable.  This only needs to be called
--  when working on an existing record.

PROCEDURE Table_Queries(
   p_org_id                   IN            NUMBER,
   p_item_id                  IN            NUMBER,
   p_master_org               IN            NUMBER,
   p_primary_uom_code         IN            VARCHAR2,
   p_catalog_group_id         IN            NUMBER,
   p_calling_routine          IN            VARCHAR2,
   x_onhand_lot               IN OUT NOCOPY NUMBER,
   x_onhand_serial            IN OUT NOCOPY NUMBER,
   x_onhand_shelf             IN OUT NOCOPY NUMBER,
   x_onhand_rev               IN OUT NOCOPY NUMBER,
   x_onhand_loc               IN OUT NOCOPY NUMBER,
   x_onhand_all               IN OUT NOCOPY NUMBER,
   x_onhand_trackable         IN OUT NOCOPY NUMBER,
   x_wip_repetitive_item      IN OUT NOCOPY NUMBER,
   x_rsv_exists               IN OUT NOCOPY NUMBER,
   x_so_rsv                   IN OUT NOCOPY NUMBER,
   x_so_ship                  IN OUT NOCOPY NUMBER,
   x_so_txn                   IN OUT NOCOPY NUMBER,
   x_demand_exists            IN OUT NOCOPY NUMBER,
   x_uom_conv                 IN OUT NOCOPY NUMBER,
   x_comp_atp                 IN OUT NOCOPY NUMBER,
   x_bom_exists               IN OUT NOCOPY NUMBER,
   x_cost_txn                 IN OUT NOCOPY NUMBER,
   x_bom_item                 IN OUT NOCOPY NUMBER,
   x_mrp_schedule             IN OUT NOCOPY NUMBER,
   x_null_elem_exists         IN OUT NOCOPY NUMBER,
   x_so_open_exists           IN OUT NOCOPY NUMBER,
   x_fte_vechicle_exists      IN OUT NOCOPY NUMBER,
   x_pendadj_lot              IN OUT NOCOPY NUMBER,
   x_pendadj_rev              IN OUT NOCOPY NUMBER,
   x_pendadj_loc              IN OUT NOCOPY NUMBER,
   x_so_ato                   IN OUT NOCOPY NUMBER,
   x_vmiorconsign_enabled     IN OUT NOCOPY NUMBER,
   x_consign_enabled          IN OUT NOCOPY NUMBER,
   x_process_enabled          IN OUT NOCOPY NUMBER,
   x_onhand_tracking_qty_ind  IN OUT NOCOPY NUMBER,
   x_pendadj_tracking_qty_ind IN OUT NOCOPY NUMBER,
   x_onhand_primary_uom       IN OUT NOCOPY NUMBER,
   x_pendadj_primary_uom      IN OUT NOCOPY NUMBER,
   x_onhand_secondary_uom     IN OUT NOCOPY NUMBER,
   x_pendadj_secondary_uom    IN OUT NOCOPY NUMBER,
   x_onhand_sec_default_ind   IN OUT NOCOPY NUMBER,
   x_pendadj_sec_default_ind  IN OUT NOCOPY NUMBER,
   x_onhand_deviation_high    IN OUT NOCOPY NUMBER,
   x_pendadj_deviation_high   IN OUT NOCOPY NUMBER,
   x_onhand_deviation_low     IN OUT NOCOPY NUMBER,
   x_pendadj_deviation_low    IN OUT NOCOPY NUMBER,
   x_onhand_child_lot         IN OUT NOCOPY NUMBER,
   x_pendadj_child_lot        IN OUT NOCOPY NUMBER,
   x_onhand_lot_divisible     IN OUT NOCOPY NUMBER,
   x_pendadj_lot_divisible    IN OUT NOCOPY NUMBER,
   x_onhand_grade             IN OUT NOCOPY NUMBER,
   x_pendadj_grade            IN OUT NOCOPY NUMBER,
   x_intr_ship_lot            IN OUT NOCOPY NUMBER,
   x_intr_ship_serial         IN OUT NOCOPY NUMBER,
   X_revision_control            OUT NOCOPY number,   -- Bug 6501149
   X_stockable                   OUT NOCOPY number,   -- Bug 6501149
   X_lot_control                 OUT NOCOPY number,   -- Bug 6501149
   X_serial_control              OUT NOCOPY number,   -- Bug 6501149
   X_open_shipment_lot        IN OUT NOCOPY number,   -- Bug 9043779
   X_open_shipment_serial     IN OUT NOCOPY number    -- Bug 9043779
   ) IS

  -- Local variables

  lot_onhand			NUMBER := 0;
  lot_txn_pending		NUMBER := 0;
  ser_onhand			NUMBER := 0;
  ser_txn_pending		NUMBER := 0;
  shelf_onhand			NUMBER := 0;
  shelf_txn_pending		NUMBER := 0;
  rev_onhand			NUMBER := 0;
  rev_txn_pending		NUMBER := 0;
  loc_onhand			NUMBER := 0;
  loc_txn_pending		NUMBER := 0;
  uom_conv			NUMBER := 0;
  uom_other_conv		NUMBER := 0;
  cost_moq			NUMBER := 0;
  cost_moq2			NUMBER := 0;
  cost_tmp			NUMBER := 0;
  cost_mmt			NUMBER := 0;
  bom_row_exists		NUMBER := 0;
  bom_substitute		NUMBER := 0;
  bom_inventory			NUMBER := 0;
  onhand_org_count		NUMBER := 0;
  onhand_master_count		NUMBER := 0;
  material_org_count		NUMBER := 0;
  material_org_count_ls         number := 0; --bug 7155924
  material_master_count		NUMBER := 0;
  material_master_count_ls      number := 0; --bug 7155924
  lot_level			NUMBER := 0;
  rev_level			NUMBER := 0;
  loc_level			NUMBER := 0;
  shelf_level			NUMBER := 0;
  serial_level			NUMBER := 0;
  trackable_level		NUMBER := 0;
  attr_name			VARCHAR2(50);
  l_tab_exists			NUMBER  := 0;
  onhand_tracking_qty_ind  	NUMBER  := 0;
  pendadj_tracking_qty_ind 	NUMBER  := 0;
  tracking_qty_ind_level   	NUMBER  := 0;
  onhand_primary_uom  		NUMBER  := 0;
  pendadj_primary_uom 		NUMBER  := 0;
  primary_uom_level   		NUMBER  := 0;
  onhand_secondary_uom  	NUMBER  := 0;
  pendadj_secondary_uom 	NUMBER  := 0;
  secondary_uom_level   	NUMBER  := 0;
  onhand_sec_default_ind  	NUMBER  := 0;
  pendadj_sec_default_ind 	NUMBER  := 0;
  sec_default_ind_level   	NUMBER  := 0;
  onhand_deviation_high 	NUMBER  := 0;
  pendadj_deviation_high 	NUMBER  := 0;
  onhand_deviation_low 		NUMBER  := 0;
  pendadj_deviation_low 	NUMBER  := 0;
  deviation_high_level    	NUMBER  := 0;
  deviation_low_level    	NUMBER  := 0;
  onhand_child_lot       	NUMBER  := 0;
  pendadj_child_lot      	NUMBER  := 0;
  child_lot_level        	NUMBER  := 0;
  onhand_lot_divisible       	NUMBER  := 0;
  pendadj_lot_divisible      	NUMBER  := 0;
  lot_divisible_level        	NUMBER  := 0;
  onhand_grade       		NUMBER  := 0;
  pendadj_grade      		NUMBER  := 0;
  grade_level        		NUMBER  := 0;
  lots_org_count                NUMBER  := 0;
  lots_master_count             NUMBER  := 0;
  l_intr_ship_org		NUMBER  := 0;
  l_intr_ship_master		NUMBER  := 0;
  l_attr_control_level		NUMBER; -- Bug: 4139938
  reservable_level              NUMBER  := 0;
  ship_item_level               NUMBER  := 0;
  transaction_level             NUMBER  := 0;
  bom_enabled_level             NUMBER  := 0;
  inv_asset_level               NUMBER  := 0;
  cost_enabled_level            NUMBER  := 0;
    /*  Bug 6501149 */
  stockable_level               NUMBER := 0;
  l_org                         NUMBER := 0;
  l_master                      NUMBER := 0;

  /* bug 9043779 */
  open_shipment_org_count		NUMBER := 0;
  open_shipment_master_count		NUMBER := 0;
  /* end bug 9043779 */
	-- bug 8406930
 	opm_enabled_org varchar2(1);
BEGIN

   -- 6531911 : Removed the intialization of out variables.
   -- Values for these will be passed from calling routines
   -- If not NULL, we will query the downstream tables.
   -- Intialise the variable only when called from Item form.
   -- Changes are too huge to make in certification phase.
   IF p_calling_routine = 'INVIDITM' THEN
      x_onhand_lot               := 0;
      x_onhand_serial            := 0;
      x_onhand_shelf             := 0;
      x_onhand_rev               := 0;
      x_onhand_loc               := 0;
      x_onhand_all               := 0;
      x_onhand_trackable         := 0;
      x_wip_repetitive_item      := 0;
      x_rsv_exists               := 0;
      x_so_rsv                   := 0;
      x_so_ship                  := 0;
      x_so_txn                   := 0;
      x_demand_exists            := 0;
      x_uom_conv                 := 0;
      x_comp_atp                 := 0;
      x_bom_exists               := 0;
      x_cost_txn                 := 0;
      x_bom_item                 := 0;
      x_mrp_schedule             := 0;
      x_null_elem_exists         := 0;
      x_so_open_exists           := 0;
      x_fte_vechicle_exists      := 0;
      x_pendadj_lot              := 0;
      x_pendadj_rev              := 0;
      x_pendadj_loc              := 0;
      x_so_ato                   := 0;
      x_vmiorconsign_enabled     := 0;
      x_consign_enabled          := 0;
      x_process_enabled          := 0;
      x_onhand_tracking_qty_ind  := 0;
      x_pendadj_tracking_qty_ind := 0;
      x_onhand_primary_uom       := 0;
      x_pendadj_primary_uom      := 0;
      x_onhand_secondary_uom     := 0;
      x_pendadj_secondary_uom    := 0;
      x_onhand_sec_default_ind   := 0;
      x_pendadj_sec_default_ind  := 0;
      x_onhand_deviation_high    := 0;
      x_pendadj_deviation_high   := 0;
      x_onhand_deviation_low     := 0;
      x_pendadj_deviation_low    := 0;
      x_onhand_child_lot         := 0;
      x_pendadj_child_lot        := 0;
      x_onhand_lot_divisible     := 0;
      x_pendadj_lot_divisible    := 0;
      x_onhand_grade             := 0;
      x_pendadj_grade            := 0;
      x_intr_ship_lot            := 0;
      x_intr_ship_serial         := 0;
       /* Bug 6501149 */
      X_revision_control := 0;
      X_stockable        := 0;
      X_lot_control      := 0;
      X_serial_control   := 0;
      X_open_shipment_lot    := 0; -- bug 9043779
      X_open_shipment_serial := 0; -- bug 9043779
   END IF;

   --6531911 : Removed multiple select stmts into one cursor stmt
   FOR cur IN (SELECT control_level, attribute_name
               FROM   mtl_item_attributes
    	       WHERE  attribute_name IN ('MTL_SYSTEM_ITEMS.LOT_CONTROL_CODE'
                                        ,'MTL_SYSTEM_ITEMS.SHELF_LIFE_CODE'
		   		        ,'MTL_SYSTEM_ITEMS.SERIAL_NUMBER_CONTROL_CODE'
				        ,'MTL_SYSTEM_ITEMS.REVISION_QTY_CONTROL_CODE'
				        ,'MTL_SYSTEM_ITEMS.LOCATION_CONTROL_CODE'
				        ,'MTL_SYSTEM_ITEMS.COMMS_NL_TRACKABLE_FLAG'
				        ,'MTL_SYSTEM_ITEMS.TRACKING_QUANTITY_IND'
				        ,'MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE'
				        ,'MTL_SYSTEM_ITEMS.SECONDARY_UOM_CODE'
				        ,'MTL_SYSTEM_ITEMS.SECONDARY_DEFAULT_IND'
				        ,'MTL_SYSTEM_ITEMS.DUAL_UOM_DEVIATION_HIGH'
				        ,'MTL_SYSTEM_ITEMS.DUAL_UOM_DEVIATION_LOW'
				        ,'MTL_SYSTEM_ITEMS.CHILD_LOT_FLAG'
				        ,'MTL_SYSTEM_ITEMS.LOT_DIVISIBLE_FLAG'
				        ,'MTL_SYSTEM_ITEMS.GRADE_CONTROL_FLAG'
					,'MTL_SYSTEM_ITEMS.RESERVABLE_TYPE'
					,'MTL_SYSTEM_ITEMS.SHIPPABLE_ITEM_FLAG'
					,'MTL_SYSTEM_ITEMS.SO_TRANSACTIONS_FLAG'
					,'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG'
                                        ,'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG'))  -- bug 6501149
   LOOP
      IF cur.attribute_name =  'MTL_SYSTEM_ITEMS.LOT_CONTROL_CODE' THEN
         lot_level          := cur.control_level;
      ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.SHELF_LIFE_CODE' THEN
         shelf_level        := cur.control_level;
      ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.SERIAL_NUMBER_CONTROL_CODE' THEN
         serial_level       := cur.control_level;
      ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.REVISION_QTY_CONTROL_CODE' THEN
         rev_level          := cur.control_level;
      ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.LOCATION_CONTROL_CODE' THEN
         loc_level          := cur.control_level;
      ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.COMMS_NL_TRACKABLE_FLAG' THEN
         trackable_level    := cur.control_level;
      ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.TRACKING_QUANTITY_IND' THEN
         tracking_qty_ind_level    := cur.control_level;
      ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE' THEN
         primary_uom_level  := cur.control_level;
      ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.SECONDARY_UOM_CODE' THEN
         secondary_uom_level:= cur.control_level;
      ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.SECONDARY_DEFAULT_IND' THEN
         sec_default_ind_level    := cur.control_level;
      ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.DUAL_UOM_DEVIATION_HIGH' THEN
         deviation_high_level    := cur.control_level;
      ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.DUAL_UOM_DEVIATION_LOW' THEN
         deviation_low_level:= cur.control_level;
      ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.CHILD_LOT_FLAG' THEN
         child_lot_level    := cur.control_level;
      ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.LOT_DIVISIBLE_FLAG' THEN
         lot_divisible_level:= cur.control_level;
     ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.GRADE_CONTROL_FLAG' THEN
         grade_level       := cur.control_level;
     ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.RESERVABLE_TYPE' THEN
         reservable_level  := cur.control_level;
     ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.SHIPPABLE_ITEM_FLAG' THEN
         ship_item_level  := cur.control_level;
     ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.SO_TRANSACTIONS_FLAG' THEN
         transaction_level  := cur.control_level;
     ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG' THEN
         bom_enabled_level  := cur.control_level;
     ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.INVENTORY_ASSET_FLAG' THEN
         inv_asset_level  := cur.control_level;
     ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.COSTING_ENABLED_FLAG' THEN
         cost_enabled_level  := cur.control_level;
     ELSIF cur.attribute_name =  'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG' THEN  -- bug 6501149
         stockable_level  := cur.control_level;
     END IF;
   END LOOP;

   IF  x_onhand_lot              IS NOT NULL
    OR x_onhand_shelf            IS NOT NULL
    OR x_onhand_serial           IS NOT NULL
    OR x_onhand_rev              IS NOT NULL
    OR x_onhand_loc              IS NOT NULL
    OR x_onhand_trackable        IS NOT NULL
    OR x_onhand_tracking_qty_ind IS NOT NULL
    OR x_onhand_primary_uom      IS NOT NULL
    OR x_onhand_secondary_uom    IS NOT NULL
    OR x_onhand_sec_default_ind  IS NOT NULL
    OR x_onhand_deviation_high   IS NOT NULL
    OR x_onhand_deviation_low    IS NOT NULL
    OR x_onhand_child_lot 	 IS NOT NULL
    OR x_onhand_lot_divisible	 IS NOT NULL
    OR x_onhand_grade		 IS NOT NULL
   THEN

      SELECT COUNT(1) INTO   onhand_org_count
      FROM   mtl_onhand_quantities_detail -- Bug:2687570
      WHERE  inventory_item_id = p_item_id
      AND    organization_id   = p_org_id
      AND    ROWNUM            = 1;

      IF (onhand_org_count <> 1) THEN
         SELECT COUNT(1) INTO onhand_master_count
         FROM   mtl_onhand_quantities_detail -- Bug:2687570
         WHERE inventory_item_id = p_item_id
	 AND   (organization_id IN  (SELECT organization_id
                                     FROM   mtl_parameters
                                     WHERE  master_organization_id = p_master_org))
         AND ROWNUM = 1;

         SELECT count(1) INTO material_org_count
         FROM   mtl_material_transactions_temp
         WHERE  inventory_item_id = p_item_id
         AND    organization_id   = p_org_id
         AND    rownum = 1;

         --bug 7355994(7356679,7356680): setting lot-serial flag to be 1 in case
         --rows exist in mtl_material_transactions_temp
        IF (material_org_count = 1) THEN
          material_org_count_ls := 1;
        END IF;

         IF (material_org_count <> 1) THEN
            SELECT count(1)  INTO material_org_count
            FROM  mtl_supply
            WHERE item_id = p_item_id
            AND  (from_organization_id = p_org_id OR to_organization_id = p_org_id)
            AND  rownum = 1;

            --bug 7155924(7327865,7327866): for lot and serial control attributes
            --we need to check for records in MTL_Supply with supply_type_code
            --in Receiving and Shipment only
            SELECT count(1)  INTO material_org_count_ls
            FROM  mtl_supply
            WHERE item_id = p_item_id
            AND  (from_organization_id = p_org_id
                 OR to_organization_id = p_org_id)
            and supply_type_code in ('RECEIVING', 'SHIPMENT')
            AND  rownum = 1;
         END IF;

         IF (material_org_count <> 1) THEN
            SELECT COUNT(1) INTO material_org_count
            FROM  mtl_demand
            WHERE inventory_item_id = p_item_id
            AND   organization_id   = p_org_id
            AND   rownum            = 1;

            --bug 7155924(7327865,7327866): setting lot-serial flag to be 1 in case
            --rows exist in mtl_demand
            IF(material_org_count = 1) THEN
              material_org_count_ls := 1;
            END IF;
         END IF;

         IF (material_org_count <> 1) THEN
            SELECT COUNT(1) INTO material_master_count
            FROM mtl_material_transactions_temp
            WHERE inventory_item_id = p_item_id
            AND (organization_id IN (SELECT organization_id
                                     FROM mtl_parameters
                                     WHERE master_organization_id = p_master_org))
            AND rownum = 1;

            --bug 7355994(7356679,7356680): setting lot-serial flag to be 1 in
            --case rows exist in mtl_material_transactions_temp
            IF(material_master_count = 1) THEN
               material_master_count_ls := 1;
            END IF;


            --3713912 :check for pending transactions such as approved PO
            IF (material_master_count <> 1) THEN
               SELECT COUNT(1) INTO material_master_count
               FROM   mtl_supply ms
               WHERE ms.item_id = p_item_id
               AND   EXISTS (SELECT 1
                             FROM   mtl_parameters
                             WHERE  master_organization_id = p_master_org
                             AND    (organization_id = ms.from_organization_id OR organization_id = ms.to_organization_id))
               AND rownum = 1;

               --bug 7155924(7327865,7327866): for lot and serial control attributes
               --we need to check for records in MTL_Supply with supply_type_code
               --in Receiving and Shipment only
               SELECT COUNT(1)
               INTO material_master_count_ls
               FROM   mtl_supply ms
               WHERE ms.item_id = p_item_id
               AND   EXISTS (SELECT 1
                             FROM   mtl_parameters
                             WHERE  master_organization_id = p_master_org
                             AND    (organization_id = ms.from_organization_id
                                    OR organization_id = ms .to_organization_id))
               AND supply_type_code in ('RECEIVING', 'SHIPMENT')
               AND rownum = 1;
            END IF;

            --Check for pending transactions such as a booked order
            IF (material_master_count <> 1) THEN
              SELECT COUNT(1)  INTO material_master_count
              FROM  mtl_demand md
              WHERE md.inventory_item_id = p_item_id
              AND   EXISTS (SELECT 1
                            FROM   mtl_parameters
                            WHERE  master_organization_id = p_master_org
                            AND    organization_id = md.organization_id)
              AND rownum = 1;

              --bug 7155924(7327865,7327866): setting lot-serial flag
              --to be 1 in case rows exist in mtl_demand
              IF (material_master_count = 1) THEN
                material_master_count_ls := 1;
              END IF;

            END IF;
         END IF;
      END IF;

      IF ( onhand_org_count = 1 or material_org_count = 1) THEN
         --7155924,7355994
         IF (onhand_org_count = 1 or material_org_count_ls = 1) THEN
           X_onhand_lot := 1;
           X_onhand_serial := 1;
           X_onhand_shelf := 1; /* Bug 8521729. Shelf Life is also handled as same as Lot control. */
         END IF;

         --x_onhand_shelf            := 1;
         x_onhand_rev              := 1;
         x_onhand_loc              := 1;
         x_onhand_trackable        := 1;
         x_onhand_tracking_qty_ind := 1;
         x_onhand_primary_uom      := 1;
         x_onhand_secondary_uom    := 1;
         x_onhand_sec_default_ind  := 1;
         x_onhand_deviation_high   := 1;
         x_onhand_deviation_low    := 1;
         x_onhand_child_lot        := 1;
         x_onhand_lot_divisible	   := 1;
         x_onhand_grade		   := 1;
         X_stockable			   := 1; /*Bug 9094398*/

      ELSIF ( onhand_master_count = 1 or material_master_count = 1) THEN
         --bug_7155924_7355994
         if (lot_level = 1
            and (onhand_master_count = 1 or material_master_count_ls = 1))
         then
           x_onhand_lot := 1;
         end if;

         /* Bug 8521729 Shelf life is also handled similar to lot control */
         if (shelf_level = 1 and (onhand_master_count = 1 or material_master_count_ls = 1)) then
            x_onhand_shelf := 1;
         end if;

         --bug_7155924_7355994
         if (serial_level = 1
            and (onhand_master_count = 1 or material_master_count_ls = 1))
         then
           x_onhand_serial := 1;
         end if;

         if (rev_level = 1) then
            x_onhand_rev := 1;
         end if;
         if (loc_level = 1) then
            x_onhand_loc := 1;
         end if;
         if ( trackable_level = 1 ) then
            x_onhand_trackable := 1;
         end if;
         if (tracking_qty_ind_level    = 1) then
            x_onhand_tracking_qty_ind := 1;
         end if;
         if (primary_uom_level    = 1) then
            x_onhand_primary_uom := 1;
         end if;
         if (secondary_uom_level  = 1) then
            x_onhand_secondary_uom:= 1;
         end if;
         if (sec_default_ind_level        = 1) then
            x_onhand_sec_default_ind := 1;
         end if;
         if (deviation_high_level         = 1) then
            x_onhand_deviation_high := 1;
         end if;
         if (deviation_low_level  = 1) then
           x_onhand_deviation_low := 1;
         end if;
         if (child_lot_level  = 1) then
            x_onhand_child_lot := 1;
         end if;
         if (lot_divisible_level  = 1) then
            x_onhand_lot_divisible := 1;
         end if;
         if (grade_level  = 1) then
            x_onhand_grade := 1;
         end if;
         /*Added for Bug 9094398*/
		 if (stockable_level = 1) then
		    X_stockable    := 1;
		 end if;
		 /*End of comment*/

      end if;
         --Start Bug 3713912 we have to check if lots have been defined.
         --If lots are defined the all lot dependent fields are non updateable.

       /* start bug 8406930 */
 	     select process_enabled_flag
 	     into   opm_enabled_org
 	     from   mtl_parameters
 	     where  organization_id = p_org_id;

 	     if opm_enabled_org ='Y' then -- to check the OPM_ENABLED_ORGS

         select count(1)
         into   lots_org_count
         from   mtl_lot_numbers
         where  inventory_item_id = p_item_id and
                organization_id   = p_org_id and
                rownum = 1;

         if (lots_org_count <> 1) then
            select count(1)
            into   lots_master_count
            from   mtl_lot_numbers mln
            where  inventory_item_id = p_item_id
            and    exists (select 1
                           from   mtl_parameters
                           where  master_organization_id = p_master_org
                           and    organization_id = mln.organization_id)
            and rownum = 1;

         end if;

         if ( lots_org_count = 1 ) then
            x_onhand_lot 			:= 1;
            x_onhand_child_lot 		:= 1;
            x_onhand_lot_divisible	:= 1;
            x_onhand_grade		:= 1;
            x_onhand_shelf 		:= 1;
         elsif ( lots_master_count = 1) then
   	    if (lot_level = 1) then
      	      x_onhand_lot := 1;
            end if;
            if (child_lot_level  = 1) then
               x_onhand_child_lot := 1;
            end if;
            if (lot_divisible_level  = 1) then
              x_onhand_lot_divisible := 1;
            end if;
            if (grade_level  = 1) then
              x_onhand_grade := 1;
            end if;
            if (shelf_level = 1) then
               x_onhand_shelf := 1;
            end if;
         end if;
      END IF;
    --end if; -- bug 8406930  (If opm_enabled_org ='Y')
   END IF;

   IF x_intr_ship_lot IS NOT NULL
   OR x_intr_ship_serial IS NOT NULL THEN
      -- Start bug 4387538
      if (lot_level = 2 or serial_level = 2) then
	  select count(1)
	  into l_intr_ship_org
	  from mtl_supply
	  where supply_type_code = 'SHIPMENT'
	  and item_id = p_item_id
	  and to_organization_id = p_org_id
	  and from_organization_id is not null
	  and po_line_location_id is null
	  and rownum = 1;
      end if;

      if (lot_level = 1 or serial_level = 1) then
	 select count(1)
	 into l_intr_ship_master
	 from mtl_supply
	 where supply_type_code = 'SHIPMENT'
	 and item_id = p_item_id
	 and to_organization_id in
	          (select organization_id
	           from mtl_parameters
	           where master_organization_id = p_master_org)
	 and from_organization_id is not null
	 and po_line_location_id is null
	 and rownum = 1;

      end if;
      if (l_intr_ship_org = 1 ) then
         x_intr_ship_lot    := 1;
         x_intr_ship_serial := 1;
      elsif (l_intr_ship_master = 1) then
        if (lot_level = 1) then
          x_intr_ship_lot := 1;
        end if;
        if (serial_level = 1) then
          x_intr_ship_serial := 1;
        end if;
      end if;
      -- End bug 4387538
   END IF;

 /*Bug 6501149 Code changes Start
    Updating the Values of the attributes to 1 if there are Open Deliver transactions.
    The below query returns rows if Open Deliver transactions present */
  if (rev_level = 2 or stockable_level = 2 or lot_level = 2 or serial_level = 2) then

    select count(1)
    into l_org
    from mtl_supply
    where supply_type_code in ('RECEIVING', 'SHIPMENT')
    and item_id = p_item_id
    and to_organization_id  =p_org_id
    and rownum =1 ;

  end if;

  if (rev_level = 1 or stockable_level = 1 or lot_level = 1 or serial_level = 1 ) then

   select count(1)
   into l_master
    from mtl_supply
    where supply_type_code in ('RECEIVING', 'SHIPMENT')
    and item_id = p_item_id
    and to_organization_id in
              (select organization_id
               from mtl_parameters
               where master_organization_id = p_master_org)
    and rownum = 1;

  end if;

  if (l_org = 1 ) then

    X_revision_control    := 1;
    X_stockable           := 1;
    X_lot_control         := 1;
    X_serial_control      := 1;
  elsif (l_master = 1) then

    if (rev_level = 1) then
       X_revision_control := 1;
    end if;
    if (stockable_level = 1) then
       X_stockable        := 1;
    end if;
    if(lot_level = 1) then
       X_lot_control      := 1;
    end if;
    if (serial_level = 1) then
       X_serial_control   := 1;
    end if;
  end if;
/*Bug 6501149 Code changes ends */

   --Following code added for Bug 3058650
   if (x_onhand_rev <> 1) then
       if (inv_attribute_control_pvt.check_pending_adjustments
                       (p_org_id      => p_org_id,
                        p_item_id     => p_item_id,
                        p_source_item => 'REVISION_QTY_CONTROL_CODE')) then
           x_pendadj_rev := 1;
       end if ;
   end if ;
   if (x_onhand_lot <> 1) then
       if (inv_attribute_control_pvt.check_pending_adjustments
                       (p_org_id      => p_org_id,
                        p_item_id     => p_item_id,
                        p_source_item => 'LOT_CONTROL_CODE')) then
          x_pendadj_lot := 1;
       end if;
   end if;
   if (x_onhand_loc <> 1) then
       if (inv_attribute_control_pvt.check_pending_adjustments
                       (p_org_id      => p_org_id,
                        p_item_id     => p_item_id,
                        p_source_item => 'LOCATION_CONTROL_CODE')) then
          x_pendadj_loc := 1;
       end if;
   end if;
   if (INV_ATTRIBUTE_CONTROL_PVT.ato_uncheck(p_org_id => p_org_id,
                        p_item_id => p_item_id)) then
      x_so_ato := 1;
   end if;

   -- Start Bug 3713912
   if (x_onhand_tracking_qty_ind <> 1) then
       if (inv_attribute_control_pvt.check_pending_adjustments
                       (p_org_id      => p_org_id,
                        p_item_id     => p_item_id,
                        p_source_item => 'TRACKING_QTY_IND')) then
          x_pendadj_tracking_qty_ind := 1;
       end if;
   end if;
   if (x_onhand_primary_uom <> 1) then
       if (inv_attribute_control_pvt.check_pending_adjustments
                       (p_org_id      => p_org_id,
                        p_item_id     => p_item_id,
                        p_source_item => 'PRIMARY_UOM_CODE')) then
          x_pendadj_primary_uom := 1;
       end if;
   end if;
   if (x_onhand_secondary_uom <> 1) then
       if (inv_attribute_control_pvt.check_pending_adjustments
                       (p_org_id      => p_org_id,
                        p_item_id     => p_item_id,
                        p_source_item => 'SECONDARY_UOM_CODE')) then
          x_pendadj_secondary_uom := 1;
       end if;
   end if;
   if (x_onhand_sec_default_ind <> 1) then
       if (inv_attribute_control_pvt.check_pending_adjustments
                       (p_org_id      => p_org_id,
                        p_item_id     => p_item_id,
                        p_source_item => 'SECONDARY_DEFAULT_IND')) then
          x_pendadj_sec_default_ind := 1;
       end if;
   end if;
   if (x_onhand_deviation_high <> 1) then
       if (inv_attribute_control_pvt.check_pending_adjustments
                       (p_org_id      => p_org_id,
                        p_item_id     => p_item_id,
                        p_source_item => 'DUAL_UOM_DEVIATION_HIGH')) then
          x_pendadj_deviation_high := 1;
       end if;
   end if;
   if (x_onhand_deviation_low <> 1) then
       if (inv_attribute_control_pvt.check_pending_adjustments
                       (p_org_id      => p_org_id,
                        p_item_id     => p_item_id,
                        p_source_item => 'DUAL_UOM_DEVIATION_LOW')) then
          x_pendadj_deviation_low := 1;
       end if;
   end if;
   if (x_onhand_child_lot <> 1) then
       if (inv_attribute_control_pvt.check_pending_adjustments
                       (p_org_id      => p_org_id,
                        p_item_id     => p_item_id,
                        p_source_item => 'CHILD_LOT_FLAG')) then
          X_pendadj_child_lot := 1;
       end if;
   end if;
   if (x_onhand_lot_divisible <> 1) then
       if (inv_attribute_control_pvt.check_pending_adjustments
                       (p_org_id      => p_org_id,
                        p_item_id     => p_item_id,
                        p_source_item => 'LOT_DIVISIBLE_FLAG')) then
          x_pendadj_lot_divisible := 1;
       end if;
   end if;
   if (x_onhand_grade <> 1) then
       if (inv_attribute_control_pvt.check_pending_adjustments
                       (p_org_id      => p_org_id,
                        p_item_id     => p_item_id,
                        p_source_item => 'GRADE_CONTROL_FLAG')) then
          x_pendadj_grade := 1;
       end if;
   end if;
   --End Bug 3713912

   -- Check if on-hand quantity for the item exists in master and all child orgs.
   if x_onhand_all IS NOT NULL THEN
     select count(*) into X_onhand_all
     from dual
     where exists  ( select 'x'
                     from  mtl_onhand_quantities_detail moh -- Bug:2687570
                     where  moh.inventory_item_id = p_item_id
                     and  moh.organization_id in  ( select mp.organization_id
                                                    from  mtl_parameters mp
                                                    where  mp.master_organization_id = p_master_org));
   end if;

   if X_wip_repetitive_item IS NOT NULL THEN
      select count(*) into X_wip_repetitive_item
      from dual
      where exists ( select 'x'
                     from  WIP_REPETITIVE_ITEMS wri
                     where  wri.PRIMARY_ITEM_ID = p_item_id
                     and  wri.ORGANIZATION_ID in ( select mp.organization_id
                                                   from  mtl_parameters mp
                                                   where  mp.master_organization_id = p_master_org));
   end if;

   IF x_rsv_exists IS NOT NULL THEN
      if (reservable_level = 1) then
         select count(1) into x_rsv_exists
         from mtl_reservations res,
	      mtl_parameters param
         where res.inventory_item_id = p_item_id
	  AND  res.organization_id   = param.organization_id
	  and  param.master_organization_id = p_master_org
          and reservation_quantity > 0
          and rownum = 1 ;
      else
         select count(1) into X_rsv_exists
        from mtl_reservations
        where organization_id   = p_org_id
          and inventory_item_id = p_item_id
          and reservation_quantity > 0
          and rownum = 1 ;
      end if ;
   end if ;

   x_so_rsv  := x_rsv_exists;                     --- Bug 1923215
   attr_name := 'MTL_SYSTEM_ITEMS.SHIPPABLE_ITEM_FLAG';

   -- bug 9043779, Check if the shipping org has open shipment or supply for internal requistion or inventory REQ
   IF (X_open_shipment_lot IS NOT NULL or X_open_shipment_serial IS NOT NULL ) THEN

      select count(1)
      into open_shipment_org_count
      from rcv_shipment_headers rsh, rcv_shipment_lines rsl
      where rsh.shipment_header_id = rsl.shipment_header_id
         and rsh.receipt_source_code IN ('INTERNAL ORDER', 'INVENTORY')
         and exists (select 1
                  from mtl_supply ms
                  where ms.shipment_header_id = rsh.shipment_header_id
                    and ms.shipment_line_id = rsl.shipment_line_id
                    and ms.supply_type_code in ('SHIPMENT', 'RECEIVING'))
         and rsl.item_id = p_item_id
         and rsl.from_organization_id = p_org_id
         and rownum = 1;

      if (open_shipment_org_count <> 1) then
         select count(1)
         into open_shipment_master_count
         from rcv_shipment_headers rsh, rcv_shipment_lines rsl
         where rsh.shipment_header_id = rsl.shipment_header_id
            and rsh.receipt_source_code IN ('INTERNAL ORDER', 'INVENTORY')
            and exists (select 1
                     from mtl_supply ms
                     where ms.shipment_header_id = rsh.shipment_header_id
                       and ms.shipment_line_id = rsl.shipment_line_id
                       and ms.supply_type_code in ('SHIPMENT', 'RECEIVING'))
            and rsl.item_id = p_item_id
            and rsl.from_organization_id IN  (SELECT organization_id
                                     FROM   mtl_parameters
                                     WHERE  master_organization_id = p_master_org)
            and rownum = 1;
      end if;

      if (open_shipment_org_count = 1) then
         X_open_shipment_lot := 1;
         X_open_shipment_serial := 1;
      elsif (lot_level = 1 and open_shipment_master_count = 1) then
         X_open_shipment_lot := 1;
      elsif (serial_level = 1 and open_shipment_master_count = 1) then
         X_open_shipment_serial := 1;
      end if;
   end if;
   -- end bug 9043779

-- Bug 4139938 - for improving performance, breaking statement into parts
-- logic of the complete SQL remains same.
  IF X_so_ship IS NOT NULL THEN

  declare /*Changes made for perf issue for bug 7567261*/
   shipping_level NUMBER :=0;
  begin
    select count(1) into shipping_level
    from mtl_item_attributes
    where control_level = 1
    and attribute_name=attr_name;

    if (shipping_level = 0) then
	    select count(1) into X_so_ship -- bug 10405137
	    from oe_order_lines_all l
	    where l.inventory_item_id = p_item_id
	    and l.open_flag  = 'Y'
	    and nvl(l.shipping_interfaced_flag,'N') = 'N'
	    and  l.ship_from_org_id = p_org_id
	    and rownum = 1;
    else
      select count(1) into X_so_ship -- bug 10405137
      from oe_order_lines_all l
      where l.inventory_item_id = p_item_id
      and l.open_flag  = 'Y'
      and nvl(l.shipping_interfaced_flag,'N') = 'N'
      and l.ship_from_org_id in
          (select organization_id
            from mtl_parameters
            where master_organization_id = p_master_org
           )
      and rownum = 1;
    end if;
 -- Bug 12669090: Start
  IF (X_so_ship = 0) THEN
     IF (shipping_level = 0) THEN
      select count(1) into X_so_ship -- bug 10405137

      from  wsh_delivery_details wdd
      where wdd.inventory_item_id = p_item_id
        and  wdd.inv_interfaced_flag in ('N','P')
        -- Bug 3963689 Condition added so that if no sales order and on hand qty 0
        --then shippable flag of the item can be modified - Anmurali
        and wdd.released_status <> 'D'
        and wdd.source_code = 'OE'
        and wdd.organization_id  = p_org_id
        and rownum = 1;
    ELSE
            select count(1) into X_so_ship -- bug 10405137
            from  wsh_delivery_details wdd
            where wdd.inventory_item_id = p_item_id
              and  wdd.inv_interfaced_flag in ('N','P')
              -- Bug 3963689 Condition added so that if no sales order and on hand qty 0
              --then shippable flag of the item can be modified - Anmurali
              and wdd.released_status <> 'D'
              and wdd.source_code = 'OE'
              and wdd.organization_id in (select organization_id
 	                                       from mtl_parameters
 	                                       where master_organization_id = p_master_org)
              and rownum = 1;
      END IF;
    END IF;
  end;
  END IF;
-- Bug 4139938 end

/* Bug 1923215
 Modified the below SQL to use the oe_order_lines_all Table
 as so_lines_all and so_line_details are obsoleted in R11i
*/
  -- Check for open sales order line with a different value for
  -- so_transactions_flag than in mtl_system_items
  -- If controlled at Item level, check child orgs too
  -- Used for validation on so_transactions_flag
  -- X_so_txn will have either 0 or 1
  attr_name := 'MTL_SYSTEM_ITEMS.SO_TRANSACTIONS_FLAG';
  IF X_so_txn IS NOT NULL THEN
  select count(1)
  into X_so_txn
  from oe_order_lines_all l
  where l.inventory_item_id = p_item_id
  and l.open_flag  = 'Y'  -- Bug 8435071
  and (l.ship_from_org_id in
        (select organization_id
         from mtl_parameters
         where master_organization_id= p_master_org
         and 1=transaction_level)
  or l.ship_from_org_id= p_org_id)
  and rownum = 1;
  END IF;

-- bug 10405137, comment it as it wouldn't be executed
/*  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;*/

  -- Check for open sales order line for the item
  IF X_so_open_exists IS NOT NULL THEN
  select count(*) into X_so_open_exists from dual
  where exists
  ( select * from oe_order_lines_all
    where inventory_item_id = p_item_id
      and open_flag  = 'Y'  -- Bug 8435071
  );
  END IF;

  -- Check for reservations + open demand
  -- If controlled at Item level, check child orgs too
  -- Used to determine if so_transactions_flag is updateable
  -- X_demand_exists will have either 0 or 1

/* Bug 1923215
   Commenting the following Code
   Confirmed with OM Team that they are not using so_transactions Flag
   to control the Open Demand.
*/

/*
  select count(1)
  into X_demand_exists
  from oe_order_lines_all
  where inventory_item_id = p_item_id
  and visible_demand_flag = 'Y'
  and shipped_quantity is NOT null
  and (ship_from_org_id in
        (select organization_id
         from mtl_parameters
         where master_organization_id = p_master_org
         and 1=(select control_level
                from mtl_item_attributes
                where
                attribute_name='MTL_SYSTEM_ITEMS.SO_TRANSACTIONS_FLAG'
               )
        )
  or ship_from_org_id = p_org_id)
  and rownum = 1;

  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;

*/


  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- First check if a conversion exists for this item's primary uom
  --  or if the item's primary uom is base unit of measure.
  -- Check if uom conversions exist for this item (either item-specific
  -- or inter-class conversions)
  -- Used to determine if allowed_units_lookup_code is updateable
  -- Use local variables for each sql statement, return 1 value to form
  IF X_uom_conv IS NOT NULL THEN
  select count(*)
    into uom_conv
  from dual
  where exists
        ( select 'x'
          from mtl_uom_conversions
          where inventory_item_id = p_item_id
            and uom_code = p_primary_uom_code
        );

  if (uom_conv = 0) then

     select decode(base_uom_flag, 'Y', 1, 0)
       into uom_conv
     from mtl_units_of_measure_vl
     where uom_code = p_primary_uom_code;

  end if;

if (uom_conv = 0) then

  select count(1)
  into uom_other_conv
  from sys.dual
  where exists
    (select 'x' from mtl_uom_conversions
   where inventory_item_id = p_item_id)
  or exists
  (select 'x' from mtl_uom_class_conversions
   where inventory_item_id = p_item_id);

end if;

  -- Only need to know if there is no conversion for primary uom but
  -- there are other conversions - return 1 in this case.
  --
  if (uom_conv = 0 and uom_other_conv = 1) then
     X_uom_conv := 1;
  end if;
  END IF;

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  -- Check if the item is a component with Check ATP = 1 (yes) in
  -- bom_inventory_components.
  -- If controlled at Item level, check in child orgs too
  -- Used to determine if atp_flag is updateable
  -- X_comp_atp will have either 0 or 1

  --3432253 atp check nolonger required...please refer to below mentioned bugs.
  --The below query is causing a performance problem and query result is not used.
  --Bug 1457730 : we do not need this validation after bugfix 1123857 in BOM
  /*
  select LEADING(BIC) INDEX(BIC BOM_INVENTORY_COMPONENTS_N1) USE_NL(BIC BOM)
        count(1)
  into X_comp_atp
  from bom_inventory_components bic, bom_bill_of_materials bom
  where bic.bill_sequence_id = bom.common_bill_sequence_id
  and bic.component_item_id = p_item_id
  and bic.check_atp = 1
  and (bom.organization_id in
        (select organization_id
         from mtl_parameters
         where master_organization_id = p_master_org
         and 1 = (select control_level
                  from mtl_item_attributes
                  where attribute_name= 'MTL_SYSTEM_ITEMS.ATP_FLAG')
        )
  or bom.organization_id = p_org_id)
  and rownum = 1;


  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;
 */
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  -- Check if a BOM is defined in master or any child orgs
  -- Used to determine if bom_item_type is updateable
  -- X_bom_exists will have either 0 or 1

  /*select count(*) into bom_row_exists from dual
  where exists
  ( select 'x' from bom_bill_of_materials bom
    where  bom.assembly_item_id = p_item_id
      and  bom.organization_id in
           ( select organization_id
             from  mtl_parameters
             where  master_organization_id = p_master_org
           )
  );*/

   -- Added the bill existence check based on attribute control for BOM allowed
   -- as part of fix for bug#3451941.
  IF X_bom_exists IS NOT NULL THEN
  select count(*) into bom_row_exists from dual
  where exists
  ( select 'x' from bom_bill_of_materials bom
    where  bom.assembly_item_id = p_item_id
      and  bom.organization_id in
           ( select organization_id
             from  mtl_parameters
             where  master_organization_id = p_master_org
             and 1 = bom_enabled_level
             union all
             select organization_id
             from  mtl_parameters
             where  organization_id = p_org_id
             and 2 = bom_enabled_level
          )
  );
  END IF;

  X_bom_exists := bom_row_exists;

  -- Check if there are rows in bom_substitute_components
  -- bom_item_type is always controlled at Item level, so check all child orgs
  -- Used to determine if bom_item_type is updateable
  -- Local variable bom_substitute will have either 0 or 1
IF X_bom_item IS NOT NULL THEN
if (bom_row_exists <> 1) then

  select count(1)
  into bom_substitute
  from bom_substitute_components sub,
       bom_inventory_components inv,
       bom_bill_of_materials bom
  where sub.substitute_component_id = p_item_id
  and sub.component_sequence_id = inv.component_sequence_id
  and inv.bill_sequence_id = bom.bill_sequence_id
  and bom.organization_id in
        (select organization_id
         from mtl_parameters
         where master_organization_id= p_master_org)
  and rownum = 1;

end if;

  -- Check if there are rows in bom_inventory_components
  -- bom_item_type is always controlled at Item level, so check all child orgs
  -- Used to determine if bom_item_type is updateable
  -- Local variable bom_inventory will have either 0 or 1

if (bom_row_exists <> 1 and bom_substitute <> 1) then

  select /*+ LEADING(INV) INDEX(INV BOM_INVENTORY_COMPONENTS_N1) USE_NL(INV BOM) */
        count(1)
  into bom_inventory
  from bom_inventory_components inv, bom_bill_of_materials bom
  where inv.component_item_id = p_item_id
  and inv.bill_sequence_id=bom.bill_sequence_id
  and exists (select count(1)
          from MTL_PARAMETERS
          WHERE MASTER_ORGANIZATION_ID= p_master_org AND BOM.ORGANIZATION_ID = ORGANIZATION_ID)
  and rownum = 1;

end if;

  if (bom_row_exists = 1 or bom_substitute = 1 or bom_inventory = 1) then
    X_bom_item := 1;
  end if;
 END IF;

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Check if there is onhand or transactions pending or uncosted
  -- transactions for this item in any orgs where the costing org
  -- is the current org
  -- Used to determine if inventory_asset_flag is updateable
  -- Use local variables for each sql statement, return 1 variable to form
  -- X_cost_txn will have either 0 or 1
  IF X_cost_txn IS NOT NULL THEN
  select count(1)
  into cost_moq
  from mtl_onhand_quantities_detail  -- Bug:2687570
  where inventory_item_id = p_item_id
  and organization_id in
        (select organization_id
         from mtl_parameters
         where cost_organization_id = p_org_id)
  and rownum = 1;

if (cost_moq <> 1) then
  select count(1)
  into cost_moq2
  from mtl_onhand_quantities_detail  -- Bug:2687570
  where inventory_item_id = p_item_id
  and organization_id in
       (select organization_id
        from mtl_parameters
        where master_organization_id = p_master_org
        and (1=inv_asset_level  OR  1=cost_enabled_level))
  and rownum = 1;

end if;

if (cost_moq <> 1 and cost_moq2 <> 1) then

  select count(1)
  into cost_tmp
  from mtl_material_transactions_temp
  where inventory_item_id = p_item_id
  and organization_id in
        (select organization_id
         from mtl_parameters
         where cost_organization_id = p_org_id)
  and rownum = 1;

end if;

if (cost_moq <> 1 and cost_moq2 <> 1 and cost_tmp <> 1) then

  select count(1)
  into cost_mmt
  from mtl_material_transactions
  where inventory_item_id = p_item_id
  and organization_id in
        (select organization_id
         from mtl_parameters
         where cost_organization_id = p_org_id)
  and costed_flag is not null
  and rownum = 1;

end if;

  if (cost_moq = 1 or cost_moq2 = 1 or cost_tmp = 1 or cost_mmt = 1) then
    X_cost_txn := 1;
  end if;
END IF;

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Check if there are required descriptive elements that are currently
  --  null for this item
  -- Used to determine if catalog_status_flag can be set to 'Y'
  -- X_null_elem_exists will have either 0 or 1
  -- We need to do this check only in master org items, since the
  -- catalog_status_flag is always controlled at the master org level

 if (p_master_org = p_org_id) AND (X_null_elem_exists IS NOT NULL) then
  select count(1)
  into X_null_elem_exists
  from mtl_descriptive_elements e,
       mtl_descr_element_values v
  where e.required_element_flag = 'Y'
  and e.item_catalog_group_id = p_catalog_group_id
  and v.inventory_item_id = p_item_id
  and v.element_name = e.element_name
  and v.element_value is null
  and rownum = 1;
 end if ;

  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Check if the item exists on an mrp schedule
  -- X_mrp_schedule = 1 if it exists on a schedule, 0 otherwise
  IF X_mrp_schedule IS NOT NULL THEN
  select count(1)
  into X_mrp_schedule
  from mrp_schedule_items
  where inventory_item_id = p_item_id
  and organization_id = p_org_id
  and rownum = 1;
  END IF;
--Bug: 2691174 Disabling vehicle items from being edited if a corresponding
-- vehicle type is exists in FTE_VEHICLE_TYPES
  IF INV_ITEM_UTIL.Appl_Inst_FTE <> 0 AND X_fte_vechicle_exists IS NOT NULL THEN
   SELECT count(1)
    INTO  l_tab_exists
     FROM TAB
     WHERE TNAME = 'FTE_VEHICLE_TYPES'
       AND ROWNUM = 1;
   IF l_tab_exists > 0 THEN
--Bug: 2812994 Corrected the Dynamic SQL
    EXECUTE IMMEDIATE
    'SELECT count(1) '||
      'FROM FTE_VEHICLE_TYPES '||
      'WHERE INVENTORY_ITEM_ID = :p_item_id '||
        'AND ORGANIZATION_ID = :p_org_id '||
        'AND ROWNUM = 1'
     INTO  X_fte_vechicle_exists USING IN p_item_id, IN p_org_id;
   END IF;
  END IF;

  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Added for 11.5.10 bug 3012796
  -- Check if the master org is process enabled org
  -- X_process_enabled = 1 if master org is process enabled, 0 otherwise
  -- Check if the item is VMI/Consign enabled
  IF X_process_enabled IS NOT NULL THEN
  select count(1)
  into X_process_enabled
  from mtl_parameters
  where organization_id = p_org_id
  and   process_enabled_flag = 'Y'
  and rownum = 1;
  END IF;

  IF X_vmiorconsign_enabled IS NOT NULL OR X_consign_enabled IS NOT NULL THEN
  VMI_Table_Queries(
     p_org_id
   , p_item_id
   , X_vmiorconsign_enabled
   , X_consign_enabled);
  END IF;

END Table_Queries;

FUNCTION  Get_inv_item_id Return Number is
BEGIN

        RETURN (G_inv_item_id);

END Get_inv_item_id;

PROCEDURE Set_inv_item_id(item_id number)
IS
BEGIN

  G_inv_item_id := item_id;

END Set_inv_item_id;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Added for 11.5.10 bug 3012796
-- Check if the item is VMI/Consign enabled
-- X_vmiorconsign_enabled = 'Y' if the item is VMI/Consign enabled, 'N' otherwise
-- X_consign_enabled = 'Y' if the item is Consign enabled, 'N' otherwise

PROCEDURE VMI_Table_Queries
( p_org_id                  IN    NUMBER
, p_item_id                 IN    NUMBER
, X_vmiorconsign_enabled    OUT NOCOPY NUMBER
, X_consign_enabled         OUT NOCOPY NUMBER
)
IS
  -- Local variables
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(1000);
  l_consign_flag        VARCHAR2(1);
  l_vmiorconsign_flag   VARCHAR2(1);
BEGIN

  INV_PO_ITEMVALID_MDTR.check_vmiorconsign_enabled (
      p_api_version    => 1
    , p_init_msg_list  => 'T'
    , x_return_status  => l_return_status
    , x_msg_count      => l_msg_count
    , x_msg_data       => l_msg_data
    , p_item_id        =>  p_item_id
    , p_organization_id => p_org_id
    , x_vmiorconsign_flag => l_vmiorconsign_flag );

  if (l_vmiorconsign_flag = 'Y') then
    X_vmiorconsign_enabled := 1;
  else
    X_vmiorconsign_enabled := 0;
  end if;
  INV_PO_ITEMVALID_MDTR.check_consign_enabled (
      p_api_version    => 1
    , p_init_msg_list  => 'T'
    , x_return_status  => l_return_status
    , x_msg_count      => l_msg_count
    , x_msg_data       => l_msg_data
    , p_item_id        => p_item_id
    , p_organization_id => p_org_id
    , x_consign_flag   => l_consign_flag );

  if (l_consign_flag = 'Y') then
    X_consign_enabled := 1;
  else
    X_consign_enabled := 0;
  end if;

END VMI_Table_Queries;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Added for 11.5.10 bug 3171098
-- Check for proper catalog category setup for PLM
--Bug: 3491746 New catalog should not have NIR and if not child catalog then
--     check whether item has any open/hold CO's for an item
FUNCTION Is_Catalog_Group_Valid(
       old_catalog_group_id VARCHAR2,
       new_catalog_group_id VARCHAR2,
       item_id              NUMBER) RETURN VARCHAR2
IS

l_sql VARCHAR2(4000) :=
  'SELECT ''Y''
     FROM eng_revised_items eri
    WHERE eri.revised_item_id = :cp_item_id
      AND eri.status_type NOT IN (5, 6)
      AND ( eri.NEW_ITEM_REVISION_ID IS NOT null --this CO creates a revision
            OR EXISTS                            --this CO has AML Change
               (SELECT NULL
                  FROM  ego_mfg_part_num_chgs
                 WHERE change_line_id = eri.revised_item_sequence_id )
            OR EXISTS                            --this CO has UDA Change
               (SELECT NULL
                  FROM  ego_items_attrs_changes_b
                 WHERE change_line_id = eri.revised_item_sequence_id )
            OR EXISTS                            --this CO has Attachment Change
               (SELECT NULL
                  FROM  eng_attachment_changes
                 WHERE revised_item_sequence_id = eri.revised_item_sequence_id )
            OR EXISTS                            --this CO has Operational Attribute Change
               (SELECT NULL
                  FROM  ego_mtl_sy_items_chg_b
                 WHERE change_line_id = eri.revised_item_sequence_id
                   AND change_id = eri.change_id)
            OR EXISTS                            --this CO has GTIN Single Change
               (SELECT NULL
                  FROM  ego_gtn_attr_chg_b
                 WHERE change_line_id = eri.revised_item_sequence_id
                   AND change_id = eri.change_id)
            OR EXISTS                            --this CO has GTIN Multi Change
               (SELECT NULL
                  FROM  ego_gtn_mul_attr_chg_b
                WHERE change_line_id = eri.revised_item_sequence_id
                  AND change_id = eri.change_id)
            OR EXISTS                            --this CO has Related Doc Change
               (SELECT NULL
                  FROM  eng_relationship_changes
                 WHERE ENTITY_ID = eri.revised_item_sequence_id
                   AND change_id = eri.change_id
                   AND ENTITY_NAME=''ITEM'')
            OR EXISTS                           --this CO has Structure Changes
               (SELECT NULL
                  FROM bom_components_b
                 WHERE revised_item_sequence_id = eri.revised_item_sequence_id)
          )
          AND ROWNUM =1 ';

 l_child_catalog  VARCHAR2(200) := NULL;
 l_co_exists      VARCHAR2(200) := NULL;

BEGIN
  l_child_catalog := 'N';
  IF new_catalog_group_id IS NOT NULL THEN
  BEGIN
     SELECT 'Y' INTO L_child_catalog
       FROM mtl_item_catalog_groups_b icg
      WHERE icg.item_creation_allowed_flag = 'Y' AND
           ((inactive_date is null) or ((trunc(inactive_date) > trunc(sysdate)) OR
           (icg.item_catalog_group_id=item_catalog_group_id)))  AND
	   icg.item_catalog_group_id = new_catalog_group_id
    CONNECT BY   prior icg.item_catalog_group_id = icg.parent_catalog_group_id
      START WITH       icg.item_catalog_group_id = old_catalog_group_id;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_child_catalog := 'N';
  END;
  END IF;

  IF (l_child_catalog <> 'Y') THEN                      --If not child catalog
    IF (old_catalog_group_id) IS NOT NULL
    THEN
       IF FND_PROFILE.DEFINED('EGO_OCD_ENABLED')  THEN--Bug: 3570886
          BEGIN
             EXECUTE IMMEDIATE l_sql INTO l_co_exists USING item_id;
             EXCEPTION
             WHEN OTHERS THEN --Bug:3610290
                l_co_exists := 'N';
          END;
       END IF;
    END IF;
  END IF;

  IF (l_child_catalog <> 'Y' AND
      l_co_exists = 'Y') THEN
     RETURN('INV_INVALID_CATALOG_SETUP');
  END IF;
  RETURN NULL;

END Is_Catalog_Group_Valid;

  FUNCTION CHECK_NPR_CATALOG(p_catalog_group_id NUMBER)
  RETURN  BOOLEAN IS

     CURSOR c_get_npr_flag(cp_catalog_group_id NUMBER) IS
        SELECT new_item_request_reqd
        FROM   mtl_item_catalog_groups_b
        CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
        START WITH item_catalog_group_id         = cp_catalog_group_id;

     l_npr_flag                 mtl_item_catalog_groups_b.new_item_request_reqd%TYPE;
     l_return_value             BOOLEAN := FALSE;
     l_miss_num     CONSTANT    NUMBER  :=  9.99E125;
  BEGIN

     IF  p_catalog_group_id IS NOT NULL
     AND p_catalog_group_id <> l_miss_num THEN

        FOR cur IN c_get_npr_flag(p_catalog_group_id) LOOP
           IF cur.new_item_request_reqd = 'Y' THEN
              l_return_value := TRUE;
           ELSIF NVL(cur.new_item_request_reqd,'N') = 'N' THEN
              l_return_value := FALSE;
           END IF;

           EXIT WHEN NVL(cur.new_item_request_reqd,'N') <> 'I';

        END LOOP;

     END IF;

     RETURN l_return_value;

  EXCEPTION
     WHEN OTHERS THEN
        RETURN l_return_value;
  END CHECK_NPR_CATALOG;

  FUNCTION CHECK_ITEM_APPROVED(p_inventory_item_id NUMBER
                              ,p_organization_id   NUMBER)
  RETURN BOOLEAN IS

     CURSOR c_get_item_status(cp_inventory_item_id NUMBER
                             ,cp_organization_id   NUMBER)
     IS
        SELECT approval_status
        FROM   mtl_system_items_b
        WHERE  inventory_item_id = cp_inventory_item_id
        AND    organization_id   = cp_organization_id;

     l_return_value BOOLEAN := FALSE;
     l_item_approval_status mtl_system_items_b.approval_status%TYPE;

  BEGIN

     OPEN  c_get_item_status(p_inventory_item_id,p_organization_id);
     FETCH c_get_item_status INTO l_item_approval_status;
     CLOSE c_get_item_status;

     IF NVL(l_item_approval_status,'A') = 'A' THEN
        l_return_value := TRUE;
     END IF;

     RETURN l_return_value;

  EXCEPTION
     WHEN OTHERS THEN
        IF c_get_item_status%ISOPEN THEN
           CLOSE c_get_item_status;
        END IF;
        RETURN l_return_value;
  END CHECK_ITEM_APPROVED;

--Added for Bug: 4569555
PROCEDURE CSI_Table_Queries (
   p_inventory_item_id   IN NUMBER
  ,p_organization_id     IN NUMBER
  ,X_ib_ret_status       OUT NOCOPY VARCHAR2
  ,X_ib_msg              OUT NOCOPY VARCHAR2) IS

  l_plsql_blk   VARCHAR2(2000);
  l_msg_count   NUMBER;
BEGIN
   IF INV_ITEM_UTIL.Appl_Inst_CSI <> 0 THEN
      BEGIN
        l_plsql_blk :=
        'BEGIN
               CSI_UTILITY_GRP.vld_item_ctrl_changes (
                       p_api_version          =>  1.0
                      ,p_commit               =>  fnd_api.g_false
                      ,p_init_msg_list        =>  fnd_api.g_false
                      ,p_validation_level     =>  fnd_api.g_valid_level_full
                      ,p_inventory_item_id    =>  :1
                      ,p_organization_id      =>  :2
                      ,p_item_attr_name       =>  NULL
                      ,p_new_item_attr_value  =>  NULL
                      ,p_old_item_attr_value  =>  NULL
                      ,x_return_status        =>  :X_ib_ret_status
                      ,x_msg_count            =>  :l_msg_count
                      ,x_msg_data             =>  :X_ib_msg);
           END;';
           EXECUTE IMMEDIATE l_plsql_blk
           USING p_inventory_item_id, p_organization_id,OUT X_ib_ret_status,OUT l_msg_count,OUT X_ib_msg;
           X_ib_ret_status:= FND_API.G_RET_STS_ERROR;
      EXCEPTION
         WHEN OTHERS THEN
            X_ib_ret_status:= FND_API.G_RET_STS_SUCCESS;
            X_ib_msg       := NULL;
      END;
   ELSE
      X_ib_ret_status:= FND_API.G_RET_STS_SUCCESS;
      X_ib_msg       := NULL;
   END IF;
END CSI_Table_Queries;

END INVIDIT3;

/
