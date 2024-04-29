--------------------------------------------------------
--  DDL for Package Body WSH_CONTAINER_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CONTAINER_ACTIONS" as
/* $Header: WSHCMACB.pls 120.22.12010000.6 2010/02/25 15:48:10 sankarun ship $ */

  LIMITED_PRECISION NUMBER := 5;
  c_wms_code_present varchar2(2) := 'Y';
-- HW OPMCONV - Removed OPM variable

  G_CALLED_FROM_INBOUND BOOLEAN := FALSE;

  TYPE empty_container_info IS RECORD (
        container_index   NUMBER,
        container_item_id WSH_DELIVERY_DETAILS.inventory_item_id%TYPE,
        mast_cont_item_id WSH_DELIVERY_DETAILS.master_container_item_id%TYPE,
        organization_id   WSH_DELIVERY_DETAILS.organization_id%TYPE,
        group_id          NUMBER,
        numerator         NUMBER,
        denominator       NUMBER,
        empty             NUMBER);
  TYPE empty_container_info_tab IS TABLE OF empty_container_info INDEX BY BINARY_INTEGER;
  g_empty_cont_tab empty_container_info_tab;
  g_new_cont_index NUMBER := 0;
  g_num_cont_index NUMBER := 0;

  TYPE assign_detail_info IS RECORD (
        container_index    NUMBER,
        gross_weight       WSH_DELIVERY_DETAILS.net_weight%TYPE,
        net_weight         WSH_DELIVERY_DETAILS.net_weight%TYPE,
        volume             WSH_DELIVERY_DETAILS.volume%TYPE,
        delivery_id        wsh_delivery_assignments_v.delivery_id%TYPE,
        delivery_detail_id WSH_DELIVERY_DETAILS.delivery_detail_id%TYPE,
        -- J: W/V Changes
        inventory_item_id  WSH_DELIVERY_DETAILS.inventory_item_id%TYPE,
        weight_uom         WSH_DELIVERY_DETAILS.weight_uom_code%TYPE,
        volume_uom         WSH_DELIVERY_DETAILS.volume_uom_code%TYPE,
        -- K LPN CONV
        organization_id    WSH_DELIVERY_DETAILS.organization_id%TYPE);
  TYPE assign_detail_info_tab IS TABLE OF assign_detail_info INDEX BY BINARY_INTEGER;
  g_assign_detail_tab assign_detail_info_tab;
  g_assign_detail_index NUMBER := 0;

-- added number_of_containers to the record structure
  TYPE new_container_info IS RECORD (
        organization_id   WSH_DELIVERY_DETAILS.organization_id%TYPE,
        container_item_id WSH_DELIVERY_DETAILS.inventory_item_id%TYPE,
        mast_cont_item_id WSH_DELIVERY_DETAILS.master_container_item_id%TYPE,
        cont_instance_id  WSH_DELIVERY_DETAILS.delivery_detail_id%TYPE,
        number_of_containers NUMBER
       );
  TYPE new_container_info_tab IS TABLE OF new_container_info INDEX BY BINARY_INTEGER;
  g_new_container_tab new_container_info_tab;

 -- another temp table to store id
 -- Store container instance id after Bulk Insert
  TYPE new_contid_rec IS RECORD (
       match_id  NUMBER,
       cont_instance_id WSH_DELIVERY_DETAILS.delivery_detail_id%TYPE,
       -- J: W/V Changes
       unit_weight NUMBER,
       unit_volume NUMBER,
       weight_uom  VARCHAR2(3),
       volume_uom  VARCHAR2(3),
       item_id     NUMBER,
       -- K LPN CONV
       organization_id NUMBER
      );
  TYPE new_contid_info_tab IS TABLE OF new_contid_rec INDEX BY BINARY_INTEGER;
  g_new_contid_tab new_contid_info_tab;

  -- Cache Tables
  TYPE organization_info IS RECORD (
        process_flag      VARCHAR2(1),
        fill_pc_basis     WSH_SHIPPING_PARAMETERS.percent_fill_basis_flag%TYPE);
  TYPE organization_info_tab IS TABLE OF organization_info INDEX BY BINARY_INTEGER;
  g_cache_organization_info_tab organization_info_tab;

  /* Organization specific Cache Table */
  TYPE container_load_info IS RECORD (
        cont_item_id      WSH_CONTAINER_ITEMS.container_item_id%TYPE,
        max_load_qty      WSH_CONTAINER_ITEMS.max_load_quantity%TYPE);
  TYPE container_load_info_tab IS TABLE OF container_load_info INDEX BY BINARY_INTEGER;
  g_cache_cont_load_info_tab container_load_info_tab;

  /* Organization specific Cache Table */

-- valid_flag indicates if this container can be used for packing or not
-- inactive containers cannot be used
  TYPE cont_msi_info IS RECORD (
        mtl_max_load     MTL_SYSTEM_ITEMS.maximum_load_weight%TYPE,
        mtl_max_vol      MTL_SYSTEM_ITEMS.internal_volume%TYPE,
        mtl_wt_uom       MTL_SYSTEM_ITEMS.weight_uom_code%TYPE,
        mtl_vol_uom      MTL_SYSTEM_ITEMS.volume_uom_code%TYPE,
        valid_flag       VARCHAR2(1)
       );
  TYPE cont_msi_tab IS TABLE OF cont_msi_info INDEX BY BINARY_INTEGER;
  g_cont_msi_tab cont_msi_tab;

  C_ERROR_STATUS       CONSTANT VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_ERROR;
  C_WARNING_STATUS     CONSTANT VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_WARNING;
  C_SUCCESS_STATUS     CONSTANT VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  C_UNEXP_ERROR_STATUS CONSTANT VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_CONTAINER_ACTIONS';
--

--Bug #3005780 : Added the local function Get_Gcd
/*
-----------------------------------------------------------------------------
   FUNCTION   : Get_Gcd
   PARAMETERS : num1 - First Number
                num2 - Second Number
  DESCRIPTION : This function finds greatest common devisor for the given
                Two numbers num1 and num2. If one number is zero then it
                returns other number as  GCD value
------------------------------------------------------------------------------
*/

FUNCTION Get_Gcd (num1 IN NUMBER,
  num2 IN NUMBER) RETURN NUMBER IS
  temp_int  NUMBER;
  num1_int  NUMBER := num1;
  num2_int  NUMBER := num2;
BEGIN
    IF num1_int = 0 THEN return num2_int; END IF;
    WHILE num2_int <> 0 LOOP
      temp_int := mod(num1_int,num2_int);
      num1_int := num2_int;
      num2_int := temp_int;
    END LOOP;
    return num1_int;
END Get_Gcd;

-- bug 3440811
/*
-----------------------------------------------------------------------------
   PROCEDURE  : Validate_Container
   PARAMETERS : p_organization_id  - Organization Id
                p_cont_item_id          - Container Item Id

  DESCRIPTION : This procedure takes the organization_id and the container's item_id
                to check if the container is a valid container for packing or not.
------------------------------------------------------------------------------
*/

PROCEDURE Validate_Container(
  p_organization_id   IN  NUMBER,
  p_cont_item_id      IN  NUMBER,
  x_return_status     OUT NOCOPY  VARCHAR2)
IS
  CURSOR l_valid_cont_csr (p_cont_item_id NUMBER, p_org_id NUMBER) IS
  SELECT 'X'
  FROM MTL_SYSTEM_ITEMS
  WHERE inventory_item_id = p_cont_item_id
  AND container_item_flag = 'Y'
  AND organization_id = p_org_id
  AND    nvl(vehicle_item_flag,'N') = 'N'
  AND    shippable_item_flag = 'Y';

  l_valid_container VARCHAR2(1);
  l_item_name  VARCHAR2(32767);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_CONTAINER';
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
        WSH_DEBUG_SV.log(l_module_name, 'p_cont_item_id', p_cont_item_id);
        WSH_DEBUG_SV.log(l_module_name, 'p_organization_id', p_organization_id);
    END IF;

    x_return_status := wsh_util_core.g_ret_sts_success;
    IF p_cont_item_id IS NOT NULL THEN
    --{
      OPEN  l_valid_cont_csr (p_cont_item_id, p_organization_id);
      FETCH l_valid_cont_csr INTO l_valid_container;
      IF l_valid_cont_csr%NOTFOUND THEN
      --{
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ITEM_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        l_item_name := WSH_UTIL_CORE.Get_Item_Name(p_cont_item_id,p_organization_id);
        FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_INV_ITEM');
        FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
        CLOSE l_valid_cont_csr;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

       WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --}
      ELSE
      --{
        CLOSE l_valid_cont_csr;
      --}
      END IF;
    --}
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
EXCEPTION
  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Validate_Container',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Validate_Container;
-- bug 3440811

/* lpn conv
-----------------------------------------------------------------------------
   PROCEDURE  : default_container_attr
------------------------------------------------------------------------------
*/

PROCEDURE default_container_attr (
     P_container_rec  IN  OUT NOCOPY
                           wsh_glbl_var_strct_grp.Delivery_Details_Rec_Type,
     p_additional_cont_attr IN wsh_glbl_var_strct_grp.LPNRecordType,
     p_caller               IN VARCHAR2,
     x_return_status OUT NOCOPY  VARCHAR2

  ) IS

  l_wms_org    VARCHAR2(5) := 'N';

  CURSOR Get_Cont_Item_Info (v_cont_item_id NUMBER,
                             v_org_id NUMBER,
                             v_wms_org VARCHAR2 ) IS
  SELECT Description, Container_Type_Code, weight_uom_code, volume_uom_code,
  minimum_fill_percent, maximum_load_weight, internal_volume, primary_uom_code,
-- J: W/V Changes
  unit_weight, unit_volume
  FROM MTL_SYSTEM_ITEMS
  WHERE inventory_item_id = v_cont_item_id
  AND container_item_flag = 'Y'
  AND organization_id = v_org_id
  AND    nvl(vehicle_item_flag,'N') = 'N'
  AND    ((shippable_item_flag = 'Y' AND v_wms_org = 'N')
          OR v_wms_org = 'Y') ;

-- bug 2828591 - remove the condition since it will prevent user to create container with other status
--  AND inventory_item_status_code='Active';

  l_cont_name VARCHAR2(50);
  i NUMBER;
  l_description VARCHAR2(240);
  l_container_type_code VARCHAR2(30);
  l_wt_uom VARCHAR2(3);
  l_vol_uom VARCHAR2(3);
  l_wt_uom_org VARCHAR2(3); --bug 7615765
  l_vol_uom_org VARCHAR2(3);--bug 7615765
  l_min_fill_pc NUMBER;
  l_max_load_wt NUMBER;
  l_max_vol NUMBER;
  l_user_id NUMBER;
  l_last_update_by NUMBER;
  l_primary_uom VARCHAR2(3);
-- J: W/V Changes
  l_unit_weight NUMBER;
  l_unit_volume NUMBER;
  l_row_id	VARCHAR2(30);
  l_org_name VARCHAR2(240);
  l_item_name VARCHAR2(2000);
  l_additional_cont_attr wsh_glbl_var_strct_grp.LPNRecordType;

  i NUMBER;
  j NUMBER;
  l_return_status  VARCHAR2(2);
  l_num_warnings   NUMBER := 0;
  l_num_errors     NUMBER := 0;

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DEFAULT_CONTAINER_ATTR';
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
        WSH_DEBUG_SV.log(l_module_name,'organization_id',P_container_rec.organization_id);
        WSH_DEBUG_SV.log(l_module_name,'item_id',P_container_rec.inventory_item_id);
    END IF;
    --

    -- If one of the wt/vol fields are negative, or if any wt/vol is give
    -- without their uom, or if any wt/vol's uom is given without value then
    -- error out.

    l_additional_cont_attr := p_additional_cont_attr;

    IF P_container_rec.volume < 0 OR P_container_rec.filled_volume < 0
     OR P_container_rec.net_weight < 0 OR P_container_rec.gross_weight < 0
     OR l_additional_cont_attr.tare_weight < 0
    THEN --{

       IF l_debug_on THEN --{

          WSH_DEBUG_SV.log(l_module_name,'1 gross_weight',P_container_rec.gross_weight);
          WSH_DEBUG_SV.log(l_module_name,'net_weight',P_container_rec.net_weight);
          WSH_DEBUG_SV.log(l_module_name,'tare_weight',l_additional_cont_attr.tare_weight);
          WSH_DEBUG_SV.log(l_module_name,'volume',P_container_rec.volume);
          WSH_DEBUG_SV.log(l_module_name,'filled_volume',P_container_rec.filled_volume);
       END IF; --}

       RAISE FND_API.G_EXC_ERROR;

    ELSIF (nvl(P_container_rec.volume,0) > 0
           AND P_container_rec.volume_uom_code IS NULL)
       --OR (P_container_rec.volume IS NULL
           --AND P_container_rec.volume_uom_code IS NOT NULL )
       OR (NVL(P_container_rec.filled_volume,0)> 0
           AND l_additional_cont_attr.filled_volume_uom_code IS NULL )
       --OR (P_container_rec.filled_volume IS NULL
           --AND l_additional_cont_attr.filled_volume_uom_code IS NOT NULL )
       OR (nvl(P_container_rec.gross_weight,0) > 0
           AND P_container_rec.weight_uom_code IS NULL )
       --OR (P_container_rec.gross_weight IS NULL
           --AND P_container_rec.weight_uom_code IS NOT NULL )
       OR (nvl(P_container_rec.net_weight,0) > 0
           AND P_container_rec.weight_uom_code IS NULL )
       --OR (P_container_rec.net_weight IS NULL
           --AND P_container_rec.weight_uom_code IS NOT NULL )
       OR (nvl(l_additional_cont_attr.tare_weight,0) > 0
           AND l_additional_cont_attr.tare_weight_uom_code IS NULL )
       --OR (l_additional_cont_attr.tare_weight IS NULL
           --AND l_additional_cont_attr.tare_weight_uom_code IS NOT NULL )
    THEN --}{
       IF l_debug_on THEN --{

          WSH_DEBUG_SV.log(l_module_name,'2 gross_weight',P_container_rec.gross_weight);
          WSH_DEBUG_SV.log(l_module_name,'net_weight',P_container_rec.net_weight);
          WSH_DEBUG_SV.log(l_module_name,'weight_uom_code',P_container_rec.weight_uom_code);
          WSH_DEBUG_SV.log(l_module_name,'tare_weight',l_additional_cont_attr.tare_weight);
          WSH_DEBUG_SV.log(l_module_name,'tare_weight_uom_code',l_additional_cont_attr.tare_weight_uom_code);
          WSH_DEBUG_SV.log(l_module_name,'volume',P_container_rec.volume);
          WSH_DEBUG_SV.log(l_module_name,'filled_volume',P_container_rec.filled_volume);
          WSH_DEBUG_SV.log(l_module_name,'volume_uom_code',P_container_rec.volume_uom_code);
          WSH_DEBUG_SV.log(l_module_name,'filled_volume_uom',l_additional_cont_attr.filled_volume_uom_code);
       END IF; --}

       RAISE FND_API.G_EXC_ERROR;

    END IF; --}

    l_wms_org := wsh_util_validate.check_wms_org(P_container_rec.organization_id);
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_wms_org',l_wms_org);
    END IF;

    OPEN Get_Cont_Item_Info (P_container_rec.inventory_item_id,
                             P_container_rec.organization_id,
                             l_wms_org);

     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'GETTING CONTAINER ITEM INFO'  );
     END IF;
     --
	FETCH Get_Cont_Item_Info INTO
	  l_description,
	  l_container_type_code,
	  l_wt_uom,
	  l_vol_uom,
	  l_min_fill_pc,
	  l_max_load_wt,
	  l_max_vol,
	  l_primary_uom,
          l_unit_weight,
          l_unit_volume;

	IF Get_Cont_Item_Info%NOTFOUND THEN --{
	  --
          IF NVL(p_caller,'WSH') NOT IN ( 'WSH_PICK_RELEASE', 'WSH_IB_PACK')
            AND NVL(p_caller,'WSH') NOT LIKE 'WMS%'
          THEN

	     IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ITEM_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	     END IF;
	     --
	     l_item_name := WSH_UTIL_CORE.Get_Item_Name(P_container_rec.inventory_item_id,P_container_rec.organization_id);
	     FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_INV_ITEM');
	     FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
	     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   	     WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
          END IF;

	  CLOSE Get_Cont_Item_Info;
  	  --  Bug#: 3362895
	  IF P_container_rec.inventory_item_id IS NOT NULL THEN
            IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    --
	    return;
	  END IF;

	  -- return;  Containers need not have an inventory item
	  -- 		 associated with them. Cross-Docking requirements
	ELSE --}{
	    CLOSE Get_Cont_Item_Info;
	END IF; --}

        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name, 'l_vol_uom',l_vol_uom  );
           WSH_DEBUG_SV.log(l_module_name, 'l_wt_uom',l_wt_uom  );
        END IF;
        IF l_vol_uom IS NULL OR l_wt_uom IS NULL THEN --{
           IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.GET_DEFAULT_UOMS',WSH_DEBUG_SV.C_PROC_LEVEL);
	   END IF;
	   --
	   WSH_WV_UTILS.Get_Default_Uoms (
			   P_container_rec.organization_id,
                           -- bug 761576
                           --l_wt_uom,
                           --l_vol_uom,
                           l_wt_uom_org,
                           l_vol_uom_org,
			   l_return_status);

	   IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN --{
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR GETTING DEFFAULT UOMS'  );
 	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
 	      END IF;
 	      --
 	      l_org_name := WSH_UTIL_CORE.Get_Org_Name(P_container_rec.organization_id);
	      FND_MESSAGE.SET_NAME('WSH','WSH_DEFAULT_UOM_ERROR');
	      FND_MESSAGE.SET_TOKEN('ORG_NAME',l_org_name);
	      WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
	      --
	      IF l_debug_on THEN
	         WSH_DEBUG_SV.log(l_module_name,'Org Name is ',l_org_name);
	       END IF;
	       --
               wsh_util_core.api_post_call
                 (
                   p_return_status => l_return_status,
                   x_num_warnings  => l_num_warnings,
                   x_num_errors    => l_num_errors
               );
	   END IF; --}
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'NO ERRORS AFTER GETTING DEFAULT UOMS'  );
               WSH_DEBUG_SV.logmsg(l_module_name, 'CLOSED GET_CONT_ITEM_INFO'  );
           END IF;
           --

           --Changes for bug 	7615765 Give preference to Container Item attributes
           IF l_wt_uom IS NULL THEN
           --{
                l_wt_uom := l_wt_uom_ORG;
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'l_wt_uom updated to org dafault value' );
                   WSH_DEBUG_SV.log(l_module_name, 'l_wt_uom',l_wt_uom );
                END IF;
           --}
           END IF;

           IF l_vol_uom IS NULL THEN
           --{
                l_vol_uom := l_vol_uom_ORG;
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'l_vol_uom updated to org dafault value' );
                   WSH_DEBUG_SV.log(l_module_name, 'l_vol_uom',l_vol_uom);
                END IF;
           --}
           END IF;

        END IF; --}

        --converting the uoms
        p_container_rec.volume_uom_code := NVL(p_container_rec.volume_uom_code,l_vol_uom);
        l_additional_cont_attr.filled_volume_uom_code := NVL(l_additional_cont_attr.filled_volume_uom_code, l_vol_uom);

        IF p_container_rec.volume_uom_code <> l_vol_uom THEN
           p_container_rec.volume :=
                  WSH_WV_UTILS.Convert_Uom_core (
                                   from_uom => p_container_rec.volume_uom_code,
                                   to_uom => l_vol_uom,
                                   quantity => p_container_rec.volume,
                                   item_id => P_container_rec.inventory_item_id,
                                   x_return_status => l_return_status
                               );
           wsh_util_core.api_post_call
             (
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors
             );
        END IF;
        p_container_rec.volume := NVL(p_container_rec.volume,l_unit_volume);
        p_container_rec.volume_uom_code := l_vol_uom;

        IF l_additional_cont_attr.filled_volume_uom_code <> l_vol_uom THEN
           p_container_rec.filled_volume :=
               WSH_WV_UTILS.Convert_Uom_core (
                       from_uom =>l_additional_cont_attr.filled_volume_uom_code,
                       to_uom =>l_vol_uom,
                       quantity =>p_container_rec.filled_volume,
                       item_id =>P_container_rec.inventory_item_id,
                       x_return_status => l_return_status );
           wsh_util_core.api_post_call
             (
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors
             );
        END IF;
        p_container_rec.unit_volume := l_unit_volume;
        --p_container_rec.filled_volume := NVL(p_container_rec.filled_volume,l_unit_volume);

        p_container_rec.weight_uom_code := NVL(p_container_rec.weight_uom_code,l_wt_uom);
        IF p_container_rec.weight_uom_code <> l_wt_uom THEN
           p_container_rec.gross_weight :=
               WSH_WV_UTILS.Convert_Uom_core (
                                  from_uom => p_container_rec.weight_uom_code,
                                  to_uom => l_wt_uom,
                                  quantity => p_container_rec.gross_weight,
                                  item_id => P_container_rec.inventory_item_id,
                                  x_return_status => l_return_status
                               );
           wsh_util_core.api_post_call
             (
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors
             );
           IF  p_container_rec.net_weight is not NULL THEN
               p_container_rec.net_weight :=
                     WSH_WV_UTILS.Convert_Uom_core (
                                  from_uom => p_container_rec.weight_uom_code,
                                  to_uom => l_wt_uom,
                                  quantity => p_container_rec.net_weight,
                                  item_id =>P_container_rec.inventory_item_id,
                                  x_return_status => l_return_status);
               wsh_util_core.api_post_call
                 (
                   p_return_status => l_return_status,
                   x_num_warnings  => l_num_warnings,
                   x_num_errors    => l_num_errors
                 );
            END IF;
        END IF;
        p_container_rec.weight_uom_code := l_wt_uom;

        IF l_additional_cont_attr.tare_weight_uom_code <> l_wt_uom THEN
              l_additional_cont_attr.tare_weight :=
                  WSH_WV_UTILS.Convert_Uom_core (
                          from_uom=>l_additional_cont_attr.tare_weight_uom_code,
                          to_uom => l_wt_uom,
                          quantity => l_additional_cont_attr.tare_weight,
                          item_id => P_container_rec.inventory_item_id,
                          x_return_status => l_return_status
                  );
               wsh_util_core.api_post_call
                 (
                   p_return_status => l_return_status,
                   x_num_warnings  => l_num_warnings,
                   x_num_errors    => l_num_errors
                 );
        END IF;

        p_container_rec.gross_weight := NVL(p_container_rec.gross_weight,l_unit_weight);
        IF p_container_rec.net_weight IS NULL AND l_additional_cont_attr.tare_weight IS NOT NULL THEN
           p_container_rec.net_weight := p_container_rec.gross_weight
                                   - l_additional_cont_attr.tare_weight;
        END IF;

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'gross weight', p_container_rec.gross_weight  );
            WSH_DEBUG_SV.log(l_module_name, 'volume', p_container_rec.volume );
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.ORG_TO_LOCATION',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        p_container_rec.ship_from_location_id := WSH_UTIL_CORE.Org_To_Location(p_container_rec.organization_id,TRUE);
        p_container_rec.container_type_code := NVL(p_container_rec.container_type_code,l_container_type_code);
        p_container_rec.item_description := l_description;
        p_container_rec.requested_quantity := 1;
        p_container_rec.shipped_quantity := null;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'ASSIGNING RQ_UOM'  );
        END IF;
        --
        p_container_rec.requested_quantity_uom := l_primary_uom;
        p_container_rec.wv_frozen_flag := 'N';
        p_container_rec.unit_weight := l_unit_weight;
        p_container_rec.maximum_volume := l_max_vol;
        p_container_rec.maximum_load_weight := l_max_load_wt;
                  --NVL(p_container_rec.maximum_load_weight, l_max_load_wt);
        p_container_rec.minimum_fill_percent := l_min_fill_pc;
                   --NVL(p_container_rec.minimum_fill_percent,l_min_fill_pc);
        p_container_rec.source_code := 'WSH';
        p_container_rec.container_flag := 'Y';

        -- Fix for Bug 1820376 : Containers should have release status as 'X'
        p_container_rec.released_status := 'X';


        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle
error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');      END IF;

    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.default_container_attr',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END default_container_attr;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Create_Cont_Instance_Multi
-- This API has been created to Create Multiple Containers
-- while Auto Packing, p_num_of_containers specifies how
-- many containers need to be created
------------------------------------------------------------------------------
*/

PROCEDURE Create_Cont_Instance_Multi (
  x_cont_name IN OUT NOCOPY  VARCHAR2,
  p_cont_item_id IN NUMBER,
  x_cont_instance_id IN OUT NOCOPY  NUMBER,
  p_par_detail_id IN NUMBER,
  p_organization_id IN NUMBER,
  p_container_type_code IN VARCHAR2,
  p_num_of_containers IN NUMBER,
  x_row_id OUT NOCOPY  VARCHAR2,
  --x_row_id will containe the rowid of the first container created.
  x_return_status OUT NOCOPY  VARCHAR2,
  x_cont_tab OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
  -- J: W/V Changes
  x_unit_weight OUT NOCOPY NUMBER,
  x_unit_volume OUT NOCOPY NUMBER,
  x_weight_uom_code OUT NOCOPY VARCHAR2,
  x_volume_uom_code OUT NOCOPY VARCHAR2,
  p_lpn_id          IN NUMBER DEFAULT NULL,
  p_ignore_for_planning IN VARCHAR2 DEFAULT 'N',
  p_caller            IN VARCHAR2 DEFAULT 'WSH'
  ) IS

  CURSOR Get_Cont_Item_Info (v_cont_item_id NUMBER, v_org_id NUMBER) IS
  SELECT Description, Container_Type_Code, weight_uom_code, volume_uom_code,
  minimum_fill_percent, maximum_load_weight, internal_volume, primary_uom_code,
-- J: W/V Changes
  unit_weight, unit_volume
  FROM MTL_SYSTEM_ITEMS
  WHERE inventory_item_id = v_cont_item_id
  AND container_item_flag = 'Y'
  AND organization_id = v_org_id
  AND    nvl(vehicle_item_flag,'N') = 'N'
  AND    shippable_item_flag = 'Y';
-- bug 2828591 - remove the condition since it will prevent user to create container with other status
--  AND inventory_item_status_code='Active';

  CURSOR Get_Cont_Name (v_cont_inst_id NUMBER) IS
  SELECT container_name
  FROM WSH_DELIVERY_DETAILS
  WHERE delivery_detail_id = v_cont_inst_id
  AND container_flag = 'Y';

--added cursors
  CURSOR Get_Wdd_Nextval IS
  SELECT wsh_delivery_details_s.nextval
    FROM sys.dual;

  CURSOR Get_Wda_Nextval IS
  SELECT wsh_delivery_assignments_s.nextval
    FROM sys.dual;

  l_cont_instance_id NUMBER;
  l_cont_name VARCHAR2(50);
  l_description VARCHAR2(240);
  l_container_type_code VARCHAR2(30);
  l_min_fill_pc NUMBER;
  l_max_load_wt NUMBER;
  l_max_vol NUMBER;
  l_user_id NUMBER;
  l_last_update_by NUMBER;
  l_primary_uom VARCHAR2(3);
-- J: W/V Changes

  l_container_rec       WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
  l_del_assg_rec	WSH_DELIVERY_DETAILS_PKG.Delivery_Assignments_Rec_Type;

  l_row_id	VARCHAR2(30);
  l_del_assg_id	NUMBER;

  l_cont_name VARCHAR2(30);
  l_org_name VARCHAR2(240);

  l_item_name VARCHAR2(2000);
  l_cont_rec wsh_container_actions.cont_inst_rec;
  l_cont_tab wsh_container_actions.cont_inst_tab;
  i NUMBER;
  j NUMBER;
  cnt NUMBER;
  l_cont_dummy_tab  WSH_UTIL_CORE.id_tab_type;
  l_assignment_dummy_tab  WSH_UTIL_CORE.id_tab_type;
  l_delivery_detail_id NUMBER;
--lpn conv
  l_orig_value   VARCHAR2(2);
  l_orig_update_cont_value   VARCHAR2(2);
  l_net_weight   number;

  l_LPN_PREFIX   mtl_parameters.LPN_PREFIX%TYPE;
  l_LPN_SUFFIX   mtl_parameters.LPN_SUFFIX%TYPE;
  l_LPN_STARTING_NUMBER  mtl_parameters.LPN_STARTING_NUMBER%TYPE;
  l_TOTAL_LPN_LENGTH     mtl_parameters.TOTAL_LPN_LENGTH%TYPE;
  --l_cont_names WSH_GLBL_VAR_STRCT_GRP.v50_Tbl_Type;
  --l_lpn_ids              WSH_UTIL_CORE.id_tab_type;
  l_cont_name_dig          number;
  l_tare_wt   NUMBER;
  l_tare_wt_uom VARCHAR2(10);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_container_info_rec        WSH_GLBL_VAR_STRCT_GRP.ContInfoRectype;
  l_gen_lpn_rec           WMS_Data_Type_Definitions_pub.AutoCreateLPNRecordType;
  l_lpn_tbl               WMS_Data_Type_Definitions_pub.LPNTableType;
  l_num_warnings  NUMBER := 0;
  l_num_errors    NUMBER := 0;
  l_return_status VARCHAR2(10);
  l_additional_cont_attr    wsh_glbl_var_strct_grp.LPNRecordType;
  l_organization_id         NUMBER;
  l_inventory_item_id       NUMBER;
  l_first                   number;
  CURSOR c_get_default_parameters (v_organization_id NUMBER) IS
  SELECT LPN_PREFIX,
         LPN_SUFFIX,
         LPN_STARTING_NUMBER ,
         TOTAL_LPN_LENGTH
  FROM mtl_parameters
  WHERE ORGANIZATION_ID = v_organization_id;

  CURSOR c_get_lpn_info(v_lpn_id NUMBER) IS
  SELECT gross_weight ,
         GROSS_WEIGHT_UOM_CODE,
         TARE_WEIGHT_UOM_CODE,
         TARE_WEIGHT,
         --container_volume,
         --CONTAINER_VOLUME_UOM,
         content_volume,  --filled volume
         CONTENT_VOLUME_UOM_CODE ,
         locator_id,
         subinventory_code,
         license_plate_number ,
         organization_id,
         inventory_item_id
   FROM wms_license_plate_numbers
   WHERE lpn_id = v_lpn_id;

   CURSOR c_get_lpn_from_history (v_lpn_id number)IS
   SELECT wlh.LICENSE_PLATE_NUMBER,
          wlh.organization_id,
          wlh.inventory_item_id
  FROM wms_lpn_histories wlh
  WHERE wlh.lpn_id = v_lpn_id
  --AND wlh.OPERATION_MODE = 1
  AND wlh.lpn_context = 7
  AND wlh.SOURCE_TYPE_ID = 1;

  CURSOR c_get_rowid (v_delivery_detail number) IS
  SELECT rowid , container_name
  from wsh_delivery_details
  WHERE delivery_detail_id = v_delivery_detail;





--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_CONT_INSTANCE_MULTI';
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
        WSH_DEBUG_SV.log(l_module_name,'X_CONT_NAME',X_CONT_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_CONT_ITEM_ID',P_CONT_ITEM_ID);
        WSH_DEBUG_SV.log(l_module_name,'X_CONT_INSTANCE_ID',X_CONT_INSTANCE_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_PAR_DETAIL_ID',P_PAR_DETAIL_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_TYPE_CODE',P_CONTAINER_TYPE_CODE);
    END IF;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'IN CREATE_CONT_INSTANCE_MULTI '  );
    END IF;
    --

    l_orig_value := WSH_WMS_LPN_GRP.g_call_group_api;
    l_orig_update_cont_value := WSH_WMS_LPN_GRP.g_update_to_container;
    l_inventory_item_id := p_cont_item_id;

    IF p_organization_id IS NULL AND p_lpn_id IS NULL THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_ORG_NULL');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
    END IF;

--lpn conv
    IF p_lpn_id IS NULL THEN --{

       WSH_WMS_LPN_GRP.g_call_group_api := 'N';
       WSH_WMS_LPN_GRP.g_update_to_container := 'N';

       IF c_wms_code_present = 'Y' THEN --{

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,
                          'calling wms_container_grp.Auto_Create_LPNs'  );
       END IF;

       l_gen_lpn_rec.container_item_id := l_inventory_item_id;
       l_gen_lpn_rec.organization_id :=  p_organization_id;
       --l_gen_lpn_rec.lpn_prefix:=  l_LPN_PREFIX;
       --l_gen_lpn_rec.lpn_suffix := l_LPN_SUFFIX;
       --l_gen_lpn_rec.starting_num :=  l_LPN_STARTING_NUMBER;
       --l_gen_lpn_rec.total_length :=  l_TOTAL_LPN_LENGTH;
       l_gen_lpn_rec.quantity:= p_num_of_containers;

       wms_container_grp.Auto_Create_LPNs (
               p_api_version         => 1.0
             , p_init_msg_list      => fnd_api.g_false
             , p_commit             => fnd_api.g_false
             , x_return_status      => l_return_status
             , x_msg_count          => l_msg_count
             , x_msg_data           => l_msg_data
             , p_caller             => 'WSH_GENERATE'
             , p_gen_lpn_rec        => l_gen_lpn_rec
             , p_lpn_table          => l_lpn_tbl
       );
       wsh_util_core.api_post_call
         (
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors,
           p_msg_data      => l_msg_data
       );
       WSH_WMS_LPN_GRP.g_call_group_api := l_orig_value;
       WSH_WMS_LPN_GRP.g_update_to_container := l_orig_update_cont_value;

       j := 1;
       i := l_lpn_tbl.first;
       WHILE i IS NOT NULL LOOP
          IF l_debug_on THEN
	     WSH_DEBUG_SV.log(l_module_name,'container_name',
                                   l_lpn_tbl(i).license_plate_number);
	     WSH_DEBUG_SV.log(l_module_name,'lpn_id',
                                   l_lpn_tbl(i).lpn_id);
          END IF;
          l_container_info_rec.container_names(j)
                                   := l_lpn_tbl(i).license_plate_number;
          l_container_info_rec.lpn_ids(j) := l_lpn_tbl(i).lpn_id;

          IF (l_container_info_rec.container_names(j) IS NULL)  OR (l_container_info_rec.lpn_ids(j) IS NULL )THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          i := l_lpn_tbl.NEXT(i);
          j := J + 1;
       END LOOP;

       l_container_rec.weight_uom_code :=
                                     l_lpn_tbl(1).GROSS_WEIGHT_UOM_CODE;
       l_container_rec.gross_weight :=
                                       l_lpn_tbl(1).GROSS_WEIGHT;
       l_additional_cont_attr.tare_weight :=
                                       l_lpn_tbl(1).TARE_WEIGHT;
       l_additional_cont_attr.tare_weight_uom_code :=
                                       l_lpn_tbl(1).TARE_WEIGHT_UOM_CODE;
       l_container_rec.volume_uom_code :=
                       l_lpn_tbl(1).CONTAINER_VOLUME_UOM;
       l_container_rec.volume := l_lpn_tbl(1).CONTAINER_VOLUME;
       l_additional_cont_attr.filled_volume_uom_code :=
                       l_lpn_tbl(1).CONTENT_VOLUME_UOM_CODE;
       l_container_rec.filled_volume := l_lpn_tbl(1).CONTENT_VOLUME;
       l_container_rec.locator_id := l_lpn_tbl(1).locator_id;
       l_container_rec.subinventory := l_lpn_tbl(1).SUBINVENTORY_CODE;

       ELSE --}{
       /* commment out this part once the wms code is ready*/
       OPEN c_get_default_parameters(p_organization_id);
       FETCH c_get_default_parameters INTO
          l_LPN_PREFIX,
          l_LPN_SUFFIX,
          l_LPN_STARTING_NUMBER ,
          l_TOTAL_LPN_LENGTH;
       CLOSE c_get_default_parameters;
       IF l_TOTAL_LPN_LENGTH IS NOT NULL THEN
          l_cont_name_dig := length(l_TOTAL_LPN_LENGTH) -
             nvl(length(l_LPN_SUFFIX),0) -
             NVL(length(l_LPN_PREFIX),0);
          IF l_cont_name_dig < 0 THEN
             l_cont_name_dig := NULL;
          END IF;
       END IF;
       Create_Multiple_Cont_name (
          p_cont_name     => NULL,
          p_cont_name_pre => l_LPN_PREFIX,
          p_cont_name_suf => l_LPN_SUFFIX,
          p_cont_name_num => l_LPN_STARTING_NUMBER,
          p_cont_name_dig => l_cont_name_dig,
          p_quantity      => p_num_of_containers,
          x_cont_names    => l_container_info_rec.container_names,
          x_return_status => l_return_status
       );
       wsh_util_core.api_post_call
         (
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors
       );
       i := l_container_info_rec.container_names.FIRST;
       WHILE i IS NOT NULL LOOP
         IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'container_name', l_container_info_rec.container_names(i));
         END IF;
         l_container_info_rec.lpn_ids(i) := NULL;
         i := l_container_info_rec.container_names.NEXT(i);
       END LOOP;
       END IF ; --} bmso
    ELSE --}{
       IF p_caller LIKE 'WSH_IB%' THEN --{
          l_container_rec.container_name := x_cont_name;
          l_organization_id := p_organization_id;
          l_inventory_item_id := NULL;
          l_container_info_rec.container_names(1) := l_container_rec.container_name;
          l_container_info_rec.lpn_ids(1) := p_lpn_id;
       ELSE --}{
          OPEN  c_get_lpn_info(p_lpn_id);
          FETCH c_get_lpn_info INTO
             l_container_rec.gross_weight,
             l_container_rec.weight_uom_code,
             l_additional_cont_attr.tare_weight_uom_code,
             l_additional_cont_attr.tare_weight,
             --l_container_rec.volume,
             --l_container_rec.volume_uom_code,
             l_container_rec.filled_volume,
             l_additional_cont_attr.filled_volume_uom_code,
             l_container_rec.locator_id,
             l_container_rec.subinventory,
             l_container_rec.container_name,
             l_organization_id,
             l_inventory_item_id;

             IF  c_get_lpn_info%NOTFOUND THEN
	        IF l_debug_on THEN
	           WSH_DEBUG_SV.log(l_module_name,'Error invalid Lpn_id ',
                                                                     p_lpn_id);
                END IF;
                RAISE FND_API.G_EXC_ERROR;
             END IF;

/*
                --compute the net weight
             IF (l_inventory_item_id IS NOT NULL)
               AND (l_tare_wt IS NOT NULL)
               AND (l_tare_wt_uom IS NOT NULL)
               AND (l_container_rec.weight_uom_code IS NOT NULL)
               AND (l_container_rec.gross_weight IS NOT NULL)
            THEN
                l_net_weight := l_container_rec.gross_weight
                           -       WSH_WV_UTILS.Convert_Uom (l_tare_wt_uom,
                                           l_container_rec.weight_uom_code,
                                           l_tare_wt,
                                           l_inventory_item_id);
             END IF;
             IF l_debug_on THEN
	         WSH_DEBUG_SV.log(l_module_name,'l_net_weight ',l_net_weight);
             END IF;
             l_container_rec.net_weight:= l_net_weight;
*/
             l_container_info_rec.container_names(1) := l_container_rec.container_name;
             l_container_info_rec.lpn_ids(1) := p_lpn_id;

          CLOSE c_get_lpn_info;
       END IF; --}

       IF p_organization_id IS NULL AND  l_organization_id IS NULL THEN
           FND_MESSAGE.SET_NAME('WSH','WSH_CONT_ORG_NULL');
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           return;
       END IF;

    END IF; --}

    l_container_rec.organization_id := NVL(p_organization_id,l_organization_id);
    l_container_rec.inventory_item_id := l_inventory_item_id;
    l_container_rec.container_type_code := p_container_type_code;
    l_container_rec.ignore_for_planning := p_ignore_for_planning;

    default_container_attr(l_container_rec,
                           l_additional_cont_attr ,
                           p_caller,
                           l_return_status);

    wsh_util_core.api_post_call
         (
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors
    );
   --lpn conv



    -- Populate Delivery Detail id and Delivery Assignment id
    -- within the Loop

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'CREATING DELIVERY DETAIL'||p_num_of_containers  );
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.CREATE_DELIVERY_DETAILS_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --


    WSH_DELIVERY_DETAILS_PKG.create_delivery_details_bulk
       ( p_delivery_details_info => l_container_rec,
         p_num_of_rec            => p_num_of_containers,
         p_container_info_rec    => l_container_info_rec,
         x_return_status         => x_return_status,
         x_dd_id_tab             => l_cont_dummy_tab
       );

    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'Return status ' || x_return_status);
       WSH_DEBUG_SV.logmsg(l_module_name, 'CREATED DELIVERY DETAIL ' || l_cont_dummy_tab.count);
   END IF;
   --

   IF x_return_status IN
      (WSH_UTIL_CORE.G_RET_STS_ERROR,
       WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR  ) THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR CREATING CONTAINER' || TO_CHAR ( L_CONT_INSTANCE_ID )  );
      END IF;
      --
      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_CREATE_ERROR');
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
	        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
   END IF;

   l_first := l_cont_dummy_tab.FIRST;
   OPEN c_get_rowid(l_cont_dummy_tab(l_first));
   FETCH c_get_rowid INTO x_row_id, x_cont_name;
   CLOSE c_get_rowid;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'x_row_id',x_row_id);
       WSH_DEBUG_SV.log(l_module_name, 'x_cont_name',x_cont_name);
       WSH_DEBUG_SV.logmsg(l_module_name, 'CREATED CONTAINER DELIVERY DETAIL ');
   END IF;
   --

   l_del_assg_rec.delivery_id := null;
   l_del_assg_rec.delivery_detail_id := l_cont_instance_id;
   l_del_assg_rec.parent_delivery_detail_id := null;

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.CREATE_DELIV_ASSIGNMENT_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
       --WSH_DEBUG_SV.logmsg(l_module_name,'NUMBER OF CONTS'||p_num_of_containers);
       WSH_DEBUG_SV.logmsg(l_module_name,'NUMBER OF RECORDS IN WDD '||l_cont_dummy_tab.count);
   END IF;
   --

   WSH_DELIVERY_DETAILS_PKG.create_deliv_assignment_bulk
       ( p_delivery_assignments_info => l_del_assg_rec,
         p_num_of_rec => p_num_of_containers,
         p_dd_id_tab  =>  l_cont_dummy_tab,
         x_da_id_tab => l_assignment_dummy_tab,
         x_return_status => x_return_status
   );

   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'COUNT OF WDA RECORDS'||l_assignment_dummy_tab.count);
      WSH_DEBUG_SV.logmsg(l_module_name,'Create Delivery Assignment, Return Status'||x_return_status);
   END IF;

   IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                             WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_CREATE_ERROR');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;
   END IF;

   --x_cont_instance_id := l_cont_instance_id; lpn conv
   l_first := l_cont_dummy_tab.FIRST;
   IF l_first IS NOT NULL THEN
      x_cont_instance_id := l_cont_dummy_tab(l_first);
   END IF;
   x_cont_tab := l_cont_dummy_tab;
   -- J: W/V Changes
   x_unit_weight := l_container_rec.unit_weight;
   x_unit_volume := l_container_rec.unit_volume;
   x_weight_uom_code := l_container_rec.weight_uom_code;
   x_volume_uom_code := l_container_rec.volume_uom_code;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      WSH_WMS_LPN_GRP.g_call_group_api := l_orig_value;
      WSH_WMS_LPN_GRP.g_update_to_container := l_orig_update_cont_value;
      IF c_get_lpn_info%ISOPEN THEN
         CLOSE c_get_lpn_info;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;

  WHEN Others THEN
        WSH_WMS_LPN_GRP.g_call_group_api := l_orig_value;
        WSH_WMS_LPN_GRP.g_update_to_container := l_orig_update_cont_value;
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Create_Cont_Instance_Multi',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Create_Cont_Instance_Multi;

--
/*
-----------------------------------------------------------------------------
   PROCEDURE  : Create_Container_Instance
   PARAMETERS : p_cont_name - name for the container
		p_cont_item_id - container item id (containers inv item id)
		x_cont_instance_id - delivery_detail_id for new container - if
		null then it will return a new id
		p_par_detail_id - the parent detail id (parent container)
		p_organization_id - organization id
		p_container_type_code - the container type code of container
		x_row_id - rowid of the new container record
		x_return_status - return status of API
  DESCRIPTION : This procedure creates a new container and defaults some of the
		container item attributes. The container item id of the
		container that is being created is required. If	the container
		name is not specified it defaults the name to be equal to the
		delivery detail id.

                 PLEASE DO NOT USE THIS PROCEDURE ANYMORE

------------------------------------------------------------------------------
*/
--
--THIS PROCEDURE IS OBSOLETE
PROCEDURE Create_Container_Instance (
  x_cont_name IN OUT NOCOPY  VARCHAR2,
  p_cont_item_id IN NUMBER,
  x_cont_instance_id IN OUT NOCOPY  NUMBER,
  p_par_detail_id IN NUMBER,
  p_organization_id IN NUMBER,
  p_container_type_code IN VARCHAR2,
  x_row_id OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2) IS

BEGIN

 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

END Create_Container_Instance;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Create_Multiple_Containers
   PARAMETERS : p_cont_item_id - container item id (containers inv item id)
		p_organization_id - organization id
		p_container_type_code - the container type code of container
		p_cont_name - name for the container if qty is 1 (mainly used
				by public APIs)
		p_cont_name_pre - prefix for container name
		p_cont_name_suf - suffix for container name
		p_cont_name_num - starting number for number part of container
				  name
		p_cont_name_dig - number of digits to use for the number part
				  of the container name
		p_quantity - number of containers to create
		x_cont_instance_tab - table of delivery_detail_ids for new
				  containers - if null then it will return a
				  table with new ids
		x_return_status - return status of API
  DESCRIPTION : This procedure creates a new container and defaults some of the
		container item attributes. The container item id of the
		container that is being created is required. If	the container
		name is not specified it defaults the name to be equal to the
		delivery detail id.
------------------------------------------------------------------------------
*/

-- THIS PROCEDURE IS OBSOLETE

PROCEDURE Create_Multiple_Containers (
  p_cont_item_id IN NUMBER,
  p_organization_id IN NUMBER,
  p_container_type_code IN VARCHAR2,
  p_cont_name IN VARCHAR2,
  p_cont_name_pre IN VARCHAR2,
  p_cont_name_suf IN VARCHAR2,
  p_cont_name_num IN NUMBER,
  p_cont_name_dig IN NUMBER,
  p_quantity IN NUMBER,
  x_cont_instance_tab IN OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
  x_return_status OUT NOCOPY  VARCHAR2) IS

--
BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

END Create_Multiple_Containers;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Delete_Containers
   PARAMETERS : p_cont_tab - table of container instances to be deleted.
                x_return_status - return status of API
  DESCRIPTION : This procedure in a  container instance and
                deletes the container.  If the containers are not empty or
                they are assigned to deliveries that are not open, they will
                not be deleted. Also, if the containers are either assigned to
                or container other containers packed into it, they will not be
                deleted.
------------------------------------------------------------------------------
*/


PROCEDURE Delete_Containers (
  p_container_id IN number,
  x_return_status OUT NOCOPY  VARCHAR2) IS

CURSOR Check_Hierarchy (v_detail_id NUMBER) IS
SELECT 'NOT EMPTY' FROM DUAL
WHERE EXISTS (
SELECT delivery_detail_id
FROM wsh_delivery_assignments
WHERE parent_delivery_detail_id = v_detail_id
AND NVL(type, 'S') in ('C', 'S')
AND rownum < 2
UNION
SELECT delivery_detail_id
FROM wsh_delivery_assignments
WHERE delivery_detail_id = v_detail_id
AND parent_delivery_detail_id IS NOT NULL
AND NVL(type, 'S') in ('C', 'S')
AND rownum < 2);

CURSOR Check_Container (v_detail_id NUMBER) IS
SELECT container_flag
FROM WSH_DELIVERY_DETAILS
WHERE delivery_detail_id = v_detail_id;



l_cont_status   VARCHAR2(30) := 'EMPTY';
l_container_flag VARCHAR2(1);

l_del_id        NUMBER;
l_del_sts       VARCHAR2(10);

l_return_status VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


Invalid_Container  EXCEPTION;
Invalid_Delivery   EXCEPTION;
Invalid_Detail     EXCEPTION;
Delete_Det_Error   EXCEPTION;
Cont_Not_Empty     EXCEPTION;
Container_Error    EXCEPTION;
Unassign_Del_Error EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_CONTAINERS';
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
            WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_ID',P_CONTAINER_ID);
        END IF;
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        SAVEPOINT Delete_Cont;
        IF (NVL(p_container_id,0) = 0) THEN
                raise Invalid_Container;
        ELSE
         OPEN Check_Container (p_container_id);
         IF Check_Container%NOTFOUND THEN
                raise Invalid_Detail;
         ELSE
           FETCH Check_Container INTO l_container_flag;
           IF l_container_flag = 'N' THEN
                raise Invalid_Detail;
           END IF;
         END IF;
         IF Check_Container%ISOPEN THEN
           CLOSE Check_Container;
         END IF;
        END IF;
        -- get the delivery status of the container and check if it is assigned
        -- to a closed or in-transit delivery (only open deliveries allowed)

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_DELIVERY_STATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_CONTAINER_UTILITIES.Get_Delivery_Status (
                                                p_container_id,
                                                l_del_id,
                                                l_del_sts,
                                                x_return_status);

        IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          raise Container_Error;
        END IF;
        IF ((nvl(l_del_id,-99) <> -99) AND (nvl(l_del_sts,'N/A') <> 'OP')) THEN
                    raise Invalid_Delivery;
        END IF;
        l_cont_status := 'EMPTY';

        OPEN Check_Hierarchy (p_container_id);

        FETCH Check_Hierarchy INTO l_cont_status;

        IF Check_Hierarchy%NOTFOUND THEN


                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'Delivery Status',l_del_sts);
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.DELETE_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_DELIVERY_DETAILS_PKG.Delete_Delivery_Details (
                                 p_rowid              => null,
                                 p_delivery_detail_id => p_container_id,
                                 x_return_status      => x_return_status);

                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
                END IF;
                --

                IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    raise Container_Error;
                END IF;

        ELSE

                IF (nvl(l_cont_status,'EMPTY') <> 'EMPTY') THEN
                   raise Cont_Not_Empty;
                ELSE
                    raise Container_Error;
                END IF;
        END IF;

        IF Check_Hierarchy%ISOPEN THEN
                     CLOSE Check_Hierarchy;
        END IF;


--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Invalid_Container  THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_CONT_NULL_DELETE');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_CONTAINER exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_CONTAINER');
        END IF;
        --
  WHEN Invalid_Delivery   THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DEL_STS_INVALID');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_DELIVERY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_DELIVERY');
        END IF;
        --
  WHEN Invalid_Detail     THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DELETE_NOT_CONT');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_DETAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_DETAIL');
        END IF;
        --
  WHEN Cont_Not_Empty     THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DELETE_NOT_EMPTY');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'CONT_NOT_EMPTY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CONT_NOT_EMPTY');
        END IF;
        --
  WHEN Container_Error    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DELETE_ERROR');
        WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'CONTAINER_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CONTAINER_ERROR');
        END IF;
        --
  WHEN Unassign_Del_Error THEN
        ROLLBACK to Delete_Cont;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('WSH','WSH_UNASSIGN_DEL_ERROR');
        WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'UNASSIGN_DEL_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UNASSIGN_DEL_ERROR');
END IF;
--
  WHEN Others THEN
        WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Delete_Containers',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Delete_Containers;

-- THIS PROCEDURE IS OBSOLETE
/*
-----------------------------------------------------------------------------
   PROCEDURE  : Update_Container
   PARAMETERS : p_container_name - new container name that needs to be assigned
		to the existing container.
		p_container_instance_id - the delivery detail id for the
		container that needs to be updated.
		p_old_cont_name - exisiting container name for the container,
		to be used only if container instance id in the input parameter
		is null.
		x_return_status - return status of API
  DESCRIPTION : This procedure takes in a new container name and existing
		container information like the delivery detail id and existing
		container name that needs to be updated. The API checks to see
		if the container that is being updated is assigned to a closed,
		confirmed or in-transit delivery. If it is, no update is
		allowed - if not, only the container name can be updated.
------------------------------------------------------------------------------
*/


--THIS PROCEDURE IS OBSOLETE
PROCEDURE Update_Container (
  p_container_name IN VARCHAR2,
  p_container_instance_id IN NUMBER,
  p_old_cont_name IN VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2) IS

BEGIN

 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

END Update_Container;



/*
-----------------------------------------------------------------------------
   PROCEDURE  : Assign_Detail
   PARAMETERS : p_container_instance_id - container instance id of container
		p_del_detail_tab - table of delivery detail ids
		x_pack_status - status of container after packing the lines
			into it : underpacked or overpacked
		x_return_status - return status of API
  DESCRIPTION : This procedure assigns a number of lines to the specified
		container instance and returns a pack status of underpacked
		or overpacked or success.
------------------------------------------------------------------------------
*/


PROCEDURE Assign_Detail(
  p_container_instance_id IN NUMBER,
  p_del_detail_tab IN WSH_UTIL_CORE.id_tab_type,
  x_pack_status OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2,
  p_check_credit_holds IN BOOLEAN) IS

  CURSOR Get_First_Line (v_cont_instance_id NUMBER) IS
  SELECT delivery_detail_id
  FROM wsh_delivery_assignments_v
  WHERE parent_delivery_detail_id = v_cont_instance_id
  AND rownum < 2;

  CURSOR Get_Cont_Item IS
  SELECT inventory_item_id, master_serial_number
  FROM WSH_DELIVERY_DETAILS
  WHERE delivery_detail_id = p_container_instance_id
  AND container_flag = 'Y';

  CURSOR Get_Det_Cont_Item (v_detail_id NUMBER) IS
  SELECT nvl(detail_container_item_id, master_container_item_id),
	 source_line_id, source_header_id,source_code
  FROM WSH_DELIVERY_DETAILS
  WHERE delivery_detail_id = v_detail_id
  AND container_flag = 'N';

  l_del_detail_id	WSH_DELIVERY_DETAILS.delivery_detail_id%TYPE;

  l_group_id_tab 	WSH_UTIL_CORE.id_tab_type;
--  l_temp_detail_tab	WSH_UTIL_CORE.id_tab_type;

  l_src_line_id		NUMBER;
  l_src_hdr_id		NUMBER;
  l_source_code         VARCHAR2(30);

  cnt			NUMBER;
  i			NUMBER;
  l_group_id		NUMBER;

  l_del_rows		WSH_UTIL_CORE.id_tab_type;
  l_ret_sts		VARCHAR2(1);

  l_cont_name VARCHAR2(30);
  l_delivery_id NUMBER;
  l_del_status VARCHAR2(10);

  l_det_cont_item_id NUMBER;
  l_cont_item_id NUMBER;

  l_tmp_status VARCHAR2(30) := 'OK';

  l_attr_flag VARCHAR2(1) := 'N';

  l_upd_flag BOOLEAN := FALSE;

  l_master_serial_number VARCHAR2(30);
  l_master_cont_id	NUMBER;
  l_master_cont_name    VARCHAR2(30);

  l_attr_tab  wsh_delivery_autocreate.grp_attr_tab_type;
  l_group_tab  wsh_delivery_autocreate.grp_attr_tab_type;
  l_action_rec wsh_delivery_autocreate.action_rec_type;
  l_target_rec wsh_delivery_autocreate.grp_attr_rec_type;
  l_matched_entities wsh_util_core.id_tab_type;
  l_out_rec wsh_delivery_autocreate.out_rec_type;



--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ASSIGN_DETAIL';
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
      WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_CHECK_CREDIT_HOLDS',P_CHECK_CREDIT_HOLDS);
  END IF;
  --
  IF p_del_detail_tab.COUNT = 0 THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('WSH', 'WSH_CONT_DET_ASSG_NULL');
     WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return;
  END IF;

  -- get the delivery status of the container and check if it is assigned
  -- to a closed or in-transit delivery (only open deliveries allowed)

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_DELIVERY_STATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_CONTAINER_UTILITIES.Get_Delivery_Status ( p_container_instance_id,
						l_delivery_id,
						l_del_status,
						x_return_status);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Delivery Status',l_del_status);
    WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
  END IF;
  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;

  IF (nvl(l_delivery_id,-99) <> -99) THEN

	IF (nvl(l_del_status,'N/A') NOT IN  ('OP','SA')) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DEL_STS_INVALID');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
		x_pack_status := 'Error';
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
	END IF;
  END IF;


  -- check container attributes to see if the attr columns have been populated
  -- if they are not null - it implies that lines are already assigned to the
  -- container in the hierarchy. so call the autocreate deliveries API with the
  -- container as the first line..

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.CHECK_CONT_ATTRIBUTES',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_container_actions.Check_Cont_Attributes (
					p_container_instance_id,
					l_attr_flag,
					x_return_status);

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,' after CHECK_CONT_ATTRIBUTES, return status is',x_return_status);
  END IF;

  --dbms_output.put_line('after check attr for ' || p_container_instance_id || ' attr flag is ' || l_attr_flag || ' and ret sts is  ' || x_return_status);

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

  IF l_attr_flag = 'N' THEN
	i := 1;
  ELSE
	l_attr_tab(1).entity_id := p_container_instance_id;
	l_attr_tab(1).entity_type := 'DELIVERY_DETAIL';
	i := 2;
  END IF;


  FOR j IN 1.. p_del_detail_tab.COUNT LOOP
     l_attr_tab(i).entity_id := p_del_detail_tab(j);
     l_attr_tab(i).entity_type := 'DELIVERY_DETAIL';
     i := i + 1;
  END LOOP;

  IF Get_First_Line%ISOPEN THEN
  	CLOSE Get_First_Line;
  END IF;

  -- call auto_create del grouping API with l_temp_detail_tab returning
  -- l_group_id_tab of type WSH_UTIL_CORE.id_tab_type;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.AUTOCREATE_DELIVERIES',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
   l_action_rec.action := 'MATCH_GROUPS';



   WSH_Delivery_AutoCreate.Find_Matching_Groups(p_attr_tab => l_attr_tab,
                                                   p_action_rec => l_action_rec,
                                                   p_target_rec => l_target_rec,
                                                   p_group_tab => l_group_tab,
                                                   x_matched_entities => l_matched_entities,
                                                   x_out_rec => l_out_rec,
                                                   x_return_status => x_return_status);

  --
  IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
	--dbms_output.put_line('error in autocreate');
	FND_MESSAGE.SET_NAME('WSH','WSH_GROUP_DETAILS_ERROR');
        WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
  END IF;

  i := l_attr_tab.FIRST;

  l_group_id := l_attr_tab(i).group_id;

  -- if l_attr_flag = Y then it means that the first record in the PL/SQL table
  -- is the container itself and it should be ignored. so increment counters.

  IF l_attr_flag = 'Y' THEN
	i := i + 1;
  END IF;

  l_del_detail_id := l_attr_tab(i).entity_id;
  l_ret_sts := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  OPEN Get_Cont_Item;

  FETCH Get_Cont_Item INTO l_cont_item_id,l_master_serial_number;

  IF Get_Cont_Item%NOTFOUND THEN
	CLOSE Get_Cont_Item;
	l_ret_sts := WSH_UTIL_CORE.G_RET_STS_ERROR;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
	FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
	WSH_UTIL_CORE.Add_Message(l_ret_sts,l_module_name);
	x_return_status := l_ret_sts;
	x_pack_status := 'Error';
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;

  IF Get_Cont_Item%ISOPEN THEN
	CLOSE Get_Cont_Item;
  END IF;


  WHILE  i <= l_attr_tab.COUNT LOOP

     IF l_group_id = l_attr_tab(i).group_id THEN


	l_del_detail_id := l_attr_tab(i).entity_id;
	l_src_line_id := NULL;
 	l_src_hdr_id := NULL;

	-- check if the detail container item id on the line matches the
	-- container item id of the container that it is being assigned to

        OPEN Get_Det_Cont_Item (l_del_detail_id);

	FETCH Get_Det_Cont_Item INTO
	      l_det_cont_item_id,
	      l_src_line_id,
	      l_src_hdr_id,l_source_code;

	IF Get_Det_Cont_Item%NOTFOUND THEN
	   CLOSE Get_Det_Cont_Item;
	   l_ret_sts := WSH_UTIL_CORE.G_RET_STS_ERROR;
           l_tmp_status := 'Error';
	   GOTO next_line;
	 END IF;

	 IF Get_Det_Cont_Item%ISOPEN THEN
	    CLOSE Get_Det_Cont_Item;
	 END IF;

	 IF l_cont_item_id <> nvl(l_det_cont_item_id,l_cont_item_id) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_DET_CONT_ITEM_DIFF');
		FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_del_detail_id);
		WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
		IF l_ret_sts <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
		   l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
		END IF;
	 END IF;

	  -- check if the line has any holds on it. IF yes ignore the line
	  -- and set a warning and proceed to the next line.

	--
	--
	-- added to fix bug 1818233.
	-- Auto-pack performs 90% of time doing this check, especially
	-- when a single delivery line is being split into multiple due to
	-- container-load relationship.
	-- This check will be made only once for a delivery line in place of
	-- doing it every time we assign a split delivery line to a container.
	-- Thus, auto-pack lines will always call assign_detail procedure
	-- with parameter p_check_credit_holds = FALSE.
	-- Auto-pack lines will explicitly call the procedure
	-- WSH_DETAILS_VALIDATIONS.Check_Credit_Holds only once for a delivery
	-- line
	--
        IF p_check_credit_holds
	THEN
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_CREDIT_HOLDS',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    WSH_DETAILS_VALIDATIONS.Check_Credit_Holds (
					l_del_detail_id,
					'PACK',
					l_src_line_id,
					l_src_hdr_id,
                                        l_source_code,
					'Y',
					x_return_status);

            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
            END IF;
            --
	    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		IF l_ret_sts <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
		   l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
		END IF;
		l_tmp_status := 'Error';
		GOTO next_line;
	    END IF;
	END IF;

	-- check if line has any invalid hazmat codes - either by itself
	-- or if there is any incompatability with any existing lines in
	-- the container.

	-- currently there is no code for this and so the API returns a
	-- success always..

	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.VALIDATE_HAZARD_CLASS',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_CONTAINER_UTILITIES.Validate_Hazard_Class (
		l_del_detail_id,
		p_container_instance_id,
		x_return_status);

	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		IF l_ret_sts <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
		   l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
		END IF;
		l_tmp_status := 'Error';
		GOTO next_line;
	END IF;

	-- create assignment with l_del_detail_id and p_container_instance_id;

        --
        IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_DETAIL_TO_CONT',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_DELIVERY_DETAILS_ACTIONS.Assign_Detail_To_Cont (
		l_del_detail_id,
		p_container_instance_id,
		x_return_status);

            --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
        END IF;
        --
	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
              l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
           ELSE
		-- l_ret_sts := x_return_status;
		--dbms_output.put_line('error assigning ' || l_del_detail_id);
		l_ret_sts := WSH_UTIL_CORE.G_RET_STS_ERROR;
	     	FND_MESSAGE.SET_NAME('WSH', 'WSH_CONT_DETAIL_NOT_ASSIGNED');
		FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_del_detail_id);
 	    	WSH_UTIL_CORE.Add_Message(l_ret_sts,l_module_name);
	    END IF;
	 END IF;

	 -- store group id to check for group id of next line
	 -- l_group_id := l_group_id_tab(cnt);

	    -- now update the container grouping attribute columns with the
	    -- attributes from the delivery details (only for first line).
            -- we need to do this regardless of the fact the the line may have
            -- grouping attributes populated as in the case of updating line direction
            -- of a container already assigned to a delivery.

            IF NOT l_upd_flag THEN

		--dbms_output.put_line('calling update cont hierarchy with ' || p_container_instance_id);
	    	--
	    	IF l_debug_on THEN
	    	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.UPDATE_CONT_HIERARCHY',WSH_DEBUG_SV.C_PROC_LEVEL);
	    	END IF;
	    	--
	    	wsh_container_actions.Update_Cont_Hierarchy (
						l_del_detail_id,
						NULL,
						p_container_instance_id,
						x_return_status);
                --
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
                END IF;
                --

	    	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			FND_MESSAGE.SET_NAME('WSH','WSH_CONT_UPD_ATTR_ERROR');
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			--
			l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
			FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
			WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	    	 END IF;

		 l_upd_flag := TRUE;



	    END IF;

	    UPDATE WSH_DELIVERY_DETAILS
	    SET master_serial_number = l_master_serial_number
	    WHERE delivery_detail_id = l_del_detail_id;

	    IF SQL%ROWCOUNT > 1 OR SQL%NOTFOUND THEN
  --dbms_output.put_line('error updating master serial number for detail ' || l_del_detail_id);

		FND_MESSAGE.SET_NAME('WSH','WSH_DET_UPD_SER_ERROR');
		FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_del_detail_id);
		WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
	 	IF l_ret_sts <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
			l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
	    	END IF;
	     END IF;
        ELSE

          l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
          l_tmp_status := 'Error';
          GOTO next_line;

        END IF;

	<<next_line>>
		IF l_tmp_status = 'Error' THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_CONT_DETAIL_NOT_ASSIGNED');
			FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_del_detail_id);
			WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
	 	END IF;

	i := i + 1;
	l_tmp_status := 'OK';

   END LOOP;

   x_return_status := l_ret_sts;

	--
	IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
	   WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Assign_Detail',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Assign_Detail;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Unassign_Detail
   PARAMETERS : p_container_instance_id - container instance id of container
		p_delivery_id - delivery id from which detail needs to be
		unassigned
		p_del_detail_tab - table of delivery detail ids
		p_cont_unassign - flag to determine whether to unassign from
		container or not.
		p_del_unassign - flag to determine whether to unassign from
		delivery or not
		x_pack_status - status of container after packing the lines
			into it : underpacked or overpacked
		x_return_status - return status of API
  DESCRIPTION : This procedure unassigns a number of lines from the specified
		container instance or delivery and returns a pack status of
		underpacked or overpacked or success. The unassigning is
		determined using the two unassign flags or by specific ids.
------------------------------------------------------------------------------
*/



PROCEDURE Unassign_Detail(
  p_container_instance_id IN NUMBER,
  p_delivery_id IN NUMBER,
  p_del_detail_tab IN WSH_UTIL_CORE.id_tab_type,
  p_cont_unassign IN VARCHAR2,
  p_del_unassign IN VARCHAR2,
  x_pack_status OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2,
  p_action_prms IN wsh_glbl_var_strct_grp.dd_action_parameters_rec_type
  ) IS

  l_del_detail_rec 	WSH_UTIL_CORE.ID_TAB_TYPE;

  l_gross 	NUMBER;
  l_net		NUMBER;
  l_volume	NUMBER;
-- J: W/V Changes
  l_fill_status  VARCHAR2(1);

  l_rows	NUMBER;

  cnt		NUMBER;

  CURSOR Get_Min_Fill IS
  SELECT minimum_fill_percent
  FROM WSH_DELIVERY_DETAILS
  WHERE delivery_detail_id = p_container_instance_id
  AND container_flag = 'Y';

  /* wms -change : Added inentory_item_id to later check (ignore) fill pc when LPN */
  CURSOR Is_Container (v_detail_id NUMBER) IS
  SELECT container_flag, serial_number, master_serial_number, inventory_item_id
  FROM WSH_DELIVERY_DETAILS
  WHERE delivery_detail_id = v_detail_id;

  CURSOR Get_Cont (v_detail_id NUMBER) IS
  SELECT wda.parent_delivery_detail_id container_instance_id, wda.delivery_id,
         wddp.organization_id, nvl(wddp.line_direction,'O'),    -- K LPN CONV. rv
         wddp.container_flag -- K: MDC
  FROM wsh_delivery_assignments wda,
       wsh_delivery_details wddp        -- K LPN CONV. rv
  WHERE wda.delivery_detail_id = v_detail_id
  AND   wda.parent_delivery_detail_id = wddp.delivery_detail_id(+)
  AND   NVL(wda.type, 'S') in ('S', 'C');


  l_cont_flag	VARCHAR2(1);
  l_serial_number VARCHAR2(30);
  l_master_serial_number VARCHAR2(30);

  l_master_cont_id NUMBER;
  l_master_cont_name VARCHAR2(30);

  l_cont_name VARCHAR2(30);

  l_cont_instance_id NUMBER;
  l_cont_org_id NUMBER;  -- K LPN CONV. rv
  l_cont_line_dir VARCHAR2(10);  -- K LPN CONV. rv
  l_cnt_org_id NUMBER;  -- K LPN CONV. rv
  l_delivery_id NUMBER;
  l_last_line_flag VARCHAR2(1);
  l_attr_flag VARCHAR2(1) := 'N';

  l_return_status VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_del_status VARCHAR2(10);

  l_cont_tab          WSH_UTIL_CORE.id_tab_type;
  l_cont_org_tab      WSH_UTIL_CORE.id_tab_type; -- K LPN CONV. rv
  l_cont_line_dir_tab WSH_UTIL_CORE.Column_Tab_Type; -- K LPN CONV. rv

  -- K: MDC
  l_mdc_index        NUMBER := 0;
  l_mdc_details      WSH_UTIL_CORE.id_tab_type;


  l_cont_item_id NUMBER;  -- wms change:

l_num_warnings          number := 0;

-- K LPN CONV. rv
l_wms_org    VARCHAR2(10) := 'N';
l_sync_tmp_rec wsh_glbl_var_strct_grp.sync_tmp_rec_type;

cursor l_get_cnt_org_csr (p_cnt_inst_id IN NUMBER) is
select organization_id
from   wsh_delivery_details
where  delivery_detail_id = p_cnt_inst_id;

-- K LPN CONV. rv

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UNASSIGN_DETAIL';
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
      WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_CONT_UNASSIGN',P_CONT_UNASSIGN);
      WSH_DEBUG_SV.log(l_module_name,'P_DEL_UNASSIGN',P_DEL_UNASSIGN);
  END IF;
  --
  IF p_del_detail_tab.count = 0 THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_ASSG_NULL');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;

  cnt := 0;

  FOR i IN 1..p_del_detail_tab.count LOOP

 	-- get the delivery status of the container and check if it is assigned
  	-- to a closed or in-transit delivery (only open deliveries allowed)
	OPEN Get_Cont (p_del_detail_tab(i));
	FETCH Get_Cont INTO l_cont_instance_id, l_delivery_id,
                            l_cont_org_id, l_cont_line_dir, -- K LPN CONV. rv
                            l_cont_flag; -- K: MDC

	IF Get_Cont%NOTFOUND THEN
		CLOSE Get_Cont;
		GOTO next_detail;
	END IF;
	IF Get_Cont%ISOPEN THEN
		CLOSE Get_Cont;
	END IF;

  	--
  	IF l_debug_on THEN
  	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_DELIVERY_STATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
  	END IF;
  	--
  	WSH_CONTAINER_UTILITIES.Get_Delivery_Status (
					l_cont_instance_id,
					l_delivery_id,
					l_del_status,
					x_return_status);

        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
        END IF;
        --
  	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
			l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		END IF;
		GOTO next_detail;
  	END IF;

  	IF (nvl(l_delivery_id,-99) <> -99) THEN

		IF (nvl(l_del_status,'N/A') <> 'OP')
        AND NVL(p_action_prms.caller,'!!!!') NOT LIKE '%' || WSH_UTIL_CORE.C_SPLIT_DLVY_SUFFIX   -- J-IB-NPARIKH
        THEN
			FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DEL_STS_INVALID');
			x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
				l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			END IF;
			x_pack_status := 'Error';
			GOTO next_detail;
		END IF;
  	END IF;
        IF l_cont_instance_id IS NOT NULL AND l_cont_flag = 'C' THEN
             l_mdc_index       := l_mdc_index + 1;
             l_mdc_details(l_mdc_index) := p_del_detail_tab(i);
        ELSE
	   cnt := cnt + 1;
  	   l_del_detail_rec(cnt)    := p_del_detail_tab(i);
	   l_cont_tab(cnt)          := l_cont_instance_id; -- K LPN CONV. rv
	   l_cont_org_tab(cnt)      := l_cont_org_id;       -- K LPN CONV. rv
	   l_cont_line_dir_tab(cnt) := l_cont_line_dir;     -- K LPN CONV. rv
        END IF;
        <<next_detail>>
		null;

  END LOOP;

  IF l_mdc_index > 0 THEN
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Unpack_Details_from_Consol',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     Unpack_Details_from_Consol
               (p_delivery_details_tab  => l_mdc_details,
                p_caller                => 'WMS_UNASSIGN_CONSOL',
                x_return_status         => x_return_status);

     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
     END IF;
     --
     IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           l_num_warnings := l_num_warnings + 1;
        ELSE
	  --
          IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
	  return;
        END IF;
     END IF;

     IF cnt = 0 THEN
        return;
     END IF;

  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_MULTIPLE_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Multiple_Details (
						l_del_detail_rec,
						p_del_unassign,
						p_cont_unassign,
						x_return_status,
						null,
                    p_action_prms);

   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
   END IF;
   --
  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
     IF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_num_warnings := l_num_warnings + 1;
     ELSE
--	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_UNASSG_ERROR');
--	WSH_UTIL_CORE.Add_Message(x_return_status);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
     END IF;
  END IF;

  -- fetch the container for each line and update the attr columns if it is
  -- the last line in the container hierarchy..

  FOR i IN 1..l_del_detail_rec.count LOOP

    IF l_cont_tab(i) IS NULL THEN
      -- not assigned to a container.
      GOTO next_line;
    END IF;

    -- K LPN CONV. rv
    l_wms_org := wsh_util_validate.check_wms_org(l_cont_org_tab(i));
    -- K LPN CONV. rv

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_wms_org',l_wms_org);
    END IF;
	--dbms_output.put_line('calling last assigned line for ' || l_del_detail_rec(i));

	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.LAST_ASSIGNED_LINE',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wsh_container_actions.Last_Assigned_Line (
					l_del_detail_rec(i),
					l_cont_tab(i),
					l_last_line_flag,
					x_return_status);

        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
        END IF;
        --
	IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                               WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
          ) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_LAST_LINE_ERROR');
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_cont_tab(i));
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
		WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
			l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		END IF;
		GOTO next_line;
	END IF;

	--dbms_output.put_line('calling check cont attr with ' || l_cont_tab(i));

	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.CHECK_CONT_ATTRIBUTES',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wsh_container_actions.Check_Cont_Attributes (
					l_cont_tab(i),
					l_attr_flag,
					x_return_status);
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
        END IF;
        --

	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	--dbms_output.put_line('after check cont attr status is ' || x_return_status);
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_ATTR_ERROR');
		WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
			l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		END IF;
		GOTO next_line;
	END IF;

--dbms_output.put_line(' last line flag is ' || l_last_line_flag || ' attr flag ' || l_attr_flag || ' and delivery_id ' || l_delivery_id || ' before updating cont ' || l_cont_tab(i));


	IF (nvl(l_last_line_flag,'N') = 'Y') AND (nvl(l_attr_flag,'N') = 'Y') AND (nvl(l_delivery_id,-99) = -99) THEN

--dbms_output.put_line('updating attr to null for ' || l_cont_tab(i));


                --
                -- K LPN CONV. rv
                IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
                AND l_cont_line_dir_tab(i) IN ('O','IO')
                AND
                (
                  (WSH_WMS_LPN_GRP.GK_WMS_UPD_GRP and l_wms_org = 'Y')
                  OR
                  (WSH_WMS_LPN_GRP.GK_INV_UPD_GRP and l_wms_org = 'N')
                )
                THEN
                --{
                    l_sync_tmp_rec.delivery_detail_id := l_cont_tab(i);
                    l_sync_tmp_rec.operation_type := 'UPDATE';
                    WSH_WMS_SYNC_TMP_PKG.MERGE
                    (
                      p_sync_tmp_rec      => l_sync_tmp_rec,
                      x_return_status     => l_return_status
                    );

                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_WMS_SYNC_TMP_PKG.MERGE',l_return_status);
                    END IF;
                    --
                    --
                    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                      --
                      GOTO next_line;
                      --
                    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                      --
                      l_num_warnings := l_num_warnings + 1;
                      --
                    END IF;
                    --
                --}
                END IF;
                -- K LPN CONV. rv

		UPDATE WSH_DELIVERY_DETAILS
		SET 	customer_id = NULL,
			ship_to_location_id = NULL,
			intmed_ship_to_location_id = NULL,
			fob_code = NULL,
		  	freight_terms_code = NULL,
			ship_method_code = NULL,
			carrier_id = NULL,
			mode_of_transport = NULL,
			service_level = NULL,
			deliver_to_location_id = NULL,
                        line_direction = DECODE(line_direction,'IO','O',line_direction),    -- J-IB-NPARIKH
                        client_id = NULL  -- LSP PROJECT :
		WHERE delivery_detail_id = l_cont_tab(i);

		IF SQL%ROWCOUNT > 1 OR SQL%NOTFOUND THEN
			FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
			WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
				l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			END IF;
			GOTO next_line;
		END IF;

		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.UPDATE_CONT_HIERARCHY',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		wsh_container_actions.Update_Cont_Hierarchy (
						l_cont_tab(i),
						NULL,
						l_cont_tab(i),
						x_return_status);
                --
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
                END IF;
                --

	    	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			FND_MESSAGE.SET_NAME('WSH','WSH_CONT_UPD_ATTR_ERROR');
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			--
			l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_cont_tab(i));
			FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
			WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
				l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			END IF;
			GOTO next_line;
		END IF;

	END IF;

	OPEN Is_Container (l_del_detail_rec(i));

	FETCH Is_Container INTO
		l_cont_flag,
		l_serial_number,
		l_master_serial_number,
		l_cont_item_id;

	IF Is_Container%NOTFOUND THEN
		CLOSE Is_Container;
		FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
		FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_del_detail_rec(i));
		WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
			l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		END IF;
		GOTO next_line;
	END IF;

	IF Is_Container%ISOPEN THEN
		CLOSE Is_Container;
	END IF;

         IF l_cont_flag = 'N' THEN --{
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_cont_flag',l_cont_flag);
              WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id',l_del_detail_rec(i));
           END IF;
           --
           UPDATE wsh_delivery_details --bug 5165197
           SET master_serial_number = NULL
           WHERE delivery_detail_id = l_del_detail_rec(i);
           --
         ELSIF l_cont_flag = 'Y' THEN --}{

	  	--
	  	IF l_debug_on THEN
	  	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_DELIVERY_STATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
	  	END IF;
	  	--
	  	WSH_CONTAINER_UTILITIES.Get_Delivery_Status (
					l_del_detail_rec(i),
					l_delivery_id,
					l_del_status,
					x_return_status);
                --
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
                END IF;
                --

  		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
				l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			END IF;
			GOTO next_line;
  		END IF;

  		IF (nvl(l_delivery_id,-99) <> -99) THEN --{

			IF (nvl(l_del_status,'N/A') <> 'OP') THEN
				FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DEL_STS_INVALID');
				x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
				WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
					l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
				END IF;
				x_pack_status := 'Error';
				GOTO next_line;
			END IF;
  		END IF; --}

            -- Bug 8925387 .. Removed the goto next_line statement,since master serial number has to be updated irrespect of delivery exist or not.
            -- Last_Assigned_Line and Check_Cont_Attributes will be called only if the container belongs to a delivery.
            IF (nvl(l_delivery_id,-99) = -99) THEN  --{ Delivery Check
                 --
                 IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.LAST_ASSIGNED_LINE',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 wsh_container_actions.Last_Assigned_Line (
                                                            NULL,
                                                            l_del_detail_rec(i),
                                                            l_last_line_flag,
                                                            x_return_status);
                 --
                 IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
                 END IF;
                 --

                 IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN --{
                      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_LAST_LINE_ERROR');
                      --
                      IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                      END IF;
                      --
                      l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_del_detail_rec(i));
                      FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
                      WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);

                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                           l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                      END IF;
                      GOTO next_line;
                 END IF;	--}

                 --dbms_output.put_line('calling check cont attr with ' || l_del_detail_rec(i));

                 --
                 IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.CHECK_CONT_ATTRIBUTES',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 wsh_container_actions.Check_Cont_Attributes (
                                                             l_del_detail_rec(i),
                                                             l_attr_flag,
                                                             x_return_status);
                 --
                 IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
                 END IF;
                 --

                 IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN --{
                      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_ATTR_ERROR');
                      WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);

                      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                           l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                      END IF;
                      GOTO next_line;
                 END IF; --}
            END IF; --} Delivery Check


		IF (nvl(l_last_line_flag,'N') = 'Y') AND (nvl(l_attr_flag,'N') = 'Y') AND (nvl(l_delivery_id,-99) = -99) THEN --{
                        --
                        -- K LPN CONV. rv
                        IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
                        AND l_cont_line_dir_tab(i) IN ('O','IO')
                        AND
                        (
                          (WSH_WMS_LPN_GRP.GK_WMS_UPD_GRP and l_wms_org = 'Y')
                          OR
                          (WSH_WMS_LPN_GRP.GK_INV_UPD_GRP and l_wms_org = 'N')
                        )
                        THEN
                        --{
                            l_sync_tmp_rec.delivery_detail_id := l_del_detail_rec(i);
                            l_sync_tmp_rec.operation_type := 'UPDATE';
                            WSH_WMS_SYNC_TMP_PKG.MERGE
                            (
                              p_sync_tmp_rec      => l_sync_tmp_rec,
                              x_return_status     => l_return_status
                            );

                            IF l_debug_on THEN
                              WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_WMS_SYNC_TMP_PKG.MERGE',l_return_status);
                            END IF;
                            --
                            --
                            --
                            IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                              --
                              GOTO next_line;
                              --
                            ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                              --
                              l_num_warnings := l_num_warnings + 1;
                              --
                            END IF;
                            --
                        --}
                        END IF;
                        -- K LPN CONV. rv

			UPDATE WSH_DELIVERY_DETAILS
			SET 	customer_id = NULL,
				ship_to_location_id = NULL,
				intmed_ship_to_location_id = NULL,
				fob_code = NULL,
			  	freight_terms_code = NULL,
				ship_method_code = NULL,
				service_level = NULL,
				carrier_id = NULL,
				mode_of_transport = NULL,
				deliver_to_location_id = NULL,
                                line_direction = DECODE(line_direction,'IO','O',line_direction),    -- J-IB-NPARIKH
                                client_id = NULL  -- LSP PROJECT
			WHERE delivery_detail_id = l_del_detail_rec(i);

			IF SQL%ROWCOUNT > 1 OR SQL%NOTFOUND THEN
				FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
				WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
					l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
				END IF;
				GOTO next_line;
			END IF;

			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.UPDATE_CONT_HIERARCHY',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			--
			wsh_container_actions.Update_Cont_Hierarchy (
						l_del_detail_rec(i),
						NULL,
						l_del_detail_rec(i),
						x_return_status);
                        --
                        IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
                        END IF;
                        --

		    	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN --{
				FND_MESSAGE.SET_NAME('WSH','WSH_CONT_UPD_ATTR_ERROR');
				--
				IF l_debug_on THEN
				    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;
				--
				l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_del_detail_rec(i));
				FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
				WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
					l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
				END IF;
				GOTO next_line;
			END IF;	--}

		END IF;--}

		-- update child containers of the current hierarchy that was
		-- unassigned with the serial number of the current top most
		-- container..
                --
                -- K LPN CONV. rv
                IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
                AND l_cont_line_dir_tab(i) IN ('O','IO')
                AND
                (
                  (WSH_WMS_LPN_GRP.GK_WMS_UPD_MISC and l_wms_org = 'Y')
                  OR
                  (WSH_WMS_LPN_GRP.GK_INV_UPD_MISC and l_wms_org = 'N')
                )
                THEN
                --{
                    l_sync_tmp_rec.delivery_detail_id := l_del_detail_rec(i);
                    l_sync_tmp_rec.operation_type := 'UPDATE';
                    WSH_WMS_SYNC_TMP_PKG.MERGE
                    (
                      p_sync_tmp_rec      => l_sync_tmp_rec,
                      x_return_status     => l_return_status
                    );

                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_WMS_SYNC_TMP_PKG.MERGE',l_return_status);
                    END IF;
                    --
                    --
                    --
                    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                      --
                      GOTO next_line;
                      --
                    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                      --
                      l_num_warnings := l_num_warnings + 1;
                      --
                    END IF;
                    --
                --}
                END IF;
                -- K LPN CONV. rv

		UPDATE WSH_DELIVERY_DETAILS
		SET master_serial_number = serial_number
		WHERE delivery_detail_id = l_del_detail_rec(i);

		IF SQL%ROWCOUNT > 1 OR SQL%NOTFOUND THEN
			FND_MESSAGE.SET_NAME('WSH','WSH_CONT_CHILD_UPD_ERROR');
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			--
			l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_del_detail_rec(i));
			FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
				l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			END IF;
			GOTO next_line;
		END IF;

		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_MASTER_SERIAL_NUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		WSH_CONTAINER_UTILITIES.Get_Master_Serial_Number (
					l_del_detail_rec(i),
					l_master_serial_number,
					x_return_status);
                 --
                 IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
                 END IF;
                 --

		IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			FND_MESSAGE.SET_NAME('WSH','WSH_CONT_GET_SRL_ERROR');
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			--
			l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_del_detail_rec(i));
			FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
				l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			END IF;
			GOTO next_line;
		END IF;

		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.UPDATE_CHILD_CONTAINERS',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		WSH_CONTAINER_UTILITIES.Update_Child_Containers (
					l_del_detail_rec(i),
					l_master_cont_name,
					l_master_serial_number,
					x_return_status);
                 --
                 IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
                 END IF;
                 --

	    	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			--
			l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_del_detail_rec(i));
     			FND_MESSAGE.SET_NAME('WSH', 'WSH_CONT_CHILD_UPD_ERROR');
			FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
			x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			--
			return;
    		END IF;

	END IF; --}

  	<<next_line>>
		null;

  END LOOP;

-- J: W/V Changes
        IF (p_container_instance_id is not null and l_cont_item_id IS NOT NULL) THEN

            -- LPN CONV. rv
            open  l_get_cnt_org_csr(p_container_instance_id);
            fetch l_get_cnt_org_csr into l_cnt_org_id;

            l_wms_org := 'N';

            IF l_cnt_org_id is NOT NULL THEN
              l_wms_org := wsh_util_validate.check_wms_org(l_cnt_org_id);
            END IF;
            close l_get_cnt_org_csr;

            -- LPN CONV. rv
            IF NOT(
                   l_wms_org = 'Y' AND nvl(wsh_wms_lpn_grp.g_caller,'WSH') like 'WMS%'
                  )
            THEN
            --{
                WSH_WV_UTILS.Check_Fill_Pc (
                  p_container_instance_id => p_container_instance_id,
                  x_fill_status           => l_fill_status,
                  x_return_status         => l_return_status);

                IF l_fill_status = 'O' THEN

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
                    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_OVERPACKED');
                    FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
                    l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                    WSH_UTIL_CORE.Add_Message(l_return_status);
                    x_pack_status := 'Overpacked';

                 ELSIF l_fill_status = 'U' THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
                    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_UNDERPACKED');
                    FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
                    l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                    WSH_UTIL_CORE.Add_Message(l_return_status);
                    x_pack_status := 'Underpacked';
                  ELSE
                    x_pack_status := 'Success';
                  END IF;
            --}
            END IF;
        END IF;

        IF l_num_warnings > 0 THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        ELSE
           x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        END IF;

	--
	IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Unassign_Detail',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Unassign_Detail;

-------------------------------------------------------------------
-- This procedure is only for backward compatibility. No one should call
-- this procedure.
-------------------------------------------------------------------

PROCEDURE Unassign_Detail(
  p_container_instance_id IN NUMBER,
  p_delivery_id IN NUMBER,
  p_del_detail_tab IN WSH_UTIL_CORE.id_tab_type,
  p_cont_unassign IN VARCHAR2,
  p_del_unassign IN VARCHAR2,
  x_pack_status OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2) IS


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UNASSIGN_DETAIL';
--
  l_action_prms   wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;
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
      WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_CONT_UNASSIGN',P_CONT_UNASSIGN);
      WSH_DEBUG_SV.log(l_module_name,'P_DEL_UNASSIGN',P_DEL_UNASSIGN);
  END IF;
  --
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.Unassign_Detail',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  Unassign_Detail
    (
        p_container_instance_id,
        p_delivery_id,
        p_del_detail_tab,
        p_cont_unassign,
        p_del_unassign,
        x_pack_status,
        x_return_status,
        l_action_prms
     );
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION

  WHEN Others THEN
    WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Unassign_Detail',l_module_name);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END Unassign_Detail;
/*
-----------------------------------------------------------------------------
   PROCEDURE  : Assign_To_Delivery
   PARAMETERS : p_container_instance_id - container instance id of container
		p_delivery_id - delivery id
		x_return_status - return status of API
--           x_dlvy_has_lines : 'Y' :delivery has non-container lines.
--                              'N' : delivery does not have non-container lines
--           x_dlvy_freight_Terms_code : Delivery's freight term code
  DESCRIPTION : This procedure checks to see if a container can be assigned to
		the specified delivery and returns a success or failure.
------------------------------------------------------------------------------
*/


PROCEDURE Assign_To_Delivery(
  p_container_instance_id IN NUMBER,
  p_delivery_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
 x_dlvy_has_lines          IN OUT NOCOPY VARCHAR2,    -- J-IB-NPARIKH
 x_dlvy_freight_terms_code IN OUT NOCOPY VARCHAR2     -- J-IB-NPARIKH
  ) IS

-- remove this cursor for Bug
  CURSOR Get_First_Line (v_cont_instance_id NUMBER) IS
  SELECT delivery_detail_id
  FROM wsh_delivery_assignments_v
  WHERE parent_delivery_detail_id = v_cont_instance_id
  AND rownum < 2;
-- remove this cursor for Bug

  CURSOR Get_Cont_Org (v_cont_instance_id NUMBER) IS
  SELECT organization_id
  FROM WSH_DELIVERY_DETAILS
  WHERE delivery_detail_id = v_cont_instance_id
  AND container_flag = 'Y';

  CURSOR Get_Del_Org (v_del_id NUMBER) IS
  SELECT organization_id, freight_terms_code
  FROM WSH_NEW_DELIVERIES
  WHERE delivery_id = v_del_id;

  l_del_detail_id	WSH_DELIVERY_DETAILS.delivery_detail_id%TYPE;

  l_cont_org 	NUMBER;
  l_del_org	NUMBER;

  l_cont_name VARCHAR2(30);
  l_del_name VARCHAR2(30);
  --
  --
  l_has_lines               VARCHAR2(1);
  l_dlvy_freight_terms_code VARCHAR2(30);
  --
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ASSIGN_TO_DELIVERY';
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
      WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
  END IF;
  --
  OPEN Get_Cont_Org (p_container_instance_id);

  FETCH Get_Cont_Org INTO l_cont_org;

  IF Get_Cont_Org%NOTFOUND THEN
     CLOSE Get_Cont_Org;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
     FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
     FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return;
  END IF;

  CLOSE Get_Cont_Org;


  OPEN Get_Del_Org (p_delivery_id);

  FETCH Get_Del_Org INTO l_del_org, l_dlvy_freight_terms_code;

  IF Get_Del_Org%NOTFOUND THEN
     CLOSE Get_Del_Org;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     l_del_name := WSH_NEW_DELIVERIES_PVT.Get_Name(p_delivery_id);
     FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DEL');
     FND_MESSAGE.SET_TOKEN('DEL_NAME',l_del_name);
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return;
  END IF;

  CLOSE Get_Del_Org;


  -- just check for organization id match and create assignment
  IF l_cont_org = l_del_org THEN

	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.CREATE_DELIVERY_ASSIGNMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wsh_container_actions.Create_Delivery_Assignment(
		p_container_instance_id,
		p_delivery_id,
		x_return_status,
		x_dlvy_has_lines,
		x_dlvy_freight_terms_code
		);

       --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
        END IF;
        --

	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
	   --
	   return;
  	END IF;
    ELSE
     	--
     	IF l_debug_on THEN
     	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
     	END IF;
     	--
     	l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        l_del_name := WSH_NEW_DELIVERIES_PVT.Get_Name(p_delivery_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_ASSG_ORG_DIFF');
	FND_MESSAGE.SET_TOKEN('ENTITY1',l_cont_name);
	FND_MESSAGE.SET_TOKEN('ENTITY2',l_del_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
    END IF;


  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Assign_To_Delivery',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Assign_To_Delivery;

-------------------------------------------------------------------
-- This procedure is only for backward compatibility. No one should call
-- this procedure.
-------------------------------------------------------------------

PROCEDURE Assign_To_Delivery(
 p_container_instance_id IN NUMBER,
 p_delivery_id IN NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2
    ) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Assign_To_Delivery';
--
l_has_lines               VARCHAR2(1);
l_dlvy_freight_terms_code VARCHAR2(30);
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
         WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    l_has_lines := WSH_DELIVERY_VALIDATIONS.has_lines
                        (
                            p_delivery_id => p_delivery_id
                        );
    --
    Assign_To_Delivery
        (
            P_CONTAINER_INSTANCE_ID               => P_CONTAINER_INSTANCE_ID,
            p_delivery_id             => p_delivery_id,
            x_dlvy_has_lines               => l_has_lines,
            x_dlvy_freight_Terms_code => l_dlvy_freight_Terms_code,
	    x_return_status => x_return_status
        );
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION
    WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        wsh_util_core.default_handler('WSH_CONTAINER_ACTIONS.Assign_To_Delivery',l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Assign_To_Delivery;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Create_Delivery_Assignment
   PARAMETERS : p_container_instance_id - container instance id of container
		p_delivery_id - delivery id
		x_return_status - return status of API.
--           x_dlvy_has_lines : 'Y' :delivery has non-container lines.
--                              'N' : delivery does not have non-container lines
--           x_dlvy_freight_Terms_code : Delivery's freight term code
  DESCRIPTION : This procedure assigns a container to the specified delivery.
------------------------------------------------------------------------------
*/


PROCEDURE Create_Delivery_Assignment (
 p_container_instance_id IN NUMBER,
 p_delivery_id IN NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2,
 x_dlvy_has_lines          IN OUT NOCOPY VARCHAR2,    -- J-IB-NPARIKH
 x_dlvy_freight_terms_code IN OUT NOCOPY VARCHAR2     -- J-IB-NPARIKH
 ) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DELIVERY_ASSIGNMENT';
--
BEGIN

/* instead of this entire stuff just call assign_detail_to_delivery in whcih call to check container attributes, all validations can be done*/

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
     WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
 END IF;
 --
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_DETAIL_TO_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
 END IF;
 --
 WSH_DELIVERY_DETAILS_ACTIONS.Assign_Detail_to_Delivery(
   P_DETAIL_ID =>p_container_instance_id ,
   P_DELIVERY_ID => p_delivery_id,
   X_RETURN_STATUS =>x_return_status,
   x_dlvy_has_lines               => x_dlvy_has_lines,
   x_dlvy_freight_Terms_code => x_dlvy_freight_Terms_code
 );

   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
   END IF;
 IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	--set proper error message
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
 END IF;
 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
EXCEPTION
  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Create_Delivery_Assignment',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END Create_Delivery_Assignment;

-------------------------------------------------------------------
-- This procedure is only for backward compatibility. No one should call
-- this procedure.
-------------------------------------------------------------------

PROCEDURE Create_Delivery_Assignment(
 p_container_instance_id IN NUMBER,
 p_delivery_id IN NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2
    ) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Delivery_Assignment';
--
l_has_lines               VARCHAR2(1);
l_dlvy_freight_terms_code VARCHAR2(30);
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
         WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
         WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    l_has_lines := WSH_DELIVERY_VALIDATIONS.has_lines
                        (
                            p_delivery_id => p_delivery_id
                        );
    --
    Create_Delivery_Assignment
        (
            P_CONTAINER_INSTANCE_ID               => P_CONTAINER_INSTANCE_ID,
            p_delivery_id             => p_delivery_id,
            X_RETURN_STATUS           => X_RETURN_STATUS,
            x_dlvy_has_lines               => l_has_lines,
            x_dlvy_freight_Terms_code => l_dlvy_freight_Terms_code
        );
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION
    WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        wsh_util_core.default_handler('WSH_CONTAINER_ACTIONS.Create_Delivery_Assignment',l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Create_Delivery_Assignment;


-- THIS IS OBSOLETED
/*
-----------------------------------------------------------------------------
   PROCEDURE  : Unassign_Delivery
   PARAMETERS : p_container_instance_id - container instance id of container
		p_delivery_id - delivery id
		x_return_status - return status of API
  DESCRIPTION : This procedure checks unassigns a container from the specified
		delivery and returns a success or failure.
------------------------------------------------------------------------------
*/
--THIS PROCEDURE IS OBSOLETE
PROCEDURE Unassign_Delivery(
  p_container_instance_id IN NUMBER,
  p_delivery_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2) IS

BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

END Unassign_Delivery;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Assign_To_Container
   PARAMETERS : p_det_cont_inst_id - container instance id of child container
		p_par_cont_inst_id - container instance id of parent container
		x_return_status - return status of API
  DESCRIPTION : This procedure checks to see if a container can be assigned to
		a specified parent container and returns a success or failure.
------------------------------------------------------------------------------
*/


PROCEDURE Assign_To_Container(
  p_det_cont_inst_id IN NUMBER,
  p_par_cont_inst_id IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2) IS

-- remove this cursor
  CURSOR Get_First_Line (v_cont_instance_id NUMBER) IS
  SELECT delivery_detail_id
  FROM wsh_delivery_assignments_v
  WHERE parent_delivery_detail_id = v_cont_instance_id
  AND rownum < 2;
-- remove this cursor

  CURSOR Get_Cont_Org (v_cont_instance_id NUMBER) IS
  SELECT organization_id
  FROM WSH_DELIVERY_DETAILS
  WHERE delivery_detail_id = v_cont_instance_id
  AND container_flag in ('Y', 'C');

  l_det_detail_id	WSH_DELIVERY_DETAILS.delivery_detail_id%TYPE;
  l_par_detail_id	WSH_DELIVERY_DETAILS.delivery_detail_id%TYPE;

  l_det_cont_org 	NUMBER;
  l_par_cont_org	NUMBER;

  l_temp_detail_tab WSH_UTIL_CORE.id_tab_type;

  cnt 			NUMBER;
  l_del_rows		WSH_UTIL_CORE.id_tab_type;
  l_group_id_tab	WSH_UTIL_CORE.id_tab_type;
  l_ret_sts 		VARCHAR2(1);

  l_cont_name VARCHAR2(30);

  l_master_serial_number VARCHAR2(30);
  l_master_cont_id	NUMBER;
  l_master_cont_name    VARCHAR2(30);

  l_det_attr_flag VARCHAR2(1);
  l_par_attr_flag VARCHAR2(1);

  l_det_del_id NUMBER;
  l_par_del_id NUMBER;
  l_del_status VARCHAR2(10);

  l_attr_tab  wsh_delivery_autocreate.grp_attr_tab_type;
  l_group_tab  wsh_delivery_autocreate.grp_attr_tab_type;
  l_action_rec wsh_delivery_autocreate.action_rec_type;
  l_target_rec wsh_delivery_autocreate.grp_attr_rec_type;
  l_matched_entities wsh_util_core.id_tab_type;
  l_out_rec wsh_delivery_autocreate.out_rec_type;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ASSIGN_TO_CONTAINER';
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
      WSH_DEBUG_SV.log(l_module_name,'P_DET_CONT_INST_ID',P_DET_CONT_INST_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PAR_CONT_INST_ID',P_PAR_CONT_INST_ID);
  END IF;
  --
  OPEN Get_Cont_Org (p_det_cont_inst_id);

  FETCH Get_Cont_Org INTO l_det_cont_org;

  IF Get_Cont_Org%NOTFOUND THEN
     CLOSE Get_Cont_Org;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_det_cont_inst_id);
     FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
     FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return;
  END IF;

  IF Get_Cont_Org%ISOPEN THEN
  	CLOSE Get_Cont_Org;
  END IF;

  OPEN Get_Cont_Org (p_par_cont_inst_id);

  FETCH Get_Cont_Org INTO l_par_cont_org;

  IF Get_Cont_Org%NOTFOUND THEN
     CLOSE Get_Cont_Org;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_par_cont_inst_id);
     FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
     FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return;
  END IF;

  IF Get_Cont_Org%ISOPEN THEN
  	CLOSE Get_Cont_Org;
  END IF;

  IF l_det_cont_org <> l_par_cont_org THEN
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_det_cont_inst_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_ASSG_ORG_DIFF');
	FND_MESSAGE.SET_TOKEN('ENTITY1',l_cont_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_par_cont_inst_id);
	FND_MESSAGE.SET_TOKEN('ENTITY2',l_cont_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;

  -- get the delivery status of the container and check if it is assigned
  -- to a closed or in-transit delivery (only open deliveries allowed)

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_DELIVERY_STATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_CONTAINER_UTILITIES.Get_Delivery_Status ( p_par_cont_inst_id,
						l_par_del_id,
						l_del_status,
						x_return_status);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
  END IF;
  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;

  IF (nvl(l_par_del_id,-99) <> -99) THEN

	-- TPW - Distributed Organization Changes
        IF (nvl(l_del_status,'N/A') NOT IN  ('OP','SA')) THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DEL_STS_INVALID');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
	END IF;
  END IF;

  -- get the delivery status of the container and check if it is assigned
  -- to a closed or in-transit delivery (only open deliveries allowed)

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_DELIVERY_STATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_CONTAINER_UTILITIES.Get_Delivery_Status ( p_det_cont_inst_id,
						l_det_del_id,
						l_del_status,
						x_return_status);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
  END IF;
  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;

  IF (nvl(l_det_del_id,-99) <> -99) THEN

	IF (nvl(l_del_status,'N/A') <> 'OP') THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DEL_STS_INVALID');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
	END IF;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_det_del_id',l_det_del_id);
    WSH_DEBUG_SV.log(l_module_name,'l_par_del_id',l_par_del_id);
  END IF;

  IF ((nvl(l_det_del_id,-99) <> -99) AND (nvl(l_par_del_id,-99) <> -99)) THEN

  	IF l_det_del_id <> l_par_del_id THEN


            -- R12: MDC: For WMS we can assign containers to parent containers on different deliveries.
            IF wsh_util_validate.check_wms_org(l_par_cont_org) = 'Y' THEN

	       IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Assign_Container_to_Consol',WSH_DEBUG_SV.C_PROC_LEVEL);
	       END IF;
               Assign_Container_to_Consol(
                 p_child_container_id   => p_det_cont_inst_id,
                 p_parent_container_id  => p_par_cont_inst_id,
                 p_caller               => 'WMS_PACK_CONSOL',
                 x_return_status        => x_return_status);

               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'return status -',x_return_status);
               END IF;

	       return;
            ELSE


		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_det_cont_inst_id);
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_ASSG_DEL_DIFF');
		FND_MESSAGE.SET_TOKEN('ENTITY1',l_cont_name);
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_par_cont_inst_id);
		FND_MESSAGE.SET_TOKEN('ENTITY2',l_cont_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   		WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;

            END IF;

  	END IF;
   END IF;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_MASTER_CONT_SERIAL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_CONTAINER_UTILITIES.Get_Master_Cont_Serial (
				p_par_cont_inst_id,
				l_master_cont_id,
				l_master_cont_name,
				l_master_serial_number,
				x_return_status);
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
  END IF;

  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	--dbms_output.put_line('error while getting master serial for parent ' || p_par_cont_inst_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_GET_MASTER_ERROR');
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_par_cont_inst_id);
	FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
	WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
	IF l_ret_sts <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
	   l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
	l_master_cont_id := NULL;
	l_master_serial_number := NULL;
  END IF;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.CHECK_CONT_ATTRIBUTES',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_container_actions.Check_Cont_Attributes (
				p_det_cont_inst_id,
				l_det_attr_flag,
				x_return_status);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
  END IF;

  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_ATTR_ERROR');
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;


  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.CHECK_CONT_ATTRIBUTES',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_container_actions.Check_Cont_Attributes (
				p_par_cont_inst_id,
				l_par_attr_flag,
				x_return_status);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
  END IF;

  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_ATTR_ERROR');
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;

  IF l_det_attr_flag = 'N' AND l_par_attr_flag = 'N' THEN

--dbms_output.put_line('creating assignment of cont ' || p_det_cont_inst_id || ' to container ' || p_par_cont_inst_id);
    	-- just create assignment of child container to parent.
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_CONT_TO_CONT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_DELIVERY_DETAILS_ACTIONS.Assign_Cont_To_Cont (
			p_det_cont_inst_id,
			p_par_cont_inst_id,
			x_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
        END IF;

    	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
    	END IF;

--	l_master_cont_id := WSH_CONTAINER_UTILITIES.Get_Master_Cont_Id (p_det_cont_inst_id);


	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.UPDATE_CHILD_CONTAINERS',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_CONTAINER_UTILITIES.Update_Child_Containers (
					p_det_cont_inst_id,
					l_master_cont_id,
					l_master_serial_number,
					x_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
        END IF;

    	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_det_cont_inst_id);
     		FND_MESSAGE.SET_NAME('WSH', 'WSH_CONT_CHILD_UPD_ERROR');
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
    	END IF;

   ELSIF l_det_attr_flag = 'N' AND l_par_attr_flag = 'Y' THEN

--dbms_output.put_line('creating assignment of cont ' || p_det_cont_inst_id || ' to container ' || p_par_cont_inst_id);

    	-- just create assignment of child container to parent.
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_CONT_TO_CONT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_DELIVERY_DETAILS_ACTIONS.Assign_Cont_To_Cont (
			p_det_cont_inst_id,
			p_par_cont_inst_id,
			x_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
        END IF;
    	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
    	END IF;

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.UPDATE_CONT_HIERARCHY',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_container_actions.Update_Cont_Hierarchy (
					p_par_cont_inst_id,
					l_det_del_id,
					p_det_cont_inst_id,
					x_return_status );
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
        END IF;

	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_GRP_ATTR_WARN');
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_det_cont_inst_id);
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
		l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
		WSH_UTIL_CORE.Add_Message(l_ret_sts,l_module_name);
	END IF;

	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.UPDATE_CHILD_CONTAINERS',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_CONTAINER_UTILITIES.Update_Child_Containers (
					p_det_cont_inst_id,
					l_master_cont_id,
					l_master_serial_number,
					x_return_status);
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
        END IF;

    	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_det_cont_inst_id);
     		FND_MESSAGE.SET_NAME('WSH', 'WSH_CONT_CHILD_UPD_ERROR');
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
    	END IF;

   ELSIF l_det_attr_flag = 'Y' and l_par_attr_flag = 'N' THEN

--dbms_output.put_line('creating assignment of cont ' || p_det_cont_inst_id || ' to container ' || p_par_cont_inst_id);

    	-- just create assignment of child container to parent.
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_CONT_TO_CONT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_DELIVERY_DETAILS_ACTIONS.Assign_Cont_To_Cont (
			p_det_cont_inst_id,
			p_par_cont_inst_id,
			x_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
        END IF;
    	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		--dbms_output.put_line('cont not assigned');
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
    	END IF;

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.UPDATE_CONT_HIERARCHY',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_container_actions.Update_Cont_Hierarchy (
				p_det_cont_inst_id,
				l_par_del_id,
				p_par_cont_inst_id,
				x_return_status );

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
        END IF;
	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_GRP_ATTR_WARN');
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_det_cont_inst_id);
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
		l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
		WSH_UTIL_CORE.Add_Message(l_ret_sts,l_module_name);
	END IF;

	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.UPDATE_CHILD_CONTAINERS',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_CONTAINER_UTILITIES.Update_Child_Containers (
					p_det_cont_inst_id,
					l_master_cont_id,
					l_master_serial_number,
					x_return_status);
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
        END IF;

    	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_det_cont_inst_id);
     		FND_MESSAGE.SET_NAME('WSH', 'WSH_CONT_CHILD_UPD_ERROR');
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
    	END IF;

   ELSIF l_det_attr_flag = 'Y' and l_par_attr_flag = 'Y' THEN

--dbms_output.put_line('creating assignment of cont ' || p_det_cont_inst_id || ' to container ' || p_par_cont_inst_id);

	-- check on using the container instance ids for grouping
	-- attribute comparisons instead of using the lines.

	l_attr_tab(1).entity_id := p_det_cont_inst_id;
	l_attr_tab(1).entity_type := 'DELIVERY_DETAIL';
	l_attr_tab(2).entity_id := p_par_cont_inst_id;
	l_attr_tab(2).entity_type := 'DELIVERY_DETAIL';

	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.AUTOCREATE_DELIVERIES',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

      l_action_rec.action := 'MATCH_GROUPS';
      l_action_rec.check_single_grp := 'Y';


      WSH_DELIVERY_AUTOCREATE.Find_Matching_Groups(p_attr_tab => l_attr_tab,
                        p_action_rec => l_action_rec,
                        p_target_rec => l_target_rec,
                        p_group_tab => l_group_tab,
                        x_matched_entities => l_matched_entities,
                        x_out_rec => l_out_rec,
                        x_return_status => x_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
        END IF;
	IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
        OR  NVL(l_out_rec.single_group, 'N') = 'N') THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_GROUP_DETAILS_ERROR');
       		WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
	END IF;

--dbms_output.put_line('creating assignment of cont ' || p_det_cont_inst_id || ' to container ' || p_par_cont_inst_id);

	    -- create assignment between child and parent container
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_CONT_TO_CONT',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_DELIVERY_DETAILS_ACTIONS.Assign_Cont_To_Cont (
		p_det_cont_inst_id,
		p_par_cont_inst_id,
		x_return_status);

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
            END IF;
	    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		l_ret_sts := x_return_status;
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
	    END IF;

	    -- call update cont attributes to update grouping attr.
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.UPDATE_CHILD_CONTAINERS',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    WSH_CONTAINER_UTILITIES.Update_Child_Containers (
					p_det_cont_inst_id,
					l_master_cont_id,
					l_master_serial_number,
					x_return_status);
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
            END IF;

    	    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_det_cont_inst_id);
     		FND_MESSAGE.SET_NAME('WSH', 'WSH_CONT_CHILD_UPD_ERROR');
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
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
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Assign_To_Container',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Assign_To_Container;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Get_Cont_Load_Vol_info
   PARAMETERS : p_container_item_id - Item Id of the Container
                p_organization_id - Organization Id of the item
                p_w_v_both - W (Find Weight), V (Find Volume),
                             B (Find Weight and Volume)
                x_return_status - Return Status of the API
                x_error_cnt     - Count of errors encountered
                x_max_load      - Max Load Weight of the container
                x_max_vol       - Internal Volume of the container
                x_wt_uom        - Weight UOM of the container
                x_vol_uom       - Volume UOM of the container
  DESCRIPTION : This procedure finds Container Weight/Volume attributes
                either from database or from cached PL/SQL table and caches
                the info if fetched from database.
------------------------------------------------------------------------------
*/

PROCEDURE  Get_Cont_Load_Vol_info(
             p_container_item_id IN  NUMBER,
             p_organization_id   IN  NUMBER,
             p_w_v_both          IN  VARCHAR2,
             x_max_load          OUT NOCOPY  NUMBER,
             x_max_vol           OUT NOCOPY  NUMBER,
             x_wt_uom            OUT NOCOPY  VARCHAR2,
             x_vol_uom           OUT NOCOPY  VARCHAR2,
          --   x_inventory_item_status_code OUT VARCHAR2,
             x_return_status     OUT NOCOPY  VARCHAR2,
             x_error_cnt         OUT NOCOPY  NUMBER) IS
-- in this cursor we can add filters as required in 2428050
  CURSOR Get_Cont_Msi (v_cont_item_id NUMBER, v_org_id NUMBER) IS
  SELECT maximum_load_weight, internal_volume,
         weight_uom_code, volume_uom_code
  FROM   MTL_SYSTEM_ITEMS
  WHERE  inventory_item_id = v_cont_item_id
  AND    organization_id   = v_org_id
-- bug 2828591 - remove the condition since it will prevent user to create container with other status
--  AND    inventory_item_status_code = 'Active'
  AND    container_item_flag = 'Y'
  AND    nvl(vehicle_item_flag,'N') = 'N'
  AND    shippable_item_flag = 'Y' ;

  l_mtl_max_load NUMBER;
  l_mtl_max_vol  NUMBER;
  l_mtl_wt_uom   VARCHAR2(3);
  l_mtl_vol_uom  VARCHAR2(3);
  l_inv_item_status_code VARCHAR2(10);
  l_flag VARCHAR2(1);
  l_item_name    VARCHAR2(2000);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CONT_LOAD_VOL_INFO';
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
      WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_ITEM_ID',P_CONTAINER_ITEM_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_W_V_BOTH',P_W_V_BOTH);
  END IF;
  --
  x_error_cnt := 0;
  x_return_status := C_SUCCESS_STATUS;
  --dbms_output.put_line('Get_Cont_Load_Vol_info: p_container_item_id '||p_container_item_id||' p_w_v_both '||p_w_v_both);
  IF ((g_cont_msi_tab.COUNT > 0) AND (g_cont_msi_tab.EXISTS(p_container_item_id))) THEN

-- added for valid flag in PL SQL table
    IF g_cont_msi_tab(p_container_item_id).valid_flag = 'Y' THEN
      NULL;
    ELSE
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ITEM_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_item_name := WSH_UTIL_CORE.Get_Item_Name(p_container_item_id, p_organization_id);
      --dbms_output.put_line('Container '||p_container_item_id||' not found in Org '||p_organization_id);
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_INV_ITEM');
      FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
      CLOSE Get_Cont_Msi;
      WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
      x_return_status := C_ERROR_STATUS;
      x_error_cnt := x_error_cnt + 1;

    END IF;
-- end of for valid flag

     --dbms_output.put_line('Using Cached Cont/Msi Info');
  ELSE
    l_mtl_max_load := NULL;
    l_mtl_max_vol  := NULL;
    l_mtl_wt_uom   := NULL;
    l_mtl_vol_uom  := NULL;

    l_flag := 'Y';

    OPEN Get_Cont_Msi(p_container_item_id, p_organization_id);
    FETCH Get_Cont_Msi
    INTO  l_mtl_max_load,
          l_mtl_max_vol,
          l_mtl_wt_uom,
          l_mtl_vol_uom;

    IF Get_Cont_Msi%NOTFOUND THEN
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ITEM_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_item_name := WSH_UTIL_CORE.Get_Item_Name(p_container_item_id, p_organization_id);
      --dbms_output.put_line('Container '||p_container_item_id||' not found in Org '||p_organization_id);
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_INV_ITEM');
      FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
      CLOSE Get_Cont_Msi;
      WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
      x_return_status := C_ERROR_STATUS;
      x_error_cnt := x_error_cnt + 1;
    ELSE

    --dbms_output.put_line('IN ELSE CLAUSE'||l_flag);
      CLOSE Get_Cont_Msi;


      IF ((NVL(l_mtl_max_load,0) <= 0) AND (p_w_v_both in ('W','B'))) THEN
        --dbms_output.put_line('Preferred Container Weight is <= 0');
        FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_LOAD_ERROR');
        WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
        x_return_status := C_ERROR_STATUS;
        x_error_cnt := x_error_cnt + 1;
        l_flag := 'N';
      END IF;

      IF ((NVL(l_mtl_max_vol,0) <= 0) AND (p_w_v_both in ('V','B'))) THEN
        --dbms_output.put_line('Preferred Container Volume is <= 0');
        FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_VOL_ERROR');
        WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
        x_return_status := C_ERROR_STATUS;
        x_error_cnt := x_error_cnt + 1;
        l_flag := 'N';
      END IF;

      IF (l_flag IS NULL OR l_flag <> 'N') THEN
        l_flag := 'Y';
      END IF;

    END IF;

    --dbms_output.put_line('Caching Cont/Msi Info'||l_flag);
    g_cont_msi_tab(p_container_item_id).mtl_max_load := l_mtl_max_load;
    g_cont_msi_tab(p_container_item_id).mtl_max_vol  := l_mtl_max_vol;
    g_cont_msi_tab(p_container_item_id).mtl_wt_uom   := l_mtl_wt_uom;
    g_cont_msi_tab(p_container_item_id).mtl_vol_uom  := l_mtl_vol_uom;
    g_cont_msi_tab(p_container_item_id).valid_flag  := l_flag;
  END IF;

  x_max_load := g_cont_msi_tab(p_container_item_id).mtl_max_load;
  x_max_vol  := g_cont_msi_tab(p_container_item_id).mtl_max_vol;
  x_wt_uom   := g_cont_msi_tab(p_container_item_id).mtl_wt_uom;
  x_vol_uom  := g_cont_msi_tab(p_container_item_id).mtl_vol_uom;
  --x_inventory_item_status_code  := g_cont_msi_tab(p_container_item_id).inventory_item_status_code;
  --dbms_output.put_line('WSH_CONTAINER_ACTIONS.Get_Cont_Load_Vol_info returned '||x_return_status||' with error count '||x_error_cnt);

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'MAX LOAD',x_max_load);
      WSH_DEBUG_SV.log(l_module_name,'MAX VOLUME',x_max_vol);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN;

EXCEPTION
  WHEN Others THEN
    IF (Get_Cont_Msi%ISOPEN) THEN
      CLOSE Get_Cont_Msi;
    END IF;
    WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Get_Cont_Load_Vol_info',l_module_name);
        x_return_status := C_UNEXP_ERROR_STATUS;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END  Get_Cont_Load_Vol_info;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Calc_Fill_Basis_and_Proc_Flag
   PARAMETERS : p_organization_id - Organization Id for which Fill Basis and
                                    Process Flag is to be determined
                x_return_status - Return Status of the API
                x_error_cnt     - Count of errors encountered
                x_fill_basis    - Fill Basis for the organization
                x_process_flag  - Discrete/Process Organization
  DESCRIPTION : This procedure finds Fill Basis for organization and determines
                whether organization uses Process or Discrete Manufacturing
                either from database or from cached PL/SQL table and caches
                the info if fetched from database.
------------------------------------------------------------------------------
*/

PROCEDURE Calc_Fill_Basis_and_Proc_Flag(
            p_organization_id IN  NUMBER,
            x_return_status   OUT NOCOPY  VARCHAR2,
            x_fill_basis      OUT NOCOPY  VARCHAR2,
            x_process_flag    OUT NOCOPY  VARCHAR2) IS

  l_param_info  WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALC_FILL_BASIS_AND_PROC_FLAG';
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
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
  END IF;
  --
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.GET',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_SHIPPING_PARAMS_PVT.Get(
    p_organization_id => p_organization_id,
    x_param_info      => l_param_info,
    x_return_status   => x_return_status);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'return status - ',x_return_status);
  END IF;
  IF (x_return_status = C_SUCCESS_STATUS) THEN
    x_fill_basis   := l_param_info.percent_fill_basis_flag;
-- HW OPMCONV - No need to populate this value
--  x_process_flag := l_param_info.process_flag;
  END IF;

  --dbms_output.put_line('WSH_CONTAINER_ACTIONS.Calc_Fill_Basis_and_proc_flag returned '||x_return_status);

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN Others THEN
    WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Calc_Fill_Basis_and_proc_flag',l_module_name);
    x_return_status := C_UNEXP_ERROR_STATUS;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END  Calc_Fill_Basis_and_proc_flag;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Calc_Pref_Container
   PARAMETERS : p_organization_id - Organization Id of the Item for which
                                    Preferred Container is to be determined
                p_inventory_item_id - Item for which Preferred Container is to
                                      be determined
                p_fill_pc_basis - Fill Basis for the organization
                x_return_status - Return Status of the API
                x_error_cnt     - Count of errors encountered
                x_cont_item_id  - Preferred Container Item Id
                x_max_load_qty  - Max Load Qty of the Preferred Container
  DESCRIPTION : This procedure finds preferred container for item-organization
                combination either from database or from cached PL/SQL table
                and caches the info if fetched from database.
                This procedure also finds and caches the Max Load qty a
                preferred container can hold if fill basis is Quantity.
------------------------------------------------------------------------------
*/

PROCEDURE Calc_Pref_Container(
            p_organization_id   IN  NUMBER,
            p_inventory_item_id IN  NUMBER,
            p_fill_pc_basis     IN  VARCHAR2,
            x_return_status     OUT NOCOPY  VARCHAR2,
            x_error_cnt         OUT NOCOPY  NUMBER,
            x_cont_item_id      OUT NOCOPY  NUMBER,
            x_max_load_qty      OUT NOCOPY  NUMBER) IS

  CURSOR Get_Cont_Load (v_inv_item_id NUMBER, v_organization_id NUMBER) IS
  SELECT container_item_id,
         max_load_quantity
  FROM   WSH_CONTAINER_ITEMS
  WHERE  load_item_id           = v_inv_item_id
  AND    master_organization_id = v_organization_id
  AND    preferred_flag         = 'Y';

  l_wcl_cont_item_id NUMBER;
  l_max_load_qty     NUMBER;
  l_item_name VARCHAR2(2000);
  l_org_name VARCHAR2(240);


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALC_PREF_CONTAINER';
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
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_FILL_PC_BASIS',P_FILL_PC_BASIS);
  END IF;
  --
  x_error_cnt := 0;
  x_return_status := C_SUCCESS_STATUS;

  IF ((g_cache_cont_load_info_tab.COUNT > 0) AND (g_cache_cont_load_info_tab.EXISTS(p_inventory_item_id))) THEN
    NULL;
    --dbms_output.put_line('Using Cached Cont/Load info');
  ELSE
    l_wcl_cont_item_id := NULL;
    l_max_load_qty     := NULL;

    OPEN Get_Cont_Load (p_inventory_item_id, p_organization_id);

    FETCH Get_Cont_Load
    INTO  l_wcl_cont_item_id,
          l_max_load_qty;

    IF Get_Cont_Load%NOTFOUND THEN
      CLOSE Get_Cont_Load;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ITEM_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_item_name := WSH_UTIL_CORE.Get_Item_Name(p_inventory_item_id, p_organization_id);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      l_org_name := WSH_UTIL_CORE.Get_Org_Name(p_organization_id);
      --dbms_output.put_line('Error: Cont/Load Relationship does not exist for Item '||l_item_name||' Org '||l_org_name);
      --dbms_output.put_line('p_inventory_item_id '||p_inventory_item_id||' p_organization_id '||p_organization_id);
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONT_LOAD');
      FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
      FND_MESSAGE.SET_TOKEN('ORG_NAME',l_org_name);
      WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
      x_return_status := C_ERROR_STATUS;
      x_error_cnt := x_error_cnt + 1;
    ELSE
      CLOSE Get_Cont_Load;
      IF ((l_max_load_qty = 0) AND (p_fill_pc_basis = 'Q')) THEN
        --dbms_output.put_line('Error: Max Load qty for Preferred Container is 0');
        FND_MESSAGE.SET_NAME('WSH','WSH_CONT_LOAD_QTY_ERROR');
        WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
        x_error_cnt := x_error_cnt + 1;
        x_return_status := C_ERROR_STATUS;
        l_wcl_cont_item_id := NULL;
      END IF;
    END IF;

    g_cache_cont_load_info_tab(p_inventory_item_id).cont_item_id := l_wcl_cont_item_id;
    g_cache_cont_load_info_tab(p_inventory_item_id).max_load_qty := l_max_load_qty;
    --dbms_output.put_line('Caching Cont/Load info');
  END IF;
  x_cont_item_id :=  g_cache_cont_load_info_tab(p_inventory_item_id).cont_item_id;
  x_max_load_qty :=  g_cache_cont_load_info_tab(p_inventory_item_id).max_load_qty;
  --dbms_output.put_line('WSH_CONTAINER_ACTIONS.Calc_Pref_Container returned '||x_return_status||' with error count '||x_error_cnt);

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN Others THEN
    IF (Get_Cont_Load%ISOPEN) THEN
      CLOSE Get_Cont_Load;
    END IF;
    WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Calc_Pref_Container',l_module_name);
    x_return_status := C_UNEXP_ERROR_STATUS;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Calc_Pref_Container;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Pack_Delivery_Detail
   PARAMETERS : p_line_cont_rec - Dd info which needs to be autopacked
                x_return_status - Return Status of the API
  DESCRIPTION : This procedure packs a delivery detail into Container either
                by creating a new one or by packing it into one created for
                previous delivery details (created in the same run)
------------------------------------------------------------------------------
*/

PROCEDURE Pack_Delivery_Detail(
  p_line_cont_rec IN  wsh_container_actions.line_cont_info,
  x_return_status OUT NOCOPY  VARCHAR2) IS

  l_mtl_max_load          NUMBER;
  l_mtl_max_vol           NUMBER;
  l_item_name             VARCHAR2(2000);
  l_weight_per_pc         NUMBER;
  l_volume_per_pc         NUMBER;
  l_volume_per_pc2        NUMBER;
  l_equal_distribution    BOOLEAN;
  l_wt_left               NUMBER;
  l_vol_left              NUMBER;
  l_original_qty          NUMBER;
  l_quantity_left              NUMBER;
  l_tmp_split_qty         NUMBER;
  l_tmp_split_qty2        NUMBER;
  l_split_qty             NUMBER;
  l_split_qty2            NUMBER;
  l_split_del_detail_id   NUMBER;
  l_return_status VARCHAR2(1) := C_SUCCESS_STATUS;
  l_output_qty            NUMBER;
  l_discard_message     VARCHAR2(2000);
  l_max_load_qty        NUMBER;
  l_tot_gross_wt NUMBER;
  l_tot_net_wt NUMBER;
  l_tot_vol NUMBER;
  l_dd_wt_per_pc  NUMBER;
  l_dd_gross_wt_left    NUMBER;
  l_dd_net_wt_left    NUMBER;
  l_dd_vol_per_pc NUMBER;
  l_dd_vol_left   NUMBER;

  i NUMBER;
  j NUMBER;
  gcdvalue NUMBER;

  l_count_container NUMBER;
  l_container_item_id NUMBER;
  l_container_org_id NUMBER;
  l_num_of_split     NUMBER;
  l_dd_id_tab        WSH_UTIL_CORE.id_tab_type;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PACK_DELIVERY_DETAIL';
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
    WSH_DEBUG_SV.log(l_module_name,'In Pack_Delivery_Detail API, Packing wdd '||p_line_cont_rec.delivery_detail_id||' div flag '||p_line_cont_rec.indivisible_flag||' Process Flag '||p_line_cont_rec.process_flag);
    WSH_DEBUG_SV.log(l_module_name,'Fill Pc Basis '||p_line_cont_rec.fill_pc_basis||' G Wt '||p_line_cont_rec.gross_weight||' N Wt '||p_line_cont_rec.net_weight||' Vol '||p_line_cont_rec.volume );
  END IF;
  --
  l_dd_gross_wt_left := ROUND(p_line_cont_rec.gross_weight,LIMITED_PRECISION);
  l_dd_net_wt_left   := ROUND(p_line_cont_rec.net_weight,LIMITED_PRECISION);
  l_dd_vol_left      := ROUND(p_line_cont_rec.volume,LIMITED_PRECISION);

  IF (p_line_cont_rec.fill_pc_basis = 'Q') THEN
     l_max_load_qty := p_line_cont_rec.max_load_qty;
     --dbms_output.put_line('Max Load qty is '||p_line_cont_rec.max_load_qty);
  ELSIF (p_line_cont_rec.fill_pc_basis = 'W') THEN

    l_mtl_max_load := p_line_cont_rec.cont_wt;

    -- Calculate Wt per Piece. We pack based on converted Container UOM weight
    l_weight_per_pc  := TRUNC(p_line_cont_rec.converted_wt/p_line_cont_rec.shp_qty,LIMITED_PRECISION);
    l_wt_left       := p_line_cont_rec.converted_wt;
-- Bug 2786021
    IF (nvl(l_mtl_max_load,0) = 0 OR nvl(l_weight_per_pc,0) = 0)THEN
      x_return_status := C_ERROR_STATUS;
      IF nvl(l_mtl_max_load,0) = 0 THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_LOAD_ERROR');
      ELSIF nvl(l_weight_per_pc,0) = 0 THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_NULL_WEIGHT_VOLUME');
        FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL',p_line_cont_rec.delivery_detail_id);
      END IF;
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;
-- Bug 2786021

  ELSE
    l_mtl_max_vol := p_line_cont_rec.cont_vol;

    -- Calculate Vol per Piece. We pack based on converted Container UOM volume
    l_volume_per_pc  := TRUNC(p_line_cont_rec.converted_vol/p_line_cont_rec.shp_qty,LIMITED_PRECISION);
    l_vol_left       := p_line_cont_rec.converted_vol;
-- Bug 2786021
    IF (nvl(l_mtl_max_vol,0) = 0 OR nvl(l_volume_per_pc,0) = 0) THEN
      x_return_status := C_ERROR_STATUS;
      IF nvl(l_mtl_max_vol,0) = 0 THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_VOL_ERROR');
      ELSIF nvl(l_volume_per_pc,0) = 0 THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_NULL_WEIGHT_VOLUME');
        FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL',p_line_cont_rec.delivery_detail_id);
      END IF;
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;
-- Bug 2786021
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Wt per pc-',l_weight_per_pc);
    WSH_DEBUG_SV.log(l_module_name,'Vol per pc-',l_volume_per_pc);
    WSH_DEBUG_SV.log(l_module_name,'Cont max load-',l_mtl_max_load);
    WSH_DEBUG_SV.log(l_module_name,'Cont max vol-',l_mtl_max_vol);
  END IF;

  l_original_qty  := p_line_cont_rec.shp_qty;
  l_quantity_left := p_line_cont_rec.shp_qty;

  -- Check Empty Containers first
  IF (g_empty_cont_tab.COUNT > 0 ) THEN
--dbms_output.put_line('There are containers with empty space'||to_char(sysdate,'HH24:MI:SS'));

    i := g_empty_cont_tab.FIRST;
    WHILE i <= g_empty_cont_tab.LAST LOOP
      IF p_line_cont_rec.preferred_container <> g_empty_cont_tab(i).container_item_Id OR
         p_line_cont_rec.organization_id <> g_empty_cont_tab(i).organization_id OR
         p_line_cont_rec.group_id <> g_empty_cont_tab(i).group_id  OR
         (NVL(p_line_cont_rec.master_cont_item_id,NVL(g_empty_cont_tab(i).mast_cont_item_id,-99)) <> NVL(g_empty_cont_tab(i).mast_cont_item_id,-99)) OR
         g_empty_cont_tab(i).empty <= 0 THEN
        GOTO next_cont;
      END IF;

      -- Got a Match in empty container table

      IF (p_line_cont_rec.fill_pc_basis = 'Q') THEN
        --dbms_output.put_line('Found Container '||g_empty_cont_tab(i).container_index||' with empty numerator '||g_empty_cont_tab(i).numerator||' denominator '||g_empty_cont_tab(i).denominator);
        -- Calculate qty than can fit in 'empty' space
        -- Bug 2733274
        l_tmp_split_qty  := TRUNC((p_line_cont_rec.max_load_qty*g_empty_cont_tab(i).numerator)/g_empty_cont_tab(i).denominator,LIMITED_PRECISION);

      ELSIF (p_line_cont_rec.fill_pc_basis = 'W') THEN
        --dbms_output.put_line('Found Container '||g_empty_cont_tab(i).container_index||' with empty weight '||g_empty_cont_tab(i).empty);
        -- Calculate qty than can fit in 'empty' space
        l_tmp_split_qty := TRUNC(g_empty_cont_tab(i).empty/l_weight_per_pc,LIMITED_PRECISION);
      ELSE
        --dbms_output.put_line('Found Container '||g_empty_cont_tab(i).container_index||' with empty volume '||g_empty_cont_tab(i).empty);
        -- Calculate qty than can fit in 'empty' space
        l_tmp_split_qty := TRUNC(g_empty_cont_tab(i).empty/l_volume_per_pc,LIMITED_PRECISION);
      END IF;
      -- l_tmp_split_qty is qty, in fraction, that can fit into empty container
      --dbms_output.put_line('l_tmp_split_qty '||l_tmp_split_qty||' l_tmp_split_qty2 '||l_tmp_split_qty2);

      -- Per Pushkar,OPM: Call Check_Decimal_Quantity for both OPM and Discrete for primary quantity
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_DECIMAL_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_DETAILS_VALIDATIONS.Check_Decimal_Quantity (
           p_line_cont_rec.inventory_item_id,
           p_line_cont_rec.organization_id,
           l_tmp_split_qty,
           p_line_cont_rec.req_qty_uom,
           l_output_qty,
           l_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
      END IF;
      IF (l_return_status <> C_SUCCESS_STATUS OR
          p_line_cont_rec.indivisible_flag = 'Y')THEN
        -- Fractional qtys not allowed
        --dbms_output.put_line('WSH_DETAILS_VALIDATIONS.Check_Decimal_Quantity returned '||l_return_status);
        l_discard_message := FND_MESSAGE.GET;
        l_tmp_split_qty  := FLOOR(l_tmp_split_qty);
      END IF;
-- HW OPMCONV - 1) No need to check for process
--            - 2) Changed code to handle qty2
--            - 3) Remove OPM specific precision to 9

      IF ( p_line_cont_rec.shp_qty2 IS NOT NULL ) THEN
        l_tmp_split_qty2 := (l_tmp_split_qty * p_line_cont_rec.shp_qty2)/p_line_cont_rec.shp_qty;
      ELSE
        l_tmp_split_qty2 := NULL;
      END IF;
      --dbms_output.put_line('l_tmp_split_qty '||l_tmp_split_qty||' l_tmp_split_qty2 '||l_tmp_split_qty2||' l_quantity_left '||l_quantity_left);

      IF (l_tmp_split_qty <= 0) THEN
        -- Container insufficient, skip this
        --dbms_output.put_line('Container Insufficient. Skipping this');
        GOTO next_cont;
      ELSE
        IF (l_tmp_split_qty >= l_quantity_left) THEN
          -- all left can be packed into the empty container
          l_tmp_split_qty := l_quantity_left;
          l_quantity_left := 0;

          -- Assign the dd to container
          g_assign_detail_index := g_assign_detail_index + 1;
          g_assign_detail_tab(g_assign_detail_index).delivery_detail_id := p_line_cont_rec.delivery_detail_id;
          g_assign_detail_tab(g_assign_detail_index).delivery_id := p_line_cont_rec.delivery_id;
          g_assign_detail_tab(g_assign_detail_index).container_index := g_empty_cont_tab(i).container_index;
          g_assign_detail_tab(g_assign_detail_index).gross_weight := l_dd_gross_wt_left;
          g_assign_detail_tab(g_assign_detail_index).net_weight := l_dd_net_wt_left;
          g_assign_detail_tab(g_assign_detail_index).volume := l_dd_vol_left;
          -- J: W/V Changes
          g_assign_detail_tab(g_assign_detail_index).inventory_item_id := p_line_cont_rec.inventory_item_id;
          g_assign_detail_tab(g_assign_detail_index).weight_uom := p_line_cont_rec.weight_uom;
          g_assign_detail_tab(g_assign_detail_index).volume_uom := p_line_cont_rec.volume_uom;
          -- K LPN CONV. rv
          g_assign_detail_tab(g_assign_detail_index).organization_id := p_line_cont_rec.organization_id;
          g_assign_detail_tab(g_assign_detail_index).delivery_id := p_line_cont_rec.delivery_id;

          --dbms_output.put_line('Assigning '||g_assign_detail_tab(g_assign_detail_index).delivery_detail_id||' to Cont index '||g_assign_detail_tab(g_assign_detail_index).container_index);

        ELSIF (l_tmp_split_qty < l_quantity_left) THEN
          -- Some qty will be left out
--- HW OPM BUG#3011758
-- HW OPMCONV - 1) Renamed lot_indivisible variable to lot_divisible_flag
--            - 2) Changed check condition for lot divisible from 1 to 'N'
          IF( p_line_cont_rec.lot_divisible_flag = 'N')    THEN
             goto next_cont;
          END IF;

          l_quantity_left := l_quantity_left - l_tmp_split_qty;

          --dbms_output.put_line('Splitting dd '||p_line_cont_rec.delivery_detail_id||' with qty '||l_tmp_split_qty);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DELIVERY_DETAILS_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
              WSH_DEBUG_SV.logmsg(l_module_name,'SPLIT QTY IS'||l_tmp_split_qty);
          END IF;
          --

-- added l_dd_id_tab for Bulk call
-- empty container logic, need to test and modify this
-- the value for p_num_of_split is passed as 1
-- so that split occurs once

          WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details_bulk (
               p_from_detail_id => p_line_cont_rec.delivery_detail_id,
               p_req_quantity   => l_tmp_split_qty,
               p_req_quantity2  => l_tmp_split_qty2,
               p_manual_split   => 'C',
               p_num_of_split  => 1,
               x_new_detail_id  => l_split_del_detail_id,
               x_dd_id_tab     => l_dd_id_tab,
               x_return_status  => l_return_status
              );

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
          END IF;
--dbms_output.put_line('STATUS after SPLITDD in empty'||l_return_status||l_dd_id_tab.count);

          IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            --dbms_output.put_line('WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details returned '|| l_return_status);
            x_return_status := C_ERROR_STATUS;
            --dbms_output.put_line('WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details returned '||x_return_status);
            FND_MESSAGE.SET_NAME('WSH','WSH_DET_SPLIT_ERROR');
            FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_line_cont_rec.delivery_detail_id);
            WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            return;
          END IF;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'COUNT OF WDD RECORDS IS'||l_dd_id_tab.count);
          END IF;

          --dbms_output.put_line('Created new dd '||l_split_del_detail_id);

          -- Calculate distributed wt/vol for the new dd
          l_tot_gross_wt := ROUND((l_tmp_split_qty * p_line_cont_rec.gross_weight)/p_line_cont_rec.shp_qty, LIMITED_PRECISION);
          l_tot_net_wt   := ROUND((l_tmp_split_qty * p_line_cont_rec.net_weight)/p_line_cont_rec.shp_qty, LIMITED_PRECISION);
          l_tot_vol      := ROUND((l_tmp_split_qty * p_line_cont_rec.volume)/p_line_cont_rec.shp_qty, LIMITED_PRECISION);
          l_dd_gross_wt_left := l_dd_gross_wt_left - l_tot_gross_wt;
          l_dd_net_wt_left   := l_dd_net_wt_left - l_tot_net_wt;
          l_dd_vol_left      := l_dd_vol_left - l_tot_vol;

-- Use Bulk assignment into this PL SQL table
-- from the returned PL SQL table
-- weight volume will be same
-- Look for empty container population in record, is this correct???

        FOR j in 1..l_dd_id_tab.count
        LOOP
          -- Assign the newly created dd
--dbms_output.put_line('Value of j is'||j);
          g_assign_detail_index := g_assign_detail_index + 1;
          --g_assign_detail_tab(g_assign_detail_index).delivery_detail_id := l_split_del_detail_id;
          g_assign_detail_tab(g_assign_detail_index).delivery_detail_id := l_dd_id_tab(j);
          g_assign_detail_tab(g_assign_detail_index).delivery_id := p_line_cont_rec.delivery_id;
          g_assign_detail_tab(g_assign_detail_index).container_index := g_empty_cont_tab(i).container_index;
          g_assign_detail_tab(g_assign_detail_index).gross_weight := l_tot_gross_wt;
          g_assign_detail_tab(g_assign_detail_index).net_weight := l_tot_net_wt;
          g_assign_detail_tab(g_assign_detail_index).volume := l_tot_vol;
          -- J: W/V Changes
          g_assign_detail_tab(g_assign_detail_index).inventory_item_id := p_line_cont_rec.inventory_item_id;
          g_assign_detail_tab(g_assign_detail_index).weight_uom := p_line_cont_rec.weight_uom;
          g_assign_detail_tab(g_assign_detail_index).volume_uom := p_line_cont_rec.volume_uom;
          -- K LPN CONV. rv
          g_assign_detail_tab(g_assign_detail_index).organization_id := p_line_cont_rec.organization_id;
          g_assign_detail_tab(g_assign_detail_index).delivery_id := p_line_cont_rec.delivery_id;
          --dbms_output.put_line('Assigning '||g_assign_detail_tab(g_assign_detail_index).delivery_detail_id||' to Cont index '||g_assign_detail_tab(g_assign_detail_index).container_index);

         -- j := j + 1;

         END LOOP;
         l_dd_id_tab.DELETE;
        END IF;

        -- Calcualte space left and see if container needs to be deleted from empty cont PL/SQL table
        IF (p_line_cont_rec.fill_pc_basis = 'Q') THEN
          g_empty_cont_tab(i).numerator := (g_empty_cont_tab(i).numerator * l_max_load_qty) - (g_empty_cont_tab(i).denominator * l_tmp_split_qty);
          g_empty_cont_tab(i).denominator := g_empty_cont_tab(i).denominator * l_max_load_qty;

	  /* Bug # 3005780 : Added GCD just to reduce the numerator and denominator values
	   Example : When packing 100 LPNs into a master container (Where Max load QTY is 100) ,  after some iterations the numerator and denominator values exceeding the maximum
	   allowable value in NUMBER data type. to overcome that problem using the Get_Gcd function which limit the both numerator and denominator                   */
          IF (g_empty_cont_tab(i).numerator <> 0 ) AND (g_empty_cont_tab(i).denominator <> 0 ) THEN
              gcdvalue := Get_Gcd(g_empty_cont_tab(i).numerator , g_empty_cont_tab(i).denominator);
              --dbms_output.put_line('Get_Gcd return value is  '||gcdvalue');
              IF (gcdvalue > 1) THEN
                  g_empty_cont_tab(i).numerator := g_empty_cont_tab(i).numerator / gcdvalue;
                  g_empty_cont_tab(i).denominator := g_empty_cont_tab(i).denominator / gcdvalue ;
              END IF;
          END IF;
          IF ((g_empty_cont_tab(i).numerator <= 0) OR
              (g_empty_cont_tab(i).numerator >= g_empty_cont_tab(i).denominator)) THEN
            --dbms_output.put_line('Deleting '||g_empty_cont_tab(i).container_index||' from empty cont table');
            g_empty_cont_tab.DELETE(i);
          END IF;
        ELSIF (p_line_cont_rec.fill_pc_basis = 'W') THEN
          l_wt_left       := l_wt_left - ROUND(l_tmp_split_qty*l_weight_per_pc,LIMITED_PRECISION);
          g_empty_cont_tab(i).empty := g_empty_cont_tab(i).empty - (l_tmp_split_qty * l_weight_per_pc);
          IF (g_empty_cont_tab(i).empty <= 0) THEN
            --dbms_output.put_line('Deleting '||g_empty_cont_tab(i).container_index||' from empty cont table');
            g_empty_cont_tab.DELETE(i);
          END IF;
        ELSE
          l_vol_left       := l_vol_left - ROUND(l_tmp_split_qty*l_volume_per_pc,LIMITED_PRECISION);
          g_empty_cont_tab(i).empty := g_empty_cont_tab(i).empty - (l_tmp_split_qty * l_volume_per_pc);
          IF (g_empty_cont_tab(i).empty <= 0) THEN
            --dbms_output.put_line('Deleting '||g_empty_cont_tab(i).container_index||' from empty cont table');
            g_empty_cont_tab.DELETE(i);
          END IF;
        END IF;

      END IF; -- l_tmp_split_qty <= 0

      -- If the whole qty is packed then exit the loop
      IF (l_quantity_left <= 0) THEN
        EXIT;
      END IF;

      <<next_cont>>
        i := g_empty_cont_tab.NEXT(i);
    END LOOP;
  END IF; -- g_empty_cont_tab > 0

--dbms_output.put_line('AFter EMPTY containers with empty space'||to_char(sysdate,'HH24:MI:SS'));

  --dbms_output.put_line(' *** Looping empty cont tab is Over and Quantity Left is '||l_quantity_left||' ***');
  IF (l_quantity_left > 0) THEN
    -- Some qty is left out

    IF (p_line_cont_rec.fill_pc_basis = 'Q') THEN

      l_tmp_split_qty  := l_max_load_qty;
      l_split_qty      := l_tmp_split_qty;

    ELSIF (p_line_cont_rec.fill_pc_basis = 'W') THEN

      -- Need to do TRUNC instead of ROUND because of following case
      -- Ex: If we try to pack qty 4(wt per 3Lbs) into Cont with wt 2LB the value of l_tmp_split_qty(after ROUND) is 0.66667
      --     Total wt of split dd will be 0.66667 * 3 = 2.00001 which is > Cont capacity
      l_tmp_split_qty := TRUNC((l_quantity_left*l_mtl_max_load)/l_wt_left,LIMITED_PRECISION);
      l_split_qty := l_tmp_split_qty;
      --dbms_output.put_line('l_quantity_left '||l_quantity_left||' l_wt_left '||l_wt_left||' l_mtl_max_load '||l_mtl_max_load);

    ELSE

      l_tmp_split_qty := TRUNC((l_quantity_left*l_mtl_max_vol)/l_vol_left,LIMITED_PRECISION);
      l_split_qty := l_tmp_split_qty;
      --dbms_output.put_line('l_quantity_left '||l_quantity_left||' l_vol_left '||l_vol_left||' l_mtl_max_vol '||l_mtl_max_vol);

    END IF;
    -- l_tmp_split_qty holds max that can be packed into a new container
    --dbms_output.put_line(' l_tmp_split_qty '||l_tmp_split_qty);

    -- Per Pushkar,OPM: Call Check_Decimal_Quantity for both OPM and Discrete for primary quantity
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_DECIMAL_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_DETAILS_VALIDATIONS.Check_Decimal_Quantity (
       p_line_cont_rec.inventory_item_id,
       p_line_cont_rec.organization_id,
       l_tmp_split_qty,
       p_line_cont_rec.req_qty_uom,
       l_output_qty,
       l_return_status);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
    END IF;
    IF (l_return_status <> C_SUCCESS_STATUS OR
        p_line_cont_rec.indivisible_flag = 'Y')THEN
      -- Fractional qtys not allowed
      --dbms_output.put_line('WSH_DETAILS_VALIDATIONS.Check_Decimal_Quantity returned '||l_return_status);
      l_discard_message := FND_MESSAGE.GET;
      l_split_qty  := FLOOR(l_tmp_split_qty);
    END IF;

-- HW OPMCONV - 1) No need to check for process
--            - 2) Changed code to handle qty2

    IF ( p_line_cont_rec.shp_qty2 IS NOT NULL ) THEN
      l_split_qty2 := (l_split_qty * p_line_cont_rec.shp_qty2)/p_line_cont_rec.shp_qty;
    ELSE
      l_split_qty2 := NULL;
    END IF;
    -- Split Qty holds quantity that can be packed into a container

    --dbms_output.put_line('l_split_qty '||l_split_qty||' l_split_qty2 '||l_split_qty2);
-- initialize the variables
    l_count_container := 0;
    l_container_item_id := -99;
    l_container_org_id := -99;

--dbms_output.put_line('Before LOOP in pack DD'||to_char(sysdate,'HH24:MI:SS'));
    WHILE (l_quantity_left > 0) LOOP

      -- Create new container index
      --g_new_cont_index := g_new_cont_index + 1;

-- added code here
      IF (p_line_cont_rec.preferred_container = l_container_item_id
          AND p_line_cont_rec.organization_id = l_container_org_id)
      THEN
-- keep appending this logic is moved to the end
        null;
      ELSE
-- reset counter
        l_count_container := 0;
      END IF;

      l_container_item_id := p_line_cont_rec.preferred_container;
      l_container_org_id := p_line_cont_rec.organization_id;

      --dbms_output.put_line('Created Container index '||g_new_cont_index);
      --dbms_output.put_line('l_tmp_split_qty '||l_tmp_split_qty||' l_split_qty '||l_split_qty);

      IF (l_split_qty < l_quantity_left
          AND l_split_qty > 0
         ) THEN
        -- Quantity left is > Split qty
        l_num_of_split := CEIL(l_quantity_left/l_split_qty) -1;

        -- Start BugFix#3475352
	IF (l_num_of_split + 1) > 100000 THEN
            x_return_status := C_ERROR_STATUS;
            FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONT_COUNT');
            FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_line_cont_rec.delivery_detail_id);
            WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
	    return;
        END IF;
        -- End BugFix#3475352

        --dbms_output.put_line('Splitting dd '||p_line_cont_rec.delivery_detail_id||' with qty '||l_split_qty);
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DELIVERY_DETAILS_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
            WSH_DEBUG_SV.logmsg(l_module_name,'Split Qty is'||l_split_qty);
            WSH_DEBUG_SV.logmsg(l_module_name,'Number of split is'||l_num_of_split);
        END IF;

--this is in Main Loop
-- Call BULK Split API

--dbms_output.put_line('======BEFORE SPLIT'||l_dd_id_tab.count||'<'||l_num_of_split);

        WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details_bulk (
             p_from_detail_id => p_line_cont_rec.delivery_detail_id,
             p_req_quantity   => l_split_qty,
             p_req_quantity2  => l_split_qty2,
             p_manual_split   => 'C',
             p_num_of_split   => l_num_of_split,
             x_new_detail_id  => l_split_del_detail_id,
             x_dd_id_tab      => l_dd_id_tab,
             x_return_status  => l_return_status
        );

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
    END IF;

        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          --dbms_output.put_line('WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details returned '|| l_return_status);
          x_return_status := C_ERROR_STATUS;
          FND_MESSAGE.SET_NAME('WSH','WSH_DET_SPLIT_ERROR');
          FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_line_cont_rec.delivery_detail_id);
          WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);

          IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
          END IF;

          return;
        END IF;
--dbms_output.put_line('======AFTER SPLIT'||l_dd_id_tab.count);

      ELSE -- (l_split_qty < l_quantity_left)
      -- l_quantity_left <= l_split_qty which means there is no more qty left

        l_split_qty := l_quantity_left;
        l_split_del_detail_id := p_line_cont_rec.delivery_detail_id;
        l_dd_id_tab(l_dd_id_tab.count + 1) := p_line_cont_rec.delivery_detail_id;
      END IF;
      --dbms_output.put_line('l_tmp_split_qty '||l_tmp_split_qty||' l_split_qty '||l_split_qty);

      -- Insert the new container into empty PL/SQL cont table only if l_tmp_split_qty > l_split_qty
      -- Otherwise Container is full
      IF ((l_tmp_split_qty - l_split_qty) > 0) THEN
        -- l_tmp_split_qty > l_split_qty means container is not full and
        -- we need to calculate how much empty space is left
        IF (g_empty_cont_tab.COUNT = 0) THEN
          j := 1;
        ELSE
          j:= g_empty_cont_tab.LAST + 1;
        END IF;
        --g_empty_cont_tab(j).container_index   := g_new_cont_index;
-- changed this part
        g_empty_cont_tab(j).container_index   := g_new_cont_index + 1;
        g_empty_cont_tab(j).container_item_id := p_line_cont_rec.preferred_container;
        g_empty_cont_tab(j).organization_id   := p_line_cont_rec.organization_id;
        g_empty_cont_tab(j).group_id          := p_line_cont_rec.group_id;
        g_empty_cont_tab(j).mast_cont_item_id := p_line_cont_rec.master_cont_item_id;

        -- Calculate Empty Space
        IF (p_line_cont_rec.fill_pc_basis = 'Q') THEN
          g_empty_cont_tab(j).numerator   := l_max_load_qty - l_split_qty;
          g_empty_cont_tab(j).denominator := l_max_load_qty;
          --dbms_output.put_line('Inserted Container '||j||' with numerator '||g_empty_cont_tab(j).numerator||' and denominator '||g_empty_cont_tab(j).denominator);
        ELSIF (p_line_cont_rec.fill_pc_basis = 'W') THEN
          g_empty_cont_tab(j).empty             := l_mtl_max_load - (l_split_qty * l_weight_per_pc);
          --dbms_output.put_line('Inserted Container '||j||' with empty weight '||g_empty_cont_tab(j).empty||' into empty cont');
        ELSE
          g_empty_cont_tab(j).empty             := l_mtl_max_vol - ROUND(l_split_qty * l_volume_per_pc,LIMITED_PRECISION);
          --dbms_output.put_line('Inserted Container '||j||' with empty volume '||g_empty_cont_tab(j).empty||' into empty cont');
        END IF;
      END IF;

      -- Calculate distributed wt/vol for the new dd
      l_tot_gross_wt  := ROUND((l_split_qty * p_line_cont_rec.gross_weight)/p_line_cont_rec.shp_qty,LIMITED_PRECISION);
      l_tot_net_wt    := ROUND((l_split_qty * p_line_cont_rec.net_weight)/p_line_cont_rec.shp_qty,LIMITED_PRECISION);
      l_tot_vol       := ROUND((l_split_qty * p_line_cont_rec.volume)/p_line_cont_rec.shp_qty,LIMITED_PRECISION);
--dbms_output.put_line('l_tot_vol '||l_tot_vol||' l_dd_vol_left '||l_dd_vol_left);

      -- Assign the split dd/existing dd
-- changed the call to populate the PL SQL table

      IF l_dd_id_tab.count > 0 THEN
        FOR j in 1..l_dd_id_tab.count
        LOOP
          IF l_count_container > 0 THEN
            l_count_container := l_count_container + 1;
            g_new_container_tab(g_num_cont_index).number_of_containers := l_count_container;
            g_new_cont_index := g_new_cont_index + 1;
          ELSE
            l_count_container := 1;
            g_num_cont_index := g_num_cont_index + 1;
            g_new_cont_index := g_new_cont_index + 1;
            g_new_container_tab(g_num_cont_index).container_item_id := p_line_cont_rec.preferred_container;
            g_new_container_tab(g_num_cont_index).organization_id   := p_line_cont_rec.organization_id;
            g_new_container_tab(g_num_cont_index).mast_cont_item_id := p_line_cont_rec.master_cont_item_id;
            g_new_container_tab(g_num_cont_index).number_of_containers := l_count_container;

          END IF;

          g_assign_detail_index := g_assign_detail_index + 1;
          g_assign_detail_tab(g_assign_detail_index).delivery_detail_id := l_dd_id_tab(j);
          g_assign_detail_tab(g_assign_detail_index).delivery_id := p_line_cont_rec.delivery_id;
          g_assign_detail_tab(g_assign_detail_index).container_index    := g_new_cont_index;
          g_assign_detail_tab(g_assign_detail_index).gross_weight := l_tot_gross_wt;
          g_assign_detail_tab(g_assign_detail_index).net_weight := l_tot_net_wt;
          g_assign_detail_tab(g_assign_detail_index).volume := l_tot_vol;
          -- J: W/V Changes
          g_assign_detail_tab(g_assign_detail_index).inventory_item_id := p_line_cont_rec.inventory_item_id;
          g_assign_detail_tab(g_assign_detail_index).weight_uom := p_line_cont_rec.weight_uom;
          g_assign_detail_tab(g_assign_detail_index).volume_uom := p_line_cont_rec.volume_uom;
          -- K LPN CONV. rv
          g_assign_detail_tab(g_assign_detail_index).organization_id := p_line_cont_rec.organization_id;
          g_assign_detail_tab(g_assign_detail_index).delivery_id := p_line_cont_rec.delivery_id;
          -- K LPN CONV. rv

          l_quantity_left := l_quantity_left - l_split_qty;
          l_dd_gross_wt_left  := l_dd_gross_wt_left - l_tot_gross_wt;
          l_dd_net_wt_left  := l_dd_net_wt_left - l_tot_net_wt;
          l_dd_vol_left := l_dd_vol_left - l_tot_vol;

        END LOOP;

        l_dd_id_tab.DELETE;

-- so that this table is not read later,
-- we continue in the LOOP even if qty_left = 1, so in that case
-- should not reach here

--  commented this and put it in the LOOP above
--         l_quantity_left := GREATEST(l_quantity_left - (FLOOR(l_quantity_left/l_split_qty) *l_split_qty),0);
      ELSE
        g_assign_detail_index := g_assign_detail_index + 1;
        g_new_cont_index := g_new_cont_index + 1;
        g_assign_detail_tab(g_assign_detail_index).delivery_detail_id := l_split_del_detail_id;
        g_assign_detail_tab(g_assign_detail_index).delivery_id := p_line_cont_rec.delivery_id;
        g_assign_detail_tab(g_assign_detail_index).container_index    := g_new_cont_index;
        g_assign_detail_tab(g_assign_detail_index).gross_weight := l_tot_gross_wt;
        g_assign_detail_tab(g_assign_detail_index).net_weight := l_tot_net_wt;
        g_assign_detail_tab(g_assign_detail_index).volume := l_tot_vol;
        -- J: W/V Changes
        g_assign_detail_tab(g_assign_detail_index).inventory_item_id := p_line_cont_rec.inventory_item_id;
        g_assign_detail_tab(g_assign_detail_index).weight_uom := p_line_cont_rec.weight_uom;
        g_assign_detail_tab(g_assign_detail_index).volume_uom := p_line_cont_rec.volume_uom;
        -- K LPN CONV. rv
        g_assign_detail_tab(g_assign_detail_index).organization_id := p_line_cont_rec.organization_id;
        g_assign_detail_tab(g_assign_detail_index).delivery_id := p_line_cont_rec.delivery_id;
        -- K LPN CONV. rv
      --dbms_output.put_line('Assigning '||g_assign_detail_tab(g_assign_detail_index).delivery_detail_id||' to Cont index '||g_assign_detail_tab(g_assign_detail_index).container_index);

        l_quantity_left := l_quantity_left - l_split_qty;

      END IF;


      -- If there is no more qty left, then adjust any wt/vol left on last dd
      IF (l_quantity_left <= 0) THEN
        --dbms_output.put_line('Assigning the left over Weight');
        g_assign_detail_tab(g_assign_detail_index).gross_weight := g_assign_detail_tab(g_assign_detail_index).gross_weight + l_dd_gross_wt_left;
        g_assign_detail_tab(g_assign_detail_index).net_weight := g_assign_detail_tab(g_assign_detail_index).net_weight + l_dd_net_wt_left;
        g_assign_detail_tab(g_assign_detail_index).volume := g_assign_detail_tab(g_assign_detail_index).volume + l_dd_vol_left;
      END IF;
      --dbms_output.put_line('l_quantity_left '||l_quantity_left);

    END LOOP;

--dbms_output.put_line('End of Pack DD, Count is '||l_count_container||to_char(sysdate,'HH24:MI:SS'));

  END IF;
  x_return_status := C_SUCCESS_STATUS;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN;

EXCEPTION
  WHEN Others THEN
        WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Pack_Delivery_Detail',l_module_name);
        x_return_status := C_UNEXP_ERROR_STATUS;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Pack_Delivery_Detail;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Validate_Dd_for_Pack
   PARAMETERS : p_group_id_tab_id - table of group ids for lines that need to
			            be autopacked.
		p_del_detail_tab  - table of delivery detail ids
		x_line_cont_tab   - Delivery Details along with other info
			            which passed validations
		x_error_cnt       - Count of errors encountered during validation
		x_warn_cnt        - Count of warnings encountered during validation
                x_fill_pc_warn_cnt - Count of Fill Percent Basis 'None' dds.
                x_fill_pc_warn_cnt - Count of details with Fill Percent Basis 'None'.
                x_release_warn_cnt - Count of 'Released to Warehouse' dds.
  DESCRIPTION : This procedure takes a list of delivery details and does all
                validations and returns a list of delivery details which passed
                validations
------------------------------------------------------------------------------
*/

PROCEDURE Validate_Dd_for_Pack(
  p_group_id_tab      IN  WSH_UTIL_CORE.id_tab_type,
  p_del_detail_tab    IN  WSH_UTIL_CORE.id_tab_type,
  x_line_cont_tab     OUT NOCOPY  wsh_container_actions.line_cont_info_tab,
  x_error_cnt         OUT NOCOPY  NUMBER,
  x_warn_cnt          OUT NOCOPY  NUMBER,
  x_fill_pc_warn_cnt  OUT NOCOPY  NUMBER, -- bug 3562797 jckwok
  x_release_warn_cnt  OUT NOCOPY  NUMBER) IS

  CURSOR Get_dd_Detail IS
  SELECT wdd.inventory_item_id inventory_item_id,
         NVL(wdd.shipped_quantity, NVL(wdd.picked_quantity, wdd.requested_quantity)) packed_quantity,
         NVL(wdd.shipped_quantity2, NVL(wdd.picked_quantity2, wdd.requested_quantity2)) packed_quantity2,
         NVL(wdd.picked_quantity, wdd.requested_quantity) picked_quantity,
         NVL(wdd.picked_quantity2, wdd.requested_quantity2) picked_quantity2,
         wdd.requested_quantity_uom requested_quantity_uom,
         nvl(wdd.wv_frozen_flag,'Y') wv_frozen_flag,
         wdd.gross_weight gross_weight,
         wdd.net_weight net_weight,
         wdd.weight_uom_code weight_uom_code,
         wdd.volume volume,
         wdd.volume_uom_code volume_uom_code,
         wdd.detail_container_item_id detail_container_item_id,
         wdd.master_container_item_id master_container_item_id,
         wdd.organization_id organization_id,
         wdd.source_line_id source_line_id,
         wdd.delivery_detail_id delivery_detail_id,
         wdd.released_status,
         wdd.source_code,
         wda.parent_delivery_detail_id parent_delivery_detail_id,
         wda.delivery_id delivery_id, --  added delivery id
         msi.indivisible_flag indivisible_flag
  FROM   WSH_DELIVERY_DETAILS wdd,
         wsh_delivery_assignments_v wda,
         MTL_SYSTEM_ITEMS msi,
         WSH_TMP wt
  WHERE  wdd.delivery_detail_id =  wt.id
  AND    wdd.delivery_detail_id = wda.delivery_detail_id
  AND    wdd.container_flag     = 'N'
  AND    wdd.inventory_item_id  = msi.inventory_item_id
  AND    wdd.organization_id    = msi.organization_id
  ORDER BY wdd.organization_id,wdd.inventory_item_id,source_line_id;

  CURSOR Get_Cont_Item_Load (v_inv_item_id NUMBER, v_cont_item_id NUMBER, v_organization_id NUMBER) IS
  SELECT max_load_quantity
  FROM   WSH_CONTAINER_ITEMS
  WHERE  load_item_id           = v_inv_item_id
  AND    container_item_id      = v_cont_item_id
  AND    master_organization_id = v_organization_id;

  line_cont_rec line_cont_info;
  line_cont_tab line_cont_info_tab;

  l_dd_count        NUMBER;
  l_group_id        NUMBER;
  l_wcl_cont_item_id NUMBER;
  l_fill_pc_basis   VARCHAR2(1);
  l_max_load_qty    NUMBER;
  l_item_load_found BOOLEAN;

  l_return_status   VARCHAR2(1);

  l_dd_gross_wt     NUMBER;
  l_dd_net_wt       NUMBER;
  l_dd_volume       NUMBER;
  l_mtl_max_load    NUMBER;
  l_mtl_max_vol     NUMBER;
  l_mtl_wt_uom      VARCHAR2(3);
  l_mtl_vol_uom     VARCHAR2(3);
  l_tmp_num_cont    NUMBER;
  l_discard_message VARCHAR2(2000);
  l_output_qty      NUMBER;
  l_process_flag    VARCHAR2(1);
  l_last_organization_id NUMBER;
  l_error_cnt       NUMBER := 0;

  warn_cnt          NUMBER := 0;
  error_cnt         NUMBER := 0;
  release_warn_cnt  NUMBER := 0;
  fill_pc_warn_cnt  NUMBER := 0; -- bug 3562797 jckwok
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_DD_FOR_PACK';
--

-- HW OPMCONV - New variable to hold item info
l_item_info                   WSH_DELIVERY_DETAILS_INV.mtl_system_items_rec;
-- HW OPM BUG# 3011758
-- HW OPMCONV - Removed opm variables

-- HW OPMCONV - Renamed variable from lot_indivisible to l_lot_divisible_flag
l_lot_divisible_flag                        VARCHAR2(1);

-- HW OPMCONV - New variables to hold warnings and errors
l_num_warnings                NUMBER :=0;
l_num_errors                  NUMBER := 0;
x_return_status VARCHAR2(5);
BEGIN

  --dbms_output.put_line('---------------------------');
  --dbms_output.put_line('In Validate_Dd_for_Pack ...');
  --dbms_output.put_line('---------------------------');

  -- 10. Delete and Bulk Insert into the wsh_tmp table
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
  DELETE FROM wsh_tmp;

  FORALL i IN 1..p_del_detail_tab.count
    INSERT INTO wsh_tmp (id) VALUES(p_del_detail_tab(i));

  -- 20. Populate  detail dd info into line_cont_tab PL/SQL table
  l_last_organization_id := NULL;
  l_dd_count := 0;

  FOR rec in get_dd_detail
  LOOP
    --dbms_output.put_line('Processing dd '||rec.delivery_detail_id||' Org '||rec.organization_id);

    -- 20.10 Delete Organization Specfic Cached Tables if organization_id changes
    IF ((l_last_organization_id IS NULL) OR (rec.organization_id <> l_last_organization_id)) THEN
      g_cache_cont_load_info_tab.DELETE;
      g_cont_msi_tab.DELETE;

      l_last_organization_id := rec.organization_id;
    END IF;


    /* grouping API will return a number = negative delivery_id if the line is
       already assigned to a delivery. So, check for negative numbers and if number
       < 0, then convert it to a postive number = delivery_id.
    */
    l_group_id := ABS(p_group_id_tab(rec.delivery_detail_id));
    --dbms_output.put_line('l_group_id '||l_group_id);

    -- 20.12 Populate line_cont_tab PL/SQL table now
    IF ((rec.packed_quantity <> 0) AND (rec.released_status NOT IN ('C','D'))) THEN
      line_cont_rec.group_id            := l_group_id;
      line_cont_rec.delivery_detail_id  := rec.delivery_detail_id;
      line_cont_rec.inventory_item_id   := rec.inventory_item_id;
      line_cont_rec.shp_qty             := rec.packed_quantity;
      line_cont_rec.shp_qty2            := rec.packed_quantity2;
      line_cont_rec.req_qty             := rec.picked_quantity;
      line_cont_rec.req_qty2            := rec.picked_quantity2;
      line_cont_rec.req_qty_uom         := rec.requested_quantity_uom;
      line_cont_rec.detail_cont_item_id := rec.detail_container_item_id;
      line_cont_rec.master_cont_item_id := rec.master_container_item_id;
      line_cont_rec.gross_weight        := rec.gross_weight;
      line_cont_rec.net_weight          := rec.net_weight;
      line_cont_rec.weight_uom          := rec.weight_uom_code;
      line_cont_rec.volume              := rec.volume;
      line_cont_rec.volume_uom          := rec.volume_uom_code;
      line_cont_rec.organization_id     := rec.organization_id;
      line_cont_rec.source_line_id      := rec.source_line_id;
      line_cont_rec.indivisible_flag    := rec.indivisible_flag;
      line_cont_rec.delivery_id         := rec.delivery_id;
    ELSE
      goto next_detail;
    END IF;

    -- 20.20 Check if the detail is already packed
    IF (rec.parent_delivery_detail_id IS NOT NULL) THEN
      --dbms_output.put_line('Warning: dd already packed');
      warn_cnt := warn_cnt + 1;
      goto next_detail;
    END IF;

    -- 20.30 Ignore dds with status 'Released to Warehouse'
    IF (rec.released_status = 'S') THEN
      release_warn_cnt := release_warn_cnt + 1;
      goto next_detail;
    END IF;

     --dbms_output.put_line('Before calc_fill_basis');

    -- 20.40 Determine Fill PC Basis from shipping parameters and Process Flag
    Calc_Fill_Basis_and_Proc_Flag(
      p_organization_id => rec.organization_id,
      x_return_status   => l_return_status,
      x_fill_basis      => l_fill_pc_basis,
      x_process_flag    => l_process_flag);


    IF (l_return_status <> C_SUCCESS_STATUS) THEN
      error_cnt := error_cnt + 1;
      goto next_detail;
    END IF;
    --
    -- bug 3562797 jckwok  - Ignore dds with 'Shipping Parameter' percent fill basis as None.
    -- Increment fill_pc_warn_cnt so that the caller know how many had fill basis of None.
    --
    IF (l_fill_pc_basis = 'N') THEN
      fill_pc_warn_cnt := fill_pc_warn_cnt + 1;
      goto next_detail;
    END IF;
    -- end bug

    line_cont_rec.fill_pc_basis := l_fill_pc_basis;
-- HW OPMCONV - No need to populate this value
--  line_cont_rec.process_flag  := l_process_flag;

-- HW OPM BUG#:3011758 Retrieve OPM item information
-- HW OPMCONV - 1)Change the call from OPM API to get item info
--                to a new WSH API
--            - 2) Remove checking for process

    WSH_DELIVERY_DETAILS_INV.Get_item_information
          (
               p_organization_id       => rec.organization_id
              , p_inventory_item_id    => rec.inventory_item_id
              , x_mtl_system_items_rec => l_item_info
              , x_return_status        => l_return_status
            );


     IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
    END IF;

     wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );

     IF (  l_item_info.lot_divisible_flag = 'N' AND
           l_item_info.lot_control_code= 2) THEN
         line_cont_rec.lot_divisible_flag := 'N';
     ELSE
         line_cont_rec.lot_divisible_flag := 'Y';
     END IF;


-- HW OPMCONV - No need to check for process_flag. Removed OR condition
    IF (line_cont_rec.fill_pc_basis IS NULL) THEN
      --dbms_output.put_line('Skipping dd');

      goto next_detail;
    END IF;

    -- 20.50 Determine Preferred Container
    line_cont_rec.preferred_container := nvl(rec.detail_container_item_id,rec.master_container_item_id);
    line_cont_rec.max_load_qty := NULL;

     --dbms_output.put_line('Before calc_pref_cont');

    IF (line_cont_rec.preferred_container IS NULL) THEN

      Calc_Pref_Container(
        p_organization_id   => rec.organization_id,
        p_inventory_item_id => rec.inventory_item_id,
        p_fill_pc_basis     => line_cont_rec.fill_pc_basis,
        x_return_status     => l_return_status,
        x_error_cnt         => l_error_cnt,
        x_cont_item_id      => l_wcl_cont_item_id,
        x_max_load_qty      => l_max_load_qty);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
      END IF;

      IF (l_return_status = C_ERROR_STATUS) THEN
        error_cnt := error_cnt + l_error_cnt;
      END IF;

      line_cont_rec.preferred_container := l_wcl_cont_item_id;
      line_cont_rec.max_load_qty        := l_max_load_qty;
    END IF;

    -- bug 3440811
    validate_container(
      p_organization_id  => rec.organization_id,
      p_cont_item_id     => line_cont_rec.preferred_container,
      x_return_status    => l_return_status);

    IF (l_return_status IN (C_UNEXP_ERROR_STATUS,C_ERROR_STATUS)) THEN
        line_cont_rec.preferred_container := null;
        line_cont_rec.max_load_qty := null;
        l_error_cnt := l_error_cnt + 1;
        error_cnt := error_cnt + l_error_cnt;
    END IF;
    -- bug 3440811


    IF (line_cont_rec.preferred_container is NULL) THEN
      --dbms_output.put_line('Skipping dd');
      goto next_detail;
    END IF;


    -- 20.60 Calculate Max Load/Converted wt/Converted Vol depending on fill basis
    line_cont_rec.converted_wt := NULL;
    line_cont_rec.converted_vol := NULL;

     --dbms_output.put_line('FILL BASIS'||line_cont_rec.fill_pc_basis||line_cont_rec.max_load_qty);
    IF (line_cont_rec.fill_pc_basis = 'Q') THEN
      IF (line_cont_rec.max_load_qty IS NULL) THEN
        OPEN Get_Cont_Item_Load (rec.inventory_item_id,line_cont_rec.preferred_container, rec.organization_id);

        FETCH Get_Cont_Item_Load
        INTO  l_max_load_qty;

        l_item_load_found := FALSE;
        IF Get_Cont_Item_Load%NOTFOUND THEN
          l_item_load_found := TRUE;
        END IF;
        CLOSE Get_Cont_Item_Load;

        IF (l_item_load_found) THEN
          --dbms_output.put_line('Could not find max load qty for Item '||rec.inventory_item_id||' Cont '||line_cont_rec.preferred_container||' Org '||rec.organization_id);

          -- Calculate max load qty depending on Weight/Volume
          IF (rec.net_weight IS NULL OR rec.volume IS NULL) THEN
            --
            IF rec.wv_frozen_flag = 'N' THEN

              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              WSH_WV_UTILS.Detail_Weight_Volume(
                   p_delivery_detail_id => rec.delivery_detail_id,
                   -- J: W/V Changes
                   p_update_flag        => 'Y',
                   p_post_process_flag  => 'Y',
                   p_calc_wv_if_frozen  => 'N',
                   x_net_weight         => l_dd_net_wt,
                   x_volume             => l_dd_volume ,
                   x_return_status      => l_return_status);
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
              END IF;

              IF (l_return_status <> C_SUCCESS_STATUS) THEN
                --dbms_output.put_line('WSH_WV_UTILS.Detail_Weight_Volume did not return success');
                FND_MESSAGE.SET_NAME('WSH','WSH_DET_WT_VOL_FAILED');
                FND_MESSAGE.SET_TOKEN('DETAIL_ID',rec.delivery_detail_id);
                WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
                error_cnt := error_cnt + 1;
                --dbms_output.put_line('Skipping this dd');
                goto next_detail;
              END IF;

              rec.gross_weight := NVL(rec.gross_weight,l_dd_net_wt);
              rec.net_weight   := NVL(rec.net_weight,l_dd_net_wt);
              rec.volume       := NVL(rec.volume,l_dd_volume);

            END IF;

            IF ((NVL(rec.net_weight,0) = 0) OR
                (NVL(rec.volume,0) = 0)) THEN
              --dbms_output.put_line('Weight or Volume is NULL or 0');
              FND_MESSAGE.SET_NAME('WSH', 'WSH_NULL_WEIGHT_VOLUME');
              FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL', rec.delivery_detail_id);
              WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
              error_cnt := error_cnt + 1;
              --dbms_output.put_line('Skipping this dd');
              goto next_detail;
            END IF;
          END IF;

--dbms_output.put_line('Call to GET CONT LOAD VOL INFO 4');
          Get_Cont_Load_Vol_info(
             p_container_item_id => line_cont_rec.preferred_container,
             p_organization_id   => line_cont_rec.organization_id,
             p_w_v_both          => 'B',
             x_max_load          => l_mtl_max_load,
             x_max_vol           => l_mtl_max_vol,
             x_wt_uom            => l_mtl_wt_uom,
             x_vol_uom           => l_mtl_vol_uom,
             x_return_status     => l_return_status,
             x_error_cnt         => l_error_cnt);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
          END IF;
          IF (l_return_status IN (C_ERROR_STATUS,C_UNEXP_ERROR_STATUS)
              ) THEN
            error_cnt := error_cnt + l_error_cnt;
          END IF;

-- Bug 2786021
          IF (nvl(l_mtl_max_load,0) = 0) OR
             (nvl(l_mtl_max_vol,0) = 0) THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'fill pc is Q,but use Wt or Vol');
              WSH_DEBUG_SV.log(l_module_name,'Wt-'||l_mtl_max_load);
              WSH_DEBUG_SV.log(l_module_name,'Vol-'||l_mtl_max_vol);
            END IF;
            FND_MESSAGE.SET_NAME('WSH', 'WSH_CONT_MAX_WT_ERROR');
            WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
            error_cnt := error_cnt + l_error_cnt;
            goto next_detail;
          END IF;
-- Bug 2786021

          IF ((NVL(l_mtl_max_load,0) <= 0) OR (NVL(l_mtl_max_vol,0) <= 0)) THEN
            --dbms_output.put_line('Skipping this dd');
            goto next_detail;
          END IF;

          IF (l_mtl_wt_uom <> rec.weight_uom_code) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            l_dd_gross_wt := WSH_WV_UTILS.Convert_Uom (
                                  from_uom => rec.weight_uom_code,
                                  to_uom   => l_mtl_wt_uom,
                                  quantity => rec.gross_weight,
                                  item_id  => rec.inventory_item_id);
          ELSE
            l_dd_gross_wt := rec.gross_weight;
          END IF;

          IF (l_mtl_vol_uom <> rec.volume_uom_code) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            l_dd_volume :=  WSH_WV_UTILS.Convert_Uom (
                                  from_uom => rec.volume_uom_code,
                                  to_uom   => l_mtl_vol_uom,
                                  quantity => rec.volume,
                                  item_id  => rec.inventory_item_id);
          ELSE
            l_dd_volume:= rec.volume;
          END IF;

          IF ((l_dd_gross_wt/l_mtl_max_load) >= (l_dd_volume/l_mtl_max_vol)) THEN
            l_max_load_qty := (l_dd_gross_wt/l_mtl_max_load);
          ELSE
            l_max_load_qty := (l_dd_volume/l_mtl_max_vol);
          END IF;
          --dbms_output.put_line('l_dd_gross_wt '||l_dd_gross_wt||' l_dd_volume '||l_dd_volume ||' l_mtl_max_load '||l_mtl_max_load||' l_mtl_max_vol '||l_mtl_max_vol || ' l_max_load_qty '||l_max_load_qty);

          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_DECIMAL_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          WSH_DETAILS_VALIDATIONS.Check_Decimal_Quantity (
                      p_item_id         => rec.inventory_item_id,
                      p_organization_id => rec.organization_id,
                      p_input_quantity  => ROUND((rec.packed_quantity/l_max_load_qty),LIMITED_PRECISION),
                      p_uom_code        => rec.requested_quantity_uom,
                      x_output_quantity => l_output_qty,
                      x_return_status   => l_return_status);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
          END IF;
          IF l_return_status <> C_SUCCESS_STATUS THEN
            --dbms_output.put_line('WSH_DETAILS_VALIDATIONS.Check_Decimal_Quantity returned '||l_return_status);
            l_discard_message := FND_MESSAGE.GET;
            l_tmp_num_cont := FLOOR(rec.packed_quantity/l_max_load_qty);

            IF (l_tmp_num_cont = 0) THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_WT_ERROR');
              WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
              error_cnt := error_cnt + 1;
              goto next_detail;
            ELSE
              --l_max_load_qty := (rec.packed_quantity/l_tmp_num_cont);
              l_max_load_qty := l_tmp_num_cont;
            END IF;
          ELSE
            l_max_load_qty := ROUND((rec.packed_quantity/l_max_load_qty),LIMITED_PRECISION);
          END IF;
        END IF; -- l_item_load_found
        line_cont_rec.max_load_qty := l_max_load_qty;

        IF (NVL(line_cont_rec.max_load_qty,0) <= 0) THEN
          --dbms_output.put_line('Max Load Qty is NULL or <= 0. Skipping this dd');
          FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_WT_ERROR');
          WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
          error_cnt := error_cnt + 1;
          goto next_detail;
        END IF;

      END IF; -- line_cont_rec.max_load_qty IS NULL
      --dbms_output.put_line('line_cont_rec.max_load_qty '||line_cont_rec.max_load_qty);

    ELSIF (line_cont_rec.fill_pc_basis in ('W','V')) THEN
      -- Calculate max load qty depending on Weight/Volume
      IF ((rec.gross_weight IS NULL AND line_cont_rec.fill_pc_basis = 'W') OR
          (rec.volume IS NULL) AND (line_cont_rec.fill_pc_basis = 'V')) THEN
        --
        IF rec.wv_frozen_flag = 'N' THEN

          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          WSH_WV_UTILS.Detail_Weight_Volume(
               p_delivery_detail_id => rec.delivery_detail_id,
               -- J: W/V Changes
               p_update_flag        => 'Y',
               p_post_process_flag  => 'Y',
               p_calc_wv_if_frozen  => 'N',
               x_net_weight         => l_dd_net_wt,
               x_volume             => l_dd_volume ,
               x_return_status      => l_return_status);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'return status -,wt,vol',l_return_status||l_dd_net_wt||','||l_dd_volume);
          END IF;

          IF (l_return_status <> C_SUCCESS_STATUS) THEN
            --dbms_output.put_line('WSH_WV_UTILS.Detail_Weight_Volume did not return success');
            FND_MESSAGE.SET_NAME('WSH','WSH_DET_WT_VOL_FAILED');
            FND_MESSAGE.SET_TOKEN('DETAIL_ID',rec.delivery_detail_id);
            WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
            error_cnt := error_cnt + 1;
            --dbms_output.put_line('Skipping this dd');
            goto next_detail;
          END IF;

          IF (line_cont_rec.fill_pc_basis = 'W') THEN
            rec.gross_weight := NVL(rec.gross_weight,l_dd_net_wt);
            rec.net_weight   := NVL(rec.net_weight,l_dd_net_wt);
          ELSE
            rec.volume := NVL(rec.volume,l_dd_volume);
          END IF;

        END IF;

        IF (line_cont_rec.fill_pc_basis = 'W') THEN

          IF (NVL(rec.gross_weight,0) = 0) THEN
            --dbms_output.put_line('Weight is NULL or 0');
            FND_MESSAGE.SET_NAME('WSH', 'WSH_NULL_WEIGHT_VOLUME');
            FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL', rec.delivery_detail_id);
            WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
            error_cnt := error_cnt + 1;
            --dbms_output.put_line('Skipping this dd');
            goto next_detail;
          END IF;
        ELSE

          IF (NVL(rec.volume,0) = 0) THEN
            --dbms_output.put_line('Volume is NULL or 0');
            FND_MESSAGE.SET_NAME('WSH', 'WSH_NULL_WEIGHT_VOLUME');
            FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL', rec.delivery_detail_id);
            WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
            error_cnt := error_cnt + 1;
            --dbms_output.put_line('Skipping this dd');
            goto next_detail;
          END IF;
        END IF;

      END IF;

--dbms_output.put_line('Call to GET CONT LOAD VOL INFO 3');
      Get_Cont_Load_Vol_info(
         p_container_item_id => line_cont_rec.preferred_container,
         p_organization_id   => line_cont_rec.organization_id,
         p_w_v_both          => line_cont_rec.fill_pc_basis,
         x_max_load          => l_mtl_max_load,
         x_max_vol           => l_mtl_max_vol,
         x_wt_uom            => l_mtl_wt_uom,
         x_vol_uom           => l_mtl_vol_uom,
         x_return_status     => l_return_status,
         x_error_cnt         => l_error_cnt);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
      END IF;
      IF (l_return_status = C_ERROR_STATUS) THEN
        error_cnt := error_cnt + l_error_cnt;
      END IF;

      IF (line_cont_rec.fill_pc_basis = 'W') THEN
        IF (NVL(l_mtl_max_load,0) <= 0) THEN
          --dbms_output.put_line('Skipping this dd');
          goto next_detail;
         END IF;

        line_cont_rec.cont_wt := l_mtl_max_load;

        IF (l_mtl_wt_uom <> rec.weight_uom_code) THEN
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          l_dd_gross_wt :=  WSH_WV_UTILS.Convert_Uom (
                                from_uom => rec.weight_uom_code,
                                to_uom   => l_mtl_wt_uom,
                                quantity => rec.gross_weight,
                                item_id  => rec.inventory_item_id);
        ELSE
          l_dd_gross_wt := rec.gross_weight;
        END IF;
        line_cont_rec.converted_wt := l_dd_gross_wt;
        --dbms_output.put_line('line_cont_rec.converted_wt '||line_cont_rec.converted_wt);
      ELSE
        IF (NVL(l_mtl_max_vol,0) <= 0) THEN
          --dbms_output.put_line('Skipping this dd');
          goto next_detail;
         END IF;

        line_cont_rec.cont_vol := l_mtl_max_vol;

        IF (l_mtl_vol_uom <> rec.volume_uom_code) THEN
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          l_dd_volume :=  WSH_WV_UTILS.Convert_Uom (
                                from_uom => rec.volume_uom_code,
                                to_uom   => l_mtl_vol_uom,
                                quantity => rec.volume,
                                item_id  => rec.inventory_item_id);
        ELSE
          l_dd_volume := rec.volume;
        END IF;
        line_cont_rec.converted_vol := l_dd_volume;
        --dbms_output.put_line('line_cont_rec.converted_vol '||line_cont_rec.converted_vol);
      END IF;

      -- Check if the container can hold atleast 1 piece if the item is indivisible
      IF (line_cont_rec.indivisible_flag = 'Y' AND
          ((line_cont_rec.fill_pc_basis = 'W' AND ((line_cont_rec.converted_wt/line_cont_rec.shp_qty) > l_mtl_max_load)) OR
           (line_cont_rec.fill_pc_basis = 'V' AND ((line_cont_rec.converted_vol/line_cont_rec.shp_qty) > l_mtl_max_vol)))) THEN
        --dbms_output.put_line('Indivisible flag is Y and Preferred Cont cannot hold atleast 1 piece');
	-- Bug#: 2503937 - New Error Message
        FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_WT_VOL_ERROR');
        WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
        error_cnt := error_cnt + 1;
        --dbms_output.put_line('Skipping this dd');
        goto next_detail;
      END IF;

    END IF;



-- HW OPM BUG#: 3011758 For debugging purposes.
-- HW OPMCONV - 1) Removed all GMI print msgs

-- HW OPM BUG#:3011758 Check if OPM lot indivisible and check percent fill basis
-- If 'Q', compare the delivery line qty shipped against the max_load
-- If 'W, compare the delivery line net weight against the container's net weight
-- If 'V', compare the delivery line volume against the container's volume
-- If any of the above exceeds the max allowed, an error is raised
-- because it will not fit into the container without splitting
-- OPM item that are lot indivisible should not split

-- HW OPMCONV - 1) Renamed lot_divisible_flag
--            - 2) Changed checking value of visible flag from 1 to 'N'
   IF ( line_cont_rec.lot_divisible_flag = 'N' AND
        ((line_cont_rec.fill_pc_basis = 'Q' AND (line_cont_rec.shp_qty  > line_cont_rec.max_load_qty ))
      OR (line_cont_rec.fill_pc_basis = 'W' AND (l_dd_gross_wt > line_cont_rec.cont_wt) )
      OR (line_cont_rec.fill_pc_basis = 'V' AND (l_dd_volume> line_cont_rec.cont_vol) ) ) ) THEN

        FND_MESSAGE.SET_NAME('WSH','WSH_OPM_IND_SPLIT_PACK');
        FND_MESSAGE.SET_TOKEN('DETAIL_ID',rec.delivery_detail_id);
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(l_return_status);
        error_cnt := error_cnt + 1;
        goto next_detail;
    END IF;-- end of 3011758

    -- 20.70 Do Credit Check
    --dbms_output.put_line('Doing Credit Check');
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_CREDIT_HOLDS',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_DETAILS_VALIDATIONS.Check_Credit_Holds (
             p_detail_id        => rec.delivery_detail_id,
             p_activity_type    => 'PACK',
             p_source_line_id   => NULL,
             p_source_header_id => NULL,
             p_source_code      => rec.source_code,
             p_init_flag        => 'Y',
             x_return_status    => l_return_status);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
    END IF;
-- Bug 2847515
-- Error was being treated as warning
    IF l_return_status <> C_SUCCESS_STATUS THEN
      IF l_return_status IN (C_ERROR_STATUS,C_UNEXP_ERROR_STATUS) THEN
        error_cnt := error_cnt + 1;
      ELSIF l_return_status = C_WARNING_STATUS THEN
      --dbms_output.put_line('Credit Check Failed. Warning: Skipping dd');
        warn_cnt := warn_cnt + 1;
      END IF;
      goto next_detail;
    END IF;

    l_dd_count := l_dd_count + 1;
    line_cont_tab(l_dd_count) := line_cont_rec;

    <<next_detail>>
      null;

  END LOOP;

  DELETE FROM wsh_tmp;

  x_error_cnt        := error_cnt;
  x_warn_cnt         := warn_cnt;
  x_fill_pc_warn_cnt := fill_pc_warn_cnt; -- bug 3562797 jckwok
  x_release_warn_cnt := release_warn_cnt;
  x_line_cont_tab    := line_cont_tab;

  --dbms_output.put_line('Exiting Validate_Dd_for_Pack');

  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'p_del_detail_tab count->'||p_del_detail_tab.count||' x_line_cont_tab count->'||x_line_cont_tab.count);
    WSH_DEBUG_SV.log(l_module_name,'Error Count '|| x_error_cnt||' Warning Count '|| x_warn_cnt||' Release Warn Count '|| x_release_warn_cnt);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN Others THEN
    IF (Get_dd_Detail%ISOPEN) THEN
      CLOSE Get_dd_Detail;
    END IF;
    IF (Get_Cont_Item_Load%ISOPEN) THEN
      CLOSE Get_Cont_Item_Load;
    END IF;
    WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Validate_Dd_For_Pack',l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
    raise;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END Validate_Dd_For_Pack;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Auto_Pack_Lines
   PARAMETERS : p_group_id_tab_id - table of group ids for lines that need to
			be autopacked.
		p_del_detail_tab - table of delivery detail ids
		p_pack_cont_flag - 'Y' or 'N' to determine whether to try and
			autopack the detail containers into master containers.
		x_cont_instance_id - table of container instance ids that were
			created during the autopacking.
		x_pack_status - indicates whether containers overpacked or not
		x_return_status - return status of API.
  DESCRIPTION : This procedure takes the number of lines and groups them by
		common grouping attributes - similar to grouping attributes of
		delivery.  If a group id table is specified it uses the
		group ids in the table to decided which lines can be grouped
		into the same container. If a group id table is not specified,
		it creates the group id table before autopacking. It creates
		the required number and type of containers per line and keeps
		track of all partially filled containers in the empty
		containers table. Before creating new container instances, it
		searches for available space using the empty container table
		and after filling up a container, it creates a new one if
		there are no empty containers of the same type.
------------------------------------------------------------------------------
*/

PROCEDURE Auto_Pack_Lines (
  p_group_id_tab      IN     WSH_UTIL_CORE.id_tab_type,
  p_del_detail_tab    IN     WSH_UTIL_CORE.id_tab_type,
  p_pack_cont_flag    IN     VARCHAR2,
  x_cont_instance_tab IN OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
  x_return_status     OUT NOCOPY     VARCHAR2) IS

   CURSOR c_get_attributes(v_delivery_detail_id IN NUMBER) IS
    SELECT customer_id,ship_to_location_id,
           intmed_ship_to_location_id,
           fob_code,freight_terms_code,ship_method_code,
           mode_of_transport, carrier_id, service_level,
           deliver_to_location_id,
           NVL(line_direction,'O') line_direction,   -- J-IB-NPARIKH
           shipping_control,    -- J-IB-NPARIKH
           NVL(ignore_for_planning,'N') ignore_for_planning,
           client_id  -- LSP PROJECT
      FROM wsh_delivery_details
     WHERE delivery_detail_id = v_delivery_detail_id;

   -- OTM R12 : assign delivery detail
   CURSOR c_get_tare_weight(v_detail_id NUMBER) IS
   SELECT nvl(unit_weight, 0)
     FROM wsh_delivery_details
    WHERE delivery_detail_id = v_detail_id;

   CURSOR c_get_plan_and_tms_flag(v_delivery_id NUMBER) IS
   SELECT nvl(ignore_for_planning, 'N'),
          nvl(tms_interface_flag, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)
     FROM wsh_new_deliveries
    WHERE delivery_id = v_delivery_id;

   TYPE Boolean_Tab_Type IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;

   -- OTM R12 : assign delivery detail

   TYPE tab_varchar IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

   l_tab_cust_id wsh_util_core.id_tab_type;
   l_tab_ship_location_id wsh_util_core.id_tab_type;
   l_tab_intmed_location_id wsh_util_core.id_tab_type;
   l_tab_deliver_location_id wsh_util_core.id_tab_type;
   l_tab_carrier_id wsh_util_core.id_tab_type;
   l_tab_fob_code tab_varchar;
   l_tab_freight_terms_code tab_varchar;
   l_tab_ship_method_code tab_varchar;
   l_tab_mode_of_transport tab_varchar;
   l_tab_service_level tab_varchar;
   l_tab_line_direction tab_varchar;
   l_tab_shipping_control tab_varchar;
   l_tab_ignore_for_planning tab_varchar;
   --
   l_tab_client_id           wsh_util_core.id_tab_type; -- LSP PROJECT :
   --

  line_cont_tab line_cont_info_tab;

  l_group_id_temp_tab    WSH_UTIL_CORE.id_tab_type;
  l_group_id_tab    WSH_UTIL_CORE.id_tab_type;
  l_del_row_tab     WSH_UTIL_CORE.id_tab_type;
  l_mast_cont_tab   WSH_UTIL_CORE.id_tab_type;
  l_tmp_detail_tab  WSH_UTIL_CORE.id_tab_type;
  l_detail_cont_rec empty_cont_info;
  l_detail_cont_tab empty_cont_info_tab;

  l_return_status   VARCHAR2(1);
  l_cont_instance_id NUMBER;
  l_cont_name       VARCHAR2(30);
  l_row_id          VARCHAR2(30);
  l_pack_status     VARCHAR2(30);

  l_net_weight      NUMBER;
  l_cont_fill_pc    NUMBER;
  l_err_cont_name   VARCHAR2(30);
  l_last_organization_id NUMBER;

  i                 NUMBER;
  j                 NUMBER;
  cnt               NUMBER;
  l_cont_instance_cnt NUMBER;

  warn_cnt          NUMBER := 0;
  error_cnt         NUMBER := 0;
  succ_cnt          NUMBER := 0;
  cont_warn         NUMBER := 0;
  l_release_warn_count NUMBER := 0;
  l_fill_pc_warn_count NUMBER := 0; -- bug 3562797 jckwok
  l_error_cnt       NUMBER := 0;

  l_new_contid_count  NUMBER := 0;
  --l_cont_tab          wsh_container_actions.cont_inst_tab;
  l_cont_tab          WSH_UTIL_CORE.id_tab_type;

  TYPE NumList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE CharList IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
  l_GrossWtlist     NumList;
  l_NetWtlist       NumList;
  l_Vollist         NumList;
  l_ddlist          NumList;
  l_dellist         NumList; -- for delivery id
  l_contlist        NumList; -- containers for delivery detail id
  l_contlist1       NumList; -- containers and delivery id
  l_dellist1         NumList; -- containers and delivery id
  m                 NUMBER;
  l_del_tab         WSH_UTIL_CORE.id_tab_type;
  l_exists_flag     VARCHAR2(1);
  l_duplicate_flag     VARCHAR2(1);   -- for checking record

  -- J: W/V Changes
  l_prev_del_id   NUMBER;
  l_prev_dd_id    NUMBER;
  l_prev_cont_id  NUMBER;
  l_unit_weight   NUMBER;
  l_unit_volume   NUMBER;
  l_weight_uom_code VARCHAR2(3);
  l_volume_uom_code VARCHAR2(3);
  l_cont_Wtlist   NumList;
  l_cont_Vollist  NumList;
  l_WtUOMlist   CharList;
  l_VolUOMlist  CharList;
  l_InvItemlist  NumList;
  l_cont_InvItemlist  NumList;
  l_cont_WtUOMlist   CharList;
  l_cont_VolUOMlist  CharList;
  l_tot_dd_gross_wt NUMBER;
  l_tot_dd_net_wt NUMBER;
  l_tot_dd_vol    NUMBER;
/*
  l_tot_cont_gross_wt NUMBER;
  l_tot_cont_vol  NUMBER;
*/
  l_tot_del_vol   NUMBER;
  TYPE del_wv_adjust_info IS RECORD (
        dd_id   NUMBER,
        gross_wt       NUMBER,
        net_wt         NUMBER,
        vol            NUMBER);
  TYPE del_wv_adjust_tab IS TABLE OF del_wv_adjust_info INDEX BY BINARY_INTEGER;
  l_tmp_dd1list del_wv_adjust_tab;
  l_tmp_dd2list del_wv_adjust_tab;
  del_index       NUMBER;
  i1 NUMBER := 0;
  j1 NUMBER := 0;
  k1 NUMBER := 0;
  l_prev_wt_uom VARCHAR2(3);
  l_prev_vol_uom VARCHAR2(3);
  l_item_changed BOOLEAN;
  l_cont_item_changed BOOLEAN;
  l_prev_item NUMBER;

  l_attr_tab  wsh_delivery_autocreate.grp_attr_tab_type;
  l_group_tab  wsh_delivery_autocreate.grp_attr_tab_type;
  l_action_rec wsh_delivery_autocreate.action_rec_type;
  l_target_rec wsh_delivery_autocreate.grp_attr_rec_type;
  l_matched_entities wsh_util_core.id_tab_type;
  l_out_rec wsh_delivery_autocreate.out_rec_type;

  mark_reprice_error EXCEPTION;

  -- OTM R12 : assign delivery detail
  l_gc3_is_installed         VARCHAR2(1);
  l_is_delivery_empty        VARCHAR2(1);
  l_index                    NUMBER;
  l_index_update             NUMBER;
  l_tare_weight              WSH_DELIVERY_DETAILS.UNIT_WEIGHT%TYPE;
  l_ignore_for_planning_tab  WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_tms_interface_flag_tab   WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_delivery_was_empty_tab   BOOLEAN_TAB_TYPE;
  l_delivery_id_tab          WSH_UTIL_CORE.ID_TAB_TYPE;
  l_interface_flag_tab       WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  -- End of OTM R12 : assign delivery detail

-- K LPN CONV. rv
l_wms_org    VARCHAR2(10) := 'N';
l_sync_tmp_wms_ddlist wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
l_sync_tmp_inv_ddlist wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
l_wms_ddtlist_cnt NUMBER;
l_inv_ddtlist_cnt NUMBER;
l_sync_tmp_wms_contlist wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
l_sync_tmp_inv_contlist wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
l_wms_contlist_cnt NUMBER;
l_inv_contlist_cnt NUMBER;
l_sync_tmp_wms_contlist1 wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
l_sync_tmp_inv_contlist1 wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
l_wms_contlist1_cnt NUMBER;
l_inv_contlist1_cnt NUMBER;
-- K LPN CONV. rv
l_mdc_id_tab wsh_util_core.id_tab_type;
l_mdc_index_i NUMBER;
l_mdc_index_j NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTO_PACK_LINES';
--
BEGIN

  --dbms_output.put_line('==================================================');
  --dbms_output.put_line('   AUTO  PACK  LINES                              ');
  --dbms_output.put_line('==================================================');

  --dbms_output.put_line('Start of WSH_CONTAINER_ACTIONS.Auto_Pack_Lines...');
  -- Delete all Global PL/SQL tables to start with
  --
  --

  -- OTM R12 : assign delivery detail
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  IF (l_gc3_is_installed IS NULL) THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;

  -- End of OTM R12 : assign delivery detail

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
      WSH_DEBUG_SV.log(l_module_name,'P_PACK_CONT_FLAG',P_PACK_CONT_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'l_gc3_is_installed', l_gc3_is_installed);                        -- OTM R12 : assign delivery detail
  END IF;
  --
  g_empty_cont_tab.DELETE;
  g_assign_detail_tab.DELETE;
  g_new_container_tab.DELETE;
  g_cache_organization_info_tab.DELETE;
  g_cont_msi_tab.DELETE;
  g_new_contid_tab.DELETE;
  g_new_cont_index := 0;
  g_num_cont_index := 0;
  g_assign_detail_index := 0;

  -- 10. Check if Count of p_del_detail_tab table is 0
  IF p_del_detail_tab.count = 0 THEN
    --dbms_output.put_line('p_del_detail_tab count is 0');
    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_ASSG_NULL');
    x_return_status := C_ERROR_STATUS;
    WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
  END IF;
--dbms_output.put_line('Before Autocreate Del'||to_char(sysdate,'HH24:MI:SS'));
  -- 20. Generate Grouping Ids
  IF p_group_id_tab.COUNT = 0 THEN

    -- call autocreate delivery API with a check flag set to 'Y' and
    -- container flag set to 'Y' to fetch group id table for delivery lines

    --dbms_output.put_line('Calling WSH_DELIVERY_AUTOCREATE.autocreate_deliveries to generate group_ids');
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.AUTOCREATE_DELIVERIES',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --

   l_attr_tab.delete;

   FOR i in 1..p_del_detail_tab.count LOOP

       l_attr_tab(i).entity_id := p_del_detail_tab(i);
       l_attr_tab(i).entity_type := 'DELIVERY_DETAIL';

   END LOOP;

   l_action_rec.action := 'MATCH_GROUPS';



   WSH_Delivery_AutoCreate.Find_Matching_Groups(p_attr_tab => l_attr_tab,
                                                   p_action_rec => l_action_rec,
                                                   p_target_rec => l_target_rec,
                                                   p_group_tab => l_group_tab,
                                                   x_matched_entities => l_matched_entities,
                                                   x_out_rec => l_out_rec,
                                                   x_return_status => l_return_status);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
    END IF;
    IF (l_return_status = C_ERROR_STATUS) OR
       (l_return_status = C_UNEXP_ERROR_STATUS) THEN
      --dbms_output.put_line('***WSH_DELIVERY_AUTOCREATE.autocreate_deliveries returned '||l_return_status);
      FND_MESSAGE.SET_NAME('WSH','WSH_GROUP_DETAILS_ERROR');
      WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
      x_return_status := l_return_status;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
    END IF;
    FOR i in 1..l_attr_tab.COUNT LOOP
      l_group_id_tab(l_attr_tab(i).entity_id) := l_attr_tab(i).group_id;
    END LOOP;
  ELSE
    cnt := p_group_id_tab.FIRST;

    IF ((cnt IS NULL) OR (p_group_id_tab.COUNT <> p_del_detail_tab.count)) THEN
      x_return_status := C_ERROR_STATUS;
      FND_MESSAGE.SET_NAME('WSH','WSH_GROUP_DETAILS_ERROR');
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
    ELSE

      FOR i in 1..p_group_id_tab.COUNT LOOP
        l_group_id_tab(p_del_detail_tab(i)) := p_group_id_tab(i);
      END LOOP;

    END IF;
  END IF;


--dbms_output.put_line('Before Validate DD for Pack'||to_char(sysdate,'HH24:MI:SS'));
  Validate_Dd_for_Pack(
    p_group_id_tab     => l_group_id_tab,
    p_del_detail_tab   => p_del_detail_tab,
    x_line_cont_tab    => line_cont_tab,
    x_error_cnt        => error_cnt,
    x_warn_cnt         => warn_cnt,
    x_fill_pc_warn_cnt => l_fill_pc_warn_count, -- bug 3562797 jckwok
    x_release_warn_cnt => l_release_warn_count);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
      WSH_DEBUG_SV.log(l_module_name,'line cont tab count -',line_cont_tab.count);
    END IF;
  --dbms_output.put_line(p_del_detail_tab.count||'<CALL TO VALIDATE DD FOR PACK>'||l_release_warn_count||'>'||line_cont_tab.count);

  -- Raise warning if we found some delivery details with status 'S'
  -- Raise Error if all lines are with status 'S'
  IF (l_release_warn_count = p_del_detail_tab.count) THEN
    x_return_status := C_ERROR_STATUS;
    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_RELEASED_STATUS');
    WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
    -- Bug 3337629 : Added the following return statement.
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  ELSIF (l_release_warn_count > 0) THEN
    -- Bug 3337629 - x_return_status does not hold any value.
    -- Compare it with l_return_status.
    -- Also increment the warn_cnt.

    --IF (x_return_status <> C_ERROR_STATUS) THEN
    IF (l_return_status <> C_ERROR_STATUS) THEN
      x_return_status := C_WARNING_STATUS;
      warn_cnt := warn_cnt + 1;
      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_REL_STATUS_WARN');
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
    END IF;
  END IF;
  --
  -- bug 3562797 jckwok
  -- Raise Error if all dds have 'Shipping Parameter' percent fill basis as None
  -- Raise warning if only some of the dds have 'Shipping Parameter' percent fill basis as None
  --
  IF (l_fill_pc_warn_count = p_del_detail_tab.count) THEN
    x_return_status := C_ERROR_STATUS;
    FND_MESSAGE.SET_NAME('WSH','WSH_FILL_BASIS_NONE');
    WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  ELSIF (l_fill_pc_warn_count > 0) THEN
    IF (l_return_status <> C_ERROR_STATUS) THEN
      x_return_status := C_WARNING_STATUS;
      warn_cnt := warn_cnt + 1;
      FND_MESSAGE.SET_NAME('WSH','WSH_FILL_BASIS_NONE');
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
    END IF;
  END IF;
  -- end of bug 3562797 jckwok

--dbms_output.put_line('Before 50'||to_char(sysdate,'HH24:MI:SS'));
  IF (line_cont_tab.COUNT > 0) THEN
    -- 50. Loop through all lines that need to be Auto-Packed
    cnt := 1;
    l_last_organization_id := NULL;
    WHILE (cnt <= line_cont_tab.COUNT) LOOP

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'======================================================');
        WSH_DEBUG_SV.log(l_module_name,'auto-packing line ' || line_cont_tab(cnt).delivery_detail_id||'Org id'||line_cont_tab(cnt).organization_id);
      END IF;

      IF (l_last_organization_id is NULL) THEN
        l_last_organization_id := line_cont_tab(cnt).organization_id;
      ELSIF (l_last_organization_id <> line_cont_tab(cnt).organization_id) THEN
        l_last_organization_id := line_cont_tab(cnt).organization_id;

        -- Delete the empty PL/SQL cont table if organization_id changes
        g_empty_cont_tab.DELETE;
      END IF;

      Pack_Delivery_Detail(
         p_line_cont_rec => line_cont_tab(cnt),
         x_return_status => l_return_status);
 -- Bug  2786021 handle unexpected error
      IF (l_return_status = C_ERROR_STATUS OR
          l_return_status = C_UNEXP_ERROR_STATUS
         ) THEN
       error_cnt := error_cnt + 1;
      ELSE
       succ_cnt := succ_cnt + 1;
      END IF;
      cnt := cnt + 1;

    END LOOP;
--dbms_output.put_line('Error Count '|| error_cnt||' Success Count '||succ_cnt);
--dbms_output.put_line('Before Create'||to_char(sysdate,'HH24:MI:SS')||'g_new_container_tab.count'||g_new_container_tab.COUNT);

    -- 60.1 Create Containers from g_new_container_tab PL/SQL table
    --dbms_output.put_line('*** Creating Actual Containers ***');
    cnt := 1;
    l_cont_instance_cnt := 1;
    WHILE (cnt <= g_new_container_tab.COUNT) LOOP
      l_cont_name := null;

      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.CREATE_CONT_INSTANCE_MULTI',WSH_DEBUG_SV.C_PROC_LEVEL);
          WSH_DEBUG_SV.logmsg(l_module_name,'Number of Containers'||g_new_container_tab(cnt).number_of_containers);
          WSH_DEBUG_SV.log(l_module_name,'Create Container'||g_new_container_tab(cnt).container_item_id||'<'||g_new_container_tab(cnt).organization_id||'>'||g_new_container_tab(cnt).number_of_containers);
      END IF;
      --
      wsh_container_actions.Create_Cont_Instance_Multi (
               x_cont_name           => l_cont_name,
               p_cont_item_id        => g_new_container_tab(cnt).container_item_id,
               x_cont_instance_id    => l_cont_instance_id,
               p_par_detail_id       => NULL,
               p_organization_id     => g_new_container_tab(cnt).organization_id,
               p_container_type_code => NULL,
               p_num_of_containers   => g_new_container_tab(cnt).number_of_containers,
               x_row_id              => l_row_id,
               x_return_status       => l_return_status,
               x_cont_tab            => l_cont_tab,
               -- J: W/V Changes
               x_unit_weight         => l_unit_weight,
               x_unit_volume         => l_unit_volume,
               x_weight_uom_code     => l_weight_uom_code,
               x_volume_uom_code     => l_volume_uom_code,
               p_lpn_id              => NULL,
               p_ignore_for_planning => NULL,
               p_caller              => 'WSH'
               );
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status ,cont tab count -',l_return_status||l_cont_tab.count);
      END IF;

      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
        ) THEN
        --dbms_output.put_line('Container Creation failed for index '|| cnt);
        FND_MESSAGE.SET_NAME('WSH','WSH_CONT_CREATE_ERROR');
        WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
        error_cnt := error_cnt + 1;
      ELSE

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Created Containers'||l_cont_tab.count);
        END IF;
-- do not use this container instance id
        g_new_container_tab(cnt).cont_instance_id := l_cont_instance_id;

-- This new PL SQL table will have mapping records to g_new_container_tab
-- where count of g_new_container_tab will have records here
-- Example if l_new_contid_count is 1 and in g_new_container_tab, the
-- number of containers is 10, then those 10 container instance id can be
-- extracted from this new PL SQL table
        IF l_new_contid_count IS NULL THEN
          l_new_contid_count := 0;
        ELSE
          l_new_contid_count := g_new_contid_tab.count;
        END IF;

-- can replace l_new_contid_count with g_new_contid_tab.count
        FOR j in 1..l_cont_tab.count
        LOOP
          l_new_contid_count := l_new_contid_count + 1;
          g_new_contid_tab(l_new_contid_count).match_id := cnt;
          g_new_contid_tab(l_new_contid_count).cont_instance_id := l_cont_tab(j);
          -- J: W/V Changes
          g_new_contid_tab(l_new_contid_count).unit_weight := l_unit_weight;
          g_new_contid_tab(l_new_contid_count).unit_volume := l_unit_volume;
          g_new_contid_tab(l_new_contid_count).weight_uom := l_weight_uom_code;
          g_new_contid_tab(l_new_contid_count).volume_uom := l_volume_uom_code;
          g_new_contid_tab(l_new_contid_count).item_id := g_new_container_tab(cnt).container_item_id;

          -- K LPN CONV. rv
          g_new_contid_tab(l_new_contid_count).organization_id := g_new_container_tab(cnt).organization_id;

          x_cont_instance_tab(l_new_contid_count) := l_cont_tab(j);
          -- Bug 3570364 : Adding the Master container item id of the line to all it's
	  --               container LPN's. This information is passed to Auto_pack_conts.
	  l_detail_cont_rec.container_instance_id := l_cont_tab(j);
          l_detail_cont_rec.container_item_id     := g_new_container_tab(cnt).mast_cont_item_id;
          l_detail_cont_tab(l_new_contid_count)  := l_detail_cont_rec;

          --g_new_contid_tab(l_new_contid_count).cont_instance_id := l_cont_tab(j).cont_instance_id;
          --x_cont_instance_tab(l_new_contid_count) := l_cont_tab(j).cont_instance_id;
        END LOOP;

--dbms_output.put_line('COUNT in new tab'||g_new_contid_tab.count||'<'||x_cont_instance_tab.count);

-- End of PL SQL table usage
 -- move this call of x_cont_instance_tab to within the above LOOP
        --x_cont_instance_tab(l_cont_instance_cnt)    := l_cont_instance_id;

        -- Bug  3570364 : Move following stmt's to within the above LOOP
	--                which stores the master container item id for each LPN
       /*{ l_detail_cont_rec.container_instance_id := l_cont_instance_id;
        l_detail_cont_rec.container_item_id     := g_new_container_tab(cnt).mast_cont_item_id;
        l_detail_cont_tab(l_cont_instance_cnt)  := l_detail_cont_rec;
        l_cont_instance_cnt := l_cont_instance_cnt + 1; } */

        --dbms_output.put_line('Container dd id '||l_cont_instance_id||' for index '|| cnt);
      END IF;
      cnt := cnt + 1;
    END LOOP;
    --dbms_output.put_line('Error Count after CREATE CONTAINER'|| error_cnt);


    -- 70.1 Assign Details to Actual Containers created
    IF l_debug_on THEN

     WSH_DEBUG_SV.log(l_module_name,'*** Assigning Details to Containers Created ***'||g_assign_detail_tab.count);
     WSH_DEBUG_SV.log(l_module_name,'*** COUNT ***'||g_new_contid_tab.count||'<'||g_new_container_tab.count||to_char(sysdate,'HH24:MI:SS'));
    END IF;

-- doing BULK UPDATE here
-- First Update WDA for each delivey detail to have parent_delivery_detail populated
-- correctly

    m := 0;
    l_wms_ddtlist_cnt :=1;
    l_inv_ddtlist_cnt :=1;
    FOR cnt in 1..g_assign_detail_tab.COUNT
    LOOP
      l_GrossWtlist(cnt) := g_assign_detail_tab(cnt).gross_weight;
      l_NetWtlist(cnt) := g_assign_detail_tab(cnt).net_weight;
      l_WtUOMlist(cnt) := g_assign_detail_tab(cnt).weight_uom;
      l_Vollist(cnt) := g_assign_detail_tab(cnt).volume;
      l_VolUOMlist(cnt) := g_assign_detail_tab(cnt).volume_uom;
      l_InvItemlist(cnt) :=  g_assign_detail_tab(cnt).inventory_item_id;
      l_ddlist(cnt) := g_assign_detail_tab(cnt).delivery_detail_id;
      l_dellist(cnt) := g_assign_detail_tab(cnt).delivery_id;
      l_wms_org := 'N';
      -- K LPN CONV. rv
      IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y' THEN
      --{
          l_wms_org := wsh_util_validate.check_wms_org(g_assign_detail_tab(cnt).organization_id);
          IF (l_wms_org = 'Y') THEN
            l_sync_tmp_wms_ddlist.delivery_detail_id_tbl(l_wms_ddtlist_cnt) := g_assign_detail_tab(cnt).delivery_detail_id;
            l_sync_tmp_wms_ddlist.delivery_id_tbl(l_wms_ddtlist_cnt) := g_assign_detail_tab(cnt).delivery_id;
            l_sync_tmp_wms_ddlist.parent_detail_id_tbl(l_wms_ddtlist_cnt) := NULL;
            l_sync_tmp_wms_ddlist.operation_type_tbl(l_wms_ddtlist_cnt) := 'PRIOR';
            l_wms_ddtlist_cnt := l_wms_ddtlist_cnt + 1;
          ELSE
            l_sync_tmp_inv_ddlist.delivery_detail_id_tbl(l_inv_ddtlist_cnt) := g_assign_detail_tab(cnt).delivery_detail_id;
            l_sync_tmp_inv_ddlist.delivery_id_tbl(l_inv_ddtlist_cnt) := g_assign_detail_tab(cnt).delivery_id;
            l_sync_tmp_inv_ddlist.parent_detail_id_tbl(l_inv_ddtlist_cnt) := NULL;
            l_sync_tmp_inv_ddlist.operation_type_tbl(l_inv_ddtlist_cnt) := 'PRIOR';
            l_inv_ddtlist_cnt := l_inv_ddtlist_cnt + 1;
          END IF;
      --}
      END IF;
      -- K LPN CONV. rv
    IF l_dellist(cnt) IS NOT NULL THEN
-- no check for distinct was there earlier, added the check
      IF l_del_tab.count > 0 THEN
        FOR j in 1..l_del_tab.COUNT
        LOOP
          IF (l_dellist(cnt) IS NOT NULL
             AND l_dellist(cnt) = l_del_tab(j)
            ) THEN

            l_exists_flag := 'Y';
            EXIT;
          ELSE
            l_exists_flag := 'N';

          END IF;
        END LOOP;
      ELSE
        l_exists_flag := 'N';
      END IF;

      IF l_exists_flag = 'N' THEN
         m := m + 1;
         l_del_tab(m) := l_dellist(cnt);
      END IF;
    END IF;
    END LOOP;
-- the number of records should be same
-- when Empty Container logic is used, then there can be a record in
-- assign table with no one to one mapping in new container table
-- so use container index to find that container

    m := 0;
    -- K LPN CONV. rv
    l_wms_contlist_cnt := 1;
    l_inv_contlist_cnt := 1;

    l_wms_contlist1_cnt := 1;
    l_inv_contlist1_cnt := 1;
    -- K LPN CONV. rv
    FOR cnt in 1..g_assign_detail_tab.COUNT
    LOOP

      l_contlist(cnt) :=
        g_new_contid_tab(g_assign_detail_tab(cnt).container_index).cont_instance_id;
      -- K LPN CONV. rv
      IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y' THEN
      --{
          l_wms_org := 'N';
          l_wms_org := wsh_util_validate.check_wms_org(g_new_contid_tab(g_assign_detail_tab(cnt).container_index).organization_id);
          IF (l_wms_org = 'Y') THEN
            l_sync_tmp_wms_contlist.delivery_detail_id_tbl(l_wms_contlist_cnt) := l_contlist(cnt);
            l_sync_tmp_wms_contlist.operation_type_tbl(l_wms_contlist_cnt) := 'UPDATE';
            l_wms_contlist_cnt :=  l_wms_contlist_cnt + 1;
          ELSE
            l_sync_tmp_inv_contlist.delivery_detail_id_tbl(l_inv_contlist_cnt) := l_contlist(cnt);
            l_sync_tmp_inv_contlist.operation_type_tbl(l_inv_contlist_cnt) := 'UPDATE';
            l_inv_contlist_cnt :=  l_inv_contlist_cnt + 1;
          END IF;
      --}
      END IF;
      -- K LPN CONV. rv

      IF ((cnt = 1)
          OR
          (cnt > 1
             AND l_contlist1(m) <>
                 g_new_contid_tab(g_assign_detail_tab(cnt).container_index).cont_instance_id)
         )THEN

         IF l_contlist1.count > 0 THEN
           FOR j in l_contlist1.FIRST..l_contlist1.LAST
           LOOP
             IF l_contlist1(j) =
                  g_new_contid_tab(g_assign_detail_tab(cnt).container_index).cont_instance_id
             THEN
               l_duplicate_flag := 'Y';
               EXIT;  -- out of the loop
             ELSE
               l_duplicate_flag := 'N';
             END IF;
           END LOOP;
         ELSE
           l_duplicate_flag := 'N';
         END IF;
         IF l_duplicate_flag = 'N' THEN
           m := m + 1;
           l_contlist1(m) :=
             g_new_contid_tab(g_assign_detail_tab(cnt).container_index).cont_instance_id;
           -- J: W/V Changes
           l_cont_Wtlist(m) :=
             g_new_contid_tab(g_assign_detail_tab(cnt).container_index).unit_weight;
           l_cont_Vollist(m) :=
             g_new_contid_tab(g_assign_detail_tab(cnt).container_index).unit_volume;
           l_dellist1(m) := g_assign_detail_tab(cnt).delivery_id;
           -- K LPN CONV. rv
           IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y' THEN
           --{
               IF (l_wms_org = 'Y') THEN
                 l_sync_tmp_wms_contlist1.delivery_detail_id_tbl(l_wms_contlist1_cnt) := l_contlist1(m);
                 l_sync_tmp_wms_contlist1.delivery_id_tbl(l_wms_contlist1_cnt) := NULL;
                 l_sync_tmp_wms_contlist1.parent_detail_id_tbl(l_wms_contlist1_cnt) := NULL;
                 l_sync_tmp_wms_contlist1.operation_type_tbl(l_wms_contlist1_cnt) := 'PRIOR';
                 l_wms_contlist1_cnt := l_wms_contlist1_cnt + 1;
               ELSE
                 l_sync_tmp_inv_contlist1.delivery_detail_id_tbl(l_inv_contlist1_cnt) := l_contlist1(m);
                 l_sync_tmp_inv_contlist1.delivery_id_tbl(l_inv_contlist1_cnt) := NULL;
                 l_sync_tmp_inv_contlist1.parent_detail_id_tbl(l_inv_contlist1_cnt) := NULL;
                 l_sync_tmp_inv_contlist1.operation_type_tbl(l_inv_contlist1_cnt) := 'PRIOR';
                 l_inv_contlist1_cnt := l_inv_contlist1_cnt + 1;
               END IF;
           --}
           END IF;
           -- K LPN CONV. rv
         END IF;
      END IF;
    END LOOP; -- g_assign_detail_tab Loop

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Count-g_assign_detail_tab'||g_assign_detail_tab.COUNT);
      WSH_DEBUG_SV.logmsg(l_module_name,'Count-l_contlist'||l_contlist.COUNT);
      WSH_DEBUG_SV.logmsg(l_module_name,'Count-l_dellist>'||l_dellist.COUNT);
      WSH_DEBUG_SV.logmsg(l_module_name,'Count-g_new_contid>'||g_new_contid_tab.COUNT);
      WSH_DEBUG_SV.logmsg(l_module_name,'Count-l_contlist1>'||l_contlist1.COUNT);
      WSH_DEBUG_SV.logmsg(l_module_name,'Count-l_dellist1>'||l_dellist1.COUNT);
    END IF;

-- J: W/V Changes
    -- 70.2 Accumulate the W/V to be adjusted by delivery and container for perf reasons. After the following loop
    --      l_tmp_dd1list will have W/V that needs to be reduced from deliveries (if the lines are already assigned to a delivery)
    --      l_tmp_dd2list will have W/V that needs to be propogated to container only.
    -- The W/V is accumulated and stored in the above tables whenever item,W/V uom change in container and delivery
    -- For Ex: Say a dd with Wt 10 Lbs and Vol 20 Cu. Ft is assigned to a delivery (which has Wt 10 Lbs and Vol 20 Cu. Ft)
    --         and say the line got auto-packed into a container with tare wt. 2 Lbs and Vol. 100 Cu. Ft
    --         Then after the following loop, l_tmp_dd1list will have dd with vol -20. l_tmp_dd2list will have
    --         gross wt. 10 Lbs and Vol 20 Cu. Ft.

    IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'before W/V adjustment '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;
    l_prev_del_id := NULL;
    l_prev_dd_id := NULL;
    l_prev_cont_id := NULL;
    l_tot_dd_gross_wt := 0;
    l_tot_dd_net_wt := 0;
    l_tot_dd_vol    := 0;
    l_tot_del_vol   := 0;
    i := 0;
    l_item_changed := FALSE;

    LOOP
      i := i + 1;

      IF l_debug_on THEN
        IF i <= l_dellist.COUNT THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Del '||l_dellist(i)||' Cont '||l_contlist(i)||' DD '||l_ddlist(i)||' l_prev_dd_id '||l_prev_dd_id||' l_prev_cont_id '||l_prev_cont_id||' l_prev_del_id '||l_prev_del_id);
        END IF;
      END IF;

      IF (i > l_dellist.COUNT OR l_contlist(i) is NOT NULL) THEN

        IF (i > 1) AND (i <= l_dellist.COUNT) THEN
          IF (l_prev_item <> l_InvItemlist(i)) OR
             (NVL(l_prev_wt_uom,'-99') <> NVL(l_WtUOMlist(i),'-99')) OR
             (NVL(l_prev_vol_uom,'-99') <> NVL(l_VolUOMlist(i),'-99')) THEN
             l_item_changed := TRUE;
          END IF;

        END IF;

        IF (i > l_dellist.COUNT) OR
           (l_prev_del_id is NOT NULL AND (NVL(l_dellist(i),-99) <> l_prev_del_id)) OR
           l_item_changed THEN
          i1 := i1 + 1;
          l_tmp_dd1list(i1).dd_id := l_prev_dd_id;
          l_tmp_dd1list(i1).vol   := -1 * l_tot_del_vol;
          l_tot_del_vol := 0;
        END IF;

        IF i > l_dellist.COUNT OR
           (l_prev_cont_id is NOT NULL AND (l_contlist(i) <> l_prev_cont_id)) OR
           l_item_changed THEN

          k1 := k1 + 1;
          l_tmp_dd2list(k1).dd_id    := l_prev_dd_id;
          l_tmp_dd2list(k1).gross_wt := l_tot_dd_gross_wt;
          l_tmp_dd2list(k1).net_wt   := l_tot_dd_net_wt;
          l_tmp_dd2list(k1).vol      := l_tot_dd_vol;

          l_tot_dd_gross_wt := 0;
          l_tot_dd_net_wt   := 0;
          l_tot_dd_vol      := 0;
        END IF;

        IF i > l_dellist.COUNT THEN
          EXIT;
        END IF;

        l_tot_dd_gross_wt := l_tot_dd_gross_wt + NVL(l_GrossWtlist(i),0);
        l_tot_dd_net_wt := l_tot_dd_net_wt + NVL(l_NetWtlist(i),0);
        l_tot_dd_vol    := l_tot_dd_vol    + NVL(l_Vollist(i),0);
        IF l_dellist(i) is not null THEN
          l_tot_del_vol   := l_tot_del_vol   + NVL(l_Vollist(i),0);
        END IF;
        l_prev_dd_id := l_ddlist(i);
        l_prev_cont_id := l_contlist(i);
        l_prev_wt_uom := l_WtUOMlist(i);
        l_prev_vol_uom := l_VolUOMlist(i);
        l_prev_item := l_InvItemlist(i);
        l_prev_del_id := l_dellist(i);

      END IF;
    END LOOP;
    IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'after W/V adjustment '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
     --WSH_DEBUG_SV.log(l_module_name,'l_tmp_dd1list.COUNT '||l_tmp_dd1list.COUNT||' l_tmp_dd2list.COUNT '||l_tmp_dd2list.COUNT||' l_tmp_contlist.COUNT '||l_tmp_contlist.COUNT);
     WSH_DEBUG_SV.log(l_module_name,'l_tmp_dd1list.COUNT '||l_tmp_dd1list.COUNT||' l_tmp_dd2list.COUNT '||l_tmp_dd2list.COUNT);
     WSH_DEBUG_SV.log(l_module_name,'before W/V adjustment 1 '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;

-- J: W/V Changes
   FOR i in 1..l_tmp_dd1list.COUNT LOOP
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Del1:Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     WSH_WV_UTILS.DD_WV_Post_Process(
       p_delivery_detail_id => l_tmp_dd1list(i).dd_id,
       p_diff_gross_wt      => l_tmp_dd1list(i).gross_wt,
       p_diff_net_wt        => NULL,
       p_diff_volume        => l_tmp_dd1list(i).vol,
       p_diff_fill_volume   => l_tmp_dd1list(i).vol,
       x_return_status      => l_return_status);

     IF (l_return_status <> C_SUCCESS_STATUS) THEN
       --
       IF (l_return_status = C_ERROR_STATUS OR
           l_return_status = C_UNEXP_ERROR_STATUS) THEN
         error_cnt := error_cnt + 1;
       ELSE
         cont_warn := cont_warn + 1;
       END IF;

     END IF;
   END LOOP;
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'after W/V adjustment 1 '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
   END IF;

-- changes to add l_dellist1 and add new messages
    --
    -- K LPN CONV. rv
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    THEN
    --{
        IF (WSH_WMS_LPN_GRP.GK_WMS_PACK and l_sync_tmp_wms_ddlist.delivery_detail_id_tbl.count > 0)
        THEN
        --{
            WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
              (
                p_sync_tmp_recTbl   => l_sync_tmp_wms_ddlist,
                x_return_status     => l_return_status
              );

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_WMS_SYNC_TMP_PKG.MERGE',l_return_status);
            END IF;
            --
            IF l_return_status IN (C_UNEXP_ERROR_STATUS, C_ERROR_STATUS) THEN
              x_return_status := l_return_status;
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Error occured in WSH_WMS_SYNC_TMP_PKG.MERGE_BULK');
                  WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              RETURN;
            ELSE
              IF l_return_status <> C_SUCCESS_STATUS THEN
                x_return_status := C_WARNING_STATUS;
              END IF;
            END IF;
        --}
        ELSIF (WSH_WMS_LPN_GRP.GK_INV_PACK and l_sync_tmp_inv_ddlist.delivery_detail_id_tbl.count > 0)
        THEN
        --{
            WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
              (
                p_sync_tmp_recTbl   => l_sync_tmp_inv_ddlist,
                x_return_status     => l_return_status
              );

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_WMS_SYNC_TMP_PKG.MERGE',l_return_status);
            END IF;
            --
            IF l_return_status IN (C_UNEXP_ERROR_STATUS, C_ERROR_STATUS) THEN
              x_return_status := l_return_status;
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Error occured in WSH_WMS_SYNC_TMP_PKG.MERGE_BULK');
                  WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              RETURN;
            ELSE
              IF l_return_status <> C_SUCCESS_STATUS THEN
                x_return_status := C_WARNING_STATUS;
              END IF;
            END IF;
        --}
        END IF;
    --}
    END IF;
    -- K LPN CONV. rv

    FORALL cnt IN 1..g_assign_detail_tab.COUNT
      UPDATE wsh_delivery_assignments_v
      SET    PARENT_DELIVERY_DETAIL_ID = l_contlist(cnt),
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.USER_ID,
             last_update_login = FND_GLOBAL.LOGIN_ID
      WHERE  DELIVERY_DETAIL_ID = l_ddlist(cnt);
    l_mdc_id_tab.delete;
    l_mdc_index_i := l_ddlist.FIRST;
    l_mdc_index_j := 0;
    WHILE l_mdc_index_i IS NOT NULL LOOP
       l_mdc_index_j := l_mdc_index_j + 1;
       l_mdc_id_tab(l_mdc_index_j) := l_ddlist(l_mdc_index_i);
       l_mdc_index_i := l_ddlist.next(l_mdc_index_i);

    END LOOP;
    WSH_DELIVERY_DETAILS_ACTIONS.Delete_Consol_Record(
                   p_detail_id_tab     => l_mdc_id_tab,
                   x_return_status     => x_return_status);

    IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         RETURN;
   END IF;


-- J: W/V Changes
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'before W/V adjustment 2 '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
   END IF;
   FOR i in 1..l_tmp_dd2list.COUNT LOOP
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Del2:Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     WSH_WV_UTILS.DD_WV_Post_Process(
       p_delivery_detail_id => l_tmp_dd2list(i).dd_id,
       p_diff_gross_wt      => l_tmp_dd2list(i).gross_wt,
       p_diff_net_wt        => l_tmp_dd2list(i).net_wt,
       p_diff_volume        => l_tmp_dd2list(i).vol,
       p_diff_fill_volume   => l_tmp_dd2list(i).vol,
       x_return_status      => l_return_status);

     IF (l_return_status <> C_SUCCESS_STATUS) THEN
       --
       IF (l_return_status = C_ERROR_STATUS OR
           l_return_status = C_UNEXP_ERROR_STATUS) THEN
         error_cnt := error_cnt + 1;
       ELSE
         cont_warn := cont_warn + 1;
       END IF;

     END IF;
   END LOOP;
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'after W/V adjustment 2 '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
   END IF;

-- fetch all the attributes for the delivery line
    cnt := 0;
    FOR i in 1..l_ddlist.count
    LOOP
-- the inner loop will process one record at a time
      FOR rec in c_get_attributes(l_ddlist(i))
      LOOP
      cnt := cnt + 1;
      l_tab_cust_id(cnt) := rec.customer_id;
      l_tab_ship_location_id(cnt) := rec.ship_to_location_id;
      l_tab_intmed_location_id(cnt) := rec.intmed_ship_to_location_id;
      l_tab_fob_code(cnt) := rec.fob_code;
      l_tab_freight_terms_code(cnt) := rec.freight_terms_code;
      l_tab_ship_method_code(cnt) := rec.ship_method_code;
      l_tab_carrier_id(cnt) := rec.carrier_id;
      l_tab_mode_of_transport(cnt) := rec.mode_of_transport;
      l_tab_service_level(cnt) := rec.service_level;
      l_tab_deliver_location_id(cnt) := rec.deliver_to_location_id;
      l_tab_line_direction(cnt)     := rec.line_direction;   -- J-IB-NPARIKH
      l_tab_shipping_control(cnt)   := rec.shipping_control;   -- J-IB-NPARIKH
      l_tab_ignore_for_planning(cnt)   := rec.ignore_for_planning;
      l_tab_client_id(cnt)               := rec.client_id;  -- LSP PROJECT
      END LOOP;

    END LOOP;

    --
    -- K LPN CONV. rv
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    THEN
    --{
        IF (WSH_WMS_LPN_GRP.GK_WMS_UPD_GRP and l_sync_tmp_wms_contlist.delivery_detail_id_tbl.count > 0)
        THEN
        --{
            WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
              (
                p_sync_tmp_recTbl   => l_sync_tmp_wms_contlist,
                x_return_status     => l_return_status
              );

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_WMS_SYNC_TMP_PKG.MERGE',l_return_status);
            END IF;
            --
            IF l_return_status IN (C_UNEXP_ERROR_STATUS, C_ERROR_STATUS) THEN
              x_return_status := l_return_status;
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Error occured in WSH_WMS_SYNC_TMP_PKG.MERGE_BULK');
                  WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              RETURN;
            ELSE
              IF l_return_status <> C_SUCCESS_STATUS THEN
                x_return_status := C_WARNING_STATUS;
              END IF;
            END IF;
        --}
        ELSIF (WSH_WMS_LPN_GRP.GK_INV_UPD_GRP and l_sync_tmp_inv_contlist.delivery_detail_id_tbl.count > 0)
        THEN
        --{
            WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
              (
                p_sync_tmp_recTbl   => l_sync_tmp_inv_contlist,
                x_return_status     => l_return_status
              );

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_WMS_SYNC_TMP_PKG.MERGE',l_return_status);
            END IF;
            --
            IF l_return_status IN (C_UNEXP_ERROR_STATUS, C_ERROR_STATUS) THEN
              x_return_status := l_return_status;
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Error occured in WSH_WMS_SYNC_TMP_PKG.MERGE_BULK');
                  WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              RETURN;
            ELSE
              IF l_return_status <> C_SUCCESS_STATUS THEN
                x_return_status := C_WARNING_STATUS;
              END IF;
            END IF;
        --}
        END IF;
    --}
    END IF;
    -- K LPN CONV. rv
-- update container with all the attributes
    FORALL cnt IN 1..g_assign_detail_tab.COUNT
      UPDATE WSH_DELIVERY_DETAILS
         SET customer_id = l_tab_cust_id(cnt),
             ship_to_location_id = l_tab_ship_location_id(cnt),
             intmed_ship_to_location_id = l_tab_intmed_location_id(cnt),
             fob_code = l_tab_fob_code(cnt),
             freight_terms_code = l_tab_freight_terms_code(cnt),
             ship_method_code = l_tab_ship_method_code(cnt),
             carrier_id = l_tab_carrier_id(cnt),
             service_level = l_tab_service_level(cnt),
             mode_of_transport = l_tab_mode_of_transport(cnt),
             deliver_to_location_id = l_tab_deliver_location_id(cnt),
             line_direction = l_tab_line_direction(cnt),
             shipping_control = l_tab_shipping_control(cnt),
             ignore_for_planning = l_tab_ignore_for_planning(cnt),
             client_id           = l_tab_client_id(cnt) -- LSP PROJECT
       WHERE DELIVERY_DETAIL_ID = l_contlist(cnt);


-- then if the delivery detail has a delivery assigned, update the container records
-- in WDA to indicate delivery id
    --
    -- K LPN CONV. rv
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    THEN
    --{
        IF (WSH_WMS_LPN_GRP.GK_WMS_ASSIGN_DLVY and l_sync_tmp_wms_contlist1.delivery_detail_id_tbl.count > 0)
        THEN
        --{
            WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
              (
                p_sync_tmp_recTbl   => l_sync_tmp_wms_contlist1,
                x_return_status     => l_return_status
              );

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_WMS_SYNC_TMP_PKG.MERGE',l_return_status);
            END IF;
            --
            IF l_return_status IN (C_UNEXP_ERROR_STATUS, C_ERROR_STATUS) THEN
              x_return_status := l_return_status;
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Error occured in WSH_WMS_SYNC_TMP_PKG.MERGE_BULK');
                  WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              RETURN;
            ELSE
              IF l_return_status <> C_SUCCESS_STATUS THEN
                x_return_status := C_WARNING_STATUS;
              END IF;
            END IF;
        --}
        ELSIF (WSH_WMS_LPN_GRP.GK_INV_ASSIGN_DLVY and l_sync_tmp_inv_contlist1.delivery_detail_id_tbl.count > 0)
        THEN
        --{
            WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
              (
                p_sync_tmp_recTbl   => l_sync_tmp_inv_contlist1,
                x_return_status     => l_return_status
              );

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_WMS_SYNC_TMP_PKG.MERGE',l_return_status);
            END IF;
            --
            IF l_return_status IN (C_UNEXP_ERROR_STATUS, C_ERROR_STATUS) THEN
              x_return_status := l_return_status;
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Error occured in WSH_WMS_SYNC_TMP_PKG.MERGE_BULK');
                  WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              RETURN;
            ELSE
              IF l_return_status <> C_SUCCESS_STATUS THEN
                x_return_status := C_WARNING_STATUS;
              END IF;
            END IF;
        --}
        END IF;
    --}
    END IF;
    -- K LPN CONV. rv

    -- OTM R12 : assign delivery detail

    IF (l_gc3_is_installed = 'Y') THEN
      -- loop through the deliveries in l_dellist1,
      -- and get ignore_for_planning and tms_interface_flag tab,
      -- for ignore_for_planning delivery, check whether it's empty
      l_index := l_dellist1.FIRST;
      WHILE (l_index IS NOT NULL) LOOP
        -- l_dellist1(l_index) might be null if the container is not assigned
        -- to a delivery
        IF (l_dellist1(l_index) IS NOT NULL) THEN
          OPEN c_get_plan_and_tms_flag(l_dellist1(l_index));
          FETCH c_get_plan_and_tms_flag INTO l_ignore_for_planning_tab(l_index),
                                             l_tms_interface_flag_tab(l_index);
          IF c_get_plan_and_tms_flag%NOTFOUND THEN
          --{
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'No data for c_get_plan_and_tms_flag', l_dellist1(l_index));
            END IF;
            CLOSE c_get_plan_and_tms_flag;
            raise FND_API.G_EXC_ERROR;
          END IF;

          CLOSE c_get_plan_and_tms_flag;

          l_delivery_was_empty_tab(l_index) := FALSE;
          IF (l_ignore_for_planning_tab(l_index) = 'N') THEN
            l_is_delivery_empty := WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY(l_dellist1(l_index));
            IF (l_is_delivery_empty = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'error from wsh_new_delivery_actions.is_delivery_empty');
              END IF;
              raise FND_API.G_EXC_ERROR;
            ELSIF (l_is_delivery_empty = 'Y') THEN
              l_delivery_was_empty_tab(l_index) := TRUE;
            END IF;
          END IF;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_dellist1('||l_index||')', l_dellist1(l_index));
            WSH_DEBUG_SV.log(l_module_name,'l_contlist1('||l_index||')', l_contlist1(l_index));
            WSH_DEBUG_SV.log(l_module_name,'l_ignore_for_planning_tab('||l_index||')', l_ignore_for_planning_tab(l_index));
            WSH_DEBUG_SV.log(l_module_name,'l_tms_interface_flag_tab('||l_index||')', l_tms_interface_flag_tab(l_index));
          END IF;
        ELSE
          l_ignore_for_planning_tab(l_index) := NULL;
          l_tms_interface_flag_tab(l_index) := NULL;
          l_delivery_was_empty_tab(l_index) := NULL;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'l_dellist1 is null for ', l_contlist1(l_index));
          END IF;
        END IF;

        l_index := l_dellist1.NEXT(l_index);
      END LOOP;
    END IF;
    -- End of OTM R12 : assign delivery detail

    FORALL cnt IN 1..g_new_contid_tab.COUNT
      UPDATE wsh_delivery_assignments_v
       SET delivery_id = l_dellist1(cnt),
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.USER_ID,
             last_update_login = FND_GLOBAL.LOGIN_ID
      WHERE  DELIVERY_DETAIL_ID = l_contlist1(cnt);


    --
    -- OTM R12 : assign delivery detail
    IF (l_gc3_is_installed = 'Y') THEN

      l_index := l_dellist1.FIRST;
      l_index_update := 0;
      WHILE (l_index IS NOT NULL) LOOP
        IF (l_dellist1(l_index) IS NOT NULL AND
            l_ignore_for_planning_tab(l_index) = 'N') THEN

          IF (l_delivery_was_empty_tab(l_index)) THEN
            l_is_delivery_empty := WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY(l_dellist1(l_index));

            IF (l_is_delivery_empty = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
              --handle the error approriately to the procedure this code is in
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'error from wsh_new_delivery_actions.is_delivery_empty');
              END IF;
              raise FND_API.G_EXC_ERROR;
            ELSIF (l_is_delivery_empty = 'N') THEN
              IF (l_tms_interface_flag_tab(l_index) = WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT) THEN
                l_index_update := l_index_update + 1;
                l_delivery_id_tab(l_index_update) := l_dellist1(l_index);
                l_interface_flag_tab(l_index_update) := WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_REQUIRED;

                IF (l_debug_on) THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery is not empty');
                  WSH_DEBUG_SV.log(l_module_name,'l_dellist1', l_dellist1(l_index));
                  WSH_DEBUG_SV.log(l_module_name,'l_interface_flag_tab', l_interface_flag_tab(l_index_update));
                END IF;
              ELSIF (l_tms_interface_flag_tab(l_index) in
                     (WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED,
                      WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS)) THEN
                l_index_update := l_index_update + 1;
                l_delivery_id_tab(l_index_update) := l_dellist1(l_index);
                l_interface_flag_tab(l_index_update) := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
                IF (l_debug_on) THEN
                  WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery is not empty');
                  WSH_DEBUG_SV.log(l_module_name,'l_dellist1', l_dellist1(l_index));
                  WSH_DEBUG_SV.log(l_module_name,'l_interface_flag_tab', l_interface_flag_tab(l_index_update));
                END IF;
              END IF;
            END IF;
          ELSE -- (NOT l_delivery_was_empty)

            OPEN c_get_tare_weight(l_contlist1(l_index));
            FETCH c_get_tare_weight INTO l_tare_weight;

            IF c_get_tare_weight%NOTFOUND THEN
            --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'No data for c_get_tare_weight', l_contlist1(l_index));
              END IF;
              CLOSE c_get_tare_weight;
              raise FND_API.G_EXC_ERROR;
            END IF;
            CLOSE c_get_tare_weight;

            IF (l_debug_on) THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery was not empty');
              WSH_DEBUG_SV.log(l_module_name,'l_dellist1', l_dellist1(l_index));
              WSH_DEBUG_SV.log(l_module_name,'l_contlist1', l_contlist1(l_index));
              WSH_DEBUG_SV.log(l_module_name,'l_tare_weight', l_tare_weight);
            END IF;
              l_index_update := l_index_update + 1;
              l_delivery_id_tab(l_index_update) := l_dellist1(l_index);
              l_interface_flag_tab(l_index_update) := NULL;
              --Bug7608629
              --removed code which checked for gross weight
              --now irrespective of tare weight UPDATE_TMS_INTERFACE_FLAG will be called
          END IF;
        END IF;
        l_index := l_dellist1.NEXT(l_index);
      END LOOP;

      IF (l_index_update > 0) THEN
        WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG(
                       p_delivery_id_tab        => l_delivery_id_tab,
                       p_tms_interface_flag_tab => l_interface_flag_tab,
                       x_return_status          => l_return_status);

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG '||l_return_status);
          END IF;
          raise FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Warning in WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG '||l_return_status);
          END IF;
          cont_warn := cont_warn + 1;
        END IF;

      END IF;
    END IF;
    -- End of OTM R12 : assign delivery detail

   l_mdc_id_tab.delete;
   l_mdc_index_i := l_contlist1.FIRST;
   l_mdc_index_j := 0;
   WHILE l_mdc_index_i IS NOT NULL LOOP
       l_mdc_index_j := l_mdc_index_j + 1;
       l_mdc_id_tab(l_mdc_index_j) := l_contlist1(l_mdc_index_i);
       l_mdc_index_i := l_contlist1.next(l_mdc_index_i);

   END LOOP;

   WSH_DELIVERY_DETAILS_ACTIONS.Create_Consol_Record(
                  p_detail_id_tab     => l_mdc_id_tab,
                  x_return_status     => x_return_status);

   IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       RETURN;
   END IF;

-- J: W/V Changes
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'before W/V adjustment 3 '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
   END IF;
   FOR i in 1..l_contlist1.COUNT LOOP
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Cont:Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     WSH_WV_UTILS.DD_WV_Post_Process(
       p_delivery_detail_id => l_contlist1(i),
       p_diff_gross_wt      => l_cont_Wtlist(i),
       p_diff_net_wt        => NULL,
       p_diff_volume        => l_cont_Vollist(i),
       p_diff_fill_volume   => l_cont_Vollist(i),
       x_return_status      => l_return_status);

     IF (l_return_status <> C_SUCCESS_STATUS) THEN
       --
       IF (l_return_status = C_ERROR_STATUS OR
           l_return_status = C_UNEXP_ERROR_STATUS) THEN
         error_cnt := error_cnt + 1;
       ELSE
         cont_warn := cont_warn + 1;
       END IF;

     END IF;
   END LOOP;
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'after W/V adjustment 3 '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
   END IF;

    -- 75.1 Bulk Update Weight/Volume on packed delivery details
 -- added the WHO columns in the UPDATE
 -- in WSHWVUTB.pls , update_container_wt there are no WHO columns
    FORALL cnt IN 1..g_assign_detail_tab.COUNT
      UPDATE WSH_DELIVERY_DETAILS
      SET    NET_WEIGHT   = l_NetWtlist(cnt),
             GROSS_WEIGHT = l_GrossWtlist(cnt),
             VOLUME       = l_Vollist(cnt),
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.USER_ID,
             last_update_login = FND_GLOBAL.LOGIN_ID
      WHERE  DELIVERY_DETAIL_ID = l_ddlist(cnt);

  END IF; -- line_cont_tab.COUNT > 0

  --H integration : Pricing Integration
  IF l_del_tab.count > 0 THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling Program Unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required
      (p_entity_type => 'DELIVERY',
       p_entity_ids  => l_del_tab,
       x_return_status => l_return_status
      );
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
    END IF;
    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      RAISE mark_reprice_error;
    END IF;
  END IF;
  -- End of H integration : Pricing Integration

--dbms_output.put_line('AFTER CONT WT'||to_char(sysdate,'HH24:MI:SS'));
  -- 90.1 Summarize errors/warnings

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Error, warn,success Count -'||error_cnt||','||warn_cnt||','||succ_cnt);
  END IF;
  IF (warn_cnt > 0 OR cont_warn > 0) THEN
    x_return_status := C_WARNING_STATUS;
    IF cont_warn > 0 THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_PACK_WARN');
      FND_MESSAGE.SET_TOKEN('CONT_WARN',cont_warn);
      FND_MESSAGE.SET_TOKEN('CONT_ERR',0);
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
    END IF;
  ELSIF (error_cnt > 0) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_PACK_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_COUNT',error_cnt);
    FND_MESSAGE.SET_TOKEN('WARN_COUNT',warn_cnt);
    FND_MESSAGE.SET_TOKEN('SUCC_COUNT',succ_cnt);
    IF succ_cnt > 0 THEN
      x_return_status := C_WARNING_STATUS;
    ELSE
      x_return_status := C_ERROR_STATUS;
    END IF;
    WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
  ELSE
    x_return_status := C_SUCCESS_STATUS;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'L ret status -'||l_return_status);
    WSH_DEBUG_SV.logmsg(l_module_name,'X ret status -'||x_return_status);
  END IF;
  IF x_return_status = C_ERROR_STATUS THEN
    IF p_pack_cont_flag = 'Y' THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MASTER_NOT_PACK');
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
  ELSE
    l_return_status := x_return_status;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'2L ret status -'||l_return_status);
    WSH_DEBUG_SV.logmsg(l_module_name,'2X ret status -'||x_return_status);
  END IF;
  -- 100.1 Call WSH_CONTAINER_ACTIONS.Auto_Pack_Conts depending on
  --       p_pack_cont_flag and if new detail containers are created
  IF l_detail_cont_tab.count > 0 AND p_pack_cont_flag = 'Y' THEN

    l_group_id_tab.delete;

    --dbms_output.put_line('Calling AUTO PACK CONTS With x_cont_instance count of ' || x_cont_instance_tab.count);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.AUTO_PACK_CONTS',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_container_actions.Auto_Pack_Conts (
      l_group_id_tab,
      l_detail_cont_tab,
      x_cont_instance_tab,
      l_mast_cont_tab,
      l_return_status);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'return status -',l_return_status);
    END IF;
    IF l_return_status = C_UNEXP_ERROR_STATUS THEN
      --dbms_output.put_line('Returned from autopack conts with unexpected error');
      /* No message WSH_CONT_CONT_AUTOPACK_ERR
      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_CONT_AUTOPACK_ERR');
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      IF l_return_status <> C_ERROR_STATUS THEN
        l_return_status := C_WARNING_STATUS;
      END IF;
      */
      x_return_status := l_return_status;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    ELSE
      IF l_return_status <> C_SUCCESS_STATUS THEN
        x_return_status := C_WARNING_STATUS;
      END IF;
    END IF;

    --dbms_output.put_line('WSH_CONTAINER_ACTIONS.Auto_Pack_Conts created '||l_mast_cont_tab.COUNT||' Master Containers');
    IF l_mast_cont_tab.COUNT > 0 THEN
      i := 1;
      cnt := x_cont_instance_tab.COUNT;
      WHILE i  <= l_mast_cont_tab.COUNT LOOP
        cnt := cnt + 1;
        x_cont_instance_tab(cnt) := l_mast_cont_tab(i);
        i := i + 1;
      END LOOP;
    END IF;

  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'3L ret status -'||l_return_status);
    WSH_DEBUG_SV.logmsg(l_module_name,'3X ret status -'||x_return_status);
  END IF;
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN mark_reprice_error THEN
    FND_MESSAGE.Set_Name('WSH','WSH_REPRICE_REQD_ERR');
    x_return_status := l_return_status;
    WSH_UTIL_CORE.add_message(x_return_status,l_module_name);
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
    END IF;

  -- OTM R12 : assign delivery detail
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF c_get_plan_and_tms_flag%ISOPEN THEN
      CLOSE c_get_plan_and_tms_flag;
    END IF;
    IF c_get_tare_weight%ISOPEN THEN
      CLOSE c_get_tare_weight;
    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  -- End of OTM R12 : assign delivery detail

  WHEN Others THEN
    -- OTM R12 : assign delivery detail
    IF c_get_plan_and_tms_flag%ISOPEN THEN
      CLOSE c_get_plan_and_tms_flag;
    END IF;
    IF c_get_tare_weight%ISOPEN THEN
      CLOSE c_get_tare_weight;
    END IF;
    -- End of OTM R12 : assign delivery detail

        WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Auto_Pack_Lines',l_module_name);
        x_return_status := C_UNEXP_ERROR_STATUS;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Auto_Pack_Lines;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Auto_Pack_Delivery
   PARAMETERS : p_delivery_tab - table of delivery ids that need to be
			autopacked.
		x_cont_instance_tab - table of container instance ids that were
			created during the autopacking.
		x_return_status - return status of API.
  DESCRIPTION : This procedure takes a table of deliveries that need to be
		autopacked and checks for all unpacked lines in each of the
		deliveries. After fetching all unpacked lines in each delivery,
		it calls the Auto_Pack_Lines with the table of unpacked lines.
		After autopacking the lines, it recalculates the weight and
		volume of the delivery.
------------------------------------------------------------------------------
*/


PROCEDURE Auto_Pack_Delivery (
  p_delivery_tab IN WSH_UTIL_CORE.id_tab_type,
  p_pack_cont_flag IN VARCHAR2,
  x_cont_instance_tab OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
  x_return_status OUT NOCOPY  VARCHAR2) IS

  CURSOR get_delivery_wms(x_delivery_id NUMBER) IS
  SELECT mp.wms_enabled_flag
  FROM   wsh_new_deliveries wnd,
         mtl_parameters     mp
  WHERE  wnd.delivery_id = x_delivery_id
  AND    mp.organization_id = wnd.organization_id;


  CURSOR Get_Delivery_Lines (v_delivery_id NUMBER) IS
  SELECT wda.delivery_detail_id
  FROM wsh_delivery_assignments_v wda,
       WSH_DELIVERY_DETAILS wdd
  WHERE wda.delivery_id = v_delivery_id
  AND wda.delivery_id IS NOT NULL
  AND wda.parent_delivery_detail_id IS NULL
  AND wda.delivery_detail_id = wdd.delivery_detail_id
  AND wdd.container_flag = 'N';

  l_del_detail_tab WSH_UTIL_CORE.id_tab_type;
  l_group_id_tab WSH_UTIL_CORE.id_tab_type;

  l_gross_weight NUMBER;
  l_volume NUMBER;

  l_cont_instance_tab WSH_UTIL_CORE.id_tab_type;

  l_ret_sts VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_return_status VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  error_cnt NUMBER := 0;
  warn_cnt  NUMBER := 0;
  succ_cnt NUMBER := 0;

  i NUMBER;
  m NUMBER := 0;
  l_del_rows WSH_UTIL_CORE.id_tab_type;

  l_del_name VARCHAR2(30);
  l_wms_count NUMBER := 0;
  l_wms_enabled_flag VARCHAR2(1);

  -- LPN CONV. rv
  l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
  l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(32767);
  e_return_excp EXCEPTION;
  -- LPN CONV. rv


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTO_PACK_DELIVERY';
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
      WSH_DEBUG_SV.log(l_module_name,'P_PACK_CONT_FLAG',P_PACK_CONT_FLAG);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_del_rows.delete;

  FOR j IN 1..p_delivery_tab.count LOOP

    i := 1;
    l_ret_sts := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    l_del_detail_tab.delete;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Auto pack delivery ', p_delivery_tab(j));
    END IF;
    -- bug 1578527: disallow packing actions in WMS

    OPEN  get_delivery_wms(p_delivery_tab(j));
    FETCH get_delivery_wms INTO l_wms_enabled_flag;
    IF get_delivery_wms%NOTFOUND THEN
      CLOSE get_delivery_wms;
      FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_DATA_FOUND');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      --IF l_debug_on THEN
          --WSH_DEBUG_SV.pop(l_module_name);
      --END IF;
      --
      --RETURN; LPN CONV. rv
      raise e_return_excp; -- LPN CONV. rv
    END IF;
    CLOSE get_delivery_wms;

    IF l_wms_enabled_flag = 'Y' THEN
      l_wms_count := l_wms_count + 1;
      l_ret_sts := WSH_UTIL_CORE.G_RET_STS_ERROR;
      goto next_delivery_to_autopack;
    END IF;

    FOR d IN Get_Delivery_Lines (p_delivery_tab(j)) LOOP

	l_del_detail_tab(i) := d.delivery_detail_id;
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'pupulate delivery detail id  ', d.delivery_detail_id );
        END IF;
	i := i + 1;

    END LOOP;

    IF Get_Delivery_Lines%ISOPEN THEN
	CLOSE Get_Delivery_Lines;
    END IF;
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_del_detail_tab.count: ', l_del_detail_tab.count );
    END IF;
    IF l_del_detail_tab.count = 0 THEN

	l_ret_sts := WSH_UTIL_CORE.G_RET_STS_ERROR;

	FND_MESSAGE.SET_NAME('WSH','WSH_DEL_AUTOPACK_NULL');
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_del_name := WSH_NEW_DELIVERIES_PVT.Get_Name(p_delivery_tab(j));
	FND_MESSAGE.SET_TOKEN('DEL_NAME',l_del_name);
	WSH_UTIL_CORE.Add_Message(l_ret_sts,l_module_name);
    ELSE

    	--
    	IF l_debug_on THEN
    	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.AUTO_PACK_LINES',WSH_DEBUG_SV.C_PROC_LEVEL);
    	END IF;
    	--

    	wsh_container_actions.Auto_Pack_Lines (
		l_group_id_tab,
		l_del_detail_tab,
		p_pack_cont_flag,
		l_cont_instance_tab,
		l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return status from wsh_container_actions.Auto_Pack_Lines -',l_return_status);
        END IF;
    	IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR OR l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
		--dbms_output.put_line('autopack lines failed');
		l_ret_sts := WSH_UTIL_CORE.G_RET_STS_ERROR;
    	ELSE
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	    l_ret_sts := WSH_UTIL_CORE.G_RET_STS_WARNING;
	  ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN  -- Bug#2903864 - Start
	     IF (x_cont_instance_tab IS NULL) THEN
	         x_cont_instance_tab := l_cont_instance_tab;
	     ELSE
		 FOR i in 1..l_cont_instance_tab.count LOOP
			x_cont_instance_tab(x_cont_instance_tab.count + 1) := l_cont_instance_tab(i);
		 END LOOP;
	     END IF; -- Bug#2903864 - End

          END IF;

    	END IF;

    END IF;
    <<next_delivery_to_autopack>>
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'return status for delivery '|| p_delivery_tab(j), l_ret_sts );
    END IF;
    IF l_ret_sts = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       succ_cnt := succ_cnt + 1;
    ELSIF l_ret_sts = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
       warn_cnt := warn_cnt + 1;
    ELSE
       error_cnt := error_cnt + 1;
    END IF;
  END LOOP;

   -- bug 1578527: disallow packing actions in WMS
   IF l_wms_count > 0 THEN
      IF l_wms_count = p_delivery_tab.count THEN
          FND_MESSAGE.SET_NAME('WSH', 'WSH_WMS_PACK_NOT_ALLOWED');
          WSH_UTIL_CORE.Add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
      ELSE
          FND_MESSAGE.SET_NAME('WSH', 'WSH_WMS_RECORDS_NOT_PACKED');
          FND_MESSAGE.SET_TOKEN('COUNT', l_wms_count);
          WSH_UTIL_CORE.Add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
      END IF;
   END IF;

   /*  H integration: Pricing integration csun
       when plan a delivery
   */
   IF l_del_rows.count > 0 THEN
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
	   p_entity_type => 'DELIVERY',
	   p_entity_ids   => l_del_rows,
	   x_return_status => l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return status from WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required -',l_return_status);
        END IF;
        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
	      l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
	      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	      FND_MESSAGE.SET_NAME('WSH', 'WSH_REPRICE_REQUIRED_ERR');
	      WSH_UTIL_CORE.add_message(x_return_status,l_module_name);
              --IF l_debug_on THEN
              --  WSH_DEBUG_SV.pop(l_module_name);
              --END IF;
	      --return; LPN CONV. rv
              raise e_return_excp; -- LPN CONV. rv
	END IF;
   END IF;

   -- LPN CONV. rv
   --
   IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
   THEN
   --{

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
         (
           p_in_rec             => l_lpn_in_sync_comm_rec,
           x_return_status      => l_return_status,
           x_out_rec            => l_lpn_out_sync_comm_rec
         );
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
       END IF;
       --
       WSH_UTIL_CORE.API_POST_CALL
         (
           p_return_status    => l_return_status,
           x_num_warnings     => warn_cnt,
           x_num_errors       => error_cnt,
           p_raise_error_flag => false
         );
   --}
   END IF;
   -- LPN CONV. rv
   --

  IF warn_cnt > 0 THEN
  	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  	FND_MESSAGE.SET_NAME('WSH','WSH_DEL_PACK_WARN');
 	FND_MESSAGE.SET_TOKEN('ERROR_COUNT',error_cnt);
	FND_MESSAGE.SET_TOKEN('WARN_COUNT',warn_cnt);
	FND_MESSAGE.SET_TOKEN('SUCC_COUNT',succ_cnt);
  	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);

  ELSIF error_cnt > 0 THEN
     IF succ_cnt > 0 THEN
  	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  	FND_MESSAGE.SET_NAME('WSH','WSH_DEL_PACK_WARN');
 	FND_MESSAGE.SET_TOKEN('ERROR_COUNT',error_cnt);
	FND_MESSAGE.SET_TOKEN('WARN_COUNT',warn_cnt);
	FND_MESSAGE.SET_TOKEN('SUCC_COUNT',succ_cnt);
  	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
     ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FND_MESSAGE.SET_NAME('WSH','WSH_DEL_PACK_ERROR');
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
     END IF;
  ELSIF succ_cnt > 0 THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  ELSE
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
    -- LPN CONV. rv
    WHEN e_return_excp THEN
        --
        IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
        THEN
        --{
             --
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
             WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
               (
                 p_in_rec             => l_lpn_in_sync_comm_rec,
                 x_return_status      => l_return_status,
                 x_out_rec            => l_lpn_out_sync_comm_rec
               );
             --
             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
             END IF;
             IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,WSH_UTIL_CORE.G_RET_STS_ERROR) AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status := l_return_status;
             END IF;
        --}
        END IF;
        --
        -- LPN CONV. rv
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_RETURN_EXCP');
        END IF;

  WHEN Others THEN
        --
        WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Auto_Pack_Delivery',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS FROM WHEN OTHERS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS FROM WHEN OTHERS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
        THEN
        --{
             --
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
            WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
              (
                p_in_rec             => l_lpn_in_sync_comm_rec,
                x_return_status      => l_return_status,
                x_out_rec            => l_lpn_out_sync_comm_rec
              );
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
            END IF;
        --}
        END IF;
        --
        -- LPN CONV. rv
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Auto_Pack_Delivery;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Pack_Multi
   PARAMETERS : p_cont_tab - table of container instance ids that are being
		packed.
		p_del_detail_tab - table of unpacked delivery detail ids.
		p_pack_mode  - indicates whether containers are packed in
		equal/proportional mode ('E') or in full/sequential mode ('F')
		p_split_pc - the percentage by which each line is going to be
		split in the case of equal packing mode.
		x_pack_status - the packed status of containers after the multi
		pack is performed - indicates whether any underpacked or
		overpacked containers.
		x_return_status - return status of API.
  DESCRIPTION : This procedure takes the specified delivery detail ids and
		packs them into the selected containers in either the full mode
		or equal mode. In the full mode, it packs the first container
		fully before packing the next. In the equal mode, all lines
		are split equally between all the containers and packed
		equally between them.
------------------------------------------------------------------------------
*/


PROCEDURE Pack_Multi (
 p_cont_tab IN WSH_UTIL_CORE.id_tab_type,
 p_del_detail_tab IN WSH_UTIL_CORE.id_tab_type,
 p_pack_mode IN VARCHAR2,
 p_split_pc IN NUMBER,
 x_pack_status OUT NOCOPY  VARCHAR2,
 x_return_status OUT NOCOPY  VARCHAR2) IS


 CURSOR Get_Cont_Info (v_cont_instance_id NUMBER) IS
 SELECT inventory_item_id, organization_id, gross_weight, net_weight,
	volume, weight_uom_code, volume_uom_code, fill_percent,
	minimum_fill_percent, maximum_load_weight, maximum_volume
 FROM wsh_delivery_details
 WHERE delivery_detail_id = v_cont_instance_id
 AND container_flag = 'Y';

 CURSOR Get_Detail_Info (v_del_detail_id NUMBER) IS
 SELECT inventory_item_id, nvl(shipped_quantity, NVL(picked_quantity, requested_quantity)) pack_qty,
	requested_quantity_uom, net_weight, volume,
	weight_uom_code, volume_uom_code, organization_id,
	nvl(detail_container_item_id, master_container_item_id) cont_item_id,
        nvl(shipped_quantity2, NVL(picked_quantity2, requested_quantity2)) pack_qty2
 FROM wsh_delivery_details
 WHERE delivery_detail_id = v_del_detail_id
 AND container_flag = 'N';

 TYPE Cont_Rec IS RECORD (container_instance_id NUMBER, pack_status VARCHAR2(30));

 TYPE Detail_Rec IS RECORD (delivery_detail_id NUMBER, pack_status VARCHAR2(30));

 TYPE Cont_Rec_Table IS TABLE OF Cont_Rec INDEX BY BINARY_INTEGER;
 TYPE Detail_Rec_Table IS TABLE OF Detail_Rec INDEX BY BINARY_INTEGER;

 l_cont_item_id		NUMBER;
 l_cont_org_id		NUMBER;
 l_cont_gross		NUMBER;
 l_cont_net		NUMBER;
 l_cont_volume		NUMBER;
 l_cont_wt_uom		VARCHAR2(3);
 l_cont_vol_uom		VARCHAR2(3);
 l_cont_fill_pc		NUMBER;
 l_cont_min_fill_pc	NUMBER;
 l_cont_max_load_wt	NUMBER;
 l_cont_max_vol		NUMBER;

 l_det_inv_item_id	NUMBER;
 l_det_pack_qty		NUMBER;
 l_det_pack_qty2	NUMBER;
 l_det_qty_uom		VARCHAR2(3);
 l_det_net		NUMBER;
 l_det_volume		NUMBER;
 l_det_wt_uom		VARCHAR2(3);
 l_det_vol_uom		VARCHAR2(3);
 l_det_org_id		NUMBER;
 l_det_cont_item_id	NUMBER;

 l_split_det_id		NUMBER;
 i			NUMBER;
 j			NUMBER;
 cont_count		NUMBER;
 det_count		NUMBER;
 l_req_cont_num		NUMBER;
 l_cont_avail_pc	NUMBER;
 l_cont_self_tare	NUMBER;
 l_split_qty		NUMBER;
 l_split_qty2           NUMBER;
 l_return_status	VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 l_tmp_cont_gr		NUMBER;
 l_tmp_cont_net		NUMBER;
 l_tmp_cont_vol		NUMBER;
 l_tmp_fill_pc		NUMBER;
 l_pack_status		VARCHAR2(30);

 l_tmp_split_qty 	NUMBER;

 l_tmp_det_net		NUMBER;
 l_tmp_det_vol		NUMBER;

 l_det_pack_sts		VARCHAR2(30);

 l_tmp_det_tab		WSH_UTIL_CORE.id_tab_type;

 l_cont_tab		Cont_Rec_Table;
 l_det_tab		Detail_Rec_Table;

 l_split_pc		NUMBER;

 l_tmp_det_qty 		NUMBER;
 l_tmp_det_count	NUMBER;

 l_tmp_delta            NUMBER;

 l_cont_name VARCHAR2(30);

 warn_cnt NUMBER := 0;
 succ_cnt NUMBER := 0;
 error_cnt NUMBER := 0;

 cont_warn NUMBER := 0;
 cont_err NUMBER := 0;
 cont_succ NUMBER := 0;
 l_tmp_return_status   varchar2(1);

 l_tmp_status VARCHAR2(30)  := 'OK';
 l_discard_status          VARCHAR2(1);
 l_discard_message VARCHAR2(2000);
 -- J: W/V Changes
 l_fill_status VARCHAR2(1);

  /* H projects: pricing integration csun */
  m NUMBER := 0;
  l_detail_rows   WSH_UTIL_CORE.id_tab_type;

-- for Load Tender
  l_trip_id_tab wsh_util_core.id_tab_type;

-- bug 3562797 jckwok
  l_process_flag         VARCHAR2(1);
  l_fill_pc_basis        VARCHAR2(1);
-- end bug 3562797 jckwok

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PACK_MULTI';
--Bugfix 4070732
l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
l_reset_flags BOOLEAN;
l_num_errors  NUMBER;
--
--
  l_num_warnings NUMBER;
--

-- HW OPM BUG# 3011758
--HW OPMCONV - Removed OPM local variables

-- HW OPMCONV - Renamed variable to l_lot_divisible_flag
l_lot_divisible_flag                        VARCHAR2(1);
-- HW OPMCONV - New variable to hold item info
l_item_info                   WSH_DELIVERY_DETAILS_INV.mtl_system_items_rec;

-- LPN CONV. rv
l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
e_return_excp EXCEPTION;
-- LPN CONV. rv

BEGIN
 IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null THEN  --Bugfix 4070732
   WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
   WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
 END IF;
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
     WSH_DEBUG_SV.log(l_module_name,'P_PACK_MODE',P_PACK_MODE);
     WSH_DEBUG_SV.log(l_module_name,'P_SPLIT_PC',P_SPLIT_PC);
 END IF;
 --
 IF p_cont_tab.count = 0 OR p_del_detail_tab.count = 0 THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_ASSG_NULL');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    x_pack_status := 'Error';
    WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
    --
    --Bugfix 4070732 {
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
       IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                    x_return_status => l_tmp_return_status);


          IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_tmp_return_status',l_tmp_return_status);
          END IF;
          /*wsh_util_core.api_post_call
               (
                 p_return_status => l_return_status,
                 x_num_warnings  => l_num_warnings,
                 x_num_errors    => l_num_errors
                );
          */
          IF l_tmp_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            X_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          END IF;
       END IF;
    END IF;
    --}
    --IF l_debug_on THEN
    --    WSH_DEBUG_SV.pop(l_module_name);
    --END IF;
    --
    --return; LPN CONV. rv
    raise e_return_excp; -- LPN CONV. rv
 END IF;

 cont_count := p_cont_tab.count;
 det_count := p_del_detail_tab.count;

 --dbms_output.put_line('in pack multi conts are ' || cont_count || ' details are ' || det_count);

 FOR i IN 1..cont_count LOOP

   l_cont_tab(i).container_instance_id := p_cont_tab(i);
   l_cont_tab(i).pack_status := 'Unpacked';

 END LOOP;

	--
	--
	-- added to fix bug 1818233.
	-- pack_multi performs most of time doing this check, especially
	-- when a single delivery line is being split into multiple due to
	-- container-load relationship.
	-- This check will be made only once for a delivery line in place of
	-- doing it every time we assign a split delivery line to a container.
	-- Thus, auto-pack lines will always call assign_detail procedure
	-- with parameter p_check_credit_holds = FALSE.
	-- pack_multi lines will explicitly call the procedure (as follows)
	-- WSH_DETAILS_VALIDATIONS.Check_Credit_Holds only once for a delivery
	-- line . If any of the delivery lines fails this check, API will
	-- return with error.
	--

 FOR j IN 1..det_count LOOP

   l_det_tab(j).delivery_detail_id := p_del_detail_tab(j);
   l_det_tab(j).pack_status := 'Unpacked';

            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_CREDIT_HOLDS',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_DETAILS_VALIDATIONS.Check_Credit_Holds (
                                        l_det_tab(j).delivery_detail_id,
                                        'PACK',
                                        NULL,
                                        NULL,
                                        NULL,
                                        'Y',
                                        x_return_status);
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'return status-', x_return_status);
            END IF;

            IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                l_return_status :=  WSH_UTIL_CORE.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DETAIL_NOT_ASSIGNED');
		FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_det_tab(j).delivery_detail_id);
		WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                x_pack_status := 'Error';
            END IF;

 END LOOP;

 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
 THEN
     --Bugfix 4070732 {
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
       IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                    x_return_status => l_tmp_return_status);

          IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_tmp_return_status',l_tmp_return_status);
          END IF;

          /* wsh_util_core.api_post_call
               (
                 p_return_status => l_return_status,
                 x_num_warnings  => l_num_warnings,
                 x_num_errors    => l_num_errors
                );
          */

          IF l_tmp_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            X_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          END IF;
       END IF;
    END IF;
    --}
    --
    --IF l_debug_on THEN
    --    WSH_DEBUG_SV.pop(l_module_name);
    --END IF;
    --
    --RETURN; LPN CONV. rv
    raise e_return_excp; -- LPN CONV. rv
 END IF;

 i := 1;
 j := 1;

 IF p_pack_mode = 'F' THEN
   -- packing mode is full - each container is filled before packing the next

   WHILE j <= det_count LOOP

	--dbms_output.put_line('j = ' || j);
	l_det_pack_sts := 'Unpacked';
	i := 1;

        IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_module_name,'processing line ' || j || ' detail is ' || l_det_tab(j).delivery_detail_id);
        END IF;

	WHILE i <= cont_count LOOP
	    	IF l_cont_tab(i).pack_status = 'Skipped' THEN
			l_cont_tab(i).pack_status := 'Unpacked';
		END IF;
		i := i + 1;
	END LOOP;

	i := 1;

        WHILE (i <= cont_count AND l_det_pack_sts = 'Unpacked') LOOP

/*
	   if i <= 0 or i > 10 then
		exit;
	   end if;
*/

 	   OPEN Get_Detail_Info (l_det_tab(j).delivery_detail_id);

	   FETCH Get_Detail_Info INTO
	  	l_det_inv_item_id,
	  	l_det_pack_qty,
	  	l_det_qty_uom,
	  	l_det_net,
	  	l_det_volume,
	  	l_det_wt_uom,
	  	l_det_vol_uom,
	  	l_det_org_id,
	  	l_det_cont_item_id,
                l_det_pack_qty2;

	   IF Get_Detail_Info%NOTFOUND THEN
	   	FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
		FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_det_tab(j).delivery_detail_id);
	   	x_pack_status := 'Error';
	   	l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   	CLOSE Get_Detail_Info;
		WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
		error_cnt := error_cnt + 1;
		l_det_tab(j).pack_status := 'Error';
		exit;
 	   END IF;

	   IF Get_Detail_Info%ISOPEN THEN
	   	CLOSE Get_Detail_Info;
	   END IF;

           -- bug 3562797 jckwok
           -- when percent fill basis flag is None and packing mode as Full,
           -- packing workbench raises error.
           Calc_Fill_Basis_and_Proc_Flag(
                    p_organization_id => l_det_org_id,
                    x_return_status   => x_return_status,
                    x_fill_basis      => l_fill_pc_basis,
                    x_process_flag    => l_process_flag);

           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'return status -',x_return_status);
           END IF;

           IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               --Bugfix 4070732 {
             IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
                  IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                     IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                     END IF;

                     WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                               x_return_status => l_tmp_return_status);


                     IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'l_tmp_return_status',l_tmp_return_status);
                     END IF;

                     /*wsh_util_core.api_post_call
                          (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                           );
                     */

                     IF
                     (l_tmp_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                     OR
                     (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                     THEN --{
                        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                     ELSIF x_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR
                     THEN
                        IF l_tmp_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
                        THEN
                           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                        ELSIF l_tmp_return_status =
                           WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                           x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                        END IF;
                     END IF; --}

                  END IF;
             END IF;
             --}
             --IF l_debug_on THEN
             --  WSH_DEBUG_SV.pop(l_module_name);
             --END IF;
             --RETURN;
             raise e_return_excp; -- LPN CONV. rv
           END IF;
           IF (l_fill_pc_basis = 'N') THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_FILL_BASIS_NONE');
              l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
              x_pack_status := 'Error';
              error_cnt := error_cnt + 1;
              l_det_tab(j).pack_status := 'Error';
              exit;
           END IF;
           -- end bug 3562797 jckwok
--- HW OPM BUG# 3011758
-- HW OPMCONV - 1) Removed branching code
--            - 2) Removed call to OPM API to get item info
--            - 3) New WSH API call to get item info

           WSH_DELIVERY_DETAILS_INV.Get_item_information
             (
                p_organization_id       =>l_det_org_id
              , p_inventory_item_id    => l_det_inv_item_id
              , x_mtl_system_items_rec => l_item_info
              , x_return_status        => l_return_status
             );

            wsh_util_core.api_post_call
             (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
             );

-- HW OPMCONV - Get flag from correct record
             IF ( l_item_info.lot_divisible_flag = 'N' AND
                  l_item_info.lot_control_code = 2 ) THEN
               l_lot_divisible_flag := 'N';
             ELSE
               l_lot_divisible_flag := 'Y';
             END IF;

	   --dbms_output.put_line('before checking for unpacked conts ' || i || l_cont_tab(i).pack_status);


	   WHILE (i <= cont_count and l_cont_tab(i).pack_status <> 'Unpacked') LOOP
	 	i := i + 1;

	   END LOOP;

	   --dbms_output.put_line('after looping for unpacked conts i = ' || i);

	   IF i > cont_count THEN
		exit;
	   END IF;

	   OPEN Get_Cont_Info (l_cont_tab(i).container_instance_id);

	   FETCH Get_Cont_Info INTO
		l_cont_item_id,
		l_cont_org_id,
		l_cont_gross,
	  	l_cont_net,
	  	l_cont_volume,
	  	l_cont_wt_uom,
	  	l_cont_vol_uom,
	  	l_cont_fill_pc,
	  	l_cont_min_fill_pc,
	  	l_cont_max_load_wt,
	  	l_cont_max_vol;

	   IF Get_Cont_Info%NOTFOUND THEN
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_cont_tab(i).container_instance_id);
	   	FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
	   	x_pack_status := 'Error';
	   	l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   	CLOSE Get_Cont_Info;
		WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
		cont_err := cont_err + 1;
		l_cont_tab(i).pack_status := 'Error';
		l_tmp_status := 'Error';
		GOTO new_container;
 	   END IF;

	   CLOSE Get_Cont_Info;

	   --dbms_output.put_line('processing container ' || i || ' id is ' || l_cont_tab(i).container_instance_id);

/*
--           WSH_WV_UTILS.Container_Weight_Volume (
--	     replacing with TPA enabled API..

	     --
	     IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_CONTAINER_PKG.CONTAINER_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
	     END IF;
	     --
	     WSH_TPA_CONTAINER_PKG.Container_Weight_Volume (
				l_cont_tab(i).container_instance_id,
				'Y',
				l_tmp_cont_gr,
				l_tmp_cont_net,
				l_tmp_cont_vol,
				'Y',
				l_tmp_fill_pc,
				x_return_status);
           IF l_debug_on THEN
	     WSH_DEBUG_SV.log(l_module_name,'return status ' ,x_return_status);
           END IF;

	   IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		--dbms_output.put_line('container wt vol error');

		l_cont_tab(i).pack_status := 'Warning';
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_cont_tab(i).container_instance_id);
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_WT_VOL_FAILED');
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);


		WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
		cont_warn := cont_warn + 1;
		l_tmp_status := 'Error';
		GOTO new_container;
	   END IF;

	   IF (l_tmp_fill_pc > 100) THEN
*/
           IF (l_cont_fill_pc > 100) THEN

		--dbms_output.put_line('cont overpacked');

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
			l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		END IF;

		l_cont_tab(i).pack_status := 'Overpacked';
		cont_warn := cont_warn + 1;
		l_tmp_status := 'Error';
		GOTO new_container;
           END IF;

           -- bug 4642837 l_tmp_fill_pc --> l_cont_fill_pc

	   l_cont_avail_pc := 1 - (nvl(l_cont_fill_pc,0)/100);

	   IF (l_cont_org_id = l_det_org_id) THEN

--	  	WSH_CONTAINER_UTILITIES.Estimate_Detail_Containers (
--		replacing with TPA enabled API..

		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_CONTAINER_PKG.ESTIMATE_DETAIL_CONTAINERS',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		WSH_TPA_CONTAINER_PKG.Estimate_Detail_Containers (
			l_cont_tab(i).container_instance_id,
			l_cont_item_id,
			l_det_tab(j).delivery_detail_id,
			l_det_org_id,
			l_req_cont_num,
			x_return_status);

                IF l_debug_on THEN
	          WSH_DEBUG_SV.log(l_module_name,'return status ' ,x_return_status);
                END IF;
	    	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			l_cont_tab(i).pack_status := 'Skipped';
			l_det_tab(j).pack_status := 'Error';
			error_cnt := error_cnt + 1;
			l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			l_tmp_status := 'Error';
			GOTO new_container;
	    	END IF;

		--dbms_output.put_line('req cont is ' || l_req_cont_num);
		--dbms_output.put_line(' cont avail pc is ' || l_cont_avail_pc);

		IF l_req_cont_num <= l_cont_avail_pc THEN

		    l_tmp_det_tab(1) := l_det_tab(j).delivery_detail_id;

                IF l_debug_on THEN
	          WSH_DEBUG_SV.log(l_module_name,'assigning detail ' || l_tmp_det_tab(1) || ' to container ' || l_cont_tab(i).container_instance_id);
		  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.ASSIGN_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;

		    --
		    wsh_container_actions.Assign_Detail (
					l_cont_tab(i).container_instance_id,
					l_tmp_det_tab,
					l_pack_status,
					x_return_status,FALSE);
                    IF l_debug_on THEN
	              WSH_DEBUG_SV.log(l_module_name,'return status ' ,x_return_status);
                    END IF;
		    IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			--dbms_output.put_line('could not assign');
			l_cont_tab(i).pack_status := 'Skipped';
			l_det_tab(j).pack_status := 'Error';
			error_cnt := error_cnt + 1;
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
				l_return_status := x_return_status;
			END IF;

		    ELSIF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			l_det_tab(j).pack_status := 'Packed';
			l_det_pack_sts := 'Packed';
-- J: W/V Changes
                       WSH_WV_UTILS.Check_Fill_Pc (
                         p_container_instance_id => l_cont_tab(i).container_instance_id,
                         x_fill_status           => l_fill_status,
                         x_return_status         => l_return_status);

                       IF l_fill_status = 'O' THEN
                           --
                           IF l_debug_on THEN
                               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                           END IF;
                           --
                           l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_cont_tab(i).container_instance_id);

                           --dbms_output.put_line('container ' || l_cont_name || ' overpacked ');


                           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                                l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                           END IF;

                           l_cont_tab(i).pack_status := 'Overpacked';
                           cont_warn := cont_warn + 1;
                           l_tmp_status := 'Error';
                       END IF;

		       l_det_pack_sts := 'Packed';

 		       IF l_req_cont_num = l_cont_avail_pc THEN
	 	          l_cont_tab(i).pack_status := 'Packed';
			  i := i + 1;
		       END IF;


 		     END IF;

		ELSE -- if line needs to be split

		    l_tmp_split_qty := ROUND(((l_det_pack_qty*l_cont_avail_pc)/l_req_cont_num),LIMITED_PRECISION);

		    --
		    IF l_debug_on THEN
		        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_DECIMAL_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
		    END IF;
		    --
		    WSH_DETAILS_VALIDATIONS.Check_Decimal_Quantity (
					l_det_inv_item_id,
					l_det_org_id,
					l_tmp_split_qty,
					l_det_qty_uom,
					l_split_qty,
					l_discard_status);
                       IF l_debug_on THEN
	                 WSH_DEBUG_SV.log(l_module_name,'return status ' ,l_discard_status);
                       END IF;

		    -- bug 1716136: errors likely mean integers are safe values.
		    IF l_discard_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                        l_discard_message := FND_MESSAGE.GET;
                        l_split_qty := FLOOR(l_tmp_split_qty);
		    END IF;

		    IF l_split_qty IS NULL THEN
			l_split_qty := l_tmp_split_qty;
		    END IF;

		    IF (l_split_qty < 0 OR l_split_qty > l_det_pack_qty) THEN
			FND_MESSAGE.SET_NAME('WSH','WSH_DET_SPLIT_ERROR');
			FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_det_tab(j).delivery_detail_id);
			l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
			l_det_tab(j).pack_status := 'Error';
			error_cnt := error_cnt + 1;
			exit;
		    END IF;

		    IF l_split_qty >= 1 THEN

                      IF l_det_pack_qty = l_split_qty THEN
                        IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'In IF of equal-');
                        END IF;
                        l_split_det_id := l_det_tab(j).delivery_detail_id;
                        IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'DELIVERY DETAIL id'||l_split_det_id);
                        END IF;
                        l_tmp_det_tab(1) := l_split_det_id;
                        l_tmp_det_count := j;
                        l_det_pack_sts := 'Packed';

                      ELSIF l_det_pack_qty > l_split_qty THEN

--- HW OPM BUG# 3011758
-- if lot indivisbile and last container, raise an error
-- else go to the next container
-- HW OPMCONV - 1) Renamed lot_indivisible variable to lot_divisible_flag
--            - 2) Changed check condition for lot divisible from 1 to 'N'
                         IF  ( l_lot_divisible_flag = 'N' AND i = cont_count AND l_det_pack_sts = 'Unpacked') THEN
                           FND_MESSAGE.SET_NAME('WSH','WSH_OPM_IND_SPLIT_PACK');
                           FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_det_tab(j).delivery_detail_id);
                           l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                           WSH_UTIL_CORE.Add_Message(l_return_status);
                           l_det_tab(j).pack_status := 'Error';
                           error_cnt := error_cnt + 1;
                           exit;
-- HW OPMCONV - 1) Renamed lot_indivisible variable to lot_divisible_flag
--            - 2) Changed check condition for lot divisible from 1 to 'N'
                         ELSIF  ( l_lot_divisible_flag = 'N' AND i < cont_count AND l_det_pack_sts = 'Unpacked') THEN
                           goto new_container;
			--dbms_output.put_line('calling split details');

		    	--
		    	ELSE -- non divisible

                          l_split_qty2 := (l_split_qty * l_det_pack_qty2)/l_det_pack_qty;
		    	  IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'l_split_qty',l_split_qty);
                            WSH_DEBUG_SV.log(l_module_name,'l_split_qty2',l_split_qty2);
                            WSH_DEBUG_SV.log(l_module_name,'l_det_pack_qty2',l_det_pack_qty2);
                            WSH_DEBUG_SV.log(l_module_name,'l_det_pack_qty',l_det_pack_qty);
		    	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
		    	  END IF;
		    	--

		    	  WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details (
				p_from_detail_id => l_det_tab(j).delivery_detail_id,
				p_req_quantity => l_split_qty,
				p_req_quantity2 => l_split_qty2,
				x_new_detail_id => l_split_det_id,
				x_return_status =>x_return_status,
                                p_manual_split => 'C'
                                );
			--dbms_output.put_line('...split detail id ' || l_split_det_id);
		    	  IF l_debug_on THEN
		    	    WSH_DEBUG_SV.log(l_module_name,'return status,split det id -',x_return_status||l_split_det_id);
		    	  END IF;

		    	  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
				--dbms_output.put_line('error in splitting');
				FND_MESSAGE.SET_NAME('WSH','WSH_DET_SPLIT_ERROR');
				FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_det_tab(j).delivery_detail_id);
				l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
				l_det_tab(j).pack_status := 'Error';
				error_cnt := error_cnt + 1;
				exit;
		    	  END IF;

			--dbms_output.put_line('after splitting lines');

			-- update detail attributes by decrementing shipped quantity
			-- (if not null) by the split quantity and updating the shipped
			-- quantity of the new line to be eqaul to the split quantity

		   	l_tmp_det_tab(1) := l_split_det_id;
		        l_tmp_det_count := l_det_tab.count + 1;
			l_det_tab(l_tmp_det_count).delivery_detail_id := l_split_det_id;

		      END IF;
		    	--
		    	IF l_debug_on THEN
		    	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.ASSIGN_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
		    	END IF;
		    	--
		    	wsh_container_actions.Assign_Detail (
					l_cont_tab(i).container_instance_id,
				        l_tmp_det_tab,
					l_pack_status,
					x_return_status,FALSE);

		    	IF l_debug_on THEN
		    	    WSH_DEBUG_SV.log(l_module_name,'return status -',x_return_status);
		    	END IF;

		    	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
				l_return_status := x_return_status;
			     END IF;

			     l_det_tab(l_tmp_det_count).pack_status := 'Error';
			     l_cont_tab(i).pack_status := 'Skipped';
			     error_cnt := error_cnt + 1;

		        END IF;

		        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			   l_det_tab(l_tmp_det_count).pack_status := 'Packed';
			   l_cont_tab(i).pack_status := 'Packed';
-- J: W/V Changes

                           WSH_WV_UTILS.Check_Fill_Pc (
                             p_container_instance_id => l_cont_tab(i).container_instance_id,
                             x_fill_status           => l_fill_status,
                             x_return_status         => l_return_status);

                           IF l_fill_status = 'O' THEN
                                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                                   l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                                END IF;

                                l_cont_tab(i).pack_status := 'Overpacked';
                                cont_warn := cont_warn + 1;
                                l_tmp_status := 'Error';
                                GOTO new_container;
                           END IF;

			   l_cont_tab(i).pack_status := 'Packed';

		    	END IF; -- if packing successful
                      END IF; --- of of 3011758
		    ELSE -- split qty < 1 means cannot split - so try next cont

			i := i + 1;

		    END IF; -- if split qty >= 1

		END IF; -- if l_req_cont_num < = l_cont_avail_pc

	     ELSE -- means org ids don't match and so try next container.

		i := i + 1;

	     END IF; -- if l_cont_org_id = l_det_org_id

	     <<new_container>>
		  	i := i + 1;
			l_tmp_status := 'OK';

	     END LOOP;  -- inner loop of containers

	     j := j + 1;

	 END LOOP;    -- outer loop of lines

   -- at end of loop, if all containers had been used, cont_count should be 0
   -- and if all lines had been used, j should be > det_count.
   -- if j <= det_count, then it implies that some lines were unpacked so
   -- issue a warning.

 ELSIF p_pack_mode = 'E' THEN
   -- packing mode is equal - each line is split equally between all containers
   -- and each split line is packed into each container. Packs even if
   -- container is overpacked/underpacked and returns with a warning.

    IF (p_split_pc IS NULL OR p_split_pc = 0) THEN
	l_split_pc := 100/(p_cont_tab.count);
    ELSE
	l_split_pc := p_split_pc;
    END IF;

    FOR j IN 1..det_count LOOP

   	IF l_debug_on THEN
   	  WSH_DEBUG_SV.log(l_module_name,'===========================================');
          WSH_DEBUG_SV.log(l_module_name,'pack mode E: processing detail ' || l_det_tab(j).delivery_detail_id);
   	END IF;

	OPEN Get_Detail_Info (l_det_tab(j).delivery_detail_id);

	FETCH Get_Detail_Info INTO
	    l_det_inv_item_id,
	    l_det_pack_qty,
	    l_det_qty_uom,
	    l_det_net,
	    l_det_volume,
	    l_det_wt_uom,
	    l_det_vol_uom,
	    l_det_org_id,
	    l_det_cont_item_id,
            l_det_pack_qty2;

	IF Get_Detail_Info%NOTFOUND THEN
	    FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
	    FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_det_tab(j).delivery_detail_id);
	    l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    CLOSE Get_Detail_Info;
	    --dbms_output.put_line('error in fetching details for ' || l_det_tab(j).delivery_detail_id);
	    l_det_tab(j).pack_status := 'Error';
	    WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
	    l_tmp_status := 'Error';
	    GOTO next_detail;
 	END IF;

	CLOSE Get_Detail_Info;


-- HW OPM BUG#:3011758. get OPM item information
-- HW OPMCONV - 1)Change the call from OPM API to get item info
--                to a new WSH API
--            - 2) Remove checking for process

          WSH_DELIVERY_DETAILS_INV.Get_item_information
          (
               p_organization_id       => l_det_org_id
              , p_inventory_item_id    => l_det_inv_item_id
              , x_mtl_system_items_rec => l_item_info
              , x_return_status        => l_return_status
            );

     wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );


           IF ( l_item_info.lot_divisible_flag = 'N' AND
                  l_item_info.lot_control_code = 2 ) THEN
             l_lot_divisible_flag := 'N';
           ELSE
             l_lot_divisible_flag := 'Y';
           END IF;

        l_tmp_split_qty := ROUND((l_split_pc*l_det_pack_qty/100),LIMITED_PRECISION);

	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_DECIMAL_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_DETAILS_VALIDATIONS.Check_Decimal_Quantity (
			l_det_inv_item_id,
			l_det_org_id,
			l_tmp_split_qty,
			l_det_qty_uom,
			l_split_qty,
			l_discard_status);

	IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_module_name,'return status-',l_discard_status);
	END IF;

        -- bug 1716136: errors likely mean integers are safe values.
	IF l_discard_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                l_discard_message := FND_MESSAGE.GET;
                l_split_qty := FLOOR(l_tmp_split_qty);
	END IF;
	/* Bug 2173615 - added l_split_qty = 0,in case of fractional split example = 0.3 */
	IF (l_split_qty IS NULL OR l_split_qty = 0) THEN
		l_split_qty := l_tmp_split_qty;
	END IF;

	--dbms_output.put_line('l_split_qty = ' || l_split_qty);
        /* Bug 2173615 ,changed 1 to zero */
        IF l_split_qty < 0 THEN
	   l_split_qty := 1;
	   --dbms_output.put_line('because < 1, l_split_qty now = ' || l_split_qty);
        END IF;

	l_tmp_det_qty := 0;

 	FOR i IN 1..cont_count LOOP

	IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_module_name,'----- packing into container ' || l_cont_tab(i).container_instance_id);
          WSH_DEBUG_SV.log(l_module_name,'Tmp Det Qty,Det Pack Qty,split qty',l_tmp_det_qty||l_det_pack_qty||l_split_qty);
	END IF;
	   --dbms_output.put_line('l_tmp_det_qty = ' || l_tmp_det_qty);
	   --dbms_output.put_line('l_det_pack_qty = ' || l_det_pack_qty);
	   --dbms_output.put_line('l_split_qty = ' || l_split_qty);

	   IF l_tmp_det_qty <= l_det_pack_qty THEN

		OPEN Get_Cont_Info (l_cont_tab(i).container_instance_id);

		FETCH Get_Cont_Info INTO
			l_cont_item_id,
			l_cont_org_id,
			l_cont_gross,
		  	l_cont_net,
		  	l_cont_volume,
		  	l_cont_wt_uom,
		  	l_cont_vol_uom,
	  		l_cont_fill_pc,
		  	l_cont_min_fill_pc,
		  	l_cont_max_load_wt,
	  		l_cont_max_vol;

		IF Get_Cont_Info%NOTFOUND THEN
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			--
			l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_cont_tab(i).container_instance_id);
	   		FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
			FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
		   	-- x_pack_status := 'Error';
		   	l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			l_cont_tab(i).pack_status := 'Error';
	   		CLOSE Get_Cont_Info;
			WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
			cont_err := cont_err + 1;
			l_tmp_status := 'Error';
			GOTO next_container;
 	   	END IF;

	   	CLOSE Get_Cont_Info;

		IF l_cont_org_id = l_det_org_id THEN

		   --dbms_output.put_line('Decision point: compare ' || (l_tmp_det_qty + l_split_qty) || ' with ' || l_det_pack_qty);

		   -- bug 1367540:
		   -- due to round-off errors in calculating floating-point values (e.g., 1/3 = 0.33333...)
		   -- avoid exact comparisons

		   l_tmp_delta := l_det_pack_qty - (l_tmp_det_qty + l_split_qty);

		   IF l_tmp_delta > 0.00001 THEN  -- if (l_tmp_det_qty + l_split_qty) < l_det_pack_qty) then

			--dbms_output.put_line('SPLITTING line ' || l_det_tab(j).delivery_detail_id || ' by ' || l_split_qty);
 	    	   	--

--- HW OPM BUG# 3011758
-- HW OPMCONV - 1) Renamed lot_indivisible variable to lot_divisible_flag
--            - 2) Changed check condition for lot divisible from 1 to 'N'
                      IF  ( l_lot_divisible_flag = 'N' AND i = cont_count AND l_det_pack_sts = 'Unpacked') THEN
                         FND_MESSAGE.SET_NAME('WSH','WSH_OPM_IND_SPLIT_PACK');
                         FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_det_tab(j).delivery_detail_id);
                         l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                         WSH_UTIL_CORE.Add_Message(l_return_status);
                         l_det_tab(j).pack_status := 'Error';
                         error_cnt := error_cnt + 1;
                         exit;
-- HW OPMCONV - 1) Renamed lot_indivisible variable to lot_divisible_flag
--            - 2) Changed check condition for lot divisible from 1 to 'N'
                      ELSIF  ( l_lot_divisible_flag = 'N' AND i < cont_count AND l_det_pack_sts = 'Unpacked') THEN
                        goto next_container;

                      ELSE -- non divisible
                        l_split_qty2 := (l_split_qty * l_det_pack_qty2)/l_det_pack_qty;

 	    	   	IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'l_split_qty',l_split_qty);
                          WSH_DEBUG_SV.log(l_module_name,'l_split_qty2',l_split_qty2);
                          WSH_DEBUG_SV.log(l_module_name,'l_det_pack_qty2',l_det_pack_qty2);
                          WSH_DEBUG_SV.log(l_module_name,'l_det_pack_qty',l_det_pack_qty);
 	    	   	  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
 	    	   	END IF;

  	    	        WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details (
			  p_from_detail_id => l_det_tab(j).delivery_detail_id,
			  p_req_quantity => l_split_qty,
			  p_req_quantity2 => l_split_qty2,
			  x_new_detail_id => l_split_det_id,
			  x_return_status => x_return_status,
                          p_manual_split => 'C'
                                );
 	    	   	IF l_debug_on THEN
 	    	   	   WSH_DEBUG_SV.log(l_module_name,'return status',x_return_status);
 	    	   	END IF;
			--dbms_output.put_line('...split detail id ' || l_split_det_id);

	    	   	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			  FND_MESSAGE.SET_NAME('WSH','WSH_DET_SPLIT_ERROR');
			  FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_det_tab(j).delivery_detail_id);
                          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			  WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
	    		--dbms_output.put_line('error in splitting details for ' || l_det_tab(j).delivery_detail_id);
                          error_cnt := error_cnt + 1;
                          l_det_tab(j).pack_status := 'Error';
                          exit;
	    	   	END IF;
	    	      END IF; -- end of 3011758

			-- update detail attributes by decrementing shipped quantity
			-- (if not null) by the split quantity and updating the shipped
			-- quantity of the new line to be eqaul to the split quantity

	   	   	l_tmp_det_tab(1) := l_split_det_id;
   	           	l_tmp_det_count := l_det_tab.count + 1;
		   	l_det_tab(l_tmp_det_count).delivery_detail_id := l_split_det_id;
  		    	--dbms_output.put_line('split line is  ' || l_split_det_id);

		   ELSIF l_tmp_delta >= -0.00001 THEN -- elsif (l_tmp_det_qty + l_split_qty) = l_det_pack_qty then
			-- Here, l_tmp_delta is between -0.00001 and 0.00001 (see the first IF condition).

			l_split_det_id := l_det_tab(j).delivery_detail_id;
			l_tmp_det_tab(1) := l_det_tab(j).delivery_detail_id;
			l_tmp_det_count := j;
		    	--dbms_output.put_line('NO SPLIT and line is  ' || l_split_det_id);
		   ELSE
			-- bug 1367540: this case had not been handled before,
			-- so when neither condition above was met, the last split detail was reassigned.
			-- The API will return a warning if the container turns out to be overpacked.
			l_split_det_id := l_det_tab(j).delivery_detail_id;
			l_tmp_det_tab(1) := l_det_tab(j).delivery_detail_id;
			l_tmp_det_count := j;
		    	--dbms_output.put_line('NO SPLIT, POSSIBLE OVERPACK and line ' || l_split_det_id || ' will be assigned.');
		   END IF;

		   --dbms_output.put_line('* * * ASSIGNING detail ' || l_tmp_det_tab(1) || ' to container ' || l_cont_tab(i).container_instance_id);

	    	   --
	    	   IF l_debug_on THEN
	    	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.ASSIGN_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
	    	   END IF;
	    	   --
	    	   wsh_container_actions.Assign_Detail (
			l_cont_tab(i).container_instance_id,
		        l_tmp_det_tab,
			l_pack_status,
			x_return_status,FALSE);

 	    	  IF l_debug_on THEN
 	    	    WSH_DEBUG_SV.log(l_module_name,'return status',x_return_status);
 	    	  END IF;

	    	   IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		        --dbms_output.put_line('error in assigning details for ' || l_tmp_det_tab(1));
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
				l_return_status := x_return_status;
			END IF;
		 	error_cnt := error_cnt + 1;
		       	l_det_tab(l_tmp_det_count).pack_status := 'Error';

	           ELSIF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		       --dbms_output.put_line('assigned line ' || l_tmp_det_tab(1));
		       l_det_tab(l_tmp_det_count).pack_status := 'Packed';
		       l_cont_tab(i).pack_status := 'Packed';

-- J: W/V Changes
                       WSH_WV_UTILS.Check_Fill_Pc (
                         p_container_instance_id => l_cont_tab(i).container_instance_id,
                         x_fill_status           => l_fill_status,
                         x_return_status         => l_return_status);

                       IF (l_fill_status = 'O'  AND l_cont_item_id IS NOT NULL) THEN

                          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                            l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                          END IF;

                          cont_warn := cont_warn + 1;
                          l_cont_tab(i).pack_status := 'Overpacked';
                       ELSIF (l_fill_status = 'U'
                                          AND l_cont_item_id IS NOT NULL ) THEN

                          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                            l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                          END IF;

                          cont_warn := cont_warn + 1;
                          l_cont_tab(i).pack_status := 'Underpacked';
                       ELSE
                          l_cont_tab(i).pack_status := 'Packed';
                       END IF;

		   END IF; -- if assign was successful

		   l_tmp_det_qty := l_tmp_det_qty + l_split_qty;
		ELSE
		   --dbms_output.put_line('orgs dont match for detail ' || l_det_tab(j).delivery_detail_id || ' and container ' || l_cont_tab(i).container_instance_id);
		   FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_NO_MATCH');
		   FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_det_tab(j).delivery_detail_id);
		   --
		   IF l_debug_on THEN
		       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		   END IF;
		   --
		   l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_cont_tab(i).container_instance_id);
		   FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);

		END IF; -- cont org and det org id check

	   END IF; -- if l_tmp_det_qty < l_det_pack_qty

           <<next_container>>
		null;

        END LOOP; -- looping though containers - inner loop

        IF (l_tmp_det_qty = l_det_pack_qty) AND (l_det_tab(j).pack_status <> 'Error' ) THEN
	   l_det_tab(j).pack_status := 'Packed';
        END IF;

        l_tmp_det_qty := 0;

	<<next_detail>>
	  	null;

    END LOOP; -- looping through lines - outer loop

 ELSE
   -- packing mode is invalid - did not pack

   FND_MESSAGE.SET_NAME('WSH','WSH_CONT_INVALID_PACK_MODE');
   x_pack_status := 'Error';
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
   --Bugfix 4070732 {
   IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                   x_return_status => l_tmp_return_status);


         IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_tmp_return_status',l_tmp_return_status);
         END IF;

         /*wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
               );
        */
        IF l_tmp_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            X_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        END IF;
      END IF;
   END IF;
   --}
   --
   --IF l_debug_on THEN
   --    WSH_DEBUG_SV.pop(l_module_name);
   --END IF;
   --
   --return;
   raise e_return_excp; -- LPN CONV. rv
 END IF;


 error_cnt := 0;
 warn_cnt := 0;
 succ_cnt := 0;

 cont_warn := 0;
 cont_err := 0;
 x_pack_status := NULL;

 --dbms_output.put_line('l_return_status = ' || l_return_status);

 FOR i IN 1..l_det_tab.count LOOP
	--dbms_output.put_line('detail ' || l_det_tab(i).delivery_detail_id || ' status is ' || l_det_tab(i).pack_status);
	IF l_det_tab(i).pack_status <> 'Packed' THEN
	   IF l_det_tab(i).pack_status = 'Error' THEN
		error_cnt := error_cnt + 1;
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DETAIL_NOT_ASSIGNED');
		FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_det_tab(i).delivery_detail_id);
		WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
           ELSE
		IF l_det_tab(i).pack_status = 'Unpacked' THEN
			FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_IGNORED');
			FND_MESSAGE.SET_TOKEN('DETAIL_ID',l_det_tab(i).delivery_detail_id);
			WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
		END IF;
	        warn_cnt := warn_cnt + 1;
	   END IF;
	ELSE
	   succ_cnt := succ_cnt + 1;
	   /* H projects: pricing integration csun */
	   m := m+1;
	   l_detail_rows(m) := l_det_tab(i).delivery_detail_id;
	END IF;

 END LOOP;

 IF error_cnt > 0 or warn_cnt > 0 THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_DET_PACK_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_COUNT',error_cnt);
    FND_MESSAGE.SET_TOKEN('WARN_COUNT',warn_cnt);
    FND_MESSAGE.SET_TOKEN('SUCC_COUNT',succ_cnt);
    IF error_cnt > 0 THEN
      l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF warn_cnt > 0 THEN
      l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    END IF;

    WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);

    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
   	x_return_status := l_return_status;
    	x_pack_status := 'Error';
        --Bugfix 4070732 {
        IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
           IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
              IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_tmp_return_status);


              IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'l_tmp_return_status',l_tmp_return_status);
              END IF;

              /*wsh_util_core.api_post_call
                   (
                     p_return_status => l_return_status,
                     x_num_warnings  => l_num_warnings,
                     x_num_errors    => l_num_errors
                    );
              */
              IF l_tmp_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                   X_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
              END IF;
           END IF;
        END IF;
        --}
        --
        --IF l_debug_on THEN
        --    WSH_DEBUG_SV.pop(l_module_name);
        --END IF;
        --
        --return;
        raise e_return_excp; -- LPN CONV. rv
    END IF;

 END IF;

 /*  H integration: Pricing integration csun
 */
 IF l_detail_rows.count > 0 THEN
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
	    p_entity_type => 'DELIVERY_DETAIL',
	    p_entity_ids   => l_detail_rows,
	    x_return_status => l_return_status);

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'return status',l_return_status);
       END IF;
	 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	      x_return_status := l_return_status;
	      FND_MESSAGE.SET_NAME('WSH', 'WSH_REPRICE_REQUIRED_ERR');
	      WSH_UTIL_CORE.add_message(x_return_status,l_module_name);
	      --
              --Bugfix 4070732 {
              IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
                 IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
                    IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;

                    WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                              x_return_status => l_tmp_return_status);


                    IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name,'l_tmp_return_status',l_tmp_return_status);
                    END IF;

                    /*wsh_util_core.api_post_call
                         (
                           p_return_status => l_return_status,
                           x_num_warnings  => l_num_warnings,
                           x_num_errors    => l_num_errors
                          );
                    */
                    IF
                     (l_tmp_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                       OR
                     (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                    THEN --{
                       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                    ELSIF x_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR
                    THEN
                       IF l_tmp_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
                       THEN
                          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                       ELSIF l_tmp_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
                       THEN
                          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                       END IF;
                    END IF; --}
                 END IF;
              END IF;
              --}
	      --IF l_debug_on THEN
	      --    WSH_DEBUG_SV.pop(l_module_name);
	      --END IF;
	      --
	      --return;
              raise e_return_excp; -- LPN CONV. rv
	 END IF;
 END IF;



 FOR i IN 1..l_cont_tab.count LOOP
	   --dbms_output.put_line('container ' || l_cont_tab(i).container_instance_id || ' is ' || l_cont_tab(i).pack_status);
	IF l_cont_tab(i).pack_status <> 'Packed' THEN
	   IF l_cont_tab(i).pack_status = 'Error' THEN
		l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		cont_err := cont_err + 1;
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_NOT_PACKED');
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_cont_tab(i).container_instance_id);
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
		WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
	   ELSIF l_cont_tab(i).pack_status = 'Overpacked' THEN
		cont_warn := cont_warn + 1;
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_OVERPACKED');
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_cont_tab(i).container_instance_id);
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
		WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
	        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		        l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		END IF;
	   ELSIF l_cont_tab(i).pack_status = 'Underpacked' THEN
		cont_warn := cont_warn + 1;
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_UNDERPACKED');
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_cont_tab(i).container_instance_id);
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
		WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
	        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		        l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		END IF;
	   ELSIF l_cont_tab(i).pack_status = 'Warning' THEN
		cont_warn := cont_warn + 1;
		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_WT_VOL_FAILED');
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_cont_tab(i).container_instance_id);
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
		WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);

	        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		        l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		END IF;
	   END IF;
	END IF;

 END LOOP;


 -- LPN CONV. rv
 --
 IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
 THEN
 --{

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
       (
         p_in_rec             => l_lpn_in_sync_comm_rec,
         x_return_status      => l_return_status,
         x_out_rec            => l_lpn_out_sync_comm_rec
       );
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
     END IF;
     --
     WSH_UTIL_CORE.API_POST_CALL
       (
         p_return_status    => l_return_status,
         x_num_warnings     => cont_warn,
         x_num_errors       => cont_err,
         p_raise_error_flag => false
       );
 --}
 END IF;
 -- LPN CONV. rv
 --

 IF cont_err > 0 OR cont_warn > 0 THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_PACK_WARN');
 	FND_MESSAGE.SET_TOKEN('CONT_WARN',cont_warn);
	FND_MESSAGE.SET_TOKEN('CONT_ERR',cont_err);
	IF cont_err > 0 THEN
		l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSE
		l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
	WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
 END IF;

 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
 	x_return_status := l_return_status;
 ELSE
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 END IF;

 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    x_pack_status := 'Success';
 ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
    x_pack_status := 'Error';
 ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
    x_pack_status := 'Warning';
    l_num_warnings := nvl(l_num_warnings,0 ) + 1;
 END IF;


 IF x_pack_status IS NULL THEN
	x_pack_status := 'Success';
 END IF;

--Bugfix 4070732 {
IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API) = upper(l_api_session_name) THEN
   IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                  x_return_status => l_tmp_return_status);
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_tmp_return_status',l_tmp_return_status);
      END IF;

      /*wsh_util_core.api_post_call
         (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
         );
      */
      IF (l_tmp_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
         OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
      THEN --{
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         x_pack_status := 'Error';
      ELSIF x_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR
      THEN
         IF l_tmp_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            x_pack_status := 'Error';
         ELSIF l_tmp_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
         THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            x_pack_status := 'Warning';
         END IF;
      END IF; --}

   END IF;
END IF;
--}

 	--
 	IF l_debug_on THEN
 	    WSH_DEBUG_SV.pop(l_module_name);
 	END IF;
 	--
EXCEPTION
  -- LPN CONV. rv
  WHEN e_return_excp THEN
        --
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
        THEN
        --{
             --
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
            WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
              (
                p_in_rec             => l_lpn_in_sync_comm_rec,
                x_return_status      => l_return_status,
                x_out_rec            => l_lpn_out_sync_comm_rec
              );
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
            END IF;
            --
            IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,WSH_UTIL_CORE.G_RET_STS_ERROR) AND x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
            END IF;
        --}
        END IF;
        --
        -- LPN CONV. rv
        --
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_RETURN_EXCP');
        END IF;
  WHEN Others THEN
        --
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Pack_Multi',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
END IF;
        --
        -- LPN CONV. rv
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
        THEN
        --{
             --
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
            WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
              (
                p_in_rec             => l_lpn_in_sync_comm_rec,
                x_return_status      => l_return_status,
                x_out_rec            => l_lpn_out_sync_comm_rec
              );
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
            END IF;
        --}
        END IF;
        --
        -- LPN CONV. rv
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

              /*wsh_util_core.api_post_call
                   (
                     p_return_status => l_return_status,
                     x_num_warnings  => l_num_warnings,
                     x_num_errors    => l_num_errors
                    );
              */
           END IF;
        END IF;
        --}
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Pack_Multi;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Update_Shipped_Qty
   PARAMETERS : p_delivery_detail_id - delivery detail id of the original line
		that was split
		p_split_detail_id - delivery detail id of the newly created
		split line
		p_split_qty - quantity used to split original delivery line
		x_return_status - return status of API
  DESCRIPTION : This procedure updates the shipped quantities of the original
		delivery line that was split and the new line that was created
		due to the split.  The shipped quantity of the original line is
		decremented by split qty and that of the new line is increased
		to be equal to the split qty.  The updating is done only if the
		original shipped quantity is not null.
------------------------------------------------------------------------------
*/



PROCEDURE Update_Shipped_Qty(
  p_delivery_detail_id IN NUMBER,
  p_split_detail_id IN NUMBER,
  p_split_qty IN NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2) IS

 CURSOR Get_Ship_Qty (v_det_id NUMBER) IS
 SELECT nvl(shipped_quantity,-99)
 FROM WSH_DELIVERY_DETAILS
 WHERE delivery_detail_id = v_det_id
 AND   nvl(line_direction,'O') IN ('O','IO')
 AND container_flag = 'N';

 l_shp_qty          NUMBER;
 l_db_split_shp_qty NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_SHIPPED_QTY';
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
     WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_SPLIT_DETAIL_ID',P_SPLIT_DETAIL_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_SPLIT_QTY',P_SPLIT_QTY);
 END IF;
 --
 IF p_split_detail_id IS NULL THEN
   -- nothing split, ergo nothing to update...
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return;
 END IF;

 OPEN Get_Ship_Qty (p_delivery_detail_id);

 FETCH Get_Ship_Qty INTO l_shp_qty;

 IF Get_Ship_Qty%NOTFOUND THEN
	CLOSE Get_Ship_Qty;
   	FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
	FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_delivery_detail_id);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
 END IF;

 IF Get_Ship_Qty%ISOPEN THEN
	CLOSE Get_Ship_Qty;
 END IF;

 IF l_shp_qty = -99 THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
 END IF;


 -- need to look up the split detail's shipped quantity
 -- so that we can correctly adjust the original detail's shipped quantity

 OPEN Get_Ship_Qty(p_split_detail_id);
 FETCH Get_Ship_Qty into l_db_split_shp_qty;

 IF Get_Ship_Qty%NOTFOUND THEN
	CLOSE Get_Ship_Qty;
   	FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
	FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_split_detail_id);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
 END IF;

 CLOSE Get_Ship_Qty;

 IF l_db_split_shp_qty = -99 THEN
	l_db_split_shp_qty := 0;
 END IF;
 --dbms_output.put_line('l_db_split_shp_qty = ' || l_db_split_shp_qty);

 l_shp_qty := l_shp_qty - nvl(p_split_qty,0) + l_db_split_shp_qty;
 --dbms_output.put_line('new l_shp_qty = ' || l_shp_qty);

 UPDATE WSH_DELIVERY_DETAILS
 SET shipped_quantity = l_shp_qty
 WHERE delivery_detail_id = p_delivery_detail_id;

 IF SQL%NOTFOUND THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
	FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_delivery_detail_id);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
 END IF;

 UPDATE WSH_DELIVERY_DETAILS
 SET shipped_quantity = p_split_qty
 WHERE delivery_detail_id = p_split_detail_id;

 IF SQL%NOTFOUND THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
	FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_split_detail_id);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


 	--
 	IF l_debug_on THEN
 	    WSH_DEBUG_SV.pop(l_module_name);
 	END IF;
 	--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Update_Shipped_Qty',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Update_Shipped_Qty;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Pack_Container
   PARAMETERS : p_line_cont_rec - Container info which needs to be autopacked
                x_return_status - Return Status of the API
  DESCRIPTION : This procedure packs a container into Master Container either
                by creating a new one or by packing it into one created for
                previous containers (created in the same run)
------------------------------------------------------------------------------
*/

PROCEDURE Pack_Container(
           p_line_cont_rec IN  cont_info,
           x_return_status OUT NOCOPY  VARCHAR2) IS

  l_quantity_left              NUMBER;
  l_tmp_split_qty         NUMBER;

  i NUMBER;
  j NUMBER;
  gcdvalue NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PACK_CONTAINER';
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
      WSH_DEBUG_SV.log(l_module_name,'shp_qty',p_line_cont_rec.shp_qty);
      WSH_DEBUG_SV.log(l_module_name,'preferred_container',p_line_cont_rec.preferred_container);
      WSH_DEBUG_SV.log(l_module_name,'organization_id',p_line_cont_rec.organization_id);
      WSH_DEBUG_SV.log(l_module_name,'group_id',p_line_cont_rec.group_id);
  END IF;
  --
  l_quantity_left := p_line_cont_rec.shp_qty;

  -- Check Empty Containers first
  IF (g_empty_cont_tab.COUNT > 0 ) THEN
    --dbms_output.put_line('There are containers with empty space');

    i := g_empty_cont_tab.FIRST;
    WHILE i <= g_empty_cont_tab.LAST LOOP
      IF p_line_cont_rec.preferred_container <> g_empty_cont_tab(i).container_item_Id OR
         p_line_cont_rec.organization_id <> g_empty_cont_tab(i).organization_id OR
         p_line_cont_rec.group_id <> g_empty_cont_tab(i).group_id  OR
         g_empty_cont_tab(i).empty <= 0 THEN
        GOTO next_cont;
      END IF;

      -- Got a Match in empty container table
      IF (p_line_cont_rec.fill_pc_basis = 'Q') THEN
        --dbms_output.put_line('Found Container '||g_empty_cont_tab(i).container_index||' with empty numerator '||g_empty_cont_tab(i).numerator||' denominator '||g_empty_cont_tab(i).denominator);
        -- Calculate qty than can fit in 'empty' space
        l_tmp_split_qty := TRUNC((p_line_cont_rec.max_load_qty*g_empty_cont_tab(i).numerator)/g_empty_cont_tab(i).denominator,LIMITED_PRECISION);
        IF (l_tmp_split_qty < 1) THEN
          GOTO next_cont;
        END IF;

      ELSIF (p_line_cont_rec.fill_pc_basis = 'W') THEN
        --dbms_output.put_line('Found Container '||g_empty_cont_tab(i).container_index||' with empty weight '||g_empty_cont_tab(i).empty);
        -- Calculate qty than can fit in 'empty' space
        IF (p_line_cont_rec.converted_wt > g_empty_cont_tab(i).empty) THEN
          GOTO next_cont;
        END IF;
      ELSE
        --dbms_output.put_line('Found Container '||g_empty_cont_tab(i).container_index||' with empty volume '||g_empty_cont_tab(i).empty);
        -- Calculate qty than can fit in 'empty' space
        IF (p_line_cont_rec.converted_vol > g_empty_cont_tab(i).empty) THEN
          GOTO next_cont;
        END IF;
      END IF;

      -- Assign the dd to container
      g_assign_detail_index := g_assign_detail_index + 1;
      g_assign_detail_tab(g_assign_detail_index).delivery_detail_id := p_line_cont_rec.delivery_detail_id;
      g_assign_detail_tab(g_assign_detail_index).container_index := g_empty_cont_tab(i).container_index;
      l_quantity_left := l_quantity_left - p_line_cont_rec.shp_qty;

      --dbms_output.put_line('Assigning '||g_assign_detail_tab(g_assign_detail_index).delivery_detail_id||' to Cont index '||g_assign_detail_tab(g_assign_detail_index).container_index);

      -- Calcualte space left and see if container needs to be deleted from empty cont PL/SQL table
      IF (p_line_cont_rec.fill_pc_basis = 'Q') THEN
        g_empty_cont_tab(i).numerator := (g_empty_cont_tab(i).numerator * p_line_cont_rec.max_load_qty) - (g_empty_cont_tab(i).denominator * p_line_cont_rec.shp_qty);
        g_empty_cont_tab(i).denominator := g_empty_cont_tab(i).denominator * p_line_cont_rec.max_load_qty;

	-- Bug # 3005780 : Added GCD just to reduce the numerator and denominator values
        IF (g_empty_cont_tab(i).numerator <> 0 ) AND (g_empty_cont_tab(i).denominator <> 0 ) THEN
            gcdvalue := Get_Gcd(g_empty_cont_tab(i).numerator , g_empty_cont_tab(i).denominator);
            --dbms_output.put_line('Get_Gcd return value is  '||gcdvalue');
            IF (gcdvalue > 1) THEN
                g_empty_cont_tab(i).numerator := g_empty_cont_tab(i).numerator / gcdvalue;
                g_empty_cont_tab(i).denominator := g_empty_cont_tab(i).denominator / gcdvalue ;
            END IF;
        END IF;
        IF ((g_empty_cont_tab(i).numerator <= 0) OR
            (g_empty_cont_tab(i).numerator >= g_empty_cont_tab(i).denominator)) THEN
          --dbms_output.put_line('Deleting '||g_empty_cont_tab(i).container_index||' from empty cont table');
          g_empty_cont_tab.DELETE(i);
        END IF;
      ELSIF (p_line_cont_rec.fill_pc_basis = 'W') THEN
        g_empty_cont_tab(i).empty := g_empty_cont_tab(i).empty - p_line_cont_rec.gross_weight;
        IF (g_empty_cont_tab(i).empty <= 0) THEN
          --dbms_output.put_line('Deleting '||g_empty_cont_tab(i).container_index||' from empty cont table');
          g_empty_cont_tab.DELETE(i);
        END IF;
      ELSE
        g_empty_cont_tab(i).empty := g_empty_cont_tab(i).empty - p_line_cont_rec.volume;
        IF (g_empty_cont_tab(i).empty <= 0) THEN
          --dbms_output.put_line('Deleting '||g_empty_cont_tab(i).container_index||' from empty cont table');
          g_empty_cont_tab.DELETE(i);
        END IF;
      END IF;

      -- If the whole qty is packed then exit the loop
      IF (l_quantity_left <= 0) THEN
        EXIT;
      END IF;

      <<next_cont>>
        i := g_empty_cont_tab.NEXT(i);
    END LOOP;
  END IF; -- g_empty_cont_tab > 0

  --dbms_output.put_line(' *** Looping empty cont tab is Over and Quantity Left is '||l_quantity_left||' ***');
  IF (l_quantity_left > 0) THEN

    -- Create new container index
    g_new_cont_index := g_new_cont_index + 1;
    g_new_container_tab(g_new_cont_index).container_item_id := p_line_cont_rec.preferred_container;
    g_new_container_tab(g_new_cont_index).organization_id   := p_line_cont_rec.organization_id;
    --dbms_output.put_line('Created Container index '||g_new_cont_index);

    -- Assign the split dd/existing dd
    g_assign_detail_index := g_assign_detail_index + 1;
    g_assign_detail_tab(g_assign_detail_index).delivery_detail_id := p_line_cont_rec.delivery_detail_id;
    g_assign_detail_tab(g_assign_detail_index).container_index    := g_new_cont_index;
    --dbms_output.put_line('Assigning '||g_assign_detail_tab(g_assign_detail_index).delivery_detail_id||' to Cont index '||g_assign_detail_tab(g_assign_detail_index).container_index);


    IF (g_empty_cont_tab.COUNT = 0) THEN
      j := 1;
    ELSE
      j:= g_empty_cont_tab.LAST + 1;
    END IF;

    -- Calculate Empty Space
    IF (p_line_cont_rec.fill_pc_basis = 'Q') THEN
      IF (l_quantity_left < p_line_cont_rec.max_load_qty) THEN
        g_empty_cont_tab(j).container_index   := g_new_cont_index;
        g_empty_cont_tab(j).container_item_id := p_line_cont_rec.preferred_container;
        g_empty_cont_tab(j).organization_id   := p_line_cont_rec.organization_id;
        g_empty_cont_tab(j).group_id          := p_line_cont_rec.group_id;
        g_empty_cont_tab(j).numerator         := p_line_cont_rec.max_load_qty - l_quantity_left;
        g_empty_cont_tab(j).denominator       := p_line_cont_rec.max_load_qty;
        --dbms_output.put_line('Inserted Container '||j||' with numerator '||g_empty_cont_tab(j).numerator||' and denominator '||g_empty_cont_tab(j).denominator);
      END IF;
    ELSIF (p_line_cont_rec.fill_pc_basis in ('W','V')) THEN
      IF ((p_line_cont_rec.converted_wt < p_line_cont_rec.cont_wt AND p_line_cont_rec.fill_pc_basis = 'W') OR
          (p_line_cont_rec.converted_vol < p_line_cont_rec.cont_vol AND p_line_cont_rec.fill_pc_basis = 'V')) THEN
        g_empty_cont_tab(j).container_index   := g_new_cont_index;
        g_empty_cont_tab(j).container_item_id := p_line_cont_rec.preferred_container;
        g_empty_cont_tab(j).organization_id   := p_line_cont_rec.organization_id;
        g_empty_cont_tab(j).group_id          := p_line_cont_rec.group_id;

        IF (p_line_cont_rec.fill_pc_basis = 'W') THEN
          g_empty_cont_tab(j).empty             := p_line_cont_rec.cont_wt - p_line_cont_rec.converted_wt;
          --dbms_output.put_line('Inserted Container '||j||' with empty weight '||g_empty_cont_tab(j).empty||' into empty cont');
        ELSE
          g_empty_cont_tab(j).empty             := p_line_cont_rec.cont_vol - p_line_cont_rec.converted_vol;
          --dbms_output.put_line('Inserted Container '||j||' with empty volume '||g_empty_cont_tab(j).empty||' into empty cont');
        END IF;

      END IF;
    END IF;

  END IF;
  x_return_status := C_SUCCESS_STATUS;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN Others THEN
        WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Pack_Container',l_module_name);
        x_return_status := C_UNEXP_ERROR_STATUS;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Pack_Container;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Validate_Container_For_Pack
   PARAMETERS : p_group_id_tab_id - table of group ids for lines that need to
                                    be autopacked.
                p_cont_info_tab  - table of Container ids
                x_line_cont_tab   - Delivery Detail(Cont)s along with other info
                                    which passed validations
                x_error_cnt       - Count of errors encountered during validation
                x_warn_cnt        - Count of warnings encountered during validation
  DESCRIPTION : This procedure takes a list of containers and does all
                validations and returns a list of containers which passed
                validations
------------------------------------------------------------------------------
*/
-- Bug 3570364 : Added new parameter p_mast_cont_info_tab which contains the
--               Master container informations which is used when Auto_pack Master
--               action performed on delivery detail lines

PROCEDURE Validate_Container_For_Pack(
  p_group_id_tab       IN  WSH_UTIL_CORE.id_tab_type,
  p_cont_info_tab      IN  wsh_util_core.id_tab_type,
  p_mast_cont_info_tab IN wsh_container_actions.empty_cont_info_tab,
  x_line_cont_tab      OUT NOCOPY  wsh_container_actions.cont_info_tab,
  x_error_cnt          OUT NOCOPY  NUMBER,
  x_warn_cnt           OUT NOCOPY  NUMBER,
  x_fill_pc_warn_cnt   OUT NOCOPY  NUMBER -- bug 3421823
  ) IS

--Bug 3405853 : Added detail_container_item_id in the select clause
  CURSOR Get_dd_Detail(c_dd_id NUMBER) IS
  SELECT wdd.inventory_item_id inventory_item_id,
         wdd.gross_weight gross_weight,
         wdd.weight_uom_code weight_uom,
         wdd.volume volume,
         wdd.volume_uom_code volume_uom,
         wdd.organization_id organization_id,
         wdd.delivery_detail_id,
         wda.parent_delivery_detail_id parent_delivery_detail_id,
	 nvl(wdd.detail_container_item_id,wdd.master_container_item_id) detail_container_item_id
  FROM   wsh_delivery_details wdd,
         wsh_delivery_assignments_v wda
  WHERE  wdd.delivery_detail_id = c_dd_id
  AND    wdd.delivery_detail_id = wda.delivery_detail_id
  AND    source_code = 'WSH';

  CURSOR Get_Cont_Item_Load (v_inv_item_id NUMBER, v_cont_item_id NUMBER, v_organization_id NUMBER) IS
  SELECT max_load_quantity
  FROM   WSH_CONTAINER_ITEMS
  WHERE  load_item_id           = v_inv_item_id
  AND    container_item_id      = v_cont_item_id
  AND    master_organization_id = v_organization_id;

  line_cont_rec wsh_container_actions.cont_info;
  line_cont_tab wsh_container_actions.cont_info_tab;

  l_return_status        VARCHAR2(1);
  l_last_organization_id NUMBER;
  l_dd_count             NUMBER;
  l_group_id_cnt         NUMBER;
  l_group_id             NUMBER;
  l_parent_delivery_detail_id NUMBER;
  l_error_cnt            NUMBER;
  l_process_flag         VARCHAR2(1);
  l_fill_pc_basis        VARCHAR2(1);
  l_wcl_cont_item_id     NUMBER;
  l_max_load_qty         NUMBER;
  l_dd_gross_wt          NUMBER;
  l_dd_net_wt            NUMBER;
  l_dd_volume            NUMBER;
  l_cont_fill_pc         NUMBER;
  l_cont_name            VARCHAR2(30);
  l_mtl_max_load         NUMBER;
  l_mtl_max_vol          NUMBER;
  l_mtl_wt_uom           VARCHAR2(3);
  l_mtl_vol_uom          VARCHAR2(3);
  l_item_name		VARCHAR2(2000); -- <-- for Bug 3577115
  --Bug #3405853
  l_detail_container_item_id  NUMBER;


  error_cnt              NUMBER := 0;
  warn_cnt               NUMBER := 0;

  fill_pc_warn_cnt       NUMBER := 0; -- 3562797 jckwok
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_CONTAINER_FOR_PACK';
--
BEGIN


  -- 10. Populate  detail dd info into line_cont_tab PL/SQL table
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
      WSH_DEBUG_SV.log(l_module_name,'---------------------------------');
      WSH_DEBUG_SV.log(l_module_name,'In Validate_Container_For_Pack...');
      WSH_DEBUG_SV.log(l_module_name,'---------------------------------');
  END IF;
  --
  l_last_organization_id := NULL;
  l_dd_count := 0;
  l_group_id_cnt := 1;

  WHILE ( l_group_id_cnt <= p_cont_info_tab.COUNT )
  LOOP
    --dbms_output.put_line('Processing dd '||p_cont_info_tab(l_group_id_cnt));

     OPEN get_dd_detail(p_cont_info_tab(l_group_id_cnt));

     FETCH get_dd_detail
     INTO  line_cont_rec.inventory_item_id,
           line_cont_rec.gross_weight,
           line_cont_rec.weight_uom,
           line_cont_rec.volume,
           line_cont_rec.volume_uom,
           line_cont_rec.organization_id,
           line_cont_rec.delivery_detail_id,
           l_parent_delivery_detail_id,
	   l_detail_container_item_id;
     IF (get_dd_detail%NOTFOUND) THEN
       CLOSE get_dd_detail;
       goto next_cont;
     END IF;

     CLOSE get_dd_detail;

    -- 10.10 Delete Organization Specfic Cached Tables if organization_id changes
    IF ((l_last_organization_id IS NULL) OR (line_cont_rec.organization_id <> l_last_organization_id)) THEN
      g_cache_cont_load_info_tab.DELETE;
      g_cont_msi_tab.DELETE;

      l_last_organization_id := line_cont_rec.organization_id;
    END IF;

    /* grouping API will return a number = negative delivery_id if the line is
       already assigned to a delivery. So, check for negative numbers and if number
       < 0, then convert it to a postive number = delivery_id.
    */
    l_group_id := ABS(p_group_id_tab(p_cont_info_tab(l_group_id_cnt)));
    --dbms_output.put_line('l_group_id '||l_group_id);

    -- 10.20 Check if the detail is already packed
    IF (l_parent_delivery_detail_id IS NOT NULL) THEN
      --dbms_output.put_line('Warning: cont already packed');
      warn_cnt := warn_cnt + 1;
      goto next_cont;
    END IF;

    -- 10.30 Determine Fill PC Basis from shipping parameters
    Calc_Fill_Basis_and_Proc_Flag(
      p_organization_id => line_cont_rec.organization_id,
      x_return_status   => l_return_status,
      x_fill_basis      => l_fill_pc_basis,
      x_process_flag    => l_process_flag);
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'return status',l_return_status);
    END IF;
    IF (l_return_status <> C_SUCCESS_STATUS) THEN
      error_cnt := error_cnt + 1;
      goto next_cont;
    END IF;

    line_cont_rec.fill_pc_basis := l_fill_pc_basis;
    IF (line_cont_rec.fill_pc_basis IS NULL) THEN
      --dbms_output.put_line('Skipping cont');
      goto next_cont;
    --
    -- bug 3562797 jckwok
    -- check Shipping Parameter Fill Percent Basis.
    --
    ELSIF line_cont_rec.fill_pc_basis='N' THEN
      fill_pc_warn_cnt := fill_pc_warn_cnt + 1;
      goto next_cont;
    END IF;
    -- end of bug 3562797
    -- 10.40 Determine Preferred Container
    -- Bug 3405853 : First check the detail lpn entered if it is null
    --               then consider the preferred container.
    -- Bug 3570364 : First check the master container item for the line ( Auto Pack Master action on Lines)
    --               If it is NULL then check for the Detail container item for the
    --               LPN ( Auto Pack Action on LPN's)
    IF p_mast_cont_info_tab.exists(l_group_id_cnt) THEN
      line_cont_rec.preferred_container := nvl(p_mast_cont_info_tab(l_group_id_cnt).container_item_id,l_detail_container_item_id);
    ELSE
      line_cont_rec.preferred_container := l_detail_container_item_id;
    END IF;
    line_cont_rec.max_load_qty := NULL;

    IF (line_cont_rec.preferred_container IS NULL) THEN
      Calc_Pref_Container(
        p_organization_id   => line_cont_rec.organization_id,
        p_inventory_item_id => line_cont_rec.inventory_item_id,
        p_fill_pc_basis     => line_cont_rec.fill_pc_basis,
        x_return_status     => l_return_status,
        x_error_cnt         => l_error_cnt,
        x_cont_item_id      => l_wcl_cont_item_id,
        x_max_load_qty      => l_max_load_qty);
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'return status',l_return_status);
    END IF;
      IF (l_return_status = C_ERROR_STATUS) THEN
        error_cnt := error_cnt + l_error_cnt;
      END IF;

      line_cont_rec.preferred_container := l_wcl_cont_item_id;
      line_cont_rec.max_load_qty        := l_max_load_qty;
    END IF;

    -- bug 3440811
    validate_container(
      p_organization_id  => line_cont_rec.organization_id,
      p_cont_item_id     => line_cont_rec.preferred_container,
      x_return_status    => l_return_status);

    IF (l_return_status IN (C_UNEXP_ERROR_STATUS,C_ERROR_STATUS)) THEN
        line_cont_rec.preferred_container := null;
        line_cont_rec.max_load_qty := null;
        l_error_cnt := l_error_cnt + 1;
        error_cnt := error_cnt + l_error_cnt;
    END IF;
    -- bug 3440811

    IF (line_cont_rec.preferred_container is NULL) THEN
      --dbms_output.put_line('Skipping cont');
      goto next_cont;
    END IF;

    -- 10.50 Calculate Max Load/Converted wt/Converted Vol depending on fill basis
    line_cont_rec.converted_wt := NULL;
    line_cont_rec.converted_vol := NULL;

    IF (line_cont_rec.fill_pc_basis = 'Q') THEN
      IF (line_cont_rec.max_load_qty IS NULL) THEN
        OPEN Get_Cont_Item_Load (line_cont_rec.inventory_item_id,line_cont_rec.preferred_container, line_cont_rec.organization_id);

        FETCH Get_Cont_Item_Load
        INTO  l_max_load_qty;

        IF Get_Cont_Item_Load%NOTFOUND THEN
          --dbms_output.put_line('Could not find max load qty for Item'||line_cont_rec.inventory_item_id||' Cont '||line_cont_rec.preferred_container||' Org '||line_cont_rec.organization_id);
          CLOSE Get_Cont_Item_Load;

          -- Calculate max load qty depending on Weight/Volume
          IF (line_cont_rec.gross_weight IS NULL OR line_cont_rec.volume IS NULL) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_CONTAINER_PKG.CONTAINER_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
-- J: W/V Changes
            WSH_WV_UTILS.Container_Weight_Volume(
                 p_container_instance_id => line_cont_rec.delivery_detail_id,
                 p_override_flag      => 'Y',
                 p_post_process_flag  => 'Y',
                 p_calc_wv_if_frozen  => 'N',
                 x_gross_weight       => l_dd_gross_wt,
                 x_net_weight         => l_dd_net_wt,
                 x_volume             => l_dd_volume ,
                 p_fill_pc_flag       => 'N',
                 x_cont_fill_pc       => l_cont_fill_pc,
                 x_return_status      => l_return_status);

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'return status',l_return_status);
            END IF;
            IF (l_return_status <> C_SUCCESS_STATUS) THEN
              --dbms_output.put_line('WSH_TPA_CONTAINER_PKG.Container_Weight_Volume did not return success');
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(line_cont_rec.delivery_detail_id);
              FND_MESSAGE.SET_NAME('WSH','WSH_CONT_WT_VOL_FAILED');
              FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
              IF l_return_status = C_WARNING_STATUS THEN
                warn_cnt := warn_cnt + 1;
              ELSE
                error_cnt := error_cnt + 1;
              END IF;
              --dbms_output.put_line('Skipping this cont');
              goto next_cont;
            END IF;

            line_cont_rec.gross_weight := NVL(line_cont_rec.gross_weight,l_dd_gross_wt);
            line_cont_rec.volume     := NVL(line_cont_rec.volume,l_dd_volume);

            IF ((NVL(line_cont_rec.gross_weight,0) = 0) OR
                (NVL(line_cont_rec.volume,0) = 0)) THEN
              --dbms_output.put_line('Weight or Volume is NULL or 0');
              FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_WT_ERROR');
              WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
              error_cnt := error_cnt + 1;
              --dbms_output.put_line('Skipping this cont');
              goto next_cont;
            END IF;
          END IF;

--dbms_output.put_line('Call to GET CONT LOAD VOL INFO 2');
          Get_Cont_Load_Vol_info(
             p_container_item_id => line_cont_rec.preferred_container,
             p_organization_id   => line_cont_rec.organization_id,
             p_w_v_both          => 'B',
             x_max_load          => l_mtl_max_load,
             x_max_vol           => l_mtl_max_vol,
             x_wt_uom            => l_mtl_wt_uom,
             x_vol_uom           => l_mtl_vol_uom,
             x_return_status     => l_return_status,
             x_error_cnt         => l_error_cnt);
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'return status',l_return_status);
            END IF;
          IF (l_return_status = C_ERROR_STATUS) THEN
            error_cnt := error_cnt + l_error_cnt;
          END IF;

          IF ((NVL(l_mtl_max_load,0) <= 0) OR (NVL(l_mtl_max_vol,0) <= 0)) THEN
            --dbms_output.put_line('Skipping this Cont');
            goto next_cont;
          END IF;

          IF (l_mtl_wt_uom <> line_cont_rec.weight_uom) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            l_dd_gross_wt := WSH_WV_UTILS.Convert_Uom (
                                  from_uom => line_cont_rec.weight_uom,
                                  to_uom   => l_mtl_wt_uom,
                                  quantity => line_cont_rec.gross_weight,
                                  item_id  => line_cont_rec.inventory_item_id);
          ELSE
            l_dd_gross_wt := line_cont_rec.gross_weight;
          END IF;

          IF (l_mtl_vol_uom <> line_cont_rec.volume_uom) THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            l_dd_volume :=  WSH_WV_UTILS.Convert_Uom (
                                  from_uom => line_cont_rec.volume_uom,
                                  to_uom   => l_mtl_vol_uom,
                                  quantity => line_cont_rec.volume,
                                  item_id  => line_cont_rec.inventory_item_id);
          ELSE
            l_dd_volume:= line_cont_rec.volume;
          END IF;

          IF ((l_mtl_max_load/l_dd_gross_wt) >= (l_mtl_max_vol/l_dd_volume)) THEN
            l_max_load_qty := l_mtl_max_load/l_dd_gross_wt;
          ELSE
            l_max_load_qty := l_mtl_max_vol/l_dd_volume;
          END IF;
          --dbms_output.put_line('l_dd_gross_wt '||l_dd_gross_wt||' l_dd_volume '||l_dd_volume ||' l_mtl_max_load '||l_mtl_max_load||' l_mtl_max_vol '||l_mtl_max_vol || ' l_max_load_qty '||l_max_load_qty);

          -- Containers cannot be split. So take FLOOR of l_max_load_qty
          l_max_load_qty := FLOOR(l_max_load_qty);

        ELSE -- Get_Cont_Item_Load%NOTFOUND
          CLOSE Get_Cont_Item_Load;
        END IF;
        line_cont_rec.max_load_qty := l_max_load_qty;

        IF (NVL(line_cont_rec.max_load_qty,0) <= 0) THEN
          --dbms_output.put_line('Max Load Qty is null or <= 0. Skipping this container');
          FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_WT_ERROR');
          WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
          error_cnt := error_cnt + 1;
          goto next_cont;
        END IF;

      END IF; -- line_cont_rec.max_load_qty IS NULL
      --dbms_output.put_line('line_cont_rec.max_load_qty '||line_cont_rec.max_load_qty);
    ELSIF (line_cont_rec.fill_pc_basis in ('W','V')) THEN
      -- Calculate max load qty depending on Weight
      IF ((line_cont_rec.gross_weight IS NULL AND line_cont_rec.fill_pc_basis = 'W') OR
          (line_cont_rec.volume IS NULL AND line_cont_rec.fill_pc_basis = 'V')) THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_CONTAINER_PKG.CONTAINER_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
-- J: W/V Changes
        WSH_WV_UTILS.Container_Weight_Volume(
             p_container_instance_id => line_cont_rec.delivery_detail_id,
             p_override_flag      => 'Y',
             p_post_process_flag  => 'Y',
             p_calc_wv_if_frozen  => 'N',
             x_gross_weight       => l_dd_gross_wt,
             x_net_weight         => l_dd_net_wt,
             x_volume             => l_dd_volume ,
             p_fill_pc_flag       => 'N',
             x_cont_fill_pc       => l_cont_fill_pc,
             x_return_status      => l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status',l_return_status);
        END IF;
        IF (l_return_status <> C_SUCCESS_STATUS) THEN
          --dbms_output.put_line('WSH_TPA_CONTAINER_PKG.Container_Weight_Volume did not return success');
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(line_cont_rec.delivery_detail_id);
          FND_MESSAGE.SET_NAME('WSH','WSH_CONT_WT_VOL_FAILED');
          FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
          IF l_return_status = C_WARNING_STATUS THEN
            warn_cnt := warn_cnt + 1;
          ELSE
            error_cnt := error_cnt + 1;
          END IF;
          error_cnt := error_cnt + 1;
          --dbms_output.put_line('Skipping this cont');
          goto next_cont;
        END IF;

        IF (line_cont_rec.fill_pc_basis = 'W') THEN
          line_cont_rec.gross_weight := NVL(line_cont_rec.gross_weight,l_dd_gross_wt);

          IF (NVL(line_cont_rec.gross_weight,0) = 0) THEN
            --dbms_output.put_line('Weight is NULL or 0');
                --BUG 3577115
		   --FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_WT_ERROR');
		    l_item_name := WSH_UTIL_CORE.Get_Item_Name(line_cont_rec.inventory_item_id, line_cont_rec.organization_id);
		    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_NULL_WEIGHT_VOLUME');
		    FND_MESSAGE.SET_TOKEN('CONT_NAME',l_item_name);
		--BUG 3577115
            WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
            error_cnt := error_cnt + 1;
            --dbms_output.put_line('Skipping this Cont');
            goto next_cont;
          END IF;
        ELSE
          line_cont_rec.volume := NVL(line_cont_rec.volume,l_dd_volume);

          IF (NVL(line_cont_rec.volume,0) = 0) THEN
            --dbms_output.put_line('Volume is NULL or 0');
               --BUG 3577115
		   --FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_VOL_ERROR');
		    l_item_name := WSH_UTIL_CORE.Get_Item_Name(line_cont_rec.inventory_item_id, line_cont_rec.organization_id);
		    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_NULL_WEIGHT_VOLUME');
		    FND_MESSAGE.SET_TOKEN('CONT_NAME',l_item_name);
		--BUG 3577115
             WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
             error_cnt := error_cnt + 1;
            --dbms_output.put_line('Skipping this Cont');
            goto next_cont;
          END IF;
        END IF;
      END IF;
--dbms_output.put_line('Call to GET CONT LOAD VOL INFO 1');
      Get_Cont_Load_Vol_info(
         p_container_item_id => line_cont_rec.preferred_container,
         p_organization_id   => line_cont_rec.organization_id,
         p_w_v_both          => line_cont_rec.fill_pc_basis,
         x_max_load          => l_mtl_max_load,
         x_max_vol           => l_mtl_max_vol,
         x_wt_uom            => l_mtl_wt_uom,
         x_vol_uom           => l_mtl_vol_uom,
         x_return_status     => l_return_status,
         x_error_cnt         => l_error_cnt);
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'return status',l_return_status);
      END IF;
      IF (l_return_status = C_ERROR_STATUS) THEN
        error_cnt := error_cnt + l_error_cnt;
      END IF;

      IF (line_cont_rec.fill_pc_basis = 'W') THEN
        IF (NVL(l_mtl_max_load,0) <= 0) THEN
          --dbms_output.put_line('Skipping this Cont');
          goto next_cont;
         END IF;

        line_cont_rec.cont_wt := l_mtl_max_load;

        IF (l_mtl_wt_uom <> line_cont_rec.weight_uom) THEN
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          l_dd_net_wt :=  WSH_WV_UTILS.Convert_Uom (
                                from_uom => line_cont_rec.weight_uom,
                                to_uom   => l_mtl_wt_uom,
                                quantity => line_cont_rec.gross_weight,
                                item_id  => line_cont_rec.inventory_item_id);
        ELSE
          l_dd_net_wt := line_cont_rec.gross_weight;
        END IF;


        line_cont_rec.converted_wt := l_dd_net_wt;
        --dbms_output.put_line('line_cont_rec.converted_wt '||line_cont_rec.converted_wt);
      ELSE
        IF (NVL(l_mtl_max_vol,0) <= 0) THEN
          --dbms_output.put_line('Skipping this Cont');
          goto next_cont;
         END IF;

        line_cont_rec.cont_vol := l_mtl_max_vol;

        IF (l_mtl_vol_uom <> line_cont_rec.volume_uom) THEN
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          l_dd_volume :=  WSH_WV_UTILS.Convert_Uom (
                                from_uom => line_cont_rec.volume_uom,
                                to_uom   => l_mtl_vol_uom,
                                quantity => line_cont_rec.volume,
                                item_id  => line_cont_rec.inventory_item_id);
        ELSE
          l_dd_volume := line_cont_rec.volume;
        END IF;
        line_cont_rec.converted_vol := l_dd_volume;
        --dbms_output.put_line('line_cont_rec.converted_vol '||line_cont_rec.converted_vol);
      END IF;

      -- Check if the Master container can hold atleast 1 piece of the Detail Container
      IF  ((line_cont_rec.fill_pc_basis = 'W' AND (line_cont_rec.converted_wt > l_mtl_max_load)) OR
           (line_cont_rec.fill_pc_basis = 'V' AND (line_cont_rec.converted_vol > l_mtl_max_vol))) THEN
        --dbms_output.put_line('Indivisible flag is Y and Preferred Mast Cont cannot hold atleast 1 piece');
	-- Bug#: 2503937 - New Error Message
        FND_MESSAGE.SET_NAME('WSH','WSH_CONT_MAX_WT_VOL_ERROR');
        WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
        error_cnt := error_cnt + 1;
        --dbms_output.put_line('Skipping this Cont');
        goto next_cont;
      END IF;
    END IF;

    -- 10.60 Populate line_cont_tab PL/SQL table now
    line_cont_rec.group_id  := l_group_id;
    line_cont_rec.shp_qty   := 1;
    line_cont_rec.req_qty   := 1;

    l_dd_count := l_dd_count + 1;
    line_cont_tab(l_dd_count) := line_cont_rec;

    <<next_cont>>
      l_group_id_cnt := l_group_id_cnt + 1;

  END LOOP;

  x_error_cnt     := error_cnt;
  x_warn_cnt      := warn_cnt;
  x_line_cont_tab := line_cont_tab;
  x_fill_pc_warn_cnt := fill_pc_warn_cnt; -- bug 3562797 jckwok

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'p_cont_info_tab count->'||p_cont_info_tab.count||' x_line_cont_tab count->'||x_line_cont_tab.count);
    WSH_DEBUG_SV.log(l_module_name,'Error Count '|| error_cnt||' Warning Count '|| warn_cnt);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  RETURN;

EXCEPTION
  WHEN Others THEN
    IF (Get_dd_Detail%ISOPEN) THEN
      CLOSE Get_dd_Detail;
    END IF;
    IF (Get_Cont_Item_Load%ISOPEN) THEN
      CLOSE Get_Cont_Item_Load;
    END IF;
    WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Validate_Container_For_Pack',l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
    raise;

END Validate_Container_For_Pack;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Auto_Pack_Conts
   PARAMETERS : p_group_id_tab_id - table of group ids for containers that need
		to be autopacked.
  		p_det_cont_info - table of detail containers created during the
		autopack process consisting of container instances, master
		container item ids and percentage empty.
		p_cont_detail_tab - table of container delivery detail ids that
		were created during the autopacking of lines.
		x_cont_instance_id - table of container instance ids that were
			created during the autopacking.
		x_return_status - return status of API.
  DESCRIPTION : This procedure takes the number of containers and groups them
		by common grouping attributes - similar to grouping attributes
		of delivery.  If a group id table is specified it uses the
		group ids in the table to decided which container can be
		grouped	into the same parent container. If a group id table is
		not specified, it creates the group id table before autopacking
		It creates the required number and type of parent containers
		per detail container and keeps track of all partially filled
		containers in the empty containers table. Before creating new
		container instances, it	searches for available space using the
		empty container table and after filling up a container, it
		creates a new one if there are no empty containers of the same
		type. The difference between this API and the autopack lines is
		that this API does not split containers if they don't fit
		entirely into a parent container.
------------------------------------------------------------------------------
*/

PROCEDURE Auto_Pack_Conts (
  p_group_id_tab      IN     WSH_UTIL_CORE.id_tab_type,
  p_cont_info_tab     IN     wsh_container_actions.empty_cont_info_tab,
  p_cont_detail_tab   IN     WSH_UTIL_CORE.id_tab_type,
  x_cont_instance_tab IN OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
  x_return_status OUT NOCOPY  VARCHAR2) IS

  line_cont_rec wsh_container_actions.cont_info;
  line_cont_tab wsh_container_actions.cont_info_tab;

  l_group_id_temp_tab         WSH_UTIL_CORE.id_tab_type;
  l_group_id_tab         WSH_UTIL_CORE.id_tab_type;
  l_del_row_tab          WSH_UTIL_CORE.id_tab_type;
  l_return_status        VARCHAR2(1);
  l_cont_instance_id     NUMBER;
  l_row_id               VARCHAR2(30);
  l_gross_weight         NUMBER;
  l_net_weight           NUMBER;
  l_volume               NUMBER;
  l_err_cont_name        VARCHAR2(30);
  l_cont_instance_cnt    NUMBER;
  l_last_organization_id NUMBER;
  l_cont_fill_pc         NUMBER;
  l_cont_name            VARCHAR2(30);


  l_attr_tab  wsh_delivery_autocreate.grp_attr_tab_type;
  l_group_tab  wsh_delivery_autocreate.grp_attr_tab_type;
  l_action_rec wsh_delivery_autocreate.action_rec_type;
  l_target_rec wsh_delivery_autocreate.grp_attr_rec_type;
  l_matched_entities wsh_util_core.id_tab_type;
  l_out_rec wsh_delivery_autocreate.out_rec_type;


  i   NUMBER;
  cnt NUMBER;

  error_cnt NUMBER := 0;
  succ_cnt  NUMBER  := 0;
  warn_cnt  NUMBER  := 0;
  cont_warn NUMBER := 0;

  l_fill_pc_warn_count NUMBER := 0; -- bug 3562797 jckwok

  CURSOR c_get_detail(p_del_det_id NUMBER) IS
  SELECT nvl(ignore_for_planning, 'N') ignore_for_planning,
         organization_id,                        -- K LPN CON. rv
         nvl(line_direction,'O') line_direction  -- K LPN CONV. rv
  FROM wsh_delivery_details
  WHERE delivery_detail_id=p_del_det_id;

-- K LPN CONV. rv
l_wms_org    VARCHAR2(10) := 'N';
l_sync_tmp_rec wsh_glbl_var_strct_grp.sync_tmp_rec_type;
l_cont_tab wsh_util_core.id_tab_type;
l_lpn_unit_weight NUMBER;
l_lpn_unit_volume NUMBER;
l_lpn_weight_uom_code VARCHAR2(100);
l_lpn_volume_uom_code VARCHAR2(100);
l_cnt_orgn_id NUMBER;
l_cnt_line_dir VARCHAR2(10);
l_cnt_ignore_plan_flag VARCHAR2(10);
-- K LPN CONV. rv
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTO_PACK_CONTS';
--
BEGIN

  --dbms_output.put_line('==================================================');
  --dbms_output.put_line('Start of WSH_CONTAINER_ACTIONS.Auto_Pack_Conts...');
  --dbms_output.put_line('==================================================');

  -- Delete all Global PL/SQL tables to start with
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
  g_empty_cont_tab.DELETE;
  g_assign_detail_tab.DELETE;
  g_new_container_tab.DELETE;
  g_cache_organization_info_tab.DELETE;
  g_cont_msi_tab.DELETE;
  g_new_cont_index := 0;
  g_assign_detail_index := 0;

  -- 10. Check if Count of p_del_detail_tab table is 0
  --IF (p_cont_detail_tab.COUNT = 0 OR p_cont_info_tab.COUNT = 0) THEN
  IF (p_cont_detail_tab.COUNT = 0) THEN
    --dbms_output.put_line('p_cont_detail_tab count is 0');
    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_CONT_ASSG_NULL');
    x_return_status := C_ERROR_STATUS;
    WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
  END IF;

  -- 20. Generate Grouping Ids
  IF p_group_id_tab.COUNT = 0 THEN

    -- call autocreate delivery API with a check flag set to 'Y' and
    -- container flag set to 'Y' to fetch group id table for delivery lines

    --dbms_output.put_line('Calling WSH_DELIVERY_AUTOCREATE.autocreate_deliveries to generate group_ids');
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.AUTOCREATE_DELIVERIES',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
   l_attr_tab.delete;
   FOR i in 1..p_cont_detail_tab.count LOOP

       l_attr_tab(i).entity_id := p_cont_detail_tab(i);
       l_attr_tab(i).entity_type := 'DELIVERY_DETAIL';

   END LOOP;

   l_action_rec.action := 'MATCH_GROUPS';



   WSH_Delivery_AutoCreate.Find_Matching_Groups(p_attr_tab => l_attr_tab,
                                                   p_action_rec => l_action_rec,
                                                   p_target_rec => l_target_rec,
                                                   p_group_tab => l_group_tab,
                                                   x_matched_entities => l_matched_entities,
                                                   x_out_rec => l_out_rec,
                                                   x_return_status => l_return_status);



      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status', l_return_status);
      END IF;
    IF (l_return_status = C_ERROR_STATUS) OR
       (l_return_status = C_UNEXP_ERROR_STATUS) THEN
      --dbms_output.put_line('WSH_DELIVERY_AUTOCREATE.autocreate_deliveries returned '||l_return_status);
      FND_MESSAGE.SET_NAME('WSH','WSH_GROUP_DETAILS_ERROR');
      WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
      x_return_status := l_return_status;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
    END IF;
    FOR i in 1..l_attr_tab.COUNT LOOP
        l_group_id_tab(l_attr_tab(i).entity_id) := l_attr_tab(i).group_id;
    END LOOP;
  ELSE
    cnt := p_group_id_tab.FIRST;
    IF ((cnt IS NULL) OR (p_group_id_tab.COUNT <> p_cont_detail_tab.count)) THEN
        x_return_status := C_ERROR_STATUS;
        FND_MESSAGE.SET_NAME('WSH','WSH_GROUP_DETAILS_ERROR');
        WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;
    ELSE
        FOR i in 1..l_group_id_tab.COUNT LOOP
          l_group_id_tab(p_cont_detail_tab(i)) := p_group_id_tab(i);
        END LOOP;
    END IF;
  END IF;

  --dbms_output.put_line('Checking group_ids is over');

  -- 40. Call Validate_Container_For_Pack to validate detail info in p_cont_detail_tab
  -- Bug 3570364 : Passing the parameter p_cont_info_tab which contains the
  --               master container item id's for all LPN's( For Auto_pack Master Action on Lines).
  Validate_Container_For_Pack(
    p_group_id_tab    => l_group_id_tab,
    p_cont_info_tab   => p_cont_detail_tab,
    p_mast_cont_info_tab => p_cont_info_tab,
    x_line_cont_tab   => line_cont_tab,
    x_error_cnt       => error_cnt,
    x_warn_cnt        => warn_cnt,
    x_fill_pc_warn_cnt => l_fill_pc_warn_count -- bug 3562797 jckwok
  );

      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'after validate container for pack-error,warning', error_cnt||','||warn_cnt);
      END IF;
  --
  -- bug 3562797 jckwok
  -- Raise Error if all containers have 'Shipping Parameter' percent fill basis as None
  -- Raise warning if found some of the containers with 'Shipping Parameter'
  -- percent fill basis as None.
  --
  IF (l_fill_pc_warn_count = p_cont_detail_tab.count) THEN
    x_return_status := C_ERROR_STATUS;
    FND_MESSAGE.SET_NAME('WSH','WSH_FILL_BASIS_NONE');
    WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  ELSIF (l_fill_pc_warn_count > 0) THEN
    IF (l_return_status <> C_ERROR_STATUS) THEN
      x_return_status := C_WARNING_STATUS;
      warn_cnt := warn_cnt + 1;
      FND_MESSAGE.SET_NAME('WSH','WSH_FILL_BASIS_NONE');
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
    END IF;
  END IF;
  -- end of bug 3562797 jckwok

  IF (line_cont_tab.COUNT > 0) THEN
    -- 50. Loop through all Containers that need to be Auto-Packed
    cnt := 1;
    succ_cnt := 0;
    l_last_organization_id := NULL;
    WHILE (cnt <= line_cont_tab.COUNT) LOOP

      --dbms_output.put_line('======================================================');
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'auto-packing Container ' || line_cont_tab(cnt).delivery_detail_id||' Organization id '||line_cont_tab(cnt).organization_id);
      END IF;

      IF (l_last_organization_id is NULL) THEN
        l_last_organization_id := line_cont_tab(cnt).organization_id;
      ELSIF (l_last_organization_id <> line_cont_tab(cnt).organization_id) THEN
        l_last_organization_id := line_cont_tab(cnt).organization_id;

        -- Delete the empty PL/SQL cont table if organization_id changes
        g_empty_cont_tab.DELETE;
      END IF;

      Pack_Container(
         p_line_cont_rec => line_cont_tab(cnt),
         x_return_status => l_return_status);

      IF l_return_status = C_ERROR_STATUS THEN
        error_cnt := error_cnt + 1;
      ELSE
        succ_cnt := succ_cnt + 1;
      END IF;
      cnt := cnt + 1;

    END LOOP;

    -- 60.1 Create Containers from g_new_container_tab PL/SQL table
    --dbms_output.put_line('*** Creating Actual Containers ***');
    cnt := 1;
    l_cont_instance_cnt := 1;
    WHILE (cnt <= g_new_container_tab.COUNT) LOOP
      l_cont_name := null;

      --
      -- K LPN CONV. rv
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.CREATE_CONT_INSTANCE_MULTI',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_CONTAINER_ACTIONS.Create_Cont_Instance_Multi(
        x_cont_name           => l_cont_name,
        p_cont_item_id        => g_new_container_tab(cnt).container_item_id,
        x_cont_instance_id    => l_cont_instance_id,
        p_par_detail_id       => NULL,
        p_organization_id     => g_new_container_tab(cnt).organization_id,
        p_container_type_code => NULL,
        p_num_of_containers   => 1,
        x_row_id              => l_row_id,
        x_return_status       => l_return_status,
        x_cont_tab            => l_cont_tab,
        x_unit_weight         => l_lpn_unit_weight,
        x_unit_volume         => l_lpn_unit_volume,
        x_weight_uom_code     => l_lpn_weight_uom_code,
        x_volume_uom_code     => l_lpn_volume_uom_code,
        p_lpn_id              => NULL,
        p_ignore_for_planning => NULL,
        p_caller              => 'WSH_AUTO_PACK_CONTS');
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status',l_return_status);
          WSH_DEBUG_SV.log(l_module_name,'count of l_cont_tab',l_cont_tab.count);
      END IF;
      -- K LPN CONV. rv

      IF l_return_status <> C_SUCCESS_STATUS THEN
        --dbms_output.put_line('Container Creation failed for index '|| cnt);
        FND_MESSAGE.SET_NAME('WSH','WSH_CONT_CREATE_ERROR');
        WSH_UTIL_CORE.Add_Message(C_ERROR_STATUS,l_module_name);
        error_cnt := error_cnt + 1;
      ELSE
        l_cont_instance_id := l_cont_tab(1);
        g_new_container_tab(cnt).cont_instance_id := l_cont_instance_id;
        x_cont_instance_tab(l_cont_instance_cnt) := l_cont_instance_id;
        l_cont_instance_cnt := l_cont_instance_cnt + 1;
        --dbms_output.put_line('Container dd id '||l_cont_instance_id||' for index '|| cnt);
      END IF;
      cnt := cnt + 1;
    END LOOP;


    -- 70.1 Assign Details to Actual Containers created
    --dbms_output.put_line('*** Assigning Containers to Containers Created ***');
    cnt := 1;
    WHILE (cnt <= g_assign_detail_tab.COUNT) LOOP
      l_cont_instance_id := g_new_container_tab(g_assign_detail_tab(cnt).container_index).cont_instance_id;
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'DD '||g_assign_detail_tab(cnt).delivery_detail_id||' Index '||g_assign_detail_tab(cnt).container_index||' Cont '||l_cont_instance_id);
      END IF;

       --
       -- K LPN CONV. rv
       IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y' THEN
       --{
           open  c_get_detail(l_cont_instance_id);
           fetch c_get_detail into l_cnt_ignore_plan_flag, l_cnt_orgn_id, l_cnt_line_dir;
           close c_get_detail;

           l_wms_org := wsh_util_validate.check_wms_org(l_cnt_orgn_id);
       --}
       END IF;
       -- K LPN CONV. rv
       --
       -- J TP Release
       --update the container's ignore value with the first line's ignore
       --since grouping will have already sorted out lines with diff ignore, this shud be okay
       FOR cur IN c_get_detail(g_assign_detail_tab(cnt).delivery_detail_id) LOOP
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'ignore_for_planning',cur.ignore_for_planning);
          END IF;
          --
          -- K LPN CONV. rv
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          AND l_cnt_line_dir IN ('O','IO')
          AND
          (
            (WSH_WMS_LPN_GRP.GK_WMS_UPD_GRP and l_wms_org = 'Y')
            OR
            (WSH_WMS_LPN_GRP.GK_INV_UPD_GRP and l_wms_org = 'N')
          )
          THEN
          --{
              l_sync_tmp_rec.delivery_detail_id := l_cont_instance_id;
              l_sync_tmp_rec.operation_type := 'UPDATE';
              WSH_WMS_SYNC_TMP_PKG.MERGE
              (
                p_sync_tmp_rec      => l_sync_tmp_rec,
                x_return_status     => l_return_status
              );

              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_WMS_SYNC_TMP_PKG.MERGE',l_return_status);
              END IF;
              --
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                --
                IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  warn_cnt := warn_cnt + 1;
                ELSE
                  --
                  error_cnt := error_cnt + 1;
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_WMS_SYNC_TMP_PKG.MERGE completed with an error');
                  END IF;
                  --
                END IF;
                --
              END IF;
          --}
          END IF;
          -- K LPN CONV. rv
          UPDATE wsh_delivery_details
          SET ignore_for_planning=cur.ignore_for_planning
          WHERE delivery_detail_id=l_cont_instance_id;

          IF SQL%NOTFOUND THEN
             FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
             IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
            l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(l_cont_instance_id);
	    FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
            IF l_debug_on THEN
	       WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
            return;
          END IF;
       END LOOP;

      IF (l_cont_instance_id is NOT NULL) THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.ASSIGN_TO_CONTAINER',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_container_actions.Assign_To_Container (
              p_det_cont_inst_id => g_assign_detail_tab(cnt).delivery_detail_id,
              p_par_cont_inst_id => l_cont_instance_id,
              x_return_status    => l_return_status);
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status',l_return_status);
      END IF;

        --dbms_output.put_line('WSH_CONTAINER_ACTIONS.Assign_To_Container returned '||l_return_status);
        IF l_return_status = C_ERROR_STATUS THEN
           error_cnt := error_cnt + 1;
        ELSIF l_return_status = C_WARNING_STATUS THEN
           warn_cnt := warn_cnt + 1;
        ELSE
           NULL;
           --dbms_output.put_line('Assigned dd '||g_assign_detail_tab(cnt).delivery_detail_id||' to Cont '||l_cont_instance_id);
        END IF;
      END IF;

      cnt := cnt + 1;
    END LOOP;

  END IF; -- line_cont_tab.COUNT > 0

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'error cnt is ' || error_cnt || ' warn cnt is ' || warn_cnt|| ' succ cnt is ' || succ_cnt);
        END IF;

  -- 90.1 Summarize errors/warnings
  IF (error_cnt > 0) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_CONT_CONT_PACK_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_COUNT',error_cnt);
    FND_MESSAGE.SET_TOKEN('WARN_COUNT',warn_cnt);
    FND_MESSAGE.SET_TOKEN('SUCC_COUNT',succ_cnt);
    IF succ_cnt > 0 THEN
      x_return_status := C_WARNING_STATUS;
    ELSE
      x_return_status := C_ERROR_STATUS;
    END IF;
    WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
  ELSIF (warn_cnt > 0 OR cont_warn > 0) THEN
    x_return_status := C_WARNING_STATUS;
    IF cont_warn > 0 THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_CONT_PACK_WARN');
      FND_MESSAGE.SET_TOKEN('CONT_WARN',cont_warn);
      FND_MESSAGE.SET_TOKEN('CONT_ERR',0);
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
    END IF;
  ELSE
    x_return_status := C_SUCCESS_STATUS;
  END IF;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN Others THEN
    WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Auto_Pack_conts',l_module_name);
    x_return_status := C_UNEXP_ERROR_STATUS;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Auto_Pack_conts;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Update_Cont_Attributes
   PARAMETERS : p_delivery_detail_id - delivery detail id
		p_delivery_id - delivery id if container assigned to delivery
		p_container_instance_id - delivery detail id for the container
		x_return_status - return status of API
  DESCRIPTION : This procedure updates the grouping attribute columns of the
		container with the grouping attribute values derived from the
		delivery line that is input.
------------------------------------------------------------------------------
*/

PROCEDURE Update_Cont_Attributes (
 p_delivery_detail_id IN NUMBER,
 p_delivery_id IN NUMBER,
 p_container_instance_id IN NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2) IS


 CURSOR Get_Detail_Attr (v_detail_id NUMBER) IS
 SELECT organization_id, customer_id, ship_to_location_id,
	intmed_ship_to_location_id,
	fob_code, freight_terms_code, ship_method_code,
        mode_of_transport, service_level, carrier_id,
	deliver_to_location_id,
        NVL(line_direction,'O') line_direction,   -- J-IB-NPARIKH
        shipping_control,   -- J-IB-NPARIKH
        vendor_id,   -- J-IB-NPARIKH
        party_id,   -- J-IB-NPARIKH
        nvl(ignore_for_planning, 'N')  ignore_for_planning, --J TP Release
        client_id -- LSP PROJECT : ClientID needs to be updated on LPN
 FROM WSH_DELIVERY_DETAILS
 WHERE delivery_detail_id = v_detail_id;

 CURSOR Get_Del_Attr (v_del_id NUMBER) IS
 SELECT organization_id, customer_id, ultimate_dropoff_location_id,
	intmed_ship_to_location_id,
	fob_code, freight_terms_code, ship_method_code,
        mode_of_transport, service_level, carrier_id,
	ultimate_dropoff_location_id deliver_to_location_id,
        NVL(shipment_direction,'O') line_direction,   -- J-IB-NPARIKH
        shipping_control,   -- J-IB-NPARIKH
        vendor_id,   -- J-IB-NPARIKH
        party_id,   -- J-IB-NPARIKH
        nvl(ignore_for_planning,'N') ignore_for_planning, --J TP Release
        client_id -- LSP PROJECT : ClientID needs to be updated on LPN
 FROM WSH_NEW_DELIVERIES
 WHERE delivery_id = v_del_id;

 l_cont_name VARCHAR2(30);

 l_org_id NUMBER;
 l_cust_id NUMBER;
 l_intmed_loc_id NUMBER;
 l_fob_code VARCHAR2(30);
 l_freight_terms_code VARCHAR2(30);
 l_ship_method_code VARCHAR2(30);
 l_carrier_id NUMBER;
 l_service_level VARCHAR2(30);
 l_mode_of_transport VARCHAR2(30);
 l_deliver_to_loc_id NUMBER;
 l_ship_to_loc_id NUMBER;
 l_line_direction VARCHAR2(30);
 l_shipping_control VARCHAR2(30);
 l_vendor_id NUMBER;
 l_party_id  NUMBER;
 l_ignore_for_planning VARCHAR2(1);
 --
 l_client_id           NUMBER; -- LSP PROJECT :

-- K LPN CONV. rv
l_wms_org    VARCHAR2(10) := 'N';
l_sync_tmp_rec wsh_glbl_var_strct_grp.sync_tmp_rec_type;
l_return_status VARCHAR2(1);
l_num_warnings  NUMBER := 0;
l_cnt_line_dir VARCHAR2(10);
-- K LPN CONV. rv

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CONT_ATTRIBUTES';
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
     WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
 END IF;
 --
 IF p_delivery_detail_id IS NOT NULL THEN

	 OPEN Get_Detail_Attr (p_delivery_detail_id);

	 FETCH Get_Detail_Attr INTO
		l_org_id,
		l_cust_id,
		l_ship_to_loc_id,
		l_intmed_loc_id,
		l_fob_code,
		l_freight_terms_code,
		l_ship_method_code,
		l_mode_of_transport,
		l_service_level,
		l_carrier_id,
		l_deliver_to_loc_id,
        l_line_direction,
        l_shipping_control,
        l_vendor_id,
        l_partY_id,
        l_ignore_for_planning,
        l_client_id -- LSP PROJECT
        ;

	 IF Get_Detail_Attr%NOTFOUND THEN
--dbms_output.put_line('invalid detail id ' || p_delivery_detail_id);
		CLOSE Get_Detail_Attr;
		FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
		FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_delivery_detail_id);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
	 END IF;

	 IF Get_Detail_Attr%ISOPEN THEN
		CLOSE Get_Detail_Attr;
	 END IF;

 ELSIF p_delivery_id IS NOT NULL THEN

	 OPEN Get_Del_Attr (p_delivery_id);

	 FETCH Get_Del_Attr INTO
		l_org_id,
		l_cust_id,
		l_ship_to_loc_id,
		l_intmed_loc_id,
		l_fob_code,
		l_freight_terms_code,
		l_ship_method_code,
                l_mode_of_transport,
                l_service_level,
                l_carrier_id,
		l_deliver_to_loc_id,
                l_line_direction,
                l_shipping_control,
                l_vendor_id,
                l_partY_id,
                l_ignore_for_planning,
                l_client_id -- LSP PROJECT
        ;

	 IF Get_Del_Attr%NOTFOUND THEN
		CLOSE Get_Del_Attr;
		FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DELIVERY');
		FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_delivery_id);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return;
	 END IF;

	 IF Get_Del_Attr%ISOPEN THEN
		CLOSE Get_Del_Attr;
	 END IF;

 ELSE
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_NO_ATTR_ERROR');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;

 END IF;


 --dbms_output.put_line('calling update with customer id ' || l_cust_id || ' and ship to ' || l_ship_to_loc_id);

 -- K LPN CONV. rv
 IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y' THEN
   FOR cnt_inst_rec in Get_Detail_Attr(p_container_instance_id) LOOP
     l_wms_org := wsh_util_validate.check_wms_org(cnt_inst_rec.organization_id);
     l_cnt_line_dir := cnt_inst_rec.line_direction;
   END LOOP;
 END IF;
 --
 IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
 AND l_cnt_line_dir IN ('O','IO')
 AND
 (
   (WSH_WMS_LPN_GRP.GK_WMS_UPD_GRP and l_wms_org = 'Y')
   OR
   (WSH_WMS_LPN_GRP.GK_INV_UPD_GRP and l_wms_org = 'N')
 )
 THEN
 --{
     l_sync_tmp_rec.delivery_detail_id := p_container_instance_id;
     l_sync_tmp_rec.operation_type := 'UPDATE';
     WSH_WMS_SYNC_TMP_PKG.MERGE
     (
       p_sync_tmp_rec      => l_sync_tmp_rec,
       x_return_status     => l_return_status
     );

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_WMS_SYNC_TMP_PKG.MERGE',l_return_status);
     END IF;
     --
     IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
       --
       x_return_status := l_return_status;
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Return Status',l_return_status);
         WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       return;
       --
     ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
       --
       l_num_warnings := l_num_warnings + 1;
       --
     END IF;
     --
 --}
 END IF;
 -- K LPN CONV. rv
 UPDATE WSH_DELIVERY_DETAILS SET
	customer_id = l_cust_id,
	ship_to_location_id = l_ship_to_loc_id,
	intmed_ship_to_location_id = l_intmed_loc_id,
	fob_code = l_fob_code,
  	freight_terms_code = l_freight_terms_code,
	ship_method_code = l_ship_method_code,
	mode_of_transport = l_mode_of_transport,
	carrier_id = l_carrier_id,
	service_level = l_service_level,
	deliver_to_location_id = l_deliver_to_loc_id,
        line_direction      = l_line_direction ,   -- J-IB-NPARIKH
        shipping_control    = l_shipping_control,   -- J-IB-NPARIKH
        --vendor_id           = l_vendor_id,   -- J-IB-NPARIKH
        --party_id            = l_party_id   -- J-IB-NPARIKH
        ignore_for_planning   = l_ignore_for_planning,
        client_id             = l_client_id -- LSP PROJECT : update clientId info on LPN Rec.
 WHERE delivery_detail_id = p_container_instance_id;

 IF SQL%NOTFOUND THEN
--dbms_output.put_line('could not update container ' || p_container_instance_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_container_instance_id);
	FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 IF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 END IF;


--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Update_Cont_Attributes',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Update_Cont_Attributes;



/*
-----------------------------------------------------------------------------
   PROCEDURE  : Check_Cont_Attributes
   PARAMETERS : p_container_instance_id - delivery detail id for the container
		x_attr_flag - 'Y' or 'N' to determine if any of the grouping
		attributes other than org id and ship from has been populated.
		x_return_status - return status of API
  DESCRIPTION : This procedure fetched the grouping attribute columns of the
		container and checks to see if the columns are null or if they
		are populated. If any of the values are not null, then the API
		returns a x_attr_flag of 'Y' else it returns a 'N'.
------------------------------------------------------------------------------
*/

PROCEDURE Check_Cont_Attributes (
 p_container_instance_id IN NUMBER,
 x_attr_flag OUT NOCOPY  VARCHAR2,
 x_return_status OUT NOCOPY  VARCHAR2) IS

 CURSOR Get_Detail_Attr (v_detail_id NUMBER) IS
 SELECT customer_id, intmed_ship_to_location_id,
	fob_code, freight_terms_code, ship_method_code,
        mode_of_transport, service_level, carrier_id,
	deliver_to_location_id
 FROM WSH_DELIVERY_DETAILS
 WHERE delivery_detail_id = v_detail_id;

 l_cont_name VARCHAR2(30);

 l_org_id NUMBER;
 l_cust_id NUMBER;
 l_intmed_loc_id NUMBER;
 l_fob_code VARCHAR2(30);
 l_freight_terms_code VARCHAR2(30);
 l_ship_method_code VARCHAR2(30);
 l_carrier_id NUMBER;
 l_mode_of_transport VARCHAR2(30);
 l_service_level VARCHAR2(30);
 l_deliver_to_loc_id NUMBER;

 l_attr_flag VARCHAR2(1) := 'N';

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_CONT_ATTRIBUTES';
--
BEGIN

--dbms_output.put_line('in check cont attr with ' || p_container_instance_id);

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
 OPEN Get_Detail_Attr (p_container_instance_id);

 FETCH Get_Detail_Attr INTO
	l_cust_id,
	l_intmed_loc_id,
	l_fob_code,
	l_freight_terms_code,
	l_ship_method_code,
        l_mode_of_transport,
        l_service_level,
        l_carrier_id,
	l_deliver_to_loc_id;

 IF Get_Detail_Attr%NOTFOUND THEN
	CLOSE Get_Detail_Attr;
--dbms_output.put_line('no detail found for ' || p_container_instance_id);
	FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
 	x_attr_flag := 'N';
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
 END IF;

 IF Get_Detail_Attr%ISOPEN THEN
	CLOSE Get_Detail_Attr;
 END IF;

 IF l_cust_id IS NOT NULL THEN
	l_attr_flag := 'Y';
 END IF;

 IF l_intmed_loc_id IS NOT NULL THEN
	l_attr_flag := 'Y';
 END IF;

 IF l_fob_code IS NOT NULL THEN
	l_attr_flag := 'Y';
 END IF;

 IF l_freight_terms_code IS NOT NULL THEN
	l_attr_flag := 'Y';
 END IF;

 IF l_service_level IS NOT NULL THEN
	l_attr_flag := 'Y';
 END IF;
 IF l_mode_of_transport IS NOT NULL THEN
	l_attr_flag := 'Y';
 END IF;
 IF l_carrier_id IS NOT NULL THEN
	l_attr_flag := 'Y';
 END IF;
 IF l_ship_method_code IS NOT NULL THEN
	l_attr_flag := 'Y';
 END IF;

 IF l_deliver_to_loc_id IS NOT NULL THEN
	l_attr_flag := 'Y';
 END IF;

 x_attr_flag := l_attr_flag;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Check_Cont_Attributes',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Cont_Attributes;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Update_Cont_Hierarchy
   PARAMETERS : p_delivery_detail_id - delivery detail id
		p_delivery_id - delivery id if container assigned to delivery
		p_container_instance_id - delivery detail id for the container
		x_return_status - return status of API
  DESCRIPTION : This procedure updates the grouping attribute columns of the
		the entire container hierarchy for the specified container
		with the grouping attribute values derived from the
		delivery line that is input.
------------------------------------------------------------------------------
*/

PROCEDURE Update_Cont_Hierarchy (
 p_del_detail_id IN NUMBER,
 p_delivery_id IN NUMBER,
 p_container_instance_id IN NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2) IS


 CURSOR Get_Child_Containers(v_cont_instance_id NUMBER) IS
 SELECT delivery_detail_id
 FROM wsh_delivery_assignments_v
 START WITH delivery_detail_id = v_cont_instance_id
 CONNECT BY PRIOR delivery_detail_id = parent_delivery_detail_id;

 CURSOR Get_Cont_Flag (v_detail_id NUMBER) IS
 SELECT container_flag
 FROM WSH_DELIVERY_DETAILS
 WHERE delivery_detail_id = v_detail_id;

 l_master_cont_inst_id NUMBER;
 l_master_cont_name VARCHAR2(30);

 l_cont_name VARCHAR2(30);
 l_cont_flag VARCHAR2(1);

 l_return_status VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CONT_HIERARCHY';
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
     WSH_DEBUG_SV.log(l_module_name,'P_DEL_DETAIL_ID',P_DEL_DETAIL_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
 END IF;
 --
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_MASTER_CONT_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
 END IF;
 --
 l_master_cont_inst_id := WSH_CONTAINER_UTILITIES.Get_Master_Cont_Id(p_container_instance_id);

 IF l_master_cont_inst_id IS NULL THEN
	l_master_cont_inst_id := p_container_instance_id;
 END IF;

 --dbms_output.put_line('calling get child containers with ' || l_master_cont_inst_id);

 FOR cont IN Get_Child_Containers(l_master_cont_inst_id) LOOP

	EXIT WHEN Get_Child_Containers%NOTFOUND;

 --dbms_output.put_line('in loop with ' || cont.delivery_detail_id);

	OPEN Get_Cont_Flag (cont.delivery_detail_id);

	FETCH Get_Cont_Flag INTO l_cont_flag;

 	IF Get_Cont_Flag%NOTFOUND THEN
--dbms_output.put_line('cont flag not found for ' || cont.delivery_detail_id);
		CLOSE Get_Cont_Flag;
		GOTO next_cont;
	END IF;

	IF Get_Cont_Flag%ISOPEN THEN
		CLOSE Get_Cont_Flag;
	END IF;

--dbms_output.put_line('called get child containers with ' || cont.delivery_detail_id || ' and cont flag is ' || l_cont_flag);

	IF (nvl(l_cont_flag,'N') = 'Y') THEN

	--dbms_output.put_line('calling update cont attr with ' || cont.delivery_detail_id);

		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.UPDATE_CONT_ATTRIBUTES',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		wsh_container_actions.Update_Cont_Attributes (
						p_del_detail_id,
						p_delivery_id,
						cont.delivery_detail_id,
						l_return_status);
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'return status-',l_return_status);
                END IF;

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			FND_MESSAGE.SET_NAME('WSH','WSH_CONT_UPD_ATTR_ERROR');
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_CONT_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			--
			l_cont_name := WSH_CONTAINER_UTILITIES.Get_Cont_Name(cont.delivery_detail_id);
			FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
			x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
		END IF;

	END IF;

	<<next_cont>>
	     null;

	l_cont_flag := NULL;

  END LOOP;

  IF nvl(x_return_status,WSH_UTIL_CORE.G_RET_STS_SUCCESS) <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  ELSE
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  END IF;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Update_Cont_Hierarchy',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Update_Cont_Hierarchy;


/*
-----------------------------------------------------------------------------
   PROCEDURE  : Last_Assigned_Line
   PARAMETERS : p_delivery_detail_id - delivery detail id
		p_container_instance_id - delivery detail id for the container
		x_last_line_flag - 'Y' or 'N' depending on whether it is the
		last line in the container hierarchy or not.
		x_return_status - return status of API
  DESCRIPTION : This procedure checks to see if the delivery detail id is the
		last assigned line in the container hierarchy for the input
		container. If it is, x_last_line_flag is set to 'Y' else it is
		set to 'N'.
------------------------------------------------------------------------------
*/

PROCEDURE Last_Assigned_Line (
 p_del_detail_id IN NUMBER,
 p_container_instance_id IN NUMBER,
 x_last_line_flag OUT NOCOPY  VARCHAR2,
 x_return_status OUT NOCOPY  VARCHAR2) IS

 CURSOR Get_Contents (v_detail_id NUMBER) IS
 SELECT count(*)
 FROM wsh_delivery_assignments_v
 START WITH delivery_detail_id = v_detail_id
 CONNECT BY PRIOR delivery_detail_id = parent_delivery_detail_id;

 CURSOR Get_Cont_Count (v_cont_id NUMBER) IS
 SELECT count(*)
 FROM wsh_delivery_assignments_v
 WHERE delivery_detail_id IN
	(SELECT delivery_detail_id
	 FROM WSH_DELIVERY_DETAILS
  	 WHERE container_flag = 'Y')
 START WITH delivery_detail_id = v_cont_id
 CONNECT BY PRIOR delivery_detail_id = parent_delivery_detail_id;

 l_content_cnt NUMBER;
 l_cont_cnt NUMBER;

 l_mast_cont_inst_id NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LAST_ASSIGNED_LINE';
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
     WSH_DEBUG_SV.log(l_module_name,'P_DEL_DETAIL_ID',P_DEL_DETAIL_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
 END IF;
 --
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_UTILITIES.GET_MASTER_CONT_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
 END IF;
 --
 l_mast_cont_inst_id := WSH_CONTAINER_UTILITIES.Get_Master_Cont_Id (p_container_instance_id);

 IF l_mast_cont_inst_id IS NULL THEN
	l_mast_cont_inst_id := p_container_instance_id;
 END IF;

 OPEN Get_Contents (l_mast_cont_inst_id);

 FETCH Get_Contents INTO l_content_cnt;

 IF Get_Contents%NOTFOUND THEN
	CLOSE Get_Contents;
	x_last_line_flag := 'N';
	FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
 END IF;

 IF Get_Contents%ISOPEN THEN
	CLOSE Get_Contents;
 END IF;

 OPEN Get_Cont_Count (l_mast_cont_inst_id);

 FETCH Get_Cont_Count INTO l_cont_cnt;

 IF Get_Cont_Count%NOTFOUND THEN
	CLOSE Get_Cont_Count;
	x_last_line_flag := 'N';
	FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
 END IF;

 IF Get_Cont_Count%ISOPEN THEN
	CLOSE Get_Cont_Count;
 END IF;

 IF (l_content_cnt - l_cont_cnt) > 0 THEN
	x_last_line_flag := 'N';
 ELSE
	x_last_line_flag := 'Y';
 END IF;

 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Last_Assigned_Line',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Last_Assigned_Line;



-- J-IB-NPARIKH-{
--
--========================================================================
-- PROCEDURE : pack_inbound_lines
--
-- PARAMETERS: p_lines_tbl       Table of delivery lines to be packed
--             p_lpn_id          LPN ID
--             p_lpn_name        Container name as entered on ASN
--             p_delivery_id     Delivery ID for delivery, input lines belong to
--             p_transactionType ASN/RECEIPT
--             x_return_status   Return status of the API
--
-- ASSUMPTION: All input lines belong to only one delivery, specified by p_delivery_id
--
-- COMMENT   : This procedure is called only from the Inbound ASN/Receipt
--             integration to pack delivery lines as per the ASN LPN
--             Configuration.
--             It performs the following steps:
--             01. Validate that input delivery id is not null and is a valid delivery.
--             02. Validate that input table of lines contain at least one record.
--             03. If input delivery is outbound, return with error.
--             04. Append LPN name with delivery name.
--             05. Create container instance
--             06. Update container delivery detail record with grouping attributes from delivery.
--             07. Assign container to delivery
--             08. Assign input lines to container
--             09. Calculate container dates
--             10. Calculate container weight/volume
--
--========================================================================
--
PROCEDURE pack_inbound_lines
            (
               p_lines_tbl          IN          WSH_UTIL_CORE.id_tab_type,
               p_lpn_id             IN          NUMBER,
               p_lpn_name           IN        VARCHAR2,
               p_delivery_id        IN          NUMBER,
               p_transactionType    IN          VARCHAR2 DEFAULT 'ASN',
               x_return_status      OUT NOCOPY  VARCHAR2,
	       p_waybill_number     IN          VARCHAR2,
               p_caller             IN          VARCHAR2
            )
IS
--{
    --
    -- Get delivery information
    --
    CURSOR dlvy_csr (p_delivery_id IN NUMBER)
    IS
        SELECT organization_id,
               nvl(shipment_direction,'O') shipment_direction,
               initial_pickup_location_id,
               ultimate_dropoff_location_id,
               customer_id,
               intmed_ship_to_location_id,
               fob_code,
               freight_terms_code,
               ship_method_code,
               shipping_control,
               vendor_id,
               party_id,
               name,
               nvl(ignore_for_planning,'N') ignore_for_planning
        FROM   wsh_new_deliveries wnd
        WHERE  delivery_id             = p_delivery_id;
    --
    --
    l_dlvy_rec dlvy_csr%ROWTYPE;
    --
    l_num_warnings                NUMBER := 0;
    l_num_errors                  NUMBER := 0;
    l_return_status               VARCHAR2(10);
    --
    l_cont_name                   VARCHAR2(100);
    l_container_instance_id       NUMBER;
    l_rowid                       VARCHAR2(32767);
    l_cont_tbl                    WSH_UTIL_CORE.id_tab_type;
				--
    l_gross_weight                NUMBER;
    l_net_weight                  NUMBER;
    l_volume                      NUMBER;
    l_cont_fill_pc                NUMBER;

    l_detail_tab                  WSH_UTIL_CORE.id_tab_type;  -- DBI Project
    l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API

    cursor l_dup_del_csr(p_lpn_name IN VARCHAR2)
    is
    select wnd.delivery_id,
           wnd.name,
           wnd.status_code,
           wda.delivery_detail_id
    from   wsh_delivery_details wdd,
           wsh_delivery_assignments_v wda,
           wsh_new_deliveries wnd
    where  wdd.container_name = p_lpn_name
    and    wdd.container_flag = 'Y'
    and    wda.delivery_detail_id = wdd.delivery_detail_id
    and    wda.delivery_id = wnd.delivery_id(+);

    l_dup_del_id     NUMBER;
    l_dup_del_name   VARCHAR2(32767);
    l_dup_del_status VARCHAR2(2);
    l_dup_cnt_id     NUMBER;
    --

-- K LPN CONV. rv
l_cont_tab wsh_util_core.id_tab_type;
l_lpn_unit_weight NUMBER;
l_lpn_unit_volume NUMBER;
l_lpn_weight_uom_code VARCHAR2(100);
l_lpn_volume_uom_code VARCHAR2(100);
-- K LPN CONV. rv
    l_debug_on                    BOOLEAN;
    --
    l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'pack_inbound_lines';
    --
--}
BEGIN
--{
    SAVEPOINT pack_inbound_lines_sp;
    --
    l_debug_on := wsh_debug_interface.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      --
      wsh_debug_sv.LOG(l_module_name, 'p_lpn_id', p_lpn_id);
      wsh_debug_sv.LOG(l_module_name, 'p_delivery_id', p_delivery_id);
      wsh_debug_sv.LOG(l_module_name, 'p_transactionTYpe', p_transactionTYpe);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    --
    IF p_delivery_id IS NULL
    THEN
    --{
        --
        -- p_delivery_id is mandatory
        --
        FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'p_delivery_id');
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    IF p_lines_tbl.count = 0
    THEN
    --{
        --
        -- p_lines_tbl should have at least one record
        --
        FND_MESSAGE.SET_NAME('WSH', 'WSH_EMPTY_TABLE_ERROR');
        FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'p_lines_tbl');
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    OPEN dlvy_csr(p_delivery_id);
    FETCH dlvy_csr INTO l_dlvy_rec;
    CLOSE dlvy_csr;
    --
    IF l_dlvy_rec.initial_pickup_location_id IS NULL
    THEN
    --{
        FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_NOT_EXIST');
        FND_MESSAGE.SET_TOKEN('DELIVERY_ID', p_delivery_id);
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    IF l_dlvy_rec.shipment_direction IN ('O','IO')
    THEN
    --{
        --
        -- Invalid operation for outbound delivery
        --
        FND_MESSAGE.SET_NAME('WSH','WSH_NOT_IB_DLVY_ERROR');
        FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', l_dlvy_rec.name);
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    --l_cont_name := SUBSTRB(p_lpn_id || '.' || l_dlvy_rec.name,1,30);
    l_cont_name := p_lpn_name;
    --
    -- commented out the following code because this is not applicable anymore
    -- as container name is not unique in WSH.  This check is not required.
    /*
    open  l_dup_del_csr(p_lpn_name);
    fetch l_dup_del_csr into l_dup_del_id,l_dup_del_name, l_dup_del_status, l_dup_cnt_id;
    close l_dup_del_csr;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_dup_del_id', l_dup_del_id);
        WSH_DEBUG_SV.log(l_module_name,'l_dup_del_name', l_dup_del_name);
        WSH_DEBUG_SV.log(l_module_name,'l_dup_del_status', l_dup_del_status);
        WSH_DEBUG_SV.log(l_module_name,'l_dup_cnt_id', l_dup_cnt_id);
    END IF;

    IF(l_dup_del_id is not null AND nvl(l_dup_del_status,'OP') = 'CL') THEN
    --{
        update wsh_delivery_details
        set    container_name = SUBSTRB(p_lpn_name || '.' ||l_dup_del_name,1,50)
        where  delivery_detail_id = l_dup_cnt_id;
    --}
    ELSIF(l_dup_cnt_id IS NOT NULL) THEN
    --{
        l_cont_name := SUBSTRB(p_lpn_name || '.' || l_dlvy_rec.name,1,50);
    --}
    END IF;
    */
    --l_cont_name := SUBSTRB(p_lpn_name || '.' || l_dlvy_rec.name,1,50);
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Create_Cont_Instance_Multi',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    G_CALLED_FROM_INBOUND := TRUE;
    --
      --
      -- K LPN CONV. rv
      --
      WSH_CONTAINER_ACTIONS.Create_Cont_Instance_Multi(
        x_cont_name           => l_cont_name,
        p_cont_item_id        => NULL,
        x_cont_instance_id    => l_container_instance_id,
        p_par_detail_id       => NULL,
        p_organization_id     => l_dlvy_rec.organization_id,
        p_container_type_code => NULL,
        p_num_of_containers   => 1,
        x_row_id              => l_rowid,
        x_return_status       => l_return_status,
        x_cont_tab            => l_cont_tab,
        x_unit_weight         => l_lpn_unit_weight,
        x_unit_volume         => l_lpn_unit_volume,
        x_weight_uom_code     => l_lpn_weight_uom_code,
        x_volume_uom_code     => l_lpn_volume_uom_code,
        p_lpn_id              => p_lpn_id,
        p_ignore_for_planning => l_dlvy_rec.ignore_for_planning,
        p_caller              => 'WSH_IB_PACK');
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'return status',l_return_status);
          WSH_DEBUG_SV.log(l_module_name,'count of l_cont_tab',l_cont_tab.count);
      END IF;
      l_container_instance_id := l_cont_tab(1);
      -- K LPN CONV. rv
    --
    --
    G_CALLED_FROM_INBOUND := FALSE;
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
    --
    --
    -- Update Container record with delivery grouping attributes
    --
    UPDATE WSH_DELIVERY_DETAILS
    SET    lpn_id                       = p_lpn_id,
           shipped_quantity             = DECODE(p_transactionType,'ASN',1,shipped_quantity),
           received_quantity            = DECODE(p_transactionType,'RECEIPT',1,received_quantity),
           released_status              = DECODE(p_transactionType,'ASN','C','RECEIPT','L','C'),
           src_requested_quantity       = requested_quantity,
           src_requested_quantity_uom   = 'Ea'  ,
           requested_quantity_uom       = 'Ea'  ,
           line_direction               = l_dlvy_rec.shipment_direction,
           ship_from_location_id        = l_dlvy_rec.initial_pickup_location_id,
           ship_to_location_id          = l_dlvy_rec.ultimate_dropoff_location_id,
           customer_id                  = l_dlvy_rec.customer_id,
           intmed_ship_to_location_id   = l_dlvy_rec.intmed_ship_to_location_id,
           fob_code                     = l_dlvy_rec.fob_code,
           freight_terms_code           = l_dlvy_rec.freight_terms_code,
           ship_method_code             = l_dlvy_rec.ship_method_code,
           shipping_control             = l_dlvy_rec.shipping_control,
           vendor_id                    = l_dlvy_rec.vendor_id,
           party_id                     = l_dlvy_rec.party_id,
           ignore_for_planning          = l_dlvy_rec.ignore_for_planning,
           tracking_number              = NVL(p_waybill_number,tracking_number),
           last_update_date             = SYSDATE,
           last_updated_by              = FND_GLOBAL.USER_ID,
           last_update_login            = FND_GLOBAL.LOGIN_ID
   WHERE   rowid                        = l_rowid;
   --
   -- l_container_instance_id is the delivery_detail_id, use for DBI call
   -- DBI Project
   -- Update of wsh_delivery_details where requested_quantity/released_status
   -- are changed, call DBI API after the update.
   -- This API will also check for DBI Installed or not
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',l_container_instance_id);
   END IF;
   l_detail_tab(1) := l_container_instance_id;
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
       WSH_DEBUG_SV.pop(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     return;
   END IF;
   -- treat all other return status as Success
   -- End of Code for DBI Project
   --
   -- Assign container to delivery
   --
   UPDATE wsh_delivery_assignments_v
   SET      delivery_id        = p_delivery_id,
            last_update_date   = SYSDATE,
            last_updated_by    = FND_GLOBAL.USER_ID,
            last_update_login  = FND_GLOBAL.LOGIN_ID
   WHERE    delivery_detail_id = l_container_instance_id;
   --
   --
   -- Assign lines to container
   --
   FORALL i IN p_lines_tbl.FIRST..p_lines_tbl.LAST
   UPDATE wsh_delivery_assignments_v
   SET      parent_delivery_detail_id   = l_container_instance_id,
            last_update_date   = SYSDATE,
            last_updated_by    = FND_GLOBAL.USER_ID,
            last_update_login  = FND_GLOBAL.LOGIN_ID
   WHERE    delivery_detail_id = p_lines_tbl(i);
   --
   --
   l_cont_tbl(1) := l_container_instance_id;
   --
   --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_tp_release.calculate_cont_del_tpdates',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
   --
   -- Calculate container dates
   --
   wsh_tp_release.calculate_cont_del_tpdates
    (
        p_entity        => 'LPN',
        p_entity_ids    => l_cont_tbl,
        x_return_status => l_return_status
    );
   --
   wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
    --
        IF nvl(p_caller, '!!!!') <> 'WSH_VENDOR_MERGE' THEN
        --{

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_CONTAINER_PKG.CONTAINER_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            --
            -- Calculate container weight and volume
            --
            WSH_TPA_CONTAINER_PKG.Container_Weight_Volume(
                 p_container_instance_id => l_container_instance_id,
                 p_override_flag         => 'Y',
                 p_calc_wv_if_frozen     => 'N',
                 x_gross_weight          => l_gross_weight,
                 x_net_weight            => l_net_weight,
                 x_volume                => l_volume ,
                 p_fill_pc_flag          => 'Y',
                 x_cont_fill_pc          => l_cont_fill_pc,
                 x_return_status         => l_return_status);
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'return status',l_return_status);
            END IF;
        --}
        END IF;

			--
			--
   IF l_num_errors > 0
   THEN
        x_return_status         := WSH_UTIL_CORE.G_RET_STS_ERROR;
   ELSIF l_num_warnings > 0
   THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;
   --
   IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name);
   END IF;
    --
--}
EXCEPTION
--{
      --
    WHEN FND_API.G_EXC_ERROR THEN

      G_CALLED_FROM_INBOUND := FALSE;
      ROLLBACK TO  pack_inbound_lines_sp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      G_CALLED_FROM_INBOUND := FALSE;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO  pack_inbound_lines_sp;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN

      G_CALLED_FROM_INBOUND := FALSE;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN

        G_CALLED_FROM_INBOUND := FALSE;
        ROLLBACK TO  pack_inbound_lines_sp;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        wsh_util_core.default_handler('wsh_container_actions.pack_inbound_lines', l_module_name);
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
--}
END pack_inbound_lines;
--
--
--
--========================================================================
-- PROCEDURE : unpack_inbound_delivery
--
-- PARAMETERS: p_delivery_id     Delivery ID for delivery, input lines belong to
--             x_return_status   Return status of the API
--
--
-- COMMENT   : This procedure is called only from the cancel ASN/Revert ASN events
--             It performs the following steps:
--             01. Validate that input delivery id is not null and is a valid delivery.
--             02. If input delivery is outbound, return with error.
--             03. Delete all containers within the delivery (WDD and WDA)
--             04. Unassign all lines (within delivery) from container.
--
--========================================================================
--
--
PROCEDURE unpack_inbound_delivery
            (
               p_delivery_id        IN          NUMBER,
               x_return_status      OUT NOCOPY  VARCHAR2
            )
IS
--{
    CURSOR dlvy_csr (p_delivery_id IN NUMBER)
    IS
        SELECT nvl(shipment_direction,'O') shipment_direction,
               initial_pickup_location_id,
               name
        FROM   wsh_new_deliveries wnd
        WHERE  delivery_id             = p_delivery_id;
    --
    l_dlvy_rec dlvy_csr%ROWTYPE;
    --
    --
    l_num_warnings                NUMBER := 0;
    l_num_errors                  NUMBER := 0;
    l_return_status               VARCHAR2(10);
    --
    l_lines_tbl                   WSH_UTIL_CORE.id_tab_type;
    --
    l_debug_on                    BOOLEAN;
    --
    l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'unpack_inbound_delivery';
    --
--}
BEGIN
--{
    SAVEPOINT unpack_inbound_delivery_sp;
    --
    l_debug_on := wsh_debug_interface.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      --
      wsh_debug_sv.LOG(l_module_name, 'p_delivery_id', p_delivery_id);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    --
    IF p_delivery_id IS NULL
    THEN
    --{
        --
        -- p_delivery_id is mandatory
        --
        FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'p_delivery_id');
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    OPEN dlvy_csr(p_delivery_id);
    FETCH dlvy_csr INTO l_dlvy_rec;
    CLOSE dlvy_csr;
    --
    IF l_dlvy_rec.initial_pickup_location_id IS NULL
    THEN
    --{
        FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_NOT_EXIST');
        FND_MESSAGE.SET_TOKEN('DELIVERY_ID', p_delivery_id);
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    IF l_dlvy_rec.shipment_direction IN ('O','IO')
    THEN
    --{
        --
        -- Invalid operation for outbound delivery
        --
        FND_MESSAGE.SET_NAME('WSH','WSH_NOT_IB_DLVY_ERROR');
        FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', l_dlvy_rec.name);
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    -- Delete all containers within the delivery
    --
    DELETE WSH_DELIVERY_DETAILS
    WHERE  DELIVERY_DETAIL_ID IN (
                                    SELECT wdd.delivery_detail_id
                                    FROM   wsh_delivery_details wdd,
                                           wsh_delivery_assignments_v wda
                                    WHERE  wda.delivery_id = p_delivery_id
                                    AND    wda.delivery_detail_id = wdd.delivery_detail_id
                                    AND    NVL(wdd.container_flag,'N') = 'Y'
                                 )
    RETURNING delivery_detail_id BULK COLLECT INTO l_lines_tbl;
    --
    --
    IF l_lines_tbl.COUNT > 0
    THEN
    --{
        FORALL i IN l_lines_tbl.FIRST..l_lines_tbl.LAST
        DELETE wsh_delivery_assignments_v
        WHERE  delivery_detail_id = l_lines_tbl(i);
    --}
    END IF;
    --
    --
    --
    -- Unassign all lines from containers.
    --
   UPDATE wsh_delivery_assignments_v
   SET      parent_delivery_detail_id = NULL,
            last_update_date   = SYSDATE,
            last_updated_by    = FND_GLOBAL.USER_ID,
            last_update_login  = FND_GLOBAL.LOGIN_ID
   WHERE    delivery_id        = p_delivery_id;
   --
   --
   IF l_num_errors > 0
   THEN
        x_return_status         := WSH_UTIL_CORE.G_RET_STS_ERROR;
   ELSIF l_num_warnings > 0
   THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;
   --
   IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name);
   END IF;
    --
--}
EXCEPTION
--{
      --
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO  unpack_inbound_delivery_sp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO  unpack_inbound_delivery_sp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN

        ROLLBACK TO  unpack_inbound_delivery_sp;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        wsh_util_core.default_handler('wsh_container_actions.unpack_inbound_delivery', l_module_name);
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
--}
END unpack_inbound_delivery;
--
--
-- J-IB-NPARIKH-}
/* This procedure is a temporarily procedure that will create
   container names and will be deleted once WMS provides the functionality.
   lpn conv
*/

PROCEDURE Create_Multiple_Cont_name (
  p_cont_name IN VARCHAR2,
  p_cont_name_pre IN VARCHAR2,
  p_cont_name_suf IN VARCHAR2,
  p_cont_name_num IN NUMBER,
  p_cont_name_dig IN NUMBER,
  p_quantity IN NUMBER,
  x_cont_names OUT NOCOPY  WSH_GLBL_VAR_STRCT_GRP.v50_Tbl_Type,
  x_return_status OUT NOCOPY  VARCHAR2) IS

  CURSOR Get_Exist_Cont(v_cont_name VARCHAR2) IS
  SELECT NVL(MAX(1),0) FROM DUAL
  WHERE EXISTS ( SELECT 1 FROM WSH_DELIVERY_DETAILS
                 WHERE container_name = v_cont_name
                 AND container_flag = 'Y');

  l_cont_name VARCHAR2(30);
  l_cont_name_num NUMBER;
  l_cont_inst_id NUMBER;
  l_row_id VARCHAR2(30);
  l_cont_cnt NUMBER;
  l_all_null_flag VARCHAR2(1) := 'Y';
  l_return_status VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_MULTIPLE_CONT_NAME';
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
      WSH_DEBUG_SV.log(l_module_name,'P_CONT_NAME',P_CONT_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_CONT_NAME_PRE',P_CONT_NAME_PRE);
      WSH_DEBUG_SV.log(l_module_name,'P_CONT_NAME_SUF',P_CONT_NAME_SUF);
      WSH_DEBUG_SV.log(l_module_name,'P_CONT_NAME_NUM',P_CONT_NAME_NUM);
      WSH_DEBUG_SV.log(l_module_name,'P_CONT_NAME_DIG',P_CONT_NAME_DIG);
      WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY',P_QUANTITY);
  END IF;
  --
  IF ( NVL(p_quantity,0) <=  0 )  THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_CREATE_ERROR');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;

  IF p_cont_name_pre IS NULL AND p_cont_name_num IS NULL AND p_cont_name_dig IS NULL AND p_cont_name_suf IS NULL THEN
	l_all_null_flag := 'Y';
  ELSE
	l_all_null_flag := 'N';
  END IF;

  l_cont_name_num := NVL(p_cont_name_num,0);
  FOR i IN 1..p_quantity LOOP
     IF p_quantity = 1 AND p_cont_name IS NOT NULL THEN
        l_cont_name := p_cont_name;
     ELSIF l_all_null_flag = 'Y' THEN
        l_cont_name := NULL;
     ELSE
        -- if p..dig is null don't do padding
	   IF (p_cont_name_dig IS NOT NULL) THEN
  	      l_cont_name := p_cont_name_pre || LPAD(to_char(l_cont_name_num),p_cont_name_dig,'0') || p_cont_name_suf;
	   ELSE
  	      l_cont_name := p_cont_name_pre || to_char(l_cont_name_num)|| p_cont_name_suf;
        END IF;
     END IF;
	l_cont_name_num := l_cont_name_num + 1;

	OPEN Get_Exist_Cont(l_cont_name);
     FETCH Get_Exist_Cont INTO l_cont_cnt;
     CLOSE Get_Exist_Cont;

	IF l_cont_cnt = 0 THEN
		--
                x_cont_names(x_cont_names.count+1) := l_cont_name;
	ELSE
		l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  		FND_MESSAGE.SET_NAME('WSH','WSH_CONT_NAME_DUPLICATE');
		FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
		WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
	END IF;
  END LOOP;

  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	x_return_status := l_return_status;
	FND_MESSAGE.SET_NAME('WSH','WSH_CONT_CREATE_ERROR');
	WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN Others THEN
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Create_Multiple_Cont_names',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;


         IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
        --
END Create_Multiple_Cont_name;


/* ----------------------------------------------------------------------

PROCEDURE Update_child_inv_info
   This procedure updates all the containers included in p_container_id
   with p_locator_id and p_subinventory (downward in hirearchy)

Prameters
   p_container_id
   p_locator_id
   p_subinventory
   x_return_status

------------------------------------------------------------------------*/

--lpn conv
PROCEDURE Update_child_inv_info(p_container_id  IN NUMBER,
                        P_locator_id IN NUMBER,
                        P_subinventory IN VARCHAR2,
                        X_return_status OUT NOCOPY VARCHAR2)
IS


   --
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CHILD_INV_INFO';
   --
   l_container_id      NUMBER;

   child_cont_locked     EXCEPTION;
   PRAGMA EXCEPTION_INIT(child_cont_locked, -00054);

   CURSOR lock_containers(v_container_id NUMBER) IS
   SELECT delivery_detail_id
   FROM wsh_delivery_details
   --WHERE container_flag = 'Y'
   WHERE delivery_detail_id IN
   (SELECT delivery_detail_id
    FROM wsh_delivery_assignments
    START WITH parent_delivery_detail_id = v_container_id
   CONNECT BY PRIOR delivery_detail_id = parent_delivery_detail_id
   )
   FOR UPDATE NOWAIT;

BEGIN

  --
  --
  SAVEPOINT s_Update_child_inv_info;
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
      WSH_DEBUG_SV.log(l_module_name,'p_container_id',p_container_id);
      WSH_DEBUG_SV.log(l_module_name,'P_locator_id',P_locator_id);
      WSH_DEBUG_SV.log(l_module_name,'P_subinventory',P_subinventory);
  END IF;
  --


  OPEN lock_containers(p_container_id);
  LOOP --{
     FETCH lock_containers INTO l_container_id;
     EXIT WHEN lock_containers%NOTFOUND;

     UPDATE wsh_delivery_details
     SET locator_id = p_locator_id,
         subinventory = p_subinventory
     WHERE delivery_detail_id = l_container_id;

  END LOOP ; --}

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION

  WHEN  child_cont_locked THEN
      rollback to s_Update_child_inv_info;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Could not lock record for the containers ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:child_cont_locked');
      END IF;
      --
  WHEN Others THEN
      rollback to s_Update_child_inv_info;
	WSH_UTIL_CORE.Default_Handler('WSH_CONTAINER_ACTIONS.Update_child_inv_info',l_module_name);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;


         IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
        --
END Update_child_inv_info;

-----------------------------------------------------------------------------------------------------------------------
--
-- Name:
-- Assign_Container_to_Consol
--
-- Purpose:
-- This API will assign a content LPN to a consol LPN.
-- If the parent LPN is not a consol LPN, we will convert it
-- to a consol LPN and create the corresponding consol deliveries
-- and trips.
--
-- Parameters:
-- p_child_container_id: LPN that needs to be assigned.
-- p_parent_container_id: LPN that will be assigned to
-- p_caller: Calling entity/action
-- x_return_status: status

PROCEDURE Assign_Container_to_Consol(
             p_child_container_id   IN NUMBER,
             p_parent_container_id  IN NUMBER,
             p_caller               IN VARCHAR2,
             x_return_status        OUT NOCOPY VARCHAR2) IS

cursor c_get_container_info(p_delivery_detail_id in number) is
select d.container_flag, a.delivery_id, a.parent_delivery_id, d.inventory_item_id, d.organization_id
from wsh_delivery_details d, wsh_delivery_assignments a
where d.delivery_detail_id = p_delivery_detail_id
and d.container_flag in ('Y', 'C')
and a.type in ('C', 'S')
and a.delivery_detail_id = d.delivery_detail_id
and a.parent_delivery_detail_id is null
and a.delivery_id is not null;



l_parent_container_info c_get_container_info%rowtype;
l_child_container_info c_get_container_info%rowtype;
l_new_parent_delivery_id NUMBER := NULL;
l_del_tab wsh_util_core.id_tab_type;


-- This cursor accepts a given delivery, p_del_id,
-- and looks for consol deliveries that share the
-- same trip as this delivery from the initial pickup location.

cursor c_get_trip_info(p_del_id in number) is
select s.trip_id, d2.delivery_id
from  wsh_delivery_legs l1, wsh_delivery_legs l2,
      wsh_new_deliveries d1, wsh_new_deliveries d2,
      wsh_trip_stops s
where l1.delivery_id = p_del_id
and l1.delivery_id = d1.delivery_id   -- bug 4891897
and s.stop_id = l1.pick_up_stop_id
and s.stop_location_id = d1.initial_pickup_location_id
and l1.pick_up_stop_id = l2.pick_up_stop_id
and l2.delivery_id = d2.delivery_id
and d2.delivery_type = 'CONSOLIDATION';

cursor c_get_child_details(p_parent_detail_id in number) IS
SELECT delivery_detail_id
FROM wsh_delivery_assignments_v
WHERE parent_delivery_detail_id = p_parent_detail_id;

/*CURSOR Get_Cont_Item_Info (v_cont_item_id NUMBER, v_org_id NUMBER) IS
  SELECT  Container_Type_Code, weight_uom_code, volume_uom_code,
  minimum_fill_percent, maximum_load_weight, internal_volume, primary_uom_code,
  unit_weight, unit_volume
  FROM MTL_SYSTEM_ITEMS
  WHERE inventory_item_id = v_cont_item_id
  AND container_item_flag = 'Y'
  AND organization_id = v_org_id
  AND    nvl(vehicle_item_flag,'N') = 'N'
  AND    shippable_item_flag = 'Y';

*/

CURSOR c_get_trip_id(p_delivery_id in number) IS
SELECT trip_id
FROM wsh_trip_stops s, wsh_delivery_legs l
WHERE s.stop_id = l.pick_up_stop_id
AND l.delivery_id = p_delivery_id;

l_assign_flag VARCHAR2(1);
l_del_info_tab WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
l_parent_del_info_rec WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
l_del_asg_info_rec WSH_DELIVERY_DETAILS_PKG.Delivery_Assignments_Rec_TYPE;
l_child_details_tab wsh_util_core.id_tab_type;
l_dummy_asg_tab wsh_util_core.id_tab_type;
l_wv_delivery_tab wsh_util_core.id_tab_type;
l_child_delivery_id NUMBER;
l_trip_id NUMBER;
l_parent_trip_id NUMBER;
l_parent_consol_del_id NUMBER;
l_child_trip_id NUMBER;
l_child_consol_del_id NUMBER;
l_unassign_dels wsh_util_core.id_tab_type;
l_trip_id_tab wsh_util_core.id_tab_type;

l_cont_gross_weight NUMBER;
l_cont_net_weight NUMBER;
l_cont_volume NUMBER;
l_cont_fill_pc NUMBER;

l_gross_wt NUMBER;
l_net_wt NUMBER;
l_volume NUMBER;

l_num_warnings              NUMBER  := 0;
l_num_errors                NUMBER  := 0;
l_return_status             VARCHAR2(30);

CURSOR c_get_filled_vol(p_container_id NUMBER) IS
SELECT filled_volume
FROM WSH_DELIVERY_DETAILS
WHERE delivery_detail_id = p_container_id;

l_filled_volume  NUMBER;


WSH_INVALID_CHILD EXCEPTION;
WSH_INVALID_PARENT EXCEPTION;
WSH_INVALID_CONSOL_ASSIGN EXCEPTION;
WSH_ASSIGN_CONSOL_LPN_ERROR EXCEPTION;
WSH_CONSOL_DEL_NO_MATCH EXCEPTION;
WSH_NO_CHILD_LPNS EXCEPTION;
WSH_INVALID_TRIPS EXCEPTION;

l_debug_on                    BOOLEAN;
l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'Assign_Container_to_Consol';

BEGIN

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
      WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
      WSH_DEBUG_SV.log(l_module_name,'p_child_container_id',p_child_container_id);
      WSH_DEBUG_SV.log(l_module_name,'p_parent_container_id',p_parent_container_id);
   END IF;
    -- Check if the parent lpn is a consol LPN

    OPEN c_get_container_info(p_parent_container_id);
    FETCH c_get_container_info INTO l_parent_container_info;
    IF c_get_container_info%NOTFOUND THEN
       CLOSE c_get_container_info;
       RAISE WSH_INVALID_PARENT;

    END IF;
    CLOSE c_get_container_info;

    -- validate child LPN

    OPEN c_get_container_info(p_child_container_id);
    FETCH c_get_container_info INTO l_child_container_info;
    IF c_get_container_info%NOTFOUND OR l_child_container_info.container_flag = 'C' THEN
       CLOSE c_get_container_info;
       RAISE WSH_INVALID_CHILD;
    END IF;
    CLOSE c_get_container_info;

    IF l_child_container_info.delivery_id = l_parent_container_info.delivery_id THEN

       -- Don't use this API!!!, use API's to pack into content LPNs.
       RAISE WSH_INVALID_CONSOL_ASSIGN;


    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_child_container_info.parent_delivery_id',l_child_container_info.parent_delivery_id);
      WSH_DEBUG_SV.log(l_module_name,'l_parent_container_info.parent_delivery_id',l_parent_container_info.parent_delivery_id);
      WSH_DEBUG_SV.log(l_module_name,'l_parent_container_info.container_flag',l_parent_container_info.container_flag);
    END IF;
    IF l_parent_container_info.container_flag = 'Y' THEN

    -- This is not a consol LPN, so we need to convert this to a consol before assignment.
    -- We consider the following cases:
    -- case 1. Neither the parent LPN nor the child LPN is attached to a consol delivery.
    --         We need to create a consolidation delivery for both.
    -- case 2. The parent LPN, even though not a consol LPN, is attached to
    --         a consol delivery, but the child is not.
    --         We need to assign the child container's delivery to the parent container's
    --         consol delivery.
    -- case 3. The child LPN is attached to a consol delivery, but the parent is not.
    --         We need to assign the parent container's delivery to the child
    --         container's consol delivery.
    -- case 4. Both the child and the parent containers have consolidation deliveries,
    --         but they do not match.
    --         Raise an exception since this is not a valid assignment.
    -- case 5. Both the child and the parent container have the same consol delivery.
    --         We do not need to do anything (this case is ignored) apart from converting the LPN.



       IF l_parent_container_info.parent_delivery_id IS NULL
       AND l_child_container_info.parent_delivery_id IS NULL THEN

       -- case 1. Neither the parent LPN nor the child LPN are attached to any consol deliveries.
       --         Check if the deliveries are assigned to trips. If they are assigned to
       --         the same trip, or if only one of the deliveries has a trip. Check if
       --         this trip has a consol delivery. If yes, we can use this consol delivery, else
       --         We need to create a consolidation delivery for both.
           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_child_container_info.parent_delivery_id',l_child_container_info.parent_delivery_id);
             WSH_DEBUG_SV.log(l_module_name,'l_parent_container_info.parent_delivery_id',l_parent_container_info.parent_delivery_id);
           END IF;

           -- Check if the trips have consolidation deliveries.
           -- Check trip for the parent lpn.
           OPEN c_get_trip_info(l_parent_container_info.delivery_id);
           FETCH c_get_trip_info INTO l_parent_trip_id, l_parent_consol_del_id;
           CLOSE c_get_trip_info;


           -- Check trip for the child lpn.
           OPEN c_get_trip_info(l_child_container_info.delivery_id);
           FETCH c_get_trip_info INTO l_child_trip_id, l_child_consol_del_id;
           CLOSE c_get_trip_info;

           IF (l_child_trip_id <> l_parent_trip_id) THEN

              RAISE WSH_INVALID_TRIPS;

           END IF;

           IF (l_child_trip_id IS NOT NULL) OR (l_parent_trip_id IS NOT NULL) THEN

               -- Unassign the deliveries from the trip.

               IF l_child_trip_id IS NOT NULL THEN

                  l_unassign_dels(1) := l_child_container_info.delivery_id;

               END IF;
               IF l_parent_trip_id IS NOT NULL THEN

                  l_unassign_dels(l_unassign_dels.count + 1) := l_parent_container_info.delivery_id;

               END IF;

               l_child_trip_id := NVL(l_child_trip_id, l_parent_trip_id);


              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.Unassign_Trip',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_TRIPS_ACTIONS.Unassign_Trip(p_del_rows => l_unassign_dels,
                            p_trip_id  => l_child_trip_id,
                            x_return_status => l_return_status);

              wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

              l_assign_flag := 'Y';
              l_new_parent_delivery_id := NVL(l_parent_consol_del_id, l_child_consol_del_id);
              l_del_tab(1) := l_parent_container_info.delivery_id;
              l_del_tab(2) := l_child_container_info.delivery_id;
           END IF;
           IF l_new_parent_delivery_id IS NULL THEN
           -- Create a new consolidation delivery.
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_child_container_info.parent_delivery_id',l_child_container_info.parent_delivery_id);
                WSH_DEBUG_SV.log(l_module_name,'l_parent_container_info.parent_delivery_id',l_parent_container_info.parent_delivery_id);
              END IF;

              FOR i in 1..2 LOOP

                 IF i = 1 THEN
                    l_child_delivery_id :=  l_parent_container_info.delivery_id;
                 ELSE
                    l_child_delivery_id := l_child_container_info.delivery_id;
                 END IF;

                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.Populate_Record',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 WSH_NEW_DELIVERIES_PVT.Populate_Record(
                              p_delivery_id => l_child_delivery_id,
                              x_delivery_info => l_del_info_tab(i),
                              x_return_status => l_return_status);

                 wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
                 -- Handle return status

              END LOOP;


              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_Delivery_Autocreate.Autocreate_Consol_Delivery',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              WSH_Delivery_Autocreate.Autocreate_Consol_Delivery(
                           p_del_attributes_tab => l_del_info_tab,
                           p_caller => p_caller,
                           x_parent_del_id => l_new_parent_delivery_id,
                           x_parent_trip_id => l_trip_id,
                           x_return_status => l_return_status);

              wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
           END IF;

       ELSIF  (l_parent_container_info.parent_delivery_id <> l_child_container_info.parent_delivery_id) OR
              (l_parent_container_info.parent_delivery_id IS NULL) OR
              (l_child_container_info.parent_delivery_id IS NULL) THEN
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_child_container_info.parent_delivery_id',l_child_container_info.parent_delivery_id);
             WSH_DEBUG_SV.log(l_module_name,'l_parent_container_info.parent_delivery_id',l_parent_container_info.parent_delivery_id);
          END IF;

          IF l_parent_container_info.parent_delivery_id IS NOT NULL
          AND  l_child_container_info.parent_delivery_id IS NULL THEN
          -- case 2. The parent LPN, even though not a consol LPN, is attached to
          --         a consol delivery, but the child is not.
          --         We need to assign the child containers delivery to the parent containers
          --         consol delivery.
             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_child_container_info.parent_delivery_id',l_child_container_info.parent_delivery_id);
                WSH_DEBUG_SV.log(l_module_name,'l_parent_container_info.parent_delivery_id',l_parent_container_info.parent_delivery_id);
             END IF;

             l_assign_flag := 'Y';
             l_new_parent_delivery_id := l_parent_container_info.parent_delivery_id;
             l_del_tab(1) := l_child_container_info.delivery_id;


          ELSIF l_parent_container_info.parent_delivery_id IS NULL
          AND  l_child_container_info.parent_delivery_id IS NOT NULL THEN
          -- case 3. The child LPN is attached to a consol delivery, but the parent is not.
          --         We need to assign the parent container's delivery to the child
          --         containers consol delivery.
             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_child_container_info.parent_delivery_id',l_child_container_info.parent_delivery_id);
                WSH_DEBUG_SV.log(l_module_name,'l_parent_container_info.parent_delivery_id',l_parent_container_info.parent_delivery_id);
             END IF;

		     l_assign_flag := 'Y';
		     l_new_parent_delivery_id := l_child_container_info.parent_delivery_id;
		     l_del_tab(1) := l_parent_container_info.delivery_id;


	  ELSIF l_parent_container_info.parent_delivery_id <> l_child_container_info.parent_delivery_id THEN
	  -- case 4. Both the child and the parent containers have consolidation deliveries
	  --         but they do not match.
	  --         Raise an exception since this is not a valid assignment.

	     IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'l_child_container_info.parent_delivery_id',l_child_container_info.parent_delivery_id);
		WSH_DEBUG_SV.log(l_module_name,'l_parent_container_info.parent_delivery_id',l_parent_container_info.parent_delivery_id);
	     END IF;
	     RAISE WSH_CONSOL_DEL_NO_MATCH;

	  END IF;
       ELSIF l_child_container_info.parent_delivery_id = l_parent_container_info.parent_delivery_id THEN
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_child_container_info.parent_delivery_id',l_child_container_info.parent_delivery_id);
             WSH_DEBUG_SV.log(l_module_name,'l_parent_container_info.parent_delivery_id',l_parent_container_info.parent_delivery_id);
          END IF;

          l_new_parent_delivery_id := l_parent_container_info.parent_delivery_id;

       END IF;

       -- Convert the parent LPN to be a consol LPN.

       -- Get the attributes of the parent delivery
       IF l_debug_on THEN
	 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.Populate_Record',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       WSH_NEW_DELIVERIES_PVT.Populate_Record(
			      p_delivery_id => l_new_parent_delivery_id,
			      x_delivery_info => l_parent_del_info_rec,
			      x_return_status => l_return_status);

       wsh_util_core.api_post_call
		      (
			p_return_status => l_return_status,
			x_num_warnings  => l_num_warnings,
			x_num_errors    => l_num_errors
		      );
       -- update the LPN with the parents' attributes and set the container_flag to 'C'

       -- Lock the delivery details and assignments.

       BEGIN
	  wsh_delivery_details_pkg.lock_detail_no_compare(p_delivery_detail_id => p_parent_container_id);
	  wsh_delivery_details_pkg.lock_wda_no_compare(p_delivery_detail_id => p_parent_container_id);
	  wsh_delivery_details_pkg.lock_wda_no_compare(p_delivery_detail_id => p_child_container_id);
       EXCEPTION
	  WHEN OTHERS THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    FND_MESSAGE.SET_NAME('WSH','WSH_NO_LOCK');
	    WSH_UTIL_CORE.Add_Message(x_return_status);
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_NO_LOCK exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_NO_LOCK');
	    END IF;
	    RETURN;
	   --
       END;


       update wsh_delivery_details
       set container_flag = 'C',
	   ship_to_location_id = l_parent_del_info_rec.ultimate_dropoff_location_id,
	   intmed_ship_to_location_id = l_parent_del_info_rec.intmed_ship_to_location_id,
	   customer_id = l_parent_del_info_rec.customer_id,
	   fob_code = l_parent_del_info_rec.fob_code,
	   freight_terms_code = l_parent_del_info_rec.freight_terms_code,
	   ship_method_code = l_parent_del_info_rec.ship_method_code,
	   carrier_id = l_parent_del_info_rec.carrier_id,
	   mode_of_transport = l_parent_del_info_rec.mode_of_transport,
	   service_level = l_parent_del_info_rec.service_level,
	   deliver_to_location_id = l_parent_del_info_rec.ultimate_dropoff_location_id,
	   line_direction = 'O'
       where delivery_detail_id = p_parent_container_id;


       -- Perform wda conversion.
       -- wda picture before conversion

       -----------------------------------------------------------------------
       -- | del asg id| del det id| parent det id| del id| parent del id| type
       -----------------------------------------------------------------------
       -- | 1         | dd1       | lpn1         | d1    | NULL         | S
       -----------------------------------------------------------------------
       -- | 2         | lpn1      | NULL         | d1    | NULL         | S
       -----------------------------------------------------------------------

       -- wda picture after conversion

       -----------------------------------------------------------------------
       -- | del asg id| del det id| parent det id| del id| parent del id| type
       -----------------------------------------------------------------------
       -- | 1         | dd1       | NULL         | d1    | NULL         | O
       -----------------------------------------------------------------------
       -- | 2         | lpn1      | NULL         | pd1   | NULL         | S
       -----------------------------------------------------------------------
       -- | 3         | dd1       | lpn1         | d1    | pd1          | C
       -----------------------------------------------------------------------

       -- Here we are only converting the parent LPN into a consol LPN, we are not
       -- assigning any new children to the parent yet.

       -- Parent container has a consolidation record. Since the parent
       -- is now a consol LPN, the consolidation record should be on the
       -- topmost children currently assigned to the parent, so we need
       -- to delete the parent's consolidation record.

       delete from wsh_delivery_assignments
       where delivery_detail_id = p_parent_container_id
       and type = 'C';


       -- Get the current topmost children of the parent LPN.
       IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_module_name,'p_parent_container_id',p_parent_container_id);
       END IF;

       OPEN c_get_child_details(p_parent_container_id);
       FETCH c_get_child_details BULK COLLECT
       INTO l_child_details_tab;
       IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_module_name,'l_child_details_tab.count',l_child_details_tab.count);
       END IF;
       CLOSE c_get_child_details;

       -- lock the children.

       BEGIN
	  FOR i in 1..l_child_details_tab.count LOOP
	      wsh_delivery_details_pkg.lock_wda_no_compare(p_delivery_detail_id => l_child_details_tab(i));
	  END LOOP;

       EXCEPTION
	  WHEN OTHERS THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    FND_MESSAGE.SET_NAME('WSH','WSH_NO_LOCK');
	    WSH_UTIL_CORE.Add_Message(x_return_status);
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_NO_LOCK exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_NO_LOCK');
	    END IF;
	    RETURN;
	   --
       END;

       -- Step 1.
       -- Update the outer assignment to be 'O', and null out
       -- its parent delivery detail id which is now a consolidation LPN.

       FORALL i in 1..l_child_details_tab.count
       update wsh_delivery_assignments
       set parent_delivery_detail_id = NULL,
       type = 'O'
       where delivery_detail_id = l_child_details_tab(i)
       and NVL(type, 'S') = 'S';



       -- Step 2.
       -- Now update the consol LPN's delivery assignment to be the consol delivery,
       -- and set its parent delivery id to be NULL.

       update wsh_delivery_assignments
       set delivery_id = l_new_parent_delivery_id,
	   parent_delivery_id = NULL,
	   type = 'S'
       where delivery_detail_id = p_parent_container_id;

       -- Step 3.
       -- Create new delivery assignments with type 'C' for all the topmost
       -- children of the parent.

       l_del_asg_info_rec.parent_delivery_detail_id := p_parent_container_id;
       l_del_asg_info_rec.delivery_id := l_parent_container_info.delivery_id;
       l_del_asg_info_rec.parent_delivery_id := l_new_parent_delivery_id;
       l_del_asg_info_rec.type := 'C';

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_Delivery_Details_PKG.Create_Deliv_Assignment_bulk',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       WSH_Delivery_Details_PKG.Create_Deliv_Assignment_bulk(
                     p_delivery_assignments_info => l_del_asg_info_rec,
                     p_num_of_rec => l_child_details_tab.count,
                     p_dd_id_tab => l_child_details_tab,
                     x_da_id_tab => l_dummy_asg_tab,
                     x_return_status => l_return_status);

       wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
       -- Handle return status

    ELSE -- if l_parent_container_info.container_flag = 'C'

    -- The parent is already a consol LPN.
    -- this implies that the delivery id of the parent in wda
    -- is the consol delivery.

       IF l_child_container_info.parent_delivery_id IS NULL THEN

         -- Assign child delivery to parent's delivery.
         -- this will validate the constraints and the deconsol point.

         l_assign_flag := 'Y';
         l_del_tab(1) := l_child_container_info.delivery_id;
         l_new_parent_delivery_id := l_parent_container_info.delivery_id;


       ELSIF l_child_container_info.parent_delivery_id <> l_parent_container_info.delivery_id THEN

          -- Error! The child's parent delivery has to be the same as the consol delivery of the parent.

          -- RAISE EXCEPTION;
          RAISE WSH_CONSOL_DEL_NO_MATCH;
       ELSE

         l_new_parent_delivery_id := l_parent_container_info.delivery_id;

       END IF;

    END IF; -- if l_parent_container_info.container_flag = 'Y'

    -- We now need to make the assignment of deliveries to consol deliveries where
    -- one delivery had a consol delivery and the other did not.

    IF l_assign_flag = 'Y' THEN

       -- Assign the unassigned delivery to the consol delivery.
       -- This will also validate constraints/deconsol point.


        FOR i in 1..l_del_tab.count LOOP

            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.Populate_Record',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            WSH_NEW_DELIVERIES_PVT.Populate_Record(
                              p_delivery_id => l_del_tab(i),
                              x_delivery_info => l_del_info_tab(i),
                              x_return_status => l_return_status);

            wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
                 -- Handle return status

       END LOOP;




       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_New_Delivery_Actions.Assign_Del_to_Consol_Del',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       WSH_New_Delivery_Actions.Assign_Del_to_Consol_Del(
            p_del_tab         => l_del_info_tab,
            p_parent_del_id   => l_new_parent_delivery_id,
            p_caller          => p_caller,
            x_return_status   => l_return_status);

          -- Handle return status.

        wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

    END IF;


    -- At this point the parent LPN is a consol LPN and is assigned to a
    -- consol delivery. The child LPN is also assigned to the same consol delivery.
    -- All we need to do now is to update the child's consolidation record to
    -- create the assignment.

    update wsh_delivery_assignments
    set parent_delivery_detail_id = p_parent_container_id
    where delivery_detail_id = p_child_container_id
    and type = 'C';

    -- Handle wt/vol for consol deliveries/LPNs.
/***
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.Container_Weight_Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    WSH_WV_UTILS.Container_Weight_Volume (
         p_container_instance_id => p_parent_container_id,
         p_override_flag         => 'Y',
         p_fill_pc_flag          => 'Y',
         p_post_process_flag     => 'N',
         p_calc_wv_if_frozen     => 'N',
         x_gross_weight          => l_cont_gross_weight,
         x_net_weight            => l_cont_net_weight,
         x_volume                => l_cont_volume,
         x_cont_fill_pc          => l_cont_fill_pc,
         x_return_status         => l_return_status);

    wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
***/
    -- Need to recalculate the wt/vol for the releated entities.
    -- Calculating for the trips would drive all the way to the deliveries and lpns.
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.trip_weight_volume',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    OPEN c_get_filled_vol(p_parent_container_id);
    FETCH c_get_filled_vol INTO l_filled_volume;
    CLOSE c_get_filled_vol;

    OPEN c_get_trip_id(l_new_parent_delivery_id);
    FETCH c_get_trip_id INTO l_trip_id_tab(1);
    CLOSE c_get_trip_id;
    WSH_TRIPS_ACTIONS.trip_weight_volume(
          p_trip_rows            => l_trip_id_tab,
          p_override_flag        => 'Y',
          p_calc_wv_if_frozen    => 'N',
          p_start_departure_date => to_date(NULL),
          p_calc_del_wv          => 'Y',
          x_return_status        => l_return_status,
          p_suppress_errors      => 'N');

    UPDATE wsh_delivery_details
    SET filled_volume = l_filled_volume
    WHERE delivery_detail_id =  p_parent_container_id;

    IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Error calculating trip wt/vol');
      END IF;
    END IF;
/*

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.Delivery_Weight_Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    WSH_WV_UTILS.Delivery_Weight_Volume
                ( p_delivery_id    => l_new_parent_delivery_id,
                  p_update_flag    => 'Y',
                  p_calc_wv_if_frozen => 'N',
                  x_gross_weight   => l_gross_wt,
                  x_net_weight     => l_net_wt,
                  x_volume         => l_volume,
                  x_return_status  => l_return_status);
*/
    wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors);

    IF l_num_errors > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
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
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;

    WHEN WSH_INVALID_TRIPS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_TRIPS');
      WSH_UTIL_CORE.Add_Message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_TRIPS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_TRIPS');
      END IF;

    WHEN WSH_NO_CHILD_LPNS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_NO_CHILD_LPNS');
      WSH_UTIL_CORE.Add_Message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_NO_CHILD_LPNS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_NO_CHILD_LPNS');
      END IF;

    WHEN WSH_CONSOL_DEL_NO_MATCH THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_CONSOL_DEL_NO_MATCH');
      WSH_UTIL_CORE.Add_Message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CONSOL_DEL_NO_MATCH exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CONSOL_DEL_NO_MATCH');
      END IF;

    WHEN WSH_ASSIGN_CONSOL_LPN_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_ASSIGN_CONSOL_LPN_ERROR');
      WSH_UTIL_CORE.Add_Message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_ASSIGN_CONSOL_LPN_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_ASSIGN_CONSOL_LPN_ERROR');
      END IF;

    WHEN WSH_INVALID_CONSOL_ASSIGN THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONSOL_ASSIGN');
      WSH_UTIL_CORE.Add_Message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_CONSOL_ASSIGN exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_CONSOL_ASSIGN');
      END IF;

    WHEN WSH_INVALID_PARENT THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_PARENT');
      WSH_UTIL_CORE.Add_Message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_PARENT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_PARENT');
      END IF;

    WHEN WSH_INVALID_CHILD THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CHILD');
      WSH_UTIL_CORE.Add_Message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_CHILD exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_CHILD');
      END IF;
       --

    WHEN OTHERS THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('wsh_container_actions.Assign_Container_to_Consol', l_module_name);
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END Assign_Container_to_Consol;

PROCEDURE Unpack_Details_from_Consol
               (p_delivery_details_tab IN WSH_UTIL_CORE.ID_TAB_TYPE,
                p_caller               IN VARCHAR2,
                x_return_status       OUT NOCOPY VARCHAR2) IS

cursor c_check_valid_combination(p_dd_id IN NUMBER) IS
select wdd1.delivery_detail_id,
       wdd2.delivery_detail_id,
       wdd1.gross_weight,
       wdd1.net_weight,
       wdd1.volume,
       wdd1.weight_uom_code,
       wdd1.volume_uom_code,
       wdd1.inventory_item_id,
       wdd2.weight_uom_code,
       wdd2.volume_uom_code
from wsh_delivery_details wdd1,
     wsh_delivery_details wdd2,
     wsh_delivery_assignments wda,
     wsh_new_deliveries wnd
where wdd1.delivery_detail_id = p_dd_id
and wda.delivery_detail_id = wdd1.delivery_detail_id
and wda.type = 'C'
and wda.delivery_id = wnd.delivery_id
and wnd.status_code = 'OP'
and wdd1.container_flag in ('Y', 'N')
and wda.parent_delivery_detail_id = wdd2.delivery_detail_id
and wdd2.container_flag = 'C'
order by wdd2.delivery_detail_id;

cursor c_check_empty_consol(p_consol_lpn_id in number) is
select delivery_detail_id
from wsh_delivery_assignments
where parent_delivery_detail_id = p_consol_lpn_id
and type = 'C'
and rownum = 1;


l_consol_lpn_tab wsh_util_core.id_tab_type;
l_empty_lpn_tab wsh_util_core.id_tab_type;
l_rem_lpn_tab  wsh_util_core.id_tab_type;

l_cont_gross_weight    NUMBER;
l_cont_net_weight      NUMBER;
l_cont_volume          NUMBER;
l_child_gross_weight    NUMBER;
l_child_net_weight      NUMBER;
l_child_volume          NUMBER;
l_child_inv_item_id     NUMBER;
l_child_weight_UOM      VARCHAR2(30);
l_child_volume_UOM      VARCHAR2(30);
l_parent_weight_UOM      VARCHAR2(30);
l_parent_volume_UOM      VARCHAR2(30);
l_cont_fill_pc         NUMBER;
l_child_dd_id          NUMBER;
l_parent_dd_id          NUMBER;
l_dummy_dd_id          NUMBER;
j                      NUMBER := 0;
k                      NUMBER := 0;
l                      NUMBER := 0;

l_num_warnings              NUMBER  := 0;
l_num_errors                NUMBER  := 0;
l_return_status             VARCHAR2(30);

WSH_INVALID_COMBINATION EXCEPTION;

l_debug_on                    BOOLEAN;
l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'Unpack_Details_from_Consol';

BEGIN

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
      WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
   END IF;
   --


   FOR i in 1..p_delivery_details_tab.count LOOP

       OPEN c_check_valid_combination(p_delivery_details_tab(i));
       FETCH c_check_valid_combination
       INTO l_child_dd_id,
            l_parent_dd_id,
            l_cont_gross_weight,
            l_cont_net_weight,
            l_cont_volume,
            l_child_weight_UOM,
            l_child_volume_UOM,
            l_child_inv_item_id,
            l_parent_weight_UOM,
            l_parent_volume_UOM;
       IF c_check_valid_combination%NOTFOUND THEN
          CLOSE c_check_valid_combination;
          RAISE WSH_INVALID_COMBINATION;
       END IF;
       CLOSE c_check_valid_combination;

       IF i = 1 THEN
          j := 1;
          l_consol_lpn_tab(j) := l_parent_dd_id;
       ELSIF l_parent_dd_id <> l_consol_lpn_tab(j) THEN
          j := j +1;
          l_consol_lpn_tab(j) := l_parent_dd_id;
       END IF;

       -- Lock the delivery assignments.

       BEGIN

          WSH_DELIVERY_DETAILS_PKG.lock_wda_no_compare(p_delivery_detail_id => p_delivery_details_tab(i));

       EXCEPTION
         WHEN OTHERS THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('WSH','WSH_NO_LOCK');
           WSH_UTIL_CORE.Add_Message(x_return_status);
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'WSH_NO_LOCK exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_NO_LOCK');
           END IF;
           RETURN;
           --
       END;



       -- WMS will update the consol LPN with the decremented wt/vol (LPN convergence).
       -- This will also decrement the consol delivery wt/vol. However since the child
       -- LPN is still attached to the consol delivery, the consol delivery wt/vol should
       -- not change. So here we put back the child wt/vol onto the consol delivery in
       -- anticipation of it being decremented during the WMS call.


       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_cont_gross_weight',l_cont_gross_weight);
          WSH_DEBUG_SV.log(l_module_name,'l_cont_net_weight',l_cont_net_weight);
          WSH_DEBUG_SV.log(l_module_name,'l_cont_volume',l_cont_volume);
          WSH_DEBUG_SV.log(l_module_name,'l_child_weight_UOM',l_child_weight_UOM);
          WSH_DEBUG_SV.log(l_module_name,'l_parent_weight_UOM',l_parent_weight_UOM);
          WSH_DEBUG_SV.log(l_module_name,'l_child_volume_UOM',l_child_volume_UOM);
          WSH_DEBUG_SV.log(l_module_name,'l_parent_volume_UOM',l_parent_volume_UOM);
       END IF;

       -- convert the child UOM to the parent UOMs.

       IF l_child_weight_UOM = l_parent_weight_UOM THEN
          l_child_gross_weight := l_cont_gross_weight;
          l_child_net_weight   := l_cont_net_weight;
       ELSE

          IF NVL(l_cont_gross_weight, 0) = 0 THEN
             l_child_gross_weight := 0;
          ELSE
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.convert_uom',WSH_DEBUG_SV.C_PROC_LEVEL);
                WSH_DEBUG_SV.log(l_module_name,'l_cont_gross_weight',l_cont_gross_weight);
             END IF;
             l_child_gross_weight :=
             WSH_WV_UTILS.convert_uom(l_child_weight_UOM, l_parent_weight_UOM, l_cont_gross_weight, l_child_inv_item_id);
          END IF;
          IF NVL(l_cont_net_weight, 0) = 0 THEN
             l_child_net_weight := 0;
          ELSE
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.convert_uom',WSH_DEBUG_SV.C_PROC_LEVEL);
                WSH_DEBUG_SV.log(l_module_name,'l_cont_net_weight',l_cont_net_weight);
             END IF;
             l_child_net_weight :=
             WSH_WV_UTILS.convert_uom(l_child_weight_UOM, l_parent_weight_UOM, l_cont_net_weight, l_child_inv_item_id);
          END IF;

       END IF;
       IF l_child_volume_UOM = l_parent_volume_UOM THEN
          l_child_volume := l_cont_volume;
       ELSE

          IF NVL(l_cont_volume, 0) = 0 THEN
             l_child_volume := 0;
          ELSE
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.convert_uom',WSH_DEBUG_SV.C_PROC_LEVEL);
                WSH_DEBUG_SV.log(l_module_name,'l_cont_volume',l_cont_volume);
             END IF;
             l_child_volume :=
             WSH_WV_UTILS.convert_uom(l_child_volume_UOM, l_parent_volume_UOM, l_cont_volume, l_child_inv_item_id);
          END IF;

       END IF;

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       WSH_WV_UTILS.DD_WV_Post_Process(
          p_delivery_detail_id => l_parent_dd_id,
          p_diff_gross_wt      => l_child_gross_weight,
          p_diff_net_wt        => l_child_net_weight,
          p_diff_volume        => l_child_volume,
          p_diff_fill_volume   => l_child_volume,
          x_return_status      => l_return_status);

       WSH_UTIL_CORE.API_Post_Call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors);


   END LOOP;

   FORALL i in 1..p_delivery_details_tab.count
   update wsh_delivery_assignments
   set parent_delivery_detail_id = NULL
   where delivery_detail_id = p_delivery_details_tab(i)
   and type = 'C';



   IF l_num_errors > 0
   THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   ELSIF l_num_warnings > 0
   THEN
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


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;


  WHEN WSH_INVALID_COMBINATION THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_COMBINATION');
        WSH_UTIL_CORE.Add_Message(x_return_status);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_COMBINATION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_COMBINATION');
        END IF;
        --

  WHEN OTHERS THEN
    wsh_util_core.default_handler('wsh_container_actions.unassign_detail_from_consol',l_module_name);
      --
    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
    END IF;

END Unpack_Details_from_Consol;

END wsh_container_actions;

/
