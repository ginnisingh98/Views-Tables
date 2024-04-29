--------------------------------------------------------
--  DDL for Package Body INV_ITEM_INQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_INQ" AS
/* $Header: INVIQWMB.pls 120.15 2008/02/13 12:00:39 abaid noship $ */

FUNCTION get_status_code (
        p_status_id mtl_material_statuses_vl.status_id%TYPE
        ) RETURN VARCHAR2 IS
        x_status_code mtl_material_statuses_vl.status_code%TYPE;
BEGIN
        IF p_status_id IS NULL THEN
                x_status_code := '';
        ELSE
                SELECT status_code
                INTO x_status_code
                FROM mtl_material_statuses_vl
                WHERE status_id = p_status_id;
        END IF;
        return x_status_code;
END get_status_code;

/***************************
 * Obtain onhand information
 *  INV org
 **************************/
/* THIS PROCEDURE IS NOT BEING USED ANYWHERE */
PROCEDURE INV_ITEM_INQUIRIES  (
               x_item_inquiries          OUT NOCOPY t_genref,
               p_Organization_Id         IN NUMBER,
               p_Inventory_Item_Id       IN NUMBER   DEFAULT NULL,
               p_Revision                IN VARCHAR2 DEFAULT NULL,
               p_Lot_Number              IN VARCHAR2 DEFAULT NULL,
               p_Subinventory_Code       IN VARCHAR2 DEFAULT NULL,
               p_Locator_Id              IN NUMBER DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2) IS
BEGIN
      OPEN x_item_inquiries FOR
         SELECT msik.concatenated_segments,  -- Item Concatenated Segments
                moq.revision,
           msik.description,
                moq.subinventory_code,
           moq.locator_id,
                milk.concatenated_segments,  -- Locator Concatenated Segments
                moq.lot_number,
                msik.primary_uom_code,
                sum(nvl(moq.primary_transaction_quantity, 0)),
                inv_ITEM_INQ.get_available_qty(
                     moq.organization_id,
                     moq.inventory_item_id,
                     moq.revision,
                     moq.subinventory_code,
                     moq.locator_id,
                     moq.lot_number,null,
                     decode(moq.revision, NULL, 'FALSE', 'TRUE'),
                     decode(msik.lot_control_code, 2, 'TRUE', 'FALSE'),
                     decode(msik.serial_number_control_code, NULL, 'FALSE', 1, 'FALSE', 'TRUE')),
      inv_item_inq.get_status_code(msub.status_id),
      inv_item_inq.get_status_code(milk.status_id),
      inv_item_inq.get_status_code(mln.status_id),
      msik.serial_number_control_code,
         moq.cost_group_id

          FROM  mtl_onhand_quantities_detail moq,
                mtl_system_items_vl msik, -- Modified for Bug # 5472330
                mtl_item_locations_kfv milk,
           mtl_secondary_inventories msub,
      mtl_lot_numbers mln
          /*    mtl_serial_numbers msn Commenting for bug 1643966 as this table is not reqd.  */
          WHERE moq.organization_id = msik.organization_id
          AND   moq.inventory_item_id = msik.inventory_item_id
          AND   moq.organization_id = msub.organization_id
          AND   moq.subinventory_code = msub.secondary_inventory_name(+)
          AND   moq.organization_id = milk.organization_id(+)
          AND   moq.locator_id = milk.inventory_location_id(+)
          AND   moq.subinventory_code = milk.subinventory_code(+)
     AND   moq.organization_id = mln.organization_id(+)
     AND   moq.inventory_item_id = mln.inventory_item_id(+)
   /*     AND   moq.organization_id = msn.current_organization_id(+) bug 1643966 rnrao
     AND   moq.inventory_item_id = msn.inventory_item_id(+)
          and   moq.cost_group_id = msn.cost_group_id(+)*/
     AND   moq.lot_number = mln.lot_number(+)
          AND   moq.organization_id        = p_Organization_Id
          AND   moq.inventory_item_id     =
                decode (p_Inventory_Item_Id, NULL, moq.inventory_item_id, p_Inventory_Item_Id)
          -- Bug 4301817 Not check mtl_transactions_enabled_flag to query non-transactable items
          -- AND   msik.mtl_transactions_enabled_flag = 'Y'
          AND   nvl(moq.revision, '!@#$%^&') =
              decode(p_Revision, NULL, nvl(moq.revision, '!@#$%^&'), p_Revision)
          AND   nvl(moq.lot_number, '!@#$%^&') =
              decode (p_Lot_Number, NULL, nvl(moq.lot_number, '!@#$%^&'), p_Lot_Number)
          AND   nvl(moq.subinventory_code, '!@#$%^&') =
              decode (p_Subinventory_Code, NULL, nvl(moq.subinventory_code, '!@#$%^&'), p_Subinventory_Code)
          AND   nvl(moq.locator_id, 0) =
              decode(p_Locator_Id, NULL, nvl(moq.locator_id, 0), p_Locator_Id)
          GROUP BY moq.organization_id, moq.inventory_item_id,
               msik.concatenated_segments, moq.revision, msik.description,
               moq.subinventory_code, moq.locator_id, milk.concatenated_segments,
               moq.lot_number, msik.primary_uom_code,
               inv_item_inq.get_available_qty(
                   moq.organization_id,
                   moq.inventory_item_id,
                   moq.revision,
                   moq.subinventory_code,
                   moq.locator_id,
                   moq.lot_number, null,
                   decode(moq.revision, NULL, 'FALSE', 'TRUE'),
                   decode(msik.lot_control_code, 2, 'TRUE', 'FALSE'),
                   decode(msik.serial_number_control_code, NULL, 'FALSE', 1, 'FALSE', 'TRUE')),
      inv_item_inq.get_status_code(msub.status_id),
      inv_item_inq.get_status_code(milk.status_id),
      inv_item_inq.get_status_code(mln.status_id),
      msik.serial_number_control_code,
        moq.cost_group_id;

       x_status := 'C';
       x_message := 'Records found';
END  INV_ITEM_INQUIRIES;

/******************************************
 * Obtain onhand information
 *  WMS org, provide cost group information
 *       query wms related information
 *****************************************/
/* THIS PROCEDURE IS NOT BEING USED ANYWHERE */
PROCEDURE WMS_LOOSE_ITEM_INQUIRIES  (
               x_item_inquiries          OUT NOCOPY t_genref,
               p_Organization_Id         IN NUMBER,
               p_Inventory_Item_Id       IN NUMBER   DEFAULT NULL,
               p_Revision                IN VARCHAR2 DEFAULT NULL,
               p_Lot_Number              IN VARCHAR2 DEFAULT NULL,
               p_Subinventory_Code       IN VARCHAR2 DEFAULT NULL,
               p_Locator_Id              IN NUMBER DEFAULT NULL,
             p_cost_Group_id      IN NUMBER DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2) IS
BEGIN
      OPEN x_item_inquiries FOR
   SELECT b.msik_concatenated_segments,
               b.revision,
               b.description,
               b.subinventory_code,
               b.subinventory_status,
               b.locator_id,
               b.milk_concatenated_segments,
               b.locator_status,
               b.cost_group_id,
               b.cost_group,
               b.lot_number,
               b.lot_status,
               b.primary_uom_code,
               b.sum_txn_qty,
               inv_item_inq.get_available_qty(
                                      b.organization_id,
                                      b.inventory_item_id,
                                      b.revision,
                                      b.subinventory_code,
                                      b.locator_id,
                                      b.lot_number,
                                      b.cost_group_id,
                                      decode(b.revision, NULL, 'FALSE', 'TRUE'),
                                      decode(b.lot_control_code, 2, 'TRUE', 'FALSE'),
                                     decode(b.serial_number_control_code, NULL, 'FALSE', 1, 'FALSE', 'TRUE')),
                inv_item_inq.get_packed_quantity(
                        b.organization_id, b.inventory_item_id, b.revision,
                        b.subinventory_code, b.locator_id, b.lot_number, b.cost_Group_id),
                inv_item_inq.get_loose_quantity(
                        b.organization_id, b.inventory_item_id, b.revision,
                        b.subinventory_code, b.locator_id, b.lot_number, b.cost_Group_id),
                b.serial_number_control_code
     FROM
        (SELECT moq.organization_id organization_id,
           moq.inventory_item_id inventory_item_id,
           msik.concatenated_segments msik_concatenated_segments,
           moq.revision revision,
           msik.description description,
           moq.subinventory_code subinventory_code,
           mms1.status_code subinventory_status,
           moq.locator_id locator_id,
           milk.concatenated_segments milk_concatenated_segments,
           mms2.status_code locator_status,
           moq.cost_group_id cost_group_id,
           csg.cost_group cost_group,
           moq.lot_number lot_number,
           mms3.status_code lot_status,
           msik.primary_uom_code primary_uom_code,
           sum(nvl(moq.primary_transaction_quantity, 0)) sum_txn_qty,
           msik.lot_control_code lot_control_code,
           msik.serial_number_control_code serial_number_control_code
       FROM  mtl_onhand_quantities_detail moq,
             mtl_system_items_vl msik, -- Modified for Bug # 5472330
             mtl_item_locations_kfv milk,
             mtl_secondary_inventories msub,
             mtl_lot_numbers mlot,
             mtl_material_statuses_vl mms1,
             mtl_material_statuses_vl mms2,
             mtl_material_statuses_vl mms3,
             cst_cost_groups csg
       WHERE moq.organization_id = msik.organization_id
       AND   moq.inventory_item_id = msik.inventory_item_id
       AND   moq.organization_id = msub.organization_id
       AND   moq.subinventory_code = msub.secondary_inventory_name(+)
       AND   msub.status_id = mms1.status_id(+)
       AND   moq.organization_id = milk.organization_id
       AND   moq.locator_id = milk.inventory_location_id(+)
       aND   milk.status_id = mms2.status_id(+)
       AND   moq.subinventory_code = milk.subinventory_code(+)
       AND   moq.lot_number = mlot.lot_number(+)
       AND   moq.inventory_item_id = mlot.inventory_item_id(+)
       ANd   moq.organization_id = mlot.organization_id(+)
       AND   mlot.status_id = mms3.status_id(+)
       AND   moq.cost_group_id = csg.cost_group_id(+)
      -- AND   moq.organization_id = csg.organization_id(+)
       AND   moq.organization_id        = p_Organization_Id
       AND   moq.inventory_item_id     =
             decode (p_Inventory_Item_Id, NULL, moq.inventory_item_id, p_Inventory_Item_Id)
       -- Bug 4301817 Not check mtl_transactions_enabled_flag to query non-transactable items
       -- AND   msik.mtl_transactions_enabled_flag = 'Y'
       AND   nvl(moq.revision, '!@#$%^&') =
          decode(p_Revision, NULL, nvl(moq.revision, '!@#$%^&'), p_Revision)
       AND   nvl(moq.lot_number, '!@#$%^&') =
            decode (p_Lot_Number, NULL, nvl(moq.lot_number, '!@#$%^&'), p_Lot_Number)
       AND   nvl(moq.subinventory_code, '!@#$%^&') =
            decode (p_Subinventory_Code, NULL, nvl(moq.subinventory_code, '!@#$%^&'), p_Subinventory_Code)
       AND   nvl(moq.locator_id, 0) =
            decode(p_Locator_Id, NULL, nvl(moq.locator_id, 0), p_Locator_Id)
       AND   nvl(moq.cost_group_id, 0) =
            decode(p_cost_group_id, NULL, nvl(moq.cost_group_id, 0), p_cost_group_id)
       GROUP BY moq.organization_id,
           moq.inventory_item_id,
           msik.concatenated_segments,
           moq.revision,
           msik.description,
           moq.subinventory_code,
           mms1.status_code,
           moq.locator_id,
           milk.concatenated_segments,
           mms2.status_code,
           moq.cost_group_id,
           csg.cost_group,
           moq.lot_number,
           mms3.status_code,
           msik.primary_uom_code,
           msik.lot_control_code,
           msik.serial_number_control_code) b;
       x_status := 'C';
       x_message := 'Records found';
EXCEPTION
     when others then
        x_status := 'E';
--        x_message := SUBSTR (SQLERRM , 1 , 240);
        x_message := 'System error in select statement';
END WMS_LOOSE_ITEM_INQUIRIES;

/******************************************
 * Query for Inv org, giving serial number
 *****************************************/
/* THIS PROCEDURE IS NOT BEING USED ANYWHERE */
PROCEDURE INV_SERIAL_INQUIRIES (
               x_serial_inquiries       OUT NOCOPY t_genref,
               p_Organization_Id        IN NUMBER,
               p_Serial_Number          IN VARCHAR2  DEFAULT NULL,
               p_Inventory_Item_Id      IN NUMBER    DEFAULT NULL,
               p_Revision               IN VARCHAR2  DEFAULT NULL,
               p_Lot_Number             IN VARCHAR2  DEFAULT NULL,
               p_Subinventory_Code      IN VARCHAR2  DEFAULT NULL,
               p_Locator_Id             IN NUMBER    DEFAULT NULL,
               x_Status                OUT NOCOPY VARCHAR2,
               x_Message               OUT NOCOPY VARCHAR2) IS
BEGIN
      OPEN x_serial_inquiries FOR
      SELECT  msik.concatenated_segments, -- Item Concatenated Segments
              msn.revision,
         msik.description,
              msn.current_subinventory_code,
         msn.current_locator_id,
              milk.concatenated_segments, -- Locator Concatenated Segments
              msn.lot_number,
              msn.serial_number,
              msik.primary_uom_code,
              1
      FROM    MTL_SERIAL_NUMBERS msn,
              MTL_SYSTEM_ITEMS_VL msik, /* Bug 5581528 */
              MTL_ITEM_LOCATIONS_KFV milk
      WHERE   milk.organization_id(+) = msn.current_organization_id
      AND     milk.subinventory_code(+) = msn.current_subinventory_code
      AND     milk.inventory_location_id(+) = msn.current_locator_id
      AND     msn.inventory_item_id         = msik.inventory_item_id
      AND     msn.current_organization_id   = msik.organization_id
      AND     msik.organization_id   = p_Organization_Id
      -- Bug 4301817 Not check mtl_transactions_enabled_flag to query non-transactable items
      -- AND     msik.mtl_transactions_enabled_flag = 'Y'
      AND     msn.serial_number =
                decode(p_Serial_Number, NULL, msn.serial_number, p_Serial_Number)
      AND     msn.inventory_item_id         = p_Inventory_Item_Id
      AND     nvl(msn.revision, '!@#$%^&') =
                decode(p_Revision, NULL, nvl(msn.revision, '!@#$%^&'), p_Revision)
      AND     nvl(msn.current_subinventory_code, '!@#$%^&') =
                decode(p_Subinventory_Code, NULL, nvl(msn.current_subinventory_code, '!@#$%^&'), p_Subinventory_Code)
      AND     nvl(msn.current_locator_id, 99999999) =
                decode(p_Locator_Id, NULL, nvl(msn.current_locator_id, 99999999), p_Locator_Id)
      AND     nvl(msn.lot_number, '!@#$%^&') =
                decode(p_Lot_Number, NULL, nvl(msn.lot_number, '!@#$%^&'), p_Lot_Number);

     x_status := 'C';
     x_message := 'Records found';
END INV_SERIAL_INQUIRIES;

/******************************************
 * Query for WMS org, giving serial number
 *****************************************/

PROCEDURE WMS_LOOSE_SERIAL_INQUIRIES (
               x_serial_inquiries       OUT NOCOPY t_genref,
               p_Organization_Id        IN NUMBER,
               p_Serial_Number          IN VARCHAR2  DEFAULT NULL,
               p_Inventory_Item_Id      IN NUMBER    DEFAULT NULL,
               p_Revision               IN VARCHAR2  DEFAULT NULL,
               p_Lot_Number             IN VARCHAR2  DEFAULT NULL,
               p_Subinventory_Code      IN VARCHAR2  DEFAULT NULL,
               p_Locator_Id             IN NUMBER    DEFAULT NULL,
          p_cost_Group_id     IN NUMBER    DEFAULT NULL,
               x_Status                OUT NOCOPY VARCHAR2,
               x_Message               OUT NOCOPY VARCHAR2) IS
BEGIN
      OPEN x_serial_inquiries FOR
      SELECT  msik.concatenated_segments, -- Item Concatenated Segments
              msn.revision,
         msik.description,
              msn.current_subinventory_code,
         mms1.status_code subinventory_status,
         msn.current_locator_id,
              milk.concatenated_segments, -- Locator Concatenated Segments
         mms2.status_code locator_status,
         msn.cost_group_id,
         csg.cost_group,
              msn.lot_number,
         mms3.status_code lot_status,
              msn.serial_number,
         mms4.status_code serial_status,
              msik.primary_uom_code,
              1
      FROM    MTL_SERIAL_NUMBERS msn,
              MTL_SYSTEM_ITEMS_VL msik, /* Bug 5581528 */
              MTL_ITEM_LOCATIONS_KFV milk,
         MTL_SECONDARY_INVENTORIES msub,
         MTL_LOT_NUMBERS mlot,
         MTL_MATERIAL_STATUSES_vl mms1,
         MTL_MATERIAL_STATUSES_vl mms2,
         MTL_MATERIAL_STATUSES_vl mms3,
         MTL_MATERIAL_STATUSES_vl mms4,
         CST_COST_GROUPS csg
      WHERE   milk.organization_id(+) = msn.current_organization_id
      AND     milk.subinventory_code(+) = msn.current_subinventory_code
      AND     milk.inventory_location_id(+) = msn.current_locator_id
      AND     milk.status_id = mms2.status_id(+)
      AND     msn.inventory_item_id         = msik.inventory_item_id
      AND     msn.current_organization_id   = msik.organization_id
      AND     msn.current_subinventory_code = msub.secondary_inventory_name(+)
      AND     msn.current_organization_id = msub.organization_id(+)
      AND     msub.status_id = mms1.status_id(+)
      AND     msn.cost_group_id = csg.cost_group_id(+)
      AND     msn.lot_number = mlot.lot_number (+)
      AND     msn.current_organization_id = mlot.organization_id(+)
      AND     msn.inventory_item_id = mlot.inventory_item_id(+)
      AND     mlot.status_id = mms3.status_id(+)
      AND     msn.status_id = mms4.status_id(+)
      AND     msik.organization_id   = p_Organization_Id
      -- Bug 4301817 Not check mtl_transactions_enabled_flag to query non-transactable items
      -- AND     msik.mtl_transactions_enabled_flag = 'Y'
      AND     msn.serial_number =
                decode(p_Serial_Number, NULL, msn.serial_number, p_Serial_Number)
      AND     msn.inventory_item_id         = p_Inventory_Item_Id
      AND     nvl(msn.revision, '!@#$%^&') =
                decode(p_Revision, NULL, nvl(msn.revision, '!@#$%^&'), p_Revision)
      AND     nvl(msn.current_subinventory_code, '!@#$%^&') =
                decode(p_Subinventory_Code, NULL, nvl(msn.current_subinventory_code, '!@#$%^&'), p_Subinventory_Code)
      AND     nvl(msn.current_locator_id, 99999999) =
                decode(p_Locator_Id, NULL, nvl(msn.current_locator_id, 99999999), p_Locator_Id)
      AND     nvl(msn.cost_group_id, 99999999) =
                decode(p_cost_Group_id, NULL, nvl(msn.cost_group_id, 99999999), p_cost_group_id)
      AND     nvl(msn.lot_number, '!@#$%^&') =
                decode(p_Lot_Number, NULL, nvl(msn.lot_number, '!@#$%^&'), p_Lot_Number);

     x_status := 'C';
     x_message := 'Records found';
EXCEPTION
     when others then
        x_status := 'E';
        x_message := 'System error in select statement';
END WMS_LOOSE_SERIAL_INQUIRIES;


/****************************************************************************
         This procedure gets the contents for a given lpn
   30.1.2002. Changed by venjayar
         To account for the contents of the LPN in Packing Context also
         (as part of the bug 2091699)
   4.4.2002   Changed by venjayar
         To fetch project and task information also for Loaded LPN since
         Locator and Sub are fetched. (as part of bug 2314495)
****************************************************************************/

/* Changes for Bug #2810546
 * a) Removed outer join between MFG_LOOKUPS and WMS_LICENSE_PLATE_NUMBERS since
 *    an LPN will always have a context associated
 * b) Forked the code to fetch the dock door if the LPN context is "Loaded to Dock(9)"
 *    For this join between wms_license_plate_numbers, wms_shipping_transactions_temp
 *    and mtl_item_locations.
 * d) For other LPN contexts, we do not need dock door information. So removed the
 *    join with wms_shipping_transactions_temp and mtl_item_locations (milk2).
 * e) Use the cached values for PROJECT_NUMBER and TASK_NUMBER instead of fetching
 *    them using project_id and task_id
 */
PROCEDURE GET_LPN_CONTENTS(
   x_lpn_contents  OUT NOCOPY t_genref,
   p_parent_lpn_id IN  NUMBER)
IS
    l_count NUMBER;
    l_lpn_context_id NUMBER;
BEGIN

   SELECT lpn_context INTO l_lpn_context_id
      FROM wms_license_plate_numbers
      WHERE lpn_id = p_parent_lpn_id;

   /********************************************************************************
    * The formation of cursor is different when the LPN Context is Packing Context.
    * 1) If the LPN Context is Packing then the tables MTL_MATERIAL_TRANSACTIONS_TEMP
    *    and MTL_TRANSACTION_LOTS_TEMPare used to get the required information.
    * 2) For all other types of LPN Context WMS_LPN_CONTENTS is used.
    * Bug #4191414 - Modifications to showing the contents for packing context LPNs
    * The cursor is split in to two select statements
    *  1. The first SQL fetches the content information for not lot controlled items
    *     by fetching the data from MMTT
    *  2. The second SQL fetches the content information for each allocated lot
    *     by joining MMTT and MTLT
    *******************************************************************************/

   IF(l_lpn_context_id = 8) THEN
      --For non-lot controlled items
      OPEN x_lpn_contents FOR
         SELECT
            mmtt.content_lpn_id ,
            mmtt.transfer_lpn_id ,
            lpn.license_plate_number ,
            mlk.meaning ,
            mmtt.inventory_item_id ,
            msiv.concatenated_segments ,
            msiv.description,
            mmtt.organization_id ,
            mp.organization_code ,
            mmtt.revision,
            mmtt.subinventory_code ,
            mmtt.locator_id,
            INV_PROJECT.GET_LOCSEGS(mlc.inventory_location_id,mlc.organization_id) ,
            to_char(NULL) lot_number,
            to_char(NULL) serial_number,
            mmtt.transaction_quantity,
            mmtt.transaction_uom,
            nvl(mmtt.cost_group_id, 0),
            ccg.cost_group,
            lpn.outermost_lpn_id,
            lpn3.license_plate_number ,
            inv_item_inq.get_status_code(msub.status_id),
            inv_item_inq.get_status_code(milk.status_id),
            to_char(NULL),                   --Lot Status
            lpn.lpn_context,
            to_char(NULL),                   --Dock Door segs
            msiv.serial_number_control_code,
            INV_PROJECT.GET_PROJECT_NUMBER,  --Project Number
            INV_PROJECT.GET_TASK_NUMBER,     --Task Number
            to_char(NULL),                   --Source Name
            -- INVCONV start
            NVL(msiv.tracking_quantity_ind, 'P'),
            msiv.secondary_uom_code,
            NVL(mmtt.secondary_transaction_quantity, 0),
            -- INVCONV end
            --lpn status project start
           NVL(mmtt.lpn_id,mmtt.content_lpn_id)
            --lpn status project end
         FROM mtl_material_transactions_temp mmtt,
            wms_license_plate_numbers lpn,
            wms_license_plate_numbers lpn3,
            mtl_parameters mp,
            cst_cost_groups ccg,
            mtl_item_locations_kfv mlc ,
            mtl_secondary_inventories msub,
            mtl_item_locations_kfv milk,
            mtl_system_items_vl msiv, /* Bug 5581528 */
            mfg_lookups mlk
         WHERE mmtt.transfer_lpn_id = p_parent_lpn_id
            AND lpn.lpn_id = mmtt.transfer_lpn_id
            AND lpn.organization_id = mp.organization_id
            AND lpn.outermost_lpn_id = lpn3.lpn_id
            AND mmtt.cost_group_id = ccg.cost_group_id(+)
            AND mmtt.organization_id = mlc.organization_id(+)
            AND mmtt.locator_id = mlc.inventory_location_id(+)
            AND mmtt.organization_id = msub.organization_id(+)
            AND mmtt.subinventory_code = msub.secondary_inventory_name(+)
            AND mmtt.organization_id = milk.organization_id(+)
            AND mmtt.locator_id = milk.inventory_location_id(+)
            AND mmtt.subinventory_code = milk.subinventory_code(+)
            AND mmtt.organization_id  = msiv.organization_id
            AND mmtt.inventory_item_id = msiv.inventory_item_id
            AND mmtt.inventory_item_id is not null
            AND mlk.lookup_type = 'WMS_LPN_CONTEXT'
            AND mlk.lookup_code = lpn.lpn_context
            AND msiv.lot_control_code = 1
         UNION
         --For Lot controlled items
         SELECT
            mmtt.content_lpn_id ,
            mmtt.transfer_lpn_id ,
            lpn.license_plate_number ,
            mlk.meaning ,
            mmtt.inventory_item_id ,
            msiv.concatenated_segments ,
            msiv.description,
            mmtt.organization_id ,
            mp.organization_code ,
            mmtt.revision,
            mmtt.subinventory_code ,
            mmtt.locator_id,
            INV_PROJECT.GET_LOCSEGS(mlc.inventory_location_id, mlc.organization_id),
            mtlt.lot_number,
            to_char(NULL) serial_number,
            mtLt.transaction_quantity,       --Get qty for each lot
            mmtt.transaction_uom,
            nvl(mmtt.cost_group_id, 0),
            ccg.cost_group,
            lpn.outermost_lpn_id, lpn3.license_plate_number ,
            inv_item_inq.get_status_code(msub.status_id),
            inv_item_inq.get_status_code(milk.status_id),
            inv_item_inq.get_status_code(mln.status_id),
            lpn.lpn_context,
            to_char(NULL),                   --Dock Door segs
            msiv.serial_number_control_code,
            TO_CHAR(NULL),                   --Project Number
            TO_CHAR(NULL),                   --Task Number
            to_char(NULL),                   --Source Name
            -- INVCONV start
            NVL(msiv.tracking_quantity_ind, 'P'),
            msiv.secondary_uom_code,
            NVL(mmtt.secondary_transaction_quantity, 0),
            -- INVCONV end
            --lpn status project
            NVL(mmtt.lpn_id,mmtt.content_lpn_id)
            --lpn status project end

         FROM mtl_material_transactions_temp mmtt,
            mtl_transaction_lots_temp mtlt,
            wms_license_plate_numbers lpn,
            wms_license_plate_numbers lpn3,
            mtl_parameters mp,
            cst_cost_groups ccg,
            mtl_item_locations_kfv mlc ,
            mtl_secondary_inventories msub,
            mtl_item_locations_kfv milk,
            mtl_lot_numbers mln,
            mtl_system_items_vl msiv, /* Bug 5581528 */
            mfg_lookups mlk
         WHERE mmtt.transfer_lpn_id = p_parent_lpn_id
            AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
            AND lpn.lpn_id = mmtt.transfer_lpn_id
            AND lpn.organization_id = mp.organization_id
            AND lpn.outermost_lpn_id = lpn3.lpn_id
            AND mmtt.cost_group_id = ccg.cost_group_id(+)
            AND mmtt.organization_id = mlc.organization_id(+)
            AND mmtt.locator_id = mlc.inventory_location_id(+)
            AND mmtt.organization_id = msub.organization_id(+)
            AND mmtt.subinventory_code = msub.secondary_inventory_name(+)
            AND mmtt.organization_id = milk.organization_id(+)
            AND mmtt.locator_id = milk.inventory_location_id(+)
            AND mmtt.subinventory_code = milk.subinventory_code(+)
            AND mmtt.organization_id = mln.organization_id(+)
            AND mmtt.inventory_item_id = mln.inventory_item_id(+)
            AND mmtt.lot_number = mln.lot_number(+)
            AND mmtt.organization_id  = msiv.organization_id
            AND mmtt.inventory_item_id = msiv.inventory_item_id
            AND mmtt.inventory_item_id is not null
            AND mlk.lookup_type = 'WMS_LPN_CONTEXT'
            AND mlk.lookup_code = lpn.lpn_context
            AND msiv.lot_control_code > 1;

   /* LPN Context = "Loaded to Dock" - fetch the dock door information */
   ELSIF (l_lpn_context_id = 9) THEN
      OPEN x_lpn_contents FOR
         SELECT
            wlc.lpn_content_id , wlc.parent_lpn_id , lpn.license_plate_number ,
            mlk.meaning,
            wlc.inventory_item_id, msiv.concatenated_segments, msiv.description,
            wlc.organization_id , mp.organization_code ,
            wlc.revision,
            lpn.subinventory_code ,
            lpn.locator_id, INV_PROJECT.GET_LOCSEGS(mlc.inventory_location_id,mlc.organization_id) ,
            wlc.lot_number, wlc.serial_number,
            wlc.quantity, wlc.uom_code,
            nvl(wlc.cost_group_id, 0), ccg.cost_group,
            lpn.outermost_lpn_id, lpn3.license_plate_number ,
            inv_item_inq.get_status_code(msub.status_id) ,
            inv_item_inq.get_status_code(milk.status_id) ,
            inv_item_inq.get_status_code(mln.status_id) ,
            lpn.lpn_context,
            INV_PROJECT.GET_LOCSEGS(milk2.inventory_location_id, milk2.organization_id) ,
            msiv.serial_number_control_code,
            INV_PROJECT.GET_PROJECT_NUMBER(mlc.project_id),
            INV_PROJECT.GET_TASK_NUMBER(mlc.task_id),
            wlc.source_name,
            -- INVCONV start
            NVL(msiv.tracking_quantity_ind, 'P'),
            msiv.secondary_uom_code,
            NVL(wlc.secondary_quantity, 0),
            -- INVCONV end
            --lpn status project
            wlc.parent_lpn_id
            --lpn status project end

         FROM
            wms_lpn_contents wlc,
            wms_license_plate_numbers lpn,
            wms_license_plate_numbers lpn3,
            mtl_parameters mp,
            cst_cost_groups ccg,
            mtl_item_locations mlc ,
            mtl_secondary_inventories msub,
            mtl_item_locations milk,
            mtl_item_locations milk2,
            mtl_lot_numbers mln,
            mtl_system_items_vl msiv, /* Bug 5581528 */
            mfg_lookups mlk,
            wms_shipping_transaction_temp wstt
         WHERE wlc.parent_lpn_id = p_parent_lpn_id
            AND lpn.lpn_id = wlc.parent_lpn_id
            AND lpn.organization_id = mp.organization_id
            AND lpn.outermost_lpn_id = lpn3.lpn_id
            AND wlc.cost_group_id = ccg.cost_group_id(+)
            AND lpn.organization_id = mlc.organization_id(+)
            AND lpn.locator_id = mlc.inventory_location_id(+)
            AND lpn.organization_id = msub.organization_id(+)
            AND lpn.subinventory_code = msub.secondary_inventory_name(+)
            AND lpn.organization_id = milk.organization_id(+)
            AND lpn.locator_id = milk.inventory_location_id(+)
            AND lpn.subinventory_code = milk.subinventory_code(+)
            AND wlc.organization_id = mln.organization_id(+)
            AND wlc.inventory_item_id = mln.inventory_item_id(+)
            AND wlc.lot_number = mln.lot_number(+)
            AND lpn.organization_id  = msiv.organization_id
            AND wlc.inventory_item_id = msiv.inventory_item_id
            AND wlc.inventory_item_id is not null
            AND mlk.lookup_type = 'WMS_LPN_CONTEXT'
            AND mlk.lookup_code = lpn.lpn_context
            AND lpn.lpn_id = wstt.parent_lpn_id (+)
            AND wstt.dock_door_id = milk2.inventory_location_id (+)
            AND milk2.inventory_location_type(+) = 1

         UNION ALL

         SELECT
            wlc.lpn_content_id , wlc.parent_lpn_id , lpn.license_plate_number ,
            mlk.meaning,
            0, null, wlc.item_description,
            wlc.organization_id , mp.organization_code ,
            wlc.revision,
            lpn.subinventory_code ,
            lpn.locator_id, INV_PROJECT.GET_LOCSEGS(mlc.inventory_location_id, mlc.organization_id),
            null, null,
            wlc.quantity, wlc.uom_code,
            nvl(wlc.cost_group_id, 0), ccg.cost_group,
            lpn.outermost_lpn_id, lpn3.license_plate_number ,
            null, null, null,
            lpn.lpn_context,
            INV_PROJECT.GET_LOCSEGS(milk2.inventory_location_id, milk2.organization_id),
            0,
            INV_PROJECT.GET_PROJECT_NUMBER(mlc.project_id),
            INV_PROJECT.GET_TASK_NUMBER(mlc.task_id),
            wlc.source_name,
            -- INVCONV start
            'P',
            NULL,
            NVL(wlc.secondary_quantity, 0) ,
            -- INVCONV end
            --lpn status project start
            wlc.parent_lpn_id
            --lpn status project end
         FROM wms_lpn_contents wlc,
            wms_license_plate_numbers lpn,
            mtl_parameters mp,
            wms_license_plate_numbers lpn3,
            cst_cost_groups ccg,
            mtl_item_locations_kfv mlc ,
            mtl_secondary_inventories msub,
            mtl_item_locations_kfv milk,
            mfg_lookups mlk,
            wms_shipping_transaction_temp wstt,
            mtl_item_locations_kfv milk2
         WHERE wlc.parent_lpn_id = p_parent_lpn_id
            AND lpn.lpn_id = wlc.parent_lpn_id
            AND lpn.organization_id = mp.organization_id
            AND lpn.outermost_lpn_id = lpn3.lpn_id
            AND wlc.cost_group_id = ccg.cost_group_id(+)
            AND lpn.organization_id = mlc.organization_id(+)
            AND lpn.locator_id = mlc.inventory_location_id(+)
            AND lpn.organization_id = msub.organization_id(+)
            AND lpn.subinventory_code = msub.secondary_inventory_name(+)
            AND lpn.organization_id = milk.organization_id(+)
            AND lpn.locator_id = milk.inventory_location_id(+)
            AND lpn.subinventory_code = milk.subinventory_code(+)
            AND wlc.inventory_item_id is null
            AND mlk.lookup_type = 'WMS_LPN_CONTEXT'
            AND mlk.lookup_code = lpn.lpn_context
            AND lpn.lpn_id = wstt.parent_lpn_id (+)
            AND wstt.dock_door_id = milk2.inventory_location_id (+)
            AND milk2.inventory_location_type(+) = 1;
   ELSE
      /*       All other Contexts      */
      OPEN x_lpn_contents FOR
         -- Release 12 (K)
         -- WLC can have multiple records for same item, but different UOMs
         -- However, available quantity is not calculated for each UOM
         -- LPN content can not show seperate record for different UOM
         -- Changed the following cursor to not to group by WLC.UOM
         -- Instead, summarize the WLC records for each item/rev/lot across UOMs
         -- and return primary quantity and primary UOM
         SELECT
	 /* 3372973 : 0 is selected instead of wlc.lpn_content_id because it is not used and moreover it is part
                              of 'group by'. */
            0, wwlc.parent_lpn_id ,
	    lpn.license_plate_number ,
            mlk.meaning,
            wwlc.inventory_item_id, msiv.concatenated_segments, msiv.description,
            wwlc.organization_id , mp.organization_code ,
            wwlc.revision,
            lpn.subinventory_code ,
            lpn.locator_id,
            INV_PROJECT.GET_LOCSEGS(mlc.inventory_location_id,mlc.organization_id) ,
	    wwlc.lot_number, wwlc.serial_number,
            -- Release 12: change to sum of primary quantity
            -- and select primary uom
            -- sum(wlc.quantity), wlc.uom_code,  /* 3372973 : Sum of quantity is taken as wlc is grouped */
            wwlc.primary_quantity,
            msiv.primary_uom_code,
            nvl(wwlc.cost_group_id, 0), ccg.cost_group,
            lpn.outermost_lpn_id, lpn3.license_plate_number ,
            inv_item_inq.get_status_code(msub.status_id) ,
            inv_item_inq.get_status_code(milk.status_id) ,
            inv_item_inq.get_status_code(mln.status_id) ,
            lpn.lpn_context,
            NULL,  --dock door
            msiv.serial_number_control_code,
            INV_PROJECT.GET_PROJECT_NUMBER,  --project number
            INV_PROJECT.GET_TASK_NUMBER,  --task number
            wwlc.source_name,
            -- INVCONV start
            NVL(msiv.tracking_quantity_ind, 'P'),
            msiv.secondary_uom_code,
            wwlc.secondary_quantity ,
            -- INVCONV end
            --lpn status project start
            wwlc.parent_lpn_id
            --lpn status project end
         FROM
            --Bug 4951729 Included a subquery which selects from wlc for perfomance improvement
	    (SELECT  wlc.parent_lpn_id parent_lpn_id,
wlc.inventory_item_id inventory_item_id,
wlc.organization_id  organization_id,
wlc.revision revision,
wlc.lot_number lot_number,
wlc.serial_number serial_number,
sum(wlc.primary_quantity) primary_quantity ,
nvl(wlc.cost_group_id, 0) cost_group_id,
wlc.source_name source_name,
sum(wlc.secondary_quantity) secondary_quantity
FROM
wms_lpn_contents wlc

WHERE
wlc.parent_lpn_id = p_parent_lpn_id


GROUP BY
wlc.parent_lpn_id ,
wlc.inventory_item_id,
wlc.organization_id ,
 wlc.revision,
wlc.lot_number,
wlc.serial_number,
nvl(wlc.cost_group_id, 0),
wlc.source_name
) wwlc,
            wms_license_plate_numbers lpn,
            wms_license_plate_numbers lpn3,
            mtl_parameters mp,
            cst_cost_groups ccg,
            mtl_item_locations mlc ,
            mtl_secondary_inventories msub,
            mtl_item_locations milk,
            mtl_lot_numbers mln,
            mtl_system_items_vl msiv, /* Bug 5581528 */
            mfg_lookups mlk
         WHERE
             lpn.lpn_id = wwlc.parent_lpn_id
            AND lpn.organization_id = mp.organization_id
            AND lpn.outermost_lpn_id = lpn3.lpn_id
            AND wwlc.cost_group_id = ccg.cost_group_id(+)
            AND lpn.organization_id = mlc.organization_id(+)
            AND lpn.locator_id = mlc.inventory_location_id(+)
            AND lpn.organization_id = msub.organization_id(+)
            AND lpn.subinventory_code = msub.secondary_inventory_name(+)
            AND lpn.organization_id = milk.organization_id(+)
            AND lpn.locator_id = milk.inventory_location_id(+)
            AND lpn.subinventory_code = milk.subinventory_code(+)
            AND wwlc.organization_id = mln.organization_id(+)
            AND wwlc.inventory_item_id = mln.inventory_item_id(+)
            AND wwlc.lot_number = mln.lot_number(+)
            AND lpn.organization_id  = msiv.organization_id
            AND wwlc.inventory_item_id = msiv.inventory_item_id
            AND wwlc.inventory_item_id is not null
            AND mlk.lookup_type = 'WMS_LPN_CONTEXT'
            AND mlk.lookup_code = lpn.lpn_context
         /* 3372973: Grouping has to be done because there can be multiple wlc records with same column values (except qty).
                     This can happen, for example, in Direct Org transfer of an LPN with Lot Controlled item (2 lots packed)
                     from a Source Org where the Item is Lot controlled to Dest Org where the Item is not Lot-controlled.
                     After the transfer, Org of the LPN is changed to Dest Org and 'Lot Number' is simply nulled out
                     in wlc records, which leaves multiple records in wlc with same column values.
                     Earlier in Source Org before Direct Org transfer, qty and 'Lot Number' would be having
                     different values (2 different lots packed) to make different wlc records. */

 --Bug 4951729 We need to have group by only on wlc hence included a subquery for the same and commented out
   --  group by clause .


	 /*GROUP BY
            0, wlc.parent_lpn_id , lpn.license_plate_number ,
            mlk.meaning,
            wlc.inventory_item_id, msiv.concatenated_segments, msiv.description,
            wlc.organization_id , mp.organization_code ,
            wlc.revision,
            lpn.subinventory_code ,
            lpn.locator_id,
            INV_PROJECT.GET_LOCSEGS(mlc.inventory_location_id,mlc.organization_id) ,
            wlc.lot_number, wlc.serial_number,
            --Release 12(K), group by primary UOM
            --wlc.uom_code,
            msiv.primary_uom_code,
            nvl(wlc.cost_group_id, 0), ccg.cost_group,
            lpn.outermost_lpn_id, lpn3.license_plate_number ,
            inv_item_inq.get_status_code(msub.status_id) ,
            inv_item_inq.get_status_code(milk.status_id) ,
            inv_item_inq.get_status_code(mln.status_id) ,
            lpn.lpn_context,
            NULL,  --dock door
            msiv.serial_number_control_code,
            INV_PROJECT.GET_PROJECT_NUMBER,  --project number
            INV_PROJECT.GET_TASK_NUMBER,  --task number
            wlc.source_name,
            -- INVCONV start
            NVL(msiv.tracking_quantity_ind, 'P'),
            msiv.secondary_uom_code
            -- INVCONV end*/

         UNION ALL

         SELECT
            wlc.lpn_content_id , wlc.parent_lpn_id , lpn.license_plate_number ,
            mlk.meaning,
            0, null, wlc.item_description,
            wlc.organization_id , mp.organization_code ,
            wlc.revision,
            lpn.subinventory_code ,
            lpn.locator_id,
            INV_PROJECT.GET_LOCSEGS(mlc.inventory_location_id, mlc.organization_id),
            null, null,
            wlc.quantity, wlc.uom_code,
            nvl(wlc.cost_group_id, 0), ccg.cost_group,
            lpn.outermost_lpn_id, lpn3.license_plate_number ,
            null, null, null,
            lpn.lpn_context,
            NULL, --dock door
            0,
            INV_PROJECT.GET_PROJECT_NUMBER,  --project number
            INV_PROJECT.GET_TASK_NUMBER,  --task number
            wlc.source_name,
            -- INVCONV start
            'P',
            NULL,
            NVL(wlc.secondary_quantity, 0),
            -- INVCONV end
            --lpn status project start
            wlc.parent_lpn_id
            --lpn status project end

         FROM wms_lpn_contents wlc,
            wms_license_plate_numbers lpn,
            mtl_parameters mp,
            wms_license_plate_numbers lpn3,
            cst_cost_groups ccg,
            mtl_item_locations_kfv mlc ,
            mtl_secondary_inventories msub,
            mtl_item_locations_kfv milk,
            mfg_lookups mlk
         WHERE wlc.parent_lpn_id = p_parent_lpn_id
            AND lpn.lpn_id = wlc.parent_lpn_id
            AND lpn.organization_id = mp.organization_id
            AND lpn.outermost_lpn_id = lpn3.lpn_id
            AND wlc.cost_group_id = ccg.cost_group_id(+)
            AND lpn.organization_id = mlc.organization_id(+)
            AND lpn.locator_id = mlc.inventory_location_id(+)
            AND lpn.organization_id = msub.organization_id(+)
            AND lpn.subinventory_code = msub.secondary_inventory_name(+)
            AND lpn.organization_id = milk.organization_id(+)
            AND lpn.locator_id = milk.inventory_location_id(+)
            AND lpn.subinventory_code = milk.subinventory_code(+)
            AND wlc.inventory_item_id is null
            AND mlk.lookup_type = 'WMS_LPN_CONTEXT'
            AND mlk.lookup_code = lpn.lpn_context;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      null;
END GET_LPN_CONTENTS;


-----------------------------------------------------
-- THis procedure is to find the lpn for a given item
-----------------------------------------------------
PROCEDURE GET_LPN_FOR_ITEM(
   x_lpn_for_item    OUT NOCOPY t_genref
,  p_organization_id IN  NUMBER
,  p_inventory_item_id  IN  NUMBER
,  p_subinventory_code  IN  VARCHAR2
,  p_locator_id      IN  NUMBER
,  p_lot_number      IN  VARCHAR2
,  p_serial_number      IN  VARCHAR2
,  p_revision     IN  VARCHAR2
,  p_cost_group_id      IN  NUMBER
   ) IS


BEGIN
   OPEN x_lpn_for_item FOR
      SELECT wlc.lpn_content_id
      , wlc.parent_lpn_id
      , lpn.license_plate_number
      , mlk.meaning
      , wlc.inventory_item_id
      , msiv.concatenated_segments
      , msiv.description
      , wlc.organization_id
      , mp.organization_code
      , wlc.revision
      , lpn.subinventory_code
      , lpn.locator_id
      --, mlc.concatenated_segments
      , INV_PROJECT.GET_LOCSEGS(lpn.locator_id, lpn.organization_id) concatenated_segments
      , wlc.lot_number
      , wlc.serial_number
      , wlc.quantity
      , wlc.uom_code
      , nvl(wlc.cost_group_id, 0)
      , ccg.cost_group
      , lpn.outermost_lpn_id
      , lpn3.license_plate_number
      , inv_item_inq.get_status_code(msub.status_id)
      , inv_item_inq.get_status_code(mlc.status_id)
      , inv_item_inq.get_status_code(mln.status_id)
      , lpn.gross_weight
      , lpn.gross_weight_uom_code
      , lpn.content_volume
      , lpn.content_volume_uom_code
      , msiv.serial_number_control_code
      , INV_PROJECT.GET_PROJECT_NUMBER project_number
      , INV_PROJECT.GET_TASK_NUMBER task_number
      , wlc.source_name
      -- INVCONV start
      , NVL(msiv.tracking_quantity_ind, 'P')
      , nvl(wlc.secondary_quantity, 0)
      , msiv.secondary_uom_code
      -- INVCONV end
      FROM WMS_LPN_CONTENTS wlc
           , WMS_LICENSE_PLATE_NUMBERS lpn
           , mtl_system_items_vl msiv -- Modified for Bug # 5472330
           , mtl_parameters mp
       , wms_license_plate_numbers lpn3
           , cst_cost_groups ccg
       , mtl_item_locations mlc
           , mtl_secondary_inventories msub
           , mtl_lot_numbers mln
           , mfg_lookups mlk

       WHERE lpn.organization_id = p_organization_id
       AND  wlc.inventory_item_id = p_inventory_item_id
       AND lpn.lpn_id = wlc.parent_lpn_id
       AND lpn.organization_id = mp.organization_id
       AND lpn.subinventory_code = p_subinventory_code
       AND nvl(lpn.locator_id, 9999)  = nvl(p_locator_id, 9999)
       AND nvl(wlc.lot_number, '@@@') = nvl(p_lot_number, '@@@')

/** Bug 2392768  **/
       --AND nvl(wlc.serial_number, '@@@') = nvl(p_serial_number, '@@@')

       AND nvl(wlc.revision, '@@@') = nvl(p_revision, '@@@')
       /* Bug 4731897 Modified the comparision of the cost group condition
          It is possible that for serial controlled item delivered from inbound,
          WLC.cost_group_id is NULL but MSN.cost_group_id is not null
          changed the where clause to match with p_cost_group_id with WLC.cost_group_id
          OR match p_cost_group_id with MSN.cost_group_id
       AND nvl(wlc.cost_group_id, 9999) = nvl(p_cost_group_id, 9999) */
       AND ((p_cost_group_id IS NULL) OR
            (wlc.cost_group_id = p_cost_group_id) OR
            ( ( wlc.cost_group_id IS NULL OR wlc.cost_group_id <> p_cost_group_id )AND msiv.serial_number_control_code in (2,5) AND exists
                (select 1 from mtl_serial_numbers msn
                 where msn.lpn_id = wlc.parent_lpn_id
                 and msn.cost_group_id = p_cost_group_id
                )
            )
           ) -- Bug 4731897
       --AND nvl(wlc.cost_group_id, nvl(p_cost_group_id, 9999) )= nvl(p_cost_group_id, 9999)--Bug 4731897
       -- Bug 4928751
       AND (p_serial_number IS NULL OR EXISTS (SELECT 1 FROM mtl_serial_numbers msn
                                                WHERE msn.serial_number=p_serial_number
                                                AND msn.current_organization_id=p_organization_id
                                                AND msn.lpn_id=wlc.parent_lpn_id
                                                AND msn.inventory_item_id=p_inventory_item_id ) )
       AND lpn.outermost_lpn_id = lpn3.lpn_id
       AND wlc.cost_group_id = ccg.cost_group_id(+)
       AND lpn.organization_id = mlc.organization_id(+)
       AND lpn.locator_id = mlc.inventory_location_id(+)
       and lpn.organization_id = msub.organization_id(+)
       and lpn.subinventory_code = msub.secondary_inventory_name(+)
       and wlc.organization_id = mln.organization_id(+)
       and wlc.inventory_item_id = mln.inventory_item_id(+)
       and wlc.lot_number = mln.lot_number(+)
       and lpn.organization_id = msiv.organization_id
       and wlc.inventory_item_id = msiv.inventory_item_id

       and mlk.lookup_type = 'WMS_LPN_CONTEXT'
       and mlk.lookup_code = lpn.lpn_context(+)
                 and not exists (select wlpn.lpn_id
                                 from   wms_license_plate_numbers wlpn,
                                        mtl_material_transactions_temp t,
                                        wms_dispatched_tasks w
                                 where  w.status = 4
                                 and    w.task_type <> 2
                                 and    w.transaction_temp_id = t.transaction_temp_id
                                 and    wlpn.lpn_id = lpn.lpn_id
                                 and    (t.content_lpn_id = wlpn.lpn_id)); -- #Bug 4892698
               -- or t.lpn_id = wlpn.lpn_id)); -- Line commented out for #Bug 4892698
EXCEPTION
    when FND_API.G_EXC_UNEXPECTED_ERROR then
   null;

END GET_LPN_FOR_ITEM;

FUNCTION GET_PACKED_QUANTITY(p_organization_id IN NUMBER,
         p_inventory_item_id IN NUMBER,
         p_revision IN VARCHAR2,
         p_subinventory_code IN VARCHAR2,
         p_locator_id       IN NUMBER,
         p_lot_number       IN VARCHAR2,
              p_cost_Group     IN NUMBER) RETURN NUMBER IS
   l_packed_quantity NUMBER;
BEGIN
   select sum(quantity)
   into l_packed_quantity
   from wms_onhand_and_loaded_qty_v
   where organization_id = p_organization_id
   and   inventory_item_id = decode(p_inventory_item_id, NULL, inventory_item_id, p_inventory_item_id)
   AND   nvl(revision, '$@#$%') = decode(p_revision, NULL, nvl(revision,'$@#$%'),  p_revision)
   AND   nvl(lot_number, '$@#$%') = decode(p_lot_number, NULL, nvl(lot_number, '$@#$%'), p_lot_number)
   AND   nvl(subinventory_code, '$@#$%') =
      decode(p_subinventory_code, NULL, nvl(subinventory_code, '$@#$%'), p_subinventory_code)
   AND   nvl(locator_id, 0) = decode(p_locator_id, NULL, nvl(locator_id, 0), p_locator_id)
   AND   nvl(cost_group_id, 0) = decode(p_cost_group, NULL, nvl(cost_group_id, 0), p_cost_group)
   AND   nvl(containerized_flag, 2) = 1;
-- group by moq.organization_id, moq.inventory_item_id, moq.revision, moq.subinventory_code,
--       moq.locator_id, moq.cost_group_id, moq.lot_number, moq.cost_group_id, moq.containerized_flag;
   return l_packed_quantity;
end;

FUNCTION GET_LOOSE_QUANTITY(p_organization_id IN NUMBER,
                        p_inventory_item_id IN NUMBER,
                        p_revision IN VARCHAR2,
                        p_subinventory_code IN VARCHAR2,
                        p_locator_id        IN NUMBER,
                        p_lot_number        IN VARCHAR2,
                        p_cost_Group        IN NUMBER) RETURN NUMBER IS
   l_loose_quantity NUMBER;
BEGIN
   select sum(quantity)
   into l_loose_quantity
   from wms_onhand_and_loaded_qty_v
   where organization_id = p_organization_id
   and   inventory_item_id = decode(p_inventory_item_id, NULL, inventory_item_id, p_inventory_item_id)
   AND   nvl(revision, '$@#$%') = decode(p_revision, NULL, nvl(revision,'$@#$%'),  p_revision)
   AND   nvl(lot_number, '$@#$%') = decode(p_lot_number, NULL, nvl(lot_number, '$@#$%'), p_lot_number)
   AND   nvl(subinventory_code, '$@#$%') =
      decode(p_subinventory_code, NULL, nvl(subinventory_code, '$@#$%'), p_subinventory_code)
   AND   nvl(locator_id, 0) = decode(p_locator_id, NULL, nvl(locator_id, 0), p_locator_id)
   AND   nvl(cost_group_id, 0) = decode(p_cost_group, NULL, nvl(cost_group_id, 0), p_cost_group)
        AND   nvl(containerized_flag, 2) = 2;
        --group by moq.organization_id, moq.inventory_item_id, moq.revision, moq.subinventory_code,
        --     moq.locator_id, moq.cost_group_id, moq.lot_number, moq.cost_group_id, moq.containerized_flag;
        return l_loose_quantity;
end;

-- INVCONV start

PROCEDURE  GET_PACKED_QTY(p_organization_id IN NUMBER,
         p_inventory_item_id IN NUMBER,
         p_revision IN VARCHAR2,
         p_subinventory_code IN VARCHAR2,
         p_locator_id       IN NUMBER,
         p_lot_number       IN VARCHAR2,
         p_cost_Group     IN NUMBER,
         x_packed_qty       OUT NOCOPY NUMBER,
         x_sec_packed_qty       OUT NOCOPY NUMBER) IS

BEGIN
   select sum(quantity),
          sum(secondary_transaction_quantity)
   into x_packed_qty,
        x_sec_packed_qty
   from wms_onhand_and_loaded_qty_v
   where organization_id = p_organization_id
   and   inventory_item_id = decode(p_inventory_item_id, NULL, inventory_item_id, p_inventory_item_id)
   AND   nvl(revision, '$@#$%') = decode(p_revision, NULL, nvl(revision,'$@#$%'),  p_revision)
   AND   nvl(lot_number, '$@#$%') = decode(p_lot_number, NULL, nvl(lot_number, '$@#$%'), p_lot_number)
   AND   nvl(subinventory_code, '$@#$%') =
      decode(p_subinventory_code, NULL, nvl(subinventory_code, '$@#$%'), p_subinventory_code)
   AND   nvl(locator_id, 0) = decode(p_locator_id, NULL, nvl(locator_id, 0), p_locator_id)
   AND   nvl(cost_group_id, 0) = decode(p_cost_group, NULL, nvl(cost_group_id, 0), p_cost_group)
   AND   nvl(containerized_flag, 2) = 1;
-- group by moq.organization_id, moq.inventory_item_id, moq.revision, moq.subinventory_code,
--       moq.locator_id, moq.cost_group_id, moq.lot_number, moq.cost_group_id, moq.containerized_flag;
END GET_PACKED_QTY;

PROCEDURE GET_LOOSE_QTY(p_organization_id IN NUMBER,
                        p_inventory_item_id IN NUMBER,
                        p_revision IN VARCHAR2,
                        p_subinventory_code IN VARCHAR2,
                        p_locator_id        IN NUMBER,
                        p_lot_number        IN VARCHAR2,
                        p_cost_Group        IN NUMBER,
                        x_loose_qty       OUT NOCOPY NUMBER,
                        x_sec_loose_qty       OUT NOCOPY NUMBER) IS

BEGIN
   select sum(quantity),
          sum(secondary_transaction_quantity)
   into x_loose_qty,
        x_sec_loose_qty
   from wms_onhand_and_loaded_qty_v
   where organization_id = p_organization_id
   and   inventory_item_id = decode(p_inventory_item_id, NULL, inventory_item_id, p_inventory_item_id)
   AND   nvl(revision, '$@#$%') = decode(p_revision, NULL, nvl(revision,'$@#$%'),  p_revision)
   AND   nvl(lot_number, '$@#$%') = decode(p_lot_number, NULL, nvl(lot_number, '$@#$%'), p_lot_number)
   AND   nvl(subinventory_code, '$@#$%') =
      decode(p_subinventory_code, NULL, nvl(subinventory_code, '$@#$%'), p_subinventory_code)
   AND   nvl(locator_id, 0) = decode(p_locator_id, NULL, nvl(locator_id, 0), p_locator_id)
   AND   nvl(cost_group_id, 0) = decode(p_cost_group, NULL, nvl(cost_group_id, 0), p_cost_group)
        AND   nvl(containerized_flag, 2) = 2;
        --group by moq.organization_id, moq.inventory_item_id, moq.revision, moq.subinventory_code,
        --     moq.locator_id, moq.cost_group_id, moq.lot_number, moq.cost_group_id, moq.containerized_flag;
END GET_LOOSE_QTY;

PROCEDURE  GET_PACKED_LOOSE_QTY(p_organization_id IN NUMBER,
         p_inventory_item_id IN NUMBER,
         p_revision IN VARCHAR2,
         p_subinventory_code IN VARCHAR2,
         p_locator_id       IN NUMBER,
         p_lot_number       IN VARCHAR2,
         p_cost_Group     IN NUMBER,
         x_packed_qty       OUT NOCOPY NUMBER,
         x_loose_qty       OUT NOCOPY NUMBER,
         x_sec_packed_qty       OUT NOCOPY NUMBER,
         x_sec_loose_qty       OUT NOCOPY NUMBER) IS

BEGIN

   GET_PACKED_QTY(p_organization_id => p_organization_id,
         p_inventory_item_id => p_inventory_item_id ,
         p_revision          => p_revision,
         p_subinventory_code => p_subinventory_code,
         p_locator_id        => p_locator_id,
         p_lot_number        => p_lot_number,
         p_cost_Group        => p_cost_Group,
         x_packed_qty        => x_packed_qty,
         x_sec_packed_qty    => x_sec_packed_qty);


   GET_LOOSE_QTY(p_organization_id => p_organization_id,
         p_inventory_item_id => p_inventory_item_id ,
         p_revision          => p_revision,
         p_subinventory_code => p_subinventory_code,
         p_locator_id        => p_locator_id,
         p_lot_number        => p_lot_number,
         p_cost_Group        => p_cost_Group,
         x_loose_qty        => x_loose_qty,
         x_sec_loose_qty    => x_sec_loose_qty);

END GET_PACKED_LOOSE_QTY;

PROCEDURE GET_AVAILABLE_QTIES (p_organization_id     IN NUMBER,
                                p_inventory_item_id   IN NUMBER,
                                p_revision            IN VARCHAR2,
                                p_subinventory_code   IN VARCHAR2,
                                p_locator_id          IN NUMBER,
                                p_lot_number          IN VARCHAR2,
                                p_cost_group_id       IN NUMBER,
                                p_revision_control IN VARCHAR2,
                                p_lot_control      IN VARCHAR2,
                                p_serial_control   IN VARCHAR2,
                                x_available_qty    OUT NOCOPY NUMBER,
                                x_sec_available_qty OUT NOCOPY NUMBER) IS

   l_is_revision_control BOOLEAN := FALSE;
   l_is_lot_control BOOLEAN := FALSE;
   l_is_serial_control BOOLEAN := FALSE;

   l_return_status VARCHAR2(1);
   l_msg_count     NUMBER(10);
   l_msg_data      VARCHAR2(1000);
   l_qoh           NUMBER;
   l_rqoh          NUMBER;
   l_qr            NUMBER;
   l_qs            NUMBER;
   l_atr           NUMBER;
   l_sqoh           NUMBER;
   l_srqoh          NUMBER;
   l_sqr            NUMBER;
   l_sqs            NUMBER;
   l_satr           NUMBER;

   l_locator_id number;
   l_cost_group_id number;
BEGIN


-- Clearing the quantity cache
   inv_quantity_tree_pub.clear_quantity_cache;


   if upper(p_revision_control) = 'TRUE' then
      l_is_revision_control := TRUE;
   end if;
   if upper(p_lot_control) = 'TRUE' then
      l_is_lot_control := TRUE;
   end if;
   if upper(p_serial_control) = 'TRUE' then
      l_is_serial_control := TRUE;
   end if;

   if p_locator_id <= 0 then
      l_locator_id := null;
   else
      l_locator_id := p_locator_id;
   end if;

   if p_cost_group_id <= 0 then
      l_cost_group_id := null;
   else
      l_cost_group_id := p_cost_group_id;
   end if;

   Inv_Quantity_Tree_Pub.Query_Quantities (
                p_api_version_number => 1.0,
                p_init_msg_lst       => fnd_api.g_false,
                x_return_status      => l_return_status,
                x_msg_count          => l_msg_count,
                x_msg_data           => l_msg_data,
                p_organization_id    => p_organization_id,
                p_inventory_item_id  => p_inventory_item_id,
                p_tree_mode          => INV_Quantity_Tree_PUB.g_transaction_mode,
                p_is_revision_control => l_is_revision_control,
                p_is_lot_control     => l_is_lot_control,
                p_is_serial_control  => l_is_serial_control,
                p_grade_code         => NULL,
                p_revision           => p_revision,
                p_lot_number         => p_lot_number,
                p_subinventory_code  => p_subinventory_code,
                p_locator_id         => l_locator_id,
                p_cost_group_id      => l_cost_group_id,
                x_qoh                => l_qoh,
                x_rqoh               => l_rqoh,
                x_qr                 => l_qr,
                x_qs                 => l_qs,
                x_att                => x_available_qty,
                x_atr                => l_atr,
                x_sqoh               => l_sqoh,
                x_srqoh              => l_srqoh,
                x_sqr                => l_sqr,
                x_sqs                => l_sqs,
                x_satt               => x_sec_available_qty,
                x_satr               => l_satr);


END GET_AVAILABLE_QTIES;
-- INVCONV end

FUNCTION GET_AVAILABLE_QTY (p_organization_id     IN NUMBER,
                                p_inventory_item_id   IN NUMBER,
                                p_revision            IN VARCHAR2,
                                p_subinventory_code   IN VARCHAR2,
                                p_locator_id          IN NUMBER,
                                p_lot_number          IN VARCHAR2,
                                p_cost_group_id       IN NUMBER,
                                p_revision_control IN VARCHAR2,
                                p_lot_control      IN VARCHAR2,
                                p_serial_control   IN VARCHAR2)
                                RETURN NUMBER IS

   l_is_revision_control BOOLEAN := FALSE;
   l_is_lot_control BOOLEAN := FALSE;
   l_is_serial_control BOOLEAN := FALSE;

   l_return_status VARCHAR2(1);
   l_msg_count     NUMBER(10);
   l_msg_data      VARCHAR2(1000);
   l_qoh           NUMBER;
   l_rqoh          NUMBER;
   l_qr            NUMBER;
   l_qs            NUMBER;
   l_att           NUMBER;
   l_atr           NUMBER;

   l_locator_id number;
   l_cost_group_id number;
BEGIN

-- Clearing the quantity cache
   inv_quantity_tree_pub.clear_quantity_cache;


   if upper(p_revision_control) = 'TRUE' then
      l_is_revision_control := TRUE;
   end if;
   if upper(p_lot_control) = 'TRUE' then
      l_is_lot_control := TRUE;
   end if;
   if upper(p_serial_control) = 'TRUE' then
      l_is_serial_control := TRUE;
   end if;

   if p_locator_id <= 0 then
      l_locator_id := null;
   else
      l_locator_id := p_locator_id;
   end if;

   if p_cost_group_id <= 0 then
      l_cost_group_id := null;
   else
      l_cost_group_id := p_cost_group_id;
   end if;

   Inv_Quantity_Tree_Pub.Query_Quantities (
                p_api_version_number => 1.0,
                p_init_msg_lst       => fnd_api.g_false,
                x_return_status      => l_return_status,
                x_msg_count          => l_msg_count,
                x_msg_data           => l_msg_data,
                p_organization_id    => p_organization_id,
                p_inventory_item_id  => p_inventory_item_id,
                p_tree_mode          => INV_Quantity_Tree_PUB.g_transaction_mode,
                p_is_revision_control => l_is_revision_control,
                p_is_lot_control     => l_is_lot_control,
                p_is_serial_control  => l_is_serial_control,
                p_revision           => p_revision,
                p_lot_number         => p_lot_number,
                p_subinventory_code  => p_subinventory_code,
                p_locator_id         => l_locator_id,
                x_qoh                => l_qoh,
                x_rqoh               => l_rqoh,
                x_qr                 => l_qr,
                x_qs                 => l_qs,
                x_att                => l_att,
                x_atr                => l_atr,
            p_cost_group_id       => l_cost_group_id);
--
   IF (l_return_status = fnd_api.g_ret_sts_success)
   THEN
      return l_atr;       -- Return the available quantity
   ELSE
      return -99999999;   -- Return bogus number if error occurs
   END IF;
--
END GET_AVAILABLE_QTY;

/****************************************************************************
      30.1.2002 Updated by venjayar
         To account for getting the LotAttributes of a lot even if the LPN is
         in Packing Context (as part of the bug 2091699)
****************************************************************************/
/*
 * BUg 2267890 - add msik.lot_status_enabled for the cursor
 */
PROCEDURE LOT_ATTRIBUTES (
   x_lot_attributes OUT NOCOPY t_genref,
   p_lot_number IN VARCHAR2,
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_lpn_context_id IN NUMBER DEFAULT 0) IS
BEGIN
   IF(p_lpn_context_id = 8)
   THEN
      /* PACKING CONTEXT   */
      OPEN x_lot_attributes FOR
         SELECT mmst.status_code, mmst.status_id,
                msik.shelf_life_code, msik.lot_status_enabled, mtlt.lot_expiration_date
         FROM mtl_material_statuses_vl mmst,
              mtl_system_items_kfv msik,
              mtl_transaction_lots_temp mtlt,
              mtl_material_transactions_temp mmtt
         WHERE mtlt.lot_number = p_lot_number
           AND mmtt.organization_id = p_organization_id
           AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
           AND msik.inventory_item_id = p_inventory_item_id
           AND mmst.status_id(+) = mtlt.status_id
           AND msik.organization_id = mmtt.organization_id;
   ELSE
      /* All other Contexts */
      OPEN x_lot_attributes FOR
      SELECT mmst.status_code, mmst.status_id,
             msik.shelf_life_code, msik.lot_status_enabled, mln.expiration_date
      FROM mtl_material_statuses_vl mmst,
           mtl_system_items_kfv msik,
           mtl_lot_numbers mln
      WHERE mln.lot_number = p_lot_number
        AND mln.organization_id = p_organization_id
        AND msik.inventory_item_id = p_inventory_item_id
        AND mmst.status_id(+) = mln.status_id
        AND msik.organization_id = mln.organization_id
        -- Following condition is added as a part of Bug fix for Bug# 3549931
        AND msik.inventory_item_id = mln.inventory_item_id;
   END IF;
EXCEPTION
    when FND_API.G_EXC_UNEXPECTED_ERROR then
        null;
END LOT_ATTRIBUTES;

/****************************************************************************
      30.1.2002 Updated by venjayar
         To account for getting the Serial Attributes of a Serial Number
         even if the LPN is in Packing Context (as part of the bug 2091699)
****************************************************************************/
PROCEDURE SERIAL_ATTRIBUTES(
   x_serial_attributes OUT NOCOPY t_genref,
   p_serial_number IN VARCHAR2,
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_lpn_context_id IN NUMBER DEFAULT 0) IS

BEGIN
   IF(p_lpn_context_id = 8)
   THEN
      /*    PACKING CONTEXT      */
      OPEN x_serial_attributes FOR
         SELECT mmst.status_code, msik.serial_status_enabled, mmst.status_id
         FROM mtl_material_statuses_vl mmst,
              mtl_serial_numbers_temp msnt,
              mtl_material_transactions_temp mmtt,
              mtl_transaction_lots_temp mtlt,
          mtl_system_items_b msik
         WHERE mmtt.organization_id = p_organization_id
         AND mmtt.inventory_item_id = p_inventory_item_id
     AND msik.organization_id = mmtt.organization_id
     AND msik.inventory_item_id = mmtt.inventory_item_id
         AND msnt.status_id = mmst.status_id(+)
         AND msnt.fm_serial_number = p_serial_number
         AND mmtt.transaction_temp_id = mtlt.transaction_temp_id(+)
         AND nvl(mtlt.serial_transaction_temp_id,mmtt.transaction_temp_id) = msnt.transaction_temp_id;
   ELSE
      /*    All other Contexts      */
      OPEN x_serial_attributes FOR
         SELECT mmst.status_code, msik.serial_status_enabled, mmst.status_id
         FROM mtl_material_statuses_vl mmst, mtl_serial_numbers msn, mtl_system_items_b msik
         WHERE msn.current_organization_id = p_organization_id
         AND msn.inventory_item_id = p_inventory_item_id
     AND msik.organization_id = msn.current_organization_id
     AND msik.inventory_item_id = msn.inventory_item_id
         AND msn.status_id = mmst.status_id(+)
         AND msn.serial_number = p_serial_number;
   END IF;
EXCEPTION
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      null;
END SERIAL_ATTRIBUTES;

PROCEDURE Get_Serial_Number(
   x_serialLOV OUT NOCOPY t_genref,
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_serial_number in VARCHAR2)
IS
BEGIN
    /* FP-J Lot/Serial Support Enhancements
     * Add current status of resides in receiving
     */
     OPEN x_serialLOV for
   select serial_number, current_subinventory_code, current_locator_id, lot_number,'', current_status, ''
   from mtl_serial_numbers
   where current_organization_id = p_organization_id
   and inventory_item_id = p_inventory_item_id
   --and current_status in (3, 5)
   AND current_status in (3, 5, 7)
   and serial_number like (p_serial_number);
END Get_Serial_number;

PROCEDURE Get_Serial_Number_Inq(
   x_serialLOV OUT NOCOPY t_genref,
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_serial_number in VARCHAR2)
IS
BEGIN
    /* FP-J Lot/Serial Support Enhancements
     * Add current status of resides in receiving
     */
     OPEN x_serialLOV for
   select msn.serial_number, msn.current_subinventory_code, milk.concatenated_segments
      , msn.lot_number,'', msn.current_status, '', msn.current_locator_id
   from mtl_serial_numbers msn, mtl_item_locations_kfv milk
   where msn.current_organization_id = p_organization_id
   and msn.inventory_item_id = p_inventory_item_id
   --and msn.current_status in (3, 5)
   AND msn.current_status in (3, 5, 7)
   and msn.serial_number like (p_serial_number)
   and milk.organization_id (+) = msn.current_organization_id
   and milk.subinventory_code (+) = msn.current_subinventory_code
   and milk.inventory_location_id (+) = msn.current_locator_id
   ORDER BY msn.serial_number, msn.current_subinventory_code, milk.concatenated_segments;
END Get_Serial_number_Inq;


--  Added by Manu Gupta 28-Feb-2001
--  This works just as Get_Serial_Number but
--  is specific for misc receipts
PROCEDURE Get_Serial_Number_RcptTrx(
        x_serialLOV OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_inventory_item_id IN NUMBER,
        p_serial_number in VARCHAR2,
   p_transactiontypeid IN NUMBER)
IS
BEGIN

     OPEN x_serialLOV for
        select serial_number, current_subinventory_code, current_locator_id, lot_number,'', current_status, ''
        from mtl_serial_numbers
        where current_organization_id = p_organization_id
        and inventory_item_id = p_inventory_item_id
       AND(
        (current_organization_id = p_organization_id  AND current_status = 1)
            OR
            (current_status = 4 AND Nvl(to_number(fnd_profile.value('INV_RESTRICT_RCPT_SER')), 2) = 2)
            OR
        (current_status = 4 AND Nvl(to_number(fnd_profile.value('INV_RESTRICT_RCPT_SER')), 2) = 1 AND last_txn_source_type_id Not in (2,5))
         )
        and serial_number like (p_serial_number)
    AND (group_mark_id is null OR group_mark_id = -1) -- Bug # 2591673
   and
        (INV_MATERIAL_STATUS_GRP.is_status_applicable(
               'TRUE',
               NULL,
               p_transactiontypeid,
               NULL,
               NULL,
               p_organization_id,
               p_inventory_item_id,
               current_subinventory_code,
               current_locator_id,
               lot_number,
               serial_number,
               'S')) = 'Y'
     ORDER BY serial_number;
END Get_Serial_Number_RcptTrx;

PROCEDURE Get_PUP_Serial_Number(
   x_serialLOV OUT NOCOPY t_genref,
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_serial_number in VARCHAR2,
   p_txn_type_id    IN   NUMBER   := 0,
   p_wms_installed  IN   VARCHAR2 :='TRUE')
IS
BEGIN
    /* FP-J Lot/Serial Support Enhancements
     * Add current status of resides in receiving */
     OPEN x_serialLOV for
   select serial_number, current_subinventory_code, current_locator_id, lot_number
   from mtl_serial_numbers
   where current_organization_id = p_organization_id
   and inventory_item_id = p_inventory_item_id
       --and current_status in (3, 5)
       AND current_status in (3, 5, 7)
       and serial_number like p_serial_number
       AND inv_material_status_grp.is_status_applicable
                                         (p_wms_installed,
                                          NULL,
                 p_txn_type_id,
                 NULL,
                 NULL,
                 p_organization_id,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 p_serial_number,
                 'S') = 'Y' ;
END Get_PUP_Serial_NUMBER;

PROCEDURE get_serial_lov(x_serial_number OUT NOCOPY t_genref,
              p_organization_id IN NUMBER,
              p_item_id IN VARCHAR2,
              p_serial IN VARCHAR2)
  IS
BEGIN
   OPEN x_serial_number FOR
     SELECT serial_number, current_subinventory_code, current_locator_id, lot_number, 'A', 'A', 'A'
     FROM   mtl_serial_numbers
     WHERE inventory_item_id = TO_NUMBER(p_item_id)
     AND (group_mark_id is null OR group_mark_id = -1)
     AND current_organization_id = p_organization_id
     --AND (  (current_organization_id = p_organization_id AND current_status = 1)
     --       OR current_status = 4)
     AND serial_number LIKE (p_serial)
     ORDER BY Lpad(serial_number,20);

END get_serial_lov;


PROCEDURE SELECT_SERIAL_NUMBER(
        x_serial_numbers OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_inventory_item_id IN NUMBER,
        p_revision IN VARCHAR2,
        p_subinventory_code IN VARCHAR2,
        p_locator_id IN NUMBER,
        p_cost_Group_id IN NUMBER,
        p_lot_number IN VARCHAR2) IS
BEGIN
   open x_serial_numbers FOR
   select ms.serial_number, ms.lpn_id
   from mtl_serial_numbers ms
   where ms.inventory_item_id = p_inventory_item_id
   and ms.current_organization_id = p_organization_id
   and nvl(ms.revision, '$@#$%') =
      decode(p_revision, NULL, nvl(ms.revision, '$@#$%'), p_revision)
   AND nvl(ms.current_subinventory_code, '$@#$%') =
      decode(p_subinventory_code, NULL, nvl(ms.current_subinventory_code, '$@#$%'), p_subinventory_code)
   AND nvl(ms.current_locator_id, 0) = decode(p_locator_id, NULL, nvl(ms.current_locator_id, 0), p_locator_id)
   AND nvl(ms.cost_group_id, 0) = decode(p_cost_group_id, NULL, nvl(ms.cost_group_id, 0), p_cost_group_id)
   AND nvl(ms.lot_number, '$@#$%') = decode(p_lot_number, NULL, nvl(ms.lot_number, '$@#$%'), p_lot_number)
   AND ms.current_status =3
        and not exists (select w.status
                        from   mtl_material_transactions_temp t,
                               wms_dispatched_tasks w
                        where  w.status = 4
                        and    w.task_type <> 2
                        and    w.transaction_temp_id = t.transaction_temp_id
                        and    (t.content_lpn_id = ms.lpn_id or
                                        t.lpn_id = ms.lpn_id));

END SELECT_SERIAL_NUMBER;

/****************************************************************************
      Added by Amy (qxliu) Sept. 20, 2001
      Overloaded procedure to find serial numbers in a LPN

      30.1.2002 Updated by venjayar
         To account for getting the Serial Numbers even if the LPN is
         in Packing Context (as part of the bug 2091699)
****************************************************************************/
PROCEDURE SELECT_SERIAL_NUMBER(
        x_serial_numbers OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_inventory_item_id IN NUMBER,
        p_lot_number IN VARCHAR2,
        p_lpn_id IN NUMBER,
        p_lpn_context_id IN NUMBER DEFAULT 0,
        p_revision IN VARCHAR2) IS
BEGIN

   IF (p_lpn_context_id = 8)
   THEN
      /*    PACKING CONTEXT      */
      OPEN x_serial_numbers FOR
         SELECT msnt.fm_serial_number, mmtt.transfer_lpn_id, mtlt.lot_number
         FROM mtl_serial_numbers_temp msnt,
              mtl_material_transactions_temp mmtt,
              mtl_transaction_lots_temp mtlt
         WHERE mmtt.transaction_temp_id = mtlt.transaction_temp_id(+)
           and nvl(mtlt.serial_transaction_temp_id,mmtt.transaction_temp_id) = msnt.transaction_temp_id
           and mmtt.inventory_item_id = p_inventory_item_id
           and nvl(mmtt.revision,'$@#$%') = DECODE(p_revision,NULL,nvl(mmtt.revision,'$@#$%'),p_revision)
           and mmtt.organization_id = p_organization_id
           and mmtt.transfer_lpn_id = p_lpn_id
           and nvl(mtlt.lot_number,'$@#$%') = DECODE(p_lot_number,NULL,nvl(mtlt.lot_number,'$@#$%'),p_lot_number);
   ELSE
      /* FP-J Lot/Serial Support Enhancements
       * Add current status of resides in receiving */
      /*    All other Contexts      */
      OPEN x_serial_numbers FOR
      SELECT ms.serial_number, ms.lpn_id
      FROM mtl_serial_numbers ms
      WHERE ms.inventory_item_id = p_inventory_item_id
      AND ms.current_organization_id = p_organization_id
      AND nvl(ms.revision, '$@#$%') = decode(p_revision, NULL, nvl(ms.revision, '$@#$%'), p_revision)
      AND nvl(ms.lot_number, '$@#$%') = decode(p_lot_number, NULL, nvl(ms.lot_number, '$@#$%'), p_lot_number)
      --AND ms.current_status in (3,4,5)
      --Bug no 3589766
      --Show serial numbers irrespective of the status of the serial number.
      --AND ms.current_status in (3, 4, 5, 7)
           AND NOT EXISTS (SELECT w.status
                           FROM   mtl_material_transactions_temp t,
                                  wms_dispatched_tasks w
                           WHERE  w.status = 4
                           AND    w.task_type <> 2
                           AND    w.transaction_temp_id = t.transaction_temp_id
                           AND    (t.content_lpn_id = ms.lpn_id or
                                           t.transfer_lpn_id = ms.lpn_id))
      AND ms.lpn_id = p_lpn_id;

   END IF;
END SELECT_SERIAL_NUMBER;


PROCEDURE UPDATE_QUANTITY (
     p_organization_id          IN  NUMBER
   , p_inventory_item_id        IN  NUMBER
   , p_revision                 IN  VARCHAR2 DEFAULT NULL
   , p_lot_number               IN  VARCHAR2 DEFAULT NULL
   , p_subinventory_code        IN  VARCHAR2 DEFAULT NULL
   , p_locator_id               IN  NUMBER   DEFAULT NULL
   , p_cost_group_id            IN  NUMBER DEFAULT NULL
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_primary_quantity         IN  NUMBER
   , p_containerized            IN  NUMBER
   , x_qoh                      OUT NOCOPY NUMBER
   , x_att                      OUT NOCOPY NUMBER
   , x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   ) IS

  l_api_version_number CONSTANT NUMBER := 1.0;
  l_api_name CONSTANT VARCHAR2(30) := 'Update_Quantities';
  l_tree_mode NUMBER := INV_Quantity_Tree_Pvt.g_transaction_mode;
  l_is_revision_control BOOLEAN;
  l_is_lot_control BOOLEAN;
  l_is_serial_control BOOLEAN;
  l_rev_control_code NUMBER;
  l_lot_control_code NUMBER;
  l_ser_control_code NUMBER;
  l_demand_source_type_id NUMBER := 13;
  l_demand_source_header_id NUMBER := -9999;
  l_demand_source_line_id NUMBER := -9999;
  l_demand_source_name VARCHAR2(30) := NULL;
  l_lot_expiration_date DATE;
  l_quantity_type NUMBER := inv_quantity_tree_pvt.g_qoh;
  l_onhand_source NUMBER := inv_quantity_tree_pvt.g_all_subs;
  l_rqoh NUMBER;
  l_qr NUMBER;
  l_qs NUMBER;
  l_atr NUMBER;

  cursor iteminfo is
   select nvl(msi.revision_qty_control_code, 1)
         ,nvl(msi.lot_control_code, 1)
         ,nvl(msi.serial_number_control_code,1)
     from mtl_system_items msi
    where organization_id = p_organization_id
      and inventory_item_id = p_inventory_item_id;

BEGIN

  l_lot_expiration_date := to_date(NULL);

  open iteminfo;
  fetch iteminfo into l_rev_control_code
                   ,l_lot_control_code
                   ,l_ser_control_code;
  if iteminfo%notfound then
     close iteminfo;
     raise no_data_found;
  end if;
  close iteminfo;

  if l_rev_control_code = 1 then
      l_is_revision_control := false;
  else
      l_is_revision_control := true;
  end if;
  if l_lot_control_code = 1 then
      l_is_lot_control := false;
  else
      l_is_lot_control := true;
  end if;
  if l_ser_control_code = 1 then
      l_is_serial_control := false;
  else
      l_is_serial_control := true;
  end if;

  inv_quantity_tree_pub.update_quantities
  (  p_api_version_number       => l_api_version_number
   , p_init_msg_lst             => fnd_api.g_false
   , x_return_status            => x_return_status
   , x_msg_count                => x_msg_count
   , x_msg_data                 => x_msg_data
   , p_organization_id          => p_organization_id
   , p_inventory_item_id        => p_inventory_item_id
   , p_tree_mode                => l_tree_mode
   , p_is_revision_control      => l_is_revision_control
   , p_is_lot_control           => l_is_lot_control
   , p_is_serial_control        => l_is_serial_control
   , p_demand_source_type_id    => l_demand_source_type_id
   , p_demand_source_header_id  => l_demand_source_header_id
   , p_demand_source_line_id    => l_demand_source_line_id
   , p_demand_source_name       => l_demand_source_name
   , p_lot_expiration_date      => l_lot_expiration_date
   , p_revision                 => p_revision
   , p_lot_number               => p_lot_number
   , p_subinventory_code        => p_subinventory_code
   , p_locator_id               => p_locator_id
   , p_primary_quantity         => p_primary_quantity
   , p_quantity_type            => l_quantity_type
   , p_onhand_source            => l_onhand_source
   , x_qoh                      => x_qoh
   , x_rqoh                     => l_rqoh
   , x_qr                       => l_qr
   , x_qs                       => l_qs
   , x_att                      => x_att
   , x_atr                      => l_atr
   , p_transfer_subinventory_code => p_transfer_subinventory_code
   , p_cost_group_id            => p_cost_group_id
   , p_containerized            => p_containerized
   ) ;

exception
  when others then
    --
      if iteminfo%isopen then
        close iteminfo;
      end if;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );

END UPDATE_QUANTITY;

 -- INVCONV, NSRIVAST, START
  /*
   * Overloaded procedure that calls the the update_quantity procedure
   * with secondary quantity.
   */

PROCEDURE UPDATE_QUANTITY (
     p_organization_id          IN  NUMBER
   , p_inventory_item_id        IN  NUMBER
   , p_revision                 IN  VARCHAR2 DEFAULT NULL
   , p_lot_number               IN  VARCHAR2 DEFAULT NULL
   , p_subinventory_code        IN  VARCHAR2 DEFAULT NULL
   , p_locator_id               IN  NUMBER   DEFAULT NULL
   , p_cost_group_id            IN  NUMBER DEFAULT NULL
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_primary_quantity         IN  NUMBER
   , p_containerized            IN  NUMBER
   , p_secondary_quntity        IN  NUMBER            -- INVCONV, NSRIVAST,
   , x_qoh                      OUT NOCOPY NUMBER
   , x_att                      OUT NOCOPY NUMBER
   , x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   ) IS

  l_api_version_number CONSTANT NUMBER := 1.0;
  l_api_name CONSTANT VARCHAR2(30) := 'Update_Quantities';
  l_tree_mode NUMBER := INV_Quantity_Tree_Pvt.g_transaction_mode;
  l_is_revision_control BOOLEAN;
  l_is_lot_control BOOLEAN;
  l_is_serial_control BOOLEAN;
  l_rev_control_code NUMBER;
  l_lot_control_code NUMBER;
  l_ser_control_code NUMBER;
  l_demand_source_type_id NUMBER := 13;
  l_demand_source_header_id NUMBER := -9999;
  l_demand_source_line_id NUMBER := -9999;
  l_demand_source_name VARCHAR2(30) := NULL;
  l_lot_expiration_date DATE;
  l_quantity_type NUMBER := inv_quantity_tree_pvt.g_qoh;
  l_onhand_source NUMBER := inv_quantity_tree_pvt.g_all_subs;
  l_rqoh        NUMBER;
  l_qr          NUMBER;
  l_qs          NUMBER;
  l_atr         NUMBER;
  -- INVCONV, NSRIVAST, END
  l_sqoh        NUMBER;
  l_srqoh       NUMBER;
  l_sqr         NUMBER;
  l_sqs         NUMBER;
  l_satt        NUMBER;
  l_satr        NUMBER;
  l_grade       VARCHAR2(150) := NULL ;
  -- INVCONV, NSRIVAST, END

  cursor iteminfo is
   select nvl(msi.revision_qty_control_code, 1)
         ,nvl(msi.lot_control_code, 1)
         ,nvl(msi.serial_number_control_code,1)
     from mtl_system_items msi
    where organization_id = p_organization_id
      and inventory_item_id = p_inventory_item_id;

BEGIN

  l_lot_expiration_date := to_date(NULL);

  open iteminfo;
  fetch iteminfo into l_rev_control_code
                   ,l_lot_control_code
                   ,l_ser_control_code;
  if iteminfo%notfound then
     close iteminfo;
     raise no_data_found;
  end if;
  close iteminfo;

  if l_rev_control_code = 1 then
      l_is_revision_control := false;
  else
      l_is_revision_control := true;
  end if;
  if l_lot_control_code = 1 then
      l_is_lot_control := false;
  else
      l_is_lot_control := true;
  end if;
  if l_ser_control_code = 1 then
      l_is_serial_control := false;
  else
      l_is_serial_control := true;
  end if;

  inv_quantity_tree_pub.update_quantities
  (  p_api_version_number       => l_api_version_number
   , p_init_msg_lst             => fnd_api.g_false
   , x_return_status            => x_return_status
   , x_msg_count                => x_msg_count
   , x_msg_data                 => x_msg_data
   , p_organization_id          => p_organization_id
   , p_inventory_item_id        => p_inventory_item_id
   , p_tree_mode                => l_tree_mode
   , p_is_revision_control      => l_is_revision_control
   , p_is_lot_control           => l_is_lot_control
   , p_is_serial_control        => l_is_serial_control
   , p_demand_source_type_id    => l_demand_source_type_id
   , p_demand_source_header_id  => l_demand_source_header_id
   , p_demand_source_line_id    => l_demand_source_line_id
   , p_demand_source_name       => l_demand_source_name
   , p_lot_expiration_date      => l_lot_expiration_date
   , p_revision                 => p_revision
   , p_lot_number               => p_lot_number
   , p_subinventory_code        => p_subinventory_code
   , p_locator_id               => p_locator_id
   , p_primary_quantity         => p_primary_quantity
   , p_quantity_type            => l_quantity_type
   , p_onhand_source            => l_onhand_source
   , x_qoh                      => x_qoh
   , x_rqoh                     => l_rqoh
   , x_qr                       => l_qr
   , x_qs                       => l_qs
   , x_att                      => x_att
   , x_atr                      => l_atr
   , p_transfer_subinventory_code => p_transfer_subinventory_code
   , p_cost_group_id            => p_cost_group_id
   , p_containerized            => p_containerized
     -- INVCONV, NSRIVAST, Start
   , x_sqoh                     => l_sqoh
   , x_srqoh                    => l_srqoh
   , x_sqr                      => l_sqr
   , x_sqs                      => l_sqs
   , x_satt                     => l_satt
   , x_satr                     => l_satr
   , p_grade_code               => l_grade
   , p_secondary_quantity       => p_secondary_quntity
   --, p_transfer_locator_id    =>
   ---, p_lpn_id                =>
     -- INVCONV, NSRIVAST, End
   ) ;

exception
  when others then
    --
      if iteminfo%isopen then
        close iteminfo;
      end if;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );

END UPDATE_QUANTITY;
-- INVCONV, NSRIVAST, END


--
/******************************************************
 * Obtain onhand information for an INV org
 * Overloaded to include filtering on project and task
 ******************************************************
 */

PROCEDURE INV_ITEM_INQUIRIES (
               x_item_inquiries         OUT NOCOPY t_genref,
               p_Organization_Id        IN  NUMBER,
               p_Inventory_Item_Id      IN  NUMBER    DEFAULT NULL,
               p_Revision               IN  VARCHAR2  DEFAULT NULL,
               p_Lot_Number             IN  VARCHAR2  DEFAULT NULL,
               p_Subinventory_Code      IN  VARCHAR2  DEFAULT NULL,
               p_Locator_Id             IN  NUMBER    DEFAULT NULL,
               p_project_id             IN  NUMBER    DEFAULT NULL,
               p_task_id                IN  NUMBER    DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2) IS
BEGIN
      OPEN x_item_inquiries FOR
         SELECT msik.concatenated_segments,  -- Item Concatenated Segments
                moq.revision,
                msik.description,
                moq.subinventory_code,
                moq.locator_id,
                INV_PROJECT.GET_LOCSEGS(moq.locator_id,
                        p_organization_id) concatenated_segments, --Physical Locator Segs
                moq.lot_number,
                msik.primary_uom_code,
                sum(nvl(moq.primary_transaction_quantity, 0)),
                /* Bug 4117556 performance issue for item inquiry
                   Do not call quantity tree to get available quantity for each onhand record
                   Instead, calling quantity tree at each page entered event of ItemOnhandPage */
                /*inv_ITEM_INQ.get_available_qty(
                     moq.organization_id,
                     moq.inventory_item_id,
                     moq.revision,
                     moq.subinventory_code,
                     moq.locator_id,
                     moq.lot_number,null,
                     decode(moq.revision, NULL, 'FALSE', 'TRUE'),
                     decode(msik.lot_control_code, 2, 'TRUE', 'FALSE'),
                     decode(msik.serial_number_control_code, NULL, 'FALSE', 1, 'FALSE', 'TRUE'))*/
                     -999,
                msub.status_id,
                inv_item_inq.get_status_code(msub.status_id),
                mil.status_id,
                inv_item_inq.get_status_code(mil.status_id),
                mln.status_id,
                inv_item_inq.get_status_code(mln.status_id),
                msik.serial_number_control_code,
                moq.cost_group_id,
                INV_PROJECT.GET_PROJECT_NUMBER project_number,   --Project #
                INV_PROJECT.GET_TASK_NUMBER task_number,      --Task #
                -- INVCONV start
                NVL(msik.tracking_quantity_ind, 'P'),
                sum(nvl(moq.secondary_transaction_quantity, 0)),
                msik.secondary_uom_code
                -- INVCONV end
          FROM  mtl_onhand_quantities_detail moq,
                mtl_system_items_vl msik, -- Modified for Bug # 5472330
                mtl_item_locations mil,
                mtl_secondary_inventories msub,
                mtl_lot_numbers mln
          WHERE moq.organization_id = msik.organization_id
          AND   moq.inventory_item_id = msik.inventory_item_id
          AND   moq.organization_id = msub.organization_id
          AND   moq.subinventory_code = msub.secondary_inventory_name(+)
          AND   moq.organization_id = mil.organization_id(+)
          AND   moq.locator_id = mil.inventory_location_id(+)
          AND   NVL(mil.project_id,-9999) = NVL(p_project_id, NVL(mil.project_id,-9999)) -- filter on project
          AND   NVL(mil.task_id, -9999) = NVL(p_task_id, NVL(mil.task_id, -9999))
          AND   moq.subinventory_code = mil.subinventory_code(+)
          AND   moq.organization_id = mln.organization_id(+)
          AND   moq.inventory_item_id = mln.inventory_item_id(+)
          AND   moq.lot_number = mln.lot_number(+)
          AND   moq.organization_id        = p_Organization_Id
          AND   moq.inventory_item_id     =
                decode (p_Inventory_Item_Id, NULL, moq.inventory_item_id, p_Inventory_Item_Id)
          -- Bug 4301817 Not check mtl_transactions_enabled_flag to query non-transactable items
          -- AND   msik.mtl_transactions_enabled_flag = 'Y'
          AND   nvl(moq.revision, '!@#$%^&') =
              decode(p_Revision, NULL, nvl(moq.revision, '!@#$%^&'), p_Revision)
          AND   nvl(moq.lot_number, '!@#$%^&') =
              decode (p_Lot_Number, NULL, nvl(moq.lot_number, '!@#$%^&'), p_Lot_Number)
          AND   nvl(moq.subinventory_code, '!@#$%^&') =
              decode (p_Subinventory_Code, NULL, nvl(moq.subinventory_code, '!@#$%^&'), p_Subinventory_Code)
          AND   nvl(moq.locator_id, 0) =
              decode(p_Locator_Id, NULL, nvl(moq.locator_id, 0), p_Locator_Id)
          GROUP BY moq.organization_id, moq.inventory_item_id,
               msik.concatenated_segments, moq.revision, msik.description,
               moq.subinventory_code, moq.locator_id,
               INV_PROJECT.GET_LOCSEGS(moq.locator_id,p_organization_id),
               moq.lot_number, msik.primary_uom_code,
                /* Bug 4117556 performance issue for item inquiry */
                /*inv_item_inq.get_available_qty(
                   moq.organization_id,
                   moq.inventory_item_id,
                   moq.revision,
                   moq.subinventory_code,
                   moq.locator_id,
                   moq.lot_number, null,
                   decode(moq.revision, NULL, 'FALSE', 'TRUE'),
                   decode(msik.lot_control_code, 2, 'TRUE', 'FALSE'),
                   decode(msik.serial_number_control_code, NULL, 'FALSE', 1, 'FALSE', 'TRUE'))*/
                  -999,
                msub.status_id,
                inv_item_inq.get_status_code(msub.status_id),
                mil.status_id,
                inv_item_inq.get_status_code(mil.status_id),
                mln.status_id,
                inv_item_inq.get_status_code(mln.status_id),
               msik.serial_number_control_code,
               moq.cost_group_id,
               INV_PROJECT.GET_PROJECT_NUMBER,
               INV_PROJECT.GET_TASK_NUMBER,
               -- INVCONV start
               NVL(msik.tracking_quantity_ind, 'P'),
               msik.secondary_uom_code;
               -- INVCONV end


       x_status := 'C';
       x_message := 'Records found';
EXCEPTION
    when others then
        x_status := 'E';
        x_message := substr(SQLERRM,1,240);
END  INV_ITEM_INQUIRIES;

/*******************************************************************
 * Obtain onhand information WMS org, provide cost group
 * information query wms related information
 * Overloaded to include filtering on project and task
 *******************************************************************
 */
PROCEDURE WMS_LOOSE_ITEM_INQUIRIES (
          x_item_inquiries    OUT NOCOPY t_genref,
          p_organization_id   IN  NUMBER,
          p_inventory_item_id IN  NUMBER   DEFAULT NULL,
          p_revision          IN  VARCHAR2 DEFAULT NULL,
          p_lot_number        IN  VARCHAR2 DEFAULT NULL,
          p_subinventory_code IN  VARCHAR2 DEFAULT NULL,
          p_locator_id        IN  NUMBER   DEFAULT NULL,
          p_cost_Group_id     IN  NUMBER   DEFAULT NULL,
          p_project_id        IN  NUMBER   DEFAULT NULL,
          p_task_id           IN  NUMBER   DEFAULT NULL,
          x_status            OUT NOCOPY VARCHAR2,
          x_message           OUT NOCOPY VARCHAR2) IS
BEGIN
      OPEN x_item_inquiries FOR
   SELECT b.msik_concatenated_segments,
               b.revision,
               b.description,
               b.subinventory_code,
               b.subinventory_status_id,
               b.subinventory_status,
               b.locator_id,
               b.milk_concatenated_segments,
               b.locator_status_id,
               b.locator_status,
               b.cost_group_id,
               b.cost_group,
               b.lot_number,
               b.lot_status_id,
               b.lot_status,
               b.primary_uom_code,
               b.sum_txn_qty,
               /* Bug 4117556 performance issue for item inquiry
                   Do not call quantity tree to get available quantity for each onhand record
                   Instead, calling quantity tree at each page entered event of ItemOnhandPage */
               /*inv_item_inq.get_available_qty(
                    b.organization_id,
                    b.inventory_item_id,
                    b.revision,
                    b.subinventory_code,
                    b.locator_id,
                    b.lot_number,
                    b.cost_group_id,
                    decode(b.revision, NULL, 'FALSE', 'TRUE'),
                    decode(b.lot_control_code, 2, 'TRUE', 'FALSE'),
                    decode(b.serial_number_control_code, NULL, 'FALSE', 1, 'FALSE', 'TRUE'))*/
                    -999,
               -- INVCONV start
               ---inv_item_inq.get_packed_quantity(
               ---     b.organization_id, b.inventory_item_id, b.revision,
               ---     b.subinventory_code, b.locator_id, b.lot_number, b.cost_Group_id),
               ---inv_item_inq.get_loose_quantity(
               ---     b.organization_id, b.inventory_item_id, b.revision,
               ---     b.subinventory_code, b.locator_id, b.lot_number, b.cost_Group_id),
               b.packed_quantity,    -- Bug : 4563072
   	       b.loose_quantity,     -- Bug : 4563072
               b.serial_number_control_code,
               b.project_number,
               b.task_number,
               -- INVCONV start
               b.tracking_quantity_ind,
               b.secondary_uom_code,
               -- INVCONV end
               b.sec_packed_quantity,  -- Bug : 4563072
   	       b.sec_loose_quantity    -- Bug : 4563072
     FROM
        (SELECT moq.organization_id organization_id,
           moq.inventory_item_id inventory_item_id,
           msik.concatenated_segments msik_concatenated_segments,
           moq.revision revision,
           msik.description description,
           moq.subinventory_code subinventory_code,
           msub.status_id subinventory_status_id,
           mms1.status_code subinventory_status,
           moq.locator_id locator_id,
           INV_PROJECT.GET_LOCSEGS(moq.locator_id,
                   p_organization_id) milk_concatenated_segments,  --Physical Locator Segements
           milk.status_id locator_status_id,
           mms2.status_code locator_status,
           moq.cost_group_id cost_group_id,
           csg.cost_group cost_group,
           moq.lot_number lot_number,
           mlot.status_id lot_status_id,
           mms3.status_code lot_status,
           msik.primary_uom_code primary_uom_code,
           sum(nvl(moq.primary_transaction_quantity, 0)) sum_txn_qty,
	   -- Start Bug : 4563072
           SUM(DECODE(moq.containerized_flag, 1, moq.primary_transaction_quantity, 0)) packed_quantity,
           SUM(DECODE(moq.containerized_flag, 1, 0, moq.primary_transaction_quantity)) loose_quantity,
           SUM(DECODE(moq.containerized_flag, 1, moq.secondary_transaction_quantity, 0)) sec_packed_quantity,
           SUM(DECODE(moq.containerized_flag, 1, 0, moq.secondary_transaction_quantity)) sec_loose_quantity,
	   -- End Bug : 4563072
	   msik.lot_control_code lot_control_code,
           msik.serial_number_control_code serial_number_control_code,
                     INV_PROJECT.GET_PROJECT_NUMBER project_number,
                     INV_PROJECT.GET_TASK_NUMBER task_number,
           -- INVCONV start
           NVL(msik.tracking_quantity_ind, 'P') tracking_quantity_ind,
           msik.secondary_uom_code secondary_uom_code
           -- INVCONV end
       FROM  mtl_onhand_quantities_detail moq,
             mtl_system_items_vl msik, -- Modified for Bug # 5472330
             mtl_item_locations milk,
             mtl_secondary_inventories msub,
             mtl_lot_numbers mlot,
             mtl_material_statuses_vl mms1,
             mtl_material_statuses_vl mms2,
             mtl_material_statuses_vl mms3,
             cst_cost_groups csg
       WHERE moq.organization_id = msik.organization_id
       AND   moq.inventory_item_id = msik.inventory_item_id
       AND   moq.organization_id = msub.organization_id
       AND   moq.subinventory_code = msub.secondary_inventory_name(+)
       AND   msub.status_id = mms1.status_id(+)
       AND   moq.organization_id = milk.organization_id
       AND   moq.locator_id = milk.inventory_location_id(+)
       AND   milk.status_id = mms2.status_id(+)
       AND   moq.subinventory_code = milk.subinventory_code(+)
       AND   moq.lot_number = mlot.lot_number(+)
       AND   moq.inventory_item_id = mlot.inventory_item_id(+)
       AND   moq.organization_id = mlot.organization_id(+)
       AND   mlot.status_id = mms3.status_id(+)
       AND   moq.cost_group_id = csg.cost_group_id(+)
      -- AND   moq.organization_id = csg.organization_id(+)
       AND   moq.organization_id        = p_Organization_Id
       AND   moq.inventory_item_id     =
             decode (p_Inventory_Item_Id, NULL, moq.inventory_item_id, p_Inventory_Item_Id)
       -- Bug 4301817 Not check mtl_transactions_enabled_flag to query non-transactable items
       -- AND   msik.mtl_transactions_enabled_flag = 'Y'
       AND   nvl(moq.revision, '!@#$%^&') =
          decode(p_Revision, NULL, nvl(moq.revision, '!@#$%^&'), p_Revision)
       AND   nvl(moq.lot_number, '!@#$%^&') =
            decode (p_Lot_Number, NULL, nvl(moq.lot_number, '!@#$%^&'), p_Lot_Number)
       AND   nvl(moq.subinventory_code, '!@#$%^&') =
            decode (p_Subinventory_Code, NULL, nvl(moq.subinventory_code, '!@#$%^&'), p_Subinventory_Code)
       AND   nvl(moq.locator_id, 0) =
            decode(p_Locator_Id, NULL, nvl(moq.locator_id, 0), p_Locator_Id)
       AND   nvl(moq.cost_group_id, 0) =
            decode(p_cost_group_id, NULL, nvl(moq.cost_group_id, 0), p_cost_group_id)
       AND  NVL(milk.project_id, -9999) = NVL(p_project_id, NVL(milk.project_id, -9999))
       AND  NVL(milk.task_id, -9999) = NVL(p_task_id, NVL(milk.task_id, -9999))
       GROUP BY moq.organization_id,
           moq.inventory_item_id,
           msik.concatenated_segments,
           moq.revision,
           msik.description,
           moq.subinventory_code,
           msub.status_id,
           mms1.status_code,
           moq.locator_id,
           INV_PROJECT.GET_LOCSEGS(moq.locator_id,p_organization_id),
           milk.status_id,
           mms2.status_code,
           moq.cost_group_id,
           csg.cost_group,
           moq.lot_number,
           mlot.status_id,
           mms3.status_code,
           msik.primary_uom_code,
           msik.lot_control_code,
           msik.serial_number_control_code,
           INV_PROJECT.GET_PROJECT_NUMBER,
           INV_PROJECT.GET_TASK_NUMBER,
           -- INVCONV start
           NVL(msik.tracking_quantity_ind, 'P'),
           msik.secondary_uom_code
           -- INVCONV end
           ) b;
       x_status := 'C';
       x_message := 'Records found';
EXCEPTION
     when others then
        x_status := 'E';
        x_message := SUBSTR (SQLERRM , 1 , 240);
END WMS_LOOSE_ITEM_INQUIRIES;

/******************************************************
 * Query for Inv org, giving serial number
 * Overloaded to include filter on project and task
 ******************************************************
 */
/* THIS PROCEDURE IS NOT BEING USED ANYWHERE */
PROCEDURE INV_SERIAL_INQUIRIES (
               x_serial_inquiries       OUT NOCOPY t_genref,
               p_Organization_Id        IN  NUMBER,
               p_Serial_Number          IN  VARCHAR2  DEFAULT NULL,
               p_Inventory_Item_Id      IN  NUMBER    DEFAULT NULL,
               p_Revision               IN  VARCHAR2  DEFAULT NULL,
               p_Lot_Number             IN  VARCHAR2  DEFAULT NULL,
               p_Subinventory_Code      IN  VARCHAR2  DEFAULT NULL,
               p_Locator_Id             IN  NUMBER    DEFAULT NULL,
               p_project_id             IN  NUMBER    DEFAULT NULL,
               p_task_id                IN  NUMBER    DEFAULT NULL,
               p_unit_number            IN  VARCHAR2  DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2) IS
BEGIN
      OPEN x_serial_inquiries FOR
      SELECT  msik.concatenated_segments, -- Item Concatenated Segments
              msn.revision,
              msik.description,
              msn.current_subinventory_code,
              msn.current_locator_id,
              INV_PROJECT.GET_LOCSEGS(msn.current_locator_id,
                      p_organization_id) concatenated_segments, --Locator Segments
              msn.lot_number,
              msn.serial_number,
              msik.primary_uom_code,
              1,
              INV_PROJECT.GET_PROJECT_NUMBER project_number,
              INV_PROJECT.GET_TASK_NUMBER task_number,
                msik.serial_number_control_code serial_number_control_code
      FROM    MTL_SERIAL_NUMBERS msn,
              MTL_SYSTEM_ITEMS_VL msik, /* Bug 5581528 */
              MTL_ITEM_LOCATIONS milk
      WHERE   milk.organization_id(+) = msn.current_organization_id
      AND     milk.subinventory_code(+) = msn.current_subinventory_code
      AND     milk.inventory_location_id(+) = msn.current_locator_id
            AND     msn.inventory_item_id         = msik.inventory_item_id
      AND     msn.current_organization_id   = msik.organization_id
      AND     msik.organization_id   = p_Organization_Id
      -- Bug 4301817 Not check mtl_transactions_enabled_flag to query non-transactable items
      -- AND     msik.mtl_transactions_enabled_flag = 'Y'
      AND     msn.serial_number =
                decode(p_Serial_Number, NULL, msn.serial_number, p_Serial_Number)
      AND     nvl(msn.end_item_unit_number, '$@#$%') =
              decode(p_unit_number, NULL, nvl(msn.end_item_unit_number, '$@#$%'), p_unit_number)
      AND     msn.inventory_item_id         = p_Inventory_Item_Id
      AND     nvl(msn.revision, '!@#$%^&') =
                decode(p_Revision, NULL, nvl(msn.revision, '!@#$%^&'), p_Revision)
      AND     nvl(msn.current_subinventory_code, '!@#$%^&') =
                decode(p_Subinventory_Code, NULL, nvl(msn.current_subinventory_code, '!@#$%^&'), p_Subinventory_Code)
      AND     nvl(msn.current_locator_id, 99999999) =
                decode(p_Locator_Id, NULL, nvl(msn.current_locator_id, 99999999), p_Locator_Id)
      AND     nvl(msn.lot_number, '!@#$%^&') =
                decode(p_Lot_Number, NULL, nvl(msn.lot_number, '!@#$%^&'), p_Lot_Number)
      AND     NVL(milk.project_id, -9999) = NVL(p_project_id, NVL(milk.project_id, -9999))
      AND     NVL(milk.task_id, -9999) = NVL(p_task_id, NVL(milk.task_id, -9999));

     x_status := 'C';
     x_message := 'Records found';
EXCEPTION
     when others then
        x_status := 'E';
        x_message := substr(SQLERRM,1,240);
END INV_SERIAL_INQUIRIES;

/*****************************************************************
 * Query for WMS org, giving serial number
 * Overloaded to filter on project and task
 ****************************************************************/
PROCEDURE WMS_LOOSE_SERIAL_INQUIRIES (
               x_serial_inquiries       OUT NOCOPY t_genref,
               p_Organization_Id        IN NUMBER,
               p_Serial_Number          IN VARCHAR2  DEFAULT NULL,
               p_Inventory_Item_Id      IN NUMBER    DEFAULT NULL,
               p_Revision               IN VARCHAR2  DEFAULT NULL,
               p_Lot_Number             IN VARCHAR2  DEFAULT NULL,
               p_Subinventory_Code      IN VARCHAR2  DEFAULT NULL,
               p_Locator_Id             IN NUMBER    DEFAULT NULL,
               p_cost_Group_id          IN NUMBER    DEFAULT NULL,
               p_project_id             IN NUMBER    DEFAULT NULL,
               p_task_id                IN NUMBER    DEFAULT NULL,
               p_unit_number            IN VARCHAR2  DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2) IS
BEGIN
      OPEN x_serial_inquiries FOR
      SELECT  msik.concatenated_segments, -- Item Concatenated Segments
              msn.revision,
              msik.description,
              msn.current_subinventory_code,
              msub.status_id subinventory_status_id,
              mms1.status_code subinventory_status,
              msn.current_locator_id,
              INV_PROJECT.GET_LOCSEGS(msn.current_locator_id,
                      p_organization_id) concatenated_segments, --Locator Segments
              milk.status_id locator_status_id,
              mms2.status_code locator_status,
              msn.cost_group_id,
              csg.cost_group,
              msn.lot_number,
              mlot.status_id lot_status_id,
              mms3.status_code lot_status,
              msn.serial_number,
              msn.status_id serial_status_id,
              mms4.status_code serial_status,
              msik.primary_uom_code,
              1,
              INV_PROJECT.GET_PROJECT_NUMBER project_number,
              INV_PROJECT.GET_TASK_NUMBER task_number,
                msik.serial_number_control_code serial_number_control_code,
              DECODE(msn.lpn_id,NULL,0,1) packed_qty,
              DECODE(msn.lpn_id,NULL,1,0) loose_qty
              -- INVCONV start
              ---NVL(msik.tracking_quantity_ind, 'P'),
              ---msik.secondary_uom_code
              -- INVCONV end
      FROM    MTL_SERIAL_NUMBERS msn,
              MTL_SYSTEM_ITEMS_VL msik, /* Bug 5581528 */
              MTL_ITEM_LOCATIONS milk,
              MTL_SECONDARY_INVENTORIES msub,
              MTL_LOT_NUMBERS mlot,
              MTL_MATERIAL_STATUSES_vl mms1,
              MTL_MATERIAL_STATUSES_vl mms2,
              MTL_MATERIAL_STATUSES_vl mms3,
              MTL_MATERIAL_STATUSES_vl mms4,
              CST_COST_GROUPS csg
      WHERE   milk.organization_id(+) = msn.current_organization_id
      AND     milk.subinventory_code(+) = msn.current_subinventory_code
      AND     milk.inventory_location_id(+) = msn.current_locator_id
      AND     milk.status_id = mms2.status_id(+)
      AND     msn.inventory_item_id         = msik.inventory_item_id
      AND     msn.current_organization_id   = msik.organization_id
      AND     msn.current_subinventory_code = msub.secondary_inventory_name(+)
      AND     msn.current_organization_id = msub.organization_id(+)
      AND     msub.status_id = mms1.status_id(+)
      AND     msn.cost_group_id = csg.cost_group_id(+)
      AND     msn.lot_number = mlot.lot_number (+)
      AND     msn.current_organization_id = mlot.organization_id(+)
      AND     msn.inventory_item_id = mlot.inventory_item_id(+)
      AND     mlot.status_id = mms3.status_id(+)
      AND     msn.status_id = mms4.status_id(+)
      AND     msik.organization_id   = p_Organization_Id
      -- Bug 4301817 Not check mtl_transactions_enabled_flag to query non-transactable items
      -- AND     msik.mtl_transactions_enabled_flag = 'Y'
      AND     msn.serial_number =  NVL(p_Serial_Number, msn.serial_number)
      AND     msn.inventory_item_id         = p_Inventory_Item_Id
      AND     nvl(msn.revision, '!@#$%^&') =
                decode(p_Revision, NULL, nvl(msn.revision, '!@#$%^&'), p_Revision)
      AND     nvl(msn.current_subinventory_code, '!@#$%^&') =
                decode(p_Subinventory_Code, NULL, nvl(msn.current_subinventory_code, '!@#$%^&'), p_Subinventory_Code)
      AND     nvl(msn.current_locator_id, 99999999) =
                decode(p_Locator_Id, NULL, nvl(msn.current_locator_id, 99999999), p_Locator_Id)
      AND     nvl(msn.cost_group_id, 99999999) =
                decode(p_cost_Group_id, NULL, nvl(msn.cost_group_id, 99999999), p_cost_group_id)
      AND     nvl(msn.lot_number, '!@#$%^&') =
                decode(p_Lot_Number, NULL, nvl(msn.lot_number, '!@#$%^&'), p_Lot_Number)
      AND     nvl(msn.end_item_unit_number, '$@#$%') =
              decode(p_unit_number, NULL, nvl(msn.end_item_unit_number, '$@#$%'), p_unit_number)
      AND     NVL(milk.project_id, -9999) = NVL(p_project_id, NVL(milk.project_id, -9999))
      AND     NVL(milk.task_id, -9999) = NVL(p_task_id, NVL(milk.task_id, -9999))
      AND     msn.current_status = 3;  -- Bug# 3196252

     x_status := 'C';
     x_message := 'Records found';
EXCEPTION
     when others then
        x_status := 'E';
        x_message := substr(SQLERRM,1,240);
END WMS_LOOSE_SERIAL_INQUIRIES;

/********************************************************
 * Procedure to fetch Unit Numbers for the item
 * Called from  UnitNumber LOV of Item Inquiry page
 ********************************************************/
PROCEDURE GET_UNIT_NUMBERS (
               x_unit_numbers           OUT NOCOPY t_genref,
               p_organization_id        IN NUMBER,
                             p_inventory_item_id      IN NUMBER,
               p_restrict_unit_numbers  IN VARCHAR2) IS
BEGIN
  OPEN x_unit_numbers FOR
    SELECT distinct end_item_unit_number
    FROM   mtl_serial_numbers
    WHERE  inventory_item_id = p_inventory_item_id
    AND    current_organization_id = p_organization_id
    AND    end_item_unit_number IS NOT NULL
    AND    end_item_unit_number like (p_restrict_unit_numbers)
  ORDER BY 1;

END GET_UNIT_NUMBERS;

/****************************************************************************
* Overloaded procedure to find serial numbers given a unit # and even serial #
* This procedure would be used when the ItemOnhandPage displays data for a
* Unit Number and/or a Serial Number
****************************************************************************/
PROCEDURE SELECT_SERIAL_NUMBER(
        x_serial_numbers OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_inventory_item_id IN NUMBER,
        p_revision IN VARCHAR2,
        p_subinventory_code IN VARCHAR2,
        p_locator_id IN NUMBER,
        p_cost_Group_id IN NUMBER,
        p_lot_number IN VARCHAR2,
        p_unit_number IN VARCHAR := NULL,
        p_serial_number IN VARCHAR2 := NULL) IS
BEGIN
   open x_serial_numbers FOR
   select ms.serial_number, ms.lpn_id
   from mtl_serial_numbers ms
   where ms.inventory_item_id = p_inventory_item_id
   and ms.current_organization_id = p_organization_id
   and nvl(ms.revision, '$@#$%') =
      decode(p_revision, NULL, nvl(ms.revision, '$@#$%'), p_revision)
   AND nvl(ms.current_subinventory_code, '$@#$%') =
      decode(p_subinventory_code, NULL, nvl(ms.current_subinventory_code, '$@#$%'), p_subinventory_code)
   AND nvl(ms.current_locator_id, 0) = decode(p_locator_id, NULL, nvl(ms.current_locator_id, 0), p_locator_id)
   AND nvl(ms.cost_group_id, 0) = decode(p_cost_group_id, NULL, nvl(ms.cost_group_id, 0), p_cost_group_id)
   AND nvl(ms.lot_number, '$@#$%') = decode(p_lot_number, NULL, nvl(ms.lot_number, '$@#$%'), p_lot_number)
   AND nvl(ms.serial_number, '$@#$%') = decode(p_serial_number, NULL, nvl(ms.serial_number, '$@#$%'), p_serial_number)
   AND nvl(ms.end_item_unit_number, '$@#$%') = decode(p_unit_number, NULL, nvl(ms.end_item_unit_number, '$@#$%'), p_unit_number)
   AND ms.current_status =3
        and not exists (select w.status
                        from   mtl_material_transactions_temp t,
                               wms_dispatched_tasks w
                        where  w.status = 4
                        and    w.task_type <> 2
                        and    w.transaction_temp_id = t.transaction_temp_id
                        and    (t.content_lpn_id = ms.lpn_id or
                                       t.lpn_id = ms.lpn_id));

END SELECT_SERIAL_NUMBER;

--Item Inquiry based on project, task and unit number for MSCA orgs
/* THIS PROCEDURE IS NOT BEING USED ANYWHERE */
PROCEDURE INV_UNIT_NUMBER_INQUIRIES (
               x_unit_inquiries       OUT NOCOPY t_genref,
               p_Organization_Id        IN  NUMBER,
               p_unit_number            IN  VARCHAR2  DEFAULT NULL,
               p_Inventory_Item_Id      IN  NUMBER    DEFAULT NULL,
               p_Revision               IN  VARCHAR2  DEFAULT NULL,
               p_Lot_Number             IN  VARCHAR2  DEFAULT NULL,
               p_Subinventory_Code      IN  VARCHAR2  DEFAULT NULL,
               p_Locator_Id             IN  NUMBER    DEFAULT NULL,
               p_project_id             IN  NUMBER    DEFAULT NULL,
               p_task_id                IN  NUMBER    DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2) IS
BEGIN
      OPEN x_unit_inquiries FOR
      SELECT  msik.concatenated_segments, -- Item Concatenated Segments
              msn.revision,
              msik.description,
              msn.current_subinventory_code,
              msn.current_locator_id,
              INV_PROJECT.GET_LOCSEGS(msn.current_locator_id,
                      p_organization_id) concatenated_segments, --Locator Segments
              msn.lot_number,
              msik.primary_uom_code,
              count(msn.serial_number) total_qty,
              inv_item_inq.get_status_code(msub.status_id) sub_status,
              inv_item_inq.get_status_code(milk.status_id) loc_status,
              inv_item_inq.get_status_code(mln.status_id) lot_status,
              msik.serial_number_control_code,
              msn.cost_group_id,
              INV_PROJECT.GET_PROJECT_NUMBER project_number,
              INV_PROJECT.GET_TASK_NUMBER task_number
      FROM    MTL_SERIAL_NUMBERS msn,
              MTL_SYSTEM_ITEMS_VL msik, /* Bug 5581528 */
              MTL_ITEM_LOCATIONS milk,
              MTL_SECONDARY_INVENTORIES msub,
              MTL_LOT_NUMBERS mln
      WHERE   msn.inventory_item_id         = p_Inventory_Item_Id
      AND    milk.organization_id(+) = msn.current_organization_id
      AND     milk.subinventory_code(+) = msn.current_subinventory_code
      AND     milk.inventory_location_id(+) = msn.current_locator_id
            AND     msn.inventory_item_id         = msik.inventory_item_id
      AND     msn.current_organization_id   = msik.organization_id
      AND     msik.organization_id   = p_Organization_Id
      AND     msn.current_organization_id = msub.organization_id(+)
      AND     msn.current_subinventory_code = msub.secondary_inventory_name(+)
      AND     msn.current_organization_id = mln.organization_id(+)
      AND     msn.lot_number = mln.lot_number(+)
      -- Bug 4301817 Not check mtl_transactions_enabled_flag to query non-transactable items
      -- AND     msik.mtl_transactions_enabled_flag = 'Y'
      AND     nvl(msn.end_item_unit_number, '$@#$%') =
              decode(p_unit_number, NULL, nvl(msn.end_item_unit_number, '$@#$%'), p_unit_number)
      AND     nvl(msn.revision, '!@#$%^&') =
                decode(p_Revision, NULL, nvl(msn.revision, '!@#$%^&'), p_Revision)
      AND     nvl(msn.current_subinventory_code, '!@#$%^&') =
                decode(p_Subinventory_Code, NULL, nvl(msn.current_subinventory_code, '!@#$%^&'), p_Subinventory_Code)
      AND     nvl(msn.current_locator_id, 99999999) =
                decode(p_Locator_Id, NULL, nvl(msn.current_locator_id, 99999999), p_Locator_Id)
      AND     nvl(msn.lot_number, '!@#$%^&') =
                decode(p_Lot_Number, NULL, nvl(msn.lot_number, '!@#$%^&'), p_Lot_Number)
      AND     NVL(milk.project_id, -9999) = NVL(p_project_id, NVL(milk.project_id, -9999))
      AND     NVL(milk.task_id, -9999) = NVL(p_task_id, NVL(milk.task_id, -9999))
      GROUP BY msn.current_organization_id,
               msn.inventory_item_id,
               msn.revision,
               msik.concatenated_segments,
               msn.revision,
               msik.description,
               msn.current_subinventory_code,
               msn.current_locator_id,
               INV_PROJECT.GET_LOCSEGS(msn.current_locator_id,p_organization_id),
               msn.lot_number,
               msik.primary_uom_code,
               inv_item_inq.get_status_code(msub.status_id),
              inv_item_inq.get_status_code(milk.status_id),
              inv_item_inq.get_status_code(mln.status_id),
              msik.serial_number_control_code,
              msn.cost_group_id,
              INV_PROJECT.GET_PROJECT_NUMBER,
              INV_PROJECT.GET_TASK_NUMBER;

     x_status := 'C';
     x_message := 'Records found';
EXCEPTION
    when others then
        x_status := 'E';
        x_message := substr(SQLERRM,1,240);
END INV_UNIT_NUMBER_INQUIRIES;

--Item Inquiry based on project, task and unit number for WMS orgs
PROCEDURE WMS_UNIT_NUMBER_INQUIRIES (
               x_unit_inquiries         OUT NOCOPY t_genref,
               p_Organization_Id        IN  NUMBER,
               p_unit_number            IN  VARCHAR2 DEFAULT NULL,
               p_Inventory_Item_Id      IN  NUMBER   DEFAULT NULL,
               p_Revision               IN  VARCHAR2 DEFAULT NULL,
               p_Lot_Number             IN  VARCHAR2 DEFAULT NULL,
               p_Subinventory_Code      IN  VARCHAR2 DEFAULT NULL,
               p_Locator_Id             IN  NUMBER   DEFAULT NULL,
               p_cost_Group_id          IN  NUMBER   DEFAULT NULL,
               p_project_id             IN  NUMBER   DEFAULT NULL,
               p_task_id                IN  NUMBER   DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2) IS
BEGIN
   OPEN x_unit_inquiries FOR
         SELECT b.msik_concatenated_segments,
               b.revision,
               b.description,
               b.subinventory_code,
               b.subinventory_status_id,
               b.subinventory_status,
               b.locator_id,
               b.milk_concatenated_segments,
               b.locator_status_id,
               b.locator_status,
               b.cost_group_id,
               b.cost_group,
               b.lot_number,
               b.lot_status_id,
               b.lot_status,
               b.primary_uom_code,
               b.total_qty,
               b.loose_qty,
               b.serial_number_control_code,
               b.project_number,
               b.task_number
         FROM
         (SELECT msn.current_organization_id organization_id,
           msn.inventory_item_id inventory_item_id,
           msik.concatenated_segments msik_concatenated_segments,
           msn.revision revision,
           msik.description description,
           msn.current_subinventory_code subinventory_code,
           msub.status_id subinventory_status_id,
           mms1.status_code subinventory_status,
           msn.current_locator_id locator_id,
           INV_PROJECT.GET_LOCSEGS(msn.current_locator_id,
                   p_organization_id) milk_concatenated_segments,  --Physical Locator Segements
           milk.status_id locator_status_id,
           mms2.status_code locator_status,
           msn.cost_group_id cost_group_id,
           csg.cost_group cost_group,
           msn.lot_number lot_number,
           mlot.status_id lot_status_id,
           mms3.status_code lot_status,
           msik.primary_uom_code primary_uom_code,
           count(msn.serial_number) total_qty,
           count(decode(msn.lpn_id, null,1)) loose_qty,
           msik.lot_control_code lot_control_code,
           msik.serial_number_control_code serial_number_control_code,
                     INV_PROJECT.GET_PROJECT_NUMBER project_number,
                     INV_PROJECT.GET_TASK_NUMBER task_number
       FROM  mtl_serial_numbers msn,
             mtl_system_items_vl msik, /* Bug 5581528 */
             mtl_item_locations milk,
             mtl_secondary_inventories msub,
             mtl_lot_numbers mlot,
             mtl_material_statuses_vl mms1,
             mtl_material_statuses_vl mms2,
             mtl_material_statuses_vl mms3,
             cst_cost_groups csg
       WHERE msn.current_organization_id = msik.organization_id
       AND   msn.current_organization_id  = p_Organization_Id
       AND   msn.inventory_item_id     = p_inventory_item_id
       AND   msn.inventory_item_id = msik.inventory_item_id
       AND     nvl(msn.end_item_unit_number, '$@#$%') =
              decode(p_unit_number, NULL, nvl(msn.end_item_unit_number, '$@#$%'), p_unit_number)
       AND   msn.current_organization_id = msub.organization_id
       AND   msn.current_subinventory_code = msub.secondary_inventory_name(+)
       AND   msub.status_id = mms1.status_id(+)
       AND   msn.current_organization_id = milk.organization_id
       AND   msn.current_locator_id = milk.inventory_location_id(+)
       aND   milk.status_id = mms2.status_id(+)
       AND   msn.current_subinventory_code = milk.subinventory_code(+)
       AND   msn.lot_number = mlot.lot_number(+)
       AND   msn.inventory_item_id = mlot.inventory_item_id(+)
       AND   msn.current_organization_id = mlot.organization_id(+)
       AND   mlot.status_id = mms3.status_id(+)
       AND   msn.cost_group_id = csg.cost_group_id(+)
       -- Bug 4301817 Not check mtl_transactions_enabled_flag to query non-transactable items
       -- AND   msik.mtl_transactions_enabled_flag = 'Y'
       AND   nvl(msn.revision, '!@#$%^&') =
          decode(p_Revision, NULL, nvl(msn.revision, '!@#$%^&'), p_Revision)
       AND   nvl(msn.lot_number, '!@#$%^&') =
            decode (p_Lot_Number, NULL, nvl(msn.lot_number, '!@#$%^&'), p_Lot_Number)
       AND   nvl(msn.current_subinventory_code, '!@#$%^&') =
            decode (p_Subinventory_Code, NULL, nvl(msn.current_subinventory_code, '!@#$%^&'), p_Subinventory_Code)
       AND   nvl(msn.current_locator_id, 0) =
            decode(p_Locator_Id, NULL, nvl(msn.current_locator_id, 0), p_Locator_Id)
       AND   nvl(msn.cost_group_id, 0) =
            decode(p_cost_group_id, NULL, nvl(msn.cost_group_id, 0), p_cost_group_id)
       AND  NVL(milk.project_id, -9999) = NVL(p_project_id, NVL(milk.project_id, -9999))
       AND  NVL(milk.task_id, -9999) = NVL(p_task_id, NVL(milk.task_id, -9999))
       GROUP BY msn.current_organization_id,
           msn.inventory_item_id,
           msik.concatenated_segments,
           msn.revision,
           msik.description,
           msn.current_subinventory_code,
           msub.status_id,
           mms1.status_code,
           msn.current_locator_id,
           INV_PROJECT.GET_LOCSEGS(msn.current_locator_id,p_organization_id),
           milk.status_id,
           mms2.status_code,
           msn.cost_group_id,
           csg.cost_group,
           msn.lot_number,
           mlot.status_id,
           mms3.status_code,
           msik.primary_uom_code,
           msik.lot_control_code,
           msik.serial_number_control_code,
           INV_PROJECT.GET_PROJECT_NUMBER,
           INV_PROJECT.GET_TASK_NUMBER) b;

        x_status := 'C';
        x_message := 'Records found';
EXCEPTION
    when others then
        x_status := 'E';
        x_message := substr(SQLERRM,1,240);
END WMS_UNIT_NUMBER_INQUIRIES;

--changes for walkup loc project


/*******************************************************************
 * Obtain onhand information WMS org, provide cost group
 * information query wms related information
 * Overloaded to include filtering on project and task
 *******************************************************************
 */
PROCEDURE WMS_LOOSE_ITEM_INQUIRIES (
          x_item_inquiries    OUT NOCOPY t_genref,
          p_organization_id   IN  NUMBER,
          p_inventory_item_id IN  NUMBER   DEFAULT NULL,
          p_subinventory_code IN  VARCHAR2 DEFAULT NULL,
          p_locator_id        IN  NUMBER   DEFAULT NULL,
          x_status            OUT NOCOPY VARCHAR2,
          x_message           OUT NOCOPY VARCHAR2) IS
BEGIN
   OPEN x_item_inquiries FOR

    SELECT b.msik_concatenated_segments,
               NULL,--b.revision,
               b.description,
               b.subinventory_code,
               b.subinventory_status_id,
               b.subinventory_status,
               b.locator_id,
               b.milk_concatenated_segments,
               b.locator_status_id,
               b.locator_status,
               NULL,--b.cost_group_id,
               NULL,--b.cost_group,
               NULL,--b.lot_number,
               NULL,--b.lot_status_id,
               NULL,--b.lot_status,
               b.primary_uom_code,
               b.sum_txn_qty,
               inv_item_inq.get_available_qty(
                          b.organization_id,
                          b.inventory_item_id,
                          NULL,--b.revision,
                          b.subinventory_code,
                          b.locator_id,
                          NULL,--b.lot_number,
                          NULL,--b.cost_group_id
                          'FALSE',
                          decode(b.lot_control_code, 2, 'TRUE', 'FALSE'),
                          decode(b.serial_number_control_code, NULL, 'FALSE', 1, 'FALSE', 'TRUE')) ,
     inv_item_inq.get_packed_quantity(
                      b.organization_id,
                      b.inventory_item_id,
                      NULL,--b.revision,
                      b.subinventory_code,
                      b.locator_id,
                      NULL,--b.lot_number,
                      NULL--b.cost_Group_id
                      ) ,
     inv_item_inq.get_loose_quantity(
                     b.organization_id,
                     b.inventory_item_id,
                     NULL,--b.revision,
                     b.subinventory_code,
                     b.locator_id,
                     NULL,--b.lot_number,
                     NULL--b.cost_Group_id
                     ),
     b.serial_number_control_code,
     NULL,--b.project_number,
     NULL,--b.task_number
     b.inventory_item_id
     FROM
     (SELECT moq.organization_id organization_id,
      moq.inventory_item_id inventory_item_id,
      msik.concatenated_segments msik_concatenated_segments,
      msik.description description,
      moq.subinventory_code subinventory_code,
      msub.status_id subinventory_status_id,
      mms1.status_code subinventory_status,
      moq.locator_id locator_id,
      INV_PROJECT.GET_LOCSEGS(moq.locator_id,
                  p_organization_id) milk_concatenated_segments,  --Physical Locator Segements
      milk.status_id locator_status_id,
      mms2.status_code locator_status,
      msik.primary_uom_code primary_uom_code,
      sum(nvl(moq.primary_transaction_quantity, 0)) sum_txn_qty,
      msik.lot_control_code lot_control_code,
      msik.serial_number_control_code serial_number_control_code
       FROM  mtl_onhand_quantities_detail moq,
             mtl_system_items_vl msik, /* Bug 5581528 */
             mtl_item_locations milk,
             mtl_secondary_inventories msub,
             mtl_material_statuses_vl mms1,
             mtl_material_statuses_vl mms2
       WHERE moq.organization_id = msik.organization_id
       AND   moq.inventory_item_id = msik.inventory_item_id
       AND   moq.organization_id = msub.organization_id
       AND   moq.subinventory_code = msub.secondary_inventory_name(+)
       AND   msub.status_id = mms1.status_id(+)
       AND   moq.organization_id = milk.organization_id
       AND   moq.locator_id = milk.inventory_location_id(+)
       AND   milk.status_id = mms2.status_id(+)
       AND   moq.subinventory_code = milk.subinventory_code(+)
       AND   moq.organization_id        = p_Organization_Id
       AND   moq.inventory_item_id     =
             decode (p_Inventory_Item_Id, NULL, moq.inventory_item_id, p_Inventory_Item_Id)
       -- Bug 4301817 Not check mtl_transactions_enabled_flag to query non-transactable items
       -- AND   msik.mtl_transactions_enabled_flag = 'Y'
       AND   nvl(moq.subinventory_code, '!@#$%^&') =
            decode (p_Subinventory_Code, NULL, nvl(moq.subinventory_code, '!@#$%^&'), p_Subinventory_Code)
       AND   nvl(moq.locator_id, 0) =
            decode(p_Locator_Id, NULL, nvl(moq.locator_id, 0), p_Locator_Id)
       GROUP BY moq.organization_id,
           moq.inventory_item_id,
           msik.concatenated_segments,
           msik.description,
           moq.subinventory_code,
           msub.status_id,
           mms1.status_code,
           moq.locator_id,
           INV_PROJECT.GET_LOCSEGS(moq.locator_id,p_organization_id),
           milk.status_id,
           mms2.status_code,
           msik.primary_uom_code,
           msik.lot_control_code,
     msik.serial_number_control_code
     ) b;

       x_status := 'C';
       x_message := 'Records found';
EXCEPTION
     when others then
        x_status := 'E';
        x_message := SUBSTR (SQLERRM , 1 , 240);
END WMS_LOOSE_ITEM_INQUIRIES;







END inv_ITEM_INQ;

/
