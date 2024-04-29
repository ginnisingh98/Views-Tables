--------------------------------------------------------
--  DDL for Package Body WSH_CONTAINER_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CONTAINER_UTILITIES" as
/* $Header: WSHCMUTB.pls 120.5 2006/10/30 23:13:42 wrudge noship $ */


/*
-----------------------------------------------------------------------------
   FUNCTION   : Get Master Cont Id
   PARAMETERS : p_container_instance_id - instance id for the container
   RETURNS    : master container instance id
  DESCRIPTION : This function derives the master container instance id
		of the container by using a heirarchical SQL query on
		wsh_delivery_assignments_v table. This function can be used in
		SELECT statements that need to use the master container id.
------------------------------------------------------------------------------
*/


--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_CONTAINER_UTILITIES';
--
FUNCTION Get_Master_Cont_Id (p_cont_instance_id IN NUMBER) RETURN NUMBER IS

 l_mast_cont_id NUMBER;

 CURSOR Get_Master_Cont (v_cont_inst_id NUMBER) IS
 SELECT delivery_detail_id
 FROM wsh_delivery_assignments
 WHERE parent_delivery_detail_id IS NULL
 AND  NVL(type, 'S') in ('S', 'C')
 START WITH delivery_detail_id = v_cont_inst_id
 AND  NVL(type, 'S') in ('S', 'C')
 CONNECT BY PRIOR parent_delivery_detail_id = delivery_detail_id;

--
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_MASTER_CONT_ID';
--
BEGIN

 --
 --
 --
 OPEN Get_Master_Cont (p_cont_instance_id);

 FETCH Get_Master_Cont INTO l_mast_cont_id;

 IF Get_Master_Cont%NOTFOUND THEN
 	l_mast_cont_id := null;
 END IF;

 CLOSE Get_Master_Cont;

 IF (l_mast_cont_id = p_cont_instance_id) THEN
    l_mast_cont_id := NULL;
 END IF;

 --
 RETURN l_mast_cont_id;

END Get_Master_Cont_Id;


/*
-----------------------------------------------------------------------------
   FUNCTION   : Get Cont Name
   PARAMETERS : p_cont_instance_id - instance id for the container
   RETURNS    : container name for the container instance id
  DESCRIPTION : This function derives the container name for the container id

------------------------------------------------------------------------------
*/


FUNCTION Get_Cont_Name (p_cont_instance_id IN NUMBER) RETURN VARCHAR2 IS

l_cont_name VARCHAR2(30);

 CURSOR Get_Name (v_cont_inst_id NUMBER) IS
 SELECT container_name
 FROM WSH_DELIVERY_DETAILS
 WHERE delivery_detail_id = v_cont_inst_id
 AND container_flag  in ('Y', 'C');

--
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CONT_NAME';
--
BEGIN

 --
 --
 --
 IF (p_cont_instance_id IS NULL) THEN
    --
    RETURN NULL;
 END IF;

 OPEN Get_Name (p_cont_instance_id);

 FETCH Get_Name INTO l_cont_name;

 IF Get_Name%NOTFOUND THEN
 	l_cont_name := null;
 END IF;

 CLOSE Get_Name;

 --
 RETURN l_cont_name;

END Get_Cont_Name;



/*
-----------------------------------------------------------------------------
   PROCEDURE  : Validate_Hazard_Class
   PARAMETERS : p_delivery_detail_id - delivery detail id
		p_container_instance_id - delivery detail id of container
		x_return_status - return status of API
  DESCRIPTION : This procedure retrieves the hazard class id of the delivery
		detail id and checks if there is any incompatability or
		special restrictions on packing the detail into the specified
		container.  Also checks to see if the hazard class for the
		detail is incompatible with the other details already in the
		container. It returns a success if there are no restrictions
		and returns an error if there is any invalid hazard class.
------------------------------------------------------------------------------
*/


PROCEDURE Validate_Hazard_Class (
 p_delivery_detail_id IN NUMBER,
 p_container_instance_id IN NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2) IS


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_HAZARD_CLASS';
--
BEGIN

-- dummy API for now. will add validation code later on, once the hazard class
-- information is available.


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
    WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
END IF;
--
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END Validate_Hazard_Class;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Validate_Hold_Code
   PARAMETERS : p_delivery_detail_id - delivery detail id
		x_return_status - return status of API
  DESCRIPTION : This procedure retrieves the hold code for the delivery detail
		id and returns a success if there is no hold code and returns
		an error if there is any invalid hold code.
------------------------------------------------------------------------------
*/


PROCEDURE Validate_Hold_Code (
  p_delivery_detail_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_HOLD_CODE';
--
BEGIN

-- dummy API for now because the hold codes haven't been finalized. Add code
-- later on.

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

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END Validate_Hold_Code;

-- Bug 2381184
-- Note there are 2 api with same name of estimate detail container
-- the name is same to keep the changes consistent in both.
-- work to call one of them and have single place for code.
/*
-----------------------------------------------------------------------------
   PROCEDURE  : Estimate Detail Containers
   PARAMETERS : p_container_instance_id - instance id for the container
		x_container_item_id - container item for estimation
		p_delivery_detail_id - the delivery detail id for which the
			number of containers is being estimated
		p_organization_id - organization_id
		x_num_cont - number of containers required to pack the line.
		x_return_status - return status of API
                x_max_qty_per_lpn - returns maximum quantity per LPN
                x_fill_pc_per_lpn - returns fill percent per LPN for Q,W or V
  DESCRIPTION : This procedure estimates the number of detail containers that
		would be required to pack a delivery detail.  The container
		item could be specified or if it is not specified, it is
		derived from the delivery detail or through the container load
		relationship. Using the inventory item and quantity on the
		detail and the container item, the number of containers is
		calculated/estimated.
                THIS IS USED ONLY FROM PACK_EMPTY_CONTS as of now.
------------------------------------------------------------------------------
*/

PROCEDURE Estimate_Detail_Containers(
   p_in_record IN inrectype,
   x_inout_record IN OUT NOCOPY  inoutrectype,
   x_out_record OUT NOCOPY  outrectype,
   x_return_status OUT NOCOPY  VARCHAR2
  ) IS

CURSOR Get_Cont_Load (v_cont_id NUMBER, v_inv_item_id NUMBER) IS
SELECT max_load_quantity, container_item_id
FROM WSH_CONTAINER_ITEMS
WHERE container_item_id = NVL(v_cont_id, container_item_id)
AND load_item_id = v_inv_item_id
AND master_organization_id = p_in_record.organization_id
AND preferred_flag = DECODE(nvl(v_cont_id,-99),-99,'Y',preferred_flag);

CURSOR get_flag_value (v_inv_item_id NUMBER, v_org_id NUMBER) IS
SELECT indivisible_flag
  FROM mtl_system_items
 WHERE organization_id = v_org_id
  AND inventory_item_id  = v_inv_item_id;

CURSOR Get_Delivery_Details (v_del_detail_id NUMBER) IS
SELECT delivery_detail_id, inventory_item_id, item_description,
       nvl(shipped_quantity,
           NVL(picked_quantity, requested_quantity)) packed_qty,
       requested_quantity_uom,
       master_container_item_id, detail_container_item_id, hold_code,
       load_seq_number, net_weight,
       weight_uom_code, volume, volume_uom_code, organization_id
FROM WSH_DELIVERY_DETAILS
WHERE delivery_detail_id = v_del_detail_id
AND container_flag = 'N';

CURSOR Get_Container_Info (v_cont_instance_id NUMBER, v_org_id NUMBER)IS
SELECT delivery_detail_id container_instance_id, container_name lpn,
       inventory_item_id container_item_id, item_description,
       gross_weight, net_weight, (gross_weight - net_weight), weight_uom_code,
       volume, volume_uom_code, fill_percent, maximum_load_weight,
       maximum_volume, minimum_fill_percent
FROM WSH_DELIVERY_DETAILS
WHERE delivery_detail_id = v_cont_instance_id
AND organization_id = v_org_id
AND  container_flag  in ('Y', 'C');

CURSOR Get_Cont_Msi (v_cont_item_id NUMBER, v_org_id NUMBER) IS
SELECT maximum_load_weight, internal_volume, weight_uom_code, volume_uom_code
FROM MTL_SYSTEM_ITEMS
WHERE inventory_item_id = v_cont_item_id
AND organization_id = v_org_id;

CURSOR Get_Fill_Basis (v_org_id NUMBER) IS
SELECT percent_fill_basis_flag
FROM WSH_SHIPPING_PARAMETERS
WHERE organization_id = v_org_id;

CURSOR get_cont_fill_qty (v_container_instance_id NUMBER) IS
SELECT sum(nvl(wdd.shipped_quantity,
           NVL(wdd.picked_quantity, wdd.requested_quantity))) packed_qty
FROM wsh_delivery_details wdd
WHERE wdd.delivery_detail_id IN
   (SELECT wda.delivery_detail_id
      FROM wsh_delivery_assignments_v wda
     WHERE wda.parent_delivery_detail_id IS NOT NULL
       AND wda.parent_delivery_detail_id = v_container_instance_id)
 AND wdd.container_flag ='N';

l_cont_gross		NUMBER;
l_cont_net		NUMBER;
l_cont_tare		NUMBER;
l_cont_weight_uom	VARCHAR2(3);
l_cont_volume		NUMBER;
l_cont_vol_uom		VARCHAR2(3);
l_lpn			VARCHAR2(30);
l_par_cont_id		NUMBER;
l_cont_item_id		NUMBER;
l_cont_description	VARCHAR2(240);
l_fill_pc		NUMBER;
l_max_load_wt		NUMBER;
l_min_fill_pc		NUMBER;
l_max_volume		NUMBER;
l_max_load_qty		NUMBER;
l_dd_master_cont_id	NUMBER;
l_dd_det_cont_id	NUMBER;
l_dd_inv_item_id	NUMBER;
l_dd_inv_item_desc	VARCHAR2(240);
l_dd_packed_qty		NUMBER;
l_dd_hold_flag		VARCHAR2(1);
l_dd_gross_wt		NUMBER;
l_dd_net_wt		NUMBER;
l_dd_tare_wt		NUMBER;
l_dd_volume		NUMBER;
l_dd_vol_uom		VARCHAR2(3);
l_dd_wt_uom		VARCHAR2(3);
l_dd_req_qty_uom	VARCHAR2(3);
l_wcl_cont_item_id	NUMBER;
l_dd_org_id		NUMBER;
l_cont_org_id		NUMBER;
l_del_det_id		NUMBER;
l_cont_instance_id	NUMBER;
l_dd_load_seq_num	NUMBER;
l_num_cont		NUMBER;
l_mtl_wt_uom		VARCHAR2(3);
l_mtl_vol_uom		VARCHAR2(3);
l_mtl_max_load		NUMBER;
l_mtl_max_vol		NUMBER;
l_fill_pc_basis		VARCHAR2(1);

l_item_name		VARCHAR2(2000);
l_org_name		VARCHAR2(240);

-- get temporary count of number of containers required
l_tmp_num_cont         NUMBER;
l_discard_message       VARCHAR2(2000);
l_output_qty            NUMBER;
l_return_status         VARCHAR2(3);
l_item_indivisible      VARCHAR2(1) := 'N';
l_max_qty_per_lpn       NUMBER := 0;
l_fill_pc_per_lpn       NUMBER := 0;

--the values can be Q1(with preferred container), Q2(without preferred container), W or V
l_fill_pc_flag          VARCHAR2(2) := 'Q1';
l_dd_numerator          NUMBER;
-- make precision constant thru out the packing code
LIMITED_PRECISION       NUMBER := 8;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ESTIMATE_DETAIL_CONTAINERS';
--
BEGIN

   -- dbms_output.put_line('in estimating detail containers');
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
  END IF;
  --
  x_out_record.max_qty_per_lpn := 0;
  x_out_record.fill_pc_per_lpn := 0;

   OPEN Get_Delivery_Details (p_in_record.delivery_detail_id);

   FETCH Get_Delivery_Details INTO
   l_del_det_id,
   l_dd_inv_item_id,
   l_dd_inv_item_desc,
   l_dd_packed_qty,
   l_dd_req_qty_uom,
   l_dd_master_cont_id,
   l_dd_det_cont_id,
   l_dd_hold_flag,
   l_dd_load_seq_num,
   l_dd_net_wt,
   l_dd_wt_uom,
   l_dd_volume,
   l_dd_vol_uom,
   l_dd_org_id;


   IF (Get_Delivery_Details%NOTFOUND) THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	-- dbms_output.put_line('no delivery details');
        FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
	FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_in_record.delivery_detail_id);
	CLOSE Get_Delivery_Details;
	WSH_UTIL_CORE.Add_Message(x_return_status);
 	--
 	-- Debug Statements
 	--
 	IF l_debug_on THEN
 	    WSH_DEBUG_SV.pop(l_module_name);
 	END IF;
 	--
 	return;
   END IF;

   CLOSE Get_Delivery_Details;

   x_inout_record.container_item_id := NVL(NVL(l_dd_det_cont_id, l_dd_master_cont_id), x_inout_record.container_item_id);

   --dbms_output.put_line('x cont item is ' || x_inout_record.container_item_id || ' and inv item is ' || l_dd_inv_item_id || ' and org is ' || p_in_record.organization_id);

   OPEN Get_Cont_Load (x_inout_record.container_item_id, l_dd_inv_item_id);

   FETCH Get_Cont_Load INTO
   l_max_load_qty,
   l_wcl_cont_item_id;

   IF (Get_Cont_Load%NOTFOUND AND x_inout_record.container_item_id IS NULL) THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ITEM_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_item_name := WSH_UTIL_CORE.Get_Item_Name(l_dd_inv_item_id,l_dd_org_id);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_org_name := WSH_UTIL_CORE.Get_Org_Name(p_in_record.organization_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONT_LOAD');
	FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
	FND_MESSAGE.SET_TOKEN('ORG_NAME',l_org_name);
	-- dbms_output.put_line('error in get cont load');
	CLOSE Get_Cont_Load;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
   END IF;

  CLOSE Get_Cont_Load;

   x_inout_record.container_item_id := NVL(x_inout_record.container_item_id, l_wcl_cont_item_id);

   -- dbms_output.put_line('before check for p_container_instance_id');

   IF (p_in_record.container_instance_id IS NOT NULL) THEN

      OPEN Get_Container_Info(p_in_record.container_instance_id, nvl(p_in_record.organization_id,l_dd_org_id));

      FETCH Get_Container_Info INTO
	l_cont_instance_id,
	l_lpn,
	l_cont_item_id,
	l_cont_description,
	l_cont_gross,
	l_cont_net,
	l_cont_tare,
	l_cont_weight_uom,
	l_cont_volume,
	l_cont_vol_uom,
	l_fill_pc,
	l_max_load_wt,
	l_max_volume,
	l_min_fill_pc;


      IF Get_Container_Info%NOTFOUND THEN
	   -- it means that no container load defined. may need to get it from
	   -- container instances table.
	   -- if container isntance id also not defined then
	   -- raise container_item_error;
	    CLOSE Get_Container_Info;
	    -- dbms_output.put_line('container not found');
 	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
	    FND_MESSAGE.SET_TOKEN('CONT_NAME',l_lpn);
	    WSH_UTIL_CORE.Add_Message(x_return_status);
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    --
	    return;

      END IF;

      CLOSE Get_Container_Info;

      x_inout_record.container_item_id := NVL(x_inout_record.container_item_id,l_cont_item_id);

   END IF;

   -- dbms_output.put_line('after container instance check');

   IF (x_inout_record.container_item_id IS NULL) THEN
	   -- it means that no container defined for this item type
	   -- raise container_item_error;
	   -- FND_MESSAGE.SET_NAME('WSH','WSH_CONT_EST_ERROR');
           -- dbms_output.put_line('no container item');
	   -- WSH_UTIL_CORE.Add_Message(x_return_status);
 	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  	   --
  	   -- Debug Statements
  	   --
  	   IF l_debug_on THEN
  	       WSH_DEBUG_SV.pop(l_module_name);
  	   END IF;
  	   --
  	   return;
   ELSE

           OPEN Get_Cont_Msi(x_inout_record.container_item_id, nvl(p_in_record.organization_id,l_dd_org_id));

 	   FETCH Get_Cont_Msi INTO
	   l_mtl_max_load,
  	   l_mtl_max_vol,
	   l_mtl_wt_uom,
	   l_mtl_vol_uom;

	   IF Get_Cont_Msi%NOTFOUND THEN
		-- dbms_output.put_line('no cont_item in mtl_system_items');
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ITEM_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_item_name := WSH_UTIL_CORE.Get_Item_Name(x_inout_record.container_item_id,nvl(p_in_record.organization_id,l_dd_org_id));
		FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_INV_ITEM');
		FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		CLOSE Get_Cont_Msi;
		WSH_UTIL_CORE.Add_Message(x_return_status);
	        --
	        -- Debug Statements
	        --
	        IF l_debug_on THEN
	            WSH_DEBUG_SV.pop(l_module_name);
	        END IF;
	        --
	        return;
	   END IF;

	   CLOSE Get_Cont_Msi;


	   -- dbms_output.put_line('max load wt before convert is ' || l_mtl_max_load || 'wt uom ' || l_mtl_wt_uom || ' cont wt uom ' || l_cont_weight_uom);

	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
	   END IF;
	   --
	   l_max_load_wt := NVL(l_max_load_wt, WSH_WV_UTILS.Convert_Uom (
					l_mtl_wt_uom,
					nvl(l_cont_weight_uom,l_mtl_wt_uom),
					l_mtl_max_load,
					x_inout_record.container_item_id));

	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
	   END IF;
	   --
	   l_max_volume := NVL(l_max_volume, WSH_WV_UTILS.Convert_Uom (
					l_mtl_vol_uom,
					nvl(l_cont_vol_uom,l_mtl_vol_uom),
					l_mtl_max_vol,
					x_inout_record.container_item_id));

   END IF;

   OPEN Get_Fill_Basis (nvl(p_in_record.organization_id,l_dd_org_id));

   FETCH Get_Fill_Basis INTO l_fill_pc_basis;

   IF Get_Fill_Basis%NOTFOUND THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_org_name := WSH_UTIL_CORE.Get_Org_Name(p_in_record.organization_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_FILL_BASIS_ERROR');
	FND_MESSAGE.SET_TOKEN('ORG_NAME',l_org_name);
	-- dbms_output.put_line('fill percent not defined');
 	CLOSE Get_Fill_Basis;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
   END IF;

   CLOSE Get_Fill_Basis;


   OPEN Get_Cont_Load (x_inout_record.container_item_id, l_dd_inv_item_id);

   FETCH Get_Cont_Load INTO
     l_max_load_qty,
     l_wcl_cont_item_id;


   IF Get_Cont_Load%FOUND AND l_fill_pc_basis = 'Q' THEN
     -- decided to return decimal number of containers and manage the actual
     -- number during the creation of the containers.

--dbms_output.put_line('fill percent is Q');
     IF l_max_load_qty <> 0 THEN

     	l_num_cont := (l_dd_packed_qty / l_max_load_qty);


        l_fill_pc_flag := 'Q1';

--dbms_output.put_line('l_num_cont in Qty set up'||l_num_cont);
     	CLOSE Get_Cont_Load;

     ELSE

	x_out_record.num_cont := 0;
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_LOAD_QTY_ERROR');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;

     END IF;

   ELSE

     CLOSE Get_Cont_Load;

     -- removed the CEIL from the expressions to check for exact numbers;

    -- dbms_output.put_line('net-weight before convert is ' || l_dd_net_wt);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    l_dd_net_wt := WSH_WV_UTILS.Convert_Uom (
				l_dd_wt_uom,
				nvl(l_cont_weight_uom,l_dd_wt_uom),
				l_dd_net_wt,
				l_dd_inv_item_id);


    -- dbms_output.put_line('net_weight after convert is ' || l_dd_net_wt);
    -- dbms_output.put_line('max load weight is ' || l_max_load_wt);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    l_dd_volume := WSH_WV_UTILS.Convert_Uom (
				l_dd_vol_uom,
				nvl(l_cont_vol_uom,l_dd_vol_uom),
				l_dd_volume,
				l_dd_inv_item_id);


     IF l_fill_pc_basis = 'W' THEN
--dbms_output.put_line('using weights' || l_dd_net_wt || ' and ' || l_max_load_wt);

	   IF l_max_load_wt > 0 THEN
	     	   l_num_cont := (l_dd_net_wt/l_max_load_wt);
                   l_fill_pc_flag := 'W';
	   ELSE
		   FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_LOAD_ERROR');
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   WSH_UTIL_CORE.Add_Message(x_return_status);
		   x_out_record.num_cont := 0;
		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
		       WSH_DEBUG_SV.pop(l_module_name);
		   END IF;
		   --
		   return;
	   END IF;

     ELSIF l_fill_pc_basis = 'V' THEN
--dbms_output.put_line('using volume' || l_dd_volume || ' and ' || l_max_volume);

	   IF l_max_volume > 0 THEN
	   	   l_num_cont := (l_dd_volume/l_max_volume);
                   l_fill_pc_flag := 'V';
	   ELSE
		   FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_VOL_ERROR');
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   WSH_UTIL_CORE.Add_Message(x_return_status);
		   x_out_record.num_cont := 0;
		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
		       WSH_DEBUG_SV.pop(l_module_name);
		   END IF;
		   --
		   return;
	   END IF;

     ELSIF l_fill_pc_basis = 'Q' THEN

	   IF l_max_load_wt > 0 AND l_max_volume > 0 THEN

	   	IF ((l_dd_net_wt/l_max_load_wt) >= (l_dd_volume/l_max_volume)) THEN
     	      		l_num_cont := (l_dd_net_wt/l_max_load_wt);
                        l_fill_pc_flag := 'W';
           	ELSE
	      		l_num_cont := (l_dd_volume/l_max_volume);
                        l_fill_pc_flag := 'V';
           	END IF;
--dbms_output.put_line('using qty with NO CONTAINER LOAD' || l_num_cont);
	   ELSE
		   FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_WT_ERROR');
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   WSH_UTIL_CORE.Add_Message(x_return_status);
		   x_out_record.num_cont := 0;
		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
		       WSH_DEBUG_SV.pop(l_module_name);
		   END IF;
		   --
		   return;
	   END IF;
     ELSE
	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	   END IF;
	   --
	   l_org_name := WSH_UTIL_CORE.Get_Org_Name(nvl(p_in_record.organization_id,l_dd_org_id));
	   FND_MESSAGE.SET_NAME('WSH','WSH_FILL_BASIS_ERROR');
	   FND_MESSAGE.SET_TOKEN('ORG_NAME',l_org_name);
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   	   WSH_UTIL_CORE.Add_Message(x_return_status);
	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
	   --
	   return;
     END IF;


   END IF;


   -- bug 2443162: avoid division by zero if the item's
   --   weight or volume value or max load quantity is zero.
   --   We also should catch the case when value is NULL.
   --    (This is the overloaded procedure with records as parameters.)
   IF NVL(l_num_cont, 0) = 0 THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_NULL_WEIGHT_VOLUME');
     FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL',p_in_record.delivery_detail_id);
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.Add_Message(x_return_status);
     x_out_record.num_cont := 0;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return;
   END IF;


-- This check is required for Bug 2393568

-- extra code added here to get the value of indivisible flag
-- since the check_decimal_quantity was not returning correct.

                OPEN get_flag_value(l_dd_inv_item_id,l_dd_org_id);
                FETCH get_flag_value
                 INTO l_item_indivisible;
                IF get_flag_value%NOTFOUND THEN
                  CLOSE get_flag_value;
                ELSE
                  CLOSE get_flag_value;
                END IF;

                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_DECIMAL_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_DETAILS_VALIDATIONS.Check_Decimal_Quantity (
                   l_dd_inv_item_id,
                   l_dd_org_id,
                   ROUND((l_dd_packed_qty/l_num_cont),LIMITED_PRECISION),
                   l_dd_req_qty_uom,
                   l_output_qty,
                   l_return_status);


--dbms_output.put_line('Return Status after CHECK DECIMAL'||l_return_status);
                -- errors likely mean integers are safe values.
                -- or if item indivisible flag is set to Y
                IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS OR
                    l_item_indivisible = 'Y'
                   )THEN
                  l_discard_message := FND_MESSAGE.GET;

                  l_tmp_num_cont := FLOOR(l_dd_packed_qty/l_num_cont);

                  IF (l_tmp_num_cont = 0) THEN
		    -- Bug#: 2503937 - New Error Message
                    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_WT_VOL_ERROR');
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    WSH_UTIL_CORE.Add_Message(x_return_status);
                    x_out_record.num_cont := 0;
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.pop(l_module_name);
                    END IF;
                    --
                    return;
                  END IF;

                  l_num_cont := (l_dd_packed_qty/l_tmp_num_cont);
                END IF;

-- End of check is required for Bug 2393568

   -- bug 1748609: maximize precision available to get accurate packing
   x_out_record.num_cont := l_num_cont;
--dbms_output.put_line('x_num_cont'||x_out_record.num_cont||'>'||l_num_cont||'>'||l_item_indivisible);

--USE A FLAG TO SET if the item is indivisible or not - l_item_indivisible
-- l_fill_pc_flag is set to W,Q1 or V, in case of Quantity with no preferred
-- container, it will be either W or V, so just use that

--Based on what ever the fill percent is
-- Calculate x_max_qty_per_lpn and x_fill_pc_per_lpn

-- for Quantity
-- maximum quantity from container load
-- if item is indivisible , FLOOR the max quantity per LPN
-- fill % = 100
-- else from weight and volume use the better precision

   IF l_fill_pc_flag = 'Q1' THEN

       l_max_qty_per_lpn := l_max_load_qty;
       l_fill_pc_per_lpn := 100; -- for Quantity it will be 100 %

--dbms_output.put_line('before floor Max QTY PER LPN is Q -'||l_max_qty_per_lpn);
-- for indivisible items need to floor
       IF l_item_indivisible = 'Y' THEN
         l_max_qty_per_lpn := FLOOR(l_max_qty_per_lpn);
       END IF;

--dbms_output.put_line('Max QTY PER LPN is Q -'||l_max_qty_per_lpn);
--dbms_output.put_line('Fill pc PER LPN is Q -'||l_fill_pc_per_lpn);

-- for weight
-- maximum quantity depending on item weight and max_load_weight
-- use max quantity to determin fil %
-- if item is indivisible, then fill % =
-- ((max_qty(total weight/requested_qty))/(max_load_weight))
--
   ELSIF l_fill_pc_flag = 'W' THEN
     l_max_qty_per_lpn := (l_max_load_wt/(l_dd_net_wt/l_dd_packed_qty));
     IF l_item_indivisible = 'Y' THEN
       l_max_qty_per_lpn := FLOOR(l_max_qty_per_lpn);
     END IF;
--dbms_output.put_line('Max QTY PER LPN is W -'||l_max_qty_per_lpn);
     l_fill_pc_per_lpn := ((l_max_qty_per_lpn*(l_dd_net_wt/l_dd_packed_qty))/(l_max_load_wt));
--dbms_output.put_line('Fill pc PER LPN is W -'||l_fill_pc_per_lpn);

-- for volume
-- maximum quantity depending on item volume and internal_volume
-- use max quantity to determin fil %
-- if item is indivisible, then fill % =
-- ((max_qty(total volume/requested_qty))/(internal volume))
--
   ELSIF l_fill_pc_flag = 'V' THEN
     l_max_qty_per_lpn := (l_max_volume/(l_dd_volume/l_dd_packed_qty));
     IF l_item_indivisible = 'Y' THEN
       l_max_qty_per_lpn := FLOOR(l_max_qty_per_lpn);
     END IF;
     l_fill_pc_per_lpn := ((l_max_qty_per_lpn*(l_dd_volume/l_dd_packed_qty))/(l_max_volume));
--dbms_output.put_line('Max QTY PER LPN is V -'||l_max_qty_per_lpn);
--dbms_output.put_line('Fill pc PER LPN is V -'||l_fill_pc_per_lpn);

   END IF;

   x_out_record.max_qty_per_lpn := l_max_qty_per_lpn;
   x_out_record.fill_pc_per_lpn := l_fill_pc_per_lpn;
   x_out_record.indivisible_flag := l_item_indivisible;
   x_out_record.fill_pc_flag := l_fill_pc_basis;

   IF x_out_record.num_cont <= 0 THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
   	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

      WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_UTILITIES.Estimate_Detail_Containers(2)');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Estimate_Detail_Containers;
-- end bug 2381184 adding new Estimate_Detail_Containers

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Estimate Detail Containers
   PARAMETERS : p_container_instance_id - instance id for the container
		x_container_item_id - container item for estimation
		p_delivery_detail_id - the delivery detail id for which the
			number of containers is being estimated
		p_organization_id - organization_id
		x_num_cont - number of containers required to pack the line.
		x_return_status - return status of API
  DESCRIPTION : This procedure estimates the number of detail containers that
		would be required to pack a delivery detail.  The container
		item could be specified or if it is not specified, it is
		derived from the delivery detail or through the container load
		relationship. Using the inventory item and quantity on the
		detail and the container item, the number of containers is
		calculated/estimated.
------------------------------------------------------------------------------
*/


PROCEDURE  Estimate_Detail_Containers(
   p_container_instance_id IN NUMBER DEFAULT NULL,
   x_container_item_id IN OUT NOCOPY  NUMBER,
   p_delivery_detail_id IN NUMBER,
   p_organization_id IN NUMBER,
   x_num_cont IN OUT NOCOPY  NUMBER,
   x_return_status OUT NOCOPY  VARCHAR2) IS

CURSOR Get_Cont_Load (v_cont_id NUMBER, v_inv_item_id NUMBER) IS
SELECT max_load_quantity, container_item_id
FROM WSH_CONTAINER_ITEMS
WHERE container_item_id = NVL(v_cont_id, container_item_id)
AND load_item_id = v_inv_item_id
AND master_organization_id = p_organization_id
AND preferred_flag = DECODE(nvl(v_cont_id,-99),-99,'Y',preferred_flag);

CURSOR Get_Delivery_Details (v_del_detail_id NUMBER) IS
SELECT delivery_detail_id, inventory_item_id, item_description,
       nvl(shipped_quantity,
           NVL(picked_quantity, requested_quantity)) packed_qty,
       requested_quantity_uom,
       master_container_item_id, detail_container_item_id, hold_code,
       load_seq_number, net_weight,
       weight_uom_code, volume, volume_uom_code, organization_id
FROM WSH_DELIVERY_DETAILS
WHERE delivery_detail_id = v_del_detail_id
AND container_flag = 'N';

CURSOR Get_Container_Info (v_cont_instance_id NUMBER, v_org_id NUMBER)IS
SELECT delivery_detail_id container_instance_id, container_name lpn,
       inventory_item_id container_item_id, item_description,
       gross_weight, net_weight, (gross_weight - net_weight), weight_uom_code,
       volume, volume_uom_code, fill_percent, maximum_load_weight,
       maximum_volume, minimum_fill_percent
FROM WSH_DELIVERY_DETAILS
WHERE delivery_detail_id = v_cont_instance_id
AND organization_id = v_org_id
AND  container_flag  in ('Y', 'C');

CURSOR Get_Cont_Msi (v_cont_item_id NUMBER, v_org_id NUMBER) IS
SELECT maximum_load_weight, internal_volume, weight_uom_code, volume_uom_code
FROM MTL_SYSTEM_ITEMS
WHERE inventory_item_id = v_cont_item_id
AND organization_id = v_org_id;

CURSOR Get_Fill_Basis (v_org_id NUMBER) IS
SELECT percent_fill_basis_flag
FROM WSH_SHIPPING_PARAMETERS
WHERE organization_id = v_org_id;

l_cont_gross		NUMBER;
l_cont_net		NUMBER;
l_cont_tare		NUMBER;
l_cont_weight_uom	VARCHAR2(3);
l_cont_volume		NUMBER;
l_cont_vol_uom		VARCHAR2(3);
l_lpn			VARCHAR2(30);
l_par_cont_id		NUMBER;
l_cont_item_id		NUMBER;
l_cont_description	VARCHAR2(240);
l_fill_pc		NUMBER;
l_max_load_wt		NUMBER;
l_min_fill_pc		NUMBER;
l_max_volume		NUMBER;
l_max_load_qty		NUMBER;
l_dd_master_cont_id	NUMBER;
l_dd_det_cont_id	NUMBER;
l_dd_inv_item_id	NUMBER;
l_dd_inv_item_desc	VARCHAR2(240);
l_dd_packed_qty		NUMBER;
l_dd_hold_flag		VARCHAR2(1);
l_dd_gross_wt		NUMBER;
l_dd_net_wt		NUMBER;
l_dd_tare_wt		NUMBER;
l_dd_volume		NUMBER;
l_dd_vol_uom		VARCHAR2(3);
l_dd_wt_uom		VARCHAR2(3);
l_dd_req_qty_uom	VARCHAR2(3);
l_output_qty            NUMBER;
l_return_status         VARCHAR2(30);

l_wcl_cont_item_id	NUMBER;
l_dd_org_id		NUMBER;
l_cont_org_id		NUMBER;
l_del_det_id		NUMBER;
l_cont_instance_id	NUMBER;
l_dd_load_seq_num	NUMBER;
l_num_cont		NUMBER;
l_mtl_wt_uom		VARCHAR2(3);
l_mtl_vol_uom		VARCHAR2(3);
l_mtl_max_load		NUMBER;
l_mtl_max_vol		NUMBER;
l_fill_pc_basis		VARCHAR2(1);

l_item_name		VARCHAR2(2000);
l_org_name		VARCHAR2(240);

l_tmp_num_cont          NUMBER;
l_discard_message       VARCHAR2(2000);
LIMITED_PRECISION       NUMBER := 8;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ESTIMATE_DETAIL_CONTAINERS';
--
BEGIN

   -- dbms_output.put_line('in estimating detail containers');

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
       WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
       WSH_DEBUG_SV.log(l_module_name,'X_CONTAINER_ITEM_ID',X_CONTAINER_ITEM_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'X_NUM_CONT',X_NUM_CONT);
   END IF;
   --
   OPEN Get_Delivery_Details (p_delivery_detail_id);

   FETCH Get_Delivery_Details INTO
   l_del_det_id,
   l_dd_inv_item_id,
   l_dd_inv_item_desc,
   l_dd_packed_qty,
   l_dd_req_qty_uom,
   l_dd_master_cont_id,
   l_dd_det_cont_id,
   l_dd_hold_flag,
   l_dd_load_seq_num,
   l_dd_net_wt,
   l_dd_wt_uom,
   l_dd_volume,
   l_dd_vol_uom,
   l_dd_org_id;


   IF (Get_Delivery_Details%NOTFOUND) THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 --dbms_output.put_line('no delivery details');
        FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
	FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_delivery_detail_id);
	CLOSE Get_Delivery_Details;
	WSH_UTIL_CORE.Add_Message(x_return_status);
 	--
 	-- Debug Statements
 	--
 	IF l_debug_on THEN
 	    WSH_DEBUG_SV.pop(l_module_name);
 	END IF;
 	--
 	return;
   END IF;

   CLOSE Get_Delivery_Details;

   x_container_item_id := NVL(NVL(l_dd_det_cont_id, l_dd_master_cont_id), x_container_item_id);

   --dbms_output.put_line('x cont item is ' || x_container_item_id || ' and inv item is ' || l_dd_inv_item_id || ' and org is ' || p_organization_id);

   OPEN Get_Cont_Load (x_container_item_id, l_dd_inv_item_id);

   FETCH Get_Cont_Load INTO
   l_max_load_qty,
   l_wcl_cont_item_id;

   IF (Get_Cont_Load%NOTFOUND AND x_container_item_id IS NULL) THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ITEM_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_item_name := WSH_UTIL_CORE.Get_Item_Name(l_dd_inv_item_id,l_dd_org_id);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_org_name := WSH_UTIL_CORE.Get_Org_Name(p_organization_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONT_LOAD');
	FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
	FND_MESSAGE.SET_TOKEN('ORG_NAME',l_org_name);
	CLOSE Get_Cont_Load;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
   END IF;

  CLOSE Get_Cont_Load;

   x_container_item_id := NVL(x_container_item_id, l_wcl_cont_item_id);


   IF (p_container_instance_id IS NOT NULL) THEN

      OPEN Get_Container_Info(p_container_instance_id, nvl(p_organization_id,l_dd_org_id));

      FETCH Get_Container_Info INTO
	l_cont_instance_id,
	l_lpn,
	l_cont_item_id,
	l_cont_description,
	l_cont_gross,
	l_cont_net,
	l_cont_tare,
	l_cont_weight_uom,
	l_cont_volume,
	l_cont_vol_uom,
	l_fill_pc,
	l_max_load_wt,
	l_max_volume,
	l_min_fill_pc;


      IF Get_Container_Info%NOTFOUND THEN
	   -- it means that no container load defined. may need to get it from
	   -- container instances table.
	   -- if container instance id also not defined then
	   -- raise container_item_error;
	    CLOSE Get_Container_Info;
	    -- dbms_output.put_line('container not found');
 	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
	    FND_MESSAGE.SET_TOKEN('CONT_NAME',l_lpn);
	    WSH_UTIL_CORE.Add_Message(x_return_status);
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    --
	    return;

      END IF;

      CLOSE Get_Container_Info;

      x_container_item_id := NVL(x_container_item_id,l_cont_item_id);

   END IF;


   IF (x_container_item_id IS NULL) THEN
	   -- it means that no container defined for this item type
	   -- raise container_item_error;
	   -- FND_MESSAGE.SET_NAME('WSH','WSH_CONT_EST_ERROR');
           -- dbms_output.put_line('no container item');
	   -- WSH_UTIL_CORE.Add_Message(x_return_status);
 	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  	   --
  	   -- Debug Statements
  	   --
  	   IF l_debug_on THEN
  	       WSH_DEBUG_SV.pop(l_module_name);
  	   END IF;
  	   --
  	   return;
   ELSE

           OPEN Get_Cont_Msi(x_container_item_id, nvl(p_organization_id,l_dd_org_id));

 	   FETCH Get_Cont_Msi INTO
	   l_mtl_max_load,
  	   l_mtl_max_vol,
	   l_mtl_wt_uom,
	   l_mtl_vol_uom;

	   IF Get_Cont_Msi%NOTFOUND THEN
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ITEM_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_item_name := WSH_UTIL_CORE.Get_Item_Name(x_container_item_id,nvl(p_organization_id,l_dd_org_id));
		FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_INV_ITEM');
		FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		CLOSE Get_Cont_Msi;
		WSH_UTIL_CORE.Add_Message(x_return_status);
	        --
	        -- Debug Statements
	        --
	        IF l_debug_on THEN
	            WSH_DEBUG_SV.pop(l_module_name);
	        END IF;
	        --
	        return;
	   END IF;

	   CLOSE Get_Cont_Msi;


	   -- dbms_output.put_line('max load wt before convert is ' || l_mtl_max_load || 'wt uom ' || l_mtl_wt_uom || ' cont wt uom ' || l_cont_weight_uom);

	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
	   END IF;
	   --
	   l_max_load_wt := NVL(l_max_load_wt, WSH_WV_UTILS.Convert_Uom (
					l_mtl_wt_uom,
					nvl(l_cont_weight_uom,l_mtl_wt_uom),
					l_mtl_max_load,
					x_container_item_id));

	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
	   END IF;
	   --
	   l_max_volume := NVL(l_max_volume, WSH_WV_UTILS.Convert_Uom (
					l_mtl_vol_uom,
					nvl(l_cont_vol_uom,l_mtl_vol_uom),
					l_mtl_max_vol,
					x_container_item_id));

   END IF;

   OPEN Get_Fill_Basis (nvl(p_organization_id,l_dd_org_id));

   FETCH Get_Fill_Basis INTO l_fill_pc_basis;

   IF Get_Fill_Basis%NOTFOUND THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_org_name := WSH_UTIL_CORE.Get_Org_Name(p_organization_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_FILL_BASIS_ERROR');
	FND_MESSAGE.SET_TOKEN('ORG_NAME',l_org_name);
	-- dbms_output.put_line('fill percent not defined');
 	CLOSE Get_Fill_Basis;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
   END IF;

   CLOSE Get_Fill_Basis;


   OPEN Get_Cont_Load (x_container_item_id, l_dd_inv_item_id);

   FETCH Get_Cont_Load INTO
     l_max_load_qty,
     l_wcl_cont_item_id;

   IF Get_Cont_Load%FOUND AND l_fill_pc_basis = 'Q' THEN
     -- decided to return decimal number of containers and manage the actual
     -- number during the creation of the containers.

     IF l_max_load_qty <> 0 THEN

     	l_num_cont := (l_dd_packed_qty / l_max_load_qty);
     	CLOSE Get_Cont_Load;

     ELSE

       CLOSE Get_Cont_Load;

	x_num_cont := 0;
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_LOAD_QTY_ERROR');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
     -- dbms_output.put_line('num cont in estimate is ' || l_num_cont);

     END IF;

   ELSE

     CLOSE Get_Cont_Load;

     -- removed the CEIL from the expressions to check for exact numbers;

    -- dbms_output.put_line('net-weight before convert is ' || l_dd_net_wt);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    l_dd_net_wt := WSH_WV_UTILS.Convert_Uom (
				l_dd_wt_uom,
				nvl(l_cont_weight_uom,l_dd_wt_uom),
				l_dd_net_wt,
				l_dd_inv_item_id);


    -- dbms_output.put_line('net_weight after convert is ' || l_dd_net_wt);
    -- dbms_output.put_line('max load weight is ' || l_max_load_wt);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    l_dd_volume := WSH_WV_UTILS.Convert_Uom (
				l_dd_vol_uom,
				nvl(l_cont_vol_uom,l_dd_vol_uom),
				l_dd_volume,
				l_dd_inv_item_id);


     IF l_fill_pc_basis = 'W' THEN
	   -- dbms_output.put_line('using weights' || l_dd_net_wt || ' and ' || l_max_load_wt);

	   IF l_max_load_wt > 0 THEN

	     	   l_num_cont := (l_dd_net_wt/l_max_load_wt);
	   ELSE
		   FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_LOAD_ERROR');
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   WSH_UTIL_CORE.Add_Message(x_return_status);
		   x_num_cont := 0;
		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
		       WSH_DEBUG_SV.pop(l_module_name);
		   END IF;
		   --
		   return;
	   END IF;

     ELSIF l_fill_pc_basis = 'V' THEN

	   IF l_max_volume > 0 THEN

	   	   l_num_cont := (l_dd_volume/l_max_volume);

	   ELSE
		   FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_VOL_ERROR');
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   WSH_UTIL_CORE.Add_Message(x_return_status);
		   x_num_cont := 0;
		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
		       WSH_DEBUG_SV.pop(l_module_name);
		   END IF;
		   --
		   return;
	   END IF;

     ELSIF l_fill_pc_basis = 'Q' THEN

	   IF l_max_load_wt > 0 AND l_max_volume > 0 THEN

	   	IF ((l_dd_net_wt/l_max_load_wt) >= (l_dd_volume/l_max_volume)) THEN
     	      		l_num_cont := (l_dd_net_wt/l_max_load_wt);
           	ELSE
	      		l_num_cont := (l_dd_volume/l_max_volume);
           	END IF;
	   ELSE
		   FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_WT_ERROR');
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   WSH_UTIL_CORE.Add_Message(x_return_status);
		   x_num_cont := 0;
		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
		       WSH_DEBUG_SV.pop(l_module_name);
		   END IF;
		   --
		   return;
	   END IF;
     ELSE
	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	   END IF;
	   --
	   l_org_name := WSH_UTIL_CORE.Get_Org_Name(nvl(p_organization_id,l_dd_org_id));
	   FND_MESSAGE.SET_NAME('WSH','WSH_FILL_BASIS_ERROR');
	   FND_MESSAGE.SET_TOKEN('ORG_NAME',l_org_name);
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   	   WSH_UTIL_CORE.Add_Message(x_return_status);
	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
	   --
	   return;
     END IF;


   -- bug 2443162: avoid division by zero if the item's
   --   weight or volume value or max load quantity is zero.
   --   We also should catch the case when value is NULL.
   --  (This is the original API with multiple IN parameters)
   IF NVL(l_num_cont, 0) = 0 THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_NULL_WEIGHT_VOLUME');
     FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL', p_delivery_detail_id);
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.Add_Message(x_return_status);
     x_num_cont := 0;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return;
   END IF;



-- THIS CHECK IS REQUIRED FOR WEIGHT AS WELL AS VOLUME PLUS THE CASE OF QTY with no container
-- load set up bug 2381184

                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_DECIMAL_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_DETAILS_VALIDATIONS.Check_Decimal_Quantity (
                                    l_dd_inv_item_id,
                                    l_dd_org_id,
                                    ROUND((l_dd_packed_qty/l_num_cont),LIMITED_PRECISION),
                                    l_dd_req_qty_uom,
                                    l_output_qty,
                                    l_return_status);


                -- errors likely mean integers are safe values.
                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                  l_discard_message := FND_MESSAGE.GET;

                  l_tmp_num_cont := FLOOR(l_dd_packed_qty/l_num_cont);

                  IF (l_tmp_num_cont = 0) THEN
		    -- Bug#: 2503937 - New Error Message
                    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_WT_VOL_ERROR');
                    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    WSH_UTIL_CORE.Add_Message(x_return_status);
                    x_num_cont := 0;
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.pop(l_module_name);
                    END IF;
                    --
                    return;
                  END IF;

                  l_num_cont := (l_dd_packed_qty/l_tmp_num_cont);
                END IF;


   END IF;

   -- bug 1748609: maximize precision available to get accurate packing
   x_num_cont := l_num_cont;

   IF x_num_cont <= 0 THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
   	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

      WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_UTILITIES.Estimate_Detail_Containers(1)');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Estimate_Detail_Containers;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Estimate Master Containers
   PARAMETERS : p_container_instance_id - instance id of the detail container
		x_mast_cont_item_id - master container item id
		p_det_cont_item_id - detail container item id
		p_organization_id - organization_id
		x_num_cont - number of master containers required to pack
			     the detail containers.
		x_return_status - return status of API
  DESCRIPTION : This procedure estimates the number of master containers that
		would be required to pack a number of detail containers.  The
		master container item could be specified or if it is not
		specified, it is derived from the container load relationship.
		Using the detail container item id and the derived master
		container item id the number of master containers is
		calculated/estimated.
------------------------------------------------------------------------------
*/


PROCEDURE  Estimate_Master_Containers(
   p_container_instance_id IN NUMBER,
   x_mast_cont_item_id IN OUT NOCOPY  NUMBER,
   p_det_cont_item_id IN NUMBER,
   p_organization_id IN NUMBER,
   x_num_cont IN OUT NOCOPY  NUMBER,
   x_return_status OUT NOCOPY  VARCHAR2) IS

CURSOR Get_Cont_Load (v_cont_id NUMBER, v_inv_item_id NUMBER) IS
SELECT max_load_quantity, container_item_id
FROM WSH_CONTAINER_ITEMS
WHERE container_item_id = NVL(v_cont_id, container_item_id)
AND load_item_id = v_inv_item_id
AND master_organization_id = p_organization_id
AND preferred_flag = DECODE(nvl(v_cont_id,-99),-99,'Y',preferred_flag);

-- For container, requested quantity is acceptable
-- what if container is ordered item????
-- then would there be shipped quantity????
-- based on that need to verify for unit weight and unit volume
-- as in estimate_detail_containers
CURSOR Get_Container_Info (v_cont_instance_id NUMBER, v_org_id NUMBER)IS
SELECT delivery_detail_id container_instance_id, container_name lpn,
       inventory_item_id container_item_id, item_description,
       requested_quantity,requested_quantity_uom,
       gross_weight, net_weight, (gross_weight - net_weight), weight_uom_code,
       volume, volume_uom_code, fill_percent,
       minimum_fill_percent, organization_id
FROM WSH_DELIVERY_DETAILS
WHERE delivery_detail_id = v_cont_instance_id
AND organization_id = nvl(v_org_id, organization_id)
AND  container_flag  in ('Y', 'C');

CURSOR Get_Cont_Msi (v_cont_item_id NUMBER, v_org_id NUMBER) IS
SELECT maximum_load_weight, internal_volume, weight_uom_code, volume_uom_code
FROM MTL_SYSTEM_ITEMS
WHERE inventory_item_id = v_cont_item_id
AND organization_id = v_org_id;

CURSOR Get_Fill_Basis (v_org_id NUMBER) IS
SELECT percent_fill_basis_flag
FROM WSH_SHIPPING_PARAMETERS
WHERE organization_id = v_org_id;

l_cont_gross		NUMBER;
l_cont_net		NUMBER;
l_cont_tare		NUMBER;
l_cont_weight_uom	VARCHAR2(3);
l_cont_volume		NUMBER;
l_cont_vol_uom		VARCHAR2(3);

l_cont_req_qty          NUMBER;
l_cont_req_qty_uom      VARCHAR2(3);

l_lpn			VARCHAR2(30);
l_par_cont_id		NUMBER;
l_cont_item_id		NUMBER;
l_cont_description	VARCHAR2(240);
l_fill_pc		NUMBER;
l_max_load_wt		NUMBER;
l_min_fill_pc		NUMBER;
l_max_volume		NUMBER;
l_max_load_qty		NUMBER;
l_wcl_cont_item_id	NUMBER;
l_cont_org_id		NUMBER;
l_cont_instance_id	NUMBER;
l_num_cont		NUMBER;
l_mtl_max_load		NUMBER;
l_mtl_max_vol		NUMBER;
l_mtl_wt_uom		VARCHAR2(3);
l_mtl_vol_uom		VARCHAR2(3);
l_fill_pc_flag		VARCHAR2(1) := 'N';
l_cont_fill_pc		NUMBER;

l_item_name		VARCHAR2(2000);
l_org_name		VARCHAR2(240);

l_cont_name		VARCHAR2(30);

l_fill_pc_basis VARCHAR2(1);

l_tmp_num_cont          NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ESTIMATE_MASTER_CONTAINERS';
--
BEGIN

   -- dbms_output.put_line('in estimating master containers - container instance id is ' || p_container_instance_id);

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
       WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
       WSH_DEBUG_SV.log(l_module_name,'X_MAST_CONT_ITEM_ID',X_MAST_CONT_ITEM_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DET_CONT_ITEM_ID',P_DET_CONT_ITEM_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'X_NUM_CONT',X_NUM_CONT);
   END IF;
   --
   IF (p_container_instance_id IS NOT NULL) THEN

      OPEN Get_Container_Info(p_container_instance_id, p_organization_id);

      -- Auto Pack Rewrite: Removed l_max_load_wt and l_max_volume from Get_Container_Info cursor
      --                    These 2 variables are causing incorrect container qty calculation
      FETCH Get_Container_Info INTO
	l_cont_instance_id,
	l_lpn,
	l_cont_item_id,
	l_cont_description,
        l_cont_req_qty,
        l_cont_req_qty_uom,
	l_cont_gross,
	l_cont_net,
	l_cont_tare,
	l_cont_weight_uom,
	l_cont_volume,
	l_cont_vol_uom,
	l_fill_pc,
	l_min_fill_pc,
	l_cont_org_id;


      IF Get_Container_Info%NOTFOUND THEN
	    CLOSE Get_Container_Info;
 	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
	    FND_MESSAGE.SET_TOKEN('CONT_NAME',l_lpn);
   	    WSH_UTIL_CORE.Add_Message(x_return_status);
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    --
	    return;

      END IF;

      CLOSE Get_Container_Info;

      l_cont_item_id := NVL(p_det_cont_item_id,l_cont_item_id);

   ELSE

      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.Add_Message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;

   END IF;

   OPEN Get_Cont_Load (x_mast_cont_item_id, l_cont_item_id);

   FETCH Get_Cont_Load INTO
   l_max_load_qty,
   l_wcl_cont_item_id;

   IF (Get_Cont_Load%NOTFOUND AND x_mast_cont_item_id IS NULL) THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ITEM_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_item_name := WSH_UTIL_CORE.Get_Item_Name(l_cont_item_id,p_organization_id);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_org_name := WSH_UTIL_CORE.Get_Org_Name(p_organization_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONT_LOAD');
	FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
	FND_MESSAGE.SET_TOKEN('ORG_NAME',l_org_name);
	-- dbms_output.put_line('error in get cont load');
	CLOSE Get_Cont_Load;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
   END IF;

  CLOSE Get_Cont_Load;

   x_mast_cont_item_id := NVL(x_mast_cont_item_id, l_wcl_cont_item_id);

   -- dbms_output.put_line('master cont item id is ' || x_mast_cont_item_id);

   IF (x_mast_cont_item_id IS NULL) THEN
	   -- it means that no container defined for this item type
	   -- raise container_item_error;
	   -- FND_MESSAGE.SET_NAME('WSH','WSH_CONT_EST_ERROR');
           -- dbms_output.put_line('no container item');
   	   -- WSH_UTIL_CORE.Add_Message(x_return_status);
 	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  	   --
  	   -- Debug Statements
  	   --
  	   IF l_debug_on THEN
  	       WSH_DEBUG_SV.pop(l_module_name);
  	   END IF;
  	   --
  	   return;
   ELSE

           OPEN Get_Cont_Msi(x_mast_cont_item_id, nvl(p_organization_id,l_cont_org_id));

 	   FETCH Get_Cont_Msi INTO
	   l_mtl_max_load,
  	   l_mtl_max_vol,
	   l_mtl_wt_uom,
	   l_mtl_vol_uom;

	   IF Get_Cont_Msi%NOTFOUND THEN
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ITEM_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_item_name := WSH_UTIL_CORE.Get_Item_Name(x_mast_cont_item_id,p_organization_id);
		FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_INV_ITEM');
		FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		CLOSE Get_Cont_Msi;
		WSH_UTIL_CORE.Add_Message(x_return_status);
	        --
	        -- Debug Statements
	        --
	        IF l_debug_on THEN
	            WSH_DEBUG_SV.pop(l_module_name);
	        END IF;
	        --
	        return;
	   END IF;

	   CLOSE Get_Cont_Msi;

           -- Convert weight/volume of Master Cont into detail container's UOM
	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
	   END IF;
	   --
	   l_max_load_wt := NVL(l_max_load_wt, WSH_WV_UTILS.Convert_Uom (
					l_mtl_wt_uom,
					nvl(l_cont_weight_uom,l_mtl_wt_uom),
					l_mtl_max_load,
					x_mast_cont_item_id));

	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
	   END IF;
	   --
	   l_max_volume := NVL(l_max_volume, WSH_WV_UTILS.Convert_Uom (
					l_mtl_vol_uom,
					nvl(l_cont_vol_uom,l_mtl_vol_uom),
					l_mtl_max_vol,
					x_mast_cont_item_id));

   END IF;


   OPEN Get_Fill_Basis (nvl(p_organization_id,l_cont_org_id));

   FETCH Get_Fill_Basis INTO l_fill_pc_basis;

   IF Get_Fill_Basis%NOTFOUND THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_org_name := WSH_UTIL_CORE.Get_Org_Name(nvl(p_organization_id,l_cont_org_id));
	FND_MESSAGE.SET_NAME('WSH','WSH_FILL_BASIS_ERROR');
	FND_MESSAGE.SET_TOKEN('ORG_NAME',l_org_name);
	-- dbms_output.put_line('fill percent not defined');
 	CLOSE Get_Fill_Basis;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
   END IF;

   CLOSE Get_Fill_Basis;


   OPEN Get_Cont_Load (x_mast_cont_item_id, l_cont_item_id);

   FETCH Get_Cont_Load INTO
     l_max_load_qty,
     l_wcl_cont_item_id;

   IF Get_Cont_Load%FOUND AND l_fill_pc_basis = 'Q' THEN
     -- decided to return decimal number of containers and manage the actual
     -- number during the creation of the containers.


     IF l_max_load_qty <> 0 THEN

     	l_num_cont := (1 / l_max_load_qty);
     	CLOSE Get_Cont_Load;

     ELSE

     	CLOSE Get_Cont_Load;

	x_num_cont := 0;
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_LOAD_QTY_ERROR');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
     -- dbms_output.put_line('num cont in estimate is ' || l_num_cont);

     END IF;

   ELSE

     CLOSE Get_Cont_Load;

     -- removed the CEIL from the expressions to check for exact numbers;

     IF l_fill_pc_basis = 'W' THEN

	   IF l_max_load_wt > 0 THEN
	     	   l_num_cont := (l_cont_gross/l_max_load_wt);
	   ELSE
		   FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_LOAD_ERROR');
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   WSH_UTIL_CORE.Add_Message(x_return_status);
		   x_num_cont := 0;
		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
		       WSH_DEBUG_SV.pop(l_module_name);
		   END IF;
		   --
		   return;
	   END IF;

     ELSIF l_fill_pc_basis = 'V' THEN

	   IF l_max_volume > 0 THEN
	   	   l_num_cont := (l_cont_volume/l_max_volume);
	   ELSE
		   FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_VOL_ERROR');
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   WSH_UTIL_CORE.Add_Message(x_return_status);
		   x_num_cont := 0;
		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
		       WSH_DEBUG_SV.pop(l_module_name);
		   END IF;
		   --
		   return;
	   END IF;

     ELSIF l_fill_pc_basis = 'Q' THEN

	   IF l_max_load_wt > 0 AND l_max_volume > 0 THEN

	   	IF ((l_cont_gross/l_max_load_wt) >= (l_cont_volume/l_max_volume)) THEN
     	      		l_num_cont := (l_cont_gross/l_max_load_wt);
           	ELSE
	      		l_num_cont := (l_cont_volume/l_max_volume);
           	END IF;
	   ELSE
		   -- Bug#: 2503937 - New Error Message
		   FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_WT_VOL_ERROR');
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   WSH_UTIL_CORE.Add_Message(x_return_status);
		   x_num_cont := 0;
		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
		       WSH_DEBUG_SV.pop(l_module_name);
		   END IF;
		   --
		   return;
	   END IF;

     ELSE
	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	   END IF;
	   --
	   l_org_name := WSH_UTIL_CORE.Get_Org_Name(nvl(p_organization_id, l_cont_org_id));
	   FND_MESSAGE.SET_NAME('WSH','WSH_FILL_BASIS_ERROR');
	   FND_MESSAGE.SET_TOKEN('ORG_NAME',l_org_name);
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   	   WSH_UTIL_CORE.Add_Message(x_return_status);
	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
	   --
	   return;
     END IF;


   END IF;

   -- bug 1748609: maximize precision available to get accurate packing
   x_num_cont := l_num_cont;

--   dbms_output.put_line('num of cont for container ' || p_container_instance_id  || ' is  ' || x_num_cont);

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

      WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_UTILITIES.Estimate_Master_Containers');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Estimate_Master_Containers;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Get Master Cont Serial
   PARAMETERS : p_container_instance_id - instance id for the container
		x_master_container_id - the master container of the container
			derived using the container hierarchy.
		x_master_container_name - container name for the master
			container.
		x_master_serial_number - serial number of the master container
			derived using the container hierarchy.
		x_return_status - return status of API
  DESCRIPTION : This procedure derives the master container instance id and
		master serial number of the container.  The master serial
		number and master container instance id is derived from the
		container instance table using the container heirarchy.
------------------------------------------------------------------------------
*/


PROCEDURE Get_Master_Cont_Serial (
   p_container_instance_id IN NUMBER,
   x_master_container_id IN OUT NOCOPY  NUMBER,
   x_master_container_name IN OUT NOCOPY  VARCHAR2,
   x_master_serial_number IN OUT NOCOPY  VARCHAR2,
   x_return_status OUT NOCOPY  VARCHAR2) IS

CURSOR Get_Master_Cont (v_cont_inst_id NUMBER) IS
SELECT delivery_detail_id
FROM wsh_delivery_assignments
WHERE parent_delivery_detail_id IS NULL
AND        NVL(type, 'S')       in ('S', 'C')
START WITH delivery_detail_id = v_cont_inst_id
AND        NVL(type, 'S')       in ('S', 'C')
CONNECT BY PRIOR parent_delivery_detail_id = delivery_detail_id;

CURSOR Get_Serial_Number (v_detail_id NUMBER) IS
SELECT master_serial_number, delivery_detail_id, container_flag
FROM WSH_DELIVERY_DETAILS
WHERE delivery_detail_id = v_detail_id;

l_det_id NUMBER;
l_cont_flag VARCHAR2(1);
l_cont_name VARCHAR2(30);


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_MASTER_CONT_SERIAL';
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
       WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
       WSH_DEBUG_SV.log(l_module_name,'X_MASTER_CONTAINER_ID',X_MASTER_CONTAINER_ID);
       WSH_DEBUG_SV.log(l_module_name,'X_MASTER_CONTAINER_NAME',X_MASTER_CONTAINER_NAME);
       WSH_DEBUG_SV.log(l_module_name,'X_MASTER_SERIAL_NUMBER',X_MASTER_SERIAL_NUMBER);
   END IF;
   --
   OPEN Get_Master_Cont (p_container_instance_id);
   FETCH Get_Master_Cont INTO x_master_container_id;

   IF (Get_Master_Cont%NOTFOUND) THEN
      CLOSE Get_Master_Cont;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
      FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
      WSH_UTIL_CORE.Add_Message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
   END IF;

   IF (Get_Master_Cont%ISOPEN) THEN
	CLOSE Get_Master_Cont;
   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   x_master_container_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(x_master_container_id);

   OPEN Get_Serial_Number (x_master_container_id);
   FETCH Get_Serial_Number INTO x_master_serial_number, l_det_id, l_cont_flag;

   IF (Get_Serial_Number%NOTFOUND OR l_cont_flag = 'N') THEN
      CLOSE Get_Serial_Number;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
      FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
      WSH_UTIL_CORE.Add_Message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
   END IF;

   IF (Get_Serial_Number%ISOPEN) THEN
	CLOSE Get_Serial_Number;
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_UTILITIES.Get_Master_Container');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Get_Master_Cont_Serial;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Update Child Containers
   PARAMETERS : p_container_instance_id - instance id for the container
		x_master_cont_instance_id - master container of the container
		x_master_serial_number - serial number of the master container
		x_return_status - return status of API
  DESCRIPTION : This procedure updates the master container instance id and
		master serial number of all the child containers. When the
		master serial number and master container instance id is
		changed on the master container, all the child containers are
		updated with the new values using this API.
------------------------------------------------------------------------------
*/


PROCEDURE Update_Child_Containers (
   p_container_instance_id IN NUMBER,
   p_master_cont_instance_id IN NUMBER,
   p_master_serial_number IN VARCHAR2,
   x_return_status OUT NOCOPY  VARCHAR2) IS

   CURSOR Get_Child_Containers(v_cont_instance_id NUMBER) IS
   SELECT delivery_detail_id
   FROM wsh_delivery_assignments_v
   START WITH parent_delivery_detail_id = v_cont_instance_id
   CONNECT BY PRIOR delivery_detail_id = parent_delivery_detail_id;

   CURSOR l_get_det_attribs_csr(p_detail_id IN NUMBER) IS
   SELECT container_flag, nvl(line_direction, 'O'), organization_id
   from   wsh_delivery_details
   where  delivery_detail_id = p_detail_id;

   l_cont_instance_id NUMBER;

   l_cont_name VARCHAR2(30);

   -- K LPN CONV. rv
   l_wms_org          VARCHAR2(10) := 'N';
   l_sync_tmp_rec     wsh_glbl_var_strct_grp.sync_tmp_rec_type;
   l_sync_tmp_recTbl  wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
   l_line_direction   VARCHAR2(10);
   l_organization_id  NUMBER;
   l_cnt_flag         VARCHAR2(10);
   l_child_counter    NUMBER;
   -- K LPN CONV. rv


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CHILD_CONTAINERS';
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
       WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_MASTER_CONT_INSTANCE_ID',P_MASTER_CONT_INSTANCE_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_MASTER_SERIAL_NUMBER',P_MASTER_SERIAL_NUMBER);
   END IF;
   --

   -- bug 5603825: need to stamp master_serial_number of
   --              p_container_instance_id when packing it into
   --              a LPN or unpacking it because this record is
   --              not included in the results of get_child_containers.
   IF    (p_container_instance_id <> p_master_cont_instance_id)
      OR (p_master_cont_instance_id IS NULL) THEN
   --{
     UPDATE WSH_DELIVERY_DETAILS
     SET    master_serial_number = p_master_serial_number
     WHERE  delivery_detail_id = p_container_instance_id
     RETURNING container_flag, NVL(line_direction, 'O'), organization_id
     INTO l_cnt_flag, l_line_direction, l_organization_id;

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'Master serial number is updated on this container.', p_container_instance_id);
     END IF;

     IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y' THEN
     --{
       l_wms_org := wsh_util_validate.check_wms_org(l_organization_id);

       IF l_line_direction IN ('O', 'IO')
          AND l_cnt_flag = 'Y'
          AND
          (
              (WSH_WMS_LPN_GRP.GK_WMS_UPD_MISC and l_wms_org = 'Y')
           OR (WSH_WMS_LPN_GRP.GK_INV_UPD_MISC and l_wms_org = 'N')
          )
       THEN
       --{
         l_sync_tmp_rec.delivery_detail_id := p_container_instance_id;
         l_sync_tmp_rec.operation_type     := 'UPDATE';

         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_WMS_SYNC_TMP_PKG.MERGE
         (
            p_sync_tmp_rec      => l_sync_tmp_rec,
            x_return_status     => x_return_status
         );


         IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name,'Return Status',x_return_status);
         END IF;

         IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Error occured in WSH_WMS_SYNC_TMP_PKG.MERGE');
             WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           return;
         END IF;
       --}
       END IF;
     --}
     END IF;
   --}
   END IF;

   --
   l_child_counter := 1;
   FOR det IN Get_Child_Containers(p_container_instance_id) LOOP
	IF (Get_Child_Containers%NOTFOUND) THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      	    --
      	    -- Debug Statements
      	    --
      	    IF l_debug_on THEN
      	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      	    END IF;
      	    --
      	    l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
	    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_NO_CHILD');
      	    FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
   	    WSH_UTIL_CORE.Add_Message(x_return_status);
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    --
	    return;
        END IF;
        --
        -- K LPN CONV. rv

        IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
        THEN
        --{
            open  l_get_det_attribs_csr(det.delivery_detail_id);
            fetch l_get_det_attribs_csr into l_cnt_flag, l_line_direction, l_organization_id;
            close l_get_det_attribs_csr;

            l_wms_org := wsh_util_validate.check_wms_org(l_organization_id);

            IF l_line_direction IN ('O', 'IO')
            AND l_cnt_flag = 'Y'
            AND
            (
              (WSH_WMS_LPN_GRP.GK_WMS_UPD_MISC and l_wms_org = 'Y')
              OR
              (WSH_WMS_LPN_GRP.GK_INV_UPD_MISC and l_wms_org = 'N')
            )
            THEN
            --{
                l_sync_tmp_rec.delivery_detail_id := det.delivery_detail_id;
                l_sync_tmp_rec.operation_type := 'UPDATE';
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

                WSH_WMS_SYNC_TMP_PKG.MERGE
                (
                  p_sync_tmp_rec      => l_sync_tmp_rec,
                  x_return_status     => x_return_status
                );

                --
                IF l_debug_on THEN
                  wsh_debug_sv.log(l_module_name,'Return Status',x_return_status);
                END IF;
                --
                IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
                  IF l_debug_on THEN
      	              WSH_DEBUG_SV.logmsg(l_module_name,'Error occured in WSH_WMS_SYNC_TMP_PKG.MERGE');
                      WSH_DEBUG_SV.pop(l_module_name);
                  END IF;
                  return;
                END IF;
            --}
            END IF;
        --}
        END IF;
        -- K LPN CONV. rv
        --
	UPDATE WSH_DELIVERY_DETAILS
	  SET master_serial_number = p_master_serial_number
	  WHERE delivery_detail_id = det.delivery_detail_id;

	IF (SQL%ROWCOUNT > 1 OR SQL%NOTFOUND) THEN
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      	   --
      	   -- Debug Statements
      	   --
      	   IF l_debug_on THEN
      	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      	   END IF;
      	   --
      	   l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(det.delivery_detail_id);
	   FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
      	   FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
   	   WSH_UTIL_CORE.Add_Message(x_return_status);
	END IF;
   END LOOP;

   IF (Get_Child_Containers%ISOPEN) THEN
	CLOSE Get_Child_Containers;
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_UTILITIES.Update_Child_Containers');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Update_Child_Containers;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Validate Master Serial Number
   PARAMETERS : p_container_instance_id - instance id for the container
		p_master_serial_number - serial number of the master container
		x_return_status - return status of API
  DESCRIPTION : This is a dummy procedure created to help customers create
		a customizable validation API for the master serial number. It
		currently returns success for all cases.
------------------------------------------------------------------------------
*/


PROCEDURE Validate_Master_Serial_Number (
   p_master_serial_number IN VARCHAR2,
   p_container_instance_id IN NUMBER,
   x_return_status OUT NOCOPY  VARCHAR2) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_MASTER_SERIAL_NUMBER';
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
      WSH_DEBUG_SV.log(l_module_name,'P_MASTER_SERIAL_NUMBER',P_MASTER_SERIAL_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_UTILITIES.Validate_Master_serial_Number');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Validate_Master_Serial_Number;



/*
-----------------------------------------------------------------------------
   PROCEDURE  : Get Master Serial Number
   PARAMETERS : p_container_instance_id - instance id for the container
		x_master_serial_number - serial number of the master container
		x_return_status - return status of API
  DESCRIPTION : This procedure retrieves the master serial number for a
		container by getting the serial number of the master container
		in the container heirarchy.
------------------------------------------------------------------------------
*/

PROCEDURE Get_Master_Serial_Number (
   p_container_instance_id IN NUMBER,
   x_master_serial_number IN OUT NOCOPY  VARCHAR2,
   x_return_status OUT NOCOPY  VARCHAR2) IS


  CURSOR Get_Master_Serial (v_cont_instance_id NUMBER) IS
  SELECT master_serial_number
  FROM WSH_DELIVERY_DETAILS
  WHERE delivery_detail_id = v_cont_instance_id;

  l_cont_name VARCHAR2(30);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_MASTER_SERIAL_NUMBER';
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
      WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
      WSH_DEBUG_SV.log(l_module_name,'X_MASTER_SERIAL_NUMBER',X_MASTER_SERIAL_NUMBER);
  END IF;
  --
  OPEN Get_Master_Serial (p_container_instance_id);

  FETCH Get_Master_Serial INTO x_master_serial_number;

  IF Get_Master_Serial%NOTFOUND THEN
	CLOSE Get_Master_Serial;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      	--
      	-- Debug Statements
      	--
      	IF l_debug_on THEN
      	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      	END IF;
      	--
      	l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
        FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
      	FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
        WSH_UTIL_CORE.Add_Message(x_return_status);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;
  END IF;

  IF Get_Master_Serial%ISOPEN THEN
	CLOSE Get_Master_Serial;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_UTILITIES.Get_Master_Serial_Number');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Get_Master_Serial_Number;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Is Empty
   PARAMETERS : p_container_instance_id - instance id for the container
	 	x_empty_flag - flag to return empty or non-empty
		x_return_status - return status of API
  DESCRIPTION : This procedure checks the container to see if there are any
		lines packed in the container. If there are no lines it returns
		a true flag to indicate that it is empty.
------------------------------------------------------------------------------
*/


PROCEDURE Is_Empty (
   p_container_instance_id IN NUMBER,
   x_empty_flag IN OUT NOCOPY  BOOLEAN,
   x_return_status OUT NOCOPY  VARCHAR2) IS

CURSOR Fetch_Details (v_cont_instance_id NUMBER) IS
SELECT wda.delivery_detail_id, wda.delivery_id
FROM wsh_delivery_assignments_v wda,
     WSH_DELIVERY_DETAILS wdd
WHERE wda.parent_delivery_detail_id = v_cont_instance_id
AND wdd.delivery_detail_id = wda.delivery_detail_id
AND wdd.container_flag = 'N'
AND rownum < 2
AND wda.parent_delivery_detail_id IS NOT NULL;

l_delivery_detail_id NUMBER;
l_delivery_id NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'IS_EMPTY';
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
       WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
       WSH_DEBUG_SV.log(l_module_name,'X_EMPTY_FLAG',X_EMPTY_FLAG);
   END IF;
   --
   OPEN Fetch_Details (p_container_instance_id);

   FETCH Fetch_Details INTO l_delivery_detail_id, l_delivery_id;

   IF Fetch_Details%FOUND THEN
	IF (l_delivery_detail_id IS NOT NULL) THEN
	   x_empty_flag := FALSE;
	ELSE
	   x_empty_flag := TRUE;
 	END IF;
   ELSE
	x_empty_flag := TRUE;
   END IF;

   IF Fetch_Details%ISOPEN THEN
	CLOSE Fetch_Details;
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

      WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_UTILITIES.Is_Empty');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Is_Empty;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Is Empty
   PARAMETERS : p_container_instance_id - instance id for the container
                x_empty_flag - flag to return empty or non-empty
                x_return_status - return status of API
  DESCRIPTION : This procedure checks the container to see if there are any
                lines packed in the container. If there are no lines it returns
                a 'Y' flag to indicate that it is empty.
                If C1 contains C2 and C3. C2 has C4 which is empty , but C3 has a ddid
                Based on this API, C1 is not empty, but C2 ind C4 are empty.
                Caller must ensure the ID being passed is a container to resolve bug 5100229 by removing the redundant query.
------------------------------------------------------------------------------
*/

PROCEDURE Is_Empty (
   p_container_instance_id IN NUMBER,
   x_empty_flag OUT NOCOPY  VARCHAR2,
   x_return_status OUT NOCOPY  VARCHAR2) IS


-- bug 4891897, sql 15036897
-- removed the outer query (select 1 from dual where exists ())
-- since it causes 2 full table scan on wsh_delivery_assignments


CURSOR c_details_exist (v_delivery_detail_id NUMBER) IS
  SELECT 1
    FROM wsh_delivery_details
   WHERE delivery_detail_id in (
         SELECT delivery_detail_id
           FROM wsh_delivery_assignments_v
          START WITH delivery_detail_id = v_delivery_detail_id
          CONNECT BY prior delivery_detail_id = parent_delivery_detail_id)
     AND container_flag = 'N';
l_delivery_detail_id NUMBER;
above_sql_status  boolean := FALSE;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'IS_EMPTY2';
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
       WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
       WSH_DEBUG_SV.log(l_module_name,'X_EMPTY_FLAG',X_EMPTY_FLAG);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


   x_empty_flag := 'Y';

   OPEN c_details_exist (p_container_instance_id);
   FETCH c_details_exist INTO l_delivery_detail_id;
   above_sql_status :=  c_details_exist%FOUND;
   CLOSE c_details_exist;

   IF above_sql_status THEN  -- Content exists
      x_empty_flag := 'N';
   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --

EXCEPTION

      WHEN Others THEN

        IF c_details_exist%ISOPEN THEN
           close c_details_exist;
        END IF;

        WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_UTILITIES.Is_Empty2');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--

END Is_Empty;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Get Fill Percent
   PARAMETERS : p_container_instance_id - instance id for the container
		x_percent_fill - percent fill of the container
		x_return_status - return status of API
  DESCRIPTION : This procedure retrieves the percent fill of the container
		from the container instances table. If the percent fill is
		null, it recalculates the percent fill for the container.
------------------------------------------------------------------------------
*/


PROCEDURE Get_Fill_Percent (
   p_container_instance_id IN NUMBER,
   x_percent_fill OUT NOCOPY  NUMBER,
   x_return_status OUT NOCOPY  VARCHAR2) IS

   CURSOR Get_Fill_Percent (v_cont_instance_id NUMBER) IS
   SELECT fill_percent
   FROM WSH_DELIVERY_DETAILS
   WHERE delivery_detail_id = v_cont_instance_id
   AND  container_flag  in ('Y', 'C');

   l_fill_percent NUMBER;

   l_cont_name VARCHAR2(30);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_FILL_PERCENT';
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
       WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
   END IF;
   --
   OPEN Get_Fill_Percent (p_container_instance_id);

   FETCH Get_Fill_Percent INTO l_fill_percent;

   IF Get_Fill_Percent%NOTFOUND THEN
	CLOSE Get_Fill_Percent;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      	--
      	-- Debug Statements
      	--
      	IF l_debug_on THEN
      	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      	END IF;
      	--
      	l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
      	FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
	WSH_UTIL_CORE.Add_Message(x_return_status);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;
   END IF;

   IF Get_Fill_Percent%ISOPEN THEN
	CLOSE Get_Fill_Percent;
   END IF;

   x_percent_fill := l_fill_percent;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

      WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_UTILITIES.Get_Fill_Percent');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
   --
END Get_Fill_Percent;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Get Delivery Status
   PARAMETERS : p_container_instance_id - instance id for the container
		x_delivery_id - delivery id the container is assigned to
		x_del_status - status of delivery that the container is
			assigned to.
		x_return_status - return status of API
  DESCRIPTION : This procedure retrieves the delivery id and delivery status
		of the delivery that the container is assigned to.
------------------------------------------------------------------------------
*/


PROCEDURE Get_Delivery_Status (
   p_container_instance_id IN NUMBER,
   x_delivery_id IN OUT NOCOPY  NUMBER,
   x_del_status IN OUT NOCOPY  VARCHAR2,
   x_return_status OUT NOCOPY  VARCHAR2) IS

CURSOR Get_Delivery_Status (v_cont_instance_id NUMBER) IS
SELECT wda.delivery_id, wnd.status_code
FROM wsh_delivery_assignments_v wda, WSH_NEW_DELIVERIES wnd, WSH_DELIVERY_DETAILS wdd
WHERE wda.delivery_detail_id = v_cont_instance_id
AND wda.delivery_id = wnd.delivery_id
AND wdd.delivery_detail_id = wda.delivery_detail_id
AND wdd.container_flag in ('Y', 'C');

l_delivery_id NUMBER;
l_del_status VARCHAR2(2);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DELIVERY_STATUS';
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
       WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
       WSH_DEBUG_SV.log(l_module_name,'X_DELIVERY_ID',X_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'X_DEL_STATUS',X_DEL_STATUS);
   END IF;
   --
   OPEN Get_Delivery_Status (p_container_instance_id);

   FETCH Get_Delivery_Status INTO l_delivery_id, l_del_status;
   IF (Get_Delivery_Status%FOUND) THEN
	x_del_status := l_del_status;
	x_delivery_id := l_delivery_id;
	CLOSE Get_Delivery_Status;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
   ELSE
    	x_del_status := 'NA';
   	x_delivery_id := -99;
	CLOSE Get_Delivery_Status;
   	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
   END IF;

   IF Get_Delivery_Status%ISOPEN THEN
   	CLOSE Get_Delivery_Status;
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

      WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_UTILITIES.Get_Delivery_Status');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Get_Delivery_Status;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Validate_Container
   PARAMETERS : p_container_name - container name that needs to be validated.
		p_container_instance_id - the delivery detail id for the
		container that needs to be updated.
		x_return_status - return status of API
  DESCRIPTION : This procedure takes in the container name and existing
		container id (detail id) and checks to see if the container
		that is being updated is assigned to a closed, confirmed or
		in-transit delivery. If it is, no update is allowed - if not,
		only the container name can be updated if the name is not a
		duplicate of an existing container.
------------------------------------------------------------------------------
*/


PROCEDURE Validate_Container (
  p_container_name IN VARCHAR2,
  p_container_instance_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2) IS

CURSOR Check_Dup_Cont IS
SELECT delivery_detail_id
FROM WSH_DELIVERY_DETAILS
WHERE container_name = p_container_name
  AND container_flag in ('Y', 'C');

l_cont_instance_id NUMBER;
l_del_id	NUMBER;
l_del_sts	VARCHAR2(10);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_CONTAINER';
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
     WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_NAME',P_CONTAINER_NAME);
     WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
 END IF;
 --
 IF p_container_name IS NULL THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_INVALID_NAME');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
 END IF;

 IF p_container_instance_id IS NULL THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
 END IF;

 OPEN Check_Dup_Cont;

 FETCH Check_Dup_Cont INTO
	l_cont_instance_id;

 IF (Check_Dup_Cont%FOUND AND l_cont_instance_id <> p_container_instance_id) THEN
	CLOSE Check_Dup_Cont;
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_NAME_DUPLICATE');
	FND_MESSAGE.SET_TOKEN('CONT_NAME',p_container_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
 END IF;

 IF Check_Dup_Cont%ISOPEN THEN
	CLOSE Check_Dup_Cont;
 END IF;

 --
 -- Debug Statements
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_DELIVERY_STATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
 END IF;
 --
 WSH_CONTAINER_UTILITIES.Get_Delivery_Status (
				p_container_instance_id,
				l_del_id,
				l_del_sts,
				x_return_status);

 IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
 END IF;

 IF (nvl(l_del_id,-99) <> -99) THEN

	IF (nvl(l_del_sts,'N/A') <> 'OP') THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DEL_STS_INVALID');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status);
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
	END IF;
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

      WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_UTILITIES.Validate_Container');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Validate_Container;

END WSH_CONTAINER_UTILITIES;

/
