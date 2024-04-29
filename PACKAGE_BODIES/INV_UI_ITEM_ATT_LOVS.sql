--------------------------------------------------------
--  DDL for Package Body INV_UI_ITEM_ATT_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_UI_ITEM_ATT_LOVS" AS
  /* $Header: INVITATB.pls 120.12.12010000.6 2010/02/22 16:51:51 rkatoori ship $ */

  -- This is equivalent to inv_serial4 in the serial entry form INVTTESR
  PROCEDURE get_serial_lov_rcv(x_serial_number OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_serial IN VARCHAR2, p_transaction_type_id IN NUMBER, p_wms_installed IN VARCHAR2) IS
  BEGIN
    OPEN x_serial_number FOR
      SELECT   serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , 0
             , current_status
             , mms.status_code
          FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
         WHERE inventory_item_id = p_item_id
           AND (group_mark_id IS NULL
                OR group_mark_id = -1
               )
           AND ((current_organization_id = p_organization_id
                 AND current_status = 1
                )
                OR (current_status = 4 AND
                    Nvl(to_number(fnd_profile.value('INV_RESTRICT_RCPT_SER')), 2) = 2
                )
               )
           AND msn.status_id = mms.status_id(+)
           AND mms.language (+) = userenv('LANG')
           AND serial_number LIKE (p_serial)
           AND inv_material_status_grp.is_status_applicable(p_wms_installed, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, NULL, NULL, NULL, serial_number, 'S') = 'Y'
      ORDER BY LPAD(serial_number, 20);
  END get_serial_lov_rcv;

  -- This is equivalent to inv_serial3 in the serial entry form INVTTESR

  PROCEDURE get_serial_lov_rma_rcv(x_serial_number OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_serial IN VARCHAR2, p_transaction_type_id IN NUMBER, p_wms_installed IN VARCHAR2, p_oe_order_header_id IN NUMBER) IS

 l_return_status            VARCHAR2(1)  := fnd_api.g_ret_sts_success;
 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(4000);
 l_errorcode                  VARCHAR2(4000);
 l_enforce_rma_sn           VARCHAR2(10);

  BEGIN

    -- Bug 3907968
    -- Changes applicable for patchJ onwards
    -- File needed  for I branch is ARU: 3439979 and 3810978
    -- GET the SERIAL ENFORCE paramneter from Receiving Options
    -- IF enforce is YES
    --   then
    --      For all Order lines matching with the ITEM call INV_RMA_SERIAL_PVT.POPULATE_TEMP_TABLE
    --      to populate the temporary serial table MTL_RMA_SERIAL_TEMP
    --      Modify the LOV to join with MTL_RMA_SERIAL_TEMP
    -- Else
    --   the Existing LOV
    -- End if

    select nvl(ENFORCE_RMA_SERIAL_NUM,'N')
      into   l_enforce_rma_sn
      from   RCV_PARAMETERS
     where  organization_id = p_organization_id;

    IF ( l_enforce_rma_sn = 'Y' and p_oe_order_header_id is not null) THEN

              For c_rma_line in ( select line_id
            FROM
                  OE_ORDER_LINES_all OEL,
                  OE_ORDER_HEADERS_all OEH
           WHERE OEL.LINE_CATEGORY_CODE='RETURN'
             AND OEL.INVENTORY_ITEM_ID = p_item_id
             AND nvl(OEL.SHIP_FROM_ORG_ID, OEH.SHIP_FROM_ORG_ID) = p_organization_id
             AND OEL.HEADER_ID = OEH.HEADER_ID
             AND OEH.HEADER_ID = p_oe_order_header_id
             AND OEL.ORDERED_QUANTITY > NVL(OEL.SHIPPED_QUANTITY,0)
             AND OEL.FLOW_STATUS_CODE = 'AWAITING_RETURN'
                                 )
               Loop

                INV_RMA_SERIAL_PVT.POPULATE_TEMP_TABLE(
                  p_api_version => 0.9
                , p_init_msg_list => FND_API.G_FALSE
                , p_commit => FND_API.G_FALSE
                , p_validation_level => FND_API.G_VALID_LEVEL_FULL
                , x_return_status => l_return_status
                , x_msg_count => l_msg_count
                , x_msg_data => l_msg_data
                , x_errorcode => l_errorcode
                , p_rma_line_id => c_rma_line.LINE_ID
                , p_org_id => P_ORGANIZATION_ID
                , p_item_id => p_item_id
                );

               -- No error check from the Previous API.

               End loop;

               -- Set the new LOV below..
               OPEN x_serial_number FOR
               SELECT   serial_number
                      , current_subinventory_code
                      , current_locator_id
                      , lot_number
                      , 0
                      , current_status
                      , mms.status_code
                   FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
                  WHERE msn.inventory_item_id = p_item_id
                    AND (group_mark_id IS NULL
                         OR group_mark_id = -1
                        )
                    AND current_status = 4
                    AND msn.status_id = mms.status_id(+)
                    AND mms.language (+) = userenv('LANG')
                    AND inv_material_status_grp.is_status_applicable(p_wms_installed, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, NULL, NULL, NULL, serial_number, 'S') = 'Y'
                    AND msn.serial_number LIKE (p_serial)
                    AND EXISTS ( select 'x' from mtl_rma_serial_temp msrt
                                  where msrt.organization_id = p_organization_id
                                   and  msrt.inventory_item_id = p_item_id
                                   and msrt.serial_number = msn.serial_number
                                   and msrt.serial_number LIKE (p_serial)
                               )
               ORDER BY LPAD(serial_number, 20);

    Else
               -- the OLD LOV will work and will not restrict
               OPEN x_serial_number FOR
                 SELECT   serial_number
                        , current_subinventory_code
                        , current_locator_id
                        , lot_number
                        , 0
                        , current_status
                        , mms.status_code
                     FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
                    WHERE inventory_item_id = p_item_id
                      AND (group_mark_id IS NULL
                           OR group_mark_id = -1
                          )
                      AND current_status = 4
                      AND msn.status_id = mms.status_id(+)
                      AND mms.language (+) = userenv('LANG')
                      AND inv_material_status_grp.is_status_applicable(p_wms_installed, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, NULL, NULL, NULL, serial_number, 'S') = 'Y'
                      AND serial_number LIKE (p_serial)
                 ORDER BY LPAD(serial_number, 20);
    End if;
  END get_serial_lov_rma_rcv;

  -- This is equivalent to inv_serial7 in the serial entry form INVTTESR

  -- Bug #3350460
  -- Added a new parameter (default NULL) to pass the ID of the From LPN
  -- The serials will be filtered on the LPNs they are a part of while shipping
  -- This is applicable only if WMS and PO J are installed
  PROCEDURE get_serial_lov_int_shp_rcv(
    x_serial_number       OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_shipment_header_id  IN     NUMBER
  , p_lot_num             IN     VARCHAR2
  , p_serial              IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_from_lpn_id         IN     NUMBER DEFAULT NULL
  ) IS
    l_src_org_lot_ctrl  NUMBER := 1;
    l_rcv_org_lot_ctrl  NUMBER := 1;
    l_src_org_srl_ctrl  NUMBER := 1;
    l_source_document_code rcv_shipment_lines.source_document_code%TYPE;
  BEGIN

    BEGIN
      --Get the lot control in source and receiving orgs and the
      --serial control code in the sending org
      SELECT msi1.lot_control_code src_lot_ctrl
           , msi1.serial_number_control_code src_srl_ctrl
           , msi2.lot_control_code rcv_lot_ctrl
           , rsl.source_document_code
      INTO   l_src_org_lot_ctrl
           , l_src_org_srl_ctrl
           , l_rcv_org_lot_ctrl
           , l_source_document_code
      FROM   mtl_system_items msi1
           , mtl_system_items msi2
           , rcv_shipment_lines rsl
      WHERE  rsl.shipment_header_id   = p_shipment_header_id
      AND    rsl.to_organization_id   = p_organization_id
      AND    rsl.item_id              = p_item_id
      AND    msi1.inventory_item_id   = p_item_id
      AND    msi1.organization_id     = rsl.from_organization_id
      AND    msi1.inventory_item_id   = msi2.inventory_item_id
      AND    msi2.organization_id     = p_organization_id
      AND    ROWNUM=1;
    EXCEPTION
      WHEN OTHERS THEN
        l_src_org_lot_ctrl := 1;
        l_src_org_srl_ctrl := 1;
        l_rcv_org_lot_ctrl := 'INVENTORY';
    END;

    --For intransit shipment, if serial control code in source org is
    --dynamic at SO Issue, serials would not be shipped and treat serial control code as 1
    IF l_source_document_code = 'INVENTORY' AND l_src_org_srl_ctrl = 6 THEN
      l_src_org_srl_ctrl := 1;
    END IF;

    --If the item is serial controlled in the source organization, then the
    --shipped serials would be there in rcv_serials_supply and we should be
    --filter the serials in RSS and MSN
    IF (l_src_org_srl_ctrl <> 1) THEN
      OPEN x_serial_number FOR
        SELECT   msn.serial_number
               , ''
               , 0
               , rss.lot_num
               , 0
               , msn.current_status
               , mms.status_code
        FROM     rcv_serials_supply rss
               , rcv_shipment_lines rsl
               , mtl_serial_numbers msn
               , mtl_material_statuses_tl mms
        WHERE    rss.shipment_line_id(+) = rsl.shipment_line_id
 --BUG 3417870: The RSL.shipment_line_status_code will be FULLY
 -- RECEIVED, so we need to comment it out.
 --        AND      rsl.shipment_line_status_code <> 'FULLY RECEIVED'
 AND      nvl(rss.supply_type_code, 'SHIPMENT') = 'SHIPMENT'
        AND     (msn.group_mark_id IS NULL OR msn.group_mark_id = -1)
        AND      rsl.shipment_header_id = p_shipment_header_id
        AND      rsl.to_organization_id = p_organization_id
        AND      rsl.item_id = p_item_id
        AND      msn.inventory_item_id = p_item_id
        AND      msn.serial_number = rss.serial_num
        AND      msn.current_status = 5
 AND      Nvl(msn.lpn_id,NVL(p_from_lpn_id,-1)) = NVL(p_from_lpn_id, NVL(msn.lpn_id, -1))
        AND (   (l_rcv_org_lot_ctrl = 1 OR l_src_org_lot_ctrl = 1) OR
                ((l_rcv_org_lot_ctrl = 2 AND l_src_org_lot_ctrl = 2) AND
                 (Nvl(rss.lot_num,'@@@') = Nvl(p_lot_num,'@@@')))
            )
        AND      msn.status_id = mms.status_id(+)
        AND      mms.language (+) = userenv('LANG')
        AND      inv_material_status_grp.is_status_applicable(
                       p_wms_installed
                     , p_transaction_type_id
                     , NULL
                     , NULL
                     , p_organization_id
                     , p_item_id
                     , NULL
                     , NULL
                     , NULL
                     , msn.serial_number
                     , 'S') = 'Y'
        AND      msn.serial_number LIKE (p_serial)
        ORDER BY LPAD(msn.serial_number, 20);

    --If the item is not serial controlled in source org, then fetch the
    --serials from mtl_serial_numbers which reside in the receiving org
    -- bug #5508238, Displaying ISSUED OUT serials in the LOV if the profile
    --   'INV: Restrict receipt of serials' is set to "No"
    ELSE
      OPEN x_serial_number FOR
        SELECT   msn.serial_number
               , ''
               , 0
               , p_lot_num
               , 0
               , msn.current_status
               , mms.status_code
        FROM     mtl_serial_numbers msn
               , rcv_shipment_lines rsl
               , mtl_material_statuses_tl mms
        WHERE    msn.inventory_item_id = p_item_id
        AND      rsl.shipment_header_id = p_shipment_header_id
        AND     (msn.group_mark_id IS NULL OR msn.group_mark_id = -1)
        AND     ( (    msn.current_status IN (1, 6)
                   AND msn.current_organization_id = p_organization_id
                  ) OR
 	                (    msn.current_status = 4
 	                 AND nvl(to_number(fnd_profile.value('INV_RESTRICT_RCPT_SER')), 2) = 2
 	              ) )
        AND      rsl.shipment_line_status_code <> 'FULLY RECEIVED'
        AND      rsl.to_organization_id = p_organization_id
        AND      rsl.item_id = p_item_id
        AND      msn.status_id = mms.status_id(+)
        AND      mms.language (+) = userenv('LANG')
        AND      inv_material_status_grp.is_status_applicable(
                       p_wms_installed
                     , p_transaction_type_id
                     , NULL
                     , NULL
                     , p_organization_id
                     , p_item_id
                     , NULL
                     , NULL
                     , NULL
                     , msn.serial_number
                     , 'S') = 'Y'
        AND      msn.serial_number LIKE (p_serial)
        ORDER BY LPAD(msn.serial_number, 20);
    END IF;   --END IF check serial control code in src org
  END get_serial_lov_int_shp_rcv;

  --      Name: GET_SERIAL_LOV_LMT
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           which restricts LOV SQL to current item
  --       p_subinv_code       restricts to Subinventory
  --       p_locator_id        restricts to Locator ID. If not used, set to -1
  --       p_serial            which restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers limited by
  --       the specified Subinventory and Locator with status = 3;
  --
  PROCEDURE get_serial_lov_lmt(
    x_serial_number       OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_subinv_code         IN     VARCHAR2
  , p_locator_id          IN     NUMBER
  , p_serial              IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_group_mark_id       IN     NUMBER := NULL
  ) IS

/* Bug 9121707 In the cursor x_serial_number Changed the is_status_applicable API call to 'A' from 'S' */

  BEGIN
    OPEN x_serial_number FOR
      SELECT   serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , 0
             , current_status
             , mms.status_code
          FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
         WHERE inventory_item_id = p_item_id
           AND (group_mark_id IS NULL
                OR group_mark_id = -1
                OR group_mark_id in (select a.serial_transaction_temp_id from mtl_transaction_lots_temp a
                                     where a.transaction_temp_id = p_group_mark_id)
                OR group_mark_id = p_group_mark_id
               )
           AND (line_mark_id IS NULL
                OR line_mark_id = -1
                OR line_mark_id in (select a.serial_transaction_temp_id from mtl_transaction_lots_temp a
                                     where a.transaction_temp_id = p_group_mark_id)
                OR line_mark_id = p_group_mark_id)
           AND current_organization_id = p_organization_id
           AND current_status = 3
           AND current_subinventory_code = p_subinv_code
           AND msn.lpn_id IS NULL
           AND NVL(current_locator_id, 0) = NVL(DECODE(p_locator_id, -1, current_locator_id, p_locator_id), 0)
           AND msn.status_id = mms.status_id(+)
           AND mms.language (+) = userenv('LANG')
           AND serial_number LIKE (p_serial)
           AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinv_code, msn.current_locator_id, msn.lot_number, msn.serial_number, 'A') = 'Y'
      ORDER BY LPAD(serial_number, 20);
  END;

  PROCEDURE get_lot_info(
    p_organization_id       IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_lot_number            IN     VARCHAR2
  , p_shelf_life_code       IN     NUMBER
  , p_shelf_life_days       IN     NUMBER
  , p_lot_status_enabled    IN     VARCHAR2
  , p_default_lot_status_id IN     NUMBER
  , p_wms_installed         IN     VARCHAR2
  , x_expiration_date       OUT    NOCOPY DATE
  , x_is_new_lot            OUT    NOCOPY VARCHAR2
  , x_is_valid_lot          OUT    NOCOPY VARCHAR2
  , x_lot_status            OUT    NOCOPY VARCHAR2
  ) IS
    l_valid_lot     BOOLEAN      := TRUE;
    l_wms_installed VARCHAR2(10) := 'FALSE';
    l_number        NUMBER;
  BEGIN
    x_expiration_date  := '';
    x_lot_status       := '';

    IF (p_wms_installed = 'I'
        OR p_wms_installed = 'TRUE'
       ) THEN
      l_wms_installed  := 'TRUE';
    END IF;

    l_valid_lot        := inv_lot_api_pub.validate_unique_lot(p_organization_id, p_inventory_item_id, '', p_lot_number);

    IF l_valid_lot THEN
      x_is_valid_lot  := 'TRUE';
    ELSE
      x_is_valid_lot  := 'FALSE';
      RETURN;
    END IF;

    IF p_shelf_life_code = 1 THEN
      BEGIN
        SELECT status_id
          INTO l_number
          FROM mtl_lot_numbers
         WHERE organization_id = p_organization_id
           AND inventory_item_id = p_inventory_item_id
           AND lot_number = p_lot_number;

        x_is_new_lot  := 'FALSE';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_is_new_lot  := 'TRUE';
      END;


      -- Bug 7654189 Wms Installed is not required as
      -- Lot Status Enabled can be used for INV Orgs also.
      IF (
          --l_wms_installed = 'TRUE' AND
          p_lot_status_enabled = 'Y'
         ) THEN
        BEGIN
          SELECT NVL(status_code, '')
            INTO x_lot_status
            FROM mtl_material_statuses_tl mms
           WHERE mms.status_id = NVL(l_number, p_default_lot_status_id)
                 AND mms.language = userenv('LANG');
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_lot_status  := '';
        END;
      END IF;

      RETURN;
    ELSE
      BEGIN
        SELECT   expiration_date
               , NVL(status_code, '')
            INTO x_expiration_date
               , x_lot_status
            FROM mtl_lot_numbers_all_v
           WHERE organization_id = p_organization_id
             AND inventory_item_id = p_inventory_item_id
             AND lot_number = p_lot_number
             AND ROWNUM < 2
        ORDER BY expiration_date;

        x_is_new_lot  := 'FALSE';

        IF x_expiration_date IS NULL THEN
          IF p_shelf_life_code = 2 THEN
            SELECT (SYSDATE + NVL(p_shelf_life_days, 0))
              INTO x_expiration_date
              FROM DUAL;
          END IF;
        END IF;

        RETURN;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_is_new_lot  := 'TRUE';

           -- Bug 7654189 Wms Installed is not required as
           -- Lot Status Enabled can be used for INV Orgs also.

          IF (
              --l_wms_installed = 'TRUE' AND
              p_lot_status_enabled = 'Y'
             ) THEN
            BEGIN
              SELECT NVL(status_code, '')
                INTO x_lot_status
                FROM mtl_material_statuses_tl mms
               WHERE mms.status_id = p_default_lot_status_id
                     AND mms.language = userenv('LANG');
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                x_lot_status  := '';
            END;
          END IF;

          IF p_shelf_life_code = 2 THEN
            SELECT (SYSDATE + NVL(p_shelf_life_days, 0))
              INTO x_expiration_date
              FROM DUAL;
          END IF;

          RETURN;
      END;
    END IF;

    RETURN;
  END get_lot_info;

  -- procedure to get the serial information in case of a dynamically entered
  -- serial number.
  PROCEDURE get_serial_info(p_item_id IN NUMBER, p_serial IN VARCHAR2, p_serial_status_enabled IN VARCHAR2, p_default_serial_status IN NUMBER, p_wms_installed IN VARCHAR2, x_current_status OUT NOCOPY VARCHAR2, x_serial_status OUT NOCOPY VARCHAR2) IS
    l_wms_installed VARCHAR2(10) := 'FALSE';
  BEGIN
    IF (p_wms_installed = 'I'
        OR p_wms_installed = 'TRUE'
       ) THEN
      l_wms_installed  := 'TRUE';
    END IF;

    BEGIN
      -- Bug 2263020
      -- Modified the following to fix the problem where the STATUS field
      -- shows in the mobile page even when item is not serial status enabled
      -- The value for x_serial_status needs to be set only when the serial
      -- is SERIAL STATUS ENABLED.
      x_serial_status  := '';


      -- Bug 7654189 Wms Installed is not required as
      -- Lot Status Enabled can be used for INV Orgs also.
      IF (
          --l_wms_installed = 'TRUE' AND
          p_serial_status_enabled = 'Y'
         ) THEN
        SELECT msn.current_status
             , NVL(mms.status_code, '')
          INTO x_current_status
             , x_serial_status
          FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
         WHERE msn.inventory_item_id = p_item_id
           AND msn.serial_number = p_serial
           AND msn.status_id = mms.status_id(+)
           AND mms.language (+) = userenv('LANG');
      ELSE
        SELECT msn.current_status
          INTO x_current_status
          FROM mtl_serial_numbers msn
         WHERE msn.inventory_item_id = p_item_id
           AND msn.serial_number = p_serial;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_current_status  := 6;

         -- Bug 7654189 Wms Installed is not required as
         -- Lot Status Enabled can be used for INV Orgs also.

        IF (
            --l_wms_installed = 'TRUE' AND
            p_serial_status_enabled = 'Y'
           ) THEN
          BEGIN
            SELECT NVL(mms.status_code, '')
              INTO x_serial_status
              FROM mtl_material_statuses_tl mms
             WHERE mms.status_id = p_default_serial_status
                   AND mms.language (+) = userenv('LANG');
          EXCEPTION
            WHEN OTHERS THEN
              x_serial_status  := '';
          END;
        END IF;
    END;
  END get_serial_info;

  --During an issue, if it is the first serial number then
  --we can accept any serial that resides in stores
  --however, after the first serial has been scanned we must
  --make sure that all subsequent serials are from the same
  --locator and same sub.
  --Consignment and VMI Changes - Added Planning Org and TP Type and Owning Org and TP Type.
  PROCEDURE get_valid_serial_issue(
    x_rserials                  OUT    NOCOPY t_genref
  , p_current_organization_id   IN     NUMBER
  , p_revision                  IN     VARCHAR2
  , p_current_subinventory_code IN     VARCHAR2
  , p_current_locator_id        IN     NUMBER
  , p_current_lot_number        IN     VARCHAR2
  , p_inventory_item_id         IN     NUMBER
  , p_serial_number             IN     VARCHAR2
  , p_transaction_type_id       IN     NUMBER
  , p_wms_installed             IN     VARCHAR2
  , p_lpn_id                    IN     NUMBER
  , p_planning_org_id           IN     NUMBER
  , p_planning_tp_type          IN     NUMBER
  , p_owning_org_id             IN     NUMBER
  , p_owning_tp_type            IN     NUMBER
  ) IS
  BEGIN
    IF p_current_subinventory_code IS NULL THEN
      OPEN x_rserials FOR
        SELECT a.serial_number
             , a.current_subinventory_code
             , a.current_locator_id
             , a.lot_number
             , b.expiration_date
             , a.current_status
             , mms.status_code
             , inv_project.get_locsegs(a.current_locator_id, p_current_organization_id)
             , inv_project.get_project_id
             , inv_project.get_project_number
             , inv_project.get_task_id
             , inv_project.get_task_number
          FROM mtl_serial_numbers a, mtl_lot_numbers b, mtl_material_statuses_tl mms
         WHERE a.current_organization_id = p_current_organization_id
           AND NVL(a.lpn_id, -1) = NVL(p_lpn_id, -1)
           AND a.inventory_item_id = p_inventory_item_id
           AND (a.group_mark_id IS NULL OR a.group_mark_id = -1)
           AND ((a.revision = p_revision)
                OR (a.revision IS NULL AND p_revision IS NULL))
           AND a.current_status = 3
           AND b.inventory_item_id(+) = a.inventory_item_id
           AND b.organization_id(+) = a.current_organization_id
           AND b.lot_number(+) = a.lot_number
           AND mms.status_id(+) = a.status_id
           AND mms.language (+) = userenv('LANG')
           AND a.serial_number LIKE (p_serial_number)
           AND (p_planning_org_id IS NULL
                OR planning_organization_id = p_planning_org_id)
           AND (p_planning_tp_type IS NULL
                OR planning_tp_type = p_planning_tp_type)
           AND (p_owning_org_id IS NULL
                OR owning_organization_id = p_owning_org_id)
           AND (p_owning_tp_type IS NULL
                OR owning_tp_type = p_owning_tp_type)
           AND a.serial_number LIKE (p_serial_number)
           AND inv_material_status_grp.is_status_applicable(
                 p_wms_installed
               , NULL
               , p_transaction_type_id
               , NULL
               , NULL
               , p_current_organization_id
               , p_inventory_item_id
               , a.current_subinventory_code
               , a.current_locator_id
               , a.lot_number
               , a.serial_number
               , 'A'
               ) = 'Y' -- modified by mxgupta because we want to check all statuses (lot and serial)
         ORDER BY a.serial_number;
    ELSE
      OPEN x_rserials FOR
        SELECT a.serial_number
             , a.current_subinventory_code
             , NVL(a.current_locator_id, -1)
             , a.lot_number
             , b.expiration_date
             , a.current_status
             , mms.status_code
             , inv_project.get_locsegs(a.current_locator_id, p_current_organization_id)
             , inv_project.get_project_id
             , inv_project.get_project_number
             , inv_project.get_task_id
             , inv_project.get_task_number
          FROM mtl_serial_numbers a, mtl_lot_numbers b, mtl_material_statuses_tl mms
         WHERE a.current_organization_id = p_current_organization_id
           AND NVL(a.lpn_id, -1) = NVL(p_lpn_id, -1)
           AND a.inventory_item_id = p_inventory_item_id
           AND a.current_subinventory_code = p_current_subinventory_code
           AND (a.group_mark_id IS NULL OR a.group_mark_id = -1)
           AND a.current_status = 3
           AND mms.status_id(+) = a.status_id
           AND mms.language (+) = userenv('LANG')
           AND ((a.revision = p_revision)
                OR (a.revision IS NULL AND p_revision IS NULL))
           AND ((a.current_locator_id = p_current_locator_id)
                OR (a.current_locator_id IS NULL
                    AND (p_current_locator_id IS NULL OR p_current_locator_id = -1))) -- Bug2564817
           AND b.inventory_item_id(+) = a.inventory_item_id
           AND b.organization_id(+) = a.current_organization_id
           AND b.lot_number(+) = a.lot_number
           AND (p_planning_org_id IS NULL
                OR planning_organization_id = p_planning_org_id)
           AND (p_planning_tp_type IS NULL
                OR planning_tp_type = p_planning_tp_type)
           AND (p_owning_org_id IS NULL
                OR owning_organization_id = p_owning_org_id)
           AND (p_owning_tp_type IS NULL
                OR owning_tp_type = p_owning_tp_type)
           AND a.serial_number LIKE (p_serial_number)
           AND inv_material_status_grp.is_status_applicable(
                 p_wms_installed
               , NULL
               , p_transaction_type_id
               , NULL
               , NULL
               , p_current_organization_id
               , p_inventory_item_id
               , p_current_subinventory_code
               , a.current_locator_id
               , a.lot_number
               , a.serial_number
               , 'S'
               ) = 'Y'
         ORDER BY a.serial_number;
    END IF;
  END get_valid_serial_issue;

  PROCEDURE get_cost_group_lov(x_cost_group OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN VARCHAR2, p_subinventory_code IN VARCHAR2, p_locator_id IN VARCHAR2, p_cost_group IN VARCHAR2) IS
  BEGIN
    OPEN x_cost_group FOR
      SELECT cost_group
           , cost_group_id
           , description
        FROM cst_cost_groups
       WHERE NVL(organization_id, p_organization_id) = p_organization_id
         AND cost_group_type = 3
         AND cost_group LIKE (p_cost_group)
         AND cost_group_id IN (SELECT cost_group_id
                                 FROM mtl_onhand_quantities_detail moq
                                WHERE organization_id = p_organization_id
                                  AND NVL(subinventory_code, '@') = NVL(p_subinventory_code, NVL(subinventory_code, '@'))
                                  AND NVL(locator_id, -999) = NVL(TO_NUMBER(p_locator_id), NVL(locator_id, -999))
                                  AND inventory_item_id = NVL(TO_NUMBER(p_inventory_item_id), inventory_item_id));
  END get_cost_group_lov;

  PROCEDURE get_phyinv_serial_lov(
    x_serials               OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_serial_number         IN     VARCHAR2
  , p_lot_number            IN     VARCHAR2
  , p_dynamic_entry_flag    IN     NUMBER
  , p_physical_inventory_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  ) IS
  BEGIN
    IF (p_dynamic_entry_flag = 1) THEN -- Dynamic entries are allowed
    /*Bug7829724 Commented locator*/
      OPEN x_serials FOR
       SELECT  serial_number
              ,current_subinventory_code
              ,current_locator_id
              ,lot_number
              ,0
              ,current_status
              ,status_code
       FROM
        (
          SELECT serial_number
                ,current_subinventory_code
                ,current_locator_id
                ,lot_number
                ,0
                ,current_status
                ,mms.status_code
          FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
          WHERE inventory_item_id = p_inventory_item_id
          AND (group_mark_id IS NULL
                  OR group_mark_id = -1
              )
          AND ((current_organization_id = p_organization_id
                 AND current_status IN (1, 3, 4, 6)
               )
                 OR current_status = 5
              )
          AND msn.current_subinventory_code = p_subinventory_code
          --AND NVL(msn.current_locator_id, -99999) = NVL(p_locator_id, -99999)
          AND (NVL(msn.lot_number, '###') = NVL(p_lot_number, '###')
                 OR current_status IN (1, 6)
              ) --newly generated
          AND serial_number LIKE (p_serial_number)
          AND msn.status_id = mms.status_id(+)
          AND mms.language (+) = userenv('LANG')
          UNION
          SELECT serial_number
             ,current_subinventory_code
                ,current_locator_id
  ,lot_number
  ,0
  ,current_status
  ,mms.status_code
          FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
   WHERE inventory_item_id = p_inventory_item_id
          AND (group_mark_id IS NULL OR group_mark_id = -1)
          AND ((current_organization_id = p_organization_id
   AND current_status =1
        )
   OR current_status = 5
       )
   AND serial_number LIKE (p_serial_number)
          AND msn.status_id = mms.status_id(+)
          AND mms.language (+) = userenv('LANG')
   ) ORDER BY SERIAL_NUMBER;
    ELSE -- Dynamic entries are not allowed
      OPEN x_serials FOR
        SELECT UNIQUE msn.serial_number
                    , msn.current_subinventory_code
                    , msn.current_locator_id
                    , msn.lot_number
                    , 0
                    , msn.current_status
                    , mms.status_code
                 FROM mtl_serial_numbers msn, mtl_physical_inventory_tags mpit, mtl_material_statuses_tl mms
                WHERE msn.inventory_item_id = p_inventory_item_id
                  AND (msn.group_mark_id IS NULL
                       OR msn.group_mark_id = -1
                      )
                  AND ((msn.current_organization_id = p_organization_id
                        AND msn.current_status IN (3, 4)
                       )
                       OR msn.current_status = 5
                      )
                  AND msn.current_subinventory_code = p_subinventory_code
                  AND NVL(msn.current_locator_id, -99999) = NVL(p_locator_id, -99999)
                  AND NVL(msn.lot_number, '###') = NVL(p_lot_number, '###')
                  AND msn.serial_number LIKE (p_serial_number)
                  AND msn.serial_number = mpit.serial_num
                  AND msn.status_id = mms.status_id(+)
                  AND mms.language (+) = userenv('LANG')
                  AND mpit.physical_inventory_id = p_physical_inventory_id
                  AND mpit.inventory_item_id = p_inventory_item_id
                  AND mpit.organization_id = p_organization_id
                  AND NVL(mpit.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
                  AND NVL(mpit.void_flag, 2) = 2
                  AND mpit.adjustment_id IN (SELECT adjustment_id
                                               FROM mtl_physical_adjustments
                                              WHERE physical_inventory_id = p_physical_inventory_id
                                                AND organization_id = p_organization_id
                                                AND approval_status IS NULL)
                  ORDER BY LPAD(msn.serial_number, 20);
    END IF;
  END get_phyinv_serial_lov;

  PROCEDURE get_phyinv_to_serial_lov(
    x_serials               OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_to_serial_number      IN     VARCHAR2
  , p_lot_number            IN     VARCHAR2
  , p_dynamic_entry_flag    IN     NUMBER
  , p_physical_inventory_id IN     NUMBER
  , p_from_serial_number    IN     VARCHAR2
  , p_parent_lpn_id         IN     NUMBER
  ) IS
    l_prefix       VARCHAR2(30);
    l_quantity     NUMBER;
    l_from_number  NUMBER;
    l_to_number    NUMBER;
    l_errorcode    NUMBER;
    l_temp_boolean BOOLEAN;
  BEGIN
    l_temp_boolean  := mtl_serial_check.inv_serial_info(p_from_serial_number, NULL, l_prefix, l_quantity, l_from_number, l_to_number, l_errorcode);

    IF (p_dynamic_entry_flag = 1) THEN -- Dynamic entries are allowed
      OPEN x_serials FOR
       SELECT serial_number
             ,current_subinventory_code
             ,current_locator_id
             ,lot_number
             ,0
             ,current_status
             ,status_code
       FROM (SELECT serial_number, current_subinventory_code, current_locator_id,
                 lot_number, 0, current_status, mms.status_code
             FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
             WHERE inventory_item_id = p_inventory_item_id
             AND (group_mark_id IS NULL OR group_mark_id = -1)
             AND (( current_organization_id = p_organization_id
                    AND current_status IN (1, 3, 4, 6)
                  )
                    OR current_status = 5
                 )
             AND msn.current_subinventory_code = p_subinventory_code
             AND NVL (msn.current_locator_id, -99999) = NVL (p_locator_id,-99999)
             AND (NVL (msn.lot_number, '###') = NVL (p_lot_number, '###')
                  OR current_status IN (1, 6)
                 )     --newly generated
             AND serial_number LIKE (p_to_serial_number)
             AND serial_number LIKE (l_prefix || '%')
             AND msn.status_id = mms.status_id(+)
             AND mms.LANGUAGE(+) = USERENV ('LANG')
             AND serial_number > p_from_serial_number
             -- Bug# 2770853. Honor the serial material status for physical inventory adjustments.
             AND inv_material_status_grp.is_status_applicable
                                                         (NULL,
                                                          NULL,
                                                          8,
                                                          NULL,
                                                          'Y',
                                                          p_organization_id,
                                                          p_inventory_item_id,
                                                          NULL,
                                                          NULL,
                                                          NULL,
                                                          msn.serial_number,
                                                          'S'
                                                         ) = 'Y'
             UNION
             SELECT serial_number, current_subinventory_code, current_locator_id,
                 lot_number, 0, current_status, mms.status_code
             FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
             WHERE inventory_item_id = p_inventory_item_id
             AND (group_mark_id IS NULL OR group_mark_id = -1)
             AND (   (    current_organization_id = p_organization_id
                      AND current_status = 1
                     )
                  OR current_status = 5
                 )
             AND serial_number LIKE (p_to_serial_number)
             AND serial_number LIKE (l_prefix || '%')
             AND msn.status_id = mms.status_id(+)
             AND mms.LANGUAGE(+) = USERENV ('LANG')
             AND serial_number > p_from_serial_number
             -- Bug# 2770853. Honor the serial material status for physical inventory adjustments.
             AND inv_material_status_grp.is_status_applicable
                                                         (NULL,
                                                          NULL,
                                                          8,
                                                          NULL,
                                                          'Y',
                                                          p_organization_id,
                                                          p_inventory_item_id,
                                                          NULL,
                                                          NULL,
                                                          NULL,
                                                          msn.serial_number,
                                                          'S'
                                                         ) = 'Y'
          ) ORDER BY serial_number;
    ELSE -- Dynamic entries are not allowed
      OPEN x_serials FOR
        SELECT UNIQUE msn.serial_number
                    , msn.current_subinventory_code
                    , msn.current_locator_id
                    , msn.lot_number
                    , 0
                    , msn.current_status
                    , mms.status_code
                 FROM mtl_serial_numbers msn, mtl_physical_inventory_tags mpit, mtl_material_statuses_tl mms
                WHERE msn.inventory_item_id = p_inventory_item_id
                  AND (msn.group_mark_id IS NULL
                       OR msn.group_mark_id = -1
                      )
                  AND ((msn.current_organization_id = p_organization_id
                        AND msn.current_status IN (3, 4)
                       )
                       OR msn.current_status = 5
                      )
                  AND msn.current_subinventory_code = p_subinventory_code
                  AND NVL(msn.current_locator_id, -99999) = NVL(p_locator_id, -99999)
                  AND NVL(msn.lot_number, '###') = NVL(p_lot_number, '###')
                  AND msn.serial_number LIKE (p_to_serial_number)
                  AND msn.serial_number LIKE (l_prefix || '%')
                  AND msn.serial_number = mpit.serial_num
                  AND mpit.physical_inventory_id = p_physical_inventory_id
                  AND mpit.inventory_item_id = p_inventory_item_id
                  AND mpit.organization_id = p_organization_id
                  AND msn.status_id = mms.status_id(+)
                  AND mms.language (+) = userenv('LANG')
                  AND msn.serial_number > p_from_serial_number
                  AND NVL(mpit.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
                  AND NVL(mpit.void_flag, 2) = 2
                  AND mpit.adjustment_id IN (SELECT adjustment_id
          FROM mtl_physical_adjustments
          WHERE physical_inventory_id = p_physical_inventory_id
          AND organization_id = p_organization_id
          AND approval_status IS NULL)
           -- Bug# 2770853
           -- Honor the serial material status for physical inventory adjustments
    AND INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
           NULL,
           8,
           NULL,
           'Y',
           p_organization_id,
           p_inventory_item_id,
           NULL,
           NULL,
           NULL,
           msn.serial_number,
           'S') = 'Y'
             ORDER BY LPAD(msn.serial_number, 20);
    END IF;
  END get_phyinv_to_serial_lov;

  PROCEDURE get_phyinv_serial_count_lov(
    x_serials OUT NOCOPY t_genref
  , p_organization_id IN NUMBER
  , p_subinventory_code IN VARCHAR2
  , p_locator_id IN NUMBER
  , p_serial_number IN VARCHAR2
  , p_dynamic_entry_flag IN NUMBER
  , p_physical_inventory_id IN NUMBER
  ) IS
  BEGIN
    IF (p_dynamic_entry_flag = 1) THEN -- Dynamic entries are allowed
      OPEN x_serials FOR
        SELECT   msn.serial_number
               , msn.current_subinventory_code
               , msn.current_locator_id
               , msn.inventory_item_id
               , msik.concatenated_segments
               , msn.revision
               , msn.lot_number
               , msn.lpn_id
               , wlpn.license_plate_number
               , msn.current_status
               , msik.primary_uom_code
            FROM mtl_serial_numbers msn, mtl_system_items_kfv msik, wms_license_plate_numbers wlpn
           WHERE (msn.group_mark_id IS NULL
                  OR msn.group_mark_id = -1
                 )
             AND ((msn.current_organization_id = p_organization_id
                   AND msn.current_status IN (1, 3, 4, 6)
                  )
                  OR msn.current_status = 5
                 )
             AND msn.serial_number LIKE (p_serial_number)
             AND msn.inventory_item_id = msik.inventory_item_id
             AND msn.current_organization_id = msik.organization_id
             AND wlpn.lpn_id(+) = msn.lpn_id
      -- Bug# 2770853
      -- Honor the serial material status for physical inventory adjustments
      AND INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
             NULL,
             8,
             NULL,
             'Y',
             p_organization_id,
             msn.inventory_item_id,
             NULL,
             NULL,
             NULL,
             msn.serial_number,
             'S') = 'Y'
        ORDER BY LPAD(msn.serial_number, 20);
    ELSE -- Dynamic entries are not allowed
      OPEN x_serials FOR
        SELECT UNIQUE msn.serial_number
                    , msn.current_subinventory_code
                    , msn.current_locator_id
                    , msn.inventory_item_id
                    , msik.concatenated_segments
                    , msn.revision
                    , msn.lot_number
                    , msn.lpn_id
                    , wlpn.license_plate_number
                    , msn.current_status
                    , msik.primary_uom_code
                 FROM mtl_serial_numbers msn, mtl_physical_inventory_tags mpit, mtl_system_items_kfv msik, wms_license_plate_numbers wlpn
                WHERE (msn.group_mark_id IS NULL
                       OR msn.group_mark_id = -1
                      )
                  AND msn.current_organization_id = p_organization_id
                  AND msn.current_subinventory_code = p_subinventory_code
                  AND NVL(msn.current_locator_id, -99999) = NVL(p_locator_id, -99999)
                  AND msn.serial_number LIKE (p_serial_number)
                  AND msn.serial_number = mpit.serial_num
                  AND msn.inventory_item_id = mpit.inventory_item_id
                  AND NVL(msn.lpn_id, -99999) = NVL(mpit.parent_lpn_id, -99999)
                  AND mpit.physical_inventory_id = p_physical_inventory_id
                  AND mpit.organization_id = p_organization_id
                  AND mpit.subinventory = p_subinventory_code
                  AND NVL(mpit.locator_id, -99999) = NVL(p_locator_id, -99999)
                  AND NVL(mpit.void_flag, 2) = 2
                  AND mpit.tag_quantity IS NULL
                  AND mpit.adjustment_id IN (SELECT adjustment_id
          FROM mtl_physical_adjustments
          WHERE physical_inventory_id = p_physical_inventory_id
          AND organization_id = p_organization_id
          AND approval_status IS NULL)
                  AND msn.inventory_item_id = msik.inventory_item_id
                  AND msn.current_organization_id = msik.organization_id
                  AND wlpn.lpn_id(+) = msn.lpn_id
           -- Bug# 2770853
           -- Honor the serial material status for physical inventory adjustments
    AND INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
           NULL,
           8,
           NULL,
           'Y',
           p_organization_id,
           msn.inventory_item_id,
           NULL,
           NULL,
           NULL,
           msn.serial_number,
           'S') = 'Y'
             ORDER BY LPAD(msn.serial_number, 20);
    END IF;
  END get_phyinv_serial_count_lov;

  PROCEDURE get_cyc_serial_lov(
    x_serials               OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_serial_number         IN     VARCHAR2
  , p_lot_number            IN     VARCHAR2
  , p_unscheduled_entry     IN     NUMBER
  , p_cycle_count_header_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  , p_serial_count_option   IN     NUMBER
  ) IS
    l_serial_discrepancy_option    NUMBER;
    l_container_discrepancy_option NUMBER;
    l_orientation_code             NUMBER;
  BEGIN
    -- Get the cycle count discrepancy option flags and orientation code
    SELECT NVL(serial_discrepancy_option, 2),
      NVL(container_discrepancy_option, 2),
      NVL(orientation_code, 1)
      INTO l_serial_discrepancy_option, l_container_discrepancy_option,
      l_orientation_code
      FROM mtl_cycle_count_headers
     WHERE cycle_count_header_id = p_cycle_count_header_id;

    IF (p_unscheduled_entry = 1) THEN
      -- Unscheduled entries are allowed
      OPEN x_serials FOR
        SELECT   serial_number
        , current_subinventory_code
        , current_locator_id
        , lot_number
        , 0
        , current_status
        , mms.status_code
        FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
        WHERE inventory_item_id = p_inventory_item_id
             AND (group_mark_id IS NULL
                  OR group_mark_id = -1
                 )
             AND ((current_organization_id = p_organization_id
                   AND current_status IN (1, 3, 4, 6)
                  )
                  OR current_status = 5
                 )
             AND ((msn.current_subinventory_code = p_subinventory_code
                   AND NVL(msn.current_locator_id, -99999) = NVL(p_locator_id, -99999)
                  )
                  OR l_serial_discrepancy_option = 1
                  OR (p_parent_lpn_id IS NOT NULL
                      AND l_container_discrepancy_option = 1
                     )
                 )
             -- Bug# 2591158
             -- Only allow serials that are within the scope of the header
      -- for unscheduled cycle count entries
      -- Bug# 2778771
      -- Do this check only if the serial status is 3, resides in stores
             AND (l_orientation_code = 1 OR
                  (msn.current_status = 3
     AND msn.current_subinventory_code IN
                   (SELECT subinventory
                    FROM mtl_cc_subinventories
                    WHERE cycle_count_header_id = p_cycle_count_header_id))
    OR msn.current_status <> 3
                  )
             AND serial_number LIKE (p_serial_number)
             AND msn.status_id = mms.status_id(+)
             AND mms.language (+) = userenv('LANG')
             AND (NVL(msn.lot_number, '###') = NVL(p_lot_number, '###')
                  OR current_status IN (1, 6)
                 ) --newly generated
             -- Do not include  the serial numbers which are pending approval
             -- for the same cycle count header
             AND msn.serial_number NOT IN
                    (SELECT mcce.serial_number
                     FROM mtl_cycle_count_entries mcce
                     WHERE mcce.cycle_count_header_id = p_cycle_count_header_id
                     AND mcce.inventory_item_id = p_inventory_item_id
                     AND mcce.organization_id = p_organization_id
                     AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
                     AND mcce.entry_status_code = 2
                     AND NVL(mcce.export_flag, 2) = 2)
             AND msn.serial_number NOT IN
                    (SELECT mcsn.serial_number
                     FROM mtl_cc_serial_numbers mcsn, mtl_cycle_count_entries mcce
                     WHERE mcsn.cycle_count_entry_id = mcce.cycle_count_entry_id
                     AND mcce.cycle_count_header_id = p_cycle_count_header_id
                     AND mcce.inventory_item_id = p_inventory_item_id
                     AND mcce.organization_id = p_organization_id
                     AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
                     AND mcce.entry_status_code = 2
                     AND NVL(mcce.export_flag, 2) = 2)
      -- Bug# 2770853
      -- Honor the serial material status for cycle count adjustments
      AND INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
             NULL,
             4,
             NULL,
             'Y',
             p_organization_id,
             p_inventory_item_id,
             NULL,
             NULL,
             NULL,
             msn.serial_number,
             'S') = 'Y'
        ORDER BY 1 ASC;
    ELSE
      -- Unscheduled entries are not allowed
      IF (p_serial_count_option = 2) THEN
        -- Single serial
        OPEN x_serials FOR
          SELECT UNIQUE msn.serial_number
                      , msn.current_subinventory_code
                      , msn.current_locator_id
                      , msn.lot_number
                      , 0
                      , msn.current_status
                      , mms.status_code
                   FROM mtl_serial_numbers msn, mtl_cycle_count_entries mcce, mtl_material_statuses_tl mms
                  WHERE msn.inventory_item_id = p_inventory_item_id
                    AND ((msn.current_organization_id = p_organization_id
                          AND msn.current_status IN (3, 4)
                         )
                         OR msn.current_status = 5
                        )
                    AND ((msn.current_subinventory_code = p_subinventory_code
                          AND NVL(msn.current_locator_id, -99999) = NVL(p_locator_id, -99999)
                         )
                         OR l_serial_discrepancy_option = 1
                         OR (p_parent_lpn_id IS NOT NULL
                             AND l_container_discrepancy_option = 1
                            )
                        )
                    AND NVL(msn.lot_number, '###') = NVL(p_lot_number, '###')
                    AND msn.serial_number LIKE (p_serial_number)
                    AND msn.serial_number = mcce.serial_number
                    AND msn.status_id = mms.status_id(+)
                    AND mms.language (+) = userenv('LANG')
                    AND mcce.cycle_count_header_id = p_cycle_count_header_id
                    AND mcce.inventory_item_id = p_inventory_item_id
                    AND mcce.organization_id = p_organization_id
                    AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
                    AND mcce.entry_status_code IN (1, 3)
                    AND NVL(mcce.export_flag, 2) = 2
      -- Bug# 2770853
      -- Honor the serial material status for cycle count adjustments
      AND INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
             NULL,
             4,
             NULL,
             'Y',
             p_organization_id,
             p_inventory_item_id,
             NULL,
             NULL,
             NULL,
             msn.serial_number,
             'S') = 'Y'
               ORDER BY LPAD(msn.serial_number, 20);
      ELSIF (p_serial_count_option = 3) THEN
        -- Multiple serial
        OPEN x_serials FOR
          SELECT UNIQUE msn.serial_number
                      , msn.current_subinventory_code
                      , msn.current_locator_id
                      , msn.lot_number
                      , 0
                      , msn.current_status
                      , mms.status_code
          FROM mtl_serial_numbers msn, mtl_cc_serial_numbers mcsn,
          mtl_material_statuses_tl mms, mtl_cycle_count_entries mcce
          WHERE msn.inventory_item_id = p_inventory_item_id
          AND (msn.group_mark_id IS NULL
               OR msn.group_mark_id = -1
               )
            AND ((msn.current_organization_id = p_organization_id
                  AND msn.current_status IN (3, 4)
                  )
                 OR msn.current_status = 5
                 )
            AND ((msn.current_subinventory_code = p_subinventory_code
                  AND NVL(msn.current_locator_id, -99999) = NVL(p_locator_id, -99999)
                  )
                 OR l_serial_discrepancy_option = 1
                 OR (p_parent_lpn_id IS NOT NULL
                     AND l_container_discrepancy_option = 1
                     )
                 )
            AND msn.serial_number LIKE (p_serial_number)
            AND msn.status_id = mms.status_id(+)
            AND mms.language (+) = userenv('LANG')
            AND NVL(msn.lot_number, '###') = NVL(p_lot_number, '###')
            AND msn.serial_number = mcsn.serial_number
            AND mcsn.cycle_count_entry_id = mcce.cycle_count_entry_id
            AND mcce.cycle_count_header_id = p_cycle_count_header_id
            AND mcce.inventory_item_id = p_inventory_item_id
            AND mcce.organization_id = p_organization_id
            AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
            AND mcce.entry_status_code IN (1, 3)
            AND NVL(mcce.export_flag, 2) = 2
     -- Bug# 2770853
     -- Honor the serial material status for cycle count adjustments
     AND INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
            NULL,
            4,
            NULL,
            'Y',
            p_organization_id,
            p_inventory_item_id,
            NULL,
            NULL,
            NULL,
            msn.serial_number,
            'S') = 'Y'
         ORDER BY LPAD(msn.serial_number, 20);
      END IF;
    END IF;
  END get_cyc_serial_lov;

  PROCEDURE get_cyc_to_serial_lov(
    x_serials               OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_to_serial_number      IN     VARCHAR2
  , p_lot_number            IN     VARCHAR2
  , p_unscheduled_entry     IN     NUMBER
  , p_cycle_count_header_id IN     NUMBER
  , p_from_serial_number    IN     VARCHAR2
  , p_parent_lpn_id         IN     NUMBER
  , p_serial_count_option   IN     NUMBER
  ) IS
    l_prefix                       VARCHAR2(30);
    l_quantity                     NUMBER;
    l_from_number                  NUMBER;
    l_to_number                    NUMBER;
    l_errorcode                    NUMBER;
    l_temp_boolean                 BOOLEAN;
    l_serial_discrepancy_option    NUMBER;
    l_container_discrepancy_option NUMBER;
    l_orientation_code             NUMBER;
  BEGIN
    -- Get the cycle count discrepancy option flags and orientation code
    SELECT NVL(serial_discrepancy_option, 2),
      NVL(container_discrepancy_option, 2),
      NVL(orientation_code, 1)
      INTO l_serial_discrepancy_option, l_container_discrepancy_option,
      l_orientation_code
      FROM mtl_cycle_count_headers
      WHERE cycle_count_header_id = p_cycle_count_header_id;

    l_temp_boolean  :=
      mtl_serial_check.inv_serial_info(p_from_serial_number, NULL, l_prefix,
                                       l_quantity, l_from_number, l_to_number, l_errorcode);

    IF (p_unscheduled_entry = 1) THEN
      -- Unscheduled entries are allowed
      OPEN x_serials FOR
        SELECT   serial_number
        , current_subinventory_code
        , current_locator_id
        , lot_number
        , 0
        , current_status
        , mms.status_code
        FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
        WHERE inventory_item_id = p_inventory_item_id
             AND (group_mark_id IS NULL
                  OR group_mark_id = -1
                 )
             AND ((current_organization_id = p_organization_id
                   AND current_status IN (1, 3, 4, 6)
                  )
                  OR current_status = 5
                 )
             AND ((msn.current_subinventory_code = p_subinventory_code
                   AND NVL(msn.current_locator_id, -99999) = NVL(p_locator_id, -99999)
                  )
                  OR l_serial_discrepancy_option = 1
                  OR (p_parent_lpn_id IS NOT NULL
                      AND l_container_discrepancy_option = 1
                     )
                 )
             -- Bug# 2591158
             -- Only allow serials that are within the scope of the header
             -- for unscheduled cycle count entries
      -- Bug# 2778771
      -- Do this check only if the serial status is 3, resides in stores
             AND (l_orientation_code = 1 OR
                  (msn.current_status = 3
     AND msn.current_subinventory_code IN
                   (SELECT subinventory
                    FROM mtl_cc_subinventories
                    WHERE cycle_count_header_id = p_cycle_count_header_id))
    OR msn.current_status <> 3
                  )
             AND (NVL(msn.lot_number, '###') = NVL(p_lot_number, '###')
                  OR current_status IN (1, 6)
                 ) --newly generated
             AND serial_number LIKE (p_to_serial_number)
             AND serial_number LIKE (l_prefix || '%')
             AND msn.status_id = mms.status_id(+)
             AND mms.language (+) = userenv('LANG')
             AND serial_number > p_from_serial_number
             -- Do not include  the serial numbers which are pending approval
             -- for the same cycle count header
             AND msn.serial_number NOT IN
                    (SELECT mcce.serial_number
                     FROM mtl_cycle_count_entries mcce
                     WHERE mcce.cycle_count_header_id = p_cycle_count_header_id
                     AND mcce.inventory_item_id = p_inventory_item_id
                     AND mcce.organization_id = p_organization_id
                     AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
                     AND mcce.entry_status_code = 2
                     AND NVL(mcce.export_flag, 2) = 2)
             AND msn.serial_number NOT IN
                    (SELECT mcsn.serial_number
                     FROM mtl_cc_serial_numbers mcsn, mtl_cycle_count_entries mcce
                     WHERE mcsn.cycle_count_entry_id = mcce.cycle_count_entry_id
                     AND mcce.cycle_count_header_id = p_cycle_count_header_id
                     AND mcce.inventory_item_id = p_inventory_item_id
                     AND mcce.organization_id = p_organization_id
                     AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
                     AND mcce.entry_status_code = 2
                     AND NVL(mcce.export_flag, 2) = 2)
      -- Bug# 2770853
      -- Honor the serial material status for cycle count adjustments
      AND INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
             NULL,
             4,
             NULL,
             'Y',
             p_organization_id,
             p_inventory_item_id,
             NULL,
             NULL,
             NULL,
             msn.serial_number,
             'S') = 'Y'
        ORDER BY 1 ASC;
    ELSE
      -- Unscheduled entries are not allowed
      IF (p_serial_count_option = 2) THEN
        -- Single serial
        OPEN x_serials FOR
          SELECT UNIQUE msn.serial_number
          , msn.current_subinventory_code
          , msn.current_locator_id
          , msn.lot_number
          , 0
          , msn.current_status
          , mms.status_code
          FROM mtl_serial_numbers msn, mtl_cycle_count_entries mcce, mtl_material_statuses_tl mms
          WHERE msn.inventory_item_id = p_inventory_item_id
          AND ((msn.current_organization_id = p_organization_id
                AND msn.current_status IN (3, 4)
                )
               OR msn.current_status = 5
               )
          AND ((msn.current_subinventory_code = p_subinventory_code
                AND NVL(msn.current_locator_id, -99999) = NVL(p_locator_id, -99999)
                )
               OR l_serial_discrepancy_option = 1
               OR (p_parent_lpn_id IS NOT NULL
                   AND l_container_discrepancy_option = 1
                   )
               )
          AND NVL(msn.lot_number, '###') = NVL(p_lot_number, '###')
          AND msn.serial_number LIKE (p_to_serial_number)
          AND msn.serial_number LIKE (l_prefix || '%')
          AND msn.serial_number = mcce.serial_number
          AND mcce.cycle_count_header_id = p_cycle_count_header_id
          AND mcce.inventory_item_id = p_inventory_item_id
          AND mcce.organization_id = p_organization_id
          AND msn.status_id = mms.status_id(+)
          AND mms.language (+) = userenv('LANG')
          AND msn.serial_number > p_from_serial_number
          AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
          AND mcce.entry_status_code IN (1, 3)
          AND NVL(mcce.export_flag, 2) = 2
   -- Bug# 2770853
          -- Honor the serial material status for cycle count adjustments
          AND INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
          NULL,
          4,
          NULL,
          'Y',
          p_organization_id,
          p_inventory_item_id,
          NULL,
          NULL,
          NULL,
          msn.serial_number,
          'S') = 'Y'
        ORDER BY LPAD(msn.serial_number, 20);
      ELSIF (p_serial_count_option = 3) THEN
        -- Multiple serial
        OPEN x_serials FOR
          SELECT UNIQUE msn.serial_number
          , msn.current_subinventory_code
          , msn.current_locator_id
          , msn.lot_number
          , 0
          , msn.current_status
          , mms.status_code
          FROM mtl_serial_numbers msn, mtl_cycle_count_entries mcce,
          mtl_material_statuses_tl mms, mtl_cc_serial_numbers mcsn
          WHERE msn.inventory_item_id = p_inventory_item_id
          AND (msn.group_mark_id IS NULL
                         OR msn.group_mark_id = -1
                        )
            AND ((msn.current_organization_id = p_organization_id
                  AND msn.current_status IN (3, 4)
                  )
                 OR msn.current_status = 5
                 )
            AND ((msn.current_subinventory_code = p_subinventory_code
                  AND NVL(msn.current_locator_id, -99999) = NVL(p_locator_id, -99999)
                  )
                 OR l_serial_discrepancy_option = 1
                 OR (p_parent_lpn_id IS NOT NULL
                     AND l_container_discrepancy_option = 1
                     )
                 )
            AND NVL(msn.lot_number, '###') = NVL(p_lot_number, '###')
            AND msn.serial_number LIKE (p_to_serial_number)
            AND msn.serial_number LIKE (l_prefix || '%')
            AND msn.status_id = mms.status_id(+)
            AND mms.language (+) = userenv('LANG')
            AND msn.serial_number > p_from_serial_number
            AND msn.serial_number = mcsn.serial_number
            AND mcsn.cycle_count_entry_id = mcce.cycle_count_entry_id
            AND mcce.cycle_count_header_id = p_cycle_count_header_id
            AND mcce.inventory_item_id = p_inventory_item_id
            AND mcce.organization_id = p_organization_id
            AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
            AND mcce.entry_status_code IN (1, 3)
            AND NVL(mcce.export_flag, 2) = 2
     -- Bug# 2770853
     -- Honor the serial material status for cycle count adjustments
     AND INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
            NULL,
            4,
            NULL,
            'Y',
            p_organization_id,
            p_inventory_item_id,
            NULL,
            NULL,
            NULL,
            msn.serial_number,
            'S') = 'Y'
         ORDER BY LPAD(msn.serial_number, 20);
      END IF;
    END IF;
  END get_cyc_to_serial_lov;

  PROCEDURE get_cyc_serial_count_lov
    ( x_serials                OUT NOCOPY t_genref
    , p_organization_id        IN  NUMBER
    , p_subinventory_code      IN  VARCHAR2
    , p_locator_id             IN  NUMBER
    , p_serial_number          IN  VARCHAR2
    , p_unscheduled_entry      IN  NUMBER
    , p_cycle_count_header_id  IN  NUMBER
      ) IS
         l_serial_discrepancy_option NUMBER;
         l_orientation_code          NUMBER;
  BEGIN
    -- Get the cycle count serial discrepancy option and orientation code
    SELECT NVL(serial_discrepancy_option, 2), NVL(orientation_code, 1)
      INTO l_serial_discrepancy_option, l_orientation_code
      FROM mtl_cycle_count_headers
     WHERE cycle_count_header_id = p_cycle_count_header_id;

    IF (p_unscheduled_entry = 1) THEN
      -- Unscheduled entries are allowed
      OPEN x_serials FOR
        SELECT   msn.serial_number
               , msn.current_subinventory_code
               , msn.current_locator_id
               , msn.inventory_item_id
               , msik.concatenated_segments
               , msn.revision
               , msn.lot_number
               , msn.lpn_id
               , wlpn.license_plate_number
               , msn.current_status
               , msik.primary_uom_code
            FROM mtl_serial_numbers msn, mtl_system_items_kfv msik, wms_license_plate_numbers wlpn
           WHERE (msn.group_mark_id IS NULL
                  OR msn.group_mark_id = -1
                 )
             AND ((msn.current_organization_id = p_organization_id
                   AND msn.current_status IN (1, 3, 4, 6)
                  )
                  OR msn.current_status = 5
                 )
             AND ((msn.current_subinventory_code = p_subinventory_code
                   AND NVL(msn.current_locator_id, -99999) = NVL(p_locator_id, -99999)
                  )
                  OR l_serial_discrepancy_option = 1
                 )
             -- Bug# 2591158
             -- Only allow serials that are within the scope of the header
             -- for unscheduled cycle count entries
      -- Bug# 2778771
      -- Do this check only if the serial status is 3, resides in stores
             AND (l_orientation_code = 1 OR
                  (msn.current_status = 3
     AND msn.current_subinventory_code IN
                   (SELECT subinventory
                    FROM mtl_cc_subinventories
                    WHERE cycle_count_header_id = p_cycle_count_header_id))
    OR msn.current_status <> 3
                  )
             AND msn.serial_number LIKE (p_serial_number)
             AND msn.inventory_item_id = msik.inventory_item_id
             AND msn.current_organization_id = msik.organization_id
             AND wlpn.lpn_id(+) = msn.lpn_id
             -- Do not include  the serial numbers which are pending approval
             -- for the same cycle count header
             AND msn.serial_number NOT IN (SELECT mcce.serial_number
                                           FROM mtl_cycle_count_entries mcce
                                           WHERE mcce.cycle_count_header_id = p_cycle_count_header_id
                                           AND mcce.organization_id = p_organization_id
                                           AND mcce.inventory_item_id = msn.inventory_item_id
                                           AND mcce.entry_status_code = 2
                                           AND NVL(mcce.export_flag, 2) = 2)
      -- Bug# 2770853
      -- Honor the serial material status for cycle count adjustments
      AND INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
             NULL,
             4,
             NULL,
             'Y',
             p_organization_id,
             msn.inventory_item_id,
             NULL,
             NULL,
             NULL,
             msn.serial_number,
             'S') = 'Y'
        ORDER BY LPAD(msn.serial_number, 20);
    ELSE
      -- Unscheduled entries are not allowed
      -- Single serial
      OPEN x_serials FOR
        SELECT UNIQUE msn.serial_number
        , msn.current_subinventory_code
        , msn.current_locator_id
        , msn.inventory_item_id
        , msik.concatenated_segments
        , msn.revision
        , msn.lot_number
        , msn.lpn_id
        , wlpn.license_plate_number
        , msn.current_status
        , msik.primary_uom_code
        FROM mtl_serial_numbers msn, mtl_cycle_count_entries mcce,
        mtl_system_items_kfv msik, wms_license_plate_numbers wlpn
        WHERE (msn.group_mark_id IS NULL
               OR msn.group_mark_id = -1
               )
          AND msn.current_organization_id = p_organization_id
          AND ((msn.current_subinventory_code = p_subinventory_code
                AND NVL(msn.current_locator_id, -99999) = NVL(p_locator_id, -99999)
                )
               OR l_serial_discrepancy_option = 1
               )
          AND msn.serial_number LIKE (p_serial_number)
          AND msn.serial_number = mcce.serial_number
          AND msn.inventory_item_id = mcce.inventory_item_id
          AND NVL(msn.lpn_id, -99999) = NVL(mcce.parent_lpn_id, -99999)
          AND mcce.cycle_count_header_id = p_cycle_count_header_id
          AND mcce.organization_id = p_organization_id
          AND mcce.entry_status_code IN (1, 3)
          AND NVL(mcce.export_flag, 2) = 2
          AND msn.inventory_item_id = msik.inventory_item_id
          AND msn.current_organization_id = msik.organization_id
          AND wlpn.lpn_id(+) = msn.lpn_id
   -- Bug# 2770853
          -- Honor the serial material status for cycle count adjustments
          AND INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
          NULL,
          4,
          NULL,
          'Y',
          p_organization_id,
          msn.inventory_item_id,
          NULL,
          NULL,
          NULL,
          msn.serial_number,
          'S') = 'Y'
        ORDER BY LPAD(msn.serial_number, 20);
    END IF;
  END get_cyc_serial_count_lov;

  PROCEDURE get_serial_lov_status(x_seriallov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_from_lot_number IN VARCHAR2, p_to_lot_number IN VARCHAR2, p_serial_number IN VARCHAR2) IS
  BEGIN
    /* FP-J Lot/Serial Support Enhancements
     * Add current status of resides in receiving
     */
    OPEN x_seriallov FOR
      SELECT serial_number
           , current_subinventory_code
           , current_locator_id
           , lot_number
           , 0
           , current_status
           , mms.status_code
        FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
       WHERE current_organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id
         --AND current_status IN (1, 3, 5)
         AND current_status IN (1, 3, 5, 7)
         AND (p_from_lot_number IS NULL
              OR lot_number >= p_from_lot_number
             )
         AND (p_to_lot_number IS NULL
              OR lot_number <= p_to_lot_number
             )
         AND msn.status_id = mms.status_id(+)
         AND mms.language (+) = userenv('LANG')
         AND serial_number LIKE (p_serial_number);
  END;

  PROCEDURE get_to_status_serial_lov(
    x_seriallov OUT NOCOPY t_genref
  , p_organization_id IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_from_lot_number IN VARCHAR2
  , p_to_lot_number IN VARCHAR2
  , p_from_serial_number IN VARCHAR2
  , p_serial_number IN VARCHAR2
  ) IS
  BEGIN
    /* FP-J Lot/Serial Support Enhancements
     * Add current status of resides in receiving
     */
    OPEN x_seriallov FOR
      SELECT serial_number
           , current_subinventory_code
           , current_locator_id
           , lot_number
           , 0
           , current_status
           , status_code
        FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
       WHERE current_organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id
         --AND current_status IN (1, 3, 5)
         AND current_status IN (1, 3, 5, 7)
         AND (p_from_lot_number IS NULL
              OR lot_number >= p_from_lot_number
             )
         AND (p_to_lot_number IS NULL
              OR lot_number <= p_to_lot_number
             )
         AND msn.status_id = mms.status_id(+)
         AND mms.language (+) = userenv('LANG')
         AND serial_number >= p_from_serial_number
         AND serial_number LIKE (p_serial_number);
  END;

  PROCEDURE get_serial_lov_lpn(x_serial_number OUT NOCOPY t_genref, p_lpn_id IN NUMBER, p_organization_id IN NUMBER, p_item_id IN NUMBER := NULL, p_lot IN VARCHAR2 := NULL, p_serial IN VARCHAR2) IS
  BEGIN
    OPEN x_serial_number FOR
      SELECT   serial_number
             , 0
             , 0
             , 0
             , 0
             , ''
             , ''
          FROM mtl_serial_numbers
         WHERE lpn_id = p_lpn_id
           AND inventory_item_id = p_item_id
           AND NVL(lot_number, 'NOLOT') = NVL(p_lot, 'NOLOT')
           AND serial_number LIKE (p_serial)
           AND group_mark_id IS NULL
      ORDER BY LPAD(serial_number, 20);
  END get_serial_lov_lpn;

  --      Name: GET_SERIAL_INSPECTLOV_RCV
  --
  --      Input parameters:
  --       p_Organization_Id    which restricts LOV SQL to current org
  --       p_item_id            which restricts LOV SQL to current item
  --       p_lpn_id             restricts serial nos to LPN that is being inspected
  --       p_serial             which restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for mobile inspection
  --
  PROCEDURE get_serial_inspect_lov_rcv
    (x_serial_number OUT NOCOPY t_genref,
     p_organization_id IN NUMBER,
     p_item_id IN NUMBER,
     p_lpn_id IN NUMBER,
     p_serial IN VARCHAR2,
     p_lot_number IN VARCHAR2 ) IS
  BEGIN
    /* FP-J Lot/Serial Support Enhancements
     * Add current status of resides in receiving
     */
    OPEN x_serial_number FOR
      SELECT   serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , 0
             , current_status
             , mms.status_code
          FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
         WHERE msn.inventory_item_id = p_item_id
           AND msn.lpn_id = p_lpn_id
           AND msn.current_organization_id = p_organization_id
           --AND msn.current_status = 5      /* Intransit */
           AND msn.current_status IN (5, 7)  /* Intransit, Resides in Receiving */
           AND msn.status_id = mms.status_id(+)
           AND mms.language (+) = userenv('LANG')
           AND msn.inspection_status is not null  --8405606
           AND msn.serial_number LIKE (p_serial)
           AND Nvl(msn.lot_number,'@@@') = Nvl(p_lot_number,Nvl(msn.lot_number,'@@@'))
           AND Nvl(msn.group_mark_id,-1) <> 2
      ORDER BY LPAD(serial_number, 20);
  END get_serial_inspect_lov_rcv;

  --      Name: GET_SERIAL_LOV_SO
  --
  --      Input parameters:
  --       p_Organization_Id    which restricts LOV SQL to current org
  --       p_inventory_item_id  which restricts LOV SQL to current item
  --       p_subinventory_code  which restricts LOV SQL to current sub
  --       p_locator_id         which restricts LOV SQL to current locator
  --       p_revision           which restricts LOV SQL to current revision
  --       p_lot_number         which restricts LOV SQL to current lot
  --       p_serial_number      which restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for mobile inspection
  --
  PROCEDURE get_serial_lov_so(
    x_serial            OUT    NOCOPY t_genref
  , p_delivery_id       IN     NUMBER
  , p_inventory_item_id IN     NUMBER
  , p_organization_id   IN     NUMBER
  , p_subinventory_code IN     VARCHAR2
  , p_locator_id        IN     NUMBER
  , p_revision          IN     VARCHAR2
  , p_lot_number        IN     VARCHAR2
  , p_serial_number     IN     VARCHAR2
  ) IS
    l_serial_number_control_code NUMBER;
  BEGIN
    SELECT serial_number_control_code
      INTO l_serial_number_control_code
      FROM mtl_system_items_b
     WHERE organization_id = p_organization_id
       AND inventory_item_id = p_inventory_item_id;

    IF l_serial_number_control_code = 6 THEN
      OPEN x_serial FOR
        SELECT   serial_number
               , current_subinventory_code
               , current_locator_id
               , lot_number
               , 0
               , current_status
               , ' '
            FROM mtl_serial_numbers
           WHERE inventory_item_id = p_inventory_item_id
             AND current_organization_id = p_organization_id
             AND (group_mark_id IS NULL
                  OR group_mark_id = -1
                 )
             AND current_status = 1
             AND serial_number LIKE (p_serial_number)
        ORDER BY LPAD(serial_number, 20);
    ELSE
       OPEN x_serial FOR
  select serial_number,current_subinventory_code,current_locator_id,lot_number,0,0,''
  from mtl_serial_numbers msn
  where inventory_item_id = p_inventory_item_id
  and current_organization_id = p_organization_id
  and (group_mark_id is null or group_mark_id = -1 )
  and nvl(current_subinventory_code,'@@@') = nvl(p_subinventory_code,'@@@')
  and nvl(current_locator_id,0) = nvl(p_locator_id,0)
  and current_status = 3
  and (lpn_id is NULL OR lpn_id = 0)
  and wip_entity_id is NULL
  and msn.serial_number like (p_serial_number || '%')
  order by lpad(msn.serial_number,20);
    END IF;
  END get_serial_lov_so;

  PROCEDURE get_cont_serial_lov(x_serial_number OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_lpn_id IN NUMBER, p_revision IN VARCHAR2, p_lot_number IN VARCHAR2, p_serial IN VARCHAR2) IS
  BEGIN
    OPEN x_serial_number FOR
      SELECT   msn.serial_number
             , msn.current_subinventory_code
             , msn.current_locator_id
             , msn.lot_number
             , 0
             , msn.current_status
             , ''
          FROM mtl_serial_numbers msn
         WHERE msn.current_organization_id = p_organization_id
           AND msn.inventory_item_id = p_item_id
           AND msn.lpn_id = p_lpn_id
           AND NVL(line_mark_id, -999) <> 1
           AND NVL(lot_number, '@@@') = NVL(NVL(p_lot_number, '@@@'), NVL(lot_number, '@@@'))
           AND NVL(revision, '@@@') = NVL(NVL(p_revision, '@@@'), NVL(revision, '@@@'))
           AND msn.serial_number LIKE p_serial
           AND inv_material_status_grp.is_status_applicable('TRUE', NULL, inv_globals.g_type_container_unpack, NULL, NULL, p_organization_id, msn.inventory_item_id, NULL, NULL, NULL, msn.serial_number, 'S') = 'Y'
           AND NOT EXISTS (select 1
                           from   mtl_reservations mr
                           where  mr.reservation_id = msn.reservation_id
                           and    mr.lpn_id = p_lpn_id)
      ORDER BY LPAD(msn.serial_number, 20);
  END get_cont_serial_lov;

  PROCEDURE get_split_cont_serial_lov(x_serial_number OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_lpn_id IN NUMBER, p_revision IN VARCHAR2, p_lot_number IN VARCHAR2, p_transaction_subtype IN NUMBER, p_serial IN VARCHAR2) IS
  BEGIN
    IF ( p_transaction_subtype = 1 ) THEN  -- Inventory Split
      OPEN x_serial_number FOR
        SELECT   msn.serial_number
               , msn.current_subinventory_code
               , msn.current_locator_id
               , msn.lot_number
               , 0
               , msn.current_status
               , ''
            FROM mtl_serial_numbers msn
           WHERE msn.current_organization_id = p_organization_id
             AND msn.inventory_item_id = p_item_id
             AND msn.lpn_id = p_lpn_id
             AND NVL(line_mark_id, -9) <> 1
             AND NVL(lot_number, '@') = NVL(NVL(p_lot_number, '@'), NVL(lot_number, '@'))
             AND NVL(revision, '@') = NVL(NVL(p_revision, '@'), NVL(revision, '@'))
             AND msn.serial_number LIKE (p_serial)
             AND (inv_material_status_grp.is_status_applicable('TRUE', NULL, inv_globals.g_type_container_split, NULL, NULL, p_organization_id, msn.inventory_item_id, NULL, NULL, NULL, msn.serial_number, 'S') = 'Y')
             AND NOT EXISTS (select 1
                             from   mtl_reservations mr
                             where  mr.reservation_id = msn.reservation_id
                             and    mr.lpn_id = p_lpn_id)
        ORDER BY LPAD(msn.serial_number, 20);
    ELSE -- Outbound or Salesorder ( p_transaction_subtype in (2, 3) )
      OPEN x_serial_number FOR
      SELECT   msn.serial_number
             , msn.current_subinventory_code
             , msn.current_locator_id
             , msn.lot_number
             , 0
             , msn.current_status
             , ''
          FROM mtl_serial_numbers msn
         WHERE msn.current_organization_id = p_organization_id
           AND msn.inventory_item_id = p_item_id
           AND msn.lpn_id = p_lpn_id
           AND NVL(line_mark_id, -9) <> 1
           AND NVL(lot_number, '@') = NVL(NVL(p_lot_number, '@'), NVL(lot_number, '@'))
           AND NVL(revision, '@') = NVL(NVL(p_revision, '@'), NVL(revision, '@'))
           AND msn.serial_number LIKE (p_serial)
           AND (inv_material_status_grp.is_status_applicable('TRUE', NULL, inv_globals.g_type_container_split, NULL, NULL, p_organization_id, msn.inventory_item_id, NULL, NULL, NULL, msn.serial_number, 'S') = 'Y')
      ORDER BY LPAD(msn.serial_number, 20);
    END IF;
  END get_split_cont_serial_lov;

  PROCEDURE get_pupcont_serial_lov(
    x_serial_number   OUT    NOCOPY t_genref
  , p_organization_id IN     NUMBER
  , p_item_id         IN     NUMBER
  , p_lpn_id          IN     NUMBER
  , p_revision        IN     VARCHAR2
  , p_lot_number      IN     VARCHAR2
  , p_serial          IN     VARCHAR2
  , p_txn_type_id     IN     NUMBER := 0
  , p_wms_installed   IN     VARCHAR2 := 'TRUE'
  ) IS
  BEGIN
    OPEN x_serial_number FOR
      SELECT   msn.serial_number
             , msn.current_subinventory_code
             , msn.current_locator_id
             , msn.lot_number
          FROM mtl_serial_numbers msn
         WHERE msn.current_organization_id = p_organization_id
           AND msn.inventory_item_id = p_item_id
           AND msn.lpn_id = p_lpn_id
           AND (group_mark_id IS NULL
                OR group_mark_id = -1
               )
           AND NVL(lot_number, '@@@') = NVL(NVL(p_lot_number, '@@@'), NVL(lot_number, '@@@'))
           AND NVL(revision, '@@@') = NVL(NVL(p_revision, '@@@'), NVL(revision, '@@@'))
           AND msn.serial_number LIKE (p_serial)
           AND current_status = 3
           AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, NULL, NULL, p_organization_id, NULL, NULL, NULL, NULL, p_serial, 'S') = 'Y'
      ORDER BY LPAD(msn.serial_number, 20);
  END get_pupcont_serial_lov;

  --      Name: GET_INV_SERIAL_LOV
  --
  --      Input parameters:
  --       p_Organization_Id    which restricts LOV SQL to current org
  --       p_inventory_item_id  which restricts LOV SQL to current item
  --       p_subinventory_code  which restricts LOV SQL to current sub
  --       p_locator_id         which restricts LOV SQL to current locator
  --       p_revision           which restricts LOV SQL to current revision
  --       p_lot_number         which restricts LOV SQL to current lot
  --       p_serial_number      which restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for mobile inspection
  --
  PROCEDURE get_inv_serial_lov(
    x_serial OUT NOCOPY t_genref
  , p_organization_id IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_subinventory_code IN VARCHAR2
  , p_locator_id IN VARCHAR2
  , p_revision IN VARCHAR2
  , p_lot_number IN VARCHAR2
  , p_serial_number IN VARCHAR2
  ) IS
  BEGIN
    OPEN x_serial FOR
      SELECT   serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , 'NULL'
             , current_status
             , 'NULL'
          FROM mtl_serial_numbers
         WHERE inventory_item_id = NVL(p_inventory_item_id, inventory_item_id)
           AND current_organization_id = p_organization_id
           AND (group_mark_id IS NULL
                OR group_mark_id = -1
               )
           AND ((NVL(current_subinventory_code, '@@@') = NVL(NVL(p_subinventory_code, '@@@'), NVL(current_subinventory_code, '@@@'))
                 AND NVL(current_locator_id, -1) = NVL(NVL(TO_NUMBER(p_locator_id), -1), NVL(current_locator_id, -1))
                 AND NVL(lot_number, '@@@') = NVL(NVL(p_lot_number, '@@@'), NVL(lot_number, '@@@'))
                 AND NVL(revision, '@@@') = NVL(NVL(p_revision, '@@@'), NVL(revision, '@@@'))
                 AND current_status = 3
                )
                OR current_status = 1
                OR current_status = 6
               )
           AND serial_number LIKE (p_serial_number)
      ORDER BY LPAD(serial_number, 20);
  END get_inv_serial_lov;

  PROCEDURE get_pack_serial_lov(
      x_serial OUT NOCOPY t_genref
      , p_organization_id IN NUMBER
      , p_inventory_item_id IN NUMBER
      , p_subinventory_code IN VARCHAR2
      , p_locator_id IN VARCHAR2
      , p_revision IN VARCHAR2
      , p_lot_number IN VARCHAR2
      , p_serial_number IN VARCHAR2) IS
  BEGIN
    OPEN x_serial FOR
      SELECT   serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , 'NULL'
             , current_status
             , 'NULL'
          FROM mtl_serial_numbers
         WHERE inventory_item_id = p_inventory_item_id
           AND current_organization_id = p_organization_id
           AND NVL(line_mark_id, -999) <> 1
           AND current_subinventory_code = p_subinventory_code
           AND NVL(current_locator_id, -1) = NVL(NVL(TO_NUMBER(p_locator_id), -1), NVL(current_locator_id, -1))
           AND NVL(lot_number, '@@@') = NVL(NVL(p_lot_number, '@@@'), NVL(lot_number, '@@@'))
           AND NVL(revision, '@@@') = NVL(NVL(p_revision, '@@@'), NVL(revision, '@@@'))
           AND current_status = 3
           AND lpn_id IS NULL
           AND serial_number LIKE p_serial_number
           AND inv_material_status_grp.is_status_applicable
               (
                'TRUE', NULL,
                inv_globals.g_type_container_pack,
                NULL, NULL,
                p_organization_id, inventory_item_id,
                NULL, NULL, NULL, serial_number, 'S') = 'Y'
      ORDER BY LPAD(serial_number, 20);
  END get_pack_serial_lov;

  --      Name: GET_INV_SERIAL_LOV_BULK
  --
  --      Input parameters:
  --       p_Organization_Id    which restricts LOV SQL to current org
  --       p_inventory_item_id  which restricts LOV SQL to current item
  --       p_subinventory_code  which restricts LOV SQL to current sub
  --       p_locator_id         which restricts LOV SQL to current locator
  --       p_revision           which restricts LOV SQL to current revision
  --       p_lot_number         which restricts LOV SQL to current lot
  --       p_serial_number      which restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for mobile inspection
  --
  PROCEDURE get_inv_serial_lov_bulk(
    x_serial             OUT    NOCOPY t_genref
  , p_organization_id    IN     NUMBER
  , p_inventory_item_id  IN     NUMBER
  , p_subinventory_code  IN     VARCHAR2
  , p_locator_id         IN     VARCHAR2
  , p_revision           IN     VARCHAR2
  , p_lot_number         IN     VARCHAR2
  , p_from_serial_number IN     VARCHAR2
  , p_serial_number      IN     VARCHAR2
  ) IS
    l_prefix       VARCHAR2(30);
    l_quantity     NUMBER;
    l_from_number  NUMBER;
    l_to_number    NUMBER;
    l_errorcode    NUMBER;
    l_temp_boolean BOOLEAN;
  BEGIN
    IF (p_from_serial_number IS NOT NULL) THEN
      l_temp_boolean  := mtl_serial_check.inv_serial_info(p_from_serial_number, NULL, l_prefix, l_quantity, l_from_number, l_to_number, l_errorcode);
    ELSE
      l_prefix  := '';
    END IF;

    OPEN x_serial FOR
      SELECT   serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , 'NULL'
             , current_status
             , 'NULL'
          FROM mtl_serial_numbers
         WHERE inventory_item_id = NVL(p_inventory_item_id, inventory_item_id)
           AND current_organization_id = p_organization_id
           AND (group_mark_id IS NULL
                OR group_mark_id = -1
               )
           AND ((NVL(current_subinventory_code, '@@@') = NVL(NVL(p_subinventory_code, '@@@'), NVL(current_subinventory_code, '@@@'))
                 AND NVL(current_locator_id, -1) = NVL(NVL(TO_NUMBER(p_locator_id), -1), NVL(current_locator_id, -1))
                 AND NVL(lot_number, '@@@') = NVL(NVL(p_lot_number, '@@@'), NVL(lot_number, '@@@'))
                 AND NVL(revision, '@@@') = NVL(NVL(p_revision, '@@@'), NVL(revision, '@@@'))
                 AND current_status = 3
                )
               )
           AND serial_number LIKE (l_prefix || '%')
           AND lpn_id IS NULL
           AND serial_number >= NVL(p_from_serial_number, serial_number)
           AND serial_number LIKE (p_serial_number)
           AND (inv_material_status_grp.is_status_applicable('TRUE', NULL, inv_globals.g_type_container_pack, NULL, NULL, p_organization_id, inventory_item_id, NULL, NULL, NULL, serial_number, 'S') = 'Y')
      ORDER BY LPAD(serial_number, 20);
  END get_inv_serial_lov_bulk;

  --      Name: GET_CGUPDATE_SERIAL_LOV
  --
  --      Input parameters:
  --       p_Organization_Id    which restricts LOV SQL to current org
  --       p_inventory_item_id  which restricts LOV SQL to current item
  --       p_serial_number      which restricts LOV SQL to the serial entered
  --       p_subinventory_code  which restricts LOV SQL to current sub
  --       p_locator_id         which restricts LOV SQL to current locator
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for mobile inspection
  --
  PROCEDURE get_cgupdate_serial_lov(
    x_serial            OUT    NOCOPY t_genref
  , p_organization_id   IN     NUMBER
  , p_inventory_item_id IN     NUMBER
  , p_lpn_id            IN     NUMBER
  , p_serial_number     IN     VARCHAR2
  , p_subinventory_code IN     VARCHAR2
  , p_locator_id        IN     NUMBER
  , p_revision          IN     VARCHAR2
  , p_cost_group_id     IN     NUMBER
  ) IS
  BEGIN
    IF p_lpn_id IS NULL THEN
      OPEN x_serial FOR
        SELECT   msn.serial_number
               , msn.current_subinventory_code
               , msn.current_locator_id
               , msn.lot_number
               , ''
               , msn.current_status
               , mms.status_code
               , mil.concatenated_segments
               , msn.revision
               , msn.cost_group_id
               , ccg.cost_group
            FROM mtl_item_locations_kfv mil, mtl_serial_numbers msn, cst_cost_groups ccg, mtl_material_statuses_tl mms
           WHERE (group_mark_id IS NULL
                  OR group_mark_id = -1
                 )
             AND mms.status_id(+) = msn.status_id
             AND mms.language (+) = userenv('LANG')
             AND ccg.cost_group_id = msn.cost_group_id
             AND msn.current_locator_id = mil.inventory_location_id
             AND mil.organization_id = p_organization_id
             AND inv_material_status_grp.is_status_applicable('TRUE', NULL, 86, NULL, NULL, p_organization_id, p_inventory_item_id, msn.current_subinventory_code, msn.current_locator_id, msn.lot_number, msn.serial_number, 'A') = 'Y'
             AND msn.current_status = 3
             AND (msn.group_mark_id IS NULL
                  OR (msn.group_mark_id <> 1)
                 )
             AND (p_revision IS NULL
                  OR (msn.revision = p_revision)
                 )
             AND msn.cost_group_id = NVL(p_cost_group_id, msn.cost_group_id)
             AND msn.current_locator_id = NVL(p_locator_id, msn.current_locator_id)
             AND msn.current_subinventory_code = NVL(p_subinventory_code, msn.current_subinventory_code)
             AND msn.serial_number LIKE (p_serial_number)
             AND msn.lpn_id IS NULL
             AND msn.inventory_item_id = p_inventory_item_id
             AND msn.current_organization_id = p_organization_id
        ORDER BY serial_number;
    ELSE
      OPEN x_serial FOR
        SELECT   msn.serial_number
               , msn.current_subinventory_code
               , msn.current_locator_id
               , msn.lot_number
               , ''
               , msn.current_status
               , mms.status_code
               , mil.concatenated_segments
               , msn.revision
               , msn.cost_group_id
               , ccg.cost_group
            FROM mtl_item_locations_kfv mil, mtl_serial_numbers msn, cst_cost_groups ccg, mtl_material_statuses_tl mms
           WHERE (group_mark_id IS NULL
                  OR group_mark_id = -1
                 )
             AND mms.status_id(+) = msn.status_id
             AND mms.language (+) = userenv('LANG')
             AND ccg.cost_group_id = msn.cost_group_id
             AND msn.current_locator_id = mil.inventory_location_id
             AND mil.organization_id = p_organization_id
             AND inv_material_status_grp.is_status_applicable('TRUE', NULL, 86, NULL, NULL, p_organization_id, p_inventory_item_id, msn.current_subinventory_code, msn.current_locator_id, msn.lot_number, msn.serial_number, 'A') = 'Y'
             AND msn.current_status = 3
             AND (msn.group_mark_id IS NULL
                  OR (msn.group_mark_id <> 1)
                 )
             AND (p_revision IS NULL
                  OR (msn.revision = p_revision)
                 )
             AND msn.cost_group_id = NVL(p_cost_group_id, msn.cost_group_id)
             AND msn.current_locator_id = NVL(p_locator_id, msn.current_locator_id)
             AND msn.current_subinventory_code = NVL(p_subinventory_code, msn.current_subinventory_code)
             AND msn.serial_number LIKE (p_serial_number)
             AND msn.lpn_id = p_lpn_id
             AND msn.inventory_item_id = p_inventory_item_id
             AND msn.current_organization_id = p_organization_id
        ORDER BY serial_number;
    END IF;
  END get_cgupdate_serial_lov;

  PROCEDURE get_lot_expiration_date(p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_lot_number IN VARCHAR2, p_shelf_life_code IN NUMBER, p_shelf_life_days IN NUMBER, x_expiration_date OUT NOCOPY DATE) IS
  BEGIN
    x_expiration_date  := '';

    IF p_shelf_life_code = 1 THEN
      RETURN;
    ELSE
      BEGIN
        SELECT MIN(expiration_date)
          INTO x_expiration_date
          FROM mtl_lot_numbers
         WHERE organization_id = p_organization_id
           AND inventory_item_id = p_inventory_item_id
           AND lot_number = p_lot_number;

        IF x_expiration_date IS NULL THEN
          IF p_shelf_life_code = 2 THEN
            SELECT (SYSDATE + NVL(p_shelf_life_days, 0))
              INTO x_expiration_date
              FROM DUAL;
          END IF;
        END IF;

        RETURN;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF p_shelf_life_code = 2 THEN
            SELECT (SYSDATE + NVL(p_shelf_life_days, 0))
              INTO x_expiration_date
              FROM DUAL;
          END IF;

          RETURN;
      END;
    END IF;

    RETURN;
  END get_lot_expiration_date;

  --      Name: GET_SERIAL_LOV_PICKING
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           which restricts LOV SQL to current item
  --       p_subinv_code       restricts to Subinventory
  --       p_locator_id        restricts to Locator ID. If not used, set to -1
  --       p_serial            which restricts LOV SQL to the serial entered
  --       p_lpn_id            which restricts LOV SQL to current LPN
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers limited by
  --       the specified Subinventory and Locator with status = 3;
  --


  PROCEDURE get_serial_lov_picking(
    x_serial_number       OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_subinv_code         IN     VARCHAR2
  , p_locator_id          IN     NUMBER
  , p_serial              IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_lpn_id              IN     NUMBER
  , p_lot_number          IN     VARCHAR2
  ) IS
    l_wms_installed VARCHAR2(10) := 'TRUE';
  BEGIN
    OPEN x_serial_number FOR
      SELECT   serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , 0
             , current_status
             , mms.status_code
          FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
         WHERE inventory_item_id = p_item_id
           AND (group_mark_id IS NULL
                OR group_mark_id = -1
               )
           AND current_organization_id = p_organization_id
           AND current_status = 3
           AND current_subinventory_code = p_subinv_code
           AND NVL(msn.lpn_id, 0) = NVL(p_lpn_id, 0)
           AND NVL(current_locator_id, 0) = NVL(DECODE(p_locator_id, -1, current_locator_id, p_locator_id), 0)
           AND msn.status_id = mms.status_id(+)
           AND mms.language (+) = userenv('LANG')
           AND serial_number LIKE (p_serial)
           AND NVL(msn.lot_number, 0) = NVL(p_lot_number, 0) --retrict to lot numbers
           AND inv_material_status_grp.is_status_applicable(l_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinv_code, msn.current_locator_id, msn.lot_number, msn.serial_number, 'S') = 'Y'
      ORDER BY LPAD(serial_number, 20);
  END get_serial_lov_picking;

  --      Name: GET_SERIAL_LOV_ALLOC_PICKING
  --
  --      Input parameters:
  --       p_transaction_temp_id the transaction temp id from the
  --                                mtl_material_transactions_temp table
  --        p_lot_code if '1' means not lot controlled
  --                   if '2' means IS lot controlled
  --                     the caller function would have to ensure that
  --                      these are the only numbers used.
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers allocated at receipt
  --
  --

  PROCEDURE get_serial_lov_alloc_picking(
    x_serial_number       OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_subinv_code         IN     VARCHAR2
  , p_locator_id          IN     NUMBER
  , p_serial              IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_lpn_id              IN     NUMBER
  , p_transaction_temp_id IN     NUMBER
  , p_lot_code            IN     NUMBER
  , p_lot_number          IN     VARCHAR2
  ) IS
    lp_lot_code     NUMBER;
    l_wms_installed VARCHAR2(10) := 'TRUE';
  BEGIN
    IF (p_lot_code IS NULL) THEN
      lp_lot_code  := 1;
    ELSE
      lp_lot_code  := p_lot_code;
    END IF;

    -- if is NOT lot controlled, do this
    IF (lp_lot_code = 1) THEN
      OPEN x_serial_number FOR
        SELECT   msnt.fm_serial_number
               , msn.current_subinventory_code
               , msn.current_locator_id
               , msn.lot_number
               , 0
               , msn.current_status
               , mms.status_code
            FROM mtl_serial_numbers_temp msnt, mtl_serial_numbers msn, mtl_material_statuses_tl mms
           WHERE msn.inventory_item_id = p_item_id
             AND msn.current_organization_id = p_organization_id
             AND msn.current_status = 3
             AND msn.current_subinventory_code = p_subinv_code
             AND NVL(msn.lpn_id, 0) = NVL(p_lpn_id, 0)
             AND NVL(msn.current_locator_id, 0) = NVL(DECODE(p_locator_id, -1, msn.current_locator_id, p_locator_id), 0)
             AND msn.status_id = mms.status_id(+)
             AND mms.language (+) = userenv('LANG')
             AND inv_material_status_grp.is_status_applicable(l_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinv_code, msn.current_locator_id, msn.lot_number, msnt.fm_serial_number, 'S') = 'Y'
             AND msn.serial_number = msnt.fm_serial_number
             AND msnt.fm_serial_number LIKE (p_serial)
             AND msnt.transaction_temp_id = p_transaction_temp_id
        ORDER BY LPAD(msnt.fm_serial_number, 20);
    -- else if IS lot controlled do this
    ELSIF (lp_lot_code = 2) THEN
      OPEN x_serial_number FOR
        SELECT   msnt.fm_serial_number
               , msn.current_subinventory_code
               , msn.current_locator_id
               , msn.lot_number
               , 0
               , msn.current_status
               , mms.status_code
            FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt, mtl_serial_numbers msn, mtl_material_statuses_tl mms
           WHERE msn.inventory_item_id = p_item_id
             AND msn.current_organization_id = p_organization_id
             AND msn.current_status = 3
             AND msn.current_subinventory_code = p_subinv_code
             AND NVL(msn.lpn_id, 0) = NVL(p_lpn_id, 0)
             AND NVL(msn.current_locator_id, 0) = NVL(DECODE(p_locator_id, -1, msn.current_locator_id, p_locator_id), 0)
             AND msn.status_id = mms.status_id(+)
             AND mms.language (+) = userenv('LANG')
             AND inv_material_status_grp.is_status_applicable(l_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinv_code, msn.current_locator_id, msn.lot_number, msnt.fm_serial_number, 'S') = 'Y'
             AND msn.serial_number = msnt.fm_serial_number
             AND msnt.fm_serial_number LIKE (p_serial)
             AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
             AND mtlt.lot_number = p_lot_number
             AND mtlt.transaction_temp_id = p_transaction_temp_id
        ORDER BY LPAD(msnt.fm_serial_number, 20);
    END IF;
  END get_serial_lov_alloc_picking;


  PROCEDURE get_serial_lov_apl_picking(
      x_serial_number       OUT    NOCOPY t_genref
    , p_organization_id     IN     NUMBER
    , p_item_id             IN     NUMBER
    , p_subinv_code         IN     VARCHAR2
    , p_locator_id          IN     NUMBER
    , p_serial              IN     VARCHAR2
    , p_transaction_type_id IN     NUMBER
    , p_lpn_id              IN     NUMBER
    , p_lot_number          IN     VARCHAR2
    , p_revision            IN     VARCHAR2
    ) IS
      l_wms_installed VARCHAR2(10) := 'TRUE';
    BEGIN
      OPEN x_serial_number FOR
        SELECT   serial_number
               , current_subinventory_code
               , current_locator_id
               , lot_number
               , 0
               , current_status
               , mms.status_code
            FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
           WHERE inventory_item_id = p_item_id
             AND (group_mark_id IS NULL
                  OR group_mark_id = -1
                 )
             AND current_organization_id = p_organization_id
             AND current_status = 3
             AND current_subinventory_code = p_subinv_code
             AND NVL(msn.lpn_id, 0) = NVL(p_lpn_id, 0)
             AND NVL(current_locator_id, 0) = NVL(DECODE(p_locator_id, -1, current_locator_id, p_locator_id), 0)
             AND msn.status_id = mms.status_id(+)
             AND mms.language (+) = userenv('LANG')
             AND serial_number LIKE (p_serial)
             AND (p_revision IS NULL
                  OR (msn.revision = p_revision)
                 )
             AND NVL(msn.lot_number, 0) = NVL(p_lot_number, 0) --retrict to lot numbers
             AND inv_material_status_grp.is_status_applicable(l_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinv_code, msn.current_locator_id, msn.lot_number, msn.serial_number, 'S') = 'Y'
        ORDER BY LPAD(serial_number, 20);
  END get_serial_lov_apl_picking;


  PROCEDURE get_serial_lov_apl_alloc_pick(
      x_serial_number       OUT    NOCOPY t_genref
    , p_organization_id     IN     NUMBER
    , p_item_id             IN     NUMBER
    , p_subinv_code         IN     VARCHAR2
    , p_locator_id          IN     NUMBER
    , p_serial              IN     VARCHAR2
    , p_transaction_type_id IN     NUMBER
    , p_lpn_id              IN     NUMBER
    , p_transaction_temp_id IN     NUMBER
    , p_lot_code            IN     NUMBER
    , p_lot_number          IN     VARCHAR2
    , p_revision            IN     VARCHAR2
    ) IS
      lp_lot_code     NUMBER;
      l_wms_installed VARCHAR2(10) := 'TRUE';
    BEGIN
      IF (p_lot_code IS NULL) THEN
        lp_lot_code  := 1;
      ELSE
        lp_lot_code  := p_lot_code;
      END IF;

      -- if is NOT lot controlled, do this
      IF (lp_lot_code = 1) THEN
        OPEN x_serial_number FOR
          SELECT   mag.serial_number
                 , msn.current_subinventory_code
                 , msn.current_locator_id
                 , msn.lot_number
                 , 0
                 , msn.current_status
                 , mms.status_code
              FROM wms_allocations_gtmp mag, mtl_serial_numbers msn, mtl_material_statuses_tl mms
             WHERE msn.inventory_item_id = p_item_id
               AND msn.current_organization_id = p_organization_id
               AND msn.current_status = 3
               AND msn.current_subinventory_code = p_subinv_code
               --AND NVL(msn.lpn_id, 0) = NVL(p_lpn_id, 0)
               AND NVL(msn.current_locator_id, 0) = NVL(DECODE(p_locator_id, -1, msn.current_locator_id, p_locator_id), 0)
               AND msn.status_id = mms.status_id(+)
               AND mms.language (+) = userenv('LANG')
               AND inv_material_status_grp.is_status_applicable(l_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinv_code, msn.current_locator_id, msn.lot_number, mag.serial_number, 'S') = 'Y'
               AND msn.serial_number = mag.serial_number
               AND mag.serial_number LIKE (p_serial)
               AND (p_revision IS NULL
                    OR (msn.revision = p_revision)
                 )
          ORDER BY LPAD(mag.serial_number, 20);
      -- else if IS lot controlled do this
      ELSIF (lp_lot_code = 2) THEN
        OPEN x_serial_number FOR
          SELECT   mag.serial_number
                 , msn.current_subinventory_code
                 , msn.current_locator_id
                 , msn.lot_number
                 , 0
                 , msn.current_status
                 , mms.status_code
              FROM wms_allocations_gtmp mag,  mtl_serial_numbers msn, mtl_material_statuses_tl mms
             WHERE msn.inventory_item_id = p_item_id
               AND msn.current_organization_id = p_organization_id
               AND msn.current_status = 3
               AND msn.current_subinventory_code = p_subinv_code
               --AND NVL(msn.lpn_id, 0) = NVL(p_lpn_id, 0)
               AND NVL(msn.current_locator_id, 0) = NVL(DECODE(p_locator_id, -1, msn.current_locator_id, p_locator_id), 0)
               AND msn.status_id = mms.status_id(+)
               AND mms.language (+) = userenv('LANG')
               AND inv_material_status_grp.is_status_applicable(l_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinv_code, msn.current_locator_id, msn.lot_number, mag.serial_number, 'S') = 'Y'
               AND msn.serial_number = mag.serial_number
               AND mag.serial_number LIKE (p_serial)
               AND mag.lot_number = p_lot_number
               AND (p_revision IS NULL
                   OR (msn.revision = p_revision)
                 )
          ORDER BY LPAD(mag.serial_number, 20);
      END IF;
  END get_serial_lov_apl_alloc_pick;

  PROCEDURE get_all_serial_lov(x_serial OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_serial IN VARCHAR2) IS
  BEGIN
    OPEN x_serial FOR
      SELECT DISTINCT serial_number
                    , 'NULL'
                    , 0
                    , 'NULL'
                    , --lot_number,
                     'NULL'
                    , 0
                    , --current_status,
                     'NULL'
                 FROM mtl_serial_numbers
                WHERE current_organization_id = p_organization_id
                  AND serial_number LIKE (p_serial)
             ORDER BY LPAD(serial_number, 20);
  END get_all_serial_lov;

  PROCEDURE get_all_to_serial_lov(x_serial OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_from_serial_number IN VARCHAR2, p_inventory_item_id IN NUMBER, p_serial IN VARCHAR2) IS
    l_prefix       VARCHAR2(30);
    l_quantity     NUMBER;
    l_from_number  NUMBER;
    l_to_number    NUMBER;
    l_errorcode    NUMBER;
    l_temp_boolean BOOLEAN;
  BEGIN
    l_temp_boolean  := mtl_serial_check.inv_serial_info(p_from_serial_number, NULL, l_prefix, l_quantity, l_from_number, l_to_number, l_errorcode);
    OPEN x_serial FOR
      SELECT DISTINCT serial_number
                    , 'NULL'
                    , 0
                    , 'NULL'
                    , --lot_number,
                     'NULL'
                    , 0
                    , --current_status,
                     'NULL'
                 FROM mtl_serial_numbers
                WHERE current_organization_id = p_organization_id
                  AND inventory_item_id = p_inventory_item_id
                  AND LENGTH(serial_number) = LENGTH(p_from_serial_number)
                  AND serial_number LIKE (l_prefix || '%')
                  AND serial_number LIKE (p_serial)
             ORDER BY LPAD(serial_number, 20);
  END get_all_to_serial_lov;

  --"Returns"
  PROCEDURE get_return_serial_lov(x_serial OUT NOCOPY t_genref, p_org_id IN NUMBER, p_lpn_id IN NUMBER, p_item_id IN NUMBER, p_revision IN VARCHAR2, p_serial IN VARCHAR2, p_upd_group_id IN NUMBER) IS
    dummy_s VARCHAR2(20);
    dummy_a VARCHAR2(20);
    dummy_b NUMBER;
    dummy_c VARCHAR2(20);
    dummy_d VARCHAR2(20);
    dummy_e NUMBER;
    dummy_f VARCHAR2(20);
  BEGIN
    IF (p_upd_group_id = 1) THEN
      UPDATE mtl_serial_numbers
         SET group_mark_id = NULL
       WHERE current_organization_id = p_org_id
         AND group_mark_id IS NOT NULL
         AND lpn_id = p_lpn_id
         AND inventory_item_id = p_item_id
         AND ((revision = p_revision
               AND p_revision IS NOT NULL
              )
              OR (revision IS NULL
                  AND p_revision IS NULL
                 )
             )
         AND last_txn_source_name IN ('RETURN TO VENDOR', 'RETURN TO CUSTOMER', 'RETURN TO RECEIVING');
    END IF;

    OPEN x_serial FOR
      SELECT DISTINCT serial_number
                    , 'NULL'
                    , 0
                    , NVL(lot_number, '')
                    , --lot_number,
                     'NULL'
                    , 0
                    , --current_status,
                     'NULL'
                 FROM mtl_serial_numbers
                WHERE current_organization_id = p_org_id
                  AND (group_mark_id IS NULL
                       OR group_mark_id = -1
                      )
                  AND lpn_id = p_lpn_id
                  AND inventory_item_id = p_item_id
                  AND ((revision = p_revision
                        AND p_revision IS NOT NULL
                       )
                       OR (revision IS NULL
                           AND p_revision IS NULL
                          )
                      )
                  AND last_txn_source_name IN ('RETURN TO VENDOR', 'RETURN TO CUSTOMER', 'RETURN TO RECEIVING')
                  AND serial_number LIKE (p_serial)
             ORDER BY LPAD(serial_number, 20);
  END get_return_serial_lov;

  --"Returns"

  PROCEDURE get_task_serial_lov(x_serial_number OUT NOCOPY t_genref, p_temp_id IN NUMBER, p_lot_code IN NUMBER) IS
  BEGIN
    IF (p_lot_code = 1) THEN
      OPEN x_serial_number FOR
        SELECT   fm_serial_number || '-' || to_serial_number
               , 0
               , 0
               , 0
               , 0
               , ''
               , ''
            FROM mtl_serial_numbers_temp
           WHERE transaction_temp_id = p_temp_id
        ORDER BY LPAD(fm_serial_number, 20);
    ELSE
      OPEN x_serial_number FOR
        SELECT   msnt.fm_serial_number || '-' || msnt.to_serial_number
               , 0
               , 0
               , 0
               , 0
               , ''
               , ''
            FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt
           WHERE mtlt.transaction_temp_id = p_temp_id
             AND msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
        ORDER BY LPAD(fm_serial_number, 20);
    END IF;
  END get_task_serial_lov;

  -- LOV query for serial triggered subinventory transfer
  PROCEDURE get_serial_subxfr_lov(x_serials OUT NOCOPY t_genref, p_current_organization_id IN NUMBER, p_serial_number IN VARCHAR2, p_transaction_type_id IN NUMBER, p_wms_installed IN VARCHAR2) IS
  BEGIN
    -- For serial triggered subinventory transfer
   /*Bug#5612236. In the below query, replaced 'MTL_SYSTEM_ITEMS_KFV' with
     'MTL_SYSTEM_ITEMS_VL'.*/
    OPEN x_serials FOR
      SELECT DISTINCT msn.serial_number
                    , msn.current_subinventory_code
                    , msn.current_locator_id
                    , --I Development Bug 2634570
                     --milv.concatenated_segments,
                     inv_project.get_locsegs(msn.current_locator_id, p_current_organization_id)
                    , msn.inventory_item_id
                    , msiv.concatenated_segments
                    , msiv.description
                    , msn.revision
                    , msn.lot_number
                    , NVL(msiv.restrict_subinventories_code, 2)
                    , NVL(msiv.restrict_locators_code, 2)
                    , msiv.serial_number_control_code
                    , msi.asset_inventory
                    , msiv.location_control_code
                    , msiv.primary_uom_code
                    , --I Development Bug 2634570
                     inv_project.get_project_id
                    , inv_project.get_project_number
                    , inv_project.get_task_id
                    , inv_project.get_task_number
                 FROM mtl_serial_numbers msn
                    , mtl_system_items_vl msiv
                    , mtl_item_locations_kfv milv
                    , mtl_secondary_inventories msi
                WHERE msn.current_organization_id = p_current_organization_id
                  AND msn.lpn_id IS NULL
                  AND (msn.group_mark_id IS NULL
                       OR msn.group_mark_id = -1
                       OR (       msn.group_mark_id IS NOT NULL
                              -- Performance Bug : 5367744
                              AND NOT EXISTS (
                                   SELECT 1
                                   FROM mtl_reservations mr
                                   WHERE mr.reservation_id = msn.reservation_id
                                   AND NVL(mr.staged_flag, 'N') = 'Y')
                              AND NOT EXISTS (
                                   SELECT 1
                                   FROM  mtl_serial_numbers_temp msnt
                                   WHERE msn.serial_number BETWEEN msnt.fm_serial_number
                                   AND   msnt.to_serial_number)
                           )

                      )
                  AND msn.current_status = 3
                  AND msn.serial_number LIKE (p_serial_number || '%')
                  AND milv.organization_id(+) = p_current_organization_id
                  AND milv.inventory_location_id(+) = msn.current_locator_id
                  AND msiv.organization_id = p_current_organization_id
                  AND msiv.inventory_item_id = msn.inventory_item_id
                  AND msi.organization_id = p_current_organization_id
                  AND msi.secondary_inventory_name = msn.current_subinventory_code;
  END get_serial_subxfr_lov;

  --      Name: GET_SERIAL_LOV_MO
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           which restricts LOV SQL to current item
  --       p_serial            which restricts LOV SQL to the serial entered
  --       p_transaction_type_id  trx_type_id
  --       p_wms_installed     whether WMS-enabled ORG
  --       p_move_order_line_id which include the serials allocated to the
  --                            move order line
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers limited by
  --         the specified move order line and all other avialable serial
  --         numbers and status='Received';
  PROCEDURE get_serial_lov_mo(x_serial_number OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_serial IN VARCHAR2, p_transaction_type_id IN NUMBER, p_wms_installed IN VARCHAR2, p_move_order_line_id IN NUMBER := NULL) IS
  BEGIN
    -- Bug 7695297, added condition of move_order_line_id for lot_serial controlled items.
    OPEN x_serial_number FOR
      SELECT   serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , 0
             , current_status
             , mms.status_code
             , ''
             , msn.revision
          FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
         WHERE inventory_item_id = p_item_id
           AND (group_mark_id IS NULL
                OR group_mark_id = -1
                OR group_mark_id IN (SELECT transaction_temp_id
                                       FROM mtl_material_transactions_temp
                                      WHERE move_order_line_id = p_move_order_line_id
                                     UNION
                                     SELECT mtlt.serial_transaction_temp_id
                                       FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
                                      WHERE move_order_line_id = p_move_order_line_id
                                        AND mtlt.transaction_temp_id = mmtt.transaction_temp_id
                                        AND mtlt.serial_transaction_temp_id IS NOT NULL)
               )
           AND current_organization_id = p_organization_id
           AND current_status = 3
           AND msn.lpn_id IS NULL
           AND msn.status_id = mms.status_id(+)
           AND mms.language (+) = userenv('LANG')
           AND serial_number LIKE (p_serial)
           AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, msn.current_subinventory_code, msn.current_locator_id, msn.lot_number, msn.serial_number, 'A') = 'Y'
      ORDER BY LPAD(serial_number, 20);
  END get_serial_lov_mo;

  --      Name: GET_SERIAL_LOV_WMA_NEGISS
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           which restricts LOV SQL to current item
  --       p_serial            which restricts LOV SQL to the serial entered
  --       p_transaction_type_id  trx_type_id
  --       p_wms_installed     whether WMS-enabled ORG
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers limited to
  --         status of 'DEFINED NOT USED' and 'ISSUED OUT OF STORES' (to WIP).
  --         Used by WMA negative issue.
  --
  PROCEDURE get_serial_lov_wma_negiss(x_serial_number OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_serial IN VARCHAR2, p_lot_number IN VARCHAR2, p_transaction_type_id IN NUMBER, p_wms_installed IN VARCHAR2) IS
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number VARCHAR2(80);
  BEGIN
    IF (p_lot_number IS NULL) THEN
      l_lot_number  := '%';
    ELSE
      l_lot_number  := p_lot_number || '%';
    END IF;

    OPEN x_serial_number FOR
      SELECT   serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , ''
             , current_status
             , mms.status_code
          FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
         WHERE current_organization_id = p_organization_id
           AND inventory_item_id = p_item_id
           AND msn.status_id = mms.status_id(+)
           AND mms.language (+) = userenv('LANG')
           AND (current_status = 1 or current_status = 6
                OR (current_status = 4
                    AND last_txn_source_type_id = 5 -- returned to WIP
                    AND (NVL(lot_number, '%') LIKE l_lot_number)))
           AND serial_number LIKE (p_serial)
           AND (group_mark_id IS NULL OR group_mark_id = -1)
           AND (inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, current_organization_id, inventory_item_id, current_subinventory_code, current_locator_id, lot_number, serial_number, 'S')) = 'Y'
      ORDER BY LPAD(serial_number, 20);
  END get_serial_lov_wma_negiss;

  --      Name: GET_SERIAL_LOV_WMA_ISS
    --
    --      Input parameters:
    --       p_Organization_Id   which restricts LOV SQL to current org
    --       p_item_id           which restricts LOV SQL to current item
    --       p_serial            which restricts LOV SQL to the serial entered
    --       p_transaction_type_id  trx_type_id
    --       p_wms_installed     whether WMS-enabled ORG
    --       p_lot               which restricts LOV SQL to the current lot
    --
    --      Output parameters:
    --       x_serial_number      returns LOV rows as reference cursor
    --
    --      Functions: This API is to return serial numbers limited to
    --         a specific lot and status of 'RESIDES IN STORES'.  Used by WMA
    --         transaction that issue out of inventory.
    --
  PROCEDURE get_serial_lov_wma_iss(
    x_serial_number       OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_serial              IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_subinv              IN     VARCHAR2
  , p_locator_id          IN     NUMBER
  , p_revision            IN     VARCHAR2
  , p_lot                 IN     VARCHAR2
  ) IS
  BEGIN
    OPEN x_serial_number FOR
      SELECT DISTINCT serial_number
                    , current_subinventory_code
                    , current_locator_id
                    , lot_number
                    , ''
                    , current_status
                    , mms.status_code
                 FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
                WHERE current_organization_id = p_organization_id
                  AND inventory_item_id = p_item_id
                  AND current_status = 3
                  AND msn.status_id = mms.status_id(+)
                  AND mms.language (+) = userenv('LANG')
                  -- bug 2360642: don't select serials that are packed into lpns
                  AND msn.lpn_id IS NULL
                  AND NVL(current_subinventory_code, '$@#$%') = NVL(p_subinv, NVL(current_subinventory_code, '$@#$%'))
                  AND NVL(current_locator_id, -1) = DECODE(p_locator_id, -1, NVL(current_locator_id, -1), p_locator_id)
                  AND NVL(lot_number, '$@#$%') = NVL(p_lot, NVL(lot_number, '$@#$%'))
                  AND NVL(revision, '$@#$%') = NVL(p_revision, NVL(revision, '$@#$%'))
                  AND serial_number LIKE (p_serial)
                  AND (group_mark_id IS NULL
                       OR group_mark_id = -1
                      )
                  AND (inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, current_organization_id, inventory_item_id, current_subinventory_code, current_locator_id, lot_number, serial_number, 'S')) =
                                                                                                                                                                                                                                                      'Y'
             ORDER BY LPAD(serial_number, 20);
  END get_serial_lov_wma_iss;

  --      Name: GET_SERIAL_LOV_WMA_RCV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           which restricts LOV SQL to current item
  --       p_serial            which restricts LOV SQL to the serial entered
  --       p_transaction_type_id  trx_type_id
  --       p_wms_installed     whether WMS-enabled ORG
  --       p_wip_entity_id     for SN that are 'ISSUED OUT OF STORES' (returned
  --                           from inventory), restrict to current job/schedule
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers limited to
  --         status of 'DEFINED NOT USED'.  Used by WMA completion and negative
  --         issue transactions.
  --
  PROCEDURE get_serial_lov_wma_rcv(
    x_serial_number       OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_serial              IN     VARCHAR2
  , p_lot_number          IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_wip_entity_id       IN     NUMBER
  ) IS
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number VARCHAR2(80);
  BEGIN
    IF (p_lot_number IS NULL) THEN
      l_lot_number  := '%';
    ELSE
      l_lot_number  := p_lot_number || '%';
    END IF;

    OPEN x_serial_number FOR
      SELECT   serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , ''
             , current_status
             , mms.status_code
          FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
         WHERE current_organization_id = p_organization_id
           AND inventory_item_id = p_item_id
           AND msn.status_id = mms.status_id(+)
           AND mms.language (+) = userenv('LANG')
           AND (current_status = 1 or current_status = 6
                OR (current_status = 4
                    AND last_txn_source_type_id = 5 -- returned to WIP
                    AND (((p_wip_entity_id <> -1)
                          AND (p_wip_entity_id = last_txn_source_id)
                          AND (NVL(lot_number, '%') LIKE l_lot_number)
                         )
                         OR ((p_wip_entity_id = -1)
                             AND (NVL(lot_number, '%') LIKE l_lot_number)
                             AND (4 = (SELECT entity_type
                                         FROM wip_entities
                                        WHERE wip_entity_id = last_txn_source_id)
                                 )
                            )
                        )
                   )
               )
           AND serial_number LIKE (p_serial)
           AND (group_mark_id IS NULL
                OR group_mark_id = -1
               )
           AND (inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, current_organization_id, inventory_item_id, current_subinventory_code, current_locator_id, lot_number, serial_number, 'S')) = 'Y'
      ORDER BY LPAD(serial_number, 20);
  END get_serial_lov_wma_rcv;

  --      Name: GET_SERIAL_LOV_WMA_RETCOMP
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           which restricts LOV SQL to current item
  --       p_serial            which restricts LOV SQL to the serial entered
  --       p_transaction_type_id  trx_type_id
  --       p_wms_installed     whether WMS-enabled ORG
  --       p_wip_entity_id     restricts to SN that were issued to the same job/schedule
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers limited to
  --         status of 'ISSUED OUT OF STORES".  Use by WMA component return transactions.
  --
  PROCEDURE get_serial_lov_wma_retcomp(
    x_serial_number OUT NOCOPY t_genref
  , p_organization_id IN NUMBER
  , p_item_id IN NUMBER
  , p_serial IN VARCHAR2
  , p_transaction_type_id IN NUMBER
  , p_wms_installed IN VARCHAR2
  , p_wip_entity_id IN NUMBER, p_lot IN VARCHAR2
  ) IS
  BEGIN
    OPEN x_serial_number FOR
      SELECT   serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , 0
             , current_status
             , mms.status_code
          FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
         WHERE inventory_item_id = p_item_id
           AND (group_mark_id IS NULL
                OR group_mark_id = -1
               )
           AND current_status = 4
           AND last_txn_source_type_id = 5 -- issued to WIP
           AND msn.status_id = mms.status_id(+)
           AND mms.language (+) = userenv('LANG')
           AND NVL(lot_number, '$@#$%') = NVL(p_lot, NVL(lot_number, '$@#$%'))
           AND inv_material_status_grp.is_status_applicable(p_wms_installed, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, NULL, NULL, NULL, serial_number, 'S') = 'Y'
           AND (((p_wip_entity_id <> -1)
                 AND (p_wip_entity_id = last_txn_source_id)
                )
                OR ((p_wip_entity_id = -1)
                    AND (4 = (SELECT entity_type
                                FROM wip_entities
                               WHERE wip_entity_id = last_txn_source_id)
                        )
                   )
               )
           AND serial_number LIKE (p_serial)
      ORDER BY LPAD(serial_number, 20);
  END get_serial_lov_wma_retcomp;

  PROCEDURE get_serial_lov_wma_retcomp(
    x_serial_number OUT NOCOPY t_genref
  , p_organization_id IN NUMBER
  , p_item_id IN NUMBER
  , p_serial IN VARCHAR2
  , p_transaction_type_id IN NUMBER
  , p_wms_installed IN VARCHAR2
  , p_wip_entity_id IN NUMBER
  , p_lot IN VARCHAR2
  , p_revision IN VARCHAR2
  ) IS
  BEGIN
    OPEN x_serial_number FOR
      SELECT   serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , 0
             , current_status
             , mms.status_code
          FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
         WHERE inventory_item_id = p_item_id
           AND (group_mark_id IS NULL
                OR group_mark_id = -1
               )
           AND current_status = 4
           AND last_txn_source_type_id = 5 -- issued to WIP
           AND msn.status_id = mms.status_id(+)
           AND mms.language (+) = userenv('LANG')
           AND NVL(lot_number, '$@#$%') = NVL(p_lot, NVL(lot_number, '$@#$%'))
           AND nvl(msn.revision, '$@#$%') = nvl(p_revision, '$@#$%')
           AND inv_material_status_grp.is_status_applicable(p_wms_installed, p_transaction_type_id, NULL, NULL,
 p_organization_id, p_item_id, NULL, NULL, NULL, serial_number, 'S') = 'Y'
           AND (((p_wip_entity_id <> -1)
                 AND (p_wip_entity_id = last_txn_source_id)
                )
                OR ((p_wip_entity_id = -1)
                    AND (4 = (SELECT entity_type
                                FROM wip_entities
                               WHERE wip_entity_id = last_txn_source_id)
                        )
                   )
               )
           AND serial_number LIKE (p_serial)
      ORDER BY LPAD(serial_number, 20);
  END get_serial_lov_wma_retcomp;

  /* Serial Tracking in WIP: Added the following procedure to display the parent serial lov on the
  Mobile WIP component issue transactions */

  PROCEDURE get_parent_serial_lov_wma(
        x_serial_number         OUT NOCOPY t_genref,
        p_organization_id       IN  NUMBER,
        p_item_id               IN  NUMBER,
        p_serial                IN  VARCHAR2,
        p_transaction_type_id   IN  NUMBER,
        p_transaction_action_id IN  NUMBER,
        p_wip_entity_id         IN  NUMBER,
        p_wip_assembly_id IN  NUMBER,
        p_wms_installed         IN VARCHAR2)
   IS
        l_restrict_rcpt_ser NUMBER;
        l_wip_assembly_id NUMBER;
   BEGIN

      BEGIN
          select primary_item_id
          into l_wip_assembly_id
          From wip_discrete_jobs
          where wip_entity_id = p_wip_entity_id
          And organization_id = p_organization_id;
      EXCEPTION
               when others then
                  l_wip_assembly_id := p_wip_assembly_id;
      END;

      OPEN x_serial_number FOR
           select serial_number
                , current_subinventory_code
                , current_locator_id
           , lot_number
           , 0
           , current_status
           , mms.status_code
           from mtl_serial_numbers msn, mtl_material_statuses_tl mms
           where inventory_item_id = l_wip_assembly_id
           and msn.status_id = mms.status_id(+)
           AND mms.language (+) = userenv('LANG')
           AND CURRENT_organization_id = p_organization_id
           and (
                ((current_status = 1 or current_status = 6 )
                   AND p_transaction_action_id =1
                   AND (wip_entity_id = p_wip_entity_id OR wip_entity_id is null)
                 )
                 or ((current_status = 3 OR current_status = 4)
                      AND last_txn_source_type_id =5
                      AND last_txn_source_id = p_wip_entity_id
                      AND p_transaction_type_id = 35
                     )
                )--changed for bug 2767928
            and inv_material_status_grp.is_status_applicable(
                          p_wms_installed, p_transaction_type_id,NULL,NULL,
                          p_organization_id, p_item_id, NULL, NULL, NULL,
                serial_number,'S') = 'Y'
                 and serial_number like (p_serial)
           order by lpad(serial_number,20);
End get_parent_serial_lov_wma;


  --
  -- New Procedure to get the Flexfield Data for a Lot
  --
  --
  PROCEDURE get_lot_flex_info(
    p_org_id                 IN     NUMBER
  , p_lot_number             IN     VARCHAR2
  , p_inventory_item_id      IN     NUMBER
  , x_vendor_id              OUT    NOCOPY NUMBER
  , x_grade_code             OUT    NOCOPY VARCHAR2
  , x_origination_date       OUT    NOCOPY VARCHAR2
  , x_date_code              OUT    NOCOPY VARCHAR2
  , x_status_id              OUT    NOCOPY NUMBER
  , x_change_date            OUT    NOCOPY VARCHAR2
  , x_age                    OUT    NOCOPY NUMBER
  , x_retest_date            OUT    NOCOPY VARCHAR2
  , x_maturity_date          OUT    NOCOPY VARCHAR2
  , x_lot_attribute_category OUT    NOCOPY VARCHAR2
  , x_item_size              OUT    NOCOPY NUMBER
  , x_color                  OUT    NOCOPY VARCHAR2
  , x_volume                 OUT    NOCOPY NUMBER
  , x_volume_uom             OUT    NOCOPY VARCHAR2
  , x_place_of_origin        OUT    NOCOPY VARCHAR2
  , x_best_by_date           OUT    NOCOPY VARCHAR2
  , x_length                 OUT    NOCOPY NUMBER
  , x_length_uom             OUT    NOCOPY VARCHAR2
  , x_recycled_content       OUT    NOCOPY NUMBER
  , x_thickness              OUT    NOCOPY NUMBER
  , x_thickness_uom          OUT    NOCOPY VARCHAR2
  , x_width                  OUT    NOCOPY NUMBER
  , x_width_uom              OUT    NOCOPY VARCHAR2
  , x_curl_wrinkle_fold      OUT    NOCOPY VARCHAR2
  , x_c_attribute1           OUT    NOCOPY VARCHAR2
  , x_c_attribute2           OUT    NOCOPY VARCHAR2
  , x_c_attribute3           OUT    NOCOPY VARCHAR2
  , x_c_attribute4           OUT    NOCOPY VARCHAR2
  , x_c_attribute5           OUT    NOCOPY VARCHAR2
  , x_c_attribute6           OUT    NOCOPY VARCHAR2
  , x_c_attribute7           OUT    NOCOPY VARCHAR2
  , x_c_attribute8           OUT    NOCOPY VARCHAR2
  , x_c_attribute9           OUT    NOCOPY VARCHAR2
  , x_c_attribute10          OUT    NOCOPY VARCHAR2
  , x_c_attribute11          OUT    NOCOPY VARCHAR2
  , x_c_attribute12          OUT    NOCOPY VARCHAR2
  , x_c_attribute13          OUT    NOCOPY VARCHAR2
  , x_c_attribute14          OUT    NOCOPY VARCHAR2
  , x_c_attribute15          OUT    NOCOPY VARCHAR2
  , x_c_attribute16          OUT    NOCOPY VARCHAR2
  , x_c_attribute17          OUT    NOCOPY VARCHAR2
  , x_c_attribute18          OUT    NOCOPY VARCHAR2
  , x_c_attribute19          OUT    NOCOPY VARCHAR2
  , x_c_attribute20          OUT    NOCOPY VARCHAR2
  , x_d_attribute1           OUT    NOCOPY VARCHAR2
  , x_d_attribute2           OUT    NOCOPY VARCHAR2
  , x_d_attribute3           OUT    NOCOPY VARCHAR2
  , x_d_attribute4           OUT    NOCOPY VARCHAR2
  , x_d_attribute5           OUT    NOCOPY VARCHAR2
  , x_d_attribute6           OUT    NOCOPY VARCHAR2
  , x_d_attribute7           OUT    NOCOPY VARCHAR2
  , x_d_attribute8           OUT    NOCOPY VARCHAR2
  , x_d_attribute9           OUT    NOCOPY VARCHAR2
  , x_d_attribute10          OUT    NOCOPY VARCHAR2
  , x_n_attribute1           OUT    NOCOPY NUMBER
  , x_n_attribute2           OUT    NOCOPY NUMBER
  , x_n_attribute3           OUT    NOCOPY NUMBER
  , x_n_attribute4           OUT    NOCOPY NUMBER
  , x_n_attribute5           OUT    NOCOPY NUMBER
  , x_n_attribute6           OUT    NOCOPY NUMBER
  , x_n_attribute7           OUT    NOCOPY NUMBER
  , x_n_attribute8           OUT    NOCOPY NUMBER
  , x_n_attribute9           OUT    NOCOPY NUMBER
  , x_n_attribute10          OUT    NOCOPY NUMBER
  , x_supplier_lot_number    OUT    NOCOPY VARCHAR2
  , x_territory_code         OUT    NOCOPY VARCHAR2
  , x_vendor_name            OUT    NOCOPY VARCHAR2
  , x_description            OUT    NOCOPY VARCHAR2
  ) IS
  BEGIN
    SELECT vendor_id
         , grade_code
         , TO_CHAR(origination_date, 'YYYY/MM/DD HH24:MI:SS')
         , date_code
         , status_id
         , TO_CHAR(change_date, 'YYYY/MM/DD HH24:MI:SS')
         , age
         , TO_CHAR(retest_date, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(maturity_date, 'YYYY/MM/DD HH24:MI:SS')
         , lot_attribute_category
         , item_size
         , color
         , volume
         , volume_uom
         , place_of_origin
         , TO_CHAR(best_by_date, 'YYYY/MM/DD HH24:MI:SS')
         , LENGTH
         , length_uom
         , recycled_content
         , thickness
         , thickness_uom
         , width
         , width_uom
         , curl_wrinkle_fold
         , c_attribute1
         , c_attribute2
         , c_attribute3
         , c_attribute4
         , c_attribute5
         , c_attribute6
         , c_attribute7
         , c_attribute8
         , c_attribute9
         , c_attribute10
         , c_attribute11
         , c_attribute12
         , c_attribute13
         , c_attribute14
         , c_attribute15
         , c_attribute16
         , c_attribute17
         , c_attribute18
         , c_attribute19
         , c_attribute20
         , TO_CHAR(d_attribute1, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute2, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute3, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute4, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute5, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute6, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute7, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute8, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute9, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute10, 'YYYY/MM/DD HH24:MI:SS')
         , n_attribute1
         , n_attribute2
         , n_attribute3
         , n_attribute4
         , n_attribute5
         , n_attribute6
         , n_attribute7
         , n_attribute8
         , n_attribute9
         , n_attribute10
         , supplier_lot_number
         , territory_code
         , vendor_name
         , description
      INTO x_vendor_id
         , x_grade_code
         , x_origination_date
         , x_date_code
         , x_status_id
         , x_change_date
         , x_age
         , x_retest_date
         , x_maturity_date
         , x_lot_attribute_category
         , x_item_size
         , x_color
         , x_volume
         , x_volume_uom
         , x_place_of_origin
         , x_best_by_date
         , x_length
         , x_length_uom
         , x_recycled_content
         , x_thickness
         , x_thickness_uom
         , x_width
         , x_width_uom
         , x_curl_wrinkle_fold
         , x_c_attribute1
         , x_c_attribute2
         , x_c_attribute3
         , x_c_attribute4
         , x_c_attribute5
         , x_c_attribute6
         , x_c_attribute7
         , x_c_attribute8
         , x_c_attribute9
         , x_c_attribute10
         , x_c_attribute11
         , x_c_attribute12
         , x_c_attribute13
         , x_c_attribute14
         , x_c_attribute15
         , x_c_attribute16
         , x_c_attribute17
         , x_c_attribute18
         , x_c_attribute19
         , x_c_attribute20
         , x_d_attribute1
         , x_d_attribute2
         , x_d_attribute3
         , x_d_attribute4
         , x_d_attribute5
         , x_d_attribute6
         , x_d_attribute7
         , x_d_attribute8
         , x_d_attribute9
         , x_d_attribute10
         , x_n_attribute1
         , x_n_attribute2
         , x_n_attribute3
         , x_n_attribute4
         , x_n_attribute5
         , x_n_attribute6
         , x_n_attribute7
         , x_n_attribute8
         , x_n_attribute9
         , x_n_attribute10
         , x_supplier_lot_number
         , x_territory_code
         , x_vendor_name
         , x_description
      FROM mtl_lot_numbers
     WHERE organization_id = p_org_id
       AND inventory_item_id = p_inventory_item_id
       AND lot_number = p_lot_number;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END get_lot_flex_info;

  -- Bug# 4176656
  -- New Procedure to get the Flexfield Data for a given Serial Number
  --
  --
  PROCEDURE get_serial_flex_info(
  p_serial_number            IN     VARCHAR2
  , p_inventory_item_id      IN     NUMBER
  , x_attribute_category     OUT    NOCOPY VARCHAR2
  , x_attribute1             OUT    NOCOPY VARCHAR2
  , x_attribute2             OUT    NOCOPY VARCHAR2
  , x_attribute3             OUT    NOCOPY VARCHAR2
  , x_attribute4             OUT    NOCOPY VARCHAR2
  , x_attribute5             OUT    NOCOPY VARCHAR2
  , x_attribute6             OUT    NOCOPY VARCHAR2
  , x_attribute7             OUT    NOCOPY VARCHAR2
  , x_attribute8             OUT    NOCOPY VARCHAR2
  , x_attribute9             OUT    NOCOPY VARCHAR2
  , x_attribute10            OUT    NOCOPY VARCHAR2
  , x_attribute11            OUT    NOCOPY VARCHAR2
  , x_attribute12            OUT    NOCOPY VARCHAR2
  , x_attribute13            OUT    NOCOPY VARCHAR2
  , x_attribute14            OUT    NOCOPY VARCHAR2
  , x_attribute15            OUT    NOCOPY VARCHAR2
  , x_group_mark_id          OUT    NOCOPY NUMBER
  , x_serial_attribute_category OUT NOCOPY VARCHAR2
  , x_c_attribute1           OUT    NOCOPY VARCHAR2
  , x_c_attribute2           OUT    NOCOPY VARCHAR2
  , x_c_attribute3           OUT    NOCOPY VARCHAR2
  , x_c_attribute4           OUT    NOCOPY VARCHAR2
  , x_c_attribute5           OUT    NOCOPY VARCHAR2
  , x_c_attribute6           OUT    NOCOPY VARCHAR2
  , x_c_attribute7           OUT    NOCOPY VARCHAR2
  , x_c_attribute8           OUT    NOCOPY VARCHAR2
  , x_c_attribute9           OUT    NOCOPY VARCHAR2
  , x_c_attribute10          OUT    NOCOPY VARCHAR2
  , x_c_attribute11          OUT    NOCOPY VARCHAR2
  , x_c_attribute12          OUT    NOCOPY VARCHAR2
  , x_c_attribute13          OUT    NOCOPY VARCHAR2
  , x_c_attribute14          OUT    NOCOPY VARCHAR2
  , x_c_attribute15          OUT    NOCOPY VARCHAR2
  , x_c_attribute16          OUT    NOCOPY VARCHAR2
  , x_c_attribute17          OUT    NOCOPY VARCHAR2
  , x_c_attribute18          OUT    NOCOPY VARCHAR2
  , x_c_attribute19          OUT    NOCOPY VARCHAR2
  , x_c_attribute20          OUT    NOCOPY VARCHAR2
  , x_d_attribute1           OUT    NOCOPY VARCHAR2
  , x_d_attribute2           OUT    NOCOPY VARCHAR2
  , x_d_attribute3           OUT    NOCOPY VARCHAR2
  , x_d_attribute4           OUT    NOCOPY VARCHAR2
  , x_d_attribute5           OUT    NOCOPY VARCHAR2
  , x_d_attribute6           OUT    NOCOPY VARCHAR2
  , x_d_attribute7           OUT    NOCOPY VARCHAR2
  , x_d_attribute8           OUT    NOCOPY VARCHAR2
  , x_d_attribute9           OUT    NOCOPY VARCHAR2
  , x_d_attribute10          OUT    NOCOPY VARCHAR2
  , x_n_attribute1           OUT    NOCOPY NUMBER
  , x_n_attribute2           OUT    NOCOPY NUMBER
  , x_n_attribute3           OUT    NOCOPY NUMBER
  , x_n_attribute4           OUT    NOCOPY NUMBER
  , x_n_attribute5           OUT    NOCOPY NUMBER
  , x_n_attribute6           OUT    NOCOPY NUMBER
  , x_n_attribute7           OUT    NOCOPY NUMBER
  , x_n_attribute8           OUT    NOCOPY NUMBER
  , x_n_attribute9           OUT    NOCOPY NUMBER
  , x_n_attribute10          OUT    NOCOPY NUMBER
  ) IS
  BEGIN
    SELECT attribute_category
         , attribute1
         , attribute2
         , attribute3
         , attribute4
         , attribute5
         , attribute6
         , attribute7
         , attribute8
         , attribute9
         , attribute10
         , attribute11
         , attribute12
         , attribute13
         , attribute14
         , attribute15
         , group_mark_id
         , serial_attribute_category
         , c_attribute1
         , c_attribute2
         , c_attribute3
         , c_attribute4
         , c_attribute5
         , c_attribute6
         , c_attribute7
         , c_attribute8
         , c_attribute9
         , c_attribute10
         , c_attribute11
         , c_attribute12
         , c_attribute13
         , c_attribute14
         , c_attribute15
         , c_attribute16
         , c_attribute17
         , c_attribute18
         , c_attribute19
         , c_attribute20
         , TO_CHAR(d_attribute1, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute2, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute3, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute4, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute5, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute6, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute7, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute8, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute9, 'YYYY/MM/DD HH24:MI:SS')
         , TO_CHAR(d_attribute10, 'YYYY/MM/DD HH24:MI:SS')
         , n_attribute1
         , n_attribute2
         , n_attribute3
         , n_attribute4
         , n_attribute5
         , n_attribute6
         , n_attribute7
         , n_attribute8
         , n_attribute9
         , n_attribute10
      INTO x_attribute_category
         , x_attribute1
         , x_attribute2
         , x_attribute3
         , x_attribute4
         , x_attribute5
         , x_attribute6
         , x_attribute7
         , x_attribute8
         , x_attribute9
         , x_attribute10
         , x_attribute11
         , x_attribute12
         , x_attribute13
         , x_attribute14
         , x_attribute15
         , x_group_mark_id
         , x_serial_attribute_category
         , x_c_attribute1
         , x_c_attribute2
         , x_c_attribute3
         , x_c_attribute4
         , x_c_attribute5
         , x_c_attribute6
         , x_c_attribute7
         , x_c_attribute8
         , x_c_attribute9
         , x_c_attribute10
         , x_c_attribute11
         , x_c_attribute12
         , x_c_attribute13
         , x_c_attribute14
         , x_c_attribute15
         , x_c_attribute16
         , x_c_attribute17
         , x_c_attribute18
         , x_c_attribute19
         , x_c_attribute20
         , x_d_attribute1
         , x_d_attribute2
         , x_d_attribute3
         , x_d_attribute4
         , x_d_attribute5
         , x_d_attribute6
         , x_d_attribute7
         , x_d_attribute8
         , x_d_attribute9
         , x_d_attribute10
         , x_n_attribute1
         , x_n_attribute2
         , x_n_attribute3
         , x_n_attribute4
         , x_n_attribute5
         , x_n_attribute6
         , x_n_attribute7
         , x_n_attribute8
         , x_n_attribute9
         , x_n_attribute10
      FROM mtl_serial_numbers
     WHERE inventory_item_id = p_inventory_item_id
       AND serial_number = p_serial_number;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END get_serial_flex_info;


PROCEDURE get_item_load_serial_lov
  (x_serial_number        OUT NOCOPY t_genref     ,
   p_lpn_id               IN  NUMBER              ,
   p_organization_id      IN  NUMBER              ,
   p_item_id              IN  NUMBER              ,
   p_lot_number           IN  VARCHAR2            ,
   p_serial_number        IN  VARCHAR2)
  IS

BEGIN
   OPEN x_serial_number FOR
     SELECT  serial_number
     , current_subinventory_code
     , current_locator_id
     , lot_number
     , 0
     , current_status
     , mms.status_code
     FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
     WHERE lpn_id = p_lpn_id
     AND current_organization_id = p_organization_id
     AND inventory_item_id = p_item_id
     AND NVL(lot_number, 'NOLOT') = NVL(p_lot_number, 'NOLOT')
     AND (group_mark_id IS NULL
   OR group_mark_id = -1
   )
     AND msn.status_id = mms.status_id(+)
     AND mms.language (+) = userenv('LANG')
     AND serial_number LIKE (p_serial_number)
     AND inv_material_status_grp.is_status_applicable('TRUE',
            NULL,
            INV_GLOBALS.G_TYPE_CONTAINER_UNPACK,
            NULL,
            NULL,
            p_organization_id,
            p_item_id,
            NULL,
            NULL,
            NULL,
            msn.serial_number,
            'S') = 'Y'
     ORDER BY LPAD(msn.serial_number, 20);

END get_item_load_serial_lov;


PROCEDURE get_serial_load_serial_lov
  (x_serial_number        OUT NOCOPY t_genref     ,
   p_lpn_id               IN  NUMBER              ,
   p_organization_id      IN  NUMBER              ,
   p_item_id              IN  NUMBER              ,
   p_serial_number        IN  VARCHAR2)
  IS
BEGIN
   OPEN x_serial_number FOR
     SELECT  serial_number
     , current_subinventory_code
     , current_locator_id
     , lot_number
     , 0
     , current_status
     , mms.status_code
     FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
     WHERE lpn_id = p_lpn_id
     AND current_organization_id = p_organization_id
     AND inventory_item_id = p_item_id
     AND (group_mark_id IS NULL
   OR group_mark_id = -1
   )
     AND msn.status_id = mms.status_id(+)
     AND mms.language (+) = userenv('LANG')
     AND serial_number LIKE (p_serial_number)
     AND inv_material_status_grp.is_status_applicable('TRUE',
            NULL,
            INV_GLOBALS.G_TYPE_CONTAINER_UNPACK,
            NULL,
            NULL,
            p_organization_id,
            p_item_id,
            NULL,
            NULL,
            NULL,
            msn.serial_number,
            'S') = 'Y'
     ORDER BY LPAD(msn.serial_number, 20);

END get_serial_load_serial_lov;

  /**
    *   This procedure fetches the Serial Numbers for an item
    *   inside a LPN that "Resides in Receiving". It uses the
    *   serial number in RCV_SERIALS_SUPPLY that corresponds to the
    *   parent transaction.
    *   This LOV would be called from the Item-based Putaway Drop
    *   mobile page when the user confirms a quantity lesser than
    *   the suggested quantity.
    *  @param  x_serial_number      REF cursor containing the serial numbers fetched
    *  @param  p_lpn_id             Identifer for the LPN containing the serials
    *  @param  p_organization_id    Current Organization
    *  @param  p_inventory_item_id  Inventory Item
    *  @param  p_lot_number         Lot Number
    *  @param  p_txn_header_id      Transaction Header ID. This would be used to match
    *                               with rcv_serials_supply
    *  @param  p_serial             Serial Number entered on the UI
  **/
  PROCEDURE  get_rcv_lpn_serial_lov(
      x_serial_number     OUT NOCOPY  t_genref
  , p_lpn_id            IN          NUMBER
  , p_organization_id   IN          NUMBER
  , p_inventory_item_id IN          NUMBER
  , p_lot_number        IN          VARCHAR2
  , p_txn_header_id     IN          NUMBER
  , p_serial            IN          VARCHAR2) IS
  BEGIN
    OPEN x_serial_number FOR
      SELECT   serial_number
             , 0
             , 0
             , 0
             , 0
             , ''
             , ''
      FROM  mtl_serial_numbers msn
          , rcv_serials_supply rss
          , rcv_supply rs
      WHERE msn.lpn_id = p_lpn_id
      AND msn.inventory_item_id = p_inventory_item_id
      AND msn.current_organization_id = p_organization_id
      AND NVL(msn.lot_number, '&*^') = NVL(p_lot_number, '&*^')
      AND msn.serial_number LIKE (p_serial)
      AND msn.current_status = 7
      AND (group_mark_id IS NULL or group_mark_id = -1)
      AND rss.serial_num = msn.serial_number
      AND rs.lpn_id = p_lpn_id
      AND rss.transaction_id = rs.rcv_transaction_id
      AND rs.supply_type_code = 'RECEIVING'
      ORDER BY LPAD(serial_number, 20);
  END get_rcv_lpn_serial_lov;


/* Bug 4574714-Added the procedure to insert into temp table
               based on the ENFORCE_RMA_SERIAL_NUM value in
	       rcv_parameters. This is called before firing
	       the LOV query for serials for RMA*/


  PROCEDURE insert_temp_table_for_serials
  (p_organization_id IN NUMBER,
   p_item_id IN NUMBER,
   p_wms_installed IN VARCHAR2,
   p_oe_order_header_id IN NUMBER,
   x_returnSerialVal OUT NOCOPY VARCHAR2,
   x_return_status OUT  NOCOPY VARCHAR2,
   x_errorcode     OUT  NOCOPY NUMBER) IS

 l_return_status            VARCHAR2(1)  := fnd_api.g_ret_sts_success;
 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(4000);
 l_errorcode                VARCHAR2(4000);
 l_enforce_rma_sn           VARCHAR2(10);
 l_count_rows               NUMBER;

 BEGIN

    -- Bug 3907968
    -- Changes applicable for patchJ onwards
    -- File needed  for I branch is ARU: 3439979 and 3810978
    -- GET the SERIAL ENFORCE paramneter from Receiving Options
    -- IF enforce is YES
    --   then
    --      For all Order lines matching with the ITEM call INV_RMA_SERIAL_PVT.POPULATE_TEMP_TABLE
    --      to populate the temporary serial table MTL_RMA_SERIAL_TEMP
    --      Modify the LOV to join with MTL_RMA_SERIAL_TEMP
    -- Else
    --   the Existing LOV
    -- End if


    x_returnSerialVal:='N';

    select nvl(ENFORCE_RMA_SERIAL_NUM,'N')
      into   l_enforce_rma_sn
      from   RCV_PARAMETERS
     where  organization_id = p_organization_id;


 IF ( l_enforce_rma_sn = 'Y' and p_oe_order_header_id is not null) THEN

      For c_rma_line in ( select line_id
            FROM
                  OE_ORDER_LINES_all OEL,
                  OE_ORDER_HEADERS_all OEH
           WHERE OEL.LINE_CATEGORY_CODE='RETURN'
             AND OEL.INVENTORY_ITEM_ID = p_item_id
             AND nvl(OEL.SHIP_FROM_ORG_ID, OEH.SHIP_FROM_ORG_ID) = p_organization_id
             AND OEL.HEADER_ID = OEH.HEADER_ID
             AND OEH.HEADER_ID = p_oe_order_header_id
             AND OEL.ORDERED_QUANTITY > NVL(OEL.SHIPPED_QUANTITY,0)
             AND OEL.FLOW_STATUS_CODE = 'AWAITING_RETURN'
                                 )
               Loop

                INV_RMA_SERIAL_PVT.POPULATE_TEMP_TABLE(
                  p_api_version => 0.9
                , p_init_msg_list => FND_API.G_FALSE
                , p_commit => FND_API.G_FALSE
                , p_validation_level => FND_API.G_VALID_LEVEL_FULL
                , x_return_status => l_return_status
                , x_msg_count => l_msg_count
                , x_msg_data => l_msg_data
                , x_errorcode => l_errorcode
                , p_rma_line_id => c_rma_line.LINE_ID
                , p_org_id => P_ORGANIZATION_ID
                , p_item_id => p_item_id
                );

               End loop;

	       SELECT count(line_id)
	       INTO l_count_rows
	       FROM mtl_rma_serial_temp msrt
	       WHERE msrt.organization_id = p_organization_id
	       AND  msrt.inventory_item_id = p_item_id ;


              IF l_count_rows > 0  THEN
	       x_returnSerialVal:= 'Y' ;
	      ELSE
       	       x_returnSerialVal:= 'N' ;
              END IF;

  Else

  x_returnSerialVal:= 'N' ;

  End if;


END insert_temp_table_for_serials;

/* End of fix for Bug 4574714 */


/* Bug 4574714-Added the new procedure for the serial LOV query
               for RMAs. The additional input parameter p_restrict
	       decides whether the old LOV query or the new one, i.e from
	       the temp table should be fired.*/

 PROCEDURE get_serial_lov_rma_restrict
 (x_serial_number OUT NOCOPY t_genref,
  p_organization_id IN NUMBER,
  p_item_id IN NUMBER,
  p_serial IN VARCHAR2,
  p_transaction_type_id IN NUMBER,
  p_wms_installed IN VARCHAR2,
  p_oe_order_header_id IN NUMBER,
  p_restrict IN VARCHAR2) IS

 l_return_status            VARCHAR2(1)  := fnd_api.g_ret_sts_success;
 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(4000);
 l_errorcode                VARCHAR2(4000);
 l_enforce_rma_sn           VARCHAR2(10);

  BEGIN

   IF ( p_restrict = 'Y') THEN

              -- Set the new LOV below..
               OPEN x_serial_number FOR
               SELECT   serial_number
                      , current_subinventory_code
                      , current_locator_id
                      , lot_number
                      , 0
                      , current_status
                      , mms.status_code
                   FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
                  WHERE msn.inventory_item_id = p_item_id
                    AND (group_mark_id IS NULL
                         OR group_mark_id = -1
                        )
                    AND current_status = 4
                    AND msn.status_id = mms.status_id(+)
                    AND mms.language (+) = userenv('LANG')
                    AND inv_material_status_grp.is_status_applicable(p_wms_installed, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, NULL, NULL, NULL, serial_number, 'S') = 'Y'
                    AND msn.serial_number LIKE (p_serial)
                    AND EXISTS ( select 'x' from mtl_rma_serial_temp msrt
                                  where msrt.organization_id = p_organization_id
                                   and  msrt.inventory_item_id = p_item_id
                                   and msrt.serial_number = msn.serial_number
                                   and msrt.serial_number LIKE (p_serial)
                               )
               ORDER BY LPAD(serial_number, 20);

    Else

              -- the OLD LOV will work and will not restrict
               OPEN x_serial_number FOR
                 SELECT   serial_number
                        , current_subinventory_code
                        , current_locator_id
                        , lot_number
                        , 0
                        , current_status
                        , mms.status_code
                     FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
                    WHERE inventory_item_id = p_item_id
                      AND (group_mark_id IS NULL
                           OR group_mark_id = -1
                          )
                      AND current_status = 4
                      AND msn.status_id = mms.status_id(+)
                      AND mms.language (+) = userenv('LANG')
                      AND inv_material_status_grp.is_status_applicable(p_wms_installed, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, NULL, NULL, NULL, serial_number, 'S') = 'Y'
                      AND serial_number LIKE (p_serial)
                 ORDER BY LPAD(serial_number, 20);
    End if;
  END get_serial_lov_rma_restrict;

/* End of fix for Bug 4574714 */

/*Bug 4703782 (FP of BUG 4639427) -Added the procedure for the serial lov for asn */

 PROCEDURE get_serial_lov_asn_rcv
 (x_serial_number OUT NOCOPY t_genref,
  p_organization_id     IN NUMBER,
  p_item_id             IN NUMBER,
  p_shipment_header_id  IN NUMBER,
  p_serial              IN VARCHAR2,
  p_transaction_type_id IN NUMBER,
  p_wms_installed       IN VARCHAR2,
  p_from_lpn_id         IN NUMBER DEFAULT NULL)

  IS

  l_debug   NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

  BEGIN


    OPEN x_serial_number FOR
      SELECT   serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , 0
             , current_status
             , status_code
      FROM
      (SELECT  serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , 0
             , current_status
             , mms.status_code
          FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
         WHERE inventory_item_id = p_item_id
           AND (group_mark_id IS NULL
                OR group_mark_id = -1
               )
           AND ((current_organization_id = p_organization_id
                 AND current_status = 1
                )
                OR (current_status = 4 AND
                    Nvl(to_number(fnd_profile.value('INV_RESTRICT_RCPT_SER')), 2) = 2)
               )
           AND msn.status_id = mms.status_id(+)
           AND mms.language (+) = userenv('LANG')
           AND serial_number LIKE (p_serial)
           AND inv_material_status_grp.is_status_applicable(p_wms_installed, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, NULL, NULL, NULL, serial_number, 'S') = 'Y'
      UNION
       SELECT serial_number
             , current_subinventory_code
             , current_locator_id
             , lot_number
             , 0
             , current_status
             , mms.status_code
        FROM     rcv_serials_supply rss
               , rcv_shipment_lines rsl
               , mtl_serial_numbers msn
               , mtl_material_statuses_tl mms
        WHERE    rss.shipment_line_id(+) = rsl.shipment_line_id
        AND      nvl(rss.supply_type_code, 'SHIPMENT') = 'SHIPMENT'
        AND     (msn.group_mark_id IS NULL OR msn.group_mark_id = -1)
        AND      rsl.shipment_header_id = p_shipment_header_id
        AND      rsl.to_organization_id = p_organization_id
        AND      rsl.item_id = p_item_id
        AND      msn.inventory_item_id = p_item_id
        AND      msn.serial_number = rss.serial_num
        AND      msn.current_status = 5
        AND      Nvl(msn.lpn_id,NVL(p_from_lpn_id,-1)) = NVL(p_from_lpn_id, NVL(msn.lpn_id, -1))
        AND msn.status_id = mms.status_id(+)
        AND mms.language (+) = userenv('LANG')
        AND serial_number LIKE (p_serial)
        AND inv_material_status_grp.is_status_applicable(p_wms_installed, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, NULL, NULL, NULL, serial_number, 'S') = 'Y')
       ORDER BY LPAD(serial_number, 20) ;

  END get_serial_lov_asn_rcv;

  /* End of Bug 4703782 */

/* Bug 5577789-Added the procedure to insert into temp table
               based on the ENFORCE_RMA_SERIAL_NUM value in
               rcv_parameters. This is called before firing
               the LOV query for serials for RMA. This is for the deliver step*/


  PROCEDURE insert_RMA_serials_for_deliver
  (p_organization_id IN NUMBER,
   p_item_id IN NUMBER,
   p_wms_installed IN VARCHAR2,
   p_oe_order_header_id IN NUMBER,
   x_returnSerialVal OUT NOCOPY VARCHAR2,
   x_return_status OUT  NOCOPY VARCHAR2,
   x_errorcode     OUT  NOCOPY NUMBER) IS

 l_return_status            VARCHAR2(1)  := fnd_api.g_ret_sts_success;
 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(4000);
 l_errorcode                VARCHAR2(4000);
 l_enforce_rma_sn           VARCHAR2(10);
 l_count_rows               NUMBER;

 BEGIN

    -- Bug 3907968
    -- Changes applicable for patchJ onwards
    -- File needed  for I branch is ARU: 3439979 and 3810978
    -- GET the SERIAL ENFORCE paramneter from Receiving Options
    -- IF enforce is YES
    --   then
    --      For all Order lines matching with the ITEM call INV_RMA_SERIAL_PVT.POPULATE_TEMP_TABLE
    --      to populate the temporary serial table MTL_RMA_SERIAL_TEMP
    --      Modify the LOV to join with MTL_RMA_SERIAL_TEMP
    -- Else
    --   the Existing LOV
    -- End if


    x_returnSerialVal:='N';

    select nvl(ENFORCE_RMA_SERIAL_NUM,'N')
      into   l_enforce_rma_sn
      from   RCV_PARAMETERS
     where  organization_id = p_organization_id;


 IF ( l_enforce_rma_sn = 'Y' and p_oe_order_header_id is not null) THEN

      For c_rma_line in ( select line_id
            FROM
                  OE_ORDER_LINES_all OEL,
                  OE_ORDER_HEADERS_all OEH
           WHERE OEL.LINE_CATEGORY_CODE='RETURN'
             AND OEL.INVENTORY_ITEM_ID = p_item_id
             AND nvl(OEL.SHIP_FROM_ORG_ID, OEH.SHIP_FROM_ORG_ID) = p_organization_id
             AND OEL.HEADER_ID = OEH.HEADER_ID
             AND OEH.HEADER_ID = p_oe_order_header_id
             AND OEL.ORDERED_QUANTITY >= NVL(OEL.SHIPPED_QUANTITY,0)
             AND OEL.FLOW_STATUS_CODE = 'AWAITING_RETURN_DISPOSITION'
                                 )
               Loop

                INV_RMA_SERIAL_PVT.POPULATE_TEMP_TABLE(
                  p_api_version => 0.9
                , p_init_msg_list => FND_API.G_FALSE
                , p_commit => FND_API.G_FALSE
                , p_validation_level => FND_API.G_VALID_LEVEL_FULL
                , x_return_status => l_return_status
                , x_msg_count => l_msg_count
                , x_msg_data => l_msg_data
                , x_errorcode => l_errorcode
                , p_rma_line_id => c_rma_line.LINE_ID
                , p_org_id => P_ORGANIZATION_ID
                , p_item_id => p_item_id
                );

               End loop;

               SELECT count(line_id)
               INTO l_count_rows
               FROM mtl_rma_serial_temp msrt
               WHERE msrt.organization_id = p_organization_id
               AND  msrt.inventory_item_id = p_item_id ;

              IF l_count_rows > 0  THEN
               x_returnSerialVal:= 'Y' ;
              ELSE
               x_returnSerialVal:= 'N' ;
              END IF;

  Else

  x_returnSerialVal:= 'N' ;

  End if;


END insert_RMA_serials_for_deliver;

/* End of fix for Bug 5577789 */
--bug 6928897
PROCEDURE get_to_ostatus_serial_lov(
    x_seriallov OUT NOCOPY t_genref
  , p_organization_id IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_from_lot_number IN VARCHAR2
  , p_to_lot_number IN VARCHAR2
  , p_from_serial_number IN VARCHAR2
  , p_serial_number IN VARCHAR2
  ) IS
  BEGIN

    OPEN x_seriallov FOR
      SELECT serial_number
           , current_subinventory_code
           , current_locator_id
           , lot_number
           , 0
           , current_status
           , status_code
        FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
       WHERE current_organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id
         --AND current_status IN (1, 3, 5)
         AND current_status IN (1, 3, 5, 7)
         AND (p_from_lot_number IS NULL
              OR lot_number >= p_from_lot_number
             )
         AND (p_to_lot_number IS NULL
              OR lot_number <= p_to_lot_number
             )
         AND msn.status_id = mms.status_id(+)
         AND mms.language (+) = userenv('LANG')
         AND msn.lpn_id is null
         AND serial_number >= p_from_serial_number
         AND serial_number LIKE (p_serial_number);
  END;

    PROCEDURE get_serial_lov_ostatus(x_seriallov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_from_lot_number IN VARCHAR2, p_to_lot_number IN VARCHAR2, p_serial_number IN VARCHAR2) IS
  BEGIN

    OPEN x_seriallov FOR
      SELECT serial_number
           , current_subinventory_code
           , current_locator_id
           , lot_number
           , 0
           , current_status
           , mms.status_code
        FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
       WHERE current_organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id
         --AND current_status IN (1, 3, 5)
         AND current_status IN (1, 3, 5, 7)
         AND (p_from_lot_number IS NULL
              OR lot_number >= p_from_lot_number
             )
         AND (p_to_lot_number IS NULL
              OR lot_number <= p_to_lot_number
             )
         AND msn.status_id = mms.status_id(+)
         AND mms.language (+) = userenv('LANG')
         AND serial_number LIKE (p_serial_number)
         AND msn.lpn_id is NULL;
  END;
--end of bug 6928897
--bug 6952533
PROCEDURE GET_TO_LPN_SERIAL_LOV_OSTATUS(
    x_seriallov OUT NOCOPY t_genref
  , p_organization_id IN NUMBER
  , p_inventory_item_id IN NUMBER
   ,p_lpn_id NUMBER
  , p_lot_number IN VARCHAR2
  , p_from_serial_number IN VARCHAR2
  , p_serial_number IN VARCHAR2
  ) IS
  BEGIN
    /* FP-J Lot/Serial Support Enhancements
     * Add current status of resides in receiving
     */
    OPEN x_seriallov FOR
      SELECT serial_number
           , current_subinventory_code
           , current_locator_id
           , lot_number
           , 0
           , current_status
           , status_code
        FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
       WHERE current_organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id
         AND (p_lot_number IS NULL
              OR lot_number = p_lot_number)
         AND msn.status_id = mms.status_id(+)
         AND mms.language (+) = userenv('LANG')
          AND msn.lpn_id = p_lpn_id
         AND serial_number >= p_from_serial_number
         AND serial_number LIKE (p_serial_number)
        ;
  END;

    PROCEDURE GET_LPN_STATUS_SERIAL_LOV(x_seriallov OUT NOCOPY t_genref,
                                         p_organization_id IN NUMBER,
                                         p_inventory_item_id IN NUMBER,
                                         p_lpn_id IN NUMBER,
                                         p_lot_number IN VARCHAR2,
                                         p_serial_number IN VARCHAR2) IS
  BEGIN
    /* FP-J Lot/Serial Support Enhancements
     * Add current status of resides in receiving
     */
    OPEN x_seriallov FOR
      SELECT serial_number
           , current_subinventory_code
           , current_locator_id
           , lot_number
           , 0
           , current_status
           , mms.status_code
        FROM mtl_serial_numbers msn, mtl_material_statuses_tl mms
       WHERE current_organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id
         --AND current_status IN (1, 3, 5)
         AND current_status IN (1, 3, 5, 7)
         AND (p_lot_number IS NULL
              OR lot_number = p_lot_number
             )
         AND msn.status_id = mms.status_id(+)
         AND mms.language (+) = userenv('LANG')
          AND msn.lpn_id = p_lpn_id
         AND serial_number LIKE (p_serial_number)
        ;
  END;
  --bug 6952533
END inv_ui_item_att_lovs;

/
