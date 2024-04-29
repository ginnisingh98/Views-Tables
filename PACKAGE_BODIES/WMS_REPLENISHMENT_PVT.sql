--------------------------------------------------------
--  DDL for Package Body WMS_REPLENISHMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_REPLENISHMENT_PVT" AS
/* $Header: WMSREPVB.pls 120.17.12010000.5 2010/04/22 02:47:57 sahmahes ship $  */


-- PACKAGE variables
g_ordered_psr           psrTabTyp;
g_total_pick_criteria       NUMBER := 5;
g_conversion_precision      NUMBER := 5;

g_backorder_deliv_tab   WSH_UTIL_CORE.ID_TAB_TYPE;
g_backorder_qty_tab    WSH_UTIL_CORE.ID_TAB_TYPE;
g_dummy_table          WSH_UTIL_CORE.ID_TAB_TYPE;

-- replenishment Type
g_push_repl NUMBER    := 1;
g_dynamic_repl NUMBER := 2;

-- This is a function used to retrieve the UOM conversion rate given an inventory item ID,
-- from UOM code and to UOM code.  The values retrieved will be cached in a global PLSQL table.

PROCEDURE print_debug(p_err_msg VARCHAR2)
  IS
BEGIN
   inv_mobile_helper_functions.tracelog(p_err_msg => p_err_msg,
					p_module => 'WMS_REPLENISHMENT_PVT',
					p_level => 4);
END print_debug;



FUNCTION get_conversion_rate(p_item_id       IN NUMBER,
			     p_from_uom_code IN VARCHAR2,
			     p_to_uom_code   IN VARCHAR2) RETURN NUMBER
  IS
     l_conversion_rate NUMBER;
     l_debug              NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

BEGIN
   IF (p_from_uom_code = p_to_uom_code) THEN
      -- No conversion necessary
      l_conversion_rate := 1;
    ELSE
      -- Check if the conversion rate for the item/from UOM/to UOM combination is cached
      IF (g_item_uom_conversion_tb.EXISTS(p_item_id) AND
	  g_item_uom_conversion_tb(p_item_id).EXISTS(p_from_uom_code) AND
	  g_item_uom_conversion_tb(p_item_id)(p_from_uom_code).EXISTS(p_to_uom_code)) THEN

	 -- Conversion rate is cached so just use the value
	 l_conversion_rate := g_item_uom_conversion_tb(p_item_id)(p_from_uom_code)(p_to_uom_code);
       ELSE
	 -- Conversion rate is not cached so query and store the value
	 inv_convert.inv_um_conversion(from_unit => p_from_uom_code,
				       to_unit   => p_to_uom_code,
				       item_id   => p_item_id,
				       uom_rate  => l_conversion_rate);
	 IF (l_conversion_rate > 0) THEN
	    -- Store the conversion rate and also the reverse conversion.
	    -- Do this only if the conversion rate returned is valid, i.e. not negative.
	    -- {{
	    -- Test having an exception when retrieving the UOM conversion rate. }}
	    g_item_uom_conversion_tb(p_item_id)(p_from_uom_code)(p_to_uom_code) := l_conversion_rate;
	    g_item_uom_conversion_tb(p_item_id)(p_to_uom_code)(p_from_uom_code) := 1 /l_conversion_rate;
	 END IF;
      END IF;
   END IF;

   -- Return the conversion rate retrieved
   RETURN l_conversion_rate;

EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('Exception in get_conversion_rate: ' || sqlcode || ', ' || sqlerrm);
      END IF;
      -- If an exception occurs, return a negative value.
      -- The calling program should interpret this as an exception in retrieving
      -- the UOM conversion rate.
      RETURN -999;
END get_conversion_rate;


-- API name : Init_Rules
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to retrieves  sequencing information based on sequence rule and
--            group information based on grouping rule.
-- Parameters :
-- IN:
--      p_pick_seq_rule_id            IN  pick sequence rule id.
-- OUT:
--      x_api_status     OUT NOCOPY  Standard to output api status.

-- This API gets called from the wms_task_dispatch_gen.pick_drop() API as
-- well. Needed to pass x_ordered_psr for this

PROCEDURE Init_Rules(p_pick_seq_rule_id     IN NUMBER
		     , x_order_id_sort       OUT NOCOPY VARCHAR2
		     , x_INVOICE_VALUE_SORT  OUT NOCOPY VARCHAR2
		     , x_SCHEDULE_DATE_SORT  OUT NOCOPY VARCHAR2
		     , x_trip_stop_date_sort OUT NOCOPY VARCHAR2
		     , x_SHIPMENT_PRI_SORT   OUT NOCOPY VARCHAR2
		     , x_ordered_psr         OUT nocopy  psrTabTyp
		     , x_api_status          OUT NOCOPY VARCHAR2)
  IS


     -- cursor to fetch pick sequence rule info
     l_debug              NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     CURSOR pick_seq_rule(v_psr_id NUMBER) IS
	SELECT NAME,
	  NVL(ORDER_ID_PRIORITY, 999999999),
	  DECODE(ORDER_ID_SORT, 'A', 'ASC', 'D', 'DESC', ''),
	  NVL(INVOICE_VALUE_PRIORITY, 999999999),
	  DECODE(INVOICE_VALUE_SORT, 'A', 'ASC', 'D', 'DESC', ''),
	  NVL(SCHEDULE_DATE_PRIORITY, 999999999),
	  DECODE(SCHEDULE_DATE_SORT, 'A', 'ASC', 'D', 'DESC', ''),
	  NVL(SHIPMENT_PRI_PRIORITY, 999999999),
	  DECODE(SHIPMENT_PRI_SORT, 'A', 'ASC', 'D', 'DESC', ''),
	  NVL(TRIP_STOP_DATE_PRIORITY, 999999999),
	  DECODE(TRIP_STOP_DATE_SORT, 'A', 'ASC', 'D', 'DESC', '')
	  FROM WSH_PICK_SEQUENCE_RULES
	  WHERE PICK_SEQUENCE_RULE_ID = v_psr_id
	  AND SYSDATE BETWEEN TRUNC(NVL(START_DATE_ACTIVE, SYSDATE)) AND
	  NVL(END_DATE_ACTIVE, TRUNC(SYSDATE) + 1);

     l_pick_seq_rule_name      VARCHAR2(30);
     l_invoice_value_priority  NUMBER;
     l_order_id_priority       NUMBER;
     l_schedule_date_priority  NUMBER;
     l_trip_stop_date_priority NUMBER;
     l_shipment_pri_priority   NUMBER;
     l_invoice_value_sort      VARCHAR2(4);
     l_order_id_sort           VARCHAR2(4);
     l_schedule_date_sort      VARCHAR2(4);
     l_trip_stop_date_sort     VARCHAR2(4);
     l_shipment_pri_sort       VARCHAR2(4);
     i                         NUMBER;
     j                         NUMBER;
     l_temp_psr                psrTyp;
     l_ordered_psr             psrtabtyp;
BEGIN
   x_api_status := fnd_api.g_ret_sts_success;

   IF  p_pick_seq_rule_id IS NULL THEN
      FOR i IN 1 .. g_total_pick_criteria LOOP
	 l_ordered_psr(i).attribute_name := 'TEMP';
	 l_ordered_psr(i).priority := 999999999;
	 l_ordered_psr(i).sort_order := 'ASC';
      END LOOP;

      --ASSIGN ANY VALUE
      x_order_id_sort := 'ASC';
      x_INVOICE_VALUE_SORT := 'ASC';
      x_SCHEDULE_DATE_SORT := 'ASC';
      x_trip_stop_date_sort := 'ASC';
      x_SHIPMENT_PRI_SORT   := 'ASC';

    ELSE -- means p_pick_seq_rule_id is not null


      -- fetch pick sequence rule parameters
      OPEN pick_seq_rule(p_pick_seq_rule_id);
      LOOP
	 FETCH pick_seq_rule
	   INTO l_pick_seq_rule_name, L_ORDER_ID_PRIORITY, x_ORDER_ID_SORT,
	   L_INVOICE_VALUE_PRIORITY, x_INVOICE_VALUE_SORT,
	   L_SCHEDULE_DATE_PRIORITY, x_SCHEDULE_DATE_SORT,
	   L_TRIP_STOP_DATE_PRIORITY,
	   x_TRIP_STOP_DATE_SORT, L_SHIPMENT_PRI_PRIORITY, x_SHIPMENT_PRI_SORT;
	 EXIT WHEN pick_seq_rule%notfound;
      END LOOP;
      CLOSE pick_seq_rule;

      -- initialize the pick sequence rule parameters
      i := 1;

      l_ordered_psr(i).attribute_name := 'ORDER_NUMBER';
      l_ordered_psr(i).priority := l_order_id_priority;
      l_ordered_psr(i).sort_order := x_order_id_sort;
      i := i + 1;

      l_ordered_psr(i).attribute_name := 'SHIPMENT_PRIORITY';
      l_ordered_psr(i).priority := l_shipment_pri_priority;
      l_ordered_psr(i).sort_order := x_shipment_pri_sort;
      i := i + 1;

      l_ordered_psr(i).attribute_name := 'INVOICE_VALUE';
      l_ordered_psr(i).priority := l_invoice_value_priority;
      l_ordered_psr(i).sort_order := x_invoice_value_sort;
      i := i + 1;

      l_ordered_psr(i).attribute_name := 'SCHEDULE_DATE';
      l_ordered_psr(i).priority := l_schedule_date_priority;
      l_ordered_psr(i).sort_order := x_schedule_date_sort;
      i := i + 1;

      l_ordered_psr(i).attribute_name := 'TRIP_STOP_DATE';
      l_ordered_psr(i).priority := l_trip_stop_date_priority;
      l_ordered_psr(i).sort_order := x_trip_stop_date_sort;
      i := i + 1;

      -- sort the table for pick sequence rule according to priority
      FOR i IN 1 .. g_total_pick_criteria LOOP
	 FOR j IN i + 1 .. g_total_pick_criteria LOOP
	    IF (l_ordered_psr(j).priority < l_ordered_psr(i).priority) THEN
	       l_temp_psr := l_ordered_psr(j);
	       l_ordered_psr(j) := l_ordered_psr(i);
	       l_ordered_psr(i) := l_temp_psr;
	    END IF;
	 END LOOP;
      END LOOP;
   END IF; -- for p_pick_seq_rule_id is null

   x_ordered_psr := l_ordered_psr;
   x_api_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   --
   WHEN OTHERS THEN
      --
      x_api_status := fnd_api.g_ret_sts_unexp_error;
      --
      IF pick_seq_rule%ISOPEN THEN
	 CLOSE pick_seq_rule;
      END IF;
      IF l_debug = 1 THEN
	 print_debug('Error in Init_Rules: ' || sqlcode || ', ' || sqlerrm);
      END IF;

END Init_Rules;



PROCEDURE Get_Source_Sub_Dest_Loc_Info(p_Org_id              IN NUMBER,
                                       p_Item_id             IN NUMBER,
                                       p_Picking_Sub         IN VARCHAR2,
                                       x_source_sub          OUT NOCOPY VARCHAR2,
				       x_src_pick_uom        OUT NOCOPY VARCHAR2,
                                       x_MAX_MINMAX_QUANTITY OUT NOCOPY NUMBER,
				       x_fixed_lot_multiple  OUT NOCOPY NUMBER,
                                       x_return_status       OUT NOCOPY VARCHAR2)
  IS

     -- Get the source sub for destination location for the replenishment move order

     CURSOR c_get_source_sub IS
	select MISI.SOURCE_SUBINVENTORY, MSISR.pick_uom_code, Nvl(MISI.max_minmax_quantity,0), NVL(MISI.FIXED_LOT_MULTIPLE, -1)
	  FROM MTL_ITEM_SUB_INVENTORIES MISI,
	  MTL_SECONDARY_INVENTORIES msi,
	  MTL_SECONDARY_INVENTORIES MSISR
	  WHERE MISI.organization_id = p_Org_id
	  AND MISI.SECONDARY_INVENTORY = MSI.SECONDARY_INVENTORY_NAME
	  AND MISI.ORGANIZATION_ID = MSI.ORGANIZATION_ID
	  and MISI.INVENTORY_ITEM_ID = p_Item_id
	  and MISI.source_type = 3 --(for Subinventory)
	  AND MISI.source_organization_id = p_Org_id
	  and MISI.SECONDARY_INVENTORY = p_picking_sub
	  and MSISR.SECONDARY_INVENTORY_NAME = MISI.SOURCE_SUBINVENTORY
	  AND MSISR.ORGANIZATION_ID = MISI.ORGANIZATION_ID
	  order by MSI.picking_order;

     -- Destination locator from Item+Sub Form will NOT be stamped on the REPL MO
     -- So that rules engine can allocate destination locator of the
     -- IDENTIFIED sub  based on available capacity

     L_INDEX NUMBER;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   -- Get the highest priority subinventory
   L_INDEX := 0;
   OPEN c_get_source_sub;
   LOOP
      FETCH c_get_source_sub
	into x_source_sub, x_src_pick_uom, x_max_minmax_quantity, x_fixed_lot_multiple;
      EXIT WHEN c_get_source_sub%NOTFOUND;
      L_INDEX := L_INDEX + 1;
      EXIT WHEN L_INDEX = 1;
   END LOOP;
   CLOSE c_get_source_sub;

   IF l_index = 0 THEN -- means no record found
      x_source_sub := NULL;
      x_src_pick_uom := NULL;
      x_max_minmax_quantity := 0;
      x_fixed_lot_multiple  := -1;
   END IF;


   IF l_debug = 1 THEN
      print_debug('Return values from API Get_Source_Sub_Dest_Loc_Info' );
      print_debug('l_index               :' || l_index);
      print_debug('x_source_sub          :' || x_source_sub );
      print_debug('x_src_pick_uom        :' || x_src_pick_uom );
      print_debug('x_fixed_lot_multiple  :' || x_fixed_lot_multiple);
      print_debug('x_MAX_MINMAX_QUANTITY :' || x_MAX_MINMAX_QUANTITY);
   END IF;


   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('Error Get_Source_Sub_loc_Info: ' || sqlcode || ',' || sqlerrm);
      END IF;

      IF c_get_source_sub%ISOPEN THEN
	 CLOSE c_get_source_sub;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_Source_Sub_Dest_Loc_Info;



--Updates the replenishment_status of single passed delivery_detail_id
-- If p_repl_status = 'R' marks it RR
-- If p_repl_status = 'C' marks it RC
-- If p_repl_status = NULL - Reverts WDD to original status (Ready to release / backorder)
--
PROCEDURE update_wdd_repl_status (p_deliv_detail_id   IN NUMBER
				  , p_repl_status     IN VARCHAR2
				  , p_deliv_qty       IN NUMBER DEFAULT NULL
				  , x_return_status            OUT    NOCOPY VARCHAR2
				  )
  IS

     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;

     l_detail_info_tab             WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
     l_in_rec                      WSH_INTERFACE_EXT_GRP.detailInRecType;
     l_out_rec                     WSH_INTERFACE_EXT_GRP.detailOutRecType;

     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(1000);
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     -- for backordering
     l_out_rows             WSH_UTIL_CORE.ID_TAB_TYPE;
     l_backorder_deliv_tab  WSH_UTIL_CORE.ID_TAB_TYPE;
     l_backorder_qty_tab    WSH_UTIL_CORE.ID_TAB_TYPE;
     l_dummy_table          WSH_UTIL_CORE.ID_TAB_TYPE;
BEGIN

   IF (l_debug = 1) THEN
      print_debug('Updating Repl status of delivery_detail :'||p_deliv_detail_id
		  ||' To Status :'||p_repl_status);
   END IF;

   l_detail_info_tab.DELETE;
   l_in_rec := NULL;


   IF p_repl_status IS NOT NULL THEN
      -- call WSH to just update the replenishment status

      l_detail_info_tab(1).delivery_detail_id := p_deliv_detail_id;
      l_detail_info_tab(1).replenishment_status := p_repl_status ;
      l_in_rec.caller := 'WMS_REP';
      l_in_rec.action_code := 'UPDATE';

      WSH_INTERFACE_EXT_GRP.Create_Update_Delivery_Detail
	(p_api_version_number  => 1.0,
	 p_init_msg_list       => fnd_api.g_false,
	 p_commit              => fnd_api.g_false,
	 x_return_status       => l_return_status,
	 x_msg_count           => l_msg_count,
	 x_msg_data            => l_msg_data,
	 p_detail_info_tab     => l_detail_info_tab,
	 p_in_rec              => l_in_rec,
	 x_out_rec             => l_out_rec
	 );

      IF (l_debug = 1) THEN
	 print_debug('Status after updating the Repl status '||l_return_status);
      END IF;

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Error returned from Create_Update_Delivery_Detail IN api update_wdd_repl_status');
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Unexpected errror from Create_Update_Delivery_Detail IN api update_wdd_repl_status');
	 END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSE -- p_repl_status IS NULL

      -- This gets called from  INVTOTRL.pld->clear_replenishment_status() procedure.

      -- We need to explicitely backorder delivery detail
      -- be calling api WSH_SHIP_CONFIRM_ACTIONS2.backorder

      -- While pick release process WSH does not backorder all those
      -- delivery detail lines that can not be fulfilled at that time(once the INV
      -- returns 'replenishment_status = 'R'). Rather WSH
      -- marks wdd.replenishemnt_status = 'R' and released_status = 'B'.
      -- This is just pseudo backorder. We actually need to backorder here explicitely.
      IF (l_debug = 1) THEN
	 print_debug('Calling Shipping API to backorder related WDD lines');
      END IF;
      l_backorder_deliv_tab(1) := p_deliv_detail_id;
      l_backorder_qty_tab(1)   := p_deliv_qty ;

      WSH_SHIP_CONFIRM_ACTIONS2.backorder
	(
	 p_detail_ids     => l_backorder_deliv_tab,
	 p_bo_qtys        => l_backorder_qty_tab,
	 p_req_qtys       => l_backorder_qty_tab,
	 p_bo_qtys2       => l_dummy_table,
	 p_overpick_qtys  => l_dummy_table,
	 p_overpick_qtys2 => l_dummy_table,
	 p_bo_mode        => 'UNRESERVE',
	 p_bo_source      => 'PICK',
	 x_out_rows       => l_out_rows,
	 x_return_status  => l_return_status
	 );
      IF (l_debug = 1) THEN
	 print_debug('WSH_SHIP_CONFIRM_ACTIONS2.backorder returned STATUS :'||l_return_status);
      END IF;

   END IF;

   x_return_status :=  l_return_status ;

EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('Error update_wdd_repl_status: ' || sqlcode || ',' || sqlerrm);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END update_wdd_repl_status;




PROCEDURE Revert_ALL_WDD_dynamic_repl (p_org_id  IN NUMBER
				       , p_batch_id  IN NUMBER
				       , x_return_status            OUT    NOCOPY VARCHAR2
				       )
  IS

l_deliv_detail_id_tab num_tab;

l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_detail_info_tab             WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
l_in_rec                      WSH_INTERFACE_EXT_GRP.detailInRecType;
l_out_rec                     WSH_INTERFACE_EXT_GRP.detailOutRecType;
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

l_msg_count     NUMBER;
l_msg_data      VARCHAR2(1000);

CURSOR c_rr_marked_wdd IS
    SELECT delivery_detail_id
      FROM wsh_delivery_details wdd
      WHERE wdd.source_code = 'OE'
      AND wdd.organization_id = p_org_id
      AND wdd.requested_quantity > 0
      -- excluding Replenishment Requested status
      AND wdd.released_status in ('R', 'B') and wdd.replenishment_status = 'R'
      -- there might not be reservation
      AND NOT EXISTS
      (select 1
       from mtl_reservations mr
       WHERE MR.DEMAND_SOURCE_LINE_ID = wdd.source_line_id
       and MR.DEMAND_SOURCE_HEADER_ID =
       inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id)
       and MR.demand_source_type_id =
       decode(wdd.source_document_type_id, 10, 8, 2)
       and MR.SUBINVENTORY_CODE IS NOT NULL) --locator is not needed, Exclude detailed RSV
	 AND NOT EXISTS
	 (select wrd.demand_line_detail_id
	  from WMS_REPLENISHMENT_DETAILS wrd
	  where wrd.demand_line_detail_id = wdd.delivery_detail_id
	  and wrd.demand_line_id = wdd.source_line_id
	  and wrd.organization_id = wdd.organization_id
	  AND wrd.organization_id = p_org_id)
	 AND wdd.batch_id = p_batch_id;

BEGIN

   IF (l_debug = 1) THEN
      print_debug('Inside API Revert_ALL_WDD_dynamic_repl ....');
   END IF;

 BEGIN

    OPEN c_rr_marked_wdd;
    FETCH c_rr_marked_wdd BULK COLLECT INTO l_deliv_detail_id_tab;
    CLOSE c_rr_marked_wdd;

 EXCEPTION
    WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Exception retrieving item repl records for Dynamic');
	 END IF;
	 l_return_status := fnd_api.g_ret_sts_error;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END;

 l_detail_info_tab.DELETE;
 FOR i IN  l_deliv_detail_id_tab.FIRST..l_deliv_detail_id_tab.LAST LOOP
    l_detail_info_tab(i).delivery_detail_id := l_deliv_detail_id_tab(i);
    -- mark the demand lines for FND_API.g_miss_char  replenishment status
    l_detail_info_tab(i).replenishment_status := FND_API.g_miss_char;

 END LOOP;


 IF (l_debug = 1) THEN
    print_debug('REVERT ALL DEMAND DETAIL STATUS to original release status');
 END IF;

 l_in_rec := NULL;
 l_in_rec.caller := 'WMS_REP';
 l_in_rec.action_code := 'UPDATE';

 WSH_INTERFACE_EXT_GRP.Create_Update_Delivery_Detail
     (p_api_version_number  => 1.0,
      p_init_msg_list       => fnd_api.g_false,
      p_commit              => fnd_api.g_false,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      p_detail_info_tab     => l_detail_info_tab,
      p_in_rec              => l_in_rec,
      x_out_rec             => l_out_rec
      );

   IF (l_debug = 1) THEN
      print_debug('AFTER Changing the line status to original release status');
   END IF;

   IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (l_debug = 1) THEN
	 print_debug('Error returned from Create_Update_Delivery_Detail IN api Revert_ALL_WDD_dynamic_repl');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (l_debug = 1) THEN
	 print_debug('Unexpected errror from Create_Update_Delivery_Detail api IN Revert_ALL_WDD_dynamic_repl');
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status :=  l_return_status ;

EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('Error In Revert_ALL_WDD_dynamic_repl: ' || sqlcode || ',' || sqlerrm);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END revert_all_wdd_dynamic_repl;


PROCEDURE Revert_Consol_item_changes ( p_repl_type   IN NUMBER
				       , p_demand_type_id IN NUMBER
				       , P_item_id       IN NUMBER
				       , p_org_id       IN NUMBER
				       , x_return_status            OUT    NOCOPY VARCHAR2
				      )
  IS

     l_deliv_detail_id_tab num_tab;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_detail_info_tab             WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
     l_in_rec                      WSH_INTERFACE_EXT_GRP.detailInRecType;
     l_out_rec                     WSH_INTERFACE_EXT_GRP.detailOutRecType;

     l_item_id NUMBER;
     l_org_id NUMBER;

     l_msg_count NUMBER;
     l_msg_data VARCHAR2(1000);

     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;

     CURSOR c_demand_for_items IS
	SELECT demand_line_detail_id
	  FROM wms_repl_demand_gtmp
	  WHERE inventory_item_id = p_item_id
	  AND ORGANIZATION_ID  = p_org_id
	  AND repl_level = 1
	  AND demand_type_id <> 4;
BEGIN

   IF (l_debug = 1) THEN
      print_debug('Inside API Revert_Consol_item_changes .......');
   END IF;

   -- if repl_type 2 and demand_type_id <> 4 then revert that WDD to original status
   IF p_repl_type = g_dynamic_repl AND p_demand_type_id <> 4  THEN

      IF (l_debug = 1) THEN
	 print_debug('Reverting WDD status to original status for consol item');
      END IF;

      BEGIN

	 OPEN c_demand_for_items;
	 FETCH c_demand_for_items BULK COLLECT INTO l_deliv_detail_id_tab;
	 CLOSE c_demand_for_items;

      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('Exception retrieving repl records for consol item');
	    END IF;
	    l_return_status := fnd_api.g_ret_sts_error;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      l_detail_info_tab.DELETE;
      FOR i IN  l_deliv_detail_id_tab.FIRST..l_deliv_detail_id_tab.LAST LOOP
	 l_detail_info_tab(i).delivery_detail_id := l_deliv_detail_id_tab(i);
	 -- mark the demand lines for FND_API.g_miss_char replenishment status
	 l_detail_info_tab(i).replenishment_status := FND_API.g_miss_char;
      END LOOP;

      l_in_rec := NULL;
      l_in_rec.caller := 'WMS_REP';
      l_in_rec.action_code := 'UPDATE';

      WSH_INTERFACE_EXT_GRP.Create_Update_Delivery_Detail
	(p_api_version_number  => 1.0,
	 p_init_msg_list       => fnd_api.g_false,
	 p_commit              => fnd_api.g_false,
	 x_return_status       => l_return_status,
	 x_msg_count           => l_msg_count,
	 x_msg_data            => l_msg_data,
	 p_detail_info_tab     => l_detail_info_tab,
	 p_in_rec              => l_in_rec,
	 x_out_rec             => l_out_rec
	 );

      IF (l_debug = 1) THEN
	 print_debug('AFTER Changing the line status to original release status');
      END IF;

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Error returned from Create_Update_Delivery_Detail IN api revert_consol_item_changes');
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Unexpected errror from	Create_Update_Delivery_Detail api IN revert_consol_item_changes');
	 END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   END IF; -- for IF p_repl_type = g_dynamic_repl AND p_demand_type_id <> 4


   -- remove all entries for that item from gtmp
   DELETE FROM  wms_repl_demand_gtmp
     WHERE inventory_item_id = p_item_id
     AND ORGANIZATION_ID  = p_org_id;

    x_return_status :=  l_return_status ;

EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('Error in Revert_Consol_item_changes: ' || sqlcode || ',' || sqlerrm);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END revert_consol_item_changes;




PROCEDURE Backorder_wdd_for_repl( x_return_status            OUT    NOCOPY VARCHAR2
				)
  IS
 l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
 l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 l_out_rows             WSH_UTIL_CORE.ID_TAB_TYPE;
BEGIN

   IF (l_debug = 1)  THEN
      print_debug( 'Calling Shipping API to backorder all unment demand lines during Replenishment');
   END IF;
   -- Bulk processing of records here
   --these demand lines need fresh backordering

     WSH_SHIP_CONFIRM_ACTIONS2.backorder
     (
      p_detail_ids     => G_backorder_deliv_tab,
      p_bo_qtys        => G_backorder_qty_tab,
      p_req_qtys       => G_backorder_qty_tab,
      p_bo_qtys2       => G_dummy_table,
      p_overpick_qtys  => G_dummy_table,
      p_overpick_qtys2 => G_dummy_table,
      p_bo_mode        => 'UNRESERVE',
      p_bo_source      => 'PICK',
      x_out_rows       => l_out_rows,
      x_return_status  => l_return_status
      );

   IF (l_debug = 1)  THEN
      print_debug( 'After call to Backorder API Return Status :'||l_return_status);
   END IF;

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --Delete all entries in the pl/sql table
   G_backorder_deliv_tab.DELETE;
   G_backorder_qty_tab.DELETE;
   G_dummy_table.DELETE;

    x_return_status :=  l_return_status;
EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('Error in Backorder_wdd_for_repl: ' || sqlcode || ',' || sqlerrm);
      END IF;
      --Delete all entries in the pl/sql table
      G_backorder_deliv_tab.DELETE;
      G_backorder_qty_tab.DELETE;
      G_dummy_table.DELETE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Backorder_wdd_for_repl ;




PROCEDURE ADJUST_ATR_FOR_ITEM  (p_repl_level  IN NUMBER
				, p_repl_type IN NUMBER
				, x_consol_item_repl_tbl IN OUT NOCOPY CONSOL_ITEM_REPL_TBL
				, x_return_status            OUT    NOCOPY VARCHAR2
				)
  IS


     l_qoh NUMBER;
     l_rqoh NUMBER;
     l_qr   NUMBER;
     l_qs NUMBER;
     l_att NUMBER;
     l_atr NUMBER;
     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(1000);
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     l_is_revision_ctrl BOOLEAN;
     l_is_lot_ctrl BOOLEAN;
     l_is_serial_ctrl BOOLEAN;

     l_open_mo_qty NUMBER;
     l_item_id NUMBER;
     l_org_id NUMBER;
     l_demand_line_detail_id NUMBER;
     l_quantity   NUMBER;
     l_uom_code VARCHAR2(3);
     l_prim_repl_qty NUMBER;
     l_released_status VARCHAR2(1);
     cnt NUMBER;
     l_qty_in_repl_uom NUMBER;
     l_REPL_UOM_CODE  VARCHAR2(3);

     l_demand_header_id NUMBER;
     l_demand_line_id NUMBER;
     l_demand_type_id  NUMBER;
     l_new_qty_in_repl_uom NUMBER;

     l_expected_ship_date DATE;
     l_repl_to_subinventory_code VARCHAR2(10);
     l_repl_status VARCHAR2(1);

     l_detail_info_tab             WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
     l_in_rec                      WSH_INTERFACE_EXT_GRP.detailInRecType;
     l_out_rec                     WSH_INTERFACE_EXT_GRP.detailOutRecType;

     l_detail_id_tab               WSH_UTIL_CORE.id_tab_type;
     l_action_prms                 WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
     l_action_out_rec              WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;

     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_split_wdd_id NUMBER;

     l_dyn_bkord_dd_id_tab num_tab;

     l_psh_cnt NUMBER;
     l_push_bkord_dd_id_tab num_tab;
     l_rsvd_demand_qty NUMBER;
     l_gtmp_demand_qty NUMBER;
     l_rsv_accounted_qty NUMBER;
     l_other_wdd_qty NUMBER;
     l_temp_value NUMBER;

     CURSOR c_item_demand_lines IS
	SELECT  demand_header_id,
	  demand_line_id,
	  demand_line_detail_id,
	  demand_type_id,
	  Quantity,
	  Uom_code,
	  quantity_in_repl_uom,
	  REPL_UOM_code,
	  Expected_ship_date,
	  Repl_To_Subinventory_code,
	  repl_status,
	  RELEASED_STATUS
	  FROM wms_repl_demand_gtmp
	  WHERE inventory_item_id = l_item_id
	  AND organization_id = l_org_id
	  AND repl_level = P_REPL_LEVEL
	  ORDER BY repl_sequence_id;

  BEGIN

     IF (l_debug = 1)  THEN
	print_debug('Inside API ADJUST_atr_for_item.....');
     END IF ;

     FOR i IN x_consol_item_repl_tbl.FIRST.. x_consol_item_repl_tbl.LAST LOOP


	l_item_id := x_consol_item_repl_tbl(i).item_id;
	l_org_id := x_consol_item_repl_tbl(i).organization_id;

	-- Get all item details
	IF inv_cache.set_item_rec(L_ORG_ID, L_item_id)  THEN

	   IF inv_cache.item_rec.revision_qty_control_code = 2 THEN
	      l_is_revision_ctrl := TRUE;
	    ELSE
	      l_is_revision_ctrl := FALSE;
	   END IF;

	   IF inv_cache.item_rec.lot_control_code = 2 THEN
	      l_is_lot_ctrl := TRUE;
	    ELSE
	      l_is_lot_ctrl := FALSE;
	   END IF;

	   IF inv_cache.item_rec.serial_number_control_code NOT IN (1,6) THEN
	      l_is_serial_ctrl := FALSE;
	    ELSE
	      l_is_serial_ctrl := TRUE;
	   END IF;

	 ELSE

	   IF (l_debug = 1)  THEN
	      print_debug('Error: Item detail not found');
	   END IF ;

	   RAISE no_data_found;
	END IF; -- for inv_cache.set_item_rec


	--uom conversio would already be defined, otherwise it will not come here
	-- get the final repl qty in the primary UOM
	l_prim_repl_qty :=
	  ROUND((x_consol_item_repl_tbl(i).total_demand_qty * get_conversion_rate(l_Item_id,
								x_consol_item_repl_tbl(i).repl_uom_code,
										  inv_cache.item_rec.primary_uom_code
										  )),
		g_conversion_precision);


	IF (l_debug = 1)  THEN
	   print_debug('Processing for Item :'||l_item_id||
		       ' Total Primary Dmd Qty :'||l_prim_repl_qty);
	END IF ;

	--Query Quantity Tree
	inv_quantity_tree_pub.clear_quantity_cache;

	-- Check value passed in this call to QTY Tree
	inv_quantity_tree_pub.query_quantities
	  (
	   p_api_version_number           => 1.0
	   , p_init_msg_lst               => fnd_api.g_false
	   , x_return_status              => l_return_status
	   , x_msg_count                  => l_msg_count
	   , x_msg_data                   => l_msg_data
	   , p_organization_id            => L_ORG_ID
	   , p_inventory_item_id          => L_item_id
	   , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
	   , p_is_revision_control        => l_is_revision_ctrl
	   , p_is_lot_control             => l_is_lot_ctrl
	   , p_is_serial_control        => l_is_serial_ctrl
	   , p_demand_source_type_id    => -9999 --should not be null
	   , p_demand_source_header_id  => -9999 --should not be null
	   , p_demand_source_line_id    => -9999
	   , p_revision                      => NULL
	   , p_lot_number                 => NULL
	   , p_subinventory_code          => NULL
	   , p_locator_id                 => NULL
	   , x_qoh                        => l_qoh
	   , x_rqoh                       => l_rqoh
	  , x_qr                         => l_qr
	  , x_qs                         => l_qs
	  , x_att                        => l_att
	  , x_atr                        => l_atr
	  );

	IF (l_debug = 1)  THEN
	   print_debug( 'Return status from QTY TREE:' ||l_return_status);
	   print_debug( '>>>> From Qrt Tree, Org Level atr for Item :'||L_item_id||' is : '||l_atr);
	END IF;

	IF l_return_status <> fnd_api.g_ret_sts_success THEN
	   l_atr := 0;
	END IF;

	----------------------
	-- Since Qty Tree would have also subttracted qty for current demand
	-- lines under consideration for which there is existing
	-- reservation as well, I need to add them back
	-- to see real picture of the atr for demand line under consideration

	------------------
	-- Note: one SO demand line can have multiple delivery_details
	-- Reservation is made at the SO line level and WRDG is at the
	-- delivery_detail level

	-- Steps:
	-- 1-Get all the RSV qty for the item+org for ONLY those SO lines
	-- that are part OF GTMP table= Q1
	-- 2-Get the SUM OF qty in the GTMP for item+org combination  = Q2
        -- Q3 - represents, For a specific item+Org, SUM OF qty for ALL wdds that are :
	-- 1- Part of same SO line whose wdds in the GTMP table
	-- 2- Excludes Wdds in the GTMP table
	-- 3- WDD.released_status not in (R,N,B,X,C) or already RR

	--R- Ready to Release
	--N- Not ready to Release
	--B- Backordered
	--X- Not applicable
	--C- Shipped
	--S- Released to Warehouse
	--Y- Staged


	-- On the so line that can be possible candidate to contribute to reduction OF ATR

	-- Qty that would already have been accounted for in the qty
	-- tree = MIN(MAX((Q1-Q3), 0),Q2)

	------------------------

	-- Get Q1
	SELECT nvl(sum(mr.reservation_QUANTITY),0) INTO l_rsvd_demand_qty
	  from mtl_reservations mr
	  ,WMS_REPL_DEMAND_GTMP WRDG
	  WHERE mr.organization_id = wrdg.organization_id
	  and mr.inventory_item_id = wrdg.inventory_item_id
	  and MR.DEMAND_SOURCE_LINE_ID = wrdg.DEMAND_line_ID
	  and MR.DEMAND_SOURCE_HEADER_ID = wrdg.DEMAND_HEADER_ID
	  AND Wrdg.INVENTORY_ITEM_ID = l_item_id
	  and wrdg.ORGANIZATION_ID = L_ORG_ID
	  and wrdg.demand_type_id <> 4
	  and wrdg.repl_level = nvl(p_repl_level, 1);


	-- Get Q2
	SELECT Nvl(sum(wrdg.QUANTITY),0) INTO l_gtmp_demand_qty
	  from WMS_REPL_DEMAND_GTMP WRDG
	  WHERE  Wrdg.INVENTORY_ITEM_ID = l_item_id
	  and wrdg.ORGANIZATION_ID = L_ORG_ID
	  and wrdg.demand_type_id <> 4
	  and wrdg.repl_level = nvl(p_repl_level, 1);

	-- Get Q3
	SELECT  Nvl(SUM(wdd.requested_quantity),0) INTO l_other_wdd_qty
	  FROM wsh_delivery_details wdd
	  WHERE wdd.organization_id = l_org_id
	  AND wdd.inventory_item_id = l_item_id
	  AND((wdd.released_status NOT IN ('R','N','B','X','C') AND wdd.replenishment_status IS NULL)
	      OR (wdd.released_status = 'B' AND wdd.replenishment_status IS NOT NULL))
	  AND NOT EXISTS
		(SELECT 1
		 FROM wms_repl_demand_gtmp wrdg
		 WHERE wrdg.organization_id = wdd.organization_id
		 AND wrdg.inventory_item_id = wdd.inventory_item_id
		 AND wrdg.demand_line_detail_id = wdd.delivery_detail_id
		 AND wrdg.demand_header_id = inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id)
		 AND wrdg.demand_line_id = wdd.source_line_id
		 )
	  AND inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id) IN
		(
		 SELECT DISTINCT demand_header_id FROM wms_repl_demand_gtmp wrdg1
		 WHERE WRDG1.organization_id = l_org_id
		 AND WRDG1.inventory_item_id = l_item_id
		 );


	IF (l_debug = 1)  THEN
	   print_debug( ' l_rsvd_demand_qty:'||l_rsvd_demand_qty);
	   print_debug( ' l_gtmp_demand_qty:'||l_gtmp_demand_qty);
	   print_debug( ' l_other_wdd_qty  :'||l_other_wdd_qty);

	END IF;

	--l_rsv_accounted_qty = MIN(MAX((Q1-Q3), 0),Q2)
	--l_rsv_accounted_qty :=  MIN(MAX((l_rsvd_demand_qty-l_other_wdd_qty ), 0),l_gtmp_demand_qty) ;


	IF (l_rsvd_demand_qty-l_other_wdd_qty ) >= 0 THEN
	   l_temp_value := (l_rsvd_demand_qty-l_other_wdd_qty );
	 ELSE
	   l_temp_value := 0;
	END IF;


	IF l_temp_value >= l_gtmp_demand_qty THEN
	   l_rsv_accounted_qty :=l_gtmp_demand_qty;
	 ELSE
	   l_rsv_accounted_qty :=l_temp_value;
	END IF;


	IF (l_debug = 1)  THEN
	   print_debug( 'Already Rsvd QTY AT ORG for demand lines for current item :'||l_rsv_accounted_qty);
	END IF;


	-- Adjust the l_atr with "EFFECTIVE QTY" on open MO whose source_sub is
	-- sub under consideration. These MO should NOT be part of WRD becs
	-- those part of WRD would already have been accounted in the RSV
	-- Problematic are those for which MO is created but not allocated and
	-- NOT tracked IN wrd AND whose source sub is Current Sub under consideration
	-- So any untracked repl MO that is going out of the current sub should
	-- be subtracted FROM l_org_atr for item for the reason of directionality (Pallet > CASE > Each)
	-- becs material move from higher configuration to lower configuration
	-- "EFFECTIVE QTY" = (mtrl.quantity - (Nvl(mtrl.quantity_detailed,0) + Nvl(mtrl.quantity_delivered,0)))

       BEGIN
	  SELECT  SUM((mtrl.quantity - (Nvl(mtrl.quantity_detailed,0) +
					Nvl(mtrl.quantity_delivered,0))))  INTO l_open_mo_qty
	    FROM mtl_txn_request_lines mtrl,
	    Mtl_txn_request_headers mtrh
	    WHERE  mtrl.header_id = mtrh.header_id
	    AND mtrl.organization_id = mtrh.organization_id
	    AND mtrl.organization_id   = L_ORG_ID
	    AND mtrl.inventory_item_id = L_item_id
	    AND mtrl.organization_id in (select organization_id from mtl_parameters where wms_enabled_flag = 'Y')
	    AND MTRH.move_order_type = 2
	    and mtrl.line_status in (3,7) -- only approved and pre-approved
	    and mtrl.transaction_type_id = 64
	    and mtrl.transaction_source_type_id = 4
	    and mtrl.from_SUBINVENTORY_CODE = x_consol_item_repl_tbl(i).repl_to_subinventory_code
	    GROUP BY mtrl.inventory_item_id;
       EXCEPTION
	  WHEN no_data_found THEN
	     l_open_mo_qty := 0;
       END;

       l_atr := l_atr + Nvl(l_rsv_accounted_qty,0) - Nvl(l_open_mo_qty,0);

       IF (l_debug = 1)  THEN
	  print_debug( 'Total effective qty for Untracked repl MO going out of FP Sub:' ||l_open_mo_qty);
	  print_debug( 'Final Org Level Effective ATR for Item in GTMP table:'||l_atr);
       END IF;

       --========================================
       -- Now perform these 3 things.
       --1- Do calculation about qty
       --2- Remove unmet entery from the GTMP table
       --3- For the Item, Adjust the QTY in the CONSOLIDATED TABLE
       --4- Backorder the unmet demand line qty
       --========================================

       --1- Do calculation about qty
       IF l_atr > l_prim_repl_qty THEN
	  -- do nothing
	  RETURN;

	ELSE -- L_ATR IS NOT GOOD ENOUGH to handle all demands
	  l_prim_repl_qty := 0; -- Reset AND re-add in loop for each item
	  cnt := 0;
	  l_psh_cnt := 0;
	  l_detail_info_tab.DELETE;
	  l_dyn_bkord_dd_id_tab.DELETE;
	  l_push_bkord_dd_id_tab.DELETE;


	  OPEN c_item_demand_lines;
	  LOOP
	     FETCH c_item_demand_lines INTO   l_demand_header_id,
	       l_demand_line_id,
	       l_demand_line_detail_id,
	       l_demand_type_id,
	       l_Quantity,
	       l_Uom_code,
	       l_qty_in_repl_uom,
	       l_REPL_UOM_code,
	       l_Expected_ship_date,
	       l_Repl_To_Subinventory_code,
	       l_repl_status,
	       l_released_status;

	     EXIT WHEN c_item_demand_lines%notfound;


	     IF l_atr >= l_quantity THEN
		-- once l_atr becomes negative it will always reamin negative
		-- and code will always go TO the ELSE section afterwards
		-- Final primary qty will be set here for this item
		l_atr := l_atr - l_quantity;
		l_prim_repl_qty := l_prim_repl_qty +l_quantity;

	      ELSE  -- means l_atr < l_quantity; remaining l_atr is not enough for l_quantity

		IF l_atr <> 0  THEN -- so that it does not call to split again FOR an item
		   IF (l_debug = 1)  THEN
		      print_debug( 'Remaining l_atr is not enough for CURRENT demand line,....splitting the WDD ');
		   END IF;

		   -- 1-Call Shipping API to split the WDD with (l_quantity - l_atr)
		   -- Shipping will update current WDD with qty = l_atr
		   -- and create a new WDD with qty = (l_quantity - l_atr)

		   -- 2-Split the Qty in the GTMP :UPDATE current demand RECORD with qty = l_atr
		   -- We do NOT need to insert the new record in GTMP with qty = (l_quantity - l_atr)
		   -- since we are going to delete downstream from GTMP for ALL unmet demand lines

		   -- -3-Adjust 	l_prim_repl_qty := l_prim_repl_qty +l_atr;
		   -- -4- Set l_atr = 0

		   l_detail_id_tab.DELETE;
		   l_action_prms := NULL;
		   l_detail_id_tab(1) := l_demand_line_detail_id;
		   -- Caller needs to be WSH_PUB in order for shipping to allow this action
		   l_action_prms.caller := 'WSH_PUB';
		   l_action_prms.action_code := 'SPLIT-LINE';
		   l_action_prms.split_quantity := (l_quantity - l_atr);

		   WSH_INTERFACE_GRP.Delivery_Detail_Action
		     (p_api_version_number  => 1.0,
		      p_init_msg_list       => fnd_api.g_false,
		      p_commit              => fnd_api.g_false,
		      x_return_status       => l_return_status,
		      x_msg_count           => l_msg_count,
		      x_msg_data            => l_msg_data,
		      p_detail_id_tab       => l_detail_id_tab,
		      p_action_prms         => l_action_prms,
		      x_action_out_rec      => l_action_out_rec
		      );

		   IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
		      IF (l_debug = 1) THEN
			 print_debug( 'Error returned from Split ADJUST_ATR_FOR_ITEM API..skip this demand');
		      END IF;
		      -- skip this demand line
		      GOTO  next_dmd_rec;
		    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		      IF (l_debug = 1) THEN
			 print_debug( 'Unexpected errror from Split ADJUST_ATR_FOR_ITEM API..skip this demand');
		      END IF;
		      -- skip this demand line
		      GOTO  next_dmd_rec;
		   END IF;

		   l_split_wdd_id := l_action_out_rec.result_id_tab(l_action_out_rec.result_id_tab.FIRST);

		   l_new_qty_in_repl_uom := ROUND((l_atr * get_conversion_rate(l_item_id,
									       inv_cache.item_rec.primary_uom_code,
									       x_consol_item_repl_tbl(i).repl_uom_code )), g_conversion_precision);

		   -- update the qty in the existing GTMP record
		   UPDATE wms_repl_demand_gtmp
		     SET  QUANTITY   = l_atr,
		     QUANTITY_IN_REPL_UOM  =  l_new_qty_in_repl_uom
		     WHERE demand_line_detail_id = l_demand_line_detail_id;

		   --reset program parameters for next loop
		   l_prim_repl_qty := l_prim_repl_qty +l_atr;
		   l_atr := 0;


		   --Override l_demand_line_detail_id so that it gets added to
		   -- the backorder list. released status of both dd_id is same
		   l_demand_line_detail_id :=	l_split_wdd_id;
		END IF; --for l_atr <> 0

		-- the code will go in above split case only once to consume
		-- all remaining available l_atr. Thereafter, it will only go to following section to add
		-- lines to be backordered

		-- add to the backorder table to backorder demand AND delete from GTMP
		IF p_repl_type = g_push_repl THEN

		   -- we can call the backorder API for WDD lines that are already backordered
		   -- Now, Shipping team has made changes and it will honor
		   -- consolidation of the backordered api feature
		   -- it does NOT matter whether DD_id was alredy backordered

		   cnt := cnt+1;
		   l_push_bkord_dd_id_tab(cnt) :=
		     l_demand_line_detail_id;

		   g_backorder_deliv_tab(cnt):= l_demand_line_detail_id;
		   g_backorder_qty_tab(cnt) := l_quantity;
		   -- since we are backordering entire qty parameters
		   -- p_bo_qtys AND  p_req_qtys will have same value
		   g_dummy_table(cnt)       := 0;


		 ELSIF p_repl_type = g_dynamic_repl THEN
		   -- call the  backorder API to backorder the delivery_detail
		   -- add the delivery_detail to the global variable
		   -- it does NOT matter whether DD_id was already backordered

		   cnt := cnt+1;
		   l_dyn_bkord_dd_id_tab(cnt) := l_demand_line_detail_id;

		   g_backorder_deliv_tab(cnt):= l_demand_line_detail_id;
		   g_backorder_qty_tab(cnt) := l_quantity;
		   -- since we are backordering entire qty parameters
		   -- p_bo_qtys AND  p_req_qtys will have same value
		   g_dummy_table(cnt)       := 0;

		END IF;

	     END IF; -- for IF l_atr >= l_quantity

	     <<next_dmd_rec>>
	       IF l_return_status <> 'S' THEN
		  IF (l_debug = 1) THEN
		     print_debug( 'Removing the demand from repl consideration :'||l_demand_line_detail_id);
		  END IF;
		  -- delete this demand line from the GTMP
		  -- subtract the qty from the consol record
		  DELETE FROM wms_repl_demand_gtmp
		    WHERE demand_line_detail_id = l_demand_line_detail_id;

		  -- we have not updated the qty l_prim_repl_qty yet
		  -- so no need to update the consol qty for this item

		  -- Add here to list of delivery_details to be backordered
		  cnt := cnt+1;
		  g_backorder_deliv_tab(cnt):= l_demand_line_detail_id;
		  g_backorder_qty_tab(cnt) := l_quantity;
		  -- since we are backordering entire qty parameters
		  -- p_bo_qtys AND  p_req_qtys will have same value
		  g_dummy_table(cnt)       := 0;

	       END IF; --for IF l_return_status <> 'S'

	  END LOOP;
	  CLOSE c_item_demand_lines;
       END IF; -- for if l_atr > l_prim_repl_qty

       --2- Remove unmet entery from the GTMP table IN bulk
       IF p_repl_type = g_push_repl THEN
	  IF (l_debug = 1) THEN
	     print_debug( 'PUSH - NUMBER OF lines to be deleted :'||l_push_bkord_dd_id_tab.count);
	  END IF;

	  FORALL k IN 1 .. l_push_bkord_dd_id_tab.COUNT
	    DELETE FROM wms_repl_demand_gtmp
	    WHERE demand_line_detail_id = l_push_bkord_dd_id_tab(k)
	    AND inventory_item_id = l_item_id
	    AND organization_id = L_ORG_ID
	    AND Nvl(repl_level,1) = p_repl_level;
	ELSIF p_repl_type = g_dynamic_repl THEN
	  IF (l_debug = 1) THEN
	     print_debug( 'DYNAMIC - NUMBER OF lines to be deleted :'||l_dyn_bkord_dd_id_tab.count);
	  END IF;
	  FORALL k IN 1 .. l_dyn_bkord_dd_id_tab.COUNT
	    DELETE FROM wms_repl_demand_gtmp
	    WHERE demand_line_detail_id = l_dyn_bkord_dd_id_tab(k)
	    AND inventory_item_id = l_item_id
	    AND organization_id = L_ORG_ID
	    AND Nvl(repl_level,1) = p_repl_level;
       END IF;


       --3- For the Item, Adjust the QTY in the CONSOLIDATED TABLE
       IF l_prim_repl_qty > 0 THEN
	  x_consol_item_repl_tbl(i).total_demand_qty :=
	    ROUND((l_prim_repl_qty * get_conversion_rate(l_item_id,
							 inv_cache.item_rec.primary_uom_code,
							 x_consol_item_repl_tbl(i).repl_uom_code
							 )),
		  g_conversion_precision);

	  IF (l_debug = 1)  THEN
	     print_debug( 'After all into account Final total dmd Qty :'||x_consol_item_repl_tbl(i).total_demand_qty);
	     print_debug( 'In the UOM Code :'||x_consol_item_repl_tbl(i).repl_uom_code);
	  END IF;

	ELSE
	    IF (l_debug = 1)  THEN
	       print_debug( 'NO Qty available for this item in the ORG....removing FROM Replenishment Consideration');
	    END IF;
	    x_consol_item_repl_tbl.DELETE(i);
       END IF;



       --4- Backorder the unmet demand line qty
       -- We do not need to do anything here as we have already added those
       -- delivery_details IN the global TABLE that need TO be backordered
       -- we call an api  WSH_SHIP_CONFIRM_ACTIONS2.backorder()
       -- to backorder these delivery at the end of the
       -- replenishment process - be it push/stock-up OR pull/dynamic

       /* NOT needed

       IF p_repl_type = g_push_repl THEN
	  NULL;
	  -- To honor the consolidation of the backordered demand lines
	  -- We need to call the WSH_SHIP_CONFIRM_ACTIONS2.backorder() API
	  -- at the end of Push replenishment process. Above in the code,
	  -- We have already stored the delivery_details_ids to be
	  -- backordered IN the global pacakge variable -  g_backorder_deliv_tab

	ELSIF p_repl_type = g_dynamic_repl THEN
	  -- since line is already marked RR, just reverting the line status
	  -- to its orignal status will make it Backorder
	  -- Bulk processing of records here

	  -- FOR dynamic repl,consolidation of the backordered demand lines
	  -- works fine, even if we call in the middle of the dynamic repl
	  -- only for the push repl, backorder API needs to be called at
	  -- end of the push replenishment process.

	  IF (l_debug = 1)  THEN
	     print_debug( 'Calling Shipping API to revert to original status FOR unmet demand lines');
	  END IF;
	  l_in_rec := NULL;
	  l_in_rec.caller := 'WMS_REP';
	  l_in_rec.action_code := 'UPDATE';

	  WSH_INTERFACE_EXT_GRP.Create_Update_Delivery_Detail
	    (p_api_version_number  => 1.0,
	     p_init_msg_list       => fnd_api.g_false,
	     p_commit              => fnd_api.g_false,
	     x_return_status       => l_return_status,
	     x_msg_count           => l_msg_count,
	     x_msg_data            => l_msg_data,
	     p_detail_info_tab     => l_detail_info_tab,
	     p_in_rec              => l_in_rec,
	     x_out_rec             => l_out_rec
	     );

	  IF (l_debug = 1) THEN
	     print_debug('AFTER Changing the line status to original release status');
	  END IF;

	  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	     IF (l_debug = 1) THEN
		print_debug('Error returned from Create_Update_Delivery_Detail IN api ADJUST_ATR_FOR_ITEM');
	     END IF;
	     RAISE FND_API.G_EXC_ERROR;
	   ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	     IF (l_debug = 1) THEN
		print_debug('Unexpected errror from Create_Update_Delivery_Detail api IN ADJUST_ATR_FOR_ITEM');
	     END IF;
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

	 END IF;

	 */


     END LOOP; -- For each consolidated Items

   x_return_status := l_return_status;

  EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1)  THEN
	 print_debug('Exception in ADJUST_atr_for_item: ' || sqlcode || ', ' || sqlerrm);
      END IF;
      x_return_status :=   FND_API.G_RET_STS_ERROR;
      -- calling API will rollback
END ADJUST_atr_for_item;



PROCEDURE PUSH_REPLENISHMENT(P_repl_level                IN NUMBER DEFAULT 1,
			     p_Item_id                   IN NUMBER,
			     p_organization_id           IN NUMBER,
			     p_ABC_assignment_group_id   IN NUMBER, -- For ABC Compile Group
			     p_abc_class_id              IN NUMBER, -- For Item Classification
			     p_Order_Type_id             IN NUMBER,
			     p_Carrier_id                IN NUMBER,
			     p_customer_class            IN VARCHAR2,
			     p_customer_id               IN NUMBER,
			     p_Ship_Method_code          IN VARCHAR2,
			     p_Scheduled_Ship_Date_To    IN NUMBER,
			     p_Scheduled_Ship_Date_From  IN NUMBER,
			     p_Forward_Pick_Sub          IN VARCHAR2,
			     p_repl_UOM                  IN VARCHAR2,
			     p_Repl_Lot_Size             IN NUMBER,
			     p_Min_Order_lines_threshold IN NUMBER,
			     p_Min_repl_qty_threshold    IN NUMBER,
			     p_max_NUM_items_for_repl    IN NUMBER,
			     p_Sort_Criteria             IN NUMBER,
			     p_Auto_Allocate             IN VARCHAR2,
  p_Plan_Tasks                IN VARCHAR2,
  p_Release_Sequence_Rule_Id  IN NUMBER,
  p_Create_Reservation        IN VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2)
  IS

     l_return_value BOOLEAN;
     l_debug              NUMBER      :=  NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_consol_item_repl_tbl CONSOL_ITEM_REPL_TBL;

     l_return_status VARCHAR2(3) := fnd_api.g_ret_sts_success;
BEGIN
   x_return_status := l_return_status;

   SAVEPOINT push_replenishment_sp;

   -- REPLENISHMENT_TYPE
   --  1 - PUSH REPLENISHMENT
   --  2 - DYNAMIC REPLENISHMENT
   -- Do validation on passed parameter values

   IF l_debug = 1 THEN
      print_debug('Printing Values inside PUSH_REPLENISHMENT');
      print_debug(' P_repl_level               :'|| p_repl_level);
      print_debug(' p_Item_id                  :'|| p_Item_id  );
      print_debug(' p_organization_id          :'||p_organization_id );
      print_debug(' p_ABC_assignment_group_id  :'||p_ABC_assignment_group_id );
      print_debug(' p_abc_class_id             :'|| p_abc_class_id );
      print_debug(' p_Order_Type_id            :'|| p_Order_Type_id );
      print_debug(' p_Carrier_id               :'||p_Carrier_id );
      print_debug(' p_customer_class           :'|| p_customer_class );
      print_debug(' p_customer_id              :'|| p_customer_id  );
      print_debug(' p_Ship_Method_code         :'|| p_Ship_Method_code );
      print_debug(' p_Scheduled_Ship_Date_To   :'|| p_Scheduled_Ship_Date_To );
      print_debug(' p_Scheduled_Ship_Date_From :'||p_Scheduled_Ship_Date_From );
      print_debug(' p_Forward_Pick_Sub         :'|| p_Forward_Pick_Sub    );
      print_debug(' p_repl_UOM                 :'|| p_repl_UOM   );
      print_debug(' p_Repl_Lot_Size            :'||  p_Repl_Lot_Size  );
      print_debug(' p_Min_Order_lines_threshold :'||p_Min_Order_lines_threshold);
      print_debug(' p_Min_repl_qty_threshold    :'||p_Min_repl_qty_threshold  );
      print_debug(' p_max_NUM_items_for_repl    :'||p_max_NUM_items_for_repl  );
      print_debug(' p_Sort_Criteria             :'|| p_Sort_Criteria  );
      print_debug(' p_Auto_Allocate             :'|| p_Auto_Allocate    );
      print_debug(' p_Plan_Tasks                :'|| p_Plan_Tasks    );
      print_debug(' p_Release_Sequence_Rule_Id  :'||p_Release_Sequence_Rule_Id);
      print_debug(' p_Create_Reservation        :'|| p_Create_Reservation  );
   END IF;


   IF (p_organization_id IS NULL
       OR p_Forward_Pick_Sub IS NULL
       OR p_repl_UOM IS NULL
       OR p_Sort_Criteria IS NULL  --Default is total demand quantity = 1 from UI
       OR p_Auto_Allocate IS NULL
       OR p_Plan_Tasks IS NULL
       OR (p_ABC_assignment_group_id IS NULL AND p_abc_class_id IS NOT NULL)) THEN

      IF l_debug = 1 THEN
	 print_debug(' ERROR: VALIDATION FAILED !'  );
      END IF;

      x_return_status :=   FND_API.G_RET_STS_ERROR;
      x_msg_data  := 'Missing Required Information';
      RETURN;

   END IF;

   -- Initialize Global package tables

   l_consol_item_repl_tbl.DELETE;

   -- Initialize the global Item UOM conversion table
   g_item_uom_conversion_tb.DELETE;

   POPULATE_PUSH_REPL_DEMAND(p_repl_level                => p_repl_level,
			     p_Item_id                   => p_Item_id,
			     p_organization_id           => p_organization_id,
			     p_ABC_assignment_group_id   => p_ABC_assignment_group_id,
			     p_abc_class_id              => p_abc_class_id,
			     p_Order_Type_id             => p_Order_Type_id,
			     p_Carrier_id                => p_Carrier_id,
			     p_customer_class            => p_customer_class,
			     p_customer_id               => p_customer_id,
			     p_Ship_Method_code          => p_Ship_Method_code,
			     p_Scheduled_Ship_Date_To    => p_Scheduled_Ship_Date_To,
			     p_Scheduled_Ship_Date_From  => p_Scheduled_Ship_Date_From,
			     p_Forward_Pick_Sub          => p_Forward_Pick_Sub,
			     p_repl_UOM                  => p_repl_UOM,
			     p_Release_Sequence_Rule_Id  => p_Release_Sequence_Rule_Id,
			     p_Min_Order_lines_threshold => p_Min_Order_lines_threshold,
			     p_Min_repl_qty_threshold    => p_Min_repl_qty_threshold,
     p_max_NUM_items_for_repl    => p_max_NUM_items_for_repl,
     p_Sort_Criteria             => p_Sort_Criteria,
     x_consol_item_repl_tbl      => l_consol_item_repl_tbl,
     x_return_status             => l_return_status,
     x_msg_count                 => x_msg_count,
     x_msg_data                  => x_msg_data);


   IF l_RETURN_status = fnd_api.g_ret_sts_success THEN
      IF (l_debug = 1) THEN
	 PRINT_DEBUG('Demand records populated successfully');
      END IF;

    ELSE
      l_consol_item_repl_tbl.DELETE;
      IF (l_debug = 1) THEN
	 PRINT_DEBUG('Error from API POPULATE_PUSH_REPL_DEMAND');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;


   -- ==========TEST CODE starts ===========
   -- This code is for debugging purpose only, this code should be in
   -- l_debug = 1 only
   IF (l_debug = 1) THEN
      IF l_consol_item_repl_tbl.COUNT <> 0 THEN
	 print_debug('*******AFTER GETTING DEMAND RECORDS******');

	 FOR i IN l_consol_item_repl_tbl.FIRST .. l_consol_item_repl_tbl.LAST LOOP
	    IF (NOT l_consol_item_repl_tbl.exists(i)) THEN
	       print_debug('RECORD has been deleted from consol table, Skipping it');
	     ELSE
	       print_debug('ITEM_ID = ' || l_consol_item_repl_tbl(i).ITEM_ID  || ' '
			   || 'total_demand_qty = ' || l_consol_item_repl_tbl(i).total_demand_qty );

	    END IF;
	 END LOOP;
      END IF;
   END IF;
   -- ==========TEST CODE ends ===========



   -- To populate the demand table - WMS_REPL_DEMAND_GTMP - Get values in l_consol_item_repl_tbl
   -- Cache information about relevant items
   -- Call the Extensibility API to see if there is a custom logic to get the consolidate demand lines per Item.
   --This API will appropriately populate l_consol_item_repl_tbl .


   IF (WMS_REPL_CUSTOM_APIS_PUB.g_is_api_implemented) THEN
      l_consol_item_repl_tbl.DELETE;
      WMS_REPL_CUSTOM_APIS_PUB.GET_CONSOL_REPL_DEMAND_CUST(x_return_status        => x_return_status,
							   x_msg_count            => x_msg_count,
							   x_msg_data             => x_msg_data,
							   x_consol_item_repl_tbl => l_consol_item_repl_tbl);

   END IF; -- for API is implemented


   IF l_consol_item_repl_tbl.COUNT <> 0 THEN

      --Call the core replenishment processing API - PROCESS_REPLENISHMENT()
      PROCESS_REPLENISHMENT(P_repl_level           => P_repl_level,
			    p_repl_type            => 1, --Push Replenishment
			    p_Repl_Lot_Size        => p_Repl_Lot_Size,
			    P_consol_item_repl_tbl => l_consol_item_repl_tbl,
			    p_Create_Reservation   => p_Create_Reservation,
			    p_Auto_Allocate        => p_Auto_Allocate,
			    p_Plan_Tasks           => p_Plan_Tasks,
			    x_return_status        => l_return_status,
			    x_msg_count            => x_msg_count,
			    x_msg_data             => x_msg_data);

      IF l_RETURN_status = fnd_api.g_ret_sts_success THEN
	 IF (l_debug = 1) THEN
	    PRINT_DEBUG('processed replenishment successfully');
	 END IF;

       ELSE
	 IF (l_debug = 1) THEN
	    PRINT_DEBUG('Error from API process_replenishment');
	 END IF;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSE
      IF (l_debug = 1) THEN
	 print_debug('No Demand Records Identified for Chosen Criteria..Exiting...');
      END IF;
      ROLLBACK TO push_replenishment_sp;
      -- RETURN; -- bug 7201888
   END IF;

   -- Call an API to backorder all demands lines that were stored to be backordered
   -- We do not fail the transaction even if the backordering fails

   IF (l_debug = 1) THEN
      print_debug( 'Number of WDDs to backorder :'||g_backorder_deliv_tab.COUNT());
   END IF;

   IF g_backorder_deliv_tab.COUNT() <> 0 THEN
      Backorder_wdd_for_repl( l_return_status );
      IF l_RETURN_status <> fnd_api.g_ret_sts_success THEN
	 IF (l_debug = 1) THEN
	    PRINT_DEBUG('Call to Backorder_wdd_for_repl API returned failure..DO NOTHING');
	 END IF;
      END IF;
   END IF;


   COMMIT; -- commit entire transaction
   x_return_status := FND_API.g_ret_sts_success;

   IF (l_debug = 1) THEN
      PRINT_DEBUG('Done with the Push Replenishment');
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK TO push_replenishment_sp;
      l_consol_item_repl_tbl.DELETE;
      g_item_uom_conversion_tb.DELETE;
      IF l_debug = 1 THEN
	 print_debug('Error in PUSH_REPLENISHMENT: ' || sqlcode || ', ' || sqlerrm);
      END IF;
      x_return_status:= FND_API.g_ret_sts_error;

END PUSH_REPLENISHMENT;


PROCEDURE DYNAMIC_REPLENISHMENT(p_org_id IN NUMBER,
				P_Batch_id                 IN NUMBER,
				p_Plan_Tasks               IN VARCHAR2,
				p_Release_Sequence_Rule_Id IN NUMBER,
				P_repl_level               IN NUMBER DEFAULT 1,
				x_msg_count                OUT NOCOPY NUMBER,
				x_return_status            OUT NOCOPY VARCHAR2,
				x_msg_data                 OUT NOCOPY VARCHAR2)
  IS
     l_return_value         BOOLEAN;
     l_consol_item_repl_tbl CONSOL_ITEM_REPL_TBL;
     l_debug              NUMBER      :=  NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

     l_return_status VARCHAR2(3) := fnd_api.g_ret_sts_success;
BEGIN

   x_return_status := l_return_status;
   SAVEPOINT dynamic_replenishment_sp;

   --REPLENISHMENT_TYPE
   --  1 - PUSH REPLENISHMENT
   --  2 - DYNAMIC REPLENISHMENT

   IF l_debug = 1 THEN
      print_debug('Inside DYNAMIC_REPLENISHMENT API....');
      print_debug('p_org_id      :'||p_org_id  );
      print_debug('p_Batch_id    :'||p_Batch_id );
      print_debug('p_Plan_Tasks  :'||p_Plan_Tasks );
      print_debug('p_Release_Sequence_Rule_Id :'||p_Release_Sequence_Rule_Id );
      print_debug('p_repl_level  :'||p_repl_level );
   END IF;


   -- Do validation on passed parameter values

   IF(P_Batch_id IS NULL) THEN
      -- if no batch_id provided, just return, Pick release should not fail here
      IF l_debug = 1 THEN
	 print_debug('P_Batch_id is NULL, Returning from DYNAMIC_REPLENISHMENT');
      END IF;
      RETURN;
   END IF;

   --Initialize Global package tables
   l_consol_item_repl_tbl.DELETE;

   -- Initialize the global Item UOM conversion table
   g_item_uom_conversion_tb.DELETE;

   POPULATE_DYNAMIC_REPL_DEMAND(p_repl_level               => p_repl_level,
				p_org_id                   => p_org_id,
				P_Batch_id                 => P_Batch_id,
				p_Release_Sequence_Rule_Id => p_Release_Sequence_Rule_Id,
				x_consol_item_repl_tbl     => L_consol_item_repl_tbl,
				x_return_status            => l_return_status,
				x_msg_count                => x_msg_count,
				x_msg_data                 => x_msg_data
				);
   -- API for dynamic replenishment should not return error
   -- The API needs to revert the original status of WDD
   -- Even if it errors out for what ever reason, all WDDs
   -- should be reverted in the called API at the very least
   -- and return status of success with no records in consol table
   IF l_RETURN_status = fnd_api.g_ret_sts_success THEN
      IF (l_debug = 1) THEN
	 PRINT_DEBUG('Demand records populated successfully');
      END IF;
    ELSE
      l_consol_item_repl_tbl.DELETE;
      IF (l_debug = 1) THEN
	 PRINT_DEBUG('Error from API POPULATE_dynamic_REPL_DEMAND');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- To populate the demand table - WMS_REPL_DEMAND_GTMP - Get values in l_consol_item_repl_tbl
   -- Cache information about relevant items
   -- Call the core replenishment processing API - PROCESS_REPLENISHMENT()



   -- ==========TEST CODE starts ===========
   -- This code is for debugging purpose only, this code should be in
   -- l_debug = 1 only
   IF (l_debug = 1) THEN
      IF l_consol_item_repl_tbl.COUNT <> 0 THEN
	 print_debug('*******AFTER POPULATE_DYNAMIC_REPL_DEMAND****');

	 FOR i IN l_consol_item_repl_tbl.FIRST .. l_consol_item_repl_tbl.LAST LOOP

	    IF (NOT l_consol_item_repl_tbl.exists(i)) THEN
	       print_debug('RECORD has been deleted from consol table, Skipping it');
	     ELSE
	       print_debug('ITEM_ID,  Total_qty,  available_OH,  open_MO_QTY, Final_repl_qty ');
	       print_debug( l_consol_item_repl_tbl(i).ITEM_ID  || ' , ' ||
			    l_consol_item_repl_tbl(i).total_demand_qty || ' , '||
			    l_consol_item_repl_tbl(i).available_onhand_qty|| ' , '||
			    l_consol_item_repl_tbl(i).open_mo_qty|| ' , '||
			    l_consol_item_repl_tbl(i).final_replenishment_qty);

	    END IF;
	 END LOOP;
      END IF;
   END IF;
   -- ==========TEST CODE ends ===========



   IF l_consol_item_repl_tbl.COUNT <> 0 THEN
      PROCESS_REPLENISHMENT (
			      P_repl_level                => P_repl_level,
			      p_repl_type                 => 2,  --Dynamic Replenishment
			      p_Repl_Lot_Size             => NULL,
			      P_consol_item_repl_tbl      => l_consol_item_repl_tbl,
			      p_Create_Reservation        => 'Y',
			      p_Auto_Allocate             => 'Y',
			      p_Plan_Tasks                => p_Plan_Tasks,
			      x_return_status             => l_return_status  ,
			      x_msg_count                 => x_msg_count ,
			      x_msg_data                  => x_msg_data );

      IF l_RETURN_status = fnd_api.g_ret_sts_success THEN
	 IF (l_debug = 1) THEN
	    PRINT_DEBUG('processed replenishment successfully');
	 END IF;

       ELSE
	 IF (l_debug = 1) THEN
	    PRINT_DEBUG('Error from API process_replenishment');
	 END IF;
	 -- To call revert of WDD status for all WDDs
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSE

      IF (l_debug = 1) THEN
	 print_debug('No Demand Records Identified for Chosen Criteria..Exiting...');
      END IF;
   END IF;


   -- Call an API to backorder all demands lines that were stored to be backordered
   -- We do not fail the transaction even if the backordering fails

   IF (l_debug = 1) THEN
      print_debug( 'Number of WDDs to backorder :'||g_backorder_deliv_tab.COUNT());
   END IF;

   IF g_backorder_deliv_tab.COUNT() <> 0 THEN
      Backorder_wdd_for_repl( l_return_status );
      IF l_RETURN_status <> fnd_api.g_ret_sts_success THEN
	 IF (l_debug = 1) THEN
	    PRINT_DEBUG('Call to Backorder_wdd_for_repl API returned failure..DO NOTHING');
	 END IF;
      END IF;
   END IF;


   COMMIT;
   x_return_status := FND_API.g_ret_sts_success;

   IF (l_debug = 1) THEN
      PRINT_DEBUG('Done with the Pull/Dynamic Replenishment');
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO dynamic_replenishment_sp;
      l_consol_item_repl_tbl.DELETE;
      IF l_debug = 1 THEN
	 print_debug('SHOULD NOT HAPPEN Error in DYNAMIC_REPLENISHMENT: ' || sqlcode || ', ' || sqlerrm);
      END IF;

      -- To call revert of WDD status for all WDDs
      -- need to revert all WDD status back
      Revert_ALL_WDD_dynamic_repl (p_org_id           => p_org_id
				   , p_batch_id       => p_batch_id
				   , x_return_status  =>  l_return_status
				   );

      IF l_debug = 1 THEN
	 print_debug('status:'||l_return_status);
      END IF;
      COMMIT;

      x_return_status:= FND_API.g_ret_sts_error;
END DYNAMIC_REPLENISHMENT;



PROCEDURE POPULATE_PUSH_REPL_DEMAND
  (p_repl_level                IN NUMBER,
   p_Item_id                   IN NUMBER,
   p_organization_id           IN NUMBER,
   p_ABC_assignment_group_id   IN NUMBER, -- For ABC Compile Group
   p_abc_class_id              IN NUMBER, -- For Item Classification
   p_Order_Type_id             IN NUMBER,
   p_Carrier_id                IN NUMBER,
   p_customer_class            IN VARCHAR2,
   p_customer_id               IN NUMBER,
   p_Ship_Method_code          IN VARCHAR2,
   p_Scheduled_Ship_Date_To    IN NUMBER,
   p_Scheduled_Ship_Date_From  IN NUMBER,
   p_Forward_Pick_Sub          IN VARCHAR2,
   p_repl_UOM                  IN VARCHAR2,
   p_Release_Sequence_Rule_Id  IN NUMBER,
   p_Min_Order_lines_threshold IN NUMBER,
   p_Min_repl_qty_threshold    IN NUMBER,
   p_max_NUM_items_for_repl    IN NUMBER,
   p_Sort_Criteria             IN NUMBER,
   x_consol_item_repl_tbl      OUT NOCOPY CONSOL_ITEM_REPL_TBL,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2
  )
  IS



     -- Note: This procedure/concurrent program will be launced for a
     -- specific organization. All demand lines for same organizations should be together but here it
     -- will not matter (for dynamic repl,it will be ordered by org_id as well

     l_debug              NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

     L_ORDER_ID_SORT           VARCHAR2(4) := NULL;
     L_INVOICE_VALUE_SORT      VARCHAR2(4) := NULL;
     L_SCHEDULE_DATE_SORT      VARCHAR2(4) := NULL;
     L_TRIP_STOP_DATE_SORT     VARCHAR2(4) := NULL;
     L_SHIPMENT_PRI_SORT       VARCHAR2(4) := NULL;

     L_INDEX                NUMBER;
     l_progress             VARCHAR2(10);
     l_quantity_in_repl_uom NUMBER;
     L_match_found          NUMBER;
     l_return_value BOOLEAN;


     --TEST : if sub is specified on the SO, we exclude that unless it is same
     -- AS forward pick Sub

     CURSOR c_repl_demand_cur IS
	SELECT
	  item_id,header_id,line_id,delivery_detail_id,demand_type_id,requested_quantity,requested_quantity_uom,
	  quantity_in_repl_uom, expected_ship_date , replenishment_status,released_status,
	  sort_attribute1 ,sort_attribute2,sort_attribute3,sort_attribute4,sort_attribute5

	  FROM (
		SELECT wdd.inventory_item_id as item_id,
		inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id) AS header_id,
		wdd.source_line_id AS line_id,
		wdd.delivery_detail_id delivery_detail_id,
		decode(wdd.source_document_type_id, 10, 8, 2) as demand_type_id, -- for SO=2 and Internal Order=8
		wdd.requested_quantity requested_quantity, -- this is always stored in primary UOM
		wdd.requested_quantity_uom requested_quantity_uom,
		ROUND((wdd.requested_quantity * get_conversion_rate(wdd.inventory_item_id,
					 wdd.requested_quantity_uom,
					 p_repl_UOM)),g_conversion_precision) as quantity_in_repl_uom,

		decode(p_Scheduled_Ship_Date_To,
		       null,
		       decode(p_Scheduled_Ship_Date_From,
			      null,
			      null,
			      NVL(WMS_REPLENISHMENT_PVT.Get_Expected_Time(decode(wdd.source_document_type_id, 10, 8, 2),
									  wdd.source_header_id,
									  wdd.source_line_id,
									  wdd.delivery_detail_id),
				  WDD.date_scheduled)),

		       NVL(WMS_REPLENISHMENT_PVT.Get_Expected_Time(decode(wdd.source_document_type_id, 10, 8, 2),
								   wdd.source_header_id,
								   wdd.source_line_id,
								   wdd.delivery_detail_id),
			   WDD.date_scheduled)) as expected_ship_date,
			     wdd.replenishment_status,
			     wdd.released_status,

			     -- For order clause by select column values for WSH_PICK_SEQUENCE_RULES
			     -- get for sort_attribute1
			     To_number(DECODE(p_Release_Sequence_Rule_Id,
					      null,
					      null,
                  DECODE(g_ordered_psr(1).attribute_name,
                         'ORDER_NUMBER',
                         DECODE(L_ORDER_ID_SORT,
                                'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
			       NULL),
			 'INVOICE_VALUE',
                         GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
                                 'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
                         NULL))) as sort_attribute1,

           -- get for sort_attribute2
            To_number(DECODE(p_Release_Sequence_Rule_Id,
                  null,
                  null,
                  DECODE(g_ordered_psr(2).attribute_name,
                         'ORDER_NUMBER',
			 DECODE(L_ORDER_ID_SORT,
				'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
				NULL),
                         'INVOICE_VALUE',
                         GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
				'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
                         NULL))) as sort_attribute2,

           -- get for sort_attribute3
            To_number(DECODE(p_Release_Sequence_Rule_Id,
                  null,
                  null,
                  DECODE(g_ordered_psr(3).attribute_name,
                         'ORDER_NUMBER',
			 DECODE(L_ORDER_ID_SORT,
				'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
				NULL),
                         'INVOICE_VALUE',
                         GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
				'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
                         NULL))) as sort_attribute3,

           -- get for sort_attribute4
            To_number(DECODE(p_Release_Sequence_Rule_Id,
                  null,
                  null,
                  DECODE(g_ordered_psr(4).attribute_name,
                         'ORDER_NUMBER',
			 DECODE(L_ORDER_ID_SORT,
				'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
				NULL),
			 'INVOICE_VALUE',
                         GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
				'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
                         NULL))) as sort_attribute4,

           -- get for sort_attribute5
            To_number(DECODE(p_Release_Sequence_Rule_Id,
                  null,
                  null,
                  DECODE(g_ordered_psr(5).attribute_name,
                         'ORDER_NUMBER',
			 DECODE(L_ORDER_ID_SORT,
				'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
				null),
                         'INVOICE_VALUE',
                         GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
				'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
			   NULL))) as sort_attribute5

			   FROM oe_order_lines_all oel,
			   wsh_delivery_details wdd,
			   MTL_ABC_ASSIGNMENTS  MAA
			   WHERE wdd.organization_id = p_organization_id
			   AND wdd.source_code = 'OE'
			   AND oel.booked_flag = 'Y'
			   AND oel.open_flag = 'Y'
			   AND wdd.requested_quantity > 0
			   AND oel.line_id = wdd.source_line_id
			   -- excluding Replenishment requested status
			   AND wdd.released_status in ('R', 'B')
			   and nvl(wdd.replenishment_status, 'C') = 'C'
			   -- there might not be reservation
			   AND not exists
			   (select 1
			    from mtl_reservations mr
			    WHERE MR.DEMAND_SOURCE_LINE_ID = wdd.source_line_id
			    and MR.DEMAND_SOURCE_HEADER_ID =
			    inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id)
			    AND MR.SUBINVENTORY_CODE IS NOT NULL) --locator is not needed -- Exclude detailed RSV

			      --Exclude those demands that have suub
			      -- specified, we can not use sub = Forward_pick_sub either
			      -- becs FP sub info is not availble while marking 'RC' at the pick drop time when rsv = N
			      AND wdd.subinventory IS NULL
			    AND oel.inventory_item_id = maa.inventory_item_id(+)
			    AND nvl(MAA.ASSIGNMENT_GROUP_ID, -1) = nvl(p_ABC_assignment_group_id, nvl(MAA.ASSIGNMENT_GROUP_ID, -1))
			    AND nvl(MAA.ABC_CLASS_ID, -1) = nvl(p_abc_class_id, nvl(MAA.ABC_CLASS_ID, -1))

			      AND (nvl(wdd.customer_id, -1) = nvl(p_customer_id,nvl(wdd.customer_id, -1))
				   OR  wdd.customer_id in (SELECT party_id FROM  hz_cust_accounts
						      WHERE customer_class_code = p_customer_class
						      AND  status <> 'I'
						      AND  party_id = nvl(p_customer_id,party_id)))
			      AND wdd.source_header_type_id = nvl(P_ORDER_TYPE_ID,source_header_type_id)
			      AND NOT  exists
			      (select wrd.demand_line_detail_id
			       from WMS_REPLENISHMENT_DETAILS wrd
			       where wrd.demand_line_detail_id = wdd.delivery_detail_id
			       and wrd.demand_line_id = wdd.source_line_id
			       and wrd.organization_id = wdd.organization_id
			       And wrd.organization_id = p_organization_id)

			      AND wdd.INVENTORY_ITEM_ID = NVL(P_ITEM_ID, wdd.INVENTORY_ITEM_ID)
			      AND nvl(wdd.carrier_id, -1) =
			      NVL(p_Carrier_id, nvl(wdd.carrier_id, -1))
			      AND nvl(wdd.SHIP_METHOD_CODE, '@@@') =
			      NVL(p_Ship_Method_code, nvl(wdd.SHIP_METHOD_CODE, '@@@')) -- mandatory field

			      ) X

			WHERE x.quantity_in_repl_uom > 0
			AND x.expected_ship_date <= (SYSDATE + p_scheduled_ship_date_to )-- MANDATORY FIELD

				ORDER BY
			      x.sort_attribute1,
			      x.sort_attribute2,
			      x.sort_attribute3,
			      x.sort_attribute4,
			      x.sort_attribute5
			      FOR UPDATE SKIP LOCKED;

			      --<<Those demands that are still in Order Management and
			      -- not scheduled yet are not considering in the demand
			      --  cursor. Only those demands that are scheduled, means that
			      --are booked and they exist in WDD are being considered as
			      --valid demand>>


			      -- DESTINATION SUB IS SAME FOR ALL THESE RECORDS in c_item_repl_cur
     CURSOR c_item_repl_cur IS
	SELECT  X.inventory_item_id inventory_item_id,
	  X.total_demand_qty total_demand_qty,
	  X.date_required date_required
	  FROM (SELECT inventory_item_id,
		sum(quantity_in_repl_uom) as total_demand_qty,
		MIN(expected_ship_date) as date_required,
		MIN(repl_sequence_id) AS order_priority -- to avoid conflicting situation
		FROM WMS_REPL_DEMAND_GTMP
		where organization_id = p_organization_id
		group by inventory_item_id
		order by decode(p_Sort_Criteria,
				1,
				sum(quantity_in_repl_uom),
				count(1)) DESC, order_priority ASC) X
		  WHERE ROWNUM <= nvl(p_max_NUM_items_for_repl, 1e25);




		--BULK OPERATION: Table to store results from the open demand for replenishment
		l_item_id_tb num_tab;
		l_header_id_tb num_tab;
		l_line_id_tb num_tab;
		l_delivery_detail_id_tb num_tab;
		l_demand_type_id_tb num_tab;
		l_requested_quantity_tb num_tab;
		l_requested_quantity_uom_tb uom_tab;
		l_quantity_in_repl_uom_tb num_tab;
		l_expected_ship_date_tb date_tab;
		l_repl_status_tb  char1_tab;
		l_released_status_tb char1_tab;
		l_attr1_tab num_tab;
		l_attr2_tab num_tab;
		l_attr3_tab num_tab;
		l_attr4_tab num_tab;
		l_attr5_tab num_tab;


		-- BULK OPERATION:  Table to store consolidate demand results for replenishment
		l_total_demand_qty_tb num_tab;
		l_date_required_tb date_tab;

		l_temp_cnt NUMBER; -- for debugging only
		l_return_status VARCHAR2(3) := fnd_api.g_ret_sts_success;
BEGIN
   x_return_status := l_return_status;

   IF (l_debug = 1) THEN
      print_debug('Inside POPULATE_PUSH_REPL_DEMAND Release_Sequence_Rule_Id: '||p_Release_Sequence_Rule_Id);
   END IF;


   -- Get the Order By Clause based on Pick Release Rule
   --initialize gloabl variables
   --delete old value
   g_ordered_psr.DELETE;
   init_rules(p_pick_seq_rule_id    =>  p_Release_Sequence_Rule_Id,
	      x_order_id_sort       =>  L_ORDER_ID_SORT,
	      x_INVOICE_VALUE_SORT  =>  L_INVOICE_VALUE_SORT,
	      x_SCHEDULE_DATE_SORT  =>  L_SCHEDULE_DATE_SORT,
	      x_trip_stop_date_sort =>  L_TRIP_STOP_DATE_SORT,
	      x_SHIPMENT_PRI_SORT   =>  l_shipment_pri_sort,
	      x_ordered_psr         =>  g_ordered_psr,
	      x_api_status          =>  l_return_status );

   IF (l_debug = 1) THEN
      print_debug('Status after calling init_rules'||l_return_status);
   END IF;
   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      x_return_status := l_return_status;
      -- caller rollsback everything if error
      RETURN;
   END IF;

   --Clear all tables for bulk operation
   l_item_id_tb.DELETE;
   l_header_id_tb.DELETE;
   l_line_id_tb.DELETE;
   l_delivery_detail_id_tb.DELETE;
   l_demand_type_id_tb.DELETE;
   l_requested_quantity_tb.DELETE;
   l_requested_quantity_uom_tb.DELETE;
   l_quantity_in_repl_uom_tb.DELETE;
   l_expected_ship_date_tb.DELETE;
   l_repl_status_tb.DELETE;
   l_released_status_tb.DELETE;
   l_attr1_tab.DELETE;
   l_attr2_tab.DELETE;
   l_attr3_tab.DELETE;
   l_attr4_tab.DELETE;
   l_attr5_tab.DELETE;

   -- BULK Fetch all data from the demand cursor
   BEGIN
      OPEN c_repl_demand_cur;
      FETCH c_repl_demand_cur BULK COLLECT INTO l_item_id_tb,l_header_id_tb, l_line_id_tb, l_delivery_detail_id_tb,
	l_demand_type_id_tb, l_requested_quantity_tb,l_requested_quantity_uom_tb,
	l_quantity_in_repl_uom_tb,l_expected_ship_date_tb,l_repl_status_tb,l_released_status_tb,
	l_attr1_tab,l_attr2_tab,l_attr3_tab,l_attr4_tab,l_attr5_tab ;

      IF (l_debug = 1) THEN
	 print_debug('InProcess ROWCOUNT :'||  c_repl_demand_cur%ROWCOUNT );
      END IF;
      CLOSE c_repl_demand_cur;

   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Exception retrieving open repl demand records :'||SQLCODE ||' '||SQLERRM);
	 END IF;
      -- caller rollsback everything if error
	 x_return_status := fnd_api.g_ret_sts_error;
	 RETURN;
   END;


   --BULK insert all demand records in the GTMP table
   BEGIN
      FORALL k IN INDICES OF l_delivery_detail_id_tb
	insert into WMS_REPL_DEMAND_GTMP
	(Repl_Sequence_id,
	 repl_level,
	 Inventory_item_id,
	 Organization_id,
	 demand_header_id,
	 demand_line_id,
	 demand_line_detail_id,
	 demand_type_id,
	 Quantity,
	 Uom_code,
	 quantity_in_repl_uom,
	 REPL_UOM_code,
	 Expected_ship_date,
	 Repl_To_Subinventory_code,
	 filter_item_flag,
	 repl_status,
	 repl_type,
	 RELEASED_STATUS)
	values
	(WMS_REPL_DEMAND_GTMP_S.NEXTVAL,
	 p_repl_level,
	 l_item_id_tb(k),
	 p_organization_id,
	 l_header_id_tb(k),
	 l_line_id_tb(k),
	 l_delivery_detail_id_tb(k),
	 l_demand_type_id_tb(k),
	 l_requested_quantity_tb(k),
	 l_requested_quantity_uom_tb(k),
	 l_quantity_in_repl_uom_tb(k),
	 p_repl_UOM,
	 l_expected_ship_date_tb(k),
	 P_Forward_Pick_Sub,
	 NULL,
	 l_repl_status_tb(k),
	 1,
	 l_released_status_tb(k)); -- for Push replenishment


      /*
      -- p_Scheduled_Ship_Date_FROM is long enough to go to take the
      -- expected_date TO the last month, the query used to fail.
      --  AND x.expected_ship_date >=
      --        DECODE(NVL(p_Scheduled_Ship_Date_FROM, -1),-1,x.expected_ship_date,(SYSDATE - p_scheduled_ship_date_from))
      -- NULL value of p_Scheduled_Ship_Date_FROM is fine,
      -- running seperate query from dual with problematic value is also fine
      -- So I removed the condition from the main query and have put here
      -- AS extra CHECK ON p_scheduled_ship_date_from value condition
      */

      IF  p_scheduled_ship_date_from IS NOT NULL THEN
	 DELETE FROM  WMS_REPL_DEMAND_GTMP
	   WHERE expected_ship_date < (SYSDATE - p_scheduled_ship_date_from);
      END IF;


      -- NOTE:  Only those records were inserted in the GTMP table for which there is no detailed reservation
      -- Delete records in the GTMP table for which total demand qty for an
      -- item is below the p_Min_repl_qty_threshold (Minimum threshold for Replenishment);

      IF p_Min_repl_qty_threshold is NOT NULL THEN
	 DELETE FROM  WMS_REPL_DEMAND_GTMP
	   WHERE (inventory_item_id)
	   IN  (SELECT inventory_item_id
		from WMS_REPL_DEMAND_GTMP
		where organization_id = p_organization_id
		group by inventory_item_id
		having sum(quantity_in_repl_uom) < p_Min_repl_qty_threshold);

      END IF;


      --  Delete records in the GTMP table for which number of order lines are below p_Min_Order_lines_threshold
      -- (Minimum Order lines threshold)
      IF p_Min_Order_lines_threshold IS NOT NULL THEN
	 DELETE  FROM  WMS_REPL_DEMAND_GTMP
	   where(inventory_item_id) in
	   (SELECT  inventory_item_id from WMS_REPL_DEMAND_GTMP
	    where organization_id = p_organization_id group by inventory_item_id
	    having count(1) < Nvl(p_min_order_lines_threshold,1));

      END IF;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Error inserting wms_repl_demand_gtmp table');
	 END IF;
	 -- caller rollsback everything if error
	 x_return_status := fnd_api.g_ret_sts_error;
	 RETURN;
   END;


   -- Sort the remaining records based on the Sort Criteria specified (1 =
   --Total Demand Quantity; 2= Number of Order lines)
   --and then apply the filter p_max_NUM_items_for_repl ( Number of Items to be considered for Replenishment )
   --  Now the cursor c_consol_item_repl_cur will apply two filter: p_sort_criteria and p_max_num_items_for_repl
   -- Now store these final Item records for consolidated demand in the PL/SQL table
   -- l_consol_item_repl_tbl . This PL/SQL table will have more information (available onhand qty
   -- open move order qty and final_replenishment_qty populated in later calculation.

   -- USE BULK UPLOAD

   -- Clear tables for bulk operation
   l_item_id_tb.DELETE;
   l_total_demand_qty_tb.DELETE;
   l_date_required_tb.DELETE;

   BEGIN
      OPEN c_item_repl_cur;
      FETCH c_item_repl_cur BULK COLLECT INTO  l_item_id_tb, l_total_demand_qty_tb, l_date_required_tb;
      CLOSE c_item_repl_cur;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Exception retrieving item repl records');
	 END IF;
	 x_return_status := fnd_api.g_ret_sts_error;
      -- caller rollback everything if error
	 RETURN;
   END;

   IF (l_debug = 1) THEN
      print_debug('Total Number of consolidate Repl Records:'||l_item_id_tb.COUNT);
   END IF;



   -- Proceed following only if anything need to be processed
   IF l_item_id_tb.COUNT = 0 THEN

      IF (l_debug = 1) THEN
	 print_debug('No record to be processed..Exiting');
      END IF;


    ELSE -- means there are records are to be processed

      --Clear consolidated table
      x_consol_item_repl_tbl.DELETE;

      FOR k IN l_item_id_tb.FIRST .. l_item_id_tb.LAST LOOP
	 x_consol_item_repl_tbl(k).Organization_id := p_organization_id;
	 x_consol_item_repl_tbl(k).Item_id := l_item_id_tb(k);
	 x_consol_item_repl_tbl(k).total_demand_qty := l_total_demand_qty_tb(k);
	 x_consol_item_repl_tbl(k).date_required := l_date_required_tb(k);

	 x_consol_item_repl_tbl(k).available_onhand_qty := 0; --calculated later
	 x_consol_item_repl_tbl(k).open_mo_qty := 0; --calculated later
	 x_consol_item_repl_tbl(k).final_replenishment_qty := 0; --calculated later

	 x_consol_item_repl_tbl(k).repl_to_subinventory_code := P_Forward_Pick_sub; --same for batch
	 x_consol_item_repl_tbl(k).repl_uom_code := p_repl_UOM; --same for a batch

      END LOOP;



      -- ===========================================
      -- Delete all records from the GTMP table for all items that is not part
      -- of the l_consol_item_repl_tbl pl/sql table. here are steps TO DO it

      --1- BULK Insert again all item records in the PL/SQL table with
      --  Filter_item_flag columns = 'Y into the GTMP table,  We want to keep
      --  all original item records in GTMP that corresponds to these newly inserted item_id records
      --2-Delete those item records in the GTMP table whose item_ids are not same as item_id
      --  records that correspond to Filter_item_flag columns = Y records
      --3-Remove all records in the table that correspond to Filter_item_flag columns = 'Y'
      -- ===========================================

      --1 BULK Insert again all item records in the PL/SQL table with
      BEGIN
	 FORALL k IN 1 .. l_item_id_tb.COUNT
	   INSERT INTO WMS_REPL_DEMAND_GTMP
	   (Repl_Sequence_id,
	    repl_level,
	    Inventory_item_id,
	    Organization_id,
	    demand_header_id,
	    demand_line_id,
	    demand_line_detail_id,
	    demand_type_id,
	    quantity_in_repl_uom,
	    REPL_UOM_code,
	    Quantity,
	    Uom_code,
	    Expected_ship_date,
	    Repl_To_Subinventory_code,
	    filter_item_flag,
	    repl_status,
	    repl_type,
	    RELEASED_STATUS)
	   VALUES
	   (WMS_REPL_DEMAND_GTMP_S.NEXTVAL,
	    p_repl_level,
	    l_item_id_tb(k),
	    p_organization_id, --for push repl, it is same though
	    -9999,
	    -9999,
	    -9999,
	    -9999,
	    -9999,
	    p_repl_UOM,
	    -9999,
	    '@@@',
	    l_date_required_tb(k),
	    P_Forward_Pick_Sub,
	    'Y',
	    NULL,
	    1, -- For Push replenishment
	    NULL);


	 --2 Delete those item records in the GTMP table whose item_ids are not same as item_id
	 --records that correspond to Filter_item_flag columns = 'Y' records
	 DELETE FROM wms_repl_demand_gtmp
	   WHERE filter_item_flag IS NULL
	     AND inventory_item_id NOT IN (SELECT inventory_item_id FROM
					   wms_repl_demand_gtmp WHERE
					   Nvl(filter_item_flag,'N') = 'Y');


	   --3  Remove all records in the table that correspond to Filter_item_flag columns = 'Y'
	   DELETE FROM wms_repl_demand_gtmp
	     WHERE filter_item_flag = 'Y';

      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('Error inserting in WRDG temp table with Filter_item_flag = y : '||SQLCODE ||' '||SQLERRM);
	    END IF;
	    -- caller rollsback everything if error
	    x_return_status := fnd_api.g_ret_sts_error;
	    x_consol_item_repl_tbl.DELETE;
	    RETURN;
      END;


      -- Discard all demand lines from Push Repl consideration that could not be
      -- Fulfilled BY available Effective atr in the entire the organizatrion
      -- Adjust ALL qty in consol_table and GTMP accordingly for all items
      IF x_consol_item_repl_tbl.COUNT() <> 0 THEN
	 ADJUST_ATR_FOR_ITEM  (p_repl_level             => p_repl_level
			       , p_repl_type            => g_push_repl
			       , x_consol_item_repl_tbl => x_consol_item_repl_tbl
			       , x_return_status        => l_return_status
			       );

	 IF l_return_status <> 'S' THEN
	    IF l_debug = 1 THEN
	       print_debug('API ADJUST_ATR_FOR_ITEM returned error');
	    END IF;
	    x_return_status := fnd_api.g_ret_sts_error;
	    x_consol_item_repl_tbl.DELETE;
	    RETURN;
	 END IF;

	 IF l_debug = 1 THEN
	    print_debug('Return Status after call to ADJUST_ATR_FOR_ITEM :'|| l_return_status);
	 END IF;

      END IF;

      --=====================TEST CODE STARTS =======
      -- ONLY for debugging purpose
      IF l_debug = 1 THEN
	 SELECT COUNT(1) INTO  l_temp_cnt FROM wms_repl_demand_gtmp;
	 print_debug(' FINAL record count in gtmp :'||l_temp_cnt);
	 print_debug(' number of records in consol table :'||x_consol_item_repl_tbl.COUNT());
      END IF;
      --=====================TEST CODE ENDS =======

   END IF; --  IF l_item_id_tb.COUNT = 0

      x_return_status := FND_API.g_ret_sts_success;

      IF l_debug = 1 THEN
	 print_debug('Done with API populate_push_repl_demand');
      END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Error in populate_push_repl_demand SQLCODE:'||SQLCODE ||' '||SQLERRM );
      END IF;
      --
      -- caller rollsback everything if error
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_consol_item_repl_tbl.DELETE;
      --
END  populate_push_repl_demand ;

PROCEDURE check_for_next_level_repl(p_move_order_header_id IN NUMBER,
				    p_move_order_line_id IN NUMBER,
				    p_organization_id IN NUMBER,
				    p_inventory_item_id IN NUMBER,
				    p_repl_level IN NUMBER,
				    x_source_sub_atr IN OUT nocopy NUMBER,
				    x_create_qty OUT nocopy VARCHAR2,
				    x_return_status OUT nocopy VARCHAR2,
				    x_msg_count OUT nocopy NUMBER,
				    x_msg_data OUT nocopy VARCHAR2)
  IS
     l_debug              NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_repl_level NUMBER := p_repl_level;
     l_create_qty NUMBER := 0; -- 0 to signify it was not created
     l_source_sub_atr NUMBER := x_source_sub_atr;
     l_pending_mo_qty NUMBER;
     l_mo_source_sub VARCHAR2(50);
     l_mo_source_loc NUMBER;
     l_is_revision_ctrl BOOLEAN := FALSE;
     l_is_lot_ctrl BOOLEAN := FALSE;
     l_is_serial_ctrl BOOLEAN := FALSE;
     l_qoh NUMBER;
     l_rqoh NUMBER;
     l_qr   NUMBER;
     l_qs NUMBER;
     l_atr NUMBER;
     l_return_status VARCHAR2(3) := fnd_api.g_ret_sts_success;
     l_next_lvl_src_sub VARCHAR(30);
BEGIN
   x_create_qty := l_create_qty;
   x_return_status := fnd_api.g_ret_sts_success;

   IF l_source_sub_atr IS NULL THEN
      l_source_sub_atr := -9999;
   END IF;

   IF l_repl_level IS NULL THEN
   BEGIN
      SELECT repl_level
	INTO l_repl_level
	FROM wms_replenishment_details
	WHERE source_type_id = 4
	AND organization_id = p_organization_id
	AND inventory_item_id = p_inventory_item_id
	AND source_header_id = p_move_order_header_id
	AND source_line_id = p_move_order_line_id
	AND ROWNUM = 1;
   EXCEPTION
      WHEN no_data_found THEN
	 l_repl_level := 1;
      WHEN OTHERS THEN
	 l_repl_level := 4;
   END;
   END IF;
   IF (l_debug = 1) THEN
      print_debug('l_repl_level:'||l_repl_level);
   END IF;

   IF l_repl_level >= 4 THEN
      x_return_status := fnd_api.g_ret_sts_success;
      x_create_qty := 0;
      RETURN;
   END IF;


   BEGIN
      SELECT (quantity - Nvl(quantity_detailed,0) - Nvl(quantity_delivered,0))
	, from_subinventory_code
	, from_locator_id
	INTO l_create_qty
	, l_mo_source_sub
	, l_mo_source_loc
	FROM mtl_txn_request_lines
	WHERE line_id = p_move_order_line_id
	AND organization_id = p_organization_id
	AND inventory_item_id = p_inventory_item_id;
      IF (l_debug = 1) THEN
	 print_debug('l_create_qty:'||l_create_qty);
	 print_debug('l_mo_source_sub:'||l_mo_source_sub);
	 print_debug('l_mo_source_loc:'||l_mo_source_loc);
      END IF;
      IF ((l_create_qty <= 0) OR (l_mo_source_sub IS NULL)) THEN
	 x_return_status := fnd_api.g_ret_sts_success;
	 x_create_qty := 0;
	 RETURN;
      END IF;
	select MISI.SOURCE_SUBINVENTORY into l_next_lvl_src_sub
	FROM MTL_ITEM_SUB_INVENTORIES MISI
	WHERE MISI.organization_id = p_organization_id
	and MISI.INVENTORY_ITEM_ID = p_inventory_item_id
	and MISI.source_type = 3 --(for Subinventory)
	and MISI.SECONDARY_INVENTORY = l_mo_source_sub
	AND ROWNUM = 1;

	if l_next_lvl_src_sub is NULL then

		if (l_debug = 1) THEN
		print_debug('Since no next level setup exists, thus returning' );
		END IF;
		x_create_qty := 0;
		x_return_status := fnd_api.g_ret_sts_success;
		return;
	end if;


      IF l_source_sub_atr = -9999 THEN
	 -- Get all item details
	 IF inv_cache.set_item_rec(p_ORGANIZATION_ID, p_inventory_item_id)  THEN
	    IF (l_debug = 1) THEN
	       print_debug('Getting Item Attribute Details' );
	    END IF;
	    IF inv_cache.item_rec.revision_qty_control_code = 2 THEN
	       l_is_revision_ctrl := TRUE;
	     ELSE
	       l_is_revision_ctrl := FALSE;
	    END IF;

	    IF inv_cache.item_rec.lot_control_code = 2 THEN
	       l_is_lot_ctrl := TRUE;
	     ELSE
	       l_is_lot_ctrl := FALSE;
	    END IF;

	    IF inv_cache.item_rec.serial_number_control_code NOT IN (1,6) THEN
	       l_is_serial_ctrl := FALSE;
	     ELSE
	       l_is_serial_ctrl := TRUE;
	    END IF;

	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('Error: Item detail not found');
	    END IF;
	    x_return_status := fnd_api.g_ret_sts_success;
	    x_create_qty := 0;
	 END IF; -- for inv_cache.set_item_rec

	 IF (l_debug = 1) THEN
	    print_debug('Clearing Qty Tree' );
	 END IF;
	 --Query Quantity Tree
	 inv_quantity_tree_pub.clear_quantity_cache;

	 IF (l_debug = 1) THEN
	    print_debug('Calling Qty Tree API' );
	 END IF;

	 inv_quantity_tree_pub.query_quantities
	   (
	    p_api_version_number         => 1.0
	    , p_init_msg_lst               => fnd_api.g_false
	    , x_return_status              => l_return_status
	    , x_msg_count                  => x_msg_count
	    , x_msg_data                   => x_msg_data
	    , p_organization_id            => p_organization_id
	    , p_inventory_item_id          => p_inventory_item_id
	    , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
	    , p_is_revision_control        =>  l_is_revision_ctrl
	    , p_is_lot_control             =>  l_is_lot_ctrl
	    , p_is_serial_control          =>  l_is_serial_ctrl
	    , p_demand_source_type_id    => -9999 --should not be null
	    , p_demand_source_header_id  => -9999 --should not be null
	    , p_demand_source_line_id    => -9999
	    , p_revision                   => NULL
	    , p_lot_number                 => NULL
	    , p_subinventory_code          => l_mo_source_sub
	    , p_locator_id                 => l_mo_source_loc
	    , x_qoh                        => l_qoh
	    , x_rqoh                       => l_rqoh
	   , x_qr                         => l_qr
	   , x_qs                         => l_qs
	   , x_att                        => l_source_sub_atr
	   , x_atr                        => l_atr
	   );

	 IF (l_debug = 1) THEN
	    print_debug( 'Return status from QTY TREE:' ||x_return_status);
	 END IF;
	 IF l_return_status = fnd_api.g_ret_sts_success THEN
	    x_source_sub_atr := l_source_sub_atr;
	  ELSE
	    l_source_sub_atr := -9999;
	 END IF;
      END IF;
      IF (l_debug = 1) THEN
	 print_debug( 'l_source_sub_atr is: '||l_source_sub_atr);
      END IF;
      IF l_source_sub_atr <= 0 THEN
	 x_return_status := fnd_api.g_ret_sts_success;
	 x_create_qty := l_create_qty;
	 x_source_sub_atr := 0;
	 RETURN;
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;
      x_create_qty := 0;
   EXCEPTION
      WHEN OTHERS THEN
	 x_return_status := fnd_api.g_ret_sts_success;
	 x_create_qty := 0;
	 x_source_sub_atr := NULL;
   END;
END check_for_next_level_repl;

PROCEDURE trigger_next_level_repl(p_repl_level IN NUMBER
				  , p_repl_lot_size IN NUMBER
				  , p_plan_tasks IN VARCHAR2
				  , x_return_status OUT nocopy VARCHAR2)
  IS
     l_return_status VARCHAR2(3);
     l_org_id_tb num_tab;
     l_item_id_tb num_tab;
     l_repl_to_sub_code_tb char_tab;
     l_repl_UOM_CODE_tb uom_tab;
     l_total_demand_qty_tb num_tab;
     l_consol_item_repl_tbl consol_item_repl_tbl;
     l_debug NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

     l_msg_count NUMBER;
     l_msg_data VARCHAR2(1000);

     CURSOR c_distinct_org_id IS
	SELECT DISTINCT organization_id
	  FROM wms_repl_demand_gtmp
	  WHERE repl_level = p_repl_level;

     CURSOR c_item_repl_cur(v_org_id NUMBER) IS
	SELECT inventory_item_id,
	  sum(quantity_in_repl_uom) as total_demand_qty,
	      repl_to_subinventory_code,
	      repl_uom_code
	      FROM wms_repl_demand_gtmp
	      WHERE organization_id = v_org_id
	      AND repl_level = p_repl_level
	      GROUP BY inventory_item_id, repl_to_subinventory_code,repl_uom_code
	      ORDER BY inventory_item_id, repl_to_subinventory_code;

BEGIN
   l_org_id_tb.DELETE;
   l_return_status  := fnd_api.g_ret_sts_success;

   IF (l_debug = 1) THEN
      print_debug('Inside API trigger_next_level_repl');
   END IF;

   BEGIN
      OPEN c_distinct_org_id;
      FETCH c_distinct_org_id bulk collect INTO l_org_id_tb;
      CLOSE c_distinct_org_id;
   EXCEPTION
      WHEN OTHERS THEN
	 x_return_status := fnd_api.g_ret_sts_error;
	 DELETE FROM wms_repl_demand_gtmp WHERE repl_level = p_repl_level;
	 IF (l_debug = 1) THEN
	    print_debug('Exception getting orgs:'||p_repl_level);
	 END IF;
	 RETURN;
   END;

   FOR j IN 1..l_org_id_tb.COUNT loop
      l_item_id_tb.DELETE;
      l_total_demand_qty_tb.DELETE;
      l_repl_to_sub_code_tb.DELETE;
      l_repl_uom_code_tb.DELETE;
      BEGIN

	 SAVEPOINT new_org_sp;

	 OPEN c_item_repl_cur(l_org_id_tb(j));
	 FETCH c_item_repl_cur BULK COLLECT INTO l_item_id_tb,
	   l_total_demand_qty_tb,
	   l_repl_to_sub_code_tb,l_repl_uom_code_tb;
	 CLOSE c_item_repl_cur;

	 l_consol_item_repl_tbl.DELETE;
	 FOR k IN l_item_id_tb.FIRST .. l_item_id_tb.LAST LOOP
	    l_consol_item_repl_tbl(k).Organization_id := l_org_id_tb(j);
	    l_consol_item_repl_tbl(k).Item_id := l_item_id_tb(k);
	    l_consol_item_repl_tbl(k).total_demand_qty := l_total_demand_qty_tb(k);
	    l_consol_item_repl_tbl(k).date_required := sysdate;

	    l_consol_item_repl_tbl(k).available_onhand_qty := 0;
	    l_consol_item_repl_tbl(k).open_mo_qty := 0;
	    l_consol_item_repl_tbl(k).final_replenishment_qty := 0;

	    l_consol_item_repl_tbl(k).repl_to_subinventory_code := l_repl_to_sub_code_tb(k);
	    l_consol_item_repl_tbl(k).repl_uom_code := l_repl_uom_code_tb(k);

	    l_consol_item_repl_tbl(k).final_replenishment_qty:= l_total_demand_qty_tb(k);
	 END LOOP;

	 IF l_consol_item_repl_tbl.COUNT <> 0 THEN
	    PROCESS_REPLENISHMENT (
				    P_repl_level              	=> P_repl_level,
				    p_repl_type                 => 2,
				    p_Repl_Lot_Size             => p_Repl_Lot_Size,
				    P_consol_item_repl_tbl      => l_consol_item_repl_tbl,
				    p_Create_Reservation        => 'N',
				    p_Auto_Allocate             => 'Y',
				    p_Plan_Tasks                => p_Plan_Tasks,
				    x_return_status             => l_return_status  ,
				    x_msg_count                 => l_msg_count ,
				    x_msg_data                  => l_msg_data );

	    IF l_return_status <> 'S' THEN
	       IF (l_debug = 1) THEN
		  print_debug('Error performing replenishment for Multi-step');
	       END IF;
	       ROLLBACK TO new_org_sp;
	       DELETE FROM wms_repl_demand_gtmp
		 WHERE repl_level = p_repl_level
		 AND organization_id = l_org_id_tb(j);
	       GOTO next_org;
	    END IF;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('No Demand Records Identified for this level..Exiting...');
	    END IF;
	 END IF;


      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('Exception retrieving item repl records for Multi-step');
	    END IF;
	    ROLLBACK TO new_org_sp;
	    DELETE FROM wms_repl_demand_gtmp
	      WHERE repl_level = p_repl_level
	      AND organization_id = l_org_id_tb(j);
	    GOTO next_org;
      END;

      <<next_org>>
	NULL;
   END LOOP; -- org loop


   IF l_debug = 1 THEN
      print_debug('DONE WITH API trigger_next_level_repl');
   END IF;
   x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('Exception in trigger_next_level_repl: ' || sqlcode || ', ' || sqlerrm);
      END IF;

END trigger_next_level_repl;


PROCEDURE PROCESS_REPLENISHMENT( p_Repl_level           IN NUMBER,
				 p_repl_type            IN NUMBER,
				 p_Repl_Lot_Size        IN NUMBER,
				 P_consol_item_repl_tbl IN OUT NOCOPY CONSOL_ITEM_REPL_TBL,
				 p_Create_Reservation   IN VARCHAR2,
				 p_Auto_Allocate        IN VARCHAR2,
				 p_Plan_Tasks           IN VARCHAR2,
				 x_return_status        OUT NOCOPY VARCHAR2,
				 x_msg_count            OUT NOCOPY NUMBER,
				 x_msg_data             OUT NOCOPY
				 VARCHAR2)
  IS

     l_debug              NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_temp_cnt NUMBER; -- for debugging only
     l_repl_level NUMBER;
     l_return_status VARCHAR2(3) := fnd_api.g_ret_sts_success;

BEGIN
   x_return_status := l_return_status;

   -- At this point WMS_REPL_DEMAND_GTMP table should have all the correct demand records and
   --l_consol_item_repl_tbl should have all the consolidated quantities grouped by for Item_Id and Repl_To_Subinventory_Code.
   -- Now for each entry in the p_consol_item_repl_tbl, get available onhand qty and update records in the p_consol_item_repl_tbl.

   -- it does not make sense to net off onhand/open MOs for
   -- next level of Replenishment MOs
   -- We would get the quantity after the first level made use
   -- of the atr, open MOs and the remaining qty on first level repl
   -- MO could not be allocated.
   IF (Nvl(p_repl_level,1) = 1) THEN
      GET_AVAILABLE_ONHAND_QTY(p_repl_level           => p_repl_level,
			       p_repl_type            => p_repl_type,
			       p_Create_Reservation   => p_Create_Reservation,
			       x_consol_item_repl_tbl => P_consol_item_repl_tbl,
			       x_return_status        => l_return_status,
			       x_msg_count            => x_msg_count,
			       x_msg_data             => x_msg_data);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
	 x_return_status := fnd_api.g_ret_sts_error;
	 RETURN;
      END IF;
   END IF;


   -- ==========TEST CODE start ===========
   -- for debugging purpise only, entire code should be inside l_debug = 1
   IF (l_debug = 1) THEN
      IF P_consol_item_repl_tbl.COUNT <> 0 THEN
	 print_debug('*******AFTER GET_AVAILABLE_ONHAND_QTY*******');

	 FOR i IN  p_consol_item_repl_tbl.FIRST .. p_consol_item_repl_tbl.LAST LOOP
	    IF (NOT p_consol_item_repl_tbl.exists(i)) THEN
	       IF (l_debug = 1) THEN
		  print_debug('CURRENT INDEX IN THE CONSOL TABLE HAS BEEN Discarded - moving TO next consol RECORD' );
	       END IF;
	     ELSE
	       IF (l_debug = 1) THEN
		  print_debug('ITEM_ID,  Total_qty,  available_OH,  open_MO_QTY, Final_repl_qty ');
		  print_debug( p_consol_item_repl_tbl(i).ITEM_ID  || ' , ' ||
			       p_consol_item_repl_tbl(i).total_demand_qty || ' , '||
			       p_consol_item_repl_tbl(i).available_onhand_qty|| ' , '||
			       p_consol_item_repl_tbl(i).open_mo_qty|| ' , '||
			       p_consol_item_repl_tbl(i).final_replenishment_qty);

	       END IF;
	    END IF;
	 END LOOP;

	 SELECT COUNT(1) INTO  l_temp_cnt FROM wms_repl_demand_gtmp;
	 IF (l_debug = 1) THEN
	    print_debug(' NUMBER OF RECORDS IN wms_repl_demand_gtmp l_temp_cnt :'||l_temp_cnt);
	 END IF;
      END IF;
   END IF;

   -- ==========TEST CODE ends ===========


   -- For Each Item, Net Off on Hand on the Forward Pick Subinventory passed in the program
   -- and keep updating l_consol_item_repl_tbl(l_index).final_replenishment_qty as well
   -- Now for each entry in the P_consol_item_repl_tbl, get
   --Open move order qty and update records in the P_consol_item_repl_tbl.

   -- it does not make sense to net off onhand/open MOs for
   -- next level of Replenishment MOs
   -- We would get the quantity after the first level made use
   -- of the atr, open MOs and the remaining qty on first level repl
   -- MO could not be allocated.
   IF (Nvl(p_repl_level,1) = 1) THEN
      GET_OPEN_MO_QTY(p_repl_level           => p_repl_level,
		      p_repl_type            => p_repl_type,
		      p_Create_Reservation   => p_Create_Reservation,
		      x_consol_item_repl_tbl => P_consol_item_repl_tbl,
		      x_return_status        => l_return_status,
		      x_msg_count            => x_msg_count,
		      x_msg_data             => x_msg_data);
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
	 x_return_status := fnd_api.g_ret_sts_error;
	 RETURN;
      END IF;
   END IF;


   -- ==========TEST CODE starts ===========
   -- for debugging purpise only, entire code should be inside l_debug = 1
   IF (l_debug = 1) THEN
      IF P_consol_item_repl_tbl.COUNT <> 0 THEN
	 print_debug('********AFTER GET_OPEN_MO_QTY API call*******');

	 FOR i IN p_consol_item_repl_tbl.FIRST .. p_consol_item_repl_tbl.LAST LOOP
	    IF (NOT p_consol_item_repl_tbl.exists(i)) THEN
	       IF (l_debug = 1) THEN
		  print_debug('CURRENT INDEX IN THE CONSOL TABLE HAS BEEN Discarded - moving TO next consol RECORD' );
	       END IF;
	     ELSE

	       IF (l_debug = 1) THEN
		  print_debug('ITEM_ID,  Total_qty,  available_OH,  open_MO_QTY, Final_repl_qty ');
		  print_debug( p_consol_item_repl_tbl(i).ITEM_ID  || ' , ' ||
			       p_consol_item_repl_tbl(i).total_demand_qty || ' , '||
			       p_consol_item_repl_tbl(i).available_onhand_qty|| ' , '||
			       p_consol_item_repl_tbl(i).open_mo_qty|| ' , '||
			       p_consol_item_repl_tbl(i).final_replenishment_qty);

	       END IF;
	    END IF;
	 END LOOP;
      END IF;
   END IF; -- IF (l_debug = 1) THEN
   -- ==========TEST CODE ends ===========


   --  For Each Item, Net Off Open Move Orders in the Forward Pick Subinventory and keep updating l_consol_item_repl_tbl(l_index).final_replenishment_qty as well
   -- At this point P_consol_item_repl_tbl should have total replenishment quantity to create MO for. It is done inside the API - GET_OPEN_MO_QTY().
   -- Now create Replenishment Move Orders for effective demand that could not be fulfilled by available onhand or open move order
   -- Make sure to upp the replenishment quantity in the
   --p_consol_item_repl_tbl(l_index).final_replenishment_qty
   -- based on the p_Repl_Lot_Size parameter passed in the program. other
   -- parameters p_Create_Reservation, p_Auto_Allocate AND p_Plan_Tasks parameters will be honored inside following call.


   CREATE_REPL_MOVE_ORDER(p_repl_level           => p_repl_level,
			  p_repl_type            => p_repl_type,
			  P_consol_item_repl_tbl => P_consol_item_repl_tbl,
			  p_Create_Reservation   => p_Create_Reservation,
			  p_Repl_Lot_Size        => p_Repl_Lot_Size,
			  p_Auto_Allocate        => p_Auto_Allocate,
			  p_Plan_Tasks           => p_Plan_Tasks,
			  x_return_status        => l_return_status,
			  x_msg_count            => x_msg_count,
			  x_msg_data             => x_msg_data);
   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;


   --TODO : Satish
   -- Delete from WMS_REPL_DEMAND_GTMP for current level of replenishment. There might be records remaining in this table for the mext level of replenishment.
   -- Trigger next level of replenishment IF
   --  Replenishment level < 4  (Ea < CS < PLT < SupPLT)
   -- And there are records in the GTMP for the next level. It should have been already inserted by now


   DELETE FROM wms_repl_demand_gtmp WHERE repl_level=Nvl(p_repl_level,1);


   x_return_status := 'S';

   --TODO: Blocking Multi-Level Code changes
   -- Multi step change
   IF ((p_repl_level < 4) AND (p_auto_allocate = 'Y')) THEN
	BEGIN

	   l_repl_level := Nvl(p_repl_level,1) + 1;
   	   COMMIT;

	   IF (l_debug = 1) THEN
	      print_debug('STARTING THE NEXT LEVEL REPL :'||L_repl_level);
	   END IF;



   	   trigger_next_level_repl(p_repl_level => l_repl_level
   				   , p_repl_lot_size => p_repl_lot_size
   				   , p_plan_tasks => p_plan_tasks
   				   , x_return_status => l_return_status);
   	EXCEPTION
   	   WHEN OTHERS THEN
   	      l_return_status := 'E';
   	END;
   	IF l_return_status <> 'S' THEN
   	   DELETE FROM wms_repl_demand_gtmp WHERE repl_level = (Nvl(p_repl_level,1)+1);
   	END IF;

   END IF;


EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('PROCESS_REPLENISHMENT: Exception block: ' || sqlcode || ', ' || sqlerrm);
      END IF;
      --
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --
END PROCESS_REPLENISHMENT;




PROCEDURE CREATE_REPL_MOVE_ORDER(p_Repl_level           IN NUMBER,
				 p_repl_type            IN NUMBER,
				 p_consol_item_repl_tbl IN OUT NOCOPY CONSOL_ITEM_REPL_TBL,
                                 p_Create_Reservation   IN VARCHAR2,
                                 p_Repl_Lot_Size        IN NUMBER,
                                 p_Auto_Allocate        IN VARCHAR2,
                                 p_Plan_Tasks           IN VARCHAR2,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_msg_count            OUT NOCOPY NUMBER,
                                 x_msg_data             OUT NOCOPY VARCHAR2
				 )
  IS

     -- Note: UI will insure that if p_Create_Reservation  = No then p_Auto_Allocate must be No
     -- In case of Push Replenishement, once all replenishment tasks are
     -- completed, user will perform pick release manually.
     -- Just to keep in mind, we do not distinguish dynamic and push in the Allocate_repl_move_order Conc Request

     l_trohdr_rec       INV_Move_Order_PUB.Trohdr_Rec_Type;
     l_trohdr_val_rec   INV_Move_Order_PUB.Trohdr_Val_Rec_Type;
     l_x_trohdr_rec     INV_Move_Order_PUB.Trohdr_Rec_Type;
     l_x_trohdr_val_rec INV_Move_Order_PUB.Trohdr_Val_Rec_Type;
     l_commit           VARCHAR2(1) := FND_API.G_TRUE;

     l_trolin_tbl       INV_Move_Order_PUB.Trolin_Tbl_Type;
     l_trolin_val_tbl   INV_Move_Order_PUB.Trolin_Val_Tbl_Type;
     l_x_trolin_tbl     INV_Move_Order_PUB.Trolin_Tbl_Type;
     l_x_trolin_val_tbl INV_Move_Order_PUB.Trolin_Val_Tbl_Type;

     l_return_status VARCHAR2(1);
     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(1000);
     l_msg         VARCHAR2(250);
     l_plan_tasks BOOLEAN;
     l_repl_lot_size_prim NUMBER;

     -- Multi step change
     l_source_sub_atr NUMBER;
     l_create_qty NUMBER;
     l_prev_item_id NUMBER;
     l_prev_sub_code VARCHAR2(10);

     l_item_id_tb num_tab;
     l_org_id_tb num_tab;
     l_demand_header_id_tb num_tab;
     l_demand_line_id_tb num_tab;
     l_demand_type_id_tb num_tab;
     l_requested_quantity_tb num_tab;
     l_requested_quantity_uom_tb uom_tab;
     l_quantity_in_repl_uom_tb num_tab;
     l_expected_ship_date_tb date_tab;
     l_repl_to_sub_code_tb char_tab;
     l_repl_UOM_CODE_tb uom_tab;
     l_next_repl_cntr NUMBER := 0;

     l_del_index NUMBER;
     l_del_consol_item_tb num_tab;

     l_src_sub     VARCHAR2(10);
     l_order_count NUMBER ;

     l_demand_header_id            NUMBER;
     L_demand_line_id              NUMBER;
     L_demand_line_detail_id       NUMBER;
     L_demand_quantity             NUMBER;
     L_demand_quantity_in_repl_uom NUMBER;
     L_demand_uom_code             VARCHAR2(3);
     L_demand_type_id              NUMBER;
     L_sequence_id                 NUMBER;
     l_expected_ship_date          date;
     l_repl_level                  NUMBER;
     l_repl_type                   NUMBER;

     l_repl_UOM_code               VARCHAR2(3);
     l_Repl_Lot_Size               NUMBER;

     l_rsv_tbl_tmp    inv_reservation_global.mtl_reservation_tbl_type;
     l_rsv_rec            inv_reservation_global.mtl_reservation_tbl_type;
     l_serial_number      inv_reservation_global.serial_number_tbl_type;
     l_to_serial_number   inv_reservation_global.serial_number_tbl_type;
     l_quantity_reserved  NUMBER;
     l_quantity_reserved2 NUMBER;
     l_rsv_id             NUMBER;
     l_error_code         NUMBER;
     l_mo_uom_code        VARCHAR2(3);

     l_detail_info_tab             WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
     l_in_rec                      WSH_INTERFACE_EXT_GRP.detailInRecType;
     l_out_rec                     WSH_INTERFACE_EXT_GRP.detailOutRecType;

     l_rsv_temp_rec   inv_reservation_global.mtl_reservation_rec_type;
     l_rsv_temp_rec_2 inv_reservation_global.mtl_reservation_rec_type;
     l_line_num           NUMBER  ;

     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     l_index                 NUMBER;
     l_prev_org_id           NUMBER;
     l_MAX_MINMAX_QUANTITY   NUMBER;
     l_mtl_reservation_count NUMBER;
     l_fixed_lot_multiple    NUMBER;
     l_src_pick_uom          VARCHAR2(3);
     l_txn_prim_qty          NUMBER;


     -- For bulk upload in the WRD table
     l_organization_id_tab  num_tab;
     l_mo_header_id_tab  num_tab;
     l_mo_line_id_tab  num_tab;
     l_demand_header_id_tab  num_tab;
     l_demand_line_id_tab  num_tab;
     l_demand_line_detail_id_tab  num_tab;
     l_demand_type_id_tab  num_tab;
     l_item_id_tab  num_tab;
     l_demand_uom_code_tab  uom_tab;
     l_demand_quantity_tab  num_tab;
     l_sequence_id_tab  num_tab;
     l_repl_level_tab  num_tab;
     l_repl_type_tab  num_tab;

     l_conversion  NUMBER;

     l_quantity_detailed NUMBER;
     l_quantity_detailed_conv NUMBER;
     l_num_detail_recs NUMBER;
     l_prim_quantity_detailed NUMBER;
     l_mo_line_id NUMBER;
     l_task_id NUMBER;

     CURSOR c_demand_lines_for_item(p_org_id NUMBER, p_item_id number, P_FP_SUB VARCHAR2) IS
	Select repl_sequence_id,
	  demand_header_id,
	  demand_line_id,
	  demand_line_detail_id,
	  demand_type_id,
	  quantity,
	  uom_code,
	  expected_ship_date,
	  quantity_in_repl_uom,
	  repl_uom_code,
	  Nvl(repl_level,1),
	  repl_type
	  FROM WMS_REPL_DEMAND_GTMP
	  WHERE ORGANIZATION_ID = p_org_id
	  AND inventory_item_id = p_item_id
	  AND REPL_TO_SUBINVENTORY_CODE = P_FP_SUB
	  order by Repl_Sequence_id;

     CURSOR c_mmtt_rec IS
      SELECT transaction_temp_id
        FROM mtl_material_transactions_temp
	WHERE move_order_line_id = l_mo_line_id;

BEGIN
   --Note: by the time this API is called p_consol_item_repl_tbl(i).final_replenishment_qty
   -- will store the Correct qty (rounded up) to create replenishment MO for each Item

   l_src_sub := NULL;

   l_trohdr_rec.created_by             := fnd_global.user_id;
   l_trohdr_rec.creation_date          := sysdate;
   l_trohdr_rec.header_status          := INV_Globals.g_to_status_preapproved;
   l_trohdr_rec.last_updated_by        := fnd_global.user_id;
   l_trohdr_rec.last_update_date       := sysdate;
   l_trohdr_rec.last_update_login      := fnd_global.user_id;
   l_trohdr_rec.organization_id        := NULL; -- assigned inside the loop
   l_trohdr_rec.status_date            := sysdate;
   l_trohdr_rec.move_order_type        := INV_GLOBALS.G_MOVE_ORDER_REPLENISHMENT;
   l_trohdr_rec.transaction_type_id    := INV_GLOBALS.G_TYPE_TRANSFER_ORDER_SUBXFR;
   l_trohdr_rec.operation              := INV_GLOBALS.G_OPR_CREATE;
   l_trohdr_rec.db_flag                :=   FND_API.G_TRUE;

   -- Multi step change
   l_item_id_tb.DELETE;
   l_org_id_tb.DELETE;
   l_demand_header_id_tb.DELETE;
   l_demand_line_id_tb.DELETE;
   l_demand_type_id_tb.DELETE;
   l_requested_quantity_tb.DELETE;
   l_requested_quantity_uom_tb.DELETE;
   l_quantity_in_repl_uom_tb.DELETE;
   l_expected_ship_date_tb.DELETE;
   l_repl_to_sub_code_tb.DELETE;
   l_repl_uom_code_tb.DELETE;
   l_next_repl_cntr := 1;


   IF l_debug = 1 THEN
      print_debug('Inside the API CREATE_REPL_MOVE_ORDER');
   END IF;

   l_del_index := 0;
   FOR i IN p_consol_item_repl_tbl.FIRST.. p_consol_item_repl_tbl.LAST LOOP


      IF (NOT p_consol_item_repl_tbl.exists(i)) THEN

	 IF (l_debug = 1) THEN
	    print_debug('CURRENT INDEX IN THE CONSOL TABLE HAS BEEN Discarded - moving TO next consol RECORD' );

	 END IF;
       ELSE



	 IF l_debug = 1 THEN
	    print_debug('Final Replenishment Qty for item - '|| p_consol_item_repl_tbl(i).Item_id
			||' ,Qty : '||p_consol_item_repl_tbl(i).final_replenishment_qty);
	 END IF;

      IF p_consol_item_repl_tbl(i).final_replenishment_qty <= 0 THEN

	 IF l_debug = 1 THEN
	    print_debug('No Need of Replenishment for this Item....Moving to next consol Item');
	 END IF;

       ELSE

	 --******* Create Move Order Header per organization ******
	 -- Per organization, create a single MO header for all items. p_consol_item_repl_tbl has recorde ordered by
	 -- organization_id

	 IF (l_prev_org_id IS NULL) OR (l_prev_org_id <> p_consol_item_repl_tbl(i).organization_id) THEN
	    --values for other parameters for header as same so assigned outside the loop

	    l_trohdr_rec.organization_id := p_consol_item_repl_tbl(i).organization_id;

	    -- Create MO Header
	    IF l_debug = 1 THEN
	       print_debug('CALLING INV_Move_Order_PUB.Create_Move_Order_Header');
	    END IF;

	    INV_Move_Order_PUB.Create_Move_Order_Header(p_api_version_number => 1.0,
							p_init_msg_list      => FND_API.G_FALSE,
							p_return_values      => FND_API.G_TRUE,
							p_commit             => l_commit,
							x_return_status      => l_return_status,
							x_msg_count          => l_msg_count,
							x_msg_data           => l_msg_data,
							p_trohdr_rec         => l_trohdr_rec,
							p_trohdr_val_rec     => l_trohdr_val_rec,
							x_trohdr_rec         => l_x_trohdr_rec,
							x_trohdr_val_rec     => l_x_trohdr_val_rec,
							p_validation_flag    => inv_move_order_pub.g_validation_yes
							);


	    IF l_debug = 1 THEN
	       print_debug('After Calling Create_Move_Order_Header');
	    END IF;

	    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	       IF l_debug = 1 THEN
		  print_debug('Creating MO Header failed with unexpected error returning message: ' ||
			      l_msg_data);
	       END IF;
	       RAISE fnd_api.g_exc_unexpected_error;
	       -- If cant create a common MOH, do no repl stuff
	     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       IF l_debug = 1 THEN
		  print_debug('Creating MO Header failed with expected error returning message: ' ||
			      l_msg_data);
	       END IF;
	       RAISE fnd_api.g_exc_error;
	       -- If cant create a common MOH, do no repl stuff
	     ELSE
	       IF l_debug = 1 THEN
		  print_debug('Creating MO Header returned success with MO Header Id: ' || l_x_trohdr_rec.header_id);
	       END IF;
	    END IF;

	    --set line number for MO lines under this header
	    l_line_num := 0;

	 END IF; --Create MO header per organization

	 --******* Create Move Order Line for a mover order header in an organization ******
	 -- Create MO Lines for all Items in the pl/sql table under the same MO header for an organization
	 -- Create replenishment MO lines only if the quantity can not be fulfilled by available OH or Open MO

	 SAVEPOINT Current_MOL_SP;

	 -- Get the source sub from the item+sub desktop form for the Front Pick Sub OR let rules
	 -- engine decide while performing allocation
         IF l_debug = 1 THEN
	    print_debug('Calling Get_Source_Sub_Dest_Loc_Info....');
	 END IF;
	 -- Get source sub and loc information for the repl MO, if available
	 l_return_status := fnd_api.g_ret_sts_success;
	 Get_Source_Sub_Dest_Loc_Info(p_Org_id              => p_consol_item_repl_tbl(i).ORGANIZATION_ID,
				      p_Item_id             => p_consol_item_repl_tbl(i).Item_id,
				      p_Picking_Sub         => p_consol_item_repl_tbl(i).Repl_To_Subinventory_code,
				      x_source_sub          => l_src_sub,
				      x_src_pick_uom        => l_src_pick_uom,
				      x_MAX_MINMAX_QUANTITY => l_MAX_MINMAX_QUANTITY,
				      x_fixed_lot_multiple  => l_fixed_lot_multiple,
				      x_return_status       => l_return_status);

	 IF l_return_status <> fnd_api.g_ret_sts_success THEN
	    GOTO next_consol_rec;
	 END IF;

	 -- Final Replenishment Quantity = Maximum of min-max qty + Sum of
	 -- unallocated demand + Sum of Allocated but not executed tasks
	 -- Available On Hand - Sum of unallocated replenishment move orders with destination sub ] .

	 --By the time, code comes at this point, last 2 are already
	 --subtracted. Maximum of min-max qty should alWays be in the fixed
	 --lot multiple. It is restrained by the UI on the item-sub form

	 p_consol_item_repl_tbl(i).final_replenishment_qty :=
	   p_consol_item_repl_tbl(i).final_replenishment_qty + L_MAX_MINMAX_QUANTITY;

	 IF l_debug = 1 THEN
	    print_debug('getting right qty and uom for the move order line creation' );
	    print_debug('Current Final Qty: '||p_consol_item_repl_tbl(i).final_replenishment_qty);
	 END IF;

	 -- For DYNAMIC REPL, How to stamp the qty and UOM on the newly created Replenishment Move Order
	 --example:
	 -- Destination Sub = CASE (Pick_UOM = CS)
	 -- 1CS = 10 Ea
	 -- Final calculated Repl Qty = 3CS
	 --
	 -- Fixed-Lot-multiplier(200 ea)	Src-sub(bulk)	Pick-uom-Src-sub (PLT=100 Ea)	Example (Qty ON repl mo)
	 -- Y	                            Y                       	Y		2PLT
	 -- Y	                            y                          	N		20CS
	 -- n                                 y                   	y       	1PLT
	 -- n                                 y                   	n       	10CS
	 -- n                                 n             	Not applicable   	3CS
	 --

	 -- If open MO and available Onhand can offset the current demand, then do not create Replenishment MO for those records
	 IF p_consol_item_repl_tbl(i).final_replenishment_qty > 0 THEN

	    -- Upp the replenishment qty appropriately

	    --set the item info in cache
	    IF inv_cache.set_item_rec(p_consol_item_repl_tbl(i).ORGANIZATION_ID, p_consol_item_repl_tbl(i).item_id) THEN

	       -- for Dynamic replenishment or next level repl, p_Repl_Lot_Size will be passed as NULL
	       IF p_repl_lot_size IS NULL THEN
		  IF l_debug = 1 THEN
		     print_debug('repl_lot_size is NULL, Either Dynamic Or Next LEVEL Repl');
		  END IF;

		  -- means final qty and uom code need to change with following condition
		  IF l_fixed_lot_multiple <> -1 OR (l_src_pick_uom IS NOT NULL AND
						    l_src_pick_uom <> p_consol_item_repl_tbl(i).repl_uom_code) THEN



		     IF l_fixed_lot_multiple <> -1 THEN
			l_repl_lot_size_prim := l_fixed_lot_multiple;

			-- If lot multiplier is specified and src_pick_uom IS specified
			-- The qty should be tracked in src_pick_uom
			IF l_src_pick_uom IS NOT NULL THEN  -- pushing with bug 7201888
			   l_conversion := ROUND(get_conversion_rate(p_consol_item_repl_tbl(i).Item_id,
								       l_src_pick_uom,
								     inv_cache.item_rec.primary_uom_code),
						 g_conversion_precision);

			END IF;

		      ELSIF l_src_pick_uom IS NOT NULL THEN
			-- GET THE MULITPLE OF THE "UNIT QTY CONVERSION OF the source sub pick UOM"
			l_conversion := ROUND(get_conversion_rate(p_consol_item_repl_tbl(i).Item_id,
									  l_src_pick_uom,
									  inv_cache.item_rec.primary_uom_code),
						      g_conversion_precision);


			IF l_debug = 1 THEN
			   print_debug('Unit Conversion qty for Source UOM :'||l_conversion);
			END IF;

			-- what if UOM conversion not defined
			IF l_conversion  > 0 THEN
			   l_repl_lot_size_prim := l_conversion;
			END IF;
		     END IF; -- IF l_fixed_lot_multiple <> -1


		     IF l_debug = 1 THEN
			print_debug('Value of repl_lot_size in Primary UOM: '||l_repl_lot_size_prim);
		     END IF;

		     -- GET THE FINAL PRIMARY MOVE ORDER QTY
		     -- This UOM conversion will be defined, otherwise code
		     -- will not come here, repl_uom_code in consol table
		     -- would not have been marked otherwise
		     l_txn_prim_qty :=
		       ROUND((p_consol_item_repl_tbl(i).final_replenishment_qty * get_conversion_rate(p_consol_item_repl_tbl(i).Item_id,
									 p_consol_item_repl_tbl(i).repl_uom_code,
									inv_cache.item_rec.primary_uom_code)),
			     g_conversion_precision);

		     -- UPP the PRIMARY QTY in the INTEGRAL MULITPLE of l_repl_lot_size_prim
		     -- to habndle the case in which Repl_Lot_Size is exact multiple of repl qty
		     IF MOD(l_txn_prim_qty,l_Repl_Lot_Size_prim) <> 0 THEN
			l_txn_prim_qty :=  l_repl_lot_size_prim * (1 + FLOOR(l_txn_prim_qty/l_repl_lot_size_prim));
		     END IF;


		     -- Now take care of stamping right UOM and updated qty
		     IF (l_src_pick_uom IS NOT NULL)  THEN
			IF l_conversion  > 0 THEN
			   -- convert the final qty into apporopriate qty based on l_src_pick_uom
			   p_consol_item_repl_tbl(i).final_replenishment_qty :=
			     ROUND((l_txn_prim_qty * get_conversion_rate(p_consol_item_repl_tbl(i).Item_id,
									 inv_cache.item_rec.primary_uom_code,
									 l_src_pick_uom )),
				   g_conversion_precision);

			   -- UPDATE THE UOM CODE AS WELL
			   p_consol_item_repl_tbl(i).repl_uom_code := l_src_pick_uom;
			END IF;

		      ELSE -- means source sub UOM code is not available
			--ADJUST THE INCREASED QTY IN THE p_consol_item_repl_tbl(i).repl_uom_code uom only
			IF l_conversion  > 0 THEN
			   p_consol_item_repl_tbl(i).final_replenishment_qty :=
			     ROUND((l_txn_prim_qty * get_conversion_rate(p_consol_item_repl_tbl(i).Item_id,
									 inv_cache.item_rec.primary_uom_code,
									 p_consol_item_repl_tbl(i).Repl_UOM_Code )),
				   g_conversion_precision);

			   -- UOM_CODE remains same here
			END IF; --	IF l_conversion  > 0
		     END IF; --IF (l_src_pick_uom IS NOT NULL)

		  END IF; -- means final qty and uom code need TO CHANGE


		ELSE -- means p_repl_lot_size IS NOT NULL, First level of PUSH Replenishment
		  -- For Push Replenishment NULL value for p_Repl_Lot_Size will be treated as 1
		  IF p_Repl_Lot_Size IS NULL THEN
		     L_Repl_Lot_Size := 1;
		   ELSE
		     L_Repl_Lot_Size := p_Repl_Lot_Size;
		  END IF;

		  -- to habndle the case in which Repl_Lot_Size is exact multiple of repl qty
		  IF MOD(p_consol_item_repl_tbl(i).final_replenishment_qty,l_Repl_Lot_Size) <> 0 THEN

		     p_consol_item_repl_tbl(i).final_replenishment_qty :=
		       l_Repl_Lot_Size * (1 + FLOOR(p_consol_item_repl_tbl(i).final_replenishment_qty / l_Repl_Lot_Size));
		  END IF;
	       END IF; -- for p_repl_lot_size IS NOT NULL

	    END IF; -- FOR inv_cache.set_item_rec

	  ELSE  -- menas final_replenishment_qty <= 0
	    -- Mark negative qty to avoid further considerations and creating MO
	    p_consol_item_repl_tbl(i).final_replenishment_qty := -9999;

	 END IF;  --for final_replenishment_qty > 0




	 IF l_debug = 1 THEN
	    print_debug('After Upp qty by Repl_Lot_Size, Final Repl qty :'||
			p_consol_item_repl_tbl(i).final_replenishment_qty);
	    print_debug('After Upp qty by Repl_Lot_Size, Final UOM CODE :'||
			p_consol_item_repl_tbl(i).repl_uom_code);
	 END IF;


	 -- While creating the MO, we have decided NOT to check for
	 -- availability of item. Even if the qty is available now, still. create	repl MO.
	 -- Customer might be expecting some shipment and he would like Move Order to be already created.

	 -- We do not create MO lines qty in the multiple of 'fixed lot multiple' specified on the Item-sub form.
	 --It will create too many move order lines and will end up having
	 --remaining left over quantities with lot of lines.
	 --Instead let rules engine allocate in that fashion if needed.

	 IF p_consol_item_repl_tbl(i).final_replenishment_qty <> -9999 THEN

	    l_trolin_tbl.DELETE;
	    l_order_count:= 1;

	    -- Create MO Lines
	    IF l_debug = 1 THEN
	       print_debug('CALLING INV_Move_Order_PUB.Create_Move_Order_Lines');
	    END IF;
	    l_line_num := l_line_num + 1;
	    l_trolin_tbl(l_order_count).header_id := l_x_trohdr_rec.header_id;
	    l_trolin_tbl(l_order_count).created_by := fnd_global.user_id;
	    l_trolin_tbl(l_order_count).creation_date := sysdate;
	    l_trolin_tbl(l_order_count).date_required := p_consol_item_repl_tbl(i).date_required;
	    l_trolin_tbl(l_order_count).from_subinventory_code := l_src_sub;
	    l_trolin_tbl(l_order_count).line_number             := l_line_num;
	    l_trolin_tbl(l_order_count).inventory_item_id := p_consol_item_repl_tbl(i).Item_id;
	    l_trolin_tbl(l_order_count).last_updated_by := fnd_global.user_id;
	    l_trolin_tbl(l_order_count).last_update_date := sysdate;
	    l_trolin_tbl(l_order_count).last_update_login := fnd_global.user_id;
	    l_trolin_tbl(l_order_count).line_status := INV_Globals.g_to_status_preapproved;
	    l_trolin_tbl(l_order_count).organization_id := p_consol_item_repl_tbl(i).ORGANIZATION_ID;
	    l_trolin_tbl(l_order_count).quantity := p_consol_item_repl_tbl(i).final_replenishment_qty;
	    l_trolin_tbl(l_order_count).uom_code := p_consol_item_repl_tbl(i).Repl_UOM_Code;
	    l_trolin_tbl(l_order_count).status_date := sysdate;
	    l_trolin_tbl(l_order_count).to_subinventory_code := p_consol_item_repl_tbl(i).Repl_To_Subinventory_code;
	    l_trolin_tbl(l_order_count).to_locator_id := NULL; -- Let Rule engine decide based ON avail_capacity
	    l_trolin_tbl(l_order_count).transaction_source_type_id :=INV_GLOBALS.G_SOURCETYPE_MOVEORDER; -- 4
	    l_trolin_tbl(l_order_count).transaction_type_id := INV_GLOBALS.G_TYPE_TRANSFER_ORDER_SUBXFR;
	    l_trolin_tbl(l_order_count).db_flag := FND_API.G_TRUE;
	    l_trolin_tbl(l_order_count).operation := INV_GLOBALS.G_OPR_CREATE;


	    -- NO NEED TO CALL THIS API FOR EACH LINE. STORE ALL LINES FOR A
	    -- mo header IN THE l_trolin_tbl TABLE AND THEN CALL ONLY ONCE FOR
	    -- PERFORMACE REASON. THEN FOR EACH MO LINE FROM THE SAME TABLE,
	    -- CREATE RESERVATION FOR CORRESPONDING DEMAND LINES, IF NEEDED
	    l_return_status := fnd_api.g_ret_sts_success;
	    INV_Move_Order_PUB.Create_Move_Order_Lines(
						       p_api_version_number => 1.0,
						       p_init_msg_list  => FND_API.G_FALSE,
						       p_commit         => l_commit,
						       x_return_status  => l_return_status,
						       x_msg_count      => l_msg_count,
						       x_msg_data       => l_msg_data,
						       p_trolin_tbl     => l_trolin_tbl,
						       p_trolin_val_tbl => l_trolin_val_tbl,
						       x_trolin_tbl     => l_x_trolin_tbl,
						       x_trolin_val_tbl => l_x_trolin_val_tbl,
						       p_validation_flag     => 'Y'  );


	    IF L_DEBUG = 1 THEN
	       print_debug('After call to INV_Move_Order_PUB.Create_Move_Order_Lines');
	    END IF;

	    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

	       IF L_DEBUG = 1 THEN
		  print_debug('INV_Move_Order_PUB.Create_Move_Order_Lines failed with expected error returning message: ' || l_msg_data || l_msg_count);
	       END IF;
	       IF l_msg_count > 0 THEN
		  FOR i in 1 .. l_msg_count LOOP
		     l_msg := fnd_msg_pub.get(i, 'F');
		     print_debug(l_msg);
		     fnd_msg_pub.delete_msg(i);
		  END LOOP;
	       END IF;
	       l_line_num := l_line_num - 1;
	       l_trolin_tbl.DELETE(l_order_count);
	       GOTO next_consol_rec;
	     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       IF L_DEBUG= 1 THEN
		  print_debug('INV_Move_Order_PUB.Create_Move_Order_Lines failed with unexpected error returning message: ' || l_msg_data);
	       END IF;

	       IF l_msg_count > 0 THEN
		  FOR i in 1 .. l_msg_count LOOP
		     l_msg := fnd_msg_pub.get(i, 'F');
		     print_debug(l_msg);
		     fnd_msg_pub.delete_msg(i);
		  END LOOP;
	       END IF;
	       l_line_num := l_line_num - 1;
	       l_trolin_tbl.DELETE(l_order_count);
	       GOTO next_consol_rec;
	     ELSE
	       IF L_DEBUG = 1 THEN
		  print_debug('INV_Move_Order_PUB.Create_Move_Order_Lines returned success');
	       END IF;
	    END IF;



	    IF p_Create_Reservation = 'Y'  THEN --and  Nvl(repl_level,1) = 1 THEN
	       IF L_DEBUG = 1 THEN
		  print_debug('******Create_Reservation = Y and  repl_LEVEL = 1');
	       END IF;
	       l_index := 1;

	       -- Loop through all demand lines for the repl MO and Create rsv
	       -- At this point, for an item, sum (quantity) for demand lines in the GTMP table should be in sync with mol_qty
	       OPEN c_demand_lines_for_item(p_consol_item_repl_tbl(i).ORGANIZATION_ID, p_consol_item_repl_tbl(i).item_id, p_consol_item_repl_tbl(i).repl_to_subinventory_code);

	       LOOP
		  FETCH c_demand_lines_for_item INTO
		    L_sequence_id, L_demand_header_id,
		    L_demand_line_id,
		    L_demand_line_detail_id, l_demand_type_id,
		    L_demand_quantity,
		    L_demand_uom_code, l_expected_ship_date,
		    l_demand_quantity_in_repl_uom, l_repl_uom_code,
		    l_repl_level, l_repl_type;
		  EXIT WHEN c_demand_lines_for_item%notfound;

		  IF L_DEBUG = 1 THEN
		     print_debug('Fetch the Demand Line detail id: '|| L_demand_line_detail_id);
		     print_debug('Check if reservation exists');
		  END IF;

		  -- Create Org Level reservation for every demand line, if it does not exist

		  -- Check if an Org level reservation exists for corresponding order line
		  -- Clear out old values
		  l_rsv_temp_rec := l_rsv_temp_rec_2;

		  -- Assign all new values
		  l_rsv_temp_rec.organization_id := p_consol_item_repl_tbl(i).ORGANIZATION_ID;
		  l_rsv_temp_rec.inventory_item_id := p_consol_item_repl_tbl(i).item_id;
		  l_rsv_temp_rec.DEMAND_SOURCE_TYPE_ID := l_demand_type_id;
		  l_rsv_temp_rec.DEMAND_SOURCE_HEADER_ID := l_demand_header_id;
		  l_rsv_temp_rec.DEMAND_SOURCE_LINE_ID := l_demand_line_id;

		  l_return_status := fnd_api.g_ret_sts_success;
		  inv_reservation_pub.query_reservation(p_api_version_number =>1.0,
							x_return_status => l_return_status,
							x_msg_count   => x_msg_count,
							x_msg_data    => x_msg_data,
							p_query_input => l_rsv_temp_rec,
							x_mtl_reservation_tbl  => l_rsv_rec,
							x_mtl_reservation_tbl_count => l_mtl_reservation_count,
							x_error_code => l_error_code);

		  IF l_RETURN_status = fnd_api.g_ret_sts_success THEN
		     IF L_DEBUG = 1 THEN
			PRINT_DEBUG('Number of reservations found: ' || l_mtl_reservation_count);
		     END IF;
		   ELSE
		     IF L_DEBUG = 1 THEN
			PRINT_DEBUG('Error: ' || X_msg_data);
		     END IF;
		     l_line_num := l_line_num - 1;
		     l_trolin_tbl.DELETE(l_order_count);
		     GOTO next_consol_rec;
		  END IF;

		  -- If no org level reservation found then create it

		  IF l_mtl_reservation_count = 0 then
		     -- Create high-level reservation
		     IF L_DEBUG = 1 THEN
			PRINT_DEBUG('Calling Create_RSV >>>');
		     END IF;
		     l_return_status := fnd_api.g_ret_sts_success;
		     Create_RSV(p_replenishment_type => 1, --  1- Stock Up/Push; 2- Dynamic/Pull
				l_debug => l_debug,
				l_organization_id => p_consol_item_repl_tbl(i).ORGANIZATION_ID,
				l_inventory_item_id => p_consol_item_repl_tbl(i).item_id,
				l_demand_type_id => l_demand_type_id,
				l_demand_so_header_id => L_demand_header_id,
				l_demand_line_id => L_demand_line_id,
				l_split_wdd_id => NULL,
				l_primary_uom_code => l_demand_uom_code,
				l_supply_uom_code => L_mo_uom_code,
				l_atd_qty => L_demand_quantity,
				l_atd_prim_qty => L_demand_quantity,
				l_supply_type_id => 13,
				l_supply_header_id => NULL, -- since high level rsv
				l_supply_line_id => NULL, -- since high level rsv
				l_supply_line_detail_id => NULL, -- since high level rsv
				l_supply_expected_time => SYSDATE,
				l_demand_expected_time => l_expected_ship_date,
				l_rsv_rec => l_rsv_temp_rec, -- only need to provide good enough information FOR high LEVEL reservation, only one row will do
		       l_serial_number => l_serial_number,
		       l_to_serial_number => l_to_serial_number,
		       l_quantity_reserved => l_quantity_reserved,
		       l_quantity_reserved2 => l_quantity_reserved2,
		       l_rsv_id => l_rsv_id,
		       x_return_status => l_return_status,
		       x_msg_count => x_msg_count,
		       x_msg_data => x_msg_data
		       );

		     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			IF (l_debug = 1) THEN
			   print_debug('Error returned from create_reservation API: ' || l_return_status);
			END IF;
			l_line_num := l_line_num - 1;
			l_trolin_tbl.DELETE(l_order_count);
			GOTO next_consol_rec;
		      ELSE -- reservation creation successful
			IF (l_debug = 1) THEN
			   print_debug('Successfully created a RSV record');
			END IF;

		     END IF;

		   ELSE -- means l_mtl_reservation_count <> 0, rsv already exists
		     --DO NOTHING
		     NULL;

		  END IF; -- for l_mtl_reservation_count ==  0

		  -- Put the WDDs to 'Replenishment Requested' RR status
		  -- Call Shipping API to mark the Delivery Detail to 'RR'

		  IF l_demand_type_id <> 4 THEN
		     -- Mark wdd RR only for first level
		     -- WHEN demand is WDD and NOT mover order of next level
		     IF (l_debug = 1) THEN
			print_debug('Mark Delivery Detail to RR');
		     END IF;
		     update_wdd_repl_status (p_deliv_detail_id   =>  l_demand_line_detail_id
					     , p_repl_status     => 'R' -- for completed status
					     , x_return_status   => l_return_status
					     );

		     IF l_return_status <> fnd_api.g_ret_sts_success THEN
			l_line_num := l_line_num - 1;
			l_trolin_tbl.DELETE(l_order_count);
			GOTO next_consol_rec;
		     END IF;
		  END IF; -- for   IF l_demand_type_id <> 4 THEN

		  -- Add an entry into WRD table for consumed Demand lines
		  -- STORE DATA here and do BULK INSERT later
		  l_organization_id_tab(l_index) := p_consol_item_repl_tbl(i).organization_id;
		  l_mo_header_id_tab(l_index) := l_x_trolin_tbl(l_order_count).header_id;
		  l_mo_line_id_tab(l_index) := l_x_trolin_tbl(l_order_count).line_id;
		  l_demand_header_id_tab(l_index) := l_demand_header_id;
		  l_demand_line_id_tab(l_index) := l_demand_line_id;
		  l_demand_line_detail_id_tab(l_index) :=  l_demand_line_detail_id;
		  l_demand_type_id_tab(l_index) := l_demand_type_id;
		  l_item_id_tab(l_index) :=  p_consol_item_repl_tbl(i).item_id;
		  l_demand_uom_code_tab(l_index) :=  l_demand_uom_code;
		  l_demand_quantity_tab(l_index) := l_demand_quantity;
		  l_sequence_id_tab(l_index) := l_sequence_id;
		  l_repl_level_tab(l_index)  := l_repl_level;
		  l_repl_type_tab(l_index)   := l_repl_type;
		  l_index := l_index +1;


		  -- NOTE: For all demand records that would be consumed by newly created MO lines, corresponding
		  -- entry in the GTMP table will be deleted at the end of the processing of the replenishment calls

	       END LOOP; -- for each demand line for an item
	       CLOSE c_demand_lines_for_item;

	       IF (l_debug = 1) THEN
		  print_debug('Bulk Upload records in WRD');
	       END IF;

	       -- BULK UPLOAD ALL DEMAND RECORDS IN THE WRD TABLE
	       FORALL k in 1 .. l_demand_line_detail_id_tab.COUNT()
		 INSERT INTO wms_replenishment_details
		 (Replenishment_id,
		  Organization_id,
		  source_header_id,
		  Source_line_id,
		  Source_line_detail_id,
		  Source_type_id,
		  demand_header_id,
		  demand_line_id,
		  demand_line_detail_id,
		  demand_type_id,
		  Inventory_item_id,
		  Primary_UOM,
		  Primary_Quantity,
		  demand_sort_order,
		  repl_level,
		  repl_type,
		  CREATION_DATE,
		  LAST_UPDATE_DATE,
		  CREATED_BY,
		  LAST_UPDATED_BY,
		  LAST_UPDATE_LOGIN
		  )VALUES (
			   WMS_REPLENISHMENT_DETAILS_S.NEXTVAL,
			   l_organization_id_tab(k),
			   l_mo_header_id_tab(k),
			   l_mo_line_id_tab(k),
			   NULL,
			   4, --  For Move Orders
			   l_demand_header_id_tab(k),
			   l_demand_line_id_tab(k),
			   l_demand_line_detail_id_tab(k),
			   l_demand_type_id_tab(k),
			   l_item_id_tab(k),
			   l_demand_uom_code_tab(k),
			   l_demand_quantity_tab(k),
			   l_sequence_id_tab(k),
			   l_repl_level_tab(k),
			   l_repl_type_tab(k),
			   Sysdate,
			   Sysdate,
			   fnd_global.user_id,
			   fnd_global.user_id,
			   fnd_global.user_id);

	       -- CLEAR all entries in the tables
	       l_organization_id_tab.DELETE;
	       l_mo_header_id_tab.DELETE;
	       l_mo_line_id_tab.DELETE;
	       l_demand_header_id_tab.DELETE;
	       l_demand_line_id_tab.DELETE;
	       l_demand_line_detail_id_tab.DELETE;
	       l_demand_type_id_tab.DELETE;
	       l_item_id_tab.DELETE;
	       l_demand_uom_code_tab.DELETE;
	       l_demand_quantity_tab.DELETE;
	       l_sequence_id_tab.DELETE;
	       l_repl_level_tab.DELETE;
	       l_repl_type_tab.DELETE;


	       IF (l_debug = 1) THEN
		  print_debug('After Bulk Upload records in WRD');
	       END IF;


	     ELSIF  ( p_repl_level > 1 AND  p_Create_Reservation = 'N') THEN

		-- means next level of replenishment
		-- just insert records into the WRD table
		IF L_DEBUG = 1 THEN
		   print_debug('******Create_Reservation = N and Next LEVEL repl');
		   print_debug('Bulk Upload records in WRD');
		END IF;


		-----------------------
		-- this is within the loop for each item

		IF inv_cache.set_item_rec(p_consol_item_repl_tbl(i).ORGANIZATION_ID, p_consol_item_repl_tbl(i).item_id) THEN
		   l_txn_prim_qty :=
		     ROUND((p_consol_item_repl_tbl(i).final_replenishment_qty * get_conversion_rate(p_consol_item_repl_tbl(i).Item_id,
							 p_consol_item_repl_tbl(i).repl_uom_code,
							 inv_cache.item_rec.primary_uom_code)),
		   g_conversion_precision);


		   INSERT INTO wms_replenishment_details
		     (Replenishment_id,
		       Organization_id,
		       source_header_id,
		       Source_line_id,
		       Source_line_detail_id,
		       Source_type_id,
		       demand_header_id,
		       demand_line_id,
		       demand_line_detail_id,
		       demand_type_id,
		       Inventory_item_id,
		       Primary_UOM,
		       Primary_Quantity,
		       demand_sort_order,
		       repl_level,
		       repl_type,
		       CREATION_DATE,
		       LAST_UPDATE_DATE,
		       CREATED_BY,
		       LAST_UPDATED_BY,
		       LAST_UPDATE_LOGIN
		       )
      		      SELECT
		      WMS_REPLENISHMENT_DETAILS_S.NEXTVAL,       --Replenishment_id,
		      p_consol_item_repl_tbl(i).organization_id, --Organization_id,
		     l_x_trolin_tbl(1).header_id, --  source_header_id,
		     l_x_trolin_tbl(1).line_id,   --  Source_line_id,
		     NULL,                        --  Source_line_detail_id,
		     4,                           --  Source_type_id,
		     demand_header_id,
		     demand_line_id,
		     demand_line_detail_id,       -- stored as -9999 for next level
		     demand_type_id,              -- stored as 4 for next level
		     p_consol_item_repl_tbl(i).item_id,   -- Inventory_item_id,
		     inv_cache.item_rec.primary_uom_code, --  Primary_UOM,
		     l_txn_prim_qty,                      --  Primary_Quantity,
		     repl_sequence_id ,                   --demand_sort_order,
		     repl_level,
		     repl_type,
		     Sysdate,
		     Sysdate,
		     fnd_global.user_id,
		     fnd_global.user_id,
		     fnd_global.user_id
		     FROM WMS_REPL_DEMAND_GTMP
		     WHERE ORGANIZATION_ID = p_consol_item_repl_tbl(i).ORGANIZATION_ID
		     AND inventory_item_id = p_consol_item_repl_tbl(i).item_id
		     AND REPL_TO_SUBINVENTORY_CODE =  p_consol_item_repl_tbl(i).repl_to_subinventory_code;

		END IF;

		  IF (l_debug = 1) THEN
		  print_debug('After Bulk Upload records in WRD FOR NEXT LEVEL');
		  END IF;


	     ELSE -- means p_Create_Reservation    = 'N'
		     -- Do not need to do anything here. We do not need to call the shipping API to revert to original
		     --line status because For dynamic/pull replenishment p_create_Reservation  will
		     -- always be 'Y' and hence the code will never come here. For Push replenishemnt, The demand
		     -- line would not have been touched yet. So it will remain in its orignal status.

		     NULL;
	    END IF; -- for p_Create_Reservation    = 'Y'

	    -- Create Allocation if parameter is Y. For simplicity, only those mover orders will be considered for
	    -- allocation that are created newly in this program. Already existing open move orders that could
	    -- partly satisfy current demands will not be detailed.
	    -- Note: parameter p_Auto_Allocate will be 'N' if p_Create_Reservation   = 'N', UI ensures it

	    IF p_Auto_Allocate = 'Y' THEN
	       -- Call the allocation engine

	       IF (l_debug = 1) THEN
		  print_debug('l_x_trolin_tbl count :'||l_x_trolin_tbl.COUNT());
		  print_debug('Auto Allocate is Y, Calling rules engine ..MOL:' ||l_x_trolin_tbl(1).line_id);
	       END IF;

	       IF p_Plan_Tasks = 'Y' THEN
		  L_Plan_Tasks := TRUE;
		ELSE
		  L_Plan_Tasks := FALSE;
	       END IF;

	       WMS_Engine_PVT.create_suggestions(
						 p_api_version => 1.0,
						 p_init_msg_list => fnd_api.g_false,
						 p_commit => fnd_api.g_false,
						 p_validation_level => fnd_api.g_valid_level_none,
						 x_return_status => l_return_status,
						 x_msg_count => x_msg_count,
						 x_msg_data => x_msg_data,
						 p_transaction_temp_id => l_x_trolin_tbl(1).line_id,
						 p_reservations => l_rsv_tbl_tmp, --NULL value  AS no rsv FOR repl MO
						 p_suggest_serial => fnd_api.g_false,
						 p_plan_tasks => l_plan_tasks);

	       IF (l_debug = 1) THEN
		  print_debug('after calling create_suggestions API');
	       END IF;


	       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		  IF (l_debug = 1) THEN
		     print_debug('Error returned from create_suggestions API: ' || l_return_status);
		  END IF;
		  -- even though it is failing
		  -- we want to process the replenishment mo
		  -- it can be allocated later
		  -- no reverting so passing success to go to next
		  -- consol rec. Also should not do any next level
		  -- stuff which this will help to skip.
		  l_return_status := fnd_api.g_ret_sts_success;
		  GOTO next_consol_rec;


		ELSE

		  IF (l_debug = 1) THEN
		     print_debug('Success returned from create_suggestions API');
		     print_debug('Now Assign Task Type for all Repl tasks created FOR the MO Line');
		  END IF;
		  l_mo_line_id:=l_x_trolin_tbl(1).line_id;

		  OPEN c_mmtt_rec;
		  LOOP
		     FETCH c_mmtt_rec INTO l_task_id;
		     EXIT WHEN c_mmtt_rec%notfound;

		     IF (l_debug = 1) THEN
			print_debug('Assign Task Type for MMTT_id: '||l_task_id);
		     END IF;

		     wms_rule_pvt.assigntt(
					   p_api_version                => 1.0
					   , p_task_id                    => l_task_id
					   , x_return_status              => l_return_status
					   , x_msg_count                  => x_msg_count
					   , x_msg_data                   => x_msg_data
					   );

		  END LOOP;
		  CLOSE c_mmtt_rec;


	       END IF;


	       --*************
	       --update the MO line quantity_detailed field or close the MO
               BEGIN
		  SELECT NVL(SUM(primary_quantity), 0)
		    ,NVL(sum(transaction_quantity),0)
		    ,COUNT(*)
		    INTO l_prim_quantity_detailed
		    ,l_quantity_detailed_conv
		    ,l_num_detail_recs
		    FROM mtl_material_transactions_temp
		    WHERE move_order_line_id = l_x_trolin_tbl(1).line_id;

		  IF (l_debug = 1) THEN
		     print_debug('primary l_quantity detailed is :'|| l_prim_quantity_detailed);
		     print_debug('l_num_detail_recs is :'|| l_num_detail_recs);
		     print_debug('Primary UOM code     :'||inv_cache.item_rec.primary_uom_code);
		  END IF;

		  --Convert the MOL detailed qty into MOL UOM code qty
		  IF inv_cache.item_rec.primary_uom_code <> p_consol_item_repl_tbl(i).repl_uom_code THEN

		     l_quantity_detailed :=
		       ROUND((l_prim_quantity_detailed* get_conversion_rate(p_consol_item_repl_tbl(i).item_id,
									    inv_cache.item_rec.primary_uom_code,
									    p_consol_item_repl_tbl(i).Repl_UOM_Code )),
			     g_conversion_precision);

		   ELSE
		     l_quantity_detailed := l_prim_quantity_detailed;
		  END IF;


	       EXCEPTION
		  WHEN NO_DATA_FOUND THEN
		     IF (l_debug = 1) THEN
			print_debug('no detail records found');
		     END IF;
		     l_quantity_detailed       := 0;
		     l_quantity_detailed_conv  := 0;
		     l_num_detail_recs         := 0;
	       END;

		 IF (l_debug = 1) THEN
		    print_debug('Qty Detailed           :'||l_quantity_detailed );
		    print_debug('MOL Line Qty           :'||l_x_trolin_tbl(1).quantity);
		    print_debug('MOL Line Qty Delivered :'||l_x_trolin_tbl(1).quantity_delivered);
		 END IF;

	       -- NOTE: l_quantity_detailed contains all qty of MMTT related TO CURRENT mo line whether in this
	       -- RUN OR ANY previous runs
	       IF  l_quantity_detailed < (l_x_trolin_tbl(1).quantity - Nvl(l_x_trolin_tbl(1).quantity_delivered,0))  THEN -- partial allocation
		  -- update the quantity detailed correctly
		  UPDATE mtl_txn_request_lines mtrl
		    SET mtrl.quantity_detailed = l_quantity_detailed
		    where line_id = l_x_trolin_tbl(1).line_id;

		  IF (l_debug = 1) THEN
		     print_debug('Updated the detailed qty on the MO line');
		  END IF;

		ELSE -- Fully allocated
		  -- it has been completely detailed
		  -- do not close the MO, otherwise pick Drop of repl task fails
		  UPDATE mtl_txn_request_lines mtrl
		    SET mtrl.quantity_detailed = l_quantity_detailed
		    where line_id = l_x_trolin_tbl(1).line_id;

		  IF (l_debug = 1) THEN
		     print_debug('MO line completely detailed');
		  END IF;

	       END IF; -- for partial allocation

	       --*************

	       -- TODO: Blocking Multi-Level Code changes
	       -- Multi step change
	       -- Call to check to insert into temp table next level record after
	       --
	       IF (( l_prev_item_id IS NULL AND
		     l_prev_sub_code IS NULL ) OR
		   l_prev_org_id <> p_consol_item_repl_tbl(i).organization_id  OR
		   l_prev_item_id <> p_consol_item_repl_tbl(i).Item_id OR
		   l_prev_sub_code <> l_src_sub) THEN
		  l_source_sub_atr := NULL;
	       END IF;

	       IF (l_debug = 1) THEN
		  print_debug('Ging to check for Next Level of Replenishment');
	       END IF;

	       check_for_next_level_repl(p_move_order_header_id => l_x_trolin_tbl(1).header_id
					 , p_move_order_line_id => l_x_trolin_tbl(1).line_id
					 , p_organization_id => p_consol_item_repl_tbl(i).organization_id
					 , p_inventory_item_id => p_consol_item_repl_tbl(i).Item_id
					 , p_repl_level => p_repl_level
					 , x_source_sub_atr => l_source_sub_atr
					 , x_create_qty => l_create_qty
					 , x_return_status => l_return_status
					 , x_msg_count => l_msg_count
					 , x_msg_data => l_msg_data
					 );

	       -- if above api did end up computing the atr
	       -- it will return a non null value else it will return a null
	       -- value. If it returns a null, we would like to force a check
	       -- next time around.
	       IF l_source_sub_atr IS NULL THEN
		  l_prev_item_id := NULL;
		  l_prev_sub_code := NULL;
		ELSE
		  l_prev_item_id := p_consol_item_repl_tbl(i).item_id;
		  l_prev_sub_code := l_src_sub;
	       END IF;

	       IF l_create_qty > 0 THEN
		  l_item_id_tb(l_next_repl_cntr) := p_consol_item_repl_tbl(i).Item_id;
		  l_org_id_tb(l_next_repl_cntr)  := p_consol_item_repl_tbl(i).organization_id;
		  l_demand_header_id_tb(l_next_repl_cntr) := l_x_trolin_tbl(1).header_id;
		  l_demand_line_id_tb(l_next_repl_cntr)   := l_x_trolin_tbl(1).line_id;
		  l_demand_type_id_tb(l_next_repl_cntr)   := 4;
		  l_repl_to_sub_code_tb(l_next_repl_cntr) := l_src_sub;
		  l_requested_quantity_tb(l_next_repl_cntr)     := l_create_qty;
		  l_requested_quantity_uom_tb(l_next_repl_cntr) := p_consol_item_repl_tbl(i).Repl_UOM_Code;
		  l_quantity_in_repl_uom_tb(l_next_repl_cntr)   := l_create_qty;
		  l_repl_uom_code_tb(l_next_repl_cntr)          := p_consol_item_repl_tbl(i).Repl_UOM_Code;
		  l_expected_ship_date_tb(l_next_repl_cntr)     := NULL;
		  l_next_repl_cntr := l_next_repl_cntr + 1;
	       END IF;



	    END IF; -- for p_Auto_Allocate

	 END IF; -- for p_consol_item_repl_tbl(i).final_replenishment_qty  <> -9999

	 l_prev_org_id := p_consol_item_repl_tbl(i).ORGANIZATION_ID;

      END IF; --   IF p_consol_item_repl_tbl(i).final_replenishment_qty <= 0
      <<next_consol_rec>>
	IF l_return_status <> fnd_api.g_ret_sts_success then
	   l_return_status := fnd_api.g_ret_sts_success;
	   ROLLBACK TO current_mol_sp;
	   -- if repl_type 2 and demand_type_id <> 4 then revert that WDD to original status
	   -- remove all entries for that item from gtmp
	   -- both done in following API
	   Revert_Consol_item_changes
	     ( p_repl_type         => l_repl_type
	       , p_demand_type_id  => l_demand_type_id
	       , P_item_id         => p_consol_item_repl_tbl(i).item_ID
	       , p_org_id          => p_consol_item_repl_tbl(i).ORGANIZATION_ID
	       , x_return_status   => l_return_status
	       );

	   -- Remove element from consol table, can not do inside this loop
	   -- AS iterating through the same consol record
	   -- store the index of the consol table to be deleted outside the loop
	   l_del_index := l_del_index +1;
	   l_del_consol_item_tb(l_del_index) := i;

	END IF;

      END IF; --    IF (NOT p_consol_item_repl_tbl.exists(i))
   END LOOP; -- For each consolidated demand Items

   --REMOVE CONSOL RECORDS THAT HAS BEEN REMOVED FROM MOVE ORDER CREATION
   -- THIS WILL KEEP DATA IN SYNC. Remember to use 'FORALL k IN INDICES OF'
   --  CREATE_REPL_MOVE_ORDER() is last call for a level. so it does not matter
   FOR j IN 1..l_del_consol_item_tb.COUNT() LOOP
      p_consol_item_repl_tbl.DELETE(l_del_consol_item_tb(j));
   END LOOP;

    -- TODO: Blocking Multi-Level Code changes
   -- Multi step change
   -- Bulk upload all eligible demand lines
   FORALL k IN INDICES OF l_demand_line_id_tb
     INSERT INTO WMS_REPL_DEMAND_GTMP
     (Repl_Sequence_id,
      repl_level,
      Inventory_item_id,
      Organization_id,
      demand_header_id,
      demand_line_id,
      DEMAND_LINE_DETAIL_ID,
      demand_type_id,
      quantity_in_repl_uom,
      REPL_UOM_code,
      Quantity,
      Uom_code,
      Expected_ship_date,
      Repl_To_Subinventory_code,
      filter_item_flag,
      repl_type)
     VALUES
     (WMS_REPL_DEMAND_GTMP_S.NEXTVAL,
      Nvl(p_repl_level,1) + 1,
      l_item_id_tb(k),
      l_org_id_tb(k),
      l_demand_header_id_tb(k),
      l_demand_line_id_tb(k),
      -9999,
      l_demand_type_id_tb(k),
      l_quantity_in_repl_uom_tb(k),
      l_repl_uom_code_tb(k),
      l_requested_quantity_tb(k),
      l_requested_quantity_uom_tb(k),
      l_expected_ship_date_tb(k),
      l_repl_to_sub_code_tb(k),
      NULL,
      2);



EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('CREATE_REPL_MOVE_ORDER: Error creating move order: ' || sqlcode || ', ' || sqlerrm);
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;

END CREATE_REPL_MOVE_ORDER;



PROCEDURE  GET_OPEN_MO_QTY(p_Repl_level           IN NUMBER,
			   p_repl_type            IN NUMBER,
			   p_Create_Reservation   IN VARCHAR2,
			   x_consol_item_repl_tbl IN OUT NOCOPY CONSOL_ITEM_REPL_TBL,
			   x_return_status        OUT NOCOPY VARCHAR2,
			   x_msg_count            OUT NOCOPY NUMBER,
			   x_msg_data             OUT NOCOPY VARCHAR2)
  IS

     L_demand_header_id            NUMBER;
     L_demand_line_id              NUMBER;
     L_demand_line_detail_id       NUMBER;
     L_demand_quantity             NUMBER;
     L_demand_quantity_in_repl_uom NUMBER;
     L_demand_uom_code             VARCHAR2(3);
     L_demand_type_id              NUMBER;
     L_sequence_id                 NUMBER;
     L_expected_ship_date          date;

     L_mo_line_id           NUMBER;
     L_mo_header_id         NUMBER;
     L_mo_quantity          NUMBER;
     L_mo_uom_code          VARCHAR2(3);
     L_mo_quantity_detailed NUMBER;

     l_rsv_temp_rec_2       inv_reservation_global.mtl_reservation_rec_type;
     l_rsv_temp_rec       inv_reservation_global.mtl_reservation_rec_type;
     l_rsv_rec            inv_reservation_global.mtl_reservation_tbl_type;
     l_serial_number      inv_reservation_global.serial_number_tbl_type;
     l_to_serial_number   inv_reservation_global.serial_number_tbl_type;
     l_quantity_reserved  NUMBER;
     l_quantity_reserved2 NUMBER;
     l_rsv_id             NUMBER;

     l_mtl_reservation_count NUMBER;
     l_error_code            NUMBER;
     l_conversion_rate       NUMBER;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);


     l_repl_level NUMBER;
     l_repl_type NUMBER;

     l_detail_info_tab             WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
     l_in_rec                      WSH_INTERFACE_EXT_GRP.detailInRecType;
     l_out_rec                     WSH_INTERFACE_EXT_GRP.detailOutRecType;

     -- For bulk upload in the WRD table
     l_organization_id_tab  num_tab;
     l_mo_header_id_tab  num_tab;
     l_mo_line_id_tab  num_tab;
     l_demand_header_id_tab  num_tab;
     l_demand_line_id_tab  num_tab;
     l_demand_line_detail_id_tab  num_tab;
     l_demand_type_id_tab  num_tab;
     l_item_id_tab  num_tab;
     l_demand_uom_code_tab  uom_tab;
     l_demand_quantity_tab  num_tab;
     l_sequence_id_tab  num_tab;
     l_repl_level_tab   num_tab;
     l_repl_type_tab    num_tab;

     l_index NUMBER;

     -- For bulk delete from the WRDG table
     l_detail_id_delete_tab num_tab;
     l_del_index NUMBER;

     l_return_status VARCHAR2(3) := fnd_api.g_ret_sts_success;

     CURSOR c_demand_lines_for_item(P_ORG_ID NUMBER, p_item_id number, p_fp_sub VARCHAR2) IS
	SELECT Repl_Sequence_id,
	  demand_header_id,
	  demand_line_id,
	  demand_line_detail_id,
	  demand_type_id,
	  Nvl(quantity,0),
	  uom_code,
	  expected_ship_date,
	  Nvl(quantity_in_repl_uom,0),
	  repl_level,
	  repl_type
	  FROM WMS_REPL_DEMAND_GTMP
	  WHERE ORGANIZATION_ID = P_ORG_ID
	  AND inventory_item_id = p_item_id
	  AND repl_to_subinventory_code = p_fp_sub
	  order by Repl_Sequence_id;


     -- TEST: make sure that all qty in correct UOM here
     --Store all open MO for the Sub
     CURSOR c_open_mo_lines(P_ORG_ID NUMBER, p_item_id NUMBER, P_FP_SUB VARCHAR2) IS
	select mtrl.line_id,
	  mtrl.header_id,
	  -- get all open move order qty that are not part of WRD
	  -- once fully transacted, mtrl.QUANTITY = mtrl.QUANTITY_DETAILED + mtrl.QUANTITY_DELIVERED
	  -- here quantity containes  QUANTITY_DETAILED at the current sub as
	  -- well AS untouched move ORDER qty
	  (mtrl.QUANTITY - NVL(mtrl.QUANTITY_DELIVERED,0)) AS quantity,
	    mtrl.uom_code,
	    Nvl(mtrl.quantity_detailed,0) AS quantity_detailed
	      from mtl_txn_request_lines mtrl, mtl_txn_request_headers mtrh
	      where mtrl.header_id = mtrh.header_id
	      and mtrl.organization_id = P_ORG_ID
	      and mtrl.inventory_item_id = p_item_id
	      and mtrl.to_subinventory_code = P_FP_SUB
	      and mtrl.line_status in (3, 7) -- only approved and pre-approved
	      and mtrh.move_order_type = 2 -- for replenishment only
	      AND not exists
	      (select WRD.Source_line_id
	       from WMS_REPLENISHMENT_DETAILS wrd
	       where WRD.source_header_id = MTRL.HEADER_ID
               AND WRD.Source_line_id = MTRL.LINE_ID
               And wrd.organization_id = mtrl.organization_id
               And wrd.organization_id = p_org_id )
	      UNION
	      -- get all Open Move Order qty that are left out due to rounding or other reason
	      select mtrl.line_id,
	      mtrl.header_id,
	      -- qty inside function Round(**) below might NOT be allocated yet based on
	      -- how the stock up was RUN but we have earmarked that much mo qty through WRD for certain demands
	      -- so we need to subtract that much qty from existing_mo_qty for availble_mo_qty
	      (mtrl.QUANTITY- NVL(mtrl.QUANTITY_DELIVERED,0) -
	       ROUND((WMS_REPLENISHMENT_PVT.get_conversion_rate(p_item_id, x.primary_uom, mtrl.uom_code)* Nvl(X.quantity,0)),5)) AS quantity,

		 mtrl.uom_code,
		 Nvl(mtrl.quantity_detailed,0) AS quantity_detailed
		   FROM
		   mtl_txn_request_lines mtrl,
		   (
		    SELECT WRD.Source_line_id, WRD.source_header_id,
		    wrd.inventory_item_id, SUM(wrd.Primary_quantity) quantity,
		    wrd.organization_id,wrd.primary_uom
		    FROM  WMS_REPLENISHMENT_DETAILS wrd, wsh_delivery_details wdd
		    WHERE wrd.demand_line_detail_id = wdd.delivery_detail_id
		    AND  wrd.demand_line_id = wdd.source_line_id
		    AND  wrd.organization_id = P_ORG_ID
		    AND  wrd.organization_id = wdd.organization_id
		    GROUP BY  wrd.organization_id,
		    WRD.source_header_id,
		    WRD.Source_line_id,
		    wrd.inventory_item_id,
		    wrd.primary_uom) X
		   WHERE X.inventory_item_id = mtrl.inventory_item_id
		   and x.source_header_id = MTRL.HEADER_ID
		   AND x.Source_line_id = MTRL.LINE_ID
		   and x.organization_id = mtrl.organization_id
		   and mtrl.organization_id = P_ORG_ID
		   and mtrl.inventory_item_id = p_item_id
		   and mtrl.to_subinventory_code = P_FP_SUB
		   and mtrl.line_status in (3, 7)
		   order by quantity DESC;



		 CURSOR c_demands_for_mo(p_org_id NUMBER, p_mo_header_id NUMBER, p_mo_line_id NUMBER) IS
		    SELECT demand_line_detail_id, demand_line_id
		      FROM WMS_REPLENISHMENT_DETAILS WRD
		      WHERE WRD.organization_id = P_ORG_ID
		      AND WRD.source_header_id = P_mo_header_id
		      AND WRD.Source_line_id = P_mo_line_id;
BEGIN
   x_return_status := l_return_status;
   -- For all Items in the pl/sql table
   IF (l_debug = 1) THEN
      print_debug('Inside the API GET_OPEN_MO_QTY');
   END IF;
   l_index := 1;
   l_del_index := 1;
   FOR i IN x_consol_item_repl_tbl.FIRST .. x_consol_item_repl_tbl.LAST LOOP

      IF (NOT x_consol_item_repl_tbl.exists(i)) THEN

	 IF (l_debug = 1) THEN
	    print_debug('CURRENT INDEX IN THE CONSOL TABLE HAS BEEN Discarded - moving TO next consol RECORD' );

	 END IF;

       ELSE

	 IF (l_debug = 1) THEN
	    print_debug('Going through consolidated item :'|| x_consol_item_repl_tbl(i).item_id ||
			' , Index :'|| i);
	 END IF;

      --For all Open Move Orders for the item, see if there is any demand lines that can be consumed
      -- Loop through all open MO for the item
      OPEN c_open_mo_lines(x_consol_item_repl_tbl(i).ORGANIZATION_ID,
			   x_consol_item_repl_tbl(i).item_id,
			   x_consol_item_repl_tbl(i).repl_to_subinventory_code);
      LOOP
	 FETCH c_open_mo_lines INTO L_mo_line_id, L_mo_header_id, L_mo_quantity, L_mo_uom_code, L_mo_quantity_detailed;
	 EXIT WHEN c_open_mo_lines%NOTFOUND;
	 IF (l_debug = 1) THEN
	    print_debug('Curent open MO Line Id-'|| L_mo_line_id ||' ,Qty :'||L_mo_quantity||' ,UOM :'||L_mo_uom_code);
	 END IF;

	 -- Loop through all demand lines for the item to see if any demand line can be consumed against open MOL
	 OPEN c_demand_lines_for_item(x_consol_item_repl_tbl(i).ORGANIZATION_ID,
				      x_consol_item_repl_tbl(i).item_id,
				      x_consol_item_repl_tbl(i).repl_to_subinventory_code);
	 LOOP
	    FETCH c_demand_lines_for_item INTO L_sequence_id,
	      L_demand_header_id, L_demand_line_id,
	      L_demand_line_detail_id, l_demand_type_id, L_demand_quantity,
	      L_demand_uom_code,
	      l_expected_ship_date, l_demand_quantity_in_repl_uom, l_repl_level,l_repl_type ;
	    EXIT WHEN c_demand_lines_for_item%NOTFOUND;

	    IF (l_debug = 1) THEN
	       print_debug('Netting delivery_detail :'||L_demand_line_detail_id||
			   ' ,Qty_in_repl_uom :'||l_demand_quantity_in_repl_uom);
	    END IF;

	    SAVEPOINT Current_Demand_SP;

	    -- All quantity comparison should happen in repl_UOM_code because there can be multiple demand for a
	    --  single MO. It will save the computation.
	    IF L_mo_uom_code <> x_consol_item_repl_tbl(i).Repl_UOM_Code then

	       l_conversion_rate := get_conversion_rate(x_consol_item_repl_tbl(i).Item_id,
							L_mo_uom_code,
							x_consol_item_repl_tbl(i).Repl_UOM_Code);

	       IF (l_conversion_rate < 0) THEN
		  IF (l_debug = 1) THEN
		     print_debug('Error while obtaining L_mo_uom_code conversion rate for demand qty');
		  END IF;
		  -- Process the next existing demand record.
		  GOTO next_record;
	       END IF;

	       L_mo_quantity := ROUND(l_conversion_rate * L_mo_quantity,
				      g_conversion_precision);

	    END IF;

	    IF L_mo_quantity < L_demand_quantity_in_repl_uom THEN
	       -- For simplicity, we will consume only those MOLs that have qty greater than WDD qty
	       IF (l_debug = 1) THEN
		  print_debug('MO Qty < Demand Line qty, NOTHING TO DO..');
	       END IF;

	       GOTO next_record;

	     ELSIF L_mo_quantity >= L_demand_quantity_in_repl_uom THEN
	       -- The specific demand order will be consumed with this Move Order
	       IF (l_debug = 1) THEN
		  print_debug('MO Qty > Demand Line qty, Consume Against it');
	       END IF;

	       IF p_Create_Reservation = 'Y' THEN

		  IF (l_debug = 1) THEN
		     print_debug('Create RSV =Y, Mark Replenishment Status as RR');
		  END IF;

		  -- Call Shipping API to mark the Delivery Detail to 'RR'
		  update_wdd_repl_status (p_deliv_detail_id   =>  l_demand_line_detail_id
					  , p_repl_status     => 'R' -- for completed status
					  , x_return_status   => l_return_status
					  );

		  IF l_return_status <> fnd_api.g_ret_sts_success THEN
		     GOTO next_record;
		  END IF;


		  IF (l_debug = 1) THEN
		     print_debug('Check if Org level RSV exists');
		  END IF;
		  -- Check if an Org level reservation exists for corresponding demand line
		  -- Clear out old values
		  l_rsv_temp_rec := l_rsv_temp_rec_2;

		  -- Assign all new values
		  l_rsv_temp_rec.organization_id := x_consol_item_repl_tbl(i).organization_id;
		  l_rsv_temp_rec.inventory_item_id := x_consol_item_repl_tbl(i).item_id;
		  l_rsv_temp_rec.DEMAND_SOURCE_TYPE_ID := l_demand_type_id;
		  l_rsv_temp_rec.DEMAND_SOURCE_HEADER_ID := l_demand_header_id;
		  l_rsv_temp_rec.DEMAND_SOURCE_LINE_ID := l_demand_line_id;


		  inv_reservation_pub.query_reservation(
							p_api_version_number =>1.0,
							x_return_status => l_return_status,
							x_msg_count   => x_msg_count,
							x_msg_data    => x_msg_data,
							p_query_input => l_rsv_temp_rec,
							x_mtl_reservation_tbl  => l_rsv_rec,
							x_mtl_reservation_tbl_count => l_mtl_reservation_count,
							x_error_code => l_error_code);

		  IF l_RETURN_status = fnd_api.g_ret_sts_success THEN
		     IF (l_debug = 1) THEN
			PRINT_DEBUG('Number of reservations found: ' ||l_mtl_reservation_count);
		     END IF;

		   ELSE
		     IF (l_debug = 1) THEN
			PRINT_DEBUG('Error: ' || X_msg_data);
		     END IF;
		     GOTO next_record;
		  END IF;


		  -- If no org level reservation found then create it
		  IF l_mtl_reservation_count = 0 then
		     IF (l_debug = 1) THEN
			PRINT_DEBUG('NO RSV Found, Create High Level RSV');
		     END IF;

		     l_rsv_temp_rec.DEMAND_SOURCE_HEADER_ID := l_demand_header_id;
		     l_rsv_temp_rec.demand_source_line_detail :=  l_demand_line_detail_id;

		     -- Create high-level reservation for the demand line against inventory (sypply_type = 13)
		     Create_RSV(p_replenishment_type    => 1, --  1- Stock Up/Push; 2- Dynamic
				l_debug                 => l_debug,
				l_organization_id       => x_consol_item_repl_tbl(i).ORGANIZATION_ID,
				l_inventory_item_id     => x_consol_item_repl_tbl(i).item_id,
				l_demand_type_id        => l_demand_type_id,
				l_demand_so_header_id   => L_demand_header_id,
				l_demand_line_id        => L_demand_line_id,
				l_split_wdd_id          => NULL,
				l_primary_uom_code      => L_demand_uom_code, --demand uom are prim
				l_supply_uom_code       => L_mo_uom_code,
				l_atd_qty               => L_demand_quantity,
				l_atd_prim_qty          => L_demand_quantity,
				l_supply_type_id        => 13, --Inventory
				l_supply_header_id      => NULL, -- since high level rsv
				l_supply_line_id        => NULL, -- since high level rsv
				l_supply_line_detail_id => NULL, -- since high level rsv
				l_supply_expected_time  => SYSDATE,
				l_demand_expected_time  => l_expected_ship_date,
				l_rsv_rec               => l_rsv_temp_rec, -- only need to provide good enough information FOR high LEVEL reservation, only one row will do
		       l_serial_number         => l_serial_number,
		       l_to_serial_number      => l_to_serial_number,
		       l_quantity_reserved     => l_quantity_reserved,
		       l_quantity_reserved2    => l_quantity_reserved2,
		       l_rsv_id                => l_rsv_id,
		       x_return_status         => l_return_status,
		       x_msg_count             => x_msg_count,
		       x_msg_data              => x_msg_data);

		     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			IF (l_debug = 1) THEN

			   print_debug('Error returned from create_reservation API: ' ||
				       l_return_status);
			END IF;
			GOTO next_record;
		      ELSE
			IF (l_debug = 1) THEN
			   print_debug('Successfully created a RSV record for MO Line');
			END IF;
		     END IF;

		  END IF; -- for l_mtl_reservation_count = 0

		  IF (l_debug = 1) THEN
		     print_debug('Add entry into the WRD Table dmd_detail_id :'||l_demand_line_detail_id);
		  END IF;
		  -- Add an entry into WRD table
		  -- STORE DATA here and do BULK INSERT later
		  l_organization_id_tab(l_index) := x_consol_item_repl_tbl(i).organization_id;
		  l_mo_header_id_tab(l_index) := l_mo_header_id;
		  l_mo_line_id_tab(l_index) := l_mo_line_id;
		  l_demand_header_id_tab(l_index) := l_demand_header_id;
		  l_demand_line_id_tab(l_index) := l_demand_line_id;
		  l_demand_line_detail_id_tab(l_index) :=  l_demand_line_detail_id;
		  l_demand_type_id_tab(l_index) := l_demand_type_id;
		  l_item_id_tab(l_index) :=  x_consol_item_repl_tbl(i).item_id;
		  l_demand_uom_code_tab(l_index) :=  l_demand_uom_code;
		  l_demand_quantity_tab(l_index) := l_demand_quantity;
		  l_sequence_id_tab(l_index) := l_sequence_id;
		  l_repl_level_tab(l_index)  := l_repl_level;
		  l_repl_type_tab(l_index)   := l_repl_type;
		  l_index := l_index +1;

		ELSE --means p_create_Reservation = 'N'
		  -- Do not need to do anything here. We do not need to call the shipping API to revert to original
		  --line status because For dynamic/pull replenishment p_create_Reservation  will
		  -- always be 'Y' and hence the code will never come here. For Push replenishemnt, The demand
		  -- line would not have been touched yet. So it will remain in its orignal status.
		  NULL;
		  IF (l_debug = 1) THEN
		     print_debug('Create RSV =N, Do not add in WRD table');
		  END IF;
	       END IF; --For p_Create_Reservation  = 'Y'


	       IF (l_debug = 1) THEN
		  print_debug('Remove the Demand_detail_id from the GTMP: '||l_demand_line_detail_id);
	       END IF;
	       -- Remove this DEMAND from the WMS_REPL_DEMAND_GTMP table
	       -- IRRESPECTIVE OF p_create_reservation value. This demand is already consumed
	       -- This set can be different than set inserted in the WRD table
	       -- Store here to BULK DELETE later
	       l_detail_id_delete_tab(l_del_index) := l_demand_line_detail_id;
	       l_del_index := l_del_index +1;


	       IF (l_debug = 1) THEN
		  print_debug('Add to the open MO Qty in the Consol table');
	       END IF;
	       -- In PL/SQL table, increase the open MO qty in repl_UOM by L_demand_quantity_in_repl_uom
	       x_consol_item_repl_tbl(i).open_mo_qty := x_consol_item_repl_tbl(i).open_mo_qty +L_demand_quantity_in_repl_uom;


	       -- Decrease the L_mo_quantity to reflect correct available MO qty for next demand line
	       -- All quantity comparision is in the repl_uom unit
	       L_mo_quantity := L_mo_quantity - L_demand_quantity_in_repl_uom;


	    END IF; -- L_mo_quantity >= L_demand_quantity

	    <<next_record>>
	      IF (l_debug = 1) THEN
		 print_debug('At the end of current demand Available Open MO qty: '||L_mo_quantity);
	      END IF;
	      IF l_return_status <> fnd_api.g_ret_sts_success THEN
		 l_return_status := fnd_api.g_ret_sts_success;
		 ROLLBACK TO current_demand_sp;
	      END IF;
	 END LOOP; -- for each demand line
	 CLOSE c_demand_lines_for_item;

	 IF (l_debug = 1) THEN
	    print_debug('Done with Current OPEN MO record');
	    print_debug('Final Open MO qty that cound not be consumed: '||L_mo_quantity);
	 END IF;

      END LOOP;  --for each open MO
      CLOSE c_open_mo_lines;

      --At the end for Each item In PL/SQL table, update the final_replenishment_qty in Repl_UOM
      x_consol_item_repl_tbl(i).final_replenishment_qty :=
	(x_consol_item_repl_tbl(i).final_replenishment_qty - x_consol_item_repl_tbl(i).open_mo_qty);

      --Note: the final replenishment qty will be upp by the p_Repl_Lot_Size in Create_repl_Move_order() API
      IF (l_debug = 1) THEN
	 print_debug('Done with Current Consolidated  record');
      END IF;


      END IF ; --  IF not x_consol_item_repl_tbl.exists(i)

   END LOOP; -- For each consolidated demand lines



   IF (l_debug = 1) THEN
      print_debug('BULK INSERT ALL CONSUMED DEMANDS IN WRD table' );
   END IF;

   -- BULK INSERT ALL consumed demands IN wms_replenishment_details table
   FORALL k IN INDICES OF l_demand_line_detail_id_tab
     INSERT INTO WMS_REPLENISHMENT_DETAILS
     (Replenishment_id,
      Organization_Id,
      source_header_id,
      Source_line_id,
      Source_line_detail_id,
      Source_type_id,
      demand_header_id,
      demand_line_id,
      demand_line_detail_id,
      demand_type_id,
      Inventory_item_id,
      Primary_UOM,
      Primary_Quantity,
      demand_sort_order,
      repl_level,
      repl_type,
      CREATION_DATE,
      LAST_UPDATE_DATE,
      CREATED_BY,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
      )VALUES (
	       WMS_REPLENISHMENT_DETAILS_S.NEXTVAL,
	       l_organization_id_tab(k),
	       l_mo_header_id_tab(k),
	       l_mo_line_id_tab(k),
	       NULL,
	       4, --  For Move Orders
	       l_demand_header_id_tab(k),
	       l_demand_line_id_tab(k),
	       l_demand_line_detail_id_tab(k),
	       l_demand_type_id_tab(k),
	       l_item_id_tab(k),
	       l_demand_uom_code_tab(k),
	       l_demand_quantity_tab(k),
	       l_sequence_id_tab(k),
	       l_repl_level_tab(k),
	       l_repl_type_tab(k),
	       Sysdate,
	       Sysdate,
	       fnd_global.user_id,
	       fnd_global.user_id,
	       fnd_global.user_id
	       );

   -- CLEAR all entries in the tables
   l_organization_id_tab.DELETE;
   l_mo_header_id_tab.DELETE;
   l_mo_line_id_tab.DELETE;
   l_demand_header_id_tab.DELETE;
   l_demand_line_id_tab.DELETE;
   l_demand_line_detail_id_tab.DELETE;
   l_demand_type_id_tab.DELETE;
   l_item_id_tab.DELETE;
   l_demand_uom_code_tab.DELETE;
   l_demand_quantity_tab.DELETE;
   l_sequence_id_tab.DELETE;
   l_repl_level_tab.DELETE;
   l_repl_type_tab.DELETE;

   IF (l_debug = 1) THEN
      print_debug('BULK REMOVE ALL CONSUMED DEMANDS FROM GTMP table' );
   END IF;
   -- BULK Remove all consumed demands from WMS_REPL_DEMAND_GTMP table
   FORALL k in 1 .. l_detail_id_delete_tab.COUNT()
     DELETE  From WMS_REPL_DEMAND_GTMP
     WHERE demand_line_detail_id = l_detail_id_delete_tab(k);

   -- CLEAR all entries in the tables
   l_detail_id_delete_tab.DELETE;

   IF (l_debug = 1) THEN
      print_debug('DONE WITH API - GET_OPEN_MO_QTY' );
   END IF;
   x_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF c_demand_lines_for_item%ISOPEN THEN
	 CLOSE c_demand_lines_for_item;
      END IF;
      IF c_open_mo_lines%ISOPEN THEN
	 CLOSE c_open_mo_lines;
      END IF;

      IF (l_debug = 1) THEN
	 print_debug('Error in GET_OPEN_MO_QTY SQLCODE: '||SQLCODE ||' : '||SQLERRM );
      END IF;

END GET_OPEN_MO_QTY;


PROCEDURE  GET_AVAILABLE_ONHAND_QTY(p_Repl_level           IN NUMBER,
				    p_repl_type            IN NUMBER,
				    p_Create_Reservation   IN VARCHAR2,
				    x_consol_item_repl_tbl IN OUT NOCOPY CONSOL_ITEM_REPL_TBL,
				    x_return_status        OUT NOCOPY VARCHAR2,
				    x_msg_count            OUT NOCOPY NUMBER,
				    x_msg_data             OUT NOCOPY VARCHAR2)
  IS


     l_debug              NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_demand_header_id NUMBER;
     l_demand_type_id NUMBER;
     l_sequence_id      NUMBER;
     l_demand_line_id NUMBER;
     l_demand_line_detail_id NUMBER;
     l_demand_quantity NUMBER;
     l_demand_uom_code VARCHAR2(3);
     l_expected_ship_date   DATE;
     l_demand_quantity_in_repl_uom NUMBER;

     l_last_sub VARCHAR2(30) := NULL;
     l_qoh NUMBER;
     l_rqoh NUMBER;
     l_qr   NUMBER;
     l_qs NUMBER;
     l_att NUMBER;
     l_atr NUMBER;
     l_mtl_reservation_count NUMBER;

     l_rsv_temp_rec   inv_reservation_global.mtl_reservation_rec_type;
     l_rsv_temp_rec_2 inv_reservation_global.mtl_reservation_rec_type;
     l_rsv_rec            inv_reservation_global.mtl_reservation_tbl_type;

     l_prev_org_id NUMBER;
     l_prev_item_id NUMBER;
     l_prev_sub_code VARCHAR2(10);
     l_qty_tree_demand_line_id NUMBER;

     l_rsv_id_tb num_tab;
     l_detail_info_tab             WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
     l_in_rec                      WSH_INTERFACE_EXT_GRP.detailInRecType;
     l_out_rec                     WSH_INTERFACE_EXT_GRP.detailOutRecType;

     l_serial_number      inv_reservation_global.serial_number_tbl_type;
     l_to_serial_number   inv_reservation_global.serial_number_tbl_type;
     l_quantity_reserved  NUMBER;
     l_quantity_reserved2 NUMBER;
     l_rsv_id             NUMBER;
     l_error_code         NUMBER;

     l_is_revision_ctrl BOOLEAN;
     l_is_lot_ctrl  BOOLEAN;
     l_is_serial_ctrl  BOOLEAN;

     l_del_index NUMBER;
     l_del_consol_item_tb num_tab;
     l_repl_status VARCHAR2(1);
     l_bkorder_cnt NUMBER;

     CURSOR c_demand_lines_for_item(p_org_id NUMBER, p_item_id number, p_fp_sub VARCHAR2) IS
	SELECT repl_sequence_id, demand_header_id, demand_line_id,
	  demand_line_detail_id,
	  demand_type_id, quantity, uom_code, expected_ship_date,
	  quantity_in_repl_uom, repl_status
	  FROM  WMS_REPL_DEMAND_GTMP
	  WHERE  ORGANIZATION_ID = P_ORG_ID
	  AND inventory_item_id = p_item_id
	  AND  repl_to_subinventory_code = p_fp_sub
	  order by Repl_Sequence_id;

     l_return_status VARCHAR2(3) := fnd_api.g_ret_sts_success;
BEGIN

   x_return_status := l_return_status;

   IF (l_debug = 1) THEN
      print_debug('Inside GET_AVAILABLE_ONHAND_QTY API' );
   END IF;

   -- For all Items in the pl/sql table
   FOR i IN x_consol_item_repl_tbl.FIRST.. x_consol_item_repl_tbl.LAST LOOP
      IF (l_debug = 1) THEN
	 print_debug('Consol record Index :' || i);
      END IF;

      IF (NOT x_consol_item_repl_tbl.exists(i)) THEN

	 IF (l_debug = 1) THEN
	    print_debug('CURRENT INDEX IN THE CONSOL TABLE HAS BEEN Discarded - moving TO next consol RECORD' );

	 END IF;
       ELSE


      SAVEPOINT onhd_consol_rec_sp;
      -- For all demand lines net the available OnHand
      OPEN  c_demand_lines_for_item(x_consol_item_repl_tbl(i).ORGANIZATION_ID,
				    x_consol_item_repl_tbl(i).item_id,
				    x_consol_item_repl_tbl(i).repl_to_subinventory_code);
      LOOP
	 SAVEPOINT onhd_demand_line_sp;

	 FETCH  c_demand_lines_for_item INTO L_sequence_id,
	   L_demand_header_id, L_demand_line_id,
	   L_demand_line_detail_id, l_demand_type_id, L_demand_quantity,
	   L_demand_uom_code,
	   l_expected_ship_date, l_demand_quantity_in_repl_uom, l_repl_status;
	 EXIT WHEN c_demand_lines_for_item%notfound;

	 IF (l_debug = 1) THEN
	    print_debug('=======Netting onhand for NEW Demand line=======');
	    print_debug('Next Demand for consol Item Record :' ||l_demand_line_detail_id ||', Dmd_QTY :'||l_demand_quantity
			||', Qty_in_repl_UOM :'||l_demand_quantity_in_repl_uom);
	    print_debug('l_demand_type_id :'||l_demand_type_id);
	 END IF;

	 -- For an Org+item+Sub combination, the qty tree should be called only once
	 IF (( l_prev_org_id IS NULL AND l_prev_item_id IS NULL AND
	       l_prev_sub_code IS NULL ) OR
	     l_prev_org_id <> x_consol_item_repl_tbl(i).ORGANIZATION_ID  OR
	     l_prev_item_id <> x_consol_item_repl_tbl(i).item_id OR
	     l_prev_sub_code <> x_consol_item_repl_tbl(i).repl_to_subinventory_code ) THEN

	    l_atr := 0;
	    -- Get all item details
	    IF inv_cache.set_item_rec(x_consol_item_repl_tbl(i).ORGANIZATION_ID, x_consol_item_repl_tbl(i).item_id)  THEN

	       IF (l_debug = 1) THEN
		  print_debug('Getting Item Attribute Details' );
	       END IF;

	       IF inv_cache.item_rec.revision_qty_control_code = 2 THEN
		  l_is_revision_ctrl := TRUE;
		ELSE
		  l_is_revision_ctrl := FALSE;
	       END IF;

	       IF inv_cache.item_rec.lot_control_code = 2 THEN
		  l_is_lot_ctrl := TRUE;
		ELSE
		  l_is_lot_ctrl := FALSE;
	       END IF;

	       IF inv_cache.item_rec.serial_number_control_code NOT IN (1,6) THEN
		  l_is_serial_ctrl := FALSE;
		ELSE
		  l_is_serial_ctrl := TRUE;
	       END IF;

	     ELSE
	       IF (l_debug = 1) THEN
		  print_debug('Error: Item detail not found');
	       END IF;
	       l_return_status := fnd_api.g_ret_sts_error;
	       GOTO next_onhd_consol_rec;
	    END IF; -- for inv_cache.set_item_rec


	    IF (l_debug = 1) THEN
	       print_debug('Clearing Qty Tree' );
	    END IF;
	    --Query Quantity Tree
	    inv_quantity_tree_pub.clear_quantity_cache;

	    IF (l_debug = 1) THEN
	       print_debug('Calling Qty Tree API' );
	    END IF;

	    inv_quantity_tree_pub.query_quantities
	      (
	       p_api_version_number         => 1.0
	       , p_init_msg_lst               => fnd_api.g_false
	       , x_return_status              => l_return_status
	       , x_msg_count                  => x_msg_count
	       , x_msg_data                   => x_msg_data
	       , p_organization_id            => x_consol_item_repl_tbl(i).organization_id
	       , p_inventory_item_id          => x_consol_item_repl_tbl(i).item_id
	       , p_tree_mode                  => inv_quantity_tree_pub.g_transaction_mode
	       , p_is_revision_control        =>  l_is_revision_ctrl
	       , p_is_lot_control             =>  l_is_lot_ctrl
	       , p_is_serial_control          =>  l_is_serial_ctrl
	       , p_demand_source_type_id    => l_demand_type_id  -- 2 (OE) / 8 for Internal Order
	       , p_demand_source_header_id  => L_demand_header_id
	       , p_demand_source_line_id    => L_demand_line_id
	       , p_revision                 => NULL
	       , p_lot_number                => NULL
	      , p_subinventory_code          => x_consol_item_repl_tbl(i).repl_to_subinventory_code
	      , p_locator_id                 => NULL
	      , x_qoh                        => l_qoh
	      , x_rqoh                       => l_rqoh
	      , x_qr                         => l_qr
	      , x_qs                         => l_qs
	      , x_att                        => l_att
	      , x_atr                        => l_atr
	      );

	    IF (l_debug = 1) THEN
	       print_debug( 'Return status from QTY TREE:' ||l_return_status);
	       print_debug( 'l_atr is: '||l_atr);
	    END IF;
	    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	       GOTO next_onhd_consol_rec;
	    END IF;
	    -- Store the demand line for which the qty tree was called
	    l_qty_tree_demand_line_id := l_demand_line_id;


	 END IF; --For an Org+item+Sub combination


	 -- In transaction_mode call to API inv_quantity_tree_pub.query_quantities pass parameters: item_id, demand header, demand line, subinventory

	 --For l_atr calculation for all high level reservations, qty_tree first consumes all available material from outside the current SUB then bite from the current sub if remaining any.

	 --(l_atr) will be available qty to reserve. It includes rsv_qty
	 --for current demand line  (if detailed at current sub OR high level rsv).
	 --It does not include qty if the current demand is detailed at other sub.
	 --It deduct any detailed rsv by other demand lines at the current sub

	 --l_qr - detailed resv by ALL Other demands at the CURRENT sub (does not include rsv_qty by current demand line)

	 IF l_atr > 0 THEN

	    -- Note:  if l_atr < l_demand_qty, then we would rather
	    --create new replenishment MO than splitting the demand line FOR simplicity

	    IF l_atr >= l_demand_quantity THEN
	       IF (l_debug = 1) THEN
		  PRINT_DEBUG('Enough Qty - Consuming this demand :' ||L_demand_line_detail_id);
	       END IF;

	       -- Check if rsv exists for the current demand line from table mtl_reservations
	       -- Use Query_reservation() API
	       -- Make sure that if rsv exists all qty must be either high level rsv or must be all completely detailed.
	       -- Lets say that we get l_existing_rsv_qty from MR table for current demand which
	       -- should be less than or equal to l_demand_qty

	       IF (l_debug = 1) THEN
		  PRINT_DEBUG('****Check if Reservation exists for current demand');
	       END IF;

	       -- Check if reservation exists for corresponding order line
	       -- Clear out old values
	       l_rsv_temp_rec := l_rsv_temp_rec_2;

	       -- Assign all new values
	       l_rsv_temp_rec.organization_id := x_consol_item_repl_tbl(i).organization_id;
	       l_rsv_temp_rec.inventory_item_id := x_consol_item_repl_tbl(i).item_id;
	       l_rsv_temp_rec.DEMAND_SOURCE_TYPE_ID := l_demand_type_id;
	       l_rsv_temp_rec.DEMAND_SOURCE_HEADER_ID := l_demand_header_id;
	       l_rsv_temp_rec.DEMAND_SOURCE_LINE_ID := l_demand_line_id;

	       inv_reservation_pub.query_reservation(
						     p_api_version_number =>1.0,
						     x_return_status => l_return_status,
						     x_msg_count   => x_msg_count,
						     x_msg_data    => x_msg_data,
						     p_query_input => l_rsv_temp_rec,
						     x_mtl_reservation_tbl  => l_rsv_rec,
						     x_mtl_reservation_tbl_count => l_mtl_reservation_count,
						     x_error_code => l_error_code);

	       IF l_RETURN_status = fnd_api.g_ret_sts_success THEN
		  IF (l_debug = 1) THEN
		     PRINT_DEBUG('*****Number of reservations found: ' ||l_mtl_reservation_count);
		  END IF;

		ELSE
		  IF (l_debug = 1) THEN
		     PRINT_DEBUG('Error: ' || X_msg_data);
		  END IF;
		  GOTO next_dmd_record;
	       END IF;

	       -- IMP NOTE: only HIGH LEVEL RSV can exists for 'demands slated for replenishment' at this point for
	       -- BOTH type of replenishments since detailed rsv has been discarded from the original demand cursor
	       -- BUT if somehow in between the time duration, user details one of the high
	       -- LEVEL reservation demand line, we assume that he does not
	       -- break reservation across different sub TO consume the demand qty


	       IF l_mtl_reservation_count <> 0 THEN -- RSV EXISTS

		  -- FIND IF ALL RECORDS HAVE SAME TYPE OF RSV
		  -- means EITHER HIGH LEVEL OR detail LEVEL at the SAME subinventory
		  -- Note: Reservation can not be made for qty greater than demand_qty on the order


		  l_rsv_id_tb.DELETE;
		  FOR i IN l_rsv_rec.first.. l_rsv_rec.last LOOP
		     l_rsv_id_tb(i) := l_rsv_rec(i).reservation_id;
		     IF i <> 1 THEN
			IF (l_rsv_rec(i).subinventory_code IS NULL AND l_last_sub IS NOT NULL)
			  OR
			  (l_rsv_rec(i).subinventory_code IS NOT NULL AND l_last_sub IS NULL)
			    OR (l_rsv_rec(i).subinventory_code IS NOT NULL AND
				l_last_sub IS NOT NULL AND l_rsv_rec(i).subinventory_code <> l_last_sub)
				  THEN
			   IF (l_debug = 1) THEN
			      print_debug('SKIP Current Demand: Mixed level of reservation');
			   END IF;
			   -- means mixed level of rsv, we will rather CREATE NEW replenishment
			   -- We will not account for these rsv in this case
			   -- Since we need to skip to next demand and
			   -- behave as if this demand is in error
			   l_return_status := fnd_api.g_ret_sts_error;
			   GOTO next_dmd_record;
			END IF;

		     END IF;
		     l_last_sub := l_rsv_rec(i).subinventory_code;

		     -- What if the reserved qty is less than the demand
		     -- qty, there IS left OUT qty FOR the line TO be reserved
		  END LOOP;

		  IF (l_debug = 1) THEN
		     print_debug('If Sub Level RSV, SUB :'||l_last_sub);
		  END IF;

		  -- If the l_last_sub is not null, means detailed rsv
		  -- because all rsv data has to be of same type either NULL OR same subinventory

		  IF l_last_sub is NULL THEN -- high level rsv

		     IF (l_debug = 1) THEN
			print_debug('****** It is High Level RSV Exists');
			print_debug('****** Call WSH to make Lines as RC');
		     END IF;

		     -- Call Shipping API to mark the Delivery Detail TO 'RC'.
		     update_wdd_repl_status (p_deliv_detail_id   =>  l_demand_line_detail_id
					     , p_repl_status     => 'C'  -- for completed status
					     , x_return_status   => l_return_status
					     );

		     IF l_return_status <> fnd_api.g_ret_sts_success THEN
			GOTO next_dmd_record;
		     END IF;


		     -- Remove the entry from the WMS_REPL_DEMAND_GTMP table
		     IF (l_debug = 1) THEN
			print_debug('Remove Entry from WRDG table');
		     END IF;
		     DELETE FROM wms_repl_demand_gtmp
		       WHERE  Organization_id = x_consol_item_repl_tbl(i).organization_id
		       AND INVENTORY_ITEM_ID =  x_consol_item_repl_tbl(i).item_id
		       AND demand_type_id = l_demand_type_id
		       AND DEMAND_LINE_DETAIL_ID = l_demand_line_detail_id
		       AND demand_header_id = l_demand_header_id
		       AND demand_line_id = l_demand_line_id;

		     -- Detail the reservation to the current sub. We will consume right here
		     IF (l_debug = 1) THEN
			print_debug('Detail High Level Rsv to Detailed CURRENT sub :'
				    || x_consol_item_repl_tbl(i).repl_to_subinventory_code);
		     END IF;
		     FORALL k in 1 .. l_rsv_rec.COUNT()
		       UPDATE mtl_reservations
		       SET     subinventory_code = x_consol_item_repl_tbl(i).repl_to_subinventory_code
		       WHERE   reservation_id = l_rsv_id_tb(k);


		     IF (l_debug = 1) THEN
			print_debug('Add to the available onhand for this item');
		     END IF;
		     -- In PL/SQL table, increase the available OnHand qty in repl_UOM by L_demand_quantity_in_repl_uom
		     x_consol_item_repl_tbl(i).available_onhand_qty :=
		       x_consol_item_repl_tbl(i).available_onhand_qty + L_demand_quantity_in_repl_uom;


		     --Decrease the l_atr to reflect correct available OnHand qty for next demand line.
		     --This seems to be a pessimistic approach. If all demands are at high level in the set and all material is in the current, then l_atr
		     --  would already have deducted for all demands. If we deduct it again, we are asking for twice the qty than it should.

		     --  But above will not be a very common business scenario because if all material is in the current sub, then we will not be talking of replenishment here.
		     --  In general pick areas will have minial quantity and major qty are stores in bulk areas in the facility

		     IF (l_debug = 1) THEN
			print_debug('decrese the consumed qty from the curent atr FOR this demand');
		     END IF;
		     -- All quantity comparision is in the primary unit
		     l_atr := l_atr - l_demand_quantity;


		   ELSIF l_last_sub = x_consol_item_repl_tbl(i).repl_to_subinventory_code THEN
		     -- means detailed at Current sub
		     IF (l_debug = 1) THEN
			print_debug('It is Detailed RSV at the current FP sub');
			print_debug('Call WSH to mark current dmand RC');
		     END IF;


		     -- Call Shipping API to mark the Delivery Detail TO 'RC'.
		     update_wdd_repl_status (p_deliv_detail_id   =>  l_demand_line_detail_id
					     , p_repl_status     => 'C'  -- for completed status
					     , x_return_status   => l_return_status
					     );

		     IF l_return_status <> fnd_api.g_ret_sts_success THEN
			GOTO next_dmd_record;
		     END IF;

		     IF (l_debug = 1) THEN
			print_debug('Remove the entry from the WRDG table');
		     END IF;
		     -- Remove the entry from the WMS_REPL_DEMAND_GTMP table
		     DELETE FROM wms_repl_demand_gtmp
		       WHERE  Organization_id = x_consol_item_repl_tbl(i).organization_id
		       AND INVENTORY_ITEM_ID =  x_consol_item_repl_tbl(i).item_id
		       AND demand_type_id = l_demand_type_id
		       AND DEMAND_LINE_DETAIL_ID = l_demand_line_detail_id
		       AND demand_header_id = l_demand_header_id
		       AND demand_line_id = l_demand_line_id;


		     IF (l_debug = 1) THEN
			print_debug('Add to the available onhand for this item');
		     END IF;
		     -- In PL/SQL table, increase the available OnHand qty in repl_UOM by L_demand_quantity_in_repl_uom
		     x_consol_item_repl_tbl(i).available_onhand_qty := x_consol_item_repl_tbl(i).available_onhand_qty + L_demand_quantity_in_repl_uom;


		     --If the qty_tree is run the current_demand in the set then there we must decrease the demand_qty from l_atr BUT if the qty_tree was not run for
		     --the current_demand then demand_qty should not be decreased from
		     --  l_atr becse it has already been deducted when qty_tree returned
		     --  l_atr.

		     IF (l_debug = 1) THEN
			print_debug('decrese the consumed qty only if atr was calculated FOR curent demand');
		     END IF;

		     IF  l_qty_tree_demand_line_id = l_demand_line_id THEN
			-- All quantity comparision is in the primary unit
			l_atr := l_atr - l_demand_quantity;
		     END IF;


		   ELSE -- menas detailed at other sub
		     -- SKIP current demand line assuming it will be fulfilled up by other sub
		     -- Since we need to skip to next demand and
		     -- behave as if this demand is in error
		     l_return_status := fnd_api.g_ret_sts_error;
		     GOTO next_dmd_record;
		  END IF;



		ELSE --means rsv does not exists

		  IF (l_debug = 1) THEN
		     print_debug('NO RESERVATION EXISTS FOR CURRENT DEMAND');
		  END IF;


		  IF p_Create_Reservation  = 'Y' THEN

		     IF (l_debug = 1) THEN
			print_debug('p_Create_Rsv is Y and qty available - Creating detailed rsv AT FP sub' );
		     END IF;

		     --TEST: CALL Create_RSV() API to create reservation AT DETAILED LEVEL to this sub
		     l_return_status := fnd_api.g_ret_sts_success;
		     Create_RSV(p_replenishment_type => 1, --  1- Stock Up/Push; 2- Dynamic/Pull
				l_debug => l_debug,
				l_organization_id => x_consol_item_repl_tbl(i).ORGANIZATION_ID,
				l_inventory_item_id => x_consol_item_repl_tbl(i).item_id,
				l_demand_type_id => l_demand_type_id,
				l_demand_so_header_id => L_demand_header_id,
				l_demand_line_id => L_demand_line_id,
				l_split_wdd_id => NULL,
				l_primary_uom_code => l_demand_uom_code,
				l_supply_uom_code => l_demand_uom_code,
				l_atd_qty => L_demand_quantity,
				l_atd_prim_qty => L_demand_quantity,
				l_supply_type_id => 13,
				l_supply_header_id => NULL, -- since sub LEVEL from inventory
				l_supply_line_id => NULL, -- since sub LEVEL from inventory
				l_supply_line_detail_id => NULL, -- since sub LEVEL from inventory
				l_supply_expected_time => SYSDATE,
				l_demand_expected_time => l_expected_ship_date,
				l_subinventory_code => x_consol_item_repl_tbl(i).repl_to_subinventory_code,
		       l_rsv_rec => l_rsv_temp_rec,
		       l_serial_number => l_serial_number,
		       l_to_serial_number => l_to_serial_number,
		       l_quantity_reserved => l_quantity_reserved,
		       l_quantity_reserved2 => l_quantity_reserved2,
		       l_rsv_id => l_rsv_id,
		       x_return_status => l_return_status,
		       x_msg_count => x_msg_count,
		       x_msg_data => x_msg_data
		       );

		     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			IF (l_debug = 1) THEN
			   print_debug('Error returned from create_reservation API: ' || l_return_status);
			END IF;
			-- Proceed to next record. In this case we might have extra amount on MOL than rsv
			GOTO next_dmd_record;

		      ELSE -- reservation creation successful
			IF (l_debug = 1) THEN
			   print_debug('Successfully created a RSV for demand ');
			END IF;

		     END IF;

		   ELSE -- means p_Create_Reservation  = 'N'
		     -- DO nothing
		     IF (l_debug = 1) THEN
			print_debug('p_Create_Rsv is N and qty available' );
		     END IF;
		  END IF; --p_Create_Reservation  = 'Y'

		  -- Mark these demand records as 'RC'.
		  -- These demand lines Status go directly from Ready to
		  -- release to RC because  material is physically present AT the sub
		  -- < in case of open move order, we will not it will NOT be marked RC though>
		  -- Note:  In some cases lines might already by in
		  -- repl_status = RC here BECS original demand cursol includes repl_status = 'C' demand lines

		  IF (l_debug = 1) THEN
		     print_debug('call WSH to mark lines as RC' );
		  END IF;

		  IF l_repl_status <> 'C' THEN
		     update_wdd_repl_status (p_deliv_detail_id   =>  l_demand_line_detail_id
					     , p_repl_status     => 'C'  -- for completed status
					     , x_return_status   => l_return_status
					     );

		     IF l_return_status <> fnd_api.g_ret_sts_success THEN
			GOTO next_dmd_record;
		     END IF;

		  END IF; -- FOR IF l_repl_status <> 'C'



		  IF (l_debug = 1) THEN
		     print_debug('Remove entry from GTMP table');
		  END IF;
		  -- Remove the demand entry from the WMS_REPL_DEMAND_GTMP table
		  DELETE FROM wms_repl_demand_gtmp
		    WHERE  Organization_id = x_consol_item_repl_tbl(i).organization_id
		    AND INVENTORY_ITEM_ID =  x_consol_item_repl_tbl(i).item_id
		    AND demand_type_id = l_demand_type_id
		    AND DEMAND_LINE_DETAIL_ID = l_demand_line_detail_id
		    AND demand_header_id = l_demand_header_id
		    AND demand_line_id = l_demand_line_id;


		  IF (l_debug = 1) THEN
		     print_debug('Increase availble onhand and decrese l_atr');
		  END IF;
		  -- In PL/SQL table, increase the available OnHand qty in repl_UOM by L_demand_quantity_in_repl_uom
		  x_consol_item_repl_tbl(i).available_onhand_qty
		    := x_consol_item_repl_tbl(i).available_onhand_qty + L_demand_quantity_in_repl_uom;

		  -- Decrease the l_atr to reflect correct available OnHand qty for next demand line
		  -- All quantity comparision is in the primary unit
		  l_atr := l_atr - l_demand_quantity;


	       END IF; -- FOR RSV EXISTS


	     ELSE -- means l_atr < l_demand_qty
	       --  Here it can come in one case when
	       --  L_atr > 0 and l_atr < l_demand_qty in subsequent loops after consuming from l_atr
	       --   Once l_atr becomes 0, it goes to other part of the else condition below

	       --  Available onhand (atr) = 22 at location [ out of this 22 QTY,  20 was for D1 initially but in this run another high priority otrder D2 has come above D1]

	       --    Demand  demand_qty  priority  status      Action/new status
	       --    D2    10    high           RC
	       --    D1    20   low  RC  (no rsv exists for d1)      Revert to original stat
	       --    D3    2    lower          Will be marked RC
	       --    D4    5    lowest  RC  (no rsv exists for d1)    Revert to original stat
	       --    D5    10   lowest            Do not touch
	       --    After D2 gets processed and the at the time of processing D1, l_atr = 12 and l_demand_qty = 20
	       --    D3 will be processed in the conditional block of 'l_atr >= l_demand_qty' above
	       --  D5 will be processed in the conditional block ELSE -- means l_atr <= 0 below

	       IF (l_debug = 1) THEN
		  print_debug('Here l_atr < l_demand_qty. Nothing to do..');
	       END IF;


	       IF l_repl_status = 'C' THEN

		  IF (l_debug = 1) THEN
		     print_debug('DmdLine alredy RC, but this run does NOT have enough qty any longer ');
		     print_debug('Backorder delivery_detail - l_demand_line_detail_id ');
		  END IF;
		  -- Code will come here only for Push Repl if Create_rsv = N
		  -- Add to the global variable table to be backordered later

		  l_bkorder_cnt := g_backorder_deliv_tab.COUNT()+1;

		  g_backorder_deliv_tab(l_bkorder_cnt):= l_demand_line_detail_id;
		  g_backorder_qty_tab(l_bkorder_cnt) := l_demand_quantity;
		  -- since we are backordering entire qty parameters
		  -- p_bo_qtys AND  p_req_qtys will have same value
		  g_dummy_table(l_bkorder_cnt)       := 0;

	       END IF; -- FOR l_repl_status = 'C'



	    END IF; -- l_atr > l_demand_qty

	  ELSE -- MEANS l_atr <= 0

	    IF (l_debug = 1) THEN
	       print_debug('Here l_atr <= 0 '||l_atr);
	    END IF;

	    IF l_repl_status = 'C' THEN

	       IF (l_debug = 1) THEN
		  print_debug('DmdLine already RC - but this run does NOT have enough qty any longer');
		  print_debug('Backorder delivery_detail - l_demand_line_detail_id ');
	       END IF;
	       -- Code will come here only for Push Repl if Create_rsv = N
	       -- Add to the global variable table to be backordered later

	       l_bkorder_cnt := g_backorder_deliv_tab.COUNT()+1;

	       g_backorder_deliv_tab(l_bkorder_cnt):= l_demand_line_detail_id;
	       g_backorder_qty_tab(l_bkorder_cnt) := l_demand_quantity;
	       -- since we are backordering entire qty parameters
	       -- p_bo_qtys AND  p_req_qtys will have same value
	       g_dummy_table(l_bkorder_cnt)       := 0;

	    END IF; --FOR l_repl_status = 'C'

	 END IF; -- FOR 	l_atr > 0

	 <<next_dmd_record>>
	 l_prev_org_id := x_consol_item_repl_tbl(i).ORGANIZATION_ID ;
	 l_prev_item_id := x_consol_item_repl_tbl(i).item_id;
	 l_prev_sub_code := x_consol_item_repl_tbl(i).repl_to_subinventory_code;
	 print_debug( 'l_atr AT THE END OF CURRENT DEMAND LINE: '||l_atr);

	 IF l_return_status <> fnd_api.g_ret_sts_success THEN
	    IF (l_debug = 1 ) THEN
	       print_debug('Move to next demand record ignoring this one');
	    END IF;
	    ROLLBACK TO onhd_demand_line_sp;
	    l_return_status := fnd_api.g_ret_sts_success;
	    x_consol_item_repl_tbl(i).total_demand_qty :=
	      x_consol_item_repl_tbl(i).total_demand_qty - l_demand_quantity_in_repl_uom;

	    -- For pull and demand_type_id<>4, Backorder the WDD
	    -- Add to the global variable table to be called at the end of
	    -- the dynamic repl process

	    -- We do not need to do it for Push repl since rollback takes care
	    -- of it whereas for Pull repl, shipping has committed his change and
	    -- hence we need to make explicit call to backorder it

	    IF l_demand_type_id <> 4 AND p_repl_type = g_dynamic_repl AND
	      Nvl(p_repl_level,1) = 1 THEN

	       l_bkorder_cnt := g_backorder_deliv_tab.COUNT()+1;

	       g_backorder_deliv_tab(l_bkorder_cnt):= l_demand_line_detail_id;
	       g_backorder_qty_tab(l_bkorder_cnt) := l_demand_quantity;
	       -- since we are backordering entire qty parameters
	       -- p_bo_qtys AND  p_req_qtys will have same value
	       g_dummy_table(l_bkorder_cnt)       := 0;

	    END IF;


	    DELETE FROM wms_repl_demand_gtmp
	      WHERE  Organization_id = x_consol_item_repl_tbl(i).organization_id
	      AND INVENTORY_ITEM_ID =  x_consol_item_repl_tbl(i).item_id
	      AND demand_type_id = l_demand_type_id
	      AND DEMAND_LINE_DETAIL_ID = l_demand_line_detail_id
	      AND demand_header_id = l_demand_header_id
	      AND demand_line_id = l_demand_line_id;

	 END IF;

      END LOOP; -- for each demand line
      CLOSE c_demand_lines_for_item;

      --At the end for Each item+Sub In PL/SQL table, update the final_replenishment_qty in Repl_UOM
      x_consol_item_repl_tbl(i).final_replenishment_qty
	:= (x_consol_item_repl_tbl(i).total_demand_qty - x_consol_item_repl_tbl(i).available_onhand_qty);

      --Note: the final replenishment qty will be upp by the p_Repl_Lot_Size in Create_repl_Move_order() API
      <<next_onhd_consol_rec>>
	IF l_return_status <> fnd_api.g_ret_sts_success then
	   l_return_status := fnd_api.g_ret_sts_success;
	   ROLLBACK TO onhd_consol_rec_sp;
	   -- if repl_type 2 and demand_type_id <> 4 then revert that WDD to original status
	   -- remove all entries for that item from gtmp
	   -- both done in following API
	   Revert_Consol_item_changes
	     ( p_repl_type         => p_repl_type
	       , p_demand_type_id  => l_demand_type_id
	       , P_item_id         => x_consol_item_repl_tbl(i).item_ID
	       , p_org_id          => x_consol_item_repl_tbl(i).ORGANIZATION_ID
	       , x_return_status   => l_return_status
	       );

	   -- Remove element from consol table, can not do inside this loop
	   -- AS iterating through the same consol record
	   -- store the index of the consol table to be deleted outside the loop
	   l_del_index := l_del_index +1;
	   l_del_consol_item_tb(l_del_index) := i;

	END IF;


      END IF; --IF  not x_consol_item_repl_tbl.exists(i)

   END LOOP; -- main loop on pl/sql table

  --REMOVE CONSOL RECORDS THAT HAS BEEN REMOVED FROM MOVER ORDER CREATION
   -- THIS WILL KEEP DATA IN SYNC
   FOR j IN 1..l_del_consol_item_tb.COUNT() LOOP
      x_consol_item_repl_tbl.DELETE(l_del_consol_item_tb(j));
   END LOOP;


   IF (l_debug = 1 ) THEN
      print_debug('DONE WITH GET_AVAILABLE_ONHAND_QTY API');
   END IF;
   x_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
   WHEN OTHERS THEN
      IF c_demand_lines_for_item%ISOPEN THEN
	 CLOSE c_demand_lines_for_item;
      END IF;
      IF (l_debug = 1) THEN
	 print_debug('Error in GET_AVAILABLE_ONHAND_QTY SQLCODE:'||SQLCODE ||' '||SQLERRM );
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
END GET_AVAILABLE_ONHAND_QTY;




PROCEDURE CREATE_RSV(p_replenishment_type    IN NUMBER, --  1- Stock Up/Push; 2- Dynamic
		     l_debug                 IN NUMBER,
		     l_organization_id       IN NUMBER,
		     l_inventory_item_id     IN NUMBER,
		     l_demand_type_id        IN NUMBER,
		     l_demand_so_header_id   IN NUMBER,
		     l_demand_line_id        IN NUMBER,
		     l_split_wdd_id          IN NUMBER,
		     l_primary_uom_code      IN VARCHAR2,
		     l_supply_uom_code       IN VARCHAR2,
		     l_atd_qty               IN NUMBER,
		     l_atd_prim_qty          IN NUMBER,
		     l_supply_type_id        IN NUMBER,
		     l_supply_header_id      IN NUMBER,
		     l_supply_line_id        IN NUMBER,
		     l_supply_line_detail_id IN NUMBER,
		     l_supply_expected_time  IN DATE,
		     l_demand_expected_time  IN DATE,
		     l_subinventory_code     IN VARCHAR2 DEFAULT NULL,
		     l_rsv_rec               IN OUT NOCOPY inv_reservation_global.mtl_reservation_rec_type,
		     l_serial_number         IN OUT NOCOPY inv_reservation_global.serial_number_tbl_type,
  l_to_serial_number      IN OUT NOCOPY inv_reservation_global.serial_number_tbl_type,
  l_quantity_reserved     IN OUT NOCOPY NUMBER,
  l_quantity_reserved2    IN OUT NOCOPY NUMBER,
  l_rsv_id                IN OUT NOCOPY NUMBER,
  x_return_status         IN OUT NOCOPY VARCHAR2,
  x_msg_count             IN OUT NOCOPY NUMBER,
  x_msg_data              IN OUT NOCOPY VARCHAR2)
  IS


     l_progress VARCHAR2(10);

BEGIN

   --
   -- Set the values for the reservation record to be created
   IF (l_debug = 1) THEN
      print_debug('Requirement Date: ' || l_demand_expected_time);
   END IF;

   l_rsv_rec.reservation_id          := NULL;
   l_rsv_rec.requirement_date        := l_demand_expected_time;
   l_rsv_rec.organization_id         := l_organization_id;
   l_rsv_rec.inventory_item_id       := l_inventory_item_id;
   l_rsv_rec.demand_source_name      := NULL;
   l_rsv_rec.demand_source_type_id   := l_demand_type_id;
   l_rsv_rec.demand_source_header_id := l_demand_so_header_id;
   -- here l_demand_so_header_id is inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id)
   l_rsv_rec.demand_source_line_id        := l_demand_line_id;
   l_rsv_rec.orig_demand_source_type_id   := l_demand_type_id;
   l_rsv_rec.orig_demand_source_header_id := l_demand_so_header_id;
   l_rsv_rec.orig_demand_source_line_id   := l_demand_line_id;

   -- For now supply is only from Inventory supply_source_type_id = 13
   l_rsv_rec.demand_source_line_detail      := l_split_wdd_id;
   l_rsv_rec.orig_demand_source_line_detail := l_split_wdd_id;

   l_rsv_rec.demand_source_delivery         := NULL;
   l_rsv_rec.primary_uom_code               := l_primary_uom_code;
   l_rsv_rec.primary_uom_id                 := NULL;
   l_rsv_rec.secondary_uom_code             := null;
   l_rsv_rec.secondary_uom_id               := NULL;
   l_rsv_rec.reservation_uom_code           := l_supply_uom_code;
   l_rsv_rec.reservation_uom_id             := NULL;
   l_rsv_rec.reservation_quantity           := l_atd_qty;
   l_rsv_rec.primary_reservation_quantity   := l_atd_prim_qty;
   l_rsv_rec.secondary_reservation_quantity := null;
   l_rsv_rec.detailed_quantity              := NULL;
   l_rsv_rec.secondary_detailed_quantity    := NULL;
   l_rsv_rec.autodetail_group_id            := NULL;
   l_rsv_rec.external_source_code           := 'REPL'; -- Mark the external source
   l_rsv_rec.external_source_line_id        := NULL;
   l_rsv_rec.supply_source_type_id          := l_supply_type_id;
   l_rsv_rec.orig_supply_source_type_id     := l_supply_type_id;
   l_rsv_rec.supply_source_name             := NULL;

   l_rsv_rec.supply_source_header_id        := l_supply_header_id;
   l_rsv_rec.supply_source_line_id          := l_supply_line_id;
   l_rsv_rec.supply_source_line_detail      := l_supply_line_detail_id;
   l_rsv_rec.orig_supply_source_header_id   := l_supply_header_id;
   l_rsv_rec.orig_supply_source_line_id     := l_supply_line_id;
   l_rsv_rec.orig_supply_source_line_detail := l_supply_line_detail_id;

   l_rsv_rec.revision           := NULL;
   l_rsv_rec.subinventory_code  := l_subinventory_code;
   l_rsv_rec.subinventory_id    := NULL;
   l_rsv_rec.locator_id         := NULL;
   l_rsv_rec.lot_number         := NULL;
   l_rsv_rec.lot_number_id      := NULL;
   l_rsv_rec.pick_slip_number   := NULL;
   l_rsv_rec.lpn_id             := NULL;
   l_rsv_rec.attribute_category := NULL;
   l_rsv_rec.attribute1         := NULL;
   l_rsv_rec.attribute2         := NULL;
   l_rsv_rec.attribute3         := NULL;
   l_rsv_rec.attribute4         := NULL;
   l_rsv_rec.attribute5         := NULL;
   l_rsv_rec.attribute6         := NULL;
   l_rsv_rec.attribute7         := NULL;
   l_rsv_rec.attribute8         := NULL;
   l_rsv_rec.attribute9         := NULL;
   l_rsv_rec.attribute10        := NULL;
   l_rsv_rec.attribute11        := NULL;
   l_rsv_rec.attribute12        := NULL;
   l_rsv_rec.attribute13        := NULL;
   l_rsv_rec.attribute14        := NULL;
   l_rsv_rec.attribute15        := NULL;
   l_rsv_rec.ship_ready_flag    := NULL;
   l_rsv_rec.staged_flag        := NULL;

   l_rsv_rec.crossdock_flag        := NULL;
   l_rsv_rec.crossdock_criteria_id := NULL;

   l_rsv_rec.serial_reservation_quantity := NULL;
   l_rsv_rec.supply_receipt_date         := l_supply_expected_time;
   l_rsv_rec.demand_ship_date            := l_demand_expected_time;
   l_rsv_rec.project_id                  := NULL;
   l_rsv_rec.task_id                     := NULL;
   l_rsv_rec.serial_number               := NULL;

   IF (l_debug = 1) THEN
      print_debug('Call the create_reservation API to create the replenishemnt reservation');
   END IF;

   INV_RESERVATION_PVT.create_reservation(p_api_version_number          => 1.0,
					  p_init_msg_lst                => fnd_api.g_false,
					  x_return_status               => x_return_status,
					  x_msg_count                   => x_msg_count,
					  x_msg_data                    => x_msg_data,
					  p_rsv_rec                     => l_rsv_rec,
					  p_serial_number               => l_serial_number,
					  x_serial_number               => l_to_serial_number,
					  p_partial_reservation_flag    => fnd_api.g_false,
					  p_force_reservation_flag      => fnd_api.g_false,
					  p_validation_flag             => fnd_api.g_true,
					  x_quantity_reserved           => l_quantity_reserved,
					  x_secondary_quantity_reserved => l_quantity_reserved2,
					  x_reservation_id              => l_rsv_id);

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (l_debug = 1) THEN

	 print_debug('Error returned from INV create_reservation API: ' ||
		     x_return_status);
      END IF;
      -- Raise an exception.  The caller will do the rollback, cleanups,
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   l_progress := '20';

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IF (l_debug = 1) THEN
	 print_debug('Exiting Create_RSV - Execution error: ' || l_progress || ' ' ||
		     TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')|| ' ' ||x_msg_data);
      END IF;

END Create_RSV;




FUNCTION  Get_Expected_Time(p_demand_type_id in number,
			    p_source_header_id in number,
			    p_source_line_id          in number,
			    p_delivery_line_id in number) RETURN DATE
  IS



     l_demand_expected_time DATE := null;

     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);


     CURSOR wdd_rec_cursor IS
	SELECT  NVL(wts.planned_departure_date,
		    NVL(wdd.date_scheduled,
			NVL(ool.schedule_ship_date, ool.promise_date))) AS expected_ship_date
			  FROM wsh_delivery_details wdd, oe_order_lines_all ool,
			  wsh_delivery_assignments_v wda, wsh_new_deliveries wnd, wsh_delivery_legs wdl,
			  wsh_trip_stops wts, wsh_trips wt
			  WHERE wdd.delivery_detail_id = p_delivery_line_id
			  AND ool.line_id = p_source_line_id
			  AND wdd.source_line_id = ool.line_id
			  AND wdd.source_header_id = p_source_header_id
			  AND wdd.delivery_detail_id = wda.delivery_detail_id (+)
			  AND wda.delivery_id = wnd.delivery_id (+)
			  AND wnd.delivery_id = wdl.delivery_id (+)
			  AND (wdl.sequence_number IS NULL OR
			       wdl.sequence_number = (SELECT MIN(sequence_number)
						      FROM wsh_delivery_legs wdl_first_leg
						      WHERE wdl_first_leg.delivery_id = wdl.delivery_id))
			    AND wdl.pick_up_stop_id = wts.stop_id (+)
			    AND wts.trip_id         = wt.trip_id  (+);

BEGIN

   IF (p_demand_type_id NOT IN (2, 8)) THEN
      RETURN NULL;
   END IF;

   --     IF (l_debug = 1) THEN
   --       print_debug('===============================');
   --       print_debug('p_demand_type_id : ' ||p_demand_type_id);
   --       print_debug(' p_source_header_id : ' || p_source_header_id);
   --       print_debug('p_source_line_id : ' ||p_source_line_id  );
   --       print_debug('p_delivery_line_id : ' ||p_delivery_line_id);
   --       END IF;


   OPEN wdd_rec_cursor;
   FETCH wdd_rec_cursor INTO l_demand_expected_time;
   IF (wdd_rec_cursor%NOTFOUND) THEN
      IF (l_debug = 1) THEN
	 print_debug('WDD cursor did not return any records!');
      END IF;
      l_demand_expected_time := NULL;
   END IF;
   CLOSE wdd_rec_cursor;

   IF l_debug = 1 THEN
      print_debug('******Returning Get_Expected_Time : '||l_demand_expected_time );
   END IF;

   RETURN l_demand_expected_time;

EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('Get_Expected_Time: ' || sqlcode || ', ' || sqlerrm);
      END IF;
END Get_Expected_Time;




FUNCTION GET_SORT_TRIP_STOP_DATE(P_delivery_detail_id  IN NUMBER,
				 P_TRIP_STOP_DATE_SORT IN VARCHAR2)
  RETURN NUMBER
  IS

     -- If the current delivery detail is a part of a trip that has multiple
     -- deliveries each HAVING its own planned_departure_date, THEN MIN needs to
     -- be selected

     CURSOR c_planned_departure_date IS
	SELECT  MIN(NVL(wts.planned_departure_date, wdd.date_scheduled))
	  --	    MIN(NVL(wts.planned_departure_date,
	  --	    NVL(wdd.date_scheduled,
	  --	    NVL(ool.schedule_ship_date, ool.promise_date)))) AS min_expected_ship_date,
	  FROM wsh_new_deliveries wnd,  wsh_delivery_details wdd, wsh_delivery_assignments_v wda,
	  wsh_delivery_legs wdl, wsh_trip_stops wts
	  --	    oe_order_lines_all ool

	  WHERE wdd.delivery_detail_id = p_delivery_detail_id
	  --	    AND wdd.source_line_id = ool.line_id (+)
	  AND wnd.shipment_direction = 'O'
	  AND wnd.delivery_id = wda.delivery_id (+)
	  AND wda.delivery_detail_id = wdd.delivery_detail_id (+)
	  AND wnd.delivery_id = wdl.delivery_id (+)
	  AND (wdl.sequence_number IS NULL OR
	       wdl.sequence_number = (SELECT MIN(sequence_number)
				      FROM wsh_delivery_legs wdl_first_leg
				      WHERE wdl_first_leg.delivery_id = wdl.delivery_id))
	    AND wdl.pick_up_stop_id = wts.stop_id (+)
	    GROUP BY wnd.organization_id, wnd.delivery_id, wts.stop_id;


	  l_planned_departure_date date;
	  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN

   -- <<c_planned_departure_date(wdd.delivery_detail_id) will return planned trip date based on WTS.PLANNED_DEPARTURE_DATE if any exists>>

   --TEST: correst planned date is passed
   OPEN c_planned_departure_date;
   LOOP
      FETCH c_planned_departure_date INTO  l_planned_departure_date;
      EXIT WHEN c_planned_departure_date%NOTFOUND;
   END LOOP;
   CLOSE c_planned_departure_date;

   IF (l_debug = 1) THEN
      print_debug('get_planned_departure_date: '||l_planned_departure_date);
   END IF;


   IF l_planned_departure_date is NULL THEN
      RETURN NULL;

    ELSE

      IF P_TRIP_STOP_DATE_SORT = 'ASC' then
	 RETURN (l_planned_departure_date - TO_DATE('01-01-1700 23:59:59', 'DD-MM-YYYY HH24:MI:SS'));

       ELSIF P_TRIP_STOP_DATE_SORT = 'DESC' then
	 RETURN (TO_DATE('01-01-1700 23:59:59', 'DD-MM-YYYY HH24:MI:SS') - l_planned_departure_date);

       ELSE
	 --means P_TRIP_STOP_DATE_SORT is NULL
	 RETURN  NULL;
      END IF;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('GET_SORT_TRIP_STOP_DATE: ' || sqlcode || ', ' || sqlerrm);
      END IF;
END GET_SORT_TRIP_STOP_DATE;




FUNCTION GET_SORT_INVOICE_VALUE(P_SOURCE_HEADER_ID NUMBER, P_INVOICE_VALUE_SORT VARCHAR2)
  RETURN NUMBER
  IS
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN


   IF P_INVOICE_VALUE_SORT = 'ASC' THEN
      RETURN  WSH_PICK_CUSTOM.OUTSTANDING_ORDER_VALUE(p_SOURCE_HEADER_ID);

    ELSIF P_INVOICE_VALUE_SORT = 'DESC' THEN
      RETURN (-1 *  WSH_PICK_CUSTOM.OUTSTANDING_ORDER_VALUE(p_SOURCE_HEADER_ID));

    ELSE
      RETURN  NULL;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('GET_SORT_INVOICE_VALUE: ' || sqlcode || ', ' || sqlerrm);
      END IF;

END GET_SORT_INVOICE_VALUE;


FUNCTION  get_available_capacity(p_quantity_function    IN NUMBER,
				 p_organization_id      IN NUMBER,
				 p_subinventory_code    IN VARCHAR2,
				 p_locator_id           IN NUMBER,
				 p_inventory_item_id    IN NUMBER,
				 p_unit_volume          IN NUMBER,
				 p_unit_volume_uom_code IN VARCHAR2,
				 p_unit_weight          IN NUMBER,
				 p_unit_weight_uom_code IN VARCHAR2,
				 p_primary_uom          IN VARCHAR2,
				 p_transaction_uom      IN VARCHAR2,
				 p_base_uom             IN VARCHAR2,
				 p_transaction_quantity IN NUMBER)
  RETURN NUMBER

  IS
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_possible_quantity NUMBER;
     l_sec_possible_quantity NUMBER;

BEGIN
   IF (l_debug = 1) THEN
      print_debug('get_available_capacity - qty function code: ' || p_quantity_function);
   END IF;


   IF p_quantity_function is NOT NULL THEN
      IF p_quantity_function = 530003 THEN
	 l_possible_quantity  :=
	   wms_parameter_pvt.getavailableunitcapacity
	   (
	    p_organization_id            => p_organization_id
	    , p_subinventory_code          => p_subinventory_code
	    , p_locator_id                 => p_locator_id
	    );
       ELSIF p_quantity_function = 530007 THEN
	 l_possible_quantity  :=
	   wms_parameter_pvt.getavailablevolumecapacity
	   (
	    p_organization_id            => p_organization_id
	    , p_subinventory_code          => p_subinventory_code
	    , p_locator_id                 => p_locator_id
	    , p_inventory_item_id          => p_inventory_item_id
	    , p_unit_volume                => p_unit_volume
	    , p_unit_volume_uom_code       => p_unit_volume_uom_code
	    , p_primary_uom                => p_primary_uom
	    , p_transaction_uom            => p_transaction_uom
	    , p_base_uom                   => p_base_uom
	    );
       ELSIF p_quantity_function = 530011 THEN
	 l_possible_quantity  :=
	   wms_parameter_pvt.getavailableweightcapacity
	   (
	    p_organization_id            => p_organization_id
	    , p_subinventory_code          => p_subinventory_code
	    , p_locator_id                 => p_locator_id
	    , p_inventory_item_id          => p_inventory_item_id
	    , p_unit_weight                => p_unit_weight
	    , p_unit_weight_uom_code       => p_unit_weight_uom_code
	    , p_primary_uom                => p_primary_uom
	    , p_transaction_uom            => p_transaction_uom
	    , p_base_uom                   => p_base_uom
	    );
       ELSIF p_quantity_function = 530015 THEN
	 l_possible_quantity  :=
	   wms_parameter_pvt.getminimumavailablevwcapacity
	   (
	    p_organization_id            => p_organization_id
	    , p_subinventory_code          => p_subinventory_code
	    , p_locator_id                 => p_locator_id
	    , p_inventory_item_id          => p_inventory_item_id
	    , p_unit_volume                => p_unit_volume
	    , p_unit_volume_uom_code       => p_unit_volume_uom_code
	    , p_unit_weight                => p_unit_weight
	    , p_unit_weight_uom_code       => p_unit_weight_uom_code
	    , p_primary_uom                => p_primary_uom
	    , p_transaction_uom            => p_transaction_uom
	    , p_base_uom                   => p_base_uom
	    );
       ELSIF p_quantity_function = 530019 THEN
	 l_possible_quantity  :=
	   wms_parameter_pvt.getminimumavailableuvwcapacity
	   (
	    p_organization_id            => p_organization_id
	    , p_subinventory_code          => p_subinventory_code
	    , p_locator_id                 => p_locator_id
	    , p_inventory_item_id          => p_inventory_item_id
	    , p_unit_volume                => p_unit_volume
	    , p_unit_volume_uom_code       => p_unit_volume_uom_code
	    , p_unit_weight                => p_unit_weight
	    , p_unit_weight_uom_code       => p_unit_weight_uom_code
	    , p_primary_uom                => p_primary_uom
	    , p_transaction_uom            => p_transaction_uom
	    , p_base_uom                   => p_base_uom
	    );
       ELSIF p_quantity_function = 530023 THEN
	 l_possible_quantity  :=
	   wms_re_custom_pub.getavailablelocationcapacity
	   (
	    p_organization_id            => p_organization_id
	    , p_subinventory_code          => p_subinventory_code
	    , p_locator_id                       =>    p_locator_id
	    , p_inventory_item_id          => p_inventory_item_id
	    , p_transaction_quantity       => p_transaction_quantity
	    , p_transaction_uom            =>  p_transaction_uom
	    );
       ELSE
	 l_possible_quantity  := 0;
	 IF (l_debug = 1) THEN
	    print_debug('bad_qtyF - Invalid Quantity Function');
	 END IF;
      END IF;

    ELSE -- means p_quantity_function is null
      -- capacity should not be considered
      l_possible_quantity := 1e125;
      l_sec_possible_quantity := 1e125;
   END IF;

   IF l_debug = 1 THEN
      print_debug('Avail. capacity: ' || l_possible_quantity);

   END IF;

   RETURN l_possible_quantity ;

EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('Exception in Get_Available_Capacity: ' || sqlcode || ', ' || sqlerrm);
      END IF;

END Get_Available_Capacity;




PROCEDURE Get_to_Sub_For_Dynamic_Repl(P_Org_id               IN NUMBER,
				      P_Item_id              IN NUMBER,
				      P_PRIMARY_DEMAND_QTY   IN NUMBER,
				      X_TO_SUBINVENTORY_CODE IN OUT NOCOPY VARCHAR2,
				      X_REPL_UOM_CODE        OUT NOCOPY VARCHAR2)
  IS
     CURSOR c_destination_sub IS
	SELECT SECONDARY_INVENTORY, PICK_UOM_CODE
	  FROM (select MISI.SECONDARY_INVENTORY,
		MSI.PICK_UOM_CODE,
		MSIB.PRIMARY_UOM_CODE,
		get_conversion_rate(MISI.INVENTORY_ITEM_id,
				    MSI.PICK_UOM_CODE,
				    MSIB.PRIMARY_UOM_CODE) AS CONVERSION_RATE
		from MTL_ITEM_SUB_INVENTORIES  MISI,
		MTL_SECONDARY_INVENTORIES MSI,
		MTL_SYSTEM_ITEMS_B        MSIB
		WHERE MISI.organization_id = P_Org_id
		and MISI.INVENTORY_ITEM_ID = P_Item_id
		AND MISI.SECONDARY_INVENTORY = MSI.SECONDARY_INVENTORY_NAME
		AND MISI.ORGANIZATION_ID = MSI.ORGANIZATION_ID
		AND MSI.PICK_UOM_CODE IS NOT NULL
		AND MOD(P_PRIMARY_DEMAND_QTY,(get_conversion_rate(MISI.INVENTORY_ITEM_id,MSI.PICK_UOM_CODE,MSIB.PRIMARY_UOM_CODE)))=0
		AND get_conversion_rate(MISI.INVENTORY_ITEM_id,
					MSI.PICK_UOM_CODE,
					MSIB.PRIMARY_UOM_CODE) > 0
		AND MISI.INVENTORY_ITEM_id = MSIB.INVENTORY_ITEM_id
		AND MISI.ORGANIZATION_ID = MSIB.ORGANIZATION_ID
		ORDER BY CONVERSION_RATE DESC, MSI.PICKING_ORDER) X
		  WHERE ROWNUM = 1;

		l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);


BEGIN

   IF (l_debug = 1) THEN
      print_debug('Inside Get_to_Sub_For_Dynamic_Repl: TO_SUB :' ||X_TO_SUBINVENTORY_CODE);
   END IF;


   IF x_to_subinventory_code IS NOT NULL THEN
      -- THIS SUB VALUE WAS SPECIFIED WHILE CREATING THE SO, JUST FIND THE UOM CODE

      SELECT PICK_UOM_CODE INTO  x_repl_uom_code
	FROM  MTL_SECONDARY_INVENTORIES MSI
	WHERE MSI.ORGANIZATION_ID = p_org_id
	and secondary_inventory_name = x_to_subinventory_code;


    ELSE
      -- FIND THE TO_SUB BASED ON LOGIC BELOW

      -- 2.1- Get the item and find out possible destination-sub candidates
      --from the item-subinventory table (MTL_ITEM_SUB_INVENTORIES).
      --  Make sure that these subinventories have pick-uom defined as well.

      --2.2- Rank these subinventories in the decreasing order of pick-uom
      --conversion (with respect to primary UOM for the item) and 'Picking
      --  order defined for the sub (Note: it does not matter whether source subinventory is defined for these destination subs in the item-subinventory form)

      --2.3- Among all these destination Sub with pick-UOM, pick the one that has the replenishment_qty as a whole number multiple of conversion qty.
      --  (Example: Consider the hierarchy PALLET(PLT) > CASE(CS) > EACH(Ea);
      --  Conversion factors of PLT= 100Ea and CS = 10 Ea;
      --  If the repl_qty = 23; then chosen destination sub will be EACH
      --  If the repl_qty = 30; then chosen destination sub will be CASE
      --  If the repl_qty = 123; then chosen destination sub will be EACH
      --  If the repl_qty = 130; then chosen destination sub will be CASE
      --  If the repl_qty = 100; then chosen destination sub will be PALLET)

      --  Justification:  in 80% of the cases, qty need to be replenished for small orders from small pick uom areas. For all big orders they order in whole numbers only (like PLT or CS)

      -- Note: conversion rate is in from higher UOM to lower UOM

      OPEN c_destination_sub;
      LOOP
	 FETCH c_destination_sub
	   INTO X_TO_SUBINVENTORY_CODE, X_REPL_UOM_CODE;
	 EXIT WHEN c_destination_sub%NOTFOUND;
      END LOOP;
      CLOSE c_destination_sub;

      -- Value of X_TO_SUBINVENTORY_CODE and  X_REPL_UOM_CODE is NULL menas
      -- Either no record for the item exist in the item-sub form
      -- OR Conversion UOM was not specified the identified sub and corresponding picking uom for the sub
      -- OR PICK_UOM_CODE was not specified for the sub that is specified in the item-sub form

   END IF; -- FOR  x_to_subinventory_code IS NOT NULL


   IF (l_debug = 1) THEN

      print_debug( 'Dynamic Repl: X_TO_SUBINVENTORY_CODE :' || X_TO_SUBINVENTORY_CODE);
      print_debug( 'Dynamic Repl: X_REPL_UOM_CODE :'        || X_REPL_UOM_CODE);

   END IF;

EXCEPTION
   WHEN OTHERS THEN

      IF c_destination_sub%ISOPEN THEN
	 CLOSE c_destination_sub;
      END IF;
      IF l_debug = 1 THEN
	 print_debug('Exception in Get_to_Sub_For_Dynamic_Repl: ' || sqlcode || ', ' || sqlerrm);
      END IF;

END Get_to_Sub_For_Dynamic_Repl;



PROCEDURE POPULATE_DYNAMIC_REPL_DEMAND(p_repl_level  IN NUMBER,
				       p_org_id      IN NUMBER,
				       P_Batch_id                 IN NUMBER,
				       p_Release_Sequence_Rule_Id IN NUMBER,
				       x_consol_item_repl_tbl     OUT NOCOPY CONSOL_ITEM_REPL_TBL,
				       x_return_status            OUT NOCOPY VARCHAR2,
				       x_msg_count                OUT NOCOPY NUMBER,
				       x_msg_data                 OUT NOCOPY VARCHAR2)
  IS

     L_ORDER_ID_SORT           VARCHAR2(4) := NULL;
     L_INVOICE_VALUE_SORT      VARCHAR2(4) := NULL;
     L_SCHEDULE_DATE_SORT      VARCHAR2(4) := NULL;
     L_TRIP_STOP_DATE_SORT     VARCHAR2(4) := NULL;
     L_SHIPMENT_PRI_SORT       VARCHAR2(4) := NULL;
     l_debug              NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  CURSOR c_dynamic_repl_demand IS
     SELECT wdd.inventory_item_id as item_id,
       inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id) AS header_id,
       wdd.source_line_id AS line_id,
       wdd.delivery_detail_id,
       decode(wdd.source_document_type_id, 10, 8, 2) as demand_type_id, -- for SO=2 and Internal Order=8
       wdd.requested_quantity, -- this is always stored in primary UOM
	 wdd.requested_quantity_uom,
	 NVL(WMS_REPLENISHMENT_PVT.Get_Expected_Time(decode(wdd.source_document_type_id, 10, 8, 2),
						 wdd.source_header_id,
						 wdd.source_line_id,
						 wdd.delivery_detail_id),
	 WDD.date_scheduled) as expected_ship_date,
	   wdd.subinventory,
	   wdd.replenishment_status,
	   wdd.released_status,
	   -- get for sort_attribute1
            To_number(DECODE(p_Release_Sequence_Rule_Id,
                  null,
                  null,
                  DECODE(g_ordered_psr(1).attribute_name,
                         'ORDER_NUMBER',
                         DECODE(L_ORDER_ID_SORT,
                                'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
			       NULL),
			 'INVOICE_VALUE',
                         GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
                                'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
                         NULL))) as sort_attribute1,

           -- get for sort_attribute2
            To_number(DECODE(p_Release_Sequence_Rule_Id,
                  null,
                  null,
                  DECODE(g_ordered_psr(2).attribute_name,
                         'ORDER_NUMBER',
			 DECODE(L_ORDER_ID_SORT,
                                'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
				NULL),
                         'INVOICE_VALUE',
                         GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
                                'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
                         NULL))) as sort_attribute2,

           -- get for sort_attribute3
            To_number(DECODE(p_Release_Sequence_Rule_Id,
                  null,
                  null,
                  DECODE(g_ordered_psr(3).attribute_name,
                         'ORDER_NUMBER',
			 DECODE(L_ORDER_ID_SORT,
                                'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
				NULL),
                         'INVOICE_VALUE',
                         GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
                                'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
                         NULL))) as sort_attribute3,

           -- get for sort_attribute4
            To_number(DECODE(p_Release_Sequence_Rule_Id,
                  null,
                  null,
                  DECODE(g_ordered_psr(4).attribute_name,
                         'ORDER_NUMBER',
			 DECODE(L_ORDER_ID_SORT,
                                'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
				NULL),
			 'INVOICE_VALUE',
                         GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
                                'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
                         NULL))) as sort_attribute4,

           -- get for sort_attribute5
            To_number(DECODE(p_Release_Sequence_Rule_Id,
                  null,
                  null,
                  DECODE(g_ordered_psr(5).attribute_name,
                         'ORDER_NUMBER',
			 DECODE(L_ORDER_ID_SORT,
                                'ASC',
                                To_number(wdd.source_header_number),
                                'DESC',
                                (-1 * To_number(wdd.SOURCE_HEADER_NUMBER)),
                                null),
                         'SHIPMENT_PRIORITY',
			 DECODE(WDD.SHIPMENT_PRIORITY_CODE,
				'High',
				20,
				'Standard',
				10,
				NULL),
                         'INVOICE_VALUE',
                         GET_SORT_INVOICE_VALUE(WDD.SOURCE_HEADER_ID,
                                                L_INVOICE_VALUE_SORT),
                         'SCHEDULE_DATE',
                         DECODE(L_SCHEDULE_DATE_SORT,
                                'ASC',
                                (WDD.DATE_SCHEDULED -
                                TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS')),
                                'DESC',
                                (TO_DATE('01-01-1700 23:59:59',
                                         'DD-MM-YYYY HH24:MI:SS') -
                                WDD.DATE_SCHEDULED),
                                null),
                         'TRIP_STOP_DATE',
                         GET_SORT_TRIP_STOP_DATE(wdd.delivery_detail_id,
                                                 L_TRIP_STOP_DATE_SORT),
                         NULL))) as sort_attribute5
	FROM wsh_delivery_details wdd
	WHERE wdd.source_code = 'OE'
	 AND wdd.organization_id = p_org_id
	 AND wdd.requested_quantity > 0
          -- excluding Replenishment Requested status
       AND wdd.released_status in ('R', 'B') and wdd.replenishment_status = 'R'
          -- there might not be reservation
       AND NOT EXISTS
     (select 1
              from mtl_reservations mr
             WHERE MR.DEMAND_SOURCE_LINE_ID = wdd.source_line_id
               and MR.DEMAND_SOURCE_HEADER_ID =
                   inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id)
               and MR.demand_source_type_id =
                   decode(wdd.source_document_type_id, 10, 8, 2)
               and MR.SUBINVENTORY_CODE IS NOT NULL) --locator is not needed -- Exclude detailed RSV
       AND NOT EXISTS
     (select wrd.demand_line_detail_id
      from WMS_REPLENISHMENT_DETAILS wrd
      where wrd.demand_line_detail_id = wdd.delivery_detail_id
      and wrd.demand_line_id = wdd.source_line_id
      and wrd.organization_id = wdd.organization_id
      AND wrd.organization_id = p_org_id)
     AND wdd.batch_id = P_Batch_id
     ORDER BY sort_attribute1,
              sort_attribute2,
              sort_attribute3,
              sort_attribute4,
              sort_attribute5
       FOR UPDATE SKIP LOCKED;


	       CURSOR c_item_repl_cur IS
		  SELECT inventory_item_id,
		    sum(quantity_in_repl_uom) as total_demand_qty,
		      MIN(expected_ship_date) as date_required,
			repl_to_subinventory_code,
			repl_uom_code
			FROM wms_repl_demand_gtmp
			WHERE organization_id = p_org_id
			GROUP BY inventory_item_id, repl_to_subinventory_code,repl_uom_code
			ORDER BY inventory_item_id, repl_to_subinventory_code;


		      l_repl_uom_code             VARCHAR2(3);
		      L_quantity_in_repl_uom      NUMBER;
		      l_conversion_rate           NUMBER;

		      l_return_value BOOLEAN;
		      l_atr_ORG NUMBER;

		      l_detail_info_tab             WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
		      l_in_rec                      WSH_INTERFACE_EXT_GRP.detailInRecType;
		      l_out_rec                     WSH_INTERFACE_EXT_GRP.detailOutRecType;

		      l_pr_sub VARCHAR2(10);

		      -- BULK OPERATION: Table to store results from the open demand for replenishment
		      l_item_id_tb num_tab;
		      l_header_id_tb num_tab;
		      l_line_id_tb num_tab;
		      l_delivery_detail_id_tb num_tab;
		      l_demand_type_id_tb num_tab;
		      l_requested_quantity_tb num_tab;
		      l_requested_quantity_uom_tb uom_tab;
		      l_quantity_in_repl_uom_tb num_tab;
		      l_expected_ship_date_tb date_tab;
		      l_repl_status_tb char1_tab;
		      l_released_status_tb char1_tab;
		      l_attr1_tb num_tab;
		      l_attr2_tb num_tab;
		      l_attr3_tb num_tab;
		      l_attr4_tb num_tab;
		      l_attr5_tb num_tab;
		      l_repl_to_sub_code_tb char_tab;
		      l_repl_UOM_CODE_tb uom_tab;


		      -- BULK OPERATION:  Table to store consolidate demand results for replenishment
		      l_total_demand_qty_tb num_tab;
		      l_date_required_tb date_tab;

		      l_temp_cnt NUMBER; -- removei t

		      l_return_status VARCHAR2(3) := fnd_api.g_ret_sts_success;
		      l_revert_wdd BOOLEAN := FALSE;

		      l_bkorder_cnt NUMBER;
BEGIN

   x_return_status := l_return_status;
   SAVEPOINT populate_dyn_demand_sp;
   IF (l_debug = 1) THEN
      print_debug('Inside  POPULATE_DYNAMIC_REPL_DEMAND Procedure');
      print_debug('Release_Sequence_Rule_Id: '||p_Release_Sequence_Rule_Id);
   END IF;


   -- Get the Order By Clause based on Pick Release Rule
   --initialize gloabl variables
   -- delete old value
   g_ordered_psr.DELETE;
   init_rules(p_pick_seq_rule_id    =>  p_Release_Sequence_Rule_Id,
	      x_order_id_sort       =>  l_ORDER_ID_SORT,
	      x_INVOICE_VALUE_SORT  =>  l_INVOICE_VALUE_SORT,
	      x_SCHEDULE_DATE_SORT  =>  l_SCHEDULE_DATE_SORT,
	      x_trip_stop_date_sort =>  l_TRIP_STOP_DATE_SORT,
	      x_SHIPMENT_PRI_SORT   =>  l_shipment_pri_sort,
	      x_ordered_psr         =>  g_ordered_psr,
	      x_api_status          =>  l_return_status );


   IF (l_debug = 1) THEN
      print_debug('Status after calling init_rules'||l_return_status);
   END IF;
   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      GOTO end_populate;
   END IF;


   -- 1- Go through all the demand lines that are marked as Replenishement requested and insert them in the
   -- WMS_REPL_DEMAND_GTMP table

   -- USE BULK INSERT FROM CURSOR TO THE TABLE AND THEN UPDATE THE TABLE FOR
   -- l_repl_to_sub_code, l_repl_uom_code and l_quantity in repl_uom

   l_item_id_tb.DELETE;
   l_header_id_tb.DELETE;
   l_line_id_tb.DELETE;
   l_delivery_detail_id_tb.DELETE;
   l_demand_type_id_tb.DELETE;
   l_requested_quantity_tb.DELETE;
   l_requested_quantity_uom_tb.DELETE;
   l_expected_ship_date_tb.DELETE;
   l_repl_status_tb.DELETE;
   l_released_status_tb.DELETE;
   l_attr1_tb.DELETE;
   l_attr2_tb.DELETE;
   l_attr3_tb.DELETE;
   l_attr4_tb.DELETE;
   l_attr5_tb.DELETE;
   l_repl_to_sub_code_tb.DELETE;
   l_quantity_in_repl_uom_tb.DELETE;
   l_repl_uom_code_tb.DELETE;

   -- BULK Fetch all data from the demand cursor
   BEGIN
      OPEN c_dynamic_repl_demand;
      FETCH c_dynamic_repl_demand BULK COLLECT INTO
	l_item_id_tb,l_header_id_tb, l_line_id_tb,
	l_delivery_detail_id_tb,l_demand_type_id_tb,
	l_requested_quantity_tb,l_requested_quantity_uom_tb,
	l_expected_ship_date_tb,l_repl_to_sub_code_tb,l_repl_status_tb,	l_released_status_tb,
	l_attr1_tb,l_attr2_tb,l_attr3_tb,l_attr4_tb,l_attr5_tb;
      CLOSE c_dynamic_repl_demand;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Exception retrieving open repl demand records');
	 END IF;
	 l_return_status := fnd_api.g_ret_sts_error;
	 GOTO end_populate;
   END;

   select pick_from_subinventory INTO l_PR_sub
     from wsh_picking_batches where batch_id = p_batch_id;

   IF (l_debug = 1) THEN
      print_debug('At this point total number of dd_ids considered  :' ||l_delivery_detail_id_tb.COUNT);
      print_debug('Subinventory specified at the time of pick release:'||l_PR_sub);
   END IF;


   -- Now process/calculate ALL records
   FOR j IN l_delivery_detail_id_tb.FIRST..l_delivery_detail_id_tb.LAST LOOP

      l_revert_wdd := FALSE;

      -- Consider for replenishment
      -- Try to get the Destination sub for the to_be_created replenishemnt move order

      -- Subinventory specified at Pick release time should take priority
      -- subinvnetory specifeid while creating the SO.
      IF l_pr_sub IS NULL THEN
	 l_pr_sub := l_repl_to_sub_code_tb(j);
      END IF;

      --Store values in l_repl_to_sub_code_tb and  l_repl_uom_code_tb table
      Get_to_Sub_For_Dynamic_Repl(P_Org_id               => p_org_id,
				  P_Item_id              => l_Item_id_tb(j),
				  P_PRIMARY_DEMAND_QTY   => l_requested_quantity_tb(j),
				  X_TO_SUBINVENTORY_CODE => l_PR_sub,
				  X_REPL_UOM_CODE        => l_repl_uom_code_tb(j));


      l_repl_to_sub_code_tb(j) :=l_pr_sub;

      IF l_repl_to_sub_code_tb(j) IS NOT NULL AND l_repl_uom_code_tb(j) IS NOT NULL THEN
	 -- keep only those records which has to_sub_code

	 l_conversion_rate := get_conversion_rate(l_Item_id_tb(j),
						  l_requested_quantity_uom_tb(j),
						  l_repl_uom_code_tb(j));


	 IF (l_conversion_rate < 0) THEN

	    IF (l_debug = 1) THEN
	       print_debug('Error while obtaining conversion rate');
	       print_debug('Skipping REPL for the delivery detail:'||l_delivery_detail_id_tb(j)  );
	    END IF;
	    -- this records should not be added to the WRDT:
	    -- Must delete this records jth element from the bulk uploaded tables later
	    l_revert_wdd := TRUE;
	    GOTO next_wdd;

	  ELSE

	    -- Store values in l_quantity_in_repl_uom_tb table
	    l_quantity_in_repl_uom_tb(j) := ROUND(l_conversion_rate *
						  l_requested_quantity_tb(j));

	 END IF;

       ELSE
	 --TO_SUB_CODE could not be identified
	 IF (l_debug = 1) THEN
	    print_debug('TO_SUB_CODE could not be identified for delivery_detail');
	    print_debug('Skipping REPL for the delivery detail:'||l_delivery_detail_id_tb(j)  );
	 END IF;
	 -- this records should not be added to the WRDT:
	 -- Must delete this records jth element from the bulk uploaded tables later
	 l_revert_wdd := TRUE;
	 GOTO next_wdd;

      END IF; -- for l_repl_to_sub_code_tb(j) IS NOT NULL

      <<next_wdd>>
	IF (l_revert_wdd) THEN
	   l_revert_wdd := FALSE;
	   -- We can not replenish this line
	   -- Backorder this demand line - Add to the global variable to be
	   -- called AT the END OF the dynamic repl process

	   IF (l_debug = 1) THEN
	      print_debug('Revert wdd' );
	      print_debug('--Backorder this demand line, add to the global variable :'||l_delivery_detail_id_tb(j));
	   END IF;

	   l_bkorder_cnt := g_backorder_deliv_tab.COUNT() + 1;

	   g_backorder_deliv_tab(l_bkorder_cnt):= l_delivery_detail_id_tb(j) ;
	   g_backorder_qty_tab(l_bkorder_cnt) := l_requested_quantity_tb(j);
	   -- since we are backordering entire qty parameters
	   -- p_bo_qtys AND  p_req_qtys will have same value
	   g_dummy_table(l_bkorder_cnt)       := 0;


	   -- this records should not be added to the WRDT:
	   -- Must delete this records jth element from the bulk uploaded tables later
	   IF (l_debug = 1) THEN
	      print_debug('Skipping REPL for the delivery detail:'||l_delivery_detail_id_tb(j)  );
	   END IF;

	   -- Note: these delete in pl/sql table do not reindex
	   -- data. element deleted at J remains NULL. it works sort of
	   -- key-value pair for id and values

	   l_item_id_tb.DELETE(j);
	   l_header_id_tb.DELETE(j);
	   l_line_id_tb.DELETE(j);
	   l_delivery_detail_id_tb.DELETE(j);
	   l_demand_type_id_tb.DELETE(j);
	   l_requested_quantity_tb.DELETE(j);
	   l_requested_quantity_uom_tb.DELETE(j);
	   l_expected_ship_date_tb.DELETE(j);
	   l_repl_status_tb.DELETE(j);
	   l_released_status_tb.DELETE(j);
	   l_repl_to_sub_code_tb.DELETE(j);
	   l_quantity_in_repl_uom_tb.DELETE(j);
	   l_repl_uom_code_tb.DELETE(j);


	   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	      -- if we are unable to revert a WDD, we should
	      -- essentially revery everything back
	      -- as if could not do anything in populating
	      l_item_id_tb.DELETE;
	      l_header_id_tb.DELETE;
	      l_line_id_tb.DELETE;
	      l_delivery_detail_id_tb.DELETE;
	      l_demand_type_id_tb.DELETE;
	      l_requested_quantity_tb.DELETE;
	      l_requested_quantity_uom_tb.DELETE;
	      l_expected_ship_date_tb.DELETE;
	      l_repl_status_tb.DELETE;
	      l_released_status_tb.DELETE;
	      l_repl_to_sub_code_tb.DELETE;
	      l_quantity_in_repl_uom_tb.DELETE;
	      l_repl_uom_code_tb.DELETE;
	      l_return_status := fnd_api.g_ret_sts_error;
	      GOTO end_populate;
	   END IF;
	END IF; -- IF (l_revert_wdd) THEN
   END LOOP; -- FOR j IN 1..l_delivery_detail_id_tb.COUNT LOOP


   -- Bulk upload all eligible demand lines
   -- since some recprds from the l_delivery_detail_id_tb has been deleted,
   -- use 'INDICES OF' instead of table count
     FORALL k IN INDICES OF l_delivery_detail_id_tb
     INSERT INTO WMS_REPL_DEMAND_GTMP
     (Repl_Sequence_id,
      repl_level,
      Inventory_item_id,
      Organization_id,
      demand_header_id,
      demand_line_id,
      demand_line_detail_id,
      demand_type_id,
      quantity_in_repl_uom,
      REPL_UOM_code,
      Quantity,
      Uom_code,
      Expected_ship_date,
      Repl_To_Subinventory_code,
      filter_item_flag,
      repl_status,
      repl_type,
      RELEASED_STATUS)
     VALUES
     (WMS_REPL_DEMAND_GTMP_S.NEXTVAL,
      p_repl_level,
      l_item_id_tb(k),
      p_org_id,
      l_header_id_tb(k),
      l_line_id_tb(k),
      l_delivery_detail_id_tb(k),
      l_demand_type_id_tb(k),
      l_quantity_in_repl_uom_tb(k),
      l_repl_uom_code_tb(k),
      l_requested_quantity_tb(k),
      l_requested_quantity_uom_tb(k),
      l_expected_ship_date_tb(k),
      l_repl_to_sub_code_tb(k),
      NULL,
      l_repl_status_tb(k),
      2,  -- for dynamic replenishment
      l_released_status_tb(k));

   IF (l_debug = 1) THEN
      print_debug('DONE with storing all records in WRDT table');
      print_debug('Now Store consolidated date in the PL/SQL table');
   END IF;


   --=====================TEST CODE STARTS =======
   -- for debugging purpise only, entire code should be inside l_debug = 1
   IF (l_debug = 1) THEN
      SELECT COUNT(1) INTO  l_temp_cnt FROM wms_repl_demand_gtmp;
      print_debug('FINAL record count in gtmp :'||l_temp_cnt);
   END IF;
   --=====================TEST CODE ENDS =======



   -- 3- For replenishment MO creation, all demand line qty will be consolidated/grouped for Item_id and destiniation_sub

   -- Clear tables for bulk operation
   l_item_id_tb.DELETE;
   l_total_demand_qty_tb.DELETE;
   l_date_required_tb.DELETE;
   l_repl_to_sub_code_tb.DELETE;
   l_repl_uom_code_tb.DELETE;

   -- BULK COLLECT  THESE RECORDS
   BEGIN
      OPEN c_item_repl_cur;
      FETCH c_item_repl_cur BULK COLLECT INTO l_item_id_tb,
	l_total_demand_qty_tb,
	l_date_required_tb,l_repl_to_sub_code_tb,l_repl_uom_code_tb;
      CLOSE c_item_repl_cur;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Exception retrieving item repl records for Dynamic');
	 END IF;
	 l_return_status := fnd_api.g_ret_sts_error;
	 GOTO end_populate;
   END;

   --Clear consolidated table
   x_consol_item_repl_tbl.DELETE;

   FOR k IN 1 .. l_item_id_tb.COUNT LOOP
      x_consol_item_repl_tbl(k).Organization_id := p_org_id;
      x_consol_item_repl_tbl(k).Item_id := l_item_id_tb(k);
      x_consol_item_repl_tbl(k).total_demand_qty := l_total_demand_qty_tb(k);
      x_consol_item_repl_tbl(k).date_required := l_date_required_tb(k);

      x_consol_item_repl_tbl(k).available_onhand_qty := 0; --calculated later
      x_consol_item_repl_tbl(k).open_mo_qty := 0; --calculated later
      x_consol_item_repl_tbl(k).final_replenishment_qty := 0; --calculated later

      x_consol_item_repl_tbl(k).repl_to_subinventory_code := l_repl_to_sub_code_tb(k);
      x_consol_item_repl_tbl(k).repl_uom_code := l_repl_uom_code_tb(k);
   END LOOP;

   -- At this point, we do not know whether the demand could not be fulfilled becs of rules restrictions or
   -- material is not available in the entire organization
   -- Check the high level availability (atr) at the org level.and adjust  ALL qty accordingly for all items

   IF l_debug = 1 THEN
      print_debug('Number of consolidated demand records :'||x_consol_item_repl_tbl.COUNT());
   END IF;


   IF x_consol_item_repl_tbl.COUNT() <> 0 THEN

      ADJUST_ATR_FOR_ITEM  (p_repl_level             => p_repl_level
			    , p_repl_type            => g_dynamic_repl
			    , x_consol_item_repl_tbl => x_consol_item_repl_tbl
			    , x_return_status        => l_return_status
			    );

      IF l_debug = 1 THEN
	 print_debug('Return Status after call to ADJUST_ATR_FOR_ITEM :'|| l_return_status);
      END IF;

      IF l_return_status <> FND_API.g_ret_sts_success THEN
	 -- All error out
	 GOTO end_populate;
      END IF;
   END IF;


   <<end_populate>>
     IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	-- Raising excetion so that will call revert of WDD status for all WDDs
	-- in the DYNAMIC_REPLENISHMENT api
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     x_return_status        := FND_API.G_RET_STS_SUCCESS;
     IF l_debug = 1 THEN
	print_debug('DONE WITH API POPULATE_DYNAMIC_REPL_DEMAND');
     END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('Exception in POPULATE_DYNAMIC_REPL_DEMAND: ' || sqlcode || ', ' || sqlerrm);
      END IF;
      ROLLBACK TO populate_dyn_demand_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      x_consol_item_repl_tbl.DELETE;
END POPULATE_DYNAMIC_REPL_DEMAND;



PROCEDURE allocate_repl_move_order(
				   p_Quantity_function_id IN NUMBER,
				   x_return_status             OUT NOCOPY VARCHAR2,
				   x_msg_count                 OUT NOCOPY NUMBER,
				   x_msg_data                  OUT nocopy VARCHAR2
				   )
  IS



     l_debug              NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

     L_LOC_ID NUMBER;

     l_prev_to_sub VARCHAR2(10);
     l_prev_item_id NUMBER;


     L_PICK_UOM_CODE VARCHAR2(3);
     L_FIXED_LOT_MULTIPLE NUMBER;
     L_UNIT_CONV_QTY NUMBER;

     l_rsv_tbl_tmp    inv_reservation_global.mtl_reservation_tbl_type;
     i NUMBER;

     L_CUR_SUB_HAS_CAPACITY BOOLEAN ;
     l_available_capacity NUMBER;
     l_base_uom_code VARCHAR2(3);
     l_return_status VARCHAR2(1);
     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(1000);
     l_trigger_allocation BOOLEAN := FALSE;

     l_quantity_detailed  NUMBER;
     l_quantity_detailed_conv  NUMBER;
     l_num_detail_recs NUMBER;

     l_prim_quantity_detailed NUMBER;
     l_mo_line_id NUMBER;
     l_task_id NUMBER;

     -- We are NOT doing this at the moment: For the available capacity at the destination sub there can be competing replenishment move order lines.
     --  Consume queued and competing repl MO lines in the order of priority of demand lines based on wrd.Demand_Sort_Order
     --  (Since Demand_Sort_Order will alredy give priority orders first
     --  within a release_batch.Since we want to give high priority to earlier pick releases,
     --  the wrd. WRD.Demand_Sort_Order  will take care of this as well as it gets value from a DB sequence.

     CURSOR c_open_repl_mo IS
	select
	  mtrl.organization_id,
	  mtrl.INVENTORY_ITEM_ID,
	  mtrl.FROM_SUBINVENTORY_CODE,
	  mtrl.TO_SUBINVENTORY_CODE,
	  mtrl.quantity mol_qty,
	  Nvl(mtrl.quantity_detailed,0) mol_detailed_qty,
	  Nvl(mtrl.quantity_delivered,0) mol_delivered_qty,
	  mtrl.uom_code,
	  mtrl.header_id,
	  mtrl.line_id
	  FROM mtl_txn_request_lines mtrl,
	  Mtl_txn_request_headers mtrh
	  WHERE  mtrl.header_id = mtrh.header_id
	  And mtrl.organization_id = mtrh.organization_id
	  and mtrl.organization_id in (select organization_id from mtl_parameters where wms_enabled_flag = 'Y')
	  And MTRH.move_order_type = 2
	  and mtrl.line_status in (3,7) -- only approved and pre-approved
	  and (mtrl.quantity - (Nvl(mtrl.quantity_detailed,0) + Nvl(mtrl.quantity_delivered,0)))  > 0
	  and mtrh.transaction_type_id = 64
	  and mtrl.transaction_type_id = 64
	  and mtrl.transaction_source_type_id = 4
	  ORDER BY mtrl.organization_id, mtrl.TO_SUBINVENTORY_CODE, mtrl.line_id, mtrl.INVENTORY_ITEM_ID;

     -- Note we have mtrl.line_Id in the order_by clause to have some predictable consumption of move order behavior in
     -- case of conflicting priority among MO lines.
     --(Note: We could have put a better consumption order of repl move
     --order lines based on assigning the priority number as MIN[priority of associated demand lines].)

     --We need to order by mtrl.INVENTORY_ITEM_ID to process lines more efficiently below

     CURSOR c_locators_in_sub(P_ORGANIZATION_ID NUMBER, p_sub_code VARCHAR2) IS
	SELECT INVENTORY_LOCATION_ID
	  FROM MTL_ITEM_LOCATIONS
	  WHERE SUBINVENTORY_CODE = P_SUB_CODE
	  AND ORGANIZATION_ID = p_organization_id
	  ORDER BY PICKING_ORDER;

     CURSOR c_trigger_parameters(P_ORG_ID NUMBER, p_item_id NUMBER, p_src_sub VARCHAR2, p_dest_sub VARCHAR2) IS
	SELECT MSI.PICK_UOM_CODE, MISI.FIXED_LOT_MULTIPLE
	  from MTL_ITEM_SUB_INVENTORIES  MISI,
	  MTL_SECONDARY_INVENTORIES MSI
	  where MISI.organization_id =  p_org_id
	  AND MISI.SOURCE_SUBINVENTORY = MSI.SECONDARY_INVENTORY_NAME
	  AND MISI.ORGANIZATION_ID = MSI.ORGANIZATION_ID
	  AND nvl(MISI.SOURCE_SUBINVENTORY, '@@@') = NVL(p_src_sub , nvl(MISI.SOURCE_SUBINVENTORY,'@@@'))
	  AND MISI.SECONDARY_INVENTORY = p_dest_sub
	  AND MISI.INVENTORY_ITEM_ID   = p_Item_id
	  and MISI.source_type = 3 --(for Subinventory)
	  AND MISI.source_organization_id =  p_org_id;

     CURSOR c_base_uom(p_txn_uom_code VARCHAR2) IS
	SELECT muom.uom_code
	  FROM  mtl_units_of_measure_tl muom,mtl_units_of_measure_tl muom2
	  WHERE muom2.uom_code = p_txn_uom_code
	  AND muom2.language = userenv('LANG')
	  AND muom.uom_class = muom2.uom_class
	  AND muom.language = userenv('LANG')
	  AND muom.base_uom_flag = 'Y';


    CURSOR c_mmtt_rec IS
      SELECT transaction_temp_id
        FROM mtl_material_transactions_temp
	WHERE move_order_line_id = l_mo_line_id;

BEGIN

   IF l_debug = 1 THEN
      print_debug('API allocate_repl_move_order -  quantity function id :'|| p_quantity_function_id) ;
   END IF;

   --It will keep looking at the locators of the destination subinventories of the queued replenishemt MO and see if any capacity becomes available.

   --If  there is 'Fixed Lot Multiple' value specified for the item-subinventory form for the destination sub,
   --then this value must be used in the decision making to trigger allocation. If the available capacity at
   --destination locator is more than single unit 'Fixed Lot Multiple' qty of the source subinventory on
   --the queued replenishment MO, then trigger the allocation process of the MO based on the priority of the
   --associated demand orders.

   --If  the 'Fixed Lot multiple' value is NOT specified on the item-subinventory form for the tiem and
   --destination sub, then see if the source subinventory is stamped on the item_sub Form.
   --Check if the 'Pick UOM' for the source sub is set in the subinventory Form. Get the unit qty conversion
   --of this pick uom to the primary qty (say l_src_uom_unit_qty).  If l_src_uom_unit_qty
   --is less than the available capacity of the destination sub, then trigger the allocation for the open repl MO.

   --Otherwise
   --IF
   --( 'Fixed Lot Multiple' value is NOT specified on the item-sub form)
   --AND (the source_sub is also NOT specified for the item+destination_sub  OR the pick_uom of the
   --source_sub is not defined on the source sub ) THEN
   --Trigger the allocation anyway.
   --END IF;

   -- Get all destination subinventories from the replenishment move
   --orders that have some qty to be replenished for demands.


   L_CUR_SUB_HAS_CAPACITY := TRUE;

   FOR l_open_repl_mo IN c_open_repl_mo LOOP

      IF l_debug = 1 THEN
	 print_debug('Processing MO Line: '||l_open_repl_mo.line_id ||
		     ' ,with destination sub: '||l_open_repl_mo.to_subinventory_code||
		     ' ,FOR ITEM : '||l_open_repl_mo.inventory_item_id
		     ) ;
      END IF;

      --IF l_available_capacity <= 0 for ALL locations in the current sub,
      --then skip ALL Open move orders in the batch that has destination of the current sub

      IF (NOT l_cur_sub_has_capacity) AND (l_prev_to_sub = l_open_repl_mo.to_subinventory_code) THEN
	 -- Skip to the next open MO
	 IF l_debug = 1 THEN
	    print_debug('DEST SUB HAS NO CAPACITY : SKIPPING allocation of current MO') ;
	 END IF;
	 GOTO next_mo_line;
       ELSE

	 -- Get the available capacity for EACH valid locator in  the l_open_repl_mo.TO_SUBINVENTORY_CODE
	 -- Scan each locator in the sub for capacity
	 L_CUR_SUB_HAS_CAPACITY := FALSE;

	 -- Setting Item information in the Cache
	 IF inv_cache.set_item_rec(l_open_repl_mo.organization_id, l_open_repl_mo.inventory_item_id)  THEN
	    NULL;
	    IF (l_debug = 1) THEN
	       print_debug('Primary UOM for the Item:' ||inv_cache.item_rec.primary_uom_code);
	    END IF;
	 END IF;

	 OPEN c_locators_in_sub(l_open_repl_mo.organization_id, l_open_repl_mo.TO_SUBINVENTORY_CODE);
	 LOOP
	    FETCH c_locators_in_sub INTO L_loc_id;

	    IF l_debug = 1 THEN
	       print_debug('*******Getting capacity for Next LOC :'||L_loc_id) ;
	    END IF;

	    EXIT WHEN c_locators_in_sub%NOTFOUND;

	    IF p_quantity_function_id IS NULL THEN  -- not specified

	       l_available_capacity := 1e125;

	     ELSIF (p_quantity_function_ID = 530003) THEN  -- Unit Capacity Quantity Function

	       -- Call capacity calculation function ONLY for each to_sub change
	       IF (l_prev_to_sub IS NULL OR (l_prev_to_sub  <>  l_open_repl_mo.to_subinventory_code)) THEN
		  IF l_debug = 1 THEN
		     print_debug('CALLING Unit Capacity API FOR AVAILABLE CAPACITY') ;
		  END IF;

		  l_available_capacity := get_available_capacity
		    (
		     p_quantity_function   => p_Quantity_function_id
		     , p_organization_id   => l_open_repl_mo.organization_id
		     , p_subinventory_code => l_open_repl_mo.TO_SUBINVENTORY_CODE
		     , p_locator_id             => l_loc_id
		     , p_inventory_item_id    => NULL
		     , p_unit_volume             => NULL
		     , p_unit_volume_uom_code       => NULL
		     , p_unit_weight              => NULL
		     , p_unit_weight_uom_code       => NULL
		     , p_primary_uom                => NULL
		     , p_transaction_uom            => NULL
		     , p_base_uom                   => NULL
		     , p_transaction_quantity     => NULL        );
	       END IF;

	     ELSE  -- all other kind of quantity function

	       -- Call capacity calculation function for EACH to_sub change OR item change

	       IF (l_prev_to_sub IS NULL OR l_prev_to_sub  <>  l_open_repl_mo.TO_SUBINVENTORY_CODE OR
		   l_prev_item_id IS NULL OR l_prev_item_id <> l_open_repl_mo.INVENTORY_ITEM_ID) THEN
		  IF l_debug = 1 THEN
		     print_debug('CALCULATING AVAILABLE CAPACITY WITH other APIs') ;
		  END IF;

		  OPEN c_base_uom(l_open_repl_mo.uom_code) ;
		  FETCH c_base_uom INTO l_base_uom_code;
		  IF c_base_uom%NOTFOUND THEN
		     GOTO next_mo_line;
		  END IF;
		  CLOSE c_base_uom;

		  l_available_capacity := get_available_capacity
		    (
		     p_quantity_function   => p_Quantity_function_id
		     , p_organization_id   => l_open_repl_mo.organization_id
		     , p_subinventory_code => l_open_repl_mo.TO_SUBINVENTORY_CODE
		     , p_locator_id           => l_loc_id
		     , p_inventory_item_id    => l_open_repl_mo.inventory_item_id
		     , p_unit_volume          => inv_cache.item_rec.unit_volume
		     , p_unit_volume_uom_code    =>inv_cache.item_rec.volume_uom_code
		     , p_unit_weight             =>inv_cache.item_rec.unit_weight
		     , p_unit_weight_uom_code    =>inv_cache.item_rec.weight_uom_code
		     , p_primary_uom             =>inv_cache.item_rec.primary_uom_code
		     , p_transaction_uom         => l_open_repl_mo.uom_code
		     , p_base_uom                => l_base_uom_code
		     , p_transaction_quantity    => (l_open_repl_mo.mol_qty - l_open_repl_mo.mol_detailed_qty -  l_open_repl_mo.mol_delivered_qty));

		ELSE
		  IF (l_debug = 1) THEN
		     print_debug('No data Found and hence no capacity for the Item');
		  END IF;

		  GOTO next_mo_line;
	       END IF; -- FOR l_prev_to_sub  <>  l_open_repl_mo.TO_SUBINVENTORY_CODE
	    END IF; -- all other kind of quantity function

	    --Note: CAPACITY changes after each allocation even if the material has not physically moved to the destination.

	    --So we need to rely on the condition that once L_CUR_SUB_HAS_CAPACITY becomes FALSE for a location,
	    --  there is no chance of it becoming true as the API get_available_capacity() will be
	    --  returning the updated available capacity.

	    IF (l_debug = 1) THEN
	       print_debug('Capacity of current locator: '||l_available_capacity);
	    END IF;

	    IF l_available_capacity > 0 then
	       L_CUR_SUB_HAS_CAPACITY := TRUE;
	       -- DO NOT PUT the :  ELSE L_CUR_SUB_HAS_CAPACITY := FALSE;
	    END IF;

	    -- get the Picking UOM AND  'Fixed Lot Multiple' for l_open_repl_mo.FROM_SUBINVENTORY_CODE,
	    OPEN c_trigger_parameters(l_open_repl_mo.organization_id,
				      l_open_repl_mo.INVENTORY_ITEM_ID,
				      l_open_repl_mo.FROM_SUBINVENTORY_CODE ,l_open_repl_mo.TO_SUBINVENTORY_CODE);
	    LOOP
	       FETCH c_trigger_parameters INTO L_PICK_UOM_CODE, L_FIXED_LOT_MULTIPLE;
	       EXIT WHEN c_trigger_parameters%NOTFOUND;

	       IF (l_debug = 1) THEN
		  print_debug('Trigger parameter value l_fixed_lot_multiple: '||l_fixed_lot_multiple);
		  print_debug('Trigger parameter value L_PICK_UOM_CODE: '||L_PICK_UOM_CODE);
	       END IF;

	       -- NOW DECIDE WHETHER TO TRIGGER ALLOCATION OR NOT
	       -- l_available_capacity and l_fixed_lot_multiple are in primary UOM
	       IF l_fixed_lot_multiple IS NOT NULL THEN
		  IF (l_debug = 1) THEN
		     print_debug('USING Fixed Lot Multiplier for decision making');
		  END IF;
		  IF l_available_capacity > 0 AND l_available_capacity >= l_fixed_lot_multiple THEN
		     l_trigger_allocation := TRUE;
		   ELSE
		     l_trigger_allocation := FALSE;
		  END IF;

		ELSIF l_pick_uom_code IS NOT NULL THEN --see if the source sub pick UOM is valid
		  IF (l_debug = 1) THEN
		     print_debug('USING Src Sub Pick UOM Unit Qty for decision making');
		  END IF;

		  L_UNIT_CONV_QTY :=  ROUND(1* get_conversion_rate(l_open_repl_mo.inventory_item_id,
								   l_pick_uom_code,
								   inv_cache.item_rec.primary_uom_code),
					    g_conversion_precision);

		  IF (l_debug = 1) THEN
		     print_debug(' L_UNIT_CONV_QTY:' ||L_UNIT_CONV_QTY);
		  END IF;

		  IF L_UNIT_CONV_QTY < 0 THEN
		     IF (l_debug = 1) THEN
			print_debug('Error while obtaining L_mo_uom_code conversion rate for demand qty');
		     END IF;
		     l_trigger_allocation := FALSE;
		   ELSE
		     IF l_available_capacity > 0 AND (l_available_capacity >= l_unit_conv_qty) THEN
			l_trigger_allocation := TRUE;
		      ELSE
			l_trigger_allocation := FALSE;
		     END IF;
		  END IF;

		ELSE --Trigger it anyway
		  IF (l_debug = 1) THEN
		     print_debug('Trigger allocation since fixed_lot_multiplier AND src sub unit qty NOT available');
		  END IF;
		  l_trigger_allocation := TRUE;

		  -- in case the 'effective qty' that need to be allocated ON MO
		  -- IS more than the available capacity at the destination
		  -- rule engine will allocate whatever it could
		  -- effective qty = (mtrl.quantity - (Nvl(mtrl.quantity_detailed,0) + Nvl(mtrl.quantity_delivered,0)))
	       END IF;  --for l_fixed_lot_multiple IS NOT null


	       -- Now actually allocate the MO
	       IF (NOT l_trigger_allocation) THEN
		  --Do nothing, get to the next mo line to allocate
		  IF (l_debug = 1) THEN
		     print_debug('Could not meet capacity Criteria in current Sub/Loc');
		     print_debug('Skip to next Loc in the Sub OR Next repl MO Line......');
		  END IF;
		  GOTO next_loc_in_sub;

		ELSE -- allocate the replenishment move order
		  -- Call Allocation API
		  IF (l_debug = 1) THEN
		     print_debug('Available capacity is enough to trigger allocation....');
		  END IF;

		  WMS_Engine_PVT.create_suggestions(
						    p_api_version => 1.0,
						    p_init_msg_list => fnd_api.g_false,
						    p_commit => fnd_api.g_false,
						    p_validation_level => fnd_api.g_valid_level_none,
						    x_return_status => l_return_status,
						    x_msg_count => l_msg_count,
						    x_msg_data => l_msg_data,
						    p_transaction_temp_id => l_open_repl_mo.line_id,
						    p_reservations => l_rsv_tbl_tmp, --NULL value  AS no rsv FOR repl MO
						    p_suggest_serial => fnd_api.g_false,
						    p_plan_tasks => FALSE);


		  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		     IF (l_debug = 1) THEN
			print_debug('Error returned from create_suggestions API: '
				    || l_return_status);
		     END IF;

		     -- If an exception occurs while modifying a database record, rollback the changes
		     -- and raise exception. Should we proceed to next record
		     ROLLBACK TO Current_MOL_SP;
		     RAISE fnd_api.g_exc_error;
		   ELSE

		     IF (l_debug = 1) THEN
			print_debug('Success returned from create_suggestions API');
			print_debug('Now Assign Task Type for all Repl tasks created FOR the MO Line');
		     END IF;
		     l_mo_line_id:=l_open_repl_mo.line_id;

		     OPEN c_mmtt_rec;
		     LOOP
			FETCH c_mmtt_rec INTO l_task_id;
			EXIT WHEN c_mmtt_rec%notfound;

			IF (l_debug = 1) THEN
			   print_debug('Assign Task Type for MMTT_id: '||l_task_id);
			END IF;

			wms_rule_pvt.assigntt(
					      p_api_version                => 1.0
					      , p_task_id                    => l_task_id
					      , x_return_status              => l_return_status
					      , x_msg_count                  => x_msg_count
					      , x_msg_data                   => x_msg_data
					      );

		     END LOOP;
		     CLOSE c_mmtt_rec;

		  END IF;

		  --update the MO line quantity_detailed field or close the MO
                  BEGIN
		     SELECT NVL(SUM(primary_quantity), 0)
		       ,NVL(sum(transaction_quantity),0)
		       ,COUNT(*)
		       INTO l_prim_quantity_detailed
		       ,l_quantity_detailed_conv
		       ,l_num_detail_recs
		       FROM mtl_material_transactions_temp
		       WHERE move_order_line_id = l_open_repl_mo.line_id;

		     IF (l_debug = 1) THEN
			print_debug('primary l_quantity detailed is '|| l_prim_quantity_detailed);
			print_debug('l_num_detail_recs is '|| l_num_detail_recs);
		     END IF;
		  EXCEPTION
		     WHEN NO_DATA_FOUND THEN
			IF (l_debug = 1) THEN
			   print_debug('no detail records found');
			END IF;
			l_quantity_detailed  := 0;
			l_quantity_detailed_conv  := 0;
			l_num_detail_recs := 0;
		  END;


		  --Convert the MOL detailed qty into MOL UOM code qty
		  IF inv_cache.item_rec.primary_uom_code <> l_open_repl_mo.uom_code THEN

		     l_quantity_detailed :=
		       ROUND((l_prim_quantity_detailed* get_conversion_rate(l_open_repl_mo.inventory_item_id,
									    inv_cache.item_rec.primary_uom_code,
									    l_open_repl_mo.UOM_Code )),
			     g_conversion_precision);

		   ELSE
		     l_quantity_detailed := l_prim_quantity_detailed;
		  END IF;

		  IF (l_debug = 1) THEN
		     print_debug('Qty Detailed           :'||l_quantity_detailed );
		     print_debug('MOL Line Qty           :'||l_open_repl_mo.mol_qty);
		     print_debug('MOL Line Qty Delivered :'||l_open_repl_mo.mol_delivered_qty);
		  END IF;

		  -- NOTE: l_quantity_detailed contains all qty of MMTT related TO CURRENT mo line whether in this
		  -- RUN OR ANY previous runs
		  IF  l_quantity_detailed < (l_open_repl_mo.mol_qty - l_open_repl_mo.mol_delivered_qty)  THEN -- partial allocation
		     -- update the quantity detailed correctly
		     UPDATE mtl_txn_request_lines mtrl
		       SET mtrl.quantity_detailed = l_quantity_detailed
		       where line_id = l_open_repl_mo.line_id;

		     IF (l_debug = 1) THEN
			print_debug('Updated the detailed qty on the MO line');
		     END IF;

		   ELSE -- Fully allocated
		     -- it has been completely detailed
		     -- DO NOT Close the MO, otherwise finalize Pick
		     -- Confirm fails WHILE dropping the task
		     UPDATE mtl_txn_request_lines mtrl
		       SET mtrl.quantity_detailed = l_quantity_detailed
		       where line_id = l_open_repl_mo.line_id;

		     IF (l_debug = 1) THEN
			print_debug('MO line completely detailed');
		     END IF;

		  END IF; -- for partial allocation

	       END IF; -- for (NOT l_trigger_allocation)

	    END LOOP; -- get pick_uom_code and fixed_multiple
	    <<next_loc_in_sub>>
	      CLOSE c_trigger_parameters;
	    IF (l_debug = 1) THEN
	       print_debug('Done with the Capacity of current Locator in the Sub');
	    END IF;
	 END LOOP;  -- For each locator in the sub
	 CLOSE c_locators_in_sub;
      END IF; -- for L_CUR_SUB_HAS_CAPACITY

      <<next_mo_line>>

	IF c_trigger_parameters%isopen THEN
	   CLOSE c_trigger_parameters;
	END IF;
	IF c_locators_in_sub%isopen THEN
	   CLOSE c_locators_in_sub;
	END IF;

	l_prev_to_sub  :=  l_open_repl_mo.TO_SUBINVENTORY_CODE;
	l_prev_item_id := l_open_repl_mo.INVENTORY_ITEM_ID;

	IF (l_debug = 1) THEN
	   print_debug('Done Allocating CURRENT MO record ');
	END IF;
   END LOOP; -- For each REPL MO line under consideration


   COMMIT;
   x_return_status        := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('Exception in ALLOCATE_REPL_MOVE_ORDER: ' || sqlcode || ', ' || sqlerrm);
      END IF;
       x_return_status        := FND_API.G_RET_STS_ERROR;
END ALLOCATE_REPL_MOVE_ORDER;


PROCEDURE UPDATE_DELIVERY_DETAIL (
				  p_delivery_detail_id       IN NUMBER,
				  P_PRIMARY_QUANTITY         IN NUMBER,
				  P_SPLIT_DELIVERY_DETAIL_ID IN NUMBER  DEFAULT NULL,
				  p_split_source_line_id     IN NUMBER DEFAULT NULL,
				  x_return_status            OUT    NOCOPY VARCHAR2
				  )

  IS
     l_debug   NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_orig_pri_qty  NUMBER;

     l_source_header_id NUMBER;
     l_source_line_id  NUMBER;
     l_source_line_detail_id  NUMBER;
     l_source_type_id  NUMBER;
     l_demand_header_id  NUMBER;
     l_demand_line_id  NUMBER;
     l_demand_type_id  NUMBER;
     l_primary_uom VARCHAR2(3);
     l_demand_sort_order NUMBER;
     l_item_id NUMBER;
     l_org_id NUMBER;
     L_repl_type NUMBER;
     L_REPL_LEVEL NUMBER;
     l_no_deliv_in_wrd BOOLEAN := FALSE;

BEGIN

   IF l_debug = 1 THEN
      print_debug('P_SPLIT_DELIVERY_DETAIL_ID :'||P_SPLIT_DELIVERY_DETAIL_ID );
      print_debug('p_delivery_detail_id: '|| p_delivery_detail_id);
      print_debug('p_delivery_detail_id: '|| p_split_source_line_id);
      print_debug('p_primary_quantity  :' || p_primary_quantity);
   END IF;

   -- This API will be called by the shipping team to update the qty in wrd
   -- if the demand qty changes in the process
   -- if P_QUANTITY = 0, then WMS will remove those demands from the
   -- replenishment consideration

   IF p_split_delivery_detail_id IS NULL THEN

      IF P_PRIMARY_QUANTITY > 0 THEN
	 --UPDATE THE PRIMARY QTY FOR THE DEMAND

	 UPDATE WMS_REPLENISHMENT_DETAILS
	   SET PRIMARY_QUANTITY = P_PRIMARY_QUANTITY
	   WHERE DEMAND_LINE_DETAIL_ID = p_delivery_detail_id
	   AND primary_quantity >= P_PRIMARY_QUANTITY;

       ELSE

	 -- NEED TO REMOVE THE ENTRY FROM WRD.
	 -- In this case we will have More qty in the replenishment mover
	 -- ORDER that will be consumed BY later processing


	 DELETE FROM WMS_REPLENISHMENT_DETAILS
	   WHERE DEMAND_LINE_DETAIL_ID = P_DELIVERY_DETAIL_ID;

      END IF;



    ELSE -- MEANS DELIVERY IS SPLIT

      --Note: There can be case when this API will be called after
      -- splitting a delivery detail that was NOT originally tracked in the
      -- WRD table to start with

      --  p_delivery_detail_id is tied up with  P_PRIMARY_QUANTITY and
      -- remaining qty go with new delivery detail  p_split_delivery_detail_id
      BEGIN
	 SELECT
	   source_header_id, Source_line_id,
	   Source_line_detail_id,Source_type_id, demand_header_id,
	   demand_line_id,demand_type_id, Primary_UOM, Primary_Quantity,
	   demand_sort_order, inventory_item_id, organization_id
	   , Nvl(repl_level,1), repl_type
	   INTO l_source_header_id,l_Source_line_id,
	   l_Source_line_detail_id, l_Source_type_id,
	   l_demand_header_id,l_demand_line_id, l_demand_type_id,l_Primary_UOM, l_orig_pri_qty, l_demand_sort_order,
	   l_item_id, l_org_id , l_repl_level, l_repl_type
	   FROM WMS_REPLENISHMENT_DETAILS
	   WHERE DEMAND_LINE_DETAIL_ID = p_delivery_detail_id;
      EXCEPTION
	 WHEN no_data_found THEN
	    l_orig_pri_qty := -9999;
	    l_no_deliv_in_wrd := TRUE;
      END;

      -- Insert split delivery details id only if the original delivery
      --  detail id is found IN WRD
      IF (NOT l_no_deliv_in_wrd) AND l_orig_pri_qty <> -9999 AND p_primary_quantity < l_orig_pri_qty THEN

	 -- Update old delivery with decreased qty
	 UPDATE WMS_REPLENISHMENT_DETAILS
	   SET PRIMARY_QUANTITY = P_PRIMARY_QUANTITY
	   WHERE DEMAND_LINE_DETAIL_ID = p_delivery_detail_id;

	 -- Insert a new record in WRD with remaining qty
	 -- Note: Priority of the Split demand Order remain same as the
	 -- original one
	 INSERT INTO WMS_REPLENISHMENT_DETAILS
	   (Replenishment_id,
	    Organization_Id,
	    source_header_id,
	    Source_line_id,
	    Source_line_detail_id,
	    Source_type_id,
	    demand_header_id,
	    demand_line_id,
	    demand_line_detail_id,
	    demand_type_id,
	    Inventory_item_id,
	    Primary_UOM,
	    Primary_Quantity,
	    demand_sort_order,
	    repl_type,
	    repl_level,
	    CREATION_DATE,
	    LAST_UPDATE_DATE,
	    CREATED_BY,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN
	    )VALUES (
		     WMS_REPLENISHMENT_DETAILS_S.NEXTVAL,
		     l_org_id,
		     l_source_header_id,
		     l_source_line_id,
		     l_Source_line_detail_id,
		     l_Source_type_id,
		     l_demand_header_id,
		     Nvl(p_split_source_line_id,l_demand_line_id),
		     p_split_delivery_detail_id,
		     l_demand_type_id,
		     l_item_id,
		     l_Primary_UOM,
		     (l_orig_pri_qty - p_primary_quantity) ,
		     l_demand_sort_order,
		     L_repl_type,
		     l_repl_level,
		     Sysdate,
		     Sysdate,
		     fnd_global.user_id,
		     fnd_global.user_id,
		     fnd_global.user_id);

      END IF; -- FOR  l_orig_pri_qty <> -9999

   END IF; -- MEANS DELIVERY IS SPLIT

   x_return_status        := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN OTHERS THEN
      IF l_debug = 1 THEN
	 print_debug('Exception in update_delivery_detail: ' || sqlcode || ', ' || sqlerrm);
      END IF;
END update_delivery_detail;


END wms_replenishment_pvt;

/
