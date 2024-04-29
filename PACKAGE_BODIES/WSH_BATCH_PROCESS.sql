--------------------------------------------------------
--  DDL for Package Body WSH_BATCH_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_BATCH_PROCESS" as
/* $Header: WSHBHPSB.pls 120.10.12010000.3 2009/12/03 14:12:02 anvarshn ship $ */

G_SHIP_CONFIRM CONSTANT VARCHAR2(5) := 'SC';
G_AUTO_PACK CONSTANT VARCHAR2(5) := 'AP';
g_error_message VARCHAR2(30);
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_BATCH_PROCESS';


-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Select_Deliveries
-- Purpose
--   This procedure is called by Ship_Confirm_Deliveries_SRS
--   and Auto_Pack_Deliveries_SRS to select deliveries  according
--   to users entered quiteria.
-- Input Parameters:
--   p_input_info : this record contains all the input parameters
--   p_batch_rec  : this record returns the fields for creating batch record in wsh_picking_batches table
-- Output Parameters:
--   x_selected_del_tab: returns a list of delivery ids which are selected according to the criteria
--   x_return_status  - Success, Warning, Error, Unexpected Error
-- ----------------------------------------------------------------------

PROCEDURE Select_Deliveries (
  p_input_info        IN  WSH_BATCH_PROCESS.Select_Criteria_Rec,
  p_batch_rec        IN  OUT NOCOPY WSH_PICKING_BATCHES%ROWTYPE,
  x_selected_del_tab    OUT NOCOPY  WSH_BATCH_PROCESS.Del_Info_Tab,
  x_return_status      OUT NOCOPY VARCHAR2)
IS

  l_sc_SELECT          VARCHAR2(3000) := NULL;
  l_sc_FROM          VARCHAR2(3000) := NULL;
  l_sc_WHERE          VARCHAR2(3000) := NULL;
  l_sc_EXISTS_BOL        VARCHAR2(3000) := NULL;
  l_sc_EXISTS          VARCHAR2(3000) := NULL;
  l_sc_NOT_EXISTS        VARCHAR2(3000) := NULL;
  l_sc_FINAL          VARCHAR2(4000) := NULL;
  l_sub_str          VARCHAR2(2000);
  l_str_length          NUMBER := 0;
  l_pickup_date_lo        DATE;
  l_pickup_date_hi        DATE;
  l_dropoff_date_lo      DATE;
  l_dropoff_date_hi      DATE;
  i              NUMBER := 0;
  v_delivery_id        NUMBER := 0;
  v_organization_id    NUMBER := 0;
  v_initial_pickup_location_id  NUMBER := 0;
  v_cursorID          INTEGER;
  v_ignore            INTEGER;
l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Select_Deliveries';

BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status  :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  x_selected_del_tab.delete;

  l_sc_SELECT := l_sc_SELECT || ' wnd.delivery_id , wnd.organization_id, wnd.initial_pickup_location_id ';

  l_sc_FROM   := l_sc_FROM   || 'wsh_new_deliveries  wnd ';

  IF p_input_info.process_mode = G_SHIP_CONFIRM THEN
  l_sc_WHERE  := l_sc_WHERE  || 'NVL(wnd.auto_sc_exclude_flag, ''N'') = ''N'' ';
  ELSIF p_input_info.process_mode = G_AUTO_PACK THEN
  l_sc_WHERE  := l_sc_WHERE  || 'NVL(wnd.auto_ap_exclude_flag, ''N'') = ''N'' ';
  END IF;

  l_sc_WHERE  := l_sc_WHERE  || 'AND wnd.status_code = ''OP'' ';
-- J Inbound Logistics jckwok
  l_sc_WHERE  := l_sc_WHERE  || 'AND nvl(wnd.SHIPMENT_DIRECTION , ''O'') IN (''O'', ''IO'') ';
-- end of Inbound Logistics changes

 -- R12 MDC changes. Do not select consolidation deliveries. Only standard deliveries to be included

  l_sc_WHERE  := l_sc_WHERE  || 'AND wnd.DELIVERY_TYPE = ''STANDARD'' ';

  l_sc_EXISTS := l_sc_EXISTS ||' SELECT wdd.delivery_detail_id ';
  l_sc_EXISTS := l_sc_EXISTS ||' FROM wsh_delivery_details wdd, wsh_delivery_assignments_v wda ';
  l_sc_EXISTS := l_sc_EXISTS ||' WHERE wda.delivery_detail_id = wdd.delivery_detail_id ';
  l_sc_EXISTS := l_sc_EXISTS ||' AND wda.delivery_id = wnd.delivery_id ';
  l_sc_EXISTS := l_sc_EXISTS ||' AND wda.delivery_id IS NOT NULL ';
  l_sc_EXISTS := l_sc_EXISTS ||' AND wdd.container_flag = ''N'' ';

  IF p_input_info.process_mode = G_SHIP_CONFIRM THEN
    l_sc_EXISTS := l_sc_EXISTS ||' AND wdd.released_status in (''Y'', ''X'') ';
  ELSIF p_input_info.process_mode = G_AUTO_PACK THEN
    l_sc_EXISTS := l_sc_EXISTS ||' AND wdd.released_status in (''Y'', ''X'', ''R'', ''B'') ';
  END IF;

  l_sc_NOT_EXISTS  := l_sc_NOT_EXISTS || ' SELECT wdd2.delivery_detail_id ';
  l_sc_NOT_EXISTS  := l_sc_NOT_EXISTS || ' FROM wsh_delivery_details wdd2, wsh_delivery_assignments_v  wda2 ';
  l_sc_NOT_EXISTS  := l_sc_NOT_EXISTS || ' WHERE wnd.delivery_id = wda2.delivery_id ';
  l_sc_NOT_EXISTS  := l_sc_NOT_EXISTS || ' AND wda2.delivery_id IS NOT NULL ';
  l_sc_NOT_EXISTS  := l_sc_NOT_EXISTS || ' AND wda2.delivery_detail_id = wdd2.delivery_detail_id ';
  l_sc_NOT_EXISTS  := l_sc_NOT_EXISTS || ' AND wdd2.container_flag = ''N'' ';

  IF p_input_info.organization_id IS NOT NULL THEN
  l_sc_WHERE  := l_sc_WHERE ||'AND wnd.organization_id = :x_organization_id ';
  WSH_UTIL_CORE.PrintMsg('  Organization ID: '|| p_input_info.organization_id);
  p_batch_rec.organization_id := p_input_info.organization_id;
  END IF;

  IF p_input_info.pr_batch_id IS NOT NULL THEN

    l_sc_EXISTS := l_sc_EXISTS ||'AND  wdd.batch_id = :x_pr_batch_id ';

    IF p_input_info.process_mode = G_SHIP_CONFIRM THEN
      l_sc_NOT_EXISTS := l_sc_NOT_EXISTS || ' AND (wdd2.released_status in (''R'', ''S'', ''B'', ''C'', ''N'') OR wdd2.batch_id <> :x_pr_batch_id ) ';
    ELSIF p_input_info.process_mode = G_AUTO_PACK THEN
      l_sc_NOT_EXISTS := l_sc_NOT_EXISTS || ' AND (wdd2.released_status in (''S'', ''C'' , ''N'') OR NVL(wdd2.batch_id, -999) <> :x_pr_batch_id ) ';
    END IF;

    WSH_UTIL_CORE.PrintMsg('  Pick Release Batch ID: '|| p_input_info.pr_batch_id);
    p_batch_rec.selected_batch_id := p_input_info.pr_batch_id;

  ELSE

    IF p_input_info.process_mode = G_SHIP_CONFIRM THEN
      l_sc_NOT_EXISTS := l_sc_NOT_EXISTS || ' AND wdd2.released_status in (''R'', ''S'', ''B'', ''C'', ''N'') ';
    ELSIF p_input_info.process_mode = G_AUTO_PACK THEN
      l_sc_NOT_EXISTS := l_sc_NOT_EXISTS || ' AND wdd2.released_status in (''S'', ''C'', ''N'') ';
    END IF;

  END IF;

  /*Modified R12.1.1 LSP PROJECT*/
  IF p_input_info.client_id IS NOT NULL THEN
    l_sc_WHERE  := l_sc_WHERE  || 'AND wnd.client_id = :x_client_id ';
    WSH_UTIL_CORE.PrintMsg('  Client ID: '|| p_input_info.client_id);
    p_batch_rec.client_id := p_input_info.client_id; -- Assign to OUT Parameter
  END IF;
 /*Modified R12.1.1 LSP PROJECT*/

  IF p_input_info.ap_batch_id IS NOT NULL THEN
    l_sc_WHERE  := l_sc_WHERE  || 'AND wnd.ap_batch_id = :x_ap_batch_id ';
    WSH_UTIL_CORE.PrintMsg('  Auto Pack Batch ID: '|| p_input_info.ap_batch_id);
  END IF;

  IF p_input_info.delivery_name_lo IS NOT NULL OR p_input_info.delivery_name_hi IS NOT NULL THEN
    IF p_input_info.delivery_name_lo IS NOT NULL AND p_input_info.delivery_name_hi IS NOT NULL THEN
      l_sc_WHERE  := l_sc_WHERE ||'AND wnd.name BETWEEN :x_delivery_name_lo AND :x_delivery_name_hi ';
      WSH_UTIL_CORE.PrintMsg('  Delivery Name (Low): '|| p_input_info.delivery_name_lo);
      p_batch_rec.delivery_name_lo := p_input_info.delivery_name_lo;
      WSH_UTIL_CORE.PrintMsg('  Delivery Name (High): '|| p_input_info.delivery_name_hi);
      p_batch_rec.delivery_name_hi := p_input_info.delivery_name_hi;
    ELSIF p_input_info.delivery_name_lo IS NOT NULL THEN
      l_sc_WHERE  := l_sc_WHERE ||'AND wnd.name >= :x_delivery_name_lo ';
      WSH_UTIL_CORE.PrintMsg('  Delivery Name (Low): '|| p_input_info.delivery_name_lo);
      p_batch_rec.delivery_name_lo := p_input_info.delivery_name_lo;
    ELSE
      l_sc_WHERE  := l_sc_WHERE ||'AND wnd.name <= :x_delivery_name_hi ';
      WSH_UTIL_CORE.PrintMsg('  Delivery Name (High): '|| p_input_info.delivery_name_hi);
      p_batch_rec.delivery_name_hi := p_input_info.delivery_name_hi;
    END IF;
  END IF;

  IF (p_input_info.bol_number_lo IS NOT NULL OR p_input_info.bol_number_hi IS NOT NULL) THEN
    l_sc_EXISTS_BOL := l_sc_EXISTS_BOL ||' SELECT wdi.document_instance_id ';
    l_sc_EXISTS_BOL := l_sc_EXISTS_BOL ||' FROM  wsh_delivery_legs     wlg ';
    l_sc_EXISTS_BOL := l_sc_EXISTS_BOL ||'     ,wsh_document_instances  wdi ';
    l_sc_EXISTS_BOL := l_sc_EXISTS_BOL ||' WHERE wnd.delivery_id = wlg.delivery_id ';
    l_sc_EXISTS_BOL := l_sc_EXISTS_BOL ||' AND wlg.delivery_leg_id = wdi.entity_id ';
    l_sc_EXISTS_BOL := l_sc_EXISTS_BOL ||' AND wdi.entity_name= ''WSH_DELIVERY_LEGS'' ';
    l_sc_EXISTS_BOL := l_sc_EXISTS_BOL ||' AND wdi.document_type =''BOL'' ';
    l_sc_EXISTS_BOL := l_sc_EXISTS_BOL ||' AND wdi.status <> ''CANCELED'' ';

    IF p_input_info.bol_number_lo IS NOT NULL AND p_input_info.bol_number_hi IS NOT NULL THEN
      l_sc_EXISTS_BOL := l_sc_EXISTS_BOL || 'AND wdi.sequence_number BETWEEN :x_bol_number_lo AND :x_bol_number_hi ';

      WSH_UTIL_CORE.PrintMsg('  BOL Number (Low): '|| p_input_info.bol_number_lo);
      p_batch_rec.bol_number_lo := p_input_info.bol_number_lo;

      WSH_UTIL_CORE.PrintMsg('  BOL Number (High): '|| p_input_info.bol_number_hi);
      p_batch_rec.bol_number_hi := p_input_info.bol_number_hi;

    ELSIF p_input_info.bol_number_lo IS NOT NULL THEN
      l_sc_EXISTS_BOL := l_sc_EXISTS_BOL || 'AND wdi.sequence_number >= :x_bol_number_lo ';
      WSH_UTIL_CORE.PrintMsg('  BOL Number (Low): '|| p_input_info.bol_number_lo);
      p_batch_rec.bol_number_lo := p_input_info.bol_number_lo;

    ELSE
      l_sc_EXISTS_BOL := l_sc_EXISTS_BOL || 'AND wdi.sequence_number <= :x_bol_number_hi ';
      WSH_UTIL_CORE.PrintMsg('  BOL Number (High): '|| p_input_info.bol_number_hi);
      p_batch_rec.bol_number_hi := p_input_info.bol_number_hi;
    END IF;

  END IF;


  IF p_input_info.planned_flag  IS NOT NULL THEN
    l_sc_WHERE  := l_sc_WHERE || 'AND wnd.planned_flag = :x_planned_flag ';
    WSH_UTIL_CORE.PrintMsg('  Planned Flag: '|| p_input_info.planned_flag);
    p_batch_rec.planned_flag := p_input_info.planned_flag;
  END IF;

  IF p_input_info.ship_from_loc_id IS NOT NULL THEN
    l_sc_WHERE  := l_sc_WHERE || 'AND wnd.initial_pickup_location_id = :x_ship_from_loc_id ';
    WSH_UTIL_CORE.PrintMsg('  Ship from Location ID: '|| to_char(p_input_info.ship_from_loc_id));
    p_batch_rec.ship_from_location_id := p_input_info.ship_from_loc_id;
  END IF;

  IF p_input_info.ship_to_loc_id  IS NOT NULL THEN
    l_sc_WHERE  := l_sc_WHERE || 'AND wnd.ultimate_dropoff_location_id = :x_ship_to_loc_id ';
    WSH_UTIL_CORE.PrintMsg('  Ship to Location ID: '|| to_char(p_input_info.ship_to_loc_id));
    p_batch_rec.ship_to_location_id := p_input_info.ship_to_loc_id;
  END IF;

  IF p_input_info.intmed_ship_to_loc_id  IS NOT NULL THEN
    l_sc_WHERE  := l_sc_WHERE || 'AND wnd.intmed_ship_to_location_id = :x_intmed_ship_to_loc_id ';
    WSH_UTIL_CORE.PrintMsg('  Intermediate Ship to Location ID: '|| to_char(p_input_info.intmed_ship_to_loc_id));
    p_batch_rec.intmed_ship_to_loc_id := p_input_info.intmed_ship_to_loc_id;
  END IF;

  IF p_input_info.pooled_ship_to_loc_id IS NOT NULL THEN
    l_sc_WHERE  := l_sc_WHERE || 'AND wnd.pooled_ship_to_location_id = :x_pooled_ship_to_loc_id ';
    WSH_UTIL_CORE.PrintMsg('  Pooled Ship to Location ID: '|| p_input_info.pooled_ship_to_loc_id);
    p_batch_rec.pooled_ship_to_loc_id := p_input_info.pooled_ship_to_loc_id;
  END IF;

  IF p_input_info.customer_id  IS NOT NULL THEN
    l_sc_WHERE := l_sc_WHERE || 'AND wnd.customer_id = :x_customer_id ';
    WSH_UTIL_CORE.PrintMsg('  Customer ID: '|| p_input_info.customer_id);
    p_batch_rec.customer_id := p_input_info.customer_id;
  END IF;

  IF p_input_info.ship_method_code IS NOT NULL THEN
    l_sc_WHERE := l_sc_WHERE || 'AND wnd.ship_method_code = :x_ship_method_code ';
    WSH_UTIL_CORE.PrintMsg('  Ship Method Code: '|| p_input_info.ship_method_code);
    p_batch_rec.ship_method_code := p_input_info.ship_method_code;
  END IF;

  IF p_input_info.fob_code IS NOT NULL THEN
    l_sc_WHERE := l_sc_WHERE || 'AND wnd.fob_code = :x_fob_code ';
    WSH_UTIL_CORE.PrintMsg('  FOB Code: '|| p_input_info.fob_code);
    p_batch_rec.fob_code := p_input_info.fob_code;
  END IF;

  IF p_input_info.freight_terms_code  IS NOT NULL THEN
    l_sc_WHERE := l_sc_WHERE || 'AND wnd.freight_terms_code = :x_freight_terms_code ';

    WSH_UTIL_CORE.PrintMsg('  Freight Term Code: '|| p_input_info.freight_terms_code);
    p_batch_rec.freight_terms_code := p_input_info.freight_terms_code;
  END IF;

  IF p_input_info.pickup_date_lo IS NOT NULL OR p_input_info.pickup_date_hi IS NOT NULL THEN
    IF p_input_info.pickup_date_lo IS NOT NULL AND p_input_info.pickup_date_hi IS NOT NULL THEN

      l_pickup_date_lo := fnd_date.canonical_to_date(p_input_info.pickup_date_lo);
      l_pickup_date_hi := fnd_date.canonical_to_date(p_input_info.pickup_date_hi);
      l_sc_WHERE := l_sc_WHERE || 'AND NVL(wnd.initial_pickup_date, sysdate) BETWEEN :x_pickup_date_lo AND :x_pickup_date_hi ';
      WSH_UTIL_CORE.PrintMsg('  Pick-up Date (Low): '|| to_char(l_pickup_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
      p_batch_rec.pickup_date_lo := l_pickup_date_lo;
      WSH_UTIL_CORE.PrintMsg('  Pick-up Date (High): '|| to_char(l_pickup_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
      p_batch_rec.pickup_date_hi := l_pickup_date_hi;

    ELSIF p_input_info.pickup_date_lo  IS NOT NULL THEN

      l_pickup_date_lo := fnd_date.canonical_to_date(p_input_info.pickup_date_lo);
      l_sc_WHERE := l_sc_WHERE || 'AND NVL(wnd.initial_pickup_date, sysdate) >= :x_pickup_date_lo ';
      WSH_UTIL_CORE.PrintMsg('  Pick-up Date (Low): '|| to_char(l_pickup_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
      p_batch_rec.pickup_date_lo := l_pickup_date_lo;

    ELSE

      l_pickup_date_hi := fnd_date.canonical_to_date(p_input_info.pickup_date_hi);
      l_sc_WHERE := l_sc_WHERE || 'AND NVL(wnd.initial_pickup_date, sysdate) <= :x_pickup_date_hi ';
      WSH_UTIL_CORE.PrintMsg('  Pick-up Date (High): '|| to_char(l_pickup_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
      p_batch_rec.pickup_date_hi := l_pickup_date_hi;
    END IF;
  END IF;

  IF p_input_info.dropoff_date_lo IS NOT NULL OR p_input_info.dropoff_date_hi IS NOT NULL THEN

    IF p_input_info.dropoff_date_lo IS NOT NULL AND p_input_info.dropoff_date_hi IS NOT NULL THEN
      l_dropoff_date_lo := fnd_date.canonical_to_date(p_input_info.dropoff_date_lo);
      l_dropoff_date_hi := fnd_date.canonical_to_date(p_input_info.dropoff_date_hi);
      l_sc_WHERE := l_sc_WHERE || 'AND wnd.ultimate_dropoff_date BETWEEN :x_dropoff_date_lo AND :x_dropoff_date_hi ';
      WSH_UTIL_CORE.PrintMsg('  Drop-off Date (Low): '|| to_char(l_dropoff_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
      p_batch_rec.dropoff_date_lo := l_dropoff_date_lo;
      WSH_UTIL_CORE.PrintMsg('  Drop-off Date (High): '|| to_char(l_dropoff_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
      p_batch_rec.dropoff_date_hi := l_dropoff_date_hi;

    ELSIF p_input_info.dropoff_date_lo IS NOT NULL THEN
      l_dropoff_date_lo := fnd_date.canonical_to_date(p_input_info.dropoff_date_lo);
      l_sc_WHERE := l_sc_WHERE || 'AND wnd.ultimate_dropoff_date >= :x_dropoff_date_lo ';
      WSH_UTIL_CORE.PrintMsg('  Drop-off Date (Low): '|| to_char(l_dropoff_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
      p_batch_rec.dropoff_date_lo := l_dropoff_date_lo;

    ELSE
      l_dropoff_date_hi := fnd_date.canonical_to_date(p_input_info.dropoff_date_hi);
      l_sc_WHERE := l_sc_WHERE || 'AND wnd.ultimate_dropoff_date <= :x_dropoff_date_hi ';
      WSH_UTIL_CORE.PrintMsg('  Drop-off Date (High): '|| to_char(l_dropoff_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
      p_batch_rec.dropoff_date_hi := l_dropoff_date_hi;
    END IF;
  END IF;

  WSH_UTIL_CORE.PrintMsg('  Log Level: '|| p_input_info.log_level);

  l_sc_FINAL :=  'SELECT ' ||l_sc_SELECT||' FROM '||l_sc_FROM||' WHERE '||l_sc_WHERE ;
  IF length(l_sc_EXISTS_BOL) > 0 THEN
    l_sc_FINAL :=  l_sc_FINAL ||'AND EXISTS ( '|| l_sc_EXISTS_BOL || ' ) ';
  END IF;
  l_sc_FINAL :=  l_sc_FINAL || ' AND EXISTS ( '|| l_sc_EXISTS ||' ) AND NOT EXISTS ( '|| l_sc_NOT_EXISTS||' )';

  IF p_input_info.log_level > 0 OR l_debug_on THEN
    -- print SELECT statement
    i := 1;
    l_str_length := length(l_sc_FINAL);

    LOOP
      IF i > l_str_length THEN
      EXIT;
      END IF;
      l_sub_str := SUBSTR(l_sc_FINAL, i , 80);
      -- l_sub_str := SUBSTR(l_sc_FINAL, i , WSH_UTIL_CORE.G_MAX_LENGTH);
      WSH_UTIL_CORE.PrintMsg(l_sub_str);
      i := i + 80;
      -- i := i + WSH_UTIL_CORE.G_MAX_LENGTH;
    END LOOP;
  END IF;

  v_CursorID := DBMS_SQL.Open_Cursor;

  DBMS_SQL.Parse(v_CursorID, l_sc_FINAL, DBMS_SQL.v7 );

  DBMS_SQL.Define_Column(v_CursorID, 1,  v_delivery_id);
  DBMS_SQL.Define_Column(v_CursorID, 2,  v_organization_id);
  DBMS_SQL.Define_Column(v_CursorID, 3,  v_initial_pickup_location_id);

  /* Modified R12.1.1 LSP PROJECT*/
  IF p_input_info.client_id IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_client_id', p_input_info.client_id);   --Modified R12.1.1 LSP PROJECT
  END IF;
  /* Modified R12.1.1 LSP PROJECT*/

  IF p_input_info.organization_id IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_organization_id', p_input_info.organization_id);
  END IF;

  IF p_input_info.pr_batch_id IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_pr_batch_id', p_input_info.pr_batch_id);
  END IF;

  IF p_input_info.ap_batch_id IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_ap_batch_id', p_input_info.ap_batch_id);
  END IF;

  IF p_input_info.delivery_name_lo IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_delivery_name_lo', p_input_info.delivery_name_lo);
  END IF;

  IF p_input_info.delivery_name_hi IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_delivery_name_hi', p_input_info.delivery_name_hi);
  END IF;


  IF p_input_info.bol_number_lo IS NOT NULL  THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_bol_number_lo', p_input_info.bol_number_lo) ;
  END IF;

  IF p_input_info.bol_number_hi IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_bol_number_hi', p_input_info.bol_number_hi);
  END IF;


  IF p_input_info.planned_flag  IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_planned_flag', p_input_info.planned_flag);
  END IF;

  IF p_input_info.ship_from_loc_id IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_ship_from_loc_id', p_input_info.ship_from_loc_id);
  END IF;

  IF p_input_info.ship_to_loc_id  IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_ship_to_loc_id', p_input_info.ship_to_loc_id);
  END IF;

  IF p_input_info.intmed_ship_to_loc_id  IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_intmed_ship_to_loc_id', p_input_info.intmed_ship_to_loc_id);
  END IF;

  IF p_input_info.pooled_ship_to_loc_id IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_pooled_ship_to_loc_id', p_input_info.pooled_ship_to_loc_id);
  END IF;

  IF p_input_info.customer_id  IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_customer_id', p_input_info.customer_id);
  END IF;

  IF p_input_info.ship_method_code IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_ship_method_code', p_input_info.ship_method_code);
  END IF;

  IF p_input_info.fob_code IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_fob_code', p_input_info.fob_code);
  END IF;

  IF p_input_info.freight_terms_code  IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_freight_terms_code', p_input_info.freight_terms_code);
  END IF;

  IF p_input_info.pickup_date_lo  IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_pickup_date_lo', l_pickup_date_lo);
  END IF;

  IF p_input_info.pickup_date_hi IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_pickup_date_hi', l_pickup_date_hi);
  END IF;

  IF p_input_info.dropoff_date_lo IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_dropoff_date_lo', l_dropoff_date_lo);
  END IF;

  IF p_input_info.dropoff_date_hi IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_dropoff_date_hi', l_dropoff_date_hi);
  END IF;

  v_ignore := DBMS_SQL.Execute(v_CursorID);

  LOOP
    IF DBMS_SQL.Fetch_Rows(v_cursorID) = 0 THEN
      DBMS_SQL.Close_Cursor(v_cursorID);
      EXIT;
    ELSE
      DBMS_SQL.Column_Value(v_CursorID, 1,  v_delivery_id);
      DBMS_SQL.Column_Value(v_CursorID, 2,  v_organization_id);
      DBMS_SQL.Column_Value(v_CursorID, 3,  v_initial_pickup_location_id);
      x_selected_del_tab(x_selected_del_tab.count+1).delivery_id := v_delivery_id;
      x_selected_del_tab(x_selected_del_tab.count).organization_id := v_organization_id;
      x_selected_del_tab(x_selected_del_tab.count).initial_pickup_location_id := v_initial_pickup_location_id;

    END IF;
  END LOOP;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, to_char(x_selected_del_tab.count)||' deliveries fetched to be processed');
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

  WHEN others THEN

    wsh_util_core.default_handler('WSH_BATCH_PROCESS.Select_Deliveries');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

END Select_Deliveries;



-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Ship_Confirm_A_Delivery
--
-- Purpose:
--   This PRIVATE procedure ship confirm a delivery, it is called by
--   Ship_Confirm_Batch in a loop.
--   It is necessary to make a saperate procedure, othewise it fails to
--   catch the exception when a delivery cannot be locked within a loop and
--   it will exit all the way out of the delivery loop so no deliveries can be
--   ship confirmed after the exception
--
-- Input Parameters:
--   p_delivery_id - the delivery id to be ship cofirmed
--   p_sc_batch_id - Ship Confirm Batch ID, needed to stamp the delivery
--   p_ship_confirm_rule_rec - the ship confirm options
--   p_log_level   - log level for printing debug messages
--   p_actual_departure_date - Actual Departure Date on stop
--
-- Output Parameters:
--   x_organization_id - the organization id of the delivery
--   x_return_status  - Success, Warning, Error, Unexpected Error
-- ----------------------------------------------------------------------

PROCEDURE Ship_Confirm_A_Delivery(
  p_delivery_id            IN   NUMBER,
  p_sc_batch_id            IN   NUMBER,
  p_ship_confirm_rule_rec  IN   G_GET_SHIP_CONFIRM_RULE%ROWTYPE,
  p_log_level              IN   NUMBER,
  p_actual_departure_date  IN   DATE,
  x_return_status     OUT  NOCOPY VARCHAR2) IS


 CURSOR get_delivery( c_delivery_id NUMBER ) IS
  SELECT delivery_id,
         status_code,
         planned_flag,
         initial_pickup_date,
         organization_id,
         ship_method_code,
         initial_pickup_location_id
  FROM wsh_new_deliveries
  WHERE delivery_id = c_delivery_id and
    status_code = 'OP' AND
    NVL(auto_sc_exclude_flag, 'N')= 'N' FOR UPDATE NOWAIT;


  -- bug 4302048: respect rule's ship method defaulting
  CURSOR c_first_trip_ship_method (x_delivery_id    IN NUMBER,
                                   x_initial_loc_id IN NUMBER)IS
  SELECT  wt.ship_method_code
  FROM    wsh_delivery_legs dlg,
          wsh_trip_stops    st,
          wsh_trips         wt
  WHERE   dlg.delivery_id        = x_delivery_id
  AND     st.stop_id             = dlg.pick_up_stop_id
  AND     st.stop_location_id    = x_initial_loc_id
  AND     st.trip_id             = wt.trip_id
  AND     wt.ship_method_code IS NOT NULL
  AND     rownum = 1;

 l_ship_method_code WSH_NEW_DELIVERIES.SHIP_METHOD_CODE%TYPE;

 l_delivery_rec     get_delivery%ROWTYPE;
 l_tmp_del_tab      WSH_UTIL_CORE.Id_Tab_Type;
 l_err_entity_ids   WSH_UTIL_CORE.Id_Tab_Type;
 l_return_status    VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 l_actual_dep_date  DATE ;
 l_action_prms      WSH_DELIVERIES_GRP.action_parameters_rectype;
 l_rec_attr_tab     WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
 l_delivery_out_rec WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;
 l_defaults_rec     WSH_DELIVERIES_GRP.default_parameters_rectype;
 l_msg_count        NUMBER;
 l_msg_data         VARCHAR2(4000);
 l_debug_on BOOLEAN;
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Ship_Confirm_A_Delivery';
 delivery_locked    EXCEPTION;

 PRAGMA EXCEPTION_INIT(delivery_locked, -00054);

BEGIN

    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    l_tmp_del_tab.delete;
    l_tmp_del_tab(1) := p_delivery_id;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Locking delivery '|| p_delivery_id);
    END IF;

    OPEN get_delivery(p_delivery_id);
    FETCH get_delivery INTO l_delivery_rec;
    IF get_delivery%FOUND THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Check if ship confirm is allowed for delivery ID: ' || to_char(l_tmp_del_tab(1)));
      END IF;

        UPDATE WSH_NEW_DELIVERIES SET BATCH_ID = p_sc_batch_id
        WHERE delivery_id = p_delivery_id;

        SAVEPOINT beginning_of_loop;

        fnd_msg_pub.initialize;  -- clear messages
        --
        IF p_actual_departure_date IS NOT NULL THEN
         l_actual_dep_date := p_actual_departure_date;
        ELSE
         l_actual_dep_date := SYSDATE;
        END IF;
        --
        l_rec_attr_tab(1).delivery_id       := l_delivery_rec.delivery_id;
        l_rec_attr_tab(1).status_code       := l_delivery_rec.status_code;
        l_rec_attr_tab(1).planned_flag      := l_delivery_rec.planned_flag;
        l_rec_attr_tab(1).organization_id   := l_delivery_rec.organization_id;
        l_rec_attr_tab(1).ship_method_code  := l_delivery_rec.ship_method_code;

        l_action_prms.action_code           := 'CONFIRM';
        l_action_prms.caller                := 'WSH_BHPS';
        l_action_prms.phase                 := NULL;
        l_action_prms.action_flag           := p_ship_confirm_rule_rec.action_flag;
        -- 3667595, do not close stops when ship confirm deliveries
        l_action_prms.intransit_flag        := 'N';
        l_action_prms.close_trip_flag       := 'N';
        l_action_prms.stage_del_flag        := p_ship_confirm_rule_rec.stage_del_flag;
        l_action_prms.report_set_id         := p_ship_confirm_rule_rec.report_set_id;
        l_action_prms.bill_of_lading_flag   := p_ship_confirm_rule_rec.ac_bol_flag;
        l_action_prms.mc_bill_of_lading_flag := p_ship_confirm_rule_rec.mc_bol_flag;
        l_action_prms.defer_interface_flag  := 'Y';

        -- bug 4302048: respect the rule's ship method default flag.
        IF p_ship_confirm_rule_rec.ship_method_default_flag = 'R' THEN
          l_action_prms.ship_method_code      := p_ship_confirm_rule_rec.ship_method_code;
        ELSE
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'deriving trip/delivery SM');
          END IF;
          OPEN c_first_trip_ship_method(
                          l_delivery_rec.delivery_id,
                          l_delivery_rec.initial_pickup_location_id);
          FETCH c_first_trip_ship_method INTO l_ship_method_code;
          IF c_first_trip_ship_method%NOTFOUND THEN
             l_ship_method_code := l_delivery_rec.ship_method_code;
          END IF;
          CLOSE c_first_trip_ship_method;
          l_action_prms.ship_method_code    := l_ship_method_code;
        END IF;
        l_action_prms.actual_dep_date       := l_actual_dep_date;
        l_action_prms.send_945_flag         := p_ship_confirm_rule_rec.send_945_flag;

        IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_action_prms.action_code: ',l_action_prms.action_code);
              WSH_DEBUG_SV.log(l_module_name,'l_action_prms.caller:',l_action_prms.caller);
              WSH_DEBUG_SV.log(l_module_name,'l_action_prms.phase: ',l_action_prms.phase);
              WSH_DEBUG_SV.log(l_module_name,'l_action_prms.action_flag: ',l_action_prms.action_flag);
              WSH_DEBUG_SV.log(l_module_name,'l_action_prms.intransit_flag: ',l_action_prms.intransit_flag);
              WSH_DEBUG_SV.log(l_module_name,'l_action_prms.close_trip_flag: ',l_action_prms.close_trip_flag);
              WSH_DEBUG_SV.log(l_module_name,'l_action_prms.stage_del_flag: ',l_action_prms.stage_del_flag);
              WSH_DEBUG_SV.log(l_module_name,'l_action_prms.report_set_id: ',l_action_prms.report_set_id);
              WSH_DEBUG_SV.log(l_module_name,'l_action_prms.bill_of_lading_flag: ',l_action_prms.bill_of_lading_flag);
              WSH_DEBUG_SV.log(l_module_name,'l_action_prms.mc_bill_of_lading_flag: ',l_action_prms.mc_bill_of_lading_flag);
              WSH_DEBUG_SV.log(l_module_name,'l_action_prms.defer_interface_flag: ',l_action_prms.defer_interface_flag);
              WSH_DEBUG_SV.log(l_module_name,'l_action_prms.ship_method_code: ',l_action_prms.ship_method_code);
              WSH_DEBUG_SV.log(l_module_name,'l_action_prms.actual_dep_date: ',l_action_prms.actual_dep_date);
              WSH_DEBUG_SV.log(l_module_name,'l_action_prms.send_945_flag: ',l_action_prms.send_945_flag);
        END IF;

        WSH_DELIVERIES_GRP.Delivery_Action
          ( p_api_version_number => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_commit             => FND_API.G_FALSE,
            p_action_prms        => l_action_prms,
            p_rec_attr_tab       => l_rec_attr_tab,
            x_delivery_out_rec   => l_delivery_out_rec,
            x_defaults_rec       => l_defaults_rec,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data
          );


        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
           l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           /* error or unexpected error */
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           ROLLBACK TO beginning_of_loop;
        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        END IF;


    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.PrintMsg('Delivery '|| p_delivery_id||' not found or cannot be locked');
      /* cannot lock the delivery */
    END IF; -- if delivery exist

    CLOSE get_delivery;  /* unlock the delivery */
    IF l_debug_on THEN
       WSH_DEBUG_SV.POP(l_module_name);
    END IF;

    EXCEPTION


      WHEN delivery_locked THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF get_delivery%ISOPEN THEN
          CLOSE get_delivery;
        END IF;
        IF c_first_trip_ship_method%ISOPEN THEN
          CLOSE c_first_trip_ship_method;
        END IF;
        WSH_UTIL_CORE.PrintMsg('ERROR: Failed to lock delivery ID '||to_char(p_delivery_id));
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'ERROR: Failed to lock delivery ID '||to_char(p_delivery_id));
          WSH_DEBUG_SV.POP(l_module_name);
        END IF;

      WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF get_delivery%ISOPEN THEN
          CLOSE get_delivery;
        END IF;
        IF c_first_trip_ship_method%ISOPEN THEN
          CLOSE c_first_trip_ship_method;
        END IF;
        WSH_UTIL_CORE.PrintMsg('ERROR: unhandled exception');
        wsh_util_core.default_handler('WSH_BATCH_PROCESS.Ship_Confirm_A_Delivery');
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: unhandled exception');
          WSH_DEBUG_SV.POP(l_module_name);
        END IF;

     END Ship_Confirm_A_Delivery;


-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Close_A_Stop
--
-- Purpose:
--   This PRIVATE procedure closes a stop, it is called by
--   Ship_Confirm_Batch in a loop.
--   It is necessary to make a saperate procedure, othewise it fails to
--   catch the exception when a stop cannot be locked within a loop and
--   it will exit all the way out of the stop loop so no stop can be
--   closed after the exception
--
-- Input Parameters:
--   p_stop_id - the stop id to be closed
--   p_actual_date - the actual departure date for the stop
--   p_defer_interface_flag - indicate whether to defer interface
--
-- Output Parameters:
--   x_return_status  - Success, Warning, Error, Unexpected Error
-- ----------------------------------------------------------------------

PROCEDURE Close_A_Stop (
           p_stop_id    IN NUMBER,
           p_actual_date  IN DATE,
           p_defer_interface_flag IN VARCHAR2,
           x_return_status OUT NOCOPY VARCHAR2) IS

Cursor lock_stop_trip (c_stop_id NUMBER) IS
   SELECT a.stop_id self_stop_id, b.trip_id, c.stop_id other_stop_id
   FROM wsh_trip_stops a, wsh_trips b, wsh_trip_stops c
   WHERE a.trip_id = b.trip_id AND
         a.stop_id = c_stop_id AND
         c.trip_id = b.trip_id AND
         a.stop_id <> C.stop_id
   FOR UPDATE NOWAIT;

l_stops_to_close WSH_UTIL_CORE.Id_Tab_Type;
l_self_stop_id  NUMBER;
l_other_stop_id NUMBER;
l_trip_id  NUMBER;
l_return_status  VARCHAR2(1);
l_action_prms    WSH_TRIP_STOPS_GRP.action_parameters_rectype;
l_rec_attr_tab   WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;
l_stop_out_rec   WSH_TRIP_STOPS_GRP.stopActionOutRecType;
l_def_rec        WSH_TRIP_STOPS_GRP.default_parameters_rectype;
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Close_A_Stop';

stop_trip_locked EXCEPTION;
PRAGMA EXCEPTION_INIT(stop_trip_locked, -00054);

BEGIN

  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name, 'Locking stop '|| to_char(p_stop_id));
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  OPEN lock_stop_trip(p_stop_id);
  FETCH lock_stop_trip INTO l_self_stop_id, l_trip_id , l_other_stop_id;
  IF lock_stop_trip%FOUND THEN

    SAVEPOINT beginning_of_the_procedure;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Stop locked, calling WSH_TRIP_STOPS_GRP.Stop_Action for stop '|| to_char(p_stop_id));
    END IF;

    l_action_prms.action_code  := 'UPDATE-STATUS';
    l_action_prms.stop_action  := 'CLOSE';
    l_action_prms.actual_date  := p_actual_date;
    l_action_prms.defer_interface_flag := 'Y';

    l_action_prms.caller                := 'WSH_BHPS';
    l_action_prms.phase                 := NULL;

    l_rec_attr_tab(1).stop_id := p_stop_id;


    WSH_TRIP_STOPS_GRP.Stop_Action
      ( p_api_version_number     => 1.0,
        p_init_msg_list          => FND_API.G_FALSE,
        p_commit                 => FND_API.G_FALSE,
        p_action_prms            => l_action_prms,
        p_rec_attr_tab           => l_rec_attr_tab,
        x_stop_out_rec           => l_stop_out_rec,
        x_def_rec                => l_def_rec,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data);
    x_return_status := l_return_status;

    CLOSE lock_stop_trip;
    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
       x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN

       ROLLBACK TO beginning_of_the_procedure;
    END IF;
 ELSE
    CLOSE lock_stop_trip;

 END IF;


 IF l_debug_on THEN
  WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
      WHEN stop_trip_locked THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        CLOSE lock_stop_trip ;
        WSH_UTIL_CORE.PrintMsg('ERROR: Failed to lock stop and trip, stop ID '||to_char(p_stop_id));
        FND_MESSAGE.SET_NAME('WSH', 'WSH_STOP_LOCK_FAILED');
        FND_MESSAGE.SET_TOKEN('ENTITY_NAME',to_char(p_stop_id));
        wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'ERROR: Failed to lock stop and trip, stop ID '||to_char(p_stop_id));
          WSH_DEBUG_SV.POP(l_module_name);
        END IF;

      WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        CLOSE lock_stop_trip;
        WSH_UTIL_CORE.PrintMsg('ERROR: Failed to lock stop and trip, stop ID '||to_char(p_stop_id));
        FND_MESSAGE.SET_NAME('WSH', 'WSH_STOP_LOCK_FAILED');
        FND_MESSAGE.SET_TOKEN('ENTITY_NAME',to_char(p_stop_id));
        wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'ERROR: Failed to lock stop and trip, stop ID '||to_char(p_stop_id));
          WSH_DEBUG_SV.POP(l_module_name);
        END IF;
END Close_A_Stop;

-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Ship_Confirm_Batch
--
-- Purpose
--   This procedure takes a list of delivery IDs and ship confirm these
--   deliveries in batch fashion. It calls confirm_delivery once for one
--   delivery at a time. If the ship confirm operation is successful,
--   it commits the change, otherwise it rollback the change and proceed
--   to next delivery. If a delivery cannot be ship confirmed,
--   it does not prevent next delivery to be ship confirmed.
--   This procedure is called from Automated Ship Confirm SRS or by
--   Pick Release SRS.
--
-- Input Parameters:
--   p_del_tab   - list of delivery IDs to be ship confimed
--   p_sc_batch_id - Ship Confirm Batch ID
--   p_log_level   - log level for printing debug messages
--
-- Output Parameters:
--   x_return_status  - Success, Warning, Error, Unexpected Error
-- ----------------------------------------------------------------------

PROCEDURE Ship_Confirm_Batch(
  p_del_tab         IN   WSH_BATCH_PROCESS.Del_Info_Tab,
  p_sc_batch_id       IN   NUMBER,
  p_log_level       IN   NUMBER,
  x_confirmed_del_tab   OUT  NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
  x_results_summary     OUT  NOCOPY WSH_BATCH_PROCESS.Results_Summary_Rec,
  x_return_status     OUT  NOCOPY VARCHAR2,
  p_commit               IN   VARCHAR2) IS -- BugFix #4001135

l_batch_creation_date   DATE := NULL;

CURSOR get_sc_batch IS
  SELECT ship_confirm_rule_id, creation_date, actual_departure_date
  FROM   wsh_picking_batches
  WHERE  batch_id = p_sc_batch_id FOR UPDATE NOWAIT;

-- 3667595
CURSOR get_pick_up_stops   IS
  SELECT DISTINCT wtp.trip_id, wst.stop_sequence_number, wst.stop_id, wst.stop_location_id
  FROM wsh_new_deliveries wnd,
     wsh_delivery_legs  wlg,
     wsh_trip_stops  wst,
     wsh_trips      wtp
  WHERE  wnd.delivery_id = wlg.delivery_id AND
     wlg.pick_up_stop_id = wst.stop_id AND
     wnd.status_code = 'CO' AND
     wnd.batch_id = p_sc_batch_id AND
     wtp.trip_id = wst.trip_id AND
     wst.status_code = 'OP' AND
     NOT EXISTS (
     select '1' from wsh_exceptions we where
     we.delivery_id = wnd.delivery_id AND
     we.severity = 'ERROR' AND
     we.status = 'OPEN' AND
     we.EXCEPTION_NAME = 'WSH_SC_REQ_EXPORT_COMPL')


  ORDER BY wtp.trip_id, wst.stop_sequence_number, wst.stop_id ;

--Modified the following SQL as part of bug 4280371 ( 30-Jun-2005 ).
CURSOR get_all_stops   IS
select wsto.trip_id, wsto.stop_sequence_number, wsto.stop_id , wsto.stop_location_id
  from wsh_trip_stops     wsto
     , wsh_new_deliveries wnd
     , wsh_delivery_legs  wlg
     , wsh_trip_stops     wst
 where wnd.batch_id    = p_sc_batch_id
   and wnd.status_code = 'CO'
   and wnd.delivery_id = wlg.delivery_id
   and wlg.pick_up_stop_id = wst.stop_id
   and wnd.INITIAL_PICKUP_LOCATION_ID = wst.STOP_LOCATION_ID
   and wst.status_code in ( 'OP' , 'AR' )
   and NOT EXISTS (
        select '1' from wsh_exceptions we
         where we.delivery_id = wnd.delivery_id
           AND we.severity = 'ERROR'
           AND we.status = 'OPEN'
           AND we.EXCEPTION_NAME = 'WSH_SC_REQ_EXPORT_COMPL')
   and wsto.trip_id  = wst.trip_id
  ORDER BY 1, 2, 3;


-- added cursor to check if interface is necessary
-- 3667595
CURSOR c_batch_stop(p_batch_id NUMBER)IS
   SELECT wts.stop_id
   FROM   wsh_trip_stops    wts,
         wsh_delivery_legs  wdl,
         wsh_new_deliveries wnd,
         wsh_picking_batches wpb
   WHERE p_batch_id IS NOT NULL
   AND   wnd.batch_id    = p_batch_id
   AND   wdl.delivery_id     = wnd.delivery_id
   AND   wts.stop_id      = wdl.pick_up_stop_id
   AND   wts.stop_location_id = wnd.initial_pickup_location_id
   AND   wpb.batch_id = wnd.batch_id
   AND   wts.status_code = 'CL'
   AND   rownum = 1;



l_ship_confirm_rule_rec   G_GET_SHIP_CONFIRM_RULE%ROWTYPE;
l_sc_confirmed_dels     wsh_util_core.id_tab_type;
l_return_status      VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_ship_confirm_rule_id  NUMBER := 0;
l_trip_id        NUMBER := NULL;
l_stop_id        NUMBER := NULL;
l_stop_sequence_number  NUMBER := NULL;
l_stop_location_id      NUMBER := NULL;
l_stops_to_close      WSH_UTIL_CORE.Id_Tab_Type;
l_stop_location_ids   WSH_UTIL_CORE.Id_Tab_Type;
l_request_id        NUMBER := 0;
l_num_warn        NUMBER := 0;
l_num_error        NUMBER := 0;
l_actual_dep_date    DATE := NULL;
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Ship_Confirm_Batch';

l_status_code  VARCHAR2(30);
l_lock_error         VARCHAR2(1) := 'N';
l_closing_stop_success    NUMBER := 0;
l_closing_stop_warning    NUMBEr := 0;
l_closing_stop_failure    NUMBER := 0;
l_interface_stop_id          NUMBER := 0;

wsh_missing_sc_rule    EXCEPTION;
wsh_submit_sc_report_err  EXCEPTION;
delivery_locked      EXCEPTION;
wsh_missing_sc_batch    EXCEPTION;
inv_inter_req_submission  EXCEPTION;

PRAGMA EXCEPTION_INIT(delivery_locked, -00054);
 --
 --Bugfix 4070732
 l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
 l_reset_flags BOOLEAN;
 l_return_status1 VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 --
 l_actual_departure_date DATE;
 --
BEGIN

  -- reset out parameters
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  x_results_summary.success := 0;
  x_results_summary.warning := 0;
  x_results_summary.failure := 0;
  x_results_summary.report_req_id := 0;
  x_return_status  :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  l_sc_confirmed_dels.delete;
  l_stops_to_close.delete;
  l_stop_location_ids.delete;

  WSH_UTIL_CORE.PrintDateTime;

  -- lock ship confirm batch
  OPEN get_sc_batch ;
  FETCH get_sc_batch INTO l_ship_confirm_rule_id, l_batch_creation_date,
                          l_actual_departure_date;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'Batch Creation Date',
                     to_char(l_batch_creation_date, 'MM-DD-YYYY HH24:MI:SS'));
    WSH_DEBUG_SV.log(l_module_name, 'Actual Departure Date',
                     to_char(l_actual_departure_date, 'MM/DD/YYYY HH24:MI:SS'));
  END IF;

  IF get_sc_batch%NOTFOUND THEN
  CLOSE get_sc_batch;
  raise wsh_missing_sc_batch;
  END IF;

  IF l_ship_confirm_rule_id IS NULL THEN
  raise wsh_missing_sc_rule;
  END IF;

  OPEN G_GET_SHIP_CONFIRM_RULE(l_ship_confirm_rule_id);
  FETCH G_GET_SHIP_CONFIRM_RULE INTO l_ship_confirm_rule_rec;

  IF G_GET_SHIP_CONFIRM_RULE%NOTFOUND THEN
  CLOSE G_GET_SHIP_CONFIRM_RULE;
  raise wsh_missing_sc_rule;
  END IF;


  FOR i in 1 .. p_del_tab.count LOOP
    BEGIN

        Ship_Confirm_A_Delivery(
          p_delivery_id            => p_del_tab(i).delivery_id,
          p_sc_batch_id            => p_sc_batch_id,
          p_ship_confirm_rule_rec  => l_ship_confirm_rule_rec,
          p_log_level              => p_log_level,
          p_actual_departure_date  => l_actual_departure_date,
          x_return_status          => l_return_status);

      EXCEPTION

        WHEN delivery_locked THEN
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          WSH_UTIL_CORE.PrintMsg('ERROR2: Failed to lock delivery ID '||to_char(p_del_tab(i).delivery_id));
          FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVY_LOCK_FAILED');
          FND_MESSAGE.SET_TOKEN('ENTITY_NAME',to_char(p_del_tab(i).delivery_id));
          wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
          log_batch_messages(p_sc_batch_id, NULL ,NULL, p_del_tab(i).initial_pickup_location_id, NULL);
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg('wsh.plsql.' || G_PKG_NAME || '.' || 'Ship_Confirm_A_Delivery', 'ERROR: Failed to lock delivery ID '||to_char(p_del_tab(i).delivery_id));
            WSH_DEBUG_SV.POP('wsh.plsql.' || G_PKG_NAME || '.' || 'Ship_Confirm_A_Delivery');
          END IF;

        WHEN OTHERS THEN
           /* this will catch the exception when failing to obtain the lock on the delivery */
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          WSH_UTIL_CORE.PrintMsg('ERROR3: Failed to lock delivery ID '||to_char(p_del_tab(i).delivery_id));
          FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVY_LOCK_FAILED');
          FND_MESSAGE.SET_TOKEN('ENTITY_NAME',to_char(p_del_tab(i).delivery_id));
          wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg('wsh.plsql.' || G_PKG_NAME || '.' || 'Ship_Confirm_A_Delivery', 'ERROR: Failed to lock delivery ID '||to_char(p_del_tab(i).delivery_id));
            WSH_DEBUG_SV.POP('wsh.plsql.' || G_PKG_NAME || '.' || 'Ship_Confirm_A_Delivery');
          END IF;
    END;

    --
    --bug 4070732
    IF (l_return_status in (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING)
        AND p_commit = FND_API.G_TRUE ) THEN
    --{
        IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
        --{

            l_reset_flags := FALSE;

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            BEGIN

               WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
                                                           x_return_status => l_return_status1);
               IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_return_status1',l_return_status1);
               END IF;

               IF l_return_status1 IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                       WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                       WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                  l_return_status := l_return_status1;
               END IF;
            EXCEPTION
            WHEN others THEN
              l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            END;

        --}
        END IF;
    --}
    END IF;
    --bug 4070732
    --
    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      x_results_summary.success := x_results_summary.success + 1;
      l_sc_confirmed_dels(l_sc_confirmed_dels.count+1):= p_del_tab(i).delivery_id;
      IF l_debug_on THEN
        select status_code into l_status_code from wsh_new_deliveries where delivery_id = p_del_tab(i).delivery_id;
        WSH_DEBUG_SV.logmsg(l_module_name,'Delivery ID ' || to_char(p_del_tab(i).delivery_id)||' is ship confirmed successfully with status '|| l_status_code);
      END IF;


    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING   THEN
      x_results_summary.warning := x_results_summary.warning + 1;
      l_sc_confirmed_dels(l_sc_confirmed_dels.count+1):= p_del_tab(i).delivery_id;
      log_batch_messages(p_sc_batch_id, p_del_tab(i).delivery_id, NULL, p_del_tab(i).initial_pickup_location_id, NULL);
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Delivery ID '|| to_char(p_del_tab(i).delivery_id)||' is ship confirmed with warnings');
      END IF;

    ELSE
      x_results_summary.failure := x_results_summary.failure + 1;

      log_batch_messages(p_sc_batch_id, p_del_tab(i).delivery_id,NULL, p_del_tab(i).initial_pickup_location_id, NULL);

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Delivery ID '|| to_char(p_del_tab(i).delivery_id)||' cannot be ship confirmed');
      END IF;


    END IF;

    -- Following if condition is added for Bugfix #4001135
    -- We will commit the data only when this api is called from Concurrent Request.
    IF ( P_COMMIT = FND_API.G_TRUE ) THEN
      COMMIT;
    END IF;

  END LOOP;

  x_confirmed_del_tab := l_sc_confirmed_dels;


  -- Close the manually created Trip-Stops
  -- 3667595
  IF l_ship_confirm_rule_rec.ac_close_trip_flag = 'Y' THEN
    OPEN get_all_stops;

    LOOP

      FETCH get_all_stops into l_trip_id, l_stop_sequence_number, l_stop_id, l_stop_location_id ;
      EXIT WHEN get_all_stops%NOTFOUND;
      l_stops_to_close(l_stops_to_close.count+1) := l_stop_id;
      l_stop_location_ids(l_stop_location_ids.count+1) := l_stop_location_id;

    END LOOP;
    CLOSE get_all_stops;

  -- 3667595
  ELSIF l_ship_confirm_rule_rec.ac_intransit_flag = 'Y' THEN
    OPEN get_pick_up_stops ;
    LOOP

      FETCH get_pick_up_stops into l_trip_id, l_stop_sequence_number, l_stop_id, l_stop_location_id;
      EXIT WHEN get_pick_up_stops%NOTFOUND;
      l_stops_to_close(l_stops_to_close.count+1) := l_stop_id;
      l_stop_location_ids(l_stop_location_ids.count+1) := l_stop_location_id;

    END LOOP;
    CLOSE get_pick_up_stops;

  END IF;

  IF l_stops_to_close.count > 0 THEN
    IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name, 'Closing manually created stops');
    END IF;
    FOR i in 1..l_stops_to_close.count LOOP
      BEGIN
        l_lock_error := 'N';

        Close_A_Stop(
           p_stop_id => l_stops_to_close(i),
           p_actual_date => NVL(l_actual_departure_date,SYSDATE),
           p_defer_interface_flag => 'Y',
           x_return_status => l_return_status);

      EXCEPTION
      WHEN others THEN
        /* this will catch the exeption when stop and trip cannot be locked */
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        l_lock_error := 'Y';

        WSH_UTIL_CORE.PrintMsg('ERROR: Failed to lock stop and trip, stop ID '||to_char(l_stops_to_close(i)));
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg('wsh.plsql.' || G_PKG_NAME || '.' || 'Close_A_Stop', 'ERROR: Failed to lock stop and trip, stop ID '||to_char(l_stops_to_close(i)));
          WSH_DEBUG_SV.POP('wsh.plsql.' || G_PKG_NAME || '.' || 'Close_A_Stop');
        END IF;
      END;

      --
      --bug 4070732
      IF (l_return_status in (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING)
          AND p_commit = FND_API.G_TRUE ) THEN
      --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          --{

              l_reset_flags := FALSE;

              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              BEGIN

                 WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
                                                             x_return_status => l_return_status1);
                 IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_return_status1',l_return_status1);
                 END IF;

                 IF l_return_status1 IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                       WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                         WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                    l_return_status := l_return_status1;
                 END IF;
              EXCEPTION
              WHEN others THEN
                l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              END;

          --}
          END IF;
      --}
      END IF;
      --bug 4070732

      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Successfully closed stop '|| l_stops_to_close(i));
        END IF;
        l_closing_stop_success := l_closing_stop_success + 1;
      ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Trip stop '|| l_stops_to_close(i) ||' is closed with warnings');
        END IF;
        l_closing_stop_warning := l_closing_stop_warning + 1;
        log_batch_messages(p_sc_batch_id, NULL , l_stops_to_close(i) , l_stop_location_ids(i), NULL);
      ELSE
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Failed to close stop '|| l_stops_to_close(i));
        END IF;

        IF l_lock_error = 'Y' THEN
          FND_MESSAGE.SET_NAME('WSH', 'WSH_STOP_LOCK_FAILED');
          FND_MESSAGE.SET_TOKEN('ENTITY_NAME',to_char(l_stops_to_close(i)));
          wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
        END IF;
        l_closing_stop_failure := l_closing_stop_failure + 1;
        log_batch_messages(p_sc_batch_id, NULL , l_stops_to_close(i) , l_stop_location_ids(i), NULL);
      END IF;

    -- Following if condition is added for Bugfix #4001135
    -- We will commit the data only when this api is called from Concurrent Request.
    IF ( P_COMMIT = FND_API.G_TRUE ) THEN
      COMMIT;
    END IF;

    END LOOP;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Successfully closed '|| l_closing_stop_success ||' stops' );
      WSH_DEBUG_SV.logmsg(l_module_name,'Closed '|| l_closing_stop_warning ||' stops with warnings' );
      WSH_DEBUG_SV.logmsg(l_module_name,'Failed to close '|| l_closing_stop_failure ||' stops' );
    END IF;

  ELSE
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'No manually created stops to close');
    END IF;
  END IF;

  IF l_ship_confirm_rule_rec.ac_defer_interface_flag = 'N' THEN
    l_interface_stop_id := 0;
    -- added cursor to check if interface is necessary
    open c_batch_stop ( p_sc_batch_id);
    fetch c_batch_stop into l_interface_stop_id;
    close c_batch_stop;
    IF l_interface_stop_id <> 0 THEN

      l_request_id := FND_REQUEST.submit_Request('WSH', 'WSHINTERFACE', '', '', FALSE,
	  'ALL', '', '', 0, p_sc_batch_id);
      IF  (l_request_id = 0) THEN
	 raise inv_inter_req_submission;
      ELSE
	 WSH_UTIL_CORE.PrintMsg('Interface request submitted for closed stops, request ID: '
	 || to_char(l_request_id) );
      END IF;

    END IF;
  END IF;



  CLOSE G_GET_SHIP_CONFIRM_RULE;
  CLOSE get_sc_batch;


  -- submit Auto Ship Confirm Deliveries Reprot here
  x_results_summary.report_req_id := fnd_request.submit_request(
       'WSH',
       'WSHRDASC','Auto Ship Confirm Report',NULL,FALSE
       ,p_sc_batch_id,'','','','','','','','',''
       ,'','','','','','','','SC','',''
       ,'','','','','','','','','',''
       ,'','','','','','','','','',''
       ,'','','','','','','','','',''
       ,'','','','','','','','','',''
       ,'','','','','','','','','',''
       ,'','','','','','','','','',''
       ,'','','','','','','','','',''
       ,'','','','','','','','','','' );

  IF x_results_summary.report_req_id =0 THEN
    raise WSH_SUBMIT_SC_REPORT_ERR;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

  WHEN wsh_missing_sc_batch THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.PrintMsg('ERROR: Failed to find the ship confirm batch ');

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  WHEN wsh_missing_sc_rule THEN
    IF get_sc_batch%ISOPEN THEN
    CLOSE get_sc_batch;
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.PrintMsg('ERROR: Ship Confirm Rule is not found or has expired');
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  WHEN inv_inter_req_submission THEN
    IF get_sc_batch%ISOPEN THEN
    CLOSE get_sc_batch;
    END IF;
    IF G_GET_SHIP_CONFIRM_RULE%ISOPEN THEN
    CLOSE G_GET_SHIP_CONFIRM_RULE;
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    WSH_UTIL_CORE.PrintMsg('ERROR: Failed to submit Interface concurrent request ');
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  WHEN WSH_SUBMIT_SC_REPORT_ERR THEN
    IF get_sc_batch%ISOPEN THEN
     CLOSE get_sc_batch;
    END IF;
    IF G_GET_SHIP_CONFIRM_RULE%ISOPEN THEN
    CLOSE G_GET_SHIP_CONFIRM_RULE;
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    WSH_UTIL_CORE.PrintMsg('ERROR: Failed to submit Auto Ship Confirm Report ');
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  WHEN delivery_locked THEN
    IF get_sc_batch%ISOPEN THEN
     CLOSE get_sc_batch;
    END IF;
    IF G_GET_SHIP_CONFIRM_RULE%ISOPEN THEN
    CLOSE G_GET_SHIP_CONFIRM_RULE;
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    WSH_UTIL_CORE.PrintMsg('ERROR: Failed to lock delivery ID ');
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  WHEN others THEN
    IF get_sc_batch%ISOPEN THEN
    CLOSE get_sc_batch;
    END IF;
    IF G_GET_SHIP_CONFIRM_RULE%ISOPEN THEN
    CLOSE G_GET_SHIP_CONFIRM_RULE;
    END IF;
    wsh_util_core.default_handler('WSH_BATCH_PROCESS.Ship_Confirm_Batch');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

END Ship_Confirm_Batch;

-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Auto_Pack_A_Delivery
--
-- Purpose:
--   This PRIVATE procedure auto pack a delivery, it is called by
--   uto_Pack_Deliveries_Batch in a loop.
--   It is necessary to make a saperate procedure, othewise it fails to
--   catch the exception when a delivery cannot be locked within a loop and
--   it will exit all the way out of the delivery loop so no deliveries can be
--   ship confirmed after the exception occurs.
--
-- Input Parameters:
--   p_delivery_id - the delivery id to be ship cofirmed
--   p_sc_batch_id - Ship Confirm Batch ID, needed to stamp the delivery
--   p_ship_confirm_rule_rec - the ship confirm options
--   p_log_level   - log level for printing debug messages
--
-- Output Parameters:
--   x_organization_id - the organization id of the delivery
--   x_return_status  - Success, Warning, Error, Unexpected Error
-- ----------------------------------------------------------------------


PROCEDURE Auto_Pack_A_Delivery(
  p_delivery_id         IN   NUMBER,
  p_ap_batch_id         IN   NUMBER,
  p_auto_pack_level     IN   NUMBER,
  p_log_level           IN   NUMBER,
  x_return_status       OUT  NOCOPY VARCHAR2) IS

 CURSOR get_delivery( c_delivery_id NUMBER ) IS
  SELECT delivery_id,
         status_code,
         planned_flag,
         initial_pickup_date,
         organization_id,
         ship_method_code
  FROM wsh_new_deliveries
  WHERE delivery_id = c_delivery_id and
    status_code = 'OP' AND
    NVL(auto_ap_exclude_flag, 'N')= 'N' FOR UPDATE NOWAIT;


l_delivery_rec        get_delivery%ROWTYPE;
l_tmp_del_tab         WSH_UTIL_CORE.Id_Tab_Type;
l_action              VARCHAR2(30) := NULL;
l_pack_cont_flag      VARCHAR2(1) := NULL;
l_err_entity_ids      WSH_UTIL_CORE.Id_Tab_Type;
l_cont_instance_tab   WSH_UTIL_CORE.Id_Tab_Type;
l_return_status       VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_action_prms      WSH_DELIVERIES_GRP.action_parameters_rectype;
l_rec_attr_tab     WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
l_delivery_out_rec WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;
l_defaults_rec     WSH_DELIVERIES_GRP.default_parameters_rectype;
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(4000);
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Auto_Pack_A_Delivery';
WSH_INVALID_AUTO_PACK_LEVEL  EXCEPTION;
delivery_locked      EXCEPTION;

PRAGMA EXCEPTION_INIT(delivery_locked, -00054);


BEGIN

  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
  WSH_DEBUG_SV.push(l_module_name);
  END IF;

  l_tmp_del_tab.delete;
  l_tmp_del_tab(1) := p_delivery_id;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

  IF p_auto_pack_level = 1 THEN
    l_action := 'AUTO-PACK';
    l_pack_cont_flag := 'N';
  ELSIF p_auto_pack_level = 2 THEN
    l_action := 'AUTO-PACK-MASTER';
    l_pack_cont_flag := 'Y';
  ELSE
    RAISE WSH_INVALID_AUTO_PACK_LEVEL;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'Locking delivery '|| p_delivery_id);
  END IF;


  OPEN get_delivery(p_delivery_id);
  FETCH get_delivery INTO l_delivery_rec;
  IF get_delivery%FOUND THEN


      SAVEPOINT beginning_of_loop;

      UPDATE WSH_NEW_DELIVERIES SET AP_BATCH_ID = p_ap_batch_id
      WHERE delivery_id = p_delivery_id;

      fnd_msg_pub.initialize;  -- clear messages

      /* auto pack a delivery */
        l_rec_attr_tab(1).delivery_id       := l_delivery_rec.delivery_id;
        l_rec_attr_tab(1).status_code       := l_delivery_rec.status_code;
        l_rec_attr_tab(1).planned_flag      := l_delivery_rec.planned_flag;
        l_rec_attr_tab(1).organization_id   := l_delivery_rec.organization_id;
        l_rec_attr_tab(1).ship_method_code  := l_delivery_rec.ship_method_code;

        l_action_prms.action_code           := l_action;
        l_action_prms.caller                := 'WSH_BHPS';
        l_action_prms.phase                 := NULL;



        WSH_DELIVERIES_GRP.Delivery_Action
          ( p_api_version_number => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_commit             => FND_API.G_FALSE,
            p_action_prms        => l_action_prms,
            p_rec_attr_tab       => l_rec_attr_tab,
            x_delivery_out_rec   => l_delivery_out_rec,
            x_defaults_rec       => l_defaults_rec,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data
          );

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
         l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         x_return_status  :=  WSH_UTIL_CORE.G_RET_STS_ERROR;
        ROLLBACK TO beginning_of_loop;
      ELSE
         x_return_status := l_return_status;
      END IF;

  ELSE /* cannot lock the delivery */
    x_return_status  :=  WSH_UTIL_CORE.G_RET_STS_ERROR;
  END IF; -- if delivery exist

  CLOSE get_delivery;
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION

    WHEN WSH_INVALID_AUTO_PACK_LEVEL THEN
      x_return_status  :=  WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.PrintMsg('ERROR: invalid auto pack level');
      IF l_debug_on  THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Invalid Auot Pack Level');
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

    WHEN delivery_locked THEN
     CLOSE get_delivery;
     x_return_status  :=  WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.PrintMsg('ERROR: Failed to lock delivery '|| to_char(p_delivery_id));
     IF l_debug_on  THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: Failed to lock delivery '|| to_char(p_delivery_id));
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;



    WHEN OTHERS THEN
      CLOSE get_delivery;
      x_return_status  :=  WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.default_handler('WSH_BATCH_PROCESS.Auto_Pack_A_Delivery');
      WSH_UTIL_CORE.PrintMsg('ERROR: Failed to lock delivery '|| to_char(p_delivery_id));
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: Failed to lock delivery '|| to_char(p_delivery_id));
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

END Auto_Pack_A_Delivery;

-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Auto_Pack_Deliveries_Batch
--
-- Purpose
--   This procedure takes a list of delivery IDs and auto pack these
--   deliveries in batch fashion. It calls auto_pack_deliveries once for one
--   delivery at a time. If the auto pack operation is successful,
--   it commits the change, otherwise it rollback the change and proceed
--   to next delivery. If a delivery cannot be auto packed,
--   it does not prevent next delivery to be auto packed.
--   This procedure is called from Auto Pack Deliveries SRS or by
--   Pick Release SRS.
--
-- Input Parameters:
--   p_del_tab   - list of delivery IDs to be ship confimed
--   p_sc_batch_id - Ship Confirm Batch ID
--   p_log_level   - log level for printing debug messages
--
-- Output Parameters:
--   x_return_status  - Success, Warning, Error, Unexpected Error
-- ----------------------------------------------------------------------

PROCEDURE Auto_Pack_Deliveries_Batch(
  p_del_tab                  IN   WSH_BATCH_PROCESS.Del_Info_Tab,
  p_ap_batch_id          IN   NUMBER,
  p_auto_pack_level      IN   NUMBER,
  p_log_level            IN   NUMBER,
  x_packed_del_tab       OUT  NOCOPY WSH_BATCH_PROCESS.Del_Info_Tab,
  x_results_summary      OUT  NOCOPY WSH_BATCH_PROCESS.Results_Summary_Rec,
  x_return_status        OUT  NOCOPY VARCHAR2,
  P_COMMIT		 IN   VARCHAR2) IS -- BugFix #4001135

l_ap_packed_dels       wsh_util_core.id_tab_type;
l_return_status        VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Auto_Pack_Deliveries_Batch';
WSH_SUBMIT_AP_REPORT_ERR  EXCEPTION;
delivery_locked      EXCEPTION;
WSH_INVALID_AUTO_PACK_LEVEL EXCEPTION;
PRAGMA EXCEPTION_INIT(delivery_locked, -54);

    --Bugfix 4070732
    l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
    l_reset_flags BOOLEAN;
    l_return_status1 VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


BEGIN


  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  x_results_summary.success := 0;
  x_results_summary.warning := 0;
  x_results_summary.failure := 0;
  x_results_summary.report_req_id := 0;
  x_return_status  :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_packed_del_tab.delete;

  IF l_debug_on THEN
  WSH_DEBUG_SV.push(l_module_name);
  WSH_DEBUG_SV.logmsg(l_module_name,'AP level'||p_auto_pack_level);
  END IF;

  WSH_UTIL_CORE.PrintDateTime;

  IF p_auto_pack_level <> 1 AND p_auto_pack_level <> 2 THEN
    RAISE WSH_INVALID_AUTO_PACK_LEVEL;
  END IF;

  FOR i in 1 .. p_del_tab.count LOOP

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Auto pack delivery ID: ' || to_char(p_del_tab(i).delivery_id));
    END IF;

    BEGIN
      Auto_Pack_A_Delivery(
        p_delivery_id        => p_del_tab(i).delivery_id,
        p_ap_batch_id        => p_ap_batch_id,
        p_auto_pack_level    => p_auto_pack_level,
        p_log_level          => p_log_level,
        x_return_status      => l_return_status);


    EXCEPTION

      WHEN delivery_locked THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.PrintMsg('ERROR => Failed to lock delivery '|| to_char(p_del_tab(i).delivery_id));
        FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVY_LOCK_FAILED');
        FND_MESSAGE.SET_TOKEN('ENTITY_NAME',to_char(p_del_tab(i).delivery_id));
        wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);
        log_batch_messages(p_ap_batch_id, NULL ,NULL, p_del_tab(i).initial_pickup_location_id, 'E');

        IF l_debug_on  THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Failed to lock delivery '|| to_char(p_del_tab(i).delivery_id));
          WSH_DEBUG_SV.pop('wsh.plsql.' || G_PKG_NAME || '.' || 'Auto_Pack_A_Delivery');
        END IF;

      WHEN OTHERS THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.PrintMsg('ERROR => Failed to lock delivery '|| to_char(p_del_tab(i).delivery_id));
        FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVY_LOCK_FAILED');
        FND_MESSAGE.SET_TOKEN('ENTITY_NAME',to_char(p_del_tab(i).delivery_id));
        wsh_util_core.add_message(wsh_util_core.g_ret_sts_error,l_module_name);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Failed to lock delivery '|| to_char(p_del_tab(i).delivery_id));
          WSH_DEBUG_SV.pop('wsh.plsql.' || G_PKG_NAME || '.' || 'Auto_Pack_A_Delivery');
        END IF;


    END;

      --
      --bug 4070732
      IF (l_return_status in (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING)
          AND p_commit = FND_API.G_TRUE ) THEN
      --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          --{

              l_reset_flags := FALSE;

              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              BEGIN

                 WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
                                                             x_return_status => l_return_status1);
                 IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_return_status1',l_return_status1);
                 END IF;

                 IF l_return_status1 IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                       WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                         WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                    l_return_status := l_return_status1;
                 END IF;
              EXCEPTION
              WHEN others THEN
                l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              END;

          --}
          END IF;
      --}
      END IF;
      --bug 4070732
    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      x_results_summary.success := x_results_summary.success + 1;
      x_packed_del_tab(x_packed_del_tab.count+1).delivery_id := p_del_tab(i).delivery_id;
      x_packed_del_tab(x_packed_del_tab.count).organization_id := p_del_tab(i).organization_id;
      x_packed_del_tab(x_packed_del_tab.count).initial_pickup_location_id := p_del_tab(i).initial_pickup_location_id;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Auto Pack succeed for delivery ID: ' || to_char(p_del_tab(i).delivery_id));
      END IF;

    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING   THEN
      x_results_summary.warning := x_results_summary.warning + 1;
      x_packed_del_tab(x_packed_del_tab.count+1).delivery_id := p_del_tab(i).delivery_id;
      x_packed_del_tab(x_packed_del_tab.count).organization_id := p_del_tab(i).organization_id;
      x_packed_del_tab(x_packed_del_tab.count).initial_pickup_location_id := p_del_tab(i).initial_pickup_location_id;

      log_batch_messages(p_ap_batch_id, p_del_tab(i).delivery_id, NULL, p_del_tab(i).initial_pickup_location_id, 'W');
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Auto Pack completed with warnings for delivery ID: ' || to_char(p_del_tab(i).delivery_id));
      END IF;

    ELSE -- error or unexpected error

      x_results_summary.failure := x_results_summary.failure + 1;


      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Auto Pack failed for delivery ID: ' || to_char(p_del_tab(i).delivery_id));
      END IF;

      log_batch_messages(p_ap_batch_id, p_del_tab(i).delivery_id,NULL, p_del_tab(i).initial_pickup_location_id, 'E');

    END IF;

    -- Following if condition is added for Bugfix #4001135
    -- We will commit the data only when this api is called from Concurrent Request.
    IF ( P_COMMIT = FND_API.G_TRUE ) THEN
      COMMIT;
    END IF;

  END LOOP;

  IF l_debug_on THEN
  WSH_DEBUG_SV.logmsg(l_module_name,'All the deliveries have been packed');
  END IF;

  -- submit Auto Pack Deliveries Reprot here
  x_results_summary.report_req_id := fnd_request.submit_request(
         'WSH',
         'WSHRDAPK','Auto Pack Report',NULL,FALSE
         ,p_ap_batch_id,'','','','','','','','',''
         ,'','','','','','','AP','','',''
         ,'','','','','','','','','',''
         ,'','','','','','','','','',''
         ,'','','','','','','','','',''
         ,'','','','','','','','','',''
         ,'','','','','','','','','',''
         ,'','','','','','','','','',''
         ,'','','','','','','','','',''
         ,'','','','','','','','','','' );
  IF x_results_summary.report_req_id =0 THEN
    raise WSH_SUBMIT_AP_REPORT_ERR;
  END IF;

    --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

  WHEN WSH_INVALID_AUTO_PACK_LEVEL THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('WSH' , 'WSH_INVALID_AUTO_PACK_LEVEL');
    WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
    IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  WHEN WSH_SUBMIT_AP_REPORT_ERR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    FND_MESSAGE.SET_NAME('WSH' , 'WSH_SUBMIT_AP_REPORT_ERR');
    WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
    IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  WHEN others THEN
    wsh_util_core.default_handler('WSH_BATCH_PROCESS.Auto_Pack_Deliveries_Batch');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
    END IF;

END Auto_Pack_Deliveries_Batch;

-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Confirm_Delivery_SRS
--
-- Purpose
--   This is ship confirm concurrent program launched using standard report submisstion.
--   It takes users defined criteria and construct a dynamic select statement to
--   get a list of delivery IDs to be ship confirmed then call Ship_Confirm_Batch.
--   The actual ship confirm operation is done in Ship_Cofirm_Batch procedure
--
-- Input Parameters:
--   p_ship_confirm_rule_id   - Auto Ship Confirm Rule ID
--   p_sc_batch_prefix    - Ship Confirm Batch ID
--   p_client_id        - Client ID for LSP -- Modified R12.1.1 LSP PROJECT (rminocha)
--   p_organization_id    - Organization ID
--   p_pr_batch_id      - Pick Release Batch ID
--   p_ap_batch_id      - Auto Pack Batch ID
--   p_delivery_name_lo    - Delivery Name (Low)
--   p_delivery_name_hi    - Delivery Name (High)
--   p_bol_number_lo      - BOL Number (Low)
--   p_bol_number_hi      - BOL Number (High)
--   p_planned_flag      - Planned Flag
--   p_ship_from_loc_id    - Ship from Location ID
--   p_ship_to_loc_id    - Ship to Location ID
--   p_intmed_ship_to_loc_id  - Intermediate Ship to Location ID
--   p_pooled_ship_to_loc_id  - Pooled Ship to Location ID
--   p_customer_id      - Customer ID
--   p_ship_method_code    - Ship Method Code
--   p_fob_code        - FOB Code
--   p_freight_terms_code  - Freight Terms Code
--   p_pickup_date_lo    - Pick up Date (Low)
--   p_pickup_date_hi    - Pick up Date (High)
--   p_dropoff_date_lo    - Drop off Date (Low)
--   p_dropoff_date_hi    - Drop off Date (High)
--   p_log_level        - Log Level
--   p_actual_departure_date - Actual Departure Date for stop
--
-- Output Parameters:
--   errbug   - standard output parameter for a concurrent program
--   retcode     - standard output parameter for a concurrent program
-- ----------------------------------------------------------------------


procedure Confirm_Delivery_SRS(
   errbuf          OUT NOCOPY VARCHAR2,
   retcode          OUT NOCOPY VARCHAR2,
   p_ship_confirm_rule_id  IN NUMBER,
   p_actual_departure_date IN VARCHAR2,
   p_sc_batch_prefix    IN VARCHAR2,
   p_deploy_mode        IN VARCHAR2,  -- Modified R12.1.1 LSP PROJECT
   p_client_id        IN NUMBER, -- Modified R12.1.1 LSP PROJECT (rminocha)
   p_organization_id    IN NUMBER,
   p_pr_batch_id      IN NUMBER,
   p_ap_batch_id      IN NUMBER,
   p_delivery_name_lo    IN VARCHAR2,
   p_delivery_name_hi    IN VARCHAR2,
   p_bol_number_lo      IN VARCHAR2,
   p_bol_number_hi      IN VARCHAR2,
   p_planned_flag      IN VARCHAR2,
   p_ship_from_loc_id    IN NUMBER,
   p_ship_to_loc_id      IN NUMBER,
   p_intmed_ship_to_loc_id   IN NUMBER,
   p_pooled_ship_to_loc_id   IN NUMBER,
   p_customer_id      IN NUMBER,
   p_ship_method_code    IN VARCHAR2,
   p_fob_code        IN VARCHAR2,
   p_freight_terms_code    IN VARCHAR2,
   p_pickup_date_lo      IN VARCHAR2,
   p_pickup_date_hi      IN VARCHAR2,
   p_dropoff_date_lo    IN VARCHAR2,
   p_dropoff_date_hi    IN VARCHAR2,
   p_log_level        IN NUMBER) IS

   l_completion_status      VARCHAR2(30);
   l_error_code          NUMBER;
   l_error_text          VARCHAR2(2000);

   l_user_id          NUMBER := 0;
   l_login_id          NUMBER := 0;
   l_return_status        VARCHAR2(30) := NULL;
   l_rowid                VARCHAR2(30);
   l_log_level          NUMBER := 0;
   l_temp            BOOLEAN;
   l_batch_rec          WSH_PICKING_BATCHES%ROWTYPE;
   l_debug_on BOOLEAN;
   l_confirmed_del_tab      WSH_UTIL_CORE.Id_Tab_Type;
   l_selected_del_tab      WSH_BATCH_PROCESS.Del_Info_Tab;
   l_select_criteria      WSH_BATCH_PROCESS.Select_Criteria_Rec;
   l_results_summary      WSH_BATCH_PROCESS.Results_Summary_Rec;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Confirm_Delivery_SRS';
   WSH_MISSING_SC_RULE      EXCEPTION;
   WSH_MISSING_SC_BATCH_PREFIX   EXCEPTION;
   WSH_SC_BATCH_ERR        EXCEPTION;
   WSH_SELECT_ERR        EXCEPTION;
   WSH_NO_FUTURE_SHIPDATE  EXCEPTION;
   l_batch_name		VARCHAR2(30);

   -- deliveryMerge
   Adjust_Planned_Flag_Err  EXCEPTION;
   l_warning_num            NUMBER := 0;
   l_delivery_ids           WSH_UTIL_CORE.Id_Tab_Type;

   --
   -- Bug 5097710
   --
   l_summary VARCHAR2(32000);
   l_detail  VARCHAR2(32000);
   l_count  number;
   --
BEGIN

    l_delivery_ids.delete;
    IF p_log_level IS NULL THEN
       l_log_level := 0;
    ELSE
       l_log_level := p_log_level;
    END IF;
    WSH_UTIL_CORE.Set_Log_Level(l_log_level);

    --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
   END IF;

   l_completion_status := 'NORMAL';

   -- Fetch user and login information
   l_user_id := FND_GLOBAL.USER_ID;
   l_login_id := FND_GLOBAL.CONC_LOGIN_ID;

   WSH_UTIL_CORE.Enable_Concurrent_Log_Print;

   IF p_ship_confirm_rule_id IS NULL THEN
      raise WSH_MISSING_SC_RULE;
   END IF;

   IF p_sc_batch_prefix IS NULL THEN
      raise WSH_MISSING_SC_BATCH_PREFIX;
   END IF;

   WSH_UTIL_CORE.PrintMsg('Input Parameters: ' );
   WSH_UTIL_CORE.PrintMsg('  Auto Ship Confirm Rule ID: '|| p_ship_confirm_rule_id);
   WSH_UTIL_CORE.PrintMsg('  Ship Confirm Batch Prefix: ' || p_sc_batch_prefix );
   WSH_UTIL_CORE.PrintMsg('  Actual Departure Date: ' || p_actual_departure_date);


   IF NOT WSH_UTIL_CORE.ValidateActualDepartureDate(p_ship_confirm_rule_id, FND_DATE.CANONICAL_TO_DATE(p_actual_departure_date)) THEN
      raise WSH_NO_FUTURE_SHIPDATE;
   END IF;

   l_select_criteria.process_mode          := G_SHIP_CONFIRM;
   l_select_criteria.client_id             := p_client_id; --Modified R12.1.1 LSP PROJECT
   l_select_criteria.organization_id       := p_organization_id;
   l_select_criteria.pr_batch_id           := p_pr_batch_id;
   l_select_criteria.ap_batch_id           := p_ap_batch_id;
   l_select_criteria.delivery_name_lo      := p_delivery_name_lo;
   l_select_criteria.delivery_name_hi      := p_delivery_name_hi;
   l_select_criteria.bol_number_lo         := p_bol_number_lo;
   l_select_criteria.bol_number_hi         := p_bol_number_hi;
   l_select_criteria.planned_flag          := p_planned_flag;
   l_select_criteria.ship_from_loc_id      := p_ship_from_loc_id;
   l_select_criteria.ship_to_loc_id        := p_ship_to_loc_id;
   l_select_criteria.intmed_ship_to_loc_id := p_intmed_ship_to_loc_id;
   l_select_criteria.pooled_ship_to_loc_id := p_pooled_ship_to_loc_id;
   l_select_criteria.customer_id           := p_customer_id;
   l_select_criteria.ship_method_code      := p_ship_method_code;
   l_select_criteria.fob_code              := p_fob_code;
   l_select_criteria.freight_terms_code    := p_freight_terms_code;
   l_select_criteria.pickup_date_lo        := p_pickup_date_lo;
   l_select_criteria.pickup_date_hi        := p_pickup_date_hi;
   l_select_criteria.dropoff_date_lo       := p_dropoff_date_lo;
   l_select_criteria.dropoff_date_hi       := p_dropoff_date_hi;
   l_select_criteria.log_level             := l_log_level;

   Select_Deliveries(
      p_input_info          => l_select_criteria,
      p_batch_rec           => l_batch_rec,
      x_selected_del_tab    => l_selected_del_tab,
      x_return_status       => l_return_status);

   --  should we also pack the input parameters into a record
   --  so I will pack them into record, and
   --  this is the record used to populate wsh_picking_batches
   --  otherwise i need to have a bunch of if stmt again to check the parameters

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      raise WSH_SELECT_ERR;
   END IF;

   IF l_selected_del_tab.count > 0 THEN

      -- deliveryMerge
      FOR i in l_selected_del_tab.FIRST .. l_selected_del_tab.LAST LOOP
         l_delivery_ids(l_delivery_ids.count+1) := l_selected_del_tab(i).delivery_id;
      END LOOP;

      -- call adjust_planned_flag to plan the deliveries
      -- because during ship confirm, no other delivery
      -- detail lines should be appended to the deliveries
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Adjust_Planned_Flag');
      END IF;

      WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag(
         p_delivery_ids            => l_delivery_ids,
         p_caller                  => 'WSH_DLMG',
         p_force_appending_limit   => 'Y',
         p_call_lcss               => 'N',
         x_return_status           => l_return_status);
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Return status from Calling Adjust_Planned_Flag:'||l_return_status);
      END IF;

      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         l_warning_num := l_warning_num + 1;
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR or
            l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
         raise Adjust_Planned_Flag_Err;
      END IF;
      commit;

      -- insert new record in table WSH_PICKING_BATCHES, with NON_PICKING_FLAG = 'Y',
      -- SHIP_CONFIRM_RULE_ID = <p_ship_confirm_rule_id>

      l_batch_rec.non_picking_flag := 'Y';
      l_batch_rec.ship_confirm_rule_id := p_ship_confirm_rule_id;
      l_batch_rec.actual_departure_date :=
       FND_DATE.canonical_to_date(p_actual_departure_date);
      --
      IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'Non Picking Flag',
                        l_batch_rec.non_picking_flag);
       WSH_DEBUG_SV.log(l_module_name, 'Ship Confirm Rule ID',
                        l_batch_rec.ship_confirm_rule_id);
       WSH_DEBUG_SV.log(l_module_name, 'Actual Departure Date',
                        l_batch_rec.actual_departure_date);
       --
       IF l_batch_rec.actual_departure_date IS NULL THEN
        wsh_debug_sv.logmsg(l_module_name,
                   'NULL input parameter p_actual_departure_date');
       ELSE
        wsh_debug_sv.logmsg(l_module_name,
                   'NOT NULL input parameter p_actual_departure_date');
       END IF;
       --
      END IF;

      -- bug 5117876, direct insert into wsh_picking_batches table is replaced
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PICKING_BATCHES_PKG.INSERT_ROW',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_PICKING_BATCHES_PKG.Insert_Row(
          X_Rowid                   => l_rowid,
          X_Batch_Id                => l_batch_rec.batch_id,
          P_Creation_Date           => SYSDATE,
          P_Created_By              => l_user_id,
          P_Last_Update_Date        => SYSDATE,
          P_Last_Updated_By         => l_user_id,
          P_Last_Update_Login       => l_login_id,
          P_batch_name_prefix       => p_sc_batch_prefix,
          X_Name                    => l_batch_rec.name,
          P_Backorders_Only_Flag    => NULL,
          P_Document_Set_Id         => NULL,
          P_Existing_Rsvs_Only_Flag => NULL,
          P_Shipment_Priority_Code  => NULL,
          P_Ship_Method_Code        => l_batch_rec.ship_method_code,
          P_Customer_Id             => l_batch_rec.customer_id,
          P_Order_Header_Id         => NULL,
          P_Ship_Set_Number         => NULL,
          P_Inventory_Item_Id       => NULL,
          P_Order_Type_Id           => NULL,
          P_From_Requested_Date     => NULL,
          P_To_Requested_Date       => NULL,
          P_From_Scheduled_Ship_Date => NULL,
          P_To_Scheduled_Ship_Date   => NULL,
          P_Ship_To_Location_Id      => l_batch_rec.ship_to_location_id,
          P_Ship_From_Location_Id    => l_batch_rec.ship_from_location_id,
          P_Trip_Id                  => NULL,
          P_Delivery_Id              => NULL,
          P_Include_Planned_Lines    => NULL,
          P_Pick_Grouping_Rule_Id    => NULL,
          P_pick_sequence_rule_id    => NULL,
          P_Autocreate_Delivery_Flag => NULL,
          P_Attribute_Category       => NULL,
          P_Attribute1               => NULL,
          P_Attribute2               => NULL,
          P_Attribute3               => NULL,
          P_Attribute4               => NULL,
          P_Attribute5               => NULL,
          P_Attribute6               => NULL,
          P_Attribute7               => NULL,
          P_Attribute8               => NULL,
          P_Attribute9               => NULL,
          P_Attribute10              => NULL,
          P_Attribute11              => NULL,
          P_Attribute12              => NULL,
          P_Attribute13              => NULL,
          P_Attribute14              => NULL,
          P_Attribute15              => NULL,
          P_Autodetail_Pr_Flag       => NULL,
          P_Carrier_Id               => NULL,
          P_Trip_Stop_Id             => NULL,
          P_Default_stage_subinventory => NULL,
          P_Default_stage_locator_id => NULL,
          P_Pick_from_subinventory   => NULL,
          P_Pick_from_locator_id     => NULL,
          P_Auto_pick_confirm_flag   => NULL,
          P_Delivery_Detail_ID       => NULL,
          P_Project_ID               => NULL,
          P_Task_ID                  => NULL,
          P_Organization_Id          => l_batch_rec.organization_id,
          P_Ship_Confirm_Rule_Id     => l_batch_rec.ship_confirm_rule_id,
          P_Autopack_Flag            => NULL,
          P_Autopack_Level           => NULL,
          P_Task_Planning_Flag       => NULL,
          P_Non_Picking_Flag         => l_batch_rec.non_picking_flag,
          p_regionID                 => NULL,
          p_zoneId                   => NULL,
          p_categoryID               => NULL,
          p_categorySetID            => NULL,
          p_acDelivCriteria          => NULL,
          p_RelSubinventory          => NULL,
          p_actual_departure_date    => l_batch_rec.actual_departure_date,
          p_allocation_method        => NULL,
          p_crossdock_criteria_id    => NULL,
          p_append_flag              => NULL,
          p_task_priority            => NULL,
          p_Delivery_Name_Lo         => l_batch_rec.delivery_name_lo,
          p_Delivery_Name_Hi         => l_batch_rec.delivery_name_hi,
          p_Bol_Number_Lo            => l_batch_rec.bol_number_lo,
          p_Bol_Number_Hi            => l_batch_rec.bol_number_hi,
          p_Intmed_Ship_To_Loc_Id    => l_batch_rec.intmed_ship_to_loc_id,
          p_Pooled_Ship_To_Loc_Id    => l_batch_rec.pooled_ship_to_loc_id,
          p_Fob_Code                 => l_batch_rec.fob_code,
          p_Freight_Terms_Code       => l_batch_rec.freight_terms_code,
          p_Pickup_Date_Lo           => l_batch_rec.pickup_date_lo,
          p_Pickup_Date_Hi           => l_batch_rec.pickup_date_hi,
          p_Dropoff_Date_Lo          => l_batch_rec.dropoff_date_lo,
          p_Dropoff_Date_Hi          => l_batch_rec.dropoff_date_hi,
          p_Planned_Flag             => l_batch_rec.planned_flag,
          p_Selected_Batch_Id        => l_batch_rec.selected_batch_id,
          p_client_id                => l_batch_rec.client_id); -- Modified R12.1.1 LSP PROJECT


      WSH_UTIL_CORE.PrintMsg('Ship Confirm Batch Name: ' || l_batch_rec.name);

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Deliveries selected to be ship confirmed are: ');
         FOR k in 1 .. l_selected_del_tab.count LOOP
            WSH_DEBUG_SV.logmsg(l_module_name, '  delivery: ' || l_selected_del_tab(k).delivery_id);
         END LOOP;
      END IF;

      Ship_Confirm_Batch(
         p_del_tab => l_selected_del_tab,
         p_sc_batch_id => l_batch_rec.batch_id,
         p_log_level => l_log_level,
         x_confirmed_del_tab => l_confirmed_del_tab,
         x_results_summary =>  l_results_summary,
         x_return_status => l_return_status,
         p_commit => FND_API.G_TRUE); -- BugFix #4001135

      WSH_UTIL_CORE.PrintDateTime;
      WSH_UTIL_CORE.PrintMsg('Summary: ');
      WSH_UTIL_CORE.PrintMsg(to_char(l_selected_del_tab.count) ||' deliveries selected to be ship confirmed');
      WSH_UTIL_CORE.PrintMsg(to_char(l_results_summary.success)||' deliveries have been successfully ship confirmed');
      WSH_UTIL_CORE.PrintMsg(to_char(l_results_summary.warning)||' deliveries have been ship confirmed with warnings');
      WSH_UTIL_CORE.PrintMsg(to_char(l_results_summary.failure)||' deliveries cannot be ship confirmed');

      IF l_results_summary.report_req_id > 0 THEN
         WSH_UTIL_CORE.PrintMsg('Ship Confirm Report request ID: '|| to_char(l_results_summary.report_req_id));
         WSH_UTIL_CORE.PrintMsg('Please see Ship Confirm Report for details');
      END IF;

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) AND
         (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
         RAISE WSH_SC_BATCH_ERR;
      END IF;

   ELSE
      /* no deliveries selected */
      WSH_UTIL_CORE.PrintDateTime;
      WSH_UTIL_CORE.PrintMsg('Summary: ');
      WSH_UTIL_CORE.PrintMsg(to_char(l_selected_del_tab.count) ||' deliveries selected to be ship confirmed');

END IF;

errbuf := 'Automated Ship Confirm is completed successfully';
retcode := '0';
IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
END IF;


EXCEPTION

   WHEN Adjust_Planned_Flag_Err THEN
      -- Bug 5097710
      wsh_util_core.get_messages('Y',l_summary,l_detail,l_count);
      WSH_UTIL_CORE.PrintMsg('Summary:');
      WSH_UTIL_CORE.PrintMsg(l_summary);
      WSH_UTIL_CORE.PrintMsg('Details:');
      WSH_UTIL_CORE.PrintMsg(l_detail);
      WSH_UTIL_CORE.PrintMsg('No. of Errors : ' || l_count);
      --
      l_completion_status := 'WARNING';
      WSH_UTIL_CORE.PrintMsg('Adjust Planned Flag error');
      l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
      errbuf := 'Automated Ship Confirm is completed with warning';
      retcode := '1';
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

   WHEN WSH_MISSING_SC_RULE THEN
      l_completion_status := 'WARNING';
      WSH_UTIL_CORE.PrintMsg('Ship Confirm Rule is not found or has expired');
      l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
      errbuf := 'Automated Ship Confirm is completed with warning';
      retcode := '1';
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

   WHEN WSH_MISSING_SC_BATCH_PREFIX THEN
      l_completion_status := 'WARNING';
      WSH_UTIL_CORE.PrintMsg('You need to specify Ship Confirm Batch Prefix');
      l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
      errbuf := 'Automated Ship Confirm is completed with warning';
      retcode := '1';
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

   WHEN WSH_NO_FUTURE_SHIPDATE THEN
      l_completion_status := 'WARNING';
      WSH_UTIL_CORE.PrintMsg('No Lines were selected for Ship Confirmation because Allow Future Ship Date Parameter is disabled and Actual Ship Date is greater than current system date');
      l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
      errbuf := 'Automated Ship Confirm is completed with warning';
      retcode := '1';
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

   WHEN WSH_SELECT_ERR THEN
      l_completion_status := 'WARNING';
      WSH_UTIL_CORE.PrintMsg('Failed to select deliveries for the batch');
      l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
      errbuf := 'Automated Ship Confirm is completed with warning';
      retcode := '1';
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

   WHEN WSH_SC_BATCH_ERR THEN
      l_completion_status := 'WARNING';
      WSH_UTIL_CORE.PrintMsg('Ship Confirm failed for this batch');
      l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
      errbuf := 'Automated Ship Confirm is completed with warning';
      retcode := '1';
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

   WHEN OTHERS THEN
      l_completion_status := 'ERROR';
      l_error_code   := SQLCODE;
      l_error_text   := SQLERRM;
      WSH_UTIL_CORE.PrintMsg('Confirm Delivery SRS failed with unexpected error.');
      WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || l_error_text);
      l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
      errbuf := 'Automated Ship Confirm failed with unexpected error';
      retcode := '2';
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;

END CONFIRM_DELIVERY_SRS;


-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Auto_Pack_Deliveries_SRS
--
-- Purpose
--   This is auto pack deliveries concurrent program launched using standard
--   report submisstion.
--   It takes users defined criteria and construct a dynamic select statement to
--   get a list of delivery IDs to be auto packed then call Auto_Pack_Deliveries_Batch.
--   The actual auto pack operation is done in Auto_Pack_Deliveries_Batch procedure
--
-- Input Parameters:
--   p_auto_pack_level    - 1: auto pack , 2: auto pack master
--   p_organization_id    - Organization ID
--   p_pr_batch_id      - Pick Release Batch ID
--   p_delivery_name_lo    - Delivery Name (Low)
--   p_delivery_name_hi    - Delivery Name (High)
--   p_bol_number_lo      - BOL Number (Low)
--   p_bol_number_hi      - BOL Number (High)
--   p_planned_flag      - Planned Flag
--   p_ship_from_loc_id    - Ship from Location ID
--   p_ship_to_loc_id    - Ship to Location ID
--   p_intmed_ship_to_loc_id  - Intermediate Ship to Location ID
--   p_pooled_ship_to_loc_id  - Pooled Ship to Location ID
--   p_customer_id      - Customer ID
--   p_ship_method_code    - Ship Method Code
--   p_fob_code        - FOB Code
--   p_freight_terms_code  - Freight Terms Code
--   p_pickup_date_lo    - Pick up Date (Low)
--   p_pickup_date_hi    - Pick up Date (High)
--   p_dropoff_date_lo    - Drop off Date (Low)
--   p_dropoff_date_hi    - Drop off Date (High)
--   p_log_level        - Log Level
--
-- Output Parameters:
--   errbug   - standard output parameter for a concurrent program
--   retcode     - standard output parameter for a concurrent program
-- ----------------------------------------------------------------------


procedure Auto_Pack_Deliveries_SRS(
   errbuf          OUT NOCOPY VARCHAR2,
   retcode          OUT NOCOPY VARCHAR2,
   p_auto_pack_level    IN NUMBER,
   p_ap_batch_prefix    IN VARCHAR2,
   p_organization_id    IN NUMBER,
   p_pr_batch_id      IN NUMBER,
   p_delivery_name_lo    IN VARCHAR2,
   p_delivery_name_hi    IN VARCHAR2,
   p_bol_number_lo      IN VARCHAR2,
   p_bol_number_hi      IN VARCHAR2,
   p_planned_flag      IN VARCHAR2,
   p_ship_from_loc_id    IN NUMBER,
   p_ship_to_loc_id      IN NUMBER,
   p_intmed_ship_to_loc_id   IN NUMBER,
   p_pooled_ship_to_loc_id   IN NUMBER,
   p_customer_id      IN NUMBER,
   p_ship_method_code    IN VARCHAR2,
   p_fob_code        IN VARCHAR2,
   p_freight_terms_code    IN VARCHAR2,
   p_pickup_date_lo      IN VARCHAR2,
   p_pickup_date_hi      IN VARCHAR2,
   p_dropoff_date_lo    IN VARCHAR2,
   p_dropoff_date_hi    IN VARCHAR2,
   p_log_level        IN NUMBER ) IS

   l_completion_status      VARCHAR2(30);
   l_error_code          NUMBER;
   l_error_text          VARCHAR2(2000);
   l_user_id          NUMBER := 0;
   l_login_id          NUMBER := 0;
   l_auto_pack_level      NUMBER := 0;
   l_log_level          NUMBER := 0;
   l_return_status        VARCHAR2(30) := NULL;
   l_rowid                VARCHAR2(30);
   l_temp            BOOLEAN;
   l_batch_rec          WSH_PICKING_BATCHES%ROWTYPE;
   l_debug_on BOOLEAN;
   l_packed_del_tab        WSH_BATCH_PROCESS.Del_Info_Tab;
   l_selected_del_tab      WSH_BATCH_PROCESS.Del_Info_Tab;
   l_select_criteria      WSH_BATCH_PROCESS.Select_Criteria_Rec;
   l_results_summary      WSH_BATCH_PROCESS.Results_Summary_Rec;

   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Auto_Pack_Deliveries_SRS';
   WSH_PK_BATCH_ERR        EXCEPTION;
   WSH_INVALID_AUTO_PACK_LEVEL   EXCEPTION;
   WSH_SELECT_ERR        EXCEPTION;
   --
   l_batch_name		VARCHAR2(30);
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
   END IF;

   l_completion_status := 'NORMAL';

   l_packed_del_tab.delete;
   -- Fetch user and login information
   l_user_id := FND_GLOBAL.USER_ID;
   l_login_id := FND_GLOBAL.CONC_LOGIN_ID;

   IF p_auto_pack_level IS NULL THEN
      l_auto_pack_level := 1;
   ELSE
      l_auto_pack_level := p_auto_pack_level;
   END IF;

   IF p_log_level IS NULL THEN
      l_log_level := 0;
   ELSE
      l_log_level := p_log_level;
   END IF;

   WSH_UTIL_CORE.Enable_Concurrent_Log_Print;
   WSH_UTIL_CORE.Set_Log_Level(l_log_level);

   WSH_UTIL_CORE.PrintMsg('Input Parameters: ' );
   WSH_UTIL_CORE.PrintMsg('  Auto Pack Level: '||to_char(p_auto_pack_level));
   WSH_UTIL_CORE.PrintMsg('  Auto Pack Batch Prefix: '|| p_ap_batch_prefix);

   l_select_criteria.process_mode      := G_AUTO_PACK;
   l_select_criteria.organization_id    := p_organization_id;
   l_select_criteria.pr_batch_id      := p_pr_batch_id;
   l_select_criteria.delivery_name_lo    := p_delivery_name_lo;
   l_select_criteria.delivery_name_hi    := p_delivery_name_hi;
   l_select_criteria.bol_number_lo    := p_bol_number_lo;
   l_select_criteria.bol_number_hi    := p_bol_number_hi;
   l_select_criteria.planned_flag      := p_planned_flag;
   l_select_criteria.ship_from_loc_id    := p_ship_from_loc_id;
   l_select_criteria.ship_to_loc_id    := p_ship_to_loc_id;
   l_select_criteria.intmed_ship_to_loc_id := p_intmed_ship_to_loc_id;
   l_select_criteria.pooled_ship_to_loc_id := p_pooled_ship_to_loc_id;
   l_select_criteria.customer_id      := p_customer_id;
   l_select_criteria.ship_method_code    := p_ship_method_code;
   l_select_criteria.fob_code        := p_fob_code;
   l_select_criteria.freight_terms_code  := p_freight_terms_code;
   l_select_criteria.pickup_date_lo    := p_pickup_date_lo;
   l_select_criteria.pickup_date_hi    := p_pickup_date_hi;
   l_select_criteria.dropoff_date_lo    := p_dropoff_date_lo;
   l_select_criteria.dropoff_date_hi    := p_dropoff_date_hi;
   l_select_criteria.log_level      := l_log_level;

   Select_Deliveries(
      p_input_info      => l_select_criteria,
      p_batch_rec      => l_batch_rec,
      x_selected_del_tab    => l_selected_del_tab,
      x_return_status    => l_return_status);

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      raise WSH_SELECT_ERR;
   END IF;

   IF l_selected_del_tab.count > 0 THEN

      -- insert new record in table WSH_PICKING_BATCHES, with NON_PICKING_FLAG = 'Y',
      -- SHIP_CONFIRM_RULE_ID = <p_ship_confirm_rule_id>

      -- required fields for auto pack batch
      l_batch_rec.non_picking_flag := 'Y';
      l_batch_rec.autopack_flag := 'Y';
      l_batch_rec.autopack_level := l_auto_pack_level;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Non Picking Flag', l_batch_rec.non_picking_flag);
        WSH_DEBUG_SV.log(l_module_name, 'Batch Name', l_batch_rec.name);
        WSH_DEBUG_SV.log(l_module_name, 'Auto Pack Flag', l_batch_rec.autopack_flag);
        WSH_DEBUG_SV.log(l_module_name, 'Auto Pack Level', l_batch_rec.autopack_level);
      END IF;

      -- bug 5117876, direct insert into wsh_picking_batches table is replaced
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PICKING_BATCHES_PKG.INSERT_ROW',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_PICKING_BATCHES_PKG.Insert_Row(
          X_Rowid                   => l_rowid,
          X_Batch_Id                => l_batch_rec.batch_id,
          P_Creation_Date           => SYSDATE,
          P_Created_By              => l_user_id,
          P_Last_Update_Date        => SYSDATE,
          P_Last_Updated_By         => l_user_id,
          P_Last_Update_Login       => l_login_id,
          P_batch_name_prefix       => p_ap_batch_prefix,
          X_Name                    => l_batch_rec.name,
          P_Backorders_Only_Flag    => NULL,
          P_Document_Set_Id         => NULL,
          P_Existing_Rsvs_Only_Flag => NULL,
          P_Shipment_Priority_Code  => NULL,
          P_Ship_Method_Code        => l_batch_rec.ship_method_code,
          P_Customer_Id             => l_batch_rec.customer_id,
          P_Order_Header_Id         => NULL,
          P_Ship_Set_Number         => NULL,
          P_Inventory_Item_Id       => NULL,
          P_Order_Type_Id           => NULL,
          P_From_Requested_Date     => NULL,
          P_To_Requested_Date       => NULL,
          P_From_Scheduled_Ship_Date => NULL,
          P_To_Scheduled_Ship_Date   => NULL,
          P_Ship_To_Location_Id      => l_batch_rec.ship_to_location_id,
          P_Ship_From_Location_Id    => l_batch_rec.ship_from_location_id,
          P_Trip_Id                  => NULL,
          P_Delivery_Id              => NULL,
          P_Include_Planned_Lines    => NULL,
          P_Pick_Grouping_Rule_Id    => NULL,
          P_pick_sequence_rule_id    => NULL,
          P_Autocreate_Delivery_Flag => NULL,
          P_Attribute_Category       => NULL,
          P_Attribute1               => NULL,
          P_Attribute2               => NULL,
          P_Attribute3               => NULL,
          P_Attribute4               => NULL,
          P_Attribute5               => NULL,
          P_Attribute6               => NULL,
          P_Attribute7               => NULL,
          P_Attribute8               => NULL,
          P_Attribute9               => NULL,
          P_Attribute10              => NULL,
          P_Attribute11              => NULL,
          P_Attribute12              => NULL,
          P_Attribute13              => NULL,
          P_Attribute14              => NULL,
          P_Attribute15              => NULL,
          P_Autodetail_Pr_Flag       => NULL,
          P_Carrier_Id               => NULL,
          P_Trip_Stop_Id             => NULL,
          P_Default_stage_subinventory => NULL,
          P_Default_stage_locator_id => NULL,
          P_Pick_from_subinventory   => NULL,
          P_Pick_from_locator_id     => NULL,
          P_Auto_pick_confirm_flag   => NULL,
          P_Delivery_Detail_ID       => NULL,
          P_Project_ID               => NULL,
          P_Task_ID                  => NULL,
          P_Organization_Id          => l_batch_rec.organization_id,
          P_Ship_Confirm_Rule_Id     => NULL,
          P_Autopack_Flag            => l_batch_rec.autopack_flag,
          P_Autopack_Level           => l_batch_rec.autopack_level,
          P_Task_Planning_Flag       => NULL,
          P_Non_Picking_Flag         => l_batch_rec.non_picking_flag,
          p_regionID                 => NULL,
          p_zoneId                   => NULL,
          p_categoryID               => NULL,
          p_categorySetID            => NULL,
          p_acDelivCriteria          => NULL,
          p_RelSubinventory          => NULL,
          p_actual_departure_date    => NULL,
          p_allocation_method        => NULL,
          p_crossdock_criteria_id    => NULL,
          p_append_flag              => NULL,
          p_task_priority            => NULL,
          p_Delivery_Name_Lo         => l_batch_rec.delivery_name_lo,
          p_Delivery_Name_Hi         => l_batch_rec.delivery_name_hi,
          p_Bol_Number_Lo            => l_batch_rec.bol_number_lo,
          p_Bol_Number_Hi            => l_batch_rec.bol_number_hi,
          p_Intmed_Ship_To_Loc_Id    => l_batch_rec.intmed_ship_to_loc_id,
          p_Pooled_Ship_To_Loc_Id    => l_batch_rec.pooled_ship_to_loc_id,
          p_Fob_Code                 => l_batch_rec.fob_code,
          p_Freight_Terms_Code       => l_batch_rec.freight_terms_code,
          p_Pickup_Date_Lo           => l_batch_rec.pickup_date_lo,
          p_Pickup_Date_Hi           => l_batch_rec.pickup_date_hi,
          p_Dropoff_Date_Lo          => l_batch_rec.dropoff_date_lo,
          p_Dropoff_Date_Hi          => l_batch_rec.dropoff_date_hi,
          p_Planned_Flag             => l_batch_rec.planned_flag,
          p_Selected_Batch_Id        => l_batch_rec.selected_batch_id);

      WSH_UTIL_CORE.PrintMsg('Auto Pack Batch Name: ' || l_batch_rec.name);

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Deliveries selected to be auto packed are: ');
         FOR k in 1 .. l_selected_del_tab.count LOOP
            WSH_DEBUG_SV.logmsg(l_module_name, '  delivery: ' || l_selected_del_tab(k).delivery_id);
         END LOOP;
      END IF;

      Auto_Pack_Deliveries_Batch(
      p_del_tab => l_selected_del_tab,
      p_ap_batch_id => l_batch_rec.batch_id,
      p_auto_pack_level => p_auto_pack_level,
      p_log_level => l_log_level,
      x_packed_del_tab => l_packed_del_tab,
      x_results_summary =>  l_results_summary,
      x_return_status => l_return_status,
      p_commit => FND_API.G_TRUE); -- BugFix #4001135

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Deliveries successfully packed are: ');
        FOR k in 1 .. l_packed_del_tab.count LOOP
          WSH_DEBUG_SV.logmsg(l_module_name, '  delivery: ' || l_packed_del_tab(k).delivery_id);
        END LOOP;
      END IF;

      WSH_UTIL_CORE.PrintDateTime;
      WSH_UTIL_CORE.PrintMsg('Summary: ');
      WSH_UTIL_CORE.PrintMsg(to_char(l_selected_del_tab.count)|| ' deliveries selected for auto packing');
      WSH_UTIL_CORE.PrintMsg(to_char(l_results_summary.success)||' deliveries have been successfully packed');
      WSH_UTIL_CORE.PrintMsg(to_char(l_results_summary.warning)||' deliveries have been packed with warnings');
      WSH_UTIL_CORE.PrintMsg(to_char(l_results_summary.failure)||' deliveries cannot be packed');
      IF l_results_summary.report_req_id > 0 THEN
         WSH_UTIL_CORE.PrintMsg('Auto Pack Deliveries Report request ID: '|| to_char(l_results_summary.report_req_id));
         WSH_UTIL_CORE.PrintMsg('Please see Auto Pack Deliveries Report for details');
      END IF;

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) AND
         (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
         RAISE WSH_PK_BATCH_ERR;
      END IF;

   ELSE
      /* not deliveries selected */
      WSH_UTIL_CORE.PrintDateTime;
      WSH_UTIL_CORE.PrintMsg('Summary: ');
      WSH_UTIL_CORE.PrintMsg(to_char(l_selected_del_tab.count)|| ' deliveries selected for auto packing');

   END IF;
   errbuf := 'Auto Pack Deliveries is completed successfully';
   retcode := '0';

   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;


EXCEPTION

   WHEN WSH_INVALID_AUTO_PACK_LEVEL THEN
      l_completion_status := 'WARNING';
      WSH_UTIL_CORE.PrintMsg('Invalid Auto Packing Level');
      l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
      errbuf := 'Auto Pack Deliveries is completed with warning';
      retcode := '1';
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

      WHEN WSH_PK_BATCH_ERR THEN
      l_completion_status := 'WARNING';
      WSH_UTIL_CORE.PrintMsg('Auto Pack Deliveries failed for this batch');
      l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
      errbuf := 'Auto Pack Deliveries is completed with warning';
      retcode := '1';
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;

   WHEN WSH_SELECT_ERR THEN
      l_completion_status := 'WARNING';
      WSH_UTIL_CORE.PrintMsg('Failed to select deliveries for the batch');
      l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
      errbuf := 'Auto Pack Deliveries is completed with warning';
      retcode := '1';
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

   WHEN OTHERS THEN
      l_completion_status := 'ERROR';
      l_error_code   := SQLCODE;
      l_error_text   := SQLERRM;
      WSH_UTIL_CORE.PrintMsg('Auto Pack Deliveries SRS failed with unexpected error.');
      WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || l_error_text);
      l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
      errbuf := 'Auto Pack Deliveries failed with unexpected error';
      retcode := '2';
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
       END IF;
END Auto_Pack_Deliveries_SRS;



PROCEDURE log_batch_messages(p_batch_id IN NUMBER,
               p_delivery_id IN NUMBER,
               p_stop_id     IN NUMBER,
               p_exception_location_id IN NUMBER,
               p_error_status IN VARCHAR2) IS

  c NUMBER;
  i NUMBER;
  l_buffer VARCHAR2(4000);
  l_index_out NUMBER;
  l_return_status  VARCHAR2(1);
  l_msg_count   NUMBER;
  l_msg_data     VARCHAR2(2000);
  l_exception_id   NUMBER;
  l_error_message wsh_exceptions.error_message%type;

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOG_BATCH_MESSAGES';
  --


BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_LOCATION_ID',P_EXCEPTION_LOCATION_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_ERROR_STATUS',P_ERROR_STATUS);
  END IF;

  IF p_batch_id IS NULL THEN
   RETURN;
  END IF;
  -- We populate the error_message column in wsh_exceptions if the exception
  -- was logged for autopack. If the exception was logged for ship confirm we
  -- leave it as NULL.
/*  IF  p_error_status = 'W' THEN

   IF g_error_message is NULL THEN

    g_error_message := substrb(FND_MESSAGE.Get_String('FND', 'FND_MBOX_WARN_CONSTANT'), 1,500);

   END IF;

   l_error_message := g_error_message;

  END IF;*/

  l_error_message := p_error_status;

  c := FND_MSG_PUB.count_msg;
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'COUNT--',c);
  END IF;
  FOR i in 1..c LOOP
  FND_MSG_PUB.get(p_encoded => FND_API.G_FALSE,
          p_msg_index => i,
          p_data => l_buffer,
          p_msg_index_out => l_index_out);
  -- pass only first 2000 characters of l_buffer
-- only for cases when l_buffer is not null
  IF l_buffer IS NOT NULL THEN
    wsh_xc_util.log_exception(p_api_version => 1.0,
               x_return_status => l_return_status,
               x_msg_count => l_msg_count,
               x_msg_data => l_msg_data,
               x_exception_id => l_exception_id,
               p_exception_location_id => p_exception_location_id,
               p_logged_at_location_id => p_exception_location_id,
               p_logging_entity => 'SHIPPER',
               p_logging_entity_id => FND_GLOBAL.USER_ID,
               p_exception_name => 'WSH_BATCH_MESSAGE',
               p_message => substrb(l_buffer,1,2000),
               p_trip_stop_id => p_stop_id,
               p_delivery_id => p_delivery_id,
               p_batch_id  => p_batch_id,
               p_error_message => l_error_message);
-- Bug 2713285
      l_exception_id := null;
    END IF;
  END LOOP;
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --


EXCEPTION
  WHEN OTHERS THEN
  WSH_UTIL_CORE.Default_Handler('WSH_BATCH_PROCESS.log_batch_messages');
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name, 'EXCEPTION: OTHERS');
    END IF;
    --

END log_batch_messages;

-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Select_Delivery_Lines (private within the package)
-- Purpose
--   This procedure select the delivery lines according to the selection criteria and
--   return a list of delivery lines selected.
-- Input Parameters:
-- p_select_criteria        This record stores the selection criteria
-- p_autocreate_deliveries  Indidate whether to autocreate deliveries for the delivery lines
--                          'Y': do autocreate deliveries , 'SP' shipping parameters
--
-- Output Parameters:
-- x_selected_det_tbl        Delivery lines selected
-- x_return_status           Return status
---- ----------------------------------------------------------------------

PROCEDURE Select_Delivery_Lines (
  p_select_criteria        IN  WSH_BATCH_PROCESS.Select_Criteria_Rec,
  p_autocreate_deliveries  IN  VARCHAR2,
  x_selected_det_tbl       OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
  x_return_status          OUT NOCOPY VARCHAR2)
IS
--TCA View Changes Start
 CURSOR get_customer_name(c_customer_id NUMBER) IS
  SELECT   substrb ( party.party_name,  1,  50 )  customer_name
  FROM   hz_parties Party, hz_cust_accounts cust_acct
  WHERE  cust_acct.party_id = party.party_id AND
  cust_acct.cust_account_id = c_customer_id;
--TCA View Changes end

  l_sc_SELECT                    VARCHAR2(3000) := NULL;
  l_sc_FROM                      VARCHAR2(3000) := NULL;
  l_sc_WHERE                     VARCHAR2(3000) := NULL;
  l_sc_FINAL                     VARCHAR2(4000) := NULL;
  l_sub_str                      VARCHAR2(2000);
  l_msg_string                   VARCHAR2(80);
  l_str_length                   NUMBER := 0;
  l_scheduled_ship_date_lo       DATE;
  l_scheduled_ship_date_hi       DATE;
  i                              NUMBER := 0;
  v_delivery_detail_id           NUMBER := 0;
  v_autocreate_deliveries_flag   VARCHAR2(1);
  v_cursorID                     INTEGER;
  v_ignore                       INTEGER;
  l_debug_on                     BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Select_Delivery_Lines';

  --Perf bug 5218515
  v_delivery_detail_id_tbl       DBMS_SQL.NUMBER_TABLE;
  l_fetch_count                  NUMBER := 1000;
  l_start_index                  NUMBER := 1;
  l_records_fetched              NUMBER := 0;
  --
  -- Bug 5624475 and ECO 5676263
  l_line_status                  VARCHAR2(3);
  -- LSP PROJECT : Begin
  l_client_id                    NUMBER;
  l_client_code                  VARCHAR2(10);
  -- LSP PROJECT : End
  --
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
  -- set default return status to SUCCESS
  x_return_status  :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  -- clear up x_selected_det_tbl table
  x_selected_det_tbl.delete;

  IF p_autocreate_deliveries is NULL OR p_autocreate_deliveries='SP' THEN
     -- p_autocreate_deliveries = 'SP', need to join with wsh_shipping_parameters
     l_sc_SELECT := l_sc_SELECT || ' wdd.delivery_detail_id ';
     l_sc_FROM   := l_sc_FROM   || ' wsh_delivery_details wdd , wsh_delivery_assignments_v wda ';
     l_sc_FROM   := l_sc_FROM   || ' , wsh_shipping_parameters wsp ';
     l_sc_WHERE  := l_sc_WHERE  || ' wda.delivery_detail_id = wdd.delivery_detail_id ';
     l_sc_WHERE  := l_sc_WHERE  || ' and wdd.organization_id = wsp.organization_id ';
     l_sc_WHERE  := l_sc_WHERE  || ' and wsp.autocreate_deliveries_flag = ''Y'' ';

  ELSIF  p_autocreate_deliveries = 'Y' THEN
     -- p_autocreate_deliveries = 'Y' do not join with wsh_shipping_parameters
     l_sc_SELECT := l_sc_SELECT || ' wdd.delivery_detail_id ';
     l_sc_FROM   := l_sc_FROM   || ' wsh_delivery_details wdd , wsh_delivery_assignments_v wda ';
     l_sc_WHERE  := l_sc_WHERE  || ' wda.delivery_detail_id = wdd.delivery_detail_id ';

  ELSE
    -- invalud value in p_autocreate_deliveries
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, ' No delivery lines fetched because p_autocreate_deliveries is: '||p_autocreate_deliveries);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    return;
  END IF;

  l_sc_WHERE  := l_sc_WHERE  || ' and wda.delivery_id is null ';
  l_sc_WHERE  := l_sc_WHERE  || ' and wdd.container_flag = ''N'' ';
  l_sc_WHERE  := l_sc_WHERE  || ' and NVL(wdd.line_direction, ''O'') = ''O'' ';


  IF p_select_criteria.delivery_lines_status is not NULL THEN
     IF p_select_criteria.delivery_lines_status = 'ALL' THEN
        l_sc_WHERE  := l_sc_WHERE ||'AND wdd.released_status in (''X'', ''R'', ''S'', ''Y'' , ''B'') '; --Bugfix 9129793 added Backorder status
     ELSE
        l_sc_WHERE  := l_sc_WHERE ||'AND wdd.released_status = :x_released_status ';
     END IF;
     --
     -- Bug 5624475 and ECO 5676263 :
     -- Distinguish between Planned for X-dock status and Released to warehouse
     --
     IF p_select_criteria.delivery_lines_status = 'K' THEN
        l_sc_WHERE := l_sc_WHERE || ' AND wdd.move_order_line_id IS NULL ';
     ELSIF p_select_criteria.delivery_lines_status = 'S' THEN
        l_sc_WHERE := l_sc_WHERE || ' AND wdd.move_order_line_id IS NOT NULL ';
     END IF;
     -- End Bug 5624475 and ECO 5676263
     --
     FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DETAILS_STATUS');
     l_msg_string := NULL;
     l_msg_string := WSH_XC_UTIL.Get_Lookup_Meaning(
                          p_lookup_code => p_select_criteria.delivery_lines_status,
                          p_lookup_type => 'WSH_PD_DEL_LINE_STATUS' );
     FND_MESSAGE.SET_TOKEN('DETAILS_STATUS', l_msg_string);
     FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

     WSH_UTIL_CORE.PrintMsg('  Delivery Lines Status: '|| p_select_criteria.delivery_lines_status);
  END IF;

  -- put organization in the where clause if it is part of selection criteria
  IF p_select_criteria.organization_id IS NOT NULL THEN
     l_sc_WHERE  := l_sc_WHERE ||'AND wdd.organization_id = :x_organization_id ';
     FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_ORGANIZATION');
     FND_MESSAGE.SET_TOKEN('ORGANIZATION_NAME', WSH_UTIL_CORE.Get_Org_Name(p_select_criteria.organization_id));
     FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

     WSH_UTIL_CORE.PrintMsg('  Organization ID: '|| p_select_criteria.organization_id);
  END IF;


  -- put scheduled ship date in the where clause if it is part of selection criteria
  IF p_select_criteria.scheduled_ship_date_lo IS NOT NULL OR p_select_criteria.scheduled_ship_date_hi IS NOT NULL THEN

    IF p_select_criteria.scheduled_ship_date_lo IS NOT NULL AND p_select_criteria.scheduled_ship_date_hi IS NOT NULL THEN
      l_scheduled_ship_date_lo := fnd_date.canonical_to_date(p_select_criteria.scheduled_ship_date_lo);
      l_scheduled_ship_date_hi := fnd_date.canonical_to_date(p_select_criteria.scheduled_ship_date_hi);

      l_sc_WHERE  := l_sc_WHERE ||'AND wdd.date_scheduled BETWEEN :x_scheduled_ship_date_lo AND :x_scheduled_ship_date_hi ';


      FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_SCHD_SHIP_DATE_LO');
      FND_MESSAGE.SET_TOKEN('SCHD_SHIP_DATE_LO', to_char(l_scheduled_ship_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
      FND_FILE.put_line(FND_FILE.output, FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_SCHD_SHIP_DATE_HI');
      FND_MESSAGE.SET_TOKEN('SCHD_SHIP_DATE_HI', to_char(l_scheduled_ship_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
      FND_FILE.put_line(FND_FILE.output, FND_MESSAGE.GET);

      WSH_UTIL_CORE.PrintMsg('  Scheduled Ship Date Start: '|| to_char(l_scheduled_ship_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
      WSH_UTIL_CORE.PrintMsg('  Scheduled Ship Date End: '|| to_char(l_scheduled_ship_date_hi, 'DD-MON-YYYY HH24:MI:SS'));

    ELSIF p_select_criteria.scheduled_ship_date_lo IS NOT NULL THEN
      l_scheduled_ship_date_lo := fnd_date.canonical_to_date(p_select_criteria.scheduled_ship_date_lo);
      l_sc_WHERE  := l_sc_WHERE ||'AND wdd.date_scheduled >= :x_scheduled_ship_date_lo ';

      FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_SCHD_SHIP_DATE_LO');
      FND_MESSAGE.SET_TOKEN('SCHD_SHIP_DATE_LO', to_char(l_scheduled_ship_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
      FND_FILE.put_line(FND_FILE.output, FND_MESSAGE.GET);
      WSH_UTIL_CORE.PrintMsg('  Scheduled Ship Date Start: '|| to_char(l_scheduled_ship_date_lo, 'DD-MON-YYYY HH24:MI:SS'));

    ELSE
      l_scheduled_ship_date_hi := fnd_date.canonical_to_date(p_select_criteria.scheduled_ship_date_hi);
      l_sc_WHERE  := l_sc_WHERE ||'AND wdd.date_scheduled <= :x_scheduled_ship_date_hi ';
      FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_SCHD_SHIP_DATE_HI');
      FND_MESSAGE.SET_TOKEN('SCHD_SHIP_DATE_HI', to_char(l_scheduled_ship_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
      FND_FILE.put_line(FND_FILE.output, FND_MESSAGE.GET);
      WSH_UTIL_CORE.PrintMsg('  Scheduled Ship Date End: '|| to_char(l_scheduled_ship_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
    END IF;
  END IF;

  -- put ship to location id in the where clause if it is part of selection criteria
  IF p_select_criteria.ship_to_loc_id  IS NOT NULL THEN
    l_sc_WHERE  := l_sc_WHERE || 'AND wdd.ship_to_location_id = :x_ship_to_loc_id ';

    l_msg_string := substrb(WSH_UTIL_CORE.Get_Location_Description(
                                   p_location_id => p_select_criteria.ship_to_loc_id,
                                   p_format      => 'NEW UI CODE'),
                                1, 80);

    FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_SHIP_TO');
    FND_MESSAGE.SET_TOKEN('SHIP_TO', l_msg_string);

    FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

    WSH_UTIL_CORE.PrintMsg('  Ship to Location ID: '|| to_char(p_select_criteria.ship_to_loc_id));
  END IF;

  -- put source code in the where clause if it is part of selection criteria
  IF p_select_criteria.source_code IS NOT NULL THEN
     IF p_select_criteria.source_code = 'BOTH' THEN
        l_sc_WHERE  := l_sc_WHERE ||'AND wdd.source_code in (''OE'', ''OKE'') ';
     ELSE
        l_sc_WHERE  := l_sc_WHERE ||'AND wdd.source_code = :x_source_code ';
     END IF;

     l_msg_string := NULL;
     l_msg_string := WSH_XC_UTIL.Get_Lookup_Meaning(
                       p_lookup_code => p_select_criteria.source_code,
                       p_lookup_type => 'WSH_PD_SOURCE_SYSTEM' );
     FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_SOURCE_SYSTEM');
     FND_MESSAGE.SET_TOKEN('SOURCE_NAME', l_msg_string);
     FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
     WSH_UTIL_CORE.PrintMsg('  Source System: '|| p_select_criteria.source_code);
  ELSE
     l_sc_WHERE  := l_sc_WHERE ||'AND wdd.source_code in (''OE'', ''OKE'') ';
  END IF;


  -- put customer id in the where clause if it is part of selection criteria
  IF p_select_criteria.customer_id  IS NOT NULL THEN
    l_sc_WHERE := l_sc_WHERE || 'AND wdd.customer_id = :x_customer_id ';

    l_msg_string := NULL;

    OPEN  get_customer_name(p_select_criteria.customer_id);
    FETCH get_customer_name INTO l_msg_string;
    CLOSE get_customer_name;

    FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_CUSTOMER');
    FND_MESSAGE.SET_TOKEN('CUSTOMER_NAME', l_msg_string);
    FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

    WSH_UTIL_CORE.PrintMsg('  Customer ID: '|| p_select_criteria.customer_id);
  END IF;

  -- put ship method code in the where clause if it is part of selection criteria
  IF p_select_criteria.ship_method_code IS NOT NULL THEN
    l_sc_WHERE := l_sc_WHERE || 'AND wdd.ship_method_code = :x_ship_method_code ';
    FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_SHIP_METHOD');
    l_msg_string := NULL;
    l_msg_string := WSH_XC_UTIL.Get_Lookup_Meaning(
                       p_lookup_code => p_select_criteria.ship_method_code,
                       p_lookup_type => 'SHIP_METHOD' );
    FND_MESSAGE.SET_TOKEN('SHIP_METHOD', l_msg_string);
    FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
    WSH_UTIL_CORE.PrintMsg('  Ship Method Code: '|| p_select_criteria.ship_method_code);
  END IF;

  FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_LOG_LEVEL');
  FND_MESSAGE.SET_TOKEN('LOG_LEVEL', to_char(p_select_criteria.log_level));
  FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
  WSH_UTIL_CORE.PrintMsg('  Log Level: '|| p_select_criteria.log_level);
  --
  -- LSP PROJECT : put client id in the where clause if it is part of selection criteria
  IF p_select_criteria.client_id IS NOT NULL THEN
    l_sc_WHERE   := l_sc_WHERE || 'AND wdd.client_id = :x_client_id ';
    l_msg_string := NULL;
    l_client_id  := p_select_criteria.client_id;
    wms_deploy.get_client_details(
      x_client_id     => l_client_id,
      x_client_name   => l_msg_string,
      x_client_code   => l_client_code,
      x_return_status => x_return_status);
    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in WMS_DEPLOY.GET_CLIENT_DETAILS');
        RETURN;
      END IF;
    END IF;
    FND_MESSAGE.SET_NAME('WSH', 'WSH_CLIENT');
    FND_MESSAGE.SET_TOKEN('CLIENT_NAME', l_msg_string);
    FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
    WSH_UTIL_CORE.PrintMsg('  Client ID: '|| p_select_criteria.client_id);
  END IF;
  -- LSP PROJECT : end
  --

  l_sc_FINAL :=  'SELECT ' ||l_sc_SELECT||' FROM '||l_sc_FROM||' WHERE '||l_sc_WHERE ;


  IF p_select_criteria.log_level > 0 OR l_debug_on THEN
    -- print SELECT statement if deubg is turned on
    i := 1;
    l_str_length := length(l_sc_FINAL);

    LOOP
      IF i > l_str_length THEN
      EXIT;
      END IF;
      l_sub_str := SUBSTR(l_sc_FINAL, i , 80);
      -- l_sub_str := SUBSTR(l_sc_FINAL, i , WSH_UTIL_CORE.G_MAX_LENGTH);
      WSH_UTIL_CORE.PrintMsg(l_sub_str);
      i := i + 80;
      -- i := i + WSH_UTIL_CORE.G_MAX_LENGTH;
    END LOOP;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Bind variables: ');
    WSH_DEBUG_SV.logmsg(l_module_name,'========================');
    WSH_DEBUG_SV.log(l_module_name,'   x_organization_id', to_char(p_select_criteria.organization_id));
    WSH_DEBUG_SV.log(l_module_name,'   x_scheduled_ship_date_lo', to_char(l_scheduled_ship_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
    WSH_DEBUG_SV.log(l_module_name,'   x_scheduled_ship_date_hi', to_char(l_scheduled_ship_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
    WSH_DEBUG_SV.log(l_module_name,'   x_source_code', p_select_criteria.source_code);
    WSH_DEBUG_SV.log(l_module_name,'   x_ship_to_loc_id', to_char(p_select_criteria.ship_to_loc_id));
    WSH_DEBUG_SV.log(l_module_name,'   x_customer_id', to_char(p_select_criteria.customer_id));
    WSH_DEBUG_SV.log(l_module_name,'   x_ship_method_code', p_select_criteria.ship_method_code);
    WSH_DEBUG_SV.log(l_module_name,'   x_released_status', p_select_criteria.delivery_lines_status);
    WSH_DEBUG_SV.log(l_module_name,'   x_client_id', p_select_criteria.client_id);  -- LSP PROJECT
    WSH_DEBUG_SV.logmsg(l_module_name,'========================');
  END IF;

  -- open cursor
  v_CursorID := DBMS_SQL.Open_Cursor;

  -- parse cursor
  DBMS_SQL.Parse(v_CursorID, l_sc_FINAL, DBMS_SQL.v7 );


  -- define column
  --Perf bug 5218515
  DBMS_SQL.Define_Array(v_CursorID, 1,  v_delivery_detail_id_tbl ,l_fetch_count ,l_start_index);

  --
  -- Bug 5624475 and ECO 5676263
  IF p_select_criteria.delivery_lines_status IN ('K', 'S') THEN
   l_line_status := 'S';
  ELSE
   l_line_status := p_select_criteria.delivery_lines_status;
  END IF;
  --
  IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name, ' l_line_status', l_line_status);
   WSH_DEBUG_SV.log(l_module_name, 'p_select_criteria.delivery_lines_status',
                    p_select_criteria.delivery_lines_status);
  END IF;
  --
  IF p_select_criteria.delivery_lines_status IS NOT NULL AND
     p_select_criteria.delivery_lines_status <> 'ALL' THEN
     DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_released_status', l_line_status); -- Bug 5624475 and ECO 5676263
  END IF;

  -- bind the variables for organization id
  IF p_select_criteria.organization_id IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_organization_id', p_select_criteria.organization_id);
  END IF;

  IF p_select_criteria.scheduled_ship_date_lo  IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_scheduled_ship_date_lo', l_scheduled_ship_date_lo);
  END IF;

  IF p_select_criteria.scheduled_ship_date_hi IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_scheduled_ship_date_hi', l_scheduled_ship_date_hi);
  END IF;

  IF p_select_criteria.source_code IS NOT NULL
     AND p_select_criteria.source_code <> 'BOTH' THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_source_code', p_select_criteria.source_code);
  END IF;

  IF p_select_criteria.ship_to_loc_id  IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_ship_to_loc_id', p_select_criteria.ship_to_loc_id);
  END IF;

  IF p_select_criteria.customer_id  IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_customer_id', p_select_criteria.customer_id);
  END IF;

  IF p_select_criteria.ship_method_code IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_ship_method_code', p_select_criteria.ship_method_code);
  END IF;

  -- LSP PROJECT : begin
  IF p_select_criteria.client_id IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_client_id', p_select_criteria.client_id);
  END IF;
  -- LSP PROJECT : end

  -- execute the cursor
  v_ignore := DBMS_SQL.Execute(v_CursorID);

  -- fetching the rows in bulk.
  --Perf bug 5218515
  Loop
     l_records_fetched := dbms_sql.fetch_rows(v_CursorID) ;
     dbms_sql.column_value(v_CursorID,1,v_delivery_detail_id_tbl);
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'   Records Fetched in this pass '|| l_records_fetched);
         WSH_DEBUG_SV.logmsg(l_module_name,'   l_fetch_count '|| l_fetch_count);
         WSH_DEBUG_SV.logmsg(l_module_name,'   Record count in v_delivery_detail_id_tbl '||
                                               v_delivery_detail_id_tbl.count);
     END IF;
     Exit when l_records_fetched <> l_fetch_count ;
  End Loop;

  If v_delivery_detail_id_tbl.count > 0 then
     For i in 1..v_delivery_detail_id_tbl.count
     loop
         x_selected_det_tbl(i) := v_delivery_detail_id_tbl(i);
         If l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'   Fetched delivery line '|| to_char(x_selected_det_tbl(i)));
         End If;
     End Loop;
  End If;

  IF v_cursorID <> 0 THEN
     If l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'  Before closing cursor = '||v_cursorID );
     End If;

     DBMS_SQL.Close_Cursor(v_cursorID);

     If l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'  After closing cursor = '||v_cursorID );
     End If;
  END IF;
  -- done fetching
  -- print debug messages

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, to_char(x_selected_det_tbl.count)||' delivery lines fetched to be processed');
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

  WHEN others THEN
    -- if the cursor is still open then close the cursor
    IF v_cursorID <> 0 THEN
       DBMS_SQL.Close_Cursor(v_cursorID);
    END IF;
    wsh_util_core.default_handler('WSH_BATCH_PROCESS.Select_Deliveries');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

END Select_Delivery_Lines;

-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Process_Delivery_Lines_Batch(private within the package)
-- Purpose
--   This procedure works on a list of delivery lines, append these lines to existing
--   deliveries and autocreate deliveries for the lines not appended.
--
-- Input Parameters:
--
--   p_selected_det_tbl    List of delivery lines selected
--   p_append_flag         Indicate if it needs to append deliveries or not
--                         'Y': append deliveries, 'SP': check the value in shipping parameters
--   p_ac_del_criteria     Indicate if deliveries can across order or not
--                         'Y': Within an Order
--                         'N': Across Orders
-- Output Parameters:
--   x_appended_det_num       Number of delivery lines appended
--   x_autocreate_del_det_num Number of delivery lines submitted to autocreate deliveries
--   x_new_del_num            Number of deliveries created
--   x_msg_count              Message count
--   x_msg_data               Message data
--   x_return_status          Return status
---- ----------------------------------------------------------------------

PROCEDURE Process_Delivery_Lines_Batch(
   p_selected_det_tbl       IN WSH_UTIL_CORE.Id_Tab_Type,
   p_append_flag            IN VARCHAR2,
   p_ac_del_criteria        IN VARCHAR2,
   x_appended_det_num       OUT NOCOPY NUMBER,
   x_autocreate_del_det_num OUT NOCOPY NUMBER,
   x_appended_del_num       OUT NOCOPY NUMBER,
   x_new_del_num            OUT NOCOPY NUMBER,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   x_return_status          OUT NOCOPY VARCHAR2) IS

   l_delivery_detail_tbl       WSH_UTIL_CORE.Id_Tab_Type;
   l_appended_del_tbl          WSH_UTIL_CORE.Id_Tab_Type;
   l_appended_det_tbl          WSH_DELIVERY_DETAILS_UTILITIES.delivery_assignment_rec_tbl;
   l_unappended_det_tbl        WSH_UTIL_CORE.Id_Tab_Type;
   l_append_flag               VARCHAR2(1);
   l_ac_del_criteria           VARCHAR2(1);
   l_action_prms               wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;
   l_action_out_rec            wsh_glbl_var_strct_grp.dd_action_out_rec_type;
   l_msg_count                 NUMBER := 0;
   l_msg_data                  VARCHAR2(32767) := NULL;
   l_return_status             VARCHAR2(1);
   l_warning_num               NUMBER := 0;
   l_number_of_warnings        NUMBER := 0;
   l_number_of_errors          NUMBER := 0;
   --
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Delivery_Lines_Batch';
   --
   append_to_deliveries_failed   EXCEPTION;
   autocreate_delivery_failed    EXCEPTION;

BEGIN
   SAVEPOINT BEFORE_PROCESS_DELIVERIES;
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   x_appended_det_num       := 0;
   x_autocreate_del_det_num := 0;
   x_new_del_num            := 0;
   l_appended_det_tbl.delete;
   l_unappended_det_tbl.delete;

   -- print input parameter if debug is turned on
   IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Input Parameters:',WSH_DEBUG_SV.C_PROC_LEVEL);
        WSH_DEBUG_SV.logmsg(l_module_name,'   p_append_flag: '|| p_append_flag,WSH_DEBUG_SV.C_PROC_LEVEL);
        WSH_DEBUG_SV.logmsg(l_module_name,'   p_ac_del_criteria: '|| p_ac_del_criteria,WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;

   -- set append flag
   IF p_append_flag = 'SP' THEN
      l_append_flag := NULL;
   ELSE
      l_append_flag := p_append_flag;
   END IF;

   -- set autocreate delivery criteria
   IF p_ac_del_criteria = 'SP' THEN
      l_ac_del_criteria := NULL;
   ELSE
      l_ac_del_criteria := p_ac_del_criteria;
   END IF;



   -- calling WSH_DELIVERY_DETAILS_UTILITIES.Append_to_Deliveries
   IF l_append_flag is NULL or l_append_flag = 'Y' THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit DELIVERY_DETAILS_UTILITIES.Append_to_Deliveries',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      WSH_DELIVERY_DETAILS_UTILITIES.Append_to_Deliveries(
            p_delivery_detail_tbl     => p_selected_det_tbl,
            p_append_flag             => l_append_flag,
            p_group_by_header         => l_ac_del_criteria,
            p_commit                  => FND_API.G_FALSE,
            p_lock_rows               => FND_API.G_TRUE,
            p_check_fte_compatibility => FND_API.G_TRUE,
            x_appended_det_tbl        => l_appended_det_tbl,
            x_unappended_det_tbl      => l_unappended_det_tbl,
            x_appended_del_tbl        => l_appended_del_tbl,
            x_return_status           => l_return_status);

      FND_MSG_PUB.Count_And_Get
         (
            p_count =>  l_msg_count,
            p_data  =>  l_msg_data,
            p_encoded => FND_API.G_FALSE
         );
         x_appended_det_num := l_appended_det_tbl.count;
         x_msg_count := l_msg_count;
         x_msg_data := l_msg_data;

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Return status from DELIVERY_DETAILS_UTILITIES.Append_to_Deliveries: '|| l_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      -- handle return status from WSH_DELIVERY_DETAILS_UTILITIES.Append_to_Deliveries
      IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
         raise append_to_deliveries_failed;
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         l_warning_num := l_warning_num + 1;
      END IF;

   ELSIF l_append_flag = 'N' THEN
      l_unappended_det_tbl.delete;
      l_unappended_det_tbl := p_selected_det_tbl;
   ELSE
      raise append_to_deliveries_failed;
   END IF;

   IF l_unappended_det_tbl.count > 0 THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTERFACE_GRP.DELIVERY_DETAIL_ACTION',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      -- calling wsh_interface_grp.delivery_detail_action with action code 'AUTOCREATE-DEL'
      l_action_prms.caller := 'WSH_DEPS';
      l_action_prms.action_code := 'AUTOCREATE-DEL';
      l_action_prms.group_by_header_flag := l_ac_del_criteria;

      wsh_interface_grp.delivery_detail_action(
           p_api_version_number    => 1.0,
           p_init_msg_list         => FND_API.G_FALSE,
           p_commit                => FND_API.G_FALSE,
           x_return_status         => l_return_status,
           x_msg_count             => l_msg_count,
           x_msg_data              => l_msg_data,
           p_detail_id_tab         => l_unappended_det_tbl,
           p_action_prms           => l_action_prms ,
           x_action_out_rec        => l_action_out_rec);

       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Return status from WSH_INTERFACE_GRP.DELIVERY_DETAIL_ACTION:'|| l_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       x_autocreate_del_det_num := l_unappended_det_tbl.count;
       x_appended_del_num       := l_appended_del_tbl.count;
       x_new_del_num := l_action_out_rec.delivery_id_tab.count;
       x_msg_count := x_msg_count + l_number_of_warnings + l_number_of_errors;
       x_msg_data := x_msg_data || l_msg_data;

       -- handle return status from wsh_interface_grp.delivery_detail_action
       IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          raise autocreate_delivery_failed;
       ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          l_warning_num := l_warning_num + 1;
       END IF;

       IF l_warning_num > 0 THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       END IF;


    END IF;

    COMMIT;


    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;

   EXCEPTION

      WHEN append_to_deliveries_failed THEN
         ROLLBACK TO BEFORE_PROCESS_DELIVERIES;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'APPEND_TO_DELIVERIES_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APPEND_TO_DELIVERIES_FAILED');
         END IF;

      WHEN autocreate_delivery_failed THEN
         ROLLBACK TO BEFORE_PROCESS_DELIVERIES;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'AUTOCREATE_DELIVERY_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:AUTOCREATE_DELIVERY_FAILED');
         END IF;

      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         ROLLBACK TO BEFORE_PROCESS_DELIVERIES;
         wsh_util_core.add_message(x_return_status, l_module_name);
         WSH_UTIL_CORE.default_handler('WSH_BATCH_PROCESS.Process_Delivery_Lines_Batch');
         FND_MSG_PUB.Count_And_Get
            (
               p_count  => x_msg_count,
               p_data  =>  x_msg_data,
               p_encoded => FND_API.G_FALSE
            );

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;

END Process_Delivery_Lines_Batch;

-- -----------------------------------------------------------------------
-- Name
--   PROCEDURE Process_Deliveries_SRS
-- Purpose
--   This procedure is the entry procedure of Process Delivery SRS program
--   It creates consolidated trips for the deliveries if p_entity_type = 'D'
--   (Deliveries Only)
--   and create deliveries for the delivery lines if p_entity_type = 'L' (Delivery Lines Only)
--
-- Input Parameters:
--
--   p_entity_type             Entity type, either 'D'(Deliveries Only) or 'L'(Delivery Lines Only)
--   p_delivery_lines_status   Delivery Lines selection criteria: Delivery line status
--   p_deliveries_status       Deliveries selection criteria: Delivery Status
--   p_scheduled_ship_date_lo  Delivery Lines selection criteria: Scheduled Ship Date Start
--   p_scheduled_ship_date_hi  Delivery Lines selection criteria: Scheduled Ship Date End
--   p_source_system           Delivery Lines selection criteria: Source System
--   p_pickup_date_lo          Deliveries selection criteria: Pickup Date Start
--   p_pickup_date_hi          Deliveries selection criteria: Pickup Date End
--   p_dropoff_date_lo         Deliveries selection criteria: Dropoff Date Start
--   p_dropoff_date_hi         Deliveries selection criteria: Dropoff Date End
--   p_client_id               Selection criteria for both delivery lines and deliveries ,Client for LSP --Modified R12.1.1 LSP PROJECT
--   p_organization_id         Selection criteria for both delivery lines and deliveries
--   p_customer_id             Selection criteria for both delivery lines and deliveries
--   p_ship_to_loc_id          Selection criteria for both delivery lines and deliveries
--   p_ship_method_code        Selection criteria for both delivery lines and deliveries
--   p_autocreate_deliveries   Delivery Lines Only: 'Y': autocreate deliveries, 'SP': Shipping Parameter
--   p_ac_del_criteria         Delivery Lines Only: 'Y': Within An order, 'N': Across Order, 'SP': Shipping Parameter
--   p_append_deliveries       Delivery Lines Only: 'Y': append deliveries,'N': do not append deliveries 'SP':Shipping Parameter
--   p_grp_ship_method         Deliveries Only: 'Y': group deliveries by ship method 'N': do not use ship method to group deliveries
--   p_grp_ship_from           Deliveries Only: 'Y': group deliveries by ship from 'N': do not use ship from to group deliveries
--   p_max_number              Deliveries Only: Max number of deliveries per trip
--   p_log_level               0: debug log off, 1: debug log on
--
-- Output Parameters:
--   errbuf                    Starndard parameter
--   retcode                   Starndard parameter
---- ----------------------------------------------------------------------
--
PROCEDURE Process_Deliveries_SRS(
  errbuf                         OUT NOCOPY VARCHAR2,
  retcode                        OUT NOCOPY VARCHAR2,
  p_entity_type                  IN VARCHAR2,
  p_delivery_lines_status        IN VARCHAR2,
  p_deliveries_status            IN VARCHAR2,
  p_scheduled_ship_date_lo       IN VARCHAR2,
  p_scheduled_ship_date_hi       IN VARCHAR2,
  p_source_system                IN VARCHAR2,
  p_pickup_date_lo               IN VARCHAR2,
  p_pickup_date_hi               IN VARCHAR2,
  p_dropoff_date_lo              IN VARCHAR2,
  p_dropoff_date_hi              IN VARCHAR2,
  p_deploy_mode                  IN VARCHAR2,  -- Modified R12.1.1 LSP PROJECT
  p_client_id                    IN NUMBER, --Modified R12.1.1 LSP PROJECT
  p_organization_id              IN NUMBER,
  p_customer_id                  IN VARCHAR2,
  p_ship_to_loc_id               IN NUMBER,
  p_ship_method_code             IN VARCHAR2,
  p_autocreate_deliveries        IN VARCHAR2,
  p_ac_del_criteria              IN VARCHAR2,
  p_append_deliveries            IN VARCHAR2,
  p_grp_ship_method              IN VARCHAR2,
  p_grp_ship_from                IN VARCHAR2,
  p_max_del_number               IN NUMBER,
  p_log_level                    IN NUMBER ) IS


 --TCA View Changes Start
CURSOR get_customer_name(c_customer_id NUMBER) IS
  SELECT   substrb ( party.party_name,  1,  50 )  customer_name
  FROM   hz_parties Party, hz_cust_accounts cust_acct
  WHERE  cust_acct.party_id = party.party_id AND
  cust_acct.cust_account_id = c_customer_id;
  --TCA View Changes end

 CURSOR get_appending_limit (c_organization_id NUMBER) IS
  SELECT appending_limit
  FROM wsh_shipping_parameters
  WHERE organization_id = c_organization_id;

  l_completion_status            VARCHAR2(30);
  l_error_code                   NUMBER;
  l_error_text                   VARCHAR2(2000);
  l_log_level                    NUMBER := 0;
  l_return_status                VARCHAR2(30) := NULL;
  l_temp                         BOOLEAN;
  l_debug_on                     BOOLEAN;
  l_select_criteria              WSH_BATCH_PROCESS.Select_Criteria_Rec;
  l_appended_det_num             NUMBER;
  l_appended_del_num             NUMBER;
  l_autocreate_del_det_num       NUMBER;
  l_selected_det_tbl             WSH_UTIL_CORE.Id_Tab_Type;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(32767);
  l_new_del_num                  NUMBER;
  l_del_num                      NUMBER;
  l_del_grouped_num              NUMBER;
  l_trip_num                     NUMBER;
  l_pickup_date_lo               DATE;
  l_pickup_date_hi               DATE;
  l_dropoff_date_lo              DATE;
  l_dropoff_date_hi              DATE;
  l_scheduled_date_lo            DATE;
  l_scheduled_date_hi            DATE;
  l_autocreate_deliveries        VARCHAR2(30);
  l_append_deliveries            VARCHAR2(30);
  l_ac_del_criteria              VARCHAR2(30);
  l_deliveries_status            VARCHAR2(30);
  l_grp_ship_method              VARCHAR2(1);
  l_grp_ship_from                VARCHAR2(1);
  l_appending_limit              VARCHAR2(1);
  l_msg_string                   VARCHAR2(80);
  l_msg_date                     DATE;
  l_max_del_number               NUMBER;
  l_module_name CONSTANT         VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Deliveries_SRS';
  l_buffer VARCHAR2(4000);
  l_index_out NUMBER;
  WSH_SELECT_ERR                 EXCEPTION;
  Process_Delivery_Lines_ERR     EXCEPTION;
  Create_Consolidated_Trips_ERR  EXCEPTION;
  Parameters_ERR                 EXCEPTION;

  l_processed  number ;
  l_inner_loop_count number ;
  l_selected_det_tbl_tmp         WSH_UTIL_CORE.Id_Tab_Type;
  g_selected_det_count           number :=0;
  g_appended_det_num             number :=0;
  g_appended_del_num             number :=0;
  g_autocreate_del_det_num       number :=0;
  g_new_del_num                  number :=0;

  l_client_id NUMBER; -- Modified R12.1.1 LSP PROJECT
  l_client_code  VARCHAR2(10);  -- Modified R12.1.1 LSP PROJECT

BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
     wsh_debug_sv.push(l_module_name);
     wsh_debug_sv.logmsg(l_module_name,'Input Parameters: ');
     wsh_debug_sv.logmsg(l_module_name,'=================================');
     wsh_debug_sv.log(l_module_name,'p_entity_type', p_entity_type);
     wsh_debug_sv.log(l_module_name,'p_append_deliveries',p_append_deliveries);
     wsh_debug_sv.log(l_module_name,'p_deliveries_status',p_deliveries_status);
     wsh_debug_sv.log(l_module_name,'p_scheduled_ship_date_lo',p_scheduled_ship_date_lo);
     wsh_debug_sv.log(l_module_name,'p_scheduled_ship_date_hi',p_scheduled_ship_date_hi);
     wsh_debug_sv.log(l_module_name,'p_source_system',p_source_system);
     wsh_debug_sv.log(l_module_name,'p_pickup_date_lo',p_pickup_date_lo);
     wsh_debug_sv.log(l_module_name,'p_pickup_date_hi',p_pickup_date_hi);
     wsh_debug_sv.log(l_module_name,'p_dropoff_date_lo',p_dropoff_date_lo);
     wsh_debug_sv.log(l_module_name,'p_dropoff_date_hi',p_dropoff_date_hi);
     wsh_debug_sv.log(l_module_name,'p_deploy_mode',p_deploy_mode);
     wsh_debug_sv.log(l_module_name,'p_client_id',p_client_id);
     wsh_debug_sv.log(l_module_name,'p_organization_id',p_organization_id);
     wsh_debug_sv.log(l_module_name,'p_customer_id',p_customer_id);
     wsh_debug_sv.log(l_module_name,'p_ship_to_loc_id',p_ship_to_loc_id);
     wsh_debug_sv.log(l_module_name,'p_ship_method_code',p_ship_method_code);
     wsh_debug_sv.log(l_module_name,'p_autocreate_deliveries',p_autocreate_deliveries);
     wsh_debug_sv.log(l_module_name,'p_ac_del_criteria',p_ac_del_criteria);
     wsh_debug_sv.log(l_module_name,'p_append_deliveries',p_append_deliveries);
     wsh_debug_sv.log(l_module_name,'p_grp_ship_method',p_grp_ship_method);
     wsh_debug_sv.log(l_module_name,'p_grp_ship_from',p_grp_ship_from);
     wsh_debug_sv.log(l_module_name,'p_max_del_number',p_max_del_number);
     wsh_debug_sv.log(l_module_name,'p_log_level',p_log_level);
  END IF;




  -- set the completion status to NORMAL
  l_completion_status := 'NORMAL';

  IF p_log_level IS NULL THEN
     l_log_level := 0;
  ELSE
     l_log_level := p_log_level;
  END IF;

  -- enable printing of the concurrent request
  WSH_UTIL_CORE.Enable_Concurrent_Log_Print;
  -- set the log level for the whole session
  WSH_UTIL_CORE.Set_Log_Level(l_log_level);


  FND_MESSAGE.SET_NAME('WSH','WSH_PD_PARM');
  FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
  FND_FILE.put_line(FND_FILE.output,'====================');

  FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_PROCESSED_ENTITIES');
  l_msg_string := WSH_XC_UTIL.Get_Lookup_Meaning(
                     p_lookup_code => p_entity_type,
                     p_lookup_type => 'WSH_PD_ENTITY'  );
  FND_MESSAGE.SET_TOKEN('ENTITY_TYPE', l_msg_string);
  FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);


  -- print required input parameters
  WSH_UTIL_CORE.PrintMsg('Input Parameters: ' );
  WSH_UTIL_CORE.PrintMsg('  Processed Entities: '|| p_entity_type);

  IF p_entity_type = 'D' THEN
     --
     IF WSH_UTIL_CORE.TP_Is_Installed = 'Y' THEN
        FND_FILE.put_line(FND_FILE.output, '      ');
        FND_FILE.put_line(FND_FILE.output, '      ');
        -- print the summary results of auto create trips action
        FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_TRIP_CONSOLIDATION');
        FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
        WSH_UTIL_CORE.PrintMsg('Trip Consolidation is disabled because Transportation Planning is installed. ');
     ELSE
        --
        l_pickup_date_lo  := fnd_date.canonical_to_date(p_pickup_date_lo);
        l_pickup_date_hi  := fnd_date.canonical_to_date(p_pickup_date_hi);
        l_dropoff_date_lo := fnd_date.canonical_to_date(p_dropoff_date_lo);
        l_dropoff_date_hi := fnd_date.canonical_to_date(p_dropoff_date_hi);

        -- bug 3319789
        IF p_scheduled_ship_date_lo is not NULL OR
           p_scheduled_ship_date_hi is not NULL THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_SCHD_DATE_NOT_ALLOWED');
           FND_FILE.put_line(FND_FILE.output,'   ');
	   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           WSH_UTIL_CORE.PrintMsg('Scheduled Ship Date parameters are not applicable for entity Deliveries Only. Please do not enter Sheduled Ship Date range when selecting entity Deliveries Only.');
           raise Parameters_ERR;
        END IF;

        -- Deliveries Only, auto create trips

        -- default value : Set Deliveries Status to 'BOTH'
        IF p_deliveries_status IS NULL THEN
           l_deliveries_status := 'BOTH';
        ELSE
           l_deliveries_status := p_deliveries_status;
        END IF;

        -- default value : Set Group Deliveries by Ship Method to 'Y'
        IF p_grp_ship_method IS NULL THEN
           l_grp_ship_method := 'Y';
        ELSE
           l_grp_ship_method := p_grp_ship_method;
        END IF;

        -- default value : Set Group Deliveries by Ship From Organization to 'Y'
        IF p_grp_ship_from IS NULL THEN
           l_grp_ship_from := 'Y';
        ELSE
           l_grp_ship_from := p_grp_ship_from;
        END IF;

        -- default value : Set Maximum Number of Deliveries per Trip to 50
        IF p_max_del_number IS NULL THEN
           l_max_del_number := 50;
        ELSE
           l_max_del_number  := p_max_del_number;
        END IF;


        -- print Input Parameters

        IF l_deliveries_status IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DELIVERIES_STATUS');
           l_msg_string := NULL;
           l_msg_string := WSH_XC_UTIL.Get_Lookup_Meaning(
                             p_lookup_code => p_deliveries_status,
                             p_lookup_type => 'WSH_PD_DEL_STATUS' );
           FND_MESSAGE.SET_TOKEN('DELIVERIES_STATUS', l_msg_string);
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           WSH_UTIL_CORE.PrintMsg('  Deliveries Status: '|| l_deliveries_status);
        END IF;

        IF p_pickup_date_lo IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_PICKUP_DATE_LO');
           FND_MESSAGE.SET_TOKEN('PICKUP_DATE_LO', to_char(l_pickup_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           WSH_UTIL_CORE.PrintMsg('  Pick Up Date Start: '|| to_char(l_pickup_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
        END IF;

        IF p_pickup_date_hi IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_PICKUP_DATE_HI');
           FND_MESSAGE.SET_TOKEN('PICKUP_DATE_HI', to_char(l_pickup_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           WSH_UTIL_CORE.PrintMsg('  Pick Up Date End: '|| to_char(l_pickup_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
        END IF;

        -- bug 3332670
        IF p_pickup_date_hi is NOT NULL and
           p_pickup_date_lo is NOT NULL THEN
           IF l_pickup_date_hi < l_pickup_date_lo THEN
             FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_PICKUP_DATE_RANGE');
             FND_MESSAGE.SET_TOKEN('PICKUP_DATE_LO', to_char(l_pickup_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
             FND_MESSAGE.SET_TOKEN('PICKUP_DATE_HI', to_char(l_pickup_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
       	     FND_FILE.put_line(FND_FILE.output,'   ');
       	     FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
             WSH_UTIL_CORE.PrintMsg('The end date of Pick Up Date range '||to_char(l_pickup_date_hi, 'DD-MON-YYYY HH24:MI:SS')||' should not precede the start date '|| to_char(l_pickup_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
             raise Parameters_ERR;
           END IF;
        END IF;

        IF p_dropoff_date_lo IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DROPOFF_DATE_LO');
           FND_MESSAGE.SET_TOKEN('DROPOFF_DATE_LO', to_char(l_dropoff_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           WSH_UTIL_CORE.PrintMsg('  Drop Off Date Start: '|| to_char(l_dropoff_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
        END IF;

        IF p_dropoff_date_hi IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DROPOFF_DATE_HI');
           FND_MESSAGE.SET_TOKEN('DROPOFF_DATE_HI', to_char(l_dropoff_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           WSH_UTIL_CORE.PrintMsg('  Drop Off Date End: '|| to_char(l_dropoff_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
        END IF;

        -- bug 3332670
        IF p_dropoff_date_hi is NOT NULL and
           p_dropoff_date_lo is NOT NULL THEN
           IF l_dropoff_date_hi < l_dropoff_date_lo THEN
             FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DROPOFF_DATE_RANGE');
             FND_MESSAGE.SET_TOKEN('DROPOFF_DATE_LO', to_char(l_dropoff_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
             FND_MESSAGE.SET_TOKEN('DROPOFF_DATE_HI', to_char(l_dropoff_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
       	     FND_FILE.put_line(FND_FILE.output,'   ');
       	     FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
             WSH_UTIL_CORE.PrintMsg('The end date of Drop Off Date range '||to_char(l_dropoff_date_hi, 'DD-MON-YYYY HH24:MI:SS')||' should not precede the start date '|| to_char(l_dropoff_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
             raise Parameters_ERR;
           END IF;
        END IF;

        /*Modified R12.1.1 LSP PROJECT*/
        IF p_client_id  IS NOT NULL THEN
           l_client_id := p_client_id;
           wms_deploy.get_client_details(
                                    x_client_id     => l_client_id,
                                    x_client_name   => l_msg_string,
                                    x_client_code   => l_client_code,
                                    x_return_status => l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       --{
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in WMS_DEPLOY.GET_CLIENT_DETAILS');
           END IF;
           END IF;

           FND_MESSAGE.SET_NAME('WSH', 'WSH_CLIENT');
           FND_MESSAGE.SET_TOKEN('CLIENT_NAME', l_msg_string);
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           WSH_UTIL_CORE.PrintMsg('  Client ID: '|| (p_client_id));
        END IF;
        /*Modified R12.1.1 LSP PROJECT*/

        IF p_organization_id  IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_ORGANIZATION');
           FND_MESSAGE.SET_TOKEN('ORGANIZATION_NAME', WSH_UTIL_CORE.Get_Org_Name(p_organization_id));
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           WSH_UTIL_CORE.PrintMsg('  Organization ID: '|| to_char(p_organization_id));
        END IF;

        IF p_customer_id  IS NOT NULL THEN

           OPEN  get_customer_name(p_customer_id);
           FETCH get_customer_name INTO l_msg_string;
           CLOSE get_customer_name;

           FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_CUSTOMER');
           FND_MESSAGE.SET_TOKEN('CUSTOMER_NAME', l_msg_string);
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           --bug fix 3286811
           WSH_UTIL_CORE.PrintMsg('  Customer ID: '|| (p_customer_id));
        END IF;

        IF p_ship_to_loc_id  IS NOT NULL THEN
           l_msg_string := substrb(WSH_UTIL_CORE.Get_Location_Description(
                                      p_location_id => p_ship_to_loc_id,
                                      p_format      => 'NEW UI CODE'),
                                   1, 80);

           FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_SHIP_TO');
           FND_MESSAGE.SET_TOKEN('SHIP_TO', l_msg_string);
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           WSH_UTIL_CORE.PrintMsg('  Ship to Location ID: '|| to_char(p_ship_to_loc_id));
        END IF;

        IF p_ship_method_code  IS NOT NULL THEN

           FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_SHIP_METHOD');
           l_msg_string := NULL;
           l_msg_string := WSH_XC_UTIL.Get_Lookup_Meaning(
                             p_lookup_code => p_ship_method_code,
                             p_lookup_type => 'SHIP_METHOD' );
           FND_MESSAGE.SET_TOKEN('SHIP_METHOD', l_msg_string);
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           WSH_UTIL_CORE.PrintMsg('  Ship Method Code: '|| p_ship_method_code);
        END IF;

        IF l_grp_ship_method  IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_GRP_SHIP_METHOD');
           l_msg_string := NULL;
           l_msg_string := WSH_XC_UTIL.Get_Lookup_Meaning(
                             p_lookup_code => l_grp_ship_method,
                             p_lookup_type => 'YES_NO' );
           FND_MESSAGE.SET_TOKEN('GRP_SHIP_METHOD', l_msg_string);
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           WSH_UTIL_CORE.PrintMsg('  Group Deliveries by Ship Method: '|| l_grp_ship_method);
        END IF;

        IF l_grp_ship_from  IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_GRP_SHIP_FROM');
           l_msg_string := NULL;
           l_msg_string := WSH_XC_UTIL.Get_Lookup_Meaning(
                             p_lookup_code => l_grp_ship_from,
                             p_lookup_type => 'YES_NO' );
           FND_MESSAGE.SET_TOKEN('GRP_SHIP_FROM', l_msg_string);
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           WSH_UTIL_CORE.PrintMsg('  Group Deliveries by Ship from Organization: '|| l_grp_ship_from);
        END IF;

        IF l_max_del_number  IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_MAX_DEL_NUMBER');
           FND_MESSAGE.SET_TOKEN('MAX_DEL_NUMBER', to_char(l_max_del_number));
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           WSH_UTIL_CORE.PrintMsg('  Maximum Number of Deliveries per Trip: '|| to_char(l_max_del_number));
        END IF;

        IF l_log_level  IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_LOG_LEVEL');
           FND_MESSAGE.SET_TOKEN('LOG_LEVEL', to_char(l_log_level));
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
           WSH_UTIL_CORE.PrintMsg('  Log Level: '|| l_log_level );
        END IF;

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling WSH_TRIP_CONSOLIDATION.Create_Consolidated_Trips',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        -- calling WSH_TRIP_CONSOLIDATION.Create_Consolidated_Trips to create trips
        WSH_TRIP_CONSOLIDATION.Create_Consolidated_Trips(
            p_deliv_status       => l_deliveries_status,
            p_pickup_start       => l_pickup_date_lo,
            p_pickup_end         => l_pickup_date_hi,
            p_dropoff_start      => l_dropoff_date_lo,
            p_dropoff_end        => l_dropoff_date_hi,
            p_client_id          => p_client_ID,  --Modified R12.1.1 LSP PROJECT
            p_ship_from_org_id   => p_organization_id,
            p_customer_id        => p_customer_id,
            p_ship_to_location   => p_ship_to_loc_id,
            p_ship_method_code   => p_ship_method_code,
            p_grp_ship_method    => l_grp_ship_method,
            p_grp_ship_from      => l_grp_ship_from,
            p_max_num_deliveries => l_max_del_number,
            x_TotDeliveries      => l_del_num,
            x_SuccessDeliv       => l_del_grouped_num,
            x_Trips              => l_trip_num,
            x_return_status      => l_return_status);

         -- print the summary results of auto create trips action
         FND_FILE.put_line(FND_FILE.output,'     ');
         FND_FILE.put_line(FND_FILE.output,'     ');
         FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_SUMMARY');
         FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
         FND_FILE.put_line(FND_FILE.output,'====================');

         FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DELIVERIES_SELECTED');
         FND_MESSAGE.SET_TOKEN('NUMBER_OF_DELIVERIES', to_char(l_del_num));
         FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

         FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DELIVERIES_GROUPED');
         FND_MESSAGE.SET_TOKEN('NUMBER_OF_DELIVERIES', to_char(l_del_grouped_num));
         FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

         FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_TRIPS_CREATED');
         FND_MESSAGE.SET_TOKEN('NUMBER_OF_TRIPS', to_char(l_trip_num));
         FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

         WSH_UTIL_CORE.PrintDateTime;
         WSH_UTIL_CORE.PrintMsg('Summary: ');
         WSH_UTIL_CORE.PrintMsg(to_char(l_del_num)|| ' deliveries selected for processing');
         WSH_UTIL_CORE.PrintMsg(to_char(l_del_grouped_num)||' deliveries have been grouped to new trips');
         WSH_UTIL_CORE.PrintMsg(to_char(l_trip_num)||' trips have been successfully created');

         -- print return status of autocreate trips
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Return status from WSH_TRIP_CONSOLIDATION.Create_Consolidated_Trips is '|| l_return_status ,WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
                FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DEL_ERROR');
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DEL_WARNING');
            END IF;

            FND_FILE.put_line(FND_FILE.output,'     ');
            FND_FILE.put_line(FND_FILE.output,'     ');
            FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

            -- print warning or error messages Process_Delivery_Lines_Batch
            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_MESSAGE_LIST');
               FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
               FND_FILE.put_line(FND_FILE.output,'====================');
               WSH_UTIL_CORE.PrintMsg('List of Messages: ');
               WSH_UTIL_CORE.PrintMsg('====================');
               FOR i in 1..l_msg_count LOOP
                  FND_MSG_PUB.get(p_encoded => FND_API.G_FALSE,
                     p_msg_index => i,
                     p_data => l_buffer,
                     p_msg_index_out => l_index_out);
                  IF l_buffer IS NOT NULL THEN
                     FND_FILE.put_line(FND_FILE.output,substrb(l_buffer,1,2000));
                     WSH_UTIL_CORE.PrintMsg(substrb(l_buffer,1,2000));
                  END IF;
               END LOOP;

            END IF;
            raise Create_Consolidated_Trips_ERR;
         END IF;

      END IF;  -- TP is not installed
  ELSE

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling Select_Deliveries_Lines ',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     -- bug 3319789
     IF p_pickup_date_lo is not NULL OR
        p_pickup_date_hi is not NULL THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_PICKUP_DATE_NOT_ALLOWED');
        FND_FILE.put_line(FND_FILE.output,'   ');
	FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
        WSH_UTIL_CORE.PrintMsg('Pick Up Date parameters are not applicable for entity Delivery Lines Only. Please do not enter Pick Up Date range when selecting entity Delivery Lines Only.');
        raise Parameters_ERR;
     END IF;

     -- bug 3319789
     IF p_dropoff_date_lo is not NULL OR
        p_dropoff_date_hi is not NULL THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_DROPOFF_DATE_NOT_ALLOWED');
        FND_FILE.put_line(FND_FILE.output,'   ');
	FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
        WSH_UTIL_CORE.PrintMsg('Drop Off Date parameters are not applicable for entity Delivery Lines Only. Please do not enter Drop Off Date range when selecting entity Delivery Lines Only.');
        raise Parameters_ERR;
     END IF;

     -- set default value of Delivery Lines Status to 'ALL'
     IF p_delivery_lines_status IS NULL THEN
        l_select_criteria.delivery_lines_status  := 'ALL';
     ELSE
        l_select_criteria.delivery_lines_status  := p_delivery_lines_status;
     END IF;

     -- bug 3332670
     IF p_scheduled_ship_date_lo is not NULL AND
        p_scheduled_ship_date_hi is not NULL THEN
        l_scheduled_date_lo := fnd_date.canonical_to_date(p_scheduled_ship_date_lo);
        l_scheduled_date_hi := fnd_date.canonical_to_date(p_scheduled_ship_date_hi);
        IF l_scheduled_date_hi < l_scheduled_date_lo THEN
             FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_SCH_SHIP_DATE_RANGE');
             FND_MESSAGE.SET_TOKEN('SCHEDULED_DATE_LO', to_char(l_scheduled_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
             FND_MESSAGE.SET_TOKEN('SCHEDULED_DATE_HI', to_char(l_scheduled_date_hi, 'DD-MON-YYYY HH24:MI:SS'));
       	     FND_FILE.put_line(FND_FILE.output,'   ');
       	     FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
             WSH_UTIL_CORE.PrintMsg('The end date of Scheduled Ship Date range '||to_char(l_scheduled_date_hi, 'DD-MON-YYYY HH24:MI:SS')||' should not precede the start date '|| to_char(l_scheduled_date_lo, 'DD-MON-YYYY HH24:MI:SS'));
             raise Parameters_ERR;
        END IF;
     END IF;

     l_select_criteria.scheduled_ship_date_lo := p_scheduled_ship_date_lo;
     l_select_criteria.scheduled_ship_date_hi := p_scheduled_ship_date_hi;

     -- set default value of Source System to 'BOTH'
     IF p_source_system IS NULL THEN
        l_select_criteria.source_code            := 'BOTH';
     ELSE
        l_select_criteria.source_code            := p_source_system;
     END IF;

     l_select_criteria.organization_id        := p_organization_id;
     l_select_criteria.customer_id            := p_customer_id;
     l_select_criteria.ship_to_loc_id         := p_ship_to_loc_id;
     l_select_criteria.ship_method_code       := p_ship_method_code;
     l_select_criteria.client_id            := p_client_id; -- LSP PROJECT

     IF p_log_level IS NULL THEN
        l_select_criteria.log_level              := 0;
     ELSE
        l_select_criteria.log_level              := p_log_level;
     END IF;

     -- set append deliveries and autocreate deliveries crtieria to shipping parameter
     -- if autocreate deliveries is shipping parameter

     IF p_autocreate_deliveries IS NULL OR p_autocreate_deliveries = 'SP' THEN
        l_autocreate_deliveries := 'SP';
        l_append_deliveries := 'N';
        l_ac_del_criteria := 'SP';
     ELSIF  p_autocreate_deliveries = 'N'   THEN
     -- turn off append deliveries and autocreate deliveries criteria if autocreate
     -- deliveries is off
        l_autocreate_deliveries := 'N';
        l_append_deliveries := 'N';
        l_ac_del_criteria := 'N';
     ELSE
     -- get the value of append deliveries and autocreate deliveries criteria from
     -- user input
        l_autocreate_deliveries := p_autocreate_deliveries;
        l_ac_del_criteria := p_ac_del_criteria;
        IF p_ac_del_criteria is NULL or p_ac_del_criteria = 'SP' or p_ac_del_criteria = 'Y' THEN
          l_append_deliveries := 'N';
        ELSE
          l_append_deliveries := p_append_deliveries;
        END IF;
     END IF;


     -- turn off append deliveries if TP is installed OR lines are not from OE OR
     -- lines status is not Release to Warehouse or Ready to Release
     -- IF WSH_UTIL_CORE.TP_Is_Installed = 'Y'
     IF p_source_system <> 'OE'
        OR p_delivery_lines_status in ('ALL', 'X', 'Y')
        OR p_organization_id is NULL THEN
        l_append_deliveries := 'N';
     END IF;

     IF l_append_deliveries is NULL THEN
        IF p_organization_id is not NULL THEN
           OPEN get_appending_limit(p_organization_id);
           FETCH get_appending_limit INTO l_appending_limit;
           IF get_appending_limit%NOTFOUND THEN
             CLOSE get_appending_limit;
             raise Process_Delivery_Lines_ERR;
           END IF;
           CLOSE get_appending_limit;
           IF l_appending_limit ='N' OR l_appending_limit is NULL THEN
             l_append_deliveries := 'N';
           ELSE
             l_append_deliveries := 'Y';
           END IF;
        ELSE
           l_append_deliveries := 'N';
        END IF;
     END IF;

     IF l_autocreate_deliveries is not NULL THEN
        l_msg_string := NULL;
        l_msg_string := WSH_XC_UTIL.Get_Lookup_Meaning(
                          p_lookup_code => l_autocreate_deliveries,
                          p_lookup_type => 'YES_NO');
        FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_AUTOCREATE_DEL');
        FND_MESSAGE.SET_TOKEN('AUTOCREATE_DEL', l_msg_string);
        FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
     END IF;

     IF l_ac_del_criteria is not NULL THEN
        l_msg_string := NULL;
        l_msg_string := WSH_XC_UTIL.Get_Lookup_Meaning(
                          p_lookup_code => l_ac_del_criteria,
                          p_lookup_type => 'WSH_AC_DEL_CRITERIA');
        FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_AC_DEL_CRITERIA');
        FND_MESSAGE.SET_TOKEN('AC_DEL_CRITERIA', l_msg_string);
        FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
     END IF;

     IF l_append_deliveries is not NULL THEN
        l_msg_string := NULL;
        l_msg_string := WSH_XC_UTIL.Get_Lookup_Meaning(
                          p_lookup_code => l_append_deliveries,
                          p_lookup_type => 'YES_NO');
        FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_APPEND_DEL');
        FND_MESSAGE.SET_TOKEN('APPEND_DEL', l_msg_string);
        FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
     END IF;

     -- populate the selection criteria record and call select_delivery_lines
     Select_Delivery_Lines(
       p_select_criteria       => l_select_criteria,
       p_autocreate_deliveries => l_autocreate_deliveries,
       x_selected_det_tbl      => l_selected_det_tbl,
       x_return_status         => l_return_status);

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Return status from Select_Deliveries_Lines is '|| l_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       -- select_delivery_lines failed, exit
       raise WSH_SELECT_ERR;
     END IF;

     IF l_selected_det_tbl.count > 0 THEN
        --Perf Bug 5215740
        l_processed := 0;
        Loop
        l_inner_loop_count :=0;
        <<inner_loop>>
         Loop
           l_processed   := l_processed +1 ;
           l_inner_loop_count := l_inner_loop_count + 1;
           l_selected_det_tbl_tmp(l_inner_loop_count) := l_selected_det_tbl(l_processed);
           If (( l_inner_loop_count = 1000) or
                (l_processed = l_selected_det_tbl.count)) then
              Exit inner_loop;
           End If;
         End Loop;

        -- have selected some lines for auto create
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery lines selected to be processed are: ');
          FOR k in 1 .. l_selected_det_tbl_tmp.count LOOP
             WSH_DEBUG_SV.logmsg(l_module_name, '  delivery lines: ' || l_selected_det_tbl_tmp(k));
          END LOOP;

          WSH_DEBUG_SV.logmsg(l_module_name,'Calling Process_Delivery_Lines_Batch',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        -- call Process_delivery_lines_batch to append deliveries and autocreate deliveries
        Process_Delivery_Lines_Batch(
           p_selected_det_tbl => l_selected_det_tbl_tmp,
           p_append_flag => l_append_deliveries,
           p_ac_del_criteria => l_ac_del_criteria,
           x_appended_det_num => l_appended_det_num,
           x_autocreate_del_det_num => l_autocreate_del_det_num,
           x_appended_del_num => l_appended_del_num,
           x_new_del_num => l_new_del_num,
           x_msg_count => l_msg_count,
           x_msg_data => l_msg_data,
           x_return_status => l_return_status);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
             FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DEL_DET_ERROR');
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DEL_DET_WARNING');
          END IF;
          FND_FILE.put_line(FND_FILE.output,'     ');
          FND_FILE.put_line(FND_FILE.output,'     ');
          FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

          -- print warning or error messages Process_Delivery_Lines_Batch
          l_msg_count := FND_MSG_PUB.count_msg;

          IF l_msg_count > 0 THEN
             FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_MESSAGE_LIST');
             FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
             FND_FILE.put_line(FND_FILE.output,'====================');

             WSH_UTIL_CORE.PrintMsg('====================');
             FOR i in 1..l_msg_count LOOP
                FND_MSG_PUB.get(p_encoded => FND_API.G_FALSE,
                   p_msg_index => i,
                   p_data => l_buffer,
                   p_msg_index_out => l_index_out);
                IF l_buffer IS NOT NULL THEN
                   FND_FILE.put_line(FND_FILE.output,substrb(l_buffer,1,2000));
                   WSH_UTIL_CORE.PrintMsg(substrb(l_buffer,1,2000));
                END IF;
             END LOOP;

          END IF;
          raise Process_Delivery_Lines_ERR;
        END IF;

        g_selected_det_count     := g_selected_det_count + l_selected_det_tbl_tmp.count;
        g_appended_det_num       := g_appended_det_num + l_appended_det_num;
        g_autocreate_del_det_num := g_autocreate_del_det_num + l_autocreate_del_det_num ;
        g_appended_del_num       := g_appended_del_num + l_appended_del_num;
        g_new_del_num            := g_new_del_num + l_new_del_num ;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Return status from Process_Delivery_Lines_Batch is '|| l_return_status ,WSH_DEBUG_SV.C_PROC_LEVEL);

          WSH_DEBUG_SV.logmsg(l_module_name,'l_selected_det_tbl_tmp.count = '|| l_selected_det_tbl_tmp.count ,WSH_DEBUG_SV.C_PROC_LEVEL);
          WSH_DEBUG_SV.logmsg(l_module_name,'g_selected_det_count = '|| g_selected_det_count ,WSH_DEBUG_SV.C_PROC_LEVEL);

          WSH_DEBUG_SV.logmsg(l_module_name,'l_appended_det_num = '|| l_appended_det_num,WSH_DEBUG_SV.C_PROC_LEVEL);
          WSH_DEBUG_SV.logmsg(l_module_name,'g_appended_det_num = '|| g_appended_det_num,WSH_DEBUG_SV.C_PROC_LEVEL);

          WSH_DEBUG_SV.logmsg(l_module_name,'l_autocreate_del_det_num = '|| l_autocreate_del_det_num, WSH_DEBUG_SV.C_PROC_LEVEL);
          WSH_DEBUG_SV.logmsg(l_module_name,'g_autocreate_del_det_num = '|| g_autocreate_del_det_num, WSH_DEBUG_SV.C_PROC_LEVEL);

          WSH_DEBUG_SV.logmsg(l_module_name,'l_appended_del_num = '|| l_appended_del_num, WSH_DEBUG_SV.C_PROC_LEVEL);
          WSH_DEBUG_SV.logmsg(l_module_name,'g_appended_del_num = '|| g_appended_del_num, WSH_DEBUG_SV.C_PROC_LEVEL);

          WSH_DEBUG_SV.logmsg(l_module_name,'l_new_del_num = '|| l_new_del_num, WSH_DEBUG_SV.C_PROC_LEVEL);
          WSH_DEBUG_SV.logmsg(l_module_name,'g_new_del_num = '|| g_new_del_num, WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        exit when l_processed = l_selected_det_tbl.count;
        l_selected_det_tbl_tmp.delete;
        l_appended_det_num := 0;
        l_autocreate_del_det_num := 0;
        l_appended_del_num := 0;
        l_new_del_num := 0;
     End Loop;

       -- print results of appending deliveries and autocreate deliveries
       -- print the summary results of auto create trips action
       FND_FILE.put_line(FND_FILE.output,'     ');
       FND_FILE.put_line(FND_FILE.output,'     ');
       FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_SUMMARY');
       FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
       FND_FILE.put_line(FND_FILE.output,'====================');

       FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DETAILS_SELECTED');
       FND_MESSAGE.SET_TOKEN('NUMBER_OF_DETAILS', to_char(g_selected_det_count));
       FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

       FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DETAILS_APPENDED');
       FND_MESSAGE.SET_TOKEN('NUMBER_OF_DETAILS', to_char(g_appended_det_num));
       FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

       FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DETAILS_GROUPED');
       FND_MESSAGE.SET_TOKEN('NUMBER_OF_DETAILS', to_char(g_autocreate_del_det_num));
       FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

       FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DELIVERIES_CREATED');
       FND_MESSAGE.SET_TOKEN('NUMBER_OF_DELIVERIES', to_char(g_new_del_num));
       FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

       WSH_UTIL_CORE.PrintDateTime;
       WSH_UTIL_CORE.PrintMsg('Summary: ');
       WSH_UTIL_CORE.PrintMsg(to_char(g_selected_det_count)|| ' delivery lines selected for processing');
       WSH_UTIL_CORE.PrintMsg(to_char(g_appended_det_num)||' delivery lines have been successfully appended to existing deliveries');
       WSH_UTIL_CORE.PrintMsg(to_char(g_appended_del_num)||' existing deliveries have been successfully appended');
       WSH_UTIL_CORE.PrintMsg(to_char(g_autocreate_del_det_num)||' delivery lines have been successfully grouped to new deliveries');
       WSH_UTIL_CORE.PrintMsg(to_char(g_new_del_num)||' deliveries have been successfully created');


     ELSE
        -- no delivery lines selected
        FND_FILE.put_line(FND_FILE.output,'     ');
        FND_FILE.put_line(FND_FILE.output,'     ');
        FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_SUMMARY');
        FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
        FND_FILE.put_line(FND_FILE.output,'====================');

        FND_MESSAGE.SET_NAME('WSH', 'WSH_PD_DETAILS_SELECTED');
        FND_MESSAGE.SET_TOKEN('NUMBER_OF_DETAILS', to_char(l_selected_det_tbl.count));
        FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

        WSH_UTIL_CORE.PrintDateTime;
        WSH_UTIL_CORE.PrintMsg('Summary: ');
        WSH_UTIL_CORE.PrintMsg(to_char(l_selected_det_tbl.count)|| ' delivery lines selected for processing');

     END IF;

  END IF;

  errbuf := 'Process Deliveries is completed successfully';
  retcode := '0';
  l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;


EXCEPTION

  WHEN Create_Consolidated_Trips_ERR THEN
     l_completion_status := 'WARNING';
     l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
     errbuf := 'Process Deliveries completed with warnings';
     retcode := '1';
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;

  WHEN Process_Delivery_Lines_ERR THEN
     l_completion_status := 'WARNING';
     l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
     errbuf := 'Process Deliveries completed with warnings';
     retcode := '1';
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;

  WHEN WSH_SELECT_ERR THEN
     WSH_UTIL_CORE.PrintMsg('Error Messages: ' || l_msg_data);
     l_completion_status := 'ERROR';
     WSH_UTIL_CORE.PrintMsg('Failed to select delivery lines for processing');
     l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
     errbuf := 'Process Deliveries is completed with warning';
     retcode := '1';
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;

  WHEN Parameters_ERR THEN
     l_completion_status := 'WARNING';
     l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
     errbuf := 'Process Deliveries is completed with warning';
     retcode := '1';
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;


  WHEN OTHERS THEN
     l_completion_status := 'ERROR';
     l_error_code   := SQLCODE;
     l_error_text   := SQLERRM;
     WSH_UTIL_CORE.PrintMsg('Process Deliveries SRS failed with unexpected error.');
     WSH_UTIL_CORE.PrintMsg('The unexpected error is ' || l_error_text);
     l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
     errbuf := 'Process Deliveries failed with unexpected error';
     retcode := '2';
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;

END Process_Deliveries_SRS;


END WSH_BATCH_PROCESS;



/
