--------------------------------------------------------
--  DDL for Package Body INV_KANBAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_KANBAN_PKG" AS
  /* $Header: INVKBAPB.pls 120.4 2006/12/12 11:15:08 pannapra noship $ */

  --This package is created to finish the kanban mobile transactions
  -- including replenishment and inquiry

  /**
   *   Globals constant holding the package name.
   **/
  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_REPLENISH_COUNT_PVT';
  g_version_printed BOOLEAN := FALSE;
  g_user_name fnd_user.user_name%TYPE := fnd_global.user_name;

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
      inv_log_util.trace('$Header: INVKBAPB.pls 120.4 2006/12/12 11:15:08 pannapra noship $', g_pkg_name|| '.' || p_module, 1);
      g_version_printed := TRUE;
    END IF;
    inv_log_util.TRACE(g_user_name || ':  ' || p_message, g_pkg_name || '.' || p_module, p_level);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END print_debug;

  FUNCTION getlocatorname(org_id IN NUMBER, locator_id IN NUMBER)
    RETURN VARCHAR2 IS
    locator_name VARCHAR2(60);
  BEGIN
    IF locator_id IS NULL THEN
      RETURN (NULL);
    ELSE
      SELECT inv_project.get_locsegs(locator_id, org_id)
        INTO locator_name
        FROM mtl_item_locations
       WHERE inventory_location_id = locator_id
         AND organization_id = org_id;

      RETURN (locator_name);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END getlocatorname;

  FUNCTION getorgcode(p_org_id IN NUMBER)
    RETURN VARCHAR2 IS
    org_code VARCHAR2(3);
  BEGIN
    IF p_org_id IS NULL THEN
      RETURN (NULL);
    ELSE
      SELECT organization_code
        INTO org_code
        FROM mtl_parameters
       WHERE organization_id = p_org_id;

      RETURN (org_code);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END getorgcode;

  FUNCTION getsuppliersitename(supplier_site_id IN NUMBER)
    RETURN VARCHAR2 IS
    supplier_site_name VARCHAR2(60);
  BEGIN
    IF supplier_site_id IS NULL THEN
      RETURN NULL;
    ELSE
      SELECT vendor_site_code
        INTO supplier_site_name
        FROM po_vendor_sites_all
       WHERE vendor_site_id = supplier_site_id;

      RETURN supplier_site_name;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END getsuppliersitename;

  FUNCTION getdocmentnumber(v_document_header_id IN NUMBER, v_document_type_id IN NUMBER, v_document_detail_id IN NUMBER)
    RETURN VARCHAR2 IS
    v_document_header VARCHAR2(1000);
  BEGIN
    IF v_document_type_id = 1 THEN  /*  PO */
      SELECT h.segment1
        INTO v_document_header
        FROM po_distributions_all d, po_headers_all h
       WHERE d.po_distribution_id = v_document_detail_id
         AND h.po_header_id = d.po_header_id;
    ELSIF v_document_type_id = 2 THEN  /* Blanket Release */
      SELECT h.segment1
        INTO v_document_header
        FROM po_distributions_all d, po_headers_all h
       WHERE d.po_distribution_id = v_document_detail_id
         AND h.po_header_id = d.po_header_id;
    ELSIF v_document_type_id = 3 THEN  /* Internal Req */
      SELECT h.segment1
        INTO v_document_header
        FROM po_requisition_headers_all h, po_requisition_lines_all l
       WHERE l.requisition_line_id = v_document_detail_id
         AND h.requisition_header_id = l.requisition_header_id;
    ELSIF v_document_type_id = 4 THEN  /* Move Order */
      SELECT h.request_number
        INTO v_document_header
        FROM mtl_txn_request_headers h, mtl_txn_request_lines l
       WHERE l.line_id = v_document_detail_id
         AND h.header_id = l.header_id;
    ELSIF v_document_type_id = 5 THEN  /* Wip Discrete Job */
      SELECT h.wip_entity_name
        INTO v_document_header
        FROM wip_entities h
       WHERE h.wip_entity_id = v_document_header_id;
    ELSIF v_document_type_id = 6 THEN  /* Rep Schedule */
      SELECT h.wip_entity_name
        INTO v_document_header
        FROM wip_entities h
       WHERE h.wip_entity_id = v_document_header_id;
    ELSIF v_document_type_id = 7 THEN  /* Flow Schedule */
      SELECT h.wip_entity_name
        INTO v_document_header
        FROM wip_entities h
	WHERE h.wip_entity_id = v_document_header_id;
     ELSIF v_document_type_id = 8 THEN  /* Lot based Job*/
      SELECT h.wip_entity_name
        INTO v_document_header
        FROM wip_entities h
       WHERE h.wip_entity_id = v_document_header_id;
    END IF;

    RETURN v_document_header;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RETURN NULL;
  END getdocmentnumber;

  FUNCTION status_check(from_status_id IN NUMBER, to_status IN NUMBER)
    RETURN NUMBER IS
    x    NUMBER;
    col1 VARCHAR2(40) := ('2222111');
    col2 VARCHAR2(40) := ('1222111');
    col3 VARCHAR2(40) := ('1122111');
    col4 VARCHAR2(40) := ('1211211');
    col5 VARCHAR2(40) := ('1211222');
    col6 VARCHAR2(40) := ('1211121');
    col7 VARCHAR2(40) := ('1211111');
  BEGIN
    IF from_status_id = 1 THEN
      x  := SUBSTR(col1, to_status, 1);
    ELSIF from_status_id = 2 THEN
      x  := SUBSTR(col2, to_status, 1);
    ELSIF from_status_id = 3 THEN
      x  := SUBSTR(col3, to_status, 1);
    ELSIF from_status_id = 4 THEN
      x  := SUBSTR(col4, to_status, 1);
    ELSIF from_status_id = 5 THEN
      x  := SUBSTR(col5, to_status, 1);
    ELSIF from_status_id = 6 THEN
       x  := SUBSTR(col6, to_status, 1);
    ELSIF from_status_id = 7 THEN
      x  := SUBSTR(col7, to_status, 1);
    END IF;

    RETURN (x);
  END status_check;

  PROCEDURE replenishcard
    (x_message OUT NOCOPY VARCHAR2,
     x_status OUT NOCOPY VARCHAR2,
     p_org_id IN NUMBER,
     p_kanban_card_number IN VARCHAR2,
     p_lot_item_id        IN NUMBER  ,
     p_lot_number         IN VARCHAR2 ,
     p_lot_item_revision   IN VARCHAR2 ,
     p_lot_subinventory_code   IN VARCHAR2,
     p_lot_location_id         IN NUMBER ,
     p_lot_quantity            IN NUMBER,
     p_replenish_quantity      IN NUMBER)IS

	recinfo            mtl_kanban_cards%ROWTYPE;
	from_supply_status NUMBER;
	v_supply_val       NUMBER;
	l_return_status    VARCHAR2(1);
  BEGIN
    SELECT *
      INTO recinfo
      FROM mtl_kanban_cards
     WHERE kanban_card_number = p_kanban_card_number
       AND organization_id = p_org_id;

    -- Is kanban_card_number unique?
    x_status  := 'C';

    IF recinfo.card_status <> 1 THEN
      x_message  := 'Card' || p_kanban_card_number || 'is not active';
      x_status   := 'E';
    ELSE
      from_supply_status     := recinfo.supply_status;
      recinfo.supply_status  := 4;
      v_supply_val           := status_check(from_supply_status, recinfo.supply_status);

      IF v_supply_val = 1 THEN
        x_message  := 'Card ' || p_kanban_card_number || 'cannot be replenished from status ' || TO_CHAR(from_supply_status);
        x_status   := 'E';
      ELSIF v_supply_val = 2 THEN
        -- Start replenishment process
        inv_kanbancard_pkg.update_row(
          x_return_status              => l_return_status
        , p_kanban_card_id             => recinfo.kanban_card_id
        , p_kanban_card_number         => recinfo.kanban_card_number
        , p_pull_sequence_id           => recinfo.pull_sequence_id
        , p_inventory_item_id          => recinfo.inventory_item_id
        , p_organization_id            => recinfo.organization_id
        , p_subinventory_name          => recinfo.subinventory_name
        , p_supply_status              => recinfo.supply_status
        , p_card_status                => recinfo.card_status
        , p_kanban_card_type           => recinfo.kanban_card_type
        , p_source_type                => recinfo.source_type
        , p_kanban_size                => recinfo.kanban_size
        , p_last_update_date           => SYSDATE
        , p_last_updated_by            => fnd_global.user_id
        , p_creation_date              => recinfo.creation_date
        , p_created_by                 => recinfo.created_by
        , p_last_update_login          => fnd_global.login_id
        , p_last_print_date            => recinfo.last_print_date
        , p_locator_id                 => recinfo.locator_id
        , p_supplier_id                => recinfo.supplier_id
        , p_supplier_site_id           => recinfo.supplier_site_id
        , p_source_organization_id     => recinfo.source_organization_id
        , p_source_subinventory        => recinfo.source_subinventory
        , p_source_locator_id          => recinfo.source_locator_id
        , p_wip_line_id                => recinfo.wip_line_id
        , p_current_replnsh_cycle_id   => recinfo.current_replnsh_cycle_id
        , p_error_code                 => recinfo.error_code
        , p_attribute_category         => recinfo.attribute_category
        , p_attribute1                 => recinfo.attribute1
        , p_attribute2                 => recinfo.attribute2
        , p_attribute3                 => recinfo.attribute3
        , p_attribute4                 => recinfo.attribute4
        , p_attribute5                 => recinfo.attribute5
        , p_attribute6                 => recinfo.attribute6
        , p_attribute7                 => recinfo.attribute7
        , p_attribute8                 => recinfo.attribute8
        , p_attribute9                 => recinfo.attribute9
        , p_attribute10                => recinfo.attribute10
        , p_attribute11                => recinfo.attribute11
        , p_attribute12                => recinfo.attribute12
        , p_attribute13                => recinfo.attribute13
        , p_attribute14                => recinfo.attribute14
        , p_attribute15                => recinfo.attribute15
        , p_document_type              => NULL
        , p_document_header_id         => NULL
        , p_document_detail_id         => NULL
	, p_lot_item_id                => p_lot_item_id
	, p_lot_number                 => p_lot_number
	, p_lot_item_revision          => p_lot_item_revision
	, p_lot_subinventory_code      => p_lot_subinventory_code
	, p_lot_location_id            => p_lot_location_id
	, p_lot_quantity               => p_lot_quantity
	, p_replenish_quantity         => p_replenish_quantity);
      END IF;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_message  := p_kanban_card_number || 'is not a valid Kanban card number';
      x_status   := 'E';
  END replenishcard;

  /*PJM-WMS Integration:*/
  /*Returned 5 new output parameters namely x_project, x_task,x_source_id,
   *x_source_project and x_source_task.
   */
  PROCEDURE getreplenishinfo(
    p_org_id             IN     NUMBER
  , p_kanban_card_number IN     VARCHAR2
  , x_item               OUT    NOCOPY VARCHAR2
  , x_item_description   OUT    NOCOPY VARCHAR2
  , x_quantity           OUT    NOCOPY NUMBER
  , x_zone               OUT    NOCOPY VARCHAR2
  , x_project            OUT    NOCOPY VARCHAR2
  , --PJM-WMS Integration
   x_task                OUT    NOCOPY VARCHAR2
  , --PJM-WMS Integration
   x_locator             OUT    NOCOPY VARCHAR2
  , x_supply_status      OUT    NOCOPY VARCHAR2
  , x_source_type_id     OUT    NOCOPY NUMBER
  , x_source_type        OUT    NOCOPY VARCHAR2
  , x_source_org_id      OUT    NOCOPY NUMBER
  , --PJM-WMS Integration
   x_source_org          OUT    NOCOPY VARCHAR2
  , x_source_zone        OUT    NOCOPY VARCHAR2
  , x_source_project     OUT    NOCOPY VARCHAR2
  , --PJM-WMS Integration
   x_source_task         OUT    NOCOPY VARCHAR2
  , --PJM-WMS Integration
   x_source_locator      OUT    NOCOPY VARCHAR2
  , x_wip_line           OUT    NOCOPY VARCHAR2
  , x_supplier_name      OUT    NOCOPY VARCHAR2
  , x_supplier_site      OUT    NOCOPY VARCHAR2
  , x_item_id            OUT    NOCOPY NUMBER
  , x_eligible_for_lbj   OUT    NOCOPY VARCHAR2
  , x_bom_seq_id         OUT    NOCOPY NUMBER
  , x_start_seq_num      OUT    NOCOPY NUMBER
  , x_message            OUT    NOCOPY VARCHAR2
  , x_status             OUT    NOCOPY VARCHAR2
  ) IS
    locator_id        NUMBER;
    source_org_id     NUMBER;
    source_locator_id NUMBER;
    supplier_site_id  NUMBER;


    l_error_code      NUMBER := NULL;
    l_error_message       VARCHAR2(255) := NULL;
  BEGIN
    /*Bug#5612236. In the below query, replaced 'MTL_SYSTEM_ITEMS_KFV'
      with 'MTL_SYSTEM_ITEMS_VL'.*/
    SELECT msiv.concatenated_segments
         , msiv.description
         , mkcv.kanban_size
         , mkcv.subinventory_name
         , mkcv.locator_id
         , mkcv.supply_status_name
         , mkcv.source_type
         , mkcv.source_type_meaning
         , mkcv.source_organization_id
         , mkcv.source_org_code
         , mkcv.source_subinventory
         , mkcv.source_locator_id
         , mkcv.wip_line_code
         , mkcv.supplier_name
         , mkcv.supplier_site_id
         , msiv.inventory_item_id
      INTO x_item
         , x_item_description
         , x_quantity
         , x_zone
         , locator_id
         , x_supply_status
         , x_source_type_id
         , x_source_type
         , source_org_id
         , x_source_org
         , x_source_zone
         , source_locator_id
         , x_wip_line
         , x_supplier_name
         , supplier_site_id
         , x_item_id
      FROM mtl_kanban_cards_v mkcv, mtl_system_items_vl msiv
     WHERE mkcv.kanban_card_number = p_kanban_card_number
       AND mkcv.organization_id = p_org_id
       AND mkcv.inventory_item_id = msiv.inventory_item_id
       AND mkcv.organization_id = msiv.organization_id;

    /* PJM-WMS Integration:
     * Use the function INV_PROJECT.Get_Locsegs() to get the
     * concatenated segments of the locators.
     */
    x_locator         := inv_project.get_locsegs(locator_id, p_org_id);
    x_project         := inv_project.get_project_number;
    x_task            := inv_project.get_task_number;
    x_source_locator  := inv_project.get_locsegs(source_locator_id, source_org_id);
    x_source_project  := inv_project.get_project_number;
    x_source_task     := inv_project.get_task_number;
    x_source_org_id   := source_org_id;
    /*End of PJM-WMS Integration */
    x_supplier_site   := inv_kanban_pkg.getsuppliersitename(supplier_site_id);
    x_message         := 'Item: ' || x_item;
    x_status          := 'C';

    IF inv_kanban_pvt.eligible_for_lbj
      (p_organization_id  => p_org_id,
       p_inventory_item_id => x_item_id,
       p_source_type_id    => x_source_type_id) = 'Y' THEN

       x_eligible_for_lbj := 'Y';

       INV_KANBAN_PVT.GET_KANBAN_REC_GRP_INFO (p_organization_id     => p_org_id,
					       p_kanban_assembly_id  => x_item_id,
					       p_rtg_rev_date        => sysdate,
					       x_bom_seq_id	     => x_bom_seq_id,
					       x_start_seq_num	     => x_start_seq_num,
					       x_error_code	     => l_error_code,
					       x_error_msg	     => l_error_message);

       IF l_error_code IS NOT NULL OR
	 l_error_message IS NOT NULL  THEN
	  RAISE NO_DATA_FOUND;
       END IF;

       --Get parameters for the lot lov
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_message           := p_kanban_card_number || 'Is Not a Valid Kanban Card Number';
      x_status            := 'E';
      x_item              := NULL;
      x_item_description  := NULL;
      x_quantity          := NULL;
      x_zone              := NULL;
      x_locator           := NULL;
      x_supply_status     := NULL;
      x_source_type       := NULL;
      x_source_org        := NULL;
      x_source_zone       := NULL;
      x_source_locator    := NULL;
      x_wip_line          := NULL;
      x_supplier_name     := NULL;
      x_supplier_site     := NULL;
      /*PJM-WMS Integration*/
      x_project           := NULL;
      x_task              := NULL;
      x_source_org_id     := NULL;
      x_source_project    := NULL;
      x_source_project    := NULL;
      /* -PJM-WMS Integration*/
      x_item_id          := NULL;
      x_eligible_for_lbj := NULL;
      x_bom_seq_id := NULL;
      x_start_seq_num := NULL;
  END getreplenishinfo;

  PROCEDURE getsourcetypelov(x_kanban_ref OUT NOCOPY t_genref, p_source_type IN VARCHAR2) IS
  BEGIN
    OPEN x_kanban_ref FOR
      SELECT DISTINCT meaning
                    , lookup_code
                 FROM mfg_lookups
                WHERE lookup_code IN (1, 2, 3, 4)
                  AND meaning LIKE (p_source_type)
                  AND lookup_type = 'MTL_KANBAN_SOURCE_TYPE';
  END getsourcetypelov;

  PROCEDURE getsupplierlov(x_kanban_ref OUT NOCOPY t_genref, p_supplier_name IN VARCHAR2) IS
  BEGIN
    OPEN x_kanban_ref FOR
      SELECT vendor_name
           , vendor_id
        FROM po_vendors
       WHERE vendor_name LIKE (p_supplier_name);
  END getsupplierlov;

  PROCEDURE getsuppliersitelov(x_kanban_ref OUT NOCOPY t_genref, p_supplier_site IN VARCHAR2, p_vendor_id IN NUMBER) IS
  BEGIN
    OPEN x_kanban_ref FOR
      SELECT vendor_site_code
           , vendor_site_code_alt
        FROM po_vendor_sites_all
       WHERE vendor_site_code LIKE (p_supplier_site)
         AND vendor_id = p_vendor_id;
  END getsuppliersitelov;

  PROCEDURE getwiplinelov(x_kanban_ref OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_wip_line IN VARCHAR2) IS
  BEGIN
    OPEN x_kanban_ref FOR
      SELECT line_code
           , line_id
        FROM wip_lines
       WHERE p_organization_id = organization_id
         AND line_code LIKE (p_wip_line);
  END getwiplinelov;

  PROCEDURE getinquiryinfo(
    x_kanban_ref             OUT    NOCOPY t_genref
  , p_org_id                 IN     NUMBER
  , p_kanban_card_number     IN     VARCHAR2
  , p_item_id                IN     NUMBER
  , p_source_type_id         IN     NUMBER
  , p_supplier               IN     VARCHAR2
  , p_supplier_site          IN     VARCHAR2
  , p_source_organization_id IN     NUMBER
  , p_source_sub             IN     VARCHAR2
  , p_source_loc             IN     NUMBER
  , p_wip_line_id            IN     NUMBER
  , p_project_id             IN     NUMBER DEFAULT NULL
  , p_task_id                IN     NUMBER DEFAULT NULL
  ) IS
  BEGIN
    /*Bug#5612236. In the below query, replaced 'MTL_SYSTEM_ITEMS_KFV' with
      'MTL_SYSTEM_ITEMS_VL'.*/
    OPEN x_kanban_ref FOR
      SELECT mkc.kanban_card_number
           , mfg1.meaning kanban_card_type
           , msiv.concatenated_segments item
           , msiv.description
           , mkc.kanban_size
           , mkc.subinventory_name
           , inv_kanban_pkg.getlocatorname(p_org_id, mkc.locator_id) loc_name
           , inv_project.get_project_number project_num
           , inv_project.get_task_number task_num
           , mfg2.meaning card_status_name
           , mfg3.meaning supply_status_name
           , mfg4.meaning source_type
           , inv_kanban_pkg.getorgcode(mkc.source_organization_id)
           , mkc.source_subinventory
           , inv_kanban_pkg.getlocatorname(mkc.source_organization_id, mkc.source_locator_id) source_loc_name
           , inv_project.get_project_number src_project_num
           , inv_project.get_task_number src_task_num
           , mka.last_update_date
           , mfg5.meaning act_supp_status_name
           , mfg6.meaning doc_type
           , inv_kanban_pkg.getdocmentnumber(mka.document_header_id, mka.document_type, mka.document_detail_id) doc_num
           , inv_kanban_pkg.getorgcode(mka.source_organization_id)
           , mka.source_subinventory act_sub
           , inv_kanban_pkg.getlocatorname(mka.source_organization_id, mka.source_locator_id) act_loc_name
           , inv_project.get_project_number act_project_num
           , inv_project.get_task_number act_task_num
           , pv.vendor_name vendor
           , pvsa.vendor_site_code vendor_site
           , wl.line_code
           , pv_act.vendor_name vendor_last_activity
           , pvsa_act.vendor_site_code vendor_site_last_activity
           , wl_act.line_code
        FROM mtl_kanban_cards mkc
           , mtl_system_items_vl msiv
           , mfg_lookups mfg1
           , mfg_lookups mfg2
           , mfg_lookups mfg3
           , mfg_lookups mfg4
           , mfg_lookups mfg5
           , mfg_lookups mfg6
           , po_vendors pv
           , mtl_kanban_card_activity mka
           , po_vendor_sites_all pvsa
           , mtl_kanban_pull_sequences mkps
           , wip_lines wl
           , wip_lines wl_act
           , po_vendors pv_act
           , mtl_item_locations mil
           , po_vendor_sites_all pvsa_act
       WHERE mkc.kanban_card_number LIKE (p_kanban_card_number || '%') -- 3231139
         AND mkc.organization_id = p_org_id
         AND mkc.inventory_item_id = NVL(p_item_id, mkc.inventory_item_id)
         AND mkc.source_type = NVL(p_source_type_id, mkc.source_type)
         AND NVL(mkc.source_organization_id, 0) = NVL(p_source_organization_id, NVL(mkc.source_organization_id, 0))
         AND NVL(mkc.source_subinventory, '@@@') LIKE NVL(p_source_sub, NVL(mkc.source_subinventory, '@@@'))
         AND NVL(mkc.source_locator_id, 0) = NVL(p_source_loc, NVL(mkc.source_locator_id, 0))
         --Bug 3622464 Start
         AND mil.inventory_location_id(+) = mkc.source_locator_id
      --AND (mil.inventory_location_id(+) = NVL(p_source_loc, -1)
         --Bug 3882518 fix. commenting the below line.don't need this
         --AND (nvl(mil.inventory_location_id,-1) = nvl(p_source_loc,-1)
         --Bug 3622464 End
              AND NVL(mil.project_id, -1) = NVL(p_project_id, NVL(mil.project_id, -1))
              AND NVL(mil.task_id, -1) = NVL(p_task_id, NVL(mil.task_id, -1))
         --    )
         AND mkc.pull_sequence_id = mkps.pull_sequence_id(+)
         AND NVL(mkps.wip_line_id, 0) = NVL(p_wip_line_id, NVL(mkps.wip_line_id, 0))
         AND wl.line_id(+) = mkps.wip_line_id
         AND wl_act.line_id(+) = mka.wip_line_id
         AND pv.vendor_name(+) LIKE (p_supplier || '%')
         AND pvsa.vendor_site_code(+) LIKE (p_supplier_site || '%')
         AND mkc.inventory_item_id = msiv.inventory_item_id
         AND mkc.organization_id = msiv.organization_id
         AND mkc.supplier_id = pv.vendor_id(+)
         AND mkc.supplier_site_id = pvsa.vendor_site_id(+)
         AND mka.supplier_id = pv_act.vendor_id(+)
         AND mka.supplier_site_id = pvsa_act.vendor_site_id(+)
         AND mkc.inventory_item_id = mka.inventory_item_id(+)
         AND mkc.organization_id = mka.organization_id(+)
         AND mkc.kanban_card_id = mka.kanban_card_id(+)
         AND NVL(TO_CHAR(mka.last_update_date, 'DD-MON-YYYY HH24:MI:SS'), '01/01/1111 00:00:00') =
                                                     (SELECT NVL(TO_CHAR(MAX(last_update_date), 'DD-MON-YYYY HH24:MI:SS'), '01/01/1111 00:00:00')
                                                        FROM mtl_kanban_card_activity mkca
                                                       WHERE NVL(mkca.kanban_card_id, mkc.kanban_card_id) = mkc.kanban_card_id)
         AND mfg1.lookup_type = 'MTL_KANBAN_CARD_TYPE'
         AND mfg1.lookup_code = mkc.kanban_card_type
         AND mfg2.lookup_type = 'MTL_KANBAN_CARD_STATUS'
         AND mfg2.lookup_code = mkc.card_status
         AND mfg3.lookup_type = 'MTL_KANBAN_SUPPLY_STATUS'
         AND mfg3.lookup_code = mkc.supply_status         AND mfg4.lookup_type = 'MTL_KANBAN_SOURCE_TYPE'
         AND mfg4.lookup_code = mkc.source_type
         AND mfg5.lookup_type(+) = 'MTL_KANBAN_SUPPLY_STATUS'
         AND mfg5.lookup_code(+) = NVL(mka.supply_status, 0)
         AND mfg6.lookup_type(+) = 'MTL_KANBAN_DOCUMENT_TYPE'
         AND mfg6.lookup_code(+) = NVL(mka.document_type, 0);
  END getinquiryinfo;


  /* VMI changes - Called from VendorSiteLOV though not used anymore*/
  PROCEDURE get_vmi_vendor_site_lov(x_ref OUT NOCOPY t_genref, p_vendor_site_code IN VARCHAR2, p_vendor_id IN NUMBER) IS
  BEGIN
    OPEN x_ref FOR
      SELECT vendor_site_code
           , vendor_site_id
        FROM po_vendor_sites povs
       WHERE povs.vendor_id = p_vendor_id
         AND povs.vendor_site_code LIKE (p_vendor_site_code);
  END get_vmi_vendor_site_lov;

  /* Consignment Changes */
  /* Bug#2810335. Added ood.organization_code to the select clause*/
  /* Bug 2834753, continue bug 2810335, show party name, opertion unit second */
  PROCEDURE get_vendor_lov(x_ref OUT NOCOPY t_genref, p_vendor VARCHAR2,p_vendor_site_id VARCHAR2) IS
  BEGIN
     OPEN x_ref FOR
        SELECT
              pv.vendor_name || '-' || pvs.vendor_site_code owning_planning_party
             , ood.organization_code
             , pv.vendor_id
             , pvs.vendor_site_id
             , 1 tp_type
             , 'Supplier' party_type
          FROM po_vendors pv
             , po_vendor_sites_all pvs
             , org_organization_definitions ood
         WHERE pv.vendor_id = pvs.vendor_id
           AND pvs.org_id = ood.organization_id (+)
           AND pv.vendor_name || '-' || pvs.vendor_site_code LIKE p_vendor
           AND (p_vendor_site_id IS NULL OR  pvs.vendor_site_id = p_vendor_site_id)
           -- bug# 2880891
         order by owning_planning_party;

  END get_vendor_lov;

  PROCEDURE get_starting_lot_lov
    (x_lot_num_lov OUT NOCOPY t_genref,
     p_organization_id IN NUMBER,
     p_assembly_item_id IN NUMBER,
     p_bom_sequence_id IN NUMBER,
     p_start_sequence_num IN VARCHAR2) IS

  BEGIN
    OPEN x_lot_num_lov FOR
      select lot_number, item, quantity,  revision, wslv.subinventory_code,
      milk.concatenated_segments, wslv.inventory_item_id, locator_id
      from
      wsm_source_lots_v wslv,
      bom_inventory_components bic,
      mtl_item_locations_kfv milk
      where
      wslv.organization_id = p_organization_id
      and wslv.inventory_item_id = bic.component_item_id
      and bic.bill_sequence_id = p_bom_sequence_id
      and(bic.operation_seq_num = p_start_sequence_num or bic.operation_seq_num = 1 )
      and bic.effectivity_date <= sysdate
      and nvl(bic.disable_date, sysdate + 1) > Sysdate
      AND wslv.locator_id = milk.inventory_location_id(+)
      AND wslv.subinventory_code = milk.subinventory_code(+)
      AND wslv.organization_id = milk.organization_id(+);

  END get_starting_lot_lov;

  /** This procedure returns the details of the kanban card passed like
   *  Card Type, Card Status, Supply Status etc.,
   *  @param   x_return_status           Return Status
   *  @param   x_msg_count               Message Count
   *  @param   x_msg_data                Message Data
   *  @param   x_card_type               Kanban Card Type
   *  @param   x_card_status             Kanban Card Status
   *  @param   x_supply_status           Kanban Card Supply status
   *  @param   x_status_check            Kanban Card Supply status Check
   *  @param   x_supply_status_meaning   Kanban Card Supply status meaning
   *  @param   p_organization_id         Organization Id
   *  @param   p_kanban_number           Kanban Card Number
   *
   **/
  PROCEDURE get_kanban_details(x_return_status OUT NOCOPY VARCHAR2
                             , x_msg_count OUT NOCOPY NUMBER
                             , x_msg_data OUT NOCOPY VARCHAR2
                             , x_card_type OUT NOCOPY NUMBER
                             , x_card_status OUT NOCOPY NUMBER
                             , x_supply_status OUT NOCOPY NUMBER
                             , x_status_check OUT NOCOPY NUMBER
                             , x_supply_status_meaning OUT NOCOPY VARCHAR2
                             , p_organization_id IN NUMBER
                             , p_kanban_number IN VARCHAR2) IS
    l_proc CONSTANT VARCHAR2(30) := 'GET_KANBAN_DETAILS';
    l_trace_on NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
    CURSOR c_kb_details IS
      SELECT mkc.kanban_card_type
           , mkc.card_status
           , mkc.supply_status
           , status_check(mkc.supply_status, 4) status_check
           , ml.meaning supply_status_meaning
        FROM mtl_kanban_cards mkc
           , mfg_lookups ml
       WHERE mkc.organization_id = p_organization_id
         AND mkc.kanban_card_number = p_kanban_number
         AND ml.lookup_type = 'MTL_KANBAN_SUPPLY_STATUS'
         AND mkc.supply_status = ml.lookup_code
         AND ROWNUM = 1;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    IF l_trace_on = 1 THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || '   p_organization_id      : '
        || p_organization_id
        || fnd_global.local_chr(10)
        || '   p_kanban_number     : '
        || p_kanban_number
        || fnd_global.local_chr(10)
      , l_proc
      , 9
      );
    END IF;
    OPEN c_kb_details;
    FETCH c_kb_details INTO x_card_type, x_card_status, x_supply_status, x_status_check, x_supply_status_meaning;

    IF (c_kb_details%NOTFOUND) THEN
       x_return_status := fnd_api.g_ret_sts_error;
    ELSE
	    x_return_status := fnd_api.g_ret_sts_success;
    END IF;
    CLOSE c_kb_details;

  END get_kanban_details;

  /** This procedure returns the details of the kanban move order
   *  like Mo Line Id, MO Line Status, MO Reference Type etc., for the Kanban Card passed.
   *  @param   x_return_status           Return Status
   *  @param   x_msg_count               Message Count
   *  @param   x_msg_data                Message Data
   *  @param   x_mo_line_id              Kanban Move Order Line Id
   *  @param   x_ref_type_code           Move Order Reference Type
   *  @param   x_mo_line_status_code     Kanban Move Order Line Status
   *  @param   x_mo_line_qty_diff        (Kanban Move Order Line quantity delivered - Total Kanban Move Order Line quantity)
   *  @param   p_organization_id         Organization Id
   *  @param   p_kanban_number           Kanban Card Number
   **/
  PROCEDURE get_kanban_mo_details(x_return_status OUT NOCOPY VARCHAR2
                                , x_msg_count OUT NOCOPY NUMBER
                                , x_msg_data OUT NOCOPY VARCHAR2
                                , x_mo_line_id OUT NOCOPY NUMBER
                                , x_ref_type_code OUT NOCOPY NUMBER
                                , x_mo_line_status_code OUT NOCOPY NUMBER
                                , x_mo_line_qty_diff OUT NOCOPY NUMBER
                                , p_organization_id IN NUMBER
                                , p_kanban_number IN VARCHAR2) IS
    l_proc CONSTANT VARCHAR2(30) := 'GET_KANBAN_MO_DETAILS';
    l_trace_on NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 2);
    -- Bug 4574518, when the kanban card is replenished more than once, there will be more records and the latest record should be used
    CURSOR c_kb_mo_details IS
       SELECT * FROM (SELECT m.line_id
            , m.reference_type_code
            , m.line_status
            , (NVL(quantity_delivered, 0)- m.quantity) qty_diff
        FROM mtl_txn_request_lines m
           , mtl_kanban_cards k
       WHERE m.reference_id = k.kanban_card_id
         AND m.organization_id = p_organization_id
         AND k.kanban_card_number = p_kanban_number
	 ORDER BY m.line_id desc)
       WHERE ROWNUM = 1;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    IF l_trace_on = 1 THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || '   p_organization_id      : '
        || p_organization_id
        || fnd_global.local_chr(10)
        || '   p_kanban_number     : '
        || p_kanban_number
        || fnd_global.local_chr(10)
      , l_proc
      , 9
      );
    END IF;
    OPEN c_kb_mo_details;
    FETCH c_kb_mo_details INTO x_mo_line_id, x_ref_type_code, x_mo_line_status_code, x_mo_line_qty_diff;

    IF (c_kb_mo_details%NOTFOUND) THEN
       x_return_status := fnd_api.g_ret_sts_error;
    ELSE
	    x_return_status := fnd_api.g_ret_sts_success;
    END IF;
    CLOSE c_kb_mo_details;

  END get_kanban_mo_details;
END inv_kanban_pkg;

/
