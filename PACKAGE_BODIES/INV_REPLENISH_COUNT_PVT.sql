--------------------------------------------------------
--  DDL for Package Body INV_REPLENISH_COUNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_REPLENISH_COUNT_PVT" AS
  /* $Header: INVVRPCB.pls 120.1.12010000.2 2008/07/29 13:49:46 ptkumar ship $ */

  /**
   *  Package     : INV_REPLENISH_COUNT_PVT
   *  File        : INVVRPCB.pls
   *  Content     :
   *  Description :
   *  Notes       :
   *  Modified    : Mon Aug 25 12:17:54 GMT+05:30 2003
   *
   *  Package Body for INV_REPLENISH_COUNT_PVT
   *  This file contains procedures and functions needed for
   *  Replenishment Count being used in the mobile WMS/INV applications.
   *  This package also includes APIs to process and report Count entries
   *  for a Replenishment Count.
   **/

  /**
   *   Globals constant holding the package name.
   **/
  g_pkg_name CONSTANT VARCHAR2(30)              := 'INV_REPLENISH_COUNT_PVT';
  g_version_printed   BOOLEAN                   := FALSE;
  g_user_name         fnd_user.user_name%TYPE   := fnd_global.user_name;

  /**
   *  This Procedure is used to print the Debug Messages to log file.
   *  @param   p_message   Debug Message
   *  @param   p_module    Module
   *  @param   p_level     Debug Level
   **/
  PROCEDURE print_debug(p_message IN VARCHAR2, p_module IN VARCHAR2, p_level IN NUMBER) IS
  BEGIN
    IF NOT g_version_printed THEN
      inv_log_util.TRACE('$Header: INVVRPCB.pls 120.1.12010000.2 2008/07/29 13:49:46 ptkumar ship $', g_pkg_name || '.' || p_module, 1);
      g_version_printed  := TRUE;
    END IF;

    inv_log_util.TRACE(g_user_name || ':  ' || p_message, g_pkg_name || '.' || p_module, p_level);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END print_debug;

  /**
   *  This Procedure is used to insert values into table mtl_replenish_lines.
   *  @param   x_return_status         Return Status
   *  @param   x_msg_count             Message Count
   *  @param   x_msg_data              Message Data
   *  @param   p_organization_id       Organization Id
   *  @param   p_replenish_header_id   Replenishment Count Header Id
   *  @param   p_locator_id            Locator Id
   *  @param   p_item_id               Item ID
   *  @param   p_count_type_code       Count Type Code
   *  @param   p_count_quantity        Count Quantity
   *  @param   p_count_uom_code        Count Uom Code
   *  @param   p_primary_uom_code      Primary Uom Code
   *  @param   p_count_secondary_uom_code  Secondary Uom Code<br>
   *  @param   p_count_secondary_quantity  Secondary Quantity<br>
   **/
  PROCEDURE insert_row(
    x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_organization_id     IN            NUMBER
  , p_replenish_header_id IN            NUMBER
  , p_locator_id          IN            NUMBER
  , p_item_id             IN            NUMBER
  , p_count_type_code     IN            NUMBER
  , p_count_quantity      IN            NUMBER
  , p_count_uom_code      IN            VARCHAR2
  , p_primary_uom_code    IN            VARCHAR2
  , p_count_secondary_uom_code IN            VARCHAR2  -- INVCONV, NSRIVAST
  , p_count_secondary_quantity IN            NUMBER    -- INVCONV, NSRIVAST
  ) IS
    l_proc CONSTANT VARCHAR2(30) := 'INSERT_ROW';
    l_trace_on      NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF l_trace_on = 1 THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || '   p_organization_id      : '
        || p_organization_id
        || fnd_global.local_chr(10)
        || '   p_replenish_header_id  : '
        || p_replenish_header_id
        || fnd_global.local_chr(10)
        || '   p_locator_id           : '
        || p_locator_id
        || fnd_global.local_chr(10)
        || '   p_item_id              : '
        || p_item_id
        || fnd_global.local_chr(10)
        || '   p_count_type_code      : '
        || p_count_type_code
        || fnd_global.local_chr(10)
        || '   p_count_quantity       : '
        || p_count_quantity
        || fnd_global.local_chr(10)
        || '   p_count_uom_code       : '
        || p_count_uom_code
        || fnd_global.local_chr(10)
        || '   p_primary_uom_code     : '
        || p_primary_uom_code
        || fnd_global.local_chr(10)
      , l_proc
      , 9
      );
    END IF;

    fnd_message.set_name('INV', 'INV_RC_CREATED_FROM_MOBILE');

    INSERT INTO mtl_replenish_lines
                (
                 replenishment_line_id
               , replenishment_header_id
               , organization_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , locator_id
               , inventory_item_id
               , count_type_code
               , count_quantity
               , count_uom_code
               , supply_quantity
               , source_type
               , source_organization_id
               , source_subinventory
               , reorder_quantity
               , expense_account
               , encumbrance_account
               , REFERENCE
               , error_flag
               , primary_uom_count_quantity
               , primary_uom_code
               -- INCVONV, NSRIVAST
               , secondary_uom_code
               , secondary_uom_count_quantity
               -- INCVONV, NSRIVAST
                )
         VALUES (
                 mtl_replenish_lines_s.NEXTVAL
               , p_replenish_header_id
               , p_organization_id
               , SYSDATE
               , fnd_global.user_id
               , SYSDATE
               , fnd_global.user_id
               , fnd_global.login_id
               , p_locator_id
               , p_item_id
               , p_count_type_code
               , p_count_quantity
               , p_count_uom_code
               , NULL
               , NULL
               , NULL
               , NULL
               , NULL
               , NULL
               , NULL
               , fnd_message.get
               , NULL
               , inv_convert.inv_um_convert(p_item_id, 6, p_count_quantity, p_count_uom_code, p_primary_uom_code, NULL, NULL)
               , p_primary_uom_code
               -- INCVONV, NSRIVAST
               , p_count_secondary_uom_code
               , p_count_secondary_quantity
               -- INCVONV, NSRIVAST
                );

    IF (SQL%NOTFOUND) THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    ELSE
      x_return_status  := fnd_api.g_ret_sts_success;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;
  END insert_row;

  /**
   *  This Procedure is used to update table mtl_replenish_lines.
   *  @param   x_return_status         Return Status
   *  @param   x_msg_count             Message Count
   *  @param   x_msg_data              Message Data
   *  @param   p_item_id               Item ID
   *  @param   p_replenish_header_id   Replenishment Count Header Id
   *  @param   p_replenish_line_id     Replenishment Count Line Id
   *  @param   p_count_quantity        Count Quantity
   *  @param   p_primary_uom_code      Primary Uom Code
   *  @param   p_count_secondary_quantity  Secondary Quantity<br>
   **/
  PROCEDURE update_row(
    x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_item_id             IN            NUMBER
  , p_replenish_header_id IN            NUMBER
  , p_replenish_line_id   IN            NUMBER
  , p_count_quantity      IN            NUMBER
  , p_count_uom_code      IN            VARCHAR2
  , p_count_secondary_quantity IN            NUMBER    -- INVCONV, NSRIVAST
  ) IS
    l_proc CONSTANT VARCHAR2(30) := 'UPDATE_ROW';
    l_trace_on      NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF l_trace_on = 1 THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || '   p_replenish_header_id  : '
        || p_replenish_header_id
        || fnd_global.local_chr(10)
        || '   p_replenish_line_id    : '
        || p_replenish_line_id
        || fnd_global.local_chr(10)
        || '   p_count_quantity       : '
        || p_count_quantity
        || fnd_global.local_chr(10)
        || '   p_count_uom_code       : '
        || p_count_uom_code
        || fnd_global.local_chr(10)
      , l_proc
      , 9
      );
    END IF;

    -- Convert the count quantity into the item primary uom quantity.
    UPDATE mtl_replenish_lines
       SET last_update_date = SYSDATE
         , last_updated_by = fnd_global.user_id
         , last_update_login = fnd_global.login_id
         , count_quantity = p_count_quantity
         , count_uom_code = p_count_uom_code
         , primary_uom_count_quantity =
                                  inv_convert.inv_um_convert(p_item_id, 6, p_count_quantity, p_count_uom_code, primary_uom_code, NULL, NULL)
         , secondary_uom_count_quantity = p_count_secondary_quantity -- INVCONV, NSRIVAST
     WHERE replenishment_header_id = p_replenish_header_id
       AND replenishment_line_id = p_replenish_line_id;

    IF (SQL%NOTFOUND) THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    ELSE
      x_return_status  := fnd_api.g_ret_sts_success;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;
  END update_row;

  /** This Procedure is used to fetch the Replenishment Count lines for the user input.
   *  @param   x_return_status               Return Status
   *  @param   x_msg_count                   Message Count
   *  @param   x_msg_data                    Message Data
   *  @param   x_replenish_count_lines_lov   Replenish Count Lines LOV
   *  @param   p_replenish_header_id         Replenishment Header Id
   *  @param   p_use_loc_pick_seq            Use Locator Picking Sequence or not
   *  @param   p_organization_id             Organization ID
   *  @param   p_subinventory_code           Subinventory Code
   *  @param   p_planning_level              Planning level of the subinventory
   *  @param   p_quantity_tracked            Qauntity Tracked Flag of the Subinventory
   **/
  PROCEDURE fetch_count_lines(
    x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_replenish_count_lines OUT NOCOPY    t_genref
  , p_replenish_header_id   IN            NUMBER
  , p_use_loc_pick_seq      IN            VARCHAR2
  , p_organization_id       IN            NUMBER
  , p_subinventory_code     IN            VARCHAR2
  , p_planning_level        IN            NUMBER
  , p_quantity_tracked      IN            NUMBER
  ) IS
    l_proc CONSTANT VARCHAR2(30) := 'FETCH_COUNT_LINES';
    l_count         NUMBER       := 0;
    l_trace_on      NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF l_trace_on = 1 THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || '   p_replenish_header_id     : '
        || p_replenish_header_id
        || fnd_global.local_chr(10)
        || '   p_use_loc_pick_seq        : '
        || p_use_loc_pick_seq
        || fnd_global.local_chr(10)
        || '   p_organization_id         : '
        || p_organization_id
        || fnd_global.local_chr(10)
        || '   p_subinventory_code       : '
        || p_subinventory_code
        || fnd_global.local_chr(10)
        || '   p_planning_level          : '
        || p_planning_level
        || fnd_global.local_chr(10)
        || '   p_quantity_tracked        : '
        || p_quantity_tracked
        || fnd_global.local_chr(10)
      , l_proc
      , 9
      );
    END IF;

    IF p_planning_level = 1 THEN   -- PAR level Count
      /*Bug#5612236. In the below query, replaced 'MTL_SYSTEM_ITEMS_KFV' with
        'MTL_SYSTEM_ITEMS_VL'.*/
      OPEN x_replenish_count_lines
       FOR
         SELECT   msiv.inventory_item_id item_id
                , msiv.concatenated_segments item
                , mil.inventory_location_id locator_id
                , inv_project.get_locsegs(mil.inventory_location_id, mil.organization_id) LOCATOR
                , mrl.count_type_code count_type_code
                , ml.meaning count_type
                , mrl.replenishment_line_id replenishment_line_id
                , msiv.description item_description
                , msiv.primary_uom_code primary_uom_code
             FROM mtl_item_locations mil, mtl_system_items_vl msiv, mtl_secondary_locators msl, mtl_replenish_lines mrl, mfg_lookups ml
            WHERE msl.inventory_item_id = msiv.inventory_item_id
              AND msl.organization_id = msiv.organization_id
              AND msl.secondary_locator = mil.inventory_location_id
              AND msl.organization_id = mil.organization_id
              AND msl.organization_id = p_organization_id
              AND msl.subinventory_code = p_subinventory_code
              AND mrl.replenishment_header_id(+) = p_replenish_header_id
              AND ml.lookup_type(+) = 'MTL_COUNT_TYPES'
              AND ml.lookup_code(+) = mrl.count_type_code
              AND mrl.organization_id(+) = msl.organization_id
              AND mrl.inventory_item_id(+) = msl.inventory_item_id
--            AND mil.inventory_location_id = NVL(mil.physical_location_id, mil.inventory_location_id)	-- Commented for Bug 6798138
              AND mrl.locator_id(+) = msl.secondary_locator
              AND(
                  mrl.count_type_code IS NULL
                  OR mrl.count_type_code = 2
                  OR(mrl.count_type_code = 1
                     AND p_quantity_tracked = 2
                     AND msl.maximum_quantity IS NOT NULL)
                 )
              AND mrl.count_quantity IS NULL
              AND mrl.error_flag IS NULL
         ORDER BY DECODE(p_use_loc_pick_seq, 'YES', mil.picking_order, replenishment_line_id), item;
    ELSE   -- Subinventory Level Count
      /*Bug#5612236. In the below query, replaced 'MTL_SYSTEM_ITEMS_KFV' with
        'MTL_SYSTEM_ITEMS_VL'.*/
      OPEN x_replenish_count_lines
       FOR
         SELECT   mis.inventory_item_id item_id
                , msiv.concatenated_segments item
                , TO_NUMBER(NULL) locator_id
                , NULL LOCATOR
                , mrl.count_type_code count_type_code
                , ml.meaning count_type
                , mrl.replenishment_line_id replenishment_line_id
                , msiv.description item_description
                , msiv.primary_uom_code primary_uom_code
             FROM mtl_system_items_vl msiv, mtl_item_sub_inventories mis, mtl_replenish_lines mrl, mfg_lookups ml
            WHERE mis.inventory_item_id = msiv.inventory_item_id
              AND mis.organization_id = msiv.organization_id
              AND mis.organization_id = p_organization_id
              AND mis.secondary_inventory = p_subinventory_code
              AND mrl.replenishment_header_id(+) = p_replenish_header_id
              AND ml.lookup_type(+) = 'MTL_COUNT_TYPES'
              AND ml.lookup_code(+) = mrl.count_type_code
              AND mrl.organization_id(+) = mis.organization_id
              AND mrl.inventory_item_id(+) = mis.inventory_item_id
              AND(
                  mrl.count_type_code IS NULL
                  OR mrl.count_type_code = 2
                  OR(mrl.count_type_code = 1
                     AND p_quantity_tracked = 2
                     AND mis.inventory_planning_code = 2)
                 )
              AND mrl.count_quantity IS NULL
              AND mrl.error_flag IS NULL
         ORDER BY replenishment_line_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;
  END fetch_count_lines;

  /** This procedure is used to get the Replenishment Count Name if the Subinventory and Organization passed
   *  as input has only one active Replenishment Count.
   *  @param    x_return_status         Return Status
   *  @param    x_msg_count             Message Count
   *  @param    x_msg_data              Message Data
   *  @param    x_replenish_count_name  Replenishment Count Name for the Subinventory and Organization passed
   *                                    if there exists only obe active Replenishment Count.
   *                                    NULL - Otherwise.
   *  @param    p_organization_id       Organization ID
   *  @param    p_subinventory_code     Subinventory Code
   *  @param    p_planning_level        Subinventory Planning Level
  **/
  PROCEDURE get_replenish_count_name(
    x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , x_replenish_count_name OUT NOCOPY    VARCHAR2
  , p_organization_id      IN            NUMBER
  , p_subinventory_code    IN            VARCHAR2
  , p_planning_level       IN            NUMBER
  ) IS
    l_func_name CONSTANT VARCHAR2(30) := 'GET_REPLENISH_COUNT_NAME';
    l_trace_on           NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF l_trace_on = 1 THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || '   p_organization_id     : '
        || p_organization_id
        || fnd_global.local_chr(10)
        || '   p_subinventory_code     : '
        || p_subinventory_code
        || fnd_global.local_chr(10)
        || '   p_planning_level     : '
        || p_planning_level
      , l_func_name
      , 9
      );
    END IF;

    SELECT replenishment_count_name
      INTO x_replenish_count_name
      FROM mtl_replenish_headers mrh
     WHERE mrh.organization_id = p_organization_id
       AND mrh.subinventory_code = p_subinventory_code
       AND mrh.process_status = 1
       AND mrh.count_mode = 1
       AND(
           (
            p_planning_level = 1
            AND NOT EXISTS(SELECT 1
                             FROM mtl_replenish_lines mrl
                            WHERE mrl.replenishment_header_id = mrh.replenishment_header_id
                              AND mrl.locator_id IS NULL)
           )
           OR(
              p_planning_level = 2
              AND NOT EXISTS(SELECT 1
                               FROM mtl_replenish_lines mrl
                              WHERE mrl.replenishment_header_id = mrh.replenishment_header_id
                                AND mrl.locator_id IS NOT NULL)
             )
          );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_replenish_count_name  := NULL;
    WHEN TOO_MANY_ROWS THEN
      x_replenish_count_name  := NULL;
    WHEN OTHERS THEN
      x_replenish_count_name  := NULL;
      x_return_status         := fnd_api.g_ret_sts_error;
  END get_replenish_count_name;



  /** This procedure is used to check whether invalid and/or uncounted lines exist.
   *  @param    x_return_status         Return Status
   *  @param    x_msg_count             Message Count
   *  @param    x_msg_data              Message Data
   *  @param    p_replenish_header_id   Replenishment Count Header Id
   *  @param    p_quantity_tracked      Qauntity Tracked Flag of the Subinventory
   *  @param    p_planning_level        Planning level of the subinventory
   *  @param    p_subinventory_code     Subinventory Code
   *  @RETURN   NUMBER                  1 - Invalid and uncounted lines exist.
   *                                    2 - Invalid but no uncounted lines exist.
   *                                    3 - No invalid but uncounted lines exist.
   *                                    4 - No invalid and no uncounted lines exist.
  **/
   FUNCTION invalid_uncounted_lines_exist(
    x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_replenish_header_id IN            NUMBER
  , p_quantity_tracked    IN            NUMBER
  , p_planning_level      IN            NUMBER
  , p_subinventory_code   IN            VARCHAR2
  )
    RETURN NUMBER IS
    l_func_name  CONSTANT VARCHAR2(30) := 'invalid_uncounted_lines_exist';
    l_record_exists       NUMBER       := 0;
    l_error_record_exists NUMBER       := 0;
    l_trace_on            NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF l_trace_on = 1 THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || '   p_replenish_header_id     : '
        || p_replenish_header_id
        || fnd_global.local_chr(10)
        || '   p_quantity_tracked     : '
        || p_quantity_tracked
        || fnd_global.local_chr(10)
        || '   p_planning_level     : '
        || p_planning_level
        || fnd_global.local_chr(10)
        || '   p_subinventory_code     : '
        || p_subinventory_code
        || fnd_global.local_chr(10)
      , l_func_name
      , 9
      );
    END IF;

    BEGIN
      SELECT 1
        INTO l_record_exists
        FROM DUAL
       WHERE EXISTS(SELECT 1
                      FROM mtl_replenish_lines
                     WHERE replenishment_header_id = p_replenish_header_id
                       AND count_quantity IS NULL
                       AND error_flag IS NULL);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_record_exists  := 0;
      WHEN OTHERS THEN
        x_return_status  := fnd_api.g_ret_sts_error;
    END;

    BEGIN
      SELECT 1
        INTO l_error_record_exists
        FROM DUAL
       WHERE EXISTS(
               SELECT 1
                 FROM mtl_replenish_lines mrl
                WHERE replenishment_header_id = p_replenish_header_id
                  AND(
                      (count_type_code = 1
                       AND p_quantity_tracked = 1)
                      OR(
                         p_planning_level = 1
                         AND(
                             locator_id IS NULL
                             OR count_type_code = 3
                             OR NOT EXISTS(
                                 SELECT maximum_quantity
                                   FROM mtl_secondary_locators msl, mtl_item_locations mil, mtl_system_items msi
                                  WHERE msl.inventory_item_id = mrl.inventory_item_id
                                    AND msl.secondary_locator = mrl.locator_id
                                    AND msl.organization_id = mrl.organization_id
                                    AND msi.inventory_item_id = msl.inventory_item_id
                                    AND msi.organization_id = msl.organization_id
                                    AND mil.inventory_location_id = msl.secondary_locator
                                    AND mil.organization_id = msl.organization_id
                                    AND msi.inventory_item_flag = 'Y'
                                    AND msi.stock_enabled_flag = 'Y'
                                    AND NVL(mil.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE))
                             OR(
                                EXISTS(
                                  SELECT maximum_quantity
                                    FROM mtl_secondary_locators msl, mtl_item_locations mil, mtl_system_items msi
                                   WHERE msl.inventory_item_id = mrl.inventory_item_id
                                     AND msl.secondary_locator = mrl.locator_id
                                     AND msl.organization_id = mrl.organization_id
                                     AND msi.inventory_item_id = msl.inventory_item_id
                                     AND msi.organization_id = msl.organization_id
                                     AND mil.inventory_location_id = msl.secondary_locator
                                     AND mil.organization_id = msl.organization_id
                                     AND msi.inventory_item_flag = 'Y'
                                     AND msi.stock_enabled_flag = 'Y'
                                     AND NVL(mil.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                                     AND maximum_quantity IS NULL)
                                AND count_type_code IN(1, 4)
                               )
                            )
                        )
                      OR(
                         p_planning_level <> 1
                         AND(
                             locator_id IS NOT NULL
                             OR count_type_code = 4
                             OR(
                                NOT EXISTS(
                                  SELECT mis.inventory_planning_code
                                    FROM mtl_item_sub_inventories mis, mtl_system_items msi
                                   WHERE mis.inventory_item_id = mrl.inventory_item_id
                                     AND mis.secondary_inventory = p_subinventory_code
                                     AND mis.organization_id = mrl.organization_id
                                     AND msi.inventory_item_id = mis.inventory_item_id
                                     AND msi.organization_id = mis.organization_id
                                     AND msi.inventory_item_flag = 'Y'
                                     AND msi.stock_enabled_flag = 'Y'
                                     AND mis.inventory_planning_code IN(2, 6))
                               )
                             OR(
                                EXISTS(
                                  SELECT mis.inventory_planning_code
                                    FROM mtl_item_sub_inventories mis, mtl_system_items msi
                                   WHERE mis.inventory_item_id = mrl.inventory_item_id
                                     AND mis.secondary_inventory = p_subinventory_code
                                     AND mis.organization_id = mrl.organization_id
                                     AND msi.inventory_item_id = mis.inventory_item_id
                                     AND msi.organization_id = mis.organization_id
                                     AND msi.inventory_item_flag = 'Y'
                                     AND msi.stock_enabled_flag = 'Y'
                                     AND mis.inventory_planning_code = 6)
                                AND count_type_code IN(1, 3)
                               )
                            )
                        )
                     ));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_error_record_exists  := 0;
      WHEN OTHERS THEN
        x_return_status  := fnd_api.g_ret_sts_error;
    END;

    IF l_trace_on = 1 THEN
        print_debug('Error record exists : ' || l_error_record_exists, l_func_name, 9);
        print_debug('Invalid record exists : ' || l_record_exists, l_func_name, 9);
    END IF;

    IF l_error_record_exists = 1
       AND l_record_exists = 1 THEN
      RETURN 1;
    ELSIF l_error_record_exists = 1
          AND l_record_exists <> 1 THEN
      RETURN 2;
    ELSIF l_error_record_exists <> 1
          AND l_record_exists = 1 THEN
      RETURN 3;
    ELSE
      RETURN 4;
    END IF;
  END invalid_uncounted_lines_exist;

  /** This function returns if the Replenishment Count passed as input is a valid
   *  one for the passed subinventory planning level.
   *  @param    x_return_status         Return Status
   *  @param    x_msg_count             Message Count
   *  @param    x_msg_data              Message Data
   *  @param    p_replenish_header_id   Replenishment Count Header Id
   *  @param    p_planning_level        Subinventory Planning Level
   *  @RETURN   NUMBER                  1 - Count is valid.
   *                                    2 - Count is invalid.
  **/
  FUNCTION is_count_valid(
    x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_replenish_header_id IN            NUMBER
  , p_planning_level      IN            NUMBER
  )
    RETURN NUMBER IS
    l_func_name CONSTANT VARCHAR2(30) := 'IS_COUNT_VALID';
    l_count_valid        NUMBER       := 1;
    l_trace_on           NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF l_trace_on = 1 THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || '   p_replenish_header_id     : '
        || p_replenish_header_id
        || fnd_global.local_chr(10)
        || '   p_planning_level          : '
        || p_planning_level
        || fnd_global.local_chr(10)
      , l_func_name
      , 9
      );
    END IF;

    SELECT 2
      INTO l_count_valid
      FROM DUAL
     WHERE EXISTS(
             SELECT 1
               FROM mtl_replenish_lines
              WHERE replenishment_header_id = p_replenish_header_id
                AND((p_planning_level = 1
                     AND locator_id IS NULL)
                    OR(p_planning_level = 2
                       AND locator_id IS NOT NULL)));

    RETURN l_count_valid;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN l_count_valid;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;
  END is_count_valid;

  /** This procedure submits the passed in Replenishment Count
   *  for processing and Reporting.
   *  @param    x_return_status         Return Status
   *  @param    x_msg_count             Message Count
   *  @param    x_msg_data              Message Data
   *  @param    x_proces_request_id     Process Request Id
   *  @param    p_replenish_header_id   Replenishment Count Header Id
   *  @param    p_organization_id       Organization Id<br>
   **/
  PROCEDURE process_report_count(
    x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , x_process_request_id  OUT NOCOPY    NUMBER
  , p_replenish_header_id IN            NUMBER
  , p_organization_id     IN            NUMBER
  ) IS
    l_proc CONSTANT VARCHAR2(30) := 'PROCESS_REPORT_COUNT';
    l_trace_on      NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
  BEGIN
    x_return_status       := fnd_api.g_ret_sts_success;

    IF l_trace_on = 1 THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || '  p_replenish_header_id      : '
        || p_replenish_header_id
        || fnd_global.local_chr(10)
        || '   p_organization_id         : '
        || p_organization_id
        || fnd_global.local_chr(10)
      , l_proc
      , 9
      );
    END IF;

    x_process_request_id  := fnd_request.submit_request('INV', 'INCRPR', '', '', FALSE, TO_CHAR(2), TO_CHAR(p_replenish_header_id),'4', CHR(0));

    IF x_process_request_id <= 0 THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    ELSE
      UPDATE mtl_replenish_headers
         SET process_status = 2
       WHERE replenishment_header_id = p_replenish_header_id;

      x_return_status  := fnd_api.g_ret_sts_success;

      IF l_trace_on = 1 THEN
        print_debug('Process Request Id : ' || x_process_request_id, l_proc, 9);
      END IF;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;
  END process_report_count;
END inv_replenish_count_pvt;

/
