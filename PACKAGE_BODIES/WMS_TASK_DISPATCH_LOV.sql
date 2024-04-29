--------------------------------------------------------
--  DDL for Package Body WMS_TASK_DISPATCH_LOV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TASK_DISPATCH_LOV" AS
/* $Header: WMSTSKLB.pls 120.14.12010000.3 2010/03/26 10:02:11 kjujjuru ship $ */


--  Global constant holding the package name

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'WMS_Task_Dispatch_LOV';
g_gtin_cross_ref_type VARCHAR2(25) := fnd_profile.value('INV:GTIN_CROSS_REFERENCE_TYPE');
g_gtin_code_length NUMBER := 14;


PROCEDURE mydebug(msg in varchar2)
  IS
     l_msg VARCHAR2(5100);
     l_ts VARCHAR2(30);
BEGIN
--   select to_char(sysdate,'MM/DD/YYYY HH:MM:SS') INTO l_ts from dual;
--   l_msg:=l_ts||'  '||msg;

   l_msg := msg;

   inv_mobile_helper_functions.tracelog
     (p_err_msg => l_msg,
      p_module => 'WMS_Task_Dispatch_LOV',
      p_level => 4);

   --dbms_output.put_line(l_msg);

   null;
END;



PROCEDURE get_tasks_lov
( x_tasks            OUT NOCOPY  t_genref
, p_Organization_Id  IN          NUMBER
, p_User_Id          IN          NUMBER
, p_concat_segments  IN          VARCHAR2
, p_page_type        IN          VARCHAR2
)
IS
   l_wms_po_j_or_higher NUMBER := 0;
BEGIN
   IF ((WMS_UI_TASKS_APIS.g_wms_patch_level >= WMS_UI_TASKS_APIS.g_patchset_j) AND
       (WMS_UI_TASKS_APIS.g_po_patch_level >= WMS_UI_TASKS_APIS.g_patchset_j_po)) THEN
      l_wms_po_j_or_higher := 1;
   END IF;

   IF p_page_type = 'SYSTEM_DROP'
   THEN
      OPEN x_tasks FOR
      -- Putaway J or higher
      SELECT ' '                      status
           , wlpn1.license_plate_number   lpn
           , 'PUTAWAY'                task_type
           , 'NORMAL'                 task_mo_status
           , ''                    to_sub
           , ''                    to_loc
           , ''                    item
           , To_number(NULL)       transaction_quantity
           , ''                    transaction_uom
           , wlpn1.lpn_id
           , To_number(NULL)       taskid
           , wlpn1.lpn_context
           , 'FALSE'  is_bulk_pick
           , 1                     dummy_sort
        FROM wms_license_plate_numbers wlpn1
        WHERE wlpn1.license_plate_number LIKE p_concat_segments
        START WITH
        wlpn1.lpn_id IN (SELECT DISTINCT wlpn2.outermost_lpn_id
                         FROM mtl_material_transactions_temp mmtt,
                         wms_dispatched_tasks wdt,
                         wms_license_plate_numbers wlpn2
                         WHERE  l_wms_po_j_or_higher = 1
                         AND    mmtt.organization_id = p_organization_id
                         AND    mmtt.transaction_temp_id = wdt.transaction_temp_id
                         AND    wdt.organization_id = p_organization_id
                         AND    wdt.task_type = 2
                         AND    wdt.status = 4
                         AND    wdt.person_id = p_user_id
                         AND    wlpn2.lpn_id = mmtt.lpn_id)
        CONNECT BY PRIOR wlpn1.lpn_id = wlpn1.parent_lpn_id
      UNION ALL
      -- Picking, replenishment and move order transfers
      SELECT /*+ ORDERED */
             DECODE( m.parent_line_id
                   , NULL, DECODE( mtrl.line_status
                                 , 6,'*'
                                 , 9, '*'
                                 , ' '
                                 )
                   , ' '
                   ) status
           , l.license_plate_number   lpn
           , DECODE( m.parent_line_id
                   , NULL, DECODE( m.transaction_type_ID
                                 , 35,'WIP_PICKING'
                                 , DECODE( w.task_type
                                         , 1,'PICKING'
                                         , 5,'MOXFER'
                                         , 'REPLENISHMENT'
                                         )
                                 )
                   , 'PICKING'
                   ) task_type
           , DECODE( m.parent_line_id
                   , NULL, DECODE( mtrl.line_status
                                 , 6,'CANCELLED'
                                 , 9,'CANCELLED'
                                 , 'NORMAL'
                                 )
                   , 'NORMAL'
                   ) task_mo_status
           , DECODE( m.parent_line_id
                   , NULL, m.transfer_subinventory
                   , NULL
                   ) to_sub
           , DECODE( m.parent_line_id
                   , NULL, get_locator( m.wms_task_type
                                      , m.locator_id
                                      , m.transfer_to_location
                                      , m.transaction_type_id
                                      , m.organization_id
                                      )
                   , NULL
                   ) to_loc
           , i.concatenated_segments  item
           , m.transaction_quantity
           , m.transaction_uom
           , m.transfer_lpn_id        lpn_id
           , m.transaction_temp_id    taskid
           , l.lpn_context
           , DECODE( m.parent_line_id
                   , NULL, 'FALSE'
                   , 'TRUE'
                   ) is_bulk_pick
           , 2                        dummy_sort
        FROM wms_dispatched_tasks            w
           , mtl_material_transactions_temp  m
           , mtl_system_items_kfv            i
           , wms_license_plate_numbers       l
           , mtl_txn_request_lines           mtrl
       WHERE w.person_id            = p_user_id
         AND w.organization_id      = p_organization_id
         AND w.status               = 4
         AND w.transaction_temp_id  = m.transaction_temp_id
         AND m.organization_id      = i.organization_id
         AND m.inventory_item_id    = i.inventory_item_id
         AND m.organization_id      = l.organization_id
         AND w.task_type           IN (1,4,5)
         AND m.transfer_lpn_id      = l.lpn_id
         AND m.move_order_line_id   = mtrl.line_id (+)
         --Bug 6891745
         AND decode(l.lpn_context, 8 , l.lpn_id, l.outermost_lpn_id) = l.outermost_lpn_id
         AND (m.parent_line_id     IS NULL
               OR
               (m.parent_line_id   IS NOT NULL
                AND
                m.parent_line_id    = m.transaction_temp_id
               )
             )
         AND l.license_plate_number LIKE (p_concat_segments)
     /* MRANA - MDC  Staging drop should not be supported using Current task Page*/
      /*  UNION ALL
      -- Staging moves
      SELECT ' '                      status
           , l.license_plate_number   lpn
           , 'STAGING MOVE'           task_type
           , 'NORMAL'                 task_mo_status
           , m.transfer_subinventory  to_sub
           , get_locator( m.wms_task_type
                        , m.locator_id
                        , m.transfer_to_location
                        , m.transaction_type_id
                        , m.organization_id
                        ) to_loc
           , i.concatenated_segments  item
           , to_number(null)          transaction_quantity
           , to_char(null)            transaction_uom
           , m.transfer_lpn_id        lpn_id
           , m.transaction_temp_id    taskid
           , l.lpn_context
           , 'FALSE'                  is_bulk_pick
           , 3                        dummy_sort
        FROM wms_dispatched_tasks            w
           , mtl_material_transactions_temp  m
           , mtl_system_items_kfv            i
           , wms_license_plate_numbers       l
       WHERE w.person_id            = p_user_id
         AND w.organization_id      = p_organization_id
         AND w.status               = 4
         AND w.transaction_temp_id  = m.transaction_temp_id
         AND m.organization_id      = i.organization_id
         AND m.inventory_item_id    = i.inventory_item_id
         AND m.organization_id      = l.organization_id
         AND w.task_type            = 7
         AND m.transfer_lpn_id      = l.lpn_id
         AND l.license_plate_number LIKE (p_concat_segments)
       ORDER BY task_type
              , to_sub
              , to_loc
              , lpn;  MRANA - MDC */
      -- dummy_sort not used for ordering SYSTEM_DROP tasks
      --Added UNION for bug 6682436
      UNION ALL

     SELECT /*+ ORDERED */
             DECODE( m.parent_line_id
                   , NULL, DECODE( mtrl.line_status
                                 , 6,'*'
                                 , 9, '*'
                                 , ' '
                                 )
                   , ' '
                   ) status
           , l.license_plate_number   lpn
           , DECODE( m.parent_line_id
                   , NULL, DECODE( m.transaction_type_ID
                                 , 35,'WIP_PICKING'
                                 , DECODE( w.task_type
                                         , 1,'PICKING'
                                         , 5,'MOXFER'
                                         , 'REPLENISHMENT'
                                         )
                                 )
                   , 'PICKING'
                   ) task_type
           , DECODE( m.parent_line_id
                   , NULL, DECODE( mtrl.line_status
                                 , 6,'CANCELLED'
                                 , 9,'CANCELLED'
                                 , 'NORMAL'
                                 )
                   , 'NORMAL'
                   ) task_mo_status
           , DECODE( m.parent_line_id
                   , NULL, m.transfer_subinventory
                   , NULL
                   ) to_sub
           , DECODE( m.parent_line_id
                   , NULL, get_locator( m.wms_task_type
                                      , m.locator_id
                                      , m.transfer_to_location
                                      , m.transaction_type_id
                                      , m.organization_id
                                      )
                   , NULL
                   ) to_loc
           , i.concatenated_segments  item
           , m.transaction_quantity
           , m.transaction_uom
           , l.lpn_id               lpn_id    /*modified for bug 6717052*/
           , m.transaction_temp_id    taskid
           , l.lpn_context
           , DECODE( m.parent_line_id
                   , NULL, 'FALSE'
                   , 'TRUE'
                   ) is_bulk_pick
           , 2                        dummy_sort
        FROM wms_dispatched_tasks            w
           , mtl_material_transactions_temp  m
           , mtl_system_items_kfv            i
           , wms_license_plate_numbers       l
           , mtl_txn_request_lines           mtrl
       WHERE w.person_id            = p_user_id
         AND w.organization_id      = p_organization_id
         AND w.status               = 4
         AND w.transaction_temp_id  = m.transaction_temp_id
         AND m.organization_id      = i.organization_id
         AND m.inventory_item_id    = i.inventory_item_id
         AND m.organization_id      = l.organization_id
         AND w.task_type           IN (1,4,5)
         AND l.lpn_id  IN  (SELECT DISTINCT(wlpn1.outermost_lpn_id) FROM wms_license_plate_numbers wlpn1 WHERE wlpn1.lpn_id = m.transfer_lpn_id AND wlpn1.lpn_id <> wlpn1.outermost_lpn_id)
         AND m.move_order_line_id   = mtrl.line_id (+)
         AND (m.parent_line_id     IS NULL
               OR
               (m.parent_line_id   IS NOT NULL
                AND
                m.parent_line_id    = m.transaction_temp_id
               )
             )
         AND l.license_plate_number LIKE (p_concat_segments);
   ELSE
      OPEN x_tasks FOR
      -- Putaway J or higher
      SELECT ' '                      status
           , wlpn1.license_plate_number   lpn
           , 'PUTAWAY'                task_type
           , 'NORMAL'                 task_mo_status
           , ''                    to_sub
           , ''                    to_loc
           , ''                    item
           , To_number(NULL)       transaction_quantity
           , ''                    transaction_uom
           , wlpn1.lpn_id
           , To_number(NULL)       taskid
           , wlpn1.lpn_context
           , 'FALSE'  is_bulk_pick
           , 1                     dummy_sort
        FROM wms_license_plate_numbers wlpn1
        WHERE wlpn1.license_plate_number LIKE p_concat_segments
        START WITH
        wlpn1.lpn_id IN (SELECT DISTINCT wlpn2.outermost_lpn_id
                         FROM mtl_material_transactions_temp mmtt,
                         wms_dispatched_tasks wdt,
                         wms_license_plate_numbers wlpn2
                         WHERE  l_wms_po_j_or_higher = 1
                         AND    (p_page_type IS NULL OR p_page_type <> 'MANUAL_UNLOAD')
                         AND    mmtt.organization_id = p_organization_id
                         AND    mmtt.transaction_temp_id = wdt.transaction_temp_id
                         AND    wdt.organization_id = p_organization_id
                         AND    wdt.task_type = 2
                         AND    wdt.status = 4
                         AND    wdt.person_id = p_user_id
                         AND    wlpn2.lpn_id = mmtt.lpn_id)
        CONNECT BY PRIOR wlpn1.lpn_id = wlpn1.parent_lpn_id
        UNION ALL
        -- Putaway for I or lower
        SELECT /*+ ORDERED */
        ' '                      status
        , l.license_plate_number   lpn
        , 'PUTAWAY'                task_type
        , 'NORMAL'                 task_mo_status
        , m.subinventory_code      to_sub
        , Decode(m.transfer_to_location,
                 NULL,
                 Decode(m.locator_id,
                        NULL,
                        -- In the case of load, the transfer_to_location
                        -- AND locator_id will be null. So no need to
                        -- call get_locator.
                        Decode(l_wms_po_j_or_higher,
                               1,
                               NULL,
                               get_locator( m.wms_task_type
                                            , m.locator_id
                                            , m.transfer_to_location
                                            , m.transaction_type_id
                                            , m.organization_id
                                            )
                               ),
                        get_locator( m.wms_task_type
                                     , m.locator_id
                                     , m.transfer_to_location
                                     , m.transaction_type_id
                                     , m.organization_id
                                     )
                        ),
                 -- The transfer_to_location column is usually populated in
                 -- MMTT FOR putaway
                 get_locator( m.wms_task_type
                              , m.transfer_to_location
                              , m.transfer_to_location
                              , m.transaction_type_id
                              , m.organization_id
                              )
                 ) to_loc
        , i.concatenated_segments  item
        , m.transaction_quantity
        , m.transaction_uom
        , m.lpn_id
        , m.transaction_temp_id    taskid
        , l.lpn_context
        , 'FALSE'  is_bulk_pick
        , 1                        dummy_sort
        FROM wms_dispatched_tasks            w
        , mtl_material_transactions_temp  m
        , mtl_system_items_kfv            i
        , wms_license_plate_numbers       l
        , mtl_txn_request_lines           mtrl
        WHERE l_wms_po_j_or_higher <> 1
         AND w.person_id            = p_user_id
         AND w.organization_id      = p_organization_id
         AND w.status               = 4
         AND w.transaction_temp_id  = m.transaction_temp_id
         AND m.organization_id      = i.organization_id
         AND m.inventory_item_id    = i.inventory_item_id
         AND m.organization_id      = l.organization_id
         AND w.task_type            = 2
         AND m.lpn_id               = l.lpn_id
         AND m.move_order_line_id   = mtrl.line_id
         AND l.license_plate_number LIKE (p_concat_segments)
       UNION ALL
      -- Material packed into content LPNs
      SELECT /*+ ORDERED */
             DECODE( m.parent_line_id
                   , NULL, DECODE( mtrl.line_status
                                 , 6,'*'
                                 , 9, '*'
                                 , ' '
                                 )
                   , ' '
                   ) status
           , l.license_plate_number   lpn
           , DECODE( m.parent_line_id
                   , NULL, DECODE( m.transaction_type_ID
                                 , 35,'WIP_PICKING'
                                 , DECODE( w.task_type
                                         , 1,'PICKING'
                                         , 5,'MOXFER'
                                         , 'REPLENISHMENT'
                                         )
                                 )
                   , 'PICKING'
                   ) task_type
           , DECODE( m.parent_line_id
                   , NULL, DECODE( mtrl.line_status
                                 , 6,'CANCELLED'
                                 , 9,'CANCELLED'
                                 , 'NORMAL'
                                 )
                   , 'NORMAL'
                   ) task_mo_status
           , DECODE( m.parent_line_id
                   , NULL, m.transfer_subinventory
                   , NULL
                   ) to_sub
           , DECODE( m.parent_line_id
                   , NULL, get_locator( m.wms_task_type
                                      , m.locator_id
                                      , m.transfer_to_location
                                      , m.transaction_type_id
                                      , m.organization_id
                                      )
                   , NULL
                   ) to_loc
           , i.concatenated_segments  item
           , m.transaction_quantity
           , m.transaction_uom
           , m.transfer_lpn_id        lpn_id
           , m.transaction_temp_id    taskid
           , l.lpn_context
           , DECODE( m.parent_line_id
                   , NULL, 'FALSE'
                   , 'TRUE'
                   ) is_bulk_pick
           , 2                        dummy_sort
        FROM wms_dispatched_tasks            w
           , mtl_material_transactions_temp  m
           , mtl_system_items_kfv            i
           , wms_license_plate_numbers       l
           , mtl_txn_request_lines           mtrl
       WHERE w.person_id            = p_user_id
         AND w.organization_id      = p_organization_id
         AND w.status               = 4
         AND w.transaction_temp_id  = m.transaction_temp_id
         AND m.organization_id      = i.organization_id
         AND m.inventory_item_id    = i.inventory_item_id
         AND m.organization_id      = l.organization_id
         AND w.task_type           IN (1,4,5)
         AND m.transfer_lpn_id      = l.lpn_id
         AND m.move_order_line_id   = mtrl.line_id (+)
          --Bug 6891745
         AND decode(l.lpn_context, 8 , l.lpn_id, l.outermost_lpn_id) = l.outermost_lpn_id
         AND (m.parent_line_id     IS NULL
               OR
               (m.parent_line_id   IS NOT NULL
                AND
                m.parent_line_id    = m.transaction_temp_id
               )
             )
         AND EXISTS
           ( SELECT 'x'
               FROM mtl_material_transactions_temp  m2
              WHERE m2.transfer_lpn_id      = m.transfer_lpn_id
                AND m2.organization_id      = m.organization_id
                AND m2.content_lpn_id       = m.transfer_lpn_id
                AND m2.transaction_temp_id <> m.transaction_temp_id
                AND DECODE( m2.parent_line_id
                          , NULL, 0
                          , m2.transaction_temp_id, 1
                          , 2
                          )                 = DECODE( m.parent_line_id
                                                    , NULL, 0
                                                    , 1
                                                    )
           )
         AND l.license_plate_number LIKE (p_concat_segments)
       UNION ALL
      -- Content LPNs
      SELECT /*+ ORDERED */
             DECODE( m.parent_line_id
                   , NULL, DECODE( mtrl.line_status
                                 , 6,'*'
                                 , 9, '*'
                                 , ' '
                                 )
                   , ' '
                   ) status
           , l.license_plate_number   lpn
           , DECODE( m.parent_line_id
                   , NULL, DECODE( m.transaction_type_ID
                                 , 35,'WIP_PICKING'
                                 , DECODE( w.task_type
                                         , 1,'PICKING'
                                         , 5,'MOXFER'
                                         , 'REPLENISHMENT'
                                         )
                                 )
                   , 'PICKING'
                   ) task_type
           , DECODE( m.parent_line_id
                   , NULL, DECODE( mtrl.line_status
                                 , 6,'CANCELLED'
                                 , 9,'CANCELLED'
                                 , 'NORMAL'
                                 )
                   , 'NORMAL'
                   ) task_mo_status
           , DECODE( m.parent_line_id
                   , NULL, m.transfer_subinventory
                   , NULL
                   ) to_sub
           , DECODE( m.parent_line_id
                   , NULL, get_locator( m.wms_task_type
                                      , m.locator_id
                                      , m.transfer_to_location
                                      , m.transaction_type_id
                                      , m.organization_id
                                      )
                   , NULL
                   ) to_loc
           , i.concatenated_segments  item
           , m.transaction_quantity
           , m.transaction_uom
           , m.transfer_lpn_id        lpn_id
           , m.transaction_temp_id    taskid
           , l.lpn_context
           , DECODE( m.parent_line_id
                   , NULL, 'FALSE'
                   , 'TRUE'
                   ) is_bulk_pick
           , 3                        dummy_sort
        FROM wms_dispatched_tasks            w
           , mtl_material_transactions_temp  m
           , mtl_system_items_kfv            i
           , wms_license_plate_numbers       l
           , mtl_txn_request_lines           mtrl
       WHERE w.person_id            = p_user_id
         AND w.organization_id      = p_organization_id
         AND w.status               = 4
         AND w.transaction_temp_id  = m.transaction_temp_id
         AND m.organization_id      = i.organization_id
         AND m.inventory_item_id    = i.inventory_item_id
         AND m.organization_id      = l.organization_id
         AND w.task_type           IN (1,4,5)
         AND m.transfer_lpn_id      = l.lpn_id
         AND m.move_order_line_id   = mtrl.line_id (+)
         --Bug 6891745
         AND decode(l.lpn_context, 8 , l.lpn_id, l.outermost_lpn_id) = l.outermost_lpn_id
         AND (m.parent_line_id     IS NULL
               OR
               (m.parent_line_id   IS NOT NULL
                AND
                m.parent_line_id    = m.transaction_temp_id
               )
             )
         AND m.content_lpn_id      IS NOT NULL
         AND l.license_plate_number LIKE (p_concat_segments)
       UNION ALL
      -- Material unpacked from content LPNs
      SELECT /*+ ORDERED */
             DECODE( m.parent_line_id
                   , NULL, DECODE( mtrl.line_status
                                 , 6,'*'
                                 , 9, '*'
                                 , ' '
                                 )
                   , ' '
                   ) status
           , l.license_plate_number   lpn
           , DECODE( m.parent_line_id
                   , NULL, DECODE( m.transaction_type_ID
                                 , 35,'WIP_PICKING'
                                 , DECODE( w.task_type
                                         , 1,'PICKING'
                                         , 5,'MOXFER'
                                         , 'REPLENISHMENT'
                                         )
                                 )
                   , 'PICKING'
                   ) task_type
           , DECODE( m.parent_line_id
                   , NULL, DECODE( mtrl.line_status
                                 , 6,'CANCELLED'
                                 , 9,'CANCELLED'
                                 , 'NORMAL'
                                 )
                   , 'NORMAL'
                   ) task_mo_status
           , DECODE( m.parent_line_id
                   , NULL, m.transfer_subinventory
                   , NULL
                   ) to_sub
           , DECODE( m.parent_line_id
                   , NULL, get_locator( m.wms_task_type
                                      , m.locator_id
                                      , m.transfer_to_location
                                      , m.transaction_type_id
                                      , m.organization_id
                                      )
                   , NULL
                   ) to_loc
           , i.concatenated_segments  item
           , m.transaction_quantity
           , m.transaction_uom
           , m.transfer_lpn_id        lpn_id
           , m.transaction_temp_id    taskid
           , l.lpn_context
           , DECODE( m.parent_line_id
                   , NULL, 'FALSE'
                   , 'TRUE'
                   ) is_bulk_pick
           , 4                        dummy_sort
        FROM wms_dispatched_tasks            w
           , mtl_material_transactions_temp  m
           , mtl_system_items_kfv            i
           , wms_license_plate_numbers       l
           , mtl_txn_request_lines           mtrl
       WHERE w.person_id            = p_user_id
         AND w.organization_id      = p_organization_id
         AND w.status               = 4
         AND w.transaction_temp_id  = m.transaction_temp_id
         AND m.organization_id      = i.organization_id
         AND m.inventory_item_id    = i.inventory_item_id
         AND m.organization_id      = l.organization_id
         AND w.task_type           IN (1,4,5)
         AND m.transfer_lpn_id      = l.lpn_id
         AND m.move_order_line_id   = mtrl.line_id (+)
         --Bug 6891745
         AND decode(l.lpn_context, 8 , l.lpn_id, l.outermost_lpn_id) = l.outermost_lpn_id
         AND (m.parent_line_id     IS NULL
               OR
               (m.parent_line_id   IS NOT NULL
                AND
                m.parent_line_id    = m.transaction_temp_id
               )
             )
         AND m.lpn_id              IS NOT NULL
         AND EXISTS
           ( SELECT 'x'
               FROM mtl_material_transactions_temp  m2
              WHERE m2.transfer_lpn_id      = m.transfer_lpn_id
                AND m2.organization_id      = m.organization_id
                AND m2.content_lpn_id       = m.lpn_id
                AND m2.transaction_temp_id <> m.transaction_temp_id
                AND DECODE( m2.parent_line_id
                          , NULL, 0
                          , m2.transaction_temp_id, 1
                          , 2
                          )                 = DECODE( m.parent_line_id
                                                    , NULL, 0
                                                    , 1
                                                    )
           )
         AND l.license_plate_number LIKE (p_concat_segments)
       UNION ALL
      -- All other picked material
      SELECT /*+ ORDERED */
             DECODE( m.parent_line_id
                   , NULL, DECODE( mtrl.line_status
                                 , 6,'*'
                                 , 9, '*'
                                 , ' '
                                 )
                   , ' '
                   ) status
           , l.license_plate_number   lpn
           , DECODE( m.parent_line_id
                   , NULL, DECODE( m.transaction_type_ID
                                 , 35,'WIP_PICKING'
                                 , DECODE( w.task_type
                                         , 1,'PICKING'
                                         , 5,'MOXFER'
                                         , 'REPLENISHMENT'
                                         )
                                 )
                   , 'PICKING'
                   ) task_type
           , DECODE( m.parent_line_id
                   , NULL, DECODE( mtrl.line_status
                                 , 6,'CANCELLED'
                                 , 9,'CANCELLED'
                                 , 'NORMAL'
                                 )
                   , 'NORMAL'
                   ) task_mo_status
           , DECODE( m.parent_line_id
                   , NULL, m.transfer_subinventory
                   , NULL
                   ) to_sub
           , DECODE( m.parent_line_id
                   , NULL, get_locator( m.wms_task_type
                                      , m.locator_id
                                      , m.transfer_to_location
                                      , m.transaction_type_id
                                      , m.organization_id
                                      )
                   , NULL
                   ) to_loc
           , i.concatenated_segments  item
           , m.transaction_quantity
           , m.transaction_uom
           , m.transfer_lpn_id        lpn_id
           , m.transaction_temp_id    taskid
           , l.lpn_context
           , DECODE( m.parent_line_id
                   , NULL, 'FALSE'
                   , 'TRUE'
                   ) is_bulk_pick
           , 5                        dummy_sort
        FROM wms_dispatched_tasks            w
           , mtl_material_transactions_temp  m
           , mtl_system_items_kfv            i
           , wms_license_plate_numbers       l
           , mtl_txn_request_lines           mtrl
       WHERE w.person_id            = p_user_id
         AND w.organization_id      = p_organization_id
         AND w.status               = 4
         AND w.transaction_temp_id  = m.transaction_temp_id
         AND m.organization_id      = i.organization_id
         AND m.inventory_item_id    = i.inventory_item_id
         AND m.organization_id      = l.organization_id
         AND w.task_type           IN (1,4,5)
         AND m.transfer_lpn_id      = l.lpn_id
         AND m.move_order_line_id   = mtrl.line_id (+)
         AND (m.parent_line_id     IS NULL
               OR
               (m.parent_line_id   IS NOT NULL
                AND
                m.parent_line_id    = m.transaction_temp_id
               )
             )
         AND m.content_lpn_id      IS NULL
         AND ( (m.lpn_id           IS NOT NULL
                AND NOT EXISTS
                  ( SELECT 'x'
                      FROM mtl_material_transactions_temp  m2
                     WHERE m2.transfer_lpn_id      = m.transfer_lpn_id
                       AND m2.organization_id      = m.organization_id
                       AND m2.content_lpn_id       = m.lpn_id
                       AND m2.transaction_temp_id <> m.transaction_temp_id
                       AND DECODE( m2.parent_line_id
                                 , NULL, 0
                                 , m2.transaction_temp_id, 1
                                 , 2
                                 )                 = DECODE( m.parent_line_id
                                                           , NULL, 0
                                                           , 1
                                                           )
                  )
               )
               OR m.lpn_id         IS NULL
             )
         AND NOT EXISTS
             ( SELECT 'x'
                 FROM mtl_material_transactions_temp  m3
                WHERE m3.transfer_lpn_id      = m.transfer_lpn_id
                  AND m3.organization_id      = m.organization_id
                  AND m3.content_lpn_id       = m.transfer_lpn_id
                  AND m3.transaction_temp_id <> m.transaction_temp_id
                  AND DECODE( m3.parent_line_id
                            , NULL, 0
                            , m3.transaction_temp_id, 1
                            , 2
                            )                 = DECODE( m.parent_line_id
                                                      , NULL, 0
                                                      , 1
                                                      )
             )
         AND l.license_plate_number LIKE (p_concat_segments)
	 --Added UNION for bug 6682436
      UNION ALL

     SELECT /*+ ORDERED */
             DECODE( m.parent_line_id
                   , NULL, DECODE( mtrl.line_status
                                 , 6,'*'
                                 , 9, '*'
                                 , ' '
                                 )
                   , ' '
                   ) status
           , l.license_plate_number   lpn
           , DECODE( m.parent_line_id
                   , NULL, DECODE( m.transaction_type_ID
                                 , 35,'WIP_PICKING'
                                 , DECODE( w.task_type
                                         , 1,'PICKING'
                                         , 5,'MOXFER'
                                         , 'REPLENISHMENT'
                                         )
                                 )
                   , 'PICKING'
                   ) task_type
           , DECODE( m.parent_line_id
                   , NULL, DECODE( mtrl.line_status
                                 , 6,'CANCELLED'
                                 , 9,'CANCELLED'
                                 , 'NORMAL'
                                 )
                   , 'NORMAL'
                   ) task_mo_status
           , DECODE( m.parent_line_id
                   , NULL, m.transfer_subinventory
                   , NULL
                   ) to_sub
           , DECODE( m.parent_line_id
                   , NULL, get_locator( m.wms_task_type
                                      , m.locator_id
                                      , m.transfer_to_location
                                      , m.transaction_type_id
                                      , m.organization_id
                                      )
                   , NULL
                   ) to_loc
           , i.concatenated_segments  item
           , m.transaction_quantity
           , m.transaction_uom
           , l.lpn_id         lpn_id
           /*modified for bug 6717052*/
           , m.transaction_temp_id    taskid
           , l.lpn_context
           , DECODE( m.parent_line_id
                   , NULL, 'FALSE'
                   , 'TRUE'
                   ) is_bulk_pick
           , 2                        dummy_sort
        FROM wms_dispatched_tasks            w
           , mtl_material_transactions_temp  m
           , mtl_system_items_kfv            i
           , wms_license_plate_numbers       l
           , mtl_txn_request_lines           mtrl
       WHERE w.person_id            = p_user_id
         AND w.organization_id      = p_organization_id
         AND w.status               = 4
         AND w.transaction_temp_id  = m.transaction_temp_id
         AND m.organization_id      = i.organization_id
         AND m.inventory_item_id    = i.inventory_item_id
         AND m.organization_id      = l.organization_id
         AND w.task_type           IN (1,4,5)
         AND l.lpn_id  IN  (SELECT DISTINCT(wlpn1.outermost_lpn_id) FROM wms_license_plate_numbers wlpn1 WHERE wlpn1.lpn_id = m.transfer_lpn_id AND wlpn1.lpn_id <> wlpn1.outermost_lpn_id)
         AND m.move_order_line_id   = mtrl.line_id (+)
         AND (m.parent_line_id     IS NULL
               OR
               (m.parent_line_id   IS NOT NULL
                AND
                m.parent_line_id    = m.transaction_temp_id
               )
             )
         AND l.license_plate_number LIKE (p_concat_segments)
        UNION ALL
      -- Staging moves
      SELECT  /*+ ORDERED */
           ' '                      status
           , l.license_plate_number   lpn
           , 'STAGING MOVE'           task_type
           , 'NORMAL'                 task_mo_status
           , m.transfer_subinventory  to_sub
           , get_locator( m.wms_task_type
                        , m.locator_id
                        , m.transfer_to_location
                        , m.transaction_type_id
                        , m.organization_id
                        ) to_loc
           , i.concatenated_segments  item
           , to_number(null)          transaction_quantity
           , to_char(null)            transaction_uom
           , m.transfer_lpn_id        lpn_id
           , m.transaction_temp_id    taskid
           , l.lpn_context
           , 'FALSE'                  is_bulk_pick
           , 6                        dummy_sort
        FROM wms_dispatched_tasks            w
           , mtl_material_transactions_temp  m
           , mtl_system_items_kfv            i
           , wms_license_plate_numbers       l
       WHERE w.person_id            = p_user_id
         AND w.organization_id      = p_organization_id
         AND w.status               = 4
         AND w.transaction_temp_id  = m.transaction_temp_id
         AND m.organization_id      = i.organization_id
         AND m.inventory_item_id    = i.inventory_item_id
         AND m.organization_id      = l.organization_id
         AND w.task_type            = 7
         AND m.transfer_lpn_id      = l.lpn_id
         AND l.license_plate_number LIKE (p_concat_segments)
       ORDER BY task_type
              , to_sub
              , to_loc
              , lpn
              , dummy_sort ;
   END IF;
END get_tasks_lov;



PROCEDURE GET_REASONS_LOV(x_reasons         OUT NOCOPY t_genref,
                          p_reason_type     IN NUMBER,
                          p_concat_segments IN VARCHAR2) IS


BEGIN
   inv_trx_util_pub.trace( 'WMS_Task_Dispatch_LOV - GET_REASONS_LOV - p_reason type' || p_reason_type || 'p_concat_segments -' || p_concat_segments   ,  '~~~~ ', 1); --/* Bug 9448490 Lot Substitution Project */

   OPEN x_reasons FOR
     SELECT reason_name,description, reason_id
     FROM   mtl_transaction_reasons
     WHERE  reason_type=p_reason_type
     AND    nvl(DISABLE_DATE, SYSDATE+1) > SYSDATE
     AND    reason_name LIKE (p_concat_segments)
     ORDER BY reason_name;

END get_reasons_lov;

--
-- Procedure overloaded for Transaction Reason Security build.
-- 4505091, nsrivast

PROCEDURE GET_REASONS_LOV(x_reasons         OUT NOCOPY t_genref,
                          p_reason_type     IN NUMBER,
                          p_concat_segments IN VARCHAR2,
                           p_txn_type_id    IN  NUMBER ) IS


BEGIN

   OPEN x_reasons FOR
     SELECT reason_name,description, reason_id
     FROM   mtl_transaction_reasons
     WHERE  reason_type=p_reason_type
     AND    nvl(DISABLE_DATE, SYSDATE+1) > SYSDATE
     AND    reason_name LIKE (p_concat_segments)
    -- nsrivast, invconv , transaction reason security
    AND   ( NVL  ( fnd_profile.value_wnps('INV_TRANS_REASON_SECURITY'), 'N') = 'N'
          OR
          reason_id IN (SELECT  reason_id FROM mtl_trans_reason_security mtrs
                              WHERE(( responsibility_id = fnd_global.resp_id OR NVL(responsibility_id, -1) = -1 )
                                        AND
                                    ( mtrs.transaction_type_id =  p_txn_type_id OR  NVL(mtrs.transaction_type_id, -1) = -1 )
                                    )-- where ends
                            )-- select ends
          ) -- and condn ends ,-- nsrivast, invconv
     ORDER BY reason_name;

END get_reasons_lov;


PROCEDURE GET_LPN_ITEMS_LOV(x_items         OUT NOCOPY t_genref,
                          p_lpn_id          IN NUMBER,
                          p_concat_segments IN VARCHAR2) IS

BEGIN

   OPEN x_items FOR
     SELECT k.concatenated_segments, k.inventory_item_id
     FROM mtl_material_transactions_temp m, mtl_system_items_vl k
     WHERE  m.transfer_lpn_id=p_lpn_id
     AND m.organization_id=k.organization_id
     AND m.inventory_item_id=k.inventory_item_id
     AND k.concatenated_segments LIKE (p_concat_segments);
     mydebug('In GET_LPN_ITEMS_LOV');
END GET_LPN_ITEMS_LOV;

PROCEDURE get_container_items_lov
  (x_container_items OUT NOCOPY t_genref,
   p_org_id          IN NUMBER,
   p_concat_segments IN VARCHAR2)
IS

BEGIN

   OPEN x_container_items FOR
     SELECT k.concatenated_segments, k.inventory_item_id
     FROM  mtl_system_items_vl k
     WHERE   k.organization_id=p_org_id
     AND k.container_item_flag='Y'
     AND k.concatenated_segments LIKE (p_concat_segments);
     mydebug('In get_container_items_lov');

END GET_CONTAINER_ITEMS_LOV;

PROCEDURE validate_container_items
  (p_organization_id             IN NUMBER,
   p_concat_segments    IN VARCHAR2,
   x_is_valid_container OUT NOCOPY VARCHAR2,
   x_container_item_id  OUT NOCOPY NUMBER)
IS
   TYPE container_item_record_type IS RECORD
   (concatenated_segments   VARCHAR2(40),
    inventory_item_id       NUMBER);

   container_item_rec      container_item_record_type;
   l_container_items       t_genref;
BEGIN
   x_is_valid_container := 'N';

   get_container_items_lov(x_container_items => l_container_items,
   p_org_id          => p_organization_id,
   p_concat_segments => p_concat_segments);

   LOOP
      FETCH l_container_items INTO container_item_rec;
      EXIT WHEN l_container_items%notfound;

      IF container_item_rec.concatenated_segments = p_concat_segments THEN
         x_is_valid_container := 'Y';
         x_container_item_id := container_item_rec.inventory_item_id;
         EXIT;
      END IF;

   END LOOP;

END validate_container_items;

PROCEDURE get_eqp_lov
  (x_eqps            OUT NOCOPY t_genref,
   p_Organization_Id IN NUMBER,
   p_concat_segments IN VARCHAR2)
IS

BEGIN

   OPEN x_eqps FOR
     SELECT
     mtl_serial_numbers.serial_number EQP_INS,
     mtl_system_items_vl.concatenated_segments EQP_NAME,
     mtl_system_items_vl.description EQP_DESC ,
     mtl_serial_numbers.inventory_item_id EQP_ID
     from
     mtl_serial_numbers,
     mtl_system_items_vl /* Bug 5581528 */
     where mtl_serial_numbers.inventory_item_id=mtl_system_items_vl.inventory_item_id
     and mtl_system_items_vl.organization_id=p_Organization_Id
     and mtl_system_items_vl.equipment_type=1
     AND mtl_serial_numbers.serial_number  LIKE (p_concat_segments)
     UNION ALL
     SELECT
     'NONE' EQP_INS,
     'NONE'eqp_name,
     'NONE' EQP_DESC,
     -999 eqp_id
     FROM DUAL
     where 'NONE' like (upper(p_concat_segments));


END get_eqp_lov;


PROCEDURE get_device_lov
  (x_devices         OUT NOCOPY t_genref,
   p_Organization_Id IN NUMBER,
   p_concat_segments IN VARCHAR2)
IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      mydebug('In get_device_lov');
   END IF;

   OPEN x_devices FOR
     SELECT NAME device_name,
            DEVICE_TYPE device_type,
            DESCRIPTION device_desc,
            DEVICE_ID device_id,
            SUBINVENTORY_CODE subinventory
     FROM WMS_DEVICES_VL
     WHERE SUBINVENTORY_CODE is not null
       and ORGANIZATION_ID = p_Organization_Id
       and NAME like (p_concat_segments)
     UNION ALL
     SELECT 'NONE' device_name,'NONE' device_type,'NONE'device_desc,-999 EQP_ID,'NONE' SUBINVENTORY FROM DUAL
       where 'NONE' like (upper(p_concat_segments))
       ORDER BY 1;


END get_device_lov;


PROCEDURE get_current_device_lov
  (x_devices         OUT NOCOPY t_genref,
   p_Employee_Id     IN NUMBER,
   p_concat_segments IN VARCHAR2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      mydebug('In get_device_lov');
   END IF;

   OPEN x_devices FOR
     SELECT wdv.NAME device_name,
            wdv.DEVICE_TYPE device_type,
            wdv.DESCRIPTION device_desc,
            wdat.ASSIGNMENT_TEMP_ID temp_id,
            wdv.SUBINVENTORY_CODE subinventory
     FROM WMS_DEVICES_VL wdv, WMS_DEVICE_ASSIGNMENT_TEMP wdat
     WHERE
        wdat.EMPLOYEE_ID = p_Employee_Id
       and wdv.device_id = wdat.device_id
       and wdv.NAME like (p_concat_segments)
     order by 4;

END get_current_device_lov;


Function get_locator(p_wms_task_type IN NUMBER,
                     p_locator_id IN NUMBER,
                     p_transfer_to_location_id IN NUMBER,
                     p_transaction_TYPE_id IN NUMBER,
                     p_organization_id IN NUMBER)
  RETURN VARCHAR2 IS
     v_concatenated_segments varchar2(204):= null;
begin
   if p_transaction_type_ID = 35 then
      v_concatenated_segments := NULL;
   else
      if p_wms_task_type in (1,4,5) then
         begin
            select concatenated_segments into v_concatenated_segments
            from  mtl_item_locations_kfv k
            where k.inventory_location_id = p_transfer_to_location_id
            and   k.organization_id = p_organization_id;
         EXCEPTION
            WHEN no_data_found THEN
              RAISE fnd_api.g_exc_error;
            WHEN OTHERS THEN
              RAISE fnd_api.g_exc_unexpected_error;
         END;
       elsif p_wms_task_type = 2 then
          begin
             select concatenated_segments into v_concatenated_segments
               from mtl_item_locations_kfv k
               where k.inventory_location_id = p_locator_id
               and   k.organization_id = p_organization_id;
          EXCEPTION
             WHEN no_data_found THEN
                RAISE fnd_api.g_exc_error;
             WHEN OTHERS THEN
                RAISE fnd_api.g_exc_unexpected_error;
          END;
      end if;
   end if;
   return  v_concatenated_segments;

end get_locator;



PROCEDURE get_item_lov
  (x_Items OUT NOCOPY t_genref,
   p_Organization_Id IN NUMBER,
   p_Concatenated_Segments IN VARCHAR2,
   p_where_clause IN VARCHAR2,
   p_lpn_id  IN NUMBER)
  IS
  l_cross_ref varchar2(204);
  l_lov_sql   VARCHAR2(4000);
  l_append varchar2(2):='';

BEGIN

   l_append := wms_deploy.get_item_suffix_for_lov(p_Concatenated_Segments);

   l_cross_ref := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');

   IF p_lpn_id IS NULL  THEN
     OPEN x_items FOR
       SELECT concatenated_segments,
       inventory_item_id, description,
       Nvl(revision_qty_control_code,1),
       Nvl(lot_control_code, 1),
       Nvl(serial_number_control_code, 1),
       Nvl(restrict_subinventories_code, 2),
       Nvl(restrict_locators_code, 2),
       Nvl(location_control_code, 1),
       primary_uom_code,
       Nvl(inspection_required_flag, 'N'),
       Nvl(shelf_life_code, 1),
       Nvl(shelf_life_days,0),
       Nvl(allowed_units_lookup_code, 2),
       Nvl(effectivity_control,1), 0, 0,
       Nvl(default_serial_status_id,1),
       Nvl(serial_status_enabled,'N'),
       Nvl(default_lot_status_id,0),
       Nvl(lot_status_enabled,'N'),
       '',
       'N',
       inventory_item_flag,
       0,
       wms_deploy.get_item_client_name(inventory_item_id),
       inventory_asset_flag,
       outside_operation_flag,
       NVL(grade_control_flag,'N'),
       NVL(default_grade,''),
       NVL(expiration_action_interval,0),
       NVL(expiration_action_code,''),
       NVL(hold_days,0),
       NVL(maturity_days,0),
       NVL(retest_interval,0),
       NVL(copy_lot_attribute_flag,'N'),
       NVL(child_lot_flag,'N'),
       NVL(child_lot_validation_flag,'N'),
       NVL(lot_divisible_flag,'Y'),
       NVL(secondary_uom_code,''),
       NVL(secondary_default_ind,''),
       NVL(tracking_quantity_ind,'P'),
       NVL(dual_uom_deviation_high,0),
       NVL(dual_uom_deviation_low,0)
       FROM mtl_system_items_vl /* Bug 5581528 */
       WHERE organization_id = p_organization_id
       AND concatenated_segments LIKE p_concatenated_segments || l_append

       --Changes for GTIN
       UNION

       SELECT concatenated_segments,
       msik.inventory_item_id, msik.description,
       Nvl(revision_qty_control_code,1),
       Nvl(lot_control_code, 1),
       Nvl(serial_number_control_code, 1),
       Nvl(restrict_subinventories_code, 2),
       Nvl(restrict_locators_code, 2),
       Nvl(location_control_code, 1),
       primary_uom_code,
       Nvl(inspection_required_flag, 'N'),
       Nvl(shelf_life_code, 1),
       Nvl(shelf_life_days,0),
       Nvl(allowed_units_lookup_code, 2),
       Nvl(effectivity_control,1), 0, 0,
       Nvl(default_serial_status_id,1),
       Nvl(serial_status_enabled,'N'),
       Nvl(default_lot_status_id,0),
       Nvl(lot_status_enabled,'N'),
       'mcr.cross_reference',
       'N',
       inventory_item_flag,
       0,
       wms_deploy.get_item_client_name(msik.inventory_item_id),
       inventory_asset_flag,
       outside_operation_flag,
       NVL(grade_control_flag,'N'),
       NVL(default_grade,''),
       NVL(expiration_action_interval,0),
       NVL(expiration_action_code,''),
       NVL(hold_days,0),
       NVL(maturity_days,0),
       NVL(retest_interval,0),
       NVL(copy_lot_attribute_flag,'N'),
       NVL(child_lot_flag,'N'),
       NVL(child_lot_validation_flag,'N'),
       NVL(lot_divisible_flag,'Y'),
       NVL(secondary_uom_code,''),
       NVL(secondary_default_ind,''),
       NVL(tracking_quantity_ind,'P'),
       NVL(dual_uom_deviation_high,0),
       NVL(dual_uom_deviation_low,0)
       FROM mtl_system_items_vl msik, /* Bug 5581528 */
            mtl_cross_references mcr
       WHERE msik.organization_id = p_organization_id
       AND msik.inventory_item_id   = mcr.inventory_item_id
       AND mcr.cross_reference_type = g_gtin_cross_ref_type
       AND mcr.cross_reference      LIKE l_cross_ref
       AND (mcr.organization_id     = msik.organization_id
            OR
            mcr.org_independent_flag = 'Y');
   ELSE

     /** Make the above sql dynamic to avoid dependency on
         wms_grouped_tasks_gtemp  for patchset I
         and use bind variables for better performance*/
     OPEN x_items FOR

     SELECT concatenated_segments,
       inventory_item_id, description,
       Nvl(revision_qty_control_code,1),
       Nvl(lot_control_code, 1),
       Nvl(serial_number_control_code, 1),
       Nvl(restrict_subinventories_code, 2),
       Nvl(restrict_locators_code, 2),
       Nvl(location_control_code, 1),
       primary_uom_code,
       Nvl(inspection_required_flag, 'N'),
       Nvl(shelf_life_code, 1),
       Nvl(shelf_life_days,0),
       Nvl(allowed_units_lookup_code, 2),
       Nvl(effectivity_control,1), 0, 0,
       Nvl(default_serial_status_id,1),
       Nvl(serial_status_enabled,'N'),
       Nvl(default_lot_status_id,0),
       Nvl(lot_status_enabled,'N'),
       '',
       'N',
       inventory_item_flag,
       0,
       wms_deploy.get_item_client_name(inventory_item_id),
       inventory_asset_flag,
       outside_operation_flag,
       NVL(grade_control_flag,'N'),
       NVL(default_grade,''),
       NVL(expiration_action_interval,0),
       NVL(expiration_action_code,''),
       NVL(hold_days,0),
       NVL(maturity_days,0),
       NVL(retest_interval,0),
       NVL(copy_lot_attribute_flag,'N'),
       NVL(child_lot_flag,'N'),
       NVL(child_lot_validation_flag,'N'),
       NVL(lot_divisible_flag,'Y'),
       NVL(secondary_uom_code,''),
       NVL(secondary_default_ind,''),
       NVL(tracking_quantity_ind,'P'),
       NVL(dual_uom_deviation_high,0),
       NVL(dual_uom_deviation_low,0)
       FROM mtl_system_items_vl msik /* Bug 5581528 */
       WHERE organization_id = p_organization_id
       AND concatenated_segments LIKE p_concatenated_segments||l_append
       AND exists
            (  select 1
               from wms_putaway_group_tasks_gtmp wpgt
               where wpgt.inventory_item_id  = msik.inventory_item_id
               and lpn_id = p_lpn_id
               and drop_type = 'ID')
       --Changes for GTIN
       UNION

       SELECT concatenated_segments,
       msik.inventory_item_id, msik.description,
       Nvl(revision_qty_control_code,1),
       Nvl(lot_control_code, 1),
       Nvl(serial_number_control_code, 1),
       Nvl(restrict_subinventories_code, 2),
       Nvl(restrict_locators_code, 2),
       Nvl(location_control_code, 1),
       primary_uom_code,
       Nvl(inspection_required_flag, 'N'),
       Nvl(shelf_life_code, 1),
       Nvl(shelf_life_days,0),
       Nvl(allowed_units_lookup_code, 2),
       Nvl(effectivity_control,1), 0, 0,
       Nvl(default_serial_status_id,1),
       Nvl(serial_status_enabled,'N'),
       Nvl(default_lot_status_id,0),
       Nvl(lot_status_enabled,'N'),
       'mcr.cross_reference',
       'N',
       inventory_item_flag,
       0,
       wms_deploy.get_item_client_name(msik.inventory_item_id),
       inventory_asset_flag,
       outside_operation_flag,
       NVL(grade_control_flag,'N'),
       NVL(default_grade,''),
       NVL(expiration_action_interval,0),
       NVL(expiration_action_code,''),
       NVL(hold_days,0),
       NVL(maturity_days,0),
       NVL(retest_interval,0),
       NVL(copy_lot_attribute_flag,'N'),
       NVL(child_lot_flag,'N'),
       NVL(child_lot_validation_flag,'N'),
       NVL(lot_divisible_flag,'Y'),
       NVL(secondary_uom_code,''),
       NVL(secondary_default_ind,''),
       NVL(tracking_quantity_ind,'P'),
       NVL(dual_uom_deviation_high,0),
       NVL(dual_uom_deviation_low,0)
       FROM mtl_system_items_vl msik, /* Bug 5581528 */
            mtl_cross_references mcr
       WHERE msik.organization_id = p_organization_id
       AND msik.inventory_item_id   = mcr.inventory_item_id
       AND mcr.cross_reference_type = g_gtin_cross_ref_type
       AND mcr.cross_reference      LIKE l_cross_ref
       AND (mcr.organization_id     = msik.organization_id
            OR
            mcr.org_independent_flag = 'Y')
      AND exists
            (  select 1
               from wms_putaway_group_tasks_gtmp wpgt
               where wpgt.inventory_item_id  = msik.inventory_item_id
               and lpn_id = p_lpn_id
               and drop_type = 'ID');

   END IF;
   mydebug('In get_item_lov');
END get_item_lov;


-- Overloaded procedure for the reason LOV in the discrepancy page for APL
PROCEDURE get_reasons_lov(x_reasons         OUT NOCOPY t_genref,
                          p_reason_type     IN NUMBER,
                          p_reason_contexts IN VARCHAR2,
                          p_concat_segments IN VARCHAR2)
  IS
   l_context_count NUMBER := 1;
   l_cp_allowed    NUMBER := 0;
   l_le_allowed    NUMBER := 0;
   l_pn_allowed    NUMBER := 0;
   l_po_allowed    NUMBER := 0;
   l_pp_allowed    NUMBER := 0;
   l_sl_allowed    NUMBER := 0;
   l_um_allowed    NUMBER := 0;
   l_pl_allowed    NUMBER := 0;
   l_cl_allowed    NUMBER := 0;  --/* Bug 9448490 Lot Substitution Project */
   l_context       VARCHAR2(2);
   l_reason_count  NUMBER := 0;
BEGIN
/* Bug 9448490 Lot Substitution Project */
 inv_trx_util_pub.trace( 'WMSTSKLB ~getreasonlov 2 - entered overloaded proc  -p_reason_type-'|| p_reason_type ||'-p_reason_contexts-'||p_reason_contexts||'-p_concat_segments-'||p_concat_segments  ,  'wms_alloc_gtmp_trigger', 1);

   WHILE l_context_count < Length(p_reason_contexts) LOOP
      l_context := Substr(p_reason_contexts, l_context_count, 2);

      IF l_context = 'CP' THEN
         l_cp_allowed := 1;
       ELSIF l_context = 'LE' THEN
         l_le_allowed := 1;
       ELSIF l_context = 'PN' THEN
         l_pn_allowed := 1;
       ELSIF l_context = 'PO' THEN
         l_po_allowed := 1;
       ELSIF l_context = 'PP' THEN
         l_pp_allowed := 1;
       ELSIF l_context = 'SL' THEN
         l_sl_allowed := 1;
       ELSIF l_context = 'UM' THEN
         l_um_allowed := 1;
       ELSIF l_context = 'PL' THEN
         l_pl_allowed := 1;
	  ELSIF l_context = 'CL' THEN
         l_cl_allowed := 1;  --/* Bug 9448490 Lot Substitution Project */
      END IF;

      l_context_count := l_context_count + 2;
   END LOOP;

   BEGIN
      SELECT COUNT(reason_name)
        INTO l_reason_count
        FROM mtl_transaction_reasons
        WHERE reason_type = p_reason_type -- Picking
        AND Nvl(DISABLE_DATE, SYSDATE+1) > SYSDATE
        AND Decode(reason_context_code,
                   'CP', l_cp_allowed,
                   'LE', l_le_allowed,
                   'PN', l_pn_allowed,
                   'PO', l_po_allowed,
                   'PP', l_pp_allowed,
                   'SL', l_sl_allowed,
                   'UM', l_um_allowed,
                   'PL', l_pl_allowed,
		   'CL', l_cl_allowed) = 1 --/* Bug 9448490 Lot Substitution Project */
        AND reason_name LIKE p_concat_segments || '%' ;
   EXCEPTION
      WHEN no_data_found THEN
         l_reason_count := 0;
   END;

   OPEN x_reasons FOR
     SELECT reason_name, description,
            reason_id, reason_context_code,
            workflow_name, workflow_process, l_reason_count
     FROM mtl_transaction_reasons
     WHERE reason_type = p_reason_type -- Picking
     AND Nvl(DISABLE_DATE, Sysdate+1) > Sysdate
     AND Decode(reason_context_code,
                'CP', l_cp_allowed,
                'LE', l_le_allowed,
                'PN', l_pn_allowed,
                'PO', l_po_allowed,
                'PP', l_pp_allowed,
                'SL', l_sl_allowed,
                'UM', l_um_allowed,
                'PL', l_pl_allowed,
		'CL', l_cl_allowed) = 1 --/* Bug 9448490 Lot Substitution Project */
     AND reason_name LIKE p_concat_segments || '%'
     ORDER BY reason_name;

END get_reasons_lov;


-- Overloaded procedure for the reason LOV in the discrepancy page for APL
-- Procedure overloaded for Transaction Reason Security build. 4505091, nsrivast
PROCEDURE get_reasons_lov(x_reasons         OUT NOCOPY t_genref,
                          p_reason_type     IN NUMBER,
                          p_reason_contexts IN VARCHAR2,
                          p_concat_segments IN VARCHAR2,
                          p_txn_type_id     IN VARCHAR2 )
  IS
   l_context_count NUMBER := 1;
   l_cp_allowed    NUMBER := 0;
   l_le_allowed    NUMBER := 0;
   l_pn_allowed    NUMBER := 0;
   l_po_allowed    NUMBER := 0;
   l_pp_allowed    NUMBER := 0;
   l_sl_allowed    NUMBER := 0;
   l_um_allowed    NUMBER := 0;
   l_pl_allowed    NUMBER := 0;
   l_context       VARCHAR2(2);
   l_reason_count  NUMBER := 0;
BEGIN

   WHILE l_context_count < Length(p_reason_contexts) LOOP
      l_context := Substr(p_reason_contexts, l_context_count, 2);

      IF l_context = 'CP' THEN
         l_cp_allowed := 1;
       ELSIF l_context = 'LE' THEN
         l_le_allowed := 1;
       ELSIF l_context = 'PN' THEN
         l_pn_allowed := 1;
       ELSIF l_context = 'PO' THEN
         l_po_allowed := 1;
       ELSIF l_context = 'PP' THEN
         l_pp_allowed := 1;
       ELSIF l_context = 'SL' THEN
         l_sl_allowed := 1;
       ELSIF l_context = 'UM' THEN
         l_um_allowed := 1;
       ELSIF l_context = 'PL' THEN
         l_pl_allowed := 1;
      END IF;

      l_context_count := l_context_count + 2;
   END LOOP;

   BEGIN
      SELECT COUNT(reason_name)
        INTO l_reason_count
        FROM mtl_transaction_reasons
        WHERE reason_type = p_reason_type -- Picking
        AND Nvl(DISABLE_DATE, SYSDATE+1) > SYSDATE
        AND Decode(reason_context_code,
                   'CP', l_cp_allowed,
                   'LE', l_le_allowed,
                   'PN', l_pn_allowed,
                   'PO', l_po_allowed,
                   'PP', l_pp_allowed,
                   'SL', l_sl_allowed,
                   'UM', l_um_allowed,
                   'PL', l_pl_allowed) = 1
        AND reason_name LIKE p_concat_segments || '%'
      -- nsrivast, invconv , transaction reason security
      AND   ( NVL  ( fnd_profile.value_wnps('INV_TRANS_REASON_SECURITY'), 'N') = 'N'
          OR
          reason_id IN (SELECT  reason_id FROM mtl_trans_reason_security mtrs
                              WHERE(( responsibility_id = fnd_global.resp_id OR NVL(responsibility_id, -1) = -1 )
                                        AND
                                    ( mtrs.transaction_type_id =  p_txn_type_id OR  NVL(mtrs.transaction_type_id, -1) = -1 )
                                    )-- where ends
                            )-- select ends
          ) -- and condn ends ,-- nsrivast, invconv
        ;
   EXCEPTION
      WHEN no_data_found THEN
         l_reason_count := 0;
   END;

   OPEN x_reasons FOR
     SELECT reason_name, description,
            reason_id, reason_context_code,
            workflow_name, workflow_process, l_reason_count
     FROM mtl_transaction_reasons
     WHERE reason_type = p_reason_type -- Picking
     AND Nvl(DISABLE_DATE, Sysdate+1) > Sysdate
     AND Decode(reason_context_code,
                'CP', l_cp_allowed,
                'LE', l_le_allowed,
                'PN', l_pn_allowed,
                'PO', l_po_allowed,
                'PP', l_pp_allowed,
                'SL', l_sl_allowed,
                'UM', l_um_allowed,
                'PL', l_pl_allowed) = 1
     AND reason_name LIKE p_concat_segments || '%'
     -- nsrivast, invconv , transaction reason security
     AND   ( NVL  ( fnd_profile.value_wnps('INV_TRANS_REASON_SECURITY'), 'N') = 'N'
          OR
          reason_id IN (SELECT  reason_id FROM mtl_trans_reason_security mtrs
                              WHERE(( responsibility_id = fnd_global.resp_id OR NVL(responsibility_id, -1) = -1 )
                                        AND
                                    ( mtrs.transaction_type_id =  p_txn_type_id OR  NVL(mtrs.transaction_type_id, -1) = -1 )
                                    )-- where ends
                            )-- select ends
          ) -- and condn ends ,-- nsrivast, invconv
     ORDER BY reason_name;

END get_reasons_lov;

END wms_task_dispatch_LOV;


/
