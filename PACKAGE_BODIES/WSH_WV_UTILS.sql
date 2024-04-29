--------------------------------------------------------
--  DDL for Package Body WSH_WV_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_WV_UTILS" as
/* $Header: WSHWVUTB.pls 120.23.12010000.5 2009/06/12 11:00:20 mvudugul ship $ */


--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_WV_UTILS';
--
-- HW OPMCONV - Added lot_number and org_id parameters
c_wms_code_present VARCHAR2(2) := 'Y';

-- MDC keep track of the parent consol LPN to prevent double counting
g_consol_lpn NUMBER;

-- OTM R12 : packing ECO
-- default to 'Y' so only specific flow will use this to update delivery
G_DELIVERY_TMS_IMPACT  VARCHAR2(1) := 'Y';
-- End of OTM R12 : packing ECO

--OTM R12, header include for the prorate procedure

PROCEDURE Prorate_weight_actual(
            p_entity_type	    IN         VARCHAR2,
            p_entity_id		    IN         NUMBER,
            p_old_gross_wt	    IN         NUMBER,
	    p_new_gross_wt	    IN         NUMBER,
            p_old_net_wt	    IN         NUMBER,
	    p_new_net_wt	    IN         NUMBER,
            p_weight_uom_code       IN         VARCHAR2,
	    x_return_status         OUT NOCOPY VARCHAR2,
            p_call_level            IN         NUMBER);
--

FUNCTION convert_uom(from_uom IN VARCHAR2,
		     to_uom IN VARCHAR2,
		     quantity IN NUMBER,
		     item_id IN NUMBER DEFAULT NULL,
		     p_max_decimal_digits IN NUMBER DEFAULT 5, -- RV DEC_QTY
		     lot_number VARCHAR2 DEFAULT NULL,
		     org_id IN NUMBER DEFAULT NULL)
RETURN NUMBER
IS
  this_item     NUMBER;
  to_rate       NUMBER;
  from_rate     NUMBER;
  result        NUMBER;

--
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONVERT_UOM';
--
BEGIN
  --
  --
  IF quantity is NULL THEN
    result := NULL;
  ELSE
    IF from_uom = to_uom THEN
       result := round(quantity,p_max_decimal_digits);
    ELSIF    from_uom IS NULL
          OR to_uom   IS NULL THEN
       result := 0;
    ELSE
       --
       --
       -- RV DEC_QTY
       -- p_max_decimal_digits has a default value of 5.  Therefore
       -- for all the outbound transactions, it will be passed as 5.
       -- But for inbound data the value will be 38.
-- HW OPMCONV - Check for specific values to call the correct
-- procedure
      IF (lot_number is NOT NULL OR org_id is NOT NULL ) THEN
-- Inventory has an overloaded procedure to perform
-- the UOM conversion

-- RV DEC_QTY
       -- p_max_decimal_digits has a default value of 5.  Therefore
       -- for all the outbound transactions, it will be passed as 5.
       -- But for inbound data the value will be 38.

       result := INV_CONVERT.inv_um_convert(item_id,
                                            lot_number,
                                            org_id,
                                            p_max_decimal_digits, -- Bug 1842481 : precision digits changed to 5
                                            quantity,
                                            from_uom,
                                            to_uom,
                                            NULL,
                                            NULL
                                            );
-- Use old call
    ELSE
       result := INV_CONVERT.inv_um_convert(item_id,
                                            p_max_decimal_digits, -- Bug 1842481 : precision digits changed to 5
                                            quantity,
                                            from_uom,
                                            to_uom,
                                            NULL,
                                            NULL);

       --
       --
    END IF;

       -- hard-coded value that means undefined conversion
       --  For example, conversion of FT2 to FT3 doesn't make sense...
       -- Reset the result to 0 to preserve compatibility before
       -- the bug fix made above (namely, always call inv_um_convert).
       if result = -99999 then
          result := 0;
          FND_MESSAGE.SET_NAME('WSH','WSH_UNDEF_UOM_CONVERSION');
     FND_MESSAGE.SET_TOKEN('FROM_UOM',from_uom);
     FND_MESSAGE.SET_TOKEN('TO_UOM',to_uom);
       end if;
    END IF;
  END IF;

  --
  RETURN result;

END convert_uom;

FUNCTION convert_uom_core(from_uom IN VARCHAR2,
		     to_uom IN VARCHAR2,
		     quantity IN NUMBER,
		     item_id IN NUMBER DEFAULT NULL,
		     p_max_decimal_digits IN NUMBER DEFAULT 5, -- RV DEC_QTY
		     lot_number VARCHAR2 DEFAULT NULL,
		     org_id IN NUMBER DEFAULT NULL,
                     x_return_status OUT NOCOPY VARCHAR2)
RETURN NUMBER
IS
  this_item     NUMBER;
  to_rate       NUMBER;
  from_rate     NUMBER;
  result        NUMBER;
  l_ignore_wtvol  VARCHAR2(5);

--
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONVERT_UOM_CORE';
--
BEGIN
  --
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  IF quantity is NULL THEN
    result := NULL;
  ELSE
    IF from_uom = to_uom THEN
       result := round(quantity,p_max_decimal_digits);
    ELSIF    from_uom IS NULL
          OR to_uom   IS NULL THEN
       result := 0;
    ELSE
       --
       --
       -- RV DEC_QTY
       -- p_max_decimal_digits has a default value of 5.  Therefore
       -- for all the outbound transactions, it will be passed as 5.
       -- But for inbound data the value will be 38.
-- HW OPMCONV - Check for specific values to call the correct
-- procedure
      IF (lot_number is NOT NULL OR org_id is NOT NULL ) THEN
-- Inventory has an overloaded procedure to perform
-- the UOM conversion

-- RV DEC_QTY
       -- p_max_decimal_digits has a default value of 5.  Therefore
       -- for all the outbound transactions, it will be passed as 5.
       -- But for inbound data the value will be 38.

       result := INV_CONVERT.inv_um_convert(item_id,
                                            lot_number,
                                            org_id,
                                            p_max_decimal_digits, -- Bug 1842481 : precision digits changed to 5
                                            quantity,
                                            from_uom,
                                            to_uom,
                                            NULL,
                                            NULL
                                            );
-- Use old call
    ELSE
       result := INV_CONVERT.inv_um_convert(item_id,
                                            p_max_decimal_digits, -- Bug 1842481 : precision digits changed to 5
                                            quantity,
                                            from_uom,
                                            to_uom,
                                            NULL,
                                            NULL);

       --
       --
    END IF;

       -- hard-coded value that means undefined conversion
       --  For example, conversion of FT2 to FT3 doesn't make sense...
       -- Reset the result to 0 to preserve compatibility before
       -- the bug fix made above (namely, always call inv_um_convert).

          if result = -99999 then
             fnd_profile.get('WSH_IGNORE_WT_VOL',l_ignore_wtvol);
             IF NVL(l_ignore_wtvol,'Y') = 'N' THEN
                x_return_status := wsh_util_core.g_ret_sts_error;
                FND_MESSAGE.SET_NAME('WSH','WSH_UNDEF_UOM_CONVERSION');
                FND_MESSAGE.SET_TOKEN('FROM_UOM',from_uom);
                FND_MESSAGE.SET_TOKEN('TO_UOM',to_uom);
                WSH_UTIL_CORE.add_message (x_return_status);
             END IF;
             result := 0;
          end if;
    END IF;
  END IF;

  --
  RETURN result;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_WV_UTILS.convert_uom_core');
      --

END convert_uom_core;

PROCEDURE get_default_uoms ( p_organization_id IN NUMBER,
            x_weight_uom_code  OUT NOCOPY  VARCHAR2,
            x_volume_uom_code  OUT NOCOPY  VARCHAR2,
            x_return_status    OUT NOCOPY  VARCHAR2) IS

CURSOR cur_get_uom (x_uom_class IN VARCHAR2) IS
  SELECT UOM_CODE
  FROM mtl_units_of_measure
  WHERE base_uom_flag = 'Y' AND
      uom_class = x_uom_class;

-- Bug# 8446283 : Added weight and volume UOM codes
CURSOR get_class IS
  SELECT weight_uom_class,weight_uom_code,volume_uom_class,volume_uom_code
  FROM   wsh_shipping_parameters
  WHERE  organization_id = p_organization_id;

l_weight_uom_class VARCHAR2(10);
l_volume_uom_class VARCHAR2(10);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DEFAULT_UOMS';
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
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS; --Bug 8369407
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
    END IF;
    --
    if ( p_organization_id is NULL ) Then
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      Return;
    end if;

    -- Bug# 8446283 : Added weight and volume UOM codes
    OPEN get_class;
    FETCH get_class INTO l_weight_uom_class,x_weight_uom_code,l_volume_uom_class,x_volume_uom_code;
    CLOSE get_class;

    IF (x_weight_uom_code IS NULL AND l_weight_uom_class IS NOT NULL ) THEN
    --{
        OPEN cur_get_uom(l_weight_uom_class);
        FETCH cur_get_uom INTO x_weight_uom_code;
        CLOSE cur_get_uom;
    --}
    END IF;
    IF (x_volume_uom_code IS NULL AND l_volume_uom_class IS NOT NULL) THEN
    --{
        OPEN cur_get_uom(l_volume_uom_class);
        FETCH cur_get_uom INTO x_volume_uom_code;
        CLOSE cur_get_uom;
    --}
    END IF;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_weight_uom_code',x_weight_uom_code);
        WSH_DEBUG_SV.log(l_module_name,'x_volume_uom_code',x_volume_uom_code);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION
    WHEN Others THEN
     WSH_UTIL_CORE.Default_Handler ('WSH_WV_UTILS.GET_DEFAULT_UOMS');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END get_default_uoms;


-- J: W/V Changes

-- Start of comments
-- API name : Detail_Weight_Volume
-- Type     : Public
-- Pre-reqs : None.
-- Function : Calculates Weight and Volume of Delivery Detail
--            If p_update_flag is 'Y' then the calculated W/V is updated on Delivery Detail
--            Otherwise, the API returns the calculated W/V
--            OTM R12 : packing ECO
--                      This procedure is modified to keep track of delivery
--                      detail wt/vol updates. Changed because it contains the
--                      actual update on the wsh_delivery_detail table.
-- Parameters :
-- IN:
--    p_delivery_detail_id IN NUMBER Required
--    p_update_flag        IN VARCHAR2
--      'Y' if the detail needs to be updated with the calculated W/V
--    p_calc_wv_if_frozen  IN VARCHAR2
--      'Y' if manual W/V can be overriden
-- OUT:
--    x_net_weight OUT NUMBER
--       gives the net weight of delivery detail
--    x_volume OUT NUMBER
--       gives the volume of delivery detail
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Detail_Weight_Volume (
  p_delivery_detail_id IN NUMBER,
  p_update_flag        IN VARCHAR2,
  p_calc_wv_if_frozen  IN VARCHAR2 DEFAULT 'Y',
  x_net_weight         OUT NOCOPY  NUMBER,
  x_volume             OUT NOCOPY  NUMBER,
  x_return_status      OUT NOCOPY  VARCHAR2) AS


  CURSOR Item_Net_Wt_Vol(v_delivery_detail_id NUMBER) IS
  SELECT convert_uom(
           msi.weight_uom_code,
           NVL(wdd.weight_uom_code,msi.weight_uom_code),
           (NVL(wdd.unit_weight,msi.unit_weight) *
              convert_uom(
                wdd.requested_quantity_uom,
                msi.primary_uom_code,
                nvl(wdd.received_quantity, nvl(wdd.shipped_quantity, NVL(wdd.picked_quantity, wdd.requested_quantity))),
                wdd.inventory_item_id) ),
            wdd.inventory_item_id ) WEIGHT,
          convert_uom(
            msi.volume_uom_code,
            NVL(wdd.volume_uom_code,msi.volume_uom_code),
            (NVL(wdd.unit_volume,msi.unit_volume) *
               convert_uom(
                 wdd.requested_quantity_uom,
                 msi.primary_uom_code,
                 nvl(wdd.received_quantity, nvl(wdd.shipped_quantity, NVL(wdd.picked_quantity, wdd.requested_quantity))),
                 wdd.inventory_item_id) ),
            wdd.inventory_item_id ) VOLUME,
          msi.weight_uom_code,
          msi.volume_uom_code,
          msi.unit_weight,
          msi.unit_volume
  FROM    wsh_delivery_details wdd,
          mtl_system_items     msi
  WHERE   wdd.delivery_detail_id = v_delivery_detail_id
  AND     msi.inventory_item_id = wdd.inventory_item_id
  AND     msi.organization_id = wdd.organization_id;


  /* Bug 2177410, for non item just return the net weight and
     volume of the delivery detail  */
  CURSOR get_detail_wv (v_delivery_detail_id NUMBER ) IS
  select wdd.inventory_item_id,
         wdd.organization_id,
         wdd.net_weight,
         wdd.volume,
         wdd.gross_weight ,
         wdd.unit_weight,
         wdd.unit_volume,
         nvl(wdd.received_quantity, nvl(wdd.shipped_quantity, NVL(wdd.picked_quantity, wdd.requested_quantity))) qty,
         wdd.weight_uom_code,
         wdd.volume_uom_code,
         --lpn conv
         wdd.container_flag,
         NVL(wdd.wv_frozen_flag,'Y'),
         nvl(line_direction,'O') line_direction -- LPN CONV. rv
  from   wsh_delivery_details wdd
  where  wdd.delivery_detail_id = v_delivery_detail_id;

  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DETAIL_WEIGHT_VOLUME';
  l_inventory_item_id NUMBER;
  l_organization_id   NUMBER;
  l_net_weight        NUMBER;
  l_volume            NUMBER;
  l_gross_weight      NUMBER;
  l_dd_wt_code        VARCHAR(100);
  l_dd_vol_code       VARCHAR(100);
  l_wv_frozen_flag    VARCHAR2(1);
  l_unit_wt           NUMBER;
  l_unit_vol          NUMBER;
  l_qty               NUMBER;
  l_item_wt_code      VARCHAR(100);
  l_item_vol_code     VARCHAR(100);
  l_item_unit_wt      NUMBER;
  l_item_unit_vol     NUMBER;
  l_frozen_flag       VARCHAR2(1);
  l_return_status     VARCHAR2(1);
  l_detail_tab        WSH_UTIL_CORE.Id_Tab_Type;
  --lpn conv
  l_container_flag    VARCHAR2(10);
  l_wms_org           VARCHAR2(10) := 'N';
  -- LPN CONV. rv
  l_sync_tmp_rec    wsh_glbl_var_strct_grp.sync_tmp_rec_type;
  -- LPN CONV. rv
  l_line_direction    VARCHAR2(10);
  l_num_warnings      NUMBER := 0;
  mark_reprice_error  EXCEPTION;

BEGIN

      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      IF l_debug_on IS NULL THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_FLAG',P_UPDATE_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_CALC_WV_IF_FROZEN',P_CALC_WV_IF_FROZEN);
      END IF;

      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      -- Get the original W/V of the delivery detail
      OPEN  get_detail_wv (p_delivery_detail_id);
      FETCH get_detail_wv
      INTO  l_inventory_item_id,
            l_organization_id,
            l_net_weight,
            l_volume,
            l_gross_weight,
            l_unit_wt,
            l_unit_vol,
            l_qty,
            l_dd_wt_code,
            l_dd_vol_code,
            -- lpn conv
            l_container_flag,
            l_wv_frozen_flag,
            l_line_direction; -- LPN CONV. rv
      IF get_detail_wv%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_DET_INVALID_DETAIL');
        FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_delivery_detail_id);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        CLOSE get_detail_wv;
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        return;
      END IF;
      CLOSE get_detail_wv;

      --lpn conv
      IF l_container_flag IN ('Y', 'C')  THEN
         l_wms_org := wsh_util_validate.check_wms_org(l_organization_id);
         IF l_wms_org = 'Y' THEN
            l_wv_frozen_flag := 'N';
         END IF;
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Item Id '||l_inventory_item_id||' Org '||l_organization_id||' Wt Code '||l_dd_wt_code||' Vol Code '||l_dd_vol_code||' Qty '||l_qty);
        WSH_DEBUG_SV.logmsg(l_module_name,'Gross '||l_gross_weight||' Net '||l_net_weight||' Vol '||l_volume||' U Wt '||l_unit_wt||' U Vol '||l_unit_vol||' Frozen '||l_wv_frozen_flag);
      END IF;

      -- Return the original W/V if the W/V is manually entered and p_calc_wv_if_frozen is 'N'
      IF p_calc_wv_if_frozen = 'N' and l_wv_frozen_flag ='Y' THEN
        x_net_weight := l_net_weight;
        x_volume     := l_volume;
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Detail weights are Frozen. Skipping W/V calculation');
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;

      --  If the delivery details has one time item then
      --    If the delivery detail doesn't have unit wt or volume specified then
      --       do not calculate W/V.
      --    Else
      --       calculate the W/V.
      --  Else calculate the W/V.
      --       If p_update_flag is 'Y' then update the W/V info on delivery detail
      IF l_inventory_item_id is NULL THEN
        IF l_unit_wt is NULL AND l_unit_vol is NULL THEN
          x_net_weight := l_net_weight;
          x_volume     := l_volume;
        ELSE
          x_net_weight := l_qty * l_unit_wt;
          x_volume     := l_qty * l_unit_vol;
          l_frozen_flag := 'N';
        END IF;

      ELSE

        OPEN  Item_Net_Wt_Vol (p_delivery_detail_id);

        FETCH Item_Net_Wt_Vol
        INTO  x_net_weight,
              x_volume,
              l_item_wt_code,
              l_item_vol_code,
              l_item_unit_wt,
              l_item_unit_vol;

        IF Item_Net_Wt_Vol%NOTFOUND THEN
          FND_MESSAGE.SET_NAME('WSH', 'WSH_DET_INVALID_DETAIL');
          FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_delivery_detail_id);
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          CLOSE Item_Net_Wt_Vol;
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           return;
        END IF;
        CLOSE Item_Net_Wt_Vol;
        l_frozen_flag := 'N';
      END IF;

      IF p_update_flag = 'Y' THEN

         --lpn conv
         IF NVL(l_frozen_flag,'Y') = 'Y' THEN
            IF l_wms_org = 'Y' AND l_container_flag IN ('Y', 'C') THEN
               l_frozen_flag := 'N';
            END IF;
         END IF;
         -- LPN CONV. rv
         --
         --
         IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
         AND l_line_direction IN ('O','IO')
         AND l_container_flag IN ('Y','C')
         AND
         (
           ((WSH_WMS_LPN_GRP.GK_WMS_UPD_WV or WSH_WMS_LPN_GRP.GK_WMS_UPD_ITEM) and l_wms_org = 'Y')
           OR
           ((WSH_WMS_LPN_GRP.GK_INV_UPD_WV or WSH_WMS_LPN_GRP.GK_INV_UPD_ITEM) and l_wms_org = 'N')
         )
         THEN
         --{
             l_sync_tmp_rec.delivery_detail_id := p_delivery_detail_id;
             l_sync_tmp_rec.operation_type := 'UPDATE';
             --
             -- Debug Statements
             --
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --

             WSH_WMS_SYNC_TMP_PKG.MERGE
             (
               p_sync_tmp_rec      => l_sync_tmp_rec,
               x_return_status     => l_return_status
             );

             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_WMS_SYNC_TMP_PKG.MERGE',l_return_status);
             END IF;
             --
             IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
               --
               x_return_status := l_return_status;
               --
               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'WSH_WMS_SYNC_TMP_PKG.MERGE completed with an error');
                 WSH_DEBUG_SV.pop(l_module_name);
               END IF;
               --
               RETURN;
             ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               l_num_warnings := l_num_warnings + 1;
             END IF;
         --}
         END IF;
         -- K LPN CONV. rv
         --
         UPDATE WSH_DELIVERY_DETAILS
         SET net_weight        = x_net_weight,
             volume            = x_volume,
             gross_weight      = x_net_weight,
             weight_uom_code   = nvl(weight_uom_code,l_item_wt_code),
             volume_uom_code   = nvl(volume_uom_code,l_item_vol_code),
             unit_weight       = NVL(unit_weight,l_item_unit_wt),
             unit_volume       = NVL(unit_volume,l_item_unit_vol),
             wv_frozen_flag    = decode(l_frozen_flag,NULL,wv_frozen_flag,l_frozen_flag),
             last_update_date  = SYSDATE,
             last_updated_by   = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
         WHERE delivery_detail_id = p_delivery_detail_id;

         IF SQL%NOTFOUND THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
           FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_delivery_detail_id);
           IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           return;
         END IF;

         -- bug 3711017 mark reprice required only when weight volume have changed
         IF ((l_dd_wt_code is NULL and l_item_wt_code is not NULL )
           or (l_dd_vol_code is NULL and l_item_vol_code is not NULL)
           or nvl(x_net_weight, 0) <> nvl(l_net_weight, 0)
           or nvl(x_volume, 0) <> nvl(l_volume, 0 )
           or nvl(x_net_weight, 0) <> nvl(l_gross_weight,0)) THEN
            l_detail_tab(1) := p_delivery_detail_id;
            WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
	     p_entity_type => 'DELIVERY_DETAIL',
	     p_entity_ids   => l_detail_tab,
	     x_return_status => l_return_status);
	    IF l_debug_on THEN
	     WSH_DEBUG_SV.log(l_module_name,'Mark_Reprice_Required l_return_status',l_return_status);
	    END IF;
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	     raise mark_reprice_error;
            END IF;
         END IF;
         -- end of bug 3711017

         -- OTM R12 : packing ECO
         -- after update wsh_delivery_details sql
         -- if any weight/vol changed, mark the global variable
         IF (G_DELIVERY_TMS_IMPACT = 'N' AND
             (NVL(l_net_weight, -1) <> NVL(x_net_weight, -1) OR
              NVL(l_volume, -1) <> NVL(x_volume, -1) OR
              NVL(l_dd_wt_code, '@@') <>
              NVL(l_dd_wt_code, NVL(l_item_wt_code, '@@')) OR
              NVL(l_gross_weight, -1) <> NVL(x_net_weight, -1) OR
              NVL(l_dd_vol_code, '@@') <>
              NVL(l_dd_vol_code, NVL(l_item_vol_code, '@@')))) THEN
           G_DELIVERY_TMS_IMPACT := 'Y';

	   IF l_debug_on THEN
	     WSH_DEBUG_SV.log(l_module_name,'G_DELIVERY_TMS_IMPACT', G_DELIVERY_TMS_IMPACT);
	   END IF;
         END IF;
         -- End of OTM R12 : packing ECO
      END IF; -- p_update_flag


      -- LPN CONV. rv
      IF (l_num_warnings > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        --
      ELSE
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        --
      END IF;
      -- LPN CONV. rv

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_net_weight '||x_net_weight||' x_volume '||x_volume||' x_return_status '||x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

EXCEPTION

  WHEN mark_reprice_error then

   FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
   x_return_status := l_return_status;
   WSH_UTIL_CORE.add_message (x_return_status);
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
   END IF;


   WHEN others THEN

      wsh_util_core.default_handler ('WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END Detail_Weight_Volume;

-- J: W/V changes

-- Start of comments
-- API name : Adjust_parent_WV
-- Type     : Private
-- Pre-reqs : None.
-- Function : Adjusts W/V on parent(container, delivery, stop) recursively
-- Parameters :
-- IN:
--    p_entity_type   IN VARCHAR2 Required
--      Valid values are  STOP, DELIVERY, CONTAINER, DETAIL
--    p_entity_id     IN VARCHAR2 Required
--      Id of the p_entity_type
--    p_gross_weight  IN NUMBER
--      Gross weight to be adjusted on p_entity_id
--    p_net_weight    IN NUMBER
--      Net weight to be adjusted on p_entity_id
--    p_volume        IN NUMBER
--      Volume to be adjusted on p_entity_id
--    p_filled_volume IN NUMBER
--      Filled Volume to be adjusted on p_entity_id
--    p_wt_uom_code   IN VARCHAR2
--      Wt UOM code of the Weight
--    p_vol_uom_code  IN VARCHAR2
--      Vol UOM code of the Volume
--    p_inv_item_id  IN VARCHAR2
--      Item Id of the child entity
-- OUT:
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Adjust_parent_WV (
              p_entity_type             IN VARCHAR2,
              p_entity_id               IN NUMBER,
              p_gross_weight            IN NUMBER,
              p_net_weight              IN NUMBER,
              p_volume                  IN NUMBER DEFAULT null,
              p_filled_volume           IN NUMBER DEFAULT null,
              p_wt_uom_code             IN VARCHAR2,
              p_vol_uom_code            IN VARCHAR2,
              p_inv_item_id             IN NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2,
              p_stop_type               IN VARCHAR2 DEFAULT NULL)
IS


  -- MDC: Update the stop wt/vol for delivery only
  --      if the delivery is directly attached to
  --      the delivery_leg.

  CURSOR trip_info IS
  SELECT wts.trip_id,
         wdl.pick_up_stop_id,
         wdl.drop_off_stop_id,
         wdl.parent_delivery_leg_id
  FROM   wsh_trip_stops wts,
         wsh_delivery_legs wdl
  WHERE  wdl.delivery_id = p_entity_id
  AND    wdl.pick_up_stop_id = wts.stop_id;

  CURSOR c_stops(c_trip_id IN NUMBER, c_pkup_stop_id IN NUMBER, c_dpoff_stop_id IN NUMBER) IS
  SELECT wts.stop_id,
         wts.departure_gross_weight,
         wts.departure_net_weight,
         wts.departure_volume
  FROM   wsh_trip_stops wts
  WHERE  wts.trip_id = c_trip_id
  AND    wts.stop_sequence_number < (
           select wts1.stop_sequence_number
           from   wsh_trip_stops wts1
           where  wts1.stop_id = c_dpoff_stop_id)
  AND    wts.stop_sequence_number >= (
           select wts2.stop_sequence_number
           from   wsh_trip_stops wts2
           where  wts2.stop_id = c_pkup_stop_id)
  FOR    UPDATE NOWAIT -- BugFix 3570954 Added NOWAIT
  ORDER  BY wts.stop_id, wts.planned_departure_date ASC;

  -- MDC: Update the parent delivery's wt/vol
  --      when updating the child wt/vol

  CURSOR c_consol_delivery(p_delivery_leg_id IN NUMBER) IS
  SELECT delivery_id
  FROM wsh_delivery_legs
  WHERE delivery_leg_id = p_delivery_leg_id;


  -- BugFix 3570954
  -- Added lock_detected exception
  lock_detected	EXCEPTION;
  PRAGMA EXCEPTION_INIT( lock_detected, -00054);

l_debug_on              BOOLEAN;
l_module_name CONSTANT  VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ADJUST_PARENT_WV';
l_gross_weight          number;
l_net_weight            number;
l_volume                number;
l_wt_uom_code           VARCHAR2(3);
l_vol_uom_code          VARCHAR2(3);
l_status_code           VARCHAR2(2);
l_shipment_type_flag    VARCHAR2(1);
l_shipment_direction    wsh_new_deliveries.shipment_direction%TYPE;
l_frozen_flag           VARCHAR2(1);
l_inv_item_id           number;
l_org_gross_wt          number;
l_org_net_wt            number;
l_org_vol               number;
l_org_fill_vol          number;
l_filled_volume         number;
l_container_id          number;
l_delivery_id           number;
l_return_status         VARCHAR2(100);
l_num_warnings          number;
l_cont_fill_pc          number;
l_fill_percent          number;

-- MDC
l_parent_delivery_id    number;
l_wda_type              VARCHAR2(30);

e_wt_mismatch           exception;
e_abort                 exception;
e_wt_vol_fail           exception;
record_locked           exception;
PRAGMA EXCEPTION_INIT(record_locked, -54);

--Bugfix 4070732
l_num_errors            NUMBER;
l_entity_id             NUMBER;
l_container_flag        VARCHAR2(10);
l_organization_id       NUMBER;
l_wms_org               VARCHAR2(10) := 'N';

--R12 MDC
l_pick_up_weight  number;
l_pick_up_volume number;
l_drop_off_weight number;
l_drop_off_volume number;
l_line_direction VARCHAR2(10);
l_update_wms_org            varchar2(10) := 'N';


BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_entity_type',p_entity_type);
    WSH_DEBUG_SV.log(l_module_name,'p_entity_id',p_entity_id);
    WSH_DEBUG_SV.log(l_module_name,'p_gross_weight',p_gross_weight);
    WSH_DEBUG_SV.log(l_module_name,'p_net_weight',p_net_weight);
    WSH_DEBUG_SV.log(l_module_name,'p_volume',p_volume);
    WSH_DEBUG_SV.log(l_module_name,'p_filled_volume',p_filled_volume);
    WSH_DEBUG_SV.log(l_module_name,'p_wt_uom_code',p_wt_uom_code);
    WSH_DEBUG_SV.log(l_module_name,'p_vol_uom_code',p_vol_uom_code);
    WSH_DEBUG_SV.log(l_module_name,'p_inv_item_id',p_inv_item_id);
    WSH_DEBUG_SV.log(l_module_name,'p_stop_type',p_stop_type);
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_num_errors := 0;
  l_num_warnings := 0;

  -- Check if the values of input W/V are > 0
  -- IF ((NVL(p_gross_weight,0) <> 0) OR (NVL(p_net_weight,0) <> 0) OR (NVL(p_volume,0) <> 0) OR
  --    (p_entity_type in ('CONTAINER','DETAIL') AND NVL(p_filled_volume,0) <> 0)) THEN

    --  For Stop
    IF (p_entity_type = 'STOP') THEN

      -- Get the orginal W/V info of the stop
      BEGIN
        SELECT departure_gross_weight,
               departure_net_weight,
               departure_volume,
               weight_uom_code,
               volume_uom_code,
               status_code,
               NVL(shipments_type_flag,'O'),
               NVL(wv_frozen_flag,'Y'),
               pick_up_weight,
               pick_up_volume,
               drop_off_weight,
               drop_off_volume
        INTO   l_gross_weight,
               l_net_weight,
               l_volume,
               l_wt_uom_code,
               l_vol_uom_code,
               l_status_code,
               l_shipment_type_flag,
               l_frozen_flag,
               l_pick_up_weight,
               l_pick_up_volume,
               l_drop_off_weight,
               l_drop_off_volume
        FROM   wsh_trip_stops
        WHERE  stop_id = p_entity_id
        FOR UPDATE NOWAIT;
      EXCEPTION
        WHEN record_locked THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Error: '||p_entity_type||' Id '||p_entity_id||'could not be locked');
          END IF;
          raise e_abort;
      END;


      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,p_entity_type||' has Gross '||l_gross_weight||' Net '||l_net_weight||' Vol '||l_volume||' Wt-Uom '||l_wt_uom_code||' Vol-Uom '||l_vol_uom_code ||' Status '||l_status_code||' Frozen '||l_frozen_flag);
      END IF;

      IF (NVL(l_shipment_type_flag, ' ') = 'O' AND NVL(l_status_code , ' ') in ('IT','CL'))
      OR (l_frozen_flag = 'Y' and p_stop_type NOT IN ('PICKUP','DROPOFF')) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'W/V propogation not allowed');
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;

        return;
      END IF;

      -- If the W/V UOM on stop and the input differ then convert the input W/V to the stop UOMs
      IF (l_wt_uom_code <> p_wt_uom_code) THEN
        l_org_gross_wt := convert_uom(p_wt_uom_code, l_wt_uom_code, NVL(p_gross_weight,0), p_inv_item_id);
        l_org_net_wt   := convert_uom(p_wt_uom_code, l_wt_uom_code, NVL(p_net_weight,0), p_inv_item_id);
      ELSE
        l_org_gross_wt := p_gross_weight;
        l_org_net_wt   := p_net_weight;
      END IF;

      IF (l_vol_uom_code <> p_vol_uom_code) THEN
        l_org_vol := convert_uom(p_vol_uom_code, l_vol_uom_code, NVL(p_volume,0), p_inv_item_id);
      ELSE
        l_org_vol := p_volume;
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Parameter Values after UOM conversions are Gross '||l_org_gross_wt||' Net '||l_org_net_wt||' Vol '||l_org_vol);
      END IF;

      -- Sum up the input W/V and Stop's original W/V
      IF NOT (l_gross_weight IS NULL and l_org_gross_wt IS NULL) THEN
        l_gross_weight := GREATEST(nvl(l_gross_weight,0) + nvl(l_org_gross_wt,0),0);
      END IF;
      IF NOT (l_net_weight IS NULL and l_org_net_wt IS NULL) THEN
        l_net_weight := GREATEST(nvl(l_net_weight,0) + nvl(l_org_net_wt,0),0);
      END IF;
      IF NOT (l_volume IS NULL and l_org_vol IS NULL) THEN
        l_volume := GREATEST(nvl(l_volume,0) + nvl(l_org_vol,0),0);
      END IF;
      IF (nvl(l_gross_weight,0) < nvl(l_net_weight,0)) THEN
        -- raise e_wt_mismatch;
        l_gross_weight := l_net_weight;
      END IF;

      --R12 MDC
      If p_stop_type = 'PICKUP' Then

         -- Add the input (converted UOM if necessary)gross weight to l_pick_up_weight
         IF NOT (l_pick_up_weight IS NULL and l_org_gross_wt IS NULL) THEN
            l_pick_up_weight := GREATEST(nvl(l_pick_up_weight,0) + nvl(l_org_gross_wt,0),0);
         END IF;

        --Add the input (converted UOM if necessary)volume  to l_pick_up_volume
        IF NOT (l_pick_up_volume IS NULL and l_org_vol IS NULL) THEN
           l_pick_up_volume := GREATEST(nvl(l_pick_up_volume,0) + nvl(l_org_vol,0),0);
        END IF;

     Elsif p_stop_type = 'DROPOFF' Then

       --Add the input (converted UOM if necessary)gross weight to l_drop_off_weight
       IF NOT (l_drop_off_weight IS NULL and l_org_gross_wt IS NULL) THEN
	 l_drop_off_weight := GREATEST(nvl(l_drop_off_weight,0) + nvl(l_org_gross_wt ,0),0);
       END IF;

       --Add the input (converted UOM if necessary)gross weight to l_drop_off_volume
       IF NOT (l_drop_off_volume IS NULL and l_org_vol IS NULL) THEN
         l_drop_off_volume := GREATEST(nvl(l_drop_off_volume,0) + nvl(l_org_vol,0),0);
       END IF;
     END IF;

      -- Calculate Stop fill%
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.Stop_Fill_Percent',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      WSH_TRIPS_ACTIONS.Calc_Stop_Fill_Percent(
        p_stop_id           => p_entity_id,
        p_gross_weight      => l_gross_weight,
        p_volume            => l_volume,
        x_stop_fill_percent => l_fill_percent,
        x_return_status     => l_return_status);

      IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;

      IF WSH_UTIL_CORE.FTE_IS_INSTALLED = 'Y' THEN
        --Bugfix 4070732
        IF WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API THEN --{

           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.Fte_Load_Tender',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           WSH_TRIPS_ACTIONS.Fte_Load_Tender(
              p_stop_id       => p_entity_id,
              p_gross_weight  => l_gross_weight,
              p_net_weight    => l_net_weight,
              p_volume        => l_volume,
              p_fill_percent  => l_fill_percent,
              x_return_status => l_return_status);

           IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
             IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             RETURN;
           END IF;

        ELSE --{ }

          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

	  l_entity_id := p_entity_id;
	  wsh_util_core.get_cached_value
             (
              p_cache_tbl         => WSH_UTIL_CORE.G_STOP_IDS_STOP_IDS_CACHE,
              p_cache_ext_tbl     => WSH_UTIL_CORE.G_STOP_IDS_STOP_IDS_EXT_CACHE,
              p_key               => l_entity_id,
              p_value             => l_entity_id,
              p_action            => 'PUT',
              x_return_status     => l_return_status
             );

	  IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );

        END IF; -- }

      END IF;

      -- Update the new W/V on the stop
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Updating '||p_entity_id||' with Gross '||l_gross_weight||' Net '||l_net_weight||' Vol '||l_volume);
        WSH_DEBUG_SV.logmsg(l_module_name,'l_frozen_flag '||l_frozen_flag||'p_stop_type '||p_stop_type);
      END IF;
      --R12 MDC
      --Included update for new wt/vol columns
      IF p_stop_type = 'DROPOFF' THEN
         update wsh_trip_stops
         set    last_update_date  = SYSDATE,
                last_updated_by   = FND_GLOBAL.user_id,
                last_update_login = FND_GLOBAL.login_id,
                drop_off_weight = l_drop_off_weight,
                drop_off_volume = l_drop_off_volume
         where  stop_id = p_entity_id;

      ELSIF l_frozen_flag = 'Y' AND p_stop_type = 'PICKUP' THEN
         update wsh_trip_stops
         set    last_update_date  = SYSDATE,
                last_updated_by   = FND_GLOBAL.user_id,
                last_update_login = FND_GLOBAL.login_id,
                pick_up_weight = l_pick_up_weight,
                pick_up_volume = l_pick_up_volume
         where  stop_id = p_entity_id;
      ELSIF NVL(l_frozen_flag, 'N') = 'N' THEN
         IF  p_stop_type = 'PICKUP' THEN
             update wsh_trip_stops
             set    departure_gross_weight = l_gross_weight,
                    departure_net_weight   = l_net_weight,
                    departure_volume       = l_volume,
                    departure_fill_percent = l_fill_percent,
                    last_update_date  = SYSDATE,
                    last_updated_by   = FND_GLOBAL.user_id,
                    last_update_login = FND_GLOBAL.login_id,
                    pick_up_weight = l_pick_up_weight,
                    pick_up_volume = l_pick_up_volume
             where  stop_id = p_entity_id;
         ELSE
             update wsh_trip_stops
             set    departure_gross_weight = l_gross_weight,
                    departure_net_weight   = l_net_weight,
                    departure_volume       = l_volume,
                    departure_fill_percent = l_fill_percent,
                    last_update_date  = SYSDATE,
                    last_updated_by   = FND_GLOBAL.user_id,
                    last_update_login = FND_GLOBAL.login_id
             where  stop_id = p_entity_id;
         END IF;
      END IF;



    -- For Delivery
    ELSIF (p_entity_type in ('DELIVERY')) THEN

      -- Get the orginal W/V info of the delivery
      BEGIN
        SELECT gross_weight,
               net_weight,
               volume,
               weight_uom_code,
               volume_uom_code,
               status_code,
               NVL(shipment_direction,'O'),
               NVL(wv_frozen_flag,'Y')
        INTO   l_gross_weight,
               l_net_weight,
               l_volume,
               l_wt_uom_code,
               l_vol_uom_code,
               l_status_code,
               l_shipment_direction,
               l_frozen_flag
        FROM   wsh_new_deliveries
        WHERE  delivery_id = p_entity_id
	AND    NVL(wv_frozen_flag, 'Y') <> 'Y' -- BugFix 3570954
        FOR UPDATE NOWAIT;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name, p_entity_type||' Id '||p_entity_id||'has wv_frozen_flag Y');
          END IF;
          l_frozen_flag := 'Y';
        WHEN record_locked THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Error: '||p_entity_type||' Id '||p_entity_id||' could not be locked');
          END IF;
          --Bug8513181
          FND_MESSAGE.SET_NAME('WSH', 'WSH_UI_NOT_PERFORMED');
          x_return_status := wsh_util_core.g_ret_sts_error;
          wsh_util_core.add_message(x_return_status,l_module_name);
          IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name, 'WSH_UI_NOT_PERFORMED');
          END IF;
          --Bug8513181
          raise e_abort;
      END;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,p_entity_type||' has Gross '||l_gross_weight||' Net '||l_net_weight||' Vol '||l_volume||' Wt-Uom '||l_wt_uom_code||' Vol-Uom '||l_vol_uom_code||' Status '||l_status_code||' Frozen '||l_frozen_flag);
      END IF;

      IF (NVL(l_shipment_direction, ' ') in ('O','IO') AND NVL(l_status_code, ' ') IN ('IT','CL','SR')) OR l_frozen_flag = 'Y' THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'W/V propogation not allowed');
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;

        return;
      END IF;

      -- If the W/V UOM on delivery and the input differ then convert the input W/V to the delivery UOMs
      IF (l_wt_uom_code <> p_wt_uom_code) THEN
        l_org_gross_wt := convert_uom(p_wt_uom_code, l_wt_uom_code, NVL(p_gross_weight,0), p_inv_item_id);
        l_org_net_wt   := convert_uom(p_wt_uom_code, l_wt_uom_code, NVL(p_net_weight,0), p_inv_item_id);
      ELSE
        l_org_gross_wt := p_gross_weight;
        l_org_net_wt   := p_net_weight;
      END IF;

      IF (l_vol_uom_code <> p_vol_uom_code) THEN
        l_org_vol := convert_uom(p_vol_uom_code, l_vol_uom_code, NVL(p_volume,0), p_inv_item_id);
      ELSE
        l_org_vol := p_volume;
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Parameter Values after UOM conversions are Gross '||l_org_gross_wt||' Net '||l_org_net_wt||' Vol '||l_org_vol);
      END IF;

      -- -- Sum up the input W/V and Delivery's original W/V
      IF NOT (l_gross_weight IS NULL and l_org_gross_wt IS NULL) THEN
        l_gross_weight := GREATEST(nvl(l_gross_weight,0) + nvl(l_org_gross_wt,0),0);
      END IF;
      IF NOT (l_net_weight IS NULL and l_org_net_wt IS NULL) THEN
        l_net_weight := GREATEST(nvl(l_net_weight,0) + nvl(l_org_net_wt,0),0);
      END IF;
      IF NOT (l_volume IS NULL and l_org_vol IS NULL) THEN
        l_volume := GREATEST(nvl(l_volume,0) + nvl(l_org_vol,0),0);
      END IF;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Gross '||l_gross_weight||' Net '||l_net_weight||' Vol '||l_volume);
      END IF;
      IF (nvl(l_gross_weight,0) < nvl(l_net_weight,0)) THEN
        -- raise e_wt_mismatch;
        l_gross_weight := l_net_weight;
      END IF;

      -- Update the new W/V on the delivery
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Updating '||p_entity_id||' with Gross '||l_gross_weight||' Net '||l_net_weight||' Vol '||l_volume);
      END IF;
      update wsh_new_deliveries
      set    gross_weight = l_gross_weight,
             net_weight   = l_net_weight,
             volume       = l_volume,
             last_update_date  = SYSDATE,
             last_updated_by   = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
      where  delivery_id = p_entity_id;

      -- Call Adjust_parent_WV recursively to adjust W/V on parent stops, if any
      --

      FOR crec in trip_info LOOP
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Processing Trip '||crec.trip_id||' Pickup '||crec.pick_up_stop_id||' Drop off '||crec.drop_off_stop_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Processing Trip '||crec.trip_id|| 'parent_delivery_leg'||crec.parent_delivery_leg_id);
          END IF;

          IF (crec.parent_delivery_leg_id is not NULL) THEN

             -- MDC: This delivery is assigned to a parent. Update its parents wv
             -- The stop wv would get updated when the parent wv gets updated.
             -- If p_entity_type = 'DELIVERY_NO_RECURSE' this delivery is assigned to a
             -- parent LPN and Delivery. Parent delivery and trip/stops will get updated
             -- when the parent LPN's weight volume gets updated.

             IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Parent Delivery Leg '||crec.parent_delivery_leg_id);
             END IF;
             OPEN c_consol_delivery(crec.parent_delivery_leg_id);
             FETCH c_consol_delivery INTO l_parent_delivery_id;
             CLOSE c_consol_delivery;

             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Parent Delivery '||l_parent_delivery_id);
             END IF;

             Adjust_parent_WV(
               p_entity_type   => 'DELIVERY',
               p_entity_id     => l_parent_delivery_id,
               p_gross_weight  => p_gross_weight,
               p_net_weight    => p_net_weight,
               p_volume        => p_volume,
               p_wt_uom_code   => p_wt_uom_code,
               p_vol_uom_code  => p_vol_uom_code,
               p_inv_item_id   => NULL,
               x_return_status => l_return_status);

              IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Adjust_parent_WV has returned Error for delivery '||l_parent_delivery_id);
                END IF;
                raise e_abort;
              END IF;

          ELSE
          -- Update the stop wt/vol

            FOR crec1 in c_stops(crec.trip_id, crec.pick_up_stop_id, crec.drop_off_stop_id) LOOP
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Processing Stop '||crec1.stop_id);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Adjust_parent_WV',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              Adjust_parent_WV(
                p_entity_type   => 'STOP',
                p_entity_id     => crec1.stop_id,
                p_gross_weight  => p_gross_weight,
                p_net_weight    => p_net_weight,
                p_volume        => p_volume,
                p_wt_uom_code   => p_wt_uom_code,
                p_vol_uom_code  => p_vol_uom_code,
                p_inv_item_id   => null,
                x_return_status => l_return_status);

              IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Adjust_parent_WV has returned Error for Stop '||crec1.stop_id);
                END IF;
                raise e_abort;
              END IF;
            END LOOP;

          END IF;
      END LOOP;
      --END IF; -- p_entity_type

    -- For Container or Delivery Detail
    ELSIF (p_entity_type IN ('CONTAINER', 'DETAIL'))THEN

      -- Get the orginal W/V info
      BEGIN
        SELECT gross_weight,
               net_weight,
               volume,
               filled_volume,
               parent_delivery_detail_id,
               delivery_id,
               wdd.weight_uom_code,
               wdd.volume_uom_code,
               wdd.inventory_item_id,
               wdd.container_flag,
               wdd.organization_id,
               nvl(wdd.wv_frozen_flag,'Y'),
               NVL(wda.type, 'S'),
               wdd.line_direction
        INTO   l_gross_weight,
               l_net_weight,
               l_volume,
               l_filled_volume,
               l_container_id,
               l_delivery_id,
               l_wt_uom_code,
               l_vol_uom_code,
               l_inv_item_id,
               --lpn conv
               l_container_flag,
               l_organization_id,
               l_frozen_flag,
               -- MDC
               l_wda_type,
               l_line_direction
        FROM   wsh_delivery_details wdd,
               wsh_delivery_assignments wda
        WHERE  wdd.delivery_detail_id = p_entity_id
        AND    wdd.delivery_detail_id = wda.delivery_detail_id
        AND    NVL(wda.type, 'S') in ('S', 'C')
        FOR UPDATE NOWAIT;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Error: '||p_entity_type||' Id '||p_entity_id||'doesn not exist');
          END IF;
          raise e_abort;
        WHEN record_locked THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Error: '||p_entity_type||' Id '||p_entity_id||'could not be locked');
          END IF;
          raise e_abort;
      END;

      --lpn conv
      IF l_container_flag IN ('Y', 'C')  THEN
         l_wms_org := wsh_util_validate.check_wms_org(l_organization_id);
         IF l_wms_org = 'Y'  THEN
            l_frozen_flag := 'N';
         END IF;
      END IF;


      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,p_entity_type||' has Gross '||l_gross_weight||' Net '||l_net_weight||' Vol '||l_volume||' Fill-Vol '||l_filled_volume||' Wt-Uom '||l_wt_uom_code||' Vol-Uom '||l_vol_uom_code||' Frozen '||l_frozen_flag);
      END IF;

      IF l_frozen_flag = 'Y' THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'W/V propogation not allowed');
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        return;
      END IF;

      -- If the W/V UOM on DD and the input differ then convert the input W/V to the DD UOMs
      IF (l_wt_uom_code <> p_wt_uom_code) THEN
        l_org_gross_wt := convert_uom(p_wt_uom_code, l_wt_uom_code, NVL(p_gross_weight,0), p_inv_item_id);
        l_org_net_wt   := convert_uom(p_wt_uom_code, l_wt_uom_code, NVL(p_net_weight,0), p_inv_item_id);
      ELSE
        l_org_gross_wt := p_gross_weight;
        l_org_net_wt   := p_net_weight;
      END IF;

      IF (l_vol_uom_code <> p_vol_uom_code) THEN
        l_org_vol := convert_uom(p_vol_uom_code, l_vol_uom_code, NVL(p_volume,0), p_inv_item_id);
        l_org_fill_vol := convert_uom(p_vol_uom_code, l_vol_uom_code, NVL(p_filled_volume,0), p_inv_item_id);
      ELSE
        l_org_vol := p_volume;
        l_org_fill_vol := p_filled_volume;
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Parameter Values after UOM conversions are Gross '||l_org_gross_wt||' Net '||l_org_net_wt||' Vol '||l_org_vol);
      END IF;

       -- Sum up the input W/V and DD's original W/V
      IF NOT (l_gross_weight IS NULL and l_org_gross_wt IS NULL) THEN
        l_gross_weight := GREATEST(nvl(l_gross_weight,0) + nvl(l_org_gross_wt,0),0);
      END IF;
      IF NOT (l_net_weight IS NULL and l_org_net_wt IS NULL) THEN
        l_net_weight := GREATEST(nvl(l_net_weight,0) + nvl(l_org_net_wt,0),0);
        IF l_net_weight = 0 THEN
          l_net_weight := NULL;
        END IF;
      END IF;
      IF NOT (l_filled_volume IS NULL and l_org_fill_vol IS NULL) THEN
        l_filled_volume := GREATEST(nvl(l_filled_volume,0) + nvl(l_org_fill_vol,0),0);
      END IF;
      IF NOT (l_volume IS NULL and l_org_vol IS NULL) THEN
        l_volume := GREATEST(nvl(l_volume,0) + nvl(l_org_vol,0),0);
      END IF;
      IF (nvl(l_gross_weight,0) < nvl(l_net_weight,0)) THEN
        -- raise e_wt_mismatch;
        l_gross_weight := l_net_weight;
      END IF;

      -- Call update_container_wt_vol to update new W/V on container
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit UPDATE_CONTAINER_WT_VOL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      update_container_wt_vol(
        p_container_instance_id =>   p_entity_id,
        p_gross_weight  => l_gross_weight,
        p_net_weight    => l_net_weight,
        p_volume        => l_volume,
        p_filled_volume => l_filled_volume,
        p_fill_pc_flag  => 'Y',
        x_cont_fill_pc  => l_cont_fill_pc,
        x_return_status => l_return_status);

      IF l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          RAISE e_wt_vol_fail;
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_num_warnings := l_num_warnings + 1;
      END IF;

      -- Call Adjust_parent_WV recursively to adjust W/V on parent container/delivery, if any
      IF ((l_container_id IS NOT NULL)) THEN
    --lpn conv

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_wms_org',l_wms_org);
        END IF;
        IF l_wms_org = 'Y' THEN --{

           IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
            AND l_line_direction IN ('O', 'IO') THEN

              IF ( WSH_WMS_LPN_GRP.GK_WMS_UPD_WV) THEN --{
                 WSH_WMS_LPN_GRP.g_update_to_containers := 'Y';
              END IF; --}
           END IF;

        ELSE --}{
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,p_entity_type||' '||p_entity_id||' has parent container '||l_container_id);
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Adjust_parent_WV',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           Adjust_parent_WV(
             p_entity_type   => 'CONTAINER',
             p_entity_id     => l_container_id,
             p_gross_weight  => p_gross_weight,
             p_net_weight    => p_net_weight,
             p_volume        => p_volume,
             p_filled_volume => p_filled_volume,
             p_wt_uom_code   => p_wt_uom_code,
             p_vol_uom_code  => p_vol_uom_code,
             p_inv_item_id   => l_inv_item_id,
             x_return_status => l_return_status);

           IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Adjust_parent_WV has returned Error for Container '||l_container_id);
             END IF;
             raise e_abort;
           END IF;
         END IF; --}

         -- R12: MDC we need to make sure that the child deliveries get updated as well
         IF l_wda_type = 'C' THEN
            g_consol_lpn := l_container_id;

            Adjust_parent_WV(
             p_entity_type   => 'DELIVERY',
             p_entity_id     => l_delivery_id,
             p_gross_weight  => p_gross_weight,
             p_net_weight    => p_net_weight,
             p_volume        => p_volume,
             p_wt_uom_code   => p_wt_uom_code,
             p_vol_uom_code  => p_vol_uom_code,
             p_inv_item_id   => l_inv_item_id,
             x_return_status => l_return_status);
           IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Adjust_parent_WV has returned Error for Delivery '||l_delivery_id);
             END IF;
             raise e_abort;
           END IF;

         END IF;


      ELSIF (l_delivery_id IS NOT NULL) AND (l_container_flag <> 'C') THEN
        -- MDC: Do not propagate wt/vol to the consol delivery through the
        -- consol LPN since the wt/vols to the consol delivery will be propagated
        -- through the child delivery.

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,p_entity_type||' '||p_entity_id||' is in delivery '||l_delivery_id);
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Adjust_parent_WV',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;


        Adjust_parent_WV(
             p_entity_type   => 'DELIVERY',
             p_entity_id     => l_delivery_id,
             p_gross_weight  => p_gross_weight,
             p_net_weight    => p_net_weight,
             p_volume        => p_volume,
             p_wt_uom_code   => p_wt_uom_code,
             p_vol_uom_code  => p_vol_uom_code,
             p_inv_item_id   => l_inv_item_id,
             x_return_status => l_return_status);
        IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Adjust_parent_WV has returned Error for Delivery '||l_delivery_id);
           END IF;
           raise e_abort;
        END IF;

      END IF;
    END IF;
  --END IF;
  IF l_num_warnings > 0 THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_return_status '||x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN  e_wt_vol_fail THEN
    FND_MESSAGE.Set_Name('WSH','WSH_UPDATE_WTVOL_FAIL');
    FND_MESSAGE.Set_Token('LPN', p_entity_id);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.add_message (x_return_status);
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'E_WT_VOL_FAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_WT_VOL_FAIL');
   END IF;

  WHEN e_abort THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  WHEN e_wt_mismatch THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Error: Adjusted Net Weight is greater than Adjusted Gross Weight');
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  WHEN lock_detected THEN -- BugFix 3570954
      FND_MESSAGE.SET_NAME('WSH','WSH_NO_LOCK');
      x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
      wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Cannot lock delivery for update',l_delivery_id);
      END IF;

 WHEN Others THEN
    WSH_UTIL_CORE.Default_Handler ('WSH_WV_UTILS.Adjust_parent_WV');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
End Adjust_parent_WV;

-- J: W/V Changes

-- Start of comments
-- API name : DD_WV_Post_Process
-- Type     : Public
-- Pre-reqs : None.
-- Function : API to do post processing(Log exceptions in manual mode and
--            adjust W/V on parents in automatic mode)  for a delivery detail or container
-- Parameters :
-- IN:
--    p_delivery_detail_id IN NUMBER Required
--    p_diff_gross_wt      IN NUMBER
--      Gross Wt that needs to be adjusted on parent entities
--    p_diff_net_wt        IN NUMBER
--      Net Wt that needs to be adjusted on parent entities
--    p_diff_volume        IN NUMBER
--      Volume that needs to be adjusted on parent entities
--    p_diff_fill_volume   IN NUMBER
--      Filled Volume that needs to be adjusted on parent entities
--    p_check_for_empty    IN VARCHAR2
--      Check if the parent of p_delivery_detail_id becomes empty
--      without p_delivery_detail_id
-- OUT:
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE DD_WV_Post_Process(
            p_delivery_detail_id    IN NUMBER,
            p_diff_gross_wt         IN NUMBER,
            p_diff_net_wt           IN NUMBER,
            p_diff_volume           IN NUMBER   DEFAULT null,
            p_diff_fill_volume      IN NUMBER   DEFAULT null,
            p_check_for_empty       IN VARCHAR2 DEFAULT 'N',
            x_return_status         OUT NOCOPY VARCHAR2) IS

  CURSOR C1 IS
  SELECT wda.parent_delivery_detail_id,
         wda.delivery_id,
         wdd.organization_id,
         wdd.container_flag,
         wdd.weight_uom_code,
         wdd.volume_uom_code,
         wdd.inventory_item_id,
--lpn conv
         wdd.line_direction,
-- MDC
         NVL(wda.type, 'S')
  FROM   wsh_delivery_assignments wda,
         wsh_delivery_details wdd
  WHERE  wdd.delivery_detail_id = p_delivery_detail_id
  AND    NVL(wda.type, 'S') in ('S', 'C')
  AND    wdd.delivery_detail_id = wda.delivery_detail_id;

  CURSOR C2(c_container_id IN NUMBER) IS
  SELECT wda.delivery_detail_id
  FROM   wsh_delivery_assignments_v wda
  WHERE  wda.parent_delivery_detail_id = c_container_id
  AND    wda.delivery_detail_id <> p_delivery_detail_id;

  CURSOR C3(c_delivery_id IN NUMBER) IS
  SELECT wda.delivery_detail_id
  FROM   wsh_delivery_assignments_v wda
  WHERE  wda.delivery_id = c_delivery_id
  AND    wda.delivery_detail_id <> p_delivery_detail_id;

  CURSOR C4(c_container_id IN NUMBER) IS
  SELECT unit_weight,
         unit_volume,
         gross_weight,
         net_weight,
         volume,
         filled_volume
  FROM   wsh_delivery_details
  WHERE  delivery_detail_id = c_container_id;

  CURSOR C5(c_delivery_id IN NUMBER) IS
  SELECT gross_weight,
         net_weight,
         volume
  FROM   wsh_new_deliveries
  WHERE  delivery_id = c_delivery_id
  FOR UPDATE NOWAIT; --BugFix 3570954;

  -- BugFix 3570954
  -- Added lock_detected exception
  lock_detected	EXCEPTION;
  PRAGMA EXCEPTION_INIT( lock_detected, -00054);

  l_parent_container_id       NUMBER;
  l_delivery_id               NUMBER;
  l_organization_id           NUMBER;
  l_container_flag            VARCHAR2(1);
  l_wt_uom_code               VARCHAR2(3);
  l_vol_uom_code              VARCHAR2(3);
  l_inv_item_id               number;
  -- MDC
  l_wda_type                  VARCHAR2(30);

  l_return_status             VARCHAR2(100);

  l_cont_empty                BOOLEAN;
  l_del_empty                 BOOLEAN;
  l_tmp_unit_wt               NUMBER;
  l_tmp_unit_vol              NUMBER;
  l_tmp_gross_wt              NUMBER;
  l_tmp_net_wt                NUMBER;
  l_tmp_vol                   NUMBER;
  l_tmp_fill_vol              NUMBER;
  l_tmp_fill_pc               NUMBER;
  l_dummy_id                  NUMBER;
  l_detail_count              NUMBER;
  l_debug_on                  BOOLEAN;
  l_module_name CONSTANT      VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DD_WV_POST_PROCESS';

  l_num_warnings          number := 0;
  l_num_errors            number := 0;
  l_update_wms_org            varchar2(10) := 'N';
  l_line_direction        varchar2(10) ;
  l_cont_fill_pc          NUMBER;
  l_item_id               NUMBER;

  cursor  c_get_item_id (v_delivery_detail_id number) IS
  SELECT inventory_item_id
  FROM wsh_delivery_details
  WHERE delivery_detail_id = v_delivery_detail_id;

  e_abort                     exception;


BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_delivery_detail_id',p_delivery_detail_id);
    WSH_DEBUG_SV.log(l_module_name,'p_diff_gross_wt',p_diff_gross_wt);
    WSH_DEBUG_SV.log(l_module_name,'p_diff_net_wt',p_diff_net_wt);
    WSH_DEBUG_SV.log(l_module_name,'p_diff_volume',p_diff_volume);
    WSH_DEBUG_SV.log(l_module_name,'p_diff_fill_volume',p_diff_fill_volume);
    WSH_DEBUG_SV.log(l_module_name,'p_check_for_empty',p_check_for_empty);
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Get the delivery detail information
  OPEN  C1;
  FETCH C1
  INTO  l_parent_container_id,
        l_delivery_id,
        l_organization_id,
        l_container_flag,
        l_wt_uom_code,
        l_vol_uom_code,
        l_inv_item_id,
        l_line_direction,
        l_wda_type;
  IF C1%NOTFOUND THEN
    CLOSE C1;
    RETURN;
  END IF;
  CLOSE C1;

  -- For Container
  IF ((l_parent_container_id IS NOT NULL)) THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'The parent container id is '||l_parent_container_id);
    END IF;

    --lpn conv
    IF l_container_flag IN ('Y', 'C') AND l_line_direction IN ('O', 'IO')  THEN
       l_update_wms_org := wsh_util_validate.Check_Wms_Org(l_organization_id);
    END IF;

    OPEN c_get_item_id(l_parent_container_id);
    FETCH c_get_item_id INTO l_item_id;
    CLOSE c_get_item_id;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_item_id',l_item_id);
    END IF;

    IF c_wms_code_present = 'Y'
     AND  l_update_wms_org = 'Y' THEN --{
        IF l_item_id IS NOT NULL THEN --{
           WSH_TPA_CONTAINER_PKG.Calc_Cont_Fill_Pc (
                 p_container_instance_id =>
                                   l_parent_container_id,
                 p_update_flag           => 'Y',
                 p_fill_pc_basis         => NULL,
                 x_fill_percent          => l_cont_fill_pc,
                 x_return_status         => l_return_status
           );
           wsh_util_core.api_post_call
           (
             p_return_status => l_return_status,
             x_num_warnings  => l_num_warnings,
             x_num_errors    => l_num_errors
           );
       END IF; --}
    ELSE --}{

       -- Check if container becomes empty without delivery detail
       l_cont_empty := FALSE;
       IF p_check_for_empty = 'Y' THEN
         OPEN  C2(l_parent_container_id);
         FETCH C2 INTO l_dummy_id;
         IF C2%NOTFOUND THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Container will become empty without this dd');
           END IF;
           l_cont_empty := TRUE;
         END IF;
         CLOSE C2;
       END IF;

       -- If container becomes empty then
       --   reset the W/V on container to unit w/v and call DD_WV_POST_PROCESS API for the container
       -- else
       --   call adjust_parent_wv for the delivery detail
       IF l_cont_empty THEN
         OPEN  C4(l_parent_container_id);
         FETCH C4
         INTO  l_tmp_unit_wt,
               l_tmp_unit_vol,
               l_tmp_gross_wt,
               l_tmp_net_wt,
               l_tmp_vol,
               l_tmp_fill_vol;
         CLOSE C4;

         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Update_Container_Wt_Vol',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         WSH_WV_UTILS.update_container_wt_vol(
           p_container_instance_id => l_parent_container_id,
           p_gross_weight  => l_tmp_unit_wt,
           p_net_weight    => null,
           p_volume        => l_tmp_unit_vol,
           p_filled_volume => null,
           p_fill_pc_flag  => 'Y',
           x_cont_fill_pc  => l_tmp_fill_pc,
           x_return_status => l_return_status);
         IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
         ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
           l_num_warnings := l_num_warnings + 1;
         END IF;

         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         DD_WV_Post_Process(
               p_delivery_detail_id => l_parent_container_id,
               p_diff_gross_wt      => NVL(l_tmp_unit_wt,0) - NVL(l_tmp_gross_wt,0),
               p_diff_net_wt        => -1 * NVL(l_tmp_net_wt,0),
               p_diff_volume        => NVL(l_tmp_unit_vol,0) - NVL(l_tmp_vol,0),
               p_diff_fill_volume   => NVL(l_tmp_unit_vol,0) - NVL(l_tmp_vol,0),
               x_return_status      => l_return_status);

       ELSE -- NOT l_cont_empty
         -- Call Adjust_parent_WV to adjust W/V
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.Adjust_parent_WV',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         Adjust_parent_WV(
           p_entity_type   => 'CONTAINER',
           p_entity_id     => l_parent_container_id,
           p_gross_weight  => p_diff_gross_wt,
           p_net_weight    => p_diff_net_wt,
           p_filled_volume => p_diff_fill_volume,
           p_wt_uom_code   => l_wt_uom_code,
           p_vol_uom_code  => l_vol_uom_code,
           p_inv_item_id   => l_inv_item_id,
           x_return_status => l_return_status);
       END IF;


       IF l_wda_type = 'C' THEN
       -- R12: MDC: if this detail is assigned to a consol LPN, then
       -- we need to update the child deliveries...

       Adjust_parent_WV(
          p_entity_type   => 'DELIVERY',
          p_entity_id     => l_delivery_id,
          p_gross_weight  => p_diff_gross_wt,
          p_net_weight    => p_diff_net_wt,
          p_volume        => p_diff_volume,
          p_wt_uom_code   => l_wt_uom_code,
          p_vol_uom_code  => l_vol_uom_code,
          p_inv_item_id   => l_inv_item_id,
          x_return_status => l_return_status);


       END IF;

     END IF; --}
  -- For Delivery
  ELSIF (l_delivery_id IS NOT NULL) THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'The Delivery id is '||l_delivery_id);
    END IF;

    -- Check if delivery becomes empty without delivery detail
    l_del_empty := FALSE;
    IF p_check_for_empty = 'Y' THEN
      OPEN  C3(l_delivery_id);
      FETCH C3 INTO l_dummy_id;
      IF C3%NOTFOUND THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Delivery will become empty without this dd');
        END IF;
        l_del_empty := TRUE;
      END IF;
      CLOSE C3;
    END IF;

    -- If delivery becomes empty then
    --   reset the W/V on delivery to null and call Del_WV_POST_PROCESS API for the delivery
    -- else
    --   call adjust_parent_wv for the delivery detail
    IF l_del_empty THEN
      OPEN  C5(l_delivery_id);
      FETCH C5
      INTO  l_tmp_gross_wt,
            l_tmp_net_wt,
            l_tmp_vol;

      UPDATE wsh_new_deliveries
      SET    gross_weight = null,
             net_weight   = null,
             volume       = null,
             wv_frozen_flag = 'N',
             last_update_date  = SYSDATE,
             last_updated_by   = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.login_id
      WHERE  delivery_id = l_delivery_id;

      CLOSE C5;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.Del_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      Del_WV_Post_Process(
            p_delivery_id   => l_delivery_id,
            p_diff_gross_wt => -1 * l_tmp_gross_wt,
            p_diff_net_wt   => -1 * l_tmp_net_wt,
            p_diff_volume   => -1 * l_tmp_vol,
            x_return_status => l_return_status);

      ELSE -- NOT l_del_empty

      -- Call Adjust_parent_WV to adjust W/V
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.Adjust_parent_WV',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      IF (l_container_flag = 'Y') OR ((l_container_flag = 'C')
      AND (NVL(g_consol_lpn, 0) <> p_delivery_detail_id)) THEN
        Adjust_parent_WV(
          p_entity_type   => 'DELIVERY',
          p_entity_id     => l_delivery_id,
          p_gross_weight  => p_diff_gross_wt,
          p_net_weight    => p_diff_net_wt,
          p_volume        => p_diff_volume,
          p_wt_uom_code   => l_wt_uom_code,
          p_vol_uom_code  => l_vol_uom_code,
          p_inv_item_id   => l_inv_item_id,
          x_return_status => l_return_status);
      ELSIF l_container_flag = 'N' THEN
        Adjust_parent_WV(
          p_entity_type   => 'DELIVERY',
          p_entity_id     => l_delivery_id,
          p_gross_weight  => p_diff_gross_wt,
          p_net_weight    => p_diff_net_wt,
          p_volume        => p_diff_fill_volume,
          p_wt_uom_code   => l_wt_uom_code,
          p_vol_uom_code  => l_vol_uom_code,
          p_inv_item_id   => l_inv_item_id,
          x_return_status => l_return_status);
      END IF;
      g_consol_lpn := NULL;

    END IF;
  END IF;
  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
     IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        x_return_status := l_return_status;
     ELSE
        x_return_status := l_return_status;
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'API returned '||l_return_status);
        END IF;
        raise e_abort;
     END IF;
  END IF;

  IF l_num_warnings > 0 THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status '||x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

   WHEN lock_detected THEN -- BugFix 3570954
      FND_MESSAGE.SET_NAME('WSH','WSH_NO_LOCK');
      x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
      wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Cannot lock delivery for update',l_delivery_id);
      END IF;

  WHEN e_abort THEN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;

  WHEN Others THEN
    WSH_UTIL_CORE.Default_Handler ('WSH_WV_UTILS.DD_WV_POST_PROCESS');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END DD_WV_Post_Process;

-- Start of comments
-- API name : Del_WV_Post_Process
-- Type     : Public
-- Pre-reqs : None.
-- Function : API to do post processing (adjust W/V on parents) for a delivery
-- Parameters :
-- IN:
--    p_delivery_id IN NUMBER Required
--    p_diff_gross_wt      IN NUMBER
--      Gross Wt that needs to be adjusted on parent entities
--    p_diff_net_wt        IN NUMBER
--      Net Wt that needs to be adjusted on parent entities
--    p_diff_volume        IN NUMBER
--      Volume that needs to be adjusted on parent entities
--    p_check_for_empty    IN VARCHAR2
--      Check if the parent of p_delivery_id becomes empty
--      without p_delivery_id
--    p_leg_id IN VARCHAR2
--      Do Post Processing only for the specified delivery/delivery leg
-- OUT:
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Del_WV_Post_Process(
            p_delivery_id     IN NUMBER,
            p_diff_gross_wt   IN NUMBER,
            p_diff_net_wt     IN NUMBER,
            p_diff_volume     IN NUMBER,
            p_check_for_empty IN VARCHAR2 DEFAULT 'N',
            p_leg_id          IN NUMBER DEFAULT NULL,
            x_return_status   OUT NOCOPY VARCHAR2) IS

  CURSOR c_stops(c_trip_id IN NUMBER, c_pkup_stop_id IN NUMBER, c_dpoff_stop_id IN NUMBER) IS
  SELECT wts.stop_id,
         wts.departure_gross_weight,
         wts.departure_net_weight,
         wts.departure_volume
  FROM   wsh_trip_stops wts
  WHERE  wts.trip_id = c_trip_id
  AND    wts.stop_sequence_number <= (
           select wts1.stop_sequence_number
           from   wsh_trip_stops wts1
           where  wts1.stop_id = c_dpoff_stop_id)
  AND    wts.stop_sequence_number >= (
           select wts2.stop_sequence_number
           from   wsh_trip_stops wts2
           where  wts2.stop_id = c_pkup_stop_id)
  FOR    UPDATE NOWAIT
  ORDER  BY wts.stop_id, wts.planned_departure_date ASC;

  -- BugFix 3570954
  -- Added lock_detected exception
  lock_detected	EXCEPTION;
  PRAGMA EXCEPTION_INIT( lock_detected, -00054);

  CURSOR trip_info IS
  SELECT wts.trip_id,
         wdl.pick_up_stop_id,
         wdl.drop_off_stop_id,
         wdl.parent_delivery_leg_id
  FROM   wsh_trip_stops wts,
         wsh_delivery_legs wdl
  WHERE  wdl.delivery_leg_id = p_leg_id
  AND    wdl.pick_up_stop_id = wts.stop_id
  AND    p_leg_id is not null
  UNION
  SELECT wts.trip_id,
         wdl.pick_up_stop_id,
         wdl.drop_off_stop_id,
         wdl.parent_delivery_leg_id
  FROM   wsh_trip_stops wts,
         wsh_delivery_legs wdl
  WHERE  wdl.delivery_id = p_delivery_id
  AND    wdl.pick_up_stop_id = wts.stop_id
  AND    p_leg_id is null;

  CURSOR C1(c_trip_id IN NUMBER) IS
  SELECT delivery_id
  FROM   wsh_delivery_legs wdl,
         wsh_trip_stops wts
  WHERE  wts.trip_id = c_trip_id
  AND    wdl.pick_up_stop_id = wts.stop_id
  AND    wdl.parent_delivery_leg_id is NULL
  AND    wdl.delivery_id <> p_delivery_id;

  CURSOR c_parent_delivery (p_delivery_leg_id IN NUMBER) IS
  SELECT delivery_id from wsh_delivery_legs
  WHERE  delivery_leg_id = p_delivery_leg_id;

  --R12 MDC
  CURSOR c_check_pickup(p_stop_id IN NUMBER) IS
  SELECT delivery_leg_id
  FROM wsh_delivery_legs wdl
  WHERE wdl.delivery_id = p_delivery_id
  AND wdl.pick_up_stop_id = p_stop_id;

  CURSOR c_check_dropoff(p_stop_id IN NUMBER) IS
  SELECT delivery_leg_id
  FROM wsh_delivery_legs wdl
  WHERE wdl.delivery_id = p_delivery_id
  AND wdl.drop_off_stop_id = p_stop_id;

  l_stop_type VARCHAR2(100);

  l_wt_uom_code               VARCHAR2(3);
  l_vol_uom_code              VARCHAR2(3);
  l_return_status             VARCHAR2(100);
  l_status_code               VARCHAR2(2);
  l_shipment_direction        wsh_new_deliveries.shipment_direction%TYPE;
  l_frozen_flag               VARCHAR2(1);
  l_dummy                     NUMBER;
  l_trip_empty                BOOLEAN;
  l_parent_delivery_id        NUMBER;
  l_debug_on                  BOOLEAN;
  l_del_tab                   wsh_util_core.id_tab_type;
  l_module_name CONSTANT      VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DEL_WV_POST_PROCESS';

  e_abort                     exception;
  mark_reprice_error          exception;

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',p_delivery_id);
    WSH_DEBUG_SV.log(l_module_name,'P_DIFF_GROSS_WT',p_diff_gross_wt);
    WSH_DEBUG_SV.log(l_module_name,'P_DIFF_NET_WT',p_diff_net_wt);
    WSH_DEBUG_SV.log(l_module_name,'P_DIFF_VOLUME',p_diff_volume);
    WSH_DEBUG_SV.log(l_module_name,'P_LEG_ID',p_leg_id);
    WSH_DEBUG_SV.log(l_module_name,'P_CHECK_FOR_EMPTY',P_CHECK_FOR_EMPTY);
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Get the delivery information
  BEGIN
    SELECT weight_uom_code,
           volume_uom_code,
           status_code,
           NVL(shipment_direction,'O'),
           NVL(wv_frozen_flag,'Y')
    INTO   l_wt_uom_code,
           l_vol_uom_code,
           l_status_code,
           l_shipment_direction,
           l_frozen_flag
    FROM   wsh_new_deliveries
    WHERE  delivery_id = p_delivery_id;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_DELIVERY');
        FND_MESSAGE.SET_TOKEN('DELIVERY',p_delivery_id);
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Delivery '||p_delivery_id||' not found');
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        return;
  END;

  -- If delivery status is 'IT','CL','SR' and shipment direction is 'O','IO' then Post processing is not allowed
  IF l_shipment_direction in ('O','IO') AND l_status_code IN ('IT','CL','SR') THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Status Code is '||l_status_code||'. Post Processing is not allowed');
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    return;
  END IF;

  -- for all trips assigned to the delivery leg/delivery
  FOR crec in trip_info LOOP

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Processing Trip '||crec.trip_id||' Pickup '||crec.pick_up_stop_id||' Drop off '||crec.drop_off_stop_id);
    END IF;

    -- if p_check_for_empty is 'Y' and if the trip will become empty without delivery
    -- then set W/V to null for all stops in this trip
    l_trip_empty := FALSE;
    IF p_check_for_empty = 'Y' THEN
      OPEN  C1(crec.trip_id);
      FETCH C1 INTO l_dummy;
      IF C1%NOTFOUND THEN
        l_trip_empty := TRUE;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Trip '||crec.trip_id||' will become empty without this delivery');
        END IF;

      --R12 MDC
      --Included update for new wt/vol columns
        UPDATE wsh_trip_stops
        SET    departure_gross_weight = null,
               departure_net_weight   = null,
               departure_volume       = null,
               departure_fill_percent = null,
               wv_frozen_flag = 'N',
               last_update_date  = SYSDATE,
               last_updated_by   = FND_GLOBAL.user_id,
               last_update_login = FND_GLOBAL.login_id,
               pick_up_weight = null,
               pick_up_volume = null,
               drop_off_weight = null,
               drop_off_volume = null
        WHERE  trip_id = crec.trip_id;
      END IF;
      CLOSE C1;
    END IF;

    IF NOT l_trip_empty THEN

      -- Adjust all stops W/V which are between pickup stop and dropoff stop
      FOR crec1 in c_stops(crec.trip_id, crec.pick_up_stop_id, crec.drop_off_stop_id) LOOP
        --R12 MDC
        l_stop_type := NULL;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Processing Stop '||crec1.stop_id);
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Adjust_parent_WV',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        OPEN c_check_pickup(crec1.stop_id);
        FETCH c_check_pickup INTO l_dummy;
        IF c_check_pickup%FOUND THEN
           l_stop_type := 'PICKUP';
        ELSE
           OPEN c_check_dropoff(crec1.stop_id);
           FETCH c_check_dropoff INTO l_dummy;
           IF c_check_dropoff%FOUND THEN
             l_stop_type := 'DROPOFF';
           END IF;
           CLOSE c_check_dropoff;
        END IF;
        CLOSE c_check_pickup;

        IF (crec.parent_delivery_leg_id IS NOT NULL) AND (l_stop_type = 'PICKUP') THEN

           OPEN c_parent_delivery(crec.parent_delivery_leg_id);
           FETCH c_parent_delivery
           INTO l_parent_delivery_id;
           CLOSE c_parent_delivery;

           Adjust_parent_WV(
             p_entity_type   => 'DELIVERY',
             p_entity_id     => l_parent_delivery_id,
             p_gross_weight  => p_diff_gross_wt,
             p_net_weight    => p_diff_net_wt,
             p_volume        => p_diff_volume,
             p_wt_uom_code   => l_wt_uom_code,
             p_vol_uom_code  => l_vol_uom_code,
             p_inv_item_id   => null,
             x_return_status => l_return_status);

           IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Adjust_parent_WV returned '||l_return_status);
             END IF;
             raise e_abort;
           END IF;
        ELSIF crec.parent_delivery_leg_id IS NULL THEN

           Adjust_parent_WV(
             p_entity_type   => 'STOP',
             p_entity_id     => crec1.stop_id,
             p_gross_weight  => p_diff_gross_wt,
             p_net_weight    => p_diff_net_wt,
             p_volume        => p_diff_volume,
             p_wt_uom_code   => l_wt_uom_code,
             p_vol_uom_code  => l_vol_uom_code,
             p_inv_item_id   => null,
             x_return_status => l_return_status,
             p_stop_type  => l_stop_type);

           IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Adjust_parent_WV returned '||l_return_status);
             END IF;
             raise e_abort;
           END IF;
        END IF;
      END LOOP;

    END IF;

  END LOOP;

  -- BugFix 5518613, changed > to <>
  IF (p_diff_gross_wt <> 0) or (p_diff_net_wt <> 0) THEN

     l_del_tab(1) := p_delivery_id;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
       p_entity_type => 'DELIVERY',
       p_entity_ids   => l_del_tab,
       x_return_status => l_return_status);
     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        raise mark_reprice_error;
     END IF;

  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

  WHEN lock_detected THEN -- BugFix 3570954
      FND_MESSAGE.SET_NAME('WSH','WSH_NO_LOCK');
      x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
      wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);

  WHEN e_abort THEN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;

  WHEN mark_reprice_error then
    FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
    x_return_status := l_return_status;
    WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
    END IF;

  WHEN Others THEN
    WSH_UTIL_CORE.Default_Handler ('WSH_WV_UTILS.DEL_WV_POST_PROCESS');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END DEL_WV_Post_Process;

-- J: W/V changes

-- Start of comments
-- API name : Detail_Weight_Volume
-- Type     : Public
-- Pre-reqs : None.
-- Function : Calculates Weight and Volume of Delivery Detail
--            If p_update_flag is 'Y' then the calculated W/V is updated on Delivery Detail
--            Otherwise, the API returns the calculated W/V
-- Parameters :
-- IN:
--    p_delivery_detail_id IN NUMBER Required
--    p_update_flag        IN VARCHAR2
--      'Y' if the detail needs to be updated with the calculated W/V
--    p_post_process_flag  IN VARCHAR2
--      'Y' if W/V post processing is required
--    p_calc_wv_if_frozen  IN VARCHAR2
--      'N' if W/V should not be calculated if W/V is frozen
-- OUT:
--    x_net_weight OUT NUMBER
--       gives the net weight of delivery detail
--    x_volume OUT NUMBER
--       gives the volume of delivery detail
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Detail_Weight_Volume (
  p_delivery_detail_id  IN NUMBER,
  p_update_flag         IN VARCHAR2,
  p_post_process_flag   IN VARCHAR2,
  p_calc_wv_if_frozen   IN VARCHAR2 DEFAULT 'Y',
  x_net_weight          OUT NOCOPY  NUMBER,
  x_volume              OUT NOCOPY  NUMBER,
  x_return_status       OUT NOCOPY  VARCHAR2) IS

  l_org_gross_wt number;
  l_org_net_wt   number;
  l_org_vol      number;
  l_frozen_flag  VARCHAR2(1);
  l_return_status VARCHAR2(100);

  l_debug_on     BOOLEAN;
  l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DETAIL_WEIGHT_VOLUME';

  e_abort        exception;

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_FLAG',P_UPDATE_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_POST_PROCESS_FLAG',P_POST_PROCESS_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_CALC_WV_IF_FROZEN',p_CALC_WV_IF_FROZEN);
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Get the DD info
  BEGIN
    SELECT gross_weight,
           net_weight,
           volume,
           NVL(wv_frozen_flag,'Y')
    INTO   l_org_gross_wt,
           l_org_net_wt,
           l_org_vol,
           l_frozen_flag
    FROM   wsh_delivery_details
    WHERE  delivery_detail_id = p_delivery_detail_id
    AND    container_flag = 'N';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
      FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_delivery_detail_id);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'DD '||p_delivery_detail_id||' not found');
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;
  END;

  IF (P_CALC_WV_IF_FROZEN = 'N' AND l_frozen_flag = 'Y') THEN
    x_net_weight := l_org_net_wt;
    x_volume     := l_org_vol;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WV calculation not allowed on '||p_delivery_detail_id||'. Returning existing W/V');
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    return;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'DD original wts are Gross '||l_org_gross_wt||' Net '||l_org_net_wt||' Vol '||l_org_vol);
  END IF;

  -- Call Detail_Weight_Volume API
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  Detail_Weight_Volume(
    p_delivery_detail_id  => p_delivery_detail_id,
    p_update_flag         => p_update_flag,
    p_calc_wv_if_frozen   => p_calc_wv_if_frozen,
    x_net_weight          => x_net_weight,
    x_volume              => x_volume,
    x_return_status       => l_return_status);

  IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
    x_return_status := l_return_status;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name,'Detail_Weight_Volume returned '||l_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     return;
  END IF;

  -- If p_update_flag is 'Y and ((p_post_process_flag is 'Y' and the new and old W/V differ)
  -- then call DD_WV_Post_Process API
  IF (p_update_flag = 'Y' AND p_post_process_flag = 'Y' AND
       (  (NVL(x_net_weight,0)   <> NVL(l_org_gross_wt,0)) OR
          (NVL(x_net_weight,0)   <> NVL(l_org_net_wt,0)) OR
          (NVL(x_volume,0)       <> NVL(l_org_vol,0))
       )) THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    DD_WV_Post_Process(
      p_delivery_detail_id => p_delivery_detail_id,
      p_diff_gross_wt      => NVL(x_net_weight,0) - NVL(l_org_gross_wt,0),
      p_diff_net_wt        => NVL(x_net_weight,0) - NVL(l_org_net_wt,0),
      p_diff_fill_volume   => NVL(x_volume,0) - NVL(l_org_vol,0),
      x_return_status      => l_return_status);

    IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := l_return_status;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'DD_WV_Post_Process returned '||l_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;
    END IF;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status '||x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

  WHEN e_abort THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  WHEN Others THEN
    WSH_UTIL_CORE.Default_Handler ('WSH_WV_UTILS.Detail_Weight_Volume');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL)
;
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Detail_Weight_Volume;

/* This procedure is no longer used */
-- THIS PROCEDURE IS OBSOLETE
PROCEDURE Add_Container_Wt_Vol (
  p_container_instance_id IN NUMBER,
  p_detail_id     IN NUMBER,
  p_detail_type   IN VARCHAR2,
  p_fill_pc_flag  IN VARCHAR2,
  x_gross_weight  OUT NOCOPY  NUMBER,
  x_net_weight    OUT NOCOPY  NUMBER,
  x_volume        OUT NOCOPY  NUMBER,
  x_cont_fill_pc  OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2) IS

BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

END Add_Container_Wt_Vol;

-- J: W/V Changes
-- OTM R12 : packing ECO
--           modified to keep track of container wt/vol updates
PROCEDURE Update_Container_Wt_Vol(
   p_container_instance_id IN NUMBER,
   p_gross_weight IN NUMBER,
   p_net_weight IN NUMBER,
   p_volume IN NUMBER,
   p_filled_volume IN NUMBER,
   p_fill_pc_flag IN VARCHAR2,
   p_unit_weight IN NUMBER DEFAULT -99,
   p_unit_volume IN NUMBER DEFAULT -99,
   x_cont_fill_pc OUT NOCOPY  NUMBER,
   x_return_status OUT NOCOPY  VARCHAR2) IS

   CURSOR c_get_detail_wv IS
   SELECT net_weight,
          gross_weight,
          volume,
          filled_volume,
          container_flag,
          nvl(line_direction, 'O') line_direction, -- LPN CONV. rv
          organization_id                          -- LPN CONV. rv
   FROM   wsh_delivery_details
   WHERE  delivery_detail_id = p_container_instance_id;

l_net_weight       NUMBER := 0;
l_gross_weight     NUMBER := 0;
l_volume           NUMBER := 0;
l_filled_volume    NUMBER := 0;
l_container_flag   VARCHAR2(1):='N';
l_details_marked   WSH_UTIL_CORE.Id_Tab_Type;
l_return_status    VARCHAR2(1);

mark_reprice_error EXCEPTION;
-- LPN CONV. rv
l_line_direction  VARCHAR2(10);
l_organization_id NUMBER;
l_wms_org         VARCHAR2(10) := 'N';
l_sync_tmp_rec    wsh_glbl_var_strct_grp.sync_tmp_rec_type;
l_num_warnings    NUMBER := 0;
-- LPN CONV. rv

l_debug_on    BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CONTAINER_WT_VOL';

BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_GROSS_WEIGHT',P_GROSS_WEIGHT);
       WSH_DEBUG_SV.log(l_module_name,'P_NET_WEIGHT',P_NET_WEIGHT);
       WSH_DEBUG_SV.log(l_module_name,'P_VOLUME',P_VOLUME);
       WSH_DEBUG_SV.log(l_module_name,'P_FILLED_VOLUME',P_FILLED_VOLUME);
       WSH_DEBUG_SV.log(l_module_name,'P_FILL_PC_FLAG',P_FILL_PC_FLAG);
   END IF;

   OPEN  c_get_detail_wv;
   FETCH c_get_detail_wv
   INTO  l_net_weight,
         l_gross_weight,
         l_volume,
         l_filled_volume,
         l_container_flag,
         l_line_direction,   -- LPN CONV. rv
         l_organization_id;  -- LPN CONV. rv
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Original l_net_weight '||l_net_weight||' l_gross_weight '||l_gross_weight||' l_volume '||l_volume||' l_filled_volume '||l_filled_volume||' l_container_flag '||l_container_flag);
   END IF;
   IF c_get_detail_wv%NOTFOUND THEN
     CLOSE c_get_detail_wv;
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');

     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     return;
   END IF;
   CLOSE c_get_detail_wv;

   -- K LPN CONV. rv
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'line direction', l_line_direction);
       WSH_DEBUG_SV.log(l_module_name,'Organization Id', l_organization_id);
   END IF;
   --
   l_wms_org := wsh_util_validate.check_wms_org(l_organization_id);
   --
   IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
   AND l_line_direction IN ('O','IO')
   AND l_container_flag IN ('Y', 'C')
   AND
   (
     ((WSH_WMS_LPN_GRP.GK_WMS_UPD_WV or WSH_WMS_LPN_GRP.GK_WMS_UPD_ITEM) and l_wms_org = 'Y')
     OR
     ((WSH_WMS_LPN_GRP.GK_INV_UPD_WV or WSH_WMS_LPN_GRP.GK_INV_UPD_ITEM) and l_wms_org = 'N')
   )
   THEN
   --{
       l_sync_tmp_rec.delivery_detail_id := p_container_instance_id;
       l_sync_tmp_rec.operation_type := 'UPDATE';
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       WSH_WMS_SYNC_TMP_PKG.MERGE
       (
         p_sync_tmp_rec      => l_sync_tmp_rec,
         x_return_status     => l_return_status
       );

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_WMS_SYNC_TMP_PKG.MERGE',l_return_status);
       END IF;
       --
       IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
         --
         x_return_status := l_return_status;
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'WSH_WMS_SYNC_TMP_PKG.MERGE completed with an error');
           WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
         --
       ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         --
         l_num_warnings := l_num_warnings + 1;
         --
       END IF;

   --}
   END IF;
   -- K LPN CONV. rv

   UPDATE WSH_DELIVERY_DETAILS
   SET    net_weight   = p_net_weight,
          gross_weight = p_gross_weight,
          volume       = p_volume,
          filled_volume= p_filled_volume,
          unit_weight  = NVL(unit_weight,decode(p_unit_weight,-99,NULL,p_unit_weight)),
          unit_volume  = NVL(unit_volume,decode(p_unit_volume,-99,NULL,p_unit_volume)),
          wv_frozen_flag  = 'N',
          last_update_date  = SYSDATE,
          last_updated_by   = FND_GLOBAL.user_id,
          last_update_login = FND_GLOBAL.login_id
   WHERE delivery_detail_id = p_container_instance_id;

   IF SQL%NOTFOUND THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');

     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     return;
   END IF;

   /* H projects : pricing integration csun */
   IF  (NVL(l_net_weight,-99)   <> NVL(p_net_weight,-99) OR
        NVL(l_gross_weight,-99) <> NVL(p_gross_weight,-99) OR
        NVL(NVL(l_filled_volume,l_volume),-99) <> NVL(p_filled_volume,-99) ) THEN

     l_details_marked.delete;
     l_details_marked(1) := p_container_instance_id;
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
       p_entity_type => 'DELIVERY_DETAIL',
       p_entity_ids   => l_details_marked,
       x_return_status => l_return_status);
     IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       raise mark_reprice_error;
     END IF;

   END IF;

   IF p_fill_pc_flag = 'Y' THEN

     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_CONTAINER_PKG.CALC_CONT_FILL_PC',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     WSH_TPA_CONTAINER_PKG.Calc_Cont_Fill_Pc (
        p_container_instance_id,
        'Y',
        NULL,
        x_cont_fill_pc,
        x_return_status);

     IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       return;
     END IF;

   END IF;

   -- OTM R12 : packing ECO
   -- after update wsh_delivery_details sql
   -- if any weight/vol changed, mark the global variable
   IF (G_DELIVERY_TMS_IMPACT = 'N' AND
       (NVL(l_net_weight, -1) <> NVL(p_net_weight, -1) OR
        NVL(l_gross_weight, -1) <> NVL(p_gross_weight, -1) OR
        NVL(l_volume, -1) <> NVL(p_volume, -1))) THEN
     G_DELIVERY_TMS_IMPACT := 'Y';
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'G_DELIVERY_TMS_IMPACT', G_DELIVERY_TMS_IMPACT);
     END IF;
   END IF;
   -- End of OTM R12 : packing ECO

   -- LPN CONV. rv
   IF (l_num_warnings > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     --
   ELSE
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     --
   END IF;
   -- LPN CONV. rv

   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
   WHEN mark_reprice_error then
     FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
     x_return_status := l_return_status;
     WSH_UTIL_CORE.add_message (x_return_status);
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
     END IF;

   WHEN others THEN
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'EXCEPTION: OTHERS ' || SQLERRM  );
     END IF;
     wsh_util_core.default_handler('WSH_WV_UTIL.update_container_wt_vol');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END update_container_wt_vol;

-- J: W/V Changes

-- Start of comments
-- API name : Container_Weight_Volume
-- Type     : Private
-- Pre-reqs : None.
-- Function : Calculates Weight and Volume of Container
--            If p_overrideFlag is 'Y' then the calculated W/V is updated on Container
--            Otherwise, the API returns the calculated W/V
--            OTM R12 : packing ECO
--                      This procedure is modified to keep track of detail
--                      wt/vol updates. Changed because it contains the actual
--                      update on the wsh_delivery_detail table.
-- Parameters :
-- IN:
--    p_containerInstanceId IN NUMBER Required
--    p_overrideFlag        IN VARCHAR2
--      'Y' if the detail needs to be updated with the calculated W/V
--    p_calcWVIfFrozen      IN VARCHAR2
--      ''Y' if manual W/V can be overriden
--    p_fillPcFlag          IN  VARCHAR2
--      'Y' if fill% needs to be calculated
--    p_masterWeightUomCode IN  VARCHAR2
--      Return the calculated Wt info in p_masterWeightUomCode UOM
--    p_masterVolumeUomCode IN  VARCHAR2
--      Return the calculated Vol info in p_masterVolumeUomCode UOM
-- OUT:
--    x_grossWeight OUT NUMBER
--       gives the gross weight of container
--    x_netWeight OUT NUMBER
--       gives the net weight of container
--    x_filledVolume OUT NUMBER
--       gives the filled volume of container
--    x_volume OUT NUMBER
--       gives the volume of container
--    x_contFillPc  OUT NUMBER
--       gives the Fill% of container
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Container_Weight_Volume
            (
              p_containerInstanceId     IN  NUMBER,
              p_overrideFlag            IN  VARCHAR2,
              p_calcWVIfFrozen          IN  VARCHAR2,
              p_fillPcFlag              IN  VARCHAR2,
              p_masterWeightUomCode     IN  VARCHAR2 DEFAULT NULL,
              p_masterVolumeUomCode     IN  VARCHAR2 DEFAULT NULL,
              x_grossWeight             OUT NOCOPY  NUMBER,
              x_netWeight               OUT NOCOPY  NUMBER,
              x_filledVolume            OUT NOCOPY  NUMBER,
              x_volume                  OUT NOCOPY  NUMBER,
              x_contFillPc              OUT NOCOPY  NUMBER,
              x_returnStatus            OUT NOCOPY  VARCHAR2
            )
IS
--{
    --
    -- Parameters p_masterWeightUomCode, p_masterVolumeUomCode will be NULL
    -- when this procedure is called for the topmost container.
    -- It will be set during the first call and will be passed on to any
    -- recursive calls.
    --
    --
    -- x_volume indicates volume of a line i.e. volume of an item/container itself.
    -- x_filledVolume indicate filled volume of a line
    -- In case of a container, it will indicate total volume of all its contents
    -- In case of other items(non-container), it will be same as x_volume.
    -- Same holds true for local variables
    --   - l_volume and l_filledVolume
    --   - l_line_volume and l_line_filledVolume
    --
    l_netWeight              NUMBER;
    l_grossWeight            NUMBER;
    l_volume                 NUMBER;
    l_filledVolume           NUMBER;
    l_contFillPc             number;
    --
    --
    l_line_grossWeight        NUMBER;
    l_line_netWeight          NUMBER;
    l_line_volume             NUMBER;
    l_line_grossWeight_orig   NUMBER;
    l_line_netWeight_orig     NUMBER;
    l_line_volume_orig        NUMBER;
    l_line_filledVolume       NUMBER;
    l_line_contFillPc         NUMBER;
    l_returnStatus            VARCHAR2(32767);
    --
    --
    l_masterWeightUomCode    VARCHAR2(32767);
    l_masterVolumeUomCode    VARCHAR2(32767);
    l_masterInvItemId        NUMBER;
    --
    --
    l_dd_grossWt             NUMBER;
    l_dd_netWt               NUMBER;
    l_dd_vol                 NUMBER;
    --
    e_wt_vol_fail         EXCEPTION;
    e_abort               EXCEPTION;
    e_continue            EXCEPTION;
    e_invalid_detail      EXCEPTION;

    --
    --
    -- Following query returns the delivery details ID and its immediate
    -- children ( Condition LEVEL <=2 limits itself to only immediate children)
    --
    CURSOR immediateChildren_cur
             (
               p_containerInstanceId IN  NUMBER
             )
    IS
    SELECT     delivery_detail_id,
               LEVEL
    FROM       wsh_delivery_assignments wda
    WHERE      LEVEL                   <= 2
    AND        NVL(wda.type, 'S')       in ('S', 'C')
    START WITH wda.delivery_detail_id       = p_containerInstanceId
          AND  NVL(wda.type, 'S')       in ('S', 'C')
    CONNECT BY PRIOR delivery_detail_id = parent_delivery_detail_id;
    --
    --
    -- Get Delivery Detail information for each line including its
    -- physical attributes from inventory item definition.
    --
    --
    CURSOR childInfo_cur
             (
               p_deliveryDetailId     IN NUMBER
             )
    IS
    SELECT wdd.container_flag ,
           wdd.delivery_detail_id,
           wdd.inventory_item_id,
           NVL(wdd.wv_frozen_flag,'Y') wv_frozen_flag,
           wdd.net_weight,
           wdd.gross_weight,
           wdd.volume,
           wdd.filled_volume,
           wdd.weight_uom_code,
           wdd.volume_uom_code,
           wdd.organization_id ,
           nvl(wdd.unit_weight,msi.unit_weight) unit_weight,
           nvl(wdd.unit_volume,msi.unit_volume) unit_volume,
           WSH_WV_UTILS.convert_uom
             (
               wdd.requested_quantity_uom,
               nvl(msi.primary_uom_code,wdd.requested_quantity_uom), --Bug7165744
               nvl(wdd.received_quantity, nvl(wdd.shipped_quantity, NVL(wdd.picked_quantity, wdd.requested_quantity))),
               wdd.inventory_item_id
             ) qty
    FROM   mtl_system_items msi,
           wsh_delivery_details wdd
    WHERE  msi.inventory_item_id (+)  = wdd.inventory_item_id
    AND    msi.organization_id (+)    = wdd.organization_id
    AND    wdd.delivery_detail_id = p_deliveryDetailId;
    --
    childInfo_rec childInfo_cur%ROWTYPE;
--}

l_details_marked        WSH_UTIL_CORE.Id_Tab_Type;

l_return_status         VARCHAR2(1);
l_err_container         NUMBER;
mark_reprice_error      EXCEPTION;
invalid_detail          EXCEPTION;

l_param_info  WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
l_num_warnings  NUMBER := 0;
l_unit_wt NUMBER;
l_unit_vol NUMBER;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONTAINER_WEIGHT_VOLUME';
--lpn conv
l_wms_org               VARCHAR2(10) := 'N';

BEGIN
--{
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_CONTAINERINSTANCEID',P_CONTAINERINSTANCEID);
        WSH_DEBUG_SV.log(l_module_name,'P_OVERRIDEFLAG',P_OVERRIDEFLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_CALCWVIFFROZEN',P_CALCWVIFFROZEN);
        WSH_DEBUG_SV.log(l_module_name,'P_FILLPCFLAG',P_FILLPCFLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_MASTERWEIGHTUOMCODE',P_MASTERWEIGHTUOMCODE);
        WSH_DEBUG_SV.log(l_module_name,'P_MASTERVOLUMEUOMCODE',P_MASTERVOLUMEUOMCODE);
    END IF;
    l_returnStatus := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    -- For parent container and all its immediate contents
    FOR immediateChildren_rec
    IN  immediateChildren_cur ( p_containerInstanceId )
    LOOP
    --{
        BEGIN

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Processing DD '||immediateChildren_rec.delivery_detail_id);
        END IF;

        -- Get the container info
        OPEN childInfo_cur ( immediateChildren_rec.delivery_detail_id );
        FETCH childInfo_cur INTO childInfo_rec;
        IF childInfo_cur%NOTFOUND
        THEN
        --{
            CLOSE childInfo_cur;
            RAISE e_continue;
        --}
        END IF;
        CLOSE childInfo_cur;

        --lpn conv
        IF childInfo_rec.container_flag IN ('Y', 'C')
                          AND NVL(childInfo_rec.wv_frozen_flag,'Y') = 'Y' THEN
           l_wms_org :=
               wsh_util_validate.check_wms_org(childInfo_rec.organization_id);
           IF l_wms_org = 'Y' THEN
              childInfo_rec.wv_frozen_flag := 'N';
           END IF;
        END IF;

        -- Set Master Weight and Volume UOM Code to the UOMs of parent container
        IF immediateChildren_rec.LEVEL = 1 THEN
          l_masterWeightUomCode := childInfo_rec.weight_uom_code;
          l_masterVolumeUomCode := childInfo_rec.volume_uom_code;
          l_masterInvItemId     := childInfo_rec.inventory_item_id;

          IF (childInfo_rec.wv_frozen_flag = 'Y' AND p_calcWVIfFrozen = 'N') THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'wv_frozen_flag is Y. Skipping the W/V calculation for this container');
            END IF;
            l_grossWeight  := childInfo_rec.gross_weight;
            l_netWeight    := childInfo_rec.net_weight;
            l_volume       := childInfo_rec.volume;
            l_filledVolume := childInfo_rec.filled_volume;
            goto skip_wv_calc;
          END IF;

          -- Get the shipping parameters of container organization
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.Get',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_SHIPPING_PARAMS_PVT.Get(
            p_organization_id => childInfo_rec.organization_id,
            x_param_info      => l_param_info,
            x_return_status   => l_return_status);

          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'WSH_SHIPPING_PARAMS_PVT.Get returned '||l_return_status);
            END IF;
            FND_MESSAGE.Set_Name('WSH', 'WSH_PARAM_NOT_DEFINED');
            FND_MESSAGE.Set_Token('ORGANIZAION_CODE',
                     wsh_util_core.get_org_name(childInfo_rec.organization_id));
            wsh_util_core.add_message(l_return_status,l_module_name);
            raise e_abort;
          END IF;

        END IF;

        l_dd_grossWt := childInfo_rec.unit_weight * childInfo_rec.qty;
        l_dd_netWt   := l_dd_grossWt;
        l_dd_vol     := childInfo_rec.unit_volume * childInfo_rec.qty;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'l_dd_grossWt '||l_dd_grossWt||' l_dd_netWt '||l_dd_netWt||' l_dd_vol '||l_dd_vol);
        END IF;

        -- Convert the W/V if UOMs differ
        IF ((l_dd_vol > 0) AND (childInfo_rec.volume_uom_code <> l_masterVolumeUomCode)) THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            l_line_volume := WSH_WV_UTILS.convert_uom(
                               childInfo_rec.volume_uom_code,
                               l_masterVolumeUomCode,
                               l_dd_vol,
                               childInfo_rec.inventory_item_id);

            l_line_volume_orig := l_dd_vol;
        ELSE
            l_line_volume      := l_dd_vol;
            l_line_filledVolume:= l_dd_vol;
            l_line_volume_orig := l_line_volume;
        END IF;

        IF ((l_dd_grossWt > 0) AND (childInfo_rec.weight_uom_code <> l_masterWeightUomCode)) THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            l_line_grossWeight := WSH_WV_UTILS.convert_uom(
                                    childInfo_rec.weight_uom_code,
                                    l_masterWeightUomCode,
                                    l_dd_grossWt,
                                    childInfo_rec.inventory_item_id);
            l_line_grossWeight_orig := l_dd_grossWt;
        ELSE
          l_line_grossWeight      := l_dd_grossWt;
          l_line_grossWeight_orig := l_line_grossWeight;
        END IF;

        IF ((l_dd_netWt > 0) AND (childInfo_rec.weight_uom_code <> l_masterWeightUomCode)) THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            l_line_netWeight := WSH_WV_UTILS.convert_uom(
                                    childInfo_rec.weight_uom_code,
                                    l_masterWeightUomCode,
                                    l_dd_netWt,
                                    childInfo_rec.inventory_item_id);
            l_line_netWeight_orig := l_dd_netWt;
        ELSE
          l_line_netWeight      := l_dd_netWt;
          l_line_netWeight_orig := l_line_netWeight;
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'l_line_grossWeight '||l_line_grossWeight||' l_line_netWeight '||l_line_netWeight||' l_line_volume '||l_line_volume);
          WSH_DEBUG_SV.logmsg(l_module_name,'l_line_grossWeight_orig '||l_line_grossWeight_orig||' l_line_netWeight_orig '||l_line_netWeight_orig||' l_line_volume_orig '||l_line_volume_orig);
        END IF;

        -- Raise warning if delivery detail has null W/V depending on percent_fill_basis_flag
        IF (childInfo_rec.container_flag = 'N') THEN
          IF (l_param_info.percent_fill_basis_flag = 'W' AND l_line_grossWeight IS NULL) OR
             (l_param_info.percent_fill_basis_flag = 'V' AND l_line_volume IS NULL) THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_NULL_WEIGHT_VOLUME');
            FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL',childInfo_rec.delivery_detail_id);
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING);
            l_num_warnings := l_num_warnings + 1;

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Raising WSH_NULL_WEIGHT_VOLUME Warning for Dd '||immediateChildren_rec.delivery_detail_id);
            END IF;
          END IF;
        END IF;

        -- For parent container
        IF immediateChildren_rec.LEVEL = 1
        THEN
        --{
            l_unit_wt      := childInfo_rec.unit_weight;
            l_unit_vol     := childInfo_rec.unit_volume;
            l_netWeight    := null;
            l_volume       := l_line_volume;

            IF childInfo_rec.container_flag IN ('Y', 'C')
            THEN
            --{
                l_grossWeight  := l_line_grossWeight;
            --}
            ELSE
            --{
                l_grossWeight := null;
            --}
            END IF;
        --}
        -- For immediate chidren (container/delivery details)
        ELSE  -- immediateChildren_rec.LEVEL = 2, content of a container.
        --{
            -- For container
            IF childInfo_rec.container_flag IN ('Y', 'C')
            THEN
            --{
                l_line_grossWeight        := NULL;
                l_line_netWeight          := NULL;
                l_line_volume             := NULL;
                l_line_filledVolume       := NULL;
                l_line_contFillPc         := NULL;
                --
                --
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Container_Weight_Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                Container_Weight_Volume
                  (
                    p_containerInstanceId  => childInfo_rec.delivery_detail_id,
                    p_overrideFlag         => p_overrideFlag,
                    p_calcWVIfFrozen       => p_calcWVIfFrozen,
                    x_grossWeight          => l_line_grossWeight,
                    x_netWeight            => l_line_netWeight,
                    x_volume               => l_line_volume,
                    p_fillPcFlag           => p_fillPcFlag,
                    x_contFillPc           => l_line_contFillPc,
                    x_returnStatus         => l_returnStatus,
                    x_filledVolume         => l_line_filledVolume,
                    p_masterWeightUomCode  => l_masterWeightUomCode,
                    p_masterVolumeUomCode  => l_masterVolumeUomCode
                  );
                --
                --
                IF l_returnStatus NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING)
                THEN
                    l_err_container := childInfo_rec.delivery_detail_id;
                    RAISE e_wt_vol_fail;
                ELSIF l_returnStatus = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                    l_num_warnings := l_num_warnings + 1;
                END IF;
                --
            --}
            -- For delivery detail
            ELSE
            --{
                IF p_calcWVIfFrozen = 'N' and childInfo_rec.wv_frozen_flag = 'Y' THEN
                  l_line_netWeight    := childInfo_rec.net_weight;
                  l_line_grossWeight  := childInfo_rec.gross_weight;
                  l_line_volume       := childInfo_rec.volume;
                  l_line_FilledVolume := childInfo_rec.volume;
                ELSE
                  l_line_netWeight    := l_line_netWeight;
                  l_line_grossWeight  := l_line_grossWeight;
                  l_line_volume       := l_line_volume;
                  l_line_FilledVolume := l_line_volume;
                END IF;

                IF ((p_overrideFlag = 'Y')  AND
                    (NOT (p_calcWVIfFrozen = 'N' and childInfo_rec.wv_frozen_flag = 'Y')) AND
                    ((NVL(l_line_grossWeight_orig,-99) <> NVL(childInfo_rec.gross_weight,-99)) OR
                     (NVL(l_line_volume_orig,-99) <> NVL(childInfo_rec.volume,-99)))) THEN
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Update W/V for DD '||childInfo_rec.delivery_detail_id);
                  END IF;
                  -- LPN CONV. rv
                  -- no call reqd. because this update is for non-container lines
                  UPDATE wsh_delivery_details
                  SET    net_weight   = l_line_grossWeight_orig,
                         gross_weight = l_line_grossWeight_orig,
                         volume       = l_line_volume_orig,
                         unit_weight  = NVL(unit_weight,childInfo_rec.unit_weight),
                         unit_volume  = NVL(unit_volume,childInfo_rec.unit_volume),
                         wv_frozen_flag  = 'N',
                         last_update_date  = SYSDATE,
                         last_updated_by   = FND_GLOBAL.user_id,
                         last_update_login = FND_GLOBAL.login_id
                  WHERE delivery_detail_id = childInfo_rec.delivery_detail_id;
                  --
                  --
                  IF SQL%NOTFOUND  OR SQL%ROWCOUNT = 0
                  THEN
                  --{
                      FND_MESSAGE.SET_NAME('WSH','WSH_DET_INVALID_DETAIL');
                      FND_MESSAGE.SET_TOKEN('DETAIL_ID',childInfo_rec.delivery_detail_id);
                      RAISE e_invalid_detail;
                  --}
                  END IF;

                  l_details_marked.delete;
                  l_details_marked(1) := childInfo_rec.delivery_detail_id;

                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
                    p_entity_type   => 'DELIVERY_DETAIL',
                    p_entity_ids    => l_details_marked,
                    x_return_status => l_return_status);
                  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                    raise mark_reprice_error;
                  END IF;

                  -- OTM R12 : packing ECO
                  -- after update wsh_delivery_details sql
                  -- if any weight/vol changed, mark the global variable

                  -- G_DELIVERY_TMS_IMPACT is set to Y for the first one
                  -- meeting the condition in immediateChildren_rec cursor,
                  -- if none of them has different weight, then it stays N
                  -- once it's set to Y, it won't be checked again for other
                  -- children

                  IF (G_DELIVERY_TMS_IMPACT = 'N' AND
                      NVL(l_line_grossWeight_orig,-99) <>
                      NVL(childInfo_rec.net_weight,-99)) THEN
                    G_DELIVERY_TMS_IMPACT := 'Y';
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id', childInfo_rec.delivery_detail_id);
                      WSH_DEBUG_SV.log(l_module_name,'G_DELIVERY_TMS_IMPACT', G_DELIVERY_TMS_IMPACT);
                    END IF;
                  END IF;
                  -- End of OTM R12 : packing ECO
                END IF;

            --}
            END IF;
            --
            -- Accumlate the W/V
            IF l_line_netWeight IS NOT NULL THEN
              l_netWeight := nvl(l_netWeight,0) + l_line_netWeight;
            END IF;
            IF (l_line_grossWeight IS NOT NULL) THEN
              l_grossWeight := nvl(l_grossWeight,0) + l_line_grossWeight;
            END IF;
            IF (l_line_volume IS NOT NULL) THEN
              l_filledVolume := nvl(l_filledVolume,0) + l_line_volume;
            END IF;
        --}
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'After this iteration LEVEL '||immediateChildren_rec.LEVEL||
                                            ' l_grossWeight '||l_grossWeight||' l_netWeight '||l_netWeight||
                                            ' l_volume '||l_volume||' l_filledVolume '||l_filledVolume);
        END IF;
        --
        EXCEPTION
           when e_continue THEN
             NULL;
        END;
    --}
    END LOOP;

    IF l_volume = 0 THEN
       l_volume := l_filledVolume;
    END IF;
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'After LOOP l_grossWeight '||l_grossWeight||' l_netWeight '||l_netWeight||
                                         ' l_volume '||l_volume||' l_filledVolume '||l_filledVolume);
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Update_container_Wt_Vol',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    -- IF p_overrideFlag is 'Y' then call update_container_wt_vol to update W/V
    IF (p_overrideFlag = 'Y') THEN
      update_container_wt_vol(
        p_container_instance_id =>   p_containerInstanceId,
        p_gross_weight  => l_grossWeight,
        p_net_weight    => l_netWeight,
        p_volume        => l_volume,
        p_filled_volume => l_filledVolume,
        p_fill_pc_flag  => p_fillPcFlag,
        p_unit_weight   => l_unit_wt,
        p_unit_volume   => l_unit_vol,
        x_cont_fill_pc  => x_contFillPc,
        x_return_status => l_returnStatus);

      IF l_returnStatus NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING)
      THEN
          l_err_container := p_containerInstanceId;
          RAISE e_wt_vol_fail;
      ELSIF l_returnStatus = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_num_warnings := l_num_warnings + 1;
      END IF;

    END IF;
    --

    <<skip_wv_calc>>

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'p_masterWeightUomCode '||p_masterWeightUomCode||' l_masterWeightUomCode '||l_masterWeightUomCode||' l_masterInvItemId '||l_masterInvItemId);
    END IF;

    -- Convert the calculated W/V to p_masterWeightUomCode,p_masterVolumeUomCode UOMs
    IF p_masterWeightUomCode <> l_masterWeightUomCode THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      x_grossWeight := WSH_WV_UTILS.convert_uom(
                         l_masterWeightUomCode,
                         p_masterWeightUomCode,
                         l_grossWeight,
                         l_masterInvItemId);
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      x_netWeight := WSH_WV_UTILS.convert_uom(
                       l_masterWeightUomCode,
                       p_masterWeightUomCode,
                       l_netWeight,
                       l_masterInvItemId);
    ELSE
      x_grossWeight := l_grossWeight;
      x_netWeight := l_netWeight;
    END IF;

    IF p_masterVolumeUomCode <> l_masterVolumeUomCode THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      x_volume := WSH_WV_UTILS.convert_uom(
                    l_masterVolumeUomCode,
                    p_masterVolumeUomCode,
                    l_volume,
                    l_masterInvItemId);
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      x_filledVolume := WSH_WV_UTILS.convert_uom(
                          l_masterVolumeUomCode,
                          p_masterVolumeUomCode,
                          l_filledVolume,
                          l_masterInvItemId);
    ELSE
      x_volume := l_volume;
      x_filledVolume := l_filledVolume;
    END IF;
    --
    IF l_num_warnings > 0 THEN
      x_returnStatus := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
      x_returnStatus := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'x_grossWeight '||x_grossWeight||' x_netWeight '||x_netWeight||
                                         ' x_volume '||x_volume||' x_filledVolume '||x_filledVolume||
                                         ' x_contFillPc '||x_contFillPc||' x_returnStatus '||x_returnStatus);
    END IF;
--}
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN mark_reprice_error then
   FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
   x_returnStatus := l_return_status;
   WSH_UTIL_CORE.add_message (x_returnStatus);
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
   END IF;
   --
  WHEN  e_invalid_detail THEN
        x_returnStatus := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.add_message (x_returnStatus);
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'E_INVALID_DETAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_INVALID_DETAIL');
   END IF;
   --
  WHEN  e_wt_vol_fail THEN
        FND_MESSAGE.Set_Name('WSH','WSH_UPDATE_WTVOL_FAIL');
        FND_MESSAGE.Set_Token('LPN', l_err_container);
        x_returnStatus := WSH_UTIL_CORE.G_RET_STS_ERROR;
   WSH_UTIL_CORE.add_message (x_returnStatus);
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'E_WT_VOL_FAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_WT_VOL_FAIL');
   END IF;
   --
  WHEN e_abort THEN
    WSH_UTIL_CORE.Default_Handler ('WSH_WV_UTILS.CONTAINER_WEIGHT_VOLUME');
    x_returnStatus := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  WHEN Others THEN
    WSH_UTIL_CORE.Default_Handler ('WSH_WV_UTILS.CONTAINER_WEIGHT_VOLUME');
    x_returnStatus := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END Container_Weight_Volume;

-- Start of comments
-- API name : Container_Weight_Volume
-- Type     : Private
-- Pre-reqs : None.
-- Function : Wrapper for the base Container_Weight_Volume (Called from TPA API)
-- Parameters :
-- IN:
--    p_container_instance_id IN NUMBER Required
--    p_override_flag         IN VARCHAR2
--      'Y' if the detail needs to be updated with the calculated W/V
--    p_calc_wv_if_frozen     IN VARCHAR2
--      'Y' if manual W/V can be overriden
--    p_fill_pc_flag          IN  VARCHAR2
--      'Y' if fill% needs to be calculated
-- OUT:
--    x_gross_weight OUT NUMBER
--       gives the gross weight of container
--    x_net_weight OUT NUMBER
--       gives the net weight of container
--    x_volume OUT NUMBER
--       gives the volume of container
--    x_cont_fill_pc  OUT NUMBER
--       gives the Fill% of container
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Container_Weight_Volume (
  p_container_instance_id IN NUMBER,
  p_override_flag IN VARCHAR2,
  x_gross_weight  OUT NOCOPY  NUMBER,
  x_net_weight    OUT NOCOPY  NUMBER,
  x_volume        OUT NOCOPY  NUMBER,
  p_fill_pc_flag  IN VARCHAR2,
  x_cont_fill_pc  OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  p_calc_wv_if_frozen IN VARCHAR2) IS


l_vol number;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONTAINER_WEIGHT_VOLUME';
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
      WSH_DEBUG_SV.log(l_module_name,'P_OVERRIDE_FLAG',P_OVERRIDE_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_CALC_WV_IF_FROZEN',P_CALC_WV_IF_FROZEN);
      WSH_DEBUG_SV.log(l_module_name,'P_FILL_PC_FLAG',P_FILL_PC_FLAG);
  END IF;
  --
  Container_Weight_Volume
    (
      p_containerInstanceId => p_container_instance_id,
      p_overrideFlag        => p_override_flag,
      p_calcWVIfFrozen      => p_calc_wv_if_frozen,
      x_grossWeight         => x_gross_weight,
      x_netWeight           => x_net_weight,
      x_volume              => x_volume,
      p_fillPcFlag          => p_fill_pc_flag,
      x_contFillPc          => x_cont_fill_pc,
      x_returnStatus        => x_return_status,
      x_filledVolume        => l_vol
    );
/*
EXCEPTION

  WHEN Others THEN
   WSH_UTIL_CORE.Default_Handler ('WSH_WV_UTILS.CONTAINER_WEIGHT_VOLUME');
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
*/
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END Container_Weight_Volume;

-- J: W/V changes

-- Start of comments
-- API name : Container_Weight_Volume
-- Type     : Private
-- Pre-reqs : None.
-- Function : Calculates Weight and Volume of Container
--            If p_override_flag is 'Y' then the calculated W/V is updated on Container
--            Otherwise, the API returns the calculated W/V
--            If p_post_process_flag is 'Y' then calls post processing API
-- Parameters :
-- IN:
--    p_container_instance_id IN NUMBER Required
--    p_override_flag         IN VARCHAR2
--      'Y' if the detail needs to be updated with the calculated W/V
--    p_fill_pc_flag          IN  VARCHAR2
--      'Y' if fill% needs to be calculated
--    p_post_process_flag     IN VARCHAR2
--      'Y' if W/V post processing is required
--    p_calc_wv_if_frozen     IN VARCHAR2
--      'Y' if manual W/V can be overriden
-- OUT:
--    x_gross_weight OUT NUMBER
--       gives the gross weight of container
--    x_net_weight OUT NUMBER
--       gives the net weight of container
--    x_volume OUT NUMBER
--       gives the volume of container
--    x_cont_fill_pc  OUT NUMBER
--       gives the Fill% of container
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Container_Weight_Volume (
  p_container_instance_id IN NUMBER,
  p_override_flag IN VARCHAR2,
  p_fill_pc_flag  IN VARCHAR2,
  p_post_process_flag IN VARCHAR2,
  p_calc_wv_if_frozen IN VARCHAR2 DEFAULT 'Y',
  x_gross_weight  OUT NOCOPY  NUMBER,
  x_net_weight    OUT NOCOPY  NUMBER,
  x_volume        OUT NOCOPY  NUMBER,
  x_cont_fill_pc  OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2) IS

l_org_gross_wt number;
l_org_net_wt   number;
l_org_vol      number;
l_org_fill_pc  number;
l_organization_id NUMBER;
l_frozen_flag  VARCHAR2(1);

l_return_status VARCHAR2(100);
l_debug_on     BOOLEAN;
l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONTAINER_WEIGHT_VOLUME';
--lpn conv
l_wms_org      VARCHAR2(10) := 'N';

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_INSTANCE_ID',P_CONTAINER_INSTANCE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_OVERRIDE_FLAG',P_OVERRIDE_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_FILL_PC_FLAG',P_FILL_PC_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_POST_PROCESS_FLAG',P_POST_PROCESS_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_CALC_WV_IF_FROZEN',P_CALC_WV_IF_FROZEN);
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Get the container info
  BEGIN
    SELECT gross_weight,
           net_weight,
           volume,
           fill_percent,
           organization_id,
           NVL(wv_frozen_flag,'Y')
    INTO   l_org_gross_wt,
           l_org_net_wt,
           l_org_vol,
           l_org_fill_pc,
           l_organization_id,
           l_frozen_flag
    FROM   wsh_delivery_details
    WHERE  delivery_detail_id = p_container_instance_id
    AND    container_flag IN ('Y', 'C');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_DET_INVALID_DETAIL');
        FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_container_instance_id);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        return;
  END;

  --lpn conv
  IF NVL(l_frozen_flag,'Y') = 'Y' THEN
     l_wms_org :=
            wsh_util_validate.check_wms_org(l_organization_id);
     IF l_wms_org = 'Y' THEN
        l_frozen_flag := 'N';
     END IF;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'DD original wts are Gross '||l_org_gross_wt||' Net '||l_org_net_wt||' Vol '||l_org_vol||' Frozen '||l_frozen_flag);
  END IF;

  IF (P_CALC_WV_IF_FROZEN = 'N' AND l_frozen_flag = 'Y') THEN
    x_gross_weight := l_org_gross_wt;
    x_net_weight   := l_org_net_wt;
    x_volume       := l_org_vol;
    x_cont_fill_pc := l_org_fill_pc;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'WV calculation not allowed on '||p_container_instance_id||'. Returning existing W/V');
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    return;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_CONTAINER_PKG.container_weight_volume',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  -- Call WSH_TPA_CONTAINER_PKG.container_weight_volume to calculate W/V
  WSH_TPA_CONTAINER_PKG.container_weight_volume (
    p_container_instance_id => p_container_instance_id,
    p_override_flag         => p_override_flag,
    p_calc_wv_if_frozen     => p_calc_wv_if_frozen,
    p_fill_pc_flag          => p_fill_pc_flag,
    x_gross_weight          => x_gross_weight,
    x_net_weight            => x_net_weight,
    x_volume                => x_volume,
    x_cont_fill_pc          => x_cont_fill_pc,
    x_return_status         => l_return_status);

  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
    x_return_status := l_return_status;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TPA_CONTAINER_PKG.container_weight_volume returned '||l_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     return;
  END IF;

  -- If p_override_flag is 'Y and ((p_post_process_flag is 'Y' and the new and old W/V differ)
  -- then call DD_WV_Post_Process API
  IF (p_override_flag = 'Y' AND p_post_process_flag = 'Y' AND
      (  (NVL(x_gross_weight,0) <> NVL(l_org_gross_wt,0)) OR
         (NVL(x_net_weight,0)   <> NVL(l_org_net_wt,0)) OR
         (NVL(x_volume,0)       <> NVL(l_org_vol,0)))) THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    DD_WV_Post_Process(
      p_delivery_detail_id => p_container_instance_id,
      p_diff_gross_wt      => NVL(x_gross_weight,0) - NVL(l_org_gross_wt,0),
      p_diff_net_wt        => NVL(x_net_weight,0) - NVL(l_org_net_wt,0),
      p_diff_fill_volume   => NVL(x_volume,0) - NVL(l_org_vol,0),
      x_return_status      => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'DD_WV_Post_Process returned '||l_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;
    END IF;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status '||x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN Others THEN
    WSH_UTIL_CORE.Default_Handler ('WSH_WV_UTILS.CONTAINER_WEIGHT_VOLUME');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL)
;
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Container_Weight_Volume;

-- J: W/V changes

-- Start of comments
-- API name : Detail_Weight_Volume
-- Type     : Public
-- Pre-reqs : None.
-- Function : Calculates Weight and Volume of Multiple Delivery Details
--            If p_update_flag is 'Y' then the calculated W/V is updated on Delivery Detail
--            Otherwise, the API returns the calculated W/V
--            If p_calc_wv_if_frozen is 'N' then W/V will be calculated not be calculated
--            for entities whose W/V is manually entered
--            OTM R12 : packing ECO
--                      This procedure is modified to keep track of delivery
--                      detail wt/vol updates. Called first by WSHDDGPB
--                      (WSH_DELIVERY_DETAILS_GRP.Delivery_Detail_Action),
--                      so the logic of checking G_RESET_WV is here.
-- Parameters :
-- IN:
--    p_detail_rows        IN wsh_util_core.id_tab_type REQUIRED
--    p_update_flag        IN VARCHAR2
--      'Y' if the detail needs to be updated with the calculated W/V
--    p_calc_wv_if_frozen  IN VARCHAR2
--      'Y' if manual W/V can be overriden
-- OUT:
--    x_return_status OUT VARCHAR2 Required
--       gives the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Detail_Weight_Volume(
           p_detail_rows    IN wsh_util_core.id_tab_type,
           p_override_flag  IN VARCHAR2,
           p_calc_wv_if_frozen IN VARCHAR2 DEFAULT 'Y',
           x_return_status  OUT NOCOPY  VARCHAR2) IS

CURSOR c_container_flag(x_id NUMBER) IS
SELECT container_flag
  FROM wsh_delivery_details
 WHERE delivery_detail_id = x_id;

-- OTM R12 : packing ECO
CURSOR c_get_delivery_info(p_detail_id IN NUMBER) IS
SELECT wda.delivery_id
  FROM WSH_DELIVERY_ASSIGNMENTS wda,
       WSH_NEW_DELIVERIES wnd
WHERE wda.delivery_detail_id = p_detail_id
  AND wda.delivery_id = wnd.delivery_id
  AND wnd.tms_interface_flag IN (WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS,
                                 WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS,
                                 WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
                                 WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED)
  AND NVL(wnd.ignore_for_planning, 'N') = 'N';

l_delivery_id          WSH_NEW_DELIVERIES.DELIVERY_ID%TYPE;
l_delivery_id_tab      WSH_UTIL_CORE.ID_TAB_TYPE;
l_interface_flag_tab   WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_count                NUMBER;
l_return_status        VARCHAR2(1);
-- End of OTM R12 : packing ECO

l_net_weight           NUMBER;
l_gross_weight         NUMBER;
l_volume               NUMBER;
l_fill_pc              NUMBER;
l_num_error            NUMBER := 0;
l_flag                 WSH_DELIVERY_DETAILS.CONTAINER_FLAG%TYPE;

others EXCEPTION;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DETAIL_WEIGHT_VOLUME';
--
BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'P_OVERRIDE_FLAG',P_OVERRIDE_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_CALC_WV_IF_FROZEN',P_CALC_WV_IF_FROZEN);
   END IF;

   IF (p_detail_rows.count = 0) THEN
    raise others;
   END IF;

   -- OTM R12 : packing ECO
   l_count := 0;
   -- End of OTM R12 : packing ECO

   FOR i IN 1..p_detail_rows.count LOOP

     -- OTM R12 : packing ECO
     -- for each detail in the loop, enable the check for delivery update
     IF (WSH_WV_UTILS.G_RESET_WV = 'Y') THEN

       OPEN c_get_delivery_info(p_detail_rows(i));
       FETCH c_get_delivery_info INTO l_delivery_id;

       IF (c_get_delivery_info%NOTFOUND) THEN
	 l_delivery_id := NULL;
       END IF;
       CLOSE c_get_delivery_info;

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'G_RESET_WV', WSH_WV_UTILS.G_RESET_WV);
         WSH_DEBUG_SV.log(l_module_name,'l_delivery_id', l_delivery_id);
       END IF;

       -- need to check for update only if delivery is include for planning and
       -- tms_interface_flag is in CP UP AW AR state, which will be set to UR
       IF l_delivery_id IS NOT NULL THEN
         G_DELIVERY_TMS_IMPACT := 'N';
       END IF;
     END IF;
     -- End of OTM R12 : packing ECO

     OPEN c_container_flag(p_detail_rows(i));
     FETCH c_container_flag INTO l_flag;
     IF c_container_flag%NOTFOUND THEN
       CLOSE c_container_flag;
       raise others;
     END IF;
     CLOSE c_container_flag;

     IF l_flag in ('Y', 'C') THEN

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit CONTAINER_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       Container_Weight_Volume (
         p_container_instance_id => p_detail_rows(i),
         p_override_flag         => p_override_flag,
         p_fill_pc_flag          => 'Y',
         p_post_process_flag     => 'Y',
         p_calc_wv_if_frozen     => p_calc_wv_if_frozen,
         x_gross_weight          => l_gross_weight,
         x_net_weight            => l_net_weight,
         x_volume                => l_volume,
         x_cont_fill_pc          => l_fill_pc,
         x_return_status         => x_return_status);

     ELSE

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       Detail_Weight_Volume(
         p_delivery_detail_id => p_detail_rows(i),
         p_update_flag        => p_override_flag,
         p_post_process_flag  => 'Y',
         p_calc_wv_if_frozen  => p_calc_wv_if_frozen,
         x_net_weight         => l_net_weight,
         x_volume             => l_volume,
         x_return_status      => x_return_status);

     END IF;  -- l_flag = 'Y'

     IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_DET_WT_VOL_ERROR');
       FND_MESSAGE.SET_TOKEN('DET_NAME',p_detail_rows(i));
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       wsh_util_core.add_message(x_return_status);
       l_num_error := l_num_error + 1;
     END IF;

     -- OTM R12 : packing ECO
     -- for the given delivery_id, G_DELIVERY_TMS_IMPACT is changed from N to Y
     IF (WSH_WV_UTILS.G_RESET_WV ='Y' AND
         G_DELIVERY_TMS_IMPACT = 'Y' AND
         l_delivery_id IS NOT NULL) THEN

       l_count := l_count + 1;
       l_delivery_id_tab(l_count) := l_delivery_id;
       l_interface_flag_tab(l_count) := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'l_count', l_count);
         WSH_DEBUG_SV.log(l_module_name, 'l_delivery_id_tab', l_delivery_id_tab(l_count));
         WSH_DEBUG_SV.log(l_module_name, 'l_interface_flag_tab', l_interface_flag_tab(l_count));
       END IF;
     END IF;

     --resetting the flag back to default after done with current detail
     IF (G_DELIVERY_TMS_IMPACT = 'N') THEN
       G_DELIVERY_TMS_IMPACT := 'Y';
     END IF;

     -- End of OTM R12 : packing ECO
   END LOOP;

   -- OTM R12 : packing ECO
   -- There can be the same delivery_id's in l_delivery_id_tab
   IF (l_count > 0) THEN
     WSH_NEW_DELIVERIES_PVT.update_tms_interface_flag(
                            p_delivery_id_tab        => l_delivery_id_tab,
                            p_tms_interface_flag_tab => l_interface_flag_tab,
                            x_return_status          => l_return_status);

     IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                             WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
       x_return_status := l_return_status;
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
         WSH_DEBUG_SV.pop(l_module_name, 'UPDATE_TMS_INTERFACE_FLAG ERROR');
       END IF;
       RETURN;
     END IF;
   END IF;
   -- End of OTM R12 : packing ECO

   IF (p_detail_rows.count > 1) THEN

    IF (l_num_error > 0) THEN

       FND_MESSAGE.SET_NAME('WSH','WSH_DEL_WT_VOL_SUMMARY');
       FND_MESSAGE.SET_TOKEN('NUM_ERROR',l_num_error);
       FND_MESSAGE.SET_TOKEN('NUM_SUCCESS',p_detail_rows.count - l_num_error);

       IF (p_detail_rows.count = l_num_error) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       ELSE
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       END IF;

       wsh_util_core.add_message(x_return_status);

    ELSE
       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;

   END IF;

   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
   WHEN others THEN
     -- OTM R12 : packing ECO
     IF (c_get_delivery_info%ISOPEN) THEN
       CLOSE c_get_delivery_info;
     END IF;
     -- End of OTM R12 : packing ECO
     wsh_util_core.default_handler ('WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END Detail_Weight_Volume;

PROCEDURE Calc_Cont_Fill_Pc (
 p_container_instance_id IN NUMBER,
 p_update_flag IN VARCHAR2,
 p_fill_pc_basis IN VARCHAR2,
 x_fill_percent OUT NOCOPY  NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2) IS


 CURSOR Get_Cont_Info (v_cont_instance_id NUMBER) IS
 SELECT inventory_item_id, gross_weight, net_weight,
 -- J: W/V Changes
        filled_volume,
        nvl(unit_weight,0),
   weight_uom_code, volume_uom_code, organization_id,
   maximum_load_weight, maximum_volume, fill_percent, container_flag, container_name,
   nvl(line_direction, 'O') line_direction, organization_id
 FROM wsh_delivery_details
 WHERE delivery_detail_id = v_cont_instance_id;

 CURSOR Get_Cont_Contents (v_cont_instance_id NUMBER, v_org_id NUMBER) IS
 SELECT wda.delivery_detail_id,container_flag,
      inventory_item_id,
      NVL(received_quantity,    -- J-IB-NPARIKH
          nvl(shipped_quantity, NVL(picked_quantity, requested_quantity))) pack_qty
 FROM wsh_delivery_assignments_v wda,
    wsh_delivery_details wdd
 WHERE wda.parent_delivery_detail_id = v_cont_instance_id AND
     wdd.delivery_detail_id = wda.delivery_detail_id;


 CURSOR Get_Fill_Basis (v_org_id NUMBER) IS
 SELECT percent_fill_basis_flag
 FROM wsh_shipping_parameters
 WHERE organization_id = v_org_id;

 l_cont_item_id      NUMBER;
 l_cont_gross_wt  NUMBER;
 l_cont_net_wt    NUMBER;
 l_cont_wt_uom    VARCHAR2(3);
 l_cont_vol    NUMBER;
 l_cont_unit_wt   NUMBER;
 l_cont_vol_uom      VARCHAR2(3);
 l_cont_max_load  NUMBER;
 l_cont_max_vol      NUMBER;
 l_cont_org_id       NUMBER;
 l_cont_fill_pc      NUMBER;
 l_cont_name         VARCHAR2(32767);

 l_dlvb_id     NUMBER;
 l_dlvb_det_id    NUMBER;
 l_dlvb_cont_id      NUMBER;
 l_dlvb_type      VARCHAR2(1);
 l_dlvb_del_id    NUMBER;
 l_dlvb_inv_id    NUMBER;
 l_dlvb_pack_qty  NUMBER;

 l_max_load_qty      NUMBER;
 l_cont_qty    NUMBER;
 l_fill_pc_basis  VARCHAR2(1);
 l_wt_uom      VARCHAR2(3);
 l_cont_flag      VARCHAR2(1);


-- LPN CONV. rv
l_line_direction  VARCHAR2(10);
l_organization_id NUMBER;
l_wms_org         VARCHAR2(10) := 'N';
l_sync_tmp_rec    wsh_glbl_var_strct_grp.sync_tmp_rec_type;
l_return_status   VARCHAR2(10);
l_num_warnings    NUMBER := 0;
-- LPN CONV. rv
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALC_CONT_FILL_PC';
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
     WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_FLAG',P_UPDATE_FLAG);
     WSH_DEBUG_SV.log(l_module_name,'P_FILL_PC_BASIS',P_FILL_PC_BASIS);
 END IF;
 --
 OPEN Get_Cont_Info (p_container_instance_id);

 FETCH Get_Cont_Info INTO
   l_cont_item_id,
   l_cont_gross_wt,
   l_cont_net_wt,
   l_cont_vol,
   l_cont_unit_wt,
   l_cont_wt_uom,
   l_cont_vol_uom,
   l_cont_org_id,
   l_cont_max_load,
   l_cont_max_vol,
   l_cont_fill_pc,
   l_cont_flag,
   l_cont_name,
   l_line_direction,
   l_organization_id;

 IF Get_Cont_Info%NOTFOUND THEN
   CLOSE Get_Cont_Info;
   FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return;
 END IF;

 CLOSE Get_Cont_Info;

 IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'Cont flag'||l_cont_flag);
 END IF;
 --
 -- Bug 3562797 jckwok
 -- Code to get fill percent basis moved up here because we want to check whether
 -- it is set to 'N' as early as possible.
 --
 l_fill_pc_basis := p_fill_pc_basis;

 IF l_fill_pc_basis IS NULL THEN
   OPEN Get_Fill_Basis (l_cont_org_id);
   FETCH Get_Fill_Basis INTO l_fill_pc_basis;
   IF Get_Fill_Basis%NOTFOUND THEN
      CLOSE Get_Fill_Basis;
      FND_MESSAGE.SET_NAME('WSH','WSH_FILL_BASIS_UNDEFINED');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
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
 END IF;
 --
 -- Debug Statements
 --
 IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'fill pc basis',l_fill_pc_basis);
 END IF;
 --
 -- If the Shipping Parameter Fill Basis is set to None, then simply return sucess and log a message.
 --
 IF (l_fill_pc_basis = 'N') THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Fill PC is not calculated because Fill Percent Basis flag is set to None');
       END IF;
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
 END IF;
 -- end of bug 3562797 changes

 IF (nvl(l_cont_flag,'N') = 'N') THEN
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

 IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'Cont item '||l_cont_item_id);
 END IF;
 /* wms change: Return Null if LPN is grouping  */
 IF (l_cont_item_id IS NULL) THEN
    x_return_status := NULL;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
 END IF;

 IF l_fill_pc_basis = 'W' THEN
   IF nvl(l_cont_max_load, 0 ) <= 0 THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_CONT_FILL_PC_ERROR');
     FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
     wsh_util_core.add_message(wsh_util_core.g_ret_sts_warning);
     RAISE WSH_UTIL_CORE.G_EXC_WARNING;
   END IF;
 ELSIF l_fill_pc_basis = 'V' THEN
   IF nvl(l_cont_max_vol, 0 ) <= 0 THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_CONT_FILL_PC_ERROR');
     FND_MESSAGE.SET_TOKEN('CONT_NAME',l_cont_name);
     wsh_util_core.add_message(wsh_util_core.g_ret_sts_warning);
     RAISE WSH_UTIL_CORE.G_EXC_WARNING;
   END IF;
 END IF;

 IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'Fill pc basis --'||l_fill_pc_basis);
 END IF;

 IF l_fill_pc_basis = 'W' THEN
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'max load --'||l_cont_max_load);
     WSH_DEBUG_SV.log(l_module_name,'gross wt --'||l_cont_gross_wt);
     WSH_DEBUG_SV.log(l_module_name,'net wt --'||l_cont_net_wt);
     WSH_DEBUG_SV.log(l_module_name,'Unit wt --'||l_cont_unit_wt);
   END IF;
   l_cont_fill_pc := (l_cont_gross_wt - l_cont_unit_wt)/l_cont_max_load;
 ELSIF l_fill_pc_basis = 'V' THEN
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'max vol --'||l_cont_max_vol);
     WSH_DEBUG_SV.log(l_module_name,'volume --'||l_cont_vol);
   END IF;
   l_cont_fill_pc := l_cont_vol/l_cont_max_vol;
 ELSIF l_fill_pc_basis = 'Q' THEN

   l_cont_fill_pc := 0;

   FOR dlvb IN Get_Cont_Contents (p_container_instance_id, l_cont_org_id) LOOP

       IF (nvl(dlvb.container_flag,'N') <> 'Y') THEN

--   WSH_CONTAINER_UTILITIES.Estimate_Detail_Containers (
--   replacing with TPA enabled API..

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_CONTAINER_PKG.ESTIMATE_DETAIL_CONTAINERS',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_TPA_CONTAINER_PKG.Estimate_Detail_Containers (
         p_container_instance_id,
         l_cont_item_id,
         dlvb.delivery_detail_id,
         l_cont_org_id,
         l_cont_qty,
         x_return_status);

     IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      -- dbms_output.put_line('error in estimating detail cont');
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      return;
     END IF;

     l_cont_fill_pc := l_cont_fill_pc + l_cont_qty;

   ELSIF dlvb.container_flag = 'Y' THEN

--    WSH_CONTAINER_UTILITIES.Estimate_Master_Containers (
--    replacing with TPA enabled API..

     -- dbms_output.put_line('calling estimate master with  ' || p_container_instance_id);

     -- AP Rewrite : Change p_container_instance_id to dlvb.delivery_detail_id
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_CONTAINER_PKG.ESTIMATE_MASTER_CONTAINERS',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_TPA_CONTAINER_PKG.Estimate_Master_Containers (
         dlvb.delivery_detail_id,
         l_cont_item_id,
         dlvb.inventory_item_id,
         l_cont_org_id,
         l_cont_qty,
         x_return_status);

      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      -- dbms_output.put_line('error in estimating master cont');
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
      END IF;

     l_cont_fill_pc := l_cont_fill_pc + l_cont_qty;

   END IF;

   END LOOP;

 ELSE

    FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_FILL_BASIS');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;

 END IF;  -- fill pc basis check

  -- bug 1748609: increase precision to improve accuracy
  -- of auto-packing and packing workbench with packing
  -- partially filled containers.
 x_fill_percent := ROUND((100*l_cont_fill_pc),6);

 IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'Fill pc--'||x_fill_percent);
 END IF;
-- dbms_output.put_line('fill percent is ' || x_fill_percent);

 -- J: W/V Changes
 IF p_update_flag = 'Y' THEN

   -- K LPN CONV. rv
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'line direction', l_line_direction);
       WSH_DEBUG_SV.log(l_module_name,'Organization Id', l_organization_id);
   END IF;
   --
   l_wms_org := wsh_util_validate.check_wms_org(l_organization_id);
   --
   IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
   AND l_line_direction IN ('O','IO')
   AND l_cont_flag = 'Y'
   AND
   (
     (WSH_WMS_LPN_GRP.GK_WMS_UPD_FILL and l_wms_org = 'Y')
     OR
     (WSH_WMS_LPN_GRP.GK_INV_UPD_FILL and l_wms_org = 'N')
   )
   THEN
   --{
       l_sync_tmp_rec.delivery_detail_id := p_container_instance_id;
       l_sync_tmp_rec.operation_type := 'UPDATE';
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       WSH_WMS_SYNC_TMP_PKG.MERGE
       (
         p_sync_tmp_rec      => l_sync_tmp_rec,
         x_return_status     => l_return_status
       );

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Return Status after calling WSH_WMS_SYNC_TMP_PKG.MERGE',l_return_status);
       END IF;
       --
       IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
         --
         x_return_status := l_return_status;
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'WSH_WMS_SYNC_TMP_PKG.MERGE completed with an error');
           WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
         --
       ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         --
         l_num_warnings := l_num_warnings + 1;
         --
       END IF;
   --}
   END IF;
   -- K LPN CONV. rv
   UPDATE WSH_DELIVERY_DETAILS
   SET fill_percent = x_fill_percent
   WHERE delivery_detail_id = p_container_instance_id;

   IF SQL%NOTFOUND THEN
      -- dbms_output.put_line('unexp error while updating fill percent');
      FND_MESSAGE.SET_NAME('WSH','WSH_UNEXP_ERROR');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
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

 -- LPN CONV. rv
 IF (l_num_warnings > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   --
 ELSE
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   --
 END IF;
 -- LPN CONV. rv

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
      WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
      WHEN Others THEN
       WSH_UTIL_CORE.Default_Handler ('WSH_WV_UTILS.CALC_CONT_FILL_PC');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Calc_Cont_Fill_Pc;


PROCEDURE Container_Tare_Weight_Self (
 p_container_instance_id IN NUMBER,
 p_cont_item_id IN NUMBER,
 p_wt_uom IN VARCHAR2,
 p_organization_id IN NUMBER,
 x_cont_tare_wt OUT NOCOPY  NUMBER,
 x_return_status OUT NOCOPY  VARCHAR2) IS

 CURSOR Get_Unit_Weight (v_cont_item_id NUMBER, v_org_id NUMBER) IS
 SELECT unit_weight, weight_uom_code
 FROM mtl_system_items
 WHERE inventory_item_id = v_cont_item_id
 AND organization_id = v_org_id;

 CURSOR Get_Cont_Info (v_cont_inst_id NUMBER) IS
 SELECT inventory_item_id, weight_uom_code, organization_id
 FROM wsh_delivery_details
 WHERE delivery_detail_id = v_cont_inst_id AND
     container_flag = 'Y';

 l_cont_item_id NUMBER;
 l_cont_org_id NUMBER;
 l_cont_unit_wt NUMBER;
 l_cont_wt_uom VARCHAR2(3);
 l_wt_uom VARCHAR2(3);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONTAINER_TARE_WEIGHT_SELF';
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
     WSH_DEBUG_SV.log(l_module_name,'P_CONT_ITEM_ID',P_CONT_ITEM_ID);
     WSH_DEBUG_SV.log(l_module_name,'P_WT_UOM',P_WT_UOM);
     WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
 END IF;
 --
 IF p_container_instance_id IS NOT NULL THEN

     OPEN Get_Cont_Info (p_container_instance_id);

     FETCH Get_Cont_Info INTO l_cont_item_id, l_cont_wt_uom, l_cont_org_id;

     IF Get_Cont_Info%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
   CLOSE Get_Cont_Info;
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return;
     END IF;

     CLOSE Get_Cont_Info;

 ELSIF p_cont_item_id IS NULL OR p_organization_id IS NULL THEN

      FND_MESSAGE.SET_NAME('WSH','WSH_NO_CONT_OR_ORG');
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return;

 END IF;

 OPEN Get_Unit_Weight (nvl(p_cont_item_id,l_cont_item_id), nvl(p_organization_id,l_cont_org_id));

 FETCH Get_Unit_Weight INTO l_cont_unit_wt, l_wt_uom;

 IF Get_Unit_Weight%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONT_ITEM');
      CLOSE Get_Unit_Weight;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
 END IF;

 CLOSE Get_Unit_Weight;

 --
 -- Debug Statements
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM',WSH_DEBUG_SV.C_PROC_LEVEL);
     WSH_DEBUG_SV.log(l_module_name,'wt uom'||l_wt_uom);
     WSH_DEBUG_SV.log(l_module_name,'cont unit wt'||l_cont_unit_wt);
 END IF;
 --
 x_cont_tare_wt := WSH_WV_UTILS.Convert_Uom(l_wt_uom, nvl(p_wt_uom,l_cont_wt_uom),l_cont_unit_wt,nvl(p_cont_item_id, l_cont_item_id));

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
       WSH_UTIL_CORE.Default_Handler ('WSH_WV_UTILS.CONTAINER_TARE_WEIGHT_SELF');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Container_Tare_Weight_Self;

--
-- Procedure:   Check Fill PC
-- Parameters:  p_container_instance_id - container instance id of container
--              p_calculation_flag - w/v calculation flag, 'Y' for Automatic and 'N' for Manual
--              x_fill_status - fill status of container - 'Overpacked',
--              'Underpacked',or 'Success' (returns 'O','U' or 'S')
--              x_return_status - status of procedure call
-- Description: This procedure will check the fill status of container by
--              comparing the fill pc with min fill pc. If fill pc < min fill
--              pc then it is underpacked. If fill pc > 100 then overpacked
--              else 'Success'.
--

PROCEDURE Check_Fill_Pc (
      p_container_instance_id IN NUMBER,
      p_calc_wt_vol_flag IN VARCHAR2 DEFAULT 'Y', -- bug 2790656
      x_fill_status OUT NOCOPY  VARCHAR2,
      x_return_status OUT NOCOPY  VARCHAR2) IS

 /* wms - change : to check for LPN grouping, added inventory_item_id */
 CURSOR Get_Cont_Info IS
 SELECT fill_percent, minimum_fill_percent, inventory_item_id, organization_id
 FROM WSH_DELIVERY_DETAILS
 WHERE delivery_detail_id = p_container_instance_id AND
     container_flag = 'Y';

 l_fill_pc NUMBER;
 l_min_fill_pc NUMBER;
 l_cont_item_id NUMBER;
 l_organization_id NUMBER;
 l_param_info  WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;

 l_gr_wt NUMBER;
 l_net_wt NUMBER;
 l_vol NUMBER;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_FILL_PC';
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
 IF p_container_instance_id IS NOT NULL
 THEN
 --{
 OPEN Get_Cont_Info;

 FETCH Get_Cont_Info INTO
 l_fill_pc,
 l_min_fill_pc,
 l_cont_item_id,
 l_organization_id;

 IF Get_Cont_Info%NOTFOUND THEN
    CLOSE Get_Cont_Info;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONTAINER');
    WSH_UTIL_CORE.Add_Message (x_return_status);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
 END IF;

 /* wms change: if groupin is LPN , always return success */
 IF (l_cont_item_id IS NULL) THEN
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

 CLOSE Get_Cont_Info;

 --Bug 3562797 jckwok
 WSH_SHIPPING_PARAMS_PVT.Get(
       p_organization_id => l_organization_id,
       x_param_info      => l_param_info,
       x_return_status   => x_return_status);
 IF x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
    FND_MESSAGE.Set_Name('WSH', 'WSH_PARAM_NOT_DEFINED');
    FND_MESSAGE.Set_Token('ORGANIZAION_CODE',
                          wsh_util_core.get_org_name(l_organization_id));
    wsh_util_core.add_message(x_return_status,l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_SHIPPING_PARAMS_PVT.Get returned '||x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    return;
 END IF;

 --
 -- Debug Statements
 --
 IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'fill pc basis', l_param_info.percent_fill_basis_flag);
 END IF;
 --
 -- If the Shipping Parameter Fill Basis is set to None, then simply return success and log a message.
 --
 IF (l_param_info.percent_fill_basis_flag = 'N') THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_fill_status := 'S';
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
 END IF;
 --Bug 3562797 jckwok


 IF l_fill_pc < nvl(l_min_fill_pc,0) THEN
   x_fill_status := 'U';
 ELSIF l_fill_pc > 100 THEN
   x_fill_status := 'O';
 ELSE
   x_fill_status := 'S';
 END IF;

 --}
 ELSE
 --{
     x_fill_status := 'S';
 --}
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
       WSH_UTIL_CORE.Default_Handler ('WSH_WV_UTILS.CHECK_FILL_PC');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Fill_Pc;

-- J: W/V changes

-- Start of comments
-- API name : Delivery_Weight_Volume
-- Type     : Public
-- Pre-reqs : None.
-- Function : Calculates Weight and Volume of Delivery
--            If p_update_flag is 'Y' then the calculated W/V is updated on
--            Delivery. Otherwise, the API returns the calculated W/V
--            If p_calc_wv_if_frozen is 'N' then manually entered W/V will not
--            be overwritten with calculated W/V
--            OTM R12 : packing ECO
--                      This procedure is modified to keep track of delivery
--                      detail wt/vol updates.  logic of checking G_RESET_WV
--
-- Parameters :
-- IN:
--    p_delivery_id  IN NUMBER Required
--    p_update_flag  IN VARCHAR2
--      'Y' if the delivery needs to be updated with the calculated W/V
--    p_calc_wv_if_frozen  IN VARCHAR2
--      'Y' if manual W/V can be overriden
-- OUT:
--    x_gross_weight OUT NUMBER
--       gives the gross weight of delivery
--    x_net_weight OUT NUMBER
--       gives the net weight of delivery
--    x_volume OUT NUMBER
--       gives the volume of delivery
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Delivery_Weight_Volume(
        p_delivery_id    IN NUMBER,
        p_update_flag    IN VARCHAR2,
        p_calc_wv_if_frozen IN VARCHAR2,
        x_gross_weight   OUT NOCOPY  NUMBER,
        x_net_weight     OUT NOCOPY  NUMBER,
        x_volume         OUT NOCOPY  NUMBER,
        x_return_status  OUT NOCOPY  VARCHAR2) IS

  CURSOR loose_detail_wt_vol IS
  SELECT wdd.delivery_detail_id dd_id,
         wdd.gross_weight gross_wt,
         wdd.net_weight net_wt,
         wdd.volume vol,
         wdd.inventory_item_id,
         wdd.weight_uom_code wt_uom,
         wdd.volume_uom_code vol_uom
  FROM   wsh_delivery_details     wdd,
         wsh_delivery_assignments_v wda
  WHERE  wdd.delivery_detail_id = wda.delivery_detail_id AND
         wda.delivery_id = p_delivery_id AND
         wda.delivery_id IS NOT NULL AND
         wdd.container_flag = 'N' AND
         wda.parent_delivery_detail_id IS NULL;

  CURSOR del_containers IS
  SELECT distinct(dd.delivery_detail_id) c_id,
         dd.gross_weight gr_wt,
         dd.net_weight   net_wt,
         dd.volume vol,
         dd.inventory_item_id inventory_item_id,
         dd.weight_uom_code wt_uom,
         dd.volume_uom_code vol_uom
  FROM   wsh_delivery_assignments_v da,
         wsh_delivery_details dd
  WHERE  da.delivery_id = p_delivery_id AND
         da.delivery_id IS NOT NULL AND
         da.delivery_detail_id = dd.delivery_detail_id AND
         dd.container_flag = 'Y' AND
         da.parent_delivery_detail_id IS NULL;

  CURSOR del_uoms IS
  SELECT weight_uom_code,
         volume_uom_code,
         organization_id,
         gross_weight,
         net_weight,
         volume,
         NVL(wv_frozen_flag,'Y'),
         delivery_type,
         NVL(ignore_for_planning, 'N'),    -- OTM R12 : packing ECO
         tms_interface_flag                -- OTM R12 : packing ECO
  FROM   wsh_new_deliveries
  WHERE  delivery_id = p_delivery_id;


  -- MDC: calculate the wt/vol of the child deliveries

  CURSOR c_child_deliveries(p_delivery_id IN NUMBER) IS
  SELECT d.weight_uom_code wt_uom,
         d.volume_uom_code vol_uom,
         d.delivery_id del_id
  FROM   wsh_delivery_legs l1,
         wsh_delivery_legs l2,
         wsh_new_deliveries d
  WHERE  l1.delivery_id = p_delivery_id
  AND    l1.delivery_leg_id = l2.parent_delivery_leg_id
  AND    l2.delivery_id = d.delivery_id;

  -- MDC: Get the consol LPNs attached to the delivery
  CURSOR c_consol_lpns(p_delivery_id in NUMBER) IS
  select da.delivery_detail_id,
         dd.gross_weight gr_wt,
         dd.volume vol,
         dd.inventory_item_id inventory_item_id,
         dd.weight_uom_code wt_uom,
         dd.volume_uom_code vol_uom
  from wsh_delivery_details dd, wsh_delivery_assignments da
  where dd.delivery_detail_id = da.delivery_detail_id
  and   dd.container_flag = 'C'
  and   NVL(da.type, 'S') = 'S'
  and   da.delivery_id = p_delivery_id
  and   da.delivery_id is not null;


  -- MDC: calculate the wt/vol of the consol LPNs
  -- topmost children

  CURSOR c_top_child_lpns(p_consol_lpn in NUMBER) IS
  SELECT dd.delivery_detail_id,
         dd.gross_weight gr_wt,
         dd.net_weight   net_wt,
         dd.volume vol,
         dd.inventory_item_id inventory_item_id,
         dd.weight_uom_code wt_uom,
         dd.volume_uom_code vol_uom
  FROM   wsh_delivery_assignments da,
         wsh_delivery_details dd
  WHERE  da.parent_delivery_detail_id = p_consol_lpn AND
         da.delivery_detail_id = dd.delivery_detail_id AND
         da.type = 'C';

  l_weight_uom_code   VARCHAR2(10);
  l_volume_uom_code   VARCHAR2(10);
  l_organization_id   NUMBER;
  l_del_gross_wt      NUMBER;
  l_del_net_wt        NUMBER;
  l_del_vol           NUMBER;
  l_wv_frozen_flag    VARCHAR2(1);
  l_delivery_type     VARCHAR2(30);

  loose_gross_weight  NUMBER;
  loose_net_weight    NUMBER;
  loose_volume        NUMBER;
  l_gross_weight      NUMBER;
  l_net_weight        NUMBER;
  l_volume            NUMBER;

  l_cont_gross_weight NUMBER;
  l_cont_net_weight   NUMBER;
  l_cont_volume       NUMBER;
  l_cont_fill_pc      NUMBER;

  -- MDC
  child_del_gross_weight  NUMBER;
  child_del_net_weight    NUMBER;
  child_del_volume        NUMBER;

  consol_lpn_gross_weight  NUMBER :=0;
  consol_lpn_net_weight    NUMBER :=0;
  consol_lpn_tare_weight   NUMBER :=0;
  consol_lpn_volume        NUMBER;

  l_num_warnings      NUMBER := 0;
  l_return_status     VARCHAR2(100);
  l_param_info        WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;

  l_debug_on          BOOLEAN;
  l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_WEIGHT_VOLUME';

  e_abort             exception;

  -- OTM R12 : packing ECO
  l_ignore_for_planning   WSH_NEW_DELIVERIES.IGNORE_FOR_PLANNING%TYPE;
  l_tms_interface_flag    WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE;
  l_delivery_id_tab       WSH_UTIL_CORE.ID_TAB_TYPE;
  l_interface_flag_tab    WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  -- End of OTM R12 : packing ECO

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_FLAG',P_UPDATE_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_CALC_WV_IF_FROZEN',P_CALC_WV_IF_FROZEN);
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Get the delivery info
  OPEN  del_uoms;
  FETCH del_uoms
  INTO  l_weight_uom_code,
        l_volume_uom_code,
        l_organization_id,
        l_del_gross_wt,
        l_del_net_wt,
        l_del_vol,
        l_wv_frozen_flag,
        l_delivery_type,
        l_ignore_for_planning,        -- OTM R12 : packing ECO
        l_tms_interface_flag;         -- OTM R12 : packing ECO
  IF (del_uoms%NOTFOUND) THEN
    CLOSE del_uoms;
    FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_DELIVERY');
    FND_MESSAGE.SET_TOKEN('DELIVERY',p_delivery_id);
    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Delivery '||p_delivery_id||' not found');
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  END IF;
  CLOSE del_uoms;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Delivery original wts are Gross '||l_del_gross_wt||' Net '||l_del_net_wt||' Vol '||l_del_vol||' Frozen '||l_wv_frozen_flag);
    WSH_DEBUG_SV.log(l_module_name,'Org '||l_organization_id||' Wt Code '||l_weight_uom_code||' Vol Code '||l_volume_uom_code);
    WSH_DEBUG_SV.log(l_module_name, 'Ignore_for_planning '||l_ignore_for_planning);
    WSH_DEBUG_SV.log(l_module_name, 'tms_interface_flag '||l_tms_interface_flag);
  END IF;

  IF p_calc_wv_if_frozen = 'N' AND l_wv_frozen_flag = 'Y' THEN
    x_gross_weight := l_del_gross_wt;
    x_net_weight   := l_del_net_wt;
    x_volume       := l_del_vol;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Delivery W/V is frozen. Returning');
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  END IF;

  -- Get the Shipping parameters of DD's organization
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.Get',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  WSH_SHIPPING_PARAMS_PVT.Get(
    p_organization_id => l_organization_id,
    x_param_info      => l_param_info,
    x_return_status   => l_return_status);

  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_SHIPPING_PARAMS_PVT.Get returned '||l_return_status);
    END IF;
    FND_MESSAGE.Set_Name('WSH', 'WSH_PARAM_NOT_DEFINED');
    FND_MESSAGE.Set_Token('ORGANIZAION_CODE',
                wsh_util_core.get_org_name(l_organization_id));
    wsh_util_core.add_message(l_return_status,l_module_name);
    raise e_abort;
  END IF;


  -- OTM R12 : packing ECO

  -- for the delivery, enable the check for delivery update
  -- need to check for update only if delivery is include for planning and
  -- tms_interface_flag is in CP UP AW AR state, which will be set to UR
  IF (WSH_WV_UTILS.G_RESET_WV ='Y' AND
      l_ignore_for_planning = 'N' AND
      l_tms_interface_flag IN
                          (WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS,
                           WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS,
                           WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
                           WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED)) THEN
    -- setting this will impact the detail_weight_volume,
    -- container_weight_volume calls later
    G_DELIVERY_TMS_IMPACT := 'N';
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'G_DELIVERY_TMS_IMPACT', G_DELIVERY_TMS_IMPACT);
  END IF;
  -- End of OTM R12 : packing ECO


  -- MDC: Calculate wt/vol for consolidation deliveries

  IF l_delivery_type = 'CONSOLIDATION' THEN

     -- For all child_del items in delivery
     FOR del IN c_child_deliveries(p_delivery_id) LOOP

       l_gross_weight := NULL;
       l_net_weight   := NULL;
       l_volume       := NULL;

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Processing Delivery '||del.del_id);
       END IF;

       -- Call Delivery WV API to calculate delivery W/V
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DELIVERY_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       Delivery_Weight_Volume(
        p_delivery_id       => del.del_id,
        p_update_flag       => p_update_flag,
        p_calc_wv_if_frozen => p_calc_wv_if_frozen,
        x_gross_weight      => l_gross_weight,
        x_net_weight        => l_net_weight,
        x_volume            => l_volume,
        x_return_status     => x_return_status);


       IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         RETURN;
       END IF;


       -- Convert the W/V if UOMs differ and then accumulate W/V
       IF (del.wt_uom <> l_weight_uom_code) THEN
         IF (l_gross_weight > 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM for converting Gross',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           child_del_gross_weight := NVL(child_del_gross_weight,0) +
                                 WSH_WV_UTILS.convert_uom(del.wt_uom, l_weight_uom_code, l_gross_weight);
         ELSIF (l_gross_weight = 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'adding l_gross_wt=0',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           child_del_gross_weight := NVL(child_del_gross_weight,0) + l_gross_weight;
         END IF;

         IF (l_net_weight > 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM for converting Net',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           child_del_net_weight := NVL(child_del_net_weight,0) +
                               WSH_WV_UTILS.convert_uom(del.wt_uom, l_weight_uom_code, l_net_weight);
         ELSIF (l_net_weight = 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'adding l_net_wt=0',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           child_del_net_weight := NVL(child_del_net_weight,0) + l_net_weight;
         END IF;
       ELSE
         IF (l_gross_weight >= 0) THEN
           child_del_gross_weight := NVL(child_del_gross_weight,0) + l_gross_weight;
         END IF;
         IF (l_net_weight >= 0) THEN
           child_del_net_weight := NVL(child_del_net_weight,0) + l_net_weight;
         END IF;
       END IF;

       IF (del.vol_uom <> l_volume_uom_code) THEN
         IF (l_volume > 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM for converting Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           child_del_volume := NVL(child_del_volume,0) +
                           WSH_WV_UTILS.convert_uom(del.vol_uom, l_volume_uom_code, l_volume);
         ELSIF (l_volume = 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'adding l_volume=0',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           child_del_volume := NVL(child_del_volume,0) + l_volume;
         END IF;
       ELSE
         IF (l_volume >= 0) THEN
           child_del_volume := NVL(child_del_volume,0) + l_volume;
         END IF;
       END IF;

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'child_del_net_weight',child_del_net_weight);
         WSH_DEBUG_SV.log(l_module_name,'child_del_gross_weight',child_del_gross_weight);
         WSH_DEBUG_SV.log(l_module_name,'consol_lpn_tare_weight',consol_lpn_tare_weight);
         WSH_DEBUG_SV.log(l_module_name,'consol_lpn_volume',consol_lpn_volume);
         WSH_DEBUG_SV.log(l_module_name,'child_del_volume',child_del_volume);
       END IF;
     END LOOP;

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'after loop for child dels');
       WSH_DEBUG_SV.log(l_module_name,'child_del_net_weight',child_del_net_weight);
       WSH_DEBUG_SV.log(l_module_name,'child_del_gross_weight',child_del_gross_weight);
       WSH_DEBUG_SV.log(l_module_name,'consol_lpn_tare_weight',consol_lpn_tare_weight);
       WSH_DEBUG_SV.log(l_module_name,'consol_lpn_volume',consol_lpn_volume);
       WSH_DEBUG_SV.log(l_module_name,'child_del_volume',child_del_volume);
     END IF;


     -- K: MDC: We need to calculate the empty tare weight of the consol LPNs.
     -- Since the gross weights of the consol LPNs children have already been
     -- been added when adding up the weights of the child deliveries, we
     -- need to add only the weight of the empty consol LPN to the consol delivery's
     -- gross weight here.
     -- The consol LPNs net weight for the purpose of calculating its empty tare weight
     -- is considered to be the some of the gross weights of its topmost contents.
     FOR consol_lpn in c_consol_lpns(p_delivery_id) LOOP

       FOR lpn IN c_top_child_lpns(consol_lpn.delivery_detail_id) LOOP

         l_cont_gross_weight := NULL;
         l_cont_net_weight   := NULL;
         l_cont_volume       := NULL;

         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Processing Cont '||lpn.delivery_detail_id);
         END IF;

/**
         -- Call WSH_TPA_CONTAINER_PKG.container_weight_volume API to calculate Container W/V
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit CONTAINER_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         Container_Weight_Volume (
         p_container_instance_id => lpn.delivery_detail_id,
         p_override_flag         => p_update_flag,
         p_fill_pc_flag          => 'Y',
         p_post_process_flag     => 'N',
         p_calc_wv_if_frozen     => p_calc_wv_if_frozen,
         x_gross_weight          => l_cont_gross_weight,
         x_net_weight            => l_cont_net_weight,
         x_volume                => l_cont_volume,
         x_cont_fill_pc          => l_cont_fill_pc,
         x_return_status         => x_return_status);

         IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
         END IF;
**/

         l_cont_gross_weight := lpn.gr_wt;
         l_cont_net_weight := lpn.net_wt;
         l_cont_volume := lpn.vol;

         -- Convert the W/V if UOMs differ and then accumulate W/V
         IF (lpn.wt_uom <> l_weight_uom_code) THEN
           IF (l_cont_gross_weight > 0) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM for converting Gross',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             consol_lpn_net_weight := NVL(consol_lpn_net_weight,0) +
                        WSH_WV_UTILS.convert_uom(lpn.wt_uom, l_weight_uom_code, l_cont_gross_weight, lpn.inventory_item_id);
           ELSIF (l_cont_gross_weight = 0) THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'adding l_cont_gross_weight=0',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             consol_lpn_net_weight := NVL(consol_lpn_net_weight,0) + l_cont_gross_weight;
           END IF;
         ELSE
           IF (l_cont_gross_weight >= 0) THEN
             consol_lpn_net_weight := NVL(consol_lpn_net_weight,0) + l_cont_gross_weight;
           END IF;
         END IF;

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Accumulated Net '||consol_lpn_net_weight);
         END IF;

       END LOOP;

       -- MDC: Get the total gross weight of the consol LPN, calculate its empty tare weight

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit CONTAINER_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       l_cont_gross_weight := NULL;
       l_cont_net_weight   := NULL;
       l_cont_volume       := NULL;

       Container_Weight_Volume (
         p_container_instance_id => consol_lpn.delivery_detail_id,
         p_override_flag         => p_update_flag,
         p_fill_pc_flag          => 'Y',
         p_post_process_flag     => 'N',
         p_calc_wv_if_frozen     => p_calc_wv_if_frozen,
         x_gross_weight          => l_cont_gross_weight,
         x_net_weight            => l_cont_net_weight,
         x_volume                => l_cont_volume,
         x_cont_fill_pc          => l_cont_fill_pc,
         x_return_status         => x_return_status);

       IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
         IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         RETURN;
       END IF;

       IF (consol_lpn.wt_uom <> l_weight_uom_code) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM for converting Gross',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          IF (l_cont_gross_weight > 0) THEN
             consol_lpn_gross_weight := NVL(consol_lpn_gross_weight,0) +
                     WSH_WV_UTILS.convert_uom(consol_lpn.wt_uom, l_weight_uom_code, l_cont_gross_weight, consol_lpn.inventory_item_id);
          ELSE
             consol_lpn_gross_weight := NVL(consol_lpn_gross_weight,0);
          END IF;
       ELSE
         IF (consol_lpn.gr_wt >= 0) THEN
           consol_lpn_gross_weight := NVL(consol_lpn_gross_weight,0) + l_cont_gross_weight;
         END IF;
       END IF;
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Accumulated Gross '||consol_lpn_gross_weight);
       END IF;

       consol_lpn_tare_weight := consol_lpn_tare_weight + (consol_lpn_gross_weight - consol_lpn_net_weight);

       IF (consol_lpn.vol_uom <> l_volume_uom_code) THEN
         IF (l_cont_volume > 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM for converting Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           consol_lpn_volume := NVL(consol_lpn_volume,0) +
                           WSH_WV_UTILS.convert_uom(consol_lpn.vol_uom, l_volume_uom_code, l_cont_volume);
         ELSIF (consol_lpn.vol = 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'adding l_volume=0',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           consol_lpn_volume := NVL(consol_lpn_volume,0);
         END IF;
       ELSE
         IF (consol_lpn.vol >= 0) THEN
           consol_lpn_volume := NVL(consol_lpn_volume,0) + NVL(l_cont_volume, 0);
         END IF;
       END IF;

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'inside consol lpn loop');
         WSH_DEBUG_SV.log(l_module_name,'child_del_net_weight',child_del_net_weight);
         WSH_DEBUG_SV.log(l_module_name,'child_del_gross_weight',child_del_gross_weight);
         WSH_DEBUG_SV.log(l_module_name,'consol_lpn_tare_weight',consol_lpn_tare_weight);
         WSH_DEBUG_SV.log(l_module_name,'consol_lpn_volume',consol_lpn_volume);
         WSH_DEBUG_SV.log(l_module_name,'child_del_volume',child_del_volume);
       END IF;

     END LOOP;

     -- Since the sum net weights of the child deliveries would already include the
     -- net weights of the consol LPNs we need to add up only the tare weight of the
     -- consol LPN to the gross weight of the consol delivery.
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'after consol lpn loop');
       WSH_DEBUG_SV.log(l_module_name,'child_del_net_weight',child_del_net_weight);
       WSH_DEBUG_SV.log(l_module_name,'child_del_gross_weight',child_del_gross_weight);
       WSH_DEBUG_SV.log(l_module_name,'consol_lpn_tare_weight',consol_lpn_tare_weight);
       WSH_DEBUG_SV.log(l_module_name,'consol_lpn_volume',consol_lpn_volume);
       WSH_DEBUG_SV.log(l_module_name,'child_del_volume',child_del_volume);
     END IF;

     x_net_weight   := child_del_net_weight;
     x_gross_weight := child_del_gross_weight + NVL(consol_lpn_tare_weight, 0);
     x_volume       := NVL(consol_lpn_volume,child_del_volume);
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'After accumulating all child_del items: Gross '||child_del_gross_weight||' Net '||child_del_net_weight||' Vol '||child_del_volume);
       WSH_DEBUG_SV.logmsg(l_module_name,'calculated wt/vol for consol delivery');
     END IF;

  ELSE  -- IF l_delivery_type = 'STANDARD' THEN

     -- For all loose items in delivery
     FOR dt IN loose_detail_wt_vol LOOP

       l_gross_weight := NULL;
       l_net_weight   := NULL;
       l_volume       := NULL;

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Processing DD '||dt.dd_id);
       END IF;

       -- Call detail_weight_volume API to calculate detail W/V
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DETAIL_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       WSH_WV_UTILS.detail_weight_volume(
         p_delivery_detail_id => dt.dd_id,
         p_update_flag        => p_update_flag,
         p_calc_wv_if_frozen  => p_calc_wv_if_frozen,
         x_net_weight         => l_net_weight,
         x_volume             => l_volume,
         x_return_status      => x_return_status);

       IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         RETURN;
       END IF;
       l_gross_weight := l_net_weight;

        -- Raise warning if delivery detail has null W/V depending on percent_fill_basis_flag
       IF (l_param_info.percent_fill_basis_flag = 'W' AND l_net_weight IS NULL) OR
          (l_param_info.percent_fill_basis_flag = 'V' AND l_volume IS NULL) THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_NULL_WEIGHT_VOLUME');
         FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL',dt.dd_id);
         wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING);
         l_num_warnings := l_num_warnings + 1;
       END IF;

       -- Convert the W/V if UOMs differ and then accumulate W/V
       IF (dt.wt_uom <> l_weight_uom_code) THEN
         IF (l_gross_weight > 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM for converting Gross',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           loose_gross_weight := NVL(loose_gross_weight,0) +
                              WSH_WV_UTILS.convert_uom(dt.wt_uom, l_weight_uom_code, l_gross_weight, dt.inventory_item_id);
         ELSIF (l_gross_weight = 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'adding l_gross_wt=0',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           loose_gross_weight := NVL(loose_gross_weight,0) + l_gross_weight;
         END IF;

         IF (l_net_weight > 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM for converting Net',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           loose_net_weight := NVL(loose_net_weight,0) +
                               WSH_WV_UTILS.convert_uom(dt.wt_uom, l_weight_uom_code, l_net_weight, dt.inventory_item_id);
         ELSIF (l_net_weight = 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'adding l_net_wt=0',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           loose_net_weight := NVL(loose_net_weight,0) + l_net_weight;
         END IF;
       ELSE
         IF (l_gross_weight >= 0) THEN
           loose_gross_weight := NVL(loose_gross_weight,0) + l_gross_weight;
         END IF;
         IF (l_net_weight >= 0) THEN
           loose_net_weight := NVL(loose_net_weight,0) + l_net_weight;
         END IF;
       END IF;

       IF (dt.vol_uom <> l_volume_uom_code) THEN
         IF (l_volume > 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM for converting Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           loose_volume := NVL(loose_volume,0) +
                           WSH_WV_UTILS.convert_uom(dt.vol_uom, l_volume_uom_code, l_volume, dt.inventory_item_id);
         ELSIF (l_volume = 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'adding l_volume=0',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           loose_volume := NVL(loose_volume,0) + l_volume;
         END IF;
       ELSE
         IF (l_volume >= 0) THEN
           loose_volume := NVL(loose_volume,0) + l_volume;
         END IF;
       END IF;

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Accumulated Gross '||loose_gross_weight||' Net '||loose_net_weight||' Vol '||loose_volume);
       END IF;
     END LOOP;

     x_net_weight   := loose_net_weight;
     x_gross_weight := loose_gross_weight;
     x_volume       := loose_volume;
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'After accumulating all loose items: Gross '||loose_gross_weight||' Net '||loose_net_weight||' Vol '||loose_volume);
     END IF;

     -- For all containers in delivery
     FOR wci IN del_containers LOOP

       l_cont_gross_weight := NULL;
       l_cont_net_weight   := NULL;
       l_cont_volume       := NULL;

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Processing Cont '||wci.c_id);
       END IF;

       -- Call WSH_TPA_CONTAINER_PKG.container_weight_volume API to calculate Container W/V
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit CONTAINER_WEIGHT_VOLUME',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       Container_Weight_Volume (
         p_container_instance_id => wci.c_id,
         p_override_flag         => p_update_flag,
         p_fill_pc_flag          => 'Y',
         p_post_process_flag     => 'N',
         p_calc_wv_if_frozen     => p_calc_wv_if_frozen,
         x_gross_weight          => l_cont_gross_weight,
         x_net_weight            => l_cont_net_weight,
         x_volume                => l_cont_volume,
         x_cont_fill_pc          => l_cont_fill_pc,
         x_return_status         => x_return_status);

       IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
         IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         RETURN;
       END IF;

       -- Convert the W/V if UOMs differ and then accumulate W/V
       IF (wci.wt_uom <> l_weight_uom_code) THEN
         IF (l_cont_gross_weight > 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM for converting Gross',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           x_gross_weight := NVL(x_gross_weight,0) +
                        WSH_WV_UTILS.convert_uom(wci.wt_uom, l_weight_uom_code, l_cont_gross_weight, wci.inventory_item_id);
         ELSIF (l_cont_gross_weight = 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'adding l_cont_gross_weight=0',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           x_gross_weight := NVL(x_gross_weight,0) + l_cont_gross_weight;
         END IF;

         IF (l_cont_net_weight > 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM for converting Net',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           x_net_weight := NVL(x_net_weight,0) +
                        WSH_WV_UTILS.convert_uom(wci.wt_uom, l_weight_uom_code, l_cont_net_weight, wci.inventory_item_id);
         ELSIF (l_cont_net_weight = 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'adding l_cont_net_weight=0',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           x_net_weight := NVL(x_net_weight,0) + l_cont_net_weight;
         END IF;
       ELSE
         IF (l_cont_gross_weight >= 0) THEN
           x_gross_weight := NVL(x_gross_weight,0) + l_cont_gross_weight;
         END IF;
         IF (l_cont_net_weight >= 0) THEN
           x_net_weight := NVL(x_net_weight,0) + l_cont_net_weight;
         END IF;
       END IF;

       IF (wci.vol_uom <> l_volume_uom_code) THEN
         IF (l_cont_volume > 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CONVERT_UOM for converting Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           x_volume := NVL(x_volume,0) +
                           WSH_WV_UTILS.convert_uom(wci.vol_uom, l_volume_uom_code, l_cont_volume, wci.inventory_item_id);
         ELSIF (l_cont_volume = 0) THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'adding l_cont_volume=0',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           x_volume := NVL(x_volume,0) + l_cont_volume;
         END IF;
       ELSE
         IF (l_cont_volume >= 0) THEN
           x_volume := NVL(x_volume,0) + l_cont_volume;
         END IF;
       END IF;

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Accumulated Gross '||x_gross_weight||' Net '||x_net_weight||' Vol '||x_volume);
       END IF;

     END LOOP;

  END IF; -- IF delivery_type = 'CONSOLIDATION

  -- If p_update_flag is 'Y' then update the delivery with the calculated W/V
  IF (p_update_flag = 'Y') THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Updating Del '||p_delivery_id||' With Gross '||x_gross_weight||' Net '||x_net_weight||' Vol '||x_volume);
    END IF;

    UPDATE wsh_new_deliveries
    SET    net_weight   = x_net_weight,
           gross_weight = x_gross_weight,
           volume       = x_volume,
           wv_frozen_flag  = 'N',
           last_update_date  = SYSDATE,
           last_updated_by   = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id
    WHERE  delivery_id = p_delivery_id;

    IF (SQL%NOTFOUND) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;

  END IF;


  -- OTM R12 : packing ECO
  -- for the given delivery_id, G_DELIVERY_TMS_IMPACT is changed from N to Y
  IF (WSH_WV_UTILS.G_RESET_WV ='Y' AND
      G_DELIVERY_TMS_IMPACT = 'Y' AND
      l_tms_interface_flag IN (
                           WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS,
                           WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS,
                           WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
                           WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED) AND
      l_ignore_for_planning = 'N') THEN
    l_delivery_id_tab(1) := p_delivery_id;
    l_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_delivery_id_tab', l_delivery_id_tab(1));
      WSH_DEBUG_SV.log(l_module_name, 'l_interface_flag_tab', l_interface_flag_tab(1));
    END IF;

    WSH_NEW_DELIVERIES_PVT.update_tms_interface_flag(
                         p_delivery_id_tab        => l_delivery_id_tab,
                         p_tms_interface_flag_tab => l_interface_flag_tab,
                         x_return_status          => l_return_status);

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                          WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
      x_return_status := l_return_status;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
        WSH_DEBUG_SV.pop(l_module_name, 'UPDATE_TMS_INTERFACE_FLAG ERROR');
      END IF;
      RETURN;
    END IF;
  END IF;

  --resetting the flag back to default after done with current delivery
  IF (G_DELIVERY_TMS_IMPACT = 'N') THEN
    G_DELIVERY_TMS_IMPACT := 'Y';
  END IF;

  -- End of OTM R12 : packing ECO


  IF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status '||x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN e_abort THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

   WHEN Others THEN
     WSH_UTIL_CORE.Default_Handler ('WSH_WV_UTILS.delivery_weight_volume');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END delivery_weight_volume;

-- J: W/V changes

-- Start of comments
-- API name : Delivery_Weight_Volume
-- Type     : Public
-- Pre-reqs : None.
-- Function : Calculates Weight and Volume of Delivery
--            If p_update_flag is 'Y' then the calculated W/V is updated on Delivery
--            Otherwise, the API returns the calculated W/V
-- Parameters :
-- IN:
--    p_delivery_detail_id IN NUMBER Required
--    p_update_flag        IN VARCHAR2
--      'Y' if the delivery needs to be updated with the calculated W/V
--    p_post_process_flag  IN VARCHAR2
--      'Y' if W/V post processing is required
--    p_calc_wv_if_frozen  IN VARCHAR2
--      'Y' if manual W/V can be overriden
-- OUT:
--    x_gross_weight OUT NUMBER
--       gives the gross weight of delivery
--    x_net_weight OUT NUMBER
--       gives the net weight of delivery
--    x_volume OUT NUMBER
--       gives the volume of delivery
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Delivery_Weight_Volume (
        p_delivery_id    IN NUMBER,
        p_update_flag    IN VARCHAR2,
        p_post_process_flag IN VARCHAR2,
        p_calc_wv_if_frozen IN VARCHAR2 DEFAULT 'Y',
        x_gross_weight   OUT NOCOPY  NUMBER,
        x_net_weight     OUT NOCOPY  NUMBER,
        x_volume         OUT NOCOPY  NUMBER,
        x_return_status  OUT NOCOPY  VARCHAR2) IS

l_org_gross_wt number;
l_org_net_wt   number;
l_org_vol      number;
l_organization_id number;
l_status_code  wsh_new_deliveries.status_code%TYPE;
l_shipment_direction wsh_new_deliveries.shipment_direction%TYPE;
l_wv_frozen_flag wsh_new_deliveries.wv_frozen_flag%TYPE;

l_return_status VARCHAR2(100);
l_debug_on     BOOLEAN;
l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_WEIGHT_VOLUME';

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_FLAG',P_UPDATE_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_POST_PROCESS_FLAG',P_POST_PROCESS_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'P_CALC_WV_IF_FROZEN',P_CALC_WV_IF_FROZEN);
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Get the delivery info
  BEGIN
    SELECT gross_weight,
           net_weight,
           volume,
           organization_id,
           status_code,
           NVL(shipment_direction,'O'),
           NVL(wv_frozen_flag,'Y')
    INTO   l_org_gross_wt,
           l_org_net_wt,
           l_org_vol,
           l_organization_id,
           l_status_code,
           l_shipment_direction,
           l_wv_frozen_flag
    FROM   wsh_new_deliveries
    WHERE  delivery_id = p_delivery_id;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_DELIVERY');
        FND_MESSAGE.SET_TOKEN('DELIVERY',p_delivery_id);
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Delivery '||p_delivery_id||' not found');
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        return;
  END;

  IF ((l_shipment_direction in ('O','IO') AND l_status_code IN ('IT','CL','SR')) OR
     (p_calc_wv_if_frozen = 'N' AND l_wv_frozen_flag = 'Y')) THEN

    x_gross_weight := l_org_gross_wt;
    x_net_weight   := l_org_net_wt;
    x_volume       := l_org_vol;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Delivery Status is '||l_status_code||' Frozen Flag '||l_wv_frozen_flag||'. Returning delivery weights');
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

    RETURN;
  END IF;


  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Del original wts are Gross '||l_org_gross_wt||' Net '||l_org_net_wt||' Vol '||l_org_vol);
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Delivery_weight_volume',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  -- Call Delivery_Weight_Volume API
  Delivery_weight_volume (
    p_delivery_id    => p_delivery_id,
    p_update_flag    => p_update_flag,
    p_calc_wv_if_frozen => p_calc_wv_if_frozen,
    x_gross_weight   => x_gross_weight,
    x_net_weight     => x_net_weight,
    x_volume         => x_volume,
    x_return_status  => l_return_status);

  IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
    x_return_status := l_return_status;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Delivery_weight_volume returned '||l_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     return;
  END IF;

  -- If p_update_flag is 'Y and ((p_post_process_flag is 'Y' and the new and old W/V differ)
  -- then call Del_WV_Post_Process API
  IF (p_update_flag = 'Y' AND p_post_process_flag = 'Y' AND
      (  (NVL(x_gross_weight,0) <> NVL(l_org_gross_wt,0)) OR
         (NVL(x_net_weight,0)   <> NVL(l_org_net_wt,0)) OR
         (NVL(x_volume,0)       <> NVL(l_org_vol,0)))) THEN

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Del_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    Del_WV_Post_Process(
      p_delivery_id   => p_delivery_id,
      p_diff_gross_wt => NVL(x_gross_weight,0) - NVL(l_org_gross_wt,0),
      p_diff_net_wt   => NVL(x_net_weight,0) - NVL(l_org_net_wt,0),
      p_diff_volume   => NVL(x_volume,0) - NVL(l_org_vol,0),
      x_return_status => l_return_status);

    IF l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := l_return_status;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Del_WV_Post_Process returned '||l_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;
    END IF;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status '||x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
   WHEN Others THEN
     WSH_UTIL_CORE.Default_Handler ('WSH_WV_UTILS.delivery_weight_volume');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END Delivery_Weight_Volume;

-- Start of comments
-- API name : Delivery_Weight_Volume
-- Type     : Public
-- Pre-reqs : None.
-- Function : Calculates Weight and Volume of Multiple Deliveries
--            If p_update_flag is 'Y' then the calculated W/V is updated on Delivery
--            Otherwise, the API returns the calculated W/V
--            If p_calc_wv_if_frozen is 'N' then manually entered W/V will not
--            be overwritten with calculated W/V
-- Parameters :
-- IN:
--    p_delivery_detail_id IN NUMBER Required
--    p_update_flag        IN VARCHAR2
--      'Y' if the delivery needs to be updated with the calculated W/V
--    p_post_process_flag  IN VARCHAR2
--      'Y' if W/V post processing is required
--    p_calc_wv_if_frozen  IN VARCHAR2
--      'Y' if manual W/V can be overriden
-- OUT:
--    x_gross_weight OUT NUMBER
--       gives the gross weight of delivery
--    x_net_weight OUT NUMBER
--       gives the net weight of delivery
--    x_volume OUT NUMBER
--       gives the volume of delivery
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Delivery_Weight_Volume(
            p_del_rows       IN wsh_util_core.id_tab_type,
            p_update_flag    IN VARCHAR2,
            p_calc_wv_if_frozen IN VARCHAR2,
            x_return_status  OUT NOCOPY  VARCHAR2) IS

l_net_weight NUMBER;
l_gross_weight NUMBER;
l_volume NUMBER;
l_num_error NUMBER := 0;

others EXCEPTION;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_WEIGHT_VOLUME';

BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_FLAG',P_UPDATE_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_CALC_WV_IF_FROZEN',P_CALC_WV_IF_FROZEN);
   END IF;

   IF (p_del_rows.count = 0) THEN
    raise others;
   END IF;

   FOR i IN 1..p_del_rows.count LOOP

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Delivery_Weight_Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    Delivery_Weight_Volume(
      p_delivery_id       => p_del_rows(i),
      p_update_flag       => p_update_flag,
      p_post_process_flag => 'Y',
      p_calc_wv_if_frozen => p_calc_wv_if_frozen,
      x_gross_weight      => l_gross_weight,
      x_net_weight        => l_net_weight,
      x_volume            => l_volume,
      x_return_status     => x_return_status);

    IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
       FND_MESSAGE.SET_NAME('WSH','WSH_DEL_WT_VOL_ERROR');
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_del_rows(i)));
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       wsh_util_core.add_message(x_return_status);
       WSH_NEW_DELIVERY_ACTIONS.g_error_level := 'E';
       l_num_error := l_num_error + 1;
      END IF;

   END LOOP;

   IF (p_del_rows.count > 1) THEN

    IF (l_num_error > 0) THEN

       FND_MESSAGE.SET_NAME('WSH','WSH_DEL_WT_VOL_SUMMARY');
       FND_MESSAGE.SET_TOKEN('NUM_ERROR',l_num_error);
       FND_MESSAGE.SET_TOKEN('NUM_SUCCESS',p_del_rows.count - l_num_error);

       IF (p_del_rows.count = l_num_error) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       ELSE
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       END IF;

       wsh_util_core.add_message(x_return_status);

    ELSE
       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;

   END IF;

   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
   WHEN others THEN

     wsh_util_core.default_handler ('WSH_WV_UTILS.DELIVERY_WEIGHT_VOLUME');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;

END Delivery_Weight_Volume;


-- HW OPMCONV - New routine to check item deviation
-- Function:	within_deviation
-- Parameters:	p_organization_id     - organization id
-- 		p_inventory_item_id   - Inventory Item id
--              p_lot_number          - Lot number
--              p_precision           - Precision - default 5
--              p_quantity            - Primary Qty
--              p_uom1                - Uom code to convert from
--              p_quantity2           - Secondary Qty
--              p_uom2                - Uom code to convert to
-- Description: This function calls new INV routine INV_CONVERT.within_deviation
--              to check if Qtys are within deviation for item types 'D' and 'N'

FUNCTION within_deviation (
      p_organization_id         IN   NUMBER,
      p_inventory_item_id       IN   NUMBER,
      p_lot_number              IN   VARCHAR2,
      p_precision               IN   NUMBER default 5,
      p_quantity                IN   NUMBER,
      p_uom1                    IN   VARCHAR2,
      p_quantity2               IN   NUMBER,
      p_uom2                    IN   VARCHAR2) RETURN NUMBER
IS

result        NUMBER;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'WITHIN_DEVIATION';

BEGIN

-- INV API will validate item, org, UOMs and deviations and will raise
-- errors where applicable

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_organization_id',p_organization_id);
      WSH_DEBUG_SV.log(l_module_name,'p_inventory_item_id',p_inventory_item_id);
      WSH_DEBUG_SV.log(l_module_name,'p_lot_number',p_lot_number);
      WSH_DEBUG_SV.log(l_module_name,'p_quantity',p_quantity);
      WSH_DEBUG_SV.log(l_module_name,'p_quantity2',p_quantity2);
      WSH_DEBUG_SV.log(l_module_name,'p_uom1',p_lot_number);
      WSH_DEBUG_SV.log(l_module_name,'p_uom2',p_uom2);
      WSH_DEBUG_SV.log(l_module_name,'p_precision',p_precision);
   END IF;


     result := INV_CONVERT.within_deviation(
          p_organization_id,
          p_inventory_item_id,
          p_lot_number,
          p_precision,
          p_quantity ,
          p_uom1,
          p_quantity2,
          p_uom2 );


       IF ( result = 1 ) THEN
         result := 1;
       ELSE
         result := 0;
       END IF;

      RETURN result;


EXCEPTION
   WHEN others THEN
     wsh_util_core.default_handler ('WSH_WV_UTILS.within_deviation');

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
END within_deviation;

--OTM R12, creating wrapper for prorate_weight_actual so we only update delivery tms flag once
-- Procedure name : Prorate_weight
-- Pre-reqs       : Prorate_wt_flag should be 'Y' for the delivery.
-- Description    : Prorates weight of the given delivery/container to its immediate children
--
-- Parameters :
--    p_entity_type  	- DELIVERY or CONTAINER
--    p_entity_id       - Delivery_id or Container_id
--    p_old_gross_wt	- Original Gross Weight of the entity
--    p_new_gross_wt	- New Gross Weight of the entity
--    p_old_net_wt      - Original Net Weight of the entity
--    p_net_net_wt	- New Net Weight of the entity
--    p_weight_uom_code - Weight UOM of the entity

PROCEDURE Prorate_weight(
            p_entity_type	    IN         VARCHAR2,
            p_entity_id		    IN         NUMBER,
            p_old_gross_wt	    IN         NUMBER,
	    p_new_gross_wt	    IN         NUMBER,
            p_old_net_wt	    IN         NUMBER,
	    p_new_net_wt	    IN         NUMBER,
            p_weight_uom_code       IN         VARCHAR2,
	    x_return_status         OUT NOCOPY VARCHAR2,
            p_call_level            IN         NUMBER) IS

  CURSOR c_get_delivery_info_cont(p_detail_id IN NUMBER) IS
    SELECT wda.delivery_id,
           wnd.weight_uom_code
    FROM   WSH_DELIVERY_ASSIGNMENTS wda,
           WSH_NEW_DELIVERIES wnd
    WHERE  wda.delivery_detail_id = p_detail_id
    AND    wda.delivery_id = wnd.delivery_id
    AND    wda.delivery_id IS NOT NULL
    AND    NVL(wnd.ignore_for_planning, 'N') = 'N'
    AND    NVL(wnd.tms_interface_flag, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)
           IN (WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS,
               WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS,
               WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
               WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED);

  CURSOR c_get_delivery_info_del(p_delivery_id IN NUMBER) IS
    SELECT delivery_id,
           weight_uom_code
    FROM   WSH_NEW_DELIVERIES
    WHERE  delivery_id = p_delivery_id
    AND    NVL(ignore_for_planning, 'N') = 'N'
    AND    NVL(tms_interface_flag, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)
           IN (WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS,
               WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS,
               WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
               WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED);

  l_delivery_id 	   WSH_NEW_DELIVERIES.DELIVERY_ID%TYPE;
  l_delivery_id_tab        WSH_UTIL_CORE.ID_TAB_TYPE;
  l_interface_flag_tab     WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_gc3_is_installed       VARCHAR2(1);
  l_weight_uom_code        WSH_NEW_DELIVERIES.WEIGHT_UOM_CODE%TYPE;
  api_return_fail          EXCEPTION;

  l_return_status          VARCHAR2(1);
  l_debug_on               BOOLEAN;

  l_module_name  CONSTANT  VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRORATE_WEIGHT';

  BEGIN
    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN

      wsh_debug_sv.push(l_module_name);
      --
      wsh_debug_sv.LOG(l_module_name, 'P_ENTITY_TYPE', p_entity_type);
      wsh_debug_sv.LOG(l_module_name, 'P_ENTITY_ID', p_entity_id );
      wsh_debug_sv.LOG(l_module_name, 'P_OLD_GROSS_WT',p_old_gross_wt  );
      wsh_debug_sv.LOG(l_module_name, 'P_NEW_GROSS_WT', p_new_gross_wt);
      wsh_debug_sv.LOG(l_module_name, 'P_OLD_NET_WT',p_old_net_wt  );
      wsh_debug_sv.LOG(l_module_name, 'P_NEW_NET_WT', p_new_net_wt);
      wsh_debug_sv.LOG(l_module_name, 'P_WEIGHT_UOM_CODE', p_weight_uom_code);
      wsh_debug_sv.LOG(l_module_name, 'p_call_level', p_call_level);
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED; -- this is global variable

    IF l_gc3_is_installed IS NULL THEN
      l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED; -- this is actual function
    END IF;

    --first call real prorate procedure to prorate the delivery/container
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit prorate_weight_actual',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    prorate_weight_actual(
            p_entity_type     => p_entity_type,
            p_entity_id       => p_entity_id,
            p_old_gross_wt    => p_old_gross_wt,
            p_new_gross_wt    => p_new_gross_wt,
            p_old_net_wt      => p_old_net_wt,
            p_new_net_wt      => p_new_net_wt,
            p_weight_uom_code => p_weight_uom_code,
            x_return_status   => l_return_status,
            p_call_level      => p_call_level);

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'return status from prorate_weight_actual: ' || l_return_status);
    END IF;

    x_return_status := l_return_status;

    IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR)) THEN
      RAISE api_return_fail;
    END IF;

    --after prorate, details are changed, so check if the weights have changed
    --then call update for delivery tms_interface_flag.
    IF (l_gc3_is_installed = 'Y') THEN

      l_delivery_id := NULL;
      l_weight_uom_code := NULL;

      IF p_entity_type = 'DELIVERY' THEN
        OPEN c_get_delivery_info_del(p_entity_id);
        FETCH c_get_delivery_info_del INTO l_delivery_id,
                                           l_weight_uom_code;
        IF (c_get_delivery_info_del%NOTFOUND) THEN
          l_delivery_id := NULL;
        END IF;
        CLOSE c_get_delivery_info_del;
      ELSIF p_entity_type = 'CONTAINER' THEN
        OPEN c_get_delivery_info_cont(p_entity_id);
        FETCH c_get_delivery_info_cont INTO l_delivery_id,
                                            l_weight_uom_code;
        IF (c_get_delivery_info_cont%NOTFOUND) THEN
          l_delivery_id := NULL;
        END IF;
        CLOSE c_get_delivery_info_cont;
      END IF;

      IF (l_delivery_id IS NOT NULL
          AND ((NVL(p_weight_uom_code, '!@#$%') <> NVL(l_weight_uom_code,  '!@#$%'))
               OR (NVL(p_old_net_wt, -99) <> NVL(p_new_net_wt, -99))
               OR (NVL(p_old_gross_wt, -99) <> NVL(p_new_gross_wt, -99)))) THEN

        l_delivery_id_tab(1) := l_delivery_id;
        l_interface_flag_tab(1) := 'UR';

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_NEW_DELIVERIES_PVT.update_tms_interface_flag(
                 p_delivery_id_tab        => l_delivery_id_tab,
                 p_tms_interface_flag_tab => l_interface_flag_tab,
                 x_return_status          => l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG: ' || l_return_status);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          RAISE api_return_fail;
        ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
          x_return_status := l_return_status;
        END IF;

      END IF; -- delivery id not null
    END IF;  --gc3 installed

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    EXCEPTION
      WHEN api_return_fail THEN
        x_return_status := l_return_status;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
      WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

        IF (c_get_delivery_info_del%ISOPEN) THEN
          CLOSE c_get_delivery_info_del;
        END IF;

        IF (c_get_delivery_info_cont%ISOPEN) THEN
          CLOSE c_get_delivery_info_cont;
        END IF;

        WSH_UTIL_CORE.default_handler('WSH_WV_UTILS.Prorate_weight' );
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
  END Prorate_weight;

--END OTM R12

--OTM R12, for this procedure, changed the name to prorate_weight_actual so the wrapper prorate_weight
--can be used without changing any caller code, so the old prorate_weight calls in this procedure is all changed to
--prorate_weight_actual

-- Bug#4254552:"Proration of weight from Delivery to delivery lines" Project.
-- Procedure name : Prorate_weight_actual
-- Pre-reqs       : Prorate_wt_flag should be 'Y' for the delivery.
-- Description    : Prorates weight of the given delivery/container to its immediate children
--
-- Parameters :
--    p_entity_type  	- DELIVERY or CONTAINER
--    p_entity_id       - Delivery_id or Container_id
--    p_old_gross_wt	- Original Gross Weight of the entity
--    p_new_gross_wt	- New Gross Weight of the entity
--    p_old_net_wt      - Original Net Weight of the entity
--    p_net_net_wt	- New Net Weight of the entity
--    p_weight_uom_code - Weight UOM of the entity

PROCEDURE Prorate_weight_actual(
            p_entity_type	    IN  VARCHAR2,
            p_entity_id		    IN  NUMBER,
            p_old_gross_wt	    IN  NUMBER,
	    p_new_gross_wt	    IN  NUMBER,
            p_old_net_wt	    IN  NUMBER,
	    p_new_net_wt	    IN  NUMBER,
            p_weight_uom_code       IN  VARCHAR2,
	    x_return_status    	OUT NOCOPY VARCHAR2,
            p_call_level            IN NUMBER) IS

-- Get immediate container/delivery line information for the given delivery_id

CURSOR immediate_details_del(p_delivery_id IN NUMBER, p_wt_uom IN VARCHAR2) IS
SELECT wdd.delivery_detail_id,
       nvl(wdd.net_weight,0) net_wt,
       nvl(wdd.gross_weight,0) gross_wt,
       nvl(wdd.gross_weight,0) - nvl(wdd.net_weight,0) tare_wt,
       decode(wdd.weight_uom_code,p_wt_uom,nvl(wdd.net_weight,0),wsh_wv_utils.convert_uom(wdd.weight_uom_code,p_wt_uom,nvl(wdd.net_weight,0),wdd.inventory_item_id)) net_wt_in_parent_uom,
       decode(wdd.weight_uom_code,p_wt_uom,nvl(wdd.gross_weight,0)-nvl(wdd.net_weight,0),wsh_wv_utils.convert_uom(wdd.weight_uom_code,p_wt_uom,(nvl(wdd.gross_weight,0)-nvl(wdd.net_weight,0)),wdd.inventory_item_id)) tare_wt_in_parent_uom,
       wdd.weight_uom_code,
       wdd.inventory_item_id,
       wdd.container_flag,
       nvl(wdd.line_direction, 'O') line_direction, -- LPN CONV. rv
       wdd.organization_id organization_id          -- LPN CONV. rv
FROM  wsh_delivery_assignments_v wda,
      wsh_delivery_details wdd
WHERE wda.delivery_id = p_delivery_id
AND   wda.parent_delivery_detail_id IS NULL
AND   wda.delivery_detail_id = wdd.delivery_detail_id
AND   nvl(wdd.gross_weight,0) > 0
FOR UPDATE NOWAIT;

-- Get immediate container/delivery line information for the given container_id
CURSOR immediate_details_cont(p_container_id IN NUMBER, p_wt_uom IN VARCHAR2) IS
SELECT wdd.delivery_detail_id,
       nvl(wdd.net_weight,0)   net_wt,
       nvl(wdd.gross_weight,0) gross_wt,
       nvl(wdd.gross_weight,0) - nvl(wdd.net_weight,0) tare_wt,
       decode(wdd.weight_uom_code,p_wt_uom,nvl(wdd.net_weight,0),wsh_wv_utils.convert_uom(wdd.weight_uom_code,p_wt_uom,nvl(wdd.net_weight,0),wdd.inventory_item_id)) net_wt_in_parent_uom,
       decode(wdd.weight_uom_code,p_wt_uom,nvl(wdd.gross_weight,0)-nvl(wdd.net_weight,0),wsh_wv_utils.convert_uom(wdd.weight_uom_code,p_wt_uom,(nvl(wdd.gross_weight,0)-nvl(wdd.net_weight,0)),wdd.inventory_item_id)) tare_wt_in_parent_uom,
       wdd.weight_uom_code,
       wdd.inventory_item_id,
       wdd.container_flag,
       nvl(wdd.line_direction, 'O') line_direction, -- LPN CONV. rv
       wdd.organization_id organization_id          -- LPN CONV. rv
FROM  wsh_delivery_assignments_v wda,
      wsh_delivery_details wdd
WHERE wda.parent_delivery_detail_id IS NOT NULL
AND   wda.parent_delivery_detail_id = p_container_id
AND   wda.delivery_detail_id = wdd.delivery_detail_id
AND   nvl(wdd.gross_weight,0) > 0
FOR UPDATE NOWAIT;

TYPE Prorate_Rec_Type IS RECORD (
	delivery_detail_id	NUMBER,
	old_gross_weight	NUMBER,
	new_gross_weight	NUMBER,
	old_net_weight		NUMBER,
	new_net_weight		NUMBER,
	wt_uom_code		VARCHAR2(3));

TYPE Prorate_Tab_Type IS TABLE OF Prorate_Rec_Type index by binary_integer;

l_lpn_tab	        Prorate_Tab_Type;
-- Used to store the immediate Container's info to call the API recursively
immediate_detail_rec	immediate_details_del%ROWTYPE;
-- Used to store immediate delivery detail lines information
TYPE immediate_detail_rec_tab IS TABLE OF immediate_details_del%ROWTYPE INDEX BY binary_integer;
l_detail_rec_tab    immediate_detail_rec_tab;

-- Following variables are used to store the immediate container/delivery lines' info
l_dd_upd_tbl            WSH_UTIL_CORE.Id_Tab_Type; -- Stores all immediate child delivery detail ids'
l_dd_upd_net_wt_tbl 	WSH_UTIL_CORE.Id_Tab_Type; -- Stores Net weights(in entity's UOM) of all immediate children
l_dd_upd_gross_wt_tbl	WSH_UTIL_CORE.Id_Tab_Type; -- Stores Tare weights(in entity's UOM) of all immediate children
--

l_new_tare_wt		NUMBER := 0;
l_new_gross_wt		NUMBER := 0;
l_new_net_wt		NUMBER := 0;

l_new_tare_wt_in_parent_uom NUMBER;
l_new_net_wt_in_parent_uom  NUMBER;

l_entity_tare_change	NUMBER;		-- Change in Tare Weight of the passed entity
l_entity_net_change	NUMBER;		-- Change in Net Weight of the passed entity
l_total_tare_wt		NUMBER := 0;	-- Stores the total Tare Weight of all immediate Containers/Delivery lines.
l_total_net_wt		NUMBER := 0;	-- Stores the total Net Weight of all immediate Containers/Delivery lines.


l_lpn_count             NUMBER := 0;

-- LPN CONV. rv
l_wms_org VARCHAR2(10);
l_sync_tmp_wms_recTbl wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
l_sync_tmp_inv_recTbl wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;

l_child_cnt_counter NUMBER;
l_cnt_wms_counter NUMBER;
l_cnt_inv_counter NUMBER;
-- LPN CONV. rv


-- Standard call to check for call compatibility
l_return_status               VARCHAR2(30) := NULL;
l_num_errors            NUMBER := 0;
l_num_warnings          NUMBER := 0;
l_debug_on              BOOLEAN;

l_update_to_containers VARCHAR2(2) := WSH_WMS_LPN_GRP.g_update_to_containers;
l_call_group_api      VARCHAR2(2) := WSH_WMS_LPN_GRP.g_call_group_api;
l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
l_call_level          NUMBER;

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRORATE_WEIGHT_ACTUAL';

BEGIN
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL  THEN
  --{
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  --}
  END IF;
  --
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
  --{
     wsh_debug_sv.push(l_module_name);
     --
     wsh_debug_sv.LOG(l_module_name, 'P_ENTITY_TYPE', p_entity_type);
     wsh_debug_sv.LOG(l_module_name, 'P_ENTITY_ID', p_entity_id );
     wsh_debug_sv.LOG(l_module_name, 'P_OLD_GROSS_WT',p_old_gross_wt  );
     wsh_debug_sv.LOG(l_module_name, 'P_NEW_GROSS_WT', p_new_gross_wt);
     wsh_debug_sv.LOG(l_module_name, 'P_OLD_NET_WT',p_old_net_wt  );
     wsh_debug_sv.LOG(l_module_name, 'P_NEW_NET_WT', p_new_net_wt);
     wsh_debug_sv.LOG(l_module_name, 'P_WEIGHT_UOM_CODE', p_weight_uom_code);
     wsh_debug_sv.LOG(l_module_name, 'p_call_level', p_call_level);
  --}
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- Find the change in net and tare wts
  l_entity_tare_change   := ( nvl(p_new_gross_wt,0) - nvl(p_new_net_wt,0) ) - ( nvl(p_old_gross_wt,0) - nvl(p_old_net_wt,0) );
  l_entity_net_change    := nvl(p_new_net_wt,0) - nvl(p_old_net_wt,0);


  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Change in Net: '||l_entity_net_change||', Change in Tare: '||l_entity_tare_change);
  END IF;
  --
  -- Do proration only when there is a change in tare/net.
  IF l_entity_tare_change  <> 0 OR l_entity_net_change <> 0 THEN
  --{
     IF p_entity_type = 'DELIVERY' THEN
        OPEN immediate_details_del(p_entity_id,p_weight_uom_code);
     ELSIF p_entity_type = 'CONTAINER' THEN
        OPEN immediate_details_cont(p_entity_id,p_weight_uom_code);
     END IF;

     -- Calculating the total Net and Tare Weight of all immediate delivery lines which are
     -- required later to find out the proportional weight.
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calculating the total Net and Tare Weight of all immediate delivery lines');
     END IF;
     --
     LOOP
     --{ Looping thru' all immediate children for the delivery/container
        IF p_entity_type = 'DELIVERY' THEN
           FETCH immediate_details_del INTO immediate_detail_rec;
	   EXIT WHEN immediate_details_del%NOTFOUND;
        ELSIF p_entity_type = 'CONTAINER' THEN
           FETCH immediate_details_cont INTO immediate_detail_rec;
	   EXIT WHEN immediate_details_cont%NOTFOUND;
        END IF;
        -- Cache the Weights of immediate Containers/Delivery lines of the Delivery
        l_detail_rec_tab(l_detail_rec_tab.COUNT + 1) := immediate_detail_rec;

        l_total_net_wt := l_total_net_wt + immediate_detail_rec.net_wt_in_parent_uom;
        l_total_tare_wt := l_total_tare_wt + immediate_detail_rec.tare_wt_in_parent_uom;
     --} Looping thru' all immediate children for the delivery/container
     END LOOP;

     IF immediate_details_del%ISOPEN THEN
        CLOSE immediate_details_del;
     END IF;
     IF immediate_details_cont%ISOPEN THEN
        CLOSE immediate_details_cont;
     END IF;
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Total Tare Weight: '||l_total_tare_wt||', Total Net Weight: ' ||l_total_net_wt);
     END IF;
     --
     IF ( l_total_net_wt = 0 AND l_total_tare_wt = 0 ) THEN
     --{
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'There is no proration required as the total Tare and Net weights are zero, ');
        END IF;
        --
        RETURN;
     --}
     END IF;

     l_call_level := NVL(p_call_level,0) + 1;

     IF p_call_level IS NULL THEN --{
        --bmso call out for WMS to flush all the record prior to prorating.
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

       WSH_UTIL_CORE.API_POST_CALL
         (
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors
         );

     END IF; --}

     -- Calculate the change in Weights of Delivery detail.
     -- change in Weight of DD = (DD's original weight/total weight of all the children) * change in entity's weight;
     --
     -- LPN CONV. rv
     l_cnt_wms_counter := 1;
     l_cnt_inv_counter := 1;
     -- LPN CONV. rv
     --
     FOR i IN 1..l_detail_rec_tab.COUNT
     LOOP
     --{

        l_new_tare_wt := 0;
        l_new_net_wt  := 0;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'********* Processing the Delivery Detail Id:',l_detail_rec_tab(i).delivery_detail_id);
           WSH_DEBUG_SV.logmsg(l_module_name, 'Current Wts are, Gross '||l_detail_rec_tab(i).gross_wt|| ' Net '||l_detail_rec_tab(i).net_wt||' Tare '||l_detail_rec_tab(i).tare_wt|| ' Weight UOM '||l_detail_rec_tab(i).weight_uom_code);
        END IF;
        --
        -- Calculate the change in Tare Weight
        IF ( l_entity_tare_change <> 0 ) THEN
         --{ tare wt change
            IF (p_weight_uom_code <> l_detail_rec_tab(i).weight_uom_code ) THEN
            --{ UOM's are different
               IF l_detail_rec_tab(i).tare_wt_in_parent_uom <> 0 THEN
               --{
                  l_new_tare_wt_in_parent_uom :=l_detail_rec_tab(i).tare_wt_in_parent_uom + (l_detail_rec_tab(i).tare_wt_in_parent_uom/l_total_tare_wt) * l_entity_tare_change;
                  l_new_tare_wt    := WSH_WV_UTILS.convert_uom(
					            p_weight_uom_code,
	              		                    l_detail_rec_tab(i).weight_uom_code,
				                    l_new_tare_wt_in_parent_uom,
  			                            l_detail_rec_tab(i).inventory_item_id);
               --}
               END IF;
	    ELSE
               IF l_detail_rec_tab(i).tare_wt <> 0 THEN
                  l_new_tare_wt := l_detail_rec_tab(i).tare_wt+(l_detail_rec_tab(i).tare_wt/l_total_tare_wt) * l_entity_tare_change;
               END IF;
            --} UOM's are different
            END IF;
            -- Final Tare weight
            l_new_tare_wt   := ROUND(l_new_tare_wt,5);
        ELSE
           l_new_tare_wt := l_detail_rec_tab(i).tare_wt;
        --} tare wt change
        END IF;

        -- Calculate the change in Net Weight
        IF  ( l_entity_net_change <> 0 ) THEN
         --{ net weight change
            IF (p_weight_uom_code <> l_detail_rec_tab(i).weight_uom_code ) THEN
             --{ UOM's are different
                IF l_detail_rec_tab(i).net_wt_in_parent_uom <> 0 THEN
                --{
                   l_new_net_wt_in_parent_uom :=l_detail_rec_tab(i).net_wt_in_parent_uom + (l_detail_rec_tab(i).net_wt_in_parent_uom/l_total_net_wt) * l_entity_net_change;
                   l_new_net_wt    := WSH_WV_UTILS.convert_uom(
	 		                     p_weight_uom_code,
	           		             l_detail_rec_tab(i).weight_uom_code,
		                             l_new_net_wt_in_parent_uom,
  			                     l_detail_rec_tab(i).inventory_item_id);
                --}
                END IF;
	    ELSE
               IF l_detail_rec_tab(i).net_wt <> 0 THEN
                  l_new_net_wt := l_detail_rec_tab(i).net_wt+(l_detail_rec_tab(i).net_wt/l_total_net_wt) * l_entity_net_change;
               END IF;
            --} UOM's are different
            END IF;
            -- Final Net weight
            l_new_net_wt    := ROUND(l_new_net_wt ,5);
        ELSE
           l_new_net_wt := l_detail_rec_tab(i).net_wt ;
        --} net weight change
        END IF;

        -- Wt should not be -ve
        IF l_new_net_wt < 0 THEN
           l_new_net_wt := 0;
        END IF;

        IF l_new_tare_wt < 0 THEN
           l_new_tare_wt := 0;
        END IF;

        l_new_gross_wt  := l_new_net_wt + l_new_tare_wt;

        -- Make the new Gross Weight equal to Net Weight, if the Gross Weight is lesser than Net Weight due to precision loss
        IF l_new_gross_wt  < l_new_net_wt THEN
           l_new_gross_wt := l_new_net_wt;
        END IF;
        --
        IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'New Weights are, Gross ' || l_new_gross_wt ||' Net '||l_new_net_wt ||' Tare '||l_new_tare_wt);
        END IF;
        --
        -- Cache the new weights of the Containers to pass them to recursive call
        -- If immediate child of the Delivery is a Container, cache it to call the prorate api recursively
        IF nvl(l_detail_rec_tab(i).container_flag, 'N') = 'Y' THEN
        --{
               l_lpn_count := l_lpn_count + 1;
	       l_lpn_tab(l_lpn_count).delivery_detail_id := l_detail_rec_tab(i).delivery_detail_id;
	       l_lpn_tab(l_lpn_count).old_gross_weight := l_detail_rec_tab(i).gross_wt;
	       l_lpn_tab(l_lpn_count).old_net_weight := l_detail_rec_tab(i).net_wt;
	       l_lpn_tab(l_lpn_count).wt_uom_code := l_detail_rec_tab(i).weight_uom_code;
               l_lpn_tab(l_lpn_count).new_gross_weight := l_new_gross_wt;
	       l_lpn_tab(l_lpn_count).new_net_weight   := l_new_net_wt;

               -- LPN CONV. rv
               IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
               THEN
               --{
                   --
                   -- need to check the wms org value for each record because the parent LPN
                   -- can be a consol. LPN.
                   l_wms_org := wsh_util_validate.check_wms_org(l_detail_rec_tab(i).organization_id);
                   --
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_wms_org value is', l_wms_org);
                   END IF;
                   --
                   IF(l_wms_org = 'Y'
                      AND l_detail_rec_tab(i).line_direction in ('O', 'IO')
                     )
                   THEN
                     l_sync_tmp_wms_recTbl.delivery_detail_id_tbl(l_cnt_wms_counter) := l_detail_rec_tab(i).delivery_detail_id;
                     l_sync_tmp_wms_recTbl.operation_type_tbl(l_cnt_wms_counter) := 'UPDATE';
                     l_sync_tmp_wms_recTbl.call_level(l_cnt_wms_counter) := l_call_level;
                     l_cnt_wms_counter := l_cnt_wms_counter +1;
                   ELSIF (l_wms_org = 'N'
                          AND l_detail_rec_tab(i).line_direction in ('O', 'IO')
                         )
                   THEN
                     l_sync_tmp_inv_recTbl.delivery_detail_id_tbl(l_cnt_inv_counter) := l_detail_rec_tab(i).delivery_detail_id;
                     l_sync_tmp_inv_recTbl.operation_type_tbl(l_cnt_inv_counter) := 'UPDATE';
                     l_sync_tmp_inv_recTbl.call_level(l_cnt_inv_counter) := l_call_level;
                     l_cnt_inv_counter := l_cnt_inv_counter +1;
                   END IF;
                   --
               --}
               END IF;
               -- LPN CONV. rv
        --}
        END IF;

        -- Store delivery detail id,new gross and new net weight for doing BULK update later.
        l_dd_upd_tbl(l_dd_upd_tbl.COUNT + 1)                 := l_detail_rec_tab(i).delivery_detail_id;
        l_dd_upd_net_wt_tbl(l_dd_upd_net_wt_tbl.COUNT+1)     := l_new_net_wt;
        l_dd_upd_gross_wt_tbl(l_dd_upd_gross_wt_tbl.COUNT+1) := l_new_gross_wt;
     --}
     END LOOP;

     -- LPN CONV. rv
     --
     IF l_debug_on THEN
       wsh_debug_sv.LOG(l_module_name, 'Count of l_sync_tmp_wms_recTbl', l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.count);
       wsh_debug_sv.LOG(l_module_name, 'Count of l_sync_tmp_inv_recTbl', l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.count);
     END IF;
     --
     --
     IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
     THEN
     --{
         IF  WSH_WMS_LPN_GRP.GK_WMS_UPD_WV
         AND l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.count > 0
         THEN
         --{
             --
             -- Debug Statements
             --
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
             WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
               (
                 p_sync_tmp_recTbl   => l_sync_tmp_wms_recTbl,
                 x_return_status     => l_return_status
               );
             --
             IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name, 'Return status after the call to WSH_WMS_SYNC_TMP_PKG.MERGE_BULK is ', l_return_status);
             END IF;
             --
             WSH_UTIL_CORE.API_POST_CALL
               (
                 p_return_status => l_return_status,
                 x_num_warnings  => l_num_warnings,
                 x_num_errors    => l_num_errors
               );
         --}
         ELSIF WSH_WMS_LPN_GRP.GK_INV_UPD_WV
         AND l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.count > 0
         THEN
         --{
             --
             -- Debug Statements
             --
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
             WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
               (
                 p_sync_tmp_recTbl   => l_sync_tmp_inv_recTbl,
                 x_return_status     => l_return_status
               );

             --
             IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name, 'Return status after the call to WSH_WMS_SYNC_TMP_PKG.MERGE_BULK is ', l_return_status);
             END IF;
             --
             WSH_UTIL_CORE.API_POST_CALL
               (
                 p_return_status => l_return_status,
                 x_num_warnings  => l_num_warnings,
                 x_num_errors    => l_num_errors
               );
         --}
         END IF;
     --}
     END IF;
     -- LPN CONV. rv

     -- Update all effected delivery details with  resultant gross
     -- and net weight. Also update wv_frozen_flag to 'Y' for all.
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Updating the Weights of Delivery Details');
     END IF;
     --
     FORALL i IN 1..l_dd_upd_tbl.COUNT
     UPDATE wsh_delivery_details
     SET    gross_weight      = l_dd_upd_gross_wt_tbl(i),
            net_weight        = l_dd_upd_net_wt_tbl(i),
            wv_frozen_flag    = 'Y',
            last_update_date  = SYSDATE,
            last_updated_by   = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id
     WHERE  delivery_detail_id = l_dd_upd_tbl(i);

     -- Make the recursive call to prorate the weights further down.
     IF l_lpn_tab.COUNT > 0 THEN
     --{
       FOR i IN 1..l_lpn_tab.COUNT
       LOOP
       --{
          --
          IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,'Calling the Prorate API recursively for the Containers');
          END IF;
          --
	  Prorate_weight_actual(
	            p_entity_type   => 'CONTAINER',
                    p_entity_id     => l_lpn_tab(i).delivery_detail_id,
                    p_old_gross_wt  => l_lpn_tab(i).old_gross_weight,
	            p_new_gross_wt  => l_lpn_tab(i).new_gross_weight,
                    p_old_net_wt    => l_lpn_tab(i).old_net_weight,
	            p_new_net_wt    => l_lpn_tab(i).new_net_weight,
                    p_weight_uom_code => l_lpn_tab(i).wt_uom_code,
	            x_return_status => l_return_status,
                    p_call_level    => l_call_level);

	 x_return_status :=  l_return_status;

	 IF l_debug_on THEN
	    wsh_debug_sv.log(l_module_name,'Return Status After Calling Prorate_weight_actual',l_return_status);
	 END IF;
         --
         wsh_util_core.api_post_call(
	     p_return_status    => l_return_status,
	     x_num_warnings     => l_num_warnings,
	     x_num_errors       => l_num_errors,
             p_raise_error_flag => TRUE );
         --
       --}
       END LOOP;
     --}
     END IF;
  --}
  END IF;

  IF (p_call_level IS NULL)
   AND (WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y')
   AND (l_wms_org = 'Y')
  THEN --{

     WSH_WMS_LPN_GRP.g_update_to_containers := 'N';
     WSH_WMS_LPN_GRP.g_call_group_api := 'N' ;
     --call the new API
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_PRORATED_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     WSH_LPN_SYNC_COMM_PKG.SYNC_PRORATED_LPNS_TO_WMS
     (
       p_in_rec             => l_lpn_in_sync_comm_rec,
       x_return_status      => l_return_status,
       x_out_rec            => l_lpn_out_sync_comm_rec
     );

     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_PRORATED_LPNS_TO_WMS', l_return_status);
     END IF;

     WSH_UTIL_CORE.API_POST_CALL
       (
         p_return_status => l_return_status,
         x_num_warnings  => l_num_warnings,
         x_num_errors    => l_num_errors
       );
     WSH_WMS_LPN_GRP.g_call_group_api := l_call_group_api;
     WSH_WMS_LPN_GRP.g_update_to_containers := l_update_to_containers;

  END IF; --}

  IF l_num_errors > 0
  THEN
       x_return_status     := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF l_num_warnings > 0
  THEN
       x_return_status     := WSH_UTIL_CORE.G_RET_STS_WARNING;
  ELSE
       x_return_status     := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
       WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         WSH_WMS_LPN_GRP.g_call_group_api := l_call_group_api;
         WSH_WMS_LPN_GRP.g_update_to_containers := l_update_to_containers;

	   IF immediate_details_del%ISOPEN THEN
	      CLOSE immediate_details_del;
	   END IF;
	   IF immediate_details_cont%ISOPEN THEN
	       CLOSE immediate_details_cont;
           END IF;
         WSH_UTIL_CORE.default_handler('WSH_WV_UTILS.Prorate_weight_actual' );
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
          --
END Prorate_weight_actual;

END WSH_WV_UTILS;

/
