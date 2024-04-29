--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PVT10
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PVT10" AS
/* $Header: INVLA10B.pls 120.5 2007/01/17 09:47:50 salagars noship $ */

LABEL_B		CONSTANT VARCHAR2(50) := '<label';
LABEL_E		CONSTANT VARCHAR2(50) := '</label>'||fnd_global.local_chr(10);
VARIABLE_B	CONSTANT VARCHAR2(50) := '<variable name= "';
VARIABLE_E	CONSTANT VARCHAR2(50) := '</variable>'||fnd_global.local_chr(10);
TAG_E		CONSTANT VARCHAR2(50)  := '>'||fnd_global.local_chr(10);
l_debug number;

/* MMTT_TYPE : transaction is MTL_MATERIAL_TRANSACTIONS_TEMP ID */
/* MTI_TYPE  : transaction is MTL_TRANSACTION_INTERFACE ID      */
/* MTRL_TYPE : transaction is MTL_TXN_REQUEST_LINES ID          */
/* WFS_TYPE  : transaction is WIP_FLOW_SCHEDULES ID             */

MMTT_TYPE       CONSTANT NUMBER := 1;
MTI_TYPE        CONSTANT NUMBER := 2;
MTRL_TYPE       CONSTANT NUMBER := 3;
WFS_TYPE        CONSTANT NUMBER := 4;

G_DATE_FORMAT_MASK VARCHAR2(20) := INV_LABEL.G_DATE_FORMAT_MASK;

TYPE output_rec is RECORD
(
  datbuf VARCHAR2(240)
);

TYPE output_tbl_type IS TABLE OF output_rec INDEX BY BINARY_INTEGER;

PROCEDURE trace(p_message VARCHAR2) IS
BEGIN
   	INV_LABEL.trace(p_message, 'LABEL_FLOW_CONT');
END trace;

PROCEDURE get_data(
   x_out_tbl IN OUT NOCOPY output_tbl_type,
   p_wip_entity_id     wip_flow_schedules.wip_entity_id%TYPE,
   p_schedule_number   wip_flow_schedules.schedule_number%TYPE,
   p_inventory_item_id mtl_system_items.inventory_item_id%TYPE,
   p_organization_id   mtl_system_items.organization_id%TYPE,
   p_subinventory_code wip_flow_schedules.completion_subinventory%TYPE,
   p_locator_id        wip_flow_schedules.completion_locator_id%TYPE
) IS

i                 NUMBER;
l_wip_entity_id   wip_flow_schedules.wip_entity_id%TYPE := NULL;

  CURSOR item_curs IS
SELECT
NULL cost_group,
item.concatenated_segments,
item.description,
item.attribute1,
item.attribute10,
item.attribute11,
item.attribute12,
item.attribute13,
item.attribute14,
item.attribute15,
item.attribute2,
item.attribute3,
item.attribute4,
item.attribute5,
item.attribute6,
item.attribute7,
item.attribute8,
item.attribute9,
item.attribute_category,
item_poh. hazard_class,
item_mir.revision
FROM MTL_SYSTEM_ITEMS_KFV item,
 PO_HAZARD_CLASSES item_poh,
 MTL_ITEM_REVISIONS item_mir
WHERE item.organization_id = p_organization_id
AND item.inventory_item_id = p_inventory_item_id
AND item.hazard_class_id  = item_poh.hazard_class_id (+)
AND item.organization_Id = item_mir.organization_id(+)
AND item.inventory_item_id = item_mir.inventory_item_id(+);

  CURSOR flow_curs IS
SELECT
wflow.bom_revision,
Wflow.build_sequence,
wflow_loc.concatenated_segments completion_location,
NVL(p_subinventory_code ,wflow.completion_subinventory),
wflow.end_item_unit_number,
wflow.attribute1,
wflow.attribute10,
wflow.attribute11,
wflow.attribute12,
wflow.attribute13,
wflow.attribute14,
wflow.attribute15,
wflow.attribute2,
wflow.attribute3,
wflow.attribute4,
wflow.attribute5,
wflow.attribute6,
wflow.attribute7,
wflow.attribute8,
wflow.attribute9,
wflow.attribute_category,
Wflow.created_by,
to_char(wflow.creation_date,G_DATE_FORMAT_MASK),
to_char(wflow.last_update_date,G_DATE_FORMAT_MASK),
wflow.last_updated_by,
wflow.planned_quantity,
wflow.quantity_completed,
wflow.schedule_number,
to_char(wflow.scheduled_start_date,G_DATE_FORMAT_MASK),
wflow.status,
wflow_mkc.kanban_card_number,
wflow.material_account,
wflow.mps_net_quantity,
to_char(wflow.mps_scheduled_completion_date,G_DATE_FORMAT_MASK),
wflow.quantity_scrapped,
wflow.routing_revision,
to_char(wflow.scheduled_completion_date,G_DATE_FORMAT_MASK),
wflow_we.wip_entity_name,
Wflow_wl.line_code,
wflow.End_item_unit_number,
wflow.Current_line_operation
FROM WIP_FLOW_SCHEDULES wflow,
WIP_ENTITIES wflow_we,
MTL_ITEM_LOCATIONS_KFV wflow_loc,
MTL_KANBAN_CARDS wflow_mkc,
WIP_LINES wflow_wl
WHERE wflow.wip_entity_id = l_wip_entity_id
AND Wflow.wip_entity_id = wflow_we.wip_entity_id
AND NVL(p_locator_id,wflow.completion_locator_id) = wflow_loc.inventory_location_id(+)
AND Wflow.kanban_card_id = wflow_mkc.kanban_card_id(+)
AND Wflow.line_id = wflow_wl.line_id(+);

CURSOR flow_entity_curs IS
   SELECT wip_entity_id
   FROM WIP_FLOW_SCHEDULES
   WHERE wip_entity_id = p_wip_entity_id ;


BEGIN
    l_debug := INV_LABEL.l_debug;
   IF (l_debug = 1) THEN
      trace('**In get_data() **.');
      trace(' p_schedule_number : ' || p_schedule_number);
      trace(' p_wip_entity_Id : ' || p_wip_entity_id);
      trace(' p_inventory_item_id : ' || p_inventory_item_id);
      trace(' p_organization_id : ' || p_organization_id);
      trace('** Get Item data .., ');
   END IF;
   OPEN item_curs;
   FETCH item_curs INTO
      x_out_tbl(1710).datbuf, x_out_tbl(1711).datbuf, x_out_tbl(1712).datbuf,
      x_out_tbl(1713).datbuf, x_out_tbl(1714).datbuf, x_out_tbl(1715).datbuf,
      x_out_tbl(1716).datbuf, x_out_tbl(1717).datbuf, x_out_tbl(1718).datbuf,
      x_out_tbl(1719).datbuf, x_out_tbl(1720).datbuf, x_out_tbl(1721).datbuf,
      x_out_tbl(1722).datbuf, x_out_tbl(1723).datbuf, x_out_tbl(1724).datbuf,
      x_out_tbl(1725).datbuf, x_out_tbl(1726).datbuf, x_out_tbl(1727).datbuf,
      x_out_tbl(1728).datbuf, x_out_tbl(1729).datbuf, x_out_tbl(1730).datbuf;

   CLOSE item_curs;
/*
   FOR i in 1710..1730 LOOP
      IF (x_out_tbl.EXISTS(i) AND x_out_tbl(i).datbuf IS NOT NULL ) THEN
          IF (l_debug = 1) THEN
             trace('x_out_tbl('||i||')='|| x_out_tbl(i).datbuf );
          END IF;
      END IF;
   END LOOP;
*/
   IF (l_debug = 1) THEN
      trace('** Get WIP Flow Schedule entity ID .., ');
   END IF;
   OPEN flow_entity_curs;
   FETCH flow_entity_curs INTO l_wip_entity_id;
   CLOSE flow_entity_curs;
   if (p_schedule_number IS NOT NULL) THEN
      -- assign schedule number to x_out_tbl(2027)
      x_out_tbl(2027).datbuf := p_schedule_number;

      BEGIN
         SELECT wip_entity_id INTO l_wip_entity_id
         FROM WIP_FLOW_SCHEDULES
         WHERE schedule_number = p_schedule_number ;

      EXCEPTION
         WHEN OTHERS THEN
         IF (l_debug = 1) THEN
            trace('No entry for WIP_FLOW_SCHEDULE schedule_number : ' || p_schedule_number);
         END IF;

      END;
   END IF;

   IF (l_wip_entity_id IS NOT NULL) THEN
       IF (l_debug = 1) THEN
          trace('** Retrieving WIP Flow Schedue date for entity ID : '|| l_wip_entity_id);
       END IF;
      OPEN flow_curs;
      FETCH flow_curs INTO
      x_out_tbl(2000).datbuf, x_out_tbl(2001).datbuf, x_out_tbl(2002).datbuf,
      x_out_tbl(2003).datbuf, x_out_tbl(2004).datbuf, x_out_tbl(2005).datbuf,
      x_out_tbl(2006).datbuf, x_out_tbl(2007).datbuf, x_out_tbl(2008).datbuf,
      x_out_tbl(2009).datbuf, x_out_tbl(2010).datbuf, x_out_tbl(2011).datbuf,
      x_out_tbl(2012).datbuf, x_out_tbl(2013).datbuf, x_out_tbl(2014).datbuf,
      x_out_tbl(2015).datbuf, x_out_tbl(2016).datbuf, x_out_tbl(2017).datbuf,
      x_out_tbl(2018).datbuf, x_out_tbl(2019).datbuf, x_out_tbl(2020).datbuf,
      x_out_tbl(2021).datbuf, x_out_tbl(2022).datbuf, x_out_tbl(2023).datbuf,
      x_out_tbl(2024).datbuf, x_out_tbl(2025).datbuf, x_out_tbl(2026).datbuf,
      x_out_tbl(2027).datbuf, x_out_tbl(2028).datbuf, x_out_tbl(2029).datbuf,
      x_out_tbl(2030).datbuf, x_out_tbl(2031).datbuf, x_out_tbl(2032).datbuf,
      x_out_tbl(2033).datbuf, x_out_tbl(2034).datbuf, x_out_tbl(2035).datbuf,
      x_out_tbl(2036).datbuf, x_out_tbl(2037).datbuf, x_out_tbl(2038).datbuf,
      x_out_tbl(2039).datbuf, x_out_tbl(2040).datbuf;
      CLOSE flow_curs;

/*
      -- Wip Flow Schedule
      FOR i in 2000..2040 LOOP
         IF (x_out_tbl.EXISTS(i) AND x_out_tbl(i).datbuf IS NOT NULL ) THEN
             IF (l_debug = 1) THEN
                trace('x_out_tbl('||i||')='|| x_out_tbl(i).datbuf );
             END IF;
         END IF;
      END LOOP;
*/
   END IF;

END get_data ;
/*=================================================================*/
PROCEDURE get_data_bom_bill_header(
   x_out_tbl IN OUT NOCOPY output_tbl_type,
   p_inventory_item_id bom_bill_of_materials.assembly_item_id%TYPE,
   p_organization_id   bom_bill_of_materials.organization_id%TYPE,
   p_alternate_bom_designator   bom_bill_of_materials.alternate_bom_designator%TYPE
)IS

  CURSOR bom_header_curs IS
SELECT
--Bom_hdr.bill_sequence_id,
--Bom_hdr.assembly_item_id,
bom_hdr.attribute1,
bom_hdr.attribute2,
bom_hdr.attribute3,
bom_hdr.attribute4,
bom_hdr.attribute5,
bom_hdr.attribute6,
bom_hdr.attribute7,
bom_hdr.attribute8,
bom_hdr.attribute9,
bom_hdr.attribute10,
bom_hdr.attribute11,
bom_hdr.attribute12,
bom_hdr.attribute13,
bom_hdr.attribute14,
bom_hdr.attribute15,
bom_hdr.attribute_category,
bom_hdr_pp.name project_name,
bom_hdr_pt.task_name task_name,
Bom_hdr.specific_assembly_comment
FROM BOM_BILL_OF_MATERIALS bom_hdr,
     PA_PROJECTS bom_hdr_pp, PA_TASKS bom_hdr_pt
WHERE bom_hdr.assembly_item_id = p_inventory_item_id
AND   bom_hdr.organization_id     = p_organization_id
AND  nvl(bom_hdr.alternate_bom_designator, '@@@') =   nvl(p_alternate_bom_designator, '@@@')
AND bom_hdr.project_id = bom_hdr_pp.project_id(+)
AND bom_hdr.task_id = bom_hdr_pt.task_id(+);

BEGIN
   IF (l_debug = 1) THEN
      trace('**In get_data_bom_bill_header() **');
   END IF;
   OPEN bom_header_curs;
   FETCH bom_header_curs INTO
      x_out_tbl(2075).datbuf, x_out_tbl(2076).datbuf, x_out_tbl(2077).datbuf,
      x_out_tbl(2078).datbuf, x_out_tbl(2079).datbuf, x_out_tbl(2080).datbuf,
      x_out_tbl(2081).datbuf, x_out_tbl(2082).datbuf, x_out_tbl(2083).datbuf,
      x_out_tbl(2084).datbuf, x_out_tbl(2085).datbuf, x_out_tbl(2086).datbuf,
      x_out_tbl(2087).datbuf, x_out_tbl(2088).datbuf, x_out_tbl(2089).datbuf,
      x_out_tbl(2090).datbuf, x_out_tbl(2091).datbuf, x_out_tbl(2092).datbuf,
      x_out_tbl(2093).datbuf;

   CLOSE bom_header_curs;
/*
   FOR i in 2075..2093 LOOP
      IF (x_out_tbl.EXISTS(i) AND x_out_tbl(i).datbuf IS NOT NULL ) THEN
          IF (l_debug = 1) THEN
             trace('x_out_tbl('||i||')='|| x_out_tbl(i).datbuf );
          END IF;
      END IF;
   END LOOP;
*/

END get_data_bom_bill_header ;

/*=================================================================*/
PROCEDURE get_data_bom_routing(
   x_out_tbl IN OUT NOCOPY output_tbl_type,
   p_inventory_item_id           bom_operational_routings.assembly_item_id%TYPE,
   p_organization_id             bom_operational_routings.organization_id%TYPE,
   p_alternate_routing_designator   bom_operational_routings.alternate_routing_designator%TYPE
)IS

  CURSOR bom_routing_curs IS
SELECT
--bom_rte.routing_sequence_id,
--bom_rte.assembly_item_id,
bom_rte.attribute1,
bom_rte.attribute2,
bom_rte.attribute3,
bom_rte.attribute4,
bom_rte.attribute5,
bom_rte.attribute6,
bom_rte.attribute7,
bom_rte.attribute8,
bom_rte.attribute9,
bom_rte.attribute10,
bom_rte.attribute11,
bom_rte.attribute12,
bom_rte.attribute13,
bom_rte.attribute14,
bom_rte.attribute15,
bom_rte.attribute_category,
bom_rte.routing_comment,
bom_rte_wl.line_code line_code,
bom_rte.total_product_cycle_time,
bom_rte_pp.name project_name,
bom_rte_pt.task_name
FROM BOM_OPERATIONAL_ROUTINGS bom_rte,
     PA_PROJECTS bom_rte_pp, PA_TASKS bom_rte_pt,
     WIP_LINES bom_rte_wl
WHERE bom_rte.assembly_item_id = p_inventory_item_id
AND   bom_rte.organization_id     = p_organization_id
AND  nvl(bom_rte.alternate_routing_designator, '@@@') =   nvl(p_alternate_routing_designator, '@@@')
AND bom_rte.project_id = bom_rte_pp.project_id(+)
AND bom_rte.task_id = bom_rte_pt.task_id(+)
AND bom_rte.line_id = bom_rte_wl.line_id(+);

BEGIN
   IF (l_debug = 1) THEN
      trace('**In get_data_bom_routing() **');
   END IF;
   OPEN bom_routing_curs;
   FETCH bom_routing_curs INTO
      x_out_tbl(2094).datbuf, x_out_tbl(2095).datbuf, x_out_tbl(2096).datbuf,
      x_out_tbl(2097).datbuf, x_out_tbl(2098).datbuf, x_out_tbl(2099).datbuf,
      x_out_tbl(2100).datbuf, x_out_tbl(2101).datbuf, x_out_tbl(2102).datbuf,
      x_out_tbl(2103).datbuf, x_out_tbl(2104).datbuf, x_out_tbl(2105).datbuf,
      x_out_tbl(2106).datbuf, x_out_tbl(2107).datbuf, x_out_tbl(2108).datbuf,
      x_out_tbl(2109).datbuf, x_out_tbl(2110).datbuf, x_out_tbl(2111).datbuf,
      x_out_tbl(2112).datbuf, x_out_tbl(2113).datbuf, x_out_tbl(2114).datbuf;

   CLOSE bom_routing_curs;
/*
   FOR i in 2094..2114 LOOP
      IF (x_out_tbl.EXISTS(i) AND x_out_tbl(i).datbuf IS NOT NULL ) THEN
          IF (l_debug = 1) THEN
             trace('x_out_tbl('||i||')='|| x_out_tbl(i).datbuf );
          END IF;
      END IF;
   END LOOP;
*/
END get_data_bom_routing ;

/*=================================================================*/
PROCEDURE get_data_kanban(
   x_out_tbl IN OUT NOCOPY output_tbl_type,
   p_kanban_card_id IN mtl_kanban_cards.kanban_card_id%TYPE
)IS

CURSOR kanban_curs IS
SELECT
kanban.attribute1,
kanban.attribute2,
kanban.attribute3,
kanban.attribute4,
Kanban.attribute5,
kanban.attribute6,
kanban.attribute7,
kanban.attribute8,
kanban.attribute9,
kanban.attribute10,
kanban.attribute11,
kanban.attribute12,
kanban.attribute13,
kanban.attribute14,
kanban.attribute15,
kanban.attribute_category,
kanban.card_status,
kanban.kanban_card_type,
kanban.created_by,
to_char(kanban.creation_date,G_DATE_FORMAT_MASK),
kanban.last_updated_by,
to_char(kanban.last_update_date,G_DATE_FORMAT_MASK),
kanban_loc.concatenated_segments locator,
kanban.pull_sequence_id,
kanban.kanban_size,
kanban_sloc.concatenated_segments source_locator,
kanban_sorg.organization_code source_organization_code,
kanban.source_subinventory,
kanban.Source_type,
pv.vendor_name supplier,
kanban.supply_status,
kanban.kanban_card_number
FROM MTL_KANBAN_CARDS kanban,
MTL_ITEM_LOCATIONS_KFV kanban_loc,
MTL_ITEM_LOCATIONS_KFV kanban_sloc,
MTL_PARAMETERS kanban_sorg,
MTL_PARAMETERS kanban_org,
PO_VENDORS pv
WHERE kanban.kanban_card_id = p_kanban_card_id
AND kanban.locator_id = kanban_loc.inventory_location_id(+)
AND kanban.source_locator_id = kanban_sloc.inventory_location_id(+)
AND kanban.source_organization_id = kanban_sorg.organization_id
AND kanban.organization_id = kanban_org.organization_id
AND kanban.supplier_id = pv.vendor_id(+);


BEGIN
   IF (l_debug = 1) THEN
      trace('**In get_data_kanban() **');
   END IF;
   OPEN kanban_curs;
   FETCH kanban_curs INTO
     x_out_tbl(1507).datbuf, x_out_tbl(1508).datbuf, x_out_tbl(1509).datbuf,
     x_out_tbl(1510).datbuf, x_out_tbl(1511).datbuf, x_out_tbl(1512).datbuf,
     x_out_tbl(1513).datbuf, x_out_tbl(1514).datbuf, x_out_tbl(1515).datbuf,
     x_out_tbl(1516).datbuf, x_out_tbl(1517).datbuf, x_out_tbl(1518).datbuf,
     x_out_tbl(1519).datbuf, x_out_tbl(1520).datbuf, x_out_tbl(1521).datbuf,
     x_out_tbl(1522).datbuf, x_out_tbl(1523).datbuf, x_out_tbl(1524).datbuf,
     x_out_tbl(1525).datbuf, x_out_tbl(1526).datbuf, x_out_tbl(1527).datbuf,
     x_out_tbl(1528).datbuf, x_out_tbl(1529).datbuf, x_out_tbl(1530).datbuf,
     x_out_tbl(1531).datbuf, x_out_tbl(1532).datbuf, x_out_tbl(1533).datbuf,
     x_out_tbl(1534).datbuf, x_out_tbl(1535).datbuf, x_out_tbl(1536).datbuf,
     x_out_tbl(1537).datbuf, x_out_tbl(1538).datbuf;

   CLOSE kanban_curs;
/*
   FOR i in 1507..1538 LOOP
      IF (x_out_tbl.EXISTS(i) AND x_out_tbl(i).datbuf IS NOT NULL ) THEN
          IF (l_debug = 1) THEN
             trace('x_out_tbl('||i||')='|| x_out_tbl(i).datbuf );
          END IF;
      END IF;
   END LOOP;
*/
END get_data_kanban ;

/*=================================================================*/
PROCEDURE get_data_lot(
   x_out_tbl IN OUT NOCOPY output_tbl_type,
   p_lot_number mtl_lot_numbers.lot_number%TYPE
)IS

CURSOR lot_curs IS
SELECT
lot.lot_number,
lot.age,
to_char(lot.best_by_date,G_DATE_FORMAT_MASK),
lot.c_attribute1,
lot.c_attribute10,
lot.c_attribute11,
lot.c_attribute12,
lot.c_attribute13,
lot.c_attribute14,
lot.c_attribute15,
lot.c_attribute16,
lot.c_attribute17,
lot.c_attribute18,
lot.c_attribute19,
lot.c_attribute2,
lot.c_attribute20,
lot.c_attribute3,
lot.c_attribute4,
lot.c_attribute5,
lot.c_attribute6,
lot.c_attribute7,
lot.c_attribute8,
lot.c_attribute9,
lot.attribute_category,
to_char(lot.change_date,G_DATE_FORMAT_MASK),
lot.color,
lot.d_attribute1,
lot.d_attribute10,
lot.d_attribute2,
lot.d_attribute3,
lot.d_attribute4,
lot.d_attribute5,
lot.d_attribute6,
lot.d_attribute7,
lot.d_attribute8,
lot.d_attribute9,
lot.date_code,
lot.grade_code,
lot.item_size,
lot.length,
lot.length_uom,
to_char(lot.maturity_date,G_DATE_FORMAT_MASK),
lot.n_attribute1,
lot.n_attribute10,
lot.n_attribute2,
lot.n_attribute3,
lot.n_attribute4,
lot.n_attribute5,
lot.n_attribute6,
lot.n_attribute7,
lot.n_attribute8,
lot.n_attribute9,
to_char(lot.origination_date,G_DATE_FORMAT_MASK),
lot.place_of_origin,
lot.recycled_content,
to_char(lot.retest_date,G_DATE_FORMAT_MASK),
lot.thickness,
lot.thickness_uom,
lot.vendor_name supplier,
lot.supplier_lot_number,
lot.volume,
lot.volume_uom,
lot.width,
lot.width_uom,
to_char(lot.expiration_date,G_DATE_FORMAT_MASK),
lot_status.status_code
FROM MTL_LOT_NUMBERS lot,
MTL_MATERIAL_STATUSES_VL     lot_status
WHERE lot.lot_number = p_lot_number
AND lot.status_id = lot_status.status_id (+);

BEGIN
   IF (l_debug = 1) THEN
      trace('**In get_data_lot() **');
   END IF;
   OPEN lot_curs;
   FETCH lot_curs INTO
     x_out_tbl(1539).datbuf, x_out_tbl(1540).datbuf, x_out_tbl(1541).datbuf,
     x_out_tbl(1542).datbuf, x_out_tbl(1543).datbuf, x_out_tbl(1544).datbuf,
     x_out_tbl(1545).datbuf, x_out_tbl(1546).datbuf, x_out_tbl(1547).datbuf,
     x_out_tbl(1548).datbuf, x_out_tbl(1549).datbuf, x_out_tbl(1550).datbuf,
     x_out_tbl(1551).datbuf, x_out_tbl(1552).datbuf, x_out_tbl(1553).datbuf,
     x_out_tbl(1554).datbuf, x_out_tbl(1555).datbuf, x_out_tbl(1556).datbuf,
     x_out_tbl(1557).datbuf, x_out_tbl(1558).datbuf, x_out_tbl(1559).datbuf,
     x_out_tbl(1560).datbuf, x_out_tbl(1561).datbuf, x_out_tbl(1562).datbuf,
     x_out_tbl(1563).datbuf, x_out_tbl(1564).datbuf,
     x_out_tbl(1567).datbuf, x_out_tbl(1568).datbuf,
     x_out_tbl(1569).datbuf, x_out_tbl(1570).datbuf, x_out_tbl(1571).datbuf,
     x_out_tbl(1572).datbuf, x_out_tbl(1573).datbuf, x_out_tbl(1574).datbuf,
     x_out_tbl(1575).datbuf, x_out_tbl(1576).datbuf, x_out_tbl(1577).datbuf,
     x_out_tbl(1578).datbuf, x_out_tbl(1579).datbuf,
     x_out_tbl(1581).datbuf, x_out_tbl(1582).datbuf, x_out_tbl(1583).datbuf,
     x_out_tbl(1584).datbuf, x_out_tbl(1585).datbuf, x_out_tbl(1586).datbuf,
     x_out_tbl(1587).datbuf, x_out_tbl(1588).datbuf, x_out_tbl(1589).datbuf,
     x_out_tbl(1590).datbuf, x_out_tbl(1591).datbuf, x_out_tbl(1592).datbuf,
     x_out_tbl(1593).datbuf, x_out_tbl(1594).datbuf, x_out_tbl(1595).datbuf,
     x_out_tbl(1596).datbuf, x_out_tbl(1597).datbuf, x_out_tbl(1598).datbuf,
     x_out_tbl(1599).datbuf, x_out_tbl(1600).datbuf, x_out_tbl(1601).datbuf,
     x_out_tbl(1602).datbuf, x_out_tbl(1603).datbuf, x_out_tbl(1604).datbuf,
     x_out_tbl(1605).datbuf, x_out_tbl(1606).datbuf, x_out_tbl(1607).datbuf;

     IF lot_curs%NOTFOUND THEN
         trace('New Lot, just populate lot number');
         x_out_tbl(1539).datbuf := p_lot_number;
     END IF;
   CLOSE lot_curs;

/*
   FOR i in 1539..1607 LOOP
      IF (x_out_tbl.EXISTS(i) AND x_out_tbl(i).datbuf IS NOT NULL ) THEN
          IF (l_debug = 1) THEN
             trace('x_out_tbl('||i||')='|| x_out_tbl(i).datbuf );
          END IF;
      END IF;
   END LOOP;
*/
END get_data_lot ;

/*=================================================================*/
PROCEDURE get_data_serial(
   x_out_tbl IN OUT NOCOPY output_tbl_type,
   p_inventory_item_id mtl_serial_numbers.inventory_item_id%TYPE,
   p_serial_number mtl_serial_numbers.serial_number%TYPE
)IS

CURSOR serial_curs IS
SELECT
serial.c_attribute1,
serial.c_attribute2,
serial.c_attribute3,
serial.c_attribute4,
serial.c_attribute5,
serial.c_attribute6,
serial.c_attribute7,
serial.c_attribute8,
serial.c_attribute9,
serial.c_attribute10,
serial.c_attribute11,
serial.c_attribute12,
serial.c_attribute13,
serial.c_attribute14,
serial.c_attribute15,
serial.c_attribute16,
serial.c_attribute17,
serial.c_attribute18,
serial.c_attribute19,
serial.c_attribute20,
serial.attribute_category,
to_date(serial.completion_date,G_DATE_FORMAT_MASK),
serial.cycles_since_mark,
serial.cycles_since_new,
serial.cycles_since_overhaul,
serial.cycles_since_repair,
serial.cycles_since_visit,
serial.d_attribute1,
serial.d_attribute10,
serial.d_attribute2,
serial.d_attribute3,
serial.d_attribute4,
serial.d_attribute5,
serial.d_attribute6,
serial.d_attribute7,
serial.d_attribute8,
serial.d_attribute9,
serial.fixed_asset_tag,
to_char(serial.initialization_date,G_DATE_FORMAT_MASK),
serial.n_attribute1,
serial.n_attribute2,
serial.n_attribute3,
serial.n_attribute4,
serial.n_attribute5,
serial.n_attribute6,
serial.n_attribute7,
serial.n_attribute8,
serial.n_attribute9,
serial.n_attribute10,
serial.number_of_repairs,
to_char(serial.origination_date,G_DATE_FORMAT_MASK),
serial.time_since_mark,
serial.time_since_new,
serial.time_since_overhaul,
serial.time_since_repair,
serial.time_since_visit,
serial.vendor_serial_number,
serial.serial_number,
serial_status.status_code
FROM MTL_SERIAL_NUMBERS serial,
MTL_MATERIAL_STATUSES_VL     serial_status
WHERE serial.inventory_item_id = p_inventory_item_id
AND serial.serial_number = p_serial_number
AND serial.status_id = serial_status.status_id (+);

BEGIN
   IF (l_debug = 1) THEN
      trace('**In get_data_serial() **');
   END IF;
   OPEN serial_curs;
   FETCH serial_curs INTO
      x_out_tbl(1609).datbuf, x_out_tbl(1610).datbuf, x_out_tbl(1611).datbuf,
      x_out_tbl(1612).datbuf, x_out_tbl(1613).datbuf, x_out_tbl(1614).datbuf,
      x_out_tbl(1615).datbuf, x_out_tbl(1616).datbuf, x_out_tbl(1617).datbuf,
      x_out_tbl(1618).datbuf, x_out_tbl(1619).datbuf, x_out_tbl(1620).datbuf,
      x_out_tbl(1621).datbuf,
      x_out_tbl(1622).datbuf, x_out_tbl(1623).datbuf, x_out_tbl(1624).datbuf,
      x_out_tbl(1625).datbuf, x_out_tbl(1626).datbuf, x_out_tbl(1627).datbuf,
      x_out_tbl(1628).datbuf, x_out_tbl(1629).datbuf, x_out_tbl(1630).datbuf,
      x_out_tbl(1631).datbuf, x_out_tbl(1632).datbuf, x_out_tbl(1633).datbuf,
      x_out_tbl(1634).datbuf, x_out_tbl(1635).datbuf, x_out_tbl(1636).datbuf,
      x_out_tbl(1637).datbuf, x_out_tbl(1638).datbuf, x_out_tbl(1639).datbuf,
      x_out_tbl(1640).datbuf, x_out_tbl(1641).datbuf, x_out_tbl(1642).datbuf,
      x_out_tbl(1643).datbuf, x_out_tbl(1644).datbuf, x_out_tbl(1645).datbuf,
      x_out_tbl(1646).datbuf, x_out_tbl(1647).datbuf, x_out_tbl(1648).datbuf,
      x_out_tbl(1649).datbuf, x_out_tbl(1650).datbuf,
      x_out_tbl(1651).datbuf, x_out_tbl(1652).datbuf,
      x_out_tbl(1653).datbuf, x_out_tbl(1654).datbuf, x_out_tbl(1655).datbuf,
      x_out_tbl(1656).datbuf, x_out_tbl(1657).datbuf, x_out_tbl(1658).datbuf,
      x_out_tbl(1659).datbuf, x_out_tbl(1660).datbuf, x_out_tbl(1661).datbuf,
      x_out_tbl(1662).datbuf, x_out_tbl(1663).datbuf, x_out_tbl(1664).datbuf,
      x_out_tbl(1665).datbuf, x_out_tbl(1666).datbuf, x_out_tbl(1667).datbuf;


   CLOSE serial_curs;
/*
   FOR i in 1609..1667 LOOP
      IF (x_out_tbl.EXISTS(i) AND x_out_tbl(i).datbuf IS NOT NULL ) THEN
          IF (l_debug = 1) THEN
             trace('x_out_tbl('||i||')='|| x_out_tbl(i).datbuf );
          END IF;
      END IF;
   END LOOP;
*/

END get_data_serial ;

/*=================================================================*/
PROCEDURE get_data_LPN(
   x_out_tbl IN OUT NOCOPY output_tbl_type,
   p_lpn_id  wms_license_plate_numbers.lpn_id%TYPE,
   p_revision wms_lpn_contents.revision%TYPE,
   p_lot_number wms_lpn_contents.lot_number%TYPE,
   p_serial_number wms_lpn_contents.serial_number%TYPE,
   p_inventory_item_id  wms_lpn_contents.inventory_item_id%TYPE
)IS

CURSOR lpn_curs IS
SELECT
lpn.license_plate_number  license_plate_number,
lpn_msik1.concatenated_segments  lpn_container_item,
lpn.attribute1,
lpn.attribute2,
lpn.attribute3,
lpn.attribute4,
lpn.attribute5,
lpn.attribute6,
lpn.attribute7,
lpn.attribute8,
lpn.attribute9,
lpn.attribute10,
lpn.attribute11,
lpn.attribute12,
lpn.attribute13,
lpn.attribute14,
lpn.attribute15,
lpn.attribute_category,
lpn.gross_weight   gross_weight,
lpn.gross_weight_uom_code  gross_weight_uom,
0 number_of_total,
lpn.tare_weight    tare_weight,
lpn.tare_weight_uom_code  tare_weight_uom,
0 total_of_total,
lpn.content_volume  volume,
lpn.content_volume_uom_code  volume_uom,
lpn_mp.organization_code	organization,
lpn_msik2.concatenated_segments  item,
lpn_msik2.description    item_description,
lpn_wlc.revision revision,
lpn_wlc.lot_number lot,
NVL(lpn_wlc.serial_number, p_serial_number)  serial_number,
decode(p_serial_number, NULL, lpn_wlc.quantity,
       decode(lpn_wlc.serial_summary_entry, 1, 1, lpn_wlc.quantity)) quantity,
lpn_wlc.uom_code
FROM wms_license_plate_numbers lpn,
     wms_license_plate_numbers lpn_pLpn,
     mtl_system_items_kfv lpn_msik1,
     mtl_system_items_kfv lpn_msik2,
     mtl_parameters lpn_mp,
     wms_lpn_contents lpn_wlc
WHERE lpn.lpn_id                           = p_lpn_id
AND   lpn.parent_lpn_id                    = lpn_pLpn.lpn_id(+)
AND   lpn_wlc.parent_lpn_id(+)             = p_lpn_id
AND   nvl(lpn_wlc.revision, '$$$')         = nvl(p_revision, nvl(lpn_wlc.revision, '$$$'))
AND   nvl(lpn_wlc.lot_number, '$$$')    = nvl(p_lot_number, nvl(lpn_wlc.lot_number, '$$$'))
--AND   nvl(lpn_wlc.serial_number,'$$$')  = nvl(p_serial_number,nvl(lpn_wlc.serial_number,'$$$'))
AND   lpn_wlc.inventory_item_id           = p_inventory_item_id
AND   lpn_msik1.inventory_item_id (+) = lpn.inventory_item_id
AND   lpn_msik1.organization_id  (+)  	 = lpn.organization_id
AND   lpn_mp.organization_id      	 = lpn.organization_id
AND   lpn_msik2.inventory_item_id(+)  = lpn_wlc.inventory_item_id
AND   lpn_msik2.organization_id(+)   	 = lpn_wlc.organization_id;


BEGIN
   IF (l_debug = 1) THEN
      trace('**In get_data_LPN() **');
   END IF;
   OPEN lpn_curs;
   FETCH lpn_curs INTO
x_out_tbl(2041).datbuf, x_out_tbl(2042).datbuf, x_out_tbl(2043).datbuf,
x_out_tbl(2044).datbuf, x_out_tbl(2045).datbuf, x_out_tbl(2046).datbuf,
x_out_tbl(2047).datbuf, x_out_tbl(2048).datbuf, x_out_tbl(2049).datbuf,
x_out_tbl(2050).datbuf, x_out_tbl(2051).datbuf, x_out_tbl(2052).datbuf,
x_out_tbl(2053).datbuf, x_out_tbl(2054).datbuf, x_out_tbl(2055).datbuf,
x_out_tbl(2056).datbuf, x_out_tbl(2057).datbuf, x_out_tbl(2058).datbuf,
x_out_tbl(2059).datbuf, x_out_tbl(2060).datbuf, x_out_tbl(2061).datbuf,
x_out_tbl(2062).datbuf, x_out_tbl(2063).datbuf, x_out_tbl(2064).datbuf,
x_out_tbl(2065).datbuf, x_out_tbl(2066).datbuf, x_out_tbl(2067).datbuf,
x_out_tbl(2068).datbuf, x_out_tbl(2069).datbuf, x_out_tbl(2070).datbuf,
x_out_tbl(2071).datbuf, x_out_tbl(2072).datbuf, x_out_tbl(2073).datbuf,
x_out_tbl(2074).datbuf;


/*
   CLOSE lpn_curs;
   FOR i in 2041..2074 LOOP
      IF (x_out_tbl.EXISTS(i) AND x_out_tbl(i).datbuf IS NOT NULL ) THEN
          IF (l_debug = 1) THEN
             trace('x_out_tbl('||i||')='|| x_out_tbl(i).datbuf );
          END IF;
      END IF;
   END LOOP;
*/

END get_data_LPN ;

/*=================================================================*/
PROCEDURE get_data_sale_header(
   x_out_tbl IN OUT NOCOPY output_tbl_type,
   p_header_id oe_order_headers_all.header_id%TYPE ,
   p_line_id oe_order_lines_all.line_id%TYPE

)IS

--
-- Modification Start for Bug # - 4418524
--
-- As part of TCA related changes ra_customers, ra_contacts views are
-- obsoleted in R12. The columns fetched from these views are fetched
-- from "HZ_PARTIES", "HZ_CUST_ACCOUNTS", "HZ_CUST_ACCOUNT_ROLES",
-- "HZ_CUST_ACCOUNTS", "HZ_RELATIONSHIPS".
--
-- Following declarations are commented.
--
--l_customer_id  ra_customers.customer_id%TYPE;
--l_party_id  ra_customers.party_id%TYPE;
--l_party_number  ra_customers.party_number%TYPE;
--l_customer_name       ra_customers.customer_name%TYPE;
--l_invoice_customer_id            ra_customers.customer_id%TYPE;
--l_deliver_customer_id            ra_customers.customer_id%TYPE;
--l_ship_to_customer_id            ra_customers.customer_id%TYPE;
--
-- Following declarations are added to replace the above commented
-- declarations
--
l_customer_id                   hz_cust_accounts.cust_account_id%TYPE;
l_party_id                      hz_parties.party_id%TYPE;
l_party_number                  hz_parties.party_number%TYPE;
l_customer_name                 hz_parties.party_name%TYPE;
l_invoice_customer_id           hz_cust_accounts.cust_account_id%TYPE;
l_deliver_customer_id           hz_cust_accounts.cust_account_id%TYPE;
l_ship_to_customer_id           hz_cust_accounts.cust_account_id%TYPE;
--
-- Modification End for Bug # - 4418524
--


l_sold_from_org_id   oe_order_headers_all.sold_from_org_id%TYPE;
l_sold_to_org_id     oe_order_headers_all.sold_to_org_id%TYPE;
l_ship_from_org_id   oe_order_headers_all.ship_from_org_id%TYPE;
l_ship_to_org_id     oe_order_headers_all.ship_to_org_id%TYPE;
l_invoice_to_org_id   oe_order_headers_all.invoice_to_org_id%TYPE;
l_deliver_to_org_id   oe_order_headers_all.deliver_to_org_id%TYPE;
l_organization_code   mtl_parameters.organization_code%TYPE;
l_location_id         hz_locations.location_id%TYPE;
l_location_name       hz_cust_site_uses_all.location%TYPE;
l_organization_name   org_organization_definitions.organization_name%TYPE;
l_customer_number     hz_cust_accounts.account_number%TYPE;
l_sold_from_location_id  hz_locations.location_id%TYPE;
l_sold_to_location_id  hz_locations.location_id%TYPE;
l_ship_from_location_id  hz_locations.location_id%TYPE;
l_ship_to_location_id  hz_locations.location_id%TYPE;
l_invoice_to_location_id  hz_locations.location_id%TYPE;
l_deliver_to_location_id  hz_locations.location_id%TYPE;
l_ship_from_organization_code    mtl_parameters.organization_code%TYPE;
l_ship_to_organization_code       mtl_parameters.organization_code%TYPE;
l_sold_from_organization_code    mtl_parameters.organization_code%TYPE;
l_sold_to_organization_code      mtl_parameters.organization_code%TYPE;
l_invoice_to_organization_code    mtl_parameters.organization_code%TYPE;
l_deliver_to_organization_code   mtl_parameters.organization_code%TYPE;
l_address5                       hz_locations.address4%TYPE;
l_header_id                oe_order_headers_all.header_id%TYPE := p_header_id;


 CURSOR oe_header_curs IS
   SELECT
     ohead_mp.organization_code,
     to_char(Ohead.booked_date,G_DATE_FORMAT_MASK),
     Ohead.credit_card_holder_name,
     Ohead.credit_card_number,
     to_char(Ohead.expiration_date,G_DATE_FORMAT_MASK),
     ohead.attribute1,
     ohead.attribute10,
     ohead.attribute11,
     ohead.attribute12,
     ohead.attribute13,
     ohead.attribute14,
     ohead.attribute15,
     ohead.attribute2,
     ohead.attribute3,
     ohead.attribute4,
     ohead.attribute5,
     ohead.attribute6,
     ohead.attribute7,
     ohead.attribute8,
     ohead.attribute9,
     ohead.global_attribute_category,
     ohead.global_attribute1,
     ohead.global_attribute10,
     ohead.global_attribute11,
     ohead.global_attribute12,
     ohead.global_attribute13,
     ohead.global_attribute14,
     ohead.global_attribute15,
     ohead.global_attribute16,
     ohead.global_attribute17,
     ohead.global_attribute18,
     ohead.global_attribute19,
     ohead.global_attribute2,
     ohead.global_attribute20,
     ohead.global_attribute3,
     ohead.global_attribute4,
     ohead.global_attribute5,
     ohead.global_attribute6,
     ohead.global_attribute7,
     ohead.global_attribute8,
     ohead.global_attribute9,
     Ohead.order_number,
     Ohead.return_reason_code,
     to_char(Ohead.ordered_date,G_DATE_FORMAT_MASK),
     ohead_rcs.customer_name,
     ohead_rcs.person_first_name,
     ohead_rcs.person_last_name,
     ohead_rcs.person_middle_name,
     ohead_rcs.customer_type,
     ohead_rcs.customer_id,
     ohead_rcs.party_id,
     ohead_rcs.party_number,
     ohead.sold_from_org_id,
     ohead.sold_to_org_id,
     ohead.ship_to_org_id,
     ohead.ship_from_org_id,
     ohead.invoice_to_org_id,
     ohead.deliver_to_org_id
   FROM OE_ORDER_HEADERS_ALL ohead
     , MTL_PARAMETERS ohead_mp
     --
     -- Modification Start for Bug # - 4418524
     --
     -- As part of TCA related changes ra_customers, ra_contacts views are
     -- obsoleted in R12. The columns fetched from these views are fetched
     -- from hz_parties and hz_cust_accounts.
     --
     -- Following table alias are commented
     --,  ra_customers                 ohead_rcs
     --
     -- Following Queries are added to replace the above commented
     -- views
     --
     ,  ( SELECT CUST_ACCT.cust_account_id customer_id,
                 PARTY.party_id party_id,
                 PARTY.party_number party_number,
	         SUBSTRB(PARTY.party_name,1,50) customer_name,
                 PARTY.person_first_name person_first_name,
                 PARTY.person_middle_name person_middle_name,
                 PARTY.person_last_name person_last_name,
	         CUST_ACCT.customer_type customer_type
	  FROM hz_parties PARTY
             , hz_cust_accounts CUST_ACCT
          WHERE CUST_ACCT.party_id = PARTY.party_id
	) ohead_rcs
      --
      -- Modification End for Bug # - 4418524
      --
     WHERE ohead.header_id = l_header_id
     AND   ohead.org_id   = ohead_mp.organization_id
     AND ohead.sold_to_org_id = ohead_rcs.customer_id(+);

-- ======================
-- OE lines Cursor
-- ======================
CURSOR oe_lines_curs IS
SELECT
  oline.booked_flag,
  oline.cancelled_flag,
  oline.component_code,
  oline.cust_po_number,
  to_char(oline.earliest_acceptable_date,G_DATE_FORMAT_MASK),
  to_char(oline.explosion_date, G_DATE_FORMAT_MASK),
  oline.freight_carrier_code,
  to_char(oline.latest_acceptable_date, G_DATE_FORMAT_MASK),
  Oline.open_flag,
  to_char(oline.actual_shipment_date, G_DATE_FORMAT_MASK),
  oline.created_by,
  oline.last_updated_by,
  to_char(oline.last_update_date, G_DATE_FORMAT_MASK),
  oline.attribute1,
  oline.attribute2,
  oline.attribute3,
  oline.attribute4,
  oline.attribute5,
  oline.attribute6,
  oline.attribute7,
  oline.attribute8,
  oline.attribute9,
  oline.attribute10,
  oline.attribute11,
  oline.attribute12,
  oline.attribute13,
  oline.attribute14,
  oline.attribute15,
  oline.return_attribute1,
  oline.return_attribute2,
  oline.return_attribute3,
  oline.return_attribute4,
  oline.return_attribute5,
  oline.return_attribute6,
  oline.return_attribute7,
  oline.return_attribute8,
  oline.return_attribute9,
  oline.return_attribute10,
  oline.return_attribute11,
  oline.return_attribute12,
  oline.return_attribute13,
  oline.return_attribute14,
  oline.return_attribute15,
  oline.return_context,
  oline.context,
  to_char(oline.creation_date, G_DATE_FORMAT_MASK),
  oline.fulfilled_quantity,
  oline.ordered_item,
  oline.line_number,
  oline.ordered_quantity,
  to_char(oline.promise_date, G_DATE_FORMAT_MASK),
  oline.order_quantity_uom,
  to_char(oline.request_date, G_DATE_FORMAT_MASK),
  to_char(oline.schedule_ship_date, G_DATE_FORMAT_MASK),
  oline.shipped_quantity,
  oline.shipping_quantity,
  oline.shipping_quantity_uom,
  oline.over_ship_reason_code,
  oline.packing_instructions,
  pp.name  project_name,
  ras.name salesreps_name,
  to_char(oline.schedule_arrival_date, G_DATE_FORMAT_MASK),
  oe_sets.set_name ship_set_name,
  osmv.meaning shipping_method_name,
  ar_lookups.meaning tax_exempt_reason,
  oline.tax_code,
  oline.tax_exempt_flag,
  oline.tax_exempt_number,
  oline.tax_rate,
  oline.shipment_number,
  oline.shipping_instructions,
  --rcship.last_name,
  LTRIM(rcship.last_name ||decode(rcship.first_name,NULL,NULL,','||rcship.first_name)) ship_to_contact_name,
  LTRIM(isc.last_name || decode(isc.first_name,NULL,NULL,','|| isc.first_name)) intmed_ship_to_contact_name,
  LTRIM(invc.last_name || decode(invc.first_name,NULL,NULL,','|| invc.first_name)) invoice_to_contact_name,
  LTRIM(dcontact.last_name || decode(dcontact.first_name,NULL,NULL,','|| dcontact.first_name)) deliver_to_contact_name,
  oline_rc.customer_name,
  oline_rc.person_first_name,
  oline_rc.person_last_name,
  oline_rc.person_middle_name,
  oline_rc.customer_type,
  oline_rc.customer_id,
  oline_rc.party_id,
  oline_rc.party_number,
  oline.sold_from_org_id,
  oline.sold_to_org_id,
  oline.ship_from_org_id,
  oline.ship_to_org_id,
  oline.invoice_to_org_id,
  oline.deliver_to_org_id,
  shiptoc.customer_id ship_to_customer_id,
  dcontact.customer_id delivery_customer_id,
  invc.customer_id invoice_customer_id,
  oline.header_id
  -- ship_from_org.organization_code
FROM OE_ORDER_LINES_ALL oline,
  OE_SHIP_METHODS_V osmv
  --
  -- Modification Start for Bug # - 4418524
  --
  -- As part of TCA related changes ra_customers, ra_contacts views are
  -- obsoleted in R12. The columns fetched from these views are fetched
  -- from "HZ_PARTIES", "HZ_CUST_ACCOUNTS", "HZ_CUST_ACCOUNT_ROLES",
  -- "HZ_CUST_ACCOUNTS", "HZ_RELATIONSHIPS".
  --
  -- Following six table alias are commented
  --,  ra_customers                 oline_rc
  --,  ra_contacts                  rcship
  --,  ra_contacts                  dcontact
  --,  ra_contacts                  isc
  --,  ra_contacts                  invc
  --,  ra_contacts                  shiptoc
  --
  -- Following 4 Queries are added to replace the above commented
  -- views
  --
  ,  ( SELECT CUST_ACCT.cust_account_id customer_id,
              PARTY.party_id party_id,
              PARTY.party_number party_number,
	      SUBSTRB(PARTY.party_name,1,50) customer_name,
              PARTY.person_first_name person_first_name,
              PARTY.person_middle_name person_middle_name,
              PARTY.person_last_name person_last_name,
	      CUST_ACCT.customer_type customer_type
       FROM hz_parties PARTY
          , hz_cust_accounts CUST_ACCT
       WHERE CUST_ACCT.party_id = PARTY.party_id
     ) oline_rc
  ,  ( SELECT ACCT_ROLE.cust_account_role_id        contact_id,
            ACCT_ROLE.cust_account_id customer_id,
            SUBSTRB(PARTY.person_last_name,1,50)  last_name,
            SUBSTRB(PARTY.person_first_name,1,40) first_name
       FROM hz_cust_account_roles ACCT_ROLE,
            hz_parties PARTY,
            hz_relationships REL,
            hz_cust_accounts ROLE_ACCT
       WHERE
             ACCT_ROLE.party_id = REL.party_id
         AND ACCT_ROLE.role_type = 'CONTACT'
         AND REL.subject_id = PARTY.party_id
         AND REL.subject_table_name = 'HZ_PARTIES'
         AND REL.object_table_name = 'HZ_PARTIES'
         AND ACCT_ROLE.cust_account_id = ROLE_ACCT.cust_account_id
         AND ROLE_ACCT.party_id = REL.object_id
   ) rcship
  ,  ( SELECT ACCT_ROLE.cust_account_role_id        contact_id,
            ACCT_ROLE.cust_account_id customer_id,
            SUBSTRB(PARTY.person_last_name,1,50)  last_name,
            SUBSTRB(PARTY.person_first_name,1,40) first_name
       FROM hz_cust_account_roles ACCT_ROLE,
            hz_parties PARTY,
            hz_relationships REL,
            hz_cust_accounts ROLE_ACCT
       WHERE
             ACCT_ROLE.party_id = REL.party_id
         AND ACCT_ROLE.role_type = 'CONTACT'
         AND REL.subject_id = PARTY.party_id
         AND REL.subject_table_name = 'HZ_PARTIES'
         AND REL.object_table_name = 'HZ_PARTIES'
         AND ACCT_ROLE.cust_account_id = ROLE_ACCT.cust_account_id
         AND ROLE_ACCT.party_id = REL.object_id
   ) dcontact
  ,  ( SELECT ACCT_ROLE.cust_account_role_id        contact_id,
            ACCT_ROLE.cust_account_id customer_id,
            SUBSTRB(PARTY.person_last_name,1,50)  last_name,
            SUBSTRB(PARTY.person_first_name,1,40) first_name
       FROM hz_cust_account_roles ACCT_ROLE,
            hz_parties PARTY,
            hz_relationships REL,
            hz_cust_accounts ROLE_ACCT
       WHERE
             ACCT_ROLE.party_id = REL.party_id
         AND ACCT_ROLE.role_type = 'CONTACT'
         AND REL.subject_id = PARTY.party_id
         AND REL.subject_table_name = 'HZ_PARTIES'
         AND REL.object_table_name = 'HZ_PARTIES'
         AND ACCT_ROLE.cust_account_id = ROLE_ACCT.cust_account_id
         AND ROLE_ACCT.party_id = REL.object_id
   ) isc
  ,  ( SELECT ACCT_ROLE.cust_account_role_id        contact_id,
            ACCT_ROLE.cust_account_id customer_id,
            SUBSTRB(PARTY.person_last_name,1,50)  last_name,
            SUBSTRB(PARTY.person_first_name,1,40) first_name
       FROM hz_cust_account_roles ACCT_ROLE,
            hz_parties PARTY,
            hz_relationships REL,
            hz_cust_accounts ROLE_ACCT
       WHERE
             ACCT_ROLE.party_id = REL.party_id
         AND ACCT_ROLE.role_type = 'CONTACT'
         AND REL.subject_id = PARTY.party_id
         AND REL.subject_table_name = 'HZ_PARTIES'
         AND REL.object_table_name = 'HZ_PARTIES'
         AND ACCT_ROLE.cust_account_id = ROLE_ACCT.cust_account_id
         AND ROLE_ACCT.party_id = REL.object_id
   ) invc
  ,  ( SELECT ACCT_ROLE.cust_account_role_id        contact_id,
            ACCT_ROLE.cust_account_id customer_id,
            SUBSTRB(PARTY.person_last_name,1,50)  last_name,
            SUBSTRB(PARTY.person_first_name,1,40) first_name
       FROM hz_cust_account_roles ACCT_ROLE,
            hz_parties PARTY,
            hz_relationships REL,
            hz_cust_accounts ROLE_ACCT
       WHERE
             ACCT_ROLE.party_id = REL.party_id
         AND ACCT_ROLE.role_type = 'CONTACT'
         AND REL.subject_id = PARTY.party_id
         AND REL.subject_table_name = 'HZ_PARTIES'
         AND REL.object_table_name = 'HZ_PARTIES'
         AND ACCT_ROLE.cust_account_id = ROLE_ACCT.cust_account_id
         AND ROLE_ACCT.party_id = REL.object_id
   ) shiptoc,
  --
  -- Modification End for Bug # - 4418524
  --
  PA_PROJECTS pp,
  --ORG_FREIGHT_VL ofv,
  RA_SALESREPS ras,
  OE_SETS,
  AR_LOOKUPS,
  MTL_PARAMETERS ship_from_org
WHERE oline.line_id = p_line_id
  AND oline.sold_to_org_id = oline_rc.customer_id(+)
  AND oline.deliver_to_contact_id = dcontact.contact_id(+)
  AND oline.ship_to_contact_id = shiptoc.contact_id(+)
  AND oline.invoice_to_contact_id = invc.contact_id(+)
  AND oline.intmed_ship_to_contact_id = isc.contact_id(+)
  AND oline.salesrep_id = ras.salesrep_id(+)
  AND oline.ship_set_id = oe_sets.set_id(+)
  AND oline.ship_to_contact_id = rcship.contact_id(+)
  AND oline.shipping_method_code = osmv.lookup_code(+)
  AND oline.tax_exempt_reason_code = ar_lookups.lookup_code(+)
  and ar_lookups.lookup_type(+) = 'TAX_REASON'
  AND oline.project_id =pp.project_id(+)
  AND oline.ship_from_org_id = ship_from_org.organization_id(+);
  --AND oline.freight_carrier_code = ofv.freight_code(+)

-- ===================================================

CURSOR loc_curs (c_location_id NUMBER) IS
SELECT
loc.address_line_1,
loc.address_line_2,
loc.address_line_3,
decode(LOC.CITY,null, null, LOC.CITY|| ', ')
||decode(LOC.state, null, null, LOC.state || ', ') ||
decode(LOC.postal_code,null, null, LOC.postal_code || ', ') ||
decode(LOC.country, null, null, LOC.country) address_line_4 ,
-- loc.address_line_4 address_line_5,
loc.country,
loc.postal_code,
loc.county,
loc.state,
loc.province,
loc.city ,
loc.telephone_number_1
--loc.description
FROM (
  SELECT loc.location_id location_id,
        loc.address_line_1 address_line_1,
          loc.address_line_2 address_line_2,loc.address_line_3 address_line_3,
          loc.loc_information13 address_line_4,
          loc.town_or_city city,loc.postal_code postal_code,
          loc.region_2 state,loc.region_1 county,
          loc.country country,loc.region_3 province,
          loc.location_code location_code,loc.description description,
          loc.telephone_number_1
   FROM hr_locations_all loc
   UNION ALL
   SELECT hz.location_id location_id,
          hz.address1    address_line_1,
          hz.address2    address_line_2,hz.address3  address_line_3,
          hz.address4    address_line_4,
          hz.city city,hz.postal_code postal_code,
          hz.state state,hz.county county,
          hz.country country,hz.province province,
          hz.description location_code, hz.description description,
          NULL telephone_number_1
   FROM hz_locations hz
) LOC
WHERE location_id = c_location_id;

CURSOR customer_site(c_site_use_code VARCHAR2,
                c_site_use_id NUMBER, c_customer_id NUMBER)  IS
SELECT   /*+ INDEX(ACCT_SITE,HZ_CUST_ACCT_SITES_N2) */
party_site.location_id,
site.location location_code,
org.organization_code,
org.organization_name
--cust_acct.account_number customer_Number,
--cust_acct.customer_type,
--party.party_name customer_name
--site.site_use_code,
--site.site_use_id,
--site.org_Id organization_id,
--cust_acct.cust_account_id customer_id
FROM
     HZ_CUST_ACCT_SITES_ALL     ACCT_SITE,
     HZ_PARTY_SITES             PARTY_SITE,
     HZ_CUST_SITE_USES_ALL      SITE,
     HZ_PARTIES           PARTY,
     HZ_CUST_ACCOUNTS      CUST_ACCT,
     ORG_ORGANIZATION_DEFINITIONS        ORG
WHERE SITE.ORG_ID                  = ORG.ORGANIZATION_ID
AND   SITE.CUST_ACCT_SITE_ID     = ACCT_SITE.CUST_ACCT_SITE_ID
AND   ACCT_SITE.PARTY_SITE_ID    = PARTY_SITE.PARTY_SITE_ID
and    acct_site.status='A'
AND ACCT_SITE.CUST_ACCOUNT_ID=CUST_ACCT.CUST_ACCOUNT_ID
AND CUST_ACCT.PARTY_ID=PARTY.PARTY_ID
AND CUST_ACCT.status='A'
AND site.status='A'
AND SITE.SITE_USE_CODE         = c_site_use_code
AND CUST_ACCT.CUST_ACCOUNT_ID = c_customer_id
AND SITE.SITE_USE_ID = c_site_use_id;

-- ==================================================

CURSOR from_org_curs (c_organization_id NUMBER) IS
   SELECT hou.location_id,
          mp.organization_code
        --  hou.name organization_name,
        --  hou.organization_id
   FROM hr_organization_units hou,
        mtl_parameters mp,
        hr_organization_information hoi1
WHERE hou.ORGANIZATION_ID = mp.ORGANIZATION_ID
AND hou.ORGANIZATION_ID = hoi1.ORGANIZATION_id
AND hoi1.ORG_INFORMATION1= 'INV'
AND hoi1.ORG_INFORMATION2 = 'Y'
AND mp.organization_id = c_organization_id;



BEGIN
   IF (l_debug = 1) THEN
      trace('**In get_data_sale_header() **');
      trace('p_header_id : ' || p_header_id);
      trace('p_line_id : ' || p_line_id);
   END IF;



  IF (p_line_id IS NOT NULL) THEN

     /* ================================== */
     /* Retrieve data for sale order line  */
     /* ================================== */
      IF (l_debug = 1) THEN
         trace('**Retrieve Sale Line data ... **');
      END IF;
      OPEN oe_lines_curs;
      FETCH oe_lines_curs INTO
      x_out_tbl(1876).datbuf, x_out_tbl(1877).datbuf, x_out_tbl(1878).datbuf,
      x_out_tbl(1879).datbuf, x_out_tbl(1880).datbuf, x_out_tbl(1881).datbuf,
      x_out_tbl(1882).datbuf, x_out_tbl(1883).datbuf, x_out_tbl(1884).datbuf,
      x_out_tbl(1885).datbuf, x_out_tbl(1886).datbuf, x_out_tbl(1887).datbuf,
      x_out_tbl(1888).datbuf, x_out_tbl(1889).datbuf, x_out_tbl(1890).datbuf,
      x_out_tbl(1891).datbuf, x_out_tbl(1892).datbuf, x_out_tbl(1893).datbuf,
      x_out_tbl(1894).datbuf, x_out_tbl(1895).datbuf, x_out_tbl(1896).datbuf,
      x_out_tbl(1897).datbuf, x_out_tbl(1898).datbuf, x_out_tbl(1899).datbuf,
      x_out_tbl(1900).datbuf, x_out_tbl(1901).datbuf, x_out_tbl(1902).datbuf,
      x_out_tbl(1903).datbuf, x_out_tbl(1904).datbuf, x_out_tbl(1905).datbuf,
      x_out_tbl(1906).datbuf, x_out_tbl(1907).datbuf, x_out_tbl(1908).datbuf,
      x_out_tbl(1909).datbuf, x_out_tbl(1910).datbuf, x_out_tbl(1911).datbuf,
      x_out_tbl(1912).datbuf, x_out_tbl(1913).datbuf, x_out_tbl(1914).datbuf,
      x_out_tbl(1915).datbuf, x_out_tbl(1916).datbuf, x_out_tbl(1917).datbuf,
      x_out_tbl(1918).datbuf, x_out_tbl(1919).datbuf, x_out_tbl(1920).datbuf,
      x_out_tbl(1921).datbuf, x_out_tbl(1922).datbuf, x_out_tbl(1923).datbuf,
      x_out_tbl(1924).datbuf, x_out_tbl(1925).datbuf, x_out_tbl(1926).datbuf,
      x_out_tbl(1927).datbuf, x_out_tbl(1928).datbuf, x_out_tbl(1929).datbuf,
      x_out_tbl(1930).datbuf, x_out_tbl(1931).datbuf, x_out_tbl(1932).datbuf,
      x_out_tbl(1933).datbuf, x_out_tbl(1934).datbuf, x_out_tbl(1935).datbuf,
      x_out_tbl(1936).datbuf, x_out_tbl(1937).datbuf, x_out_tbl(1938).datbuf,
      x_out_tbl(1939).datbuf, x_out_tbl(1940).datbuf, x_out_tbl(1941).datbuf,
      x_out_tbl(1942).datbuf, x_out_tbl(1943).datbuf, x_out_tbl(1944).datbuf,
      x_out_tbl(1945).datbuf, x_out_tbl(1946).datbuf, x_out_tbl(1947).datbuf,
      x_out_tbl(1948).datbuf, x_out_tbl(1949).datbuf, x_out_tbl(1950).datbuf,
      x_out_tbl(1951).datbuf, x_out_tbl(1952).datbuf, x_out_tbl(1953).datbuf,
      x_out_tbl(1954).datbuf, x_out_tbl(1955).datbuf,
      l_customer_id, l_party_id, l_party_number,
      l_sold_from_org_id, l_sold_to_org_id, l_ship_from_org_id,
      l_ship_to_org_id,l_invoice_to_org_id, l_deliver_to_org_id,
      l_ship_to_customer_id,l_deliver_customer_id, l_invoice_customer_id,
      l_header_id;

      CLOSE oe_lines_curs;
   --   trace('l_sold_from_org_id : ' || l_sold_from_org_id);
   --   trace('l_sold_to_org_id : ' || l_sold_to_org_id);
   --   trace('l_ship_to_org_id : ' || l_ship_to_org_id);
   --   trace('l_ship_from_org_id : ' || l_ship_from_org_id);
   --   trace('l_invoice_to_org_id : ' || l_invoice_to_org_id);
   --   trace('l_deliver_to_org_id : ' || l_deliver_to_org_id);
   --   trace('l_ship_to_customer_id : ' || l_ship_to_customer_id);
   --   trace('l_invoice_customer_id : ' || l_invoice_customer_id);
   --   trace('l_deliver_customer_id : ' || l_deliver_customer_id);

      -- ship to organization_code
      OPEN customer_site('SHIP_TO', l_ship_to_org_id, l_ship_to_customer_id);

      FETCH customer_site INTO l_ship_to_location_id, l_location_name,
                            l_ship_to_organization_code, l_organization_name;
      CLOSE customer_site;
      --trace('l_ship_to_location_id : ' || l_ship_to_location_id ||
      --      ' l_ship_to_organization_code : ' || l_ship_to_organization_code);

      -- sold to organization_code
      OPEN customer_site('BILL_TO', l_invoice_to_org_id, l_customer_id);

      FETCH customer_site INTO l_sold_to_location_id, l_location_name,
                            l_sold_to_organization_code, l_organization_name;
      CLOSE customer_site;

      -- invoice to organization_code
      OPEN customer_site('BILL_TO', l_invoice_to_org_id, l_invoice_customer_id);

      FETCH customer_site INTO l_invoice_to_location_id, l_location_name,
                            l_invoice_to_organization_code, l_organization_name;
      CLOSE customer_site;

      -- deliver to organization_code
      OPEN customer_site('DELIVER_TO',l_deliver_to_org_id, l_deliver_customer_id);

      FETCH customer_site INTO l_deliver_to_location_id, l_location_name,
                            l_deliver_to_organization_code, l_organization_name;
      CLOSE customer_site;

      -- sold from organization_code
      OPEN from_org_curs(l_sold_from_org_id);
      FETCH from_org_curs INTO l_sold_from_location_id,
                            l_sold_from_organization_code;
      CLOSE from_org_curs;

      -- ship from organization_code
      OPEN from_org_curs(l_ship_from_org_id);
      FETCH from_org_curs INTO l_ship_from_location_id,
                            l_ship_from_organization_code;
      CLOSE from_org_curs;
      --trace('l_ship_from_location_id : ' || l_ship_from_location_id ||
      -- ' l_ship_from_organization_code : ' || l_ship_from_organization_code);

      x_out_tbl(1956).datbuf := l_sold_from_organization_code;
      x_out_tbl(1957).datbuf := l_sold_to_organization_code;
      x_out_tbl(1958).datbuf := l_deliver_to_organization_code;
      x_out_tbl(1959).datbuf := l_ship_to_organization_code;
      x_out_tbl(1960).datbuf := l_invoice_to_organization_code;
      x_out_tbl(1961).datbuf := l_ship_from_organization_code;


      OPEN loc_curs(l_ship_to_location_id);
      FETCH loc_curs INTO
        x_out_tbl(1962).datbuf, x_out_tbl(1963).datbuf, x_out_tbl(1964).datbuf,
        x_out_tbl(1965).datbuf, x_out_tbl(1966).datbuf, x_out_tbl(1967).datbuf,
        x_out_tbl(1968).datbuf, x_out_tbl(1969).datbuf, x_out_tbl(1970).datbuf,
        x_out_tbl(1971).datbuf, x_out_tbl(1972).datbuf;
      CLOSE loc_curs;

      OPEN loc_curs(l_ship_from_location_id);
      FETCH loc_curs INTO
        x_out_tbl(1973).datbuf, x_out_tbl(1974).datbuf, x_out_tbl(1975).datbuf,
        x_out_tbl(1976).datbuf, x_out_tbl(1977).datbuf, x_out_tbl(1978).datbuf,
        x_out_tbl(1979).datbuf, x_out_tbl(1980).datbuf, x_out_tbl(1981).datbuf,
        x_out_tbl(1982).datbuf, x_out_tbl(1983).datbuf;
      CLOSE loc_curs;
/*
      FOR i in 1876..1983 LOOP
         IF (x_out_tbl.EXISTS(i) AND x_out_tbl(i).datbuf IS NOT NULL ) THEN
          IF (l_debug = 1) THEN
             trace('x_out_tbl('||i||')='|| x_out_tbl(i).datbuf );
          END IF;
         END IF;
      END LOOP;
*/
   END IF;  -- p_line_id not null

   IF (l_debug = 1) THEN
      trace('**Retrieve Sale Header data ... **');
      trace('Header ID : ' || l_header_id);
   END IF;
   OPEN oe_header_curs;
   FETCH oe_header_curs INTO
     x_out_tbl(1731).datbuf, x_out_tbl(1732).datbuf, x_out_tbl(1733).datbuf,
     x_out_tbl(1734).datbuf, x_out_tbl(1735).datbuf, x_out_tbl(1736).datbuf,
     x_out_tbl(1737).datbuf, x_out_tbl(1738).datbuf, x_out_tbl(1739).datbuf,
     x_out_tbl(1740).datbuf, x_out_tbl(1741).datbuf, x_out_tbl(1742).datbuf,
     x_out_tbl(1743).datbuf, x_out_tbl(1744).datbuf, x_out_tbl(1745).datbuf,
     x_out_tbl(1746).datbuf, x_out_tbl(1747).datbuf, x_out_tbl(1748).datbuf,
     x_out_tbl(1749).datbuf, x_out_tbl(1750).datbuf, x_out_tbl(1751).datbuf,
     x_out_tbl(1752).datbuf, x_out_tbl(1753).datbuf, x_out_tbl(1754).datbuf,
     x_out_tbl(1755).datbuf, x_out_tbl(1756).datbuf, x_out_tbl(1757).datbuf,
     x_out_tbl(1758).datbuf, x_out_tbl(1759).datbuf, x_out_tbl(1760).datbuf,
     x_out_tbl(1761).datbuf, x_out_tbl(1762).datbuf, x_out_tbl(1763).datbuf,
     x_out_tbl(1764).datbuf, x_out_tbl(1765).datbuf, x_out_tbl(1766).datbuf,
     x_out_tbl(1767).datbuf, x_out_tbl(1768).datbuf, x_out_tbl(1769).datbuf,
     x_out_tbl(1770).datbuf, x_out_tbl(1771).datbuf, x_out_tbl(1772).datbuf,
     x_out_tbl(1773).datbuf, x_out_tbl(1774).datbuf, x_out_tbl(1775).datbuf,
     x_out_tbl(1776).datbuf, x_out_tbl(1777).datbuf, x_out_tbl(1778).datbuf,
     x_out_tbl(1779).datbuf, l_customer_id, l_party_id, l_party_number,
     l_sold_from_org_id, l_sold_to_org_id, l_ship_to_org_id,
     l_ship_from_org_id,l_invoice_to_org_id, l_deliver_to_org_id;

   CLOSE oe_header_curs;

   OPEN customer_site('SHIP_TO', l_ship_to_org_id, l_customer_id);

   FETCH customer_site INTO l_location_id, l_location_name,
                            l_organization_code, l_organization_name;
   CLOSE customer_site;

   OPEN loc_curs(l_location_id);
   FETCH loc_curs INTO
     x_out_tbl(1780).datbuf, x_out_tbl(1781).datbuf, x_out_tbl(1782).datbuf,
     x_out_tbl(1783).datbuf, x_out_tbl(1785).datbuf,
     x_out_tbl(1786).datbuf, x_out_tbl(1787).datbuf, x_out_tbl(1788).datbuf,
     x_out_tbl(1789).datbuf, x_out_tbl(1790).datbuf, x_out_tbl(1791).datbuf;
   CLOSE loc_curs;
/*
   FOR i in 1731..1789 LOOP
      IF (x_out_tbl.EXISTS(i) AND x_out_tbl(i).datbuf IS NOT NULL ) THEN
          IF (l_debug = 1) THEN
             trace('x_out_tbl('||i||')='|| x_out_tbl(i).datbuf );
          END IF;
      END IF;
   END LOOP;
*/
END get_data_sale_header ;

/*=================================================================*/
PROCEDURE get_data_sale_line(
   x_out_tbl IN OUT NOCOPY output_tbl_type,
   p_line_id oe_order_lines_all.line_id%TYPE
)IS

l_header_id  oe_order_headers_all.header_id%TYPE;

CURSOR hr_location_curs (c_location_id NUMBER) IS
   SELECT loc.location_id location_id,
          loc.address_line_1 address_line_1,
          loc.address_line_2 address_line_2,loc.address_line_3 address_line_3,
          loc.loc_information13 address_line_4,
          loc.town_or_city city,loc.postal_code postal_code,
          loc.region_2 state,loc.region_1 county,
          loc.country country,loc.region_3 province,
          loc.location_code location_code,loc.description location_description
   FROM hr_locations_all loc
   WHERE loc.location_id = c_location_id
   UNION ALL
   SELECT hz.location_id location_id,
          hz.address1    address_line_1,
          hz.address2    address_line_2,hz.address3  address_line_3,
          hz.address4    address_line_4,
          hz.city city,hz.postal_code postal_code,
          hz.state state,hz.county county,
          hz.country country,hz.province province,
          hz.description location_code, hz.description location_description
   FROM hz_locations hz
   WHERE hz.location_id = c_location_id;

CURSOR oe_lines_curs IS
SELECT
  oline.booked_flag,
  oline.cancelled_flag,
  oline.component_code,
  oline.cust_po_number,
  to_char(oline.earliest_acceptable_date, G_DATE_FORMAT_MASK),
  to_char(oline.explosion_date, G_DATE_FORMAT_MASK),
  oline.freight_carrier_code,
  to_char(oline.latest_acceptable_date, G_DATE_FORMAT_MASK),
  Oline.open_flag,
  to_char(oline.actual_shipment_date, G_DATE_FORMAT_MASK),
  oline.created_by,
  oline.last_updated_by,
  to_char(oline.last_update_date, G_DATE_FORMAT_MASK),
  oline.attribute1,
  oline.attribute2,
  oline.attribute3,
  oline.attribute4,
  oline.attribute5,
  oline.attribute6,
  oline.attribute7,
  oline.attribute8,
  oline.attribute9,
  oline.attribute10,
  oline.attribute11,
  oline.attribute12,
  oline.attribute13,
  oline.attribute14,
  oline.attribute15,
  oline.return_attribute1,
  oline.return_attribute2,
  oline.return_attribute3,
  oline.return_attribute4,
  oline.return_attribute5,
  oline.return_attribute6,
  oline.return_attribute7,
  oline.return_attribute8,
  oline.return_attribute9,
  oline.return_attribute10,
  oline.return_attribute11,
  oline.return_attribute12,
  oline.return_attribute13,
  oline.return_attribute14,
  oline.return_attribute15,
  oline.return_context,
  oline.context,
  to_char(oline.creation_date, G_DATE_FORMAT_MASK),
  oline.fulfilled_quantity,
  oline.ordered_item,
  oline.line_number,
  oline.ordered_quantity,
  to_char(oline.promise_date, G_DATE_FORMAT_MASK),
  oline.order_quantity_uom,
  to_char(oline.request_date, G_DATE_FORMAT_MASK),
  to_char(oline.schedule_ship_date, G_DATE_FORMAT_MASK),
  oline.shipped_quantity,
  oline.shipping_quantity,
  oline.shipping_quantity_uom,
  oline.over_ship_reason_code,
  oline.packing_instructions,
  pp.name  project_name,
  ras.name salesreps_name,
  to_char(oline.schedule_arrival_date, G_DATE_FORMAT_MASK),
  oe_sets.set_name ship_set_name,
  osmv.meaning shipping_method_name,
  ar_lookups.meaning tax_exempt_reason,
  oline.tax_code,
  oline.tax_exempt_flag,
  oline.tax_exempt_number,
  oline.tax_rate,
  oline.shipment_number,
  oline.shipping_instructions,
  --rcship.last_name,
  LTRIM(rcship.last_name ||decode(rcship.first_name,NULL,NULL,','||rcship.first_name)) ship_to_contact_name,
  LTRIM(isc.last_name || decode(isc.first_name,NULL,NULL,','|| isc.first_name)) intmed_ship_to_contact_name,
  LTRIM(invc.last_name || decode(invc.first_name,NULL,NULL,','|| invc.first_name)) invoice_to_contact_name,
  LTRIM(dcontact.last_name || decode(dcontact.first_name,NULL,NULL,','|| dcontact.first_name)) deliver_to_contact_name,
  oline.sold_from_org_id,
  oline.sold_to_org_id,
  oline.deliver_to_org_id,
  oline.ship_to_org_id,
  oline.invoice_to_org_id,
  ship_from_org.organization_code,
  oline.header_id
FROM OE_ORDER_LINES_ALL oline,
  OE_SHIP_METHODS_V osmv
  --
  -- Modification Start for Bug # - 4418524
  --
  -- As part of TCA related changes ra_customers, ra_contacts views are
  -- obsoleted in R12. The columns fetched from these views are fetched
  -- from "HZ_PARTIES", "HZ_CUST_ACCOUNTS", "HZ_CUST_ACCOUNT_ROLES",
  -- "HZ_CUST_ACCOUNTS", "HZ_RELATIONSHIPS".
  --
  -- Following six table alias are commented
  --,  ra_contacts                  rcship
  --,  ra_contacts                  dcontact
  --,  ra_contacts                  isc
  --,  ra_contacts                  invc
  --
  -- Following 4 Queries are added to replace the above commented
  -- views
  --
  ,  ( SELECT ACCT_ROLE.cust_account_role_id        contact_id,
            ACCT_ROLE.cust_account_id customer_id,
            SUBSTRB(PARTY.person_last_name,1,50)  last_name,
            SUBSTRB(PARTY.person_first_name,1,40) first_name
       FROM hz_cust_account_roles ACCT_ROLE,
            hz_parties PARTY,
            hz_relationships REL,
            hz_cust_accounts ROLE_ACCT
       WHERE
             ACCT_ROLE.party_id = REL.party_id
         AND ACCT_ROLE.role_type = 'CONTACT'
         AND REL.subject_id = PARTY.party_id
         AND REL.subject_table_name = 'HZ_PARTIES'
         AND REL.object_table_name = 'HZ_PARTIES'
         AND ACCT_ROLE.cust_account_id = ROLE_ACCT.cust_account_id
         AND ROLE_ACCT.party_id = REL.object_id
   ) rcship
  ,  ( SELECT ACCT_ROLE.cust_account_role_id        contact_id,
            ACCT_ROLE.cust_account_id customer_id,
            SUBSTRB(PARTY.person_last_name,1,50)  last_name,
            SUBSTRB(PARTY.person_first_name,1,40) first_name
       FROM hz_cust_account_roles ACCT_ROLE,
            hz_parties PARTY,
            hz_relationships REL,
            hz_cust_accounts ROLE_ACCT
       WHERE
             ACCT_ROLE.party_id = REL.party_id
         AND ACCT_ROLE.role_type = 'CONTACT'
         AND REL.subject_id = PARTY.party_id
         AND REL.subject_table_name = 'HZ_PARTIES'
         AND REL.object_table_name = 'HZ_PARTIES'
         AND ACCT_ROLE.cust_account_id = ROLE_ACCT.cust_account_id
         AND ROLE_ACCT.party_id = REL.object_id
   ) dcontact
  ,  ( SELECT ACCT_ROLE.cust_account_role_id        contact_id,
            ACCT_ROLE.cust_account_id customer_id,
            SUBSTRB(PARTY.person_last_name,1,50)  last_name,
            SUBSTRB(PARTY.person_first_name,1,40) first_name
       FROM hz_cust_account_roles ACCT_ROLE,
            hz_parties PARTY,
            hz_relationships REL,
            hz_cust_accounts ROLE_ACCT
       WHERE
             ACCT_ROLE.party_id = REL.party_id
         AND ACCT_ROLE.role_type = 'CONTACT'
         AND REL.subject_id = PARTY.party_id
         AND REL.subject_table_name = 'HZ_PARTIES'
         AND REL.object_table_name = 'HZ_PARTIES'
         AND ACCT_ROLE.cust_account_id = ROLE_ACCT.cust_account_id
         AND ROLE_ACCT.party_id = REL.object_id
   ) isc
  ,  ( SELECT ACCT_ROLE.cust_account_role_id        contact_id,
            ACCT_ROLE.cust_account_id customer_id,
            SUBSTRB(PARTY.person_last_name,1,50)  last_name,
            SUBSTRB(PARTY.person_first_name,1,40) first_name
       FROM hz_cust_account_roles ACCT_ROLE,
            hz_parties PARTY,
            hz_relationships REL,
            hz_cust_accounts ROLE_ACCT
       WHERE
             ACCT_ROLE.party_id = REL.party_id
         AND ACCT_ROLE.role_type = 'CONTACT'
         AND REL.subject_id = PARTY.party_id
         AND REL.subject_table_name = 'HZ_PARTIES'
         AND REL.object_table_name = 'HZ_PARTIES'
         AND ACCT_ROLE.cust_account_id = ROLE_ACCT.cust_account_id
         AND ROLE_ACCT.party_id = REL.object_id
   ) invc,
  PA_PROJECTS pp,
  --ORG_FREIGHT_VL ofv,
  RA_SALESREPS ras,
  OE_SETS,
  AR_LOOKUPS,
  MTL_PARAMETERS ship_from_org
WHERE oline.line_id = p_line_id
  AND oline.deliver_to_contact_id = dcontact.contact_id(+)
  AND oline.intmed_ship_to_contact_id = isc.contact_id(+)
  AND oline.salesrep_id = ras.salesrep_id(+)
  AND oline.ship_set_id = oe_sets.set_id(+)
  AND oline.ship_to_contact_id = rcship.contact_id(+)
  AND oline.shipping_method_code = osmv.lookup_code(+)
  AND oline.tax_exempt_reason_code = ar_lookups.lookup_code(+)
  and ar_lookups.lookup_type(+) = 'TAX_REASON'
  AND oline.invoice_to_contact_id = invc.contact_id(+)
  AND oline.project_id =pp.project_id(+)
  AND oline.ship_from_org_id = ship_from_org.organization_id(+);
  --AND oline.freight_carrier_code = ofv.freight_code(+)



  BEGIN
     IF (l_debug = 1) THEN
        trace('**In get_data_sale_line() **');
     END IF;
     OPEN oe_lines_curs;
     FETCH oe_lines_curs INTO
        x_out_tbl(1876).datbuf, x_out_tbl(1877).datbuf, x_out_tbl(1878).datbuf,
        x_out_tbl(1879).datbuf, x_out_tbl(1880).datbuf, x_out_tbl(1881).datbuf,
        x_out_tbl(1882).datbuf, x_out_tbl(1883).datbuf, x_out_tbl(1884).datbuf,
      x_out_tbl(1885).datbuf, x_out_tbl(1886).datbuf, x_out_tbl(1887).datbuf,
      x_out_tbl(1888).datbuf, x_out_tbl(1889).datbuf, x_out_tbl(1890).datbuf,
      x_out_tbl(1891).datbuf, x_out_tbl(1892).datbuf, x_out_tbl(1893).datbuf,
      x_out_tbl(1894).datbuf, x_out_tbl(1895).datbuf, x_out_tbl(1896).datbuf,
      x_out_tbl(1897).datbuf, x_out_tbl(1898).datbuf, x_out_tbl(1899).datbuf,
      x_out_tbl(1900).datbuf, x_out_tbl(1901).datbuf, x_out_tbl(1902).datbuf,
      x_out_tbl(1903).datbuf, x_out_tbl(1904).datbuf, x_out_tbl(1905).datbuf,
      x_out_tbl(1906).datbuf, x_out_tbl(1907).datbuf, x_out_tbl(1908).datbuf,
      x_out_tbl(1909).datbuf, x_out_tbl(1910).datbuf, x_out_tbl(1911).datbuf,
      x_out_tbl(1912).datbuf, x_out_tbl(1913).datbuf, x_out_tbl(1914).datbuf,
      x_out_tbl(1915).datbuf, x_out_tbl(1916).datbuf, x_out_tbl(1917).datbuf,
      x_out_tbl(1918).datbuf, x_out_tbl(1919).datbuf, x_out_tbl(1920).datbuf,
      x_out_tbl(1921).datbuf, x_out_tbl(1922).datbuf, x_out_tbl(1923).datbuf,
      x_out_tbl(1924).datbuf, x_out_tbl(1925).datbuf, x_out_tbl(1926).datbuf,
      x_out_tbl(1927).datbuf, x_out_tbl(1928).datbuf, x_out_tbl(1929).datbuf,
      x_out_tbl(1930).datbuf, x_out_tbl(1931).datbuf, x_out_tbl(1932).datbuf,
      x_out_tbl(1933).datbuf, x_out_tbl(1934).datbuf, x_out_tbl(1935).datbuf,
      x_out_tbl(1936).datbuf, x_out_tbl(1937).datbuf, x_out_tbl(1938).datbuf,
      x_out_tbl(1939).datbuf, x_out_tbl(1940).datbuf, x_out_tbl(1941).datbuf,
      x_out_tbl(1942).datbuf, x_out_tbl(1943).datbuf, x_out_tbl(1944).datbuf,
      x_out_tbl(1945).datbuf, x_out_tbl(1946).datbuf, x_out_tbl(1947).datbuf,
      x_out_tbl(1948).datbuf, x_out_tbl(1949).datbuf, x_out_tbl(1950).datbuf,
      x_out_tbl(1951).datbuf, x_out_tbl(1952).datbuf, x_out_tbl(1953).datbuf,
      x_out_tbl(1954).datbuf, x_out_tbl(1955).datbuf, x_out_tbl(1956).datbuf,
      l_header_id;

   CLOSE oe_lines_curs;

/*
   FOR i in 1876..1955 LOOP
      IF (x_out_tbl.EXISTS(i) AND x_out_tbl(i).datbuf IS NOT NULL ) THEN
          IF (l_debug = 1) THEN
             trace('x_out_tbl('||i||')='|| x_out_tbl(i).datbuf );
          END IF;
      END IF;
   END LOOP;
*/

END get_data_sale_line ;

/*=================================================================*
 *  Main Procedure                                                 *
 *=================================================================*
*/
PROCEDURE get_variable_data(
 x_variable_content      OUT NOCOPY INV_LABEL.label_tbl_type
,x_msg_count              OUT NOCOPY NUMBER
,x_msg_data               OUT NOCOPY VARCHAR2
,x_return_status          OUT NOCOPY VARCHAR2
,p_label_type_info        IN INV_LABEL.label_type_rec
,p_transaction_id         IN NUMBER
,p_input_param            IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
,p_transaction_identifier IN NUMBER
) IS

l_api_name 		VARCHAR2(20) := 'get_variable_data';
SERIAL_EXCEPTION        EXCEPTION;
NO_FLOW_DATA_FOUND_X    EXCEPTION;
NO_LABEL_FORMAT_FOUND_X EXCEPTION;

l_transaction_id       MTL_MATERIAL_TRANSACTIONS_TEMP.TRANSACTION_TEMP_ID%TYPE;

TYPE inptype is RECORD
(
   inventory_item_id    mtl_material_transactions_temp.inventory_item_id%TYPE,
   organization_id      mtl_material_transactions_temp.organization_id%TYPE,
   subinventory_code    mtl_material_transactions_temp.subinventory_code%TYPE,
   locator_id           mtl_material_transactions_temp.locator_id%TYPE,
   lot_number           mtl_material_transactions_temp.lot_number%TYPE,
   serial_number        mtl_material_transactions_temp.serial_number%TYPE,
   serial_number_start  mtl_serial_numbers.serial_number%TYPE,
   serial_number_end    mtl_serial_numbers.serial_number%TYPE,
   cost_group_id        mtl_material_transactions_temp.cost_group_id%TYPE,
   project_id           mtl_material_transactions_temp.project_id%TYPE,
   task_id              mtl_material_transactions_temp.task_id%TYPE,
   quantity             mtl_material_transactions_temp.transaction_quantity%TYPE,
   uom                  mtl_material_transactions_temp.transaction_uom%TYPE,
   revision            mtl_material_transactions_temp.revision%TYPE,
   alternate_bom_designator mtl_material_transactions_temp.alternate_bom_designator%TYPE,
   alternate_routing_designator mtl_material_transactions_temp.alternate_routing_designator%TYPE,
   sale_header_id    mtl_material_transactions_temp.demand_source_header_id%TYPE,
   sale_line_id     mtl_material_transactions_temp.demand_source_line%TYPE,
   kanban_card_id     mtl_material_transactions_temp.kanban_card_id%TYPE,
   lpn_id             mtl_material_transactions_temp.lpn_id%TYPE,
   wip_entity_id      mtl_material_transactions_temp.transaction_source_id%TYPE,
   schedule_number    wip_flow_schedules.schedule_number%TYPE,
   lot_control_code           mtl_system_items.lot_control_code%TYPE,
   serial_number_control_code mtl_system_items.serial_number_control_code%TYPE,
   transaction_id     mtl_material_transactions_temp.transaction_temp_id%TYPE
);


--TYPE flow_input_tbl_type IS TABLE OF inptype INDEX BY BINARY_INTEGER;
TYPE flow_input_tbl_type IS TABLE OF inptype INDEX BY BINARY_INTEGER;

l_in_tbl        flow_input_tbl_type;
l_prev_in_tbl   inptype;
l_out_tbl          output_tbl_type;
l_counter               INTEGER;
l_in_rec                inptype;
l_serial_numbers_table  inv_label.serial_tab_type;
l_transaction_identifier NUMBER;
l_serial_not_found      BOOLEAN;

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--   Following variables were added (as a part of 11i10+ 'Custom Labels' Project)            |
--   to retrieve and hold the SQL Statement and it's result.                                 |
---------------------------------------------------------------------------------------------
   l_sql_stmt  VARCHAR2(4000);
   l_sql_stmt_result VARCHAR2(4000) := NULL;
   TYPE sql_stmt IS REF CURSOR;
   c_sql_stmt sql_stmt;
   l_custom_sql_ret_status VARCHAR2(1);
   l_custom_sql_ret_msg VARCHAR2(2000);

   -- Fix for bug: 4179593 Start
   l_CustSqlWarnFlagSet BOOLEAN;
   l_CustSqlErrFlagSet BOOLEAN;
   l_CustSqlWarnMsg VARCHAR2(2000);
   l_CustSqlErrMsg VARCHAR2(2000);
   -- Fix for bug: 4179593 End

------------------------End of this change for Custom Labels project code--------------------

-- Driving cursor
CURSOR flow_complete_mmtt_curs IS
   SELECT  mmtt.inventory_item_id,
           mmtt.organization_id,
           NVL(mmtt.subinventory_code,
               wfs.completion_subinventory) subinventory_code,
           NVL(mmtt.locator_id, wfs.completion_locator_id) locator_id,
           NVL(mtlt.lot_number,mmtt.lot_number) lot_number ,
           mmtt.serial_number,
           NULL serial_number_start,
           NULL serial_number_end,
           mmtt.cost_group_id ,
           NVL(mmtt.project_id , wfs.project_id) project_id ,
           NVL(mmtt.task_id , wfs.task_id) task_id ,
           mmtt.transaction_quantity quantity,
           mmtt.transaction_uom  uom,
           mmtt.revision revision,
           NVL(mmtt.alternate_bom_designator,
               wfs.alternate_bom_designator) alternate_bom_designator,
           NVL(mmtt.alternate_routing_designator,
               wfs.alternate_routing_designator) alternate_routing_designator,
           NVL(mmtt.demand_source_header_id,
               wfs.demand_source_header_id) sale_header_id,
           NVL(mmtt.demand_source_line, wfs.demand_source_line) sale_line_id,
           NVL(mmtt.kanban_card_id,wfs.kanban_card_id) kanban_card_id,
       NVL(NVL(mmtt.transfer_lpn_id, mmtt.content_lpn_id), mmtt.lpn_id) lpn_id,
           mmtt.transaction_source_id wip_entity_id,
           NVL(mmtt.schedule_number, wfs.schedule_number) schedule_number,
           msi.lot_control_code,
           msi.serial_number_control_code serial_number_control_code,
           mmtt.transaction_temp_id transaction_id
   FROM  MTL_MATERIAL_TRANSACTIONS_TEMP mmtt,
         MTL_TRANSACTION_LOTS_TEMP mtlt,
         MTL_SYSTEM_ITEMS msi,
         WIP_ENTITIES WE,
         WIP_FLOW_SCHEDULES wfs
   WHERE   mmtt.transaction_temp_id     =  l_transaction_id
   AND     mmtt.transaction_temp_id     =  mtlt.transaction_temp_id(+)
   AND     mmtt.organization_id         = msi.organization_id
   AND     mmtt.inventory_item_id       = msi.inventory_item_id
   AND     mmtt.transaction_source_id   = wfs.wip_entity_id(+)
   AND     mmtt.transaction_source_id   = we.wip_entity_id(+)
   AND we.entity_type(+) = 4;    -- Flow
   -- Bug 2904142 Add next where clause
   /*AND     mmtt.inventory_item_id IS NOT NULL
   AND     mmtt.content_lpn_id IS NULL;*/ -- Modified for the bug # 5740354

-- Bug 2904142, add a new cusor to query the exploded MMTT line
CURSOR flow_complete_mmtt_lpn_curs IS
   SELECT  mmtt.inventory_item_id,
           mmtt.organization_id,
           NVL(mmtt.subinventory_code,
               wfs.completion_subinventory) subinventory_code,
           NVL(mmtt.locator_id, wfs.completion_locator_id) locator_id,
           NVL(mtlt.lot_number,mmtt.lot_number) lot_number ,
           mmtt.serial_number,
           NULL serial_number_start,
           NULL serial_number_end,
           mmtt.cost_group_id ,
           NVL(mmtt.project_id , wfs.project_id) project_id ,
           NVL(mmtt.task_id , wfs.task_id) task_id ,
           mmtt.transaction_quantity quantity,
           mmtt.transaction_uom  uom,
           mmtt.revision revision,
           NVL(mmtt.alternate_bom_designator,
               wfs.alternate_bom_designator) alternate_bom_designator,
           NVL(mmtt.alternate_routing_designator,
               wfs.alternate_routing_designator) alternate_routing_designator,
           NVL(mmtt.demand_source_header_id,
               wfs.demand_source_header_id) sale_header_id,
           NVL(mmtt.demand_source_line, wfs.demand_source_line) sale_line_id,
           NVL(mmtt.kanban_card_id,wfs.kanban_card_id) kanban_card_id,
           NVL(NVL(mmtt.transfer_lpn_id, mmtt.content_lpn_id), mmtt.lpn_id) lpn_id,
           mmtt.transaction_source_id wip_entity_id,
           NVL(mmtt.schedule_number, wfs.schedule_number) schedule_number,
           msi.lot_control_code,
           msi.serial_number_control_code serial_number_control_code,
           mmtt.transaction_temp_id transaction_id
   FROM  MTL_MATERIAL_TRANSACTIONS_TEMP mmtt,
         MTL_TRANSACTION_LOTS_TEMP mtlt,
         MTL_SYSTEM_ITEMS msi,
         WIP_ENTITIES WE,
         WIP_FLOW_SCHEDULES wfs,
         MTL_MATERIAL_TRANSACTIONS_TEMP mmtt_orig
   WHERE   mmtt.transaction_temp_id     = mtlt.transaction_temp_id(+)
   AND     mmtt.organization_id         = msi.organization_id
   AND     mmtt.inventory_item_id       = msi.inventory_item_id
   AND     mmtt.transaction_source_id   = wfs.wip_entity_id(+)
   AND     mmtt.transaction_source_id   = we.wip_entity_id(+)
   AND     we.entity_type(+) = 4
   AND     mmtt.transaction_header_id      = mmtt_orig.transaction_header_id
   AND     mmtt.transaction_temp_id        <>mmtt_orig.transaction_temp_id
   AND     mmtt_orig.content_lpn_id IS NOT NULL
   AND     mmtt_orig.transaction_temp_id  = l_transaction_id;

-- Driving cursor
CURSOR flow_complete_mti_curs IS
   SELECT  mti.inventory_item_id,
           mti.organization_id,
           NVL(mti.subinventory_code,
               wfs.completion_subinventory) subinventory_code,
           NVL(mti.locator_id, wfs.completion_locator_id) locator_id,
           -- mti.source_lot_number lot_number, -- Commented for Bug 2894995 : joabraha
           mtli.lot_number lot_number, -- Added for Bug 2894995 : joabraha
           NULL serial_number,
           NULL serial_number_start,
           NULL serial_number_end,
           mti.cost_group_id,
           NVL(mti.project_id , wfs.project_id) project_id ,
           NVL(mti.task_id , wfs.task_id) task_id ,
           mti.transaction_quantity quantity,
           mti.transaction_uom uom,
           mti.revision revision,
           NVL(mti.alternate_bom_designator,
               wfs.alternate_bom_designator) alternate_bom_designator,
           NVL(mti.alternate_routing_designator,
               wfs.alternate_routing_designator) alternate_routing_designator,
           NVL(mti.demand_source_header_id,
               wfs.demand_source_header_id) sale_header_id,
           NVL(mti.demand_source_line, wfs.demand_source_line) sale_line_id,
           NVL(mti.kanban_card_id,wfs.kanban_card_id) kanban_card_id,
           mti.transfer_lpn_id lpn_id ,
           mti.transaction_source_id wip_entity_id,
           NVL(mti.schedule_number, wfs.schedule_number) schedule_number,
           msi.lot_control_code,
           msi.serial_number_control_code,
           mti.transaction_interface_id transaction_id
   FROM  MTL_TRANSACTIONS_INTERFACE mti,
         -- MTL_TRANSACTION_LOTS_INTERFACE mtli, -- Bug 2576424 : joabraha
         -- Bug 2904877, change back to using MTLI,
         --  this depends on WIP's fix on bug 2904857
         MTL_TRANSACTION_LOTS_INTERFACE mtli,
         --MTL_TRANSACTION_LOTS_TEMP mtlt,
         MTL_SYSTEM_ITEMS msi,
         WIP_FLOW_SCHEDULES wfs
   WHERE   mti.transaction_interface_id     =  l_transaction_id
   -- AND     mti.transaction_interface_id     =  mtli.transaction_interface_id(+) -- Bug 2576424 : joabraha
   -- AND     mti.transaction_interface_id     =  mtlt.transaction_temp_id(+) -- Bug 2576424 : joabraha
   -- Bug 2904877, change back to using MTLI,
   --  this depends on WIP's fix on bug 2904857
   AND     mti.transaction_interface_id     =  mtli.transaction_interface_id(+)
   AND     mti.organization_id         = msi.organization_id
   AND     mti.inventory_item_id       = msi.inventory_item_id
   AND     mti.transaction_source_id   = wfs.wip_entity_id(+);
   --AND     mti.wip_entity_type = 4;    -- Flow  /* Commented out as part of Bug# 3560377 */


-- Driving cursor
CURSOR flow_complete_mtrl_curs IS
   SELECT mtrl.inventory_item_id,
          mtrl.organization_id,
       NVL(mmtt.subinventory_code, mtrl.to_subinventory_code) subinventory_code,
           mtrl.to_locator_id locator_id,
           NVL(mmtt.lot_number,mtrl.lot_number) lot_number,
           NULL serial_number,
           NVL(mtrl.serial_number_start,'@@') serial_number_start,
           NVL(mtrl.serial_number_end,'@@') serial_number_end,
           mtrl.to_cost_group_id cost_group_id,
           mtrl.project_id ,
           mtrl.task_id ,
           mtrl.quantity quantity,
           mtrl.uom_code  uom,
           mtrl.revision revision,
           mmtt.alternate_bom_designator alternate_bom_designator,
           mmtt.alternate_routing_designator alternate_routing_designator,
           mmtt.demand_source_header_id sale_header_id,
           NVL(mmtt.demand_source_line, mtrl.txn_source_line_id) sale_line_id,
           mmtt.kanban_card_id kanban_card_id,
           mtrl.lpn_id lpn_id ,
           mtrl.txn_source_id wip_entity_id,
           mmtt.schedule_number schedule_number,
           msi.lot_control_code,
           msi.serial_number_control_code,
           mmtt.transaction_temp_id transaction_id
   FROM  MTL_TXN_REQUEST_LINES mtrl,
         MTL_MATERIAL_TRANSACTIONS_TEMP mmtt,
         MTL_TRANSACTION_LOTS_TEMP mtlt,
         MTL_SYSTEM_ITEMS msi,
         WIP_ENTITIES WE
   WHERE   mtrl.line_id                 =  l_transaction_id
   AND     mtrl.line_id                 = mmtt.move_order_line_id(+)
   AND     mmtt.transaction_temp_id     = mtlt.transaction_temp_id(+)
   AND     mtrl.organization_id         = msi.organization_id
   AND     mtrl.inventory_item_id       = msi.inventory_item_id
   AND mtrl.txn_source_id = we.wip_entity_id(+)
   AND we.entity_type(+) = 4;

-- Driving cursor
CURSOR flow_schedule_mmtt_curs IS
   SELECT  wfs.primary_item_id inventory_item_id,
           wfs.organization_id organization_id,
           NVL(mmtt.subinventory_code, wfs.completion_subinventory) subinventory_code,
           NVL(mmtt.locator_id, wfs.completion_locator_id) locator_id,
           NULL lot_number ,
           NULL serial_number,
           NULL serial_number_start,
           NULL serial_number_end,
           mmtt.cost_group_id cost_group_id,
           NVL(mmtt.project_id, wfs.project_id) project_id ,
           NVL(mmtt.task_id, wfs.task_id) task_id ,
           NVL(mmtt.transaction_quantity, wfs.quantity_completed) quantity,
           mmtt.transaction_uom uom,
           mmtt.revision revision,
           NVL(mmtt.alternate_bom_designator,wfs.alternate_bom_designator) alternate_bom_designator,
           NVL(mmtt.alternate_routing_designator, wfs.alternate_routing_designator) alternate_routing_designator,
           NVL(mmtt.demand_source_header_id,
                  wfs.demand_source_header_id ) sale_header_id,
           NVL(mmtt.demand_source_line,
                  wfs.demand_source_line) sale_line_id,
           NVL(mmtt.kanban_card_id,wfs.kanban_card_id) kanban_card_id,
       NVL(NVL(mmtt.transfer_lpn_id, mmtt.content_lpn_id), mmtt.lpn_id) lpn_id,
           wfs.wip_entity_id wip_entity_id,
           wfs.schedule_number schedule_number,
           msi.lot_control_code,
           msi.serial_number_control_code,
           mmtt.transaction_temp_id transaction_id
   FROM  WIP_FLOW_SCHEDULES wfs,
         MTL_MATERIAL_TRANSACTIONS_TEMP mmtt,
         MTL_TRANSACTION_LOTS_TEMP mtlt,
         MTL_SYSTEM_ITEMS msi,
         WIP_ENTITIES WE
   WHERE   mmtt.transaction_source_type_id = 5
   AND     mmtt.transaction_action_id  = 31
   AND     mmtt.organization_id        = wfs.organization_id
   AND     mmtt.inventory_item_id      = wfs.primary_item_id
   AND     mmtt.transaction_source_id  = wfs.wip_entity_id
   AND     mmtt.transaction_temp_id    = mtlt.transaction_temp_id(+)
   AND     wfs.organization_id         = msi.organization_id
   AND     wfs.primary_item_id         = msi.inventory_item_id
   AND     wfs.wip_entity_id           = we.wip_entity_id
   AND     we.entity_type              = 4                        -- Flow
   AND     wfs.wip_entity_id           =  l_transaction_id;

-- Driving cursor
CURSOR flow_schedule_mmt_curs IS
   SELECT  wfs.primary_item_id inventory_item_id,
           wfs.organization_id organization_id,
           NVL(mmt.subinventory_code, wfs.completion_subinventory) subinventory_code,
           NVL(mmt.locator_id, wfs.completion_locator_id) locator_id,
           mtln.lot_number lot_number ,
           NULL serial_number,
           NULL serial_number_start,
           NULL serial_number_end,
           mmt.cost_group_id cost_group_id,
           NVL(mmt.project_id, wfs.project_id) project_id ,
           NVL(mmt.task_id, wfs.task_id) task_id ,
           NVL(mmt.transaction_quantity, wfs.quantity_completed) quantity,
           mmt.transaction_uom uom,
           mmt.revision revision,
           wfs.alternate_bom_designator alternate_bom_designator,
           wfs.alternate_routing_designator alternate_routing_designator,
           wfs.demand_source_header_id  sale_header_id,
           wfs.demand_source_line sale_line_id,
           wfs.kanban_card_id kanban_card_id,
           NVL(NVL(mmt.transfer_lpn_id, mmt.content_lpn_id), mmt.lpn_id) lpn_id ,
           wfs.wip_entity_id wip_entity_id,
           wfs.schedule_number schedule_number,
           msi.lot_control_code,
           msi.serial_number_control_code,
           mmt.transaction_id transaction_id
   FROM  wip_flow_schedules wfs,
         mtl_material_transactions mmt,
         mtl_transaction_lot_numbers mtln,
         wip_entities we,
         mtl_system_items msi
   WHERE   mmt.transaction_source_type_id = 5
   AND     mmt.transaction_action_id =  31
   AND     mmt.organization_id = wfs.organization_id
   AND     mmt.inventory_item_id = wfs.primary_item_id
   AND     mmt.transaction_source_id = wfs.wip_entity_id
   AND     wfs.organization_id         = msi.organization_id
   AND     wfs.primary_item_id         = msi.inventory_item_id
   AND     we.wip_entity_id = wfs.wip_entity_id
   AND     we.entity_type = 4
   AND     mmt.transaction_id = mtln.transaction_id(+)
   AND   wfs.wip_entity_id           = l_transaction_id;

-- Bug 2728468 Adhoc printing enabled for schedules that is not completed yet.
-- Added new cursor of flow_schedule_wfs_curs to retrieve schedule information
-- from WIP_FLOW_SCHEDULES
CURSOR flow_schedule_wfs_curs IS
   SELECT  wfs.primary_item_id inventory_item_id,
           wfs.organization_id organization_id,
           wfs.completion_subinventory subinventory_code,
           wfs.completion_locator_id locator_id,
           NULL lot_number ,
           NULL serial_number,
           NULL serial_number_start,
           NULL serial_number_end,
           NULL cost_group_id,
           wfs.project_id project_id ,
           wfs.task_id task_id ,
           wfs.quantity_completed quantity,
           msi.primary_uom_code uom,
           NULL revision,
           wfs.alternate_bom_designator alternate_bom_designator,
           wfs.alternate_routing_designator alternate_routing_designator,
           wfs.demand_source_header_id  sale_header_id,
           wfs.demand_source_line sale_line_id,
           wfs.kanban_card_id kanban_card_id,
           NULL lpn_id ,
           wfs.wip_entity_id wip_entity_id,
           wfs.schedule_number schedule_number,
           msi.lot_control_code,
           msi.serial_number_control_code,
           NULL transaction_id
   FROM  wip_flow_schedules wfs,
         wip_entities we,
         mtl_system_items msi
   WHERE   wfs.organization_id         = msi.organization_id
   AND     wfs.primary_item_id         = msi.inventory_item_id
   AND     we.wip_entity_id = wfs.wip_entity_id
   AND     we.entity_type = 4
   AND   wfs.wip_entity_id           = l_transaction_id;

   /* The following cursor has been modified for the bug# 5475495
    * The cursor will be opened only for LPN- Flow/WorkOrderLess completion Txn's
    * ie., transaction_identifier will be 1(i.e., MMTT_TYPE in this PACKAGE)
    *
    * Currently the cursor is fetching data using mtl_serial_numbers_temp table.
    * whereas the data will present only on mtl_serial_numbers table.
    * hence, modified the code to retrieve the serial numbers based on lpn_id in
    * mtl_material_transactions_temp  and lpn_id in mtl_serial_numbers.

  -- Bug 2882958, added parameter p_lot_number to restrict on lot
   CURSOR mmtt_serial_curs(p_lot_number VARCHAR2) IS
      -- Serial Control
      SELECT msn.serial_number
      FROM mtl_material_transactions_temp mmtt,
           mtl_serial_numbers_temp msnt, mtl_serial_numbers msn
      where mmtt.transaction_temp_id = msnt.transaction_temp_id
      and msnt.fm_serial_number <= msn.serial_number AND
          msnt.to_serial_number >= msn.serial_number
      and mmtt.organization_id = msn.current_organization_id
      and mmtt.inventory_item_id = msn.inventory_item_id
      and mmtt.transaction_temp_id = l_transaction_id
      UNION
      -- Lot and Serial Control
      SELECT msn.serial_number
      FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt,
           mtl_serial_numbers_temp msnt, mtl_serial_numbers msn
      where mmtt.transaction_temp_id = mtlt.transaction_temp_id
      and mtlt.serial_transaction_temp_id = msnt.transaction_temp_id
      and msnt.fm_serial_number <= msn.serial_number AND
          msnt.to_serial_number >= msn.serial_number
      and mmtt.organization_id = msn.current_organization_id
      and mmtt.inventory_item_id = msn.inventory_item_id
      and mmtt.transaction_temp_id = l_transaction_id
      -- Bug 2882958, added parameter p_lot_number to restrict on lot
      and mtlt.lot_number = p_lot_number; */

      CURSOR mmtt_serial_curs(p_lot_number VARCHAR2) IS
      SELECT msn.serial_number
        FROM mtl_material_transactions_temp mmtt,
             mtl_serial_numbers msn
       where mmtt.transaction_temp_id = l_transaction_id
         and (mmtt.lpn_id = msn.lpn_id
          or mmtt.content_lpn_id = msn.lpn_id) -- Modified for the bug # 5740354
         and mmtt.inventory_item_id = msn.inventory_item_id
       UNION
      SELECT msn.serial_number
        FROM mtl_material_transactions_temp mmtt,
             mtl_serial_numbers msn
       where mmtt.transaction_temp_id = l_transaction_id
         and (mmtt.lpn_id = msn.lpn_id
         or mmtt.content_lpn_id = msn.lpn_id) -- Modified for the bug # 5740354
         and mmtt.inventory_item_id = msn.inventory_item_id
         and msn.lot_number = p_lot_number;


   -- Bug 2882958, added parameter p_lot_number to restrict on lot
   CURSOR mti_serial_curs(p_lot_number VARCHAR2) IS
      -- Serial Control
      SELECT msn.serial_number
      FROM mtl_transactions_interface mti,
           mtl_serial_numbers_interface msni, mtl_serial_numbers msn
      where mti.transaction_interface_id =msni.transaction_interface_id
      and msni.fm_serial_number <= msn.serial_number AND
          msni.to_serial_number >= msn.serial_number
      and mti.organization_id = msn.current_organization_id
      and mti.inventory_item_id = msn.inventory_item_id
      and mti.transaction_interface_id = l_transaction_id
      UNION
      -- Lot and Serial Control
      SELECT msn.serial_number
      FROM mtl_transactions_interface mti, mtl_transaction_lots_interface mtli,
           mtl_serial_numbers_interface msni, mtl_serial_numbers msn
      where mti.transaction_interface_id = mtli.transaction_interface_id
      and mtli.serial_transaction_temp_id = msni.transaction_interface_id
      and msni.fm_serial_number <= msn.serial_number AND
          msni.to_serial_number >= msn.serial_number
      and mti.organization_id = msn.current_organization_id
      and mti.inventory_item_id = msn.inventory_item_id
      and mti.transaction_interface_id = l_transaction_id
      -- Bug 2882958, added parameter p_lot_number to restrict on lot
      and mtli.lot_number = p_lot_number;

   CURSOR serial_curs IS
      select serial_number
      FROM mtl_serial_numbers
      WHERE current_organization_id = l_in_rec.organization_id
      AND inventory_item_id         = l_in_rec.inventory_item_id
      AND current_subinventory_code = l_in_rec.subinventory_code
      AND NVL(revision, '@@@@')    = NVL(l_in_rec.revision,'@@@@')
      AND NVL(lot_number, '@@@@')   = NVL(l_in_rec.lot_number, '@@@@')
      AND last_transaction_id       = l_transaction_id;

l_organization_id NUMBER := null;
l_wip_entity_id   NUMBER := null;
l_inventory_item_id NUMBER := null;
l_operation_seq_num NUMBER := null;
l_lpn_id NUMBER := null;
l_revision VARCHAR2(3) := null;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
l_lot_number VARCHAR2(80) := null;
l_cost_group_id NUMBER := null;
l_quantity NUMBER := null;
l_uom VARCHAR2(3) := null;
l_subinventory_code mtl_material_transactions_temp.subinventory_code%TYPE;


l_selected_fields 	INV_LABEL.label_field_variable_tbl_type;
l_selected_fields_count	NUMBER;

l_label_format_id       NUMBER := 0 ;
l_label_format          VARCHAR2(100);
l_printer        	VARCHAR2(30);
l_field_id              NUMBER := 0 ;

l_prev_label_format_id	NUMBER :=0;

l_content_item_data LONG;
l_content_rec_index 	NUMBER := 0;

l_return_status 	VARCHAR2(240);
l_error_message  	VARCHAR2(240);
l_msg_count      	NUMBER;
l_api_status     	VARCHAR2(240);
l_msg_data		VARCHAR2(240);
i 			NUMBER;
j 			NUMBER;
l_field_value           VARCHAR2(240);

l_id number;
l_label_index 		NUMBER := 1;
l_label_request_id NUMBER;
-- I cleanup, user l_prev_sub to record the previous subinventory
--so that get_printer is not called if the subinventory is the same
l_prev_sub VARCHAR2(30);

BEGIN
    l_debug := INV_LABEL.l_debug;

   -- Initialize return status as success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (l_debug = 1) THEN
      trace('**In PVT10:  Flow Content label**');
      trace('  Business_flow: '||p_label_type_info.business_flow_code);
      trace('  Transaction ID:'||p_transaction_id);
      trace('  Transaction Identifier:'||p_transaction_identifier);
   END IF;

   -- ==========================================================
   -- Validate Input Parameters
   -- ==========================================================

   IF (p_transaction_id IS NULL) AND (p_input_param.transaction_temp_id IS NULL)
   THEN
      IF (l_debug = 1) THEN
         trace('Neither p_transaction_id nor p_input_param.transaction_temp_id is passed . ');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   l_counter := 0;
   IF p_transaction_identifier IS NULL THEN
      l_transaction_identifier := 0;
   ELSE
      l_transaction_identifier := p_transaction_identifier;
   END IF;

   l_transaction_id := p_transaction_id;
   -- ====================================================
   -- Manual Printing is for specific wip_entity_id
   -- ====================================================
   IF (p_input_param.transaction_temp_id IS NOT NULL) THEN
      l_transaction_identifier := WFS_TYPE;
      l_transaction_id := p_input_param.transaction_temp_id;
   END IF;

   IF (l_transaction_identifier = MMTT_TYPE ) THEN
     OPEN flow_complete_mmtt_curs;
     LOOP
     FETCH flow_complete_mmtt_curs INTO l_in_rec;
     EXIT WHEN flow_complete_mmtt_curs%NOTFOUND;
        l_counter := l_counter + 1;
        l_transaction_id := l_in_rec.transaction_id;
        IF (l_in_rec.serial_number_control_code in (2,5,6) ) THEN
           -- The item is serial control
           -- initialize serial_number to check for error
           l_serial_not_found := TRUE;
           FOR serial_rec IN mmtt_serial_curs(l_in_rec.lot_number) LOOP
               l_in_tbl(l_counter) := l_in_rec;
               l_in_tbl(l_counter).serial_number := serial_rec.serial_number;
               l_counter := l_counter + 1;
               l_serial_not_found := FALSE;
           END LOOP;

           IF l_serial_not_found THEN
             IF (l_debug = 1) THEN
                trace('Item is serial number control. No serial Number found !!!');
             END IF;
                FND_MESSAGE.SET_NAME('INV', 'WMS_SERIAL_FOUND');
                FND_MSG_PUB.ADD;
                RAISE SERIAL_EXCEPTION;
           -- Bug 2882958
           ELSE
              -- Reduce l_count to avoid extra increment
              l_counter := l_counter - 1;
           END IF;

        ELSE
            l_in_tbl(l_counter) := l_in_rec;
        END IF;
     END LOOP;
     CLOSE flow_complete_mmtt_curs;
     -- Bug 2904142, For Flow completion with putaway drop (35),
     -- The MMTT record is only has content_lpn_id populated and
     -- the detail item, lot, serial information should be retrieved
     -- from the new MMTT/MTLT/MSNT that will be exploded from the original MMTT line
     IF (l_counter = 0) THEN
        OPEN flow_complete_mmtt_lpn_curs;
        LOOP
        FETCH flow_complete_mmtt_lpn_curs INTO l_in_rec;
        EXIT WHEN flow_complete_mmtt_lpn_curs%NOTFOUND;
           l_counter := l_counter + 1;
           l_transaction_id := l_in_rec.transaction_id;
           IF (l_in_rec.serial_number_control_code in (2,5,6) ) THEN
              -- The item is serial control
              -- initialize serial_number to check for error
              l_serial_not_found := TRUE;
              FOR serial_rec IN mmtt_serial_curs(l_in_rec.lot_number) LOOP
                  l_in_tbl(l_counter) := l_in_rec;
                  l_in_tbl(l_counter).serial_number := serial_rec.serial_number;
                  l_counter := l_counter + 1;
                  l_serial_not_found := FALSE;
              END LOOP;

              IF l_serial_not_found THEN
                trace('Item is serial number control. No serial Number found !!!');
                   FND_MESSAGE.SET_NAME('INV', 'WMS_SERIAL_FOUND');
                   FND_MSG_PUB.ADD;
                   RAISE SERIAL_EXCEPTION;
	           -- Bug 2882958
	           ELSE
	              -- Reduce l_count to avoid extra increment
	              l_counter := l_counter - 1;
              END IF;
           ELSE
               l_in_tbl(l_counter) := l_in_rec;
           END IF;
        END LOOP;
        CLOSE flow_complete_mmtt_lpn_curs;
     END IF;

     IF (l_counter = 0)  THEN
        IF (l_debug = 1) THEN
           trace(' No material found for Transaction ID:'||p_transaction_id);
        END IF;
        RAISE NO_FLOW_DATA_FOUND_X;
     END IF ;

   ELSIF (l_transaction_identifier = MTI_TYPE ) THEN
     OPEN flow_complete_mti_curs;
     LOOP
     FETCH flow_complete_mti_curs INTO l_in_rec;
     EXIT WHEN flow_complete_mti_curs%NOTFOUND;
        l_counter := l_counter + 1;
        l_transaction_id := l_in_rec.transaction_id;
        IF (l_in_rec.serial_number_control_code in (2,5,6) ) THEN
           -- The item is serial control
           -- initialize serial_number to check for error
           l_serial_not_found := TRUE;
           -- Bug 2882958, add lot_number to cursor mti_serial_curs
           FOR serial_rec IN mti_serial_curs(l_in_rec.lot_number) LOOP
               l_in_tbl(l_counter) := l_in_rec;
               l_in_tbl(l_counter).serial_number := serial_rec.serial_number;
               l_counter := l_counter + 1;
               l_serial_not_found := FALSE;
           END LOOP;

           IF l_serial_not_found THEN
               IF (l_debug = 1) THEN
                  trace('Item is serial number control. No serial Number found !!!');
               END IF;
                FND_MESSAGE.SET_NAME('INV', 'WMS_SERIAL_FOUND');
                FND_MSG_PUB.ADD;
                RAISE SERIAL_EXCEPTION;
           -- Bug 2882958
           ELSE
              -- Reduce l_count to avoid extra increment
              l_counter := l_counter - 1;
           END IF;
        ELSE
           l_in_tbl(l_counter) := l_in_rec;
        END IF;
     END LOOP;
     CLOSE flow_complete_mti_curs;

     IF (l_counter = 0)  THEN
        IF (l_debug = 1) THEN
           trace(' No material found for Interface Transaction ID:'|| p_transaction_id);
        END IF;
        RAISE NO_FLOW_DATA_FOUND_X;
     END IF ;

  ELSIF (l_transaction_identifier = MTRL_TYPE ) THEN

     OPEN flow_complete_mtrl_curs;
     LOOP
     FETCH flow_complete_mtrl_curs INTO l_in_rec;
     EXIT WHEN flow_complete_mtrl_curs%NOTFOUND;
        l_counter := l_counter + 1;
        l_transaction_id := l_in_rec.transaction_id;
        IF (l_in_rec.serial_number_control_code in (2,5,6) ) THEN
           -- The item is serial control
           IF (l_debug = 1) THEN
              trace(' Before call to  GET_SERIALS_BETWEEN_RANGE');
           END IF;
           IF (l_in_rec.serial_number_start) <> (l_in_rec.serial_number_end) THEN
              INV_LABEL.GET_NUMBER_BETWEEN_RANGE(
                  fm_x_number => l_in_rec.serial_number_start
                 ,to_x_number => l_in_rec.serial_number_end
                 ,x_return_status => l_return_status
                 ,x_number_table => l_serial_numbers_table);
              IF l_return_status <> 'S' THEN
                FND_MESSAGE.SET_NAME('WMS', 'WMS_GET_SER_CUR_FAILED');
                FND_MSG_PUB.ADD;
                RAISE SERIAL_EXCEPTION;
              END IF;

              FOR j IN 1..l_serial_numbers_table.count LOOP
                 l_in_tbl(l_counter) := l_in_rec;
                 l_in_tbl(l_counter).serial_number := l_serial_numbers_table(j);
                 l_counter := l_counter + 1;

              END LOOP;
              IF ( l_serial_numbers_table.count = 0) THEN
                 IF (l_debug = 1) THEN
                    trace('Item is serial number control. No serial Number found !!! ');
                 END IF;
                 FND_MESSAGE.SET_NAME('INV', 'WMS_SERIAL_FOUND');
                 FND_MSG_PUB.ADD;
                 RAISE SERIAL_EXCEPTION;

              END IF;

           END IF;
        ELSE
           l_in_tbl(l_counter) := l_in_rec;
        END IF;
     END LOOP;
     CLOSE flow_complete_mtrl_curs;

     IF (l_counter = 0)  THEN
        IF (l_debug = 1) THEN
           trace(' No material found for Move Order Line ID:'||p_transaction_id);
        END IF;
        RAISE NO_FLOW_DATA_FOUND_X;
     END IF ;

  ELSIF (l_transaction_identifier = WFS_TYPE ) THEN
     -- Bug 2728468 Adhoc printing enabled for schedules that is not completed yet.
     -- Remove the following query from MMTT because from adhoc printing does not
     -- look at schedules that is being processed.
     /*OPEN flow_schedule_mmtt_curs;
     LOOP
     FETCH flow_schedule_mmtt_curs INTO l_in_rec;
     EXIT WHEN flow_schedule_mmtt_curs%NOTFOUND;
        l_counter := l_counter + 1;
        l_transaction_id := l_in_rec.transaction_id;
        l_in_tbl(l_counter) := l_in_rec;
        IF (l_in_rec.serial_number_control_code in (2,5,6) ) THEN
           -- The item is serial control
           -- initialize serial_number to check for error
           l_serial_not_found := TRUE;
           FOR serial_rec IN serial_curs LOOP
               l_in_tbl(l_counter) := l_in_rec;
               l_in_tbl(l_counter).serial_number := serial_rec.serial_number;
               l_counter := l_counter + 1;
               l_serial_not_found := FALSE;

           END LOOP;

           IF l_serial_not_found THEN
               IF (l_debug = 1) THEN
                  trace('Item is serial number control. No serial Number found ');
               END IF;
                FND_MESSAGE.SET_NAME('INV', 'WMS_SERIAL_FOUND');
                FND_MSG_PUB.ADD;
        --        RAISE SERIAL_EXCEPTION;
           END IF;
        ELSE
           l_in_tbl(l_counter) := l_in_rec;
        END IF;
     END LOOP;
     CLOSE flow_schedule_mmtt_curs;*/
     OPEN flow_schedule_mmt_curs;
     -- Attempt to retrieve lot/serial from mmt
     LOOP
     FETCH flow_schedule_mmt_curs INTO l_in_rec;
     EXIT WHEN flow_schedule_mmt_curs%NOTFOUND;
        l_counter := l_counter + 1;
        l_transaction_id := l_in_rec.transaction_id;
        l_in_tbl(l_counter) := l_in_rec;
        IF (l_in_rec.serial_number_control_code in (2,5,6) ) THEN
           -- The item is serial control
           -- initialize serial_number to check for error
           l_serial_not_found := TRUE;
           FOR serial_rec IN serial_curs LOOP
               l_in_tbl(l_counter) := l_in_rec;
               l_in_tbl(l_counter).serial_number := serial_rec.serial_number;
               l_counter := l_counter + 1;
               l_serial_not_found := FALSE;

           END LOOP;

           IF l_serial_not_found THEN
               IF (l_debug = 1) THEN
                  trace('Item is serial number control. No serial Number found ');
               END IF;
                FND_MESSAGE.SET_NAME('INV', 'WMS_SERIAL_FOUND');
                FND_MSG_PUB.ADD;
        --        RAISE SERIAL_EXCEPTION;
           END IF;
        ELSE
           l_in_tbl(l_counter) := l_in_rec;
        END IF;
     END LOOP;
     CLOSE flow_schedule_mmt_curs;

     -- Bug 2728468 Adhoc printing enabled for schedules that is not completed yet.
     -- Added new cursor of flow_schedule_wfs_curs to retrieve schedule information
     -- from WIP_FLOW_SCHEDULES
     IF (l_in_rec.transaction_id IS NULL) THEN
        l_counter := 0;
     -- When no MMT record for the schedule, query directly from WFS
        OPEN flow_schedule_wfs_curs;
        LOOP
        FETCH flow_schedule_wfs_curs INTO l_in_rec;
        EXIT WHEN flow_schedule_wfs_curs%NOTFOUND;
           l_counter := l_counter + 1;
           l_transaction_id := l_in_rec.transaction_id;
           l_in_tbl(l_counter) := l_in_rec;
        END LOOP;
        CLOSE flow_schedule_wfs_curs;

     END IF;

     IF (l_counter = 0)  THEN
        IF (l_debug = 1) THEN
           trace(' No material found for Wip Flow Schedule ID:'||p_transaction_id);
        END IF;
        RAISE NO_FLOW_DATA_FOUND_X;
     END IF ;

  ELSE
     IF (l_debug = 1) THEN
        trace(' Invalid transaction_identifier passed '||p_transaction_identifier);
     END IF;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_debug = 1) THEN
     trace(' Getting default format selected fields ');
  END IF;
  INV_LABEL.GET_VARIABLES_FOR_FORMAT(
      x_variables 		=> l_selected_fields
      ,x_variables_count	=> l_selected_fields_count
      ,p_format_id		=> p_label_type_info.default_format_id);

   IF (l_selected_fields_count=0) OR (l_selected_fields.count =0 ) THEN
      IF (l_debug = 1) THEN
         trace('no fields defined for this format: ' || p_label_type_info.default_format_id || ',' || p_label_type_info.default_format_name);
      END IF;
      RAISE NO_LABEL_FORMAT_FOUND_X;
   END IF;

   IF (l_debug = 1) THEN
      trace(' Found format ID and name : ' || p_label_type_info.default_format_id || p_label_type_info.default_format_name);
   END IF;

   IF (l_debug = 1) THEN
      trace(' Found variable defined for this format, cont = ' || l_selected_fields_count);
   END IF;

   l_content_rec_index := 0;
   IF (l_debug = 1) THEN
      trace('** in PVT10.get_variable_data ** , start ');
   END IF;
   l_prev_label_format_id := p_label_type_info.default_format_id;
   l_printer := p_label_type_info.default_printer;

   --
   -- Initialize l_prev_in_tbl
   --
   l_prev_in_tbl.inventory_item_id := -9999;
   l_prev_in_tbl.subinventory_code := '@';
   l_prev_in_tbl.lot_number    := -9999;
   l_prev_in_tbl.serial_number := -9999;
   l_prev_in_tbl.revision   := '@@@';
   l_prev_in_tbl.alternate_bom_designator := '@@@';
   l_prev_in_tbl.alternate_routing_designator := '@@@';
   l_prev_in_tbl.sale_header_id := -9999;
   l_prev_in_tbl.sale_line_id  := -9999;
   l_prev_in_tbl.kanban_card_id := -9999;
   l_prev_in_tbl.lpn_id       := -9999;
   l_prev_in_tbl.wip_entity_id := -9999;
   l_prev_in_tbl.lot_controL_code := -9999;
   l_prev_in_tbl.serial_number_control_code := -9999;

   l_prev_sub := '####';

   FOR i in 1..l_in_tbl.COUNT LOOP
    	l_content_item_data := '';
        IF (l_debug = 1) THEN
           trace(' New Flow Content label : in_tbl.COUNT = ' || l_in_tbl.COUNT);
           trace(' l_inventory_item_id='|| l_in_tbl(i).inventory_item_id ||
               ' l_organization_id='|| l_in_tbl(i).organization_id||
               ' l_subinventory_code='||l_in_tbl(i).subinventory_code||
               ' l_locator_id ='||l_in_tbl(i).locator_id);
           trace(' l_lot_number ='||l_in_tbl(i).lot_number||
               ' l_serial_number ='||l_in_tbl(i).serial_number ||
               ' l_serial_number_start ='|| l_in_tbl(i).serial_number_start||
               ' l_serial_number_end ='||l_in_tbl(i).serial_number_end);
           trace(' l_uom ='||l_in_tbl(i).uom||
               ' l_revision ='||l_in_tbl(i).revision||
               ' l_sale_header_id ='||l_in_tbl(i).sale_header_id||
               ' l_sale_line_id ='||l_in_tbl(i).sale_line_id);
           trace(' l_kanban_card_id ='||l_in_tbl(i).kanban_card_id ||
               ' l_lpn_id ='        ||l_in_tbl(i).lpn_id||
               ' l_wip_entity_id='  || l_in_tbl(i).wip_entity_id||
               ' l_schedule_number='|| l_in_tbl(i).schedule_number);
           trace(' l_lot_control_code ='||l_in_tbl(i).lot_control_code||
               ' l_serial_number_control_code ='|| l_in_tbl(i).serial_number_control_code||
               ' l_transaction_id ='|| l_in_tbl(i).transaction_id);
        END IF;

        IF (l_in_tbl(i).inventory_item_id) <> (l_prev_in_tbl.inventory_item_id) THEN
            get_data(l_out_tbl, l_in_tbl(i).wip_entity_id,
                     l_in_tbl(i).schedule_number,
                     l_in_tbl(i).inventory_item_id,
                     l_in_tbl(i).organization_id,
                     l_in_tbl(i).subinventory_code,
                     l_in_tbl(i).locator_id);

            get_data_bom_bill_header(l_out_tbl,
                     l_in_tbl(i).inventory_item_id,
                     l_in_tbl(i).organization_id,
                     l_in_tbl(i).alternate_bom_designator);

            get_data_bom_routing(l_out_tbl,
                     l_in_tbl(i).inventory_item_id,
                     l_in_tbl(i).organization_id,
                     l_in_tbl(i).alternate_routing_designator);
        END IF;


         IF (l_in_tbl(i).kanban_card_id IS NOT NULL) AND
            (l_in_tbl(i).kanban_card_id <> l_prev_in_tbl.kanban_card_id) THEN
            get_data_kanban(l_out_tbl, l_in_tbl(i).kanban_card_id);

         END IF;

         IF (l_in_tbl(i).lpn_id IS NOT NULL) AND
            (l_in_tbl(i).lpn_id <> l_prev_in_tbl.lpn_id) THEN
            get_data_LPN(l_out_tbl, l_in_tbl(i).lpn_id,
                         l_in_tbl(i).revision,
                         l_in_tbl(i).lot_number,
                         l_in_tbl(i).serial_number,
                         l_in_tbl(i).inventory_item_id
                        );
         END IF;

         IF (l_in_tbl(i).lot_number IS NOT NULL) AND
            (l_in_tbl(i).lot_number <> l_prev_in_tbl.lot_number) THEN
            get_data_lot(l_out_tbl, l_in_tbl(i).lot_number);
         END IF;


         IF (l_in_tbl(i).serial_number IS NOT NULL) AND
            (l_in_tbl(i).serial_number <> l_prev_in_tbl.serial_number) THEN
            get_data_serial(l_out_tbl,
                            l_in_tbl(i).inventory_item_id,
                            l_in_tbl(i).serial_number);
         END IF;


         IF ((l_in_tbl(i).sale_header_id IS NOT NULL) AND
            (l_in_tbl(i).sale_header_id <> l_prev_in_tbl.sale_header_id)) OR
            ((l_in_tbl(i).sale_line_id IS NOT NULL) AND
             (l_in_tbl(i).sale_line_id <> l_prev_in_tbl.sale_line_id)) THEN
            get_data_sale_header(l_out_tbl, l_in_tbl(i).sale_header_id,
                                 l_in_tbl(i).sale_line_id);
         END IF;


         -- =====================================
         -- Save the current input record
         -- =====================================
         l_prev_in_tbl := l_in_tbl(i);

	 IF (l_debug = 1) THEN
	    trace(' ^^^^^^^^^^^^^^^^^New LAbel^^^^^^^^^^^^^^^^^');


	    --R12 : RFID compliance project
	    --Calling rules engine before calling to get printer

	    IF (l_debug = 1) THEN
	       trace('Apply Rules engine for format, printer=' || l_printer ||',manual_format_id='||p_label_type_info.manual_format_id ||',manual_format_name='||p_label_type_info.manual_format_name);
	    END IF;


	    INV_LABEL.get_format_with_rule
	      (
	       p_document_id         => p_label_type_info.label_type_id,
	       P_LABEL_FORMAT_ID    => p_label_type_info.manual_format_id,
	       p_organization_id     => l_in_tbl(i).organization_id,
	       p_inventory_item_id   => l_in_tbl(i).inventory_item_id,
	       P_LAST_UPDATE_DATE    => sysdate,
	       P_LAST_UPDATED_BY     => FND_GLOBAL.user_id,
	       P_CREATION_DATE       => sysdate,
	       P_CREATED_BY          => FND_GLOBAL.user_id,
	       --P_PRINTER_NAME        => l_printer,-- Removed in R12: 4396558
	       P_BUSINESS_FLOW_CODE  => p_label_type_info.business_flow_code,
	       x_return_status       => l_return_status,
	       x_label_format_id     => l_label_format_id,
	       x_label_format        => l_label_format,
	       x_label_request_id    => l_label_request_id);

	    IF l_return_status <> 'S' THEN
	       FND_MESSAGE.SET_NAME('WMS', 'WMS_LABL_RULE_ENGINE_FAILED');
	       FND_MSG_PUB.ADD;
	       l_label_format:= p_label_type_info.default_format_id;
	       l_label_format_id:= p_label_type_info.default_format_name;
	    END IF;

	    IF (l_debug = 1) THEN
	       trace('did apply label ' || l_label_format || ',' || l_label_format_id||',req_id '||l_label_request_id);
	    END IF;



	    trace(' Getting printer, manual_printer='||p_label_type_info.manual_printer ||',sub='||l_subinventory_code ||',default printer='||p_label_type_info.default_printer);
	 END IF;

	 IF p_label_type_info.manual_printer IS NULL THEN
	    -- The p_label_type_info.manual_printer is the one  passed from the manual page.
		-- As per the design, if a printer is passed from the manual page, then we use that printer irrespective.
	    IF (l_subinventory_code IS NOT NULL) AND (l_subinventory_code <> l_prev_sub)THEN
	       IF (l_debug = 1) THEN
		  trace('getting printer with sub '||l_subinventory_code);
	       END IF;
				BEGIN
				   WSH_REPORT_PRINTERS_PVT.get_printer
				     (
				      p_concurrent_program_id=>p_label_type_info.label_type_id,
				      p_user_id              =>fnd_global.user_id,
				      p_responsibility_id    =>fnd_global.resp_id,
				      p_application_id       =>fnd_global.resp_appl_id,
				      p_organization_id      =>l_organization_id,
				      p_zone                 =>l_subinventory_code,
				      p_format_id            =>l_label_format_id, --added in r12 RFID 4396558
				      x_printer              =>l_printer,
				      x_api_status           =>l_api_status,
				      x_error_message        =>l_error_message);
				   IF l_api_status <> 'S' THEN
				      IF (l_debug = 1) THEN
					 trace('Error in calling get_printer, set printer as default printer, err_msg:'||l_error_message);
				      END IF;
				      l_printer := p_label_type_info.default_printer;
				   END IF;
				EXCEPTION
				   WHEN others THEN
				      l_printer := p_label_type_info.default_printer;
				END;
				l_prev_sub := l_subinventory_code;
	    END IF;
	  ELSE
	       IF (l_debug = 1) THEN
		  trace('Set printer as Manual Printer passed in:' || p_label_type_info.manual_printer );
	       END IF;
	       l_printer := p_label_type_info.manual_printer;
	 END IF;



	IF p_label_type_info.manual_format_id IS NOT NULL THEN
	   l_label_format_id := p_label_type_info.manual_format_id;
	   l_label_format := p_label_type_info.manual_format_name;
	   IF (l_debug = 1) THEN
	      trace('Manual format passed in:'||l_label_format_id||','||l_label_format);
	   END IF;
	   	END IF;
	   	IF (l_label_format_id IS NOT NULL) THEN
	   		-- Derive the fields for the format either passed in or derived via the rules engine.
	   		IF l_label_format_id <> nvl(l_prev_label_format_id, -999) THEN
	   			IF (l_debug = 1) THEN
   	   			trace(' Getting variables for new format ' || l_label_format);
	   			END IF;
	   			INV_LABEL.GET_VARIABLES_FOR_FORMAT(
	   				x_variables 		=> l_selected_fields
	   			,	x_variables_count	=> l_selected_fields_count
	   			,	p_format_id		=> l_label_format_id);

	   			l_prev_label_format_id := l_label_format_id;

	   			IF (l_selected_fields_count=0) OR (l_selected_fields.count =0 ) THEN
	   				IF (l_debug = 1) THEN
   	   				trace('no fields defined for this format: ' || l_label_format|| ',' ||l_label_format_id);
	   				END IF;
	   				GOTO NextLabel;
	   			END IF;
	   			IF (l_debug = 1) THEN
   	   			trace('   Found selected_fields for format ' || l_label_format ||', num='|| l_selected_fields_count);
	   			END IF;
	   		END IF;
	   	ELSE
	   		IF (l_debug = 1) THEN
   	   		trace('No format exists for this label, goto nextlabel');
	   		END IF;
	   		GOTO NextLabel;
	   	END IF;

	    /* variable header */
	   	l_content_item_data := l_content_item_data || LABEL_B;
	   	IF l_label_format <> nvl(p_label_type_info.default_format_name, '@@@') THEN
	   		l_content_item_data := l_content_item_data || ' _FORMAT="' || nvl(p_label_type_info.manual_format_name, l_label_format) || '"';
	   	END IF;
	   	IF (l_printer IS NOT NULL) AND (l_printer <> nvl(p_label_type_info.default_printer,'###')) THEN
	   		l_content_item_data := l_content_item_data || ' _PRINTERNAME="'||l_printer||'"';
	   	END IF;

	   	l_content_item_data := l_content_item_data || TAG_E;
 		IF (l_debug = 1) THEN
    		trace('Starting assign variables, ');
 		END IF;

      /* Modified for Bug 4072474 -start*/
		l_custom_sql_ret_status := FND_API.G_RET_STS_SUCCESS;
		/* Modified for Bug 4072474 -End*/

      -- Fix for bug: 4179593 Start
      l_CustSqlWarnFlagSet := FALSE;
      l_CustSqlErrFlagSet := FALSE;
      l_CustSqlWarnMsg := NULL;
      l_CustSqlErrMsg := NULL;
      -- Fix for bug: 4179593 End

	   -- Loop for each selected fields, find the columns and write into the XML_content
	   FOR i IN 1..l_selected_fields.count LOOP
              l_field_id := l_selected_fields(i).label_field_id;
             -- trace('      -- In selected_fields loop , column_name ='||
             --        l_selected_fields(i).column_name);

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--  The check (SQL_STMT <> NULL and COLUMN_NAME = NULL) implies that the field is a          |
--  Custom SQL based field. Handle it appropriately.                                         |
---------------------------------------------------------------------------------------------
         		  IF (l_selected_fields(i).SQL_STMT IS NOT NULL AND l_selected_fields(i).column_name = 'sql_stmt') THEN
         			 IF (l_debug = 1) THEN
         			  trace('Custom Labels Trace [INVLA10B.pls]: ------------------------- REPORT BEGIN-------------------------------------');
         			  trace('Custom Labels Trace [INVLA10B.pls]: LABEL_FIELD_ID       : ' || l_selected_fields(i).label_field_id);
         			  trace('Custom Labels Trace [INVLA10B.pls]: FIELD_VARIABLE_NAME  : ' || l_selected_fields(i).variable_name);
         			  trace('Custom Labels Trace [INVLA10B.pls]: COLUMN_NAME          : ' || l_selected_fields(i).column_name);
         			  trace('Custom Labels Trace [INVLA10B.pls]: SQL_STMT             : ' || l_selected_fields(i).sql_stmt);
         			 END IF;
         			 l_sql_stmt := l_selected_fields(i).sql_stmt;
         			 IF (l_debug = 1) THEN
         			  trace('Custom Labels Trace [INVLA10B.pls]: l_sql_stmt BEFORE REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
         			 END IF;
         			 l_sql_stmt := l_sql_stmt || ' AND WLR.LABEL_REQUEST_ID = :REQUEST_ID';
         			 IF (l_debug = 1) THEN
         			  trace('Custom Labels Trace [INVLA10B.pls]: l_sql_stmt AFTER REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
         			 END IF;
         			 BEGIN
         			 IF (l_debug = 1) THEN
         			  trace('Custom Labels Trace [INVLA10B.pls]: At Breadcrumb 1');
         			  trace('Custom Labels Trace [INVLA10B.pls]: LABEL_REQUEST_ID     : ' || l_label_request_id);
         			 END IF;
         			 OPEN c_sql_stmt FOR l_sql_stmt using l_label_request_id;
         			 LOOP
         				 FETCH c_sql_stmt INTO l_sql_stmt_result;
         				 EXIT WHEN c_sql_stmt%notfound OR c_sql_stmt%rowcount >=2;
         			 END LOOP;

                   IF (c_sql_stmt%rowcount=1 AND l_sql_stmt_result IS NULL) THEN
                     x_return_status := FND_API.G_RET_STS_SUCCESS;
                     l_custom_sql_ret_status  := INV_LABEL.G_WARNING;
                     fnd_message.set_name('WMS','WMS_CS_NULL_VALUE_RETURNED');
                     fnd_msg_pub.ADD;
                     -- Fix for bug: 4179593 Start
                     --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                     l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                     l_CustSqlWarnMsg := l_custom_sql_ret_msg;
                     l_CustSqlWarnFlagSet := TRUE;
                     -- Fix for bug: 4179593 End

                     IF (l_debug = 1) THEN
                        trace('Custom Labels Trace [INVLA10B.pls]: At Breadcrumb 2');
                        trace('Custom Labels Trace [INVLA10B.pls]: l_sql_stmt_result is: ' || l_sql_stmt_result);
                        trace('Custom Labels Trace [INVLA10B.pls]: WARNING: NULL value returned by the custom SQL Query.');
                        trace('Custom Labels Trace [INVLA10B.pls]: l_custom_sql_ret_status  is set to : ' || l_custom_sql_ret_status );
                     END IF;
                   ELSIF c_sql_stmt%rowcount=0 THEN
         				IF (l_debug = 1) THEN
         				 trace('Custom Labels Trace [INVLA10B.pls]: At Breadcrumb 3');
         				 trace('Custom Labels Trace [INVLA10B.pls]: WARNING: No row returned by the Custom SQL query');
         				END IF;
                     x_return_status := FND_API.G_RET_STS_SUCCESS;
                     l_custom_sql_ret_status  := INV_LABEL.G_WARNING;
         				fnd_message.set_name('WMS','WMS_CS_NO_DATA_FOUND');
         				fnd_msg_pub.ADD;
                     /* Replaced following statement for Bug 4207625: Anupam Jain*/
         				/*fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_status);*/
                     -- Fix for bug: 4179593 Start
                     --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                     l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                     l_CustSqlWarnMsg := l_custom_sql_ret_msg;
                     l_CustSqlWarnFlagSet := TRUE;
                     -- Fix for bug: 4179593 End
         			 ELSIF c_sql_stmt%rowcount>=2 THEN
         				IF (l_debug = 1) THEN
         				 trace('Custom Labels Trace [INVLA10B.pls]: At Breadcrumb 4');
         				 trace('Custom Labels Trace [INVLA10B.pls]: ERROR: Multiple values returned by the Custom SQL query');
         				END IF;
                     l_sql_stmt_result := NULL;
                     x_return_status := FND_API.G_RET_STS_SUCCESS;
                     l_custom_sql_ret_status  := FND_API.G_RET_STS_ERROR;
         				fnd_message.set_name('WMS','WMS_CS_MULTIPLE_VALUES_RETURN');
         				fnd_msg_pub.ADD;
                     /* Replaced following statement for Bug 4207625: Anupam Jain*/
         				/*fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_status);*/
                     -- Fix for bug: 4179593 Start
                     --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                     l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                     l_CustSqlErrMsg := l_custom_sql_ret_msg;
                     l_CustSqlErrFlagSet := TRUE;
                     -- Fix for bug: 4179593 End
         			 END IF;
                   IF (c_sql_stmt%ISOPEN) THEN
	                  CLOSE c_sql_stmt;
                   END IF;
         			EXCEPTION
         			WHEN OTHERS THEN
                   IF (c_sql_stmt%ISOPEN) THEN
	                  CLOSE c_sql_stmt;
                   END IF;
         			  IF (l_debug = 1) THEN
         				trace('Custom Labels Trace [INVLA10B.pls]: At Breadcrumb 5');
         				trace('Custom Labels Trace [INVLA10B.pls]: Unexpected Error has occured in GET_VARIABLES_DATA');
         			  END IF;
         			  x_return_status := FND_API.G_RET_STS_ERROR;
         			  fnd_message.set_name('WMS','WMS_CS_WRONG_SQL_CONSTRUCT');
         			  fnd_msg_pub.ADD;
         			  fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
         			  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         		   END;
         		   IF (l_debug = 1) THEN
         			  trace('Custom Labels Trace [INVLA10B.pls]: At Breadcrumb 6');
         			  trace('Custom Labels Trace [INVLA10B.pls]: Before assigning it to l_content_item_data');
         		   END IF;
         			l_content_item_data  :=   l_content_item_data
         							   || variable_b
         							   || l_selected_fields(i).variable_name
         							   || '">'
         							   || l_sql_stmt_result
         							   || variable_e;
         			l_sql_stmt_result := NULL;
         			l_sql_stmt        := NULL;
         			IF (l_debug = 1) THEN
         			  trace('Custom Labels Trace [INVLA10B.pls]: At Breadcrumb 7');
         			  trace('Custom Labels Trace [INVLA10B.pls]: After assigning it to l_content_item_data');
                    trace('Custom Labels Trace [INVLA10B.pls]: --------------------------REPORT END-------------------------------------');
         			END IF;
 ------------------------End of this change for Custom Labels project code--------------------
         	  ELSIF LOWER(l_selected_fields(i).column_name) = 'current_date' THEN
	              l_content_item_data := l_content_item_data || VARIABLE_B ||
				     l_selected_fields(i).variable_name ||
                                    '">' || INV_LABEL.G_DATE || VARIABLE_E;
              ELSIF LOWER(l_selected_fields(i).column_name) = 'current_time' THEN
                 l_content_item_data := l_content_item_data || VARIABLE_B ||
					l_selected_fields(i).variable_name ||
                                    '">' || INV_LABEL.G_TIME || VARIABLE_E;
              ELSIF LOWER(l_selected_fields(i).column_name) = 'request_user' THEN
                  l_content_item_data := l_content_item_data || VARIABLE_B ||
                                      l_selected_fields(i).variable_name ||
                                     '">' || INV_LABEL.G_USER || VARIABLE_E;
              ELSE
                 l_field_value := '';
              --trace('   Finished writing variables ');
                 IF (l_out_tbl.EXISTS(l_field_id) ) THEN
                    l_field_value := l_out_tbl(l_field_id).datbuf;
                 END IF;

                 l_content_item_data := l_content_item_data || VARIABLE_B ||
                                  l_selected_fields(i).variable_name || '">' ||
                                  l_field_value ||
                                        VARIABLE_E;
              END IF;

              --trace('   Finished writing variables ');
	   END LOOP;
       l_content_item_data := l_content_item_data || LABEL_E;
	   x_variable_content(l_label_index).label_content :=  l_content_item_data ;
	   x_variable_content(l_label_index).label_request_id := l_label_request_id;

------------------------Start of changes for Custom Labels project code------------------

        -- Fix for bug: 4179593 Start
        IF (l_CustSqlWarnFlagSet) THEN
         l_custom_sql_ret_status := INV_LABEL.G_WARNING;
         l_custom_sql_ret_msg := l_CustSqlWarnMsg;
        END IF;

        IF (l_CustSqlErrFlagSet) THEN
         l_custom_sql_ret_status := FND_API.G_RET_STS_ERROR;
         l_custom_sql_ret_msg := l_CustSqlErrMsg;
        END IF;
        -- Fix for bug: 4179593 End

        x_variable_content(l_label_index).label_status      := l_custom_sql_ret_status ;
        x_variable_content(l_label_index).error_message     := l_custom_sql_ret_msg;
------------------------End of this changes for Custom Labels project code---------------

	   IF (l_debug = 1) THEN
   	   trace('LENGTH : ' || length(x_variable_content(l_label_index).label_content));
	   END IF;
       l_label_index := l_label_index + 1;
 		<<NextLabel>>
 		l_content_item_data := '';
 		l_label_request_id := null;

------------------------Start of changes for Custom Labels project code------------------
        l_custom_sql_ret_status  := NULL;
        l_custom_sql_ret_msg    := NULL;
------------------------End of this changes for Custom Labels project code---------------

   END LOOP;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN SERIAL_EXCEPTION THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN NO_FLOW_DATA_FOUND_X THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN NO_LABEL_FORMAT_FOUND_X THEN
     FND_MESSAGE.SET_NAME('WMS', 'WMS_LABL_NO_LABEL_CREATED');
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;



END get_variable_data;

END INV_LABEL_PVT10;

/
