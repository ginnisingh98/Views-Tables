--------------------------------------------------------
--  DDL for Package Body WSH_USA_ACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_USA_ACTIONS_PVT" as
/* $Header: WSHUSAAB.pls 120.21.12010000.14 2010/09/15 05:23:21 brana ship $ */

-- Start of body implementations


--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_USA_ACTIONS_PVT';
--
PROCEDURE Import_Records(
  p_source_code            IN            VARCHAR2,
  p_changed_attributes     IN            WSH_INTERFACE.ChangedAttributeTabType,
  x_return_status          OUT NOCOPY            VARCHAR2)
IS
  l_counter NUMBER;
  l_rs      VARCHAR2(1);
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'IMPORT_RECORDS';
  --
  l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
  l_organization_tab WSH_UTIL_CORE.id_tab_type; --Pick To POD WF Project
  l_wf_rs              VARCHAR2(1);  --Pick To POD WF Project
  l_dbi_rs              VARCHAR2(1);       -- DBI Project

BEGIN
   --
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
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
   END IF;
   l_rs := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  <<records_loop>>
  FOR l_counter IN p_changed_attributes.FIRST .. p_changed_attributes.LAST LOOP
    IF p_changed_attributes(l_counter).action_flag = 'I' THEN
      Import_Delivery_Details(
            p_source_line_id  => p_changed_attributes(l_counter).source_line_id,
            p_source_code     => p_source_code,
            x_return_status   => l_rs);
      IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
         EXIT records_loop;
      END IF;

      IF (NVL(p_changed_attributes(l_counter).released_status,'@') <> FND_API.G_MISS_CHAR) THEN

         -- pickable lines should have status updated to 'R'.
         -- non-pickable (non-reservable) lines should have status updated to 'X'.
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'source_line_id',p_changed_attributes(l_counter).source_line_id);
         END IF;
         UPDATE WSH_DELIVERY_DETAILS
         SET  released_status = decode(pickable_flag, 'Y','R', 'X')
         WHERE source_line_id = p_changed_attributes(l_counter).source_line_id
         AND   source_code    = p_source_code
         RETURNING delivery_detail_id, organization_id BULK COLLECT INTO l_detail_tab, l_organization_tab;
	            -- Added for DBI Project
		    --Organization_id added for Pick to Pod Workflow

	--Raise Event: Pick To Pod Workflow
	FOR i in l_detail_tab.first .. l_detail_tab.last
	LOOP
		IF (l_detail_tab.exists(i)) THEN
			  WSH_WF_STD.Raise_Event(
									p_entity_type => 'LINE',
									p_entity_id => l_detail_tab(i) ,
									p_event => 'oracle.apps.wsh.line.gen.readytorelease' ,
									--p_parameters IN wf_parameter_list_t DEFAULT NULL,
									p_organization_id => l_organization_tab(i),
									x_return_status => l_wf_rs ) ;
			 IF l_debug_on THEN
			     WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
			     WSH_DEBUG_SV.log(l_module_name,'Delivery Detail Id is  ',l_detail_tab(i) );
			     wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
			 END IF;
		END IF;
	END LOOP;
	--Done Raise Event: Pick To Pod Workflow
        --
        -- DBI Project
        -- Update of wsh_delivery_details where requested_quantity/released_status
        -- are changed, call DBI API after the update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count',l_detail_tab.count);
        END IF;
        WSH_INTEGRATION.DBI_Update_Detail_Log
         (p_delivery_detail_id_tab => l_detail_tab,
          p_dml_type               => 'UPDATE',
          x_return_status          => l_dbi_rs);

        IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_dbi_rs;
          -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
        END IF;
      END IF;

    END IF;


  END LOOP; -- l_counter IN p_changed_attributes.FIRST .. p_changed_attributes.LAST

  x_return_status := l_rs;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_USA_ACTIONS_PVT.Import_Records',l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Import_Records;

--
--  Procedure :  sort_splits
--  Parameters:  p_index_tab         IN OUT  table of indexes of the input parameter p_split_table
--               p_split_table       IN OUT table of records passed by OM for splitting.
--               x_return_status     OUT return status
--
--  Description:
--               Sorts the p_split_table the the following order :
--                        original_source_line_id    asc
--                        source_line_id             desc
--                        date_requested             desc
--

PROCEDURE sort_splits ( p_index_tab IN OUT NOCOPY WSH_UTIL_CORE.id_tab_type ,
      p_split_table IN OUT NOCOPY split_Table_tab_type,
      x_return_status OUT NOCOPY  VARCHAR2 )
IS
l_tmp NUMBER ;
l_tmp_date  DATE  ;
l_split_table      split_Table_tab_type ;
l_tmp_split_table  split_Table_type ;
l_exchange         BOOLEAN ;
l_sorted           BOOLEAN ;
l_total_splits     NUMBER ;


l_debug_on BOOLEAN;
  --
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'sort_splits';

l_ref  NUMBER ;
l_cmp  NUMBER ;

BEGIN
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   -- add the original line also in the l_split_table
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Inside sort splits ' );
  END IF;

   FOR i in 1..p_split_table.count
   LOOP
       l_split_table(i).source_line_id  := p_split_table(i).source_line_id  ;
       l_split_table(i).original_source_line_id  := p_split_table(i).original_source_line_id  ;
       l_split_table(i).date_requested   := p_split_table(i).date_requested   ;
       l_split_table(i).changed_Attributes_index  := p_split_table(i).changed_Attributes_index  ;
       p_index_tab(i) := i ;
   END LOOP;

  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Assigned l_split_table');
  END IF;

   l_ref := 1 ;
   l_exchange := TRUE ;
   l_sorted   := FALSE ;

   WHILE  not l_sorted
   LOOP
   l_sorted := TRUE ;

   -- for loop ignores last 2 lines because
   -- a. Since we are comparing the current line with the NEXT line , the current line cannot be the
   --    last line  and
   -- b. the last line is the reference line for schedule_date so does not have to be used for comparision
   --    for sorting.

   FOR l_ref in 1..l_split_table.count - 2
   LOOP
       l_exchange := FALSE ;
             l_cmp  := l_ref + 1 ;

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,l_split_table(l_cmp ).original_source_line_id || ' : ' || l_split_table(l_ref).original_source_line_id  );
          WSH_DEBUG_SV.logmsg(l_module_name,l_split_table(l_cmp ).source_line_id || ' : ' || l_split_table(l_ref).source_line_id  );
          WSH_DEBUG_SV.logmsg(l_module_name,l_split_table(l_cmp ).date_requested || ' : ' || l_split_table(l_ref).date_requested  );
       END IF;

       IF l_split_table(l_cmp ).original_source_line_id > l_split_table(l_ref).original_source_line_id
       THEN
         l_exchange := TRUE ;
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'exchang = TRUE 1 ' );
                  END IF;
             ELSIF l_split_table(l_cmp ).original_source_line_id  = l_split_table(l_ref).original_source_line_id
            and   nvl( l_split_table(l_cmp ).date_requested , SYSDATE ) < NVL ( l_split_table(l_ref).date_requested , SYSDATE )
       THEN
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'exchang = TRUE 2 ' );
                 END IF;

           l_exchange := TRUE ;
             ELSIF  l_split_table(l_cmp ).original_source_line_id  = l_split_table(l_ref).original_source_line_id
            and nvl(  l_split_table(l_cmp ).date_requested, SYSDATE) = nvl( l_split_table(l_ref).date_requested  , SYSDATE )
            and  l_split_table(l_cmp ).source_line_id  < l_split_table(l_ref).source_line_id
       THEN
           l_exchange := TRUE ;
       END IF ;

              IF l_exchange then
           l_sorted := FALSE ;
     -- IS the p_index_Tab required if the changedattrib index is already
     -- stored in p_split_Tab ?!! - splitrsv
           l_tmp := p_index_tab(l_ref) ;
           p_index_tab(l_ref) := p_index_tab(l_cmp );
           p_index_Tab(l_cmp ) := l_tmp ;

           l_tmp_split_Table := l_split_table(l_ref);
           l_split_Table(l_ref) := l_split_Table(l_cmp );
           l_split_Table(l_cmp ) := l_tmp_split_Table ;

       END IF ;

         END LOOP ;

   END LOOP ;

   -- update  directions with 'F' till you see original line . after that update direction to 'L'
   -- for every new orginal_source_line_id you encounter reset to 'F' .

   l_total_splits := l_split_table.count-1 ;

      FOR i in 1..l_total_splits --{
      LOOP
         IF  l_split_table(i).date_requested  is not null  AND
             l_split_Table(l_total_splits + 1 ).date_requested is not null AND
       l_split_table(i).date_requested > l_split_Table(l_total_splits + 1 ).date_requested then
       l_split_table(i).direction_flag := 'F' ;
         ELSE
       l_split_table(i).direction_flag := 'L' ;
         END IF ;
         p_split_table(i) := l_split_table(i);
      END LOOP; --}


   EXCEPTION
   WHEN OTHERS THEN
       x_return_status  := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Exception in sort_splits' );
         WSH_DEBUG_SV.logmsg(l_module_name, SQLERRM || ' : ' || SQLCODE  );
       END IF;

END sort_splits ;
--
--  Procedure :  split_records_int ( internal API )
--  Parameters:  p_source_code              IN   source_code
--               p_changed_attributes       IN   table of records passed by OM for changing.
--               p_interface_flag           IN   is the record interfaced to OM ?
--               p_index_tab                IN   table of indexes pointing to p_changed_attributes
--               p_split_lines              IN   table of records of lines that are to be split.
--               x_return_status            OUT  return status
--
--  Description:
--               Sorts the p_split_table the the following order :
--                        original_source_line_id    asc
--                        source_line_id             desc
--                        date_requested             desc
--

PROCEDURE Split_Records_Int (
  p_source_code            IN            VARCHAR2,
  p_changed_attributes     IN            WSH_INTERFACE.ChangedAttributeTabType,
  p_interface_flag         IN            VARCHAR2,
  p_index_tab              IN            WSH_UTIL_CORE.ID_Tab_Type ,
  p_split_lines            IN            WSH_USA_ACTIONS_PVT.split_Table_Tab_type ,
  x_return_status          OUT  NOCOPY   VARCHAR2
) IS

  -- cursor to calculate the total requested quantity for the original source_line_id .

-- HW OPMCONV -Retrieve Qty2
  CURSOR c_total_requested_quantity (p_source_line_id NUMBER)
  IS
  SELECT inventory_item_id , requested_quantity_uom  ,sum ( requested_quantity ),
         sum ( NVL(requested_quantity2,0) ),organization_id --bugfix 8780998
  from wsh_delivery_details
  where source_line_id = p_source_line_id
  and source_code = 'OE'
  group by inventory_item_id , requested_quantity_uom,organization_id;

  -- This cursor is the same for both normal and OM Process
  -- We assume that the caller will have screened source lines
  -- for delivery lines that are shipped or in confirmed deliveries.
  CURSOR c_details(x_source_code             VARCHAR2,
                   x_original_source_line_id NUMBER,
                   x_interface_flag          VARCHAR2,
                   x_shipped_flag            VARCHAR2) IS
    SELECT wdd.delivery_detail_id,
           wdd.requested_quantity,
           wdd.picked_quantity,
           wdd.shipped_quantity,
           wdd.cycle_count_quantity,
           wdd.requested_quantity_uom,
           wdd.requested_quantity2,
           wdd.picked_quantity2,
           wdd.shipped_quantity2,
           wdd.cycle_count_quantity2,
           wdd.requested_quantity_uom2,
           wdd.released_status,
           wdd.move_order_line_id,
           wdd.organization_id,
           wdd.inventory_item_id,
           wdd.revision,
           wdd.subinventory,
           wdd.lot_number,
-- HW OPMCONV - No need for sublot_number
--         wdd.sublot_number,
           wdd.locator_id,
           wdd.source_line_id,
           wdd.source_code,
           wdd.source_header_id,
           wdd.net_weight,
           wdd.cancelled_quantity,
           wdd.cancelled_quantity2,
           wdd.serial_number,
           wdd.to_serial_number,
           wdd.transaction_temp_id,
           wdd.pickable_flag,
           wdd.ato_line_id,
           wdd.container_flag,
           NVL(wdd.inv_interfaced_flag, 'N') inv_interfaced_flag,
           wdd.source_line_set_id,  -- anxsharm Bug 2181132
           wda.delivery_id,
           wda.parent_delivery_detail_id ,
           wdd1.lpn_id,              -- Bug 2773605 : Need to fetch the parent's lpn_id also.
           -- J: W/V Changes
           wdd.gross_weight,
           wdd.volume,
           wdd.weight_uom_code,
           wdd.volume_uom_code,
           wdd.wv_frozen_flag,
           -- End W/V Changes
           wdd.source_header_number,-- ECO 4524041, add field to display in message
           -- K: MDC
           wda.parent_delivery_id,
           NVL(wda.type, 'S') wda_type,
           -- END K: MDC
	   wdd.replenishment_status  -- bug# 6719369 (replenishment project)
    FROM wsh_delivery_details     wdd,
         wsh_delivery_assignments wda,
         wsh_delivery_details     wdd1 -- Bug 2773605: Added to fetch parent's lpn_id
    WHERE wdd.source_code = x_source_code
    AND   wdd.source_line_id = x_original_source_line_id
    AND   wdd.container_flag = 'N'
    AND   wdd.released_status <> 'D'
    AND   (
              (    x_interface_flag = 'N'
              )
           OR
              (    x_interface_flag = 'Y'
               AND (
                       (x_shipped_flag = 'Y' AND wdd.oe_interfaced_flag = 'P')
                    OR (x_shipped_flag = 'N' AND NVL(wdd.oe_interfaced_flag, 'N')  = 'N')
                   )
              )
          )
    AND  wda.delivery_detail_id = wdd.delivery_detail_id
    AND  NVL(wda.type, 'S') in ('S', 'C')
    AND  wda.parent_Delivery_Detail_id = wdd1.delivery_Detail_id(+)
    ORDER BY DECODE(wdd.released_status,
                    'C', 1,
                    'Y', 2,
                    'R', 3,
                    'N', 4,
                    'B', 5,
                    'X', 6,
                    7), -- 'S': save "released to warehouse" for last
             wdd.REQUESTED_QUANTITY DESC;

  -- bug 3364238
  CURSOR c_req_qty(x_source_code             VARCHAR2,
                   x_original_source_line_id NUMBER
                   ) IS
  SELECT sum(nvl(wdd.requested_quantity, 0))
    FROM wsh_delivery_details     wdd,
         wsh_delivery_assignments_v wda,
         wsh_delivery_details     wdd1
    WHERE wdd.source_code = x_source_code
    AND   wdd.source_line_id = x_original_source_line_id
    AND   wdd.container_flag = 'N'
    AND   wdd.released_status <> 'D'
    AND   NVL(wdd.oe_interfaced_flag, 'N')  = 'N'
    AND   wda.delivery_detail_id = wdd.delivery_detail_id
    AND   wda.parent_Delivery_Detail_id = wdd1.delivery_Detail_id(+);

  l_detail_inv_rec    WSH_USA_INV_PVT.DeliveryDetailInvRecType;
  l_detail_info       WSH_DELIVERY_DETAILS_ACTIONS.SplitDetailRecType;

  l_cancel_Reservation_Tab_Type  WSH_USA_ACTIONS_PVT.Cancel_Reservation_Tab_Type; --bugfix 8915868
  l_cancel_counter   NUMBER :=0 ; --bugfix 8915868

  l_uom_converted     BOOLEAN;
  l_counter           NUMBER;
  l_rs                VARCHAR2(1);
  l_quantity_to_split NUMBER;
  l_quantity_to_split2 NUMBER;  -- AG
  l_quantity_split    NUMBER;
  l_quantity_split2    NUMBER;   --  AG
  l_working_detail_id NUMBER;
  l_reservable        VARCHAR2(1);

--wrudge
  -- bug 2121426: keep track of reservation quantity to transfer
  l_res_qty_to_transfer  NUMBER;
  l_res_qty2_to_transfer NUMBER;

  l_ato_split BOOLEAN;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
-- HW OPM for OM changes
l_prev_org_id          NUMBER := NULL;
-- HW OPMCONV. Removed OPM variables

-- HW OPMCONV - Added two new variables
l_detailed_qty   NUMBER;
l_detailed_qty2  NUMBER;
  l_prev_source_line_id NUMBER;

l_delete_dds      WSH_UTIL_CORE.Id_Tab_Type ; -- to delete delivery lines pending overpick

l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs       VARCHAR2(1);              -- DBI Project


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SPLIT_RECORDS_Int';
--
-- Bug 2540015: Added l_move_order_line_status
l_move_order_line_status VARCHAR2(20);  -- bug # 9410461 : increased the size.
l_trnfer_reservations    VARCHAR2(1);   -- bug # 9410461

-- Variables added for bug 2919848.
 l_quantity_to_keep  NUMBER;
 l_total_res_qty_to_transfer NUMBER;
-- HW OPMCONV - Added Qty2
 l_total_res_qty2_to_transfer NUMBER;
 l_found     BOOLEAN;

 l_total_spare_rsv             NUMBER ;
-- HW OPMCONV - Added Qty2
 l_total_spare_rsv2             NUMBER ;
 l_total_rsv_to_split          WSH_UTIL_CORE.id_Tab_type ;
-- HW OPMCONV - Added Qty2
 l_total_rsv_to_split2          WSH_UTIL_CORE.id_Tab_type ;

 l_inventory_item_id            NUMBER;
 l_organization_id              NUMBER;
 l_last_orig_line_id            NUMBER;

 l_pickable_flag                VARCHAR2(1);

 l_sdd_tab         WSH_UTIL_CORE.Id_Tab_Type ; -- to store delivery details marked as 'R'
 l_total_reserved_quantity  NUMBER ;
-- HW OPMCONV - Added Qty2
l_total_reserved_quantity2  NUMBER ;
 l_total_requested_quantity NUMBER ;
-- HW OPMCONV - Added Qty2
 l_total_requested_quantity2 NUMBER ;
 l_total_unstaged_quantity  NUMBER ;
 l_max_rsv_to_split         NUMBER ;
-- HW OPMCONV - Added Qty2
 l_max_rsv_to_split2         NUMBER ;
 l_requested_quantity_uom   VARCHAR2(3);
 l_direction_flag VARCHAR2(1);
-- End of variables added for bug 2919848
/*Bug#8373924*/
l_line_ordered_quantinty2 NUMBER;
 cursor ordered_quantity2(l_source_line_id NUMBER) IS
 select ordered_quantity2
            from oe_order_lines
            where line_id = l_source_line_id;
BEGIN
  --
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
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_INTERFACE_FLAG',P_INTERFACE_FLAG);
  END IF;
  --
  l_rs := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  SAVEPOINT before_splits;

  l_total_requested_quantity := 0 ;
-- HW OPMCONV - Added Qty2
 l_total_requested_quantity2 :=0;
  l_last_orig_line_id        := 0 ;

  l_prev_source_line_id := 0;

  <<records_loop>>
  FOR i  IN 1..p_split_lines.count-1 LOOP

    l_counter := p_split_lines(i).changed_attributes_index ;

    IF p_changed_attributes(l_counter).action_flag = 'S' THEN

      IF p_interface_flag = 'Y' THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'original_source_line_id',p_changed_attributes(l_counter).original_source_line_id);
            WSH_DEBUG_SV.log(l_module_name,'source_line_id',p_changed_attributes(l_counter).source_line_id);
            WSH_DEBUG_SV.log(l_module_name,'source_line_set_id',p_changed_attributes(l_counter).source_line_set_id);
            WSH_DEBUG_SV.log(l_module_name,'shipped_flag',p_changed_attributes(l_counter).shipped_flag);
            WSH_DEBUG_SV.log(l_module_name,'ordered_quantity',p_changed_attributes(l_counter).ordered_quantity);
         END IF;
      END IF;

      l_uom_converted      := FALSE;
      l_ato_split          := FALSE;

      l_last_orig_line_id :=  p_changed_attributes(l_counter).original_source_line_id ;

      <<details_loop>>
       FOR c IN c_details(p_source_code,
                         p_changed_attributes(l_counter).original_source_line_id,
                         p_interface_flag,
                         p_changed_attributes(l_counter).shipped_flag)
        LOOP

          l_trnfer_reservations := NULL; -- bug # 9410461: initializing the flag value to NULL.
          --ECO 4524041
          --Do not allow split for Released to Warehouse lines which have been
          --progressed from Planned for Crossdocking status
          IF c.released_status = 'S' AND c.move_order_line_id IS NOT NULL THEN
          --{
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Checking Released to Warehouse line,MOL is--',c.move_order_line_id) ;
            END IF;
            -- Keeping the function call separate to avoid extra overhead of calling
            -- a function for each check, it will be called only when above is
            -- satisfied
            IF wsh_usa_inv_pvt.is_mo_type_putaway (c.move_order_line_id) = 'Y' THEN
            --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'DO NOT ALLOW SPLIT FOR PUTAWAY MOL,---',c.move_order_line_id) ;
                WSH_DEBUG_SV.log(l_module_name,'ORDER NUMBER---',c.source_header_number) ;
              END IF;
              --Split API is called for a source line and if any of the details is
              --in Rel. to warehouse status as described above, the flow needs to
              --stop
              FND_MESSAGE.SET_NAME('WSH', 'WSH_SPLIT_NOT_ALLOWED');
              FND_MESSAGE.SET_TOKEN('ORDER', c.source_header_number);
              WSH_UTIL_CORE.add_message(l_rs,l_module_name);
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              ROLLBACK to before_splits;
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'RAISE ERROR AS SPLIT IS NOT ALLOWED');
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              RETURN;
            END IF;--}
          END IF;--}
          --End of ECO 4524041

          -- bug 2662327: overship tolerance fix to update line_set_id for all delivery lines if it is populated
          -- assumption: line_set_id will be populated only when OM splits order line.
          IF (p_changed_attributes(l_counter).source_line_set_id <> FND_API.G_MISS_NUM)
             AND (   (c.source_line_set_id IS NULL)
                  OR (p_changed_attributes(l_counter).source_line_set_id <> c.source_line_set_id))
             AND (l_prev_source_line_id <> p_changed_attributes(l_counter).original_source_line_id)  THEN
             UPDATE WSH_DELIVERY_DETAILS
             SET  source_line_set_id  = p_changed_attributes(l_counter).source_line_set_id,
                 last_update_date  = SYSDATE,
                 last_updated_by   = FND_GLOBAL.USER_ID,
                 last_update_login = FND_GLOBAL.LOGIN_ID
             WHERE  source_line_id = p_changed_attributes(l_counter).original_source_line_id
             AND    source_code    = p_source_code
             AND    container_flag = 'N'
             AND    released_status <> 'D';
             l_prev_source_line_id := p_changed_attributes(l_counter).original_source_line_id;
          END IF;

          IF (l_prev_org_id IS NULL)
             OR (l_prev_org_id <> c.organization_id)  THEN -- cache process org call
             l_prev_org_id := c.organization_id;
-- HW OPM for OM changes
             --
-- HW OPMCONV. Removed checking for process org

          END IF; -- cache process org call

          IF NOT l_uom_converted THEN
             l_uom_converted := TRUE;
-- HW OPM for OM changes- Need to branch
-- HW OPMCONV. Removed forking

                -- bug 3364238 : During OM interface, for non-model lines, we have to transfer all the pending delivery
                --               details to new order line irrespective of whatever quantity OM passes. If we rely on
                --               OM quantity there could be some precision loss and we may have orphan pending details
                --               still attached to original order line.
                IF ((p_interface_flag = 'Y') AND
                   ((p_changed_attributes(l_counter).top_model_line_id = FND_API.G_MISS_NUM) OR
                   (p_changed_attributes(l_counter).top_model_line_id IS NULL)))
                   THEN
                   OPEN  c_req_qty(p_source_code,
                                   p_changed_attributes(l_counter).original_source_line_id);
                   FETCH c_req_qty INTO l_quantity_to_split;
                   IF c_req_qty%NOTFOUND THEN
                      IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name,'c_req_qty notfound for line', p_changed_attributes(l_counter).original_source_line_id);
                      END IF;
                      CLOSE c_req_qty;
                   END IF;
                   CLOSE c_req_qty;
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'Inside If l_quantity_to_split', l_quantity_to_split);
                   END IF;
                ELSE
                   l_quantity_to_split := WSH_WV_UTILS.Convert_UOM(
                     from_uom => p_changed_attributes(l_counter).order_quantity_uom,
                     to_uom   => c.requested_quantity_uom,
                     quantity => p_changed_attributes(l_counter).ordered_quantity,
                     item_id  => c.inventory_item_id);
                END IF;

-- HW OPMCONV - Moved the following from top + removed forking
               IF ( p_changed_attributes(l_counter).ordered_quantity2 is NOT NULL) THEN
                    l_quantity_to_split2 := p_changed_attributes(l_counter).ordered_quantity2;
               END IF;
               IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'Inside If l_quantity_to_split2', l_quantity_to_split2);
                   END IF;
              IF p_changed_attributes(l_counter).ordered_quantity > 0
                 AND l_quantity_to_split <= 0 THEN
                 l_rs := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_CANNOT_SPLIT');
                 WSH_UTIL_CORE.add_message(l_rs,l_module_name);
                 EXIT records_loop;
              END IF;
           END IF; -- NOT l_uom_converted

           -- delete delivery details pending overpick
           IF (c.requested_quantity = 0 AND c.released_status = 'S') THEN
              l_delete_dds( l_delete_dds.count+1 ) := c.delivery_detail_id;
              GOTO split_next_record;
           END IF;

--wrudge
           -- bug 2121426/2129298: transfer reservations only if delivery line is
           -- transferred to or split for the new order line.
           -- Resetting them to NULL will let us know if we need to transfer.
           l_res_qty_to_transfer := NULL;
           l_res_qty2_to_transfer := NULL;

--wrudge
           -- Bug 2129298: if requested_quantity = 0 and quantity_to_split = 0,
           -- we should transfer this delivery line to the new order line (since 0=0).
           -- if requested_quantity = 0, line is overpicked.

           l_move_order_line_status := 'TRANSFER';
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Processing Delivery Detail ',c.delivery_detail_id);
           END IF;

           IF c.requested_quantity <= l_quantity_to_split THEN
              -- assign the entire delivery line to new source_line_id
              l_working_detail_id := c.delivery_detail_id;
              l_quantity_split    := c.requested_quantity;
              l_quantity_split2   := c.requested_quantity2;
              --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'c.requested_quantity',c.requested_quantity);
                 WSH_DEBUG_SV.log(l_module_name,'l_quantity_to_split',l_quantity_to_split);
-- HW OPMCONV - Print Qty2
                 WSH_DEBUG_SV.log(l_module_name,'c.requested_quantity2',c.requested_quantity2);
                 WSH_DEBUG_SV.log(l_module_name,'l_quantity_split2',l_quantity_split2);
              END IF;
              --
              UPDATE WSH_DELIVERY_DETAILS
              SET    source_line_id    = p_changed_attributes(l_counter).source_line_id,
                     last_update_date  = SYSDATE,
                     last_updated_by   = FND_GLOBAL.USER_ID,
                     last_update_login = FND_GLOBAL.LOGIN_ID
              WHERE  delivery_detail_id = c.delivery_detail_id;

--wrudge
              -- bug 2121426: keep track of reservation quantity to transfer
              -- Since we transfer the full delivery line to the new order line,
              -- we should move all of its reservations picked or requested.
              -- This also takes care of transferring overpicked reservations
              -- when requested quantity = 0 which is always <= quantity to split.
              l_res_qty_to_transfer  := NVL(c.picked_quantity,  c.requested_quantity);
              l_res_qty2_to_transfer := NVL(c.picked_quantity2, c.requested_quantity2);

--wrudge
              -- Bug 2540015
              IF (c.released_status = 'S') THEN
                 IF (p_interface_flag = 'Y') THEN
                    IF ((p_changed_attributes(l_counter).top_model_line_id = FND_API.G_MISS_NUM) OR
                       (p_changed_attributes(l_counter).top_model_line_id IS NULL)) OR
		  -- the following condition added for bug 3858111(front port of bug 3808946)
		  (    p_changed_attributes(l_counter).top_model_line_id <> FND_API.G_MISS_NUM
		   AND p_changed_attributes(l_counter).top_model_line_id IS NOT NULL
		   AND p_changed_attributes(l_counter).top_model_line_id = p_changed_attributes(l_counter).ato_line_id )
                       THEN
                       IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'Transferring the MO line');
                       END IF;
                       l_move_order_line_status := 'TRANSFER';
                       -- Bug 2939884/2919186
                       -- If the line is in status 'S' we transfer
                       -- the detailed quantity of the move order line
                       -- or the quantity in the delivery detail, which ever is
                       -- greater.
                       IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_USA_INV_PVT.get_detailed_quantity');
                          WSH_DEBUG_SV.log(l_module_name,'move_order',c.move_order_line_id);
                       END IF;

                       -- Bug3143426 (included branch for l_res_qty_to_transfer calculation)
 -- HW OPMCONV. Removed forking and Call get_detailed_quantity as a procedure
                       -- anxsharm, X-dock changes
                       --{
                       IF c.move_order_line_id IS NOT NULL THEN
                         WSH_USA_INV_PVT.get_detailed_quantity (
                           p_mo_line_id      => c.move_order_line_id,
                           x_detailed_qty    => l_detailed_qty,
                           x_detailed_qty2   => l_detailed_qty2,
                           x_return_status   => x_return_status);

                         IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                           IF l_debug_on THEN
                             WSH_DEBUG_SV.log(l_module_name,'get_detailed_quantity returned error');
                             EXIT records_loop;
                           END IF;
                         END IF;
                       ELSE
                         l_detailed_qty := c.requested_quantity;
                         l_detailed_qty2 := c.requested_quantity2;
                       END IF;  -- if c.move_order_line_id IS NOT NULL
                       --}
                       -- anxsharm, end of X-dock changes

-- HW OPMCONV - Change values and capture Qty2
                            l_res_qty_to_transfer := GREATEST(l_res_qty_to_transfer,  l_detailed_qty);
                            l_res_qty2_to_transfer := GREATEST(l_res_qty2_to_transfer, l_detailed_qty2);

--                     END IF;

                    ELSE
                       -- Cancel the move order line for models always.
                       -- Reason: Otherwise we have to match the detailed quantities of MO lines with that of
                       --         Reservations in case of REMNANT models
                       IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'The line belongs to model (not ATO) and DD status is S. Transfer Move order line');
                       END IF;
                       -- bug # 9410461: Changed value from 'CANCEL' to 'PTOTRANSFER'. It prevents the cancelling of move order lines
                       --                 associated to PTO components. Code has been added in the API WSH_USA_INV_PVT.Split_Reservation
                       --                 for the value 'PTOTRANSFER'.
                       l_move_order_line_status := 'PTOTRANSFER';
                    END IF;
                 ELSE
                    l_move_order_line_status := 'CANCEL';
                 END IF;
              END IF;
           -- Bug 2540015
           ELSIF l_quantity_to_split > 0 THEN
              -- Bug 2129298: since requested_quantity > quantity_to_split > 0,
              --  we can split the delivery line.
              --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'IN ELSIF IN SPLIT_RECORDS_Int'  );
              END IF;
              --
              l_quantity_split := l_quantity_to_split;
              l_quantity_split2 := l_quantity_to_split2;

              l_detail_info.delivery_detail_id      := c.delivery_detail_id;
              l_detail_info.requested_quantity      := c.requested_quantity;
              l_detail_info.picked_quantity         := c.picked_quantity;
              l_detail_info.shipped_quantity        := c.shipped_quantity;
              l_detail_info.cycle_count_quantity    := c.cycle_count_quantity;
              l_detail_info.requested_quantity_uom  := c.requested_quantity_uom;

              l_detail_info.requested_quantity2     := c.requested_quantity2;
              l_detail_info.picked_quantity2        := c.picked_quantity2;
              l_detail_info.shipped_quantity2       := c.shipped_quantity2;
              l_detail_info.cycle_count_quantity2   := c.cycle_count_quantity2;
              l_detail_info.requested_quantity_uom2 := c.requested_quantity_uom2;

              l_detail_info.organization_id         := c.organization_id;
              l_detail_info.inventory_item_id       := c.inventory_item_id;
              l_detail_info.subinventory            := c.subinventory;
              l_detail_info.lot_number              := c.lot_number;
-- HW OPMCONV - No need for sublot_number
--            l_detail_info.sublot_number           := c.sublot_number;
              l_detail_info.locator_id              := c.locator_id;
              l_detail_info.source_line_id          := c.source_line_id;
              l_detail_info.net_weight              := c.net_weight;
              l_detail_info.cancelled_quantity      := c.cancelled_quantity;
              l_detail_info.cancelled_quantity2     := c.cancelled_quantity2;
              l_detail_info.serial_number           := c.serial_number;
              l_detail_info.to_serial_number        := c.to_serial_number;
              l_detail_info.transaction_temp_id     := c.transaction_temp_id;

              l_detail_info.container_flag          := c.container_flag;
              l_detail_info.delivery_id             := c.delivery_id;
              l_detail_info.parent_delivery_detail_id  := c.parent_delivery_detail_id;
              -- Bug 2419301
              l_detail_info.oe_interfaced_flag      := NULL;
              --
              -- J: W/V Changes
              l_detail_info.gross_weight            := c.gross_weight;
              l_detail_info.volume                  := c.volume;
              l_detail_info.weight_uom_code         := c.weight_uom_code;
              l_detail_info.volume_uom_code         := c.volume_uom_code;
              l_detail_info.wv_frozen_flag          := c.wv_frozen_flag;
              -- End W/V Changes
              --
              -- K: MDC
              l_detail_info.parent_delivery_id      := c.parent_delivery_id;
              l_detail_info.wda_type                := c.wda_type;
              -- END K: MDC
	      IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DETAIL_INT IN SPLIT_RECORDS_Int'  );
              END IF;
              --
-- HW OPMCONV. Removed  l_process_flag
              WSH_DELIVERY_DETAILS_ACTIONS.Split_Detail_INT(
                 p_old_delivery_detail_rec => l_detail_info,
                 p_new_source_line_id  => p_changed_attributes(l_counter).source_line_id,
                 p_quantity_to_split   => l_quantity_split,
                 p_quantity_to_split2  => l_quantity_split2,
                 p_split_sn            => 'Y',
                 x_split_detail_id     => l_working_detail_id,
                 x_return_status       => l_rs);


              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_rs',l_rs);
              END IF;
              IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                 EXIT records_loop;
              END IF;

	      --bug# 6719369 (replenishment project) (begin) : call WMS for whenever there is split on replenishment requested
              -- delivery detail lines with the new quantity for the old delivery detail line on p_primary_quantity parameter.
              -- Inturn WMS creates a new replenishment record for p_split_delivery_detail_id with old delivery detail line old qty - old delivery detail line
              --  new quantity (p_primary_quantity).
              IF ( c.replenishment_status = 'R' and c.released_status in ('R','B')) THEN
              --{
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL' ,WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL(
                      p_delivery_detail_id       => l_detail_info.delivery_detail_id,
                      p_primary_quantity         => c.requested_quantity - l_quantity_split,
                      p_split_delivery_detail_id => l_working_detail_id,
		      p_split_source_line_id     => p_changed_attributes(l_counter).source_line_id,
                      x_return_status            => x_return_status);
                  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  --{
                      IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,  'UNEXPECTED ERROR FROM WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL');
                          WSH_DEBUG_SV.pop(l_module_name);
                      END IF;
                      EXIT records_loop;
                  --}
                  END IF;
              --}
              END IF;
              --bug# 6719369 (replenishment project): end

              l_res_qty2_to_transfer := l_quantity_split2;
              l_res_qty_to_transfer  := l_quantity_split;
              l_move_order_line_status := 'CANCEL';

              --  bug fix 2187012 fix#1 start
              --
              --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'RELEASED STATUS',c.released_status);
              END IF;
              IF (c.released_status = 'S' ) THEN
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'MOL id ',c.move_order_line_id);
                END IF;
                --X-dock,split
                -- For rel. to warehouse lines, progressed from X-dock
                -- validation will be done earlier to stop the flow
                -- the code would come here only for Inventory org where
                -- MOL will be not null or
                -- X-dock where MOL will be null, in which case we want to
                -- retain the released_status of 'S' with null MOL
                 IF c.move_order_line_id IS NOT NULL THEN
                   UPDATE wsh_delivery_details
                   SET released_status = 'R',
                       move_order_line_id = NULL
                   WHERE delivery_detail_id = c.delivery_detail_id;
                 -- else released_status should be 'S' and MOL should be null
                 ELSE
                   UPDATE wsh_delivery_details
                   SET released_status = 'S',
                       move_order_line_id = NULL
                   WHERE delivery_detail_id = c.delivery_detail_id;
                 END IF;
                 --End of X-dock,split

                 --
                 -- DBI Project
                 -- Update of wsh_delivery_details where requested_quantity/released_status
                 -- are changed, call DBI API after the update.
                 -- This API will also check for DBI Installed or not
                 IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Calling DBI API delievery detail id:',c.delivery_detail_id);
                 END IF;
                 l_detail_tab(1) := c.delivery_detail_id;
                 WSH_INTEGRATION.DBI_Update_Detail_Log
                   (p_delivery_detail_id_tab => l_detail_tab,
                   p_dml_type               => 'UPDATE',
                   x_return_status          => l_dbi_rs);

                 IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
                 END IF;
                 --{
                 IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
		  x_return_status := l_dbi_rs;
                  ROLLBACK to before_splits;
		  -- just pass this return status to caller API
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
                    WSH_DEBUG_SV.pop(l_module_name);
                  END IF;
                  return;
                  END IF;
                 --}
              -- End of Code for DBI Project
              --
               -- to be used later for splitting unstaged reservations
                 l_sdd_tab(l_sdd_tab.count + 1 ) := c.delivery_detail_id ;
              END IF;
              --}

           END IF;

           l_quantity_to_split := l_quantity_to_split - l_quantity_split;
           l_quantity_to_split2 := l_quantity_to_split2 - l_quantity_split2;

           -- mark ATO split flag for CTO callback.
           IF c.ato_line_id IS NOT NULL THEN
              l_ato_split := TRUE;
           END IF;
           --
           -- bug # 9410461: Begin
           -- Need to call the transfer/cancle reservation API
           -- only when the released to warehouse dd is considereed
           -- to be transferred to the new line.
           -- NOTE: L_RES_QTY_TO_TRANSFER gets some value only when DD is transferred to new line.
           IF (c.released_status = 'S') AND (p_interface_flag = 'Y')
              AND (  p_changed_attributes(l_counter).top_model_line_id <> FND_API.G_MISS_NUM
		   AND p_changed_attributes(l_counter).top_model_line_id IS NOT NULL
		   AND (p_changed_attributes(l_counter).ato_line_id IS NULL OR p_changed_attributes(l_counter).ato_line_id = FND_API.G_MISS_NUM  )) THEN
           --{
               IF L_RES_QTY_TO_TRANSFER IS NULL THEN
                 l_trnfer_reservations := 'N';
               ELSE
                 l_trnfer_reservations := 'Y';
               END IF;
           --}
           END IF;
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'l_trnfer_reservations:' || l_trnfer_reservations);
           END IF;
           -- bug # 9410461: end
           --
           -- update reservations only if this delivery line can have them:
           -- non transactable lines do not have reservations.
           -- And delivery lines interfaced to inventory have consumed reservations.
           -- Bug 2119916: backordered delivery lines could still have
           --              reservations (from PO and WIP for expected quantities,
           --              as well as INV which user may manually create).
           --              Since we take care of other statuses first (except 'S')
           --              it should be OK to split reservations for 'B'.

           -- Bug 2121426/2129298: transfer reservations only if we have
           --   transferred delivery line to the new order line.
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'RESERVATION QUANTITY TO TRANSFER: ' || L_RES_QTY_TO_TRANSFER  );
-- HW OPMCONV -Added Qty2
              WSH_DEBUG_SV.logmsg(l_module_name, 'RESERVATION QUANTITY2 TO TRANSFER: ' || L_RES_QTY2_TO_TRANSFER  );
           END IF;
           --
           -- bug 3364238 - added the condition when released_status is 'S' and get_detailed_quantity > 0
--- HW 3530178 added the l_process_flag condition
-- HW OPMCONV - Call get_detailed_quantity as a procedure and
-- removed forking

           -- detailed quantity is only for details released to warehouse.
           -- anxsharm, X-dock changes
           --{
           IF c.released_status = 'S' AND c.move_order_line_id IS NOT NULL THEN
             WSH_USA_INV_PVT.get_detailed_quantity (
               p_mo_line_id      => c.move_order_line_id,
               x_detailed_qty    => l_detailed_qty,
               x_detailed_qty2   => l_detailed_qty2,
               x_return_status   => x_return_status);

             IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
               IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'get_detailed_quantity returned error');
                 EXIT records_loop;
               END IF;
             END IF;
           ELSE
             l_detailed_qty := c.requested_quantity;
             l_detailed_qty2 := c.requested_quantity2;
           END IF;  -- if c.move_order_line_id IS NOT NULL
           --}
           -- anxsharm, end of X-dock changes
-- bug # 9410461: Added l_trnfer_reservations condition.
-- HW OPMCONV - Use l_detailed_qty instead of calling get_detailed_quantity directly
-- and removed check for process in condition
           IF ( c.released_status in ('Y', 'C')) OR
              ( ( (c.released_status = 'S'
                    AND l_detailed_qty > 0
                    AND l_trnfer_reservations IS NULL)
                  OR
                   (l_trnfer_reservations = 'Y' ))) OR
               --bug 6313281: added status 'B' for ato_lines as they can have reservations.
              ( c.released_status = 'B' AND l_ato_split ) THEN
              l_reservable := WSH_DELIVERY_DETAILS_INV.get_reservable_flag(
                                    x_item_id         => c.inventory_item_id,
                                    x_organization_id => c.organization_id,
                                    x_pickable_flag   => c.pickable_flag);

              IF l_reservable = 'Y' THEN
-- HW 3530178 added the l_process_flag condition
-- HW OPMCONV - Removed forking
-- bug 8754085 commented both the lines below
                   --  l_res_qty_to_transfer :=  l_quantity_split;
-- HW OPMCONV Added Qty2
                   --    l_res_qty2_to_transfer :=  l_quantity_split2;

                 l_detail_inv_rec.delivery_detail_id := l_working_detail_id;
                 l_detail_inv_rec.released_status    := c.released_status;
                 l_detail_inv_rec.move_order_line_id := c.move_order_line_id;
                 l_detail_inv_rec.organization_id    := c.organization_id;
                 l_detail_inv_rec.inventory_item_id  := c.inventory_item_id;
                 l_detail_inv_rec.subinventory       := c.subinventory;
                 l_detail_inv_rec.revision           := c.revision;
                 l_detail_inv_rec.lot_number         := c.lot_number;
                 l_detail_inv_rec.locator_id         := c.locator_id;
                 -- Bug 2773605 : Update the lpn_id also to pass to Split_Reservation.
                 l_detail_inv_rec.lpn_id             := c.lpn_id;

--wrudge
                 -- bug 2121426: pass the correct quantity of reservations to transfer
                 --
              -- bugfix 8780988  Do not transfer the reservation when organization is changed for a split line (manual split)
	      IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'p_changed_attributes(l_counter).ship_from_org_id: ' || p_changed_attributes(l_counter).ship_from_org_id );
                WSH_DEBUG_SV.logmsg(l_module_name, 'l_detail_inv_rec.organization_id: ' || l_detail_inv_rec.organization_id );
              END IF;

              --bugfix 8976069 added join for 'Y' and 'C'
               IF (p_changed_attributes(l_counter).ship_from_org_id <> l_detail_inv_rec.organization_id) and c.released_status in ('Y', 'C')  THEN

		      WSH_USA_INV_PVT.cancel_staged_reservation(p_source_code => p_source_code,
                                                                p_source_header_id  => p_changed_attributes(l_counter).source_header_id,
                                                                p_source_line_id  =>  p_changed_attributes(l_counter).original_source_line_id,
                                                                p_delivery_detail_split_rec  => l_detail_inv_rec,
                                                                p_cancellation_quantity =>l_res_qty_to_transfer,
                                                                p_cancellation_quantity2 =>l_res_qty2_to_transfer,
                                                                x_return_status  => l_rs);


		  IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'unexpected error after WSH_USA_INV_PVT.cancel_staged_reservation ');
                    END IF;
                    exit records_loop ;
                 END IF;

	      ELSE

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_USA_INV_PVT.SPLIT_RESERVATION',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
               -- Added parameter p_shipped_flag for bug 10105817
                 WSH_USA_INV_PVT.Split_Reservation  (
                    p_delivery_detail_split_rec => l_detail_inv_rec,
                    p_source_code               => p_source_code,
                    p_source_header_id          => p_changed_attributes(l_counter).source_header_id,
                    p_original_source_line_id   => p_changed_attributes(l_counter).original_source_line_id,
                    p_split_source_line_id      => p_changed_attributes(l_counter).source_line_id,
                    p_split_quantity            => l_res_qty_to_transfer,
                    p_split_quantity2           => l_res_qty2_to_transfer,
                    p_move_order_line_status    => l_move_order_line_status,
                    p_direction_flag            => p_split_lines(i).direction_flag ,
                    p_shipped_flag              => p_changed_attributes(l_counter).shipped_flag,
                    x_return_status             => l_rs);

                 IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                    EXIT records_loop;
                 END IF;
	       END IF; --if ship_from_org_id

	      ELSE
                 l_total_unstaged_quantity := l_total_unstaged_quantity + NVL(c.picked_quantity,  c.requested_quantity);
              END IF; -- If reservable
           END IF;    -- If   c.released_status = 'Y'

--wrudge
            -- Bug 2129298: when quantity_to_split becomes zero during a normal
            -- user-initated action, we are done.
            -- But when we do the split during OM Interface, we need to continue
            -- the loop and look for other delivery lines with requested_quantity = 0.
            -- This ensures that the overpicked delivery lines are all moved to the
            -- new order line, since the original order line becomes closed.
            IF (l_quantity_to_split <= 0)
               AND (p_interface_flag = 'N')    THEN
               -- We are finished with splitting this original source line.
               EXIT details_loop;
            END IF;

         END LOOP; -- delivery lines loop

         -- after split of ATO delivery lines,
         -- we need to call CTO to update information on ATO for the new order line.
         IF l_ato_split AND p_source_code = 'OE' THEN

           -- update CTO for newly split order line
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit CTO_WORKFLOW_API_PK.WF_UPDATE_AFTER_INV_UNRESERV',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
              --
              CTO_WORKFLOW_API_PK.wf_update_after_inv_unreserv(
                 p_order_line_id => p_changed_attributes(l_counter).source_line_id,
                 x_return_status => l_rs,
                 x_msg_count     => l_msg_count,
                 x_msg_data      => l_msg_data);
              IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'wf_update_after_inv_unreserv returned error');
                 END IF;
                 EXIT records_loop;
              END IF;
              -- update CTO for original order line
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit CTO_WORKFLOW_API_PK.WF_UPDATE_AFTER_INV_UNRESERV',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              CTO_WORKFLOW_API_PK.wf_update_after_inv_unreserv(
                 p_order_line_id => p_changed_attributes(l_counter).original_source_line_id,
                 x_return_status => l_rs,
                 x_msg_count     => l_msg_count,
                 x_msg_data      => l_msg_data);
              IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'wf_update_after_inv_unreserv returned error');
                 END IF;
                 EXIT records_loop;
              END IF;


           END IF; -- l_ato_split AND p_source_code = 'OE'

          /* Bug#8373924 */
           OPEN ordered_quantity2(p_changed_attributes(l_counter).original_source_line_id);
           FETCH ordered_quantity2 INTO l_line_ordered_quantinty2;
           CLOSE ordered_quantity2;

           -- bug fix 2187012 fix #2 start
           -- No Update of released status
           UPDATE WSH_DELIVERY_DETAILS
           SET SRC_REQUESTED_QUANTITY  = SRC_REQUESTED_QUANTITY - p_changed_attributes(l_counter).ordered_quantity,
               SRC_REQUESTED_QUANTITY2 = l_line_ordered_quantinty2 --SRC_REQUESTED_QUANTITY2 - p_changed_attributes(l_counter).ordered_quantity2
           WHERE SOURCE_LINE_ID = p_changed_attributes(l_counter).original_source_line_id
           AND   SOURCE_CODE = p_source_code;
           -- bug fix 2187012 fix #2 end

        END IF; -- p_changed_attributes(l_counter).action_flag = 'S'

        <<split_next_record>>
        NULL;
     END LOOP;  -- records loop

     l_last_orig_line_id := 0 ;

     -- Loop here to calculate the reservations to split for each p_changed_attribute
     -- IF Condition added for bug 10105817
     -- Proceed further only l_rs is SUCCESS/WARNING.
     -- Added If Condition, since ITS proceeds further and completes normally even if API
     -- WSH_USA_INV_PVT.Split_Reservation returs Expected/Unexpected error.
     IF l_rs NOT IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN -- {
     -- Loop here to calculate the reservations to split for each p_changed_attribute


    l_total_spare_rsv  := 0; --bugfix 8780988
    l_total_spare_rsv2 := 0; --bugfix 8780988


     FOR i  IN 1..p_split_lines.count -1  LOOP --{

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'i = ' || i ) ;
        END IF;
        l_counter := p_split_lines(i).changed_attributes_index ;

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calculating unstaged reservations for line_id ' || p_changed_attributes(l_counter).source_line_id || ' , action_flag is ' || p_changed_attributes(l_counter).action_flag  );
        END IF;

        IF p_changed_attributes(l_counter).action_flag = 'S' THEN --{

           -- Get total ordered Quantity

           IF l_last_orig_line_id <>  p_changed_attributes(l_counter).original_source_line_id THEN --{

              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'new line_id ' || p_changed_attributes(l_counter).original_source_line_id);
              END IF;
              open c_total_requested_quantity (  p_changed_attributes(l_counter).original_source_line_id);
              fetch c_total_requested_quantity into l_inventory_item_id , l_requested_quantity_uom , l_total_requested_quantity,
                    l_total_requested_quantity2,l_organization_id; --bugfix 8780988
              close c_total_requested_quantity ;

              -- Get total already reserved on the original line
-- HW OPMCONV - Added Qty2 parameter
          --bugfix 8915868 Store the Spare reservation for original line
              IF l_total_spare_rsv > 0 THEN

                l_cancel_counter :=l_cancel_counter + 1;

	        l_Cancel_Reservation_Tab_Type(l_cancel_counter).source_code:= p_source_code ;
                l_Cancel_Reservation_Tab_Type(l_cancel_counter).source_header_id:= p_changed_attributes(l_counter).source_header_id;
	        l_Cancel_Reservation_Tab_Type(l_cancel_counter).source_line_id:= l_last_orig_line_id;
	        l_Cancel_Reservation_Tab_Type(l_cancel_counter).delivery_detail_id:= NULL;
	        l_Cancel_Reservation_Tab_Type(l_cancel_counter).organization_id:=  l_organization_id;
	        l_Cancel_Reservation_Tab_Type(l_cancel_counter).cancelled_quantity := l_total_spare_rsv;
	        l_Cancel_Reservation_Tab_Type(l_cancel_counter).cancelled_quantity2 := l_total_spare_rsv2;

	      END IF;

	       WSH_USA_INV_PVT.Get_total_reserved_quantity (
                p_source_code        => p_source_code  ,
                p_source_header_id   => p_changed_attributes(l_counter ).source_header_id   ,
                p_source_line_id     => p_changed_attributes(l_counter ).original_source_line_id  ,
                p_organization_id    => p_changed_attributes(l_counter ).organization_id  ,
                x_total_rsv          => l_total_reserved_quantity ,
                x_total_rsv2          => l_total_reserved_quantity2 ,
                x_return_status      => l_rs );

              -- Get spare reservation quantity

              l_total_spare_rsv :=  GREATEST ( l_total_reserved_quantity - l_total_requested_quantity  , 0 ) ;
-- HW OPMCONV - AddedQty2
              l_total_spare_rsv2 :=  GREATEST ( l_total_reserved_quantity2 - l_total_requested_quantity2  , 0 ) ;

              l_last_orig_line_id :=  p_changed_attributes(l_counter).original_source_line_id  ;

          END IF ;  --}
          --bugfix 8780988 Added check for organization id
          IF l_total_spare_rsv > 0 AND (p_changed_attributes(l_counter).Ship_from_org_id = l_organization_id) THEN  --{

             -- Get total  reserved quantity on current line
-- HW OPMCONV - Pass Qty2 as a parameter
             WSH_USA_INV_PVT.Get_total_reserved_quantity (
               p_source_code        => p_source_code  ,
               p_source_header_id   => p_changed_attributes(l_counter ).source_header_id   ,
               p_source_line_id     => p_changed_attributes(l_counter ).source_line_id  ,
               p_organization_id    => p_changed_attributes(l_counter ).organization_id  ,
               x_total_rsv          => l_total_reserved_quantity ,
               x_total_rsv2         => l_total_reserved_quantity2 ,
               x_return_status      => l_rs );

-- HW OPMCONV. Removed forking
               l_quantity_to_split := WSH_WV_UTILS.Convert_UOM(
                             from_uom => p_changed_attributes(l_counter).order_quantity_uom,
                             to_uom   => l_requested_quantity_uom,
                             quantity => p_changed_attributes(l_counter).ordered_quantity ,
                             item_id  => l_inventory_item_id);

-- HW OPMCONV - Added Qty2
            l_quantity_to_split2 := NVL(p_changed_attributes(l_counter).ordered_quantity2,0);
            l_max_rsv_to_split := GREATEST ( l_quantity_to_split - l_total_reserved_quantity , 0 ) ;
-- HW OPMCONV - Added Qty2
            l_max_rsv_to_split2 := GREATEST ( l_quantity_to_split2 - l_total_reserved_quantity2 , 0 ) ;

            l_total_rsv_to_split(l_counter) :=  LEAST ( l_total_spare_rsv , l_max_rsv_to_split ) ;

            l_total_rsv_to_split2(l_counter) :=  LEAST ( l_total_spare_rsv2 , l_max_rsv_to_split2 ) ;
            l_total_spare_rsv := l_total_spare_rsv - l_total_rsv_to_split(l_counter) ;
-- HW OPMCONV - Added Qty2
            l_total_spare_rsv2 := l_total_spare_rsv2 - l_total_rsv_to_split2(l_counter) ;
            l_max_rsv_to_split:= 0 ;
-- HW OPMCONV - Added Qty2
            l_max_rsv_to_split2:= 0 ;

         else
            l_total_rsv_to_split(l_counter) := 0 ;
-- HW OPMCONV - Added Qty2
            l_total_rsv_to_split2(l_counter) := 0 ;
         END IF ;  --}
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'l_total_rsv_to_split ( ' || l_counter || ' ) = ' || l_total_rsv_to_split(l_counter));
-- HW OPMCONV - Print Qty2
             WSH_DEBUG_SV.logmsg(l_module_name,'l_total_rsv_to_split2 ( ' || l_counter || ' ) = ' || l_total_rsv_to_split2(l_counter));
         END IF;
      END IF ; --} Action_flag = 'S'

    END LOOP ;--}

    --transfer unstaged reservations loop
    <<unstaged_rsv_loop>>
    FOR i IN 1..p_changed_attributes.count LOOP --{

      l_counter := p_changed_attributes.count -i + 1  ;
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unstg RSV xfr loop : l_counter ' || l_counter );
      END IF;

      IF p_changed_attributes(l_counter).action_flag = 'S' THEN --{

        l_uom_converted      := FALSE;

        l_total_res_qty_to_transfer :=  l_total_rsv_to_split(l_counter);
-- HW OPMCONV - Added Qty2
        l_total_res_qty2_to_transfer :=  l_total_rsv_to_split2(l_counter);

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unstg RSV xfr loop : l_counter ' || l_counter || ' : OLID ' || p_changed_attributes(l_counter).original_source_line_id || ' : LID ' || p_changed_attributes(l_counter).source_line_id );
           WSH_DEBUG_SV.logmsg(l_module_name,'l_total_res_qty_to_transfer  ' || l_total_res_qty_to_transfer );
-- HW OPMCONV - Print qty2
           WSH_DEBUG_SV.logmsg(l_module_name,'l_total_res2_qty_to_transfer  ' || l_total_res_qty2_to_transfer );
        END IF;

        if ( l_total_res_qty_to_transfer > 0 ) then  --{

           FOR c IN c_details(p_source_code,
                      p_changed_attributes(l_counter).source_line_id,
                      p_interface_flag,
                      p_changed_attributes(l_counter).shipped_flag  ) LOOP --{
              -- bug 3364238 - added the condition when released_status is 'S' and get_detailed_quantity > 0
-- HW OPMCONV - Get detailed_qty using new procedure

           -- detailed quantity is only for details released to warehouse.
           -- anxsharm, X-dock changes
           --{
           IF c.released_status = 'S' AND c.move_order_line_id IS NOT NULL THEN
             WSH_USA_INV_PVT.get_detailed_quantity (
               p_mo_line_id      => c.move_order_line_id,
               x_detailed_qty    => l_detailed_qty,
               x_detailed_qty2   => l_detailed_qty2,
               x_return_status   => x_return_status);

             IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
               IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'get_detailed_quantity returned error');
                 EXIT unstaged_rsv_loop;
               END IF;
             END IF;
           ELSE
             l_detailed_qty := c.requested_quantity;
             l_detailed_qty2 := c.requested_quantity2;
           END IF;  -- if released to whse and c.move_order_line_id IS NOT NULL
           --}
           -- anxsharm, end of X-dock changes

              IF NOT (( c.released_status IN ('Y','C') ) OR ( c.released_status = 'S' AND l_detailed_qty > 0 )) THEN -- {
                 IF NOT l_uom_converted THEN --{
                    l_uom_converted := TRUE;
 -- HW OPMCONV. Removed forking
                       l_quantity_to_split := WSH_WV_UTILS.Convert_UOM(
                                from_uom => p_changed_attributes(l_counter).order_quantity_uom,
                                to_uom   => c.requested_quantity_uom,
                                quantity => p_changed_attributes(l_counter).ordered_quantity,
                                item_id  => c.inventory_item_id);
-- HW OPMCONV - Added Qty2

                       l_quantity_to_split2 := p_changed_attributes(l_counter).ordered_quantity2;
                 END IF ;  --}

                 l_detail_inv_rec.delivery_detail_id := c.delivery_detail_id ;

                 l_found := FALSE  ;
                 l_move_order_line_status := 'TRANSFER';
                 for i in 1..l_sdd_tab.count loop
                    if l_sdd_tab(i) = c.delivery_Detail_id then
                       l_found := TRUE ;
                       l_move_order_line_status := 'CANCEL';
                       exit ;
                    end if ;
                 end loop ;

                 if not l_found then
                    l_detail_inv_rec.released_status    := c.released_status;
                 else
                    l_detail_inv_rec.released_status    := 'S' ;
                 end if ;

                 l_detail_inv_rec.move_order_line_id := c.move_order_line_id;
                 l_detail_inv_rec.organization_id    := c.organization_id;
                 l_detail_inv_rec.inventory_item_id  := c.inventory_item_id;
                 l_detail_inv_rec.subinventory       := c.subinventory;
                 l_detail_inv_rec.revision           := c.revision;
                 l_detail_inv_rec.lot_number         := c.lot_number;
                 l_detail_inv_rec.locator_id         := c.locator_id;
                 l_detail_inv_rec.lpn_id             := c.lpn_id;

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'TRansfering unstaged reservations : BEfore WSH_USA_INV_PVT.Split_Reservation ');
                 END IF;
-- HW OPMCONV - Added Qty2
                  l_res_qty_to_transfer := LEAST ( nvl(c.picked_quantity , c.requested_quantity ) ,
                                                  l_total_res_qty_to_transfer );

                  l_res_qty2_to_transfer := LEAST ( nvl(c.picked_quantity2 , c.requested_quantity2 ) ,
                                                  l_total_res_qty2_to_transfer );


                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'c.picked_quantity ' || c.picked_quantity  );
                    WSH_DEBUG_SV.logmsg(l_module_name,'c.requested_quantity ' || c.requested_quantity  );
                    WSH_DEBUG_SV.logmsg(l_module_name,'l_total_res_qty_to_transfer  ' || l_total_res_qty_to_transfer   );
-- HW OPMCONV - Print Qty2
                    WSH_DEBUG_SV.logmsg(l_module_name,'l_total_res_qty2_to_transfer  ' || l_total_res_qty2_to_transfer   );
                    WSH_DEBUG_SV.logmsg(l_module_name,'c.picked_quantity2 ' || c.picked_quantity2  );
                    WSH_DEBUG_SV.logmsg(l_module_name,'c.requested_quantity2 ' || c.requested_quantity2  );
                    WSH_DEBUG_SV.logmsg(l_module_name,'l_res_qty_to_transfer = min of above = ' || l_res_qty_to_transfer );
-- HW OPMCONV - Print Qty2
                    WSH_DEBUG_SV.logmsg(l_module_name,'l_res_qty2_to_transfer = min of above = ' || l_res_qty2_to_transfer );
                    WSH_DEBUG_SV.logmsg(l_module_name,'released_status       = ' || c.released_Status  );
                 END IF;

                 -- Bugfix 8864613 add code to get the direction flag
                 l_direction_flag := NULL;
		 --
                 FOR j  IN 1..p_split_lines.count LOOP
		 --
                 IF p_changed_attributes(l_counter).source_line_id = p_split_lines(j).source_line_id THEN
                   l_direction_flag :=p_split_lines(j).direction_flag ;
                   EXIT;
                 END IF;
		 --
                 END LOOP;

                 --
		 IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'l_direction_flag       = ' || l_direction_flag );
                  WSH_DEBUG_SV.logmsg(l_module_name,'p_shipped_flag    = '||p_changed_attributes(l_counter).shipped_flag);
                 END IF;
                 --
                 WSH_USA_INV_PVT.Split_Reservation  (
                          p_delivery_detail_split_rec => l_detail_inv_rec,
                          p_source_code               => p_source_code,
                          p_source_header_id          => p_changed_attributes(l_counter).source_header_id,
                          p_original_source_line_id   => p_changed_attributes(l_counter).original_source_line_id,
                          p_split_source_line_id      => p_changed_attributes(l_counter).source_line_id,
                          p_split_quantity            => l_res_qty_to_transfer,
                          p_split_quantity2           => l_res_qty2_to_transfer,
                          p_move_order_line_status    => l_move_order_line_status, -- spltrsv:this needs to be set correctly.
                          p_direction_flag            => l_direction_flag,
			  p_shipped_flag              => p_changed_attributes(l_counter).shipped_flag,
                          x_return_status             => l_rs);

                 IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'unexpected error after WSH_USA_INV_PVT.Split_Reservation ');
                    END IF;
                    exit unstaged_rsv_loop ;
                 END IF;


                 l_total_res_qty_to_transfer := l_total_res_qty_to_transfer - l_res_qty_to_transfer ;
-- HW OPMCONV - Added Qty2
                 l_total_res_qty2_to_transfer := l_total_res_qty2_to_transfer - l_res_qty2_to_transfer ;

                 IF ( l_total_res_qty_to_transfer <= 0 ) then
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'Exiting to next source_line');
                    END IF;
                    EXIT ;
                 END IF ;
              END IF; --} c.released_status NOT IN ('Y','C')
           END LOOP ; --}
        END IF ; --} if total reservation to transfer > 0
     END IF ; --} Action_flag = 'S'
  END LOOP; --}
 --

 IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'l_total_spare_rsv  = ' ||l_total_spare_rsv);
    WSH_DEBUG_SV.logmsg(l_module_name,'l_total_spare_rsv2  = ' ||l_total_spare_rsv2);
 END IF;
  -- bugfix 8780988 delete all the remaining unstaged reservation
  -- l_total_spare_rsv is populated only for split and unstaged reservation
   -- bugfix 8915868
 --
 IF l_total_spare_rsv > 0 THEN

          l_cancel_counter := l_cancel_counter + 1 ;

	  l_Cancel_Reservation_Tab_Type(l_cancel_counter).source_code:= p_source_code ;
          l_Cancel_Reservation_Tab_Type(l_cancel_counter).source_header_id:= p_changed_attributes(l_counter).source_header_id;
	  l_Cancel_Reservation_Tab_Type(l_cancel_counter).source_line_id:= p_changed_attributes(l_counter).original_source_line_id;
	  l_Cancel_Reservation_Tab_Type(l_cancel_counter).delivery_detail_id:= NULL;
	  l_Cancel_Reservation_Tab_Type(l_cancel_counter).organization_id:=  l_organization_id;
	  l_Cancel_Reservation_Tab_Type(l_cancel_counter).cancelled_quantity := l_total_spare_rsv;
	  l_Cancel_Reservation_Tab_Type(l_cancel_counter).cancelled_quantity2 := l_total_spare_rsv2;

 END IF;
 --
 IF l_cancel_counter > 0 THEN

   FOR i in 1..l_cancel_counter LOOP

    WSH_USA_INV_PVT.cancel_nonstaged_reservation( p_source_code            => l_Cancel_Reservation_Tab_Type(i).source_code,
                                                  p_source_header_id       => l_Cancel_Reservation_Tab_Type(i).source_header_id,
                                                  p_source_line_id         => l_Cancel_Reservation_Tab_Type(i).source_line_id,
                                                  p_delivery_detail_id     => l_Cancel_Reservation_Tab_Type(i).delivery_detail_id,
                                                  p_organization_id        => l_Cancel_Reservation_Tab_Type(i).organization_id ,
                                                  p_cancellation_quantity  => l_Cancel_Reservation_Tab_Type(i).cancelled_quantity,
                                                  p_cancellation_quantity2 => l_Cancel_Reservation_Tab_Type(i).cancelled_quantity2,
                                                  x_return_status          => l_rs);
            --
  	    IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                 IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'unexpected error after WSH_USA_INV_PVT.cancel_nonstaged_reservation');
                 END IF;
            END IF;
            --
    END LOOP ;
 END IF;

 l_cancel_counter := 0;

END IF; -- } Added for bug 10105817
 --
 -- purge delivery details pending overpick
  IF l_rs NOT IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
     AND l_delete_dds.count > 0 THEN
     WSH_INTERFACE.Delete_Details(
       p_details_id      =>    l_delete_dds,
       x_return_status   =>    l_rs
       );
  END IF;

  IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
      ROLLBACK to before_splits;
  END IF;

  x_return_status := l_rs;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO before_splits;
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_USA_ACTIONS_PVT.Split_Records_Int',l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Split_Records_Int;

PROCEDURE Split_Records (
  p_source_code            IN            VARCHAR2,
  p_changed_attributes     IN            WSH_INTERFACE.ChangedAttributeTabType,
  p_interface_flag         IN            VARCHAR2,
  x_return_status          OUT NOCOPY    VARCHAR2
) IS
l_index number ;
l_direction_flag direction_flag_tab_type ;
l_index_tab      WSH_UTIL_CORE.ID_Tab_Type ;
l_split_table    split_Table_Tab_Type ;
l_smallest_orig_line_id  NUMBER ;
l_updates_count          NUMBER ;
l_original_line_found   BOOLEAN ;
l_smallest_date         DATE ;
l_return_status        VARCHAR2(1);
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Split_Records';
l_debug_on BOOLEAN;
BEGIN
   --
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
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_INTERFACE_FLAG',P_INTERFACE_FLAG);
       WSH_DEBUG_SV.logmsg(l_module_name,'Inside Split_Records');
   END IF;

  l_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Populate p_split_table
  l_smallest_orig_line_id := 0 ;
  l_updates_count         := 0 ;

  FOR i in p_changed_attributes.FIRST..p_changed_attributes.LAST  --{loop on p_changed_attributes to scan for request_date on update records.
  LOOP

       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Index i',i);
       END IF;

       IF p_changed_attributes(i).action_flag = 'U' THEN
   l_updates_count := l_updates_count + 1 ;
       ELSIF p_changed_attributes(i).action_flag = 'S' THEN
          -- is this the earlier original_source_line ?
    if p_changed_attributes(i).original_source_line_id < l_smallest_orig_line_id then
        l_smallest_orig_line_id := p_changed_attributes(i).original_source_line_id ;
        l_smallest_date  := p_changed_attributes(i).date_requested ;
          end if ;

    -- Bug 2896725 : update the next record in l_split_table .
          l_split_table(l_split_table.count+1 ).source_line_id   := p_changed_attributes(i).source_line_id ;
          l_split_table(l_split_table.count ).original_source_line_id := p_changed_attributes(i).original_source_line_id ;

          l_split_table(l_split_table.count ).changed_Attributes_index  := i;

         FOR j in  p_changed_attributes.FIRST..p_changed_attributes.LAST   --{
         LOOP
            IF p_changed_attributes(j).action_flag = 'U' and
         p_changed_Attributes(i).source_line_id = p_changed_attributes(j).source_line_id  THEN
         l_split_table(l_split_table.count).date_requested := p_changed_attributes(j).date_requested ;
         l_split_table(l_split_table.count).date_requested := p_changed_attributes(j).date_requested ;
            END IF ;
         END LOOP;  --}

       END IF ;
  END LOOP ; --} loop on p_changed_attributes ..

  -- Populate the last split record with the smalled orginal source line id
  -- and its scheduled date for reference later for setting the direction.

  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Inside Split_Records: split_table.count = ' ||  l_split_table.count );
  END IF;

  if l_split_table.count > 0 then  --{ call sort_splits if one or more records
           --  because sort_splits also sets the direction_flag
         l_split_Table(l_split_table.count + 1 ).original_source_line_id := l_smallest_orig_line_id ;
         l_split_Table(l_split_table.count ).source_line_id := l_smallest_orig_line_id          ;
         l_split_Table(l_split_table.count ).date_requested := l_smallest_date                  ;

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Before sort splits' );

            WSH_DEBUG_SV.logmsg(l_module_name,'[original  source_line AttrIdx date-requested  direction_flag]' );
         END IF;

         FOR i in 1..l_split_table.count
         LOOP
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'[' || l_split_table(i).original_source_line_id || ' , '
                            || l_split_table(i).source_line_id || ' , '
                            || l_split_table(i).changed_Attributes_index ||    ' , '
                            || l_split_table(i).date_requested || ' , '
                            || l_split_table(i).direction_flag || ' ] '  );

            END IF;
         END LOOP;

   -- Bug 2899127:  even if one record exists , we still need to pass
   --               l_split_table to sort_splits to get the direction
   --               flag set correctly.
         if l_split_table.count > 1 then
              sort_splits (p_index_tab     => l_index_tab ,
                     p_split_table   => l_split_table,
         x_return_status => l_return_status  );

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
     x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
     return ;
        END IF;
         end if ;

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'[original  source_line AttrIdx date-requested  direction_flag]');
         END IF;

         FOR i in 1..l_split_table.count
         LOOP
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'[' || l_split_table(i).original_source_line_id || ' , '
                            || l_split_table(i).source_line_id || ' , '
                            || l_split_table(i).changed_Attributes_index ||    ' , '
                            || l_split_table(i).date_requested || ' , '
                            || l_split_table(i).direction_flag || ' ] '   );
           END IF;
         END LOOP;


         Split_Records_INT (
             p_source_code        => p_source_code  ,
             p_changed_attributes     => p_changed_attributes,
             p_interface_flag         => p_interface_flag ,
             p_index_tab              => l_index_tab ,
             p_split_lines            => l_split_table,
             x_return_status          => l_return_status
         ) ;

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
     x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,' Error in split_records_int '  );
     END IF;
   END IF;

  END IF ; --} if count > 1

  x_return_status := l_return_status ;

  --Debug message added  in bug 9265925
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION

  WHEN others THEN
       WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_USA_ACTIONS_PVT.Split_records ');
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,SQLCODE || ' : ' || SQLERRM );
       END IF;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END split_Records ;

PROCEDURE Update_Records(
  p_source_code            IN            VARCHAR2,
  p_changed_attributes     IN            WSH_INTERFACE.ChangedAttributeTabType,
  p_interface_flag         IN            VARCHAR2,
  x_return_status          OUT NOCOPY            VARCHAR2)
IS
  l_counter        NUMBER;
  l_update_allowed VARCHAR2(1);
  l_rs             VARCHAR2(1);
  l_changed_detail    WSH_USA_CATEGORIES_PVT.ChangedDetailRec;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_RECORDS';
  --
BEGIN

  --
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
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_INTERFACE_FLAG',P_INTERFACE_FLAG);
  END IF;
  --
  l_rs := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  <<records_loop>>
  FOR l_counter IN p_changed_attributes.FIRST .. p_changed_attributes.LAST LOOP

    IF p_changed_attributes(l_counter).action_flag IN ('S', 'U') THEN

      IF p_interface_flag = 'Y' THEN
         -- always allow update during OM Interface without validation or further changes.
        l_update_allowed := 'Y';
      ELSE
        -- normal process requires validation and sometimes changes.
        WSH_USA_CATEGORIES_PVT.Check_Attributes(
                  p_source_code        => p_source_code,
                  p_attributes_rec     => p_changed_attributes(l_counter),
                  x_changed_detail     => l_changed_detail,
                  x_update_allowed     => l_update_allowed,
                  x_return_status      => l_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'AFTER CALLING WSH_USA_CATEGORIES_PVT.CHECK_ATTRIBUTES: L_RS', L_RS  );
          WSH_DEBUG_SV.log(l_module_name, 'L_UPDATE_ALLOWED', l_update_allowed);
        END IF;

        IF NVL(l_update_allowed, 'N') = 'N' THEN
          -- bug 5387341: to prevent data corruption, we should return
          -- error when update is not allowed, since that means that
          -- the delivery detail(s) will not be synchronized with the
          -- order line.
          IF NVL(l_rs, 'X') <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            l_rs := WSH_UTIL_CORE.G_RET_STS_ERROR;
          END IF;
        END IF;

        IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          EXIT records_loop;
        END IF;
        --
      END IF;  -- p_interface_flag = 'Y'

      IF l_update_allowed = 'Y' THEN
        WSH_USA_ACTIONS_PVT.Update_Attributes(
                  p_source_code      => p_source_code,
                  p_attributes_rec   => p_changed_attributes(l_counter),
                  p_changed_detail   =>  l_changed_detail,
                  x_return_status    => l_rs);

        IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          EXIT records_loop;
        END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER CALLING WSH_USA_ACTIONS_PVT.UPDATE_ATTRIBUTES ' || L_RS  );
        END IF;
        --
      END IF; -- l_update_allowed = 'Y'

    END IF; -- p_changed_attributes(l_counter).action_flag in ('S', 'U')

  END LOOP; -- l_counter IN p_changed_attributes.FIRST .. p_changed_attributes.LAST

  x_return_status := l_rs;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_USA_ACTIONS_PVT.Update_Records',l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Update_Records;



Procedure Update_Attributes(
         p_source_code      IN        VARCHAR2,
         p_attributes_rec   IN        WSH_INTERFACE.ChangedAttributeRecType,
         p_changed_detail   IN        WSH_USA_CATEGORIES_PVT.ChangedDetailRec,
         x_return_status    OUT NOCOPY        VARCHAR2)
IS

--bug#6407943:Needs to change items org dependent attributes when org changes.
cursor c_is_reservable IS
select inventory_item_id, organization_id, pickable_flag,requested_quantity_uom,
       unit_weight,weight_uom_code,unit_volume,volume_uom_code,hazard_class_id,item_description
from wsh_delivery_details
where source_line_id = p_attributes_rec.source_line_id
and   source_code    = p_source_code
and rownum = 1;

/* H projects: pricing integration csun */ /* J TP Release */
--4410272
cursor c_get_delivery_detail_id IS
select delivery_detail_id, released_status, date_requested, date_scheduled
from  wsh_delivery_details
WHERE  source_code    = p_source_code
AND    source_line_id = p_attributes_rec.source_line_id
AND    container_flag = 'N'
AND    delivery_detail_id = decode( p_attributes_rec.delivery_detail_id, FND_API.G_MISS_NUM ,
                                  delivery_detail_id, p_attributes_rec.delivery_detail_id );

cursor c_get_tpdetails IS
select organization_id, carrier_id, ship_method_code, ignore_for_planning
from  wsh_delivery_details
WHERE  source_code    = p_source_code
AND    source_line_id = p_attributes_rec.source_line_id
AND    container_flag = 'N'
AND    delivery_detail_id = decode( p_attributes_rec.delivery_detail_id, FND_API.G_MISS_NUM ,
                                  delivery_detail_id, p_attributes_rec.delivery_detail_id )
AND    nvl(ignore_for_planning,'N')<>'Y'
AND    rownum=1;

b_ignore BOOLEAN;

CURSOR c_get_det_in_del (p_detailid NUMBER) IS
SELECT wnd.name delivery_name
FROM   wsh_delivery_assignments_v wda, wsh_new_deliveries wnd
WHERE  wda.delivery_id = wnd.delivery_id AND
       wda.delivery_id IS NOT NULL AND
       wda.delivery_detail_id=p_detailid;

-- Bug 3125768: this cursor is introduced to get the inventory transactable flag
CURSOR c_get_pickable(c_item_id NUMBER, c_org_id NUMBER) IS
SELECT NVL(mtl_transactions_enabled_flag, 'N')
FROM   mtl_system_items
WHERE  inventory_item_id = c_item_id
AND    organization_id   = c_org_id;

-- bug#6407943 (begin):Needs to change items org dependent attributes when org changes
CURSOR C_specific_item_info(c_p_inventory_item_id number,
                            c_p_organization_id number)
IS
SELECT hazard_class_id, primary_uom_code, weight_uom_code,
      unit_weight, volume_uom_code, unit_volume,description
FROM mtl_system_items m
WHERE m.inventory_item_id = c_p_inventory_item_id
AND   m.organization_id = c_p_organization_id;

l_haz_class_id number;
l_primary_uom_code varchar2(3);
l_weight_uom varchar2(3);
l_unit_weight number;
l_volume_uom varchar2(3);
l_unit_volume number;
l_db_requested_quantity_uom varchar2(3);
l_db_unit_volume number;
l_db_unit_weight number;
l_db_volume_uom varchar2(3);
l_db_weight_uom varchar2(3);
l_db_haz_class_id number;
l_change_req_quantity_uom varchar2(1):='N';
l_change_unit_weight varchar2(1) :='N';
l_change_unit_volume varchar2(1):= 'N';
l_change_weight_uom  varchar2(1) :='N';
l_change_volume_uom  varchar2(1):= 'N';
l_change_weight  varchar2(1):= 'N';
l_change_volume  varchar2(1):= 'N';
l_change_haz_class_id  varchar2(1):= 'N';
l_db_item_description   VARCHAR2(250);
l_item_description      VARCHAR2(250);
l_change_item_desc      VARCHAR2(1):='N';
-- bug#6407943 (end):Needs to change items org dependent attributes when org changes


l_wh_type VARCHAR2(3);
l_ignore_for_planning VARCHAR2(1);
l_groupbysmc VARCHAR2(1);
l_groupbycarrier VARCHAR2(1);
l_in_ids wsh_util_core.id_tab_type;
l_datetype VARCHAR2(30);
l_smc wsh_delivery_details.ship_method_code%TYPE;
l_carrierid wsh_delivery_details.carrier_id%TYPE;
l_orgid wsh_delivery_details.organization_id%TYPE;
l_earliest_pickup_date DATE;
l_latest_pickup_date DATE;
l_earliest_dropoff_date DATE;
l_latest_dropoff_date DATE;


l_mark_reprice_flag            VARCHAR2(1) := 'N';
l_delivery_detail_id           NUMBER ;
m     NUMBER := 0;
l_details_marked        WSH_UTIL_CORE.Id_Tab_Type;
--4410272
l_tp_details            WSH_UTIL_CORE.Id_Tab_Type;
l_return_status         VARCHAR2(1);
mark_reprice_error  EXCEPTION;


l_inventory_item_id            NUMBER;
l_organization_id              NUMBER;
l_pickable_flag                VARCHAR2(1);
l_reservable_flag              VARCHAR2(1);
l_ship_from_location_id        NUMBER;
l_ship_to_location_id          NUMBER;
l_deliver_to_location_id       NUMBER;
l_intmed_ship_to_location_id   NUMBER;
l_carrier_rec                  WSH_CARRIERS_GRP.Carrier_Service_InOut_Rec_Type;
l_generic_flag VARCHAR2(1);
l_service_level VARCHAR2(30);
l_mode_of_transport VARCHAR2(30);
l_carrier_id NUMBER;
l_ship_method_code VARCHAR2(30);
tpdates_changed VARCHAR2(1);

--OTM R12 Start Org-Specific
l_gc3_is_installed             VARCHAR2(1);
l_shipping_param_info          WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;

-- 5870774
l_oke_full_cancel_flag         VARCHAR2(1) := 'N';

Update_Failed                  Exception;

l_change_sub VARCHAR2(1); --Added for bug 8995849

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ATTRIBUTES';
l_dbi_rs       VARCHAR2(1); -- DBI Project
--
BEGIN
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --OTM R12 Start Org-Specific
   l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;
   IF l_gc3_is_installed IS NULL THEN
     l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
   END IF;
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_gc3_is_installed',l_gc3_is_installed);
   END IF;
   --OTM R12

   SAVEPOINT before_changes;

   OPEN c_is_reservable;
   -- bug#6407943 : Added extra fields related to item specific attribute values.
   FETCH  c_is_reservable INTO l_inventory_item_id, l_organization_id, l_pickable_flag,l_db_requested_quantity_uom,
                               l_db_unit_weight,l_db_weight_uom,l_db_unit_volume,l_db_volume_uom,
                               l_db_haz_class_id,l_db_item_description;

   CLOSE c_is_reservable;

   -- Bug 3125768: Commenting the following call that gets the reservable flag.
   --              Now, Get the reservable flag after fetching the pickable flag for the new Organization
   /*
   l_reservable_flag := WSH_DELIVERY_DETAILS_INV.get_reservable_flag(
                                                         x_item_id => l_inventory_item_id,
                                                         x_organization_id =>  l_organization_id,
                                                         x_pickable_flag =>  l_pickable_flag);
   */

   -- bug#6407943 (Begin):
   --When there is a change in org value on sale order line, needs to change
   --item attributes which are org dependent .
   IF p_attributes_rec.ship_from_org_id <> FND_API.G_MISS_NUM
      AND p_attributes_rec.ship_from_org_id <> l_organization_id
      AND p_attributes_rec.inventory_item_id = FND_API.G_MISS_NUM
      AND p_attributes_rec.ship_from_org_id IS NOT NULL THEN
   --{
      OPEN c_specific_item_info(l_inventory_item_id, p_attributes_rec.ship_from_org_id);
      FETCH C_SPECIFIC_ITEM_INFO INTO l_haz_class_id, l_primary_uom_code, l_weight_uom, l_unit_weight,
                                      l_volume_uom, l_unit_volume,l_item_description;

      CLOSE c_specific_item_info;

      IF (l_db_requested_quantity_uom <> l_primary_uom_code) THEN
      --{
         l_change_req_quantity_uom:='Y';
      --}
      END IF;
      IF (nvl(l_db_unit_weight,-99) <> nvl(l_unit_weight,-99)) THEN
          l_change_unit_weight:='Y';
      END IF;
      IF (nvl(l_db_unit_volume,-99)<> nvl(l_unit_volume,-99)) THEN
          l_change_unit_volume:='Y';
      END IF;
      IF (nvl(l_db_weight_uom,-99) <> nvl(l_weight_uom,-99)) THEN
          l_change_weight_uom:='Y';
      END IF;
      IF (nvl(l_db_volume_uom,-99)<> nvl(l_volume_uom,-99)) THEN
          l_change_volume_uom:='Y';
      END IF;
      IF (l_change_unit_weight ='Y' OR l_change_req_quantity_uom = 'Y') THEN
         l_change_weight:='Y';
      END IF;
      IF (l_change_unit_volume ='Y' OR l_change_req_quantity_uom = 'Y') THEN
         l_change_volume:='Y';
      END IF;
      IF (nvl(l_db_haz_class_id,-99) <> nvl(l_haz_class_id,-99)) THEN
          l_change_haz_class_id:='Y';
      END IF;
      IF (nvl(l_db_item_description,-99) <> nvl(l_item_description,-99)) THEN
          l_change_item_desc:='Y';
      END IF;


   --}
   END IF;
   -- bug#6407943 (end):Needs to change items org dependent attributes when org changes.

   IF p_attributes_rec.ship_from_org_id <> FND_API.G_MISS_NUM THEN

      WSH_UTIL_CORE.GET_LOCATION_ID('ORG', p_attributes_rec.ship_from_org_id,
                                    l_ship_from_location_id, x_return_status);

      IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'get_reservable_flag returned error');
        END IF;
        raise Update_Failed;
      END IF;

-- HW OPMCONV -Removed forking

-- Bug 3125768: Getting the inventory transactable flag for the item of the new Organization
        OPEN c_get_pickable(l_inventory_item_id, p_attributes_rec.ship_from_org_id);
        FETCH c_get_pickable INTO l_pickable_flag;
        CLOSE c_get_pickable;


   END IF;

   -- Bug 3125768
   l_reservable_flag := WSH_DELIVERY_DETAILS_INV.get_reservable_flag(
                                                         x_item_id => l_inventory_item_id,
                                                         x_organization_id =>  l_organization_id,
                                                         x_pickable_flag =>  l_pickable_flag);

   IF p_attributes_rec.ship_to_org_id <> FND_API.G_MISS_NUM THEN

      WSH_UTIL_CORE.GET_LOCATION_ID('CUSTOMER SITE', p_attributes_rec.ship_to_org_id,
                                    l_ship_to_location_id, x_return_status);

      IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'GET_LOCATION_ID failed');
        END IF;
        raise Update_Failed;
      END IF;

   END IF;

   IF (p_attributes_rec.deliver_to_org_id IS NOT NULL)
    AND (p_attributes_rec.deliver_to_org_id <> FND_API.G_MISS_NUM) THEN
     WSH_UTIL_CORE.GET_LOCATION_ID('CUSTOMER SITE', p_attributes_rec.deliver_to_org_id,
                                  l_deliver_to_location_id, x_return_status);

     IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'procedure GET_LOCATION_ID failed');
       END IF;
       raise Update_Failed;
     END IF;

   END IF;

   IF (p_attributes_rec.intmed_ship_to_org_id IS NOT NULL)
    AND (p_attributes_rec.intmed_ship_to_org_id <> FND_API.G_MISS_NUM) THEN
      --
      WSH_UTIL_CORE.GET_LOCATION_ID('CUSTOMER SITE', p_attributes_rec.intmed_ship_to_org_id,
                                  l_intmed_ship_to_location_id, x_return_status);

      IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'program GET_LOCATION_ID failed');
       END IF;
        raise Update_Failed;
      END IF;

   END IF;

   IF (l_deliver_to_location_id is NULL) AND (l_ship_to_location_id IS NOT NULL) THEN
       l_deliver_to_location_id := l_ship_to_location_id;
   ELSIF (l_deliver_to_location_id is NULL) AND (l_ship_to_location_id IS NULL)
     AND (p_attributes_rec.ship_to_org_id <> FND_API.G_MISS_NUM) THEN
     --
     WSH_UTIL_CORE.GET_LOCATION_ID('CUSTOMER SITE', p_attributes_rec.ship_to_org_id,
                                    l_deliver_to_location_id, x_return_status);

       IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'GET_LOCATION_ID failed for ship_to');
         END IF;
         raise Update_Failed;
       END IF;

   END IF;
   --OTM R12 Org-Specific Start
   IF l_gc3_is_installed = 'Y' THEN
     IF ( p_attributes_rec.ship_from_org_id IS NOT NULL AND
          p_attributes_rec.ship_from_org_id <> FND_API.G_MISS_NUM) THEN
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Before call to WSH_SHIPPING_PARAMS_PVT.Get to parameter values for Org',
                                         p_attributes_rec.ship_from_org_id );
       END IF;
       WSH_SHIPPING_PARAMS_PVT.Get(
              p_organization_id => p_attributes_rec.ship_from_org_id,
              p_client_id       => p_attributes_rec.client_id, -- LSP PROJECT.
              x_param_info      => l_shipping_param_info,
              x_return_status   => l_return_status);
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'After call to WSH_SHIPPING_PARAMS_PVT.Get l_return_status ',l_return_status);
         WSH_DEBUG_SV.log(l_module_name,'l_shipping_param_info.otm_enabled ',l_shipping_param_info.otm_enabled);
       END IF;

       IF (l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
         Raise Update_failed;
       END IF;
     End If;
   END IF;
   --OTM R12 End

/* J TP Release */
   IF (WSH_UTIL_CORE.TP_IS_INSTALLED = 'Y')  OR
      (l_gc3_is_installed = 'Y')THEN --OTM R12 Org-Specific. Added the second OR condition.
     b_ignore:=FALSE;
     --find atleast 1 detail with null or 'N' ignore
     OPEN c_get_tpdetails;
     FETCH c_get_tpdetails INTO l_orgid, l_carrierid, l_smc, l_ignore_for_planning;
     IF c_get_tpdetails%FOUND THEN
        b_ignore:=TRUE;
     END IF;
     CLOSE c_get_tpdetails;

    --1. check for updates to org, carrier, smc and based on
    -- that set ignore_for_planning

    IF (((p_attributes_rec.ship_from_org_id IS NOT NULL AND p_attributes_rec.ship_from_org_id <> FND_API.G_MISS_NUM)
       OR (p_attributes_rec.carrier_id IS NOT NULL AND p_attributes_rec.carrier_id <> FND_API.G_MISS_NUM)
       OR (p_attributes_rec.shipping_method_code IS NOT NULL AND p_attributes_rec.shipping_method_code <> FND_API.G_MISS_CHAR)
       AND b_ignore )
       OR (l_shipping_param_info.otm_enabled='Y')) --OTM R12 Org-Specific

  THEN

        IF (p_attributes_rec.ship_from_org_id IS NOT NULL AND p_attributes_rec.ship_from_org_id <> FND_API.G_MISS_NUM) THEN
            l_orgid:=p_attributes_rec.ship_from_org_id;
        END IF;
        IF (p_attributes_rec.carrier_id IS NOT NULL AND p_attributes_rec.carrier_id <> FND_API.G_MISS_NUM) THEN
            l_carrierid:=p_attributes_rec.carrier_id;
        END IF;
        IF (p_attributes_rec.shipping_method_code IS NOT NULL AND p_attributes_rec.shipping_method_code <> FND_API.G_MISS_CHAR) THEN
            l_smc:=p_attributes_rec.shipping_method_code;
        END IF;
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_orgid', l_orgid);
          WSH_DEBUG_SV.log(l_module_name,'l_carrierid', l_carrierid);
          WSH_DEBUG_SV.log(l_module_name,'l_smc', l_smc);
       END IF;

        l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
                           (p_organization_id  => l_orgid,
                            p_carrier_id         => l_carrierid,
                            p_ship_method_code   => l_smc,
                            p_msg_display        => 'N',
                            x_return_status    => l_return_status
                            );

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,' Get_Warehouse_Type  l_wh_type,l_return_status',l_wh_type||l_return_status);
        END IF;

       IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type failed');
         END IF;
         raise Update_Failed;
       END IF;

       IF (nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('TPW','CMS')) THEN --{
             l_ignore_for_planning:='Y';
             WSH_TP_RELEASE.Check_Shipset_Ignoreflag(p_attributes_rec.delivery_detail_id ,'Y',TRUE,x_return_status);
       --OTM R12 Start Org-Specific
       ELSIF (l_gc3_is_installed ='Y') THEN
         IF (l_shipping_param_info.otm_enabled ='Y') THEN
           l_ignore_for_planning:='N';
         ELSE
           l_ignore_for_planning:='Y';
         END IF;
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_ignore_for_planning ',
                                            l_ignore_for_planning );
         END IF;
       --OTM R12 End
       END IF; --}
    END IF;--org_id or carrier_id or smc is changed
  END IF; --tp_is_installed

  --OTM R12 Start Org-Specific
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_ignore_for_planning ',
                                    l_ignore_for_planning );
  END IF;
  --OTM R12 End


  IF (p_attributes_rec.shipping_method_code IS NOT NULL
  AND p_attributes_rec.shipping_method_code <> FND_API.G_MISS_CHAR) THEN

      l_carrier_rec.ship_method_code := p_attributes_rec.shipping_method_code;
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'ship_method_code ',p_attributes_rec.shipping_method_code);
      END IF;

      WSH_CARRIERS_GRP.get_carrier_service_mode(
                             p_carrier_service_inout_rec => l_carrier_rec,
                             x_return_status => x_return_status);

     IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'procedure get_carrier_service_mode failed');
       END IF;
       raise Update_Failed;
     END IF;

     IF l_carrier_rec.generic_flag = 'Y' THEN

        l_ship_method_code := NULL;
        l_carrier_id := NULL;

     ELSE

        l_ship_method_code := p_attributes_rec.shipping_method_code;
        l_carrier_id := l_carrier_rec.carrier_id;

     END IF;

     l_service_level := l_carrier_rec.service_level;
     l_mode_of_transport := l_carrier_rec.mode_of_transport;



  END IF;

  IF
    (p_changed_detail.earliest_pickup_date IS NULL AND p_changed_detail.latest_pickup_date IS NULL AND
     p_changed_detail.earliest_dropoff_date IS NULL AND p_changed_detail.latest_dropoff_date IS NULL ) THEN

     tpdates_changed := 'N';

  ELSE
     tpdates_changed := 'Y';
  END IF;

  -- Added for bug 4410272
  -- Call API WSH_TP_RELEASE.calculate_cont_del_tpdates only if dates
  -- are changed in WDD.
  FOR cur in c_get_delivery_detail_id LOOP
      IF ( cur.released_status <> 'C' AND
           ( ( cur.date_requested  <> p_attributes_rec.date_requested and
               p_attributes_rec.date_requested <> FND_API.G_MISS_DATE ) OR
             ( cur.date_scheduled  <> p_attributes_rec.date_scheduled and
               p_attributes_rec.date_scheduled <> FND_API.G_MISS_DATE ) OR
               tpdates_changed = 'Y' ) )
      THEN
        l_tp_details(l_tp_details.COUNT+1) := cur.delivery_detail_id;
      END IF;

      l_details_marked(l_details_marked.COUNT+1) := cur.delivery_detail_id;
  END LOOP;

  -- 5870774: If these are OKE lines and SRC Ord. Qty was 0 , then we have to leave line src_req_qty as such
  --          because the src_req_qty on the dds that were not Cancelled in the UpdateOrdQty Procedure (WSHUSAQB.pls)
  --          would have been Updated in the same Procedure (only true for OKE lines)
  l_oke_full_cancel_flag := 'N';
  if (p_source_code NOT IN ('OE','WSH','INV') and p_attributes_rec.ordered_quantity = 0) THEN --RTV changes
    l_oke_full_cancel_flag := 'Y';
  end if;  -- OKE

  --Added for bug 8995849
     If l_organization_id <> nvl(p_attributes_rec.ship_from_org_id,FND_API.G_MISS_NUM) THEN
        l_change_sub := 'Y';
     ELSE
        l_change_sub := 'N';
     END IF;

/*2740139 : For non-transactable,non-reservable,but stockable and shippable
items, the release status is 'X'.In this case the subinventory value is
set to the value that is present in wdd and not from the order lines.*/
   UPDATE wsh_delivery_details
         SET sold_to_contact_id = decode ( p_attributes_rec.sold_to_contact_id, FND_API.G_MISS_NUM ,
                                  sold_to_contact_id , NVL(p_attributes_rec.sold_to_contact_id, sold_to_contact_id) ) ,
             ship_to_contact_id = decode ( p_attributes_rec.ship_to_contact_id, FND_API.G_MISS_NUM ,
                                  ship_to_contact_id , p_attributes_rec.ship_to_contact_id ) ,
             deliver_to_contact_id = decode ( p_attributes_rec.deliver_to_contact_id, FND_API.G_MISS_NUM ,
                                     deliver_to_contact_id , p_attributes_rec.deliver_to_contact_id ) ,
             organization_id = decode (p_attributes_rec.ship_from_org_id,
                                       FND_API.G_MISS_NUM, organization_id,
                                       NULL, organization_id,
                                       p_attributes_rec.ship_from_org_id),
             ship_from_location_id = decode (p_attributes_rec.ship_from_org_id,
                                             FND_API.G_MISS_NUM, ship_from_location_id,
                                             NULL, ship_from_location_id,
                                             -- bug 2894922: if organization is not changed, keep ship_from_location_id
                                             organization_id, ship_from_location_id,
                                             l_ship_from_location_id ) ,
             ship_to_location_id = decode (p_attributes_rec.ship_to_org_id, FND_API.G_MISS_NUM ,
                                   ship_to_location_id , l_ship_to_location_id ) ,
             ship_to_site_use_id = decode ( p_attributes_rec.ship_to_org_id, FND_API.G_MISS_NUM ,
                                   ship_to_site_use_id , p_attributes_rec.ship_to_org_id ) ,
             deliver_to_site_use_id = decode ( p_attributes_rec.deliver_to_org_id, FND_API.G_MISS_NUM ,
                                      deliver_to_site_use_id , p_attributes_rec.deliver_to_org_id ) ,
             deliver_to_location_id = decode (p_attributes_rec.deliver_to_org_id, FND_API.G_MISS_NUM ,
                                      deliver_to_location_id , l_deliver_to_location_id ) ,
             intmed_ship_to_contact_id = decode ( p_attributes_rec.intmed_ship_to_contact_id, FND_API.G_MISS_NUM ,
                                         intmed_ship_to_contact_id , p_attributes_rec.intmed_ship_to_contact_id ) ,
             intmed_ship_to_location_id = decode (p_attributes_rec.intmed_ship_to_org_id, FND_API.G_MISS_NUM ,
                                         intmed_ship_to_location_id , l_intmed_ship_to_location_id ) ,
             customer_id = decode (p_attributes_rec.sold_to_org_id, FND_API.G_MISS_NUM ,
                                         customer_id , p_attributes_rec.sold_to_org_id),
             ship_tolerance_above = decode ( p_attributes_rec.ship_tolerance_above, FND_API.G_MISS_NUM ,
                                    ship_tolerance_above , p_attributes_rec.ship_tolerance_above ) ,
             ship_tolerance_below = decode ( p_attributes_rec.ship_tolerance_below, FND_API.G_MISS_NUM ,
                                    ship_tolerance_below , p_attributes_rec.ship_tolerance_below ) ,
             customer_requested_lot_flag = decode ( p_attributes_rec.customer_requested_lot_flag, FND_API.G_MISS_CHAR ,
                                           customer_requested_lot_flag , p_attributes_rec.customer_requested_lot_flag ),
             date_requested = decode ( p_attributes_rec.date_requested, FND_API.G_MISS_DATE ,
                              date_requested , p_attributes_rec.date_requested ) ,
             date_scheduled = decode ( p_attributes_rec.date_scheduled, FND_API.G_MISS_DATE ,
                              date_scheduled , p_attributes_rec.date_scheduled ) ,
             dep_plan_required_flag = decode ( p_attributes_rec.dep_plan_required_flag, FND_API.G_MISS_CHAR ,
                                      dep_plan_required_flag , p_attributes_rec.dep_plan_required_flag ) ,
             customer_prod_seq = decode ( p_attributes_rec.customer_prod_seq, FND_API.G_MISS_CHAR ,
                                 customer_prod_seq , p_attributes_rec.customer_prod_seq ) ,
             customer_dock_code = decode ( p_attributes_rec.customer_dock_code, FND_API.G_MISS_CHAR ,
                                  customer_dock_code , p_attributes_rec.customer_dock_code ) ,
             cust_model_serial_number = decode ( p_attributes_rec.cust_model_serial_number, FND_API.G_MISS_CHAR ,
                                  cust_model_serial_number , p_attributes_rec.cust_model_serial_number ) ,
             customer_job = decode ( p_attributes_rec.customer_job, FND_API.G_MISS_CHAR ,
                                  customer_job , p_attributes_rec.customer_job ) ,
             customer_production_line = decode ( p_attributes_rec.customer_production_line, FND_API.G_MISS_CHAR ,
                                  customer_production_line , p_attributes_rec.customer_production_line ) ,
             cust_po_number = decode ( p_attributes_rec.cust_po_number, FND_API.G_MISS_CHAR ,
                              cust_po_number , p_attributes_rec.cust_po_number ) ,
             packing_instructions = decode ( p_attributes_rec.packing_instructions, FND_API.G_MISS_CHAR ,
                                    packing_instructions , p_attributes_rec.packing_instructions ) ,
             shipment_priority_code = decode ( p_attributes_rec.shipment_priority_code, FND_API.G_MISS_CHAR ,
                                      shipment_priority_code , p_attributes_rec.shipment_priority_code ) ,
             ship_set_id = decode ( p_attributes_rec.ship_set_id, FND_API.G_MISS_NUM ,
                           ship_set_id , p_attributes_rec.ship_set_id ) ,
             ato_line_id = decode ( p_attributes_rec.ato_line_id, FND_API.G_MISS_NUM ,
                           ato_line_id , p_attributes_rec.ato_line_id ) ,
             arrival_set_id = decode ( p_attributes_rec.arrival_set_id, FND_API.G_MISS_NUM ,
                              arrival_set_id , p_attributes_rec.arrival_set_id ) ,
             ship_model_complete_flag = decode ( p_attributes_rec.ship_model_complete_flag, FND_API.G_MISS_CHAR ,
                                        ship_model_complete_flag , p_attributes_rec.ship_model_complete_flag ) ,
             -- Bug 2830372. We update the released status to 'N' only if the released status is in ('R', 'B', 'Y').
             -- ATO sets the released status to 'N' only when the reservations are removed for that order line.
             -- OM does not pass a released status of 'N', always passes 'R'.
       -- Bug 3125768: Checking for l_pickable_flag to update the released_status
             released_status =    decode(released_status,
                                         'C', released_status,
                                         'D', released_status,

                                         'Y', decode(p_attributes_rec.released_status,
                                                     'N', p_attributes_rec.released_status,
                                                          released_status),
                                         'X', decode(p_source_code , 'OKE', released_status,
                                                   decode(l_pickable_flag, 'N', released_status, 'R') ),    -- 5870774
                                         'S', released_status,
                                         'B', decode(p_attributes_rec.released_status,
                                                     'N', p_attributes_rec.released_status,
                                                     decode(l_pickable_flag, 'Y', released_status, 'X')),
            /* bug 2421965: backordered should stay backordered except for ATO reservations: Bug: 2587777 */
                                          decode ( l_pickable_flag, 'N' , 'X',
                                                  decode ( p_attributes_rec.released_status, FND_API.G_MISS_CHAR ,
                                                           released_status , p_attributes_rec.released_status ))) ,

             shipping_instructions = decode ( p_attributes_rec.shipping_instructions, FND_API.G_MISS_CHAR,
                                     shipping_instructions , p_attributes_rec.shipping_instructions ) ,
             shipped_quantity = decode ( p_attributes_rec.shipped_quantity, FND_API.G_MISS_NUM ,
                                shipped_quantity , p_attributes_rec.shipped_quantity ) ,
             cycle_count_quantity = decode ( p_attributes_rec.cycle_count_quantity,
                                             FND_API.G_MISS_NUM , decode(p_attributes_rec.shipped_quantity,
                                                                         FND_API.G_MISS_NUM, cycle_count_quantity,
                                                                         GREATEST(requested_quantity - p_attributes_rec.shipped_quantity, 0)),
                                             p_attributes_rec.cycle_count_quantity),
-- OPM
             shipped_quantity2 = decode ( p_attributes_rec.shipped_quantity2, FND_API.G_MISS_NUM ,
                                shipped_quantity2 , p_attributes_rec.shipped_quantity2 ) ,
             cycle_count_quantity2 = decode ( p_attributes_rec.cycle_count_quantity2,
                                              FND_API.G_MISS_NUM , decode(p_attributes_rec.shipped_quantity2,
                                                                          FND_API.G_MISS_NUM , cycle_count_quantity2 ,
                                                                          GREATEST(requested_quantity2 - p_attributes_rec.shipped_quantity2, 0)),
                                              p_attributes_rec.cycle_count_quantity2 ),
             currency_code = decode ( p_attributes_rec.currency_code, FND_API.G_MISS_CHAR ,
                             currency_code , p_attributes_rec.currency_code ) ,
             tracking_number = decode(p_attributes_rec.tracking_number, FND_API.G_MISS_CHAR ,
                               tracking_number , p_attributes_rec.tracking_number ) ,
             locator_id = decode(p_attributes_rec.locator_id,
                                 FND_API.G_MISS_NUM, locator_id,
                                 decode(released_status,
                                        'C', locator_id,
                                        p_attributes_rec.locator_id)),
             serial_number = decode(p_attributes_rec.serial_number,
                                    FND_API.G_MISS_CHAR, serial_number,
                                    decode(released_status,
                                           'C',serial_number,
                                           p_attributes_rec.serial_number)),
             lot_number = decode(p_attributes_rec.lot_number,
                                 FND_API.G_MISS_CHAR, lot_number,
                                 decode(released_status,
                                        'C', lot_number,
                                        p_attributes_rec.lot_number)),
-- OPM
-- HW OPMCONV - Removed sublot code

             preferred_grade = decode(p_attributes_rec.preferred_grade,
                                      FND_API.G_MISS_CHAR, preferred_grade,
                                      decode(released_status,
                                             'C', preferred_grade,
                                             'Y', preferred_grade,
                                             p_attributes_rec.preferred_grade)),
             revision = decode(p_attributes_rec.revision,
                               FND_API.G_MISS_CHAR, revision,
                               decode(released_status,
                                      'C', revision,
                                      p_attributes_rec.revision)),
       -- Bug 3125768: changed pickable_flag to l_pickable_flag
             subinventory = decode(p_attributes_rec.subinventory,
                                   FND_API.G_MISS_CHAR, subinventory,
                                   decode(released_status,
                                          'Y', decode(l_reservable_flag,
                                                      'N', decode(original_subinventory,
                                                                  p_attributes_rec.subinventory, subinventory,
                                                                  p_attributes_rec.subinventory),
                                                      subinventory),
                                          'S', decode(l_reservable_flag,
                                                      'N', decode(l_pickable_flag,
                                                                  'N', decode(original_subinventory,
                                                                              p_attributes_rec.subinventory, subinventory,
                                                                              p_attributes_rec.subinventory),
                                                                  subinventory),
                                                       subinventory),
                                          'C', subinventory,
              -- Bug 7665338:For Non-Inventory items,when Subinventory is changed in Order lines, it should be reflected on delivery details.
                                          'X',  decode(subinventory,
                                                        NULL,decode(p_attributes_rec.subinventory,FND_API.G_MISS_CHAR,subinventory,p_attributes_rec.subinventory),
                                                        subinventory),
                                          --bug 8995849:Modified decode statement such that for non-reservable items,when Warehouse is modified on
                                          --            Order lines,Subinventory should be updated on WDD
                                          decode(l_reservable_flag,
                                                 'N',decode(l_change_sub,'Y',p_attributes_rec.subinventory,
                                                             decode(original_subinventory,
                                                             p_attributes_rec.subinventory, subinventory,
                                                             p_attributes_rec.subinventory)),
                                                 p_attributes_rec.subinventory))),

             original_subinventory = decode(p_attributes_rec.subinventory,
                                            FND_API.G_MISS_CHAR, original_subinventory,
                                            decode (released_status,
                                                    'C', original_subinventory,
                                                    p_attributes_rec.subinventory)),

             source_line_number = decode ( p_attributes_rec.line_number, FND_API.G_MISS_CHAR ,
                                  source_line_number , p_attributes_rec.line_number ) ,
             master_container_item_id = decode ( p_attributes_rec.master_container_item_id, FND_API.G_MISS_NUM ,
                                  master_container_item_id , p_attributes_rec.master_container_item_id ) ,
             detail_container_item_id = decode ( p_attributes_rec.detail_container_item_id, FND_API.G_MISS_NUM ,
                                  detail_container_item_id , p_attributes_rec.detail_container_item_id ) ,
             ship_method_code = decode ( l_ship_method_code, FND_API.G_MISS_CHAR ,
                                  ship_method_code , l_ship_method_code ) ,
             mode_of_transport = decode ( l_mode_of_transport, FND_API.G_MISS_CHAR ,
                                  mode_of_transport , l_mode_of_transport ) ,
             service_level = decode ( l_service_level, FND_API.G_MISS_CHAR ,
                                  service_level , l_service_level ) ,
             carrier_id = decode ( l_carrier_id, FND_API.G_MISS_NUM ,
                                  carrier_id , l_carrier_id ) ,
             freight_terms_code = decode ( p_attributes_rec.freight_terms_code, FND_API.G_MISS_CHAR ,
                                  freight_terms_code , p_attributes_rec.freight_terms_code ) ,
             fob_code = decode ( p_attributes_rec.fob_code, FND_API.G_MISS_CHAR ,
                                  fob_code , p_attributes_rec.fob_code ) ,
             customer_item_id = decode ( p_attributes_rec.customer_item_id, FND_API.G_MISS_NUM ,
                                  customer_item_id , p_attributes_rec.customer_item_id ) ,
             top_model_line_id = decode ( p_attributes_rec.top_model_line_id, FND_API.G_MISS_NUM ,
                                  top_model_line_id , p_attributes_rec.top_model_line_id ) ,
             hold_code = decode ( p_attributes_rec.hold_code, FND_API.G_MISS_CHAR ,
                                  hold_code , p_attributes_rec.hold_code ) ,
             inspection_flag = decode ( p_attributes_rec.inspection_flag, FND_API.G_MISS_CHAR ,
                                  inspection_flag , p_attributes_rec.inspection_flag ) ,
             src_requested_quantity = decode ( l_oke_full_cancel_flag, 'Y',               -- 5870774, Bypass for Non-Canceled dds
                                      src_requested_quantity,
                                      decode ( p_attributes_rec.ordered_quantity, FND_API.G_MISS_NUM ,
                                      src_requested_quantity , p_attributes_rec.ordered_quantity )) ,
             src_requested_quantity_uom = decode ( p_attributes_rec.order_quantity_uom, FND_API.G_MISS_CHAR ,
                                  src_requested_quantity_uom , p_attributes_rec.order_quantity_uom ) ,
             src_requested_quantity2 = decode ( p_attributes_rec.ordered_quantity2, FND_API.G_MISS_NUM ,
                                  src_requested_quantity2 , p_attributes_rec.ordered_quantity2 ) ,
             src_requested_quantity_uom2 = decode ( p_attributes_rec.ordered_quantity_uom2, FND_API.G_MISS_CHAR ,
                                  src_requested_quantity_uom2 , p_attributes_rec.ordered_quantity_uom2 ) ,
             attribute_category = decode ( p_attributes_rec.attribute_category, FND_API.G_MISS_CHAR ,
                          attribute_category , p_attributes_rec.attribute_category ) ,
             attribute1 = decode ( p_attributes_rec.attribute1, FND_API.G_MISS_CHAR ,
                          attribute1 , p_attributes_rec.attribute1 ) ,
             attribute2 = decode ( p_attributes_rec.attribute2, FND_API.G_MISS_CHAR ,
                          attribute2 , p_attributes_rec.attribute2 ) ,
             attribute3 = decode ( p_attributes_rec.attribute3, FND_API.G_MISS_CHAR ,
                          attribute3 , p_attributes_rec.attribute3 ) ,
             attribute4 = decode ( p_attributes_rec.attribute4, FND_API.G_MISS_CHAR ,
                          attribute4 , p_attributes_rec.attribute4 ) ,
             attribute5 = decode ( p_attributes_rec.attribute5, FND_API.G_MISS_CHAR ,
                          attribute5 , p_attributes_rec.attribute5 ) ,
             attribute6 = decode ( p_attributes_rec.attribute6, FND_API.G_MISS_CHAR ,
                          attribute6 , p_attributes_rec.attribute6 ) ,
             attribute7 = decode ( p_attributes_rec.attribute7, FND_API.G_MISS_CHAR ,
                          attribute7 , p_attributes_rec.attribute7 ) ,
             attribute8 = decode ( p_attributes_rec.attribute8, FND_API.G_MISS_CHAR ,
                          attribute8 , p_attributes_rec.attribute8 ) ,
             attribute9 = decode ( p_attributes_rec.attribute9, FND_API.G_MISS_CHAR ,
                          attribute9 , p_attributes_rec.attribute9 ) ,
             attribute10 = decode ( p_attributes_rec.attribute10, FND_API.G_MISS_CHAR ,
                           attribute10 , p_attributes_rec.attribute10 ) ,
             attribute11 = decode ( p_attributes_rec.attribute11, FND_API.G_MISS_CHAR ,
                           attribute11 , p_attributes_rec.attribute11 ) ,
             attribute12 = decode ( p_attributes_rec.attribute12, FND_API.G_MISS_CHAR ,
                           attribute12 , p_attributes_rec.attribute12 ) ,
             attribute13 = decode ( p_attributes_rec.attribute13, FND_API.G_MISS_CHAR ,
                           attribute13 , p_attributes_rec.attribute13 ) ,
             attribute14 = decode ( p_attributes_rec.attribute14, FND_API.G_MISS_CHAR ,
                           attribute14 , p_attributes_rec.attribute14 ) ,
             attribute15 = decode ( p_attributes_rec.attribute15, FND_API.G_MISS_CHAR ,
                           attribute15 , p_attributes_rec.attribute15 ),
             cancelled_quantity = decode ( p_attributes_rec.cancelled_quantity, FND_API.G_MISS_NUM ,
                           cancelled_quantity , p_attributes_rec.cancelled_quantity ),
             cancelled_quantity2 = decode ( p_attributes_rec.cancelled_quantity2, FND_API.G_MISS_NUM ,
                          cancelled_quantity2 , p_attributes_rec.cancelled_quantity2 ) ,
             classification = decode ( p_attributes_rec.classification, FND_API.G_MISS_CHAR ,
                          classification , p_attributes_rec.classification ) ,
             commodity_code_cat_id = decode ( p_attributes_rec.commodity_code_cat_id, FND_API.G_MISS_NUM ,
                          commodity_code_cat_id , p_attributes_rec.commodity_code_cat_id ) ,
             container_flag = decode ( p_attributes_rec.container_flag, FND_API.G_MISS_CHAR ,
                          container_flag , p_attributes_rec.container_flag ) ,
             container_name = decode ( p_attributes_rec.container_name, FND_API.G_MISS_CHAR ,
                          container_name , p_attributes_rec.container_name ) ,
             container_type_code = decode ( p_attributes_rec.container_type_code, FND_API.G_MISS_CHAR ,
                          container_type_code , p_attributes_rec.container_type_code ) ,
             country_of_origin = decode ( p_attributes_rec.country_of_origin, FND_API.G_MISS_CHAR ,
                          country_of_origin , p_attributes_rec.country_of_origin ) ,
             delivered_quantity = decode ( p_attributes_rec.delivered_quantity, FND_API.G_MISS_NUM ,
                          delivered_quantity , p_attributes_rec.delivered_quantity ) ,
             delivered_quantity2 = decode ( p_attributes_rec.delivered_quantity2, FND_API.G_MISS_NUM ,
                          delivered_quantity2 , p_attributes_rec.delivered_quantity2 ) ,
             fill_percent = decode ( p_attributes_rec.fill_percent, FND_API.G_MISS_NUM ,
                           fill_percent , p_attributes_rec.fill_percent ) ,
             freight_class_cat_id = decode ( p_attributes_rec.freight_class_cat_id, FND_API.G_MISS_NUM ,
                           freight_class_cat_id , p_attributes_rec.freight_class_cat_id ) ,
       -- Bug 3125768: Checking for l_pickable_flag to update the inv_interfaced_flag
             inv_interfaced_flag = decode (inv_interfaced_flag, 'Y',
               decode ( p_attributes_rec.inv_interfaced_flag, FND_API.G_MISS_CHAR ,
                               inv_interfaced_flag , p_attributes_rec.inv_interfaced_flag ) ,
             decode (l_pickable_flag, 'N', 'X', 'N')
             ),
             inventory_item_id = decode ( p_attributes_rec.inventory_item_id, FND_API.G_MISS_NUM ,
                           inventory_item_id , p_attributes_rec.inventory_item_id ),
             --bug#6407943 (begin) :Needs to change items org dependent attributes when org changes
             item_description = decode(l_change_item_desc,'Y',l_item_description,
                                         decode (p_attributes_rec.item_description, FND_API.G_MISS_CHAR ,
                                                   item_description , p_attributes_rec.item_description )),
             requested_quantity_uom = decode (l_change_req_quantity_uom,'Y',l_primary_uom_code,
                                               requested_quantity_uom) ,
             unit_weight        = decode(l_change_unit_weight,'Y',l_unit_weight,unit_weight),
             unit_volume        = decode (l_change_unit_volume,'Y',l_unit_volume,unit_volume),
             net_weight = decode(l_change_weight,'Y',requested_quantity * decode(l_change_unit_weight,'Y',l_unit_weight,unit_weight),
                                 decode ( p_attributes_rec.net_weight, FND_API.G_MISS_NUM ,
                                          net_weight , p_attributes_rec.net_weight )) ,
             gross_weight = decode(l_change_weight,'Y',requested_quantity * decode(l_change_unit_weight,'Y',l_unit_weight,unit_weight),
                                  decode ( p_attributes_rec.gross_weight, FND_API.G_MISS_NUM ,
                                           gross_weight , p_attributes_rec.gross_weight )) ,
             weight_uom_code = decode(l_change_weight_uom,'Y',l_weight_uom,decode ( p_attributes_rec.weight_uom_code, FND_API.G_MISS_CHAR ,
                          weight_uom_code , p_attributes_rec.weight_uom_code )) ,
             volume = decode(l_change_volume,'Y', requested_quantity * decode (l_change_unit_volume,'Y',l_unit_volume,unit_volume),
                               decode ( p_attributes_rec.volume, FND_API.G_MISS_NUM ,
                                        volume , p_attributes_rec.volume )) ,
             volume_uom_code = decode(l_change_volume_uom,'Y',l_volume_uom,decode ( p_attributes_rec.volume_uom_code, FND_API.G_MISS_CHAR ,
                                   volume_uom_code , p_attributes_rec.volume_uom_code )) ,
             hazard_class_id = decode(l_change_haz_class_id,'Y',l_haz_class_id,
                               decode( p_attributes_rec.hazard_class_id, FND_API.G_MISS_NUM ,
                           hazard_class_id , p_attributes_rec.hazard_class_id)),
             --bug#6407943 (end):Needs to change items org dependent attributes when org changes.
             load_seq_number = decode ( p_attributes_rec.load_seq_number, FND_API.G_MISS_NUM ,
                          load_seq_number , p_attributes_rec.load_seq_number ) ,
             lpn_id = decode ( p_attributes_rec.lpn_id, FND_API.G_MISS_NUM ,
                          lpn_id , p_attributes_rec.lpn_id ) ,
             maximum_load_weight = decode ( p_attributes_rec.maximum_load_weight, FND_API.G_MISS_NUM ,
                          maximum_load_weight , p_attributes_rec.maximum_load_weight ) ,
             maximum_volume = decode ( p_attributes_rec.maximum_volume, FND_API.G_MISS_NUM ,
                          maximum_volume , p_attributes_rec.maximum_volume ) ,
             minimum_fill_percent = decode ( p_attributes_rec.minimum_fill_percent, FND_API.G_MISS_NUM ,
                          minimum_fill_percent , p_attributes_rec.minimum_fill_percent ) ,
             move_order_line_id = decode ( p_attributes_rec.move_order_line_id, FND_API.G_MISS_NUM ,
                          move_order_line_id, p_attributes_rec.move_order_line_id ) ,
             movement_id = decode ( p_attributes_rec.movement_id, FND_API.G_MISS_NUM ,
                           movement_id , p_attributes_rec.movement_id ) ,
             mvt_stat_status = decode ( p_attributes_rec.mvt_stat_status, FND_API.G_MISS_CHAR ,
                           mvt_stat_status , p_attributes_rec.mvt_stat_status ) ,
             oe_interfaced_flag = decode ( p_attributes_rec.oe_interfaced_flag, FND_API.G_MISS_CHAR ,
                           oe_interfaced_flag , p_attributes_rec.oe_interfaced_flag ) ,
             org_id = decode ( p_attributes_rec.org_id, FND_API.G_MISS_NUM ,
                           org_id , p_attributes_rec.org_id ) ,
       -- Bug 3125768: changed pickable_flag to l_pickable_flag
             pickable_flag = decode ( p_attributes_rec.pickable_flag, FND_API.G_MISS_CHAR ,
                                      l_pickable_flag , p_attributes_rec.pickable_flag ) ,
             picked_quantity = decode ( p_attributes_rec.picked_quantity, FND_API.G_MISS_NUM ,
                           picked_quantity , p_attributes_rec.picked_quantity ),
             picked_quantity2 = decode ( p_attributes_rec.picked_quantity2, FND_API.G_MISS_NUM ,
                           picked_quantity2 , p_attributes_rec.picked_quantity2 ),
             project_id = decode ( p_attributes_rec.project_id, FND_API.G_MISS_NUM ,
                          project_id , p_attributes_rec.project_id ) ,
             quality_control_quantity = decode ( p_attributes_rec.quality_control_quantity, FND_API.G_MISS_NUM ,
                          quality_control_quantity , p_attributes_rec.quality_control_quantity ) ,
             quality_control_quantity2 = decode ( p_attributes_rec.quality_control_quantity2, FND_API.G_MISS_NUM ,
                          quality_control_quantity2 , p_attributes_rec.quality_control_quantity2 ) ,
             received_quantity = decode ( p_attributes_rec.received_quantity, FND_API.G_MISS_NUM ,
                          received_quantity , p_attributes_rec.received_quantity ) ,
             received_quantity2 = decode ( p_attributes_rec.received_quantity2, FND_API.G_MISS_NUM ,
                          received_quantity2 , p_attributes_rec.received_quantity2 ) ,
             request_id = decode ( p_attributes_rec.request_id, FND_API.G_MISS_NUM ,
                          request_id , p_attributes_rec.request_id ) ,
             seal_code = decode ( p_attributes_rec.seal_code, FND_API.G_MISS_CHAR ,
                          seal_code , p_attributes_rec.seal_code ) ,
             source_code = decode ( p_attributes_rec.source_code, FND_API.G_MISS_CHAR ,
                          source_code , p_attributes_rec.source_code ),
             source_header_id = decode ( p_attributes_rec.source_header_id, FND_API.G_MISS_NUM ,
                          source_header_id , p_attributes_rec.source_header_id ) ,
             source_header_number = decode ( p_attributes_rec.source_header_number, FND_API.G_MISS_CHAR ,
                          source_header_number , p_attributes_rec.source_header_number ) ,
             source_header_type_id = decode ( p_attributes_rec.source_header_type_id, FND_API.G_MISS_NUM ,
                          source_header_type_id , p_attributes_rec.source_header_type_id ) ,
             source_header_type_name = decode ( p_attributes_rec.source_header_type_name, FND_API.G_MISS_CHAR ,
                           source_header_type_name , p_attributes_rec.source_header_type_name ) ,
             source_line_id = decode ( p_attributes_rec.source_line_id, FND_API.G_MISS_NUM ,
                           source_line_id , p_attributes_rec.source_line_id ) ,
             source_line_set_id = decode ( p_attributes_rec.source_line_set_id, FND_API.G_MISS_NUM ,
                           source_line_set_id , p_attributes_rec.source_line_set_id ) ,
             split_from_delivery_detail_id = decode (p_attributes_rec.split_from_delivery_detail_id, FND_API.G_MISS_NUM,
                           split_from_delivery_detail_id , p_attributes_rec.split_from_delivery_detail_id ) ,
             task_id = decode ( p_attributes_rec.task_id, FND_API.G_MISS_NUM ,
                           task_id , p_attributes_rec.task_id ) ,
             to_serial_number = decode ( p_attributes_rec.to_serial_number, FND_API.G_MISS_CHAR ,
                           to_serial_number , p_attributes_rec.to_serial_number ) ,
             tp_attribute1 = decode ( p_attributes_rec.tp_attribute1, FND_API.G_MISS_CHAR ,
                           tp_attribute1 , p_attributes_rec.tp_attribute1 ),
             tp_attribute10 = decode ( p_attributes_rec.tp_attribute10, FND_API.G_MISS_CHAR ,
                          tp_attribute10 , p_attributes_rec.tp_attribute10 ) ,
             tp_attribute11 = decode ( p_attributes_rec.tp_attribute11, FND_API.G_MISS_CHAR ,
                          tp_attribute11 , p_attributes_rec.tp_attribute11 ) ,
             tp_attribute12 = decode ( p_attributes_rec.tp_attribute12, FND_API.G_MISS_CHAR ,
                          tp_attribute12 , p_attributes_rec.tp_attribute12 ) ,
             tp_attribute13 = decode ( p_attributes_rec.tp_attribute13, FND_API.G_MISS_CHAR ,
                          tp_attribute13 , p_attributes_rec.tp_attribute13 ) ,
             tp_attribute14 = decode ( p_attributes_rec.tp_attribute14, FND_API.G_MISS_CHAR ,
                          tp_attribute14 , p_attributes_rec.tp_attribute14 ) ,
             tp_attribute15 = decode ( p_attributes_rec.tp_attribute15, FND_API.G_MISS_CHAR ,
                          tp_attribute15 , p_attributes_rec.tp_attribute15 ) ,
             tp_attribute2 = decode ( p_attributes_rec.tp_attribute2, FND_API.G_MISS_CHAR ,
                          tp_attribute2 , p_attributes_rec.tp_attribute2 ) ,
             tp_attribute3 = decode ( p_attributes_rec.tp_attribute3, FND_API.G_MISS_CHAR ,
                          tp_attribute3 , p_attributes_rec.tp_attribute3 ) ,
             tp_attribute4 = decode ( p_attributes_rec.tp_attribute4, FND_API.G_MISS_CHAR ,
                           tp_attribute4 , p_attributes_rec.tp_attribute4 ) ,
             tp_attribute5 = decode ( p_attributes_rec.tp_attribute5, FND_API.G_MISS_CHAR ,
                           tp_attribute5 , p_attributes_rec.tp_attribute5 ) ,
             tp_attribute6 = decode ( p_attributes_rec.tp_attribute6, FND_API.G_MISS_CHAR ,
                           tp_attribute6 , p_attributes_rec.tp_attribute6 ) ,
             tp_attribute7 = decode ( p_attributes_rec.tp_attribute7, FND_API.G_MISS_CHAR ,
                           tp_attribute7 , p_attributes_rec.tp_attribute7 ) ,
             tp_attribute8 = decode ( p_attributes_rec.tp_attribute8, FND_API.G_MISS_CHAR ,
                           tp_attribute8 , p_attributes_rec.tp_attribute8 ) ,
             tp_attribute9 = decode ( p_attributes_rec.tp_attribute9, FND_API.G_MISS_CHAR ,
                           tp_attribute9 , p_attributes_rec.tp_attribute9 ),
             tp_attribute_category = decode ( p_attributes_rec.tp_attribute_category, FND_API.G_MISS_CHAR ,
                          tp_attribute_category , p_attributes_rec.tp_attribute_category ) ,
             transaction_temp_id = decode ( p_attributes_rec.transaction_temp_id, FND_API.G_MISS_NUM ,
                          transaction_temp_id , p_attributes_rec.transaction_temp_id ) ,
             unit_number = decode ( p_attributes_rec.unit_number, FND_API.G_MISS_CHAR ,
                          unit_number , p_attributes_rec.unit_number ) ,
             unit_price = decode ( p_attributes_rec.unit_price, FND_API.G_MISS_NUM ,
                          unit_price , p_attributes_rec.unit_price ),
             /* J TP Release */
             earliest_pickup_date  = decode(tpdates_changed, 'N' ,
                                         to_date(to_char(earliest_pickup_date,'mm-dd-yy HH24:MI:SS'),'mm-dd-yy HH24:MI:SS')
										 , p_changed_detail.earliest_pickup_date ),
             latest_pickup_date    = decode(tpdates_changed, 'N' ,
                                         to_date(to_char(latest_pickup_date,'mm-dd-yy HH24:MI:SS'),'mm-dd-yy HH24:MI:SS')
										 , p_changed_detail.latest_pickup_date ),
             earliest_dropoff_date = decode(tpdates_changed, 'N' ,
                                         to_date(to_char(earliest_dropoff_date,'mm-dd-yy HH24:MI:SS'),'mm-dd-yy HH24:MI:SS')
										 , p_changed_detail.earliest_dropoff_date ),
             latest_dropoff_date   = decode(tpdates_changed, 'N' ,
                                         to_date(to_char(latest_dropoff_date,'mm-dd-yy HH24:MI:SS'),'mm-dd-yy HH24:MI:SS')
										, p_changed_detail.latest_dropoff_date),
             --OTM R12 Org-Specific ( Changes made for update to ignore_for_planning column ).
             --Update the field only if organization_id is changed.
             ignore_for_planning   = decode(organization_id, l_orgid, ignore_for_planning,
                                           nvl(l_ignore_for_planning,nvl(ignore_for_planning,'N'))),
      -- Bug 3244272 : Added laste_update_date and last_updated_by in the
      -- update statement.
             last_update_date = SYSDATE,
             last_updated_by =  FND_GLOBAL.USER_ID,
             last_update_login = FND_GLOBAL.LOGIN_ID
      WHERE  source_code    = p_source_code
      AND    source_line_id = p_attributes_rec.source_line_id
      AND    container_flag = 'N'
      AND    delivery_detail_id = decode( p_attributes_rec.delivery_detail_id, FND_API.G_MISS_NUM ,
                                  delivery_detail_id, p_attributes_rec.delivery_detail_id );

   /* H projects: pricing integration csun */

   IF (p_attributes_rec.gross_weight IS NOT NULL)
      AND (p_attributes_rec.gross_weight <> FND_API.G_MISS_NUM) THEN
        l_mark_reprice_flag := 'Y';
   ELSIF   (p_attributes_rec.net_weight IS NOT NULL)
      AND (p_attributes_rec.net_weight <> FND_API.G_MISS_NUM) THEN
        l_mark_reprice_flag := 'Y';
   ELSIF   (p_attributes_rec.volume IS NOT NULL)
      AND (p_attributes_rec.volume <> FND_API.G_MISS_NUM) THEN
        l_mark_reprice_flag := 'Y';
   ELSIF   (p_attributes_rec.volume_uom_code IS NOT NULL)
      AND (p_attributes_rec.volume_uom_code <> FND_API.G_MISS_CHAR) THEN
        l_mark_reprice_flag := 'Y';
   ELSIF   (p_attributes_rec.weight_uom_code IS NOT NULL)
      AND (p_attributes_rec.weight_uom_code <> FND_API.G_MISS_CHAR) THEN
        l_mark_reprice_flag := 'Y';
   ELSIF   (p_attributes_rec.subinventory IS NOT NULL)
      AND (p_attributes_rec.subinventory <> FND_API.G_MISS_CHAR) THEN
        l_mark_reprice_flag := 'Y';
   ELSIF   (p_attributes_rec.ship_from_org_id IS NOT NULL)
      AND (p_attributes_rec.ship_from_org_id <> FND_API.G_MISS_NUM) THEN
        l_mark_reprice_flag := 'Y';
   ELSIF   (p_attributes_rec.ship_to_org_id IS NOT NULL)
      AND (p_attributes_rec.ship_to_org_id <> FND_API.G_MISS_NUM) THEN
        l_mark_reprice_flag := 'Y';
   ELSIF   (p_attributes_rec.deliver_to_org_id IS NOT NULL)
      AND (p_attributes_rec.deliver_to_org_id <> FND_API.G_MISS_NUM) THEN
        l_mark_reprice_flag := 'Y';
   ELSIF   (p_attributes_rec.intmed_ship_to_org_id IS NOT NULL)
      AND (p_attributes_rec.intmed_ship_to_org_id <> FND_API.G_MISS_NUM) THEN
        l_mark_reprice_flag := 'Y';
   END IF;
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_mark_reprice_flag',l_mark_reprice_flag);
   END IF;

   /* 4410272
   FOR cur in c_get_delivery_detail_id LOOP
      l_details_marked(l_details_marked.COUNT+1) := cur.delivery_detail_id;
   END LOOP;
*/
   IF l_mark_reprice_flag = 'Y' THEN
     IF l_details_marked.count > 0 THEN
      --
      WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
         p_entity_type => 'DELIVERY_DETAIL',
         p_entity_ids   => l_details_marked,
         x_return_status => l_return_status);
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         raise mark_reprice_error;
      END IF;
    END IF;
   END IF;

   -- Added for bug 4410272
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'TP Details count', l_tp_details.count);
   END IF;
   --
   -- IF condition added for bug 4410272
   IF ( l_tp_details.COUNT > 0 )
   THEN
   -- {
      WSH_TP_RELEASE.calculate_cont_del_tpdates(
           p_entity        => 'DLVB',
           p_entity_ids    => l_tp_details,
           x_return_status => l_return_status);
   -- }
      IF (l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
        WSH_INTERFACE.PrintMsg(name=>'WSH_CALC_CONT_DEL_TPDATES',
                       txt=>'Error in calculating Container/Delivery TP dates ');
         IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Error in calculating Container/Delivery TP dates ');
         END IF;
      END IF;
    END IF;
   --
   -- DBI Project
   -- Update of wsh_delivery_details where requested_quantity/released_status
   -- are changed, call DBI API after the update.
   -- This API will also check for DBI Installed or not
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Calling DBI API delivery details l_details_marked count :',l_details_marked.COUNT);
   END IF;
   WSH_INTEGRATION.DBI_Update_Detail_Log
     (p_delivery_detail_id_tab => l_details_marked,
      p_dml_type               => 'UPDATE',
      x_return_status          => l_dbi_rs);

   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
   END IF;
   IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_dbi_rs;
      ROLLBACK to before_changes;
      -- just pass this return status to caller API
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;
   END IF;
  -- End of Code for DBI Project
  --
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
     WHEN mark_reprice_error then
    FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
    x_return_status := l_return_status;
    WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
    END IF;
    --
      WHEN Update_Failed THEN
         FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_LOCATION');
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UPDATE_FAILED');
          END IF;
          --
      WHEN others THEN
         IF c_is_reservable%ISOPEN THEN
           CLOSE c_is_reservable;
         END IF;
         --
         ROLLBACK TO before_changes;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         wsh_util_core.default_handler('WSH_USA_ACTIONS.Update_Attributes',l_module_name);
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
         --
END Update_Attributes;



PROCEDURE Import_Delivery_Details(
  p_source_line_id    IN   NUMBER,
  p_source_code       IN   VARCHAR2,
  x_return_status     OUT NOCOPY   VARCHAR2)
IS
  CURSOR C_specific_item_info(c_p_inventory_item_id number,
                              c_p_organization_id number)
  IS
  SELECT hazard_class_id, primary_uom_code, weight_uom_code,
   unit_weight, volume_uom_code, unit_volume , decode(mtl_transactions_enabled_flag,'Y','Y','N')
  FROM mtl_system_items m
  WHERE m.inventory_item_id = c_p_inventory_item_id
  AND   m.organization_id = c_p_organization_id;

-- Bug 2995052 : Treating the Back Order delivery detail lines also as not released lines.
-- Bug 2896605 : Remove restriction on adding lines with different released status' to the
--               same ship set.
--  CURSOR c_check_ship_sets is defined in the spec

  l_ship_set_id NUMBER;
  haz_class_id number;
  prim_uom_code varchar2(3);
  transactable_flag varchar2(1);
  weight_uom varchar2(3);
  unit_weight number;
  volume_uom varchar2(3);
  unit_volume number;
  invalid_qty_or_uom exception;

  create_details_failed exception;
  create_assignments_failed exception;
  process_order_failed exception;
  invalid_source_code exception;
  l_cr_dt_summary varchar2(3000);
  l_cr_dt_details varchar2(3000);
  l_cr_dt_count number;
  l_cr_as_summary varchar2(3000);
  l_cr_as_details varchar2(3000);
  l_cr_as_count number;
i number;
  l_return_status varchar2(30);
  l_msg_data varchar2(4000);
  l_msg_count number;
  l_ship_from_location_id number;
  l_ship_from_location_id1 number;
  l_ship_to_location_id number;
  l_ship_to_location_id1 number;
  l_deliver_to_location_id number;
  l_deliver_to_location_id1 number;
  l_intmed_ship_to_location_id number;
  l_intmed_ship_to_location_id1 number;
  l_location_status varchar2(30);
  l_line_rec                  OE_ORDER_PUB.line_rec_type;
  l_line_tbl                  OE_ORDER_PUB.Line_Tbl_Type;
  l_control_rec               OE_GLOBALS.control_rec_type;
  l_header_out_rec            OE_ORDER_PUB.Header_Rec_Type;
  l_line_out_tbl              OE_ORDER_PUB.Line_Tbl_Type;
  l_line_adj_out_tbl          oe_order_pub.line_Adj_Tbl_Type;
  l_header_adj_out_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
  l_Header_Scredit_out_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
  l_Line_Scredit_out_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
  l_action_request_out_tbl    OE_Order_PUB.request_Tbl_type;
  l_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
  l_header_val_rec            OE_Order_PUB.header_val_rec_type;
  l_header_adj_val_tbl        OE_Order_PUB.header_adj_val_tbl_type;
  l_Line_Scredit_val_tbl      OE_Order_PUB.Line_Scredit_val_Tbl_Type;
  l_line_val_tbl              OE_ORDER_PUB.Line_val_Tbl_Type;
  l_line_adj_val_tbl          oe_order_pub.line_Adj_val_Tbl_Type;
  l_Lot_Serial_val_tbl        OE_Order_PUB.Lot_Serial_val_Tbl_Type;
  l_header_Scredit_val_tbl    OE_Order_PUB.header_Scredit_val_Tbl_Type;
  l_line_index    NUMBER := 0;
  l_summary varchar2(3000);
  l_details varchar2(3000);
  l_get_msg_count number;
  invalid_org exception;
  invalid_cust_site exception;
  invalid_ship_set exception;
-- HW OPM BUG#:2677054
-- HW OPMCONV. Removed OPM variables

-- HW end of 2677054
  l_cr_dt_status varchar2(30);
  dummy_assgn_rowid varchar2(30);
  dummy_delivery_assignment_id number;
  l_cr_as_status varchar2(30);
  k number;

-- odaboval : Begin of OPM Changes

  l_transfer_qty                   NUMBER(19,9);
-- 2654051:  Exception (if any) raised for Booked lines
  l_booked_ln_excpn    BOOLEAN;

/* HW OPMCOMV - No need to get OPM item info
  CURSOR C_GET_OPM_LOT_ID(c_opm_item_id NUMBER,
                        c_opm_lot_number VARCHAR2,
                        c_opm_sublot_number VARCHAR2)
  IS
  SELECT lot_id
  FROM ic_lots_mst
  WHERE item_id = c_opm_item_id
  AND lot_no = c_opm_lot_number
  AND sublot_no = c_opm_sublot_number;
  -- odaboval : End of OPM Changes
*/

  -- performance bug 4891897 : high Sharable Memory usage (1,472,182)
  -- divide the cursor into two and use the appropriate one

  -- columns/views must be in sync with C_PULL_ONE_LINE

  CURSOR C_PULL_DELIVERY_DETAILS is
  SELECT
    HEADER_ID,
    HEADER_NUMBER,
    HEADER_TYPE_ID,
    HEADER_TYPE_NAME,
    LINE_ID,
    LINE_NUMBER,
    ORG_ID,
    SOLD_TO_ORG_ID,
    INVENTORY_ITEM_ID,
    ITEM_DESCRIPTION,
    SHIP_FROM_ORG_ID,
    SUBINVENTORY,
    SHIP_TO_ORG_ID,
    DELIVER_TO_ORG_ID,
    SHIP_TO_CONTACT_ID,
    DELIVER_TO_CONTACT_ID,
    INTMED_SHIP_TO_ORG_ID,
    INTMED_SHIP_TO_CONTACT_ID,
    SHIP_TOLERANCE_ABOVE,
    SHIP_TOLERANCE_BELOW,
    ORDERED_QUANTITY,
    SHIPPED_QUANTITY,
    DELIVERED_QUANTITY,
    ORDER_QUANTITY_UOM,
    SHIPPING_QUANTITY_UOM,
    SHIPPING_QUANTITY,
    DATE_SCHEDULED,
    SHIPPING_METHOD_CODE,
    FREIGHT_CARRIER_CODE,
    FREIGHT_TERMS_CODE,
    SHIPMENT_PRIORITY_CODE,
    FOB_CODE,
    ITEM_IDENTIFIER_TYPE,
    ORDERED_ITEM_ID,
    DATE_REQUESTED,
    DEP_PLAN_REQUIRED_FLAG,
    CUSTOMER_PROD_SEQ_NUMBER,
    CUSTOMER_DOCK_CODE,
    SHIPPING_INTERFACED_FLAG,
    SHIP_SET_ID,
    ATO_LINE_ID,
    SHIP_MODEL_COMPLETE_FLAG,
    TOP_MODEL_LINE_ID,
    ITEM_TYPE_CODE,
    CUST_PO_NUMBER,
    ARRIVAL_SET_ID,
    SOURCE_TYPE_CODE,
    LINE_TYPE_ID,
    PROJECT_ID,
    TASK_ID,
    SHIPPING_INSTRUCTIONS,
    PACKING_INSTRUCTIONS,
    MASTER_CONTAINER_ITEM_ID,
    DETAIL_CONTAINER_ITEM_ID,
    PREFERRED_GRADE,
    ORDERED_QUANTITY2,
    ORDERED_QUANTITY_UOM2,
    UNIT_LIST_PRICE,
    TRANSACTIONAL_CURR_CODE,
    END_ITEM_UNIT_NUMBER,
    TP_CONTEXT,
    TP_ATTRIBUTE1,
    TP_ATTRIBUTE2,
    TP_ATTRIBUTE3,
    TP_ATTRIBUTE4,
    TP_ATTRIBUTE5,
    TP_ATTRIBUTE6,
    TP_ATTRIBUTE7,
    TP_ATTRIBUTE8,
    TP_ATTRIBUTE9,
    TP_ATTRIBUTE10,
    TP_ATTRIBUTE11,
    TP_ATTRIBUTE12,
    TP_ATTRIBUTE13,
    TP_ATTRIBUTE14,
    TP_ATTRIBUTE15,
    SOLD_TO_CONTACT_ID,
    CUSTOMER_JOB,
    CUSTOMER_PRODUCTION_LINE,
    CUST_MODEL_SERIAL_NUMBER,
    LINE_SET_ID,
/* J TP Release */
    latest_acceptable_date,
    promise_date,
    schedule_arrival_date,
    earliest_acceptable_date,
    earliest_ship_date,  --equivalent of demand_satisfaction_date in TP
    order_date_type_code,
    source_document_type_id
  from oe_delivery_lines_v
  where  ship_from_org_id is not NULL
  and    order_quantity_uom is not NULL
  and    ordered_quantity is not NULL;

  -- columns/views must be in sync with C_PULL_DELIVERY_DETAILS

  CURSOR C_PULL_ONE_LINE is
  SELECT
    HEADER_ID,
    HEADER_NUMBER,
    HEADER_TYPE_ID,
    HEADER_TYPE_NAME,
    LINE_ID,
    LINE_NUMBER,
    ORG_ID,
    SOLD_TO_ORG_ID,
    INVENTORY_ITEM_ID,
    ITEM_DESCRIPTION,
    SHIP_FROM_ORG_ID,
    SUBINVENTORY,
    SHIP_TO_ORG_ID,
    DELIVER_TO_ORG_ID,
    SHIP_TO_CONTACT_ID,
    DELIVER_TO_CONTACT_ID,
    INTMED_SHIP_TO_ORG_ID,
    INTMED_SHIP_TO_CONTACT_ID,
    SHIP_TOLERANCE_ABOVE,
    SHIP_TOLERANCE_BELOW,
    ORDERED_QUANTITY,
    SHIPPED_QUANTITY,
    DELIVERED_QUANTITY,
    ORDER_QUANTITY_UOM,
    SHIPPING_QUANTITY_UOM,
    SHIPPING_QUANTITY,
    DATE_SCHEDULED,
    SHIPPING_METHOD_CODE,
    FREIGHT_CARRIER_CODE,
    FREIGHT_TERMS_CODE,
    SHIPMENT_PRIORITY_CODE,
    FOB_CODE,
    ITEM_IDENTIFIER_TYPE,
    ORDERED_ITEM_ID,
    DATE_REQUESTED,
    DEP_PLAN_REQUIRED_FLAG,
    CUSTOMER_PROD_SEQ_NUMBER,
    CUSTOMER_DOCK_CODE,
    SHIPPING_INTERFACED_FLAG,
    SHIP_SET_ID,
    ATO_LINE_ID,
    SHIP_MODEL_COMPLETE_FLAG,
    TOP_MODEL_LINE_ID,
    ITEM_TYPE_CODE,
    CUST_PO_NUMBER,
    ARRIVAL_SET_ID,
    SOURCE_TYPE_CODE,
    LINE_TYPE_ID,
    PROJECT_ID,
    TASK_ID,
    SHIPPING_INSTRUCTIONS,
    PACKING_INSTRUCTIONS,
    MASTER_CONTAINER_ITEM_ID,
    DETAIL_CONTAINER_ITEM_ID,
    PREFERRED_GRADE,
    ORDERED_QUANTITY2,
    ORDERED_QUANTITY_UOM2,
    UNIT_LIST_PRICE,
    TRANSACTIONAL_CURR_CODE,
    END_ITEM_UNIT_NUMBER,
    TP_CONTEXT,
    TP_ATTRIBUTE1,
    TP_ATTRIBUTE2,
    TP_ATTRIBUTE3,
    TP_ATTRIBUTE4,
    TP_ATTRIBUTE5,
    TP_ATTRIBUTE6,
    TP_ATTRIBUTE7,
    TP_ATTRIBUTE8,
    TP_ATTRIBUTE9,
    TP_ATTRIBUTE10,
    TP_ATTRIBUTE11,
    TP_ATTRIBUTE12,
    TP_ATTRIBUTE13,
    TP_ATTRIBUTE14,
    TP_ATTRIBUTE15,
    SOLD_TO_CONTACT_ID,
    CUSTOMER_JOB,
    CUSTOMER_PRODUCTION_LINE,
    CUST_MODEL_SERIAL_NUMBER,
    LINE_SET_ID,
    latest_acceptable_date,
    promise_date,
    schedule_arrival_date,
    earliest_acceptable_date,
    earliest_ship_date,
    order_date_type_code,
    source_document_type_id
  from oe_delivery_lines_v
  WHERE  line_id = p_source_line_id
  and    p_source_line_id IS NOT NULL
  and    ship_from_org_id is not NULL
  and    order_quantity_uom is not NULL
  and    ordered_quantity is not NULL;

  -- Bug: 1902176. Need to Lock the oe_line (Current Line fetched)
  -- otherwise it could result in Multiple Wsh_del_dtl records to be created
  -- for instance in Import Del. Details.

  CURSOR C_OE_LINES_REC_LOCK (c_line_id NUMBER) is
  SELECT line_id
  FROM   oe_order_lines_all
  --FROM   oe_delivery_lines_v
  WHERE  line_id = c_line_id
  and    nvl(shipping_interfaced_flag, 'N') = 'N'
  FOR UPDATE NOWAIT;

  ln_rec_info C_PULL_DELIVERY_DETAILS%ROWTYPE;

  l_delivery_details_info WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
  l_delivery_assignments_info WSH_DELIVERY_DETAILS_PKG.Delivery_assignments_rec_TYPE;
  dummy_rowid VARCHAR2(30);
  dummy_delivery_detail_id number;
  dummy_slid number;
  l_header_price_att_tbl        OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
  l_header_adj_assoc_tbl        OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
  l_header_adj_att_tbl          OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
  l_line_price_att_tbl          OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
  l_line_adj_assoc_tbl          OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
  l_line_adj_att_tbl            OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;

  l_wf_source_header_id NUMBER;
  l_wf_source_code VARCHAR2(30);
  l_wf_order_number NUMBER;
  l_wf_contact_type VARCHAR2(10);
  l_wf_contact_id NUMBER;
  l_result BOOLEAN;
  latest_pickup_tpdate_excep DATE;
  latest_dropoff_tpdate_excep DATE;

  CURSOR c_shipping_parameters(c_organization_id NUMBER) IS
  SELECT freight_class_cat_set_id, commodity_code_cat_set_id, enforce_ship_set_and_smc  --2373131
  FROM wsh_shipping_parameters
  WHERE organization_id = c_organization_id;

  l_ship_parameters c_shipping_parameters%ROWTYPE;

  cursor c_get_ship_set_name(c_set_id IN NUMBER) is --2373131
  select set_name
  from oe_sets
  where set_id = c_set_id;

  l_ship_set_name  VARCHAR2(30);

  CURSOR c_category_id( c_inventory_item_id NUMBER, c_organization_id NUMBER,
                      c_category_set_id NUMBER) IS
  SELECT category_id
  FROM mtl_item_categories
  WHERE inventory_item_id = c_inventory_item_id
  AND   organization_id = c_organization_id
  AND   category_set_id = c_category_set_id;

  l_freight_cl_cat_id          NUMBER;
  l_commodity_cat_id           NUMBER;
  l_oe_line_id_locked          NUMBER;   -- 1902176

  l_carrier_rec                  WSH_CARRIERS_GRP.Carrier_Service_InOut_Rec_Type;
  l_generic_flag VARCHAR2(1);
  l_service_level VARCHAR2(30);
  l_mode_of_transport VARCHAR2(30);
  l_carrier_id NUMBER;

  l_pull_lines_count NUMBER :=0;

  --OTM R12
  l_delivery_detail_tab		WSH_ENTITY_INFO_TAB;
  l_delivery_detail_rec		WSH_ENTITY_INFO_REC;
  l_item_quantity_uom_tab	WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_gc3_is_installed            VARCHAR2(1);
  --

  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'IMPORT_DELIVERY_DETAILS';
  --
BEGIN
   --
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
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
   END IF;
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --OTM R12, initialize
   l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;
   IF l_gc3_is_installed IS NULL THEN
     l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
   END IF;
   IF (l_gc3_is_installed = 'Y') THEN
     l_delivery_detail_tab := WSH_ENTITY_INFO_TAB();
     l_delivery_detail_tab.EXTEND;
   END IF;
   --

   i := 0;
   IF (P_SOURCE_CODE <> 'OE') THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_INVALID_SOURCE_CODE');
     FND_MESSAGE.SET_TOKEN('SOURCE_CODE', p_source_code);
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.add_message(x_return_status,l_module_name);
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN;
   END IF;

   -- 2654051
   l_booked_ln_excpn  := FALSE;

   -- bug 4891897
   IF p_source_line_id IS NULL THEN
     OPEN C_PULL_DELIVERY_DETAILS;
   ELSE
     OPEN C_PULL_ONE_LINE;
   END IF;

   LOOP
    <<start_over>>
    IF C_OE_LINES_REC_LOCK%ISOPEN THEN -- Bug 2410864
       CLOSE C_OE_LINES_REC_LOCK;
    END IF;

    -- 2680026
    IF ( l_booked_ln_excpn and p_source_line_id IS NOT NULL ) THEN
        raise create_details_failed;
    END IF;

    i := i + 1;

    IF p_source_line_id IS NULL THEN
      FETCH C_PULL_DELIVERY_DETAILS into ln_rec_info;
      EXIT WHEN C_PULL_DELIVERY_DETAILS%NOTFOUND; -- Bug 2410864
    ELSE
      FETCH C_PULL_ONE_LINE into ln_rec_info;
      EXIT WHEN C_PULL_ONE_LINE%NOTFOUND;
    END IF;
    --Added below IF condition to check whether the workflow has ship line activity or not --Bugfix 6740363
    IF p_source_line_id IS NULL AND NOT wf_engine.activity_exist_in_process('OEOL', to_char(ln_rec_info.line_id), 'OEOL', 'SHIP_LINE') THEN --{
      GOTO start_over;
    ELSE
   l_pull_lines_count := l_pull_lines_count + 1;

     -- Bug: 1902176. Need to Lock the oe_line (Current Line fetched)
    BEGIN  -- 1902176: Block to Lock Oe_line REcord and to TRap NO WAIT error
                   -- 1902176 :Requerying record - FOR UPDATE NOWAIT (locking this record)
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'line_id',ln_rec_info.line_id);
     END IF;
     OPEN C_OE_LINES_REC_LOCK( ln_rec_info.line_id);        -- 1902176
     FETCH C_OE_LINES_REC_LOCK  INTO l_oe_line_id_locked;   -- 1902176

      OPEN c_specific_item_info(ln_rec_info.inventory_item_id, ln_rec_info.ship_from_org_id);
      FETCH C_SPECIFIC_ITEM_INFO INTO haz_class_id, prim_uom_code, weight_uom, unit_weight,
                                      volume_uom, unit_volume, transactable_flag;
      CLOSE c_specific_item_info;
      WSH_INTERFACE.PrintMsg(txt=>'Importing order line ' || ln_rec_info.line_id);
      WSH_UTIL_CORE.GET_LOCATION_ID('ORG', ln_rec_info.ship_from_org_id,
                                    l_ship_from_location_id, l_location_status);

      IF (l_location_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Failed to get location for line: '||ln_rec_info.line_id||' org:'||ln_rec_info.ship_from_org_id);
            END IF;
            l_booked_ln_excpn  := TRUE;
            GOTO start_over;
      END IF;
   WSH_INTERFACE.PrintMsg(txt=>'From organization:'|| ln_rec_info.ship_from_org_id||' loc:'|| l_ship_from_location_id );

      WSH_UTIL_CORE.GET_LOCATION_ID('CUSTOMER SITE', ln_rec_info.ship_to_org_id,
                                    l_ship_to_location_id, l_location_status);
      IF (l_location_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      WSH_INTERFACE.PrintMsg(name=>'WSH_DET_NO_LOCATION_FOR_ORG',
         txt=>'Failed to get location for line: '||ln_rec_info.line_id||
                          ' ship to org:'||ln_rec_info.ship_to_org_id);
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Failed to get location for line: '||ln_rec_info.line_id|| ' ship to org:'||ln_rec_info.ship_to_org_id);
            END IF;
            l_booked_ln_excpn  := TRUE;
            GOTO start_over;
      END IF;
   WSH_INTERFACE.PrintMsg(txt=>'To organization:'|| ln_rec_info.ship_to_org_id||' loc:'|| l_ship_to_location_id );

      IF (ln_rec_info.deliver_to_org_id IS NOT NULL) THEN
        WSH_UTIL_CORE.GET_LOCATION_ID('CUSTOMER SITE', ln_rec_info.deliver_to_org_id,
                                    l_deliver_to_location_id, l_location_status);
        IF (l_location_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      WSH_INTERFACE.PrintMsg(name=>'WSH_DET_NO_LOCATION_FOR_ORG',
         txt=> 'Failed to get location for line: '||ln_rec_info.line_id||
                           ' delivery to org:'||ln_rec_info.deliver_to_org_id);
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Failed to get location for line: '||ln_rec_info.line_id||' delivery to org:'||ln_rec_info.deliver_to_org_id);
            END IF;
            l_booked_ln_excpn  := TRUE;
            GOTO start_over;
        END IF;
      END IF;
   WSH_INTERFACE.PrintMsg(txt=>'Deliver to org:'|| ln_rec_info.deliver_to_org_id||' loc:'|| l_deliver_to_location_id );

      IF (ln_rec_info.intmed_ship_to_org_id IS NOT NULL) THEN
        WSH_UTIL_CORE.GET_LOCATION_ID('CUSTOMER SITE', ln_rec_info.intmed_ship_to_org_id,
                                    l_intmed_ship_to_location_id, l_location_status);
        IF (l_location_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      WSH_INTERFACE.PrintMsg(name=>'WSH_DET_NO_LOCATION_FOR_ORG',
         txt=> 'Failed to get location for line: '||ln_rec_info.line_id||
                           ' intermediate ship to org:'||ln_rec_info.intmed_ship_to_org_id);
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Failed to get location for line: '||ln_rec_info.line_id||' intermediate ship to org:'||ln_rec_info.intmed_ship_to_org_id);
            END IF;
            l_booked_ln_excpn  := TRUE;
            GOTO start_over;
        END IF;
      END IF;
   WSH_INTERFACE.PrintMsg(txt=>'Intermediate ship to org:'|| ln_rec_info.intmed_ship_to_org_id||' loc:'|| l_intmed_ship_to_location_id );

      IF (l_deliver_to_location_id is NULL) THEN
         l_deliver_to_location_id := l_ship_to_location_id;
      END IF;

      OPEN c_shipping_parameters(ln_rec_info.ship_from_org_id);
      FETCH c_shipping_parameters INTO l_ship_parameters;
   IF ( c_shipping_parameters%NOTFOUND ) THEN
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Shipping Parameters notfound for warehuse:'||ln_rec_info.ship_from_org_id);
            END IF;
      WSH_INTERFACE.PrintMsg(txt=>'Shipping Parameters notfound for warehouse:'||ln_rec_info.ship_from_org_id);
   END IF;
      CLOSE c_shipping_parameters;

      OPEN c_category_id(ln_rec_info.inventory_item_id,
                         ln_rec_info.ship_from_org_id,
                         l_ship_parameters.freight_class_cat_set_id);
      FETCH c_category_id INTO l_freight_cl_cat_id;
   IF (c_category_id%NOTFOUND) THEN
      WSH_INTERFACE.PrintMsg(txt=>'Freight Catergory id notfound for item:'||ln_rec_info.inventory_item_id||
           ' warehouse:'||ln_rec_info.ship_from_org_id ||
           ' freight_class:'||l_ship_parameters.freight_class_cat_set_id);
   END IF;
      CLOSE c_category_id;

      OPEN c_category_id(ln_rec_info.inventory_item_id,
                         ln_rec_info.ship_from_org_id,
                         l_ship_parameters.commodity_code_cat_set_id);
      FETCH c_category_id INTO l_commodity_cat_id;
   IF (c_category_id%NOTFOUND) THEN
      WSH_INTERFACE.PrintMsg(txt=>'Commodity Catergory id notfound for item:'||ln_rec_info.inventory_item_id||
           ' warehouse:'||ln_rec_info.ship_from_org_id ||
           ' commodity_class:'||l_ship_parameters.commodity_code_cat_set_id);
   END IF;
      CLOSE c_category_id;
      WSH_INTERFACE.PrintMsg(txt=>'frght_class_catg_id:'|| l_freight_cl_cat_id ||' commodity_class_ctg_id:'|| l_commodity_cat_id);


   -- Check added for Standalone Project
   IF NVL(WMS_DEPLOY.Wms_Deployment_Mode,'I') <> 'D' THEN --{
/* J TP Release */
      WSH_TP_RELEASE.calculate_tp_dates (
                                          p_request_date_type        => ln_rec_info.order_date_type_code,
                                          p_latest_acceptable_date   => ln_rec_info.latest_acceptable_date,
                                          p_promise_date             => ln_rec_info.promise_date,
                                          p_schedule_arrival_date    => ln_rec_info.schedule_arrival_date,
                                          p_schedule_ship_date       => ln_rec_info.date_scheduled,
                                          p_earliest_acceptable_date => ln_rec_info.earliest_acceptable_date,
                                          p_demand_satisfaction_date => ln_rec_info.earliest_ship_date,
                                          p_source_line_id           => p_source_line_id,
                                          p_source_code              => p_source_code,
                                          x_return_status            => l_return_status,
                                          x_earliest_pickup_date     => l_delivery_details_info.earliest_pickup_date,
                                          x_latest_pickup_date       => l_delivery_details_info.latest_pickup_date,
                                          x_earliest_dropoff_date    => l_delivery_details_info.earliest_dropoff_date,
                                          x_latest_dropoff_date      => l_delivery_details_info.latest_dropoff_date
                                         );
         IF (l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
      WSH_INTERFACE.PrintMsg(name=>'WSH_CALC_TP_DATES',
         txt=>'Error in calculating TP dates: '||ln_rec_info.order_date_type_code||ln_rec_info.latest_acceptable_date||ln_rec_info.promise_date||ln_rec_info.schedule_arrival_date||ln_rec_info.earliest_acceptable_date||ln_rec_info.earliest_ship_date);
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Error in calculating TP dates: '    ||
                 ln_rec_info.order_date_type_code    ||
                 ln_rec_info.latest_acceptable_date  ||
                 ln_rec_info.promise_date            ||
                 ln_rec_info.schedule_arrival_date   ||
                 ln_rec_info.earliest_acceptable_date||
                 ln_rec_info.earliest_ship_date);
            END IF;
      END IF;
      IF l_delivery_details_info.earliest_pickup_date > l_delivery_details_info.latest_pickup_date THEN
        latest_pickup_tpdate_excep := l_delivery_details_info.latest_pickup_date;
        l_delivery_details_info.latest_pickup_date:= l_delivery_details_info.earliest_pickup_date;
      END IF;

      IF l_delivery_details_info.earliest_dropoff_date > l_delivery_details_info.latest_dropoff_date THEN
        latest_dropoff_tpdate_excep := l_delivery_details_info.latest_dropoff_date;
        l_delivery_details_info.latest_dropoff_date := l_delivery_details_info.earliest_dropoff_date;
      END IF;
   END IF; --}

      l_delivery_details_info.source_document_type_id := ln_rec_info.source_document_type_id;
      /*J TP Release*/

      --bug 3272115 - for internal orders line dir shud be set to 'IO'
      --internal orders have source_document_type_id=10
      IF ln_rec_info.source_document_type_id=10 THEN
         l_delivery_details_info.line_direction:='IO';
      END IF;

      l_delivery_details_info.source_code :=  'OE';
      l_delivery_details_info.source_header_id := ln_rec_info.header_id;
      l_delivery_details_info.source_line_id := ln_rec_info.line_id;
      l_delivery_details_info.customer_id := ln_rec_info.sold_to_org_id;
      l_delivery_details_info.sold_to_contact_id := ln_rec_info.sold_to_contact_id;
      l_delivery_details_info.inventory_item_id := ln_rec_info.inventory_item_id;
      l_delivery_details_info.item_description := ln_rec_info.item_description;
      l_delivery_details_info.hazard_class_id := haz_class_id;
      l_delivery_details_info.ship_from_location_id :=  l_ship_from_location_id;
      l_delivery_details_info.ship_to_location_id := l_ship_to_location_id;
      l_delivery_details_info.ship_to_site_use_id := ln_rec_info.ship_to_org_id ;
      l_delivery_details_info.deliver_to_site_use_id := ln_rec_info.deliver_to_org_id ;
      l_delivery_details_info.deliver_to_location_id := l_deliver_to_location_id;
      l_delivery_details_info.ship_to_contact_id := ln_rec_info.ship_to_contact_id;
      l_delivery_details_info.deliver_to_contact_id  := ln_rec_info.deliver_to_contact_id;
      l_delivery_details_info.intmed_ship_to_location_id := l_intmed_ship_to_location_id;
      l_delivery_details_info.intmed_ship_to_contact_id := ln_rec_info.intmed_ship_to_contact_id;
      l_delivery_details_info.ship_tolerance_above := ln_rec_info.ship_tolerance_above;
      l_delivery_details_info.ship_tolerance_below := ln_rec_info.ship_tolerance_below;
      WSH_INTERFACE.PrintMsg(txt=>'calling Convert uom=> order uom:'||ln_rec_info.order_quantity_uom||
                    ' order_qty:'||ln_rec_info.ordered_quantity || ' item_id:'|| ln_rec_info.inventory_item_id ||
        'to uom:'||prim_uom_code);

-- HW OPMCONV.
      l_delivery_details_info.requested_quantity := wsh_wv_utils.convert_uom(ln_rec_info.order_quantity_uom,
                                                                             prim_uom_code,ln_rec_info.ordered_quantity,
                                                                             ln_rec_info.inventory_item_id);
      WSH_INTERFACE.PrintMsg(txt=>'Convert uom=> prim_uom:'||prim_uom_code);
      l_delivery_details_info.requested_quantity_uom := prim_uom_code;

      -- odaboval : Begin of OPM Changes
      -- requested_quantities need to converted from apps primary uom code to
      -- opm primary uom code
      -- Only convert if this is a process org
-- HW OPMCONV. Removed forking and print msgs

      l_delivery_details_info.requested_quantity2 := ln_rec_info.ordered_quantity2;

      l_delivery_details_info.requested_quantity_uom2 :=ln_rec_info.ordered_quantity_uom2;
      l_delivery_details_info.preferred_grade := ln_rec_info.preferred_grade;
      l_delivery_details_info.src_requested_quantity2 := ln_rec_info.ordered_quantity2;
      l_delivery_details_info.src_requested_quantity_uom2 := ln_rec_info.ordered_quantity_uom2;
      --
     -- HW OPMCONV. Removed reference to OPM in the debugging statements
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'LN_REC_INFO.PREFERRED_GRADE IS ' || LN_REC_INFO.PREFERRED_GRADE  );
          WSH_DEBUG_SV.logmsg(l_module_name, 'LN_REC_INFO.ORDERED_QUANTITY2 IS ' || LN_REC_INFO.ORDERED_QUANTITY2  );
      END IF;
      --
      l_delivery_details_info.cancelled_quantity2:= NULL;
      -- odaboval : End of OPM Changes
      WSH_INTERFACE.PrintMsg(txt=>'Continuing to populate delivery_details_info record.');

      l_delivery_details_info.customer_requested_lot_flag := NULL;
      l_delivery_details_info.date_requested := ln_rec_info.date_requested;
      l_delivery_details_info.date_scheduled :=  ln_rec_info.date_scheduled;
      l_delivery_details_info.load_seq_number := NULL;
      IF ln_rec_info.shipping_method_code IS NOT NULL THEN
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, ' shipping_method_code: ' || ln_rec_info.shipping_method_code  );
         END IF;

         l_carrier_rec.ship_method_code := ln_rec_info.shipping_method_code;
         WSH_CARRIERS_GRP.get_carrier_service_mode(
                             p_carrier_service_inout_rec => l_carrier_rec,
                             x_return_status => x_return_status);

         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, ' shipping_method_code: ' || l_carrier_rec.ship_method_code  );
          WSH_DEBUG_SV.logmsg(l_module_name, ' generic: ' || l_carrier_rec.generic_flag  );
          WSH_DEBUG_SV.logmsg(l_module_name, ' service_level: ' || l_carrier_rec.service_level  );
          WSH_DEBUG_SV.logmsg(l_module_name, ' mode_of_transport: ' || l_carrier_rec.mode_of_transport  );
         END IF;
      END IF;
      IF l_carrier_rec.generic_flag = 'Y' THEN
         l_delivery_details_info.ship_method_code := NULL;
         l_delivery_details_info.carrier_id := NULL;
      ELSE
         l_delivery_details_info.ship_method_code := ln_rec_info.shipping_method_code;
         l_delivery_details_info.carrier_id := l_carrier_rec.carrier_id;
      END IF;
      l_delivery_details_info.service_level := l_carrier_rec.service_level;
      l_delivery_details_info.mode_of_transport := l_carrier_rec.mode_of_transport;
      l_delivery_details_info.freight_terms_code := ln_rec_info.freight_terms_code;
      l_delivery_details_info.shipment_priority_code := ln_rec_info.shipment_priority_code;
      l_delivery_details_info.fob_code := ln_rec_info.fob_code;
      IF (ln_rec_info.item_identifier_type = 'CUST') THEN
         l_delivery_details_info.customer_item_id :=  ln_rec_info.ordered_item_id;
      END IF;
      l_delivery_details_info.dep_plan_required_flag := ln_rec_info.dep_plan_required_flag;
      l_delivery_details_info.customer_prod_seq := ln_rec_info.customer_prod_seq_number;
      l_delivery_details_info.customer_dock_code := ln_rec_info.customer_dock_code;
      l_delivery_details_info.cust_model_serial_number := ln_rec_info.cust_model_serial_number;
      l_delivery_details_info.customer_job := ln_rec_info.customer_job;
      l_delivery_details_info.customer_production_line := ln_rec_info.customer_production_line;
      -- bug 1701560: use requested_quantity, instead of ordered_quantity,
      --              to calculate correct net_weight
      l_delivery_details_info.net_weight :=  unit_weight * l_delivery_details_info.requested_quantity;
      l_delivery_details_info.weight_uom_code := weight_uom;
      -- bug 1701560: use requested_quantity, instead of ordered_quantity,
      --              to calculate correct volume
      l_delivery_details_info.volume := unit_volume * l_delivery_details_info.requested_quantity;
      l_delivery_details_info.volume_uom_code := volume_uom;
      l_delivery_details_info.released_flag := 'N';
      l_delivery_details_info.pickable_flag := transactable_flag;
      l_delivery_details_info.organization_id  := ln_rec_info.ship_from_org_id;
      l_delivery_details_info.ship_set_id   := ln_rec_info.ship_set_id;
      l_delivery_details_info.arrival_set_id := ln_rec_info.arrival_set_id;
      l_delivery_details_info.ship_model_complete_flag := ln_rec_info.ship_model_complete_flag;
      l_delivery_details_info.top_model_line_id := ln_rec_info.top_model_line_id;
      l_delivery_details_info.source_header_number := ln_rec_info.header_number;
      l_delivery_details_info.source_header_type_id := ln_rec_info.header_type_id;
      l_delivery_details_info.source_header_type_name := ln_rec_info.header_type_name;
      l_delivery_details_info.cust_po_number := ln_rec_info.cust_po_number;
      l_delivery_details_info.ato_line_id := ln_rec_info.ato_line_id;
      l_delivery_details_info.src_requested_quantity := ln_rec_info.ordered_quantity;
      l_delivery_details_info.src_requested_quantity_uom := ln_rec_info.order_quantity_uom;
      l_delivery_details_info.cancelled_quantity := NULL;
      l_delivery_details_info.shipping_instructions := ln_rec_info.shipping_instructions;
      l_delivery_details_info.packing_instructions := ln_rec_info.packing_instructions;
      l_delivery_details_info.project_id := ln_rec_info.project_id;
      l_delivery_details_info.task_id :=  ln_rec_info.task_id;
      l_delivery_details_info.org_id :=  ln_rec_info.org_id;
      l_delivery_details_info.source_line_number  := ln_rec_info.line_number;
--    l_delivery_details_info.master_container_item_id := ln_rec_info.master_container_item_id; vms updated in 115.69
      l_delivery_details_info.master_container_item_id := NULL;
--    l_delivery_details_info.detail_container_item_id := ln_rec_info.detail_container_item_id;
      l_delivery_details_info.detail_container_item_id := NULL;
      l_delivery_details_info.released_status := 'N';
      l_delivery_details_info.container_flag := 'N';
      l_delivery_details_info.container_type_code := NULL;
      l_delivery_details_info.container_name := NULL;
      l_delivery_details_info.fill_percent := NULL;
      l_delivery_details_info.gross_weight := l_delivery_details_info.net_weight;
      l_delivery_details_info.master_serial_number := NULL;
      l_delivery_details_info.maximum_load_weight := NULL;
      l_delivery_details_info.maximum_volume := NULL;
      l_delivery_details_info.minimum_fill_percent := NULL;
      l_delivery_details_info.seal_code :=  NULL;
      l_delivery_details_info.mvt_stat_status := 'NEW';
      l_delivery_details_info.unit_price := ln_rec_info.unit_list_price;
      l_delivery_details_info.currency_code := ln_rec_info.transactional_curr_code;
      l_delivery_details_info.unit_number := ln_rec_info.end_item_unit_number;
   l_delivery_details_info.freight_class_cat_id := l_freight_cl_cat_id;
   l_delivery_details_info.commodity_code_cat_id := l_commodity_cat_id;

   l_delivery_details_info.subinventory := ln_rec_info.subinventory;
--   l_delivery_details_info.attribute15 := ln_rec_info.subinventory;  -- 1561078
   l_delivery_details_info.original_subinventory := ln_rec_info.subinventory;  -- 1561078

      l_delivery_details_info.tp_attribute_category := ln_rec_info.tp_context;
      l_delivery_details_info.tp_attribute1 := ln_rec_info.tp_attribute1;
      l_delivery_details_info.tp_attribute2 := ln_rec_info.tp_attribute2;
      l_delivery_details_info.tp_attribute3 := ln_rec_info.tp_attribute3;
      l_delivery_details_info.tp_attribute4 := ln_rec_info.tp_attribute4;
      l_delivery_details_info.tp_attribute5 := ln_rec_info.tp_attribute5;
      l_delivery_details_info.tp_attribute6 := ln_rec_info.tp_attribute6;
      l_delivery_details_info.tp_attribute7 := ln_rec_info.tp_attribute7;
      l_delivery_details_info.tp_attribute8 := ln_rec_info.tp_attribute8;
      l_delivery_details_info.tp_attribute9 := ln_rec_info.tp_attribute9;
      l_delivery_details_info.tp_attribute10 := ln_rec_info.tp_attribute10;
      l_delivery_details_info.tp_attribute11 := ln_rec_info.tp_attribute11;
      l_delivery_details_info.tp_attribute12 := ln_rec_info.tp_attribute12;
      l_delivery_details_info.tp_attribute13 := ln_rec_info.tp_attribute13;
      l_delivery_details_info.tp_attribute14 := ln_rec_info.tp_attribute14;
      l_delivery_details_info.tp_attribute15 := ln_rec_info.tp_attribute15;
      -- J: W/V Changes
      l_delivery_details_info.unit_weight := unit_weight;
      l_delivery_details_info.unit_volume := unit_volume;
      l_delivery_details_info.wv_frozen_flag := 'N';
      l_delivery_details_info.request_date_type_code := ln_rec_info.order_date_type_code;

      IF (l_delivery_details_info.requested_quantity = 0) THEN
         WSH_INTERFACE.PrintMsg(name=>'WSH_QTY_OR_UOM_NOT_VALID',
         txt=>'Failed to import order line  '  ||  ln_rec_info.line_id || ' because quantity uom or quantity is invalid');
         l_booked_ln_excpn  := TRUE;
         GOTO start_over;
      END IF;

-- anxsharm Bug 2181132
      l_delivery_details_info.source_line_set_id := ln_rec_info.line_set_id;

      IF (l_delivery_details_info.source_line_set_id IS NOT NULL) THEN
        WSH_INTERFACE.PrintMsg(txt=> 'Source Line Set id -'||l_delivery_details_info.source_line_set_id);
      END IF;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Source Line Set id -'||l_delivery_details_info.source_line_set_id);
      END IF;

      WSH_DELIVERY_DETAILS_PKG.Create_Delivery_Details( l_delivery_details_info, dummy_rowid,
                                                        DUMMY_DELIVERY_DETAIL_ID,
                                                        l_cr_dt_status );
      IF (l_cr_dt_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         WSH_INTERFACE.PrintMsg(name=>'WSH_DET_CREATE_DET_FAILED',
         txt=>'Create_delivery_details failed for line: ' || ln_rec_info.line_id );
         WSH_UTIL_CORE.Get_Messages('N', l_cr_as_summary, l_cr_as_details, l_cr_as_count);
         WSH_INTERFACE.PrintMsg(txt=>'Creation of the delivery details failed because of ' || l_cr_as_summary || ':'|| l_cr_as_details);
         l_booked_ln_excpn  := TRUE;
         GOTO start_over;
      END IF;
      WSH_INTERFACE.PrintMsg(txt=>'Created dd:' || dummy_delivery_detail_id|| ' for line:'|| ln_rec_info.line_id );
      IF DUMMY_DELIVERY_DETAIL_ID IS NOT NULL THEN
        IF latest_pickup_tpdate_excep IS NOT NULL THEN
          WSH_TP_RELEASE.log_tpdate_exception('LINE',dummy_delivery_detail_id,TRUE,l_delivery_details_info.earliest_pickup_date,latest_pickup_tpdate_excep);
        END IF;
        IF latest_dropoff_tpdate_excep IS NOT NULL THEN
          WSH_TP_RELEASE.log_tpdate_exception('LINE',dummy_delivery_detail_id,FALSE,l_delivery_details_info.earliest_dropoff_date,latest_dropoff_tpdate_excep);
        END IF;
      END IF;
/* LG OPM for OM changes */
     /* OPM assign the new delivery_detail_id to the trans that associated with this order line */
-- HW OPMCONV. Removed code forking

      -- Call default container after create a new delivery detail to populate
      -- default container
      WSH_INTERFACE.Default_Container(dummy_delivery_detail_id, l_return_status);
      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         WSH_INTERFACE.PrintMsg(txt=>'Default container failed for dd:'||dummy_delivery_detail_id);
      END IF;

      l_delivery_assignments_info.delivery_id := NULL;
      l_delivery_assignments_info.parent_delivery_id := NULL;
      l_delivery_assignments_info.delivery_detail_id := dummy_delivery_detail_id;
      l_delivery_assignments_info.parent_delivery_detail_id := NULL;

      WSH_DELIVERY_DETAILS_PKG.Create_Delivery_Assignments( l_delivery_assignments_info,
                                                            dummy_assgn_rowid,
                                                            DUMMY_DELIVERY_ASSIGNMENT_ID,
                                                            l_cr_as_status);
      IF (l_cr_as_status  <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
         WSH_INTERFACE.PrintMsg(name=>'WSH_DET_CREATE_AS_FAILED',
         txt=>'Create Delivery assignments failed for order line:' || ln_rec_info.line_id);
         WSH_UTIL_CORE.Get_Messages('N', l_cr_as_summary, l_cr_as_details, l_cr_as_count);
         WSH_INTERFACE.PrintMsg(txt=>'Creation of the delivery assignments failed because of ' || l_cr_as_summary || ':'|| l_cr_as_details);
         l_booked_ln_excpn  := TRUE;
         GOTO start_over;
      END IF;
      WSH_INTERFACE.PrintMsg(txt=>'Created da:' || DUMMY_DELIVERY_ASSIGNMENT_ID|| ' for dd:'|| l_delivery_assignments_info.delivery_detail_id);

      --OTM R12, calling delivery detail splitter
      IF (l_gc3_is_installed = 'Y') THEN

        WSH_INTERFACE.PrintMsg(txt=>'Delivery Detail Splitter Data:');
        WSH_INTERFACE.PrintMsg(txt=>'delivery detail id: '||dummy_delivery_detail_id);
        WSH_INTERFACE.PrintMsg(txt=>'inventory item id: '||l_delivery_details_info.inventory_item_id);
        WSH_INTERFACE.PrintMsg(txt=>'net weight: '|| l_delivery_details_info.net_weight);
        WSH_INTERFACE.PrintMsg(txt=>'organization id: '||l_delivery_details_info.organization_id);
        WSH_INTERFACE.PrintMsg(txt=>'weight uom code: '||l_delivery_details_info.weight_uom_code);
        WSH_INTERFACE.PrintMsg(txt=>'requested quantity: '||l_delivery_details_info.requested_quantity);
        WSH_INTERFACE.PrintMsg(txt=>'ship from location id: '||l_delivery_details_info.ship_from_location_id);
        WSH_INTERFACE.PrintMsg(txt=>'requested_quantity_uom: '||l_delivery_details_info.requested_quantity_uom);

        --prepare table of delivery detail information to call splitter
	l_delivery_detail_tab(1) := WSH_ENTITY_INFO_REC(
                                dummy_delivery_detail_id,
                                NULL,
                                l_delivery_details_info.inventory_item_id,
                                l_delivery_details_info.net_weight,
                                0,
                                l_delivery_details_info.organization_id,
                                l_delivery_details_info.weight_uom_code,
                                l_delivery_details_info.requested_quantity,
                                l_delivery_details_info.ship_from_location_id,
                                NULL);
        l_item_quantity_uom_tab(1) := l_delivery_details_info.requested_quantity_uom;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_SPLITTER.tms_delivery_detail_split',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

	WSH_DELIVERY_DETAILS_SPLITTER.tms_delivery_detail_split(
              	p_detail_tab            => l_delivery_detail_tab,
                p_item_quantity_uom_tab => l_item_quantity_uom_tab,
                x_return_status         => l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_DELIVERY_DETAILS_SPLITTER.tms_delivery_detail_split: ' || l_return_status);
        END IF;

	-- we will not fail based on l_return_status here because
        -- we do not want to stop the flow
        -- if the detail doesn't split, it will be caught later in
        -- delivery splitting and will have exception on the detail
        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          WSH_INTERFACE.PrintMsg(txt=>'Delivery detail split failed for dd:'||dummy_delivery_detail_id);
        END IF;

      END IF;
      --END OTM R12


      MO_GLOBAL.set_policy_context('S', ln_rec_info.org_id);

      oe_globals.set_context;
      /*   Replace process order with update_shipping_interface API for better
           performance
   */
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_SHIPPING_INTEGRATION_PUB.UPDATE_SHIPPING_INTERFACE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      OE_Shipping_Integration_PUB.Update_Shipping_Interface(
            p_api_version_number          => 1.0,
            p_line_id                     => ln_rec_info.line_id,
            p_shipping_interfaced_flag    => 'Y',
            x_return_status               => l_return_status,
            x_msg_count                   => l_msg_count,
            x_msg_data                    => l_msg_data);


      IF (l_return_status =  WSH_UTIL_CORE.G_RET_STS_ERROR) or (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
      THEN
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR: OE_SHIPPING_INTEGRATION_PUB.UPDATE_SHIPPING_INTERFACE RETURNED ' || L_RETURN_STATUS  );
      END IF;
      --
         WSH_INTERFACE.PrintMsg(name=>'WSH_DET_PROCESS_ORDER_FAILED',
         txt=>'Update_Shipping_Interface failed for line:'  ||  ln_rec_info.line_id );
         WSH_UTIL_CORE.Get_Messages('N',l_summary, l_details, l_get_msg_count);
         WSH_INTERFACE.PrintMsg(txt=>'no. of OE messages :'||l_msg_count);
         FOR k IN 1 .. l_msg_count LOOP
            l_msg_data := OE_MSG_PUB.GET( p_msg_index => k, p_encoded => 'F');
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_msg_data',SUBSTR(l_msg_data,1,200));
            END IF;
            --
            WSH_INTERFACE.PrintMsg(txt=>substr(l_msg_data,1,255));
         END LOOP;
      -- Added for Bug-2876707
         l_booked_ln_excpn := TRUE;
         GOTO Start_Over;
      ELSE
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'OE_SHIPPING_INTEGRATION_PUB.UPDATE_SHIPPING_INTERFACE RETURNED ' || L_RETURN_STATUS  );
      END IF;
      --
          l_wf_source_header_id    := l_delivery_details_info.source_header_id;
          l_wf_source_code         := l_delivery_details_info.source_code;
          l_wf_order_number        := l_delivery_details_info.source_header_number;
          IF (l_delivery_details_info.ship_to_contact_id is not null) THEN
       l_wf_contact_type := 'SHIP_TO';
       l_wf_contact_id   := l_delivery_details_info.ship_to_contact_id;
          ELSIF (l_delivery_details_info.sold_to_contact_id is not null) then
       l_wf_contact_type := 'SOLD_TO';
       l_wf_contact_id   := l_delivery_details_info.sold_to_contact_id;
          ELSE
       l_wf_contact_type := 'CUSTOMER';
       l_wf_contact_id   := l_delivery_details_info.customer_id;
          END IF;

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'L_WF_SOURCE_HEADER_ID : ' || L_WF_SOURCE_HEADER_ID  );
        WSH_DEBUG_SV.logmsg(l_module_name, 'L_WF_SOURCE_CODE : ' || L_WF_SOURCE_CODE  );
        WSH_DEBUG_SV.logmsg(l_module_name, 'L_WF_ORDER_NUMBER : ' || L_WF_ORDER_NUMBER  );
        WSH_DEBUG_SV.logmsg(l_module_name, 'L_WF_CONTACT_TYPE : ' || L_WF_CONTACT_TYPE  );
        WSH_DEBUG_SV.logmsg(l_module_name, 'L_WF_CONTACT_ID : ' || L_WF_CONTACT_ID  );
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF.START_WORKFLOW',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_WF.Start_Workflow( l_wf_source_header_id, l_wf_source_code,
                           l_wf_order_number, l_wf_contact_type,
                           l_wf_contact_id, l_result);

          IF (l_result = TRUE) THEN
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'WSH_WF.START_WORKFLOW : RETURNED TRUE'  );
         END IF;
         --
         WSH_INTERFACE.PrintMsg(txt=>'Started workflow for '||l_wf_source_header_id||'-'||l_wf_source_code||'-'||
           l_wf_contact_type||'-'||l_wf_contact_id);
          ELSE
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'WSH_WF.START_WORKFLOW : DID NOT RETURNED TRUE'  );
            END IF;
            --
         WSH_INTERFACE.PrintMsg(txt=>'Did not Start workflow for '||l_wf_source_header_id||'-'||l_wf_source_code||'-'||
           l_wf_contact_type||'-'||l_wf_contact_id);
          END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER CALLING WSH_WF.START_WORKFLOW '  );
        WSH_DEBUG_SV.logmsg(l_module_name, 'L_WF_SOURCE_HEADER_ID : ' || L_WF_SOURCE_HEADER_ID  );
        WSH_DEBUG_SV.logmsg(l_module_name, 'L_WF_SOURCE_CODE : ' || L_WF_SOURCE_CODE  );
        WSH_DEBUG_SV.logmsg(l_module_name, 'L_WF_ORDER_NUMBER : ' || L_WF_ORDER_NUMBER  );
        WSH_DEBUG_SV.logmsg(l_module_name, 'L_WF_CONTACT_TYPE : ' || L_WF_CONTACT_TYPE  );
        WSH_DEBUG_SV.logmsg(l_module_name, 'L_WF_CONTACT_ID : ' || L_WF_CONTACT_ID  );
    END IF;
    --
      END IF;

      -- Bug: 1902176
      IF C_OE_LINES_REC_LOCK%ISOPEN THEN
        CLOSE C_OE_LINES_REC_LOCK;
      END IF;
    EXCEPTION
      -- 1902176: Handling the Locked Condition
       WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
         -- some one else is currently working on this line id
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'IN LOCK LINE ID EXCEPTION: WSH_USA_ACTIONS_PVT.IMPORT_DELIVERY_DETAILS' );
             WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION:  ' || SQLERRM );
         END IF;
         --
         wsh_util_core.default_handler('WSH_USA_ACTIONS_PVT.IMPORT_DELIVERY_DETAILS',l_module_name);
         IF C_OE_LINES_REC_LOCK%ISOPEN THEN
           CLOSE C_OE_LINES_REC_LOCK;
         END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     when invalid_org THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION: INVALID_ORG'  );
        END IF;
        --
        fnd_message.set_name('WSH', 'WSH_DET_NO_LOCATION_FOR_ORG');
        IF C_OE_LINES_REC_LOCK%ISOPEN THEN
          CLOSE C_OE_LINES_REC_LOCK;
        END IF;
        WSH_UTIL_CORE.add_message ('E',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     when invalid_cust_site THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION: INVALID_CUST_SITE'  );
        END IF;
        --
        fnd_message.set_name('WSH', 'WSH_DET_NO_LOCATION_FOR_SITE');
        IF C_OE_LINES_REC_LOCK%ISOPEN THEN
          CLOSE C_OE_LINES_REC_LOCK;
        END IF;
        WSH_UTIL_CORE.add_message ('E',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     when invalid_qty_or_uom THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION: INVALID_QTY_OR_UOM'  );
        END IF;
        --
        fnd_message.set_name('WSH','WSH_QTY_OR_UOM_NOT_VALID');
        IF C_OE_LINES_REC_LOCK%ISOPEN THEN
          CLOSE C_OE_LINES_REC_LOCK;
        END IF;
        WSH_UTIL_CORE.add_message ('E',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     when process_order_failed THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION: PROCESS_ORDER_FAILED'  );
        END IF;
        --
        fnd_message.set_name('WSH', 'WSH_DET_PROCESS_ORDER_FAILED');
        IF C_OE_LINES_REC_LOCK%ISOPEN THEN
          CLOSE C_OE_LINES_REC_LOCK;
        END IF;
        WSH_UTIL_CORE.add_message ('E',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     when create_details_failed THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION:CREATE_DETAILS_FAILED'  );
        END IF;
        --
        fnd_message.set_name('WSH', 'WSH_DET_CREATE_DET_FAILED');
        IF C_OE_LINES_REC_LOCK%ISOPEN THEN
          CLOSE C_OE_LINES_REC_LOCK;
        END IF;
        WSH_UTIL_CORE.add_message ('E',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     when create_assignments_failed THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION: CREATE_ASSIGNMENTS_FAILED'  );
        END IF;
        --
        fnd_message.set_name('WSH', 'WSH_DET_CREATE_AS_FAILED');
        IF C_OE_LINES_REC_LOCK%ISOPEN THEN
          CLOSE C_OE_LINES_REC_LOCK;
        END IF;
        WSH_UTIL_CORE.add_message ('E',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WHEN invalid_ship_set THEN -- bug 2373131
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION: INVALID SHIP SET'  );
        END IF;
        --
        fnd_message.set_name('WSH', 'WSH_INVALID_SET');
        fnd_message.set_token('SHIP_SET',l_ship_set_name);
        fnd_message.set_token('LINE_NUMBER',ln_rec_info.line_number);
        IF C_OE_LINES_REC_LOCK%ISOPEN THEN
          CLOSE C_OE_LINES_REC_LOCK;
        END IF;
        WSH_UTIL_CORE.add_message ('E',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

-- HW OPM BUG#:2677054
-- HW OPMCONV. Removed OPM exceptions

     WHEN OTHERS THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION: OTHERS ' || SQLERRM );
        END IF;
        --
        wsh_util_core.default_handler('WSH_USA_ACTIONS_PVT.IMPORT_DELIVERY_DETAILS',l_module_name);
        IF C_OE_LINES_REC_LOCK%ISOPEN THEN
          CLOSE C_OE_LINES_REC_LOCK;
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    END;   -- Lock Check Block (1902176)
   END IF; --}  --Bugfix 6740363

   END LOOP;
   IF (C_PULL_DELIVERY_DETAILS%ISOPEN) THEN
     CLOSE C_PULL_DELIVERY_DETAILS;
   END IF;
   IF (C_PULL_ONE_LINE%ISOPEN) THEN
     CLOSE C_PULL_ONE_LINE;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_pull_lines_count',l_pull_lines_count);
   END IF;

   IF (l_pull_lines_count = 0 and p_source_line_id IS NOT NULL) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

        fnd_message.set_name('WSH', 'WSH_DET_CREATE_LINE_FAILED');
        WSH_UTIL_CORE.add_message (x_return_status,l_module_name);


        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Cursor C_PULL_DELIVERY_DETAIL DID NOT FOUND ANY LINES');
        END IF;
   END IF;


   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
  EXCEPTION
    -- 2680026
     when create_details_failed THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION:CREATE_DETAILS_FAILED'  );
        END IF;
        --
        fnd_message.set_name('WSH', 'WSH_DET_CREATE_DET_FAILED');
        IF C_OE_LINES_REC_LOCK%ISOPEN THEN
          CLOSE C_OE_LINES_REC_LOCK;
        END IF;
        IF (C_PULL_DELIVERY_DETAILS%ISOPEN) THEN
           CLOSE C_PULL_DELIVERY_DETAILS;
        END IF;
        IF (C_PULL_ONE_LINE%ISOPEN) THEN
           CLOSE C_PULL_ONE_LINE;
        END IF;
        WSH_UTIL_CORE.add_message ('E',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     when others THEN
        wsh_util_core.default_handler('WSH_USA_ACTIONS_PVT.IMPORT_DELIVERY_DETAILS',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        IF C_OE_LINES_REC_LOCK%ISOPEN THEN
          CLOSE C_OE_LINES_REC_LOCK;
        END IF;
        IF (C_PULL_DELIVERY_DETAILS%ISOPEN) THEN
           CLOSE C_PULL_DELIVERY_DETAILS;
        END IF;
        IF (C_PULL_ONE_LINE%ISOPEN) THEN
           CLOSE C_PULL_ONE_LINE;
        END IF;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END Import_Delivery_Details;


END WSH_USA_ACTIONS_PVT;

/
