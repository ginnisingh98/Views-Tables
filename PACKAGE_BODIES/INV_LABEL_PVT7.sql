--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PVT7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PVT7" AS
/* $Header: INVLAP7B.pls 120.7.12010000.3 2009/08/07 11:24:34 abasheer ship $ */

LABEL_B     CONSTANT VARCHAR2(50) := '<label';
LABEL_E     CONSTANT VARCHAR2(50) := '</label>'||fnd_global.local_chr(10);
VARIABLE_B  CONSTANT VARCHAR2(50) := '<variable name= "';
VARIABLE_E  CONSTANT VARCHAR2(50) := '</variable>'||fnd_global.local_chr(10);
TAG_E    CONSTANT VARCHAR2(50)  := '>'||fnd_global.local_chr(10);
l_debug number;


PROCEDURE trace(p_message IN VARCHAR2) iS
BEGIN
      inv_label.trace(p_message, 'LABEL_SHIPPING');
END trace;

FUNCTION get_total_number_of_lpns(p_delivery_id IN NUMBER) RETURN NUMBER
IS
   l_lpn_count    NUMBER := 0;
BEGIN
   SELECT count(*)  INTO l_lpn_count
   FROM wsh_delivery_assignments_v
   WHERE delivery_id = p_delivery_id
   AND  parent_delivery_detail_id is null;
      RETURN l_lpn_count;
EXCEPTION
   WHEN no_data_found THEN
   RETURN  0;

END get_total_number_of_lpns;

   --Bug# 5051977. Added the following function.
   --This function will return 'Y' if there is a label aready printed for this LPN
   --and delivery; otherwise it returns 'N'. This is used only for pick drop.
   FUNCTION check_duplicate_label ( p_delivery_id IN NUMBER, p_transaction_id IN NUMBER)
   RETURN VARCHAR2
   IS
      CURSOR Dup_Staging_txn_cur IS
          SELECT 'Y'
          FROM mtl_material_transactions mmt ,
               mtl_material_transactions_temp mmtt,
               wsh_delivery_assignments wda,
               wsh_delivery_details wdd
          WHERE mmtt.transaction_temp_id     = p_transaction_id
          AND wda.delivery_id                = p_delivery_id
          AND mmt.organization_id            = mmtt.organization_id
          AND mmt.transaction_source_type_id IN (INV_GLOBALS.G_SOURCETYPE_SALESORDER,INV_GLOBALS.G_SOURCETYPE_INTORDER)
          AND mmt.transaction_action_id      = INV_GLOBALS.G_ACTION_STGXFR
          AND mmtt.transfer_lpn_id           = mmt.transfer_lpn_id
          AND mmt.move_order_line_id         = wdd.move_order_line_id
          AND wda.delivery_detail_id         = wdd.delivery_detail_id
          AND ROWNUM<2;

      l_dup_label  VARCHAR2(1):= 'N';
      l_debug       NUMBER  := INV_LABEL.l_debug;
   BEGIN
         IF (l_debug = 1) THEN
             trace('In duplicate label check for del:'|| p_delivery_id||'tranxid:'||p_transaction_id);
         End if;
         OPEN  Dup_Staging_txn_cur ;
         FETCH Dup_Staging_txn_cur INTO l_dup_label ;
         CLOSE Dup_Staging_txn_cur;
         IF ( l_dup_label = 'Y' AND l_debug = 1 ) THEN
              trace('There is a label already printed for this LPN and delivery.');
         END IF;
         RETURN l_dup_label;
   EXCEPTION
   WHEN OTHERS THEN
         RETURN 'N';
   END check_duplicate_label;
   --End of fix for Bug# 5051977

PROCEDURE get_variable_data(
   x_variable_content   OUT NOCOPY INV_LABEL.label_tbl_type
,  x_msg_count    OUT NOCOPY NUMBER
,  x_msg_data     OUT NOCOPY VARCHAR2
,  x_return_status      OUT NOCOPY VARCHAR2
,  p_label_type_info IN INV_LABEL.label_type_rec
,  p_transaction_id  IN NUMBER
,  p_input_param     IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
,  p_transaction_identifier IN NUMBER
) IS

   l_delivery_id     NUMBER;
   l_delivery_detail_id NUMBER;

   l_move_order_line_id NUMBER;

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

   CURSOR  c_wdd_shipping IS
   SELECT wda.delivery_id, wdd.organization_id, wdd.subinventory
   FROM   wsh_delivery_assignments_v   wda, wsh_new_deliveries wnd
          , wsh_delivery_details wdd
   WHERE  wda.delivery_detail_id = p_transaction_id
   AND    wnd.delivery_id        = wda.delivery_id
   AND    wdd.delivery_detail_id(+) = wda.delivery_detail_id;

   CURSOR   c_cart_shipping IS
   SELECT   wda.delivery_id, mmtt.organization_id, mmtt.subinventory_code
   FROM  wsh_delivery_assignments_v wda, wsh_new_deliveries wnd,
      wsh_delivery_details wdd, mtl_material_transactions_temp mmtt
   WHERE    mmtt.move_order_line_id    = wdd.move_order_line_id
   AND      wda.delivery_detail_id     = wdd.delivery_detail_id
   AND      wnd.delivery_id            = wda.delivery_id
   AND      mmtt.transaction_temp_id   = p_transaction_id;

   -- Fix for Bug# 3786272. Removed the 'wms_packaging_hist' from the 'FROM' clause.

   CURSOR c_cart_shipping_pkg IS
   SELECT   DISTINCT(wda.delivery_id)
   FROM  wsh_delivery_assignments_v wda, wsh_new_deliveries wnd,
      wsh_delivery_details wdd, mtl_material_transactions_temp mmtt
      --wms_packaging_hist wph
   WHERE    mmtt.move_order_line_id    = wdd.move_order_line_id (+)
   AND      wda.delivery_detail_id (+)    = wdd.delivery_detail_id
   AND      wnd.delivery_id (+)           = wda.delivery_id
   AND      mmtt.cartonization_id      = p_transaction_id; -- Bug 2374644


   /* Bug 2072560:
      The solution to this (in consultation with  Tharian and Janet), we will derive
           the move_order_line_id from the mmtt and then with the move_order_line_id
           derive the delivery_detail_id from the WDD and then eventually the delivery_id.
   */
   /*CURSOR c_mmtt_temp_id IS
   SELECT move_order_line_id
   FROM   mtl_material_transactions_temp mmtt
   WHERE  mmtt.transaction_temp_id = p_transaction_id;



      CURSOR c_wdd_delivery_dtl_id IS
   SELECT delivery_detail_id
   FROM   wsh_delivery_details wdd
   WHERE  wdd.move_order_line_id = l_move_order_line_id;


   CURSOR c_wda_delivery_id IS
   SELECT delivery_id
   FROM   wsh_delivery_assignments_v wda
   WHERE  wda.delivery_detail_id = l_delivery_detail_id;*/

   /* Combined the above three cursors into one */
   CURSOR c_mmtt_pick_drop IS
   SELECT wda.delivery_id, mmtt.organization_id, mmtt.transfer_subinventory
   FROM   wsh_delivery_assignments_v wda, wsh_delivery_details wdd
          , mtl_material_transactions_temp mmtt
   WHERE  wda.delivery_detail_id = wdd.delivery_detail_id
   AND    wdd.move_order_line_id = mmtt.move_order_line_id
   AND    mmtt.transaction_temp_id = p_transaction_id;

   /* Added for Patchset J
    * When calling label printing from Packing Workbench
    * LPN_ID is passed to label printing
    * Delivery ID can be derived with the LPN_ID
    * New cursor to derive delivery_id with LPN */
   CURSOR c_lpn_delivery(p_lpn_id NUMBER) IS
      SELECT wda.delivery_id
      FROM wsh_delivery_assignments_v wda
          ,wsh_delivery_details wdd
      WHERE wda.parent_delivery_detail_id = wdd.delivery_detail_id
      AND   wda.delivery_id IS NOT NULL
      AND   wdd.lpn_id IS NOT NULL
      AND   wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
      AND   exists(
             select lpn_id from wms_license_plate_numbers
             where lpn_id = wdd.lpn_id
             and   outermost_lpn_id = p_lpn_id)
      AND rownum<2;



   /* Patchset J- Select attribute1..attribute15, tp_attribute1..tp_attribute15
    *, global_attribute1..global_attribute15, attribute_category,
    * tp_attribute_category, global_attribute_category from wsh_new_deliveries
    */

   CURSOR  c_delivery(p_delivery_id NUMBER) IS
   SELECT     wnd.delivery_id       delivery_number
             -- Added by joabraha for Bug 3549300
           , wnd.customer_id       customer_id
           , wnd.organization_id   organization_id
             --
                /*Bug 3969347 -Added two columns ship_from_addressee
                  and ship_to_addressee to obtain data
                  for these label fields.*/
                , hro.name              ship_from_addressee
                --    , rac.customer_name     ship_to_addressee  Commented for Bug#4445708
                --End of fix for Bug 3969347
                , addr.addressee        ship_to_addressee  --Added for fix of Bug#4445708
      , rac.customer_name     customer_name
      , rac.customer_name     customer
      , hrl.address_line_1    ship_from_address1
      , hrl.address_line_2    ship_from_address2
      , hrl.address_line_3    ship_from_address3
      , hrl.address_line_4    ship_from_address4
      , hrl.city              ship_from_city
      , hrl.postal_code       ship_from_postal_code
      , hrl.state             ship_from_state
      , hrl.county            ship_from_county
      , hrl.country           ship_from_country
      , hrl.province          ship_from_province
      , hrl1.address_line_1   ship_to_address1
      , hrl1.address_line_2   ship_to_address2
      , hrl1.address_line_3   ship_to_address3
      , hrl1.address_line_4   ship_to_address4
      , hrl1.city       ship_to_city
      , hrl1.postal_code      ship_to_postal_code
      , hrl1.state            ship_to_state
      , hrl1.county           ship_to_county
      , hrl1.country          ship_to_country
      , hrl1.province         ship_to_province
      -- Bug 2878652, get carrier name from wsh_carriers_v
      -- Bug 5121507, Get carrier in order of Trip->Delivery
      -- Get carrier_id first, then query carrier_name later
      --, wcv.carrier_name      carrier
      , nvl(wt.carrier_id, wnd.carrier_id) carrier_id
      , null carrier
      , wnd.waybill           waybill
      , wnd.waybill           airbill
      , wdi.sequence_number   bill_of_lading
      -- Bug 2878652, get ship_method_name with ship_method_code
      , fcl.meaning           ship_method
      , wnd.gross_weight      shipment_gross_weight
      , wnd.weight_uom_code   shipment_gross_weight_uom
      , (wnd.gross_weight  -  wnd.net_weight)   shipment_tare_weight
      , wnd.weight_uom_code   shipment_tare_weight_uom
      , wnd.volume            shipment_volume
      , wnd.volume_uom_code   shipment_volume_uom
      , get_total_number_of_lpns(wnd.delivery_id) total_number_of_lpns
           , wnd.attribute_category new_del_attribute_category
           , wnd.attribute1        new_del_attribute1
           , wnd.attribute2        new_del_attribute2
           , wnd.attribute3        new_del_attribute3
           , wnd.attribute4        new_del_attribute4
           , wnd.attribute5        new_del_attribute5
           , wnd.attribute6        new_del_attribute6
           , wnd.attribute7        new_del_attribute7
           , wnd.attribute8        new_del_attribute8
           , wnd.attribute9        new_del_attribute9
           , wnd.attribute10        new_del_attribute10
           , wnd.attribute11        new_del_attribute11
           , wnd.attribute12        new_del_attribute12
           , wnd.attribute13        new_del_attribute13
           , wnd.attribute14        new_del_attribute14
           , wnd.attribute15        new_del_attribute15
           , wnd.tp_attribute_category new_del_tp_attr_category
           , wnd.tp_attribute1        new_del_tp_attr1
           , wnd.tp_attribute2        new_del_tp_attr2
           , wnd.tp_attribute3        new_del_tp_attr3
           , wnd.tp_attribute4        new_del_tp_attr4
           , wnd.tp_attribute5        new_del_tp_attr5
           , wnd.tp_attribute6        new_del_tp_attr6
           , wnd.tp_attribute7        new_del_tp_attr7
           , wnd.tp_attribute8        new_del_tp_attr8
           , wnd.tp_attribute9        new_del_tp_attr9
           , wnd.tp_attribute10        new_del_tp_attr10
           , wnd.tp_attribute11        new_del_tp_attr11
           , wnd.tp_attribute12        new_del_tp_attr12
           , wnd.tp_attribute13        new_del_tp_attr13
           , wnd.tp_attribute14        new_del_tp_attr14
           , wnd.tp_attribute15        new_del_tp_attr15
           , wnd.global_attribute_category new_del_global_attr_category
           , wnd.global_attribute1        new_del_global_attr1
           , wnd.global_attribute2        new_del_global_attr2
           , wnd.global_attribute3        new_del_global_attr3
           , wnd.global_attribute4        new_del_global_attr4
           , wnd.global_attribute5        new_del_global_attr5
           , wnd.global_attribute6        new_del_global_attr6
           , wnd.global_attribute7        new_del_global_attr7
           , wnd.global_attribute8        new_del_global_attr8
           , wnd.global_attribute9        new_del_global_attr9
           , wnd.global_attribute10        new_del_global_attr10
           , wnd.global_attribute11        new_del_global_attr11
           , wnd.global_attribute12        new_del_global_attr12
           , wnd.global_attribute13        new_del_global_attr13
           , wnd.global_attribute14        new_del_global_attr14
           , wnd.global_attribute15        new_del_global_attr15
   FROM
        --
        -- Modification Start for Bug # - 4418524
        --
        -- As part of TCA related changes ra_customers, ra_contacts views are
        -- obsoleted in R12. The columns fetched from these views are fetched
        -- from hz_parties and hz_cust_accounts.
        --
        -- Following table alias are commented
        --  ra_customers                 rac
        --
        -- Following Queries are added to replace the above commented
        -- views
        --
           ( SELECT CUST_ACCT.cust_account_id customer_id,
                    SUBSTRB(PARTY.party_name,1,50) customer_name
             FROM hz_parties PARTY
                     , hz_cust_accounts CUST_ACCT
                  WHERE CUST_ACCT.party_id = PARTY.party_id
           ) rac,
             --
             -- Modification End for Bug # - 4418524
             --
      (select loc.location_id location_id,loc.address_line_1 address_line_1
            ,loc.address_line_2 address_line_2,loc.address_line_3 address_line_3
            ,loc.loc_information13 address_line_4,loc.town_or_city city
            ,loc.postal_code postal_code,loc.region_2 state,loc.region_1 county
            ,loc.country country, DECODE(LOC.STYLE,'CA',(SELECT MEANING
 	                               FROM   FND_COMMON_LOOKUPS
 	                               WHERE  LOOKUP_TYPE = 'CA_PROVINCE'
 	                                      AND LOOKUP_CODE = LOC.REGION_1
 	                                      AND ROWNUM < 2),
 	                         'CA_GLB',(SELECT MEANING
 	                                   FROM   FND_COMMON_LOOKUPS
 	                                   WHERE  LOOKUP_TYPE = 'CA_PROVINCE'
 	                                          AND LOOKUP_CODE = LOC.REGION_1
 	                                          AND ROWNUM < 2),
 	                         LOC.REGION_3) PROVINCE  -- Modified for bug 7281160
            from hr_locations_all loc
      union all
      select hz.location_id location_id,hz.address1   address_line_1
            ,hz.address2   address_line_2,hz.address3 address_line_3
            ,hz.address4   address_line_4,hz.city city,hz.postal_code postal_code
            ,hz.state state,hz.county county,hz.country country,hz.province province
      from hz_locations hz   ) hrl,
        --Bug 3969347 -Adding the table hr_organization_units
             hr_organization_units hro,
        --End of fix for Bug 3969347.
      (select loc.location_id location_id,loc.address_line_1 address_line_1
            ,loc.address_line_2 address_line_2,loc.address_line_3 address_line_3
            ,loc.loc_information13 address_line_4,loc.town_or_city city
            ,loc.postal_code postal_code,loc.region_2 state,loc.region_1 county
            ,loc.country country, DECODE(LOC.STYLE,'CA',(SELECT MEANING
 	                               FROM   FND_COMMON_LOOKUPS
 	                               WHERE  LOOKUP_TYPE = 'CA_PROVINCE'
 	                                      AND LOOKUP_CODE = LOC.REGION_1
 	                                      AND ROWNUM < 2),
 	                         'CA_GLB',(SELECT MEANING
 	                                   FROM   FND_COMMON_LOOKUPS
 	                                   WHERE  LOOKUP_TYPE = 'CA_PROVINCE'
 	                                          AND LOOKUP_CODE = LOC.REGION_1
 	                                          AND ROWNUM < 2),
 	                         LOC.REGION_3) PROVINCE  -- Modified for bug 7281160
            from hr_locations_all loc
      union all
      select hz.location_id location_id,hz.address1   address_line_1
            ,hz.address2   address_line_2,hz.address3 address_line_3
            ,hz.address4   address_line_4,hz.city city,hz.postal_code postal_code
            ,hz.state state,hz.county county,hz.country country,hz.province province
      from hz_locations hz   ) hrl1,
      wsh_new_deliveries    wnd,
      wsh_delivery_legs     wdl,
      wsh_document_instances  wdi
      -- Bug 2878652, get carrier name and ship method name
      , fnd_common_lookups fcl
      -- Bug 5121507 Getting Carrier in the order of Trip->Delivery
      --, wsh_carriers_v wcv
      ,  wsh_trip_stops  wts
      ,  wsh_trips       wt
                --Added to fix the issue reported in the Bug#4445708
                , ( select party_site.addressee addressee
                    from wsh_delivery_details wdd
                       , wsh_delivery_assignments wda
                       , hz_cust_site_uses_all hcsua
                       , hz_party_sites party_site
                       , hz_loc_assignments loc_assign
                       , hz_locations loc
                       , hz_cust_acct_sites_all acct_site
                    where wdd.delivery_detail_id = wda.delivery_detail_id
                      and wda.delivery_id = p_delivery_id
                      and wdd.container_flag = 'N'
                      and hcsua.site_use_id = wdd.ship_to_site_use_id
                      and acct_site.cust_acct_site_id = hcsua.cust_acct_site_id
                      AND acct_site.party_site_id = party_site.party_site_id
                      AND loc.location_id = party_site.location_id
                      AND loc.location_id = loc_assign.location_id
                      AND NVL ( acct_site.org_id, -99 )  = NVL ( loc_assign.org_id, -99 )
                      and rownum = 1
                  ) addr

   WHERE wnd.delivery_id      =  p_delivery_id
   AND   rac.customer_id(+)   =  wnd.customer_id
   AND   hrl.location_id(+)   =  wnd.INITIAL_PICKUP_LOCATION_ID
   AND   hrl1.location_id(+)  =  wnd.ULTIMATE_DROPOFF_LOCATION_ID
   AND   wdl.delivery_id (+)  =  wnd.delivery_id
   AND   wdi.entity_id  (+)   =  wdl.delivery_leg_id
   AND     wdi.entity_name  (+)    =     'WSH_DELIVERY_LEGS' -- Bug 3905110
   --Bug 3969347 --Added this condition to join the table hr_organization_units.
   AND     hro.organization_id(+)  =       wnd.organization_id
    --End of fix for Bug 3969347
   AND wdi.document_type(+) = 'BOL'
   AND fcl.lookup_type(+) = 'SHIP_METHOD'
   AND fcl.lookup_code(+) = wnd.ship_method_code
   --Bug 5121507 Getting Carrier in the order of Trip->Delivery
   AND wnd.delivery_id      = wdl.delivery_id(+)
   AND wdl.pick_up_stop_id  = wts.stop_id (+)
   AND wts.trip_id          = wt.trip_id (+);
   --AND wcv.carrier_id(+) = wnd.carrier_id;

   l_delivery_data   LONG;
   l_sales_order_header_id NUMBER; -- Introduced for bug: 5740331

   l_selected_fields    INV_LABEL.label_field_variable_tbl_type;
   l_selected_fields_count NUMBER;

   l_delivery_rec_index    NUMBER := 0;

   l_label_format_id       NUMBER := 0 ;
   l_label_format       VARCHAR2(100);
   l_printer      VARCHAR2(30);

   l_api_name        VARCHAR2(20) := 'get_variable_data';

   l_return_status      VARCHAR2(240);

   l_error_message   VARCHAR2(240);
   l_msg_count       NUMBER;
   l_api_status      VARCHAR2(240);
   l_msg_data     VARCHAR2(240);

   i        NUMBER;

   l_organization_id NUMBER;
   l_subinventory_code  VARCHAR2(30) :=null;

   l_label_index NUMBER;
   l_label_request_id NUMBER;

   --I cleanup, use l_prev_format_id to record the previous label format
   l_prev_format_id      NUMBER;
   -- I cleanup, user l_prev_sub to record the previous subinventory
   --so that get_printer is not called if the subinventory is the same
   l_prev_sub VARCHAR2(30);

   -- a list of columns that are selected for format
   l_column_name_list LONG;

BEGIN
   -- Initialize return status as success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- If the transactions_id is passed, and the business flow code passed is in 6(Cross dock),
   -- or 19(Pick Drop), then the transactions_id passed is the Delivery_Detail_Id.
   -- Since we are printing the "Shipping"  label here, we will have to derive the delivery_id
   -- from the delivery_detail_id and print the details for the Delivery Id .
   -- If the business flow code passed is 21(Shipping) then the transaction id passed is the
   -- delivery ID itself and so this can be directly assigned to the l_delivery_id

   -- For Pick Load(18), transaction_header_id is passed as p_transaction_id,
   -- Delivery ID is obtained from MMTT and joining mmtt.move_order_line_id
   -- to wdd.move_order_line_id.. All the MMTT record with that header_id
   -- has the same move_order_line_id

    l_debug := INV_LABEL.l_debug;
   IF (l_debug = 1) THEN
      trace('**In Shipping label**');
      trace('  Business_flow: '||p_label_type_info.business_flow_code);
      trace('  Transaction ID:'||p_transaction_id);
   END IF;

   -- Get l_delivery_id
   IF p_transaction_id IS NOT NULL then
      -- txn mode
      IF p_label_type_info.business_flow_code in (6) THEN
      -- means that the delivery_detail_id has been passed
         OPEN c_wdd_shipping;
         FETCH c_wdd_shipping INTO l_delivery_id, l_organization_id, l_subinventory_code;
         IF c_wdd_shipping%NOTFOUND THEN
            IF (l_debug = 1) THEN
               trace(' No delivery_id found from WDD, no label print');
            END IF;
            CLOSE c_wdd_shipping;
            RETURN;
         ELSE
            CLOSE c_wdd_shipping;
         END IF;
      ELSIF p_label_type_info.business_flow_code in (19) THEN
      -- Old Design.
      -- when the transactions manager calls printing for business flow of 'Pick Drop' (19) and passes the
      -- transactions_temp_id, we derive the the transfer_lpn_id and the content_lpn_id from the MMTT and using either
      -- the transfer_lpn_id  or content_lpn_id (imp: only if transfer_lpn_id is null) derive the delivery_detail_id
      -- from the wsh_delivery_details.
      -- There may be no delivery at Pick Load, Pick Drop, and Cartonization is the users fails to create one.
      -- But a delivery ID will be automatically created after ship confirm.
      -- This means that of the business flows of Pick Load, Pick Drop, and Cartonization there may be no delivery
      -- label printed on some ocassions mentioned above.

      -- New Design:
      -- Derive the move_order_line_id from the mmtt and then with the move_order_line_id derive the delivery_detail_id
      -- from the WDD and then eventually the delivery_id.

      /*combined cursor c_mmtt_temp_id, c_wdd_delivery_dtl_id
      , c_wda_delivery_id into one c_mmtt_pick_drop cursor*/
         OPEN c_mmtt_pick_drop;
         FETCH c_mmtt_pick_drop INTO l_delivery_id, l_organization_id, l_subinventory_code;

         IF c_mmtt_pick_drop%NOTFOUND THEN
            IF (l_debug = 1) THEN
               trace(' No record found in MMTT for given ID:'||p_transaction_id);
            END IF;
            CLOSE c_mmtt_pick_drop;
            RETURN;
         ELSE
            CLOSE c_mmtt_pick_drop;
            IF (l_debug = 1) THEN
               trace(' Found delivery ID for pick drop:'||l_delivery_id);
            END IF;
         END IF;

      ELSIF p_label_type_info.business_flow_code in (21) THEN
      -- means that the delivery_id has been passed
         l_delivery_id := p_transaction_id ;

	 -- Bug 5740331 - Added the following block to fetch the sales order header.
         BEGIN
          SELECT DISTINCT(source_header_id)
          INTO  l_sales_order_header_id
          FROM  wsh_delivery_details wdd,
                    wsh_delivery_assignments wda
          WHERE wdd.delivery_detail_id = wda.delivery_detail_id
          AND   wda.delivery_id = l_delivery_id
          AND   wdd.container_flag = 'N' ;

          IF (l_debug = 1) THEN
               trace('Value of l_sales_order_header_id:'|| l_sales_order_header_id);
          END IF;

          EXCEPTION
          WHEN TOO_MANY_ROWS THEN
	  IF (l_debug = 1) THEN
		trace('In the exception for too many rows for Sales Order Header');
          END IF;
                l_sales_order_header_id := NULL;
          WHEN OTHERS THEN
          IF (l_debug = 1) THEN
		trace('In the exception for too many rows for Sales Order Header');
          END IF;
		l_sales_order_header_id := NULL;
          END;
          --End of fix for Bug 5740331

      ELSIF p_label_type_info.business_flow_code in (22) THEN
         OPEN c_cart_shipping_pkg;
         FETCH c_cart_shipping_pkg INTO l_delivery_id;
            IF c_cart_shipping_pkg%NOTFOUND
            THEN
               IF (l_debug = 1) THEN
                  trace(' No delivery_id found for cartonizationt');
               END IF;
               CLOSE c_cart_shipping_pkg;
               RETURN;
            ELSE
               IF (l_debug = 1) THEN
                  Trace('Found delivery_id for cartonization:' || l_delivery_id);
               END IF;
            END IF;

      ELSIF p_label_type_info.business_flow_code in (18, 34) THEN
         OPEN c_cart_shipping;
         FETCH c_cart_shipping INTO l_delivery_id, l_organization_id, l_subinventory_code;
         IF c_cart_shipping%NOTFOUND THEN
            IF (l_debug = 1) THEN
               trace(' No delivery_id found from MMTT, no label print');
            END IF;
            CLOSE c_cart_shipping;
            RETURN;
         ELSE
            CLOSE c_cart_shipping;
         END IF;

      -- 18th February 2002 : Commented out below for fix to bug 2219171 for Qualcomm. Hence forth the
      -- WMSTASKB.pls will be calling label printing at Pick Load with the
      -- transaction_temp_id as opposed to the transaction_header_id earlier. This business flows(18)
      -- have been added to  the above call.
      -- ELSIF p_label_type_info.business_flow_code in (18) THEN
      -- OPEN c_pickload_shipping;
      -- FETCH c_pickload_shipping INTO l_delivery_id;
      -- IF c_pickload_shipping%NOTFOUND THEN
      --    trace(' No delivery_id found from MMTT with the header_id, no label print');
      --    CLOSE c_pickload_shipping;
      --    RETURN;
      -- ELSE
      --    CLOSE c_pickload_shipping;
      -- END IF;

      ELSE
         IF (l_debug = 1) THEN
            trace(' Invalid business flow code '|| p_label_type_info.business_flow_code || ' No label print');
         END IF;
         RETURN;
      END IF;
   ELSE
      -- manual mode.Manual request is from Jason's page.
      -- We have to have an agreement that when they call
      -- this API, they have to pass the delivery_id
      -- in place of the transactions_temp_id.
      l_delivery_id := p_input_param.transaction_temp_id;

      -- After patchset J, as per request from Packing Workbench
      -- If delivery_id is not passed in directly
      --  but LPN_ID is available
      --  will derive the delivery_id with the LPN_ID
      IF l_delivery_id IS NULL AND p_input_param.lpn_id IS NOT NULL THEN
         OPEN c_lpn_delivery(p_input_param.lpn_id);
         FETCH c_lpn_delivery INTO l_delivery_id;
         CLOSE c_lpn_delivery;
      END IF;

   END IF;

   IF (l_debug = 1) THEN
      trace(' Got Delivery_id = '|| l_delivery_id);
   END IF;

   IF l_delivery_id IS NULL THEN
      IF (l_debug = 1) THEN
         trace(' Delivery ID IS NULL, can not process ');
      END IF;
      RETURN;
   END IF;

   IF (l_debug = 1) THEN
      trace(' Getting selected fields ');
   END IF;

   INV_LABEL.GET_VARIABLES_FOR_FORMAT(
      x_variables       => l_selected_fields
   ,  x_variables_count => l_selected_fields_count
   ,  p_format_id    => p_label_type_info.default_format_id);

   IF (l_selected_fields_count=0) OR (l_selected_fields.count =0 ) THEN
      IF (l_debug = 1) THEN
         trace('no fields defined for this format: ' || p_label_type_info.default_format_id || ',' ||p_label_type_info.default_format_name);
      END IF;
      --return;
   END IF;

   IF (l_debug = 1) THEN
      trace(' Found variable defined for this format, cont = ' || l_selected_fields_count);
   END IF;

   l_delivery_rec_index := 0;
   IF (l_debug = 1) THEN
      trace('** in PVT7.get_variable_data ** , start ');
   END IF;
   l_printer := p_label_type_info.default_printer;
   l_prev_sub := '####';

   l_label_index := 1;
   l_prev_format_id := p_label_type_info.default_format_id;

   WHILE l_delivery_id IS NOT NULL LOOP
      l_delivery_data := '';
      FOR v_delivery IN c_delivery(l_delivery_id) LOOP
         l_delivery_rec_index := l_delivery_rec_index + 1;
         IF (l_debug = 1) THEN
            trace(' ** New Label  ' || l_delivery_rec_index );
         END IF;

         -- Bug 5121507, get carrier name
         IF v_delivery.carrier_id IS NOT NULL THEN
            BEGIN
               SELECT carrier_name
               INTO v_delivery.carrier
               FROM wsh_carriers_v
               WHERE carrier_id = v_delivery.carrier_id
               AND ROWNUM<2;
            EXCEPTION
               WHEN others THEN
                  v_delivery.carrier := null;
            END;
         END IF;

         --R12 : RFID compliance project
         --Calling rules engine before calling to get printer
         IF (l_debug = 1) THEN
            trace('Apply Rules engine for format'
            ||',manual_format_id='||p_label_type_info.manual_format_id
            ||',manual_format_name='||p_label_type_info.manual_format_name);
         END IF;

         /* insert a record into wms_label_requests entity to
         call the label rules engine to get appropriate label */
         INV_LABEL.GET_FORMAT_WITH_RULE
         (  p_document_id        =>p_label_type_info.label_type_id,
            P_LABEL_FORMAT_ID    => p_label_type_info.manual_format_id,
            p_delivery_id  =>l_delivery_id,
            --p_printer_name  =>l_printer,-- Removed in R12: 4396558
            P_BUSINESS_FLOW_CODE =>   p_label_type_info.business_flow_code,
            P_LAST_UPDATE_DATE   =>sysdate,
            P_LAST_UPDATED_BY    =>FND_GLOBAL.user_id,
            P_CREATION_DATE      =>sysdate,
            P_CREATED_BY         =>FND_GLOBAL.user_id,
            x_return_status      =>l_return_status,
            x_label_format_id   =>l_label_format_id,
            x_label_format    =>l_label_format,
            x_label_request_id  =>l_label_request_id,
            -- Added by joabraha for Bug 3549300
            p_customer_id     => v_delivery.customer_id,
            p_organization_id   => v_delivery.organization_id,
	    -- Added by dchithir for bug 5740331
	    p_sales_order_header_id  => l_sales_order_header_id
            );

         IF l_return_status <> 'S' THEN
            FND_MESSAGE.SET_NAME('WMS', 'WMS_LABL_RULE_ENGINE_FAILED');
            FND_MSG_PUB.ADD;
            l_label_format:= p_label_type_info.default_format_id;
            l_label_format_id:= p_label_type_info.default_format_name;
         END IF;
         IF (l_debug = 1) THEN
            trace('did apply label ' || l_label_format || ',' || l_label_format_id||',req_id '||l_label_request_id);
         END IF;



         IF (l_debug = 1) THEN
            trace(' Getting printer, manual_printer='||p_label_type_info.manual_printer ||',sub='||l_subinventory_code ||',default printer='||p_label_type_info.default_printer);
         END IF;

         -- IF clause Added for Add format/printer for manual request
         IF p_label_type_info.manual_printer IS NULL THEN
         -- The p_label_type_info.manual_printer is the one  passed from the manual page.
         -- As per the design, if a printer is passed from the manual page, then we use that printer irrespective.

            IF (l_subinventory_code IS NOT NULL) AND (l_subinventory_code <> l_prev_sub) THEN
               IF (l_debug = 1) THEN
                  trace('getting printer with sub '||l_subinventory_code);
               END IF;
               BEGIN
                  WSH_REPORT_PRINTERS_PVT.GET_PRINTER(
                     p_concurrent_program_id=>p_label_type_info.label_type_id,
                     p_user_id              =>fnd_global.user_id,
                     p_responsibility_id    =>fnd_global.resp_id,
                     p_application_id       =>fnd_global.resp_appl_id,
                     p_organization_id      =>l_organization_id,
                     p_zone                 =>l_subinventory_code,
                     p_format_id         =>l_label_format_id, --added in r12 RFID 4396558
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
            IF l_label_format_id <> nvl(l_prev_format_id, -999) THEN
               IF (l_debug = 1) THEN
                  trace(' Getting variables for new format ' || l_label_format);
               END IF;
               INV_LABEL.GET_VARIABLES_FOR_FORMAT(
                  x_variables       => l_selected_fields
               ,  x_variables_count => l_selected_fields_count
               ,  p_format_id    => l_label_format_id);

               l_prev_format_id := l_label_format_id;

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
         l_delivery_data := l_delivery_data || LABEL_B;
         IF l_label_format <> nvl(p_label_type_info.default_format_name, '@@@') THEN
            l_delivery_data := l_delivery_data || ' _FORMAT="' || nvl(p_label_type_info.manual_format_name, l_label_format) || '"';
         END IF;
         IF (l_printer IS NOT NULL) AND (l_printer <> nvl(p_label_type_info.default_printer,'###')) THEN
            l_delivery_data := l_delivery_data || ' _PRINTERNAME="'||l_printer||'"';
         END IF;

         l_delivery_data := l_delivery_data || TAG_E;


         IF (l_debug = 1) THEN
            trace('Starting assign variables, ');
         END IF;

         l_column_name_list := 'Set variables for ';

         /* Modified for Bug 4072474 -start*/
         l_custom_sql_ret_status := FND_API.G_RET_STS_SUCCESS;
         /* Modified for Bug 4072474 -End*/

         -- Fix for bug: 4179593 Start
         l_CustSqlWarnFlagSet := FALSE;
         l_CustSqlErrFlagSet := FALSE;
         l_CustSqlWarnMsg := NULL;
         l_CustSqlErrMsg := NULL;
         -- Fix for bug: 4179593 End

         /* Loop for each selected fields, find the columns and write into the XML_content*/
         FOR i IN 1..l_selected_fields.count LOOP

            IF (l_debug = 1) THEN
                  l_column_name_list := l_column_name_list || ',' ||l_selected_fields(i).column_name;
            END IF;

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--  The check (SQL_STMT <> NULL and COLUMN_NAME = NULL) implies that the field is a          |
--  Custom SQL based field. Handle it appropriately.                                         |
---------------------------------------------------------------------------------------------
           IF (l_selected_fields(i).SQL_STMT IS NOT NULL AND l_selected_fields(i).column_name = 'sql_stmt') THEN
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP7B.pls]: ------------------------- REPORT BEGIN-------------------------------------');
              trace('Custom Labels Trace [INVLAP7B.pls]: LABEL_FIELD_ID       : ' || l_selected_fields(i).label_field_id);
              trace('Custom Labels Trace [INVLAP7B.pls]: FIELD_VARIABLE_NAME  : ' || l_selected_fields(i).variable_name);
              trace('Custom Labels Trace [INVLAP7B.pls]: COLUMN_NAME          : ' || l_selected_fields(i).column_name);
              trace('Custom Labels Trace [INVLAP7B.pls]: SQL_STMT             : ' || l_selected_fields(i).sql_stmt);
             END IF;
             l_sql_stmt := l_selected_fields(i).sql_stmt;
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP7B.pls]: l_sql_stmt BEFORE REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
             END IF;
             l_sql_stmt := l_sql_stmt || ' AND WLR.LABEL_REQUEST_ID = :REQUEST_ID';
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP7B.pls]: l_sql_stmt AFTER REQUEST_ID Filter Concatenation: ' || l_sql_stmt);

             END IF;
             BEGIN
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP7B.pls]: At Breadcrumb 1');
              trace('Custom Labels Trace [INVLAP7B.pls]: LABEL_REQUEST_ID     : ' || l_label_request_id);
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
                trace('Custom Labels Trace [INVLAP7B.pls]: At Breadcrumb 2');
                trace('Custom Labels Trace [INVLAP7B.pls]: l_sql_stmt_result is: ' || l_sql_stmt_result);
                trace('Custom Labels Trace [INVLAP7B.pls]: WARNING: NULL value returned by the custom SQL Query.');
                trace('Custom Labels Trace [INVLAP7B.pls]: l_custom_sql_ret_status  is set to : ' || l_custom_sql_ret_status );
               END IF;
             ELSIF c_sql_stmt%rowcount=0 THEN
               IF (l_debug = 1) THEN
                trace('Custom Labels Trace [INVLAP7B.pls]: At Breadcrumb 3');
                trace('Custom Labels Trace [INVLAP7B.pls]: WARNING: No row returned by the Custom SQL query');
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
                trace('Custom Labels Trace [INVLAP7B.pls]: At Breadcrumb 4');
                trace('Custom Labels Trace [INVLAP7B.pls]: ERROR: Multiple values returned by the Custom SQL query');
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
                trace('Custom Labels Trace [INVLAP7B.pls]: At Breadcrumb 5');
                trace('Custom Labels Trace [INVLAP7B.pls]: Unexpected Error has occured in GET_VARIABLES_DATA');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('WMS','WMS_CS_WRONG_SQL_CONSTRUCT');
              fnd_msg_pub.ADD;
              fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;
            IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP7B.pls]: At Breadcrumb 6');
              trace('Custom Labels Trace [INVLAP7B.pls]: Before assigning it to l_delivery_data');
            END IF;
            l_delivery_data  :=   l_delivery_data
                           || variable_b
                           || l_selected_fields(i).variable_name
                           || '">'
                           || l_sql_stmt_result
                           || variable_e;
            l_sql_stmt_result := NULL;
            l_sql_stmt        := NULL;
            IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP7B.pls]: At Breadcrumb 7');
              trace('Custom Labels Trace [INVLAP7B.pls]: After assigning it to l_delivery_data');
              trace('Custom Labels Trace [INVLAP7B.pls]: --------------------------REPORT END-------------------------------------');
            END IF;
------------------------End of this change for Custom Labels project code--------------------
            ELSIF LOWER(l_selected_fields(i).column_name) = 'current_date' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || INV_LABEL.G_DATE || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'current_time' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || INV_LABEL.G_TIME || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'request_user' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || INV_LABEL.G_USER || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'airbill' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.airbill || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'bill_of_lading' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.bill_of_lading || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'carrier' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.carrier || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'customer' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.customer || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'delivery_number' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
                l_selected_fields(i).variable_name || '">' || v_delivery.delivery_number || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_from_postal_code' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_from_postal_code || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_from_state' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_from_state || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_from_address1' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_from_address1 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_from_address2' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_from_address2 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_from_address3' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_from_address3 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_from_address4' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_from_address4 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_from_city' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_from_city || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_from_country' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_from_country || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_from_county' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_from_county || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_from_province' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_from_province || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_from_state' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_from_state || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'shipment_gross_weight' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.shipment_gross_weight || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'shipment_gross_weight_uom' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.shipment_gross_weight_uom || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_method' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_method || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'shipment_tare_weight' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.shipment_tare_weight || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'shipment_tare_weight_uom' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.shipment_tare_weight_uom || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_to_address1' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_to_address1 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_to_address2' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_to_address2 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_to_address3' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_to_address3 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_to_address4' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_to_address4 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_to_city' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_to_city || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_to_country' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_to_country || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_to_county' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_to_county || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_to_postal_code' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_to_postal_code || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_to_province' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_to_province || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_to_state' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.ship_to_state || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'shipment_volume' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.shipment_volume || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'shipment_volume_uom' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.shipment_volume_uom || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'total_number_of_lpns' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.total_number_of_lpns || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'waybill' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.waybill || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute1' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute1 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute2' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute2 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute3' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute3 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute4' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute4 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute5' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute5 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute6' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute6 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute7' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute7 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute8' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute8 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute9' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute9 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute10' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute10 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute11' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute11 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute12' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute12 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute13' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute13 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute14' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute14 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute15' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute15 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_attribute_category' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_attribute_category || VARIABLE_E;

             ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr1' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr1 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr2' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr2 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr3' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr3 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr4' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr4 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr5' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr5 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr6' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr6 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr7' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr7 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr8' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr8 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr9' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr9 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr10' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr10 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr11' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr11 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr12' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr12 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr13' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr13 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr14' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr14 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr15' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr15 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_tp_attr_category' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_tp_attr_category || VARIABLE_E;

             ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr1' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr1 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr2' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr2 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr3' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr3 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr4' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr4 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr5' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr5 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr6' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr6 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr7' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr7 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr8' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr8 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr9' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr9 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr10' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr10 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr11' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr11 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr12' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr12 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr13' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr13 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr14' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr14 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr15' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr15 || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'new_del_global_attr_category' THEN
               l_delivery_data := l_delivery_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || v_delivery.new_del_global_attr_category || VARIABLE_E;
            --Bug 3969347-Added the label fields ship_from_addressee and ship_to_addressee.
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_from_addressee' THEN
                   l_delivery_data := l_delivery_data || VARIABLE_B ||
                    l_selected_fields(i).variable_name || '">' || v_delivery.ship_from_addressee || VARIABLE_E;
            ELSIF LOWER(l_selected_fields(i).column_name) = 'ship_to_addressee' THEN
                   l_delivery_data := l_delivery_data || VARIABLE_B ||
                    l_selected_fields(i).variable_name || '">' || v_delivery.ship_to_addressee || VARIABLE_E;
           --End of fix for Bug 3969347.

          END IF;

         END LOOP;
         l_delivery_data := l_delivery_data || LABEL_E;
         x_variable_content(l_label_index).label_content := l_delivery_data;
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

         l_label_index := l_label_index +1;
         <<NextLabel>>
         l_delivery_data := '';
         l_label_request_id := null;

------------------------Start of changes for Custom Labels project code------------------
        l_custom_sql_ret_status := NULL;
        l_custom_sql_ret_msg    := NULL;
------------------------End of this changes for Custom Labels project code---------------

         IF (l_debug = 1) THEN
            trace(l_column_name_list);
               trace('  Finished writing item variables ');
         END IF;
      END LOOP;

      IF p_label_type_info.business_flow_code in (22)
      THEN
         FETCH c_cart_shipping_pkg INTO l_delivery_id;
            IF c_cart_shipping_pkg%NOTFOUND
            THEN
               IF (l_debug = 1) THEN
                  trace(' No more delivery_id found for cartonization');
               END IF;
               CLOSE c_cart_shipping_pkg;
               l_delivery_id := null;
            ELSE
               IF (l_debug = 1) THEN
                  Trace('Found next delivery_id=' || l_delivery_id);
               END IF;
            END IF;
      ELSE
         l_delivery_id := null;
      END IF;

   END LOOP;
END get_variable_data;

PROCEDURE get_variable_data(
   x_variable_content   OUT NOCOPY LONG
,  x_msg_count    OUT NOCOPY NUMBER
,  x_msg_data           OUT NOCOPY VARCHAR2
,  x_return_status      OUT NOCOPY VARCHAR2
,  p_label_type_info IN INV_LABEL.label_type_rec
,  p_transaction_id  IN NUMBER
,  p_input_param     IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
,  p_transaction_identifier IN NUMBER
) IS
   l_variable_data_tbl INV_LABEL.label_tbl_type;
BEGIN
   get_variable_data(
      x_variable_content   => l_variable_data_tbl
   ,  x_msg_count    => x_msg_count
   ,  x_msg_data           => x_msg_data
   ,  x_return_status      => x_return_status
   ,  p_label_type_info => p_label_type_info
   ,  p_transaction_id  => p_transaction_id
   ,  p_input_param     => p_input_param
   ,  p_transaction_identifier=> p_transaction_identifier
   );

   x_variable_content := '';

   FOR i IN 1..l_variable_data_tbl.count() LOOP
      x_variable_content := x_variable_content || l_variable_data_tbl(i).label_content;
   END LOOP;

END get_variable_data;


END INV_LABEL_PVT7;

/
