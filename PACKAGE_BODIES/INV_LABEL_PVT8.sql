--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PVT8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PVT8" AS
/* $Header: INVLAP8B.pls 120.20.12010000.8 2010/02/07 12:23:24 sanjeevs ship $ */


LABEL_B     CONSTANT VARCHAR2(50)  := '<label';
LABEL_E     CONSTANT VARCHAR2(50)  := '</label>'||fnd_global.local_chr(10);
VARIABLE_B  CONSTANT VARCHAR2(50)  := '<variable name= "';
VARIABLE_E  CONSTANT VARCHAR2(50)  := '</variable>'||fnd_global.local_chr(10);
TAG_E       CONSTANT VARCHAR2(50)  := '>'||fnd_global.local_chr(10);
G_DATE_FORMAT_MASK   VARCHAR2(100) := INV_LABEL.G_DATE_FORMAT_MASK;
NULL_NUM    CONSTANT NUMBER   := -9999;
NULL_VAR    CONSTANT VARCHAR2(10)  := '$%#!@^&*';
l_debug NUMBER;

g_get_hash_for_insert NUMBER := 1;
g_get_hash_for_retrieve NUMBER := 0;
g_count_custom_sql NUMBER := 0;

TYPE column_element_tp IS RECORD
  (column_name VARCHAR2(60),
   column_content VARCHAR2(2000));


TYPE column_elements_tab_tp IS TABLE OF column_element_tp
  INDEX BY BINARY_INTEGER;

g_column_elements_table column_elements_tab_tp;

TYPE field_element_tp IS RECORD
  (column_name_with_count VARCHAR2(60),
   variable_name VARCHAR2(60),
   sql_stmt VARCHAR2(4000));


TYPE field_elements_tab_tp IS TABLE OF field_element_tp
  INDEX BY BINARY_INTEGER;

g_field_elements_table field_elements_tab_tp;

TYPE carton_count IS RECORD
( delivery_id NUMBER
, carton_count NUMBER
, carton_index NUMBER);

TYPE carton_count_tb IS TABLE OF carton_count INDEX BY BINARY_INTEGER;

g_carton_tb carton_count_tb;

PROCEDURE trace(p_message IN VARCHAR2) IS
BEGIN
   inv_label.trace(p_message, 'LABEL_SHIP_CONT');
END trace;

/* Private API to get/set hash value for a column */
FUNCTION get_column_hash_value (p_input_string VARCHAR2)
  RETURN NUMBER IS
     l_return_hash_value NUMBER;
     l_orig_hash_value NUMBER;
     l_hash_base NUMBER := 2;
     l_hash_size NUMBER := Power(2, 20);
BEGIN
   l_orig_hash_value := dbms_utility.get_hash_value
     (
      name         => p_input_string
      ,base    => l_hash_base
      ,hash_size   => l_hash_size
      );

   IF  g_column_elements_table.exists(l_orig_hash_value) AND
     g_column_elements_table(l_orig_hash_value).column_name = p_input_string THEN


      l_return_hash_value := l_orig_hash_value;

   ELSIF g_column_elements_table.exists(l_orig_hash_value) THEN
      -- hash collision

    LOOP
    l_orig_hash_value := l_orig_hash_value + 1;

    IF l_orig_hash_value > l_hash_size THEN
       -- Don't need to check hash overflow here because the hash range
       -- for sure is greater than the number of columns.
       l_orig_hash_value := l_hash_base;
    END IF;

    IF g_column_elements_table.exists(l_orig_hash_value) AND
      g_column_elements_table(l_orig_hash_value).column_name = p_input_string THEN

       EXIT;
     ELSIF NOT g_column_elements_table.exists(l_orig_hash_value) THEN

       EXIT;
    END IF;

      END LOOP;

      l_return_hash_value := l_orig_hash_value;

    ELSE

      l_return_hash_value := l_orig_hash_value;
   END IF;

   g_column_elements_table(l_return_hash_value).column_name := p_input_string;

   RETURN l_return_hash_value;

END get_column_hash_value;

/* Private API to get/set hash value for a field */
FUNCTION get_field_hash_value (p_input_string VARCHAR2, p_get_hash_mode NUMBER)
  RETURN NUMBER IS
     l_return_hash_value NUMBER;
     l_orig_hash_value NUMBER;
     l_hash_base NUMBER := 2;
     l_hash_size NUMBER := Power(2, 20);
BEGIN
   l_orig_hash_value := dbms_utility.get_hash_value
     (
      name         => p_input_string
      ,base    => l_hash_base
      ,hash_size   => l_hash_size
      );

   IF  g_field_elements_table.exists(l_orig_hash_value) AND
      g_field_elements_table(l_orig_hash_value).column_name_with_count = p_input_string THEN
      l_return_hash_value := l_orig_hash_value;

   ELSIF g_field_elements_table.exists(l_orig_hash_value) THEN
      -- hash collision
    LOOP
    l_orig_hash_value := l_orig_hash_value + 1;

    IF l_orig_hash_value > l_hash_size THEN
       -- Don't need to check hash overflow here because the hash range
       -- for sure is greater than the number of columns.
       l_orig_hash_value := l_hash_base;
    END IF;

    IF g_field_elements_table.exists(l_orig_hash_value) AND
      g_field_elements_table(l_orig_hash_value).column_name_with_count = p_input_string THEN

       EXIT;
     ELSIF NOT g_field_elements_table.exists(l_orig_hash_value) THEN

       EXIT;
    END IF;

      END LOOP;

      l_return_hash_value := l_orig_hash_value;

    ELSE

      l_return_hash_value := l_orig_hash_value;
   END IF;

   IF p_get_hash_mode = g_get_hash_for_insert THEN
      g_field_elements_table(l_return_hash_value).column_name_with_count := p_input_string;
   END IF;

   RETURN l_return_hash_value;

END get_field_hash_value;

/* Private API to get the variable name for a given column_name */
FUNCTION get_variable_name(p_column_name IN VARCHAR2,
    p_row_index IN NUMBER, p_format_id IN NUMBER) RETURN VARCHAR2 IS
    l_variable_name VARCHAR2(100);
BEGIN
   --trace('Begin get_variable_name for column '|| p_column_name || ' with p_row_index : ' || p_row_index );

   BEGIN
      l_variable_name := g_field_elements_table(get_field_hash_value(p_column_name||(p_row_index+1), g_get_hash_for_retrieve)).variable_name;
   EXCEPTION
      WHEN OTHERS THEN
         l_variable_name := NULL;
   END;
   --IF l_variable_name is not NULL THEN
   -- trace('get variable name '||l_variable_name||' for column '|| p_column_name);
   --END IF;

   RETURN l_variable_name;

END get_variable_name;

PROCEDURE build_format_fields_structure(p_label_format_id NUMBER) IS

   CURSOR c_label_field_var IS
      SELECT wlf.column_name,
             wlf.sql_stmt,
             wlfv.field_variable_name
      FROM wms_label_field_variables wlfv,
           wms_label_fields_vl wlf
      WHERE wlfv.label_format_id = p_label_format_id
      AND wlfv.label_field_id = wlf.label_field_id
      ORDER BY wlf.column_name, wlfv.field_variable_name;

   l_label_field_var c_label_field_var%ROWTYPE;
   l_column_count NUMBER := 1;
   l_prev_column_name VARCHAR2(60) := '';

BEGIN

   OPEN c_label_field_var;
   LOOP
      FETCH c_label_field_var INTO l_label_field_var;
      EXIT WHEN c_label_field_var%notfound;

      IF l_prev_column_name IS NULL OR
         l_prev_column_name <> l_label_field_var.column_name THEN
         l_prev_column_name := l_label_field_var.column_name;
         l_column_count := 1;
      ELSE
         l_column_count := l_column_count + 1;
      END IF;

      -- build the hash table with column_name concatenate count as key
      -- trace('*********** insert into hash table '|| l_label_field_var.column_name ||l_column_count||'  ************ ' || l_label_field_var.field_variable_name);
      g_field_elements_table(get_field_hash_value(l_label_field_var.column_name||l_column_count, g_get_hash_for_insert)).variable_name := l_label_field_var.field_variable_name;

      IF l_label_field_var.column_name = 'sql_stmt' THEN
         g_count_custom_sql := g_count_custom_sql + 1; -- Added for Bug#4179391
         g_field_elements_table(get_field_hash_value(l_label_field_var.column_name||l_column_count, g_get_hash_for_insert)).sql_stmt := l_label_field_var.sql_stmt;
      END IF;

   END LOOP;

   CLOSE c_label_field_var;

END build_format_fields_structure;

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--  This function get_sql_for_variable() is newly added for the Custom Labels project to     |
--  fetch the SQL statement from the PL/SQL table.                                           |
---------------------------------------------------------------------------------------------
FUNCTION get_sql_for_variable(p_column_name IN VARCHAR2, p_row_index IN NUMBER, p_format_id IN NUMBER)
RETURN VARCHAR2
IS

lv_sql_stmt VARCHAR2(4000);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  BEGIN
     lv_sql_stmt := g_field_elements_table(get_field_hash_value(p_column_name||(p_row_index+1), g_get_hash_for_retrieve)).sql_stmt;
     IF (l_debug = 1) THEN
         trace(' Inside get_sql_for_variable() lv_sql_stmt is: '|| lv_sql_stmt);
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
      lv_sql_stmt := NULL;
      IF (l_debug = 1) THEN
             trace(' Inside Exception Block of get_sql_for_variable() ');
      END IF;
  END;
  RETURN lv_sql_stmt;

END get_sql_for_variable;

/* Set value for total number of cartons for a delivery
      Get delivery_id for a certain cartonization_id
      Increment the total count for that delivery
   This is called by INV_LABEL for each cartonization_id
*/
PROCEDURE set_carton_count(p_cartonization_id NUMBER) IS

   CURSOR c_delivery(v_cartonization_id NUMBER) IS
      SELECT distinct wda.delivery_id
      FROM   wsh_delivery_assignments wda
           , wsh_delivery_details wdd
           , mtl_material_transactions_temp mmtt
      WHERE  mmtt.cartonization_id = v_cartonization_id
      AND    mmtt.move_order_line_id = wdd.move_order_line_id
      AND    wda.delivery_detail_id = wdd.delivery_detail_id;
   l_delivery_id NUMBER;
   i NUMBER;
   l_found VARCHAR2(1);

BEGIN
      --trace('In set_carton_count p_cartonization_id ='||p_cartonization_id);
      OPEN c_delivery(p_cartonization_id);
      FETCH c_delivery INTO l_delivery_id;
      CLOSE c_delivery;

      l_found := 'N';
      FOR i IN 1..g_carton_tb.count LOOP
         IF g_carton_tb(i).delivery_id = l_delivery_id THEN
            g_carton_tb(i).carton_count := g_carton_tb(i).carton_count + 1;
            g_carton_tb(i).carton_index := 1;
            l_found := 'Y';
            EXIT;
         END IF;
      END LOOP;

      IF ((g_carton_tb.count = 0) OR (l_found = 'N'))  THEN
         i := g_carton_tb.count + 1;
         g_carton_tb(i).delivery_id := l_delivery_id;
         g_carton_tb(i).carton_count := 1;
         g_carton_tb(i).carton_index := 1;
      END IF;


END set_carton_count;

PROCEDURE get_carton_count(
   p_delivery_id IN NUMBER
 , x_carton_total OUT NOCOPY NUMBER
 , x_carton_index OUT NOCOPY NUMBER) IS
   i NUMBER;
BEGIN
   FOR i IN 1..g_carton_tb.count LOOP
      IF g_carton_tb(i).delivery_id = p_delivery_id THEN
         x_carton_total := g_carton_tb(i).carton_count;
         x_carton_index := g_carton_tb(i).carton_index;
         g_carton_tb(i).carton_index := g_carton_tb(i).carton_index + 1;
         EXIT;
      END IF;
   END LOOP;
END get_carton_count;

PROCEDURE clear_carton_count IS
BEGIN
   g_carton_tb.delete;
END clear_carton_count;


PROCEDURE get_variable_data(
   x_variable_content   OUT NOCOPY INV_LABEL.label_tbl_type
,  x_msg_count          OUT NOCOPY NUMBER
,  x_msg_data           OUT NOCOPY VARCHAR2
,  x_return_status      OUT NOCOPY VARCHAR2
,  p_label_type_info    IN  INV_LABEL.label_type_rec
,  p_transaction_id     IN  NUMBER
,  p_input_param        IN  MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
,  p_transaction_identifier IN NUMBER
) IS


   CURSOR c_fields_for_format(v_label_format_id NUMBER) IS
     SELECT lbfl.column_name
       FROM wms_label_field_variables lbvar,
       wms_label_fields_vl lbfl
       WHERE lbfl.label_field_id = lbvar.label_field_id
       AND lbvar.label_format_id = v_label_format_id
       GROUP BY lbfl.column_name;

	--Standalone
    l_deploy_mode VARCHAR2(2) := WMS_DEPLOY.wms_deployment_mode;

   -- Get WDD with MMTT
   CURSOR c_wdd_mmtt(p_transaction_temp_id NUMBER, p_cartonization_id NUMBER) IS
      SELECT
          nvl(wdd.requested_quantity, mmtt.transaction_quantity)  requested_quantity
        , mmtt.transaction_quantity    shipped_quantity
        , mmtt.secondary_transaction_quantity shipped_quantity2
        , mmtt.transaction_uom       uom
        , mmtt.revision              revision
        , mmtt.lot_number            lot_number
        , wdd.cancelled_quantity
        , wdd.delivered_quantity
        , wdd.carrier_id
        , wdd.cust_po_number customer_purchase_order
        , wdd.customer_id
        , wdd.ship_method_code
        , NULL oe_ship_method_code
        , mmtt.organization_id
        , mmtt.subinventory_code from_subinventory
        , mmtt.locator_id        from_locator_id
        , milk.concatenated_segments from_locator
        , mmtt.transfer_subinventory to_subinventory
        , mmtt.transfer_to_location   to_locator_id
        , milk2.concatenated_segments to_locator
        --Standalone
		,decode(l_deploy_mode,
          'I', wdd.source_header_number,
          'D', wdd.reference_number,
          'L', wdd.reference_number) source_header_number
        ,decode(l_deploy_mode,
          'I', wdd.source_line_number,
          'D', wdd.reference_line_number,
          'L', wdd.reference_line_number) source_line_number
		--, wdd.source_header_number
        --, wdd.source_line_number
        , wdd.tracking_number
        , wdd.fob_code FOB
        , mmtt.inventory_item_id
        , wdd.customer_item_id
        , wdd.project_id
        , wdd.task_id
        , wda.delivery_id
        , wdd.ship_from_location_id
        , wdd.ship_to_location_id
        , wdd.ship_to_site_use_id
        , wdd.ship_to_contact_id
        , wdd.sold_to_contact_id
        , wdd.deliver_to_location_id
        , wdd.deliver_to_contact_id
        , wdd.deliver_to_site_use_id
        , oeol.header_id source_header_id
        , wdd.source_line_id
        , wdd.attribute_category
        , wdd.attribute1
        , wdd.attribute2
        , wdd.attribute3
        , wdd.attribute4
        , wdd.attribute5
        , wdd.attribute6
        , wdd.attribute7
        , wdd.attribute8
        , wdd.attribute9
        , wdd.attribute10
        , wdd.attribute11
        , wdd.attribute12
        , wdd.attribute13
        , wdd.attribute14
        , wdd.attribute15
        , wdd.tp_attribute_category
        , wdd.tp_attribute1
        , wdd.tp_attribute2
        , wdd.tp_attribute3
        , wdd.tp_attribute4
        , wdd.tp_attribute5
        , wdd.tp_attribute6
        , wdd.tp_attribute7
        , wdd.tp_attribute8
        , wdd.tp_attribute9
        , wdd.tp_attribute10
        , wdd.tp_attribute11
        , wdd.tp_attribute12
        , wdd.tp_attribute13
        , wdd.tp_attribute14
        , wdd.tp_attribute15
        , Nvl(mmtt.transfer_lpn_id, cartonization_id) outer_lpn_id
        , NULL number_of_total
        , NULL delivery_number  -- Place holder, get later with c_delivery
        , NULL waybill          -- Place holder, get later with c_delivery
        , NULL airbill          -- Place holder, get later with c_delivery
        , NULL bill_of_lading   -- Place holder, get later with c_delivery
        , NULL trip_number      -- Place holder, get later with c_delivery
        , NULL wnd_carrier_id       -- Place holder, get later with c_delivery
        , NULL wnd_ship_method_code -- Place holder, get later with c_delivery
        , NULL intmed_ship_to_location_id -- Place holder, get later with c_delivery
        , wdd.intmed_ship_to_contact_id
        , wdd.delivery_detail_id --Bug9261874

      FROM
        (SELECT mmtt1.inventory_item_id,
         mmtt1.organization_id,
         mmtt1.subinventory_code,
         mmtt1.locator_id,
         mmtt1.transfer_organization,
         mmtt1.transfer_to_location,
         mmtt1.transfer_subinventory,
         mmtt1.move_order_line_id,
         mmtt1.content_lpn_id,
         mmtt1.transfer_lpn_id,
         mmtt1.cartonization_id,
         mmtt1.transaction_temp_id,
         mmtt1.revision,
         mmtt1.transaction_uom,
         nvl(mtlt1.transaction_quantity, mmtt1.transaction_quantity) transaction_quantity,
         nvl(mtlt1.secondary_quantity, mmtt1.secondary_transaction_quantity) secondary_transaction_quantity, --Bug# 3596990
         mtlt1.lot_number
         FROM
         mtl_material_transactions_temp mmtt1,
         mtl_transaction_lots_temp mtlt1
         WHERE mmtt1.transaction_temp_id = mtlt1.transaction_temp_id(+)
         ) mmtt,  -- mmtt with lot number information
         wsh_delivery_details wdd,
         wsh_delivery_assignments_v wda,
         mtl_item_locations_kfv milk,
         mtl_item_locations_kfv milk2,
         oe_order_lines_all oeol
        WHERE ((mmtt.transaction_temp_id   = p_transaction_temp_id AND
                p_transaction_temp_id IS NOT NULL) OR
               (mmtt.cartonization_id      = p_cartonization_id AND
                p_cartonization_id IS NOT NULL))
        AND   mmtt.move_order_line_id    = wdd.move_order_line_id
        AND   wda.delivery_detail_id     = wdd.delivery_detail_id
        AND   wdd.released_status        = 'S'
        AND   mmtt.organization_id       = milk.organization_id (+)
        AND   mmtt.locator_id            = milk.inventory_location_id(+)
        AND   mmtt.transfer_organization = milk2.organization_id (+)
        AND   mmtt.transfer_to_location  = milk2.inventory_location_id(+)
        AND   wdd.source_line_id         = oeol.line_id(+)
        ORDER BY mmtt.inventory_item_id, mmtt.lot_number;

-- Added for bug 8454264 8486711 start

          CURSOR c_cust_details(p_delivery_detail_id NUMBER) IS
                 SELECT acct_site.cust_acct_site_id  cust_site_id
                    from wsh_delivery_details wdd
                      , wsh_delivery_assignments wda
                      , hz_cust_site_uses_all hcsua
                      , hz_party_sites party_site
                      , hz_loc_assignments loc_assign
                      , hz_locations loc
                      , hz_cust_acct_sites_all acct_site
                    where wdd.delivery_detail_id = wda.delivery_detail_id
                      and wdd.container_flag = 'N'
                      AND wda.delivery_id=p_delivery_detail_id
                      and hcsua.site_use_id = wdd.ship_to_site_use_id
                      and acct_site.cust_acct_site_id = hcsua.cust_acct_site_id
                      AND acct_site.party_site_id = party_site.party_site_id
                      AND loc.location_id = party_site.location_id
                      AND loc.location_id = loc_assign.location_id
                      AND NVL ( acct_site.org_id, -99 )  = NVL ( loc_assign.org_id, -99 )
                      AND ROWNUM=1;

 -- Added for bug 8454264 8486711 end


   -- Cursor to get WDD records with outermost LPN ID
   CURSOR c_wdd_lpn(p_lpn_id NUMBER) IS
      SELECT wdd_item.requested_quantity
         ,wdd_item.shipped_quantity
         ,wdd_item.shipped_quantity2
         ,wdd_item.requested_quantity_uom uom
         ,wdd_item.revision
         ,wdd_item.lot_number
         ,wdd_item.cancelled_quantity
         ,wdd_item.delivered_quantity
         ,wdd_item.carrier_id
         ,wdd_item.cust_po_number customer_purchase_order
         ,wdd_item.customer_id
         ,wdd_item.ship_method_code
         ,to_char(NULL)     oe_ship_method_code
         ,wdd_item.organization_id
         ,to_char(NULL)     from_subinventory
         ,to_number(NULL)   from_locator_id
         ,to_char(NULL)     from_locator
         ,to_char(NULL)     to_subinventory  -- get it later from LPN
         ,to_number(NULL)   to_locator_id    -- get it later from LPN
         ,to_char(NULL)     to_locator       -- get it later from LPN
		 --Standalone
		 ,decode(l_deploy_mode,
          'I', wdd_item.source_header_number,
          'D', wdd_item.reference_number,
          'L', wdd_item.reference_number) source_header_number
        ,decode(l_deploy_mode,
          'I', wdd_item.source_line_number,
          'D', wdd_item.reference_line_number,
          'L', wdd_item.reference_line_number) source_line_number
		 --,wdd_item.source_header_number
         --,wdd_item.source_line_number
         ,wdd_item.tracking_number
         ,wdd_item.fob_code FOB
         ,wdd_item.inventory_item_id
         ,wdd_item.customer_item_id
         ,wdd_item.project_id
         ,wdd_item.task_id
         ,wda.delivery_id
         ,wdd_item.ship_from_location_id
         ,wdd_item.ship_to_location_id
         ,wdd_item.ship_to_site_use_id
         ,wdd_item.ship_to_contact_id
         ,wdd_item.sold_to_contact_id
         ,wdd_item.deliver_to_location_id
         ,wdd_item.deliver_to_contact_id
         ,wdd_item.deliver_to_site_use_id
         ,oeol.header_id source_header_id
         ,wdd_item.source_line_id
         ,wdd_item.attribute_category
         ,wdd_item.attribute1
         ,wdd_item.attribute2
         ,wdd_item.attribute3
         ,wdd_item.attribute4
         ,wdd_item.attribute5
         ,wdd_item.attribute6
         ,wdd_item.attribute7
         ,wdd_item.attribute8
         ,wdd_item.attribute9
         ,wdd_item.attribute10
         ,wdd_item.attribute11
         ,wdd_item.attribute12
         ,wdd_item.attribute13
         ,wdd_item.attribute14
         ,wdd_item.attribute15
         ,wdd_item.tp_attribute_category
         ,wdd_item.tp_attribute1
         ,wdd_item.tp_attribute2
         ,wdd_item.tp_attribute3
         ,wdd_item.tp_attribute4
         ,wdd_item.tp_attribute5
         ,wdd_item.tp_attribute6
         ,wdd_item.tp_attribute7
         ,wdd_item.tp_attribute8
         ,wdd_item.tp_attribute9
         ,wdd_item.tp_attribute10
         ,wdd_item.tp_attribute11
         ,wdd_item.tp_attribute12
         ,wdd_item.tp_attribute13
         ,wdd_item.tp_attribute14
         ,wdd_item.tp_attribute15
         ,wlpn.outermost_lpn_id outer_lpn_id
         ,NULL number_of_total
         ,NULL delivery_number  -- Place holder, get later with c_delivery
         ,NULL waybill          -- Place holder, get later with c_delivery
         ,NULL airbill          -- Place holder, get later with c_delivery
         ,NULL bill_of_lading   -- Place holder, get later with c_delivery
         ,NULL trip_number      -- Place holder, get later with c_delivery
         ,NULL wnd_carrier_id       -- Place holder, get later with c_delivery
         ,NULL wnd_ship_method_code -- Place holder, get later with c_delivery
         ,NULL intmed_ship_to_location_id -- Place holder, get later with c_delivery
         ,wdd_item.intmed_ship_to_contact_id
         ,wdd_item.delivery_detail_id --Bug9261874
      FROM wsh_delivery_details wdd_item -- records with item info
         , wsh_delivery_details wdd_lpn  -- records of the immediate lpn
         , wsh_delivery_assignments_v wda
         , oe_order_lines_all oeol
         , wms_license_plate_numbers wlpn
      WHERE wda.delivery_detail_id = wdd_item.delivery_detail_id
      AND   wda.parent_delivery_detail_id = wdd_lpn.delivery_detail_id
      AND   (wdd_item.inventory_item_id IS NOT NULL AND
             wdd_item.lpn_id IS NULL)
      AND   wdd_lpn.lpn_id IN
            (SELECT wlpn2.lpn_id
             FROM wms_license_plate_numbers wlpn2
             WHERE wlpn2.outermost_lpn_id = wlpn.outermost_lpn_id)
      AND   wlpn.lpn_id = p_lpn_id
      AND   wdd_item.source_line_id         = oeol.line_id(+)
      AND   wdd_item.organization_id        = wlpn.organization_id /*9180228*/
      ORDER BY wdd_item.inventory_item_id, wdd_item.lot_number;

   -- Get WDD records with delivery ID
   -- WMS org: join to LPN table
   CURSOR c_wdd_del_wms(p_delivery_id NUMBER) IS
      SELECT wdd_item.requested_quantity
         ,wdd_item.shipped_quantity
         ,wdd_item.shipped_quantity2
         ,wdd_item.requested_quantity_uom uom
         ,wdd_item.revision
         ,wdd_item.lot_number
         ,wdd_item.cancelled_quantity --Added bug3952110  -- about LPN contains multiple splitted line from del det. sum qty
         ,wdd_item.delivered_quantity
         ,wdd_item.carrier_id
         ,wdd_item.cust_po_number customer_purchase_order
         ,wdd_item.customer_id
         ,wdd_item.ship_method_code
         ,NULL     oe_ship_method_code
         ,wdd_item.organization_id
         ,NULL     from_subinventory
         ,NULL     from_locator_id
         ,NULL     from_locator
         ,NULL     to_subinventory  -- get it later from LPN
         ,NULL     to_locator_id    -- get it later from LPN
         ,NULL     to_locator       -- get it later from LPN
		--Standalone
		,decode(l_deploy_mode,
          'I', wdd_item.source_header_number,
          'D', wdd_item.reference_number,
          'L', wdd_item.reference_number) source_header_number
        ,decode(l_deploy_mode,
          'I', wdd_item.source_line_number,
          'D', wdd_item.reference_line_number,
          'L', wdd_item.reference_line_number) source_line_number
         --,wdd_item.source_header_number
         --,wdd_item.source_line_number
         ,wdd_item.tracking_number
         ,wdd_item.fob_code FOB
         ,wdd_item.inventory_item_id
         ,wdd_item.customer_item_id
         ,wdd_item.project_id
         ,wdd_item.task_id
         ,wda.delivery_id
         ,wdd_item.ship_from_location_id
         ,wdd_item.ship_to_location_id
         ,wdd_item.ship_to_site_use_id
         ,wdd_item.ship_to_contact_id
         ,wdd_item.deliver_to_location_id
         ,wdd_item.deliver_to_contact_id
         ,wdd_item.deliver_to_site_use_id
         ,wdd_item.sold_to_contact_id
         ,oeol.header_id source_header_id
         ,wdd_item.source_line_id
         ,wdd_item.attribute_category
         ,wdd_item.attribute1
         ,wdd_item.attribute2
         ,wdd_item.attribute3
         ,wdd_item.attribute4
         ,wdd_item.attribute5
         ,wdd_item.attribute6
         ,wdd_item.attribute7
         ,wdd_item.attribute8
         ,wdd_item.attribute9
         ,wdd_item.attribute10
         ,wdd_item.attribute11
         ,wdd_item.attribute12
         ,wdd_item.attribute13
         ,wdd_item.attribute14
         ,wdd_item.attribute15
         ,wdd_item.tp_attribute_category
         ,wdd_item.tp_attribute1
         ,wdd_item.tp_attribute2
         ,wdd_item.tp_attribute3
         ,wdd_item.tp_attribute4
         ,wdd_item.tp_attribute5
         ,wdd_item.tp_attribute6
         ,wdd_item.tp_attribute7
         ,wdd_item.tp_attribute8
         ,wdd_item.tp_attribute9
         ,wdd_item.tp_attribute10
         ,wdd_item.tp_attribute11
         ,wdd_item.tp_attribute12
         ,wdd_item.tp_attribute13
         ,wdd_item.tp_attribute14
         ,wdd_item.tp_attribute15
         ,wlpn.outermost_lpn_id outer_lpn_id
         ,NULL number_of_total
         ,NULL delivery_number  -- Place holder, get later with c_delivery
         ,NULL waybill          -- Place holder, get later with c_delivery
         ,NULL airbill          -- Place holder, get later with c_delivery
         ,NULL bill_of_lading   -- Place holder, get later with c_delivery
         ,NULL trip_number      -- Place holder, get later with c_delivery
         ,NULL wnd_carrier_id       -- Place holder, get later with c_delivery
         ,NULL wnd_ship_method_code -- Place holder, get later with c_delivery
         ,NULL intmed_ship_to_location_id -- Place holder, get later with c_delivery
         ,wdd_item.intmed_ship_to_contact_id
         ,wdd_item.delivery_detail_id  --Bug9261874
      FROM wsh_delivery_details wdd_item -- records with item info
         , wsh_delivery_details wdd_lpn  -- records of the immediate lpn
         , wms_license_plate_numbers wlpn
         , wsh_delivery_assignments_v wda
         , oe_order_lines_all oeol
      WHERE wda.delivery_detail_id = wdd_item.delivery_detail_id
      AND   (wdd_item.inventory_item_id IS NOT NULL AND
             wdd_item.lpn_id IS NULL)
      AND   wda.parent_delivery_detail_id = wdd_lpn.delivery_detail_id
      AND   wdd_lpn.lpn_id = wlpn.lpn_id
      AND   wda.delivery_id = p_delivery_id
      AND   wdd_item.source_line_id         = oeol.line_id(+)
      ORDER BY wlpn.outermost_lpn_id, wdd_item.inventory_item_id, wdd_item.lot_number;

   -- Get WDD records with delivery ID
   -- Non WMS org: no LPN related
   CURSOR c_wdd_del_inv(p_delivery_id NUMBER) IS
      SELECT wdd_item.requested_quantity
         ,wdd_item.shipped_quantity
         ,wdd_item.shipped_quantity2
         ,wdd_item.requested_quantity_uom uom
         ,wdd_item.revision
         ,wdd_item.lot_number
         ,wdd_item.cancelled_quantity --Added bug3952110  -- about LPN contains multiple splitted line from del det. sum qty
         ,wdd_item.delivered_quantity
         ,wdd_item.carrier_id
         ,wdd_item.cust_po_number customer_purchase_order
         ,wdd_item.customer_id
         ,wdd_item.ship_method_code
         ,NULL     oe_ship_method_code
         ,wdd_item.organization_id
         ,NULL     from_subinventory
         ,NULL     from_locator_id
         ,NULL     from_locator
         ,wdd_item.subinventory      to_subinventory
         ,wdd_item.locator_id        to_locator_id
         ,milk.concatenated_segments to_locator
		 --Standalone
		 ,decode(l_deploy_mode,
           'I', wdd_item.source_header_number,
           'D', wdd_item.reference_number,
           'L', wdd_item.reference_number) source_header_number
         ,decode(l_deploy_mode,
           'I', wdd_item.source_line_number,
           'D', wdd_item.reference_line_number,
           'L', wdd_item.reference_line_number) source_line_number
          --,wdd_item.source_header_number
          --,wdd_item.source_line_number
         ,wdd_item.tracking_number
         ,wdd_item.fob_code FOB
         ,wdd_item.inventory_item_id
         ,wdd_item.customer_item_id
         ,wdd_item.project_id
         ,wdd_item.task_id
         ,wda.delivery_id
         ,wdd_item.ship_from_location_id
         ,wdd_item.ship_to_location_id
         ,wdd_item.ship_to_site_use_id
         ,wdd_item.ship_to_contact_id
         ,wdd_item.sold_to_contact_id
         ,wdd_item.deliver_to_location_id
         ,wdd_item.deliver_to_contact_id
         ,wdd_item.deliver_to_site_use_id
         ,oeol.header_id source_header_id
         ,wdd_item.source_line_id
         ,wdd_item.attribute_category
         ,wdd_item.attribute1
         ,wdd_item.attribute2
         ,wdd_item.attribute3
         ,wdd_item.attribute4
         ,wdd_item.attribute5
         ,wdd_item.attribute6
         ,wdd_item.attribute7
         ,wdd_item.attribute8
         ,wdd_item.attribute9
         ,wdd_item.attribute10
         ,wdd_item.attribute11
         ,wdd_item.attribute12
         ,wdd_item.attribute13
         ,wdd_item.attribute14
         ,wdd_item.attribute15
         ,wdd_item.tp_attribute_category
         ,wdd_item.tp_attribute1
         ,wdd_item.tp_attribute2
         ,wdd_item.tp_attribute3
         ,wdd_item.tp_attribute4
         ,wdd_item.tp_attribute5
         ,wdd_item.tp_attribute6
         ,wdd_item.tp_attribute7
         ,wdd_item.tp_attribute8
         ,wdd_item.tp_attribute9
         ,wdd_item.tp_attribute10
         ,wdd_item.tp_attribute11
         ,wdd_item.tp_attribute12
         ,wdd_item.tp_attribute13
         ,wdd_item.tp_attribute14
         ,wdd_item.tp_attribute15
         ,NULL outer_lpn_id
         ,NULL number_of_total
         ,NULL delivery_number  -- Place holder, get later with c_delivery
         ,NULL waybill          -- Place holder, get later with c_delivery
         ,NULL airbill          -- Place holder, get later with c_delivery
         ,NULL bill_of_lading   -- Place holder, get later with c_delivery
         ,NULL trip_number      -- Place holder, get later with c_delivery
         ,NULL wnd_carrier_id       -- Place holder, get later with c_delivery
         ,NULL wnd_ship_method_code -- Place holder, get later with c_delivery
         ,NULL intmed_ship_to_location_id -- Place holder, get later with c_delivery
         ,wdd_item.intmed_ship_to_contact_id
         ,wdd_item.delivery_detail_id  --Bug9261874
      FROM wsh_delivery_details wdd_item -- records with item info
         , wsh_delivery_assignments_v wda
         , mtl_item_locations_kfv  milk
         , oe_order_lines_all oeol
      WHERE wda.delivery_detail_id = wdd_item.delivery_detail_id
      AND   (wdd_item.inventory_item_id IS NOT NULL AND
             wdd_item.lpn_id IS NULL)
      AND   wda.delivery_id = p_delivery_id
      AND   wdd_item.organization_id = milk.organization_id (+)
      AND   wdd_item.locator_id      = milk.inventory_location_id(+)
      AND   wdd_item.source_line_id       = oeol.line_id(+)
      ORDER BY wdd_item.inventory_item_id, wdd_item.lot_number;

   CURSOR c_delivery(p_delivery_id NUMBER) IS
      SELECT  wnd.name             delivery_number
            , wnd.waybill          waybill
            , wnd.waybill          airbill
            , wdi.sequence_number  bill_of_lading
            , wt.name              trip_number
            -- Bug 5121507, Get carrier in the order of Trip->Delivery->Delivery Detail
            --, nvl(wnd.carrier_id, wt.carrier_id) wnd_carrier_id
            , nvl(wt.carrier_id, wnd.carrier_id) wnd_carrier_id
            , wnd.ship_method_code wnd_ship_method_code
            , wnd.intmed_ship_to_location_id
      FROM wsh_new_deliveries      wnd
        ,  wsh_delivery_legs       wdl
        ,  wsh_document_instances  wdi
        ,  wsh_trip_stops          wts
        ,  wsh_trips               wt
      WHERE  wnd.delivery_id       = wdl.delivery_id(+)
      AND    wdi.entity_name  (+)  = 'WSH_DELIVERY_LEGS'
      AND    wdl.delivery_leg_id   = wdi.entity_id  (+)
      AND    wdl.pick_up_stop_id   = wts.stop_id (+)
      AND    wts.trip_id           = wt.trip_id (+)
      AND    wnd.delivery_id       = p_delivery_id;

   CURSOR c_org_code(p_organization_id NUMBER) IS
      SELECT organization_code
      FROM mtl_parameters
      WHERE organization_id = p_organization_id;

   CURSOR c_org_name(p_organization_id NUMBER) IS
      SELECT hou.name organization_name
           , loc.telephone_number_1 org_tel_num
           , loc.telephone_number_2 org_fax_num
      FROM hr_organization_units hou
         , hr_locations_all_v loc
      WHERE hou.organization_id = p_organization_id
      AND   hou.location_id = loc.location_id (+);


   CURSOR c_wdd_outer_lpn(p_lpn_id NUMBER) IS
      SELECT  wdd.load_seq_number
            , wdd.net_weight
            , wdd.gross_weight
            , wdd.tracking_number
            , wdd.gross_weight
            , wdd.weight_uom_code
            , (wdd.gross_weight - wdd.net_weight) tare_weight
            , wdd.weight_uom_code tare_weight_uom
            , wdd.volume
            , wdd.volume_uom_code
      FROM wsh_delivery_details wdd
      WHERE lpn_id = p_lpn_id;

   CURSOR c_item(p_organization_id NUMBER, p_inventory_item_id NUMBER) IS
      SELECT msik.concatenated_segments
            ,WMS_DEPLOY.GET_CLIENT_ITEM(p_organization_id,p_inventory_item_id)			-- Added for LSP Project, bug 9087971
            ,msik.description
            ,msik.secondary_uom_code
            ,msik.attribute_category
            ,msik.attribute1
            ,msik.attribute2
            ,msik.attribute3
            ,msik.attribute4
            ,msik.attribute5
            ,msik.attribute6
            ,msik.attribute7
            ,msik.attribute8
            ,msik.attribute9
            ,msik.attribute10
            ,msik.attribute11
            ,msik.attribute12
            ,msik.attribute13
            ,msik.attribute14
            ,msik.attribute15
            ,poh.hazard_class
      FROM  mtl_system_items_kfv msik
           ,po_hazard_classes poh
      WHERE msik.organization_id   = p_organization_id
      AND   msik.inventory_item_id = p_inventory_item_id
      AND   msik.hazard_class_id   = poh.hazard_class_id(+);

   CURSOR c_customer_item(p_customer_item_id NUMBER) IS
      SELECT
          mci.customer_item_number
        , mci.attribute_category
        , mci.attribute1
        , mci.attribute2
        , mci.attribute3
        , mci.attribute4
        , mci.attribute5
        , mci.attribute6
        , mci.attribute7
        , mci.attribute8
        , mci.attribute9
        , mci.attribute10
        , mci.attribute11
        , mci.attribute12
        , mci.attribute13
        , mci.attribute14
        , mci.attribute15
      FROM mtl_customer_items mci
      WHERE mci.customer_item_id = p_customer_item_id;

   CURSOR c_lot_number(p_organization_id NUMBER, p_inventory_item_id NUMBER, p_lot_number VARCHAR2) IS
      SELECT
          mmst.status_code           lot_number_status
        , to_char(mln.expiration_date, G_DATE_FORMAT_MASK) lot_expiration_date
        , mln.lot_attribute_category lot_attribute_category
        , mln.c_attribute1           lot_c_attribute1
        , mln.c_attribute2           lot_c_attribute2
        , mln.c_attribute3           lot_c_attribute3
        , mln.c_attribute4           lot_c_attribute4
        , mln.c_attribute5           lot_c_attribute5
        , mln.c_attribute6           lot_c_attribute6
        , mln.c_attribute7           lot_c_attribute7
        , mln.c_attribute8           lot_c_attribute8
        , mln.c_attribute9           lot_c_attribute9
        , mln.c_attribute10          lot_c_attribute10
        , mln.c_attribute11          lot_c_attribute11
        , mln.c_attribute12          lot_c_attribute12
        , mln.c_attribute13          lot_c_attribute13
        , mln.c_attribute14          lot_c_attribute14
        , mln.c_attribute15          lot_c_attribute15
        , mln.c_attribute16          lot_c_attribute16
        , mln.c_attribute17          lot_c_attribute17
        , mln.c_attribute18          lot_c_attribute18
        , mln.c_attribute19          lot_c_attribute19
        , mln.c_attribute20          lot_c_attribute20
        , to_char(mln.D_ATTRIBUTE1, G_DATE_FORMAT_MASK) lot_d_attribute1
        , to_char(mln.D_ATTRIBUTE2, G_DATE_FORMAT_MASK) lot_d_attribute2
        , to_char(mln.D_ATTRIBUTE3, G_DATE_FORMAT_MASK) lot_d_attribute3
        , to_char(mln.D_ATTRIBUTE4, G_DATE_FORMAT_MASK) lot_d_attribute4
        , to_char(mln.D_ATTRIBUTE5, G_DATE_FORMAT_MASK) lot_d_attribute5
        , to_char(mln.D_ATTRIBUTE6, G_DATE_FORMAT_MASK) lot_d_attribute6
        , to_char(mln.D_ATTRIBUTE7, G_DATE_FORMAT_MASK) lot_d_attribute7
        , to_char(mln.D_ATTRIBUTE8, G_DATE_FORMAT_MASK) lot_d_attribute8
        , to_char(mln.D_ATTRIBUTE9, G_DATE_FORMAT_MASK) lot_d_attribute9
        , to_char(mln.D_ATTRIBUTE10, G_DATE_FORMAT_MASK) lot_d_attribute10
        , mln.n_attribute1           lot_n_attribute1
        , mln.n_attribute2           lot_n_attribute2
        , mln.n_attribute3           lot_n_attribute3
        , mln.n_attribute4           lot_n_attribute4
        , mln.n_attribute5           lot_n_attribute5
        , mln.n_attribute6           lot_n_attribute6
        , mln.n_attribute7           lot_n_attribute7
        , mln.n_attribute8           lot_n_attribute8
        , mln.n_attribute9           lot_n_attribute9
        , mln.n_attribute10          lot_n_attribute10
        , mln.territory_code         lot_country_of_origin
        , mln.grade_code             lot_grade_code
        , to_char(mln.ORIGINATION_DATE, G_DATE_FORMAT_MASK) lot_origination_date
        , mln.DATE_CODE             lot_date_code
        , to_char(mln.CHANGE_DATE, G_DATE_FORMAT_MASK) lot_change_date
        , mln.AGE               lot_age
        , to_char(mln.RETEST_DATE, G_DATE_FORMAT_MASK) lot_retest_date
        , to_char(mln.MATURITY_DATE, G_DATE_FORMAT_MASK) lot_maturity_date
        , mln.ITEM_SIZE       lot_item_size
        , mln.COLOR        lot_color
        , mln.VOLUME       lot_volume
        , mln.VOLUME_UOM         lot_volume_uom
        , mln.PLACE_OF_ORIGIN    lot_place_of_origin
        , to_char(mln.BEST_BY_DATE, G_DATE_FORMAT_MASK) lot_best_by_date
        , mln.length                 lot_length
        , mln.length_uom             lot_length_uom
        , mln.recycled_content       lot_recycled_cont
        , mln.thickness              lot_thickness
        , mln.thickness_uom          lot_thickness_uom
        , mln.width                  lot_width
        , mln.width_uom              lot_width_uom
        , mln.curl_wrinkle_fold      lot_curl
        , mln.vendor_name            lot_vendor
        , mln.parent_lot_number      parent_lot_number
        , mln.expiration_action_date expiration_action_date
        , ml.meaning                 origination_type
        , mln.hold_date              hold_date
        , mln.expiration_action_code expiration_action_code
        , mln.supplier_lot_number    supplier_lot_number
      FROM mtl_lot_numbers mln,
           mtl_material_statuses_b mmsb,
           mtl_material_statuses_tl mmst,
           mfg_lookups ml
      WHERE mln.organization_id   = p_organization_id
      AND   mln.inventory_item_id = p_inventory_item_id
      AND   mln.lot_number        = p_lot_number
      AND   mln.status_id         = mmsb.status_id(+)
      AND   mmsb.status_id        = mmst.status_id(+)
      AND   mmst.language(+)      = USERENV('LANG')
      AND   ml.lookup_type(+)     = 'MTL_LOT_ORIGINATION_TYPE'
      AND   ml.lookup_code(+)     = mln.origination_type;

   CURSOR c_customer(p_customer_id NUMBER) IS
      SELECT substrb(party.party_name,1,50) customer_name,
             cust_acct.account_number customer_number
      FROM hz_parties party
         , hz_cust_accounts cust_acct
      WHERE cust_acct.party_id = party.party_id
      AND   cust_acct.cust_account_id = p_customer_id;

   CURSOR c_project(p_project_id NUMBER) IS
      SELECT name
      FROM pa_projects_all
      WHERE project_id = p_project_id;

   CURSOR c_task(p_task_id NUMBER) IS
      SELECT task_name
      FROM pa_tasks
      WHERE task_id = p_task_id;

   CURSOR c_lpn(p_lpn_id NUMBER) IS
      SELECT    wlpn.license_plate_number
              , wlpn.content_volume
              , wlpn.content_volume_uom_code
              , wlpn.gross_weight
              , wlpn.gross_weight_uom_code
              , wlpn.tare_weight
              , wlpn.tare_weight_uom_code
              , wlpn.subinventory_code
              , wlpn.locator_id
              , milk.concatenated_segments locator
              , wlpn.attribute_category
              , wlpn.attribute1
              , wlpn.attribute2
              , wlpn.attribute3
              , wlpn.attribute4
              , wlpn.attribute5
              , wlpn.attribute6
              , wlpn.attribute7
              , wlpn.attribute8
              , wlpn.attribute9
              , wlpn.attribute10
              , wlpn.attribute11
              , wlpn.attribute12
              , wlpn.attribute13
              , wlpn.attribute14
              , wlpn.attribute15
              , msik.concatenated_segments lpn_container_item
      FROM    wms_license_plate_numbers wlpn
            , mtl_system_items_kfv msik
            , mtl_item_locations_kfv milk
      WHERE wlpn.lpn_id = p_lpn_id
      AND   msik.organization_id(+) = wlpn.organization_id
      AND   msik.inventory_item_id(+) = wlpn.inventory_item_id
      AND   milk.organization_id(+) = wlpn.organization_id
      AND   milk.inventory_location_id(+) = wlpn.locator_id;

   CURSOR c_carrier(p_carrier_id NUMBER) IS
      SELECT carrier_name
      FROM   wsh_carriers_v
      WHERE  carrier_id = p_carrier_id;

   CURSOR c_ship_method(p_ship_method_code VARCHAR2) IS
      SELECT meaning
      FROM fnd_common_lookups
      WHERE lookup_type='SHIP_METHOD'
      AND lookup_code = p_ship_method_code
      AND ROWNUM<2;

   CURSOR c_address(p_location_id NUMBER) IS
      SELECT hr.address_line_1
           , hr.address_line_2
           , hr.address_line_3
           , hr.address_line_4
           , hr.city
           , hr.postal_code
           , hr.state
           , hr.county
           , hr.country
           , hr.province
           , hr.location_code
           , hr.location_description
      FROM (SELECT loc.location_id location_id,loc.address_line_1 address_line_1
                  ,loc.address_line_2 address_line_2,loc.address_line_3 address_line_3
                  ,loc.loc_information13 address_line_4,loc.town_or_city city
                  ,loc.postal_code postal_code,loc.region_2 state,loc.region_1 county
                  ,loc.country country,loc.region_3 province, loc.location_code location_code
                  ,loc.description location_description
            FROM hr_locations_all loc
            UNION ALL
            SELECT hz.location_id location_id,hz.address1    address_line_1
                  ,hz.address2    address_line_2,hz.address3  address_line_3
                  ,hz.address4    address_line_4,hz.city city,hz.postal_code postal_code
                  ,hz.state state,hz.county county,hz.country country,hz.province province
                  ,hz.description location_code, hz.description location_description
            FROM hz_locations hz)  hr
       WHERE hr.location_id = p_location_id;

   CURSOR c_location(p_site_use_id NUMBER) IS
      SELECT location
      FROM hz_cust_site_uses_all
      WHERE site_use_id = p_site_use_id;

   CURSOR c_phone_fax(p_location_id NUMBER, p_type VARCHAR2) IS
      SELECT hcp.phone_country_code||decode(hcp.phone_country_code, NULL, '',' ')||
         decode(hcp.phone_area_code,NULL,'','(')||hcp.phone_area_code||decode(hcp.phone_area_code,NULL,'',')')||
         hcp.phone_number customer_site_tel_number
      FROM   hz_party_sites hps, hz_locations hl, hz_contact_points hcp
      WHERE  hps.location_id = hl.location_id
      AND    hcp.owner_table_name = 'HZ_PARTY_SITES'
      AND    hcp.owner_table_id = hps.party_site_id
      AND    (((hcp.phone_line_type IN ('PHONE','GEN')) AND (p_type = 'PHONE')) OR
              ((hcp.phone_line_type IN ('FAX')) AND (p_type = 'FAX')))
      AND    hps.location_id = p_location_id;

   CURSOR c_contact(p_contact_id NUMBER) IS
      SELECT ra_cont.last_name || decode(ra_cont.last_name, NULL, NULL, ', ')
             || ra_cont.first_name contact_name
      FROM ( SELECT ACCT_ROLE.cust_account_role_id        contact_id,
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
           ) ra_cont
      WHERE ra_cont.contact_id = p_contact_id;

   CURSOR c_so_line(p_line_id NUMBER) IS
      SELECT
          to_char(oeol.SCHEDULE_SHIP_DATE, G_DATE_FORMAT_MASK)
        , to_char(oeol.REQUEST_DATE, G_DATE_FORMAT_MASK)
        , to_char(oeol.PROMISE_DATE, G_DATE_FORMAT_MASK)
        , oeol.SHIPMENT_PRIORITY_CODE
        , oeol.shipping_method_code
        , oeol.FREIGHT_CARRIER_CODE
        , to_char(oeol.SCHEDULE_ARRIVAL_DATE, G_DATE_FORMAT_MASK)
        , to_char(oeol.ACTUAL_SHIPMENT_DATE, G_DATE_FORMAT_MASK)
        , oeol.SHIPPING_INSTRUCTIONS
        , oeol.PACKING_INSTRUCTIONS
        , oeol.attribute1
        , oeol.attribute2
        , oeol.attribute3
        , oeol.attribute4
        , oeol.attribute5
        , oeol.attribute6
        , oeol.attribute7
        , oeol.attribute8
        , oeol.attribute9
        , oeol.attribute10
        , oeol.attribute11
        , oeol.attribute12
        , oeol.attribute13
        , oeol.attribute14
        , oeol.attribute15
        , oeol.global_attribute1
        , oeol.global_attribute2
        , oeol.global_attribute3
        , oeol.global_attribute4
        , oeol.global_attribute5
        , oeol.global_attribute6
        , oeol.global_attribute7
        , oeol.global_attribute8
        , oeol.global_attribute9
        , oeol.global_attribute10
        , oeol.global_attribute11
        , oeol.global_attribute12
        , oeol.global_attribute13
        , oeol.global_attribute14
        , oeol.global_attribute15
        , oeol.global_attribute16
        , oeol.global_attribute17
        , oeol.global_attribute18
        , oeol.global_attribute19
        , oeol.global_attribute20
        , oeol.pricing_attribute1
        , oeol.pricing_attribute2
        , oeol.pricing_attribute3
        , oeol.pricing_attribute4
        , oeol.pricing_attribute5
        , oeol.pricing_attribute6
        , oeol.pricing_attribute7
        , oeol.pricing_attribute8
        , oeol.pricing_attribute9
        , oeol.pricing_attribute10
        , oeol.industry_attribute1
        , oeol.industry_attribute2
        , oeol.industry_attribute3
        , oeol.industry_attribute4
        , oeol.industry_attribute5
        , oeol.industry_attribute6
        , oeol.industry_attribute7
        , oeol.industry_attribute8
        , oeol.industry_attribute9
        , oeol.industry_attribute10
        , oeol.industry_attribute11
        , oeol.industry_attribute13
        , oeol.industry_attribute12
        , oeol.industry_attribute14
        , oeol.industry_attribute15
        , oeol.industry_attribute16
        , oeol.industry_attribute17
        , oeol.industry_attribute18
        , oeol.industry_attribute19
        , oeol.industry_attribute20
        , oeol.industry_attribute21
        , oeol.industry_attribute22
        , oeol.industry_attribute23
        , oeol.industry_attribute24
        , oeol.industry_attribute25
        , oeol.industry_attribute26
        , oeol.industry_attribute27
        , oeol.industry_attribute28
        , oeol.industry_attribute29
        , oeol.industry_attribute30
        , oeol.return_attribute1
        , oeol.return_attribute2
        , oeol.return_attribute3
        , oeol.return_attribute4
        , oeol.return_attribute5
        , oeol.return_attribute6
        , oeol.return_attribute7
        , oeol.return_attribute8
        , oeol.return_attribute9
        , oeol.return_attribute10
        , oeol.return_attribute11
        , oeol.return_attribute12
        , oeol.return_attribute13
        , oeol.return_attribute14
        , oeol.return_attribute15
        , oeol.tp_attribute1
        , oeol.tp_attribute2
        , oeol.tp_attribute3
        , oeol.tp_attribute4
        , oeol.tp_attribute5
        , oeol.tp_attribute6
        , oeol.tp_attribute7
        , oeol.tp_attribute8
        , oeol.tp_attribute9
        , oeol.tp_attribute10
        , oeol.tp_attribute11
        , oeol.tp_attribute12
        , oeol.tp_attribute13
        , oeol.tp_attribute14
        , oeol.tp_attribute15
        , Nvl(oeol.ordered_item,
         Decode(oeol.item_identifier_type,
           'CUST', mci_oi.customer_item_number,
           'INT', msik_oi.concatenated_segments,
           msik_oi.concatenated_segments)) ordered_item
      FROM oe_order_lines_all       oeol
        ,  mtl_customer_items       mci_oi
        ,  mtl_system_items_kfv     msik_oi
      WHERE oeol.line_id           = p_line_id
        AND oeol.ordered_item_id   = mci_oi.customer_item_id (+)
        AND oeol.ordered_item_id   = msik_oi.inventory_item_id (+)
        AND oeol.org_id            = msik_oi.organization_id (+);

   CURSOR c_so_header(p_header_id NUMBER) IS
      SELECT
          oeoh.attribute1
        , oeoh.attribute2
        , oeoh.attribute3
        , oeoh.attribute4
        , oeoh.attribute5
        , oeoh.attribute6
        , oeoh.attribute7
        , oeoh.attribute8
        , oeoh.attribute9
        , oeoh.attribute10
        , oeoh.attribute11
        , oeoh.attribute12
        , oeoh.attribute13
        , oeoh.attribute14
        , oeoh.attribute15
        , oeoh.global_attribute1
        , oeoh.global_attribute2
        , oeoh.global_attribute3
        , oeoh.global_attribute4
        , oeoh.global_attribute5
        , oeoh.global_attribute6
        , oeoh.global_attribute7
        , oeoh.global_attribute8
        , oeoh.global_attribute9
        , oeoh.global_attribute10
        , oeoh.global_attribute11
        , oeoh.global_attribute12
        , oeoh.global_attribute13
        , oeoh.global_attribute14
        , oeoh.global_attribute15
        , oeoh.global_attribute16
        , oeoh.global_attribute17
        , oeoh.global_attribute18
        , oeoh.global_attribute19
        , oeoh.global_attribute20
        , oeoh.tp_attribute1
        , oeoh.tp_attribute2
        , oeoh.tp_attribute3
        , oeoh.tp_attribute4
        , oeoh.tp_attribute5
        , oeoh.tp_attribute6
        , oeoh.tp_attribute7
        , oeoh.tp_attribute8
        , oeoh.tp_attribute9
        , oeoh.tp_attribute10
        , oeoh.tp_attribute11
        , oeoh.tp_attribute12
        , oeoh.tp_attribute13
        , oeoh.tp_attribute14
        , oeoh.tp_attribute15
        , oeoh.sales_channel_code
        , oeoh.shipping_instructions
        , oeoh.packing_instructions
      FROM oe_order_headers_all oeoh
      WHERE oeoh.header_id = p_header_id;

    -- Bug 9261874, Cursor defined to fetch serial information from WSN or MSNT or WDD

    CURSOR c_wsh_serial_numbers(p_delivery_detail_id number)
        IS
        SELECT FM_SERIAL_NUMBER
             , TO_SERIAL_NUMBER
        FROM   wsh_serial_numbers
        WHERE  delivery_detail_id = p_delivery_detail_id

        UNION

        SELECT msnt.FM_SERIAL_NUMBER
             , msnt.TO_SERIAL_NUMBER
        FROM   mtl_serial_numbers_temp msnt
             , wsh_delivery_details wdd
        WHERE  msnt.transaction_temp_id = wdd.transaction_temp_id
        AND    wdd.delivery_detail_id   = p_delivery_detail_id

        UNION

        SELECT serial_number FM_SERIAL_NUMBER
             , serial_number TO_SERIAL_NUMBER
        FROM   wsh_delivery_details
        WHERE  delivery_detail_id = p_delivery_detail_id
        AND    serial_number      IS NOT NULL ;

   l_selected_fields       INV_LABEL.label_field_variable_tbl_type;
   l_selected_fields_count NUMBER;
   no_of_rows_per_label    NUMBER;
   max_no_of_rows_defined  NUMBER;
   new_label               BOOLEAN;

   l_delivery_id           NUMBER;
   l_outer_lpn_id          NUMBER;
   l_organization_id       NUMBER;
   l_wms_enabled           NUMBER;
   l_return_status         VARCHAR2(1);
   l_msg_data              VARCHAR2(2000);
   l_msg_count             NUMBER;
   l_api_status            VARCHAR2(240);
   l_error_message         VARCHAR2(240);
   l_cust_site_id   NUMBER ; --Added for bug 8454264, 8486711

   l_count_custom_sql NUMBER;
   l_sql_stmt  VARCHAR2(4000);
   l_sql_stmt_result VARCHAR2(4000);
   TYPE sql_stmt IS REF CURSOR;
   c_sql_stmt sql_stmt;
   l_custom_sql_ret_status VARCHAR2(1);
   l_custom_sql_ret_msg VARCHAR2(2000);

   l_CustSqlWarnFlagSet BOOLEAN;
   l_CustSqlErrFlagSet BOOLEAN;
   l_CustSqlWarnMsg VARCHAR2(2000);
   l_CustSqlErrMsg VARCHAR2(2000);

   l_cur_wdd c_wdd_lpn%ROWTYPE;
   l_prev_wdd c_wdd_lpn%ROWTYPE;
   l_cons_wdd c_wdd_lpn%ROWTYPE;
   TYPE wdd_tbl_type IS TABLE OF c_wdd_lpn%ROWTYPE INDEX BY BINARY_INTEGER;
   l_wdd_tb wdd_tbl_type;
   consol_index NUMBER;
   l_conv_qty   NUMBER;
   l_wdd_index  NUMBER;
   i NUMBER;
   j NUMBER;
   l_txn_temp_id NUMBER;
   l_cart_id     NUMBER;
   l_wnd_carrier_id NUMBER;
   l_wnd_ship_method_code VARCHAR2(30);

   l_content_rec_index NUMBER;
   row_index_per_label NUMBER;
   l_shipping_content_data LONG;
   l_label_index       NUMBER;
   l_column_name_in_format  VARCHAR2(60);
   l_variable_name         VARCHAR2(100);
   l_variable_list LONG; -- Modified for bug # 5465141  - VARCHAR2(2000);
   l_label_request_id  NUMBER;
   l_use_rules_engine  VARCHAR2(1);
   l_label_format_id   NUMBER;
   l_label_format      VARCHAR2(300);
   l_prev_format_id    NUMBER;
   l_printer           VARCHAR2(30);
   l_prev_lpn_id       NUMBER;
   l_gtin_enabled BOOLEAN := FALSE;
   l_gtin VARCHAR2(100);
   l_gtin_desc VARCHAR2(240);

   l_progress  VARCHAR2(100);

   l_total_number_of_lpns NUMBER;
   l_number_of_total  NUMBER;
   l_child_lpn  VARCHAR2(250);

   --Start Bug 6696594
   l_qty_index NUMBER;
   l_to_lpn_id     NUMBER;
   l_to_lpn        VARCHAR2(30);
   l_process_id    NUMBER;
   --End Bug 6696594

    --Bug 6880623
    l_pick_uom   VARCHAR2(30);
    l_pick_qty   NUMBER;
    l_uom_string VARCHAR2(30);
    l_loop_counter NUMBER;
    --Bug 6880623

    -- Bug 9261874, Variables defined for printing the serial information
    l_sub_range_serial_numbers INV_LABEL.serial_tab_type ;
    l_range_serial_numbers     INV_LABEL.serial_tab_type ;
    l_serial_number_empty      INV_LABEL.serial_tab_type ;
    l_fm_serial_number         VARCHAR2(100);
    l_to_serial_number         VARCHAR2(100);
    l_serial_counter           NUMBER ;
    l_serial_check             NUMBER;
    l_wdd_loop_counter         NUMBER := 0;

BEGIN
   -- Initialize return status as success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize debug
   l_debug := INV_LABEL.l_debug;


   IF (l_debug = 1) THEN
      trace('**In Shipping Content label**');
      trace('  Business_flow: '||p_label_type_info.business_flow_code);
      trace('  Transaction ID:'||p_transaction_id);
      trace('  P_input_param.txn_tmp_id:' || p_input_param.transaction_temp_id);
      trace('  P_input_param.lpn_id:' || p_input_param.lpn_id);
      trace('    Manual Format ID: ' || p_label_type_info.manual_format_id);
      trace('    Manual Format: ' || p_label_type_info.manual_format_name);
   END IF;

   IF p_label_type_info.business_flow_code in (6, 18,34,21,22) AND
      p_transaction_id IS NULL THEN
      IF(l_debug = 1) THEN
         trace('p_transaction_id is required for business flow 18,34,21,22(Pick Load, Replenish Load, Ship Confirm, Cartonization');
         trace('Can not proceed');
      END IF;
   ELSE
      IF p_label_type_info.business_flow_code in (19, 36) AND
         p_input_param.lpn_id IS NULL THEN
         IF(l_debug = 1) THEN
            trace('lpn_id is required for business flow 19,36(Pick Drop, Packing Workbench');
            trace('Can not proceed');
         END IF;
      ELSIF p_label_type_info.business_flow_code IS NULL THEN
         -- Manual print
         -- Either delivery or the lpn has to be provided
         IF p_input_param.transaction_temp_id IS NULL and p_input_param.lpn_id IS NULL THEN
            IF(l_debug =1 ) THEN
               trace('Delivery ID or LPN_ID has to be provided');
               trace('Can not proceed');
            END IF;
         END IF;
      END IF;
   END IF;


   -- Open Driving Cursors Depends on Business Flow
   IF p_label_type_info.business_flow_code in (18, 34) THEN
      IF p_label_type_info.business_flow_code in (18, 34) THEN
         -- Pick load, replenish pick load
         l_txn_temp_id := p_transaction_id;
         l_cart_id     := NULL;
      END IF;
      -- Use cursor c_wdd_mmtt
      -- Fetch records into l_wdd_tb;
      IF(l_debug = 1) THEN
         trace('Fetch from c_wdd_mmtt with txn_temp_id='||l_txn_temp_id||', cart_id='||l_cart_id);
      END IF;
      i := 0;
      l_wdd_tb.delete;
      FOR l_cur_wdd IN c_wdd_mmtt(l_txn_temp_id, l_cart_id) LOOP
         i := i+1;
         -- Get delivery information
         IF (l_cur_wdd.delivery_id IS NOT NULL) AND
            ((i=1) OR (l_cur_wdd.delivery_id <> l_wdd_tb(i-1).delivery_id)) THEN
            OPEN c_delivery(l_cur_wdd.delivery_id);
            FETCH c_delivery INTO
               l_cur_wdd.delivery_number
              ,l_cur_wdd.waybill
              ,l_cur_wdd.airbill
              ,l_cur_wdd.bill_of_lading
              ,l_cur_wdd.trip_number
              ,l_cur_wdd.wnd_carrier_id
              ,l_cur_wdd.wnd_ship_method_code
              ,l_cur_wdd.intmed_ship_to_location_id;
            CLOSE c_delivery;
         END IF;
         l_wdd_tb(i) := l_cur_wdd;
      END LOOP;
      IF(l_debug = 1) THEN
         trace('Done fetch from c_wdd_mmtt, l_wdd_tb has '||l_wdd_tb.count||' records');
      END IF;

   ELSE
      -- Cartonization, Pick Drop, Cross Dock, Packing Workbench, Ship Confirm, Manual Print
      -- Fetch from driving cursor and consolidate into l_wdd_tb

      -- First get txn_temp_id and/or delivery_id and/or lpn_id for different business flow
      IF p_label_type_info.business_flow_code in (22) THEN
         -- Cartonization
         l_txn_temp_id := NULL;
         l_cart_id     := p_transaction_id;
      ELSIF p_label_type_info.business_flow_code in (21) THEN
         -- Ship Confirm
         l_delivery_id := p_transaction_id;
      --Start Bug 6696594
      ELSIF p_label_type_info.business_flow_code in (42) AND INV_CONTROL.G_CURRENT_RELEASE_LEVEL >= 120001 THEN
         -- Pick Release
         l_txn_temp_id := p_transaction_id;
         l_cart_id     := NULL;
      --End Bug 6696594
      ELSIF p_label_type_info.business_flow_code in (6) THEN
         BEGIN
            SELECT lpn_id INTO l_outer_lpn_id
            FROM wsh_delivery_details
            WHERE delivery_detail_id = p_transaction_id;
         EXCEPTION
            WHEN others THEN
               IF (l_debug =1 ) THEN
                  trace('Can not find delivery detail records with ID '|| p_transaction_id);
               END IF;
               RETURN;
         END;
      ELSIF p_label_type_info.business_flow_code in (19,36)
         OR p_label_type_info.business_flow_code IS NULL THEN
         -- Cross Dock, Pick Drop, Packing Workbench, Manual Print
         l_delivery_id  := p_input_param.transaction_temp_id;
         l_outer_lpn_id := p_input_param.lpn_id;
      ELSE
         IF (l_debug = 1) THEN
            trace('Invalid business flow or input data, can not proceed');
         END IF;
         RETURN;
      END IF;

      -- If only delivery_id is provided, check whether the organization
      -- is WMS enabled,
      -- For non-WMS org, open different cursor
      IF l_delivery_id IS NOT NULL AND l_outer_lpn_id IS NULL THEN
         SELECT organization_id
         INTO l_organization_id
         FROM wsh_new_deliveries
         WHERE delivery_id = l_delivery_id;

         IF wms_install.check_install
            (x_return_status => l_return_status,
             x_msg_count => l_msg_count,
             x_msg_data => l_msg_data,
             p_organization_id => l_organization_id) THEN

            l_wms_enabled := 1;
         ELSE
            l_wms_enabled := 0;
         END IF;
      ELSE
         l_wms_enabled := 1;
      END IF;

      l_total_number_of_lpns := NULL;
      l_number_of_total := NULL;

      IF l_cart_id IS NOT NULL THEN
         IF(l_debug = 1) THEN
            trace('Open c_wdd_mmtt with NULL txn_temp_id and cart_id as '|| l_cart_id);
         END IF;
         OPEN c_wdd_mmtt(l_txn_temp_id, l_cart_id);
         FETCH c_wdd_mmtt INTO l_cons_wdd;
         IF c_wdd_mmtt%NOTFOUND THEN
            CLOSE c_wdd_mmtt;
            RETURN;
         END IF;
         -- Get total number of Cartons
         --trace('Cartonization, delivery_id '||l_cons_wdd.delivery_id);
         IF l_cons_wdd.delivery_id IS NOT NULL THEN
            get_carton_count(l_cons_wdd.delivery_id
              , l_total_number_of_lpns
              , l_number_of_total);
            IF(l_debug = 1) THEN
               trace('Cartonization, got l_total_number_of_lpns '||l_total_number_of_lpns);
               trace('                   l_number_of_total '||l_number_of_total);
            END IF;
         ELSE
            l_total_number_of_lpns := NULL;
            l_number_of_total := NULL;
         END IF;
         l_cons_wdd.number_of_total := l_number_of_total;

      --Start Bug 6696594
      ELSIF l_txn_temp_id iS NOT NULL AND INV_CONTROL.G_CURRENT_RELEASE_LEVEL >= 120001 THEN
      IF(l_debug = 1) THEN
              trace('Before opening the cursor');
         END IF;
	 OPEN c_wdd_mmtt(l_txn_temp_id, l_cart_id);
	FETCH c_wdd_mmtt INTO l_cons_wdd;
         IF c_wdd_mmtt%NOTFOUND THEN
            CLOSE c_wdd_mmtt;
            RETURN;
         END IF;
	 IF(l_debug = 1) THEN
              trace('After opening the cursor');
         END IF;
      --End Bug 6696594
      ELSIF l_outer_lpn_id IS NOT NULL THEN
         -- Fetch data with outer LPN
         IF(l_debug = 1) THEN
            trace('Open c_wdd_lpn with outermost LPN ID '||l_outer_lpn_id);
         END IF;
         OPEN c_wdd_lpn(l_outer_lpn_id);
         FETCH c_wdd_lpn INTO l_cons_wdd;
         IF c_wdd_lpn%NOTFOUND THEN
            CLOSE c_wdd_lpn;
            RETURN;
         END IF;

      ELSIF l_delivery_id IS NOT NULL THEN
         -- Fetch data with delivery
         IF l_wms_enabled = 1 THEN
            -- WMS org
            IF(l_debug = 1) THEN
               trace('Open c_wdd_del_wms with Delivery ID '||l_delivery_id);
            END IF;
            OPEN c_wdd_del_wms(l_delivery_id);
            FETCH c_wdd_del_wms INTO l_cons_wdd;
            IF c_wdd_del_wms%NOTFOUND THEN
               CLOSE c_wdd_del_wms;
               RETURN;
            END IF;
            -- Only calculate total number of LPNs and number of total
            --  when label is called for a delivery
            -- If LPN is provided, total number of LPNs and number of total are NULL
            l_total_number_of_lpns := 1;
            l_number_of_total := 1;
            l_cons_wdd.number_of_total := 1;
         ELSE -- Non WMS org
            IF(l_debug = 1) THEN
               trace('Open c_wdd_del_inv with Delivery ID '||l_delivery_id);
            END IF;
            OPEN c_wdd_del_inv(l_delivery_id);
            FETCH c_wdd_del_inv INTO l_cons_wdd;
            IF c_wdd_del_inv%NOTFOUND THEN
               CLOSE c_wdd_del_inv;
               RETURN;
            END IF;
         END IF;
      END IF;

      -- Get Delivery Information , using c_deliver
      IF (l_cons_wdd.delivery_id IS NOT NULL) THEN
         IF (l_debug = 1) THEN
            trace('Use c_delivery with delivery_id '||l_cons_wdd.delivery_id||', put in l_cons_wdd');
         END IF;

         OPEN c_delivery(l_cons_wdd.delivery_id);
         FETCH c_delivery INTO
            l_cons_wdd.delivery_number
           ,l_cons_wdd.waybill
           ,l_cons_wdd.airbill
           ,l_cons_wdd.bill_of_lading
           ,l_cons_wdd.trip_number
           ,l_cons_wdd.wnd_carrier_id
           ,l_cons_wdd.wnd_ship_method_code
           ,l_cons_wdd.intmed_ship_to_location_id;
         CLOSE c_delivery;
      END IF;

      -- Create consolidated records
      -- Driving cursor c_del_lpn, c_del_wms, c_del_non_wms are ordered by outerlpn, item, lot
      -- Loop through each record, cumulatint the quantity for the same outerlpn/item/lot
      -- When finished for one outerlpn/item/lot combination, save the consolidated record
      --  into table l_consol_wdd_tb
      -- During the process, also get the common value for other columns which will be used
      --  to fetch additional data.
      -- If the consolidated records has different values, it will have value of NULL
      -- For example, if the same item/lot comes from different sales order header/line,
      --  the consolidated record will have NULL in so_header_id and so_line_id.
      -- If they come from the same so header/line, then the column will have the common value

      consol_index := 1;
      l_wdd_tb.delete;

      l_qty_index := 1;

      LOOP
         IF c_wdd_mmtt%ISOPEN THEN
		 -- Start Bug 6696594

		IF p_label_type_info.business_flow_code in (42) AND INV_CONTROL.G_CURRENT_RELEASE_LEVEL >= 120001 THEN
		   l_total_number_of_lpns := 0;
			l_number_of_total := NULL;

         --Bug 6880623
         --Need to convert the MMTT line qty acc to the PickUOM defined for the subinventory
         --so that we print as many labels as the converted qty
         IF l_cons_wdd.shipped_quantity > 0 THEN
            IF (l_debug = 1) THEN
				  trace('l_cons_wdd.from_subinventory  ' || l_cons_wdd.from_subinventory);
                  trace('l_cons_wdd.from_locator_id  ' || l_cons_wdd.from_locator_id);
                  trace('l_cons_wdd.organization_id  ' || l_cons_wdd.organization_id);
                  trace('l_cons_wdd.shipped_quantity  ' || l_cons_wdd.shipped_quantity);
                  trace('l_cons_wdd.uom  ' || l_cons_wdd.uom);
			   END IF;

            INV_CONVERT.PICK_UOM_CONVERT
               (p_org_id         =>  l_cons_wdd.organization_id,
                p_item_id        =>  l_cons_wdd.inventory_item_id,
                p_sub_code       =>  l_cons_wdd.from_subinventory,
                p_loc_id         =>  null,
                p_alloc_uom      =>  l_cons_wdd.uom,
                p_alloc_qty      =>  l_cons_wdd.shipped_quantity,
                x_pick_uom       =>  l_pick_uom,
                x_pick_qty       =>  l_pick_qty,
                x_uom_string     =>  l_uom_string,
                x_return_status  =>  l_return_status,
                x_msg_data       =>  l_msg_data,
                x_msg_count      =>  l_msg_count);

            IF ( l_return_status <> fnd_api.g_ret_sts_success ) THEN
					IF (l_debug = 1) THEN
						trace('Failed to get the pick UOM');
					END IF;
                l_loop_counter := l_cons_wdd.shipped_quantity;
				END IF;

            IF ( l_return_status = fnd_api.g_ret_sts_success ) THEN
					IF (l_debug = 1) THEN
						trace('l_pick_uom  ' || l_pick_uom);
                  trace('l_pick_qty  ' || l_pick_qty);
                  trace('l_uom_string  ' || l_uom_string);
					END IF;
               IF (trunc(l_pick_qty) > 0) THEN
                  l_loop_counter := trunc(l_pick_qty);
               ELSE
                  l_loop_counter := l_cons_wdd.shipped_quantity;
               END IF;
				END IF;
         END IF;
         --Bug 6880623

			FOR l_qty_index IN 1..l_loop_counter LOOP
				FETCH c_wdd_mmtt INTO l_cur_wdd;
				l_wdd_tb(l_qty_index) := l_cons_wdd;
				l_number_of_total := l_qty_index;
				l_total_number_of_lpns := l_total_number_of_lpns + 1;
			        l_wdd_tb(l_qty_index).number_of_total := l_number_of_total;
				IF (l_debug = 1) THEN
					trace('l_total_number_of_lpns '||l_total_number_of_lpns);
					trace('l_wdd_tb(l_qty_index).number_of_total '||l_wdd_tb(l_qty_index).number_of_total);
				END IF;
				IF (l_debug = 1) THEN
					trace('generate dummy LPN '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'));
			        END IF;
			         -- generate a dummy lpn
			         wms_container_pub.generate_lpn
				       (p_api_version  => 1.0,
				        x_return_status => l_return_status,
				        x_msg_count => l_msg_count,
				        x_msg_data => l_msg_data,
				        p_organization_id => l_wdd_tb(l_qty_index).organization_id,
				        p_lpn_out => l_to_lpn,
				        p_lpn_id_out => l_to_lpn_id,
				        p_process_id => l_process_id,
				        p_validation_level => FND_API.G_VALID_LEVEL_NONE,
					p_client_code => wms_deploy.get_client_code(l_wdd_tb(l_qty_index).inventory_item_id)         -- Added for LSP, bug 9087971
					);

				IF ( l_return_status <> fnd_api.g_ret_sts_success ) THEN
					IF (l_debug = 1) THEN
						trace('failed to genrate LPN');
					END IF;
					fnd_message.set_name('WMS', 'WMS_PRINT_LABEL_FAIL');
					fnd_msg_pub.ADD;
				END IF;

				l_wdd_tb(l_qty_index).outer_lpn_id := l_to_lpn_id;
				IF (l_debug = 1) THEN
					trace('l_wdd_tb(l_qty_index).outer_lpn_id' || l_wdd_tb(l_qty_index).outer_lpn_id);
				END IF;
			END LOOP;
			IF c_wdd_mmtt%NOTFOUND THEN
				CLOSE c_wdd_mmtt;
				EXIT;
			END IF;
		ELSE
		--End Bug 6696594
			FETCH c_wdd_mmtt INTO l_cur_wdd;
				IF c_wdd_mmtt%NOTFOUND THEN
					CLOSE c_wdd_mmtt;
					l_wdd_tb(l_qty_index) := l_cons_wdd;
					EXIT;
				END IF;
		--Start Bug 6696594
		END IF;
		--End Bug 6696594
         ELSIF c_wdd_lpn%ISOPEN THEN
            FETCH c_wdd_lpn INTO l_cur_wdd;
            IF c_wdd_lpn%NOTFOUND THEN
               CLOSE c_wdd_lpn;
               l_wdd_tb(consol_index) := l_cons_wdd;
               EXIT;
            END IF;
         ELSIF c_wdd_del_wms%ISOPEN THEN
            FETCH c_wdd_del_wms INTO l_cur_wdd;
            IF c_wdd_del_wms%NOTFOUND THEN
               CLOSE c_wdd_del_wms;
               l_cons_wdd.number_of_total := l_number_of_total;
               l_wdd_tb(consol_index) := l_cons_wdd;
               EXIT;
            END IF;
         ELSIF c_wdd_del_inv%ISOPEN THEN
            FETCH c_wdd_del_inv INTO l_cur_wdd;
            IF c_wdd_del_inv%NOTFOUND THEN
               CLOSE c_wdd_del_inv;
               l_wdd_tb(consol_index) := l_cons_wdd;
               EXIT;
            END IF;
         END IF;


         -- Get Delivery Information , using c_deliver
         -- This only needs to done if delivery_id is different
         IF (l_cur_wdd.delivery_id IS NOT NULL) AND
            (l_cur_wdd.delivery_id <> l_cons_wdd.delivery_id) THEN
            OPEN c_delivery(l_cur_wdd.delivery_id);
            FETCH c_delivery INTO
               l_cur_wdd.delivery_number
              ,l_cur_wdd.waybill
              ,l_cur_wdd.airbill
              ,l_cur_wdd.bill_of_lading
              ,l_cur_wdd.trip_number
              ,l_cur_wdd.wnd_carrier_id
              ,l_cur_wdd.wnd_ship_method_code
              ,l_cur_wdd.intmed_ship_to_location_id;
            CLOSE c_delivery;
         ELSE
            -- Copy from l_cons_wdd
            l_cur_wdd.delivery_number :=  l_cons_wdd.delivery_number;
            l_cur_wdd.waybill         :=  l_cons_wdd.waybill;
            l_cur_wdd.airbill         :=  l_cons_wdd.airbill;
            l_cur_wdd.bill_of_lading  :=  l_cons_wdd.bill_of_lading;
            l_cur_wdd.trip_number     :=  l_cons_wdd.trip_number;
            l_cur_wdd.wnd_carrier_id  :=  l_cons_wdd.wnd_carrier_id;
            l_cur_wdd.wnd_ship_method_code  := l_cons_wdd.wnd_ship_method_code;
            l_cur_wdd.intmed_ship_to_location_id := l_cons_wdd.intmed_ship_to_location_id;

         END IF;

         IF (nvl(l_cur_wdd.outer_lpn_id, NULL_NUM) = nvl(l_cons_wdd.outer_lpn_id, NULL_NUM)) AND
            (l_cur_wdd.inventory_item_id = l_cons_wdd.inventory_item_id) AND
            (nvl(l_cur_wdd.lot_number, NULL_VAR) = nvl(l_cons_wdd.lot_number,NULL_VAR)) AND
            (nvl(l_cur_wdd.revision, NULL_VAR) = nvl(l_cons_wdd.revision, NULL_VAR)) THEN
            -- Same outer LPN, item, and lot
            -- Consolidate
            -- Add quantities, if UOMs are different, need to convert

            IF l_cons_wdd.uom = l_cur_wdd.uom THEN
               l_cons_wdd.requested_quantity := l_cons_wdd.requested_quantity +
                                              l_cur_wdd.requested_quantity;
            ELSE
               l_conv_qty := inv_convert.inv_um_convert(l_cur_wdd.inventory_item_id, NULL,
                    l_cur_wdd.requested_quantity, l_cur_wdd.uom,l_cons_wdd.uom,NULL,NULL);
               IF l_conv_qty <> -9999 THEN
                  l_cons_wdd.requested_quantity := l_cons_wdd.requested_quantity + l_conv_qty;
               END IF;
            END IF;

            -- For NULLable quantities
            -- if both values are NULL, keep it as NULL
            -- If one of the values is not NULL, then do the addition
            -- convert if uom is different
            IF (l_cons_wdd.shipped_quantity IS NOT NULL) OR
               (l_cur_wdd.shipped_quantity IS NOT NULL) THEN
               IF l_cons_wdd.uom = l_cur_wdd.uom THEN
                  l_cons_wdd.shipped_quantity := nvl(l_cons_wdd.shipped_quantity,0) +
                                           nvl(l_cur_wdd.shipped_quantity,0);
               ELSIF l_cur_wdd.shipped_quantity IS NOT NULL THEN
                  l_conv_qty := inv_convert.inv_um_convert(l_cur_wdd.inventory_item_id, NULL,
                       l_cur_wdd.shipped_quantity, l_cur_wdd.uom,l_cons_wdd.uom,NULL,NULL);
                  IF l_conv_qty <> -9999 THEN
                     l_cons_wdd.shipped_quantity := nvl(l_cons_wdd.shipped_quantity,0) + l_conv_qty;
                  END IF;
               END IF;
            END IF;
            IF (l_cons_wdd.shipped_quantity2 IS NOT NULL) OR
               (l_cur_wdd.shipped_quantity2 IS NOT NULL) THEN
               IF l_cons_wdd.uom = l_cur_wdd.uom THEN
                  l_cons_wdd.shipped_quantity2 := nvl(l_cons_wdd.shipped_quantity2,0) +
                                           nvl(l_cur_wdd.shipped_quantity2,0);
               ELSIF l_cur_wdd.shipped_quantity2 IS NOT NULL THEN
                  l_conv_qty := inv_convert.inv_um_convert(l_cur_wdd.inventory_item_id, NULL,
                       l_cur_wdd.shipped_quantity2, l_cur_wdd.uom,l_cons_wdd.uom,NULL,NULL);
                  IF l_conv_qty <> -9999 THEN
                     l_cons_wdd.shipped_quantity2 := nvl(l_cons_wdd.shipped_quantity2,0) + l_conv_qty;
                  END IF;
               END IF;
            END IF;
            IF (l_cons_wdd.cancelled_quantity IS NOT NULL) OR
               (l_cur_wdd.cancelled_quantity IS NOT NULL) THEN
               IF l_cons_wdd.uom = l_cur_wdd.uom THEN
                  l_cons_wdd.cancelled_quantity := nvl(l_cons_wdd.cancelled_quantity,0) +
                                           nvl(l_cur_wdd.cancelled_quantity,0);
               ELSIF l_cur_wdd.cancelled_quantity IS NOT NULL THEN
                  l_conv_qty := inv_convert.inv_um_convert(l_cur_wdd.inventory_item_id, NULL,
                       l_cur_wdd.cancelled_quantity, l_cur_wdd.uom,l_cons_wdd.uom,NULL,NULL);
                  IF l_conv_qty <> -9999 THEN
                     l_cons_wdd.cancelled_quantity := nvl(l_cons_wdd.cancelled_quantity,0) + l_conv_qty;
                  END IF;
               END IF;
            END IF;
            IF (l_cons_wdd.delivered_quantity IS NOT NULL) OR
               (l_cur_wdd.delivered_quantity IS NOT NULL) THEN
               IF l_cons_wdd.uom = l_cur_wdd.uom THEN
                  l_cons_wdd.delivered_quantity := nvl(l_cons_wdd.delivered_quantity,0) +
                                           nvl(l_cur_wdd.delivered_quantity,0);
               ELSIF l_cur_wdd.delivered_quantity IS NOT NULL THEN
                  l_conv_qty := inv_convert.inv_um_convert(l_cur_wdd.inventory_item_id, NULL,
                       l_cur_wdd.delivered_quantity, l_cur_wdd.uom,l_cons_wdd.uom,NULL,NULL);
                  IF l_conv_qty <> -9999 THEN
                     l_cons_wdd.delivered_quantity := nvl(l_cons_wdd.delivered_quantity,0) + l_conv_qty;
                  END IF;
               END IF;
            END IF;

            -- Compare the following columns,
            -- If they have the common values for the consolidated WDDs,
            --  they will have the value populated, otherwise, it will have NULL

            IF nvl(l_cur_wdd.carrier_id, NULL_NUM) <> nvl(l_cons_wdd.carrier_id, NULL_NUM) THEN
               l_cons_wdd.carrier_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.customer_purchase_order, NULL_VAR) <> nvl(l_cons_wdd.customer_purchase_order, NULL_VAR) THEN
               l_cons_wdd.customer_purchase_order := NULL;
            END IF;
            IF nvl(l_cur_wdd.customer_id, NULL_NUM) <> nvl(l_cons_wdd.customer_id, NULL_NUM) THEN
               l_cons_wdd.customer_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.ship_method_code, NULL_VAR) <> nvl(l_cons_wdd.ship_method_code, NULL_VAR) THEN
               l_cons_wdd.ship_method_code := NULL;
            END IF;
            IF nvl(l_cur_wdd.source_header_number, NULL_VAR) <> nvl(l_cons_wdd.source_header_number, NULL_VAR) THEN
               l_cons_wdd.source_header_number := NULL;
               l_cons_wdd.source_line_number := NULL;
            ELSIF nvl(l_cur_wdd.source_line_number, NULL_VAR) <> nvl(l_cons_wdd.source_line_number, NULL_VAR) THEN
               l_cons_wdd.source_line_number := NULL;
            END IF;
            IF nvl(l_cur_wdd.tracking_number, NULL_VAR) <> nvl(l_cons_wdd.tracking_number, NULL_VAR) THEN
               l_cons_wdd.tracking_number := NULL;
            END IF;
            IF nvl(l_cur_wdd.fob, NULL_VAR) <> nvl(l_cons_wdd.fob, NULL_VAR) THEN
               l_cons_wdd.fob := NULL;
            END IF;
            IF nvl(l_cur_wdd.customer_item_id, NULL_NUM) <> nvl(l_cons_wdd.customer_item_id, NULL_NUM) THEN
               l_cons_wdd.customer_item_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.project_id, NULL_NUM) <> nvl(l_cons_wdd.project_id, NULL_NUM) THEN
               l_cons_wdd.project_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.task_id, NULL_NUM) <> nvl(l_cons_wdd.task_id, NULL_NUM) THEN
               l_cons_wdd.task_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.ship_from_location_id, NULL_NUM) <> nvl(l_cons_wdd.ship_from_location_id, NULL_NUM) THEN
               l_cons_wdd.ship_from_location_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.ship_to_location_id, NULL_NUM) <> nvl(l_cons_wdd.ship_to_location_id, NULL_NUM) THEN
               l_cons_wdd.ship_to_location_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.ship_to_site_use_id, NULL_NUM) <> nvl(l_cons_wdd.ship_to_site_use_id, NULL_NUM) THEN
               l_cons_wdd.ship_to_site_use_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.ship_to_contact_id, NULL_NUM) <> nvl(l_cons_wdd.ship_to_contact_id, NULL_NUM) THEN
               l_cons_wdd.ship_to_contact_id := NULL;
            END IF;

            IF nvl(l_cur_wdd.delivery_id, NULL_NUM) <> nvl(l_cons_wdd.delivery_id, NULL_NUM) THEN
               l_cons_wdd.delivery_id := NULL;
               IF nvl(l_cur_wdd.delivery_number, NULL_VAR) <> nvl(l_cons_wdd.delivery_number, NULL_VAR) THEN
                  l_cons_wdd.delivery_number := NULL;
               END IF;
               IF nvl(l_cur_wdd.waybill, NULL_VAR) <> nvl(l_cons_wdd.waybill, NULL_VAR) THEN
                  l_cons_wdd.waybill := NULL;
               END IF;
               IF nvl(l_cur_wdd.airbill, NULL_VAR) <> nvl(l_cons_wdd.airbill, NULL_VAR) THEN
                  l_cons_wdd.airbill := NULL;
               END IF;
               IF nvl(l_cur_wdd.bill_of_lading, NULL_VAR) <> nvl(l_cons_wdd.bill_of_lading, NULL_VAR) THEN
                  l_cons_wdd.bill_of_lading := NULL;
               END IF;
               IF nvl(l_cur_wdd.trip_number, NULL_VAR) <> nvl(l_cons_wdd.trip_number, NULL_VAR) THEN
                  l_cons_wdd.trip_number := NULL;
               END IF;
               IF nvl(l_cur_wdd.wnd_carrier_id, NULL_NUM) <> nvl(l_cons_wdd.wnd_carrier_id, NULL_NUM) THEN
                  l_cons_wdd.wnd_carrier_id := NULL;
               END IF;
               IF nvl(l_cur_wdd.wnd_ship_method_code, NULL_VAR) <> nvl(l_cons_wdd.wnd_ship_method_code, NULL_VAR) THEN
                  l_cons_wdd.wnd_ship_method_code := NULL;
               END IF;
               IF nvl(l_cur_wdd.intmed_ship_to_location_id, NULL_NUM) <> nvl(l_cons_wdd.intmed_ship_to_location_id, NULL_NUM) THEN
                  l_cons_wdd.intmed_ship_to_location_id := NULL;
               END IF;
            END IF;
            IF nvl(l_cur_wdd.intmed_ship_to_contact_id, NULL_NUM) <> nvl(l_cons_wdd.intmed_ship_to_contact_id, NULL_NUM) THEN
               l_cons_wdd.intmed_ship_to_contact_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.sold_to_contact_id, NULL_NUM) <> nvl(l_cons_wdd.sold_to_contact_id, NULL_NUM) THEN
               l_cons_wdd.sold_to_contact_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.deliver_to_location_id, NULL_NUM) <> nvl(l_cons_wdd.deliver_to_location_id, NULL_NUM) THEN
               l_cons_wdd.deliver_to_location_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.deliver_to_contact_id, NULL_NUM) <> nvl(l_cons_wdd.deliver_to_contact_id, NULL_NUM) THEN
               l_cons_wdd.deliver_to_contact_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.deliver_to_site_use_id, NULL_NUM) <> nvl(l_cons_wdd.deliver_to_site_use_id, NULL_NUM) THEN
               l_cons_wdd.deliver_to_site_use_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.source_header_id, NULL_NUM) <> nvl(l_cons_wdd.source_header_id, NULL_NUM) THEN
               l_cons_wdd.source_header_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.source_line_id, NULL_NUM) <> nvl(l_cons_wdd.source_line_id, NULL_NUM) THEN
               l_cons_wdd.source_line_id := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute_category, NULL_VAR) <> nvl(l_cons_wdd.attribute_category, NULL_VAR) THEN
               l_cons_wdd.attribute_category := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute_category, NULL_VAR) <> nvl(l_cons_wdd.attribute_category, NULL_VAR) THEN
               l_cons_wdd.attribute_category := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute1, NULL_VAR) <> nvl(l_cons_wdd.attribute1, NULL_VAR) THEN
               l_cons_wdd.attribute1 := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute2, NULL_VAR) <> nvl(l_cons_wdd.attribute2, NULL_VAR) THEN
               l_cons_wdd.attribute2 := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute3, NULL_VAR) <> nvl(l_cons_wdd.attribute3, NULL_VAR) THEN
               l_cons_wdd.attribute3 := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute4, NULL_VAR) <> nvl(l_cons_wdd.attribute4, NULL_VAR) THEN
               l_cons_wdd.attribute4 := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute5, NULL_VAR) <> nvl(l_cons_wdd.attribute5, NULL_VAR) THEN
               l_cons_wdd.attribute5 := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute6, NULL_VAR) <> nvl(l_cons_wdd.attribute6, NULL_VAR) THEN
               l_cons_wdd.attribute6 := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute7, NULL_VAR) <> nvl(l_cons_wdd.attribute7, NULL_VAR) THEN
               l_cons_wdd.attribute7 := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute8, NULL_VAR) <> nvl(l_cons_wdd.attribute8, NULL_VAR) THEN
               l_cons_wdd.attribute8 := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute9, NULL_VAR) <> nvl(l_cons_wdd.attribute9, NULL_VAR) THEN
               l_cons_wdd.attribute9 := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute10, NULL_VAR) <> nvl(l_cons_wdd.attribute10, NULL_VAR) THEN
               l_cons_wdd.attribute10 := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute11, NULL_VAR) <> nvl(l_cons_wdd.attribute11, NULL_VAR) THEN
               l_cons_wdd.attribute11 := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute12, NULL_VAR) <> nvl(l_cons_wdd.attribute12, NULL_VAR) THEN
               l_cons_wdd.attribute12 := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute13, NULL_VAR) <> nvl(l_cons_wdd.attribute13, NULL_VAR) THEN
               l_cons_wdd.attribute13 := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute14, NULL_VAR) <> nvl(l_cons_wdd.attribute14, NULL_VAR) THEN
               l_cons_wdd.attribute14 := NULL;
            END IF;
            IF nvl(l_cur_wdd.attribute15, NULL_VAR) <> nvl(l_cons_wdd.attribute15, NULL_VAR) THEN
               l_cons_wdd.attribute15 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute_category, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute_category, NULL_VAR) THEN
               l_cons_wdd.tp_attribute_category := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute1, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute1, NULL_VAR) THEN
               l_cons_wdd.tp_attribute1 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute2, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute2, NULL_VAR) THEN
               l_cons_wdd.tp_attribute2 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute3, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute3, NULL_VAR) THEN
               l_cons_wdd.tp_attribute3 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute4, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute4, NULL_VAR) THEN
               l_cons_wdd.tp_attribute4 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute5, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute5, NULL_VAR) THEN
               l_cons_wdd.tp_attribute5 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute6, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute6, NULL_VAR) THEN
               l_cons_wdd.tp_attribute6 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute7, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute7, NULL_VAR) THEN
               l_cons_wdd.tp_attribute7 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute8, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute8, NULL_VAR) THEN
               l_cons_wdd.tp_attribute8 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute9, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute9, NULL_VAR) THEN
               l_cons_wdd.tp_attribute9 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute10, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute10, NULL_VAR) THEN
               l_cons_wdd.tp_attribute10 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute11, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute11, NULL_VAR) THEN
               l_cons_wdd.tp_attribute11 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute12, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute12, NULL_VAR) THEN
               l_cons_wdd.tp_attribute12 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute13, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute13, NULL_VAR) THEN
               l_cons_wdd.tp_attribute13 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute14, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute14, NULL_VAR) THEN
               l_cons_wdd.tp_attribute14 := NULL;
            END IF;
            IF nvl(l_cur_wdd.tp_attribute15, NULL_VAR) <> nvl(l_cons_wdd.tp_attribute15, NULL_VAR) THEN
               l_cons_wdd.tp_attribute15 := NULL;
            END IF;

         ELSE
            -- Check if Outer LPN changes, calculate total number of LPNs
            IF nvl(p_label_type_info.business_flow_code, NULL_NUM) <> 22 THEN
               IF nvl(l_cur_wdd.outer_lpn_id, NULL_NUM) <> nvl(l_cons_wdd.outer_lpn_id, NULL_NUM) THEN
                  l_total_number_of_LPNs := l_total_number_of_LPNs + 1;
                  l_number_of_total := l_number_of_total + 1;
               END IF;
               l_cur_wdd.number_of_total := l_number_of_total;
            ELSE
               l_cur_wdd.number_of_total := l_number_of_total;
            END IF;

            -- Different outer LPN, item, or lot
            -- Put the last consolidated wdd into l_wdd_tb and start a new consolidation record
            l_wdd_tb(consol_index) := l_cons_wdd;
            l_cons_wdd := l_cur_wdd;
            l_cur_wdd  := NULL;
            consol_index := consol_index + 1;

         END IF; -- Whether l_cur_wdd is same as l_cons_wdd

      END LOOP; -- Loop of creating consolidated records


   END IF; -- business flow code of 18, or 22, or others

   IF (l_debug = 1) THEN
      trace('Finished creating WDD record table, l_wdd_tb has ' ||l_wdd_tb.count||' records');
      trace('Total number of LPNs: '||l_total_number_of_lpns);
   END IF;

   -- Start generating labels
   -- Loop through each wdd record in l_wdd_tb and create labels
   new_label := true;
   l_cur_wdd := NULL;

   l_content_rec_index := 0;
   l_shipping_content_data := '';
   row_index_per_label := 0;
   l_label_index := 0;
   l_prev_format_id := NULL_NUM;
   l_prev_lpn_id    := NULL_NUM;

   -- Date, Time, User
   g_column_elements_table(get_column_hash_value('current_date')).column_content := INV_LABEL.G_DATE ;
   g_column_elements_table(get_column_hash_value('current_time')).column_content := INV_LABEL.G_TIME ;
   g_column_elements_table(get_column_hash_value('request_user')).column_content := INV_LABEL.G_USER ;


   FOR l_wdd_index IN 1..l_wdd_tb.count LOOP
      l_prev_wdd := l_cur_wdd;
      l_cur_wdd := l_wdd_tb(l_wdd_index);

      IF(l_debug = 1) THEN
         trace('In l_wdd_tb loop, l_wdd_index='||l_wdd_index);
         trace(' inventory_item_id '||l_cur_wdd.inventory_item_id);
         trace(' lot_number '||l_cur_wdd.lot_number);
         trace(' requested_qty '|| l_cur_wdd.requested_quantity);
      END IF;

            -- Bug 9261874, Serial Numbers extracted from WSN/MSNT/WDD are stacked into l_range_serial_numbers.
            -- Onwards l_range_serial_numbers is used to stamp Serial Numbers in the Shipping Content label.

        BEGIN

            SELECT Count(*)
            INTO   l_serial_check
            FROM   wms_label_field_variables lbvar
                 , wms_label_fields_vl lbfl
            WHERE lbfl.label_field_id = lbvar.label_field_id
            AND   lbvar.label_format_id = p_label_type_info.default_format_id
            AND   column_name = 'serial_number';

            IF (l_debug = 1) THEN
                trace('l_serial_check:' ||l_serial_check);
            END IF;

            l_range_serial_numbers := l_serial_number_empty;

            IF (l_serial_check > 0) THEN

                l_serial_counter := 0;

                IF (l_debug = 1) THEN
                    trace('For loop for stacking the serials');
                END IF;

              -- loop started to stack all the serials.
                FOR v_wsh_serial_numbers IN c_wsh_serial_numbers(l_cur_wdd.delivery_detail_id)
                LOOP

                    l_fm_serial_number  :=   v_wsh_serial_numbers.FM_SERIAL_NUMBER ;
                    l_to_serial_number  :=   v_wsh_serial_numbers.TO_SERIAL_NUMBER ;

                    IF (l_debug = 1) THEN
                        trace('l_fm_serial_number, l_to_serial_number' ||l_fm_serial_number || ', ' || l_to_serial_number);
                    END IF;

                    IF (l_to_serial_number IS NOT NULL) AND
                       (l_fm_serial_number <> l_to_serial_number) THEN

                        INV_LABEL.GET_NUMBER_BETWEEN_RANGE(
                                   fm_x_number     => l_fm_serial_number
                                 , to_x_number     => l_to_serial_number
                                 , x_return_status => l_return_status
                                 , x_number_table  => l_sub_range_serial_numbers
                                 );
                        IF (l_debug = 1) THEN
                            trace('return_status:' ||l_return_status || ' sub range count :' ||l_sub_range_serial_numbers.count);
                        END IF;

                        -- loop to stack returmed serials into l_range_serial_numbers
                        FOR i IN 1..l_sub_range_serial_numbers.Count LOOP

                            l_serial_counter := l_serial_counter + 1 ;
                            l_range_serial_numbers(l_serial_counter) := l_sub_range_serial_numbers(i);

                        END LOOP;

                        l_sub_range_serial_numbers := l_serial_number_empty;

                    ELSE

                        l_serial_counter := l_serial_counter + 1 ;
                        l_range_serial_numbers(l_serial_counter) :=  l_fm_serial_number ;

                    END IF;

                END LOOP;
              --End of Serial stacking loop.

              l_wdd_loop_counter := 0;
              l_wdd_loop_counter := l_range_serial_numbers.COUNT;

            END IF;

            IF l_wdd_loop_counter = 0 THEN
                l_wdd_loop_counter := 1;
            END IF;

            IF (l_debug = 1) THEN
                trace('Number of serials to be printed:' || l_range_serial_numbers.COUNT || ' for Delivery_detail_id:'|| l_cur_wdd.delivery_detail_id);
            END IF;

            EXCEPTION
                WHEN OTHERS THEN
                   IF (l_debug = 1) THEN
                        trace(' Inside Exception Block of serial stacking logic');
                   END IF;
        END;

            -- Bug 9261874, Stacking the serials in l_range_serial_numbers completed.

      -- Put data from l_cur_wdd to hash table

      l_progress := 'Assign l_cur_wdd to hash table';

      g_column_elements_table(get_column_hash_value('')).column_content := l_cur_wdd.requested_quantity;
      g_column_elements_table(get_column_hash_value('shipped_quantity')).column_content := l_cur_wdd.shipped_quantity;
      g_column_elements_table(get_column_hash_value('shipped_quantity2')).column_content := l_cur_wdd.shipped_quantity2;
      g_column_elements_table(get_column_hash_value('uom')).column_content := l_cur_wdd.uom ;
      g_column_elements_table(get_column_hash_value('revision')).column_content := l_cur_wdd.revision;
      g_column_elements_table(get_column_hash_value('lot_number')).column_content := l_cur_wdd.lot_number ;
      g_column_elements_table(get_column_hash_value('cancelled_quantity')).column_content := l_cur_wdd.cancelled_quantity;
      g_column_elements_table(get_column_hash_value('delivered_quantity')).column_content := l_cur_wdd.delivered_quantity;
      g_column_elements_table(get_column_hash_value('customer_purchase_order')).column_content := l_cur_wdd.customer_purchase_order;
      g_column_elements_table(get_column_hash_value('sales_order_number')).column_content := l_cur_wdd.source_header_number ;
      g_column_elements_table(get_column_hash_value('sales_order_line')).column_content := l_cur_wdd.source_line_number ;
      g_column_elements_table(get_column_hash_value('tracking_number')).column_content := l_cur_wdd.tracking_number;
      g_column_elements_table(get_column_hash_value('fob')).column_content := l_cur_wdd.fob;
      g_column_elements_table(get_column_hash_value('del_detail_attribute_category')).column_content := l_cur_wdd.attribute_category;
      g_column_elements_table(get_column_hash_value('del_detail_attribute1')).column_content := l_cur_wdd.attribute1;
      g_column_elements_table(get_column_hash_value('del_detail_attribute2')).column_content := l_cur_wdd.attribute2;
      g_column_elements_table(get_column_hash_value('del_detail_attribute3')).column_content := l_cur_wdd.attribute3;
      g_column_elements_table(get_column_hash_value('del_detail_attribute4')).column_content := l_cur_wdd.attribute4;
      g_column_elements_table(get_column_hash_value('del_detail_attribute5')).column_content := l_cur_wdd.attribute5;
      g_column_elements_table(get_column_hash_value('del_detail_attribute6')).column_content := l_cur_wdd.attribute6;
      g_column_elements_table(get_column_hash_value('del_detail_attribute7')).column_content := l_cur_wdd.attribute7;
      g_column_elements_table(get_column_hash_value('del_detail_attribute8')).column_content := l_cur_wdd.attribute8;
      g_column_elements_table(get_column_hash_value('del_detail_attribute9')).column_content := l_cur_wdd.attribute9;
      g_column_elements_table(get_column_hash_value('del_detail_attribute10')).column_content := l_cur_wdd.attribute10;
      g_column_elements_table(get_column_hash_value('del_detail_attribute11')).column_content := l_cur_wdd.attribute11;
      g_column_elements_table(get_column_hash_value('del_detail_attribute12')).column_content := l_cur_wdd.attribute12;
      g_column_elements_table(get_column_hash_value('del_detail_attribute13')).column_content := l_cur_wdd.attribute13;
      g_column_elements_table(get_column_hash_value('del_detail_attribute14')).column_content := l_cur_wdd.attribute14;
      g_column_elements_table(get_column_hash_value('del_detail_attribute15')).column_content := l_cur_wdd.attribute15;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr_category')).column_content := l_cur_wdd.tp_attribute_category;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr1')).column_content := l_cur_wdd.tp_attribute1;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr2')).column_content := l_cur_wdd.tp_attribute2;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr3')).column_content := l_cur_wdd.tp_attribute3;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr4')).column_content := l_cur_wdd.tp_attribute4;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr5')).column_content := l_cur_wdd.tp_attribute5;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr6')).column_content := l_cur_wdd.tp_attribute6;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr7')).column_content := l_cur_wdd.tp_attribute7;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr8')).column_content := l_cur_wdd.tp_attribute8;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr9')).column_content := l_cur_wdd.tp_attribute9;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr10')).column_content := l_cur_wdd.tp_attribute10;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr11')).column_content := l_cur_wdd.tp_attribute11;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr12')).column_content := l_cur_wdd.tp_attribute12;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr13')).column_content := l_cur_wdd.tp_attribute13;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr14')).column_content := l_cur_wdd.tp_attribute14;
      g_column_elements_table(get_column_hash_value('del_detail_tp_attr15')).column_content := l_cur_wdd.tp_attribute15;
      g_column_elements_table(get_column_hash_value('from_subinventory')).column_content := l_cur_wdd.from_subinventory;
      g_column_elements_table(get_column_hash_value('from_locator')).column_content := l_cur_wdd.from_locator;
      g_column_elements_table(get_column_hash_value('to_subinventory')).column_content := l_cur_wdd.to_subinventory;
      g_column_elements_table(get_column_hash_value('to_locator')).column_content := l_cur_wdd.to_locator;
      g_column_elements_table(get_column_hash_value('total_number_of_lpns')).column_content := l_total_number_of_lpns;
      g_column_elements_table(get_column_hash_value('lpn_number_of_total')).column_content := l_cur_wdd.number_of_total;
      g_column_elements_table(get_column_hash_value('delivery_number')).column_content := l_cur_wdd.delivery_number;
      g_column_elements_table(get_column_hash_value('waybill')).column_content := l_cur_wdd.waybill;
      g_column_elements_table(get_column_hash_value('airbill')).column_content := l_cur_wdd.airbill;
      g_column_elements_table(get_column_hash_value('bill_of_lading')).column_content := l_cur_wdd.bill_of_lading;
      g_column_elements_table(get_column_hash_value('trip_number')).column_content := l_cur_wdd.trip_number;


      -- Open the following cursors to retrieve more date for labels
      --  Cursor only needs to be opened if the primary key value is not NULL
      --  and the primary key value is different than before


      IF l_cur_wdd.organization_id <> nvl(l_prev_wdd.organization_id, NULL_NUM) THEN
         l_progress := 'Use org cursor to hash table ';
         OPEN c_org_code(l_cur_wdd.organization_id);
         FETCH c_org_code INTO g_column_elements_table(get_column_hash_value('organization')).column_content;
         CLOSE c_org_code;
         g_column_elements_table(get_column_hash_value('organization_code')).column_content :=
           g_column_elements_table(get_column_hash_value('organization')).column_content;

         OPEN c_org_name(l_cur_wdd.organization_id);
         FETCH c_org_name INTO
          g_column_elements_table(get_column_hash_value('organization_name')).column_content,
          g_column_elements_table(get_column_hash_value('org_tel_number')).column_content,
          g_column_elements_table(get_column_hash_value('org_fax_number')).column_content;
         CLOSE c_org_name;
      END IF;


      IF l_cur_wdd.outer_lpn_id IS NOT NULL AND l_cur_wdd.outer_lpn_id <> nvl(l_prev_wdd.outer_lpn_id, NULL_NUM) THEN
         l_progress := 'Use outer lpn cursor to hash table';
         OPEN c_wdd_outer_lpn(l_cur_wdd.outer_lpn_id);
         FETCH c_wdd_outer_lpn INTO
          g_column_elements_table(get_column_hash_value('del_lpn_load_seq_num')).column_content
         ,g_column_elements_table(get_column_hash_value('del_lpn_net_weight')).column_content
         ,g_column_elements_table(get_column_hash_value('del_lpn_gross_weight')).column_content
         ,g_column_elements_table(get_column_hash_value('del_lpn_tracking_number')).column_content
         ,g_column_elements_table(get_column_hash_value('shipment_gross_weight')).column_content
         ,g_column_elements_table(get_column_hash_value('shipment_gross_weight_uom')).column_content
         ,g_column_elements_table(get_column_hash_value('shipment_tare_weight')).column_content
         ,g_column_elements_table(get_column_hash_value('shipment_tare_weight_uom')).column_content
         ,g_column_elements_table(get_column_hash_value('shipment_volume')).column_content
         ,g_column_elements_table(get_column_hash_value('shipment_volume_uom')).column_content;
         CLOSE c_wdd_outer_lpn;
      END IF;

      IF l_cur_wdd.inventory_item_id IS NOT NULL AND l_cur_wdd.inventory_item_id <> nvl(l_prev_wdd.inventory_item_id, NULL_NUM) THEN
         l_progress := 'Use item cursor to hash table';
         OPEN c_item(l_cur_wdd.organization_id, l_cur_wdd.inventory_item_id);
         FETCH c_item INTO
          g_column_elements_table(get_column_hash_value('item')).column_content
         ,g_column_elements_table(get_column_hash_value('client_item')).column_content 		-- Added for LSP Project, bug 9087971
         ,g_column_elements_table(get_column_hash_value('item_description')).column_content
         ,g_column_elements_table(get_column_hash_value('secondary_uom_code')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute_category')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute1')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute2')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute3')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute4')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute5')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute6')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute7')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute8')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute9')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute10')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute11')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute12')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute13')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute14')).column_content
         ,g_column_elements_table(get_column_hash_value('item_attribute15')).column_content
         ,g_column_elements_table(get_column_hash_value('item_hazard_class')).column_content;
         CLOSE c_item;
      END IF;

      IF l_cur_wdd.customer_item_id IS NOT NULL AND l_cur_wdd.customer_item_id <> nvl(l_prev_wdd.customer_item_id, NULL_NUM) THEN
         l_progress := 'Use customer item cursor to hash table';
         OPEN c_customer_item(l_cur_wdd.customer_item_id);
         FETCH c_customer_item INTO
           g_column_elements_table(get_column_hash_value('customer_part_number')).column_content,
           g_column_elements_table(get_column_hash_value('cust_item_attribute_category')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute1')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute2')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute3')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute4')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute5')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute6')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute7')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute8')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute9')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute10')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute11')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute12')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute13')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute14')).column_content,
           g_column_elements_table(get_column_hash_value('customer_item_attribute15')).column_content;
         CLOSE c_customer_item;
      END IF;

      IF l_cur_wdd.customer_id IS NOT NULL AND l_cur_wdd.customer_id <> nvl(l_prev_wdd.customer_id, NULL_NUM) THEN
         l_progress := 'Use customer cursor to hash table';
         OPEN c_customer(l_cur_wdd.customer_id);
         FETCH c_customer INTO
           g_column_elements_table(get_column_hash_value('customer')).column_content,
           g_column_elements_table(get_column_hash_value('customer_number')).column_content;
         CLOSE c_customer;
      END IF;

      IF l_cur_wdd.project_id IS NOT NULL AND l_cur_wdd.project_id <> nvl(l_prev_wdd.project_id, NULL_NUM) THEN
         l_progress := 'Use project cursor to hash table';
         OPEN c_project(l_cur_wdd.project_id);
         FETCH c_project INTO
           g_column_elements_table(get_column_hash_value('project')).column_content;
         CLOSE c_project;
      END IF;

      IF l_cur_wdd.task_id IS NOT NULL AND l_cur_wdd.task_id <> nvl(l_prev_wdd.task_id, NULL_NUM) THEN
         l_progress := 'Use task cursor to hash table';
         OPEN c_task(l_cur_wdd.task_id);
         FETCH c_task INTO
           g_column_elements_table(get_column_hash_value('task')).column_content;
         CLOSE c_task;
      END IF;

      IF l_cur_wdd.lot_number IS NOT NULL AND l_cur_wdd.lot_number <> nvl(l_prev_wdd.lot_number, NULL_VAR) THEN
         l_progress := 'Use lot cursor to hash table';
         trace('c_lot_number '||l_cur_wdd.organization_id||' '||l_cur_wdd.inventory_item_id||' '||l_cur_wdd.lot_number);
         OPEN c_lot_number(l_cur_wdd.organization_id, l_cur_wdd.inventory_item_id, l_cur_wdd.lot_number);
         FETCH c_lot_number INTO
           g_column_elements_table(get_column_hash_value('lot_number_status')).column_content,
           g_column_elements_table(get_column_hash_value('lot_expiration_date')).column_content,
           g_column_elements_table(get_column_hash_value('lot_attribute_category')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute1')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute2')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute3')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute4')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute5')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute6')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute7')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute8')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute9')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute10')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute11')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute12')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute13')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute14')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute15')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute16')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute17')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute18')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute19')).column_content,
           g_column_elements_table(get_column_hash_value('lot_c_attribute20')).column_content,
           g_column_elements_table(get_column_hash_value('lot_d_attribute1')).column_content,
           g_column_elements_table(get_column_hash_value('lot_d_attribute2')).column_content,
           g_column_elements_table(get_column_hash_value('lot_d_attribute3')).column_content,
           g_column_elements_table(get_column_hash_value('lot_d_attribute4')).column_content,
           g_column_elements_table(get_column_hash_value('lot_d_attribute5')).column_content,
           g_column_elements_table(get_column_hash_value('lot_d_attribute6')).column_content,
           g_column_elements_table(get_column_hash_value('lot_d_attribute7')).column_content,
           g_column_elements_table(get_column_hash_value('lot_d_attribute8')).column_content,
           g_column_elements_table(get_column_hash_value('lot_d_attribute9')).column_content,
           g_column_elements_table(get_column_hash_value('lot_d_attribute10')).column_content,
           g_column_elements_table(get_column_hash_value('lot_n_attribute1')).column_content,
           g_column_elements_table(get_column_hash_value('lot_n_attribute2')).column_content,
           g_column_elements_table(get_column_hash_value('lot_n_attribute3')).column_content,
           g_column_elements_table(get_column_hash_value('lot_n_attribute4')).column_content,
           g_column_elements_table(get_column_hash_value('lot_n_attribute5')).column_content,
           g_column_elements_table(get_column_hash_value('lot_n_attribute6')).column_content,
           g_column_elements_table(get_column_hash_value('lot_n_attribute7')).column_content,
           g_column_elements_table(get_column_hash_value('lot_n_attribute8')).column_content,
           g_column_elements_table(get_column_hash_value('lot_n_attribute9')).column_content,
           g_column_elements_table(get_column_hash_value('lot_n_attribute10')).column_content,
           g_column_elements_table(get_column_hash_value('lot_country_of_origin')).column_content,
           g_column_elements_table(get_column_hash_value('lot_grade_code')).column_content,
           g_column_elements_table(get_column_hash_value('lot_origination_date')).column_content,
           g_column_elements_table(get_column_hash_value('lot_date_code')).column_content,
           g_column_elements_table(get_column_hash_value('lot_change_date')).column_content,
           g_column_elements_table(get_column_hash_value('lot_age')).column_content,
           g_column_elements_table(get_column_hash_value('lot_retest_date')).column_content,
           g_column_elements_table(get_column_hash_value('lot_maturity_date')).column_content,
           g_column_elements_table(get_column_hash_value('lot_item_size')).column_content,
           g_column_elements_table(get_column_hash_value('lot_color')).column_content,
           g_column_elements_table(get_column_hash_value('lot_volume')).column_content,
           g_column_elements_table(get_column_hash_value('lot_volume_uom')).column_content,
           g_column_elements_table(get_column_hash_value('lot_place_of_origin')).column_content,
           g_column_elements_table(get_column_hash_value('lot_best_by_date')).column_content,
           g_column_elements_table(get_column_hash_value('lot_length')).column_content,
           g_column_elements_table(get_column_hash_value('lot_length_uom')).column_content,
           g_column_elements_table(get_column_hash_value('lot_recycled_cont')).column_content,
           g_column_elements_table(get_column_hash_value('lot_thickness')).column_content,
           g_column_elements_table(get_column_hash_value('lot_thickness_uom')).column_content,
           g_column_elements_table(get_column_hash_value('lot_width')).column_content,
           g_column_elements_table(get_column_hash_value('lot_width_uom')).column_content,
           g_column_elements_table(get_column_hash_value('lot_curl')).column_content,
           g_column_elements_table(get_column_hash_value('lot_vendor')).column_content,
           g_column_elements_table(get_column_hash_value('parent_lot_number')).column_content,
           g_column_elements_table(get_column_hash_value('expiration_action_date')).column_content,
           g_column_elements_table(get_column_hash_value('origination_type')).column_content,
           g_column_elements_table(get_column_hash_value('hold_date')).column_content,
           g_column_elements_table(get_column_hash_value('expiration_action_code')).column_content,
           g_column_elements_table(get_column_hash_value('supplier_lot_number')).column_content;
         CLOSE c_lot_number;
      END IF;


      IF l_cur_wdd.outer_lpn_id IS NOT NULL AND l_cur_wdd.outer_lpn_id <> nvl(l_prev_wdd.outer_lpn_id, NULL_NUM) THEN
         l_progress := 'Use lpn cursor to hash table';
         OPEN c_lpn(l_cur_wdd.outer_lpn_id);
         FETCH c_lpn INTO
           g_column_elements_table(get_column_hash_value('lpn')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_volume')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_volume_uom')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_gross_weight')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_gross_weight_uom')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_tare_weight')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_tare_weight_uom')).column_content,
           l_cur_wdd.to_subinventory,
           l_cur_wdd.to_locator_id,
           l_cur_wdd.to_locator,
           g_column_elements_table(get_column_hash_value('lpn_attribute_category')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute1')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute2')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute3')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute4')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute5')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute6')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute7')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute8')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute9')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute10')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute11')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute12')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute13')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute14')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_attribute15')).column_content,
           g_column_elements_table(get_column_hash_value('lpn_container_item')).column_content;
         CLOSE c_lpn;


         IF l_cur_wdd.to_subinventory IS NOT NULL THEN
            g_column_elements_table(get_column_hash_value('to_subinventory')).column_content := l_cur_wdd.to_subinventory;
         END IF;
         IF l_cur_wdd.to_locator_id IS NOT NULL THEN
            g_column_elements_table(get_column_hash_value('to_locator')).column_content := l_cur_wdd.to_locator;
         END IF;

         -- Get Box Count
         --   Box Count = Number of Immediate Child LPNs of the Outer LPN
         BEGIN
            SELECT count(lpn_id)
            INTO g_column_elements_table(get_column_hash_value('box_count')).column_content
            FROM wms_license_plate_numbers
            WHERE parent_lpn_id IS NOT NULL
            AND   parent_lpn_id = l_cur_wdd.outer_lpn_id
            AND   outermost_lpn_id = l_cur_wdd.outer_lpn_id;

         EXCEPTION
            WHEN others THEN
               g_column_elements_table(get_column_hash_value('box_count')).column_content := NULL;
         END;

      END IF;


      IF nvl(l_cur_wdd.wnd_carrier_id, l_cur_wdd.carrier_id) IS NOT NULL AND
         nvl(l_cur_wdd.wnd_carrier_id, l_cur_wdd.carrier_id) <> nvl(nvl(l_prev_wdd.wnd_carrier_id, l_prev_wdd.carrier_id), NULL_NUM) THEN
         l_progress := 'Use carrier cursor to hash table';
         OPEN c_carrier(nvl(l_cur_wdd.wnd_carrier_id, l_cur_wdd.carrier_id));
         FETCH c_carrier INTO
            g_column_elements_table(get_column_hash_value('carrier')).column_content;
         CLOSE c_carrier;
      END IF;

      IF nvl(l_cur_wdd.wnd_ship_method_code, l_cur_wdd.ship_method_code) IS NOT NULL AND
         nvl(l_cur_wdd.wnd_ship_method_code, l_cur_wdd.ship_method_code) <> nvl(nvl(l_prev_wdd.wnd_ship_method_code, l_prev_wdd.ship_method_code), NULL_VAR) THEN
         l_progress := 'Use ship method cursor to hash table';
         OPEN c_ship_method(nvl(l_cur_wdd.wnd_ship_method_code, l_cur_wdd.ship_method_code) );
         FETCH c_ship_method INTO
            g_column_elements_table(get_column_hash_value('ship_method')).column_content;
         CLOSE c_ship_method;
      END IF;


      IF l_cur_wdd.ship_from_location_id IS NOT NULL AND l_cur_wdd.ship_from_location_id <> nvl(l_prev_wdd.ship_from_location_id, NULL_NUM) THEN
         l_progress := 'Use ship from cursor to hash table';
         OPEN c_address(l_cur_wdd.ship_from_location_id);
         FETCH c_address INTO
           g_column_elements_table(get_column_hash_value('ship_from_address1')).column_content,
           g_column_elements_table(get_column_hash_value('ship_from_address2')).column_content,
           g_column_elements_table(get_column_hash_value('ship_from_address3')).column_content,
           g_column_elements_table(get_column_hash_value('ship_from_address4')).column_content,
           g_column_elements_table(get_column_hash_value('ship_from_city')).column_content,
           g_column_elements_table(get_column_hash_value('ship_from_postal_code')).column_content,
           g_column_elements_table(get_column_hash_value('ship_from_state')).column_content,
           g_column_elements_table(get_column_hash_value('ship_from_county')).column_content,
           g_column_elements_table(get_column_hash_value('ship_from_country')).column_content,
           g_column_elements_table(get_column_hash_value('ship_from_province')).column_content,
           g_column_elements_table(get_column_hash_value('ship_from_location')).column_content,
           g_column_elements_table(get_column_hash_value('ship_from_location_description')).column_content;
         CLOSE c_address;
      END IF;
      IF l_cur_wdd.ship_to_location_id IS NOT NULL AND l_cur_wdd.ship_to_location_id <> nvl(l_prev_wdd.ship_to_location_id, NULL_NUM) THEN
         l_progress := 'Use ship to cursor to hash table';
         OPEN c_address(l_cur_wdd.ship_to_location_id);
         FETCH c_address INTO
           g_column_elements_table(get_column_hash_value('ship_to_address1')).column_content,
           g_column_elements_table(get_column_hash_value('ship_to_address2')).column_content,
           g_column_elements_table(get_column_hash_value('ship_to_address3')).column_content,
           g_column_elements_table(get_column_hash_value('ship_to_address4')).column_content,
           g_column_elements_table(get_column_hash_value('ship_to_city')).column_content,
           g_column_elements_table(get_column_hash_value('ship_to_postal_code')).column_content,
           g_column_elements_table(get_column_hash_value('ship_to_state')).column_content,
           g_column_elements_table(get_column_hash_value('ship_to_county')).column_content,
           g_column_elements_table(get_column_hash_value('ship_to_country')).column_content,
           g_column_elements_table(get_column_hash_value('ship_to_province')).column_content,
           g_column_elements_table(get_column_hash_value('customer_site')).column_content,
           g_column_elements_table(get_column_hash_value('ship_to_loc_desc')).column_content;
         CLOSE c_address;

         OPEN c_phone_fax(l_cur_wdd.ship_to_location_id, 'PHONE');
         FETCH c_phone_fax INTO
           g_column_elements_table(get_column_hash_value('customer_site_tel_number')).column_content;
         CLOSE c_phone_fax;

         OPEN c_phone_fax(l_cur_wdd.ship_to_location_id, 'FAX');
         FETCH c_phone_fax INTO
           g_column_elements_table(get_column_hash_value('customer_site_fax_number')).column_content;
         CLOSE c_phone_fax;

      END IF;

      IF l_cur_wdd.ship_to_site_use_id IS NOT NULL AND l_cur_wdd.ship_to_site_use_id <> nvl(l_prev_wdd.ship_to_site_use_id, NULL_NUM) THEN
         OPEN c_location(l_cur_wdd.ship_to_site_use_id);
         FETCH c_location INTO
           g_column_elements_table(get_column_hash_value('ship_to_location')).column_content;
         CLOSE c_location;
      END IF;

      IF l_cur_wdd.sold_to_contact_id IS NOT NULL AND l_cur_wdd.sold_to_contact_id <> nvl(l_prev_wdd.sold_to_contact_id, NULL_NUM) THEN
         OPEN c_contact(l_cur_wdd.sold_to_contact_id);
         FETCH c_contact INTO
            g_column_elements_table(get_column_hash_value('customer_contact_name')).column_content;
         CLOSE c_contact;
      END IF;

      IF l_cur_wdd.ship_to_contact_id IS NOT NULL AND l_cur_wdd.ship_to_contact_id <> nvl(l_prev_wdd.ship_to_contact_id, NULL_NUM) THEN
         OPEN c_contact(l_cur_wdd.ship_to_contact_id);
         FETCH c_contact INTO
            g_column_elements_table(get_column_hash_value('ship_to_contact_name')).column_content;
         CLOSE c_contact;
      END IF;

      IF l_cur_wdd.deliver_to_location_id IS NOT NULL AND l_cur_wdd.deliver_to_location_id <> nvl(l_prev_wdd.deliver_to_location_id, NULL_NUM) THEN
         l_progress := 'Use deliver to cursor to hash table';
         OPEN c_address(l_cur_wdd.deliver_to_location_id);
         FETCH c_address INTO
           g_column_elements_table(get_column_hash_value('deliver_to_address1')).column_content,
           g_column_elements_table(get_column_hash_value('deliver_to_address2')).column_content,
           g_column_elements_table(get_column_hash_value('deliver_to_address3')).column_content,
           g_column_elements_table(get_column_hash_value('deliver_to_address4')).column_content,
           g_column_elements_table(get_column_hash_value('deliver_to_city')).column_content,
           g_column_elements_table(get_column_hash_value('deliver_to_postal_code')).column_content,
           g_column_elements_table(get_column_hash_value('deliver_to_state')).column_content,
           g_column_elements_table(get_column_hash_value('deliver_to_county')).column_content,
           g_column_elements_table(get_column_hash_value('deliver_to_country')).column_content,
           g_column_elements_table(get_column_hash_value('deliver_to_province')).column_content,
           g_column_elements_table(get_column_hash_value('deliver_to_site')).column_content,
           g_column_elements_table(get_column_hash_value('deliver_to_loc_desc')).column_content;
         CLOSE c_address;

         OPEN c_phone_fax(l_cur_wdd.deliver_to_location_id, 'PHONE');
         FETCH c_phone_fax INTO
           g_column_elements_table(get_column_hash_value('deliver_to_phone')).column_content;
         CLOSE c_phone_fax;

         OPEN c_phone_fax(l_cur_wdd.deliver_to_location_id, 'FAX');
         FETCH c_phone_fax INTO
           g_column_elements_table(get_column_hash_value('deliver_to_fax')).column_content;
         CLOSE c_phone_fax;

      END IF;

      IF l_cur_wdd.deliver_to_site_use_id IS NOT NULL AND l_cur_wdd.deliver_to_site_use_id <> nvl(l_prev_wdd.deliver_to_site_use_id, NULL_NUM) THEN
         OPEN c_location(l_cur_wdd.deliver_to_site_use_id);
         FETCH c_location INTO
           g_column_elements_table(get_column_hash_value('deliver_to_location')).column_content;
         CLOSE c_location;
      END IF;

      IF l_cur_wdd.deliver_to_contact_id IS NOT NULL AND l_cur_wdd.deliver_to_contact_id <> nvl(l_prev_wdd.deliver_to_contact_id, NULL_NUM) THEN
         OPEN c_contact(l_cur_wdd.deliver_to_contact_id);
         FETCH c_contact INTO
            g_column_elements_table(get_column_hash_value('deliver_to_contact_name')).column_content;
         CLOSE c_contact;
      END IF;

      IF l_cur_wdd.intmed_ship_to_location_id IS NOT NULL AND l_cur_wdd.intmed_ship_to_location_id <> nvl(l_prev_wdd.intmed_ship_to_location_id, NULL_NUM) THEN
         l_progress := 'Use intmed cursor to hash table';
         OPEN c_address(l_cur_wdd.intmed_ship_to_location_id);
         FETCH c_address INTO
           g_column_elements_table(get_column_hash_value('interm_ship_to_address1')).column_content,
           g_column_elements_table(get_column_hash_value('interm_ship_to_address2')).column_content,
           g_column_elements_table(get_column_hash_value('interm_ship_to_address3')).column_content,
           g_column_elements_table(get_column_hash_value('interm_ship_to_address4')).column_content,
           g_column_elements_table(get_column_hash_value('interm_ship_to_city')).column_content,
           g_column_elements_table(get_column_hash_value('interm_ship_to_postal_code')).column_content,
           g_column_elements_table(get_column_hash_value('interm_ship_to_state')).column_content,
           g_column_elements_table(get_column_hash_value('interm_ship_to_county')).column_content,
           g_column_elements_table(get_column_hash_value('interm_ship_to_country')).column_content,
           g_column_elements_table(get_column_hash_value('interm_ship_to_province')).column_content,
           g_column_elements_table(get_column_hash_value('interm_ship_to_location')).column_content,
           g_column_elements_table(get_column_hash_value('interm_ship_to_loc_desc')).column_content;
         CLOSE c_address;
      END IF;


      IF l_cur_wdd.intmed_ship_to_contact_id IS NOT NULL AND l_cur_wdd.intmed_ship_to_contact_id <> nvl(l_prev_wdd.intmed_ship_to_contact_id, NULL_NUM) THEN
         OPEN c_contact(l_cur_wdd.intmed_ship_to_contact_id);
         FETCH c_contact INTO
            g_column_elements_table(get_column_hash_value('interm_ship_to_contact_name')).column_content;
         CLOSE c_contact;
      END IF;

      IF l_cur_wdd.source_line_id IS NOT NULL AND l_cur_wdd.source_line_id <> nvl(l_prev_wdd.source_line_id, NULL_NUM) THEN
         OPEN c_so_line(l_cur_wdd.source_line_id);
         FETCH c_so_line INTO
           g_column_elements_table(get_column_hash_value('schd_shp_dt_ord_lines')).column_content,
           g_column_elements_table(get_column_hash_value('req_dt_ord_lines')).column_content,
           g_column_elements_table(get_column_hash_value('promise_dt_ord_lines')).column_content,
           g_column_elements_table(get_column_hash_value('shpmnt_priority_cd_ord_lines')).column_content,
           l_cur_wdd.oe_ship_method_code,
           g_column_elements_table(get_column_hash_value('freight_car_cd_ord_lines')).column_content,
           g_column_elements_table(get_column_hash_value('schd_arr_dt_ord_lines')).column_content,
           g_column_elements_table(get_column_hash_value('actual_shp_dt_ord_lines')).column_content,
           g_column_elements_table(get_column_hash_value('shppng_instructions_ord_lines')).column_content,
           g_column_elements_table(get_column_hash_value('pkg_instructions_dt_ord_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att1_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att2_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att3_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att4_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att5_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att6_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att7_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att8_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att9_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att10_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att11_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att12_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att13_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att14_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('att15_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att1_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att2_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att3_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att4_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att5_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att6_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att7_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att8_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att9_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att10_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att11_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att12_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att13_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att14_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att15_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att16_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att17_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att18_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att19_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('global_att20_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('pricing_att1_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('pricing_att2_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('pricing_att3_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('pricing_att4_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('pricing_att5_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('pricing_att6_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('pricing_att7_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('pricing_att8_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('pricing_att9_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('pricing_att10_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att1_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att2_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att3_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att4_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att5_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att6_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att7_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att8_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att9_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att10_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att11_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att12_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att13_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att14_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att15_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att16_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att17_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att18_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att19_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att20_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att21_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att22_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att23_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att24_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att25_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att26_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att27_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att28_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att29_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('industry_att30_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att1_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att2_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att3_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att4_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att5_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att6_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att7_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att8_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att9_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att10_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att11_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att12_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att13_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att14_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('return_att15_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att1_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att2_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att3_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att4_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att5_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att6_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att7_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att8_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att9_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att10_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att11_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att12_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att13_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att14_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att15_order_lines')).column_content,
           g_column_elements_table(get_column_hash_value('ordered_item')).column_content;
         CLOSE c_so_line;
      END IF;

      IF l_cur_wdd.oe_ship_method_code IS NOT NULL AND l_cur_wdd.oe_ship_method_code <> nvl(l_prev_wdd.oe_ship_method_code, NULL_VAR) THEN
         OPEN c_ship_method(l_cur_wdd.oe_ship_method_code);
         FETCH c_ship_method INTO
            g_column_elements_table(get_column_hash_value('shppng_mthd_cd_ord_lines')).column_content;
         CLOSE c_ship_method;
      END IF;

      IF l_cur_wdd.source_header_id IS NOT NULL AND l_cur_wdd.source_header_id <> nvl(l_prev_wdd.source_header_id, NULL_NUM) THEN
         OPEN c_so_header(l_cur_wdd.source_header_id);
         FETCH c_so_header INTO
           g_column_elements_table(get_column_hash_value('att1_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('att2_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('att3_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('att4_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('att5_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('att6_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('att7_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('att8_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('att9_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('att10_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('att11_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('att12_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('att13_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('att14_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('att15_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att1_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att2_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att3_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att4_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att5_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att6_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att7_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att8_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att9_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att10_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att11_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att12_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att13_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att14_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att15_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att16_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att17_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att18_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att19_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('global_att20_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att1_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att2_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att3_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att4_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att5_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att6_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att7_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att8_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att9_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att10_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att11_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att12_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att13_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att14_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('tp_att15_order_headers')).column_content,
           g_column_elements_table(get_column_hash_value('sales_channel_code')).column_content,
           g_column_elements_table(get_column_hash_value('shipping_instructions')).column_content,
           g_column_elements_table(get_column_hash_value('packing_instructions')).column_content;

         CLOSE c_so_header;
      END IF;


      -- GTIN support
      INV_LABEL.IS_ITEM_GTIN_ENABLED(
          x_return_status      =>   l_return_status
        , x_gtin_enabled       =>   l_gtin_enabled
        , x_gtin               =>   l_gtin
        , x_gtin_desc          =>   l_gtin_desc
        , p_organization_id    =>   l_cur_wdd.organization_id
        , p_inventory_item_id  =>   l_cur_wdd.inventory_item_id
        , p_unit_of_measure    =>   l_cur_wdd.uom
        , p_revision           =>   l_cur_wdd.revision);
      g_column_elements_table(get_column_hash_value('gtin')).column_content := l_gtin;
      g_column_elements_table(get_column_hash_value('gtin_description')).column_content := l_gtin_desc;


      -- Finished retrieving all data
      -- Start writing into xml

    -- Bug 9261874 for loop for printing serial attached with one WDD.

    FOR i IN 1..l_wdd_loop_counter LOOP

      l_content_rec_index := l_content_rec_index + 1;    -- loop for total number of records..
      row_index_per_label := row_index_per_label + 1;    -- counter for the number of records per label

      IF (new_label) THEN
         -- New Piece of label
         l_label_index := l_label_index + 1;
         IF (l_content_rec_index = 1) THEN
            -- First label
            -- Use rules engine to get format
            l_use_rules_engine := 'Y';
         ELSE
            l_use_rules_engine := 'N';
         END IF;


-- Added for bug 8454264 8486711 start
	IF (l_debug = 1) THEN
		trace(' l_cur_wdd.delivery_id  '|| l_cur_wdd.delivery_id);
        END IF;

        IF (l_cur_wdd.delivery_id IS NOT NULL ) THEN
            OPEN  c_cust_details(l_cur_wdd.delivery_id);
            FETCH c_cust_details INTO l_cust_site_id ;
		    IF c_cust_details%NOTFOUND THEN
		      IF (l_debug = 1) THEN
			  trace(' No cust details found for this delivery: '|| l_cur_wdd.delivery_id);
		      END IF;
		      l_cust_site_id := NULL;
		    END IF;
            CLOSE c_cust_details;
	    IF (l_debug = 1) THEN
		  trace('cust details found for this delivery: '|| l_cur_wdd.delivery_id);
		  trace('l_cust_site_id '|| l_cust_site_id);
            END IF;
        END IF;
 -- Added for bug 8454264  8486711 end



         INV_LABEL.GET_FORMAT_WITH_RULE
         (  p_document_id        =>p_label_type_info.label_type_id,
            p_label_format_id    =>p_label_type_info.manual_format_id,
            p_organization_id    =>l_cur_wdd.organization_id,
            p_inventory_item_id  =>l_cur_wdd.inventory_item_id,
            p_subinventory_code  =>nvl(l_cur_wdd.from_subinventory,l_cur_wdd.to_subinventory),
            p_locator_id         =>nvl(l_cur_wdd.from_locator_id,l_cur_wdd.to_locator_id),
            p_lpn_id             =>l_cur_wdd.outer_lpn_id,
            p_lot_number         =>l_cur_wdd.lot_number,
            p_revision           =>l_cur_wdd.revision,
            p_customer_id        =>l_cur_wdd.customer_id,
            P_CUSTOMER_SITE_ID   =>l_cust_site_id, --8454264 8486711
	    p_customer_contact_id=>l_cur_wdd.sold_to_contact_id,
            p_freight_code       =>g_column_elements_table(get_column_hash_value('freight_car_cd_ord_lines')).column_content,
            p_delivery_id        =>l_cur_wdd.delivery_id,
            p_last_update_date   =>sysdate,
            p_last_updated_by    =>fnd_global.user_id,
            p_creation_date      =>sysdate,
            p_created_by         =>fnd_global.user_id,
            p_business_flow_code => p_label_type_info.business_flow_code,
            p_customer_item_id   => l_cur_wdd.customer_item_id,
            p_sales_order_header_id  => l_cur_wdd.source_header_id,
            p_sales_order_line_id    => l_cur_wdd.source_line_id,
            p_use_rule_engine    => 'Y',
            x_return_status      =>l_return_status,
            x_label_format_id    =>l_label_format_id,
            x_label_format       =>l_label_format,
            x_label_request_id   =>l_label_request_id);

         IF l_return_status <> 'S' THEN
            IF (l_debug = 1) THEN
               trace(' Error in applying rules engine, setting as default');
            END IF;

            IF l_content_rec_index = 1 THEN
                  l_label_format := p_label_type_info.default_format_name;
                  l_label_format_id := p_label_type_info.default_format_id;
                  l_prev_format_id := l_label_format_id;
            ELSIF (new_label) THEN
                  l_label_format_id := l_prev_format_id;

            END IF;
         ELSE
            l_prev_format_id := l_label_format_id;
         END IF;

         IF (l_debug = 1) THEN
            trace(' After rules engine Label Format : '||l_label_format || ' Label Format ID :' || l_label_format_id||' label request id'||l_label_request_id);
            trace(' Getting selected fields ');
         END IF;
         INV_LABEL.get_variables_for_format
         (
            x_variables       => l_selected_fields
          , x_variables_count => l_selected_fields_count
          , p_format_id       => l_label_format_id);

         IF (l_selected_fields_count=0) OR (l_selected_fields.count =0 ) THEN
            IF (l_debug = 1) THEN
               trace('no fields defined for this format: ' ||  l_label_format_id || ',' || l_label_format);
               trace('Can not continue to print');
            END IF;
            EXIT;
         END IF;

         build_format_fields_structure (l_label_format_id);

         -- Getting No. of rows per label
         BEGIN
            SELECT min(a.count)
              INTO no_of_rows_per_label
              FROM (SELECT wlfv.label_field_id,
               count(*) count
               FROM wms_label_field_variables wlfv
               WHERE wlfv.label_format_id = l_label_format_id
               GROUP BY wlfv.label_field_id
               HAVING count(*) > 1) a;

            IF (no_of_rows_per_label IS NULL) OR  (no_of_rows_per_label=0) THEN
               no_of_rows_per_label := 1;
            END IF;
            -- Also, get max number of rows defined.
            -- It might be greater than the actual number of rows per label
            -- For example, the user setup as
            -- _ITEM1, _ITEM2   and  _QTY1, _QTY2, _QTY3
            -- Then the number of rows per label is 2 and max_no_of_rows_defined is 3.

            SELECT max(a.count)
              INTO max_no_of_rows_defined
              FROM (SELECT wlfv.label_field_id,
               count(*) count
               FROM wms_label_field_variables wlfv
               WHERE wlfv.label_format_id = l_label_format_id
               GROUP BY wlfv.label_field_id
               HAVING count(*) > 1) a;

            IF (l_debug = 1) THEN
               trace(' Max number of rows defined = '|| max_no_of_rows_defined);
            END IF;
            IF (max_no_of_rows_defined IS NULL ) OR (max_no_of_rows_defined=0) THEN
               max_no_of_rows_defined := 0;
            END IF;

         EXCEPTION
            WHEN no_data_found THEN
               IF (l_debug = 1) THEN
                  trace(' Did not find defined rows, can not proceed ');
               END IF;
               EXIT;
         END;

         IF (l_debug = 1) THEN
            trace(' Got no. of rows per label='|| no_of_rows_per_label);
            trace(' Found variable defined for this format, cont = ' || l_selected_fields_count);
         END IF;

         -- Getting printer with Label Format ID
         IF p_label_type_info.manual_printer IS NULL THEN
            -- The p_label_type_info.manual_printer is the one  passed from the manual page.
            -- As per the design, if a printer is passed from the manual page, then we use that printer irrespective.
             WSH_REPORT_PRINTERS_PVT.GET_PRINTER(
               p_concurrent_program_id=>p_label_type_info.label_type_id,
               p_user_id              =>fnd_global.user_id,
               p_responsibility_id    =>fnd_global.resp_id,
               p_application_id       =>fnd_global.resp_appl_id,
               p_organization_id      =>l_cur_wdd.organization_id,
               p_zone                 =>nvl(l_cur_wdd.from_subinventory,l_cur_wdd.to_subinventory),
               p_format_id            =>l_label_format_id,
               x_printer              =>l_printer,
               x_api_status           =>l_api_status,
               x_error_message        =>l_error_message);
            IF l_api_status <> 'S' THEN
               IF (l_debug = 1) THEN
                  trace('Error in GET_PRINTER '||l_error_message);
               END IF;
               l_printer := p_label_type_info.default_printer;
            END IF;
         ELSE
            l_printer := p_label_type_info.manual_printer;
         END IF;
         IF (l_debug = 1) THEN
            trace('Got Printer '||l_printer);
         END IF;

         --Writing <LABEL ...> tag
         l_shipping_content_data := l_shipping_content_data || LABEL_B;

         IF (l_label_format IS NOT NULL) AND
            (l_label_format_id <> nvl(p_label_type_info.default_format_id, NULL_NUM)) THEN
            l_shipping_content_data := l_shipping_content_data || ' _FORMAT="' || l_label_format || '"';
         END IF;

         IF (l_printer IS NOT NULL) THEN
	 -- Commented the AND condition for Bug: 5402949
         -- AND (l_printer <> nvl(p_label_type_info.default_printer, NULL_VAR)) THEN
            l_shipping_content_data := l_shipping_content_data || ' _PRINTERNAME="'||l_printer||'"';
         END IF;

         l_shipping_content_data := l_shipping_content_data || TAG_E;

         new_label := false;
      END IF; -- IF (new_label)

      /* Loop for each selected fields, find the columns and write into the XML_content*/
      OPEN c_fields_for_format (l_label_format_id);

      l_variable_list := '';
      l_custom_sql_ret_status := FND_API.G_RET_STS_SUCCESS;

      LOOP -- Loop for c_fields_for_format
         FETCH c_fields_for_format
         INTO l_column_name_in_format;
         EXIT WHEN c_fields_for_format%notfound;

         ---------------------------------------------------------------------------------------------
         -- Project: 'Custom Labels' (A 11i10+ Project)                                               |
         -- Author: Dinesh (dchithir@oracle.com)                                                      |
         -- Change Description:                                                                       |
         --  For the column name 'sql_stmt', if the variable name is not null implies that the field  |
         --  is a Custom SQL. For this variable name, get the corresponding SQL statement using the   |
         --  function get_sql_for_variable(). Handle the sql appropriately.                           |
         ---------------------------------------------------------------------------------------------
         l_count_custom_sql := 0; -- Added for Bug#4179391
         Loop -- Added for Bug#4179391
            EXIT WHEN l_count_custom_sql >= g_count_custom_sql; -- Added for Bug#4179391
            -- Added following IF clause for bug 4190764
            IF l_column_name_in_format = 'sql_stmt' THEN
               --l_variable_name := get_variable_name('sql_stmt', row_index_per_label-1, l_label_format_id); -- Commented the statment to replace row_index_per_label with l_count_custom_sql
               l_variable_name := get_variable_name('sql_stmt', l_count_custom_sql, l_label_format_id); -- Added for Bug#4179391
               IF l_variable_name IS NOT NULL THEN
                  --l_sql_stmt := get_sql_for_variable('sql_stmt', row_index_per_label-1, l_label_format_id); -- Commented the statment to replace row_index_per_label with l_count_custom_sql
                  l_sql_stmt := get_sql_for_variable('sql_stmt', l_count_custom_sql, l_label_format_id); -- Added for Bug#4179391
                  IF (l_sql_stmt IS NOT NULL) THEN
                     IF (l_debug = 1) THEN
                        trace('Custom Labels Trace [INVLAP8B.pls]: ------------------------- REPORT BEGIN-------------------------------------');
                        trace('Custom Labels Trace [INVLAP8B.pls]: FIELD_VARIABLE_NAME  : ' || l_variable_name);
                        trace('Custom Labels Trace [INVLAP8B.pls]: l_sql_stmt BEFORE REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
                     END IF;
                     l_sql_stmt := l_sql_stmt || ' AND WLR.LABEL_REQUEST_ID = :REQUEST_ID';
                     IF (l_debug = 1) THEN
                        trace('Custom Labels Trace [INVLAP8B.pls]: l_sql_stmt AFTER REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
                     END IF;
                     BEGIN
                        IF (l_debug = 1) THEN
                           trace('Custom Labels Trace [INVLAP8B.pls]: At Breadcrumb 1');
                           trace('Custom Labels Trace [INVLAP8B.pls]: LABEL_REQUEST_ID : ' || l_label_request_id);
                        END IF;
                        OPEN c_sql_stmt FOR l_sql_stmt using l_label_request_id;
                        LOOP
                              FETCH c_sql_stmt INTO l_sql_stmt_result;
                              EXIT WHEN c_sql_stmt%notfound OR c_sql_stmt%rowcount >=2;
                        END LOOP;

                        IF (c_sql_stmt%rowcount=1 AND l_sql_stmt_result IS NULL) THEN
                           x_return_status := FND_API.G_RET_STS_SUCCESS;
                           l_custom_sql_ret_status := INV_LABEL.G_WARNING;
                           fnd_message.set_name('WMS','WMS_CS_NULL_VALUE_RETURNED');
                           fnd_msg_pub.ADD;
                           -- Fix for bug: 4179593 Start
                           --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                           l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                           l_CustSqlWarnMsg := l_custom_sql_ret_msg;
                           l_CustSqlWarnFlagSet := TRUE;
                           -- Fix for bug: 4179593 End
                           IF (l_debug = 1) THEN
                              trace('Custom Labels Trace [INVLAP8B.pls]: At Breadcrumb 2');
                              trace('Custom Labels Trace [INVLAP8B.pls]: l_sql_stmt_result is: ' || l_sql_stmt_result);
                              trace('Custom Labels Trace [INVLAP8B.pls]: WARNING: NULL value returned by the custom SQL Query.');
                              trace('Custom Labels Trace [INVLAP8B.pls]: l_custom_sql_ret_status is set to : ' || l_custom_sql_ret_status);
                           END IF;
                        ELSIF c_sql_stmt%rowcount=0 THEN
                           IF (l_debug = 1) THEN
                              trace('Custom Labels Trace [INVLAP8B.pls]: At Breadcrumb 3');
                              trace('Custom Labels Trace [INVLAP8B.pls]: WARNING: No row returned by the Custom SQL query');
                           END IF;
                           x_return_status := FND_API.G_RET_STS_SUCCESS;
                           l_custom_sql_ret_status := INV_LABEL.G_WARNING;
                           fnd_message.set_name('WMS','WMS_CS_NO_DATA_FOUND');
                           fnd_msg_pub.ADD;
                           -- Fix for bug: 4179593 Start
                           --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                           l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                           l_CustSqlWarnMsg := l_custom_sql_ret_msg;
                           l_CustSqlWarnFlagSet := TRUE;
                           -- Fix for bug: 4179593 End
                        ELSIF c_sql_stmt%rowcount>=2 THEN
                           IF (l_debug = 1) THEN
                              trace('Custom Labels Trace [INVLAP8B.pls]: At Breadcrumb 4');
                              trace('Custom Labels Trace [INVLAP8B.pls]: ERROR: Multiple values returned by the Custom SQL query');
                           END IF;
                           x_return_status := FND_API.G_RET_STS_SUCCESS;
                           l_custom_sql_ret_status := FND_API.G_RET_STS_ERROR;
                           fnd_message.set_name('WMS','WMS_CS_MULTIPLE_VALUES_RETURN');
                           fnd_msg_pub.ADD;
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
                              trace('Custom Labels Trace [INVLAP8B.pls]: At Breadcrumb 5');
                              trace('Custom Labels Trace [INVLAP8B.pls]: Unexpected Error has occured in GET_VARIABLES_DATA');
                           END IF;
                           x_return_status := FND_API.G_RET_STS_ERROR;
                           fnd_message.set_name('WMS','WMS_CS_WRONG_SQL_CONSTRUCT');
                           fnd_msg_pub.ADD;
                           fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END;
                     IF (l_debug = 1) THEN
                        trace('Custom Labels Trace [INVLAP8B.pls]: At Breadcrumb 6');
                        trace('Custom Labels Trace [INVLAP8B.pls]: Before assigning it to l_shipping_content_data');
                     END IF;
                     l_shipping_content_data  :=   l_shipping_content_data
                                      || variable_b
                                      || l_variable_name
                                      || '">'
                                      || l_sql_stmt_result
                                      || variable_e;
                     l_sql_stmt_result := NULL;
                     l_sql_stmt        := NULL;
                     IF (l_debug = 1) THEN
                        trace('Custom Labels Trace [INVLAP8B.pls]: At Breadcrumb 7');
                        trace('Custom Labels Trace [INVLAP8B.pls]: After assigning it to l_shipping_content_data');
                        trace('Custom Labels Trace [INVLAP8B.pls]: --------------------------REPORT END-------------------------------------');
                     END IF;
                  END IF;
               END IF;
           -- Added following END IF for bug 4190764
            END IF;
            l_count_custom_sql := l_count_custom_sql + 1; -- Added for Bug#4179391
         END LOOP; -- Added for Bug#4179391
         ------------------------End of this change for Custom Labels project code--------------------


         l_variable_name := get_variable_name(l_column_name_in_format, row_index_per_label-1, l_label_format_id);
         IF l_variable_name IS NOT NULL THEN
            -- Modified the following ELSIF clause for the Bug9261874
            IF (l_column_name_in_format <> 'sql_stmt') AND (l_column_name_in_format <> 'serial_number') THEN
               l_variable_list := l_variable_list ||','||l_variable_name;
               l_shipping_content_data := l_shipping_content_data || VARIABLE_B ||
                   l_variable_name || '">' || g_column_elements_table(get_column_hash_value(l_column_name_in_format)).column_content || VARIABLE_E;
            END IF;
            --Bug 9261874, Looping over l_range_serial_numbers to print the contained serial numbers.
            IF (l_column_name_in_format = 'serial_number') THEN
                IF (l_range_serial_numbers.COUNT = 0) THEN
                    l_shipping_content_data := l_shipping_content_data || VARIABLE_B || l_variable_name || '">' || VARIABLE_E;
                ELSE
                    IF (l_debug = 1) THEN
                        trace ('Retrive value from l_range_serial_numbers');
                    END IF;
                    l_shipping_content_data := l_shipping_content_data || VARIABLE_B ||
                                               l_variable_name ||'">' || l_range_serial_numbers(i) || VARIABLE_E;
                END IF;
            END IF;
            -- End of Bug 9261874
         END IF;
      END LOOP; -- Loop for c_fields_for_format

      CLOSE c_fields_for_format;

      IF(l_debug = 1) THEN
         trace('Set value for variables '||l_variable_list);
      END IF;

      /*IF (l_debug = 1) THEN
           trace('   l_shipping_content_data =  '|| l_shipping_content_data);
      END IF;*/

      -- When finished writing all rows in the label
      --  or next LPN is a new label
      -- Start a new label

      IF (row_index_per_label = no_of_rows_per_label) OR
         ((l_wdd_index = l_wdd_tb.count) AND (i = l_wdd_loop_counter)) OR  --Bug9261874
         ((l_wdd_index < l_wdd_tb.count) AND
          (nvl(l_cur_wdd.outer_lpn_id, NULL_NUM) <> nvl(l_wdd_tb(l_wdd_index+1).outer_lpn_id, NULL_NUM))) THEN
         IF (l_debug = 1) THEN
            trace('This record is the end of a label.');
         END IF;

         -- Finished writing all rows in a label
         -- Find any extra fields that needs to written with NULL value
         -- (this is for the case where there are ITEM1, ITEM2, but QTY1, QTY2, QTY3
         --  QTY3 is a extra incorrect setup and it always has value of NULL)
         FOR i IN (row_index_per_label+1)..max_no_of_rows_defined LOOP
            FOR j IN 1..l_selected_fields.count LOOP
               IF j=1 OR
                  l_selected_fields(j).column_name <> l_selected_fields(j-1).column_name THEN
                  l_variable_name := get_variable_name(l_selected_fields(j).column_name,
                           i-1, l_label_format_id);
                  IF l_variable_name IS NOT NULL THEN
                     trace(' Found extra row to pass NULL=> '|| l_variable_name);
                     l_shipping_content_data := l_shipping_content_data || VARIABLE_B ||
                       l_variable_name || '">' ||'' || VARIABLE_E;
                  END IF;
               END IF;
            END LOOP;
         END LOOP;
         new_label := true;
         -- Finished creating one label, close with '</LABEL>', save into result table
         l_shipping_content_data := l_shipping_content_data || LABEL_E;
         trace('writing into table, l_index ='||l_label_index||', req_id='||l_label_request_id);
         x_variable_content(l_label_index).label_content := l_shipping_content_data;
         x_variable_content(l_label_index).label_request_id := l_label_request_id;

         IF (l_CustSqlWarnFlagSet) THEN
            l_custom_sql_ret_status := INV_LABEL.G_WARNING;
            l_custom_sql_ret_msg := l_CustSqlWarnMsg;
         END IF;

         IF (l_CustSqlErrFlagSet) THEN
            l_custom_sql_ret_status := FND_API.G_RET_STS_ERROR;
            l_custom_sql_ret_msg := l_CustSqlErrMsg;
         END IF;
         -- Fix for bug: 4179593 End

         x_variable_content(l_label_index).label_status      := l_custom_sql_ret_status;
         x_variable_content(l_label_index).error_message     := l_custom_sql_ret_msg;


         l_custom_sql_ret_status := NULL;
         l_custom_sql_ret_msg    := NULL;

         l_shipping_content_data := '';
         row_index_per_label := 0;
      END IF;
     END LOOP; --Bug9261874 end of 'for' loop for serial.
   END LOOP; -- l_wdd_tb Loop

   l_label_index := l_label_index - 1;
   IF (row_index_per_label < no_of_rows_per_label) AND (new_label=false) THEN
      -- Last label is partial
      -- Loop for the rest of the rows that don't have value,
      -- we need to pass NULL.
      FOR i IN (row_index_per_label+1)..max_no_of_rows_defined LOOP
         FOR j IN 1..l_selected_fields.count LOOP
            IF j=1 OR
               l_selected_fields(j).column_name <> l_selected_fields(j-1).column_name THEN
               l_variable_name := get_variable_name(l_selected_fields(j).column_name,
                      i-1, l_label_format_id);
               IF l_variable_name IS NOT NULL THEN
                  --trace(' Found extra row to pass NULL=> '|| l_variable_name);
                  l_shipping_content_data := l_shipping_content_data || VARIABLE_B ||
                      l_variable_name || '">' ||'' || VARIABLE_E;
               END IF;
            END IF;
         END LOOP;
      END LOOP;
      l_shipping_content_data := l_shipping_content_data || LABEL_E;
      x_variable_content(l_label_index).label_content := l_shipping_content_data;
      x_variable_content(l_label_index).label_request_id := l_label_request_id;
      l_shipping_content_data := '';
   END IF;
EXCEPTION
   WHEN others THEN
      IF(l_debug=1) THEN
         trace('Error in INV_LABEL_PVT8.get_variable_data');
         trace('Progress is '||l_progress);
         trace('ERROR CODE = ' || SQLCODE);
         trace('ERROR MESSAGE = ' || SQLERRM);


      END IF;
END get_variable_data;


/* Overloaded signature which x_variable_content is a long string
   rather than seperate records */
PROCEDURE get_variable_data(
   x_variable_content   OUT NOCOPY LONG
,  x_msg_count          OUT NOCOPY NUMBER
,  x_msg_data           OUT NOCOPY VARCHAR2
,  x_return_status      OUT NOCOPY VARCHAR2
,  p_label_type_info    IN  INV_LABEL.label_type_rec
,  p_transaction_id     IN  NUMBER
,  p_input_param        IN  MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
,  p_transaction_identifier IN NUMBER
) IS
   l_variable_data_tbl INV_LABEL.label_tbl_type;
BEGIN
   get_variable_data(
      x_variable_content   => l_variable_data_tbl
   ,  x_msg_count          => x_msg_count
   ,  x_msg_data           => x_msg_data
   ,  x_return_status      => x_return_status
   ,  p_label_type_info    => p_label_type_info
   ,  p_transaction_id     => p_transaction_id
   ,  p_input_param        => p_input_param
   ,  p_transaction_identifier=> p_transaction_identifier
   );

   x_variable_content := '';

   FOR i IN 1..l_variable_data_tbl.count() LOOP
      x_variable_content := x_variable_content || l_variable_data_tbl(i).label_content;
   END LOOP;


END get_variable_data;

END INV_LABEL_PVT8;

/
