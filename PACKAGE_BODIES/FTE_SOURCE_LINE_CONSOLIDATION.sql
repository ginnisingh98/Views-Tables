--------------------------------------------------------
--  DDL for Package Body FTE_SOURCE_LINE_CONSOLIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_SOURCE_LINE_CONSOLIDATION" AS
/* $Header: FTELNCNB.pls 120.2 2008/01/11 08:50:00 sankarun ship $ */

  g_weight_uom_tab uom_tab; -- will cache default weight uom for an org
  g_volume_uom_tab uom_tab; -- will cache default volume uom for an org

  g_hash_base	NUMBER := 1;
  g_hash_size	NUMBER := power(2, 25); -- do ours need to be so big?  how large?

  TYPE source_header_hash_rec IS RECORD
  (con_id NUMBER,
   hash_string VARCHAR2(1000));

  TYPE source_header_hash_tab	IS TABLE OF source_header_hash_rec
  INDEX BY BINARY_INTEGER;

  g_source_header_hash_tab	source_header_hash_tab;

  -- cache the weight and volume uom for orgs
  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_SOURCE_LINE_CONSOLIDATION';
  --

  -- Pack J OM-DisplayChoices
  CURSOR c_get_generic_carrier_flag (c_ship_method_code VARCHAR2) IS
  SELECT a.generic_flag
  FROM   wsh_carriers a, wsh_carrier_services b
  WHERE a.carrier_id = b.carrier_id
    AND b.ship_method_code = c_ship_method_code;

  PROCEDURE get_org_default_uoms(p_org_id		IN	NUMBER,
				 x_weight_uom_code	OUT NOCOPY	VARCHAR2,
				 x_volume_uom_code	OUT NOCOPY	VARCHAR2,
				 x_return_status	OUT NOCOPY	VARCHAR2) IS

  l_weight_uom_code	VARCHAR2(3);
  l_volume_uom_code	VARCHAR2(3);
  l_status		VARCHAR(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ORG_DEFAULT_UOMS';
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
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_ORG_ID',P_ORG_ID);
	END IF;
	--
	l_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (g_weight_uom_tab.EXISTS(p_org_id)) THEN
	    l_weight_uom_code := g_weight_uom_tab(p_org_id);
	END IF;

	IF (g_volume_uom_tab.EXISTS(p_org_id)) THEN
	    l_volume_uom_code := g_volume_uom_tab(p_org_id);
	END IF;

	IF (l_weight_uom_code is null OR l_volume_uom_code is null) THEN

	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.GET_DEFAULT_UOMS',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    WSH_WV_UTILS.get_default_uoms(p_org_id,
				      	  l_weight_uom_code,
				      	  l_volume_uom_code,
				      	  l_status);

	    IF (l_status is null) THEN
		l_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	    END IF;

	    g_weight_uom_tab(p_org_id) := l_weight_uom_code;
	    g_volume_uom_tab(p_org_id) := l_volume_uom_code;

	END IF;

	x_weight_uom_code := l_weight_uom_code;
	x_volume_uom_code := l_volume_uom_code;
	x_return_status := l_status;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'Returning org default uoms:');
    WSH_DEBUG_SV.log(l_module_name, 'weight_uom_code', x_weight_uom_code);
    WSH_DEBUG_SV.log(l_module_name, 'volume_uom_code', x_volume_uom_code);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END get_org_default_uoms;


  --
  -- PROCEDURE Create_Hash
  -- ---------------------
  -- Creates a hash value for a record passed in.
  -- An attribute is part of the hash string only if it is part of the grouping attributes
  --
  --
  -- CHANGE LOG
  -- ----------
  -- [2003/02/05][PACK I][ABLUNDEL][BUG:2763944]
  -- Added arrival_date to the hash string as for this bug the
  -- some line could have been scheduled previously and got one arrival date
  -- then all lines are scheduled, giving the previously unscheduled lines
  -- a different arrival date:
  -- added line "to_char(trunc(p_source_line_rec.arrival_date)) || '-' ||"
  --
  --

  --
  -- Create Hash needs to be changed to return l_group_by_flags
  -- Only if flag is populated we should propogate the value to header level
  --
  -- R12 Sachin
  PROCEDURE Create_Hash(p_source_line_rec	IN		FTE_PROCESS_REQUESTS.fte_source_line_rec,
			p_action		IN		VARCHAR2,
			x_hash_value		OUT NOCOPY	NUMBER,
			x_hash_string		OUT NOCOPY	VARCHAR2,
			x_group_by_flags	OUT NOCOPY	WSH_DELIVERY_AUTOCREATE.group_by_flags_rec_type) IS

  l_hash_string	VARCHAR2(1000) := NULL;
  l_hash_value	NUMBER;

  l_group_by_flags	WSH_DELIVERY_AUTOCREATE.group_by_flags_rec_type;
  l_status	VARCHAR2(10);

  l_con_hash_rec	source_header_hash_rec;

  l_counter	PLS_INTEGER;
  l_no_hash	BOOLEAN := TRUE;
  l_generic_carrier    	VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_HASH';
--
  BEGIN

	--
	-- Get grouping attributes for this org, but ignoring ship method, carrier
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_ACTION',P_ACTION);
	END IF;
	--
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_AUTOCREATE.GET_GROUP_BY_ATTR',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_DELIVERY_AUTOCREATE.Get_Group_By_Attr(p_organization_id => p_source_line_rec.ship_from_org_id,
						  x_group_by_flags => l_group_by_flags,
						  x_return_status => l_status);

        --
        -- [2003/02/05][I][ABLUNDEL][BUG:2763944]
        -- Added arrival_date to the hash string as for this bug the
        -- some line could have been scheduled previously and got one arrival date
        -- then all lines are scheduled, giving the previously unscheduled lines
        -- a different arrival date:
        --
        -- added line "to_char(trunc(p_source_line_rec.arrival_date)) || '-' ||"
        --

        --
	-- these 5 inputs are always in the grouping rule
        --
	l_hash_string := to_char(p_source_line_rec.ship_from_org_id) || '-' ||
			 to_char(p_source_line_rec.ship_to_location_id) || '-' ||
			 to_char(trunc(p_source_line_rec.ship_date)) || '-' ||
                         to_char(trunc(p_source_line_rec.arrival_date)) || '-' ||
			 p_source_line_rec.scheduled_flag;

	IF (l_group_by_flags.customer = 'Y') THEN
            l_hash_string  := l_hash_string ||'-'||to_char(p_source_line_rec.customer_id);
	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name, 'Using customer in grouping rule');
	    END IF;
        END IF;

	IF (l_group_by_flags.intmed = 'Y') THEN
            l_hash_string  := l_hash_string ||'-'||to_char(p_source_line_rec.intmed_ship_to_loc_id);
	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name, 'Using intermediate ship to in grouping rule');
	    END IF;
        END IF;

	IF (l_group_by_flags.fob = 'Y') THEN
            l_hash_string  := l_hash_string ||'-'||p_source_line_rec.fob_code;
	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name, 'Using fob in grouping rule');
	    END IF;
        END IF;

	IF (l_group_by_flags.freight_terms = 'Y') THEN
            l_hash_string  := l_hash_string ||'-'||p_source_line_rec.freight_terms;
	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name, 'Using freight terms in grouping rule');
	    END IF;
        END IF;

	IF (p_action = 'R' AND l_group_by_flags.ship_method = 'Y') THEN
            l_hash_string  := l_hash_string ||'-'||p_source_line_rec.ship_method_code;
	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name, 'Using ship method in grouping rule');
	    END IF;
        END IF;

	-- Pack J OM-DisplayChoices
	IF (p_action = 'GET_GROUP') THEN

	  IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name, 'for GET_GROUP action...');
	    WSH_DEBUG_SV.logmsg(l_module_name, 'ship_method_code='||p_source_line_rec.ship_method_code);
	  END IF;

	  OPEN c_get_generic_carrier_flag(p_source_line_rec.ship_method_code);
  	  FETCH c_get_generic_carrier_flag INTO l_generic_carrier;
  	  CLOSE c_get_generic_carrier_flag;

	  IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name, 'l_generic_carrier='||l_generic_carrier);
	  END IF;

	  IF l_generic_carrier = 'Y' THEN
            l_hash_string  := l_hash_string ||'-'||p_source_line_rec.ship_method_code;
	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name, 'generic carrier, Using ship method in grouping rule');
	    END IF;
	  ELSIF p_source_line_rec.override_ship_method = 'Y' THEN
	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name, 'not Using ship method in grouping rule');
	    END IF;
	  ELSE
            l_hash_string  := l_hash_string ||'-'||p_source_line_rec.ship_method_code;
	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name, 'override_ship_method=N, Using ship method in grouping rule');
	    END IF;
	  END IF;
	END IF;

	-- get hash value, check to make sure no hash collision
	l_counter := 0;

	WHILE (l_no_hash) LOOP

	    l_hash_value := dbms_utility.get_hash_value(name => l_hash_string,
						    	base => g_hash_base,
						    	hash_size => g_hash_size + l_counter);

	    IF (g_source_header_hash_tab.EXISTS(l_hash_value) = FALSE) THEN
		l_no_hash := FALSE;
	    ELSE
		l_con_hash_rec := g_source_header_hash_tab(l_hash_value);
		IF (l_con_hash_rec.hash_string = l_hash_string) THEN
		    l_no_hash := FALSE;
		ELSE -- hash collision, same hash value, different hash string
		    l_counter := l_counter + 1;
		END IF;
	    END IF;

	END LOOP;

	x_hash_value	 := l_hash_value;
	x_hash_string	 := l_hash_string;
	x_group_by_flags := l_group_by_flags;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name, 'hash_string', l_hash_string);
	    WSH_DEBUG_SV.log(l_module_name, 'hash_value', l_hash_value);
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
  END Create_Hash;

  -- main procedure that will take in a table of source line inputs
  -- and consolidate them based on grouping rules and sum the weights and volume
  -- across lines and return back the consolidations
  PROCEDURE Consolidate_Lines(p_source_line_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_tab,
			      p_source_header_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_header_tab,
			      p_action			IN		VARCHAR2,
		       	      x_return_status		OUT NOCOPY	VARCHAR2,
		       	      x_msg_count		OUT NOCOPY	NUMBER,
			      x_msg_data		OUT NOCOPY	VARCHAR2) IS

  l_counter	PLS_INTEGER;
  l_con_id_seq	PLS_INTEGER := 1;
  l_con_id	PLS_INTEGER;

  l_source_header_rec		FTE_PROCESS_REQUESTS.fte_source_header_rec;
  l_hash_string			VARCHAR2(1000);
  l_con_hash_rec		source_header_hash_rec;

  l_weight_uom_code	VARCHAR2(3);
  l_volume_uom_code	VARCHAR2(3);
  l_status		VARCHAR2(1);
  l_msg_count		PLS_INTEGER := 0;

  l_converted_weight	NUMBER;
  l_converted_volume	NUMBER;
--  l_ship_from_loc_id	NUMBER;
  l_customer_site_id	NUMBER;
  l_hash_value		NUMBER;
  l_generic_carrier    	VARCHAR2(1);
  l_override_ship_method BOOLEAN;

  l_group_by_flags	WSH_DELIVERY_AUTOCREATE.group_by_flags_rec_type;

  --bug 6707893: Added p_inv_id parameter in WSH_WV_UTILS.convert_uom called in the cursor
  CURSOR get_converted_wv(p_org_id NUMBER, p_inv_id NUMBER, p_source_qty NUMBER,
			  p_source_qty_uom VARCHAR2, p_weight_uom VARCHAR2,
			  p_volume_uom VARCHAR2) IS
  SELECT  WSH_WV_UTILS.convert_uom(weight_uom_code,
				   p_weight_uom,
				   nvl(unit_weight, 0) * WSH_WV_UTILS.convert_uom(p_source_qty_uom,
										  primary_uom_code,
										  p_source_qty, p_inv_id), p_inv_id),
	  WSH_WV_UTILS.convert_uom(volume_uom_code,
				   p_volume_uom,
				   nvl(unit_volume, 0) * WSH_WV_UTILS.convert_uom(p_source_qty_uom,
										  primary_uom_code,
										  p_source_qty,p_inv_id),p_inv_id)
  FROM  mtl_system_items
  WHERE organization_id = p_org_id
	AND inventory_item_id = p_inv_id;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONSOLIDATE_LINES';
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
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_ACTION',P_ACTION);
	END IF;
	--

	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'loop through p_source_line_tab',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	g_source_header_hash_tab.DELETE;

	FOR l_counter IN p_source_line_tab.FIRST..p_source_line_tab.LAST LOOP

	  IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'l_counter = '||l_counter,WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;

	    -- reset variables
	    l_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	    l_weight_uom_code := NULL;
	    l_volume_uom_code := NULL;
	    l_converted_weight := NULL;
	    l_converted_volume := NULL;

	    -- get default base uoms for weight and volume
	    get_org_default_uoms(p_source_line_tab(l_counter).ship_from_org_id,
				 l_weight_uom_code,
				 l_volume_uom_code,
				 l_status);

	    IF (l_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		p_source_line_tab(l_counter).status := l_status;
		FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NO_DEFAULT_UOM');
		p_source_line_tab(l_counter).message_data := FND_MESSAGE.GET;
	    END IF;

	    -- calculated weight and volume for this inventory item against requested quantity
	    IF (l_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

		OPEN get_converted_wv(p_source_line_tab(l_counter).ship_from_org_id,
			      	      p_source_line_tab(l_counter).inventory_item_id,
			      	      p_source_line_tab(l_counter).source_quantity,
			      	      p_source_line_tab(l_counter).source_quantity_uom,
			      	      l_weight_uom_code,
			      	      l_volume_uom_code);

	    	FETCH get_converted_wv INTO l_converted_weight, l_converted_volume;
	    	CLOSE get_converted_wv;

	    	-- obtain ship-from location id from ship-from org id
		IF (p_source_line_tab(l_counter).ship_from_location_id is null) THEN
	    	    --
	    	    -- Debug Statements
	    	    --
	    	    IF l_debug_on THEN
	    	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_LOCATION_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
	    	    END IF;
	    	    --
	    	    WSH_UTIL_CORE.Get_Location_Id('ORG',
					      	  p_source_line_tab(l_counter).ship_from_org_id,
					      	  p_source_line_tab(l_counter).ship_from_location_id,
					      	  l_status);
		END IF;

		IF (l_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		    p_source_line_tab(l_counter).status := l_status;
		    FND_MESSAGE.SET_NAME('WSH', 'WSH_ORG_LOCATION_UNDEFINED');
		    p_source_line_tab(l_counter).message_data := FND_MESSAGE.GET;
		END IF;

		-- obtain ship-to location id from ship-to cust site id (use 'CUSTOMER SITE')
		IF (p_source_line_tab(l_counter).ship_to_location_id is null) THEN
	    	    --
	    	    -- Debug Statements
	    	    --
	    	    IF l_debug_on THEN
	    	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_LOCATION_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
	    	    END IF;
	    	    --
	    	    WSH_UTIL_CORE.Get_Location_Id('CUSTOMER SITE',
					      	  p_source_line_tab(l_counter).ship_to_site_id,
					      	  p_source_line_tab(l_counter).ship_to_location_id,
					      	  l_status);
		END IF;

		IF (l_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		    p_source_line_tab(l_counter).status := l_status;
		    FND_MESSAGE.SET_NAME('WSH', 'WSH_SITE_LOCATION_UNDEFINED');
		    p_source_line_tab(l_counter).message_data := FND_MESSAGE.GET;
		END IF;

		-- obtain intermediate ship-to location id from intermediate ship-to org id (use 'CUSTOMER SITE')
		IF (p_source_line_tab(l_counter).intmed_ship_to_loc_id is null AND
		    p_source_line_tab(l_counter).intmed_ship_to_site_id is not null) THEN
	    	    --
	    	    -- Debug Statements
	    	    --
	    	    IF l_debug_on THEN
	    	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_LOCATION_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
	    	    END IF;
	    	    --
	    	    WSH_UTIL_CORE.Get_Location_Id('CUSTOMER SITE',
					      	  p_source_line_tab(l_counter).intmed_ship_to_site_id,
					      	  p_source_line_tab(l_counter).intmed_ship_to_loc_id,
					      	  l_status);
		END IF;

		IF (l_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		    p_source_line_tab(l_counter).status := l_status;
		    FND_MESSAGE.SET_NAME('WSH', 'WSH_SITE_LOCATION_UNDEFINED');
		    p_source_line_tab(l_counter).message_data := FND_MESSAGE.GET;
		END IF;

		IF (l_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	    	    -- get hash value for this source line
	    	    Create_Hash(p_source_line_rec => p_source_line_tab(l_counter),
				p_action	  => p_action,
		      	    	x_hash_value      => l_hash_value,
			    	x_hash_string     => l_hash_string,
				x_group_by_flags  => l_group_by_flags);

	    	    -- check if consolidation is previously created
	    	    IF (g_source_header_hash_tab.EXISTS(l_hash_value)) THEN

		    	l_con_id := g_source_header_hash_tab(l_hash_value).con_id;
		    	l_source_header_rec := p_source_header_tab(l_con_id);

		    	-- add weight and volume to existing consolidation
		    	l_source_header_rec.total_weight := l_source_header_rec.total_weight + l_converted_weight;
		    	l_source_header_rec.total_volume := l_source_header_rec.total_volume + l_converted_volume;

			l_override_ship_method := false;

			IF (p_action = 'GET_GROUP') THEN

	    		  IF l_debug_on THEN
	    			WSH_DEBUG_SV.logmsg(l_module_name,'for GET_GROUP action...',WSH_DEBUG_SV.C_PROC_LEVEL);
	    			WSH_DEBUG_SV.logmsg(l_module_name,'source line ship_method_code='||p_source_line_tab(l_counter).ship_method_code,WSH_DEBUG_SV.C_PROC_LEVEL);
	    		        WSH_DEBUG_SV.logmsg(l_module_name,'source line override_ship_method='||p_source_line_tab(l_counter).override_ship_method,WSH_DEBUG_SV.C_PROC_LEVEL);
	    		  END IF;

  	  		  OPEN c_get_generic_carrier_flag(p_source_line_tab(l_counter).ship_method_code);
		  	  FETCH c_get_generic_carrier_flag INTO l_generic_carrier;
		  	  CLOSE c_get_generic_carrier_flag;

	    		  IF l_debug_on THEN
	    			WSH_DEBUG_SV.logmsg(l_module_name,'l_generic_carrier='||l_generic_carrier,WSH_DEBUG_SV.C_PROC_LEVEL);
	    		  END IF;

			  IF (l_generic_carrier is null OR l_generic_carrier <> 'Y')
			    AND p_source_line_tab(l_counter).override_ship_method = 'Y' THEN
			    l_override_ship_method := true;
			  END IF;

			END IF; -- p_action = 'GET_GROUP'

			IF l_override_ship_method THEN

			  IF p_source_line_tab(l_counter).scheduled_flag = 'Y'
			     AND p_source_line_tab(l_counter).delivery_lead_time > 0 THEN

			    IF l_source_header_rec.scheduled_flag is NULL
			     OR l_source_header_rec.delivery_lead_time is NULL
			     OR l_source_header_rec.delivery_lead_time <= 0 THEN

				l_source_header_rec.delivery_lead_time	:= p_source_line_tab(l_counter).delivery_lead_time;
				l_source_header_rec.scheduled_flag	:= p_source_line_tab(l_counter).scheduled_flag;

				IF l_debug_on THEN
				    WSH_DEBUG_SV.logmsg(l_module_name, 'override delivery lead time to '||p_source_line_tab(l_counter).delivery_lead_time);
				END IF;
			    ELSE
			      IF p_source_line_tab(l_counter).delivery_lead_time
				 <  l_source_header_rec.delivery_lead_time THEN
				l_source_header_rec.delivery_lead_time	:=
				  p_source_line_tab(l_counter).delivery_lead_time;
				  IF l_debug_on THEN
				    WSH_DEBUG_SV.logmsg(l_module_name, 'override delivery lead time to '||p_source_line_tab(l_counter).delivery_lead_time);
				  END IF;
			    END IF;
			  END IF;
			END IF;
			END IF; -- l_override_ship_method true

			p_source_header_tab(l_con_id) := l_source_header_rec;

	    	    -- none was found, create new entry
	    	    ELSE

		      l_con_id := l_con_id_seq; -- obtain consolidation id

	    	         IF l_debug_on THEN
	    			WSH_DEBUG_SV.logmsg(l_module_name,'create new group l_con_id = '||l_con_id,WSH_DEBUG_SV.C_PROC_LEVEL);
	    		 END IF;

		   	 -- copy input attributes to the consolidation line
		    	l_source_header_rec.consolidation_id	  := l_con_id;
		    	l_source_header_rec.ship_from_org_id	  := p_source_line_tab(l_counter).ship_from_org_id;
		    	l_source_header_rec.ship_from_location_id := p_source_line_tab(l_counter).ship_from_location_id;
			l_source_header_rec.ship_to_site_id 	  := p_source_line_tab(l_counter).ship_to_site_id;
		    	l_source_header_rec.ship_to_location_id	  := p_source_line_tab(l_counter).ship_to_location_id;

			--
			-- if (CUSTOMER) is in the grouping criteria then
			--	copy it
			-- Else
			--	keep it null;
			IF (l_group_by_flags.customer ='Y') THEN
				l_source_header_rec.customer_id		  := p_source_line_tab(l_counter).customer_id;
			END IF;

			l_source_header_rec.ship_date		  := p_source_line_tab(l_counter).ship_date;
			l_source_header_rec.arrival_date	  := p_source_line_tab(l_counter).arrival_date;
			l_source_header_rec.delivery_lead_time	  := p_source_line_tab(l_counter).delivery_lead_time;
			l_source_header_rec.currency		  := p_source_line_tab(l_counter).currency;
			l_source_header_rec.currency_conversion_type	:= p_source_line_tab(l_counter).currency_conversion_type;

			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name, 'group initial delivery lead time '||p_source_line_tab(l_counter).delivery_lead_time);
			END IF;
			l_source_header_rec.scheduled_flag	:= p_source_line_tab(l_counter).scheduled_flag;
		    	l_source_header_rec.total_weight	:= l_converted_weight;
		    	l_source_header_rec.weight_uom_code	:= l_weight_uom_code;
		    	l_source_header_rec.total_volume	:= l_converted_volume;
		    	l_source_header_rec.volume_uom_code	:= l_volume_uom_code;

			--
			-- if (FREIGHT_TERM) is in the grouping criteria then
			--	copy it
			-- Else
			--	keep it null;
			IF (l_group_by_flags.freight_terms ='Y') THEN
				l_source_header_rec.freight_terms	:= p_source_line_tab(l_counter).freight_terms;
			END IF;

			--
			-- if (FOB CODE) is in the grouping criteria then
			--	copy it
			-- Else
			--	keep it null;
			--  R12 - Sachin
			IF (l_group_by_flags.fob ='Y') THEN
				l_source_header_rec.fob_code  := p_source_line_tab(l_counter).fob_code;
			END IF;

			IF (p_action = 'GET_GROUP') THEN
			  l_source_header_rec.enforce_lead_time	:= 'Y';
			ELSE
			  l_source_header_rec.enforce_lead_time	:= 'N';
			END IF;

			l_override_ship_method := false;

			IF (p_action = 'GET_GROUP') THEN

	    			IF l_debug_on THEN
	    				WSH_DEBUG_SV.logmsg(l_module_name,'for GET_GROUP action...',WSH_DEBUG_SV.C_PROC_LEVEL);
	    				WSH_DEBUG_SV.logmsg(l_module_name,'source line ship_method_code='||p_source_line_tab(l_counter).ship_method_code,WSH_DEBUG_SV.C_PROC_LEVEL);
			    	        WSH_DEBUG_SV.logmsg(l_module_name,'source line override_ship_method='||p_source_line_tab(l_counter).override_ship_method,WSH_DEBUG_SV.C_PROC_LEVEL);
	    			END IF;

	 			OPEN c_get_generic_carrier_flag(p_source_line_tab(l_counter).ship_method_code);
		  	        FETCH c_get_generic_carrier_flag INTO l_generic_carrier;
		  	        CLOSE c_get_generic_carrier_flag;

	    	                IF l_debug_on THEN
			    	        WSH_DEBUG_SV.logmsg(l_module_name,'l_generic_carrier='||l_generic_carrier,WSH_DEBUG_SV.C_PROC_LEVEL);
	    		        END IF;

				IF (l_generic_carrier is null OR l_generic_carrier <> 'Y')
				    AND p_source_line_tab(l_counter).override_ship_method = 'Y' THEN
				    l_override_ship_method := true;
		   	        END IF;

			 END IF; -- p_action = 'GET_GROUP'

			 IF l_override_ship_method THEN

			  IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name, 'set group ship method null');
			  END IF;
 			  l_source_header_rec.ship_method_code	:= null;
			  l_source_header_rec.carrier_id	:= null;
			  l_source_header_rec.service_level	:= null;
			  l_source_header_rec.mode_of_transport	:= null;

			ELSE

			  IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name, 'set group ship method as source line ship method');
			  END IF;
			  l_source_header_rec.ship_method_code	:= p_source_line_tab(l_counter).ship_method_code;
			  l_source_header_rec.carrier_id	:= p_source_line_tab(l_counter).carrier_id;
			  l_source_header_rec.service_level	:= p_source_line_tab(l_counter).service_level;
			  l_source_header_rec.mode_of_transport	:= p_source_line_tab(l_counter).mode_of_transport;

			END IF;

	            	l_con_hash_rec.con_id := l_con_id;
		    	l_con_hash_rec.hash_string := l_hash_string;
		    	g_source_header_hash_tab(l_hash_value) := l_con_hash_rec;
		    	p_source_header_tab(l_con_id) := l_source_header_rec;

		    	l_con_id_seq := l_con_id_seq + 1; -- increment for next consolidation

	        	END IF;

		END IF; -- ending if successful after getting loc id from org id

	    END IF; -- ending if successful after getting default uoms

	    -- copy calculated attributes to source line rec e.g. weight/volume/consolidation id
	    p_source_line_tab(l_counter).weight			:= l_converted_weight;
	    p_source_line_tab(l_counter).weight_uom_code	:= l_weight_uom_code;
	    p_source_line_tab(l_counter).volume			:= l_converted_volume;
	    p_source_line_tab(l_counter).volume_uom_code	:= l_volume_uom_code;
	    p_source_line_tab(l_counter).freight_rate		:= null;
	    p_source_line_tab(l_counter).freight_rate_currency 	:= null;
	    p_source_line_tab(l_counter).status			:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	    p_source_line_tab(l_counter).message_data		:= null;
	    p_source_line_tab(l_counter).consolidation_id	:= l_con_id;

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
    WHEN OTHERS THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	x_msg_data := SQLERRM;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
        RAISE;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Consolidate_Lines;

END FTE_SOURCE_LINE_CONSOLIDATION;

/
