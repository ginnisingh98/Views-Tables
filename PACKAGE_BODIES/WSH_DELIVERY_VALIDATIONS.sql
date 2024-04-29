--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_VALIDATIONS" as
/* $Header: WSHDEVLB.pls 120.22.12010000.9 2009/12/30 11:07:05 mvudugul ship $ */
--6156495  : A global variable added to store the value of actual_departure_date
G_ACT_DEPT_DATE DATE;

--3509004:public api changes
PROCEDURE   user_non_updatable_columns
     (p_user_in_rec     IN WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
      p_out_rec         IN WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
      p_in_rec          IN WSH_DELIVERIES_GRP.Del_In_Rec_Type,
      x_return_status   OUT NOCOPY    VARCHAR2);


-----------------------------------------------------------------------------
--
-- Procedure:     Check_Ship_Set
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks if Ship Set is together and returns x_valid_flag
--                TRUE - if Ship Set is together
--                FALSE - if Ship Set is not together
--
-----------------------------------------------------------------------------

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DELIVERY_VALIDATIONS';
--


/* The following 2 global variables added as part of Ship Message Customization
 * Project ( R12 ). These varibales are accessed from Check_Confirm Procedure
 * and are used to cache values for a session.*/
  g_break_ship_set_severity     VARCHAR2(10);
  g_break_smc_severity          VARCHAR2(10);

PROCEDURE check_ship_set( p_delivery_id IN NUMBER,
					 x_valid_flag  OUT NOCOPY  BOOLEAN,
					 x_return_status OUT NOCOPY  VARCHAR2) IS

CURSOR check_ship_set IS
	SELECT dd.delivery_detail_id
	FROM   wsh_delivery_details dd,
		  wsh_delivery_assignments_v da
	WHERE  ((NVL(da.delivery_id, -1) <> p_delivery_id) OR
		   (da.delivery_id = p_delivery_id AND dd.requested_quantity > dd.shipped_quantity
                    AND da.delivery_id IS NOT NULL AND dd.shipped_quantity <> 0)) AND
		  da.delivery_detail_id = dd.delivery_detail_id AND
                  NVL(dd.released_status, 'C') NOT IN ('C' ,'D') AND  -- when the other lines are not shipped
		  dd.container_flag <> 'Y' AND
		  dd.source_code = 'OE' AND
		  (dd.ship_set_id, dd.source_header_id) IN
		    (SELECT DISTINCT dd.ship_set_id, dd.source_header_id
			FROM   wsh_delivery_details dd,
				  wsh_delivery_assignments_v da
		     WHERE  da.delivery_id = p_delivery_id AND
				  da.delivery_id IS NOT NULL AND
				  da.delivery_detail_id = dd.delivery_detail_id AND
				  dd.container_flag <> 'Y' AND
                                  dd.source_code = 'OE' AND
				  dd.ship_set_id IS NOT NULL );
CURSOR check_all_lines_imported IS
SELECT DISTINCT dd.source_code, dd.ship_set_id, dd.source_header_id
FROM   wsh_delivery_details dd,
       wsh_delivery_assignments_v da
WHERE  da.delivery_id = p_delivery_id AND
       da.delivery_id IS NOT NULL AND
       da.delivery_detail_id = dd.delivery_detail_id AND
       dd.container_flag <> 'Y' AND
       dd.source_code = 'OE' AND
       dd.ship_set_id IS NOT NULL ;

l_detail_id NUMBER;
l_status BOOLEAN;
l_ship_set_id NUMBER;
l_source_header_id NUMBER;
l_source_code  WSH_DELIVERY_DETAILS.SOURCE_CODE%TYPE;
others exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_SHIP_SET';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
   END IF;
   --
   x_valid_flag := TRUE;
   OPEN check_all_lines_imported;
   LOOP
     FETCH check_all_lines_imported
     INTO  l_source_code, l_ship_set_id, l_source_header_id;
     IF (check_all_lines_imported%NOTFOUND) THEN
        EXIT;
     END IF;
     l_status := Check_SS_Imp_Pending(l_source_code, l_source_header_id, l_ship_set_id, 'N',x_return_status);
     IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
       raise others;
     ELSE
       IF (l_status = TRUE) THEN
         x_valid_flag := FALSE;
         EXIT;
       END IF;
     END IF;
   END LOOP;
   CLOSE check_all_lines_imported;

   IF (x_valid_flag = TRUE) THEN -- All lines in ship set are imported
     OPEN check_ship_set;
     FETCH check_ship_set INTO l_detail_id;

     IF (check_ship_set%FOUND) THEN
       x_valid_flag := FALSE;
     ELSE
       x_valid_flag := TRUE;
     END IF;

     CLOSE check_ship_set;
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
     WHEN others THEN
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_SHIP_SET');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_ship_set;

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Smc
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks if Ship Model is complete and returns x_valid_flag
--                TRUE - if Ship Model is complete
--                FALSE - if Ship Model is not complete
--
-----------------------------------------------------------------------------

PROCEDURE check_smc ( p_delivery_id   IN  NUMBER,
		      x_valid_flag    OUT NOCOPY  BOOLEAN,
		      x_return_status OUT NOCOPY  VARCHAR2) IS

-- Bug 2284000
CURSOR check_smc(top_model_line NUMBER) IS
        SELECT MAX(OEL.ORDERED_QUANTITY) child_ord_qty, SUM(NVL(WDD.SHIPPED_QUANTITY,0)) child_shp_qty,
               OEL.LINE_ID
        FROM   WSH_DELIVERY_DETAILS WDD, OE_ORDER_LINES_ALL OEL, wsh_delivery_assignments_v WDA
        WHERE  OEL.LINE_ID = WDD.SOURCE_LINE_ID
        AND    WDD.DELIVERY_DETAIL_ID = WDA.DELIVERY_DETAIL_ID
        AND    WDD.SHIP_MODEL_COMPLETE_FLAG = 'Y'
        AND    WDD.SOURCE_CODE = 'OE'
        AND    WDD.CONTAINER_FLAG <> 'Y'
        AND    WDA.DELIVERY_ID IS NOT NULL
        AND    WDA.DELIVERY_ID = p_delivery_id
        AND    WDD.TOP_MODEL_LINE_ID = top_model_line
        GROUP  BY OEL.LINE_ID;
check_smc_rec check_smc%rowtype;

cursor get_top_model IS
       SELECT DISTINCT dd.top_model_line_id, dd.source_header_id , oe.ordered_quantity
       FROM   wsh_delivery_details dd, wsh_delivery_assignments_v da, oe_order_lines_all oe
       WHERE  da.delivery_id = p_delivery_id
       AND    da.delivery_id IS NOT NULL
       AND    dd.ship_model_complete_flag = 'Y'
       AND    da.delivery_detail_id = dd.delivery_detail_id
       AND    dd.source_code = 'OE'
       AND    dd.container_flag <> 'Y'
       AND    dd.top_model_line_id IS NOT NULL
       AND    dd.top_model_line_id = oe.line_id ;

cursor check_item (top_model_line NUMBER, header_id NUMBER) IS
       SELECT line_id
       FROM   oe_order_lines_all
       WHERE  top_model_line_id = top_model_line
       AND    NVL(shippable_flag,'N') = 'Y'
       AND    NVL(cancelled_flag,'N') = 'N'    -- bug 4997888
       AND    ( ato_line_id IS NULL OR
                ( ato_line_id IS NOT NULL AND item_type_code = 'CONFIG' )
              )
       MINUS
       SELECT source_line_id
       FROM   wsh_delivery_details dd, wsh_delivery_assignments_v da
       WHERE  dd.source_header_id = header_id
       AND    dd.source_code = 'OE'
       AND    dd.container_flag <> 'Y'
       AND    da.delivery_id IS NOT NULL
       AND    dd.delivery_detail_id = da.delivery_detail_id
       AND    da.delivery_id = p_delivery_id;

cursor check_config (ato_id NUMBER) IS
       SELECT inventory_item_id
       FROM   oe_order_lines_all
       WHERE  ato_line_id = ato_id
       AND    NVL(shippable_flag,'N') = 'Y'
       AND    item_type_code = 'CONFIG';

cursor get_ato (top_model_line NUMBER) IS
       SELECT ato_line_id
       FROM   oe_order_lines_all
       WHERE  top_model_line_id = top_model_line
       AND    ato_line_id = line_id
       AND    item_type_code NOT IN ('STANDARD','OPTION');

l_detail_id  NUMBER;
l_item_id    NUMBER;
qty          NUMBER;
prev_qty     NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_SMC';
--
BEGIN

   -- Bug 2284000 : Ship Confirm fails for Order with a Model and Cancelled Line
   -- Bug 2284000 : Rewrote Logic to check for completeness of Model before Proportion checking

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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
   END IF;
   --
   x_valid_flag := TRUE;

   FOR model_rec IN get_top_model LOOP

       -- Check for ATO Models and whether the Configured Item has been created or not

       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Top Model Line ID',model_rec.top_model_line_id);
       END IF;
       --

       -- Get all the ATO Model IDs
       FOR get_ato_rec IN get_ato(model_rec.top_model_line_id) LOOP
         --
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'ATO Line ID',get_ato_rec.ato_line_id);
         END IF;
         --

           -- Check if the Configured Item is available, if not SMC is broken
           OPEN check_config(get_ato_rec.ato_line_id);
           FETCH check_config INTO l_item_id;
           IF check_config%NOTFOUND THEN
              x_valid_flag := FALSE;
              CLOSE check_config;
              EXIT;
           END IF;
           CLOSE check_config;

       END LOOP;

       IF x_valid_flag THEN

          -- Check if at least one of the Included Items for the Model is not selected for the delivery
          -- This means SMC is broken and no more checks are needed
          OPEN check_item (model_rec.top_model_line_id, model_rec.source_header_id);
          FETCH check_item INTO l_item_id;
          IF check_item%NOTFOUND THEN
             l_item_id := 0;
          END IF;
          CLOSE check_item;

          IF l_item_id = 0 THEN

             prev_qty:=null; --bug 2709011

             -- All Included Items are selected
             OPEN check_smc(model_rec.top_model_line_id);
             FETCH check_smc INTO check_smc_rec;
             WHILE (check_smc%FOUND) AND (x_valid_flag)
             LOOP
                 qty := (model_rec.ordered_quantity * check_smc_rec.child_shp_qty) / check_smc_rec.child_ord_qty;

                 IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Ordered Qty',model_rec.ordered_quantity);
                   WSH_DEBUG_SV.log(l_module_name,'Child Shp Qty',check_smc_rec.child_shp_qty);
                   WSH_DEBUG_SV.log(l_module_name,'Child Ord Qty',check_smc_rec.child_ord_qty);
                   WSH_DEBUG_SV.log(l_module_name,'Prev Qty',qty);
                 END IF;

                 IF ( NVL(prev_qty,qty) <> qty ) THEN
                     x_valid_flag := FALSE;
                 ELSE
                     prev_qty := qty;
                 END IF;

                 FETCH check_smc INTO check_smc_rec;
              END LOOP;
              CLOSE check_smc;

          ELSE
              x_valid_flag := FALSE;
          END IF;

       END IF;

       IF NOT (x_valid_flag) THEN
          EXIT;
       END IF;

   END LOOP;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
     WHEN others THEN
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_SMC');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_smc;

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Arrival_Set
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks if Arrival set is complete and returns a valid_flag
--                TRUE - if Arrival Set is complete
--                FALSE - if Arrival Set is not complete
--
-----------------------------------------------------------------------------

PROCEDURE check_arrival_set( p_delivery_id IN NUMBER,
                             x_valid_flag  OUT NOCOPY  BOOLEAN,
                             x_return_status OUT NOCOPY  VARCHAR2) IS

CURSOR check_arrival_set IS
SELECT 1 from dual
WHERE exists (
   SELECT 1
   FROM   wsh_delivery_details dd,
          wsh_delivery_assignments_v da
   WHERE  ((NVL(da.delivery_id, -1) <> p_delivery_id) OR
           (da.delivery_id = p_delivery_id AND dd.requested_quantity > dd.shipped_quantity
            AND da.delivery_id IS NOT NULL AND dd.shipped_quantity <> 0))
   AND    da.delivery_detail_id = dd.delivery_detail_id
   AND    dd.container_flag <> 'Y'
   AND    dd.source_code = 'OE'
   AND    (dd.arrival_set_id, dd.source_header_id) IN
             (SELECT DISTINCT dd.arrival_set_id, dd.source_header_id
              FROM   wsh_delivery_details dd,
                     wsh_delivery_assignments_v da
              WHERE  da.delivery_id = p_delivery_id
              AND    da.delivery_id IS NOT NULL
              AND    da.delivery_detail_id = dd.delivery_detail_id
              AND    dd.container_flag <> 'Y'
              AND    dd.source_code = 'OE'
              AND    dd.arrival_set_id IS NOT NULL ) );

l_detail_id NUMBER;
others exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_ARRIVAL_SET';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
   END IF;
   --
   x_valid_flag := TRUE;
   OPEN check_arrival_set;
   FETCH check_arrival_set INTO l_detail_id;

   IF (check_arrival_set%FOUND) THEN
      x_valid_flag := FALSE;
   ELSE
      x_valid_flag := TRUE;
   END IF;

   CLOSE check_arrival_set;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
     WHEN others THEN
           wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_ARRIVAL_SET');
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_arrival_set;

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Del_Not_I_T
-- Parameters:    p_delivery_id, delivery_status, x_return_status
-- Description:   Checks if delivery is In-transit status and sets a warning
--
-----------------------------------------------------------------------------

PROCEDURE check_del_not_i_t( p_delivery_id IN NUMBER,
                     p_delivery_status IN VARCHAR2,
				 x_return_status OUT NOCOPY  VARCHAR2) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_DEL_NOT_I_T';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_STATUS',P_DELIVERY_STATUS);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF (p_delivery_status = 'IT') THEN
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSIGN_TR_DEL_IT');
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	 wsh_util_core.add_message(x_return_status);
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
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_DEL_NOT_I_T');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_del_not_i_t;

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Released_Lines
-- Parameters:    p_delivery_id, rel_num, unrel_num, x_return_status
-- Description:   Checks if delivery has atleast one released and one unreleased lines and sets a warning
--
-----------------------------------------------------------------------------

PROCEDURE check_released_lines( p_delivery_id IN NUMBER,
                     rel_num IN NUMBER,
                     unrel_num IN NUMBER,
				 x_return_status OUT NOCOPY  VARCHAR2) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_RELEASED_LINES';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'REL_NUM',REL_NUM);
       WSH_DEBUG_SV.log(l_module_name,'UNREL_NUM',UNREL_NUM);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF (rel_num <> 0) AND (unrel_num > 0) THEN

      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CONFIRM_ERROR');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	 wsh_util_core.add_message(x_return_status);

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
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_RELEASED_LINES');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_released_lines;

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Del_Unpacked
-- Parameters:    p_delivery_id, p_cont_exists_flag, p_unpacked_flag, x_return_status
-- Description:   Checks if delivery has containers and is unpacked and issues a warning
--
-----------------------------------------------------------------------------

PROCEDURE check_del_unpacked( p_delivery_id IN NUMBER,
                     p_cont_exists_flag IN BOOLEAN,
                     p_unpacked_flag IN BOOLEAN,
		     x_return_status OUT NOCOPY  VARCHAR2) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_DEL_UNPACKED';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_CONT_EXISTS_FLAG',P_CONT_EXISTS_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_UNPACKED_FLAG',P_UNPACKED_FLAG);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF (p_unpacked_flag) THEN
     FND_MESSAGE.SET_NAME('WSH','WSH_DEL_PACK_ITEMS_UNPACKED');
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     wsh_util_core.add_message(x_return_status);
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
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_DEL_UNPACKED');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_del_unpacked;

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Del_Overfilled
-- Parameters:    p_delivery_id, p_cont_exists_flag, p_unpacked_flag, x_return_status
-- Description:   Checks if delivery has containers and does not have overfilled containers and issues a warning
--
-----------------------------------------------------------------------------

PROCEDURE check_del_overfilled( p_delivery_id IN NUMBER,
                     p_cont_exists_flag IN BOOLEAN,
                     p_overfilled_flag IN BOOLEAN,
				 x_return_status OUT NOCOPY  VARCHAR2) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_DEL_OVERFILLED';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_CONT_EXISTS_FLAG',P_CONT_EXISTS_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_OVERFILLED_FLAG',P_OVERFILLED_FLAG);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF (p_cont_exists_flag) THEN

      IF (p_overfilled_flag) THEN
	    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CONT_OVERPACKED');
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	    wsh_util_core.add_message(x_return_status);
      END IF;

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
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_DEL_OVERFILLED');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_del_overfilled;

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Del_Underfilled
-- Parameters:    p_delivery_id, p_cont_exists_flag, p_underfilled_flag, x_return_status
-- Description:   Checks if delivery has containers and does not have under filled containers and issues a warning
--
-----------------------------------------------------------------------------

PROCEDURE check_del_underfilled( p_delivery_id IN NUMBER,
                     p_cont_exists_flag IN BOOLEAN,
                     p_underfilled_flag IN BOOLEAN,
				 x_return_status OUT NOCOPY  VARCHAR2) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_DEL_UNDERFILLED';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_CONT_EXISTS_FLAG',P_CONT_EXISTS_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_UNDERFILLED_FLAG',P_UNDERFILLED_FLAG);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF (p_cont_exists_flag) THEN

      IF (p_underfilled_flag) THEN
	    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CONT_UNDERPACKED');
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	    wsh_util_core.add_message(x_return_status);

      END IF;

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
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_DEL_UNDERFILLED');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_del_underfilled;


-----------------------------------------------------------------------------
--
-- Procedure:     Check_Del_Final_Dest
-- Parameters:    p_delivery_id, p_final_dropoff_id, p_ultimate_dropoff_id, x_return_status
-- Description:   Checks if delivery final destination matches ultimate dropoff destination and returns a warning if it does not
--
-----------------------------------------------------------------------------

PROCEDURE check_del_final_dest( p_delivery_id IN NUMBER,
                     p_final_dropoff_id IN NUMBER,
                     p_ultimate_dropoff_id IN NUMBER,
				 x_return_status OUT NOCOPY  VARCHAR2) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_DEL_FINAL_DEST';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_FINAL_DROPOFF_ID',P_FINAL_DROPOFF_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ULTIMATE_DROPOFF_ID',P_ULTIMATE_DROPOFF_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF (p_final_dropoff_id <> p_ultimate_dropoff_id) THEN
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NO_ULTIMATE_DROPOFF');
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	 wsh_util_core.add_message(x_return_status);
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
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_DEL_FINAL_DEST');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END check_del_final_dest;

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Calendar
-- Parameters:    p_entity_type, p_ship_date, p_ship_assoc_type, p_ship_location_id,
--                p_freight_code, p_freight_org_id,
--			   p_receive_date, p_receive_assoc_type, p_receive_location_id,
--			   x_return_status
-- Description:   Checks if p_ship_date and p_rec_date are valid for the calendar
--                at location p_location_id
--                Values for p_entity_type are
--                    DELIVERY
--                Values for p_assoc_type are
--                    CUSTOMER
--                    VENDOR
--                    ORG
--                    CARRIER
--
-----------------------------------------------------------------------------

PROCEDURE Check_Calendar ( p_entity_type     		IN  VARCHAR2,
                           p_entity_id                 IN  NUMBER,
					  p_ship_date               	IN  DATE,
					  p_ship_assoc_type         	IN  VARCHAR2,
					  p_ship_location_id     	IN  NUMBER,
					  p_freight_code       		IN  VARCHAR2,
					  p_freight_org_id     		IN  NUMBER,
					  p_receive_date              IN  DATE,
					  p_receive_assoc_type        IN  VARCHAR2,
					  p_receive_location_id       IN  NUMBER,
					  p_update_flag               IN  VARCHAR2,
					  x_return_status			OUT NOCOPY  VARCHAR2) IS
l_msg_count 	NUMBER;
l_msg_data     VARCHAR2(2000);
l_return_code  NUMBER;
l_suggest_ship_date    DATE;
l_suggest_receive_date DATE;
l_temp_suggest_receive_date DATE;--Bug 8687915:New local variable

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_CALENDAR';
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
       WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE',P_ENTITY_TYPE);
       WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_DATE',P_SHIP_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_ASSOC_TYPE',P_SHIP_ASSOC_TYPE);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_LOCATION_ID',P_SHIP_LOCATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_CODE',P_FREIGHT_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_ORG_ID',P_FREIGHT_ORG_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_RECEIVE_DATE',P_RECEIVE_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_RECEIVE_ASSOC_TYPE',P_RECEIVE_ASSOC_TYPE);
       WSH_DEBUG_SV.log(l_module_name,'P_RECEIVE_LOCATION_ID',P_RECEIVE_LOCATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_FLAG',P_UPDATE_FLAG);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF (p_entity_type = 'DELIVERY') THEN

		  --
		  -- Debug Statements
		  --
		  IF l_debug_on THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.TRANSPORT_DATES',WSH_DEBUG_SV.C_PROC_LEVEL);
		  END IF;
		  --
		  wsh_cal_asg_validations.transport_dates(
                   p_api_version_number 		=> 1.0
                 , p_init_msg_list     			=> FND_API.G_FALSE
                 , x_return_status    			=> x_return_status
                 , x_msg_count       			=> l_msg_count
                 , x_msg_data       			=> l_msg_data
                 , p_priority      			=> 'SHIP'
                 , p_ship_date    				=> p_ship_date
                 , p_ship_assoc_type    		=> p_ship_assoc_type
                 , p_ship_location_id    		=> p_ship_location_id
                 , p_ship_vendor_site_id		=> to_number(NULL)
                 , p_ship_customer_site_use_id 	=> to_number(NULL)
                 , p_ship_time_matters     		=> FALSE
                 , p_freight_code     			=> p_freight_code
                 , p_freight_org_id  			=> p_freight_org_id
                 , p_receive_date   			=> p_receive_date
                 , p_receive_assoc_type			=> p_receive_assoc_type
                 , p_receive_location_id		=> p_receive_location_id
                 , p_receive_vendor_site_id  	=> to_number(NULL)
                 , p_receive_customer_site_use_id	=> to_number(NULL)
                 , p_receive_time_matters   		=> FALSE
                 , x_return_code           		=> l_return_code
                 , x_suggest_ship_date    		=> l_suggest_ship_date
                 , x_suggest_receive_date		=> l_suggest_receive_date
                 , p_primary_threshold  		=> 10
                 , p_secondary_threshold		=> 10
			  );

          IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) OR (l_return_code = 0) THEN
		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
		       WSH_DEBUG_SV.pop(l_module_name);
		   END IF;
		   --
		   RETURN;
          END IF;

		IF (l_return_code IN (1,2,3,4)) AND (l_suggest_ship_date <> p_ship_date) THEN
		   IF (p_update_flag <> 'Y') THEN
		      FND_MESSAGE.SET_NAME('WSH','WSH_CAL_SHIP_DATE_ALT');
             ELSE
		      FND_MESSAGE.SET_NAME('WSH','WSH_CAL_SHIP_DATE_ALT_UPDATE');
		   END IF;
	        --
	        -- Debug Statements
	        --
	        IF l_debug_on THEN
	            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	        END IF;
	        --
	        FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_entity_id));
		   FND_MESSAGE.SET_TOKEN('SHIP',fnd_date.date_to_chardate(p_ship_date));
		   FND_MESSAGE.SET_TOKEN('SUGGESTED',fnd_date.date_to_chardate(l_suggest_ship_date));
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		   wsh_util_core.add_message(x_return_status);
          END IF;
                   --Bug 8687915 :Handling Return codes appropriately.
 	           --             Return_Code 4 : No valid date according to Receiving Calendar in the next 10 days.
 	           --             Return_Code 5 : No valid date according to Shipping/Carrier Calendar in the next 10 days.
                   --             When Return Code is 5 (Valid Ship Date  out of tolerence),
                   --             messages related to Suggested Receiving Date should not be shown )
                l_temp_suggest_receive_date := p_receive_date+(l_suggest_ship_date-p_ship_date);
		IF (l_return_code IN (1,2,3)) AND (l_suggest_receive_date <> p_receive_date) THEN
                    --Bug 8687915: If drop_off date has changed due to a change in 'pick_up' date and NOT due to 'RCV Calendar'
                    --             message should NOT talk about Rcv calendar.
                    IF l_suggest_ship_date <> p_ship_date and l_suggest_receive_date = l_temp_suggest_receive_date THEN
                        IF (p_update_flag <> 'Y') THEN
                            FND_MESSAGE.SET_NAME('WSH','WSH_REC_DATE_ALT');
                        ELSE
                            FND_MESSAGE.SET_NAME('WSH','WSH_REC_DATE_ALT_UPDATE');
                        END IF;
                        FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_entity_id));
                        FND_MESSAGE.SET_TOKEN('RECEIVE',fnd_date.date_to_chardate(p_receive_date));
                        FND_MESSAGE.SET_TOKEN('SUGGESTED',fnd_date.date_to_chardate(l_suggest_receive_date));
                    ELSE
                        IF (p_update_flag <> 'Y') THEN
                            FND_MESSAGE.SET_NAME('WSH','WSH_CAL_REC_DATE_ALT');
                        ELSE
                            FND_MESSAGE.SET_NAME('WSH','WSH_CAL_REC_DATE_ALT_UPDATE');
                        END IF;
                        FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_entity_id));
                        --Bug 8687915: Passing the date validated against Receiving Calendar, instead of p_recv_date.
                        FND_MESSAGE.SET_TOKEN('RECEIVE',fnd_date.date_to_chardate(l_temp_suggest_receive_date));
                        FND_MESSAGE.SET_TOKEN('SUGGESTED',fnd_date.date_to_chardate(l_suggest_receive_date));
                    END IF;
	        --
	        -- Debug Statements
	        --
	        IF l_debug_on THEN
	            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	        END IF;
	        --
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		   wsh_util_core.add_message(x_return_status);
          END IF;

		IF (l_return_code = 6) THEN
		   FND_MESSAGE.SET_NAME('WSH','WSH_CAL_INV_DATES');
	        --
	        -- Debug Statements
	        --
	        IF l_debug_on THEN
	            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	        END IF;
	        --
	        FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_entity_id));
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		   wsh_util_core.add_message(x_return_status);
          END IF;

          IF (p_update_flag = 'Y') THEN

		   IF (l_suggest_ship_date <> p_ship_date) THEN
			 UPDATE wsh_new_deliveries
			 SET    initial_pickup_date = l_suggest_ship_date
			 WHERE  delivery_id = p_entity_id;
             END IF;

		   IF (l_suggest_receive_date <> p_receive_date) THEN
			 UPDATE wsh_new_deliveries
			 SET    ultimate_dropoff_date = l_suggest_receive_date
			 WHERE  delivery_id = p_entity_id;
             END IF;

          END IF;

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
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_CALENDAR');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Calendar;

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Plan
-- Parameters:    delivery_id, x_return_status
-- Description:   Checks for Plan action pre-requisites which are
--          - Delivery status is OPEN or PACKED
-- 		  - At least one delivery detail is assigned
--		  - SMC models must be together [warning]
--		  - Ship Sets must be complete [warning]
--                - Delivery flow on trip/s is valid [error/warning]
--
-----------------------------------------------------------------------------

PROCEDURE Check_Plan ( p_delivery_id 		IN  NUMBER,
		       x_return_status 		OUT NOCOPY  VARCHAR2,
                       p_called_for_sc          IN BOOLEAN default false) IS
CURSOR delivery_info IS
SELECT status_code,
       planned_flag,
	  organization_id,
	  ship_method_code,
	  initial_pickup_date,
	  ultimate_dropoff_date,
	  initial_pickup_location_id,
	  ultimate_dropoff_location_id,
   nvl(shipment_direction,'O') shipment_direction,
          delivery_type
FROM   wsh_new_deliveries
WHERE  delivery_id = p_delivery_id;


CURSOR delivery_details IS
SELECT da.delivery_detail_id
FROM   wsh_delivery_assignments_v da,
       wsh_delivery_details dd
WHERE  dd.delivery_detail_id = da.delivery_detail_id AND
	  da.delivery_id = p_delivery_id AND
	  da.delivery_id IS NOT NULL AND
	  nvl(dd.container_flag,'N') <> 'Y';

---BUG No:4241880.Cursor changed
  CURSOR get_freight(p_ship_method_code VARCHAR2,p_organization_id NUMBER) IS
  SELECT freight_code
  FROM   wsh_carriers wc,wsh_carrier_services wcs,wsh_org_carrier_services wocs
  WHERE  wc.carrier_id=wcs.carrier_id AND
	 wcs.carrier_service_id=wocs.carrier_service_id AND
	 wcs.ship_method_code = p_ship_method_code AND
	 wocs.organization_id = p_organization_id;
---BUG No:4241880.Cursor changed ends

/*
CURSOR get_freight(p_ship_method_code VARCHAR2,p_organization_id NUMBER) IS
SELECT freight_code
FROM   wsh_carrier_ship_methods_v
WHERE  ship_method_code = p_ship_method_code AND
       organization_id = p_organization_id;
*/

l_detail_id NUMBER;
l_valid_flag BOOLEAN;
l_status_code VARCHAR2(2);
l_planned_flag VARCHAR2(1);
l_return_status VARCHAR2(1);
l_org_id      NUMBER;
l_ship_method_code VARCHAR2(30);
l_freight_code VARCHAR2(30);
l_rec_date    DATE;
l_ship_date   DATE;
l_ship_from_location NUMBER;
l_ship_to_location NUMBER;
l_delivery_type VARCHAR2(30);
--6156495  : Added local variables
l_temp_ship_date   DATE;
l_temp_rec_date    DATE;

NO_FREIGHT_CODE EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_PLAN';
--
l_shipping_control     VARCHAR2(30);
l_routing_response_id  NUMBER;
l_routing_request_flag VARCHAR2(30);
l_shipment_direction   VARCHAR2(30);
l_ship_assoc_type      VARCHAR2(30);
l_receive_assoc_type      VARCHAR2(30);
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'p_called_for_sc',p_called_for_sc);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN delivery_info;
   FETCH delivery_info INTO l_status_code,
					   l_planned_flag,
					   l_org_id,
                                           l_ship_method_code,
					   l_ship_date,
					   l_rec_date,
					   l_ship_from_location,
					   l_ship_to_location,
                   l_shipment_direction,   -- J-IB-NPARIKH
                   l_delivery_type;

   IF (delivery_info%NOTFOUND) THEN
	 CLOSE delivery_info;
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_FOUND');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   ELSE
     IF l_ship_method_code IS NULL THEN
          l_freight_code:=null;
     ELSE
          OPEN get_freight(l_ship_method_code,l_org_id);
          FETCH get_freight INTO l_freight_code;

          IF (get_freight%NOTFOUND) THEN
            --bug 3389356 ship method shud be associated with org for a contents firm - this check
            --need not be performed here - LOV is restricting, for public api's restrict
            --in public api itself for create/update
            --don't raise error here
            l_freight_code:=null;
          END IF;

          CLOSE get_freight;
     END IF;
   END IF;

   CLOSE delivery_info;

   IF (l_planned_flag IN ('Y','F')) THEN
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;

   --removed code causing error for closed, in-transit dels

   IF l_delivery_type = 'STANDARD' THEN

     OPEN  delivery_details;
     FETCH delivery_details INTO l_detail_id;

     IF (delivery_details%NOTFOUND) THEN
	 CLOSE delivery_details;
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NO_DETAILS');
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     END IF;

     CLOSE delivery_details;
   END IF;

 IF  l_shipment_direction IN ('O','IO') --J-IB-NPARIKH
 THEN
 --{
   --
   -- Ship-model complete and ship-set checks are required only
   -- for outbound (O/IO) deliveries
   --

   -- Bug 4519097 : The following IF condition is commong for both ship set and smc.So
   -- moved the END IF of the IF stmt after the check on shipsets is also done.
-- TPA change
   IF NOT NVL(p_called_for_sc,FALSE)  THEN --{
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_DELIVERY_PKG.CHECK_SMC',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_tpa_delivery_pkg.check_smc( p_delivery_id, l_valid_flag, l_return_status);

      IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	    x_return_status := l_return_status;
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    --
	    RETURN;
      END IF;

      IF NOT (l_valid_flag) THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_DEL_SMC_INCOMPLETE');
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	 WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
      END IF;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_DELIVERY_PKG.CHECK_SHIP_SET',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     wsh_tpa_delivery_pkg.check_ship_set( p_delivery_id, l_valid_flag, l_return_status);

     IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	 x_return_status := l_return_status;
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
     END IF;

     IF NOT (l_valid_flag) THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_DEL_SHIP_SET_INCOMPLETE');

        -- Bug 2429632 Added a  Delivery Name Token to the above error message
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
        -- End Bug 2429632

	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     END IF;
     --
   END IF;
   --}
 --}
 END IF;
/* H integration anxsharm use name of parameters */
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.UPDATE_LEG_SEQUENCE',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_new_delivery_actions.update_leg_sequence(
     p_delivery_id => p_delivery_id,
     x_return_status => l_return_status);

   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	 x_return_status := l_return_status;
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;

-- Check for transportation calendar requirements

    -- J-IB-NPARIKH-{
    IF l_shipment_Direction = 'I'
    THEN
        l_ship_assoc_type       := 'VENDOR';
        l_receive_assoc_type    := 'ORG';
    ELSIF l_shipment_direction = 'D'
    THEN
        l_ship_assoc_type       := 'VENDOR';
        l_receive_assoc_type    := 'CUSTOMER';
    ELSE
-- modified ship_assoc type to 'HR_LOCATION' and receive_assoc_type to 'CUSTOMER_SITE' for bug 5880742
        l_ship_assoc_type       := 'HR_LOCATION';
        l_receive_assoc_type    := 'CUSTOMER_SITE';
    END IF;
    -- J-IB-NPARIKH-}
  --6156495  :Determining the dates to be validated against the shipping and Receiving Calendars
   IF G_ACT_DEPT_DATE IS NOT NULL
   THEN
       l_temp_ship_date := G_ACT_DEPT_DATE;
       IF l_rec_date > G_ACT_DEPT_DATE
       THEN
        l_temp_rec_date := l_rec_date;
       ELSE
        l_temp_rec_date := G_ACT_DEPT_DATE;
       END IF;
    ELSE
       l_temp_ship_date := l_ship_date;
       l_temp_rec_date  := l_rec_date;
    END IF;

   -- TPA Change
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_DELIVERY_PKG.CHECK_CALENDAR',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_tpa_delivery_pkg.check_calendar(p_entity_type    		=> 'DELIVERY',
                  p_entity_id     			=> p_delivery_id,
--			   p_ship_date    			=> l_ship_date,--6156495
			   p_ship_date    			=> l_temp_ship_date,
           p_ship_assoc_type        => l_ship_assoc_type, --'ORG',
			   p_ship_location_id		=> l_ship_from_location,
			   p_freight_code   		=> l_freight_code,
			   p_freight_org_id			=> l_org_id,
--			   p_receive_date 			=> l_rec_date, --6156495
			   p_receive_date 			=> l_temp_rec_date,
           p_receive_assoc_type     => l_receive_assoc_type, --'CUSTOMER',
			   p_receive_location_id		=> l_ship_to_location,
			   p_update_flag       		=> 'Y',
			   x_return_status			=> l_return_status);

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	   x_return_status := l_return_status;
    END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
     WHEN   NO_FREIGHT_CODE THEN
            fnd_message.set_name('WSH','WSH_FREIGHT_CODE_NOT_FOUND');
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'NO_FREIGHT_CODE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_FREIGHT_CODE');
            END IF;
            --
     WHEN others THEN
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_PLAN');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Plan;


-----------------------------------------------------------------------------
--
-- Procedure:     Check_Unplan
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Unplan action pre-requisites which are
-- 		  - Delivery status is OPEN or IN-TRANSIT
--                - Delivery is planned
--
-----------------------------------------------------------------------------

PROCEDURE Check_Unplan ( p_delivery_id 		IN  NUMBER,
		         x_return_status 	OUT NOCOPY  VARCHAR2) IS

CURSOR delivery_status IS
SELECT status_code,
	  planned_flag,
        nvl(shipment_direction,'O') shipment_direction   -- J-IB-NPARIKH
FROM   wsh_new_deliveries
WHERE  delivery_id = p_delivery_id;

l_status_code VARCHAR2(2);
l_planned_flag VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_UNPLAN';
--
--
l_return_status        VARCHAR2(10);
l_shipping_control     VARCHAR2(30);
l_routing_response_id  NUMBER;
l_routing_request_flag VARCHAR2(30);
l_shipment_direction   VARCHAR2(30);
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN delivery_status;
   FETCH delivery_status INTO l_status_code, l_planned_flag,l_shipment_direction;

   IF (delivery_status%NOTFOUND) THEN
	 CLOSE delivery_status;
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_FOUND');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;

   CLOSE delivery_status;

   IF (l_planned_flag NOT IN ('Y','F')) THEN
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;

   --tkt removed code for raising error for IT CL cases

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
     WHEN others THEN
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_UNPLAN');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Unplan;



-----------------------------------------------------------------------------
--
-- Procedure:     Check_Tender_Load
-- Parameters:    p_delivery_leg_id, x_return_status
-- Description:   Checks for Tender Load action pre-requisites which are
-- 		  - Delivery satisfies rules for Plan
--                - Weight/Volume information must be specified
--
-----------------------------------------------------------------------------

PROCEDURE Check_Tender_Load ( p_delivery_leg_id IN  NUMBER,
		             x_return_status 	OUT NOCOPY  VARCHAR2) IS

CURSOR delivery_details IS
SELECT dl.delivery_id,
	  dg.gross_weight,
	  dg.net_weight,
	  dg.weight_uom_code,
	  dg.volume,
	  dg.volume_uom_code
FROM   wsh_delivery_legs dg,
	  wsh_new_deliveries dl
WHERE  dl.delivery_id = dg.delivery_id AND
	  dg.delivery_leg_id = p_delivery_leg_id;

others        EXCEPTION;
l_delivery_id NUMBER;
l_gr_weight   NUMBER;
l_net_weight  NUMBER;
l_wt_uom      VARCHAR2(3);
l_volume      NUMBER;
l_vol_uom     VARCHAR2(3);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_TENDER_LOAD';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_LEG_ID',P_DELIVERY_LEG_ID);
   END IF;
   --
   OPEN delivery_details;
   FETCH delivery_details INTO l_delivery_id, l_gr_weight, l_net_weight, l_wt_uom, l_volume, l_vol_uom;

   IF (delivery_details%NOTFOUND) THEN
      CLOSE delivery_details;
	 raise others;
   END IF;
   CLOSE delivery_details;

   Check_Plan( l_delivery_id, x_return_status);

   IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_PLAN_ERROR');
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(l_delivery_id));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;

   IF (l_gr_weight IS NULL) or (l_gr_weight = 0) or (l_wt_uom IS NULL) THEN
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_LT_WT_VOL_MISSING');
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(l_delivery_id));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;

   IF (l_volume IS NULL) or (l_volume = 0) or (l_vol_uom IS NULL) THEN
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_LT_WT_VOL_MISSING');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	 wsh_util_core.add_message(x_return_status);
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
      WHEN others THEN
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_UNPLAN');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Tender_Load;




-----------------------------------------------------------------------------
--
-- Procedure:     Check_Assign_Trip
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Assign Trip action pre-requisites which are
-- 		  - Delivery status is not CLOSED
--		  - Trip status is not CLOSED
--                - Pickup Stop status is OPEN or ARRIVED
--                - Pickup Stop sequence number is smaller than Dropoff Stop sequence number
--                - If GROUP_BY_CARRIER_FLAG set then freight carrier same as that on trip [warning]
--                - Delivery status is not IN-TRANSIT [warning]
-- NOT YET IMPLEMENTED               - If trip is Planned and has Vehicle information then no stops on the trip are over filled by addition of this delivery [warning]

--
--Bug 2313077 :
/*
      1. Report an error if Ship Method on Trip does not belong to Orgs of
         deliveries being assigned to the trip
      2. Ship Method LOV on the trip shows all available values for all Orgs
	 on the trip
      3. If delivery Ship Method is different from Trips provide a warning
	 when assigning to the trip (unless Del SM is null)
*/
-----------------------------------------------------------------------------

PROCEDURE Check_Assign_Trip ( p_delivery_id     IN  NUMBER,
			      p_trip_id 	IN  NUMBER,
				 p_pickup_stop_id IN NUMBER,
				 p_dropoff_stop_id IN NUMBER,
		              x_return_status 	OUT NOCOPY  VARCHAR2) IS

CURSOR delivery_status IS
SELECT status_code,
	  organization_id,
	  ship_method_code,
      nvl(shipment_direction,'O') shipment_direction,   -- J-IB-NPARIKH
      nvl(ignore_for_planning, 'N') ignore_for_planning
FROM   wsh_new_deliveries
WHERE  delivery_id = p_delivery_id;

CURSOR trip_status IS
SELECT status_code,ship_method_code, planned_flag,
       nvl(ignore_for_planning, 'N') ignore_for_planning
FROM   wsh_trips
WHERE  trip_id = p_trip_id;

/*
CURSOR org_ship_method (l_organization_id NUMBER,l_ship_method_code VARCHAR2)  IS
SELECT ship_method_code
FROM   wsh_carrier_ship_methods
WHERE  organization_id=l_organization_id
AND ship_method_code=l_ship_method_code;
*/
--replace above cursor with the one below
--when changes for carrier enhancements are being done

---BUG No:4241880.Cursor changed
CURSOR org_ship_method (l_organization_id NUMBER,l_ship_method_code VARCHAR2)  IS
SELECT ship_method_code
FROM   wsh_carrier_services wcs, wsh_org_carrier_services wocs
WHERE  wocs.organization_id=l_organization_id
and wocs.carrier_service_id=wcs.carrier_service_id
AND wcs.ship_method_code=l_ship_method_code;
---BUG No:4241880.Cursor changed ends

CURSOR stop_status (l_stop_id NUMBER) IS
SELECT status_code,
	  planned_arrival_date,
	  planned_departure_date
FROM   wsh_trip_Stops
WHERE  stop_id = l_stop_id AND
	  status_code <> 'OP';

l_del_status  VARCHAR2(2);
l_org_id      NUMBER;
l_del_ship_method VARCHAR2(30);
l_shipment_direction VARCHAR2(30);
l_trip_status VARCHAR2(2);
l_trip_ship_method VARCHAR2(30);
l_tmp_ship_method VARCHAR2(30);

l_trip_planflag   VARCHAR2(1);
l_trip_ignore     VARCHAR2(1);
l_del_ignore      VARCHAR2(1);
trip_diffignore   EXCEPTION;
trip_firm         EXCEPTION;

l_stop_status VARCHAR2(2);

l_pickup_arr_date  DATE;
l_pickup_dep_date  DATE;
l_dropoff_arr_date DATE;
l_dropoff_dep_date DATE;

l_group_by_attr    wsh_delivery_autocreate.group_by_flags_rec_type;
l_return_status    VARCHAR2(1);

invalid_status EXCEPTION;
INVALID_TRIPSHIPMETHOD_DEL_ORG EXCEPTION;
INVALID_DEL_TRIP_SHIPMETHOD EXCEPTION;

others EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_ASSIGN_TRIP';
--
l_shipping_control     VARCHAR2(30);
l_routing_response_id  NUMBER;
l_routing_request_flag VARCHAR2(30);
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_PICKUP_STOP_ID',P_PICKUP_STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DROPOFF_STOP_ID',P_DROPOFF_STOP_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN delivery_status;
   FETCH delivery_status INTO l_del_status, l_org_id, l_del_ship_method, l_shipment_direction, l_del_ignore;

   IF (delivery_status%NOTFOUND) THEN
	 CLOSE delivery_status;
	 raise others;
   END IF;

   CLOSE delivery_status;
     --
     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'l_del_status', l_del_status);
        wsh_debug_sv.log(l_module_name, 'l_shipment_direction', l_shipment_direction);
        wsh_debug_sv.log(l_module_name, 'l_del_ignore', l_del_ignore);
     END IF;
     --

     /*
    -- J-IB-NPARIKH-{
     IF l_shipment_direction NOT IN ('O','IO')
     THEN
     --{
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GET_SHIPPING_CONTROL',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         GET_SHIPPING_CONTROL
            (
                p_delivery_id           => p_delivery_id,
                x_shipping_control      => l_shipping_control,
                x_routing_response_id   => l_routing_response_id,
                x_routing_request_flag  => l_routing_request_flag,
                x_return_status         => l_return_status
            );
         --
         --
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'l_return_status', l_return_status);
            wsh_debug_sv.log(l_module_name, 'l_shipping_control', l_shipping_control);
            wsh_debug_sv.log(l_module_name, 'l_routing_response_id', l_routing_response_id);
            wsh_debug_sv.log(l_module_name, 'l_routing_request_flag', l_routing_request_flag);
            --
         END IF;
         --
        --
        IF l_return_status = wsh_util_core.g_ret_sts_unexp_error THEN
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = wsh_util_core.g_ret_sts_error THEN
           raise FND_API.G_EXC_ERROR;
        END IF;
        --
     --}
     END IF;
     --
     IF l_shipment_direction   IN ('O','IO')
     OR l_shipping_control     <> 'SUPPLIER'
     OR l_routing_request_flag <> 'N'
     THEN
     -- J-IB-NPARIKH-}
     --{
      */
         IF  l_del_status          = 'CL'
         THEN
              raise invalid_status;
         END IF;
         --
           -- TPA Change
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_DELIVERY_PKG.CHECK_DEL_NOT_I_T',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           --
           wsh_tpa_delivery_pkg.check_del_not_i_t(p_delivery_id, l_del_status, l_return_status);

           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
             x_return_status := l_return_status;
             IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                --
                RETURN;
              END IF;
           END IF;
     --}
     --END IF;


   OPEN trip_status;
   FETCH trip_status INTO l_trip_status, l_trip_ship_method, l_trip_planflag, l_trip_ignore;

   IF (trip_status%NOTFOUND) THEN
      CLOSE trip_status;
	 raise others;
   END IF;

   CLOSE trip_status;

   IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'l_trip_planflag', l_trip_planflag);
        wsh_debug_sv.log(l_module_name, 'l_trip_ignore', l_trip_ignore);
   END IF;

   IF l_trip_planflag='F' THEN
      raise trip_firm;
   END IF;

   IF l_trip_ignore <> l_del_ignore THEN
      raise trip_diffignore;
   END IF;

   IF (l_trip_status = 'CL')
   THEN
   --{
        raise invalid_status;

        /*
         -- J-IB-NPARIKH-{
         IF l_shipment_direction   IN ('O','IO')
         THEN
                raise invalid_status;
         ELSIF l_shipping_control     = 'SUPPLIER'
         OR    l_routing_request_flag = 'N'
         THEN
            IF l_del_status <> 'CL'
            THEN
                raise invalid_status;
            END IF;
         ELSE
                raise invalid_status;
         END IF;
         -- J-IB-NPARIKH-}
         */
   --}
   END IF;

   if (l_trip_ship_method is not null) then
	OPEN org_ship_method(l_org_id, l_trip_ship_method);
   	FETCH org_ship_method INTO l_tmp_ship_method;

   	IF (org_ship_method%NOTFOUND) THEN
      	  CLOSE org_ship_method;
      	  raise invalid_tripshipmethod_del_org;
   	END IF;
   	CLOSE org_ship_method;
   end if;

   IF (l_del_ship_method is not null and l_trip_ship_method is not null
	and l_del_ship_method <> l_trip_ship_method) THEN
	raise invalid_del_trip_shipmethod;
   END IF;


   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.GET_GROUP_BY_ATTR',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_delivery_autocreate.get_group_by_attr( p_organization_id => l_org_id,
                                              x_group_by_flags => l_group_by_attr,
                                              x_return_status => l_return_status);

   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	 x_return_status := l_return_status;
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;

   IF (l_group_by_attr.ship_method = 'Y') AND (l_trip_ship_method <> l_del_ship_method) THEN
	 FND_MESSAGE.SET_NAME('WSH','WSH_TRIP_SHIP_METHOD_NOT_SAME');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	 wsh_util_core.add_message(x_return_status);
   END IF;

   IF (p_pickup_stop_id IS NOT NULL) THEN

      OPEN stop_status (p_pickup_stop_id);
      FETCH stop_status INTO l_stop_status, l_pickup_arr_date, l_pickup_dep_date;

      IF (stop_status%FOUND) THEN
      	CLOSE stop_status;
         --

         raise invalid_status;

         /*
         -- J-IB-NPARIKH-{
         IF l_shipment_direction   IN ('O','IO')
         THEN
                raise invalid_status;
         ELSIF l_shipping_control     = 'SUPPLIER'
         OR    l_routing_request_flag = 'N'
         THEN
            IF l_del_status NOT IN ('IT', 'CL')
            THEN
                raise invalid_status;
            END IF;
         ELSE
                raise invalid_status;
         END IF;
         -- J-IB-NPARIKH-}
         */
      END IF;
		CLOSE stop_status;

   END IF;

   IF (p_dropoff_stop_id IS NOT NULL) THEN

      OPEN stop_status (p_dropoff_stop_id);
      FETCH stop_status INTO l_stop_status, l_dropoff_arr_date, l_dropoff_dep_date;

      IF (stop_status%FOUND) THEN
			CLOSE stop_status;
                    raise invalid_status;

             /*
             --
             -- J-IB-NPARIKH-{
             IF l_shipment_direction   IN ('O','IO')
             THEN
                    raise invalid_status;
             ELSIF l_shipping_control     = 'SUPPLIER'
             OR    l_routing_request_flag = 'N'
             THEN
                IF l_del_status NOT IN ('IT', 'CL')
                THEN
                    raise invalid_status;
                END IF;
             ELSE
                    raise invalid_status;
             END IF;
             -- J-IB-NPARIKH-}
             */

      END IF;

		CLOSE stop_status;

   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
    -- J-IB-NPARIKH-{
      --
    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
      -- J-IB-NPARIKH-}



      WHEN invalid_del_trip_shipmethod THEN
   	    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSIGN_TR_SHIP');
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_id));
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	    wsh_util_core.add_message(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_DEL_TRIP_SHIPMETHOD exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_DEL_TRIP_SHIPMETHOD');
END IF;
--
      WHEN invalid_tripshipmethod_del_org THEN
   	    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSIGN_TR_SM_ORG');
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_id));
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	    wsh_util_core.add_message(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_TRIPSHIPMETHOD_DEL_ORG exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_TRIPSHIPMETHOD_DEL_ORG');
END IF;
--
      WHEN invalid_status THEN
   	    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSIGN_TR_STATUS');
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_id));
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_STATUS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_STATUS');
END IF;
--

      WHEN trip_firm THEN
   	    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSIGN_TR_FIRM');
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_id));
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'TRIP_FIRM exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
               WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:TRIP_FIRM');
            END IF;
      WHEN trip_diffignore THEN
   	    FND_MESSAGE.SET_NAME('WSH','WSH_DELASSIGNTR_IGNORE');
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(p_trip_id));
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'TRIP_DIFFIGNORE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
               WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:TRIP_DIFFIGNORE');
            END IF;

      WHEN others THEN
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_ASSIGN_TRIP');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Assign_Trip;


/* ******** Commented this out for bug 2554849
-----------------------------------------------------------------------------
--
-- Procedure:     Check_Unassign_Trip
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Unassign Trip action pre-requisites which are
-- 		  - Delivery status is not CLOSED
--		  - Trip status is not CLOSED
--                - Delivery status is not IN-TRANSIT [warning]
-- NOT YET IMPLEMENTED               - If trip is Planned and has Vehicle information then no stops on the trip are under filled by removal of this delivery [warning]
--                - No Bill of Lading is assigned to this delivery for this trip [warning] NOTE: this warning will inform the user that all Bill of Ladings will be deleted.
--
-----------------------------------------------------------------------------

PROCEDURE Check_Unassign_Trip ( p_delivery_id   IN  NUMBER,
			      	p_trip_id 	IN  NUMBER,
		              	x_return_status OUT NOCOPY  VARCHAR2) IS

CURSOR delivery_status IS
SELECT status_code
FROM   wsh_new_deliveries
WHERE  delivery_id = p_delivery_id;

CURSOR trip_status IS
SELECT status_code
FROM   wsh_trips
WHERE  trip_id = p_trip_id;

l_del_status  VARCHAR2(2);
l_trip_status VARCHAR2(2);
others        EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_UNASSIGN_TRIP';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN delivery_status;
   FETCH delivery_status INTO l_del_status;

   IF (delivery_status%NOTFOUND) THEN
	 CLOSE delivery_status;
	 raise others;
   END IF;

   CLOSE delivery_status;

   IF (l_del_status = 'CL') THEN
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSIGN_TR_STATUS');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;

   -- TPA Change
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_DELIVERY_PKG.CHECK_DEL_NOT_I_T',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_tpa_delivery_pkg.check_del_not_i_t(p_delivery_id, l_del_status, x_return_status);

   IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;

   OPEN trip_status;
   FETCH trip_status INTO l_trip_status;

   IF (trip_status%NOTFOUND) THEN
      CLOSE trip_status;
	 raise others;
   END IF;

   CLOSE trip_status;

   IF (l_trip_status = 'CL') THEN
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSIGN_TR_STATUS');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;

-- TO DO: Implement document instances checks

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
      WHEN others THEN
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_ASSIGN_TRIP');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Unassign_Trip;
************ */


-----------------------------------------------------------------------------
--
-- Procedure:     Check_Pack
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Pack action pre-requisites which are
--		  - Delivery status is OPEN
--		  - At least one line is assigned to delivery
--                - All items being shipped on this delivery are packed in containers
-- NOT YET IMPLEMENTED (JESSICA)     - Details (shipped quantity, inventory controls ) must be specified for all delivery lines
-- NOT YET IMPLEMENTED               - Containers assigned to the delivery are not over/under packed [warning]
--
-----------------------------------------------------------------------------

PROCEDURE Check_Pack ( p_delivery_id 		IN  NUMBER,
		       x_return_status 		OUT NOCOPY  VARCHAR2) IS

CURSOR delivery_status IS
SELECT status_code
FROM   wsh_new_deliveries
WHERE  delivery_id = p_delivery_id;

CURSOR detail_info IS
SELECT da.parent_delivery_detail_id
FROM   wsh_delivery_assignments_v da,
	  wsh_delivery_details dd
WHERE  dd.delivery_detail_id = da.delivery_detail_id AND
	  da.delivery_id = p_delivery_id AND
	  da.delivery_id IS NOT NULL AND
	  dd.container_flag = 'N';

l_container_id NUMBER;
l_count_detail NUMBER := 0;
l_del_status   VARCHAR2(2);
l_fill_status  VARCHAR2(1);
l_return_status VARCHAR2(1);

l_underfilled_flag BOOLEAN := FALSE;
l_overfilled_flag BOOLEAN := FALSE;

others         EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_PACK';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN delivery_status;
   FETCH delivery_status INTO l_del_status;

   IF (delivery_status%NOTFOUND) THEN
	 CLOSE delivery_status;
	 raise others;
   END IF;

   CLOSE delivery_status;

   IF (l_del_status = 'PA') THEN
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
	  RETURN;
   END IF;

   IF (l_del_status NOT IN  ('OP', 'SA')) THEN  -- sperera 940/945
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_OP_PA_STATUS');
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;

   OPEN detail_info;

   LOOP

      l_container_id := NULL;

	 FETCH detail_info INTO l_container_id;
      EXIT WHEN detail_info%NOTFOUND;

      --IF (detail_info%FOUND) THEN
	    IF (l_container_id IS NULL) THEN
	       FND_MESSAGE.SET_NAME('WSH','WSH_DEL_PACK_ITEMS_UNPACKED');
		  --
		  -- Debug Statements
		  --
		  IF l_debug_on THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
		  END IF;
		  --
		  FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	       wsh_util_core.add_message(x_return_status);
	       --
	       -- Debug Statements
	       --
	       IF l_debug_on THEN
	           WSH_DEBUG_SV.pop(l_module_name);
	       END IF;
	       --
	       RETURN;
         END IF;

         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.CHECK_FILL_PC',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         wsh_wv_utils.check_fill_pc( p_container_instance_id => l_container_id,
				     x_fill_status           => l_fill_status,
				     x_return_status         => l_return_status);
         IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
--		  FND_MESSAGE.SET_NAME('WSH','Error-in-fill-percent');
		  x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
--		  wsh_util_core.add_message(x_return_status);
         ELSIF (l_fill_status = 'U') THEN
		  l_underfilled_flag := TRUE;
	    ELSIF (l_fill_status = 'O') THEN
            l_overfilled_flag := TRUE;
         END IF;

      --END IF;

   l_count_detail := l_count_detail + 1;

   END LOOP;
   CLOSE detail_info;

   IF (l_overfilled_flag) THEN
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CONT_OVERPACKED');
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	 wsh_util_core.add_message(x_return_status);
   END IF;

   IF (l_underfilled_flag) THEN
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CONT_UNDERPACKED');
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	 wsh_util_core.add_message(x_return_status);
   END IF;

   --IF (l_container_id IS NULL) THEN
   IF (l_count_detail = 0) THEN /*Bug #1701366 Issue 3 */
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NO_DETAILS');
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
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
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_PACK');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Pack;

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Detail_for_Confirm
-- Parameters:    p_detail_id, p_check_credit_init_flag, x_line_inv_flag_rec, x_return_status
-- Description:   Checks for Confirm action pre-requisites which are
--                Check for inventory controls
--                Check for credit and holds
-- NOT YET IMPLEMENTED Check for exceptions
--
-----------------------------------------------------------------------------
PROCEDURE Check_Detail_for_Confirm ( p_detail_id           IN  NUMBER,
                                     p_check_credit_init_flag   IN  BOOLEAN, -- 2343058
                                     x_line_inv_flag_rec   OUT NOCOPY  wsh_delivery_details_inv.inv_control_flag_rec,
                                     x_return_status OUT NOCOPY  VARCHAR2) IS

CURSOR detail_info IS
SELECT delivery_detail_id,
          inventory_item_id,
          shipped_quantity,
          requested_quantity,
          NULL,
          revision,
          subinventory,
          lot_number,
          locator_id,
          NULL,
          serial_number,
          NULL,
          transaction_temp_id,
          organization_id,
          source_line_id,
          source_header_id,
          source_code,
          picked_quantity,
          picked_quantity2,
          requested_quantity_uom,
          requested_quantity_uom2,
          line_direction
FROM   wsh_delivery_details
WHERE  delivery_detail_id = p_detail_id;


/************************MATERIAL STATUS CONTROL ********/
CURSOR C_GET_SERIAL (l_transaction_temp_id NUMBER) IS
SELECT fm_serial_number,nvl(to_serial_number,fm_serial_number)
from MTL_SERIAL_NUMBERS_TEMP
where transaction_temp_id = l_transaction_temp_id;

l_prefix    VARCHAR2(10);
l_result    BOOLEAN;
l_valid_serial_range NUMBER;
l_org       INV_VALIDATE.org;
l_item      INV_VALIDATE.item;
l_lot       INV_VALIDATE.lot;
l_locator   INV_VALIDATE.locator;
l_sub       INV_VALIDATE.sub;

p_fm_serial INV_VALIDATE.SERIAL_NUMBER_TBL;
p_to_serial INV_VALIDATE.SERIAL_NUMBER_TBL;
x_errored_serials  INV_VALIDATE.SERIAL_NUMBER_TBL;

/************************MATERIAL STATUS CONTROL ********/

l_line_inv_rec wsh_delivery_details_inv.line_inv_info;
g_line_inv_rec wsh_delivery_details_inv.line_inv_info;
l_line_inv_flag_rec wsh_delivery_details_inv.inv_control_flag_rec;
l_details_flag  BOOLEAN;

l_source_line_id NUMBER;
l_source_header_id NUMBER;
l_source_code    WSH_DELIVERY_DETAILS.SOURCE_CODE%TYPE;
l_picked_quantity2   NUMBER;
l_temp_status VARCHAR2(1);
l_transaction_type_id NUMBER;
l_wms_enabled VARCHAR2(10);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_DETAIL_FOR_CONFIRM';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_ID',P_DETAIL_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_CHECK_CREDIT_INIT_FLAG',P_CHECK_CREDIT_INIT_FLAG);
   END IF;
   --
   OPEN  detail_info;
   FETCH detail_info INTO l_line_inv_rec.delivery_detail_id,
                                         l_line_inv_rec.inventory_item_id,
                                         l_line_inv_rec.shp_qty,
                                         l_line_inv_rec.req_qty,
                                         l_line_inv_rec.ser_qty,
                                         l_line_inv_rec.revision,
                                         l_line_inv_rec.subinventory,
                                         l_line_inv_rec.lot_number,
                                         l_line_inv_rec.locator_id,
                                         l_line_inv_rec.locator_control_code,
                                         l_line_inv_rec.serial_number,
                                         l_line_inv_rec.serial_number_control_code,
                                         l_line_inv_rec.transaction_temp_id,
                                         l_line_inv_rec.organization_id,
                                         l_line_inv_rec.source_line_id,
                                         l_line_inv_rec.source_header_id,
                                         l_line_inv_rec.source_code,
                                         l_line_inv_rec.picked_quantity,
                                         l_line_inv_rec.picked_quantity2,
                                         l_line_inv_rec.requested_quantity_uom,
                                         l_line_inv_rec.requested_quantity_uom2,
                                         l_line_inv_rec.line_direction;
   CLOSE detail_info;

   -- bug 2343058
   IF (p_check_credit_init_flag) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_CREDIT_HOLDS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_details_validations.check_credit_holds(
        p_detail_id             => p_detail_id,
        p_activity_type         => 'SHIP',
        p_source_line_id        => l_line_inv_rec.source_line_id,
        p_source_header_id      => l_line_inv_rec.source_header_id,
        p_source_code           => l_line_inv_rec.source_code,
        p_init_flag             => 'Y',
        x_return_status         => x_return_status);
   ELSE
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_CREDIT_HOLDS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_details_validations.check_credit_holds(
        p_detail_id             => p_detail_id,
        p_activity_type         => 'SHIP',
        p_source_line_id        => l_line_inv_rec.source_line_id,
        p_source_header_id      => l_line_inv_rec.source_header_id,
        p_source_code           => l_line_inv_rec.source_code,
        p_init_flag             => 'N',
        x_return_status         => x_return_status);
   END IF;

   IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;


   -- Pack J Catch Weights
   -- Call wrapper API to default catchweight if null.
   -- If required and not defaulted raise error.
   -- Bug # 8655653 : catch weight defaulting can be done for only dds
   -- which are having inv item populated.
   IF
      (wsh_util_validate.Check_Wms_Org(l_line_inv_rec.organization_id) = 'Y')
   AND (NVL(l_line_inv_rec.picked_quantity2,0) = 0)
   AND  l_line_inv_rec.inventory_item_id IS NOT NULL THEN


      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.Check_Default_Catch_Weights',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_DELIVERY_DETAILS_INV.Check_Default_Catch_Weights
                                     (p_line_inv_rec => l_line_inv_rec,
                                      x_return_status => x_return_status);

      IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;

        RETURN;

      END IF;

   END IF;

   /* Bug fix 2850555
   Initializing the new flag 'details_required_flag' to Y
   Flag will be set to 'N' after call to 'details_required' API, if
   the details are really not required */

   x_line_inv_flag_rec.details_required_flag := 'Y';

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.FETCH_INV_CONTROLS',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_delivery_details_inv.fetch_inv_controls(
      p_delivery_detail_id   => l_line_inv_rec.delivery_detail_id,
      p_inventory_item_id    => l_line_inv_rec.inventory_item_id,
      p_organization_id      => l_line_inv_rec.organization_id,
      p_subinventory         => l_line_inv_rec.subinventory,
      x_inv_controls_rec     => l_line_inv_flag_rec,
      x_return_status        => x_return_status);

   IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
   END IF;

   l_line_inv_rec.serial_number_control_code := l_line_inv_flag_rec.serial_code;
   l_line_inv_rec.locator_control_code := l_line_inv_flag_rec.location_control_code;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.DETAILS_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_delivery_details_inv.Details_Required (
          p_line_inv_rec        => l_line_inv_rec,
          p_set_default         => FALSE,
          x_line_inv_rec        => g_line_inv_rec,
          x_details_required    => l_details_flag,
          x_return_status       => x_return_status);

   IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
   END IF;

   IF (l_details_flag) THEN

      /* Bug fix 2850555
         Set the new flag 'details_required_flag' to Y , when l_details_flag
         is TRUE after the call to details_required API.
      */

        l_line_inv_flag_rec.details_required_flag := 'Y';
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,  'DETAILS REQUIRED ERROR ' || X_RETURN_STATUS  );
        END IF;
        --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   ELSE
      /* Bug fix 2850555
         Set the new flag 'details_required_flag' to N , when l_details_flag
         is FALSE after the call to details_required API.
      */
      l_line_inv_flag_rec.details_required_flag := 'N';
   END IF;
   x_line_inv_flag_rec   := l_line_inv_flag_rec  ;

   IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'x_line_inv_flag_rec.details_required_flag', x_line_inv_flag_rec.details_required_flag);
   END IF;

   /****************Material Status Control**************/
   -- Bug 9220228:Added condition on inventory item id to skip material status
   --             check when it is null(It could be null for delivery lies from Project contracts orders).
   IF l_line_inv_flag_rec.details_required_flag <> 'Y' AND l_line_inv_rec.inventory_item_id is not null THEN

      select DECODE(wsh_util_validate.Check_Wms_Org(l_line_inv_rec.organization_id),'Y','TRUE','FALSE')
      into   l_wms_enabled
      from   dual;

      WSH_DELIVERY_DETAILS_INV.get_trx_type_id(
        p_source_line_id      => l_line_inv_rec.source_line_id,
        p_source_code         => l_line_inv_rec.source_code,
        x_transaction_type_id => L_TRANSACTION_TYPE_ID ,
        x_return_status       => x_return_status);
      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        return;
      END IF;

      IF (l_line_inv_rec.serial_number_control_code = 1) THEN
         l_temp_status := inv_material_status_grp.is_status_applicable(
	                               p_wms_installed         => l_wms_enabled
  		                      ,p_trx_status_enabled    => NULL
                                      ,p_trx_type_id           => L_TRANSACTION_TYPE_ID
                                      ,p_lot_status_enabled    => NULL
                                      ,p_serial_status_enabled => NULL
                                      ,p_organization_id       => l_line_inv_rec.organization_id
                                      ,p_inventory_item_id     =>  l_line_inv_rec.inventory_item_id
                                      ,p_sub_code              => l_line_inv_rec.subinventory
                                      ,p_locator_id            => l_line_inv_rec.locator_id
                                      ,p_lot_number            => l_line_inv_rec.lot_number
                                      ,p_serial_number         => NULL
                                      ,p_object_type           => 'A');
      IF l_temp_status <>'Y' THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  	 l_line_inv_flag_rec.invalid_material_status_flag := 'Y';
  	 x_line_inv_flag_rec   := l_line_inv_flag_rec  ;
  	 IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
            END IF;
  	    return;
         END IF;
      ELSE

           IF l_line_inv_rec.transaction_temp_id IS NOT NULL THEN
              OPEN C_GET_SERIAL (l_line_inv_rec.transaction_temp_id);
              FETCH  C_GET_SERIAL BULK COLLECT
  	      INTO p_fm_serial,p_to_serial;
              CLOSE C_GET_SERIAL;

              l_org.organization_id    := l_line_inv_rec.organization_id;
              l_item.inventory_item_id := l_line_inv_rec.inventory_item_id;
              l_sub.secondary_inventory_name := l_line_inv_rec.subinventory;
              l_lot.lot_number := l_line_inv_rec.lot_number;
              l_locator.inventory_location_id := l_line_inv_rec.locator_id;

              l_valid_serial_range := INV_VALIDATE.validate_serial_range(
	                                       p_fm_serial   => p_fm_serial,
  		                               p_to_serial   => p_to_serial,
  		                               p_org         => l_org,
  				               p_item        => l_item ,
  					       p_from_sub    => l_sub ,
  		                               p_lot         => l_lot,
  		                               p_loc         => l_locator,
  		                               p_revision    => l_line_inv_rec.revision,
  		                               p_trx_type_id => L_TRANSACTION_TYPE_ID,
  		                               p_object_type => 'A',
  		                               x_errored_serials => x_errored_serials);

	      IF l_valid_serial_range <> 1 THEN
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  	         l_line_inv_flag_rec.invalid_material_status_flag := 'Y';
  	         x_line_inv_flag_rec   := l_line_inv_flag_rec  ;
  	         FOR i in 1..x_errored_serials.count LOOP
                     IF l_debug_on THEN
                      wsh_debug_sv.log(l_module_name, 'errored serial_number'||to_char(i), x_errored_serials(i));
  	             END IF;
                 END LOOP;
  	         IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
  	         return;
  	      END IF;

           ELSE
              WSH_DELIVERY_DETAILS_INV.Validate_Serial( p_serial_number       => l_line_inv_rec.serial_number,
    							p_lot_number          => l_line_inv_rec.lot_number,
  							p_organization_id     => l_line_inv_rec.organization_id ,
  							p_inventory_item_id   => l_line_inv_rec.inventory_item_id ,
  							p_subinventory        => l_line_inv_rec.subinventory ,
  							p_revision            => l_line_inv_rec.revision,
  							p_locator_id          => l_line_inv_rec.locator_id,
  							p_transaction_type_id => L_TRANSACTION_TYPE_ID,
  							p_object_type         => 'A',
  							x_return_status       => x_return_status ,
  							x_result              => l_result
  					              );
              IF l_result <> TRUE  OR x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  	         IF l_result <> TRUE THEN
  	            l_line_inv_flag_rec.invalid_material_status_flag := 'Y';
  	         END IF;
  	         x_line_inv_flag_rec   := l_line_inv_flag_rec  ;
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
  	         return;
  	      END IF;
           END IF;
           l_line_inv_flag_rec.invalid_material_status_flag := 'N';
           x_line_inv_flag_rec   := l_line_inv_flag_rec  ;
      END IF;
    /****************Material Status Control**************/
      IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'x_line_inv_flag_rec.invalid_material_status_flag', x_line_inv_flag_rec.invalid_material_status_flag);
      END IF;
   END IF;
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
--
   EXCEPTION
      WHEN others THEN
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_DETAIL_FOR_CONFIRM');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

         IF C_GET_SERIAL%ISOPEN THEN
	    CLOSE C_GET_SERIAL;
         END IF;
--
-- Debug Statements
--
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
END Check_Detail_for_Confirm;



-----------------------------------------------------------------------------
--
-- Procedure:     Check_Confirm
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Confirm action pre-requisites which are
--		  - Delivery Status is OPEN or PACKED
-- NOT YET IMPLEMENTED (JESSICA)              - Details (shipped quantity, inventory controls ) must be specified for all delivery details (lines)
--                - At least one delivery detail (line) is released
--                - All delivery details (lines) are released [warning]
--                - If delivery status is OPEN and containers are assigned to this delivery then all items being shipped on this delivery are packed [warning]
--                - If delivery status is OPEN then containers for this delivery are not over/under packed [warning]
--                - SMC models must be together [warning]
--                - Ship Sets must be complete [warning]
--                - Arrival Sets must be complete [warning]
--                - Delivery flow on trip/s is valid [error/warning]
--
-----------------------------------------------------------------------------

PROCEDURE Check_Confirm ( p_delivery_id 	IN  NUMBER,
                          p_cont_exists_flag     IN  BOOLEAN,
                          p_enforce_packing_flag IN  VARCHAR2,
                          p_overfilled_flag      IN  BOOLEAN,
                          p_underfilled_flag     IN  BOOLEAN,
			  p_ship_from_location   IN NUMBER ,
			  p_ship_to_location     IN NUMBER ,
			  p_freight_code         IN VARCHAR2 ,
			  p_organization_id      IN NUMBER  ,
			  p_initial_pickup_date   IN DATE ,
			  p_ultimate_dropoff_date IN DATE ,
			  p_actual_dep_date 	  IN DATE ,
		          x_return_status 	OUT NOCOPY  VARCHAR2) IS


l_unpacked_flag 	BOOLEAN;
l_valid_flag        BOOLEAN;
l_return_status 	VARCHAR2(1);

-- Variables for trans cal check

l_ship_from_location NUMBER;
l_ship_to_location NUMBER;
--Bug 6156495 :Variable added
l_temp_date   DATE;


record_locked                 EXCEPTION;
PRAGMA EXCEPTION_INIT(record_locked, -54);
others        	              EXCEPTION;

l_ship_parameter   WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_CONFIRM';
--
  -- Added for Ship Confirm Message Customization. R12
  l_custom_severity varchar2(10);
  l_activity_code   varchar2(200) := 'SHIP_CONFIRM_MESSAGE' ;
  l_validation_code varchar2(200) := 'BREAK_SHIP_SET';

BEGIN
   --6156495  :Storing actual_departure_date in global variable so that it can be used again in the procedure 'CHECK_PLAN'
   G_ACT_DEPT_DATE := p_actual_dep_date;


   -- TPA Change
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_CONT_EXISTS_FLAG',P_CONT_EXISTS_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_ENFORCE_PACKING_FLAG',P_ENFORCE_PACKING_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_OVERFILLED_FLAG',P_OVERFILLED_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_UNDERFILLED_FLAG',P_UNDERFILLED_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_FROM_LOCATION',P_SHIP_FROM_LOCATION);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TO_LOCATION',P_SHIP_TO_LOCATION);
       WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_CODE',P_FREIGHT_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_INITIAL_PICKUP_DATE',P_INITIAL_PICKUP_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_ULTIMATE_DROPOFF_DATE',P_ULTIMATE_DROPOFF_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_ACTUAL_DEP_DATE',P_ACTUAL_DEP_DATE);
   END IF;
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_DELIVERY_PKG.CHECK_DEL_OVERFILLED',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_tpa_delivery_pkg.check_del_overfilled(p_delivery_id, p_cont_exists_flag, p_overfilled_flag, l_return_status);

   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	 x_return_status := l_return_status;
	 IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    --
	    RETURN;
      END IF;
   END IF;

   -- TPA Change
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_DELIVERY_PKG.CHECK_DEL_UNDERFILLED',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_tpa_delivery_pkg.check_del_underfilled(p_delivery_id, p_cont_exists_flag, p_underfilled_flag, l_return_status);

   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	 x_return_status := l_return_status;
	 IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    --
	    RETURN;
      END IF;
   END IF;

-- TPA change
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_DELIVERY_PKG.CHECK_SMC',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_tpa_delivery_pkg.check_smc( p_delivery_id, l_valid_flag, l_return_status);

   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	 x_return_status := l_return_status;
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;

   IF NOT (l_valid_flag) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_SMC_INCOMPLETE');
      FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'g_break_smc_severity',g_break_smc_severity);
      END IF;

      If g_break_smc_severity is NULL then
         g_break_smc_severity := wsh_ru_actions.get_message_severity (wsh_new_delivery_actions.g_ship_confirm_act
                                                                     ,wsh_new_delivery_actions.g_break_smc_msg);
      End If;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'g_break_smc_severity',g_break_smc_severity);
      END IF;

      If g_break_smc_severity = 'E' then
         --Note. Setting return status to 'W' and message severity to 'E'. The return
         --status is checked in wsh_new_delivery_actions.confirm_delivery and treated
         --as error if WSH_NEW_DELIVERY_ACTIONS.g_break_ship_set_or_smc.count > 0.
         x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
         WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
         WSH_NEW_DELIVERY_ACTIONS.g_break_ship_set_or_smc := nvl(WSH_NEW_DELIVERY_ACTIONS.g_break_ship_set_or_smc,0) + 1;
         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Going to exit wsh_delivery_validations due to message severity set to (SMC) ',g_break_smc_severity);
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         RETURN;
      Else
         x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
         WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
      End If;
   END IF;

-- TPA change
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_DELIVERY_PKG.CHECK_SHIP_SET',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_tpa_delivery_pkg.check_ship_set( p_delivery_id, l_valid_flag, l_return_status);

   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	 x_return_status := l_return_status;
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;

   IF NOT (l_valid_flag) THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_DEL_SHIP_SET_INCOMPLETE');
         FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'g_break_ship_set_severity',g_break_ship_set_severity);
         END IF;

         If g_break_ship_set_severity is null then
            g_break_ship_set_severity := wsh_ru_actions.get_message_severity (wsh_new_delivery_actions.g_ship_confirm_act
                                                                             ,wsh_new_delivery_actions.g_break_ship_set_msg);

         End If;

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'g_break_ship_set_severity',g_break_ship_set_severity);
         END IF;

         If g_break_ship_set_severity = 'E' then
            --Note. Setting return status to 'W' and message severity to 'E'. The return
            --status is checked in wsh_new_delivery_actions.confirm_delivery and treated
            --as error if WSH_NEW_DELIVERY_ACTIONS.g_break_ship_set_or_smc.count > 0.
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            WSH_NEW_DELIVERY_ACTIONS.g_break_ship_set_or_smc := nvl(WSH_NEW_DELIVERY_ACTIONS.g_break_ship_set_or_smc,0) + 1;
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Going to exit wsh_delivery_validations due to message severity set to (ShipSet) ',g_break_ship_set_severity);
               WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;
         Else
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
         End If;
   END IF;
	/* H integration anxsharm */

   -- REmoved call to update_leg_sequence here this is now done at the end of ship confirm.
/**   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.UPDATE_LEG_SEQUENCE',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_new_delivery_actions.update_leg_sequence(
     p_delivery_id => p_delivery_id,
     x_return_status => l_return_status);

   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	 x_return_status := l_return_status;
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;
**/
-- Check for transportation calendar requirements

   -- TPA Change
   --
   -- Debug Statements
   --
   --Bug 6156495 (Determining  the date to be passed to the API wsh_tpa_delivery_pkg.check_calendar)
   IF p_ultimate_dropoff_date > P_ACTUAL_DEP_DATE
   THEN
   l_temp_date := p_ultimate_dropoff_date;
   ELSE
   l_temp_date := P_ACTUAL_DEP_DATE;
   END IF;
   --Bug 6156495 -End of code addition


   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TPA_DELIVERY_PKG.CHECK_CALENDAR',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
-- modified ship_assoc type to 'HR_LOCATION' and receive_assoc_type to 'CUSTOMER_SITE' for bug 5880742
   --
   wsh_tpa_delivery_pkg.check_calendar(p_entity_type   	=> 'DELIVERY',
                           p_entity_id  		=> p_delivery_id,
--			   p_ship_date    		=> p_initial_pickup_date  ,--6156495
			   p_ship_date    		=> P_ACTUAL_DEP_DATE  ,
			   p_ship_assoc_type 		=> 'HR_LOCATION',
			   p_ship_location_id		=> p_ship_from_location,
			   p_freight_code   		=> p_freight_code,
			   p_freight_org_id		=> p_organization_id ,
--			   p_receive_date 		=> p_ultimate_dropoff_date ,--6156495
			   p_receive_date 		=> l_temp_date ,
			   p_receive_assoc_type  	=> 'CUSTOMER_SITE',
			   p_receive_location_id	=> p_ship_to_location,
			   p_update_flag       		=> 'N',
			   x_return_status		=> l_return_status);

   IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
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
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_CONFIRM');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Confirm;

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Reopen
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Reopen action pre-requisites which are
--		  - Delivery status is PACKED or CONFIRMED
--
-----------------------------------------------------------------------------

PROCEDURE Check_Reopen ( p_delivery_id 		IN  NUMBER,
		         x_return_status 	OUT NOCOPY  VARCHAR2) IS

CURSOR delivery_status IS
SELECT status_code
FROM   wsh_new_deliveries
WHERE  delivery_id = p_delivery_id;

l_del_status  VARCHAR2(2);
others        EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_REOPEN';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN delivery_status;
   FETCH delivery_status INTO l_del_status;

   IF (delivery_status%NOTFOUND) THEN
	 CLOSE delivery_status;
	 raise others;
   END IF;

   CLOSE delivery_status;

   IF (l_del_status <> 'CO') AND (l_del_status <> 'PA') AND (l_del_status <> 'OP') THEN
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_CO_PA_STATUS');
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
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
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_REOPEN');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Reopen;


-----------------------------------------------------------------------------
--
-- Procedure:     Check_Intransit
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Reopen action pre-requisites which are
--		  - Delivery status is CONFIRMED
--                - First pickup stop status is CLOSED
--
-----------------------------------------------------------------------------

PROCEDURE Check_Intransit ( p_delivery_id 	IN  NUMBER,
		            x_return_status 	OUT NOCOPY  VARCHAR2) IS

CURSOR delivery_status IS
SELECT status_code
FROM   wsh_new_deliveries
WHERE  delivery_id = p_delivery_id;

CURSOR stop_status IS
SELECT st.status_code
FROM   wsh_trip_stops st,
	  wsh_delivery_legs dg,
	  wsh_new_deliveries dl
WHERE  dl.delivery_id = p_delivery_id AND
	  dg.delivery_id = dl.delivery_id AND
	  st.stop_id = dg.pick_up_stop_id AND
	  dl.initial_pickup_location_id = st.stop_location_id;

l_del_status  VARCHAR2(2);
l_stop_status VARCHAR2(2);
others        EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_INTRANSIT';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
   END IF;
   --
-- J-IB-NPARIKH-{
-- Stubbed out as no one is calling this API.
/*
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN delivery_status;
   FETCH delivery_status INTO l_del_status;

   IF (delivery_status%NOTFOUND) THEN
	 CLOSE delivery_status;
	 raise others;
   END IF;

   CLOSE delivery_status;

   IF (l_del_status <> 'CO') THEN
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_CONFIRMED');
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;
*/
   -- J-IB-NPARIKH-}

/*
   OPEN stop_status;
   FETCH stop_status INTO l_stop_status;

   IF (stop_status%NOTFOUND) THEN
	 CLOSE stop_status;
	 raise others;
   END IF;

   CLOSE stop_status;

   IF (l_stop_status <> 'CL') THEN
	 FND_MESSAGE.SET_NAME('WSH','First-pickup-stop-not-closed');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 RETURN;
   END IF;
*/


x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;   -- J-IB-NPARIKH
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
      WHEN others THEN
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_INTRANSIT');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Intransit;

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Close
-- Parameters:    p_delivery_id = delivery being closed
--                p_manual_flag = 'Y' if user invokes the UI action Close Del.
--                                'N' if its drop-off stop is being closed
--        p_old_status_code = delivery's original status_code
--                x_return_status = SUCCESS -> can close,
--                                  ERROR -> cannot close
--
-- Description:   Checks for Close action pre-requisites which are
--                - POD has been received
--                - If POD not received then last drop-off stop status
--                  is ARRIVED or CLOSED
--        If manually closing, the pre-requisite is either:
--                - Delivery is open with no details or legs assigned.
--                - Delivery is IN TRANSIT and owns all stops still open.
--
-----------------------------------------------------------------------------

PROCEDURE Check_Close ( p_delivery_id       IN  NUMBER,
            p_manual_flag       IN  VARCHAR2,
            p_old_status_code   IN  VARCHAR2,
                x_return_status     OUT NOCOPY  VARCHAR2) IS

  CURSOR dropoff_stop_info (l_delivery_id NUMBER) IS
  SELECT dg.drop_off_stop_id,
        st.stop_location_id
  FROM   wsh_new_deliveries dl,
        wsh_delivery_legs  dg,
        wsh_trip_stops     st
  WHERE  dl.delivery_id = l_delivery_id AND
        dl.delivery_id = dg.delivery_id AND
        dg.drop_off_stop_id = st.stop_id AND
        dl.ultimate_dropoff_location_id = st.stop_location_id;
/*Refer POD Information from WSH_DELIVERY_LEGS. Bug#1918342*/
  CURSOR check_POD (l_stop_id NUMBER, l_delivery_id NUMBER) IS
  SELECT dg.pod_flag
  FROM   wsh_delivery_legs dg,
         wsh_document_instances di
  WHERE  dg.drop_off_stop_id = l_stop_id AND
        di.entity_id = dg.delivery_leg_id AND
        di.entity_name = 'WSH_DELIVERY_LEGS' AND
        di.document_type = 'BOL' AND
        dg.pod_flag = 'Y' AND
        dg.pod_date IS NULL AND
        di.status IN ('OPEN','PLANNED');

  CURSOR have_details(l_delivery_id NUMBER) IS
  SELECT delivery_detail_id
  FROM   wsh_delivery_assignments_v
  WHERE  delivery_id = l_delivery_id
  AND    rownum = 1;

  CURSOR have_legs(l_delivery_id NUMBER) IS
  SELECT delivery_leg_id
  FROM   wsh_delivery_legs
  WHERE  delivery_id = l_delivery_id;

  CURSOR delivery_leg_stops(l_delivery_id NUMBER) IS
  SELECT dg.pick_up_stop_id,
         pu_stop.status_code  pu_status,
     dg.drop_off_stop_id,
         do_stop.status_code  do_status
  FROM   wsh_delivery_legs dg,
         wsh_trip_stops pu_stop,
         wsh_trip_stops do_stop
  WHERE  dg.delivery_id = l_delivery_id
  AND    pu_stop.stop_id = dg.pick_up_stop_id
  AND    do_stop.stop_id = dg.drop_off_stop_id;

  CURSOR shared_stops(l_delivery_id NUMBER, l_stop_id NUMBER) IS
  SELECT dg.delivery_leg_id
  FROM   wsh_delivery_legs dg, wsh_new_deliveries nd
  WHERE  dg.pick_up_stop_id = l_stop_id
  AND    dg.delivery_id <> l_delivery_id
  AND    dg.delivery_id = nd.delivery_id
  AND    nd.delivery_type = 'STANDARD'
  UNION
  SELECT dg.delivery_leg_id
  FROM   wsh_delivery_legs dg, wsh_new_deliveries nd
  WHERE  dg.drop_off_stop_id = l_stop_id
  AND    dg.delivery_id <> l_delivery_id
  AND    dg.delivery_id = nd.delivery_id
  AND    nd.delivery_type = 'STANDARD';

  -- bug 2429322: check that all stops are closed when
  --              automatically closing delivery.
  --    Sufficient to check drop off stops only;
  --    A drop off stop being closed implies that pick up stop is closed.
  CURSOR stops_not_closed(l_delivery_id NUMBER) IS
  SELECT ts.stop_id
  FROM wsh_trip_stops ts,
       wsh_delivery_legs dg
  WHERE dg.delivery_id = l_delivery_id
  AND   ts.stop_id = dg.drop_off_stop_id
  AND   ts.status_code in ('OP', 'AR')
  AND   rownum = 1;

  l_stop_id           NUMBER;
  l_stop_location_id  NUMBER;
  l_pod_flag          wsh_delivery_legs.pod_flag%TYPE;
  leg                 delivery_leg_stops%ROWTYPE;
  num                 NUMBER;
  shared_flag         BOOLEAN;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_CLOSE';
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
        WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_MANUAL_FLAG',P_MANUAL_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_OLD_STATUS_CODE',P_OLD_STATUS_CODE);
    END IF;

    /**
    -- J-IB-NPARIKH-{
    --
    -- stubbed out as no longer being called.
    --
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         RETURN;
    -- J-IB-NPARIKH-}
    **/
    --
    IF p_manual_flag = 'N' THEN
      -- Close called from Stop close. Need to check if POD requirements
      -- are fulfilled. If not, do not close the delivery, simply return

      -- bug 2429322: Make sure all stops associated with this delivey
      --    are closed, especially if delivery is on two or more trips.
      OPEN  stops_not_closed(p_delivery_id);
      FETCH stops_not_closed INTO l_stop_id;
      IF stops_not_closed%NOTFOUND THEN
        l_stop_id := NULL;
      END IF;
      CLOSE stops_not_closed;

      IF l_stop_id IS NOT NULL THEN
        -- this status signals: Do not close this delivery.
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


      -- TO DO: Log exceptions if the delivery is not PODed

      l_pod_flag := NULL;


      OPEN  dropoff_stop_info (p_delivery_id);
      FETCH dropoff_stop_info INTO l_stop_id, l_stop_location_id;
      CLOSE dropoff_stop_info;

      OPEN  check_pod (l_stop_id, p_delivery_id);
      FETCH check_pod INTO l_pod_flag;
      IF check_pod%NOTFOUND THEN
        l_pod_flag := NULL;
      END IF;
      CLOSE check_pod;

      IF (l_pod_flag IS NULL) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      ELSE
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

    ELSE -- p_manual_flag = 'Y'

    IF p_old_status_code = 'OP' THEN

      OPEN   have_details(p_delivery_id);
      FETCH  have_details INTO num;
      IF have_details%NOTFOUND THEN
        num := NULL;
      END IF;
      CLOSE  have_details;

      IF num IS NOT NULL THEN
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

      OPEN   have_legs(p_delivery_id);
      FETCH  have_legs INTO num;
      IF have_legs%NOTFOUND THEN
        num := NULL;
      END IF;
      CLOSE  have_legs;

      IF num IS NOT NULL THEN
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

      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    ELSIF p_old_status_code = 'IT' THEN

      -- Look for stops that are not closed and shared by other deliveries.
      -- These stops should not be shared with other deliveries.
      -- We don't need to worry about closed stops.

      shared_flag := FALSE;

      OPEN  delivery_leg_stops(p_delivery_id);
          FETCH delivery_leg_stops INTO leg;

          WHILE delivery_leg_stops%FOUND LOOP

        IF leg.pu_status <> 'CL' THEN
          OPEN shared_stops(p_delivery_id, leg.pick_up_stop_id);
              FETCH shared_stops INTO NUM;
              shared_flag := shared_stops%FOUND;
              CLOSE shared_stops;
            END IF;

        IF shared_flag THEN
              GOTO loop_end;
            END IF;

            IF leg.do_status <> 'CL' THEN
          OPEN shared_stops(p_delivery_id, leg.drop_off_stop_id);
              FETCH shared_stops INTO NUM;
              shared_flag := shared_stops%FOUND;
              CLOSE shared_stops;
            END IF;

        IF shared_flag THEN
              GOTO loop_end;
            END IF;

        FETCH delivery_leg_stops INTO leg;
      END LOOP;
      << loop_end >>

      CLOSE delivery_leg_stops;

      IF shared_flag THEN
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
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
          END IF;

    ELSE
          -- any other status is invalid for closing.
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    END IF;

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
       wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_CLOSE');
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END;


-----------------------------------------------------------------------------
--
-- Procedure:     Check_Close
-- Parameters:    p_in_rec.delivery_id = delivery being closed
--                p_in_rec.manual_flag = 'Y' if user invokes the UI action Close Del.
--                                       'N' if its drop-off stop is being closed
--		              p_in_rec.stop_id = Stop ID of stop being closed in case of automatic close.
--		              p_in_rec.status_code = delivery's current status_code
--                x_allowed         Close operation is allowed or not
--                                    'Y' : Allowed
--                                    'YW': Allowed with warnings
--                                    'N' : Not Allowed
--                                    'NW': Not Allowed with warnings
--                x_return_status = Return status of API
--
-- Description:   This API Validates if delivery can be closed or not.
--                Pre-requisites for automatic closing are:
--                - All other drop-off stops(other than current one) for delivery are closed.
--                - POD has been received
--		              If manually closing, the pre-requisite is either
--                - Delivery is open with no details or legs assigned.
--                OR
--                - Delivery is IN TRANSIT and exclusively owns all stops still open.
--
--               Pack J Exceptions project - Check for exception for any type of closing
--
-----------------------------------------------------------------------------

-- J-IB-NPARIKH-{
PROCEDURE Check_Close
            (
               p_in_rec             IN         ChgStatus_in_rec_type,
               x_return_status      OUT NOCOPY VARCHAR2,
               x_allowed            OUT NOCOPY VARCHAR2
            )
IS
--{
    --
    -- bug 2429322: check that all stops are closed when
    --              automatically closing delivery.
    --    Sufficient to check drop off stops only;
    --    A drop off stop being closed implies that pick up stop is closed.
    CURSOR stops_not_closed(p_delivery_id NUMBER, p_stop_id NUMBER) IS
    SELECT 1
    FROM   wsh_trip_stops ts,
           wsh_delivery_legs dg
    WHERE  dg.delivery_id  = p_delivery_id
    AND    ts.stop_id      = dg.drop_off_stop_id
    AND    ts.stop_id     <> p_stop_id
    AND    ts.status_code in ('OP', 'AR')
    AND    rownum = 1;
    --
    --
    /*Refer POD Information from WSH_DELIVERY_LEGS. Bug#1918342*/
    --
    -- Check if POD has been pending (pod_date null)
    --
    CURSOR check_POD (p_stop_id NUMBER) IS
    SELECT 1
    FROM   wsh_delivery_legs dg,
           wsh_document_instances di
    WHERE  dg.drop_off_stop_id = p_stop_id
    AND    di.entity_id        = dg.delivery_leg_id
    AND    di.entity_name      = 'WSH_DELIVERY_LEGS'
    AND    di.document_type    = 'BOL'
    AND    dg.pod_flag         = 'Y'
    AND    dg.pod_date         IS NULL
    AND    di.status           IN ('OPEN','PLANNED');
    --
    --
    CURSOR have_details (p_delivery_id NUMBER) IS
    SELECT 1
    FROM   wsh_delivery_assignments_v
    WHERE  delivery_id = p_delivery_id
    AND    rownum      = 1;
    --
    --
    CURSOR have_legs (p_delivery_id NUMBER) IS
    SELECT 1
    FROM   wsh_delivery_legs
    WHERE  delivery_id = p_delivery_id
    AND    rownum      = 1;
    --
    --
    -- Check if delivery is associated with any OP/AR stops which
    -- also has some other deliveries associated with it.
    --
    CURSOR shared_stops_csr (p_delivery_id NUMBER)
    IS
    SELECT 1
    FROM   wsh_delivery_legs wdl,
           wsh_Trip_stops    wts
    WHERE  wdl.delivery_id = p_delivery_id
    AND    (
                wdl.pick_up_stop_id  = wts.stop_id
             OR wdl.drop_off_stop_id = wts.stop_id
           )
    AND    wts.status_code <> 'CL'
    AND    EXISTS
            (
                SELECT 1
                FROM   wsh_delivery_legs wdl1, wsh_new_deliveries wnd
                WHERE  wdl1.delivery_id  <> p_delivery_id
                AND    wdl1.delivery_id = wnd.delivery_id
                AND    wnd.delivery_type = 'STANDARD'
                AND    (
                            wdl1.pick_up_stop_id  = wts.stop_id
                         OR wdl1.drop_off_stop_id = wts.stop_id
                       )
            )
    AND    rownum = 1;
    --
    --
    l_dummy           NUMBER;
    l_num_warnings          NUMBER;
    l_num_errors            NUMBER;
    --
    -- Exception variables
    l_exceptions_tab  wsh_xc_util.XC_TAB_TYPE;
    l_exp_logged      BOOLEAN := FALSE;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(4000);
    l_return_status   VARCHAR2(1);
    l_exp_warning     BOOLEAN := FALSE;
    --
    l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_CLOSE';
--}
BEGIN
--{
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
        wsh_debug_sv.LOG(l_module_name, 'p_in_rec.DELIVERY_ID ', p_in_rec.delivery_id );
        wsh_debug_sv.LOG(l_module_name, 'p_in_rec.name        ', p_in_rec.name        );
        wsh_debug_sv.LOG(l_module_name, 'p_in_rec.status_code ', p_in_rec.status_code );
        wsh_debug_sv.LOG(l_module_name, 'p_in_rec.put_messages', p_in_rec.put_messages);
        wsh_debug_sv.LOG(l_module_name, 'p_in_rec.manual_flag ', p_in_rec.manual_flag );
        wsh_debug_sv.LOG(l_module_name, 'p_in_rec.caller      ', p_in_rec.caller      );
        wsh_debug_sv.LOG(l_module_name, 'p_in_rec.actual_date ', p_in_rec.actual_date );
        wsh_debug_sv.LOG(l_module_name, 'p_in_rec.stop_id     ', p_in_rec.stop_id     );
    END IF;
    --
    l_num_warnings  := 0;
    l_num_errors    := 0;
    --
    IF p_in_rec.manual_flag = 'N'
    THEN
    --{
        -- bug 2429322: Make sure all stops associated with this delivey
        --    are closed, especially if delivery is on two or more trips.
        --
        --
        IF p_in_rec.stop_id IS NULL
        THEN
            RAISE wsh_util_core.e_not_allowed;
        END IF;
        --
        --
        OPEN  stops_not_closed(p_in_rec.delivery_id, p_in_rec.stop_id);
        FETCH stops_not_closed INTO l_dummy;
        --
        IF stops_not_closed%FOUND
        THEN
            --CLOSE stops_not_closed;
            --
            -- Delivery associated with stops which are not closed
            -- Cannot close delivery.
            --
            FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVY_NO_CLOSE_OPEN_STOP');
            FND_MESSAGE.SET_TOKEN('DEL_NAME', wsh_new_deliveries_pvt.get_name(p_in_rec.delivery_id));
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);
            RAISE wsh_util_core.e_not_allowed;
        END IF;
        CLOSE stops_not_closed;
        --
        OPEN  check_pod (p_in_rec.stop_id);
        FETCH check_pod INTO l_dummy;
        --
        IF check_pod%FOUND
        THEN
            --CLOSE check_pod;
            --
            -- POD not received
            -- Cannot close delivery.
            --
            FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVY_NO_CLOSE_POD');
            FND_MESSAGE.SET_TOKEN('DEL_NAME', wsh_new_deliveries_pvt.get_name(p_in_rec.delivery_id));
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);
            RAISE wsh_util_core.e_not_allowed;
        END IF;
        --
        CLOSE check_pod;
        --
    --}
    ELSE        -- p_manual_flag = 'Y'
    --{
        IF p_in_rec.status_code = 'OP'
        THEN
        --{
            --
            OPEN  have_details (p_in_rec.delivery_id);
            FETCH have_details INTO l_dummy;
            --
            IF have_details%FOUND
            THEN
                --CLOSE have_details;
                --
                -- Delivery has lines
                -- Cannot close delivery.
                --
                FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVY_NO_CLOSE_DETAIL');
                FND_MESSAGE.SET_TOKEN('DEL_NAME', wsh_new_deliveries_pvt.get_name(p_in_rec.delivery_id));
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);
                RAISE wsh_util_core.e_not_allowed;

            END IF;
            --
            CLOSE have_details;
            --
            --
            OPEN  have_legs (p_in_rec.delivery_id);
            FETCH have_legs INTO l_dummy;
            --
            IF have_legs%FOUND
            THEN
                --CLOSE have_legs;
                --
                -- Delivery has legs
                -- Cannot close delivery.
                --
                FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVY_NO_CLOSE_LEGS');
                FND_MESSAGE.SET_TOKEN('DEL_NAME', wsh_new_deliveries_pvt.get_name(p_in_rec.delivery_id));
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);

                RAISE wsh_util_core.e_not_allowed;
            END IF;
            --
            CLOSE have_legs;
            --
        --}
        ELSIF p_in_rec.status_code = 'IT'
        THEN
        --{
            -- Look for stops that are not closed and shared by other deliveries.
            -- These stops should not be shared with other deliveries.
            -- We don't need to worry about closed stops.
            --
            OPEN  shared_stops_csr (p_in_rec.delivery_id);
            FETCH shared_stops_csr INTO l_dummy;
            --
            IF shared_stops_csr%FOUND
            THEN
                --CLOSE shared_stops_csr;
                FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVY_NO_CLOSE_SHR_STOPS');
                FND_MESSAGE.SET_TOKEN('DEL_NAME', wsh_new_deliveries_pvt.get_name(p_in_rec.delivery_id));
                wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);
                RAISE wsh_util_core.e_not_allowed;
            END IF;
            --
            CLOSE shared_stops_csr;
        --}
        ELSE
        --{
            RAISE wsh_util_core.e_not_allowed;
        --}
        END IF;
    --}
    END IF;
    --

    -- Check for Exceptions against Delivery and its Contents
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Check_Exceptions',WSH_DEBUG_SV.C_PROC_LEVEL);    END IF;
    l_exceptions_tab.delete;
    l_exp_logged      := FALSE;
    l_exp_warning     := FALSE;
    WSH_XC_UTIL.Check_Exceptions (
                                     p_api_version           => 1.0,
                                     x_return_status         => l_return_status,
                                     x_msg_count             => l_msg_count,
                                     x_msg_data              => l_msg_data,
                                     p_logging_entity_id     => p_in_rec.delivery_id,
                                     p_logging_entity_name   => 'DELIVERY',
                                     p_consider_content      => 'Y',
                                     x_exceptions_tab        => l_exceptions_tab
                                   );
    IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
         x_return_status := l_return_status;
         wsh_util_core.add_message(x_return_status);
         RAISE FND_API.G_EXC_ERROR;
    END IF;
    FOR exp_cnt in 1..l_exceptions_tab.COUNT LOOP
         IF l_exceptions_tab(exp_cnt).exception_behavior = 'ERROR' THEN
            IF l_exceptions_tab(exp_cnt).entity_name = 'DELIVERY' THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_ENTITY');
            ELSE
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_CONTENTS');
            END IF;
            FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Delivery');
            FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_exceptions_tab(exp_cnt).entity_id);
            FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Error');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            wsh_util_core.add_message(x_return_status);
            l_num_warnings := l_num_warnings + 1 ;
            RAISE wsh_util_core.e_not_allowed;
         ELSIF l_exceptions_tab(exp_cnt).exception_behavior = 'WARNING' THEN
            IF l_exceptions_tab(exp_cnt).entity_name = 'DELIVERY' THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_ENTITY');
               FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Delivery');
               FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_exceptions_tab(exp_cnt).entity_id);
               FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Warning');
               x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
               wsh_util_core.add_message(x_return_status);
               l_num_warnings := l_num_warnings + 1 ;
               l_exp_warning := TRUE;
            ELSIF NOT (l_exp_logged) THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_CONTENTS');
               FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Delivery');
               FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_exceptions_tab(exp_cnt).entity_id);
               FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Warning');
               x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
               l_exp_logged := TRUE;
               wsh_util_core.add_message(x_return_status);
               l_num_warnings := l_num_warnings + 1 ;
               l_exp_warning := TRUE;
            END IF;
         END IF;
    END LOOP;


   IF l_num_errors > 0
   THEN
        x_return_status         := WSH_UTIL_CORE.G_RET_STS_ERROR;
        x_allowed               := 'N';
   ELSIF l_num_warnings > 0
   THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;
   --
   --
   -- If Exceptions have warnings, then display warnings but allow to proceed
   IF l_exp_warning THEN
      x_allowed := 'YW';
   ELSE
      x_allowed := 'Y';
   END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
--}
EXCEPTION
--{
    WHEN wsh_util_core.e_not_allowed THEN
      IF l_num_warnings > 0
      THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      ELSE
          x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      END IF;
      --
      x_allowed       := 'N';
      --
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_util_core.e_not_allowed exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_util_core.e_not_allowed');
      END IF;
      --
    WHEN wsh_util_core.e_not_allowed_warning THEN
      IF l_num_warnings > 0
      THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      ELSE
          x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      END IF;
      --
      x_allowed := 'NW';
      --
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

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

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.Check_Close',l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
--}
END;
-- J-IB-NPARIKH-}



-----------------------------------------------------------------------------
--
-- Procedure:     Check_Delete_Delivery
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Delete Delivery action pre-requisites which are
--                - Delivery status is OPEN
--                - No freight costs assigned to delivery [warning]
--  NOT SUPPORTED YET              - No documents assigned to delivery [warning]
--                - No delivery details assigned to this delivery [warning]
--
-----------------------------------------------------------------------------

PROCEDURE Check_Delete_Delivery ( p_delivery_id   	IN  NUMBER,
		        	  x_return_status 	OUT NOCOPY  VARCHAR2) IS

CURSOR delivery_status IS
SELECT status_code, routing_response_id, --J-IB-NPARIKH
       delivery_type,
       tms_interface_flag --OTM R12
FROM   wsh_new_deliveries
WHERE  delivery_id = p_delivery_id;

CURSOR detail_info IS
SELECT delivery_detail_id
FROM   wsh_delivery_assignments_v
WHERE  delivery_id = p_delivery_id
FOR UPDATE NOWAIT;

CURSOR leg_info IS
SELECT delivery_leg_id
FROM   wsh_delivery_legs
WHERE  delivery_id = p_delivery_id
FOR UPDATE NOWAIT;

CURSOR freight_costs_exist IS
SELECT freight_cost_id
FROM   wsh_freight_costs
WHERE  delivery_id = p_delivery_id
FOR UPDATE NOWAIT;

l_del_status  VARCHAR2(2);
l_detail_id   NUMBER;
l_routingResponseId   NUMBER;
l_flag        VARCHAR2(1) := 'N';
l_delivery_type VARCHAR2(30);
others        EXCEPTION;

record_locked                 EXCEPTION;
PRAGMA EXCEPTION_INIT(record_locked, -54);
--OTM R12
cannot_delete_GC3_delivery EXCEPTION;
l_gc3_is_installed         VARCHAR2(1);
l_tms_interface_flag       WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE;
--


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_DELETE_DELIVERY';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


   --OTM R12
   l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED; -- this is global variable

   IF l_gc3_is_installed IS NULL THEN
     l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED; -- this is actual function
   END IF;
   --


   OPEN delivery_status;
   FETCH delivery_status INTO l_del_status,
                              l_routingResponseId,
                              l_delivery_type,
                              l_tms_interface_flag;  --OTM R12

   IF (delivery_status%NOTFOUND) THEN
	 CLOSE delivery_status;
	 RAISE others;
   END IF;

   CLOSE delivery_status;

   --OTM R12, can only delete NS flag deliveries when gc3 is installed
   IF (l_gc3_is_installed = 'Y'
       AND l_tms_interface_flag <> WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT) THEN

     RAISE cannot_delete_gc3_delivery;
   END IF;
   --

   IF (l_del_status = 'CL') OR (l_del_status = 'CO') THEN
	    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DELETE_ERROR');
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
   END IF;
			--
			--
   --{ --J-IB-NPARIKH
			-- Routing response is sent for delivery, cannot be deleted.
			--
   IF l_routingResponseId IS NOT NULL
			THEN
	    FND_MESSAGE.SET_NAME('WSH','WSH_IB_DELETE_DELIVERY');
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
   END IF;
   --} --J-IB-NPARIKH
   -- 1. Checks if details exist for the delivery and locks them
   FOR dt IN detail_info LOOP
	l_flag := 'Y';
   END LOOP;

   IF (l_flag = 'Y') THEN
	    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DETAILS_UNASSIGNED');
            FND_MESSAGE.SET_TOKEN('DEL_NAME', wsh_new_deliveries_pvt.get_name(p_delivery_id));
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	    wsh_util_core.add_message(x_return_status);
   END IF;

   -- 2. Checks if legs exist for the delivery and locks them
   l_flag := 'N';
   FOR dt IN leg_info LOOP
	l_flag := 'Y';
   END LOOP;

   IF (l_flag = 'Y')  and l_delivery_type = 'STANDARD' THEN
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DELETE_WITH_LEGS');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         FND_MESSAGE.SET_TOKEN('DEL_NAME', wsh_new_deliveries_pvt.get_name(p_delivery_id));
	 wsh_util_core.add_message(x_return_status);
   END IF;

   -- 3. Checks if freight costs exist for the delivery and locks them
   l_flag := 'N';
   FOR fc IN freight_costs_exist LOOP
	 l_flag := 'Y';
   END LOOP;

   IF (l_flag = 'Y') THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DELETE_WITH_FC');
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      FND_MESSAGE.SET_TOKEN('DEL_NAME', wsh_new_deliveries_pvt.get_name(p_delivery_id));
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
      --OTM R12
      WHEN cannot_delete_gc3_delivery THEN

        IF (delivery_status%ISOPEN) THEN
          CLOSE delivery_status;
        END IF;

        IF (leg_info%ISOPEN) THEN
          CLOSE leg_info;
        END IF;

        IF (detail_info%ISOPEN) THEN
          CLOSE detail_info;
        END IF;

        IF (freight_costs_exist%ISOPEN) THEN
          CLOSE freight_costs_exist;
        END IF;

        FND_MESSAGE.SET_NAME('WSH','WSH_OTM_DEL_DELETE_ERROR');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.add_message(x_return_status,l_module_name);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'CANNOT_DELETE_GC3_DELIVERY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CANNOT_DELETE_GC3_DELIVERY');
        END IF;
      --END OTM R12

      WHEN record_locked THEN

        IF (delivery_status%ISOPEN) THEN
          CLOSE delivery_status;
        END IF;

        IF (leg_info%ISOPEN) THEN
          CLOSE leg_info;
        END IF;

        IF (detail_info%ISOPEN) THEN
          CLOSE detail_info;
        END IF;

        IF (freight_costs_exist%ISOPEN) THEN
          CLOSE freight_costs_exist;
        END IF;

	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

           FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
           wsh_util_core.add_message(x_return_status,l_module_name);


           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'record_locked has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:record_locked');
           END IF;
           --

      WHEN others THEN

        IF (delivery_status%ISOPEN) THEN
          CLOSE delivery_status;
        END IF;

        IF (leg_info%ISOPEN) THEN
          CLOSE leg_info;
        END IF;

        IF (detail_info%ISOPEN) THEN
          CLOSE detail_info;
        END IF;

        IF (freight_costs_exist%ISOPEN) THEN
          CLOSE freight_costs_exist;
        END IF;

	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_DELETE_DELIVERY');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
           END IF;
           --
END Check_Delete_Delivery;



-----------------------------------------------------------------------------
--
-- Procedure:     Check_Change_Carrier
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Change Carrier action pre-requisites which are
--                - Delivery status is OPEN or PACKED
--                - If GROUP_BY_CARRIER_FLAG is set then delivery details do not have a Ship Method specified
--
-----------------------------------------------------------------------------

PROCEDURE Check_Change_Carrier ( p_delivery_id 		IN  NUMBER,
		        	 x_return_status 	OUT NOCOPY  VARCHAR2) IS

CURSOR delivery_status IS
SELECT status_code,
	  organization_id
FROM   wsh_new_deliveries
WHERE  delivery_id = p_delivery_id;

CURSOR detail_info IS
SELECT count(*)
FROM   wsh_delivery_assignments_v da,
	  wsh_delivery_details dd
WHERE  da.delivery_id = p_delivery_id AND
       da.delivery_id IS NOT NULL AND
       da.delivery_detail_id = dd.delivery_detail_id AND
	  dd.ship_method_code IS NULL AND
	  nvl(dd.container_flag,'N') <> 'Y';

l_del_status  VARCHAR2(2);
l_detail_num   NUMBER;
l_org_id       NUMBER;

l_group_by_attr wsh_delivery_autocreate.group_by_flags_rec_type;
l_return_status VARCHAR2(1);
others          EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_CHANGE_CARRIER';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN delivery_status;
   FETCH delivery_status INTO l_del_status, l_org_id;

   IF (delivery_status%NOTFOUND) THEN
	 CLOSE delivery_status;
	 raise others;
   END IF;

   CLOSE delivery_status;

   IF (l_del_status <> 'OP') AND (l_del_status <> 'PA') THEN
	 FND_MESSAGE.SET_NAME('WSH','WSH_DEL_NOT_OP_PA_STATUS');
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
	 RETURN;
   END IF;

   IF (l_org_id IS NULL) THEN
	 raise others;
   ELSE
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.GET_GROUP_BY_ATTR',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 wsh_delivery_autocreate.get_group_by_attr( p_organization_id => l_org_id,
                                                    x_group_by_flags => l_group_by_attr,
                                                    x_return_status => l_return_status);

	 IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	    x_return_status := l_return_status;
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    --
	    RETURN;
      END IF;

   END IF;

   IF (l_group_by_attr.ship_method = 'Y') THEN
      OPEN detail_info;
      FETCH detail_info INTO l_detail_num;
      CLOSE detail_info;

      IF (l_detail_num <> 0) AND (l_detail_num IS NOT NULL) THEN
	    FND_MESSAGE.SET_NAME('WSH','WSH_DEL_CHANGE_SH_M_ERROR');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
      END IF;
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
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_CHANGE_CARRIER');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Change_Carrier;

PROCEDURE Get_Disabled_List(
  p_delivery_id		IN   NUMBER
, p_list_type           IN   VARCHAR2
, x_return_status  	OUT NOCOPY   VARCHAR2
, x_disabled_list  	OUT NOCOPY   wsh_util_core.column_tab_type
, x_msg_count           OUT NOCOPY   NUMBER
, x_msg_data            OUT NOCOPY   VARCHAR2
, p_caller IN VARCHAR2 -- DEFAULT NULL, --3509004:public api changes
)
IS
CURSOR get_delivery_status
IS
SELECT status_code, planned_flag, organization_id,
        nvl(shipment_direction,'O') shipment_direction   -- J-IB-NPARIKH
	, INITIAL_PICKUP_LOCATION_ID, --3509004:public api changes
        delivery_type  -- MDC
FROM   wsh_new_deliveries
WHERE  delivery_id = p_delivery_id;

CURSOR has_delivery_lines
IS
SELECT delivery_detail_id
FROM   wsh_delivery_assignments_v
WHERE  delivery_id = p_delivery_id
AND ROWNUM=1;

CURSOR has_delivery_legs
IS
SELECT delivery_leg_id
FROM wsh_delivery_legs
WHERE delivery_id = p_delivery_id
AND ROWNUM=1;

l_detail_id		NUMBER;
i  			NUMBER := 0;
WSH_DP_NO_ENTITY	EXCEPTION;
WSH_INV_LIST_TYPE	EXCEPTION;
l_status_code		VARCHAR2(2);
l_planned_flag		VARCHAR2(1);
l_shipment_direction  VARCHAR2(30);
l_organization_id	NUMBER;
l_msg_summary           VARCHAR2(2000) := NULL;
l_msg_details           VARCHAR2(4000) := NULL;
l_assigned_to_trip	VARCHAR2(1);
l_delivery_leg_id	NUMBER;
--3509004:public api changes
e_all_disabled EXCEPTION ;
l_shipping_control     VARCHAR2(30);
l_routing_response_id  NUMBER;
l_routing_request_flag VARCHAR2(30);
l_initial_pickup_location_id NUMBER;
l_delivery_type        VARCHAR2(30);

l_return_status               VARCHAR2(30);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DISABLED_LIST';

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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_LIST_TYPE',P_LIST_TYPE);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   -- clear the disabled list
   x_disabled_list.delete;

   OPEN get_delivery_status;
   FETCH get_delivery_status INTO l_status_code, l_planned_flag, l_organization_id, l_shipment_direction,
   l_initial_pickup_location_id, --3509004:public api changes
   l_delivery_type; -- MDC
   IF (get_delivery_status%NOTFOUND) THEN
      CLOSE get_delivery_status;
      RAISE WSH_DP_NO_ENTITY;
   END IF;
   CLOSE get_delivery_status;

   -- Check if delivery is assigned to a trip or not
   OPEN has_delivery_legs;
   FETCH has_delivery_legs INTO l_delivery_leg_id;
   IF (has_delivery_legs%NOTFOUND) THEN
      CLOSE has_delivery_legs;
      l_assigned_to_trip := 'N';
   ELSE
      CLOSE has_delivery_legs;
      l_assigned_to_trip := 'Y';
   END IF;


   IF (l_status_code IN ('CO', 'IT', 'CL')) THEN
      i:=i+1; x_disabled_list(i) := 'FULL';
      i:=i+1; x_disabled_list(i) := 'GLOBALIZATION_FLEXFIELD';
      i:=i+1; x_disabled_list(i) := 'TP_FLEXFIELD';
      i:=i+1; x_disabled_list(i) := 'DESC_FLEX';
      IF (l_status_code = 'CO') THEN
         i:=i+1; x_disabled_list(i) := 'ADDITIONAL_SHIPMENT_INFO';
         i:=i+1; x_disabled_list(i) := 'DOCK_CODE';
      ELSIF (l_status_code = 'IT') THEN
         i:=i+1; x_disabled_list(i) := 'ADDITIONAL_SHIPMENT_INFO';
         i:=i+1; x_disabled_list(i) := 'DOCK_CODE';
         i:=i+1; x_disabled_list(i) := '+ACCEPTANCE_FLAG';
         i:=i+1; x_disabled_list(i) := '+ACCEPTED_BY';
         i:=i+1; x_disabled_list(i) := '+ACCEPTED_DATE';
         i:=i+1; x_disabled_list(i) := '+ACKNOWLEDGED_BY';
      ELSIF (l_status_code = 'CL') THEN
         i:=i+1; x_disabled_list(i) := '+ACCEPTANCE_FLAG';
         i:=i+1; x_disabled_list(i) := '+ACCEPTED_BY';
         i:=i+1; x_disabled_list(i) := '+ACCEPTED_DATE';
         i:=i+1; x_disabled_list(i) := '+ACKNOWLEDGED_BY';
      END IF;
      --
      -- J-IB-NPARIKH-{
      --
      IF  l_shipment_direction NOT IN ('O','IO')
      AND l_status_code IN ('IT', 'CL')
      THEN
      --{
            --
            -- Weight/Volume/No of LPN are updateable
            -- for in-transit/closed inbound (not O/IO) deliveries
            --
            i:=i+1; x_disabled_list(i) := 'GROSS_WEIGHT';
            i:=i+1; x_disabled_list(i) := 'TARE_WEIGHT';
            i:=i+1; x_disabled_list(i) := 'NET_WEIGHT';
            i:=i+1; x_disabled_list(i) := 'WEIGHT_UOM_CODE';
            i:=i+1; x_disabled_list(i) := 'VOLUME';
            i:=i+1; x_disabled_list(i) := 'VOLUME_UOM_CODE';
            i:=i+1; x_disabled_list(i) := 'NUMBER_OF_LPN';
            -- Bug 4539613: Proration is allowed for in-transit/closed inbound deliveries.
            i:=i+1; x_disabled_list(i) := 'PRORATE_WT_FLAG';
            --
            --
            IF l_assigned_to_trip = 'N'
            THEN
            --{
                --
                -- Ship method/carrier/mode/service level updateable (only if NULL)
                -- for in-transit/closed inbound (not O/IO) deliveries
                --
		IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN --3509004:public api changes
                   i:=i+1; x_disabled_list(i) := '+SHIP_METHOD_CODE';
                   i:=i+1; x_disabled_list(i) := '+CARRIER_ID';
                   i:=i+1; x_disabled_list(i) := '+SERVICE_LEVEL';
                   i:=i+1; x_disabled_list(i) := '+MODE_OF_TRANSPORT';
		ELSE
                   i:=i+1; x_disabled_list(i) := '+SHIP_METHOD_NAME';
                   i:=i+1; x_disabled_list(i) := '+FREIGHT_CODE';
                   i:=i+1; x_disabled_list(i) := '+SERVICE_LEVEL_NAME';
                   i:=i+1; x_disabled_list(i) := '+MODE_OF_TRANSPORT_NAME';
		END IF;
            --}
            END IF;
            --
            --
            -- Waybill updateable for in-transit inbound (not O/IO) deliveries
            --
            IF l_status_code = 'IT'
            THEN
                i:=i+1; x_disabled_list(i) := 'WAYBILL';
            END IF;
            --
      --}
      END IF;
      --
      -- J-IB-NPARIKH-}
      --
      IF (p_list_type = 'FORM') THEN
         NULL; /* more form field name */
      ELSIF (p_list_type = 'TABLE') THEN
         NULL; /* table columns */
      ELSE
         RAISE WSH_INV_LIST_TYPE;
      END IF;

   ELSIF (l_status_code = 'PA') THEN
      IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN --3509004:public api changes
        i:=i+1; x_disabled_list(i) := 'INITIAL_PICKUP_LOCATION_ID';
        i:=i+1; x_disabled_list(i) := 'ULTIMATE_DROPOFF_LOCATION_ID';
        i:=i+1; x_disabled_list(i) := 'CUSTOMER_ID';
        i:=i+1; x_disabled_list(i) := 'ORGANIZATION_ID';
      ELSE
        i:=i+1; x_disabled_list(i) := 'INITIAL_PICKUP_LOCATION_CODE';
        i:=i+1; x_disabled_list(i) := 'ULTIMATE_DROPOFF_LOCATION_CODE';
        i:=i+1; x_disabled_list(i) := 'CUSTOMER_NAME';
        i:=i+1; x_disabled_list(i) := 'ORGANIZATION_CODE';
      END IF;

      i:=i+1; x_disabled_list(i) := 'LOADING_ORDER_FLAG';
      i:=i+1; x_disabled_list(i) := 'ACCEPTANCE_FLAG';
      i:=i+1; x_disabled_list(i) := 'ACCEPTED_BY';
      i:=i+1; x_disabled_list(i) := 'ACCEPTED_DATE';
      i:=i+1; x_disabled_list(i) := 'ACKNOWLEDGED_BY';
      i:=i+1; x_disabled_list(i) := '+CONFIRMED_BY';
      i:=i+1; x_disabled_list(i) := 'CURRENCY_CODE';
      IF (l_planned_flag IN ('Y','F')) THEN
         i:=i+1; x_disabled_list(i) := 'NAME';
         i:=i+1; x_disabled_list(i) := 'INITIAL_PICKUP_DATE';
         i:=i+1; x_disabled_list(i) := 'ULTIMATE_DROPOFF_DATE';
         IF (l_planned_flag ='F') THEN
	    i:=i+1; x_disabled_list(i) := 'LOADING_SEQUENCE';
         END IF;
         IF (l_assigned_to_trip = 'Y') THEN
	    IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN --3509004:public api changes
               i:=i+1; x_disabled_list(i) := 'SHIP_METHOD_CODE';
               i:=i+1; x_disabled_list(i) := 'CARRIER_ID';
               i:=i+1; x_disabled_list(i) := 'SERVICE_LEVEL';
               i:=i+1; x_disabled_list(i) := 'MODE_OF_TRANSPORT';
	    ELSE
               i:=i+1; x_disabled_list(i) := 'SHIP_METHOD_NAME';
               i:=i+1; x_disabled_list(i) := 'FREIGHT_CODE';
               i:=i+1; x_disabled_list(i) := 'SERVICE_LEVEL_NAME';
               i:=i+1; x_disabled_list(i) := 'MODE_OF_TRANSPORT_NAME';
	    END IF;
         END IF;
      ELSE
         IF (l_assigned_to_trip = 'Y') THEN
            i:=i+1; x_disabled_list(i) := 'INITIAL_PICKUP_DATE';
            i:=i+1; x_disabled_list(i) := 'ULTIMATE_DROPOFF_DATE';
	    IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN --3509004:public api changes
               i:=i+1; x_disabled_list(i) := 'SHIP_METHOD_CODE';
               i:=i+1; x_disabled_list(i) := 'CARRIER_ID';
               i:=i+1; x_disabled_list(i) := 'SERVICE_LEVEL';
               i:=i+1; x_disabled_list(i) := 'MODE_OF_TRANSPORT';
	    ELSE
               i:=i+1; x_disabled_list(i) := 'SHIP_METHOD_NAME';
               i:=i+1; x_disabled_list(i) := 'FREIGHT_CODE';
               i:=i+1; x_disabled_list(i) := 'SERVICE_LEVEL_NAME';
               i:=i+1; x_disabled_list(i) := 'MODE_OF_TRANSPORT_NAME';
	    END IF;
         END IF;
      END IF; -- if planned

/* H integration: data protection wrudge */
   ELSIF (l_status_code IN ('OP', 'SA', 'SR', 'SC')) THEN
      i:=i+1; x_disabled_list(i) := 'ACCEPTANCE_FLAG';
      i:=i+1; x_disabled_list(i) := 'ACCEPTED_BY';
      i:=i+1; x_disabled_list(i) := 'ACCEPTED_DATE';
      i:=i+1; x_disabled_list(i) := 'ACKNOWLEDGED_BY';
      i:=i+1; x_disabled_list(i) := '+CONFIRMED_BY';

      --"Proration of weight from Delivery to delivery lines" Project(Bug#4254552).
      IF l_status_code IN ('SA', 'SR', 'SC') THEN
           i:=i+1; x_disabled_list(i) := 'PRORATE_WT_FLAG';
      END IF;

      --{ J-IB-NPARIKH
      --
      -- No updates on freight term for inbound delivery (not O/IO)
      --
      IF  l_shipment_direction NOT IN ('O','IO')
      THEN
          IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN --3509004:public api changes
             i:=i+1; x_disabled_list(i) := 'FREIGHT_TERMS_CODE';
	  ELSE
             i:=i+1; x_disabled_list(i) := 'FREIGHT_TERMS_NAME';
	  END IF;
      END IF;
      --} J-IB-NPARIKH
      --
      --
/* H integration: data protection wrudge */
      IF (l_status_code IN ('SR', 'SC')) THEN
         -- Outbound document has been sent for this delivery.
	 i:=i+1; x_disabled_list(i) := 'NAME';
	 IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN --3509004:public api changes
           i:=i+1; x_disabled_list(i) := 'INTMED_SHIP_TO_LOCATION_ID';
           i:=i+1; x_disabled_list(i) := 'POOLED_SHIP_TO_LOCATION_ID';
           i:=i+1; x_disabled_list(i) := 'FOB_CODE';
           i:=i+1; x_disabled_list(i) := 'FOB_LOCATION_ID';
           i:=i+1; x_disabled_list(i) := 'FREIGHT_TERMS_CODE';
	 ELSE
           i:=i+1; x_disabled_list(i) := 'INTMED_SHIP_TO_LOCATION_CODE';
           i:=i+1; x_disabled_list(i) := 'POOLED_SHIP_TO_LOCATION_CODE';
           i:=i+1; x_disabled_list(i) := 'FOB_NAME';
           i:=i+1; x_disabled_list(i) := 'FOB_LOCATION_CODE';
           i:=i+1; x_disabled_list(i) := 'FREIGHT_TERMS_NAME';
	 END IF;
         i:=i+1; x_disabled_list(i) := 'WAYBILL';
         i:=i+1; x_disabled_list(i) := 'GROSS_WEIGHT';
         i:=i+1; x_disabled_list(i) := 'TARE_WEIGHT';
         i:=i+1; x_disabled_list(i) := 'NET_WEIGHT';
         i:=i+1; x_disabled_list(i) := 'WEIGHT_UOM_CODE';
         i:=i+1; x_disabled_list(i) := 'VOLUME';
         i:=i+1; x_disabled_list(i) := 'VOLUME_UOM_CODE';
	 i:=i+1; x_disabled_list(i) := 'NUMBER_OF_LPN';

         -- treat deliveries sent outbound as planned and assigned to trip.
         l_planned_flag     := 'Y';
         l_assigned_to_trip := 'Y';
      END IF;

      --J TP Release : firm del will always have a trip
      IF (l_planned_flag IN ('Y','F')) THEN
	 IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN --3509004:public api changes
           i:=i+1; x_disabled_list(i) := 'INITIAL_PICKUP_LOCATION_ID';
           i:=i+1; x_disabled_list(i) := 'ULTIMATE_DROPOFF_LOCATION_ID';
           i:=i+1; x_disabled_list(i) := 'ORGANIZATION_ID';
           i:=i+1; x_disabled_list(i) := 'CUSTOMER_ID';
           i:=i+1; x_disabled_list(i) := 'CLIENT_ID';	-- Modified R12.1.1 LSP PROJECT
         ELSE
           i:=i+1; x_disabled_list(i) := 'INITIAL_PICKUP_LOCATION_CODE';
           i:=i+1; x_disabled_list(i) := 'ULTIMATE_DROPOFF_LOCATION_CODE';
           i:=i+1; x_disabled_list(i) := 'ORGANIZATION_CODE';
           i:=i+1; x_disabled_list(i) := 'CUSTOMER_NAME';
           i:=i+1; x_disabled_list(i) := 'CLIENT_NAME';	-- Modified R12.1.1 LSP PROJECT
	 END IF;
         i:=i+1; x_disabled_list(i) := 'INITIAL_PICKUP_DATE';
         i:=i+1; x_disabled_list(i) := 'ULTIMATE_DROPOFF_DATE';
         i:=i+1; x_disabled_list(i) := 'LOADING_ORDER_FLAG';
         i:=i+1; x_disabled_list(i) := 'CURRENCY_CODE';
	 IF (l_planned_flag ='F') THEN
	    i:=i+1; x_disabled_list(i) := 'LOADING_SEQUENCE';
         END IF;

         IF (l_assigned_to_trip = 'Y') THEN
	    IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN --3509004:public api changes
               i:=i+1; x_disabled_list(i) := 'SHIP_METHOD_CODE';
               i:=i+1; x_disabled_list(i) := 'CARRIER_ID';
               i:=i+1; x_disabled_list(i) := 'SERVICE_LEVEL';
               i:=i+1; x_disabled_list(i) := 'MODE_OF_TRANSPORT';
	    ELSE
               i:=i+1; x_disabled_list(i) := 'SHIP_METHOD_NAME';
               i:=i+1; x_disabled_list(i) := 'FREIGHT_CODE';
               i:=i+1; x_disabled_list(i) := 'SERVICE_LEVEL_NAME';
               i:=i+1; x_disabled_list(i) := 'MODE_OF_TRANSPORT_NAME';
	    END IF;
         END IF;
      ELSE -- if not planned
         IF (l_assigned_to_trip = 'Y') THEN
	    IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN --3509004:public api changes
               i:=i+1; x_disabled_list(i) := 'INITIAL_PICKUP_LOCATION_ID';
               i:=i+1; x_disabled_list(i) := 'ULTIMATE_DROPOFF_LOCATION_ID';
               i:=i+1; x_disabled_list(i) := 'CUSTOMER_ID';
               i:=i+1; x_disabled_list(i) := 'ORGANIZATION_ID';
               i:=i+1; x_disabled_list(i) := 'SHIP_METHOD_CODE';
               i:=i+1; x_disabled_list(i) := 'CARRIER_ID';
               i:=i+1; x_disabled_list(i) := 'SERVICE_LEVEL';
               i:=i+1; x_disabled_list(i) := 'MODE_OF_TRANSPORT';
	    ELSE
               i:=i+1; x_disabled_list(i) := 'INITIAL_PICKUP_LOCATION_CODE';
               i:=i+1; x_disabled_list(i) := 'ULTIMATE_DROPOFF_LOCATION_CODE';
               i:=i+1; x_disabled_list(i) := 'CUSTOMER_NAME';
               i:=i+1; x_disabled_list(i) := 'ORGANIZATION_CODE';
               i:=i+1; x_disabled_list(i) := 'SHIP_METHOD_NAME';
               i:=i+1; x_disabled_list(i) := 'FREIGHT_CODE';
               i:=i+1; x_disabled_list(i) := 'SERVICE_LEVEL_NAME';
               i:=i+1; x_disabled_list(i) := 'MODE_OF_TRANSPORT_NAME';
	    END IF;
            i:=i+1; x_disabled_list(i) := 'INITIAL_PICKUP_DATE';
            i:=i+1; x_disabled_list(i) := 'ULTIMATE_DROPOFF_DATE';
         END IF;
         -- check in the delivery has delivery lines
         OPEN has_delivery_lines;
         FETCH has_delivery_lines INTO l_detail_id;
         IF (has_delivery_lines%NOTFOUND) THEN
           -- Modified R12.1.1 LSP PROJECT: Disable client info even for not assigned deliveries
           -- when deployment mode is other than LSP.
           IF (WMS_DEPLOY.WMS_DEPLOYMENT_MODE <> 'L') THEN
             IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN
               i:=i+1; x_disabled_list(i) := 'CLIENT_ID';
             ELSE
               i:=i+1; x_disabled_list(i) := 'CLIENT_NAME';
             END IF;
           END IF;
           -- Modified R12.1.1 LSP PROJECT: End
           CLOSE has_delivery_lines;
         ELSE
            CLOSE has_delivery_lines;
	    IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN --3509004:public api changes
               i:=i+1; x_disabled_list(i) := 'INITIAL_PICKUP_LOCATION_ID';
               i:=i+1; x_disabled_list(i) := 'ULTIMATE_DROPOFF_LOCATION_ID';
               i:=i+1; x_disabled_list(i) := 'CUSTOMER_ID';
               i:=i+1; x_disabled_list(i) := 'ORGANIZATION_ID';
               i:=i+1; x_disabled_list(i) := 'CLIENT_ID';	-- Modified R12.1.1 LSP PROJECT
	    ELSE
               i:=i+1; x_disabled_list(i) := 'INITIAL_PICKUP_LOCATION_CODE';
               i:=i+1; x_disabled_list(i) := 'ULTIMATE_DROPOFF_LOCATION_CODE';
               i:=i+1; x_disabled_list(i) := 'CUSTOMER_NAME';
               i:=i+1; x_disabled_list(i) := 'ORGANIZATION_CODE';
               i:=i+1; x_disabled_list(i) := 'CLIENT_NAME';	-- Modified R12.1.1 LSP PROJECT
	    END IF;
            i:=i+1; x_disabled_list(i) := 'CURRENCY_CODE';
         END IF;
      END IF;

      -- MDC: disable wt/vol related fields for a consol delivery

      IF l_delivery_type = 'CONSOLIDATION' THEN

         i:=i+1; x_disabled_list(i) := 'GROSS_WEIGHT';
         i:=i+1; x_disabled_list(i) := 'NET_WEIGHT';
         i:=i+1; x_disabled_list(i) := 'TARE_WEIGHT';
         i:=i+1; x_disabled_list(i) := 'WEIGHT_UOM_CODE';
         i:=i+1; x_disabled_list(i) := 'VOLUME';
         i:=i+1; x_disabled_list(i) := 'VOLUME_UOM_CODE';
         i:=i+1; x_disabled_list(i) := 'PRORATE_WT_FLAG';

      END IF;

   END IF;

    -- J-IB-NPARIKH-{
    --3509004:public api changes
    --
    -- Update on inbound/drop-ship deliveries are allowed only if caller
    -- starts with  one of the following:
    --     - FTE
    --     - WSH_IB
    --     - WSH_PUB
    --     - WSH_TP_RELEASE
    --
    IF  NVL(l_shipment_direction,'O') NOT IN ('O','IO')
    AND NVL(p_caller, '!!!')                               NOT LIKE 'FTE%'
    AND NVL(p_caller, '!!!')                               NOT LIKE 'WSH_PUB%'
    AND NVL(p_caller, '!!!')                               NOT LIKE 'WSH_IB%'
    AND NVL(p_caller, '!!!')                               NOT LIKE 'WSH_TP_RELEASE%'
    THEN
        RAISE e_all_disabled;
    END IF;

    IF  NVL(l_shipment_direction,'O') NOT IN ('O','IO')
    AND l_status_code IN ('IT', 'CL')
    AND l_initial_pickup_location_id  = WSH_UTIL_CORE.C_NULL_SF_LOCN_ID
    THEN
    --{
         --
         -- For in-transit/closed inbound deliveries (not O/IO),
         -- update of initial pickup location is allowed if Null AND
         --  - supplier is managing transportation
         -- OR
         --  - routing request was not received for all delivery lines
         --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GET_SHIPPING_CONTROL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        GET_SHIPPING_CONTROL
        (
            p_delivery_id           => p_delivery_id,
            x_shipping_control      => l_shipping_control,
            x_routing_response_id   => l_routing_response_id,
            x_routing_request_flag  => l_routing_request_flag,
            x_return_status         => l_return_status
        );
        --
        --
        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'l_return_status', l_return_status);
            wsh_debug_sv.log(l_module_name, 'l_shipping_control', l_shipping_control);
            wsh_debug_sv.log(l_module_name, 'l_routing_response_id', l_routing_response_id);
            wsh_debug_sv.log(l_module_name, 'l_routing_request_flag', l_routing_request_flag);
            --
        END IF;
        --
        --
        IF l_return_status = wsh_util_core.g_ret_sts_unexp_error THEN
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = wsh_util_core.g_ret_sts_error THEN
           raise FND_API.G_EXC_ERROR;
        END IF;
        --
        --
        IF l_shipping_control     = 'SUPPLIER'
        OR l_routing_request_flag = 'N'
        THEN
	    IF NVL(p_caller,'!!!') LIKE 'FTE%' THEN --3509004:public api changes
	       i:=i+1; x_disabled_list(i) := 'INITIAL_PICKUP_LOCATION_ID';
	    ELSE
	       i:=i+1; x_disabled_list(i) := 'INITIAL_PICKUP_LOCATION_CODE';
	    END IF;
        END IF;
    --}
    END IF;
    --
    -- J-IB-NPARIKH-}


-- Commented FTE_IS_INSTALLED If condition for Bug-2801799
/***
   IF  ( WSH_UTIL_CORE.FTE_Is_Installed ='N' ) THEN
    -- Bug Fix 2780610  added the below if condition --
      IF (l_status_code IN ('OP','SA','PA')) THEN
            i:=i+1; x_disabled_list(i) := 'FREIGHT_CODE';
            i:=i+1; x_disabled_list(i) := 'SERVICE_LEVEL_NAME';
            i:=i+1; x_disabled_list(i) := 'MODE_OF_TRANSPORT_NAME';
      END IF;
   END IF;
***/

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
    WHEN e_all_disabled THEN --3509004:public api changes
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_ALL_COLS_DISABLED');
      FND_MESSAGE.Set_Token('ENTITY_ID',p_delivery_id);
      wsh_util_core.add_message(x_return_status,l_module_name);
      IF l_debug_on THEN
        -- Nothing is updateable
        WSH_DEBUG_SV.pop(l_module_name,'e_all_disabled');
      END IF;


      WHEN wsh_dp_no_entity THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('WSH', 'WSH_DP_NO_ENTITY');
         WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
         WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
         IF x_msg_count > 1 then
            x_msg_data := l_msg_summary || l_msg_details;
         ELSE
            x_msg_data := l_msg_summary;
         END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DP_NO_ENTITY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DP_NO_ENTITY');
END IF;
--
      WHEN wsh_inv_list_type THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('WSH', 'WSH_INV_LIST_TYPE');
         WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
         WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
         IF x_msg_count > 1 then
            x_msg_data := l_msg_summary || l_msg_details;
         ELSE
            x_msg_data := l_msg_summary;
         END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INV_LIST_TYPE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INV_LIST_TYPE');
END IF;
--
      WHEN others THEN
         IF (get_delivery_status%ISOPEN) THEN
            CLOSE get_delivery_status;
         END IF;
         IF (has_delivery_lines%ISOPEN) THEN
            CLOSE has_delivery_lines;
         END IF;
         wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.get_disabled_list');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Get_Disabled_List;

-----------------------------------------------------------------------------
--
-- Function:      Check_SS_Imp_Pending
-- Parameters:    p_source_code,
--                p_source_header_id, p_ship_set_id, p_check_transactable,
--                x_return_status
--                  p_check_transactable: If p_check_transactable is Y then
--                                          check whether any transactable
--                                          line is not imported
--                                        else
--                                          check whether any line is not imported
-- Description:   Checks if any lines in the ship set are not yet imported
--                FALSE - All lines are imported into shipping
--                TRUE  - Some lines are not imported into shipping
--
-----------------------------------------------------------------------------

FUNCTION Check_SS_Imp_Pending(
  p_source_code                 IN   VARCHAR2
, p_source_header_id            IN   NUMBER
, p_ship_set_id                 IN   NUMBER
, p_check_transactable          IN   VARCHAR2
, x_return_status               OUT NOCOPY   VARCHAR2
) return BOOLEAN IS
cursor c_pending_lines IS
SELECT oel.line_id
FROM   oe_order_lines_all oel,
       mtl_system_items msi
WHERE  oel.header_id = p_source_header_id
AND    oel.ship_set_id = p_ship_set_id
AND    oel.inventory_item_id = msi.inventory_item_id
and    oel.ship_from_org_id = msi.organization_id
and    ((p_check_transactable = 'N') or (p_check_transactable = 'Y' AND msi.mtl_transactions_enabled_flag = 'Y'))
AND    oel.shipping_interfaced_flag = 'N'
AND (oel.shippable_flag = 'Y' or
     (EXISTS (SELECT 'Y'
              FROM   oe_order_lines_all oel1
              WHERE  oel1.header_id = p_source_header_id
              AND    oel1.ship_set_id = p_ship_set_id
              AND    oel1.ato_line_id = oel1.line_id
              AND    oel1.item_type_code in ('MODEL','CLASS')
              AND    NOT EXISTS (SELECT 'Y'
                                 FROM  oe_order_lines_all oel2
                                 WHERE oel2.top_model_line_id = oel1.top_model_line_id
                                 AND   oel2.ato_line_id = oel1.ato_line_id
                                 AND   oel2.item_type_code = 'CONFIG')
             )
     )
    );
l_lines_exist BOOLEAN;
l_line_id NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_SS_IMP_PENDING';
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
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_HEADER_ID',P_SOURCE_HEADER_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_SHIP_SET_ID',P_SHIP_SET_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_CHECK_TRANSACTABLE',P_CHECK_TRANSACTABLE);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF p_source_code <> 'OE' THEN
    -- assume everything is imported.
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN TRUE;
  END IF;

  l_lines_exist := FALSE;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,  'CHECKING FOR LINES NOT IMPORTED IN SHIP SET '||P_SHIP_SET_ID||' HEADER '||P_SOURCE_HEADER_ID  );
  END IF;
  --
  /* Need to replace the following with OM API once it is available */
  OPEN  c_pending_lines;
  FETCH c_pending_lines
  INTO  l_line_id;
  IF (c_pending_lines%NOTFOUND) THEN
    l_lines_exist := FALSE;
  ELSE
    l_lines_exist := TRUE;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'LINE '||L_LINE_ID||' IS NOT IMPORTED'  );
    END IF;
    --
  END IF;
  CLOSE c_pending_lines;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  return l_lines_exist;

EXCEPTION
  WHEN OTHERS THEN
     wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.Check_SS_Imp_Pending');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     --
END Check_SS_Imp_Pending;

-- This procedure added for bug 2074768

-- HW OPM Added x_max_quantity2
PROCEDURE Check_Delivery_for_tolerances ( p_delivery_id 	   IN  NUMBER,
                                          x_source_line_id        OUT NOCOPY   NUMBER,
                                          x_source_code           OUT NOCOPY   VARCHAR,
					  x_max_quantity          OUT NOCOPY   NUMBER,
					  x_max_quantity2         OUT NOCOPY   NUMBER,
	                                  x_return_status OUT NOCOPY  VARCHAR2 ) is

-- HW OPM retrieve organization to check if line is OPM/Discrete
CURSOR  c_del_lines ( v_delivery_id in number ) is
select  distinct
        dd.source_line_id,
        dd.source_code,
        dd.source_line_number,
        dd.source_header_id,
        dd.source_header_number,
        dd.source_header_type_name,
        dd.organization_id,
        dd.source_line_set_id,     --  Bug 2181132
        dd.ship_tolerance_above,     --  Bug 2181132
        dd.ship_tolerance_below,     --  Bug 2181132
        dd.requested_quantity_uom,  -- Bug 2181132
        dd.requested_quantity_uom2 -- Bug 2181132
from wsh_delivery_assignments_v da,
     wsh_Delivery_details dd
where dd.delivery_detail_id = da.delivery_detail_id
and   da.delivery_id = v_delivery_id
and   dd.container_flag = 'N'
and   dd.released_status <> 'D'
and   da.delivery_id is not null; /* added for performance */

/* csun bug 2401502 , check tolerance for lines with source_code other than OE */
CURSOR c_detail_lines(v_source_code VARCHAR2, v_source_line_id NUMBER) is
select sum( nvl(requested_quantity,0)) requested_quantity,
       sum( nvl(requested_quantity2,0)) requested_quantity2,
       ship_tolerance_above,
       ship_tolerance_below
from wsh_delivery_details
where source_code = v_source_code and
      source_line_id = v_source_line_id and
      container_flag = 'N'
group by ship_tolerance_above,
         ship_tolerance_below;
l_detail_lines c_detail_lines%ROWTYPE;


l_source_header_number WSH_DELIVERY_DETAILS.SOURCE_HEADER_NUMBER%TYPE;
l_source_header_type_name WSH_DELIVERY_DETAILS.SOURCE_HEADER_TYPE_NAME%TYPE;

-- HW OPM added qty2
-- HW OPM added qty2 in the group by
CURSOR  c_total_line_quantities (v_source_line_id in number, v_source_code in varchar2, v_source_header_id IN NUMBER) is
select  sum( greatest ( nvl(shipped_quantity , 0)  ,
			nvl(picked_quantity , requested_quantity )
		      )
	   )  expected_quantity ,
	sum( greatest ( nvl(shipped_quantity2 , 0)  ,
			nvl(picked_quantity2 , requested_quantity2 )
		      )
	   )  expected_quantity2 ,
        src_requested_quantity_uom ,
	requested_quantity_uom ,
	src_requested_quantity_uom2 ,
	requested_quantity_uom2 ,
	inventory_item_id
from    wsh_delivery_details
where   source_line_id = v_source_line_id
and     released_status <> 'D'
and     source_code    = v_source_code
and     container_flag = 'N'
--Bug 3622571
and     source_header_id = v_source_header_id
group by
src_requested_quantity_uom ,
requested_quantity_uom ,
src_requested_quantity_uom2 ,
requested_quantity_uom2 ,
inventory_item_id;

-- HW OPM added qty2
-- HW OPM added qty2 in the group by
/* Get the qty on other deliveries or without deliveries but not on the
   delivery which is being ship confirmed */
CURSOR  c_total_other_line_qty (v_source_line_id in number,
                                v_source_code in varchar2,
                                v_source_header_id IN NUMBER) is
select  sum( greatest ( nvl(wdd.shipped_quantity , 0)  ,
                        nvl(wdd.picked_quantity , wdd.requested_quantity )
                      )
           )  expected_quantity ,
        sum( greatest ( nvl(wdd.shipped_quantity2 , 0)  ,
                        nvl(wdd.picked_quantity2 , wdd.requested_quantity2 )
                      )
           )  expected_quantity2 ,
        wdd.src_requested_quantity_uom ,
        wdd.requested_quantity_uom ,
        wdd.src_requested_quantity_uom2 ,
        wdd.requested_quantity_uom2 ,
        wdd.inventory_item_id
from    wsh_delivery_details wdd,
        wsh_delivery_assignments_v wda
where   wdd.source_line_id = v_source_line_id
and     wdd.released_status <> ('D')
and     wdd.source_code    = v_source_code
and     wdd.delivery_detail_id = wda.delivery_detail_id
and     (wda.delivery_id IS NULL
         OR wda.delivery_id <> p_delivery_id)
and     wdd.container_flag = 'N'
--Bug 3622571
and     wdd.source_header_id = v_source_header_id
group by
wdd.src_requested_quantity_uom ,
wdd.requested_quantity_uom ,
wdd.src_requested_quantity_uom2 ,
wdd.requested_quantity_uom2 ,
wdd.inventory_item_id;

l_total_other_line_qty c_total_other_line_qty%ROWTYPE;

l_total_quantities  c_total_line_quantities%ROWTYPE;
l_bad_quantities  c_total_line_quantities%ROWTYPE;

l_max_quantity   NUMBER;
l_min_quantity   NUMBER;
l_max_quantity2  NUMBER;
l_min_quantity2  NUMBER;
l_source_line_number  VARCHAR(150);
l_source_line_set_id  NUMBER;

l_line_max_quantity NUMBER;
l_line_max_quantity2 NUMBER;

l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(2000);
l_source_system VARCHAR2(80);
l_return_status VARCHAR2(1);

-- 2181132
  l_minmaxinrectype WSH_DETAILS_VALIDATIONS.MinMaxInRecType;
  l_minmaxinoutrectype WSH_DETAILS_VALIDATIONS.MinMaxInOutRecType;
  l_minmaxoutrectype WSH_DETAILS_VALIDATIONS.MinMaxOutRecType;
  l_quantity_uom  WSH_DELIVERY_DETAILS.requested_quantity_uom%TYPE;
  l_quantity_uom2  WSH_DELIVERY_DETAILS.requested_quantity_uom2%TYPE;

others          EXCEPTION;
tolerance_exceeded          EXCEPTION;
-- HW OPM
-- HW OPMCONV. Removed OPM variables

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_DELIVERY_FOR_TOLERANCES';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
   END IF;
   --
   FOR dl in c_del_lines (p_delivery_id )
   LOOP

-- anxsharm
-- Bug 2181132

    l_minmaxinrectype.source_code := dl.source_code;
    l_minmaxinrectype.line_id := dl.source_line_id;
    l_minmaxinrectype.source_header_id := dl.source_header_id;
    l_minmaxinrectype.source_line_set_id := dl.source_line_set_id;
    l_minmaxinrectype.ship_tolerance_above := dl.ship_tolerance_above;
    l_minmaxinrectype.ship_tolerance_below := dl.ship_tolerance_below;
    l_minmaxinrectype.action_flag := 'S'; -- ship confirm
    l_minmaxinrectype.lock_flag := 'N';  -- verify this in UT
    l_minmaxinrectype.quantity_uom := dl.requested_quantity_uom;
    l_minmaxinrectype.quantity_uom2 := dl.requested_quantity_uom2;

  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.GET_MIN_MAX_TOLERANCE_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

               WSH_DETAILS_VALIDATIONS.get_min_max_tolerance_quantity
                 (p_in_attributes  => l_minmaxinrectype,
                  x_out_attributes  => l_minmaxoutrectype,
                  p_inout_attributes  => l_minmaxinoutrectype,
                  x_return_status  => l_return_status,
                  x_msg_count  =>  l_msg_count,
                  x_msg_data =>  l_msg_data
                 );

    l_quantity_uom := l_minmaxoutrectype.quantity_uom;
    l_min_quantity := l_minmaxoutrectype.min_remaining_quantity;
    l_max_quantity := l_minmaxoutrectype.max_remaining_quantity;
    l_quantity_uom2 := l_minmaxoutrectype.quantity2_uom;
    l_min_quantity2 := l_minmaxoutrectype.min_remaining_quantity2;
    l_max_quantity2 := l_minmaxoutrectype.max_remaining_quantity2;


               IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                      raise others ;
               END IF;


       --Bug 3622571
       --Add source_header_id along with line_id and source_code
       --In TPW instance, same source_line_id and source_code combination can exist
       --for different header_ids

       OPEN c_total_line_quantities ( dl.source_line_id , dl.source_code, dl.source_header_id ) ;

       FETCH c_total_line_quantities into l_total_quantities ;
       if c_total_line_quantities%NOTFOUND then
	 raise others ;
       end if ;

       -- Making sure we have not hit an old data-corruption if the same order line has delivery
       -- details in two different UOMs or Items .
       LOOP

         FETCH c_total_line_quantities into l_bad_quantities ;
         EXIT WHEN c_total_line_quantities%NOTFOUND;


         -- Bug 3430649, J Catchweights. Since the secondary uom for catchweight
         -- items is entered only after pick release, it is possible for a source
         -- line to have one detail with secondary uom populated and one without
         -- depending on the released status. We should handle this case w/o
         -- erroring out.

         IF   NVL(l_bad_quantities.requested_quantity_uom2, NVL(l_total_quantities.requested_quantity_uom2, FND_API.G_MISS_CHAR))
              =  NVL(l_total_quantities.requested_quantity_uom2, NVL(l_bad_quantities.requested_quantity_uom2, FND_API.G_MISS_CHAR))
         AND  NVL(l_total_quantities.src_requested_quantity_uom, FND_API.G_MISS_CHAR)
              = NVL(l_bad_quantities.src_requested_quantity_uom, FND_API.G_MISS_CHAR)
         AND  l_total_quantities.requested_quantity_uom = l_bad_quantities.requested_quantity_uom
         AND  NVL(l_total_quantities.inventory_item_id, FND_API.G_MISS_NUM)
              = NVL(l_bad_quantities.inventory_item_id, FND_API.G_MISS_NUM)
         THEN
            l_total_quantities.expected_quantity :=  l_total_quantities.expected_quantity
                                                     + l_bad_quantities.expected_quantity;
         ELSE
            CLOSE c_total_line_quantities;
	    FND_MESSAGE.SET_NAME('WSH','WSH_DATA_CORRUPTION');
            WSH_UTIL_CORE.ADD_MESSAGE(FND_API.G_RET_STS_ERROR);
	    raise others ;
         END IF;

       END LOOP;

       CLOSE c_total_line_quantities ;

-- HW OPM Need to check the org for forking
       --
       -- Debug Statements


       IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_total_quantities.expected_quantity',l_total_quantities.expected_quantity);
       END IF;

       if l_total_quantities.expected_quantity > l_max_quantity  THEN
	   x_source_line_id := dl.source_line_id ;
	   l_source_line_number :=  dl.source_line_number;
	   l_source_header_number :=  dl.source_header_number;
	   l_source_header_type_name :=  dl.source_header_type_name;
           l_source_line_set_id      := dl.source_line_set_id;
	   x_source_code    := dl.source_code ;

         OPEN c_total_other_line_qty( dl.source_line_id , dl.source_code, dl.source_header_id ) ;
         FETCH  c_total_other_line_qty
          INTO  l_total_other_line_qty;
         CLOSE  c_total_other_line_qty;

         IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_total_other_line_qty.expected_quantity',l_total_other_line_qty.expected_quantity);
         END IF;

         x_max_quantity   := l_max_quantity - nvl(l_total_other_line_qty.expected_quantity,0);
         x_max_quantity2  := nvl(l_max_quantity2,0) - nvl(l_total_other_line_qty.expected_quantity2,0);

         -- bug 2429367: provide full maximum quantity if x_max_quantity is negative.
         l_line_max_quantity := l_max_quantity;
         l_line_max_quantity2 := nvl(l_max_quantity2, 0);

         SELECT meaning
           INTO l_source_system
           FROM wsh_lookups
          WHERE lookup_type = 'SOURCE_SYSTEM'
            AND lookup_code = dl.source_code;


	 raise tolerance_exceeded ;
       end if;

   END LOOP;
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
     WHEN tolerance_exceeded   THEN

       -- bug 2429367: give an alternate message if x_max_quantity is negative.
       IF x_max_quantity > 0 THEN

         -- bug 2662327: choose appropriate message based
         -- on line being in a set or not.

	 -- Changes for Bug# 3836415
         IF l_source_line_set_id IS NULL THEN
	   IF l_source_header_type_name is NOT NULL THEN
    	      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_TOLERANCE_EXCEEDED');
              FND_MESSAGE.SET_TOKEN('ORDER_TYPE',l_source_header_type_name);
	   ELSE
    	      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_TOLERANCE_EXCEEDED_OR');
	   END IF;
	 ELSE
	   IF l_source_header_type_name is NOT NULL THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_DEL_TOLERANCE_EXCEED_LS');
              FND_MESSAGE.SET_TOKEN('ORDER_TYPE',l_source_header_type_name);
	   ELSE
    	      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_TOLERANCE_EXCEED_LS_OR');
	   END IF;
	 END IF;
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	 FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',l_source_header_number);
	 FND_MESSAGE.SET_TOKEN('SOURCE_SYSTEM',l_source_system);
	 FND_MESSAGE.SET_TOKEN('LINE_NUM',ltrim( rtrim ( l_source_line_number )) );
	 FND_MESSAGE.SET_TOKEN('MAX_QTY',x_max_quantity);

       ELSE

         -- bug : choose appropriate message based
         -- on line being in a set or not.
         IF l_source_line_set_id IS NULL THEN
  	   FND_MESSAGE.SET_NAME('WSH','WSH_DEL_TOL_EXCEEDED_REVIEW');
         ELSE
  	   FND_MESSAGE.SET_NAME('WSH','WSH_DEL_TOL_EXCEED_REVIEW_LS');
         END IF;
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
	 FND_MESSAGE.SET_TOKEN('ORDER_NUMBER',l_source_header_number);
	 FND_MESSAGE.SET_TOKEN('SOURCE_SYSTEM',l_source_system);
	 FND_MESSAGE.SET_TOKEN('ORDER_TYPE',l_source_header_type_name);
	 FND_MESSAGE.SET_TOKEN('LINE_NUM',ltrim( rtrim ( l_source_line_number )) );
	 FND_MESSAGE.SET_TOKEN('MAX_QTY',l_line_max_quantity);

       END IF;

       x_return_status := FND_API.G_RET_STS_ERROR;
-- Add_message is not needed because the caller Confirm_Delivery does this.
--       WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'TOLERANCE_EXCEEDED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:TOLERANCE_EXCEEDED');
END IF;
--
     WHEN others THEN
	   if c_total_line_quantities%ISOPEN THEN
	      close c_total_line_quantities ;
           end if ;
	   wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHECK_DELIVERY_FOR_TOLERANCE');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Check_Delivery_for_tolerances ;


FUNCTION Del_Assigned_To_Trip(
  p_delivery_id                IN   NUMBER,
  x_return_status              OUT NOCOPY   VARCHAR2
) RETURN VARCHAR2 IS

cursor check_assigned(c_delivery_id in number) is
select delivery_id
FROM   wsh_delivery_legs
WHERE  delivery_id = c_delivery_id
AND rownum = 1;

l_delivery_id  NUMBER;
l_assigned     VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DEL_ASSIGNED_TO_TRIP';
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  OPEN check_assigned(p_delivery_id);

  FETCH check_assigned INTO l_delivery_id;

  IF check_assigned%FOUND THEN

    l_assigned := 'Y';

  ELSE

    l_assigned := 'N';

  END IF;

  CLOSE check_assigned;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN  l_assigned;

  EXCEPTION
    WHEN OTHERS THEN
           IF check_assigned%ISOPEN THEN
             CLOSE check_assigned;
           END IF;
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.Del_Assigned_To_Trip');
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           return NULL;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Del_Assigned_To_Trip;


--Harmonization Project I
PROCEDURE Is_Action_Enabled(
                p_dlvy_rec_tab          IN      dlvy_rec_tab_type,
                p_action                IN      VARCHAR2,
                p_caller                IN      VARCHAR2,
                p_tripid                IN      NUMBER DEFAULT null,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_valid_ids             OUT NOCOPY      wsh_util_core.id_tab_type,
                x_error_ids             OUT NOCOPY      wsh_util_core.id_tab_type,
                x_valid_index_tab       OUT NOCOPY      wsh_util_core.id_tab_type
          ) IS

cursor  del_to_det_cur( p_delivery_id IN NUMBER ) is
select  distinct 'X'
from    wsh_delivery_details wdd,
        wsh_delivery_assignments_v wda
where   wda.delivery_id = p_delivery_id
and     wdd.delivery_detail_id = wda.delivery_detail_id
and     wdd.source_code = 'WSH'
and     wdd.container_flag = 'N';

cursor  valid_shpmnt_advice_cur(p_delivery_id IN NUMBER,
                                p_tp_id IN NUMBER
                              ) is
select  'X'
from    wsh_transactions_history
where   transaction_id = (
                        select  max(transaction_id)
                        from    wsh_transactions_history wth,
                                wsh_new_deliveries wnd
                        where   wth.entity_number = wnd.name
                        and     wth.trading_partner_id = p_tp_id
                        and     wnd.delivery_id = p_delivery_id
                        )
and     document_direction='I'
and     action_type = 'A';

cursor  det_stat_cur( p_delivery_id IN NUMBER) is
select  distinct 'X'
from    wsh_delivery_details wdd,
        wsh_delivery_assignments_v wda
where   wdd.source_code = 'WSH'
and     wdd.container_flag = 'N'
and     wdd.delivery_detail_id = wda.delivery_detail_id
and     wda.delivery_id = p_delivery_id;

CURSOR c_istripfirm(p_tripid IN NUMBER) IS
SELECT 'Y'
FROM wsh_trips wt
WHERE wt.trip_id=p_tripid
      AND wt.planned_flag='F';

CURSOR c_isvalidtptrip(p_delid IN NUMBER, p_tripid IN NUMBER) IS
SELECT 'Y'
FROM wsh_trips wt
WHERE wt.trip_id=p_tripid
      AND (nvl(wt.ignore_for_planning,'N') <> (select nvl(ignore_for_planning,'N') from wsh_new_deliveries where delivery_id=p_delid)
          );


--/== Workflow Changes
CURSOR c_get_cntrl_wf_details(p_delivery_id IN NUMBER) IS
SELECT delivery_scpod_wf_process,
       del_wf_close_attr
FROM WSH_NEW_DELIVERIES
WHERE delivery_id = p_delivery_id;

l_override_wf  VARCHAR2(1);
l_del_entity_ids WSH_UTIL_CORE.column_tab_type;
l_del_scpod_wf_process VARCHAR2(30);
l_close_flag   VARCHAR2(1);
l_purged_count NUMBER;
l_wf_rs        VARCHAR2(1);
e_scpod_wf_inprogress       EXCEPTION;
--==/

-- R12 MDC
CURSOR cur_get_delivery_type (p_delivery_id IN NUMBER) IS
SELECT delivery_type
FROM   wsh_new_deliveries
WHERE  delivery_id = p_delivery_id;
l_delivery_type   wsh_new_deliveries.delivery_type%type;

CURSOR cur_check_consol_delivery (p_delivery_id IN NUMBER) IS
select 1
from   wsh_delivery_legs pleg,
       wsh_delivery_legs cleg
where  pleg.delivery_leg_id = cleg.parent_delivery_leg_id
and    cleg.delivery_id = p_delivery_id;

l_dummy number;
--

l_dlvy_actions_tab	DeliveryActionsTabType;
-- OTM R12 - Bug#5399341
l_param_info WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;

l_organization_id       NUMBER;
l_planned_flag VARCHAR2(1);
l_status_code VARCHAR2(2);
l_wh_type VARCHAR2(30);
l_return_status VARCHAR2(1);
l_tpw_temp VARCHAR2(1);
l_valid_shpt_advc_tmp VARCHAR2(1);
l_atd_tpw_temp VARCHAR2(1);

l_org_type VARCHAR2(30);
l_cache_org_type VARCHAR2(30);
l_cache_org_id NUMBER;
l_non_wms_org_id NUMBER;

error_in_init_actions   EXCEPTION;
e_record_ineligible     EXCEPTION;
e_tp_record_ineligible     EXCEPTION;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'IS_ACTION_ENABLED';

--
l_dlvy_status_code     VARCHAR2(30);
l_shipping_control     VARCHAR2(30);
l_routing_response_id  NUMBER;
l_routing_request_flag VARCHAR2(30);
l_caller               VARCHAR2(50);
--l_planned_flag         VARCHAR2(10);
l_is_del_eligible  BOOLEAN;  --ADDED FOR BUG FIX 3562492

--OTM R12
l_gc3_is_installed              VARCHAR2(1);

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
    WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
    WSH_DEBUG_SV.log(l_module_name,'p_action',p_action);
 END IF;


  --OTM R12
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED; -- this is global variable

  IF l_gc3_is_installed IS NULL THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED; -- this is actual function
  END IF;
  --

 Init_Delivery_Actions_Tbl(
	p_action => p_action,
	x_delivery_actions_tab => l_dlvy_actions_tab,
	x_return_status => x_return_status);

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Init_Detail_Actions_Tbl x_return_status',x_return_status);
    WSH_DEBUG_SV.log(l_module_name,' Count of p_dlvy_rec_tab is',p_dlvy_rec_tab.count);
 END IF;

 IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
    raise error_in_init_actions;
 END IF;

 FOR j IN p_dlvy_rec_tab.FIRST..p_dlvy_rec_tab.LAST LOOP
   BEGIN

     -- R12 MDC
     -- Only PRINT-BOL and WT-VOL actions are allowed for
     -- consolidation delivery, other actions are not allwed.
     IF (p_action NOT IN ('PRINT-BOL', 'GENERATE-BOL', 'WT-VOL', 'UNASSIGN', 'SELECT-CARRIER'))
         OR (p_action = 'UNASSIGN' AND p_caller NOT like 'WMS%') THEN --{
        OPEN  cur_get_delivery_type(p_dlvy_rec_tab(j).delivery_id);
        FETCH cur_get_delivery_type into l_delivery_type;
        CLOSE cur_get_delivery_type;

        IF l_delivery_type = 'CONSOLIDATION' THEN
           raise e_record_ineligible;
        END IF;
     END IF; -- p_action NOT IN ('PRINT-BOL', 'WT-VOL')

     -- Following actions are not allowed when a delivery is
     -- assigned to a consolidation delivery.
     IF p_action IN ('AUTOCREATE-TRIP', 'PLAN', 'FIRM', 'INCLUDE_PLAN',
                     'SELECT-CARRIER', 'GET-FREIGHT-COSTS', 'CANCEL-SHIP-METHOD',
                     'IGNORE_PLAN') THEN

        OPEN cur_check_consol_delivery(p_dlvy_rec_tab(j).delivery_id);
	FETCH cur_check_consol_delivery INTO l_dummy;
	IF cur_check_consol_delivery%FOUND THEN
           raise e_record_ineligible;
	END IF;
	CLOSE cur_check_consol_delivery;
     END IF;
     --

     l_org_type := NULL;
     --
     IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name, 'Organization Id', p_dlvy_rec_tab(j).organization_id);
       wsh_debug_sv.log(l_module_name, 'Cached Organization Id', l_cache_org_id);
     END IF;
     --
     IF p_dlvy_rec_tab(j).organization_id = l_cache_org_id THEN
       l_org_type := l_cache_org_type;
     ELSE
       --
       IF l_debug_on THEN
	 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.GET_ORG_TYPE',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       l_org_type := wsh_util_validate.get_org_type(
                       p_organization_id => p_dlvy_rec_tab(j).organization_id,
                       p_delivery_id     => p_dlvy_rec_tab(j).delivery_id,
                       p_msg_display     => 'N',
                       x_return_status   => l_return_status );
       --
       IF l_debug_on THEN
	 wsh_debug_sv.log(l_module_name, 'Return status after wsh_util_validate.get_org_type', l_return_status);
	 wsh_debug_sv.log(l_module_name, 'l_org_type is: ', l_org_type);
       END IF;
       --
       IF l_return_status = wsh_util_core.g_ret_sts_unexp_error THEN
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = wsh_util_core.g_ret_sts_error THEN
         raise e_record_ineligible;
       END IF;
       --
       l_cache_org_id := p_dlvy_rec_tab(j).organization_id;
       l_cache_org_type := l_org_type;
       --
     END IF;
     -- OTM R12
     -- Bug 5399341: Get shipping params to figure if the org is OTM enabled.

     WSH_SHIPPING_PARAMS_PVT.Get(
                      p_organization_id => l_cache_org_id,
                      p_client_id       => p_dlvy_rec_tab(j).client_id, -- LSP PROJECT : Client defaults should be considered.
                      x_param_info      => l_param_info,
                      x_return_status   => x_return_status
                      );

     -- end of OTM R12
     -- This condition is added to enable the actions when the caller is
     -- WMS itself.
     IF (p_caller LIKE 'WMS%') THEN
       --
       IF instrb( l_org_type, 'WMS') > 0 THEN
         l_org_type := replace(l_org_type,'WMS');
       END IF;
       --
     END IF;
     --

     --
     IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name, 'l_org_type', l_org_type);
       wsh_debug_sv.log(l_module_name, 'l_dlvy_actions_tab.Count', l_dlvy_actions_tab.count);
     END IF;
     --
     --
     -- J-IB-NPARIKH-{
     --
     l_dlvy_status_code := p_dlvy_rec_tab(j).status_code;   -- J-IB-NPARIKH
     l_caller           := p_caller;
     l_planned_flag     := p_dlvy_rec_tab(j).planned_flag;
     --
     --
     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'l_dlvy_status_code', l_dlvy_status_code);
        wsh_debug_sv.log(l_module_name, 'l_caller', l_caller);
        wsh_debug_sv.log(l_module_name, 'l_planned_flag', l_planned_flag);
     END IF;
        --
        --
        -- Actions on inbound/drop-ship deliveries are allowed only if caller
        -- starts with  one of the following:
        --     - FTE
        --     - WSH_IB
        --     - WSH_PUB
        --     - WSH_TP_RELEASE
        -- For any other callers, set l_caller to WSH_FSTRX
        -- Since for caller, WSH_FSTRX, all actions are disabled
        -- on inbound/drop-ship deliveries
        --
        --
        IF  nvl(p_dlvy_rec_tab(j).shipment_direction,'O') NOT IN ('O','IO')  -- Inbound/Drop-ship
        THEN
        --{
            IF l_caller LIKE 'FTE%'
            OR l_caller LIKE 'WSH_PUB%'
            OR l_caller LIKE 'WSH_IB%'
            OR l_caller LIKE 'WSH_TP_RELEASE%'
            THEN
                NULL;
            ELSE
                l_caller := 'WSH_FSTRX';
            END IF;
        --}
        END IF;
     --
     --Bug 3458160
     IF p_action = 'INCLUDE_PLAN' THEN --{
         -- 5746444: skip this check for WSH lines if OTM is enabled
        IF l_gc3_is_installed = 'N' THEN
           open det_stat_cur(p_dlvy_rec_tab(j).delivery_id);
           fetch det_stat_cur into l_atd_tpw_temp;
           close det_stat_cur;

           IF l_atd_tpw_temp IS NOT NULL THEN
              raise e_record_ineligible;
           END IF;
         END IF;
     END IF; --}

     IF  p_action IN ('UNASSIGN','INCLUDE_PLAN') --WT-VOL-check
     AND l_dlvy_status_code IN ('IT','CL')
     AND NVL(p_dlvy_rec_tab(j).shipment_direction,'O') NOT IN ('O','IO')
     THEN
     --{
         --
         -- For in-transit/closed inbound deliveries (not O/IO),
         -- include plan action should not be allowed if
         --  - supplier is managing transportation
         -- OR
         --  - routing request was not received for all delivery lines
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit GET_SHIPPING_CONTROL',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         -- Check if transportation is managed by supplier
         --
         GET_SHIPPING_CONTROL
            (
                p_delivery_id           => p_dlvy_rec_tab(j).delivery_id,
                x_shipping_control      => l_shipping_control,
                x_routing_response_id   => l_routing_response_id,
                x_routing_request_flag  => l_routing_request_flag,
                x_return_status         => l_return_status
            );
         --
         --
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'l_return_status', l_return_status);
            wsh_debug_sv.log(l_module_name, 'l_shipping_control', l_shipping_control);
            wsh_debug_sv.log(l_module_name, 'l_routing_response_id', l_routing_response_id);
            wsh_debug_sv.log(l_module_name, 'l_routing_request_flag', l_routing_request_flag);
            --
         END IF;
         --
            --
            IF l_return_status = wsh_util_core.g_ret_sts_unexp_error THEN
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = wsh_util_core.g_ret_sts_error THEN
               raise e_record_ineligible;
            END IF;
            --
         --
         IF l_shipping_control     = 'SUPPLIER'
         OR l_routing_request_flag = 'N'
         THEN
            IF p_action = 'UNASSIGN'
            THEN
                l_planned_flag       := 'N';
            ELSIF p_action = 'INCLUDE_PLAN'
            THEN
                l_dlvy_status_code   := 'XX';
            ELSE
                l_dlvy_status_code   := 'OP';
            END IF;
         END IF;
     --}
     END IF;
     --


     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'l_dlvy_status_code-modified', l_dlvy_status_code);
        wsh_debug_sv.log(l_module_name, 'l_caller-modified', l_caller);
        wsh_debug_sv.log(l_module_name, 'l_planned_flag-modified', l_planned_flag);
     END IF;
     --
     -- J-IB-NPARIKH-}
     --
     -- Section a
     IF (l_dlvy_actions_tab.COUNT > 0 ) THEN
       For k in l_dlvy_actions_tab.FIRST..l_dlvy_actions_tab.LAST  LOOP

          --bug 3301211 : adding debug msgs
          IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name, 'Results from init_delivery_actions_tbl for index ', k);
             wsh_debug_sv.log(l_module_name, '---status_code', l_dlvy_actions_tab(k).status_code);
             wsh_debug_sv.log(l_module_name, '---planned_flag', l_dlvy_actions_tab(k).planned_flag);
             wsh_debug_sv.log(l_module_name, '---caller', l_dlvy_actions_tab(k).caller);
             wsh_debug_sv.log(l_module_name, '---org_type', l_dlvy_actions_tab(k).org_type);
             wsh_debug_sv.log(l_module_name, '---action_not_allowed', l_dlvy_actions_tab(k).action_not_allowed);
             wsh_debug_sv.log(l_module_name, '---shipment direction', l_dlvy_actions_tab(k).shipment_direction||' , '||p_dlvy_rec_tab(j).shipment_direction);
             --OTM R12
             wsh_debug_sv.log(l_module_name, '---ignore_for_planning', l_dlvy_actions_tab(k).ignore_for_planning);
             wsh_debug_sv.log(l_module_name, '---tms_interface_flag', l_dlvy_actions_tab(k).tms_interface_flag);
             -- OTM R12 Org Specific changes - 5399341
             wsh_debug_sv.log(l_module_name, '---otm_enabled', l_dlvy_actions_tab(k).otm_enabled);
             --
          END IF;

          IF(
          nvl(l_dlvy_actions_tab(k).status_code,l_dlvy_status_code) = l_dlvy_status_code     -- J-IB-NPARIKH
          --nvl(l_dlvy_actions_tab(k).status_code,p_dlvy_rec_tab(j).status_code) = p_dlvy_rec_tab(j).status_code
          AND nvl(l_dlvy_actions_tab(k).planned_flag,nvl(l_planned_flag,'N')) = nvl(l_planned_flag,'N')
          AND nvl(l_dlvy_actions_tab(k).caller,l_caller) = l_caller   -- J-IB-NPARIKH
          AND instrb( nvl(l_org_type, '!'), nvl(l_dlvy_actions_tab(k).org_type,nvl(l_org_type, '!')) ) > 0
	  AND l_dlvy_actions_tab(k).action_not_allowed = p_action
          /* J new condition to check shipment_direction jckwok */
          AND nvl(l_dlvy_actions_tab(k).shipment_direction, nvl(p_dlvy_rec_tab(j).shipment_direction, 'O'))= nvl(p_dlvy_rec_tab(j).shipment_direction, 'O')
          --OTM R12
          AND NVL(l_dlvy_actions_tab(k).ignore_for_planning, NVL(p_dlvy_rec_tab(j).ignore_for_planning, 'N')) =
              NVL(p_dlvy_rec_tab(j).ignore_for_planning, 'N')
          AND NVL(l_dlvy_actions_tab(k).tms_interface_flag, NVL(p_dlvy_rec_tab(j).tms_interface_flag, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)) =
              NVL(p_dlvy_rec_tab(j).tms_interface_flag, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)
          -- OTM R12 Org Specific changes - 5399341
          AND nvl(l_dlvy_actions_tab(k).otm_enabled, nvl(l_param_info.otm_enabled, 'N')) =nvl(l_param_info.otm_enabled, 'N')
          --
          )
          THEN
            IF l_dlvy_actions_tab(k).message_name IS NOT NULL THEN
              FND_MESSAGE.SET_NAME('WSH',l_dlvy_actions_tab(k).message_name);
              wsh_util_core.add_message(wsh_util_core.g_ret_sts_error);
	    END IF;
	      raise e_record_ineligible;
            exit;
          END IF;
       END LOOP;
     END IF;
     -- Section a
     -- Intialization of local variables for section b
     l_status_code := l_dlvy_status_code; --p_dlvy_rec_tab(j).status_code;
     --l_planned_flag := p_dlvy_rec_tab(j).planned_flag;

     -- Bug 5298643, action Pack is not allowed from delivery tab,
     -- However, this procedure can be called from delivery detail,
     -- while packing a line that is assigned to a delivery.

     IF (p_action IN ('PICK-RELEASE','AUTO-PACK','AUTO-PACK-MASTER','PACK'))
     THEN
       --BUG FIX 3562492
       IF (p_action = 'PICK-RELEASE') THEN
          l_is_del_eligible := Is_del_eligible_pick(
                                     p_delivery_id  => p_dlvy_rec_tab(j).delivery_id,
                                     x_return_status => l_return_status);
          IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Is_del_eligible_pick l_return_status',l_return_status);
          END IF;
       ELSE
          l_is_del_eligible := TRUE;
       END IF;

       IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_is_del_eligible ',l_is_del_eligible);
       END IF;

       IF l_is_del_eligible
       THEN
       --{
          l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
			(p_organization_id	=> p_dlvy_rec_tab(j).organization_id,
                         x_return_status  	=> l_return_status,
			 p_delivery_id     	=> p_dlvy_rec_tab(j).delivery_id,
                         p_msg_display    	=> 'N');

           IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type l_wh_type,l_return_status',l_wh_type||l_return_status);
           END IF;

           IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'TPW' ) THEN
              open del_to_det_cur(p_dlvy_rec_tab(j).delivery_id);
       	      Fetch del_to_det_cur into l_tpw_temp;
	      close del_to_det_cur;
  	      IF ( l_tpw_temp is null ) THEN
  	         raise e_record_ineligible;
	      ELSE
 	         x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
                 x_valid_index_tab(j) := j;
	      END IF;
	   ELSE
	      x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
              x_valid_index_tab(j) := j;
	   END IF;
        --}
       ELSE
         raise e_record_ineligible;
       END IF;
       --
     ELSIF ( p_action ='GEN-LOAD-SEQ' ) THEN
       IF ( l_status_code IN ('SR', 'SC') AND l_planned_flag IN ('Y','F') ) THEN
         l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
			(p_organization_id	=> p_dlvy_rec_tab(j).organization_id,
                         x_return_status  	=> l_return_status,
			 p_delivery_id     	=> p_dlvy_rec_tab(j).delivery_id,
                         p_msg_display    	=> 'N');

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type l_wh_type,l_return_status',l_wh_type||l_return_status);
         END IF;

	 IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'TPW' ) THEN
	   raise e_record_ineligible;
	 ELSE
	   x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
           x_valid_index_tab(j) := j;
	 END IF;
       ELSE
	 x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
         x_valid_index_tab(j) := j;
       END IF;

     ELSIF ( p_action = 'RE-OPEN' ) THEN
       IF ( l_status_code = 'CO' ) THEN
	 open del_to_det_cur(p_dlvy_rec_tab(j).delivery_id);
	 Fetch del_to_det_cur into l_tpw_temp;
	 close del_to_det_cur;

	 IF ( l_tpw_temp is null ) THEN
	   l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
			(p_organization_id	=> p_dlvy_rec_tab(j).organization_id,
                         x_return_status  	=> l_return_status,
			 p_delivery_id     	=> p_dlvy_rec_tab(j).delivery_id,
                         p_msg_display    	=> 'N');

           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type l_wh_type,l_return_status',l_wh_type|| l_return_status);
           END IF;

           IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'CMS' ) THEN
	     raise e_record_ineligible;
           ELSE
	     x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
             x_valid_index_tab(j) := j;
           END IF;

	 ELSE
	   raise e_record_ineligible;
	 END IF; -- IF ( l_tpw_temp is null )
       ELSE
         l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
     			(p_organization_id	=> p_dlvy_rec_tab(j).organization_id,
                         x_return_status  	=> l_return_status,
			 p_delivery_id     	=> p_dlvy_rec_tab(j).delivery_id,
                         p_msg_display    	=> 'N');

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type l_wh_type,l_return_status',l_wh_type||l_return_status);
         END IF;

         IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = 'CMS' ) THEN
	   raise e_record_ineligible;
         ELSE
	   x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
           x_valid_index_tab(j) := j;
         END IF;
       END IF; --IF ( l_status_code = 'CO' )

     ELSIF ( p_action ='CONFIRM' ) THEN
       l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type (
                      p_organization_id	=> p_dlvy_rec_tab(j).organization_id,
                      x_return_status   => l_return_status,
		      p_delivery_id     => p_dlvy_rec_tab(j).delivery_id,
                      p_msg_display     => 'N');

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type l_wh_type,l_return_status',l_wh_type||l_return_status);
       END IF;

       IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('TPW','CMS') ) THEN
	 open del_to_det_cur(p_dlvy_rec_tab(j).delivery_id);
	 Fetch del_to_det_cur into l_tpw_temp;
	 close del_to_det_cur;

	 IF ( l_tpw_temp IS NULL ) THEN
	   IF ( l_status_code = 'OP' ) THEN
	     open valid_shpmnt_advice_cur(p_dlvy_rec_tab(j).delivery_id, l_organization_id);
	     fetch valid_shpmnt_advice_cur into l_valid_shpt_advc_tmp;
	     close valid_shpmnt_advice_cur;
	     IF ( l_valid_shpt_advc_tmp IS NOT NULL ) THEN
	       x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
               x_valid_index_tab(j) := j;
	     ELSE
	       raise e_record_ineligible;
             END IF;
	   ELSE
	     x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
             x_valid_index_tab(j) := j;
	   END IF; -- IF ( l_status_code = 'OP' )
	 ELSE
	   x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
           x_valid_index_tab(j) := j;
	 END IF; -- IF ( l_tpw_temp IS NULL )
       ELSE
 	 x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
         x_valid_index_tab(j) := j;
       END IF; --IF ( nvl(l_wh_type,

     ELSIF (p_action IN ('OUTBOUND-DOCUMENT','TRANSACTION-HISTORY-UI') ) THEN

       --R12.1.1 STANDALONE PROJECT
       IF ( WMS_DEPLOY.wms_deployment_mode = 'D'
          OR (p_dlvy_rec_tab(j).client_id IS NOT NULL AND WMS_DEPLOY.wms_deployment_mode = 'L')) THEN
       --
       --R12.1.1 STANDALONE PROJECT
       x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
       x_valid_index_tab(j) := j;
       ELSE
       l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
		      (p_organization_id	=> p_dlvy_rec_tab(j).organization_id,
                       x_return_status   	=> l_return_status,
		       p_delivery_id     	=>  p_dlvy_rec_tab(j).delivery_id);

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type l_wh_type,l_return_status',l_wh_type||l_return_status);
       END IF;

       IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR ) THEN
	 open det_stat_cur(p_dlvy_rec_tab(j).delivery_id);
	 fetch det_stat_cur into l_atd_tpw_temp;
	 close det_stat_cur;

	 IF ( l_atd_tpw_temp IS NULL ) THEN
	   raise e_record_ineligible;
	 ELSE
	   x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
           x_valid_index_tab(j) := j;
	 END IF;
       ELSIF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('CMS','TPW') ) THEN
	 IF ( l_status_code = 'OP' ) THEN
	   open valid_shpmnt_advice_cur(p_dlvy_rec_tab(j).delivery_id, l_organization_id);
	   fetch valid_shpmnt_advice_cur into l_valid_shpt_advc_tmp;
	   close valid_shpmnt_advice_cur;

	   IF ( l_valid_shpt_advc_tmp IS NULL ) THEN
	     x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
             x_valid_index_tab(j) := j;
	   ELSE
	     raise e_record_ineligible;
	   END IF;
	 ELSE
           x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
           x_valid_index_tab(j) := j;
	 END IF;
        ELSE
	 raise e_record_ineligible;
         END IF; -- IF ( nvl(l_wh_type

       END IF ;
       --
     ELSIF ( p_action IN ('AUTOCREATE-TRIP','ASSIGN-TRIP')) THEN
       --tp_is_installed check not reqd as 'Firm' action is going to be available for wsh users as well
       IF (p_action='ASSIGN-TRIP') THEN
         IF (l_planned_flag='F') THEN --bug 3384112
            raise e_record_ineligible;
         END IF;
         FOR cur IN c_istripfirm(p_tripid) LOOP
            raise e_record_ineligible;
         END LOOP;
         FOR cur IN c_isvalidtptrip(p_dlvy_rec_tab(j).delivery_id, p_tripid) LOOP
            raise e_tp_record_ineligible;
         END LOOP;
       END IF;
       IF (p_dlvy_rec_tab(j).status_code = 'SA' )
       OR NVL(p_dlvy_rec_tab(j).shipment_direction,'O') NOT IN ('O','IO')     -- J-IB-NPARIKH
       THEN
	 x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
         x_valid_index_tab(j) := j;
       ELSE
	 l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
			(p_organization_id	=> p_dlvy_rec_tab(j).organization_id,
                         x_return_status   	=> l_return_status,
			 p_delivery_id     	=> p_dlvy_rec_tab(j).delivery_id,
                         p_msg_display     	=> 'N');

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type l_wh_type,l_return_status',l_wh_type||l_return_status);
         END IF;

         IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) in ( 'CMS','TPW') )

         THEN
	   open del_to_det_cur(p_dlvy_rec_tab(j).delivery_id);
	   fetch del_to_det_cur into l_tpw_temp;
	   close del_to_det_cur;
	   IF ( l_tpw_temp IS NULL ) THEN
	     raise e_record_ineligible;
	   ELSE
	     x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
             x_valid_index_tab(j) := j;
	   END IF;
         ELSE
	   x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
           x_valid_index_tab(j) := j;
	 END IF;  -- IF ( nvl(l_wh_type
       END IF; -- IF (p_dlvy_rec_tab .status_code = 'SA' )

     --lines can't be unassigned from firm delivery.
     ELSIF ( p_action IN ('UNASSIGN', 'UNASSIGN-TRIP')) THEN --bug 3384112
       --tp_is_installed check not reqd as 'Firm' action is going to be available for wsh users as well
       IF (l_planned_flag='F') THEN
            raise e_record_ineligible;
       ELSE
	   x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
           x_valid_index_tab(j) := j;
       END IF;
     ELSIF ( p_action IN ('GENERATE-BOL','PRINT-BOL'))
     THEN
       open det_stat_cur(p_dlvy_rec_tab(j).delivery_id);
       Fetch det_stat_cur into l_atd_tpw_temp;
       close det_stat_cur;
       IF ( l_atd_tpw_temp is not null ) THEN
	 x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
         x_valid_index_tab(j) := j;
       ELSE
         l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
			(p_organization_id	=> p_dlvy_rec_tab(j).organization_id,
                         x_return_status       	=> l_return_status,
			 p_delivery_id		=> p_dlvy_rec_tab(j).delivery_id,
                         p_msg_display     	=> 'N');

         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type l_wh_type,l_return_status',l_wh_type||l_return_status);
         END IF;

	 IF ( nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('TPW','CMS') ) THEN
	   raise e_record_ineligible;
	 ELSE
	   x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
           x_valid_index_tab(j) := j;
	 END IF;
       END IF; -- IF ( l_atd_tpw_temp
     --/== Workflow Changes
     ELSIF (p_action IN ('CLOSE')) THEN
    	 l_override_wf:= fnd_profile.value('WSH_OVERRIDE_SCPOD_WF');
	 IF (nvl(l_override_wf,'N') = 'N') THEN
	     OPEN c_get_cntrl_wf_details(p_dlvy_rec_tab(j).delivery_id);
	     FETCH c_get_cntrl_wf_details into l_del_scpod_wf_process,l_close_flag;
	     CLOSE c_get_cntrl_wf_details;
	     IF (l_del_scpod_wf_process is not null and l_close_flag = 'I') THEN
		 raise e_scpod_wf_inprogress;
	     END IF;
	 END IF;
         x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
         x_valid_index_tab(j) := j;      -- Workflow Changes ==/
     ELSE
       x_valid_ids(x_valid_ids.COUNT + 1) := p_dlvy_rec_tab(j).delivery_id;
       x_valid_index_tab(j) := j;
     END IF; -- IF ( p_action IN ('LAUNCH_PICK_RELEASE'
   EXCEPTION
     WHEN e_record_ineligible THEN
       x_error_ids(x_error_ids.count +1) := p_dlvy_rec_tab(j).delivery_id;
       IF p_caller = 'WSH_PUB' or p_caller like 'FTE%' OR
          p_caller = 'WSH_TRCON' THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_ACTION_INELIGIBLE');
          FND_MESSAGE.Set_Token('DEL_NAME',wsh_new_deliveries_pvt.get_name(x_error_ids(x_error_ids.count)));
          FND_MESSAGE.Set_Token('ACTION',wsh_util_core.get_action_meaning('DLVY',p_action));
          wsh_util_core.add_message('E',l_module_name);
       END IF;
     WHEN e_tp_record_ineligible THEN
       x_error_ids(x_error_ids.count +1) := p_dlvy_rec_tab(j).delivery_id;
       IF p_caller = 'WSH_PUB' or p_caller like 'FTE%' OR
          p_caller = 'WSH_TRCON' THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSIGN_FIRMTRIP_ERROR');
          FND_MESSAGE.Set_Token('DEL_NAME',wsh_new_deliveries_pvt.get_name(x_error_ids(x_error_ids.count)));
          FND_MESSAGE.Set_Token('TRIP_NAME',wsh_trips_pvt.get_name(p_tripid));
          wsh_util_core.add_message('E',l_module_name);
       END IF;
     WHEN e_scpod_wf_inprogress THEN     --/== Workflow Changes
       x_error_ids(x_error_ids.count +1) := p_dlvy_rec_tab(j).delivery_id;
       IF p_caller = 'WSH_PUB' or p_caller like 'FTE%' OR
          p_caller = 'WSH_TRCON' THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_WF_DEL_ACTION_INELIGIBLE');
          FND_MESSAGE.Set_Token('DEL_NAME',wsh_new_deliveries_pvt.get_name(x_error_ids(x_error_ids.count)));
          FND_MESSAGE.Set_Token('ACTION',wsh_util_core.get_action_meaning('DLVY',p_action));
          wsh_util_core.add_message('E',l_module_name);    --==/
       END IF;

   END;
 END LOOP; -- For j IN p_dlvy_rec_tab.FIRST


 IF (x_valid_ids.COUNT = 0 ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF NOT (l_caller LIKE 'FTE%' OR l_caller = 'WSH_PUB') THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_ACTION_ENABLED');
      wsh_util_core.add_message(x_return_status,l_module_name);
    END IF;
    --
 ELSIF (x_valid_ids.COUNT = p_dlvy_rec_tab.COUNT) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 ELSIF (x_valid_ids.COUNT < p_dlvy_rec_tab.COUNT ) THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    --
    IF NOT (l_caller LIKE 'FTE%' OR l_caller = 'WSH_PUB') THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_ACTION_ENABLED_WARN');
      wsh_util_core.add_message(x_return_status,l_module_name);
    END IF;
    --
 ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF NOT (l_caller LIKE 'FTE%' OR l_caller = 'WSH_PUB') THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_ACTION_ENABLED');
      wsh_util_core.add_message(x_return_status,l_module_name);
    END IF;
    --
 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
  WHEN error_in_init_actions THEN
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'error_in_init_actions exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:error_in_init_actions');
   END IF;

  WHEN OTHERS THEN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                          SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
END Is_Action_Enabled;

/*
   Procedure populate_external_edf is called from
   eliminate_displayonly_fields to populate the external value
   for a given internal field
*/

PROCEDURE populate_external_edf(
  p_internal        IN   NUMBER
, p_external        IN   VARCHAR2
, x_internal        IN OUT  NOCOPY NUMBER
, x_external        IN OUT  NOCOPY VARCHAR2
)
IS
BEGIN

   IF p_internal <> FND_API.G_MISS_NUM OR p_internal IS NULL THEN
      x_internal := p_internal;
      IF p_internal IS NULL THEN
         x_external := NULL;
      ELSE
         x_external := p_external;
      END IF;
   ELSIF p_external <> FND_API.G_MISS_CHAR OR p_external IS NULL THEN
      x_external := p_external;
      IF x_external IS NULL THEN
         x_internal := NULL;
      ELSE
         x_internal := p_internal;
      END IF;
   END IF;

END populate_external_edf;


/*
   Procedure populate_external_edf is called from
   eliminate_displayonly_fields to populate the external value
   for a given internal field
*/

PROCEDURE populate_external_edf(
  p_internal        IN   VARCHAR2
, p_external        IN   VARCHAR2
, x_internal        IN OUT  NOCOPY VARCHAR2
, x_external        IN OUT  NOCOPY VARCHAR2
)
IS
BEGIN

   IF p_internal <> FND_API.G_MISS_CHAR OR p_internal IS NULL THEN
      x_internal := p_internal;
      IF p_internal IS NULL THEN
         x_external := NULL;
      ELSE
         x_external := p_external;
      END IF;
   ELSIF p_external <> FND_API.G_MISS_CHAR OR p_external IS NULL THEN
      x_external := p_external;
      IF x_external IS NULL THEN
         x_internal := NULL;
      ELSE
         x_internal := p_internal;
      END IF;
   END IF;

END populate_external_edf;


PROCEDURE eliminate_displayonly_fields (
  p_delivery_rec   IN WSH_NEW_DELIVERIES_PVT.Delivery_rec_type
--tkt
, p_in_rec		  IN  WSH_DELIVERIES_GRP.Del_In_Rec_Type
, x_delivery_rec   IN OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_rec_type
)
IS
BEGIN

    /*
       Enable the x_delivery_detail_rec, with the columns that are not
       permanently  disabled.
    */
    --

    IF p_delivery_rec.NAME <> FND_API.G_MISS_CHAR
      OR p_delivery_rec.NAME IS NULL THEN
      x_delivery_rec.NAME :=
                          p_delivery_rec.NAME;
    END IF;

    populate_external_edf(p_delivery_rec.ORGANIZATION_ID,
                          p_delivery_rec.ORGANIZATION_CODE,
                          x_delivery_rec.ORGANIZATION_ID,
                          x_delivery_rec.ORGANIZATION_CODE );

    populate_external_edf(p_delivery_rec.INITIAL_PICKUP_LOCATION_ID,
                          p_delivery_rec.INITIAL_PICKUP_LOCATION_CODE,
                          x_delivery_rec.INITIAL_PICKUP_LOCATION_ID,
                          x_delivery_rec.INITIAL_PICKUP_LOCATION_CODE );

    populate_external_edf(p_delivery_rec.INTMED_SHIP_TO_LOCATION_ID,
                          p_delivery_rec.INTMED_SHIP_TO_LOCATION_CODE,
                          x_delivery_rec.INTMED_SHIP_TO_LOCATION_ID,
                          x_delivery_rec.INTMED_SHIP_TO_LOCATION_CODE );

    populate_external_edf(p_delivery_rec.POOLED_SHIP_TO_LOCATION_ID,
                          p_delivery_rec.POOLED_SHIP_TO_LOCATION_CODE,
                          x_delivery_rec.POOLED_SHIP_TO_LOCATION_ID,
                          x_delivery_rec.POOLED_SHIP_TO_LOCATION_CODE );

    IF p_delivery_rec.INITIAL_PICKUP_DATE <> FND_API.G_MISS_DATE
       OR p_delivery_rec.INITIAL_PICKUP_DATE IS NULL THEN
      x_delivery_rec.INITIAL_PICKUP_DATE :=
                          p_delivery_rec.INITIAL_PICKUP_DATE;
    END IF;

    --Bug 3458160
    IF p_in_rec.caller = 'WSH_TPW_INBOUND' THEN
       IF p_delivery_rec.SHIPMENT_DIRECTION <> FND_API.G_MISS_CHAR THEN
         x_delivery_rec.SHIPMENT_DIRECTION :=
                             p_delivery_rec.SHIPMENT_DIRECTION;
       END IF;
       IF p_delivery_rec.IGNORE_FOR_PLANNING <> FND_API.G_MISS_CHAR THEN
         x_delivery_rec.IGNORE_FOR_PLANNING :=
                             p_delivery_rec.IGNORE_FOR_PLANNING;
       END IF;
    ELSIF p_in_rec.caller = 'WSH_INBOUND' THEN
       IF p_delivery_rec.DELIVERED_DATE <> FND_API.G_MISS_DATE
            OR p_delivery_rec.DELIVERED_DATE IS NULL THEN
         x_delivery_rec.DELIVERED_DATE :=
                             p_delivery_rec.DELIVERED_DATE;
       END IF;
    END IF;


    populate_external_edf(p_delivery_rec.ULTIMATE_DROPOFF_LOCATION_ID,
                          p_delivery_rec.ULTIMATE_DROPOFF_LOCATION_CODE,
                          x_delivery_rec.ULTIMATE_DROPOFF_LOCATION_ID,
                          x_delivery_rec.ULTIMATE_DROPOFF_LOCATION_CODE );

    IF p_delivery_rec.NUMBER_OF_LPN <> FND_API.G_MISS_NUM
       OR p_delivery_rec.NUMBER_OF_LPN IS NULL THEN
      x_delivery_rec.NUMBER_OF_LPN :=
                          p_delivery_rec.NUMBER_OF_LPN;
    END IF;
    IF p_delivery_rec.WAYBILL <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.WAYBILL IS NULL THEN
      x_delivery_rec.WAYBILL :=
                          p_delivery_rec.WAYBILL;
    END IF;

    populate_external_edf(p_delivery_rec.CUSTOMER_ID,
                          p_delivery_rec.CUSTOMER_NUMBER,
                          x_delivery_rec.CUSTOMER_ID,
                          x_delivery_rec.CUSTOMER_NUMBER );
    --Modified R12.1.1 LSP PROJECT (anvarshn)
    /*IF p_delivery_rec.client_id <> FND_API.G_MISS_NUM
       OR p_delivery_rec.client_id IS NULL THEN
      x_delivery_rec.client_id :=
                          p_delivery_rec.client_id;
    END IF;*/
--Modified R12.1.1 LSP PROJECT (anvarshn)
   -- LSP PROJECT..
   populate_external_edf(p_delivery_rec.client_ID,
                          p_delivery_rec.client_CODE,
                          x_delivery_rec.client_id,
                          x_delivery_rec.client_CODE);

    populate_external_edf(p_delivery_rec.FREIGHT_TERMS_CODE,
                          p_delivery_rec.FREIGHT_TERMS_NAME,
                          x_delivery_rec.FREIGHT_TERMS_CODE,
                          x_delivery_rec.FREIGHT_TERMS_NAME );

    populate_external_edf(p_delivery_rec.SHIP_METHOD_CODE,
                          p_delivery_rec.SHIP_METHOD_NAME,
                          x_delivery_rec.SHIP_METHOD_CODE,
                          x_delivery_rec.SHIP_METHOD_NAME );

    populate_external_edf(p_delivery_rec.CARRIER_ID,
                          p_delivery_rec.CARRIER_CODE,
                          x_delivery_rec.CARRIER_ID,
                          x_delivery_rec.CARRIER_CODE );

    IF p_delivery_rec.SERVICE_LEVEL <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.SERVICE_LEVEL IS NULL THEN
      x_delivery_rec.SERVICE_LEVEL :=
                          p_delivery_rec.SERVICE_LEVEL;
    END IF;
    IF p_delivery_rec.MODE_OF_TRANSPORT <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.MODE_OF_TRANSPORT IS NULL THEN
      x_delivery_rec.MODE_OF_TRANSPORT :=
                          p_delivery_rec.MODE_OF_TRANSPORT;
    END IF;

    populate_external_edf(p_delivery_rec.FOB_CODE,
                          p_delivery_rec.FOB_NAME,
                          x_delivery_rec.FOB_CODE,
                          x_delivery_rec.FOB_NAME );

    populate_external_edf(p_delivery_rec.FOB_LOCATION_ID,
                          p_delivery_rec.FOB_LOCATION_CODE,
                          x_delivery_rec.FOB_LOCATION_ID,
                          x_delivery_rec.FOB_LOCATION_CODE );

    IF p_delivery_rec.GROSS_WEIGHT <> FND_API.G_MISS_NUM
       OR p_delivery_rec.GROSS_WEIGHT IS NULL THEN
      x_delivery_rec.GROSS_WEIGHT :=
                          p_delivery_rec.GROSS_WEIGHT;
    END IF;
    IF p_delivery_rec.NET_WEIGHT <> FND_API.G_MISS_NUM
       OR p_delivery_rec.NET_WEIGHT IS NULL THEN
      x_delivery_rec.NET_WEIGHT :=
                          p_delivery_rec.NET_WEIGHT;
    END IF;

    populate_external_edf(p_delivery_rec.WEIGHT_UOM_CODE,
                          p_delivery_rec.WEIGHT_UOM_DESC,
                          x_delivery_rec.WEIGHT_UOM_CODE,
                          x_delivery_rec.WEIGHT_UOM_DESC );

    IF p_delivery_rec.VOLUME <> FND_API.G_MISS_NUM
       OR p_delivery_rec.VOLUME IS NULL THEN
      x_delivery_rec.VOLUME :=
                          p_delivery_rec.VOLUME;
    END IF;

    populate_external_edf(p_delivery_rec.VOLUME_UOM_CODE,
                          p_delivery_rec.VOLUME_UOM_DESC,
                          x_delivery_rec.VOLUME_UOM_CODE,
                          x_delivery_rec.VOLUME_UOM_DESC );

    -- bug 3666967 - need wv_frozen_flag when creating new delivery through public api.
    IF p_delivery_rec.wv_frozen_flag <> FND_API.G_MISS_CHAR THEN
      x_delivery_rec.wv_frozen_flag :=
                          p_delivery_rec.wv_frozen_flag;
    END IF;
    -- end bug 3666967

    -- Bug#4539613 : Consider the Prorate weight flag while populating output record.
    IF p_delivery_rec.prorate_wt_flag <> FND_API.G_MISS_CHAR
       OR  p_delivery_rec.prorate_wt_flag  IS NULL THEN
      x_delivery_rec.prorate_wt_flag :=
                          p_delivery_rec.prorate_wt_flag;
    END IF;

    IF p_delivery_rec.LOADING_SEQUENCE <> FND_API.G_MISS_NUM
       OR p_delivery_rec.LOADING_SEQUENCE IS NULL THEN
      x_delivery_rec.LOADING_SEQUENCE :=
                          p_delivery_rec.LOADING_SEQUENCE;
    END IF;

    populate_external_edf(p_delivery_rec.LOADING_ORDER_FLAG,
                          p_delivery_rec.LOADING_ORDER_DESC,
                          x_delivery_rec.LOADING_ORDER_FLAG,
                          x_delivery_rec.LOADING_ORDER_DESC );

    IF p_delivery_rec.ADDITIONAL_SHIPMENT_INFO <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.ADDITIONAL_SHIPMENT_INFO IS NULL THEN
      x_delivery_rec.ADDITIONAL_SHIPMENT_INFO :=
                          p_delivery_rec.ADDITIONAL_SHIPMENT_INFO;
    END IF;
    IF p_delivery_rec.PORT_OF_LOADING <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.PORT_OF_LOADING IS NULL THEN
      x_delivery_rec.PORT_OF_LOADING :=
                          p_delivery_rec.PORT_OF_LOADING;
    END IF;
    IF p_delivery_rec.ROUTED_EXPORT_TXN <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.ROUTED_EXPORT_TXN IS NULL THEN
      x_delivery_rec.ROUTED_EXPORT_TXN :=
                          p_delivery_rec.ROUTED_EXPORT_TXN;
    END IF;
    IF p_delivery_rec.FTZ_NUMBER <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.FTZ_NUMBER IS NULL THEN
      x_delivery_rec.FTZ_NUMBER :=
                          p_delivery_rec.FTZ_NUMBER;
    END IF;
    IF p_delivery_rec.ENTRY_NUMBER <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.ENTRY_NUMBER IS NULL THEN
      x_delivery_rec.ENTRY_NUMBER :=
                          p_delivery_rec.ENTRY_NUMBER;
    END IF;
    IF p_delivery_rec.IN_BOND_CODE <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.IN_BOND_CODE IS NULL THEN
      x_delivery_rec.IN_BOND_CODE :=
                          p_delivery_rec.IN_BOND_CODE;
    END IF;
    IF p_delivery_rec.SHIPPING_MARKS <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.SHIPPING_MARKS IS NULL THEN
      x_delivery_rec.SHIPPING_MARKS :=
                          p_delivery_rec.SHIPPING_MARKS;
    END IF;
    IF p_delivery_rec.PROBLEM_CONTACT_REFERENCE <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.PROBLEM_CONTACT_REFERENCE IS NULL THEN
      x_delivery_rec.PROBLEM_CONTACT_REFERENCE :=
                          p_delivery_rec.PROBLEM_CONTACT_REFERENCE;
    END IF;
    IF p_delivery_rec.COD_AMOUNT <> FND_API.G_MISS_NUM
       OR p_delivery_rec.COD_AMOUNT IS NULL THEN
      x_delivery_rec.COD_AMOUNT :=
                          p_delivery_rec.COD_AMOUNT;
    END IF;
    IF p_delivery_rec.COD_CURRENCY_CODE <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.COD_CURRENCY_CODE IS NULL THEN
      x_delivery_rec.COD_CURRENCY_CODE :=
                          p_delivery_rec.COD_CURRENCY_CODE;
    END IF;
    IF p_delivery_rec.COD_REMIT_TO <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.COD_REMIT_TO IS NULL THEN
      x_delivery_rec.COD_REMIT_TO :=
                          p_delivery_rec.COD_REMIT_TO;
    END IF;
    IF p_delivery_rec.COD_CHARGE_PAID_BY <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.COD_CHARGE_PAID_BY IS NULL THEN
      x_delivery_rec.COD_CHARGE_PAID_BY :=
                          p_delivery_rec.COD_CHARGE_PAID_BY;
    END IF;
    IF p_delivery_rec.AUTO_SC_EXCLUDE_FLAG <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.AUTO_SC_EXCLUDE_FLAG IS NULL THEN
      x_delivery_rec.AUTO_SC_EXCLUDE_FLAG :=
                          p_delivery_rec.AUTO_SC_EXCLUDE_FLAG;
    END IF;
    IF p_delivery_rec.AUTO_AP_EXCLUDE_FLAG <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.AUTO_AP_EXCLUDE_FLAG IS NULL THEN
      x_delivery_rec.AUTO_AP_EXCLUDE_FLAG :=
                          p_delivery_rec.AUTO_AP_EXCLUDE_FLAG;
    END IF;
    IF p_delivery_rec.attribute1 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute1 IS NULL THEN
      x_delivery_rec.attribute1 :=
                          p_delivery_rec.attribute1;
    END IF;
    IF p_delivery_rec.attribute2 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute2 IS NULL THEN
      x_delivery_rec.attribute2 :=
                          p_delivery_rec.attribute2;
    END IF;
    IF p_delivery_rec.attribute3 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute3 IS NULL THEN
      x_delivery_rec.attribute3 :=
                          p_delivery_rec.attribute3;
    END IF;
    IF p_delivery_rec.attribute4 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute4 IS NULL THEN
      x_delivery_rec.attribute4 :=
                          p_delivery_rec.attribute4;
    END IF;
    IF p_delivery_rec.attribute5 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute5 IS NULL THEN
      x_delivery_rec.attribute5 :=
                          p_delivery_rec.attribute5;
    END IF;
    IF p_delivery_rec.attribute6 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute6 IS NULL THEN
      x_delivery_rec.attribute6 :=
                          p_delivery_rec.attribute6;
    END IF;
    IF p_delivery_rec.attribute7 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute7 IS NULL THEN
      x_delivery_rec.attribute7 :=
                          p_delivery_rec.attribute7;
    END IF;
    IF p_delivery_rec.attribute8 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute8 IS NULL THEN
      x_delivery_rec.attribute8 :=
                          p_delivery_rec.attribute8;
    END IF;
    IF p_delivery_rec.attribute9 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute9 IS NULL THEN
      x_delivery_rec.attribute9 :=
                          p_delivery_rec.attribute9;
    END IF;
    IF p_delivery_rec.attribute10 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute10 IS NULL THEN
      x_delivery_rec.attribute10 :=
                          p_delivery_rec.attribute10;
    END IF;
    IF p_delivery_rec.attribute11 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute11 IS NULL THEN
      x_delivery_rec.attribute11 :=
                          p_delivery_rec.attribute11;
    END IF;
    IF p_delivery_rec.attribute12 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute12 IS NULL THEN
      x_delivery_rec.attribute12 :=
                          p_delivery_rec.attribute12;
    END IF;
    IF p_delivery_rec.attribute13 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute13 IS NULL THEN
      x_delivery_rec.attribute13 :=
                          p_delivery_rec.attribute13;
    END IF;
    IF p_delivery_rec.attribute14 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute14 IS NULL THEN
      x_delivery_rec.attribute14 :=
                          p_delivery_rec.attribute14;
    END IF;
    IF p_delivery_rec.attribute15 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.attribute15 IS NULL THEN
      x_delivery_rec.attribute15 :=
                          p_delivery_rec.attribute15;
    END IF;
    IF p_delivery_rec.ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.ATTRIBUTE_CATEGORY IS NULL THEN
      x_delivery_rec.ATTRIBUTE_CATEGORY :=
                          p_delivery_rec.ATTRIBUTE_CATEGORY;
    END IF;
    IF p_delivery_rec.tp_attribute1 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute1 IS NULL THEN
      x_delivery_rec.tp_attribute1 :=
                          p_delivery_rec.tp_attribute1;
    END IF;
    IF p_delivery_rec.tp_attribute2 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute2 IS NULL THEN
      x_delivery_rec.tp_attribute2 :=
                          p_delivery_rec.tp_attribute2;
    END IF;
    IF p_delivery_rec.tp_attribute3 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute3 IS NULL THEN
      x_delivery_rec.tp_attribute3 :=
                          p_delivery_rec.tp_attribute3;
    END IF;
    IF p_delivery_rec.tp_attribute4 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute4 IS NULL THEN
      x_delivery_rec.tp_attribute4 :=
                          p_delivery_rec.tp_attribute4;
    END IF;
    IF p_delivery_rec.tp_attribute5 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute5 IS NULL THEN
      x_delivery_rec.tp_attribute5 :=
                          p_delivery_rec.tp_attribute5;
    END IF;
    IF p_delivery_rec.tp_attribute6 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute6 IS NULL THEN
      x_delivery_rec.tp_attribute6 :=
                          p_delivery_rec.tp_attribute6;
    END IF;
    IF p_delivery_rec.tp_attribute7 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute7 IS NULL THEN
      x_delivery_rec.tp_attribute7 :=
                          p_delivery_rec.tp_attribute7;
    END IF;
    IF p_delivery_rec.tp_attribute8 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute8 IS NULL THEN
      x_delivery_rec.tp_attribute8 :=
                          p_delivery_rec.tp_attribute8;
    END IF;
    IF p_delivery_rec.tp_attribute9 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute9 IS NULL THEN
      x_delivery_rec.tp_attribute9 :=
                          p_delivery_rec.tp_attribute9;
    END IF;
    IF p_delivery_rec.tp_attribute10 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute10 IS NULL THEN
      x_delivery_rec.tp_attribute10 :=
                          p_delivery_rec.tp_attribute10;
    END IF;
    IF p_delivery_rec.tp_attribute11 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute11 IS NULL THEN
      x_delivery_rec.tp_attribute11 :=
                          p_delivery_rec.tp_attribute11;
    END IF;
    IF p_delivery_rec.tp_attribute12 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute12 IS NULL THEN
      x_delivery_rec.tp_attribute12 :=
                          p_delivery_rec.tp_attribute12;
    END IF;
    IF p_delivery_rec.tp_attribute13 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute13 IS NULL THEN
      x_delivery_rec.tp_attribute13 :=
                          p_delivery_rec.tp_attribute13;
    END IF;
    IF p_delivery_rec.tp_attribute14 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute14 IS NULL THEN
      x_delivery_rec.tp_attribute14 :=
                          p_delivery_rec.tp_attribute14;
    END IF;
    IF p_delivery_rec.tp_attribute15 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_attribute15 IS NULL THEN
      x_delivery_rec.tp_attribute15 :=
                          p_delivery_rec.tp_attribute15;
    END IF;
    IF p_delivery_rec.tp_ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.tp_ATTRIBUTE_CATEGORY IS NULL THEN
      x_delivery_rec.tp_ATTRIBUTE_CATEGORY :=
                          p_delivery_rec.tp_ATTRIBUTE_CATEGORY;
    END IF;
    IF p_delivery_rec.global_attribute1 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute1 IS NULL THEN
      x_delivery_rec.global_attribute1 :=
                          p_delivery_rec.global_attribute1;
    END IF;
    IF p_delivery_rec.global_attribute2 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute2 IS NULL THEN
      x_delivery_rec.global_attribute2 :=
                          p_delivery_rec.global_attribute2;
    END IF;
    IF p_delivery_rec.global_attribute3 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute3 IS NULL THEN
      x_delivery_rec.global_attribute3 :=
                          p_delivery_rec.global_attribute3;
    END IF;
    IF p_delivery_rec.global_attribute4 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute4 IS NULL THEN
      x_delivery_rec.global_attribute4 :=
                          p_delivery_rec.global_attribute4;
    END IF;
    IF p_delivery_rec.global_attribute5 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute5 IS NULL THEN
      x_delivery_rec.global_attribute5 :=
                          p_delivery_rec.global_attribute5;
    END IF;
    IF p_delivery_rec.global_attribute6 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute6 IS NULL THEN
      x_delivery_rec.global_attribute6 :=
                          p_delivery_rec.global_attribute6;
    END IF;
    IF p_delivery_rec.global_attribute7 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute7 IS NULL THEN
      x_delivery_rec.global_attribute7 :=
                          p_delivery_rec.global_attribute7;
    END IF;
    IF p_delivery_rec.global_attribute8 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute8 IS NULL THEN
      x_delivery_rec.global_attribute8 :=
                          p_delivery_rec.global_attribute8;
    END IF;
    IF p_delivery_rec.global_attribute9 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute9 IS NULL THEN
      x_delivery_rec.global_attribute9 :=
                          p_delivery_rec.global_attribute9;
    END IF;
    IF p_delivery_rec.global_attribute10 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute10 IS NULL THEN
      x_delivery_rec.global_attribute10 :=
                          p_delivery_rec.global_attribute10;
    END IF;
    IF p_delivery_rec.global_attribute11 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute11 IS NULL THEN
      x_delivery_rec.global_attribute11 :=
                          p_delivery_rec.global_attribute11;
    END IF;
    IF p_delivery_rec.global_attribute12 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute12 IS NULL THEN
      x_delivery_rec.global_attribute12 :=
                          p_delivery_rec.global_attribute12;
    END IF;
    IF p_delivery_rec.global_attribute13 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute13 IS NULL THEN
      x_delivery_rec.global_attribute13 :=
                          p_delivery_rec.global_attribute13;
    END IF;
    IF p_delivery_rec.global_attribute14 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute14 IS NULL THEN
      x_delivery_rec.global_attribute14 :=
                          p_delivery_rec.global_attribute14;
    END IF;
    IF p_delivery_rec.global_attribute15 <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_attribute15 IS NULL THEN
      x_delivery_rec.global_attribute15 :=
                          p_delivery_rec.global_attribute15;
    END IF;
    IF p_delivery_rec.global_ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.global_ATTRIBUTE_CATEGORY IS NULL THEN
      x_delivery_rec.global_ATTRIBUTE_CATEGORY :=
                          p_delivery_rec.global_ATTRIBUTE_CATEGORY;
    END IF;
    IF p_delivery_rec.ULTIMATE_DROPOFF_DATE <> FND_API.G_MISS_DATE
       OR p_delivery_rec.ULTIMATE_DROPOFF_DATE IS NULL THEN
      x_delivery_rec.ULTIMATE_DROPOFF_DATE :=
                          p_delivery_rec.ULTIMATE_DROPOFF_DATE;
    END IF;
    IF p_delivery_rec.DOCK_CODE <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.DOCK_CODE IS NULL THEN
      x_delivery_rec.DOCK_CODE :=
                          p_delivery_rec.DOCK_CODE;
    END IF;
    IF p_delivery_rec.ACCEPTANCE_FLAG <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.ACCEPTANCE_FLAG IS NULL THEN
      x_delivery_rec.ACCEPTANCE_FLAG :=
                          p_delivery_rec.ACCEPTANCE_FLAG;
    END IF;
    IF p_delivery_rec.ACCEPTED_BY <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.ACCEPTED_BY IS NULL THEN
      x_delivery_rec.ACCEPTED_BY :=
                          p_delivery_rec.ACCEPTED_BY;
    END IF;
    IF p_delivery_rec.ACCEPTED_DATE <> FND_API.G_MISS_DATE
       OR p_delivery_rec.ACCEPTED_DATE IS NULL THEN
      x_delivery_rec.ACCEPTED_DATE :=
                          p_delivery_rec.ACCEPTED_DATE;
    END IF;
    IF p_delivery_rec.ACKNOWLEDGED_BY <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.ACKNOWLEDGED_BY IS NULL THEN
      x_delivery_rec.ACKNOWLEDGED_BY :=
                          p_delivery_rec.ACKNOWLEDGED_BY;
    END IF;
    IF p_delivery_rec.CONFIRMED_BY <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.CONFIRMED_BY IS NULL THEN
      x_delivery_rec.CONFIRMED_BY :=
                          p_delivery_rec.CONFIRMED_BY;
    END IF;
    IF p_delivery_rec.CONFIRM_DATE <> FND_API.G_MISS_DATE
       OR p_delivery_rec.CONFIRM_DATE IS NULL THEN
      x_delivery_rec.CONFIRM_DATE :=
                          p_delivery_rec.CONFIRM_DATE;
    END IF;
    IF p_delivery_rec.PORT_OF_DISCHARGE <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.PORT_OF_DISCHARGE IS NULL THEN
      x_delivery_rec.PORT_OF_DISCHARGE :=
                          p_delivery_rec.PORT_OF_DISCHARGE;
    END IF;
    IF p_delivery_rec.ROUTING_INSTRUCTIONS <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.ROUTING_INSTRUCTIONS IS NULL THEN
      x_delivery_rec.ROUTING_INSTRUCTIONS :=
                          p_delivery_rec.ROUTING_INSTRUCTIONS;
    END IF;
    IF p_delivery_rec.ASSIGNED_TO_FTE_TRIPS <> FND_API.G_MISS_CHAR
       OR p_delivery_rec.ASSIGNED_TO_FTE_TRIPS IS NULL THEN
      x_delivery_rec.ASSIGNED_TO_FTE_TRIPS :=
                          p_delivery_rec.ASSIGNED_TO_FTE_TRIPS;
    END IF;

--tkt
    IF p_in_rec.caller='WSH_TP_RELEASE' THEN
       IF p_delivery_rec.tp_plan_name <> FND_API.G_MISS_CHAR
          OR p_delivery_rec.tp_plan_name IS NULL THEN
          x_delivery_rec.tp_plan_name :=
                          p_delivery_rec.tp_plan_name;
       END IF;
       IF p_delivery_rec.tp_delivery_number <> FND_API.G_MISS_NUM
          OR p_delivery_rec.tp_delivery_number IS NULL THEN
          x_delivery_rec.tp_delivery_number :=
                          p_delivery_rec.tp_delivery_number;
       END IF;
    END IF;

/*3667348*/
     IF p_delivery_rec.REASON_OF_TRANSPORT <> FND_API.G_MISS_CHAR
	  OR p_delivery_rec.REASON_OF_TRANSPORT IS NULL THEN
       	  x_delivery_rec.REASON_OF_TRANSPORT :=  p_delivery_rec.REASON_OF_TRANSPORT;
     END IF;
     IF p_delivery_rec.DESCRIPTION <> FND_API.G_MISS_CHAR
	  OR p_delivery_rec.DESCRIPTION IS NULL THEN
       	  x_delivery_rec.DESCRIPTION :=  p_delivery_rec.DESCRIPTION;
     END IF;


END eliminate_displayonly_fields;

/*----------------------------------------------------------
-- Procedure disable_from_list will update the record x_out_rec
-- and disables the field contained in p_disabled_list.
-----------------------------------------------------------*/

PROCEDURE disable_from_list(
  p_disabled_list IN         WSH_UTIL_CORE.column_tab_type
, p_in_rec        IN         WSH_NEW_DELIVERIES_PVT.Delivery_rec_type
, x_out_rec       IN OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_rec_type
, x_return_status OUT NOCOPY       VARCHAR2
, x_field_name    OUT NOCOPY       VARCHAR2
, p_caller        IN               VARCHAR2

) IS
l_prefix VARCHAR2(1);
BEGIN

  FOR i IN 1..p_disabled_list.COUNT
  LOOP
    l_prefix := SUBSTR(p_disabled_list(i),1,1);
    IF l_prefix = '+' THEN
      IF p_disabled_list(i)  = '+ADDITIONAL_SHIPMENT_INFO' THEN
       IF p_in_rec.ADDITIONAL_SHIPMENT_INFO IS NOT NULL THEN
        x_out_rec.ADDITIONAL_SHIPMENT_INFO := p_in_rec.ADDITIONAL_SHIPMENT_INFO ;
       END IF;
      ELSIF p_disabled_list(i)  = '+DOCK_CODE' THEN
       IF p_in_rec.DOCK_CODE IS NOT NULL THEN
        x_out_rec.DOCK_CODE := p_in_rec.DOCK_CODE ;
       END IF;
      ELSIF p_disabled_list(i)  = '+CONFIRMED_BY' THEN
       IF p_in_rec.CONFIRMED_BY IS NOT NULL THEN
        x_out_rec.CONFIRMED_BY := p_in_rec.CONFIRMED_BY ;
       END IF;
      ELSIF p_disabled_list(i)  = '+INITIAL_PICKUP_LOCATION_CODE' THEN
       IF p_in_rec.INITIAL_PICKUP_LOCATION_ID IS NOT NULL THEN
        x_out_rec.INITIAL_PICKUP_LOCATION_ID :=
                                           p_in_rec.INITIAL_PICKUP_LOCATION_ID ;
        x_out_rec.INITIAL_PICKUP_LOCATION_CODE := FND_API.G_MISS_CHAR;
       END IF;
      ELSIF p_disabled_list(i)  = '+ULTIMATE_DROPOFF_LOCATION_CODE' THEN
       IF p_in_rec.ULTIMATE_DROPOFF_LOCATION_ID IS NOT NULL THEN
        x_out_rec.ULTIMATE_DROPOFF_LOCATION_ID :=
                                       p_in_rec.ULTIMATE_DROPOFF_LOCATION_ID ;
        x_out_rec.ULTIMATE_DROPOFF_LOCATION_CODE := FND_API.G_MISS_CHAR;
       END IF;
      ELSIF p_disabled_list(i)  = '+CUSTOMER_NAME' THEN
       IF p_in_rec.CUSTOMER_ID IS NOT NULL THEN
        x_out_rec.CUSTOMER_ID := p_in_rec.CUSTOMER_ID ;
        x_out_rec.CUSTOMER_NUMBER := FND_API.G_MISS_CHAR;
       END IF;
       -- LSP PROJECT
       ELSIF p_disabled_list(i)  = '+CLIENT_NAME' THEN
       IF p_in_rec.client_ID IS NOT NULL THEN
        x_out_rec.client_ID := p_in_rec.client_ID ;
        x_out_rec.client_code := FND_API.G_MISS_CHAR;
       END IF;
       -- LSP PROJECT
      ELSIF p_disabled_list(i)  = '+ORGANIZATION_CODE' THEN
       IF p_in_rec.ORGANIZATION_ID IS NOT NULL THEN
        x_out_rec.ORGANIZATION_ID := p_in_rec.ORGANIZATION_ID ;
        x_out_rec.organization_code := FND_API.G_MISS_CHAR;
       END IF;
      ELSIF p_disabled_list(i)  = '+LOADING_ORDER_FLAG' THEN
       IF p_in_rec.LOADING_ORDER_FLAG IS NOT NULL THEN
        x_out_rec.LOADING_ORDER_FLAG := p_in_rec.LOADING_ORDER_FLAG ;
        x_out_rec.LOADING_ORDER_DESC := FND_API.G_MISS_CHAR;
       END IF;
      ELSIF p_disabled_list(i)  = '+ACCEPTANCE_FLAG' THEN
       IF p_in_rec.ACCEPTANCE_FLAG IS NOT NULL THEN
        x_out_rec.ACCEPTANCE_FLAG := p_in_rec.ACCEPTANCE_FLAG ;
       END IF;
      ELSIF p_disabled_list(i)  = '+ACCEPTED_BY' THEN
       IF p_in_rec.ACCEPTED_BY IS NOT NULL THEN
        x_out_rec.ACCEPTED_BY := p_in_rec.ACCEPTED_BY ;
       END IF;
      ELSIF p_disabled_list(i)  = '+ACCEPTED_DATE' THEN
       IF p_in_rec.ACCEPTED_DATE IS NOT NULL THEN
        x_out_rec.ACCEPTED_DATE := p_in_rec.ACCEPTED_DATE ;
       END IF;
      ELSIF p_disabled_list(i)  = '+ACKNOWLEDGED_BY' THEN
       IF p_in_rec.ACKNOWLEDGED_BY IS NOT NULL THEN
        x_out_rec.ACKNOWLEDGED_BY := p_in_rec.ACKNOWLEDGED_BY ;
       END IF;
      ELSIF p_disabled_list(i)  = '+CURRENCY_CODE' THEN
       IF p_in_rec.CURRENCY_CODE IS NOT NULL THEN
        x_out_rec.CURRENCY_CODE := p_in_rec.CURRENCY_CODE ;
        x_out_rec.currency_name := FND_API.G_MISS_CHAR;
       END IF;
      ELSIF p_disabled_list(i)  = '+INITIAL_PICKUP_DATE' THEN
       IF p_in_rec.INITIAL_PICKUP_DATE IS NOT NULL THEN
        x_out_rec.INITIAL_PICKUP_DATE := p_in_rec.INITIAL_PICKUP_DATE ;
       END IF;
      ELSIF p_disabled_list(i)  = '+ULTIMATE_DROPOFF_DATE' THEN
       IF p_in_rec.ULTIMATE_DROPOFF_DATE IS NOT NULL THEN
        x_out_rec.ULTIMATE_DROPOFF_DATE := p_in_rec.ULTIMATE_DROPOFF_DATE ;
       END IF;
      ELSIF p_disabled_list(i)  = '+LOADING_SEQUENCE' THEN
       IF p_in_rec.LOADING_SEQUENCE IS NOT NULL THEN
        x_out_rec.LOADING_SEQUENCE := p_in_rec.LOADING_SEQUENCE ;
       END IF;
      ELSIF p_disabled_list(i)  = '+SHIP_METHOD_NAME' THEN
       IF p_in_rec.SHIP_METHOD_CODE IS NOT NULL THEN
        x_out_rec.SHIP_METHOD_CODE := p_in_rec.SHIP_METHOD_CODE ;
        x_out_rec.ship_method_name := FND_API.G_MISS_CHAR;
       END IF;
      ELSIF p_disabled_list(i)  = '+FREIGHT_CODE' THEN
        NULL ;
       -- J-IB-NPARIKH-{  --I-bugfix
       IF p_in_rec.CARRIER_CODE IS NOT NULL THEN
        x_out_rec.carrier_id := p_in_rec.carrier_id ;
        x_out_rec.CARRIER_CODE := FND_API.G_MISS_CHAR;
       END IF;
       -- J-IB-NPARIKH-}

      ELSIF p_disabled_list(i)  = '+SERVICE_LEVEL_NAME' THEN
       IF p_in_rec.SERVICE_LEVEL IS NOT NULL THEN
        x_out_rec.SERVICE_LEVEL := p_in_rec.SERVICE_LEVEL ;
       END IF;
      ELSIF p_disabled_list(i)  = '+MODE_OF_TRANSPORT_NAME' THEN
       IF p_in_rec.MODE_OF_TRANSPORT IS NOT NULL THEN
        x_out_rec.MODE_OF_TRANSPORT := p_in_rec.MODE_OF_TRANSPORT ;
       END IF;
      ELSIF p_disabled_list(i)  = '+NAME' THEN
       IF p_in_rec.NAME IS NOT NULL THEN
        x_out_rec.NAME := p_in_rec.NAME ;
       END IF;
      ELSIF p_disabled_list(i)  = '+INTMED_SHIP_TO_LOCATION_CODE' THEN
       IF p_in_rec.INTMED_SHIP_TO_LOCATION_ID IS NOT NULL THEN
        x_out_rec.INTMED_SHIP_TO_LOCATION_ID :=
                                        p_in_rec.INTMED_SHIP_TO_LOCATION_ID ;
        x_out_rec.INTMED_SHIP_TO_LOCATION_CODE := FND_API.G_MISS_CHAR;
       END IF;
      ELSIF p_disabled_list(i)  = '+POOLED_SHIP_TO_LOCATION_CODE' THEN
       IF p_in_rec.POOLED_SHIP_TO_LOCATION_ID IS NOT NULL THEN
        x_out_rec.POOLED_SHIP_TO_LOCATION_ID :=
                                           p_in_rec.POOLED_SHIP_TO_LOCATION_ID ;
        x_out_rec.POOLED_SHIP_TO_LOCATION_CODE := FND_API.G_MISS_CHAR;
       END IF;
      ELSIF p_disabled_list(i)  = '+WAYBILL' THEN
       IF p_in_rec.WAYBILL IS NOT NULL THEN
        x_out_rec.WAYBILL := p_in_rec.WAYBILL ;
       END IF;
      ELSIF p_disabled_list(i)  = '+FREIGHT_TERMS_NAME' THEN
       IF p_in_rec.FREIGHT_TERMS_CODE IS NOT NULL THEN
        x_out_rec.FREIGHT_TERMS_CODE := p_in_rec.FREIGHT_TERMS_CODE ;
        x_out_rec.FREIGHT_TERMS_NAME := FND_API.G_MISS_CHAR;
       END IF;
      ELSIF p_disabled_list(i)  = '+GROSS_WEIGHT' THEN
       IF p_in_rec.GROSS_WEIGHT IS NOT NULL THEN
        x_out_rec.GROSS_WEIGHT := p_in_rec.GROSS_WEIGHT ;
       END IF;
      ELSIF p_disabled_list(i)  = '+NET_WEIGHT' THEN
       IF p_in_rec.NET_WEIGHT IS NOT NULL THEN
        x_out_rec.NET_WEIGHT := p_in_rec.NET_WEIGHT ;
       END IF;
      ELSIF p_disabled_list(i)  = '+WEIGHT_UOM_CODE' THEN
       IF p_in_rec.WEIGHT_UOM_CODE IS NOT NULL THEN
        x_out_rec.WEIGHT_UOM_CODE := p_in_rec.WEIGHT_UOM_CODE ;
       END IF;
      ELSIF p_disabled_list(i)  = '+VOLUME' THEN
       IF p_in_rec.VOLUME IS NOT NULL THEN
        x_out_rec.VOLUME := p_in_rec.VOLUME ;
       END IF;
      ELSIF p_disabled_list(i)  = '+VOLUME_UOM_CODE' THEN
       IF p_in_rec.VOLUME_UOM_CODE IS NOT NULL THEN
        x_out_rec.VOLUME_UOM_CODE := p_in_rec.VOLUME_UOM_CODE ;
        x_out_rec.volume_uom_desc := FND_API.G_MISS_CHAR;
       END IF;
      ELSIF p_disabled_list(i)  = '+FOB_NAME' THEN
       IF p_in_rec.FOB_CODE IS NOT NULL THEN
        x_out_rec.FOB_CODE := p_in_rec.FOB_CODE ;
        x_out_rec.FOB_NAME := FND_API.G_MISS_CHAR;
       END IF;
      ELSIF p_disabled_list(i)  = '+FOB_LOCATION_CODE' THEN
       IF p_in_rec.FOB_LOCATION_ID IS NOT NULL THEN
        x_out_rec.FOB_LOCATION_ID := p_in_rec.FOB_LOCATION_ID ;
        x_out_rec.FOB_LOCATION_CODE := FND_API.G_MISS_CHAR;
       END IF;
      ELSIF p_disabled_list(i)  = '+AUTO_SC_EXCLUDE_FLAG' THEN
       IF p_in_rec.AUTO_SC_EXCLUDE_FLAG IS NOT NULL THEN
        x_out_rec.AUTO_SC_EXCLUDE_FLAG := p_in_rec.AUTO_SC_EXCLUDE_FLAG ;
       END IF;
      ELSIF p_disabled_list(i)  = '+AUTO_AP_EXCLUDE_FLAG' THEN
       IF p_in_rec.AUTO_AP_EXCLUDE_FLAG IS NOT NULL THEN
        x_out_rec.AUTO_AP_EXCLUDE_FLAG := p_in_rec.AUTO_AP_EXCLUDE_FLAG ;
       END IF;
      ELSIF p_disabled_list(i)  = '+NUMBER_OF_LPN' THEN
       IF p_in_rec.NUMBER_OF_LPN IS NOT NULL THEN
        x_out_rec.NUMBER_OF_LPN := p_in_rec.NUMBER_OF_LPN ;
       END IF;
      ELSIF p_disabled_list(i)  = '+DESC_FLEX' THEN
       IF p_in_rec.attribute1 IS NOT NULL THEN
        x_out_rec.attribute1 := p_in_rec.attribute1 ;
       END IF;
       IF p_in_rec.attribute2 IS NOT NULL THEN
        x_out_rec.attribute2 := p_in_rec.attribute2 ;
       END IF;
       IF p_in_rec.attribute3 IS NOT NULL THEN
        x_out_rec.attribute3 := p_in_rec.attribute3 ;
       END IF;
       IF p_in_rec.attribute4 IS NOT NULL THEN
        x_out_rec.attribute4 := p_in_rec.attribute4 ;
       END IF;
       IF p_in_rec.attribute5 IS NOT NULL THEN
        x_out_rec.attribute5 := p_in_rec.attribute5 ;
       END IF;
       IF p_in_rec.attribute6 IS NOT NULL THEN
        x_out_rec.attribute6 := p_in_rec.attribute6 ;
       END IF;
       IF p_in_rec.attribute7 IS NOT NULL THEN
        x_out_rec.attribute7 := p_in_rec.attribute7 ;
       END IF;
       IF p_in_rec.attribute8 IS NOT NULL THEN
        x_out_rec.attribute8 := p_in_rec.attribute8 ;
       END IF;
       IF p_in_rec.attribute9 IS NOT NULL THEN
        x_out_rec.attribute9 := p_in_rec.attribute9 ;
       END IF;
       IF p_in_rec.attribute10 IS NOT NULL THEN
        x_out_rec.attribute10 := p_in_rec.attribute10 ;
       END IF;
       IF p_in_rec.attribute11 IS NOT NULL THEN
        x_out_rec.attribute11 := p_in_rec.attribute11 ;
       END IF;
       IF p_in_rec.attribute12 IS NOT NULL THEN
        x_out_rec.attribute12 := p_in_rec.attribute12 ;
       END IF;
       IF p_in_rec.attribute13 IS NOT NULL THEN
        x_out_rec.attribute13 := p_in_rec.attribute13 ;
       END IF;
       IF p_in_rec.attribute14 IS NOT NULL THEN
        x_out_rec.attribute14 := p_in_rec.attribute14 ;
       END IF;
       IF p_in_rec.attribute15 IS NOT NULL THEN
        x_out_rec.attribute15 := p_in_rec.attribute15 ;
       END IF;
       IF p_in_rec.attribute_category IS NOT NULL THEN
        x_out_rec.attribute_category := p_in_rec.attribute_category ;
       END IF;
      ELSIF p_disabled_list(i)  = '+TP_FLEXFIELD' THEN
       IF p_in_rec.tp_attribute1 IS NOT NULL THEN
        x_out_rec.tp_attribute1 := p_in_rec.tp_attribute1 ;
       END IF;
       IF p_in_rec.tp_attribute2 IS NOT NULL THEN
        x_out_rec.tp_attribute2 := p_in_rec.tp_attribute2 ;
       END IF;
       IF p_in_rec.tp_attribute3 IS NOT NULL THEN
        x_out_rec.tp_attribute3 := p_in_rec.tp_attribute3 ;
       END IF;
       IF p_in_rec.tp_attribute4 IS NOT NULL THEN
        x_out_rec.tp_attribute4 := p_in_rec.tp_attribute4 ;
       END IF;
       IF p_in_rec.tp_attribute5 IS NOT NULL THEN
        x_out_rec.tp_attribute5 := p_in_rec.tp_attribute5 ;
       END IF;
       IF p_in_rec.tp_attribute6 IS NOT NULL THEN
        x_out_rec.tp_attribute6 := p_in_rec.tp_attribute6 ;
       END IF;
       IF p_in_rec.tp_attribute7 IS NOT NULL THEN
        x_out_rec.tp_attribute7 := p_in_rec.tp_attribute7 ;
       END IF;
       IF p_in_rec.tp_attribute8 IS NOT NULL THEN
        x_out_rec.tp_attribute8 := p_in_rec.tp_attribute8 ;
       END IF;
       IF p_in_rec.tp_attribute9 IS NOT NULL THEN
        x_out_rec.tp_attribute9 := p_in_rec.tp_attribute9 ;
       END IF;
       IF p_in_rec.tp_attribute10 IS NOT NULL THEN
        x_out_rec.tp_attribute10 := p_in_rec.tp_attribute10 ;
       END IF;
       IF p_in_rec.tp_attribute11 IS NOT NULL THEN
        x_out_rec.tp_attribute11 := p_in_rec.tp_attribute11 ;
       END IF;
       IF p_in_rec.tp_attribute12 IS NOT NULL THEN
        x_out_rec.tp_attribute12 := p_in_rec.tp_attribute12 ;
       END IF;
       IF p_in_rec.tp_attribute13 IS NOT NULL THEN
        x_out_rec.tp_attribute13 := p_in_rec.tp_attribute13 ;
       END IF;
       IF p_in_rec.tp_attribute14 IS NOT NULL THEN
        x_out_rec.tp_attribute14 := p_in_rec.tp_attribute14 ;
       END IF;
       IF p_in_rec.tp_attribute15 IS NOT NULL THEN
        x_out_rec.tp_attribute15 := p_in_rec.tp_attribute15 ;
       END IF;
       IF p_in_rec.tp_attribute_category IS NOT NULL THEN
        x_out_rec.tp_attribute_category := p_in_rec.tp_attribute_category ;
       END IF;
      ELSIF p_disabled_list(i)  = '+GLOBALIZATION_FLEXFIELD' THEN
       IF p_in_rec.global_attribute1 IS NOT NULL THEN
        x_out_rec.global_attribute1 := p_in_rec.global_attribute1 ;
       END IF;
       IF p_in_rec.global_attribute2 IS NOT NULL THEN
        x_out_rec.global_attribute2 := p_in_rec.global_attribute2 ;
       END IF;
       IF p_in_rec.global_attribute3 IS NOT NULL THEN
        x_out_rec.global_attribute3 := p_in_rec.global_attribute3 ;
       END IF;
       IF p_in_rec.global_attribute4 IS NOT NULL THEN
        x_out_rec.global_attribute4 := p_in_rec.global_attribute4 ;
       END IF;
       IF p_in_rec.global_attribute5 IS NOT NULL THEN
        x_out_rec.global_attribute5 := p_in_rec.global_attribute5 ;
       END IF;
       IF p_in_rec.global_attribute6 IS NOT NULL THEN
        x_out_rec.global_attribute6 := p_in_rec.global_attribute6 ;
       END IF;
       IF p_in_rec.global_attribute7 IS NOT NULL THEN
        x_out_rec.global_attribute7 := p_in_rec.global_attribute7 ;
       END IF;
       IF p_in_rec.global_attribute8 IS NOT NULL THEN
        x_out_rec.global_attribute8 := p_in_rec.global_attribute8 ;
       END IF;
       IF p_in_rec.global_attribute9 IS NOT NULL THEN
        x_out_rec.global_attribute9 := p_in_rec.global_attribute9 ;
       END IF;
       IF p_in_rec.global_attribute10 IS NOT NULL THEN
        x_out_rec.global_attribute10 := p_in_rec.global_attribute10 ;
       END IF;
       IF p_in_rec.global_attribute11 IS NOT NULL THEN
        x_out_rec.global_attribute11 := p_in_rec.global_attribute11 ;
       END IF;
       IF p_in_rec.global_attribute12 IS NOT NULL THEN
        x_out_rec.global_attribute12 := p_in_rec.global_attribute12 ;
       END IF;
       IF p_in_rec.global_attribute13 IS NOT NULL THEN
        x_out_rec.global_attribute13 := p_in_rec.global_attribute13 ;
       END IF;
       IF p_in_rec.global_attribute14 IS NOT NULL THEN
        x_out_rec.global_attribute14 := p_in_rec.global_attribute14 ;
       END IF;
       IF p_in_rec.global_attribute15 IS NOT NULL THEN
        x_out_rec.global_attribute15 := p_in_rec.global_attribute15 ;
       END IF;
       IF p_in_rec.global_attribute_category IS NOT NULL THEN
        x_out_rec.global_attribute_category := p_in_rec.global_attribute_category ;
       END IF;
      ELSIF   p_disabled_list(i)  = '+TARE_WEIGHT'       THEN
        NULL;
      ELSE
        -- invalid name
        x_field_name := p_disabled_list(i);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        RETURN;
        --
      END IF;
    ELSE -- else if l_prefix is not '+'
      IF p_disabled_list(i)  = 'ADDITIONAL_SHIPMENT_INFO' THEN
        x_out_rec.ADDITIONAL_SHIPMENT_INFO := p_in_rec.ADDITIONAL_SHIPMENT_INFO ;
      ELSIF p_disabled_list(i)  = 'DOCK_CODE' THEN
        x_out_rec.DOCK_CODE := p_in_rec.DOCK_CODE ;
      ELSIF p_disabled_list(i)  = 'CONFIRMED_BY' THEN
        x_out_rec.CONFIRMED_BY := p_in_rec.CONFIRMED_BY ;
      ELSIF p_disabled_list(i)  = 'INITIAL_PICKUP_LOCATION_CODE' THEN
        x_out_rec.INITIAL_PICKUP_LOCATION_ID :=
                                           p_in_rec.INITIAL_PICKUP_LOCATION_ID ;
        x_out_rec.INITIAL_PICKUP_LOCATION_CODE := FND_API.G_MISS_CHAR;
      ELSIF p_disabled_list(i)  = 'ULTIMATE_DROPOFF_LOCATION_CODE' THEN
        x_out_rec.ULTIMATE_DROPOFF_LOCATION_ID :=
                                       p_in_rec.ULTIMATE_DROPOFF_LOCATION_ID ;
        x_out_rec.ULTIMATE_DROPOFF_LOCATION_CODE := FND_API.G_MISS_CHAR;
      ELSIF p_disabled_list(i)  = 'CUSTOMER_NAME' THEN
        x_out_rec.CUSTOMER_ID := p_in_rec.CUSTOMER_ID ;
        x_out_rec.customer_number := FND_API.G_MISS_CHAR;
        -- LSP PROJECT
      ELSIF p_disabled_list(i)  = 'CLIENT_NAME' THEN
        x_out_rec.CLIENT_ID := p_in_rec.CLIENT_ID ;
        x_out_rec.CLIENT_CODE := FND_API.G_MISS_CHAR;
      -- LSP PROJECT
      ELSIF p_disabled_list(i)  = 'ORGANIZATION_CODE' THEN
        x_out_rec.ORGANIZATION_ID := p_in_rec.ORGANIZATION_ID ;
        x_out_rec.ORGANIZATION_CODE := FND_API.G_MISS_CHAR;
      ELSIF p_disabled_list(i)  = 'LOADING_ORDER_FLAG' THEN
        x_out_rec.LOADING_ORDER_FLAG := p_in_rec.LOADING_ORDER_FLAG ;
        x_out_rec.LOADING_ORDER_DESC := FND_API.G_MISS_CHAR;
      ELSIF p_disabled_list(i)  = 'ACCEPTANCE_FLAG' THEN
        x_out_rec.ACCEPTANCE_FLAG := p_in_rec.ACCEPTANCE_FLAG ;
      ELSIF p_disabled_list(i)  = 'ACCEPTED_BY' THEN
        x_out_rec.ACCEPTED_BY := p_in_rec.ACCEPTED_BY ;
      ELSIF p_disabled_list(i)  = 'ACCEPTED_DATE' THEN
        x_out_rec.ACCEPTED_DATE := p_in_rec.ACCEPTED_DATE ;
      ELSIF p_disabled_list(i)  = 'ACKNOWLEDGED_BY' THEN
        x_out_rec.ACKNOWLEDGED_BY := p_in_rec.ACKNOWLEDGED_BY ;
      ELSIF p_disabled_list(i)  = 'CURRENCY_CODE' THEN
        x_out_rec.CURRENCY_CODE := p_in_rec.CURRENCY_CODE ;
        x_out_rec.currency_name := FND_API.G_MISS_CHAR;
      ELSIF p_disabled_list(i)  = 'INITIAL_PICKUP_DATE' THEN
        x_out_rec.INITIAL_PICKUP_DATE := p_in_rec.INITIAL_PICKUP_DATE ;
      ELSIF p_disabled_list(i)  = 'ULTIMATE_DROPOFF_DATE' THEN
        x_out_rec.ULTIMATE_DROPOFF_DATE := p_in_rec.ULTIMATE_DROPOFF_DATE ;
      ELSIF p_disabled_list(i)  = 'LOADING_SEQUENCE' THEN
        x_out_rec.LOADING_SEQUENCE := p_in_rec.LOADING_SEQUENCE ;
      ELSIF p_disabled_list(i)  = 'SHIP_METHOD_NAME' THEN
        x_out_rec.SHIP_METHOD_CODE := p_in_rec.SHIP_METHOD_CODE ;
        x_out_rec.SHIP_METHOD_NAME := FND_API.G_MISS_CHAR;
      ELSIF p_disabled_list(i)  = 'FREIGHT_CODE' THEN
        IF (nvl(p_caller, '!!!!') <> 'WSH_INBOUND') THEN
          --x_out_rec.carrier_code := p_in_rec.carrier_code ;   -- J-IB-NPARIKH--I-bug-fix
          x_out_rec.carrier_id := p_in_rec.carrier_id ; -- J-IB-NPARIKH--I-bug-fix
          x_out_rec.CARRIER_CODE := FND_API.G_MISS_CHAR; -- J-IB-NPARIKH--I-bug-fix
        END IF;
      ELSIF p_disabled_list(i)  = 'SERVICE_LEVEL_NAME' THEN
        IF (nvl(p_caller, '!!!!') <> 'WSH_INBOUND') THEN
          x_out_rec.SERVICE_LEVEL := p_in_rec.SERVICE_LEVEL ;
        END IF;
      ELSIF p_disabled_list(i)  = 'MODE_OF_TRANSPORT_NAME' THEN
        IF (nvl(p_caller, '!!!!') <> 'WSH_INBOUND') THEN
          x_out_rec.MODE_OF_TRANSPORT := p_in_rec.MODE_OF_TRANSPORT ;
        END IF;
      ELSIF p_disabled_list(i)  = 'NAME' THEN
        x_out_rec.NAME := p_in_rec.NAME ;
      ELSIF p_disabled_list(i)  = 'INTMED_SHIP_TO_LOCATION_CODE' THEN
        x_out_rec.INTMED_SHIP_TO_LOCATION_ID :=
                                        p_in_rec.INTMED_SHIP_TO_LOCATION_ID ;
        x_out_rec.INTMED_SHIP_TO_LOCATION_CODE := FND_API.G_MISS_CHAR;
      ELSIF p_disabled_list(i)  = 'POOLED_SHIP_TO_LOCATION_CODE' THEN
        x_out_rec.POOLED_SHIP_TO_LOCATION_ID :=
                                           p_in_rec.POOLED_SHIP_TO_LOCATION_ID ;
        x_out_rec.POOLED_SHIP_TO_LOCATION_CODE := FND_API.G_MISS_CHAR;
      ELSIF p_disabled_list(i)  = 'WAYBILL' THEN
        x_out_rec.WAYBILL := p_in_rec.WAYBILL ;
      ELSIF p_disabled_list(i)  = 'FREIGHT_TERMS_NAME' THEN
        x_out_rec.FREIGHT_TERMS_CODE := p_in_rec.FREIGHT_TERMS_CODE ;
        x_out_rec.FREIGHT_TERMS_NAME := FND_API.G_MISS_CHAR;
      ELSIF p_disabled_list(i)  = 'GROSS_WEIGHT' THEN
        x_out_rec.GROSS_WEIGHT := p_in_rec.GROSS_WEIGHT ;
      ELSIF p_disabled_list(i)  = 'NET_WEIGHT' THEN
        x_out_rec.NET_WEIGHT := p_in_rec.NET_WEIGHT ;
-- Non Database field prorate_wt_flag added for "Proration of weight from Delivery to delivery lines" Project(Bug#4254552).
      ELSIF p_disabled_list(i)  = 'PRORATE_WT_FLAG' THEN
        x_out_rec.PRORATE_WT_FLAG := p_in_rec.PRORATE_WT_FLAG ;
--
      ELSIF p_disabled_list(i)  = 'WEIGHT_UOM_CODE' THEN
        x_out_rec.WEIGHT_UOM_CODE := p_in_rec.WEIGHT_UOM_CODE ;
        x_out_rec.weight_uom_desc := FND_API.G_MISS_CHAR;
      ELSIF p_disabled_list(i)  = 'VOLUME' THEN
        x_out_rec.VOLUME := p_in_rec.VOLUME ;
      ELSIF p_disabled_list(i)  = 'VOLUME_UOM_CODE' THEN
        x_out_rec.VOLUME_UOM_CODE := p_in_rec.VOLUME_UOM_CODE ;
        x_out_rec.volume_uom_desc := FND_API.G_MISS_CHAR;
      ELSIF p_disabled_list(i)  = 'FOB_NAME' THEN
        x_out_rec.FOB_CODE := p_in_rec.FOB_CODE ;
        x_out_rec.FOB_NAME := FND_API.G_MISS_CHAR;
      ELSIF p_disabled_list(i)  = 'FOB_LOCATION_CODE' THEN
        x_out_rec.FOB_LOCATION_ID := p_in_rec.FOB_LOCATION_ID ;
        x_out_rec.FOB_LOCATION_CODE := FND_API.G_MISS_CHAR;
      ELSIF p_disabled_list(i)  = 'NUMBER_OF_LPN' THEN
        x_out_rec.NUMBER_OF_LPN := p_in_rec.NUMBER_OF_LPN ;
      ELSIF p_disabled_list(i)  = 'AUTO_SC_EXCLUDE_FLAG' THEN
        x_out_rec.AUTO_SC_EXCLUDE_FLAG := p_in_rec.AUTO_SC_EXCLUDE_FLAG ;
      ELSIF p_disabled_list(i)  = 'AUTO_AP_EXCLUDE_FLAG' THEN
        x_out_rec.AUTO_AP_EXCLUDE_FLAG := p_in_rec.AUTO_AP_EXCLUDE_FLAG ;
      ELSIF p_disabled_list(i)  = 'DESC_FLEX' THEN
        x_out_rec.attribute1 := p_in_rec.attribute1 ;
        x_out_rec.attribute2 := p_in_rec.attribute2 ;
        x_out_rec.attribute3 := p_in_rec.attribute3 ;
        x_out_rec.attribute4 := p_in_rec.attribute4 ;
        x_out_rec.attribute5 := p_in_rec.attribute5 ;
        x_out_rec.attribute6 := p_in_rec.attribute6 ;
        x_out_rec.attribute7 := p_in_rec.attribute7 ;
        x_out_rec.attribute8 := p_in_rec.attribute8 ;
        x_out_rec.attribute9 := p_in_rec.attribute9 ;
        x_out_rec.attribute10 := p_in_rec.attribute10 ;
        x_out_rec.attribute11 := p_in_rec.attribute11 ;
        x_out_rec.attribute12 := p_in_rec.attribute12 ;
        x_out_rec.attribute13 := p_in_rec.attribute13 ;
        x_out_rec.attribute14 := p_in_rec.attribute14 ;
        x_out_rec.attribute15 := p_in_rec.attribute15 ;
        x_out_rec.attribute_category := p_in_rec.attribute_category ;
      ELSIF p_disabled_list(i)  = 'TP_FLEXFIELD' THEN
        x_out_rec.tp_attribute1 := p_in_rec.tp_attribute1 ;
        x_out_rec.tp_attribute2 := p_in_rec.tp_attribute2 ;
        x_out_rec.tp_attribute3 := p_in_rec.tp_attribute3 ;
        x_out_rec.tp_attribute4 := p_in_rec.tp_attribute4 ;
        x_out_rec.tp_attribute5 := p_in_rec.tp_attribute5 ;
        x_out_rec.tp_attribute6 := p_in_rec.tp_attribute6 ;
        x_out_rec.tp_attribute7 := p_in_rec.tp_attribute7 ;
        x_out_rec.tp_attribute8 := p_in_rec.tp_attribute8 ;
        x_out_rec.tp_attribute9 := p_in_rec.tp_attribute9 ;
        x_out_rec.tp_attribute10 := p_in_rec.tp_attribute10 ;
        x_out_rec.tp_attribute11 := p_in_rec.tp_attribute11 ;
        x_out_rec.tp_attribute12 := p_in_rec.tp_attribute12 ;
        x_out_rec.tp_attribute13 := p_in_rec.tp_attribute13 ;
        x_out_rec.tp_attribute14 := p_in_rec.tp_attribute14 ;
        x_out_rec.tp_attribute15 := p_in_rec.tp_attribute15 ;
        x_out_rec.tp_attribute_category := p_in_rec.tp_attribute_category ;
      ELSIF p_disabled_list(i)  = 'GLOBALIZATION_FLEXFIELD' THEN
        x_out_rec.global_attribute1 := p_in_rec.global_attribute1 ;
        x_out_rec.global_attribute2 := p_in_rec.global_attribute2 ;
        x_out_rec.global_attribute3 := p_in_rec.global_attribute3 ;
        x_out_rec.global_attribute4 := p_in_rec.global_attribute4 ;
        x_out_rec.global_attribute5 := p_in_rec.global_attribute5 ;
        x_out_rec.global_attribute6 := p_in_rec.global_attribute6 ;
        x_out_rec.global_attribute7 := p_in_rec.global_attribute7 ;
        x_out_rec.global_attribute8 := p_in_rec.global_attribute8 ;
        x_out_rec.global_attribute9 := p_in_rec.global_attribute9 ;
        x_out_rec.global_attribute10 := p_in_rec.global_attribute10 ;
        x_out_rec.global_attribute11 := p_in_rec.global_attribute11 ;
        x_out_rec.global_attribute12 := p_in_rec.global_attribute12 ;
        x_out_rec.global_attribute13 := p_in_rec.global_attribute13 ;
        x_out_rec.global_attribute14 := p_in_rec.global_attribute14 ;
        x_out_rec.global_attribute15 := p_in_rec.global_attribute15 ;
        x_out_rec.global_attribute_category := p_in_rec.global_attribute_category;
      ELSIF  p_disabled_list(i)  = 'FULL'
           OR p_disabled_list(i)  = 'TARE_WEIGHT'       THEN
        NULL;
      ELSE
        -- invalid name
        x_field_name := p_disabled_list(i);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        RETURN;
        --
      END IF;
    END IF;
  END LOOP;
END disable_from_list;

/*
   Procedure populate_external_efl is called from
   enable_from_list to populate the external value
   for a given internal field
*/

PROCEDURE populate_external_efl(
  p_internal        IN   NUMBER
, p_external        IN   VARCHAR2
, p_mode            IN   VARCHAR2
, x_internal        IN OUT  NOCOPY NUMBER
, x_external        IN OUT  NOCOPY VARCHAR2
)
IS
BEGIN

   IF p_mode = '+' THEN
      IF x_internal IS NULL THEN
         IF p_internal <> FND_API.G_MISS_NUM OR p_internal IS NULL THEN
            x_internal := p_internal ;
            IF p_internal IS NULL THEN
               x_external := NULL;
            ELSE
               x_external := p_external;
            END IF;
         ELSIF p_external <> FND_API.G_MISS_CHAR OR p_external IS NULL THEN
            x_external := p_external;
            IF p_external IS NULL THEN
               x_internal := NULL;
            ELSE
               x_internal := p_internal;
            END IF;
         END IF;
      END IF;
   ELSE --p_mode <> +
      IF p_internal <> FND_API.G_MISS_NUM OR p_internal IS NULL THEN
         x_internal := p_internal ;
         IF p_internal IS NULL THEN
            x_external := NULL;
         ELSE
            x_external := p_external;
         END IF;
      ELSIF p_external <> FND_API.G_MISS_CHAR OR p_external IS NULL THEN
         x_external := p_external;
         IF p_external IS NULL THEN
            x_internal := NULL;
         ELSE
            x_internal := p_internal;
         END IF;
      END IF;
   END IF;

END populate_external_efl;

/*
   Procedure populate_external_efl is called from
   enable_from_list to populate the external value
   for a given internal field
*/

PROCEDURE populate_external_efl(
  p_internal        IN   VARCHAR2
, p_external        IN   VARCHAR2
, p_mode            IN   VARCHAR2
, x_internal        IN OUT  NOCOPY VARCHAR2
, x_external        IN OUT  NOCOPY VARCHAR2
)
IS
BEGIN

   IF p_mode = '+' THEN
      IF x_internal IS NULL THEN
         IF p_internal <> FND_API.G_MISS_CHAR OR p_internal IS NULL THEN
            x_internal := p_internal ;
            IF p_internal IS NULL THEN
               x_external := NULL;
            ELSE
               x_external := p_external;
            END IF;
         ELSIF p_external <> FND_API.G_MISS_CHAR OR p_external IS NULL THEN
            x_external := p_external;
            IF p_external IS NULL THEN
               x_internal := NULL;
            ELSE
               x_internal := p_internal;
            END IF;
         END IF;
      END IF;
   ELSE --p_mode <> +
      IF p_internal <> FND_API.G_MISS_CHAR OR p_internal IS NULL THEN
         x_internal := p_internal ;
         IF p_internal IS NULL THEN
            x_external := NULL;
         ELSE
            x_external := p_external;
         END IF;
      ELSIF p_external <> FND_API.G_MISS_CHAR OR p_external IS NULL THEN
         x_external := p_external;
         IF p_external IS NULL THEN
            x_internal := NULL;
         ELSE
            x_internal := p_internal;
         END IF;
      END IF;
   END IF;

END populate_external_efl;


/*----------------------------------------------------------
-- Procedure enable_from_list will update the record x_out_rec for the fields
--   included in p_disabled_list and will enable them
-----------------------------------------------------------*/

PROCEDURE enable_from_list(
  p_disabled_list IN         WSH_UTIL_CORE.column_tab_type
, p_in_rec        IN         WSH_NEW_DELIVERIES_PVT.Delivery_rec_type
, x_out_rec       IN OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_rec_type
, x_return_status OUT NOCOPY         VARCHAR2
, x_field_name    OUT NOCOPY        VARCHAR2

) IS
l_prefix VARCHAR2(1);
BEGIN
  FOR i IN 2..p_disabled_list.COUNT
  LOOP
   l_prefix := SUBSTR(p_disabled_list(i),1,1);
   IF l_prefix = '+' THEN
    IF p_disabled_list(i)  = '+ADDITIONAL_SHIPMENT_INFO' THEN
     IF p_in_rec.ADDITIONAL_SHIPMENT_INFO <> FND_API.G_MISS_CHAR
      OR p_in_rec.ADDITIONAL_SHIPMENT_INFO IS NULL THEN
        IF x_out_rec.ADDITIONAL_SHIPMENT_INFO IS NULL THEN
          x_out_rec.ADDITIONAL_SHIPMENT_INFO := p_in_rec.ADDITIONAL_SHIPMENT_INFO ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+DOCK_CODE' THEN
     IF p_in_rec.DOCK_CODE <> FND_API.G_MISS_CHAR
      OR p_in_rec.DOCK_CODE IS NULL THEN
        IF x_out_rec.DOCK_CODE IS NULL THEN
         x_out_rec.DOCK_CODE := p_in_rec.DOCK_CODE ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+INITIAL_PICKUP_LOCATION_CODE' THEN
     populate_external_efl(p_in_rec.INITIAL_PICKUP_LOCATION_ID,
                           p_in_rec.INITIAL_PICKUP_LOCATION_CODE,
                           '+',
                           x_out_rec.INITIAL_PICKUP_LOCATION_ID,
                           x_out_rec.INITIAL_PICKUP_LOCATION_CODE);

    ELSIF p_disabled_list(i)  = '+ULTIMATE_DROPOFF_LOCATION_CODE' THEN
     populate_external_efl(p_in_rec.ULTIMATE_DROPOFF_LOCATION_ID,
                           p_in_rec.ULTIMATE_DROPOFF_LOCATION_CODE,
                           '+',
                           x_out_rec.ULTIMATE_DROPOFF_LOCATION_ID,
                           x_out_rec.ULTIMATE_DROPOFF_LOCATION_CODE);

    ELSIF p_disabled_list(i)  = '+CUSTOMER_NAME' THEN
     populate_external_efl(p_in_rec.customer_id,
                           p_in_rec.customer_number,
                           '+',
                           x_out_rec.customer_id,
                           x_out_rec.customer_number);

       -- LSP PROJECT
    ELSIF p_disabled_list(i)  = '+CLIENT_NAME' THEN
     populate_external_efl(p_in_rec.client_id,
                           p_in_rec.client_code,
                           '+',
                           x_out_rec.client_id,
                           x_out_rec.client_code);
  -- LSP PROJECT

    ELSIF p_disabled_list(i)  = '+ORGANIZATION_CODE' THEN
     populate_external_efl(p_in_rec.organization_id,
                           p_in_rec.organization_code,
                           '+',
                           x_out_rec.organization_id,
                           x_out_rec.organization_code);

    ELSIF p_disabled_list(i)  = '+LOADING_ORDER_FLAG' THEN
     populate_external_efl(p_in_rec.loading_order_flag,
                           p_in_rec.loading_order_desc,
                           '+',
                           x_out_rec.loading_order_flag,
                           x_out_rec.loading_order_desc);

    ELSIF p_disabled_list(i)  = '+ACCEPTANCE_FLAG' THEN
     IF p_in_rec.ACCEPTANCE_FLAG <> FND_API.G_MISS_CHAR
      OR p_in_rec.ACCEPTANCE_FLAG IS NULL THEN
        IF x_out_rec.ACCEPTANCE_FLAG IS NULL THEN
         x_out_rec.ACCEPTANCE_FLAG := p_in_rec.ACCEPTANCE_FLAG ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+ACCEPTED_BY' THEN
     IF p_in_rec.ACCEPTED_BY <> FND_API.G_MISS_CHAR
      OR p_in_rec.ACCEPTED_BY IS NULL THEN
        IF x_out_rec.ACCEPTED_BY IS NULL THEN
         x_out_rec.ACCEPTED_BY := p_in_rec.ACCEPTED_BY ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+ACCEPTED_DATE' THEN
     IF p_in_rec.ACCEPTED_DATE <> FND_API.G_MISS_DATE
      OR p_in_rec.ACCEPTED_DATE IS NULL THEN
        IF x_out_rec.ACCEPTED_DATE IS NULL THEN
         x_out_rec.ACCEPTED_DATE := p_in_rec.ACCEPTED_DATE ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+ACKNOWLEDGED_BY' THEN
     IF p_in_rec.ACKNOWLEDGED_BY <> FND_API.G_MISS_CHAR
      OR p_in_rec.ACKNOWLEDGED_BY IS NULL THEN
        IF x_out_rec.ACKNOWLEDGED_BY IS NULL THEN
         x_out_rec.ACKNOWLEDGED_BY := p_in_rec.ACKNOWLEDGED_BY ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+CONFIRMED_BY' THEN
     IF p_in_rec.CONFIRMED_BY <> FND_API.G_MISS_CHAR
      OR p_in_rec.CONFIRMED_BY IS NULL THEN
        IF x_out_rec.CONFIRMED_BY IS NULL THEN
         x_out_rec.CONFIRMED_BY := p_in_rec.CONFIRMED_BY ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+CURRENCY_CODE' THEN
     populate_external_efl(p_in_rec.currency_code,
                           p_in_rec.currency_name,
                           '+',
                           x_out_rec.currency_code,
                           x_out_rec.currency_name);

    ELSIF p_disabled_list(i)  = '+INITIAL_PICKUP_DATE' THEN
     IF p_in_rec.INITIAL_PICKUP_DATE <> FND_API.G_MISS_DATE
      OR p_in_rec.INITIAL_PICKUP_DATE IS NULL THEN
        IF x_out_rec.INITIAL_PICKUP_DATE IS NULL THEN
         x_out_rec.INITIAL_PICKUP_DATE := p_in_rec.INITIAL_PICKUP_DATE ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+ULTIMATE_DROPOFF_DATE' THEN
     IF p_in_rec.ULTIMATE_DROPOFF_DATE <> FND_API.G_MISS_DATE
      OR p_in_rec.ULTIMATE_DROPOFF_DATE IS NULL THEN
        IF x_out_rec.ULTIMATE_DROPOFF_DATE IS NULL THEN
         x_out_rec.ULTIMATE_DROPOFF_DATE := p_in_rec.ULTIMATE_DROPOFF_DATE ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+LOADING_SEQUENCE' THEN
     IF p_in_rec.LOADING_SEQUENCE <> FND_API.G_MISS_NUM
      OR p_in_rec.LOADING_SEQUENCE IS NULL THEN
        IF x_out_rec.LOADING_SEQUENCE IS NULL THEN
         x_out_rec.LOADING_SEQUENCE := p_in_rec.LOADING_SEQUENCE ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+SHIP_METHOD_NAME' THEN
     populate_external_efl(p_in_rec.ship_method_code,
                           p_in_rec.ship_method_name,
                           '+',
                           x_out_rec.ship_method_code,
                           x_out_rec.ship_method_name);
    ELSIF p_disabled_list(i)  = '+FREIGHT_CODE' THEN
       NULL;
     -- J-IB-NPARIKH-{ --I-bug-fix
     populate_external_efl(p_in_rec.carrier_id,
                           p_in_rec.carrier_code,
                           '+',
                           x_out_rec.carrier_id,
                           x_out_rec.carrier_code);
     -- J-IB-NPARIKH-}

    ELSIF p_disabled_list(i)  = '+SERVICE_LEVEL_NAME' THEN
     IF p_in_rec.SERVICE_LEVEL <> FND_API.G_MISS_CHAR
      OR p_in_rec.SERVICE_LEVEL IS NULL THEN
        IF x_out_rec.SERVICE_LEVEL IS NULL THEN
         x_out_rec.SERVICE_LEVEL := p_in_rec.SERVICE_LEVEL ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+MODE_OF_TRANSPORT_NAME' THEN
     IF p_in_rec.MODE_OF_TRANSPORT <> FND_API.G_MISS_CHAR
      OR p_in_rec.MODE_OF_TRANSPORT IS NULL THEN
        IF x_out_rec.MODE_OF_TRANSPORT IS NULL THEN
         x_out_rec.MODE_OF_TRANSPORT := p_in_rec.MODE_OF_TRANSPORT ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+NAME' THEN
     IF p_in_rec.NAME <> FND_API.G_MISS_CHAR
      OR p_in_rec.NAME IS NULL THEN
        IF x_out_rec.NAME IS NULL THEN
         x_out_rec.NAME := p_in_rec.NAME ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+INTMED_SHIP_TO_LOCATION_CODE' THEN
     populate_external_efl(p_in_rec.INTMED_SHIP_TO_LOCATION_ID,
                           p_in_rec.INTMED_SHIP_TO_LOCATION_CODE,
                           '+',
                           x_out_rec.INTMED_SHIP_TO_LOCATION_ID,
                           x_out_rec.INTMED_SHIP_TO_LOCATION_CODE);

    ELSIF p_disabled_list(i)  = '+POOLED_SHIP_TO_LOCATION_CODE' THEN
     populate_external_efl(p_in_rec.POOLED_SHIP_TO_LOCATION_ID,
                           p_in_rec.POOLED_SHIP_TO_LOCATION_CODE,
                           '+',
                           x_out_rec.POOLED_SHIP_TO_LOCATION_ID,
                           x_out_rec.POOLED_SHIP_TO_LOCATION_CODE);

    ELSIF p_disabled_list(i)  = '+WAYBILL' THEN
     IF p_in_rec.WAYBILL <> FND_API.G_MISS_CHAR
      OR p_in_rec.WAYBILL IS NULL THEN
        IF x_out_rec.WAYBILL IS NULL THEN
         x_out_rec.WAYBILL := p_in_rec.WAYBILL ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+FREIGHT_TERMS_NAME' THEN
     populate_external_efl(p_in_rec.FREIGHT_TERMS_CODE,
                           p_in_rec.FREIGHT_TERMS_NAME,
                           '+',
                           x_out_rec.FREIGHT_TERMS_CODE,
                           x_out_rec.FREIGHT_TERMS_NAME);

    ELSIF p_disabled_list(i)  = '+GROSS_WEIGHT' THEN
     IF p_in_rec.GROSS_WEIGHT <> FND_API.G_MISS_NUM
      OR p_in_rec.GROSS_WEIGHT IS NULL THEN
        IF x_out_rec.GROSS_WEIGHT IS NULL THEN
         x_out_rec.GROSS_WEIGHT := p_in_rec.GROSS_WEIGHT ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+NET_WEIGHT' THEN
     IF p_in_rec.NET_WEIGHT <> FND_API.G_MISS_NUM
      OR p_in_rec.NET_WEIGHT IS NULL THEN
        IF x_out_rec.NET_WEIGHT IS NULL THEN
         x_out_rec.NET_WEIGHT := p_in_rec.NET_WEIGHT ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+WEIGHT_UOM_CODE' THEN
     populate_external_efl(p_in_rec.WEIGHT_UOM_CODE,
                           p_in_rec.WEIGHT_UOM_DESC,
                           '+',
                           x_out_rec.WEIGHT_UOM_CODE,
                           x_out_rec.WEIGHT_UOM_DESC);

    ELSIF p_disabled_list(i)  = '+VOLUME' THEN
     IF p_in_rec.VOLUME <> FND_API.G_MISS_NUM
      OR p_in_rec.VOLUME IS NULL THEN
        IF x_out_rec.VOLUME IS NULL THEN
         x_out_rec.VOLUME := p_in_rec.VOLUME ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+VOLUME_UOM_CODE' THEN
     populate_external_efl(p_in_rec.VOLUME_UOM_CODE,
                           p_in_rec.VOLUME_UOM_DESC,
                           '+',
                           x_out_rec.VOLUME_UOM_CODE,
                           x_out_rec.VOLUME_UOM_DESC);

    ELSIF p_disabled_list(i)  = '+FOB_NAME' THEN
     populate_external_efl(p_in_rec.FOB_CODE,
                           p_in_rec.FOB_NAME,
                           '+',
                           x_out_rec.FOB_CODE,
                           x_out_rec.FOB_NAME);

    ELSIF p_disabled_list(i)  = '+FOB_LOCATION_CODE' THEN
     populate_external_efl(p_in_rec.FOB_LOCATION_ID,
                           p_in_rec.FOB_LOCATION_CODE,
                           '+',
                           x_out_rec.FOB_LOCATION_ID,
                           x_out_rec.FOB_LOCATION_CODE);

    ELSIF p_disabled_list(i)  = '+NUMBER_OF_LPN' THEN
     IF p_in_rec.NUMBER_OF_LPN <> FND_API.G_MISS_NUM
      OR p_in_rec.NUMBER_OF_LPN IS NULL THEN
        IF x_out_rec.NUMBER_OF_LPN IS NULL THEN
         x_out_rec.NUMBER_OF_LPN := p_in_rec.NUMBER_OF_LPN ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+AUTO_SC_EXCLUDE_FLAG' THEN
     IF p_in_rec.AUTO_SC_EXCLUDE_FLAG <> FND_API.G_MISS_CHAR
      OR p_in_rec.AUTO_SC_EXCLUDE_FLAG IS NULL THEN
        IF x_out_rec.AUTO_SC_EXCLUDE_FLAG IS NULL THEN
         x_out_rec.AUTO_SC_EXCLUDE_FLAG := p_in_rec.AUTO_SC_EXCLUDE_FLAG ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+AUTO_AP_EXCLUDE_FLAG' THEN
     IF p_in_rec.AUTO_AP_EXCLUDE_FLAG <> FND_API.G_MISS_CHAR
      OR p_in_rec.AUTO_AP_EXCLUDE_FLAG IS NULL THEN
        IF x_out_rec.AUTO_AP_EXCLUDE_FLAG IS NULL THEN
         x_out_rec.AUTO_AP_EXCLUDE_FLAG := p_in_rec.AUTO_AP_EXCLUDE_FLAG ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+DESC_FLEX' THEN
     IF p_in_rec.attribute1 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute1 IS NULL THEN
        IF x_out_rec.attribute1 IS NULL THEN
         x_out_rec.attribute1 := p_in_rec.attribute1 ;
        END IF;
     END IF;
     IF p_in_rec.attribute2 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute2 IS NULL THEN
        IF x_out_rec.attribute2 IS NULL THEN
         x_out_rec.attribute2 := p_in_rec.attribute2 ;
        END IF;
     END IF;
     IF p_in_rec.attribute3 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute3 IS NULL THEN
        IF x_out_rec.attribute3 IS NULL THEN
         x_out_rec.attribute3 := p_in_rec.attribute3 ;
        END IF;
     END IF;
     IF p_in_rec.attribute4 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute4 IS NULL THEN
        IF x_out_rec.attribute4 IS NULL THEN
         x_out_rec.attribute4 := p_in_rec.attribute4 ;
        END IF;
     END IF;
     IF p_in_rec.attribute5 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute5 IS NULL THEN
        IF x_out_rec.attribute5 IS NULL THEN
         x_out_rec.attribute5 := p_in_rec.attribute5 ;
        END IF;
     END IF;
     IF p_in_rec.attribute6 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute6 IS NULL THEN
        IF x_out_rec.attribute6 IS NULL THEN
         x_out_rec.attribute6 := p_in_rec.attribute6 ;
        END IF;
     END IF;
     IF p_in_rec.attribute7 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute7 IS NULL THEN
        IF x_out_rec.attribute7 IS NULL THEN
         x_out_rec.attribute7 := p_in_rec.attribute7 ;
        END IF;
     END IF;
     IF p_in_rec.attribute8 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute8 IS NULL THEN
        IF x_out_rec.attribute8 IS NULL THEN
         x_out_rec.attribute8 := p_in_rec.attribute8 ;
        END IF;
     END IF;
     IF p_in_rec.attribute9 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute9 IS NULL THEN
        IF x_out_rec.attribute9 IS NULL THEN
         x_out_rec.attribute9 := p_in_rec.attribute9 ;
        END IF;
     END IF;
     IF p_in_rec.attribute10 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute10 IS NULL THEN
        IF x_out_rec.attribute10 IS NULL THEN
         x_out_rec.attribute10 := p_in_rec.attribute10 ;
        END IF;
     END IF;
     IF p_in_rec.attribute11 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute11 IS NULL THEN
        IF x_out_rec.attribute11 IS NULL THEN
         x_out_rec.attribute11 := p_in_rec.attribute11 ;
        END IF;
     END IF;
     IF p_in_rec.attribute12 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute12 IS NULL THEN
        IF x_out_rec.attribute12 IS NULL THEN
         x_out_rec.attribute12 := p_in_rec.attribute12 ;
        END IF;
     END IF;
     IF p_in_rec.attribute13 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute13 IS NULL THEN
        IF x_out_rec.attribute13 IS NULL THEN
         x_out_rec.attribute13 := p_in_rec.attribute13 ;
        END IF;
     END IF;
     IF p_in_rec.attribute14 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute14 IS NULL THEN
        IF x_out_rec.attribute14 IS NULL THEN
         x_out_rec.attribute14 := p_in_rec.attribute14 ;
        END IF;
     END IF;
     IF p_in_rec.attribute15 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute15 IS NULL THEN
        IF x_out_rec.attribute15 IS NULL THEN
         x_out_rec.attribute15 := p_in_rec.attribute15 ;
        END IF;
     END IF;
     IF p_in_rec.attribute_category <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute_category IS NULL THEN
        IF x_out_rec.attribute_category IS NULL THEN
         x_out_rec.attribute_category := p_in_rec.attribute_category ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+TP_FLEXFIELD' THEN
     IF p_in_rec.tp_attribute1 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute1 IS NULL THEN
        IF x_out_rec.tp_attribute1 IS NULL THEN
         x_out_rec.tp_attribute1 := p_in_rec.tp_attribute1 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute2 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute2 IS NULL THEN
        IF x_out_rec.tp_attribute2 IS NULL THEN
         x_out_rec.tp_attribute2 := p_in_rec.tp_attribute2 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute3 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute3 IS NULL THEN
        IF x_out_rec.tp_attribute3 IS NULL THEN
         x_out_rec.tp_attribute3 := p_in_rec.tp_attribute3 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute4 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute4 IS NULL THEN
        IF x_out_rec.tp_attribute4 IS NULL THEN
         x_out_rec.tp_attribute4 := p_in_rec.tp_attribute4 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute5 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute5 IS NULL THEN
        IF x_out_rec.tp_attribute5 IS NULL THEN
         x_out_rec.tp_attribute5 := p_in_rec.tp_attribute5 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute6 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute6 IS NULL THEN
        IF x_out_rec.tp_attribute6 IS NULL THEN
         x_out_rec.tp_attribute6 := p_in_rec.tp_attribute6 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute7 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute7 IS NULL THEN
        IF x_out_rec.tp_attribute7 IS NULL THEN
         x_out_rec.tp_attribute7 := p_in_rec.tp_attribute7 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute8 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute8 IS NULL THEN
        IF x_out_rec.tp_attribute8 IS NULL THEN
         x_out_rec.tp_attribute8 := p_in_rec.tp_attribute8 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute9 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute9 IS NULL THEN
        IF x_out_rec.tp_attribute9 IS NULL THEN
         x_out_rec.tp_attribute9 := p_in_rec.tp_attribute9 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute10 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute10 IS NULL THEN
        IF x_out_rec.tp_attribute10 IS NULL THEN
         x_out_rec.tp_attribute10 := p_in_rec.tp_attribute10 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute11 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute11 IS NULL THEN
        IF x_out_rec.tp_attribute11 IS NULL THEN
         x_out_rec.tp_attribute11 := p_in_rec.tp_attribute11 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute12 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute12 IS NULL THEN
        IF x_out_rec.tp_attribute12 IS NULL THEN
         x_out_rec.tp_attribute12 := p_in_rec.tp_attribute12 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute13 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute13 IS NULL THEN
        IF x_out_rec.tp_attribute13 IS NULL THEN
         x_out_rec.tp_attribute13 := p_in_rec.tp_attribute13 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute14 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute14 IS NULL THEN
        IF x_out_rec.tp_attribute14 IS NULL THEN
         x_out_rec.tp_attribute14 := p_in_rec.tp_attribute14 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute15 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute15 IS NULL THEN
        IF x_out_rec.tp_attribute15 IS NULL THEN
         x_out_rec.tp_attribute15 := p_in_rec.tp_attribute15 ;
        END IF;
     END IF;
     IF p_in_rec.tp_attribute_category <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute_category IS NULL THEN
        IF x_out_rec.tp_attribute_category IS NULL THEN
         x_out_rec.tp_attribute_category := p_in_rec.tp_attribute_category ;
        END IF;
     END IF;
    ELSIF p_disabled_list(i)  = '+GLOBALIZATION_FLEXFIELD' THEN
     IF p_in_rec.global_attribute1 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute1 IS NULL THEN
        IF x_out_rec.global_attribute1 IS NULL THEN
         x_out_rec.global_attribute1 := p_in_rec.global_attribute1 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute2 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute2 IS NULL THEN
        IF x_out_rec.global_attribute2 IS NULL THEN
         x_out_rec.global_attribute2 := p_in_rec.global_attribute2 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute3 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute3 IS NULL THEN
        IF x_out_rec.global_attribute3 IS NULL THEN
         x_out_rec.global_attribute3 := p_in_rec.global_attribute3 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute4 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute4 IS NULL THEN
        IF x_out_rec.global_attribute4 IS NULL THEN
         x_out_rec.global_attribute4 := p_in_rec.global_attribute4 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute5 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute5 IS NULL THEN
        IF x_out_rec.global_attribute5 IS NULL THEN
         x_out_rec.global_attribute5 := p_in_rec.global_attribute5 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute6 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute6 IS NULL THEN
        IF x_out_rec.global_attribute6 IS NULL THEN
         x_out_rec.global_attribute6 := p_in_rec.global_attribute6 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute7 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute7 IS NULL THEN
        IF x_out_rec.global_attribute7 IS NULL THEN
         x_out_rec.global_attribute7 := p_in_rec.global_attribute7 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute8 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute8 IS NULL THEN
        IF x_out_rec.global_attribute8 IS NULL THEN
         x_out_rec.global_attribute8 := p_in_rec.global_attribute8 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute9 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute9 IS NULL THEN
        IF x_out_rec.global_attribute9 IS NULL THEN
         x_out_rec.global_attribute9 := p_in_rec.global_attribute9 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute10 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute10 IS NULL THEN
        IF x_out_rec.global_attribute10 IS NULL THEN
         x_out_rec.global_attribute10 := p_in_rec.global_attribute10 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute11 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute11 IS NULL THEN
        IF x_out_rec.global_attribute11 IS NULL THEN
         x_out_rec.global_attribute11 := p_in_rec.global_attribute11 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute12 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute12 IS NULL THEN
        IF x_out_rec.global_attribute12 IS NULL THEN
         x_out_rec.global_attribute12 := p_in_rec.global_attribute12 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute13 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute13 IS NULL THEN
        IF x_out_rec.global_attribute13 IS NULL THEN
         x_out_rec.global_attribute13 := p_in_rec.global_attribute13 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute14 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute14 IS NULL THEN
        IF x_out_rec.global_attribute14 IS NULL THEN
         x_out_rec.global_attribute14 := p_in_rec.global_attribute14 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute15 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute15 IS NULL THEN
        IF x_out_rec.global_attribute15 IS NULL THEN
         x_out_rec.global_attribute15 := p_in_rec.global_attribute15 ;
        END IF;
     END IF;
     IF p_in_rec.global_attribute_category <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute_category IS NULL THEN
        IF x_out_rec.global_attribute_category IS NULL THEN
         x_out_rec.global_attribute_category := p_in_rec.global_attribute_category ;
        END IF;
     END IF;
    ELSIF   p_disabled_list(i)  = 'TARE_WEIGHT'       THEN
      NULL;
    ELSE
      -- invalid name
      x_field_name := p_disabled_list(i);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      RETURN;
     END IF;
    ELSE -- if the prefix is not +
    IF p_disabled_list(i)  = 'ADDITIONAL_SHIPMENT_INFO' THEN
     IF p_in_rec.ADDITIONAL_SHIPMENT_INFO <> FND_API.G_MISS_CHAR
      OR p_in_rec.ADDITIONAL_SHIPMENT_INFO IS NULL THEN
          x_out_rec.ADDITIONAL_SHIPMENT_INFO := p_in_rec.ADDITIONAL_SHIPMENT_INFO ;
     END IF;
    ELSIF p_disabled_list(i)  = 'DOCK_CODE' THEN
     IF p_in_rec.DOCK_CODE <> FND_API.G_MISS_CHAR
      OR p_in_rec.DOCK_CODE IS NULL THEN
         x_out_rec.DOCK_CODE := p_in_rec.DOCK_CODE ;
     END IF;
    ELSIF p_disabled_list(i)  = 'INITIAL_PICKUP_LOCATION_CODE' THEN
      populate_external_efl(p_in_rec.INITIAL_PICKUP_LOCATION_ID,
                           p_in_rec.INITIAL_PICKUP_LOCATION_CODE,
                           NULL,
                           x_out_rec.INITIAL_PICKUP_LOCATION_ID,
                           x_out_rec.INITIAL_PICKUP_LOCATION_CODE);
    ELSIF p_disabled_list(i)  = 'ULTIMATE_DROPOFF_LOCATION_CODE' THEN
     populate_external_efl(p_in_rec.ULTIMATE_DROPOFF_LOCATION_ID,
                           p_in_rec.ULTIMATE_DROPOFF_LOCATION_CODE,
                           NULL,
                           x_out_rec.ULTIMATE_DROPOFF_LOCATION_ID,
                           x_out_rec.ULTIMATE_DROPOFF_LOCATION_CODE);
    ELSIF p_disabled_list(i)  = 'CUSTOMER_NAME' THEN
     populate_external_efl(p_in_rec.customer_id,
                           p_in_rec.customer_number,
                           NULL,
                           x_out_rec.customer_id,
                           x_out_rec.customer_number);
   -- LSP PROJECT :
   ELSIF p_disabled_list(i)  = 'CLIENT_NAME' THEN
     populate_external_efl(p_in_rec.client_id,
                           p_in_rec.client_code,
                           NULL,
                           x_out_rec.client_id,
                           x_out_rec.client_code);

    ELSIF p_disabled_list(i)  = 'ORGANIZATION_CODE' THEN
     populate_external_efl(p_in_rec.organization_id,
                           p_in_rec.organization_code,
                           NULL,
                           x_out_rec.organization_id,
                           x_out_rec.organization_code);
    ELSIF p_disabled_list(i)  = 'LOADING_ORDER_FLAG' THEN
     populate_external_efl(p_in_rec.loading_order_flag,
                           p_in_rec.loading_order_desc,
                           NULL,
                           x_out_rec.loading_order_flag,
                           x_out_rec.loading_order_desc);
    ELSIF p_disabled_list(i)  = 'ACCEPTANCE_FLAG' THEN
     IF p_in_rec.ACCEPTANCE_FLAG <> FND_API.G_MISS_CHAR
      OR p_in_rec.ACCEPTANCE_FLAG IS NULL THEN
         x_out_rec.ACCEPTANCE_FLAG := p_in_rec.ACCEPTANCE_FLAG ;
     END IF;
    ELSIF p_disabled_list(i)  = 'ACCEPTED_BY' THEN
     IF p_in_rec.ACCEPTED_BY <> FND_API.G_MISS_CHAR
      OR p_in_rec.ACCEPTED_BY IS NULL THEN
         x_out_rec.ACCEPTED_BY := p_in_rec.ACCEPTED_BY ;
     END IF;
    ELSIF p_disabled_list(i)  = 'ACCEPTED_DATE' THEN
     IF p_in_rec.ACCEPTED_DATE <> FND_API.G_MISS_DATE
      OR p_in_rec.ACCEPTED_DATE IS NULL THEN
         x_out_rec.ACCEPTED_DATE := p_in_rec.ACCEPTED_DATE ;
     END IF;
    ELSIF p_disabled_list(i)  = 'ACKNOWLEDGED_BY' THEN
     IF p_in_rec.ACKNOWLEDGED_BY <> FND_API.G_MISS_CHAR
      OR p_in_rec.ACKNOWLEDGED_BY IS NULL THEN
         x_out_rec.ACKNOWLEDGED_BY := p_in_rec.ACKNOWLEDGED_BY ;
     END IF;
    ELSIF p_disabled_list(i)  = 'CONFIRMED_BY' THEN
     IF p_in_rec.CONFIRMED_BY <> FND_API.G_MISS_CHAR
      OR p_in_rec.CONFIRMED_BY IS NULL THEN
         x_out_rec.CONFIRMED_BY := p_in_rec.CONFIRMED_BY ;
     END IF;
    ELSIF p_disabled_list(i)  = 'CURRENCY_CODE' THEN
     populate_external_efl(p_in_rec.currency_code,
                           p_in_rec.currency_name,
                           NULL,
                           x_out_rec.currency_code,
                           x_out_rec.currency_name);
    ELSIF p_disabled_list(i)  = 'INITIAL_PICKUP_DATE' THEN
     IF p_in_rec.INITIAL_PICKUP_DATE <> FND_API.G_MISS_DATE
      OR p_in_rec.INITIAL_PICKUP_DATE IS NULL THEN
         x_out_rec.INITIAL_PICKUP_DATE := p_in_rec.INITIAL_PICKUP_DATE ;
     END IF;
    ELSIF p_disabled_list(i)  = 'ULTIMATE_DROPOFF_DATE' THEN
     IF p_in_rec.ULTIMATE_DROPOFF_DATE <> FND_API.G_MISS_DATE
      OR p_in_rec.ULTIMATE_DROPOFF_DATE IS NULL THEN
         x_out_rec.ULTIMATE_DROPOFF_DATE := p_in_rec.ULTIMATE_DROPOFF_DATE ;
     END IF;
    ELSIF p_disabled_list(i)  = 'LOADING_SEQUENCE' THEN
     IF p_in_rec.LOADING_SEQUENCE <> FND_API.G_MISS_NUM
      OR p_in_rec.LOADING_SEQUENCE IS NULL THEN
         x_out_rec.LOADING_SEQUENCE := p_in_rec.LOADING_SEQUENCE ;
     END IF;
    ELSIF p_disabled_list(i)  = 'SHIP_METHOD_NAME' THEN
     populate_external_efl(p_in_rec.ship_method_code,
                           p_in_rec.ship_method_name,
                           NULL,
                           x_out_rec.ship_method_code,
                           x_out_rec.ship_method_name);

    ELSIF p_disabled_list(i)  = 'FREIGHT_CODE' THEN
       NULL;
     -- J-IB-NPARIKH-{
     populate_external_efl(p_in_rec.carrier_id,
                           p_in_rec.carrier_code,
                           NULL,
                           x_out_rec.carrier_id,
                           x_out_rec.carrier_code);
     -- J-IB-NPARIKH-}
    ELSIF p_disabled_list(i)  = 'SERVICE_LEVEL_NAME' THEN
     IF p_in_rec.SERVICE_LEVEL <> FND_API.G_MISS_CHAR
      OR p_in_rec.SERVICE_LEVEL IS NULL THEN
         x_out_rec.SERVICE_LEVEL := p_in_rec.SERVICE_LEVEL ;
     END IF;
    ELSIF p_disabled_list(i)  = 'MODE_OF_TRANSPORT_NAME' THEN
     IF p_in_rec.MODE_OF_TRANSPORT <> FND_API.G_MISS_CHAR
      OR p_in_rec.MODE_OF_TRANSPORT IS NULL THEN
         x_out_rec.MODE_OF_TRANSPORT := p_in_rec.MODE_OF_TRANSPORT ;
     END IF;
    ELSIF p_disabled_list(i)  = 'NAME' THEN
     IF p_in_rec.NAME <> FND_API.G_MISS_CHAR
      OR p_in_rec.NAME IS NULL THEN
         x_out_rec.NAME := p_in_rec.NAME ;
     END IF;
    ELSIF p_disabled_list(i)  = 'INTMED_SHIP_TO_LOCATION_CODE' THEN
     populate_external_efl(p_in_rec.INTMED_SHIP_TO_LOCATION_ID,
                           p_in_rec.INTMED_SHIP_TO_LOCATION_CODE,
                           NULL,
                           x_out_rec.INTMED_SHIP_TO_LOCATION_ID,
                           x_out_rec.INTMED_SHIP_TO_LOCATION_CODE);
    ELSIF p_disabled_list(i)  = 'POOLED_SHIP_TO_LOCATION_CODE' THEN
     populate_external_efl(p_in_rec.POOLED_SHIP_TO_LOCATION_ID,
                           p_in_rec.POOLED_SHIP_TO_LOCATION_CODE,
                           NULL,
                           x_out_rec.POOLED_SHIP_TO_LOCATION_ID,
                           x_out_rec.POOLED_SHIP_TO_LOCATION_CODE);
    ELSIF p_disabled_list(i)  = 'WAYBILL' THEN
     IF p_in_rec.WAYBILL <> FND_API.G_MISS_CHAR
      OR p_in_rec.WAYBILL IS NULL THEN
         x_out_rec.WAYBILL := p_in_rec.WAYBILL ;
     END IF;
    ELSIF p_disabled_list(i)  = 'FREIGHT_TERMS_NAME' THEN
     populate_external_efl(p_in_rec.FREIGHT_TERMS_CODE,
                           p_in_rec.FREIGHT_TERMS_NAME,
                           NULL,
                           x_out_rec.FREIGHT_TERMS_CODE,
                           x_out_rec.FREIGHT_TERMS_NAME);
    ELSIF p_disabled_list(i)  = 'GROSS_WEIGHT' THEN
     IF p_in_rec.GROSS_WEIGHT <> FND_API.G_MISS_NUM
      OR p_in_rec.GROSS_WEIGHT IS NULL THEN
         x_out_rec.GROSS_WEIGHT := p_in_rec.GROSS_WEIGHT ;
     END IF;
    ELSIF p_disabled_list(i)  = 'NET_WEIGHT' THEN
     IF p_in_rec.NET_WEIGHT <> FND_API.G_MISS_NUM
      OR p_in_rec.NET_WEIGHT IS NULL THEN
         x_out_rec.NET_WEIGHT := p_in_rec.NET_WEIGHT ;
     END IF;
-- Non Database field prorate_wt_flag added for "Proration of weight from Delivery to delivery lines" Project(Bug#4254552).
    ELSIF p_disabled_list(i)  = 'PRORATE_WT_FLAG' THEN
        -- Bug#4539613 :  replaced FND_API.G_MISS_NUM   by FND_API.G_MISS_CHAR
        IF p_in_rec.PRORATE_WT_FLAG <> FND_API.G_MISS_CHAR  OR p_in_rec.PRORATE_WT_FLAG IS NULL THEN
            x_out_rec.PRORATE_WT_FLAG := p_in_rec.PRORATE_WT_FLAG ;
        END IF;
--
    ELSIF p_disabled_list(i)  = 'WEIGHT_UOM_CODE' THEN
     populate_external_efl(p_in_rec.WEIGHT_UOM_CODE,
                           p_in_rec.WEIGHT_UOM_DESC,
                           NULL,
                           x_out_rec.WEIGHT_UOM_CODE,
                           x_out_rec.WEIGHT_UOM_DESC);

    ELSIF p_disabled_list(i)  = 'VOLUME' THEN
     IF p_in_rec.VOLUME <> FND_API.G_MISS_NUM
      OR p_in_rec.VOLUME IS NULL THEN
         x_out_rec.VOLUME := p_in_rec.VOLUME ;
     END IF;
    ELSIF p_disabled_list(i)  = 'VOLUME_UOM_CODE' THEN
     populate_external_efl(p_in_rec.VOLUME_UOM_CODE,
                           p_in_rec.VOLUME_UOM_DESC,
                           NULL,
                           x_out_rec.VOLUME_UOM_CODE,
                           x_out_rec.VOLUME_UOM_DESC);
    ELSIF p_disabled_list(i)  = 'FOB_NAME' THEN
     populate_external_efl(p_in_rec.FOB_CODE,
                           p_in_rec.FOB_NAME,
                           NULL,
                           x_out_rec.FOB_CODE,
                           x_out_rec.FOB_NAME);
    ELSIF p_disabled_list(i)  = 'FOB_LOCATION_CODE' THEN
     populate_external_efl(p_in_rec.FOB_LOCATION_ID,
                           p_in_rec.FOB_LOCATION_CODE,
                           NULL,
                           x_out_rec.FOB_LOCATION_ID,
                           x_out_rec.FOB_LOCATION_CODE);
    ELSIF p_disabled_list(i)  = 'NUMBER_OF_LPN' THEN
     IF p_in_rec.NUMBER_OF_LPN <> FND_API.G_MISS_NUM
      OR p_in_rec.NUMBER_OF_LPN IS NULL THEN
         x_out_rec.NUMBER_OF_LPN := p_in_rec.NUMBER_OF_LPN ;
     END IF;
    ELSIF p_disabled_list(i)  = 'AUTO_SC_EXCLUDE_FLAG' THEN
     IF p_in_rec.AUTO_SC_EXCLUDE_FLAG <> FND_API.G_MISS_CHAR
      OR p_in_rec.AUTO_SC_EXCLUDE_FLAG IS NULL THEN
         x_out_rec.AUTO_SC_EXCLUDE_FLAG := p_in_rec.AUTO_SC_EXCLUDE_FLAG ;
     END IF;
    ELSIF p_disabled_list(i)  = 'AUTO_AP_EXCLUDE_FLAG' THEN
     IF p_in_rec.AUTO_AP_EXCLUDE_FLAG <> FND_API.G_MISS_CHAR
      OR p_in_rec.AUTO_AP_EXCLUDE_FLAG IS NULL THEN
         x_out_rec.AUTO_AP_EXCLUDE_FLAG := p_in_rec.AUTO_AP_EXCLUDE_FLAG ;
     END IF;
    ELSIF p_disabled_list(i)  = 'DESC_FLEX' THEN
     IF p_in_rec.attribute1 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute1  IS NULL THEN
      x_out_rec.attribute1 := p_in_rec.attribute1 ;
     END IF;
     IF p_in_rec.attribute2 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute2  IS NULL THEN
      x_out_rec.attribute2 := p_in_rec.attribute2 ;
     END IF;
     IF p_in_rec.attribute3 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute3  IS NULL THEN
      x_out_rec.attribute3 := p_in_rec.attribute3 ;
     END IF;
     IF p_in_rec.attribute4 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute4  IS NULL THEN
      x_out_rec.attribute4 := p_in_rec.attribute4 ;
     END IF;
     IF p_in_rec.attribute5 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute5  IS NULL THEN
      x_out_rec.attribute5 := p_in_rec.attribute5 ;
     END IF;
     IF p_in_rec.attribute6 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute6  IS NULL THEN
      x_out_rec.attribute6 := p_in_rec.attribute6 ;
     END IF;
     IF p_in_rec.attribute7 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute7  IS NULL THEN
      x_out_rec.attribute7 := p_in_rec.attribute7 ;
     END IF;
     IF p_in_rec.attribute8 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute8  IS NULL THEN
      x_out_rec.attribute8 := p_in_rec.attribute8 ;
     END IF;
     IF p_in_rec.attribute9 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute9  IS NULL THEN
      x_out_rec.attribute9 := p_in_rec.attribute9 ;
     END IF;
     IF p_in_rec.attribute10 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute10  IS NULL THEN
      x_out_rec.attribute10 := p_in_rec.attribute10 ;
     END IF;
     IF p_in_rec.attribute11 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute11  IS NULL THEN
      x_out_rec.attribute11 := p_in_rec.attribute11 ;
     END IF;
     IF p_in_rec.attribute12 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute12  IS NULL THEN
      x_out_rec.attribute12 := p_in_rec.attribute12 ;
     END IF;
     IF p_in_rec.attribute13 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute13  IS NULL THEN
      x_out_rec.attribute13 := p_in_rec.attribute13 ;
     END IF;
     IF p_in_rec.attribute14 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute14  IS NULL THEN
      x_out_rec.attribute14 := p_in_rec.attribute14 ;
     END IF;
     IF p_in_rec.attribute15 <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute15  IS NULL THEN
      x_out_rec.attribute15 := p_in_rec.attribute15 ;
     END IF;
     IF p_in_rec.attribute_category <> FND_API.G_MISS_CHAR
      OR p_in_rec.attribute_category  IS NULL THEN
      x_out_rec.attribute_category := p_in_rec.attribute_category ;
     END IF;
    ELSIF p_disabled_list(i)  = 'TP_FLEXFIELD' THEN
     IF p_in_rec.tp_attribute1 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute1  IS NULL THEN
      x_out_rec.tp_attribute1 := p_in_rec.tp_attribute1 ;
     END IF;
     IF p_in_rec.tp_attribute2 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute2  IS NULL THEN
      x_out_rec.tp_attribute2 := p_in_rec.tp_attribute2 ;
     END IF;
     IF p_in_rec.tp_attribute3 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute3  IS NULL THEN
      x_out_rec.tp_attribute3 := p_in_rec.tp_attribute3 ;
     END IF;
     IF p_in_rec.tp_attribute4 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute4  IS NULL THEN
      x_out_rec.tp_attribute4 := p_in_rec.tp_attribute4 ;
     END IF;
     IF p_in_rec.tp_attribute5 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute5  IS NULL THEN
      x_out_rec.tp_attribute5 := p_in_rec.tp_attribute5 ;
     END IF;
     IF p_in_rec.tp_attribute6 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute6  IS NULL THEN
      x_out_rec.tp_attribute6 := p_in_rec.tp_attribute6 ;
     END IF;
     IF p_in_rec.tp_attribute7 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute7  IS NULL THEN
      x_out_rec.tp_attribute7 := p_in_rec.tp_attribute7 ;
     END IF;
     IF p_in_rec.tp_attribute8 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute8  IS NULL THEN
      x_out_rec.tp_attribute8 := p_in_rec.tp_attribute8 ;
     END IF;
     IF p_in_rec.tp_attribute9 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute9  IS NULL THEN
      x_out_rec.tp_attribute9 := p_in_rec.tp_attribute9 ;
     END IF;
     IF p_in_rec.tp_attribute10 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute10  IS NULL THEN
      x_out_rec.tp_attribute10 := p_in_rec.tp_attribute10 ;
     END IF;
     IF p_in_rec.tp_attribute11 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute11  IS NULL THEN
      x_out_rec.tp_attribute11 := p_in_rec.tp_attribute11 ;
     END IF;
     IF p_in_rec.tp_attribute12 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute12  IS NULL THEN
      x_out_rec.tp_attribute12 := p_in_rec.tp_attribute12 ;
     END IF;
     IF p_in_rec.tp_attribute13 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute13  IS NULL THEN
      x_out_rec.tp_attribute13 := p_in_rec.tp_attribute13 ;
     END IF;
     IF p_in_rec.tp_attribute14 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute14  IS NULL THEN
      x_out_rec.tp_attribute14 := p_in_rec.tp_attribute14 ;
     END IF;
     IF p_in_rec.tp_attribute15 <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute15  IS NULL THEN
      x_out_rec.tp_attribute15 := p_in_rec.tp_attribute15 ;
     END IF;
     IF p_in_rec.tp_attribute_category <> FND_API.G_MISS_CHAR
      OR p_in_rec.tp_attribute_category  IS NULL THEN
      x_out_rec.tp_attribute_category := p_in_rec.tp_attribute_category ;
     END IF;
    ELSIF p_disabled_list(i)  = 'GLOBALIZATION_FLEXFIELD' THEN
     IF p_in_rec.global_attribute1 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute1  IS NULL THEN
      x_out_rec.global_attribute1 := p_in_rec.global_attribute1 ;
     END IF;
     IF p_in_rec.global_attribute2 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute2  IS NULL THEN
      x_out_rec.global_attribute2 := p_in_rec.global_attribute2 ;
     END IF;
     IF p_in_rec.global_attribute3 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute3  IS NULL THEN
      x_out_rec.global_attribute3 := p_in_rec.global_attribute3 ;
     END IF;
     IF p_in_rec.global_attribute4 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute4  IS NULL THEN
      x_out_rec.global_attribute4 := p_in_rec.global_attribute4 ;
     END IF;
     IF p_in_rec.global_attribute5 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute5  IS NULL THEN
      x_out_rec.global_attribute5 := p_in_rec.global_attribute5 ;
     END IF;
     IF p_in_rec.global_attribute6 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute6  IS NULL THEN
      x_out_rec.global_attribute6 := p_in_rec.global_attribute6 ;
     END IF;
     IF p_in_rec.global_attribute7 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute7  IS NULL THEN
      x_out_rec.global_attribute7 := p_in_rec.global_attribute7 ;
     END IF;
     IF p_in_rec.global_attribute8 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute8  IS NULL THEN
      x_out_rec.global_attribute8 := p_in_rec.global_attribute8 ;
     END IF;
     IF p_in_rec.global_attribute9 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute9  IS NULL THEN
      x_out_rec.global_attribute9 := p_in_rec.global_attribute9 ;
     END IF;
     IF p_in_rec.global_attribute10 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute10  IS NULL THEN
      x_out_rec.global_attribute10 := p_in_rec.global_attribute10 ;
     END IF;
     IF p_in_rec.global_attribute11 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute11  IS NULL THEN
      x_out_rec.global_attribute11 := p_in_rec.global_attribute11 ;
     END IF;
     IF p_in_rec.global_attribute12 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute12  IS NULL THEN
      x_out_rec.global_attribute12 := p_in_rec.global_attribute12 ;
     END IF;
     IF p_in_rec.global_attribute13 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute13  IS NULL THEN
      x_out_rec.global_attribute13 := p_in_rec.global_attribute13 ;
     END IF;
     IF p_in_rec.global_attribute14 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute14  IS NULL THEN
      x_out_rec.global_attribute14 := p_in_rec.global_attribute14 ;
     END IF;
     IF p_in_rec.global_attribute15 <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute15  IS NULL THEN
      x_out_rec.global_attribute15 := p_in_rec.global_attribute15 ;
     END IF;
     IF p_in_rec.global_attribute_category <> FND_API.G_MISS_CHAR
      OR p_in_rec.global_attribute_category  IS NULL THEN
      x_out_rec.attribute_category := p_in_rec.attribute_category ;
     END IF;
    ELSIF   p_disabled_list(i)  = 'TARE_WEIGHT'       THEN
      NULL;
    ELSE
      -- invalid name
      x_field_name := p_disabled_list(i);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      RETURN;
      --
    END IF;
   END IF;
  END LOOP;

END enable_from_list;

--
-- Overloaded procedure
-- Replaced p_action with p_in_rec as a parameter
--
PROCEDURE Get_Disabled_List  (
  p_delivery_rec          IN  WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type
, p_in_rec		  IN  WSH_DELIVERIES_GRP.Del_In_Rec_Type
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, x_delivery_rec          OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type
)
IS
  l_disabled_list               WSH_UTIL_CORE.column_tab_type;
  l_db_col_rec                  WSH_NEW_DELIVERIES_PVT.Delivery_rec_type;
  l_return_status               VARCHAR2(30);
  l_field_name                  VARCHAR2(100);
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) :=
             'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DISABLED_LIST';

  CURSOR c_tbl_rec IS
  SELECT DELIVERY_ID
	,NAME
	,PLANNED_FLAG
	,STATUS_CODE
	,DELIVERY_TYPE
	,LOADING_SEQUENCE
	,LOADING_ORDER_FLAG
	,INITIAL_PICKUP_DATE
	,INITIAL_PICKUP_LOCATION_ID
	,ORGANIZATION_ID
	,ULTIMATE_DROPOFF_LOCATION_ID
	,ULTIMATE_DROPOFF_DATE
	,CUSTOMER_ID
	,INTMED_SHIP_TO_LOCATION_ID
	,POOLED_SHIP_TO_LOCATION_ID
	,CARRIER_ID
	,SHIP_METHOD_CODE
	,FREIGHT_TERMS_CODE
	,FOB_CODE
	,FOB_LOCATION_ID
	,WAYBILL
	,DOCK_CODE
	,ACCEPTANCE_FLAG
	,ACCEPTED_BY
	,ACCEPTED_DATE
	,ACKNOWLEDGED_BY
	,CONFIRMED_BY
	,CONFIRM_DATE
	,ASN_DATE_SENT
	,ASN_STATUS_CODE
	,ASN_SEQ_NUMBER
	,GROSS_WEIGHT
	,NET_WEIGHT
	,WEIGHT_UOM_CODE
	,VOLUME
	,VOLUME_UOM_CODE
	,ADDITIONAL_SHIPMENT_INFO
	,CURRENCY_CODE
	,ATTRIBUTE_CATEGORY
	,ATTRIBUTE1
	,ATTRIBUTE2
	,ATTRIBUTE3
	,ATTRIBUTE4
	,ATTRIBUTE5
	,ATTRIBUTE6
	,ATTRIBUTE7
	,ATTRIBUTE8
	,ATTRIBUTE9
	,ATTRIBUTE10
	,ATTRIBUTE11
	,ATTRIBUTE12
	,ATTRIBUTE13
	,ATTRIBUTE14
	,ATTRIBUTE15
	,TP_ATTRIBUTE_CATEGORY
	,TP_ATTRIBUTE1
	,TP_ATTRIBUTE2
	,TP_ATTRIBUTE3
	,TP_ATTRIBUTE4
	,TP_ATTRIBUTE5
	,TP_ATTRIBUTE6
	,TP_ATTRIBUTE7
	,TP_ATTRIBUTE8
	,TP_ATTRIBUTE9
	,TP_ATTRIBUTE10
	,TP_ATTRIBUTE11
	,TP_ATTRIBUTE12
	,TP_ATTRIBUTE13
	,TP_ATTRIBUTE14
	,TP_ATTRIBUTE15
	,GLOBAL_ATTRIBUTE_CATEGORY
	,GLOBAL_ATTRIBUTE1
	,GLOBAL_ATTRIBUTE2
	,GLOBAL_ATTRIBUTE3
	,GLOBAL_ATTRIBUTE4
	,GLOBAL_ATTRIBUTE5
	,GLOBAL_ATTRIBUTE6
	,GLOBAL_ATTRIBUTE7
	,GLOBAL_ATTRIBUTE8
	,GLOBAL_ATTRIBUTE9
	,GLOBAL_ATTRIBUTE10
	,GLOBAL_ATTRIBUTE11
	,GLOBAL_ATTRIBUTE12
	,GLOBAL_ATTRIBUTE13
	,GLOBAL_ATTRIBUTE14
	,GLOBAL_ATTRIBUTE15
	,GLOBAL_ATTRIBUTE16
	,GLOBAL_ATTRIBUTE17
	,GLOBAL_ATTRIBUTE18
	,GLOBAL_ATTRIBUTE19
	,GLOBAL_ATTRIBUTE20
	,CREATION_DATE
	,CREATED_BY
        ,sysdate
        ,FND_GLOBAL.USER_ID
        ,FND_GLOBAL.LOGIN_ID
	,PROGRAM_APPLICATION_ID
	,PROGRAM_ID
	,PROGRAM_UPDATE_DATE
	,REQUEST_ID
        ,BATCH_ID
        ,HASH_VALUE
        ,SOURCE_HEADER_ID
	,NUMBER_OF_LPN
        ,COD_AMOUNT
        ,COD_CURRENCY_CODE
        ,COD_REMIT_TO
        ,COD_CHARGE_PAID_BY
        ,PROBLEM_CONTACT_REFERENCE
        ,PORT_OF_LOADING
        ,PORT_OF_DISCHARGE
        ,FTZ_NUMBER
        ,ROUTED_EXPORT_TXN
        ,ENTRY_NUMBER
        ,ROUTING_INSTRUCTIONS
        ,IN_BOND_CODE
        ,SHIPPING_MARKS
	,SERVICE_LEVEL
	,MODE_OF_TRANSPORT
	,ASSIGNED_TO_FTE_TRIPS
        --new added fields
        , AUTO_SC_EXCLUDE_FLAG
        , AUTO_AP_EXCLUDE_FLAG
        , AP_BATCH_ID
        --
        ,p_delivery_rec.ROWID
        ,p_delivery_rec.LOADING_ORDER_DESC
        ,p_delivery_rec.ORGANIZATION_CODE
        ,p_delivery_rec.ULTIMATE_DROPOFF_LOCATION_CODE
        ,p_delivery_rec.INITIAL_PICKUP_LOCATION_CODE
        ,p_delivery_rec.CUSTOMER_NUMBER
        ,p_delivery_rec.INTMED_SHIP_TO_LOCATION_CODE
        ,p_delivery_rec.POOLED_SHIP_TO_LOCATION_CODE
        ,p_delivery_rec.CARRIER_CODE
        ,p_delivery_rec.SHIP_METHOD_NAME
        ,p_delivery_rec.FREIGHT_TERMS_NAME
        ,p_delivery_rec.FOB_NAME
        ,p_delivery_rec.FOB_LOCATION_CODE
        ,p_delivery_rec.WEIGHT_UOM_DESC
        ,p_delivery_rec.VOLUME_UOM_DESC
        ,p_delivery_rec.CURRENCY_NAME
/*  J  Inbound Logistics: New columns jckwok */
        ,SHIPMENT_DIRECTION
        ,VENDOR_ID
        ,PARTY_ID
        ,ROUTING_RESPONSE_ID
        ,RCV_SHIPMENT_HEADER_ID
        ,ASN_SHIPMENT_HEADER_ID
        ,SHIPPING_CONTROL
/* J TP Release : ttrichy */
        ,TP_DELIVERY_NUMBER
        ,EARLIEST_PICKUP_DATE
        ,LATEST_PICKUP_DATE
        ,EARLIEST_DROPOFF_DATE
        ,LATEST_DROPOFF_DATE
        ,IGNORE_FOR_PLANNING
        ,TP_PLAN_NAME
-- J: W/V Changes
        ,WV_FROZEN_FLAG
        ,HASH_STRING
        ,delivered_date
        ,p_delivery_rec.packing_slip
--bug 3667348
        ,REASON_OF_TRANSPORT
        ,DESCRIPTION
        ,'N' --Non Database field added for "Proration of weight from Delivery to delivery lines" Project(Bug#4254552).
--OTM R12
        ,TMS_INTERFACE_FLAG
        ,TMS_VERSION_NUMBER
--R12.1.1 STANDALONE PROJECT
        ,PENDING_ADVICE_FLAG
        ,CLIENT_ID -- LSP PROJECT : Added just for compatibility ( not used anywhere). -- Modified R12.1.1 LSP PROJECT (rminocha)
        ,p_delivery_rec.client_code -- LSP PROJECT
  FROM wsh_new_deliveries
  WHERE delivery_id = p_delivery_rec.delivery_id;

  e_dp_no_entity EXCEPTION;
  e_bad_field EXCEPTION;
  e_all_disabled EXCEPTION ;
    --
    l_shipping_control     VARCHAR2(30);
    l_routing_response_id  NUMBER;
    l_routing_request_flag VARCHAR2(30);

    l_caller               VARCHAR2(32767);
    --l_return_status        VARCHAR2(10);

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
      WSH_DEBUG_SV.log(l_module_name,'DELIVERY_ID', p_delivery_rec.DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'Action Code', p_in_rec.action_code);
      WSH_DEBUG_SV.log(l_module_name,'Caller', p_in_rec.caller);
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF p_in_rec.action_code = 'CREATE' THEN
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'calling eliminate_displayonly_fields');
     END IF;
     --
     -- nothing else need to be disabled
     --
--tkt
     eliminate_displayonly_fields(p_delivery_rec,p_in_rec, x_delivery_rec);
     --
--3509004: : public api changes
/*
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN;
     --
*/
  ELSIF p_in_rec.action_code = 'UPDATE' THEN
    --
    l_caller := p_in_rec.caller;
    IF (l_caller like 'FTE%') THEN
      l_caller := 'WSH_PUB';
    END IF;
    Get_Disabled_List( p_delivery_rec.DELIVERY_ID
                     , 'FORM'
                     , x_return_status
                     , l_disabled_list
                     , x_msg_count
                     , x_msg_data
		     , l_caller --3509004:public api changes
                     );
    --
    IF x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR OR
       x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
    THEN
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
      --
    END IF;
    --

    --
    IF l_disabled_list.COUNT = 1 THEN
      IF l_disabled_list(1) = 'FULL' THEN
        RAISE e_all_disabled;
        --Everything  is disabled
      END IF;
    END IF;
    --
    OPEN c_tbl_rec;
    FETCH c_tbl_rec INTO x_delivery_rec;
      IF c_tbl_rec%NOTFOUND THEN
       --
       CLOSE c_tbl_rec;
       RAISE e_dp_no_entity;
       --
      END IF;
    CLOSE c_tbl_rec;
    --
    -- J-IB-NPARIKH-{
    --
    --
    --
    -- depending on the caller,
    --   firmly overwrite columns that are otherwise normally protected.
    --
    IF p_in_rec.caller LIKE 'WSH_TP_RELEASE%' THEN
      -- bug 3371077: need to overwrite these dates even
      --   if delivery has contents.
      --   (technically equivalent to emptying the delivery,
      --    updating the dates, and re-assigning its contents)
      IF p_delivery_rec.INITIAL_PICKUP_DATE <> FND_API.G_MISS_DATE THEN
        x_delivery_rec.INITIAL_PICKUP_DATE := p_delivery_rec.INITIAL_PICKUP_DATE ;
      END IF;
      IF p_delivery_rec.ULTIMATE_DROPOFF_DATE <> FND_API.G_MISS_DATE THEN
        x_delivery_rec.ULTIMATE_DROPOFF_DATE := p_delivery_rec.ULTIMATE_DROPOFF_DATE ;
      END IF;
    END IF;
    --
    --
    --
    -- J-IB-NPARIKH-}

    IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'list.COUNT',l_disabled_list.COUNT);
    END IF;
    --
    IF l_disabled_list.COUNT = 0 THEN
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'calling eliminate_displayonly_fields');
     END IF;
     --
     -- nothing else need to be disabled
     --
--tkt
     eliminate_displayonly_fields (p_delivery_rec,p_in_rec,x_delivery_rec);
     --
    ELSIF l_disabled_list(1) = 'FULL' THEN
      IF l_disabled_list.COUNT > 1 THEN
      --
      IF l_debug_on THEN
          FOR i in 1..l_disabled_list.COUNT
          LOOP
            WSH_DEBUG_SV.log(l_module_name,'list values',l_disabled_list(i));
          END LOOP;
          WSH_DEBUG_SV.log(l_module_name,'calling enable_from_list');
      END IF;
      --enable the columns matching the l_disabled_list
      enable_from_list(l_disabled_list,
                      p_delivery_rec,
                      x_delivery_rec,
                      l_return_status,
                      l_field_name);
      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
         RAISE e_bad_field;
      END IF;
      END IF;
      --
    ELSE -- list.count > 1 and list(1) <> 'FULL'
      l_db_col_rec := x_delivery_rec ;
      --
      IF l_debug_on THEN
        FOR i in 1..l_disabled_list.COUNT
        LOOP
          WSH_DEBUG_SV.log(l_module_name,'list values',l_disabled_list(i));
        END LOOP;
        WSH_DEBUG_SV.log(l_module_name,'First element is not FULL');
        WSH_DEBUG_SV.log(l_module_name,'calling eliminate_displayonly_fields');
      END IF;
      --
--tkt
      eliminate_displayonly_fields (p_delivery_rec,p_in_rec,x_delivery_rec);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'calling disable_from_list');
      END IF;
      -- The fileds in the list are getting disabled
      disable_from_list(l_disabled_list,
                      l_db_col_rec,
                      x_delivery_rec,
                      l_return_status,
                      l_field_name,
                      p_in_rec.caller
                      );
      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
       RAISE e_bad_field;
      END IF;
    END IF;
  --
  END IF; /* if action = 'UPDATE' */

  --3509004:public api changes
  IF (NVL(p_in_rec.caller, '!!!') <> 'WSH_FSTRX' AND
      NVL(p_in_rec.caller, '!!!') NOT LIKE 'FTE%'
      AND NVL(p_in_rec.caller, '!!!') <> 'WSH_INBOUND'
      AND NVL(p_in_rec.caller, '!!!') <> 'WSH_TPW_INBOUND') THEN
    --
    user_non_updatable_columns
     (p_user_in_rec   => p_delivery_rec,
      p_out_rec       => x_delivery_rec,
      p_in_rec        => p_in_rec,
      x_return_status => l_return_status);
    --
    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
       x_return_status := l_return_status;
    END IF;
    --
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN e_all_disabled THEN
      IF (c_tbl_rec%ISOPEN) THEN
        CLOSE c_tbl_rec;
      END IF;

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_ALL_COLS_DISABLED');
      FND_MESSAGE.Set_Token('ENTITY_ID',p_delivery_rec.delivery_id);
      wsh_util_core.add_message(x_return_status,l_module_name);
      IF l_debug_on THEN
        -- Nothing is updateable
        WSH_DEBUG_SV.pop(l_module_name,'e_all_disabled');
      END IF;
    WHEN e_dp_no_entity THEN
      IF (c_tbl_rec%ISOPEN) THEN
        CLOSE c_tbl_rec;
      END IF;

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      -- the message for this is set in original get_disabled_list
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'e_dp_no_entity');
      END IF;
    WHEN e_bad_field THEN
      IF (c_tbl_rec%ISOPEN) THEN
        CLOSE c_tbl_rec;
      END IF;

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_BAD_FIELD_NAME');
      FND_MESSAGE.Set_Token('FIELD_NAME',l_field_name);
      wsh_util_core.add_message(x_return_status,l_module_name);
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Bad field name passed to the list:'
                                                        ,l_field_name);
        WSH_DEBUG_SV.pop(l_module_name,'e_bad_field');
      END IF;
      --
    WHEN FND_API.G_EXC_ERROR THEN
      IF (c_tbl_rec%ISOPEN) THEN
        CLOSE c_tbl_rec;
      END IF;

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (c_tbl_rec%ISOPEN) THEN
        CLOSE c_tbl_rec;
      END IF;

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

    WHEN OTHERS THEN
      IF (c_tbl_rec%ISOPEN) THEN
        CLOSE c_tbl_rec;
      END IF;

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.get_disabled_list', l_module_name);
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Error:',SUBSTR(SQLERRM,1,200));
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END Get_Disabled_List;


PROCEDURE Init_Delivery_Actions_Tbl (
  p_action                   IN                VARCHAR2
, x_delivery_actions_tab     OUT      NOCOPY         DeliveryActionsTabType
, x_return_status            OUT      NOCOPY         VARCHAR2
)

IS
i NUMBER := 0;
--OTM R12
l_gc3_is_installed		VARCHAR2(1);
--

l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) :=
         'wsh.plsql.' || G_PKG_NAME || '.' || 'Init_Delivery_Actions_Tbl';

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
      WSH_DEBUG_SV.log(l_module_name,'p_action', p_action);
  END IF;
  --
  x_return_status :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --OTM R12
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED; -- this is global variable

  IF l_gc3_is_installed IS NULL THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED; -- this is actual function
  END IF;
  --

/*
  PLEASE READ BEFORE MODIFYING THIS PROCEDURE:
  Actions are disabled by updating i FIRST and then adding appropriate conditions (like
  status code, action not allowed etc.) and NOT the other way (update i after updating
  status code, action not allowed).
*/

  --OTM R12
  IF l_gc3_is_installed = 'Y' THEN
    IF p_action IN ('GET-FREIGHT-COSTS',
                    'FIRM',
                    'SELECT-CARRIER',
                    'RATE_WITH_UPS',
                    'UPS_TIME_IN_TRANSIT',
                    'UPS_ADDRESS_VALIDATION',
                    'UPS_TRACKING') THEN
      i := i + 1;
      x_delivery_actions_tab(i).action_not_allowed := p_action;
    END IF;
  END IF;
  --END OTM R12
  --
  --
  -- J-IB-NPARIKH-{
    --
    -- Disable all the actions for inbound/drop-ship deliveries
    -- when called from shipping transaction form
    --
    i := i+1;
    x_delivery_actions_tab(i).shipment_direction := 'I';
    x_delivery_actions_tab(i).caller             := 'WSH_FSTRX';
    x_delivery_actions_tab(i).action_not_allowed := p_action;
    i := i+1;
    x_delivery_actions_tab(i).shipment_direction := 'D';
    x_delivery_actions_tab(i).caller             := 'WSH_FSTRX';
    x_delivery_actions_tab(i).action_not_allowed := p_action;
  -- J-IB-NPARIKH-}
  --
  --

  IF p_action = 'CLOSE'  THEN
        i := i+1;
        x_delivery_actions_tab(i).status_code := 'CL';
        x_delivery_actions_tab(i).action_not_allowed := p_action;
        i := i + 1;
        x_delivery_actions_tab(i).status_code := 'CO';
        x_delivery_actions_tab(i).action_not_allowed := p_action;
        --
        -- J-IB-NPARIKH-{
        --
  ELSIF p_action = 'GENERATE-ROUTING-RESPONSE'  THEN
        --
        -- Generate routing response action not allowed for
        -- - outbound (O/IO) deliveries
        -- - in-transit/closed deliveries
        --
        i := i + 1;
        x_delivery_actions_tab(i).status_code := 'CL';
        x_delivery_actions_tab(i).action_not_allowed := p_action;
        i := i + 1;
        x_delivery_actions_tab(i).status_code := 'IT';
        x_delivery_actions_tab(i).action_not_allowed := p_action;
        i := i+1;
        x_delivery_actions_tab(i).shipment_direction := 'O';
        x_delivery_actions_tab(i).action_not_allowed := p_action;
        i := i+1;
        x_delivery_actions_tab(i).shipment_direction := 'IO';
        x_delivery_actions_tab(i).action_not_allowed := p_action;
        --
        -- J-IB-NPARIKH-}
        --
  ELSIF p_action IN (  'IN-TRANSIT' ,'RE-OPEN' )  THEN
        i := i+1;
     x_delivery_actions_tab(i).status_code := 'CL';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'IT';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
/*J add disallowed actions for shipment_direction jckwok */
     i := i + 1;
     x_delivery_actions_tab(i).shipment_direction := 'I';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     i := i + 1;
     x_delivery_actions_tab(i).shipment_direction := 'D';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
  ELSIF p_action IN ('UNASSIGN-TRIP','AUTOCREATE-TRIP','WT-VOL',
                       'PICK-RELEASE-UI' ,'DELETE','ASSIGN-TRIP')  THEN

     -- J-IB-NPARIKH-{
     IF p_action = 'WT-VOL'
     THEN
     --{
         --
         -- Calculate weight/volume action
         --  - allowed for in-transit/closed inbound (not O/IO) deliveries
         --  - not allowed for in-transit/closed outbound (O/IO) deliveries
         --
         i := i + 1;
         x_delivery_actions_tab(i).shipment_direction := 'O';
         x_delivery_actions_tab(i).status_code := 'CL';
         x_delivery_actions_tab(i).action_not_allowed := p_action;
         i := i + 1;
         x_delivery_actions_tab(i).shipment_direction := 'IO';
         x_delivery_actions_tab(i).status_code := 'CL';
         x_delivery_actions_tab(i).action_not_allowed := p_action;

         i := i + 1;
         x_delivery_actions_tab(i).shipment_direction := 'O';
         x_delivery_actions_tab(i).status_code := 'IT';
         x_delivery_actions_tab(i).action_not_allowed := p_action;
         i := i + 1;
         x_delivery_actions_tab(i).shipment_direction := 'IO';
         x_delivery_actions_tab(i).status_code := 'IT';
         x_delivery_actions_tab(i).action_not_allowed := p_action;
     --}
     ELSE
     -- J-IB-NPARIKH-}
         i := i + 1;
         x_delivery_actions_tab(i).status_code := 'CL';
         x_delivery_actions_tab(i).action_not_allowed := p_action;

         i := i + 1;
         x_delivery_actions_tab(i).status_code := 'IT';
         x_delivery_actions_tab(i).action_not_allowed := p_action;
     END IF;
     --
     -- Bug fix 2657615
     -- Allow Assign-Trip, Unassign-Trip, Autocreate-Trip for Confirmed deliveries
     IF p_action NOT IN ('ASSIGN-TRIP', 'UNASSIGN-TRIP', 'AUTOCREATE-TRIP') THEN
        i := i + 1;
        x_delivery_actions_tab(i).status_code := 'CO';
        x_delivery_actions_tab(i).action_not_allowed := p_action;
     END IF;
     IF p_action NOT IN ('ASSIGN-TRIP', 'UNASSIGN-TRIP', 'AUTOCREATE-TRIP', 'WT-VOL','DELETE') THEN
/*J add disallowed actions for shipment_direction jckwok */
       i := i + 1;
       x_delivery_actions_tab(i).shipment_direction := 'I';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
       i := i + 1;
       x_delivery_actions_tab(i).shipment_direction := 'D';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
     END IF;
     -- End of Bug fix 2657615
  -- J-IB-NPARIKH-{
  ELSIF p_action = 'INCLUDE_PLAN' THEN
     --
     -- Include plan action not allowed for status code = XX
     -- status code XX is dummy status and will have this value only
     -- For in-transit/closed inbound deliveries (not O/IO), if
     --  - supplier is managing transportation
     -- OR
     --  - routing request was not received for all delivery lines
     --
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'XX';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     --OTM R12
     IF l_gc3_is_installed = 'Y' THEN
       -- 5746110: enforce this condition only when OTM is installed.
       i := i + 1;
       x_delivery_actions_tab(i).action_not_allowed := p_action;
       x_delivery_actions_tab(i).otm_enabled := 'N';
     END IF;

  -- J-IB-NPARIKH-}

  ELSIF p_action = 'FREIGHT-COSTS-UI' THEN
/*J add disallowed actions for shipment_direction jckwok */
       i := i + 1;
       x_delivery_actions_tab(i).shipment_direction := 'I';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
       i := i + 1;
       x_delivery_actions_tab(i).shipment_direction := 'D';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
       -- OTM R12 - Org specific changes - Bug#5399341
       x_delivery_actions_tab(i).otm_enabled := 'N';
  ELSIF p_action IN ('UNPLAN', 'AUTO-PACK', 'AUTO-PACK-MASTER','PACK',
                     'SELECT-CARRIER','GEN-LOAD-SEQ')   THEN
     --order of i := i + 1; changed to be before and not after addition of new record
     IF (NOT p_action='UNPLAN') THEN
        i := i + 1;
        x_delivery_actions_tab(i).status_code := 'CL';
        x_delivery_actions_tab(i).action_not_allowed := p_action;
        i := i + 1;
        x_delivery_actions_tab(i).status_code := 'CO';
        x_delivery_actions_tab(i).action_not_allowed := p_action;
        i := i + 1;
        x_delivery_actions_tab(i).status_code := 'IT';
        x_delivery_actions_tab(i).action_not_allowed := p_action;
     END IF;
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'SR';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'SC';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     --order of i := i + 1; changed to be before and not after addition of new record
     IF p_action IN ('AUTO-PACK', 'AUTO-PACK-MASTER', 'PACK') THEN
       i := i+1;
       x_delivery_actions_tab(i).org_type := 'WMS';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
/*J add disallowed actions for shipment_direction jckwok */
       i := i + 1;
       x_delivery_actions_tab(i).shipment_direction := 'I';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
       i := i + 1;
       x_delivery_actions_tab(i).shipment_direction := 'D';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
     END IF;
     IF p_action = 'GEN-LOAD-SEQ' THEN
/*J add disallowed actions for shipment_direction jckwok */
       i := i + 1;
       x_delivery_actions_tab(i).shipment_direction := 'I';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
       i := i + 1;
       x_delivery_actions_tab(i).shipment_direction := 'D';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
     END IF;
  ELSIF p_action IN (  'PICK-RELEASE','CONFIRM','PLAN', 'FIRM') THEN

     --order of i := i + 1; changed to be before and not after addition of new record
     IF (NOT p_action IN ('PLAN', 'FIRM')) THEN
        i := i + 1;
        x_delivery_actions_tab(i).status_code := 'CL';
        x_delivery_actions_tab(i).action_not_allowed := p_action;
        i := i + 1;
        x_delivery_actions_tab(i).status_code := 'CO';
        x_delivery_actions_tab(i).action_not_allowed := p_action;
        i := i + 1;
        x_delivery_actions_tab(i).status_code := 'IT';
        x_delivery_actions_tab(i).action_not_allowed := p_action;
     END IF;

     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'SR';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'SC';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     --order of i := i + 1; changed to be before and not after addition of new record

     IF p_action IN ('PICK-RELEASE','CONFIRM') THEN
/*J add disallowed actions for shipment_direction jckwok */
       i := i + 1;
       x_delivery_actions_tab(i).shipment_direction := 'I';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
       i := i + 1;
       x_delivery_actions_tab(i).shipment_direction := 'D';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
     END IF;
  ELSIF p_action IN  ('GENERATE-BOL','PRINT-BOL') THEN
     --order of i := i + 1; changed to be before and not after addition of new record
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'SR';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'SC';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
/*J add disallowed actions for shipment_direction jckwok */
     i := i + 1;
     x_delivery_actions_tab(i).shipment_direction := 'I';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     i := i + 1;
     x_delivery_actions_tab(i).shipment_direction := 'D';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
  ELSIF p_action =     'ASSIGN' THEN
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'SR';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'SC';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'CO';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'IT';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'CL';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'SA';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
   ELSIF p_action IN( 'UNASSIGN', 'SPLIT-LINE', 'UNPACK', 'PACKING-WORKBENCH','CYCLE-COUNT') THEN
     /* These Actions are for delivery lines. They are added here because,
       Delivery Detail's Is_Action_Enabled API calls Delivery's Is_Action_Enabled
       to check the status of the delivery.
       These Actions are not allowed if the delivery has been sent in outbound or if the
       delivery is awaiting a response for shipment cancellation request.
       Other actions applicable to delivery lines , like AUTO-PACK, AUTO-PACK-MASTER,
       ASSIGN, PACK are covered under the previous ELSIFs */
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'SR';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     i := i + 1;
     x_delivery_actions_tab(i).status_code := 'SC';
     x_delivery_actions_tab(i).action_not_allowed := p_action;
     --order of i := i + 1; changed to be before and not after addition of new record

     IF (p_action ='SPLIT-LINE') THEN
        i := i + 1;
        x_delivery_actions_tab(i).status_code := 'CO';
        x_delivery_actions_tab(i).action_not_allowed := p_action;
     END IF;
   ELSIF (p_action in ('GET-FREIGHT-COSTS', 'CANCEL-SHIP-METHOD') ) THEN
     IF WSH_UTIL_CORE.FTE_Is_Installed <> 'Y' THEN
       --order of i := i + 1; changed to be before and not after addition of new record
        i := i + 1;
        x_delivery_actions_tab(i).action_not_allowed := p_action;
     ELSE
       i := i + 1;
       x_delivery_actions_tab(i).status_code := 'IT';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
       i := i + 1;
       x_delivery_actions_tab(i).status_code := 'CO';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
       i := i + 1;
       x_delivery_actions_tab(i).status_code := 'CL';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
       i := i+1;
       x_delivery_actions_tab(i).org_type := 'TPW';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
/*J add disallowed actions for shipment_direction jckwok */
       i := i + 1;
       x_delivery_actions_tab(i).shipment_direction := 'I';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
       i := i + 1;
       x_delivery_actions_tab(i).shipment_direction := 'D';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
       --order of i := i + 1; changed to be before and not after addition of new record

       IF p_action = 'CANCEL-SHIP-METHOD' THEN
         i := i + 1;
         x_delivery_actions_tab(i).status_code := 'OP';
         x_delivery_actions_tab(i).planned_flag:= 'F';
         x_delivery_actions_tab(i).action_not_allowed := p_action;
       END IF;

     END IF;
-- Patchset J, add Print Pack Slip
   ELSIF (p_action in ('PRINT-DOC-SET', 'OUTBOUND-DOCUMENT', 'GENERATE-PACK-SLIP','PRINT-PACK-SLIP', 'ASSIGN-FREIGHT-COSTS') ) THEN
/*J add disallowed actions for shipment_direction jckwok */
       i := i + 1;
       x_delivery_actions_tab(i).shipment_direction := 'I';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
       i := i + 1;
       x_delivery_actions_tab(i).shipment_direction := 'D';
       x_delivery_actions_tab(i).action_not_allowed := p_action;
  --
  -- rlanka : Pack J
  -- Disallow trip consolidation for inbound deliveries
  --
  ELSIF p_action = 'TRIP-CONSOLIDATION' THEN
    --
    i := i + 1;
    x_delivery_actions_tab(i).shipment_direction := 'I';
    x_delivery_actions_tab(i).action_not_allowed := p_action;
    i := i + 1;
    x_delivery_actions_tab(i).shipment_direction := 'D';
    x_delivery_actions_tab(i).action_not_allowed := p_action;
    --
  --{ IB-Phase-2
  ELSIF p_action = 'CREATE-CONSOL-DEL' THEN
    --
    i := i + 1;
    x_delivery_actions_tab(i).shipment_direction := 'I';
    x_delivery_actions_tab(i).action_not_allowed := p_action;
    i := i + 1;
    x_delivery_actions_tab(i).shipment_direction := 'D';
    x_delivery_actions_tab(i).action_not_allowed := p_action;
    --
  --} IB-Phase-2
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.get_disabled_list', l_module_name);
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Error:',SUBSTR(SQLERRM,1,200));
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Init_Delivery_Actions_Tbl;


PROCEDURE Derive_Delivery_Uom (
  p_delivery_id         IN  NUMBER,
  p_organization_id     IN  NUMBER,
  x_volume_uom_code     IN OUT NOCOPY VARCHAR2,
  x_weight_uom_code     IN OUT NOCOPY VARCHAR2,
  x_wt_nullify_flag     OUT NOCOPY BOOLEAN, -- Default FALSE
  x_vol_nullify_flag    OUT NOCOPY BOOLEAN, -- Default FALSE
  x_return_status       OUT NOCOPY VARCHAR2)
IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DERIVE_DELIVERY_UOM';
--
cursor l_del_org_csr is
select organization_id,
       weight_uom_code,
       volume_uom_code
from   wsh_new_deliveries
where  delivery_id = p_delivery_id;
--
-- Bug# 8446283 : Added weight and volume UOM codes
CURSOR l_get_classes_csr(p_organization_id NUMBER) IS
SELECT weight_uom_class,weight_uom_code,volume_uom_class,volume_uom_code
FROM   wsh_shipping_parameters
WHERE  organization_id = p_organization_id;
--
CURSOR l_check_uom_csr (p_class VARCHAR2, p_uom_code VARCHAR2) IS
SELECT uom_code
FROM   mtl_units_of_measure
WHERE  uom_code = p_uom_code
AND    uom_class = p_class
AND    nvl(disable_date, sysdate) >= sysdate;

cursor l_get_base_uom_csr(p_class VARCHAR2) IS
select uom_code
from   mtl_units_of_measure
where  uom_class = p_class
and    base_uom_flag = 'Y'
AND    nvl(disable_date, sysdate) >= sysdate;

l_organization_id NUMBER;
l_wt_uom_code     VARCHAR2(3);
l_vol_uom_code    VARCHAR2(3);
l_wt_uom_class    VARCHAR2(10);
l_vol_uom_class   VARCHAR2(10);
--
-- Bug# 8446283 :Begin
l_parameter_wt_code  VARCHAR2(3);
l_parameter_vol_code VARCHAR2(3);
-- Bug# 8446283 : End
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
    WSH_DEBUG_SV.log(l_module_name,'p_delivery_id',p_delivery_id);
    WSH_DEBUG_SV.log(l_module_name,'p_organization_id',p_organization_id);
  END IF;
  --
  x_wt_nullify_flag   := FALSE;
  x_vol_nullify_flag  := FALSE;
  open l_del_org_csr;
  Fetch l_del_org_csr into l_organization_id, l_wt_uom_code, l_vol_uom_code;
  IF l_del_org_csr%NOTFOUND THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_INVALID_DELIVERY_ID');
    x_return_status := wsh_util_core.g_ret_sts_error;
    wsh_util_core.add_message(x_return_status,l_module_name);
    close l_del_org_csr;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  close l_del_org_csr;
  --
  IF l_organization_id <> p_organization_id THEN
    --
    -- Bug# 8446283 : Added weight and volume UOM codes
    open  l_get_classes_csr(p_organization_id);
    fetch l_get_classes_csr into l_wt_uom_class,l_parameter_wt_code,l_vol_uom_class,l_parameter_vol_code;
    close l_get_classes_csr;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_wt_uom_class',l_wt_uom_class);
      WSH_DEBUG_SV.log(l_module_name,'l_vol_uom_class',l_vol_uom_class);
      WSH_DEBUG_SV.log(l_module_name,'l_parameter_wt_code',l_parameter_wt_code);
      WSH_DEBUG_SV.log(l_module_name,'l_parameter_vol_code',l_parameter_vol_code);
    END IF;
    --
    open  l_check_uom_csr(l_wt_uom_class, l_wt_uom_code);
    fetch l_check_uom_csr into l_wt_uom_code;
    close l_check_uom_csr;
    --
    open  l_check_uom_csr(l_vol_uom_class, l_vol_uom_code);
    fetch l_check_uom_csr into l_vol_uom_code;
    close l_check_uom_csr;
    --
    IF nvl(l_wt_uom_code,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
      x_weight_uom_code := l_wt_uom_code;
    ELSE
      --
      -- Bug# 8446283 : First consider the wt UOM code value on shipping parameters.
      IF l_parameter_wt_code IS NOT NULL THEN
          x_weight_uom_code := l_parameter_wt_code;
      ELSE
          open  l_get_base_uom_csr(l_wt_uom_class);
          fetch l_get_base_uom_csr into x_weight_uom_code;
          close l_get_base_uom_csr;
      END IF;
      --
      x_wt_nullify_flag  := TRUE;
      --
    END IF;
    --
    IF nvl(l_wt_uom_code,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
      x_volume_uom_code := l_vol_uom_code;
    ELSE
      --
      -- Bug# 8446283 : First consider the vol UOM code value on shipping parameters.
      IF l_parameter_vol_code IS NOT NULL THEN
          x_volume_uom_code := l_parameter_vol_code;
      ELSE
          open  l_get_base_uom_csr(l_vol_uom_class);
          fetch l_get_base_uom_csr into x_volume_uom_code;
          close l_get_base_uom_csr;
      END IF;
      --
      x_vol_nullify_flag  := TRUE;
      --
    END IF;
    --
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_weight_uom_code',x_weight_uom_code);
    WSH_DEBUG_SV.log(l_module_name,'x_volume_uom_code',x_volume_uom_code);
  END IF;
  x_return_status := wsh_util_core.g_ret_sts_success;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.DERIVE_DELIVERY_UOM');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Derive_Delivery_Uom;

PROCEDURE Validate_Routed_Export_Txn(
  x_rtd_expt_txn_code    IN OUT NOCOPY VARCHAR2,
  p_rtd_expt_txn_meaning IN VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2)
IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_ROUTED_EXPORT_TXN';
--
l_num_errors NUMBER := 0;
l_num_warnings NUMBER := 0;
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
    WSH_DEBUG_SV.log(l_module_name,'x_rtd_expt_txn_code',x_rtd_expt_txn_code);
    WSH_DEBUG_SV.log(l_module_name,'p_rtd_expt_txn_meaning',p_rtd_expt_txn_meaning);
  END IF;
  --
  SAVEPOINT VALIDATE_ROUTED_EXPORT_TXN;
  --
  IF nvl(x_rtd_expt_txn_code,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
  OR nvl(p_rtd_expt_txn_meaning,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
  THEN
    IF x_rtd_expt_txn_code = FND_API.G_MISS_CHAR THEN
      x_rtd_expt_txn_code := NULL;
    END IF;
    WSH_UTIL_VALIDATE.validate_lookup(
      p_lookup_type   => 'YES_NO',
      p_lookup_code   => x_rtd_expt_txn_code,
      p_meaning       => p_rtd_expt_txn_meaning,
      x_return_status => x_return_status);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_lookup',x_return_status);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status => x_return_status,
      x_num_warnings  => l_num_warnings,
      x_num_errors    => l_num_errors);
    --
  END IF;
  --
  x_return_status := wsh_util_core.g_ret_sts_success;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO VALIDATE_ROUTED_EXPORT_TXN;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO VALIDATE_ROUTED_EXPORT_TXN;
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
      ROLLBACK TO VALIDATE_ROUTED_EXPORT_TXN;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.VALIDATE_ROUTED_EXPORT_TXN');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Validate_Routed_Export_Txn;


PROCEDURE Derive_Number_Of_LPN(
  p_delivery_id   IN NUMBER,
  x_number_of_lpn IN OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2)
IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DERIVE_NUMBER_OF_LPN';
--
cursor  lpn_cur is
select  count (distinct wda.delivery_detail_id)
from    wsh_delivery_assignments_v wda
where   wda.parent_delivery_detail_id is null
and     wda.delivery_id is NOT NULL
and     level > 1
connect by prior wda.parent_delivery_detail_id = wda.delivery_detail_id
start   with wda.delivery_id =p_delivery_id;
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
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_delivery_id',p_delivery_id);
    WSH_DEBUG_SV.log(l_module_name,'x_number_of_lpn',x_number_of_lpn);
    --
  END IF;
  --
  SAVEPOINT DERIVE_NUMBER_OF_LPN;
  --
  IF nvl(x_number_of_lpn,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
    --
    open  lpn_cur;
    fetch lpn_cur into x_number_of_lpn;
    close lpn_cur;
    --
    IF x_number_of_lpn = 0 THEN
      x_number_of_lpn := NULL;
    END IF;
    --
  END IF;

  x_return_status := wsh_util_core.g_ret_sts_success;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DERIVE_NUMBER_OF_LPN;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DERIVE_NUMBER_OF_LPN;
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
      ROLLBACK TO DERIVE_NUMBER_OF_LPN;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.DERIVE_NUMBER_OF_LPN');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Derive_Number_Of_LPN;
--Harmonization Project I

-- This is new procedure to check for duplicate pickup locations or
-- dropoff locations when a trip is being assigned to a delivery.
PROCEDURE Chk_Dup_Pickup_Dropoff_Locns(
  p_delivery_id  IN NUMBER,
  p_pickup_location_id IN NUMBER,
  p_dropoff_location_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2)
IS
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHK_DUP_PICKUP_DROPOFF_LOCNS';
  --
  -- The below cursor tells whether the input pickup location is
  -- already assigned to one of the legs of the delivery.
  -- If it is already assigned, then we do not allow the assignment
  -- of Trip to this Delivery.
  cursor  l_pick_up_leg_csr( p_del_id IN VARCHAR2,
                             p_pickup_locn_id IN NUMBER) is
  select  wt.name, wnd.name
  from    wsh_new_deliveries wnd,
          wsh_delivery_legs wdl,
          wsh_trip_stops wts,
          wsh_trips wt
  where   wnd.delivery_id = p_del_id
  and     wnd.delivery_id = wdl.delivery_id
  and     wdl.pick_up_stop_id = wts.stop_id
  and     wts.stop_location_id = p_pickup_locn_id
  and     wts.trip_id   = wt.trip_id;
  --
  -- The below cursor tells whether the input dropoff location is
  -- already assigned to one of the legs of the delivery.
  -- If it is already assigned, then we do not allow the assignment
  -- of Trip to this Delivery.
  cursor  l_drop_off_leg_csr( p_del_id IN VARCHAR2,
                              p_dropoff_locn_id IN NUMBER) is
  select  wt.name, wnd.name
  from    wsh_new_deliveries wnd,
          wsh_delivery_legs wdl,
          wsh_trip_stops wts,
          wsh_trips wt
  where   wnd.delivery_id = p_del_id
  and     wnd.delivery_id = wdl.delivery_id
  and     wdl.drop_off_stop_id = wts.stop_id
  and     wts.stop_location_id = p_dropoff_locn_id
  and     wts.trip_id   = wt.trip_id;
  --
  l_pick_up_leg_count NUMBER := 0;
  l_drop_off_leg_count NUMBER := 0;
  --
  l_trip_name VARCHAR2(32767);
  l_del_name VARCHAR2(32767);
  --
  l_loc_description VARCHAR2(32767);
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
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_delivery_id',p_delivery_id);
    WSH_DEBUG_SV.log(l_module_name,'p_pickup_location_id',p_pickup_location_id);
    WSH_DEBUG_SV.log(l_module_name,'p_dropoff_location_id',p_dropoff_location_id);
    --
  END IF;
  IF nvl(p_delivery_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    --
    open  l_pick_up_leg_csr(p_delivery_id, p_pickup_location_id);
    fetch l_pick_up_leg_csr into l_trip_name, l_del_name;
    close l_pick_up_leg_csr;
    --
    IF l_trip_name IS NOT NULL THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'The Pickup Location is not a valid location for this Delivery');
      END IF;
      l_loc_description := wsh_util_core.get_location_description
                             (p_location_id  => p_pickup_location_id,
                              p_format       => 'NEW UI CODE');
      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DUP_PICKUP_LOCATION');
      FND_MESSAGE.SET_TOKEN('DEL_NAME',l_del_name);
      FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_trip_name);
      FND_MESSAGE.SET_TOKEN('PICKUP_LOC',l_loc_description);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    l_trip_name := NULL;
    open  l_drop_off_leg_csr(p_delivery_id, p_dropoff_location_id);
    fetch l_drop_off_leg_csr into l_trip_name, l_del_name;
    close l_drop_off_leg_csr;
    --
    IF l_trip_name IS NOT NULL THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'The Dropoff Location is not a valid location for this Delivery');
      END IF;
      l_loc_description := wsh_util_core.get_location_description
                             (p_location_id  => p_dropoff_location_id,
                              p_format       => 'NEW UI CODE');
      FND_MESSAGE.SET_NAME('WSH','WSH_DEL_DUP_DROPOFF_LOCATION');
      FND_MESSAGE.SET_TOKEN('DEL_NAME',l_del_name);
      FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_trip_name);
      FND_MESSAGE.SET_TOKEN('DROPOFF_LOC',l_loc_description);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
  END IF;

  x_return_status := wsh_util_core.g_ret_sts_success;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'These Pickup and Drop off Locations are valid for this Delivery');
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.CHK_DUP_PICKUP_DROPOFF_LOCNS');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Chk_Dup_Pickup_Dropoff_Locns;

-- PROCEDURE:   Check_ITM_Required (Pack J: ITM integration)
-- DESCRIPTION: This procedure takes in a delivery_id, builds a query and
--              calls the customizable API which appends additional criteria
--              to the above query according to custom specification. Then it
--              executes the query to check if the delivery requires to be
--              marked for ITM screening. If it needs to be marked, return 'Y'.
-- PARAMETERS:  p_delivery_id - delivery that needs to be checked for ITM.
--

  FUNCTION Check_ITM_Required(p_delivery_id IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  l_strQuery VARCHAR2(12000);
  l_tempStr  VARCHAR2(12000);
  l_del_Table WSH_ITM_QUERY_CUSTOM.g_CondnValTableType;
  l_Item_Condn1Tab  WSH_ITM_QUERY_CUSTOM.g_ValueTableType;

  l_CursorID      NUMBER;
  l_ignore        NUMBER;
  v_delivery_id        NUMBER := 0;
  l_rows_fetched NUMBER := 0;
  l_exception_name varchar2(30);
  l_msg   varchar2(2000);
  l_exception_msg_count NUMBER;
  l_exception_msg_data varchar2(2000);
  l_dummy_exception_id NUMBER;

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Check_ITM_Required';
  --


BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_delivery_id',p_delivery_id);
    --
  END IF;


  -- Build query for this delivery

   --Bug 6676749  Modified the query to Mark the delivery for Export Compliance for Both Outbound transaction('O') and Internal Order ('IO')

  l_strQuery := 'select wnd.delivery_id from wsh_new_deliveries wnd ' ||
                -- ' where wnd.shipment_direction = ''O'' ';
	        ' where wnd.shipment_direction IN (''O'', ''IO'') ';
  l_Item_Condn1Tab(1).g_number_val := p_delivery_id;
  l_Item_Condn1Tab(1).g_Bind_Literal := ':b_delivery_id';

  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.ADD_CONDITION',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  WSH_ITM_QUERY_CUSTOM.ADD_CONDITION(l_del_Table, '  AND WND.delivery_id  = :b_delivery_id', l_Item_Condn1Tab, 'NUMBER');



  --Call the customized API

  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_CUSTOMIZE.ALTER_DELIVERY_MARK',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  WSH_ITM_CUSTOMIZE.ALTER_DELIVERY_MARK(l_del_Table, x_return_status);

  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     RETURN 'N';
  END IF;

  FOR i IN 1..l_del_Table.COUNT
  LOOP
    l_tempStr := l_tempStr || ' ' || l_del_table(i).g_Condn_Qry;
  END LOOP;

  --Concatenating Main SQL with Condition SQL

  l_strQuery := l_strQuery || l_tempStr;

  -- Parse cursor

  l_CursorID := DBMS_SQL.Open_Cursor;
  DBMS_SQL.PARSE(l_CursorID, l_strQuery,  DBMS_SQL.v7);
  DBMS_SQL.DEFINE_COLUMN(l_CursorID, 1, v_delivery_id);

  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ITM_QUERY_CUSTOM.BIND_VALUES',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  WSH_ITM_QUERY_CUSTOM.BIND_VALUES(l_del_Table, l_CursorID);

  l_ignore := DBMS_SQL.EXECUTE(l_CursorID);

  l_rows_fetched := dbms_sql.fetch_rows(l_CursorID);
  DBMS_SQL.CLOSE_CURSOR(l_CursorID);

  IF (l_rows_fetched = 0) THEN

     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return','N');
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;

     RETURN 'N';

  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Return','Y');
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  RETURN 'Y';

EXCEPTION

  WHEN OTHERS THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.add_message (x_return_status);
         WSH_UTIL_CORE.default_handler('WSH_DELIVERY_VALIDATIONS.Check_ITM_REQD');
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
END Check_ITM_REQUIRED;






-- PROCEDURE:   Log_ITM_Exception (Pack J: ITM integration)
-- DESCRIPTION: If the delivery need to be marked for ITM screening, log an
--              exception against the delivery.
-- PARAMETERS:  p_delivery_id - delivery that needs to be checked for ITM.
--              p_location_id - ship from location of delivery, required when
--                              loggin exceptions.
--              p_action_type - Whether the check is made at 'SHIP_CONFIRM'
--                              time or at 'CREATION' of delivery.

PROCEDURE Log_ITM_Exception(p_delivery_id in NUMBER,
                            p_ship_from_location_id in NUMBER,
                            p_action_type in VARCHAR2,
                            x_return_status out nocopy VARCHAR2) IS

  l_exception_name varchar2(30);
  l_msg   varchar2(2000);
  l_exception_msg_count NUMBER;
  l_exception_msg_data varchar2(2000);
  l_dummy_exception_id NUMBER := NULL;

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Log_ITM_Exception';

BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      --
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_delivery_id',p_delivery_id);
      WSH_DEBUG_SV.log(l_module_name,'p_ship_from_location_id',p_ship_from_location_id);
      WSH_DEBUG_SV.log(l_module_name,'p_action_type',p_action_type);
      --
    END IF;

    IF p_action_type = 'SHIP_CONFIRM' THEN
      l_exception_name := 'WSH_SC_REQ_EXPORT_COMPL';
      l_msg := FND_MESSAGE.Get_String('WSH', 'WSH_SC_ITM_REQD');
    ELSE
      l_exception_name := 'WSH_PR_REQ_EXPORT_COMPL';
      l_msg := FND_MESSAGE.Get_String('WSH', 'WSH_PR_ITM_REQD');
    END IF;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_xc_util.log_exception',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    wsh_xc_util.log_exception(
                     p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => l_exception_msg_count,
                     x_msg_data                => l_exception_msg_data,
                     x_exception_id            => l_dummy_exception_id ,
                     p_logged_at_location_id   => p_ship_from_location_id,
                     p_exception_location_id   => p_ship_from_location_id,
                     p_logging_entity          => 'SHIPPER',
                     p_logging_entity_id       => FND_GLOBAL.USER_ID,
                     p_exception_name          => l_exception_name,
                     p_message                 => l_msg,
                     p_delivery_id             => p_delivery_id
                     );

  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION

  WHEN OTHERS THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.add_message (x_return_status);
         WSH_UTIL_CORE.default_handler('WSH_DELIVERY_VALIDATIONS.Log_ITM_Exception');
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
END Log_ITM_Exception;


PROCEDURE check_exception(
  p_deliveries_tab           IN wsh_util_core.id_tab_type
, x_exceptions_exist          OUT NOCOPY  VARCHAR2
, x_exceptions_tab           OUT NOCOPY  wsh_delivery_validations.exception_rec_Tab_type
, x_return_status            OUT NOCOPY  VARCHAR2)
IS
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'check_exception';

  CURSOR c_check_exception (p_delivery_id in number) IS
  SELECT severity, delivery_id, exception_id
  FROM   wsh_exceptions
  WHERE  delivery_id = p_delivery_id
  AND    status not in ('NOT_HANDLED' , 'NO_ACTION_REQUIRED' , 'CLOSED')
  ORDER BY decode (severity,  'HIGH',   1,
                              'MEDIUM', 2,
                               3);
l_exception_rec   c_check_exception%rowtype;
l_count NUMBER := 0;

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
      --
      WSH_DEBUG_SV.push(l_module_name);
      --
    END IF;

    x_exceptions_exist := 'N';
    x_return_Status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    For i in 1 .. p_deliveries_tab.count LOOP

         Open c_check_exception(p_deliveries_Tab(i));
         FETCH c_check_exception into l_exception_rec;
         IF c_check_exception%FOUND THEN

            l_count := l_count + 1;
            x_exceptions_tab(l_count).delivery_id := l_exception_rec.delivery_id;
            x_exceptions_tab(l_count).severity := l_exception_rec.severity;
            x_exceptions_tab(l_count).exception_id := l_exception_rec.exception_id;
            x_exceptions_exist := 'Y';

         END IF;
         CLOSE c_check_exception;

     END LOOP;

     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;

EXCEPTION
   WHEN others THEN
        IF c_check_exception%isopen then
           Close c_check_exception;
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        WSH_UTIL_CORE.default_handler('WSH_DELIVERY_VALIDATIONS.check_exception','WSH_DELIVERY_VALIDATIONS');
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
--
END check_exception;

-- J-IB-NPARIKH-{
--
--
-- ----------------------------------------------------------------------
-- Function :   has_lines
-- Parameters:  p_delivery_id in  number
--              returns varchar2
--                  'Y' -- Has non-container lines
--                  'N' -- Does not have any non-container lines
-- Description: Checks if delivery has any non-container lines
--  ----------------------------------------------------------------------
FUNCTION has_lines
            (
               p_delivery_id      IN              NUMBER
            )
RETURN VARCHAR2
IS
--{
    -- Check if delivery has any lines with container flag = 'N'
    --
    CURSOR line_csr (p_delivery_id IN NUMBER)
    IS
        SELECT 'Y'
        FROM   wsh_delivery_details wdd,
               wsh_delivery_assignments_v wda
        WHERE  wdd.delivery_detail_id      = wda.delivery_detail_id
        AND    wda.delivery_id             = p_delivery_id
        AND    NVL(wdd.container_flag,'N') = 'N'
        AND    rownum                      = 1;
    --
    --
    l_debug_on                    BOOLEAN;
    --
    l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'has_lines';
    --
    l_has_lines  VARCHAR2(1);
--}
BEGIN
--{
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
      wsh_debug_sv.LOG(l_module_name, 'P_DELIVERY_ID', p_delivery_id);
    END IF;
    --
    --
    l_has_lines := 'N';
    --
    OPEN  line_csr (p_delivery_id);
    FETCH line_csr INTO l_has_lines;
    CLOSE line_csr;
    --
    --
    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name);
    END IF;
    --
    RETURN(l_has_lines);
--}
EXCEPTION
   WHEN OTHERS THEN
      wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.has_lines',l_module_name);
      --
      IF l_debug_on THEN
        wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
      END IF;
      --
      RAISE;
--
END has_lines;
--
--
--
--========================================================================
-- PROCEDURE : check_inTransit
--
-- PARAMETERS: p_in_rec          Delivery information record
--                x_allowed      Set to In-transit operation is allowed or not
--                                    'Y' : Allowed
--                                    'YW': Allowed with warnings
--                                    'N' : Not Allowed
--                                    'NW': Not Allowed with warnings
--             x_return_status   Return status of the API
--
--
-- COMMENT   : Check if delivery can be set to in-transit.
--
--             It performs the following steps:
--             01. Check that delivery status is CO/IT
--             02. Check for delivery exceptions (Pack J)
--
--========================================================================
--
PROCEDURE check_inTransit
            (
               p_in_rec             IN         ChgStatus_in_rec_type,
               x_return_status      OUT NOCOPY VARCHAR2,
               x_allowed            OUT NOCOPY VARCHAR2
            )
IS
--{
    l_num_warnings          NUMBER;
    l_num_errors            NUMBER;

    -- Exception variables
    l_exceptions_tab  wsh_xc_util.XC_TAB_TYPE;
    l_exp_logged      BOOLEAN := FALSE;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(4000);
    l_return_status   VARCHAR2(1);
    l_exp_warning     BOOLEAN := FALSE;

    --
    l_debug_on                    BOOLEAN;
    --
    l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'check_inTransit';
--}
BEGIN
--{
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
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.DELIVERY_ID ', p_in_rec.delivery_id );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.name        ', p_in_rec.name        );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.status_code ', p_in_rec.status_code );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.put_messages', p_in_rec.put_messages);
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.manual_flag ', p_in_rec.manual_flag );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.caller      ', p_in_rec.caller      );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.actual_date ', p_in_rec.actual_date );
      wsh_debug_sv.LOG(l_module_name, 'p_in_rec.stop_id     ', p_in_rec.stop_id     );
    END IF;
    --
    --
    l_num_warnings  := 0;
    l_num_errors    := 0;
    --
    IF NVL(p_in_rec.status_code,'!!') NOT IN ('CO','IT')
    THEN
    --{
        IF p_in_rec.put_messages
        THEN
        --{
             FND_MESSAGE.SET_NAME('WSH','WSH_DEL_INTRANSIT_ERROR');
             FND_MESSAGE.SET_TOKEN('DEL_NAME',p_in_rec.name);
             wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
        --}
        END IF;
        --
        RAISE wsh_util_core.e_not_allowed;
    --}
    END IF;
    --
    --

    -- Check for Exceptions against Delivery and its Contents
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.Check_Exceptions',WSH_DEBUG_SV.C_PROC_LEVEL);    END IF;
    l_exceptions_tab.delete;
    l_exp_logged      := FALSE;
    l_exp_warning     := FALSE;
    WSH_XC_UTIL.Check_Exceptions (
                                     p_api_version           => 1.0,
                                     x_return_status         => l_return_status,
                                     x_msg_count             => l_msg_count,
                                     x_msg_data              => l_msg_data,
                                     p_logging_entity_id     => p_in_rec.delivery_id,
                                     p_logging_entity_name   => 'DELIVERY',
                                     p_consider_content      => 'Y',
                                     x_exceptions_tab        => l_exceptions_tab
                                   );
    IF ( l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS )  THEN
         x_return_status := l_return_status;
         wsh_util_core.add_message(x_return_status);
         RAISE FND_API.G_EXC_ERROR;
    END IF;
    FOR exp_cnt in 1..l_exceptions_tab.COUNT LOOP
         IF l_exceptions_tab(exp_cnt).exception_behavior = 'ERROR' THEN
            IF l_exceptions_tab(exp_cnt).entity_name = 'DELIVERY' THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_ENTITY');
            ELSE
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_CONTENTS');
            END IF;
            FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Delivery');
            FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_exceptions_tab(exp_cnt).entity_id);
            FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Error');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            wsh_util_core.add_message(x_return_status);
            l_num_warnings := l_num_warnings + 1 ;
            RAISE wsh_util_core.e_not_allowed;
         ELSIF l_exceptions_tab(exp_cnt).exception_behavior = 'WARNING' THEN
            IF l_exceptions_tab(exp_cnt).entity_name = 'DELIVERY' THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_ENTITY');
               FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Delivery');
               FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_exceptions_tab(exp_cnt).entity_id);
               FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Warning');
               x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
               wsh_util_core.add_message(x_return_status);
               l_num_warnings := l_num_warnings + 1 ;
               l_exp_warning := TRUE;
            ELSIF NOT (l_exp_logged) THEN
               FND_MESSAGE.SET_NAME('WSH','WSH_XC_EXIST_CONTENTS');
               FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Delivery');
               FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_exceptions_tab(exp_cnt).entity_id);
               FND_MESSAGE.SET_TOKEN('EXCEPTION_BEHAVIOR','Warning');
               x_return_status :=  WSH_UTIL_CORE.G_RET_STS_WARNING;
               l_exp_logged := TRUE;
               wsh_util_core.add_message(x_return_status);
               l_num_warnings := l_num_warnings + 1 ;
               l_exp_warning := TRUE;
            END IF;
         END IF;
    END LOOP;

   --
   --
   IF l_num_errors > 0
   THEN
        x_return_status         := WSH_UTIL_CORE.G_RET_STS_ERROR;
        x_allowed               := 'N';
   ELSIF l_num_warnings > 0
   THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;
   --
   --
   -- If Exceptions have warnings, then display warnings but allow to proceed
   IF l_exp_warning THEN
      x_allowed := 'YW';
   ELSE
      x_allowed := 'Y';
   END IF;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
--
EXCEPTION
--{
    WHEN wsh_util_core.e_not_allowed THEN
      IF l_num_warnings > 0
      THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      ELSE
          x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      END IF;
      --
      x_allowed       := 'N';
      --
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_util_core.e_not_allowed exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_util_core.e_not_allowed');
      END IF;
      --
    WHEN wsh_util_core.e_not_allowed_warning THEN
      IF l_num_warnings > 0
      THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      ELSE
          x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      END IF;
      --
      x_allowed := 'NW';
      --
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'wsh_util_core.e_not_allowed_warning exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_util_core.e_not_allowed_warning');
      END IF;
      --
    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

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

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.check_inTransit',l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
--}
END check_inTransit;
--
--
--
--========================================================================
-- PROCEDURE : get_shipping_control
--
-- PARAMETERS: p_delivery_id           Delivery ID
--             x_shipping_control      Shipping control for delivery
--             x_routing_response_id   Routing response ID for delivery
--             x_routing_request_flag  Indicates if routing request was received for delivery lines(Y/N)
--             x_return_status         Return status of the API
--
--
-- COMMENT   : This procedure returns inbound-specific attributes for the delivery.
--
--========================================================================
--
PROCEDURE get_shipping_control
            (
               p_delivery_id            IN         NUMBER,
               x_shipping_control       OUT NOCOPY VARCHAR2,
               x_routing_response_id    OUT NOCOPY NUMBER,
               x_routing_request_flag   OUT NOCOPY VARCHAR2,
               x_return_status          OUT NOCOPY VARCHAR2
            )
IS
--{
    -- Get delivery info.
    CURSOR dlvy_csr (p_delivery_id NUMBER)
    IS
        SELECT shipping_control, routing_response_id
        FROM   WSH_NEW_DELIVERIES
        WHERE  delivery_id = p_delivery_id;
    --
    l_dlvy_rec              dlvy_csr%ROWTYPE;
    --
    -- Check if any routing request id is not null for any delivery line.
    --
    CURSOR line_csr(p_delivery_id NUMBER)
    IS
        SELECT 'Y'
        FROM   wsh_delivery_details wdd,
               wsh_delivery_assignments_v wda
        WHERE  wda.delivery_id             = p_delivery_id
        AND    wdd.delivery_detail_id      = wda.delivery_detail_id
        AND    NVL(wdd.container_flag,'N') = 'N'
        AND    routing_req_id              IS NOT NULL
        AND    rownum                      = 1;
    --
    l_num_warnings          NUMBER;
    l_num_errors            NUMBER;
    --
    l_debug_on                    BOOLEAN;
    --
    l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'get_shipping_control';
--}
BEGIN
--{
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
      wsh_debug_sv.LOG(l_module_name, 'p_DELIVERY_ID ', p_delivery_id );
    END IF;
    --
    --
    l_num_warnings  := 0;
    l_num_errors    := 0;
    --
    OPEN dlvy_csr (p_delivery_id);
    --
    FETCH dlvy_csr INTO l_dlvy_rec;
    --
    IF dlvy_csr%NOTFOUND
    THEN
    --{
        FND_MESSAGE.SET_NAME('WSH', 'WSH_INVALID_DELIVERY');
        FND_MESSAGE.SET_TOKEN('DELIVERY_ID',p_delivery_id);
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);
        --CLOSE dlvy_csr;
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    CLOSE dlvy_csr;
    --
    IF l_debug_on THEN
      wsh_debug_sv.LOG(l_module_name, 'l_dlvy_rec.shipping_control ', l_dlvy_rec.shipping_control );
      wsh_debug_sv.LOG(l_module_name, 'l_dlvy_rec.routing_response_id ', l_dlvy_rec.routing_response_id );
    END IF;
    --
    --
    x_shipping_control       := l_dlvy_rec.shipping_control;
    x_routing_response_id    := l_dlvy_rec.routing_response_id;
    --
    IF l_dlvy_rec.shipping_control = 'SUPPLIER'
    THEN
        x_routing_request_flag   := 'N';
    ELSE
    --{
        -- Check if any routing request id is not null for any delivery line.
        -- If No, routing request was not received for delivery lines.
        --
        OPEN line_csr(p_delivery_id);
        --
        FETCH line_csr INTO x_routing_request_flag;
        --
        IF line_csr%NOTFOUND
        THEN
            x_routing_request_flag   := 'N';
            --
            IF l_debug_on THEN
              wsh_debug_sv.LOGMSG(l_module_name, 'No Lines with Routing request' );
            END IF;
        ELSE
            x_routing_request_flag   := 'Y';
            --
            IF l_debug_on THEN
              wsh_debug_sv.LOGMSG(l_module_name, 'At least one Line with Routing request' );
            END IF;
        END IF;
        --
        CLOSE line_csr;
    --}
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
--}
EXCEPTION
--{
    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

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

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.get_shipping_control',l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
--}
END get_shipping_control;
--
--
-- J-IB-NPARIKH-}

--3509004:public api change
PROCEDURE   user_non_updatable_columns
     (p_user_in_rec     IN WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
      p_out_rec         IN WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
      p_in_rec          IN WSH_DELIVERIES_GRP.Del_In_Rec_Type,
      x_return_status   OUT NOCOPY    VARCHAR2)

IS
l_attributes VARCHAR2(2500) ;
k         number;
l_return_status VARCHAR2(1);
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'user_non_updatable_columns';

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_in_rec.caller',p_in_rec.caller);
    --
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF     p_user_in_rec.DELIVERY_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.DELIVERY_ID,-99) <> NVL(p_out_rec.DELIVERY_ID,-99)
  THEN
       l_attributes := l_attributes || 'DELIVERY_ID, ';
  END IF;

  IF     p_user_in_rec.NAME <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.NAME,'!!!') <> NVL(p_out_rec.NAME,'!!!')
  THEN
       l_attributes := l_attributes || 'NAME, ';
  END IF;

  IF     p_user_in_rec.PLANNED_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.PLANNED_FLAG,'!!!') <> NVL(p_out_rec.PLANNED_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'PLANNED_FLAG, ';
  END IF;

  IF     p_user_in_rec.STATUS_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.STATUS_CODE,'!!!') <> NVL(p_out_rec.STATUS_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'STATUS_CODE, ';
  END IF;

  IF     p_user_in_rec.DELIVERY_TYPE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.DELIVERY_TYPE,'!!!') <> NVL(p_out_rec.DELIVERY_TYPE,'!!!')
  THEN
       l_attributes := l_attributes || 'DELIVERY_TYPE, ';
  END IF;

  IF     p_user_in_rec.LOADING_SEQUENCE <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.LOADING_SEQUENCE,-99) <> NVL(p_out_rec.LOADING_SEQUENCE,-99)
  THEN
       l_attributes := l_attributes || 'LOADING_SEQUENCE, ';
  END IF;

  IF     p_user_in_rec.LOADING_ORDER_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.LOADING_ORDER_FLAG,'!!!') <> NVL(p_out_rec.LOADING_ORDER_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'LOADING_ORDER_FLAG, ';
  END IF;

  IF     p_user_in_rec.INITIAL_PICKUP_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.INITIAL_PICKUP_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.INITIAL_PICKUP_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'INITIAL_PICKUP_DATE, ';
  END IF;

  IF     p_user_in_rec.INITIAL_PICKUP_LOCATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.INITIAL_PICKUP_LOCATION_ID,-99) <> NVL(p_out_rec.INITIAL_PICKUP_LOCATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'INITIAL_PICKUP_LOCATION_ID, ';
  END IF;

  IF     p_user_in_rec.ORGANIZATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.ORGANIZATION_ID,-99) <> NVL(p_out_rec.ORGANIZATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'ORGANIZATION_ID, ';
  END IF;

  IF     p_user_in_rec.ULTIMATE_DROPOFF_LOCATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.ULTIMATE_DROPOFF_LOCATION_ID,-99) <> NVL(p_out_rec.ULTIMATE_DROPOFF_LOCATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'ULTIMATE_DROPOFF_LOCATION_ID, ';
  END IF;

  IF     p_user_in_rec.ULTIMATE_DROPOFF_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.ULTIMATE_DROPOFF_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.ULTIMATE_DROPOFF_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'ULTIMATE_DROPOFF_DATE, ';
  END IF;

  IF     p_user_in_rec.CUSTOMER_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.CUSTOMER_ID,-99) <> NVL(p_out_rec.CUSTOMER_ID,-99)
  THEN
       l_attributes := l_attributes || 'CUSTOMER_ID, ';
  END IF;

  IF     p_user_in_rec.INTMED_SHIP_TO_LOCATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.INTMED_SHIP_TO_LOCATION_ID,-99) <> NVL(p_out_rec.INTMED_SHIP_TO_LOCATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'INTMED_SHIP_TO_LOCATION_ID, ';
  END IF;

  IF     p_user_in_rec.POOLED_SHIP_TO_LOCATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.POOLED_SHIP_TO_LOCATION_ID,-99) <> NVL(p_out_rec.POOLED_SHIP_TO_LOCATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'POOLED_SHIP_TO_LOCATION_ID, ';
  END IF;

  IF     p_user_in_rec.CARRIER_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.CARRIER_ID,-99) <> NVL(p_out_rec.CARRIER_ID,-99)
  THEN
       l_attributes := l_attributes || 'CARRIER_ID, ';
  END IF;

  IF     p_user_in_rec.SHIP_METHOD_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SHIP_METHOD_CODE,'!!!') <> NVL(p_out_rec.SHIP_METHOD_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'SHIP_METHOD_CODE, ';
  END IF;

  IF     p_user_in_rec.FREIGHT_TERMS_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.FREIGHT_TERMS_CODE,'!!!') <> NVL(p_out_rec.FREIGHT_TERMS_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'FREIGHT_TERMS_CODE, ';
  END IF;

  IF     p_user_in_rec.FOB_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.FOB_CODE,'!!!') <> NVL(p_out_rec.FOB_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'FOB_CODE, ';
  END IF;

  IF     p_user_in_rec.FOB_LOCATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.FOB_LOCATION_ID,-99) <> NVL(p_out_rec.FOB_LOCATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'FOB_LOCATION_ID, ';
  END IF;

  IF     p_user_in_rec.WAYBILL <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.WAYBILL,'!!!') <> NVL(p_out_rec.WAYBILL,'!!!')
  THEN
       l_attributes := l_attributes || 'WAYBILL, ';
  END IF;

  IF     p_user_in_rec.DOCK_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.DOCK_CODE,'!!!') <> NVL(p_out_rec.DOCK_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'DOCK_CODE, ';
  END IF;

  IF     p_user_in_rec.ACCEPTANCE_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ACCEPTANCE_FLAG,'!!!') <> NVL(p_out_rec.ACCEPTANCE_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'ACCEPTANCE_FLAG, ';
  END IF;

  IF     p_user_in_rec.ACCEPTED_BY <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ACCEPTED_BY,'!!!') <> NVL(p_out_rec.ACCEPTED_BY,'!!!')
  THEN
       l_attributes := l_attributes || 'ACCEPTED_BY, ';
  END IF;

  IF     p_user_in_rec.ACCEPTED_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.ACCEPTED_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.ACCEPTED_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'ACCEPTED_DATE, ';
  END IF;

  IF     p_user_in_rec.ACKNOWLEDGED_BY <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ACKNOWLEDGED_BY,'!!!') <> NVL(p_out_rec.ACKNOWLEDGED_BY,'!!!')
  THEN
       l_attributes := l_attributes || 'ACKNOWLEDGED_BY, ';
  END IF;

  IF     p_user_in_rec.CONFIRMED_BY <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CONFIRMED_BY,'!!!') <> NVL(p_out_rec.CONFIRMED_BY,'!!!')
  THEN
       l_attributes := l_attributes || 'CONFIRMED_BY, ';
  END IF;

  IF     p_user_in_rec.CONFIRM_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.CONFIRM_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.CONFIRM_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'CONFIRM_DATE, ';
  END IF;

  IF     p_user_in_rec.ASN_DATE_SENT <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.ASN_DATE_SENT,TO_DATE('2','j')) <> NVL(p_out_rec.ASN_DATE_SENT,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'ASN_DATE_SENT, ';
  END IF;

  IF     p_user_in_rec.ASN_STATUS_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ASN_STATUS_CODE,'!!!') <> NVL(p_out_rec.ASN_STATUS_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'ASN_STATUS_CODE, ';
  END IF;

  IF     p_user_in_rec.ASN_SEQ_NUMBER <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.ASN_SEQ_NUMBER,-99) <> NVL(p_out_rec.ASN_SEQ_NUMBER,-99)
  THEN
       l_attributes := l_attributes || 'ASN_SEQ_NUMBER, ';
  END IF;

  IF     p_user_in_rec.GROSS_WEIGHT <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.GROSS_WEIGHT,-99) <> NVL(p_out_rec.GROSS_WEIGHT,-99)
  THEN
       l_attributes := l_attributes || 'GROSS_WEIGHT, ';
  END IF;

  IF     p_user_in_rec.NET_WEIGHT <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.NET_WEIGHT,-99) <> NVL(p_out_rec.NET_WEIGHT,-99)
  THEN
       l_attributes := l_attributes || 'NET_WEIGHT, ';
  END IF;
  -- Non Database field prorate_wt_flag added for "Proration of weight from Delivery to delivery lines" Project(Bug#4254552).
  IF     p_user_in_rec.PRORATE_WT_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.PRORATE_WT_FLAG,'!!!') <> NVL(p_out_rec.PRORATE_WT_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'PRORATE_WT_FLAG, ';
  END IF;
  --
  IF     p_user_in_rec.WEIGHT_UOM_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.WEIGHT_UOM_CODE,'!!!') <> NVL(p_out_rec.WEIGHT_UOM_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'WEIGHT_UOM_CODE, ';
  END IF;

  IF     p_user_in_rec.VOLUME <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.VOLUME,-99) <> NVL(p_out_rec.VOLUME,-99)
  THEN
       l_attributes := l_attributes || 'VOLUME, ';
  END IF;

  IF     p_user_in_rec.VOLUME_UOM_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.VOLUME_UOM_CODE,'!!!') <> NVL(p_out_rec.VOLUME_UOM_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'VOLUME_UOM_CODE, ';
  END IF;

  IF     p_user_in_rec.ADDITIONAL_SHIPMENT_INFO <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ADDITIONAL_SHIPMENT_INFO,'!!!') <> NVL(p_out_rec.ADDITIONAL_SHIPMENT_INFO,'!!!')
  THEN
       l_attributes := l_attributes || 'ADDITIONAL_SHIPMENT_INFO, ';
  END IF;

  IF     p_user_in_rec.CURRENCY_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CURRENCY_CODE,'!!!') <> NVL(p_out_rec.CURRENCY_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'CURRENCY_CODE, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE_CATEGORY,'!!!') <> NVL(p_out_rec.ATTRIBUTE_CATEGORY,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE_CATEGORY, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE1 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE1,'!!!') <> NVL(p_out_rec.ATTRIBUTE1,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE1, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE2 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE2,'!!!') <> NVL(p_out_rec.ATTRIBUTE2,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE2, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE3 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE3,'!!!') <> NVL(p_out_rec.ATTRIBUTE3,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE3, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE4 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE4,'!!!') <> NVL(p_out_rec.ATTRIBUTE4,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE4, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE5 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE5,'!!!') <> NVL(p_out_rec.ATTRIBUTE5,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE5, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE6 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE6,'!!!') <> NVL(p_out_rec.ATTRIBUTE6,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE6, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE7 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE7,'!!!') <> NVL(p_out_rec.ATTRIBUTE7,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE7, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE8 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE8,'!!!') <> NVL(p_out_rec.ATTRIBUTE8,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE8, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE9 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE9,'!!!') <> NVL(p_out_rec.ATTRIBUTE9,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE9, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE10 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE10,'!!!') <> NVL(p_out_rec.ATTRIBUTE10,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE10, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE11 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE11,'!!!') <> NVL(p_out_rec.ATTRIBUTE11,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE11, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE12 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE12,'!!!') <> NVL(p_out_rec.ATTRIBUTE12,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE12, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE13 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE13,'!!!') <> NVL(p_out_rec.ATTRIBUTE13,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE13, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE14 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE14,'!!!') <> NVL(p_out_rec.ATTRIBUTE14,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE14, ';
  END IF;

  IF     p_user_in_rec.ATTRIBUTE15 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ATTRIBUTE15,'!!!') <> NVL(p_out_rec.ATTRIBUTE15,'!!!')
  THEN
       l_attributes := l_attributes || 'ATTRIBUTE15, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE_CATEGORY,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE_CATEGORY,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE_CATEGORY, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE1 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE1,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE1,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE1, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE2 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE2,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE2,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE2, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE3 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE3,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE3,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE3, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE4 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE4,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE4,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE4, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE5 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE5,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE5,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE5, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE6 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE6,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE6,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE6, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE7 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE7,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE7,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE7, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE8 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE8,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE8,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE8, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE9 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE9,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE9,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE9, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE10 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE10,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE10,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE10, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE11 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE11,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE11,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE11, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE12 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE12,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE12,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE12, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE13 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE13,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE13,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE13, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE14 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE14,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE14,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE14, ';
  END IF;

  IF     p_user_in_rec.TP_ATTRIBUTE15 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_ATTRIBUTE15,'!!!') <> NVL(p_out_rec.TP_ATTRIBUTE15,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_ATTRIBUTE15, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE_CATEGORY,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE_CATEGORY,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE_CATEGORY, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE1 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE1,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE1,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE1, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE2 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE2,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE2,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE2, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE3 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE3,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE3,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE3, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE4 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE4,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE4,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE4, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE5 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE5,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE5,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE5, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE6 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE6,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE6,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE6, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE7 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE7,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE7,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE7, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE8 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE8,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE8,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE8, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE9 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE9,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE9,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE9, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE10 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE10,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE10,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE10, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE11 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE11,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE11,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE11, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE12 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE12,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE12,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE12, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE13 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE13,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE13,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE13, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE14 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE14,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE14,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE14, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE15 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE15,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE15,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE15, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE16 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE16,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE16,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE16, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE17 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE17,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE17,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE17, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE18 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE18,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE18,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE18, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE19 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE19,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE19,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE19, ';
  END IF;

  IF     p_user_in_rec.GLOBAL_ATTRIBUTE20 <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.GLOBAL_ATTRIBUTE20,'!!!') <> NVL(p_out_rec.GLOBAL_ATTRIBUTE20,'!!!')
  THEN
       l_attributes := l_attributes || 'GLOBAL_ATTRIBUTE20, ';
  END IF;

 /**
  -- Bug 3613650 - Need not compare standard WHO columns
  --
  IF     p_user_in_rec.CREATION_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.CREATION_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.CREATION_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'CREATION_DATE, ';
  END IF;

  IF     p_user_in_rec.CREATED_BY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.CREATED_BY,-99) <> NVL(p_out_rec.CREATED_BY,-99)
  THEN
       l_attributes := l_attributes || 'CREATED_BY, ';
  END IF;

  IF     p_user_in_rec.LAST_UPDATE_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.LAST_UPDATE_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.LAST_UPDATE_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'LAST_UPDATE_DATE, ';
  END IF;

  IF     p_user_in_rec.LAST_UPDATED_BY <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.LAST_UPDATED_BY,-99) <> NVL(p_out_rec.LAST_UPDATED_BY,-99)
  THEN
       l_attributes := l_attributes || 'LAST_UPDATED_BY, ';
  END IF;

  IF     p_user_in_rec.LAST_UPDATE_LOGIN <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.LAST_UPDATE_LOGIN,-99) <> NVL(p_out_rec.LAST_UPDATE_LOGIN,-99)
  THEN
       l_attributes := l_attributes || 'LAST_UPDATE_LOGIN, ';
  END IF;

  IF     p_user_in_rec.PROGRAM_APPLICATION_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.PROGRAM_APPLICATION_ID,-99) <> NVL(p_out_rec.PROGRAM_APPLICATION_ID,-99)
  THEN
       l_attributes := l_attributes || 'PROGRAM_APPLICATION_ID, ';
  END IF;

  IF     p_user_in_rec.PROGRAM_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.PROGRAM_ID,-99) <> NVL(p_out_rec.PROGRAM_ID,-99)
  THEN
       l_attributes := l_attributes || 'PROGRAM_ID, ';
  END IF;

  IF     p_user_in_rec.PROGRAM_UPDATE_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.PROGRAM_UPDATE_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.PROGRAM_UPDATE_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'PROGRAM_UPDATE_DATE, ';
  END IF;

  IF     p_user_in_rec.REQUEST_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.REQUEST_ID,-99) <> NVL(p_out_rec.REQUEST_ID,-99)
  THEN
       l_attributes := l_attributes || 'REQUEST_ID, ';
  END IF;
  **/

  IF     p_user_in_rec.BATCH_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.BATCH_ID,-99) <> NVL(p_out_rec.BATCH_ID,-99)
  THEN
       l_attributes := l_attributes || 'BATCH_ID, ';
  END IF;

  IF     p_user_in_rec.HASH_VALUE <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.HASH_VALUE,-99) <> NVL(p_out_rec.HASH_VALUE,-99)
  THEN
       l_attributes := l_attributes || 'HASH_VALUE, ';
  END IF;

  IF     p_user_in_rec.SOURCE_HEADER_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.SOURCE_HEADER_ID,-99) <> NVL(p_out_rec.SOURCE_HEADER_ID,-99)
  THEN
       l_attributes := l_attributes || 'SOURCE_HEADER_ID, ';
  END IF;

  IF     p_user_in_rec.NUMBER_OF_LPN <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.NUMBER_OF_LPN,-99) <> NVL(p_out_rec.NUMBER_OF_LPN,-99)
  THEN
       l_attributes := l_attributes || 'NUMBER_OF_LPN, ';
  END IF;

  IF     p_user_in_rec.COD_AMOUNT <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.COD_AMOUNT,-99) <> NVL(p_out_rec.COD_AMOUNT,-99)
  THEN
       l_attributes := l_attributes || 'COD_AMOUNT, ';
  END IF;

  IF     p_user_in_rec.COD_CURRENCY_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.COD_CURRENCY_CODE,'!!!') <> NVL(p_out_rec.COD_CURRENCY_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'COD_CURRENCY_CODE, ';
  END IF;

  IF     p_user_in_rec.COD_REMIT_TO <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.COD_REMIT_TO,'!!!') <> NVL(p_out_rec.COD_REMIT_TO,'!!!')
  THEN
       l_attributes := l_attributes || 'COD_REMIT_TO, ';
  END IF;

  IF     p_user_in_rec.COD_CHARGE_PAID_BY <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.COD_CHARGE_PAID_BY,'!!!') <> NVL(p_out_rec.COD_CHARGE_PAID_BY,'!!!')
  THEN
       l_attributes := l_attributes || 'COD_CHARGE_PAID_BY, ';
  END IF;

  IF     p_user_in_rec.PROBLEM_CONTACT_REFERENCE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.PROBLEM_CONTACT_REFERENCE,'!!!') <> NVL(p_out_rec.PROBLEM_CONTACT_REFERENCE,'!!!')
  THEN
       l_attributes := l_attributes || 'PROBLEM_CONTACT_REFERENCE, ';
  END IF;

  IF     p_user_in_rec.PORT_OF_LOADING <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.PORT_OF_LOADING,'!!!') <> NVL(p_out_rec.PORT_OF_LOADING,'!!!')
  THEN
       l_attributes := l_attributes || 'PORT_OF_LOADING, ';
  END IF;

  IF     p_user_in_rec.PORT_OF_DISCHARGE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.PORT_OF_DISCHARGE,'!!!') <> NVL(p_out_rec.PORT_OF_DISCHARGE,'!!!')
  THEN
       l_attributes := l_attributes || 'PORT_OF_DISCHARGE, ';
  END IF;

  IF     p_user_in_rec.FTZ_NUMBER <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.FTZ_NUMBER,'!!!') <> NVL(p_out_rec.FTZ_NUMBER,'!!!')
  THEN
       l_attributes := l_attributes || 'FTZ_NUMBER, ';
  END IF;

  IF     p_user_in_rec.ROUTED_EXPORT_TXN <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ROUTED_EXPORT_TXN,'!!!') <> NVL(p_out_rec.ROUTED_EXPORT_TXN,'!!!')
  THEN
       l_attributes := l_attributes || 'ROUTED_EXPORT_TXN, ';
  END IF;

  IF     p_user_in_rec.ENTRY_NUMBER <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ENTRY_NUMBER,'!!!') <> NVL(p_out_rec.ENTRY_NUMBER,'!!!')
  THEN
       l_attributes := l_attributes || 'ENTRY_NUMBER, ';
  END IF;

  IF     p_user_in_rec.ROUTING_INSTRUCTIONS <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ROUTING_INSTRUCTIONS,'!!!') <> NVL(p_out_rec.ROUTING_INSTRUCTIONS,'!!!')
  THEN
       l_attributes := l_attributes || 'ROUTING_INSTRUCTIONS, ';
  END IF;

  IF     p_user_in_rec.IN_BOND_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.IN_BOND_CODE,'!!!') <> NVL(p_out_rec.IN_BOND_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'IN_BOND_CODE, ';
  END IF;

  IF     p_user_in_rec.SHIPPING_MARKS <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SHIPPING_MARKS,'!!!') <> NVL(p_out_rec.SHIPPING_MARKS,'!!!')
  THEN
       l_attributes := l_attributes || 'SHIPPING_MARKS, ';
  END IF;

  IF     p_user_in_rec.SERVICE_LEVEL <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SERVICE_LEVEL,'!!!') <> NVL(p_out_rec.SERVICE_LEVEL,'!!!')
  THEN
       l_attributes := l_attributes || 'SERVICE_LEVEL, ';
  END IF;

  IF     p_user_in_rec.MODE_OF_TRANSPORT <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.MODE_OF_TRANSPORT,'!!!') <> NVL(p_out_rec.MODE_OF_TRANSPORT,'!!!')
  THEN
       l_attributes := l_attributes || 'MODE_OF_TRANSPORT, ';
  END IF;

  IF     p_user_in_rec.ASSIGNED_TO_FTE_TRIPS <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ASSIGNED_TO_FTE_TRIPS,'!!!') <> NVL(p_out_rec.ASSIGNED_TO_FTE_TRIPS,'!!!')
  THEN
       l_attributes := l_attributes || 'ASSIGNED_TO_FTE_TRIPS, ';
  END IF;

  IF     p_user_in_rec.AUTO_SC_EXCLUDE_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.AUTO_SC_EXCLUDE_FLAG,'!!!') <> NVL(p_out_rec.AUTO_SC_EXCLUDE_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'AUTO_SC_EXCLUDE_FLAG, ';
  END IF;

  IF     p_user_in_rec.AUTO_AP_EXCLUDE_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.AUTO_AP_EXCLUDE_FLAG,'!!!') <> NVL(p_out_rec.AUTO_AP_EXCLUDE_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'AUTO_AP_EXCLUDE_FLAG, ';
  END IF;

  IF     p_user_in_rec.AP_BATCH_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.AP_BATCH_ID,-99) <> NVL(p_out_rec.AP_BATCH_ID,-99)
  THEN
       l_attributes := l_attributes || 'AP_BATCH_ID, ';
  END IF;

  IF     p_user_in_rec.ROWID <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ROWID,'!!!') <> NVL(p_out_rec.ROWID,'!!!')
  THEN
       l_attributes := l_attributes || 'ROWID, ';
  END IF;

  IF     p_user_in_rec.LOADING_ORDER_DESC <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.LOADING_ORDER_DESC,'!!!') <> NVL(p_out_rec.LOADING_ORDER_DESC,'!!!')
  THEN
       l_attributes := l_attributes || 'LOADING_ORDER_DESC, ';
  END IF;

  IF     p_user_in_rec.ORGANIZATION_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ORGANIZATION_CODE,'!!!') <> NVL(p_out_rec.ORGANIZATION_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'ORGANIZATION_CODE, ';
  END IF;

  IF     p_user_in_rec.ULTIMATE_DROPOFF_LOCATION_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.ULTIMATE_DROPOFF_LOCATION_CODE,'!!!') <> NVL(p_out_rec.ULTIMATE_DROPOFF_LOCATION_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'ULTIMATE_DROPOFF_LOCATION_CODE, ';
  END IF;

  IF     p_user_in_rec.INITIAL_PICKUP_LOCATION_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.INITIAL_PICKUP_LOCATION_CODE,'!!!') <> NVL(p_out_rec.INITIAL_PICKUP_LOCATION_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'INITIAL_PICKUP_LOCATION_CODE, ';
  END IF;

  IF     p_user_in_rec.CUSTOMER_NUMBER <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CUSTOMER_NUMBER,'!!!') <> NVL(p_out_rec.CUSTOMER_NUMBER,'!!!')
  THEN
       l_attributes := l_attributes || 'CUSTOMER_NUMBER, ';
  END IF;
  -- LSP PROJECT
  IF     p_user_in_rec.CLIENT_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CLIENT_CODE,'!!!') <> NVL(p_out_rec.CLIENT_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'CLIENT_CODE, ';
  END IF;
  -- LSP PROJECT.

  IF     p_user_in_rec.INTMED_SHIP_TO_LOCATION_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.INTMED_SHIP_TO_LOCATION_CODE,'!!!') <> NVL(p_out_rec.INTMED_SHIP_TO_LOCATION_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'INTMED_SHIP_TO_LOCATION_CODE, ';
  END IF;

  IF     p_user_in_rec.POOLED_SHIP_TO_LOCATION_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.POOLED_SHIP_TO_LOCATION_CODE,'!!!') <> NVL(p_out_rec.POOLED_SHIP_TO_LOCATION_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'POOLED_SHIP_TO_LOCATION_CODE, ';
  END IF;

  IF     p_user_in_rec.CARRIER_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CARRIER_CODE,'!!!') <> NVL(p_out_rec.CARRIER_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'CARRIER_CODE, ';
  END IF;

  IF     p_user_in_rec.SHIP_METHOD_NAME <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SHIP_METHOD_NAME,'!!!') <> NVL(p_out_rec.SHIP_METHOD_NAME,'!!!')
  THEN
       l_attributes := l_attributes || 'SHIP_METHOD_NAME, ';
  END IF;

  IF     p_user_in_rec.FREIGHT_TERMS_NAME <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.FREIGHT_TERMS_NAME,'!!!') <> NVL(p_out_rec.FREIGHT_TERMS_NAME,'!!!')
  THEN
       l_attributes := l_attributes || 'FREIGHT_TERMS_NAME, ';
  END IF;

  IF     p_user_in_rec.FOB_NAME <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.FOB_NAME,'!!!') <> NVL(p_out_rec.FOB_NAME,'!!!')
  THEN
       l_attributes := l_attributes || 'FOB_NAME, ';
  END IF;

  IF     p_user_in_rec.FOB_LOCATION_CODE <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.FOB_LOCATION_CODE,'!!!') <> NVL(p_out_rec.FOB_LOCATION_CODE,'!!!')
  THEN
       l_attributes := l_attributes || 'FOB_LOCATION_CODE, ';
  END IF;

  IF     p_user_in_rec.WEIGHT_UOM_DESC <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.WEIGHT_UOM_DESC,'!!!') <> NVL(p_out_rec.WEIGHT_UOM_DESC,'!!!')
  THEN
       l_attributes := l_attributes || 'WEIGHT_UOM_DESC, ';
  END IF;

  IF     p_user_in_rec.VOLUME_UOM_DESC <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.VOLUME_UOM_DESC,'!!!') <> NVL(p_out_rec.VOLUME_UOM_DESC,'!!!')
  THEN
       l_attributes := l_attributes || 'VOLUME_UOM_DESC, ';
  END IF;

  IF     p_user_in_rec.CURRENCY_NAME <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.CURRENCY_NAME,'!!!') <> NVL(p_out_rec.CURRENCY_NAME,'!!!')
  THEN
       l_attributes := l_attributes || 'CURRENCY_NAME, ';
  END IF;

  IF     p_user_in_rec.SHIPMENT_DIRECTION <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SHIPMENT_DIRECTION,'!!!') <> NVL(p_out_rec.SHIPMENT_DIRECTION,'!!!')
  THEN
       l_attributes := l_attributes || 'SHIPMENT_DIRECTION, ';
  END IF;

  IF     p_user_in_rec.VENDOR_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.VENDOR_ID,-99) <> NVL(p_out_rec.VENDOR_ID,-99)
  THEN
       l_attributes := l_attributes || 'VENDOR_ID, ';
  END IF;

  IF     p_user_in_rec.PARTY_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.PARTY_ID,-99) <> NVL(p_out_rec.PARTY_ID,-99)
  THEN
       l_attributes := l_attributes || 'PARTY_ID, ';
  END IF;

  IF     p_user_in_rec.ROUTING_RESPONSE_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.ROUTING_RESPONSE_ID,-99) <> NVL(p_out_rec.ROUTING_RESPONSE_ID,-99)
  THEN
       l_attributes := l_attributes || 'ROUTING_RESPONSE_ID, ';
  END IF;

  IF     p_user_in_rec.RCV_SHIPMENT_HEADER_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.RCV_SHIPMENT_HEADER_ID,-99) <> NVL(p_out_rec.RCV_SHIPMENT_HEADER_ID,-99)
  THEN
       l_attributes := l_attributes || 'RCV_SHIPMENT_HEADER_ID, ';
  END IF;

  IF     p_user_in_rec.ASN_SHIPMENT_HEADER_ID <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.ASN_SHIPMENT_HEADER_ID,-99) <> NVL(p_out_rec.ASN_SHIPMENT_HEADER_ID,-99)
  THEN
       l_attributes := l_attributes || 'ASN_SHIPMENT_HEADER_ID, ';
  END IF;

  IF     p_user_in_rec.SHIPPING_CONTROL <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.SHIPPING_CONTROL,'!!!') <> NVL(p_out_rec.SHIPPING_CONTROL,'!!!')
  THEN
       l_attributes := l_attributes || 'SHIPPING_CONTROL, ';
  END IF;

  IF     p_user_in_rec.TP_DELIVERY_NUMBER <> FND_API.G_MISS_NUM
      AND NVL(p_user_in_rec.TP_DELIVERY_NUMBER,-99) <> NVL(p_out_rec.TP_DELIVERY_NUMBER,-99)
  THEN
       l_attributes := l_attributes || 'TP_DELIVERY_NUMBER, ';
  END IF;

  IF     p_user_in_rec.EARLIEST_PICKUP_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.EARLIEST_PICKUP_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.EARLIEST_PICKUP_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'EARLIEST_PICKUP_DATE, ';
  END IF;

  IF     p_user_in_rec.LATEST_PICKUP_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.LATEST_PICKUP_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.LATEST_PICKUP_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'LATEST_PICKUP_DATE, ';
  END IF;

  IF     p_user_in_rec.EARLIEST_DROPOFF_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.EARLIEST_DROPOFF_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.EARLIEST_DROPOFF_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'EARLIEST_DROPOFF_DATE, ';
  END IF;

  IF     p_user_in_rec.LATEST_DROPOFF_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.LATEST_DROPOFF_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.LATEST_DROPOFF_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'LATEST_DROPOFF_DATE, ';
  END IF;

  IF     p_user_in_rec.IGNORE_FOR_PLANNING <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.IGNORE_FOR_PLANNING,'!!!') <> NVL(p_out_rec.IGNORE_FOR_PLANNING,'!!!')
  THEN
       l_attributes := l_attributes || 'IGNORE_FOR_PLANNING, ';
  END IF;

  IF     p_user_in_rec.TP_PLAN_NAME <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.TP_PLAN_NAME,'!!!') <> NVL(p_out_rec.TP_PLAN_NAME,'!!!')
  THEN
       l_attributes := l_attributes || 'TP_PLAN_NAME, ';
  END IF;

  IF     p_user_in_rec.WV_FROZEN_FLAG <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.WV_FROZEN_FLAG,'!!!') <> NVL(p_out_rec.WV_FROZEN_FLAG,'!!!')
  THEN
       l_attributes := l_attributes || 'WV_FROZEN_FLAG, ';
  END IF;

  IF     p_user_in_rec.HASH_STRING <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.HASH_STRING,'!!!') <> NVL(p_out_rec.HASH_STRING,'!!!')
  THEN
       l_attributes := l_attributes || 'HASH_STRING, ';
  END IF;

  IF     p_user_in_rec.DELIVERED_DATE <> FND_API.G_MISS_DATE
      AND NVL(p_user_in_rec.DELIVERED_DATE,TO_DATE('2','j')) <> NVL(p_out_rec.DELIVERED_DATE,TO_DATE('2','j'))
  THEN
       l_attributes := l_attributes || 'DELIVERED_DATE, ';
  END IF;

  IF     p_user_in_rec.PACKING_SLIP <> FND_API.G_MISS_CHAR
      AND NVL(p_user_in_rec.PACKING_SLIP,'!!!') <> NVL(p_out_rec.PACKING_SLIP,'!!!')
  THEN
       l_attributes := l_attributes || 'PACKING_SLIP, ';
  END IF;

  IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_attributes',l_attributes);
       WSH_DEBUG_SV.log(l_module_name,'length(l_attributes)',length(l_attributes));
  END IF;


  IF l_attributes IS NULL    THEN
     --no message to be shown to the user
     IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN;
  ELSE
     Wsh_Utilities.process_message(
                                    p_entity => 'DLVY',
                                    p_entity_name => NVL(p_out_rec.NAME,p_out_rec.DELIVERY_ID),
                                    p_attributes => l_attributes,
                                    x_return_status => l_return_status
				  );

     IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
     THEN
       x_return_status := l_return_status;
       IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name,'Error returned by wsh_utilities.process_message',WSH_DEBUG_SV.C_PROC_LEVEL);
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         wsh_debug_sv.pop(l_module_name);
       END IF;
       return;
     ELSE
       x_return_status := wsh_util_core.G_RET_STS_WARNING;
     END IF;
  END IF;



  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --


EXCEPTION
    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END user_non_updatable_columns;

--Function added for Bugfix 3562492
--========================================================================
-- FUNCTION : Is_del_eligible_pick
--
-- PARAMETERS:
--             x_return_status         return status
--             p_delivery_id             Delivery ID
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This Function checks whether a Delivery id is eligible for Pick Release
--             , if a Delivery is eligible it returns TRUE else it returns FALSE.
--             The return status of this Function is always Success except in case
--             of unexpected error.
--========================================================================
FUNCTION  Is_del_eligible_pick(
                      p_delivery_id  IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

    cursor c_detail (p_delivery_id NUMBER) is
    select 1
    from wsh_delivery_details wdd,
    wsh_delivery_assignments_v wda
    where wdd.delivery_detail_id = wda.delivery_detail_id
    and wdd.released_status in ('R','B','X')
    and nvl(wdd.replenishment_status,'C') = 'C'   --bug# 6719369 (replenishment project)
    and wdd.source_code = 'OE'
    and wda.delivery_id = p_delivery_id
    and rownum =1;

    l_del_det_exists  NUMBER;
    l_debug_on BOOLEAN;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'IS_DEL_ELIGIBLE_PICK';
    l_is_del_eligible BOOLEAN;

BEGIN
      --
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL
      THEN
           l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
        --
      x_return_status := wsh_util_core.G_RET_STS_SUCCESS;
      l_is_del_eligible := FALSE;

      IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          WSH_DEBUG_SV.log(l_module_name,'p_delivery_id', p_delivery_id);
      END IF;

      OPEN c_detail(p_delivery_id);
      FETCH c_detail into l_del_det_exists;

      IF c_detail%FOUND THEN
          l_is_del_eligible := TRUE;
      END IF;

      CLOSE c_detail;
      RETURN l_is_del_eligible;

EXCEPTION
     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        WSH_UTIL_CORE.default_handler('WSH_DELIVERIES_GRP.is_del_eligible_pick');
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
        END IF;
	RETURN FALSE;

END Is_del_eligible_pick;

  --OTM R12
  --------------------------------------------------------
  -- PROCEDURE GET_TRIP_INFORMATION
  --
  -- parameters:	p_delivery_id	delivery id to search for trip
  --			x_trip_info_rec record of trip information for the delivery
  --			x_return_status	return status
  --
  -- Description: Find trip information for the Input delivery
  -- Added for EBS-OTM Integration
  --------------------------------------------------------
  PROCEDURE GET_TRIP_INFORMATION
  (p_delivery_id     	         IN         NUMBER,
   x_trip_info_rec               OUT NOCOPY TRIP_INFO_REC_TYPE,
   x_return_status               OUT NOCOPY VARCHAR2
  ) IS

  --this query returns first trip for the delivery.
  CURSOR c_get_trip_info(p_del_id IN NUMBER) IS
    SELECT wt.trip_id,
           wt.name,
           wt.status_code
    FROM   wsh_trip_stops wts,
           wsh_delivery_legs wdl,
           wsh_trips wt,
           wsh_new_deliveries wnd
    WHERE  wnd.delivery_id = p_del_id
    AND    wdl.delivery_id = wnd.delivery_id
    AND    wdl.pick_up_stop_id = wts.stop_id
    AND    wnd.initial_pickup_location_id = wts.stop_location_id
    AND    wts.trip_id = wt.trip_id;

  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_TRIP_INFORMATION';

  BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'delivery id', p_delivery_id);
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    -- Need to validate the input.
    IF p_delivery_id IS NOT NULL THEN

      OPEN c_get_trip_info(p_delivery_id);
      FETCH c_get_trip_info INTO x_trip_info_rec.trip_id,
                                 x_trip_info_rec.name,
                                 x_trip_info_rec.status_code;
      CLOSE c_get_trip_info;

    END IF;


    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'trip id', x_trip_info_rec.trip_id);
      WSH_DEBUG_SV.log(l_module_name, 'trip name', x_trip_info_rec.name);
      WSH_DEBUG_SV.log(l_module_name, 'trip status code', x_trip_info_rec.status_code);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
  EXCEPTION

    WHEN Others THEN
      IF (c_get_trip_info%ISOPEN) THEN
        CLOSE c_get_trip_info;
      END IF;
      WSH_UTIL_CORE.Default_Handler('WSH_DELIVERY_VALIDATIONS.GET_TRIP_INFORMATION', l_module_name);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
  END GET_TRIP_INFORMATION;

  -------------------------------------------------------------------------------
  --  Procedure:   GET_DELIVERY_INFORMATION
  --  Parameters:  x_delivery_rec: A record of all attributes of a Delivery Record
  --               p_delivery_id : delivery_id of the delivery that is to be copied
  --  Description: This procedure will copy the attributes of a delivery in wsh_new_deliveries
  --               and copy it to a record.
  -------------------------------------------------------------------------------

  PROCEDURE GET_DELIVERY_INFORMATION
  (p_delivery_id   IN         NUMBER,
   x_delivery_rec  OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
   x_return_status OUT NOCOPY VARCHAR2) IS

  CURSOR c_get_delivery_info (p_delivery_id IN NUMBER) IS
  SELECT DELIVERY_ID
        ,NAME
        ,PLANNED_FLAG
        ,STATUS_CODE
        ,DELIVERY_TYPE
        ,INITIAL_PICKUP_LOCATION_ID
        ,ORGANIZATION_ID
        ,ULTIMATE_DROPOFF_LOCATION_ID
        ,CARRIER_ID
        ,SHIP_METHOD_CODE
        ,FREIGHT_TERMS_CODE
        ,FOB_CODE
        ,CURRENCY_CODE
        ,SERVICE_LEVEL
        ,MODE_OF_TRANSPORT
        ,EARLIEST_PICKUP_DATE
        ,LATEST_PICKUP_DATE
        ,EARLIEST_DROPOFF_DATE
        ,LATEST_DROPOFF_DATE
        ,NVL(IGNORE_FOR_PLANNING, 'N')
        ,TP_PLAN_NAME
        ,WV_FROZEN_FLAG
        ,TMS_INTERFACE_FLAG
        ,TMS_VERSION_NUMBER
        ,client_id    -- LSP PROJECT (used in wshddacb. assign_dd_to_del
  FROM wsh_new_deliveries
  WHERE delivery_id = p_delivery_id;

  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DELIVERY_INFORMATION';

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
      WSH_DEBUG_SV.log(l_module_name,'p_delivery_id', p_delivery_id);
    END IF;
    --

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    OPEN c_get_delivery_info (p_delivery_id);
    FETCH c_get_delivery_info INTO x_delivery_rec.delivery_id,
                                   x_delivery_rec.name,
                                   x_delivery_rec.planned_flag,
                                   x_delivery_rec.status_code,
                                   x_delivery_rec.delivery_type,
                                   x_delivery_rec.initial_pickup_location_id,
                                   x_delivery_rec.organization_id,
                                   x_delivery_rec.ultimate_dropoff_location_id,
                                   x_delivery_rec.carrier_id,
                                   x_delivery_rec.ship_method_code,
                                   x_delivery_rec.freight_terms_code,
                                   x_delivery_rec.fob_code,
                                   x_delivery_rec.currency_code,
                                   x_delivery_rec.service_level,
                                   x_delivery_rec.mode_of_transport,
                                   x_delivery_rec.earliest_pickup_date,
                                   x_delivery_rec.latest_pickup_date,
                                   x_delivery_rec.earliest_dropoff_date,
                                   x_delivery_rec.latest_dropoff_date,
                                   x_delivery_rec.ignore_for_planning,
                                   x_delivery_rec.tp_plan_name,
                                   x_delivery_rec.wv_frozen_flag,
                                   x_delivery_rec.tms_interface_flag,
                                   x_delivery_rec.tms_version_number,
                                   x_delivery_rec.client_id; -- LSP PROJECT.

    IF c_get_delivery_info%NOTFOUND THEN

      CLOSE c_get_delivery_info;
      RAISE no_data_found;

    END IF;
    CLOSE c_get_delivery_info;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF c_get_delivery_info%ISOPEN THEN
        CLOSE c_get_delivery_info;
      END IF;

      FND_MESSAGE.Set_Name('WSH','WSH_DEL_NOT_FOUND');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
      END IF;
      --
    WHEN OTHERS THEN
      IF c_get_delivery_info%ISOPEN THEN
        CLOSE c_get_delivery_info;
      END IF;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      wsh_util_core.default_handler('WSH_DELIVERY_VALIDATION.get_delivery_information',l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  END GET_DELIVERY_INFORMATION;

  --END OTM R12

END WSH_DELIVERY_VALIDATIONS;

/
