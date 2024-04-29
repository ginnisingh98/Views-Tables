--------------------------------------------------------
--  DDL for Package Body WMS_PICK_LOAD_UI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_PICK_LOAD_UI" AS
/* $Header: WMSPLUIB.pls 120.4.12010000.4 2008/09/11 10:51:57 ssrikaku ship $ */

g_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);

PROCEDURE debug(p_message VARCHAR2,
                p_module  VARCHAR2 DEFAULT 'Pick Load UI') IS
BEGIN
   inv_log_util.trace(p_message, p_module, 9);
END debug;

PROCEDURE validate_subinventory(p_organization_id                     IN  NUMBER,
                                p_item_id                             IN  NUMBER,
                                p_subinventory_code                   IN  VARCHAR2,
                                p_restrict_subinventories_code        IN  NUMBER,
                                p_transaction_type_id                 IN  NUMBER,
                                x_is_valid_subinventory               OUT nocopy VARCHAR2,
                                x_is_lpn_controlled                   OUT nocopy VARCHAR2,
                                x_message                             OUT nocopy VARCHAR2)

  IS

  TYPE sub_record_type IS RECORD
    (subinventory_code   mtl_secondary_inventories.secondary_inventory_name%TYPE,
     locator_type        mtl_secondary_inventories.locator_type%TYPE,
     description         mtl_secondary_inventories.description%TYPE,
     asset_inventory     mtl_secondary_inventories.asset_inventory%TYPE,
     lpn_controlled_flag mtl_secondary_inventories.lpn_controlled_flag%TYPE,
     subinventory_type   mtl_secondary_inventories.subinventory_type%TYPE,
     reservable_type     mtl_secondary_inventories.reservable_type%TYPE,
     enable_alias        mtl_secondary_inventories.enable_locator_alias%TYPE);

  l_sub_rec          sub_record_type;
  l_subinventories   t_genref;

BEGIN
   x_is_valid_subinventory := 'N';

   inv_ui_item_sub_loc_lovs.get_sub_lov_rcv
     (x_sub                            => l_subinventories,
      p_organization_id                => p_organization_id,
      p_item_id                        => p_item_id,
      p_sub                            => p_subinventory_code,
      p_restrict_subinventories_code   => p_restrict_subinventories_code,
      p_transaction_type_id            => p_transaction_type_id,
      p_wms_installed                  => 'Y',
      p_location_id                    => NULL,
      p_lpn_context                    => 1,
      p_putaway_code                   => 1);


   LOOP
      FETCH l_subinventories INTO l_sub_rec;
      EXIT WHEN l_subinventories%notfound;


      IF l_sub_rec.subinventory_code = p_subinventory_code THEN
         x_is_valid_subinventory := 'Y';

         IF l_sub_rec.lpn_controlled_flag = 1 THEN
            x_is_lpn_controlled := 'Y';
          ELSE
            x_is_lpn_controlled := 'N';
         END IF;

         EXIT;
      END IF;

   END LOOP;

   IF x_is_valid_subinventory = 'N' THEN
      fnd_message.set_name('WMS', 'WMS_INVALID_VALUE');
      fnd_msg_pub.add;

      inv_mobile_helper_functions.get_stacked_messages(x_message => x_message);
   END IF;

END validate_subinventory;

PROCEDURE validate_locator_lpn
  (p_organization_id        IN         NUMBER,
   p_restrict_locators_code IN         NUMBER,
   p_inventory_item_id      IN         NUMBER,
   p_revision               IN         VARCHAR2,
   p_locator_lpn            IN         VARCHAR2,
   p_subinventory_code      IN         VARCHAR2,
   p_transaction_temp_id    IN         NUMBER,
   p_transaction_type_id    IN         NUMBER,
   p_project_id             IN         NUMBER,
   p_task_id                IN         NUMBER,
   p_allocated_lpn          IN         VARCHAR2,
   p_suggested_loc          IN         VARCHAR2,
   p_suggested_loc_id       IN         NUMBER,
   p_suggested_sub          IN         VARCHAR2,
   p_serial_allocated       IN         VARCHAR2,
   p_allow_locator_change   IN         VARCHAR2,
   p_is_loc_or_lpn          IN         VARCHAR2,
   x_is_valid_locator       OUT nocopy VARCHAR2,
   x_is_valid_lpn           OUT nocopy VARCHAR2,
   x_subinventory_code      OUT nocopy VARCHAR2,
   x_locator                OUT nocopy VARCHAR2,
   x_locator_id             OUT nocopy NUMBER,
   x_lpn_id                 OUT nocopy NUMBER,
   x_is_lpn_controlled      OUT nocopy VARCHAR2,
   x_return_status          OUT nocopy VARCHAR2,
   x_msg_count              OUT nocopy NUMBER,
   x_msg_data               OUT nocopy VARCHAR2)
  IS

   TYPE loc_record_type IS RECORD
    (locator_id   NUMBER,
     locator      VARCHAR2(204),
     description  VARCHAR2(50));

   TYPE loc_sub_record_type IS RECORD
    (locator_id   NUMBER,
     locator      VARCHAR2(204),
     description  VARCHAR2(50),
     subinventory VARCHAR2(10));

   TYPE lpn_record_type IS RECORD
     (license_plate_number    VARCHAR2(30),
      lpn_id                  NUMBER,
      inventory_item_id       NUMBER,
      organization_id         NUMBER,
      revision                VARCHAR2(3),
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
      lot_number              VARCHAR2(80),
      serial_number           VARCHAR2(30),
      subinventory_code       VARCHAR2(10),
      locator_id              NUMBER,
      parent_lpn_id           NUMBER,
      sealed_status           NUMBER,
      gross_weight_uom_code   VARCHAR2(3),
      gross_weight            NUMBER,
      content_volume_uom_code VARCHAR2(3),
      content_volume          NUMBER,
      concatenated_segments   VARCHAR2(204),
      lpn_context             NUMBER);

   l_loc_rec    loc_record_type;
   l_loc_sub_rec    loc_sub_record_type;
   l_lpn_rec    lpn_record_type;
   l_locators   t_genref;
   l_lpns       t_genref;
   l_project_id NUMBER := p_project_id;
   l_task_id    NUMBER := p_task_id;

   l_alias_enabled  VARCHAR2(1);   -- Bug 7225845
   l_locator_lpn  VARCHAR2(100);   -- Bug 7225845

BEGIN
   x_return_status := 'S';
   x_is_valid_locator := 'N';
   x_is_valid_lpn := 'N';
   x_subinventory_code := p_subinventory_code;

   IF l_project_id = 0 THEN
      l_project_id := NULL;
   END IF;

   IF l_task_id = 0 THEN
      l_task_id := NULL;
   END IF;
  debug('Validating Loc/LPN with following params');
  debug('p_allow_locator_change ==> '||p_allow_locator_change);
  debug('p_is_loc_or_lpn        ==> '||p_is_loc_or_lpn);
   -- If p_is_loc_or_lpn, only then check if the entered value is
   -- an LPN
   IF p_is_loc_or_lpn = 'EITHER' THEN

      IF (g_debug = 1) THEN
         debug('Check if entered value is an LPN', 'wms_pick_load_ui.validate_locator');
      END IF;
      IF p_allow_locator_change = 'N' THEN
        IF p_serial_allocated = 'Y' THEN
           wms_lpn_lovs.get_pick_load_serial_lpn_lov
             (x_lpn_lov             => l_lpns,
              p_lpn                 => p_locator_lpn,
              p_organization_id     => p_organization_id,
              p_revision            => p_revision,
              p_inventory_item_id   => p_inventory_item_id,
              p_cost_group_id       => 0,
              p_subinventory_code   => p_subinventory_code,
              p_locator_id          => p_suggested_loc_id,
              p_transaction_temp_id => p_transaction_temp_id);
         ELSE
           wms_lpn_lovs.get_pick_load_lpn_lov
             (x_lpn_lov           => l_lpns,
              p_lpn               => p_locator_lpn,
              p_organization_id   => p_organization_id,
              p_revision          => p_revision,
              p_inventory_item_id => p_inventory_item_id,
              p_cost_group_id     => 0,
              p_subinventory_code => p_subinventory_code,
              p_locator_id        => p_suggested_loc_id,
              p_project_id        => l_project_id,
              p_task_id           => l_task_id);
          END IF;
      ELSIF p_allow_locator_change = 'P' THEN
        IF p_serial_allocated = 'Y' THEN
           wms_lpn_lovs.get_sub_apl_serial_lpn_lov
             (x_lpn_lov             => l_lpns,
              p_lpn                 => p_locator_lpn,
              p_organization_id     => p_organization_id,
              p_revision            => p_revision,
              p_inventory_item_id   => p_inventory_item_id,
              p_subinventory_code   => p_subinventory_code,
              p_transaction_temp_id => p_transaction_temp_id);
         ELSE
           wms_lpn_lovs.get_sub_apl_lpn_lov
             (x_lpn_lov           => l_lpns,
              p_lpn               => p_locator_lpn,
              p_organization_id   => p_organization_id,
              p_revision          => p_revision,
              p_inventory_item_id => p_inventory_item_id,
              p_subinventory_code => p_subinventory_code,
              p_project_id        => l_project_id,
              p_task_id           => l_task_id);
          END IF;

      ELSIF p_allow_locator_change = 'C' THEN
        IF p_serial_allocated = 'Y' THEN
           wms_lpn_lovs.get_all_apl_serial_lpn_lov
             (x_lpn_lov             => l_lpns,
              p_lpn                 => p_locator_lpn,
              p_organization_id     => p_organization_id,
              p_revision            => p_revision,
              p_inventory_item_id   => p_inventory_item_id,
              p_transaction_temp_id => p_transaction_temp_id);
         ELSE
           wms_lpn_lovs.get_all_apl_lpn_lov
             (x_lpn_lov           => l_lpns,
              p_lpn               => p_locator_lpn,
              p_organization_id   => p_organization_id,
              p_revision          => p_revision,
              p_inventory_item_id => p_inventory_item_id,
              p_project_id        => l_project_id,
              p_task_id           => l_task_id);
          END IF;
      END IF;




        LOOP
           FETCH l_lpns INTO l_lpn_rec;
              EXIT WHEN l_lpns%notfound;

              IF l_lpn_rec.license_plate_number = p_locator_lpn THEN
                 x_is_valid_lpn := 'Y';
                 x_lpn_id := l_lpn_rec.lpn_id;
                 x_is_lpn_controlled := 'Y';
                 x_locator_id := l_lpn_rec.locator_id;
                 x_subinventory_code := l_lpn_rec.subinventory_code;
                 x_locator := INV_PROJECT.GET_LOCSEGS(l_lpn_rec.concatenated_segments);
                 EXIT;
              END IF;

       END LOOP;
   END IF;

   -- If locator change is not allowed, error out if the entered LPN is
   -- from a different locator
   IF x_locator_id IS NOT NULL AND x_locator_id <> p_suggested_loc_id THEN
      IF p_allow_locator_change = 'N' THEN
         IF (g_debug = 1) THEN
            debug('Locator change is not allowed', 'wms_pick_load_ui.validate_locator');
         END IF;
         fnd_message.set_name('WMS', 'WMS_INVALID_VALUE');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
      ELSIF p_allow_locator_change IN ('P', 'C') THEN
        return;
      END IF;
   END IF;

 -- for locator alias bug.

 l_locator_lpn := p_locator_lpn;

IF x_is_valid_lpn <> 'Y' THEN

   BEGIN

   select ENABLE_LOCATOR_ALIAS INTO l_alias_enabled
   from MTL_SECONDARY_INVENTORIES
   where SECONDARY_INVENTORY_NAME = p_subinventory_code
   and ORGANIZATION_ID = p_organization_id;

   IF (Nvl(l_alias_enabled, 'N') = 'Y') THEN

   select concatenated_segments INTO l_locator_lpn
   from wms_item_locations_kfv
   where alias =p_locator_lpn
   and SUBINVENTORY_CODE = p_subinventory_code
   and ORGANIZATION_ID = p_organization_id;


   END IF;

   EXCEPTION
  WHEN No_Data_Found THEN
  fnd_message.set_name('WMS', 'WMS_INVALID_VALUE');
   fnd_msg_pub.add;
   RAISE fnd_api.g_exc_error;

   WHEN OTHERS THEN
   debug('other exceptions raised');
   END;


END IF;

-- locator alias bug


   -- If Loc Change = No or Partail, check for the entered Loc in the Sub confirmed
   IF p_allow_locator_change IN ('N', 'P')  THEN

      IF (g_debug = 1) THEN
         debug('Validating Loc with Loc Change = N (No), P (Partial - Diff loc from the same sub is valid)', 'wms_pick_load_ui.validate_locator');
      END IF;

      /* Bug 4990550 changing the call to the newly added procedure 'get_pickload_loc' in inv_ui_item_sub_loc_lovs since the locator is no longer an LOV from 11510*/
      inv_ui_item_sub_loc_lovs.get_pickload_loc
        (x_locators               => l_locators,
         p_organization_id        => p_organization_id,
         p_subinventory_code      => p_subinventory_code,
         p_restrict_locators_code => p_restrict_locators_code,
         p_inventory_item_id      => p_inventory_item_id,
	 p_concatenated_segments  => l_locator_lpn||'%',  -- Bug 7225845
        -- p_concatenated_segments  => p_locator_lpn||'%',  -- Bug 7225845
         p_transaction_type_id    => p_transaction_type_id,
         p_wms_installed          => 'Y',
         p_project_id             => l_project_id,
         p_task_id                => l_task_id);

      LOOP
         FETCH l_locators INTO l_loc_rec;
         EXIT WHEN l_locators%notfound;
         debug('l_loc_rec.locator : '||l_loc_rec.locator);
         debug('INV_PROJECT.GET_LOCSEGS(l_loc_rec.locator) : '||INV_PROJECT.GET_LOCSEGS(l_loc_rec.locator));
       --  IF  l_loc_rec.locator = p_locator_lpn OR p_locator_lpn = INV_PROJECT.GET_LOCSEGS(l_loc_rec.locator) THEN  -- Bug 7225845
           IF  l_loc_rec.locator = l_locator_lpn OR l_locator_lpn = INV_PROJECT.GET_LOCSEGS(l_loc_rec.locator) THEN -- Bug 7225845
            x_is_valid_locator := 'Y';
            x_locator_id := l_loc_rec.locator_id;
            x_subinventory_code := p_subinventory_code;
            x_locator := INV_PROJECT.GET_LOCSEGS(l_loc_rec.locator);
            EXIT;
         END IF;

      END LOOP;
       IF p_allow_locator_change = 'N'  THEN
         -- If locator entered is not found, or is different from the sug loc
         -- then raise exception
         IF (x_locator_id IS NULL OR x_locator_id <> p_suggested_loc_id) THEN
            fnd_message.set_name('WMS', 'WMS_INVALID_VALUE');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
         END IF;
       ELSIF p_allow_locator_change = 'P' THEN
         -- If locator entered is not found, or is in different sub then raise exception
         IF (x_locator_id IS NULL OR x_subinventory_code <> p_subinventory_code) THEN
            fnd_message.set_name('WMS', 'WMS_INVALID_VALUE');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
         END IF;
       END IF;
   -- If Loc Change = Complete, check for the entered Loc in any sub
   --   (filtering on sub not required)
   ELSIF p_allow_locator_change = 'C' THEN
      IF (g_debug = 1) THEN
         debug('Validating Loc with Loc Change = C (Loc from even a diff sub is valid)', 'wms_pick_load_ui.validate_locator');
      END IF;

      inv_ui_item_sub_loc_lovs.get_pickload_all_loc_lov
        (x_locators               => l_locators,
         p_organization_id        => p_organization_id,
         p_restrict_locators_code => p_restrict_locators_code,
         p_inventory_item_id      => p_inventory_item_id,
	 p_concatenated_segments  => l_locator_lpn||'%',  -- Bug 7225845
        -- p_concatenated_segments  => p_locator_lpn||'%',  -- Bug 7225845
         p_transaction_type_id    => p_transaction_type_id,
         p_wms_installed          => 'Y',
         p_project_id             => l_project_id,
         p_task_id                => l_task_id);

      LOOP
         FETCH l_locators INTO l_loc_sub_rec;
         EXIT WHEN l_locators%notfound;

        -- IF  INV_PROJECT.GET_LOCSEGS(l_loc_sub_rec.locator) = p_locator_lpn OR p_locator_lpn = l_loc_sub_rec.locator THEN  -- Bug 7225845
	IF  INV_PROJECT.GET_LOCSEGS(l_loc_sub_rec.locator) = l_locator_lpn OR l_locator_lpn = l_loc_sub_rec.locator THEN  -- Bug 7225845
            x_is_valid_locator := 'Y';
            x_locator_id := l_loc_sub_rec.locator_id;
            x_subinventory_code := l_loc_sub_rec.subinventory;
            x_locator := INV_PROJECT.GET_LOCSEGS(l_loc_sub_rec.locator);
            EXIT;
         END IF;

      END LOOP;
      -- If locator entered is not found, or is different from the sug loc
      -- then raise exception
       IF (x_locator_id IS NULL) THEN
          fnd_message.set_name('WMS', 'WMS_INVALID_VALUE');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
       END IF;
   END IF;

   -- If the subinventory is now different from the suggested subinventory,
   -- get the new lpn controlled value
   IF x_subinventory_code <> p_suggested_sub THEN

      IF (g_debug = 1) THEN
         debug('Check if subinventory is LPN controlled', 'wms_pick_load_ui.validate_locator');
      END IF;

      SELECT Decode(lpn_controlled_flag, 1, 'Y', 'N')
        INTO x_is_lpn_controlled
        FROM mtl_secondary_inventories
        WHERE organization_id = p_organization_id
        AND secondary_inventory_name = x_subinventory_code;
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN

      IF (g_debug = 1) THEN
         debug('Error', 'wms_pick_load_ui.validate_locator');
      END IF;

      x_return_status := 'E';

      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);

   WHEN OTHERS THEN
      IF (g_debug = 1) THEN
         debug('Unexpected Error: ' || Sqlerrm, 'wms_pick_load_ui.validate_locator');
      END IF;

      x_return_status := 'U';

      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);

END validate_locator_lpn;

END wms_pick_load_ui;

/
