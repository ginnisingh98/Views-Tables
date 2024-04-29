--------------------------------------------------------
--  DDL for Package Body WSH_SHIPPING_CONSTRAINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SHIPPING_CONSTRAINTS_PKG" as
/* $Header: WSHCSCPB.pls 120.0 2005/05/26 18:33:38 appldev noship $ */

--Procedure:      check_shipping_constraints
--Parameters:      p_changed_attributes
--		x_return_status
--		x_action_allowed
--Description:     This procedure will check if actions like Delete or cancel
--		are allowed on a source line considering the status
--		of the delivery detail, detail


--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_SHIPPING_CONSTRAINTS_PKG';
--
PROCEDURE check_shipping_constraints
	(
	p_source_code            IN     VARCHAR2,
	p_changed_attributes      IN     ChangedAttributeRecType,
	x_return_status            OUT NOCOPY     VARCHAR2,
	x_action_allowed       OUT NOCOPY  VARCHAR2,
	x_action_message       OUT NOCOPY  VARCHAR2,
	x_ord_qty_allowed	       OUT NOCOPY  NUMBER,
	p_log_level              IN     NUMBER  DEFAULT 0
	) IS

CURSOR c_del_details_cur IS
SELECT    wdd.delivery_detail_id,
          wdd.serial_number,
          wdd.transaction_temp_id,
          wdd.source_line_id,
          wdd.pickable_flag,
          wdd.move_order_line_id,
          wdd.ship_from_location_id,
          wdd.organization_id,
          wdd.inventory_item_id,
          wdd.subinventory,
          wdd.revision,
          wdd.locator_id,
          wdd.lot_number,
          wdd.released_status,
          wdd.requested_quantity,
          wdd.picked_quantity,
          wdd.cancelled_quantity,
          wdd.shipped_quantity,
          wdd.requested_quantity2,
          wdd.picked_quantity2,
          wdd.cancelled_quantity2,
          wdd.shipped_quantity2,
	  wda.parent_delivery_detail_id,
	  wda.delivery_assignment_id,
	  wnd.planned_flag,
	  wnd.delivery_id,
	  nvl(wnd.status_code,'NO') status_code
FROM      wsh_delivery_details wdd,
	  wsh_new_deliveries wnd,
	  wsh_delivery_assignments_v wda
WHERE     wdd.delivery_detail_id = wda.delivery_detail_id
AND       wda.delivery_id = wnd.delivery_id (+)
AND       wdd.source_line_id = p_changed_attributes.source_line_id
AND       wdd.source_code    = p_source_code
AND       nvl(wdd.line_direction, 'O') IN ('O','IO')  -- J Inbound Logistics jckwok
AND       wdd.delivery_detail_id = decode (p_changed_attributes.delivery_detail_id,
			       NULL , wdd.delivery_detail_id ,
			       p_changed_attributes.delivery_detail_id)
AND       wdd.container_flag = 'N'
AND       wdd.released_status <> 'D'   -- New
ORDER BY  decode(nvl(wnd.status_code,'NO'),'NO',1,'OP',2,'SA',3,10), -- sperera 940/945
          decode(wda.parent_delivery_detail_id,NULL,1,10),
          decode(wnd.planned_flag,'N',1,'Y',2,'F',3,10), --TP release
          decode(wdd.released_status,'N',1,'R',2,'X',3,'B',4,'S',5,'Y',6,10),
          nvl(wdd.requested_quantity,0) asc, -- This will make sure that maximum number of details are accounted for
          wdd.delivery_detail_id;

l_delivery_details_rec c_del_details_cur%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_SHIPPING_CONSTRAINTS';
--
BEGIN

--
-- Debug Statements
--
WSH_UTIL_CORE.Set_Log_Level(p_log_level);
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
    WSH_DEBUG_SV.log(l_module_name,'action_flag',p_changed_attributes.action_flag);
    WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id',p_changed_attributes.delivery_detail_id);
    WSH_DEBUG_SV.log(l_module_name,'original_source_line_id',p_changed_attributes.original_source_line_id);
    WSH_DEBUG_SV.log(l_module_name,'source_header_id',p_changed_attributes.source_header_id);
    WSH_DEBUG_SV.log(l_module_name,'source_line_id',p_changed_attributes.source_line_id);
    WSH_DEBUG_SV.log(l_module_name,'sold_to_org_id',p_changed_attributes.sold_to_org_id);
    WSH_DEBUG_SV.log(l_module_name,'ship_from_org_id',p_changed_attributes.ship_from_org_id);
    WSH_DEBUG_SV.log(l_module_name,'ship_to_org_id',p_changed_attributes.ship_to_org_id);
    WSH_DEBUG_SV.log(l_module_name,'deliver_to_org_id',p_changed_attributes.deliver_to_org_id);
    WSH_DEBUG_SV.log(l_module_name,'intmed_ship_to_org_id',p_changed_attributes.intmed_ship_to_org_id);
    WSH_DEBUG_SV.log(l_module_name,'ordered_quantity',p_changed_attributes.ordered_quantity);
    WSH_DEBUG_SV.log(l_module_name,'released_status',p_changed_attributes.released_status);
    WSH_DEBUG_SV.log(l_module_name,'shipped_quantity',p_changed_attributes.shipped_quantity);
    WSH_DEBUG_SV.log(l_module_name,'customer_item_id',p_changed_attributes.customer_item_id);
    WSH_DEBUG_SV.log(l_module_name,'P_LOG_LEVEL',P_LOG_LEVEL);
 END IF;
--

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

x_action_allowed := 'N';

	IF(p_changed_attributes.source_line_id IS NULL) THEN
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name, 'NULL PASSED FOR SOURCE LINE ID'  );
		END IF;
		--
		x_return_status :=  WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSE

	-- if the source_line_id is not null

    	    IF((p_changed_attributes.action_flag = 'D') OR (p_changed_attributes.action_flag ='C')) THEN

	  OPEN c_del_details_cur;

	  LOOP
	     FETCH c_del_details_cur INTO l_delivery_details_rec;

		IF c_del_details_cur%ROWCOUNT = 0 THEN
			--
			-- Debug Statements
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name, 'NO CORRESPONDING DATA FOUND FOR THE LINE ID' || P_CHANGED_ATTRIBUTES.SOURCE_LINE_ID  );
			END IF;
			--
			x_action_allowed := 'Y';
		END IF;

	     EXIT WHEN c_del_details_cur%NOTFOUND;


	  IF (p_changed_attributes.action_flag = 'D') THEN

	    IF (l_delivery_details_rec.status_code =   'NO') AND -- sperera 940/945
         (l_delivery_details_rec.parent_delivery_detail_id IS NULL) THEN

		x_action_allowed := 'Y';

	   ELSE

	-- action not allowed because of the
	-- status of either delivery or delivery_detail
	-- or because of packing of delivery detail, or delivery is 'SIC'


		x_action_allowed := 'N';

		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name, 'DELIVERY DETAIL RELEASED_STATUS = ' || L_DELIVERY_DETAILS_REC.RELEASED_STATUS  );
		END IF;
		--
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name, 'PARENT DELIVERY DETAIL = ' || L_DELIVERY_DETAILS_REC.PARENT_DELIVERY_DETAIL_ID  );
		END IF;
		--
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name, 'DELIVERY STATUS CODE = ' || L_DELIVERY_DETAILS_REC.STATUS_CODE  );
		END IF;
		--
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name, 'DELIVERY PLANNED FLAG = ' || L_DELIVERY_DETAILS_REC.PLANNED_FLAG  );
		END IF;
		--
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name, 'DELETE ACTION NOT ALLOWED FOR SOURCE LINE ID: ' || P_CHANGED_ATTRIBUTES.SOURCE_LINE_ID );
		END IF;
		--

		exit;

	   END IF;

	  ELSIF (p_changed_attributes.action_flag = 'C') THEN

		IF(l_delivery_details_rec.status_code IN  ('CO', 'IT', 'CL', 'SR', 'SC')) THEN -- sperera 940/945

			x_action_allowed := 'N';

			x_ord_qty_allowed := 0;

		ELSE

			x_action_allowed := 'Y';

		END IF;

	  END IF; -- if action_flag = D

	END LOOP;

     CLOSE c_del_details_cur;

     ELSE

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name, 'INVALID ACTION FLAG'  );
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

     END IF; -- if action_flag = D

    END IF; -- if source_line_id is null


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

WHEN OTHERS THEN
 	x_action_allowed := 'N';
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

	IF c_del_details_cur%ISOPEN THEN
	      CLOSE c_del_details_cur;
        END IF;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END check_shipping_constraints;

END WSH_SHIPPING_CONSTRAINTS_PKG;

/
