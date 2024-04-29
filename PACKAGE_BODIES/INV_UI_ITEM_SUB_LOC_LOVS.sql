--------------------------------------------------------
--  DDL for Package Body INV_UI_ITEM_SUB_LOC_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_UI_ITEM_SUB_LOC_LOVS" AS
  /* $Header: INVITPSB.pls 120.20.12010000.6 2009/10/27 18:38:59 mchemban ship $ */

  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_UI_ITEM_SUB_LOC_LOVS';

  PROCEDURE debug(p_msg VARCHAR2) IS

  BEGIN

     inv_mobile_helper_functions.tracelog(
                                 p_err_msg => p_msg,
                                 p_module  => g_pkg_name,
                                 p_level   => 4
                                 );

  END debug;

  PROCEDURE update_locator(p_sub_code IN VARCHAR2, p_org_id IN NUMBER, p_locator_id IN NUMBER) IS
    l_return_status  VARCHAR2(10);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(20);
    l_wms_org        BOOLEAN;
    l_sub_type       NUMBER;
    l_locator_status NUMBER;
    l_loc_type       NUMBER;
    l_status_rec     inv_material_status_pub.mtl_status_update_rec_type;
    l_picking_order  NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF (l_debug = 1) THEN
       DEBUG('In the update locator');
    END IF;
    -- Bug 8649041, default status of the locator should be Active.
    l_locator_status := 1;

    --To check if it is wms org
    /*Passing p_organization_id in below call as null as passing p_org_id was checking whether organization is wms
      enabled or not and because of the updation logic was not working properly for non wms enabled organizations.
      Here we need to check whether wms is installed or not.Bug # 6936019 */
    --l_wms_org  := wms_install.check_install(x_return_status => l_return_status, x_msg_count => l_msg_count, x_msg_data => l_msg_data, p_organization_id => p_org_id);

    l_wms_org  := wms_install.check_install(x_return_status => l_return_status, x_msg_count => l_msg_count, x_msg_data => l_msg_data, p_organization_id => NULL);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      IF (l_debug = 1) THEN
         DEBUG('Check if WMS installed');
      END IF;
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    --If it is a WMS org get the default status ,picking order and set the locator type and insert status history
    IF l_wms_org THEN

      -- get the sub type and based on it set the loc_type
      SELECT nvl(subinventory_type,1)
        INTO l_sub_type
      FROM mtl_secondary_inventories
        WHERE organization_id = p_org_id
              AND secondary_inventory_name = p_sub_code;

      IF l_sub_type = 2 THEN
        -- Receiving sub hence set the locator status to receiving
        l_loc_type := 6;
        IF (l_debug = 1) THEN
           DEBUG('Receiving sub hence set the locator status to receiving = ' || l_loc_type);
        END IF;
      ELSE
        -- Storage sub hence set the locator status to storage
        l_loc_type := 3;
        IF (l_debug = 1) THEN
           DEBUG('Storage sub hence set the locator status to storage = ' || l_loc_type);
        END IF;
      END IF; -- sub type check


      l_locator_status                    := inv_material_status_pkg.get_default_locator_status(p_org_id, p_sub_code);
      --l_loc_type                          := 3;
      l_status_rec.organization_id        := p_org_id;
      l_status_rec.inventory_item_id      := NULL;
      l_status_rec.lot_number             := NULL;
      l_status_rec.serial_number          := NULL;
      l_status_rec.update_method          := inv_material_status_pub.g_update_method_manual;
      l_status_rec.status_id              := l_locator_status;
      l_status_rec.zone_code              := p_sub_code;
      l_status_rec.locator_id             := p_locator_id;
      l_status_rec.creation_date          := SYSDATE;
      l_status_rec.created_by             := fnd_global.user_id;
      l_status_rec.last_update_date       := SYSDATE;
      l_status_rec.last_update_login      := fnd_global.user_id;
      l_status_rec.initial_status_flag    := 'Y';
      l_status_rec.from_mobile_apps_flag  := 'Y';
      IF (l_debug = 1) THEN
         DEBUG('before inserting status history');
      END IF;
      inv_material_status_pkg.insert_status_history(l_status_rec);
      IF (l_debug = 1) THEN
         DEBUG('Status history inserted');
      END IF;
    END IF;

    --Default the picking order from the org parameters
    SELECT default_locator_order_value
      INTO l_picking_order
      FROM mtl_parameters
     WHERE organization_id = p_org_id;

    --Bug 8649041, stamping the WHO columns correctly.
    --Bug 7143077 The creation date and created by should not be null for dynamic locators

    UPDATE mtl_item_locations
       SET created_by = NVL(created_by, fnd_global.user_id)
         , creation_date = NVL(creation_date, SYSDATE)
         , last_updated_by = fnd_global.user_id
         , last_update_login = fnd_global.login_id
         , last_update_date = SYSDATE
         , subinventory_code = p_sub_code
         , status_id = l_locator_status
         , inventory_location_type = l_loc_type
         , picking_order = l_picking_order
     WHERE organization_id = p_org_id
       AND inventory_location_id = p_locator_id;
  END update_locator;


  /** Changes done for Patchset J project -Receiving Locator Support and Item Based Putaway
   *  Added two new parameters - p_location_id and p_lpn_context
   *  p_location_id will be passed from Receiving Pages in which case we will show only
   *  Receiving Type subinventories.
   *  lpn context will be passed from Putaway page where there are two requirements -
   *  i. if lpn context = 3 then show all storage as well as receiving type subs
   * ii. if lpn context = 1 then show only inventory type subinventories
   *  Added one more new parameter - p_putaway_code
   *  PutawayDropPage will use this parameter to indicate what type of
   *  subinventory should be shown:
   *  1 - show only storage sub (with no restrictions)
   *  2 - show only receiving sub
   *  3 - show only lpn-controlled and reservable storage sub (for SO xdock)
   *  4 - show only non-lpn-controlled and non-reservable storage sub (for
   *      wip xdock)
   *  NULL - show both storage sub and rcv sub, just like how it works before
   */
   --- Obsoleted
    PROCEDURE get_sub_lov_rcv(
            x_sub                          OUT NOCOPY t_genref
          , p_organization_id              IN NUMBER
          , p_item_id                      IN NUMBER
          , p_sub                          IN VARCHAR2
          , p_restrict_subinventories_code IN NUMBER
          , p_transaction_type_id          IN NUMBER
          , p_wms_installed                IN VARCHAR2
          , p_location_id                  IN NUMBER --RCVLOCATORSSUPPORT
          , p_lpn_context                  IN NUMBER
          , p_putaway_code                 IN NUMBER
          ) IS --RCVLOCATORSSUPPORT
     l_debug          NUMBER;
     l_procedure_name VARCHAR2(30);
  BEGIN

     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_procedure_name := 'GET_SUB_LOV_RCV';

     IF l_debug > 0 THEN
        debug(l_procedure_name);
        debug('p_lpn_context => ' || p_lpn_context);
        debug('p_location_id => ' || p_location_id);
        debug('p_putaway_code =>  ' || p_putaway_code);
     END IF;
     IF p_lpn_context = 3 THEN

       IF (p_item_id IS NULL OR p_restrict_subinventories_code <> 1 ) THEN
          OPEN   x_sub FOR
          SELECT msub.secondary_inventory_name
               , NVL(msub.locator_type, 1)
               , msub.description
               , msub.asset_inventory
               , msub.lpn_controlled_flag
               , nvl(msub.subinventory_type, 1)
               , msub.reservable_type
               , msub.enable_locator_alias
          FROM mtl_secondary_inventories msub
          WHERE msub.organization_id = p_organization_id
          AND Nvl(subinventory_type,1) = Decode(p_putaway_code,
                2, --Don't show any storage sub
                -1,--if system suggested a RCV sub
                1)
          AND Nvl(lpn_controlled_flag,-1) = Decode(p_putaway_code,
                  3,--For SO xdock, sub must be
                  1,--LPN controlled
                  Decode(p_putaway_code,
                    4,--For WIP xdock, sub must
                    2,--NOT be LPN controlled
                    Nvl(lpn_controlled_flag,-1)))
          AND reservable_type = Decode(p_putaway_code,
                   3,--For SO xdock, sub must be
                   1,--reservable
                   Decode(p_putaway_code,
                     4,--For WIP xdock, sub must
                     2,--not be reservable
                     reservable_type))
         AND NVL(msub.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
         AND msub.secondary_inventory_name LIKE (p_sub)
         AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, msub.secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y'
        UNION ALL
           SELECT msub.secondary_inventory_name
               , NVL(msub.locator_type, 1)
               , msub.description
               , msub.asset_inventory
               , lpn_controlled_flag
          , Nvl(subinventory_type, 1)
          , reservable_type
          , enable_locator_alias
            FROM mtl_secondary_inventories msub
           WHERE organization_id = p_organization_id
     AND Nvl(subinventory_type,1) = Decode(p_putaway_code,
                  2,--Only show rcv sub if the
                  2,--system has suggested a rcv sub
                  Decode(p_putaway_code,
                         NULL,
                         2,
                         -1))
             AND msub.secondary_inventory_name LIKE (p_sub)
             AND (trunc(disable_date + (300*365)) >= trunc(SYSDATE) OR
                  disable_date = TO_DATE('01/01/1700','DD/MM/RRRR'))
        ORDER BY 1;

       ELSE -- It is a restricted item,
         OPEN x_sub FOR
         SELECT  msub.secondary_inventory_name
               , NVL(msub.locator_type, 1)
               , msub.description
               , msub.asset_inventory
               , lpn_controlled_flag
          , Nvl(subinventory_type, 1)
          , reservable_type
          , enable_locator_alias
            FROM mtl_secondary_inventories msub
           WHERE msub.organization_id = p_organization_id
             AND NVL(msub.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND msub.secondary_inventory_name LIKE (p_sub)
        AND Nvl(msub.subinventory_type,1) = Decode(p_putaway_code,
                     2, --Don't show any storage sub
                     -1,--if system suggested a RCV sub
                     1)
        AND Nvl(msub.lpn_controlled_flag,-1) = Decode(p_putaway_code,
                     3,--For SO xdock, sub must be
                     1,--LPN controlled
                     Decode(p_putaway_code,
                       4,--For WIP xdock, sub must
                       2,--NOT be LPN controlled
                       Nvl(msub.lpn_controlled_flag,-1)))
        AND msub.reservable_type = Decode(p_putaway_code,
                      3,--For SO xdock, sub must be
                      1,--reservable
                      Decode(p_putaway_code,
                        4,--For WIP xdock, sub must
                        2,--not be reservable
                        msub.reservable_type))

      AND EXISTS( SELECT NULL
                           FROM mtl_item_sub_inventories mis
                          WHERE mis.organization_id = NVL(p_organization_id, mis.organization_id)
                            AND mis.inventory_item_id = p_item_id
                            AND mis.secondary_inventory = msub.secondary_inventory_name)
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, msub.secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y'
        UNION ALL
         SELECT msub.secondary_inventory_name
               , NVL(msub.locator_type, 1)
               , msub.description
               , msub.asset_inventory
               , lpn_controlled_flag
          , Nvl(subinventory_type, 1)
          , reservable_type
          , enable_locator_alias
            FROM mtl_secondary_inventories msub
           WHERE msub.organization_id = p_organization_id
      AND Nvl(msub.subinventory_type,1) = Decode(p_putaway_code,
                        2,--Only show rcv sub if the
                        2,--system has suggested a rcv sub
                        Decode(p_putaway_code,
                          NULL,
                          2,
                          -1))
             AND msub.secondary_inventory_name LIKE (p_sub)
             AND (trunc(disable_date + (300*365)) >= trunc(SYSDATE) OR
                  disable_date = TO_DATE('01/01/1700','DD/MM/RRRR'))
        ORDER BY 1;

      END IF;
     ELSIF (p_lpn_context IN (1,2) OR p_lpn_context IS NULL) AND p_location_id IS NULL THEN
      IF (p_item_id IS NULL
        OR p_restrict_subinventories_code <> 1
       ) THEN
      OPEN x_sub FOR
        SELECT   msub.secondary_inventory_name
               , NVL(msub.locator_type, 1)
               , msub.description
               , msub.asset_inventory
               , lpn_controlled_flag
          , Nvl(subinventory_type, 1)
          , reservable_type
          , enable_locator_alias
            FROM mtl_secondary_inventories msub
           WHERE msub.organization_id = p_organization_id
             AND NVL(msub.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
        AND msub.secondary_inventory_name LIKE (p_sub)
        AND Nvl(msub.lpn_controlled_flag,-1) = Decode(p_lpn_context,
                     2,
                     Decode(p_putaway_code,
                       3,
                       1,
                       Decode(p_putaway_code,
                         4,
                         2,
                         Nvl(msub.lpn_controlled_flag,-1))
                       ),
                     Nvl(msub.lpn_controlled_flag,-1)
                     )
        AND msub.reservable_type = Decode(p_lpn_context,
                      2,
                      Decode(p_putaway_code,
                        3,
                        1,
                        Decode(p_putaway_code,
                          4,
                          2,
                          msub.reservable_type)
                        ),
                      msub.reservable_type
                      )
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, msub.secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y'
        ORDER BY UPPER(msub.secondary_inventory_name);
    ELSE
      -- It is a restricted item,
      OPEN x_sub FOR
        SELECT   msub.secondary_inventory_name
               , NVL(msub.locator_type, 1)
               , msub.description
               , msub.asset_inventory
               , lpn_controlled_flag
          , Nvl(subinventory_type, 1)
          , reservable_type
          , enable_locator_alias
            FROM mtl_secondary_inventories msub
           WHERE msub.organization_id = p_organization_id
             AND NVL(msub.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
        AND msub.secondary_inventory_name LIKE (p_sub)
        AND Nvl(msub.lpn_controlled_flag,-1) = Decode(p_lpn_context,
                     2,
                     Decode(p_putaway_code,
                       3,-- SO XDOCK
                       1,--Must be LPN controlled
                       Decode(p_putaway_code,
                         4,--WIP XDOCK
                         2,--Must be non LPN controlled
                         Nvl(msub.lpn_controlled_flag,-1))
                       ),
                     Nvl(msub.lpn_controlled_flag,-1)
                     )
        AND msub.reservable_type = Decode(p_lpn_context,
                     2,
                     Decode(p_putaway_code,
                       3,--SO XDOCK
                       1,--Must be reservable
                       Decode(p_putaway_code,
                         4,--WIP XDOCK
                         2,--Must be non reservable
                         msub.reservable_type)
                       ),
                      msub.reservable_type
                      )
             AND EXISTS( SELECT NULL
                           FROM mtl_item_sub_inventories mis
                          WHERE mis.organization_id = NVL(p_organization_id, mis.organization_id)
                            AND mis.inventory_item_id = p_item_id
                            AND mis.secondary_inventory = msub.secondary_inventory_name)
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, msub.secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y'
        ORDER BY UPPER(msub.secondary_inventory_name);
    END IF;
  ELSIF p_location_id IS NOT NULL THEN
   -- For Putaway, p_location_id will always be null, so no change
   -- is needed below
      OPEN x_sub FOR
           SELECT msub.secondary_inventory_name
               , NVL(msub.locator_type, 1)
               , msub.description
               , msub.asset_inventory
               , lpn_controlled_flag
          , Nvl(subinventory_type, 1)
          , reservable_type
          , enable_locator_alias
        FROM mtl_secondary_inventories msub
           WHERE organization_id = p_organization_id
             AND subinventory_type = 2
             AND msub.secondary_inventory_name LIKE (p_sub)
             AND location_id = p_location_id
             AND (trunc(disable_date + (300*365)) >= trunc(SYSDATE) OR
                  disable_date = TO_DATE('01/01/1700','DD/MM/RRRR'))
        ORDER BY UPPER(msub.secondary_inventory_name);
     END IF;
  END get_sub_lov_rcv;

  --      Name: GET_MO_FROMSUB_LOV
  --
  --      Input parameters:
  --       p_organization_id   OrgId
  --       p_MOheader_id       MoveOrder Header Id
  --       p_subinv_code       SubInventory Code
  --
  --      Output parameters:
  --       x_fromsub_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Transaction Reasons
  --
  ---- Obsolete
  PROCEDURE get_mo_fromsub_lov(x_fromsub_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_moheader_id IN NUMBER, p_subinv_code IN VARCHAR) IS

  BEGIN

     OPEN x_fromsub_lov FOR
     SELECT secondary_inventory_name
          , NVL(locator_type, 1)
          , description
          , asset_inventory
          , lpn_controlled_flag
          , enable_locator_alias
     FROM   mtl_secondary_inventories
     WHERE  organization_id = p_organization_id
     AND    secondary_inventory_name IN (
            SELECT from_subinventory_code
            FROM   mtl_txn_request_lines
            WHERE  header_id = p_moheader_id
            )
     AND    NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
     AND    secondary_inventory_name LIKE (p_subinv_code);

  END get_mo_fromsub_lov;

  --      Name: GET_MO_TOSUB_LOV
  --
  --      Input parameters:
  --       p_organization_id   OrgId
  --       p_MOheader_id       MoveOrder Header Id
  --       p_subinv_code       SubInventory Code
  --
  --      Output parameters:
  --       x_tosub_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Transaction Reasons
  --
  --- Obsolete
  PROCEDURE get_mo_tosub_lov(x_tosub_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_moheader_id IN NUMBER, p_subinv_code IN VARCHAR) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    OPEN x_tosub_lov FOR
      SELECT secondary_inventory_name
           , NVL(locator_type, 1)
           , description
           , asset_inventory
           , lpn_controlled_flag
           , enable_locator_alias
        FROM mtl_secondary_inventories
       WHERE organization_id = p_organization_id
         AND secondary_inventory_name IN (SELECT to_subinventory_code
                                            FROM mtl_txn_request_lines
                                           WHERE header_id = p_moheader_id)
         AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
         AND secondary_inventory_name LIKE (p_subinv_code);
  END;

  --      Name: GET_LOC_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Concatenated_Segments   which restricts LOV SQL to the user input text
  --                                e.g.  1-1%
  --       p_Inventory_item_id      restrict to those item restricted locators
  --       p_Subinventory_Code      restrict to this sub
  --       p_restrict_Locators_code  item restricted locator flag
  --
  --      Output parameters:
  --       x_sub      returns LOV rows as reference cursor
  --
  --      Functions: This API is to returns locator for given org and sub
  --                 It returns different LOVs for item-restricted locator
  --
  PROCEDURE get_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF (l_debug = 1) THEN
       inv_log_util.TRACE('Im in GET_pick_LOV', 'WMS_LPN_LOVs', 9);
    END IF;

    IF p_restrict_locators_code = 1 THEN --Locators restricted to predefined list
      OPEN x_locators FOR
        SELECT   a.inventory_location_id
               --, a.concatenated_segments----Bug4398337:Commented this line and added below line
               , a.locator_segments concatenated_segments
               , a.description
            FROM wms_item_locations_kfv a, mtl_secondary_locators b
           WHERE b.organization_id = p_organization_id
             AND b.inventory_item_id = p_inventory_item_id
             AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND b.subinventory_code = p_subinventory_code
             AND a.inventory_location_id = b.secondary_locator
             AND a.concatenated_segments LIKE (p_concatenated_segments)
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
        ORDER BY a.concatenated_segments;
    ELSE --Locators not restricted
      OPEN x_locators FOR
        SELECT   inventory_location_id
              -- , concatenated_segments--Bug4398337:Commented this line and added below line
               , locator_segments concatenated_segments
               , description
            FROM wms_item_locations_kfv
           WHERE organization_id = p_organization_id
             AND subinventory_code = p_subinventory_code
             AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND concatenated_segments LIKE (p_concatenated_segments)
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
        ORDER BY concatenated_segments;
    END IF;
  END get_loc_lov;

  --      Name: GET_LOC_LOV_PJM
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Concatenated_Segments   which restricts LOV SQL to the user input text
  --                                e.g.  1-1%
  --       p_Inventory_item_id      restrict to those item restricted locators
  --       p_Subinventory_Code      restrict to this sub
  --       p_restrict_Locators_code  item restricted locator flag
  --
  --      Output parameters:
  --       x_sub      returns LOV rows as reference cursor and the concatenated segments
  --                  returned doesnt contain SEGMENT 19 and 20.
  --
  --      Functions: This API is to returns locator for given org and sub.
  --                 The concatenated segments returned doesnt contain SEGMENT 19 and 20.
  --                 It returns different LOVs for item-restricted locator
  --

  PROCEDURE get_loc_lov_pjm(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF (l_debug = 1) THEN
       inv_trx_util_pub.TRACE('Im in GET_LOC_LOV_PJM', 'WMS_LPN_LOVs', 9);
    END IF;

    IF p_restrict_locators_code = 1 THEN --Locators restricted to predefined list
      OPEN x_locators FOR
        SELECT   a.inventory_location_id
               --, a.concatenated_segments concatenated_segments--Bug4398337:Commented this line and added below line
               , a.locator_segments  concatenated_segments
               , a.description
            FROM wms_item_locations_kfv a, mtl_secondary_locators b
           WHERE b.organization_id = p_organization_id
             AND b.inventory_item_id = p_inventory_item_id
             AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND b.subinventory_code = p_subinventory_code
             AND a.inventory_location_id = b.secondary_locator
             AND a.project_id IS NULL
             AND a.task_id IS NULL
             AND a.concatenated_segments LIKE (p_concatenated_segments)
             AND NVL(a.physical_location_id, a.inventory_location_id) = a.inventory_location_id
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
        ORDER BY 2;
    ELSE --Locators not restricted
      OPEN x_locators FOR
        SELECT   inventory_location_id
               --, concatenated_segments concatenated_segments--Bug4398337:Commented this line and added below line
               , locator_segments concatenated_segments
               , description
            FROM wms_item_locations_kfv
           WHERE organization_id = p_organization_id
             AND subinventory_code = p_subinventory_code
             AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND concatenated_segments LIKE (p_concatenated_segments)
             AND project_id IS NULL
             AND task_id IS NULL
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
        ORDER BY 2;
    END IF;
  END get_loc_lov_pjm;

  ------------------------------------------------
  --  GET_INQ_LOC_LOV for inquiry form.
  -------------------------------------------------
  PROCEDURE get_inq_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_project_id             IN     NUMBER := NULL
  , p_task_id                IN     NUMBER := NULL
  ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_ispjm_org VARCHAR2(1);
BEGIN
   BEGIN
    SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
    INTO l_ispjm_org
    FROM pjm_org_parameters
       WHERE organization_id=p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
END;
  IF l_ispjm_org='N'THEN
     IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
          OPEN x_Locators FOR
           SELECT a.inventory_location_id,
                  --a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                  a.locator_segments locsegs,
                  a.description
            FROM  wms_item_locations_kfv a,
                  mtl_secondary_locators b
           WHERE b.organization_id = p_Organization_Id
            AND   b.inventory_item_id = p_Inventory_Item_Id
            AND   b.subinventory_code = p_Subinventory_Code
            AND   a.inventory_location_id = b.secondary_locator
            and nvl(a.disable_date, trunc(sysdate+1)) > trunc(sysdate) /* 2915024 */
            AND   a.concatenated_segments LIKE (p_concatenated_segments )
          /* BUG#28101405: To show only common locators in the LOV */
         ORDER BY 2;

        ELSE --Locators not restricted
           --bug#3440453 Remove the NVL on organization_id if user passes it.
           IF p_organization_id IS NULL THEN
             OPEN x_Locators FOR
               SELECT inventory_location_id,
                     -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                      locator_segments locsegs,
                      description
               FROM   wms_item_locations_kfv
               WHERE  organization_id = Nvl(p_organization_id, organization_id)
               AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
               and nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate) /* 2915024 */
                    AND    concatenated_segments LIKE (p_concatenated_segments)
              ORDER BY 2;
           ELSE  -- Organization_id is not null
              OPEN x_Locators FOR
                SELECT inventory_location_id,
                      -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                       locator_segments locsegs,
                       description
                FROM   wms_item_locations_kfv
                WHERE  organization_id = p_organization_id
                AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                and nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate) /* 2915024 */
                     AND    concatenated_segments LIKE (p_concatenated_segments)
               ORDER BY 2;
           END IF;
        END IF;
     ELSE /*PJM Org*/
      IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
          OPEN x_Locators FOR
           SELECT a.inventory_location_id,
                  --a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                  a.locator_segments locsegs,
                  a.description
            FROM  wms_item_locations_kfv a,
                  mtl_secondary_locators b
           WHERE b.organization_id = p_Organization_Id
      AND   b.inventory_item_id = p_Inventory_Item_Id
      AND   b.subinventory_code = p_Subinventory_Code
      AND   a.inventory_location_id = b.secondary_locator
      and nvl(a.disable_date, trunc(sysdate+1)) > trunc(sysdate) /* 2915024 */
           AND   a.inventory_location_id=NVL(a.physical_location_id,a.inventory_location_id)
      AND   a.concatenated_segments LIKE (p_concatenated_segments )
            ORDER BY 2;
        ELSE --Locators not restricted
           --bug#3440453 Remove the NVL on organization_id if user passes it.
           IF p_organization_id IS NULL THEN
             OPEN x_Locators FOR
               SELECT inventory_location_id,
                     -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                      locator_segments locsegs,
                      description
               FROM   wms_item_locations_kfv
               WHERE  organization_id = Nvl(p_organization_id, organization_id)
               AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
               and nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate) /* 2915024 */
                  AND    concatenated_segments LIKE (p_concatenated_segments )
                    AND   inventory_location_id=NVL(physical_location_id,inventory_location_id)
               ORDER BY 2;
           ELSE  -- Organization_id is not null
              OPEN x_Locators FOR
                SELECT inventory_location_id,
                      -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                       locator_segments locsegs,
                       description
                FROM   wms_item_locations_kfv
                WHERE  organization_id = p_organization_id
                AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                and nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate) /* 2915024 */
                   AND    concatenated_segments LIKE (p_concatenated_segments )
                     AND   inventory_location_id=NVL(physical_location_id,inventory_location_id)
                ORDER BY 2;
           END IF;
        END IF;
     END IF;
  END get_inq_loc_lov;
  PROCEDURE get_inq_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_project_id             IN     NUMBER := NULL
  , p_task_id                IN     NUMBER := NULL
  , p_alias                  IN     VARCHAR2
  ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_ispjm_org VARCHAR2(1);
BEGIN
    IF p_alias IS NULL THEN
       get_inq_loc_lov(
        x_locators               => x_locators
      , p_organization_id        => p_organization_id
      , p_subinventory_code      => p_subinventory_code
      , p_restrict_locators_code => p_restrict_locators_code
      , p_inventory_item_id      => p_inventory_item_id
      , p_concatenated_segments  => p_concatenated_segments
      , p_project_id             => p_project_id
      , p_task_id                => p_task_id
      );
       RETURN;
    END IF;

   BEGIN
    SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
    INTO l_ispjm_org
    FROM pjm_org_parameters
       WHERE organization_id=p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
END;
  IF l_ispjm_org='N'THEN
     IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
          OPEN x_Locators FOR
           SELECT a.inventory_location_id,
                  --a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                  a.locator_segments locsegs,
                  a.description
            FROM  wms_item_locations_kfv a,
                  mtl_secondary_locators b
           WHERE b.organization_id = p_Organization_Id
            AND   b.inventory_item_id = p_Inventory_Item_Id
            AND   b.subinventory_code = p_Subinventory_Code
            AND   a.inventory_location_id = b.secondary_locator
            and nvl(a.disable_date, trunc(sysdate+1)) > trunc(sysdate) /* 2915024 */
            AND   a.alias = p_alias
          /* BUG#28101405: To show only common locators in the LOV */
         ORDER BY 2;

        ELSE --Locators not restricted
           --bug#3440453 Remove the NVL on organization_id if user passes it.
           IF p_organization_id IS NULL THEN
             OPEN x_Locators FOR
               SELECT inventory_location_id,
                     -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                      locator_segments locsegs,
                      description
               FROM   wms_item_locations_kfv
               WHERE  organization_id = Nvl(p_organization_id, organization_id)
               AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
               and nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate) /* 2915024 */
                    AND    alias = p_alias
              ORDER BY 2;
           ELSE  -- Organization_id is not null
              OPEN x_Locators FOR
                SELECT inventory_location_id,
                      -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                       locator_segments locsegs,
                       description
                FROM   wms_item_locations_kfv
                WHERE  organization_id = p_organization_id
                AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                and nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate) /* 2915024 */
                     AND    alias = p_alias
               ORDER BY 2;
           END IF;
        END IF;
     ELSE /*PJM Org*/
      IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
          OPEN x_Locators FOR
           SELECT a.inventory_location_id,
                  --a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                  a.locator_segments locsegs,
                  a.description
            FROM  wms_item_locations_kfv a,
                  mtl_secondary_locators b
           WHERE b.organization_id = p_Organization_Id
      AND   b.inventory_item_id = p_Inventory_Item_Id
      AND   b.subinventory_code = p_Subinventory_Code
      AND   a.inventory_location_id = b.secondary_locator
      and nvl(a.disable_date, trunc(sysdate+1)) > trunc(sysdate) /* 2915024 */
           AND   a.inventory_location_id=NVL(a.physical_location_id,a.inventory_location_id)
      AND   a.alias = p_alias
            ORDER BY 2;
        ELSE --Locators not restricted
           --bug#3440453 Remove the NVL on organization_id if user passes it.
           IF p_organization_id IS NULL THEN
             OPEN x_Locators FOR
               SELECT inventory_location_id,
                     -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                      locator_segments locsegs,
                      description
               FROM   wms_item_locations_kfv
               WHERE  organization_id = Nvl(p_organization_id, organization_id)
               AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
               and nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate) /* 2915024 */
                  AND    alias = p_alias
                    AND   inventory_location_id=NVL(physical_location_id,inventory_location_id)
               ORDER BY 2;
           ELSE  -- Organization_id is not null
              OPEN x_Locators FOR
                SELECT inventory_location_id,
                      -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                       locator_segments locsegs,
                       description
                FROM   wms_item_locations_kfv
                WHERE  organization_id = p_organization_id
                AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                and nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate) /* 2915024 */
                   AND    alias = p_alias
                     AND   inventory_location_id=NVL(physical_location_id,inventory_location_id)
                ORDER BY 2;
           END IF;
        END IF;
     END IF;
  END get_inq_loc_lov;

  -- This returns the locator id for an existing locator and if
  -- it does not exist then it creates a new one.
  PROCEDURE get_dynamic_locator(x_location_id OUT NOCOPY NUMBER, x_description OUT NOCOPY VARCHAR2, x_result OUT NOCOPY VARCHAR2, x_exist_or_create OUT NOCOPY VARCHAR2, p_org_id IN NUMBER, p_sub_code IN VARCHAR2, p_concat_segs IN VARCHAR2) IS
    l_keystat_val        BOOLEAN;
    l_sub_default_status NUMBER;
    l_validity_check     VARCHAR2(10);
    l_wms_org            BOOLEAN;
    l_loc_type           NUMBER;
    l_return_status      VARCHAR2(10);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(20);
    l_label_status       VARCHAR2(20);
    l_status_rec         inv_material_status_pub.mtl_status_update_rec_type; -- bug# 1695432
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    x_result          := 'S';
    l_validity_check  := 'passed';

    BEGIN
      SELECT inventory_location_id
           , description
        INTO x_location_id
           , x_description
        FROM wms_item_locations_kfv
       WHERE organization_id = p_org_id
         AND subinventory_code = p_sub_code
         AND concatenated_segments = p_concat_segs
         AND ROWNUM < 2;

      x_exist_or_create  := 'EXISTS';
      RETURN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_keystat_val  :=
            fnd_flex_keyval.validate_segs(operation => 'CREATE_COMB_NO_AT', --changed for bug1881366
                                                                           appl_short_name => 'INV', key_flex_code => 'MTLL', structure_number => 101, concat_segments => p_concat_segs, values_or_ids => 'V', data_set => p_org_id);

        IF (l_keystat_val = FALSE) THEN
          x_result           := 'E';
          x_exist_or_create  := '';
          RETURN;
        ELSE
          x_location_id      := fnd_flex_keyval.combination_id;
          x_exist_or_create  := 'EXISTS';

          IF fnd_flex_keyval.new_combination THEN
            x_exist_or_create  := 'CREATE';

            IF p_sub_code IS NOT NULL THEN
              BEGIN
                ---  check validity
                SELECT 'failed'
                  INTO l_validity_check
                  FROM DUAL
                 WHERE EXISTS( SELECT subinventory_code
                                 FROM wms_item_locations_kfv
                                WHERE concatenated_segments = p_concat_segs
                                  AND p_sub_code <> subinventory_code
                                  AND organization_id = p_org_id);
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  NULL;
              END;

              IF l_validity_check = 'failed' THEN
                x_result           := 'E';
                x_exist_or_create  := '';
                RETURN;
              END IF;

              SELECT NVL(default_loc_status_id, 1)
                INTO l_sub_default_status
                FROM mtl_secondary_inventories
               WHERE organization_id = p_org_id
                 AND secondary_inventory_name = p_sub_code;

              l_wms_org  := wms_install.check_install(x_return_status => l_return_status, x_msg_count => l_msg_count, x_msg_data => l_msg_data, p_organization_id => p_org_id);

              IF l_return_status = 'S' THEN
                IF l_wms_org THEN
                  l_loc_type  := 3;
                ELSE
                  l_loc_type  := NULL;
                END IF;
              ELSE
                x_result           := 'E';
                x_exist_or_create  := '';
                RETURN;
              END IF;

              UPDATE mtl_item_locations
                 SET subinventory_code = p_sub_code
                   , status_id = l_sub_default_status
                   , inventory_location_type = l_loc_type
               WHERE organization_id = p_org_id
                 AND inventory_location_id = x_location_id;
            END IF;
          ELSE
            BEGIN
              ---  check validity
              SELECT 'failed'
                INTO l_validity_check
                FROM DUAL
               WHERE EXISTS( SELECT subinventory_code
                               FROM mtl_item_locations_kfv
                              WHERE concatenated_segments = p_concat_segs
                                AND p_sub_code <> subinventory_code
                                AND organization_id = p_org_id);
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                NULL;
            END;

            IF l_validity_check = 'failed' THEN
              x_result           := 'E';
              x_exist_or_create  := '';
              RETURN;
            END IF;
          END IF;

          IF x_exist_or_create = 'CREATE' THEN
            -- If a new locator is created then create a status history for it, bug# 1695432
            l_status_rec.organization_id        := p_org_id;
            l_status_rec.inventory_item_id      := NULL;
            l_status_rec.lot_number             := NULL;
            l_status_rec.serial_number          := NULL;
            l_status_rec.update_method          := inv_material_status_pub.g_update_method_manual;
            l_status_rec.status_id              := l_sub_default_status;
            l_status_rec.zone_code              := p_sub_code;
            l_status_rec.locator_id             := x_location_id;
            l_status_rec.creation_date          := SYSDATE;
            l_status_rec.created_by             := fnd_global.user_id;
            l_status_rec.last_update_date       := SYSDATE;
            l_status_rec.last_update_login      := fnd_global.user_id;
            l_status_rec.initial_status_flag    := 'Y';
            l_status_rec.from_mobile_apps_flag  := 'Y';
            inv_material_status_pkg.insert_status_history(l_status_rec);
            -- If a new locator is created, call label printing API

            IF (l_debug = 1) THEN
               inv_mobile_helper_functions.tracelog(p_err_msg => 'Before calling label printing in dynamic locator generation', p_module => 'Dynamic Locator', p_level => 3);
            END IF;
            inv_label.print_label_manual_wrap(
              x_return_status              => l_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            , x_label_status               => l_label_status
            , p_business_flow_code         => 24
            , p_organization_id            => p_org_id
            , p_subinventory_code          => p_sub_code
            , p_locator_id                 => x_location_id
            );
            IF (l_debug = 1) THEN
               inv_mobile_helper_functions.tracelog(p_err_msg => 'After calling label printing in dynamic locator generation, status=' || l_return_status, p_module => 'Dynamic Locator', p_level => 3);
            END IF;
          END IF;
        END IF;
    END;
  END;

  -- This procedure validates a locator
  PROCEDURE check_dynamic_locator(x_result OUT NOCOPY VARCHAR2, p_org_id IN NUMBER, p_sub_code IN VARCHAR2, p_inventory_location_id IN VARCHAR2) IS
    l_temp NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    x_result  := 'S';

    BEGIN
      SELECT 1
        INTO l_temp
        FROM mtl_item_locations
       WHERE organization_id = p_org_id
         AND inventory_location_id = p_inventory_location_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_result  := 'U';
    END;
  END;

  --
  --
  PROCEDURE get_valid_to_locs(
    x_locators               OUT    NOCOPY t_genref
  , p_transaction_action_id  IN     NUMBER
  , p_to_organization_id     IN     NUMBER
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  ) IS
    l_org                    NUMBER;
    l_restrict_locators_code NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF p_transaction_action_id IN (3, 21) THEN
      l_org  := p_to_organization_id;

      SELECT restrict_locators_code
        INTO l_restrict_locators_code
        FROM mtl_system_items
       WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = l_org;
    ELSE
      l_org                     := p_organization_id;
      l_restrict_locators_code  := p_restrict_locators_code;
    END IF;

    get_loc_lov(x_locators, l_org, p_subinventory_code, l_restrict_locators_code, p_inventory_item_id, p_concatenated_segments, p_transaction_type_id, p_wms_installed);
  END;

  --      Name: GET_MO_FROMLOC_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Concatenated_Segments   which restricts LOV SQL to user input text
  --                                e.g.  1-1%
  --
  --      Output parameters:
  --       x_Locators      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return "src" locator for a given MO
  --
  PROCEDURE get_mo_fromloc_lov(x_locators OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_moheader_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_project_id IN NUMBER := NULL, p_task_id IN NUMBER := NULL) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    OPEN x_locators FOR
      SELECT mil.inventory_location_id
           --, mil.concatenated_segments conseg--Bug4398337:Commented this line and added below line
           , mil.locator_segments conseg
           , mil.description
        FROM wms_item_locations_kfv mil
       WHERE mil.organization_id = p_organization_id
         AND mil.inventory_location_id IN (SELECT from_locator_id
                                             FROM mtl_txn_request_lines
                                            WHERE header_id = p_moheader_id)
         AND mil.concatenated_segments LIKE (p_concatenated_segments)
         AND NVL(mil.project_id, -9999) = NVL(p_project_id, -9999)
         AND NVL(mil.task_id, -9999) = NVL(p_task_id, -9999);
  END;
  PROCEDURE get_mo_fromloc_lov(
            x_locators OUT NOCOPY t_genref,
            p_organization_id IN NUMBER,
            p_moheader_id IN NUMBER,
            p_concatenated_segments IN VARCHAR2,
            p_project_id IN NUMBER := NULL,
            p_task_id IN NUMBER := NULL,
            p_alias                 IN VARCHAR2
            ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     IF p_alias IS NULL THEN
        get_mo_fromloc_lov(
             x_locators              => x_locators
            ,p_organization_id       => p_organization_id
            ,p_moheader_id           => p_moheader_id
            ,p_concatenated_segments => p_concatenated_segments
            ,p_project_id            => p_project_id
            ,p_task_id               => p_task_id
            );
        RETURN;
     END IF;
    OPEN x_locators FOR
      SELECT mil.inventory_location_id
           --, mil.concatenated_segments conseg--Bug4398337:Commented this line and added below line
           , mil.locator_segments conseg
           , mil.description
        FROM wms_item_locations_kfv mil
       WHERE mil.organization_id = p_organization_id
         AND mil.inventory_location_id IN (SELECT from_locator_id
                                             FROM mtl_txn_request_lines
                                            WHERE header_id = p_moheader_id)
         AND mil.alias = p_alias
         AND NVL(mil.project_id, -9999) = NVL(p_project_id, -9999)
         AND NVL(mil.task_id, -9999) = NVL(p_task_id, -9999);
  END GET_MO_FROMLOC_LOV;

  --      Name: GET_MO_TOLOC_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Concatenated_Segments   which restricts LOV SQL to user input text
  --                                e.g.  1-1%
  --
  --      Output parameters:
  --       x_Locators      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return "destination" locator for a given MO
  --
  PROCEDURE get_mo_toloc_lov(x_locators OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_moheader_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_project_id IN NUMBER := NULL, p_task_id IN NUMBER := NULL) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    OPEN x_locators FOR
      SELECT mil.inventory_location_id
           --, mil.concatenated_segments consegs--Bug4398337:Commented this line and added below line
           , mil.locator_segments consegs
           , mil.description
        FROM wms_item_locations_kfv mil
       WHERE mil.organization_id = p_organization_id
         AND inventory_location_id IN (SELECT to_locator_id
                                         FROM mtl_txn_request_lines
                                        WHERE header_id = p_moheader_id)
         AND mil.concatenated_segments LIKE (p_concatenated_segments)
         AND NVL(mil.project_id, -9999) = NVL(p_project_id, -9999)
         AND NVL(mil.task_id, -9999) = NVL(p_task_id, -9999);
  END;

  /* PJM-WMS Integration:Return only the the physical locators.
   *  Use the table mtl_item_locations instead of mtl_item_locations_kfv.
   *  Use the function  INV_PROJECT.get_locsegs() to retrieve the
   *  concatenated segments.Filter the locators based on the Project
   *  and Task passed to the procedure.
   */
  PROCEDURE get_loc_with_status(x_locators OUT NOCOPY t_genref,
                                p_organization_id IN NUMBER,
                                p_subinventory_code IN VARCHAR2,
                                p_concatenated_segments IN VARCHAR2,
                                p_project_id IN NUMBER , -- PJM_WMS Integration
                                p_task_id IN NUMBER ) -- PJM_WMS Integration
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    OPEN x_locators FOR
      SELECT   mil.inventory_location_id
             --, mil.concatenated_segments--Bug4398337:Commented this line and added below line
             , mil.locator_segments concatenated_segments
             , mil.description
             , mil.status_id
             , mmsv.status_code
          FROM wms_item_locations_kfv mil, mtl_material_statuses_vl mmsv
         WHERE mil.organization_id = p_organization_id
           AND mil.subinventory_code = p_subinventory_code
           AND mil.concatenated_segments LIKE (p_concatenated_segments)
           AND mmsv.status_id = mil.status_id
           AND NVL(mil.project_id, -1) = NVL(p_project_id, -1)
           AND NVL(mil.task_id, -1) = NVL(p_task_id, -1)
      ORDER BY mil.concatenated_segments; -- PJM-WMS Integration
  END get_loc_with_status;

  PROCEDURE get_loc_with_status(
            x_locators OUT NOCOPY t_genref,
            p_organization_id IN NUMBER,
            p_subinventory_code IN VARCHAR2,
            p_concatenated_segments IN VARCHAR2,
            p_project_id IN NUMBER , -- PJM_WMS Integration
            p_task_id IN NUMBER,  -- PJM_WMS Integration
            p_alias IN  VARCHAR2
            ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     IF p_alias IS NULL THEN
        get_loc_with_status(
             x_locators              => x_locators
            ,p_organization_id       => p_organization_id
            ,p_subinventory_code     => p_subinventory_code
            ,p_concatenated_segments => p_concatenated_segments
            ,p_project_id            => p_project_id
            ,p_task_id               => p_task_id
            );
        RETURN;
     END IF;
    OPEN x_locators FOR
      SELECT   mil.inventory_location_id
             --, mil.concatenated_segments--Bug4398337:Commented this line and added below line
             , mil.locator_segments concatenated_segments
             , mil.description
             , mil.status_id
             , mmsv.status_code
          FROM wms_item_locations_kfv mil, mtl_material_statuses_vl mmsv
         WHERE mil.organization_id = p_organization_id
           AND mil.subinventory_code = p_subinventory_code
           AND mil.alias = p_alias
           AND mmsv.status_id = mil.status_id
           AND NVL(mil.project_id, -1) = NVL(p_project_id, -1)
           AND NVL(mil.task_id, -1) = NVL(p_task_id, -1)
      ORDER BY mil.concatenated_segments; -- PJM-WMS Integration
  END get_loc_with_status;

  ---- Obsolete
  PROCEDURE get_from_subs(
            x_zones                        OUT NOCOPY t_genref
          , p_organization_id              IN  NUMBER
          , p_inventory_item_id            IN  NUMBER
          , p_restrict_subinventories_code IN  NUMBER
          , p_secondary_inventory_name     IN  VARCHAR2
          , p_transaction_action_id        IN  NUMBER
          , p_transaction_type_id          IN  NUMBER
          , p_wms_installed                IN  VARCHAR2
          ) IS
     l_expense_to_asset VARCHAR2(1);
     l_debug            NUMBER;
  BEGIN
     fnd_profile.get('INV:EXPENSE_TO_ASSET_TRANSFER', l_expense_to_asset);
     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    IF (NVL(l_expense_to_asset, '2') = '1') THEN
      IF (p_transaction_action_id <> 2
          AND p_transaction_action_id <> 3
         ) THEN
        IF p_restrict_subinventories_code = 1 THEN
          OPEN x_zones FOR
            SELECT a.secondary_inventory_name
                 , NVL(a.locator_type, 1)
                 , a.description
                 , a.asset_inventory
                 , a.lpn_controlled_flag
                 , a.enable_locator_alias
              FROM mtl_secondary_inventories a, mtl_item_sub_inventories b
             WHERE a.organization_id = p_organization_id
               AND a.organization_id = b.organization_id
               AND b.inventory_item_id = p_inventory_item_id
               AND a.secondary_inventory_name = b.secondary_inventory
               AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND a.secondary_inventory_name LIKE (p_secondary_inventory_name)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, a.secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
        ELSE
          OPEN x_zones FOR
            SELECT secondary_inventory_name
                 , NVL(locator_type, 1)
                 , description
                 , asset_inventory
                 , lpn_controlled_flag
                 , enable_locator_alias
              FROM mtl_secondary_inventories
             WHERE organization_id = p_organization_id
               AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND secondary_inventory_name LIKE (p_secondary_inventory_name)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
        END IF;
      ELSE
        IF p_restrict_subinventories_code = 1 THEN
          OPEN x_zones FOR
            SELECT a.secondary_inventory_name
                 , NVL(a.locator_type, 1)
                 , a.description
                 , a.asset_inventory
                 , a.lpn_controlled_flag
                 , a.enable_locator_alias
              FROM mtl_secondary_inventories a, mtl_item_sub_inventories b
             WHERE a.organization_id = p_organization_id
               AND a.organization_id = b.organization_id
               AND a.secondary_inventory_name = b.secondary_inventory
               AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND b.inventory_item_id = p_inventory_item_id
               AND a.secondary_inventory_name LIKE (p_secondary_inventory_name)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, a.secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
        ELSE
          OPEN x_zones FOR
            SELECT secondary_inventory_name
                 , NVL(locator_type, 1)
                 , description
                 , asset_inventory
                 , lpn_controlled_flag
                 , enable_locator_alias
              FROM mtl_secondary_inventories
             WHERE organization_id = p_organization_id
               AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND secondary_inventory_name LIKE (p_secondary_inventory_name)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
        END IF;
      END IF;
    ELSE
      IF (p_transaction_action_id <> 2
          AND p_transaction_action_id <> 3
         ) THEN
        IF p_restrict_subinventories_code = 1 THEN
          OPEN x_zones FOR
            SELECT a.secondary_inventory_name
                 , NVL(a.locator_type, 1)
                 , a.description
                 , a.asset_inventory
                 , a.lpn_controlled_flag
                 , a.enable_locator_alias
              FROM mtl_secondary_inventories a, mtl_item_sub_inventories b
             WHERE a.organization_id = p_organization_id
               AND a.organization_id = b.organization_id
               AND a.secondary_inventory_name = b.secondary_inventory
               AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND b.inventory_item_id = p_inventory_item_id
               AND a.secondary_inventory_name LIKE (p_secondary_inventory_name)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, a.secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
        ELSE
          OPEN x_zones FOR
            SELECT secondary_inventory_name
                 , NVL(locator_type, 1)
                 , description
                 , asset_inventory
                 , lpn_controlled_flag
                 , enable_locator_alias
              FROM mtl_secondary_inventories
             WHERE organization_id = p_organization_id
               AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND secondary_inventory_name LIKE (p_secondary_inventory_name)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
        END IF;
      ELSE
        IF p_restrict_subinventories_code = 1 THEN
          OPEN x_zones FOR
            SELECT a.secondary_inventory_name
                 , NVL(a.locator_type, 1)
                 , a.description
                 , a.asset_inventory
                 , a.lpn_controlled_flag
                 , a.enable_locator_alias
              FROM mtl_secondary_inventories a, mtl_item_sub_inventories b
             WHERE a.organization_id = p_organization_id
               AND a.organization_id = b.organization_id
               AND a.secondary_inventory_name = b.secondary_inventory
               AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND b.inventory_item_id = p_inventory_item_id
               AND a.secondary_inventory_name LIKE (p_secondary_inventory_name)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, a.secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
        ELSE
          OPEN x_zones FOR
            SELECT secondary_inventory_name
                 , NVL(locator_type, 1)
                 , description
                 , asset_inventory
                 , lpn_controlled_flag
                 , enable_locator_alias
              FROM mtl_secondary_inventories
             WHERE organization_id = p_organization_id
               AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND secondary_inventory_name LIKE (p_secondary_inventory_name)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
        END IF;
      END IF;
    END IF;
  END get_from_subs;

  ---obsolete
  PROCEDURE get_to_sub(
            x_to_sub                       OUT NOCOPY t_genref
          , p_organization_id              IN  NUMBER
          , p_inventory_item_id            IN  NUMBER
          , p_from_secondary_name          IN  VARCHAR2
          , p_restrict_subinventories_code IN  NUMBER
          , p_secondary_inventory_name     IN  VARCHAR2
          , p_from_sub_asset_inventory     IN  VARCHAR2
          , p_transaction_action_id        IN  NUMBER
          , p_to_organization_id           IN  NUMBER
          , p_serial_number_control_code   IN  NUMBER
          , p_transaction_type_id          IN  NUMBER
          , p_wms_installed                IN  VARCHAR2
          ) IS
     l_expense_to_asset             VARCHAR2(1);
     l_inventory_asset_flag         VARCHAR2(1);
     l_org                          NUMBER;
     l_restrict_subinventories_code NUMBER;
     l_from_sub                     VARCHAR2(10);
     l_from_sub_asset_inventory     VARCHAR2(1);
     l_debug                        NUMBER;
  BEGIN

    l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    IF p_transaction_action_id IN (3, 21) THEN
      l_org  := p_to_organization_id;

      SELECT restrict_subinventories_code
        INTO l_restrict_subinventories_code
        FROM mtl_system_items
       WHERE organization_id = l_org
         AND inventory_item_id = p_inventory_item_id;
    ELSE
      l_org                           := p_organization_id;
      l_restrict_subinventories_code  := p_restrict_subinventories_code;
    END IF;

    l_from_sub                  := p_from_secondary_name;
    l_from_sub_asset_inventory  := p_from_sub_asset_inventory;

    SELECT inventory_asset_flag
      INTO l_inventory_asset_flag
      FROM mtl_system_items
     WHERE inventory_item_id = p_inventory_item_id
       AND organization_id = l_org;

    fnd_profile.get('INV:EXPENSE_TO_ASSET_TRANSFER', l_expense_to_asset);

    IF (NVL(l_expense_to_asset, '2') = '1') THEN
      IF l_restrict_subinventories_code = 1 THEN
        OPEN x_to_sub FOR
          SELECT a.secondary_inventory_name
               , NVL(a.locator_type, 1)
               , a.description
               , a.asset_inventory
               , a.lpn_controlled_flag
               , a.enable_locator_alias
            FROM mtl_secondary_inventories a, mtl_item_sub_inventories b
           WHERE a.organization_id = l_org
             AND a.organization_id = b.organization_id
             AND a.secondary_inventory_name = b.secondary_inventory
             AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND b.inventory_item_id = p_inventory_item_id
             AND a.secondary_inventory_name LIKE (p_secondary_inventory_name)
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_to_organization_id, p_inventory_item_id, a.secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
      ELSE
        OPEN x_to_sub FOR
          SELECT secondary_inventory_name
               , NVL(locator_type, 1)
               , description
               , asset_inventory
               , lpn_controlled_flag
               , enable_locator_alias
            FROM mtl_secondary_inventories
           WHERE organization_id = l_org
             AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND secondary_inventory_name LIKE (p_secondary_inventory_name)
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_to_organization_id, p_inventory_item_id, secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
      END IF;
    ELSE
      IF l_restrict_subinventories_code = 1 THEN
        IF l_inventory_asset_flag = 'Y' THEN
          IF l_from_sub_asset_inventory = 1 THEN
            OPEN x_to_sub FOR
              SELECT a.secondary_inventory_name
                   , NVL(a.locator_type, 1)
                   , a.description
                   , a.asset_inventory
                   , a.lpn_controlled_flag
                   , a.enable_locator_alias
                FROM mtl_secondary_inventories a, mtl_item_sub_inventories b
               WHERE a.organization_id = l_org
                 AND a.organization_id = b.organization_id
                 --  and a.asset_inventory = 1
                 AND b.inventory_item_id = p_inventory_item_id
                 AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                 AND a.secondary_inventory_name = b.secondary_inventory
                 AND a.secondary_inventory_name LIKE (p_secondary_inventory_name)
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_to_organization_id, p_inventory_item_id, a.secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
          ELSE
            OPEN x_to_sub FOR
              SELECT a.secondary_inventory_name
                   , NVL(a.locator_type, 1)
                   , a.description
                   , a.asset_inventory
                   , a.lpn_controlled_flag
                   , a.enable_locator_alias
                FROM mtl_secondary_inventories a, mtl_item_sub_inventories b
               WHERE a.organization_id = l_org
                 AND a.organization_id = b.organization_id
                 AND a.asset_inventory = 2
                 AND b.inventory_item_id = p_inventory_item_id
                 AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                 AND a.secondary_inventory_name = b.secondary_inventory
                 AND a.secondary_inventory_name LIKE (p_secondary_inventory_name)
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_to_organization_id, p_inventory_item_id, a.secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
          END IF;
        ELSE
          OPEN x_to_sub FOR
            SELECT a.secondary_inventory_name
                 , NVL(a.locator_type, 1)
                 , a.description
                 , a.asset_inventory
                 , a.lpn_controlled_flag
                 , a.enable_locator_alias
              FROM mtl_secondary_inventories a, mtl_item_sub_inventories b
             WHERE a.organization_id = l_org
               AND a.organization_id = b.organization_id
               AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND a.secondary_inventory_name = b.secondary_inventory
               AND b.inventory_item_id = p_inventory_item_id
               AND a.secondary_inventory_name LIKE (p_secondary_inventory_name)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_to_organization_id, p_inventory_item_id, a.secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
        END IF;
      ELSE
        IF l_inventory_asset_flag = 'Y' THEN
          IF l_from_sub_asset_inventory = 1 THEN
            OPEN x_to_sub FOR
              SELECT secondary_inventory_name
                   , NVL(locator_type, 1)
                   , description
                   , asset_inventory
                   , lpn_controlled_flag
                   , enable_locator_alias
                FROM mtl_secondary_inventories
               WHERE organization_id = l_org
                 --and asset_inventory = 1
                 AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                 AND secondary_inventory_name LIKE (p_secondary_inventory_name)
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_to_organization_id, p_inventory_item_id, secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
          ELSE
            OPEN x_to_sub FOR
              SELECT secondary_inventory_name
                   , NVL(locator_type, 1)
                   , description
                   , asset_inventory
                   , lpn_controlled_flag
                   , enable_locator_alias
                FROM mtl_secondary_inventories
               WHERE organization_id = l_org
                 AND asset_inventory = 2
                 AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                 AND secondary_inventory_name LIKE (p_secondary_inventory_name)
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_to_organization_id, p_inventory_item_id, secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
          END IF;
        ELSE
          OPEN x_to_sub FOR
            SELECT secondary_inventory_name
                 , NVL(locator_type, 1)
                 , description
                 , asset_inventory
                 , lpn_controlled_flag
                 , enable_locator_alias
              FROM mtl_secondary_inventories
             WHERE organization_id = l_org
               AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND secondary_inventory_name LIKE (p_secondary_inventory_name)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_to_organization_id, p_inventory_item_id, secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y';
        END IF;
      END IF;
    END IF;
  END get_to_sub;

  -- Obsolete
  PROCEDURE get_valid_subs(
            x_zones             OUT NOCOPY t_genref
          , p_organization_id   IN  NUMBER
          , p_subinventory_code IN  VARCHAR2
          ) IS
     l_debug NUMBER;
  BEGIN
      l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     --bug#3440453 Remove the NVL on organization_id if user passes it.
     IF p_organization_id IS NULL THEN
        OPEN x_zones FOR
         SELECT   secondary_inventory_name
                , NVL(locator_type, 1)
                , description
                , asset_inventory
                , lpn_controlled_flag
                , enable_locator_alias
             FROM mtl_secondary_inventories
            WHERE organization_id = NVL(p_organization_id, organization_id)
              AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
              AND secondary_inventory_name LIKE (p_subinventory_code)
         ORDER BY secondary_inventory_name;
     ELSE  -- Organization_id is not null
       OPEN x_zones FOR
        SELECT   secondary_inventory_name
               , NVL(locator_type, 1)
               , description
               , asset_inventory
               , lpn_controlled_flag
               , enable_locator_alias
            FROM mtl_secondary_inventories
           WHERE organization_id = p_organization_id
             AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND secondary_inventory_name LIKE (p_subinventory_code)
        ORDER BY secondary_inventory_name;
     END IF;
  END get_valid_subs;

  --=Obsolete
  PROCEDURE get_valid_subinvs(
            x_zones             OUT NOCOPY t_genref
          , p_organization_id   IN  NUMBER
          , p_subinventory_code IN  VARCHAR2
          , p_txn_type_id       IN  NUMBER
          , p_wms_installed     IN  VARCHAR2
          ) IS
     l_debug NUMBER;
  BEGIN
     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     --bug#3440453 Remove the NVL on organization_id if user passes a value to it.
     IF p_organization_id IS NULL THEN
       OPEN x_zones FOR
         SELECT   secondary_inventory_name
                , NVL(locator_type, 1)
                , description
                , asset_inventory
                , lpn_controlled_flag
                , enable_locator_alias
             FROM mtl_secondary_inventories
            WHERE organization_id = NVL(p_organization_id, organization_id)
              AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
              AND secondary_inventory_name LIKE (p_subinventory_code)
              AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, NULL, NULL, p_organization_id, NULL, secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y'
         ORDER BY secondary_inventory_name;
     ELSE -- Organization_id is not null
        OPEN x_zones FOR
          SELECT   secondary_inventory_name
                 , NVL(locator_type, 1)
                 , description
                 , asset_inventory
                 , lpn_controlled_flag
                 , enable_locator_alias
              FROM mtl_secondary_inventories
             WHERE organization_id = p_organization_id
               AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND secondary_inventory_name LIKE (p_subinventory_code)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, NULL, NULL, p_organization_id, NULL, secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y'
          ORDER BY secondary_inventory_name;
     END IF;
  END get_valid_subinvs;

  FUNCTION check_loc_existence(p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2)
    RETURN NUMBER IS
    loc_control NUMBER;
    loc_exists  NUMBER := 0;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    /* Bug #1613379
    SELECT 1
      INTO loc_exists
     FROM DUAL
     WHERE exists (select 1
                  FROM mtl_item_locations
                  WHERE organization_id = p_organization_id
                    AND subinventory_code = p_subinventory_code);
      */

    SELECT locator_type
      INTO loc_control
      FROM mtl_secondary_inventories
     WHERE organization_id = p_organization_id
       AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
       AND secondary_inventory_name = p_subinventory_code;

    IF loc_control <> 0 THEN
      loc_exists  := 1;
    END IF;

    RETURN loc_exists;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      loc_exists  := 0;
      RETURN loc_exists;
  END check_loc_existence;

  /* This procedure is for the status update find page, here the locatorType
     in the second parameter represents if any locators exist in the current
     subinventory but doesnt really mean the locator control type   */
  -- Obsolete
  PROCEDURE get_sub_with_loc(
            x_zones OUT NOCOPY t_genref
          , p_organization_id IN NUMBER
          , p_subinventory_code IN VARCHAR2
          ) IS
     l_debug NUMBER;
  BEGIN
     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    OPEN x_zones FOR
      SELECT secondary_inventory_name
           , inv_ui_item_sub_loc_lovs.check_loc_existence(p_organization_id, secondary_inventory_name)
           , msi.description
           , asset_inventory
           , mmsv.status_id
           , status_code
           , enable_locator_alias
        FROM mtl_secondary_inventories msi, mtl_material_statuses_vl mmsv
       WHERE organization_id = p_organization_id
         AND mmsv.status_id = msi.status_id
         AND NVL(msi.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
         AND secondary_inventory_name LIKE (p_subinventory_code);
  END get_sub_with_loc;

  --- Obsolete
  PROCEDURE get_sub_lov_ship(
            x_sub_lov             OUT NOCOPY t_genref
          , p_txn_dock            IN  VARCHAR2
          , p_organization_id     IN  NUMBER
          , p_dock_appointment_id IN  NUMBER
          , p_sub                 IN VARCHAR2
          ) IS
     l_debug NUMBER;
  BEGIN
     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    IF (p_txn_dock = 'Y') THEN
      OPEN x_sub_lov FOR
        SELECT msub.secondary_inventory_name
             , NVL(msub.locator_type, 1)
             , msub.description
             , msub.asset_inventory
             , msub.lpn_controlled_flag
             , msub.enable_locator_alias
          FROM mtl_secondary_inventories msub
         WHERE msub.organization_id = p_organization_id
           AND NVL(msub.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
           AND EXISTS( SELECT wda.staging_lane_id
                         FROM wms_dock_appointments_b wda, mtl_item_locations milk, wsh_trip_stops pickup_stop
                        WHERE milk.inventory_location_id(+) = wda.staging_lane_id
                          AND milk.organization_id(+) = wda.organization_id
                          AND milk.organization_id = p_organization_id
                          AND milk.subinventory_code = msub.secondary_inventory_name
                          AND wda.dock_appointment_id = p_dock_appointment_id
                          AND wda.trip_stop = pickup_stop.stop_id(+))
           AND msub.secondary_inventory_name LIKE (p_sub);
    ELSIF (p_txn_dock = 'N') THEN
      OPEN x_sub_lov FOR
        SELECT msub.secondary_inventory_name
             , NVL(msub.locator_type, 1)
             , msub.description
             , msub.asset_inventory
             , lpn_controlled_flag
             , enable_locator_alias
          FROM mtl_secondary_inventories msub
         WHERE msub.organization_id = p_organization_id
           AND NVL(msub.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
           AND EXISTS( SELECT milk.inventory_location_id
                         FROM mtl_item_locations milk, wms_license_plate_numbers lpn
                        WHERE milk.inventory_location_id(+) = lpn.locator_id
                          AND milk.organization_id(+) = lpn.organization_id
                          AND milk.organization_id = p_organization_id
                          AND milk.subinventory_code = msub.secondary_inventory_name
                          AND (lpn.lpn_context = 1
                               OR lpn.lpn_context = 11
                              ))
           AND msub.secondary_inventory_name LIKE (p_sub);
    END IF;
  END get_sub_lov_ship;

  PROCEDURE get_to_xsubs(x_to_xsubs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    OPEN x_to_xsubs FOR
      SELECT   secondary_inventory_name
             , locator_type
             , description
             , asset_inventory
             , lpn_controlled_flag
          FROM mtl_secondary_inventories
         WHERE organization_id = p_organization_id
           AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
           AND secondary_inventory_name LIKE (p_subinventory_code)
      ORDER BY secondary_inventory_name;
  END get_to_xsubs;

  --      Name: GET_PHYINV_SUBS
  --
  --      Input parameters:
  --       p_subinventory_code     - restricts the subinventory to those like
  --                                 the user inputted text if given
  --       p_organization_id       - restricts LOV SQL to current org
  --       p_all_sub_flag          - all subinventories flag which indicates
  --                                 whether all the subs associated with the
  --                                 org are used or only those that are defined
  --                                 for that particular physical inventory
  --       p_physical_inventory_id - The physical inventory for which we are
  --                                 querying up the subs for
  --
  --
  --      Output parameters:
  --       x_phy_inv_sub_lov       - Returns LOV rows as reference cursor
  --
  --      Functions: This API returns the valid subs associated with a
  --                 physical inventory
  --
  --- obsolete
  PROCEDURE get_phyinv_subs(
            x_phy_inv_sub_lov        OUT NOCOPY t_genref
          , p_subinventory_code      IN  VARCHAR2
          , p_organization_id        IN  NUMBER
          , p_all_sub_flag           IN  NUMBER
          , p_physical_inventory_id  IN  NUMBER
          ) IS
       --l_dynamic_tag_entry_flag    NUMBER;
     l_debug NUMBER;
  BEGIN

     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     /* bug 1727378 fix*/
     -- Get the dynamic tag entry flag
     --SELECT dynamic_tag_entry_flag
     --  INTO l_dynamic_tag_entry_flag
     --  FROM mtl_physical_inventories
     --  WHERE physical_inventory_id = p_physical_inventory_id
     --  AND organization_id = p_organization_id;

     --IF (l_dynamic_tag_entry_flag = 1) THEN
     -- Dynamic tags are allowed
     --   OPEN x_phy_inv_sub_lov FOR
     -- SELECT msub.secondary_inventory_name
     -- , Nvl(msub.locator_type, 1)
     -- , msub.description
     -- , msub.asset_inventory
     -- , msub.lpn_controlled_flag
     -- FROM mtl_secondary_inventories msub
     -- WHERE msub.organization_id = p_organization_id
     -- AND nvl(msub.disable_date, trunc(sysdate+1)) > trunc(sysdate)
     -- AND msub.secondary_inventory_name LIKE (p_subinventory_code || '%')
     -- ORDER BY UPPER(msub.secondary_inventory_name);
     -- ELSE
     -- Dynamic tags are not allowed
     /* bug 1727378 fix*/

     IF (p_all_sub_flag = 1) THEN
   -- All Subinventories included for this physical inventory
   OPEN x_phy_inv_sub_lov FOR
     SELECT msub.secondary_inventory_name
     , NVL(msub.locator_type, 1)
     , msub.description
     , msub.asset_inventory
     , msub.lpn_controlled_flag
     , msub.enable_locator_alias
     FROM mtl_secondary_inventories msub
     WHERE msub.organization_id = p_organization_id
     AND NVL(msub.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
     AND msub.secondary_inventory_name LIKE (p_subinventory_code)
          ORDER BY UPPER(msub.secondary_inventory_name);
      ELSE
   -- Include only those subinventories which have been explicitly
   -- associated with this physical inventory
   OPEN x_phy_inv_sub_lov FOR
     SELECT UNIQUE msub.secondary_inventory_name
     , NVL(msub.locator_type, 1)
     , msub.description
     , msub.asset_inventory
     , msub.lpn_controlled_flag
     , msub.enable_locator_alias
     FROM mtl_secondary_inventories msub, mtl_physical_subinventories mpsub
     WHERE msub.organization_id = p_organization_id
     AND mpsub.organization_id = p_organization_id
     AND mpsub.subinventory = msub.secondary_inventory_name
     AND mpsub.physical_inventory_id = p_physical_inventory_id
     AND NVL(msub.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
     AND msub.secondary_inventory_name LIKE (p_subinventory_code)
        ORDER BY UPPER(msub.secondary_inventory_name);
     END IF;

  END get_phyinv_subs;

  --      Name: GET_PHYINV_LOCS
  --
  --      Input parameters:
  --       p_organization_id       - restricts LOV SQL to current org
  --       p_subinventory_code     - restricts LOV to the current subinventory
  --       p_concatenated_segments - restricts the locator to those that are
  --                                 similar to the user inputted text.
  --                                 locators are a key flex field so this
  --                                 is how the user represents/identifies locators
  --       p_dynamic_entry_flag    - this flag determines whether or not
  --                                 dynamic tag entries are allowed
  --       p_physical_inventory_id - The physical inventory for which we are
  --                                 querying up the locators for
  --
  --
  --      Output parameters:
  --       x_locators       - Returns LOV rows as reference cursor
  --
  --      Functions: This API returns the valid locators associated with a
  --                 physical inventory
  --
  PROCEDURE get_phyinv_locs
    (x_locators               OUT    NOCOPY t_genref ,
     p_organization_id        IN     NUMBER          ,
     p_subinventory_code      IN     VARCHAR2        ,
     p_concatenated_segments  IN     VARCHAR2        ,
     p_dynamic_entry_flag     IN     NUMBER          ,
     p_physical_inventory_id  IN     NUMBER          ,
     p_project_id             IN     NUMBER := NULL  ,
     p_task_id                IN     NUMBER := NULL
     )
    IS
       l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     IF (p_dynamic_entry_flag = 2) THEN
   -- Dynamic entries are not allowed
   OPEN x_locators FOR
     SELECT UNIQUE mil.inventory_location_id
     --, mil.concatenated_segments--Bug4398337:Commented this line and added below line
     , mil.locator_segments concatenated_segments
     , mil.description
     FROM wms_item_locations_kfv mil, mtl_physical_inventory_tags mpit
     WHERE mil.organization_id = p_organization_id
     AND mil.subinventory_code = p_subinventory_code
     AND mil.concatenated_segments LIKE (p_concatenated_segments)
     AND mil.inventory_location_id = mpit.locator_id
     AND mpit.physical_inventory_id = p_physical_inventory_id
     AND mpit.organization_id = p_organization_id
     AND NVL(mpit.void_flag, 2) = 2
     -- WMS PJM Integration:  Restrict Locators based on the project and task
     AND NVL(mil.project_id, -1) = NVL(p_project_id, -1)
     AND NVL(mil.task_id, -1) = NVL(p_task_id, -1)
     --For bug number 4885951
     AND NVL(mil.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
     AND mpit.adjustment_id IN (SELECT adjustment_id
                 FROM mtl_physical_adjustments
                 WHERE physical_inventory_id = p_physical_inventory_id
                 AND organization_id = p_organization_id
                 AND approval_status IS NULL);
          ELSE
   -- dynamic entries are allowed
   OPEN x_locators FOR
     SELECT inventory_location_id
     --, concatenated_segments--Bug4398337:Commented this line and added below line
     , locator_segments concatenated_segments
     , description
          FROM wms_item_locations_kfv mil
     WHERE organization_id = p_organization_id
     AND subinventory_code = p_subinventory_code
     AND concatenated_segments LIKE (p_concatenated_segments)
     -- WMS PJM Integration:  Restrict Locators based on the project and task
     AND NVL(project_id, -1) = NVL(p_project_id, -1)
     AND NVL(task_id, -1) = NVL(p_task_id, -1)
     --For bug number 4885951
     AND NVL(mil.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE);

     END IF;
  END get_phyinv_locs;

  PROCEDURE get_phyinv_locs
    (x_locators               OUT    NOCOPY t_genref ,
     p_organization_id        IN     NUMBER          ,
     p_subinventory_code      IN     VARCHAR2        ,
     p_concatenated_segments  IN     VARCHAR2        ,
     p_dynamic_entry_flag     IN     NUMBER          ,
     p_physical_inventory_id  IN     NUMBER          ,
     p_project_id             IN     NUMBER := NULL  ,
     p_task_id                IN     NUMBER := NULL  ,
     p_alias                  IN     VARCHAR2
     )
    IS
       l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN

     IF p_alias IS NULL THEN
        get_phyinv_locs(
         x_locators               => x_locators
        ,p_organization_id        => p_organization_id
        ,p_subinventory_code      => p_subinventory_code
        ,p_concatenated_segments  => p_concatenated_Segments
        ,p_dynamic_entry_flag     => p_dynamic_entry_flag
        ,p_physical_inventory_id  => p_physical_inventory_id
        ,p_project_id             => p_project_id
        ,p_task_id                => p_task_id
        );
        RETURN;
     END IF;
     IF (p_dynamic_entry_flag = 2) THEN
   -- Dynamic entries are not allowed
   OPEN x_locators FOR
     SELECT UNIQUE mil.inventory_location_id
     --, mil.concatenated_segments--Bug4398337:Commented this line and added below line
     , mil.locator_segments concatenated_segments
     , mil.description
     FROM wms_item_locations_kfv mil, mtl_physical_inventory_tags mpit
     WHERE mil.organization_id = p_organization_id
     AND mil.subinventory_code = p_subinventory_code
     AND mil.alias = p_alias
     AND mil.inventory_location_id = mpit.locator_id
     AND mpit.physical_inventory_id = p_physical_inventory_id
     AND mpit.organization_id = p_organization_id
     AND NVL(mpit.void_flag, 2) = 2
     -- WMS PJM Integration:  Restrict Locators based on the project and task
     AND NVL(mil.project_id, -1) = NVL(p_project_id, -1)
     AND NVL(mil.task_id, -1) = NVL(p_task_id, -1)
     --For bug number 4885951
     AND NVL(mil.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
     AND mpit.adjustment_id IN (SELECT adjustment_id
                 FROM mtl_physical_adjustments
                 WHERE physical_inventory_id = p_physical_inventory_id
                 AND organization_id = p_organization_id
                 AND approval_status IS NULL);
          ELSE
   -- dynamic entries are allowed
   OPEN x_locators FOR
     SELECT inventory_location_id
     --, concatenated_segments--Bug4398337:Commented this line and added below line
     , locator_segments concatenated_segments
     , description
          FROM wms_item_locations_kfv mil
     WHERE organization_id = p_organization_id
     AND subinventory_code = p_subinventory_code
     AND alias = p_alias
     -- WMS PJM Integration:  Restrict Locators based on the project and task
     AND NVL(project_id, -1) = NVL(p_project_id, -1)
     AND NVL(task_id, -1) = NVL(p_task_id, -1)
     --For bug number 4885951
     AND NVL(mil.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE);

     END IF;
  END get_phyinv_locs;

  --      Name: GET_CYC_SUBS
  --
  --      Input parameters:
  --       p_subinventory_code     - restricts the subinventory to those like
  --                                 the user inputted text if given
  --       p_organization_id       - restricts LOV SQL to current org
  --       p_orientation_code      - orientation code which indicates
  --                                 whether all the subs associated with the
  --                                 org are used or only those that are defined
  --                                 for that particular cycle count
  --       p_cycle_count_header_id - The physical inventory for which we are
  --                                 querying up the subs for
  --
  --
  --      Output parameters:
  --       x_cyc_sub_lov       - Returns LOV rows as reference cursor
  --
  --      Functions: This API returns the valid subs associated with a
  --                 cycle count
  --
  --- obsolete
  PROCEDURE get_cyc_subs(
            x_cyc_sub_lov            OUT NOCOPY t_genref
          , p_subinventory_code      IN  VARCHAR2
          , p_organization_id        IN  NUMBER
          , p_orientation_code       IN  NUMBER
          , p_cycle_count_header_id  IN  NUMBER
          ) IS
       l_unscheduled_count_entry  NUMBER;
       l_debug                    NUMBER;
  BEGIN
     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     IF (p_orientation_code = 1) THEN
   -- All subinventories in the org are included for this cycle count
     OPEN x_cyc_sub_lov FOR
     SELECT   msub.secondary_inventory_name
     , NVL(msub.locator_type, 1)
     , msub.description
     , msub.asset_inventory
     , msub.lpn_controlled_flag
     , msub.enable_locator_alias
     FROM mtl_secondary_inventories msub
     WHERE msub.organization_id = p_organization_id
     AND NVL(msub.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
     AND msub.secondary_inventory_name LIKE (p_subinventory_code)
     -- Bug# 2770853
     -- Check for material status at the subinventory level
     AND (INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
                         NULL,
                         4,
                         NULL,
                         NULL,
                         msub.organization_id,
                         NULL,
                         msub.secondary_inventory_name,
                         NULL,
                         NULL,
                         NULL,
                         'Z') = 'Y')
     ORDER BY UPPER(msub.secondary_inventory_name);
      ELSE
   -- Include only those subinventories which have been explicitly
   -- associated with this cycle count
   OPEN x_cyc_sub_lov FOR
     SELECT UNIQUE msub.secondary_inventory_name
     , NVL(msub.locator_type, 1)
     , msub.description
     , msub.asset_inventory
     , msub.lpn_controlled_flag
     , msub.enable_locator_alias
     FROM mtl_secondary_inventories msub, mtl_cc_subinventories mccs
     WHERE msub.organization_id = p_organization_id
     AND mccs.cycle_count_header_id = p_cycle_count_header_id
     AND mccs.subinventory = msub.secondary_inventory_name
     AND NVL(msub.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
     AND msub.secondary_inventory_name LIKE (p_subinventory_code)
     -- Bug# 2770853
     -- Check for material status at the subinventory level
     AND (INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
                         NULL,
                         4,
                         NULL,
                         NULL,
                         msub.organization_id,
                         NULL,
                         msub.secondary_inventory_name,
                         NULL,
                         NULL,
                         NULL,
                         'Z') = 'Y')
     ORDER BY UPPER(msub.secondary_inventory_name);
     END IF;
  END get_cyc_subs;


--      Patchset I: WMS-PJM integration
--      Name: GET_CYC_LOCS
--
--      Input parameters:
--       p_organization_id       - restricts LOV SQL to current org
--       p_subinventory_code     - restricts LOV to the current subinventory
--       p_concatenated_segments - restricts the locator to those that are
--                                 similar to the user inputted text.
--                                 locators are a key flex field so this
--                                 is how the user represents/identifies locators
--       p_unscheduled_entry     - this flag determines whether or not
--                                 unscheduled count entries are allowed
--       p_cycle_count_header_id - The cycle count header for which we are
--                                 querying up the locators for.
--       p_project_id            - restrict LOV SQL to this Project Id(Default null)
--       p_task_id               - restrict LOV SQL to this Task Id(Default null)
--
--
--      Output parameters:
--       x_locators       - Returns LOV rows as reference cursor
--
--      Functions: This API returns the valid locators associated with a
--                 cycle count
--
--
--
  PROCEDURE get_cyc_locs
    (x_locators               OUT  NOCOPY t_genref ,
     p_organization_id        IN   NUMBER          ,
     p_subinventory_code      IN   VARCHAR2        ,
     p_concatenated_segments  IN   VARCHAR2        ,
     p_unscheduled_entry      IN   NUMBER          ,
     p_cycle_count_header_id  IN   NUMBER          ,
     p_project_id             IN   NUMBER          ,
     p_task_id                IN   NUMBER
     )
    IS
       l_proc_name                     CONSTANT VARCHAR2(30) := 'INV_UI_ITEM_SUB_LOCS';
       l_serial_discrepancy_option     NUMBER;
       l_container_discrepancy_option  NUMBER;
       l_debug                         NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
       l_ispjm_org                     VARCHAR2(1);
 BEGIN
   IF (l_debug = 1) THEN
      Inv_log_util.trace('p_organization_id: =======> ' || p_organization_id ,l_proc_name ,9);
      Inv_log_util.trace('p_subinventory_code: =====> ' || p_subinventory_code , l_proc_name,9);
      Inv_log_util.trace('p_concatenated_segments: => ' || p_concatenated_segments , l_proc_name,9);
      Inv_log_util.trace('p_unscheduled_entry: =====> ' || p_unscheduled_entry , l_proc_name,9);
      Inv_log_util.trace('p_cycle_count_header_id: => ' || p_cycle_count_header_id , l_proc_name,9);
      Inv_log_util.trace('p_project_id: ============> ' || p_project_id , l_proc_name,9);
      Inv_log_util.trace('p_task_id: ===============> ' || p_task_id, l_proc_name,9);
   END IF;
     BEGIN
      SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
       INTO l_ispjm_org
       FROM pjm_org_parameters
       WHERE organization_id=p_organization_id;
      EXCEPTION
        WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
      END;   -- Get the cycle count discrepancy option flags
   SELECT NVL(serial_discrepancy_option, 2), NVL(container_discrepancy_option, 2)
     INTO   l_serial_discrepancy_option, l_container_discrepancy_option
     FROM mtl_cycle_count_headers
     WHERE cycle_count_header_id = p_cycle_count_header_id;

   IF (l_debug = 1) THEN
      Inv_log_util.trace('l_serial_discrepancy_option: ' || l_serial_discrepancy_option , l_proc_name,9);
      Inv_log_util.trace('l_container_discrepancy_option: ' || l_container_discrepancy_option, l_proc_name,9);
   END IF;

   IF (p_unscheduled_entry = 2 AND
       l_serial_discrepancy_option = 2 AND
       l_container_discrepancy_option = 2) THEN
      -- unscheduled count entries are not allowed
      -- and serial and container discrepancies are also not allowed
      OPEN x_locators FOR
        SELECT UNIQUE mil.inventory_location_id,
   --mil.concatenated_segments concatenated_segments,--Bug4398337:Commented this line and added below line
   mil.locator_segments concatenated_segments,
   mil.description
        FROM wms_item_locations_kfv mil, mtl_cycle_count_entries mcce
        WHERE mcce.cycle_count_header_id = p_cycle_count_header_id
        AND mil.organization_id = p_organization_id
        AND mil.subinventory_code = p_subinventory_code
        AND NVL(mil.project_id,-1) = NVL(p_project_id,-1)
        AND NVL(mil.task_id,-1) = NVL(p_task_id,-1)
        AND mil.concatenated_segments LIKE (p_concatenated_segments)
        AND mcce.organization_id = mil.organization_id
        AND mcce.subinventory = mil.subinventory_code
        AND mil.inventory_location_id = mcce.locator_id
        AND mcce.entry_status_code IN (1,3)
        AND NVL(mil.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE) -- bug # 4866575
   -- Bug# 2770853
   -- Check for material status at the locator level
   AND (INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
                       NULL,
                       4,
                       NULL,
                       NULL,
                       mcce.organization_id,
                       mcce.inventory_item_id,
                       mcce.subinventory,
                       mcce.locator_id,
                       NULL,
                       NULL,
                       'L') = 'Y')
        ORDER BY concatenated_segments;
    ELSE
      -- unscheduled count entries are allowed
      -- or serial or container discrepancy is allowed

    IF (l_ispjm_org = 'Y' and p_project_id is not null ) then
       Inv_log_util.trace('p_ispjm_org = yes and p_project_id is not null' , 'INV_UI_ITEM_SUB_LOCS',9);
       IF ( p_task_id is not null ) then
         Inv_log_util.trace('task id is not null ' , 'INV_UI_ITEM_SUB_LOCS',9);
            OPEN x_locators FOR
            SELECT inventory_location_id,
           -- concatenated_segments, --Bug4398337:Commented this line and added below line
            locator_segments concatenated_segments,
            description
            FROM wms_item_locations_kfv
            WHERE organization_id = p_organization_id
            AND subinventory_code = p_subinventory_code
            AND concatenated_segments LIKE (p_concatenated_segments )-- inv_project.get_locsegs(inventory_location_id,organization_id) LIKE (p_concatenated_segments || '%')
            AND project_id = p_project_id
            AND task_id = p_task_id
            AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE) -- bug # 4866575
            AND (INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
                       NULL,
                       4,
                       NULL,
                       NULL,
                       organization_id,
                       inventory_item_id,
                       subinventory_code,
                       inventory_location_id,
                       NULL,
                       NULL,
                       'L') = 'Y')
            ORDER BY 2;
       ELSE -- task_id is null then
         Inv_log_util.trace('Task is null ' , 'INV_UI_ITEM_SUB_LOCS',9);

           OPEN x_locators FOR
           SELECT inventory_location_id,
          -- concatenated_segments ,--Bug4398337:Commented this line and added below line
           locator_segments concatenated_segments,
           description
           FROM wms_item_locations_kfv
           WHERE organization_id = p_organization_id
           AND subinventory_code = p_subinventory_code
           AND concatenated_segments LIKE (p_concatenated_segments )--inv_project.get_locsegs(inventory_location_id,organization_id) LIKE (p_concatenated_segments || '%')
           AND project_id = p_project_id
           AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE) -- bug # 4866575
           AND (INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
                       NULL,
                       4,
                       NULL,
                       NULL,
                       organization_id,
                       inventory_item_id,
                       subinventory_code,
                       inventory_location_id,
                       NULL,
                       NULL,
                       'L') = 'Y')
           ORDER BY 2;

       END IF;
   ELSE -- non pjm org or project is not passed
       Inv_log_util.trace('non pjm org or project is not passed' , 'INV_UI_ITEM_SUB_LOCS',9);
       OPEN x_locators FOR
          SELECT inventory_location_id,
         -- concatenated_segments, --Bug4398337:Commented this line and added below line
          locator_segments concatenated_segments,
          description
          FROM wms_item_locations_kfv
          WHERE organization_id = p_organization_id
          AND subinventory_code = p_subinventory_code
          AND concatenated_segments LIKE (p_concatenated_segments )-- inv_project.get_locsegs(inventory_location_id,organization_id) LIKE (p_concatenated_segments || '%')
          AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE) -- bug # 4866575
          AND (INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
                       NULL,
                       4,
                       NULL,
                       NULL,
                       organization_id,
                       inventory_item_id,
                       subinventory_code,
                       inventory_location_id,
                       NULL,
                       NULL,
                       'L') = 'Y')
          ORDER BY 2;
     END IF;
 END IF;
END GET_CYC_LOCS;

  PROCEDURE get_cyc_locs
    (x_locators               OUT  NOCOPY t_genref ,
     p_organization_id        IN   NUMBER          ,
     p_subinventory_code      IN   VARCHAR2        ,
     p_concatenated_segments  IN   VARCHAR2        ,
     p_unscheduled_entry      IN   NUMBER          ,
     p_cycle_count_header_id  IN   NUMBER          ,
     p_project_id             IN   NUMBER          ,
     p_task_id                IN   NUMBER          ,
     p_alias                  IN   VARCHAR2
     )
    IS
       l_proc_name                     CONSTANT VARCHAR2(30) := 'INV_UI_ITEM_SUB_LOCS';
       l_serial_discrepancy_option     NUMBER;
       l_container_discrepancy_option  NUMBER;
       l_debug                         NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
       l_ispjm_org                     VARCHAR2(1);
 BEGIN
   IF (l_debug = 1) THEN
      Inv_log_util.trace('p_organization_id: =======> ' || p_organization_id ,l_proc_name ,9);
      Inv_log_util.trace('p_subinventory_code: =====> ' || p_subinventory_code , l_proc_name,9);
      Inv_log_util.trace('p_concatenated_segments: => ' || p_concatenated_segments , l_proc_name,9);
      Inv_log_util.trace('p_unscheduled_entry: =====> ' || p_unscheduled_entry , l_proc_name,9);
      Inv_log_util.trace('p_cycle_count_header_id: => ' || p_cycle_count_header_id , l_proc_name,9);
      Inv_log_util.trace('p_project_id: ============> ' || p_project_id , l_proc_name,9);
      Inv_log_util.trace('p_task_id: ===============> ' || p_task_id, l_proc_name,9);
   END IF;

   IF p_alias IS NULL THEN
      get_cyc_locs(
        x_locators               => x_locators
      , p_organization_id        => p_organization_id
      , p_subinventory_code      => p_subinventory_code
      , p_concatenated_segments  => p_concatenated_segments
      , p_unscheduled_entry      => p_unscheduled_entry
      , p_cycle_count_header_id  => p_cycle_count_header_id
      , p_project_id             => p_project_id
      , p_task_id                => p_task_id
        );
      RETURN;
   END IF;
     BEGIN
      SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
       INTO l_ispjm_org
       FROM pjm_org_parameters
       WHERE organization_id=p_organization_id;
      EXCEPTION
        WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
      END;   -- Get the cycle count discrepancy option flags
   SELECT NVL(serial_discrepancy_option, 2), NVL(container_discrepancy_option, 2)
     INTO   l_serial_discrepancy_option, l_container_discrepancy_option
     FROM mtl_cycle_count_headers
     WHERE cycle_count_header_id = p_cycle_count_header_id;

   IF (l_debug = 1) THEN
      Inv_log_util.trace('l_serial_discrepancy_option: ' || l_serial_discrepancy_option , l_proc_name,9);
      Inv_log_util.trace('l_container_discrepancy_option: ' || l_container_discrepancy_option, l_proc_name,9);
   END IF;

   IF (p_unscheduled_entry = 2 AND
       l_serial_discrepancy_option = 2 AND
       l_container_discrepancy_option = 2) THEN
      -- unscheduled count entries are not allowed
      -- and serial and container discrepancies are also not allowed
      OPEN x_locators FOR
        SELECT UNIQUE mil.inventory_location_id,
   --mil.concatenated_segments concatenated_segments,--Bug4398337:Commented this line and added below line
   mil.locator_segments concatenated_segments,
   mil.description
        FROM wms_item_locations_kfv mil, mtl_cycle_count_entries mcce
        WHERE mcce.cycle_count_header_id = p_cycle_count_header_id
        AND mil.organization_id = p_organization_id
        AND mil.subinventory_code = p_subinventory_code
        AND NVL(mil.project_id,-1) = NVL(p_project_id,-1)
        AND NVL(mil.task_id,-1) = NVL(p_task_id,-1)
        AND mil.alias = p_alias
        AND mcce.organization_id = mil.organization_id
        AND mcce.subinventory = mil.subinventory_code
        AND mil.inventory_location_id = mcce.locator_id
        AND mcce.entry_status_code IN (1,3)
        AND NVL(mil.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE) -- bug # 4866575
   -- Bug# 2770853
   -- Check for material status at the locator level
   AND (INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
                       NULL,
                       4,
                       NULL,
                       NULL,
                       mcce.organization_id,
                       mcce.inventory_item_id,
                       mcce.subinventory,
                       mcce.locator_id,
                       NULL,
                       NULL,
                       'L') = 'Y')
        ORDER BY concatenated_segments;
    ELSE
      -- unscheduled count entries are allowed
      -- or serial or container discrepancy is allowed

    IF (l_ispjm_org = 'Y' and p_project_id is not null ) then
       Inv_log_util.trace('p_ispjm_org = yes and p_project_id is not null' , 'INV_UI_ITEM_SUB_LOCS',9);
       IF ( p_task_id is not null ) then
         Inv_log_util.trace('task id is not null ' , 'INV_UI_ITEM_SUB_LOCS',9);
            OPEN x_locators FOR
            SELECT inventory_location_id,
           -- concatenated_segments, --Bug4398337:Commented this line and added below line
            locator_segments concatenated_segments,
            description
            FROM wms_item_locations_kfv
            WHERE organization_id = p_organization_id
            AND subinventory_code = p_subinventory_code
            AND alias = p_alias
            AND project_id = p_project_id
            AND task_id = p_task_id
            AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE) -- bug # 4866575
            AND (INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
                       NULL,
                       4,
                       NULL,
                       NULL,
                       organization_id,
                       inventory_item_id,
                       subinventory_code,
                       inventory_location_id,
                       NULL,
                       NULL,
                       'L') = 'Y')
            ORDER BY 2;
       ELSE -- task_id is null then
         Inv_log_util.trace('Task is null ' , 'INV_UI_ITEM_SUB_LOCS',9);

           OPEN x_locators FOR
           SELECT inventory_location_id,
          -- concatenated_segments ,--Bug4398337:Commented this line and added below line
           locator_segments concatenated_segments,
           description
           FROM wms_item_locations_kfv
           WHERE organization_id = p_organization_id
           AND subinventory_code = p_subinventory_code
           AND alias  = p_alias
           --inv_project.get_locsegs(inventory_location_id,organization_id) LIKE (p_concatenated_segments || '%')
           AND project_id = p_project_id
           AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE) -- bug # 4866575
           AND (INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
                       NULL,
                       4,
                       NULL,
                       NULL,
                       organization_id,
                       inventory_item_id,
                       subinventory_code,
                       inventory_location_id,
                       NULL,
                       NULL,
                       'L') = 'Y')
           ORDER BY 2;

       END IF;
   ELSE -- non pjm org or project is not passed
       Inv_log_util.trace('non pjm org or project is not passed' , 'INV_UI_ITEM_SUB_LOCS',9);
       OPEN x_locators FOR
          SELECT inventory_location_id,
         -- concatenated_segments, --Bug4398337:Commented this line and added below line
          locator_segments concatenated_segments,
          description
          FROM wms_item_locations_kfv
          WHERE organization_id = p_organization_id
          AND subinventory_code = p_subinventory_code
          AND alias = p_alias
          -- inv_project.get_locsegs(inventory_location_id,organization_id) LIKE (p_concatenated_segments || '%')
          AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE) -- bug # 4866575
          AND (INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
                       NULL,
                       4,
                       NULL,
                       NULL,
                       organization_id,
                       inventory_item_id,
                       subinventory_code,
                       inventory_location_id,
                       NULL,
                       NULL,
                       'L') = 'Y')
          ORDER BY 2;
     END IF;
 END IF;
END GET_CYC_LOCS;


  -- Consignment and VMI Changes: Added Planning Org, TP Type, Owning Org and TP Type.
  PROCEDURE get_valid_lpn_org_level(
    x_lpns OUT NOCOPY t_genref
  , p_organization_id IN NUMBER
  , p_lpn_segments IN VARCHAR2
  , p_planning_org_id IN NUMBER
  , p_planning_tp_type IN NUMBER
  , p_owning_org_id IN NUMBER
  , p_owning_tp_type IN NUMBER
  ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    OPEN x_lpns FOR
      SELECT DISTINCT a.license_plate_number
                    , a.outermost_lpn_id
                    , a.subinventory_code
                    , NVL(a.locator_id, 0)
                    , NVL(b.asset_inventory, '0')
                    , 0
                    , inv_project.get_locsegs(a.locator_id, p_organization_id)
                    , inv_project.get_project_id
                    , inv_project.get_project_number
                    , inv_project.get_task_id
                    , inv_project.get_task_number
                 FROM wms_license_plate_numbers a, mtl_secondary_inventories b
                WHERE a.organization_id = p_organization_id
                  AND (a.lpn_context = 1 OR a.lpn_context = 11)
                  AND b.organization_id(+) = a.organization_id
                  AND b.secondary_inventory_name(+) = a.subinventory_code
                  AND NVL(b.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                  AND a.license_plate_number LIKE (p_lpn_segments)
                  AND a.parent_lpn_id IS NULL
                  AND (p_owning_org_id IS NULL
                       OR EXISTS(SELECT 1 FROM mtl_onhand_quantities_detail moqd
                     ,wms_license_plate_numbers wlpn
                                  WHERE moqd.lpn_id in (wlpn.lpn_id)
                AND wlpn.outermost_lpn_id = a.outermost_lpn_id
                                    AND moqd.organization_id = a.organization_id
                                    AND moqd.owning_organization_id = p_owning_org_id
                                    AND moqd.owning_tp_type = p_owning_tp_type))
                  AND (p_planning_org_id IS NULL
                       OR EXISTS(SELECT 1 FROM mtl_onhand_quantities_detail moqd
                  ,wms_license_plate_numbers wlpn
                                  WHERE moqd.lpn_id in (wlpn.lpn_id)
                AND wlpn.outermost_lpn_id = a.outermost_lpn_id
                                    AND moqd.organization_id = a.organization_id
                                    AND moqd.planning_organization_id = p_planning_org_id
                                    AND moqd.planning_tp_type = p_planning_tp_type));
  END get_valid_lpn_org_level;

  --Bug 5512205 Introduced a new overloaded procedure that validates the LPN status before populating the LPN LOV for sub xfer
  PROCEDURE get_valid_lpn_org_level(
    x_lpns OUT NOCOPY t_genref
  , p_organization_id IN NUMBER
  , p_lpn_segments IN VARCHAR2
  , p_planning_org_id IN NUMBER
  , p_planning_tp_type IN NUMBER
  , p_owning_org_id IN NUMBER
  , p_owning_tp_type IN NUMBER
  , p_to_organization_id       IN     NUMBER
  , p_transaction_type_id      IN     NUMBER
  , p_wms_installed            IN     VARCHAR2
  ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    OPEN x_lpns FOR
      SELECT DISTINCT a.license_plate_number
                    , a.outermost_lpn_id
                    , a.subinventory_code
                    , NVL(a.locator_id, 0)
                    , NVL(b.asset_inventory, '0')
                    , 0
                    , inv_project.get_locsegs(a.locator_id, p_organization_id)
                    , inv_project.get_project_id
                    , inv_project.get_project_number
                    , inv_project.get_task_id
                    , inv_project.get_task_number
                 FROM wms_license_plate_numbers a, mtl_secondary_inventories b
                WHERE a.organization_id = p_organization_id
                  AND (a.lpn_context = 1 OR a.lpn_context = 11)
                  AND b.organization_id(+) = a.organization_id
                  AND b.secondary_inventory_name(+) = a.subinventory_code
                  AND NVL(b.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                  AND a.license_plate_number LIKE (p_lpn_segments)
                  AND a.parent_lpn_id IS NULL
                  AND vaildate_lpn_status(a.outermost_lpn_id
		                          ,a.organization_id
					  ,p_to_organization_id
					  ,p_wms_installed
					  ,p_transaction_type_id) = 'Y'
                  AND (p_owning_org_id IS NULL
                       OR EXISTS(SELECT 1 FROM mtl_onhand_quantities_detail moqd
                     ,wms_license_plate_numbers wlpn
                                  WHERE moqd.lpn_id in (wlpn.lpn_id)
                AND wlpn.outermost_lpn_id = a.outermost_lpn_id
                                    AND moqd.organization_id = a.organization_id
                                    AND moqd.owning_organization_id = p_owning_org_id
                                    AND moqd.owning_tp_type = p_owning_tp_type))
                  AND (p_planning_org_id IS NULL
                       OR EXISTS(SELECT 1 FROM mtl_onhand_quantities_detail moqd
                  ,wms_license_plate_numbers wlpn
                                  WHERE moqd.lpn_id in (wlpn.lpn_id)
                AND wlpn.outermost_lpn_id = a.outermost_lpn_id
                                    AND moqd.organization_id = a.organization_id
                                    AND moqd.planning_organization_id = p_planning_org_id
                                    AND moqd.planning_tp_type = p_planning_tp_type));
  END get_valid_lpn_org_level;
  --End Bug 5512205

  FUNCTION validate_lpn_for_toorg(p_lpn_id IN NUMBER, p_to_organization_id IN NUMBER, p_orgid IN NUMBER, p_transaction_type_id IN NUMBER)
    RETURN VARCHAR2 IS
    x_return  VARCHAR(1);
    l_count   NUMBER;
    l_item_id NUMBER;
    l_invalid_count NUMBER := 0;

    CURSOR l_item_cursor IS
      SELECT DISTINCT inventory_item_id
                 FROM wms_lpn_contents
                WHERE parent_lpn_id IN (SELECT lpn_id
                                          FROM wms_license_plate_numbers
                                         WHERE outermost_lpn_id = p_lpn_id)
                  AND inventory_item_id IS NOT NULL;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    x_return  := 'Y';

    IF (p_orgid IS NOT NULL AND p_transaction_type_id = 3 ) THEN

       -- bug#3440453 Split the existing SQL into 2 for performance reasons
       -- re-using the existing item_cursor
       -- checking for invalid combinations for each content in the outermost lpn
       -- and exitting from the loop as soon as one invalid combination is found.

       OPEN l_item_cursor;
       LOOP --loop for all the contents inside the outermost LPN
          FETCH l_item_cursor INTO l_item_id;
          EXIT WHEN l_item_cursor%NOTFOUND;

          BEGIN
             -- Check for invalid item control codes.
             SELECT 1
                INTO l_invalid_count
                FROM dual
                WHERE EXISTS (SELECT a.inventory_item_id
                              FROM mtl_system_items a
                                 , mtl_system_items b
                              WHERE  a.inventory_item_id = b.inventory_item_id
                                 AND a.organization_id   = p_orgid
                                 AND b.organization_id   = p_to_organization_id
                                 AND a.inventory_item_id = l_item_id
                                 AND ((a.serial_number_control_code IN (1,6) AND b.serial_number_control_code IN (2,5))
                                    OR
                                       (a.revision_qty_control_code = 1 AND b.revision_qty_control_code = 2)
                                    OR
                                       (a.lot_control_code = 1 AND b.lot_control_code = 2))
                               );

             IF (l_invalid_count <> 0) THEN
                x_return := 'N';
                IF l_item_cursor%isopen THEN
                   CLOSE l_item_cursor;
                END IF;
                RETURN x_return;
             END IF;

          EXCEPTION
             WHEN no_data_found THEN

                -- No data found can be for 2 reasons
                -- a. Item doesn't exist in TO Org which is a failure case
                -- b. The lot/serial/revision control code combinations are perfect
                -- We should check for scenario (a) and throw error.
                SELECT COUNT(*)
                  INTO l_count
                  FROM mtl_system_items
                 WHERE organization_id = p_to_organization_id
                   AND inventory_item_id = l_item_id;

                IF l_count = 1 THEN
                  x_return  := 'Y';
                ELSE
                  x_return  := 'N';
                  IF l_item_cursor%isopen THEN
                     CLOSE l_item_cursor;
                  END IF;
                  RETURN x_return;
                END IF;

             WHEN OTHERS THEN
                x_return := 'N';
                IF l_item_cursor%isopen THEN
                   CLOSE l_item_cursor;
                END IF;
                RETURN x_return;
          END;

       END LOOP;--loop for all the contents inside the outermost LPN

    IF l_item_cursor%isopen THEN
       CLOSE l_item_cursor;
    END IF;

    ELSE --Interorg transfer. Just check whether item exits in the dest org

       OPEN l_item_cursor;
       LOOP
         FETCH l_item_cursor INTO l_item_id;
         EXIT WHEN l_item_cursor%NOTFOUND;
         l_count  := 0;

         SELECT COUNT(*)
           INTO l_count
           FROM mtl_system_items
          WHERE organization_id = p_to_organization_id
            AND inventory_item_id = l_item_id;

         IF l_count = 1 THEN
           x_return  := 'Y';
         ELSE
           x_return  := 'N';
           IF l_item_cursor%isopen THEN
              CLOSE l_item_cursor;
           END IF;
           RETURN x_return;
         END IF;
       END LOOP;

       IF l_item_cursor%isopen THEN
          CLOSE l_item_cursor;
       END IF;
  END IF;

  RETURN x_return;
  END validate_lpn_for_toorg;

  --- Obsolete
  PROCEDURE get_valid_lpn_tosubs(
    x_to_sub                   OUT    NOCOPY t_genref
  , p_organization_id          IN     NUMBER
  , p_lpn_id                   IN     NUMBER
  , p_from_secondary_name      IN     VARCHAR2
  , p_from_sub_asset_inventory IN     VARCHAR2
  , p_transaction_action_id    IN     NUMBER
  , p_to_organization_id       IN     NUMBER
  , p_transaction_type_id      IN     NUMBER
  , p_wms_installed            IN     VARCHAR2
  , p_secondary_inventory_name IN     VARCHAR2
  ) IS
    l_org            NUMBER;
    l_lpn_rsvd       NUMBER;
    l_debug          NUMBER;
    l_procedure_name VARCHAR2(30);
  BEGIN
    l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_procedure_name := 'GET_VALID_LPN_TOSUBS';

    IF p_transaction_action_id IN (3, 21) THEN
      l_org  := p_to_organization_id;
    ELSE
      l_org  := p_organization_id;
    END IF;

    /* LPN reservation impact */
    BEGIN
      /*SELECT COUNT(*)
        INTO l_lpn_rsvd
        FROM mtl_reservations
       WHERE lpn_id = p_lpn_id;*/

     --Bug 5942895 Modified above query to consider nesting of LPNs.
      SELECT COUNT(*)
        INTO l_lpn_rsvd
        FROM mtl_reservations
        WHERE lpn_id IN (SELECT lpn_id
                         FROM wms_license_plate_numbers
                         WHERE outermost_lpn_id = p_lpn_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_lpn_rsvd  := 0;
      WHEN OTHERS THEN
        l_lpn_rsvd  := 0;
    END;

    IF l_lpn_rsvd = 0 THEN -- the lpn is not reserved
      OPEN x_to_sub FOR
        SELECT secondary_inventory_name
             , NVL(locator_type, 1)
             , description
             , asset_inventory
             , lpn_controlled_flag
             , enable_locator_alias
          FROM mtl_secondary_inventories
         WHERE organization_id = l_org
           AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
           AND inv_ui_item_sub_loc_lovs.vaildate_to_lpn_sub(p_lpn_id, secondary_inventory_name, l_org, p_from_sub_asset_inventory, p_wms_installed, p_transaction_type_id) = 'Y'
           AND secondary_inventory_name LIKE (p_secondary_inventory_name);
    ELSE
      OPEN x_to_sub FOR
        SELECT secondary_inventory_name
             , NVL(locator_type, 1)
             , description
             , asset_inventory
             , lpn_controlled_flag
             , enable_locator_alias
          FROM mtl_secondary_inventories
         WHERE organization_id = l_org
           AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
           AND inv_ui_item_sub_loc_lovs.vaildate_to_lpn_sub(p_lpn_id, secondary_inventory_name, l_org, p_from_sub_asset_inventory, p_wms_installed, p_transaction_type_id) = 'Y'
           AND secondary_inventory_name LIKE (p_secondary_inventory_name)
           AND reservable_type = 1
           AND lpn_controlled_flag = 1;
    END IF;
  END get_valid_lpn_tosubs;

  FUNCTION vaildate_to_lpn_sub(p_lpn_id IN NUMBER, p_to_subinventory IN VARCHAR2, p_orgid IN NUMBER, p_from_sub_asset_inventory IN VARCHAR2, p_wms_installed IN VARCHAR2, p_transaction_type_id IN NUMBER)
    RETURN VARCHAR2 IS
    l_item_id                      NUMBER;
    l_restrict_subinventories_code NUMBER;
    l_inventory_asset_flag         VARCHAR2(1);
    l_expense_to_asset             VARCHAR2(1);
    l_count                        NUMBER;
    x_return                       VARCHAR2(1);
    l_content_type                 NUMBER;
    -- Changed for Bug 1795328
    l_lpn_content                  NUMBER;

    CURSOR l_item_cursor IS
      SELECT DISTINCT inventory_item_id
                 FROM wms_lpn_contents
                WHERE parent_lpn_id IN (SELECT lpn_id
                                          FROM wms_license_plate_numbers
                                         WHERE outermost_lpn_id = p_lpn_id)
                  AND inventory_item_id IS NOT NULL;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    /*
    SELECT DISTINCT  content_type INTO l_content_type
      FROM wms_lpn_contents
      WHERE outermost_lpn_id =  p_lpn_id;

    IF l_content_type NOT IN (1) THEN
       RETURN 'Y';
    END IF;
      */

    OPEN l_item_cursor;
    l_lpn_content  := 0;

    LOOP
      FETCH l_item_cursor INTO l_item_id;
      EXIT WHEN l_item_cursor%NOTFOUND;
      l_lpn_content  := 1;

      IF inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_orgid, l_item_id, p_to_subinventory, NULL, NULL, NULL, 'Z') = 'Y' THEN
        SELECT restrict_subinventories_code
             , inventory_asset_flag
          INTO l_restrict_subinventories_code
             , l_inventory_asset_flag
          FROM mtl_system_items
         WHERE inventory_item_id = l_item_id
           AND organization_id = p_orgid;

        fnd_profile.get('INV:EXPENSE_TO_ASSET_TRANSFER', l_expense_to_asset);

        IF (NVL(l_expense_to_asset, '2') = '1') THEN
          IF l_restrict_subinventories_code = 1 THEN
            SELECT COUNT(*)
              INTO l_count
              FROM mtl_item_sub_inventories
             WHERE inventory_item_id = l_item_id
               AND organization_id = p_orgid
               AND secondary_inventory = p_to_subinventory;

            IF l_count = 0 THEN
              x_return  := 'N';
              RETURN x_return;
            ELSE
              x_return  := 'Y';
            END IF;
          ELSE
            x_return  := 'Y';
          END IF;
        ELSE
          IF l_restrict_subinventories_code = 1 THEN
            IF l_inventory_asset_flag = 'Y' THEN
              IF p_from_sub_asset_inventory = 1 THEN
                SELECT COUNT(*)
                  INTO l_count
                  FROM mtl_item_sub_inventories
                 WHERE inventory_item_id = l_item_id
                   AND organization_id = p_orgid
                   AND secondary_inventory = p_to_subinventory;

                IF l_count = 0 THEN
                  x_return  := 'N';
                  RETURN x_return;
                ELSE
                  x_return  := 'Y';
                END IF;
              ELSE
                SELECT COUNT(*)
                  INTO l_count
                  FROM mtl_item_sub_exp_val_v
                 WHERE inventory_item_id = l_item_id
                   AND organization_id = p_orgid
                   AND secondary_inventory_name = p_to_subinventory;

                IF l_count = 0 THEN
                  x_return  := 'N';
                  RETURN x_return;
                ELSE
                  x_return  := 'Y';
                END IF;
              END IF;
            ELSE
              SELECT COUNT(*)
                INTO l_count
                FROM mtl_item_sub_inventories
               WHERE inventory_item_id = l_item_id
                 AND organization_id = p_orgid
                 AND secondary_inventory = p_to_subinventory;

              IF l_count = 0 THEN
                x_return  := 'N';
                RETURN x_return;
              ELSE
                x_return  := 'Y';
              END IF;
            END IF;
          ELSE
	    --Bug#7417734.added the IF block below
	    IF l_inventory_asset_flag = 'Y' AND p_from_sub_asset_inventory = 2 THEN
	       SELECT COUNT(*)
                INTO l_count
		FROM mtl_secondary_inventories msi
               WHERE msi.organization_id = p_orgid
                 AND msi.asset_inventory = 2
                 AND NVL(msi.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                 AND msi.secondary_inventory_name = p_to_subinventory ;
              IF l_count = 0 THEN
                x_return  := 'N';
                RETURN x_return;
              ELSE
                x_return  := 'Y';
                RETURN x_return;
              END IF;
            END IF;

            x_return  := 'Y';
          END IF;
        --dbms_output.putline('jj');
        END IF;
      ELSE
        x_return  := 'N';
        RETURN x_return;
      END IF;
    END LOOP;

    CLOSE l_item_cursor;

    -- Changed for 1795328
    IF l_lpn_content = 0 THEN
      x_return  := 'Y';
    END IF;

    --END ;

    RETURN x_return;
  END vaildate_to_lpn_sub;

  FUNCTION vaildate_lpn_toloc(p_lpn_id IN NUMBER, p_to_subinventory IN VARCHAR2, p_orgid IN NUMBER, p_locator_id IN NUMBER, p_wms_installed IN VARCHAR2, p_transaction_type_id IN NUMBER)
    RETURN VARCHAR2 IS
    l_item_id                NUMBER;
    l_restrict_locators_code NUMBER;
    l_count                  NUMBER;
    x_return                 VARCHAR2(1);
    -- Changed for Bug 1795328
    l_lpn_content            NUMBER;

    CURSOR l_item_cursor IS
      SELECT DISTINCT inventory_item_id
                 FROM wms_lpn_contents
                WHERE parent_lpn_id IN (SELECT lpn_id
                                          FROM wms_license_plate_numbers
                                         WHERE outermost_lpn_id = p_lpn_id)
                  AND inventory_item_id IS NOT NULL;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_orgid, l_item_id, p_to_subinventory, p_locator_id, NULL, NULL, 'L') = 'Y' THEN
      OPEN l_item_cursor;
      l_lpn_content  := 0;

      LOOP
        FETCH l_item_cursor INTO l_item_id;
        EXIT WHEN l_item_cursor%NOTFOUND;
        l_lpn_content  := 1;

        SELECT restrict_locators_code
          INTO l_restrict_locators_code
          FROM mtl_system_items
         WHERE inventory_item_id = l_item_id
           AND organization_id = p_orgid;

        IF l_restrict_locators_code = 1 THEN
          SELECT COUNT(*)
            INTO l_count
            FROM mtl_secondary_locators
           WHERE p_locator_id = secondary_locator
             AND inventory_item_id = l_item_id
             AND organization_id = p_orgid;

          IF l_count = 0 THEN
            x_return  := 'N';
          ELSE
            x_return  := 'Y';
          END IF;
        ELSE
          x_return  := 'Y';
        END IF;
      END LOOP;

      CLOSE l_item_cursor;
    ELSE
      --x_return  := 'Y';
      -- bug 3390030, the function should return N if the material status
      -- does not return Y
      x_return := 'N';
    END IF;

    -- Changed for 1795328
    IF l_lpn_content = 0 THEN
      x_return  := 'Y';
    END IF;

    RETURN x_return;
  END vaildate_lpn_toloc;

  PROCEDURE get_lpnloc_lov(x_locators OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_lpn_id IN NUMBER, p_subinventory_code IN VARCHAR2, p_concatenated_segments IN VARCHAR2, p_transaction_type_id IN NUMBER, p_wms_installed IN VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    OPEN x_locators FOR
      SELECT inventory_location_id
           --, concatenated_segments--Bug4398337:Commented this line and added below line
           , locator_segments concatenated_segments
           , description
        FROM wms_item_locations_kfv
       WHERE organization_id = p_organization_id
         AND subinventory_code = p_subinventory_code
         AND concatenated_segments LIKE (p_concatenated_segments)
         AND inv_ui_item_sub_loc_lovs.vaildate_lpn_toloc(p_lpn_id, p_subinventory_code, p_organization_id, inventory_location_id, p_wms_installed, p_transaction_type_id) = 'Y';
  END get_lpnloc_lov;

  FUNCTION validate_sub_loc_status(p_lpn IN VARCHAR2, p_org_id IN NUMBER, p_sub IN VARCHAR2, p_loc_id IN NUMBER, p_not_lpn_id IN VARCHAR2 := NULL, p_parent_lpn_id IN VARCHAR2 := '0', p_txn_type_id IN NUMBER)
    RETURN VARCHAR2 IS
    x_return         VARCHAR2(1) := 'U';
    pack_sub_check   VARCHAR2(1) := 'U';
    pack_loc_check   VARCHAR2(1) := 'U';
    unpack_sub_check VARCHAR2(1) := 'U';
    unpack_loc_check VARCHAR2(1) := 'U';
    oth_val          VARCHAR2(1) := 'U';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    BEGIN
      SELECT 'Y'
        INTO oth_val
        FROM DUAL
       WHERE EXISTS( SELECT wlpn.license_plate_number
                       FROM wms_license_plate_numbers wlpn
                      WHERE (wlpn.organization_id = p_org_id
                             AND wlpn.lpn_context = 5
                             AND license_plate_number = p_lpn
                            )
                         OR (wlpn.organization_id = p_org_id
                             AND (wlpn.lpn_context = 1
                                  OR wlpn.lpn_context = 11
                                 )
                             AND NVL(subinventory_code, '@') = NVL(p_sub, NVL(subinventory_code, '@'))
                             AND NVL(locator_id, '0') = NVL(TO_NUMBER(p_loc_id), NVL(locator_id, '0'))
                             AND NOT lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
                             AND NVL(parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id), NVL(parent_lpn_id, 0))
                             AND license_plate_number = p_lpn
                            ));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return  := 'N';
        RETURN x_return;
    END;

    IF oth_val <> 'Y' THEN
      x_return  := 'N';
      RETURN x_return;
    END IF;

    IF p_txn_type_id IN (500, 502) THEN
      pack_sub_check  := inv_material_status_grp.is_status_applicable('TRUE', NULL, 500, NULL, NULL, p_org_id, NULL, p_sub, p_loc_id, NULL, NULL, 'Z');
      pack_loc_check  := inv_material_status_grp.is_status_applicable('TRUE', NULL, 500, NULL, NULL, p_org_id, NULL, p_sub, p_loc_id, NULL, NULL, 'L');

      IF pack_sub_check = 'N'
         OR pack_loc_check = 'N' THEN
        x_return  := 'N';
        RETURN x_return;
      END IF;
    ELSIF p_txn_type_id IN (501, 502) THEN
      unpack_sub_check  := inv_material_status_grp.is_status_applicable('TRUE', NULL, 501, NULL, NULL, p_org_id, NULL, p_sub, p_loc_id, NULL, NULL, 'Z');
      unpack_loc_check  := inv_material_status_grp.is_status_applicable('TRUE', NULL, 501, NULL, NULL, p_org_id, NULL, p_sub, p_loc_id, NULL, NULL, 'L');

      IF unpack_sub_check = 'N'
         OR unpack_loc_check = 'N' THEN
        x_return  := 'N';
        RETURN x_return;
      END IF;
    END IF;

    x_return  := 'Y';
    RETURN x_return;
  END validate_sub_loc_status;

  FUNCTION vaildate_lpn_status(p_lpn_id IN NUMBER, p_orgid IN NUMBER, p_to_org_id IN NUMBER, p_wms_installed IN VARCHAR2, p_transaction_type_id IN NUMBER)
    RETURN VARCHAR2 IS
    x_return VARCHAR2(1);

    TYPE l_rec IS RECORD(
      serial_number                 VARCHAR2(30)
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    , lot_number                    VARCHAR2(80)
    , inventory_item_id             NUMBER
    , subinventory_code             VARCHAR2(10)
    , locator_id                    NUMBER);

    l_record l_rec;

    CURSOR l_cursor IS
      SELECT DISTINCT wlc.serial_number
                    , wlc.lot_number
                    , wlc.inventory_item_id
                    , wlpn.subinventory_code
                    , wlpn.locator_id
                 FROM wms_lpn_contents wlc, wms_license_plate_numbers wlpn
                WHERE wlc.organization_id = p_orgid
                  AND wlc.parent_lpn_id = wlpn.lpn_id
                  AND wlc.organization_id = wlpn.organization_id
                  AND wlc.parent_lpn_id IN (SELECT lpn_id
                                              FROM wms_license_plate_numbers
                                             WHERE outermost_lpn_id = p_lpn_id)
                  AND wlc.inventory_item_id IS NOT NULL
      UNION
      SELECT DISTINCT serial_number
                    , lot_number
                    , inventory_item_id
                    , current_subinventory_code
                    , current_locator_id
                 FROM mtl_serial_numbers
                WHERE current_organization_id = p_orgid
                  AND lpn_id IN (SELECT lpn_id
                                   FROM wms_license_plate_numbers
                                  WHERE outermost_lpn_id = p_lpn_id);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    OPEN l_cursor;

    LOOP
      FETCH l_cursor INTO l_record;
      EXIT WHEN l_cursor%NOTFOUND;

      IF inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_orgid, l_record.inventory_item_id, l_record.subinventory_code, l_record.locator_id, l_record.lot_number, l_record.serial_number, 'A') =
                                                                                                                                                                                                                                                      'Y' THEN
        x_return  := 'Y';
      ELSE
        x_return  := 'N';
        RETURN x_return;
      END IF;
    END LOOP;

    x_return  := 'Y';
    CLOSE l_cursor;
    RETURN x_return;
  END vaildate_lpn_status;

  --      Name: GET_CGUPDATE_SUBS
  --
  --      Input parameters:
  --       p_subinventory_code     - restricts the subinventory to those like
  --                                 the user inputted text if given
  --       p_organization_id       - restricts LOV SQL to current org
  --       p_inventory_item_id     - restricts the subs to only those having
  --                                 this item.
  --       p_revision
  --
  --      Output parameters:
  --       x_cgupdate_sub_lov       - Returns LOV rows as reference cursor
  --
  --      Functions: This API returns the valid subs associated with
  --                 the Cost Group Update
  --
  -- Obsolete
  PROCEDURE get_cgupdate_subs(
            x_cgupdate_sub_lov  OUT NOCOPY t_genref
          , p_subinventory_code IN VARCHAR2
          , p_organization_id   IN NUMBER
          , p_inventory_item_id IN NUMBER
          , p_revision          IN VARCHAR2
          ) IS
     l_debug NUMBER;
  BEGIN
     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    -- Include only those subinventories which are in the current org
    -- and include material with the item number entered
    OPEN x_cgupdate_sub_lov FOR
      SELECT DISTINCT moq.subinventory_code
                    , '0'
                    , msi.description
                    , '0'
                    , msi.lpn_controlled_flag
                    , msi.enable_locator_alias
                 FROM mtl_secondary_inventories msi, MTL_ONHAND_QUANTITIES_DETAIL moq
                WHERE msi.secondary_inventory_name = moq.subinventory_code
                  AND msi.organization_id = moq.organization_id
                  AND inv_material_status_grp.is_status_applicable('TRUE', NULL, 86, NULL, NULL, p_organization_id, p_inventory_item_id, moq.subinventory_code, NULL, NULL, NULL, 'Z') = 'Y'
                  AND moq.containerized_flag = 2
                  AND moq.subinventory_code LIKE (p_subinventory_code)
                  AND (moq.revision = p_revision
                       OR (moq.revision IS NULL
                           AND p_revision IS NULL
                          )
                      )
                  AND moq.inventory_item_id = p_inventory_item_id
                  AND moq.organization_id = p_organization_id
             ORDER BY moq.subinventory_code;
  END get_cgupdate_subs;

  --      Name: GET_CGUPDATE_LOCS
  --
  --      Input parameters:
  --       p_organization_id       - restricts LOV SQL to current org
  --       p_subinventory_code     - restricts LOV to the current subinventory
  --       p_concatenated_segments - restricts the locator to those that are
  --                                 similar to the user inputted text.
  --                                 locators are a key flex field so this
  --                                 is how the user represents/identifies locators
  --       p_inventory_item_id     -
  --       p_revision
  --
  --
  --      Output parameters:
  --       x_locators       - Returns LOV rows as reference cursor
  --
  --      Functions: This API returns the valid locators associated with a
  --                 cycle count
  --
  /* PJM-WMS Integration:Return only the the physical locators.
   *  Use the table mtl_item_locations instead of mtl_item_locations_kfv.
   *  Use the function  INV_PROJECT.get_locsegs() to retrieve the
   *  concatenated segments.
   */
  PROCEDURE get_cgupdate_locs(x_locators OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2, p_concatenated_segments IN VARCHAR2, p_inventory_item_id IN NUMBER, p_revision IN VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    OPEN x_locators FOR
      SELECT   moq.locator_id
             --, mil.concatenated_segments--Bug4398337:Commented this line and added below line
             , mil.locator_segments concatenated_segments
             , mil.description
          FROM wms_item_locations_kfv mil, MTL_ONHAND_QUANTITIES_DETAIL moq
         WHERE mil.concatenated_segments LIKE (p_concatenated_segments)
           AND mil.inventory_location_id = moq.locator_id
           AND mil.organization_id = p_organization_id
           -- Bug 2325664 AND mil.physical_location_id is null -- PJM-WMS Integration
           AND mil.project_id IS NULL
           AND mil.task_id IS NULL
           AND inv_material_status_grp.is_status_applicable('TRUE', NULL, 86, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, moq.locator_id, NULL, NULL, 'L') = 'Y'
           AND moq.containerized_flag = 2
           AND (moq.revision = p_revision
                OR (moq.revision IS NULL
                    AND p_revision IS NULL
                   )
               )
           AND moq.inventory_item_id = p_inventory_item_id
           AND moq.locator_id IS NOT NULL
           AND moq.subinventory_code = p_subinventory_code
           AND moq.organization_id = p_organization_id
      GROUP BY moq.locator_id, mil.concatenated_segments, mil.description
      ORDER BY 2;
  END get_cgupdate_locs;

  PROCEDURE get_cgupdate_locs(
            x_locators OUT NOCOPY t_genref,
            p_organization_id IN NUMBER,
            p_subinventory_code IN VARCHAR2,
            p_concatenated_segments IN VARCHAR2,
            p_inventory_item_id IN NUMBER,
            p_revision IN VARCHAR2,
            p_alias IN VARCHAR2
            ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
      IF p_alias IS NULL THEN
         get_cgupdate_locs(
             x_locators => x_locators
            ,p_organization_id => p_organization_id
            ,p_subinventory_code => p_subinventory_code
            ,p_concatenated_segments => p_concatenated_segments
            ,p_inventory_item_id => p_inventory_item_id
            ,p_revision => p_revision
         );
         RETURN;
      END IF;
    OPEN x_locators FOR
      SELECT   moq.locator_id
             --, mil.concatenated_segments--Bug4398337:Commented this line and added below line
             , mil.locator_segments concatenated_segments
             , mil.description
          FROM wms_item_locations_kfv mil, MTL_ONHAND_QUANTITIES_DETAIL moq
         WHERE alias = p_alias
           AND mil.inventory_location_id = moq.locator_id
           AND mil.organization_id = p_organization_id
           -- Bug 2325664 AND mil.physical_location_id is null -- PJM-WMS Integration
           AND mil.project_id IS NULL
           AND mil.task_id IS NULL
           AND inv_material_status_grp.is_status_applicable('TRUE', NULL, 86, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, moq.locator_id, NULL, NULL, 'L') = 'Y'
           AND moq.containerized_flag = 2
           AND (moq.revision = p_revision
                OR (moq.revision IS NULL
                    AND p_revision IS NULL
                   )
               )
           AND moq.inventory_item_id = p_inventory_item_id
           AND moq.locator_id IS NOT NULL
           AND moq.subinventory_code = p_subinventory_code
           AND moq.organization_id = p_organization_id
      GROUP BY moq.locator_id, mil.concatenated_segments, mil.description
      ORDER BY 2;
  END get_cgupdate_locs;

  -- Obsolete
  PROCEDURE get_with_all_subs(
            x_zones OUT NOCOPY t_genref
          , p_organization_id IN NUMBER
          , p_subinventory_code IN VARCHAR2
          ) IS
     l_debug NUMBER;
  BEGIN
     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     --bug#3440453 Remove the NVL on organization_id if user passes it.
     IF p_organization_id IS NULL THEN
       OPEN x_zones FOR
         SELECT   secondary_inventory_name
                , NVL(locator_type, 1)
                , description
                , asset_inventory
                , 0 dummy
                , enable_locator_alias
             FROM mtl_secondary_inventories
            WHERE organization_id = NVL(p_organization_id, organization_id)
              AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
              AND secondary_inventory_name LIKE (p_subinventory_code)
         UNION ALL
         SELECT   'All Subinventories'
                , 0
                , ''
                , 0
                , 1 dummy
                , 'N' enable_locator_alias
             FROM DUAL
            WHERE 'All Subinventories' LIKE (p_subinventory_code)
         ORDER BY dummy DESC, secondary_inventory_name;
     ELSE  -- Organization_id is not null
       OPEN x_zones FOR
         SELECT   secondary_inventory_name
                , NVL(locator_type, 1)
                , description
                , asset_inventory
                , 0 dummy
                , enable_locator_alias
             FROM mtl_secondary_inventories
            WHERE organization_id = p_organization_id
              AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
              AND secondary_inventory_name LIKE (p_subinventory_code)
         UNION ALL
         SELECT   'All Subinventories'
                , 0
                , ''
                , 0
                , 1 dummy
                , 'N' enable_locator_alias
             FROM DUAL
            WHERE 'All Subinventories' LIKE (p_subinventory_code)
         ORDER BY dummy DESC, secondary_inventory_name;
     END IF;

  END get_with_all_subs;

  PROCEDURE get_with_all_loc(x_locators OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2, p_concatenated_segments IN VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    OPEN x_locators FOR
      SELECT   milv.inventory_location_id
             --, milv.concatenated_segments --Bug4398337:Commented this line and added below line
             , milv.locator_segments concatenated_segments
             , milv.description
             , 0 dummy
             , mmsv.status_code
          FROM wms_item_locations_kfv milv, mtl_material_statuses_tl mmsv
         WHERE milv.organization_id = p_organization_id
           AND milv.subinventory_code = p_subinventory_code
           AND milv.concatenated_segments LIKE (p_concatenated_segments)
           AND (mmsv.status_id(+)/*Added outer join 2918529*/ = milv.status_id )
           AND mmsv.language(+) = userenv('LANG')
      UNION ALL
      SELECT   0
             , 'All Locators'
             , ''
             , 1 dummy
             , ''
          FROM DUAL
         WHERE 'All Locators' LIKE (p_concatenated_segments)
      ORDER BY dummy DESC, concatenated_segments;
  END get_with_all_loc;

  /* Start of fix for bug # 5166308 */
  /* The following overloaded procedure has been added as a part of Locator Alias Project. */

  PROCEDURE get_with_all_loc(x_locators              OUT   NOCOPY t_genref
                           , p_organization_id       IN    NUMBER
                           , p_subinventory_code     IN    VARCHAR2
                           , p_concatenated_segments IN    VARCHAR2
                           , p_alias                 IN    VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF (l_debug = 1) THEN
      DEBUG('Alias is '||p_alias);
    END IF;
    IF p_alias IS NULL THEN
      get_with_all_loc(x_locators               =>   x_locators
                     , p_organization_id        =>   p_organization_id
                     , p_subinventory_code      =>   p_subinventory_code
                     , p_concatenated_segments  =>   p_concatenated_segments);
      RETURN;
    END IF;
    OPEN x_locators FOR
      SELECT   milv.inventory_location_id
             --, milv.concatenated_segments --Bug4398337:Commented this line and added below line
             , milv.locator_segments concatenated_segments
             , milv.description
             , 0 dummy
             , mmsv.status_code
          FROM wms_item_locations_kfv milv, mtl_material_statuses_tl mmsv
         WHERE milv.organization_id = p_organization_id
           AND milv.subinventory_code = p_subinventory_code
           AND milv.alias = p_alias
           AND (mmsv.status_id(+)/*Added outer join 2918529*/ = milv.status_id )
           AND mmsv.language(+) = userenv('LANG');
  END get_with_all_loc;
  /* End of fix for bug # 5166308 */

  PROCEDURE update_dynamic_locator(
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_result OUT NOCOPY VARCHAR2,
    x_exist_or_create OUT NOCOPY VARCHAR2,
    p_locator_id IN NUMBER,
    p_org_id IN NUMBER,
    p_sub_code IN VARCHAR2) IS

    PRAGMA AUTONOMOUS_TRANSACTION;
    l_sub_default_status NUMBER;
    l_sub_code           VARCHAR2(10);
    l_wms_org            BOOLEAN;
    l_loc_type           NUMBER;
    l_return_status      VARCHAR2(10);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(20);
    l_label_status       VARCHAR2(20);
    l_status_rec         inv_material_status_pub.mtl_status_update_rec_type;
    l_required           VARCHAR2(1)                                        := 'N';
    l_project_id         NUMBER;
    l_task_id            NUMBER;
    l_picking_order      NUMBER;
    l_return_value       BOOLEAN                                            := FALSE;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    x_result           := fnd_api.g_ret_sts_success;

    --
    -- The LocatorKFF does an autonomous commit
    -- so a record is always present in MIL
    -- However a new Locator has a null subinventory
    -- code
    --

    SELECT subinventory_code
         , project_id
         , task_id
      INTO l_sub_code
         , l_project_id
         , l_task_id
      FROM mtl_item_locations
     WHERE inventory_location_id = p_locator_id
       AND organization_id = p_org_id;

    --
    -- If the Locator already exists then we dont
    -- need to do anything. Return immediatly
    --

    IF l_sub_code IS NOT NULL THEN
      x_exist_or_create  := 'EXISTS';
      GOTO success;
    END IF;

    --
    -- For a New Locator ...
    -- Set X_EXIST_OR_CREATE is set to 'CREATE' and
    --
    -- If WMS is installed then the Locator must be
    -- assigned the Default Locator Status defined
    -- for the Subinventory and the Locator type is
    -- set to 'STORAGE_LOCATOR'
    -- i.e. MTL_LOCATOR_TYPES (MFG_LOOKUP)
    --
    -- Also a record must be inserted into Status
    -- history.
    --

    x_exist_or_create  := 'CREATE';
    update_locator(p_sub_code, p_org_id, p_locator_id);
    IF (l_debug = 1) THEN
       DEBUG('After inserting the default values');
    END IF;
      --
    -- Now that we have a complete valid row in MTL_ITEM_LOCATIONS
    -- we call the PJM Locator API to create the physical locator.
    -- This happens only if the physical locator does not already
    -- exist.
    --
    l_return_value     := inv_projectlocator_pub.get_physical_location(p_organization_id => p_org_id, p_locator_id => p_locator_id);

    IF NOT l_return_value THEN
      IF (l_debug = 1) THEN
         DEBUG('GET_PHYSICAL_LOCATION: ERROR');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    -- Print the Label for the new Locator
    --
    IF (l_debug = 1) THEN
       DEBUG('CALLING PRINTING');
    END IF;
    inv_label.print_label_manual_wrap(
      x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , x_label_status               => l_label_status
    , p_business_flow_code         => 24
    , p_organization_id            => p_org_id
    , p_subinventory_code          => p_sub_code
    , p_locator_id                 => p_locator_id
    );
    IF (l_debug = 1) THEN
       DEBUG('AFTER CALLING PRINTING');
    END IF;

    --
    -- Do not check the returns status of above API as the
    -- transaction should go through even though label
    -- printing failed.
    --

    <<success>>
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    x_result           := fnd_api.g_ret_sts_success;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         DEBUG(SQLERRM);
      END IF;
      x_result  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK;
  END update_dynamic_locator;

  -- Obsolete
  PROCEDURE get_valid_lpn_controlled_subs(
            x_zones             OUT NOCOPY t_genref
          , p_organization_id   IN  NUMBER
          , p_subinventory_code IN  VARCHAR2
          , p_txn_type_id       IN  NUMBER
          , p_wms_installed     IN  VARCHAR2
          ) IS
     l_debug NUMBER;
  BEGIN
     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     --bug#3440453 Remove the NVL on organization_id if user passes a value to it.
     IF p_organization_id IS NULL THEN
          OPEN x_zones FOR
            SELECT   secondary_inventory_name
                   , NVL(locator_type, 1)
                   , description
                   , asset_inventory
                   , lpn_controlled_flag
                   , enable_locator_alias
                FROM mtl_secondary_inventories
               WHERE organization_id = NVL(p_organization_id, organization_id)
                 AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                 AND secondary_inventory_name LIKE (p_subinventory_code)
                 AND lpn_controlled_flag = 1
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, NULL, NULL, p_organization_id, NULL, secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y'
            ORDER BY secondary_inventory_name;
     ELSE  -- Organization_id is not null
        OPEN x_zones FOR
          SELECT   secondary_inventory_name
                 , NVL(locator_type, 1)
                 , description
                 , asset_inventory
                 , lpn_controlled_flag
                 , enable_locator_alias
              FROM mtl_secondary_inventories
             WHERE organization_id = p_organization_id
               AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND secondary_inventory_name LIKE (p_subinventory_code)
               AND lpn_controlled_flag = 1
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, NULL, NULL, p_organization_id, NULL, secondary_inventory_name, NULL, NULL, NULL, 'Z') = 'Y'
          ORDER BY secondary_inventory_name;
     END IF;

  END get_valid_lpn_controlled_subs;

  ------------------------------------------------
  -- GET_PRJ_LOC_LOV - Get Locators filtered
  -- on project and task
  ------------------------------------------------
  PROCEDURE get_prj_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  ) IS
    x_return_status VARCHAR2(100);
    x_display       VARCHAR2(100);
    x_project_col   NUMBER;
    x_task_col      NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_ispjm_org VARCHAR2(1);
    l_sub_type      NUMBER;
BEGIN

   BEGIN
    SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
    INTO l_ispjm_org
    FROM pjm_org_parameters
       WHERE organization_id=p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
   END;

      BEGIN
      SELECT Nvl(subinventory_type,1)
   INTO l_sub_type
   FROM mtl_secondary_inventories
       WHERE secondary_inventory_name = p_subinventory_code
   AND  organization_id = p_organization_id;
   EXCEPTION
      WHEN OTHERS THEN
    l_sub_type := 1;
      END;

IF l_ispjm_org='N' THEN /*Non PJM Org*/
   IF p_Restrict_Locators_Code = 1 AND l_sub_type = 1 THEN --Locators restricted to predefined list
        OPEN x_Locators FOR
          select a.inventory_location_id,
                 --a.concatenated_segments,--Bug4398337:Commented this line and added below line
                 a.locator_segments concatenated_segments,
                 nvl( a.description, -1)
          FROM wms_item_locations_kfv a,mtl_secondary_locators b
          WHERE b.organization_id = p_Organization_Id
          AND  b.inventory_item_id = p_Inventory_Item_Id
          AND nvl(a.disable_date, trunc(sysdate+1)) > trunc(sysdate)
          AND  b.subinventory_code = p_Subinventory_Code
          AND a.inventory_location_id = b.secondary_locator
          AND a.concatenated_segments LIKE (p_concatenated_segments)
       /* BUG#2810405: To show only common locators in the LOV */
          AND inv_material_status_grp.is_status_applicable
             ( p_wms_installed,
               NULL,
               p_transaction_type_id,
               NULL,
               NULL,
               p_Organization_Id,
               p_Inventory_Item_Id,
               p_Subinventory_Code,
               a.inventory_location_id,
               NULL,
               NULL,
               'L') = 'Y'
           ORDER BY 2;

       ELSE --Locators not restricted
        OPEN x_Locators FOR
          select inventory_location_id,
                 --concatenated_segments,--Bug4398337:Commented this line and added below line
                 locator_segments concatenated_segments,
                 description
          FROM wms_item_locations_kfv
          WHERE organization_id = p_Organization_Id
          AND subinventory_code = p_Subinventory_Code
          AND nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate)
          AND concatenated_segments LIKE (p_concatenated_segments )
       /* BUG#2810405: To show only common locators in the LOV */
          AND inv_material_status_grp.is_status_applicable
             ( p_wms_installed,
               NULL,
               p_transaction_type_id,
               NULL,
               NULL,
               p_Organization_Id,
               p_Inventory_Item_Id,
               p_Subinventory_Code,
               inventory_location_id,
               NULL,
               NULL,
               'L') = 'Y'
         ORDER BY 2;
       END IF;
  ELSE /*PJM org*/
    IF p_Restrict_Locators_Code = 1 AND l_sub_type = 1 THEN --Locators restricted to predefined list
       OPEN x_Locators FOR
        select a.inventory_location_id,
              --a.concatenated_segments,--Bug4398337:Commented this line and added below line
              a.locator_segments concatenated_segments,
              nvl( a.description, -1)
        FROM wms_item_locations_kfv a,mtl_secondary_locators b
        WHERE b.organization_id = p_Organization_Id
        AND  b.inventory_item_id = p_Inventory_Item_Id
        AND nvl(a.disable_date, trunc(sysdate+1)) > trunc(sysdate)
        AND  b.subinventory_code = p_Subinventory_Code
        AND a.inventory_location_id = b.secondary_locator
        AND a.inventory_location_id=nvl(a.physical_location_id,a.inventory_location_id)
        AND a.concatenated_segments like (p_concatenated_segments )
   /* BUG#2810405: To show only common locators in the LOV */
        AND inv_material_status_grp.is_status_applicable
           ( p_wms_installed,
             NULL,
             p_transaction_type_id,
             NULL,
             NULL,
             p_Organization_Id,
             p_Inventory_Item_Id,
             p_Subinventory_Code,
             a.inventory_location_id,
             NULL,
             NULL,
             'L') = 'Y'
      ORDER BY 2;

     ELSE --Locators not restricted
       OPEN x_Locators FOR
         select inventory_location_id,
               --concatenated_segments,--Bug4398337:Commented this line and added below line
               locator_segments concatenated_segments,
               description
         FROM wms_item_locations_kfv
         WHERE organization_id = p_Organization_Id
         AND subinventory_code = p_Subinventory_Code
         AND nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate)
         AND inventory_location_id=NVL(physical_location_id,inventory_location_id)
         AND concatenated_segments LIKE (p_concatenated_segments )
   /* BUG#2810405: To show only common locators in the LOV */
        AND inv_material_status_grp.is_status_applicable
           ( p_wms_installed,
             NULL,
             p_transaction_type_id,
             NULL,
             NULL,
             p_Organization_Id,
             p_Inventory_Item_Id,
             p_Subinventory_Code,
             inventory_location_id,
             NULL,
             NULL,
             'L') = 'Y'
       ORDER BY 2;
     END IF;
    END IF;
END get_prj_loc_lov;
  /**
    * For Locator alias project
    */
  PROCEDURE get_prj_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  , p_alias                  IN     VARCHAR2
  ) IS
    x_return_status VARCHAR2(100);
    x_display       VARCHAR2(100);
    x_project_col   NUMBER;
    x_task_col      NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_ispjm_org VARCHAR2(1);
    l_sub_type      NUMBER;
BEGIN

    IF (l_debug = 1) THEN
      DEBUG('Alias is '||p_alias);
    END IF;
   IF p_alias IS NULL THEN
      get_prj_loc_lov(
      x_locators               => x_locators
    , p_organization_id        => p_organization_id
    , p_subinventory_code      => p_subinventory_code
    , p_restrict_locators_code => p_restrict_locators_code
    , p_inventory_item_id      => p_inventory_item_id
    , p_concatenated_segments  => p_concatenated_segments
    , p_transaction_type_id    => p_transaction_type_id
    , p_wms_installed          => p_wms_installed
    , p_project_id             => p_project_id
    , p_task_id                => p_task_id
    );
     RETURN;
   END IF;

   BEGIN
    SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
    INTO l_ispjm_org
    FROM pjm_org_parameters
       WHERE organization_id=p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
   END;

      BEGIN
      SELECT Nvl(subinventory_type,1)
   INTO l_sub_type
   FROM mtl_secondary_inventories
       WHERE secondary_inventory_name = p_subinventory_code
   AND  organization_id = p_organization_id;
   EXCEPTION
      WHEN OTHERS THEN
    l_sub_type := 1;
      END;

IF l_ispjm_org='N' THEN /*Non PJM Org*/
   IF p_Restrict_Locators_Code = 1 AND l_sub_type = 1 THEN --Locators restricted to predefined list
        OPEN x_Locators FOR
          select a.inventory_location_id,
                 --a.concatenated_segments,--Bug4398337:Commented this line and added below line
                 a.locator_segments concatenated_segments,
                 nvl( a.description, -1)
          FROM wms_item_locations_kfv a,mtl_secondary_locators b
          WHERE b.organization_id = p_Organization_Id
          AND  b.inventory_item_id = p_Inventory_Item_Id
          AND nvl(a.disable_date, trunc(sysdate+1)) > trunc(sysdate)
          AND  b.subinventory_code = p_Subinventory_Code
          AND a.inventory_location_id = b.secondary_locator
          -- AND a.concatenated_segments LIKE (p_concatenated_segments)
          AND a.alias = p_alias
       /* BUG#2810405: To show only common locators in the LOV */
          AND inv_material_status_grp.is_status_applicable
             ( p_wms_installed,
               NULL,
               p_transaction_type_id,
               NULL,
               NULL,
               p_Organization_Id,
               p_Inventory_Item_Id,
               p_Subinventory_Code,
               a.inventory_location_id,
               NULL,
               NULL,
               'L') = 'Y'
           ORDER BY 2;

       ELSE --Locators not restricted
        OPEN x_Locators FOR
          select inventory_location_id,
                 --concatenated_segments,--Bug4398337:Commented this line and added below line
                 locator_segments concatenated_segments,
                 description
          FROM wms_item_locations_kfv
          WHERE organization_id = p_Organization_Id
          AND subinventory_code = p_Subinventory_Code
          AND nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate)
          -- AND concatenated_segments LIKE (p_concatenated_segments )
          AND alias = p_alias
       /* BUG#2810405: To show only common locators in the LOV */
          AND inv_material_status_grp.is_status_applicable
             ( p_wms_installed,
               NULL,
               p_transaction_type_id,
               NULL,
               NULL,
               p_Organization_Id,
               p_Inventory_Item_Id,
               p_Subinventory_Code,
               inventory_location_id,
               NULL,
               NULL,
               'L') = 'Y'
         ORDER BY 2;
       END IF;
  ELSE /*PJM org*/
    IF p_Restrict_Locators_Code = 1 AND l_sub_type = 1 THEN --Locators restricted to predefined list
       OPEN x_Locators FOR
        select a.inventory_location_id,
              --a.concatenated_segments,--Bug4398337:Commented this line and added below line
              a.locator_segments concatenated_segments,
              nvl( a.description, -1)
        FROM wms_item_locations_kfv a,mtl_secondary_locators b
        WHERE b.organization_id = p_Organization_Id
        AND  b.inventory_item_id = p_Inventory_Item_Id
        AND nvl(a.disable_date, trunc(sysdate+1)) > trunc(sysdate)
        AND  b.subinventory_code = p_Subinventory_Code
        AND a.inventory_location_id = b.secondary_locator
        AND a.inventory_location_id=nvl(a.physical_location_id,a.inventory_location_id)
        -- AND a.concatenated_segments like (p_concatenated_segments )
        AND a.alias = p_alias
   /* BUG#2810405: To show only common locators in the LOV */
        AND inv_material_status_grp.is_status_applicable
           ( p_wms_installed,
             NULL,
             p_transaction_type_id,
             NULL,
             NULL,
             p_Organization_Id,
             p_Inventory_Item_Id,
             p_Subinventory_Code,
             a.inventory_location_id,
             NULL,
             NULL,
             'L') = 'Y'
      ORDER BY 2;

     ELSE --Locators not restricted
       OPEN x_Locators FOR
         select inventory_location_id,
               --concatenated_segments,--Bug4398337:Commented this line and added below line
               locator_segments concatenated_segments,
               description
         FROM wms_item_locations_kfv
         WHERE organization_id = p_Organization_Id
         AND subinventory_code = p_Subinventory_Code
         AND nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate)
         AND inventory_location_id=NVL(physical_location_id,inventory_location_id)
         -- AND concatenated_segments LIKE (p_concatenated_segments )
        AND alias = p_alias
   /* BUG#2810405: To show only common locators in the LOV */
        AND inv_material_status_grp.is_status_applicable
           ( p_wms_installed,
             NULL,
             p_transaction_type_id,
             NULL,
             NULL,
             p_Organization_Id,
             p_Inventory_Item_Id,
             p_Subinventory_Code,
             inventory_location_id,
             NULL,
             NULL,
             'L') = 'Y'
       ORDER BY 2;
     END IF;
    END IF;
END get_prj_loc_lov;

  PROCEDURE get_valid_prj_to_locs(
    x_locators               OUT    NOCOPY t_genref
  , p_transaction_action_id  IN     NUMBER
  , p_to_organization_id     IN     NUMBER
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  , p_alias                  IN     VARCHAR2
  ) IS
    l_org                    NUMBER;
    l_restrict_locators_code NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    debug('Inside INV_UI_ITEM_SUB_LOC_LOVS.get_valid_prj_to_locs');
    debug('p_alias : '|| p_alias);
    IF p_alias IS NULL THEN
       get_valid_prj_to_locs(
       x_locators               => x_locators
     , p_transaction_action_id  => p_transaction_action_id
     , p_to_organization_id     => p_to_organization_id
     , p_organization_id        => p_organization_id
     , p_subinventory_code      => p_subinventory_code
     , p_restrict_locators_code => p_restrict_locators_code
     , p_inventory_item_id      => p_inventory_item_id
     , p_concatenated_segments  => p_concatenated_segments
     , p_transaction_type_id    => p_transaction_type_id
     , p_wms_installed          => p_wms_installed
     , p_project_id             => p_project_id
     , p_task_id                => p_task_id
     );
     RETURN;    --Bug 8237335 Added return statement as for p_alias is null.
    END IF;
    debug('p_alias is not null case');
    IF p_transaction_action_id IN (3, 21) THEN
      l_org  := p_to_organization_id;

      SELECT restrict_locators_code
        INTO l_restrict_locators_code
        FROM mtl_system_items
       WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = l_org;
    ELSE
      l_org                     := p_organization_id;
      l_restrict_locators_code  := p_restrict_locators_code;
    END IF;

    get_prj_loc_lov(
      x_locators                   => x_locators
    , p_organization_id            => l_org
    , p_subinventory_code          => p_subinventory_code
    , p_restrict_locators_code     => l_restrict_locators_code
    , p_inventory_item_id          => p_inventory_item_id
    , p_concatenated_segments      => p_concatenated_segments
    , p_transaction_type_id        => p_transaction_type_id
    , p_wms_installed              => p_wms_installed
    , p_project_id                 => p_project_id
    , p_task_id                    => p_task_id
    , p_alias                      => p_alias
    );
  END get_valid_prj_to_locs;
  --
  --
  PROCEDURE get_valid_prj_to_locs(
    x_locators               OUT    NOCOPY t_genref
  , p_transaction_action_id  IN     NUMBER
  , p_to_organization_id     IN     NUMBER
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  ) IS
    l_org                    NUMBER;
    l_restrict_locators_code NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    debug('Inside INV_UI_ITEM_SUB_LOC_LOVS.get_valid_prj_to_locs :Overloaded');
    debug('p_transaction_action_id : '|| p_transaction_action_id);
    debug('p_to_organization_id : '|| p_to_organization_id);
    debug('p_organization_id : '|| p_organization_id);
    debug('p_subinventory_code : '|| p_subinventory_code);
    debug('p_restrict_locators_code : '|| p_restrict_locators_code);
    debug('p_inventory_item_id : '|| p_inventory_item_id);
    debug('p_concatenated_segments : '|| p_concatenated_segments);
    debug('p_transaction_type_id :' || p_transaction_type_id);
    debug('p_wms_installed : '|| p_wms_installed);
    debug('p_project_id : '|| p_project_id);
    debug('p_task_id : '|| p_task_id);

    IF p_transaction_action_id IN (3, 21) THEN
      l_org  := p_to_organization_id;

      SELECT restrict_locators_code
        INTO l_restrict_locators_code
        FROM mtl_system_items
       WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = l_org;
    ELSE
      l_org                     := p_organization_id;
      l_restrict_locators_code  := p_restrict_locators_code;
    END IF;
    debug('l_restrict_locators_code : '|| l_restrict_locators_code);

     --Commented following call and instead called new procedure get_prj_to_loc_lov for bug 8237335
    /*get_prj_loc_lov(
      x_locators                   => x_locators
    , p_organization_id            => l_org
    , p_subinventory_code          => p_subinventory_code
    , p_restrict_locators_code     => l_restrict_locators_code
    , p_inventory_item_id          => p_inventory_item_id
    , p_concatenated_segments      => p_concatenated_segments
    , p_transaction_type_id        => p_transaction_type_id
    , p_wms_installed              => p_wms_installed
    , p_project_id                 => p_project_id
    , p_task_id                    => p_task_id
    ); */

    debug('Calling get_prj_to_loc_lov ');
     get_prj_to_loc_lov(
      x_locators                   => x_locators
    , p_organization_id            => l_org
    , p_subinventory_code          => p_subinventory_code
    , p_restrict_locators_code     => l_restrict_locators_code
    , p_inventory_item_id          => p_inventory_item_id
    , p_concatenated_segments      => p_concatenated_segments
    , p_transaction_type_id        => p_transaction_type_id
    , p_wms_installed              => p_wms_installed
    , p_project_id                 => p_project_id
    , p_task_id                    => p_task_id
    );
  END get_valid_prj_to_locs;

  --
  --
  PROCEDURE get_prj_lpnloc_lov(
    x_locators              OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_lpn_id                IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_concatenated_segments IN     VARCHAR2
  , p_transaction_type_id   IN     NUMBER
  , p_wms_installed         IN     VARCHAR2
  , p_project_id            IN     NUMBER
  , p_task_id               IN     NUMBER
  ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     /*Bug 2769628: Restricted the LOV to list only common locators and anot logical locators*/
    OPEN x_locators FOR
      SELECT inventory_location_id
           --, concatenated_segments--Bug4398337:Commented this line and added below line
           , locator_segments concatenated_segments
           , description
        FROM wms_item_locations_kfv
       WHERE organization_id = p_organization_id
         AND subinventory_code = p_subinventory_code
         AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
         AND concatenated_segments LIKE (p_concatenated_segments)
         AND inventory_location_id=nvl(physical_location_id,inventory_location_id)
         AND inv_ui_item_sub_loc_lovs.vaildate_lpn_toloc(p_lpn_id, p_subinventory_code, p_organization_id, inventory_location_id, p_wms_installed, p_transaction_type_id) = 'Y';
  END get_prj_lpnloc_lov;
  PROCEDURE get_prj_lpnloc_lov(
    x_locators              OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_lpn_id                IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_concatenated_segments IN     VARCHAR2
  , p_transaction_type_id   IN     NUMBER
  , p_wms_installed         IN     VARCHAR2
  , p_project_id            IN     NUMBER
  , p_task_id               IN     NUMBER
  , p_alias                 IN     VARCHAR2
  ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN

     IF p_alias IS NULL THEN
        get_prj_lpnloc_lov(
        x_locators              => x_locators
      , p_organization_id       => p_organization_id
      , p_lpn_id                => p_lpn_id
      , p_subinventory_code     => p_subinventory_code
      , p_concatenated_segments => p_concatenated_segments
      , p_transaction_type_id   => p_transaction_type_id
      , p_wms_installed         => p_wms_installed
      , p_project_id            => p_project_id
      , p_task_id               => p_task_id
        );
        RETURN;
     END IF;
     /*Bug 2769628: Restricted the LOV to list only common locators and anot logical locators*/
    OPEN x_locators FOR
      SELECT inventory_location_id
           --, concatenated_segments--Bug4398337:Commented this line and added below line
           , locator_segments concatenated_segments
           , description
        FROM wms_item_locations_kfv
       WHERE organization_id = p_organization_id
         AND subinventory_code = p_subinventory_code
         AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
         AND alias = p_alias
         AND inventory_location_id=nvl(physical_location_id,inventory_location_id)
         AND inv_ui_item_sub_loc_lovs.vaildate_lpn_toloc(p_lpn_id, p_subinventory_code, p_organization_id, inventory_location_id, p_wms_installed, p_transaction_type_id) = 'Y';
  END get_prj_lpnloc_lov;


  -- This procedure is used for user directed putaway
  -- to get the LOV cursor for the Subinventory
  --- obsolete
  PROCEDURE get_userput_subs(
            x_sub               OUT NOCOPY t_genref
          , p_organization_id   IN  NUMBER
          , p_subinventory_code IN  VARCHAR2
          , p_lpn_id            IN  NUMBER
          , p_lpn_context       IN  NUMBER
          , p_rcv_sub_only      IN  NUMBER
          ) IS
     l_debug NUMBER;
  BEGIN
     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    IF (l_debug = 1) THEN
      DEBUG('Entering get_userput_subs:');
      DEBUG('  p_rcv_sub_only ====> ' || p_rcv_sub_only);
    END IF;

     IF (p_lpn_context in (2,3)) THEN
   IF (p_rcv_sub_only = 2) THEN
      -- Include both RCV and INV subs, with no restriction on INV subs
      OPEN x_sub FOR
        SELECT secondary_inventory_name
        , NVL(locator_type, 1)
        , description
        , asset_inventory
        , lpn_controlled_flag
        , Nvl(subinventory_type,1)
        , reservable_type
        , enable_locator_alias
        FROM mtl_secondary_inventories
        WHERE organization_id = p_organization_id
        AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
        AND secondary_inventory_name LIKE (p_subinventory_code)
        AND inv_ui_item_sub_loc_lovs.validate_lpn_sub(p_organization_id,
                        secondary_inventory_name,
                        p_lpn_id) = 'Y'
        UNION ALL
        SELECT msub.secondary_inventory_name
        , NVL(msub.locator_type, 1)
        , msub.description
        , msub.asset_inventory
        , lpn_controlled_flag
        , Nvl(subinventory_type,1)
        , reservable_type
        , enable_locator_alias
        FROM mtl_secondary_inventories msub
        WHERE organization_id = p_organization_id
        AND Nvl(subinventory_type,1) = 2
        AND msub.secondary_inventory_name LIKE (p_subinventory_code)
        AND (trunc(disable_date + (300*365)) >= trunc(SYSDATE) OR
        disable_date = TO_DATE('01/01/1700','DD/MM/RRRR'))
        ORDER BY 1;
    ELSIF (p_rcv_sub_only = 1 OR p_rcv_sub_only IS NULL) THEN
      -- Only include RCV subs.
      OPEN x_sub FOR
        SELECT msub.secondary_inventory_name
        , NVL(msub.locator_type, 1)
        , msub.description
        , msub.asset_inventory
        , lpn_controlled_flag
        , Nvl(subinventory_type,1)
        , reservable_type
        , enable_locator_alias
        FROM mtl_secondary_inventories msub
        WHERE organization_id = p_organization_id
        AND Nvl(subinventory_type,1) = 2
        AND msub.secondary_inventory_name LIKE (p_subinventory_code)
        AND (trunc(disable_date + (300*365)) >= trunc(SYSDATE) OR
        disable_date = TO_DATE('01/01/1700','DD/MM/RRRR'))
        ORDER BY 1;
    ELSIF (p_rcv_sub_only = 3) THEN
        -- Only include inventory subs, with no restrictions
        OPEN x_sub FOR
          SELECT secondary_inventory_name
          , NVL(locator_type, 1)
          , description
          , asset_inventory
          , lpn_controlled_flag
        , Nvl(subinventory_type,1)
        , reservable_type
          , enable_locator_alias
          FROM mtl_secondary_inventories
          WHERE organization_id = p_organization_id
          AND Nvl(subinventory_type,1) = 1
          AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
          AND secondary_inventory_name LIKE (p_subinventory_code)
          AND inv_ui_item_sub_loc_lovs.validate_lpn_sub(p_organization_id,
                          secondary_inventory_name,
                          p_lpn_id) = 'Y';
    ELSIF (p_rcv_sub_only = 4) THEN
      -- SO XDOCK
      -- Only include inventory subs that are reservable and LPN controlled
      OPEN x_sub FOR
        SELECT secondary_inventory_name
        , NVL(locator_type, 1)
        , description
        , asset_inventory
        , lpn_controlled_flag
        , Nvl(subinventory_type,1)
        , reservable_type
        , enable_locator_alias
        FROM mtl_secondary_inventories
        WHERE organization_id = p_organization_id
        AND Nvl(subinventory_type,1) = 1
        AND lpn_controlled_flag = 1
        AND reservable_type = 1
        AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
        AND secondary_inventory_name LIKE (p_subinventory_code)
        AND inv_ui_item_sub_loc_lovs.validate_lpn_sub(p_organization_id,
                          secondary_inventory_name,
                        p_lpn_id) = 'Y';
    ELSIF (p_rcv_sub_only = 5) THEN
      -- Only include INV Subs that are non-reservable and non-LPN-Controlled
      OPEN x_sub FOR
        SELECT secondary_inventory_name
        , NVL(locator_type, 1)
        , description
        , asset_inventory
        , lpn_controlled_flag
        , Nvl(subinventory_type,1)
        , reservable_type
        , enable_locator_alias
        FROM mtl_secondary_inventories
        WHERE organization_id = p_organization_id
        AND Nvl(subinventory_type,1) = 1
        AND lpn_controlled_flag = 2
        AND reservable_type = 2
          AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
          AND secondary_inventory_name LIKE (p_subinventory_code)
          AND inv_ui_item_sub_loc_lovs.validate_lpn_sub(p_organization_id,
                          secondary_inventory_name,
                          p_lpn_id) = 'Y';

    ELSIF (p_rcv_sub_only = 6) THEN
      -- Include RCV Subs and INV subs that are reservable and LPN Controlled
        OPEN x_sub FOR
          SELECT secondary_inventory_name
          , NVL(locator_type, 1)
          , description
          , asset_inventory
          , lpn_controlled_flag
          , Nvl(subinventory_type,1)
          , reservable_type
          , enable_locator_alias
          FROM mtl_secondary_inventories
          WHERE organization_id = p_organization_id
          AND Nvl(subinventory_type,1) = 1
          AND lpn_controlled_flag = 1
          AND reservable_type = 1
          AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
          AND secondary_inventory_name LIKE (p_subinventory_code)
          AND inv_ui_item_sub_loc_lovs.validate_lpn_sub(p_organization_id,
                          secondary_inventory_name,
                          p_lpn_id) = 'Y'
          UNION ALL
          SELECT msub.secondary_inventory_name
          , NVL(msub.locator_type, 1)
          , msub.description
          , msub.asset_inventory
          , lpn_controlled_flag
          , Nvl(subinventory_type,1)
          , reservable_type
          , enable_locator_alias
          FROM mtl_secondary_inventories msub
          WHERE organization_id = p_organization_id
          AND Nvl(subinventory_type,1) = 2
          AND msub.secondary_inventory_name LIKE (p_subinventory_code)
          AND (trunc(disable_date + (300*365)) >= trunc(SYSDATE) OR
          disable_date = TO_DATE('01/01/1700','DD/MM/RRRR'))
          ORDER BY 1;
    ELSIF (p_rcv_sub_only = 7) THEN
      -- Include RCV Subs and INV subs that are non-reservable and non-LPN-Controlled
        OPEN x_sub FOR
          SELECT secondary_inventory_name
          , NVL(locator_type, 1)
          , description
          , asset_inventory
          , lpn_controlled_flag
          , Nvl(subinventory_type,1)
          , reservable_type
          , enable_locator_alias
          FROM mtl_secondary_inventories
          WHERE organization_id = p_organization_id
          AND Nvl(subinventory_type,1) = 1
          AND lpn_controlled_flag = 2
          AND reservable_type = 2
          AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
          AND secondary_inventory_name LIKE (p_subinventory_code)
          AND inv_ui_item_sub_loc_lovs.validate_lpn_sub(p_organization_id,
                          secondary_inventory_name,
                          p_lpn_id) = 'Y'
          UNION ALL
          SELECT msub.secondary_inventory_name
          , NVL(msub.locator_type, 1)
          , msub.description
          , msub.asset_inventory
          , lpn_controlled_flag
          , Nvl(subinventory_type,1)
          , reservable_type
          , enable_locator_alias
          FROM mtl_secondary_inventories msub
          WHERE organization_id = p_organization_id
          AND Nvl(subinventory_type,1) = 2
          AND msub.secondary_inventory_name LIKE (p_subinventory_code)
          AND (trunc(disable_date + (300*365)) >= trunc(SYSDATE) OR
          disable_date = TO_DATE('01/01/1700','DD/MM/RRRR'))
          ORDER BY 1;
   END IF;
     ELSE
   -- Non-receiving LPN case
        OPEN x_sub FOR
          SELECT secondary_inventory_name
               , NVL(locator_type, 1)
               , description
               , asset_inventory
               , lpn_controlled_flag
          , Nvl(subinventory_type,1)
          , reservable_type
          , enable_locator_alias
          FROM mtl_secondary_inventories
          WHERE organization_id = p_organization_id
          AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
          AND secondary_inventory_name LIKE (p_subinventory_code)
          AND inv_ui_item_sub_loc_lovs.validate_lpn_sub(p_organization_id,
                     secondary_inventory_name,
                     p_lpn_id) = 'Y'
     ORDER BY UPPER(secondary_inventory_name);
     END IF;

  END get_userput_subs;


  -- This function will validate the LPN for item/sub restrictions
  -- and also for sub material status for each move order line transaction.
  -- This function should only be called from the procedure
  -- get_userput_subs in this package: INV_UI_ITEM_SUB_LOC_LOVS
FUNCTION validate_lpn_sub(
  p_organization_id IN NUMBER
, p_subinventory_code IN VARCHAR2
, p_lpn_id IN NUMBER)
  RETURN VARCHAR2 IS
  x_return            VARCHAR(1);
  l_item_id           NUMBER;
  l_restrict_sub      NUMBER;
  l_transaction_type  NUMBER;
  l_count             NUMBER;

  CURSOR l_item_cursor IS
    SELECT DISTINCT wlc.inventory_item_id
                  , msi.restrict_subinventories_code
    FROM            wms_lpn_contents wlc, mtl_system_items msi
    WHERE           wlc.parent_lpn_id IN(SELECT lpn_id
                                         FROM   wms_license_plate_numbers
                                         WHERE  outermost_lpn_id = p_lpn_id)
    AND             wlc.inventory_item_id IS NOT NULL
    AND             wlc.inventory_item_id = msi.inventory_item_id
    AND             msi.organization_id = p_organization_id;

  CURSOR l_item_txn_cursor IS
    SELECT inventory_item_id
         , transaction_type_id
    FROM   mtl_txn_request_lines
    WHERE  organization_id = p_organization_id
    AND    lpn_id = p_lpn_id;

  l_debug             NUMBER     := nvl(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
  -- Initialize the return variable
  x_return := 'Y';
  -- Loop through each item packed within the LPN
  OPEN l_item_cursor;

  LOOP
    FETCH l_item_cursor INTO l_item_id, l_restrict_sub;
    EXIT WHEN l_item_cursor%NOTFOUND;

    -- If the item restricts subinventories,
    -- check that the sub is allowed
    IF (l_restrict_sub = 1) THEN
      SELECT COUNT(*)
      INTO   l_count
      FROM   mtl_item_sub_inventories
      WHERE  organization_id = p_organization_id
      AND    inventory_item_id = l_item_id
      AND    secondary_inventory = p_subinventory_code;

      -- No rows returned so the sub is not valid
      -- for the current item
      IF (l_count = 0) THEN
        x_return := 'N';
        EXIT;
      END IF;
    END IF;
  END LOOP;

  CLOSE l_item_cursor;

  -- Sub has already failed item/sub restrictions
  -- so no need to do any further validation.
  IF (x_return = 'N') THEN
    RETURN x_return;
  END IF;

  -- Loop through each move order line for the LPN
  OPEN l_item_txn_cursor;

  LOOP
    FETCH l_item_txn_cursor INTO l_item_id, l_transaction_type;
    EXIT WHEN l_item_txn_cursor%NOTFOUND;
    -- Check if the sub's material status is valid
    -- for the current move order line's transaction type
    x_return := inv_material_status_grp.is_status_applicable(p_wms_installed => 'TRUE', p_trx_status_enabled => NULL, p_trx_type_id => l_transaction_type
                                                           , p_lot_status_enabled => NULL, p_serial_status_enabled => NULL, p_organization_id => p_organization_id
                                                           , p_inventory_item_id => l_item_id, p_sub_code => p_subinventory_code, p_locator_id => NULL, p_lot_number => NULL
                                                           , p_serial_number => NULL, p_object_type => 'Z');

    -- The function returned 'N' so the sub is not valid
    -- for the transaction type in the current move order line
    IF (x_return = 'N') THEN
      EXIT;
    END IF;
  END LOOP;

  CLOSE l_item_txn_cursor;
  -- If all of the items in the LPN passed validation
  -- for the given sub, the return variable should be 'Y'
  RETURN x_return;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
      DEBUG('Exception occurred in function validate_lpn_sub!');
    END IF;

    x_return := 'N';
    RETURN x_return;
END validate_lpn_sub;

  PROCEDURE get_userput_locs
    (x_locators                OUT  NOCOPY t_genref  ,
     p_organization_id         IN   NUMBER    ,
     p_subinventory_code       IN   VARCHAR2  ,
     p_concatenated_segments   IN   VARCHAR2  ,
     p_project_id              IN   NUMBER    ,
     p_task_id                 IN   NUMBER    ,
     p_lpn_id                  IN   NUMBER   ,
     p_alias                   IN   VARCHAR2
     ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     /*Bug 2769628:To list all the common locators and not the logical locators*/
     IF p_alias IS NULL THEN
        get_userput_locs(
         x_locators                => x_locators
        ,p_organization_id         => p_organization_id
        ,p_subinventory_code       => p_subinventory_code
        ,p_concatenated_segments   => p_concatenated_segments
        ,p_project_id              => p_project_id
        ,p_task_id                 => p_task_id
        ,p_lpn_id                  => p_lpn_id
        );
        RETURN;
     END IF;
      OPEN x_locators FOR
        SELECT inventory_location_id
  -- , concatenated_segments--Bug4398337:Commented this line and added below line
   , locator_segments concatenated_segments
   , description
   , inventory_location_type
   FROM wms_item_locations_kfv
   WHERE organization_id = p_organization_id
   AND subinventory_code = p_subinventory_code
   AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
   AND alias = p_alias
   AND inventory_location_id=nvl(physical_location_id,inventory_location_id)
   AND inv_ui_item_sub_loc_lovs.validate_lpn_loc(p_organization_id,
                        p_subinventory_code,
                        inventory_location_id,
                        p_lpn_id) = 'Y'
        ORDER BY 2;
  END get_userput_locs;
  PROCEDURE get_userput_locs
    (x_locators                OUT  NOCOPY t_genref  ,
     p_organization_id         IN   NUMBER    ,
     p_subinventory_code       IN   VARCHAR2  ,
     p_concatenated_segments   IN   VARCHAR2  ,
     p_project_id              IN   NUMBER    ,
     p_task_id                 IN   NUMBER    ,
     p_lpn_id                  IN   NUMBER
     ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     /*Bug 2769628:To list all the common locators and not the logical locators*/
      OPEN x_locators FOR
        SELECT inventory_location_id
  -- , concatenated_segments--Bug4398337:Commented this line and added below line
   , locator_segments concatenated_segments
   , description
   , inventory_location_type
   FROM wms_item_locations_kfv
   WHERE organization_id = p_organization_id
   AND subinventory_code = p_subinventory_code
   AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
   AND concatenated_segments LIKE (p_concatenated_segments)
    AND inventory_location_id=nvl(physical_location_id,inventory_location_id)
   AND inv_ui_item_sub_loc_lovs.validate_lpn_loc(p_organization_id,
                        p_subinventory_code,
                        inventory_location_id,
                        p_lpn_id) = 'Y'
        ORDER BY 2;
  END get_userput_locs;

  -- This function will validate the LPN for item/sub/loc restrictions
  -- and also for locator material status for each move order line transaction.
  -- This function should only be called from the procedure
  -- get_userput_locs in this package: INV_UI_ITEM_SUB_LOC_LOVS
  FUNCTION validate_lpn_loc(p_organization_id    IN  NUMBER    ,
             p_subinventory_code  IN  VARCHAR2  ,
             p_locator_id         IN  NUMBER    ,
             p_lpn_id             IN  NUMBER)
    RETURN VARCHAR2 IS
       x_return            VARCHAR(1);
       l_item_id           NUMBER;
       l_restrict_loc      NUMBER;
       l_transaction_type  NUMBER;
       l_count             NUMBER;
       CURSOR l_item_cursor IS
     SELECT DISTINCT wlc.inventory_item_id, msi.restrict_locators_code
       FROM wms_lpn_contents wlc, mtl_system_items msi
       WHERE wlc.parent_lpn_id IN (SELECT lpn_id
               FROM wms_license_plate_numbers
               WHERE outermost_lpn_id = p_lpn_id)
       AND wlc.inventory_item_id IS NOT NULL
       AND wlc.inventory_item_id = msi.inventory_item_id
       AND msi.organization_id = p_organization_id;
       CURSOR l_item_txn_cursor IS
     SELECT inventory_item_id, transaction_type_id
       FROM mtl_txn_request_lines
       WHERE organization_id = p_organization_id
       AND lpn_id = p_lpn_id;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_sub_type NUMBER;
  BEGIN
     -- Initialize the return variable
     x_return := 'Y';

     -- get the sub type and based on it set the loc_type
     BEGIN
   SELECT nvl(subinventory_type,1)
     INTO l_sub_type
     FROM mtl_secondary_inventories
     WHERE organization_id = p_organization_id
     AND secondary_inventory_name = p_subinventory_code;
     EXCEPTION
   WHEN OTHERS THEN
      l_sub_type := 1;
     END;

     --Only if it is a storage sub then we need to do the
     --following validation
     IF l_sub_type = 1 THEN
      -- Loop through each item packed within the LPN
     OPEN l_item_cursor;
     LOOP
   FETCH l_item_cursor INTO l_item_id, l_restrict_loc;
   EXIT WHEN l_item_cursor%NOTFOUND;

   -- If the item restricts locators,
   -- check that the locator is allowed
   IF (l_restrict_loc = 1) THEN
      SELECT COUNT(*)
        INTO l_count
        FROM mtl_secondary_locators
        WHERE organization_id = p_organization_id
        AND inventory_item_id = l_item_id
        AND subinventory_code = p_subinventory_code
        AND secondary_locator = p_locator_id;
      -- No rows returned so the loc is not valid
      -- for the current item
      IF (l_count = 0) THEN
         x_return := 'N';
         EXIT;
      END IF;
   END IF;
     END LOOP;
     CLOSE l_item_cursor;
     END IF;

     -- Loc has already failed item/sub/loc restrictions
     -- so no need to do any further validation.
     IF (x_return = 'N') THEN
   RETURN x_return;
     END IF;

     -- Loop through each move order line for the LPN
     OPEN l_item_txn_cursor;
     LOOP
   FETCH l_item_txn_cursor INTO l_item_id, l_transaction_type;
   EXIT WHEN l_item_txn_cursor%NOTFOUND;

   -- Check if the loc's material status is valid
   -- for the current move order line's transaction type
   x_return := inv_material_status_grp.is_status_applicable
     (p_wms_installed           =>  'TRUE',
      p_trx_status_enabled      =>  NULL,
      p_trx_type_id             =>  l_transaction_type,
      p_lot_status_enabled      =>  NULL,
      p_serial_status_enabled   =>  NULL,
      p_organization_id         =>  p_organization_id,
      p_inventory_item_id       =>  l_item_id,
      p_sub_code                =>  p_subinventory_code,
      p_locator_id              =>  p_locator_id,
      p_lot_number              =>  NULL,
      p_serial_number           =>  NULL,
      p_object_type             =>  'L');
   -- The function returned 'N' so the loc is not valid
   -- for the transaction type in the current move order line
   IF (x_return = 'N') THEN
      EXIT;
   END IF;
     END LOOP;
     CLOSE l_item_txn_cursor;

     -- If all of the items in the LPN passed validation
     -- for the given loc, the return variable should be 'Y'
     RETURN x_return;

  EXCEPTION
     WHEN OTHERS THEN
   IF (l_debug = 1) THEN
      DEBUG('Exception occurred in function validate_lpn_loc!');
   END IF;
   x_return := 'N';
   RETURN x_return;
  END validate_lpn_loc;


PROCEDURE get_pickload_loc_lov(
   x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  , p_alias                  IN     VARCHAR2
  ) IS

l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_ispjm_org VARCHAR2(1);
/*Bug 2902336:Modfied the select clauses for performance enhancements*/
BEGIN

   IF p_alias IS NULL THEN
      get_pickload_loc_lov(
       x_locators               => x_locators
     , p_organization_id        => p_organization_id
     , p_subinventory_code      => p_subinventory_code
     , p_restrict_locators_code => p_restrict_locators_code
     , p_inventory_item_id      => p_inventory_item_id
     , p_concatenated_segments  => p_concatenated_segments
     , p_transaction_type_id    => p_transaction_type_id
     , p_wms_installed          => p_wms_installed
     , p_project_id             => p_project_id
     , p_task_id                => p_task_id
     );
     RETURN;
   END IF;
   BEGIN
    SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
    INTO l_ispjm_org
    FROM pjm_org_parameters
       WHERE organization_id=p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
    END;
    IF (l_ispjm_org='N') THEN/*Non PJM org*/
       IF p_restrict_locators_code=1  THEN
             OPEN x_locators FOR
               SELECT   a.inventory_location_id
               --, a.concatenated_segments--Bug4398337:Commented this line and added below line
               , a.locator_segments
               , NVL(a.description, -1)
               FROM wms_item_locations_kfv a, mtl_secondary_locators b
               WHERE b.organization_id = p_organization_id
               AND b.inventory_item_id = p_inventory_item_id
               AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND b.subinventory_code = p_subinventory_code
               AND a.inventory_location_id = b.secondary_locator
               /*AND inv_project.get_locsegs(a.inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)*/
               AND a.alias = p_alias
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
               ORDER BY 2;
          ELSE --Locators not restricted
             OPEN x_locators FOR
               SELECT   inventory_location_id
               --, concatenated_segments--Bug4398337:Commented this line and added below line
               , locator_segments concatenated_segments
               , description
               FROM wms_item_locations_kfv
               WHERE organization_id = p_organization_id
               AND subinventory_code = p_subinventory_code
               AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               --AND inv_project.get_locsegs(inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)
               AND alias = p_alias
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
               ORDER BY 2;
          END IF;
      ELSE /*PJM org*/
       IF p_project_id IS NULL THEN
          IF p_restrict_locators_code=1  THEN
               OPEN x_locators FOR
                 SELECT   a.inventory_location_id
                 --, a.concatenated_segments--Bug4398337:Commented this line and added below line
                 , a.locator_segments concatenated_segments
                 , NVL(a.description, -1)
                 FROM wms_item_locations_kfv a, mtl_secondary_locators b
                 WHERE b.organization_id = p_organization_id
                 AND b.inventory_item_id = p_inventory_item_id
                 AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                 AND b.subinventory_code = p_subinventory_code
                 AND a.inventory_location_id = b.secondary_locator
                 AND a.inventory_location_id=nvl(a.physical_location_id,a.inventory_location_id)
                 AND a.alias = p_alias
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
                ORDER BY 2;
              ELSE --Locators not restricted
               OPEN x_locators FOR
                SELECT   inventory_location_id
                --, concatenated_segments--Bug4398337:Commented this line and added below line
                , locator_segments concatenated_segments
                , description
                FROM wms_item_locations_kfv
                WHERE organization_id = p_organization_id
                AND subinventory_code = p_subinventory_code
                AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                AND inventory_location_id=nvl(physical_location_id,inventory_location_id)
                AND alias = p_alias
                AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
                ORDER BY 2;
              END IF;
        ELSE /*PJM org:Project id not null */
            IF p_restrict_locators_code = 1 THEN --Locators restricted to predefined list
                        OPEN x_locators FOR
                    SELECT   a.inventory_location_id
                              --, a.concatenated_segments--Bug4398337:Commented this line and added below line
                              , a.locator_segments concatenated_segments
                              , NVL(a.description, -1)
                         FROM wms_item_locations_kfv a, mtl_secondary_locators b
                         WHERE b.organization_id = p_organization_id
                         AND b.inventory_item_id = p_inventory_item_id
                         AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                         AND b.subinventory_code = p_subinventory_code
                         AND a.inventory_location_id = b.secondary_locator
                         --AND inv_project.get_locsegs(a.inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)
               AND a.alias = p_alias
                         AND a.project_id = p_project_id
               AND NVL(a.task_id, -1) = NVL(p_task_id, -1)
                    AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
                    ORDER BY 2;
            ELSE --Locators not restricted
                   OPEN x_locators FOR
                         SELECT   inventory_location_id
                         --, concatenated_segments--Bug4398337:Commented this line and added below line
                         , locator_segments concatenated_segments
                         , description
                         FROM wms_item_locations_kfv
                    WHERE organization_id = p_organization_id
                   AND subinventory_code = p_subinventory_code
                         AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                         --AND inv_project.get_locsegs(inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)
               AND alias  = p_alias
                         AND project_id = p_project_id
               AND NVL(task_id, -1) = NVL(p_task_id, -1)
                         AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
                   ORDER BY 2;
            END IF;
         END IF;
    END IF;
END get_pickload_loc_lov;
 /* Bug 2769628: Procedure to list the locators during Pick Load as they have to be restricted by project and task*/
PROCEDURE get_pickload_loc_lov(
   x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER) IS

l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_ispjm_org VARCHAR2(1);
/*Bug 2902336:Modfied the select clauses for performance enhancements*/
BEGIN
   BEGIN
    SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
    INTO l_ispjm_org
    FROM pjm_org_parameters
       WHERE organization_id=p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
    END;
    IF (l_ispjm_org='N') THEN/*Non PJM org*/
       IF p_restrict_locators_code=1  THEN
             OPEN x_locators FOR
               SELECT   a.inventory_location_id
               --, a.concatenated_segments--Bug4398337:Commented this line and added below line
               , a.locator_segments
               , NVL(a.description, -1)
               FROM wms_item_locations_kfv a, mtl_secondary_locators b
               WHERE b.organization_id = p_organization_id
               AND b.inventory_item_id = p_inventory_item_id
               AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND b.subinventory_code = p_subinventory_code
               AND a.inventory_location_id = b.secondary_locator
               /*AND inv_project.get_locsegs(a.inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)*/
               AND a.concatenated_segments LIKE (p_concatenated_segments)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
               ORDER BY 2;
          ELSE --Locators not restricted
             OPEN x_locators FOR
               SELECT   inventory_location_id
               --, concatenated_segments--Bug4398337:Commented this line and added below line
               , locator_segments concatenated_segments
               , description
               FROM wms_item_locations_kfv
               WHERE organization_id = p_organization_id
               AND subinventory_code = p_subinventory_code
               AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               --AND inv_project.get_locsegs(inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)
               AND concatenated_segments LIKE (p_concatenated_segments)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
               ORDER BY 2;
          END IF;
      ELSE /*PJM org*/
       IF p_project_id IS NULL THEN
          IF p_restrict_locators_code=1  THEN
               OPEN x_locators FOR
                 SELECT   a.inventory_location_id
                 --, a.concatenated_segments--Bug4398337:Commented this line and added below line
                 , a.locator_segments concatenated_segments
                 , NVL(a.description, -1)
                 FROM wms_item_locations_kfv a, mtl_secondary_locators b
                 WHERE b.organization_id = p_organization_id
                 AND b.inventory_item_id = p_inventory_item_id
                 AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                 AND b.subinventory_code = p_subinventory_code
                 AND a.inventory_location_id = b.secondary_locator
                 AND a.inventory_location_id=nvl(a.physical_location_id,a.inventory_location_id)
                 AND a.concatenated_segments LIKE (p_concatenated_segments)
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
                ORDER BY 2;
              ELSE --Locators not restricted
               OPEN x_locators FOR
                SELECT   inventory_location_id
                --, concatenated_segments--Bug4398337:Commented this line and added below line
                , locator_segments concatenated_segments
                , description
                FROM wms_item_locations_kfv
                WHERE organization_id = p_organization_id
                AND subinventory_code = p_subinventory_code
                AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                AND inventory_location_id=nvl(physical_location_id,inventory_location_id)
                AND concatenated_segments LIKE (p_concatenated_segments)
                AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
                ORDER BY 2;
              END IF;
        ELSE /*PJM org:Project id not null */
            IF p_restrict_locators_code = 1 THEN --Locators restricted to predefined list
                        OPEN x_locators FOR
                    SELECT   a.inventory_location_id
                              --, a.concatenated_segments--Bug4398337:Commented this line and added below line
                              , a.locator_segments concatenated_segments
                              , NVL(a.description, -1)
                         FROM wms_item_locations_kfv a, mtl_secondary_locators b
                         WHERE b.organization_id = p_organization_id
                         AND b.inventory_item_id = p_inventory_item_id
                         AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                         AND b.subinventory_code = p_subinventory_code
                         AND a.inventory_location_id = b.secondary_locator
                         --AND inv_project.get_locsegs(a.inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)
               AND a.concatenated_segments LIKE (p_concatenated_segments)
                         AND a.project_id = p_project_id
               AND NVL(a.task_id, -1) = NVL(p_task_id, -1)
                    AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
                    ORDER BY 2;
            ELSE --Locators not restricted
                   OPEN x_locators FOR
                         SELECT   inventory_location_id
                         --, concatenated_segments--Bug4398337:Commented this line and added below line
                         , locator_segments concatenated_segments
                         , description
                         FROM wms_item_locations_kfv
                    WHERE organization_id = p_organization_id
                   AND subinventory_code = p_subinventory_code
                         AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                         --AND inv_project.get_locsegs(inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)
               AND concatenated_segments LIKE (p_concatenated_segments)
                         AND project_id = p_project_id
               AND NVL(task_id, -1) = NVL(p_task_id, -1)
                         AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
                   ORDER BY 2;
            END IF;
         END IF;
    END IF;
END get_pickload_loc_lov;

/* The following procedure is added for bug 4990550. Since the locator field in pick load page is no longer an LOV
from 11510,the new procedure is added to validate the locator field. */
PROCEDURE get_pickload_loc(
      x_locators               OUT    NOCOPY t_genref
     , p_organization_id        IN     NUMBER
     , p_subinventory_code      IN     VARCHAR2
     , p_restrict_locators_code IN     NUMBER
     , p_inventory_item_id      IN     NUMBER
     , p_concatenated_segments  IN     VARCHAR2
     , p_transaction_type_id    IN     NUMBER
     , p_wms_installed          IN     VARCHAR2
     , p_project_id             IN     NUMBER
     , p_task_id                IN     NUMBER) IS

   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_ispjm_org VARCHAR2(1);
   /*Bug 2902336:Modfied the select clauses for performance enhancements*/
   BEGIN
      BEGIN
       SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
       INTO l_ispjm_org
       FROM pjm_org_parameters
          WHERE organization_id=p_organization_id;
       EXCEPTION
          WHEN NO_DATA_FOUND  THEN
            l_ispjm_org:='N';
       END;
       IF (l_ispjm_org='N') THEN/*Non PJM org*/
          IF p_restrict_locators_code=1  THEN
                OPEN x_locators FOR
                  SELECT   a.inventory_location_id
                  , a.concatenated_segments -- Bug 4398336
                  --, a.locator_segments concatenated_segments
                  , NVL(a.description, -1)
                  FROM wms_item_locations_kfv a, mtl_secondary_locators b
                  WHERE b.organization_id = p_organization_id
                  AND b.inventory_item_id = p_inventory_item_id
                  AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                  AND b.subinventory_code = p_subinventory_code
                  AND a.inventory_location_id = b.secondary_locator
                  /*AND inv_project.get_locsegs(a.inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)*/
                  AND a.concatenated_segments LIKE (p_concatenated_segments)
                  AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
                  ORDER BY 2;
             ELSE --Locators not restricted
                OPEN x_locators FOR
                  SELECT   inventory_location_id
                  , concatenated_segments -- Bug 4398336
                  --, locator_segments concatenated_segments
                  , description
                  FROM wms_item_locations_kfv
                  WHERE organization_id = p_organization_id
                  AND subinventory_code = p_subinventory_code
                  AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                  --AND inv_project.get_locsegs(inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)
                  AND concatenated_segments LIKE (p_concatenated_segments)
                  AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
                  ORDER BY 2;
             END IF;
         ELSE /*PJM org*/
          IF p_project_id IS NULL THEN
             IF p_restrict_locators_code=1  THEN
                  OPEN x_locators FOR
                    SELECT   a.inventory_location_id
                    , a.concatenated_segments -- Bug 4398336
                    --, a.locator_segments concatenated_segments
                    , NVL(a.description, -1)
                    FROM wms_item_locations_kfv a, mtl_secondary_locators b
                    WHERE b.organization_id = p_organization_id
                    AND b.inventory_item_id = p_inventory_item_id
                    AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                    AND b.subinventory_code = p_subinventory_code
                    AND a.inventory_location_id = b.secondary_locator
                    -- AND a.inventory_location_id=nvl(a.physical_location_id,a.inventory_location_id)
                    AND a.project_id is null
                    AND a.concatenated_segments LIKE (p_concatenated_segments)
                    AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
                   ORDER BY 2;
                 ELSE --Locators not restricted
                  OPEN x_locators FOR
                   SELECT   inventory_location_id
                   , concatenated_segments -- Bug 4398336
                   --, locator_segments concatenated_segments
                   , description
                   FROM wms_item_locations_kfv
                   WHERE organization_id = p_organization_id
                   AND subinventory_code = p_subinventory_code
                   AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                   -- AND inventory_location_id=nvl(physical_location_id,inventory_location_id)
                   AND project_id is null
                   AND concatenated_segments LIKE (p_concatenated_segments)
                   AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
                   ORDER BY 2;
                 END IF;
           ELSE /*PJM org:Project id not null */
               IF p_restrict_locators_code = 1 THEN --Locators restricted to predefined list
                           OPEN x_locators FOR
                       SELECT   a.inventory_location_id
                                 , a.concatenated_segments -- Bug 4398336
                                 --, a.locator_segments concatenated_segments
                                 , NVL(a.description, -1)
                            FROM wms_item_locations_kfv a, mtl_secondary_locators b
                            WHERE b.organization_id = p_organization_id
                            AND b.inventory_item_id = p_inventory_item_id
                            AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                            AND b.subinventory_code = p_subinventory_code
                            AND a.inventory_location_id = b.secondary_locator
                            --AND inv_project.get_locsegs(a.inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)
                  AND a.concatenated_segments LIKE (p_concatenated_segments)
                            AND a.project_id = p_project_id
                  AND NVL(a.task_id, -1) = NVL(p_task_id, -1)
                       AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
                       ORDER BY 2;
               ELSE --Locators not restricted
                      OPEN x_locators FOR
                            SELECT   inventory_location_id
                            , concatenated_segments -- Bug 4398336
                            --, locator_segments concatenated_segments
                            , description
                            FROM wms_item_locations_kfv
                       WHERE organization_id = p_organization_id
                      AND subinventory_code = p_subinventory_code
                            AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                            --AND inv_project.get_locsegs(inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)
                  AND concatenated_segments LIKE (p_concatenated_segments)
                            AND project_id = p_project_id
                  AND NVL(task_id, -1) = NVL(p_task_id, -1)
                            AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
                      ORDER BY 2;
               END IF;
            END IF;
       END IF;
   END get_pickload_loc;


  -- Bug #3075665. ADDED IN PATCHSET J PROJECT  ADVANCED PICKLOAD
  --      Patchset J: Procedure used to get the locs including project locs
  --      Procedure Name:  get_pickload_all_loc_lov
  --
  --      Input parameters:
  --       p_organization_id       - Organization Id
  --
  --      Output value:
  --                 x_locators     Ref. cursor
  --
PROCEDURE GET_APL_PRJ_LOC_LOV(
   x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER) IS

l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_ispjm_org VARCHAR2(1);
BEGIN
   BEGIN
    SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
    INTO l_ispjm_org
    FROM pjm_org_parameters
       WHERE organization_id=p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
    END;
    IF (l_ispjm_org='N') THEN/*Non PJM org*/
       IF p_restrict_locators_code=1  THEN
             OPEN x_locators FOR
               SELECT   a.inventory_location_id
               --, a.concatenated_segments--Bug4398337:Commented this line and added below line
               , a.locator_segments concatenated_segments
               , NVL(a.description, -1)
               , a.subinventory_code
               FROM wms_item_locations_kfv a, mtl_secondary_locators b
               WHERE b.organization_id = p_organization_id
               AND b.inventory_item_id = p_inventory_item_id
               AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND b.subinventory_code = p_subinventory_code
               AND a.inventory_location_id = b.secondary_locator
               /*AND inv_project.get_locsegs(a.inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)*/
               AND a.concatenated_segments LIKE (p_concatenated_segments)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
               ORDER BY 2;
          ELSE --Locators not restricted
             OPEN x_locators FOR
               SELECT   inventory_location_id
              -- , concatenated_segments--Bug4398337:Commented this line and added below line
               , locator_segments concatenated_segments
               , description
               , subinventory_code
               FROM wms_item_locations_kfv
               WHERE organization_id = p_organization_id
               AND subinventory_code = p_subinventory_code
               AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               --AND inv_project.get_locsegs(inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)
               AND concatenated_segments LIKE (p_concatenated_segments)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
               ORDER BY 2;
          END IF;
      ELSE /*PJM org*/
       IF p_project_id IS NULL THEN
          IF p_restrict_locators_code=1  THEN
               OPEN x_locators FOR
                 SELECT   a.inventory_location_id
                 --, a.concatenated_segments--Bug4398337:Commented this line and added below line
                 , a.locator_segments concatenated_segments
                 , NVL(a.description, -1)
                 , a.subinventory_code
                 FROM wms_item_locations_kfv a, mtl_secondary_locators b
                 WHERE b.organization_id = p_organization_id
                 AND b.inventory_item_id = p_inventory_item_id
                 AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                 AND b.subinventory_code = p_subinventory_code
                 AND a.inventory_location_id = b.secondary_locator
             /*AND inv_project.get_locsegs(a.inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)*/
                 AND a.inventory_location_id=nvl(a.physical_location_id,a.inventory_location_id)
                 AND a.concatenated_segments LIKE (p_concatenated_segments)
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
                ORDER BY 2;
              ELSE --Locators not restricted
               OPEN x_locators FOR
                SELECT   inventory_location_id
               -- , concatenated_segments--Bug4398337:Commented this line and added below line
                , locator_segments concatenated_segments
                , description
                , subinventory_code
                FROM wms_item_locations_kfv
                WHERE organization_id = p_organization_id
                AND subinventory_code = p_subinventory_code
                AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                --AND inv_project.get_locsegs(inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)
                AND inventory_location_id=nvl(physical_location_id,inventory_location_id)
                AND concatenated_segments LIKE (p_concatenated_segments)
                AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
                ORDER BY 2;
              END IF;
       ELSE /*PJM org:Project id not null */
         IF p_restrict_locators_code = 1 THEN --Locators restricted to predefined list
              OPEN x_locators FOR
               SELECT   a.inventory_location_id
               --, a.concatenated_segments--Bug4398337:Commented this line and added below line
               , a.locator_segments concatenated_segments
               , NVL(a.description, -1)
            , a.subinventory_code
               FROM wms_item_locations_kfv a, mtl_secondary_locators b
               WHERE b.organization_id = p_organization_id
               AND b.inventory_item_id = p_inventory_item_id
               AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND b.subinventory_code = p_subinventory_code
               AND a.inventory_location_id = b.secondary_locator
               --AND inv_project.get_locsegs(a.inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)
               AND a.concatenated_segments LIKE (p_concatenated_segments)
               AND a.project_id = p_project_id
               AND NVL(a.task_id, -1) = NVL(p_task_id, -1)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
               ORDER BY 2;
            ELSE --Locators not restricted
              OPEN x_locators FOR
               SELECT   inventory_location_id
             --  , concatenated_segments--Bug4398337:Commented this line and added below line
               , locator_segments concatenated_segments
               , description
             , subinventory_code
               FROM wms_item_locations_kfv
               WHERE organization_id = p_organization_id
               AND subinventory_code = p_subinventory_code
               AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               --AND inv_project.get_locsegs(inventory_location_id, p_organization_id) LIKE (p_concatenated_segments)
               AND concatenated_segments LIKE (p_concatenated_segments)
               AND project_id = p_project_id
               AND NVL(task_id, -1) = NVL(p_task_id, -1)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code, inventory_location_id, NULL, NULL, 'L') = 'Y'
              ORDER BY 2;
            END IF;
         END IF;
    END IF;
END GET_APL_PRJ_LOC_LOV;

/* Bug #3075665. ADDED IN PATCHSET J PROJECT  ADVANCED PICKLOAD
 * All the locators for the given org are selected, not restricting on the subinventory
 */
  --      Patchset J: Procedure used to get all the locs in the org
  --                  restricted by proj, task if passed and
  --                  NOT restricted by subinventory
  --      Procedure Name:  get_pickload_all_loc_lov
  --
  --      Input parameters:
  --       p_organization_id       - Organization Id
  --
  --      Output value:
  --                 x_locators     Ref. cursor
  --
PROCEDURE get_pickload_all_loc_lov(
   x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER) IS

l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_ispjm_org VARCHAR2(1);
/*Bug 2902336:Modfied the select clauses for performance enhancements*/
BEGIN
   BEGIN
    SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
    INTO l_ispjm_org
    FROM pjm_org_parameters
       WHERE organization_id=p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
    END;
    IF (l_ispjm_org='N') THEN/*Non PJM org*/
       IF p_restrict_locators_code=1  THEN
             OPEN x_locators FOR
               SELECT   a.inventory_location_id
            --   , a.concatenated_segments--Bug4398337:Commented this line and added below line
               , a.locator_segments concatenated_segments
               , NVL(a.description, -1)
               , a.subinventory_code
               FROM wms_item_locations_kfv a, mtl_secondary_locators b
               WHERE b.organization_id = p_organization_id
               AND b.inventory_item_id = p_inventory_item_id
               AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               /*AND b.subinventory_code = p_subinventory_code*/ /*Removed Subinventory restriction, displayes all locs in the org*/
               AND a.inventory_location_id = b.secondary_locator
               AND a.concatenated_segments LIKE (p_concatenated_segments)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, NULL, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
               ORDER BY 2;
          ELSE --Locators not restricted
             OPEN x_locators FOR
               SELECT   inventory_location_id
               --, concatenated_segments--Bug4398337:Commented this line and added below line
               , locator_segments concatenated_segments
               , description
               , subinventory_code
               FROM wms_item_locations_kfv
               WHERE organization_id = p_organization_id
               /*AND subinventory_code = p_subinventory_code*//*Removed Subinventory restriction, displayes all locs in the org*/
               AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND concatenated_segments LIKE (p_concatenated_segments)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, NULL, inventory_location_id, NULL, NULL, 'L') = 'Y'
               ORDER BY 2;
          END IF;
      ELSE /*PJM org*/
       IF p_project_id IS NULL THEN
          IF p_restrict_locators_code=1  THEN
               OPEN x_locators FOR
                 SELECT   a.inventory_location_id
              --   , a.concatenated_segments--Bug4398337:Commented this line and added below line
                 , a.locator_segments concatenated_segments
                 , NVL(a.description, -1)
                 ,a.subinventory_code
                 FROM wms_item_locations_kfv a, mtl_secondary_locators b
                 WHERE b.organization_id = p_organization_id
                 AND b.inventory_item_id = p_inventory_item_id
                 AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                 /*AND b.subinventory_code = p_subinventory_code*//*Removed Subinventory restriction, displayes all locs in the org*/
                 AND a.inventory_location_id = b.secondary_locator
                 AND a.inventory_location_id=nvl(a.physical_location_id,a.inventory_location_id)
                 AND a.concatenated_segments LIKE (p_concatenated_segments)
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, NULL, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
                ORDER BY 2;
              ELSE --Locators not restricted
               OPEN x_locators FOR
                SELECT   inventory_location_id
              --  , concatenated_segments--Bug4398337:Commented this line and added below line
                , locator_segments concatenated_segments
                , description
                , subinventory_code
                FROM wms_item_locations_kfv
                WHERE organization_id = p_organization_id
                /*AND subinventory_code = p_subinventory_code*//*Removed Subinventory restriction, displayes all locs in the org*/
                AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                AND inventory_location_id=nvl(physical_location_id,inventory_location_id)
                AND concatenated_segments LIKE (p_concatenated_segments)
                AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, NULL, inventory_location_id, NULL, NULL, 'L') = 'Y'
                ORDER BY 2;
              END IF;
        ELSE /*PJM org:Project id not null */
         IF p_restrict_locators_code = 1 THEN --Locators restricted to predefined list
              OPEN x_locators FOR
               SELECT   a.inventory_location_id
             --  , a.concatenated_segments--Bug4398337:Commented this line and added below line
               , a.locator_segments concatenated_segments
               , NVL(a.description, -1)
               , a.subinventory_code
               FROM wms_item_locations_kfv a, mtl_secondary_locators b
               WHERE b.organization_id = p_organization_id
               AND b.inventory_item_id = p_inventory_item_id
               AND NVL(a.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               /*AND b.subinventory_code = p_subinventory_code*//*Removed Subinventory restriction, displayes all locs in the org*/
               AND a.inventory_location_id = b.secondary_locator
               AND a.concatenated_segments LIKE (p_concatenated_segments)
               AND a.project_id = p_project_id
               AND NVL(a.task_id, -1) = NVL(p_task_id, -1)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, NULL, a.inventory_location_id, NULL, NULL, 'L') = 'Y'
               ORDER BY 2;
            ELSE --Locators not restricted
              OPEN x_locators FOR
               SELECT   inventory_location_id
             --  , concatenated_segments--Bug4398337:Commented this line and added below line
               , locator_segments concatenated_segments
               , description
             , subinventory_code
               FROM wms_item_locations_kfv
               WHERE organization_id = p_organization_id
               /*AND subinventory_code = p_subinventory_code*//*Removed Subinventory restriction, displayes all locs in the org*/
               AND NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
               AND concatenated_segments LIKE (p_concatenated_segments)
               AND project_id = p_project_id
               AND NVL(task_id, -1) = NVL(p_task_id, -1)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_inventory_item_id, NULL, inventory_location_id, NULL, NULL, 'L') = 'Y'
              ORDER BY 2;
            END IF;
          END IF;
    END IF;
END get_pickload_all_loc_lov;

PROCEDURE validate_pickload_loc
  (p_organization_id        IN         NUMBER,
   p_subinventory_code      IN         VARCHAR2,
   p_restrict_locators_code IN         NUMBER,
   p_inventory_item_id      IN         NUMBER,
   p_locator                IN         VARCHAR2,
   p_transaction_type_id    IN         NUMBER,
   p_project_id             IN         NUMBER,
   p_task_id                IN         NUMBER,
   x_is_valid_locator       OUT nocopy VARCHAR2,
   x_locator_id             OUT nocopy NUMBER)
  IS

   TYPE loc_record_type IS RECORD
    (locator_id   NUMBER,
     locator      VARCHAR2(204),
     description  VARCHAR2(50));

   loc_rec      loc_record_type;
   l_locators   t_genref;
   l_project_id NUMBER;
   l_task_id    NUMBER;

BEGIN
   x_is_valid_locator := 'N';

   IF p_project_id = 0 THEN
      l_project_id := NULL;
   END IF;

   IF p_task_id = 0 THEN
      l_task_id := NULL;
   END IF;

   get_pickload_loc_lov(x_locators               => l_locators,
                        p_organization_id        => p_organization_id,
                        p_subinventory_code      => p_subinventory_code,
                        p_restrict_locators_code => p_restrict_locators_code,
                        p_inventory_item_id      => p_inventory_item_id,
                        p_concatenated_segments  => p_locator,
                        p_transaction_type_id    => p_transaction_type_id,
                        p_wms_installed          => 'Y',
                        p_project_id             => l_project_id,
                        p_task_id                => l_task_id);

   LOOP
      FETCH l_locators INTO loc_rec;
      EXIT WHEN l_locators%notfound;

      IF loc_rec.locator = p_locator THEN
         x_is_valid_locator := 'Y';
         x_locator_id := loc_rec.locator_id;
         EXIT;
      END IF;

   END LOOP;

END;

PROCEDURE get_inq_prj_loc_lov(
          x_Locators               OUT  NOCOPY t_genref,
          p_Organization_Id        IN   NUMBER,
          p_Subinventory_Code      IN   VARCHAR2,
          p_Restrict_Locators_Code IN   NUMBER,
          p_Inventory_Item_Id      IN   NUMBER,
          p_Concatenated_Segments  IN   VARCHAR2,
          p_project_id             IN   NUMBER := NULL,
          p_task_id                IN   NUMBER := NULL
          -- p_alias                  IN   VARCHAR2 := NULL
          -- p_suggestion             IN   VARCHAR2 := NULL
          ) IS
   l_ispjm_org VARCHAR2(1);
BEGIN
   BEGIN
      SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
      INTO   l_ispjm_org
      FROM   pjm_org_parameters
      WHERE  organization_id=p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
    END;

    IF l_ispjm_org='N'  THEN   /*Non PJM Org*/
       IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
          OPEN x_Locators FOR
          SELECT a.inventory_location_id,
                -- a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                 a.locator_segments  locsegs,
                 a.description
          FROM   wms_item_locations_kfv a,
                 mtl_secondary_locators b
          WHERE  b.organization_id = p_Organization_Id
          AND    b.inventory_item_id = p_Inventory_Item_Id
          AND    b.subinventory_code = p_Subinventory_Code
          AND    a.inventory_location_id = b.secondary_locator
          AND    a.concatenated_segments LIKE (p_concatenated_segments )
          -- AND    a.concatenated_segments = nvl(p_suggestion, a.concatenated_segments)
             /* BUG#28101405: To show only common locators in the LOV */
          ORDER BY 2;
       ELSE --Locators not restricted
           --bug#3440453 Remove the NVL on organization_id if user passes it.
          IF p_organization_id IS NULL THEN
             OPEN x_Locators FOR
             SELECT inventory_location_id,
                    --concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                    locator_segments locsegs,
                    description
             FROM   wms_item_locations_kfv
             WHERE  organization_id = Nvl(p_organization_id, organization_id)
             AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
             AND    concatenated_segments LIKE (p_concatenated_segments )
             -- AND    concatenated_segments = nvl(p_suggestion, concatenated_segments)
             ORDER BY 2;
          ELSE   -- Organization_id is not null
             OPEN x_Locators FOR
             SELECT inventory_location_id,
                    --concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                    locator_segments locsegs,
                    description
             FROM   wms_item_locations_kfv
             WHERE  organization_id = p_organization_id
             AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
             AND    concatenated_segments LIKE (p_concatenated_segments )
             -- AND    alias = nvl(p_alias, alias)
             -- AND    concatenated_segments = nvl(p_suggestion, concatenated_segments)
             ORDER BY 2;
          END IF;
       END IF;
    ELSE /*PJM org*/
      IF p_project_id IS NOT NULL THEN

         IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
           OPEN x_Locators FOR
            SELECT a.inventory_location_id,
                   --a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                   a.locator_segments locsegs,
                   a.description
             FROM  wms_item_locations_kfv a,
                   mtl_secondary_locators b
            WHERE b.organization_id = p_Organization_Id
             AND   b.inventory_item_id = p_Inventory_Item_Id
             AND   b.subinventory_code = p_Subinventory_Code
             AND   a.inventory_location_id = b.secondary_locator
             AND   a.concatenated_segments LIKE (p_concatenated_segments )
             -- AND   a.concatenated_segments = nvl(p_suggestion, a.concatenated_segments)
       /* BUG#28101405: To show only common locators in the LOV */
             AND   a.project_id = p_project_id
             AND   NVL(a.task_id, -9999)    = NVL(p_task_id, -9999)
            ORDER BY 2;

         ELSE --Locators not restricted
            --bug#3440453 Remove the NVL on organization_id if user passes it.
            IF p_organization_id IS NULL THEN
              OPEN x_Locators FOR
                SELECT inventory_location_id,
                      -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                       locator_segments locsegs,
                       description
                FROM   wms_item_locations_kfv
                WHERE  organization_id = Nvl(p_organization_id, organization_id)
                AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                AND    concatenated_segments LIKE (p_concatenated_segments )
                -- AND    concatenated_segments = nvl(p_suggestion, concatenated_segments)
                AND    project_id = p_project_id
                AND    NVL(task_id, -1)       = NVL(p_task_id, -1)
               ORDER BY 2;
            ELSE -- Organization_id is not null
               OPEN x_Locators FOR
                 SELECT inventory_location_id,
                        --concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                        locator_segments locsegs,
                        description
                 FROM   wms_item_locations_kfv
                 WHERE  organization_id = p_organization_id
                 AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                 AND    concatenated_segments LIKE (p_concatenated_segments )
                 -- AND    concatenated_segments = nvl(p_suggestion, concatenated_segments)
                 AND    project_id = p_project_id
                 AND    NVL(task_id, -1)       = NVL(p_task_id, -1)
                ORDER BY 2;
            END IF;
         END IF;

      ELSE /*PJM org project id null*/

          IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
            OPEN x_Locators FOR
             SELECT a.inventory_location_id,
                    --a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                    a.locator_segments locsegs,
                    a.description
              FROM  wms_item_locations_kfv a,
                    mtl_secondary_locators b
             WHERE  b.organization_id = p_Organization_Id
              AND   b.inventory_item_id = p_Inventory_Item_Id
              AND   b.subinventory_code = p_Subinventory_Code
              AND   a.inventory_location_id = b.secondary_locator
              AND   a.concatenated_segments LIKE (p_concatenated_segments )
              -- AND   a.concatenated_segments = nvl(p_suggestion, a.concatenated_segments)
              AND   a.inventory_location_id=NVL(a.physical_location_id,a.inventory_location_id)
            /* BUG#28101405: To show only common locators in the LOV */
             ORDER BY 2;

          ELSE --Locators not restricted
             --bug#3440453 Remove the NVL on organization_id if user passes it.
             IF p_organization_id IS NULL THEN
               OPEN x_Locators FOR
                 SELECT inventory_location_id,
                       -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                        locator_segments locsegs,
                        description
                 FROM   wms_item_locations_kfv
                 WHERE  organization_id = Nvl(p_organization_id, organization_id)
                 AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                 AND    concatenated_segments LIKE (p_concatenated_segments )
                 AND    inventory_location_id=nvl(physical_location_id,inventory_location_id)
                 -- AND    concatenated_segments = nvl(p_suggestion, concatenated_segments)
                 ORDER BY 2;
             ELSE -- Organization_id is not null
                OPEN x_Locators FOR
                  SELECT inventory_location_id,
                         --concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                         locator_segments locsegs,
                         description
                  FROM   wms_item_locations_kfv
                  WHERE  organization_id = p_organization_id
                  AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                  AND    concatenated_segments LIKE (p_concatenated_segments )
                  -- AND    concatenated_segments = nvl(p_suggestion, concatenated_segments)
                  AND    inventory_location_id=nvl(physical_location_id,inventory_location_id)
                  ORDER BY 2;
             END IF;
          END IF;
       END IF;
  END IF;
END get_inq_prj_loc_lov;

PROCEDURE get_inq_prj_loc_lov(
          x_Locators               OUT  NOCOPY t_genref,
          p_Organization_Id        IN   NUMBER,
          p_Subinventory_Code      IN   VARCHAR2,
          p_Restrict_Locators_Code IN   NUMBER,
          p_Inventory_Item_Id      IN   NUMBER,
          p_Concatenated_Segments  IN   VARCHAR2,
          p_project_id             IN   NUMBER := NULL,
          p_task_id                IN   NUMBER := NULL,
          p_alias                  IN   VARCHAR2
          ) IS
   l_ispjm_org VARCHAR2(1);
BEGIN
   IF p_alias IS NULL THEN
      get_inq_prj_loc_lov(
           x_Locators               => x_locators
          ,p_Organization_Id        => p_organization_id
          ,p_Subinventory_Code      => p_subinventory_code
          ,p_Restrict_Locators_Code => p_restrict_locators_code
          ,p_Inventory_Item_Id      => p_inventory_item_id
          ,p_Concatenated_Segments  => p_concatenated_segments
          ,p_project_id             => p_project_id
          ,p_task_id                => p_task_id
          );
      RETURN;
   END IF;
   BEGIN
      SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
      INTO   l_ispjm_org
      FROM   pjm_org_parameters
      WHERE  organization_id=p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
    END;

    IF l_ispjm_org='N'  THEN   /*Non PJM Org*/
       IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
          OPEN x_Locators FOR
          SELECT a.inventory_location_id,
                -- a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                 a.locator_segments  locsegs,
                 a.description
          FROM   wms_item_locations_kfv a,
                 mtl_secondary_locators b
          WHERE  b.organization_id = p_Organization_Id
          AND    b.inventory_item_id = p_Inventory_Item_Id
          AND    b.subinventory_code = p_Subinventory_Code
          AND    a.inventory_location_id = b.secondary_locator
          AND    a.alias = p_alias
          -- AND    a.concatenated_segments = nvl(p_suggestion, a.concatenated_segments)
             /* BUG#28101405: To show only common locators in the LOV */
          ORDER BY 2;
       ELSE --Locators not restricted
           --bug#3440453 Remove the NVL on organization_id if user passes it.
          IF p_organization_id IS NULL THEN
             OPEN x_Locators FOR
             SELECT inventory_location_id,
                    --concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                    locator_segments locsegs,
                    description
             FROM   wms_item_locations_kfv
             WHERE  organization_id = Nvl(p_organization_id, organization_id)
             AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
             AND    alias = p_alias
             -- AND    concatenated_segments = nvl(p_suggestion, concatenated_segments)
             ORDER BY 2;
          ELSE   -- Organization_id is not null
             OPEN x_Locators FOR
             SELECT inventory_location_id,
                    --concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                    locator_segments locsegs,
                    description
             FROM   wms_item_locations_kfv
             WHERE  organization_id = p_organization_id
             AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
             AND    alias = p_alias
             ORDER BY 2;
          END IF;
       END IF;
    ELSE /*PJM org*/
      IF p_project_id IS NOT NULL THEN

         IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
           OPEN x_Locators FOR
            SELECT a.inventory_location_id,
                   --a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                   a.locator_segments locsegs,
                   a.description
             FROM  wms_item_locations_kfv a,
                   mtl_secondary_locators b
            WHERE b.organization_id = p_Organization_Id
             AND   b.inventory_item_id = p_Inventory_Item_Id
             AND   b.subinventory_code = p_Subinventory_Code
             AND   a.inventory_location_id = b.secondary_locator
             AND   a.alias = p_alias
             -- AND   a.concatenated_segments = nvl(p_suggestion, a.concatenated_segments)
       /* BUG#28101405: To show only common locators in the LOV */
             AND   a.project_id = p_project_id
             AND   NVL(a.task_id, -9999)    = NVL(p_task_id, -9999)
            ORDER BY 2;

         ELSE --Locators not restricted
            --bug#3440453 Remove the NVL on organization_id if user passes it.
            IF p_organization_id IS NULL THEN
              OPEN x_Locators FOR
                SELECT inventory_location_id,
                      -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                       locator_segments locsegs,
                       description
                FROM   wms_item_locations_kfv
                WHERE  organization_id = Nvl(p_organization_id, organization_id)
                AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                AND    alias = p_alias
                -- AND    concatenated_segments = nvl(p_suggestion, concatenated_segments)
                AND    project_id = p_project_id
                AND    NVL(task_id, -1)       = NVL(p_task_id, -1)
               ORDER BY 2;
            ELSE -- Organization_id is not null
               OPEN x_Locators FOR
                 SELECT inventory_location_id,
                        --concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                        locator_segments locsegs,
                        description
                 FROM   wms_item_locations_kfv
                 WHERE  organization_id = p_organization_id
                 AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                 AND    alias = p_alias
                 -- AND    concatenated_segments = nvl(p_suggestion, concatenated_segments)
                 AND    project_id = p_project_id
                 AND    NVL(task_id, -1)       = NVL(p_task_id, -1)
                ORDER BY 2;
            END IF;
         END IF;

      ELSE /*PJM org project id null*/

          IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
            OPEN x_Locators FOR
             SELECT a.inventory_location_id,
                    --a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                    a.locator_segments locsegs,
                    a.description
              FROM  wms_item_locations_kfv a,
                    mtl_secondary_locators b
             WHERE  b.organization_id = p_Organization_Id
              AND   b.inventory_item_id = p_Inventory_Item_Id
              AND   b.subinventory_code = p_Subinventory_Code
              AND   a.inventory_location_id = b.secondary_locator
              AND   a.alias = p_alias
              -- AND   a.concatenated_segments = nvl(p_suggestion, a.concatenated_segments)
              AND   a.inventory_location_id=NVL(a.physical_location_id,a.inventory_location_id)
            /* BUG#28101405: To show only common locators in the LOV */
             ORDER BY 2;

          ELSE --Locators not restricted
             --bug#3440453 Remove the NVL on organization_id if user passes it.
             IF p_organization_id IS NULL THEN
               OPEN x_Locators FOR
                 SELECT inventory_location_id,
                       -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                        locator_segments locsegs,
                        description
                 FROM   wms_item_locations_kfv
                 WHERE  organization_id = Nvl(p_organization_id, organization_id)
                 AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                 AND    alias = p_alias
                 AND    inventory_location_id=nvl(physical_location_id,inventory_location_id)
                 -- AND    concatenated_segments = nvl(p_suggestion, concatenated_segments)
                 ORDER BY 2;
             ELSE -- Organization_id is not null
                OPEN x_Locators FOR
                  SELECT inventory_location_id,
                         --concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                         locator_segments locsegs,
                         description
                  FROM   wms_item_locations_kfv
                  WHERE  organization_id = p_organization_id
                  AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                  AND    alias = p_alias
                  -- AND    concatenated_segments = nvl(p_suggestion, concatenated_segments)
                  AND    inventory_location_id=nvl(physical_location_id,inventory_location_id)
                  ORDER BY 2;
             END IF;
          END IF;
       END IF;
  END IF;
END get_inq_prj_loc_lov;





PROCEDURE get_inq_prj_loc_lov_nvl
   (x_Locators                OUT  NOCOPY t_genref,
    p_Organization_Id         IN   NUMBER,
    p_Subinventory_Code       IN   VARCHAR2,
    p_Restrict_Locators_Code  IN   NUMBER,
    p_Inventory_Item_Id       IN   NUMBER,
    p_Concatenated_Segments   IN   VARCHAR2,
    p_project_id              IN   NUMBER := NULL,
    p_task_id                 IN   NUMBER := NULL)
IS
  l_ispjm_org VARCHAR2(1);
BEGIN
   BEGIN
    SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
     INTO l_ispjm_org
    FROM pjm_org_parameters
       WHERE organization_id=p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
    END;

    IF l_ispjm_org='N'  THEN   /*Non PJM Org*/
       IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
             OPEN x_Locators FOR
              SELECT a.inventory_location_id,
                     --a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                     a.locator_segments locsegs,
                     a.description
               FROM  wms_item_locations_kfv a,
                     mtl_secondary_locators b
              WHERE b.organization_id = p_Organization_Id
               AND  b.inventory_item_id = nvl(p_Inventory_Item_Id, b.inventory_item_id)
               AND  b.subinventory_code = p_Subinventory_Code
               AND  a.inventory_location_id = b.secondary_locator
               AND  a.concatenated_segments LIKE (p_concatenated_segments )
             /* BUG#28101405: To show only common locators in the LOV */
              ORDER BY 2;
           ELSE --Locators not restricted
              --bug#3440453 Remove the NVL on organization_id if user passes it.
              IF p_organization_id IS NULL THEN
                OPEN x_Locators FOR
                  SELECT inventory_location_id,
                         --concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                         locator_segments locsegs,
                         description
                  FROM   wms_item_locations_kfv
                  WHERE  organization_id = Nvl(p_organization_id, organization_id)
                  AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                  AND    concatenated_segments LIKE (p_concatenated_segments )
                  ORDER BY 2;
              ELSE  -- Organization_id is not null
                 OPEN x_Locators FOR
                   SELECT inventory_location_id,
                         -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                          locator_segments locsegs,
                          description
                   FROM   wms_item_locations_kfv
                   WHERE  organization_id = p_organization_id
                   AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                   AND    concatenated_segments LIKE (p_concatenated_segments )
                   ORDER BY 2;
              END IF;
           END IF;
    ELSE /*PJM org*/
      IF p_project_id IS NOT NULL THEN

         IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
           OPEN x_Locators FOR
            SELECT a.inventory_location_id,
                   --a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                   a.locator_segments locsegs,
                   a.description
             FROM  wms_item_locations_kfv a,
                   mtl_secondary_locators b
            WHERE b.organization_id = p_Organization_Id
             AND   b.inventory_item_id = nvl(p_Inventory_Item_Id, b.inventory_item_id)
             AND   b.subinventory_code = p_Subinventory_Code
             AND   a.inventory_location_id = b.secondary_locator
             AND   a.concatenated_segments LIKE (p_concatenated_segments )
       /* BUG#28101405: To show only common locators in the LOV */
             AND   a.project_id = p_project_id
             AND   NVL(a.task_id, -9999)    = NVL(p_task_id, -9999)
            ORDER BY 2;

         ELSE --Locators not restricted
            --bug#3440453 Remove the NVL on organization_id if user passes it.
            IF p_organization_id IS NULL THEN
              OPEN x_Locators FOR
                SELECT inventory_location_id,
                       --concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                       locator_segments locsegs,
                       description
                FROM   wms_item_locations_kfv
                WHERE  organization_id = Nvl(p_organization_id, organization_id)
                AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                AND    concatenated_segments LIKE (p_concatenated_segments )
                AND    project_id = p_project_id
                AND    NVL(task_id, -1)       = NVL(p_task_id, -1)
               ORDER BY 2;
            ELSE  -- Organization_id is not null
               OPEN x_Locators FOR
                 SELECT inventory_location_id,
                       -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                        locator_segments locsegs,
                        description
                 FROM   wms_item_locations_kfv
                 WHERE  organization_id = p_organization_id
                 AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                 AND    concatenated_segments LIKE (p_concatenated_segments )
                 AND    project_id = p_project_id
                 AND    NVL(task_id, -1)       = NVL(p_task_id, -1)
                ORDER BY 2;
            END IF;
         END IF;

      ELSE /*PJM org project id null*/

          IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
            OPEN x_Locators FOR
             SELECT a.inventory_location_id,
                    --a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                    a.locator_segments locsegs,
                    a.description
              FROM  wms_item_locations_kfv a,
                    mtl_secondary_locators b
             WHERE  b.organization_id = p_Organization_Id
              AND   b.inventory_item_id = nvl(p_Inventory_Item_Id, b.inventory_item_id)
              AND   b.subinventory_code = p_Subinventory_Code
              AND   a.inventory_location_id = b.secondary_locator
              AND   a.concatenated_segments LIKE (p_concatenated_segments )
              AND   a.inventory_location_id=NVL(a.physical_location_id,a.inventory_location_id)
            /* BUG#28101405: To show only common locators in the LOV */
             ORDER BY 2;

          ELSE --Locators not restricted
             --bug#3440453 Remove the NVL on organization_id if user passes it.
             IF p_organization_id IS NULL THEN
               OPEN x_Locators FOR
                 SELECT inventory_location_id,
                        --concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                        locator_segments locsegs,
                        description
                 FROM   wms_item_locations_kfv
                 WHERE  organization_id = Nvl(p_organization_id, organization_id)
                 AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                 AND    concatenated_segments LIKE (p_concatenated_segments )
                 AND    inventory_location_id=nvl(physical_location_id,inventory_location_id)
                 ORDER BY 2;
             ELSE -- Organization_id is not null
                OPEN x_Locators FOR
                  SELECT inventory_location_id,
                        -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                         locator_segments locsegs,
                         description
                  FROM   wms_item_locations_kfv
                  WHERE  organization_id = p_organization_id
                  AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                  AND    concatenated_segments LIKE (p_concatenated_segments )
                  AND    inventory_location_id=nvl(physical_location_id,inventory_location_id)
                  ORDER BY 2;
             END IF;
          END IF;
       END IF;
  END IF;
END get_inq_prj_loc_lov_nvl;
PROCEDURE get_inq_prj_loc_lov_nvl(
          x_Locators                OUT  NOCOPY t_genref,
          p_Organization_Id         IN   NUMBER,
          p_Subinventory_Code       IN   VARCHAR2,
          p_Restrict_Locators_Code  IN   NUMBER,
          p_Inventory_Item_Id       IN   NUMBER,
          p_Concatenated_Segments   IN   VARCHAR2,
          p_project_id              IN   NUMBER := NULL,
          p_task_id                 IN   NUMBER := NULL,
          p_alias                   IN   VARCHAR2)
IS
  l_ispjm_org VARCHAR2(1);
BEGIN
   IF p_alias IS NULL THEN
      get_inq_prj_loc_lov_nvl(
           x_Locators                => x_locators
          ,p_Organization_Id         => p_organization_id
          ,p_Subinventory_Code       => p_subinventory_code
          ,p_Restrict_Locators_Code  => p_restrict_locators_code
          ,p_Inventory_Item_Id       => p_inventory_item_id
          ,p_Concatenated_Segments   => p_concatenated_segments
          ,p_project_id              => p_project_id
          ,p_task_id                 => p_task_id
          );
      RETURN;
   END IF;
   BEGIN
    SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
     INTO l_ispjm_org
    FROM pjm_org_parameters
       WHERE organization_id=p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
    END;

    IF l_ispjm_org='N'  THEN   /*Non PJM Org*/
       IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
             OPEN x_Locators FOR
              SELECT a.inventory_location_id,
                     --a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                     a.locator_segments locsegs,
                     a.description
               FROM  wms_item_locations_kfv a,
                     mtl_secondary_locators b
              WHERE b.organization_id = p_Organization_Id
               AND  b.inventory_item_id = nvl(p_Inventory_Item_Id, b.inventory_item_id)
               AND  b.subinventory_code = p_Subinventory_Code
               AND  a.inventory_location_id = b.secondary_locator
               AND  a.alias = p_alias
             /* BUG#28101405: To show only common locators in the LOV */
              ORDER BY 2;
           ELSE --Locators not restricted
              --bug#3440453 Remove the NVL on organization_id if user passes it.
              IF p_organization_id IS NULL THEN
                OPEN x_Locators FOR
                  SELECT inventory_location_id,
                         --concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                         locator_segments locsegs,
                         description
                  FROM   wms_item_locations_kfv
                  WHERE  organization_id = Nvl(p_organization_id, organization_id)
                  AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                  AND    alias = p_alias
                  ORDER BY 2;
              ELSE  -- Organization_id is not null
                 OPEN x_Locators FOR
                   SELECT inventory_location_id,
                         -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                          locator_segments locsegs,
                          description
                   FROM   wms_item_locations_kfv
                   WHERE  organization_id = p_organization_id
                   AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                   AND    alias = p_alias
                   ORDER BY 2;
              END IF;
           END IF;
    ELSE /*PJM org*/
      IF p_project_id IS NOT NULL THEN

         IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
           OPEN x_Locators FOR
            SELECT a.inventory_location_id,
                   --a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                   a.locator_segments locsegs,
                   a.description
             FROM  wms_item_locations_kfv a,
                   mtl_secondary_locators b
            WHERE b.organization_id = p_Organization_Id
             AND   b.inventory_item_id = nvl(p_Inventory_Item_Id, b.inventory_item_id)
             AND   b.subinventory_code = p_Subinventory_Code
             AND   a.inventory_location_id = b.secondary_locator
             AND   a.alias = p_alias
       /* BUG#28101405: To show only common locators in the LOV */
             AND   a.project_id = p_project_id
             AND   NVL(a.task_id, -9999)    = NVL(p_task_id, -9999)
            ORDER BY 2;

         ELSE --Locators not restricted
            --bug#3440453 Remove the NVL on organization_id if user passes it.
            IF p_organization_id IS NULL THEN
              OPEN x_Locators FOR
                SELECT inventory_location_id,
                       --concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                       locator_segments locsegs,
                       description
                FROM   wms_item_locations_kfv
                WHERE  organization_id = Nvl(p_organization_id, organization_id)
                AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                AND    alias = p_alias
                AND    project_id = p_project_id
                AND    NVL(task_id, -1)       = NVL(p_task_id, -1)
               ORDER BY 2;
            ELSE  -- Organization_id is not null
               OPEN x_Locators FOR
                 SELECT inventory_location_id,
                       -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                        locator_segments locsegs,
                        description
                 FROM   wms_item_locations_kfv
                 WHERE  organization_id = p_organization_id
                 AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                 AND    alias = p_alias
                 AND    project_id = p_project_id
                 AND    NVL(task_id, -1)       = NVL(p_task_id, -1)
                ORDER BY 2;
            END IF;
         END IF;

      ELSE /*PJM org project id null*/

          IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
            OPEN x_Locators FOR
             SELECT a.inventory_location_id,
                    --a.concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                    a.locator_segments locsegs,
                    a.description
              FROM  wms_item_locations_kfv a,
                    mtl_secondary_locators b
             WHERE  b.organization_id = p_Organization_Id
              AND   b.inventory_item_id = nvl(p_Inventory_Item_Id, b.inventory_item_id)
              AND   b.subinventory_code = p_Subinventory_Code
              AND   a.inventory_location_id = b.secondary_locator
              AND   a.alias = p_alias
              AND   a.inventory_location_id=NVL(a.physical_location_id,a.inventory_location_id)
            /* BUG#28101405: To show only common locators in the LOV */
             ORDER BY 2;

          ELSE --Locators not restricted
             --bug#3440453 Remove the NVL on organization_id if user passes it.
             IF p_organization_id IS NULL THEN
               OPEN x_Locators FOR
                 SELECT inventory_location_id,
                        --concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                        locator_segments locsegs,
                        description
                 FROM   wms_item_locations_kfv
                 WHERE  organization_id = Nvl(p_organization_id, organization_id)
                 AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                 AND    alias = p_alias
                 AND    inventory_location_id=nvl(physical_location_id,inventory_location_id)
                 ORDER BY 2;
             ELSE -- Organization_id is not null
                OPEN x_Locators FOR
                  SELECT inventory_location_id,
                        -- concatenated_segments locsegs,--Bug4398337:Commented this line and added below line
                         locator_segments locsegs,
                         description
                  FROM   wms_item_locations_kfv
                  WHERE  organization_id = p_organization_id
                  AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
                  AND    alias = p_alias
                  AND    inventory_location_id=nvl(physical_location_id,inventory_location_id)
                  ORDER BY 2;
             END IF;
          END IF;
       END IF;
  END IF;
END get_inq_prj_loc_lov_nvl;




/*Bug #3075665 - FOR PATCHSET J PROJECT - ADVANCED PICK LOAD
 * This procedure gets the locator details - concat segs, loc desc,
 * project, task, sub for a given org id, loc id.
 * The procedure also returns if the given locator exists or not.
 */
PROCEDURE GET_PICKLOAD_LOC_DETAILS(
    p_organization_id        IN              NUMBER
  , p_inventory_location_id  IN              NUMBER
  , x_subinventory_code      OUT NOCOPY      VARCHAR2
  , x_concatenated_segments  OUT NOCOPY      VARCHAR2
  , x_description            OUT NOCOPY      VARCHAR2
  , x_project_id             OUT NOCOPY      NUMBER
  , x_task_id                OUT NOCOPY      NUMBER
  , x_loc_exists             OUT NOCOPY      VARCHAR
  , x_msg_count                 OUT NOCOPY      NUMBER
  , x_msg_data               OUT NOCOPY      VARCHAR2
  , x_return_status            OUT NOCOPY      VARCHAR2  ) IS
BEGIN
   x_loc_exists := 'Y';
   BEGIN
   DEBUG('INV_UI_ITEM_SUB_LOC_LOVS.GET_PICKLOAD_LOC_DETAILS');
   DEBUG('p_inventory_location_id   -> '||p_inventory_location_id);
   DEBUG('p_organization_id         -> '||p_organization_id);
    SELECT subinventory_code
         , CONCATENATED_SEGMENTS
         , DESCRIPTION
         , project_id
         , task_id
      INTO x_subinventory_code
         , x_concatenated_segments
         , x_description
         , x_project_id
         , x_task_id
      FROM wms_item_locations_kfv
     WHERE inventory_location_id = p_inventory_location_id
       AND organization_id = p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND  THEN
         x_loc_exists := 'N';
    END;

    IF(x_subinventory_code IS NULL) THEN
      x_loc_exists := 'N';
    END IF;
    DEBUG('x_loc_exists             -> '||x_loc_exists);

END GET_PICKLOAD_LOC_DETAILS;



--
----------------------------------
--  Name:  GET_LOCATION_TYPE_LOCATORS
--         To query locators of a sub and org without status check
--         that is also filtered by mtl_item_locations.inventory_location_type
--  Input Parameter:
--    p_organization_id:        Organization ID
--    p_subinventory_code       Sub
--    p_inventory_location_type Location Type: Dock Door, Staging, Storage
--    p_concatenated_segments   LOV
--
PROCEDURE Get_Location_Type_Locators(
  x_locators                OUT    NOCOPY t_genref
, p_organization_id         IN     NUMBER
, p_subinventory_code       IN     VARCHAR2
, p_inventory_location_type IN     NUMBER
, p_concatenated_segments   IN     VARCHAR2
) IS
  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_ispjm_org VARCHAR2(1);
BEGIN
  BEGIN
    SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
    INTO l_ispjm_org
    FROM pjm_org_parameters
    WHERE organization_id=p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND  THEN
        l_ispjm_org:='N';
  END;

  IF ( l_ispjm_org = 'N' )THEN
    OPEN x_Locators FOR
      SELECT inventory_location_id
           , locator_segments locsegs
           , description
      FROM   wms_item_locations_kfv
      WHERE  organization_id = p_organization_id
      AND    subinventory_code = NVL(p_Subinventory_Code ,subinventory_code)
      AND    inventory_location_type = p_inventory_location_type
      AND    NVL(disable_date, trunc(sysdate+1)) > trunc(sysdate)
      AND    concatenated_segments LIKE (p_concatenated_segments)
      ORDER BY 2;
  ELSE --PJM Org
    OPEN x_Locators FOR
      SELECT inventory_location_id
           , locator_segments locsegs
           , description
      FROM   wms_item_locations_kfv
      WHERE  organization_id = p_organization_id
      AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
      AND    inventory_location_type = p_inventory_location_type
      AND    NVL(disable_date, trunc(sysdate+1)) > trunc(sysdate)
      AND    concatenated_segments LIKE (p_concatenated_segments )
      AND    inventory_location_id = NVL(physical_location_id,inventory_location_id)
      ORDER BY 2;
  END IF;
END Get_Location_Type_Locators;

PROCEDURE Get_Location_Type_Locators(
  x_locators                OUT    NOCOPY t_genref
, p_organization_id         IN     NUMBER
, p_subinventory_code       IN     VARCHAR2
, p_inventory_location_type IN     NUMBER
, p_concatenated_segments   IN     VARCHAR2
, p_alias                   IN     VARCHAR2
) IS
  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_ispjm_org VARCHAR2(1);
BEGIN

   IF p_alias IS NULL THEN
      Get_Location_Type_Locators(
             x_locators                => x_locators
           , p_organization_id         => p_organization_id
           , p_subinventory_code       => p_subinventory_code
           , p_inventory_location_type => p_inventory_location_type
           , p_concatenated_segments   => p_concatenated_segments
           );
      RETURN;
   END IF;
  BEGIN
    SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
    INTO l_ispjm_org
    FROM pjm_org_parameters
    WHERE organization_id=p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND  THEN
        l_ispjm_org:='N';
  END;

  IF ( l_ispjm_org = 'N' )THEN
    OPEN x_Locators FOR
      SELECT inventory_location_id
           , locator_segments locsegs
           , description
      FROM   wms_item_locations_kfv
      WHERE  organization_id = p_organization_id
      AND    subinventory_code = NVL(p_Subinventory_Code ,subinventory_code)
      AND    inventory_location_type = p_inventory_location_type
      AND    NVL(disable_date, trunc(sysdate+1)) > trunc(sysdate)
      AND    alias = p_alias
      ORDER BY 2;
  ELSE --PJM Org
    OPEN x_Locators FOR
      SELECT inventory_location_id
           , locator_segments locsegs
           , description
      FROM   wms_item_locations_kfv
      WHERE  organization_id = p_organization_id
      AND    subinventory_code = Nvl(p_Subinventory_Code ,subinventory_code)
      AND    inventory_location_type = p_inventory_location_type
      AND    NVL(disable_date, trunc(sysdate+1)) > trunc(sysdate)
      AND    inventory_location_id = NVL(physical_location_id,inventory_location_id)
      AND    alias = p_alias
      ORDER BY 2;
  END IF;
END Get_Location_Type_Locators;

   PROCEDURE get_value_from_alias(
             x_return_status OUT NOCOPY VARCHAR2
            ,x_msg_data      OUT NOCOPY VARCHAR2
            ,x_msg_count     OUT NOCOPY NUMBER
            ,x_match         OUT NOCOPY VARCHAR2
            ,x_value         OUT NOCOPY VARCHAR2
            ,p_org_id        IN  NUMBER
            ,p_sub_code      IN  VARCHAR2
            ,p_alias         IN  VARCHAR2
            ,p_suggested     IN  VARCHAR2
            ) IS
   BEGIN

      x_return_status := 'S';
      x_value         := NULL;
      x_match         := NULL;
      x_msg_data      := NULL;
      x_msg_count     := 0;

      SELECT locator_segments
      INTO   x_value
      FROM   wms_item_locations_kfv
      WHERE  alias = p_alias
      AND    organization_id = p_org_id
      AND    subinventory_code = p_sub_code
      AND    project_id IS NULL
      AND    task_id IS NULL;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_match := 'NONE';
      WHEN TOO_MANY_ROWS THEN
         IF p_suggested IS NOT NULL THEN
            BEGIN
               SELECT locator_segments
               INTO   x_value
               FROM   wms_item_locations_kfv
               WHERE  alias = p_alias
               AND    organization_id = p_org_id
               AND    subinventory_code = p_sub_code
               AND    locator_segments = p_suggested
               AND    project_id IS NULL
               AND    task_id IS NULL;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  x_match := 'MULTIPLE';
               WHEN OTHERS THEN
                  x_return_status := 'U';
                  x_value         := NULL;
                  x_match         := NULL;
                  x_msg_data      := SQLERRM;
                  x_msg_count     := 1;
            END;
         ELSE
            x_match := 'MULTIPLE';
         END IF;
      WHEN OTHERS THEN
         x_return_status := 'U';
         x_value         := NULL;
         x_match         := NULL;
         x_msg_data      := SQLERRM;
         x_msg_count     := 1;
   END get_value_from_alias;

   /* Added following procdure for bug 8237335 */
   PROCEDURE get_prj_to_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  ) IS
    x_return_status VARCHAR2(100);
    x_display       VARCHAR2(100);
    x_project_col   NUMBER;
    x_task_col      NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_ispjm_org VARCHAR2(1);
    l_sub_type      NUMBER;
BEGIN
   debug('Inside  INV_UI_ITEM_SUB_LOC_LOVS.get_prj_to_loc_lov');
   debug('p_organization_id : ' || p_organization_id);
   debug('p_subinventory_code : ' || p_subinventory_code);
   debug('p_restrict_locators_code : ' || p_restrict_locators_code);
   debug('p_inventory_item_id : ' || p_inventory_item_id);
   debug('p_concatenated_segments : ' || p_concatenated_segments);
   debug('p_transaction_type_id : ' || p_transaction_type_id);
   debug('p_wms_installed : ' || p_wms_installed);
   debug('p_project_id : ' || p_project_id);
   debug('p_task_id : ' || p_task_id);

   BEGIN
    SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
    INTO l_ispjm_org
    FROM pjm_org_parameters
       WHERE organization_id=p_organization_id;
    EXCEPTION
       WHEN NO_DATA_FOUND  THEN
         l_ispjm_org:='N';
   END;
   debug('l_ispjm_org : ' || l_ispjm_org);

      BEGIN
      SELECT Nvl(subinventory_type,1)
   INTO l_sub_type
   FROM mtl_secondary_inventories
       WHERE secondary_inventory_name = p_subinventory_code
   AND  organization_id = p_organization_id;
   EXCEPTION
      WHEN OTHERS THEN
    l_sub_type := 1;
      END;
    debug('l_sub_type : ' || l_sub_type);

IF l_ispjm_org='N' THEN /*Non PJM Org*/
   IF p_Restrict_Locators_Code = 1 AND l_sub_type = 1 THEN --Locators restricted to predefined list
        OPEN x_Locators FOR
          select a.inventory_location_id,
                 a.locator_segments concatenated_segments,
                 nvl( a.description, -1)
          FROM wms_item_locations_kfv a,mtl_secondary_locators b
          WHERE b.organization_id = p_Organization_Id
          AND  b.inventory_item_id = p_Inventory_Item_Id
          AND nvl(a.disable_date, trunc(sysdate+1)) > trunc(sysdate)
          AND  b.subinventory_code = p_Subinventory_Code
          AND a.inventory_location_id = b.secondary_locator
          AND a.concatenated_segments LIKE (p_concatenated_segments)
          ORDER BY 2;
       ELSE --Locators not restricted
        OPEN x_Locators FOR
          select inventory_location_id,
                 locator_segments concatenated_segments,
                 description
          FROM wms_item_locations_kfv
          WHERE organization_id = p_Organization_Id
          AND subinventory_code = p_Subinventory_Code
          AND nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate)
          AND concatenated_segments LIKE (p_concatenated_segments )
          ORDER BY 2;
       END IF;
  ELSE /*PJM org*/
    IF p_Restrict_Locators_Code = 1 AND l_sub_type = 1 THEN --Locators restricted to predefined list
       OPEN x_Locators FOR
        select a.inventory_location_id,
               a.locator_segments concatenated_segments,
              nvl( a.description, -1)
        FROM wms_item_locations_kfv a,mtl_secondary_locators b
        WHERE b.organization_id = p_Organization_Id
        AND  b.inventory_item_id = p_Inventory_Item_Id
        AND nvl(a.disable_date, trunc(sysdate+1)) > trunc(sysdate)
        AND  b.subinventory_code = p_Subinventory_Code
        AND a.inventory_location_id = b.secondary_locator
        AND a.inventory_location_id=nvl(a.physical_location_id,a.inventory_location_id)
        AND a.concatenated_segments like (p_concatenated_segments )
        ORDER BY 2;
     ELSE --Locators not restricted
       OPEN x_Locators FOR
         select inventory_location_id,
                locator_segments concatenated_segments,
               description
         FROM wms_item_locations_kfv
         WHERE organization_id = p_Organization_Id
         AND subinventory_code = p_Subinventory_Code
         AND nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate)
         AND inventory_location_id=NVL(physical_location_id,inventory_location_id)
         AND concatenated_segments LIKE (p_concatenated_segments )
         ORDER BY 2;
     END IF;
    END IF;
END get_prj_to_loc_lov;

/*9022877*/
PROCEDURE get_restricted_subs(
            x_zones             OUT NOCOPY t_genref
          , p_organization_id   IN  NUMBER
          , p_subinventory_code IN  VARCHAR2
          , p_inventory_item_id IN  NUMBER
          ) IS
BEGIN
   OPEN x_zones FOR
        SELECT   secondary_inventory_name
               , NVL(locator_type, 1)
               , description
               , asset_inventory
               , lpn_controlled_flag
               , enable_locator_alias
            FROM mtl_secondary_inventories msi,
                 mtl_item_sub_inventories  misi
           WHERE msi.organization_id          = p_organization_id
             AND msi.organization_id          = misi.organization_id
             AND msi.secondary_inventory_name = misi.secondary_inventory
             AND misi.inventory_item_id = p_inventory_item_id
             AND NVL(msi.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
             AND msi.secondary_inventory_name LIKE (p_subinventory_code)
        ORDER BY secondary_inventory_name;
END get_restricted_subs;


END inv_ui_item_sub_loc_lovs;

/
