--------------------------------------------------------
--  DDL for Package Body INV_INV_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INV_LOVS" AS
  /* $Header: INVINVLB.pls 120.19.12010000.11 2010/04/02 10:55:18 kjujjuru ship $ */


  --      Name: GET_LOT_LOV
  --
  --      Input parameters:
  --       p_organization_id     Organization ID
  --       p_item_id             Inventory Item id
  --       p_lot_number          Lot Number
  --       p_transaction_type_id Used for Material Status Applicability Check
  --       p_wms_installed       Used for Material Status Applicability Check
  --       p_lpn_id              LPN ID
  --       p_subinventory_code   SubInventory Code
  --       p_locator_id          Locator ID
  --       p_planning_org_id     Planning Organization ID - Consignment and VMI Changes
  --       p_planning_tp_type    Planning TP Type         - Consignment and VMI Changes
  --       p_owning_org_id       Owning Organization ID   - Consignment and VMI Changes
  --       p_owning_tp_type      Owning TP Type           - Consignment and VMI Changes
  --
  --      Output parameters:
  --       x_lot_num_lov         Returns the LOV rows as a Reference Cursor
  --
  --      Functions: This API returns Lot number for a given org and Item Id
  --Passed subinventory and locator in is_status_applicable call when sub is not null.
  PROCEDURE get_lot_lov(
    x_lot_num_lov         OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_lot_number          IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_lpn_id              IN     NUMBER
  , p_subinventory_code   IN     VARCHAR2
  , p_locator_id          IN     NUMBER
  , p_planning_org_id     IN     NUMBER
  , p_planning_tp_type    IN     NUMBER
  , p_owning_org_id       IN     NUMBER
  , p_owning_tp_type      IN     NUMBER
  ) IS
  BEGIN
     IF p_subinventory_code IS NULL THEN
 OPEN x_lot_num_lov FOR
   SELECT DISTINCT mln.lot_number
   , mln.description
   , mln.expiration_date
   , mmst.status_code
   FROM mtl_lot_numbers mln
   , mtl_material_statuses_tl mmst
   WHERE mln.organization_id = p_organization_id
   AND mln.inventory_item_id = p_item_id
   AND mln.lot_number LIKE (p_lot_number)
   AND mln.status_id = mmst.status_id (+)
   AND mmst.language (+) = userenv('LANG')
   AND exists (SELECT '1' FROM mtl_onhand_quantities_detail moqd
        WHERE moqd.lot_number = mln.lot_number
        AND moqd.inventory_item_id = mln.inventory_item_id
        AND moqd.organization_id = mln.organization_id
        AND ((moqd.containerized_flag = 1 AND p_lpn_id IS NOT NULL)
      OR (moqd.containerized_flag = 2 AND p_lpn_id IS NULL))
        AND (p_planning_org_id IS NULL
      OR moqd.planning_organization_id = p_planning_org_id)
        AND (p_planning_tp_type IS NULL
      OR moqd.planning_tp_type = p_planning_tp_type)
        AND (p_owning_org_id IS NULL
      OR moqd.owning_organization_id = p_owning_org_id)
        AND (p_owning_tp_type IS NULL
      OR moqd.owning_tp_type = p_owning_tp_type))
          AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, NULL, NULL, mln.lot_number, NULL, 'O') = 'Y'
   -- Bug 5018199
   UNION
   SELECT DISTINCT mln.parent_lot_number
   , mln.description
   , mln.expiration_date
   , mmst.status_code
   FROM mtl_lot_numbers mln
   , mtl_material_statuses_tl mmst
   WHERE mln.organization_id = p_organization_id
   AND mln.inventory_item_id = p_item_id
   AND mln.lot_number LIKE (p_lot_number)
   AND mln.status_id = mmst.status_id (+)
   AND mmst.language (+) = userenv('LANG')
   AND mln.parent_lot_number IS NOT NULL
   AND exists (SELECT '1' FROM mtl_onhand_quantities_detail moqd
        WHERE moqd.lot_number = mln.lot_number
        AND moqd.inventory_item_id = mln.inventory_item_id
        AND moqd.organization_id = mln.organization_id
        AND ((moqd.containerized_flag = 1 AND p_lpn_id IS NOT NULL)
      OR (moqd.containerized_flag = 2 AND p_lpn_id IS NULL))
        AND (p_planning_org_id IS NULL
      OR moqd.planning_organization_id = p_planning_org_id)
        AND (p_planning_tp_type IS NULL
      OR moqd.planning_tp_type = p_planning_tp_type)
        AND (p_owning_org_id IS NULL
      OR moqd.owning_organization_id = p_owning_org_id)
        AND (p_owning_tp_type IS NULL
      OR moqd.owning_tp_type = p_owning_tp_type))
          AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, NULL, NULL, mln.lot_number, NULL, 'O') = 'Y';
   -- End Bug 5018199
      ELSE
 OPEN x_lot_num_lov FOR
   SELECT DISTINCT mln.lot_number
   , mln.description
   , mln.expiration_date
   , mmst.status_code
   FROM mtl_lot_numbers mln
   , mtl_material_statuses_tl mmst
   WHERE mln.organization_id = p_organization_id
   AND mln.inventory_item_id = p_item_id
   AND mln.lot_number LIKE (p_lot_number)
   AND mln.status_id = mmst.status_id (+)
   AND mmst.language (+) = userenv('LANG')
   AND exists (SELECT '1' FROM mtl_onhand_quantities_detail moqd
        WHERE moqd.lot_number = mln.lot_number
        AND moqd.inventory_item_id = mln.inventory_item_id
        AND moqd.organization_id = mln.organization_id
        AND ((moqd.containerized_flag = 1 AND p_lpn_id IS NOT NULL)
      OR (moqd.containerized_flag = 2 AND p_lpn_id IS NULL))
        AND moqd.subinventory_code = p_subinventory_code
        AND NVL(moqd.locator_id, -1) = NVL(NVL(p_locator_id, moqd.locator_id), -1)
        AND (p_planning_org_id IS NULL
      OR moqd.planning_organization_id = p_planning_org_id)
        AND (p_planning_tp_type IS NULL
      OR moqd.planning_tp_type = p_planning_tp_type)
        AND (p_owning_org_id IS NULL
      OR moqd.owning_organization_id = p_owning_org_id)
        AND (p_owning_tp_type IS NULL
      OR moqd.owning_tp_type = p_owning_tp_type))
          AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y';
          --Passed p_subinventory_code and p_locator_id in is_status_applicable call for Onhand status support project ,Bug#6633612
     END IF;
  END get_lot_lov;

  --      Name: GET_LOT_LOV_FOR_RECEIVING
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_lot_number   which restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --
  --

  PROCEDURE get_lot_lov_for_receiving(
    x_lot_num_lov         OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_lot_number          IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_lpn_id              IN     NUMBER
  , p_subinventory_code   IN     VARCHAR2
  , p_locator_id          IN     NUMBER
  ) IS
  BEGIN
    OPEN x_lot_num_lov FOR
      SELECT DISTINCT mln.lot_number
      , mln.description
      , mln.expiration_date
      , mmst.status_code
      FROM mtl_lot_numbers mln,
      mtl_material_statuses_tl mmst
      WHERE mln.organization_id = p_organization_id
      AND mln.inventory_item_id = p_item_id
      AND mln.lot_number LIKE (p_lot_number)
      AND NVL(mln.disable_flag,'2') = '2' --Bug#4108798 Disabled lots must not be displayed
      AND NVL(mln.expiration_date,sysdate +1 ) > sysdate -- Expired lots must not be displayed . -- Bug#5360600 - Items with null expiration date should be displayed.
      AND mln.status_id = mmst.status_id (+)
      AND mmst.language (+) = userenv('LANG')
      AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinventory_code, p_locator_id , mln.lot_number, NULL, 'O') = 'Y';
  END get_lot_lov_for_receiving;

  --      Name: ASN_LOT_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_lot_number   which restricts LOV SQL to the user input text
  --       p_source_header_id which restricts to the shipment
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --
  --

  PROCEDURE asn_lot_lov(
    x_lot_num_lov         OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_lot_number          IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_lpn_id              IN     NUMBER
  , p_subinventory_code   IN     VARCHAR2
  , p_locator_id          IN     NUMBER
  , p_source_header_id    IN     NUMBER
  ) IS
  BEGIN
    OPEN x_lot_num_lov FOR
      SELECT DISTINCT mln.lot_number
      , mln.description
      , mln.expiration_date
      , mmst.status_code
      FROM mtl_lot_numbers mln,
      mtl_material_statuses_tl mmst
      WHERE mln.organization_id = p_organization_id
      AND mln.inventory_item_id = p_item_id
      AND mln.lot_number LIKE (p_lot_number)
      AND exists (SELECT '1' FROM mtl_onhand_quantities_detail moq
    WHERE moq.lot_number = mln.lot_number
    AND moq.inventory_item_id = mln.inventory_item_id
    AND moq.organization_id = mln.organization_id)
      AND mln.status_id = mmst.status_id (+)
      AND mmst.language (+) = userenv('LANG')
      AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y'
      UNION
      SELECT DISTINCT mln.lot_number
      , mln.description
      , mln.expiration_date
      , mmst.status_code
      FROM mtl_lot_numbers mln, wms_asn_details wad,
      rcv_shipment_headers rsh, mtl_material_statuses_tl mmst
      WHERE mln.organization_id = p_organization_id
      AND mln.inventory_item_id = p_item_id
      AND mln.lot_number LIKE (p_lot_number)
      AND mln.lot_number = wad.lot_number_expected
      AND mln.inventory_item_id = wad.item_id
      AND mln.organization_id = wad.organization_id
      AND mln.status_id = mmst.status_id (+)
      AND mmst.language (+) = userenv('LANG')
      AND wad.organization_id = p_organization_id
      AND wad.discrepancy_reporting_context = 'O'
      AND wad.item_id = p_item_id
      AND wad.shipment_num = rsh.shipment_num
      AND rsh.shipment_header_id = p_source_header_id
      --Bug5726837:Added the following union to take care of direct delivery cases
      --when there is no data present in wms_asn_details and moqd.
      UNION
      SELECT   rls.lot_num lot_number
      , mln.description
      , mln.expiration_date
      , mmst.status_code
     FROM mtl_lot_numbers mln, rcv_lots_supply rls,
     rcv_shipment_lines rsl, mtl_material_statuses_tl mmst
     WHERE rls.shipment_line_id = rsl.shipment_line_id
     AND rsl.shipment_header_id = p_source_header_id
     AND rsl.to_organization_id = p_organization_id
     AND rsl.item_id = p_item_id
     AND rls.supply_type_code = 'SHIPMENT'
     AND mln.inventory_item_id = p_item_id
     AND rls.lot_num = mln.lot_number
     AND rls.lot_num LIKE (p_lot_number)
     AND mln.status_id = mmst.status_id (+)
     AND mmst.language (+) = userenv('LANG')
     AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL,p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinventory_code , p_locator_id , lot_number, NULL, 'O') = 'Y'
     GROUP BY rls.lot_num, mln.description, mln.expiration_date, mmst.status_code
     HAVING SUM(rls.primary_quantity) > 0;
  END asn_lot_lov;

  --      Name: GET_LOT_LOV_INT_SHP_RCV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_shipment_header_id
  --       p_lot_number   which restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org, lpn
  --              and Item Id
  --
  --
-- Added p_subinventory_code and p_locator_id parameters as part of onhand status support project
  PROCEDURE get_lot_lov_int_shp_rcv(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_shipment_header_id IN NUMBER,p_lot_number IN VARCHAR2, p_transaction_type_id IN NUMBER,
                                    p_wms_installed IN VARCHAR2 ,p_subinventory_code IN VARCHAR2,p_locator_id IN NUMBER
				    , p_from_lpn_id IN NUMBER  DEFAULT NULL  --Bug 6908946
				    ) IS
    l_lot_control_code NUMBER;
  BEGIN
    BEGIN
      SELECT msik.lot_control_code
        INTO l_lot_control_code
        FROM mtl_system_items_kfv msik, rcv_shipment_lines rsl
       WHERE msik.inventory_item_id = p_item_id
         AND msik.inventory_item_id = rsl.item_id --Bug 4235750
         AND rsl.shipment_header_id = p_shipment_header_id
         AND rsl.to_organization_id = p_organization_id
         AND rsl.from_organization_id = msik.organization_id
	 AND Nvl(rsl.asn_lpn_id,-1) = Nvl(decode(p_from_lpn_id,0,NULL,p_from_lpn_id),Nvl(rsl.asn_lpn_id,-1)) --Bug 6908946
         AND rownum < 2; --Bug 4235750
    EXCEPTION
      WHEN OTHERS THEN
        l_lot_control_code  := 2;
    END;

    IF l_lot_control_code = 2 THEN
       OPEN x_lot_num_lov FOR
  SELECT   rls.lot_num lot_number
  , mlnv.description
  , mlnv.expiration_date
  , mmst.status_code
  FROM mtl_lot_numbers mlnv, rcv_lots_supply rls,
  rcv_shipment_lines rsl, mtl_material_statuses_tl mmst
  WHERE rls.shipment_line_id = rsl.shipment_line_id
  AND rsl.shipment_header_id = p_shipment_header_id
  AND rsl.to_organization_id = p_organization_id
  AND rsl.item_id = p_item_id
  AND Nvl(rsl.asn_lpn_id,-1) = Nvl(decode(p_from_lpn_id,0,NULL,p_from_lpn_id),Nvl(rsl.asn_lpn_id,-1)) --Bug 6908946
  AND mlnv.organization_id = rsl.from_organization_id
  AND mlnv.inventory_item_id = p_item_id
  AND rls.lot_num = mlnv.lot_number
  AND rls.lot_num LIKE (p_lot_number)
  AND rls.SUPPLY_TYPE_CODE  =  'SHIPMENT' --Bug 6908946
  AND mlnv.status_id = mmst.status_id (+)
  AND mmst.language (+) = userenv('LANG')
  AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinventory_code , p_locator_id , lot_number, NULL, 'O') = 'Y'
  GROUP BY rls.lot_num, mlnv.description, mlnv.expiration_date, mmst.status_code
  HAVING SUM(rls.quantity) > 0;
     ELSE  --Added p_subinventory_code and p_locator_id in below call:
       get_lot_lov_for_receiving(x_lot_num_lov, p_organization_id, p_item_id, p_lot_number, p_transaction_type_id, p_wms_installed, NULL, p_subinventory_code, p_locator_id);
    END IF;
  END get_lot_lov_int_shp_rcv;

  --      Name: GET_PACK_LOT_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_lot_number   which restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --
  --

  PROCEDURE get_pack_lot_lov(
    x_lot_num_lov         OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_revision            IN     VARCHAR2 := NULL
  , p_subinventory_code   IN     VARCHAR2 := NULL
  , p_locator_id          IN     NUMBER := 0
  , p_lot_number          IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER := 0
  , p_wms_installed       IN     VARCHAR2 := 'TRUE'
  ) IS
  BEGIN
     OPEN x_lot_num_lov FOR
       SELECT DISTINCT mln.lot_number
       , mln.description
       , mln.expiration_date
       , mmst.status_code
       FROM mtl_lot_numbers mln,
       mtl_material_statuses_tl mmst
       WHERE mln.organization_id = p_organization_id
       AND mln.inventory_item_id = p_item_id
       AND mln.lot_number LIKE (p_lot_number)
       AND exists ( SELECT '1' FROM mtl_onhand_quantities_detail moq
                    WHERE mln.lot_number = moq.lot_number
                    AND moq.organization_id = p_organization_id
                    AND moq.lpn_id IS NULL -- added for bug 4614645
                    AND NVL(moq.revision, '@') = NVL(p_revision, NVL(moq.revision, '@'))
                    AND NVL(moq.subinventory_code, '@') = NVL(p_subinventory_code, NVL(moq.subinventory_code, '@'))
                    AND NVL(moq.locator_id, -999) = NVL(p_locator_id, NVL(moq.locator_id, -999))
                    AND moq.inventory_item_id = p_item_id)
       AND mln.status_id = mmst.status_id (+)
       AND mmst.language (+) = userenv('LANG')
       AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y';
  END get_pack_lot_lov;

  --      Name: GET_CGUPDATE_LOT_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   restricts LOV SQL to current org
  --       p_lpn_id
  --       p_inventory_item_id restricts LOV SQL to Inventory Item id
  --       p_revision
  --       p_subinventory_code
  --       p_locator_id
  --       p_from_cost_Group_id
  --       p_lot_number        restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --

  PROCEDURE get_cgupdate_lot_lov(
    x_lot_num_lov        OUT    NOCOPY t_genref
  , p_organization_id    IN     NUMBER
  , p_lpn_id             IN     NUMBER
  , p_inventory_item_id  IN     NUMBER
  , p_revision           IN     VARCHAR2
  , p_subinventory_code  IN     VARCHAR2
  , p_locator_id         IN     NUMBER
  , p_from_cost_group_id IN     NUMBER
  , p_lot_number         IN     VARCHAR2
  ) IS
  BEGIN
     IF p_lpn_id IS NULL THEN
 OPEN x_lot_num_lov FOR
   SELECT DISTINCT moq.lot_number
   , mln.description
   , mln.expiration_date
   , mmst.status_code
   FROM mtl_lot_numbers mln, mtl_onhand_quantities_detail moq,
   mtl_material_statuses_tl mmst
   WHERE mln.lot_number = moq.lot_number
   AND mln.inventory_item_id = p_inventory_item_id
   AND mln.organization_id = p_organization_id
   AND mln.status_id = mmst.status_id (+)
   AND mmst.language (+) = userenv('LANG')
   AND inv_material_status_grp.is_status_applicable('TRUE', NULL, 86, NULL, NULL, p_organization_id, p_inventory_item_id, p_subinventory_code , p_locator_id , moq.lot_number, NULL, 'O') = 'Y'
   AND moq.lot_number LIKE (p_lot_number)
   AND (moq.cost_group_id = p_from_cost_group_id
        OR p_from_cost_group_id IS NULL
        )
   AND (moq.revision = p_revision
        OR (moq.revision IS NULL
     AND p_revision IS NULL
     )
        )
       AND moq.containerized_flag = 2
       AND moq.inventory_item_id = p_inventory_item_id
       AND moq.locator_id = p_locator_id
       AND moq.subinventory_code = p_subinventory_code
       AND moq.organization_id = p_organization_id
       ORDER BY moq.lot_number;
      ELSE  --As lpn_id is not null ,hence not passing sub and loc in is_status_applicable
 OPEN x_lot_num_lov FOR
   SELECT DISTINCT wlc.lot_number
   , mln.description
   , mln.expiration_date
   , mmst.status_code
   FROM mtl_lot_numbers mln, wms_lpn_contents wlc,
   mtl_material_statuses_tl mmst
   WHERE mln.lot_number = wlc.lot_number
   AND mln.inventory_item_id = p_inventory_item_id
   AND mln.organization_id = p_organization_id
   AND mln.status_id = mmst.status_id (+)
   AND mmst.language (+) = userenv('LANG')
   AND inv_material_status_grp.is_status_applicable('TRUE', NULL, 86, NULL, NULL, p_organization_id, p_inventory_item_id, NULL, NULL, wlc.lot_number, NULL, 'O') = 'Y'
   AND wlc.lot_number LIKE (p_lot_number)
   AND (wlc.cost_group_id = p_from_cost_group_id
        OR p_from_cost_group_id IS NULL
        )
   AND (wlc.revision = p_revision
        OR (wlc.revision IS NULL
     AND p_revision IS NULL
     )
        )
       AND wlc.inventory_item_id = p_inventory_item_id
       AND wlc.parent_lpn_id = p_lpn_id
       ORDER BY wlc.lot_number;
     END IF;
  END get_cgupdate_lot_lov;

  --      Name: GET_INQ_LOT_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_lot_number   which restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id without status restrictiong for inquiry purpose.
  --

  PROCEDURE get_inq_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_lot_number IN VARCHAR2) IS
  BEGIN
     OPEN x_lot_num_lov FOR
       SELECT mln.lot_number
       , mln.description
       , mln.expiration_date
       , mmst.status_code
       FROM mtl_lot_numbers mln, mtl_material_statuses_tl mmst
       WHERE mln.organization_id = p_organization_id
       AND mln.inventory_item_id = p_item_id
       AND mln.status_id = mmst.status_id (+)
       AND mmst.language (+) = userenv('LANG')
       AND mln.lot_number LIKE (p_lot_number);
  END get_inq_lot_lov;

  --      Name: GET_FROM_STATUS_LOT_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_lot_number   which restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --

  PROCEDURE get_from_status_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_lot_number IN VARCHAR2) IS
  BEGIN
     OPEN x_lot_num_lov FOR
       SELECT mln.lot_number
       , mln.description
       , mln.expiration_date
       , mmst.status_code
       FROM mtl_lot_numbers mln, mtl_material_statuses_tl mmst
       WHERE mln.organization_id = p_organization_id
       AND mln.inventory_item_id = p_item_id
       AND mln.status_id = mmst.status_id (+)
       AND mmst.language (+) = userenv('LANG')
       AND mln.lot_number LIKE (p_lot_number)
       ORDER BY mln.lot_number;
  END get_from_status_lot_lov;

  --      Name: GET_TO_STATUS_LOT_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_lot_number   which restricts LOV SQL to the user input text
  --       p_from_lot_number   starting lot number
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --

  PROCEDURE get_to_status_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_from_lot_number IN VARCHAR2, p_lot_number IN VARCHAR2) IS
  BEGIN
     OPEN x_lot_num_lov FOR
       SELECT mln.lot_number
       , mln.description
       , mln.expiration_date
       , mmst.status_code
       FROM mtl_lot_numbers mln, mtl_material_statuses_tl mmst
       WHERE mln.organization_id = p_organization_id
       AND mln.inventory_item_id = p_item_id
       AND mln.status_id = mmst.status_id (+)
       AND mmst.language (+) = userenv('LANG')
       AND mln.lot_number >= p_from_lot_number
       AND mln.lot_number LIKE (p_lot_number)
       ORDER BY mln.lot_number;
  END get_to_status_lot_lov;

  --      Name: GET_REASON_LOV
  --
  --      Input parameters:
  --       p_reason   which restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_reason_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Transaction Reasons
  --

  PROCEDURE get_reason_lov(x_reason_lov OUT NOCOPY t_genref, p_reason IN VARCHAR2) IS
  BEGIN
    OPEN x_reason_lov FOR
      SELECT reason_name
           , description
           , reason_id
        FROM mtl_transaction_reasons
       WHERE reason_name LIKE (p_reason)
        AND nvl(DISABLE_DATE,SYSDATE+1) > SYSDATE ;
  END;

  --      Name: GET_REASON_LOV
  --       Overloaed Procedure
  --      Input parameters:
  --       p_reason       restricts LOV SQL to the user input text
  --       p_txn_type_id  restricts LOV SQL specific transaction type id.
  --      Output parameters:
  --       x_reason_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Transaction Reasons
  --

  PROCEDURE get_reason_lov(x_reason_lov OUT NOCOPY t_genref, p_reason IN VARCHAR2, p_txn_type_id IN VARCHAR2 ) IS
  BEGIN
    OPEN x_reason_lov FOR
      SELECT reason_name
           , description
           , reason_id
        FROM mtl_transaction_reasons
       WHERE reason_name LIKE (p_reason)
        AND nvl(DISABLE_DATE,SYSDATE+1) > SYSDATE
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
        ORDER BY REASON_NAME

        ;
  END;

  -- Procedure overloaded for Transaction Reason Security build. 4505091, nsrivast
  PROCEDURE get_to_org_lov(x_to_org_lov OUT NOCOPY t_genref, p_from_organization_id IN NUMBER, p_to_organization_code IN VARCHAR2) IS
  BEGIN
    OPEN x_to_org_lov FOR
      SELECT DISTINCT org.organization_id
                    , org.organization_code
                    , org.organization_name
                 FROM org_organization_definitions org, mtl_system_items msi
                WHERE org.organization_id <> p_from_organization_id
                  AND org.organization_id = msi.organization_id
                  AND msi.inventory_item_id IN (SELECT inventory_item_id
                                                  FROM mtl_system_items
                                                 WHERE organization_id = p_from_organization_id)
                  AND org.organization_code LIKE (p_to_organization_code);
  END get_to_org_lov;

  -- used by org transfer

  PROCEDURE get_to_org(x_organizations OUT NOCOPY t_genref, p_from_organization_id IN NUMBER, p_to_organization_code IN VARCHAR2) IS
  BEGIN
    OPEN x_organizations FOR
      SELECT   a.to_organization_id
             , b.organization_code
             , c.NAME
             , a.intransit_type
          FROM mtl_interorg_parameters a, mtl_parameters b, hr_all_organization_units c
         WHERE a.from_organization_id = p_from_organization_id
           AND a.to_organization_id = b.organization_id
           AND a.to_organization_id = c.organization_id
           AND a.internal_order_required_flag = 2
           AND b.organization_code LIKE (p_to_organization_code)
      ORDER BY 2;
  END get_to_org;

  PROCEDURE get_all_orgs(x_organizations OUT NOCOPY t_genref, p_organization_code IN VARCHAR2) IS
  BEGIN
    OPEN x_organizations FOR
      /* SELECT DISTINCT organization_id
                    , organization_code
                    , organization_name
                    , 0
           FROM org_organization_definitions
           WHERE organization_code LIKE (p_organization_code)
           ORDER BY 2; */
 --Bug 2649387
 SELECT  distinct mp.organization_id
  , mp.organization_code
  , hu.name organization_name
  ,0
         FROM mtl_parameters mp
  , hr_organization_units hu
  WHERE mp.organization_code LIKE (p_organization_code || '%')
  and  mp.organization_id = hu.organization_id order by 2;
  END get_all_orgs;

  PROCEDURE get_cost_group(x_cost_group_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_cost_group IN VARCHAR2) IS
  BEGIN
    OPEN x_cost_group_lov FOR
-- Bug 6378032 Cost group LOV was fetching all cost groups irrespective of
--             organization
/*      SELECT cost_group
           , cost_group_id
           , description
        FROM cst_cost_groups
       WHERE cost_group LIKE (p_cost_group); */
  select ccg.cost_group ,ccga.cost_group_id, ccg.description
  from cst_cost_groups ccg, cst_cost_group_accounts ccga
  where ccg.cost_group_id = ccga.cost_group_id
  and ccga.organization_id = nvl(p_organization_id, ccga.organization_id)
  --WHERE organization_id = p_organization_id
  and ccg.cost_group LIKE (p_cost_group);
  END get_cost_group;


  --      Name: GET_CGUPDATE_COST_GROUP
  --
  --      Input parameters:
  --        p_organization_id         Restricts LOV SQL to specific org
  --        p_lpn_id                  Restricts LOV SQL to specific LPN
  --        p_inventory_item_id       Restricts LOV SQL to specific item
  --        p_subinventory            Restricts LOV SQL to specific sub
  --        p_locator_id              Restricts LOV SQL to specific loc if given
  --        p_from_cost_group_id      Restricts LOV SQL to not include the
  --                                  from cost group if not null
  --        p_from_cost_group         Restricts LOV SQL to user input text
  --        p_to_cost_group           Restricts LOV SQL to user input text
  --
  --      Output parameters:
  --        x_cost_group_lov          Output reference cursor which stores
  --                                  the LOV rows for valid cost groups
  --
  --      Functions: This API returns a reference cursor for valid cost groups
  --                 in Cost Group update UI associated with the given parameters
  --
  /* PJM-WMS Integration:
  /* Return only Cost Groups of types other than 'project'.*/
  PROCEDURE get_cgupdate_cost_group(
    x_cost_group_lov     OUT    NOCOPY t_genref
  , p_organization_id    IN     NUMBER
  , p_lpn_id             IN     NUMBER
  , p_inventory_item_id  IN     NUMBER
  , p_revision           IN     VARCHAR2
  , p_subinventory_code  IN     VARCHAR2
  , p_locator_id         IN     NUMBER
  , p_from_cost_group_id IN     NUMBER
  , p_from_cost_group    IN     VARCHAR2
  , p_to_cost_group      IN     VARCHAR2
  ) IS
  BEGIN
    IF p_from_cost_group_id IS NULL THEN
      IF p_lpn_id IS NULL THEN
        OPEN x_cost_group_lov FOR
          SELECT   ccg.cost_group
                 , ccg.cost_group_id
                 , ccg.description
              FROM cst_cost_groups ccg, mtl_onhand_quantities_detail moq
             WHERE ccg.cost_group LIKE (p_from_cost_group)
               AND ccg.cost_group_id = moq.cost_group_id
               AND ccg.cost_group_type <> 1 --PJM-WMS Integration
               AND ((moq.revision = p_revision)
                    OR (moq.revision IS NULL
                        AND p_revision IS NULL
                       )
                   )
               AND moq.containerized_flag = 2
               AND moq.inventory_item_id = p_inventory_item_id
               AND moq.locator_id = p_locator_id
               AND moq.subinventory_code = p_subinventory_code
               AND moq.organization_id = p_organization_id
          GROUP BY ccg.cost_group, ccg.cost_group_id, ccg.description
          ORDER BY ccg.cost_group;
      ELSE
        OPEN x_cost_group_lov FOR
          SELECT   ccg.cost_group
                 , ccg.cost_group_id
                 , ccg.description
              FROM cst_cost_groups ccg, wms_lpn_contents wlc
             WHERE ccg.cost_group LIKE (p_from_cost_group)
               AND ccg.cost_group_id = wlc.cost_group_id
               AND ccg.cost_group_type <> 1 --PJM-WMS Integration
               AND ((wlc.revision = p_revision)
                    OR (wlc.revision IS NULL
                        AND p_revision IS NULL
                       )
                   )
               AND wlc.inventory_item_id = p_inventory_item_id
               AND wlc.parent_lpn_id = p_lpn_id
          GROUP BY ccg.cost_group, ccg.cost_group_id, ccg.description
          ORDER BY ccg.cost_group;
      END IF;
    ELSE
      OPEN x_cost_group_lov FOR
        SELECT   ccg.cost_group
               , ccg.cost_group_id
               , ccg.description
            FROM cst_cost_groups ccg, cst_cost_group_accounts ccga
           WHERE ccg.cost_group LIKE (p_to_cost_group)
             AND ccg.cost_group_id = ccga.cost_group_id
             AND ccga.cost_group_id <> p_from_cost_group_id
             AND ccg.cost_group_type <> 1 --PJM-WMS Integration
             AND ccga.organization_id = p_organization_id
        GROUP BY ccg.cost_group, ccg.cost_group_id, ccg.description
        ORDER BY ccg.cost_group;
    END IF;
  END get_cgupdate_cost_group;

  PROCEDURE get_phyinv_cost_group(
    x_cost_group_lov        OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_cost_group            IN     VARCHAR2
  , p_inventory_item_id     IN     NUMBER
  , p_subinventory          IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_dynamic_entry_flag    IN     NUMBER
  , p_physical_inventory_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  ) IS
  BEGIN
    IF (p_dynamic_entry_flag = 1) THEN -- Dynamic entries are allowed
      OPEN x_cost_group_lov FOR
        SELECT cost_group
             , cost_group_id
             , description
          FROM cst_cost_groups
         WHERE organization_id = p_organization_id
           AND cost_group LIKE (p_cost_group);
    ELSE -- Dynamic entries are not allowed
      OPEN x_cost_group_lov FOR
        SELECT UNIQUE ccg.cost_group
                    , ccg.cost_group_id
                    , ccg.description
                 FROM cst_cost_groups ccg, mtl_physical_inventory_tags mpit
                WHERE ccg.organization_id = p_organization_id
                  AND ccg.cost_group LIKE (p_cost_group)
                  AND ccg.cost_group_id = mpit.cost_group_id
                  AND mpit.physical_inventory_id = p_physical_inventory_id
                  AND mpit.organization_id = p_organization_id
                  AND mpit.subinventory = p_subinventory
                  AND NVL(mpit.locator_id, -99999) = NVL(p_locator_id, -99999)
                  AND mpit.inventory_item_id = p_inventory_item_id
                  AND NVL(mpit.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
                  AND NVL(mpit.void_flag, 2) = 2
                  AND mpit.adjustment_id IN (SELECT adjustment_id
                                               FROM mtl_physical_adjustments
                                              WHERE physical_inventory_id = p_physical_inventory_id
                                                AND organization_id = p_organization_id
                                                AND approval_status IS NULL);
    END IF;
  END get_phyinv_cost_group;

  PROCEDURE get_cyc_cost_group(
    x_cost_group_lov        OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_cost_group            IN     VARCHAR2
  , p_inventory_item_id     IN     NUMBER
  , p_subinventory          IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_unscheduled_entry     IN     NUMBER
  , p_cycle_count_header_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  ) IS
  BEGIN
    IF (p_unscheduled_entry = 1) THEN -- Unscheduled entries are allowed
      OPEN x_cost_group_lov FOR
        SELECT cost_group
             , cost_group_id
             , description
          FROM cst_cost_groups
         WHERE organization_id = p_organization_id
           AND cost_group LIKE (p_cost_group);
    ELSE -- Unscheduled entries are not allowed
      OPEN x_cost_group_lov FOR
        SELECT UNIQUE ccg.cost_group
                    , ccg.cost_group_id
                    , ccg.description
                 FROM cst_cost_groups ccg, mtl_cycle_count_entries mcce
                WHERE ccg.organization_id = p_organization_id
                  AND ccg.cost_group LIKE (p_cost_group)
                  AND ccg.cost_group_id = mcce.cost_group_id
                  AND mcce.cycle_count_header_id = p_cycle_count_header_id
                  AND mcce.organization_id = p_organization_id
                  AND mcce.subinventory = p_subinventory
                  AND NVL(mcce.locator_id, -99999) = NVL(p_locator_id, -99999)
                  AND mcce.inventory_item_id = p_inventory_item_id
                  AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
                  AND mcce.entry_status_code IN (1, 3);
    END IF;
  END get_cyc_cost_group;

  PROCEDURE get_txn_types(x_txntypelov OUT NOCOPY t_genref, p_transaction_action_id IN NUMBER, p_transaction_source_type_id IN NUMBER, p_transaction_type_name IN VARCHAR2) IS
  BEGIN
    IF (p_transaction_action_id = 2
        AND p_transaction_source_type_id = 13
       ) THEN
      OPEN x_txntypelov FOR
        SELECT transaction_type_id
             , transaction_type_name
             , description
             , transaction_action_id
          FROM mtl_transaction_types
         WHERE transaction_action_id = p_transaction_action_id
           AND transaction_source_type_id = p_transaction_source_type_id
           AND transaction_type_name LIKE (p_transaction_type_name)
           AND transaction_type_id NOT IN (66, 67, 68)
           AND Nvl(disable_date,SYSDATE+1) > SYSDATE; -- Bug9394143, to filter the transaction types that are disabled
    ELSE
      OPEN x_txntypelov FOR
        SELECT transaction_type_id
             , transaction_type_name
             , description
             , transaction_action_id
          FROM mtl_transaction_types
         WHERE transaction_action_id = p_transaction_action_id
           AND transaction_source_type_id = p_transaction_source_type_id
           AND transaction_type_name LIKE (p_transaction_type_name)
           AND Nvl(disable_date,SYSDATE+1) > SYSDATE; -- Bug9394143, to filter the transaction types that are disabled
    END IF;
  END get_txn_types;

  --      Name: GET_ITEM_LOT_LOV
  --
  --      Input parameters:
  --       p_wms_installed     which restricts LOV SQL to wms installed
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_txn_type_id       which restricts LOV SQL to txn type
  --       p_inventory_item_id which restricts LOV SQL to inventory item
  --       p_lot_number        which restricts LOV SQL to the user input text
  --       p_project_id        which restricts LOV SQL to project
  --       p_task_id           which restricts LOV SQL to task
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --
  --
-- Added p_subinventory_code and p_locator_id parameters as part of onhand status support project
  PROCEDURE get_item_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_wms_installed IN VARCHAR2, p_organization_id IN NUMBER, p_txn_type_id IN NUMBER, p_inventory_item_id IN VARCHAR2,
                             p_lot_number IN VARCHAR2, p_project_id IN NUMBER, p_task_id IN NUMBER ,p_subinventory_code IN VARCHAR2 ,p_locator_id IN NUMBER) IS
    l_inventory_item_id VARCHAR2(100);
  BEGIN
    IF p_inventory_item_id IS NULL THEN
      l_inventory_item_id  := '%';
    ELSE
      l_inventory_item_id  := p_inventory_item_id;
    END IF;

    IF p_txn_type_id = inv_globals.g_type_inv_lot_split -- Lot Split (82)
                                                        THEN
      OPEN x_lot_num_lov FOR
        SELECT   mln.lot_number lot_number
               , mln.inventory_item_id
               , msik.concatenated_segments concatenated_segments
               , msik.description
               , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
               , mms.status_code status_code
               , mms.status_id
            FROM mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms
           WHERE mms.status_id = msik.default_lot_status_id -- Bug#2267947
             AND msik.default_lot_status_id IS NOT NULL -- Bug#2267947
             AND mln.organization_id = p_organization_id
             AND mln.organization_id = msik.organization_id
             AND mln.inventory_item_id = msik.inventory_item_id
             AND mln.inventory_item_id LIKE l_inventory_item_id
             AND msik.lot_split_enabled = 'Y'
             AND mln.lot_number LIKE (p_lot_number)
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled,
                                                              p_organization_id, msik.inventory_item_id, p_locator_id , p_subinventory_code , mln.lot_number, NULL, 'O') = 'Y'
        UNION ALL
        SELECT   mln.lot_number lot_number
               , mln.inventory_item_id
               , msik.concatenated_segments concatenated_segments
               , msik.description
               , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
               , NULL status_code
               , msik.default_lot_status_id -- Bug#2267947
            FROM mtl_lot_numbers mln, mtl_system_items_kfv msik
           WHERE msik.default_lot_status_id IS NULL -- Bug#2267947
             AND mln.organization_id = p_organization_id
             AND mln.organization_id = msik.organization_id
             AND mln.inventory_item_id = msik.inventory_item_id
             AND mln.inventory_item_id LIKE l_inventory_item_id
             AND msik.lot_split_enabled = 'Y'
             AND mln.lot_number LIKE (p_lot_number)
        ORDER BY lot_number, concatenated_segments;
    ELSE
      IF p_txn_type_id = inv_globals.g_type_inv_lot_merge -- Lot Merge 83
                                                          THEN
        IF (p_project_id IS NOT NULL) THEN
          OPEN x_lot_num_lov FOR
            SELECT DISTINCT moq.lot_number
                          , moq.inventory_item_id
                          , msik.concatenated_segments concatenated_segments
                          , msik.description
                          , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                          , mms.status_code
                          , mms.status_id
                       FROM mtl_onhand_quantities_detail moq, mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms, mtl_item_locations mil
                      WHERE moq.organization_id = p_organization_id
                        AND moq.lot_number IS NOT NULL
                        AND moq.organization_id = mil.organization_id
                        AND moq.organization_id = mln.organization_id
                        AND moq.organization_id = msik.organization_id
                        AND mil.segment19 = p_project_id
                        AND (mil.segment20 = p_task_id
                             OR (mil.segment20 IS NULL
                                 AND p_task_id IS NULL
                                )
                            )
                        AND mln.lot_number = moq.lot_number
                        AND mms.status_id = msik.default_lot_status_id -- Bug#2267947
                        AND msik.default_lot_status_id IS NOT NULL -- Bug#2267947
                        AND mln.inventory_item_id = msik.inventory_item_id
                        AND mln.inventory_item_id LIKE l_inventory_item_id
                        AND msik.lot_merge_enabled = 'Y'
                        AND mln.lot_number LIKE (p_lot_number)
                        AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled,
                                                                         p_organization_id, msik.inventory_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y'
            UNION ALL
            SELECT DISTINCT moq.lot_number
                          , moq.inventory_item_id
                          , msik.concatenated_segments concatenated_segments
                          , msik.description
                          , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                          , NULL status_code
                          , msik.default_lot_status_id -- Bug#2267947
                       FROM mtl_onhand_quantities_detail moq, mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms, mtl_item_locations mil
                      WHERE moq.organization_id = p_organization_id
                        AND moq.lot_number IS NOT NULL
                        AND moq.organization_id = mil.organization_id
                        AND moq.organization_id = mln.organization_id
                        AND moq.organization_id = msik.organization_id
                        AND mil.segment19 = p_project_id
                        AND (mil.segment20 = p_task_id
                             OR (mil.segment20 IS NULL
                                 AND p_task_id IS NULL
                                )
                            )
                        AND mln.lot_number = moq.lot_number
                        AND msik.default_lot_status_id IS NULL -- Bug#2267947
                        AND mln.inventory_item_id = msik.inventory_item_id
                        AND mln.inventory_item_id LIKE l_inventory_item_id
                        AND msik.lot_merge_enabled = 'Y'
                        AND mln.lot_number LIKE (p_lot_number)
                        AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled,
                                                                         p_organization_id, msik.inventory_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y'
                   ORDER BY 1, concatenated_segments;
        ELSE
          OPEN x_lot_num_lov FOR
            SELECT   mln.lot_number lot_number
                   , mln.inventory_item_id
                   , msik.concatenated_segments concatenated_segments
                   , msik.description
                   , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                   , mms.status_code
                   , mms.status_id
                FROM mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms
               WHERE mms.status_id = msik.default_lot_status_id -- Bug#2267947
                 AND msik.default_lot_status_id IS NOT NULL -- Bug#2267947
                 AND mln.organization_id = p_organization_id
                 AND mln.organization_id = msik.organization_id
                 AND mln.inventory_item_id = msik.inventory_item_id
                 AND mln.inventory_item_id LIKE l_inventory_item_id
                 AND msik.lot_merge_enabled = 'Y'
                 AND mln.lot_number LIKE (p_lot_number)
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled,
                                                                  p_organization_id, msik.inventory_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y'
            UNION ALL
            SELECT   mln.lot_number lot_number
                   , mln.inventory_item_id
                   , msik.concatenated_segments concatenated_segments
                   , msik.description
                   , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                   , NULL status_code
                   , msik.default_lot_status_id -- Bug#2267947
                FROM mtl_lot_numbers mln, mtl_system_items_kfv msik
               WHERE msik.default_lot_status_id IS NULL -- Bug#2267947
                 AND mln.organization_id = p_organization_id
                 AND mln.organization_id = msik.organization_id
                 AND mln.inventory_item_id = msik.inventory_item_id
                 AND mln.inventory_item_id LIKE l_inventory_item_id
                 AND msik.lot_merge_enabled = 'Y'
                 AND mln.lot_number LIKE (p_lot_number)
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled,
                                                                  p_organization_id, msik.inventory_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y'
            ORDER BY lot_number, concatenated_segments;
        END IF;
      -- For bug 4306954: Added ELSIF condtion for Lot Translate case.
      -- SQL st will allow only those rows that are Lot Translate enabled.
      ELSIF p_txn_type_id = inv_globals.G_TYPE_INV_LOT_TRANSLATE THEN -- for Lot Translate
      OPEN x_lot_num_lov FOR    -- Lot Translate 84
             SELECT   mln.lot_number lot_number
                    , mln.inventory_item_id
                    , msik.concatenated_segments concatenated_segments
                    , msik.description
                    , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                    , mms.status_code
                    , mms.status_id
                 FROM mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms
                WHERE mms.status_id = msik.default_lot_status_id
                  AND msik.default_lot_status_id IS NOT NULL
                  AND mln.organization_id = p_organization_id
                  AND mln.organization_id = msik.organization_id
                  AND mln.inventory_item_id = msik.inventory_item_id
                  AND msik.lot_control_code = 2
                  AND mln.inventory_item_id LIKE l_inventory_item_id
                  AND mln.lot_number LIKE (p_lot_number)
                  AND msik.lot_translate_enabled = 'Y'
                  AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled,
                                                                   p_organization_id, msik.inventory_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y'
             UNION ALL
             SELECT   mln.lot_number LN
                    , mln.inventory_item_id
                    , msik.concatenated_segments cs
                    , msik.description
                    , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                    , NULL status_code
                    , msik.default_lot_status_id -- Bug#2267947
                 FROM mtl_lot_numbers mln, mtl_system_items_kfv msik
                WHERE msik.default_lot_status_id IS NULL -- Bug#2267947
                  AND mln.organization_id = p_organization_id
                  AND mln.organization_id = msik.organization_id
                  AND mln.inventory_item_id = msik.inventory_item_id
                  AND msik.lot_control_code = 2
                  AND mln.inventory_item_id LIKE l_inventory_item_id
                  AND mln.lot_number LIKE (p_lot_number)
                  AND msik.lot_translate_enabled = 'Y'
             ORDER BY lot_number, concatenated_segments;
      ELSE
        OPEN x_lot_num_lov FOR
          SELECT   mln.lot_number lot_number
                 , mln.inventory_item_id
                 , msik.concatenated_segments concatenated_segments
                 , msik.description
                 , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                 , mms.status_code
                 , mms.status_id
              FROM mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms
             WHERE mms.status_id = msik.default_lot_status_id -- Bug#2267947
               AND msik.default_lot_status_id IS NOT NULL -- Bug#2267947
               AND mln.organization_id = p_organization_id
               AND mln.organization_id = msik.organization_id
               AND mln.inventory_item_id = msik.inventory_item_id
               AND msik.lot_control_code = 2
               AND mln.inventory_item_id LIKE l_inventory_item_id
               AND mln.lot_number LIKE (p_lot_number)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled, p_organization_id, msik.inventory_item_id,
                                                                p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y'
          UNION ALL
          SELECT   mln.lot_number LN
                 , mln.inventory_item_id
                 , msik.concatenated_segments cs
                 , msik.description
                 , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                 , NULL status_code
                 , msik.default_lot_status_id -- Bug#2267947
              FROM mtl_lot_numbers mln, mtl_system_items_kfv msik
             WHERE msik.default_lot_status_id IS NULL -- Bug#2267947
               AND mln.organization_id = p_organization_id
               AND mln.organization_id = msik.organization_id
               AND mln.inventory_item_id = msik.inventory_item_id
               AND msik.lot_control_code = 2
               AND mln.inventory_item_id LIKE l_inventory_item_id
               AND mln.lot_number LIKE (p_lot_number)
          ORDER BY lot_number, concatenated_segments;
      END IF;
    END IF;
  END get_item_lot_lov;

  --      Name: GET_ITEM_LOT_LOV, overloaded with Lot Status ID
  --
  --      Input parameters:
  --       p_wms_installed     which restricts LOV SQL to wms installed
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_txn_type_id       which restricts LOV SQL to txn type
  --       p_inventory_item_id which restricts LOV SQL to inventory item
  --       p_lot_number        which restricts LOV SQL to the user input text
  --       p_project_id        which restricts LOV SQL to project
  --       p_task_id           which restricts LOV SQL to task
  --	   p_status_id	       which restricts LOV SQL to lot_status
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --
  --

  PROCEDURE get_item_lot_lov(
	x_lot_num_lov OUT NOCOPY t_genref
	  , p_wms_installed IN VARCHAR2
	  , p_organization_id IN NUMBER
	  , p_txn_type_id IN NUMBER
	  , p_inventory_item_id IN VARCHAR2
	  , p_lot_number IN VARCHAR2
	  , p_project_id IN NUMBER
	  , p_task_id IN NUMBER
	  , p_status_id IN NUMBER) IS

    l_inventory_item_id VARCHAR2(100);
    l_status_id		VARCHAR2(100);
    l_allow_different_status NUMBER := 0;
  BEGIN
    IF p_inventory_item_id IS NULL THEN
      l_inventory_item_id  := '%';
    ELSE
      l_inventory_item_id  := p_inventory_item_id;
    END IF;

    -- Fetch the all_different_Status from MTL_PARAMETER for the current organization and restrict
    -- the lot_status only if the parameter is set to 1.
    SELECT allow_different_status INTO l_allow_different_status FROM mtl_parameters WHERE organization_id = p_organization_id;

    IF p_status_id IS NOT NULL AND p_status_id <> 0
	AND NVL(FND_PROFILE.VALUE('INV_MATERIAL_STATUS'),2) = 1 -- IF INV: Material Status Support is set to Yes
	AND l_allow_different_status = 1 THEN -- If Allow Different Lot status is set to 1
	l_status_id := p_status_id;
    ELSE
	l_status_id := '%';
    END IF;

    IF p_txn_type_id = inv_globals.g_type_inv_lot_split -- Lot Split (82)
                                                        THEN
      OPEN x_lot_num_lov FOR
        SELECT   mln.lot_number lot_number
               , mln.inventory_item_id
               , msik.concatenated_segments concatenated_segments
               , msik.description
               , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
               , mms.status_code status_code
               , mms.status_id
            FROM mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms
           WHERE mms.status_id = msik.default_lot_status_id -- Bug#2267947
             AND msik.default_lot_status_id IS NOT NULL -- Bug#2267947
             AND mln.organization_id = p_organization_id
             AND mln.organization_id = msik.organization_id
             AND mln.inventory_item_id = msik.inventory_item_id
             AND mln.inventory_item_id LIKE l_inventory_item_id
             AND msik.lot_split_enabled = 'Y'
             AND mln.lot_number LIKE (p_lot_number)
             AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled, p_organization_id, msik.inventory_item_id, NULL, NULL, mln.lot_number, NULL, 'O') = 'Y'
        UNION ALL
        SELECT   mln.lot_number lot_number
               , mln.inventory_item_id
               , msik.concatenated_segments concatenated_segments
               , msik.description
               , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
               , NULL status_code
               , msik.default_lot_status_id -- Bug#2267947
            FROM mtl_lot_numbers mln, mtl_system_items_kfv msik
           WHERE msik.default_lot_status_id IS NULL -- Bug#2267947
             AND mln.organization_id = p_organization_id
             AND mln.organization_id = msik.organization_id
             AND mln.inventory_item_id = msik.inventory_item_id
             AND mln.inventory_item_id LIKE l_inventory_item_id
             AND msik.lot_split_enabled = 'Y'
             AND mln.lot_number LIKE (p_lot_number)
        ORDER BY lot_number, concatenated_segments;
    ELSE
      IF p_txn_type_id = inv_globals.g_type_inv_lot_merge -- Lot Merge 83
                                                          THEN
        IF (p_project_id IS NOT NULL) THEN
          OPEN x_lot_num_lov FOR
            SELECT DISTINCT moq.lot_number
                          , moq.inventory_item_id
                          , msik.concatenated_segments concatenated_segments
                          , msik.description
                          , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                          , mms.status_code
                          , mms.status_id
                       FROM mtl_onhand_quantities_detail moq, mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms, mtl_item_locations mil
                      WHERE moq.organization_id = p_organization_id
                        AND moq.lot_number IS NOT NULL
                        AND moq.organization_id = mil.organization_id
                        AND moq.organization_id = mln.organization_id
                        AND moq.organization_id = msik.organization_id
                        AND mil.segment19 = p_project_id
                        AND (mil.segment20 = p_task_id
                             OR (mil.segment20 IS NULL
                                 AND p_task_id IS NULL
                                )
                            )
                        AND mln.lot_number = moq.lot_number
                        AND mms.status_id = msik.default_lot_status_id -- Bug#2267947
                        AND msik.default_lot_status_id IS NOT NULL -- Bug#2267947
                        AND mln.inventory_item_id = msik.inventory_item_id
                        AND mln.inventory_item_id LIKE l_inventory_item_id
                        AND msik.lot_merge_enabled = 'Y'
                        AND mln.lot_number LIKE (p_lot_number)
			AND mln.status_id LIKE (l_status_id) -- restrict to lot_status
                        AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled, p_organization_id, msik.inventory_item_id, NULL, NULL, mln.lot_number, NULL, 'O') =
                                                                                                                                                                                                                                                      'Y'
            UNION ALL
            SELECT DISTINCT moq.lot_number
                          , moq.inventory_item_id
                          , msik.concatenated_segments concatenated_segments
                          , msik.description
                          , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                          , NULL status_code
                          , msik.default_lot_status_id -- Bug#2267947
                       FROM mtl_onhand_quantities_detail moq, mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms, mtl_item_locations mil
                      WHERE moq.organization_id = p_organization_id
                        AND moq.lot_number IS NOT NULL
                        AND moq.organization_id = mil.organization_id
                        AND moq.organization_id = mln.organization_id
                        AND moq.organization_id = msik.organization_id
                        AND mil.segment19 = p_project_id
                        AND (mil.segment20 = p_task_id
                             OR (mil.segment20 IS NULL
                                 AND p_task_id IS NULL
                                )
                            )
                        AND mln.lot_number = moq.lot_number
                        AND msik.default_lot_status_id IS NULL -- Bug#2267947
                        AND mln.inventory_item_id = msik.inventory_item_id
                        AND mln.inventory_item_id LIKE l_inventory_item_id
                        AND msik.lot_merge_enabled = 'Y'
                        AND mln.lot_number LIKE (p_lot_number)
			AND mln.status_id LIKE (l_status_id) -- restrict to lot_status
                        AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled, p_organization_id, msik.inventory_item_id, NULL, NULL, mln.lot_number, NULL, 'O') =
                                                                                                                                                                                                                                                      'Y'
                   ORDER BY 1, concatenated_segments;
        ELSE
          OPEN x_lot_num_lov FOR
            SELECT   mln.lot_number lot_number
                   , mln.inventory_item_id
                   , msik.concatenated_segments concatenated_segments
                   , msik.description
                   , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                   , mms.status_code
                   , mms.status_id
                FROM mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms
               WHERE mms.status_id = msik.default_lot_status_id -- Bug#2267947
                 AND msik.default_lot_status_id IS NOT NULL -- Bug#2267947
                 AND mln.organization_id = p_organization_id
                 AND mln.organization_id = msik.organization_id
                 AND mln.inventory_item_id = msik.inventory_item_id
                 AND mln.inventory_item_id LIKE l_inventory_item_id
                 AND msik.lot_merge_enabled = 'Y'
                 AND mln.lot_number LIKE (p_lot_number)
		 AND mln.status_id LIKE (l_status_id) -- restrict to lot_status
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled, p_organization_id, msik.inventory_item_id, NULL, NULL, mln.lot_number, NULL, 'O') = 'Y'
            UNION ALL
            SELECT   mln.lot_number lot_number
                   , mln.inventory_item_id
                   , msik.concatenated_segments concatenated_segments
                   , msik.description
                   , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                   , (select status_code from mtl_material_statuses_vl where status_id = mln.status_id) status_code
                   , mln.status_id -- Bug#2347381
                FROM mtl_lot_numbers mln, mtl_system_items_kfv msik
               WHERE msik.default_lot_status_id IS NULL -- Bug#2267947
                 AND mln.organization_id = p_organization_id
                 AND mln.organization_id = msik.organization_id
                 AND mln.inventory_item_id = msik.inventory_item_id
                 AND mln.inventory_item_id LIKE l_inventory_item_id
                 AND msik.lot_merge_enabled = 'Y'
                 AND mln.lot_number LIKE (p_lot_number)
		 AND mln.status_id LIKE (l_status_id) -- restrict to lot_status
                 AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled, p_organization_id, msik.inventory_item_id, NULL, NULL, mln.lot_number, NULL, 'O') = 'Y'
            ORDER BY lot_number, concatenated_segments;
        END IF;
      -- For bug 4306954: Added ELSIF condtion for Lot Translate case.
      -- SQL st will allow only those rows that are Lot Translate enabled.
      ELSIF p_txn_type_id = inv_globals.G_TYPE_INV_LOT_TRANSLATE THEN -- for Lot Translate
      OPEN x_lot_num_lov FOR    -- Lot Translate 84
             SELECT   mln.lot_number lot_number
                    , mln.inventory_item_id
                    , msik.concatenated_segments concatenated_segments
                    , msik.description
                    , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                    , mms.status_code
                    , mms.status_id
                 FROM mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms
                WHERE mms.status_id = msik.default_lot_status_id
                  AND msik.default_lot_status_id IS NOT NULL
                  AND mln.organization_id = p_organization_id
                  AND mln.organization_id = msik.organization_id
                  AND mln.inventory_item_id = msik.inventory_item_id
                  AND msik.lot_control_code = 2
                  AND mln.inventory_item_id LIKE l_inventory_item_id
                  AND mln.lot_number LIKE (p_lot_number)
                  AND msik.lot_translate_enabled = 'Y'
                  AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled, p_organization_id, msik.inventory_item_id, NULL, NULL, mln.lot_number, NULL, 'O') = 'Y'
             UNION ALL
             SELECT   mln.lot_number LN
                    , mln.inventory_item_id
                    , msik.concatenated_segments cs
                    , msik.description
                    , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                    , NULL status_code
                    , msik.default_lot_status_id -- Bug#2267947
                 FROM mtl_lot_numbers mln, mtl_system_items_kfv msik
                WHERE msik.default_lot_status_id IS NULL -- Bug#2267947
                  AND mln.organization_id = p_organization_id
                  AND mln.organization_id = msik.organization_id
                  AND mln.inventory_item_id = msik.inventory_item_id
                  AND msik.lot_control_code = 2
                  AND mln.inventory_item_id LIKE l_inventory_item_id
                  AND mln.lot_number LIKE (p_lot_number)
                  AND msik.lot_translate_enabled = 'Y'
             ORDER BY lot_number, concatenated_segments;
      ELSE
        OPEN x_lot_num_lov FOR
          SELECT   mln.lot_number lot_number
                 , mln.inventory_item_id
                 , msik.concatenated_segments concatenated_segments
                 , msik.description
                 , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                 , mms.status_code
                 , mms.status_id
              FROM mtl_lot_numbers mln, mtl_system_items_kfv msik, mtl_material_statuses_vl mms
             WHERE mms.status_id = msik.default_lot_status_id -- Bug#2267947
               AND msik.default_lot_status_id IS NOT NULL -- Bug#2267947
               AND mln.organization_id = p_organization_id
               AND mln.organization_id = msik.organization_id
               AND mln.inventory_item_id = msik.inventory_item_id
               AND msik.lot_control_code = 2
               AND mln.inventory_item_id LIKE l_inventory_item_id
               AND mln.lot_number LIKE (p_lot_number)
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_txn_type_id, msik.lot_status_enabled, msik.serial_status_enabled, p_organization_id, msik.inventory_item_id, NULL, NULL, mln.lot_number, NULL, 'O') = 'Y'
          UNION ALL
          SELECT   mln.lot_number LN
                 , mln.inventory_item_id
                 , msik.concatenated_segments cs
                 , msik.description
                 , TO_CHAR(mln.expiration_date, 'YYYY-MM-DD')
                 , NULL status_code
                 , msik.default_lot_status_id -- Bug#2267947
              FROM mtl_lot_numbers mln, mtl_system_items_kfv msik
             WHERE msik.default_lot_status_id IS NULL -- Bug#2267947
               AND mln.organization_id = p_organization_id
               AND mln.organization_id = msik.organization_id
               AND mln.inventory_item_id = msik.inventory_item_id
               AND msik.lot_control_code = 2
               AND mln.inventory_item_id LIKE l_inventory_item_id
               AND mln.lot_number LIKE (p_lot_number)
          ORDER BY lot_number, concatenated_segments;
      END IF;
    END IF;
  END get_item_lot_lov;

  -- modified by manu gupta 031601 per request to use concat segs everywhere
  PROCEDURE get_account_alias(x_accounts_info OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_description IN VARCHAR2) IS
  BEGIN
    OPEN x_accounts_info FOR
      SELECT   distribution_account
             , disposition_id
             , concatenated_segments
          FROM mtl_generic_dispositions_kfv
         WHERE organization_id = p_organization_id
           AND ((concatenated_segments LIKE ('%'|| p_description))
                OR (concatenated_segments IS NULL
                    AND p_description IS NULL
                   )
                OR (concatenated_segments IS NULL
                    AND p_description = '%'
                   )
               )
           AND enabled_flag = 'Y'
           AND NVL(effective_date, SYSDATE - 1) <= SYSDATE
           AND NVL(disable_date, SYSDATE + 1) > SYSDATE
      ORDER BY concatenated_segments;
  END get_account_alias;

  PROCEDURE get_accounts(x_accounts OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2) IS
  BEGIN
    OPEN x_accounts FOR
      SELECT   a.code_combination_id
             , a.concatenated_segments
             , a.chart_of_accounts_id
          FROM gl_code_combinations_kfv a, org_organization_definitions b
         WHERE b.organization_id = p_organization_id
           AND a.chart_of_accounts_id = b.chart_of_accounts_id
           AND a.concatenated_segments LIKE (p_concatenated_segments)
           AND a.enabled_flag = 'Y'
           AND NVL(a.start_date_active, SYSDATE - 1) <= SYSDATE
         --AND NVL(a.end_date_active, SYSDATE + 1) > SYSDATE --Bug4913515
           AND a.SUMMARY_FLAG in ('N') -- Bug 3792738
           AND a.DETAIL_POSTING_ALLOWED NOT IN ('N') -- Bug 3792738
      ORDER BY a.concatenated_segments;
  END get_accounts;

  --
  -- GET_MO_ACCOUNTS
  --
  PROCEDURE get_mo_accounts(x_accounts OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_moheader_id IN NUMBER, p_concatenated_segments IN VARCHAR2) IS
  BEGIN
    OPEN x_accounts FOR
--Bug#2963407: DISTINCT added to display distinct account segments.
-- If a MO Issue is created with same Destination a/c for all MO Lines,
-- and in MSCA QUERY MO Page, Account LOV shows multiple times the same
-- a/c segments which is incorrect. Hence this distinct.
     SELECT DISTINCT a.code_combination_id
                    , a.concatenated_segments
        FROM gl_code_combinations_kfv a, org_organization_definitions b, mtl_txn_request_lines c
       WHERE c.header_id = p_moheader_id
         AND b.organization_id = p_organization_id
         AND a.chart_of_accounts_id = b.chart_of_accounts_id
         AND c.to_account_id = a.code_combination_id
         AND a.concatenated_segments LIKE (p_concatenated_segments)
         AND a.enabled_flag = 'Y'
         AND NVL(a.start_date_active, SYSDATE - 1) <= SYSDATE
         AND NVL(a.end_date_active, SYSDATE + 1) > SYSDATE;
  END;

  PROCEDURE get_phyinv_lot_lov(
    x_lots                  OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_lot_number            IN     VARCHAR2
  , p_dynamic_entry_flag    IN     NUMBER
  , p_physical_inventory_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  ) IS
  BEGIN
     IF (p_dynamic_entry_flag = 1) THEN -- Dynamic entries are allowed
 OPEN x_lots FOR
   SELECT mln.lot_number
   , mln.description
   , mln.expiration_date
   , mmst.status_code
          FROM mtl_lot_numbers mln, mtl_material_statuses_tl mmst
   WHERE mln.organization_id = p_organization_id
   AND mln.inventory_item_id = p_inventory_item_id
   AND mln.status_id = mmst.status_id (+)
   AND mmst.language (+) = userenv('LANG')
   AND mln.lot_number LIKE (p_lot_number);
      ELSE -- Dynamic entries are not allowed
 OPEN x_lots FOR
   SELECT UNIQUE mln.lot_number
   , mln.description
   , mln.expiration_date
   , mmst.status_code
   FROM mtl_lot_numbers mln, mtl_physical_inventory_tags mpit,
   mtl_material_statuses_tl mmst
   WHERE mln.organization_id = p_organization_id
   AND mln.inventory_item_id = p_inventory_item_id
   AND mln.lot_number LIKE (p_lot_number)
   AND mln.lot_number = mpit.lot_number
   AND mln.status_id = mmst.status_id (+)
   AND mmst.language (+) = userenv('LANG')
   AND mpit.inventory_item_id = p_inventory_item_id
   AND mpit.physical_inventory_id = p_physical_inventory_id
   AND mpit.subinventory = p_subinventory_code
   AND NVL(mpit.locator_id, -99999) = NVL(p_locator_id, -99999)
   AND NVL(mpit.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
   AND NVL(mpit.void_flag, 2) = 2
   AND mpit.adjustment_id IN (SELECT adjustment_id
         FROM mtl_physical_adjustments
         WHERE physical_inventory_id = p_physical_inventory_id
         AND organization_id = p_organization_id
         AND approval_status IS NULL);
     END IF;
  END get_phyinv_lot_lov;

  PROCEDURE get_cyc_lot_lov(
    x_lots                  OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_lot_number            IN     VARCHAR2
  , p_unscheduled_entry     IN     NUMBER
  , p_cycle_count_header_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  ) IS
    l_serial_count_option          NUMBER;
    l_serial_discrepancy_option    NUMBER;
    l_container_discrepancy_option NUMBER;
    l_serial_number_control_code   NUMBER;
  BEGIN
    -- Get the cycle count discrepancy option flags
    SELECT NVL(serial_discrepancy_option, 2)
         , NVL(container_discrepancy_option, 2)
      INTO l_serial_discrepancy_option
         , l_container_discrepancy_option
      FROM mtl_cycle_count_headers
     WHERE cycle_count_header_id = p_cycle_count_header_id;

    -- Get the serial count option for the cycle count header
    SELECT NVL(serial_count_option, 1)
      INTO l_serial_count_option
      FROM mtl_cycle_count_headers
     WHERE cycle_count_header_id = p_cycle_count_header_id
       AND organization_id = p_organization_id;

    -- Get the serial number control code for the item
    SELECT NVL(serial_number_control_code, 1)
      INTO l_serial_number_control_code
      FROM mtl_system_items
     WHERE inventory_item_id = p_inventory_item_id
       AND organization_id = p_organization_id;

    IF (p_unscheduled_entry = 1) THEN -- Unscheduled entries are allowed
       OPEN x_lots FOR
  SELECT mln.lot_number
  , mln.description
  , mln.expiration_date
  , mmst.status_code
  FROM mtl_lot_numbers mln, mtl_material_statuses_tl mmst
         WHERE mln.organization_id = p_organization_id
  AND mln.inventory_item_id = p_inventory_item_id
  AND mln.status_id = mmst.status_id (+)
  AND mmst.language (+) = userenv('LANG')
  AND mln.lot_number LIKE (p_lot_number)
  -- Bug# 2770853
  -- Honor the lot material status for cycle count adjustment transaction
  AND (INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
          NULL,
          4,
          'Y',
          NULL,
          p_organization_id,
          p_inventory_item_id,
          p_subinventory_code ,
          p_locator_id ,
          mln.lot_number,
          NULL,
          'O',
	  p_parent_lpn_id) = 'Y'); /*Bug 6889528-Added p_parent_lpn_id to the call*/
     ELSE -- Unscheduled entries are not allowed
       OPEN x_lots FOR
  SELECT UNIQUE mln.lot_number
  , mln.description
  , mln.expiration_date
  , mmst.status_code
  FROM mtl_lot_numbers mln, mtl_cycle_count_entries mcce,
  mtl_material_statuses_tl mmst
  WHERE mln.organization_id = p_organization_id
  AND mln.inventory_item_id = p_inventory_item_id
  AND mln.status_id = mmst.status_id (+)
  AND mmst.language (+) = userenv('LANG')
  AND mln.lot_number LIKE (p_lot_number)
  AND mln.lot_number = mcce.lot_number
  AND mcce.inventory_item_id = p_inventory_item_id
  AND mcce.cycle_count_header_id = p_cycle_count_header_id
  -- The sub and loc have to match an existing cycle count entry
  -- OR the entry contains an LPN and
  -- container discrepancies are allowed
  -- OR the item is serial controlled, the cycle count header allows
  -- serial items and serial discrepancies are allowed
  AND ((mcce.subinventory = p_subinventory_code
        AND NVL(mcce.locator_id, -99999) = NVL(p_locator_id, -99999)
        )
       OR (mcce.parent_lpn_id IS NOT NULL
    AND l_container_discrepancy_option = 1
    )
       OR (l_serial_count_option <> 1
    AND l_serial_number_control_code NOT IN (1, 6)
    AND l_serial_discrepancy_option = 1
    )
       )
  AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
  AND mcce.entry_status_code IN (1, 3)
  -- Bug# 2770853
  -- Honor the lot material status for cycle count adjustment transaction
  AND (INV_MATERIAL_STATUS_GRP.is_status_applicable(NULL,
          NULL,
          4,
          'Y',
          NULL,
          p_organization_id,
          p_inventory_item_id,
          p_subinventory_code ,
          p_locator_id ,
          mln.lot_number,
          NULL,
          'O',
	  p_parent_lpn_id) = 'Y'); /*Bug 6889528-Added p_parent_lpn_id to the call*/
    END IF;
  END get_cyc_lot_lov;

  --      Name: GET_INSPECT_LOT_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_lpn_id            LPN that is being inspected
  --       p_lot_number   which restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --

  PROCEDURE get_inspect_lot_lov(x_lot_num_lov OUT NOCOPY t_genref,
    p_organization_id IN NUMBER,
    p_item_id IN NUMBER,
    p_lpn_id IN NUMBER,
    p_lot_number IN VARCHAR2,
    p_uom_code IN VARCHAR2 ) IS
  BEGIN
     OPEN x_lot_num_lov FOR
       SELECT a.lot_number lot_number
       , a.description description
       , a.expiration_date expiration_date
       , mmst.status_code status_code
       , SUM(Decode(Nvl(p_uom_code,uom_code),
      uom_code,
      b.quantity - Nvl(b.quantity_delivered,0),
      inv_convert.inv_um_convert(
          p_item_id
   ,NULL
   ,b.quantity - Nvl(b.quantity_delivered,0)
   ,uom_code
   ,p_uom_code
   ,NULL
   ,NULL)
      )
      ) quantity
       FROM mtl_lot_numbers a, mtl_txn_request_lines b,
       mtl_material_statuses_tl mmst
       WHERE b.organization_id = p_organization_id
       AND b.inventory_item_id = p_item_id
       AND b.lpn_id = p_lpn_id
       AND b.lot_number LIKE (p_lot_number)
       AND b.inspection_status is not null  --8987807
       AND Nvl(b.wms_process_flag,1) <> 2 --Don't pick up those that has been processed
       AND b.inventory_item_id = a.inventory_item_id
       AND b.organization_id = a.organization_id
       AND a.status_id = mmst.status_id (+)
       AND mmst.language (+) = userenv('LANG')
       AND b.lot_number = a.lot_number
       AND b.line_status = 7
       AND b.quantity - Nvl(b.quantity_delivered,0) > 0
       GROUP BY a.lot_number,a.description,a.expiration_date,mmst.status_code;
  END get_inspect_lot_lov;

-- Added p_subinventory_code and p_locator_id parameters as part of onhand status support project
  PROCEDURE get_cont_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER,
                             p_lpn_id IN NUMBER,p_lot_number IN VARCHAR2 ,p_subinventory_code IN VARCHAR2 ,p_locator_id IN NUMBER) IS
  BEGIN
    OPEN x_lot_num_lov FOR
      SELECT DISTINCT wlc.lot_number
                    , mln.description
                    , mln.expiration_date
                    , '0'
                    , '0' --wlc.quantity
                 FROM mtl_lot_numbers mln, wms_lpn_contents wlc
                WHERE wlc.organization_id = p_organization_id
                  AND wlc.inventory_item_id = p_item_id
                  AND NVL(wlc.parent_lpn_id, '0') = NVL(p_lpn_id, NVL(wlc.parent_lpn_id, '0'))
                  AND mln.inventory_item_id = wlc.inventory_item_id
                  AND mln.lot_number = wlc.lot_number
                  AND mln.organization_id = wlc.organization_id
                  AND wlc.lot_number LIKE (p_lot_number)
                  AND inv_material_status_grp.is_status_applicable('TRUE', NULL, 501, NULL, NULL, p_organization_id, p_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y';
  END get_cont_lot_lov;

-- Added p_subinventory_code and p_locator_id parameters as part of onhand status support project
  PROCEDURE get_split_cont_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER,
                                   p_lpn_id IN NUMBER,p_lot_number IN VARCHAR2,p_subinventory_code IN VARCHAR2 ,p_locator_id IN NUMBER) IS
  BEGIN
    OPEN x_lot_num_lov FOR
      SELECT DISTINCT wlc.lot_number
                    , mln.description
                    , mln.expiration_date
                    , '0'
                    , wlc.quantity
                 FROM mtl_lot_numbers mln, wms_lpn_contents wlc
                WHERE wlc.organization_id = p_organization_id
                  AND wlc.inventory_item_id = p_item_id
                  AND NVL(wlc.parent_lpn_id, '0') = NVL(p_lpn_id, NVL(wlc.parent_lpn_id, '0'))
                  AND mln.inventory_item_id = wlc.inventory_item_id
                  AND mln.lot_number = wlc.lot_number
                  AND mln.organization_id = wlc.organization_id
                  AND wlc.lot_number LIKE (p_lot_number)
                  AND (inv_material_status_grp.is_status_applicable('TRUE', NULL, 501, NULL, NULL, p_organization_id, p_item_id, p_subinventory_code, p_locator_id, mln.lot_number, NULL, 'O') = 'Y')
                  AND (inv_material_status_grp.is_status_applicable('TRUE', NULL, 500, NULL, NULL, p_organization_id, p_item_id, p_subinventory_code, p_locator_id, mln.lot_number, NULL, 'O') = 'Y');
  END get_split_cont_lot_lov;

  PROCEDURE get_all_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_lot_number IN VARCHAR2) IS
  BEGIN
    OPEN x_lot_num_lov FOR
      SELECT DISTINCT mln.lot_number
      , mln.description
      , mln.expiration_date
      , mmst.status_code
      FROM mtl_lot_numbers mln, mtl_material_statuses_tl mmst
      WHERE mln.organization_id = p_organization_id
      AND mln.status_id = mmst.status_id (+)
      AND mmst.language (+) = userenv('LANG')
      AND mln.lot_number LIKE (p_lot_number);
  END get_all_lot_lov;

  PROCEDURE get_oh_cost_group_lov(x_cost_group OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN VARCHAR2, p_subinventory_code IN VARCHAR2, p_locator_id IN VARCHAR2, p_cost_group IN VARCHAR2) IS
  BEGIN
    OPEN x_cost_group FOR
      SELECT DISTINCT ccg.cost_group
                    , ccg.cost_group_id
                    , ccg.description
                 FROM cst_cost_groups ccg, mtl_onhand_quantities_detail moq
                WHERE ccg.cost_group_id = moq.cost_group_id
                  AND ccg.cost_group_type = 3
                  AND NVL(ccg.organization_id, moq.organization_id) = moq.organization_id
                  AND NVL(moq.subinventory_code, '@') = NVL(p_subinventory_code, NVL(moq.subinventory_code, '@'))
                  AND NVL(moq.locator_id, -999) = NVL(TO_NUMBER(p_locator_id), NVL(moq.locator_id, -999))
                  AND moq.inventory_item_id = NVL(TO_NUMBER(p_inventory_item_id), moq.inventory_item_id)
                  AND moq.organization_id = p_organization_id
                  AND ccg.cost_group LIKE (p_cost_group);
  END get_oh_cost_group_lov;

  -- Call the api for checking open periods


  PROCEDURE tdatechk(p_org_id IN INTEGER, p_transaction_date IN DATE, x_period_id OUT NOCOPY INTEGER) IS
    l_open_past_period BOOLEAN := FALSE;
  BEGIN
    invttmtx.tdatechk(p_org_id, p_transaction_date, x_period_id, l_open_past_period);
  END;

  -- This is the procedure called from the LabelPage.java.
  PROCEDURE get_label_type_lov(x_source_lov OUT NOCOPY t_genref, p_wms_installed IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
  BEGIN
    IF (p_wms_installed IN ('true', 'TRUE')) THEN
      OPEN x_source_lov FOR
        SELECT   meaning
               , lookup_code
            FROM mfg_lookups
           WHERE lookup_type = 'WMS_LABEL_TYPE'
             AND lookup_code NOT IN (9)
             AND meaning LIKE (p_lookup_type)
        ORDER BY lookup_code;
    ELSE
      OPEN x_source_lov FOR
        SELECT   meaning
               , lookup_code
            FROM mfg_lookups
           WHERE lookup_type = 'WMS_LABEL_TYPE'
             AND lookup_code IN (1, 2, 6, 7, 8, 10)
             AND meaning LIKE (p_lookup_type)
        ORDER BY lookup_code;
    END IF;
  END get_label_type_lov;

  -- Added for the Label Reprint Project.
  -- A new procedure is created for this project because the procedure called from the LabelPage.java
  -- has a restriction for the "WIP Content" Label.
  PROCEDURE get_label_type_reprint_lov(x_source_lov OUT NOCOPY t_genref, p_wms_installed IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
  BEGIN
    IF (p_wms_installed IN ('true', 'TRUE')) THEN
      OPEN x_source_lov FOR
        SELECT   meaning
               , lookup_code
            FROM mfg_lookups
           WHERE lookup_type = 'WMS_LABEL_TYPE'
             AND meaning LIKE (p_lookup_type)
        ORDER BY lookup_code;
    ELSE
      OPEN x_source_lov FOR
        SELECT   meaning
               , lookup_code
            FROM mfg_lookups
           WHERE lookup_type = 'WMS_LABEL_TYPE'
             AND lookup_code IN (1, 2, 6, 7, 8, 10)
             AND meaning LIKE (p_lookup_type)
        ORDER BY lookup_code;
    END IF;
  END get_label_type_reprint_lov;

  -- Added for the Label Reprint Project.
  PROCEDURE get_businessflow_type_lov(x_source_lov OUT NOCOPY t_genref, p_wms_installed IN VARCHAR2, p_lookup_type IN VARCHAR2) IS
  BEGIN
    IF (p_wms_installed IN ('true', 'TRUE')) THEN -- WMS Enabled.
      OPEN x_source_lov FOR
        SELECT   meaning
               , lookup_code
            FROM mfg_lookups
           WHERE lookup_type = 'WMS_BUSINESS_FLOW'
             AND lookup_code NOT IN (3)
             AND meaning LIKE (p_lookup_type)
        ORDER BY lookup_code;
    ELSE -- INV Enabled.
      OPEN x_source_lov FOR
        SELECT   meaning
               , lookup_code
            FROM mfg_lookups
           WHERE lookup_type = 'WMS_BUSINESS_FLOW'
             AND lookup_code IN (1, 2, 3, 8, 9, 13, 14, 15, 17, 21, 23, 24, 26, 31, 32, 33)
             AND meaning LIKE (p_lookup_type)
        ORDER BY lookup_code;
    END IF;
  END get_businessflow_type_lov;

--      Name: GET_ALL_LABEL_TYPE_LOV
--
--      Input parameters:
--   p_wms_installed   true/false if wms is installed
--   p_all_label_str   translated string for all label types
--     p_lookup_type   partial completion on lookup type
--      Functions: This API returns all label types

PROCEDURE GET_ALL_LABEL_TYPE_LOV
  (x_source_lov  OUT  NOCOPY t_genref,
   p_wms_installed IN VARCHAR2,
   p_all_label_str IN VARCHAR2,
   p_lookup_type IN   VARCHAR2
)
IS
BEGIN
 IF ( p_wms_installed IN('true','TRUE') ) THEN
    OPEN x_source_lov FOR
  SELECT p_all_label_str meaning, 0 lookup_code
  FROM DUAL
  WHERE p_all_label_str LIKE (p_lookup_type)
  UNION ALL
  SELECT meaning, lookup_code
  FROM mfg_lookups
  WHERE lookup_type = 'WMS_LABEL_TYPE'
  AND meaning LIKE (p_lookup_type)
  ORDER BY lookup_code;
 ELSE
  OPEN x_source_lov FOR
  SELECT p_all_label_str meaning, 0 lookup_code
  FROM DUAL
  WHERE p_all_label_str LIKE (p_lookup_type)
  UNION ALL
  SELECT meaning, lookup_code
  FROM mfg_lookups
  WHERE lookup_type = 'WMS_LABEL_TYPE'
  AND lookup_code NOT IN (3,4,5,9)
  AND meaning LIKE (p_lookup_type)
  ORDER BY lookup_code;
 END IF;
END GET_ALL_LABEL_TYPE_LOV;


  PROCEDURE get_notrx_item_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_lot_number IN VARCHAR2) IS
  BEGIN
    OPEN x_lot_num_lov FOR
      SELECT mln.lot_number
      , mln.description
      , mln.expiration_date
      , mmst.status_code
      FROM mtl_lot_numbers mln, mtl_material_statuses_tl mmst
      WHERE mln.organization_id = p_organization_id
      AND mln.inventory_item_id = p_item_id
      AND mln.status_id = mmst.status_id (+)
      AND mmst.language (+) = userenv('LANG')
      AND mln.lot_number LIKE (p_lot_number);
  END get_notrx_item_lot_lov;

  PROCEDURE get_td_lot_lov(
    x_lot_num_lov         OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_lot_number          IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_lpn_id              IN     NUMBER
  , p_subinventory_code   IN     VARCHAR2
  , p_locator_id          IN     NUMBER
  , p_txn_temp_id         IN     NUMBER
  ) IS
    l_negative_rcpt_code NUMBER;
  BEGIN
    SELECT negative_inv_receipt_code
      INTO l_negative_rcpt_code
      FROM mtl_parameters
     WHERE organization_id = p_organization_id;

    IF (l_negative_rcpt_code = 1) THEN
      -- Negative inventory balances allowed

      IF (p_lpn_id IS NULL
          OR p_lpn_id = 0
         ) THEN
        OPEN x_lot_num_lov FOR
          -- In case where negative onhand inventory balances are
          -- allowed, we don't do location validation for loose items.
          SELECT DISTINCT mln.lot_number
   , mln.description
   , mln.expiration_date
   , mmst.status_code
   , mtlt.primary_quantity
   , mtlt.transaction_quantity
   FROM mtl_lot_numbers mln, mtl_transaction_lots_temp mtlt,
   mtl_material_statuses_tl mmst
   WHERE mln.organization_id = p_organization_id
   AND mln.inventory_item_id = p_item_id
   AND mln.lot_number LIKE (p_lot_number)
   AND mln.status_id = mmst.status_id (+)
   AND mmst.language (+) = userenv('LANG')
   AND mtlt.lot_number = mln.lot_number
   AND mtlt.transaction_temp_id = p_txn_temp_id
   AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y';
       ELSE --as lpn_id is not null ,hence sub and loc are not passed in is_status_applicable
        -- It however remains same for LPNs
        OPEN x_lot_num_lov FOR
          SELECT DISTINCT mln.lot_number
   , mln.description
   , mln.expiration_date
   , mmst.status_code
   , mtlt.primary_quantity
   , mtlt.transaction_quantity
   FROM mtl_lot_numbers mln,
   mtl_transaction_lots_temp mtlt, wms_lpn_contents wlc,
   mtl_material_statuses_tl mmst
   WHERE mln.organization_id = p_organization_id
   AND mln.inventory_item_id = p_item_id
   AND mln.lot_number LIKE (p_lot_number)
   AND mln.status_id = mmst.status_id (+)
   AND mmst.language (+) = userenv('LANG')
   AND exists (SELECT '1' FROM mtl_onhand_quantities_detail moq
        WHERE moq.lot_number = mln.lot_number
        AND moq.inventory_item_id = mln.inventory_item_id
        AND moq.organization_id = mln.organization_id
        AND moq.containerized_flag = 1
        AND moq.subinventory_code = NVL(p_subinventory_code, moq.subinventory_code)
        AND NVL(moq.locator_id, -1) = NVL(NVL(p_locator_id, moq.locator_id), -1))
   AND mtlt.lot_number = mln.lot_number
   AND mtlt.transaction_temp_id = p_txn_temp_id
   AND wlc.parent_lpn_id = p_lpn_id
   AND wlc.lot_number = mln.lot_number
   AND wlc.inventory_item_id = p_item_id
   AND wlc.organization_id = p_organization_id
   AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, NULL, NULL, mln.lot_number, NULL, 'O') = 'Y';
      END IF;
     ELSE
      -- Negative inventory balances not allowed

      IF (p_lpn_id IS NULL
          OR p_lpn_id = 0
         ) THEN
        OPEN x_lot_num_lov FOR
          -- In case where negative onhand inventory balances are
          -- not allowed, we do location validation for loose items.
          SELECT DISTINCT mln.lot_number
   , mln.description
   , mln.expiration_date
   , mmst.status_code
   , mtlt.primary_quantity
   , mtlt.transaction_quantity
   FROM mtl_lot_numbers mln,
   mtl_transaction_lots_temp mtlt, mtl_material_statuses_tl mmst
   WHERE mln.organization_id = p_organization_id
   AND mln.inventory_item_id = p_item_id
   AND mln.lot_number LIKE (p_lot_number)
   AND mln.status_id = mmst.status_id (+)
   AND mmst.language (+) = userenv('LANG')
   AND exists (SELECT '1' FROM mtl_onhand_quantities_detail moq
        WHERE moq.lot_number = mln.lot_number
        AND moq.inventory_item_id = mln.inventory_item_id
        AND moq.organization_id = mln.organization_id
        AND moq.containerized_flag = 2
        AND moq.subinventory_code = NVL(p_subinventory_code, moq.subinventory_code)
        AND NVL(moq.locator_id, -1) = NVL(NVL(p_locator_id, moq.locator_id), -1))
   AND mtlt.lot_number = mln.lot_number
   AND mtlt.transaction_temp_id = p_txn_temp_id
   AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y';
       ELSE
  OPEN x_lot_num_lov FOR
    SELECT DISTINCT mln.lot_number
    , mln.description
    , mln.expiration_date
    , mmst.status_code
    , mtlt.primary_quantity
    , mtlt.transaction_quantity
    FROM mtl_lot_numbers mln,
    mtl_transaction_lots_temp mtlt, wms_lpn_contents wlc,
    mtl_material_statuses_tl mmst
    WHERE mln.organization_id = p_organization_id
    AND mln.inventory_item_id = p_item_id
    AND mln.lot_number LIKE (p_lot_number)
    AND mln.status_id = mmst.status_id (+)
    AND mmst.language (+) = userenv('LANG')
    AND exists (SELECT '1' FROM mtl_onhand_quantities_detail moq
         WHERE moq.lot_number = mln.lot_number
         AND moq.inventory_item_id = mln.inventory_item_id
         AND moq.organization_id = mln.organization_id
         AND moq.containerized_flag = 1
         AND moq.subinventory_code = NVL(p_subinventory_code, moq.subinventory_code)
         AND NVL(moq.locator_id, -1) = NVL(NVL(p_locator_id, moq.locator_id), -1))
    AND mtlt.lot_number = mln.lot_number
    AND mtlt.transaction_temp_id = p_txn_temp_id
    AND wlc.parent_lpn_id = p_lpn_id
    AND wlc.lot_number = mln.lot_number
    AND wlc.inventory_item_id = p_item_id
    AND wlc.organization_id = p_organization_id
    AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, NULL, NULL, mln.lot_number, NULL, 'O') = 'Y';
      END IF;
    END IF;
  END get_td_lot_lov;

  PROCEDURE get_apl_lot_lov(
        x_lot_num_lov         OUT    NOCOPY t_genref
      , p_organization_id     IN     NUMBER
      , p_item_id             IN     NUMBER
      , p_lot_number          IN     VARCHAR2
      , p_transaction_type_id IN     NUMBER
      , p_wms_installed       IN     VARCHAR2
      , p_lpn_id              IN     NUMBER
      , p_subinventory_code   IN     VARCHAR2
      , p_locator_id          IN     NUMBER
      , p_txn_temp_id         IN     NUMBER
      , p_isLotSubtitution    IN     VARCHAR2 DEFAULT NULL --/* Bug 9448490 Lot Substitution Project */
      ) IS
        l_negative_rcpt_code NUMBER;
      BEGIN
  -- Since Negative Balance check is through APL Set-up form prameter.We would
   --not required to  check negative balance here through back-end.
    -- Vikas v1 10/04/04 start removed earlier code,also removed AND clause
    --selecting mtl_onhand_quantities_detail


          IF (p_lpn_id IS NULL
              OR p_lpn_id = 0
             ) THEN
            OPEN x_lot_num_lov FOR
              -- In case where negative onhand inventory balances are
              -- not allowed, we do location validation for loose items.
              SELECT  mln.lot_number
               , mln.description
               , mln.expiration_date
               , mmst.status_code
               , sum(mag.primary_quantity)
               , sum(mag.transaction_quantity)
               FROM mtl_lot_numbers mln,  wms_allocations_gtmp mag,
                    mtl_material_statuses_tl mmst
               WHERE mln.organization_id = p_organization_id
               AND mln.inventory_item_id = p_item_id
               AND mln.lot_number LIKE (p_lot_number)
               AND mln.status_id = mmst.status_id (+)
               AND mmst.language (+) = userenv('LANG')
               AND  mag.lot_number = mln.lot_number
               AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, p_subinventory_code , p_locator_id , mln.lot_number, NULL, 'O') = 'Y'
               GROUP BY   mln.lot_number
                        , mln.description
                        , mln.expiration_date
                        , mmst.status_code
               HAVING sum(mag.transaction_quantity) > 0;
           ELSE
              OPEN x_lot_num_lov FOR
                SELECT DISTINCT mln.lot_number
                , mln.description
                , mln.expiration_date
                , mmst.status_code
                , sum(mag.primary_quantity)
                , sum(mag.transaction_quantity)
                FROM mtl_lot_numbers mln,
                mtl_transaction_lots_temp mtlt, wms_allocations_gtmp mag,
                mtl_material_statuses_tl mmst
                WHERE mln.organization_id = p_organization_id
                AND mln.inventory_item_id = p_item_id
                AND mln.lot_number LIKE (p_lot_number)
                AND mln.status_id = mmst.status_id (+)
                AND mmst.language (+) = userenv('LANG')
                AND exists (SELECT '1' FROM mtl_onhand_quantities_detail moq
                     WHERE moq.lot_number = mln.lot_number
                     AND moq.inventory_item_id = mln.inventory_item_id
                     AND moq.organization_id = mln.organization_id
                     AND moq.containerized_flag = 1
                     AND moq.subinventory_code = NVL(p_subinventory_code, moq.subinventory_code)
                     AND NVL(moq.locator_id, -1) = NVL(NVL(p_locator_id, moq.locator_id), -1))
                --/* Bug 9448490 Lot Substitution Project */ start
                AND (
		            (p_isLotSubtitution = 'N' OR p_isLotSubtitution IS NULL)
		            OR
		            (mtlt.lot_number = mln.lot_number AND mtlt.transaction_temp_id = p_txn_temp_id AND p_isLotSubtitution = 'Y')
		                 )
                --/* Bug 9448490 Lot Substitution Project */ end
                AND mag.lot_number = mln.lot_number
                AND inv_material_status_grp.is_status_applicable(p_wms_installed, NULL, p_transaction_type_id, NULL, NULL, p_organization_id, p_item_id, NULL, NULL, mln.lot_number, NULL, 'O') = 'Y'
                GROUP BY  mln.lot_number
                        , mln.description
                        , mln.expiration_date
                        , mmst.status_code
                HAVING sum(mag.transaction_quantity) > 0;
        END IF;
  END get_apl_lot_lov;

  --"Returns"
  PROCEDURE get_return_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_org_id IN NUMBER, p_lpn_id IN NUMBER, p_item_id IN NUMBER, p_revision IN VARCHAR2, p_lot_number IN VARCHAR2) IS
  BEGIN
    OPEN x_lot_num_lov FOR
      SELECT DISTINCT mln.lot_number
                    , mln.description
                    , mln.expiration_date
                    , mstl.status_code
                 FROM mtl_lot_numbers mln, wms_lpn_contents wlpnc, mtl_material_statuses_b mstb, mtl_material_statuses_tl mstl
                WHERE wlpnc.parent_lpn_id = p_lpn_id
                  AND wlpnc.organization_id = p_org_id
                  AND wlpnc.inventory_item_id = p_item_id
                  AND ((wlpnc.revision = p_revision
                        AND p_revision IS NOT NULL
                       )
                       OR (p_revision IS NULL
                           AND wlpnc.revision IS NULL
                          )
                      )
                  AND wlpnc.source_name IN ('RETURN TO VENDOR', 'RETURN TO CUSTOMER', 'RETURN TO RECEIVING')
                  AND wlpnc.lot_number LIKE (p_lot_number)
                  AND mln.lot_number = wlpnc.lot_number
                  AND mln.organization_id = wlpnc.organization_id
                  AND mln.inventory_item_id = wlpnc.inventory_item_id
                  AND mln.status_id = mstb.status_id(+)
                  AND mstb.status_id = mstl.status_id(+)
                  AND mstl.LANGUAGE(+) = USERENV('LANG');
  END get_return_lot_lov;

  --"Returns"

  PROCEDURE get_lot_lov_for_unload(x_lot_num_lov OUT NOCOPY t_genref, p_temp_id IN NUMBER) IS
  BEGIN
    OPEN x_lot_num_lov FOR
      SELECT lot_number
           , ' '
           , ' '
           , ' '
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_temp_id;
  END get_lot_lov_for_unload;

  --      Name: GET_FORMAT_LOV
  --      Added by joabraha.
  --      Input parameters:
  --      p_label_type_id SELECTED label type.
  --      Functions: This API returns all formats for a specific label type.
  PROCEDURE get_format_lov(x_format_lov OUT NOCOPY t_genref, p_label_type_id IN NUMBER, p_format_name IN VARCHAR2) IS
  BEGIN
    OPEN x_format_lov FOR
      SELECT   label_format_id
      , label_format_name
      , Decode(label_entity_type,1,'Label Set', 'Format')
          FROM wms_label_formats
         WHERE document_id = p_label_type_id
           AND NVL(format_disable_date, SYSDATE + 1) > SYSDATE  --Bug #3452076
           AND label_format_name like (p_format_name)
      ORDER BY label_format_name;
  END get_format_lov;

  --      Name: GET_USER_PRINTERS_LOV
  --      Added by joabraha for jsheu.
  --      Input parameters:
  --      p_printer_name  partial completion on printer_name
  --      Functions: This API returns all printers

  PROCEDURE get_user_printers_lov(x_printer_lov OUT NOCOPY t_genref, p_printer_name IN VARCHAR2) IS
  BEGIN
    OPEN x_printer_lov FOR
      SELECT   printer_name
             , printer_type
          FROM fnd_printer
         WHERE printer_name LIKE (p_printer_name)
      ORDER BY printer_name;
  END get_user_printers_lov;

  PROCEDURE get_flow_schedule_lov(x_flow_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_from_schedule_number IN VARCHAR2, p_schedule_number IN VARCHAR2) IS
  BEGIN
    OPEN x_flow_lov FOR
      SELECT schedule_number
           , organization_id
        FROM wip_flow_schedules
       WHERE organization_id = NVL(p_organization_id, organization_id)
         AND schedule_number >= NVL(p_from_schedule_number, 0)
         AND schedule_number LIKE (p_schedule_number);
  END get_flow_schedule_lov;

  PROCEDURE get_lot_control_from_org(x_lot_control_code OUT NOCOPY NUMBER, x_from_org_id OUT NOCOPY NUMBER, p_organization_id IN NUMBER, p_shipment_header_id IN NUMBER, p_item_id IN NUMBER) IS
  BEGIN
    SELECT msik.lot_control_code
         , rsl.from_organization_id
      INTO x_lot_control_code
         , x_from_org_id
      FROM mtl_system_items_kfv msik, rcv_shipment_lines rsl
     WHERE msik.inventory_item_id = p_item_id
       AND rsl.shipment_header_id = p_shipment_header_id
       AND rsl.to_organization_id = p_organization_id
       AND rsl.from_organization_id = msik.organization_id
       AND ROWNUM < 2;
  EXCEPTION
    WHEN OTHERS THEN
      x_lot_control_code  := 1;
  END get_lot_control_from_org;

  -- Added p_subinventory_code and p_locator_id parameters as part of onhand status support project
PROCEDURE get_item_load_lot_lov
  (x_lot_num_lov          OUT NOCOPY t_genref     ,
   p_organization_id      IN  NUMBER              ,
   p_item_id              IN  NUMBER              ,
   p_lpn_id               IN  NUMBER              ,
   p_lot_number           IN  VARCHAR2            ,
   p_subinventory_code    IN  VARCHAR2 ,
   p_locator_id           IN  NUMBER)
  IS

BEGIN

   OPEN x_lot_num_lov FOR
     SELECT DISTINCT mln.lot_number
     , mln.description
     , mln.expiration_date
     , mmst.status_code
     FROM mtl_lot_numbers mln, wms_lpn_contents wlc,
     mtl_material_statuses_tl mmst
     WHERE wlc.organization_id = p_organization_id
     AND wlc.inventory_item_id = p_item_id
     AND wlc.parent_lpn_id = p_lpn_id
     AND mln.inventory_item_id = wlc.inventory_item_id
     AND mln.lot_number = wlc.lot_number
     AND mln.organization_id = wlc.organization_id
     AND mln.status_id = mmst.status_id (+)
     AND mmst.language (+) = userenv('LANG')
     AND wlc.lot_number LIKE (p_lot_number)
     AND inv_material_status_grp.is_status_applicable('TRUE',
            NULL,
            INV_GLOBALS.G_TYPE_CONTAINER_UNPACK,
            NULL,
            NULL,
            p_organization_id,
            p_item_id,
            p_subinventory_code,
            p_locator_id,
            mln.lot_number,
            NULL,
            'O') = 'Y'
     ORDER BY mln.lot_number;

END get_item_load_lot_lov;


FUNCTION validate_account_segments(
                                    p_segments VARCHAR2,
                                    p_data_set NUMBER
                                  ) RETURN VARCHAR2 IS

  ftype                      fnd_flex_key_api.flexfield_type;
  stype                      fnd_flex_key_api.structure_type;
  l_return_status            BOOLEAN;

  l_values_or_ids   CONSTANT VARCHAR2(1)  := 'V';
  l_flex_code       CONSTANT VARCHAR2(10) := 'GL#';
  l_appl_short_name CONSTANT VARCHAR2(10) := 'SQLGL';
  l_operation       CONSTANT VARCHAR2(20) := 'FIND_COMBINATION';
  l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

BEGIN

  fnd_flex_key_api.set_session_mode('seed_data');

  IF (l_debug=1) THEN
    inv_mobile_helper_functions.tracelog
     (p_err_msg   =>  ' inputs '||p_segments||' :: '||p_data_set,
      p_module    =>  'INV_INV_LOVS',
      p_level     =>  1);
  END IF;

  ftype := fnd_flex_key_api.find_flexfield(
                            appl_short_name => l_appl_short_name,
                            flex_code       => l_flex_code
                                         );
  IF (l_debug=1) THEN
    inv_mobile_helper_functions.tracelog
    (p_err_msg   =>  'Got flex definition',
     p_module    =>  'INV_INV_LOVS',
     p_level     =>  1);

    inv_mobile_helper_functions.tracelog
    (p_err_msg   =>  'Flex Title :'||ftype.flex_title||'description :'||ftype.description,
     p_module    =>  'INV_INV_LOVS',
     p_level     =>  1);
  END IF;



   l_return_status := FND_FLEX_KEYVAL.VALIDATE_SEGS(
                      OPERATION        => l_operation,
                      APPL_SHORT_NAME  => l_appl_short_name,
                      KEY_FLEX_CODE    => l_flex_code,
                      STRUCTURE_NUMBER => p_data_set,
                      CONCAT_SEGMENTS  => p_segments,
                      VALUES_OR_IDS    => l_values_or_ids
                      );

  IF l_return_status THEN

   IF (l_debug=1) THEN

    inv_mobile_helper_functions.tracelog
     (p_err_msg   =>  'Returned true after flex validation',
      p_module    =>  'INV_INV_LOVS',
      p_level     =>  1);

   END IF;

     RETURN 'TRUE';

  ELSE

   IF (l_debug=1) THEN

     inv_mobile_helper_functions.tracelog
     (p_err_msg   =>  'Returned false after flex validation',
      p_module    =>  'INV_INV_LOVS',
      p_level     =>  1);

   END IF;

     RETURN 'FALSE';
  END IF;

END validate_account_segments;

--added for lpn status project to handle lot in lpn and loose
procedure get_from_onstatus_lot_lov(x_lot_num_lov OUT NOCOPY t_genref,
                                       p_organization_id IN NUMBER,
                                       p_lpn VARCHAR2 ,
                                       p_item_id IN NUMBER,
                                       p_lot_number IN VARCHAR2) IS
BEGIN
IF(p_lpn IS NULL) then
   OPEN x_lot_num_lov FOR
       SELECT mln.lot_number
       , mln.description
       , mln.expiration_date
       , mmst.status_code
       FROM mtl_lot_numbers mln, mtl_material_statuses_tl mmst
       WHERE mln.organization_id = p_organization_id
       AND mln.inventory_item_id = p_item_id
       AND mln.status_id = mmst.status_id (+)
       AND mmst.language (+) = userenv('LANG')
       AND mln.lot_number LIKE (p_lot_number)
       /* Bug 8566866 */
       AND EXISTS ( select 1 from mtl_onhand_quantities_detail moqd
                    where moqd.inventory_item_id = mln.inventory_item_id
                    AND moqd.organization_id   = mln.organization_id
                    AND moqd.lot_number        = mln.lot_number
                    AND moqd.lpn_id           IS NULL
                  )
       /* End Bug 8566866 */
       ORDER BY mln.lot_number;
 ELSE
   OPEN x_lot_num_lov FOR
       SELECT mln.lot_number
       , mln.description
       , mln.expiration_date
       , mmst.status_code
       FROM mtl_lot_numbers mln, mtl_material_statuses_tl mmst , wms_license_plate_numbers wlpn , wms_lpn_contents wlc
       WHERE wlpn.license_plate_number = p_lpn
       AND   wlc.parent_lpn_id = wlpn.lpn_id
       AND   mln.lot_number = wlc.lot_number
       AND mln.organization_id = p_organization_id
       AND mln.inventory_item_id = p_item_id
       AND mln.status_id = mmst.status_id (+)
       AND mmst.language (+) = userenv('LANG')
       AND mln.lot_number LIKE (p_lot_number)
       ORDER BY mln.lot_number;
 END IF;
END get_from_onstatus_lot_lov;

 PROCEDURE get_to_onstatus_lot_lov(x_lot_num_lov OUT NOCOPY t_genref,
                                   p_organization_id IN NUMBER,
                                   p_lpn varchar2,
                                   p_item_id IN NUMBER,
                                   p_from_lot_number IN VARCHAR2,
                                   p_lot_number IN VARCHAR2) IS
  BEGIN
  IF(p_lpn is null)then
    OPEN x_lot_num_lov FOR
       SELECT mln.lot_number
       , mln.description
       , mln.expiration_date
       , mmst.status_code
       FROM mtl_lot_numbers mln, mtl_material_statuses_tl mmst
       WHERE mln.organization_id = p_organization_id
       AND mln.inventory_item_id = p_item_id
       AND mln.status_id = mmst.status_id (+)
       AND mmst.language (+) = userenv('LANG')
       AND mln.lot_number >= p_from_lot_number
       AND mln.lot_number LIKE (p_lot_number)
       /* Bug 8566866 */
       AND EXISTS ( select 1 from mtl_onhand_quantities_detail moqd
                    where moqd.inventory_item_id = mln.inventory_item_id
                    AND moqd.organization_id   = mln.organization_id
                    AND moqd.lot_number        = mln.lot_number
                    AND moqd.lpn_id           IS NULL
                  )
       /* End Bug 8566866 */
       ORDER BY mln.lot_number;


   ELSE
     OPEN x_lot_num_lov FOR
       SELECT mln.lot_number
       , mln.description
       , mln.expiration_date
       , mmst.status_code
       FROM mtl_lot_numbers mln, mtl_material_statuses_tl mmst , wms_license_plate_numbers wlpn , wms_lpn_contents wlc
       WHERE wlpn.license_plate_number = p_lpn
       AND   wlc.parent_lpn_id = wlpn.lpn_id
       AND   mln.lot_number = wlc.lot_number
       AND  mln.organization_id = p_organization_id
       AND mln.inventory_item_id = p_item_id
       AND mln.status_id = mmst.status_id (+)
       AND mmst.language (+) = userenv('LANG')
       AND mln.lot_number >= p_from_lot_number
       AND mln.lot_number LIKE (p_lot_number)
       ORDER BY mln.lot_number;
 END IF;
END get_to_onstatus_lot_lov;

  --end of lpn status project


END inv_inv_lovs;

/
