--------------------------------------------------------
--  DDL for Package Body WSH_OTM_SYNC_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_OTM_SYNC_ITEM_PKG" AS
/* $Header: WSHTMITB.pls 120.0.12000000.2 2007/04/02 17:42:21 schennal noship $ */

G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_OTM_SYNC_ITEM_PKG';

-----------------------------------------------------------------------------
--
-- Function	:get_EBS_item_info
-- Parameters	:p_entity_in_rec is the input rec type.
--		It has the entity_type, entity id and parent entity id
--		x_transmission_id Transmission id passed to the caller
--		x_return_status Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
-- Description	:This Function takes input from the txn service and passes
--		the item data back. The item data is passed in the form of
--		of collection WSH_OTM_GLOG_ITEM_TBL thats maps to
--		GLOG Schema ITEMMASTER
-----------------------------------------------------------------------------
FUNCTION get_EBS_item_info(	p_entity_in_rec IN WSH_OTM_ENTITY_REC_TYPE,
				x_transmission_id OUT NOCOPY NUMBER,
				x_return_status OUT NOCOPY VARCHAR2
			  ) RETURN WSH_OTM_GLOG_ITEM_TBL IS


--Bug#5961151: added substrb for item description as OTM can accept only 120 characters.
CURSOR	c_get_delivery_items(p_delivery_id NUMBER) IS
SELECT	mtlb.inventory_item_id,
	mtlk.concatenated_segments,
        substrb(mtlt.description,1,120),
	mtlb.last_update_date,
	mtlb.organization_id
FROM	wsh_delivery_assignments wda,
	wsh_delivery_details wdd,
	mtl_system_items_b mtlb,
	mtl_system_items_tl mtlt,
	mtl_system_items_kfv mtlk
WHERE	wda.delivery_id = p_delivery_id
AND	wda.delivery_detail_id = wdd.delivery_detail_id
AND	wdd.inventory_item_id = mtlb.inventory_item_id
AND	wdd.inventory_item_id = mtlt.inventory_item_id
AND	wdd.inventory_item_id = mtlk.inventory_item_id
AND	wdd.organization_id = mtlb.organization_id
AND	wdd.organization_id = mtlk.organization_id
AND	wdd.organization_id = mtlt.organization_id
AND	mtlb.shippable_item_flag = 'Y'
AND	mtlk.shippable_item_flag = 'Y'
AND	mtlt.language = userenv('LANG');

--Bug#5961151: added substrb for item description as OTM can accept only 120 characters.
CURSOR	c_get_trip_items(p_trip_id NUMBER) IS
SELECT	mtlb.inventory_item_id,
	mtlk.concatenated_segments,
        substrb(mtlt.description,1,120),
	mtlb.last_update_date,
	mtlb.organization_id
FROM	wsh_delivery_assignments wda,
	wsh_delivery_details wdd,
	wsh_delivery_legs wdl,
	wsh_trip_stops wts,
	mtl_system_items_b mtlb,
	mtl_system_items_tl mtlt,
	mtl_system_items_kfv mtlk
WHERE	wts.trip_id = p_trip_id
AND	wts.stop_id = wdl.pick_up_stop_id
AND	wda.delivery_id = wdl.delivery_id
AND	wda.delivery_detail_id = wdd.delivery_detail_id
AND	wdd.inventory_item_id = mtlb.inventory_item_id
AND	wdd.inventory_item_id = mtlt.inventory_item_id
AND	wdd.inventory_item_id = mtlk.inventory_item_id
AND	wdd.organization_id = mtlb.organization_id
AND	wdd.organization_id = mtlk.organization_id
AND	wdd.organization_id = mtlt.organization_id
AND	mtlb.shippable_item_flag = 'Y'
AND	mtlk.shippable_item_flag = 'Y'
AND	mtlt.language = userenv('LANG');

--Cursor to get the new transmission Id
CURSOR	c_get_transmission_id IS
SELECT	wsh_otm_sync_ref_data_log_s.NEXTVAL
FROM	dual;

--Declare are local variables of GLOG record and table types
l_tbl_send_item_info WSH_OTM_GLOG_ITEM_TBL;
l_rec_itemmaster WSH_OTM_ITEMMASTER;

l_rec_item item_info;
l_tbl_item item_info_tbl;

l_delivery_id NUMBER;
l_trip_id NUMBER;

l_item_id NUMBER;
l_item_name VARCHAR2(40);
l_item_description VARCHAR2(240);
l_last_update_date DATE;
l_org_id NUMBER;

l_domain_name VARCHAR2(50);
l_xid VARCHAR2(50);

l_substitute_entity VARCHAR2(50);
l_transmission_id NUMBER;
l_send_allowed BOOLEAN;
l_send_count NUMBER := 0;

e_null_id_error EXCEPTION;
e_entity_type_error EXCEPTION;

l_return_status VARCHAR2(1);
l_debug_on BOOLEAN ;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_EBS_ITEM_INFO';

BEGIN

-- Debug Statements
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
	WSH_DEBUG_SV.push(l_module_name);
	WSH_DEBUG_SV.log(l_module_name,' p_entity_in_rec.ENTITY_TYPE ', p_entity_in_rec.ENTITY_TYPE);
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--Check for number of ids in the input table and if 0 then raise error.
IF p_entity_in_rec.entity_id_tbl.COUNT = 0 THEN
	RAISE e_null_id_error;
END IF;

l_tbl_send_item_info := WSH_OTM_GLOG_ITEM_TBL();
--l_my_table := glog_item_tbl();

--Get the new transmission Id
OPEN c_get_transmission_id;
FETCH c_get_transmission_id INTO l_transmission_id;
CLOSE c_get_transmission_id;

--Get the domain name from the profile value
FND_PROFILE.Get('WSH_OTM_DOMAIN_NAME',l_domain_name);
IF (l_domain_name IS NULL) THEN
--{
	 FND_MESSAGE.SET_NAME('WSH','WSH_PROFILE_NOT_SET_ERR');
	 FND_MESSAGE.SET_TOKEN('PRF_NAME','WSH_OTM_DOMAIN_NAME');
	 x_return_status := wsh_util_core.G_RET_STS_UNEXP_ERROR;
	 wsh_util_core.add_message(x_return_status, l_module_name);
	 IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Error: The profile WSH_OTM_DOMAIN_NAME is set to NULL.  Please correct the profile value');
	 END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--}
END IF;

--For each delivery and trip get the item info and put it into the local table l_tbl_item
IF p_entity_in_rec.ENTITY_TYPE = 'DELIVERY' THEN
	FOR l_loop_count IN p_entity_in_rec.entity_id_tbl.FIRST .. p_entity_in_rec.entity_id_tbl.LAST
	LOOP
		OPEN c_get_delivery_items(p_entity_in_rec.entity_id_tbl(l_loop_count));
		LOOP
			FETCH c_get_delivery_items into l_rec_item;
			EXIT WHEN c_get_delivery_items%NOTFOUND;
			l_tbl_item(l_tbl_item.COUNT+1) := l_rec_item;
		END LOOP;
		CLOSE c_get_delivery_items;
	END LOOP;
ELSIF p_entity_in_rec.ENTITY_TYPE = 'TRIP' THEN
	FOR l_loop_count IN p_entity_in_rec.entity_id_tbl.FIRST .. p_entity_in_rec.entity_id_tbl.LAST
	LOOP
		OPEN c_get_trip_items(p_entity_in_rec.entity_id_tbl(l_loop_count));
		LOOP
			FETCH c_get_trip_items into l_rec_item;
			EXIT WHEN c_get_trip_items%NOTFOUND;
			l_tbl_item(l_tbl_item.COUNT+1) := l_rec_item;
		END LOOP;
		CLOSE c_get_trip_items;
	END LOOP;
ELSE
	RAISE e_entity_type_error;
END IF;

--Search the table l_tbl_item for duplicates and if found then remove them.
IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_OTM_SYNC_ITEM_PKG.REMOVE_DUPLICATE_ITEMS', WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;

IF l_tbl_item.COUNT <> 0 THEN
	remove_duplicate_items(p_item_tbl => l_tbl_item,
			       x_return_status => l_return_status);
END IF;

IF l_tbl_item.COUNT <> 0 THEN
	FOR l_loop_index in l_tbl_item.FIRST .. l_tbl_item.LAST
	LOOP
		l_item_id := l_tbl_item(l_loop_index).item_id;
		l_last_update_date := l_tbl_item(l_loop_index).last_update_date;
		l_item_name := l_tbl_item(l_loop_index).item_name;
		l_item_description := l_tbl_item(l_loop_index).item_description;
		l_org_id := l_tbl_item(l_loop_index).org_id;

		--For each item find whether it has to be sent to GLOG
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_OTM_SYNC_REF_DATA_PKG.IS_REF_DATA_SEND_REQD', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		WSH_OTM_SYNC_REF_DATA_PKG.IS_REF_DATA_SEND_REQD(P_ENTITY_ID => l_item_id,
								P_PARENT_ENTITY_ID => l_org_id,
								P_ENTITY_TYPE => 'ITEM',
								P_ENTITY_UPDATED_DATE => l_last_update_date,
								X_SUBSTITUTE_ENTITY => l_substitute_entity,
								P_TRANSMISSION_ID => l_transmission_id ,
								X_SEND_ALLOWED => l_send_allowed,
								X_RETURN_STATUS => l_return_status
								 );
		--If l_send_allowed is TRUE then populate l_tbl_send_item_info with that item info
		IF l_send_allowed THEN
			--Construct the XID
			l_xid := to_char(l_org_id) || '-' || to_char(l_item_id);
			--Extend the collection.
			l_tbl_send_item_info.EXTEND;
			l_send_count := l_send_count + 1;
			l_tbl_send_item_info(l_send_count) := WSH_OTM_ITEMMASTER(
										WSH_OTM_ITEM_TYPE('IU',
												WSH_OTM_GID_TYPE(WSH_OTM_GID_T(l_domain_name,l_xid)),
												l_item_name,
												l_item_description),
										WSH_OTM_PACKAGING_TYPE(WSH_OTM_GID_TYPE(WSH_OTM_GID_T(l_domain_name,l_xid)),
													l_item_description));
		END IF;
	END LOOP;

END IF;

--Delete the local table l_tbl_item.
l_tbl_item.DELETE;

IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;

--Check for the number of rows in the table.
IF l_send_count = 0 THEN
	-- This means that there are not items to be send and in this case pass the transmission_id = NULL
	x_transmission_id := NULL;
ELSE
	x_transmission_id := l_transmission_id;
END IF;

return l_tbl_send_item_info;

EXCEPTION
WHEN e_null_id_error THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'p_Ids cannot be null',WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NULL_IDS');
		raise;
	END IF;
WHEN e_entity_type_error THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'wrong entity type passed',WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WRONG_ENTITY_TYPE');
		raise;
	END IF;
WHEN OTHERS THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		raise;
	END IF;

END get_EBS_item_info;


-----------------------------------------------------------------------------
--
-- Procedure	:remove_duplicate_items
-- Parameters	:p_item_tbl is the input table of item_info_tbl.
--		x_return_status Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
-- Description	:This procedure take in the input table and removes all the
--		duplicate rows.
-----------------------------------------------------------------------------
PROCEDURE remove_duplicate_items(p_item_tbl IN OUT NOCOPY item_info_tbl,
				 x_return_status OUT NOCOPY VARCHAR2)IS

l_item_id NUMBER;
l_org_id NUMBER;
l_item_tbl item_info_tbl;
l_count NUMBER;

l_debug_on BOOLEAN ;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'REMOVE_DUPLICATE_ITEMS';

BEGIN

-- Debug Statements
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
	WSH_DEBUG_SV.push(l_module_name);
	WSH_DEBUG_SV.log(l_module_name,'No of rows in item_info_tbl ',p_item_tbl.COUNT);
END IF;

l_count := p_item_tbl.COUNT;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

FOR l_loop_count IN p_item_tbl.FIRST .. p_item_tbl.LAST
LOOP
	l_item_id := p_item_tbl(l_loop_count).item_id;
	l_org_id := p_item_tbl(l_loop_count).org_id;
	IF l_item_id IS NOT NULL THEN
		l_item_tbl(l_item_tbl.COUNT+1) := p_item_tbl(l_loop_count);

		FOR l_inner_count IN l_loop_count .. p_item_tbl.LAST
		LOOP
			--Bug 5079207: Added condition to check for org_id also.
			IF p_item_tbl(l_inner_count).item_id = l_item_id AND p_item_tbl(l_inner_count).org_id = l_org_id THEN
				p_item_tbl(l_inner_count) := NULL;
			END IF;
		END LOOP;
	END IF;
END LOOP;

p_item_tbl := l_item_tbl;

EXCEPTION
WHEN OTHERS THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		raise;
	END IF;
END remove_duplicate_items;

END WSH_OTM_SYNC_ITEM_PKG;

/
