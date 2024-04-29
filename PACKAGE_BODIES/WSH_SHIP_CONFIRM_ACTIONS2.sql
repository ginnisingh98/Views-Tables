--------------------------------------------------------
--  DDL for Package Body WSH_SHIP_CONFIRM_ACTIONS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SHIP_CONFIRM_ACTIONS2" as
/* $Header: WSHDDSPB.pls 120.8.12010000.7 2009/12/03 16:13:58 gbhargav ship $ */

--
--Function:         part_of_ship_set
--Parameters:       p_source_line_id
--Description: 	This function returns a boolean number that indicates
--				if the order line is part of a ship set
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_SHIP_CONFIRM_ACTIONS2';
--
FUNCTION Part_Of_Ship_Set(p_source_line_id number) RETURN BOOLEAN is
l_count number;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PART_OF_SHIP_SET';
--
BEGIN
	--
	-- Debug Statements
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
	END IF;
	--
	select count(*) into l_count
	from wsh_delivery_details
	where ship_set_id is not null
	and source_line_id = p_source_line_id
        and NVL(line_direction, 'O') IN ('O', 'IO') -- J Inbound Logistics Changes jckwok
	and NVL(container_flag,'N') = 'N';

	if (l_count > 0) then
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name,'RETURN-TRUE');
		END IF;
		--
		return TRUE;
	else
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name,'RETURN-TRUE');
		END IF;
             return FALSE;
	end if;
END part_of_ship_set;

procedure print_reservations  ( p_sales_order_id in number )is
cursor c_reservations ( c_sales_order_id number ) is
     select
     RES.RESERVATION_ID            RESERV_ID,
     decode(RES.SHIP_READY_FLAG,1,'1=Released',2,'2=Submitted',to_char(RES.SHIP_READY_FLAG))
                                   SHIP_READY,
     RES.DEMAND_SOURCE_HEADER_ID   DS_HEADER_ID,
     RES.DEMAND_SOURCE_LINE_ID     DS_LINE_ID,
     RES.DEMAND_SOURCE_DELIVERY    DS_DELIVERY,
     to_char(LIN.line_number)||
       '.'||to_char(LIN.shipment_number) ||
       decode(LIN.option_number,NULL,NULL,'.'||to_char(LIN.option_number)) LINE,
     RES.INVENTORY_ITEM_ID         ITEM_ID,
     RES.PRIMARY_RESERVATION_QUANTITY RES_QTY,
     RES.DETAILED_QUANTITY         DET_QTY,
     RES.REQUIREMENT_DATE          REQUIRD_D,
     RES.DEMAND_SOURCE_TYPE_ID     DS_TYPE,
     RES.ORGANIZATION_ID           ORG_ID,
     RES.SUBINVENTORY_CODE         SUBINV,
     RES.SUPPLY_SOURCE_HEADER_ID   SS_HEADER_ID,
     RES.SUPPLY_SOURCE_LINE_DETAIL SS_SOURCE_LINE_DET,
     RES.SUPPLY_SOURCE_LINE_ID     SS_SOURCE_LINE,
     RES.AUTODETAIL_GROUP_ID       AUTODET_GRP_ID,
     RES.AUTO_DETAILED             AUTODET
from
     MTL_RESERVATIONS              RES,
     OE_ORDER_LINES_ALL            LIN   --R12:MOAC use base table
where
      RES.DEMAND_SOURCE_HEADER_ID = c_sales_order_id
and  RES.DEMAND_SOURCE_TYPE_ID in  (2,8,9,21,22)
and  RES.DEMAND_SOURCE_LINE_ID     = LIN.LINE_ID(+)
order by
     NVL(LIN.TOP_MODEL_LINE_ID,            LIN.LINE_ID),
     NVL(LIN.ATO_LINE_ID,               LIN.LINE_ID),
     NVL(LIN.SORT_ORDER,                '0000'),
     NVL(LIN.LINK_TO_LINE_ID,           LIN.LINE_ID),
     NVL(LIN.SOURCE_DOCUMENT_LINE_ID,   LIN.LINE_ID),
     LIN.LINE_ID,
     RES.RESERVATION_ID;

l_reservations c_reservations%ROWTYPE;

  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINT_RESERVATIONS';
  --
begin
     --
     -- Debug Statements
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
         WSH_DEBUG_SV.log(l_module_name,'P_SALES_ORDER_ID',P_SALES_ORDER_ID);
     END IF;
     --
     open c_reservations ( p_sales_order_id );
     loop
     fetch c_reservations into l_reservations ;
             --
             -- Debug Statements
             --
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'RESERVATIONS FOR SALES_ORDER_ID ' || TO_CHAR ( P_SALES_ORDER_ID ) );
                 WSH_DEBUG_SV.logmsg(l_module_name, '================================================' );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'RESERV_ID : ' || TO_CHAR ( L_RESERVATIONS.RESERV_ID ) );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'SHIP_READY : ' || L_RESERVATIONS.SHIP_READY );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'DS_HEADER_ID : ' || TO_CHAR ( L_RESERVATIONS.DS_HEADER_ID ) );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'DS_LINE_ID : ' || TO_CHAR ( L_RESERVATIONS.DS_LINE_ID ) );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'DS_DELIVERY: ' || TO_CHAR ( L_RESERVATIONS.DS_DELIVERY ) );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'LINE : ' || L_RESERVATIONS.LINE );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'ITEM_ID : ' || TO_CHAR ( L_RESERVATIONS.ITEM_ID ) );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'RES_QTY : ' || TO_CHAR ( L_RESERVATIONS.RES_QTY ) );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'DET_QTY : ' || TO_CHAR ( L_RESERVATIONS.DET_QTY ) );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'REQUIRD_D : ' || L_RESERVATIONS.REQUIRD_D );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'DS_TYPE : ' || TO_CHAR ( L_RESERVATIONS.DS_TYPE ) );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'ORG_ID : ' || TO_CHAR ( L_RESERVATIONS.ORG_ID ) );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'SUBINV : ' || L_RESERVATIONS.SUBINV );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'SS_HEADER_ID : ' || TO_CHAR ( L_RESERVATIONS.SS_HEADER_ID ) );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'SS_SOURCE_LINE_DET- ' || TO_CHAR ( L_RESERVATIONS.SS_SOURCE_LINE_DET ) );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'SS_SOURCE_LINE : ' || TO_CHAR ( L_RESERVATIONS.SS_SOURCE_LINE ) );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'AUTODET_GRP_ID : ' || TO_CHAR ( L_RESERVATIONS.AUTODET_GRP_ID ) );
                 WSH_DEBUG_SV.logmsg(l_module_name, 'AUTODET : ' || TO_CHAR ( L_RESERVATIONS.AUTODET ) );
              END IF;

	     EXIT WHEN c_reservations%NOTFOUND;
    end loop ;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
end print_reservations ;

--Procedure:        Get_Line_Total_Shp_Qty
--Parameters:       p_source_line_id
--                  p_delivery_id
--                  x_line_shp_qty
--                  x_return_status
--Description:      This procedure calculates the total shippped quantity
--                  for a order line/source line in a specified delivery
-- OPM KYH 12/SEP/00 START - add x_line_shp_qty2 to out params
-- ===========================================================
PROCEDURE Get_Line_Total_Shp_Qty(
p_stop_id   in number ,
p_source_line_id in number,
x_line_shp_qty out NOCOPY  number ,
x_line_shp_qty2 out NOCOPY  number,
x_return_status out NOCOPY  varchar2) is
cursor c_shipped_rec is
SELECT   shipped_quantity
        ,shipped_quantity2   -- OPM KYH 12/SEP/00
	, dd.source_line_id
	, dl.status_code
FROM     wsh_delivery_Details dd,
	wsh_delivery_assignments_v da ,
	wsh_delivery_legs dg,
	wsh_new_deliveries dl,
	wsh_trip_stops st
WHERE st.stop_id = dg.pick_up_stop_id AND
	st.stop_id = p_stop_id AND
	st.stop_location_id = dl.initial_pickup_location_id AND
	dg.delivery_id = dl.delivery_id  AND
	dl.delivery_id = da.delivery_id  AND
	da.delivery_id IS NOT NULL AND
	da.delivery_detail_id = dd.delivery_detail_id
	and nvl ( dd.oe_interfaced_flag , 'N' )  <> 'Y'
	and nvl ( dd.inv_interfaced_flag, 'N' ) IN ( 'Y','X')
	and dd.source_line_id = p_source_line_id
	and dd.source_code = 'OE'
	and dd.container_flag = 'N' ;
shipped_rec c_shipped_rec%ROWTYPE;

NOT_ASSIGNED_TO_DEL_ERROR exception;
l_counter number;
l_error_code number;
l_error_text varchar2(2000);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_LINE_TOTAL_SHP_QTY';
--
begin
	--
	-- Debug Statements
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
	    WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_STOP_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
	END IF;
	--
	WSH_UTIL_CORE.Enable_Concurrent_Log_Print;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_line_shp_qty := 0;
	x_line_shp_qty2 := 0; -- OPM KYH 12/SEP/00
	open c_shipped_rec;
	LOOP
		fetch c_shipped_rec into shipped_rec;
		exit when c_shipped_rec%NOTFOUND;
		l_counter := l_counter + 1;
	        x_line_shp_qty := x_line_shp_qty + shipped_rec.shipped_quantity;
		-- OPM KYH 12/SEP/00 calculate qty2 for dual control scenarios
		-- ===========================================================
		if shipped_rec.shipped_quantity2 is NOT NULL THEN
		  x_line_shp_qty2 := x_line_shp_qty2 + shipped_rec.shipped_quantity2;
          ELSE
		  x_line_shp_qty2 := NULL;
          end if;
          -- OPM KYH 12/SEP/00 END of CHANGES
	END LOOP;
	if (l_counter = 0) then
		raise NOT_ASSIGNED_TO_DEL_ERROR;
	end if;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION
		when NOT_ASSIGNED_TO_DEL_ERROR then
			x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('WSH', 'WSH_DET_DETAIL_NOT_ASSIGNED');
			WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
			--
			-- Debug Statements
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'NOT_ASSIGNED_TO_DEL_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NOT_ASSIGNED_TO_DEL_ERROR');
			END IF;
			--
		when others then
			x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
			l_error_code := SQLCODE;
			l_error_text := SQLERRM;
			--
			WSH_UTIL_CORE.default_handler('WSH_SHIP_CONFIRM_ACTIONS2.Ship_zero_quantity',l_module_name);
			--
			-- Debug Statements
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
			END IF;
			--
END Get_Line_Total_Shp_Qty;

-- THIS PROCEDURE IS OBSOLETE

PROCEDURE Ship_Zero_Quantity(
  p_source_line_id			IN  	 NUMBER
, x_return_status					OUT NOCOPY  VARCHAR2
)
IS

BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

END Ship_Zero_Quantity;

/*
split each p_detail_ids into a new records with p_bo_qtys as requested_quantity.
The new dd_id is marked as 'B' and stored in x_out_rows
All the enteries in x_out_rows which are already assigned to a Delivery are stored
in l_unassign_dds and unassigned and unpacked. If the container becomes empty because of unassign
then the container is also unpacked/unassigned. This logic is embedded in unassign_unpack_empty_cont.
*/
-- bug# 6908504 (replenishment project):
-- Added a new parameter p_bo_source. This parameter can have two values 'SHIP' and 'PICK'.
-- For all replenishment functionality cases please call the API with p_bo_source code as 'PICK'.
-- This particulary parameter has been added to mimic the back order funcationaly which is available in
-- WSH_USA_INV_PVT.backorder_delivery_detail while pick releasing. Default value for this parameter
-- is 'SHIP' ( no change in the existing functionality when called without this parameter value).

PROCEDURE Backorder(
  p_detail_ids           IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_line_ids		 IN	WSH_UTIL_CORE.Id_Tab_Type ,  -- Consolidation of BO Delivery Details project
  p_bo_qtys              IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_req_qtys             IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_bo_qtys2             IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_overpick_qtys        IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_overpick_qtys2       IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_bo_mode              IN     VARCHAR2,
  p_bo_source            IN     VARCHAR2 DEFAULT 'SHIP',
  x_out_rows             OUT NOCOPY     WSH_UTIL_CORE.Id_Tab_Type,
  x_cons_flags	 	 OUT NOCOPY     WSH_UTIL_CORE.Column_Tab_Type, -- Consolidation of BO Delivery Details project
  x_return_status        OUT NOCOPY     VARCHAR2   )
IS
CURSOR c_detail(x_detail_id  NUMBER) IS
--Changed for BUG#3330869
--SELECT *
SELECT source_line_id,
       source_code,
       picked_quantity,
       delivery_detail_id,
       released_status,
       pickable_flag,
       organization_id,
       inventory_item_id,
       requested_quantity,
       serial_number,
       transaction_temp_id,
       subinventory,
       client_id   -- LSP PROJECT : Required to check whether order is for LSP
FROM wsh_delivery_details
WHERE delivery_detail_id = x_detail_id  AND
	 NVL(container_flag, 'N') = 'N';
l_detail_rec c_detail%ROWTYPE;

l_delivery_id              NUMBER;
l_return_status				VARCHAR2(30);
l_exception_exist				VARCHAR2(1);
l_user_id         			NUMBER := NULL;
l_login_id       			 	NUMBER := NULL;
l_trohdr_rec      			INV_MOVE_ORDER_PUB.Trohdr_Rec_Type;
l_trohdr_val_rec           INV_MOVE_ORDER_PUB.Trohdr_Val_Rec_Type;
l_trolin_tbl               INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
l_trolin_val_tbl           INV_MOVE_ORDER_PUB.Trolin_Val_Tbl_Type;
l_cr_hdr_return_status  	varchar2(30) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_cr_hdr_message 				varchar2(4000) := NULL;
l_cr_hdr_msg_count 			number:= NULL;
l_cr_hdr_msg_data 			varchar2(4000) := NULL;
l_cr_ln_return_status 		varchar2(30) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_cr_ln_msg_count 			number := NULL;
l_cr_ln_msg_data 				varchar2(4000) := NULL;
l_cr_ln_message 				varchar2(4000) := NULL;
l_sales_order_id 				NUMBER := NULL;
l_date           				DATE := SYSDATE;

--Added for Standalone project Changes
l_standalone_mode                VARCHAR2(1);

-- fabdi start : SHIPPING PIECE 12/09/2000

l_message_count         NUMBER;
l_message_data          VARCHAR2(3000);

l_to_subinventory       VARCHAR2(10);
l_to_locator            NUMBER;
l_commit                VARCHAR2(1) := FND_API.G_FALSE;
l_default_to_sub        VARCHAR2(10);
l_default_to_loc        NUMBER;
l_message               VARCHAR2(2000);

-- hverddin : Begin of OPM Backorder Changes 30-OCT-00

l_batch_id              NUMBER;
l_request_number        VARCHAR(30);
l_wf_rs VARCHAR2(1); --Pick To POD WF Project

-- hverddin : End of OPM Backorder Changes 30-OCT-00


-- fabdi end : SHIPPING PIECE 12/09/2000

i NUMBER;
/* Bug#: 2026895 Added the second decode statement */

/* CURSOR c_assigned(c_delivery_detail_id number) is
SELECT decode ( delivery_id , null , 'N' , 'Y' ),
	decode( delivery_id,null,-9999999,delivery_id)
FROM   wsh_delivery_assignments_v
WHERE  delivery_Detail_id = c_delivery_detail_id  ; */

-- bug# 6908504 (replenishment project), Changed the cursor definition. Now it returns planned_flag value from WND table.
CURSOR c_assigned(c_delivery_detail_id number) is
SELECT wnd.delivery_id,
       wnd.planned_flag
FROM   wsh_new_deliveries wnd,
       wsh_delivery_details wdd,
       wsh_delivery_assignments_v wda
WHERE  wdd.delivery_detail_id = c_delivery_detail_id
AND    wda.delivery_id = wnd.delivery_id
AND    wda.delivery_detail_id = wdd.delivery_detail_id ;


l_assigned_flag    VARCHAR2(1);
/*Bug#:2026895*/
l_valid_flag	BOOLEAN;

backorder_error   EXCEPTION;
-- HW 3457369
-- HW OPMCONV. Removed local variables

l_reserved_flag   VARCHAR2(1);
l_bo_detail_id    NUMBER;

l_bo_qty          NUMBER ;
l_bo_qty2         NUMBER ;
l_unassign_dds    WSH_UTIL_CORE.Id_Tab_Type ;
l_unassign_dds_tmp WSH_UTIL_CORE.Id_Tab_Type ; -- bug 7460785
l_delete_dds      WSH_UTIL_CORE.Id_Tab_Type ; -- to delete overpicked delivery lines
l_inv_controls_rec   WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec;

invalid_source_code EXCEPTION;   /*Bug 2096052- added for OKE */
no_backorder_full   EXCEPTION;   /*Bug 2399729- added for third party warehouse shipment line */
l_backorder_all  VARCHAR2(1) := 'N'; /* Bug 2399729 */
-- additional variables for bug 2056874
new_det_wt_vol_failed exception;
l_split_weight number;
l_split_volume number;
-- bug 2056874

l_num_warn NUMBER := 0;
l_num_err NUMBER := 0;

l_subinventory VARCHAR2(10) := NULL;

-- bug 2730685: need to know if we are backordering
--    an unshipped, overpicked line packed in container
l_new_picked_quantity NUMBER;

-- Newly added variables for Consolidation of BO Delivery Details project
--
l_global_param_rec	WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;
l_line_ids		WSH_UTIL_CORE.Id_Tab_Type ;
l_detail_ids		WSH_UTIL_CORE.Id_Tab_Type ;
-- HW 3457369
l_detail_ids_OPM        WSH_UTIL_CORE.Id_Tab_Type ;
l_req_qtys		WSH_UTIL_CORE.Id_Tab_Type ;
l_bo_qtys		WSH_UTIL_CORE.Id_Tab_Type ;
l_overpick_qtys         WSH_UTIL_CORE.Id_Tab_Type ;
-- HW OPM BUG#:3121616 added qty2s
l_bo_qty2s		WSH_UTIL_CORE.Id_Tab_Type ;
-- end of 3121616
l_delivery_ids		WSH_UTIL_CORE.Id_Tab_Type ;
l_cons_dd_ids		WSH_UTIL_CORE.Id_Tab_Type ; --Stores the dd_ids returned by Consolidate_Source_Line
l_remain_bo_qtys	WSH_UTIL_CORE.Id_Tab_Type ; --Stores the remaining bo qty returned by Consolidate_Delivery_details
-- HW OPM BUG#:3121616 added qty2s
l_remain_bo_qty2s	WSH_UTIL_CORE.Id_Tab_Type ; --Stores the remaining bo qty2 returned by Consolidate_Delivery_details
-- end of 3121616
l_cons_source_line_rec_tab  WSH_DELIVERY_DETAILS_ACTIONS.Cons_Source_Line_Rec_Tab;
l_dd_rec_tab		WSH_DELIVERY_DETAILS_ACTIONS.Cons_Source_Line_Rec_Tab;
l_cons_dd_rec_tab	WSH_DELIVERY_DETAILS_ACTIONS.Cons_Source_Line_Rec_Tab;
k			NUMBER;

l_dd_txn_id    NUMBER;    --DBI
l_txn_return_status  VARCHAR2(1); --DBI
--

-- HW 3457369
 CURSOR find_org_id (l_delivery_detail_id NUMBER ) IS
 SELECT organization_id from wsh_delivery_details
 WHERE delivery_detail_id = l_delivery_detail_id
 AND   NVL(container_flag, 'N') = 'N';

l_organization_id  NUMBER;
 -- end of 3457369

--Begin OPM Bug 3561937
  CURSOR get_pref_grade(wdd_id NUMBER) IS
  SELECT oelines.preferred_grade
  FROM   oe_order_lines_all oelines, wsh_delivery_details wdd
  WHERE  wdd.delivery_detail_id = wdd_id
  AND    wdd.source_code        = 'OE'
  AND    wdd.source_line_id     = oelines.line_id;

-- HW OPMCONV changed size of grade to 150
l_oeline_pref_grade VARCHAR2(150) := NULL;
--End OPM Bug 3561937

l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'BACKORDER';
--Bugfix 4070732
l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
l_reset_flags BOOLEAN;
--
-- K LPN CONV. rv
l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
l_msg_count NUMBER;
l_msg_data  VARCHAR2(32767);
e_return_excp EXCEPTION;
-- K LPN CONV. rv
l_item_info   WSH_DELIVERY_DETAILS_INV.mtl_system_items_rec;
--
--
l_unassign_dd_flag  VARCHAR2(1) := 'N';
l_planned_flag      VARCHAR2(1);    -- bug# 6908504 (replenishment project)
BEGIN
  IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null THEN  --Bugfix 4070732
    WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
    WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
  END IF;
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  -- Standalone project Changes Start
  l_standalone_mode := WMS_DEPLOY.wms_deployment_mode;
  -- Standalone project Changes End
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_BO_MODE',P_BO_MODE);
      WSH_DEBUG_SV.log(l_module_name,'P_BO_SOURCE',P_BO_SOURCE);
      WSH_DEBUG_SV.log(l_module_name,'l_standalone_mode',l_standalone_mode);
  END IF;
  --
  SAVEPOINT before_backorder;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Consolidation of BO Delivery Details project
  -- Begin
  l_line_ids.DELETE;
  l_detail_ids := p_detail_ids;
  l_detail_ids_opm := p_detail_ids;
  l_req_qtys   := p_req_qtys;
  l_bo_qtys   := p_bo_qtys;
  l_overpick_qtys := p_overpick_qtys;  -- Bug#3263952
-- HW OPM BUG#:3121616 added qty2s
  l_bo_qty2s   := p_bo_qtys2;
-- end of 3121616
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_SHIPPING_PARAMS_PVT.Get_Global_Parameters(l_global_param_rec, l_return_status);
  IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
	wsh_util_core.add_message(l_return_status,'WSH_DELIVERY_DETAILS_ACTIONS.Consolidate_Delivery_Details');
	x_return_status := l_return_status;
	RAISE backorder_error;
  END IF;

  IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Back Order Consolidation Flag is set as '||l_global_param_rec.consolidate_bo_lines, WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  IF (l_global_param_rec.consolidate_bo_lines = 'Y' AND p_line_ids.COUNT > 1 ) THEN
  --{
	-- Get the values into local pl/sql tables
        FOR i IN p_detail_ids.FIRST .. p_detail_ids.LAST LOOP --{
  	      l_dd_rec_tab(l_dd_rec_tab.count+1).delivery_detail_id := p_detail_ids(i);
       	      l_dd_rec_tab(l_dd_rec_tab.count).source_line_id := p_line_ids(i);
	      l_dd_rec_tab(l_dd_rec_tab.count).req_qty := p_req_qtys(i);
      	      l_dd_rec_tab(l_dd_rec_tab.count).bo_qty := p_bo_qtys(i);
              l_dd_rec_tab(l_dd_rec_tab.count).overpick_qty := p_overpick_qtys(i);   -- Bug#3263952
-- HW OPM BUG#:3121616 added qty2s
      	      l_dd_rec_tab(l_dd_rec_tab.count).bo_qty2 := p_bo_qtys2(i);
-- end of 3121616
	END LOOP; --}
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.Consolidate_Delivery_Details',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
-- HW OPM BUG#:3121616 Added x_remain_bo_qty2s
	WSH_DELIVERY_DETAILS_ACTIONS.Consolidate_Delivery_Details(
		p_delivery_details_tab	    => l_dd_rec_tab,
		p_bo_mode		    => p_bo_mode,
		x_cons_delivery_details_tab => l_cons_dd_rec_tab,
		x_remain_bo_qtys	    => l_remain_bo_qtys,
                x_remain_bo_qty2s	    => l_remain_bo_qty2s,
		x_return_status		    => l_return_status
		);
	IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
	           WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
		wsh_util_core.add_message(l_return_status,'WSH_DELIVERY_DETAILS_ACTIONS.Consolidate_Delivery_Details');
	        x_return_status := l_return_status;
		RAISE backorder_error;
	END IF;

	l_detail_ids.DELETE;
	l_req_qtys.DELETE;
	l_bo_qtys.DELETE;
-- HW OPM BUG#:3121616 added qty2s
        l_bo_qty2s.DELETE;
-- end of 3121616
	-- Get the values returned by Consolidate_Delivery_Details, into local pl/sql tables
        for i IN l_cons_dd_rec_tab.FIRST .. l_cons_dd_rec_tab.LAST LOOP --{
		l_detail_ids(i) := l_cons_dd_rec_tab(i).delivery_detail_id;
	        l_req_qtys(i)   := l_cons_dd_rec_tab(i).req_qty;
   	        l_bo_qtys(i)    := l_cons_dd_rec_tab(i).bo_qty;
                l_overpick_qtys(i)    := l_cons_dd_rec_tab(i).overpick_qty;   -- Bug#3263952
-- HW OPM BUG#:3121616 added qty2s
                l_bo_qty2s(i)   := l_cons_dd_rec_tab(i).bo_qty2;
-- end of 3121616
	END LOOP; --}
	IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Total No. of delivery details '||p_detail_ids.COUNT,WSH_DEBUG_SV.C_PROC_LEVEL);
                WSH_DEBUG_SV.logmsg(l_module_name,'No. of delivery details after Consolidation '||l_detail_ids.COUNT,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
  END IF;  --}, l_global_param_rec.consolidate_bo_lines flag
  --

  -- Replaced p_detail_ids with l_detail_ids, p_req_qtys with l_req_qtys, p_bo_qtys with l_bo_qtys and
  -- p_overpick_qtys with l_overpick_qtys, as part of code changes for Consolidation of BO Delivery Details project.
  FOR i IN 1 .. l_detail_ids.COUNT
  LOOP 	--{ loop thru' for each delivery detail id in l_detail_ids
      /* Bug 2399729, default l_backorder_all to 'N' */
      l_backorder_all := 'N';
      -- 1. See if the detail is assigned to a delivery .
      --    This check introduced because of bug 2041416 , because Backorder API
      --    can be called now during cycle counting of delivery details which may not
      --    be assigned to any delivery in the first place.

      l_delivery_id := NULL;  -- bug# 8365722 : Need to initialize the deliery_id to null

/*Bug#:2026895 Added l_delivery_id in the fetch statement*/
      -- bug# 6908504 (replenishment project): checking the planned flag value.
      open c_assigned ( l_detail_ids(i) )  ;
      FETCH c_assigned  INTO l_delivery_id,l_planned_flag;
      CLOSE c_assigned ;
      --
      IF l_delivery_id IS NULL THEN
      --{
          l_assigned_flag := 'N';
          l_delivery_id   := -99999;
          l_planned_flag  := 'N';
      ELSE
          l_assigned_flag := 'Y';
      --}
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'l_delivery_id: '||l_delivery_id||' ,l_planned_flag: '||l_planned_flag);
          WSH_DEBUG_SV.logmsg(l_module_name,  'IN BACKORDER ' || I  );
      END IF;
      --

           -- bug 1672188: check there is a quantity (normal or overpicked) to backorder.
           IF     (NVL(l_bo_qtys(i), 0) <= 0)
              AND (NVL(l_overpick_qtys(i), 0) <= 0) THEN
               goto loop_end;
           END IF;

           -- bug 1672188: split backordered quantity if needed
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'CHECKING IF ' || l_bo_qtys ( I ) || ' < ' || l_req_qtys ( I )  );
      END IF;
      --
      IF     (l_bo_qtys(i) > 0)
              AND (l_bo_qtys(i) < l_req_qtys(i)) THEN

        l_bo_qty := l_bo_qtys(i);
        l_bo_qty2 := p_bo_qtys2(i);

        -- wsh_util_core.println('splitting ' || l_detail_ids(i) );
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_delivery_details_actions.split_delivery_details(
                  p_from_detail_id => l_detail_ids(i),
                  p_req_quantity   => l_bo_qty,
                  x_new_detail_id  => l_bo_detail_id,
                  x_return_status  => l_return_status ,
                  p_req_quantity2  => l_bo_qty2);

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'SPLIT_DELIVERY_DETAILS l_return_status',l_return_status);
        END IF;

/* Bug 2308509 */
        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
           WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          wsh_util_core.add_message(l_return_status,l_module_name);
          x_return_status := l_return_status;
          RAISE backorder_error;
        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          l_num_warn := l_num_warn + 1;
        END IF;
/* End of Bug 2308509 */

      ELSE
        l_bo_detail_id := l_detail_ids(i);
        /* Bug 2399729, backorder all not allowed for third party warehouse shipment line */
        l_backorder_all := 'Y';

      END IF;

      /*Bug 5525314 moved up the open cursor c_detail
        and WSH_DELIVERY_DETAILS_INV.Get_item_information procedure. */
     /* H integration: 940/945 look up source code before unassigning wrudge*/
      OPEN c_detail(l_bo_detail_id );
      FETCH c_detail INTO l_detail_rec;
      CLOSE c_detail;
      -- bug 5233115: unable to backorder/cycle-count overpicked
         -- lot-indivisible item because Inventory does not allow
         -- partial reservation updates.
         --
         -- Solution agreed on by WMS, WSH, and OPM:
         --   1. Blow away lot-indivisible reservation, whether
         --      overpicked or not.
         --   2. Option RETAIN_RSV will not be honored.  At this time,
         --      only WMS will pass this option (frontport bug 4721577;
         --      base bug 4656374) when unloading truck and this option is set.
         --      WMS will inform the user about this exception (bug 5350778).
         --
         -- Note that this issue can affect ATO; see the tracking bug 5350793.

         IF l_detail_rec.released_status   = 'Y' THEN
           -- call this API only if line is staged, so we can test lot
           -- divisibility.

           WSH_DELIVERY_DETAILS_INV.Get_item_information
            (
               p_organization_id       =>  l_detail_rec.organization_id,
               p_inventory_item_id     =>  l_detail_rec.inventory_item_id,
               x_mtl_system_items_rec  =>  l_item_info,
               x_return_status         =>  l_return_status
            );

           IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
             -- this is unlikely to happen
             fnd_message.set_name('WSH', 'WSH_INVALID_INV_ITEM');
             fnd_message.set_token('ITEM_NAME', l_detail_rec.inventory_item_id);
             wsh_util_core.add_message(l_return_status,l_module_name);
             x_return_status := l_return_status;
             RAISE backorder_error;
           END IF;
         ELSE
           l_item_info.lot_divisible_flag := NULL;
           l_item_info.lot_control_code   := NULL;
         END IF;

         IF l_debug_on THEN
           wsh_debug_sv.LOG(l_module_name, 'l_item_info.lot_divisible_flag', l_item_info.lot_divisible_flag);
           wsh_debug_sv.LOG(l_module_name, 'l_item_info.lot_control_code', l_item_info.lot_control_code);
           wsh_debug_sv.LOG(l_module_name, 'l_detail_rec.released_status', l_detail_rec.released_status);
         END IF;
      -- check for overpicking
      IF     (l_overpick_qtys(i) > 0) THEN  --Bug 2026099: Removed other conditions
          -- if we are backordering overpicked quantity,
          -- and the line has been split or the line is fully overpicked,
          -- then we need to decrement the picked quantities.
          -- assumption: action Cycle Count and Ship Confirm ensure
          -- that shipped_quantity won't be affected by the reduction.
          -- (Viz., if req_qty = 0, cycle count quantities must be 0.)

    --Bug 5525314
    --If the item is lot indivisible then over picked qty should be considered.
	  IF (l_item_info.lot_divisible_flag = 'N' AND
              l_item_info.lot_control_code   = 2 ) THEN
               l_new_picked_quantity := l_detail_rec.picked_quantity  ;
	  ELSE
              UPDATE wsh_delivery_details
              SET    picked_quantity  = picked_quantity  - l_overpick_qtys(i),
                     picked_quantity2 = picked_quantity2 - p_overpick_qtys2(i)
              WHERE  l_detail_ids(i) = delivery_detail_id
              RETURNING picked_quantity INTO l_new_picked_quantity;

	      --bug 7166138 new picked quantity should be updated in l_detail_rec
	      l_detail_rec.picked_quantity := l_new_picked_quantity;

	  END IF;
      ELSE
        l_new_picked_quantity := NULL;
      END IF;

      IF (NVL(l_global_param_rec.consolidate_bo_lines,'N') = 'N') THEN
         IF (l_bo_qtys(i) > 0)  THEN
         -- make a list for temporary query in STF (e.g., cycle-count).
         x_out_rows ( x_out_rows.count + 1 ) := l_bo_detail_id ;
         END IF;
      END IF;
      --

      -- bug 2730685: if a purely overpicked but completely unshipped line is packed,
      -- it needs to be unpacked so that it can be deleted,
      -- instead of becoming "shipped" with zero req/pick quantity
      -- Need to check for l_bo_qtys(i) = 0
      IF (   (l_bo_qtys(i) > 0)
          OR (l_new_picked_quantity = 0)
         ) THEN

          /* H integration: 940/945 WSH should remain assigned wrudge */
	  -- bug# 6908504 (replenishment project): Should not un-assign the planned deliveries  when called the api
          -- with p_bo_source as PICK.
          IF( l_assigned_flag = 'Y'
              AND l_detail_rec.source_code <> 'WSH'
              AND ( p_bo_source <> 'PICK' OR ( p_bo_source = 'PICK' AND l_planned_flag <> 'Y')) ) THEN
          --{
              --
              -- Debug Statements
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,  ' NEW DD TO UNASSIGN -' || L_BO_DETAIL_ID || ' TO L_UNASSIGN_DDS'  );
              END IF;
              --
              l_unassign_dd_flag := 'Y';  --deferred to the end.
              l_unassign_dds(l_unassign_dds.count + 1 ) := l_bo_detail_id ;
          --}
          END IF;
      --}
      END IF;

/*Bug 2096052 for OKE*/
      IF l_detail_rec.source_code = 'OKE' THEN
        RAISE invalid_source_code;
/* H integration: 945 backordering cancels line wrudge */
      ELSIF l_detail_rec.source_code = 'WSH' THEN
        IF l_backorder_all = 'Y' THEN
           RAISE no_backorder_full;
        ELSE
          l_delete_dds( l_delete_dds.count+1 ) := l_bo_detail_id;
        END IF;
      END IF;

/* End of Code added for  Bug 2096052*/

      IF     l_req_qtys(i) = 0
         AND l_detail_ids(i) = l_bo_detail_id
         AND  l_detail_rec.picked_quantity  = 0 THEN  -- Bug 2026260
          -- If the line is fully overpicked and not split
          --    and its picked quantity is completely backordered/cycle-counted,
          --    then mark it as deleted.
          l_delete_dds( l_delete_dds.count+1 ) := l_detail_ids(i);
      END IF;
      -- bug 1672188: unreserve if the detail is reserved
      l_reserved_flag :=WSH_DELIVERY_DETAILS_INV.LINE_RESERVED(
                   p_detail_id         => l_detail_rec.delivery_detail_id,
                   p_source_code       => l_detail_rec.source_code,
                   p_released_status   => l_detail_rec.released_status,
                   p_pickable_flag     => l_detail_rec.pickable_flag,
                   p_organization_id   => l_detail_rec.organization_id,
                   p_inventory_item_id => l_detail_rec.inventory_item_id,
                   x_return_status     => l_return_status);
      IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
      END IF;

/* Bug 2308509 */
      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                             WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
        ) THEN
        fnd_message.set_name('WSH', 'WSH_BO_RESERVED_ERROR');
        fnd_message.set_token('DETAIL_ID', l_detail_ids(i));
        wsh_util_core.add_message(l_return_status,l_module_name);
        x_return_status := l_return_status;
        RAISE backorder_error;
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_num_warn := l_num_warn + 1;
      END IF;
/* End ofBug 2308509 */

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'RESERVED FLAG = ' || L_RESERVED_FLAG  );
      END IF;
      --
      -- wsh_util_core.println('BO Mode       = ' || p_bo_mode );
-- HW BUG#:2005977


-- HW OPMCONV. Removed branching

      IF l_reserved_flag = 'Y' THEN
         -- use the original delivery detail to unreserve
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'UNRESERVE '  );
         END IF;
         --

-- HW BUG#:2005977. Need to branch
-- HW OPMCONV. Removed branching
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'OverPick Qty ',l_overpick_qtys(i));
         END IF;



         IF (l_item_info.lot_divisible_flag = 'N' AND
             l_item_info.lot_control_code   = 2 ) THEN --{ lot divisibility

           DECLARE  --{ lot indivisible reservation block
             l_bo_mode VARCHAR2(30);
             l_qty     WSH_DELIVERY_DETAILS.REQUESTED_QUANTITY%TYPE;
             l_qty2    WSH_DELIVERY_DETAILS.REQUESTED_QUANTITY2%TYPE;
           BEGIN

             l_bo_mode := p_bo_mode;
             IF l_bo_mode = 'RETAIN_RSV' THEN
               l_bo_mode := 'UNRESERVE';
             END IF;

             -- full lot indivisible reservation should be processed.
             l_qty  := l_bo_qtys(i)  + NVL(l_overpick_qtys(i),  0);
             l_qty2 := l_bo_qty2s(i) + NVL(p_overpick_qtys2(i), 0);

             IF l_debug_on THEN
               WSH_DEBUG_SV.LOG(l_module_name, 'item is lot indivisible: l_bo_mode', l_bo_mode);
               WSH_DEBUG_SV.LOG(l_module_name, 'l_qty', l_qty);
               WSH_DEBUG_SV.LOG(l_module_name, 'l_qty2', l_qty2);
             END IF;
             --Bug 5525314,If the item is lot indivisible and backorder Qty =0,
	     --then over pick Qty should not be unreserved
	     IF ((l_bo_qtys(i) > 0 AND l_detail_rec.requested_quantity >0)
	     OR (l_bo_qtys(i) = 0  AND l_detail_rec.requested_quantity = 0))
	     THEN
              WSH_DELIVERY_DETAILS_ACTIONS.UNRESERVE_DELIVERY_DETAIL(
                               p_delivery_Detail_id      => l_detail_ids(i),
                               p_unreserve_mode          => l_bo_mode ,
                               p_quantity_to_unreserve   => l_qty,
                               p_quantity2_to_unreserve  => l_qty2,
                               p_override_retain_ato_rsv => 'Y',
                               x_return_status           => l_return_status );

              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;

              IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                     WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                fnd_message.set_name('WSH', 'WSH_BO_UNRESERVE_ERROR');
                fnd_message.set_token('DETAIL_ID', l_detail_ids(i));
                fnd_message.set_token('QUANTITY', l_qty);
                wsh_util_core.add_message(l_return_status,l_module_name);
                x_return_status := l_return_status;
                RAISE backorder_error;
              ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                l_num_warn := l_num_warn + 1;
              END IF;
             END IF;
           END;  --} lot indivisible reservation block


         ELSE  -- } lot divisibility {
             -- item is not lot divisible.

            -- Bug 2824748: Call unreserve_delivery_detail with p_override_retain_ato_rsv 'Y' so that the
            --              reservations for unused overpick qty are always removed
            IF (l_overpick_qtys(i) > 0) THEN
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNRESERVE_DELIVERY_DETAIL FOR OVERPICK QTY',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
-- HW OPMCONV - Added Qty2

	      --Bug 4721577 Do not retain reservation for overpicked quantities
	      IF p_bo_mode = 'RETAIN_RSV' THEN
	      wsh_delivery_details_actions.unreserve_delivery_detail(
                               p_delivery_Detail_id    => l_detail_ids(i),
			       p_unreserve_mode        => 'UNRESERVE' ,
                               p_quantity_to_unreserve => l_overpick_qtys(i),
                               p_override_retain_ato_rsv  => 'Y',
                               x_return_status         => l_return_status );
              ELSE
                wsh_delivery_details_actions.unreserve_delivery_detail(
                               p_delivery_Detail_id    => l_detail_ids(i),
                               p_unreserve_mode        => p_bo_mode ,
                               p_quantity_to_unreserve => l_overpick_qtys(i),
                               p_quantity2_to_unreserve =>p_overpick_qtys2(i),
                               p_override_retain_ato_rsv  => 'Y',
                               x_return_status         => l_return_status );
              END IF;

              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;
              IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                    WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                fnd_message.set_name('WSH', 'WSH_BO_UNRESERVE_ERROR');
                fnd_message.set_token('DETAIL_ID', l_detail_ids(i));
                fnd_message.set_token('QUANTITY', l_overpick_qtys(i));
                wsh_util_core.add_message(l_return_status,l_module_name);
                x_return_status := l_return_status;
                RAISE backorder_error;
              ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                l_num_warn := l_num_warn + 1;
              END IF;

            END IF; -- l_overpick_qtys(i) > 0

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'BackOrder Qty ',l_bo_qtys(i));
            END IF;

            -- Bug 2824748: Call unreserve_delivery_detail with p_override_retain_ato_rsv 'N' so that the
            --              reservations for backorder qty are removed depending on the ATO profile option
            IF (l_bo_qtys(i) > 0) THEN
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNRESERVE_DELIVERY_DETAIL FOR BO QTY',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              wsh_delivery_details_actions.unreserve_delivery_detail(
                                       p_delivery_Detail_id    => l_detail_ids(i),
                                       p_unreserve_mode        => p_bo_mode ,
                                       p_quantity_to_unreserve => l_bo_qtys(i),
                                       p_quantity2_to_unreserve => l_bo_qty2s(i),
                                       p_override_retain_ato_rsv    => 'N',
                                       x_return_status         => l_return_status );

              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;
              IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                    WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                fnd_message.set_name('WSH', 'WSH_BO_UNRESERVE_ERROR');
                fnd_message.set_token('DETAIL_ID', l_detail_ids(i));
                fnd_message.set_token('QUANTITY', l_bo_qtys(i));
                wsh_util_core.add_message(l_return_status,l_module_name);
                x_return_status := l_return_status;
                RAISE backorder_error;
              ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                l_num_warn := l_num_warn + 1;

              END IF;
            END IF; -- l_bo_qtys(i) > 0

           --  CREATE MOVE ORDER HEADER  ?!!
           --  CREATE MOVE ORDER LINE    ?!!

         END IF; -- } lot divisiblity

     else
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'NOT RESERVED '  );
         END IF;
         --
     END IF; -- l_reserved_flag = Y'

     IF (l_bo_qtys(i) > 0) THEN  -- (normal backorder case)
        -- removed cursor logic to get order line subinventory since it is already present as original_subinventory
        -- unmark serial numbers if the whole line is backordered
       IF l_bo_qtys(i) = NVL(l_detail_rec.picked_quantity, l_detail_rec.requested_quantity)  AND
              (l_detail_rec.serial_number is not null OR l_detail_rec.transaction_temp_id is
                  not null ) THEN

	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.FETCH_INV_CONTROLS',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 WSH_DELIVERY_DETAILS_INV.Fetch_Inv_Controls(
		p_delivery_detail_id   => l_detail_rec.delivery_detail_id,
		p_inventory_item_id    => l_detail_rec.inventory_item_id,
		p_organization_id      => l_detail_rec.organization_id,
		p_subinventory         => l_detail_rec.subinventory,
		x_inv_controls_rec     => l_inv_controls_rec,
		x_return_status        => l_return_status);

               IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
               END IF;
/* Bug 2308509 */
         IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
           WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
           wsh_util_core.add_message(l_return_status,l_module_name);
           x_return_status := l_return_status;
           RAISE backorder_error;
         ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           l_num_warn := l_num_warn + 1;
         END IF;
/* End of Bug 2308509 */
   	 --
   	 -- Debug Statements
   	 --
   	 IF l_debug_on THEN
   	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.UNMARK_SERIAL_NUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
   	 END IF;
   	 --
   	 WSH_DELIVERY_DETAILS_INV.Unmark_Serial_Number(
		p_delivery_detail_id   => l_detail_rec.delivery_detail_id,
		p_serial_number_code   => l_inv_controls_rec.serial_code,
		p_serial_number        => l_detail_rec.serial_number,
		p_transaction_temp_id  => l_detail_rec.transaction_temp_id,
		x_return_status        => l_return_status);
/* Bug 2308509 */
               IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
               END IF;
         IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
           WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
           wsh_util_core.add_message(l_return_status,l_module_name);
           x_return_status := l_return_status;
           RAISE backorder_error;
         ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           l_num_warn := l_num_warn + 1;
         END IF;
/* End of Bug 2308509 */

             UPDATE wsh_delivery_details
                SET transaction_temp_id = NULL,
                serial_number = NULL,
	        last_update_date = SYSDATE,
	        last_updated_by =  FND_GLOBAL.USER_ID,
	        last_update_login =  FND_GLOBAL.LOGIN_ID
                WHERE delivery_detail_id = l_detail_rec.delivery_detail_id;
       END IF;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  'BACKORDER ...'  );
           WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
           -- 2807093
           WSH_DEBUG_SV.log(l_module_name,'Released Status: ', l_detail_rec.released_status);
       END IF;
       -- bug 1733849: clear TRACKING_NUMBER when not shipped
       -- HW BUG#:1885927 Need to clear lot_number,sublot_number,locator_id,
       -- preferred_grade and subinventory if the line is backordered
       -- HW BUG#:2005977 Removed the branching so OPM/Discrete
       -- can use the same update statement.
       -- bug 2320460: cycle-counted lines should not have subinventory
       --       cleared.
       --       Normally backordered lines should have order line's subinventor

       --Begin OPM bug 3561937
-- HW OPMCONV - Removed branching

           OPEN  get_pref_grade(l_detail_rec.delivery_detail_id);
           FETCH get_pref_grade INTO l_oeline_pref_grade;
           CLOSE get_pref_grade;
       --End OPM bug 3561937
       -- LSP PROJECT : locator_id,lot_number,revision should be populated with original values
       --          in case of distributed mode as well as LSP mode with clientId on WDD.
       IF (l_standalone_mode = 'D' OR (l_standalone_mode = 'L' and l_detail_rec.client_id IS NOT NULL))
       THEN
         l_standalone_mode := 'D';
       END IF;
       -- LSP PROJECT : end
       --
       UPDATE wsh_delivery_details
       SET move_order_line_id = NULL ,
            -- 2807093: For ATO items, it is possible that during Shp.Confirm CTO would have updated the rel.Status to N
            --          so checking to see if it is 'N' then it has to remain 'N' otherwise 'B'
            released_status = decode(pickable_flag,'Y', decode(released_status, 'N', released_status,'B'),'X'),
            cycle_count_quantity = NULL,
            cycle_count_quantity2 = NULL,
            shipped_quantity = NULL,
            shipped_quantity2 = NULL,
            picked_quantity = NULL,
            picked_quantity2 = NULL,
--            ship_set_id = NULL , code removed per bug 2008156
            -- Bug 2444564 : Backordered/Cycle Count lines should be reset to Original Subinventory
            subinventory = original_subinventory,
            inv_interfaced_flag = decode(pickable_flag, 'Y', nvl(inv_interfaced_flag,'N'), 'X'),
            --Standalone project Changes
            locator_id = decode(l_standalone_mode, 'D', original_locator_id, NULL),
        -- OPM Bug 3561937 replaced NULL with l_oeline_pref_grade
            preferred_grade = l_oeline_pref_grade,
-- HW OPMCONV. No need for sublot anymore
--          sublot_number=NULL,
            --Standalone project Changes Starts
            lot_number = decode(l_standalone_mode, 'D', original_lot_number, NULL)   , -- Bug 1705057
            revision   = decode(l_standalone_mode, 'D', original_revision, NULL) ,
            --Standalone project Changes Ends
            batch_id   = null ,  -- Bug 2711490
            -- tracking_number = NULL, Bug# 3632485
            transaction_id = NULL,  --- 2803570
            replenishment_status = NULL   -- bug# 6908504 (replenishment project), update replenishment status to NULL.
       WHERE delivery_detail_id = l_detail_rec.delivery_detail_id AND
            NVL(container_flag, 'N') = 'N' ;


		    WSH_DD_TXNS_PVT.create_dd_txn_from_dd  (p_delivery_detail_id => l_detail_rec.delivery_detail_id,
		 										x_dd_txn_id => l_dd_txn_id,
												x_return_status =>l_txn_return_status);
		IF (l_txn_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			 x_return_status := l_txn_return_status;
			 --RETURN;
                         raise e_return_excp; -- LPN CONV. rv
	       END IF;


	--Raise Event: Pick To Pod Workflow
	  WSH_WF_STD.Raise_Event(
							p_entity_type => 'LINE',
							p_entity_id => l_detail_rec.delivery_detail_id ,
							p_event => 'oracle.apps.wsh.line.gen.backordered' ,
							--p_parameters IN wf_parameter_list_t DEFAULT NULL,
							p_organization_id => l_detail_rec.organization_id,
							x_return_status => l_wf_rs ) ;
	 --Error Handling to be done in WSH_WF_STD.Raise_Event itself
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
	     WSH_DEBUG_SV.log(l_module_name,'Delivery Detail Id is  ', l_detail_rec.delivery_detail_id );
	     wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
	 END IF;
	 --Even if raising of event fails the flow continues.
	 --IF (l_wf_rs <>WSH_UTIL_CORE.G_RET_STS_SUCCESS ) then
			--No Action
	 --END IF;
	--Done Raise Event: Pick To Pod Workflow

    END IF;  -- l_bo_qtys(i) > 0 (normal backorder case)

    -- Consolidation of BO Delivery Details project
    IF (l_global_param_rec.consolidate_bo_lines = 'Y' AND p_line_ids.COUNT > 1) THEN
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Adding the Consolidated BO Qty to the Requested Qty of the BO delivery detail ',WSH_DEBUG_SV.C_PROC_LEVEL);
    	    WSH_DEBUG_SV.logmsg(l_module_name,'..delivery detail id: '||l_detail_rec.delivery_detail_id, WSH_DEBUG_SV.C_PROC_LEVEL);
       	    WSH_DEBUG_SV.logmsg(l_module_name,'..delivery detail req qty: '||l_bo_qtys(i), WSH_DEBUG_SV.C_PROC_LEVEL);
	    WSH_DEBUG_SV.logmsg(l_module_name,'..Consolidate BO quantity '||l_remain_bo_qtys(i), WSH_DEBUG_SV.C_PROC_LEVEL);
		-- HW OPM BUG#:3121616 added qty2s
            WSH_DEBUG_SV.logmsg(l_module_name,'..Consolidate BO quantity2 '||l_remain_bo_qty2s(i), WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
-- HW OPM BUG#:3121616 added requested_quantity2
	UPDATE WSH_DELIVERY_DETAILS
	SET     requested_quantity = requested_quantity + l_remain_bo_qtys(i),
                requested_quantity2 = requested_quantity2 + l_remain_bo_qty2s(i)
	WHERE delivery_detail_id = l_detail_rec.delivery_detail_id;

	WSH_DD_TXNS_PVT.create_dd_txn_from_dd(p_delivery_detail_id => l_detail_rec.delivery_detail_id,
                                              x_dd_txn_id => l_dd_txn_id,
                                              x_return_status =>l_txn_return_status);
        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          raise e_return_excp;
        END IF;

	l_bo_qtys(i)  := l_bo_qtys(i)  + l_remain_bo_qtys(i);
	l_req_qtys(i) := l_bo_qtys(i);
-- HW OPM BUG#:3121616 added qty2s
        l_bo_qty2s(i)  := l_bo_qty2s(i)  + l_remain_bo_qty2s(i);
-- end of 3121616
    END IF;

    -- DBI Project, Above 2 Update statements are executed for l_detail_rec.delivery_detail_id
    -- Combining the 2 updates and making 1 call to DBI for the updates in WDD table
    -- These update released_status/requested_quantity
    -- This is different from l_detail_ids which is the set of ids for which LOOP is
    -- getting executed
    --
    -- Update of wsh_delivery_details where requested_quantity/released_status
    -- are changed, call DBI API after the update.
    -- This API will also check for DBI Installed or not
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',l_detail_rec.delivery_detail_id);
    END IF;
    l_detail_tab(1) := l_detail_rec.delivery_detail_id;
    WSH_INTEGRATION.DBI_Update_Detail_Log
      (p_delivery_detail_id_tab => l_detail_tab,
       p_dml_type               => 'UPDATE',
       x_return_status          => l_dbi_rs);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
    END IF;
    IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_dbi_rs;
      -- just pass this return status to caller API, raise as above
      -- Added in Above API already,wsh_util_core.add_message(x_return_status,l_module_name);
      RAISE backorder_error;
    END IF;
    -- treat all other return status as Success
    -- End of Code for DBI Project
    --

    -- J: W/V Changes
    IF l_bo_qtys(i) > 0 Then -- Bug 3547300
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_WV_UTILS.Detail_Weight_Volume(
      p_delivery_detail_id => l_detail_rec.delivery_detail_id,
      p_update_flag        => 'Y',
      p_post_process_flag  => 'Y',
      p_calc_wv_if_frozen  => 'Y',
      x_net_weight         => l_split_weight,
      x_volume             => l_split_volume,
      x_return_status      => l_return_status);
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;
    IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
      wsh_util_core.add_message(l_return_status,l_module_name);
      x_return_status := l_return_status;
      RAISE new_det_wt_vol_failed;
    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      l_num_warn := l_num_warn + 1;
    END IF;
    END IF; -- Bug 3547300

    -- bug # 6749200 (replenishment project ) : Moved the backorder consolidation code to inside the loop as the API needs to be called
    -- for each record separately.
    -- Bug#3317692
    -- Consolidation of BO Delivery Details project
    -- Get the delivery details with non-zero requested quantity to pass to Consolidate_Source_Line
    -- bug# 6908504 (replenishment project): Should not consolidate when the dd is assigned to a planned deliveries
    -- and p_bo_source is3/27/2008 PICK.
    IF ( (l_req_qtys(i) > 0 AND l_global_param_rec.consolidate_bo_lines = 'Y' )
         AND ( p_bo_source <> 'PICK' OR ( p_bo_source = 'PICK' AND l_planned_flag <> 'Y')) ) THEN
    --{

	  -- unassign and unpack empty container Added in bug 7460785
          --
          -- Debug Statements

          IF (l_unassign_dds.COUNT > 0 and l_unassign_dds(l_unassign_dds.COUNT) = l_bo_detail_id ) THEN
          --{
              l_unassign_dds_tmp(1) := l_bo_detail_id;

	      IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.unassign_unpack_empty_cont',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              -- p_validate_flag is passed as 'N', so that backordering does not fail for planned Deliveries.
              WSH_DELIVERY_DETAILS_ACTIONS.unassign_unpack_empty_cont
	      (
	        p_ids_tobe_unassigned  => l_unassign_dds_tmp ,
	        p_validate_flag => 'N',
	        x_return_status   => l_return_status
	      );

	      --
	      -- Debug Statements
	      --
	      IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,  'AFTER UNASSIGN AND UNPACK EMPTY CONTAINER '|| L_RETURN_STATUS  );
	      END IF;

	      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	      --{
	          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		    l_num_warn := l_num_warn + 1;
		  ELSE
		    x_return_status := l_return_status;
		    RAISE backorder_error;
		  END IF;
	      --}
	      END IF;

	      l_unassign_dds.DELETE(l_unassign_dds.COUNT);
	 --}
	 END IF; -- unpack and un-assign the deliveries

	 -- consolidate logic
        l_cons_source_line_rec_tab.delete;
        l_cons_dd_ids.delete;
        l_cons_source_line_rec_tab(1).delivery_detail_id := l_bo_detail_id;
	l_cons_source_line_rec_tab(1).source_line_id := l_detail_rec.source_line_id;
 	l_cons_source_line_rec_tab(1).delivery_id := l_delivery_id;
	l_cons_source_line_rec_tab(1).bo_qty := l_bo_qtys(i);
	l_cons_source_line_rec_tab(1).req_qty := l_bo_qtys(i);
        -- HW OPM BUG#:3121616 added qty2s
	l_cons_source_line_rec_tab(1).bo_qty2 := l_bo_qty2s(i);
	l_cons_source_line_rec_tab(1).req_qty2 := l_bo_qty2s(i);
        -- end of 3121616
        --
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.Consolidate_Source_Line',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_DELIVERY_DETAILS_ACTIONS.Consolidate_Source_Line(
	    p_Cons_Source_Line_Rec_Tab => l_cons_source_line_rec_tab,
	    x_consolidate_ids          => l_cons_dd_ids,
	    x_return_status            => l_return_status
	    );
        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR )THEN
	--{
	    x_return_status := l_return_status;
	    RAISE backorder_error;
        --}
	END IF;
	IF l_cons_dd_ids.COUNT > 0 THEN
	--{
	    x_out_rows( x_out_rows.COUNT + 1)  := l_cons_dd_ids(l_cons_dd_ids.FIRST);
            -- Setting the corresponding flag to 'Y', if a delivery detail is consolidated
	    -- into some other delivery detail.
	    IF l_cons_source_line_rec_tab(1).delivery_detail_id = l_cons_dd_ids(l_cons_dd_ids.FIRST) THEN
                x_cons_flags(x_cons_flags.COUNT+1) := 'N';
	    ELSE
	        x_cons_flags(x_cons_flags.COUNT+1) := 'Y';

	    -- Back order consolidation takes care of un-assigning/unpacking so no need to call separately.
            IF ( l_unassign_dd_flag = 'Y' ) THEN
            --{
                l_unassign_dds.delete(l_unassign_dds.count);
                l_unassign_dd_flag := 'N';
            --}
            END IF;

	    END IF;
        --}
	END IF;
    --}
    END IF;
      --
  <<loop_end>>
  NULL;
  END LOOP;  --}

  -- unassign and unpack empty container
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.unassign_unpack_empty_cont',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  -- p_validate_flag is passed as 'N', so that backordering does not fail for planned Deliveries.
  WSH_DELIVERY_DETAILS_ACTIONS.unassign_unpack_empty_cont (
                               p_ids_tobe_unassigned  => l_unassign_dds ,
                               p_validate_flag => 'N',
                               x_return_status   => l_return_status
                              );

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,  'AFTER UNASSIGN AND UNPACK EMPTY CONTAINER '|| L_RETURN_STATUS  );
  END IF;
  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
     IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          l_num_warn := l_num_warn + 1;
     ELSE
          x_return_status := l_return_status;
          RAISE backorder_error;
     END IF;
  END IF;

  IF l_delete_dds.count > 0 THEN
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTERFACE.DELETE_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_INTERFACE.Delete_Details(
      p_details_id      =>    l_delete_dds,
      x_return_status   =>    l_return_status
      );
    --
    -- Debug Statements
    --

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'AFTER DELETING DETAIL '|| L_RETURN_STATUS  );
    END IF;
    --
/* Bug 2308509 */
    IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
        WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
       )THEN
      x_return_status := l_return_status;
      RAISE backorder_error;
    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      l_num_warn := l_num_warn + 1;
    END IF;
/* End of Bug 2308509 */
  END IF; -- l_delete_dds.count > 0

/*Bug#:2026895*/
if p_bo_mode = 'CYCLE_COUNT' then
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.CHECK_SHIP_SET',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_delivery_validations.check_ship_set( l_delivery_id, l_valid_flag, l_return_status);
/* Bug 2308509 */
    IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
        WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
       )THEN
      x_return_status := l_return_status;
      RAISE backorder_error;
    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      l_num_warn := l_num_warn + 1;
    END IF;
/* End of Bug 2308509 */

   --
   -- K LPN CONV. rv
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   --
   IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
   THEN
   --{

       WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
         (
           p_in_rec             => l_lpn_in_sync_comm_rec,
           x_return_status      => l_return_status,
           x_out_rec            => l_lpn_out_sync_comm_rec
         );
       --
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
       END IF;
       --
       --
       IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
           WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
          )THEN
         x_return_status := l_return_status;
         RAISE backorder_error;
       ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         l_num_warn := l_num_warn + 1;
       END IF;
   --}
   END IF;
   --
   -- K LPN CONV. rv
   --


/* Warning Handling for Bug 2308509 */
   IF (l_num_warn > 0
       AND l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
      )THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
-- for handling all the cases
   ELSIF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                             WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
     x_return_status := l_return_status;
     RAISE backorder_error;
   END IF;
/* End of Warning Handling for Bug 2308509 */

   IF NOT (l_valid_flag) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_SHIP_SET_INCOMPLETE');
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(l_delivery_id));
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
   END IF;
end if;


--Bugfix 4070732 {
IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API) = upper(l_api_session_name) THEN
--{
   IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
   --{
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                  x_return_status => l_return_status);

      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
      END IF;

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;

         IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
         THEN
            ROLLBACK TO before_backorder;
         END IF;
      END IF;
    --}
   END IF;
--}
END IF;
--}
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN e_return_excp THEN

          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,WSH_UTIL_CORE.G_RET_STS_ERROR) AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'E_RETURN_EXCP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_RETURN_EXCP');
          END IF;
          --


  WHEN backorder_error THEN
    -- code sets messages before raising backorder_error.
    ROLLBACK to before_backorder;
    --
    -- Debug Statements
    --
    --Bugfix 4070732 {
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
       IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                    x_return_status => l_return_status);


          IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;

          IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
          END IF;
       END IF;
    END IF;
    --}
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'BACKORDER_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:BACKORDER_ERROR');
    END IF;
    --
    RETURN;

-- HW 3457369
-- HW OPMCONV. Removed OPM exception
--

/*Bug 2096052 added exception */
--
-- Debug Statements
--
--
  WHEN invalid_source_code THEN
    fnd_message.set_name('WSH','WSH_INVALID_SHIP_MODE');
    wsh_util_core.add_message(x_return_status,l_module_name);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ROLLBACK to before_backorder ;
/* End of changes for 2096052 */

    --Bugfix 4070732 {
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
       IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                    x_return_status => l_return_status);


          IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;

          IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
          END IF;

       END IF;
    END IF;
    --}
  /* Bug 2399729 disallow backorder full for third party warehouse shipment line */
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_SOURCE_CODE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_SOURCE_CODE');
  END IF;
  --
  WHEN no_backorder_full THEN
    fnd_message.set_name('WSH','WSH_BKALL_NOT_ALLOW');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    wsh_util_core.add_message(x_return_status,l_module_name);
    ROLLBACK to before_backorder ;

    --Bugfix 4070732 {
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
       IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                    x_return_status => l_return_status);


          IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;

          IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
          END IF;

       END IF;
    END IF;
    --}

  	--
  	-- Debug Statements
  	--
  	IF l_debug_on THEN
  	    WSH_DEBUG_SV.logmsg(l_module_name,'NO_BACKORDER_FULL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
  	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_BACKORDER_FULL');
  	END IF;
  	--
  WHEN new_det_wt_vol_failed THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		fnd_message.set_name('WSH', 'WSH_DET_WT_VOL_FAILED');
		FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_detail_rec.delivery_detail_id  );
		wsh_util_core.add_message(x_return_status,l_module_name);

          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
    --Bugfix 4070732 {
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
       IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                    x_return_status => l_return_status);


          IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;

          IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
          END IF;

       END IF;
    END IF;
    --}
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'NEW_DET_WT_VOL_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NEW_DET_WT_VOL_FAILED');
END IF;
--
  WHEN OTHERS THEN
    WSH_UTIL_CORE.Default_Handler('WSH_SHIP_CONFIRM_ACTIONS2.Backorder',l_module_name);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    ROLLBACK to before_backorder ;
    --Bugfix 4070732 {
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
       IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                    x_return_status => l_return_status);


          IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;
       END IF;
    END IF;
    --}
    --
    -- Debug Statements
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

    RETURN ;

END Backorder;

PROCEDURE check_exception(
  p_delivery_detail_id    IN     NUMBER
, x_exception_exist          OUT NOCOPY  VARCHAR2
, x_severity_present         OUT NOCOPY  VARCHAR2
, x_return_status            OUT NOCOPY  VARCHAR2)
IS

l_not_handled    VARCHAR2(30):='NOT_HANDLED';
l_no_action_reqd VARCHAR2(30):='NO_ACTION_REQUIRED';
l_closed         VARCHAR2(30):='CLOSED';

CURSOR c_exception IS
SELECT decode(severity,'HIGH','H','MEDIUM','M','L') severity
FROM   wsh_exceptions
WHERE  delivery_detail_id = p_delivery_detail_id
AND    status not in (l_not_handled , l_no_action_reqd , l_closed)
ORDER BY decode(severity,'H',1,'M',2,3);

l_count	NUMBER := 0;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_EXCEPTION';
--
BEGIN
   --
   -- Debug Statements
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN c_exception;
   FETCH c_exception INTO x_severity_present;
   IF c_exception%NOTFOUND THEN
      x_exception_exist  := 'N';
   ELSE
      x_exception_exist  := 'Y';
   END IF;
   CLOSE c_exception;

   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_exception_exist',x_exception_exist);
       WSH_DEBUG_SV.log(l_module_name,'x_severity_present',x_severity_present);
   END IF;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        WSH_UTIL_CORE.default_handler('WSH_SHIP_CONFIRM_ACTIONS2.check_exception',l_module_name);

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
--
END check_exception;

--
-- Procedure:       Backorder
-- Description:     This is a wrapper of the BackOrder procedure already present in the package.
--		    This is introduced for Consolidation of BO Delivery Details project.
--		    This wrapper avoids the change of the calls made to Backorder api from different apis
--		    (as additional parameter is added to the original backorder api).
--
PROCEDURE Backorder(
  p_detail_ids           IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_bo_qtys              IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_req_qtys             IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_bo_qtys2             IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_overpick_qtys        IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_overpick_qtys2       IN     WSH_UTIL_CORE.Id_Tab_Type,
  p_bo_mode              IN     VARCHAR2,
  p_bo_source            IN     VARCHAR2 DEFAULT 'SHIP',
  x_out_rows             OUT NOCOPY     WSH_UTIL_CORE.Id_Tab_Type,
  x_return_status        OUT NOCOPY     VARCHAR2   )
  IS

  l_line_ids	WSH_UTIL_CORE.Id_Tab_Type;
  l_cons_flags  WSH_UTIL_CORE.Column_Tab_Type;
  l_return_status VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'BACKORDER';
--
BEGIN
  --
  -- Debug Statements
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
      WSH_DEBUG_SV.log(l_module_name,'P_BO_MODE',P_BO_MODE);
      WSH_DEBUG_SV.log(l_module_name,'P_BO_SOURCE',P_BO_SOURCE);
  END IF;
  --

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIP_CONFIRM_ACTIONS2.BackOrder',WSH_DEBUG_SV.C_PROC_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'......with p_line_ids as NULL', WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  Backorder(
  p_detail_ids           => p_detail_ids,
  p_line_ids		 => l_line_ids,
  p_bo_qtys              => p_bo_qtys,
  p_req_qtys             => p_req_qtys,
  p_bo_qtys2             => p_bo_qtys2,
  p_overpick_qtys        => p_overpick_qtys,
  p_overpick_qtys2       => p_overpick_qtys2,
  p_bo_mode              => p_bo_mode,
  p_bo_source            => p_bo_source,
  x_out_rows             => x_out_rows,
  x_cons_flags		 => l_cons_flags,
  x_return_status        => x_return_status   );

  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status '|| x_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

END BackOrder;

END WSH_SHIP_CONFIRM_ACTIONS2;

/
