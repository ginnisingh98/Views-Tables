--------------------------------------------------------
--  DDL for Package Body INV_REPLENISH_COUNT_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_REPLENISH_COUNT_LOVS" AS
  /* $Header: INVRPCLB.pls 120.2.12010000.3 2009/11/30 12:17:48 ksivasa ship $ */

  /**  Package   : INV_REPLENISH_COUNT_LOVS
    *  File        : INVRPCLB.pls
    *  Content     :
    *  Description :
    *  Notes       :
    *  Modified    : Mon Aug 25 12:17:54 GMT+05:30 2003
    *
    *  Body of package inv_replenish_count_lovs
    *  This file contains Replenishment Count LOVS being used by the
    *  mobile WMS/INV applications. It is being called from java
    *  LOV beans to populate the LOV.
    *
    **/

  /**
   * Global constant holding the package name
   **/
  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_REPLENISH_COUNT_LOVS';
  g_version_printed BOOLEAN := FALSE;
  g_user_name fnd_user.user_name%TYPE := fnd_global.user_name;
  g_trace_on NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);

  /**
   *  This Procedure is used to print the Debug Messages to log file.
   *  @param   p_message   Debug Message
   *  @param   p_module    Module
   *  @param   p_level     Debug Level
   **/
  PROCEDURE print_debug(
    p_message IN VARCHAR2
  , p_module  IN VARCHAR2
  , p_level   IN NUMBER) IS
  BEGIN
    IF NOT g_version_printed THEN
      inv_log_util.trace('$Header: INVRPCLB.pls 120.2.12010000.3 2009/11/30 12:17:48 ksivasa ship $', g_pkg_name|| '.' || p_module, 1);
      g_version_printed := TRUE;
    END IF;
    inv_log_util.TRACE(g_user_name || ':  ' || p_message, g_pkg_name || '.' || p_module, p_level);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END print_debug;

  /**
   * This procedure returns valid Replenishment Count Names for counting in mobile.
   * @param   x_replenish_count_lov   Returns LOV rows as a reference cursor
   * @param   p_replenish_count       Restricts LOV SQL to the user input Count Name
   * @param   p_organization_id       Organization ID
   * @param   p_subinventory          Subinventory Code
   **/
  PROCEDURE get_replenish_count_lov(
    x_replenish_count_lov OUT NOCOPY t_genref
  , p_replenish_count     IN VARCHAR2
  , p_organization_id     IN NUMBER
  , p_subinventory        IN VARCHAR2
  ) IS
    l_proc CONSTANT VARCHAR2(30) := 'GET_REPLENISH_COUNT_LOV';
    l_trace_on NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
  BEGIN
    IF l_trace_on = 1 THEN
      print_debug('The input parameters are: '
                 || fnd_global.local_chr(10)
                 || '   p_replenish_count: '
                 || p_replenish_count
                 || fnd_global.local_chr(10)
                 || ',  p_organization_id: '
                 || p_organization_id
                 || ',  p_subinventory: '
                 || p_subinventory
                 || fnd_global.local_chr(10)
               , l_proc
               , 9
               );
    END IF;

    OPEN x_replenish_count_lov FOR
        SELECT mrh.replenishment_count_name
             , mrh.replenishment_header_id
             , mrh.subinventory_code
             , mrh.count_date
             , mrh.supply_cutoff_date
             , mrh.requisition_approval_type
             , mrh.process_status
             , mrh.process_mode
             , mrh.count_mode
             , mrh.error_flag
             , mrh.request_id
             , mrh.delivery_location_id
             , mrh.default_line_items
             , mrh.default_count_type_code
	          , ml.meaning default_count_type
          FROM mtl_replenish_headers mrh
             , mtl_secondary_inventories msi
	          , mfg_lookups ml
         WHERE mrh.organization_id = p_organization_id
           AND mrh.subinventory_code = NVL(p_subinventory, mrh.subinventory_code)
           AND msi.secondary_inventory_name = mrh.subinventory_code
           AND msi.organization_id = mrh.organization_id
           AND mrh.process_status = 1
           AND mrh.count_mode = 1
	        AND ml.lookup_type = 'MTL_COUNT_TYPES'
           AND mrh.default_count_type_code = ml.lookup_code
           AND mrh.replenishment_count_name LIKE p_replenish_count
           AND((msi.planning_level = 1
                AND NOT EXISTS(SELECT 1
                                 FROM mtl_replenish_lines mrl
                                WHERE mrl.replenishment_header_id = mrh.replenishment_header_id
                                  AND mrl.locator_id IS NULL
                              )
               )
               OR(msi.planning_level = 2
                  AND NOT EXISTS(SELECT 1
                                   FROM mtl_replenish_lines mrl
                                  WHERE mrl.replenishment_header_id = mrh.replenishment_header_id
                                    AND mrl.locator_id IS NOT NULL
                                 )
                  )
              )
      ORDER BY mrh.replenishment_count_name;
  END get_replenish_count_lov;

  /**
   *  This procedure returns valid Subinventories which have atleast one Min Max planned or
   *  PAR level planned item defined in the Item subinventories form.
   *  @param  x_replenish_count_subs_lov  Returns LOV rows as a reference cursor
   *  @param   p_subinventory                Subinventory Code
   *  @param   p_organization_id             Organization ID
   **/
  PROCEDURE get_replenish_count_subs_lov(
    x_replenish_count_subs_lov OUT NOCOPY t_genref
  , p_subinventory             IN VARCHAR2
  , p_organization_id          IN NUMBER) IS

    l_proc CONSTANT VARCHAR2(30) := 'GET_REPLENISH_COUNT_SUBS_LOV';
    l_trace_on NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
  BEGIN
    IF l_trace_on = 1 THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || ',  p_subinventory: '
        || p_subinventory
        || fnd_global.local_chr(10)
        || ',  p_organization_id: '
        || p_organization_id
      , l_proc
      , 9
      );
    END IF;

    OPEN x_replenish_count_subs_lov FOR
        SELECT msi.secondary_inventory_name
             , msi.locator_type
             , msi.description
             , msi.asset_inventory
             , msi.quantity_tracked
             , msi.planning_level
             , msi.enable_locator_alias
          FROM mtl_secondary_inventories msi
	      WHERE msi.organization_id = p_organization_id
               AND secondary_inventory_name LIKE p_subinventory
               AND TRUNC(NVL(disable_date, SYSDATE + 1)) > TRUNC(SYSDATE)
               AND NVL(subinventory_type, 1) = 1
               AND(( msi.planning_level = 2
                     AND EXISTS(SELECT 1
                                  FROM mtl_item_sub_inventories mis
                                 WHERE mis.organization_id = msi.organization_id
                                   AND mis.secondary_inventory = msi.secondary_inventory_name
                               )
                   )
                  OR( msi.planning_level = 1
                      AND EXISTS(SELECT 1
                                   FROM mtl_secondary_locators msl
                                  WHERE msl.organization_id = msi.organization_id
                                    AND msl.subinventory_code = msi.secondary_inventory_name
                                 )
                    )
                  )
		         AND EXISTS(SELECT 1
                                      FROM mtl_replenish_headers mrh
		                     WHERE mrh.subinventory_code = msi.secondary_inventory_name
			               AND mrh.organization_id= msi.organization_id
                                       AND mrh.count_mode = 1
                                       AND mrh.process_status = 1
                         )
      ORDER BY secondary_inventory_name;
  END get_replenish_count_subs_lov;

  /**
   *  This procedure returns all the valid locators belonging to the Replenishment Count Header Id passed.
   *  @param  x_replenish_count_locator_kff    Returns LOV rows as a reference cursor
   *  @param  p_locator                        Restricts LOV SQL to this user input Locator
   *  @param  p_replenish_header_id            Replenishment Count Header ID
   *  @param  p_organization_id                Organization ID
   *  @param  p_subinventory                   Subinventory Code
   *  @param  p_qty_tracked                    Quantity Tracked  Subinventory
   **/
  PROCEDURE get_replenish_count_locs_kff(
    x_replenish_count_locator_kff OUT NOCOPY t_genref
  , p_locator                     IN VARCHAR2
  , p_replenish_header_id         IN NUMBER
  , p_organization_id             IN NUMBER
  , p_subinventory                IN VARCHAR2
  , p_qty_tracked                 IN NUMBER
  ) IS
    l_proc CONSTANT VARCHAR2(30) := 'GET_REPLENISH_COUNT_LOCS_KFF';
    l_trace_on NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
  BEGIN
    IF l_trace_on = 1 THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || '   p_locator : '
        || p_locator
        || fnd_global.local_chr(10)
        || ',  p_replenish_header_id : '
        || p_replenish_header_id
        || fnd_global.local_chr(10)
        || ',  p_organization_id : '
        || p_organization_id
        || fnd_global.local_chr(10)
        || ',  p_subinventory : '
        || p_subinventory
      , l_proc
      , 9
      );
    END IF;

    OPEN x_replenish_count_locator_kff FOR
    SELECT milk.inventory_location_id
         , INV_PROJECT.GET_LOCATOR(milk.inventory_location_id, milk.organization_id)			-- Bug 6798138
         , milk.description
     FROM mtl_item_locations_kfv milk
     WHERE milk.organization_id = p_organization_id
       AND milk.subinventory_code = p_subinventory
  --   AND milk.inventory_location_id = NVL(milk.physical_location_id, milk.inventory_location_id)	-- Commented for Bug 6798138
       AND NVL(milk.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
       AND milk.concatenated_segments LIKE(p_locator||'%')
       AND EXISTS( SELECT 1
                    FROM mtl_secondary_locators msl
                       , mtl_replenish_lines mrl
                   WHERE msl.secondary_locator = milk.inventory_location_id
                     AND msl.organization_id = milk.organization_id
                     AND mrl.replenishment_header_id = p_replenish_header_id
                     AND mrl.locator_id = msl.secondary_locator
                     AND mrl.inventory_item_id = msl.inventory_item_id
                     AND mrl.organization_id = msl.organization_id
                     AND mrl.count_quantity IS NULL
                     AND mrl.error_flag IS NULL
                     AND (mrl.count_type_code IS NULL
                          OR mrl.count_type_code = 2
                          OR (mrl.count_type_code = 1 AND p_qty_tracked = 2 AND msl.maximum_quantity IS NOT NULL)
                          )
	              )
    ORDER BY milk.picking_order, milk.concatenated_segments;
  END get_replenish_count_locs_kff;

  PROCEDURE get_replenish_count_locs_kff(
    x_replenish_count_locator_kff OUT NOCOPY t_genref
  , p_locator                     IN VARCHAR2
  , p_replenish_header_id         IN NUMBER
  , p_organization_id             IN NUMBER
  , p_subinventory                IN VARCHAR2
  , p_qty_tracked                 IN NUMBER
  , p_alias                       IN VARCHAR2
  ) IS
    l_proc CONSTANT VARCHAR2(30) := 'GET_REPLENISH_COUNT_LOCS_KFF';
    l_trace_on NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
  BEGIN

    IF  p_alias IS NULL THEN
        get_replenish_count_locs_kff(
          x_replenish_count_locator_kff => x_replenish_count_locator_kff
        , p_locator                     => p_locator
        , p_replenish_header_id         => p_replenish_header_id
        , p_organization_id             => p_organization_id
        , p_subinventory                => p_subinventory
        , p_qty_tracked                 => p_qty_tracked
        );
        RETURN;
    END IF;
    IF l_trace_on = 1 THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || '   p_locator : '
        || p_locator
        || fnd_global.local_chr(10)
        || ',  p_replenish_header_id : '
        || p_replenish_header_id
        || fnd_global.local_chr(10)
        || ',  p_organization_id : '
        || p_organization_id
        || fnd_global.local_chr(10)
        || ',  p_subinventory : '
        || p_subinventory
        || fnd_global.local_chr(10)
        || ',  p_alias : '
        || p_alias
      , l_proc
      , 9
      );
    END IF;

    OPEN x_replenish_count_locator_kff FOR
    SELECT milk.inventory_location_id
         , INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id, milk.organization_id)
         , milk.description
     FROM mtl_item_locations_kfv milk
     WHERE milk.organization_id = p_organization_id
       AND milk.subinventory_code = p_subinventory
       AND milk.inventory_location_id = NVL(milk.physical_location_id, milk.inventory_location_id)
       AND NVL(milk.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
       AND milk.alias = p_alias
       AND EXISTS( SELECT 1
                    FROM mtl_secondary_locators msl
                       , mtl_replenish_lines mrl
                   WHERE msl.secondary_locator = milk.inventory_location_id
                     AND msl.organization_id = milk.organization_id
                     AND mrl.replenishment_header_id = p_replenish_header_id
                     AND mrl.locator_id = msl.secondary_locator
                     AND mrl.inventory_item_id = msl.inventory_item_id
                     AND mrl.organization_id = msl.organization_id
                     AND mrl.count_quantity IS NULL
                     AND mrl.error_flag IS NULL
                     AND (mrl.count_type_code IS NULL
                          OR mrl.count_type_code = 2
                          OR (mrl.count_type_code = 1 AND p_qty_tracked = 2 AND msl.maximum_quantity IS NOT NULL)
                          )
	              )
    ORDER BY milk.picking_order, milk.concatenated_segments;
  END get_replenish_count_locs_kff;

  /**
   *  This procedure returns all the valid items belonging to the Replenishment Count Header Id passed.
    * @param  x_replenish_count_items_lov    Returns LOV rows as a reference cursor
   *  @param  p_item                         Restricts LOV SQL to this user input Item
   *  @param  p_replenish_header_id          Replenishment Count Header ID
   *  @param  p_organization_id              Organization ID
   *  @param  p_subinventory                 Subinventory Code
   *  @param  p_locator_id                   Locator Id
   *  @param  p_qty_tracked                  Quantity Tracked Subinventory
   **/
  PROCEDURE get_replenish_count_items_lov(
    x_replenish_count_items_lov OUT NOCOPY t_genref
  , p_item                      IN VARCHAR2
  , p_replenish_header_id       IN NUMBER
  , p_organization_id           IN NUMBER
  , p_subinventory              IN VARCHAR2
  , p_locator_id                IN NUMBER
  , p_qty_tracked               IN NUMBER
  ) IS
    l_proc CONSTANT VARCHAR2(30) := 'GET_REPLENISH_COUNT_ITEMS_LOV';
    l_trace_on NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
    l_append varchar2(2):='';
  BEGIN
    l_append:=wms_deploy.get_item_suffix_for_lov(p_item);
    IF l_trace_on = 1 THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || '   p_item : '
        || p_item
        || fnd_global.local_chr(10)
        || ',  p_organization_id: '
        || p_organization_id
        || fnd_global.local_chr(10)
        || ',  p_subinventory: '
        || p_subinventory
        || fnd_global.local_chr(10)
        || ',  p_locator_id : '
        || p_locator_id
      , l_proc
      , 9
      );
    END IF;

    OPEN x_replenish_count_items_lov FOR
        SELECT concatenated_segments
             , msik.inventory_item_id
             , msik.description
             , NVL(revision_qty_control_code, 1)
             , NVL(lot_control_code, 1)
             , NVL(serial_number_control_code, 1)
             , NVL(restrict_subinventories_code, 2)
             , NVL(restrict_locators_code, 2)
             , NVL(location_control_code, 1)
             , primary_uom_code
             , NVL(inspection_required_flag, 'N')
             , NVL(shelf_life_code, 1)
             , NVL(shelf_life_days, 0)
             , NVL(allowed_units_lookup_code, 2)
             , NVL(effectivity_control, 1)
             , 0
             , 0
             , NVL(default_serial_status_id, 1)
             , NVL(serial_status_enabled, 'N')
             , NVL(default_lot_status_id, 0)
             , NVL(lot_status_enabled, 'N')
             , ''
             , 'N'
             , inventory_item_flag
             , 0
		 , wms_deploy.get_item_client_name(msik.inventory_item_id),
             --  , inventory_asset_flag, '',
             --Additional Fields for Process Convergence, INVCONV , NSRIVAST
               NVL(GRADE_CONTROL_FLAG,'N'),
               NVL(DEFAULT_GRADE,''),
               NVL(EXPIRATION_ACTION_INTERVAL,0),
               NVL(EXPIRATION_ACTION_CODE,''),
               NVL(HOLD_DAYS,0),
               NVL(MATURITY_DAYS,0),
               NVL(RETEST_INTERVAL,0),
               NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
               NVL(CHILD_LOT_FLAG,'N'),
               NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
               NVL(LOT_DIVISIBLE_FLAG,'Y'),
               NVL(SECONDARY_UOM_CODE,''),
               NVL(SECONDARY_DEFAULT_IND,''),
               NVL(TRACKING_QUANTITY_IND,'P'),
               NVL(DUAL_UOM_DEVIATION_HIGH,0),
               NVL(DUAL_UOM_DEVIATION_LOW,0)
               -- INVCONV , NSRIVAST, END
          FROM mtl_system_items_kfv msik
         WHERE msik.organization_id = p_organization_id
               AND msik.inventory_item_flag = 'Y'
               AND msik.stock_enabled_flag = 'Y'
               AND msik.concatenated_segments LIKE p_item||l_append
               AND ((p_locator_id IS NULL
                     AND EXISTS(SELECT 1
                                  FROM mtl_item_sub_inventories mis
                                     , mtl_replenish_lines mrl
                                 WHERE mis.organization_id = msik.organization_id
                                   AND mis.secondary_inventory = p_subinventory
                                   AND mis.inventory_item_id = msik.inventory_item_id
                                   AND mrl.replenishment_header_id = p_replenish_header_id
                                   AND mrl.inventory_item_id = mis.inventory_item_id
                                   AND mrl.count_quantity IS NULL
                                   AND mrl.error_flag IS NULL
                                   AND (mrl.count_type_code = 2
                                        OR (mrl.count_type_code = 1 AND p_qty_tracked = 2 AND mis.inventory_planning_code = 2)
                                       )
                               )
                    )
                    OR (p_locator_id IS NOT NULL
                        AND EXISTS(SELECT 1
                                     FROM mtl_secondary_locators msl
                                        , mtl_replenish_lines mrl
                                    WHERE msl.secondary_locator = p_locator_id
                                      AND msl.inventory_item_id = msik.inventory_item_id
                                      AND msl.organization_id = msik.organization_id
                                      AND mrl.replenishment_header_id = p_replenish_header_id
                                      AND mrl.locator_id = msl.secondary_locator
                                      AND mrl.inventory_item_id = msl.inventory_item_id
                                      AND mrl.count_quantity IS NULL
                                      AND mrl.error_flag IS NULL
                                      AND (mrl.count_type_code = 2
                                           OR (mrl.count_type_code = 1 AND p_qty_tracked = 2 AND msl.maximum_quantity IS NOT NULL)
                                           )
                                  )
                       )
                   )
      ORDER BY concatenated_segments;
  END get_replenish_count_items_lov;

  /**
   *  This procedure returns the Replenishment Count Types allowed for the passed in
   *  input combination.
   *  @param   x_replenish_count_types_lov  Returns LOV rows as a reference cursor
   *  @param   p_count_type                 Count Type
   *  @param   p_qty_tracked                Quantity Tracked  Subinventory
   *  @param   p_inventory_planning_level   Planning Level of the Subinventory
   *  @param   p_par_level                  PAR level for the Locator Item
   **/
  /**---------------------------------------------------------------------
   *      Parameters                          value passed
   * ---------------------------------------------------------------------
   *     p_quantity_tracked            1(Check) 1        2       2
   *
   *     p_inventory_planning_level    1(PAR)   2(Sub)   1       2
   *
   *     p_par_level                   -       NULL      -       NOT NULL
   * ---------------------------------------------------------------------
   *    Count Types Returned     Order Qty Order Qty Onhand Qty Onhand Qty
   *                                                  Order Qty Order Qty
   *----------------------------------------------------------------------
   **/
  PROCEDURE get_replenish_count_types_lov(
    x_replenish_count_types_lov OUT NOCOPY t_genref
  , p_count_type                IN VARCHAR2
  , p_qty_tracked               IN NUMBER
  , p_inventory_planning_level  IN NUMBER
  , p_par_level                 IN NUMBER
  ) IS
    l_proc CONSTANT VARCHAR2(30) := 'GET_REPLENISH_COUNT_TYPES_LOV';
    l_trace_on NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
  BEGIN
    IF l_trace_on = 1 THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || '   p_count_type : '
        || p_count_type
        || fnd_global.local_chr(10)
        || ',  p_qty_tracked : '
        || p_qty_tracked
        || fnd_global.local_chr(10)
        || ',  p_inventory_planning_level : '
        || p_inventory_planning_level
        || fnd_global.local_chr(10)
        || ',  p_par_level : '
        || p_par_level
      , l_proc
      , 9
      );
    END IF;

    IF (p_qty_tracked = 2 AND p_inventory_planning_level = 2 )
        OR (p_qty_tracked = 2 AND p_inventory_planning_level = 1 AND p_par_level IS NOT NULL)THEN
      OPEN x_replenish_count_types_lov FOR
          SELECT lookup_code
               , meaning
            FROM mfg_lookups
           WHERE lookup_type = 'MTL_COUNT_TYPES'
             AND lookup_code IN (1,2)
             AND enabled_flag = 'Y'
             AND meaning LIKE p_count_type
             AND TRUNC(NVL(end_date_active, SYSDATE + 1)) > TRUNC(SYSDATE)
             AND TRUNC(NVL(start_date_active, SYSDATE - 1)) <= TRUNC(SYSDATE)
        ORDER BY meaning;
    ELSE
      OPEN x_replenish_count_types_lov FOR
          SELECT lookup_code
               , meaning
            FROM mfg_lookups
           WHERE lookup_type = 'MTL_COUNT_TYPES'
             AND lookup_code = 2
             AND enabled_flag = 'Y'
             AND meaning LIKE p_count_type
             AND TRUNC(NVL(end_date_active, SYSDATE + 1)) > TRUNC(SYSDATE)
             AND TRUNC(NVL(start_date_active, SYSDATE - 1)) <= TRUNC(SYSDATE)
        ORDER BY meaning;
    END IF;
  END get_replenish_count_types_lov;
END inv_replenish_count_lovs;

/
