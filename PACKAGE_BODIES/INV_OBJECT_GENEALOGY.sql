--------------------------------------------------------
--  DDL for Package Body INV_OBJECT_GENEALOGY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_OBJECT_GENEALOGY" AS
  /* $Header: INVOGENB.pls 120.10.12010000.4 2009/05/07 14:22:40 mporecha ship $ */
  FUNCTION getobjecttype(p_object_id IN NUMBER)
    RETURN NUMBER IS
    l_retval NUMBER;
    l_debug  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    BEGIN
      SELECT 1
        INTO l_retval
        FROM mtl_lot_numbers
       WHERE gen_object_id = p_object_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          SELECT 2
            INTO l_retval
            FROM mtl_serial_numbers
           WHERE gen_object_id = p_object_id;
        EXCEPTION
          /*osfmint*/
          WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT 5
                INTO l_retval
                FROM wip_entities
               WHERE gen_object_id = p_object_id;
            EXCEPTION
              WHEN OTHERS THEN
                l_retval  := NULL;
            END;
          /*osfmint*/
          WHEN OTHERS THEN
            l_retval  := NULL;
        END;
      WHEN OTHERS THEN
        l_retval  := NULL;
    END;

    --  return 2; -- Serial
    RETURN l_retval;
  END getobjecttype;


  PROCEDURE getobjectinfo(
    p_object_id          IN            NUMBER
  , p_object_type        IN            NUMBER
  , p_object_name        OUT NOCOPY    VARCHAR2
  , p_object_description OUT NOCOPY    VARCHAR2
  , p_object_type_name   OUT NOCOPY    VARCHAR2
  , p_expiration_date    OUT NOCOPY    DATE
  , p_primary_uom        OUT NOCOPY    VARCHAR2
  , p_inventory_item_id  OUT NOCOPY    NUMBER
  , p_object_number      OUT NOCOPY    VARCHAR2
  , p_material_status    OUT NOCOPY    VARCHAR2
  , p_unit_number        OUT NOCOPY    VARCHAR2
  ) IS
    l_status_id NUMBER;
    l_debug     NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      inv_trx_util_pub.TRACE('in the procedure getObjectInfo', 'INV_OBJECT_GENEALOGY', 9);
      inv_trx_util_pub.TRACE('input param values to this proc are:', 'INV_OBJECT_GENEALOGY', 9);
      inv_trx_util_pub.TRACE('p_object_id is ' || p_object_id || 'p_object_type ' || p_object_type, 'INV_OBJECT_GENEALOGY', 9);
    END IF;

    IF p_object_type = 1 THEN
      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE('object_type is 1', 'INV_OBJECT_GENEALOGY', 9);
      END IF;

      BEGIN
        SELECT concatenated_segments
             , msivl.description
             , mln.expiration_date
             , msivl.primary_uom_code
             , mln.inventory_item_id
             , mln.lot_number
             , mln.status_id
          INTO p_object_name
             , p_object_description
             , p_expiration_date
             , p_primary_uom
             , p_inventory_item_id
             , p_object_number
             , l_status_id
          FROM mtl_system_items_vl msivl, mtl_lot_numbers mln
         WHERE mln.gen_object_id = p_object_id
           AND mln.inventory_item_id = msivl.inventory_item_id
           AND mln.organization_id = msivl.organization_id;

        IF (l_debug = 1) THEN
          inv_trx_util_pub.TRACE(
               'p_object_name: '
            || p_object_name
            || ' p_object_description: '
            || p_object_description
            || ' p_expiration_date :'
            || p_expiration_date
          , 'INV_OBJECT_GENEALOGY'
          , 9
          );
          inv_trx_util_pub.TRACE(
               'p_primary_uom : '
            || p_primary_uom
            || ' p_inventory_item_id : '
            || p_inventory_item_id
            || ' p_object_number :'
            || p_object_number
            || ' l_status_id :'
            || l_status_id
          , 'INV_OBJECT_GENEALOGY'
          , 9
          );
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF l_status_id IS NOT NULL THEN
        IF (l_debug = 1) THEN
          inv_trx_util_pub.TRACE('object type is 1 and status id is not null ', 'INV_OBJECT_GENEALOGY', 9);
        END IF;

        BEGIN
          SELECT status_code
            INTO p_material_status
            FROM mtl_material_statuses_vl
           WHERE status_id = l_status_id;

          IF (l_debug = 1) THEN
            inv_trx_util_pub.TRACE('object type is 1 and status code is ' || p_material_status, 'INV_OBJECT_GENEALOGY', 9);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;
    ELSIF p_object_type = 2 THEN
      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE('object type is 2 ', 'INV_OBJECT_GENEALOGY', 9);
      END IF;

      SELECT concatenated_segments
           , msivl.description
           , msn.end_item_unit_number
           , msn.serial_number
           , msn.inventory_item_id
           , msn.status_id
        INTO p_object_name
           , p_object_description
           , p_unit_number
           , p_object_number
           , p_inventory_item_id
           , l_status_id
        FROM mtl_system_items_vl msivl, mtl_serial_numbers msn
       WHERE msn.gen_object_id = p_object_id
         AND msn.inventory_item_id = msivl.inventory_item_id
         AND msn.current_organization_id = msivl.organization_id;

      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE('object type is 2 and values retrieved from MSN, MSIK are ', 'INV_OBJECT_GENEALOGY', 9);
        inv_trx_util_pub.TRACE(
          'p_object_name : ' || p_object_name || ' p_object_description : ' || p_object_description || ' p_unit_number ' || p_unit_number
        , 'INV_OBJECT_GENEALOGY'
        , 9
        );
        inv_trx_util_pub.TRACE('p_object_number : ' || p_object_number || ' l_status_id ' || l_status_id, 'INV_OBJECT_GENEALOGY', 9);
      END IF;

      IF l_status_id IS NOT NULL THEN
        BEGIN
          SELECT status_code
            INTO p_material_status
            FROM mtl_material_statuses_vl
           WHERE status_id = l_status_id;

          IF (l_debug = 1) THEN
            inv_trx_util_pub.TRACE(
              'object type is 2 and status code from mtl_material_statuses_vl for status_id ' || l_status_id || ' : ' || p_material_status
            , 'INV_OBJECT_GENEALOGY'
            , 9
            );
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;

      SELECT meaning
        INTO p_object_type_name
        FROM mfg_lookups
       WHERE lookup_code = p_object_type
         AND lookup_type = 'INV_GENEALOGY_OBJECT_TYPE';

      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE(
             'meaning from mfg_lookups for lookup_type = inv_genealogy_object_type and lookup_code = '
          || p_object_type
          || ' : '
          || p_object_type_name
        );
      END IF;
    END IF;
  END getobjectinfo;

  PROCEDURE getobjectinfo(
    p_object_id                IN            NUMBER
  , p_object_type              IN            NUMBER
  , p_object_name              OUT NOCOPY    VARCHAR2
  , p_object_description       OUT NOCOPY    VARCHAR2
  , p_object_type_name         OUT NOCOPY    VARCHAR2
  , p_expiration_date          OUT NOCOPY    DATE
  , p_primary_uom              OUT NOCOPY    VARCHAR2
  , p_inventory_item_id        OUT NOCOPY    NUMBER
  , p_object_number            OUT NOCOPY    VARCHAR2
  , p_material_status          OUT NOCOPY    VARCHAR2
  , p_unit_number              OUT NOCOPY    VARCHAR2
  , /*Serial Tracking in WIP project. Return
    wip_entity_id, operation_seq_num AND intraoperation_step_type also*/x_wip_entity_id OUT NOCOPY NUMBER
  , x_operation_seq_num        OUT NOCOPY    NUMBER
  , x_intraoperation_step_type OUT NOCOPY    NUMBER
  , x_current_lot_number       OUT NOCOPY    VARCHAR2   -- R12 Lot serial Genealogy Project : added new parameter x_current_lot_number
  ) IS
    l_status_id NUMBER;
    l_debug     NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      inv_trx_util_pub.TRACE('in the procedure getObjectInfo', 'INV_OBJECT_GENEALOGY', 9);
      inv_trx_util_pub.TRACE('input param values to this proc are:', 'INV_OBJECT_GENEALOGY', 9);
      inv_trx_util_pub.TRACE('p_object_id is ' || p_object_id || 'p_object_type ' || p_object_type, 'INV_OBJECT_GENEALOGY', 9);
    END IF;

    x_wip_entity_id             := NULL;
    x_operation_seq_num         := NULL;
    x_intraoperation_step_type  := NULL;

    IF p_object_type = 1 THEN
      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE('object_type is 1', 'INV_OBJECT_GENEALOGY', 9);
      END IF;

      BEGIN
        SELECT concatenated_segments
             , msivl.description
             , mln.expiration_date
             , msivl.primary_uom_code
             , mln.inventory_item_id
             , mln.lot_number
             , mln.status_id
          INTO p_object_name
             , p_object_description
             , p_expiration_date
             , p_primary_uom
             , p_inventory_item_id
             , p_object_number
             , l_status_id
          FROM mtl_system_items_vl msivl, mtl_lot_numbers mln
         WHERE mln.gen_object_id = p_object_id
           AND mln.inventory_item_id = msivl.inventory_item_id
           AND mln.organization_id = msivl.organization_id;

        IF (l_debug = 1) THEN
          inv_trx_util_pub.TRACE(
               'p_object_name: '
            || p_object_name
            || ' p_object_description: '
            || p_object_description
            || ' p_expiration_date :'
            || p_expiration_date
          , 'INV_OBJECT_GENEALOGY'
          , 9
          );
          inv_trx_util_pub.TRACE(
               'p_primary_uom : '
            || p_primary_uom
            || ' p_inventory_item_id : '
            || p_inventory_item_id
            || ' p_object_number :'
            || p_object_number
            || ' l_status_id :'
            || l_status_id
          , 'INV_OBJECT_GENEALOGY'
          , 9
          );
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF l_status_id IS NOT NULL THEN
        IF (l_debug = 1) THEN
          inv_trx_util_pub.TRACE('object type is 1 and status id is not null ', 'INV_OBJECT_GENEALOGY', 9);
        END IF;

        BEGIN
          SELECT status_code
            INTO p_material_status
            FROM mtl_material_statuses_vl
           WHERE status_id = l_status_id;

          IF (l_debug = 1) THEN
            inv_trx_util_pub.TRACE('object type is 1 and status code is ' || p_material_status, 'INV_OBJECT_GENEALOGY', 9);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;
    ELSIF p_object_type = 2 THEN
      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE('object type is 2 ', 'INV_OBJECT_GENEALOGY', 9);
      END IF;

      SELECT concatenated_segments
           , msivl.description
           , msn.end_item_unit_number
           , msn.serial_number
           , msn.inventory_item_id
           , msn.status_id
           , msn.wip_entity_id
           , msn.operation_seq_num
           , msn.intraoperation_step_type
           , msn.lot_number
        --Serial Tracking in WIP project. Retrieve wip_entity_id, operation_seq_num and
        -- intraoperation_step_type also.
      INTO   p_object_name
           , p_object_description
           , p_unit_number
           , p_object_number
           , p_inventory_item_id
           , l_status_id
           , x_wip_entity_id
           , x_operation_seq_num
           , x_intraoperation_step_type
           , x_current_lot_number
        FROM mtl_system_items_vl msivl, mtl_serial_numbers msn
       WHERE msn.gen_object_id = p_object_id
         AND msn.inventory_item_id = msivl.inventory_item_id
         AND msn.current_organization_id = msivl.organization_id;

      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE('object type is 2 and values retrieved from MSN, MSIK are ', 'INV_OBJECT_GENEALOGY', 9);
        inv_trx_util_pub.TRACE(
          'p_object_name : ' || p_object_name || ' p_object_description : ' || p_object_description || ' p_unit_number ' || p_unit_number
        , 'INV_OBJECT_GENEALOGY'
        , 9
        );
        inv_trx_util_pub.TRACE('p_object_number : ' || p_object_number || ' l_status_id ' || l_status_id, 'INV_OBJECT_GENEALOGY', 9);
        inv_trx_util_pub.TRACE(
             'x_wip_entity_id : '
          || x_wip_entity_id
          || ' x_operation_seq_num : '
          || x_operation_seq_num
          || ' x_intraoperation_step_type : '
          || x_intraoperation_step_type
        , 'INV_OBJECT_GENEALOGY'
        , 9
        );
      END IF;

      IF l_status_id IS NOT NULL THEN
        BEGIN
          SELECT status_code
            INTO p_material_status
            FROM mtl_material_statuses_vl
           WHERE status_id = l_status_id;

          IF (l_debug = 1) THEN
            inv_trx_util_pub.TRACE(
              'object type is 2 and status code from mtl_material_statuses_vl for status_id ' || l_status_id || ' : ' || p_material_status
            , 'INV_OBJECT_GENEALOGY'
            , 9
            );
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;

      SELECT meaning
        INTO p_object_type_name
        FROM mfg_lookups
       WHERE lookup_code = p_object_type
         AND lookup_type = 'INV_GENEALOGY_OBJECT_TYPE';

      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE(
             'meaning from mfg_lookups for lookup_type = inv_genealogy_object_type and lookup_code = '
          || p_object_type
          || ' : '
          || p_object_type_name
        );
      END IF;
    END IF;
  END getobjectinfo;

  /*Bug :4939794
    Function getjData returns 1 if the object_id passed is of 11510 data,
    returns 0 if the object_id passed is of R12 data*/

  FUNCTION getjData(
    p_object_id    IN NUMBER
  , p_object_type  IN NUMBER
  , p_object_id2   IN NUMBER DEFAULT NULL
  , p_object_type2 IN NUMBER DEFAULT NULL
  )
    RETURN NUMBER IS
     CURSOR jRecord IS
       SELECT 1                                      --when queried by asembly serial
         FROM DUAL
        WHERE EXISTS (
                 SELECT 1
                   FROM mtl_object_genealogy
                  WHERE     genealogy_origin = 1
                        AND object_type = 2
                        AND parent_object_type = 5
                        AND (end_date_active IS NULL OR end_date_active > SYSDATE)
                        AND (object_id = NVL (p_object_id, p_object_id2))
                     OR                            --when quereid by component serial
                        EXISTS (
                           SELECT 1
                             FROM DUAL
                            WHERE EXISTS (
                                     SELECT mog.parent_object_id
                                       FROM mtl_object_genealogy mog
                                      WHERE object_type = 2
                                        AND parent_object_type = 2
                                        AND object_id =
                                                      NVL (p_object_id, p_object_id2)
                                        AND EXISTS (
                                               SELECT 1
         --if queried by comp serial then check if it's parent aser has job as parent
                                                 FROM mtl_object_genealogy
                                                WHERE genealogy_origin = 1
                                                  AND object_type = 2
                                                  AND parent_object_type = 5
                                                  AND (   end_date_active IS NULL
                                                       OR end_date_active > SYSDATE
                                                      )
                                                  AND object_id =
                                                                 mog.parent_object_id))))
           OR
          -- if queried by component lot, then check if it's parent has aser as child
              EXISTS (
                 SELECT 1
                   FROM DUAL
                  WHERE EXISTS (
                           SELECT mog.parent_object_id
                             FROM mtl_object_genealogy mog
                            WHERE object_type = 1
                              AND parent_object_type = 5
                              AND object_id = NVL (p_object_id, p_object_id2)
                              AND EXISTS (
                                     SELECT 1
                                       FROM mtl_object_genealogy
                                      WHERE genealogy_origin = 1
                                        AND object_type = 2
                                        AND parent_object_type = 5
                                        AND (   end_date_active IS NULL
                                             OR end_date_active > SYSDATE
                                            )
                                        AND parent_object_id = mog.parent_object_id)))
           OR
       --if queried by assembly lot of lot serial, then check if it's parent has aser as child
              EXISTS (
                 SELECT 1
                   FROM DUAL
                  WHERE EXISTS (
                           SELECT mog.object_id
                             FROM mtl_object_genealogy mog
                            WHERE parent_object_type = 1
                              AND object_type = 5
                              AND parent_object_id = NVL (p_object_id, p_object_id2)
                              AND EXISTS (
                                     SELECT 1
                                       FROM mtl_object_genealogy
                                      WHERE genealogy_origin = 1
                                        AND object_type = 2
                                        AND parent_object_type = 5
                                        AND (   end_date_active IS NULL
                                             OR end_date_active > SYSDATE
                                            )
                                        AND parent_object_id = mog.object_id)))
           OR
       --if queried by job and if it has aser as child
              EXISTS (
                 SELECT 1
                   FROM DUAL
                  WHERE EXISTS (
                           SELECT 1
                             FROM mtl_object_genealogy mog
                            WHERE parent_object_type = 5
                              AND object_type = 2
                              AND genealogy_origin=1
                              AND parent_object_id=p_object_id))    ;
     jRec jRecord%ROWTYPE;


  BEGIN
       inv_trx_util_pub.TRACE('gjData'||g_jData, 'INV_OBJECT_GENEALOGY', 9);
         OPEN jRecord;
         FETCH jRecord INTO jRec;
         IF jRecord%found THEN
            g_jData:=1;
         ELSE
            g_jData:=0;
         END IF;
         RETURN (g_jData);
  END getjData;


  FUNCTION getobjectnumber(
    p_object_id    IN NUMBER
  , p_object_type  IN NUMBER
  , p_object_id2   IN NUMBER DEFAULT NULL
  , p_object_type2 IN NUMBER DEFAULT NULL
  )
    RETURN VARCHAR2 IS
    l_object_number           VARCHAR2(1200) := 'NULL';
    l_orgn_id                 NUMBER;
    l_item_id                 NUMBER;
    l_job_name                VARCHAR2(240);
    l_con_seg                 VARCHAR2(240);
    l_debug                   NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_genealogy_prefix_suffix NUMBER         := fnd_profile.VALUE('GENEALOGY_PREFIX_SUFFIX');
    l_genealogy_delimitter    VARCHAR2(1)    := NVL(fnd_profile.VALUE('GENEALOGY_DELIMITER'), '.');
    l_lot_number              VARCHAR2(80)   := NULL;
  BEGIN
    IF p_object_type = 1 THEN   /* object_type = 1 means lot control */
      -- Lot Genealogy is available even if WMS is not installed
      IF l_genealogy_prefix_suffix = 1 THEN   --Prefix
        SELECT lot_number || l_genealogy_delimitter || concatenated_segments
          INTO l_object_number
          FROM mtl_lot_numbers mln, mtl_system_items_kfv msikfv
         WHERE mln.gen_object_id = p_object_id
           AND mln.inventory_item_id = msikfv.inventory_item_id
           AND mln.organization_id = msikfv.organization_id;
      ELSIF l_genealogy_prefix_suffix = 2 THEN   --Suffix
        SELECT concatenated_segments || l_genealogy_delimitter || lot_number
          INTO l_object_number
          FROM mtl_lot_numbers mln, mtl_system_items_kfv msikfv
         WHERE mln.gen_object_id = p_object_id
           AND mln.inventory_item_id = msikfv.inventory_item_id
           AND mln.organization_id = msikfv.organization_id;
      ELSIF l_genealogy_prefix_suffix = 3 THEN   --None
        SELECT lot_number
          INTO l_object_number
          FROM mtl_lot_numbers mln, mtl_system_items_kfv msikfv
         WHERE mln.gen_object_id = p_object_id
           AND mln.inventory_item_id = msikfv.inventory_item_id
           AND mln.organization_id = msikfv.organization_id;
      END IF;
    ELSIF p_object_type = 2 THEN
      IF p_object_id2 IS NOT NULL
         AND p_object_type2 = 1 THEN   -- Lot Serial controlled
        BEGIN
          SELECT lot_number
            INTO l_lot_number
            FROM mtl_lot_numbers mln, mtl_system_items_kfv msikfv
           WHERE mln.gen_object_id = p_object_id2
             AND mln.inventory_item_id = msikfv.inventory_item_id
             AND mln.organization_id = msikfv.organization_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;

      IF inv_install.adv_inv_installed(p_organization_id => NULL) THEN
        IF l_genealogy_prefix_suffix = 1 THEN   -- prefix
          SELECT    l_lot_number
                 || DECODE(l_lot_number, NULL, '', l_genealogy_delimitter)
                 || serial_number
                 || l_genealogy_delimitter
                 || concatenated_segments
            INTO l_object_number
            FROM mtl_serial_numbers msn, mtl_system_items_kfv msikfv
           WHERE msn.gen_object_id = p_object_id
             AND msn.inventory_item_id = msikfv.inventory_item_id
             AND msn.current_organization_id = msikfv.organization_id;
        ELSIF l_genealogy_prefix_suffix = 2 THEN   -- suffix
          SELECT    concatenated_segments
                 || DECODE(l_lot_number, NULL, '', l_genealogy_delimitter)
                 || l_lot_number
                 || l_genealogy_delimitter
                 || serial_number
            INTO l_object_number
            FROM mtl_serial_numbers msn, mtl_system_items_kfv msikfv
           WHERE msn.gen_object_id = p_object_id
             AND msn.inventory_item_id = msikfv.inventory_item_id
             AND msn.current_organization_id = msikfv.organization_id;
        ELSIF l_genealogy_prefix_suffix = 3 THEN   --None
          SELECT l_lot_number || DECODE(l_lot_number, NULL, '', l_genealogy_delimitter) || serial_number
            INTO l_object_number
            FROM mtl_serial_numbers msn, mtl_system_items_kfv msikfv
           WHERE msn.gen_object_id = p_object_id
             AND msn.inventory_item_id = msikfv.inventory_item_id
             AND msn.current_organization_id = msikfv.organization_id;
        END IF;
      ELSE
        SELECT l_lot_number || DECODE(l_lot_number, NULL, '', l_genealogy_delimitter) || serial_number
          INTO l_object_number
          FROM mtl_serial_numbers
         WHERE gen_object_id = p_object_id;
      END IF;
    ELSIF p_object_type = 5 THEN
      SELECT we.primary_item_id
           , we.organization_id
           , we.wip_entity_name
        INTO l_item_id
           , l_orgn_id
           , l_job_name
        FROM wip_entities we
       WHERE we.gen_object_id = p_object_id;

      IF (l_item_id IS NOT NULL) THEN
        SELECT concatenated_segments
          INTO l_con_seg
          FROM mtl_system_items_kfv msikfv
         WHERE msikfv.inventory_item_id = l_item_id
           AND msikfv.organization_id = l_orgn_id;
      ELSE
        l_con_seg  := '';
      END IF;

      IF l_genealogy_prefix_suffix = 1 THEN
        l_object_number  := l_job_name || l_genealogy_delimitter || l_con_seg;
      ELSIF l_genealogy_prefix_suffix = 2 THEN
        l_object_number  := l_con_seg || l_genealogy_delimitter || l_job_name;
      ELSIF l_genealogy_prefix_suffix = 3 THEN
        l_object_number  := l_con_seg;
      END IF;
    END IF;

    RETURN(l_object_number);
  END getobjectnumber;


  FUNCTION getsource(p_org_id IN NUMBER, p_trx_src_type IN NUMBER, p_trx_src_id IN NUMBER)
    RETURN VARCHAR2 IS
    l_trx_src VARCHAR2(30);
    row_count NUMBER       := 0;
    l_debug   NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF p_trx_src_type = 1 THEN   -- PO
      SELECT segment1
        INTO l_trx_src
        FROM po_headers_all
       WHERE po_header_id = p_trx_src_id;
    ELSIF p_trx_src_type IN(2, 8, 12) THEN   -- SO,Internal Order,RMA
      SELECT SUBSTR(concatenated_segments, 1, 30)
        INTO l_trx_src
        FROM mtl_sales_orders_kfv
       WHERE sales_order_id = p_trx_src_id;
    /* Removed p_trx-src_type = 3 for 2 reasons. one, that is function is not
       used at all. Second that mtl_object_genealogy table never has data from this
       source. Bug 4237802  */
    ELSIF p_trx_src_type = 4 THEN   -- Move Orders
      SELECT request_number
        INTO l_trx_src
        FROM mtl_txn_request_headers
       WHERE header_id = p_trx_src_id;
    ELSIF p_trx_src_type = 5 THEN   -- WIP
      SELECT wip_entity_name
        INTO l_trx_src
        FROM wip_entities
       WHERE wip_entity_id = p_trx_src_id
         AND organization_id = p_org_id;
    ELSIF p_trx_src_type = 6 THEN   -- Account Alias
      SELECT SUBSTR(concatenated_segments, 1, 30)
        INTO l_trx_src
        FROM mtl_generic_dispositions_kfv
       WHERE disposition_id = p_trx_src_id
         AND organization_id = p_org_id;
    ELSIF p_trx_src_type = 7 THEN   -- Internal Requisition
      SELECT segment1
        INTO l_trx_src
        FROM po_requisition_headers_all
       WHERE requisition_header_id = p_trx_src_id;
    ELSIF p_trx_src_type = 9 THEN   -- Cycle Count
      SELECT cycle_count_header_name
        INTO l_trx_src
        FROM mtl_cycle_count_headers
       WHERE cycle_count_header_id = p_trx_src_id
         AND organization_id = p_org_id;
    ELSIF p_trx_src_type = 10 THEN   -- Physical Inventory
      SELECT physical_inventory_name
        INTO l_trx_src
        FROM mtl_physical_inventories
       WHERE physical_inventory_id = p_trx_src_id
         AND organization_id = p_org_id;
    ELSIF p_trx_src_type = 11 THEN   -- Standard Cost Update
      SELECT description
        INTO l_trx_src
        FROM cst_cost_updates
       WHERE cost_update_id = p_trx_src_id
         AND organization_id = p_org_id;
    ELSIF p_trx_src_type = 13 THEN   -- Inventory
      -- Bug 2666620: BackFlush MO Type Removed. Hence checking for TxnSourceType also.
      SELECT COUNT(*)
        INTO row_count
        FROM mtl_txn_request_lines mol
       WHERE txn_source_id = p_trx_src_id
         AND organization_id = p_org_id
         AND EXISTS(SELECT NULL
                      FROM mtl_txn_request_headers
                     WHERE header_id = mol.header_id
                       AND move_order_type = 5
                       AND mol.transaction_source_type_id = 13);

      IF row_count > 0 THEN
        SELECT wip_entity_name
          INTO l_trx_src
          FROM wip_entities
         WHERE wip_entity_id = p_trx_src_id
           AND organization_id = p_org_id;
      END IF;
    END IF;

    RETURN l_trx_src;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END getsource;

  FUNCTION gettradingpartner(
    p_org_id          IN NUMBER
  , p_trx_src_type    IN NUMBER
  , p_trx_src_id      IN NUMBER
  , p_trx_src_line_id IN NUMBER
  , p_transfer_org_id IN NUMBER
  )
    RETURN VARCHAR2 IS
    l_trading_partner VARCHAR2(240) := NULL;
    l_debug           NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    /* For Bug#3420761: Changed the code  p_trx_src_type = 2 to
     p_trx_src_type in (2,12) to handle RMA transactions */
    IF p_trx_src_type = 1 THEN   -- PO
      SELECT vendor_name
        INTO l_trading_partner
        FROM po_vendors pov, po_headers_all poh
       WHERE poh.po_header_id = p_trx_src_id
         AND poh.vendor_id = pov.vendor_id;
    ELSIF p_trx_src_type IN(2, 12) THEN   -- SO,RMA
      SELECT party_name
        INTO l_trading_partner
        FROM hz_parties hp, hz_cust_accounts hca ,
             -- R12 TCA Mandate  to replace RA_CUSTOMERS with the above 2
             oe_order_headers_all sha, oe_order_lines_all sla
       WHERE sla.line_id = p_trx_src_line_id
         AND sha.header_id = sla.header_id
         --AND sha.sold_to_org_id = rac.customer_id; As part of R12 TCA changes
         AND sha.sold_to_org_id = hca.cust_account_id
         AND hca.party_id = hp.party_id;
    ELSIF p_trx_src_type IN(7, 8) THEN
      SELECT organization_code
        INTO l_trading_partner
        FROM mtl_parameters mp
       WHERE mp.organization_id = p_transfer_org_id;
    END IF;

    RETURN l_trading_partner;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '';
  END gettradingpartner;

  -- Added this pacakage as part of Bug 4018721
  PROCEDURE init IS
  BEGIN
    g_ind     := 0;
    g_treeno  := 1;
    g_depth   := 1;

    DELETE FROM mtl_gen_temp;
  END init;

  PROCEDURE inv_populate_child(
    p_object_id         IN NUMBER
  , p_related_object_id IN NUMBER
  , p_object_type       IN NUMBER DEFAULT NULL
  , p_object_id2        IN NUMBER DEFAULT NULL
  , p_object_type2      IN NUMBER DEFAULT NULL
  ) IS
    l_count           NUMBER       := 0;
    l_previous_parent NUMBER       := 0;
    get_hierc         VARCHAR2(1)  := 'Y';

    -- get_hierc is used to decide whether to select the next level of nodes for the selected node
    -- do not get the next level, if the node has already been processed once.

    CURSOR search_cur IS
      SELECT   *
          FROM mtl_gen_temp
         WHERE treeno < g_treeno
           AND DEPTH < g_depth
      ORDER BY ind DESC;

    /* R12 Lot Serial Genealogy Project : Modified cursor */

   /*11510 record group*/
    CURSOR child_cur1 IS
         SELECT object_id
              , parent_object_id
              , object_type
              , NULL   object_id2
              , NULL   object_type2
              , NULL   parent_object_id2
         FROM   mtl_object_genealogy
         WHERE  parent_object_id  = p_object_id
           AND object_type<>2
       AND    (end_date_active is null or end_date_active > SYSDATE);
         --AND    ((object_type = 2 AND parent_object_type = object_type) OR (object_type <> 2))


    /* R12 RECORD GROUP*/
    CURSOR child_cur2 IS
      SELECT object_id
           , parent_object_id
           , object_type
           , object_id2
           , object_type2
           , parent_object_id2
        FROM mtl_object_genealogy
       WHERE parent_object_id = p_object_id
         AND (p_object_id2 IS NULL OR parent_object_id2 = p_object_id2)
         AND (end_date_active IS NULL OR end_date_active > SYSDATE);

    l_debug  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);


  BEGIN
    -- First condition
    -- ===============
    -- Check if the p_object_id is the first node of the tree
    -- if yes, then no need to check other trees or nodes
     IF (l_debug = 1) THEN
       inv_trx_util_pub.TRACE('in the procedure inv_populate_child', 'INV_OBJECT_GENEALOGY', 9);
       inv_trx_util_pub.TRACE('input param values to this proc are:', 'INV_OBJECT_GENEALOGY', 9);
       inv_trx_util_pub.TRACE('p_object_id is ' || p_object_id || 'p_object_type ' || p_object_type, 'INV_OBJECT_GENEALOGY', 9);
       inv_trx_util_pub.TRACE('p_object_id2 is ' || p_object_id2 || 'p_object_type2 ' || p_object_type2, 'INV_OBJECT_GENEALOGY', 9);
       inv_trx_util_pub.TRACE('p_related_object_id is ' || p_related_object_id, 'INV_OBJECT_GENEALOGY', 9);
     END IF;

    IF g_ind > 1 THEN
      BEGIN
        SELECT 1
          INTO l_count
          FROM mtl_gen_temp
         WHERE label = p_object_id
           AND related_label = 0
           AND (p_object_id2 is null or label2=p_object_id2)
           AND ROWNUM < 2;

        IF l_count > 0 THEN
          get_hierc  := 'N';
          g_ind      := g_ind + 1;

          IF l_debug =1 THEN
            inv_trx_util_pub.TRACE('insert1, g_ind '||g_ind, 'INV_OBJECT_GENEALOGY', 9);
          END IF;

          INSERT INTO mtl_gen_temp
                      (
                       ind
                     , treeno
                     , DEPTH
                     , label
                     , related_label
                     , child_object_type
                     , label2
                     , child_object_type2
                      )
               VALUES (
                       g_ind
                     , g_treeno
                     , g_depth
                     , p_object_id
                     , p_related_object_id
                     , p_object_type
                     , p_object_id2
                     , p_object_type2
                      );
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count  := 0;
          IF l_debug = 1 THEN
             inv_trx_util_pub.TRACE('exception 1', 'INV_OBJECT_GENEALOGY', 9);
          END IF;

      END;
    END IF;

    -- Second Condition
    -- ================
    IF g_ind > 1 and get_hierc='Y' THEN
      BEGIN
        SELECT 1
          INTO l_count
          FROM mtl_gen_temp
         WHERE treeno = g_treeno
           AND label = p_object_id
           AND (p_object_id2 is null or label2=p_object_id2)
           AND ROWNUM < 2;

           -- If the node already exists in the present tree , that means
        -- it need not be exploded further.
        IF l_count > 0 THEN
          get_hierc  := 'N';
          g_ind      := g_ind + 1;
          IF l_debug=1 THEN
             inv_trx_util_pub.TRACE('insert2 g_ind '||g_ind, 'INV_OBJECT_GENEALOGY', 9);
          END IF;

          INSERT INTO mtl_gen_temp
                      (
                       ind
                     , treeno
                     , DEPTH
                     , label
                     , related_label
                     , child_object_type
                     , label2
                     , child_object_type2
                      )
               VALUES (
                       g_ind
                     , g_treeno
                     , g_depth
                     , p_object_id
                     , p_related_object_id
                     , p_object_type
                     , p_object_id2
                     , p_object_type2
                      );
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count  := 0;
          IF l_debug=1 THEN
             inv_trx_util_pub.TRACE('exception 2', 'INV_OBJECT_GENEALOGY', 9);
          END IF;

      END;
    END IF;


    -- Third condition
    -- ===============
    IF get_hierc = 'Y'
       AND g_treeno > 1 THEN
      l_previous_parent  := 0;

      FOR cur_var IN search_cur LOOP
        IF cur_var.label = p_object_id
           AND cur_var.label = l_previous_parent THEN
          get_hierc  := 'N';
          g_ind      := g_ind + 1;
          IF l_debug=1 THEN
             inv_trx_util_pub.TRACE('insert3 g_ind '||g_ind, 'INV_OBJECT_GENEALOGY', 9);
          END IF;

          INSERT INTO mtl_gen_temp
                      (
                       ind
                     , treeno
                     , DEPTH
                     , label
                     , related_label
                     , child_object_type
                     , label2
                     , child_object_type2
                      )
               VALUES (
                       g_ind
                     , g_treeno
                     , g_depth
                     , p_object_id
                     , p_related_object_id
                     , p_object_type
                     , p_object_id2
                     , p_object_type2
                      );

          EXIT;
        END IF;

        l_previous_parent  := cur_var.related_label;
      END LOOP;
    END IF;

    IF (get_hierc = 'Y') THEN
      g_ind  := g_ind + 1;
      IF l_debug=1 THEN
         inv_trx_util_pub.TRACE('insert4 g_ind '||g_ind, 'INV_OBJECT_GENEALOGY', 9);
      END IF;

      INSERT INTO mtl_gen_temp
                  (
                   ind
                 , treeno
                 , DEPTH
                 , label
                 , related_label
                 , child_object_type
                 , label2
                 , child_object_type2
                  )
           VALUES (
                   g_ind
                 , g_treeno
                 , g_depth
                 , p_object_id
                 , p_related_object_id
                 , p_object_type
                 , p_object_id2
                 , p_object_type2
                  );
      IF p_related_object_id <> p_object_id  THEN
      IF g_jData=1 THEN
         FOR child_rec IN child_cur1 LOOP
           g_depth   := g_depth + 1;

           -- added the following condition, so that if for some reason there is an end-less
           -- loop, it will atleast stop after the depth of 45 and will not 'disconnect the server'
           -- Please note that if the user really has a hieracrchy that is more than 45 levels deep,
           -- The users may report a bug that the complete information is not diaplyes
           -- We do not expect anyone to have such a deep hierarchy
           IF g_depth > 45 THEN
             EXIT;
           END IF;

           inv_populate_child(child_rec.object_id, child_rec.parent_object_id, child_rec.object_type, child_rec.object_id2
           , child_rec.object_type2);
           g_depth   := g_depth - 1;
           g_treeno  := g_treeno + 1;
         END LOOP;
      ELSE
         FOR child_rec IN child_cur2 LOOP
           g_depth   := g_depth + 1;

           -- added the following condition, so that if for some reason there is an end-less
           -- loop, it will atleast stop after the depth of 45 and will not 'disconnect the server'
           -- Please note that if the user really has a hieracrchy that is more than 45 levels deep,
           -- The users may report a bug that the complete information is not diaplyes
           -- We do not expect anyone to have such a deep hierarchy
           IF g_depth > 45 THEN
             EXIT;
           END IF;

           inv_populate_child(child_rec.object_id, child_rec.parent_object_id, child_rec.object_type, child_rec.object_id2
           , child_rec.object_type2);
           g_depth   := g_depth - 1;
           g_treeno  := g_treeno + 1;
         END LOOP;
      END IF;
      END IF;
    END IF;
  END inv_populate_child;

  PROCEDURE inv_populate_child_tree(
    p_object_id         IN NUMBER
  , p_related_object_id IN NUMBER
  , p_object_type       IN NUMBER DEFAULT NULL
  , p_object_id2        IN NUMBER DEFAULT NULL
  , p_object_type2      IN NUMBER DEFAULT NULL
  ) IS
    l_count       NUMBER;
    l_prev_parent NUMBER       := 1;
    l_min_level   NUMBER       := 1;
    --Bug 8467584
    n_level       NUMBER;
    n_rows        NUMBER;

    /* R12 Lot Serial Genealogy Project : Modified cursor */

    /*11510 record group*/

--Bug 6600064, Added end_date_active condition in the START WITH clause in child_cur1 and child_cur1
--Bug 6643575, removed the where clause logic and moved it to the to connect by clause in child_cur1 and child_cur1

      CURSOR child_cur1 IS
      SELECT level
            , mog.object_id
            , mog.parent_object_id
            , mog.object_type
            , NULL object_id2
            , NULL object_type2
            , NULL parent_object_id2
      FROM   mtl_object_genealogy mog
     -- WHERE object_type<>2--((object_type = 2 AND parent_object_type = object_type) OR (object_type <> 2))
     -- AND    (end_date_active is null or end_date_active > SYSDATE)
      START WITH (parent_object_id=p_object_id and (end_date_active is null or end_date_active > SYSDATE))
      CONNECT BY prior object_id = parent_object_id
      AND object_type<>2 --((object_type = 2 AND parent_object_type = object_type) OR (object_type <> 2))
      AND  (end_date_active is null or end_date_active > SYSDATE);


   --R12 record group
    --Bug 8467584, Added v_level_num filter
    CURSOR child_cur2(v_level_num NUMBER) IS
      SELECT     LEVEL
               , object_id
               , parent_object_id
               , object_type
               , object_id2
               , object_type2
               , parent_object_id2
            FROM mtl_object_genealogy
        --  WHERE end_date_active IS NULL
        --  OR end_date_active > SYSDATE
      START WITH (parent_object_id=p_object_id AND (end_date_active IS NULL OR end_date_active > SYSDATE))
      CONNECT BY PRIOR object_id = parent_object_id
      AND (end_date_active IS NULL OR end_date_active > SYSDATE)
      AND LEVEL < v_level_num;

    l_debug  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    /*End of R12 Genealogy Lot serial Project*/

  BEGIN
     IF (l_debug = 1) THEN
       inv_trx_util_pub.TRACE('in the procedure inv_populate_child_tree', 'INV_OBJECT_GENEALOGY', 9);
       inv_trx_util_pub.TRACE('input param values to this proc are:', 'INV_OBJECT_GENEALOGY', 9);
       inv_trx_util_pub.TRACE('p_object_id is ' || p_object_id || 'p_object_type ' || p_object_type, 'INV_OBJECT_GENEALOGY', 9);
       inv_trx_util_pub.TRACE('p_object_id2 is ' || p_object_id2 || 'p_object_type2 ' || p_object_type2, 'INV_OBJECT_GENEALOGY', 9);
       inv_trx_util_pub.TRACE('p_related_object_id is ' || p_related_object_id, 'INV_OBJECT_GENEALOGY', 9);
     END IF;

    inv_object_genealogy.init;
    g_ind          := g_ind + 1;
    l_prev_parent  := p_related_object_id;



    INSERT INTO mtl_gen_temp
                (
                 ind
               , treeno
               , DEPTH
               , label
               , related_label
               , child_object_type
               , label2
               , child_object_type2
                )
         VALUES (
                 g_ind
               , g_treeno
               , g_depth
               , p_object_id
               , p_related_object_id
               , p_object_type
               , p_object_id2
               , p_object_type2
                );

   IF g_jData=1 THEN
      --open 11510 cursor
      FOR child_rec IN child_cur1
                                    LOOP
        IF child_rec.parent_object_id = l_prev_parent THEN
          g_treeno  := g_treeno + 1;
        END IF;

        IF l_min_level = child_rec.LEVEL THEN
          g_treeno  := g_ind;
        END IF;

        IF g_depth < child_rec.LEVEL + 1 THEN
          g_depth  := child_rec.LEVEL + 1;
        END IF;

        g_ind          := g_ind + 1;

        INSERT INTO mtl_gen_temp
                    (
                     ind
                   , treeno
                   , DEPTH
                   , label
                   , related_label
                   , child_object_type
                   , label2
                   , child_object_type2
                    )
             VALUES
                     ( g_ind,
                       g_treeno,
                       child_rec.level+1,
                       child_rec.object_id,
                       child_rec.parent_object_id,
                       child_rec.object_type,
                       child_rec.object_id2,
                       child_rec.object_type2);

         l_prev_parent  := child_rec.parent_object_id;
      END LOOP;

   ELSE

     -- Dynamic Level calculation: bug 8467584
     -- Start with n_level = 2, calculate number of rows fetched (n_rows), compare with g_rowlimit.
     -- If less, increment n_level. Continue till n_rows > g_rowlimit.
     -- Pass (level - 1) to cursor.

      n_level := 2;
      n_rows := 1;

      LOOP
        SELECT   Count(*)
        INTO n_rows
        FROM mtl_object_genealogy
        --WHERE level < n_level
        START WITH (parent_object_id=p_object_id AND (end_date_active IS NULL OR end_date_active > SYSDATE))
        CONNECT BY PRIOR object_id = parent_object_id
        AND (end_date_active IS NULL OR end_date_active > SYSDATE)
        AND LEVEL < n_level;

        EXIT WHEN (n_rows > (g_rowlimit-1) OR n_rows = 0 OR n_level > 45);
        --assuming g_rowlimit records to be a 'safe' limit for displaying genealogy
        --max levels displayed: 45 (hard-coded in inv_populate_child)
        n_level := n_level + 1;
      END LOOP;

      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE('Fetching child_cur2 for level='||(n_level-1), 'INV_OBJECT_GENEALOGY', 9);
      END IF;

      --open r12 cursor
      FOR child_rec IN child_cur2(n_level-1)
      LOOP
        IF child_rec.parent_object_id = l_prev_parent THEN
          g_treeno  := g_treeno + 1;
        END IF;

        IF l_min_level = child_rec.LEVEL THEN
          g_treeno  := g_ind;
        END IF;

        IF g_depth < child_rec.LEVEL + 1 THEN
          g_depth  := child_rec.LEVEL + 1;
        END IF;

        g_ind          := g_ind + 1;

        INSERT INTO mtl_gen_temp
                    (
                     ind
                   , treeno
                   , DEPTH
                   , label
                   , related_label
                   , child_object_type
                   , label2
                   , child_object_type2
                    )
             VALUES
                     ( g_ind,
                       g_treeno,
                       child_rec.level+1,
                       child_rec.object_id,
                       child_rec.parent_object_id,
                       child_rec.object_type,
                       child_rec.object_id2,
                       child_rec.object_type2);

         l_prev_parent  := child_rec.parent_object_id;
      END LOOP;


   END IF;


  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = 1 THEN
        inv_log_util.trace('Exception:'||SQLERRM,'INV_OBJECT_GENEALOGY',9);
      END IF;
      inv_object_genealogy.init;
      /* R12 Lot Serial Genealogy Project : Modified call to procedure to include 2 new parameters p_object_id2, p_object_type2 */
      inv_populate_child(p_object_id, p_related_object_id, p_object_type, p_object_id2, p_object_type2);
  END inv_populate_child_tree;

  PROCEDURE inv_populate_parent(
    p_object_id         IN NUMBER
  , p_related_object_id IN NUMBER
  , p_object_type       IN NUMBER DEFAULT NULL
  , p_object_id2        IN NUMBER DEFAULT NULL
  , p_object_type2      IN NUMBER DEFAULT NULL
  ) IS
    l_count           NUMBER       := 0;
    l_previous_parent NUMBER       := 0;
    get_hierc         VARCHAR2(1)  := 'Y';

    -- get_hierc is used to decide whether to select the next level of nodes for the selected node
    -- do not get the next level, if the node has already been processed once.

    /* R12 Lot Serial Genealogy Project : Added cursors to job, direct genealogy types */
    CURSOR parent_cur IS
      SELECT parent_object_id
           , object_id
           , parent_object_type
           , parent_object_id2
           , parent_object_type2, object_id2,object_type2,object_type
       FROM mtl_object_genealogy
       WHERE object_id = p_object_id
         AND (p_object_id2 IS NULL OR object_id2 = p_object_id2)
         AND(end_date_active IS NULL
             OR end_date_active > SYSDATE);

    CURSOR search_cur IS
      SELECT   *
          FROM mtl_gen_temp
         WHERE treeno < g_treeno
           AND DEPTH < g_depth
      ORDER BY ind DESC;


   l_debug  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- First condition
    -- ===============
    -- Check if the p_object_id is the first node of the tree
    -- if yes, then no need to check other trees or nodes
     IF (l_debug = 1) THEN
       inv_trx_util_pub.TRACE('in the procedure inv_populate_parent', 'INV_OBJECT_GENEALOGY', 9);
       inv_trx_util_pub.TRACE('input param values to this proc are:', 'INV_OBJECT_GENEALOGY', 9);
       inv_trx_util_pub.TRACE('p_object_id is ' || p_object_id || 'p_object_type ' || p_object_type, 'INV_OBJECT_GENEALOGY', 9);
       inv_trx_util_pub.TRACE('p_object_id2 is ' || p_object_id2 || 'p_object_type2 ' || p_object_type2, 'INV_OBJECT_GENEALOGY', 9);
       inv_trx_util_pub.TRACE('p_related_object_id is ' || p_related_object_id, 'INV_OBJECT_GENEALOGY', 9);
     END IF;
    IF g_ind > 0 THEN
      BEGIN
        SELECT 1
          INTO l_count
          FROM mtl_gen_temp
         WHERE label = p_object_id
           AND related_label = 0
           AND (p_object_id2 is null or label2=p_object_id2)
           AND ROWNUM < 2;

        IF l_count > 0 THEN
          get_hierc  := 'N';
          g_ind      := g_ind + 1;

          IF l_debug =1 THEN
            inv_trx_util_pub.TRACE('insert1, g_ind '||g_ind, 'INV_OBJECT_GENEALOGY', 9);
          END IF;


          INSERT INTO mtl_gen_temp
                      (
                       ind
                     , treeno
                     , DEPTH
                     , label
                     , related_label
                     , child_object_type
                     , label2
                     , child_object_type2
                      )
               VALUES (
                       g_ind
                     , g_treeno
                     , g_depth
                     , p_object_id
                     , p_related_object_id
                     , p_object_type
                     , p_object_id2
                     , p_object_type2
                      );
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count  := 0;
          IF l_debug = 1 THEN
             inv_trx_util_pub.TRACE('exception 1', 'INV_OBJECT_GENEALOGY', 9);
          END IF;

      END;
    END IF;

    -- Second Condition
    -- ================
    IF g_ind > 1 and get_hierc='Y' THEN
      BEGIN
        SELECT 1
          INTO l_count
          FROM mtl_gen_temp
         WHERE treeno = g_treeno
           AND label = p_object_id
           AND (p_object_id2 is null or label2=p_object_id2)
           AND ROWNUM < 2;

        -- If the node already exists in the present tree , that means
        -- it need not be exploded further.
        IF l_count > 0 THEN
          get_hierc  := 'N';
          g_ind      := g_ind + 1;

          IF l_debug = 2 THEN
            inv_trx_util_pub.TRACE('insert2, g_ind '||g_ind, 'INV_OBJECT_GENEALOGY', 9);
          END IF;


          INSERT INTO mtl_gen_temp
                      (
                       ind
                     , treeno
                     , DEPTH
                     , label
                     , related_label
                     , child_object_type
                     , label2
                     , child_object_type2
                      )
               VALUES (
                       g_ind
                     , g_treeno
                     , g_depth
                     , p_object_id
                     , p_related_object_id
                     , p_object_type
                     , p_object_id2
                     , p_object_type2
                      );
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count  := 0;
          IF l_debug = 1 THEN
             inv_trx_util_pub.TRACE('exception 2', 'INV_OBJECT_GENEALOGY', 9);
          END IF;

      END;
    END IF;
    -- Third condition
    -- ===============
    IF get_hierc = 'Y'
       AND g_treeno > 1 THEN
      l_previous_parent  := 0;

      FOR cur_var IN search_cur LOOP
        IF cur_var.label = p_object_id
           AND cur_var.label = l_previous_parent THEN
          get_hierc  := 'N';
          g_ind      := g_ind + 1;

          IF l_debug = 3 THEN
            inv_trx_util_pub.TRACE('insert3, g_ind '||g_ind, 'INV_OBJECT_GENEALOGY', 9);
          END IF;


          INSERT INTO mtl_gen_temp
                      (
                       ind
                     , treeno
                     , DEPTH
                     , label
                     , related_label
                     , child_object_type
                     , label2
                     , child_object_type2
                      )
               VALUES (
                       g_ind
                     , g_treeno
                     , g_depth
                     , p_object_id
                     , p_related_object_id
                     , p_object_type
                     , p_object_id2
                     , p_object_type2
                      );

          EXIT;
        END IF;

        l_previous_parent  := cur_var.related_label;
      END LOOP;
    END IF;

    IF (get_hierc = 'Y') THEN
      g_ind  := g_ind + 1;

      IF l_debug =1 THEN
        inv_trx_util_pub.TRACE('insert4, g_ind '||g_ind, 'INV_OBJECT_GENEALOGY', 9);
      END IF;


      INSERT INTO mtl_gen_temp
                  (
                   ind
                 , treeno
                 , DEPTH
                 , label
                 , related_label
                 , child_object_type
                 , label2
                 , child_object_type2
                  )
           VALUES (
                   g_ind
                 , g_treeno
                 , g_depth
                 , p_object_id
                 , p_related_object_id
                 , p_object_type
                 , p_object_id2
                 , p_object_type2
                  );

      IF p_object_id <> p_related_object_id THEN
         FOR parent_rec IN parent_cur LOOP
              g_depth   := g_depth + 1;

              -- added the following condition, so that if for some reason there is an end-less
              -- loop, it will atleast stop after the depth of 45 and will not 'disconnect the server'
              -- Please note that if the user really has a hieracrchy that is more than 45 levels deep,
              -- The users may report a bug that the complete information is not diaplyes
              -- We do not expect anyone to have such a deep hierarchy
              IF g_depth > 45 THEN
                EXIT;
              END IF;

              inv_populate_parent(
                parent_rec.parent_object_id
              , parent_rec.object_id
              , parent_rec.parent_object_type
              , parent_rec.parent_object_id2
              , parent_rec.parent_object_type2
              );
              g_depth   := g_depth - 1;
              g_treeno  := g_treeno + 1;
          END LOOP;
      END IF;
     END IF;
  END inv_populate_parent;

  PROCEDURE inv_populate_parent_tree(
    p_object_id         IN NUMBER
  , p_related_object_id IN NUMBER
  , p_object_type       IN NUMBER DEFAULT NULL
  , p_object_id2        IN NUMBER DEFAULT NULL
  , p_object_type2      IN NUMBER DEFAULT NULL
  ) IS
    l_count       NUMBER;
    l_prev_parent NUMBER       := 1;
    l_min_level   NUMBER       := 1;
    -- Bug 8467584
    n_level       NUMBER;
    n_rows        NUMBER;

    /* R12 Lot Serial Genealogy Project : Modified cursor */
    --Bug 6600064, Added end_date_active condition in the START WITH clause in parent_cur
    --Bug 6643575, removed the where clause logic and moved it to the to connect by clause in parent_cur
    --Bug 8467584, added v_level_num filter
      CURSOR parent_cur(v_level_num NUMBER) IS
      SELECT     LEVEL
              , mog.parent_object_id
              , mog.object_id
              , mog.parent_object_type
              , mog.parent_object_id2
              , mog.parent_object_type2
           FROM mtl_object_genealogy mog
         -- WHERE end_date_active IS NULL
           --  OR end_date_active > SYSDATE
     START WITH (object_id = p_object_id AND (end_date_active IS NULL OR end_date_active > SYSDATE))
     CONNECT BY PRIOR parent_object_id = object_id
     AND (end_date_active IS NULL OR end_date_active > SYSDATE)
     AND LEVEL < v_level_num;


    /* End of R12 Lot Serial Genealogy Project */
   l_debug  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);



    BEGIN
       IF (l_debug = 1) THEN
         inv_trx_util_pub.TRACE('in the procedure inv_populate_parent_tree', 'INV_OBJECT_GENEALOGY', 9);
         inv_trx_util_pub.TRACE('input param values to this proc are:', 'INV_OBJECT_GENEALOGY', 9);
         inv_trx_util_pub.TRACE('p_object_id is ' || p_object_id || 'p_object_type ' || p_object_type, 'INV_OBJECT_GENEALOGY', 9);
         inv_trx_util_pub.TRACE('p_object_id2 is ' || p_object_id2 || 'p_object_type2 ' || p_object_type2, 'INV_OBJECT_GENEALOGY', 9);
         inv_trx_util_pub.TRACE('p_related_object_id is ' || p_related_object_id, 'INV_OBJECT_GENEALOGY', 9);
       END IF;

    inv_object_genealogy.init;
    g_ind          := g_ind + 1;
    l_prev_parent  := p_related_object_id;

    INSERT INTO mtl_gen_temp
                (
                 ind
               , treeno
               , DEPTH
               , label
               , related_label
               , child_object_type
               , label2
               , child_object_type2
                )
         VALUES (
                 g_ind
               , g_treeno
               , g_depth
               , p_object_id
               , p_related_object_id
               , p_object_type
               , p_object_id2
               , p_object_type2
                );

    --IF g_jData=1 THEN
      -- Dynamic Level calculation: bug 8467584
      -- Start with n_level = 2, calculate number of rows fetched (n_rows), compare with g_rowlimit.
      -- If less, increment n_level. Continue till n_rows > g_rowlimit.
      -- Pass (level - 1) to cursor.

      n_level := 2;
      n_rows := 1;

      LOOP
        SELECT   Count(*)
        INTO n_rows
        FROM mtl_object_genealogy
        --WHERE level < n_level
        START WITH (object_id=p_object_id AND (end_date_active IS NULL OR end_date_active > SYSDATE))
        CONNECT BY PRIOR parent_object_id = object_id
        AND (end_date_active IS NULL OR end_date_active > SYSDATE)
        AND LEVEL < n_level;

        EXIT WHEN (n_rows > (g_rowlimit-1) OR n_rows = 0 OR n_level > 45);
        --assuming g_rowlimit records to be a 'safe' limit for displaying genealogy
        --max levels displayed: 45 (hard-coded in inv_populate_child)
        n_level := n_level + 1;
      END LOOP;

      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE('Fetching parent_cur for level='||(n_level-1), 'INV_OBJECT_GENEALOGY', 9);
      END IF;

      FOR parent_rec IN parent_cur(n_level-1) LOOP
         IF parent_rec.parent_object_id = l_prev_parent THEN
           g_treeno  := g_treeno + 1;
         END IF;

         IF l_min_level = parent_rec.LEVEL THEN
           g_treeno  := g_ind;
         END IF;

         IF g_depth < parent_rec.LEVEL + 1 THEN
           g_depth  := parent_rec.LEVEL + 1;
         END IF;

         g_ind          := g_ind + 1;

         INSERT INTO mtl_gen_temp
                     (
                      ind
                    , treeno
                    , DEPTH
                    , label
                    , related_label
                    , child_object_type
                    , label2
                    , child_object_type2
                     )
              VALUES (
                       g_ind
                      ,g_treeno
                      ,parent_rec.level+1
                      ,parent_rec.parent_object_id
                      ,parent_rec.object_id
                      ,parent_rec.parent_object_type
                      ,parent_rec.parent_object_id2
                     ,parent_rec.parent_object_type2);

          l_prev_parent  := parent_rec.parent_object_id;
       END LOOP;
      --END IF;
   EXCEPTION
      WHEN OTHERS THEN
        IF l_debug = 1 THEN
            inv_log_util.trace('Exception:'||SQLERRM,'INV_OBJECT_GENEALOGY',9);
        END IF;
        inv_object_genealogy.init;
        inv_populate_parent(p_object_id, p_related_object_id, p_object_type, p_object_id2, p_object_type2);
   END inv_populate_parent_tree;

   -- Bug 8467584
   PROCEDURE set_rowlimit(p_numrows IN NUMBER)
   IS
    l_debug  NUMBER := Nvl(fnd_profile.Value('INV_DEBUG_TRACE'), 0);
   BEGIN
        IF g_rowlimit <> p_numrows THEN
            g_rowlimit := p_numrows;
        END IF;
        IF l_debug=1 THEN
          inv_trx_util_pub.TRACE('g_rowlimit='||g_rowlimit, 'INV_OBJECT_GENEALOGY', 9);
        END IF;
   END;

END inv_object_genealogy;

/
