--------------------------------------------------------
--  DDL for Package Body WSH_BOLS_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_BOLS_UTIL_PKG" AS
/* $Header: WSHBLUTB.pls 120.1.12010000.2 2009/12/03 15:26:40 mvudugul ship $ */

-- utility function
-- purpose: Concatenate string with end of line character, depending
--          on the output format. Now supporting HTML and
--          Report(PL/SQL).

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_BOLS_UTIL_PKG';
--
FUNCTION concat_eol
  (p_org_string IN VARCHAR2,
   p_mode IN VARCHAR2
   )
  RETURN VARCHAR2
  IS
     --Bugfix 5119785 increased width of variable
     l_org_string VARCHAR2(32767) := NULL;
     --
l_debug_on BOOLEAN;
     --
     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONCAT_EOL';
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
       WSH_DEBUG_SV.log(l_module_name,'P_ORG_STRING',P_ORG_STRING);
       WSH_DEBUG_SV.log(l_module_name,'P_MODE',P_MODE);
   END IF;
   --
   IF p_mode = 'WEB' THEN
      l_org_string := (p_org_string || '<br>');
    ELSE
      l_org_string := (p_org_string || fnd_global.local_chr(10));
   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'L_ORG_STRING',l_org_string);
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN (l_org_string);
EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END concat_eol;


-- utility function
-- purpose: Concatenate two end of line characters after
--          the string. Now supporting HTML and Report(PL/SQL)
--          formats.

FUNCTION concat_eol2
  (p_org_string IN VARCHAR2,
   p_mode IN VARCHAR2
   )
  RETURN VARCHAR2
  IS
     --Bugfix 5119785 increased width of variable
     l_org_string VARCHAR2(32767) := NULL;
     --
l_debug_on BOOLEAN;
     --
     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONCAT_EOL2';
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
       WSH_DEBUG_SV.log(l_module_name,'P_ORG_STRING',P_ORG_STRING);
       WSH_DEBUG_SV.log(l_module_name,'P_MODE',P_MODE);
   END IF;
   --
   IF p_mode = 'WEB' THEN
      l_org_string := (p_org_string || '<br><br>');
    ELSE
      l_org_string := (p_org_string || fnd_global.local_chr(10) || fnd_global.local_chr(10));
   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'L_ORG_STRING',l_org_string);
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN (l_org_string);
EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END concat_eol2;


-- utility function
-- purpose: get item description

FUNCTION encode_desc
  (p_description_mode IN VARCHAR2,
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_item_description IN VARCHAR2
   )
  RETURN VARCHAR2
  IS

     -- Bug# 3306781
     CURSOR c_get_item_desc (p_inventory_item_id IN NUMBER, p_organization_id IN NUMBER) IS
     SELECT description
     FROM mtl_system_items_vl
     WHERE organization_id = p_organization_id
     AND inventory_item_id = p_inventory_item_id;

l_description VARCHAR2(250) := NULL;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ENCODE_DESC';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DESCRIPTION_MODE',P_DESCRIPTION_MODE);
       WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ITEM_DESCRIPTION',P_ITEM_DESCRIPTION);
   END IF;
   --
   IF p_description_mode = 'D' THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
   -- Bug# 3306781
   l_description :=  p_item_description;
   IF p_inventory_item_id IS NOT NULL THEN
      OPEN c_get_item_desc(p_inventory_item_id,p_organization_id);
      FETCH c_get_item_desc INTO l_description;
      CLOSE c_get_item_desc;
   END IF;

      --
      RETURN l_description;
   END IF;

   IF p_description_mode = 'F' THEN
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GENERIC_FLEX_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      -- LSP PROJECT :
      /*RETURN wsh_util_core.generic_flex_name(p_inventory_item_id,
					     p_organization_id,
					     'INV',
					     'MSTK',
					     101
					     ); */

      RETURN WSH_UTIL_CORE.get_item_name(p_inventory_item_id
                                         ,p_organization_id
                                         ,'MSTK'
                                         ,101,'Y');

   END IF;

   -- :P_ITEM_DISPLAY is 'B'
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GENERIC_FLEX_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   -- Bug# 3306781
   l_description :=  p_item_description;
   IF p_inventory_item_id IS NOT NULL THEN
      OPEN c_get_item_desc(p_inventory_item_id,p_organization_id);
      FETCH c_get_item_desc INTO l_description;
      CLOSE c_get_item_desc;
   END IF;
   -- LSP PROJECT:
   /* RETURN wsh_util_core.generic_flex_name(p_inventory_item_id,
					  p_organization_id,
					  'INV',
					  'MSTK',
					  101) || ' ' || l_description; */
   RETURN WSH_UTIL_CORE.get_item_name(p_inventory_item_id
                                      ,p_organization_id
                                      ,'MSTK'
                                      ,101,'Y')|| ' ' || l_description;

EXCEPTION
   WHEN OTHERS THEN
      FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END encode_desc;


-- purpose: get the container contents information for master
--          container
-- parameters: p_master_container_id = wsh_delivery_detail_id
--             p_output_mode = 'WEB' or 'REPORT'
--             p_description_mode = 'D', 'F', or 'B'
--             p_organization_id (or warehouse id)
--             x_data_item_classification, for the container
--             x_container_contents, for the container
--             x_hazard_code, for the container
--             x_return_status

PROCEDURE get_master_container_contents
  (p_master_container_id IN NUMBER,
   p_output_mode IN VARCHAR2,
   p_description_mode IN VARCHAR2,
   p_organization_id IN NUMBER,
   x_data_item_classification IN OUT NOCOPY  VARCHAR2,
   x_container_contents IN OUT NOCOPY  VARCHAR2,
   x_hazard_code IN OUT NOCOPY  VARCHAR2,
   x_num_of_packages IN OUT NOCOPY  NUMBER,
   x_return_status OUT NOCOPY  VARCHAR2
   )
  IS
     CURSOR c_get_container_lpn(x_master_inst_id NUMBER) IS
	SELECT container_name,
	  container_type_code,
	  item_description,
	  inventory_item_id,
	  gross_weight,
	  weight_uom_code,
	  volume,
	  volume_uom_code
	  FROM wsh_delivery_details
	  WHERE delivery_detail_id = x_master_inst_id
	  AND container_flag = 'Y';

     CURSOR c_get_master_container_items(x_master_inst_id NUMBER) IS
	SELECT wdd.item_description,
	  wdd.inventory_item_id,
	  wdd.hazard_class_id,
	  wdd.shipped_quantity,
	  wdd.requested_quantity_uom,
	  wdd.classification
	  FROM wsh_delivery_details wdd,
	  wsh_delivery_assignments_v wda
	  WHERE wda.parent_delivery_detail_id = x_master_inst_id
	  AND wda.delivery_detail_id = wdd.delivery_detail_id
	  AND wdd.container_flag = 'N';

     CURSOR c_get_inner_containers(x_container_id NUMBER) IS
	SELECT wdd.delivery_detail_id
	  FROM wsh_delivery_details     wdd,
	  wsh_delivery_assignments_v wda
	  WHERE wda.delivery_detail_id = wdd.delivery_detail_id
	  AND wdd.container_flag = 'Y'
	  AND wda.delivery_assignment_id IN
	  (SELECT wda1.delivery_assignment_id
	   FROM wsh_delivery_assignments_v wda1
	   START WITH wda1.parent_delivery_detail_id =  x_container_id
	   CONNECT BY PRIOR wda1.delivery_detail_id = wda1.parent_delivery_detail_id);

     CURSOR c_get_container_items(x_cont_inst_id NUMBER) IS
	SELECT wdd.item_description,
	  wdd.inventory_item_id,
	  wdd.hazard_class_id,
	  wdd.shipped_quantity,
	  wdd.requested_quantity_uom,
	  wdd.classification
	  FROM wsh_delivery_details wdd,
	  wsh_delivery_assignments_v wda
	  WHERE wda.parent_delivery_detail_id = x_cont_inst_id
	  AND wda.delivery_detail_id = wdd.delivery_detail_id
	  AND wdd.container_flag = 'N';

     CURSOR c_get_sub_containers(x_master_inst_id NUMBER) IS
	SELECT wdd.delivery_detail_id
	  FROM wsh_delivery_assignments_v wda,
	  wsh_delivery_details     wdd
	  WHERE wda.parent_delivery_detail_id = x_master_inst_id
	  AND wda.delivery_detail_id = wdd.delivery_detail_id
	  AND wdd.container_flag = 'Y';

     CURSOR c_get_enclosed_containers(x_cont_id NUMBER) IS
	SELECT container_name
	  FROM wsh_delivery_details
	  WHERE delivery_detail_id = x_cont_id
	  AND container_flag = 'Y';

     -- Bug# 3306781
     CURSOR c_get_item_desc (p_inventory_item_id IN NUMBER, p_organization_id IN NUMBER) IS
     SELECT description
     FROM mtl_system_items_vl
     WHERE organization_id = p_organization_id
     AND inventory_item_id = p_inventory_item_id;


     l_contents_count NUMBER := 0;
     l_item_description VARCHAR2(250) := NULL;
     l_hazard_class_id NUMBER := NULL;
     l_shipped_quantity NUMBER := NULL;
     l_requested_quantity_uom VARCHAR2(3) := NULL;
     l_item_class VARCHAR2(30) := NULL;

     l_master_container_lpn VARCHAR2(30) := NULL;
     l_container_type_code VARCHAR2(30) := NULL;
     l_container_description VARCHAR2(250) := NULL;
     l_data_container_gross_weight NUMBER := NULL;
     l_data_cont_uom_weight_code VARCHAR2(3) := NULL;
     l_data_container_volume NUMBER := NULL;
     l_data_cont_uom_volume_code VARCHAR2(3) := NULL;

     l_sub_containers_count NUMBER := 0;
     l_sub_container_id NUMBER := NULL;
     l_sub_container_lpn VARCHAR2(50) := NULL;
     l_sub_contents_count NUMBER := 0;
     l_data_sub_weight NUMBER := NULL;
     l_data_sub_weight_uom VARCHAR2(3) := NULL;
     l_data_sub_volume NUMBER := NULL;
     l_data_sub_volume_uom VARCHAR2(3) := NULL;

     l_enclosed_count NUMBER := 0;
     l_check_sub_containers NUMBER := 0;
     l_enclosed_lpn VARCHAR2(50) := NULL;
     l_enclosed_list VARCHAR2(2000) := NULL;

     l_contains_label VARCHAR2(100) := NULL;
     l_of_label VARCHAR2(100) := NULL;
     l_lpn_label VARCHAR2(100) := NULL;
     l_encloses_label VARCHAR2(100) := NULL;

     l_item_inventory_item_id NUMBER := NULL;
     l_container_inventory_item_id NUMBER := NULL;

     -- tmp variable
     --p_organization_id NUMBER := 207;

     --
l_debug_on BOOLEAN;
     --
     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_MASTER_CONTAINER_CONTENTS';
     --
BEGIN

   -- get the labels
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
       WSH_DEBUG_SV.log(l_module_name,'P_MASTER_CONTAINER_ID',P_MASTER_CONTAINER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_OUTPUT_MODE',P_OUTPUT_MODE);
       WSH_DEBUG_SV.log(l_module_name,'P_DESCRIPTION_MODE',P_DESCRIPTION_MODE);
       WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'X_DATA_ITEM_CLASSIFICATION',X_DATA_ITEM_CLASSIFICATION);
       WSH_DEBUG_SV.log(l_module_name,'X_CONTAINER_CONTENTS',X_CONTAINER_CONTENTS);
       WSH_DEBUG_SV.log(l_module_name,'X_HAZARD_CODE',X_HAZARD_CODE);
       WSH_DEBUG_SV.log(l_module_name,'X_NUM_OF_PACKAGES',X_NUM_OF_PACKAGES);
   END IF;
   --
   fnd_message.set_name('WSH','WSH_WEB_CONTAINS_LABEL');
   l_contains_label := fnd_message.get;

   fnd_message.set_name('WSH','WSH_WEB_OF_LABEL');
   l_of_label := fnd_message.get;

   fnd_message.set_name('WSH','WSH_WEB_LPN_LABEL');
   l_lpn_label := fnd_message.get;

   fnd_message.set_name('WSH','WSH_WEB_ENCLOSES_LABEL');
   l_encloses_label := fnd_message.get;

   x_num_of_packages := 0;
   x_container_contents := NULL;

   OPEN c_get_container_lpn(p_master_container_id);
   FETCH c_get_container_lpn INTO l_master_container_lpn,
     l_container_type_code,
     l_container_description,
     l_container_inventory_item_id,
     l_data_container_gross_weight,
     l_data_cont_uom_weight_code,
     l_data_container_volume,
     l_data_cont_uom_volume_code;
   CLOSE c_get_container_lpn;

   -- Bug# 3306781
   IF l_container_inventory_item_id IS NOT NULL THEN
      OPEN c_get_item_desc(l_container_inventory_item_id,p_organization_id);
      FETCH c_get_item_desc INTO l_container_description;
      CLOSE c_get_item_desc;
   END IF;

   OPEN c_get_master_container_items(p_master_container_id);
   l_contents_count := 0;
   LOOP
      FETCH c_get_master_container_items INTO l_item_description,
	l_item_inventory_item_id,
	l_hazard_class_id,
	l_shipped_quantity,
	l_requested_quantity_uom,
	l_item_class;
      IF (c_get_master_container_items%FOUND) THEN
	 IF l_item_class IS NOT NULL THEN

	    x_data_item_classification := (x_data_item_classification ||
					   ' ' ||
					   l_item_class);

	    x_data_item_classification
	      := concat_eol2(x_data_item_classification, p_output_mode);

	 END IF;

	 IF (l_contents_count = 0 AND x_container_contents IS NOT NULL) THEN
	    l_container_description := encode_desc(p_description_mode,
						   p_organization_id,
						   l_container_inventory_item_id,
						   l_container_description);

	    x_container_contents := (x_container_contents ||
				     l_container_type_code ||
				     ' ' ||
				     l_container_description);
	 END IF;

	 l_item_description := encode_desc(p_description_mode,
					   p_organization_id,
					   l_item_inventory_item_id,
					   l_item_description);

	 x_container_contents := (x_container_contents ||
				  l_contains_label || ' ' ||
				  l_shipped_quantity ||
				  ' ' ||
				  l_requested_quantity_uom ||
				  ' ' || l_of_label || ' ' ||
				  l_item_description);

	 x_container_contents
	   := concat_eol2(x_container_contents, p_output_mode);

	 IF l_hazard_class_id IS NOT NULL THEN
            --Bug 4020301 : If item is hazardous, then hazard_code should
            --should be 'X' which will get printed in the HM field in
            --BOL report.
	    -- x_hazard_code := (x_hazard_code || ' ' || l_hazard_class_id);

              x_hazard_code := 'X';
	 END IF;

	 l_contents_count := l_contents_count + 1;
      END IF;

      IF (c_get_master_container_items%NOTFOUND) THEN
	 EXIT;
      END IF;

   END LOOP;
   CLOSE c_get_master_container_items;

   IF (l_contents_count > 0) THEN
      NULL;
    ELSIF (l_contents_count = 0) THEN
      NULL;
   END IF;

   --
   -- Get any subcontainers of this master container
   --

   OPEN c_get_inner_containers(p_master_container_id);
   l_sub_containers_count := 0;
   LOOP
      FETCH  c_get_inner_containers INTO l_sub_container_id;
      EXIT WHEN c_get_inner_containers%NOTFOUND;
      l_sub_containers_count := l_sub_containers_count + 1;
      --
      -- a subcontainer exists get the LPN#
      --
      OPEN c_get_container_lpn(l_sub_container_id);
      FETCH c_get_container_lpn INTO l_sub_container_lpn,
	l_container_type_code,
	l_container_description,
	l_container_inventory_item_id,
	l_data_sub_weight,
	l_data_sub_weight_uom,
	l_data_sub_volume,
	l_data_sub_volume_uom;

      IF (c_get_container_lpn%FOUND) THEN
	 l_container_description := encode_desc(p_description_mode,
						p_organization_id,
						l_container_inventory_item_id,
						l_container_description);

	 x_container_contents :=
	   (x_container_contents ||
	    l_lpn_label ||
	    ' ' ||
	    l_sub_container_lpn||' '||
	    l_container_type_code||' '||
	    l_container_description);

	 x_container_contents
	   := concat_eol(x_container_contents, p_output_mode);

	 --
	 -- Check if there are any items in the sub container
	 --
	 OPEN c_get_container_items(l_sub_container_id);
	 l_sub_contents_count := 0;
	 LOOP
	    FETCH c_get_container_items INTO l_item_description,
	      l_item_inventory_item_id,
	      l_hazard_class_id,
	      l_shipped_quantity,
	      l_requested_quantity_uom,
	      l_item_class;

	    IF (c_get_container_items%FOUND) THEN
	       l_item_description := encode_desc(p_description_mode,
						 p_organization_id,
						 l_item_inventory_item_id,
						 l_item_description);

	       x_container_contents := (x_container_contents ||
					--' ' ||
					l_contains_label ||
					' ' ||
					l_shipped_quantity ||
					' ' ||
					l_requested_quantity_uom ||
					' ' ||
					l_of_label ||
					' ' ||
					l_item_description);

	       x_container_contents
		 := concat_eol2(x_container_contents, p_output_mode);

	       IF l_item_class IS NOT NULL THEN
		  x_data_item_classification
		    := concat_eol(x_data_item_classification, p_output_mode);

		  x_data_item_classification := (x_data_item_classification||
						 ' '||
						 l_item_class);

		  x_data_item_classification
		    := concat_eol2(x_data_item_classification, p_output_mode);
	       END IF;

	       IF l_hazard_class_id IS NOT NULL THEN
                 --Bug 4020301 : If item is hazardous, then hazard_code should
                 --should be 'X' which will get printed in the HM field in
                 --BOL report.
	         --x_hazard_code := (x_hazard_code || ' ' || l_hazard_class_id);

                 x_hazard_code := 'X';
	       END IF;

	       l_sub_contents_count := l_sub_contents_count + 1;
	    END IF;

	    IF (c_get_container_items%NOTFOUND) THEN
	       EXIT;
	    END IF;

	 END LOOP;
	 CLOSE c_get_container_items;


	 IF (l_sub_contents_count > 0) THEN
	    NULL;
	  ELSIF (l_sub_contents_count = 0) THEN
	    x_container_contents := (x_container_contents
				     ||' NO SUB CONTAINER CONTENTS');
	    NULL;
	 END IF;

	 --
	 -- Check if this container contains other containers
	 --
	 OPEN c_get_sub_containers(l_sub_container_id);
	 l_enclosed_count := 0;
	 LOOP
	    FETCH c_get_sub_containers INTO l_check_sub_containers;
	    IF (c_get_sub_containers%FOUND) THEN
	       OPEN c_get_enclosed_containers (l_check_sub_containers);
	       LOOP
		  FETCH c_get_enclosed_containers INTO l_enclosed_lpn;
		  EXIT WHEN c_get_enclosed_containers%NOTFOUND;
		  IF c_get_enclosed_containers%FOUND THEN
		     l_enclosed_count := l_enclosed_count+1;
		     l_enclosed_list := (l_enclosed_list
					 ||' '||l_lpn_label
					 ||' '||l_enclosed_lpn);
		  END IF;
	       END LOOP;
	       CLOSE c_get_enclosed_containers;

	     ELSIF (c_get_sub_containers%NOTFOUND) THEN
		     IF (l_enclosed_count > 0) THEN
			x_container_contents := (x_container_contents||
						 l_lpn_label||' '||
						 l_sub_container_lpn||' '||
						 l_encloses_label||' '||
						 l_enclosed_list);

			x_container_contents
			  := concat_eol2(x_container_contents, p_output_mode);

			l_enclosed_list := NULL;

			x_data_item_classification
			  := concat_eol2(x_data_item_classification, p_output_mode);

		     END IF;
		     EXIT;
	    END IF;
	 END LOOP;
	 CLOSE c_get_sub_containers;

       ELSIF (c_get_container_lpn%NOTFOUND) THEN
	       x_container_contents := (x_container_contents
					||' NO LPN --- ERROR --- ');

       END IF;
       CLOSE c_get_container_lpn;

    END LOOP; -- c_get_inner_containers;
    CLOSE c_get_inner_containers;

    x_num_of_packages := l_enclosed_count + l_sub_containers_count;

    x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

--
-- Debug Statements
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'X_NUM_OF_PACKAGES',x_num_of_packages);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
					--
EXCEPTION
    WHEN others THEN
        FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
        x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
        WSH_UTIL_CORE.add_message (x_return_status);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END get_master_container_contents;

END WSH_BOLS_UTIL_PKG;


/
