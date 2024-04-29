--------------------------------------------------------
--  DDL for Package Body INV_PHY_INV_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PHY_INV_LOVS" AS
/* $Header: INVPINLB.pls 120.7.12010000.9 2009/10/29 00:59:03 kbavadek ship $ */

--  Global constant holding the package name
G_PKG_NAME               CONSTANT VARCHAR2(30) := 'INV_PHY_INV_LOVS';

PROCEDURE print_debug(p_err_msg VARCHAR2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog
     (p_err_msg   =>  p_err_msg,
      p_module    =>  'INV_PHY_INV_LOVS',
      p_level     =>  4);
   END IF;

--   dbms_output.put_line(p_err_msg);
END print_debug;


--      Name: GET_PHY_INV_LOV
--
--      Input parameters:
--       p_lpn   which restricts LOV SQL to the user input text
--       p_organization_id   Organization ID
--
--      Output parameters:
--       x_phy_inv_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid physical inventories
--
PROCEDURE get_phy_inv_lov
  (x_phy_inv_lov       OUT  NOCOPY  t_genref,
   p_phy_inv           IN           VARCHAR2,
   p_organization_id   IN           NUMBER)

IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   OPEN x_phy_inv_lov FOR
     SELECT physical_inventory_name,
     physical_inventory_id,
     description,
     freeze_date,
     adjustments_posted,
     approval_required,
     cost_variance_neg,
     cost_variance_pos,
     approval_tolerance_neg,
     approval_tolerance_pos,
     all_subinventories_flag,
     dynamic_tag_entry_flag
     FROM mtl_physical_inventories_v
     WHERE organization_id = p_organization_id
     AND snapshot_complete = 1
     AND adjustments_posted <> 1
     AND physical_inventory_name LIKE (p_phy_inv)
     ORDER BY physical_inventory_name;
END get_phy_inv_lov;


--      Name: GET_SERIAL_COUNT_NUMBER
--
--      Input parameters:
--       p_physical_inventory_id    Physical Inventory ID
--       p_organization_id          Organization ID
--       p_serial_number            Serial Number
--       p_inventory_item_id        Inventory Item ID
--
--      Output parameters:
--       x_number            Returns the serial count for the number
--                           of physical tags with that particular
--                           serial number that has already been counted
--                           as present and existing in a given location.
--       x_serial_in_scope   Returns 1 if the serial is within the scope
--                           of the physical inventory.  Otherwise it will
--                           return 0.
--
--      Functions: This API returns the count of physical tag records
--                 for the given serial number inputted.
--                 It has also been overloaded so that it will also
--                 check if the inputted serial is within the scope
--                 of the physical inventory, i.e. exists in a subinventory
--                 for which the physical inventory covers
--
PROCEDURE get_serial_count_number
  (p_physical_inventory_id   IN          NUMBER            ,
   p_organization_id         IN          NUMBER            ,
   p_serial_number           IN          VARCHAR2          ,
   p_inventory_item_id       IN          NUMBER            ,
   x_number                  OUT NOCOPY  NUMBER            ,
   x_serial_in_scope         OUT NOCOPY  NUMBER)
IS
l_all_sub_flag               NUMBER;
l_serial_sub                 VARCHAR2(10);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling get_serial_count_number***');
   END IF;
   -- First get the serial count number to see if the serial has
   -- already been found for this physical inventory
   SELECT COUNT(*)
     INTO x_number
     FROM mtl_physical_inventory_tags
     WHERE physical_inventory_id = p_physical_inventory_id
     AND organization_id = p_organization_id
     AND serial_num = p_serial_number
     AND inventory_item_id = p_inventory_item_id
     AND tag_quantity IS NOT NULL
     AND tag_quantity <> 0
     AND void_flag = 2
     AND adjustment_id IN
     (SELECT adjustment_id
      FROM mtl_physical_adjustments
      WHERE physical_inventory_id = p_physical_inventory_id
      AND organization_id = p_organization_id
      AND approval_status IS NULL);

      -- Now see if the serial is within the scope of the physical
      -- inventory
      SELECT all_subinventories_flag
        INTO l_all_sub_flag
        FROM mtl_physical_inventories
        WHERE physical_inventory_id = p_physical_inventory_id
        AND organization_id = p_organization_id;
      IF (l_debug = 1) THEN
         print_debug('All subinventories flag: ' || l_all_sub_flag);
      END IF;

      IF (l_all_sub_flag = 1) THEN
         -- All subinventories are included for this physical inventory
         -- so the serial should be within the scope
         x_serial_in_scope := 1;
       ELSE
         -- Get the current sub where the serial resides according to the system
         SELECT NVL(current_subinventory_code, '@@@@@')
           INTO l_serial_sub
           FROM mtl_serial_numbers
           WHERE inventory_item_id = p_inventory_item_id
           AND serial_number = p_serial_number
           AND current_organization_id = p_organization_id;
         IF (l_debug = 1) THEN
         print_debug('Current subinventory of serial: ' || l_serial_sub);
         END IF;
         -- See if the serial's subinventory is one of the subinventories
         -- associated with the physical inventory
         SELECT COUNT(*)
           INTO x_serial_in_scope
           FROM mtl_physical_subinventories
           WHERE organization_id = p_organization_id
           AND physical_inventory_id = p_physical_inventory_id
           AND subinventory = l_serial_sub;
      END IF;
      IF (l_debug = 1) THEN
         print_debug('Serial count number: ' || x_number);
         print_debug('Serial in scope: ' || x_serial_in_scope);
      END IF;

END get_serial_count_number;


PROCEDURE process_tag
  (p_physical_inventory_id   IN    NUMBER,
   p_organization_id         IN    NUMBER,
   p_subinventory            IN    VARCHAR2,
   p_locator_id              IN    NUMBER := NULL,
   p_parent_lpn_id           IN    NUMBER := NULL,
   p_inventory_item_id       IN    NUMBER,
   p_revision                IN    VARCHAR2 := NULL,
   p_lot_number              IN    VARCHAR2 := NULL,
   p_from_serial_number      IN    VARCHAR2 := NULL,
   p_to_serial_number        IN    VARCHAR2 := NULL,
   p_tag_quantity            IN    NUMBER,
   p_tag_uom                 IN    VARCHAR2,
   p_dynamic_tag_entry_flag  IN    NUMBER,
   p_user_id                 IN    NUMBER,
   p_cost_group_id           IN    NUMBER := NULL
   --INVCONV, NSRIVAST, START
   ,p_tag_sec_uom            IN    VARCHAR2 := NULL
   ,p_tag_sec_quantity       IN    NUMBER   := NULL
   --INVCONV, NSRIVAST, END
   )
IS
l_current_serial         VARCHAR2(30);
CURSOR tag_entry IS
   SELECT *
     FROM mtl_physical_inventory_tags
     WHERE physical_inventory_id = p_physical_inventory_id
     AND organization_id = p_organization_id
     AND subinventory = p_subinventory
     AND NVL(locator_id, -99999) = NVL(p_locator_id, -99999)
     AND NVL(parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
     AND inventory_item_id = p_inventory_item_id
     AND NVL(revision, '@@@@@') = NVL(p_revision, '@@@@@')
     AND NVL(lot_number, '@@@@@') = NVL(p_lot_number, '@@@@@')
     AND NVL(serial_num, '@@@@@') = NVL(l_current_serial, '@@@@@')
     -- AND NVL(cost_group_id, -99999) = NVL(p_cost_group_id, -99999)
     AND void_flag = 2
     AND adjustment_id IN
     (SELECT adjustment_id
      FROM mtl_physical_adjustments
      WHERE physical_inventory_id = p_physical_inventory_id
      AND organization_id = p_organization_id
      AND approval_status IS NULL);
CURSOR discrepant_serial_cursor IS
   SELECT *
     FROM mtl_physical_inventory_tags
     WHERE physical_inventory_id = p_physical_inventory_id
     AND organization_id = p_organization_id
     AND NVL(parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
     AND inventory_item_id = p_inventory_item_id
     AND NVL(revision, '@@@@@') = NVL(p_revision, '@@@@@')
     AND NVL(lot_number, '@@@@@') = NVL(p_lot_number, '@@@@@')
     AND NVL(serial_num, '@@@@@') = NVL(l_current_serial, '@@@@@')
     -- AND NVL(cost_group_id, -99999) = NVL(p_cost_group_id, -99999)
     AND void_flag = 2
     AND adjustment_id IN
     (SELECT adjustment_id
      FROM mtl_physical_adjustments
      WHERE physical_inventory_id = p_physical_inventory_id
      AND organization_id = p_organization_id
      AND approval_status IS NULL);
tag_record               MTL_PHYSICAL_INVENTORY_TAGS%ROWTYPE;
l_prefix                 VARCHAR2(30);
l_quantity               NUMBER;
l_from_number            NUMBER;
l_to_number              NUMBER;
l_errorcode              NUMBER;
l_length                 NUMBER;
l_padded_length          NUMBER;
l_current_number         NUMBER;
l_adjustment_id          NUMBER;
l_cost_group_id          NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling process_tag with the following parameters***');
      print_debug('p_physical_inventory_id: ---> ' || p_physical_inventory_id);
      print_debug('p_organization_id: ---------> ' || p_organization_id);
      print_debug('p_subinventory: ------------> ' || p_subinventory);
      print_debug('p_locator_id: --------------> ' || p_locator_id);
      print_debug('p_parent_lpn_id: -----------> ' || p_parent_lpn_id);
      print_debug('p_inventory_item_id: -------> ' || p_inventory_item_id);
      print_debug('p_revision: ----------------> ' || p_revision);
      print_debug('p_lot_number: --------------> ' || p_lot_number);
      print_debug('p_from_serial_number: ------> ' || p_from_serial_number);
      print_debug('p_to_serial_number: --------> ' || p_to_serial_number);
      print_debug('p_tag_quantity: ------------> ' || p_tag_quantity);
      print_debug('p_tag_uom: -----------------> ' || p_tag_uom);
      print_debug('p_dynamic_tag_entry_flag: --> ' || p_dynamic_tag_entry_flag);
      print_debug('p_user_id: -----------------> ' || p_user_id);
      print_debug('p_cost_group_id: -----------> ' || p_cost_group_id);
   END IF;

   -- First check if the tag item is a serial controlled item
   IF ((p_from_serial_number IS NOT NULL) AND
       (p_to_serial_number IS NOT NULL)) THEN
      IF (l_debug = 1) THEN
         print_debug('Serial controlled item');
      END IF;

      -- Call this API to parse the serial numbers into prefixes and numbers.
      -- Only call this procedure if the from and to serial numbers differ
      IF (p_from_serial_number <> p_to_serial_number) THEN
         IF (NOT MTL_Serial_Check.inv_serial_info
             ( p_from_serial_number  =>  p_from_serial_number,
               p_to_serial_number    =>  p_to_serial_number,
               x_prefix              =>  l_prefix,
               x_quantity            =>  l_quantity,
               x_from_number         =>  l_from_number,
               x_to_number           =>  l_to_number,
               x_errorcode           =>  l_errorcode)) THEN
            FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SER');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      -- Check that in the case of a range of serial numbers, that the
      -- inputted p_tag_quantity equals the amount of items in the serial
      -- range.  Do this check only if a range of serials is submitted
      IF (p_from_serial_number <> p_to_serial_number) THEN
         IF (p_tag_quantity <> l_quantity) THEN
            FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_X_QTY');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      -- Get the serial number length.
      -- Note that the from and to serial numbers must be of the same length.
      l_length := length(p_from_serial_number);

      -- Initialize the current pointer variables
      l_current_serial := p_from_serial_number;
      IF (l_from_number IS NOT NULL) THEN
         l_current_number := l_from_number;
       ELSE
         l_current_number := 0;
      END IF;

      LOOP
         -- For each serial number check if a tag entry for it already
         -- exists or not
         OPEN tag_entry;
         FETCH tag_entry INTO tag_record;
         IF (tag_entry%FOUND) THEN
            -- Entry already exists so update the row
            -- Check if an adjustment ID for this tag already exists or not
            IF (tag_record.adjustment_id IS NULL) THEN
               find_existing_adjustment
                 ( p_physical_inventory_id   =>  p_physical_inventory_id,
                   p_organization_id         =>  p_organization_id,
                   p_subinventory            =>  p_subinventory,
                   p_locator_id              =>  p_locator_id,
                   p_parent_lpn_id           =>  p_parent_lpn_id,
                   p_inventory_item_id       =>  p_inventory_item_id,
                   p_revision                =>  p_revision,
                   p_lot_number              =>  p_lot_number,
                   p_serial_number           =>  l_current_serial,
                   p_user_id                 =>  p_user_id,
                   p_cost_group_id           =>  tag_record.cost_group_id,
                   x_adjustment_id           =>  l_adjustment_id
                   );
             ELSE
               l_adjustment_id := tag_record.adjustment_id;
            END IF;
            update_row( p_tag_id                  =>  tag_record.tag_id,
                        p_physical_inventory_id   =>  p_physical_inventory_id,
                        p_organization_id         =>  p_organization_id,
                        p_subinventory            =>  p_subinventory,
                        p_locator_id              =>  p_locator_id,
                        p_parent_lpn_id           =>  p_parent_lpn_id,
                        p_inventory_item_id       =>  p_inventory_item_id,
                        p_revision                =>  p_revision,
                        p_lot_number              =>  p_lot_number,
                        p_serial_number           =>  l_current_serial,
                        p_tag_quantity            =>  p_tag_quantity,
                        p_tag_uom                 =>  p_tag_uom,
                        p_user_id                 =>  p_user_id,
                        p_cost_group_id           =>  tag_record.cost_group_id,
                        p_adjustment_id           =>  l_adjustment_id
                        );
            update_adjustment
              (p_adjustment_id           =>  l_adjustment_id,
               p_physical_inventory_id   =>  p_physical_inventory_id,
               p_organization_id         =>  p_organization_id,
               p_user_id                 =>  p_user_id
               );
          ELSE
            -- Entry does not exist so insert the row
            IF (p_dynamic_tag_entry_flag = 1) THEN
               IF (l_debug = 1) THEN
               print_debug('Dynamic serial tag entry to be inserted');
               END IF;
               -- Dynamic tag entries are allowed

               -- First check to see if a tag exists for this serial number
               -- already if the serial is found in a discrepant location.
               -- If a tag already exists, we want to update the tag and
               -- adjustment record to signify that we have counted it
               -- already, although it is considered as missing.
               OPEN discrepant_serial_cursor;
               FETCH discrepant_serial_cursor INTO tag_record;
               IF (discrepant_serial_cursor%FOUND) THEN
                  -- Entry for discrepant serial exists so update the row
                  -- Check if an adjustment ID for this tag already exists or not
                  IF (l_debug = 1) THEN
                  print_debug('Discrepant serial so updating the original tag');
                  END IF;
                  IF (tag_record.adjustment_id IS NULL) THEN
                     find_existing_adjustment
                       ( p_physical_inventory_id   =>  p_physical_inventory_id,
                         p_organization_id         =>  p_organization_id,
                         p_subinventory            =>  tag_record.subinventory,
                         p_locator_id              =>  tag_record.locator_id,
                         p_parent_lpn_id           =>  p_parent_lpn_id,
                         p_inventory_item_id       =>  p_inventory_item_id,
                         p_revision                =>  p_revision,
                         p_lot_number              =>  p_lot_number,
                         p_serial_number           =>  l_current_serial,
                         p_user_id                 =>  p_user_id,
                         p_cost_group_id           =>  tag_record.cost_group_id,
                         x_adjustment_id           =>  l_adjustment_id
                         );
                   ELSE
                     l_adjustment_id := tag_record.adjustment_id;
                  END IF;
                  update_row( p_tag_id                  =>  tag_record.tag_id,
                              p_physical_inventory_id   =>  p_physical_inventory_id,
                              p_organization_id         =>  p_organization_id,
                              p_subinventory            =>  tag_record.subinventory,
                              p_locator_id              =>  tag_record.locator_id,
                              p_parent_lpn_id           =>  p_parent_lpn_id,
                              p_inventory_item_id       =>  p_inventory_item_id,
                              p_revision                =>  p_revision,
                              p_lot_number              =>  p_lot_number,
                              p_serial_number           =>  l_current_serial,
                              p_tag_quantity            =>  0,
                              p_tag_uom                 =>  p_tag_uom,
                              p_user_id                 =>  p_user_id,
                              p_cost_group_id           =>  tag_record.cost_group_id,
                              p_adjustment_id           =>  l_adjustment_id
                              );
                  update_adjustment
                    (p_adjustment_id           =>  l_adjustment_id,
                     p_physical_inventory_id   =>  p_physical_inventory_id,
                     p_organization_id         =>  p_organization_id,
                     p_user_id                 =>  p_user_id
                     );
               END IF;
               CLOSE discrepant_serial_cursor;

               -- Now deal with inserting the new dynamic tag entry
               -- Get the cost group ID for this entry
               inv_cyc_lovs.get_cost_group_id
                 (p_organization_id        =>  p_organization_id,
                  p_subinventory           =>  p_subinventory,
                  p_locator_id             =>  p_locator_id,
                  p_parent_lpn_id          =>  p_parent_lpn_id,
                  p_inventory_item_id      =>  p_inventory_item_id,
                  p_revision               =>  p_revision,
                  p_lot_number             =>  p_lot_number,
                  p_serial_number          =>  l_current_serial,
                  x_out                    =>  l_cost_group_id);
               -- Bug# 2607187
               -- Do not get the default cost group ID.  If the item is
               -- new and does not exist in onhand, pass a NULL value
               -- for the cost group ID.  The transaction manager will
               -- call the cost group rules engine for that if the
               -- cost group ID passed into MMTT is null.
               IF (l_cost_group_id = -999) THEN
                  l_cost_group_id := NULL;
               END IF;
               -- Get the default cost group ID based on the given org
               -- and sub if cost group ID was not retrieved successfully
               /*IF (l_cost_group_id = -999) THEN
                  inv_cyc_lovs.get_default_cost_group_id
                    (p_organization_id        =>  p_organization_id,
                     p_subinventory           =>  p_subinventory,
                     x_out                    =>  l_cost_group_id);
               END IF;
               -- Default the cost group ID to 1 if nothing can be found
               IF (l_cost_group_id = -999) THEN
                  l_cost_group_id := 1;
               END IF;*/

               -- Generate a new adjustment ID for this tag
               find_existing_adjustment
                 ( p_physical_inventory_id   =>  p_physical_inventory_id,
                   p_organization_id         =>  p_organization_id,
                   p_subinventory            =>  p_subinventory,
                   p_locator_id              =>  p_locator_id,
                   p_parent_lpn_id           =>  p_parent_lpn_id,
                   p_inventory_item_id       =>  p_inventory_item_id,
                   p_revision                =>  p_revision,
                   p_lot_number              =>  p_lot_number,
                   p_serial_number           =>  l_current_serial,
                   p_user_id                 =>  p_user_id,
                   p_cost_group_id           =>  l_cost_group_id,
                   x_adjustment_id           =>  l_adjustment_id
                   );
               insert_row( p_physical_inventory_id   =>  p_physical_inventory_id,
                           p_organization_id         =>  p_organization_id,
                           p_subinventory            =>  p_subinventory,
                           p_locator_id              =>  p_locator_id,
                           p_parent_lpn_id           =>  p_parent_lpn_id,
                           p_inventory_item_id       =>  p_inventory_item_id,
                           p_revision                =>  p_revision,
                           p_lot_number              =>  p_lot_number,
                           p_serial_number           =>  l_current_serial,
                           p_tag_quantity            =>  p_tag_quantity,
                           p_tag_uom                 =>  p_tag_uom,
                           p_user_id                 =>  p_user_id,
                           p_cost_group_id           =>  l_cost_group_id,
                           p_adjustment_id           =>  l_adjustment_id
                           );
               update_adjustment
                 (p_adjustment_id           =>  l_adjustment_id,
                  p_physical_inventory_id   =>  p_physical_inventory_id,
                  p_organization_id         =>  p_organization_id,
                  p_user_id                 =>  p_user_id
                  );
             ELSE
               -- Dynamic tag entries are not allowed
               -- This shouldn't happen if the mobile form's LOV
               -- statements are correctly set
               FND_MESSAGE.SET_NAME('INV','INV_NO_DYNAMIC_TAGS');
               FND_MSG_PUB.ADD;
               --RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
         CLOSE tag_entry;

         EXIT WHEN l_current_serial = p_to_serial_number;
         -- Increment the current serial number if serial range inputted
         IF (p_from_serial_number <> p_to_serial_number) THEN
            l_current_number := l_current_number + 1;
            l_padded_length := l_length - length(l_current_number);
            l_current_serial := RPAD(l_prefix, l_padded_length, '0') ||
              l_current_number;
         END IF;
      END LOOP;

    ELSE -- Item is not serial controlled
      IF (l_debug = 1) THEN
         print_debug('Non-Serial controlled item');
      END IF;
      OPEN tag_entry;
      FETCH tag_entry INTO tag_record;
      IF (tag_entry%FOUND) THEN
         -- Check if an adjustment ID for this tag already exists or not
         IF (tag_record.adjustment_id IS NULL) THEN
            find_existing_adjustment
              ( p_physical_inventory_id   =>  p_physical_inventory_id,
                p_organization_id         =>  p_organization_id,
                p_subinventory            =>  p_subinventory,
                p_locator_id              =>  p_locator_id,
                p_parent_lpn_id           =>  p_parent_lpn_id,
                p_inventory_item_id       =>  p_inventory_item_id,
                p_revision                =>  p_revision,
                p_lot_number              =>  p_lot_number,
                p_serial_number           =>  NULL,
                p_user_id                 =>  p_user_id,
                p_cost_group_id           =>  tag_record.cost_group_id,
                x_adjustment_id           =>  l_adjustment_id
                );
          ELSE
            l_adjustment_id := tag_record.adjustment_id;
         END IF;
         update_row( p_tag_id                  =>  tag_record.tag_id,
                     p_physical_inventory_id   =>  p_physical_inventory_id,
                     p_organization_id         =>  p_organization_id,
                     p_subinventory            =>  p_subinventory,
                     p_locator_id              =>  p_locator_id,
                     p_parent_lpn_id           =>  p_parent_lpn_id,
                     p_inventory_item_id       =>  p_inventory_item_id,
                     p_revision                =>  p_revision,
                     p_lot_number              =>  p_lot_number,
                     p_serial_number           =>  NULL,
                     p_tag_quantity            =>  p_tag_quantity,
                     p_tag_uom                 =>  p_tag_uom,
                     p_user_id                 =>  p_user_id,
                     p_cost_group_id           =>  tag_record.cost_group_id,
                     p_adjustment_id           =>  l_adjustment_id
                    ,p_tag_sec_quantity        =>  p_tag_sec_quantity    --INVCONV, NSRIVAST
                     );
         update_adjustment
           (p_adjustment_id           =>  l_adjustment_id,
            p_physical_inventory_id   =>  p_physical_inventory_id,
            p_organization_id         =>  p_organization_id,
            p_user_id                 =>  p_user_id
            );
       ELSE
         IF (p_dynamic_tag_entry_flag = 1) THEN
            IF (l_debug = 1) THEN
            print_debug('Dynamic non-serial tag entry to be inserted');
            END IF;
            -- Dynamic tag entries are allowed

            -- Get the cost group ID for this entry
            inv_cyc_lovs.get_cost_group_id
              (p_organization_id        =>  p_organization_id,
               p_subinventory           =>  p_subinventory,
               p_locator_id             =>  p_locator_id,
               p_parent_lpn_id          =>  p_parent_lpn_id,
               p_inventory_item_id      =>  p_inventory_item_id,
               p_revision               =>  p_revision,
               p_lot_number             =>  p_lot_number,
               p_serial_number          =>  l_current_serial,
               x_out                    =>  l_cost_group_id);
            -- Bug# 2607187
            -- Do not get the default cost group ID.  If the item is
            -- new and does not exist in onhand, pass a NULL value
            -- for the cost group ID.  The transaction manager will
            -- call the cost group rules engine for that if the
            -- cost group ID passed into MMTT is null.
            IF (l_cost_group_id = -999) THEN
               l_cost_group_id := NULL;
            END IF;
            -- Get the default cost group ID based on the given org
            -- and sub if cost group ID was not retrieved successfully
            /*IF (l_cost_group_id = -999) THEN
               inv_cyc_lovs.get_default_cost_group_id
                 (p_organization_id        =>  p_organization_id,
                  p_subinventory           =>  p_subinventory,
                  x_out                    =>  l_cost_group_id);
            END IF;
            -- Default the cost group ID to 1 if nothing can be found
            IF (l_cost_group_id = -999) THEN
               l_cost_group_id := 1;
            END IF;*/

            -- Generate a new adjustment ID for this tag
            find_existing_adjustment
              ( p_physical_inventory_id   =>  p_physical_inventory_id,
                p_organization_id         =>  p_organization_id,
                p_subinventory            =>  p_subinventory,
                p_locator_id              =>  p_locator_id,
                p_parent_lpn_id           =>  p_parent_lpn_id,
                p_inventory_item_id       =>  p_inventory_item_id,
                p_revision                =>  p_revision,
                p_lot_number              =>  p_lot_number,
                p_serial_number           =>  NULL,
                p_user_id                 =>  p_user_id,
                p_cost_group_id           =>  l_cost_group_id,
                x_adjustment_id           =>  l_adjustment_id
                );
            insert_row( p_physical_inventory_id   =>  p_physical_inventory_id,
                        p_organization_id         =>  p_organization_id,
                        p_subinventory            =>  p_subinventory,
                        p_locator_id              =>  p_locator_id,
                        p_parent_lpn_id           =>  p_parent_lpn_id,
                        p_inventory_item_id       =>  p_inventory_item_id,
                        p_revision                =>  p_revision,
                        p_lot_number              =>  p_lot_number,
                        p_serial_number           =>  NULL,
                        p_tag_quantity            =>  p_tag_quantity,
                        p_tag_uom                 =>  p_tag_uom,
                        p_user_id                 =>  p_user_id,
                        p_cost_group_id           =>  l_cost_group_id,
                        p_adjustment_id           =>  l_adjustment_id
                        --INVCONV, NSRIVAST, START
                        ,p_tag_sec_quantity       =>    p_tag_sec_quantity
                        ,p_tag_sec_uom            =>    p_tag_sec_uom
                        --INVCONV, NSRIVAST, END

                        );
            update_adjustment
              (p_adjustment_id           =>  l_adjustment_id,
               p_physical_inventory_id   =>  p_physical_inventory_id,
               p_organization_id         =>  p_organization_id,
               p_user_id                 =>  p_user_id
               );
          ELSE
            -- Dynamic tag entries are not allowed
            -- This shouldn't happen if the mobile form's LOV
            -- statements are correctly set
            FND_MESSAGE.SET_NAME('INV','INV_NO_DYNAMIC_TAGS');
            FND_MSG_PUB.ADD;
            --RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   END IF;

END process_tag;


PROCEDURE insert_row
  (p_physical_inventory_id   IN    NUMBER,
   p_organization_id         IN    NUMBER,
   p_subinventory            IN    VARCHAR2,
   p_locator_id              IN    NUMBER,
   p_parent_lpn_id           IN    NUMBER,
   p_inventory_item_id       IN    NUMBER,
   p_revision                IN    VARCHAR2,
   p_lot_number              IN    VARCHAR2,
   p_serial_number           IN    VARCHAR2,
   p_tag_quantity            IN    NUMBER,
   p_tag_uom                 IN    VARCHAR2,
   p_user_id                 IN    NUMBER,
   p_cost_group_id           IN    NUMBER,
   p_adjustment_id           IN    NUMBER
   --INVCONV, NSRIVAST, START
   ,p_tag_sec_quantity       IN    NUMBER   := NULL
   ,p_tag_sec_uom            IN    VARCHAR2 := NULL
   --INVCONV, NSRIVAST, END
   )
IS
l_tag_id                        NUMBER;
l_tag_number                    VARCHAR2(40);
l_next_tag_number               VARCHAR2(40);
l_tag_qty_at_standard_uom       NUMBER;
l_outermost_lpn_id              NUMBER;
l_lot_expiration_date           Date; /* Bug8199582 */
CURSOR tag_number_cursor IS
   SELECT next_tag_number
     FROM mtl_physical_inventories
     WHERE physical_inventory_id = p_physical_inventory_id
     AND organization_id = p_organization_id;
l_return_status                 VARCHAR2(300);
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(300);
l_lpn_list                      WMS_Container_PUB.LPN_Table_Type;
l_temp_bool                     BOOLEAN;
l_prefix                        VARCHAR2(30);
l_quantity                      NUMBER;
l_from_number                   NUMBER;
l_to_number                     NUMBER;
l_errorcode                     NUMBER;
l_length                        NUMBER;
l_padded_length                 NUMBER;
l_item_standard_uom             VARCHAR2(3);
l_employee_id                   NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('***insert_row***');
   END IF;
   -- Get the next tag ID for this new record
   SELECT mtl_physical_inventory_tags_s.nextval
     INTO l_tag_id
     FROM dual;
   IF (l_debug = 1) THEN
      print_debug('Dynamic tag ID: ' || l_tag_id);
   END IF;

   -- Generate a new tag number for this record
   OPEN tag_number_cursor;
   FETCH tag_number_cursor INTO l_tag_number;
   IF tag_number_cursor%NOTFOUND THEN
      -- No value set for next_tag_number so manually
      -- generate the next sequence value
      SELECT MAX(tag_number)
        INTO l_tag_number
        FROM mtl_physical_inventory_tags
        WHERE physical_inventory_id = p_physical_inventory_id
        AND organization_id = p_organization_id;
      -- Now parse the tag number and increment the numerical part
      l_temp_bool := MTL_Serial_Check.inv_serial_info
        ( p_from_serial_number  =>  l_tag_number,
          p_to_serial_number    =>  NULL,
          x_prefix              =>  l_prefix,
          x_quantity            =>  l_quantity,
          x_from_number         =>  l_from_number,
          x_to_number           =>  l_to_number,
          x_errorcode           =>  l_errorcode);
      l_length := length(l_tag_number);
      l_from_number := l_from_number + 1;
      l_padded_length := l_length - length(l_from_number);
      l_tag_number := RPAD(l_prefix, l_padded_length, '0') ||
        l_from_number;
   END IF;
   CLOSE tag_number_cursor;

   -- Update the next_tag_number column in the physical inventories table
   -- since we have just generated a new tag number value here
   l_temp_bool := MTL_Serial_Check.inv_serial_info
     ( p_from_serial_number  =>  l_tag_number,
       p_to_serial_number    =>  NULL,
       x_prefix              =>  l_prefix,
       x_quantity            =>  l_quantity,
       x_from_number         =>  l_from_number,
       x_to_number           =>  l_to_number,
       x_errorcode           =>  l_errorcode);
   l_length := length(l_tag_number);
   l_from_number := l_from_number + 1;
   l_padded_length := l_length - length(l_from_number);
   l_next_tag_number := RPAD(NVL(l_prefix, '0'), l_padded_length, '0') ||
     l_from_number;
   UPDATE MTL_PHYSICAL_INVENTORIES
     SET next_tag_number = l_next_tag_number
     WHERE physical_inventory_id = p_physical_inventory_id
     AND organization_id = p_organization_id;
   IF (l_debug = 1) THEN
      print_debug('Update physical inventory with next tag number: ' || l_next_tag_number);
   END IF;

   -- Calculate the tag quantity at standard uom
   SELECT primary_uom_code
     INTO l_item_standard_uom
     FROM mtl_system_items
     WHERE inventory_item_id = p_inventory_item_id
     AND organization_id = p_organization_id;
   -- I assume that the primary_uom_code is always given for an item
   --bug 8526693 added lot no and org id parameters to invoke inv_convert to honor lot specific conversions
   l_tag_qty_at_standard_uom := inv_convert.inv_um_convert
     ( item_id              =>  p_inventory_item_id,
       lot_number        =>  p_lot_number,
       organization_id  => p_organization_id,
       precision            =>  5,
       from_quantity        =>  p_tag_quantity,
       from_unit            =>  p_tag_uom,
       to_unit              =>  l_item_standard_uom,
       from_name            =>  NULL,
       to_name              =>  NULL);
   -- Conversion will return -99999 if unsuccessful so need to check for this
   IF (l_tag_qty_at_standard_uom = -99999) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_CONVERSION');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Get the outermost LPN ID for this record if necessary
   IF (p_parent_lpn_id IS NOT NULL) THEN
      --Bug2935754 starts
      /*
      WMS_CONTAINER_PUB.GET_OUTERMOST_LPN
        ( p_api_version       =>  1.0,
          x_return_status     =>  l_return_status,
          x_msg_count         =>  l_msg_count,
          x_msg_data          =>  l_msg_data,
          p_lpn_id            =>  p_parent_lpn_id,
          x_lpn_list          =>  l_lpn_list);
      l_outermost_lpn_id := l_lpn_list(1).lpn_id;
      */
   BEGIN
     SELECT  outermost_lpn_id
       INTO  l_outermost_lpn_id
       FROM  WMS_LICENSE_PLATE_NUMBERS
       WHERE lpn_id = p_parent_lpn_id;
   EXCEPTION
     WHEN OTHERS THEN
       IF (l_debug = 1) THEN
         print_debug('Unable to fetch outermost LPN for LPN ID: ' || p_parent_lpn_id);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
   END;
   --Bug2935754 ends

      IF (l_debug = 1) THEN
         print_debug('LPN ID passed in so get the outermost LPN: ' || l_outermost_lpn_id);
      END IF;
   END IF;

  print_debug('Deriving the employee id based on user ID: ' || p_user_id);

   --Bug 6600166, raising error if user is not a valid employee
   -- Bug 8717415, Commented out the join with organization id and selecting DISTINCT employee id,
   -- to allow employees across business group to enter the physical inventory tag count depending
   -- upon the 'HR:Cross Business Group' profile value.
   BEGIN
     SELECT DISTINCT(fus.employee_id)
     INTO   l_employee_id
     FROM   mtl_employees_current_view mec, fnd_user fus
     WHERE  fus.user_id = p_user_id
     AND    mec.employee_id = fus.employee_id;
     -- AND    mec.organization_id = p_organization_id;
   EXCEPTION
    WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('INV', 'INV_EMP');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END;

     print_debug('the employee id is: ' || l_employee_id);

/* Select clause Added for Bug8199582 */
BEGIN

 Select expiration_date
 into l_lot_expiration_date
 from mtl_lot_numbers
 where lot_number = p_lot_number
 and inventory_item_id = p_inventory_item_id
 and organization_id= p_organization_id
 and expiration_date is not null;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        l_lot_expiration_date := null ;
END ;

   -- Insert the new record
   IF (l_debug = 1) THEN
      print_debug('Inserting the new record here');
   END IF;
   INSERT INTO MTL_PHYSICAL_INVENTORY_TAGS
     (tag_id,
      physical_inventory_id,
      organization_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      void_flag,
      tag_number,
      adjustment_id,
      inventory_item_id,
      tag_quantity,
      tag_uom,
      tag_quantity_at_standard_uom,
      standard_uom,
      subinventory,
      locator_id,
      lot_number,
      revision,
      serial_num,
      counted_by_employee_id,
      parent_lpn_id,
      outermost_lpn_id,
      cost_group_id
      --INVCONV, NSRIVAST, START
      ,tag_secondary_uom
      ,tag_secondary_quantity
      ,LOT_EXPIRATION_DATE -- -- Inserting Expiration Date , Bug8199582
      --INVCONV, NSRIVAST, END
      ) VALUES
     (l_tag_id,
      p_physical_inventory_id,
      p_organization_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      p_user_id,
      p_user_id,
      2,
      l_tag_number,
      p_adjustment_id,
      p_inventory_item_id,
      p_tag_quantity,
      p_tag_uom,
      l_tag_qty_at_standard_uom,
      l_item_standard_uom,
      p_subinventory,
      p_locator_id,
      p_lot_number,
      p_revision,
      p_serial_number,
      l_employee_id,
      p_parent_lpn_id,
      l_outermost_lpn_id,
      p_cost_group_id
      --INVCONV, NSRIVAST, START
     ,p_tag_sec_uom
     ,p_tag_sec_quantity
     ,l_lot_expiration_date -- Inserting Expiration Date , Bug8199582
      --INVCONV, NSRIVAST, END
      );

EXCEPTION
 WHEN fnd_api.g_exc_error THEN
   raise fnd_api.g_exc_error;
 WHEN OTHERS THEN
   print_debug(SQLERRM);
   raise fnd_api.g_exc_unexpected_error;

END insert_row;


PROCEDURE update_row
  (p_tag_id                  IN    NUMBER,
   p_physical_inventory_id   IN    NUMBER,
   p_organization_id         IN    NUMBER,
   p_subinventory            IN    VARCHAR2,
   p_locator_id              IN    NUMBER,
   p_parent_lpn_id           IN    NUMBER,
   p_inventory_item_id       IN    NUMBER,
   p_revision                IN    VARCHAR2,
   p_lot_number              IN    VARCHAR2,
   p_serial_number           IN    VARCHAR2,
   p_tag_quantity            IN    NUMBER,
   p_tag_uom                 IN    VARCHAR2,
   p_user_id                 IN    NUMBER,
   p_cost_group_id           IN    NUMBER,
   p_adjustment_id           IN    NUMBER
   ,p_tag_sec_quantity       IN    NUMBER   := NULL     --INVCONV, NSRIVAST, START
   )
IS
l_tag_qty_at_standard_uom       NUMBER;
l_outermost_lpn_id              NUMBER;
l_item_standard_uom             VARCHAR2(3);
l_return_status                 VARCHAR2(300);
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(300);
l_lpn_list                      WMS_Container_PUB.LPN_Table_Type;
l_employee_id                   NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('***update_row***');
   END IF;
   -- Calculate the tag quantity at standard uom
   SELECT primary_uom_code
     INTO l_item_standard_uom
     FROM mtl_system_items
     WHERE inventory_item_id = p_inventory_item_id
     AND organization_id = p_organization_id;
   -- I assume that the primary_uom_code is always given for an item
   --bug 8526693 added lot no and org id parameters to invoke inv_convert to honor lot specific conversions
   l_tag_qty_at_standard_uom := inv_convert.inv_um_convert
     ( item_id              =>  p_inventory_item_id,
       lot_number        =>  p_lot_number,
       organization_id  => p_organization_id,
       precision            =>  5,
       from_quantity        =>  p_tag_quantity,
       from_unit            =>  p_tag_uom,
       to_unit              =>  l_item_standard_uom,
       from_name            =>  NULL,
       to_name              =>  NULL);
   -- Conversion will return -99999 if unsuccessful so need to check for this
   IF (l_tag_qty_at_standard_uom = -99999) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_CONVERSION');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Get the outermost LPN ID for this record if necessary
   IF (p_parent_lpn_id IS NOT NULL) THEN
      --Bug2935754 starts
      /*
      WMS_CONTAINER_PUB.GET_OUTERMOST_LPN
        ( p_api_version       =>  1.0,
          x_return_status     =>  l_return_status,
          x_msg_count         =>  l_msg_count,
          x_msg_data          =>  l_msg_data,
          p_lpn_id            =>  p_parent_lpn_id,
          x_lpn_list          =>  l_lpn_list);
      l_outermost_lpn_id := l_lpn_list(1).lpn_id;
      */
   BEGIN
     SELECT  outermost_lpn_id
       INTO  l_outermost_lpn_id
       FROM  WMS_LICENSE_PLATE_NUMBERS
       WHERE lpn_id = p_parent_lpn_id;
   EXCEPTION
      WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          print_debug('Unable to fetch outermost LPN for LPN ID: ' || p_parent_lpn_id);
        END IF;
      RAISE FND_API.G_EXC_ERROR;
   END;
   --Bug2935754 ends

      IF (l_debug = 1) THEN
         print_debug('LPN ID passed in so get the outermost LPN: ' || l_outermost_lpn_id);
      END IF;
   END IF;

  print_debug('Deriving the employee id based on user ID: ' || p_user_id);

  --Bug 6600166, raising error if user is not a valid employee
  -- Bug 8717415, Commented out the join with organization id and selecting DISTINCT employee id,
  -- to allow employees across business group to enter the physical inventory tag count depending
  -- upon the 'HR:Cross Business Group' profile value.
  BEGIN
   SELECT DISTINCT(fus.employee_id)
   INTO   l_employee_id
   FROM   mtl_employees_current_view mec, fnd_user fus
   WHERE  fus.user_id = p_user_id
   AND    mec.employee_id = fus.employee_id;
   -- AND    mec.organization_id = p_organization_id;
  EXCEPTION
    WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('INV', 'INV_EMP');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END;

   print_debug('the employee id is: ' || l_employee_id);

   -- Update the record
   IF (l_debug = 1) THEN
      print_debug('Updating the physical inventory tag record for tag ID: ' || p_tag_id);
   END IF;
   UPDATE MTL_PHYSICAL_INVENTORY_TAGS
     SET
     last_update_date                  =     SYSDATE,
     last_updated_by                   =     p_user_id,
     last_update_login                 =     p_user_id,
     adjustment_id                     =     p_adjustment_id,
     inventory_item_id                 =     p_inventory_item_id,
     tag_quantity                      =     p_tag_quantity,
     tag_uom                           =     p_tag_uom,
     tag_quantity_at_standard_uom      =     l_tag_qty_at_standard_uom,
     standard_uom                      =     l_item_standard_uom,
     subinventory                      =     p_subinventory,
     locator_id                        =     p_locator_id,
     lot_number                        =     p_lot_number,
     revision                          =     p_revision,
     serial_num                        =     p_serial_number,
     counted_by_employee_id            =     l_employee_id,
     parent_lpn_id                     =     p_parent_lpn_id,
     outermost_lpn_id                  =     l_outermost_lpn_id,
     cost_group_id                     =     p_cost_group_id
     ,tag_secondary_quantity           =     p_tag_sec_quantity  --INVCONV, NSRIVAST, START
     WHERE tag_id = p_tag_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END update_row;


PROCEDURE update_adjustment
  (p_adjustment_id           IN   NUMBER,
   p_physical_inventory_id   IN   NUMBER,
   p_organization_id         IN   NUMBER,
   p_user_id                 IN   NUMBER
   )
IS
l_adj_count_quantity    NUMBER;
l_adj2_count_quantity   NUMBER; -- Fix for Bug#7591655
-- Variables needed for calling the label printing API
l_inventory_item_id     NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
l_lot_number            VARCHAR2(80);
l_serial_number         VARCHAR2(30);
l_lpn_id                NUMBER;
l_subinventory          VARCHAR2(10);
l_locator_id            NUMBER;
l_adjustment_quantity   NUMBER;
l_standard_uom_code     VARCHAR2(3);
l_label_status          VARCHAR2(300) := NULL;
l_return_status         VARCHAR2(3000);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(3000);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('***update_adjustment***');
   END IF;

   /* Fix for Bug#7591655. Added tag_secondary_quantity in following select. Secondary qty is always at
      secondary uom. Hence no need of tag_secondary_at_standard_uom */

   SELECT NVL(SUM(tag_quantity_at_standard_uom),0),
   	  NVL(SUM(tag_secondary_quantity),0)
     INTO l_adj_count_quantity,
          l_adj2_count_quantity
     FROM mtl_physical_inventory_tags
     WHERE adjustment_id = p_adjustment_id
     AND organization_id = p_organization_id
     AND physical_inventory_id = p_physical_inventory_id
     AND void_flag = 2;

   IF (l_debug = 1) THEN
      print_debug('Updating the physical adjustment record for adjustment ID: ' || p_adjustment_id);
   END IF;
   /* Fix for Bug#7591655 . Added secondary_count_qty and secondary_adjustment_qty in following update */
   UPDATE mtl_physical_adjustments
     SET last_update_date = SYSDATE,
     last_updated_by = NVL(p_user_id, -1),
     count_quantity = l_adj_count_quantity,
     adjustment_quantity = NVL(l_adj_count_quantity, NVL(system_quantity,0))
     - NVL(system_quantity,0),
     secondary_count_qty = l_adj2_count_quantity,
     secondary_adjustment_qty = NVL(l_adj2_count_quantity, NVL(secondary_system_qty,0))
     - NVL(secondary_system_qty,0),
     approval_status = NULL,
     approved_by_employee_id = NULL
     WHERE adjustment_id = p_adjustment_id
     AND physical_inventory_id = p_physical_inventory_id
     AND organization_id = p_organization_id;

   -- Get the adjustment record values needed for label printing
   IF (l_debug = 1) THEN
      print_debug('Get the adjustment record values for label printing');
   END IF;
   SELECT inventory_item_id, lot_number, serial_number, parent_lpn_id,
     subinventory_name, locator_id, NVL(adjustment_quantity, 0)
     INTO l_inventory_item_id, l_lot_number, l_serial_number,
     l_lpn_id, l_subinventory, l_locator_id, l_adjustment_quantity
     FROM mtl_physical_adjustments
     WHERE adjustment_id = p_adjustment_id
     AND physical_inventory_id = p_physical_inventory_id
     AND organization_id = p_organization_id;

   -- Get the primary UOM for the inventory item
   IF (l_debug = 1) THEN
      print_debug('Get the primary UOM code: ' || 'Item ID: ' || l_inventory_item_id || ': ' || 'Org ID: ' || p_organization_id);
   END IF;
   SELECT primary_uom_code
     INTO l_standard_uom_code
     FROM mtl_system_items
     WHERE inventory_item_id = l_inventory_item_id
     AND organization_id = p_organization_id;

   -- Call the label printing API if an adjustment is required
   IF (l_debug = 1) THEN
      print_debug('Adjustment quantity: ' || l_adjustment_quantity);
   END IF;
   IF (l_adjustment_quantity <> 0) THEN
      IF (l_debug = 1) THEN
         print_debug('Calling print_label_manual_wrap with the following input parameters');
         print_debug('p_business_flow_code: -> ' || 9);
      END IF;
      --print_debug('p_label_type: ---------> ' || 1);
      IF (l_debug = 1) THEN
         print_debug('p_organization_id: ----> ' || p_organization_id);
         print_debug('p_inventory_item_id: --> ' || l_inventory_item_id);
         print_debug('p_lot_number: ---------> ' || l_lot_number);
         print_debug('p_fm_serial_number: ---> ' || l_serial_number);
         print_debug('p_to_serial_number: ---> ' || l_serial_number);
         print_debug('p_lpn_id: -------------> ' || l_lpn_id);
         print_debug('p_subinventory_code: --> ' || l_subinventory);
         print_debug('p_locator_id: ---------> ' || l_locator_id);
         print_debug('p_quantity: -----------> ' || l_adjustment_quantity);
         print_debug('p_uom: ----------------> ' || l_standard_uom_code);
         print_debug('p_no_of_copies: -------> ' || 1);
      END IF;

      -- Bug# 2301732
      -- Make the call to the label printing API more robust
      -- by trapping for exceptions when calling it
      -- Bug# 2412674
      -- Don't pass in the value for the label type
      BEGIN
         inv_label.print_label_manual_wrap
           ( x_return_status      =>  l_return_status        ,
             x_msg_count          =>  l_msg_count            ,
             x_msg_data           =>  l_msg_data             ,
             x_label_status       =>  l_label_status         ,
             p_business_flow_code =>  9                      ,
             --p_label_type         =>  1                      ,
             p_organization_id    =>  p_organization_id      ,
             p_inventory_item_id  =>  l_inventory_item_id    ,
             p_lot_number         =>  l_lot_number           ,
             p_fm_serial_number   =>  l_serial_number        ,
             p_to_serial_number   =>  l_serial_number        ,
             p_lpn_id             =>  l_lpn_id               ,
             p_subinventory_code  =>  l_subinventory         ,
             p_locator_id         =>  l_locator_id           ,
             p_quantity           =>  l_adjustment_quantity  ,
             p_uom                =>  l_standard_uom_code    ,
             p_no_of_copies       =>  1
             );
      EXCEPTION
         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
            print_debug('Error while calling label printing API');
            END IF;
            FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LABEL_FAILE');
            FND_MSG_PUB.ADD;
      END;
      IF (l_debug = 1) THEN
         print_debug('After calling label printing API: ' || l_return_status || ', ' || l_label_status || ', ' || l_msg_data);
      END IF;

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         FND_MESSAGE.SET_NAME('INV', 'INV_RCV_CRT_PRINT_LABEL_FAILE');
         FND_MSG_PUB.ADD;
      END IF;

   END IF;

END update_adjustment;



PROCEDURE find_existing_adjustment
  (p_physical_inventory_id   IN           NUMBER,
   p_organization_id         IN           NUMBER,
   p_subinventory            IN           VARCHAR2,
   p_locator_id              IN           NUMBER,
   p_parent_lpn_id           IN           NUMBER,
   p_inventory_item_id       IN           NUMBER,
   p_revision                IN           VARCHAR2,
   p_lot_number              IN           VARCHAR2,
   p_serial_number           IN           VARCHAR2,
   p_user_id                 IN           NUMBER,
   p_cost_group_id           IN           NUMBER,
   x_adjustment_id           OUT   NOCOPY NUMBER
   )
IS
l_rev_code                NUMBER;
l_org_locator_type        NUMBER;
l_sub_locator_type        NUMBER;
l_location_control_code   NUMBER;
l_lot_control_code        NUMBER;
l_serial_control_code     NUMBER;
l_adj_id                  NUMBER:= -1;
l_actual_cost             NUMBER;
l_outermost_lpn_id        NUMBER;
l_return_status           VARCHAR2(300);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(300);
l_lpn_list                WMS_Container_PUB.LPN_Table_Type;
l_approval_status         NUMBER:= -1;
l_lot_expiration_date     Date; /* Added by 8199582 */
l_process_enabled_flag    VARCHAR2(1);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('***find_existing_adjustment***');
   END IF;
   -- Get the required information for the local variables
   -- Locator control type for the org
   SELECT stock_locator_control_code
     INTO l_org_locator_type
     FROM mtl_parameters
     WHERE organization_id = p_organization_id;

   -- Locator control type for the sub
   SELECT locator_type
     INTO l_sub_locator_type
     FROM mtl_secondary_inventories
     WHERE secondary_inventory_name = p_subinventory
     AND organization_id = p_organization_id;

   -- Locator control type for the item plus revision, lot, and serial
   -- control codes
   SELECT revision_qty_control_code, location_control_code,
     lot_control_code, serial_number_control_code
     INTO l_rev_code, l_location_control_code,
     l_lot_control_code, l_serial_control_code
     FROM mtl_system_items
     WHERE inventory_item_id = p_inventory_item_id
     AND organization_id = p_organization_id;

   -- Get the adjustment ID if it is existing
   IF (l_debug = 1) THEN
      print_debug('Try to find the adjustment ID if it exists');
   END IF;
   SELECT MIN(ADJUSTMENT_ID)
     INTO l_adj_id
     FROM MTL_PHYSICAL_ADJUSTMENTS
     WHERE ORGANIZATION_ID = p_organization_id
     AND PHYSICAL_INVENTORY_ID = p_physical_inventory_id
     AND INVENTORY_ITEM_ID = p_inventory_item_id
     AND SUBINVENTORY_NAME = p_subinventory
     AND ( NVL(REVISION,'@@@@@') = NVL(p_revision,'@@@@@')
           OR l_rev_code = 1 )
     AND NVL(parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999) --Bug 6929248 Posted adjustments should not be allowed to enter tags
     AND (approval_status=3 OR NVL(cost_group_id, -99999) = NVL(p_cost_group_id, -99999))
     AND (NVL(LOCATOR_ID, -99999) = NVL(p_locator_id, -99999)
          OR l_org_locator_type = 1
          OR (l_org_locator_type = 4
              AND (l_sub_locator_type = 1
                   OR (l_sub_locator_type = 5
                       AND l_location_control_code = 1)))
          OR (l_location_control_code = 5
              AND l_location_control_code = 1))
     AND ( NVL(LOT_NUMBER,'@@@@@') = NVL(p_lot_number,'@@@@@')
           OR l_lot_control_code = 1 )
     AND ( NVL(SERIAL_NUMBER,'@@@@@') = NVL(p_serial_number,'@@@@@')
           OR l_serial_control_code = 1 )
     GROUP BY ORGANIZATION_ID,
     PHYSICAL_INVENTORY_ID,
     INVENTORY_ITEM_ID,
     SUBINVENTORY_NAME,
     REVISION,
     LOCATOR_ID,
     PARENT_LPN_ID,
     COST_GROUP_ID,
     LOT_NUMBER,
     SERIAL_NUMBER;

 /* Bug 4350316, if the corresponding adjustment is posted, not allowing the user to enter a dynamic tag*/

     IF l_adj_id IS NOT NULL THEN
       select approval_status
       into l_approval_status
       from mtl_physical_adjustments
       where adjustment_id = l_adj_id
       and physical_inventory_id = p_physical_inventory_id;

       if (nvl(l_approval_status,0) = 3) then
        print_debug('Error: The corresponding adjustment_id '||l_adj_id||' is already posted');
        fnd_message.set_name('INV','INV_PHYSICAL_ADJ_POSTED');
        fnd_message.set_token('TOKEN1', l_adj_id);
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;
       end if;
     END IF;


   x_adjustment_id := l_adj_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -- insert new adjustment row
      IF (l_debug = 1) THEN
         print_debug('No adjustment record found so insert a new one');
      END IF;

   -- Get the actual cost of the item in the current tag
   IF (l_debug = 1) THEN
      print_debug('Get the actual cost of the item');
   END IF;

    /* Bug# 2942493
    ** Instead of duplicating the code, reusing the common utility to
    ** to get the item cost. That way its easier to maintain.
    */
    -- Bug 9046942
    -- for OPM get the item cost from OPM costing tables.

    SELECT NVL(process_enabled_flag, 'N')
	   INTO l_process_enabled_flag
	   FROM mtl_parameters
	   WHERE organization_id = p_organization_id;

    IF (l_debug = 1) THEN
       print_debug('Process enabled flag : ' || l_process_enabled_flag);
       print_debug('p_inventory_item_id  : ' || p_inventory_item_id);
       print_debug('p_organization_id    : ' || p_organization_id);
       print_debug('p_locator_id         : ' || p_locator_id);
    END IF;

    IF (l_process_enabled_flag = 'Y') THEN
        -- get opm cost for the item
        --
        l_actual_cost := gmf_cmcommon.process_item_unit_cost (p_inventory_item_id,p_organization_id,SYSDATE);
        IF (l_debug = 1) THEN
           print_debug('OPM cost: ' || l_actual_cost);
        END IF;

    ELSE
      INV_UTILITIES.GET_ITEM_COST(
         v_org_id     => p_organization_id,
         v_item_id    => p_inventory_item_id,
         v_locator_id => p_locator_id,
         v_item_cost  => l_actual_cost);

      IF (l_actual_cost = -999) THEN
         l_actual_cost := 0;
      END IF;
    END IF;

-- Get a valid adjustment ID for the new record
SELECT mtl_physical_adjustments_s.NEXTVAL
  INTO l_adj_id
  FROM dual;
IF (l_debug = 1) THEN
   print_debug('New adjustment ID: ' || l_adj_id);
END IF;

-- Get the outermost LPN ID if necessary
IF (p_parent_lpn_id IS NOT NULL) THEN
   --Bug2935754 starts
   /*
   WMS_CONTAINER_PUB.GET_OUTERMOST_LPN
     ( p_api_version       =>  1.0,
       x_return_status     =>  l_return_status,
       x_msg_count         =>  l_msg_count,
       x_msg_data          =>  l_msg_data,
       p_lpn_id            =>  p_parent_lpn_id,
       x_lpn_list          =>  l_lpn_list);
   l_outermost_lpn_id := l_lpn_list(1).lpn_id;
   */

   BEGIN
     SELECT  outermost_lpn_id
       INTO  l_outermost_lpn_id
       FROM  WMS_LICENSE_PLATE_NUMBERS
       WHERE lpn_id = p_parent_lpn_id;
   EXCEPTION
     WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        print_debug('Unable to fetch outermost LPN for LPN ID: ' || p_parent_lpn_id);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END;
   --Bug2935754 ends

   IF (l_debug = 1) THEN
      print_debug('LPN ID passed in so get the outermost LPN: ' || l_outermost_lpn_id);
   END IF;
END IF;

-- Insert the new adjustment record
IF (l_debug = 1) THEN
   print_debug('Get the expire date for the lot');
END IF;

/* Select clause Added for Bug8199582 */
BEGIN

 Select expiration_date
 into l_lot_expiration_date
 from mtl_lot_numbers
 where lot_number = p_lot_number
 and inventory_item_id = p_inventory_item_id
 and organization_id   = p_organization_id
 and expiration_date is not null;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      l_lot_expiration_date := null ;
END ;

IF (l_debug = 1) THEN
   print_debug('Inserting the new physical adjustment record');
END IF;

/* Fix for Bug#7591655. Added secondary_count_qty and secondary_adjustment_qty in insert */

INSERT INTO mtl_physical_adjustments
  (     adjustment_id,
        organization_id,
        physical_inventory_id,
        inventory_item_id,
        subinventory_name,
        system_quantity,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        count_quantity,
        adjustment_quantity,
        revision,
        locator_id,
        parent_lpn_id,
        outermost_lpn_id,
        cost_group_id,
        lot_number,
        serial_number,
        actual_cost ,
        secondary_count_qty,
        secondary_adjustment_qty,
        lot_expiration_date ) /* Inserting Expiration Date , Bug8199582 */
  VALUES ( l_adj_id,
           p_organization_id,
           p_physical_inventory_id,
           p_inventory_item_id,
           p_subinventory,
           0,
           SYSDATE,
           p_user_id,
           SYSDATE,
           p_user_id,
           p_user_id,
           0,
           0,
           p_revision,
           p_locator_id,
           p_parent_lpn_id,
           l_outermost_lpn_id,
           p_cost_group_id,
           p_lot_number,
           p_serial_number,
           l_actual_cost,
           0,
           0,
           l_lot_expiration_date); /* Inserting Expiration Date , Bug8199582 */

x_adjustment_id := l_adj_id;

END find_existing_adjustment;



PROCEDURE process_summary
  (p_physical_inventory_id   IN    NUMBER,
   p_organization_id         IN    NUMBER,
   p_subinventory            IN    VARCHAR2,
   p_locator_id              IN    NUMBER := NULL,
   p_parent_lpn_id           IN    NUMBER := NULL,
   p_dynamic_tag_entry_flag  IN    NUMBER,
   p_user_id                 IN    NUMBER
   )
IS
l_current_lpn            NUMBER;
l_temp_uom_code          VARCHAR2(3);
CURSOR nested_lpn_cursor IS
   SELECT *
     FROM WMS_LICENSE_PLATE_NUMBERS
     START WITH lpn_id = p_parent_lpn_id
     CONNECT BY parent_lpn_id = PRIOR lpn_id;
CURSOR lpn_contents_cursor IS
   SELECT *
     FROM WMS_LPN_CONTENTS
     WHERE parent_lpn_id = l_current_lpn
     AND NVL(serial_summary_entry, 2) = 2;
CURSOR lpn_serial_contents_cursor IS
   SELECT *
     FROM MTL_SERIAL_NUMBERS
     WHERE lpn_id = l_current_lpn;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('***process_summary***');
   END IF;
   -- Use the cursor that searches through all levels in the parent child relationship
   FOR v_lpn_id IN nested_lpn_cursor LOOP
      l_current_lpn := v_lpn_id.lpn_id;

      -- Process the tag for the LPN item itself if it is associated with
      -- an inventory item
      IF (v_lpn_id.inventory_item_id IS NOT NULL) THEN
         -- Get the primary UOM for the container inventory item
         SELECT primary_uom_code
           INTO l_temp_uom_code
           FROM mtl_system_items
           WHERE inventory_item_id = v_lpn_id.inventory_item_id
           AND organization_id = v_lpn_id.organization_id;

         IF (l_debug = 1) THEN
         print_debug('Counting an LPN');
         END IF;
         process_tag
           (p_physical_inventory_id   =>  p_physical_inventory_id,
            p_organization_id         =>  p_organization_id,
            p_subinventory            =>  p_subinventory,
            p_locator_id              =>  p_locator_id,
            p_parent_lpn_id           =>  v_lpn_id.parent_lpn_id,
            p_inventory_item_id       =>  v_lpn_id.inventory_item_id,
            p_revision                =>  v_lpn_id.revision,
            p_lot_number              =>  v_lpn_id.lot_number,
            p_from_serial_number      =>  v_lpn_id.serial_number,
            p_to_serial_number        =>  v_lpn_id.serial_number,
            p_tag_quantity            =>  1,
            p_tag_uom                 =>  l_temp_uom_code,
            p_dynamic_tag_entry_flag  =>  p_dynamic_tag_entry_flag,
            p_user_id                 =>  p_user_id,
            p_cost_group_id           =>  v_lpn_id.cost_group_id
            );
      END IF;

      -- Process the tags for the LPN content items
      FOR v_lpn_content IN lpn_contents_cursor LOOP

         IF (l_debug = 1) THEN
         print_debug('Counting an LPN content item');
         END IF;
         process_tag
           (p_physical_inventory_id   =>  p_physical_inventory_id,
            p_organization_id         =>  p_organization_id,
            p_subinventory            =>  p_subinventory,
            p_locator_id              =>  p_locator_id,
            p_parent_lpn_id           =>  v_lpn_content.parent_lpn_id,
            p_inventory_item_id       =>  v_lpn_content.inventory_item_id,
            p_revision                =>  v_lpn_content.revision,
            p_lot_number              =>  v_lpn_content.lot_number,
            p_from_serial_number      =>  NULL,
            p_to_serial_number        =>  NULL,
            p_tag_quantity            =>  v_lpn_content.quantity,
            p_tag_uom                 =>  v_lpn_content.uom_code,
            p_dynamic_tag_entry_flag  =>  p_dynamic_tag_entry_flag,
            p_user_id                 =>  p_user_id,
            p_cost_group_id           =>  v_lpn_content.cost_group_id
            );

      END LOOP;

      -- Process the tags for serialized items
      FOR v_lpn_serial_content IN lpn_serial_contents_cursor LOOP
         -- Get the primary UOM for the serialized item
         SELECT primary_uom_code
           INTO l_temp_uom_code
           FROM mtl_system_items
           WHERE inventory_item_id = v_lpn_serial_content.inventory_item_id
           AND organization_id = v_lpn_serial_content.current_organization_id;

         IF (l_debug = 1) THEN
         print_debug('Counting an LPN serial controlled item');
         END IF;
         process_tag
           (p_physical_inventory_id   =>  p_physical_inventory_id,
            p_organization_id         =>  p_organization_id,
            p_subinventory            =>  p_subinventory,
            p_locator_id              =>  p_locator_id,
            p_parent_lpn_id           =>  v_lpn_serial_content.lpn_id,
            p_inventory_item_id       =>  v_lpn_serial_content.inventory_item_id,
            p_revision                =>  v_lpn_serial_content.revision,
            p_lot_number              =>  v_lpn_serial_content.lot_number,
            p_from_serial_number      =>  v_lpn_serial_content.serial_number,
            p_to_serial_number        =>  v_lpn_serial_content.serial_number,
            p_tag_quantity            =>  1,
            p_tag_uom                 =>  l_temp_uom_code,
            p_dynamic_tag_entry_flag  =>  p_dynamic_tag_entry_flag,
            p_user_id                 =>  p_user_id,
            p_cost_group_id           =>  v_lpn_serial_content.cost_group_id
            );

      END LOOP;

   END LOOP;

END process_summary;

--Fix for bug #4654210
   PROCEDURE unmark_serials
     (p_physical_inventory_id   IN    NUMBER,
      p_organization_id         IN    NUMBER,
      p_item_id                 IN    NUMBER,
      x_status                 OUT    NOCOPY NUMBER
     )
   IS
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      IF (l_debug = 1) THEN
         print_debug('***unmark_serials***');
      END IF;

      IF (p_physical_inventory_id IS NULL) THEN
         IF (l_debug = 1) THEN
             print_debug('Physical Inventory Id is not provided. Returning from the Procedure');
         END IF;
         x_status := -1;
      ELSIF (p_organization_id IS NULL) THEN
         IF (l_debug = 1) THEN
             print_debug('Organization Id is not provided. Returning from the Procedure');
         END IF;
         x_status := -1;
      ELSIF (p_item_id IS NULL) THEN
         IF (l_debug = 1) THEN
             print_debug('Inventory Item Id is not provided. Returning from the Procedure');
         END IF;
         x_status := -1;
      ELSE

         UPDATE mtl_serial_numbers
         SET    group_mark_id = -1
         WHERE  inventory_item_id = p_item_id
         AND    serial_number in
             (SELECT DISTINCT serial_num
              FROM   mtl_physical_inventory_tags
              WHERE  organization_id      = p_organization_id
              AND   physical_inventory_id = p_physical_inventory_id
              AND   inventory_item_id     = p_item_id
              AND   serial_num is not null
              )
         AND nvl(group_mark_id,-1) <> -1;

         IF (l_debug = 1) THEN
             print_debug('Updated ' || SQL%ROWCOUNT || ' Records in mtl_serial_numbers for the inventory_item_id ' || p_item_id);
             print_debug('*** end unmark_serials***');
         END IF;

         x_status := 0;
      END IF;

   END unmark_serials;

   --End of Fix for bug # 4654210

-- Fix for 5660272 to get the serial uniquiness type or a given organization
PROCEDURE GET_SERIAL_NUMBER_TYPE
  (	x_serial_number_type OUT NOCOPY	NUMBER,
	p_organization_id   IN		NUMBER
  )
 IS
 BEGIN
  SELECT	NVL(SERIAL_NUMBER_TYPE, 0)
  INTO		x_serial_number_type
  FROM		MTL_PARAMETERS
  WHERE		ORGANIZATION_ID = p_organization_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_serial_number_type :=0;
END;
--End of Fix for bug # 5660272
-- Fix for 5660272 to check for the validity of the serial number --
PROCEDURE VALIDATE_SERIAL_STATUS
   (    x_status             OUT NOCOPY NUMBER,               -- 1 FOR SUCCESS AND ANY OTHER VALUE FOR FAILURE
        x_organization_code  OUT NOCOPY VARCHAR2,
        x_current_status     OUT NOCOPY VARCHAR2,
        p_serial_num         IN         VARCHAR2,
        p_organization_id    IN         NUMBER,
        p_subinventory_code  IN         VARCHAR2,
        p_locator_id         IN         NUMBER,
        p_inventory_item_id  IN         NUMBER,
        p_serial_number_type IN         NUMBER
    )
IS
  l_valid_serial NUMBER := 0;
  l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  x_status := 0;
IF (l_debug = 1) THEN
    print_debug('Start Validating the serial for the current status');
  END IF;
  l_valid_serial := 0;

  /*
   * Checking if the serial number exist with same serial number in the same subinventory
   * organization and locator for the same item.
   * Bug# 6354645:
   * Added the condition to check for inventory_item_id as the same serial number can be assigned
   * to 2 different items in the same org/sub/locator if the serial uniqueness is 'Within Inventory Items'
   * This is to avoid TOO_MANY_ROWS_FOUND exception.
   */
   /*Bug7829724-Commeneted locator*/
  BEGIN
    SELECT      1,MP.ORGANIZATION_CODE,ML.MEANING
    INTO        l_valid_serial,x_organization_code,x_current_status
    FROM        MTL_SERIAL_NUMBERS MSN , MTL_PARAMETERS MP, MFG_LOOKUPS ML
    WHERE       SERIAL_NUMBER like p_serial_num
    AND         MSN.INVENTORY_ITEM_ID = p_inventory_item_id
    AND         MSN.CURRENT_ORGANIZATION_ID = p_organization_id
    AND         MSN.CURRENT_ORGANIZATION_ID = MP.ORGANIZATION_ID
    AND         MSN.CURRENT_STATUS = ML.LOOKUP_CODE
    AND         MSN.CURRENT_SUBINVENTORY_CODE like p_subinventory_code
--    AND         NVL(MSN.CURRENT_LOCATOR_ID,-9999) = NVL(p_locator_id, -9999)
    AND         ML.LOOKUP_TYPE like 'SERIAL_NUM_STATUS'
    AND         CURRENT_STATUS = 3;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_valid_serial :=0;
  END;

  -- If the serial number type is 0. Invalid serial Control Option, so error out. Very rare case.
  IF p_serial_number_type = 0 THEN
    x_status := -1;
    RETURN;
  END IF;

  --Changed the return value from -1 to 1. Because this will not be a error case. for bug 5903566
  IF  l_valid_serial = 1 THEN
    -- Serial Number is present in the org/subinv/loc given by user. Hence return Success.
    x_status := 1;
    RETURN;

  -- New Serial Given here. So check if it violates the serial Number Uniqueness logic.
  ELSIF l_valid_serial = 0 THEN
    IF p_serial_number_type = 3 THEN
      /*
       * If serial uniquiness is accross organizations (3)
       * serial should not exist anywhere
       */
      SELECT    MP.ORGANIZATION_CODE,ML.MEANING
      INTO      x_organization_code,x_current_status
      FROM      MTL_SERIAL_NUMBERS MSN, MTL_PARAMETERS MP,MFG_LOOKUPS ML
      WHERE     SERIAL_NUMBER like p_serial_num
      AND       MSN.CURRENT_ORGANIZATION_ID = MP.ORGANIZATION_ID
      AND       MSN.CURRENT_STATUS = ML.LOOKUP_CODE
      AND       ML.LOOKUP_TYPE like 'SERIAL_NUM_STATUS'
      AND       CURRENT_STATUS NOT IN (1,4);
    ELSIF p_serial_number_type IN (1,4) THEN
      /*
       * If serial uniquiness is within inventory (1,4)
       * serial should not exist in same org, same item
       */
       SELECT    MP.ORGANIZATION_CODE,ML.MEANING
       INTO      x_organization_code,x_current_status
       FROM      MTL_SERIAL_NUMBERS MSN, MTL_PARAMETERS MP,MFG_LOOKUPS ML
       WHERE     MSN.SERIAL_NUMBER like p_serial_num
       AND       MSN.INVENTORY_ITEM_ID = p_inventory_item_id
       AND       MSN.CURRENT_ORGANIZATION_ID = MP.ORGANIZATION_ID
       AND       MSN.CURRENT_STATUS = ML.LOOKUP_CODE
       AND       ML.LOOKUP_TYPE like 'SERIAL_NUM_STATUS'
       AND       CURRENT_STATUS NOT IN (1,4);
    ELSIF p_serial_number_type = 2 THEN
      /*
       * If serial uniquiness is within organization (2)
       * serial should first be unique within inventory items and
       * then within organizations.
       * Added the below condition because it could be the case that the
       * same serial could be assigned to the same item in a different org.
       */
      BEGIN

        SELECT  MP.ORGANIZATION_CODE,ML.MEANING
        INTO    x_organization_code,x_current_status
        FROM    MTL_SERIAL_NUMBERS MSN, MTL_PARAMETERS MP,MFG_LOOKUPS ML
        WHERE   MSN.SERIAL_NUMBER like p_serial_num
        AND     MSN.INVENTORY_ITEM_ID = p_inventory_item_id
        AND     MSN.CURRENT_ORGANIZATION_ID = MP.ORGANIZATION_ID
        AND     MSN.CURRENT_STATUS = ML.LOOKUP_CODE
        AND     ML.LOOKUP_TYPE like 'SERIAL_NUM_STATUS'
        AND     CURRENT_STATUS NOT IN (1,4);

        x_status := -1;
        RETURN;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;-- SETTING NULL HERE TO EXECUTE THE SECOND QUERY.
      END;
      /*
       * If serial uniquiness is within organization (2)
       * serial should not exist in same org
       */
      SELECT    MP.ORGANIZATION_CODE,ML.MEANING
      INTO      x_organization_code,x_current_status
      FROM      MTL_SERIAL_NUMBERS MSN, MTL_PARAMETERS MP,MFG_LOOKUPS ML
      WHERE     MSN.SERIAL_NUMBER like p_serial_num
      AND       MSN.CURRENT_ORGANIZATION_ID = p_organization_id
      AND       MSN.CURRENT_ORGANIZATION_ID = MP. ORGANIZATION_ID
      AND       MSN.CURRENT_STATUS = ML.LOOKUP_CODE
      AND       ML.LOOKUP_TYPE like 'SERIAL_NUM_STATUS'
      AND       CURRENT_STATUS NOT IN (1,4);

    END IF;
  END IF;
  x_status := -1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN  -- No Data Found means the given new serial doesnt violate any of the serial uniqueness conditions.
    IF (l_debug = 1) THEN
      print_debug('Serial Number status is valid so go ahaead');
    END IF;
    x_status := 1;
END  VALIDATE_SERIAL_STATUS;

--End of Fix for bug # 5660272



END INV_PHY_INV_LOVS;

/
