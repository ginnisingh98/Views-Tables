--------------------------------------------------------
--  DDL for Package Body WMS_MDC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_MDC_PVT" AS
/* $Header: WMSVMDCB.pls 120.17.12010000.2 2008/08/25 06:48:49 anviswan ship $ */

g_debug NUMBER := 1; -- NVL(fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

PROCEDURE debug(p_message VARCHAR2, p_module VARCHAR2) IS
BEGIN
   inv_log_util.TRACE(p_message, p_module);
--   dbms_output.put_line(p_module || ': ' || p_message);
END debug;

FUNCTION get_consol_delivery_id(p_lpn_id IN NUMBER) RETURN NUMBER IS
   l_delivery_id NUMBER; -- Consol Delivery ID for the LPN
BEGIN
   IF g_debug = 1 THEN
      debug('In get_consol_delivery_id: P_LPN ID: ' || p_lpn_id,
            'wms_mdc_pvt.get_consol_delivery_id');
   END IF;

   SELECT wda.delivery_id
     INTO l_delivery_id
     FROM wsh_delivery_assignments wda,
          wsh_delivery_details_ob_grp_v wdd,
          wsh_new_deliveries_ob_grp_v wnd
     WHERE wdd.delivery_detail_id = wda.delivery_detail_id
     AND wnd.delivery_id = wda.delivery_id
     AND wnd.delivery_type = 'CONSOLIDATION'
     AND wdd.lpn_id = p_lpn_id
     AND wdd.released_status = 'X'   -- For LPN reuse ER : 6845650
     AND ROWNUM = 1;

   IF g_debug = 1 THEN
      debug('Consol Delivery ID: ' || l_delivery_id,
            'wms_mdc_pvt.get_consol_delivery_id');
   END IF;

   RETURN l_delivery_id;

EXCEPTION
   WHEN no_data_found THEN
      IF g_debug = 1 THEN
         debug('No Consol Delivery', 'wms_mdc_pvt.get_consol_delivery_id');
         --{{No Consol Delivery found for the given delivery id}}
      END IF;
      RETURN NULL;
END get_consol_delivery_id;

FUNCTION get_delivery_type(p_delivery_id IN NUMBER) RETURN VARCHAR2 IS
   l_delivery_type  VARCHAR2(30); -- Consol Delivery ID for the LPN
BEGIN
   IF g_debug = 1 THEN
      debug('Inside get_delivery_type (2) : p_delivery_id : ' || p_delivery_id,
            'wms_mdc_pvt.get_delivery_type');
   END IF;

   SELECT wnd.delivery_type
     INTO l_delivery_type
     FROM wsh_new_deliveries_ob_grp_v wnd
     WHERE wnd.delivery_id = p_delivery_id ;

   IF g_debug = 1 THEN
      debug('Consol l_delivery_type : ' || l_delivery_type,
            'wms_mdc_pvt.get_delivery_type');
   END IF;

   IF l_delivery_type = 'CONSOLIDATION' THEN
      RETURN l_delivery_type;
   END IF;
     RETURN l_delivery_type;

EXCEPTION
   WHEN no_data_found THEN
      IF g_debug = 1 THEN
         debug('No Delivery found in wsh_new_deliveries', 'wms_mdc_pvt.get_delivery_type');
         --{{No Delivery found in wsh_new_deliveries whle tryiong to find delivery type }}
      END IF;
      RETURN NULL;
END get_delivery_type;

FUNCTION get_delivery_id(p_lpn_id IN NUMBER) RETURN NUMBER IS
   l_lpn_context NUMBER; -- LPN context for LPN
   l_delivery_id NUMBER; -- Delivery ID for the LPN
BEGIN
   IF g_debug = 1 THEN
      debug('inside get_delivery_id : p_lpn_id : ' || p_lpn_id,
            'wms_mdc_pvt.get_delivery_id');
   END IF;
   SELECT lpn_context
     INTO l_lpn_context
     FROM wms_license_plate_numbers
     WHERE lpn_id = p_lpn_id;

   IF g_debug = 1 THEN
      debug('LPN Context : ' || l_lpn_context, 'wms_mdc_pvt.get_delivery_id');
   END IF;

   IF l_lpn_context = 8  THEN -- Packing Context: LPN1 has been loaded
      SELECT wda.delivery_id
        INTO l_delivery_id
        FROM mtl_material_transactions_temp mmtt,
             wsh_delivery_details_ob_grp_v wdd,
             wsh_delivery_assignments_v wda
        WHERE mmtt.transfer_lpn_id = p_lpn_id
        AND mmtt.transaction_action_id = 28
        AND mmtt.transaction_source_type_id IN (2, 8)
        AND mmtt.move_order_line_id = wdd.move_order_line_id
        AND wdd.released_status = 'S'
        AND wdd.delivery_detail_id = wda.delivery_detail_id
        AND ROWNUM =1;

        ---- *** MRANA : it can return multiple rows ..using rownum=1 expecting that all
        --lines have the same delivery id..no cms
        -- {{ - LPNs that are pick loaded(context 8) with record in MMTT
        --      may belong to a cancelled MOL/SOL and }}
        -- {{   thus the join to WDD with status 'Released to Warehouse'
        --      might return no_data_found  }}
    ELSIF l_lpn_context = 5 THEN -- Prepacked LPN, does not have a delivery
       RETURN 0;
    ELSIF l_lpn_context IN (12, 11) THEN -- LPN1 has been staged
                                         -- 12:Loaded to stage move Context
      SELECT wda.delivery_id
        INTO l_delivery_id
        FROM wsh_delivery_assignments_v wda,
             wsh_delivery_details_ob_grp_v wdd
        WHERE wdd.delivery_detail_id = wda.delivery_detail_id
        AND wdd.lpn_id = p_lpn_id
  	     AND wdd.released_status = 'X'   -- For LPN reuse ER : 6845650
        AND ROWNUM =1;
       ---- *** MRANA : it can return multiple rows ..using rownum=1 expecting that all
       --lines have the same delivery id..no cms
    ELSIF l_lpn_context = 3 THEN
      --There should only be 1 MOL in this LPN
      BEGIN
         SELECT  wda.delivery_id
           INTO  l_delivery_id
           FROM  mtl_txn_request_lines mtrl,
                 wsh_delivery_assignments_v wda
           WHERE mtrl.lpn_id IN (SELECT wlpn.lpn_id
                                 FROM   wms_license_plate_numbers wlpn
                                 START  WITH wlpn.lpn_id = p_lpn_id
                                 CONNECT BY PRIOR wlpn.lpn_id = wlpn.parent_lpn_id)
           AND  wda.delivery_detail_id = mtrl.backorder_delivery_detail_id;
      EXCEPTION
         WHEN too_many_rows THEN
            IF g_debug = 1 THEN
               debug('More than 1 MOL. Should not come here!', 'wms_mdc_pvt.get_delivery_id');
            END IF;
            RETURN NULL;
         WHEN OTHERS THEN
            IF g_debug = 1 THEN
               debug('no MOL found!', 'wms_mdc_pvt.get_delivery_id');
            END IF;
            RETURN NULL;
      END;
   END IF;

   IF g_debug = 1 THEN
      debug('Delivery ID: ' || l_delivery_id, 'wms_mdc_pvt.get_delivery_id');
   END IF;

   RETURN l_delivery_id;

EXCEPTION
   WHEN no_data_found THEN
      IF g_debug = 1 THEN
         debug('SQL Error: ' || sqlerrm, 'wms_mdc_pvt.get_delivery_id');
      END IF;
      RETURN NULL;
END get_delivery_id;

-- API to check if the LPN is tied to an operation plan that specifies
-- consolidation across deliveries
FUNCTION is_across_delivery(p_lpn_id      IN NUMBER,
                            p_lpn_context IN NUMBER := NULL) RETURN BOOLEAN IS
   l_lpn_context NUMBER;             -- LPN context for LPN
   l_consolidation_method_id NUMBER; -- Consolidation method
BEGIN
   IF g_debug = 1 THEN
      debug('Entered ..is_across_delivery : ' , 'wms_mdc_pvt.is_across_delivery');
      debug('p_lpn_id : ' || p_lpn_id, 'wms_mdc_pvt.is_across_delivery');
      debug('p_lpn_context : ' || p_lpn_context, 'wms_mdc_pvt.is_across_delivery');
   END IF;

   IF p_lpn_context = 8 THEN -- Packing Context: LPN1 has been loaded
      BEGIN
         SELECT 2   -- 1=AD, 2=WD
         INTO   l_consolidation_method_id  -- 1=AD, 2=WD
           FROM wms_op_plan_details wopd, mtl_material_transactions_temp mmtt
           WHERE (mmtt.content_lpn_id = p_lpn_id OR mmtt.transfer_lpn_id = p_lpn_id)
           AND mmtt.transaction_action_id = 28
           AND mmtt.transaction_source_type_id IN (2, 8)
           AND mmtt.operation_plan_id = wopd.operation_plan_id
           AND wopd.consolidation_method_id = 2 --WD
           AND wopd.operation_type = 2  -- Drop
           AND ROWNUM = 1;
          IF g_debug = 1 THEN
             debug('Consolidation Method: context 8' || l_consolidation_method_id,
                   'wms_mdc_pvt.is_across_delivery');
          END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
          l_consolidation_method_id := 1;
      END ;
   ELSIF p_lpn_context = 5 THEN -- Prepacked LPN, can be treated as across delivery
       l_consolidation_method_id := 1;
       RETURN TRUE;
   ELSIF p_lpn_context IN (12, 11) THEN -- LPN1 has been staged
                                    -- 12:Loaded to stage move Context
       BEGIN
          SELECT 2  -- 1=AD, 2=WD
            INTO   l_consolidation_method_id  -- 1=AD, 2=WD
            FROM wms_op_plan_details wopd, wms_dispatched_tasks_history wdth
            WHERE wdth.transfer_lpn_id = p_lpn_id
            AND wdth.operation_plan_id = wopd.operation_plan_id
            AND wopd.consolidation_method_id = 2 --WD
            AND wopd.operation_type = 2  -- Drop
            AND ROWNUM = 1;
          IF g_debug = 1 THEN
             debug('Consolidation Method: context11: ' || l_consolidation_method_id,
                   'wms_mdc_pvt.is_across_delivery');
          END IF;
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_consolidation_method_id := 1;
       END ;
    ELSIF p_lpn_context = 3 THEN
      BEGIN
         SELECT 2
           INTO l_consolidation_method_id
           FROM wms_op_plan_details wopd,
                mtl_material_transactions_temp mmtt,
                mtl_txn_request_lines mtrl
           WHERE mtrl.lpn_id IN (SELECT wlpn.lpn_id
                                 FROM   wms_license_plate_numbers wlpn
                                 START  WITH wlpn.lpn_id = p_lpn_id
                                 CONNECT BY PRIOR wlpn.lpn_id = wlpn.parent_lpn_id)
           AND   mtrl.line_status = 7
           AND   mtrl.line_id = mmtt.move_order_line_id
           AND   mmtt.operation_plan_id = wopd.operation_plan_id
           AND   wopd.consolidation_method_id = 2 --WD
           AND   wopd.operation_type = 2;
       EXCEPTION
       WHEN too_many_rows THEN
           IF (g_debug = 1) THEN
              debug('Too many rows!', 'wms_mdc_pvt.is_across_delivery');
           END IF;
           l_consolidation_method_id := 2;
       WHEN NO_DATA_FOUND THEN
           IF (g_debug = 1) THEN
              debug('No data found!', 'wms_mdc_pvt.is_across_delivery');
           END IF;
           l_consolidation_method_id := 1;
       WHEN OTHERS THEN
           IF (g_debug = 1) THEN
              debug('Other exception!', 'wms_mdc_pvt.is_across_delivery');
           END IF;
           l_consolidation_method_id := 2;

       END ;
   END IF;

   IF g_debug = 1 THEN
      debug('Consolidation Method: ' || l_consolidation_method_id,
            'wms_mdc_pvt.is_across_delivery');
   END IF;

   IF Nvl(l_consolidation_method_id, 0) = 1 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN Others THEN
      IF g_debug = 1 THEN
         debug('Unexpected error:  ' || sqlerrm, 'wms_mdc_pvt.is_across_delivery');
      END IF;
      RETURN FALSE;
END is_across_delivery;


-- API to check if an LPN is a consolidated LPN
FUNCTION is_mdc_lpn(p_lpn_id IN NUMBER) RETURN BOOLEAN IS

   CURSOR lpn_cursor IS
      SELECT wlpn.lpn_id, lpn_context
        FROM wms_license_plate_numbers wlpn
        WHERE wlpn.outermost_lpn_id = p_lpn_id;

   --l_lpn_context NUMBER;
   l_loose_exists VARCHAR2(1);
BEGIN
   IF g_debug = 1 THEN
      debug('Entered ..is_mdc_lpn : ' , 'wms_mdc_pvt.is_mdc_lpn');
      debug('p_lpn_id : ' || p_lpn_id, 'wms_mdc_pvt.is_mdc_lpn');
   END IF;
   FOR rec_lpn IN lpn_cursor LOOP
      -- Call IS_ACROSS_DELIVERY foreach of the LPNs that have material. If this LPN is tied
      -- to an operation plan that specifies packing Within  Deliveries,
      -- then return false and exit the loop.

      IF g_debug = 1 THEN
         debug('rec_lpn.lpn_id:rec_lpn.lpn_context ' || rec_lpn.lpn_id || ':' || rec_lpn.lpn_context
              , 'wms_mdc_pvt.is_mdc_lpn');
      END IF;
      IF NOT is_across_delivery(rec_lpn.lpn_id, rec_lpn.lpn_context) THEN
         IF g_debug = 1 THEN
            debug('Exiting  ..is_mdc_lpn : FALSE '   , 'wms_mdc_pvt.is_mdc_lpn');
         END IF;
         RETURN FALSE;
      END IF;
   END LOOP;

   IF g_debug = 1 THEN
      debug('Exiting  ..is_mdc_lpn : TRUE '   , 'wms_mdc_pvt.is_mdc_lpn');
   END IF;

   RETURN TRUE;

END is_mdc_lpn;

-- API to check if an LPN1 (delivery D1) can be packed into another LPN2
-- p_local_caller   IN  VARCHAR2 DEFAULT 'N', It will be passed as 'Y' when called from the overloaded
-- validate_to_lpn (used for mass_move functionality ). No one else should ever use it
PROCEDURE validate_to_lpn
          (p_from_lpn_id              IN  NUMBER,               -- LPN1
           p_from_delivery_id         IN  NUMBER DEFAULT NULL,  -- delivery ID for material in LPN1
           p_to_lpn_id                IN  NUMBER,               -- LPN2
           p_is_from_to_delivery_same IN  VARCHAR2,             -- Y,N,U
           p_is_from_lpn_mdc          IN  VARCHAR2 DEFAULT 'U',
           p_is_to_lpn_mdc            IN  VARCHAR2 DEFAULT 'U',
           p_to_sub                   IN  VARCHAR2 DEFAULT NULL,
           p_to_locator_id            IN  NUMBER   DEFAULT NULL,
           p_local_caller             IN  VARCHAR2 DEFAULT 'N',
           x_allow_packing            OUT nocopy VARCHAR2,      -- Y,N,C,L
           x_return_status            OUT nocopy VARCHAR2,
           x_msg_count                OUT nocopy NUMBER,
           x_msg_data                 OUT nocopy VARCHAR2) IS

   l_from_lpn_mdc             BOOLEAN;     -- Is the LPN1 an MDC LPN?
   l_to_lpn_mdc               BOOLEAN;     -- Is the LPN2 an MDC LPN?
   l_loose_exists             VARCHAR2(1); -- Does there exist any loose material in an LPN
   l_in_staging               VARCHAR2(1); -- Does the LPN reside in a non staging locator
   l_is_from_to_delivery_same VARCHAR2(1); -- Do LPN1 and LPN2 have material for the same delivery?
   l_from_delivery_id         NUMBER;      -- Delivery ID for material in LPN1
   l_to_delivery_id           NUMBER;      -- Delivery ID for material in LPN2
   l_deconsolidation_location NUMBER;
   l_deliveries               wsh_util_core.id_tab_type;
   l_to_lpn_context           NUMBER;      -- LPN context
   l_allow_packing            VARCHAR2(1); -- Allow packing LPN1 into LPN2?
   l_from_delivery_type       VARCHAR2(30);
   l_to_delivery_type         VARCHAR2(30);
   l_to_lpn_organization_id   NUMBER;
   l_outermost_lpn_id         NUMBER;      -- To check if the TO LPn is the outermost or not
BEGIN
   x_return_status := 'S';

   IF g_debug = 1 THEN
      debug('Entered.. wms_mdc_pvt.validate_to_lpn(single): ' , 'wms_mdc_pvt.validate_to_lpn');
      debug('p_from_lpn_id: '               || p_from_lpn_id, 'wms_mdc_pvt.validate_to_lpn');
      debug('p_from_delivery_id: '          || p_from_delivery_id, 'wms_mdc_pvt.validate_to_lpn');
      debug('p_to_lpn_id: '                 || p_to_lpn_id, 'wms_mdc_pvt.validate_to_lpn');
      debug('p_is_from_to_delivery_same : ' || p_is_from_to_delivery_same, 'wms_mdc_pvt.validate_to_lpn');
      debug('p_is_from_lpn_mdc : '          || p_is_from_lpn_mdc, 'wms_mdc_pvt.validate_to_lpn');
      debug('p_is_to_lpn_mdc  : '           || p_is_to_lpn_mdc , 'wms_mdc_pvt.validate_to_lpn');
      debug('p_to_sub : '                   || p_to_sub, 'wms_mdc_pvt.validate_to_lpn');
      debug('p_to_locator_id : '            || p_to_locator_id, 'wms_mdc_pvt.validate_to_lpn');
      debug('p_local_caller  : '            || p_local_caller , 'wms_mdc_pvt.validate_to_lpn');
   END IF;

   l_is_from_to_delivery_same := p_is_from_to_delivery_same;
   IF p_is_from_to_delivery_same IS NULL THEN
      l_is_from_to_delivery_same := 'U';
   END IF;

   --{{ From LPN  Should have NOT NULL Delivery }}
   --{{ From LPN  Should have only 1 Delivery }}
   --{{ From LPN's Delivery should not be a consolidated Delivery }}
   IF l_is_from_to_delivery_same = 'N' AND p_local_caller = 'Y' THEN
       null; -- No need to derive delivery_ids
   ELSE
      l_from_delivery_id := p_from_delivery_id;
      IF l_from_delivery_id IS NULL OR l_from_delivery_id = 0 THEN
         l_from_delivery_id := get_delivery_id(p_from_lpn_id);
      END IF;

      IF g_debug = 1 THEN
         debug('l_from_delivery_id: ' || l_from_delivery_id, 'wms_mdc_pvt.validate_to_lpn');
      END IF;

      IF l_from_delivery_id is NULL AND NOT (p_to_lpn_id = 0 OR p_to_lpn_id IS NULL) THEN
         x_allow_packing := 'N' ; -- U  gets  used in WMSPKDPB.pls
         IF g_debug = 1 THEN
            debug('WMS_FROM_LPN_NO_DELIVERY : from lpn has no delivery : ' ,
                  'wms_mdc_pvt.validate_to_lpn');
         END IF;
         fnd_message.set_name('WMS', 'WMS_FROM_LPN_NO_DELIVERY');
         fnd_msg_pub.ADD;
         -- Check the to_lpn before raising it
         -- RAISE fnd_api.g_exc_error;
      END IF;

      IF l_from_delivery_id IS NOT NULL THEN
         l_from_delivery_type := get_delivery_type (p_delivery_id => l_from_delivery_id);
      END IF;

      IF g_debug = 1 THEN
         debug('l_from_delivery_type: ' || l_from_delivery_type, 'wms_mdc_pvt.validate_to_lpn');
      END IF;

      IF l_from_delivery_type = 'CONSOLIDATION' THEN
         x_allow_packing := 'C' ;
         -- further checks in the caller: pick_drop and staging_move and mass_move
         IF g_debug = 1 THEN
            debug('WMS_FROM_LPN_CONSOL : from lpn is a consol LPN: ' ,
                  'wms_mdc_pvt.validate_to_lpn');
         END IF;
         IF P_TO_LPN_ID = 0 OR p_to_lpn_id IS NULL  THEN
            IF g_debug = 1 THEN
               debug('WMS_FROM_LPN_CONSOL : from lpn is a consol LPN: ' ,
                     'wms_mdc_pvt.validate_to_lpns');
            END IF;
            fnd_message.set_name('WMS', 'WMS_FROM_LPN_CONSOL');
            fnd_msg_pub.ADD;
            --RAISE fnd_api.g_exc_error; No need to raise it ..check other conditions first
         ELSE
            IF g_debug = 1 THEN
               debug('WMS_CONSOL_LPN_NESTING_NOTALLOWED : From LPNs is ' ||
                     'a Consol LPN, No further nesting is allowed ' ,
                     'wms_mdc_pvt.validate_to_lpns');
                  --{{- From LPNs is a Consol LPN, No further nesting is allowed }}
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONSOL_NESTING_NOTALLOWED');
            fnd_msg_pub.ADD;
            x_allow_packing := 'N' ;
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
   END IF;


   IF (p_to_lpn_id = 0 OR p_to_lpn_id IS NULL)  THEN
      null;
   ELSE
      SELECT lpn_context , organization_id, outermost_lpn_id
      INTO l_to_lpn_context , l_to_lpn_organization_id, l_outermost_lpn_id
      FROM wms_license_plate_numbers
      WHERE lpn_id = p_to_lpn_id;
      IF g_debug = 1 THEN
         debug('l_to_lpn_context for p_to_lpn_id : ' || l_to_lpn_context
                                                     || ': '
                                                     || p_to_lpn_id
                                                     || ':in org : '
                                                     || l_to_lpn_organization_id ,
                                                     'wms_mdc_pvt.validate_to_lpn');
         debug('l_outermost_lpn_id: '                || l_outermost_lpn_id ,
                                                     'wms_mdc_pvt.validate_to_lpn');
      END IF;
      l_in_staging := 'N';
      l_loose_exists := 'N';
      l_allow_packing := 'N';

      IF l_to_lpn_context = 5 AND p_local_caller = 'N' THEN
         -- means only 1 from LPN
         l_is_from_to_delivery_same := 'Y';
         l_allow_packing := 'Y';
      ELSE
         IF g_debug = 1 THEN
            debug('Check is the to_locator is a staging locator ', 'wms_mdc_pvt.validate_to_lpn');
         END IF;
         BEGIN
            SELECT 'Y'
            INTO l_in_staging
            FROM mtl_item_locations mil
            WHERE mil.organization_id       = l_to_lpn_organization_id
              AND mil.subinventory_code     = p_to_sub
              AND mil.inventory_location_id = p_to_locator_id
              AND mil.inventory_location_type = 2;
         EXCEPTION
         WHEN no_data_found THEN
            l_in_staging := 'N';
         END;
         IF g_debug = 1 THEN
            debug('l_in_staging : ' || l_in_staging , 'wms_mdc_pvt.validate_to_lpn');
         END IF;

      IF l_from_delivery_type = 'CONSOLIDATION' THEN
         IF l_in_staging = 'N' THEN
            x_allow_packing := 'N' ;
            IF g_debug = 1 THEN
               debug('WMS_MDC_IN_STAGING_ONLY : The new TO LPN is not in staging locator. Consolidation ' ||
                     ' Across Delivery is allowed in staging locator only: ' , 'wms_mdc_pvt.validate_to_lpn');
               --{{- TO LPN must be in staging locator. Consolidation Across Delivery is allowed }}
               --{{  in staging locator only }}
            END IF;
            fnd_message.set_name('WMS', 'WMS_MDC_IN_STAGING_ONLY');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         ELSE    -- not a consol delivery of from LPN
            x_allow_packing := 'Y' ;
            Return;
         END IF;
         --{{- Newly generated TOLPN (context - defined but not used) should allow packing if }}
         --{{  from LPN is a consol LPN and TLPN is in Staging locator}}
         --{{- Newly generated TOLPN (context - defined but not used) should allow packing in }}
         --{{  any locatory type, if fromLPN is NOT a consolLPN }}
      END IF ;
      IF g_debug = 1 THEN
         debug('l_allow_packing: ' || l_allow_packing , 'wms_mdc_pvt.validate_to_lpn'); END IF;
   END IF ;

   /*  Bug: 5478071
    * Added the foll. for better readability. Once the 3 conditions are met for
    * to_lpn, we need can just return with allow_packing with V (further validation
    * required) */
   IF l_to_lpn_context = 5 AND p_local_caller = 'Y' AND l_in_staging = 'Y'
   THEN
       l_allow_packing := 'V';
       return;
   END IF;

   IF l_to_lpn_context = 5 THEN
      NULL;
   ELSE
      IF l_is_from_to_delivery_same = 'U' OR l_is_from_to_delivery_same IS NULL  THEN
         -- we have already derived from delivery_id ;
         IF l_to_delivery_id IS NULL THEN
            l_to_delivery_id := get_delivery_id(p_to_lpn_id);
         END IF;

         IF g_debug = 1 THEN
            debug('l_to_delivery_id: ' || l_to_delivery_id, 'wms_mdc_pvt.validate_to_lpn');
         END IF;
         -- the following will not be executed for context 5 toLPNs

         --{{ To LPN  Should have NOT NULL Delivery ..}}
         --The following is to find is one of them is null, then what shld be
         --the order of erro messages
         IF NOT (l_to_delivery_id is NOT NULL AND   l_from_delivery_id IS NOT NULL) THEN
            IF (l_to_delivery_id is NULL ) THEN
               x_allow_packing := 'N' ; -- U gets used in WMSPKDPB.pls
               IF g_debug = 1 THEN
                  debug('WMS_TO_LPN_NO_DELIVERY : TO lpn has no delivery : ' ,
                        'wms_mdc_pvt.validate_to_lpn');
               END IF;
               fnd_message.set_name('WMS', 'WMS_TO_LPN_NO_DELIVERY');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            ELSE  -- TODEL is not null and FROMDEL is null
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         IF l_to_delivery_id = l_from_delivery_id THEN
            l_is_from_to_delivery_same := 'Y';
         ELSE
            l_is_from_to_delivery_same := 'N';
         END IF;
      END IF;
   END IF;
   IF g_debug = 1 THEN
      debug('l_is_from_to_delivery_same : '|| l_is_from_to_delivery_same
                   , 'wms_mdc_pvt.validate_to_lpn');
   END IF;
   IF l_is_from_to_delivery_same = 'Y' THEN
      x_allow_packing := 'Y';
      return;
   END IF ;
   IF l_to_lpn_context = 5 THEN
      null;
   ELSE
      IF g_debug = 1 THEN
         debug('l_is_from_to_delivery_same is NO ' , 'wms_mdc_pvt.validate_to_lpn');
      END IF;
      IF l_outermost_lpn_id <> p_to_lpn_id THEN
         x_allow_packing := 'N' ;
         IF g_debug = 1 THEN
            debug('WMS_CANNOT_CONSOL_INNERLPN : TOLPN is an inner LPN. Cannot consolidate : '
                  , 'wms_mdc_pvt.validate_to_lpn');
            --{{Cannot comingle AD/WD material in TO LPN }}
         END IF;
         fnd_message.set_name('WMS', 'WMS_CANNOT_CONSOL_INNERLPN');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;
      BEGIN
         SELECT 'Y'
         INTO l_in_staging
         FROM mtl_item_locations mil, wms_license_plate_numbers wlpn
         WHERE wlpn.lpn_id = p_to_lpn_id
         AND wlpn.locator_id = mil.inventory_location_id
         AND mil.inventory_location_type = 2;
      EXCEPTION
         WHEN no_data_found THEN
         l_in_staging := 'N';
      END;
      IF g_debug = 1 THEN
         debug('l_in_staging : ' || l_in_staging , 'wms_mdc_pvt.validate_to_lpn');
      END IF;
   END IF;

  IF l_to_lpn_context = 5 AND p_local_caller = 'N' THEN
     null;
  ELSE
   IF l_in_staging = 'Y' THEN
      BEGIN
         SELECT 'Y'
         INTO l_loose_exists
         FROM wms_lpn_contents wlc
         WHERE wlc.parent_lpn_id = p_to_lpn_id
         AND   ROWNUM =1;
      EXCEPTION
         WHEN no_data_found THEN
            l_loose_exists := 'N';
      END;

      IF g_debug = 1 THEN
         debug('Loose Exists: ' || l_loose_exists, 'wms_mdc_pvt.validate_to_lpn');
      END IF;
      IF l_loose_exists = 'N' THEN
            IF p_local_caller = 'N' THEN
               IF p_is_from_lpn_mdc = 'Y' THEN
                  l_from_lpn_mdc := TRUE;
                ELSIF p_is_from_lpn_mdc = 'N' THEN
                  l_from_lpn_mdc := FALSE;
                ELSE
                  l_from_lpn_mdc := is_mdc_lpn(p_from_lpn_id);
               END IF;
               IF g_debug = 1 THEN
                  IF l_from_lpn_mdc THEN
                     debug('l_from_lpn_mdc : TRUE    ' , 'wms_mdc_pvt.validate_to_lpn');
                  ELSE
                     debug('l_from_lpn_mdc : FALSE    ' , 'wms_mdc_pvt.validate_to_lpn');
                  END IF;
               END IF;

               IF p_is_to_lpn_mdc = 'Y' THEN
                  l_to_lpn_mdc := TRUE;
                ELSIF p_is_to_lpn_mdc = 'N' THEN
                  l_to_lpn_mdc := FALSE;
                ELSE
                  l_to_lpn_mdc := is_mdc_lpn(p_to_lpn_id);
               END IF;

               IF g_debug = 1 THEN
                  IF l_to_lpn_mdc THEN
                     debug('l_to_lpn_mdc : TRUE    ' , 'wms_mdc_pvt.validate_to_lpn');
                  ELSE
                     debug('l_to_lpn_mdc : FALSE    ' , 'wms_mdc_pvt.validate_to_lpn');
                  END IF;
               END IF;

               IF l_from_lpn_mdc AND  l_to_lpn_mdc THEN
                  l_deliveries(1) := l_from_delivery_id;

                  IF get_delivery_type (p_delivery_id => l_to_delivery_id) = 'CONSOLIDATION' THEN
                     Null;
                  ELSE
                     l_deliveries(2) := l_to_delivery_id;
                     IF g_debug = 1 THEN
                        debug('p_input_delivery_id_tab : ' || l_deliveries(2),
                              'wms_mdc_pvt.validate_to_lpn');
                     END IF;
                  END IF;

                  IF g_debug = 1 THEN
                     debug('wsh_fte_comp_constraint_grp.is_valid_consol called: ' ,
                           'wms_mdc_pvt.validate_to_lpn');
                     debug('p_input_delivery_id_tab : ' || l_deliveries(1) ,
                           'wms_mdc_pvt.validate_to_lpn');
                     debug('p_caller = WMS: ', 'wms_mdc_pvt.validate_to_lpn');
                  END IF;
                  --Call shipping API to validate
                  WSH_WMS_LPN_GRP.is_valid_consol
                             (p_init_msg_list             => NULL,
                              p_input_delivery_id_tab     => l_deliveries,
                              p_target_consol_delivery_id => get_consol_delivery_id(p_lpn_id => p_to_lpn_id),
                              p_caller                    => 'WMS',
                              x_deconsolidation_location  => l_deconsolidation_location,
                              x_return_status             => x_return_status,
                              x_msg_count                 => x_msg_count,
                              x_msg_data                  => x_msg_data);

                  IF g_debug = 1 THEN
                     debug ('x_return_status : ' || x_return_status , 'wms_mdc_pvt.validate_to_lpn');
                     debug ('x_msg_data : '      || x_msg_data, 'wms_mdc_pvt.validate_to_lpn');
                     debug ('x_msg_count : '     || x_msg_count, 'wms_mdc_pvt.validate_to_lpn');
                     debug ('x_deconsolidation_location : ' || l_deconsolidation_location,
                            'wms_mdc_pvt.validate_to_lpn');
                  END IF;
                  IF x_return_status <> 'S' THEN
                     IF g_debug = 1 THEN
                        debug ('Error from wsh_fte_comp_constraint_grp.is_valid_consol: ' || x_return_status,
                                'wms_mdc_pvt.validate_to_lpn');
                        debug ('x_msg_data : ' || x_msg_data, 'wms_mdc_pvt.validate_to_lpn');
                     END IF;

                     IF x_return_status = 'E' THEN
                        RAISE fnd_api.g_exc_error;
                     ELSE
                        RAISE fnd_api.g_exc_unexpected_error;
                     END IF;
                  ELSE
                     IF l_deconsolidation_location IS NOT NULL THEN
                        l_allow_packing := 'Y';
                     ELSE
                        l_allow_packing := 'N';
                     END IF;
                  END IF;
               ELSE  -- NOT l_from_lpn_mdc and/OR NOT l_to_lpn_mdc
                  x_allow_packing := 'N' ;
                  IF g_debug = 1 THEN
                     debug('WMS_CANNOT_COMMINGLE_ADWD : cannto comingle AD/WD material: ' ,
                           'wms_mdc_pvt.validate_to_lpn');
                          --{{Cannot comingle AD/WD material in TO LPN }}
                  END IF;
                  fnd_message.set_name('WMS', 'WMS_CANNOT_COMMINGLE_ADWD');
                  fnd_msg_pub.ADD;
                  RAISE fnd_api.g_exc_error;
               END IF;
            ELSE
               l_allow_packing := 'V';
            END IF ; --p_local_caller = 'N' THEN
      ELSE -- l_loose_exists = 'Y' THEN
         x_allow_packing := 'N' ;
         IF g_debug = 1 THEN
            debug('WMS_LOOSE_TO_LPN : Loose material exist in TO LPN' , 'wms_mdc_pvt.validate_to_lpn');
            --{{Cannot Pack into TO LPN that has loose material }}
         END IF;
         fnd_message.set_name('WMS', 'WMS_LOOSE_TO_LPN');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
         END IF ;
   ELSE -- l_in_staging = 'N' THEN
      x_allow_packing := 'N' ;
      IF g_debug = 1 THEN
         debug('WMS_MDC_IN_STAGING_ONLY : TO LPN is not in staging locator. Consolidation ' ||
                ' Across Delivery is allowed in staging locator only: ' , 'wms_mdc_pvt.validate_to_lpn');
         --{{TO LPN must be in staging locator. Consolidation Across Delivery is allowed
         --in staging locator only }}
      END IF;
      fnd_message.set_name('WMS', 'WMS_MDC_IN_STAGING_ONLY');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;
  END IF; -- l_to_lpn_context = 5 AND p_local_caller = 'N' THEN

END IF; -- to_lpn_id is not null

   IF g_debug = 1 THEN
      debug ('l_allow_packing : ' || l_allow_packing, 'wms_mdc_pvt.validate_to_lpn');
   END IF;
   x_allow_packing := l_allow_packing;
   x_return_status := 'S';

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := 'E';
      IF g_debug = 1 THEN
         debug('Error', 'wms_mdc_pvt.validate_to_lpn');
      END IF;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := 'U';
      IF g_debug = 1 THEN
         debug('Unexpected Error', 'wms_mdc_pvt.validate_to_lpn');
      END IF;
   WHEN OTHERS THEN
      x_return_status := 'U';
      x_msg_data := SQLERRM;
      IF g_debug = 1 THEN
         debug('SQL error: ' || SQLERRM, 'wms_mdc_pvt.validate_to_lpn');
      END IF;
END validate_to_lpn;


-- API to suggest drop LPN, Subinventory and Locator
PROCEDURE suggest_to_lpn(p_lpn_id               IN NUMBER,           -- The LPN that is being dropped (from LPN)
                         p_delivery_id          IN NUMBER,           -- The delivery associated with the LPN
                         x_to_lpn_id            OUT nocopy NUMBER,   -- The LPN that is being dropped
                         x_to_subinventory_code OUT nocopy VARCHAR2, -- The subinventory of the suggested LPN
                         x_to_locator_id        OUT nocopy NUMBER,   -- The locator of the suggested LPN
                         x_return_status        OUT nocopy VARCHAR2,
                         x_msg_count            OUT nocopy NUMBER,
                         x_msg_data             OUT nocopy VARCHAR2) IS

   l_from_delivery_id    NUMBER;      -- The delivery for which material is packed in from LPN
   l_allow_packing       VARCHAR2(1); -- Allow packing from LPN into the suggested LPN
BEGIN
   x_return_status := 'S';

   IF g_debug = 1 THEN
      debug('p_lpn_id: ' || p_lpn_id, 'wms_mdc_pvt.suggest_to_lpn');
      debug('p_delivery_id: ' || p_delivery_id, 'wms_mdc_pvt.suggest_to_lpn');
   END IF;

   -- Algorithm
   -- If the Consolidation Method in the operation plan is set to
   -- Across Deliveries in staging lane, then the following algorithm
   -- should be used to suggest the Drop LPN
   -- * If another LPN belonging to the same delivery is staged,
   --   divert LPN to the locator where the first LPN was staged.
   --   If there are multiple LPNs for that delivery that have been staged,
   --   then use the last LPN (time-stamp). Divert to the outer LPN of the
   --   above line (if display LPN is opted in the operation plan).  This
   --   simply means that nesting/pallet building is desired.  Allow user to
   --   override and drop LPN as is or into a different Outer LPN.
   -- * Use parent delivery or trip stop to make suggestions is the above
   --   query does not return any suggestion
   -- * If this is the first LPN to be dropped, divert to the staging lane
   --   suggested by pick/cross-dock release (suggest nothing)

   --{{ From LPN is a Consol LPN..no further checking}}
   --{{ From LPN with delivery D1 is MDC }}
   --{{ From LPN with delivery D1 is not MDC}}

   IF get_consol_delivery_id(p_lpn_id => p_lpn_id)  IS NOT  NULL THEN
      IF g_debug = 1 THEN
            debug('From LPN is a consol delivery LPN : ' , 'wms_mdc_pvt.validate_to_lpns');
      END IF;
   ELSE


   IF is_mdc_lpn(p_lpn_id) THEN -- If the LPN is an MDC LPN

      l_from_delivery_id := p_delivery_id;
      IF Nvl(l_from_delivery_id, 0) = 0 THEN
         --Find the Delivery for the From LPN
         l_from_delivery_id := get_delivery_id(p_lpn_id);
      END IF;

      IF g_debug = 1 THEN
         debug('From Delivery ID: ' || l_from_delivery_id, 'wms_mdc_pvt.suggest_to_lpn');
      END IF;

      IF Nvl(l_from_delivery_id, 0) <> 0 THEN
         --{{There is another staged LPN2 with material for D1, LPN2 has loose material }}
         --{{There is another staged LPN2 with material for D1, LPN2 has no loose material }}
         --{{There is another staged LPN2 with material for D2, LPN2 has no loose material }}
         -- Find if another LPN with material for the same delivery is staged in a staging locator
         BEGIN
            SELECT outermost_lpn_id, subinventory_code, locator_id
              INTO x_to_lpn_id, x_to_subinventory_code, x_to_locator_id
              FROM
              (SELECT wlpn.outermost_lpn_id, wlpn.subinventory_code, wlpn.locator_id
               FROM   wsh_delivery_assignments wda
                    , wsh_delivery_details_ob_grp_v wdd
                    , mtl_item_locations mil
                    , wms_license_plate_numbers wlpn
                    , wms_dispatched_tasks_history wdth
               WHERE wdd.delivery_detail_id = wda.delivery_detail_id
               AND wdd.lpn_id = wlpn.lpn_id
               AND wlpn.lpn_id <> p_lpn_id
               AND wlpn.outermost_lpn_id <> p_lpn_id
               AND wlpn.LPN_CONTEXT  = 11
               AND wlpn.locator_id = mil.inventory_location_id
               AND wlpn.organization_id = mil.organization_id
               AND mil.inventory_location_type = 2 -- Staging
               AND wdth.transfer_lpn_id = wdd.lpn_id
               AND NOT exists (SELECT 1
                               FROM wms_lpn_contents wlc
                               WHERE wlc.parent_lpn_id = wlpn.outermost_lpn_id)
                  -- above is to check that the outermost lpn being suggested
                  -- does nto have Looase material
               AND wda.delivery_id = l_from_delivery_id
               ORDER BY wdth.creation_date DESC)
              WHERE ROWNUM = 1;
         IF g_debug = 1 THEN
            debug('Cursor 1: same Delivery: ' , 'wms_mdc_pvt.suggest_to_lpn');
         END IF;
         EXCEPTION
            WHEN no_data_found THEN
               IF g_debug = 1 THEN
                  debug('No staged material with the same delivery found in staging locators',
                        'wms_mdc_pvt.suggest_to_lpn');
               END IF;
         END;

         --{{There is another staged LPN2 with material for same parent delivery, no staged LPN
         --  has material for D1 }}
         -- Find if another LPN with material for the same parent delivery is staged in a staging locator
         IF Nvl(x_to_lpn_id, 0) = 0 THEN
           BEGIN
              SELECT outermost_lpn_id, subinventory_code, locator_id
                INTO x_to_lpn_id, x_to_subinventory_code, x_to_locator_id
                FROM
                (SELECT wlpn.outermost_lpn_id, wlpn.subinventory_code, wlpn.locator_id
                 FROM   wsh_delivery_assignments wda
                      , wsh_delivery_details_ob_grp_v wdd
                      , mtl_item_locations mil
                      , wms_license_plate_numbers wlpn
                      , wms_dispatched_tasks_history wdth
                 WHERE wdd.delivery_detail_id = wda.delivery_detail_id
                 AND wdd.lpn_id = wlpn.lpn_id
                 AND wlpn.lpn_id <> p_lpn_id
                 AND wlpn.outermost_lpn_id <> p_lpn_id
                 AND wlpn.LPN_CONTEXT  = 11
                 AND wlpn.locator_id = mil.inventory_location_id
                 AND wlpn.organization_id = mil.organization_id
                 AND mil.inventory_location_type = 2
                 AND wdth.transfer_lpn_id = wdd.lpn_id
                 AND NOT exists (SELECT 1
                                 FROM wms_lpn_contents wlc
                                 WHERE wlc.parent_lpn_id = wlpn.outermost_lpn_id)
                 AND wda.delivery_id IN (SELECT l2.delivery_id
                                         FROM wsh_delivery_legs l1, --_ob_grp_v l1,
                                              wsh_delivery_legs l2 --_ob_grp_v l2
                                         WHERE l1.delivery_id = l_from_delivery_id
                                         AND l1.parent_delivery_leg_id = l2.parent_delivery_leg_id)
                 --- above sub query: that this del is a prt of a consol
                ORDER BY wdth.creation_date DESC)
                WHERE ROWNUM = 1;
            IF g_debug = 1 THEN
               debug('Cursor 2: same Delivery in a consol: ' , 'wms_mdc_pvt.suggest_to_lpn');
            END IF;
           EXCEPTION
              WHEN no_data_found THEN
                 IF g_debug = 1 THEN
                    debug('No staged material with the same parent delivery found in staging locators',
                          'wms_mdc_pvt.suggest_to_lpn');
                 END IF;
           END;
         END IF;

         --{{There is another staged LPN2 with material for same trip, no staged LPN has material for
         --   D1, no staged LPN has material FOR the same parent delivery}}
         -- Find if another LPN with material for deliveries of a delivery that
         -- share the same trip from initial pickup and dropoff
         IF Nvl(x_to_lpn_id, 0) = 0 THEN
            BEGIN
               SELECT outermost_lpn_id, subinventory_code, locator_id
                 INTO x_to_lpn_id, x_to_subinventory_code, x_to_locator_id
                 FROM
                 (SELECT wlpn.outermost_lpn_id, wlpn.subinventory_code, wlpn.locator_id
                  FROM   wsh_delivery_assignments wda
                       , wsh_delivery_details_ob_grp_v wdd
                       , mtl_item_locations mil
                       , wms_license_plate_numbers wlpn
                       , wms_dispatched_tasks_history wdth
                  WHERE wdd.delivery_detail_id = wda.delivery_detail_id
                  AND wdd.lpn_id = wlpn.lpn_id
                  AND wlpn.lpn_id <> p_lpn_id
                  AND wlpn.outermost_lpn_id <> p_lpn_id
                  AND wlpn.LPN_CONTEXT  = 11
                  AND wlpn.locator_id = mil.inventory_location_id
                  AND wlpn.organization_id = mil.organization_id
                  AND mil.inventory_location_type = 2
                  AND wdth.transfer_lpn_id = wdd.lpn_id
                  AND NOT exists (SELECT 1
                                  FROM wms_lpn_contents wlc
                                  WHERE wlc.parent_lpn_id = wlpn.outermost_lpn_id)
                  AND wda.delivery_id IN (SELECT l2.delivery_id
                                          FROM   wsh_delivery_legs_ob_grp_v l1
                                               , wsh_delivery_legs_ob_grp_v l2
                                               , wsh_trip_stops_ob_grp_v s
                                               , wsh_new_deliveries_ob_grp_v d
                                          WHERE d.delivery_id = l_from_delivery_id
                                          AND d.initial_pickup_location_id = s.stop_location_id
                                          AND d.delivery_id = l1.delivery_id
                                          AND s.stop_id = l1.pick_up_stop_id
                                          AND l1.pick_up_stop_id = l2.pick_up_stop_id)
                                          --01/02/07:5475113 AND l1.drop_off_stop_id = l2.drop_off_stop_id)
                  -- above subquery: that this delvery is a part of Trip
                 ORDER BY wdth.creation_date DESC)
                 WHERE ROWNUM = 1;
              IF g_debug = 1 THEN
                 debug('Cursor 3: same Delivery in a consol: ' , 'wms_mdc_pvt.suggest_to_lpn');
              END IF;
            EXCEPTION
               WHEN no_data_found THEN
                  IF g_debug = 1 THEN
                     debug('No staged material with the same trip found in staging locators',
                           'wms_mdc_pvt.suggest_to_lpn');
                  END IF;
            END;
         END IF;

         IF g_debug = 1 THEN
            debug('To LPN ID: ' || x_to_lpn_id, 'wms_mdc_pvt.suggest_to_lpn');
            debug('To Subinventory: ' || x_to_subinventory_code, 'wms_mdc_pvt.suggest_to_lpn');
            debug('To Locator ID: ' || x_to_locator_id, 'wms_mdc_pvt.suggest_to_lpn');
         END IF;

         -- Validate that the From LPN can be packed into the To LPN.
         IF Nvl(x_to_lpn_id, 0) <> 0  THEN
            validate_to_lpn(p_from_lpn_id              => p_lpn_id,
                            p_from_delivery_id         => l_from_delivery_id,
                            p_to_lpn_id                => x_to_lpn_id,
                            p_is_from_to_delivery_same => 'U',
                            p_to_sub                   => NULL,
                            p_to_locator_id            => NULL,
                            x_allow_packing            => l_allow_packing,
                            x_return_status            => x_return_status,
                            x_msg_count                => x_msg_count,
                            x_msg_data                 => x_msg_data);

            IF x_return_status <> 'S' THEN
               IF g_debug = 1 THEN
                  debug ('Error from validate_to_lpn: ' || x_return_status, 'wms_mdc_pvt.suggest_to_lpn');
                  debug ('x_msg_data : ' || x_msg_data, 'wms_mdc_pvt.suggest_to_lpn');
               END IF;

               /*-- MRANA:  3/26/07: it is OK, not to find any valid LPN to
               -- suggest, therefore there is no need to raise an error.
               IF x_return_status = 'E' THEN
                   RAISE fnd_api.g_exc_error;
                ELSE
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF; */
               x_return_status := 'S';
               l_allow_packing := 'N';
               x_to_lpn_id := NULL;
               x_to_subinventory_code := NULL;
               x_to_locator_id := NULL;
             ELSE
               IF g_debug = 1 THEN
                  debug ('Allow Packing: ' || l_allow_packing, 'wms_mdc_pvt.suggest_to_lpn');
               END IF;

               IF l_allow_packing <> 'Y' THEN
                  x_to_lpn_id := NULL;
                  x_to_subinventory_code := NULL;
                  x_to_locator_id := NULL;
               END IF;

            END IF;
         END IF;
      END IF;
   END IF;
   END IF; -- P_lpn_id is a consol LPN
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := 'E';
      IF g_debug = 1 THEN
         debug('Error', 'wms_mdc_pvt.suggest_to_lpn');
      END IF;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := 'U';
      IF g_debug = 1 THEN
         debug('Unexpected Error', 'wms_mdc_pvt.suggest_to_lpn');
      END IF;

   WHEN OTHERS THEN
      x_return_status := 'U';
      x_msg_data := SQLERRM;
      IF g_debug = 1 THEN
         debug('SQL error: ' || SQLERRM, 'wms_mdc_pvt.suggest_to_lpn');
      END IF;
END suggest_to_lpn;

-- check if a delivery D1 can be shipped out
PROCEDURE can_ship_delivery(p_delivery_id    NUMBER,
                            x_allow_shipping OUT nocopy VARCHAR2,
                            x_return_status  OUT nocopy VARCHAR2,
                            x_msg_count      OUT nocopy NUMBER,
                            x_msg_data       OUT nocopy VARCHAR2) IS

   l_delivery_id NUMBER;
   l_part_of_consol_delivery  VARCHAR2(1);
BEGIN
   IF g_debug = 1 THEN
      debug('Entered can_ship_delivery with p_delivery_id : ' || p_delivery_id ,
            'wms_mdc_pvt.can_ship_delivery');
   END IF;
   x_allow_shipping := 'Y';
   x_return_status := 'S';
   l_part_of_consol_delivery  := NULL;
   BEGIN
   SELECT  'Y'
     INTO l_part_of_consol_delivery
     FROM wsh_delivery_legs --_ob_grp_v
    WHERE delivery_id = p_delivery_id
     AND  PARENT_DELIVERY_LEG_ID IS NOT NULL
     AND  ROWNUM = 1;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      l_part_of_consol_delivery := 'N';
   END ;

   IF g_debug = 1 THEN
      debug('l_part_of_consol_delivery : ' || l_part_of_consol_delivery ,
            'wms_mdc_pvt.can_ship_delivery');
   END IF;
   IF l_part_of_consol_delivery = 'Y'
   THEN
      x_allow_shipping := 'N' ;
      x_return_status := 'S';
      IF g_debug = 1 THEN
         debug('l_part_of_consol_delivery : ' || l_part_of_consol_delivery ,
               'wms_mdc_pvt.can_ship_delivery');
         debug('WMS_PART_OF_CONSOL : This delivery is a prt of Consol Delivery..' ||
               'cannot ship from here' , 'wms_mdc_pvt.can_ship_delivery');
      END IF;
      fnd_message.set_name('WMS', 'WMS_DEL_PART_OF_CONSOL');
      fnd_msg_pub.ADD;
   ELSE
      x_allow_shipping := 'Y';
   END IF;
   IF g_debug = 1 THEN
      debug('Exit  can_ship_delivery with x_allow_shipping : ' || x_allow_shipping ,
            'wms_mdc_pvt.can_ship_delivery');
   END IF;
END can_ship_delivery;

-- Procedure to check if multiple LPNs LPN1, LPN2, ... can be packed into LPN0
PROCEDURE validate_to_lpn(p_from_lpn_ids             IN  number_table_type,  -- LPN1, LPN2,...
                          p_from_delivery_ids        IN  number_table_type,  -- Delivery1, Delivery2,...
                          p_to_lpn_id                IN  NUMBER,             -- LPN0
                          p_to_sub                   IN  VARCHAR2 DEFAULT NULL,
                          p_to_locator_id            IN  NUMBER DEFAULT NULL,
                          x_allow_packing            OUT nocopy VARCHAR2,
                          -- Y/N/C(consol delivery )
                          x_return_status            OUT nocopy VARCHAR2,
                          x_msg_count                OUT nocopy NUMBER,
                          x_msg_data                 OUT nocopy VARCHAR2) IS

   l_previous_delivery_id     NUMBER := 0;
   l_current_delivery_id      NUMBER := 0;
   l_to_delivery_id           NUMBER := 0;
   l_deliveries               wsh_util_core.id_tab_type;
   l_deliveries_same          BOOLEAN := TRUE;
   l_lpns_ad                  BOOLEAN := TRUE;
   l_allow_packing            VARCHAR2(1);
   l_loose_exists             VARCHAR2(1); -- Does there exist any loose material in an LPN
   l_in_staging               VARCHAR2(1); -- Does the LPN reside in a non staging locator
   l_deconsolidation_location NUMBER;
   l_lpn_context              NUMBER;      -- LPN context
   l_is_consol_LPN            VARCHAR2(1);
   l_local_caller             VARCHAR2(1) := 'Y';
BEGIN

   IF g_debug = 1 THEN
      debug('Entered validate_to_lpn with LPN Count: ' || p_from_lpn_ids.COUNT, 'wms_mdc_pvt.validate_to_lpn');
      debug('p_from_delivery_ids count: ' || p_from_delivery_ids.COUNT, 'wms_mdc_pvt.validate_to_lpn');
      debug('p_to_lpn_id: ' || p_to_lpn_id, 'wms_mdc_pvt.validate_to_lpn');
   END IF;

   -- Loop through all the LPNs to check if all the from LPNs have material for the same delivery
   -- All the from LPN will be in context 11 , The From Locator validations/LOV checks that
   FOR i in 1..p_from_lpn_ids.COUNT LOOP

      l_current_delivery_id := NULL;
      l_is_consol_LPN := 'N';
      l_allow_packing := 'Y';

      -- Get the delivery of the current LPN
      IF p_from_delivery_ids.COUNT > i THEN
         l_current_delivery_id := p_from_delivery_ids(i);
          debug('p_from_delivery_ids(i): ' || p_from_delivery_ids(i), 'wms_mdc_pvt.validate_to_lpn');
      END IF;

      IF get_consol_delivery_id(p_lpn_id => p_from_lpn_ids(i))  IS NOT  NULL THEN
         IF g_debug = 1 THEN
            debug('One of the From LPN is linked to a consol delivery : ' , 'wms_mdc_pvt.validate_to_lpns');
         END IF;
         l_is_consol_LPN := 'Y' ;
         l_deliveries_same := FALSE;
         IF P_TO_LPN_ID = 0 OR p_to_lpn_id IS NULL  THEN
            IF g_debug = 1 THEN
               debug('WMS_ONE_FROM_LPN_CONSOL : One of the from lpns is a consol LPN: ' ,
                     'wms_mdc_pvt.validate_to_lpns');
            END IF;
            l_allow_packing := 'C'; -- this value is used in lpn_mass_move   -- mrcovered
            EXIT; -- No need to check the delivery ids of the remaining
         ELSE
           -- {{- if from_lpn.count = 1 then this condition shld not fail }} -- mrcovered along with the above
           IF g_debug = 1 THEN
               debug('WMS_CONSOL_LPN_NESTING_NOTALLOWED : One of the From LPNs is ' ||
                     'a Consol LPN, No further nesting is allowed ' , 'wms_mdc_pvt.validate_to_lpns');
               --{{- One of the From LPNs is a Consol LPN, No further nesting is allowed }}
           END IF;
           fnd_message.set_name('WMS', 'WMS_CONSOL_NESTING_NOTALLOWED');
           fnd_msg_pub.ADD;
           x_allow_packing := 'N' ;
           RAISE fnd_api.g_exc_error;
           --EXIT; -- No need to check the delivery ids of the remaining
         END IF;
      END IF;

      IF l_current_delivery_id IS NULL OR l_current_delivery_id = 0 THEN
         l_current_delivery_id := get_delivery_id(p_from_lpn_ids(i));
         IF l_current_delivery_id is NULL AND NOT (p_to_lpn_id = 0 OR p_to_lpn_id IS NULL) THEN
            l_allow_packing := 'N' ; -- U  gets  used in WMSPKDPB.pls
            IF g_debug = 1 THEN
               debug('WMS_ONE_FROM_LPN_NO_DEL : from lpn has no delivery : ' , 'wms_mdc_pvt.validate_to_lpn');
            END IF;
            fnd_message.set_name('WMS', 'WMS_ONE_FROM_LPN_NO_DEL');
            fnd_msg_pub.ADD;
            -- Check the to_lpn before raising it
            --RAISE fnd_api.g_exc_error;
         END IF;
      END IF;



      IF g_debug = 1 THEN
         debug('Delivery ID: ' || l_current_delivery_id, 'wms_mdc_pvt.validate_to_lpn');
      END IF;

      -- If the delivery of the current LPN is different from the delivery of the previous LPN,
      -- exit out of the loop
      IF (i > 1 AND l_current_delivery_id <> l_previous_delivery_id) OR l_current_delivery_id IS NULL THEN
         l_deliveries_same := FALSE;
         EXIT;
      END IF;

      l_previous_delivery_id := l_current_delivery_id;

   END LOOP;
   IF g_debug = 1 THEN
      IF l_deliveries_same  THEN
          debug(' l_deliveries_same is TRUE', 'wms_mdc_pvt.validate_to_lpn');
      ELSE
          debug(' l_deliveries_same is FALSE', 'wms_mdc_pvt.validate_to_lpn');
      END IF;
   END IF;

   IF (p_to_lpn_id = 0 OR p_to_lpn_id IS NULL)  THEN
      null;
   ELSE

      --IF l_allow_packing =  'Y' AND l_deliveries_same THEN
         l_to_delivery_id := get_delivery_id(p_to_lpn_id);

         IF g_debug = 1 THEN
            debug('l_to_delivery_id : ' || l_to_delivery_id , 'wms_mdc_pvt.validate_to_lpn');
            debug('l_current_delivery_id : ' || l_current_delivery_id , 'wms_mdc_pvt.validate_to_lpn');
         END IF;
         IF NOT (l_to_delivery_id is NOT NULL AND   l_current_delivery_id IS NOT NULL)
         THEN
            IF (l_to_delivery_id is NULL ) THEN
               x_allow_packing := 'N' ; -- U gets used in WMSPKDPB.pls
               IF g_debug = 1 THEN
                  debug('WMS_TO_LPN_NO_DELIVERY : TO lpn has no delivery : ' , 'wms_mdc_pvt.validate_to_lpn');
               END IF;
               fnd_message.set_name('WMS', 'WMS_TO_LPN_NO_DELIVERY');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            ELSE  -- TODEL is not null and FROMDEL is null
               x_allow_packing := 'N' ; -- U gets used in WMSPKDPB.pls
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
         IF (l_to_delivery_id <> 0 ) THEN
            debug('l_to_delivery_id <> 0', 'wms_mdc_pvt.validate_to_lpn');
            IF NOT (l_current_delivery_id = l_to_delivery_id) THEN
               l_deliveries_same := FALSE;
               IF g_debug = 1 THEN
                  debug('From LPNS  Delivery is not same as TOLPNs delivery', 'wms_mdc_pvt.validate_to_lpn');
               END IF;
            END IF;
         ELSE
            IF l_deliveries_same  THEN
            -- l_deliveries_same is for from deliveries_same ) THEN
               null;
               IF g_debug = 1 THEN
                  debug('l_deliveries_same l_to_delivery_id=0 ', 'wms_mdc_pvt.validate_to_lpn');
               END IF;
            END IF;
         END IF;

      IF l_allow_packing =  'Y' AND l_deliveries_same THEN
         IF g_debug = 1 THEN
            debug('All FROM and TO LPNS have material for the same delivery', 'wms_mdc_pvt.validate_to_lpn');
         END IF;

         -- All material in the from and to lpns is for the same delivery, allow packing
         l_allow_packing := 'Y';
      END IF;
      IF l_allow_packing = 'Y' AND NOT l_deliveries_same THEN

         IF g_debug = 1 THEN
            debug('All LPNS do not have material for the same delivery', 'wms_mdc_pvt.validate_to_lpn');
         END IF;
         validate_to_lpn(p_from_lpn_id              => p_to_lpn_id,
                                                       -- we are not using it in the calling API
                            p_from_delivery_id         => NULL,
                            p_to_lpn_id                => p_to_lpn_id,
                            p_is_from_to_delivery_same => 'N',
                            p_to_sub                   => p_to_sub,
                            p_to_locator_id            => p_to_locator_id,
                            p_local_caller             => l_local_caller , -- Y
                            x_allow_packing            => l_allow_packing,
                            x_return_status            => x_return_status,
                            x_msg_count                => x_msg_count,
                            x_msg_data                 => x_msg_data);

         -- {{ There is loose material in LPN2}}
         -- {{ LPN2 is in a non staging locator}}
         -- {{ There is no loose material in LPN2}}
         -- {{ LPN2 is in a staging locator}}
         -- Find if there is any loose material in LPN2 or if LPN2 is in a non staging locator
         IF g_debug = 1 THEN
               debug('x_return_status: : ' || x_return_status, 'wms_mdc_pvt.validate_to_lpn');
               debug('x_msg_count: : ' || x_msg_count, 'wms_mdc_pvt.validate_to_lpn');
               debug('x_msg_data: : ' || x_msg_data, 'wms_mdc_pvt.validate_to_lpn');
               debug('x_allow_packing: : ' || l_allow_packing, 'wms_mdc_pvt.validate_to_lpn');
         END IF;

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE fnd_api.g_exc_error;
         END IF;
         IF l_allow_packing = 'N' THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         IF l_allow_packing = 'V' THEN -- further validation needed for non-consol from LPNs
            -- Loop through all the LPNs to make sure that all the from LPNs are AD
            FOR i in 1..p_from_lpn_ids.COUNT LOOP
               IF NOT is_mdc_lpn(p_from_lpn_ids(i)) THEN
                  l_lpns_ad := FALSE;
                  EXIT;
               END IF;
            END LOOP;

            IF g_debug = 1 THEN
               IF l_lpns_ad THEN
                  debug('From Lpn MDC: TRUE ', 'wms_mdc_pvt.validate_to_lpn');
               ELSE
                  debug('From Lpn MDC: FALSE', 'wms_mdc_pvt.validate_to_lpn');
               END IF;
            END IF;

            IF l_to_delivery_id IS NULL OR l_to_delivery_id = 0 THEN
               NULL;
               -- l_lpns_ad will stay as is..false or true..need not reassign
            ELSE
               IF l_lpns_ad AND NOT is_mdc_lpn(p_to_lpn_id) THEN
                  l_lpns_ad := FALSE;
               END IF;

               IF g_debug = 1 THEN
                  IF l_lpns_ad THEN
                     debug('To Lpn MDC: TRUE ', 'wms_mdc_pvt.validate_to_lpn');
                  ELSE
                     debug('To Lpn MDC: FALSE', 'wms_mdc_pvt.validate_to_lpn');
                  END IF;
               END IF;
            END IF;

            IF l_lpns_ad THEN

            /*mrana: 08/22/06  Bug: 5478071
 *          l_to_delivery_id will be 0 only if lpn_context is 5 (defined but not
 *          used) and is returned by get_delivery_id function above
 *          If LPN_context <> 5 and there is no delivery, then l_to_delivery_id
 *          will be NULL and it gets checked in validate_to_lpn API*/
            IF l_to_delivery_id IS NULL THEN
               l_allow_packing := 'N';
               x_allow_packing := 'N' ;
            ELSE
               IF g_debug = 1 THEN
                  debug('All LPNS are across delivery', 'wms_mdc_pvt.validate_to_lpn');
               END IF;

               FOR i IN 1..p_from_lpn_ids.COUNT LOOP
                  l_deliveries(i) := get_delivery_id(p_from_lpn_ids(i));
               END LOOP;

               --Call shipping API to validate
               WSH_WMS_LPN_GRP.is_valid_consol
                 (p_init_msg_list             => NULL,
                  p_input_delivery_id_tab     => l_deliveries,
                  p_target_consol_delivery_id => get_consol_delivery_id(p_lpn_id => p_to_lpn_id),
                  p_caller                    => 'WMS',

                  x_deconsolidation_location  => l_deconsolidation_location,
                  x_return_status             => x_return_status,
                  x_msg_count                 => x_msg_count,
                  x_msg_data                  => x_msg_data);

               IF x_return_status <> 'S' THEN
                  IF g_debug = 1 THEN
                     debug ('Error from wsh_fte_comp_constraint_grp.is_valid_consol: '
                      || x_return_status, 'wms_mdc_pvt.validate_to_lpn');
                  END IF;

                  IF x_return_status = 'E' THEN
                     RAISE fnd_api.g_exc_error;
                   ELSE
                        RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
                ELSE
                  IF l_deconsolidation_location IS NOT NULL THEN
                     l_allow_packing := 'Y';
                   ELSE
                     l_allow_packing := 'N';
                  END IF;
               END IF;
            END IF;

            ELSE -- Both from and to lpns are not MDC
               IF g_debug = 1 THEN
                  debug('All LPNS are not across delivery', 'wms_mdc_pvt.validate_to_lpn');
               END IF;

               l_allow_packing := 'N';
               x_allow_packing := 'N' ;
               IF g_debug = 1 THEN
                  debug('WMS_CANNOT_COMMINGLE_ADWD : cannto comingle AD/WD material: ' ,
                        'wms_mdc_pvt.validate_to_lpn');
                     --{{Cannot comingle AD/WD material in TO LPN }}
               END IF;
               fnd_message.set_name('WMS', 'WMS_CANNOT_COMMINGLE_ADWD');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            END IF; -- Are all from LPNS AD?
         END IF; -- allow packing = 'V' , futher validations
      END IF; -- Allow packing is Y and deliveries and not same
   END IF; -- to_lpn_id is null or 0

   x_allow_packing := l_allow_packing;
   x_return_status := 'S';
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := 'E';
      IF g_debug = 1 THEN
         debug('Error', 'wms_mdc_pvt.validate_to_lpn');
      END IF;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := 'U';
      IF g_debug = 1 THEN
         debug('Unexpected Error', 'wms_mdc_pvt.validate_to_lpn');
      END IF;
   WHEN OTHERS THEN
      x_return_status := 'U';
      x_msg_data := SQLERRM;
      IF g_debug = 1 THEN
         debug('SQL error: ' || SQLERRM, 'wms_mdc_pvt.validate_to_lpn');
      END IF;

END validate_to_lpn;


END wms_mdc_pvt;

/
