--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_DETAILS_PKG" as
/* $Header: WSHDDTHB.pls 120.21.12010000.7 2010/08/13 11:41:12 anvarshn ship $ */


--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DELIVERY_DETAILS_PKG';
--
    --
    --  Procedure:   Create_Delivery_Details
    --  Parameters:  All Attributes of a Delivery Detail Record,
    --			 Row_id out
    --			 Delivery_Detail_id out
    --			 Return_Status out
    --  Description: This procedure will create a delivery detail.
    --               It will return to the use the delivery_detail_id
    --               if not provided as a parameter.
    --

PROCEDURE Create_Delivery_Details(
	p_delivery_details_info	IN WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
	x_rowid		OUT NOCOPY  VARCHAR2,
	x_delivery_detail_id OUT NOCOPY  NUMBER,
	x_return_status	OUT NOCOPY  VARCHAR2
	) IS


CURSOR C_Del_Detail_Rowid
IS SELECT rowid
FROM wsh_delivery_details
WHERE delivery_detail_id = x_delivery_detail_id;

l_row_count NUMBER;
l_container_name varchar2(50);
l_temp_id   NUMBER;
l_cont_dummy_tab WSH_UTIL_CORE.id_tab_type;

l_dd_id_tab WSH_UTIL_CORE.id_tab_type;

others exception;

-- bug 3022644 - Cursor to check whether container name is already exist
CURSOR Get_Exist_Cont(v_cont_name VARCHAR2,v_wms_flag NUMBER) IS
SELECT NVL(MAX(1),0) FROM DUAL
WHERE EXISTS ( SELECT 1 FROM WSH_DELIVERY_DETAILS
               WHERE container_name = v_cont_name
               AND container_flag = 'Y'
	       -- LPN reuse project
	       AND released_status = Decode(v_wms_flag,'Y','X',released_status));
l_cont_cnt NUMBER;
-- end bug 3022644
-- lpn conv
l_container_info_rec        WSH_GLBL_VAR_STRCT_GRP.ContInfoRectype;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DELIVERY_DETAILS';
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
        WSH_DEBUG_SV.log(l_module_name,'p_delivery_details_info.delivery_detail_id',
                         p_delivery_details_info.delivery_detail_id);
        WSH_DEBUG_SV.log(l_module_name,'p_delivery_details_info.container_name',
                         p_delivery_details_info.container_name);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     -- bug 3022644
/* bmso  take out this code once WMS code is ready*/
     IF (p_delivery_details_info.container_flag = 'Y') THEN
        l_container_name := p_delivery_details_info.container_name;
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'CHECK TO SEE IF CONTAINER_NAME ALREADY EXISTS');
        END IF;
        OPEN Get_Exist_Cont(l_container_name,WSH_UTIL_VALIDATE.check_wms_org(p_delivery_details_info.organization_id));
        FETCH Get_Exist_Cont INTO l_cont_cnt;
        CLOSE Get_Exist_Cont;
        IF l_cont_cnt = 1 THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('WSH','WSH_CONT_NAME_DUPLICATE');
           FND_MESSAGE.SET_TOKEN('CONT_NAME',l_container_name);
           WSH_UTIL_CORE.Add_Message(x_return_status);
           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
        END IF;
     END IF;
     -- end bug 3022644

     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'INSIDE PROCEDURE CREATE DELIVERY DETAILS Calling BULK api'  );
     END IF;
     --
     --lpn conv
     l_container_info_rec.lpn_ids(1) := p_delivery_details_info.lpn_id;
     l_container_info_rec.container_names(1) :=
                                     p_delivery_details_info.container_name;

     WSH_DELIVERY_DETAILS_PKG.Create_Delivery_Details_Bulk
       (p_delivery_details_info	=> p_delivery_details_info,
        p_num_of_rec => 1,
        -- lpn conv
        p_container_info_rec    => l_container_info_rec,
	x_return_status => x_return_status,
        x_dd_id_tab => l_dd_id_tab
       );

       x_delivery_detail_id := l_dd_id_tab(1);

          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER INSERTING INTO WSH_DELIVERY_DETAILS'  );
          END IF;
          --
     	OPEN C_Del_Detail_Rowid;
	FETCH C_Del_Detail_Rowid INTO x_rowid;
     	IF (C_Del_Detail_Rowid%NOTFOUND) THEN
     		CLOSE C_Del_Detail_Rowid;
        	RAISE others;
      END IF;
     	CLOSE C_Del_Detail_Rowid;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
	EXCEPTION
		WHEN others THEN
                --
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.CREATE_DELIVERY_DETAILS',l_module_name);
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		END IF;
		--
END Create_Delivery_Details;

/************* BULK OPERATION *****************/

/***********************************
    CREATE_DELIVERY_DETAILS_BULK
***********************************/
    --
    --  Procedure:   Create_Delivery_Details_bulk
    --  keeping old parameters as they were
    --

PROCEDURE Create_Delivery_Details_Bulk(
	p_delivery_details_info	IN WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
        p_num_of_rec    IN NUMBER,
        -- lpn conv
        p_container_info_rec    IN  WSH_GLBL_VAR_STRCT_GRP.ContInfoRectype,
	x_return_status	OUT NOCOPY  VARCHAR2,
        x_dd_id_tab     OUT NOCOPY  WSH_UTIL_CORE.id_tab_type
	) IS

/*
CURSOR C_Del_Detail_Rowid
IS SELECT rowid
FROM wsh_delivery_details
WHERE delivery_detail_id = x_delivery_detail_id;
*/

/* lpn conv
CURSOR C_Del_detail_ID
IS
SELECT wsh_delivery_details_s.nextval
FROM sys.dual;

*/


CURSOR c_get_ship_sets(c_p_set_id NUMBER,
                        c_p_source_code VARCHAR,
                        c_p_source_header_id NUMBER) IS
SELECT  distinct ignore_for_planning
FROM wsh_delivery_details
WHERE
	  ship_set_id = c_p_set_id and
	  source_code = c_p_source_code and
	  source_header_id = c_p_source_header_id;

l_row_count NUMBER;
l_container_name varchar2(50);
l_ignore_for_planning VARCHAR2(1);
l_temp_id   NUMBER;
l_cont_dummy_tab WSH_UTIL_CORE.id_tab_type;

-- 2530743
  l_delivery_details_info          WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
  l_dff_attribute                  WSH_FLEXFIELD_UTILS.FlexfieldAttributeTabType;
  l_dff_context                    VARCHAR2(150);
  l_dff_update_flag                VARCHAR2(1);
  l_dff_ret_status                 VARCHAR2(1);

-- Bug# 5603974: Considering Automotive TP DFF also.
  l_dff_tp_attribute               WSH_FLEXFIELD_UTILS.FlexfieldAttributeTabType;
  l_dff_tp_context                 VARCHAR2(150);
  l_dff_tp_update_flag             VARCHAR2(1);
  l_dff_tp_ret_status              VARCHAR2(1);
  --Variable added for Standalone project
  l_standalone_mode                VARCHAR2(1);

others exception;

l_wh_type VARCHAR2(3);
l_return_status VARCHAR2(1);

l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API
--OTM R12 Org-Specifc
l_gc3_is_installed            VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DELIVERY_DETAILS_BULK';
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
	  WSH_DEBUG_SV.log(l_module_name,'p_delivery_details_info.delivery_detail_id',
                            p_delivery_details_info.delivery_detail_id);
	  WSH_DEBUG_SV.log(l_module_name,'p_delivery_details_info.container_name',
                            p_delivery_details_info.container_name);
          WSH_DEBUG_SV.logmsg(l_module_name, 'INSIDE PROCEDURE CREATE DELIVERY DETAILS_BULK'  );
	END IF;
	--

        --OTM R12 Start Org-Specific
        l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;
        IF l_gc3_is_installed IS NULL THEN
           l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
        END IF;
	IF l_debug_on THEN
	  wsh_debug_sv.log(l_module_name,'l_gc3_is_installed ',
                                          l_gc3_is_installed);
	END IF;
        --OTM R12 End

        --lpn conv
        IF p_delivery_details_info.container_flag = 'Y' THEN
           IF p_container_info_rec.lpn_ids.COUNT = 0
             OR p_container_info_rec.container_names.count = 0
             OR p_container_info_rec.container_names.count <> p_num_of_rec
             OR p_container_info_rec.lpn_ids.count <> p_num_of_rec THEN

	      IF l_debug_on THEN
	        WSH_DEBUG_SV.log(l_module_name,'lpn_ids.count',
                                        p_container_info_rec.lpn_ids.COUNT);
	        WSH_DEBUG_SV.log(l_module_name,'container_names.count',
                                   p_container_info_rec.container_names.count);
              END IF;
              RAISE FND_API.G_EXC_ERROR;

           END IF;
        END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        l_delivery_details_info := p_delivery_details_info;

-- 2530743 : To get Default DFF values

     WSH_FLEXFIELD_UTILS.Get_DFF_Defaults
      (p_flexfield_name    => 'WSH_DELIVERY_DETAILS',
       p_default_values    => l_dff_attribute,
       p_default_context   => l_dff_context,
       p_update_flag       => l_dff_update_flag,
       x_return_status     => l_dff_ret_status);

     IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,' Get_DFF_Defaults,l_return_status',l_dff_tp_ret_status);
          WSH_DEBUG_SV.log(l_module_name,' l_dff_tp_update_flag',l_dff_tp_update_flag);
     END IF;

     IF ( l_dff_ret_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS AND l_dff_update_flag = 'Y' ) THEN
      l_delivery_details_info.attribute_category :=
                  nvl(p_delivery_details_info.attribute_category,l_dff_context );
      l_delivery_details_info.attribute1 :=
                  nvl(p_delivery_details_info.attribute1, l_dff_attribute(1) );
      l_delivery_details_info.attribute2 :=
                  nvl(p_delivery_details_info.attribute2, l_dff_attribute( 2) );
      l_delivery_details_info.attribute3 :=
                  nvl(p_delivery_details_info.attribute3, l_dff_attribute( 3) );
      l_delivery_details_info.attribute4 :=
                  nvl(p_delivery_details_info.attribute4, l_dff_attribute( 4) );
      l_delivery_details_info.attribute5 :=
                  nvl(p_delivery_details_info.attribute5, l_dff_attribute( 5) );
      l_delivery_details_info.attribute6 :=
                  nvl(p_delivery_details_info.attribute6, l_dff_attribute( 6) );
      l_delivery_details_info.attribute7 :=
                  nvl(p_delivery_details_info.attribute7, l_dff_attribute( 7) );
      l_delivery_details_info.attribute8 :=
                  nvl(p_delivery_details_info.attribute8, l_dff_attribute( 8) );
      l_delivery_details_info.attribute9 :=
                  nvl(p_delivery_details_info.attribute9, l_dff_attribute( 9) );
      l_delivery_details_info.attribute10 :=
                  nvl(p_delivery_details_info.attribute10, l_dff_attribute( 10) );
      l_delivery_details_info.attribute11 :=
                  nvl(p_delivery_details_info.attribute11, l_dff_attribute( 11) );
      l_delivery_details_info.attribute12 :=
                  nvl(p_delivery_details_info.attribute12, l_dff_attribute( 12) );
      l_delivery_details_info.attribute13 :=
                  nvl(p_delivery_details_info.attribute13, l_dff_attribute( 13) );
      l_delivery_details_info.attribute14 :=
                  nvl(p_delivery_details_info.attribute14, l_dff_attribute( 14) );
      l_delivery_details_info.attribute15 :=
                  nvl(p_delivery_details_info.attribute15, l_dff_attribute( 15) );
     END IF;

-- Bug# 5603974: Considering Automotive TP DFF also.
     WSH_FLEXFIELD_UTILS.Get_DFF_Defaults
      (p_flexfield_name    => 'WSH_VEA_DELIVERY_DETAILS',
       p_default_values    => l_dff_tp_attribute,
       p_default_context   => l_dff_tp_context,
       p_update_flag       => l_dff_tp_update_flag,
       x_return_status     => l_dff_tp_ret_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,' Get_DFF_Defaults,l_return_status',l_dff_tp_ret_status);
          WSH_DEBUG_SV.log(l_module_name,' l_dff_tp_update_flag',l_dff_tp_update_flag);
        END IF;

     IF ( l_dff_tp_ret_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS AND l_dff_tp_update_flag = 'Y' ) THEN
      l_delivery_details_info.tp_attribute_category :=
                  nvl(p_delivery_details_info.tp_attribute_category,l_dff_tp_context );
      l_delivery_details_info.tp_attribute1 :=
                  nvl(p_delivery_details_info.tp_attribute1, l_dff_tp_attribute(1) );
      l_delivery_details_info.tp_attribute2 :=
                  nvl(p_delivery_details_info.tp_attribute2, l_dff_tp_attribute( 2) );
      l_delivery_details_info.tp_attribute3 :=
                  nvl(p_delivery_details_info.tp_attribute3, l_dff_tp_attribute( 3) );
      l_delivery_details_info.tp_attribute4 :=
                  nvl(p_delivery_details_info.tp_attribute4, l_dff_tp_attribute( 4) );
      l_delivery_details_info.tp_attribute5 :=
                  nvl(p_delivery_details_info.tp_attribute5, l_dff_tp_attribute( 5) );
      l_delivery_details_info.tp_attribute6 :=
                  nvl(p_delivery_details_info.tp_attribute6, l_dff_tp_attribute( 6) );
      l_delivery_details_info.tp_attribute7 :=
                  nvl(p_delivery_details_info.tp_attribute7, l_dff_tp_attribute( 7) );
      l_delivery_details_info.tp_attribute8 :=
                  nvl(p_delivery_details_info.tp_attribute8, l_dff_tp_attribute( 8) );
      l_delivery_details_info.tp_attribute9 :=
                  nvl(p_delivery_details_info.tp_attribute9, l_dff_tp_attribute( 9) );
      l_delivery_details_info.tp_attribute10 :=
                  nvl(p_delivery_details_info.tp_attribute10, l_dff_tp_attribute( 10) );
      l_delivery_details_info.tp_attribute11 :=
                  nvl(p_delivery_details_info.tp_attribute11, l_dff_tp_attribute( 11) );
      l_delivery_details_info.tp_attribute12 :=
                  nvl(p_delivery_details_info.tp_attribute12, l_dff_tp_attribute( 12) );
      l_delivery_details_info.tp_attribute13 :=
                  nvl(p_delivery_details_info.tp_attribute13, l_dff_tp_attribute( 13) );
      l_delivery_details_info.tp_attribute14 :=
                  nvl(p_delivery_details_info.tp_attribute14, l_dff_tp_attribute( 14) );
      l_delivery_details_info.tp_attribute15 :=
                  nvl(p_delivery_details_info.tp_attribute15, l_dff_tp_attribute( 15) );
     END IF;

-- Bug# 5603974: End

-- For Auto Packing, the container name will always
-- be same as delivery detail id
-- only check if the delivery detail has container flag as Y
-- then use delivery detail id

/* lpn conv
-- get the delivery detail id in loop
     FOR i in 1..p_num_of_rec
     LOOP
       OPEN C_Del_detail_ID ;
       FETCH C_Del_detail_ID
        INTO l_cont_dummy_tab(i);
       CLOSE C_Del_detail_ID;

     END LOOP;
*/
     --x_delivery_detail_id := l_cont_dummy_tab(1);

-- l_cont_dummy_tab will have container instance id

/*** J changes TP release ****/
   --OTM R12 Start Org-Specific
   IF (wsh_util_core.tp_is_installed ='Y' OR l_gc3_is_installed = 'Y' ) THEN --{
     IF ( l_delivery_details_info.ignore_for_planning IS NULL ) THEN --{

       -- if new detail is being created by split then it will take the original details flag
       l_wh_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
             (p_organization_id    => l_delivery_details_info.organization_id,
              p_carrier_id         => l_delivery_details_info.carrier_id,
              p_ship_method_code   => l_delivery_details_info.ship_method_code,
              p_msg_display        => 'N',
              x_return_status      => l_return_status);
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type l_wh_type',
                                                            l_wh_type);
         WSH_DEBUG_SV.log(l_module_name,'Get_Warehouse_Type l_return_status',
                                                            l_return_status);
       END IF;
       IF (l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,
                               WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- TPW - Distribution Organization Changes
       -- Included TW2 in IF condition.
       -- IF (nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('TPW','CMS')) THEN --{
       IF (nvl(l_wh_type, FND_API.G_MISS_CHAR) IN ('TPW','CMS','TW2')) THEN --{
          l_delivery_details_info.ignore_for_planning:='Y';
       ELSIF (l_gc3_is_installed = 'Y') THEN
          WSH_UTIL_VALIDATE.CALC_IGNORE_FOR_PLANNING(
                   p_organization_id  => l_delivery_details_info.organization_id
                  ,p_carrier_id       => NULL
                  ,p_ship_method_code => NULL
                  ,p_tp_installed     => NULL
                  ,p_caller           => NULL
                  ,x_ignore_for_planning => l_ignore_for_planning
                  ,x_return_status       => l_return_status
                  ,p_otm_installed       => 'Y'
                  ,p_client_id           => l_delivery_details_info.client_id); -- LSP PROJECT : Added client_id
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'After call to WSH_UTIL_VALIDATE.CA'
                   ||'LC_IGNORE_FOR_PLANNING l_return_status',l_return_status);
            WSH_DEBUG_SV.log(l_module_name,'l_ignore_for_planning ',
                                            l_ignore_for_planning );
          END IF;
          IF (l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          l_delivery_details_info.ignore_for_planning := l_ignore_for_planning;
       ELSE
          IF l_delivery_details_info.ship_set_id is NOT NULL THEN
            OPEN c_get_ship_sets(l_delivery_details_info.ship_set_id,
                            l_delivery_details_info.source_code,
                            l_delivery_details_info.source_header_id);
            FETCH c_get_ship_sets INTO l_delivery_details_info.ignore_for_planning;
            IF c_get_ship_sets%NOTFOUND OR l_delivery_details_info.ignore_for_planning IS NULL THEN
              l_delivery_details_info.ignore_for_planning:='N';
            ELSE
              FETCH c_get_ship_sets INTO l_ignore_for_planning;
              IF c_get_ship_sets%FOUND THEN
                l_delivery_details_info.ignore_for_planning:='N';
              END IF;
            END IF;
            CLOSE c_get_ship_sets;
          ELSE
            l_delivery_details_info.ignore_for_planning:='N';
          END IF;
       END IF; --}
     END IF; --}
   ELSE
     l_delivery_details_info.ignore_for_planning:='N';
   END IF; --}
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'l_delivery_details_info.ignore_for_planning',
                                     l_delivery_details_info.ignore_for_planning);
   END IF; --}
   --OTM R12 End

   -- Standalone project Changes Start
   l_standalone_mode := WMS_DEPLOY.wms_deployment_mode;
   -- Standalone project Changes End

/*** J changes TP release ****/
     --
     FORALL i in 1..p_num_of_rec
 	INSERT INTO wsh_delivery_details(
		source_code,
		source_header_id,
		delivery_detail_id,
		source_line_id,
		customer_id,
		sold_to_contact_id,
		inventory_item_id,
		item_description,
		hazard_class_id,
		country_of_origin,
		classification,
		ship_from_location_id,
		ship_to_location_id,
		ship_to_contact_id,
		ship_to_site_use_id ,
		deliver_to_location_id,
		deliver_to_contact_id,
		deliver_to_site_use_id ,
		intmed_ship_to_location_id,
		intmed_ship_to_contact_id,
		ship_tolerance_above,
		ship_tolerance_below,
		requested_quantity,
		shipped_quantity,
		delivered_quantity,
		requested_quantity_uom,
		subinventory,
		revision,
		lot_number,
		customer_requested_lot_flag,
		serial_number,
		locator_id,
		date_requested,
		date_scheduled,
		master_container_item_id,
		detail_container_item_id,
		load_seq_number,
		ship_method_code,
		carrier_id,
		freight_terms_code,
		shipment_priority_code,
		fob_code,
		customer_item_id,
		dep_plan_required_flag,
		customer_prod_seq,
		customer_dock_code,
                cust_model_serial_number,
                customer_job,
                customer_production_line,
		net_weight,
		weight_uom_code,
		volume,
		volume_uom_code,
                -- J: W/V Changes
                unit_weight,
                unit_volume,
                filled_volume,
                wv_frozen_flag,
		tp_attribute_category,
		tp_attribute1,
		tp_attribute2,
		tp_attribute3,
		tp_attribute4,
		tp_attribute5,
		tp_attribute6,
		tp_attribute7,
		tp_attribute8,
		tp_attribute9,
		tp_attribute10,
		tp_attribute11,
		tp_attribute12,
		tp_attribute13,
		tp_attribute14,
		tp_attribute15,
		attribute_category, -- bug 1902467
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
		created_by,
		creation_date,
		last_update_date,
		last_update_login,
		last_updated_by,
		program_application_id,
		program_id,
		program_update_date,
		request_id,
		mvt_stat_status,
		organization_id,
		transaction_temp_id,
		ship_set_id,
		arrival_set_id,
		ship_model_complete_flag,
		top_model_line_id,
		hold_code,
		source_header_number,
		source_header_type_id,
		source_header_type_name,
		cust_po_number,
		ato_line_id,
		src_requested_quantity,
		src_requested_quantity_uom,
		move_order_line_id,
		cancelled_quantity,
		quality_control_quantity,
		cycle_count_quantity,
		tracking_number,
		movement_id,
		shipping_instructions,
		packing_instructions,
		project_id,
		task_id,
		org_id,
		oe_interfaced_flag,
		split_from_delivery_detail_id,
		inv_interfaced_flag,
		source_line_number,
		inspection_flag,
		released_status,
		container_flag,
		container_type_code,
		container_name,
		fill_percent,
		gross_weight,
		master_serial_number,
		maximum_load_weight,
		maximum_volume,
		minimum_fill_percent,
		seal_code,
		unit_number,
		unit_price,
		currency_code,
		freight_class_cat_id,
		commodity_code_cat_id,
          preferred_grade,          /* hverddin 26-jun-2000 start OPM changes */
          src_requested_quantity2,
          src_requested_quantity_uom2,
          requested_quantity2,
          shipped_quantity2,
          delivered_quantity2,
          cancelled_quantity2,
          quality_control_quantity2,
          cycle_count_quantity2,
          requested_quantity_uom2,
-- HW OPMCONV - No need for sublot_number
--        sublot_number            /* hverddin 26-jun-2000 end OPM changes */,
		pickable_flag,
		original_subinventory,
                to_serial_number,
          picked_quantity,
          picked_quantity2,
/* H Integration: datamodel changes wrudge */
          received_quantity,
          received_quantity2,
          source_line_set_id,
          batch_id,
          lpn_id,
/*  J  Inbound Logistics: New columns jckwok */
          vendor_id                       ,
          ship_from_site_id               ,
          line_direction                  ,
          party_id                        ,
          routing_req_id                  ,
          shipping_control                ,
          source_blanket_reference_id     ,
          source_blanket_reference_num    ,
          po_shipment_line_id             ,
          po_shipment_line_number         ,
          returned_quantity               ,
          returned_quantity2              ,
          rcv_shipment_line_id            ,
          source_line_type_code           ,
          supplier_item_number            ,
/* J TP release : ttrichy*/
        IGNORE_FOR_PLANNING             ,
        EARLIEST_PICKUP_DATE            ,
        LATEST_PICKUP_DATE              ,
        EARLIEST_DROPOFF_DATE           ,
        LATEST_DROPOFF_DATE             ,
        --DEMAND_SATISFACTION_DATE        , --confirm name for this
        REQUEST_DATE_TYPE_CODE          ,
        tp_delivery_detail_id           ,
        source_document_type_id         ,
        service_level,
        mode_of_transport,
/* J Inbound Logistics: New columns asutar*/
        po_revision_number,
        release_revision_number,
        -- Standalone project Changes Start
        original_lot_number,
        reference_number,
        reference_line_number,
        reference_line_quantity,
        reference_line_quantity_uom,
        original_revision,
        original_locator_id,
        -- Standalone project Changes End
        client_id  -- LSP PROJECT:
      ) VALUES
		(l_delivery_details_info.source_code,
      l_delivery_details_info.source_header_id,
      wsh_delivery_details_s.nextval, --lpn conv
      decode( l_delivery_details_info.container_flag , 'Y', wsh_delivery_details_s.currval,  l_delivery_details_info.source_line_id),
      l_delivery_details_info.customer_id,
      l_delivery_details_info.sold_to_contact_id,
      l_delivery_details_info.inventory_item_id,
      l_delivery_details_info.item_description,
      l_delivery_details_info.hazard_class_id,
      l_delivery_details_info.country_of_origin,
      l_delivery_details_info.classification,
      l_delivery_details_info.ship_from_location_id,
      l_delivery_details_info.ship_to_location_id,
      l_delivery_details_info.ship_to_contact_id,
      l_delivery_details_info.ship_to_site_use_id,
      l_delivery_details_info.deliver_to_location_id,
      l_delivery_details_info.deliver_to_contact_id,
      l_delivery_details_info.deliver_to_site_use_id,
      l_delivery_details_info.intmed_ship_to_location_id,
      l_delivery_details_info.intmed_ship_to_contact_id,
      l_delivery_details_info.ship_tolerance_above,
      l_delivery_details_info.ship_tolerance_below,
      l_delivery_details_info.requested_quantity,
		l_delivery_details_info.shipped_quantity,
      l_delivery_details_info.delivered_quantity,
		nvl ( l_delivery_details_info.requested_quantity_uom,
			 decode ( l_delivery_details_info.container_flag, 'Y' , 'YY' , 'XX') ) ,
      l_delivery_details_info.subinventory,
      l_delivery_details_info.revision,
      l_delivery_details_info.lot_number,
      l_delivery_details_info.customer_requested_lot_flag,
      l_delivery_details_info.serial_number,
      l_delivery_details_info.locator_id,
      l_delivery_details_info.date_requested,
      l_delivery_details_info.date_scheduled,
      l_delivery_details_info.master_container_item_id,
      l_delivery_details_info.detail_container_item_id,
      l_delivery_details_info.load_seq_number,
      l_delivery_details_info.ship_method_code,
      l_delivery_details_info.carrier_id,
      l_delivery_details_info.freight_terms_code,
      l_delivery_details_info.shipment_priority_code,
      l_delivery_details_info.fob_code,
      l_delivery_details_info.customer_item_id,
      l_delivery_details_info.dep_plan_required_flag,
 	   l_delivery_details_info.customer_prod_seq,
      l_delivery_details_info.customer_dock_code,
      l_delivery_details_info.cust_model_serial_number,
      l_delivery_details_info.customer_job,
      l_delivery_details_info.customer_production_line,
      l_delivery_details_info.net_weight,
      l_delivery_details_info.weight_uom_code,
      l_delivery_details_info.volume,
      l_delivery_details_info.volume_uom_code,
      -- J: W/V Changes
      l_delivery_details_info.unit_weight,
      l_delivery_details_info.unit_volume,
      l_delivery_details_info.filled_volume,
      l_delivery_details_info.wv_frozen_flag,
      l_delivery_details_info.tp_attribute_category,
      l_delivery_details_info.tp_attribute1,
      l_delivery_details_info.tp_attribute2,
      l_delivery_details_info.tp_attribute3,
      l_delivery_details_info.tp_attribute4,
      l_delivery_details_info.tp_attribute5,
      l_delivery_details_info.tp_attribute6,
      l_delivery_details_info.tp_attribute7,
      l_delivery_details_info.tp_attribute8,
      l_delivery_details_info.tp_attribute9,
      l_delivery_details_info.tp_attribute10,
      l_delivery_details_info.tp_attribute11,
      l_delivery_details_info.tp_attribute12,
      l_delivery_details_info.tp_attribute13,
      l_delivery_details_info.tp_attribute14,
      l_delivery_details_info.tp_attribute15,
      l_delivery_details_info.attribute_category, -- bug 1902467
      l_delivery_details_info.attribute1,
      l_delivery_details_info.attribute2,
      l_delivery_details_info.attribute3,
      l_delivery_details_info.attribute4,
      l_delivery_details_info.attribute5,
      l_delivery_details_info.attribute6,
      l_delivery_details_info.attribute7,
      l_delivery_details_info.attribute8,
      l_delivery_details_info.attribute9,
      l_delivery_details_info.attribute10,
      l_delivery_details_info.attribute11,
      l_delivery_details_info.attribute12,
      l_delivery_details_info.attribute13,
      l_delivery_details_info.attribute14,
      l_delivery_details_info.attribute15,
      FND_GLOBAL.USER_ID,
      SYSDATE,
      SYSDATE,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.USER_ID,
      NULL,
      NULL,
      NULL,
      l_delivery_details_info.request_id,
      l_delivery_details_info.mvt_stat_status,
      l_delivery_details_info.organization_id,
      l_delivery_details_info.transaction_temp_id,
      l_delivery_details_info.ship_set_id,
      l_delivery_details_info.arrival_set_id,
      l_delivery_details_info.ship_model_complete_flag,
      l_delivery_details_info.top_model_line_id,
      l_delivery_details_info.hold_code,
      l_delivery_details_info.source_header_number,
      l_delivery_details_info.source_header_type_id,
      l_delivery_details_info.source_header_type_name,
      l_delivery_details_info.cust_po_number,
      l_delivery_details_info.ato_line_id,
      l_delivery_details_info.src_requested_quantity,
       l_delivery_details_info.src_requested_quantity_uom,
      l_delivery_details_info.move_order_line_id,
      l_delivery_details_info.cancelled_quantity,
      l_delivery_details_info.quality_control_quantity,
      l_delivery_details_info.cycle_count_quantity ,
      l_delivery_details_info.tracking_number,
      l_delivery_details_info.movement_id,
      l_delivery_details_info.shipping_instructions,
      l_delivery_details_info.packing_instructions,
      l_delivery_details_info.project_id,
      l_delivery_details_info.task_id,
      l_delivery_details_info.org_id,
      --decode(l_delivery_details_info.source_code,'OE','N','X'),
      --Modified for Standalone project
      decode(l_delivery_details_info.source_code,'OE',decode(l_standalone_mode, 'D', 'X', 'N'),'X'),
      l_delivery_details_info.split_from_detail_id,
      nvl(l_delivery_details_info.inv_interfaced_flag, decode(l_delivery_details_info.pickable_flag,'Y','N','X')),
      l_delivery_details_info.source_line_number,
      -- Inspection is required only for 'OKE'
      decode  ( l_delivery_details_info.source_code, 'OKE' , nvl (l_delivery_details_info.inspection_flag , 'N') , 'N' ),
      l_delivery_details_info.released_status,
      l_delivery_details_info.container_flag,
      l_delivery_details_info.container_type_code,
      decode(l_delivery_details_info.container_flag,'Y',
               nvl(p_container_info_rec.container_names(i), NVL(l_delivery_details_info.container_name,wsh_delivery_details_s.currval)),
               l_delivery_details_info.container_name),
      l_delivery_details_info.fill_percent,
      l_delivery_details_info.gross_weight,
      l_delivery_details_info.master_serial_number,
      l_delivery_details_info.maximum_load_weight,
      l_delivery_details_info.maximum_volume,
      l_delivery_details_info.minimum_fill_percent,
      l_delivery_details_info.seal_code,
      l_delivery_details_info.unit_number,
      l_delivery_details_info.unit_price,
      l_delivery_details_info.currency_code,
      l_delivery_details_info.freight_class_cat_id,
      l_delivery_details_info.commodity_code_cat_id,
      l_delivery_details_info.preferred_grade, /* hverddin start changes */
      l_delivery_details_info.src_requested_quantity2,
      l_delivery_details_info.src_requested_quantity_uom2,
      l_delivery_details_info.requested_quantity2,
      l_delivery_details_info.shipped_quantity2,
      l_delivery_details_info.delivered_quantity2,
      l_delivery_details_info.cancelled_quantity2,
      l_delivery_details_info.quality_control_quantity2,
      l_delivery_details_info.cycle_count_quantity2,
      l_delivery_details_info.requested_quantity_uom2,
-- HW OPMCONV - No need for sublot_number
--    l_delivery_details_info.sublot_number    /* hverddin end changes */,
      l_delivery_details_info.pickable_flag,
      l_delivery_details_info.original_subinventory,
      l_delivery_details_info.to_serial_number,
      l_delivery_details_info.picked_quantity,
      l_delivery_details_info.picked_quantity2,
/* H Integration: datamodel changes wrudge */
      l_delivery_details_info.received_quantity,
      l_delivery_details_info.received_quantity2,
      l_delivery_details_info.source_line_set_id,
      l_delivery_details_info.batch_id,
       --lpn conv
      decode(l_delivery_details_info.container_flag , 'Y',
       NVL(p_container_info_rec.lpn_ids(i),l_delivery_details_info.lpn_id),
         l_delivery_details_info.lpn_id) ,
/*  J  Inbound Logistics: New columns jckwok */
      l_delivery_details_info.vendor_id                       ,
      l_delivery_details_info.ship_from_site_id               ,
      nvl(l_delivery_details_info.line_direction, 'O')        ,
      l_delivery_details_info.party_id                        ,
      l_delivery_details_info.routing_req_id                  ,
      l_delivery_details_info.shipping_control                ,
      l_delivery_details_info.source_blanket_reference_id     ,
      l_delivery_details_info.source_blanket_reference_num    ,
      l_delivery_details_info.po_shipment_line_id             ,
      l_delivery_details_info.po_shipment_line_number         ,
      l_delivery_details_info.returned_quantity               ,
      l_delivery_details_info.returned_quantity2              ,
      l_delivery_details_info.rcv_shipment_line_id            ,
      l_delivery_details_info.source_line_type_code           ,
      l_delivery_details_info.supplier_item_number            ,
/* J TP release : ttrichy */
      nvl(l_delivery_details_info.IGNORE_FOR_PLANNING, 'N')   ,
      l_delivery_details_info.EARLIEST_PICKUP_DATE            ,
      l_delivery_details_info.LATEST_PICKUP_DATE              ,
      l_delivery_details_info.EARLIEST_DROPOFF_DATE           ,
      l_delivery_details_info.LATEST_DROPOFF_DATE             ,
      --l_delivery_details_info.DEMAND_SATISFACTION_DATE        ,
      l_delivery_details_info.REQUEST_DATE_TYPE_CODE          ,
      l_delivery_details_info.tp_delivery_detail_id           ,
      l_delivery_details_info.source_document_type_id     ,
      l_delivery_details_info.service_level     ,
      l_delivery_details_info.mode_of_transport  ,
   /* J IB : austar*/
      l_delivery_details_info.po_revision_number,
      l_delivery_details_info.release_revision_number,
      -- Standalone project Changes Start
      l_delivery_details_info.original_lot_number,
      l_delivery_details_info.reference_number,
      l_delivery_details_info.reference_line_number,
      l_delivery_details_info.reference_line_quantity,
      l_delivery_details_info.reference_line_quantity_uom,
      l_delivery_details_info.original_revision,
      l_delivery_details_info.original_locator_id,
      -- Standalone project Changes End
      l_delivery_details_info.client_id -- LSP PROJECT:
      )
      RETURNING delivery_detail_id BULK COLLECT INTO x_dd_id_tab;

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER INSERTING INTO WSH_DELIVERY_DETAILS');
      END IF;
      --

      -- DBI Project
      -- Insert of wsh_delivery_details,  call DBI API after the insert.
      -- This API will also check for DBI Installed or not
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail count-',x_dd_id_tab.count);
      END IF;
      WSH_INTEGRATION.DBI_Update_Detail_Log
        (p_delivery_detail_id_tab => x_dd_id_tab,
         p_dml_type               => 'INSERT',
         x_return_status          => l_dbi_rs);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
      END IF;
      IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
        x_return_status := l_dbi_rs;
        -- just pass this return status to caller API
      END IF;
      -- End of Code for DBI Project

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
	WHEN others THEN
        --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'WHEN OTHERS IN CREATE_DELIVERY_DETAILS_BULK ' || SQLERRM  );
          END IF;
        --
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	  wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.CREATE_DELIVERY_DETAILS_BULK',l_module_name);
	--
	  IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	  END IF;
	--
END Create_Delivery_Details_Bulk;

/***********************************
    CREATE_DD_FROM_OLD_BULK
***********************************/

-- This API has been called to
-- make a Bulk call for creating Delivery Details
-- from Split API in WSHDDACB

-- Example if ordered qty = 13 and container capacity = 5
-- line will be split 2 times with qty of 5
-- so create 2 new records

PROCEDURE create_dd_from_old_bulk(
	p_delivery_detail_rec	IN WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
        p_delivery_detail_id    IN NUMBER,
        p_num_of_rec            IN   NUMBER,
	x_dd_id_tab             OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
	x_return_status	OUT NOCOPY  VARCHAR2
	) IS

l_container_name varchar2(50);

CURSOR C_Del_detail_ID
IS
SELECT wsh_delivery_details_s.nextval
FROM sys.dual;

l_row_count NUMBER;
l_temp_id   NUMBER;

l_dd_id_tab  WSH_UTIL_CORE.id_tab_type;
l_dd_rec     WSH_GLBL_VAR_STRCT_GRP.DELIVERY_DETAILS_REC_TYPE;
l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API
--Standalone project Changes
l_standalone_mode             VARCHAR2(1);

others exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DD_FROM_OLD_BULK';
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
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'INSIDE PROCEDURE CREATE DD FROM OLD_BULK'  );
        END IF;
        --
        FOR i in 1..p_num_of_rec
        LOOP
		OPEN C_Del_detail_ID ;
		FETCH C_Del_detail_ID INTO l_dd_id_tab(i);
		CLOSE C_Del_detail_ID;
        END LOOP;

        -- Standalone project Changes Start
        l_standalone_mode := WMS_DEPLOY.wms_deployment_mode;
        -- LSP PROJECT : consider LSP mode is same Distributed as this value is used
        --          just to populate revision,lot and locator values from associated original records
        --          and in normal case these attributes are not used.
        IF l_standalone_mode = 'L'
        THEN
          l_standalone_mode := 'D';
        END IF;
        -- Standalone project Changes End

/* Note : J TP release : ignore_for_planning will be defaulted from the old record*/
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'BEFORE INSERTING INTO WSH_DELIVERY_DETAILS' ||l_dd_id_tab.count );
        END IF;
        --
        FORALL i in 1..p_num_of_rec
 	INSERT INTO wsh_delivery_details(
		source_code,
		source_header_id,
		source_line_id,
		customer_id,
		sold_to_contact_id,
		inventory_item_id,
		item_description,
		hazard_class_id,
		country_of_origin,
		classification,
		ship_from_location_id,
		ship_to_location_id,
		ship_to_contact_id,
		ship_to_site_use_id ,
		deliver_to_location_id,
		deliver_to_contact_id,
		deliver_to_site_use_id ,
		intmed_ship_to_location_id,
		intmed_ship_to_contact_id,
		ship_tolerance_above,
		ship_tolerance_below,
		requested_quantity,
		shipped_quantity,
		delivered_quantity,
		requested_quantity_uom,
		subinventory,
		revision,
		lot_number,
		customer_requested_lot_flag,
		serial_number,
		locator_id,
		date_requested,
		date_scheduled,
		master_container_item_id,
		detail_container_item_id,
		load_seq_number,
		ship_method_code,
		carrier_id,
		freight_terms_code,
		shipment_priority_code,
		fob_code,
		customer_item_id,
		dep_plan_required_flag,
		customer_prod_seq,
		customer_dock_code,
                cust_model_serial_number,
                customer_job,
                customer_production_line,
		net_weight,
		weight_uom_code,
		volume,
		volume_uom_code,
                -- J: W/V Changes
                unit_weight,
                unit_volume,
                filled_volume,
                wv_frozen_flag,
		tp_attribute_category,
		tp_attribute1,
		tp_attribute2,
		tp_attribute3,
		tp_attribute4,
		tp_attribute5,
		tp_attribute6,
		tp_attribute7,
		tp_attribute8,
		tp_attribute9,
		tp_attribute10,
		tp_attribute11,
		tp_attribute12,
		tp_attribute13,
		tp_attribute14,
		tp_attribute15,
		attribute_category, -- bug 1902467
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
		created_by,
		creation_date,
		last_update_date,
		last_update_login,
		last_updated_by,
		program_application_id,
		program_id,
		program_update_date,
		request_id,
		mvt_stat_status,
		organization_id,
		transaction_temp_id,
		ship_set_id,
		arrival_set_id,
		ship_model_complete_flag,
		top_model_line_id,
		hold_code,
		source_header_number,
		source_header_type_id,
		source_header_type_name,
		cust_po_number,
		ato_line_id,
		src_requested_quantity,
		src_requested_quantity_uom,
		move_order_line_id,
		cancelled_quantity,
		quality_control_quantity,
		cycle_count_quantity,
		tracking_number,
		movement_id,
		shipping_instructions,
		packing_instructions,
		project_id,
		task_id,
		org_id,
		oe_interfaced_flag,
		split_from_delivery_detail_id,
		inv_interfaced_flag,
		source_line_number,
		inspection_flag,
		released_status,
		delivery_detail_id,
		container_flag,
		container_type_code,
		container_name,
		fill_percent,
		gross_weight,
		master_serial_number,
		maximum_load_weight,
		maximum_volume,
		minimum_fill_percent,
		seal_code,
		unit_number,
		unit_price,
		currency_code,
		freight_class_cat_id,
		commodity_code_cat_id,
                preferred_grade,          /* start OPM changes */
                src_requested_quantity2,
                src_requested_quantity_uom2,
                requested_quantity2,
                shipped_quantity2,
                delivered_quantity2,
                cancelled_quantity2,
                quality_control_quantity2,
                cycle_count_quantity2,
                requested_quantity_uom2,
-- HW OPMCONV - No need for sublot_number
--              sublot_number            /* end OPM changes */,
	        pickable_flag,
	        original_subinventory,
                to_serial_number,
                picked_quantity,
                picked_quantity2,
/* H Integration: datamodel changes wrudge */
                received_quantity,
                received_quantity2,
                source_line_set_id,
                batch_id,
		transaction_id,   ---- 2803570
                lpn_id,
 /*  J  Inbound Logistics: New columns jckwok */
                vendor_id                       ,
                ship_from_site_id               ,
                line_direction                  ,
                party_id                        ,
                routing_req_id                  ,
                shipping_control                ,
                source_blanket_reference_id     ,
                source_blanket_reference_num    ,
                po_shipment_line_id             ,
                po_shipment_line_number         ,
                returned_quantity               ,
                returned_quantity2              ,
                rcv_shipment_line_id            ,
                source_line_type_code           ,
                supplier_item_number            ,
/* J TP release : ttrichy*/
        IGNORE_FOR_PLANNING             ,
        EARLIEST_PICKUP_DATE            ,
        LATEST_PICKUP_DATE              ,
        EARLIEST_DROPOFF_DATE           ,
        LATEST_DROPOFF_DATE             ,
        --DEMAND_SATISFACTION_DATE        , --confirm name for this
        REQUEST_DATE_TYPE_CODE          ,
        tp_delivery_detail_id           ,
        source_document_type_id    ,
        service_level    ,
        mode_of_transport  ,
  /* J IB : asutar*/
        po_revision_number,
        release_revision_number,
        replenishment_status,   --bug# 6689448 (replenishment project)
        -- Standalone project Changes Start
        original_lot_number,
        reference_number,
        reference_line_number,
        reference_line_quantity,
        reference_line_quantity_uom,
        original_revision,
        original_locator_id,
        -- Standalone project Changes End
        client_id, -- LSP PROJECT:
        -- TPW - Distributed Organization Changes - Start
        shipment_batch_id,
        shipment_line_number,
        reference_line_id
        -- TPW - Distributed Organization Changes - End
      )
      SELECT
      decode(p_delivery_detail_rec.source_code,NULL,wdd.source_code,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.source_code),
      decode(p_delivery_detail_rec.source_header_id,NULL,wdd.source_header_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.source_header_id),
      decode(p_delivery_detail_rec.source_line_id,NULL,wdd.source_line_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.source_line_id),
      decode(p_delivery_detail_rec.customer_id,NULL,wdd.customer_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.customer_id),
      decode(p_delivery_detail_rec.sold_to_contact_id,NULL,wdd.sold_to_contact_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.sold_to_contact_id),
      decode(p_delivery_detail_rec.inventory_item_id,NULL,wdd.inventory_item_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.inventory_item_id),
      decode(p_delivery_detail_rec.item_description,NULL,wdd.item_description,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.item_description),
      decode(p_delivery_detail_rec.hazard_class_id,NULL,wdd.hazard_class_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.hazard_class_id),
      decode(p_delivery_detail_rec.country_of_origin,NULL,wdd.country_of_origin,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.country_of_origin),
      decode(p_delivery_detail_rec.classification,NULL,wdd.classification,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.classification),
      decode(p_delivery_detail_rec.ship_from_location_id,NULL,wdd.ship_from_location_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.ship_from_location_id),
      decode(p_delivery_detail_rec.ship_to_location_id,NULL,wdd.ship_to_location_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.ship_to_location_id),
      decode(p_delivery_detail_rec.ship_to_contact_id,NULL,wdd.ship_to_contact_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.ship_to_contact_id),
      decode(p_delivery_detail_rec.ship_to_site_use_id,NULL,wdd.ship_to_site_use_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.ship_to_site_use_id),
      decode(p_delivery_detail_rec.deliver_to_location_id,NULL,wdd.deliver_to_location_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.deliver_to_location_id),
      decode(p_delivery_detail_rec.deliver_to_contact_id,NULL,wdd.deliver_to_contact_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.deliver_to_contact_id),
      decode(p_delivery_detail_rec.deliver_to_site_use_id,NULL,wdd.deliver_to_site_use_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.deliver_to_site_use_id),
      decode(p_delivery_detail_rec.intmed_ship_to_location_id,NULL,wdd.intmed_ship_to_location_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.intmed_ship_to_location_id),
      decode(p_delivery_detail_rec.intmed_ship_to_contact_id,NULL,wdd.intmed_ship_to_contact_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.intmed_ship_to_contact_id),
      decode(p_delivery_detail_rec.ship_tolerance_above,NULL,wdd.ship_tolerance_above,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.ship_tolerance_above),
      decode(p_delivery_detail_rec.ship_tolerance_below,NULL,wdd.ship_tolerance_below,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.ship_tolerance_below),
      decode(p_delivery_detail_rec.requested_quantity,NULL,wdd.requested_quantity,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.requested_quantity),
      decode(p_delivery_detail_rec.shipped_quantity,NULL,wdd.shipped_quantity,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.shipped_quantity),
      decode(p_delivery_detail_rec.delivered_quantity,NULL,wdd.delivered_quantity,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.delivered_quantity),

      decode(p_delivery_detail_rec.requested_quantity_uom,NULL,nvl(wdd.requested_quantity_uom,decode(wdd.container_flag, 'Y' , 'YY' , 'XX')),FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.requested_quantity_uom),

      --Standalone project begin : Need to pass original values
      decode(p_delivery_detail_rec.subinventory,NULL,wdd.subinventory,FND_API.G_MISS_CHAR,decode(l_standalone_mode,'D',wdd.original_subinventory,NULL),p_delivery_detail_rec.subinventory),
      decode(p_delivery_detail_rec.revision,NULL,wdd.revision,FND_API.G_MISS_CHAR,decode(l_standalone_mode,'D',wdd.original_revision,NULL),p_delivery_detail_rec.revision),
      decode(p_delivery_detail_rec.lot_number,NULL,wdd.lot_number,FND_API.G_MISS_CHAR,decode(l_standalone_mode,'D',wdd.original_lot_number,NULL),p_delivery_detail_rec.lot_number),
      --Standalone project end
      decode(p_delivery_detail_rec.customer_requested_lot_flag,NULL,wdd.customer_requested_lot_flag,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.customer_requested_lot_flag),
      decode(p_delivery_detail_rec.serial_number,NULL,wdd.serial_number,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.serial_number),
      --Standalone project : Need to pass original values
      decode(p_delivery_detail_rec.locator_id,NULL,wdd.locator_id,FND_API.G_MISS_NUM,decode(l_standalone_mode,'D',wdd.original_locator_id,NULL),p_delivery_detail_rec.locator_id),
      decode(p_delivery_detail_rec.date_requested,NULL,wdd.date_requested,FND_API.G_MISS_DATE,NULL,p_delivery_detail_rec.date_requested),
      decode(p_delivery_detail_rec.date_scheduled,NULL,wdd.date_scheduled,FND_API.G_MISS_DATE,NULL,p_delivery_detail_rec.date_scheduled),
      decode(p_delivery_detail_rec.master_container_item_id,NULL,wdd.master_container_item_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.master_container_item_id),
      decode(p_delivery_detail_rec.detail_container_item_id,NULL,wdd.detail_container_item_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.detail_container_item_id),
      decode(p_delivery_detail_rec.load_seq_number,NULL,wdd.load_seq_number,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.load_seq_number),
      decode(p_delivery_detail_rec.ship_method_code,NULL,wdd.ship_method_code,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.ship_method_code),
      decode(p_delivery_detail_rec.carrier_id,NULL,wdd.carrier_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.carrier_id),
      decode(p_delivery_detail_rec.freight_terms_code,NULL,wdd.freight_terms_code,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.freight_terms_code),
      decode(p_delivery_detail_rec.shipment_priority_code,NULL,wdd.shipment_priority_code,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.shipment_priority_code),
      decode(p_delivery_detail_rec.fob_code,NULL,wdd.fob_code,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.fob_code),
      decode(p_delivery_detail_rec.customer_item_id,NULL,wdd.customer_item_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.customer_item_id),
      decode(p_delivery_detail_rec.dep_plan_required_flag,NULL,wdd.dep_plan_required_flag,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.dep_plan_required_flag),
      decode(p_delivery_detail_rec.customer_prod_seq,NULL,wdd.customer_prod_seq,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.customer_prod_seq),
      decode(p_delivery_detail_rec.customer_dock_code,NULL,wdd.customer_dock_code,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.customer_dock_code),
      decode(p_delivery_detail_rec.cust_model_serial_number,NULL,wdd.cust_model_serial_number,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.cust_model_serial_number),
      decode(p_delivery_detail_rec.customer_job,NULL,wdd.customer_job,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.customer_job),
      decode(p_delivery_detail_rec.customer_production_line,NULL,wdd.customer_production_line,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.customer_production_line),
      decode(p_delivery_detail_rec.net_weight,NULL,wdd.net_weight,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.net_weight),
      decode(p_delivery_detail_rec.weight_uom_code,NULL,wdd.weight_uom_code,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.weight_uom_code),
      decode(p_delivery_detail_rec.volume,NULL,wdd.volume,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.volume),
      decode(p_delivery_detail_rec.volume_uom_code,NULL,wdd.volume_uom_code,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.volume_uom_code),
      -- J: W/V Changes
      decode(p_delivery_detail_rec.unit_weight,NULL,wdd.unit_weight,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.unit_weight),
      decode(p_delivery_detail_rec.unit_volume,NULL,wdd.unit_volume,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.unit_volume),
      decode(p_delivery_detail_rec.filled_volume,NULL,wdd.filled_volume,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.filled_volume),
      decode(p_delivery_detail_rec.wv_frozen_flag,NULL,'N',FND_API.G_MISS_NUM,'N',p_delivery_detail_rec.wv_frozen_flag),

      decode(p_delivery_detail_rec.tp_attribute_category,NULL,wdd.tp_attribute_category,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute_category),
      decode(p_delivery_detail_rec.tp_attribute1,NULL,wdd.tp_attribute1,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute1),
      decode(p_delivery_detail_rec.tp_attribute2,NULL,wdd.tp_attribute2,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute2),
      decode(p_delivery_detail_rec.tp_attribute3,NULL,wdd.tp_attribute3,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute3),
      decode(p_delivery_detail_rec.tp_attribute4,NULL,wdd.tp_attribute4,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute4),
      decode(p_delivery_detail_rec.tp_attribute5,NULL,wdd.tp_attribute5,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute5),
      decode(p_delivery_detail_rec.tp_attribute6,NULL,wdd.tp_attribute6,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute6),
      decode(p_delivery_detail_rec.tp_attribute7,NULL,wdd.tp_attribute7,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute7),
      decode(p_delivery_detail_rec.tp_attribute8,NULL,wdd.tp_attribute8,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute8),
      decode(p_delivery_detail_rec.tp_attribute9,NULL,wdd.tp_attribute9,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute9),
      decode(p_delivery_detail_rec.tp_attribute10,NULL,wdd.tp_attribute10,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute10),
      decode(p_delivery_detail_rec.tp_attribute11,NULL,wdd.tp_attribute11,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute11),
      decode(p_delivery_detail_rec.tp_attribute12,NULL,wdd.tp_attribute12,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute12),
      decode(p_delivery_detail_rec.tp_attribute13,NULL,wdd.tp_attribute13,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute13),
      decode(p_delivery_detail_rec.tp_attribute14,NULL,wdd.tp_attribute14,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute14),
      decode(p_delivery_detail_rec.tp_attribute15,NULL,wdd.tp_attribute15,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_attribute15),
      decode(p_delivery_detail_rec.attribute_category,NULL,wdd.attribute_category,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute_category), -- bug 1902467
      decode(p_delivery_detail_rec.attribute1,NULL,wdd.attribute1,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute1),
      decode(p_delivery_detail_rec.attribute2,NULL,wdd.attribute2,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute2),
      decode(p_delivery_detail_rec.attribute3,NULL,wdd.attribute3,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute3),
      decode(p_delivery_detail_rec.attribute4,NULL,wdd.attribute4,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute4),
      decode(p_delivery_detail_rec.attribute5,NULL,wdd.attribute5,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute5),
      decode(p_delivery_detail_rec.attribute6,NULL,wdd.attribute6,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute6),
      decode(p_delivery_detail_rec.attribute7,NULL,wdd.attribute7,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute7),
      decode(p_delivery_detail_rec.attribute8,NULL,wdd.attribute8,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute8),
      decode(p_delivery_detail_rec.attribute9,NULL,wdd.attribute9,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute9),
      decode(p_delivery_detail_rec.attribute10,NULL,wdd.attribute10,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute10),
      decode(p_delivery_detail_rec.attribute11,NULL,wdd.attribute11,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute11),
      decode(p_delivery_detail_rec.attribute12,NULL,wdd.attribute12,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute12),
      decode(p_delivery_detail_rec.attribute13,NULL,wdd.attribute13,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute13),
      decode(p_delivery_detail_rec.attribute14,NULL,wdd.attribute14,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute14),
      decode(p_delivery_detail_rec.attribute15,NULL,wdd.attribute15,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.attribute15),
      FND_GLOBAL.USER_ID,
      SYSDATE,
      SYSDATE,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.USER_ID,
      NULL,
      NULL,
      NULL,
      decode(p_delivery_detail_rec.request_id,NULL,wdd.request_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.request_id),
      decode(p_delivery_detail_rec.mvt_stat_status,NULL,wdd.mvt_stat_status,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.mvt_stat_status),
      decode(p_delivery_detail_rec.organization_id,NULL,wdd.organization_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.organization_id),
	decode(p_delivery_detail_rec.transaction_temp_id,NULL,wdd.transaction_temp_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.transaction_temp_id),
	decode(p_delivery_detail_rec.ship_set_id,NULL,wdd.ship_set_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.ship_set_id),
	decode(p_delivery_detail_rec.arrival_set_id,NULL,wdd.arrival_set_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.arrival_set_id),
	decode(p_delivery_detail_rec.ship_model_complete_flag,NULL,wdd.ship_model_complete_flag,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.ship_model_complete_flag),
	decode(p_delivery_detail_rec.top_model_line_id,NULL,wdd.top_model_line_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.top_model_line_id),
	decode(p_delivery_detail_rec.hold_code,NULL,wdd.hold_code,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.hold_code),
	decode(p_delivery_detail_rec.source_header_number,NULL,wdd.source_header_number,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.source_header_number),
	decode(p_delivery_detail_rec.source_header_type_id,NULL,wdd.source_header_type_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.source_header_type_id),
	decode(p_delivery_detail_rec.source_header_type_name,NULL,wdd.source_header_type_name,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.source_header_type_name),
	decode(p_delivery_detail_rec.cust_po_number,NULL,wdd.cust_po_number,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.cust_po_number),
	decode(p_delivery_detail_rec.ato_line_id,NULL,wdd.ato_line_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.ato_line_id),
	decode(p_delivery_detail_rec.src_requested_quantity,NULL,wdd.src_requested_quantity,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.src_requested_quantity),

	decode(p_delivery_detail_rec.src_requested_quantity_uom,
               NULL, wdd.src_requested_quantity_uom,
               FND_API.G_MISS_CHAR, NULL,
               p_delivery_detail_rec.src_requested_quantity_uom),
	decode(p_delivery_detail_rec.move_order_line_id,NULL,wdd.move_order_line_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.move_order_line_id),
	decode(p_delivery_detail_rec.cancelled_quantity,NULL,wdd.cancelled_quantity,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.cancelled_quantity),
	decode(p_delivery_detail_rec.quality_control_quantity,NULL,wdd.quality_control_quantity,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.quality_control_quantity),
	decode(p_delivery_detail_rec.cycle_count_quantity ,NULL,wdd.cycle_count_quantity ,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.cycle_count_quantity),
        decode(decode(p_delivery_detail_rec.source_code,NULL,wdd.source_code,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.source_code),
                'PO',(decode (decode(p_delivery_detail_rec.released_status,NULL,wdd.released_status,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.released_status) ,
                       'X',null,p_delivery_detail_rec.tracking_number ) ),null), --bugfix 3711663
	decode(p_delivery_detail_rec.movement_id,NULL,wdd.movement_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.movement_id),
	decode(p_delivery_detail_rec.shipping_instructions,NULL,wdd.shipping_instructions,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.shipping_instructions),
	decode(p_delivery_detail_rec.packing_instructions,NULL,wdd.packing_instructions,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.packing_instructions),
	decode(p_delivery_detail_rec.project_id,NULL,wdd.project_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.project_id),
	decode(p_delivery_detail_rec.task_id,NULL,wdd.task_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.task_id),
	decode(p_delivery_detail_rec.org_id,NULL,wdd.org_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.org_id),

    --Modified for Standalone project
	--decode(p_delivery_detail_rec.oe_interfaced_flag,NULL,decode(wdd.source_code,'OE','N','X'),FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.oe_interfaced_flag),
    decode(p_delivery_detail_rec.oe_interfaced_flag,NULL,decode(wdd.source_code,'OE',decode(l_standalone_mode, 'D', 'X', 'N'),'X'),FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.oe_interfaced_flag),

	decode(p_delivery_detail_rec.split_from_detail_id,NULL,wdd.split_from_delivery_detail_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.split_from_detail_id),

	decode(p_delivery_detail_rec.inv_interfaced_flag,NULL,decode(wdd.pickable_flag,'Y','N','X'),FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.inv_interfaced_flag),

	decode(p_delivery_detail_rec.source_line_number,NULL,wdd.source_line_number,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.source_line_number),
	decode(p_delivery_detail_rec.inspection_flag,NULL,decode(wdd.source_code,'OKE',nvl(wdd.inspection_flag,'N'),'N'),FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.inspection_flag),

	decode(p_delivery_detail_rec.released_status,NULL,wdd.released_status,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.released_status),

        l_dd_id_tab(i),

	decode(p_delivery_detail_rec.container_flag,NULL,wdd.container_flag,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.container_flag),
	decode(p_delivery_detail_rec.container_type_code,NULL,wdd.container_type_code,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.container_type_code),

        decode(p_delivery_detail_rec.container_name,NULL,decode(wdd.container_flag,'Y',to_char(l_dd_id_tab(i)),null),FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.container_name),

	decode(p_delivery_detail_rec.fill_percent,NULL,wdd.fill_percent,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.fill_percent),
	decode(p_delivery_detail_rec.gross_weight,NULL,wdd.gross_weight,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.gross_weight),
	decode(p_delivery_detail_rec.master_serial_number,NULL,wdd.master_serial_number,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.master_serial_number),
	decode(p_delivery_detail_rec.maximum_load_weight,NULL,wdd.maximum_load_weight,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.maximum_load_weight),
	decode(p_delivery_detail_rec.maximum_volume,NULL,wdd.maximum_volume,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.maximum_volume),
	decode(p_delivery_detail_rec.minimum_fill_percent,NULL,wdd.minimum_fill_percent,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.minimum_fill_percent),
	decode(p_delivery_detail_rec.seal_code,NULL,wdd.seal_code,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.seal_code),
	decode(p_delivery_detail_rec.unit_number,NULL,wdd.unit_number,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.unit_number),
	decode(p_delivery_detail_rec.unit_price,NULL,wdd.unit_price,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.unit_price),
	decode(p_delivery_detail_rec.currency_code,NULL,wdd.currency_code,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.currency_code),
	decode(p_delivery_detail_rec.freight_class_cat_id,NULL,wdd.freight_class_cat_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.freight_class_cat_id),
	decode(p_delivery_detail_rec.commodity_code_cat_id,NULL,wdd.commodity_code_cat_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.commodity_code_cat_id),
        decode(p_delivery_detail_rec.preferred_grade,NULL,wdd.preferred_grade,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.preferred_grade), /* hverddin start changes */
        decode(p_delivery_detail_rec.src_requested_quantity2,NULL,wdd.src_requested_quantity2,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.src_requested_quantity2),
        decode(p_delivery_detail_rec.src_requested_quantity_uom2,NULL,wdd.src_requested_quantity_uom2,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.src_requested_quantity_uom2),
        decode(p_delivery_detail_rec.requested_quantity2,NULL,wdd.requested_quantity2,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.requested_quantity2),
        decode(p_delivery_detail_rec.shipped_quantity2,NULL,wdd.shipped_quantity2,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.shipped_quantity2),
        decode(p_delivery_detail_rec.delivered_quantity2,NULL,wdd.delivered_quantity2,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.delivered_quantity2),
        decode(p_delivery_detail_rec.cancelled_quantity2,NULL,wdd.cancelled_quantity2,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.cancelled_quantity2),
        decode(p_delivery_detail_rec.quality_control_quantity2,NULL,wdd.quality_control_quantity2,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.quality_control_quantity2),
        decode(p_delivery_detail_rec.cycle_count_quantity2,NULL,wdd.cycle_count_quantity2,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.cycle_count_quantity2),
        decode(p_delivery_detail_rec.requested_quantity_uom2,NULL,wdd.requested_quantity_uom2,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.requested_quantity_uom2),
-- HW OPMCONV - No need for sublot_number
--      decode(p_delivery_detail_rec.sublot_number,NULL,wdd.sublot_number,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.sublot_number),    /* hverddin end changes */
	decode(p_delivery_detail_rec.pickable_flag,NULL,wdd.pickable_flag,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.pickable_flag),
	decode(p_delivery_detail_rec.original_subinventory,NULL,wdd.original_subinventory,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.original_subinventory),
        decode(p_delivery_detail_rec.to_serial_number,NULL,wdd.to_serial_number,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.to_serial_number),
        decode(p_delivery_detail_rec.picked_quantity,NULL,wdd.picked_quantity,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.picked_quantity),
        decode(p_delivery_detail_rec.picked_quantity2,NULL,wdd.picked_quantity2,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.picked_quantity2),
/* H Integration: datamodel changes wrudge */
        decode(p_delivery_detail_rec.received_quantity,NULL,wdd.received_quantity,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.received_quantity),
        decode(p_delivery_detail_rec.received_quantity2,NULL,wdd.received_quantity2,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.received_quantity2),
        decode(p_delivery_detail_rec.source_line_set_id,NULL,wdd.source_line_set_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.source_line_set_id),
        decode(p_delivery_detail_rec.batch_id,NULL,wdd.batch_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.batch_id),
	decode(p_delivery_detail_rec.transaction_id,NULL,wdd.transaction_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.transaction_id),
	decode(p_delivery_detail_rec.lpn_id,NULL,wdd.lpn_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.lpn_id),
/*  J  Inbound Logistics: New columns jckwok */
        decode(p_delivery_detail_rec.vendor_id,NULL,wdd.vendor_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.vendor_id),
        decode(p_delivery_detail_rec.ship_from_site_id,NULL,wdd.ship_from_site_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.ship_from_site_id),
        decode(p_delivery_detail_rec.line_direction,NULL,wdd.line_direction,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.line_direction),
        decode(p_delivery_detail_rec.party_id,NULL,wdd.party_id,party_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.party_id),
        decode(p_delivery_detail_rec.routing_req_id,NULL,wdd.routing_req_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.routing_req_id),
        decode(p_delivery_detail_rec.shipping_control,NULL,wdd.shipping_control,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.shipping_control),
        decode(p_delivery_detail_rec.source_blanket_reference_id,NULL,wdd.source_blanket_reference_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.source_blanket_reference_id),
        decode(p_delivery_detail_rec.source_blanket_reference_num,NULL,wdd.source_blanket_reference_num,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.source_blanket_reference_num),
        decode(p_delivery_detail_rec.po_shipment_line_id,NULL,wdd.po_shipment_line_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.po_shipment_line_id),
        decode(p_delivery_detail_rec.po_shipment_line_number,NULL,wdd.po_shipment_line_number,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.po_shipment_line_number),
        decode(p_delivery_detail_rec.returned_quantity,NULL,wdd.returned_quantity,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.returned_quantity),
        decode(p_delivery_detail_rec.returned_quantity2,NULL,wdd.returned_quantity2,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.returned_quantity2),
        decode(p_delivery_detail_rec.rcv_shipment_line_id,NULL,wdd.rcv_shipment_line_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.rcv_shipment_line_id),
        decode(p_delivery_detail_rec.source_line_type_code,NULL,wdd.source_line_type_code,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.source_line_type_code),
        decode(p_delivery_detail_rec.supplier_item_number,NULL,wdd.supplier_item_number,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.supplier_item_number),
/* J TP release : ttrichy*/
        decode(p_delivery_detail_rec.IGNORE_FOR_PLANNING,NULL,wdd.IGNORE_FOR_PLANNING,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.IGNORE_FOR_PLANNING),
        decode(p_delivery_detail_rec.EARLIEST_PICKUP_DATE,NULL,wdd.EARLIEST_PICKUP_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_detail_rec.EARLIEST_PICKUP_DATE),
        decode(p_delivery_detail_rec.LATEST_PICKUP_DATE,NULL,wdd.LATEST_PICKUP_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_detail_rec.LATEST_PICKUP_DATE),
        decode(p_delivery_detail_rec.EARLIEST_DROPOFF_DATE,NULL,wdd.EARLIEST_DROPOFF_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_detail_rec.EARLIEST_DROPOFF_DATE),
        decode(p_delivery_detail_rec.LATEST_DROPOFF_DATE,NULL,wdd.LATEST_DROPOFF_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_detail_rec.LATEST_DROPOFF_DATE),
        --decode(p_delivery_detail_rec.DEMAND_SATISFACTION_DATE,NULL,wdd.DEMAND_SATISFACTION_DATE,FND_API.G_MISS_DATE,NULL,p_delivery_detail_rec.DEMAND_SATISFACTION_DATE),
        decode(p_delivery_detail_rec.REQUEST_DATE_TYPE_CODE,NULL,wdd.REQUEST_DATE_TYPE_CODE,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.REQUEST_DATE_TYPE_CODE),
        decode(p_delivery_detail_rec.tp_delivery_detail_id,NULL,wdd.tp_delivery_detail_id,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.tp_delivery_detail_id),
        decode(p_delivery_detail_rec.SOURCE_DOCUMENT_TYPE_ID,NULL,wdd.SOURCE_DOCUMENT_TYPE_ID,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.SOURCE_DOCUMENT_TYPE_ID),
        decode(p_delivery_detail_rec.service_level,NULL,wdd.service_level,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.service_level),
        decode(p_delivery_detail_rec.mode_of_transport,NULL,wdd.mode_of_transport,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.mode_of_transport),
/*WSH: IB ASUTAR*/
decode(p_delivery_detail_rec.po_revision_number,NULL,wdd.po_revision_number,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.po_revision_number),
	decode(p_delivery_detail_rec.release_revision_number,NULL,wdd.release_revision_number,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.release_revision_number),
    decode(p_delivery_detail_rec.replenishment_status,NULL,wdd.replenishment_status,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.replenishment_status), --bug# 6719369 (replenishment project)
    -- Standalone project Changes Start
    decode(p_delivery_detail_rec.original_lot_number,NULL,wdd.original_lot_number,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.original_lot_number),
    decode(p_delivery_detail_rec.reference_number,NULL,wdd.reference_number,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.reference_number),
    decode(p_delivery_detail_rec.reference_line_number,NULL,wdd.reference_line_number,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.reference_line_number),
    decode(p_delivery_detail_rec.reference_line_quantity,NULL,wdd.reference_line_quantity,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.reference_line_quantity),
    decode(p_delivery_detail_rec.reference_line_quantity_uom,NULL,wdd.reference_line_quantity_uom,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.reference_line_quantity_uom),
    decode(p_delivery_detail_rec.original_revision,NULL,wdd.original_revision,FND_API.G_MISS_CHAR,NULL,p_delivery_detail_rec.original_revision),
    decode(p_delivery_detail_rec.original_locator_id,NULL,wdd.original_locator_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.original_locator_id),
    -- Standalone project Changes End
    decode(p_delivery_detail_rec.client_id,NULL,wdd.client_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.client_id), -- LSP PROJECT:
    -- TPW - Distributed Organization Changes - Start
    decode(p_delivery_detail_rec.shipment_batch_id,NULL,wdd.shipment_batch_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.shipment_batch_id),
    decode(p_delivery_detail_rec.shipment_line_number,NULL,wdd.shipment_line_number,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.shipment_line_number),
    decode(p_delivery_detail_rec.reference_line_id,NULL,wdd.reference_line_id,FND_API.G_MISS_NUM,NULL,p_delivery_detail_rec.reference_line_id)
    -- TPW - Distributed Organization Changes - End
FROM WSH_DELIVERY_DETAILS wdd
WHERE delivery_detail_id = p_delivery_detail_id;

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER INSERTING INTO WSH_DELIVERY_DETAILS'  );
        END IF;
        --

        x_dd_id_tab := l_dd_id_tab; -- unable to use RETURNING INTO .. BULK COLLECT above

        -- DBI Project
        -- Insert of wsh_delivery_details,  call DBI API after the insert.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail count-',x_dd_id_tab.count);
        END IF;
        WSH_INTEGRATION.DBI_Update_Detail_Log
          (p_delivery_detail_id_tab => x_dd_id_tab,
           p_dml_type               => 'INSERT',
           x_return_status          => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_dbi_rs;
          -- just pass this return status to caller API
        END IF;
        -- End of Code for DBI Project
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --

EXCEPTION
	WHEN others THEN
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'WHEN OTHERS IN CREATE_DD_FROM_OLD_BULK ' || SQLERRM  );
          END IF;
          --
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	  wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.CREATE_DD_FROM_OLD_BULK',l_module_name);
	  --
	  IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	  END IF;
	  --
END create_dd_from_old_bulk;

/***********************************
    CREATE_DD_FROM_OLD_BULK
***********************************/
-- This API has been called to
-- make a Bulk call for creating Delivery Assignments
-- from Split API in WSHDDACB

--
--  Procedure:   Create_Delivery_Assignment_Bulk
--  Parameters:  All Attributes of a Delivery Assignment Record,
--               Row_id out
--               Delivery_Assignment_id out
--               Return_Status out
--  Description: This procedure will create a delivery_assignment
--               It will return to the use the delivery_assignment_id
--               if not provided as a parameter.
--

PROCEDURE Create_Deliv_Assignment_bulk(
	p_delivery_assignments_info    IN   Delivery_Assignments_Rec_Type,
        p_num_of_rec                   IN   NUMBER,
  	p_dd_id_tab        	       IN  WSH_UTIL_CORE.id_tab_type,
  	x_da_id_tab        	       OUT NOCOPY   WSH_UTIL_CORE.id_tab_type,
  	x_return_status                OUT NOCOPY   VARCHAR2
-- added new input parameter
) IS


CURSOR C_Del_Assign_ID
IS SELECT wsh_delivery_assignments_s.nextval
FROM sys.dual;

l_row_count NUMBER;
l_temp_id   NUMBER;

l_da_id_tab WSH_UTIL_CORE.id_tab_type;
l_da_info   Delivery_Assignments_Rec_Type;
others exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DELIV_ASSIGNMENT_BULK';
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
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        FOR i in 1..p_num_of_rec
        LOOP
	  OPEN C_Del_Assign_ID;
          FETCH C_Del_Assign_ID
           INTO l_da_id_tab(i);
	  CLOSE C_Del_Assign_ID;
        END LOOP;

	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name, 'BEFORE DELIVERY ASSIGNMENT BULK INSERT'||l_da_id_tab.count);
	END IF;
        x_da_id_tab := l_da_id_tab;

	FORALL i in 1..p_num_of_rec
        INSERT INTO wsh_delivery_assignments
  		(delivery_id,
     	parent_delivery_id,
      delivery_detail_id,
      parent_delivery_detail_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      program_application_id,
      program_id,
		program_update_date,
		request_id,
		active_flag,
                type,
      delivery_assignment_id
      ) VALUES (
		p_delivery_assignments_info.delivery_id,
     	p_delivery_assignments_info.parent_delivery_id,
     	p_dd_id_tab(i),
     	p_delivery_assignments_info.parent_delivery_detail_id,
      SYSDATE,
      FND_GLOBAL.USER_ID,
      SYSDATE,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.USER_ID,
      NULL,
      NULL,
      NULL,
      p_delivery_assignments_info.request_id,
      p_delivery_assignments_info.active_flag,
      NVL(p_delivery_assignments_info.type, 'S'),
      l_da_id_tab(i)
      );
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
	EXCEPTION
 	  WHEN others THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	    wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.CREATE_DELIV_ASSIGNMENT_BULK',l_module_name);

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Create_Deliv_Assignment_bulk;
/************* End of BULK OPERATION *****************/

PROCEDURE create_new_detail_from_old(
	p_delivery_detail_rec	IN WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
        p_delivery_detail_id    IN NUMBER,
	x_row_id		OUT NOCOPY  VARCHAR2,
	x_delivery_detail_id OUT NOCOPY  NUMBER,
	x_return_status	OUT NOCOPY  VARCHAR2
	) IS

l_container_name varchar2(50);

CURSOR C_Del_Detail_Rowid
IS SELECT rowid
FROM wsh_delivery_details
WHERE delivery_detail_id = x_delivery_detail_id;

CURSOR C_Del_detail_ID
IS
SELECT wsh_delivery_details_s.nextval
FROM sys.dual;

CURSOR C_Check_Detail_ID
IS SELECT rowid
FROM wsh_delivery_details
WHERE delivery_detail_id = x_delivery_detail_id;

l_row_count NUMBER;
l_temp_id   NUMBER;
l_dd_id_tab WSH_UTIL_CORE.id_tab_type;
others exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_NEW_DETAIL_FROM_OLD';
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
            WSH_DEBUG_SV.logmsg(l_module_name, 'INSIDE PROCEDURE CREATE NEW DETAIL FROM OLD CALLING BULK API'  );
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
-- make call to Bulk api from here
        WSH_DELIVERY_DETAILS_PKG.create_dd_from_old_bulk
          ( p_delivery_detail_rec  =>  p_delivery_detail_rec,
            p_delivery_detail_id  => p_delivery_detail_id,
            p_num_of_rec  => 1,
	    x_dd_id_tab => l_dd_id_tab,
	    x_return_status => x_return_status
          );

          x_delivery_detail_id := l_dd_id_tab(1);

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER INSERTING INTO WSH_DELIVERY_DETAILS'  );
        END IF;
        --
     	OPEN C_Del_Detail_Rowid;
		FETCH C_Del_Detail_Rowid INTO x_row_id;
     	IF (C_Del_Detail_Rowid%NOTFOUND) THEN
     		CLOSE C_Del_Detail_Rowid;
        	RAISE others;
        END IF;
     	CLOSE C_Del_Detail_Rowid;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
	EXCEPTION
		WHEN others THEN
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'WHEN OTHERS IN CREATE_NEW_DETAIL_FROM_OLD ' || SQLERRM  );
                END IF;
                --
			x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
			wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.CREATE_NEW_DETAIL_FROM_OLD',l_module_name);
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
			END IF;
			--
END create_new_detail_from_old;

--
--  Procedure:   Delete_Delivery_Detail
--  Parameters:  All Attributes of a Delivery Detail Record
--  Description: This procedure will delete a delivery detail.
--  Since this is a table handler no validations are done at this
--  level. The calling routine should make sure that the delete
--  action is valid for the respective details being deleted.
--

PROCEDURE Delete_Delivery_Details (
	p_rowid            IN   VARCHAR2 := NULL,
 	p_delivery_detail_id  IN   NUMBER := NULL,
        p_cancel_flag         IN VARCHAR2 DEFAULT NULL,
 	x_return_status    OUT NOCOPY   VARCHAR2
) IS


CURSOR get_del_detail(v_rowid VARCHAR2)
IS
SELECT wdd.delivery_detail_id,
		 wdd.inventory_item_id,
		 wdd.organization_id,
		 wdd.subinventory,
		 wdd.serial_number,
                 wdd.container_flag, -- bug 4416863
	     	 wdd.transaction_temp_id,
                 wda.delivery_id,
                 nvl(wdd.ignore_for_planning, 'N'), -- OTM R12
                 nvl(wdd.gross_weight, 0)           -- OTM R12 : packing ECO
FROM    wsh_delivery_details wdd, wsh_delivery_assignments wda
WHERE	wdd.delivery_detail_id = wda.delivery_detail_id
and     wdd.rowid = v_rowid;

CURSOR get_del_detail_by_id(v_delivery_detail_id NUMBER) IS
SELECT wdd.delivery_detail_id,
		 wdd.inventory_item_id,
		 wdd.organization_id,
		 wdd.subinventory,
		 wdd.serial_number,
                 wdd.container_flag, -- bug 4416863
		 wdd.transaction_temp_id,
                 wda.delivery_id,
                 nvl(wdd.ignore_for_planning, 'N'), -- OTM R12
                 nvl(wdd.gross_weight, 0)           -- OTM R12 : packing ECO
FROM wsh_delivery_details wdd, wsh_delivery_assignments wda
WHERE	wdd.delivery_detail_id = wda.delivery_detail_id
        and wdd.delivery_detail_id = v_delivery_detail_id;

l_delivery_detail_id		NUMBER	:= NULL;


l_inventory_item_id     NUMBER   := NULL;
l_organization_id       NUMBER   := NULL;
l_subinventory          VARCHAR2(10) := NULL;
l_serial_number         VARCHAR2(30) := NULL;
l_transaction_temp_id   NUMBER   := NULL;
l_inv_controls_rec      WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec;
l_return_status         VARCHAR2(5) := NULL;

l_detail_tab          WSH_UTIL_CORE.id_tab_type; -- DBI changes
l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API
l_dbi_dml_type        VARCHAR2(10);

-- bug 4416863
l_container_flag VARCHAR2(1);
l_delivery_id    NUMBER := NULL;
-- end bug

-- OTM R12
l_delivery_id_tab    WSH_UTIL_CORE.ID_TAB_TYPE;
l_interface_flag_tab WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_ignore             WSH_DELIVERY_DETAILS.IGNORE_FOR_PLANNING%TYPE;
l_is_delivery_empty  VARCHAR2(1);
l_gc3_is_installed   VARCHAR2(1);
l_gross_weight       WSH_DELIVERY_DETAILS.GROSS_WEIGHT%TYPE;   -- packing ECO
l_call_update        VARCHAR2(1);
-- end of OTM R12

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_DELIVERY_DETAILS';
--
BEGIN
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_CANCEL_FLAG',P_CANCEL_FLAG);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  -- OTM R12
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;
  IF l_gc3_is_installed IS NULL THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_gc3_is_installed',l_gc3_is_installed);
  END IF;
  -- End of OTM R12

  IF p_rowid IS NOT NULL THEN
    OPEN get_del_detail(p_rowid);
    FETCH get_del_detail
     INTO l_delivery_detail_id, l_inventory_item_id,
          l_organization_id, l_subinventory,
          l_serial_number, l_container_flag, l_transaction_temp_id,
          l_delivery_id, l_ignore,  -- OTM R12 : l_ignore is added
          l_gross_weight;           -- OTM R12 : packing ECO
    CLOSE get_del_detail;
  ELSIF p_delivery_detail_id IS NOT NULL THEN
    OPEN get_del_detail_by_id(p_delivery_detail_id);
    FETCH get_del_detail_by_id
     INTO l_delivery_detail_id, l_inventory_item_id,
          l_organization_id, l_subinventory ,
          l_serial_number, l_container_flag, l_transaction_temp_id,
          l_delivery_id, l_ignore,  -- OTM R12 : l_ignore is added
          l_gross_weight;           -- OTM R12 : packing ECO
    CLOSE get_del_detail_by_id;
  END IF;
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_delivery_detail_id',l_delivery_detail_id);
    WSH_DEBUG_SV.log(l_module_name,'l_inventory_item_id',l_inventory_item_id);
    WSH_DEBUG_SV.log(l_module_name,'l_organization_id',l_organization_id);
    WSH_DEBUG_SV.log(l_module_name,'l_subinventory', l_subinventory);
    WSH_DEBUG_SV.log(l_module_name,'l_serial_number', l_serial_number);
    WSH_DEBUG_SV.log(l_module_name,'l_container_flag', l_container_flag);
    WSH_DEBUG_SV.log(l_module_name,'l_transaction_temp_id',l_transaction_temp_id);
    WSH_DEBUG_SV.log(l_module_name,'l_delivery_id', l_delivery_id);
    WSH_DEBUG_SV.log(l_module_name,'l_ignore', l_ignore);
    WSH_DEBUG_SV.log(l_module_name,'l_gross_weight', l_gross_weight);
  END IF;

  IF l_delivery_detail_id IS NOT NULL THEN
    IF l_serial_number IS NOT NULL OR l_transaction_temp_id IS NOT NULL THEN
        --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.FETCH_INV_CONTROLS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_DELIVERY_DETAILS_INV.Fetch_Inv_Controls(
		         p_delivery_detail_id   => l_delivery_detail_id,
		         p_inventory_item_id    => l_inventory_item_id,
		         p_organization_id      => l_organization_id,
		         p_subinventory         => l_subinventory,
		         x_inv_controls_rec     => l_inv_controls_rec,
		         x_return_status        => l_return_status);

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.UNMARK_SERIAL_NUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_DELIVERY_DETAILS_INV.Unmark_Serial_Number(
		         p_delivery_detail_id   => l_delivery_detail_id,
		         p_serial_number_code   => l_inv_controls_rec.serial_code,
		         p_serial_number        => l_serial_number,
		         p_transaction_temp_id  => l_transaction_temp_id,
		         x_return_status        => l_return_status);

    END IF;

    DELETE FROM wsh_freight_costs
     WHERE delivery_detail_id  = l_delivery_detail_id;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Rows deleted',SQL%ROWCOUNT);
    END IF;

    -- bug 4416863
    IF (l_delivery_id is not null) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_delivery_details_actions.unassign_detail_from_delivery', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      wsh_delivery_details_actions.unassign_detail_from_delivery (
         p_detail_id => l_delivery_detail_id,
         x_return_status => l_return_status);
      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR
         (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
        --
        x_return_status := l_return_status;
        WSH_UTIL_CORE.Add_Message(x_return_status);
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        return;
      END IF;
    END IF;
    -- end bug 4416863

    IF p_cancel_flag = 'Y' THEN
          UPDATE wsh_delivery_details
             SET move_order_line_id = NULL ,
                 released_status = 'D',
                 requested_quantity = 0,
                 requested_quantity2 = 0,
                 src_requested_quantity = 0,
                 src_requested_quantity2 = 0,
                 cancelled_quantity = requested_quantity,
                 cancelled_quantity2 = requested_quantity2,
                 cycle_count_quantity = NULL,
                 cycle_count_quantity2 = NULL,
                 shipped_quantity = NULL,
                 shipped_quantity2 = NULL,
                 picked_quantity = NULL,
                 picked_quantity2 = NULL,
                 subinventory = NULL,
                 inv_interfaced_flag = NULL,
                 oe_interfaced_flag  = NULL,
                 locator_id = NULL,
                 preferred_grade = NULL,
-- HW OPMCONV - No need for sublot_number
--               sublot_number = NULL,
                 lot_number = NULL,
                 revision   = null ,
                 tracking_number = NULL,
                 -- J: W/V Changes
                 gross_weight = 0,
                 net_weight = 0,
                 volume = 0
             WHERE delivery_detail_id = l_delivery_detail_id;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Rows Updated',SQL%ROWCOUNT);
      END IF;
      l_dbi_dml_type := 'UPDATE';
    ELSE -- else of cancel_flag='Y'
      DELETE FROM wsh_delivery_details
       WHERE delivery_detail_id  = l_delivery_detail_id;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Rows deleted from wsh_delivery_details',SQL%ROWCOUNT);
      END IF;
      l_dbi_dml_type := 'DELETE';

      DELETE FROM wsh_delivery_assignments
       WHERE delivery_detail_id  = l_delivery_detail_id;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Rows deleted from wsh_delivery_assignments',SQL%ROWCOUNT);
      END IF;

      -- OTM R12
      -- packing ECO : l_container_flag = 'N' is removed from the if condition
      IF (l_gc3_is_installed = 'Y' AND
          l_delivery_id IS NOT NULL AND
          l_ignore = 'N') THEN

        l_call_update := 'Y';
        l_delivery_id_tab(1) := l_delivery_id;
        l_is_delivery_empty := WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY(l_delivery_id);
        IF (l_is_delivery_empty = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY');
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        ELSIF (l_is_delivery_empty = 'Y') THEN
          l_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED;
        ELSIF (l_is_delivery_empty = 'N') THEN
          l_interface_flag_tab(1) := NULL;
          --Bug7608629
          --removed code which checked for gross weight
          --now irrespective of gross weight  UPDATE_TMS_INTERFACE_FLAG will be called
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'l_call_update', l_call_update);
          IF (l_call_update = 'Y') THEN
            WSH_DEBUG_SV.log(l_module_name, 'l_delivery_id_tab', l_delivery_id_tab(1));
            WSH_DEBUG_SV.log(l_module_name, 'l_interface_flag_tab', l_interface_flag_tab(1));
          END IF;
        END IF;

        IF (l_call_update = 'Y') THEN
          WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG(
            p_delivery_id_tab        => l_delivery_id_tab,
            p_tms_interface_flag_tab => l_interface_flag_tab,
            x_return_status          => l_return_status);

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            --
            x_return_status := l_return_status;
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG');
              WSH_DEBUG_SV.log(l_module_name,'l_return_status', l_return_status);
              WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN;
          END IF;
        END IF;


      END IF;
      -- End of OTM R12

    END IF;-- end of cancel_flag='Y'

    -- DBI Call for either update/delete using l_delivery_detail_id
    -- DBI Project
    -- Update of wsh_delivery_details where requested_quantity/released_status
    -- are changed, call DBI API after the update.
    -- This API will also check for DBI Installed or not
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',l_delivery_detail_id);
    END IF;
    l_detail_tab(1) := l_delivery_detail_id;
    WSH_INTEGRATION.DBI_Update_Detail_Log
      (p_delivery_detail_id_tab => l_detail_tab,
       p_dml_type               => l_dbi_dml_type,
       x_return_status          => l_dbi_rs);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
    END IF;
    IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_dbi_rs;
      -- just pass this return status to caller API
    END IF;
    -- End of Code for DBI Project
    --

  END IF;  -- l_delivery_detail_id is not null

  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.DELETE_DELIVERY_DETAILS',l_module_name);

    -- close all cursors at exception
    IF (get_del_detail%ISOPEN) THEN
      CLOSE get_del_detail;
    END IF;

    IF (get_del_detail_by_id%ISOPEN) THEN
      CLOSE get_del_detail_by_id;
    END IF;

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END Delete_Delivery_Details;


--
--  Procedure:   Lock_Delivery_Details
--  Parameters:  All Attributes of a Delivery Detail Record
--  Description: This procedure will lock a delivery detail
--               record. It is specifically designed for
--               use by the form.
--

PROCEDURE Lock_Delivery_Details(
	p_rowid		IN VARCHAR2,
	p_delivery_details_info	IN WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type)
IS

CURSOR C_LOCK_DELIVERY_DETAIL IS
SELECT *
FROM  WSH_DELIVERY_DETAILS
WHERE ROWID = p_rowid
FOR UPDATE OF DELIVERY_DETAIL_ID NOWAIT;
recinfo C_LOCK_DELIVERY_DETAIL%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_DELIVERY_DETAILS';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
	END IF;
	--
	OPEN C_LOCK_DELIVERY_DETAIL;
  	FETCH C_LOCK_DELIVERY_DETAIL INTO recinfo;
  	IF (C_LOCK_DELIVERY_DETAIL%NOTFOUND) THEN
		CLOSE C_LOCK_DELIVERY_DETAIL;
	  	FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'FORM_RECORD_DELETED');
                END IF;
	  	app_exception.raise_exception;
 	END IF;
  	CLOSE C_LOCK_DELIVERY_DETAIL;

	if ((recinfo.source_code = p_delivery_details_info.SOURCE_CODE)
		and
		((recinfo.source_header_id = p_delivery_details_info.SOURCE_HEADER_ID)
		or
		((recinfo.source_header_id is null)
	    and (p_delivery_details_info.source_header_id is null)))

	and
		(recinfo.source_line_id = p_delivery_details_info.SOURCE_LINE_ID)
	and
	 	((recinfo.customer_id = p_delivery_details_info.CUSTOMER_ID)
		or
		((recinfo.customer_id is null)
		and (p_delivery_Details_info.customer_id is NULL)))
     and
                ((recinfo.sold_to_contact_id = p_delivery_details_info.SOLD_TO_CONTACT_ID)
                or
                ((recinfo.sold_to_contact_id is null)
                 and (p_delivery_details_info.SOLD_TO_CONTACT_ID is null)))

	and
	        ((recinfo.inventory_item_id = p_delivery_details_info.INVENTORY_ITEM_ID)
		or
		((recinfo.inventory_item_id is null)
		 and (p_delivery_details_info.INVENTORY_ITEM_ID is null)))
        and
                ((recinfo.item_description = p_delivery_details_info.ITEM_DESCRIPTION)
                or
                ((recinfo.item_description is null)
                 and (p_delivery_details_info.ITEM_DESCRIPTION is null)))

	and
                ((recinfo.hazard_class_id = p_delivery_details_info.HAZARD_CLASS_ID)
                or
                ((recinfo.hazard_class_id is null)
                 and (p_delivery_details_info.hazard_class_id is null)))
	and
		((recinfo.country_of_origin = p_delivery_details_info.COUNTRY_OF_ORIGIN)
                or
                ((recinfo.country_of_origin is null)
                 and (p_delivery_details_info.COUNTRY_OF_ORIGIN is null)))

	and
		((recinfo.classification = p_delivery_details_info.classification)
                or
                ((recinfo.classification is null)
                 and (p_delivery_details_info.classification is null)))
 	and	(recinfo.ship_from_location_id = p_delivery_details_info.SHIP_FROM_LOCATION_ID)
	and	((recinfo.ship_to_location_id = p_delivery_details_info.SHIP_TO_LOCATION_ID)
		or
		 ((recinfo.ship_to_location_id is null)
		   and (p_delivery_details_info.SHIP_TO_LOCATION_ID is null)))

	and
		((recinfo.ship_to_contact_id = p_delivery_details_info.SHIP_TO_CONTACT_ID)
                or
                ((recinfo.ship_to_contact_id is null)
                 and (p_delivery_details_info.SHIP_TO_CONTACT_ID is null)))
	and	((recinfo.deliver_to_location_id = p_delivery_details_info.DELIVER_TO_LOCATION_ID)
			or
			 ((recinfo.deliver_to_location_id is null)
			 and (p_delivery_details_info.DELIVER_TO_LOCATION_ID is null)))

	and	((recinfo.deliver_to_contact_id = p_delivery_details_info.DELIVER_TO_CONTACT_ID)
                or
                ((recinfo.deliver_to_contact_id is null)
                 and (p_delivery_details_info.DELIVER_TO_CONTACT_ID is null)))


	and
		((recinfo.intmed_ship_to_contact_id = p_delivery_details_info.INTMED_SHIP_TO_CONTACT_ID)
		or
		((recinfo.intmed_ship_to_contact_id is null)
		 and (p_delivery_details_info.INTMED_SHIP_TO_CONTACT_ID is null)))
	and
		((recinfo.intmed_ship_to_location_id = p_delivery_details_info.INTMED_SHIP_TO_LOCATION_ID)
		or
		((recinfo.intmed_ship_to_location_id is null)
	     and (p_delivery_details_info.INTMED_SHIP_TO_LOCATION_ID is null)))

	and
		((recinfo.ship_tolerance_above = p_delivery_details_info.SHIP_TOLERANCE_ABOVE)
		or
		((recinfo.ship_tolerance_above is null)
		 and (p_delivery_details_info.SHIP_TOLERANCE_ABOVE is null)))
	and
		((recinfo.ship_tolerance_below = p_delivery_details_info.SHIP_TOLERANCE_BELOW)
		or
		((recinfo.ship_tolerance_below is null)
		 and (p_delivery_details_info.SHIP_TOLERANCE_BELOW is null)))
	and
		(recinfo.created_by = p_delivery_details_info.CREATED_BY)
	and
		(recinfo.creation_date = p_delivery_details_info.CREATION_DATE)
	and
		(recinfo.last_update_date = p_delivery_details_info.LAST_UPDATE_DATE)
	and
		((recinfo.last_update_login = p_delivery_details_info.LAST_UPDATE_LOGIN)
		or
		((recinfo.last_update_login is null)
		 and (p_delivery_details_info.LAST_UPDATE_LOGIN is null)))
	and
		(recinfo.last_updated_by = p_delivery_details_info.LAST_UPDATED_BY)
	and
		((recinfo.program_application_id = p_delivery_details_info.PROGRAM_APPLICATION_ID)
		or
		((recinfo.program_application_id is null)
		 and (p_delivery_details_info.PROGRAM_APPLICATION_ID is null)))

	and	((recinfo.program_id = p_delivery_details_info.PROGRAM_ID)
		or
		((recinfo.program_id is null)
		 and (p_delivery_details_info.PROGRAM_ID is null)))
	and
		((recinfo.program_update_date = p_delivery_details_info.PROGRAM_UPDATE_DATE)
		or
		((recinfo.program_update_date is null)
		 and (p_delivery_details_info.PROGRAM_UPDATE_DATE is null)))
	and
                ((recinfo.request_id = p_delivery_details_info.REQUEST_ID)
                or
                ((recinfo.request_id is null)
                 and (p_delivery_details_info.REQUEST_ID is null)))
	and
		(recinfo.requested_quantity = p_delivery_details_info.REQUESTED_QUANTITY)
	and
		((recinfo.shipped_quantity = p_delivery_details_info.SHIPPED_QUANTITY)
                or
                ((recinfo.shipped_quantity is null)
                 and (p_delivery_details_info.SHIPPED_QUANTITY is null)))
	and
		((recinfo.delivered_quantity = p_delivery_details_info.DELIVERED_QUANTITY)
		or
		((recinfo.delivered_quantity is null)
		 and (p_delivery_details_info.DELIVERED_QUANTITY is null)))
	and
		(recinfo.requested_quantity_uom = p_delivery_details_info.REQUESTED_QUANTITY_UOM)
	and
		((recinfo.subinventory= p_delivery_details_info.SUBINVENTORY)
		or
		((recinfo.subinventory is null)
		and (p_delivery_details_info.SUBINVENTORY is null)))
	and
		((recinfo.revision = p_delivery_details_info.REVISION)
		or
		((recinfo.revision is null)
		and (p_delivery_details_info.REVISION is null)))
	and
		((recinfo.lot_number  = p_delivery_details_info.LOT_NUMBER)
		or
		((recinfo.lot_number is null)
		and (p_delivery_details_info.LOT_NUMBER is null)))
	and
                ((recinfo.customer_requested_lot_flag  = p_delivery_details_info.CUSTOMER_REQUESTED_LOT_FLAG)
                or
                ((recinfo.customer_requested_lot_flag is null)
                and (p_delivery_details_info.CUSTOMER_REQUESTED_LOT_FLAG is null)))
	and
                ((recinfo.serial_number  = p_delivery_details_info.SERIAL_NUMBER)
                or
                ((recinfo.serial_number is null)
                and (p_delivery_details_info.SERIAL_NUMBER is null)))
	and
                ((recinfo.locator_id  = p_delivery_details_info.locator_ID)
                or
                ((recinfo.locator_id is null)
                and (p_delivery_details_info.locator_ID is null)))
	and
		((recinfo.date_requested = p_delivery_details_info.DATE_REQUESTED)
		or
		((recinfo.date_requested is null)
		and (p_delivery_details_info.DATE_REQUESTED is null)))
	and
		((recinfo.date_scheduled = p_delivery_details_info.DATE_SCHEDULED)
		or
		((recinfo.date_scheduled is null)
		and (p_delivery_details_info.DATE_SCHEDULED is null)))
	and
		((recinfo.master_container_item_id = p_delivery_details_info.MASTER_CONTAINER_ITEM_ID)
		or
		((recinfo.master_container_item_id is null)
		and (p_delivery_details_info.MASTER_CONTAINER_ITEM_ID is null)))
	and
		((recinfo.detail_container_item_id = p_delivery_details_info.DETAIL_CONTAINER_ITEM_ID)
		or
		((recinfo.detail_container_item_id is null)
		and (p_delivery_details_info.DETAIL_CONTAINER_ITEM_ID is null)))
	and
		((recinfo.load_seq_number = p_delivery_details_info.LOAD_SEQ_NUMBER)
		or
		((recinfo.load_seq_number is null)
   		and (p_delivery_details_info.LOAD_SEQ_NUMBER is null)))
	and
		((recinfo.ship_method_code = p_delivery_details_info.SHIP_METHOD_CODE)
		or
		((recinfo.ship_method_code is null)
		and (p_delivery_details_info.SHIP_METHOD_CODE is null)))
	and
		((recinfo.carrier_id = p_delivery_details_info.CARRIER_ID)
		or
		((recinfo.carrier_id is null)
		and (p_delivery_details_info.CARRIER_ID is null)))
	and
		((recinfo.freight_terms_code = p_delivery_details_info.FREIGHT_TERMS_CODE)
		or
		((recinfo.freight_terms_code is null)
		and (p_delivery_details_info.FREIGHT_TERMS_CODE is null)))
	and
		((recinfo.shipment_priority_code = p_delivery_details_info.SHIPMENT_PRIORITY_CODE)
		or
		((recinfo.shipment_priority_code is null)
		and (p_delivery_details_info.SHIPMENT_PRIORITY_CODE is null)))
	and
		((recinfo.fob_code = p_delivery_details_info.FOB_CODE)
		or
		((recinfo.fob_code is null)
		and (p_delivery_details_info.FOB_CODE is null)))
	and
		((recinfo.customer_item_id = p_delivery_details_info.CUSTOMER_ITEM_ID)
		or
		((recinfo.customer_item_id is null)
		and (p_delivery_details_info.CUSTOMER_ITEM_ID is null)))
	and
		((recinfo.dep_plan_required_flag = p_delivery_details_info.DEP_PLAN_REQUIRED_FLAG)
		or
		((recinfo.dep_plan_required_flag is null)
		and (p_delivery_details_info.DEP_PLAN_REQUIRED_FLAG is null)))
	and
		((recinfo.customer_prod_seq = p_delivery_details_info.CUSTOMER_PROD_SEQ)
		or
		((recinfo.customer_prod_seq is null)
		and (p_delivery_details_info.CUSTOMER_PROD_SEQ is null)))
	and
		((recinfo.customer_dock_code = p_delivery_details_info.CUSTOMER_DOCK_CODE)
		or
		((recinfo.customer_dock_code is null)
		and (p_delivery_details_info.CUSTOMER_DOCK_CODE is null)))
	and
		((recinfo.cust_model_serial_number = p_delivery_details_info.CUST_MODEL_SERIAL_NUMBER)
		or
		((recinfo.cust_model_serial_number is null)
		and (p_delivery_details_info.CUST_MODEL_SERIAL_NUMBER is null)))
	and
		((recinfo.customer_job = p_delivery_details_info.CUSTOMER_JOB)
		or
		((recinfo.customer_job is null)
		and (p_delivery_details_info.CUSTOMER_JOB is null)))
	and
		((recinfo.customer_production_line = p_delivery_details_info.CUSTOMER_PRODUCTION_LINE)
		or
		((recinfo.customer_production_line is null)
		and (p_delivery_details_info.CUSTOMER_PRODUCTION_LINE is null)))

	and
		((recinfo.net_weight = p_delivery_details_info.NET_WEIGHT)
		or
		((recinfo.net_weight is null)
		and (p_delivery_details_info.NET_WEIGHT is null)))
	and
		((recinfo.weight_uom_code = p_delivery_details_info.WEIGHT_UOM_CODE)
		or
		((recinfo.weight_uom_code is null)
		and (p_delivery_details_info.WEIGHT_UOM_CODE is null)))
	and
		((recinfo.volume = p_delivery_details_info.VOLUME)
		or
		((recinfo.volume is null)
		and (p_delivery_details_info.VOLUME is null)))
	and
		((recinfo.volume_uom_code = p_delivery_details_info.VOLUME_UOM_CODE)
		or
		((recinfo.volume_uom_code is null)
		and (p_delivery_details_info.VOLUME_UOM_CODE is null)))

	and
                ((recinfo.tp_attribute_category = p_delivery_details_info.TP_ATTRIBUTE_CATEGORY)
                or
                ((recinfo.tp_attribute_category is null)
                and (p_delivery_details_info.TP_ATTRIBUTE_CATEGORY is null)))

	and
		((recinfo.tp_attribute1 = p_delivery_details_info.TP_ATTRIBUTE1)
                or
                ((recinfo.tp_attribute1 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE1 is null)))

	and
                ((recinfo.tp_attribute2 = p_delivery_details_info.TP_ATTRIBUTE2)
                or
                ((recinfo.tp_attribute2 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE2 is null)))
	and
                ((recinfo.tp_attribute3 = p_delivery_details_info.TP_ATTRIBUTE3)
                or
                ((recinfo.tp_attribute3 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE3 is null)))
	and
                ((recinfo.tp_attribute4 = p_delivery_details_info.TP_ATTRIBUTE4)
                or
                ((recinfo.tp_attribute4 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE4 is null)))

	and
                ((recinfo.tp_attribute5 = p_delivery_details_info.TP_ATTRIBUTE5)
                or
                ((recinfo.tp_attribute5 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE5 is null)))
	and
                ((recinfo.tp_attribute6 = p_delivery_details_info.TP_ATTRIBUTE6)
                or
                ((recinfo.tp_attribute6 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE6 is null)))
	and
                ((recinfo.tp_attribute7 = p_delivery_details_info.TP_ATTRIBUTE7)
                or
                ((recinfo.tp_attribute7 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE7 is null)))
	and
                ((recinfo.tp_attribute8 = p_delivery_details_info.TP_ATTRIBUTE8)
                or
                ((recinfo.tp_attribute8 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE8 is null)))
	and
                ((recinfo.tp_attribute9 = p_delivery_details_info.TP_ATTRIBUTE9)
                or
                ((recinfo.tp_attribute9 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE9 is null)))

	and
                ((recinfo.tp_attribute10 = p_delivery_details_info.TP_ATTRIBUTE10)
                or
                ((recinfo.tp_attribute10 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE10 is null)))
	and
                ((recinfo.tp_attribute11 = p_delivery_details_info.TP_ATTRIBUTE11)
                or
                ((recinfo.tp_attribute11 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE11 is null)))
	and
                ((recinfo.tp_attribute12 = p_delivery_details_info.TP_ATTRIBUTE12)
                or
                ((recinfo.tp_attribute12 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE12 is null)))
	and
                ((recinfo.tp_attribute13 = p_delivery_details_info.TP_ATTRIBUTE13)
                or
                ((recinfo.tp_attribute13 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE13 is null)))

	and
                ((recinfo.tp_attribute14 = p_delivery_details_info.TP_ATTRIBUTE14)
                or
                ((recinfo.tp_attribute14 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE14 is null)))


	and
                ((recinfo.tp_attribute15 = p_delivery_details_info.TP_ATTRIBUTE15)
                or
                ((recinfo.tp_attribute15 is null)
                and (p_delivery_details_info.TP_ATTRIBUTE15 is null)))

        and
                ((recinfo.attribute_category = p_delivery_details_info.ATTRIBUTE_CATEGORY)
                or
                ((recinfo.attribute_category is null)
                and (p_delivery_details_info.ATTRIBUTE_CATEGORY is null)))

	and
		((recinfo.attribute1 = p_delivery_details_info.ATTRIBUTE1)
		or
		((recinfo.attribute1 is null)
		and (p_delivery_details_info.ATTRIBUTE1 is null)))
	and
		((recinfo.attribute_category = p_delivery_details_info.ATTRIBUTE_CATEGORY)
                or
                ((recinfo.attribute_category is null)
                and (p_delivery_details_info.ATTRIBUTE_CATEGORY is null)))
	and
		((recinfo.attribute2 = p_delivery_details_info.ATTRIBUTE2)
                or
                ((recinfo.attribute2 is null)
                and (p_delivery_details_info.ATTRIBUTE2 is null)))

	and
                ((recinfo.attribute3 = p_delivery_details_info.ATTRIBUTE3)
                or
                ((recinfo.attribute3 is null)
                and (p_delivery_details_info.ATTRIBUTE3 is null)))
	and
		((recinfo.attribute4 = p_delivery_details_info.ATTRIBUTE4)
                or
                ((recinfo.attribute4 is null)
                and (p_delivery_details_info.ATTRIBUTE4 is null)))

	and
                ((recinfo.attribute5 = p_delivery_details_info.ATTRIBUTE5)
                or
                ((recinfo.attribute5 is null)
                and (p_delivery_details_info.ATTRIBUTE5 is null)))
	and
                ((recinfo.attribute6 = p_delivery_details_info.ATTRIBUTE6)
                or
                ((recinfo.attribute6 is null)
                and (p_delivery_details_info.ATTRIBUTE6 is null)))
	and
                ((recinfo.attribute7 = p_delivery_details_info.ATTRIBUTE7)
                or
                ((recinfo.attribute7 is null)
                and (p_delivery_details_info.ATTRIBUTE7 is null)))
	and
                ((recinfo.attribute8 = p_delivery_details_info.ATTRIBUTE8)
                or
                ((recinfo.attribute8 is null)
                and (p_delivery_details_info.ATTRIBUTE8 is null)))
	and
                ((recinfo.attribute9 = p_delivery_details_info.ATTRIBUTE9)
                or
                ((recinfo.attribute9 is null)
                and (p_delivery_details_info.ATTRIBUTE9 is null)))
	and
                ((recinfo.attribute10 = p_delivery_details_info.ATTRIBUTE10)
                or
                ((recinfo.attribute10 is null)
                and (p_delivery_details_info.ATTRIBUTE10 is null)))

	and
		((recinfo.attribute11 = p_delivery_details_info.ATTRIBUTE11)
                or
                ((recinfo.attribute11 is null)
                and (p_delivery_details_info.ATTRIBUTE11 is null)))
	and
                ((recinfo.attribute12 = p_delivery_details_info.ATTRIBUTE12)
                or
                ((recinfo.attribute12 is null)
                and (p_delivery_details_info.ATTRIBUTE12 is null)))
	and
                ((recinfo.attribute13 = p_delivery_details_info.ATTRIBUTE13)
                or
                ((recinfo.attribute13 is null)
                and (p_delivery_details_info.ATTRIBUTE13 is null)))
	and
                ((recinfo.attribute14 = p_delivery_details_info.ATTRIBUTE14)
                or
                ((recinfo.attribute14 is null)
                and (p_delivery_details_info.ATTRIBUTE14 is null)))
	and
                ((recinfo.attribute15 = p_delivery_details_info.ATTRIBUTE15)
                or
                ((recinfo.attribute15 is null)
                and (p_delivery_details_info.ATTRIBUTE15 is null)))
	and
                ((recinfo.mvt_stat_status = p_delivery_details_info.mvt_stat_status)
                or
                ((recinfo.mvt_stat_status is null)
                and (p_delivery_details_info.mvt_stat_status is null)))

        and
                ((recinfo.organization_id = p_delivery_details_info.organization_id)
                or
                ((recinfo.organization_id is null)
                and (p_delivery_details_info.organization_id is null)))
	and
			 ((recinfo.org_id = p_delivery_details_info.org_id)
			 or
			 ((recinfo.org_id is null)
			 and (p_delivery_details_info.org_id is null)))
	and
                ((recinfo.transaction_temp_id = p_delivery_details_info.transaction_temp_id)
                or
                ((recinfo.transaction_temp_id is null)
                and (p_delivery_details_info.transaction_temp_id is null)))
	and
                ((recinfo.ship_set_id = p_delivery_details_info.ship_set_id)
                or
                ((recinfo.ship_set_id is null)
                and (p_delivery_details_info.ship_set_id is null)))
	and
                ((recinfo.arrival_set_id = p_delivery_details_info.arrival_set_id)
                or
                ((recinfo.arrival_set_id is null)
                and (p_delivery_details_info.arrival_set_id is null)))
        and
                ((recinfo.ship_model_complete_flag = p_delivery_details_info.ship_model_complete_flag)
                or
                ((recinfo.ship_model_complete_flag is null)
                and (p_delivery_details_info.ship_model_complete_flag is null)))
	and
                ((recinfo.top_model_line_id = p_delivery_details_info.top_model_line_id)
                or
                ((recinfo.top_model_line_id is null)
                and (p_delivery_details_info.top_model_line_id is null)))
	and
                ((recinfo.hold_code = p_delivery_details_info.hold_code)
                or
                ((recinfo.hold_code is null)
                and (p_delivery_details_info.hold_code is null)))
	and
                ((recinfo.source_header_number = p_delivery_details_info.source_header_number)
                or
                ((recinfo.source_header_number is null)
                and (p_delivery_details_info.source_header_number is null)))
	and
                ((recinfo.source_header_type_id = p_delivery_details_info.source_header_type_id)
                or
                ((recinfo.source_header_type_id  is null)
                and (p_delivery_details_info.source_header_type_id is null)))

	and
                ((recinfo.source_header_type_name = p_delivery_details_info.source_header_type_name)
                or
                ((recinfo.source_header_type_name is null)
                and (p_delivery_details_info.source_header_type_name is null)))
	and
                ((recinfo.cust_po_number =  p_delivery_details_info.cust_po_number)
                or
                ((recinfo.cust_po_number is null)
                and (p_delivery_details_info.cust_po_number is null)))

	and
                ((recinfo.ato_line_id = p_delivery_details_info.ato_line_id)
                or
                ((recinfo.ato_line_id is null)
                and (p_delivery_details_info.ato_line_id is null)))

	and
                ((recinfo.src_requested_quantity = p_delivery_details_info.src_requested_quantity)
                or
                ((recinfo.src_requested_quantity is null)
                and (p_delivery_details_info.src_requested_quantity is null)))
	and
                ((recinfo.src_requested_quantity_uom = p_delivery_details_info.src_requested_quantity_uom)
                or
                ((recinfo.src_requested_quantity_uom is null)
                and (p_delivery_details_info.src_requested_quantity_uom is null)))
	and
                ((recinfo.move_order_line_id = p_delivery_details_info.move_order_line_id)
                or
                ((recinfo.move_order_line_id is null)
                and (p_delivery_details_info.move_order_line_id is null)))

	and
                ((recinfo.cancelled_quantity = p_delivery_details_info.cancelled_quantity)
                or
                ((recinfo.cancelled_quantity is null)
                and (p_delivery_details_info.cancelled_quantity is null)))
	and
			((recinfo.hazard_class_id = p_delivery_details_info.hazard_class_id)
			 or
		     ((recinfo.hazard_class_id  is null)
	 	     and (p_delivery_details_info.hazard_class_id is null)))

	and
			((recinfo.quality_control_quantity = p_delivery_details_info.quality_control_quantity)
			or
			((recinfo.quality_control_quantity is null)
			and (p_delivery_details_info.quality_control_quantity is null)))
	and
			((recinfo.cycle_count_quantity = p_delivery_details_info.cycle_count_quantity)
			or
			((recinfo.cycle_count_quantity is null)
			and (p_delivery_details_info.cycle_count_quantity is null)))
	and
			((recinfo.tracking_number = p_delivery_details_info.tracking_number)
			or
			((recinfo.tracking_number is null)
			and (p_delivery_details_info.tracking_number is null)))

	and
			((recinfo.movement_id = p_delivery_details_info.movement_id)
			or
			((recinfo.movement_id is null)
			and (p_delivery_details_info.movement_id is null)))

	and
			((recinfo.shipping_instructions = p_delivery_details_info.shipping_instructions)
			or
			((recinfo.shipping_instructions is null)
			and (p_delivery_details_info.shipping_instructions is null)))

	and
			((recinfo.packing_instructions = p_delivery_details_info.packing_instructions)
			or
			((recinfo.packing_instructions is null)
			and (p_delivery_details_info.packing_instructions is null)))
	and
			((recinfo.project_id = p_delivery_details_info.project_id)
			or
			((recinfo.project_id is null)
			and (p_delivery_details_info.project_id is null)))
	and
			((recinfo.task_id = p_delivery_details_info.task_id)
			or
			((recinfo.task_id is null)
			and (p_delivery_details_info.task_id is null)))
	and
			((recinfo.oe_interfaced_flag = p_delivery_details_info.oe_interfaced_flag)
			or
			((recinfo.oe_interfaced_flag is null)
		     and (p_delivery_details_info.oe_interfaced_flag is null)))

	and
			((recinfo.split_from_delivery_detail_id = p_delivery_details_info.split_from_detail_id)
			or
       		((recinfo.split_from_delivery_detail_id is null)
			and (p_delivery_details_info.split_from_detail_id is null)))
	and
			((recinfo.inv_interfaced_flag = p_delivery_details_info.inv_interfaced_flag)
			or
			((recinfo.inv_interfaced_flag is null)
			and (p_delivery_details_info.inv_interfaced_flag is null)))

	and
			((recinfo.source_line_number = p_delivery_details_info.source_line_number)
			or
  		    ((recinfo.source_line_number is null)
			and (p_delivery_details_info.source_line_number is null)))
	and
			((recinfo.inspection_flag = p_delivery_details_info.inspection_flag)
			or
  		    ((recinfo.inspection_flag is null)
			and (p_delivery_details_info.inspection_flag is null)))
	and
			((recinfo.released_status = p_delivery_details_info.released_status)
			or
		    ((recinfo.released_status is null)
		    and (p_delivery_details_info.released_status is null)))


	and
                (recinfo.delivery_detail_id = p_delivery_details_info.DELIVERY_detail_ID)
	and		(recinfo.container_flag = p_delivery_details_info.container_flag)
	and		((recinfo.container_type_code = p_delivery_details_info.container_type_code)
			or
			((recinfo.container_type_code is null)
			and (p_delivery_details_info.container_type_code is null)))

	and		((recinfo.container_name = p_delivery_details_info.container_name)
			or
			((recinfo.container_name is null)
			and (p_delivery_details_info.container_name is null)))

	and       ((recinfo.fill_percent = p_delivery_details_info.fill_percent)
			or
			((recinfo.fill_percent is null)
			and (p_delivery_details_info.fill_percent is null)))
	and       ((recinfo.gross_weight = p_delivery_details_info.gross_weight)
			or
			((recinfo.gross_weight is null)
			and (p_delivery_details_info.gross_weight is null)))
	and       ((recinfo.master_serial_number = p_delivery_details_info.master_serial_number)
			or
			((recinfo.master_serial_number is null)
			and (p_delivery_details_info.master_serial_number is null)))
	and       ((recinfo.maximum_load_weight = p_delivery_details_info.maximum_load_weight)
			or
			((recinfo.maximum_load_weight is null)
			and (p_delivery_details_info.maximum_load_weight is null)))
	and       ((recinfo.maximum_volume = p_delivery_details_info.maximum_volume)
			or
			((recinfo.maximum_volume is null)
			and (p_delivery_details_info.maximum_volume is null)))
	and       ((recinfo.minimum_fill_percent = p_delivery_details_info.minimum_fill_percent)
			or
			((recinfo.minimum_fill_percent is null)
			and (p_delivery_details_info.minimum_fill_percent is null)))
	and       ((recinfo.seal_code = p_delivery_details_info.seal_code)
			or
			((recinfo.seal_code is null)
			and (p_delivery_details_info.seal_code is null)))
	and       ((recinfo.unit_number = p_delivery_details_info.unit_number)
			or
			((recinfo.unit_number is null)
			and (p_delivery_details_info.unit_number is null)))
	and       ((recinfo.unit_price = p_delivery_details_info.unit_price)
			or
			((recinfo.unit_price is null)
			and (p_delivery_details_info.unit_price is null)))
	and       ((recinfo.currency_code = p_delivery_details_info.currency_code)
			or
			((recinfo.currency_code is null)
			and (p_delivery_details_info.currency_code is null)))
	and       ((recinfo.freight_class_cat_id = p_delivery_details_info.freight_class_cat_id)
			or
			((recinfo.freight_class_cat_id is null)
			and (p_delivery_details_info.freight_class_cat_id is null)))
	and       ((recinfo.commodity_code_cat_id = p_delivery_details_info.commodity_code_cat_id)
			or
			((recinfo.commodity_code_cat_id is null)
			and (p_delivery_details_info.commodity_code_cat_id is null)))

	/* OPM 09/11/00 added OPM attributes */
	and
		((recinfo.preferred_grade = p_delivery_details_info.PREFERRED_GRADE)
                or
                ((recinfo.preferred_grade is null)
                 and (p_delivery_details_info.PREFERRED_GRADE is null)))
        and
		((recinfo.src_requested_quantity2 = p_delivery_details_info.SRC_REQUESTED_QUANTITY2)
                or
                ((recinfo.src_requested_quantity2 is null)
                 and (p_delivery_details_info.SRC_REQUESTED_QUANTITY2 is null)))
        and
		((recinfo.src_requested_quantity_uom2 = p_delivery_details_info.SRC_REQUESTED_QUANTITY_UOM2)
                or
                ((recinfo.src_requested_quantity_uom2 is null)
                 and (p_delivery_details_info.SRC_REQUESTED_QUANTITY_UOM2 is null)))
        and
		((recinfo.requested_quantity2 = p_delivery_details_info.REQUESTED_QUANTITY2)
                or
                ((recinfo.requested_quantity2 is null)
                 and (p_delivery_details_info.REQUESTED_QUANTITY2 is null)))
        and
		((recinfo.shipped_quantity2 = p_delivery_details_info.SHIPPED_QUANTITY2)
                or
                ((recinfo.shipped_quantity2 is null)
                 and (p_delivery_details_info.SHIPPED_QUANTITY2 is null)))
        and
		((recinfo.delivered_quantity2 = p_delivery_details_info.DELIVERED_QUANTITY2)
                or
                ((recinfo.delivered_quantity2 is null)
                 and (p_delivery_details_info.DELIVERED_QUANTITY2 is null)))
        and
		((recinfo.cancelled_quantity2 = p_delivery_details_info.CANCELLED_QUANTITY2)
                or
                ((recinfo.cancelled_quantity2 is null)
                 and (p_delivery_details_info.CANCELLED_QUANTITY2 is null)))
         and
		((recinfo.cycle_count_quantity2 = p_delivery_details_info.CYCLE_COUNT_QUANTITY2)
                or
                ((recinfo.cycle_count_quantity2 is null)
                 and (p_delivery_details_info.CYCLE_COUNT_QUANTITY2 is null)))
        and
		((recinfo.requested_quantity_uom2 = p_delivery_details_info.REQUESTED_QUANTITY_UOM2)
                or
                ((recinfo.requested_quantity_uom2 is null)
                 and (p_delivery_details_info.REQUESTED_QUANTITY_UOM2 is null)))
-- HW OPMCONV - Removed check for sublot
        and
		((recinfo.to_serial_number  = p_delivery_details_info.TO_SERIAL_NUMBER)
		      or
			 ((recinfo.to_serial_number is null)
		       and (p_delivery_details_info.TO_SERIAL_NUMBER is null)))
        and
		((recinfo.picked_quantity  = p_delivery_details_info.PICKED_QUANTITY)
		      or
			 ((recinfo.picked_quantity is null)
		       and (p_delivery_details_info.PICKED_QUANTITY is null)))
        and
		((recinfo.picked_quantity2 = p_delivery_details_info.PICKED_QUANTITY2)
		      or
			 ((recinfo.picked_quantity2 is null)
		       and (p_delivery_details_info.PICKED_QUANTITY2 is null)))
/* H Integration: datamodel changes wrudge */
        and
                ((recinfo.received_quantity = p_delivery_details_info.RECEIVED_QUANTITY)
                      or
                         (    (recinfo.received_quantity is null)
                          and (p_delivery_details_info.RECEIVED_QUANTITY is null)))

        and
                ((recinfo.received_quantity2 = p_delivery_details_info.RECEIVED_QUANTITY2)
                      or
                         (    (recinfo.received_quantity2 is null)
                          and (p_delivery_details_info.RECEIVED_QUANTITY2 is null)))
        and
                ((recinfo.source_line_set_id = p_delivery_details_info.SOURCE_LINE_SET_ID)
                      or
                         (    (recinfo.source_line_set_id is null)
                          and (p_delivery_details_info.SOURCE_LINE_SET_ID is null)))
        and
                ((recinfo.received_quantity2 = p_delivery_details_info.RECEIVED_QUANTITY2)
                      or
                         (    (recinfo.received_quantity2 is null)
                          and (p_delivery_details_info.RECEIVED_QUANTITY2 is null)))
        and
                ((recinfo.source_line_set_id = p_delivery_details_info.SOURCE_LINE_SET_ID)
                      or
                         (    (recinfo.source_line_set_id is null)
                          and (p_delivery_details_info.SOURCE_LINE_SET_ID is null)))
/*  J  Inbound Logistics: New columns jckwok */
        and
                ((recinfo.vendor_id = p_delivery_details_info.vendor_id)
                      or
                         (    (recinfo.vendor_id is null)
                          and (p_delivery_details_info.vendor_id is null)))
        and
                ((recinfo.ship_from_site_id = p_delivery_details_info.ship_from_site_id)
                      or
                         (    (recinfo.ship_from_site_id is null)
                          and (p_delivery_details_info.ship_from_site_id is null)))
        and
                ((nvl(recinfo.line_direction,'O') = nvl(p_delivery_details_info.line_direction,'O'))
                      or
                         (    (recinfo.line_direction is null)
                          and (p_delivery_details_info.line_direction is null)))
        and
                ((recinfo.party_id = p_delivery_details_info.party_id)
                      or
                         (    (recinfo.party_id is null)
                          and (p_delivery_details_info.party_id is null)))
        and
                ((recinfo.routing_req_id = p_delivery_details_info.routing_req_id)
                      or
                         (    (recinfo.routing_req_id is null)
                          and (p_delivery_details_info.routing_req_id is null)))
        and
                ((recinfo.shipping_control = p_delivery_details_info.shipping_control)
                      or
                         (    (recinfo.shipping_control is null)
                          and (p_delivery_details_info.shipping_control is null)))
        and
                ((recinfo.source_blanket_reference_id = p_delivery_details_info.source_blanket_reference_id)
                      or
                         (    (recinfo.source_blanket_reference_id is null)
                          and (p_delivery_details_info.source_blanket_reference_id is null)))
        and
                ((recinfo.source_blanket_reference_num = p_delivery_details_info.source_blanket_reference_num)
                      or
                         (    (recinfo.source_blanket_reference_num is null)
                          and (p_delivery_details_info.source_blanket_reference_num is null)))
        and
                ((recinfo.po_shipment_line_id = p_delivery_details_info.po_shipment_line_id)
                      or
                         (    (recinfo.po_shipment_line_id is null)
                          and (p_delivery_details_info.po_shipment_line_id is null)))
        and
                ((recinfo.po_shipment_line_number = p_delivery_details_info.po_shipment_line_number)
                      or
                         (    (recinfo.po_shipment_line_number is null)
                          and (p_delivery_details_info.po_shipment_line_number is null)))
        and
                ((recinfo.returned_quantity = p_delivery_details_info.returned_quantity)
                      or
                         (    (recinfo.returned_quantity is null)
                          and (p_delivery_details_info.returned_quantity is null)))
        and
                ((recinfo.returned_quantity2 = p_delivery_details_info.returned_quantity2)
                      or
                         (    (recinfo.returned_quantity2 is null)
                          and (p_delivery_details_info.returned_quantity2 is null)))
        and
                ((recinfo.rcv_shipment_line_id = p_delivery_details_info.rcv_shipment_line_id)
                      or
                         (    (recinfo.rcv_shipment_line_id is null)
                          and (p_delivery_details_info.rcv_shipment_line_id is null)))
        and
                ((recinfo.source_line_type_code = p_delivery_details_info.source_line_type_code)
                      or
                         (    (recinfo.source_line_type_code is null)
                          and (p_delivery_details_info.source_line_type_code is null)))
        and
                ((recinfo.supplier_item_number = p_delivery_details_info.supplier_item_number)
                      or
                         (    (recinfo.supplier_item_number is null)
                          and (p_delivery_details_info.supplier_item_number is null)))
/* J TP release : ttrichy*/
        and
                ((nvl(recinfo.IGNORE_FOR_PLANNING, 'N') = nvl(p_delivery_details_info.IGNORE_FOR_PLANNING, 'N')))
        and
                ((recinfo.EARLIEST_PICKUP_DATE = p_delivery_details_info.EARLIEST_PICKUP_DATE)
                      or
                         (    (recinfo.EARLIEST_PICKUP_DATE is null)
                          and (p_delivery_details_info.EARLIEST_PICKUP_DATE is null)))
        and
                ((recinfo.LATEST_PICKUP_DATE = p_delivery_details_info.LATEST_PICKUP_DATE)
                      or
                         (    (recinfo.LATEST_PICKUP_DATE is null)
                          and (p_delivery_details_info.LATEST_PICKUP_DATE is null)))
        and
                ((recinfo.EARLIEST_DROPOFF_DATE = p_delivery_details_info.EARLIEST_DROPOFF_DATE)
                      or
                         (    (recinfo.EARLIEST_DROPOFF_DATE is null)
                          and (p_delivery_details_info.EARLIEST_DROPOFF_DATE is null)))
        and
                ((recinfo.LATEST_DROPOFF_DATE = p_delivery_details_info.LATEST_DROPOFF_DATE)
                      or
                         (    (recinfo.LATEST_DROPOFF_DATE is null)
                          and (p_delivery_details_info.LATEST_DROPOFF_DATE is null)))
        and
                ((recinfo.REQUEST_DATE_TYPE_CODE = p_delivery_details_info.REQUEST_DATE_TYPE_CODE)
                      or
                         (    (recinfo.REQUEST_DATE_TYPE_CODE is null)
                          and (p_delivery_details_info.REQUEST_DATE_TYPE_CODE is null)))
        and
                ((recinfo.tp_delivery_detail_id = p_delivery_details_info.tp_delivery_detail_id)
                      or
                         (    (recinfo.tp_delivery_detail_id is null)
                          and (p_delivery_details_info.tp_delivery_detail_id is null)))
        and
                ((recinfo.source_document_type_id = p_delivery_details_info.source_document_type_id)
                      or
                         (    (recinfo.source_document_type_id is null)
                          and (p_delivery_details_info.source_document_type_id is null)))
        -- J: W/V Changes
        and
                ((recinfo.filled_volume = p_delivery_details_info.FILLED_VOLUME)
                or
                ((recinfo.filled_volume is null)
                and (p_delivery_details_info.FILLED_VOLUME is null)))
	/* --- commented as wv frozen flag is not updateable field from UI.
        and
                ((recinfo.wv_frozen_flag = p_delivery_details_info.WV_FROZEN_FLAG)
                or
                ((recinfo.wv_frozen_flag is null)
                and (p_delivery_details_info.WV_FROZEN_FLAG is null)))
	*/
-- J IB : asutar
        and
                ((recinfo.po_revision_number = p_delivery_details_info.po_revision_number)
                or
                ((recinfo.po_revision_number is null)
                and (p_delivery_details_info.po_revision_number is null)))
-- bug#6689448 ( Replenishment Project)
      and
                ((recinfo.replenishment_status = p_delivery_details_info.replenishment_status)
                or
                ((recinfo.replenishment_status is null)
                and (p_delivery_details_info.replenishment_status is null)))
      and
                ((recinfo.release_revision_number = p_delivery_details_info.release_revision_number)
                or
                ((recinfo.release_revision_number is null)
                and (p_delivery_details_info.release_revision_number is null)))
        ) THEN
		--
		IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'Nothing has changed');
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		RETURN;
	ELSE
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		app_exception.raise_exception;
  	END IF;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
	WHEN app_exception.application_exception or app_exception.record_lock_exception THEN

	      -- Is this necessary?  Does PL/SQL automatically close a
	      -- cursor when it goes out of scope?

	      if (c_lock_delivery_detail%ISOPEN) then
		  close c_lock_delivery_detail;
	      end if;

	      --
	      IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'APP_EXCEPTION.APPLICATION_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APP_EXCEPTION.APPLICATION_EXCEPTION');
	      END IF;
	      --
	      RAISE;

	WHEN others THEN

	      -- Is this necessary?  Does PL/SQL automatically close a
	      -- cursor when it goes out of scope?

	      if (c_lock_delivery_detail%ISOPEN) then
		  close c_lock_delivery_detail;
	      end if;

	      FND_MESSAGE.SET_NAME('WSH','WSH_UNEXP_ERROR');
	      FND_MESSAGE.Set_Token('PACKAGE', 'WSH_DELIVERY_DETAILS_PKG.LOCK_DELIVERY_DETAILS');
	      FND_MESSAGE.Set_Token('ORA_ERROR',sqlcode);
	      FND_MESSAGE.Set_Token('ORA_TEXT',sqlerrm);

	      --
	      IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	      END IF;
	      --
	      RAISE;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END Lock_Delivery_Details;


--
--  Procedure:   Update_Delivery_Line
--  Parameters:  All Attributes of a Delivery Line Record
--  Description: This procedure will update attributes of
--               a delivery line.
--

PROCEDURE Update_Delivery_Details(
	p_rowid               IN   VARCHAR2 := NULL,
	p_delivery_details_info   IN   WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
  	x_return_status       OUT NOCOPY   VARCHAR2
) IS

-- J: W/V Changes
CURSOR get_dd_info IS
SELECT rowid,
       gross_weight,
       net_weight,
       volume,
       filled_volume,
       fill_percent,
       unit_weight,
       unit_volume,
       container_flag,
       NVL(wv_frozen_flag,'Y'),
       weight_uom_code,
       volume_uom_code,
       inventory_item_id,
--lpn conv
       locator_id,
       subinventory,
       container_name,
       requested_quantity,  -- OTM R12
       shipped_quantity,     -- OTM R12
       -- bug# 6719369 (replenishment project):
       released_status,
       replenishment_status
FROM   wsh_delivery_details
WHERE  delivery_detail_id = p_delivery_details_info.delivery_detail_id;

-- OTM R12 : packing ECO
CURSOR c_get_delivery_info(p_delivery_detail_id IN NUMBER) IS
SELECT wda.delivery_id
  FROM wsh_delivery_assignments wda,
       wsh_new_deliveries wnd
 WHERE wda.delivery_detail_id = p_delivery_detail_id
   AND wda.delivery_id = wnd.delivery_id
   AND wnd.tms_interface_flag IN
       (WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS,
        WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS,
        WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
        WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED)
   AND NVL(wnd.ignore_for_planning, 'N') = 'N';

-- bug # 6749200 (replenishment project) : back order consolidation for dynamic replenishment case.
CURSOR get_bo_dd_info IS
SELECT wdd.source_line_id,
       wdd.requested_quantity,
       wdd.requested_quantity2,
       wda.delivery_id
FROM   wsh_delivery_details wdd,
       wsh_delivery_assignments wda
WHERE  wdd.delivery_detail_id = p_delivery_details_info.delivery_detail_id
AND    wdd.delivery_detail_id = wda.delivery_detail_id;

l_cons_source_line_rec_tab  WSH_DELIVERY_DETAILS_ACTIONS.Cons_Source_Line_Rec_Tab;
l_cons_dd_ids		    WSH_UTIL_CORE.Id_Tab_Type ; --Stores the dd_ids returned by Consolidate_Source_Line
l_back_order_consolidation  VARCHAR2(1) := 'N';
l_req                       NUMBER;
l_req2                      NUMBER;
l_line_id                   NUMBER;
l_del_id                    NUMBER;
l_global_param_rec	    WSH_SHIPPING_PARAMS_PVT.Global_Parameters_Rec_Typ;
-- 6749200 (replenishment project) : end

l_delivery_id            WSH_NEW_DELIVERIES.DELIVERY_ID%TYPE;
l_requested_quantity     WSH_DELIVERY_DETAILS.REQUESTED_QUANTITY%TYPE;
l_shipped_quantity       WSH_DELIVERY_DETAILS.SHIPPED_QUANTITY%TYPE;
l_delivery_id_tab        WSH_UTIL_CORE.ID_TAB_TYPE;
l_interface_flag_tab     WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_gc3_is_installed       VARCHAR2(1);
-- End of OTM R12

l_rowid VARCHAR2(30);
others exception;

l_gross_wt            NUMBER;
l_net_wt              NUMBER;
l_volume              NUMBER;
l_filled_volume       NUMBER;
l_fill_percent        NUMBER;
l_unit_weight         NUMBER;
l_unit_volume         NUMBER;
l_container_flag      VARCHAR2(1);
l_frozen_flag         VARCHAR2(1);
l_return_status       VARCHAR2(1);
l_tmp_gross_wt        NUMBER;
l_tmp_vol             NUMBER;
l_tmp_vol_uom_code    VARCHAR2(30);
l_tmp_wt_uom_code     VARCHAR2(30);
l_new_gross_weight    NUMBER;
l_new_net_weight      NUMBER;
l_new_volume          NUMBER;
l_item_id             NUMBER;
l_locator_id          NUMBER;
l_subinventory        VARCHAR2(20);
l_container_name      VARCHAR2(50);
l_param_info          WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
e_wt_vol_fail         EXCEPTION;

l_detail_tab          WSH_UTIL_CORE.id_tab_type; -- DBI changes
l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API
l_num_errors          NUMBER := 0;
l_num_warnings        NUMBER := 0;
l_wms_installed       VARCHAR2(10);
l_org_type            VARCHAR2(3) := 'INV';
l_call_out            BOOLEAN := FALSE;
l_CALL_BACK_REQUIRED  VARCHAR2(2) := 'N';
l_sync_tmp_rec        wsh_glbl_var_strct_grp.sync_tmp_rec_type;
l_cont_fill_pc        NUMBER;

CURSOR Get_Cont_Item_Info (v_cont_item_id NUMBER, v_org_id NUMBER) IS
  SELECT Description,
  Container_Type_Code,
  minimum_fill_percent,
  maximum_load_weight,
  internal_volume,
  unit_weight,
  unit_volume,
  weight_uom_code,
  volume_uom_code
  FROM MTL_SYSTEM_ITEMS
  WHERE inventory_item_id = v_cont_item_id
  AND container_item_flag = 'Y'
  AND organization_id = v_org_id
  AND    nvl(vehicle_item_flag,'N') = 'N';
  --AND    shippable_item_flag = 'Y';

  l_item_description   MTL_SYSTEM_ITEMS.Description%TYPE;
  l_container_type_code MTL_SYSTEM_ITEMS.Container_Type_Code%TYPE;
  l_minimum_fill_percent MTL_SYSTEM_ITEMS.minimum_fill_percent%TYPE;
  l_maximum_load_weight MTL_SYSTEM_ITEMS.maximum_load_weight%TYPE;
  l_maximum_volume MTL_SYSTEM_ITEMS.internal_volume%TYPE;
  l_unit_weight_item MTL_SYSTEM_ITEMS.unit_weight%TYPE;
  l_unit_volume_item MTL_SYSTEM_ITEMS.unit_volume%TYPE;
  l_weight_uom_code_item MTL_SYSTEM_ITEMS.weight_uom_code%TYPE;
  l_volume_uom_code_item MTL_SYSTEM_ITEMS.volume_uom_code%TYPE;

  -- bug# 6719369 (replenishment project): begin
  l_event VARCHAR2(600):= null;
  l_dd_released_status VARCHAR2(1);
  l_wf_rs        VARCHAR2(1);
  l_replenishment_status VARCHAR2(1);
  -- bug# 6719369 (replenishment project): end

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_DELIVERY_DETAILS';
--
BEGIN
	--
	--
        SAVEPOINT s_before_update_dd;
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
	    WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;
        IF l_gc3_is_installed IS NULL THEN
           l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
        END IF;
        IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'l_gc3_is_installed ',
                                          l_gc3_is_installed);
        END IF;

        l_item_description := p_delivery_details_info.item_description;
        l_container_type_code := p_delivery_details_info.container_type_code;
        l_minimum_fill_percent := p_delivery_details_info.minimum_fill_percent;
        l_maximum_load_weight := p_delivery_details_info.maximum_load_weight;
        l_maximum_volume := p_delivery_details_info.maximum_volume;
        l_unit_weight_item := p_delivery_details_info.unit_weight;
        l_unit_volume_item := p_delivery_details_info.unit_volume;

        -- J: W/V Changes
        OPEN  get_dd_info;
        FETCH get_dd_info INTO l_rowid, l_gross_wt, l_net_wt, l_volume,
                 l_filled_volume, l_fill_percent, l_unit_weight, l_unit_volume
                 ,l_container_flag, l_frozen_flag, l_tmp_wt_uom_code
                 , l_tmp_vol_uom_code, l_item_id , l_locator_id
                 , l_subinventory, l_container_name
                 , l_requested_quantity, l_shipped_quantity,l_dd_released_status,l_replenishment_status; -- OTM R12
        IF get_dd_info%NOTFOUND THEN
          CLOSE get_dd_info;
          RAISE no_data_found;
        END IF;
        CLOSE get_dd_info;
        IF p_rowid IS NOT NULL THEN
          l_rowid := p_rowid;
        END IF;

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'l_rowid'||l_rowid||' Cont Flag '||l_container_flag||' Org Gross '||l_gross_wt||' Org Net '||l_net_wt||' Org Vol '||l_volume||' frozen '||l_frozen_flag||' U Wt '||l_unit_weight||' U Vol '||l_unit_volume);
           WSH_DEBUG_SV.log(l_module_name,'locator_id',l_locator_id);
           WSH_DEBUG_SV.log(l_module_name,'l_subinventory',l_subinventory);
           WSH_DEBUG_SV.log(l_module_name,'l_container_name',l_container_name);
           WSH_DEBUG_SV.log(l_module_name,'l_item_id',l_item_id);
           WSH_DEBUG_SV.log(l_module_name,'passed item_id',
                                    p_delivery_details_info.inventory_item_id);
           WSH_DEBUG_SV.log(l_module_name,'l_requested_quantity',l_requested_quantity);  -- OTM R12
           WSH_DEBUG_SV.log(l_module_name,'l_shipped_quantity',l_shipped_quantity);      -- OTM R12
	   WSH_DEBUG_SV.logmsg(l_module_name,'released_status: '||l_dd_released_status||' replenishment_status: '||l_replenishment_status);
        END IF;

	-- bug# 6719369 (replenishment project) : raise the business events for the replenishment requested and replenishment completed.
	IF ( p_delivery_details_info.released_status = l_dd_released_status
	     and p_delivery_details_info.replenishment_status IS NOT NULL and l_dd_released_status in ('R','B') ) THEN
	--{
	    IF (  NVL(l_replenishment_status,'R') = 'R' and p_delivery_details_info.replenishment_status = 'C' ) THEN
	    --{
	        l_event := 'oracle.apps.wsh.line.gen.replenishmentcompleted';
	    ELSIF (  l_replenishment_status IS NULL and p_delivery_details_info.replenishment_status = 'R' ) THEN
	        l_event := 'oracle.apps.wsh.line.gen.replenishmentrequested';
	    --}
            END IF;
   	--}
	END IF;
	--
	-- bug# 6719369 (replenishment project) : end

        -- bug # 6749200 (replenishment project) : back order consolidation for dynamic replenishment case.
	IF ( p_delivery_details_info.released_status = l_dd_released_status
	     and p_delivery_details_info.replenishment_status IS NULL and l_dd_released_status = 'B'
	     and l_replenishment_status IS NOT NULL) THEN
	--{
	    l_back_order_consolidation := 'Y';
   	--}
	END IF;
	--
	-- bug# 6719369 (replenishment project) : end

        --lpn conv
        IF l_container_flag IN ('Y', 'C') THEN --{
            l_wms_installed :=
                       wsh_util_validate.Check_Wms_Org(p_delivery_details_info.organization_id);

            IF l_wms_installed = 'Y' THEN --{
              l_org_type := 'WMS';
              l_frozen_flag := 'N';
              --
              IF NVL(l_item_id,-1) <> p_delivery_details_info.inventory_item_id
              THEN --{
                -- If the item id is updated then calculate some wt/vol
                -- related fields
                OPEN Get_Cont_Item_Info(p_delivery_details_info.inventory_item_id , p_delivery_details_info.organization_id);
                FETCH Get_Cont_Item_Info INTO
                   l_item_description,
                   l_container_type_code,
                   l_minimum_fill_percent,
                   l_maximum_load_weight,
                   l_maximum_volume,
                   l_unit_weight_item,
                   l_unit_volume_item,
                   l_weight_uom_code_item ,
                   l_volume_uom_code_item ;

                IF Get_Cont_Item_Info%FOUND THEN --{
                  --
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_item_description',
                                                          l_item_description);
                     WSH_DEBUG_SV.log(l_module_name,'l_container_type_code',
                                                       l_container_type_code);
                     WSH_DEBUG_SV.log(l_module_name,'l_minimum_fill_percent',
                                                      l_minimum_fill_percent);
                     WSH_DEBUG_SV.log(l_module_name,'l_maximum_load_weight',
                                                       l_maximum_load_weight);
                     WSH_DEBUG_SV.log(l_module_name,'l_maximum_volume',
                                                            l_maximum_volume);
                     WSH_DEBUG_SV.log(l_module_name,'l_unit_weight_item',
                                                   l_unit_weight_item);
                     WSH_DEBUG_SV.log(l_module_name,'l_unit_volume_item',
                                                           l_unit_volume_item);
                     WSH_DEBUG_SV.log(l_module_name,'l_weight_uom_code_item',
                                                        l_weight_uom_code_item);
                     WSH_DEBUG_SV.log(l_module_name,'l_volume_uom_code_item',
                                                        l_volume_uom_code_item);
                  END IF;

                  IF l_weight_uom_code_item <> l_tmp_wt_uom_code THEN --{
                     l_maximum_load_weight :=
                        WSH_WV_UTILS.Convert_Uom_core (
                                   from_uom => l_weight_uom_code_item,
                                   to_uom => l_tmp_wt_uom_code,
                                   quantity => l_maximum_load_weight,
                                   item_id => p_delivery_details_info.inventory_item_id,
                                   x_return_status => l_return_status
                               );
                     wsh_util_core.api_post_call
                     (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                     );


                     IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'maximum_load_weight',
                                                          l_maximum_load_weight);
                     END IF;

                     l_unit_weight_item :=
                        WSH_WV_UTILS.Convert_Uom_core (
                                      from_uom => l_weight_uom_code_item,
                                      to_uom => l_tmp_wt_uom_code,
                                      quantity => l_unit_weight_item,
                                      item_id => p_delivery_details_info.inventory_item_id,
                                      x_return_status => l_return_status
                                  );
                     wsh_util_core.api_post_call
                     (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                     );

                     IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'unit_weight',
                                                            l_unit_weight_item);
                     END IF;
                  END IF; --}
                  IF l_volume_uom_code_item <> l_tmp_vol_uom_code THEN --{

                     l_unit_volume_item :=
                        WSH_WV_UTILS.Convert_Uom_core (
                                   from_uom => l_volume_uom_code_item,
                                   to_uom => l_tmp_vol_uom_code,
                                   quantity => l_unit_volume_item,
                                   item_id => p_delivery_details_info.inventory_item_id,
                                   x_return_status => l_return_status
                               );
                     wsh_util_core.api_post_call
                     (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                     );

                     IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'unit_volume',
                                                        l_unit_volume_item);
                     END IF;

                     l_maximum_volume :=
                        WSH_WV_UTILS.Convert_Uom_core (
                                   from_uom => l_volume_uom_code_item,
                                   to_uom => l_tmp_vol_uom_code,
                                   quantity => l_maximum_volume,
                                   item_id => p_delivery_details_info.inventory_item_id,
                                   x_return_status => l_return_status
                               );
                     wsh_util_core.api_post_call
                     (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                     );

                     IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'maximum_volume',
                                                           l_maximum_volume);
                     END IF;

                  END IF; --}
                  --
                END IF; --}

                CLOSE Get_Cont_Item_Info;

              END IF; --}
              --
            ELSE  --}{
              l_org_type := 'INV';
            END IF;
        END IF; --}

        -- If W/V changes on container then set wv_frozen_flag to Y
        IF l_container_flag IN ('Y', 'C') AND l_frozen_flag = 'N' THEN

           IF l_tmp_wt_uom_code <> p_delivery_details_info.weight_uom_code THEN

              l_gross_wt := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_tmp_wt_uom_code,
                                           to_uom   => p_delivery_details_info.weight_uom_code,
                                           quantity => l_gross_wt,
                                           item_id  => p_delivery_details_info.inventory_item_id);

              l_net_wt := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_tmp_wt_uom_code,
                                           to_uom   => p_delivery_details_info.weight_uom_code,
                                           quantity => l_net_wt,
                                           item_id  => p_delivery_details_info.inventory_item_id);

           END IF;

           IF l_tmp_vol_uom_code <> p_delivery_details_info.volume_uom_code THEN

              l_volume   := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_tmp_vol_uom_code,
                                           to_uom   => p_delivery_details_info.volume_uom_code,
                                           quantity => l_volume,
                                           item_id  => p_delivery_details_info.inventory_item_id);

           END IF;


           IF ((NVL(l_gross_wt,-99) <> NVL(p_delivery_details_info.gross_weight,-99)) OR
              (NVL(l_net_wt,-99) <> NVL(p_delivery_details_info.net_weight,-99)) OR
              (NVL(l_filled_volume,-99) <> NVL(p_delivery_details_info.filled_volume,-99)) OR
              (NVL(l_fill_percent,-99) <> NVL(p_delivery_details_info.fill_percent,-99)) OR
              (NVL(l_volume,-99) <> NVL(p_delivery_details_info.volume,-99))) THEN

              --lpn conv
              IF l_org_type = 'INV' THEN
                 l_frozen_flag := 'Y';
              ELSE
                 l_frozen_flag := 'N';
              END IF;

           END IF;
           -- lpn conv
           IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y' THEN --{

              l_CALL_BACK_REQUIRED := WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED;

              IF (l_org_type = 'WMS' AND WSH_WMS_LPN_GRP.GK_WMS_UPD_WV)
               OR(l_org_type = 'INV' AND WSH_WMS_LPN_GRP.GK_INV_UPD_WV)
              THEN --{
                 IF ((NVL(l_gross_wt,-99)
                         <> NVL(p_delivery_details_info.gross_weight,-99))
                   OR
                    (NVL(l_net_wt,-99)
                            <> NVL(p_delivery_details_info.net_weight,-99))
                   OR
                    (NVL(l_volume,-99) <>
                                   NVL(p_delivery_details_info.volume,-99))
                   OR
                    (NVL(l_tmp_wt_uom_code,-99)
                         <> NVL(p_delivery_details_info.weight_uom_code,-99))
                   OR
                    (NVL(l_tmp_vol_uom_code,-99)
                         <> NVL(p_delivery_details_info.volume_uom_code,-99))
                   OR
                    (NVL(l_filled_volume,-99)
                         <> NVL(p_delivery_details_info.filled_volume,-99)))
                 THEN --{

                    l_call_out  := TRUE;
                    WSH_WMS_LPN_GRP.g_update_to_containers := 'Y';

                 END IF; --}
              ELSIF (l_org_type = 'WMS' AND WSH_WMS_LPN_GRP.GK_WMS_UPD_KEY)
               OR(l_org_type = 'INV' AND WSH_WMS_LPN_GRP.GK_INV_UPD_KEY)
              THEN --}{
                 --
                 IF (NVL(l_container_name,-99)
                         <> NVL(p_delivery_details_info.container_name,-99))
                 THEN
                    l_call_out  := TRUE;
                 END IF;
                 --
              END IF; --}
           END IF; --}
           --
        END IF;

        -- For non-containers, if the new W/V is same as qty * unit W/V then reset the wv_frozen_flag to N. Else set it to Y
        IF l_container_flag = 'N' AND (l_unit_weight is NOT NULL OR l_unit_volume is NOT NULL) THEN
          l_tmp_gross_wt := nvl(nvl(p_delivery_details_info.received_quantity, nvl(p_delivery_details_info.shipped_quantity,
                            NVL(p_delivery_details_info.picked_quantity, p_delivery_details_info.requested_quantity)))
                            * l_unit_weight,-99);
          l_tmp_vol := nvl(nvl(p_delivery_details_info.received_quantity, nvl(p_delivery_details_info.shipped_quantity, NVL(p_delivery_details_info.picked_quantity, p_delivery_details_info.requested_quantity))) * l_unit_volume,-99);

          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_tmp_gross_wt '||l_tmp_gross_wt||' l_tmp_vol '||l_tmp_vol||' New gross '||
                              nvl(p_delivery_details_info.gross_weight,-99)||' New Net '||nvl(p_delivery_details_info.net_weight,-99)||
                              ' New Vol '||nvl(p_delivery_details_info.volume,-99));
          END IF;

          IF l_tmp_wt_uom_code <> p_delivery_details_info.weight_uom_code THEN

              l_tmp_gross_wt := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_tmp_wt_uom_code,
                                           to_uom   => p_delivery_details_info.weight_uom_code,
                                           quantity => l_tmp_gross_wt,
                                           item_id  => p_delivery_details_info.inventory_item_id);
          END IF;

          IF l_tmp_vol_uom_code <> p_delivery_details_info.volume_uom_code THEN

              l_tmp_vol   := WSH_WV_UTILS.Convert_Uom(
                                           from_uom => l_tmp_vol_uom_code,
                                           to_uom   => p_delivery_details_info.volume_uom_code,
                                           quantity => l_tmp_vol,
                                           item_id  => p_delivery_details_info.inventory_item_id);

          END IF;

          IF l_tmp_gross_wt <> nvl(p_delivery_details_info.gross_weight,-99) OR
             l_tmp_gross_wt <> nvl(p_delivery_details_info.net_weight,-99) OR
             l_tmp_vol <> nvl(p_delivery_details_info.volume,-99) THEN

            l_frozen_flag := 'Y';
          ELSE
            l_frozen_flag := 'N';
          END IF;
          -- Added ELSIF condition for bug 4509105
        ELSIF (l_container_flag = 'N' and ( nvl(l_gross_wt, -99) <> nvl(p_delivery_details_info.gross_weight,-99) OR
                nvl(l_net_wt, -99)   <> nvl(p_delivery_details_info.net_weight,-99) OR
                nvl(l_volume, -99)   <> nvl(p_delivery_details_info.volume,-99) ) )
        THEN
           l_frozen_flag := 'Y';
        END IF;

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_frozen_flag '||l_frozen_flag);
        END IF;

        -- lpn conv bmso dependency
        IF l_call_out THEN
           l_sync_tmp_rec.delivery_detail_id :=
                                 p_delivery_details_info.delivery_detail_id;
           l_sync_tmp_rec.operation_type :=  'UPDATE';
           WSH_WMS_SYNC_TMP_PKG.MERGE(
                       p_sync_tmp_rec      => l_sync_tmp_rec,
                       x_return_status     => l_return_status
           );

           wsh_util_core.api_post_call
           (
             p_return_status => l_return_status,
             x_num_warnings  => l_num_warnings,
             x_num_errors    => l_num_errors
           );

        END IF;

	UPDATE wsh_delivery_details
	SET
		delivery_detail_id	= p_delivery_details_info.delivery_detail_id,
	        unit_weight	=  l_unit_weight_item,
	        unit_volume	=  l_unit_volume_item,
		source_code		= p_delivery_details_info.source_code,
		source_header_id	= p_delivery_details_info.source_header_id,
		source_line_id		= p_delivery_details_info.source_line_id,
		customer_id		= p_delivery_details_info.customer_id,
		sold_to_contact_id		= p_delivery_details_info.sold_to_contact_id,
		inventory_item_id		= p_delivery_details_info.inventory_item_id,
		item_description		= l_item_description,
		country_of_origin		= p_delivery_details_info.country_of_origin,
		classification		= p_delivery_details_info.classification,
		ship_from_location_id		= p_delivery_details_info.ship_from_location_id,
		ship_to_location_id		= p_delivery_details_info.ship_to_location_id,
		ship_to_contact_id		= p_delivery_details_info.ship_to_contact_id,
		deliver_to_location_id		= p_delivery_details_info.deliver_to_location_id,
		deliver_to_contact_id		= p_delivery_details_info.deliver_to_contact_id,
		intmed_ship_to_location_id		= p_delivery_details_info.intmed_ship_to_location_id,
		intmed_ship_to_contact_id		= p_delivery_details_info.intmed_ship_to_contact_id,
		ship_tolerance_above		= p_delivery_details_info.ship_tolerance_above,
		ship_tolerance_below		= p_delivery_details_info.ship_tolerance_below,
		requested_quantity		= p_delivery_details_info.requested_quantity,
		shipped_quantity		= p_delivery_details_info.shipped_quantity,
		delivered_quantity		= p_delivery_details_info.delivered_quantity,
		requested_quantity_uom		= p_delivery_details_info.requested_quantity_uom,
		subinventory		= p_delivery_details_info.subinventory,
		revision		= p_delivery_details_info.revision,
		lot_number		= p_delivery_details_info.lot_number,
		customer_requested_lot_flag		= p_delivery_details_info.customer_requested_lot_flag,
		serial_number		= p_delivery_details_info.serial_number,
		locator_id		= p_delivery_details_info.locator_id,
		date_requested		= p_delivery_details_info.date_requested,
		date_scheduled		= p_delivery_details_info.date_scheduled,
		master_container_item_id		= p_delivery_details_info.master_container_item_id,
		detail_container_item_id		= p_delivery_details_info.detail_container_item_id,
		load_seq_number		= p_delivery_details_info.load_seq_number,
		ship_method_code		= p_delivery_details_info.ship_method_code,
		carrier_id		= p_delivery_details_info.carrier_id,
		freight_terms_code		= p_delivery_details_info.freight_terms_code,
		shipment_priority_code		= p_delivery_details_info.shipment_priority_code,
		fob_code		= p_delivery_details_info.fob_code,
		customer_item_id		= p_delivery_details_info.customer_item_id,
		dep_plan_required_flag		= p_delivery_details_info.dep_plan_required_flag,
		customer_prod_seq		= p_delivery_details_info.customer_prod_seq,
		customer_dock_code		= p_delivery_details_info.customer_dock_code,
		cust_model_serial_number	= p_delivery_details_info.cust_model_serial_number,
		customer_job         		= p_delivery_details_info.customer_job,
		customer_production_line	= p_delivery_details_info.customer_production_line,
		net_weight		= p_delivery_details_info.net_weight,
		weight_uom_code		= p_delivery_details_info.weight_uom_code,
		volume		= p_delivery_details_info.volume,
		volume_uom_code		= p_delivery_details_info.volume_uom_code,
                -- J: W/V Changes
                filled_volume            = p_delivery_details_info.filled_volume,
		tp_attribute_category		= p_delivery_details_info.tp_attribute_category,
		tp_attribute1		= p_delivery_details_info.tp_attribute1,
		tp_attribute2		= p_delivery_details_info.tp_attribute2,
		tp_attribute3		= p_delivery_details_info.tp_attribute3,
		tp_attribute4		= p_delivery_details_info.tp_attribute4,
		tp_attribute5		= p_delivery_details_info.tp_attribute5,
		tp_attribute6		= p_delivery_details_info.tp_attribute6,
		tp_attribute7		= p_delivery_details_info.tp_attribute7,
		tp_attribute8		= p_delivery_details_info.tp_attribute8,
		tp_attribute9		= p_delivery_details_info.tp_attribute9,
		tp_attribute10		= p_delivery_details_info.tp_attribute10,
		tp_attribute11		= p_delivery_details_info.tp_attribute11,
		tp_attribute12		= p_delivery_details_info.tp_attribute12,
		tp_attribute13		= p_delivery_details_info.tp_attribute13,
		tp_attribute14		= p_delivery_details_info.tp_attribute14,
		tp_attribute15		= p_delivery_details_info.tp_attribute15,
		attribute_category		= p_delivery_details_info.attribute_category,
		attribute1		= p_delivery_details_info.attribute1,
		attribute2		= p_delivery_details_info.attribute2,
		attribute3		= p_delivery_details_info.attribute3,
		attribute4		= p_delivery_details_info.attribute4,
		attribute5		= p_delivery_details_info.attribute5,
		attribute6		= p_delivery_details_info.attribute6,
		attribute7		= p_delivery_details_info.attribute7,
		attribute8		= p_delivery_details_info.attribute8,
		attribute9		= p_delivery_details_info.attribute9,
		attribute10		= p_delivery_details_info.attribute10,
		attribute11		= p_delivery_details_info.attribute11,
		attribute12		= p_delivery_details_info.attribute12,
		attribute13		= p_delivery_details_info.attribute13,
		attribute14		= p_delivery_details_info.attribute14,
		attribute15		= p_delivery_details_info.attribute15,
		last_update_date		= p_delivery_details_info.last_update_date,
		last_updated_by		= p_delivery_details_info.last_updated_by,
		last_update_login		= p_delivery_details_info.last_update_login,
		program_application_id		= p_delivery_details_info.program_application_id,
		program_id		= p_delivery_details_info.program_id,
		program_update_date		= p_delivery_details_info.program_update_date,
		request_id		= p_delivery_details_info.request_id,
		mvt_stat_status		= p_delivery_details_info.mvt_stat_status,
		organization_id		= p_delivery_details_info.organization_id,
		transaction_temp_id		= p_delivery_details_info.transaction_temp_id,
		ship_set_id		= p_delivery_details_info.ship_set_id,
		arrival_set_id		= p_delivery_details_info.arrival_set_id,
		ship_model_complete_flag		= p_delivery_details_info.ship_model_complete_flag,
		top_model_line_id		= p_delivery_details_info.top_model_line_id,
		hold_code		= p_delivery_details_info.hold_code,
		source_header_number		= p_delivery_details_info.source_header_number,
		source_header_type_id		= p_delivery_details_info.source_header_type_id,
		source_header_type_name		= p_delivery_details_info.source_header_type_name,
		cust_po_number		= p_delivery_details_info.cust_po_number,
		ato_line_id		= p_delivery_details_info.ato_line_id,
		src_requested_quantity		= p_delivery_details_info.src_requested_quantity,
		src_requested_quantity_uom		= p_delivery_details_info.src_requested_quantity_uom,
		move_order_line_id		= p_delivery_details_info.move_order_line_id,
		cancelled_quantity		= p_delivery_details_info.cancelled_quantity,
		hazard_class_id		= p_delivery_details_info.hazard_class_id,
		quality_control_quantity		= p_delivery_details_info.quality_control_quantity,
		cycle_count_quantity		= p_delivery_details_info.cycle_count_quantity,
		tracking_number		= p_delivery_details_info.tracking_number,
		movement_id		= p_delivery_details_info.movement_id,
		shipping_instructions		= p_delivery_details_info.shipping_instructions,
		packing_instructions		= p_delivery_details_info.packing_instructions,
		project_id		= p_delivery_details_info.project_id,
		task_id		= p_delivery_details_info.task_id,
		org_id		= p_delivery_details_info.org_id,
		oe_interfaced_flag		= p_delivery_details_info.oe_interfaced_flag,
		split_from_delivery_detail_id		= p_delivery_details_info.split_from_detail_id,
		inv_interfaced_flag		= p_delivery_details_info.inv_interfaced_flag,
		source_line_number		= p_delivery_details_info.source_line_number,
		inspection_flag          = p_delivery_details_info.inspection_flag,
		released_status		= p_delivery_details_info.released_status,
		container_flag			= p_delivery_details_info.container_flag,
		container_type_code		= l_container_type_code,
		container_name			= p_delivery_details_info.container_name,
		fill_percent			= p_delivery_details_info.fill_percent,
		gross_weight			= p_delivery_details_info.gross_weight,
		master_serial_number	= p_delivery_details_info.master_serial_number,
		maximum_load_weight		= l_maximum_load_weight,
		maximum_volume			= l_maximum_volume,
		minimum_fill_percent	= l_minimum_fill_percent,
		seal_code				= p_delivery_details_info.seal_code,
		unit_number			= p_delivery_details_info.unit_number,
		unit_price			= p_delivery_details_info.unit_price,
		currency_code			= p_delivery_details_info.currency_code,
		freight_class_cat_id = p_delivery_details_info.freight_class_cat_id,
		commodity_code_cat_id = p_delivery_details_info.commodity_code_cat_id,
          preferred_grade             = p_delivery_details_info.preferred_grade, /* OPM 09/11/000 start */
          src_requested_quantity2     = p_delivery_details_info.src_requested_quantity2,
          src_requested_quantity_uom2 = p_delivery_details_info.src_requested_quantity_uom2,
          requested_quantity2         = p_delivery_details_info.requested_quantity2,
          shipped_quantity2           = p_delivery_details_info.shipped_quantity2,
          delivered_quantity2         = p_delivery_details_info.delivered_quantity2,
          cancelled_quantity2         = p_delivery_details_info.cancelled_quantity2,
          quality_control_quantity2   = p_delivery_details_info.quality_control_quantity2,
          cycle_count_quantity2       = p_delivery_details_info.cycle_count_quantity2,
          requested_quantity_uom2     = p_delivery_details_info.requested_quantity_uom2,
-- HW OPMCONV - No need for sublot_number
--        sublot_number               =  p_delivery_details_info.sublot_number,
		/* OPM 09/11/00 end */
          to_serial_number            =  p_delivery_details_info.to_serial_number,
          picked_quantity             = p_delivery_details_info.picked_quantity,
          picked_quantity2            = p_delivery_details_info.picked_quantity2,
/* H Integration: datamodel changes wrudge */
          received_quantity           = p_delivery_details_info.received_quantity,
          received_quantity2          = p_delivery_details_info.received_quantity2,
          source_line_set_id          = p_delivery_details_info.source_line_set_id,
          lpn_id                      = p_delivery_details_info.lpn_id,
/*  J  Inbound Logistics: New columns jckwok */
        vendor_id                     = p_delivery_details_info.vendor_id  ,
        ship_from_site_id             = p_delivery_details_info.ship_from_site_id  ,
        line_direction                = nvl(p_delivery_details_info.line_direction, 'O')  ,
        party_id                      = p_delivery_details_info.party_id   ,
        routing_req_id                = p_delivery_details_info.routing_req_id  ,
        shipping_control              = p_delivery_details_info.shipping_control  ,
        source_blanket_reference_id   = p_delivery_details_info.source_blanket_reference_id  ,
        source_blanket_reference_num = p_delivery_details_info.source_blanket_reference_num,
        po_shipment_line_id           = p_delivery_details_info.po_shipment_line_id  ,
        po_shipment_line_number       = p_delivery_details_info.po_shipment_line_number  ,
        returned_quantity             = p_delivery_details_info.returned_quantity  ,
        returned_quantity2            = p_delivery_details_info.returned_quantity2  ,
        rcv_shipment_line_id          = p_delivery_details_info.rcv_shipment_line_id  ,
        source_line_type_code         = p_delivery_details_info.source_line_type_code  ,
        supplier_item_number          = p_delivery_details_info.supplier_item_number  ,
/* J TP release : ttrichy*/
        IGNORE_FOR_PLANNING           = nvl(p_delivery_details_info.IGNORE_FOR_PLANNING,'N'),
        EARLIEST_PICKUP_DATE          = p_delivery_details_info.EARLIEST_PICKUP_DATE  ,
        LATEST_PICKUP_DATE            = p_delivery_details_info.LATEST_PICKUP_DATE  ,
        EARLIEST_DROPOFF_DATE         = p_delivery_details_info.EARLIEST_DROPOFF_DATE  ,
        LATEST_DROPOFF_DATE           = p_delivery_details_info.LATEST_DROPOFF_DATE  ,
        --DEMAND_SATISFACTION_DATE      = p_delivery_details_info.DEMAND_SATISFACTION_DATE  , --confirm name for this
        REQUEST_DATE_TYPE_CODE        = p_delivery_details_info.REQUEST_DATE_TYPE_CODE  ,
        tp_delivery_detail_id         = p_delivery_details_info.tp_delivery_detail_id,
        source_document_type_id       = p_delivery_details_info.source_document_type_id,
/*J: W/V Changes */
        wv_frozen_flag                = decode(l_frozen_flag,NULL,wv_frozen_flag,l_frozen_flag),
        service_level                =  p_delivery_details_info.service_level,
        mode_of_transport                = p_delivery_details_info.mode_of_transport,
/* J IB: asutar*/
        po_revision_number            = p_delivery_details_info.po_revision_number,
        release_revision_number       = p_delivery_details_info.release_revision_number,
        batch_id                      = p_delivery_details_info.batch_id, --X-dock
        replenishment_status          = p_delivery_details_info.replenishment_status --bug# 6689448 (replenishment project)
        WHERE rowid = l_rowid;

	IF (SQL%NOTFOUND) THEN
		RAISE NO_DATA_FOUND;
	ELSE
		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 	END IF;
        --
        --
        -- DBI Project
        -- Update of wsh_delivery_details where requested_quantity/released_status
        -- are changed, call DBI API after the update.
        -- DBI API checks for DBI Installed also
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',p_delivery_details_info.delivery_detail_id);
        END IF;
        l_detail_tab(1) := p_delivery_details_info.delivery_detail_id;
        WSH_INTEGRATION.DBI_Update_Detail_Log
          (p_delivery_detail_id_tab => l_detail_tab,
           p_dml_type               => 'UPDATE',
           x_return_status          => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        -- DBI API can only raise unexpected error, in that case need to
        -- pass it to the caller API for roll back of the whole transaction
        -- Only need to handle Unexpected error, rest are treated as success
        -- Since code is not proceeding, no need to reset x_return_status
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_dbi_rs;
          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          RETURN;
        END IF;
        -- End of Code for DBI Project
        --

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'event is ', l_event);
        END IF;

	-- bug# 6719369 (replenishment project) : begin : raise the business events.
	IF ( l_event IS NOT NULL ) THEN
	--{
	    --Raise Event : Pick To Pod Workflow
            WSH_WF_STD.Raise_Event(
			  p_entity_type => 'LINE',
			  p_entity_id => p_delivery_details_info.delivery_detail_id ,
			  p_event => l_event ,
			  p_organization_id => p_delivery_details_info.organization_id,
			  x_return_status => l_wf_rs ) ;
            IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
            WSH_DEBUG_SV.log(l_module_name,'Delivery Detail Id is  ',p_delivery_details_info.delivery_detail_id );
            wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
            END IF;
            --Done Raise Event: Pick To Pod Workflow
        --}
	END IF;
        --
	-- bug# 6719369 (replenishment project) : end

	-- Call DD_WV_Post_Process if W/V Change on detail or container

        -- Added condition to check if UOM Codes have been changed
        -- for post process
        -- Bug 5728048

        IF (NVL(l_gross_wt,-99) <> NVL(p_delivery_details_info.gross_weight,-99)) OR
           (NVL(l_net_wt,-99) <> NVL(p_delivery_details_info.net_weight,-99)) OR
           (NVL(l_volume,-99) <> NVL(p_delivery_details_info.volume,-99)) OR
           (NVL(l_tmp_wt_uom_code,'XX') <> NVL(p_delivery_details_info.weight_uom_code,'XX')) OR
           (NVL(l_tmp_vol_uom_code,'XX') <> NVL(p_delivery_details_info.volume_uom_code,'XX')) THEN
        --{

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_WV_UTILS.DD_WV_Post_Process(
            p_delivery_detail_id  => p_delivery_details_info.delivery_detail_id,
            p_diff_gross_wt => NVL(p_delivery_details_info.gross_weight,0) - NVL(l_gross_wt,0),
            p_diff_net_wt   => NVL(p_delivery_details_info.net_weight,0) - NVL(l_net_wt,0),
            p_diff_fill_volume => NVL(p_delivery_details_info.volume,0) - NVL(l_volume,0),
            p_diff_volume      => NVL(p_delivery_details_info.volume,0) - NVL(l_volume,0),
            x_return_status => l_return_status);

          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            raise e_wt_vol_fail;
          END IF;
        ELSIF NVL(l_filled_volume,-99) <>
                 NVL(p_delivery_details_info.filled_volume,-99)
              AND p_delivery_details_info.inventory_item_id IS NOT NULL
        THEN--}{ lpn conv
           WSH_TPA_CONTAINER_PKG.Calc_Cont_Fill_Pc (
                 p_container_instance_id =>
                                p_delivery_details_info.delivery_detail_id,
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


        IF l_container_flag IN ('Y', 'C')  AND l_org_type = 'WMS' THEN --{ lpn conv
           --bmso do we need to worry about if WMS is calling or not
           IF NVL(l_subinventory,'-1$1') <>
                           NVL(p_delivery_details_info.subinventory, '-1$1')
              OR NVL(l_locator_id,-1) <>
                                   NVL(p_delivery_details_info.locator_id,-1)
           THEN
              wsh_container_actions.Update_child_inv_info(
                        p_container_id   =>
                                  p_delivery_details_info.delivery_detail_id,
                        P_locator_id     => p_delivery_details_info.locator_id
,
                        P_subinventory   => p_delivery_details_info.subinventory,
                        X_return_status => l_return_status
              );
              wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
           END IF;
        END IF; --}

        IF l_debug_on THEN

          WSH_DEBUG_SV.log(l_module_name, 'l_gc3_is_installed', l_gc3_is_installed);
          WSH_DEBUG_SV.log(l_module_name, 'l_delivery_details_info.ignore_for_planning', p_delivery_details_info.ignore_for_planning);
          WSH_DEBUG_SV.log(l_module_name, 'l_frozen_flag', l_frozen_flag);
          WSH_DEBUG_SV.log(l_module_name, 'p_delivery_details_info.requested_quantity', p_delivery_details_info.requested_quantity);
          WSH_DEBUG_SV.log(l_module_name, 'l_requested_quantity', l_requested_quantity);
          WSH_DEBUG_SV.log(l_module_name, 'p_delivery_details_info.weight_uom_code', p_delivery_details_info.weight_uom_code);
          WSH_DEBUG_SV.log(l_module_name, 'l_tmp_wt_uom_code', l_tmp_wt_uom_code);
          WSH_DEBUG_SV.log(l_module_name, 'p_delivery_details_info.net_weight', p_delivery_details_info.net_weight);
          WSH_DEBUG_SV.log(l_module_name, 'l_net_wt', l_net_wt);
          WSH_DEBUG_SV.log(l_module_name, 'p_delivery_details_info.gross_weight', p_delivery_details_info.gross_weight);
          WSH_DEBUG_SV.log(l_module_name, 'l_gross_wt', l_gross_wt);
          WSH_DEBUG_SV.log(l_module_name, 'p_delivery_details_info.volume', p_delivery_details_info.volume);
          WSH_DEBUG_SV.log(l_module_name, 'l_volume', l_volume);
          WSH_DEBUG_SV.log(l_module_name, 'p_delivery_details_info.volume_uom_code', p_delivery_details_info.volume_uom_code);
          WSH_DEBUG_SV.log(l_module_name, 'l_tmp_vol_uom_code', l_tmp_vol_uom_code);
          WSH_DEBUG_SV.log(l_module_name, 'p_delivery_details_info.shipped_quantity', p_delivery_details_info.shipped_quantity);
          WSH_DEBUG_SV.log(l_module_name, 'l_shipped_quantity', l_shipped_quantity);
        END IF;

        -- OTM R12 : packing ECO
        IF (l_gc3_is_installed = 'Y' AND
            (nvl(p_delivery_details_info.requested_quantity, -1) <>
                nvl(l_requested_quantity, -1) OR
             nvl(p_delivery_details_info.weight_uom_code, '@@') <>
                nvl(l_tmp_wt_uom_code, '@@') OR
             nvl(p_delivery_details_info.net_weight, -1) <>
                nvl(l_net_wt, -1) OR
             nvl(p_delivery_details_info.gross_weight, -1) <>
                nvl(l_gross_wt, -1) OR
             nvl(p_delivery_details_info.volume, -1) <>
                nvl(l_volume, -1) OR                            -- packing ECO
             nvl(p_delivery_details_info.volume_uom_code, '@@') <>
                nvl(l_tmp_vol_uom_code, '@@')) AND              -- packing ECO
             nvl(p_delivery_details_info.IGNORE_FOR_PLANNING,'N') = 'N') THEN

          IF NOT (nvl(p_delivery_details_info.requested_quantity, -1) =
                     nvl(l_requested_quantity, -1) AND
                  nvl(p_delivery_details_info.weight_uom_code, '@@') =
                     nvl(l_tmp_wt_uom_code, '@@') AND
                  nvl(p_delivery_details_info.volume_uom_code, '@@') =
                     nvl(l_tmp_vol_uom_code, '@@') AND          -- packing ECO
                  nvl(p_delivery_details_info.shipped_quantity, -1) <>
                     nvl(l_shipped_quantity, -1) AND
                  nvl(l_frozen_flag, 'N') = 'N') THEN
            --weight change is not caused by shipped quantity change

            OPEN c_get_delivery_info(p_delivery_details_info.delivery_detail_id);
            FETCH c_get_delivery_info INTO l_delivery_id;
            IF (c_get_delivery_info%NOTFOUND) THEN
              l_delivery_id := NULL;
            END IF;
            CLOSE c_get_delivery_info;

            -- only proceed if tms_interface_flag is in the following
            -- which will be set to UPDATE_REQUIRED
            IF (l_delivery_id IS NOT NULL) THEN
              l_delivery_id_tab(1) := l_delivery_id;
              l_interface_flag_tab(1) := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;

              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'l_delivery_id_tab', l_delivery_id_tab(1));
                WSH_DEBUG_SV.log(l_module_name, 'l_interface_flag_tab', l_interface_flag_tab(1));
              END IF;

              WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG(
                p_delivery_id_tab        => l_delivery_id_tab,
                p_tms_interface_flag_tab => l_interface_flag_tab,
                x_return_status          => l_return_status);

              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                x_return_status := l_return_status;
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Error in WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG');
                  WSH_DEBUG_SV.log(l_module_name,'l_return_status', l_return_status);
                  WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                RETURN;
              END IF;
            END IF; -- if l_delivery_id is not null
          END IF; -- IF NOT ...
        END IF; -- if g_gc3_is_installed
        -- End of OTM R12

        --

	-- bug # 6749200 (replenishment project) : back order consolidation for dynamic replenishment case.
	IF (l_back_order_consolidation = 'Y' ) THEN
	--{

	    IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.Raise_Event',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
	    --Raise Event : backorder business event
            WSH_WF_STD.Raise_Event(
	        p_entity_type => 'LINE',
		p_entity_id => p_delivery_details_info.delivery_detail_id ,
		p_event => 'oracle.apps.wsh.line.gen.backordered' ,
		p_organization_id => p_delivery_details_info.organization_id,
		x_return_status => l_wf_rs ) ;

            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
                WSH_DEBUG_SV.log(l_module_name,'Delivery Detail Id is  ',p_delivery_details_info.delivery_detail_id );
                wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
            END IF;
            --Done Raise Event: backorder business event

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
	    END IF;
	    IF (l_global_param_rec.consolidate_bo_lines = 'Y') THEN
            --{
	        OPEN get_bo_dd_info;
	        FETCH get_bo_dd_info INTO l_line_id,l_req,l_req2,l_del_id;
	        CLOSE get_bo_dd_info;
	        l_cons_source_line_rec_tab(1).delivery_detail_id := p_delivery_details_info.delivery_detail_id;
	        l_cons_source_line_rec_tab(1).source_line_id     := l_line_id;
 	        l_cons_source_line_rec_tab(1).delivery_id        := l_del_id;
	        l_cons_source_line_rec_tab(1).bo_qty             := l_req;
	        l_cons_source_line_rec_tab(1).req_qty            := l_req;
                l_cons_source_line_rec_tab(1).bo_qty2            := l_req2;
	        l_cons_source_line_rec_tab(1).req_qty2           := l_req2;
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
	            x_return_status            => l_return_status);
                IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR )THEN
	        --{
	            x_return_status := l_return_status;
	        --}
	        END IF;
	    --}
	    END IF;
	--}
	END IF;
	-- bug # 6749200 (replenishment project) : end

	IF l_num_errors > 0
        THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        ELSIF l_num_warnings > 0
        THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        ELSE
            x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        END IF;
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --

EXCEPTION
    --lpn conv
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO s_before_update_dd;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

      IF (c_get_delivery_info%ISOPEN) THEN
        CLOSE c_get_delivery_info;
      END IF;

      IF (get_dd_info%ISOPEN) THEN
        CLOSE get_dd_info;
      END IF;

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN e_wt_vol_fail THEN
       ROLLBACK TO s_before_update_dd;
       FND_MESSAGE.SET_NAME('WSH','WSH_DET_WT_VOL_FAILED');
       FND_MESSAGE.SET_TOKEN('DETAIL_ID',p_delivery_details_info.delivery_detail_id);
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       WSH_UTIL_CORE.add_message (x_return_status);

       IF (get_dd_info%ISOPEN) THEN
         CLOSE get_dd_info;
       END IF;

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'E_WT_VOL_FAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_WT_VOL_FAIL');
       END IF;

    WHEN others THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       ROLLBACK TO s_before_update_dd;
       wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.UPDATE_DELIVERY_DETAILS',l_module_name);

       IF (c_get_delivery_info%ISOPEN) THEN
         CLOSE c_get_delivery_info;
       END IF;

       IF (get_dd_info%ISOPEN) THEN
         CLOSE get_dd_info;
       END IF;

       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
		 	--
END Update_Delivery_Details;

--
--  Procedure:   Create_Delivery_Assignments
--  Parameters:  All Attributes of a Delivery Assignment Record,
--               Row_id out
--               Delivery_Assignment_id out
--               Return_Status out
--  Description: This procedure will create a delivery_assignment
--               It will return to the use the delivery_assignment_id
--               if not provided as a parameter.
--

PROCEDURE Create_Delivery_Assignments(
	p_delivery_assignments_info    IN   Delivery_Assignments_Rec_Type,
  	x_rowid                  	OUT NOCOPY   VARCHAR2,
  	x_delivery_assignment_id        	OUT NOCOPY   NUMBER,
  	x_return_status          	OUT NOCOPY   VARCHAR2
) IS


CURSOR C_Del_Assign_Rowid
IS SELECT rowid
     FROM wsh_delivery_assignments
    WHERE delivery_assignment_id = x_delivery_assignment_id;

CURSOR C_Del_Assign_ID
IS SELECT wsh_delivery_assignments_s.nextval
FROM sys.dual;

CURSOR C_Check_Assignment_ID
IS
SELECT rowid
FROM wsh_delivery_assignments
WHERE delivery_assignment_id = x_delivery_assignment_id;

l_row_count NUMBER;
l_temp_id   NUMBER;

others exception;

l_dd_id_tab WSH_UTIL_CORE.id_tab_type;
l_da_id_tab WSH_UTIL_CORE.id_tab_type;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DELIVERY_ASSIGNMENTS';
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
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

-- delivery assignment id should not be populated before hand
/*
	IF p_delivery_assignments_info.delivery_assignment_id IS NOT NULL THEN
          RETURN;
        END IF;
 */
        l_dd_id_tab(1) :=  p_delivery_assignments_info.delivery_detail_id;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling Create_Deliv_assignment_Bulk with 1');
	END IF;
-- from this API call Bulk api with value of 1

        WSH_DELIVERY_DETAILS_PKG.Create_Deliv_Assignment_Bulk
          (p_delivery_assignments_info => p_delivery_assignments_info,
           p_num_of_rec  => 1,
           p_dd_id_tab   =>  l_dd_id_tab,
           x_da_id_tab   =>  l_da_id_tab,
  	   x_return_status =>  x_return_status);

	   x_delivery_assignment_id := l_da_id_tab(1);

 	OPEN C_Del_Assign_Rowid;
        FETCH C_Del_Assign_Rowid INTO x_rowid;
        IF (C_Del_Assign_Rowid%NOTFOUND) THEN
            CLOSE C_Del_Assign_Rowid;
            RAISE others;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;
        CLOSE C_Del_Assign_Rowid;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
	EXCEPTION
 		WHEN others THEN
		 	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		 	wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.CREATE_DELIVERY_ASSIGNMENTS',l_module_name);

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Create_Delivery_Assignments;

--
--  Procedure:   Delete_Delivery_Assignments
--  Parameters:  All Attributes of a Delivery Assignment Record,
--               Row_id out
--               Delivery_Assignment_id out
--               Return_Status out
--  Description: This procedure will delete a delivery assignment.
--               It will return to the use the delivery_assignment id
--               if not provided as a parameter.
--
--  OTM R12 : This procedure was reviewed during OTM R12 frontport project
--            but not modified since it's not called from anywhere
--            It should be modified properly when it will be in use
--            Refer to TDD for the details of expected changes

PROCEDURE Delete_Delivery_Assignments
	(p_rowid IN VARCHAR2,
	 p_delivery_assignment_id IN NUMBER,
	 x_return_status OUT NOCOPY  VARCHAR2)
IS

CURSOR get_del_assignment_id_rowid (v_rowid VARCHAR2) IS
SELECT delivery_assignment_id
FROM   wsh_delivery_assignments
WHERE  rowid = v_rowid;

l_delivery_assignment_id NUMBER;
others exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_DELIVERY_ASSIGNMENTS';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
	    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ASSIGNMENT_ID',P_DELIVERY_ASSIGNMENT_ID);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF p_rowid IS NOT NULL THEN
		OPEN  get_del_assignment_id_rowid(p_rowid);
     	FETCH get_del_assignment_id_rowid INTO l_delivery_assignment_id;
     	CLOSE get_del_assignment_id_rowid;
 	END IF;

  	IF l_delivery_assignment_id IS NULL THEN
  		l_delivery_assignment_id := p_delivery_assignment_id;
        END IF;

  	IF p_delivery_assignment_id IS NOT NULL THEN
 		DELETE FROM wsh_delivery_assignments
     	WHERE  delivery_assignment_id = l_delivery_assignment_id;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	ELSE
		raise others;
	END IF;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  	EXCEPTION
  		WHEN others THEN
		 	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		 	wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG_.DELETE_DELIVERY_ASSIGNMENTS',l_module_name);

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Delete_Delivery_Assignments;

--
--  Procedure:   Update_Delivery_Assignments
--  Parameters:
--               Row_id in
--               Return_Status out
--  Description: This procedure will update a delivery assignment.
--
--  OTM R12 : This procedure was reviewed during OTM R12 frontport project
--            but not modified since it's not called from anywhere
--            It should be modified properly when it will be in use
--            Refer to TDD for the details of expected changes
PROCEDURE Update_Delivery_Assignments(
        p_rowid               IN   VARCHAR2 := NULL,
        p_delivery_assignments_info   IN   Delivery_Assignments_Rec_Type,
        x_return_status       OUT NOCOPY   VARCHAR2
        ) IS
CURSOR get_rowid  IS
SELECT rowid
FROM wsh_delivery_assignments
WHERE delivery_assignment_id = p_delivery_assignments_info.delivery_assignment_id;

l_rowid VARCHAR2(30);
others exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_DELIVERY_ASSIGNMENTS';
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
            WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
        END IF;
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        IF (p_rowid IS NULL) THEN
                OPEN get_rowid;
        FETCH get_rowid INTO l_rowid;

                IF (get_rowid%NOTFOUND) THEN
                CLOSE get_rowid;
                RAISE no_data_found;
        END IF;
        CLOSE get_rowid;

        ELSE
                l_rowid := p_rowid;
        END IF;

        UPDATE wsh_delivery_assignments
        SET
                delivery_id     =       p_delivery_assignments_info.delivery_id,
                parent_delivery_id =    p_delivery_assignments_info.parent_delivery_id,
        delivery_detail_id =    p_delivery_assignments_info.delivery_detail_id,
      parent_delivery_detail_id = p_delivery_assignments_info.parent_delivery_detail_id,
      last_update_date =      p_delivery_assignments_info.last_update_date,
      last_updated_by =       p_delivery_assignments_info.last_updated_by,
      last_update_login =     p_delivery_assignments_info.last_update_login,
      program_application_id = p_delivery_assignments_info.program_application_id,
      program_id             = p_delivery_assignments_info.program_id,
                program_update_date    = p_delivery_assignments_info.program_update_date,
                request_id             = p_delivery_assignments_info.request_id,
                active_flag = p_delivery_assignments_info.active_flag,
      delivery_assignment_id = p_delivery_assignments_info.delivery_assignment_id
        WHERE rowid = l_rowid;

        IF (SQL%NOTFOUND) THEN
                raise others;
        ELSE
                x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
        EXCEPTION
                WHEN others THEN
                        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                        wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.UPDATE_DELIVERY_ASSIGNMENTS',l_module_name);

--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Update_Delivery_Assignments;

--
--  Procedure:   Lock_Delivery_Assignments
--  Parameters:  All Attributes of a Delivery Assignment Record,
--               Row_id in
--               Return_Status out
--  Description: This procedure will lock a delivery assignment.
--

PROCEDURE Lock_Delivery_Assignments (
	p_rowid                 IN   VARCHAR2,
  	p_delivery_assignments_info     IN   Delivery_Assignments_Rec_Type,
   x_return_status         OUT NOCOPY   VARCHAR2
   ) IS

CURSOR lock_row IS
SELECT *
FROM wsh_delivery_assignments
WHERE rowid = p_rowid
FOR UPDATE OF delivery_assignment_id NOWAIT;

Recinfo lock_row%ROWTYPE;
others exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_DELIVERY_ASSIGNMENTS';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	OPEN  lock_row;
  	FETCH lock_row INTO Recinfo;
  	IF (lock_row%NOTFOUND) THEN
  		CLOSE lock_row;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  		FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
	   wsh_util_core.add_message(x_return_status,l_module_name);
     	--
     	IF l_debug_on THEN
     	    WSH_DEBUG_SV.pop(l_module_name);
     	END IF;
     	--
     	RETURN;
	END IF;
  	CLOSE lock_row;

  	IF (
		(Recinfo.delivery_assignment_id = p_delivery_assignments_info.delivery_assignment_id)
	AND	(  (Recinfo.delivery_id = p_delivery_assignments_info.delivery_id)
              OR (  (Recinfo.delivery_id IS NULL)
                  AND  (p_delivery_assignments_info.delivery_id IS NULL)))
	AND     (  (Recinfo.parent_delivery_id = p_delivery_assignments_info.parent_delivery_id)
              OR (  (Recinfo.parent_delivery_id IS NULL)
                  AND  (p_delivery_assignments_info.parent_delivery_id IS NULL)))
	AND     (  (Recinfo.delivery_detail_id = p_delivery_assignments_info.parent_delivery_id)
              OR (  (Recinfo.delivery_detail_id IS NULL)
                  AND  (p_delivery_assignments_info.delivery_detail_id IS NULL)))
	AND	(Recinfo.creation_date = p_delivery_assignments_info.creation_date)
	AND	(Recinfo.created_by = p_delivery_assignments_info.created_by)
	AND	(Recinfo.last_update_date = p_delivery_assignments_info.last_update_date)
	AND     (Recinfo.last_updated_by = p_delivery_assignments_info.last_updated_by)
	AND 	(  (Recinfo.last_update_login = p_delivery_assignments_info.last_update_login)
              OR (  (Recinfo.last_update_login IS NULL)
                  AND  (p_delivery_assignments_info.last_update_login IS NULL)))
	AND (  (Recinfo.program_application_id = p_delivery_assignments_info.program_application_id)
              OR (  (Recinfo.program_application_id IS NULL)
                  AND  (p_delivery_assignments_info.program_application_id IS NULL))))
	THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  		--
  		IF l_debug_on THEN
  		    WSH_DEBUG_SV.pop(l_module_name);
  		END IF;
  		--
  		RETURN;
 	ELSE
--		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
  		IF l_debug_on THEN
  		    WSH_DEBUG_SV.log(l_module_name,'FORM RECORD CHANGED');
  		END IF;
		app_exception.raise_exception;

	END IF;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  	EXCEPTION
  		WHEN others THEN
			wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.LOCK_DELIVERY_ASSIGNMENTS',l_module_name);
			x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
			--
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
			    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
			END IF;
			--
END Lock_Delivery_Assignments;


procedure Lock_Delivery_Details(
        p_rec_attr_tab          IN              WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
        p_caller                IN              VARCHAR2,
        p_valid_index_tab       IN              wsh_util_core.id_tab_type,
        x_valid_ids_tab         OUT             NOCOPY wsh_util_core.id_tab_type,
        x_return_status         OUT             NOCOPY VARCHAR2
)

IS
--
--
l_index NUMBER := 0;
l_num_errors NUMBER := 0;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_DELIVERY_DETAILS_WRAPPER';
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
      WSH_DEBUG_SV.log(l_module_name,'p_caller',p_caller);
      WSH_DEBUG_SV.log(l_module_name,'Total Number of Delivery Detail Records being locked',p_valid_index_tab.COUNT);
  END IF;
  --
  --
  l_index := p_valid_index_tab.FIRST;
  --
  while l_index is not null loop
    begin
      --
      savepoint lock_delivery_detail_loop;
      --
      if p_caller = 'WSH_FSTRX' then
            lock_delivery_details(p_rowid	            => p_rec_attr_tab(l_index).rowid,
  	        	    p_delivery_details_info => p_rec_attr_tab(l_index)
               );
      else
            lock_detail_no_compare(
                 p_delivery_detail_id  => p_rec_attr_tab(l_index).delivery_detail_id);
      end if;

      IF nvl(p_caller,FND_API.G_MISS_CHAR) <> 'WSH_FSTRX' THEN
        x_valid_ids_tab(x_valid_ids_tab.COUNT + 1) := p_rec_attr_tab(l_index).delivery_detail_id;
      ELSE
        x_valid_ids_tab(x_valid_ids_tab.COUNT + 1) := l_index;
      END IF;
      --
    exception
      --
      WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
        rollback to lock_delivery_detail_loop;
        IF nvl(p_caller,'!') = 'WSH_PUB'
           OR nvl(p_caller, '!') like 'FTE%' THEN
          FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVB_LOCK_FAILED');
	  FND_MESSAGE.SET_TOKEN('ENTITY_NAME',p_rec_attr_tab(l_index).delivery_detail_id);
          wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
        END IF;
        l_num_errors := l_num_errors + 1;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Unable to obtain lock on the Delivery Detail Id',p_rec_attr_tab(l_index).delivery_detail_id);
      END IF;
      --
      WHEN others THEN
        rollback to lock_delivery_detail_loop;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end;
    --
    l_index := p_valid_index_tab.NEXT(l_index);
    --
  end loop;
  --
  IF p_valid_index_tab.COUNT = 0 THEN
     x_return_status := wsh_util_core.g_ret_sts_success;
  ELSIF l_num_errors = p_valid_index_tab.COUNT THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_UI_NOT_PERFORMED');
    x_return_status := wsh_util_core.g_ret_sts_error;
    wsh_util_core.add_message(x_return_status,l_module_name);
    IF l_debug_on THEN
      wsh_debug_sv.logmsg(l_module_name, 'WSH_UI_NOT_PERFORMED');
    END IF;
    raise fnd_api.g_exc_error;
  ELSIF l_num_errors > 0 THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_UI_NOT_PROCESSED');
    x_return_status := wsh_util_core.g_ret_sts_warning;
    wsh_util_core.add_message(x_return_status,l_module_name);
    IF l_debug_on THEN
      wsh_debug_sv.logmsg(l_module_name, 'WSH_UI_NOT_PROCESSED');
    END IF;
    raise wsh_util_core.g_exc_warning;
  ELSE
    x_return_status := wsh_util_core.g_ret_sts_success;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  --
  --
  WHEN FND_API.G_EXC_ERROR THEN
  --
    x_return_status := wsh_util_core.g_ret_sts_error;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := wsh_util_core.g_ret_sts_unexp_error;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
  --
  WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
    x_return_status := wsh_util_core.g_ret_sts_warning;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
    END IF;
  --
  WHEN OTHERS THEN
  --
    x_return_status := wsh_util_core.g_ret_sts_unexp_error;
    --
    wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.LOCK_DELIVERY_DETAILS_WRAPPER',l_module_name);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
  --
END Lock_Delivery_Details;

/*    ---------------------------------------------------------------------
     Procedure:	Lock_Detail_No_Compare

     Parameters:	Delivery_Detail Id DEFAULT NULL
                         Delivery Id        DEFAULT NULL

     Description:  This procedure is used for obtaining locks of lines/lpns
                    using the delivery_detail_id or the delivery_id.
                    This is called by delivery detail's wrapper lock API when the p_caller is NOT WSHFSTRX.
                   It is also called by delivery's wrapper lock API when the
                   action is CONFIRM, AUTO-PACK or AUTO-PACK-MASTER.
                    This procedure does not compare the attributes. It just
                    does a SELECT using FOR UPDATE NOWAIT
     Created:   Harmonization Project. Patchset I
     ----------------------------------------------------------------------- */


PROCEDURE Lock_Detail_No_Compare(
                p_delivery_detail_id   IN    NUMBER, -- default null in spec
                p_delivery_id          IN    NUMBER -- default null in spec
               )
IS

CURSOR c_lock_details_of_dlvy(p_dlvy_id NUMBER) IS
SELECT wdd.delivery_detail_id
FROM   wsh_delivery_details wdd, wsh_delivery_assignments wda
WHERE  wdd.delivery_detail_id = wda.delivery_detail_id
AND    wda.delivery_id = p_dlvy_id
FOR UPDATE OF wdd.delivery_detail_id NOWAIT;

CURSOR c_lock_detail(p_detail_id NUMBER) IS
     SELECT delivery_detail_id
     FROM wsh_delivery_details
     WHERE delivery_detail_id = p_delivery_detail_id
     FOR UPDATE NOWAIT;

l_dummy_detail_id  NUMBER;
l_del_name         VARCHAR2(30);

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_DETAIL_NO_COMPARE';

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
      WSH_DEBUG_SV.log(l_module_name,'p_delivery_detail_id', p_delivery_detail_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_delivery_id', p_delivery_id);
  END IF;
  --

  IF p_delivery_Detail_id IS NOT NULL THEN
     open c_lock_detail(p_delivery_detail_id);
     fetch c_lock_detail into l_dummy_detail_id;
     close c_lock_detail;
  ELSIF p_delivery_id IS NOT NULL THEN
     OPEN c_lock_details_of_dlvy(p_delivery_id);
     CLOSE c_lock_details_of_dlvy;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
EXCEPTION
	WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
            IF p_delivery_id IS NOT NULL THEN
              l_del_name := wsh_new_deliveries_pvt.get_name(p_delivery_id);
              FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVY_LINE_LPN_LOCK');
              FND_MESSAGE.SET_TOKEN('DEL_NAME', l_del_name);
              wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
              IF l_debug_on THEN
                 wsh_debug_sv.log(l_module_name, 'Could not obtain lock on some lines or lpns of delivery', p_delivery_id);
              END IF;
            ELSE
              IF l_debug_on THEN
                 wsh_debug_sv.log(l_module_name, 'Could not obtain lock on del detail', p_delivery_detail_id);
              END IF;
            END IF;

	      IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'APP_EXCEPTION.APPLICATION_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APP_EXCEPTION.APPLICATION_EXCEPTION');
	      END IF;
	      --
	      RAISE;

END Lock_Detail_No_Compare;

--  Bug 3292364
--  Procedure:   Table_To_Record
--  Parameters:  x_delivery_detail_rec: A record of all attributes of a Delivery detail Record
--               p_delivery_detail_id : delivery_detail_id of the detail that is to be copied
--               Return_Status,
--  Description: This procedure will copy the attributes of a delivery detail in wsh_delivery_details
--               and copy it to a record.

Procedure Table_To_Record(
          p_delivery_detail_id IN NUMBER,
          x_delivery_detail_rec OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type,
          x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR c_tbl_rec (p_delivery_detail_id IN NUMBER) IS
SELECT           delivery_detail_id
                ,source_code
                ,source_header_id
                ,source_line_id
                ,customer_id
                ,sold_to_contact_id
                ,inventory_item_id
                ,item_description
                ,hazard_class_id
                ,country_of_origin
                ,classification
                ,ship_from_location_id
                ,ship_to_location_id
                ,ship_to_contact_id
                ,ship_to_site_use_id
                ,deliver_to_location_id
                ,deliver_to_contact_id
                ,deliver_to_site_use_id
                ,intmed_ship_to_location_id
                ,intmed_ship_to_contact_id
                ,hold_code
                ,ship_tolerance_above
                ,ship_tolerance_below
                ,requested_quantity
                ,shipped_quantity
                ,delivered_quantity
                ,requested_quantity_uom
                ,subinventory
                ,revision
                ,lot_number
                ,customer_requested_lot_flag
                ,serial_number
                ,locator_id
                ,date_requested
                ,date_scheduled
                ,master_container_item_id
                ,detail_container_item_id
                ,load_seq_number
                ,ship_method_code
                ,carrier_id
                ,freight_terms_code
                ,shipment_priority_code
                ,fob_code
                ,customer_item_id
                ,dep_plan_required_flag
                ,customer_prod_seq
                ,customer_dock_code
                ,cust_model_serial_number
                ,customer_job
                ,customer_production_line
                ,net_weight
                ,weight_uom_code
                ,volume
                ,volume_uom_code
                ,tp_attribute_category
                ,tp_attribute1
                ,tp_attribute2
                ,tp_attribute3
                ,tp_attribute4
                ,tp_attribute5
                ,tp_attribute6
                ,tp_attribute7
                ,tp_attribute8
                ,tp_attribute9
                ,tp_attribute10
                ,tp_attribute11
                ,tp_attribute12
                ,tp_attribute13
                ,tp_attribute14
                ,tp_attribute15
                ,attribute_category
                ,attribute1
                ,attribute2
                ,attribute3
                ,attribute4
                ,attribute5
                ,attribute6
                ,attribute7
                ,attribute8
                ,attribute9
                ,attribute10
                ,attribute11
                ,attribute12
                ,attribute13
                ,attribute14
                ,attribute15
                ,created_by
                ,creation_date
                ,sysdate
                ,FND_GLOBAL.LOGIN_ID
                ,FND_GLOBAL.USER_ID
                ,program_application_id
                ,program_id
                ,program_update_date
                ,request_id
                ,mvt_stat_status
                ,NULL -- released_flag
                ,organization_id
                ,transaction_temp_id
                ,ship_set_id
                ,arrival_set_id
                ,ship_model_complete_flag
                ,top_model_line_id
                ,source_header_number
                ,source_header_type_id
                ,source_header_type_name
                ,cust_po_number
                ,ato_line_id
                ,src_requested_quantity
                ,src_requested_quantity_uom
                ,move_order_line_id
                ,cancelled_quantity
                ,quality_control_quantity
                ,cycle_count_quantity
                ,tracking_number
                ,movement_id
                ,shipping_instructions
                ,packing_instructions
                ,project_id
                ,task_id
                ,org_id
                ,oe_interfaced_flag
                ,split_from_delivery_detail_id
                ,inv_interfaced_flag
                ,source_line_number
                ,inspection_flag
                ,released_status
                ,container_flag
                ,container_type_code
                ,container_name
                ,fill_percent
                ,gross_weight
                ,master_serial_number
                ,maximum_load_weight
                ,maximum_volume
                ,minimum_fill_percent
                ,seal_code
                ,unit_number
                ,unit_price
                ,currency_code
                ,freight_class_cat_id
                ,commodity_code_cat_id
                ,preferred_grade
                ,src_requested_quantity2
                ,src_requested_quantity_uom2
                ,requested_quantity2
                ,shipped_quantity2
                ,delivered_quantity2
                ,cancelled_quantity2
                ,quality_control_quantity2
                ,cycle_count_quantity2
                ,requested_quantity_uom2
-- HW OPMCONV - No need for sublot_number
--              ,sublot_number
                ,lpn_id
                ,pickable_flag
                ,original_subinventory
                ,to_serial_number
                ,picked_quantity
                ,picked_quantity2
                ,received_quantity
                ,received_quantity2
                ,source_line_set_id
                ,batch_id
                ,NULL -- ROWID
                ,transaction_id
                ,vendor_id
                ,ship_from_site_id
                ,nvl(line_direction, 'O')
                ,party_id
                ,routing_req_id
                ,shipping_control
                ,source_blanket_reference_id
                ,source_blanket_reference_num
                ,po_shipment_line_id
                ,po_shipment_line_number
                ,returned_quantity
                ,returned_quantity2
                ,rcv_shipment_line_id
                ,source_line_type_code
                ,supplier_item_number
                ,nvl(ignore_for_planning, 'N')
                ,earliest_pickup_date
                ,latest_pickup_date
                ,earliest_dropoff_date
                ,latest_dropoff_date
                ,request_date_type_code
                ,tp_delivery_detail_id
                ,source_document_type_id
                ,unit_weight
                ,unit_volume
                ,filled_volume
                ,wv_frozen_flag
                ,mode_of_transport
                ,service_level
                ,po_revision_number
                ,release_revision_number
                ,replenishment_status  --bug# 6689448 (replenishment project)
                -- Standalone project Changes Start
                ,original_lot_number
                ,reference_number
                ,reference_line_number
                ,reference_line_quantity
                ,reference_line_quantity_uom
                ,original_revision
                ,original_locator_id
                -- Standalone project Changes End
                , client_id -- LSP PROJECT
                -- TPW - Distributed Organization Changes - Start
                ,shipment_batch_id
                ,shipment_line_number
                ,reference_line_id
                -- TPW - Distributed Organization Changes - End
                ,consignee_flag --RTV chagnes
FROM wsh_delivery_details
WHERE delivery_detail_id = p_delivery_detail_id;

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Table_To_Record';


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
      WSH_DEBUG_SV.log(l_module_name,'p_delivery_detail_id', p_delivery_detail_id);
    END IF;
    --

    OPEN c_tbl_rec (p_delivery_detail_id);
    FETCH c_tbl_rec INTO x_delivery_detail_rec;
        IF c_tbl_rec%NOTFOUND THEN
        --
           CLOSE c_tbl_rec;
           RAISE no_data_found;
        --
        END IF;
    CLOSE c_tbl_rec;

    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    x_return_status := wsh_util_core.g_ret_sts_success;
EXCEPTION

    WHEN OTHERS THEN
      IF c_tbl_rec%ISOPEN THEN
         CLOSE c_tbl_rec;
      END IF;
      --
      x_return_status := wsh_util_core.g_ret_sts_unexp_error;
      --
      wsh_util_core.default_handler('WSH_DELIVERY_DETAILS_PKG.Table_to_Record',l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --

END  Table_to_Record;

/*    ---------------------------------------------------------------------
     Procedure:	Lock_WDA_No_Compare

     Parameters:	Delivery_Detail Id DEFAULT NULL
                         Delivery Id        DEFAULT NULL

     Description:  This procedure is used for obtaining locks of delivery assignments
                    using the delivery_detail_id or the delivery_id.
                    This procedure does not compare the attributes. It just
                    does a SELECT using FOR UPDATE NOWAIT
     Created:  K: MDC
     ----------------------------------------------------------------------- */


PROCEDURE Lock_WDA_No_Compare(
                p_delivery_detail_id   IN    NUMBER, -- default null in spec
                p_delivery_id          IN    NUMBER -- default null in spec
               )
IS

CURSOR c_lock_wda_of_dlvy(p_dlvy_id NUMBER) IS
SELECT delivery_detail_id
FROM   wsh_delivery_assignments
WHERE  delivery_id = p_dlvy_id
FOR UPDATE NOWAIT;

CURSOR c_lock_wda_of_detail(p_detail_id NUMBER) IS
SELECT delivery_detail_id
FROM wsh_delivery_assignments
WHERE delivery_detail_id = p_delivery_detail_id
FOR UPDATE NOWAIT;

l_dummy_detail_id  NUMBER;
l_del_name         VARCHAR2(30);

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_DETAIL_NO_COMPARE';

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
      WSH_DEBUG_SV.log(l_module_name,'p_delivery_detail_id', p_delivery_detail_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_delivery_id', p_delivery_id);
  END IF;
  --

  IF p_delivery_Detail_id IS NOT NULL THEN
     open c_lock_wda_of_detail(p_delivery_detail_id);
     fetch c_lock_wda_of_detail into l_dummy_detail_id;
     close c_lock_wda_of_detail;
  ELSIF p_delivery_id IS NOT NULL THEN
     OPEN c_lock_wda_of_dlvy(p_delivery_id);
     FETCH c_lock_wda_of_dlvy INTO l_dummy_detail_id;
     CLOSE c_lock_wda_of_dlvy;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
EXCEPTION
	WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
            IF p_delivery_id IS NOT NULL THEN
              l_del_name := wsh_new_deliveries_pvt.get_name(p_delivery_id);
              FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVY_LINE_LPN_LOCK');
              FND_MESSAGE.SET_TOKEN('DEL_NAME', l_del_name);
              wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
              IF l_debug_on THEN
                 wsh_debug_sv.log(l_module_name, 'Could not obtain lock on some lines or lpns of delivery', p_delivery_id);
              END IF;
            ELSE
              IF l_debug_on THEN
                 wsh_debug_sv.log(l_module_name, 'Could not obtain lock on del detail', p_delivery_detail_id);
              END IF;
            END IF;

	      IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'APP_EXCEPTION.APPLICATION_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APP_EXCEPTION.APPLICATION_EXCEPTION');
	      END IF;
	      --
	      RAISE;

END LOCK_WDA_NO_COMPARE;

END WSH_DELIVERY_DETAILS_PKG;


/
