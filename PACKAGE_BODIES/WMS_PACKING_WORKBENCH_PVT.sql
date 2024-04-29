--------------------------------------------------------
--  DDL for Package Body WMS_PACKING_WORKBENCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_PACKING_WORKBENCH_PVT" AS
/* $Header: WMSPACVB.pls 120.13.12010000.5 2010/04/12 23:48:11 sfulzele ship $ */

--  Global constant holding the package name
g_pkg_name CONSTANT VARCHAR2(30) := 'WMS_PACKING_WORKBENCH_PVT';
g_pkg_version CONSTANT VARCHAR2(100) := '$Header: WMSPACVB.pls 120.13.12010000.5 2010/04/12 23:48:11 sfulzele ship $';

-- Lot Serial Attributes
g_lot_ser_attr INV_LOT_SEL_ATTR.lot_sel_attributes_tbl_type;
G_DATE_MASK VARCHAR2(100) := 'YYYY/MM/DD';

g_kit_count_current_comp NUMBER :=0 ;

/*==========================
  Private Procedure
  =========================*/
PROCEDURE trace(p_message IN VARCHAR2,
                p_level IN NUMBER DEFAULT 1 ) IS
BEGIN
    INV_LOG_UTIL.trace(p_message, 'PackingWB', p_level);
END trace;


/********************************************
 Procedure to insert into WMS_PACKING_MATERIAL_GTEMP
 *******************************************/
PROCEDURE insert_material_rec(
    p_material_rec IN WMS_PACKING_MATERIAL_GTEMP%ROWTYPE) IS

BEGIN
    INSERT INTO WMS_PACKING_MATERIAL_GTEMP(
      MOVE_ORDER_HEADER_ID
    , MOVE_ORDER_LINE_ID
    , REFERENCE
    , REFERENCE_ID
    , TXN_SOURCE_ID
    , DELIVERY_DETAIL_ID
    , ORGANIZATION_ID
    , ORGANIZATION_CODE
    , SUBINVENTORY
    , LOCATOR_ID
    , LOCATOR
    , PROJECT_ID
    , PROJECT
    , TASK_ID
    , TASK_NUMBER
    , TASK_NAME
    , INVENTORY_ITEM_ID
    , ITEM
    , ITEM_DESCRIPTION
    , LPN_ID
    , LPN
    , PARENT_LPN_ID
    , PARENT_LPN
    , OUTERMOST_LPN_ID
    , OUTERMOST_LPN
    , REVISION
    , UOM
    , LOT_NUMBER
    , QUANTITY
    , DELIVERY_ID
    , DELIVERY
    , DELIVERY_COMPLETED
    , TRIP_ID
    , TRIP
    , CARRIER_ID
    , CARRIER
    , ORDER_HEADER_ID
    , ORDER_NUMBER
    , ORDER_LINE_ID
    , ORDER_LINE_NUM
    , PACKING_INSTRUCTION
    , CUSTOMER_ID
    , CUSTOMER_NUMBER
    , CUSTOMER_NAME
    , SHIP_TO_LOCATION_ID
    , SHIP_TO_LOCATION
    , RECEIPT_NUM
    , DOCUMENT_TYPE
    , DOCUMENT_ID
    , DOCUMENT_NUMBER
    , DOCUMENT_LINE_ID
    , DOCUMENT_LINE_NUM
    , VENDOR_ID
    , SOURCE_ORG_ID
    , TRADING_PARTNER
    , RECEIVING_LOCATION_ID
    , RECEIVING_LOCATION
    , PTO_FLAG
    , SELECTED_FLAG
    , SHIP_SET_ID
    , SHIP_SET
    --INVCONV KKILLAMS
    , SECONDARY_UOM_CODE
    , SECONDARY_QUANTITY
    , GRADE_CODE
    --INVCONV KKILLAMS
    )
    VALUES(
      p_material_rec.MOVE_ORDER_HEADER_ID
    , p_material_rec.MOVE_ORDER_LINE_ID
    , p_material_rec.REFERENCE
    , p_material_rec.REFERENCE_ID
    , p_material_rec.TXN_SOURCE_ID
    , p_material_rec.DELIVERY_DETAIL_ID
    , p_material_rec.ORGANIZATION_ID
    , p_material_rec.ORGANIZATION_CODE
    , p_material_rec.SUBINVENTORY
    , p_material_rec.LOCATOR_ID
    , p_material_rec.LOCATOR
    , p_material_rec.PROJECT_ID
    , p_material_rec.PROJECT
    , p_material_rec.TASK_ID
    , p_material_rec.TASK_NUMBER
    , p_material_rec.TASK_NAME
    , p_material_rec.INVENTORY_ITEM_ID
    , p_material_rec.ITEM
    , p_material_rec.ITEM_DESCRIPTION
    , p_material_rec.LPN_ID
    , p_material_rec.LPN
    , p_material_rec.PARENT_LPN_ID
    , p_material_rec.PARENT_LPN
    , p_material_rec.OUTERMOST_LPN_ID
    , p_material_rec.OUTERMOST_LPN
    , p_material_rec.REVISION
    , p_material_rec.UOM
    , p_material_rec.LOT_NUMBER
    , p_material_rec.QUANTITY
    , p_material_rec.DELIVERY_ID
    , p_material_rec.DELIVERY
    , p_material_rec.DELIVERY_COMPLETED
    , p_material_rec.TRIP_ID
    , p_material_rec.TRIP
    , p_material_rec.CARRIER_ID
    , p_material_rec.CARRIER
    , p_material_rec.ORDER_HEADER_ID
    , p_material_rec.ORDER_NUMBER
    , p_material_rec.ORDER_LINE_ID
    , p_material_rec.ORDER_LINE_NUM
    , p_material_rec.PACKING_INSTRUCTION
    , p_material_rec.CUSTOMER_ID
    , p_material_rec.CUSTOMER_NUMBER
    , p_material_rec.CUSTOMER_NAME
    , p_material_rec.SHIP_TO_LOCATION_ID
    , p_material_rec.SHIP_TO_LOCATION
    , p_material_rec.RECEIPT_NUM
    , p_material_rec.DOCUMENT_TYPE
    , p_material_rec.DOCUMENT_ID
    , p_material_rec.DOCUMENT_NUMBER
    , p_material_rec.DOCUMENT_LINE_ID
    , p_material_rec.DOCUMENT_LINE_NUM
    , p_material_rec.VENDOR_ID
    , p_material_rec.SOURCE_ORG_ID
    , p_material_rec.TRADING_PARTNER
    , p_material_rec.RECEIVING_LOCATION_ID
    , p_material_rec.RECEIVING_LOCATION
    , p_material_rec.PTO_FLAG
    , nvl(p_material_rec.SELECTED_FLAG,'N')
    , p_material_rec.SHIP_SET_ID
    , p_material_rec.SHIP_SET
    --INVCONV kkillams
    , p_material_rec.SECONDARY_UOM_CODE
    , p_material_rec.SECONDARY_QUANTITY
    , p_material_rec.GRADE_CODE
    --INVCONV kkillams
    );

EXCEPTION
    WHEN others THEN
        IF l_debug = 1 THEN
            trace('Error in insert_material_rec()');
            trace('ERROR CODE = ' || SQLCODE);
            trace('ERROR MESSAGE = ' || SQLERRM);
        END IF;
END insert_material_rec;

PROCEDURE check_against_rcv
  (  p_mol_rec IN WMS_PACKING_MATERIAL_GTEMP%ROWTYPE
   , p_document_type IN VARCHAR2 DEFAULT NULL
   , p_document_id IN NUMBER DEFAULT NULL
   , p_document_line_id IN NUMBER DEFAULT NULL
   , p_receipt_num IN VARCHAR2 DEFAULT NULL
   , p_partner_id IN NUMBER DEFAULT NULL
   , p_partner_type IN NUMBER DEFAULT NULL
   , p_rcv_location_id IN NUMBER DEFAULT NULL
   , x_valid OUT nocopy VARCHAR2
   , x_unique OUT nocopy VARCHAR2
   , x_receipt_num OUT nocopy varchar2
   , x_rcv_location_id OUT nocopy NUMBER
   , x_vendor_id OUT nocopy NUMBER
   , x_from_org_id OUT nocopy NUMBER
     ) IS
   l_cursor NUMBER;
   l_last_error_pos NUMBER;
   l_temp_str VARCHAR2(100);
   l_query_sql VARCHAR2(10000);
   l_select_str VARCHAR2(2000);
   l_from_str VARCHAR2(2000);
   l_where_str VARCHAR2(2000);

   l_receipt_num VARCHAR2(30);
   l_location_id NUMBER;
   l_vendor_id NUMBER;
   l_from_organization_id NUMBER;

   l_document_unique NUMBER;
   l_prev_location_id NUMBER;
   l_location_exists NUMBER;
   l_location_unique NUMBER;
   l_prev_receipt VARCHAR2(30);
   l_receipt_exists NUMBER;
   l_receipt_unique NUMBER;
   l_prev_partner_id NUMBER;
   l_partner_exists NUMBER;
   l_partner_unique NUMBER;
   l_rcv_transaction_id NUMBER;

   p_n NUMBER;
   p_v VARCHAR2(256);

   l_return NUMBER;

   l_progress VARCHAR2(10);
   l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      trace('Entering check_against_rcv...');
      trace(' p_document_type        => '||p_document_type);
      trace(' p_mol_rec.reference    => '||p_mol_rec.reference );
      trace(' p_document_id          => '||p_document_id);
      trace(' p_mol_rec.reference_id => '||p_mol_rec.reference_id);
   END IF;

   x_valid := 'N';
   x_unique := 'Y';

   IF ((p_mol_rec.reference IS NOT NULL)
       AND
       ((p_document_type = 'PO'
    AND p_mol_rec.reference <>'PO_LINE_LOCATION_ID')
   OR (p_document_type IN ('ASN','INTSHIP','REQ')
       AND p_mol_rec.reference <>'SHIPMENT_LINE_ID')
   OR (p_document_type IN ('ASN','INTSHIP')
       AND p_mol_rec.reference = 'SHIPMENT_LINE_ID'
       AND p_document_line_id IS NOT NULL
       AND p_mol_rec.reference_id <> p_document_line_id)
   OR (p_document_type = 'RMA'
       AND p_mol_rec.reference <> 'ORDER_LINE_ID')
   )) THEN
      x_valid := 'N';
      IF (l_debug = 1) THEN
    trace('Sanity test failed.  Skip this record');
      END IF;
      RETURN;
   END IF;

   IF (p_document_type IS NULL AND
       p_document_id IS NULL AND
       p_document_line_id IS NULL AND
       p_receipt_num IS NULL AND
       p_partner_id IS NULL AND
       p_partner_type IS NULL AND
       p_rcv_location_id IS NULL) THEN
      x_valid := 'Y';
      IF (l_debug = 1) THEN
    trace('No futher validation is necessary.  This record is OK');
      END IF;
      RETURN;
   END IF;

   l_select_str := 'SELECT DISTINCT';
   l_select_str := l_select_str || ' rsh.receipt_num,';
   l_select_str := l_select_str || ' rs.location_id,';
   l_select_str := l_select_str || ' rsh.vendor_id,';
   l_select_str := l_select_str || ' rsl.from_organization_id,';
   l_select_str := l_select_str || ' rs.rcv_transaction_id';

   l_from_str := ' FROM rcv_supply rs,';
   l_from_str := l_from_str || ' rcv_transactions rt,';
   l_from_str := l_from_str || ' rcv_shipment_lines rsl,';
   l_from_str := l_from_str || ' rcv_shipment_headers rsh';

   l_where_str := ' WHERE rs.supply_source_id = rt.transaction_id';
   l_where_str := l_where_str || ' AND rs.to_organization_id = :org_id';
   l_where_str := l_where_str || ' AND rs.supply_type_code = ''RECEIVING''';

   l_where_str := l_where_str || ' AND rs.item_id = :inventory_item_id';
   l_where_str := l_where_str || ' AND nvl(rs.item_revision,''$@$'') = nvl(:revision,nvl(rs.item_revision,''$@$''))';
   l_where_str := l_where_str || ' AND nvl(rt.project_id, -999) = nvl(:project_id, -999)';
   l_where_str := l_where_str || ' AND nvl(rt.task_id, -999) = nvl(:task_id, -999)';
   l_where_str := l_where_str || ' AND rs.shipment_line_id = rsl.shipment_line_id';
   l_where_str := l_where_str || ' AND rsl.shipment_header_id = rsh.shipment_header_id';

   IF (p_mol_rec.subinventory IS NOT NULL) THEN
      l_where_str := l_where_str || ' AND nvl(rt.subinventory, ''&*&'') = :subinventory_code';
    ELSE
      l_where_str := l_where_str || ' AND nvl(rt.subinventory, ''&*&'') = ''&*&''';
   END IF;

   IF (p_mol_rec.locator_id IS NOT NULL) THEN
      l_where_str := l_where_str || ' AND nvl(rt.locator_id, -999) = :locator_id';
    ELSE
      l_where_str := l_where_str || ' AND nvl(rt.locator_id, -999) = -999';
   END IF;

   IF (p_mol_rec.lpn_id IS NOT NULL) THEN
      l_where_str := l_where_str || ' AND nvl(rs.lpn_id, -999) = :lpn_id';
    ELSE
      l_where_str := l_where_str || ' AND nvl(rs.lpn_id, -999) = -999';
   END IF;

   IF (p_document_type = 'PO' OR p_mol_rec.reference = 'PO_LINE_LOCATION_ID') THEN
      l_where_str := l_where_str||' AND rs.po_line_id IS NOT NULL';

      IF (p_mol_rec.reference_id IS NOT NULL) THEN
    l_where_str := l_where_str ||' AND rsl.po_line_location_id = :reference_id';
      END IF;

      IF (p_document_id IS NOT NULL) THEN
    l_where_str := l_where_str || ' AND rs.po_header_id = :document_id';
    IF p_document_line_id IS NOT NULL THEN
       l_where_str := l_where_str || ' AND rsl.po_line_id = :document_line_id';
    END IF;
      END IF;

    ELSIF (p_document_type IN ('ASN', 'INTSHIP') OR p_mol_rec.reference = 'SHIPMENT_LINE_ID') THEN
      IF (p_mol_rec.reference_id IS NOT NULL) THEN
    l_where_str := l_where_str || ' AND rsl.shipment_line_id = :reference_id';
      END IF;

      IF (p_document_type = 'ASN') THEN
    l_where_str := l_where_str || ' AND rsh.asn_type in (''ASN'', ''ASBN'')';
       ELSE
    l_where_str := l_where_str || ' AND nvl(rsh.asn_type,''NOT ASN'') not in (''ASN'', ''ASBN'')';
    l_where_str := l_where_str || ' AND rsh.receipt_source_code IN';
    l_where_str := l_where_str || ' (''INTERNAL ORDER'',''INVENTORY'')';
    l_where_str := l_where_str || '  AND rsh.ship_to_org_id = :org_id';
      END IF;

      IF (p_document_id IS NOT NULL) THEN
    l_where_str := l_where_str || ' AND rsl.shipment_header_id = :document_id';
    IF p_document_line_id IS NOT NULL THEN
       l_where_str := l_where_str || ' AND rsl.shipment_line_id = :document_line_id';
    END IF;
      END IF;
    ELSIF (p_document_type = 'REQ' OR p_mol_rec.reference = 'SHIPMENT_LINE_ID') THEN
      IF (p_mol_rec.reference_id IS NOT NULL) THEN
    l_where_str := l_where_str || ' AND rsl.shipment_line_id = :reference_id';
      END IF;

      IF (p_document_id IS NOT NULL) THEN
    l_where_str := l_where_str || ' AND rs.req_header_id = :document_id';
    IF (p_document_line_id IS NOT NULL) THEN
       l_where_str := l_where_str || ' AND rs.req_line_id = :document_line_id';
    END IF;
      END IF;
    ELSIF (p_document_type = 'RMA' OR p_mol_rec.reference = 'OE_ORDER_LINE_ID') THEN
      l_where_str := l_where_str||' AND rs.oe_order_header_id IS NOT NULL';

      IF (p_mol_rec.reference_id IS NOT NULL) THEN
    l_where_str := l_where_str||' AND rsl.oe_order_line_id = :reference_id';
      END IF;

      IF p_document_id IS NOT NULL THEN
    l_where_str := l_where_str||' AND rsl.oe_order_header_id = :document_id';
    IF p_document_line_id IS NOT NULL THEN
       l_where_str := l_where_str||' AND rsl.oe_order_line_id = :document_line_id';
    END IF;
      END IF;
   END IF;

   l_query_sql := l_select_str || l_from_str || l_where_str ;

    p_n :=1;
    WHILE p_n <=length(l_query_sql) LOOP
       p_v := Substr( l_query_sql,p_n,255);
       IF (l_debug = 1) THEN
     trace(p_v);
       END IF;
       p_n := p_n +255;
    END LOOP;

   l_cursor := dbms_sql.open_cursor;

   BEGIN
      dbms_sql.parse(l_cursor,l_query_sql,dbms_sql.v7);
   EXCEPTION
      WHEN OTHERS THEN
    l_last_error_pos := dbms_sql.last_error_position();
    l_temp_str := Substr(l_query_sql, l_last_error_pos-5, 50);
    IF l_debug = 1 THEN
       trace('Error in parse sql statement, at '||l_temp_str);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   IF l_debug =1 THEN
      trace('Binding variables');
   END IF;

   l_progress := '005';
   dbms_sql.bind_variable(l_cursor, ':org_id', p_mol_rec.organization_id);
   l_progress := '010';
   dbms_sql.bind_variable(l_cursor, ':inventory_item_id', p_mol_rec.inventory_item_id);
   l_progress := '011';
   dbms_sql.bind_variable(l_cursor, ':revision', p_mol_rec.revision);
   l_progress := '012';
   dbms_sql.bind_variable(l_cursor, ':project_id', p_mol_rec.project_id);
   l_progress := '013';
   dbms_sql.bind_variable(l_cursor, ':task_id', p_mol_rec.task_id);
   l_progress := '014';

   IF p_mol_rec.subinventory IS NOT NULL THEN
      dbms_sql.bind_variable(l_cursor, ':subinventory_code', p_mol_rec.subinventory);
   END IF;
   l_progress := '015';
   IF p_mol_rec.locator_id IS NOT NULL THEN
        dbms_sql.bind_variable(l_cursor, ':locator_id', p_mol_rec.locator_id);
   END IF;
   l_progress := '016';

   IF p_mol_rec.lpn_id IS NOT NULL THEN
      dbms_sql.bind_variable(l_cursor, ':lpn_id', p_mol_rec.lpn_id);
   END IF;

   l_progress := '017';
   IF p_document_id IS NOT NULL THEN
      dbms_sql.bind_variable(l_cursor, ':document_id', p_document_id);
   END IF;
   l_progress := '018';

   IF p_document_line_id IS NOT NULL THEN
      dbms_sql.bind_variable(l_cursor, ':document_line_id', p_document_line_id);
   END IF;
   l_progress := '019';

   IF p_mol_rec.reference_id IS NOT NULL THEN
      dbms_sql.bind_variable(l_cursor, ':reference_id',p_mol_rec.reference_id);
   END IF;
   l_progress := '020';


   dbms_sql.define_column(l_cursor, 1, l_receipt_num, 30);
   l_progress := '020.5';
   dbms_sql.define_column(l_cursor, 2, l_location_id);
   dbms_sql.define_column(l_cursor, 3, l_vendor_id);
   dbms_sql.define_column(l_cursor, 4, l_from_organization_id);
   dbms_sql.define_column(l_cursor, 5, l_rcv_transaction_id);

   l_progress := '021';

   IF (l_debug = 1) THEN
      trace('Excute query');
   END IF;
   l_return := dbms_sql.execute(l_cursor);
   IF (l_debug = 1) THEN
      trace('Executed query');
   END IF;
   l_progress := '022';

   l_location_exists := 0;
   l_location_unique := 1;
   l_receipt_exists  := 0;
   l_receipt_unique  := 1;
   l_partner_exists  := 0;
   l_partner_unique  := 1;

   LOOP
      IF DBMS_SQL.FETCH_ROWS(l_cursor) = 0 THEN
    EXIT;
      END IF;

      x_valid := 'Y';

      dbms_sql.column_value(l_cursor, 1, l_receipt_num);
      dbms_sql.column_value(l_cursor, 2, l_location_id);
      dbms_sql.column_value(l_cursor, 3, l_vendor_id);
      dbms_sql.column_value(l_cursor, 4, l_from_organization_id);
      dbms_sql.column_value(l_cursor, 5, l_rcv_transaction_id);

      IF (l_debug = 1) THEN
    trace('rcv_transaction_id:'||l_rcv_transaction_id||
          ' receipt_num:'||l_receipt_num||
          ' location_id:'||l_location_id||
          ' vendor_id:'||l_vendor_id||
          ' from_org_id:'||l_from_organization_id);
      END IF;

      -- Doc validations
      IF ((p_document_type IS NOT NULL AND p_mol_rec.reference IS NULL) OR
     (p_document_id IS NOT NULL AND p_mol_rec.reference_id IS NULL)) THEN
    x_unique := 'N';
      END IF;

      --RCV Location
      IF p_rcv_location_id IS NOT NULL THEN
         IF l_location_id = p_rcv_location_id THEN
            l_location_exists := 1;
         END IF;
      END IF;

      IF l_prev_location_id IS NOT NULL THEN
    IF l_prev_location_id <> l_location_id THEN
       l_location_unique := 0;
    END IF;
       ELSE
    l_location_unique := 1;
    l_prev_location_id := l_location_id;
      END IF;

      --Receipt
      IF p_receipt_num IS NOT NULL THEN
         IF l_receipt_num = p_receipt_num THEN
            l_receipt_exists := 1;
         END IF;
      END IF;

      IF l_prev_receipt IS NOT NULL THEN
    IF l_prev_receipt <>  l_receipt_num THEN
       l_receipt_unique := 0;
    END IF;
       ELSE
    l_receipt_unique := 1;
    l_prev_receipt := l_receipt_num;
      END IF;

      --Parnter
      IF p_partner_type IS NOT NULL THEN
         IF p_partner_type = 1 THEN
            IF p_partner_id = l_vendor_id THEN
               l_partner_exists := 1;
            END IF;
         ELSIF p_partner_type = 2 THEN
            IF p_partner_id = l_from_organization_id THEN
               l_partner_exists := 1;
            END IF;
         END IF;
      END IF;

      IF p_partner_type = 1 THEN
    IF l_prev_partner_id IS NOT NULL THEN
       IF l_prev_partner_id <>  Nvl(l_vendor_id,-1) THEN
          l_partner_unique := 0;
       END IF;
     ELSE
       l_partner_unique := 1;
       l_prev_partner_id := l_vendor_id;
    END IF;
       ELSIF p_partner_type = 2 THEN
    IF l_prev_partner_id IS NOT NULL THEN
       IF l_prev_partner_id <>  Nvl(l_from_organization_id,-1) THEN
          l_partner_unique := 0;
       END IF;
     ELSE
       l_partner_unique := 1;
       l_prev_partner_id := l_from_organization_id;
    END IF;
      END IF;



   END LOOP;

   dbms_sql.close_cursor(l_cursor);

   IF (l_debug = 1) THEN
      trace('l_location_exists:'||l_location_exists||
       ' l_location_unique:'||l_location_unique||
       ' l_receipt_exists:'||l_receipt_exists||
       ' l_receipt_unique:'||l_receipt_unique||
       ' l_partner_exists:'||l_partner_exists||
       ' l_partner_unique:'||l_partner_unique);
   END IF;

   --If user has entered location, receipt, partner as query
   --critieria, then if no results is found for these critieria
   --then this MOL must be skipped
   IF ((p_rcv_location_id IS NOT NULL AND l_location_exists <> 1) OR
       (p_receipt_num IS NOT NULL AND l_receipt_exists <> 1) OR
       (p_partner_type IS NOT NULL AND l_partner_exists <> 1)) THEN
      x_valid := 'N';
      RETURN;
   END IF;

   IF l_receipt_unique = 1 THEN
      --If this MOL corresponds to only 1 receipt, then stamped
      --the receipt in the GTMP record.
      x_receipt_num := l_prev_receipt;
   ELSE
      --If this MOL corresponds to more than 1 receipt, then
      --leave the receipt as null in the GTMP table.  Moreover
      --if the user has use receipt as a query critiria, prompt
      --a warning message that this MOL is mixed
      x_receipt_num := NULL;

      IF p_receipt_num IS NOT NULL THEN
    x_unique := 'N';
      END IF;
   END IF;

   IF l_location_unique = 1 THEN
      x_rcv_location_id := l_prev_location_id;
    ELSE
      x_rcv_location_id := NULL;

      IF p_rcv_location_id IS NOT NULL THEN
         x_unique := 'N';
      END IF;
   END IF;

   IF l_partner_unique = 1 THEN
      IF p_partner_type = 1 THEN
         x_vendor_id := l_prev_partner_id;
      ELSIF p_partner_type = 2 THEN
         x_from_org_id := l_prev_partner_id;
      END IF;
    ELSE

      x_vendor_id := NULL;
      x_from_org_id := NULL;

      IF p_partner_type IS NOT NULL THEN
         x_unique := 'N';
      END IF;
   END IF;

   IF (l_debug = 1) THEN
      trace('x_valid:'||x_valid||' x_unique:'||x_unique);
      trace('x_receipt_num:'||x_receipt_num||
       ' x_rcv_location_id:'||x_rcv_location_id||
       ' x_vendor_id:'||x_vendor_id||
       ' x_from_org_id:'||x_from_org_id
       );
   END IF;

EXCEPTION
   WHEN others THEN
      IF l_debug = 1 THEN
    trace('Error in query_inbound_material(), progress='||l_progress);
    trace('ERROR CODE = ' || SQLCODE);
    trace('ERROR MESSAGE = ' || SQLERRM);
      END IF;
      dbms_sql.close_cursor(l_cursor);

      x_valid := 'N';
END check_against_rcv;

/********************************************
 Procedure to query inbound eligible material
 *******************************************/
PROCEDURE query_inbound_material(
  x_return_status OUT NOCOPY VARCHAR2
, p_organization_id IN NUMBER
, p_organization_code IN VARCHAR2
, p_subinventory_code IN VARCHAR2 DEFAULT NULL
, p_locator_id IN NUMBER DEFAULT NULL
, p_locator IN VARCHAR2 DEFAULT NULL
, p_inventory_item_id IN NUMBER DEFAULT NULL
, p_item  IN VARCHAR2 DEFAULT NULL
, p_from_lpn_id IN NUMBER DEFAULT NULL
, p_project_id IN NUMBER DEFAULT NULL
, p_project IN VARCHAR2 DEFAULT NULL
, p_task_id IN NUMBER DEFAULT NULL
, p_task IN VARCHAR2 DEFAULT NULL
, p_document_type IN VARCHAR2 DEFAULT NULL
, p_document_id IN NUMBER DEFAULT NULL
, p_document_number IN VARCHAR2 DEFAULT NULL
, p_document_line_id IN NUMBER DEFAULT NULL
, p_document_line_num IN VARCHAR2 DEFAULT NULL--CLM Changes, Line number to be alphanumeric
, p_receipt_number IN VARCHAR2 DEFAULT NULL
, p_partner_id IN NUMBER DEFAULT NULL
, p_partner_type IN NUMBER DEFAULT NULL
, p_partner_name IN VARCHAR2 DEFAULT NULL
, p_rcv_location_id IN NUMBER DEFAULT NULL
, p_rcv_location IN VARCHAR2 DEFAULT NULL
, p_is_pjm_enabled_org IN VARCHAR2 DEFAULT 'N'
, x_source_unique OUT nocopy VARCHAR2 --R12

   ) IS


   CURSOR get_proj_task_rec IS
     select distinct inventory_item_id
     from wms_packing_material_gtemp
     where lpn_id is null --for loose item
       and project_id is not NULL; --taks id can be loose

       l_get_proj_task_rec get_proj_task_rec%ROWTYPE;

   -- Bug 3802897, after partial quantity is delivered,
   -- The move order line is still open and quantity remains the same
   -- The quantity_delivered will be populated with the delivered qty
   -- The actual available quantity is mol.quantity-mol.quantity_delivered

   -- Changed the select to mol.quantity-nvl(mol.quantity_delivered,0)
   -- And retrict line with such quantity > 0
    l_select_str VARCHAR2(2000) :=
        'SELECT mol.header_id mol_header_id, mol.line_id mol_line_id, mol.reference, mol.reference_id, mol.txn_source_id, '||
        'mol.organization_id organization_id, :org_code organization_code, nvl(lpn.subinventory_code,mol.from_subinventory_code) subinventory, '||
        'nvl(lpn.locator_id,mol.from_locator_id) locator_id, :locator locator, mol.project_id project_id, :project project, mol.task_id task_id, :task task, '||
        'mol.inventory_item_id inventory_item_id, :item item, mol.lpn_id lpn_id, mol.revision revision, mol.uom_code uom, mol.quantity-nvl(mol.quantity_delivered,0) quantity, mol.lot_number, '||
        'mol.secondary_quantity -NVL(mol.secondary_quantity_delivered,0) secondary_quantity, mol.secondary_uom_code, mol.grade_code';  --INCONV kkillams

    l_from_str VARCHAR2(2000) :=
        ' FROM mtl_txn_request_lines mol, mtl_txn_request_headers moh, wms_license_plate_numbers lpn ';

   -- Bug 3802897
   -- Make sure the available quantity is greater than 0
    l_where_str VARCHAR2(2000) :=
      'WHERE moh.header_id = mol.header_id AND moh.move_order_type = 6 '||
      'AND mol.line_status <> 5 AND (mol.quantity-nvl(mol.quantity_delivered,0))>0 '||
        'AND lpn.lpn_id(+) = mol.lpn_id AND lpn.organization_id(+) = mol.organization_id '||
        'AND (mol.lpn_id is null or (mol.lpn_id is not null and lpn.lpn_context = 3)) '||
        'AND nvl(mol.wms_process_flag,1) <> 2 AND mol.organization_id = :org_id AND mol.inventory_item_id = nvl(:inventory_item_id, mol.inventory_item_id) '||
        'AND nvl(mol.project_id, -9999) = nvl(:project_id, nvl(mol.project_id, -9999)) AND nvl(mol.task_id, -9999) = nvl(:task_id, nvl(mol.task_id, -9999)) '||
        'AND ((mol.lpn_id IS NULL) OR '||
        ' (mol.lpn_id IS NOT NULL AND (NOT exists (select 1 from wms_dispatched_tasks wdt where wdt.transfer_lpn_id = mol.lpn_id)) '||
        '  AND (NOT exists (select 1 from wms_dispatched_tasks wdt, mtl_material_transactions_temp mmtt where wdt.transaction_temp_id = mmtt.transaction_temp_id and mmtt.lpn_id = mol.lpn_id)))) ';

    l_sub_where_str VARCHAR2(100) :=
        ' AND (nvl(lpn.subinventory_code,mol.from_subinventory_code)=:subinventory) ';

    l_loc_where_str VARCHAR2(100) :=
        ' AND (nvl(lpn.locator_id,mol.from_locator_id)=:locator_id) ';

    l_fromlpn_where_str VARCHAR2(200) :=
        ' AND (lpn.lpn_id = :from_lpn_id OR (lpn.outermost_lpn_id = :from_lpn_id and lpn.lpn_id <> lpn.outermost_lpn_id) OR (lpn.parent_lpn_id = :from_lpn_id and lpn.lpn_id <> lpn.parent_lpn_id))';

    l_query_sql VARCHAR2(10000);

    p_n NUMBER;
    p_v VARCHAR2(256);

    l_rs_exists BOOLEAN := false;
    l_rsh_exists BOOLEAN := false;
    l_rsl_exists BOOLEAN := false;
    l_rt_exists BOOLEAN := false;

    l_cursor NUMBER;
    l_last_error_pos NUMBER;
    l_temp_str VARCHAR2(100);
    l_return NUMBER;

    l_mol_header_id NUMBER;
    l_mol_line_id  NUMBER;
    l_reference VARCHAR2(20);
    l_reference_id NUMBER;
    l_txn_source_id NUMBER;
    l_organization_id NUMBER;
    l_organization_code VARCHAR2(3);
    l_subinventory VARCHAR2(10);
    l_locator_id NUMBER;
    l_locator VARCHAR2(204);
    l_project_id NUMBER;
    l_project VARCHAR2(30);
    l_task_id NUMBER;
    l_task VARCHAR2(30);
    l_inventory_item_id NUMBER;
    l_item VARCHAR2(40);
    l_lpn_id NUMBER;
    l_revision VARCHAR2(3);
    l_uom VARCHAR2(3);
    l_qty NUMBER;
    --INVCONV kkillams
    l_sec_uom VARCHAR2(3);
    l_sec_qty NUMBER;
    l_grade   VARCHAR2(150);
    --END INVCONV kkillams
    l_lot VARCHAR2(30);
    l_rcv_location_id NUMBER;
    l_rcv_location VARCHAR2(60);
    l_vendor_id NUMBER;
    l_src_org_id NUMBER;
    l_partner_name VARCHAR2(240);
    l_doc_type VARCHAR2(10);
    l_doc_num_id NUMBER;
    l_document_number VARCHAR2(50);
    l_receipt_num VARCHAR2(30);
    l_doc_line_id NUMBER;
    l_doc_line_num VARCHAR2(10);--CLM Changes, Line number to be alphanumeric

    l_material_rec WMS_PACKING_MATERIAL_GTEMP%ROWTYPE;
    l_null_material WMS_PACKING_MATERIAL_GTEMP%ROWTYPE;
    l_rec_count NUMBER;
    l_exists NUMBER;

    l_shipment_header_id NUMBER;
    l_shipment_line_id NUMBER;
    l_req_line_id NUMBER;
    l_shipment_num VARCHAR2(30);
    l_asn_type VARCHAR2(25);
    l_receipt_source_code VARCHAR2(25);
    l_ship_to_org_id NUMBER;
    l_line_num NUMBER;

    l_progress VARCHAR2(20);
    l_item_cnt NUMBER;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(1000);
    l_proc_msg VARCHAR2(1000);

    l_valid VARCHAR2(1);
    l_unique VARCHAR2(1);
    l_receipt_used NUMBER;
    l_doc_line_used NUMBER;
    l_doc_num_used NUMBER;

BEGIN
    l_progress := '000';
    IF l_debug = 1 THEN
        trace('In WMS Packing Workbench, package header ='|| g_pkg_version);
        trace('Query Inbound eligible material with parameters :');
        trace('  p_organization_id='||p_organization_id||', p_subinventory_code='||p_subinventory_code||', p_locator_id='||p_locator_id||', p_locator='||p_locator);
        trace('  p_inventory_item_id='||p_inventory_item_id||', p_from_lpn_id='||p_from_lpn_id||', p_project_id='||p_project_id||', p_task_id='||p_task_id);
        trace('  p_document_type='||p_document_type);
        trace('  p_document_id='||p_document_id||', p_document_number='||p_document_number);
        trace('  p_document_line_id='||p_document_line_id||', p_document_line_num='||p_document_line_num);
        trace('  p_receipt_number='||p_receipt_number||', p_partner_id='||p_partner_id||', p_partner_type='||p_partner_type);
        trace('  p_rcv_location_id='||p_rcv_location_id||',p_rcv_location='||p_rcv_location);

        trace(' p_is_pjm_enabled_org ='|| p_is_pjm_enabled_org);
    END IF;

    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    /* Step 1, Build Dynamic SQL statement for the query */
    IF p_subinventory_code IS NOT NULL THEN
        l_where_str := l_where_str || l_sub_where_str;
    END IF;
    IF p_locator_id IS NOT NULL THEN
        l_where_str := l_where_str || l_loc_where_str;
    END IF;
    l_progress := '001';
    IF p_from_lpn_id IS NOT NULL THEN
        l_where_str := l_where_str || l_fromlpn_where_str;
    END IF;
    l_progress := '002';

    --R12

    l_select_str := l_select_str||', NULL rcv_location_id';
    l_select_str := l_select_str||', NULL rcv_location';
    l_select_str := l_select_str||', NULL vendor_id';
    l_select_str := l_select_str||', NULL src_org_id';
    l_select_str := l_select_str||', NULL parnter_name';
    l_select_str := l_select_str||', NULL doc_type';
    l_select_str := l_select_str||', NULL doc_num_id';
    l_select_str := l_select_str||', NULL document_number';
    l_select_str := l_select_str||', NULL receipt_num';
    l_select_str := l_select_str||', NULL doc_line_id';
    l_select_str := l_select_str||', NULL doc_line_num';

    l_receipt_used := 0;
    l_doc_line_used := 0;
    l_doc_num_used := 0;

    IF (p_subinventory_code IS NULL
   AND p_locator_id IS NULL
   AND p_inventory_item_id IS NULL
   AND p_from_lpn_id IS NULL
   AND p_project_id IS NULL
   AND p_task_id IS NULL) THEN
       IF (p_receipt_number IS NOT NULL) THEN
     l_receipt_used := 1;
     l_where_str := l_where_str||' AND mol.inventory_item_id';
     l_where_str := l_where_str||' IN (SELECT rsl.item_id';
     l_where_str := l_where_str||'     FROM rcv_shipment_lines rsl,rcv_shipment_headers rsh';
     l_where_str := l_where_str||'     WHERE rsh.receipt_num = :receipt_num';
     l_where_str := l_where_str||'     AND rsh.shipment_header_id = rsl.shipment_header_id)';
   ELSIF (p_document_type = 'PO') THEN
     IF (p_document_id IS NOT NULL AND p_document_line_id IS NOT NULL) THEN
        l_doc_line_used := 1;
        l_doc_num_used := 1;
        l_where_str := l_where_str||' AND mol.inventory_item_id';
        l_where_str := l_where_str||' IN (SELECT rs.item_id';
        l_where_str := l_where_str||'     FROM rcv_supply rs';
        l_where_str := l_where_str||'     WHERE rs.po_line_id = :doc_line_id';
        l_where_str := l_where_str||'     AND   rs.po_header_id = :doc_num_id';
        l_where_str := l_where_str||'     AND rs.to_organization_id = :org_id)';
      ELSIF p_document_id IS NOT NULL THEN
        l_doc_num_used := 1;
        l_where_str := l_where_str||' AND mol.inventory_item_id';
        l_where_str := l_where_str||' IN (SELECT rs.item_id';
        l_where_str := l_where_str||'     FROM rcv_supply rs';
        l_where_str := l_where_str||'     WHERE rs.po_header_id = :doc_num_id';
        l_where_str := l_where_str||'     AND rs.to_organization_id = :org_id)';
      ELSE
        l_where_str := l_where_str||' AND mol.inventory_item_id';
        l_where_str := l_where_str||' IN (SELECT rs.item_id';
        l_where_str := l_where_str||'     FROM rcv_supply rs';
        l_where_str := l_where_str||'     WHERE rs.to_organization_id = :org_id';
        l_where_str := l_where_str||'     AND rs.po_line_id IS NOT NULL)';
     END IF;
   ELSIF (p_document_type = 'REQ') THEN
     IF (p_document_id IS NOT NULL AND p_document_line_id IS NOT NULL) THEN
        l_doc_line_used := 1;
        l_doc_num_used := 1;
        l_where_str := l_where_str||' AND mol.inventory_item_id';
        l_where_str := l_where_str||' IN (SELECT rs.item_id';
        l_where_str := l_where_str||'     FROM rcv_supply rs';
        l_where_str := l_where_str||'     WHERE rs.req_line_id = :doc_line_id';
        l_where_str := l_where_str||'     AND rs.req_header_id = :doc_num_id';
        l_where_str := l_where_str||'     AND rs.to_organization_id = :org_id)';
      ELSIF p_document_id IS NOT NULL THEN
        l_doc_num_used := 1;
        l_where_str := l_where_str||' AND mol.inventory_item_id';
        l_where_str := l_where_str||' IN (SELECT rs.item_id';
        l_where_str := l_where_str||'     FROM rcv_supply rs';
        l_where_str := l_where_str||'     WHERE rs.req_header_id = :doc_num_id';
        l_where_str := l_where_str||'     AND rs.to_organization_id = :org_id)';
      ELSE
        l_where_str := l_where_str||' AND mol.inventory_item_id';
        l_where_str := l_where_str||' IN (SELECT rs.item_id';
        l_where_str := l_where_str||'     FROM rcv_supply rs';
        l_where_str := l_where_str||'     WHERE rs.req_line_id IS NOT NULL';
        l_where_str := l_where_str||'     AND rs.to_organization_id = :org_id)';
     END IF;
   ELSIF (p_document_type IN ('ASN','INTSHIP')) THEN
     IF (p_document_id IS NOT NULL AND p_document_line_id IS NOT NULL) THEN
        l_doc_line_used := 1;
        l_doc_num_used := 1;
        l_where_str := l_where_str||' AND mol.inventory_item_id';
        l_where_str := l_where_str||' IN (SELECT rs.item_id';
        l_where_str := l_where_str||'     FROM rcv_supply rs';
        l_where_str := l_where_str||'     WHERE rs.shipment_line_id = :doc_line_id';
        l_where_str := l_where_str||'     WHERE rs.shipment_header_id = :doc_num_id';
        l_where_str := l_where_str||'     AND rs.to_organization_id = :org_id)';
      ELSIF p_document_id IS NOT NULL THEN
        l_doc_num_used := 1;
        l_where_str := l_where_str||' AND mol.inventory_item_id';
        l_where_str := l_where_str||' IN (SELECT rs.item_id';
        l_where_str := l_where_str||'     FROM rcv_supply rs';
        l_where_str := l_where_str||'     WHERE rs.shipment_header_id = :doc_num_id';
        l_where_str := l_where_str||'     AND rs.to_organization_id = :org_id)';
      ELSE
        IF (p_document_type = 'ASN') THEN
      l_where_str := l_where_str||' AND mol.inventory_item_id';
      l_where_str := l_where_str||' IN (SELECT rs.item_id';
      l_where_str := l_where_str||'     FROM rcv_supply rs,rcv_shipment_headers rsh';
      l_where_str := l_where_str||'     WHERE rsh.asn_type IN (''ASN'',''ASBN'')';
      l_where_str := l_where_str||'     AND rsh.shipment_num is not null';
      l_where_str := l_where_str||'     AND rs.shipment_header_id = rsh.shipment_header_id';
      l_where_str := l_where_str||'     AND rs.to_organization_id = :org_id)';
         ELSE
      l_where_str := l_where_str||' AND mol.inventory_item_id';
      l_where_str := l_where_str||' IN (SELECT rs.item_id';
      l_where_str := l_where_str||'     FROM rcv_supply rs,rcv_shipment_headers rsh';
      l_where_str := l_where_str||'     WHERE rsh.asn_type NOT IN (''ASN'',''ASBN'')';
      l_where_str := l_where_str||'     AND rsh.shipment_num is not null';
      l_where_str := l_where_str||'     AND rs.to_organization_id = :org_id';
      l_where_str := l_where_str||'     AND rs.shipment_header_id = rsh.shipment_header_id';
      l_where_str := l_where_str||'     AND rsh.receipt_source_code IN (''INTERNAL ORDER'',''INVENTORY''))';
        END IF;
     END IF;
   ELSIF (p_document_type = 'RMA') THEN
     IF (p_document_id IS NOT NULL AND p_document_line_id IS NOT NULL) THEN
        l_doc_line_used := 1;
        l_doc_num_used := 1;
        l_where_str := l_where_str||' AND mol.inventory_item_id';
        l_where_str := l_where_str||' IN (SELECT rs.item_id';
        l_where_str := l_where_str||'     FROM rcv_supply rs';
        l_where_str := l_where_str||'     WHERE rs.oe_order_line_id = :doc_line_id';
        l_where_str := l_where_str||'     AND rs.oe_order_header_id = :doc_num_id';
        l_where_str := l_where_str||'     AND rs.to_organization_id = :org_id)';
      ELSIF p_document_line_id IS NOT NULL THEN
        l_doc_num_used := 1;
        l_where_str := l_where_str||' AND mol.inventory_item_id';
        l_where_str := l_where_str||' IN (SELECT rs.item_id';
        l_where_str := l_where_str||'     FROM rcv_supply rs';
        l_where_str := l_where_str||'     WHERE rs.oe_order_header_id = :doc_num_id';
        l_where_str := l_where_str||'     AND rs.to_organization_id = :org_id)';
      ELSE
        l_where_str := l_where_str||' AND mol.inventory_item_id';
        l_where_str := l_where_str||' IN (SELECT rs.item_id';
        l_where_str := l_where_str||'     FROM rcv_supply rs';
        l_where_str := l_where_str||'     WHERE rs.oe_order_line_id IS NOT NULL';
        l_where_str := l_where_str||'     AND rs.to_organization_id = :org_id)';
     END IF;
       END IF;
    END IF;

    l_progress := '020';
    l_query_sql := l_select_str || l_from_str || l_where_str ;

    p_n :=1;
    WHILE p_n <=length(l_query_sql) LOOP
       p_v := Substr( l_query_sql,p_n,255);
       trace(p_v);
       p_n := p_n +255;
    END LOOP;


    /* Step 2, Build Cusor, Bind variables */
    IF l_debug =1 THEN
        trace('Finished building SQL, start build cursor');
    END IF;
    l_cursor := dbms_sql.open_cursor;
     l_progress := '030';
    BEGIN
        dbms_sql.parse(l_cursor,l_query_sql,dbms_sql.v7);
    EXCEPTION
        WHEN OTHERS THEN
            l_last_error_pos := dbms_sql.last_error_position();
            l_temp_str := Substr(l_query_sql, l_last_error_pos-5, 50);
            IF l_debug = 1 THEN
                trace('Error in parse sql statement, at '||l_temp_str);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    l_progress := '040';
    IF l_debug =1 THEN
        trace('Binding variables');
    END IF;
    -- Bind variables
    dbms_sql.bind_variable(l_cursor, ':org_id', p_organization_id);
    dbms_sql.bind_variable(l_cursor, ':org_code', p_organization_code);
    dbms_sql.bind_variable(l_cursor, ':inventory_item_id', p_inventory_item_id);
    dbms_sql.bind_variable(l_cursor, ':item', p_item);
    dbms_sql.bind_variable(l_cursor, ':project_id', p_project_id);
    dbms_sql.bind_variable(l_cursor, ':project', p_project);
    dbms_sql.bind_variable(l_cursor, ':task_id', p_task_id);
    dbms_sql.bind_variable(l_cursor, ':task', p_task);
    l_progress := '050';
    IF p_subinventory_code IS NOT NULL THEN
        dbms_sql.bind_variable(l_cursor, ':subinventory', p_subinventory_code);
    END IF;
    IF p_locator_id IS NOT NULL THEN
        dbms_sql.bind_variable(l_cursor, ':locator_id', p_locator_id);
    END IF;
    dbms_sql.bind_variable(l_cursor, ':locator', p_locator);
    IF p_from_lpn_id IS NOT NULL THEN
        dbms_sql.bind_variable(l_cursor, ':from_lpn_id', p_from_lpn_id);
    END IF;

    IF p_document_id IS NOT NULL AND l_doc_num_used = 1 THEN
        dbms_sql.bind_variable(l_cursor, ':doc_num_id', p_document_id);
    END IF;

    IF p_document_line_id IS NOT NULL AND l_doc_line_used = 1 THEN
        dbms_sql.bind_variable(l_cursor, ':doc_line_id', p_document_line_id);
    END IF;

    IF (p_receipt_number IS NOT NULL AND l_receipt_used = 1) THEN
       dbms_sql.bind_variable(l_cursor, ':receipt_num', p_receipt_number);
    END IF;

    l_progress := '060';

    /* Step 3. Execute the query */
    IF l_debug = 1 THEN
        trace('Execute the query');
    END IF;
    --Define output parameters
    dbms_sql.define_column(l_cursor, 1, l_mol_header_id);
    dbms_sql.define_column(l_cursor, 2, l_mol_line_id);
    dbms_sql.define_column(l_cursor, 3, l_reference,240);
    dbms_sql.define_column(l_cursor, 4, l_reference_id);
    dbms_sql.define_column(l_cursor, 5, l_txn_source_id);
    dbms_sql.define_column(l_cursor, 6, l_organization_id);
    dbms_sql.define_column(l_cursor, 7, l_organization_code,3);
    dbms_sql.define_column(l_cursor, 8, l_subinventory,10);
    dbms_sql.define_column(l_cursor, 9, l_locator_id);
    dbms_sql.define_column(l_cursor, 10,l_locator,204);
    dbms_sql.define_column(l_cursor, 11, l_project_id);
    dbms_sql.define_column(l_cursor, 12, l_project,30);
    dbms_sql.define_column(l_cursor, 13, l_task_id);
    dbms_sql.define_column(l_cursor, 14, l_task,30);
    dbms_sql.define_column(l_cursor, 15, l_inventory_item_id);
    dbms_sql.define_column(l_cursor, 16, l_item,40);
    dbms_sql.define_column(l_cursor, 17, l_lpn_id);
    dbms_sql.define_column(l_cursor, 18, l_revision,3);
    dbms_sql.define_column(l_cursor, 19, l_uom,3);
    dbms_sql.define_column(l_cursor, 20, l_qty);
    dbms_sql.define_column(l_cursor, 21, l_lot, 30);
    --INVCONV kkillams
    dbms_sql.define_column(l_cursor, 22, l_sec_qty);
    dbms_sql.define_column(l_cursor, 23, l_sec_uom,3);
    dbms_sql.define_column(l_cursor, 24, l_grade,150);
    --END INVCONV kkillams
    dbms_sql.define_column(l_cursor, 25, l_rcv_location_id);
    dbms_sql.define_column(l_cursor, 26, l_rcv_location,60);
    dbms_sql.define_column(l_cursor, 27, l_vendor_id);
    dbms_sql.define_column(l_cursor, 28, l_src_org_id);
    dbms_sql.define_column(l_cursor, 29, l_partner_name,240);
    dbms_sql.define_column(l_cursor, 30, l_doc_type,20);
    dbms_sql.define_column(l_cursor, 31, l_doc_num_id);
    dbms_sql.define_column(l_cursor, 32, l_document_number,50);
    dbms_sql.define_column(l_cursor, 33, l_receipt_num,30);
    dbms_sql.define_column(l_cursor, 34, l_doc_line_id);
    dbms_sql.define_column(l_cursor, 35, l_doc_line_num,10);--CLM Changes, Line number to be alphanumeric


    l_progress := '070';
    l_return := dbms_sql.execute(l_cursor);
    l_progress := '080';
    IF l_debug = 1 THEN
        trace('Executed query');
    END IF;

    delete from wms_packing_material_gtemp;
    --delete from wms_packing_material_temp;

    l_rec_count := 0;
    LOOP
        -- Fetch the rows into the buffer, and also check for the exit
        -- condition from the loop.
        IF DBMS_SQL.FETCH_ROWS(l_cursor) = 0 THEN
            EXIT;
        END IF;
        l_material_rec := l_null_material;
        -- Retrieve the rows from the buffer into temp variables.
        dbms_sql.column_value(l_cursor, 1, l_material_rec.move_order_header_id);
        dbms_sql.column_value(l_cursor, 2, l_material_rec.move_order_line_id);
        dbms_sql.column_value(l_cursor, 3, l_material_rec.reference);
        dbms_sql.column_value(l_cursor, 4, l_material_rec.reference_id);
        dbms_sql.column_value(l_cursor, 5, l_material_rec.txn_source_id);
        dbms_sql.column_value(l_cursor, 6, l_material_rec.organization_id);
        dbms_sql.column_value(l_cursor, 7, l_material_rec.organization_code);
        dbms_sql.column_value(l_cursor, 8, l_material_rec.subinventory);
        dbms_sql.column_value(l_cursor, 9, l_material_rec.locator_id);
        dbms_sql.column_value(l_cursor, 10,l_material_rec.locator);
        dbms_sql.column_value(l_cursor, 11, l_material_rec.project_id);
        dbms_sql.column_value(l_cursor, 12, l_material_rec.project);
        dbms_sql.column_value(l_cursor, 13, l_material_rec.task_id);
        dbms_sql.column_value(l_cursor, 14, l_material_rec.task_number);
        dbms_sql.column_value(l_cursor, 15, l_material_rec.inventory_item_id);
        dbms_sql.column_value(l_cursor, 16, l_material_rec.item);
        dbms_sql.column_value(l_cursor, 17, l_material_rec.lpn_id);
        dbms_sql.column_value(l_cursor, 18, l_material_rec.revision);
        dbms_sql.column_value(l_cursor, 19, l_material_rec.uom);
        dbms_sql.column_value(l_cursor, 20, l_material_rec.quantity);
        dbms_sql.column_value(l_cursor, 21, l_material_rec.lot_number);
        --INVCONV kkillams
        dbms_sql.column_value(l_cursor, 22, l_material_rec.secondary_quantity);
        dbms_sql.column_value(l_cursor, 23, l_material_rec.secondary_uom_code);
        dbms_sql.column_value(l_cursor, 24, l_material_rec.grade_code);
        --END INVCONV kkillams
        dbms_sql.column_value(l_cursor, 25, l_material_rec.receiving_location_id);
        dbms_sql.column_value(l_cursor, 26, l_material_rec.receiving_location);
        dbms_sql.column_value(l_cursor, 27, l_material_rec.vendor_id);
        dbms_sql.column_value(l_cursor, 28, l_material_rec.source_org_id);
        dbms_sql.column_value(l_cursor, 29, l_material_rec.trading_partner);
        dbms_sql.column_value(l_cursor, 30, l_material_rec.document_type);
        dbms_sql.column_value(l_cursor, 31, l_material_rec.document_id);
        dbms_sql.column_value(l_cursor, 32, l_material_rec.document_number);
        dbms_sql.column_value(l_cursor, 33, l_material_rec.receipt_num);
        dbms_sql.column_value(l_cursor, 34, l_material_rec.document_line_id);
        dbms_sql.column_value(l_cursor, 35, l_material_rec.document_line_num);

        l_rec_count := l_rec_count + 1;

   trace('Calling check_against_rcv');
   trace(' l_material_rec.line_id           => '|| l_material_rec.move_order_line_id);
   trace(' l_material_rec.inventory_item_id => '|| l_material_rec.inventory_item_id);
   trace(' l_material_rec.revision          => '|| l_material_rec.revision);
   trace(' l_material_rec.lot_number        => '|| l_material_rec.lot_number);

   check_against_rcv
     (p_mol_rec            => l_material_rec
      , p_document_type    => p_document_type
      , p_document_id      => p_document_id
      , p_document_line_id => p_document_line_id
      , p_receipt_num      => p_receipt_number
      , p_partner_id       => p_partner_id
      , p_partner_type     => p_partner_type
      , p_rcv_location_id  => p_rcv_location_id
      , x_valid            => l_valid
      , x_unique           => l_unique
      , x_receipt_num      => l_material_rec.receipt_num
      , x_rcv_location_id  => l_material_rec.receiving_location_id
      , x_vendor_id        => l_material_rec.vendor_id
      , x_from_org_id      => l_material_rec.source_org_id
      );

   IF (l_valid = 'N') THEN
      GOTO nextmolrec;
   END IF;

   IF (x_source_unique IS NULL OR x_source_unique = 'Y') THEN
      x_source_unique := l_unique;
   END IF;

   trace(' receipt_num:'||l_material_rec.receipt_num||
         ' receiving_location_id:'||l_material_rec.receiving_location_id||
         ' vendor_id:'||l_material_rec.vendor_id||
         ' source_org_id:'||l_material_rec.source_org_id);


        -- Derive column values
        l_progress := '090-'||l_rec_count;

        -- LPN, Parent LPN, Outermost LPN
        IF l_material_rec.lpn_id IS NOT NULL THEN
            BEGIN
                SELECT lpn.license_plate_number, lpn.parent_lpn_id, pLpn.license_plate_number,
                       lpn.outermost_lpn_id, oLpn.license_plate_number
                INTO l_material_rec.lpn,
                     l_material_rec.parent_lpn_id,
                     l_material_rec.parent_lpn,
                     l_material_rec.outermost_lpn_id, l_material_rec.outermost_lpn
                FROM wms_license_plate_numbers lpn, wms_license_plate_numbers pLpn, wms_license_plate_numbers oLpn
                WHERE lpn.lpn_id = l_material_rec.lpn_id
                AND pLpn.lpn_id(+) = lpn.parent_lpn_id
                AND oLpn.lpn_id(+) = lpn.outermost_lpn_id;
            EXCEPTION
                WHEN no_data_found THEN
                    IF l_debug = 1 THEN
                        trace(' can not find lpn for lpn_id '|| l_material_rec.lpn_id);
                    END IF;
                    l_material_rec.lpn := null;
                    l_material_rec.parent_lpn_id := null;
                    l_material_rec.parent_lpn := null;
                    l_material_rec.outermost_lpn_id := null;
                    l_material_rec.outermost_lpn := null;
            END;
        END IF;
        l_progress := '091-'||l_rec_count;
        -- Locator
        IF l_material_rec.locator IS NULL AND
          (l_material_rec.locator_id IS NOT NULL AND l_material_rec.locator_id NOT IN (-1,0)) THEN
            BEGIN
                SELECT
                  inv_project.get_locsegs(l_material_rec.locator_id,l_material_rec.organization_id) /*bug344642  concatenated_segments*/  INTO l_material_rec.locator
                FROM mtl_item_locations_kfv
                WHERE organization_id = l_material_rec.organization_id
                AND subinventory_code = l_material_rec.subinventory
                AND inventory_location_id = l_material_rec.locator_id;
            EXCEPTION
                WHEN no_data_found THEN
                    IF l_debug = 1 THEN
                        trace(' can not find locator name for loc_id '|| l_material_rec.locator_id||',mol _id ='||l_material_rec.move_order_line_id);
                    END IF;
                    l_material_rec.locator := null;
            END;
        END IF;
        l_progress := '092-'||l_rec_count;
        -- Project
        IF l_material_rec.project IS NULL AND l_material_rec.project_id IS NOT NULL THEN
            BEGIN
                SELECT name INTO l_material_rec.project
                FROM pa_projects WHERE project_id = l_material_rec.project_id;
            EXCEPTION
                WHEN no_data_found THEN
                    IF l_debug = 1 THEN
                        trace(' can not find project name for project_id '|| l_material_rec.project_id);
                    END IF;
                    l_material_rec.project := null;
            END;
        END IF;
        l_progress := '093-'||l_rec_count;
        -- Task
        IF l_material_rec.task_id IS NOT NULL THEN
            BEGIN
                SELECT task_number,task_name INTO l_material_rec.task_number, l_material_rec.task_name
                FROM pa_tasks
                WHERE project_id = l_material_rec.project_id
                AND task_id = l_material_rec.task_id;
            EXCEPTION
                WHEN no_data_found THEN
                    IF l_debug = 1 THEN
                        trace(' can not find task name for task_id '|| l_material_rec.task_id);
                    END IF;
                    l_material_rec.task_number := null;
                    l_material_rec.task_name := null;
            END;
        END IF;
        l_progress := '094-'||l_rec_count;
        -- Item
        IF l_material_rec.inventory_item_id IS NOT NULL THEN
            BEGIN
                SELECT concatenated_segments,description INTO l_material_rec.item, l_material_rec.item_description
                FROM mtl_system_items_kfv
                WHERE organization_id = l_material_rec.organization_id
                AND inventory_item_id = l_material_rec.inventory_item_id;
            EXCEPTION
                WHEN no_data_found THEN
                    IF l_debug = 1 THEN
                        trace(' can not find item for item_id '|| l_material_rec.inventory_item_id);
                    END IF;
                    l_material_rec.item := null;
                    l_material_rec.item_description := null;
            END;
        END IF;

        l_progress := '095-'||l_rec_count;
        -- Receiving Location
        IF l_material_rec.receiving_location_id IS NOT NULL THEN
            BEGIN
                SELECT hrl.location_code
                INTO l_material_rec.receiving_location
                FROM hr_locations_all hrl
                WHERE hrl.location_id = l_material_rec.receiving_location_id;
            EXCEPTION
                WHEN no_data_found THEN
                    IF l_debug = 1 THEN
                        trace('Unable to retrieve location_code from location_id');
                    END IF;
                    l_material_rec.receiving_location_id := null;
                    l_material_rec.receiving_location := null;
            END;
        END IF;

        l_progress := '096-'||l_rec_count;
        -- Decide document type
   IF l_material_rec.reference = 'ORDER_LINE_ID' THEN
      l_material_rec.document_type := 'RMA';
    ELSIF l_material_rec.reference = 'PO_LINE_LOCATION_ID' THEN
      l_material_rec.document_type := 'PO';
    ELSIF l_material_rec.reference = 'SHIPMENT_LINE_ID' THEN
      IF l_material_rec.reference_id IS NOT NULL THEN
              BEGIN
       SELECT rsh.shipment_header_id, rsl.shipment_line_id, rsl.requisition_line_id, rsh.shipment_num, rsh.asn_type, rsh.receipt_source_code, rsh.ship_to_org_id, rsl.line_num, rsh.receipt_num, rsh.vendor_id, rsl.from_organization_id
         INTO l_shipment_header_id, l_shipment_line_id, l_req_line_id, l_shipment_num, l_asn_type, l_receipt_source_code, l_ship_to_org_id, l_line_num, l_receipt_num, l_vendor_id, l_src_org_id
         FROM rcv_shipment_lines rsl, rcv_shipment_headers rsh
         WHERE rsh.shipment_header_id = rsl.shipment_header_id
         AND rsl.shipment_line_id = l_material_rec.reference_id;
         EXCEPTION
       WHEN no_data_found THEN
          IF l_debug = 1 THEN
             trace('No data found in getting shipment line of '||l_material_rec.reference_id);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;

         IF l_req_line_id IS NOT NULL THEN
       l_material_rec.document_type := 'REQ';
          ELSE
       IF l_shipment_num IS NOT NULL AND l_asn_type IN ('ASN','ASBN') THEN
          l_material_rec.document_type := 'ASN';
        ELSIF l_shipment_num IS NOT NULL THEN
          IF (l_receipt_source_code IN ('INTERNAL ORDER','INVENTORY')) AND
            (l_ship_to_org_id = l_material_rec.organization_id) THEN
             l_material_rec.document_type := 'INTSHIP';
           ELSE
             IF l_debug = 1 THEN
           trace('Can not decide document type');
             END IF;
             --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        ELSE
          IF l_debug = 1 THEN
             trace('Can not decide document type');
          END IF;
          --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
         END IF;
       ELSE
         l_material_rec.document_type := 'MIXED';
      END IF;--END IF l_material_rec.reference_id IS NOT NULL THEN
    ELSE
       l_material_rec.document_type := 'MIXED';
   END IF;

        l_progress := '097-'||l_rec_count;
        --trace('Document type is '||l_material_rec.document_type);
        -- obtain document information
        IF l_material_rec.document_type IN ('ASN', 'INTSHIP') THEN
            -- Document Number
            IF l_material_rec.document_number IS NOT NULL THEN
                IF (l_shipment_num IS NOT NULL) AND (l_shipment_num <> l_material_rec.document_number) THEN
                    IF l_debug = 1 THEN
                        trace('l_shipment_num '||l_shipment_num ||' not equal to l_material_rec.document_number '||l_material_rec.document_number);
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            ELSE
                -- Need to derive document number
                IF l_shipment_num IS NOT NULL THEN
                    l_material_rec.document_id := l_shipment_header_id;
                    l_material_rec.document_number := l_shipment_num;
       ELSE
         IF (l_material_rec.reference_id IS NOT NULL) THEN
                      BEGIN
          SELECT rsh.shipment_header_id, rsh.shipment_num, rsh.receipt_num,rsh.vendor_id
            ,rsl.shipment_line_id, rsl.line_num,rsl.from_organization_id
            INTO l_material_rec.document_id, l_material_rec.document_number, l_receipt_num, l_vendor_id,l_shipment_line_id, l_line_num, l_src_org_id
            FROM rcv_shipment_lines rsl, rcv_shipment_headers rsh
            WHERE rsh.shipment_header_id = rsl.shipment_header_id
            AND rsl.shipment_line_id = l_material_rec.reference_id;
            EXCEPTION
          WHEN no_data_found THEN
                            IF l_debug = 1 THEN
                trace('Can not derive document number for type ASN/INTSHIP and reference_id = '||l_material_rec.reference_id);
                            END IF;
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;
         END IF;
                END IF;
            END IF;

            -- Document Line
            IF l_material_rec.document_line_num IS NOT NULL THEN
                IF (l_line_num IS NOT NULL) AND (l_line_num <> l_material_rec.document_line_num) THEN
                    IF l_debug = 1 THEN
                        trace('l_line_num '||l_line_num ||' not equal to l_material_rec.document_line_num '||l_material_rec.document_line_num);
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            ELSE
                -- Need to derive document number
                IF l_line_num IS NOT NULL THEN
                    l_material_rec.document_line_id := l_shipment_line_id;
                    l_material_rec.document_line_num := l_line_num;
       ELSE
         IF (l_material_rec.reference_id IS NOT NULL) THEN
                      BEGIN
          SELECT rsl.shipment_line_id, rsl.line_num, rsl.from_organization_id
            INTO l_material_rec.document_line_id, l_material_rec.document_line_num, l_src_org_id
            FROM rcv_shipment_lines rsl
            WHERE rsl.shipment_line_id = l_material_rec.reference_id;
            EXCEPTION
          WHEN no_data_found THEN
                            IF l_debug = 1 THEN
                trace('Can not derive document line for type ASN/INTSHIP and reference_id = '||l_material_rec.reference_id);
                            END IF;
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;
         END IF;
                END IF;
            END IF;

            -- Trading Partner: Vendor or Source Org
            IF l_material_rec.trading_partner IS NULL THEN
                IF l_material_rec.document_type = 'ASN' THEN
                    -- ASN, get vendor
                    IF l_material_rec.vendor_id IS NULL THEN
                        IF l_vendor_id IS NOT NULL THEN
                            l_material_rec.vendor_id := l_vendor_id;
          ELSE
             IF (l_material_rec.reference_id IS NOT NULL) THEN
                               BEGIN
              SELECT rsh.vendor_id INTO l_material_rec.vendor_id
                FROM rcv_shipment_lines rsl, rcv_shipment_headers rsh
                WHERE rsh.shipment_header_id = rsl.shipment_header_id
                AND rsl.shipment_line_id = l_material_rec.reference_id;
                EXCEPTION
              WHEN no_data_found THEN
                 IF l_debug = 1 THEN
                                        trace('Can not derive vendor for type ASN and reference_id = '||l_material_rec.reference_id);
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END;
             END IF;
                        END IF;
                    END IF;

                    IF l_material_rec.vendor_id IS NOT NULL THEN
                        BEGIN
                            SELECT vendor_name INTO l_material_rec.trading_partner
                            FROM po_vendors
                            WHERE vendor_id = l_material_rec.vendor_id;
                        EXCEPTION
                            WHEN no_data_found THEN
                                IF l_debug = 1 THEN
                                    trace('Can not derive vendor name for type ASN and vendor_id = '||l_material_rec.vendor_id);
                                END IF;
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END;
                    END IF;
                ELSE
                    -- INTSHIP, get source_org
                    IF l_material_rec.source_org_id IS NULL THEN
                        IF l_src_org_id IS NOT NULL THEN
                            l_material_rec.source_org_id := l_src_org_id;
          ELSE
             IF (l_material_rec.reference_id IS NOT NULL) THEN
                               BEGIN
              SELECT rsl.from_organization_id INTO l_material_rec.source_org_id
                FROM rcv_shipment_lines rsl
                WHERE rsl.shipment_line_id = l_material_rec.reference_id;
                EXCEPTION
              WHEN no_data_found THEN
                 IF l_debug = 1 THEN
                                        trace('Can not derive src_org_id for type INTSHIP and reference_id = '||l_material_rec.reference_id);
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END;
             END IF;
                        END IF;
                    END IF;

                    IF l_material_rec.source_org_id IS NOT NULL THEN
                        BEGIN
                            SELECT organization_code ||'-'||organization_name
                            INTO l_material_rec.trading_partner
                            FROM org_organization_definitions
                            WHERE organization_id = l_material_rec.source_org_id;
                        EXCEPTION
                            WHEN no_data_found THEN
                                IF l_debug = 1 THEN
                                    trace('Can not derive src_org name for type INSTHIP and org_id = '||l_material_rec.source_org_id);
                                END IF;
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END;
                    END IF;
                END IF;
            END IF;

        ELSIF l_material_rec.document_type = 'PO' THEN
            -- Document Number
            --IF l_debug = 1 THEN
            --  trace('1 reference_id ='|| l_material_rec.reference_id);
            --END IF;
       IF l_material_rec.document_number IS NULL THEN
          IF (l_material_rec.reference_id IS NOT NULL) THEN
                  BEGIN
           SELECT poh.po_header_id, poh.segment1, pol.po_line_id, pol.line_num
             INTO l_material_rec.document_id, l_material_rec.document_number
                       , l_material_rec.document_line_id, l_material_rec.document_line_num
             FROM po_headers_trx_v poh, po_lines_trx_v pol, po_line_locations_trx_v poll--CLM Changes, using CLM views instead of base tables
             WHERE poll.line_location_id = l_material_rec.reference_id
             AND   poh.po_header_id = poll.po_header_id
             AND   pol.po_line_id = poll.po_line_id;
        EXCEPTION
           WHEN no_data_found THEN
                        IF l_debug = 1 THEN
            trace('Can not derive document number for type PO and reference_id = '||l_material_rec.reference_id);
                        END IF;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
          END IF;
            END IF;

            -- Document Line
            IF l_material_rec.document_line_num IS NULL THEN
          IF (l_material_rec.reference_id IS NOT NULL) THEN
                  BEGIN
           SELECT pol.po_line_id, pol.line_num
             INTO l_material_rec.document_line_id, l_material_rec.document_line_num
             FROM po_lines_all pol, po_line_locations_all poll
             WHERE poll.line_location_id = l_material_rec.reference_id
             AND   pol.po_line_id = poll.po_line_id;
        EXCEPTION
           WHEN no_data_found THEN
                        IF l_debug = 1 THEN
            trace('Can not derive document line for type PO and reference_id = '||l_material_rec.reference_id);
                        END IF;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
          END IF;
            END IF;

            -- Receipt Number/Vendor
       IF l_material_rec.vendor_id IS NOT NULL THEN
               BEGIN
        SELECT vendor_name INTO l_material_rec.trading_partner
          FROM po_vendors
          WHERE vendor_id = l_material_rec.vendor_id;
          EXCEPTION
        WHEN no_data_found THEN
           IF l_debug = 1 THEN
         trace('Can not derive vendor name for type PO and vendor_id = '||l_material_rec.vendor_id);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END;
       END IF;

        ELSIF l_material_rec.document_type = 'REQ' THEN
            -- Document Number
       IF l_material_rec.document_number IS NULL THEN
          IF (l_material_rec.reference_id IS NOT NULL) THEN
                  BEGIN
           SELECT prh.requisition_header_id, prh.segment1, prl.requisition_line_id, prl.line_num
             INTO l_material_rec.document_id, l_material_rec.document_number
                       , l_material_rec.document_line_id, l_material_rec.document_line_num
             FROM po_requisition_headers_all prh, po_requisition_lines_all prl, rcv_shipment_lines rsl
             WHERE rsl.shipment_line_id = l_material_rec.reference_id
             AND   prh.requisition_header_id = prl.requisition_header_id
             AND   prl.requisition_line_id = rsl.requisition_line_id;
        EXCEPTION
           WHEN no_data_found THEN
                        IF l_debug = 1 THEN
            trace('Can not derive document number for type REQ and reference_id = '||l_material_rec.reference_id);
                        END IF;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
          END IF;
            END IF;

            -- Document Line
            IF l_material_rec.document_line_num IS NULL THEN
          IF (l_material_rec.reference_id IS NOT NULL) THEN
                  BEGIN
           SELECT prl.requisition_line_id, prl.line_num
             INTO l_material_rec.document_line_id, l_material_rec.document_line_num
             FROM po_requisition_lines_all prl, rcv_shipment_lines rsl
             WHERE rsl.shipment_line_id = l_material_rec.reference_id
             AND   prl.requisition_line_id = rsl.requisition_line_id;
        EXCEPTION
           WHEN no_data_found THEN
                        IF l_debug = 1 THEN
            trace('Can not derive document line for type REQ and reference_id = '||l_material_rec.reference_id);
                        END IF;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
          END IF;
            END IF;

            -- Receipt Number/Vendor
       IF l_material_rec.source_org_id IS NOT NULL THEN
               BEGIN
        SELECT organization_code ||'-'||organization_name
          INTO l_material_rec.trading_partner
          FROM org_organization_definitions
          WHERE organization_id = l_material_rec.source_org_id;
          EXCEPTION
        WHEN no_data_found THEN
           IF l_debug = 1 THEN
         trace('Can not derive src_org name for type INSTHIP and org_id = '||l_material_rec.source_org_id);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;
       END IF;
        ELSIF l_material_rec.document_type = 'RMA' THEN
            -- Document Number
       IF l_material_rec.document_number IS NULL THEN
          IF (l_material_rec.reference_id IS NOT NULL) THEN
                  BEGIN
           SELECT oeoh.header_id, to_char(oeoh.order_number), oeol.line_id, oeol.line_number
             INTO l_material_rec.document_id, l_material_rec.document_number
                       , l_material_rec.document_line_id, l_material_rec.document_line_num
             FROM oe_order_headers_all oeoh, oe_order_lines_all oeol
             WHERE oeol.line_id = l_material_rec.reference_id
             AND   oeoh.header_id = oeol.header_id;
        EXCEPTION
           WHEN no_data_found THEN
                        IF l_debug = 1 THEN
            trace('Can not derive document number for type RMA and reference_id='||l_material_rec.reference_id);
                        END IF;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
          END IF;
            END IF;

            -- Document Line
            IF l_material_rec.document_line_num IS NULL THEN
          IF (l_material_rec.reference_id IS NOT NULL) THEN
                  BEGIN
           SELECT oeol.line_id, oeol.line_number
             INTO l_material_rec.document_line_id, l_material_rec.document_line_num
             FROM oe_order_lines_all oeol
             WHERE oeol.line_id = l_material_rec.reference_id;
        EXCEPTION
           WHEN no_data_found THEN
                        IF l_debug = 1 THEN
            trace('Can not derive document line for type RMA and reference_id = '||l_material_rec.reference_id);
                        END IF;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
          END IF;
            END IF;

            -- Receipt Number/Vendor
       IF l_material_rec.vendor_id IS NOT NULL THEN
               BEGIN
        SELECT vendor_name INTO l_material_rec.trading_partner
          FROM po_vendors
          WHERE vendor_id = l_material_rec.vendor_id;
          EXCEPTION
        WHEN no_data_found THEN
           IF l_debug = 1 THEN
         trace('Can not derive vendor name for type RMA and vendor_id = '||l_material_rec.vendor_id);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;
            END IF;
        END IF;

        l_progress := '100-'||l_rec_count;
        -- Insert into the global temp table for eligible material
        insert_material_rec(l_material_rec);
   <<nextmolrec>>
     NULL;
    END LOOP;

    dbms_sql.close_cursor(l_cursor);

    IF l_debug = 1 THEN
        trace('Found eligible material records '||l_rec_count);
    END IF;


    --For patch set J, we will NOT be supporting the PJM transaction for loose
    --item if the query retrieved does not contain unique record with
    --item_id, project_id, task id combination. The reason is that we do not have
    --any logic as to which line to process FROM the list OF eligible
    --material in case we have multiple lines for same LOOSE item with
    -- different project and task

    IF p_is_pjm_enabled_org = 'Y' THEN

       IF l_debug = 1 THEN
          trace('Inside p_is_pjm_enabled_org condition');
       END IF;

       OPEN get_proj_task_rec;--GET ALL distinct records for loose ITEMS with project
       LOOP
          FETCH get_proj_task_rec INTO l_get_proj_task_rec;
          IF get_proj_task_rec%notfound THEN
         CLOSE get_proj_task_rec;
         EXIT;
          END IF;

                   select count(1) INTO l_item_cnt
                   FROM (select distinct project_id, task_id
                   from wms_packing_material_gtemp
                      WHERE lpn_id is NULL --loose items only
                      and inventory_item_id = l_get_proj_task_rec.inventory_item_id
                      AND project_id IS NOT NULL) wpmg;

          IF l_debug = 1 THEN
             trace('There are '||l_item_cnt||' item records with project/TASK');
          END IF;

          IF l_item_cnt > 1 THEN

             IF l_debug = 1 THEN
            trace('Do not know which one to pick: Return');
             END IF;

             CLOSE get_proj_task_rec;
             RAISE fnd_api.g_exc_error;

          END IF;

       END LOOP;

    END IF;--p_is_pjm_enabled_org

/*
    if fnd_global.user_id = 1005653  THEN --SATKUMAR
        insert into wms_packing_material_temp value (select * from wms_packing_material_gtemp);
        commit;
      end if;
*/

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
       x_return_status :=  fnd_api.G_RET_STS_ERROR;
     IF l_debug = 1 THEN
     trace('User defined: Show message:  x_return_status :'||x_return_status);
     END IF;

   WHEN others THEN
      IF l_debug = 1 THEN
     trace('Error in query_inbound_material(), progress='||l_progress);
     trace('ERROR CODE = ' || SQLCODE);
     trace('ERROR MESSAGE = ' || SQLERRM);
      END IF;
      dbms_sql.close_cursor(l_cursor);

      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;

END query_inbound_material;

/************************************************
 * Get a hash value for a given string
 * This function is to solve hash collision issue
 ************************************************/
FUNCTION get_column_hash_value (p_input_string VARCHAR2)
    RETURN NUMBER IS
    l_return_hash_value NUMBER;
    l_orig_hash_value NUMBER;
    l_hash_base NUMBER := 1;
    l_hash_size NUMBER := 256;
BEGIN
    l_orig_hash_value := dbms_utility.get_hash_value
    (
        name       => p_input_string
        ,base      => l_hash_base
        ,hash_size => l_hash_size
    );

    IF  g_lot_ser_attr.exists(l_orig_hash_value) AND
        g_lot_ser_attr(l_orig_hash_value).column_name = p_input_string THEN

        l_return_hash_value := l_orig_hash_value;
    ELSIF g_lot_ser_attr.exists(l_orig_hash_value) THEN
        -- hash collision
        LOOP
            l_orig_hash_value := l_orig_hash_value + 1;

            IF l_orig_hash_value > l_hash_size THEN
                -- Don't need to check hash overflow here because the hash range
                -- for sure is greater than the number of columns.
                l_orig_hash_value := l_hash_base;
            END IF;

            IF g_lot_ser_attr.exists(l_orig_hash_value) AND
               g_lot_ser_attr(l_orig_hash_value).column_name = p_input_string THEN
                EXIT;
            ELSIF NOT g_lot_ser_attr.exists(l_orig_hash_value) THEN
                EXIT;
            END IF;
        END LOOP;

        l_return_hash_value := l_orig_hash_value;

    ELSE
        l_return_hash_value := l_orig_hash_value;
    END IF;

    RETURN l_return_hash_value;

END get_column_hash_value;

/*********************************************
 * Get default lot/serial attribute
 * This is used for inbound for new lot/serial
 *********************************************/
PROCEDURE get_lot_ser_default_attribute(
    p_organization_id IN NUMBER
,   p_inventory_item_id IN NUMBER
,   p_lot_serial IN VARCHAR2
,   p_lot_or_serial IN VARCHAR2
) IS
    l_table_name VARCHAR2(30);
    l_flex_name VARCHAR2(30);

    l_attr_list INV_LOT_SEL_ATTR.lot_sel_attributes_tbl_type;
    l_null_attr INV_LOT_SEL_ATTR.lot_sel_attributes_tbl_type;
    l_context_code varchar2(30);
    l_count number;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_hash_value NUMBER;
    l_context_column VARCHAR2(50);
BEGIN
    IF l_debug = 1 THEN
        trace('In get_lot_ser_default_attribute ');
        trace(' p_inventory_item_id='||p_inventory_item_id||',p_lot_serial='||p_lot_serial||',p_lot_or_serial='||p_lot_or_serial);
    END IF;
    IF p_lot_or_serial = 'LOT' THEN
        l_table_name := 'MTL_LOT_NUMBERS';
        l_flex_name := 'Lot Attributes';
        l_context_column := 'LOT_ATTRIBUTE_CATEGORY';
    ELSIF p_lot_or_serial = 'SERIAL' THEN
        l_table_name := 'MTL_SERIAL_NUMBERS';
        l_flex_name := 'Serial Attributes';
        l_context_column := 'SERIAL_ATTRIBUTE_CATEGORY';
    END IF;

    g_lot_ser_attr.delete;

    INV_LOT_SEL_ATTR.get_context_code(
            context_value   => l_context_code
        ,   org_id      => p_organization_id
        ,   item_id     => p_inventory_item_id
        ,   flex_name   => l_flex_name);
    IF l_debug = 1 THEN
        trace(' Got context_code = '||l_context_code);
    END IF;
    INV_LOT_SEL_ATTR.get_default(
        x_attributes_default        => l_attr_list
    ,   x_attributes_default_count  => l_count
    ,   x_return_status             => l_return_status
    ,   x_msg_count                 => l_msg_count
    ,   x_msg_data                  => l_msg_data
    ,   p_table_name                => l_table_name
    ,   p_attributes_name           => l_flex_name
    ,   p_inventory_item_id         => p_inventory_item_id
    ,   p_organization_id          => p_organization_id
    --, p_lot_serial_number        => p_lot_serial
    ,   p_lot_serial_number        => null
    ,   p_attributes              => l_null_attr);

    IF l_return_status <> 'S' THEN
        IF l_debug = 1 THEN
            trace('Error in INV_LOT_SEL_ATTR.get_default,msg_data='||l_msg_data);
        END IF;
        RETURN ;
    END IF;
    FOR i IN 1..l_attr_list.count Loop
        g_lot_ser_attr(get_column_hash_value(l_attr_list(i).COLUMN_NAME)) := l_attr_list(i);
    END LOOP;

    g_lot_ser_attr(get_column_hash_value(l_context_column)).COLUMN_VALUE := l_context_code;

EXCEPTION
    WHEN others THEN
        IF l_debug = 1 THEN
            trace('Error in get_lot_ser_default_attribute');
            trace('ERROR Code ='||SQLCODE);
            trace('ERROR Message='||SQLERRM);
        END IF;
END get_lot_ser_default_attribute;

/***************************************
 * Function to get default values
 * for a given column
 **************************************/
FUNCTION get_column_default_value(p_column_name IN VARCHAR2)
    RETURN VARCHAR2 IS
    l_hash_value NUMBER;
BEGIN
    l_hash_value := get_column_hash_value(p_column_name);
    IF g_lot_ser_attr.exists(l_hash_value) THEN
        RETURN g_lot_ser_attr(l_hash_value).column_value;
    ELSE
        RETURN NULL;
    END IF;
END get_column_default_value;
/********************************************
 Procedure to query outbound eligible material
 *******************************************/
PROCEDURE query_outbound_material(
  x_return_status OUT NOCOPY VARCHAR2
, p_organization_id IN NUMBER
, p_organization_code IN VARCHAR2
, p_subinventory_code IN VARCHAR2 DEFAULT NULL
, p_locator_id IN VARCHAR2 DEFAULT NULL
, p_locator IN VARCHAR2 DEFAULT NULL
, p_inventory_item_id IN NUMBER DEFAULT NULL
, p_item IN VARCHAR2 DEFAULT NULL
, p_from_lpn_id IN NUMBER DEFAULT NULL
, p_project_id IN NUMBER DEFAULT NULL
, p_project IN VARCHAR2 DEFAULT NULL
, p_task_id IN NUMBER DEFAULT NULL
, p_task IN VARCHAR2 DEFAULT NULL
, p_delivery_id IN NUMBER DEFAULT NULL
, p_delivery IN VARCHAR2 DEFAULT NULL
, p_order_header_id IN NUMBER DEFAULT NULL
, p_order_number IN VARCHAR2 DEFAULT NULL
, p_order_type  IN VARCHAR2 DEFAULT NULL
, p_carrier_id IN NUMBER DEFAULT NULL
, p_carrier IN VARCHAR2 DEFAULT NULL
, p_trip_id IN NUMBER DEFAULT NULL
, p_trip IN VARCHAR2 DEFAULT NULL
, p_delivery_state IN VARCHAR2 DEFAULT NULL
, p_customer_id IN NUMBER DEFAULT NULL
, p_customer IN VARCHAR2 DEFAULT NULL
) IS

    -- Bug 4237771, performance
    -- Use different delivery cursor to use index as much as possible

    -- Use this cursor when p_delivery_is is not null
    CURSOR l_delivery_cur_del IS
    SELECT wnd.delivery_id, wnd.name,
           nvl(p_delivery_state, wms_consolidation_pub.is_delivery_consolidated(wnd.delivery_id, p_organization_id, p_subinventory_code, p_locator_id))
    FROM   wsh_new_deliveries_ob_grp_v wnd
    WHERE  wnd.organization_id = p_organization_id
    AND    wnd.delivery_id = p_delivery_id
    AND    ((p_trip_id IS NULL) OR
            (p_trip_id IS NOT NULL AND wnd.delivery_id IN
              (select wdl.delivery_id from wsh_delivery_legs_ob_grp_v wdl, wsh_trip_stops_ob_grp_v wts
               where wdl.pick_up_stop_id = wts.stop_id
               and wts.trip_id = p_trip_id)))
    AND    ((p_delivery_state IS NULL) OR
            (p_delivery_state IS NOT NULL AND
             wms_consolidation_pub.is_delivery_consolidated(wnd.delivery_id, p_organization_id, p_subinventory_code, p_locator_id) = p_delivery_state));

    -- Use this cursor when p_delivery_is is null but p_trip_id is not null
    CURSOR l_delivery_cur_trip IS
    SELECT wnd.delivery_id, wnd.name,
           nvl(p_delivery_state, wms_consolidation_pub.is_delivery_consolidated(wnd.delivery_id, p_organization_id, p_subinventory_code, p_locator_id))
    FROM   wsh_new_deliveries_ob_grp_v wnd
    WHERE  wnd.organization_id = p_organization_id
    AND    wnd.delivery_id IN
              (select wdl.delivery_id from wsh_delivery_legs_ob_grp_v wdl, wsh_trip_stops_ob_grp_v wts
               where wdl.pick_up_stop_id = wts.stop_id
               and wts.trip_id = p_trip_id)
    AND    ((p_delivery_state IS NULL) OR
            (p_delivery_state IS NOT NULL AND
             wms_consolidation_pub.is_delivery_consolidated(wnd.delivery_id, p_organization_id, p_subinventory_code, p_locator_id) = p_delivery_state));

    -- Use this cursor when both p_delivery_id and p_trip_id are null
    -- Then have to use this expensive cursor
    CURSOR l_delivery_cur_exp IS
    SELECT wnd.delivery_id, wnd.name,
           nvl(p_delivery_state, wms_consolidation_pub.is_delivery_consolidated(wnd.delivery_id, p_organization_id, p_subinventory_code, p_locator_id))
    FROM   wsh_new_deliveries_ob_grp_v wnd
    WHERE  wnd.organization_id = p_organization_id
    AND    ((p_delivery_state IS NULL) OR
            (p_delivery_state IS NOT NULL AND
             wms_consolidation_pub.is_delivery_consolidated(wnd.delivery_id, p_organization_id, p_subinventory_code, p_locator_id) = p_delivery_state));

    CURSOR l_wdd_cur(pl_delivery_id NUMBER) IS
    SELECT wdd1.organization_id
          ,wdd1.subinventory
          ,wdd1.locator_id
          ,wdd1.project_id
          ,wdd1.task_id
          ,wdd1.inventory_item_id
          ,wdd1.revision
          ,wdd1.lot_number
          ,wdd1.requested_quantity_uom uom
          ,sum(wdd1.requested_quantity) quantity
          ,wdd1.requested_quantity_uom2 uom2        --INVCONV KKILLAMS
          ,sum(wdd1.requested_quantity2) quantity2  --INVCONV KKILLAMS
          ,wdd2.lpn_id
          ,wda.delivery_id
          -- Bug 5121507, Get carrier in the order of Trip->Delivery->Delivery Detail
          --,nvl(wdd1.carrier_id, wnd.carrier_id) carrier_id
          ,nvl(wt.carrier_id, nvl(wnd.carrier_id, wdd1.carrier_id)) carrier_id
          ,wdd1.source_header_id
          ,wdd1.source_header_number
          ,wdd1.source_line_id
          ,wdd1.source_line_number
          ,nvl(wdd1.customer_id, wnd.customer_id)
          ,wdd1.ship_to_location_id
          ,wdd1.ship_set_id
          ,wdd1.top_model_line_id
    FROM wsh_delivery_details_ob_grp_v wdd1, wsh_delivery_details_ob_grp_v wdd2
        ,wsh_delivery_assignments_v wda, wsh_new_deliveries_ob_grp_v wnd
        -- Bug 5121507
        ,  wsh_delivery_legs            wdl
        ,  wsh_trip_stops               wts
        ,  wsh_trips                    wt
    WHERE wda.delivery_detail_id = wdd1.delivery_detail_id
    AND   wda.parent_delivery_detail_id = wdd2.delivery_detail_id
    AND   wnd.delivery_id (+) = wda.delivery_id
    AND   wdd1.released_status = 'Y'
    AND   wdd2.lpn_id IS NOT NULL
    AND   wdd2.released_status = 'X'  -- For LPN reuse ER : 6845650
    AND   wdd2.lpn_id IN
          (select lpn_id from wms_license_plate_numbers
           where organization_id = p_organization_id
           and lpn_context = 11)
    -- restriction from find window
    AND   wdd1.organization_id = p_organization_id
    AND   wdd1.subinventory = nvl(p_subinventory_code, wdd1.subinventory)
    AND   nvl(wdd1.locator_id, -999) = nvl(p_locator_id, nvl(wdd1.locator_id, -999))
    AND   ((wdd2.lpn_id = nvl(p_from_lpn_id, wdd2.lpn_id)) OR
           (wdd2.lpn_id IN (select lpn_id from wms_license_plate_numbers where outermost_lpn_id = p_from_lpn_id)))
    AND   wdd1.inventory_item_id = nvl(p_inventory_item_id, wdd1.inventory_item_id )
    AND   nvl(wdd1.project_id, -9999) = nvl(p_project_id,nvl(wdd1.project_id, -9999))
    AND   nvl(wdd1.task_id, -9999) = nvl(p_task_id,nvl(wdd1.task_id, -9999))
    AND   ((pl_delivery_id IS NULL) OR
           (pl_delivery_id IS NOT NULL AND wda.delivery_id = pl_delivery_id))
    AND   wdd1.source_header_number = nvl(p_order_number, wdd1.source_header_number)
    AND   wdd1.source_header_type_name = nvl(p_order_type, wdd1.source_header_type_name)
    -- Bug 5121507
    --AND   nvl(nvl(wdd1.carrier_id, wnd.carrier_id), -9999) = nvl(p_carrier_id, nvl(nvl(wdd1.carrier_id, wnd.carrier_id), -9999))
    AND   nvl(nvl(wt.carrier_id, nvl(wnd.carrier_id,wdd1.carrier_id)), -9999) = nvl(p_carrier_id, nvl(nvl(wt.carrier_id, nvl(wnd.carrier_id,wdd1.carrier_id)), -9999))
    AND   wdd1.customer_id = nvl(p_customer_id, wdd1.customer_id)
    -- Bug 5121507
    AND   wnd.delivery_id            = wdl.delivery_id(+)
    AND   wdl.pick_up_stop_id        = wts.stop_id (+)
    AND   wts.trip_id                = wt.trip_id (+)
    GROUP BY wdd1.organization_id
          ,wdd1.subinventory
          ,wdd1.locator_id
          ,wdd1.project_id
          ,wdd1.task_id
          ,wdd1.inventory_item_id
          ,wdd1.revision
          ,wdd1.lot_number
          ,wdd1.requested_quantity_uom
          ,wdd1.requested_quantity_uom2   --INVCONV KKILLAMS
          ,wdd2.lpn_id
          ,wda.delivery_id
          -- Bug 5121507
          --,nvl(wdd1.carrier_id, wnd.carrier_id)
          ,nvl(wt.carrier_id, nvl(wnd.carrier_id,wdd1.carrier_id))
          ,wdd1.source_header_id
          ,wdd1.source_header_number
          ,wdd1.source_line_id
          ,wdd1.source_line_number
          ,nvl(wdd1.customer_id, wnd.customer_id)
          ,wdd1.ship_to_location_id
          ,wdd1.ship_set_id
          ,wdd1.top_model_line_id;

    l_progress VARCHAR2(10);

    l_material_rec WMS_PACKING_MATERIAL_GTEMP%ROWTYPE;
    l_null_material WMS_PACKING_MATERIAL_GTEMP%ROWTYPE;
    l_del_count NUMBER;
    l_rec_count NUMBER;

    l_delivery_id NUMBER;
    l_delivery VARCHAR2(30);
    l_delivery_state VARCHAR2(1);
    l_delivery_req BOOLEAN;
    l_top_model_line_id NUMBER;
BEGIN
    l_progress := '000';

    IF l_debug = 1 THEN
        trace('In WMS Packing Workbench, package header ='|| g_pkg_version);
        trace('Query outbound eligible material with parameters :');
        trace('  p_organization_id='||p_organization_id||', p_organization_code='||p_organization_code);
        trace('  p_subinventory_code='||p_subinventory_code);
        trace('  p_locator_id='||p_locator_id||', p_locator='||p_locator);
        trace('  p_inventory_item_id='||p_inventory_item_id||',p_item='||p_item);
        trace('  p_from_lpn_id='||p_from_lpn_id);
        trace('  p_project_id='||p_project_id||', p_project='||p_project);
        trace('  p_task_id='||p_task_id||',p_task='||p_task);
        trace('  p_delivery_id='||p_delivery_id||', p_delivery='||p_delivery);
        trace('  p_order_header_id='||p_order_header_id);
        trace('  p_order_number='||p_order_number||', p_order_type='||p_order_type);
        trace('  p_carrier_id='||p_carrier_id||', p_carrier='||p_carrier);
        trace('  p_trip_id='||p_trip_id||', p_trip='||p_trip);
        trace('  p_delivery_state='||p_delivery_state);
        trace('  p_customer_id='||p_customer_id||', p_customer='||p_customer);
    END IF;

    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    l_del_count := 0;
    l_rec_count := 0;

    delete from wms_packing_material_gtemp;
    --delete from wms_packing_material_temp;

    l_progress := '010';
    IF (p_delivery_id IS NOT NULL) OR (p_trip_id IS NOT NULL) OR (p_delivery_state IS NOT NULL) THEN
        IF l_debug = 1 THEN
            trace(' Delivery requirement specified');
        END IF;
        l_delivery_req := true;

        -- Bug 4237771, open l_delivery_cur_* conditionally to improve performance
        -- If either p_delivery_id or p_trip_is is not null, then it can use unique index on wnd.delivery_id
        -- Otherwise, have to use a more expensive cursor
        IF (p_delivery_id IS NOT NULL) THEN
            OPEN l_delivery_cur_del;
        ELSIF (p_trip_id IS NOT NULL) THEN
            OPEN l_delivery_cur_trip;
        ELSE
            OPEN l_delivery_cur_exp;
        END IF;
    ELSE
        l_delivery_req := false;
        l_delivery_id := null;
    END IF;

    l_progress := '020';

    LOOP -- Loop for delivery
        l_delivery_id := null;
        l_delivery := null;
        IF l_delivery_req THEN
            l_progress := '030'||'-'||l_del_count;
            -- Bug 4237771
            IF l_delivery_cur_del%ISOPEN THEN
            FETCH l_delivery_cur_del INTO
               l_delivery_id, l_delivery, l_delivery_state;
            IF l_delivery_cur_del%NOTFOUND THEN
               --trace('No more delivery found in l_delivery_cur_del');
               EXIT;
            END IF;
         ELSIF l_delivery_cur_trip%ISOPEN THEN
            FETCH l_delivery_cur_trip INTO
               l_delivery_id, l_delivery, l_delivery_state;
            IF l_delivery_cur_trip%NOTFOUND THEN
               --trace('No more delivery found in l_delivery_cur_trip');
               EXIT;
            END IF;
         ELSIF l_delivery_cur_exp%ISOPEN THEN
            FETCH l_delivery_cur_exp INTO
               l_delivery_id, l_delivery, l_delivery_state;
            IF l_delivery_cur_exp%NOTFOUND THEN
               --trace('No more delivery found in l_delivery_cur_exp');
               EXIT;
            END IF;
         END IF;

            l_del_count := l_del_count + 1;
        END IF;

        OPEN l_wdd_cur(l_delivery_id);
        LOOP
            l_material_rec := l_null_material;
            FETCH l_wdd_cur INTO
                l_material_rec.organization_id
               ,l_material_rec.subinventory
               ,l_material_rec.locator_id
               ,l_material_rec.project_id
               ,l_material_rec.task_id
               ,l_material_rec.inventory_item_id
               ,l_material_rec.revision
               ,l_material_rec.lot_number
               ,l_material_rec.uom
               ,l_material_rec.quantity
               ,l_material_rec.secondary_uom_code  --invconv kkillams
               ,l_material_rec.secondary_quantity  --invconv kkillams
               ,l_material_rec.lpn_id
               ,l_material_rec.delivery_id
               ,l_material_rec.carrier_id
               ,l_material_rec.order_header_id
               ,l_material_rec.order_number
               ,l_material_rec.order_line_id
               ,l_material_rec.order_line_num
               ,l_material_rec.customer_id
               ,l_material_rec.ship_to_location_id
              ,l_material_rec.ship_set_id
              ,l_top_model_line_id;

            IF l_wdd_cur%NOTFOUND THEN
                --trace('no more WDD found for delivery '||l_delivery_id);
                EXIT;
            END IF;


            /* Comment out the following debug to reduce logging
            IF l_debug = 1 THEN
               trace(' Value of  l_material_rec.order_line_id :'|| l_material_rec.order_line_id);
               trace(' Value of  order_line_num :'|| l_material_rec.order_line_num);
               trace(' Value of l_material_rec.order_header_id :'||l_material_rec.order_header_id);

               trace(' Value of l_material_rec.order_number :'||l_material_rec.order_number);

            END IF;
            */





            l_rec_count := l_rec_count +1;
            l_progress := '040'||'-'||l_rec_count;
            -- Derive column values
            -- Organization_code
            l_material_rec.organization_code := p_organization_code;
            l_progress := '041'||'-'||l_rec_count;
            -- Locator
            IF p_locator IS NOT NULL THEN
                l_material_rec.locator := p_locator;
            ELSIF l_material_rec.locator_id IS NOT NULL THEN
              BEGIN
                SELECT
                  inv_project.get_locsegs(l_material_rec.locator_id,l_material_rec.organization_id) /*bug344642  concatenated_segments*/ INTO l_material_rec.locator
                FROM mtl_item_locations_kfv
                WHERE organization_id = l_material_rec.organization_id
                AND subinventory_code = l_material_rec.subinventory
                AND inventory_location_id = l_material_rec.locator_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF l_debug = 1 THEN
                        trace(' can not find locator name for loc_id '|| l_material_rec.locator_id);
                    END IF;
                    l_material_rec.locator := null;
              END;
            END IF;
            l_progress := '043'||'-'||l_rec_count;
            -- Project
            IF p_project IS NOT NULL THEN
                l_material_rec.project := p_project;
            ELSIF l_material_rec.project_id IS NOT NULL THEN
              BEGIN
                SELECT name INTO l_material_rec.project
                FROM pa_projects WHERE project_id = l_material_rec.project_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF l_debug = 1 THEN
                        trace(' can not find project name for project_id '|| l_material_rec.project_id);
                    END IF;
                    l_material_rec.project := null;
              END;
            END IF;
            l_progress := '045'||'-'||l_rec_count;
            -- Task
            IF l_material_rec.task_id IS NOT NULL THEN
              BEGIN
                SELECT task_number,task_name INTO l_material_rec.task_number, l_material_rec.task_name
                FROM pa_tasks
                WHERE project_id = l_material_rec.project_id
                AND task_id = l_material_rec.task_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF l_debug = 1 THEN
                        trace(' can not find task name for task_id '|| l_material_rec.task_id);
                    END IF;
                    l_material_rec.task_number := null;
                    l_material_rec.task_name := null;
              END;
            END IF;
            l_progress := '047'||'-'||l_rec_count;
            -- Item
            IF p_item IS NOT NULL THEN
                l_material_rec.item := p_item;
            ELSIF l_material_rec.inventory_item_id IS NOT NULL THEN
              BEGIN
                SELECT concatenated_segments,description INTO l_material_rec.item, l_material_rec.item_description
                FROM mtl_system_items_kfv
                WHERE organization_id = l_material_rec.organization_id
                AND inventory_item_id = l_material_rec.inventory_item_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF l_debug = 1 THEN
                        trace(' can not find item for item_id '|| l_material_rec.inventory_item_id);
                    END IF;
                    l_material_rec.item := null;
                    l_material_rec.item_description := null;
              END;
            END IF;
            l_progress := '049'||'-'||l_rec_count;
            -- LPN, Parent LPN, Outermost LPN
            IF l_material_rec.lpn_id IS NOT NULL THEN
              BEGIN
                SELECT lpn.license_plate_number, lpn.parent_lpn_id, pLpn.license_plate_number,
                       lpn.outermost_lpn_id, oLpn.license_plate_number
                INTO l_material_rec.lpn, l_material_rec.parent_lpn_id, l_material_rec.parent_lpn,
                     l_material_rec.outermost_lpn_id, l_material_rec.outermost_lpn
                FROM wms_license_plate_numbers lpn, wms_license_plate_numbers pLpn, wms_license_plate_numbers oLpn
                WHERE lpn.lpn_id = l_material_rec.lpn_id
                AND pLpn.lpn_id(+) = lpn.parent_lpn_id
                AND oLpn.lpn_id(+) = lpn.outermost_lpn_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF l_debug = 1 THEN
                        trace(' can not find lpn for lpn_id '|| l_material_rec.lpn_id);
                    END IF;
                    l_material_rec.lpn := null;
                    l_material_rec.parent_lpn_id := null;
                    l_material_rec.parent_lpn := null;
                    l_material_rec.outermost_lpn_id := null;
                    l_material_rec.outermost_lpn := null;
              END;
            END IF;

            l_progress := '0411'||'-'||l_rec_count;
            -- Delivery
            IF l_delivery IS NOT NULL THEN
                l_material_rec.delivery := l_delivery;
            ELSIF l_material_rec.delivery_id IS NOT NULL THEN
              BEGIN
                SELECT name INTO l_material_rec.delivery
                FROM wsh_new_deliveries
                WHERE delivery_id = l_material_rec.delivery_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF l_debug = 1 THEN
                        trace(' can not find delivery name for delivery_id '||l_material_rec.delivery_id);
                    END IF;
                    l_material_rec.delivery := null;
              END;
            END IF;

            l_progress := '0413'||'-'||l_rec_count;

            -- Delivery State
            IF l_delivery_state IS NOT NULL THEN
                l_material_rec.delivery_completed := l_delivery_state;
            ELSIF l_material_rec.delivery_id IS NOT NULL THEN
                l_material_rec.delivery_completed := wms_consolidation_pub.is_delivery_consolidated(l_material_rec.delivery_id, p_organization_id, p_subinventory_code, p_locator_id);
            END IF;

            l_progress := '0415'||'-'||l_rec_count;
            -- Trip
            IF p_trip IS NOT NULL THEN
                l_material_rec.trip := p_trip;
            ELSIF l_material_rec.delivery_id IS NOT NULL THEN
                IF l_debug = 1 THEN
                    trace('delivery_id='||l_material_rec.delivery_id);
                END IF;
                BEGIN
                    SELECT t.trip  INTO l_material_rec.trip
                    FROM(
                      SELECT distinct wt.name trip
                      FROM wsh_delivery_legs wdl, wsh_trip_stops wts, wsh_trips wt
                      WHERE wdl.delivery_id = l_material_rec.delivery_id
                      AND   wts.stop_id = wdl.pick_up_stop_id
                      AND   wt.trip_id = wts.trip_id) t
                    WHERE rownum <2;
                EXCEPTION
                    WHEN no_data_found THEN
                        /* Comment out the following debug to reduce logging
                        IF l_debug = 1 THEN
                            trace(' can not find trip name for delivery_id '||l_material_rec.delivery_id);
                        END IF;
                        */
                        l_material_rec.trip := null;
                END;
            END IF;

            l_progress := '0417'||'-'||l_rec_count;

            -- Carrier
            IF p_carrier IS NOT NULL THEN
                l_material_rec.carrier := p_carrier;
            ELSIF l_material_rec.carrier_id IS NOT NULL THEN
              BEGIN
                SELECT carrier_name INTO l_material_rec.carrier
                FROM wsh_carriers_v
                WHERE carrier_id = l_material_rec.carrier_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF l_debug = 1 THEN
                        trace(' can not find carrier name for carrier_id '||l_material_rec.carrier_id);
                    END IF;
                    l_material_rec.carrier := null;
              END;
            END IF;

            l_progress := '0419'||'-'||l_rec_count;
            -- Packing Instruction
            IF l_material_rec.order_line_id IS NOT NULL AND l_material_rec.order_header_id IS NOT NULL THEN
              BEGIN
                SELECT nvl(oeol.packing_instructions, oeoh.packing_instructions)
                INTO l_material_rec.packing_instruction
                FROM oe_order_headers_all oeoh, oe_order_lines_all oeol
                WHERE oeoh.header_id = oeol.header_id
                AND oeol.line_id = l_material_rec.order_line_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF l_debug = 1 THEN
                        trace(' can not find packing instruction for order_line_id '||l_material_rec.order_line_id);
                    END IF;
                    l_material_rec.packing_instruction := null;
              END;
            END IF;

            l_progress := '0421'||'-'||l_rec_count;
            -- Customer
       -- Bug4579790
            IF l_material_rec.customer_id IS NOT NULL THEN
              BEGIN
                -- Bug 5363505
                -- the following query will return more than one row
                --  if there are more than one accounts for the party
                -- No need to join to hz_cust_accounts table

                SELECT party.party_number, party.party_name
                INTO l_material_rec.customer_number, l_material_rec.customer_name
                FROM hz_parties party --, hz_cust_accounts cust_acct
                WHERE party.party_id = l_material_rec.customer_id;
                --AND   cust_acct.party_id = party.party_id;
              EXCEPTION
                WHEN OTHERS THEN
                    IF l_debug = 1 THEN
                        trace(' can not find customer for customer_id '||l_material_rec.customer_id);
                    END IF;
                    l_material_rec.customer_number := null;
                    l_material_rec.customer_name := null;
              END;
            END IF;

            l_progress := '0423'||'-'||l_rec_count;
            -- Ship To Location
            IF l_material_rec.ship_to_location_id IS NOT NULL THEN
                --IF internal location IO
              BEGIN
                SELECT location_code INTO l_material_rec.ship_to_location
                FROM hr_locations_all
                WHERE location_id = l_material_rec.ship_to_location_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_material_rec.ship_to_location := null;
              END;

              BEGIN
                SELECT nvl(city, address1)||':'||to_char(location_id)
                INTO l_material_rec.ship_to_location
                FROM hz_locations
                WHERE location_id = l_material_rec.ship_to_location_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF l_debug = 1 THEN
                        trace(' can not find location for external location_id '||l_material_rec.ship_to_location_id);
                    END IF;
                    l_material_rec.ship_to_location := null;
              END;
            END IF;

            -- PTO Flag
            IF l_top_model_line_id IS NOT NULL
              THEN
               BEGIN
                    SELECT 'Y' INTO l_material_rec.pto_flag
                    FROM dual
                    WHERE exists (
                        select 1 from  oe_order_lines_all oel, oe_order_lines_all oel1
                        where oel.inventory_item_id = l_material_rec.inventory_item_id
                        and oel.top_model_line_id =  l_top_model_line_id
                        and oel1. inventory_item_id = oel.inventory_item_id
                        and oel1.top_model_line_id = oel.top_model_line_id
                        and (((oel.shippable_flag = 'Y' or oel.line_id = oel.top_model_line_id)
                                AND (oel.ato_line_id <> oel.TOP_MODEL_LINE_ID OR oel.ato_line_id IS NULL))
                           OR (oel1.ato_line_id is not null and oel1.line_id = oel1.top_model_line_id))
                       );
                EXCEPTION
                  WHEN no_data_found THEN
                 l_material_rec.pto_flag := 'N';
               END;
            END IF;

            -- Ship Set
            IF l_material_rec.ship_set_id IS NOT NULL THEN
                BEGIN
                    SELECT set_name
                    INTO l_material_rec.ship_set
                    FROM oe_sets
                    WHERE set_id = l_material_rec.ship_set_id;
                EXCEPTION
                    WHEN no_data_found THEN
                        IF l_debug =1 THEN
                            trace(' can not find ship_set_name for ship_set_id '||l_material_rec.ship_set_id);
                        END IF;
                        l_material_rec.ship_set := null;
                END;
            END IF;

            -- Insert into the global temp table for eligible material
            insert_material_rec(l_material_rec);

        END LOOP; -- End WDD Loop
        CLOSE l_wdd_cur;

        IF NOT l_delivery_req THEN
            EXIT;
        END IF;

    END LOOP; -- End delivery loop
    IF l_debug = 1 THEN
        trace('Found total '||l_rec_count||' WDD records for total '||l_del_count||' deliveries');
    END IF;

    IF l_delivery_cur_del%ISOPEN THEN
        CLOSE l_delivery_cur_del;
    END IF;

    IF l_delivery_cur_trip%ISOPEN THEN
        CLOSE l_delivery_cur_trip;
    END IF;

    IF l_delivery_cur_exp%ISOPEN THEN
        CLOSE l_delivery_cur_exp;
    END IF;

    --insert into wms_packing_material_temp value (select * from wms_packing_material_gtemp);
    --commit;


EXCEPTION
    WHEN others THEN
        IF l_debug = 1 THEN
            trace('Error in query_outbound_material(), l_progress='||l_progress);
            trace('ERROR CODE = ' || SQLCODE);
            trace('ERROR MESSAGE = ' || SQLERRM);
        END IF;
        x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
END query_outbound_material;


FUNCTION get_kit_list(
    p_organization_id IN NUMBER
   ,p_item_id IN NUMBER
   ,p_existing_kit IN VARCHAR2 DEFAULT 'N') RETURN kit_tbl_type IS

    l_kit_list kit_tbl_type;
    l_kit_rec kit_rec_type;
    l_count NUMBER;

    CURSOR kit_exist_cur IS
       SELECT distinct kit_item_id, top_model_line_id, 'Y','N' identified_flag
         /*is_kit_identified(kit_item_id) identified_flag*/
        FROM wms_packing_kitting_gtemp
        WHERE nvl(completed_flag,'N') <> 'Y'
          ORDER BY identified_flag desc;

    --in the cursor kit_new_cu We did not use join with WPKG table
    -- since we need to know whether new scanned item IS UNIQUE across ALL the possible
    --kits IN the list OF eligible matrl, rather we will do programatically
    CURSOR kit_new_cur IS
        SELECT oel.INVENTORY_ITEM_id, oel.top_model_line_id, 'N', 'N'
        FROM  oe_order_lines_all oel
        WHERE oel.line_id = oel.top_model_line_id
        AND oel.ato_line_id IS NULL
        AND oel.top_model_line_id in (
            select oel1.top_model_line_id
            from oe_order_lines_all oel1,oe_order_lines_all oel2
            where oel1.inventory_item_id = p_item_id
            and oel2. inventory_item_id = oel1.inventory_item_id
            and oel2.top_model_line_id = oel1.top_model_line_id
            AND oel1.line_id = oel2.line_id --bug 3458361
               and (((oel1.shippable_flag = 'Y') AND (oel1.line_id <> oel1.TOP_MODEL_LINE_ID) and (oel1.ato_line_id is null))
               OR (oel2.ato_line_id is not null and oel2.line_id = oel2.top_model_line_id))
           )
        AND exists (
                select 1 from WMS_PACKING_MATERIAL_GTEMP wpmg, oe_order_lines_all oel1
                where WPMG.order_header_id = oel1.header_id
                AND wpmg.order_line_id = oel1.line_id
                AND wpmg.inventory_item_id = p_item_id
                AND wpmg.inventory_item_id = oel1.inventory_item_id
                AND oel.top_model_line_id = oel1.top_model_line_id
                AND oel.header_id = oel1.header_id);


      l_item_in_existing_kit NUMBER;


BEGIN
    l_kit_list.DELETE;
    l_count := 0;

    -- Get existing kit
    OPEN kit_exist_cur;
    LOOP
        FETCH kit_exist_cur INTO l_kit_rec;
        IF kit_exist_cur%notfound THEN
            CLOSE kit_exist_cur;
            EXIT;
        END IF;
        l_count := l_count + 1;
        l_kit_list(l_count):= l_kit_rec;
    END LOOP;
    IF l_debug = 1 THEN
        trace('Found '||l_kit_list.COUNT||' existing kit');
    END IF;


    IF Nvl(p_existing_kit,'N') = 'N' THEN
        -- Get new kit

       g_kit_count_current_comp := 0;

       OPEN kit_new_cur;
        LOOP
           FETCH kit_new_cur INTO l_kit_rec;
           IF kit_new_cur%notfound THEN
              CLOSE kit_new_cur;
              EXIT;

           END IF;

           l_item_in_existing_kit := 0;

                   BEGIN
           select 1 INTO l_item_in_existing_kit FROM dual
             WHERE exists
             (SELECT 1 from WMS_PACKING_KITTING_GTEMP WPKG
             where WPKG.top_model_line_id = l_kit_rec.top_model_line_id);

           EXCEPTION
              WHEN no_data_found THEN
             l_item_in_existing_kit := 0;
              WHEN too_many_rows THEN
              l_item_in_existing_kit := 1;
           END;

           IF l_debug = 1 THEN
              trace('Current Item is in the list of existing kits (1:YES)'||l_item_in_existing_kit);
           END IF;

           --Add only new kits retrieved by query into the
           --wpkg table, We did not use join with WPKG table
           --IN the CURSOR since we need to know whether new
           --scanned item IS UNIQUE across ALL the possible
           --kits IN the list OF eligible matrl

           IF l_item_in_existing_kit <>  1 then
              l_count := l_count+1;
              l_kit_list(l_count):=l_kit_rec;
           END IF;

           g_kit_count_current_comp := g_kit_count_current_comp +1;

        END LOOP;


    END IF;


    IF l_debug = 1 THEN
        trace('Total '||g_kit_count_current_comp||' kits for CURRENT item');
        trace('Found total unique '||l_kit_list.COUNT||' kits');
    END IF;
    RETURN l_kit_list;
EXCEPTION
    WHEN others THEN
        IF l_debug = 1 THEN
            trace('ERROR CODE = ' || SQLCODE);
            trace('ERROR MESSAGE = ' || SQLERRM);
        END IF;
    RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;

END get_kit_list;

PROCEDURE insert_kit_info(
    p_kit_item_id IN NUMBER
,   p_component_item_id IN NUMBER
,   p_top_model_line_id IN NUMBER
,   p_packed_qty IN NUMBER
,   p_disp_packed_qty IN VARCHAR2
) IS

    CURSOR kit_component_cur IS
        SELECT msi.concatenated_segments ITEM,
               msi.inventory_item_id ITEM_ID,
               --round(oel.ordered_quantity/oel1.ordered_quantity) bom_qty,
               oel.ordered_quantity ORD_QTY,
               OEL.top_model_LINE_ID
          FROM oe_order_lines_all oel, mtl_system_items_kfv msi, oe_order_lines_all oel1
          WHERE oel.inventory_item_id = msi.inventory_item_id
          AND oel.ship_from_org_id = msi.organization_id
          AND oel1.inventory_item_id = msi.inventory_item_id
          AND oel1.ship_from_org_id = msi.organization_id
          AND oel.top_model_line_id = p_top_model_line_id
          AND oel1.top_model_line_id = oel.top_model_line_id
          AND oel1.line_id = oel.line_id --bug 3458361
          AND (((oel.shippable_flag = 'Y' or oel.line_id = oel.top_model_line_id)
                AND (oel.ato_line_id <> oel.TOP_MODEL_LINE_ID OR oel.ato_line_id IS NULL))
           OR (oel1.ato_line_id is not null and oel1.line_id = oel1.top_model_line_id))
        ORDER BY oel.top_model_line_id,oel.shippable_flag;

     l_kit_rec wms_packing_kitting_gtemp%ROWTYPE;
     l_kit_item_id NUMBER;
     l_kit_oqty NUMBER;
BEGIN
    IF l_debug = 1 THEN
        trace('In insert_kit_info, p_kit_item_id='||p_kit_item_id||',p_component_item_id='||p_component_item_id);
        trace('    p_top_model_line_id='||p_top_model_line_id||',p_packed_qty='||p_packed_qty||',p_disp_packed_qty='||p_disp_packed_qty);
    END IF;
    OPEN kit_component_cur;
    -- get kit information
    FETCH kit_component_cur INTO
        l_kit_rec.item, l_kit_rec.kit_item_id
        , l_kit_rec.order_qty
        ,l_kit_rec.top_model_line_id;
    IF kit_component_cur%NOTFOUND THEN

       IF l_debug = 1 THEN
            trace('No Kit info found for top_model_line_id '||p_top_model_line_id);
        END IF;
        CLOSE kit_component_cur;
        RETURN;
    END IF;
    l_kit_rec.component_item_id := null;
    l_kit_rec.packed_qty := null;
    l_kit_rec.packed_qty_disp := null;
    l_kit_rec.completed_flag := 'N';

    INSERT INTO wms_packing_kitting_gtemp
    ( ITEM
    , kit_item_id
    , component_item_id
    , top_model_line_id
    ,  BOM_QTY
    ,  ORDER_QTY
    ,  PACKED_QTY
    , packed_qty_disp
    , completed_flag) VALUES
    (l_kit_rec.item
    ,l_kit_rec.kit_item_id
    ,l_kit_rec.component_item_id
    ,l_kit_rec.top_model_line_id
    ,1
    ,l_kit_rec.ORDER_QTY
    ,l_kit_rec.PACKED_QTY
    ,l_kit_rec.packed_qty_disp
    ,l_kit_rec.completed_flag);

        l_kit_oqty := l_kit_rec.ORDER_QTY;

    IF l_debug = 1 THEN
        trace('Inserted kit info for kit_item_id '||l_kit_rec.kit_item_id);
    END IF;
    l_kit_item_id := l_kit_rec.kit_item_id;
    -- Loop to insert component information
    LOOP
        FETCH kit_component_cur INTO
            l_kit_rec.item, l_kit_rec.component_item_id
            , l_kit_rec.order_qty
            ,l_kit_rec.top_model_line_id;
        IF kit_component_cur%NOTFOUND THEN
            IF l_debug = 1 THEN
                trace('No more component info found for top_model_line_id '||p_top_model_line_id);
            END IF;
            CLOSE kit_component_cur;
            EXIT;
        END IF;
        l_kit_rec.kit_item_id := l_kit_item_id;
        IF l_kit_rec.component_item_id = p_component_item_id THEN
           --condiiton "p_packed_qty
           -- is notl NULL" is added so that while inserting mutiple
           -- new kits for the a scanned components, we do not
           -- UPDATE the qty multiple times, we insert NULL qty for
           --ALL component under multiple kit AND THEN UPDATE based
           -- ON packed qty
           IF  p_packed_qty IS NOT NULL THEN
              l_kit_rec.packed_qty := p_packed_qty;
           END IF;
            l_kit_rec.packed_qty_disp := p_disp_packed_qty;
        ELSE
            l_kit_rec.packed_qty := null;
            l_kit_rec.packed_qty_disp := null;
        END IF;
        l_kit_rec.completed_flag := 'N';


        INSERT INTO wms_packing_kitting_gtemp
        ( ITEM
        , kit_item_id
        , component_item_id
        , top_model_line_id
        ,  BOM_QTY
        ,  ORDER_QTY
        ,  PACKED_QTY
        , packed_qty_disp
        , completed_flag) VALUES
        (l_kit_rec.item
        ,l_kit_rec.kit_item_id
        ,l_kit_rec.component_item_id
        ,l_kit_rec.top_model_line_id
        ,(l_kit_rec.order_qty/l_kit_oqty) -- Cmp BOM = Cmp_Order_Qty/Kit_Order_Qty
        ,l_kit_rec.ORDER_QTY
        ,l_kit_rec.PACKED_QTY
        ,l_kit_rec.packed_qty_disp
        ,l_kit_rec.completed_flag);

        IF l_debug = 1 THEN
            trace('Inserted component info for component_item_id '||l_kit_rec.component_item_id);
        END IF;
    END LOOP;
END insert_kit_info;

FUNCTION get_kit_component_list
  (p_kit_item_id IN NUMBER
   ,p_top_model_line_id IN NUMBER
   ,p_exclude_item_id IN NUMBER) RETURN kit_component_tbl_type IS

   CURSOR component_cur IS
        SELECT kit_item_id
        ,component_item_id
        ,packed_qty
        ,packed_qty_disp
        FROM wms_packing_kitting_gtemp
        WHERE kit_item_id = p_kit_item_id
        AND top_model_line_id = p_top_model_line_id
        AND component_item_id IS NOT NULL
        AND component_item_id <> p_exclude_item_id;

    l_comp_rec kit_component_rec_type;
    l_comp_tbl kit_component_tbl_type;
    l_rec_count NUMBER := 0;
BEGIN
    FOR l_comp_rec IN component_cur LOOP
        l_rec_count := l_rec_count + 1;
        l_comp_tbl(l_rec_count) := l_comp_rec;
    END LOOP;
    IF l_debug = 1 THEN
        trace('Got '||l_comp_tbl.count||' component for kit '||p_kit_item_id||' top_model '|| p_top_model_line_id
           || ', exclude_item '|| p_exclude_item_id);
    END IF;
    RETURN l_comp_tbl;
END get_kit_component_list;


/*==========================
  Public Procedure
  =========================*/

/*********************************
Procedure to query the eligible material for pack/split/unpack transactions
For inbound, it queries move order lines
For outbound, it queries delivery detail lines
After it finds results, it populates global temp table
  WMS_PACKING_MATERIAL_GTEMP to display on the spreadtable on packing workbench form

Input Parameter:
p_source_id: 1=>Inbound, 2=>Outbound

The following input parameters applies for both inbound and outbound
p_organization_id: Organization
p_subinventory_code: Subinventory
p_locator_id: ID for Locator
p_inventory_item_id: ID for Item
p_from_lpn_id: ID for From LPN
p_project_id: ID for Project
p_task_id: ID for Task

The following parameters applies for inbound
p_document_type: 'ASN', 'INTSHIP', 'PO', 'REQ', 'RMA'
p_document_id: ID for inbound document
p_document_line_id: ID for inbound document line
p_receipt_number: Receipt number
p_partner_id: it can be vendor_id or internal org_id
p_partner_type: 1=> Vendor, 2=> Internal Organization
p_rcv_location_id: ID for receiving location

The following parameters applies for outbound
p_delivery_id: ID for delivery
p_order_header_id: ID for sales order header
p_carrier_id: ID for carrier
p_trip_id: ID for Trip
p_delivery_state: 'Y'=> Deliveries that are completed packed
                  'N"=> Deliveries that are not completed packed
                  NULL=> all deliveries
p_customer_id: ID for customer
*********************************/

PROCEDURE query_eligible_material(
  x_return_status OUT NOCOPY VARCHAR2
, p_source_id IN NUMBER
, p_organization_id IN NUMBER
, p_organization_code IN VARCHAR2
, p_subinventory_code IN VARCHAR2 DEFAULT NULL
, p_locator_id IN NUMBER DEFAULT NULL
, p_locator IN VARCHAR2 DEFAULT NULL
, p_inventory_item_id IN NUMBER DEFAULT NULL
, p_item IN VARCHAR2 DEFAULT NULL
, p_from_lpn_id IN NUMBER DEFAULT NULL
, p_project_id IN NUMBER DEFAULT NULL
, p_project IN VARCHAR2 DEFAULT NULL
, p_task_id IN NUMBER DEFAULT NULL
, p_task IN VARCHAR2 DEFAULT NULL
, p_document_type IN VARCHAR2 DEFAULT NULL
, p_document_id IN NUMBER DEFAULT NULL
, p_document_number IN VARCHAR2 DEFAULT NULL
, p_document_line_id IN NUMBER DEFAULT NULL
, p_document_line_num IN VARCHAR2 DEFAULT NULL--CLM Changes, Line number to be alphanumeric
, p_receipt_number IN VARCHAR2 DEFAULT NULL
, p_partner_id IN NUMBER DEFAULT NULL
, p_partner_type IN NUMBER DEFAULT NULL
, p_partner_name IN VARCHAR2 DEFAULT NULL
, p_rcv_location_id IN NUMBER DEFAULT NULL
, p_rcv_location IN VARCHAR2 DEFAULT NULL
, p_delivery_id IN NUMBER DEFAULT NULL
, p_delivery IN VARCHAR2 DEFAULT NULL
, p_order_header_id IN NUMBER DEFAULT NULL
, p_order_number IN VARCHAR2 DEFAULT NULL
, p_order_type  IN VARCHAR2 DEFAULT NULL
, p_carrier_id IN NUMBER DEFAULT NULL
, p_carrier IN VARCHAR2 DEFAULT NULL
, p_trip_id IN NUMBER DEFAULT NULL
, p_trip IN VARCHAR2 DEFAULT NULL
, p_delivery_state IN VARCHAR2 DEFAULT NULL
, p_customer_id IN NUMBER DEFAULT NULL
, p_customer IN VARCHAR2 DEFAULT NULL
, p_is_pjm_enabled_org IN VARCHAR2 DEFAULT 'N'
, x_source_unique OUT nocopy VARCHAR2
) IS

    l_return_status VARCHAR2(1);

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    IF p_source_id = 1 THEN
        -- Inbound
        query_inbound_material(
          x_return_status => l_return_status
         ,p_organization_id => p_organization_id
         ,p_organization_code => p_organization_code
         ,p_subinventory_code => p_subinventory_code
         ,p_locator_id => p_locator_id
         ,p_locator => p_locator
         ,p_inventory_item_id => p_inventory_item_id
         ,p_item => p_item
         ,p_from_lpn_id => p_from_lpn_id
         ,p_project_id => p_project_id
         ,p_project => p_project
         ,p_task_id => p_task_id
         ,p_task => p_task
         ,p_document_type => p_document_type
         ,p_document_id => p_document_id
         ,p_document_number => p_document_number
         ,p_document_line_id => p_document_line_id
         ,p_document_line_num => p_document_line_num
         ,p_receipt_number => p_receipt_number
         ,p_partner_id => p_partner_id
         ,p_partner_type => p_partner_type
         ,p_partner_name => p_partner_name
         ,p_rcv_location_id => p_rcv_location_id
    ,p_rcv_location => p_rcv_location
    ,p_is_pjm_enabled_org => p_is_pjm_enabled_org
    ,x_source_unique => x_source_unique );
    ELSIF p_source_id = 2 THEN
        -- Outbound
        query_outbound_material(
          x_return_status => l_return_status
         ,p_organization_id => p_organization_id
         ,p_organization_code => p_organization_code
         ,p_subinventory_code => p_subinventory_code
         ,p_locator_id => p_locator_id
         ,p_locator => p_locator
         ,p_inventory_item_id => p_inventory_item_id
         ,p_item => p_item
         ,p_from_lpn_id => p_from_lpn_id
         ,p_project_id => p_project_id
         ,p_project => p_project
         ,p_task_id => p_task_id
         ,p_task => p_task
         ,p_delivery_id => p_delivery_id
         ,p_delivery => p_delivery
         ,p_order_header_id => p_order_header_id
         ,p_order_number => p_order_number
         ,p_order_type => p_order_type
         ,p_carrier_id => p_carrier_id
         ,p_carrier => p_carrier
         ,p_trip_id => p_trip_id
         ,p_trip => p_trip
         ,p_delivery_state => p_delivery_state
         ,p_customer_id => p_customer_id
         ,p_customer => p_customer);
    END IF;

    x_return_status := l_return_status;

END query_eligible_material;


/*******************************************
 * Procedure to create MMTT/MTLT/MSNT record
 * For a pack/split/unpack transaction
 *******************************************/
PROCEDURE create_txn(
  x_return_status OUT NOCOPY VARCHAR2
, x_proc_msg OUT NOCOPY VARCHAR2
, p_source IN NUMBER
, p_pack_process IN NUMBER
, p_organization_id IN NUMBER
, p_inventory_item_id IN NUMBER
, p_primary_uom IN VARCHAR2
, p_revision IN VARCHAR2
, p_lot_number IN VARCHAR2
, p_lot_expiration_date IN DATE
, p_fm_serial_number IN VARCHAR2
, p_to_serial_number IN VARCHAR2
, p_from_lpn_id IN NUMBER
, p_content_lpn_id IN NUMBER
, p_to_lpn_id IN NUMBER
, p_subinventory_code IN VARCHAR2
, p_locator_id IN NUMBER
, p_to_subinventory IN VARCHAR2
, p_to_locator_id IN NUMBER
, p_project_id IN NUMBER
, p_task_id IN NUMBER
, p_transaction_qty IN NUMBER
, p_transaction_uom IN VARCHAR2
, p_primary_qty IN NUMBER
, p_secondary_qty IN NUMBER
, p_secondary_uom IN VARCHAR2
, p_transaction_header_id IN NUMBER
, p_transaction_temp_id IN NUMBER
, x_transaction_header_id OUT NOCOPY NUMBER
, x_transaction_temp_id OUT NOCOPY NUMBER
, x_serial_transaction_temp_id OUT NOCOPY NUMBER
, p_grade_code IN VARCHAR2 --INVCONV kkillams
) IS

   CURSOR inb_cur IS
      SELECT wpmg.move_order_line_id
   , wpmg.txn_source_id
   , wpmg.project_id
   , wpmg.task_id
   , inv_convert.inv_um_convert(wpmg.inventory_item_id,null,least(mol.quantity,wpmg.quantity), mol.uom_code,p_primary_uom,null,null)
   , least(mol.quantity,wpmg.quantity)
   , mol.uom_code
   --, decode(wpmg.uom, p_transaction_uom, 0, 1) uom_match
   , least(mol.secondary_quantity,wpmg.secondary_quantity)
   , mol.secondary_uom_code  --INVCONV kkillams
   , wpmg.grade_code  --INVCONV kkillams
   , mol.lot_number
   , mol.inspection_status
     FROM wms_packing_material_gtemp wpmg, mtl_txn_request_lines mol
     WHERE wpmg.move_order_line_id = mol.line_id
     AND wpmg.organization_id = p_organization_id
     AND nvl(wpmg.subinventory,'#$%') = nvl(p_subinventory_code, nvl(wpmg.subinventory,'#$%'))
     AND nvl(wpmg.locator_id, -9999) = nvl(p_locator_id, nvl(wpmg.locator_id, -9999))
     AND wpmg.inventory_item_id = p_inventory_item_id
     AND ((p_revision IS NULL) OR
          (p_revision IS NOT NULL and wpmg.revision = p_revision))
     AND ((wpmg.lot_number IS NULL) OR
          (wpmg.lot_number IS NOT NULL and wpmg.lot_number = p_lot_number))
     AND ((p_from_lpn_id IS NULL AND wpmg.lpn_id IS NULL) OR
          (p_from_lpn_id IS NOT NULL and wpmg.lpn_id = p_from_lpn_id))
     AND ((p_project_id = -1 and p_task_id = -1) OR
          (wpmg.project_id IS NULL and p_project_id IS NULL and
           wpmg.task_id IS NULL and p_task_id IS NULL) OR
          (wpmg.project_id = p_project_id AND wpmg.task_id = p_task_id))
     AND ((mol.wms_process_flag = 2 and wpmg.selected_flag='Y') OR
         (mol.wms_process_flag <> 2))
     order by decode(wpmg.uom, p_transaction_uom, 0, 1) asc, mol.creation_date asc;

     --Bug 6028098
     CURSOR get_gtemp IS
	SELECT * FROM wms_packing_material_gtemp
        WHERE inventory_item_id = p_inventory_item_id
        AND nvl(lot_number, '#$%') = nvl(p_lot_number, nvl(lot_number, '#$%'))
        AND nvl(revision, '#') = nvl(p_revision,nvl(revision, '#'))
        AND subinventory = p_subinventory_code
        AND locator_id = p_locator_id
        AND lpn_id = p_from_lpn_id;

    l_sum_qty NUMBER := 0;   --Bug 6028098
    l_process_qty NUMBER := 0;  --Bug 6028098
    l_update_qty NUMBER := 0;  --Bug 6028098

    l_from_sub VARCHAR2(30);
    l_from_loc_id NUMBER;
    l_to_sub VARCHAR2(30);
    l_to_loc_id NUMBER;

    l_txn_action_id NUMBER;
    l_txn_type_id NUMBER;
    l_txn_hdr_id NUMBER;
    l_txn_tmp_id NUMBER;
    l_ser_txn_id NUMBER;

    l_insert NUMBER;
    l_proc_msg VARCHAR2(1000);
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(1000);
    i NUMBER;
    l_new_tolocator_id NUMBER;

    l_mmtt_exists NUMBER;
    l_cur_rec mmtt_mtlt_rec_type;

    l_mol_line_id NUMBER;
    l_mol_uom VARCHAR2(3);
    l_txn_src_id NUMBER;
    l_mol_project_id NUMBER;
    l_mol_task_id NUMBER;
    l_mol_prim_qty NUMBER;
    l_mol_txn_qty NUMBER;
    l_available_qty NUMBER;
    l_mol_sec_qty  NUMBER; --INVCONV kkillams
    l_mol_sec_uom VARCHAR2(3); --INVCONV kkillams
    l_mol_grade_code VARCHAR2(150); --INVCONV kkillams
    l_mol_inspection_status NUMBER;
    l_mol_lot_number VARCHAR2(80);
    l_ser_inspection_status NUMBER;
    l_ser_lot_number VARCHAR2(80);

    l_mol_list move_order_tbl_type;
    l_mol_count NUMBER;

    l_new_lot NUMBER;
    l_new_serial NUMBER;

    l_row_count NUMBER;
        l_current_status NUMBER := 1;

BEGIN
       fnd_msg_pub.Initialize;
    IF l_debug = 1 THEN
        trace('In Create TXN :');
        trace('  p_source='||p_source||', p_pack_process='||p_pack_process);
        trace('  p_organization_id='||p_organization_id);
        trace('  p_inventory_item_id='||p_inventory_item_id);
        trace('  p_primary_uom='||p_primary_uom||', p_revision='||p_revision);
        trace('  p_lot_number='||p_lot_number||', p_lot_expiration_date='||p_lot_expiration_date);
        trace('  p_fm_serial_number='||p_fm_serial_number||', p_to_serial_number='||p_to_serial_number);
        trace('  p_from_lpn_id='||p_from_lpn_id||', p_content_lpn_id='||p_content_lpn_id);
        trace('  p_to_lpn_id='||p_to_lpn_id);
        trace('  p_subinventory_code='||p_subinventory_code||',p_locator_id='||p_locator_id);
        trace('  p_to_subinventory='||p_to_subinventory||',p_to_locator_id='||p_to_locator_id);
        trace('  p_transaction_qty='||p_transaction_qty||',p_transaction_uom='||p_transaction_uom);
        trace('  p_primary_qty='||p_primary_qty);
        trace('  p_secondary_qty='||p_secondary_qty||',p_secondary_uom='||p_secondary_uom);
        trace('  p_transaction_header_id='||p_transaction_header_id||',p_transaction_temp_id='||p_transaction_temp_id);
        trace('  p_project_id='||p_project_id||', p_task_id='||p_task_id);
        trace('  p_grade_code='||p_grade_code);
    END IF;

    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    l_new_tolocator_id := p_to_locator_id;
    -- Here only those records should be present to process for which there is
    -- UNIQUE combination OF projec/task for the item, The restriction
    -- IS made sure in the find window itself

    --find the default locator if there is project/Task
    -- If not then create the new logical locator

    IF (Nvl(p_project_id,-1)<>-1) THEN -- Added for bug 7577646

       IF l_debug = 1 THEN
          trace('Getting/Creating logical locator for the project');
       END IF;

       pjm_project_locator.get_defaultprojectlocator
         ( p_organization_id
           , l_new_tolocator_id
           , p_project_id
           , p_task_id
           , l_new_tolocator_id);

       IF l_debug = 1 THEN
          trace('Existing/New to_locator_id for project='||l_new_tolocator_id);
       END IF;

    END IF;


    IF p_source =1 THEN
        --Inbound
        IF l_debug = 1 THEN
            trace('Create txn record for Inbound');
        END IF;
        -- If exists pening MMTT, get previous MMTT information
        l_mmtt_exists := 0;
        IF p_transaction_header_id IS NOT NULL and p_transaction_temp_id IS NOT NULL THEN
            l_cur_rec := l_null_rec;
            BEGIN
                SELECT 1, mmtt.move_order_line_id, mmtt.inventory_item_id, mmtt.revision
                , mmtt.transaction_quantity, mmtt.transaction_uom, mtlt.lot_number, mtlt.serial_transaction_temp_id
                , mmtt.secondary_transaction_quantity, mmtt.secondary_uom_code  --INVCONV kkillams
                INTO l_mmtt_exists, l_cur_rec.move_order_line_id, l_cur_rec.inventory_item_id
                , l_cur_rec.revision, l_cur_rec.transaction_quantity, l_cur_rec.transaction_uom
                , l_cur_rec.lot_number, l_cur_rec.serial_transaction_temp_id
                , l_cur_rec.secondary_transaction_quantity, l_cur_rec.secondary_uom_code  --INVCONV kkillams
                FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
                WHERE mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
                AND mmtt.transaction_header_id = p_transaction_header_id
                AND mmtt.transaction_temp_id = p_transaction_temp_id
                AND mmtt.inventory_item_id <> -1
                AND mmtt.content_lpn_id IS NULL;
            EXCEPTION
                WHEN no_data_found THEN
                    l_mmtt_exists:=0;
            END;
        END IF;

        IF l_debug = 1 THEN
            trace('l_mmtt_exists='||l_mmtt_exists);
        END IF;

        IF p_pack_process = 1 THEN
            l_txn_action_id := 50;
            l_txn_type_id := 87; -- Container pack
        ELSIF p_pack_process = 2 THEN
            l_txn_action_id := 52;
            l_txn_type_id := 89;  -- Container split
        ELSIF p_pack_process = 3 THEN
            l_txn_action_id := 51;
            l_txn_type_id := 88;  -- Container Unpack
        ELSE
            fnd_message.set_name('INV','INV_INT_TRXACTCODE');
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
        END IF;

        IF l_debug = 1 THEN
            trace('trx action='||l_txn_action_id||',trx type='||l_txn_type_id);
        END IF;

        IF p_content_lpn_id IS NOT NULL THEN
            -- Content is LPN, create new set of transactions and commit


           -- If there is existing MMTT for loose item, submit the transactions
           IF l_mmtt_exists = 1 THEN
              SAVEPOINT BEFORE_TM;
              IF l_debug = 1 THEN
             trace('Set savepoint BEFORE_TM, Calling rcv TM for previous MMTT txns, header_id='||p_transaction_header_id);
              END IF;
              WMS_RCV_PUP_PVT.pack_unpack_split
            ( p_header_id          => p_transaction_header_id
              ,x_return_status      => l_return_status
              ,x_msg_count          => l_msg_count
              ,x_msg_data           => l_msg_data
              );
           END IF;
           IF l_return_status <> 'S' THEN
                IF l_debug = 1 THEN
                    trace('Error in process transaction for hdr_id='||p_transaction_header_id||',l_msg_data='||l_msg_data);
                END IF;
                raise fnd_api.g_exc_error;
            ELSE
                IF l_debug = 1 THEN
                    trace('transaction processed successfully, hdr_id ='||p_transaction_header_id);
                END IF;
            END IF;

            IF l_debug = 1 THEN
                trace('Creating MMTT for Content LPN ID '||p_content_lpn_id);
            END IF;
            l_insert := inv_trx_util_pub.insert_line_trx(
              p_trx_hdr_id => null
             ,p_item_id => null
             ,p_org_id => p_organization_id
             ,p_trx_action_id => l_txn_action_id
             ,p_trx_type_id => l_txn_type_id
             ,p_trx_src_type_id => 13
             ,p_trx_qty => 0
             ,p_pri_qty => 0
             ,p_uom => nvl(p_transaction_uom, ' ')
             ,p_subinv_code => p_subinventory_code
             ,p_tosubinv_code => p_to_subinventory
             ,p_locator_id => p_locator_id
             ,p_tolocator_id => l_new_tolocator_id
             ,p_from_lpn_id => p_from_lpn_id
             ,p_cnt_lpn_id => p_content_lpn_id
             ,p_xfr_lpn_id => p_to_lpn_id
             ,p_posting_flag => 'N' -- Set this so that locator capacity calculation will not consider this
             ,p_move_order_line_id => null
             ,p_process_flag => 'N' -- Set process_flag to 'N' so that INV TM will not process this MMTT
             ,p_user_id => fnd_global.user_id
             ,x_trx_tmp_id => l_txn_tmp_id
             ,x_proc_msg => l_proc_msg
             ,p_secondary_trx_qty => CASE WHEN p_secondary_uom IS NOT NULL THEN 0 ELSE NULL END  --INVCONV kkillams
             ,p_secondary_uom     => nvl(p_secondary_uom, ' ')  --INVCONV kkillams
             );
            IF l_debug = 1 THEN
                trace('done with inserting , l_insert ='||l_insert);
            END IF;
            IF l_insert <> 0 THEN
                IF l_debug = 1 THEN
                    trace('Error when inserting MMTT for content lpn ID '|| p_content_lpn_id|| 'err is '||l_proc_msg);
                END IF;
                x_proc_msg := l_proc_msg;
                raise fnd_api.g_exc_error;
            END IF;

            IF l_debug = 1 THEN
                trace('MMTT inserted, tmp_id='||l_txn_tmp_id);
            END IF;
            l_txn_hdr_id := l_txn_tmp_id;

            SAVEPOINT BEFORE_TM;
            IF l_debug = 1 THEN
                trace('Set savepoint BEFORE_TM, Calling API to process the transaction');
            END IF;
            WMS_RCV_PUP_PVT.pack_unpack_split
              (p_transaction_temp_id => l_txn_tmp_id
               ,p_header_id          => l_txn_hdr_id
               ,x_return_status      => l_return_status
               ,x_msg_count          => l_msg_count
               ,x_msg_data           => l_msg_data
               );

            IF l_return_status <> 'S' THEN
                IF l_debug = 1 THEN
                    trace('Error in process transaction for hdr_id='||l_txn_hdr_id||',tmp_id='||l_txn_tmp_id ||',l_msg_data='||l_msg_data);
                END IF;
                raise fnd_api.g_exc_error;
            ELSE
                IF l_debug = 1 THEN
                    trace('transaction processed successfully, txn_temp_id ='||l_txn_tmp_id);
                END IF;
                x_return_status := 'S';
                x_transaction_header_id := l_txn_hdr_id;
                x_transaction_temp_id := l_txn_tmp_id;
                x_serial_transaction_temp_id := null;

                -- Delete record from eligible material temp table
                delete from wms_packing_material_gtemp where outermost_lpn_id = p_content_lpn_id;
                --commit;
            END IF;

        ELSIF p_inventory_item_id IS NOT NULL THEN
            -- Content is item

            -- If there are previous transactions for different item,
            -- submit the previous txns
            IF l_debug = 1 THEN
                trace('Content is item,mmtt_exists='||l_mmtt_exists||',cur_rec.item='||l_cur_rec.inventory_item_id);
            END IF;


            IF l_mmtt_exists = 1 AND l_cur_rec.inventory_item_id <> p_inventory_item_id THEN
                SAVEPOINT BEFORE_TM;
                IF l_debug = 1 THEN
                    trace('Set savepoint BEFORE_TM, Calling WMS_RCV_PUP_PVT.pack_unpack_split API for p_transaction_header_id='||p_transaction_header_id);
                END IF;
                WMS_RCV_PUP_PVT.pack_unpack_split
                  ( p_header_id          => p_transaction_header_id
                   ,x_return_status      => l_return_status
                   ,x_msg_count          => l_msg_count
                   ,x_msg_data           => l_msg_data
                   );

                IF l_return_status <> 'S' THEN
                    IF l_debug = 1 THEN
                        trace('Error in process transaction for hdr_id='||p_transaction_header_id||',l_msg_data='||l_msg_data);
                    END IF;
                    raise fnd_api.g_exc_error;
                ELSE
                    IF l_debug = 1 THEN
                        trace('transaction processed successfully, hdr_id='||p_transaction_header_id);
                    END IF;
                    l_mmtt_exists := 0;
                END IF;
            END IF;

            -- Get the list of move order line IDs that will satify the transaction quantity
            l_mol_list.delete;
            l_available_qty := 0;
            l_mol_count := 0;

            begin
               select current_status
       ,   lot_number
       ,   inspection_status
       INTO l_current_status
       ,    l_ser_lot_number
       ,    l_ser_inspection_status
               from mtl_serial_numbers a
               where serial_number = p_fm_serial_number
               and current_organization_id = p_organization_id
               and inventory_item_id = p_inventory_item_id
               and rownum<2;

            exception
               when no_data_found then
                    l_current_status := 1;
                    l_ser_lot_number := NULL;
                    l_ser_inspection_status := NULL;
               when others then
                    null;
            end;

       trace('ser_num:'||p_fm_serial_number||
        ' lot_num:'||l_ser_lot_number||
        ' inspect_status:'||l_ser_inspection_status);

            OPEN inb_cur;
            FETCH inb_cur
         INTO l_mol_line_id
         , l_txn_src_id
         , l_mol_project_id
         , l_mol_task_id
         , l_mol_prim_qty
         , l_mol_txn_qty
         , l_mol_uom
         , l_mol_sec_qty
         , l_mol_sec_uom
         , l_mol_grade_code  --INVCONV kkillams
         , l_mol_lot_number
         , l_mol_inspection_status;
       IF inb_cur%NOTFOUND THEN
                fnd_message.set_name('WMS','WMS_NO_ELIGIBLE_MATERIAL');
                fnd_msg_pub.add;
                raise fnd_api.g_exc_error;
            END IF;

            LOOP
                IF inb_cur%NOTFOUND THEN
                    CLOSE inb_cur;
                    EXIT;
                END IF;
                IF l_debug =1 THEN
                    trace('in mol loop, l_mol_line_id='||l_mol_line_id||',l_txn_src_id='||l_txn_src_id);
                END IF;
                IF p_fm_serial_number IS NULL THEN
                    l_available_qty := l_available_qty + l_mol_prim_qty;
                ELSE
         --R12
         IF (l_current_status = 1 OR
             (Nvl(l_mol_lot_number,'@@@') = Nvl(l_ser_lot_number,'@@@') AND
         Nvl(l_mol_inspection_status,-1) = Nvl(l_ser_inspection_status,-1))) THEN
            l_available_qty := l_available_qty + l_mol_prim_qty;
          ELSE
            l_available_qty := 0;
         END IF;
      END IF;

                IF l_debug = 1 THEN
                    trace('l_available_qty='||l_available_qty||',p_primary_qty='||p_primary_qty);
                    trace('l_mol_txn_qty='||l_mol_txn_qty||',l_mol_prim_qty='||l_mol_prim_qty);
                END IF;
                IF l_available_qty > 0 THEN
                    l_mol_count := l_mol_count + 1;
                    l_mol_list(l_mol_count).move_order_line_id := l_mol_line_id;
                    l_mol_list(l_mol_count).transaction_uom := l_mol_uom;
                    l_mol_list(l_mol_count).secondary_uom_code := l_mol_sec_uom;  --INCONV kkillams
                    l_mol_list(l_mol_count).grade_code := l_mol_grade_code;  --INCONV kkillams
                    IF l_available_qty < p_primary_qty THEN
                        -- this move order line will be used for the transaction
                        -- The quantity is the quantity on the move order line
                        l_mol_list(l_mol_count).transaction_quantity := l_mol_txn_qty;
                        l_mol_list(l_mol_count).primary_quantity := l_mol_prim_qty;
                        l_mol_list(l_mol_count).secondary_transaction_quantity := l_mol_sec_qty;  --INCONV kkillams
                    ELSIF l_available_qty >= p_primary_qty THEN
                        -- Last move order line needed for the transaction
                        -- the quantity may be partial of the quantity on the move order line
                        -- which is the mol.qty less the extra qty between the available qty and p_primary_qty
                        l_mol_list(l_mol_count).primary_quantity := l_mol_prim_qty - (l_available_qty-p_primary_qty);
                        l_mol_list(l_mol_count).transaction_quantity :=
                          inv_convert.inv_um_convert(p_inventory_item_id,null,l_mol_list(l_mol_count).primary_quantity,p_primary_uom,l_mol_uom,null,null);
                        l_mol_list(l_mol_count).SECONDARY_TRANSACTION_QUANTITY :=
                          inv_convert.inv_um_convert(p_inventory_item_id,null,l_mol_list(l_mol_count).primary_quantity,p_primary_uom,l_mol_sec_uom,null,null);--INCONV kkillams
                        CLOSE inb_cur;
                        EXIT;
                    END IF;
                    IF l_debug = 1 THEN
                        trace('txn_qty='||l_mol_list(l_mol_count).transaction_quantity ||',prim_qty='||l_mol_list(l_mol_count).primary_quantity);
                    END IF;
                END IF;


                FETCH inb_cur
        INTO l_mol_line_id, l_txn_src_id, l_mol_project_id, l_mol_task_id,
        l_mol_prim_qty, l_mol_txn_qty, l_mol_uom
        , l_mol_sec_qty, l_mol_sec_uom , l_mol_grade_code
        , l_mol_lot_number, l_mol_inspection_status;  --INVCONV kkillams
            END LOOP;
            IF l_available_qty < p_primary_qty THEN
                l_mol_list := l_null_mol_list;
                fnd_message.set_name('WMS','WMS_NO_ELIGIBLE_MATERIAL');
                fnd_msg_pub.add;
                raise fnd_api.g_exc_error;
            END IF;
            IF l_debug = 1 THEN
                trace('Found move order lines to fulfill transactions, number of records:'||l_mol_list.count);
            END IF;
            -- Create/Upadate MMTT for each move order line
            l_txn_hdr_id := p_transaction_header_id;
            FOR i IN 1..l_mol_list.count LOOP
                -- When no mmtt exists, or item changes
                IF l_debug = 1 THEN
                    trace('l_cur_rec.move_order_line_id='||l_cur_rec.move_order_line_id);
                END IF;
                IF l_mmtt_exists = 0 OR NOT (
                    l_mol_list(i).move_order_line_id = l_cur_rec.move_order_line_id AND
                    p_inventory_item_id = l_cur_rec.inventory_item_id AND
                    p_transaction_uom = l_cur_rec.transaction_uom AND
                    nvl(p_revision, '#$%') = nvl(l_cur_rec.revision, '#$%') AND
                    nvl(p_lot_number, '#$%') = nvl(l_cur_rec.lot_number, '#$%')) THEN

                    IF l_debug = 1 THEN
                        trace('Calling inv_trx_util_pub.insert_line_trx() to insert MMTT with ');
                        trace(' p_trx_hdr_id => '||l_txn_hdr_id);
                        trace(' p_item_id => '||p_inventory_item_id);
                        trace(' p_revision => '||p_revision);
                        trace(' p_org_id => '||p_organization_id);
                        trace(' p_trx_action_id => '||l_txn_action_id);
                        trace(' p_trx_type_id => '||l_txn_type_id);
                        trace(' p_trx_src_type_id => 13');
                        trace(' p_trx_qty => '||l_mol_list(i).transaction_quantity);
                        trace(' p_pri_qty => '||l_mol_list(i).primary_quantity);
                        trace(' p_uom => '||l_mol_list(i).transaction_uom);
                        trace(' p_subinv_code => '||p_subinventory_code);
                        trace(' p_tosubinv_code => '||p_to_subinventory);
                        trace(' p_locator_id => '||p_locator_id);
                        trace(' p_tolocator_id => '||l_new_tolocator_id);
                        trace(' p_from_lpn_id => '||p_from_lpn_id);
                        trace(' p_xfr_lpn_id => '||p_to_lpn_id);
                        trace(' p_posting_flag => N');
                        trace(' p_move_order_line_id => '||l_mol_list(i).move_order_line_id);
                        trace(' p_user_id => '||fnd_global.user_id);
                        trace(' p_secondary_trx_qty => '||l_mol_list(i).secondary_transaction_quantity);
                        trace(' p_secondary_uom => '||l_mol_list(i).secondary_uom_code);
                    END IF;
                    -- Create new MMTT
                    l_insert := inv_trx_util_pub.insert_line_trx(
                      p_trx_hdr_id => l_txn_hdr_id
                     ,p_item_id => p_inventory_item_id
                     ,p_revision => p_revision
                     ,p_org_id => p_organization_id
                     ,p_trx_action_id => l_txn_action_id
                     ,p_trx_type_id => l_txn_type_id
                     ,p_trx_src_type_id => 13
                     ,p_trx_qty => l_mol_list(i).transaction_quantity
                     ,p_pri_qty => l_mol_list(i).primary_quantity
                     ,p_uom => l_mol_list(i).transaction_uom
                     ,p_secondary_trx_qty => l_mol_list(i).secondary_transaction_quantity  --INVCONV kkillams
                     ,p_secondary_uom => l_mol_list(i).secondary_uom_code  --INVCONV kkillams
                     ,p_subinv_code => p_subinventory_code
                     ,p_tosubinv_code => p_to_subinventory
                     ,p_locator_id => p_locator_id
                     ,p_tolocator_id => l_new_tolocator_id --p_to_locator_id
                     ,p_from_lpn_id => p_from_lpn_id
                     ,p_xfr_lpn_id => p_to_lpn_id
                     ,p_posting_flag => 'N' -- Set this so that locator capacity calculation will not consider this
                     ,p_process_flag => 'N' -- Set process_flag to 'N' so that INV TM will not process this MMTT record
                     ,p_move_order_line_id => l_mol_list(i).move_order_line_id
                     ,p_user_id => fnd_global.user_id
                     ,x_trx_tmp_id => l_txn_tmp_id
                     ,x_proc_msg => l_proc_msg
                     );

                    IF l_debug = 1 THEN
                        trace('done with inserting , l_insert ='||l_insert||',mol='||l_mol_list(i).move_order_line_id);
                    END IF;
                    IF l_insert <> 0 THEN
                        IF l_debug = 1 THEN
                            trace('Error when inserting MMTT for move order line id:'||l_mol_list(i).move_order_line_id || 'err is '||l_proc_msg);
                        END IF;
                        x_proc_msg := l_proc_msg;
                        raise fnd_api.g_exc_error;
                    END IF;

                    IF l_txn_hdr_id IS NULL THEN
                        l_txn_hdr_id := l_txn_tmp_id;
                    END IF;
                    IF l_debug = 1 THEN
                        trace('MMTT inserted, tmp_id='||l_txn_tmp_id||', hdr_id='||l_txn_hdr_id);
                    END IF;

                    IF p_lot_number IS NOT NULL THEN
                        -- Create MTLT
                        -- Check to see whether it's a new lot
                        -- Get default attribute if it is a new lot
                        l_new_lot := 0;
                        BEGIN
                            SELECT 1 INTO l_new_lot
                            FROM mtl_lot_numbers
                            WHERE organization_id = p_organization_id
                            AND inventory_item_id = p_inventory_item_id
                            AND lot_number = p_lot_number;
                        EXCEPTION
                            WHEN no_data_found THEN
                                l_new_lot := 0;
                                IF l_debug = 1 THEN
                                    trace('It is a new lot number');
                                END IF;
                        END;

                        IF l_new_lot = 0 THEN
                            -- Get default lot attributes
                            g_lot_ser_attr.delete;
                            get_lot_ser_default_attribute(
                                p_organization_id => p_organization_id
                            ,   p_inventory_item_id => p_inventory_item_id
                            ,   p_lot_serial => p_lot_number
                            ,   p_lot_or_serial => 'LOT');
                            IF l_debug = 1 THEN
                                trace('Got lot default attr, no.of rec '||g_lot_ser_attr.count);
                            END IF;
                        END IF;
                        -- Insert MTLT record

                        IF g_lot_ser_attr.count = 0 THEN
                            -- No lot attribute
                            IF l_debug = 1 THEN
                                trace('Calling insert_lot_trx with ');
                                trace(' p_trx_tmp_id => '||l_txn_tmp_id);
                                trace(' p_lot_number => '||p_lot_number);
                                trace(' p_exp_date => '|| p_lot_expiration_date);
                                trace(' p_trx_qty => '|| l_mol_list(i).transaction_quantity);
                                trace(' p_pri_qty => '||l_mol_list(i).primary_quantity);
                                trace(' No lot attributes are passed in');
                            END IF;
                            l_insert := inv_trx_util_pub.insert_lot_trx(
                              p_trx_tmp_id => l_txn_tmp_id
                            , p_user_id => fnd_global.user_id
                            , p_lot_number => p_lot_number
                            , p_exp_date => p_lot_expiration_date
                            , p_trx_qty => l_mol_list(i).transaction_quantity
                            , p_pri_qty => l_mol_list(i).primary_quantity
                            , p_secondary_qty => l_mol_list(i).secondary_transaction_quantity  --INVCONV kkillams
                            , p_grade_code    => p_grade_code  --INVCONV kkillams
                            , x_ser_trx_id => l_ser_txn_id
                            , x_proc_msg => l_proc_msg
                            );
                            IF l_insert <> 0 THEN
                                IF l_debug = 1 THEN
                                    trace('Error when inserting MTLT for lot:'||p_lot_number||',l_proc_msg='||l_proc_msg);
                                END IF;
                                x_proc_msg := l_proc_msg;
                                raise fnd_api.g_exc_error;
                            END IF;
                            IF l_debug = 1 THEN
                                trace('MTLT record inserted for lot(no attr):'||p_lot_number||',ser_txn_id='||l_ser_txn_id);
                            END IF;
                        ELSE
                            -- With lot attribute
                            IF l_debug = 1 THEN
                                trace('Calling insert_lot_trx with ');
                                trace(' p_trx_tmp_id => '||l_txn_tmp_id);
                                trace(' p_lot_number => '||p_lot_number);
                                trace(' p_exp_date => '|| p_lot_expiration_date);
                                trace(' p_trx_qty => '|| l_mol_list(i).transaction_quantity);
                                trace(' p_pri_qty => '||l_mol_list(i).primary_quantity);
                                trace(' Lot attributes are passed in');
                            END IF;
                            l_insert := inv_trx_util_pub.insert_lot_trx(
                              p_trx_tmp_id => l_txn_tmp_id
                            , p_user_id => fnd_global.user_id
                            , p_lot_number => p_lot_number
                            , p_exp_date => p_lot_expiration_date
                            , p_trx_qty => l_mol_list(i).transaction_quantity
                            , p_pri_qty => l_mol_list(i).primary_quantity
                            , p_secondary_qty => l_mol_list(i).secondary_transaction_quantity  --INVCONV kkillams
                            , p_grade_code    => l_mol_list(i).grade_code  --INVCONV kkillams
                            , x_ser_trx_id => l_ser_txn_id
                            , x_proc_msg => l_proc_msg
                            , p_age =>to_number(get_column_default_value('AGE'))
                            , p_best_by_date  =>to_date(get_column_default_value('BEST_BY_DATE'),G_DATE_MASK)
                            , p_change_date   =>to_date(get_column_default_value('CHANGE_DATE'),G_DATE_MASK)
                            , p_color               =>get_column_default_value('COLOR')
                            , p_curl_wrinkle_fold   =>get_column_default_value('CURL_WRINKLE_FOLD')
                            , p_date_code           =>get_column_default_value('DATE_CODE')
                            , p_description         =>get_column_default_value('DESCRIPTION')
                            , p_item_size =>to_number(get_column_default_value('ITEM_SIZE'))
                            , p_length    =>to_number(get_column_default_value('LENGTH'))
                            , p_length_uom          =>get_column_default_value('LENGTH_UOM')
                            , p_maturity_date   =>to_date(get_column_default_value('MATURITY_DATE'),G_DATE_MASK)
                            , p_origination_date  =>to_date(get_column_default_value('ORIGINATION_DATE'),G_DATE_MASK)
                            , p_place_of_origin      =>get_column_default_value('PLACE_OF_ORIGIN')
                            , p_recycled_content =>to_number(get_column_default_value('RECYCLED_CONTENT'))
                            , p_retest_date      =>to_date(get_column_default_value('RETEST_DATE'),G_DATE_MASK)
                            , p_supplier_lot_number =>get_column_default_value('SUPPLIER_LOT_NUMBER')
                            , p_territory_code      =>get_column_default_value('TERRITORY_CODE')
                            , p_thickness     =>to_number(get_column_default_value('THICKNESS'))
                            , p_thickness_uom       =>get_column_default_value('THICKNESS_UOM')
                            , p_vendor_id           =>get_column_default_value('VENDOR_ID')
                            , p_volume  =>to_number(get_column_default_value('VOLUME'))
                            , p_volume_uom          =>get_column_default_value('VOLUME_UOM')
                            , p_width   =>to_number(get_column_default_value('WIDTH'))
                            , p_width_uom   =>to_number(get_column_default_value('WIDTH_UOM'))
                            , p_lot_attribute_category=>get_column_default_value('LOT_ATTRIBUTE_CATEGORY')
                            , p_c_attribute1          =>get_column_default_value('C_ATTRIBUTE1')
                            , p_c_attribute2          =>get_column_default_value('C_ATTRIBUTE2')
                            , p_c_attribute3          =>get_column_default_value('C_ATTRIBUTE3')
                            , p_c_attribute4          =>get_column_default_value('C_ATTRIBUTE4')
                            , p_c_attribute5          =>get_column_default_value('C_ATTRIBUTE5')
                            , p_c_attribute6          =>get_column_default_value('C_ATTRIBUTE6')
                            , p_c_attribute7          =>get_column_default_value('C_ATTRIBUTE7')
                            , p_c_attribute8          =>get_column_default_value('C_ATTRIBUTE8')
                            , p_c_attribute9          =>get_column_default_value('C_ATTRIBUTE9')
                            , p_c_attribute10         =>get_column_default_value('C_ATTRIBUTE10')
                            , p_c_attribute11         =>get_column_default_value('C_ATTRIBUTE11')
                            , p_c_attribute12         =>get_column_default_value('C_ATTRIBUTE12')
                            , p_c_attribute13         =>get_column_default_value('C_ATTRIBUTE13')
                            , p_c_attribute14         =>get_column_default_value('C_ATTRIBUTE14')
                            , p_c_attribute15         =>get_column_default_value('C_ATTRIBUTE15')
                            , p_c_attribute16         =>get_column_default_value('C_ATTRIBUTE16')
                            , p_c_attribute17         =>get_column_default_value('C_ATTRIBUTE17')
                            , p_c_attribute18         =>get_column_default_value('C_ATTRIBUTE18')
                            , p_c_attribute19         =>get_column_default_value('C_ATTRIBUTE19')
                            , p_c_attribute20         =>get_column_default_value('C_ATTRIBUTE20')
                            , p_d_attribute1  =>to_date(get_column_default_value('D_ATTRIBUTE1'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute2  =>to_date(get_column_default_value('D_ATTRIBUTE2'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute3  =>to_date(get_column_default_value('D_ATTRIBUTE3'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute4  =>to_date(get_column_default_value('D_ATTRIBUTE4'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute5  =>to_date(get_column_default_value('D_ATTRIBUTE5'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute6  =>to_date(get_column_default_value('D_ATTRIBUTE6'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute7  =>to_date(get_column_default_value('D_ATTRIBUTE7'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute8  =>to_date(get_column_default_value('D_ATTRIBUTE8'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute9  =>to_date(get_column_default_value('D_ATTRIBUTE9'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute10 =>to_date(get_column_default_value('D_ATTRIBUTE10'),G_DATE_MASK)
                            , p_n_attribute1  =>to_number(get_column_default_value('N_ATTRIBUTE1'))
                            , p_n_attribute2  =>to_number(get_column_default_value('N_ATTRIBUTE2'))
                            , p_n_attribute3  =>to_number(get_column_default_value('N_ATTRIBUTE3'))
                            , p_n_attribute4  =>to_number(get_column_default_value('N_ATTRIBUTE4'))
                            , p_n_attribute5  =>to_number(get_column_default_value('N_ATTRIBUTE5'))
                            , p_n_attribute6  =>to_number(get_column_default_value('N_ATTRIBUTE6'))
                            , p_n_attribute7  =>to_number(get_column_default_value('N_ATTRIBUTE7'))
                            , p_n_attribute8  =>to_number(get_column_default_value('N_ATTRIBUTE8'))
                            , p_n_attribute9  =>to_number(get_column_default_value('N_ATTRIBUTE9'))
                            , p_n_attribute10 =>to_number(get_column_default_value('N_ATTRIBUTE10'))
                            );
                            IF l_insert <> 0 THEN
                                IF l_debug = 1 THEN
                                    trace('Error when inserting MTLT for lot:'||p_lot_number||',l_proc_msg='||l_proc_msg);
                                END IF;
                                x_proc_msg := l_proc_msg;
                                raise fnd_api.g_exc_error;
                            END IF;
                            IF l_debug = 1 THEN
                                trace('MTLT record inserted for lot(with attr):'||p_lot_number||',ser_txn_id='||l_ser_txn_id);
                            END IF;
                        END IF;


                    END IF;

                    IF p_fm_serial_number IS NOT NULL THEN
                        -- Create MSNT
                        -- Check to see whether it's a new serial
                        -- Get default attribute if it is a new serial
                        l_new_serial := 0;
                        BEGIN
                            SELECT 1 INTO l_new_serial
                            FROM mtl_serial_numbers
                            WHERE current_organization_id = p_organization_id
                            AND inventory_item_id = p_inventory_item_id
                            AND nvl(lot_number, '#$%') = nvl(p_lot_number, nvl(lot_number, '#$%'))
                            AND serial_number = p_fm_serial_number;
                        EXCEPTION
                            WHEN no_data_found THEN
                                l_new_serial := 0;
                        END;

                        IF l_new_serial = 0 THEN
                            IF l_debug = 1 THEN
                                trace('New Serial number, get default attributes');
                            END IF;
                            -- Get default serial attributes
                            g_lot_ser_attr.delete;
                            get_lot_ser_default_attribute(
                                p_organization_id => p_organization_id
                            ,   p_inventory_item_id => p_inventory_item_id
                            ,   p_lot_serial => p_fm_serial_number
                            ,   p_lot_or_serial => 'SERIAL');
                            IF l_debug = 1 THEN
                                trace('Got serial default attr, no.of rec '||g_lot_ser_attr.count);
                            END IF;
                        END IF;
                        -- Insert MSNT record
                        IF g_lot_ser_attr.count = 0 THEN
                            -- No serial attributes
                            l_insert := inv_trx_util_pub.insert_ser_trx(
                              p_trx_tmp_id => nvl(l_ser_txn_id,l_txn_tmp_id)
                            , p_user_id => fnd_global.user_id
                            , p_fm_ser_num => p_fm_serial_number
                            , p_to_ser_num => p_fm_serial_number
                            , x_proc_msg => l_proc_msg
                            );
                            IF l_insert <> 0 THEN
                                IF l_debug = 1 THEN
                                    trace('Error when inserting MSNT for serial(no attr):'||p_fm_serial_number||',l_proc_msg='||l_proc_msg);
                                END IF;
                                x_proc_msg := l_proc_msg;
                                raise fnd_api.g_exc_error;
                            END IF;
                            IF l_debug = 1 THEN
                                trace('MSNT record inserted for serial(no attr):'||p_fm_serial_number||',ser_txn_id='||nvl(l_ser_txn_id,l_txn_tmp_id));
                            END IF;
                        ELSE
                            -- Has serial attributes
                            l_insert := inv_trx_util_pub.insert_ser_trx(
                              p_trx_tmp_id => nvl(l_ser_txn_id,l_txn_tmp_id)
                            , p_user_id => fnd_global.user_id
                            , p_fm_ser_num => p_fm_serial_number
                            , p_to_ser_num => p_fm_serial_number
                            , x_proc_msg => l_proc_msg
                            , p_time_since_new       =>to_number(get_column_default_value('TIME_SINCE_NEW'))
                            , p_cycles_since_new     =>to_number(get_column_default_value('CYCLES_SINCE_NEW'))
                            , p_time_since_overhaul  =>to_number(get_column_default_value('TIME_SINCE_OVERHAUL'))
                            , p_cycles_since_overhaul=>to_number(get_column_default_value('CYCLES_SINCE_OVERHAUL'))
                            , p_time_since_repair    =>to_number(get_column_default_value('TIME_SINCE_REPAIR'))
                            , p_cycles_since_repair  =>to_number(get_column_default_value('CYCLES_SINCE_REPAIR'))
                            , p_time_since_visit     =>to_number(get_column_default_value('TIME_SINCE_VISIT'))
                            , p_cycles_since_visit   =>to_number(get_column_default_value('CYCLES_SINCE_VISIT'))
                            , p_time_since_mark      =>to_number(get_column_default_value('TIME_SINCE_MARK'))
                            , p_cycles_since_mark    =>to_number(get_column_default_value('CYCLES_SINCE_MARK'))
                            , p_number_of_repairs    =>to_number(get_column_default_value('NUMBER_OF_REPAIRS'))
                            , p_territory_code       =>to_number(get_column_default_value('TERRITORY_CODE'))
                            , p_orgination_date      =>to_date(get_column_default_value('ORIGINATION_DATE'),G_DATE_MASK)
                            , p_serial_attribute_category =>get_column_default_value('SERIAL_ATTRIBUTE_CATEGORY')
                            , p_c_attribute1    =>get_column_default_value('C_ATTRIBUTE1')
                            , p_c_attribute2    =>get_column_default_value('C_ATTRIBUTE2')
                            , p_c_attribute3    =>get_column_default_value('C_ATTRIBUTE3')
                            , p_c_attribute4    =>get_column_default_value('C_ATTRIBUTE4')
                            , p_c_attribute5    =>get_column_default_value('C_ATTRIBUTE5')
                            , p_c_attribute6    =>get_column_default_value('C_ATTRIBUTE6')
                            , p_c_attribute7    =>get_column_default_value('C_ATTRIBUTE7')
                            , p_c_attribute8    =>get_column_default_value('C_ATTRIBUTE8')
                            , p_c_attribute9    =>get_column_default_value('C_ATTRIBUTE9')
                            , p_c_attribute10   =>get_column_default_value('C_ATTRIBUTE10')
                            , p_c_attribute11   =>get_column_default_value('C_ATTRIBUTE11')
                            , p_c_attribute12   =>get_column_default_value('C_ATTRIBUTE12')
                            , p_c_attribute13   =>get_column_default_value('C_ATTRIBUTE13')
                            , p_c_attribute14   =>get_column_default_value('C_ATTRIBUTE14')
                            , p_c_attribute15   =>get_column_default_value('C_ATTRIBUTE15')
                            , p_c_attribute16   =>get_column_default_value('C_ATTRIBUTE16')
                            , p_c_attribute17   =>get_column_default_value('C_ATTRIBUTE17')
                            , p_c_attribute18   =>get_column_default_value('C_ATTRIBUTE18')
                            , p_c_attribute19   =>get_column_default_value('C_ATTRIBUTE19')
                            , p_c_attribute20   =>get_column_default_value('C_ATTRIBUTE20')
                            , p_d_attribute1    =>to_date(get_column_default_value('D_ATTRIBUTE1'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute2    =>to_date(get_column_default_value('D_ATTRIBUTE2'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute3    =>to_date(get_column_default_value('D_ATTRIBUTE3'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute4    =>to_date(get_column_default_value('D_ATTRIBUTE4'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute5    =>to_date(get_column_default_value('D_ATTRIBUTE5'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute6    =>to_date(get_column_default_value('D_ATTRIBUTE6'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute7    =>to_date(get_column_default_value('D_ATTRIBUTE7'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute8    =>to_date(get_column_default_value('D_ATTRIBUTE8'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute9    =>to_date(get_column_default_value('D_ATTRIBUTE9'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute10   =>to_date(get_column_default_value('D_ATTRIBUTE10'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_n_attribute1    =>to_number(get_column_default_value('N_ATTRIBUTE1'))
                            , p_n_attribute2    =>to_number(get_column_default_value('N_ATTRIBUTE2'))
                            , p_n_attribute3    =>to_number(get_column_default_value('N_ATTRIBUTE3'))
                            , p_n_attribute4    =>to_number(get_column_default_value('N_ATTRIBUTE4'))
                            , p_n_attribute5    =>to_number(get_column_default_value('N_ATTRIBUTE5'))
                            , p_n_attribute6    =>to_number(get_column_default_value('N_ATTRIBUTE6'))
                            , p_n_attribute7    =>to_number(get_column_default_value('N_ATTRIBUTE7'))
                            , p_n_attribute8    =>to_number(get_column_default_value('N_ATTRIBUTE8'))
                            , p_n_attribute9    =>to_number(get_column_default_value('N_ATTRIBUTE9'))
                            , p_n_attribute10   =>to_number(get_column_default_value('N_ATTRIBUTE10'))
                            );
                            IF l_insert <> 0 THEN
                                IF l_debug = 1 THEN
                                    trace('Error when inserting MSNT for serial:'||p_fm_serial_number||',l_proc_msg='||l_proc_msg);
                                END IF;
                                x_proc_msg := l_proc_msg;
                                raise fnd_api.g_exc_error;
                            END IF;
                            trace('MSNT record inserted for serial(with attr):'||p_fm_serial_number||',ser_txn_id='||nvl(l_ser_txn_id,l_txn_tmp_id));

                        END IF;
                        x_serial_transaction_temp_id := nvl(l_ser_txn_id,l_txn_tmp_id);
                        -- Mark Serial Number
                        BEGIN
                            UPDATE mtl_serial_numbers
                            SET GROUP_MARK_ID = l_txn_tmp_id
                            WHERE current_organization_id = p_organization_id
                            AND inventory_item_id = p_inventory_item_id
                            --AND nvl(lot_number, '#$%') = nvl(p_lot_number, nvl(lot_number, '#$%'))
                            AND serial_number = p_fm_serial_number;
                            IF l_debug = 1 THEN
                                trace(SQL%ROWCOUNT||' records updated for serial number '||p_fm_serial_number||' for group_mark_id as '||l_txn_tmp_id);
                            END IF;
                        EXCEPTION
                            WHEN others THEN
                                IF l_debug = 1 THEN
                                    trace('Error when update MSN with group_mark_id='||l_txn_tmp_id||',SN='||p_fm_serial_number);
                                END IF;
                                raise fnd_api.g_exc_error;
                        END;

                    END IF;
                    -- Mark WMS_PROCESS_FLAG for the move order line
                    BEGIN
                        UPDATE mtl_txn_request_lines
                        SET WMS_PROCESS_FLAG = 2
                        WHERE line_id = l_mol_list(i).move_order_line_id;
                    EXCEPTION
                        WHEN others THEN
                            IF l_debug = 1 THEN
                                trace('Error when updating wms_process_flag for mo line:'||l_mol_list(i).move_order_line_id);
                            END IF;
                            raise fnd_api.g_exc_error;
                    END;

                    x_transaction_header_id := l_txn_hdr_id;
                    x_transaction_temp_id := l_txn_tmp_id;
                ELSE
                    -- Update existing MMTT
                    BEGIN
                        UPDATE mtl_material_transactions_temp
                        SET transaction_quantity = transaction_quantity + l_mol_list(i).transaction_quantity,
                             primary_quantity = primary_quantity + l_mol_list(i).primary_quantity,
                             secondary_transaction_quantity = CASE WHEN l_mol_list(i).secondary_transaction_quantity IS NOT NULL
                                                                   THEN l_mol_list(i).secondary_transaction_quantity + secondary_transaction_quantity
                                                                   ELSE secondary_transaction_quantity
                                                                   END --INVCONV kkillams
                        WHERE transaction_temp_id = p_transaction_temp_id;
                    EXCEPTION
                        WHEN others THEN
                            IF l_debug = 1 THEN
                                trace('Error when updating MMTT rec,tmp_id='||p_transaction_temp_id);
                            END IF;
                            raise fnd_api.g_exc_error;
                    END;
                    IF l_debug = 1 THEN
                        trace('MMTT updated for tmp_id '||p_transaction_temp_id);
                    END IF;

                    -- Update MTLT
                    IF p_lot_number IS NOT NULL THEN
                        BEGIN
                            UPDATE mtl_transaction_lots_temp
                            SET transaction_quantity = transaction_quantity + l_mol_list(i).transaction_quantity,
                                 primary_quantity = primary_quantity + l_mol_list(i).primary_quantity,
                                 secondary_quantity = CASE WHEN l_mol_list(i).secondary_transaction_quantity IS NOT NULL
                                                                   THEN l_mol_list(i).secondary_transaction_quantity + secondary_quantity
                                                                   ELSE secondary_quantity
                                                                   END --INVCONV kkillams
                            WHERE transaction_temp_id = p_transaction_temp_id
                            AND lot_number = p_lot_number;
                        EXCEPTION
                            WHEN others THEN
                                IF l_debug = 1 THEN
                                    trace('Error when updating MTLT rec,tmp_id='||p_transaction_temp_id);
                                END IF;
                                raise fnd_api.g_exc_error;
                        END;
                        IF l_debug = 1 THEN
                            trace('MTLT updated for tmp_id '||p_transaction_temp_id);
                        END IF;
                    END IF;

                    -- Create MSNT record
                    IF p_fm_serial_number IS NOT NULL THEN
                        -- Create MSNT
                        -- Check to see whether it's a new serial
                        -- Get default attribute if it is a new serial
                        l_new_serial := 0;
                        BEGIN
                            SELECT 1 INTO l_new_serial
                            FROM mtl_serial_numbers
                            WHERE current_organization_id = p_organization_id
                            AND inventory_item_id = p_inventory_item_id
                            AND nvl(lot_number, '#$%') = nvl(p_lot_number, nvl(lot_number, '#$%'))
                            AND serial_number = p_fm_serial_number;
                        EXCEPTION
                            WHEN no_data_found THEN
                                l_new_serial := 0;
                        END;

                        IF l_new_serial = 0 THEN
                            IF l_debug = 1 THEN
                                trace('New serial number, getting attributes');
                            END IF;

                            -- Get default serial attributes
                            g_lot_ser_attr.delete;
                            get_lot_ser_default_attribute(
                                p_organization_id => p_organization_id
                            ,   p_inventory_item_id => p_inventory_item_id
                            ,   p_lot_serial => p_fm_serial_number
                            ,   p_lot_or_serial => 'SERIAL');
                            IF l_debug = 1 THEN
                                trace('Got serial default attr, no.of rec '||g_lot_ser_attr.count);
                            END IF;
                        END IF;
                        -- Insert MSNT record
                        IF g_lot_ser_attr.count = 0 THEN
                            -- No serial attributes
                            l_insert := inv_trx_util_pub.insert_ser_trx(
                              p_trx_tmp_id => nvl(l_cur_rec.serial_transaction_temp_id, p_transaction_temp_id)
                            , p_user_id => fnd_global.user_id
                            , p_fm_ser_num => p_fm_serial_number
                            , p_to_ser_num => p_fm_serial_number
                            , x_proc_msg => l_proc_msg
                            );
                            IF l_insert <> 0 THEN
                                IF l_debug = 1 THEN
                                    trace('Error when inserting MSNT for serial(no attr):'||p_fm_serial_number||',l_proc_msg='||l_proc_msg);
                                END IF;
                                x_proc_msg := l_proc_msg;
                                raise fnd_api.g_exc_error;
                            END IF;
                            IF l_debug = 1 THEN
                                trace('MSNT record inserted for serial(no attr):'||p_fm_serial_number||',ser_txn_id='||nvl(l_ser_txn_id,l_txn_tmp_id));
                            END IF;
                        ELSE
                            -- Has serial attributes
                            l_insert := inv_trx_util_pub.insert_ser_trx(
                              p_trx_tmp_id => nvl(l_cur_rec.serial_transaction_temp_id, p_transaction_temp_id)
                            , p_user_id => fnd_global.user_id
                            , p_fm_ser_num => p_fm_serial_number
                            , p_to_ser_num => p_fm_serial_number
                            , x_proc_msg => l_proc_msg
                            , p_time_since_new       =>to_number(get_column_default_value('TIME_SINCE_NEW'))
                            , p_cycles_since_new     =>to_number(get_column_default_value('CYCLES_SINCE_NEW'))
                            , p_time_since_overhaul  =>to_number(get_column_default_value('TIME_SINCE_OVERHAUL'))
                            , p_cycles_since_overhaul=>to_number(get_column_default_value('CYCLES_SINCE_OVERHAUL'))
                            , p_time_since_repair    =>to_number(get_column_default_value('TIME_SINCE_REPAIR'))
                            , p_cycles_since_repair  =>to_number(get_column_default_value('CYCLES_SINCE_REPAIR'))
                            , p_time_since_visit     =>to_number(get_column_default_value('TIME_SINCE_VISIT'))
                            , p_cycles_since_visit   =>to_number(get_column_default_value('CYCLES_SINCE_VISIT'))
                            , p_time_since_mark      =>to_number(get_column_default_value('TIME_SINCE_MARK'))
                            , p_cycles_since_mark    =>to_number(get_column_default_value('CYCLES_SINCE_MARK'))
                            , p_number_of_repairs    =>to_number(get_column_default_value('NUMBER_OF_REPAIRS'))
                            , p_territory_code       =>to_number(get_column_default_value('TERRITORY_CODE'))
                            , p_orgination_date      =>to_date(get_column_default_value('ORIGINATION_DATE'),G_DATE_MASK)
                            , p_serial_attribute_category =>get_column_default_value('SERIAL_ATTRIBUTE_CATEGORY')
                            , p_c_attribute1    =>get_column_default_value('C_ATTRIBUTE1')
                            , p_c_attribute2    =>get_column_default_value('C_ATTRIBUTE2')
                            , p_c_attribute3    =>get_column_default_value('C_ATTRIBUTE3')
                            , p_c_attribute4    =>get_column_default_value('C_ATTRIBUTE4')
                            , p_c_attribute5    =>get_column_default_value('C_ATTRIBUTE5')
                            , p_c_attribute6    =>get_column_default_value('C_ATTRIBUTE6')
                            , p_c_attribute7    =>get_column_default_value('C_ATTRIBUTE7')
                            , p_c_attribute8    =>get_column_default_value('C_ATTRIBUTE8')
                            , p_c_attribute9    =>get_column_default_value('C_ATTRIBUTE9')
                            , p_c_attribute10   =>get_column_default_value('C_ATTRIBUTE10')
                            , p_c_attribute11   =>get_column_default_value('C_ATTRIBUTE11')
                            , p_c_attribute12   =>get_column_default_value('C_ATTRIBUTE12')
                            , p_c_attribute13   =>get_column_default_value('C_ATTRIBUTE13')
                            , p_c_attribute14   =>get_column_default_value('C_ATTRIBUTE14')
                            , p_c_attribute15   =>get_column_default_value('C_ATTRIBUTE15')
                            , p_c_attribute16   =>get_column_default_value('C_ATTRIBUTE16')
                            , p_c_attribute17   =>get_column_default_value('C_ATTRIBUTE17')
                            , p_c_attribute18   =>get_column_default_value('C_ATTRIBUTE18')
                            , p_c_attribute19   =>get_column_default_value('C_ATTRIBUTE19')
                            , p_c_attribute20   =>get_column_default_value('C_ATTRIBUTE20')
                            , p_d_attribute1    =>to_date(get_column_default_value('D_ATTRIBUTE1'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute2    =>to_date(get_column_default_value('D_ATTRIBUTE2'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute3    =>to_date(get_column_default_value('D_ATTRIBUTE3'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute4    =>to_date(get_column_default_value('D_ATTRIBUTE4'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute5    =>to_date(get_column_default_value('D_ATTRIBUTE5'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute6    =>to_date(get_column_default_value('D_ATTRIBUTE6'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute7    =>to_date(get_column_default_value('D_ATTRIBUTE7'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute8    =>to_date(get_column_default_value('D_ATTRIBUTE8'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute9    =>to_date(get_column_default_value('D_ATTRIBUTE9'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_d_attribute10   =>to_date(get_column_default_value('D_ATTRIBUTE10'),'YYYY/MM/DD:HH24:MI:SS')
                            , p_n_attribute1    =>to_number(get_column_default_value('N_ATTRIBUTE1'))
                            , p_n_attribute2    =>to_number(get_column_default_value('N_ATTRIBUTE2'))
                            , p_n_attribute3    =>to_number(get_column_default_value('N_ATTRIBUTE3'))
                            , p_n_attribute4    =>to_number(get_column_default_value('N_ATTRIBUTE4'))
                            , p_n_attribute5    =>to_number(get_column_default_value('N_ATTRIBUTE5'))
                            , p_n_attribute6    =>to_number(get_column_default_value('N_ATTRIBUTE6'))
                            , p_n_attribute7    =>to_number(get_column_default_value('N_ATTRIBUTE7'))
                            , p_n_attribute8    =>to_number(get_column_default_value('N_ATTRIBUTE8'))
                            , p_n_attribute9    =>to_number(get_column_default_value('N_ATTRIBUTE9'))
                            , p_n_attribute10   =>to_number(get_column_default_value('N_ATTRIBUTE10'))
                            );
                            IF l_insert <> 0 THEN
                                IF l_debug = 1 THEN
                                    trace('Error when inserting MSNT for serial(with attr):'||p_fm_serial_number||',l_proc_msg='||l_proc_msg);
                                END IF;
                                x_proc_msg := l_proc_msg;
                                raise fnd_api.g_exc_error;
                            END IF;
                            trace('MSNT record inserted for serial(with attr):'||p_fm_serial_number||',ser_txn_id='||nvl(l_ser_txn_id,l_txn_tmp_id));
                        END IF;
/*                      l_insert := inv_trx_util_pub.insert_ser_trx(
                          p_trx_tmp_id => nvl(l_cur_rec.serial_transaction_temp_id, p_transaction_temp_id)
                        , p_user_id => fnd_global.user_id
                        , p_fm_ser_num => p_fm_serial_number
                        , p_to_ser_num => p_fm_serial_number
                        , x_proc_msg => l_proc_msg
                        );
                        IF l_insert <> 0 THEN
                            IF l_debug = 1 THEN
                                trace('Error when inserting MSNT for serial:'||p_fm_serial_number||',l_proc_msg='||l_proc_msg);
                            END IF;
                            x_proc_msg := l_proc_msg;
                            raise fnd_api.g_exc_error;
                        END IF;
                        IF l_debug = 1 THEN
                            trace('MSNT record inserted for serial:'||p_fm_serial_number||',ser_txn_id='||
                                nvl(l_cur_rec.serial_transaction_temp_id, p_transaction_temp_id));
                        END IF;*/
                        x_serial_transaction_temp_id := nvl(l_cur_rec.serial_transaction_temp_id, p_transaction_temp_id);
                        -- Mark Serial Number
                        BEGIN
                            UPDATE mtl_serial_numbers
                            SET GROUP_MARK_ID = p_transaction_temp_id
                            WHERE current_organization_id = p_organization_id
                            AND inventory_item_id = p_inventory_item_id
                            --AND nvl(lot_number, '#$%') = nvl(p_lot_number, nvl(lot_number, '#$%'))
                            AND serial_number = p_fm_serial_number;
                            IF l_debug = 1 THEN
                                trace(SQL%ROWCOUNT||' records updated for serial number '||p_fm_serial_number||' for group_mark_id as '||p_transaction_temp_id);
                            END IF;

                        EXCEPTION
                            WHEN others THEN
                                IF l_debug = 1 THEN
                                    trace('Error when update MSN with group_mark_id='||l_txn_tmp_id||',SN='||p_fm_serial_number);
                                END IF;
                                raise fnd_api.g_exc_error;
                        END;

                    END IF; -- END SN is not null
                    x_transaction_header_id := p_transaction_header_id;
                    x_transaction_temp_id := p_transaction_temp_id;

                END IF; -- End Create new MMTT or update MMTT

                -- Update WMS_PACKING_MATERIAL_GTEMP
                IF l_debug = 1 THEN
                    trace('Updating wpmg to decrease qty '||inv_convert.inv_um_convert(
                          p_inventory_item_id,null,l_mol_list(i).transaction_quantity,l_mol_list(i).transaction_uom,'Ea',null,null));
                END IF;
                BEGIN
                    UPDATE wms_packing_material_gtemp
                    SET selected_flag = 'Y',
                        quantity = quantity - inv_convert.inv_um_convert(
                          inventory_item_id,null,l_mol_list(i).transaction_quantity,l_mol_list(i).transaction_uom,uom,null,null),
                          secondary_quantity = CASE WHEN l_mol_list(i).secondary_transaction_quantity IS NOT NULL
                                                       THEN  secondary_quantity - l_mol_list(i).secondary_transaction_quantity
                                                       ELSE secondary_quantity
                                                       END --INVCONV kkillams
                    WHERE move_order_line_id = l_mol_list(i).move_order_line_id;
                EXCEPTION
                    WHEN others THEN
                        IF l_debug = 1 THEN
                            trace('Error when updating wms_packing_material_gtemp for mol:'||l_mol_list(i).move_order_line_id);
                        END IF;
                        raise fnd_api.g_exc_error;
                END;

            END LOOP; -- Move order lines loop

        ELSE
            IF l_debug = 1 THEN
                trace('Content has to be either lpn or item');
            END IF;
            raise fnd_api.g_exc_error;
        END IF;


    ELSIF p_source = 2 THEN
        --Outbound
        -- Logic to create/update MMTT/MTLT/MSNT is
        -- For vanilla item, already create new MMTT
        -- For rev or lot or serial item, try to update previous MMTT
        --  but always create new MTLT/MSNT

        IF l_debug = 1 THEN
            trace('Create txn record for Outbound');
        END IF;
        -- Check whether MMTT/MTLT exists for the same item/lot
        l_mmtt_exists := 0;
        IF p_transaction_header_id IS NOT NULL and p_transaction_temp_id IS NOT NULL and
           p_revision IS NULL and (p_lot_number IS NOT NULL or p_fm_serial_number IS NOT NULL) THEN
            BEGIN
                SELECT 1
                INTO l_mmtt_exists
                FROM mtl_material_transactions_temp mmtt
                WHERE mmtt.transaction_header_id = p_transaction_header_id
                AND mmtt.transaction_temp_id = p_transaction_temp_id
                AND mmtt.content_lpn_id IS NULL
                AND mmtt.inventory_item_id = p_inventory_item_id
                AND mmtt.transaction_uom = p_transaction_uom
                AND mmtt.lpn_id = p_from_lpn_id
                AND nvl(mmtt.secondary_uom_code, '@#$') = nvl(p_secondary_uom,nvl(mmtt.secondary_uom_code, '@#$'));
            EXCEPTION
                WHEN no_data_found THEN
                    l_mmtt_exists:=0;
            END;
        END IF;

        IF l_debug = 1 THEN
            trace('l_mmtt_exists='||l_mmtt_exists);
        END IF;

        -- For outbound split transaction without move
        -- Transfer Sub/loc should be null
        l_to_sub := p_to_subinventory;
        l_to_loc_id := l_new_tolocator_id; --p_to_locator_id
        IF p_subinventory_code = p_to_subinventory AND
           p_locator_id = l_new_tolocator_id THEN
            -- No move transaction
            IF p_pack_process = 1 THEN
                l_txn_action_id := 50;
                l_txn_type_id := 87;
            ELSIF p_pack_process = 2 THEN
                l_txn_action_id := 52;
                l_txn_type_id := 89;
                l_to_sub := null;
                l_to_loc_id := null;
            ELSIF p_pack_process = 3 THEN
                l_txn_action_id := 51;
                l_txn_type_id := 88;
            ELSE
                fnd_message.set_name('INV','INV_INT_TRXACTCODE');
                fnd_msg_pub.add;
                raise fnd_api.g_exc_error;
            END IF;
        ELSE
            -- There is move happens
            -- Use subinventory transfer
            l_txn_action_id := 2;
            l_txn_type_id := 2;
        END IF;

        IF l_debug = 1 THEN
            trace('trx action='||l_txn_action_id||',trx type='||l_txn_type_id);
        END IF;

        IF p_transaction_header_id IS NULL THEN
            SELECT mtl_material_transactions_s.NEXTVAL
            INTO l_txn_hdr_id
            FROM dual;
        ELSE
            l_txn_hdr_id := p_transaction_header_id;
        END IF;
        x_transaction_header_id := l_txn_hdr_id;

        IF p_content_lpn_id IS NOT NULL THEN
            -- Content is LPN
            -- Create new MMTT
            IF l_debug = 1 THEN
                trace('Calling inv_trx_util_pub.insert_line_trx() to insert MMTT with ');
                trace(' p_trx_hdr_id => '||l_txn_hdr_id);
                trace(' p_item_id => null');
                trace(' p_org_id => '||p_organization_id);
                trace(' p_trx_action_id => '||l_txn_action_id);
                trace(' p_trx_type_id => '||l_txn_type_id);
                trace(' p_trx_src_type_id => 13');
                trace(' p_trx_qty => 0');
                trace(' p_pri_qty => 0');
                trace(' p_uom => '||nvl(p_transaction_uom, ' '));
                trace(' p_subinv_code => '||p_subinventory_code);
                trace(' p_tosubinv_code => '||l_to_sub);
                trace(' p_locator_id => '||p_locator_id);
                trace(' p_tolocator_id => '||l_to_loc_id);
                trace(' p_from_lpn_id => '||p_from_lpn_id);
                trace(' p_cnt_lpn_id => '||p_content_lpn_id);
                trace(' p_xfr_lpn_id => '||p_to_lpn_id);
                trace(' p_user_id => '||fnd_global.user_id);
            END IF;

            l_insert := inv_trx_util_pub.insert_line_trx(
              p_trx_hdr_id => l_txn_hdr_id
             ,p_item_id => null
             ,p_org_id => p_organization_id
             ,p_trx_action_id => l_txn_action_id
             ,p_trx_type_id => l_txn_type_id
             ,p_trx_src_type_id => 13
             ,p_trx_qty => 0
             ,p_pri_qty => 0
             ,p_uom => nvl(p_transaction_uom, ' ')
             ,p_secondary_trx_qty => CASE WHEN p_secondary_uom IS NOT NULL  THEN 0 ELSE NULL END --INVCONV kkillams
             ,p_secondary_uom => nvl(p_secondary_uom, ' ')  --INVCONV kkillams
             ,p_subinv_code => p_subinventory_code
             ,p_tosubinv_code => l_to_sub
             ,p_xfr_org_id => p_organization_id
             ,p_locator_id => p_locator_id
             ,p_tolocator_id => l_to_loc_id
             ,p_from_lpn_id => p_from_lpn_id
             ,p_cnt_lpn_id => p_content_lpn_id
             ,p_xfr_lpn_id => p_to_lpn_id
             ,p_user_id => fnd_global.user_id
             ,x_trx_tmp_id => l_txn_tmp_id
             ,x_proc_msg => l_proc_msg);

            IF l_debug = 1 THEN
                trace('done with inserting , l_insert ='||l_insert);
            END IF;
            IF l_insert <> 0 THEN
                IF l_debug = 1 THEN
                    trace('Error when inserting MMTT for content lpn ID:'||p_content_lpn_id|| 'err is '||l_proc_msg);
                END IF;
                x_proc_msg := l_proc_msg;
                raise fnd_api.g_exc_error;
            END IF;

            IF l_debug = 1 THEN
                trace('MMTT inserted, hdr_id='||l_txn_hdr_id|| ',tmp_id='||l_txn_tmp_id);
            END IF;

            -- Update wms_packing_material_gtemp
            BEGIN
                IF p_from_lpn_id IS NOT NULL THEN
                  -- Split, Unpack
                  UPDATE wms_packing_material_gtemp
                  SET selected_flag = 'D' -- Deleted
                    WHERE (lpn_id = p_content_lpn_id AND parent_lpn_id = p_from_lpn_id) OR (parent_lpn_id = p_content_lpn_id AND parent_lpn_id <> outermost_lpn_id);
                ELSE
                  -- Pack
                  UPDATE wms_packing_material_gtemp
                  SET selected_flag = 'D'
                  WHERE outermost_lpn_id = p_content_lpn_id;
                END IF;
            EXCEPTION
                WHEN others THEN
                    IF l_debug = 1 THEN
                        trace('Error when deleting from wms_packing_material_gtemp for content lpn '||p_content_lpn_id);
                    END IF;
                    x_proc_msg := l_proc_msg;
                    raise fnd_api.g_exc_error;
            END;

        ELSIF p_inventory_item_id IS NOT NULL THEN
            -- Content is Item
            -- Check whether need to create new MMTT or update existing MMTT

            IF l_mmtt_exists = 0 THEN
                -- Create new MMTT

                IF l_debug = 1 THEN
                    trace('Calling inv_trx_util_pub.insert_line_trx() to insert MMTT with ');
                    trace(' p_trx_hdr_id => '||l_txn_hdr_id);
                    trace(' p_item_id => '||p_inventory_item_id);
                    trace(' p_revision => '||p_revision);
                    trace(' p_org_id => '||p_organization_id);
                    trace(' p_trx_action_id => '||l_txn_action_id);
                    trace(' p_trx_type_id => '||l_txn_type_id);
                    trace(' p_trx_src_type_id => 13');
                    trace(' p_trx_qty => '||p_transaction_qty);
                    trace(' p_pri_qty => '||p_primary_qty);
                    trace(' p_uom => '||p_transaction_uom);
                    trace(' p_subinv_code => '||p_subinventory_code);
                    trace(' p_tosubinv_code => '||l_to_sub);
                    trace(' p_locator_id => '||p_locator_id);
                    trace(' p_tolocator_id => '||l_to_loc_id);
                    trace(' p_from_lpn_id => '||p_from_lpn_id);
                    trace(' p_xfr_lpn_id => '||p_to_lpn_id);
                    trace(' p_secondary_trx_qty => '||p_secondary_qty);
                    trace(' p_secondary_uom => '||p_secondary_uom);
                    trace(' p_user_id => '||fnd_global.user_id);
                    trace(' p_grade_code => '||p_grade_code);
                END IF;
                l_insert := inv_trx_util_pub.insert_line_trx(
                  p_trx_hdr_id => l_txn_hdr_id
                 ,p_item_id => p_inventory_item_id
                 ,p_revision => p_revision
                 ,p_org_id => p_organization_id
                 ,p_trx_action_id => l_txn_action_id
                 ,p_trx_type_id => l_txn_type_id
                 ,p_trx_src_type_id => 13
                 ,p_trx_qty => p_transaction_qty
                 ,p_pri_qty => p_primary_qty
                 ,p_uom => p_transaction_uom
                 ,p_subinv_code => p_subinventory_code
                 ,p_tosubinv_code => l_to_sub
                 ,p_xfr_org_id => p_organization_id
                 ,p_locator_id => p_locator_id
                 ,p_tolocator_id => l_to_loc_id
                 ,p_from_lpn_id => p_from_lpn_id
                 ,p_xfr_lpn_id => p_to_lpn_id
                 ,p_user_id => fnd_global.user_id
                 ,p_secondary_trx_qty => p_secondary_qty
                 ,p_secondary_uom => p_secondary_uom
                 ,x_trx_tmp_id => l_txn_tmp_id
                 ,x_proc_msg => l_proc_msg);

                IF l_debug = 1 THEN
                    trace('done with inserting , l_insert ='||l_insert);
                END IF;
                IF l_insert <> 0 THEN
                    IF l_debug = 1 THEN
                        trace('Error when inserting MMTT for item id:'||p_inventory_item_id|| 'err is '||l_proc_msg);
                    END IF;
                    x_proc_msg := l_proc_msg;
                    raise fnd_api.g_exc_error;
                END IF;

                IF l_debug = 1 THEN
                    trace('MMTT inserted, tmp_id='||l_txn_tmp_id);
                END IF;

                l_ser_txn_id := l_txn_tmp_id;
            ELSE
                -- Update existing MMTT
                BEGIN
                    UPDATE mtl_material_transactions_temp
                    SET transaction_quantity = transaction_quantity + p_transaction_qty,
                         primary_quantity = primary_quantity + p_primary_qty,
                         secondary_transaction_quantity =
                           decode(secondary_transaction_quantity, NULL, NULL, secondary_transaction_quantity+p_secondary_qty)
                    WHERE transaction_temp_id = p_transaction_temp_id;
                EXCEPTION
                    WHEN others THEN
                        IF l_debug = 1 THEN
                            trace('Error when updating MMTT rec,tmp_id='||p_transaction_temp_id);
                        END IF;
                        raise fnd_api.g_exc_error;
                END;
                IF l_debug = 1 THEN
                    trace('MMTT updated for tmp_id '||p_transaction_temp_id);
                END IF;
                l_txn_tmp_id := p_transaction_temp_id;
                l_ser_txn_id := p_transaction_temp_id;
            END IF;

            IF p_lot_number IS NOT NULL THEN
                -- Create MTLT
                -- Insert MTLT record
                l_insert := inv_trx_util_pub.insert_lot_trx(
                  p_trx_tmp_id => l_txn_tmp_id
                , p_user_id => fnd_global.user_id
                , p_lot_number => p_lot_number
                , p_trx_qty => p_transaction_qty
                , p_pri_qty => p_primary_qty
                , p_secondary_qty => p_secondary_qty
                , p_secondary_uom => p_secondary_uom
                , p_grade_code    => p_grade_code  --INVCONV kkillams
                , x_ser_trx_id => l_ser_txn_id
                , x_proc_msg => l_proc_msg
                );
                IF l_insert <> 0 THEN
                    IF l_debug = 1 THEN
                        trace('Error when inserting MTLT for lot:'||p_lot_number||',l_proc_msg='||l_proc_msg);
                    END IF;
                    x_proc_msg := l_proc_msg;
                    raise fnd_api.g_exc_error;
                END IF;
                IF l_debug = 1 THEN
                    trace('MTLT record inserted for lot:'||p_lot_number||',ser_txn_id='||l_ser_txn_id);
                END IF;

            END IF; -- End if for Lot

            IF p_fm_serial_number IS NOT NULL THEN
                -- Create MSNT
                -- Insert MSNT record
                l_insert := inv_trx_util_pub.insert_ser_trx(
                  p_trx_tmp_id => l_ser_txn_id
                , p_user_id => fnd_global.user_id
                , p_fm_ser_num => p_fm_serial_number
                , p_to_ser_num => nvl(p_to_serial_number, p_fm_serial_number)
                , x_proc_msg => l_proc_msg
                );
                IF l_insert <> 0 THEN
                    IF l_debug = 1 THEN
                        trace('Error when inserting MSNT for fm_serial:'||p_fm_serial_number||',to_serial:'||p_to_serial_number||',l_proc_msg='||l_proc_msg);
                    END IF;
                    x_proc_msg := l_proc_msg;
                    raise fnd_api.g_exc_error;
                END IF;
                IF l_debug = 1 THEN
                    trace('MSNT record inserted for fm_serial:'||p_fm_serial_number||',to_serial:'||p_to_serial_number||',ser_txn_id='||l_ser_txn_id);
                END IF;

                x_serial_transaction_temp_id := l_ser_txn_id;
            END IF; -- End if of SN

	    --Start Bug 6028098
	     BEGIN
               SELECT sum(quantity)
                 INTO l_sum_qty
                 FROM wms_packing_material_gtemp
                WHERE inventory_item_id = p_inventory_item_id
                  AND nvl(lot_number, '#$%') = nvl(p_lot_number, nvl(lot_number, '#$%'))
                  AND nvl(revision, '#') = nvl(p_revision,nvl(revision, '#'))
                  AND subinventory = p_subinventory_code
                  AND locator_id = p_locator_id
                  AND lpn_id = p_from_lpn_id;
             EXCEPTION WHEN OTHERS THEN l_sum_qty := 0;
             END;

            -- Get the converted qty based on UOM.
             l_process_qty := inv_convert.inv_um_convert(p_inventory_item_id,null,p_transaction_qty,p_transaction_uom,p_primary_uom,null,null);

	     IF l_debug = 1 THEN
                    trace('l_sum_qty: ' || l_sum_qty);
		    trace('l_process_qty: ' || l_process_qty);
             END IF;


            -- If the summed qty = process_qty, then no loop needs to be done.
            -- Simply perform an update for all records for that part and set the qty to 0.
            IF l_process_qty = l_sum_qty THEN
              UPDATE wms_packing_material_gtemp
                 SET selected_flag = 'Y'
                    ,quantity = 0
               WHERE inventory_item_id = p_inventory_item_id
                 AND nvl(lot_number, '#$%') = nvl(p_lot_number, nvl(lot_number, '#$%'))
                 AND nvl(revision, '#') = nvl(p_revision,nvl(revision, '#'))
                 AND subinventory = p_subinventory_code
                 AND locator_id = p_locator_id
                 AND lpn_id = p_from_lpn_id;

            ELSE -- quantities are not the same, so you must loop and update the records you can.

              -- Loop thru records for that part and reduce qty by correct amount.
              FOR c1 IN get_gtemp LOOP

                IF l_process_qty <= 0 THEN
				  exit;
                END IF;

		 IF l_debug = 1 THEN
                    trace('c1.quantity ' || c1.quantity);
		    trace('l_process_qty: ' || l_process_qty);
                 END IF;

                -- Calculate the qty to deduct from the current line.
                IF c1.quantity <= l_process_qty THEN
                  l_update_qty := c1.quantity;
                  l_process_qty := l_process_qty - c1.quantity;
                ELSE
                  l_update_qty := l_process_qty;
                  l_process_qty := 0;
                END IF;

		IF l_debug = 1 THEN
                    trace('l_update_qty ' || l_update_qty);
                 END IF;

                UPDATE wms_packing_material_gtemp
                   SET selected_flag = 'Y'
                      ,quantity = quantity - l_update_qty
                 WHERE inventory_item_id = p_inventory_item_id
                   AND nvl(lot_number, '#$%') = nvl(p_lot_number, nvl(lot_number, '#$%'))
                   AND nvl(revision, '#') = nvl(p_revision,nvl(revision, '#'))
                   AND subinventory = p_subinventory_code
                   AND locator_id = p_locator_id
                   AND lpn_id = p_from_lpn_id
                   AND order_line_id = c1.order_line_id; -- Modified for bug 7606031

                EXIT WHEN l_process_qty <= 0;
              END LOOP;

            END IF;
	    --End Bug 6028098

--Start Commented out Bug 6028098
/*
            -- Update wms_packing_material_gtemp
            BEGIN
                UPDATE wms_packing_material_gtemp
                SET selected_flag = 'Y'
                   ,quantity = quantity - inv_convert.inv_um_convert(
                          inventory_item_id,null,p_transaction_qty,p_transaction_uom,uom,null,null)
                WHERE inventory_item_id = p_inventory_item_id
                AND nvl(lot_number, '#$%') = nvl(p_lot_number, nvl(lot_number, '#$%'))
                AND nvl(revision, '#') = nvl(p_revision,nvl(revision, '#'))
                AND subinventory = p_subinventory_code
                AND locator_id = p_locator_id
                AND lpn_id = p_from_lpn_id
                AND rownum<2;
                l_row_count := SQL%ROWCOUNT;
                IF l_row_count > 1 THEN
                    IF l_debug = 1 THEN
                        trace('Error when updating wms_packing_material_gtemp for item, only one record should be updated');
                    END IF;
                    fnd_message.set_name('INV','INV_FAILED');
                    fnd_msg_pub.add;
                    raise fnd_api.g_exc_error;
                ELSE
                IF l_debug = 1 THEN
                    trace('wms_packing_material_gtemp updated, row_count='||l_row_count);
                END IF;
                --END IF;
            EXCEPTION
                WHEN others THEN
                    IF l_debug = 1 THEN
                        trace('Error when updating wms_packing_material_gtemp for item '||p_inventory_item_id);
                    END IF;
                    fnd_message.set_name('INV','INV_FAILED');
                    fnd_msg_pub.add;
                    raise fnd_api.g_exc_error;
            END;
*/
	    --End Commented out Bug 6028098

            -- No need to mark group_mark_id on MSN
            -- Because material in outbound already has group_mark_id stamped
            -- From stage transfer txn
            -- TM does not clear group_mark_id for stage transfer txn

        END IF; -- End if of content is lpn or item

        x_transaction_header_id := l_txn_hdr_id;
        x_transaction_temp_id := l_txn_tmp_id;

    END IF; -- End if of Inbound or Outbound
EXCEPTION
    WHEN others THEN
        IF l_debug = 1 THEN
            trace('Other errors in create_txn');
            trace('ERROR Code ='||SQLCODE);
            trace('ERROR Message='||SQLERRM);
        END IF;
        x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data, p_encoded => 'F');
        IF (l_msg_count = 1) THEN
            x_proc_msg := x_proc_msg || l_msg_data;
        ELSIF (l_msg_count > 1) THEN
            FOR i IN 1 .. l_msg_count LOOP
                l_msg_data  := fnd_msg_pub.get(i, 'F');
                x_proc_msg := x_proc_msg || l_msg_data;
            END LOOP;
        END IF;
END create_txn;


/*******************************************
 * Procedure to delete MMTT/MTLT/MSNT record
 * For a pack/split/unpack transaction
 * This is used when user choose to do a UNDO
 *******************************************/
PROCEDURE delete_txn(
  x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
, p_transaction_header_id IN NUMBER
, p_transaction_temp_id IN NUMBER
, p_lot_number IN VARCHAR2
, p_serial_number IN VARCHAR2
, p_quantity IN NUMBER DEFAULT NULL
, p_uom IN VARCHAR2 DEFAULT NULL
) IS
    l_txn_hdr_id NUMBER;
    l_txn_tmp_id NUMBER;
    l_ser_tmp_id NUMBER;
    l_row_count NUMBER;
    l_mmtt_qty NUMBER;
    l_mtlt_qty NUMBER;
    l_mtlt_row_id ROWID;
    l_msnt_row_id ROWID;
    l_cont_lpn_id NUMBER;
    l_item_id NUMBER;
    l_txn_uom VARCHAR2(3);
    l_sec_uom VARCHAR2(3); --INCONV kkillams
    l_progress VARCHAR2(20);

BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    IF l_debug = 1 THEN
        trace('In wms_packing_workbench_pvt.delete_txn');
        trace(', p_transaction_header_id = '||p_transaction_header_id||',p_transaction_temp_id='||p_transaction_temp_id);
        trace(', p_lot_number='||p_lot_number||', p_serial_number='||p_serial_number);
    END IF;

    l_progress := '000';
    BEGIN
        SELECT content_lpn_id, inventory_item_id, primary_quantity, transaction_uom, secondary_uom_code
        INTO l_cont_lpn_id, l_item_id, l_mmtt_qty, l_txn_uom
        , l_sec_uom --INCONV kkillams
        FROM mtl_material_transactions_temp
        WHERE transaction_header_id = p_transaction_header_id
        AND transaction_temp_id = p_transaction_temp_id;
        IF l_debug = 1 THEN
            trace('Found MMTT, contLPNID='||l_cont_lpn_id||', l_item_id='||l_item_id||',l_mmtt_qty='||l_mmtt_qty);
        END IF;

        l_progress := '003';
        IF p_lot_number IS NOT NULL AND p_serial_number IS NOT NULL THEN
            -- Lot and Serial
            SELECT mtlt_row_id, mtlt_qty, msnt_row_id
            INTO l_mtlt_row_id, l_mtlt_qty, l_msnt_row_id
            FROM
                (SELECT mtlt.rowid mtlt_row_id, mtlt.primary_quantity mtlt_qty, msnt.rowid msnt_row_id
                FROM mtl_transaction_lots_temp mtlt, mtl_serial_numbers_temp msnt
                WHERE msnt.transaction_temp_id = mtlt.serial_transaction_temp_id
                AND mtlt.transaction_temp_id = p_transaction_temp_id
                AND mtlt.lot_number = p_lot_number
                AND msnt.fm_serial_number = p_serial_number
                order by msnt.creation_date desc) t
            WHERE rownum < 2;
            IF l_debug = 1 THEN
                trace('Lot and Serial, l_mtlt_row_id='||l_mtlt_row_id||',l_mtlt_qty='||l_mtlt_qty||',l_msnt_row_id='||l_msnt_row_id);
            END IF;
            l_progress := '005';
        ELSIF p_lot_number IS NOT NULL THEN
            -- Lot Only
            SELECT t.mtlt_row_id, t.mtlt_qty
            INTO l_mtlt_row_id, l_mtlt_qty
            FROM
                (SELECT rowid mtlt_row_id, primary_quantity mtlt_qty
                 FROM mtl_transaction_lots_temp
                 WHERE transaction_temp_id = p_transaction_temp_id
                 AND lot_number = p_lot_number
                 AND primary_quantity = p_quantity
                 order by creation_date desc) t
            WHERE rownum < 2;
            l_msnt_row_id := null;
            IF l_debug = 1 THEN
                trace('Lot only, l_mtlt_row_id='||l_mtlt_row_id||',l_mtlt_qty='||l_mtlt_qty);
            END IF;
            l_progress := '007';
        ELSIF p_serial_number IS NOT NULL THEN
            -- Serial Only
            SELECT t.msnt_row_id
            INTO l_msnt_row_id
            FROM
                (SELECT rowid msnt_row_id
                 FROM mtl_serial_numbers_temp
                 WHERE transaction_temp_id = p_transaction_temp_id
                 AND fm_serial_number = p_serial_number
                 order by creation_date desc) t
            WHERE rownum < 2;
            l_mtlt_row_id := null;
            l_mtlt_qty := null;
            IF l_debug = 1 THEN
                trace('Serial only, msnt_row_id='||l_msnt_row_id);
            END IF;
            l_progress := '009';
        ELSE
            -- No Lot , No serial
            null;
        END IF;

    EXCEPTION
        WHEN others THEN
            IF l_debug = 1 THEN
                trace('Error getting txn information for txn_temp_id '||p_transaction_temp_id);
            END IF;
    END;

    IF (l_cont_lpn_id IS NOT NULL) OR
       (p_lot_number IS NULL AND p_serial_number IS NULL) THEN
        IF l_debug = 1 THEN
            IF l_debug = 1 THEN
                trace('MMTT is for LPN or, Lot and serial number is null, deleting MMTT');
            END IF;
        END IF;
        DELETE mtl_material_transactions_temp
        WHERE transaction_temp_id = p_transaction_temp_id;
        l_row_count := SQL%ROWCOUNT;
        IF l_debug = 1 THEN
            trace(l_row_count||' rows of MMTT deleted with tmp_id '||p_transaction_temp_id);
        END IF;
        l_progress := '011';
        IF l_row_count <> 1 THEN
            RAISE fnd_api.g_exc_error;
        END IF;
    ELSE

        IF p_serial_number IS NOT NULL THEN
            IF l_debug = 1 THEN
                trace('Deleting MSNT');
            END IF;
            DELETE mtl_serial_numbers_temp
            WHERE rowid = l_msnt_row_id;
            l_row_count := SQL%ROWCOUNT;
            IF l_debug = 1 THEN
                trace(l_row_count||' rows of MSNT deleted with row_id '||l_msnt_row_id);
            END IF;
            l_progress := '013';

            IF l_row_count <> 1 THEN
                RAISE fnd_api.g_exc_error;
            END IF;
        END IF;

        IF p_lot_number IS NOT NULL THEN
            IF l_mtlt_qty = abs(p_quantity) THEN
                -- Delete MTLT
                DELETE mtl_transaction_lots_temp
                WHERE rowid = l_mtlt_row_id;
                l_row_count := SQL%ROWCOUNT;
                IF l_debug = 1 THEN
                    trace(l_row_count||' rows of MTLT deleted with row_id '||l_mtlt_row_id);
                END IF;
                l_progress := '015';

                IF l_row_count <> 1 THEN
                    RAISE fnd_api.g_exc_error;
                END IF;
            ELSIF l_mtlt_qty > abs(p_quantity) THEN
                -- Update MTLT
                UPDATE mtl_transaction_lots_temp
                SET primary_quantity = primary_quantity - abs(p_quantity)
                   ,transaction_quantity = inv_convert.inv_um_convert(
                       l_item_id,null,primary_quantity - abs(p_quantity),p_uom,l_txn_uom,null,null)
                WHERE rowid = l_mtlt_row_id;
                l_row_count := SQL%ROWCOUNT;
                IF l_debug = 1 THEN
                    trace(l_row_count||' rows of MTLT updated with row_id '||l_mtlt_row_id);
                END IF;
                l_progress := '017';

                IF l_row_count <> 1 THEN
                    RAISE fnd_api.g_exc_error;
                END IF;
            ELSE
                IF l_debug = 1 THEN
                    trace('mtlt quantity can not be less than p_quantity');
                END IF;
                RAISE fnd_api.g_exc_error;
            END IF;
        END IF;

        -- MMTT
        IF l_mmtt_qty = abs(p_quantity) THEN
            -- Delete MMTT
            DELETE mtl_material_transactions_temp
            WHERE transaction_temp_id = p_transaction_temp_id;
            l_row_count := SQL%ROWCOUNT;
            IF l_debug = 1 THEN
                trace(l_row_count||' rows of MMTT deleted with tmp_id '||p_transaction_temp_id);
            END IF;
            l_progress := '019';

            IF l_row_count <> 1 THEN
                RAISE fnd_api.g_exc_error;
            END IF;
        ELSIF l_mmtt_qty > abs(p_quantity) THEN
            UPDATE mtl_material_transactions_temp
            SET primary_quantity = primary_quantity - abs(p_quantity)
               ,transaction_quantity = inv_convert.inv_um_convert(
                l_item_id,null,primary_quantity - abs(p_quantity),p_uom,l_txn_uom,null,null)
                --INVCONV kkillams
               ,secondary_transaction_quantity = CASE WHEN secondary_uom_code IS NOT NULL THEN
                                                           inv_convert.inv_um_convert(l_item_id,
                                                                                      null,
                                                                                      primary_quantity - abs(p_quantity),
                                                                                      p_uom,
                                                                                      l_sec_uom,null,null)
                                                      ELSE NULL END
            WHERE transaction_temp_id = p_transaction_temp_id;
            l_row_count := SQL%ROWCOUNT;
            IF l_debug = 1 THEN
                trace(l_row_count||' rows of MMTT updated with tmp_id '||p_transaction_temp_id);
            END IF;
            l_progress := '021';
            IF l_row_count <> 1 THEN
                RAISE fnd_api.g_exc_error;
            END IF;
        ELSE
            IF l_debug = 1 THEN
                trace('mmtt quantity can not be less than p_quantity');
            END IF;
            RAISE fnd_api.g_exc_error;
        END IF;

    END IF;

EXCEPTION
    WHEN others THEN
        x_return_status := fnd_api.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        IF l_debug = 1 THEN
            trace('Error in delete_txn(), progress='||l_progress);
            trace('ERROR Code ='||SQLCODE);
            trace('ERROR Message='||SQLERRM);
        END IF;
END delete_txn;

/*******************************************
 * Procedure to call transaction manager
 * to process the MMTT records
 * This is used when user close a LPN
 *******************************************/
PROCEDURE process_txn(
  p_source IN NUMBER
, p_trx_hdr_id IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2
, x_proc_msg OUT NOCOPY VARCHAR2) IS

    l_return NUMBER;
    l_proc_msg VARCHAR2(1000) := null;
    l_return_status VARCHAR2(1);
    l_msg_data VARCHAR2(1000);
    l_msg_count NUMBER;

BEGIN
    IF l_debug = 1 THEN
        trace('In process txn, p_source='||p_source||',p_hdr_id='||p_trx_hdr_id);
    END IF;

    IF p_source = 1 THEN
        -- Inbound
        IF l_debug = 1 THEN
            trace('Calling WMS_RCV_PUP_PVT.pack_unpack_split for trx_hdr_id '||p_trx_hdr_id);
        END IF;
        WMS_RCV_PUP_PVT.pack_unpack_split
        ( p_header_id          => p_trx_hdr_id
        ,x_return_status      => l_return_status
        ,x_msg_count          => l_msg_count
        ,x_msg_data           => l_msg_data
        );
        IF l_debug = 1 THEN
            trace('Called WMS_RCV_PUP_PVT.pack_unpack_split API, return_status='||l_return_status||',msg_count='||l_msg_count||',msg_data='||l_msg_data);
        END IF;
        IF l_return_status <> 'S' THEN
            raise fnd_api.g_exc_error;
        ELSE
            x_return_status := fnd_api.G_RET_STS_SUCCESS;
            x_proc_msg := NULL;
        END IF;
    ELSE
        -- Outbound
        IF l_debug = 1 THEN
            trace('Calling INV_LPN_TRX_PUB.PROCESS_LPN_TRX for trx_hdr_id '||p_trx_hdr_id);
        END IF;

        l_return := INV_LPN_TRX_PUB.PROCESS_LPN_TRX(
            p_trx_hdr_id       => p_trx_hdr_id,
            x_proc_msg         => l_proc_msg,
            p_proc_mode        => 1 --Online Mode
        );
        IF l_debug = 1 THEN
            trace('called INV_LPN_TRX_PUB.PROCESS_LPN_TRX , l_return='||l_return||',l_proc_msg='||l_proc_msg);
        END IF;
        IF l_return = 0 THEN
            x_return_status := fnd_api.G_RET_STS_SUCCESS;
            x_proc_msg := null;
        ELSE
            x_return_status := fnd_api.G_RET_STS_ERROR;
            x_proc_msg := l_proc_msg;
        END IF;

    END IF;

EXCEPTION
    WHEN others THEN
        x_return_status := fnd_api.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data, p_encoded => 'F');
        IF (l_msg_count = 1) THEN
            x_proc_msg :=  l_msg_data;
        ELSIF (l_msg_count > 1) THEN
            FOR i IN 1 .. l_msg_count LOOP
                l_msg_data  := fnd_msg_pub.get(i, 'F');
                x_proc_msg := x_proc_msg || l_msg_data;
            END LOOP;
        END IF;
        IF l_debug = 1 THEN
            trace('Error in process_txn');
            trace('ERROR Code ='||SQLCODE);
            trace('ERROR Message='||SQLERRM);
        END IF;
END process_txn;

/*******************************
 * Firm Delivery API           *
 *******************************/
PROCEDURE firm_delivery(
  p_delivery_id IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2
, x_proc_msg OUT NOCOPY VARCHAR2) IS

    l_action_prms WSH_INTERFACE_EXT_GRP.del_action_parameters_rectype;
    l_delivery_id_tab        wsh_util_core.id_tab_type;
    l_delivery_out_rec       WSH_INTERFACE_EXT_GRP.Del_Action_Out_Rec_Type;

    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

BEGIN
    IF l_debug = 1 THEN
        trace('Calling WSH_INTERFACE_EXT_GRP.Delivery_Action() for delivery_id '||p_delivery_id);
    END IF;
    l_action_prms.caller := 'WMS_DLMG';
    l_action_prms.event := WSH_INTERFACE_EXT_GRP.G_START_OF_PACKING;
    l_action_prms.action_code := 'ADJUST-PLANNED-FLAG';

    l_delivery_id_tab(1) := p_delivery_id;

    WSH_INTERFACE_EXT_GRP.Delivery_Action
     (p_api_version_number     => 1.0,
      p_init_msg_list          => fnd_api.g_false,
      p_commit                 => fnd_api.g_false,
      p_action_prms            => l_action_prms,
      p_delivery_id_tab        => l_delivery_id_tab,
      x_delivery_out_rec       => l_delivery_out_rec,
      x_return_status          => l_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data);

    IF l_debug = 1 THEN
        trace('Called WSH_INTERFACE_EXT_GRP.Delivery_Action, return_status ='||l_return_status);
        trace('l_msg_data='||l_msg_data);
    END IF;
    x_return_status := l_return_status;
    IF l_return_status <> 'S' THEN
        fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data, p_encoded => 'F');
        IF (l_msg_count = 1) THEN
            x_proc_msg :=  l_msg_data;
        ELSIF (l_msg_count > 1) THEN
            FOR i IN 1 .. l_msg_count LOOP
                l_msg_data  := fnd_msg_pub.get(i, 'F');
                x_proc_msg := x_proc_msg || l_msg_data;
            END LOOP;
        END IF;
        IF l_debug = 1 THEN
            trace('WSH_INTERFACE_EXT_GRP.Delivery_Action failed, proc_msg = '||x_proc_msg);
        END IF;
    END IF;


EXCEPTION
    WHEN others THEN
        IF l_debug = 1 THEN
            trace('Error when in firm_delivery for delivery_id='||p_delivery_id);
            trace('ERROR Code ='||SQLCODE);
            trace('ERROR Message='||SQLERRM);
        END IF;
END firm_delivery;


PROCEDURE update_kit_model_info
( p_kit_item_id IN NUMBER
, p_component_item_id IN NUMBER
, p_top_model_line_id IN NUMBER
  ) IS

     CURSOR c_existing_kits_for_component IS
    SELECT DISTINCT top_model_line_id, kit_item_id
      FROM wms_packing_kitting_gtemp
      WHERE component_item_id = p_component_item_id;

     l_existing_kits_for_component c_existing_kits_for_component%ROWTYPE;
     l_kit_packed_qty NUMBER :=0;
     l_kit_order_qty NUMBER;
     l_completed_flag VARCHAR2(1);


BEGIN

   IF p_kit_item_id IS NOT NULL AND p_top_model_line_id IS NOT NULL THEN

      -- Check whehther kit is completed and update packed_qty of the Kit .

     BEGIN
    SELECT min(floor(decode(packed_qty_disp, '*',0,NULL,0,to_number(packed_qty_disp))/bom_qty)) kit_qty
      INTO l_kit_packed_qty
      FROM wms_packing_kitting_gtemp
      WHERE kit_item_id = p_kit_item_id
      AND top_model_line_id = p_top_model_line_id
      AND component_item_id IS NOT NULL;
     EXCEPTION
    WHEN no_data_found THEN
       l_kit_packed_qty := 0;
     END;
     IF l_debug = 1 THEN
    trace('Got kit_packed_qty = '||l_kit_packed_qty);
     END IF;

     -- Get Order Qty of the kit
     BEGIN
    SELECT order_qty INTO l_kit_order_qty
      FROM wms_packing_kitting_gtemp
      WHERE kit_item_id = p_kit_item_id
      AND top_model_line_id = p_top_model_line_id
      AND component_item_id IS NULL;
     EXCEPTION
    WHEN no_data_found THEN
       l_kit_order_qty := 0;
     END;

     -- Update packed_qty for the Kit
     IF l_kit_order_qty = l_kit_packed_qty THEN
    l_completed_flag := 'Y';
      ELSE
    l_completed_flag := 'N';
     END IF;

     UPDATE wms_packing_kitting_gtemp
       SET packed_qty = l_kit_packed_qty
       ,   packed_qty_disp = decode(l_kit_packed_qty,0,NULL,to_char(l_kit_packed_qty))
       ,   completed_flag = l_completed_flag
       WHERE kit_item_id = p_kit_item_id
       AND top_model_line_id = p_top_model_line_id
       AND component_item_id IS NULL;

       IF l_debug =  1 THEN
      trace(SQL%ROWCOUNT||' rows of wms_packing_kitting_gtemp updated');
       END IF;

       UPDATE wms_packing_kitting_gtemp
     SET completed_flag = l_completed_flag
     WHERE kit_item_id = p_kit_item_id
     AND top_model_line_id = p_top_model_line_id;
       IF l_debug =  1 THEN
      trace(SQL%ROWCOUNT||' rows of wms_packing_kitting_gtemp updated for completed_flag of '||l_completed_flag);
       END IF;


    ELSE
       --called from the get_kitting_info at the end of finding
       --multiple kits to update the kits info, after updating the qty
       --field FOR common item across all kits, if all order qty has been packed

       IF l_debug =  1 THEN
          trace('Updating Kit qty information after updating the common kit-component qty');
       END IF;

       -- Get new kit
       OPEN c_existing_kits_for_component;
       LOOP
          FETCH c_existing_kits_for_component INTO l_existing_kits_for_component;

          IF c_existing_kits_for_component%notfound THEN
         CLOSE c_existing_kits_for_component;
         EXIT;
          END IF;


            -- Check whehther kit is completed and update packed_qty of the Kit .
          l_kit_packed_qty := 0;
             BEGIN
        SELECT min(floor(decode(packed_qty_disp, '*',0,NULL,0,to_number(packed_qty_disp))/bom_qty)) kit_qty
          INTO l_kit_packed_qty
          FROM wms_packing_kitting_gtemp
          WHERE kit_item_id = l_existing_kits_for_component.kit_item_id
          AND top_model_line_id = l_existing_kits_for_component.top_model_line_id
          AND component_item_id IS NOT NULL;
         EXCEPTION
        WHEN no_data_found THEN
           l_kit_packed_qty := 0;
         END;
         IF l_debug = 1 THEN
        trace('Got kit_packed_qty = '||l_kit_packed_qty);
         END IF;

         -- Get Order Qty of the kit
             BEGIN
        SELECT order_qty INTO l_kit_order_qty
          FROM wms_packing_kitting_gtemp
          WHERE kit_item_id = l_existing_kits_for_component.kit_item_id
          AND top_model_line_id = l_existing_kits_for_component.top_model_line_id
          AND component_item_id IS NULL;
         EXCEPTION
        WHEN no_data_found THEN
           l_kit_order_qty := 0;
         END;

         -- Update packed_qty for the Kit
         IF l_kit_order_qty = l_kit_packed_qty THEN
        l_completed_flag := 'Y';
          ELSE
        l_completed_flag := 'N';
         END IF;

         UPDATE wms_packing_kitting_gtemp
           SET packed_qty = l_kit_packed_qty
           ,   packed_qty_disp = decode(l_kit_packed_qty,0,NULL,to_char(l_kit_packed_qty))
           ,   completed_flag = l_completed_flag
           WHERE kit_item_id = l_existing_kits_for_component.kit_item_id
           AND top_model_line_id = l_existing_kits_for_component.top_model_line_id
           AND component_item_id IS NULL;

           IF l_debug =  1 THEN
          trace(SQL%ROWCOUNT||' rows of wms_packing_kitting_gtemp updated');
           END IF;

           UPDATE wms_packing_kitting_gtemp
         SET completed_flag = l_completed_flag
         WHERE kit_item_id = l_existing_kits_for_component.kit_item_id
         AND top_model_line_id = l_existing_kits_for_component.top_model_line_id;

           IF l_debug =  1 THEN
          trace(SQL%ROWCOUNT||' rows of wms_packing_kitting_gtemp updated for completed_flag of '||l_completed_flag);
           END IF;

       END LOOP;
   END IF;

END update_kit_model_info;



/* **************************************************
 * Update the kit temp table
 * p_packed_qty: Given packed_qty
   When p_action = 'A'(Add): Add the p_packed_qty to existing p_packed_qty
        p_action = 'U'(Update): Update the gtemp.packed_qty as p_packed_qty
   p_disp_packed_qty:
     When is '*', update gtemp.packed_qty_disp as '*'
     When is NULL, update gtemp.packed_qty_disp as NULL
     When not null and not '*', update gtemp.packed_qty_disp as gtemp.packed_qty
 ****************************************************/
PROCEDURE update_kit_info
( p_kit_item_id IN NUMBER
, p_component_item_id IN NUMBER
, p_top_model_line_id IN NUMBER
, p_packed_qty IN NUMBER DEFAULT NULL
, p_disp_packed_qty IN VARCHAR2 DEFAULT NULL
, p_action IN VARCHAR2
) IS
    l_packed_qty NUMBER;
    l_packed_qty_disp VARCHAR2(200);

    CURSOR c_update_QTY_common_comp IS
    SELECT packed_qty,order_qty,kit_item_id,component_item_id,top_model_line_id FROM wms_packing_kitting_gtemp
      WHERE component_item_id = p_component_item_id
      AND ((packed_qty <> order_qty AND packed_qty IS NOT NULL) OR
           packed_qty IS NULL);

/*
           --for debug only
           CURSOR c_debug_cur IS
          SELECT
            packed_qty,order_qty,kit_item_id,component_item_id,top_model_line_id,packed_qty_disp
            FROM wms_packing_kitting_gtemp;

           l_debug_cur C_debug_cur%ROWTYPE;
*/

    l_update_qty_common_comp c_update_qty_common_comp%ROWTYPE;
    l_surplus_qty NUMBER;
    l_remaining_qty_to_pack NUMBER;
    l_total_row_cnt NUMBER;


BEGIN
    IF l_debug = 1 THEN
        trace('In update_kit_info');
        trace(' p_kit_item_id = '||p_kit_item_id||', p_component_item_id='||p_component_item_id);
        trace(' p_top_model_line_id='||p_top_model_line_id);
        trace(' p_packed_qty ='||p_packed_qty||', p_disp_packed_qty='||p_disp_packed_qty);
        trace(' p_action='||p_action);
    END IF;

    IF p_kit_item_id IS NOT NULL AND p_component_item_id IS NOT NULL then
       UPDATE wms_packing_kitting_gtemp
         SET packed_qty = least(order_qty,decode(p_action, 'A', nvl(packed_qty,0) + p_packed_qty, p_packed_qty))
         ,   packed_qty_disp = Decode(p_disp_packed_qty, '*', '*', NULL, NULL,
                      to_char(least(order_qty,decode(p_action, 'A', nvl(packed_qty,0) + p_packed_qty, p_packed_qty))))
         WHERE kit_item_id = p_kit_item_id
         AND component_item_id = p_component_item_id
         AND top_model_line_id = p_top_model_line_id;


       IF l_debug = 1 THEN
          trace('updated kit '|| p_kit_item_id||' and component '||p_component_item_id||' top_model_line_id='||p_top_model_line_id);

          trace('NUMBER OF ROWS UPDATE :'||SQL%rowcount);
       END IF;


       /*

       --FOR DEBUG ONLY

       OPEN c_debug_cur;
       LOOP
          FETCH c_debug_cur INTO l_debug_cur;

          IF c_debug_cur%notfound THEN
         CLOSE c_debug_cur;
         EXIT;
          END IF;


          IF l_debug = 1 THEN
         trace('---------------------******************--------------');
         trace('kit_item_id :'||l_debug_cur.kit_item_id);
         trace('component_item_id :'|| l_debug_cur.component_item_id);
         trace('top_model_line_id :'||l_debug_cur.top_model_line_id);
         trace('packed_qty :'||l_debug_cur.packed_qty);
         trace('order_qty :'||l_debug_cur.order_qty);
         trace('packed_qty_disp :'||l_debug_cur.packed_qty_disp);
          END IF;

         END LOOP;

         --for debug ONLY
         */


     ELSE

       IF l_debug = 1 THEN
          trace('Updating qty in WPKG recursively');
       END IF;

       l_surplus_qty := 0;
       l_remaining_qty_to_pack:= p_packed_qty;

       OPEN c_update_QTY_common_comp;
       LOOP
          FETCH c_update_QTY_common_comp INTO l_update_qty_common_comp;

          IF c_update_QTY_common_comp%notfound THEN
         CLOSE c_update_qty_common_comp;
         EXIT;
          END IF;

          IF l_debug = 1 THEN
         trace('Inside the loop to update the qty recursively in WPKG');
          END IF;

          IF l_update_qty_common_comp.packed_qty IS NULL THEN
         l_update_qty_common_comp.packed_qty := 0;
          END IF;

          l_surplus_qty := (l_remaining_qty_to_pack + l_update_qty_common_comp.packed_qty) - l_update_qty_common_comp.order_qty;

          IF l_debug = 1 THEN
         trace('l_remaining_qty_to_pack :' ||l_remaining_qty_to_pack);
         trace('l_update_qty_common_comp.packed_qt :' ||l_update_qty_common_comp.packed_qty);
         trace('l_update_qty_common_comp.order_qty :'||  l_update_qty_common_comp.order_qty);
         trace('l_surplus_qty :'||l_surplus_qty);

          END IF;


          IF l_surplus_qty <= 0 THEN

         UPDATE wms_packing_kitting_gtemp
           SET packed_qty = (l_remaining_qty_to_pack+l_update_qty_common_comp.packed_qty)
           --, packed_qty_disp = '*'
           WHERE kit_item_id =  l_update_qty_common_comp.kit_item_id
           AND component_item_id = l_update_qty_common_comp.component_item_id
           AND top_model_line_id = l_update_qty_common_comp.top_model_line_id;

         IF l_debug = 1 THEN
            trace('Final remaining qty after consuming p_packed_qty : 0');
         END IF;

         CLOSE c_update_qty_common_comp;
         EXIT;--this record finally consumed remaining, exit

           ELSIF l_surplus_qty > 0 THEN
         --this record can not consume complete p_packed_qty
         --Update this record with enough qty to fulfill this order_qty

         l_remaining_qty_to_pack := l_remaining_qty_to_pack -
           (l_update_qty_common_comp.order_qty - l_update_qty_common_comp.packed_qty);

         UPDATE wms_packing_kitting_gtemp
           SET packed_qty = l_update_qty_common_comp.order_qty
           --, packed_qty_disp = '*'
           WHERE kit_item_id =  l_update_qty_common_comp.kit_item_id
           AND component_item_id = l_update_qty_common_comp.component_item_id
           AND top_model_line_id = l_update_qty_common_comp.top_model_line_id;

         IF l_debug = 1 THEN
            trace('Remaining qty after consuming p_packed_qty :'||l_remaining_qty_to_pack);
         END IF;

          END IF;

       END LOOP;

          UPDATE wms_packing_kitting_gtemp
        SET packed_qty_disp = '*'
        WHERE  component_item_id = p_component_item_id;

    END IF;


    --Now update kit model information
    update_kit_model_info
      ( p_kit_item_id       => p_kit_item_id
        , p_component_item_id => p_component_item_id
        , p_top_model_line_id => p_top_model_line_id);


END update_kit_info;




PROCEDURE get_kitting_info(
    x_return_status OUT NOCOPY VARCHAR2
,   x_msg_data OUT NOCOPY VARCHAR2
,   x_msg_count OUT NOCOPY VARCHAR2
,    p_organization_id IN NUMBER
    ,p_inventory_item_id IN NUMBER
    ,p_quantity IN NUMBER) IS

       /*OPEN ISSUES

       --what if the TO-LPN already has some content, do they become
       --part OF the kit TO be packed -- Not Yet

       --what if the user scans the quantity for common item greater than all
       --exhausted-qty of component IN the current  kit list. where to
       --save this extra quantity, which might be needed later FOR new
       --added kit -- Just show the order qty

       */


   CURSOR c_update_disp_qty_common_comp IS
      SELECT packed_qty,kit_item_id,component_item_id,top_model_line_id FROM wms_packing_kitting_gtemp
    WHERE component_item_id = p_inventory_item_id
    AND packed_qty = order_qty
    AND packed_qty IS NOT NULL;



    l_kit_list kit_tbl_type;
    l_other_kit_list kit_tbl_type;
        l_kit_component_list kit_component_tbl_type;

    l_update_disp_qty_common_comp c_update_disp_qty_common_comp%ROWTYPE;

    l_new_inserted_kit_cnt NUMBER := 0;
    l_item_unique_existing_kit NUMBER;
    l_common_qty_filled NUMBER := 0;


BEGIN
    IF l_debug = 1 THEN
        trace('In get_kitting_info, p_org_id='||p_organization_id||',p_item_id='||p_inventory_item_id||',p_qty='||p_quantity);
    END IF;
    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    -- First get the list of kits that the item belongs to
    l_kit_list := get_kit_list(p_organization_id, p_inventory_item_id, 'N');

    l_new_inserted_kit_cnt := 0;

    IF l_kit_list.COUNT = 1 THEN
        -- Only one kit
        IF l_debug = 1 THEN
            trace('Item belongs to only one kit');
        END IF;
        IF l_kit_list(1).exist_flag = 'N' THEN
            -- New kit
            insert_kit_info
            ( p_kit_item_id =>l_kit_list(1).kit_item_id
            , p_component_item_id =>p_inventory_item_id
            , p_top_model_line_id => l_kit_list(1).top_model_line_id
            , p_packed_qty => p_quantity
            , p_disp_packed_qty => p_quantity
            );
            IF l_debug = 1 THEN
                trace('Kit 1 is a new kit, inserted information for kit ID '||l_kit_list(1).kit_item_id);
            END IF;
        ELSE
            -- Existing kit
            -- Update this kit info
            update_kit_info
            ( p_kit_item_id =>l_kit_list(1).kit_item_id
            , p_component_item_id =>p_inventory_item_id
            , p_top_model_line_id => l_kit_list(1).top_model_line_id
            , p_packed_qty => p_quantity
            , p_disp_packed_qty => to_char(p_quantity)
            , p_action => 'A' -- Add
            );
            IF l_debug = 1 THEN
                trace('Kit 1 exists already, updated kit information for kit ID '||l_kit_list(1).kit_item_id);
            END IF;
            -- Get other items in the kit
            l_kit_component_list.DELETE;
            l_kit_component_list := get_kit_component_list
            (p_kit_item_id => l_kit_list(1).kit_item_id
            ,p_top_model_line_id => l_kit_list(1).top_model_line_id
            ,p_exclude_item_id => p_inventory_item_id
            );
            IF l_debug = 1 THEN
                trace('Got other items in the existing kit, no. of items='||l_kit_component_list.COUNT);
            END IF;
            FOR i IN 1..l_kit_component_list.COUNT LOOP
                IF l_kit_component_list(i).packed_qty IS NOT NULL AND
                   l_kit_component_list(i).packed_qty_disp='*' THEN
                    -- Update disp_pack_qty as p_packed_qty
                    update_kit_info
                    (p_kit_item_id => l_kit_list(1).kit_item_id
                    , p_component_item_id =>
                       l_kit_component_list(i).component_item_id
                    , p_top_model_line_id => l_kit_list(1).top_model_line_id
                    , p_packed_qty => l_kit_component_list(i).packed_qty
                    , p_disp_packed_qty => to_char(l_kit_component_list(i).packed_qty)
                    , p_action => 'U'); -- Update
                    IF l_debug = 1 THEN
                        trace('updated kit info for item '|| l_kit_component_list(i).component_item_id
                          ||' in kit '||l_kit_list(1).kit_item_id);
                        trace('get other unidentified kits for this item');
                    END IF;
                    l_other_kit_list.DELETE;
                    l_other_kit_list := get_kit_list(p_organization_id,
                        l_kit_component_list(i).component_item_id, 'Y');
                    FOR j IN 1..l_other_kit_list.COUNT LOOP
                        IF l_other_kit_list(j).kit_item_id <>l_kit_list(1).kit_item_id AND
                           l_other_kit_list(j).identified_flag = 'N' THEN

                            update_kit_info
                            (p_kit_item_id => l_other_kit_list(j).kit_item_id
                            , p_component_item_id =>l_kit_component_list(i).component_item_id
                            , p_top_model_line_id => l_kit_list(j).top_model_line_id
                            , p_packed_qty => NULL
                            , p_disp_packed_qty => NULL
                            , p_action => 'U'); -- Update
                            IF l_debug = 1 THEN
                                trace('Updated the packedQty and dispQty as NULL for kit '||l_other_kit_list(j).kit_item_id||', component '||l_kit_component_list(i).component_item_id);
                            END IF;
                        END IF; -- End if to update kit info
                    END LOOP; -- End loop for other kits
                END IF; -- End if for unidentified component
            END LOOP; -- End loop for all components in the kits

        END IF; -- End if new kit or existing kit

     ELSE

       -- Item belongs to more than one kits



       --l_item_unique_existing_kit is USED only for existing records,
       -- before scan of current item
       l_item_unique_existing_kit := is_item_unique_existing_kit(p_inventory_item_id);

       IF l_debug = 1 THEN
          trace('Items scanned so far belong to multiple kits');
          --TO find out whether the newly scanned item is unique
          -- across the kits; l_new_kit_count = 1 will tell that.
          trace('Is last scanned item unique across all kits for scanned items,(1: Yes) Value -> '||g_kit_count_current_comp);
          trace('number of kits this item belongs to in existing kit-list :'||l_item_unique_existing_kit);

       END IF;



       FOR i IN 1..l_kit_list.COUNT LOOP --loop is needed to
          -- INSERT multiple NEW kits, but after UPDATE just exit

          IF l_debug = 1 THEN
         trace('Found kits, LOOP '||i);
          END IF;
          IF l_kit_list(i).exist_flag = 'Y' THEN
         -- Existing kit

         --there is no Concept of identified flag anymore!!!!

         --see whether the item is unique in the
         --existing set of kits,THEN UPDATE qty OF
         --that UNIQUE item
         IF l_item_unique_existing_kit = 1 THEN

            IF g_kit_count_current_comp > 1 THEN
               --means item is unique among the existing ones BUT
               --it braught at least one more NEW Kit
               --Do not update qty here, show display here
               --At the time of New Kit qty will be updated recursively

               IF l_debug = 1 THEN
              trace(' Kit '||i||' is non-identified existing kit FOR UNIQUE item, just add to the packed qty');
               END IF;

               update_kit_info
             (p_kit_item_id=>l_kit_list(i).kit_item_id
              ,p_component_item_id=> p_inventory_item_id
              ,p_top_model_line_id => l_kit_list(i).top_model_line_id
              ,p_packed_qty=> 0
              ,p_disp_packed_qty => '*'
              ,p_action => 'A'); -- Add


             ELSE
               --means unique kit in the existing kit, component did not
               --bring ANY NEW kit

               IF l_debug = 1 THEN
              trace(' Kit '||i||' is non-identified existing kit FOR UNIQUE item, just add to the packed qty');
               END IF;

               update_kit_info
             (p_kit_item_id=>l_kit_list(i).kit_item_id
              ,p_component_item_id=> p_inventory_item_id
              ,p_top_model_line_id => l_kit_list(i).top_model_line_id
              ,p_packed_qty=>p_quantity
              ,p_disp_packed_qty => to_char(p_quantity)
              ,p_action => 'A'); -- Add

            END IF;


            --Do not exit Here since it has to update the correct
            --kit, It might not be the first one. in the API for
            --unmatching kits it will NOT get updated



          ELSIF l_item_unique_existing_kit > 1 THEN --item belongs
            --TO more than one existing kit


            IF i = l_kit_list.COUNT() THEN

               IF l_debug = 1 THEN
              trace(' Kit '||i||' is last non-unique component IN existing kit, modify packing qty recursively');
              END IF;

               -- last record in the list of existing kits
               -- Add the quantity
               update_kit_info
             (p_kit_item_id=>NULL--l_kit_list(i).kit_item_id
              ,p_component_item_id=> p_inventory_item_id
              ,p_top_model_line_id => NULL--l_kit_list(i).top_model_line_id
              ,p_packed_qty=> p_quantity
              ,p_disp_packed_qty => '*'
              ,p_action => 'A');

             ELSE

               --Just update the qty to 0 and display qty fld with *

               IF l_debug = 1 THEN
              trace(' Kit '||i||' is non-unique item in existing kit, just add 0 tO the packed qty,set disp_packed_qty as *');
               END IF;

               -- Not identified kit
               -- Add to packed_qty, but disp_packed_qty is *
               update_kit_info
             (p_kit_item_id=>l_kit_list(i).kit_item_id
              ,p_component_item_id=> p_inventory_item_id
              ,p_top_model_line_id => l_kit_list(i).top_model_line_id
              ,p_packed_qty=> 0
              ,p_disp_packed_qty => '*'
              ,p_action => 'A');

            END IF;


         END IF; -- is_item_unique in existing kit


           ELSE --MEANS l_kit_list(i).exist_flag = 'N'
         -- New kit

         IF g_kit_count_current_comp= 1 THEN
            -- From (exist_flag = 'N') and (g_kit_count_current_comp = 1)
            -- we can  infer that new scanned item braught only one NEW unique kit
            -- And this Kit is NOT part of existing kit-list

            IF l_debug = 1 THEN
               trace(' Kit '||i||' is new unique kit for the item, insert_kit_info with packed_qty ');
            END IF;
            insert_kit_info
              (p_kit_item_id =>l_kit_list(i).kit_item_id
               , p_component_item_id =>p_inventory_item_id
               , p_top_model_line_id => l_kit_list(i).top_model_line_id
               , p_packed_qty => p_quantity
               , p_disp_packed_qty => p_quantity);


            EXIT;--unique, hence exit

          ELSE -- new scanned item braught more than one
            --kits, Be Careful: NOT all of them might be
            --NEW Kit, some kits might belongs to existing kit-list
            IF l_debug = 1 THEN
               trace(' Kit '||i||' is new kit, insert_kit_info with packed_qty and *');
            END IF;

            insert_kit_info
              (p_kit_item_id =>l_kit_list(i).kit_item_id
               , p_component_item_id =>p_inventory_item_id
               , p_top_model_line_id => l_kit_list(i).top_model_line_id
               , p_packed_qty => NULL
               , p_disp_packed_qty => '*'
               );

            -- in the Kit_list() we have total number of
            -- kits in the order of Old and New Kits.
            -- Keep inserting NULL in the qty for the component Item
            -- for all new unique kits and
            -- when we are at the end of last new kit
            -- UPDATE the quantity for this Item.

            IF i = l_kit_list.COUNT THEN
               IF l_debug = 1 THEN
              trace(' updating packing qty for the item across kits');
            END IF;

               -- update the quantity in this call take care of
               --updating qty for same component across
               --different kits till the CURRENT p_quantity
               --gets exhausted
               update_kit_info
             (p_kit_item_id=>NULL--l_kit_list(i).kit_item_id
              ,p_component_item_id=> p_inventory_item_id
              ,p_top_model_line_id => NULL--l_kit_list(i).top_model_line_id
              ,p_packed_qty=> p_quantity
              ,p_disp_packed_qty => '*'
              ,p_action => 'A');

            END IF;

         END IF;

          END IF; -- End if of existing kit or not

       END LOOP; -- end loop of kit list


       --if all the ordered qty across all eligible kits for the scanned items (kit-component) has been
       --packed to fulfill the order for all eligible kits in the list of
       --eligible material then update the qty = order qty for
       --the kit component

       IF is_item_unique_existing_kit(p_inventory_item_id) > 1 THEN

          IF l_debug = 1 THEN
         trace('inside updating total qty for common item');

          END IF;


          /*
          --FOR DEBUG ONLY
           BEGIN
         SELECT SUM(packed_qty), SUM(order_qty) INTO l_pack_comp_qty_total,l_ord_comp_qty_total
         FROM wms_packing_kitting_gtemp
         WHERE component_item_id = p_inventory_item_id
         GROUP BY component_item_id;
         EXCEPTION
         WHEN no_data_found THEN
         l_pack_comp_qty_total := 0;
         END;

         IF l_debug = 1 THEN
         trace('l_pack_comp_qty_total '|| l_pack_comp_qty_total||' and l_ord_comp_qty_tota :'||l_ord_comp_qty_total);

         END IF;
         --FOR DEBUG ONLY
         */


          BEGIN
         SELECT 1 INTO l_common_qty_filled FROM dual WHERE exists
           (SELECT 1
            FROM wms_packing_kitting_gtemp
            WHERE component_item_id = p_inventory_item_id
            AND ((packed_qty <> order_qty AND packed_qty IS NOT
              NULL) OR (packed_qty IS NULL) ));

          EXCEPTION
         WHEN no_data_found THEN
            l_common_qty_filled := 0;--requirement of qty for the
            --compenent across ALL kits have been fulfilled
         WHEN too_many_rows THEN
            l_common_qty_filled := 1;
          END;


          IF l_common_qty_filled = 0 THEN

         --update disp qty for the current common item across all kits
         OPEN c_update_disp_qty_common_comp;
         LOOP
            FETCH c_update_disp_qty_common_comp INTO l_update_disp_qty_common_comp;

            IF c_update_disp_qty_common_comp%notfound THEN
               CLOSE c_update_disp_qty_common_comp;
               EXIT;
            END IF;

            UPDATE wms_packing_kitting_gtemp
              SET packed_qty_disp = l_update_disp_qty_common_comp.packed_qty
              WHERE kit_item_id =  l_update_disp_qty_common_comp.kit_item_id
              AND component_item_id = l_update_disp_qty_common_comp.component_item_id
              AND top_model_line_id = l_update_disp_qty_common_comp.top_model_line_id;


         END LOOP;

         --Now update kit model information
         update_kit_model_info
           ( p_kit_item_id       => NULL
             , p_component_item_id => p_inventory_item_id
             , p_top_model_line_id => NULL);

          END IF;


       END IF; --the item is a common component across kits


    END IF; -- end if of only one kit or multiple kits

EXCEPTION
   WHEN others THEN
      IF l_debug = 1 THEN
     trace('Unexpected Error in get_kitting_info');
     trace('ERROR Code ='||SQLCODE);
     trace('ERROR Message='||SQLERRM);
      END IF;

END get_kitting_info;


FUNCTION is_kit_identified(p_kit_id IN NUMBER) RETURN VARCHAR2 IS
    l_exist NUMBER := 0;
BEGIN
    BEGIN
        SELECT 1 INTO l_exist
        FROM dual
        WHERE exists(
            SELECT 1 FROM wms_packing_kitting_gtemp
            WHERE kit_item_id = p_kit_id
            AND component_item_id IS NOT NULL
            AND packed_qty IS NOT NULL
            AND packed_qty_disp = '*');
    EXCEPTION
        WHEN no_data_found THEN
            l_exist := 0;
    END;
    IF l_exist = 0 THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;

END is_kit_identified;


FUNCTION is_item_unique_existing_kit(p_component_id IN NUMBER) RETURN NUMBER IS
    l_cnt NUMBER := 0;
BEGIN

 BEGIN
    SELECT COUNT(1) INTO l_cnt FROM wms_packing_kitting_gtemp
      WHERE component_item_id = p_component_id;
 EXCEPTION
    WHEN no_data_found THEN
       l_cnt := 0; --is not there, unique
 END;

 RETURN l_cnt;

END is_item_unique_existing_kit;



/**********************************
 * Procedure to set savepoint
 * This is called from the form/library
 * The savepoint can be set currently are
 *   PACK_START
 *   BEFORE_TM
 * Return value:
 *   0 Success
 *   -1 Failed to set savepoint
 **************************************/
PROCEDURE issue_savepoint(p_savepoint VARCHAR2) IS
BEGIN
    IF p_savepoint = 'PACK_START' THEN
        SAVEPOINT PACK_START;
    ELSIF p_savepoint = 'BEFORE_TM' THEN
        SAVEPOINT BEFORE_TM;
    ELSE
        IF l_debug = 1 THEN
            trace('Wrong name for p_savepoint '||p_savepoint);
        END IF;
    END IF;
    IF l_debug = 1 THEN
        trace('Set savepoint '||p_savepoint);
    END IF;
EXCEPTION
    WHEN others THEN
        IF l_debug = 1 THEN
            trace('Error when setting savepoint '||p_savepoint||' in issue_savepoint');
            trace('ERROR Code ='||SQLCODE);
            trace('ERROR Message='||SQLERRM);
        END IF;
END issue_savepoint;

/**********************************
 * Procedure to issue rollback to savepoint
 * This is called from the form/library
 * The savepoint can be rollback currently are
 *   PACK_START
 *   BEFORE_TM
 *   NULL : Rollback everything
 **************************************/
PROCEDURE issue_rollback(p_savepoint VARCHAR2) IS
BEGIN
    IF p_savepoint IS NULL THEN
        ROLLBACK;
    ELSIF p_savepoint = 'PACK_START' THEN
        ROLLBACK TO PACK_START;
    ELSIF p_savepoint = 'BEFORE_TM' THEN
        ROLLBACK TO BEFORE_TM;
    ELSE
        IF l_debug = 1 THEN
            trace('Wrong name for p_savepoint '||p_savepoint||' in issue_rollback');
        END IF;
    END IF;
    IF l_debug = 1 THEN
        trace('Rollback '||p_savepoint);
    END IF;
EXCEPTION
    WHEN others THEN
        IF l_debug = 1 THEN
            trace('Error in issue rollback for '||p_savepoint);
            trace('ERROR Code ='||SQLCODE);
            trace('ERROR Message='||SQLERRM);
        END IF;
END issue_rollback;

/**********************************
 * Procedure to issue commit
 * This is called from the form/library
**************************************/
PROCEDURE issue_commit IS
BEGIN
    commit;
END issue_commit;
END WMS_PACKING_WORKBENCH_PVT;

/
