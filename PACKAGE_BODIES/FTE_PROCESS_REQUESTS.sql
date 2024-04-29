--------------------------------------------------------
--  DDL for Package Body FTE_PROCESS_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_PROCESS_REQUESTS" AS
/* $Header: FTEPRREB.pls 120.4 2007/01/03 19:46:57 parkhj noship $ */

Type TableVarchar2000 IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_PROCESS_REQUESTS';
--

g_object_id_tab       WSH_NEW_DELIVERY_ACTIONS.TableNumbers;

-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                GET_CUSTOMER_SITE				      --
-- TYPE:                PROCEDURE                                             --
--                                                                            --
-- PARAMETERS (IN):     p_consolidation_id          IN	NUMBER                --
--			  p_source_line_tab	      IN		      --
--                                FTE_PROCESS_REQUESTS.fte_source_line_tab    --
--                      x_customer_site_id        OUT NOCOPY		      --
--								NUMBER	      --
--                      x_return_status           OUT NOCOPY    VARCHAR2      --
--                                                                            --
-- DESCRIPTION:         This procedure returns  customer site id, for the     --
--                      given pseudo delivery(p_consolidation_id).            --
-- -------------------------------------------------------------------------- --

PROCEDURE   get_customer_site( p_consolidation_id	IN		NUMBER,
			       p_source_line_tab	IN 		FTE_PROCESS_REQUESTS.fte_source_line_tab,
			       x_customer_site_id	OUT NOCOPY 	NUMBER,
			       x_return_status		OUT NOCOPY      VARCHAR2)
IS

itr			NUMBER;
cust_site_id		NUMBER;
no_ship_to_site	        EXCEPTION;
mult_ship_to_site	EXCEPTION;

l_debug_on		CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name		CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CUSTOMER_SITE';

BEGIN
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
        IF l_debug_on THEN
	       wsh_debug_sv.push (l_module_name);
        END IF;
	--
	cust_site_id	:= -1;

	--
	-- Get ship_to_site_id for consolidation id. Loop over p_souce_line_tab.
	-- If multiple sites are found then throw error message.
	--
	itr := p_source_line_tab.FIRST;

	IF (itr IS NOT NULL) THEN
	LOOP
	    IF (p_source_line_tab(itr).consolidation_id = p_consolidation_id AND
	        p_source_line_tab(itr).ship_to_site_id IS NOT NULL)
	    THEN
	       	  IF (cust_site_id = -1) THEN
		     cust_site_id := p_source_line_tab(itr).ship_to_site_id;
	          ELSIF (cust_site_id <> p_source_line_tab(itr).ship_to_site_id) THEN
		     RAISE MULT_SHIP_TO_SITE;
		  END IF;
	    END IF;
  	    EXIT WHEN itr = p_source_line_tab.LAST;
	    itr := p_source_line_tab.NEXT(itr);
	END LOOP;
	END IF;

	IF (cust_site_id = -1) THEN
	    RAISE NO_SHIP_TO_SITE;
	ELSE
	    x_customer_site_id := cust_site_id;
	END IF;
	--
	IF l_debug_on THEN
	       wsh_debug_sv.pop(l_module_name);
        END IF;
	--

EXCEPTION
WHEN NO_SHIP_TO_SITE THEN
	 -- Delivery is not assoociated with a site.
	 FND_MESSAGE.SET_NAME('WSH','WSH_PDLVY_NO_SITE');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 WSH_UTIL_CORE.add_message(x_return_status);
 	 IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
WHEN MULT_SHIP_TO_SITE THEN
	 -- Delivery is associated with multiple sites
	 FND_MESSAGE.SET_NAME('WSH','WSH_PDLVY_MULT_SITE');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 WSH_UTIL_CORE.add_message(x_return_status);
	 IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	 END IF;

WHEN OTHERS THEN
    WSH_UTIL_CORE.default_handler('FTE_PROCESS_REQUEST.get_customer_site');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
END get_customer_site;

-- --------------------------------------------------------------------------  --
--                                                                             --
-- NAME:                GET_SHIP_TO_CUSTOMER				       --
-- TYPE:                PROCEDURE                                              --
--                                                                             --
-- PARAMETERS (IN):     p_dropoff_loc_id          IN		NUMBER         --
--			p_ship_to_site	          IN		NUMBER         --
--                      x_customer_id             OUT NOCOPY	NUMBER	       --
--                      x_return_status           OUT NOCOPY    VARCHAR2       --
--                                                                             --
-- DESCRIPTION:         This procedure returns  ship to customer using dropoff --
--                      location and ship to site.			       --
--			If dropoff location returns multiple customers then    --
--			use ship to site to determine the customer.	       --
-- --------------------------------------------------------------------------  --

PROCEDURE get_ship_to_customer(p_dropoff_loc_id      IN  NUMBER,
			       p_ship_to_site	     IN  NUMBER,
			       x_customer_id	     OUT NOCOPY NUMBER,
			       x_return_status	     OUT NOCOPY VARCHAR2)
IS


CURSOR c_get_shipto_cust_from_loc (p_location_id IN NUMBER) IS
SELECT hcas.cust_account_id
FROM   wsh_locations wl,
       hz_party_sites hps,
       hz_cust_acct_sites_all hcas
WHERE  wl.wsh_location_id = p_location_id
AND    wl.location_source_code = 'HZ'
AND    wl.source_location_id = hps.location_id
AND    hps.party_site_id = hcas.party_site_id;

CURSOR c_get_shipto_cust_from_site (p_site_id IN NUMBER) IS
SELECT distinct hcas.cust_account_id
FROM   hz_cust_site_uses_all hcsu,
       hz_cust_acct_sites_all hcas
WHERE  hcsu.cust_acct_site_id = hcas.cust_acct_site_id
AND    hcsu.site_use_id = p_site_id;

l_cust_tab		WSH_UTIL_CORE.ID_TAB_TYPE;
no_cust_for_loc		EXCEPTION;
mult_cust_for_loc	EXCEPTION;

l_debug_on		CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name		CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_SHIP_TO_CUSTOMER';

BEGIN
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
        IF l_debug_on THEN
	       wsh_debug_sv.push (l_module_name);
        END IF;
	--
	OPEN  c_get_shipto_cust_from_loc(p_dropoff_loc_id);
	FETCH c_get_shipto_cust_from_loc BULK COLLECT INTO l_cust_tab;
	CLOSE c_get_shipto_cust_from_loc;

	IF (l_cust_tab.COUNT=1) THEN
		x_customer_id := l_cust_tab(l_cust_tab.FIRST);
	ELSIF (l_cust_tab.COUNT = 0) THEN
		RAISE NO_CUST_FOR_LOC;
	ELSE
		OPEN   c_get_shipto_cust_from_site(p_ship_to_site);
		FETCH  c_get_shipto_cust_from_site BULK COLLECT INTO l_cust_tab;
		CLOSE  c_get_shipto_cust_from_site;

		IF (l_cust_tab.COUNT=1) THEN
			x_customer_id := l_cust_tab(l_cust_tab.FIRST);
		ELSIF (l_cust_tab.COUNT=0) THEN
			RAISE NO_CUST_FOR_LOC;
		ELSE
			RAISE MULT_CUST_FOR_LOC;
		END IF;
	END IF;
	--
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;
        --
EXCEPTION
WHEN NO_CUST_FOR_LOC THEN
  -- Location not associated with a customer.
  FND_MESSAGE.SET_NAME('WSH','WSH_CUST_NO_LOC');
  x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
  WSH_UTIL_CORE.add_message(x_return_status);
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;

WHEN MULT_CUST_FOR_LOC THEN
    -- Location  associated with a multiple customers.
   FND_MESSAGE.SET_NAME('WSH','WSH_CUST_MULT_LOC');
   x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
   WSH_UTIL_CORE.add_message(x_return_status);
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

WHEN OTHERS THEN
    WSH_UTIL_CORE.default_handler('FTE_PROCESS_REQUEST.get_ship_to_customer');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF (c_get_shipto_cust_from_loc%ISOPEN) THEN
	CLOSE c_get_shipto_cust_from_loc;
    END IF;

    IF (c_get_shipto_cust_from_site%ISOPEN) THEN
	CLOSE c_get_shipto_cust_from_site;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
END get_ship_to_customer;

  -- -------------------------------------------------------------------------- --
  --                                                                            --
  -- NAME:                FORMAT_CS_CALL					--
  -- TYPE:                PROCEDURE                                             --
  --                                                                            --
  -- PARAMETERS (IN):     p_source_header_tab          IN OUT NOCOPY            --
  --                               FTE_PROCESS_REQUESTS.fte_source_header_tab   --
  --			  p_source_line_tab	       IN OUT NOCOPY		--
  --                                FTE_PROCESS_REQUESTS.fte_source_line_tab    --
  --                      x_result_tab        OUT NOCOPY			--
  --                                 FTE_ACS_PKG.fte_cs_result_rec_type		--
  --                      x_return_message                OUT VARCHAR2          --
  --                      x_return_status                 OUT VARCHAR2          --
  --                                                                            --
  -- PARAMETERS (IN OUT): none                                                  --
  -- RETURN:              none                                                  --
  -- DESCRIPTION:         This procedure takes input of table of consolidated   --
  --                      line data that is formatted into a call to the        --
  --                      Carrier Selection Search Engine. After the return from--
  --                      the search engine, if any results where found a call  --
  --                      to get the ship method is made. Tables of result data --
  --                      and ship method codes are returned.                   --
  --                                                                            --
  -- CHANGE CONTROL LOG                                                         --
  -- ------------------                                                         --
  --                                                                            --
  -- DATE        VERSION  BY        BUG      DESCRIPTION                        --
  -- ----------  -------  --------  -------  ---------------------------------- --
  --							                        --
  --                                                                            --
  -- -------------------------------------------------------------------------- --
  PROCEDURE FORMAT_CS_CALL( p_source_header_tab         IN OUT NOCOPY FTE_PROCESS_REQUESTS.fte_source_header_tab,
			    p_source_line_tab		IN OUT NOCOPY FTE_PROCESS_REQUESTS.fte_source_line_tab,
			    x_result_tab		   OUT NOCOPY FTE_ACS_PKG.fte_cs_result_tab_type,
			    x_return_message               OUT NOCOPY VARCHAR2,
			    x_return_status                OUT NOCOPY VARCHAR2) IS

  -- New Header and Result Tab
  l_cs_input_tab		FTE_ACS_PKG.fte_cs_entity_tab_type;
  l_cs_output_tab		FTE_ACS_PKG.fte_cs_result_tab_type;
  l_cs_output_message_tab	FTE_ACS_PKG.fte_cs_output_message_tab;

  l_customer_site_id		NUMBER;
  l_customer_id			NUMBER;

  l_return_status               VARCHAR2(1);                                -- return status flag
  l_return_message              VARCHAR2(2000);                             -- return error message variable
  l_param_rec			WSH_SHIPPING_PARAMS_PVT.PARAMETER_VALUE_REC_TYP;

  -- These variables are used as counters for table creation
  l                             PLS_INTEGER := 0;                           -- variable used as a counter
  k                             PLS_INTEGER := 0;                           -- Variable used as a counter

  -- Variables used for error handling
  l_error_code                  NUMBER;                                -- Oracle SQL Error Number
  l_error_text                  VARCHAR2(2000);                        -- Oracle SQL Error Text
  l_message_tab			TableVarchar2000;

  --
  l_debug_on		BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FORMAT_CS_CALL';
  --

  BEGIN
   --
   -- Initialize the return flags
   -- Debug Statements
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
   END IF;
   --
   x_return_status                := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   x_return_message               := null;

   l := 0;

   -- for the consolidations passed in, get the information out so that we
   -- can call the Carrier Selection Search Engine

   FOR j IN p_source_header_tab.FIRST..p_source_header_tab.LAST LOOP

      --Prepare the input record.

      l_cs_input_tab(l).delivery_id		  := p_source_header_tab(j).consolidation_id;
      l_cs_input_tab(l).delivery_name		  := NULL;
      l_cs_input_tab(l).organization_id		  := p_source_header_tab(j).ship_from_org_id;
      l_cs_input_tab(l).gross_weight		  := p_source_header_tab(j).total_weight;
      l_cs_input_tab(l).weight_uom_code		  := p_source_header_tab(j).weight_uom_code;
      l_cs_input_tab(l).volume			  := p_source_header_tab(j).total_volume;
      l_cs_input_tab(l).volume_uom_code		  := p_source_header_tab(j).volume_uom_code;
      l_cs_input_tab(l).initial_pickup_loc_id	  := p_source_header_tab(j).ship_from_location_id;
      l_cs_input_tab(l).ultimate_dropoff_loc_id	  := p_source_header_tab(j).ship_to_location_id;
      --
      -- Determine the ship to site.
      --
      get_customer_site( p_consolidation_id		=> p_source_header_tab(j).consolidation_id,
		         p_source_line_tab		=> p_source_line_tab,
		         x_customer_site_id		=> l_customer_site_id,
		         x_return_status		=> l_return_status);

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	  GOTO next_pass;
      END IF;

      l_cs_input_tab(l).customer_site_id  := l_customer_site_id;

      --
      --Determine whether to use ship to customer or sold to customer.
      --
      l_param_rec.organization_id :=  p_source_header_tab(j).ship_from_org_id;
      l_param_rec.param_name(1)   := 'EVAL_RULE_BASED_ON_SHIPTO_CUST';

      WSH_SHIPPING_PARAMS_PVT.Get(x_param_value_info => l_param_rec ,
				  x_return_status    => l_return_status);

      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         GOTO next_pass;
      END IF;

      --Evaluate Rules based on ship to customer
      IF (l_param_rec.PARAM_VALUE_CHR.EXISTS(1) AND l_param_rec.PARAM_VALUE_CHR(1) = 'Y') THEN

		get_ship_to_customer( p_dropoff_loc_id	    => p_source_header_tab(j).ship_to_location_id,
				      p_ship_to_site	    => l_customer_site_id,
				      x_customer_id	    => l_customer_id,
				      x_return_status	    => l_return_status);

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                              GOTO next_pass;
                END IF;
		l_cs_input_tab(l).customer_id  := l_customer_id;
      ELSE
		l_cs_input_tab(l).customer_id  := p_source_header_tab(j).customer_id;
      END IF;

      l_cs_input_tab(l).freight_terms_code	  := p_source_header_tab(j).freight_terms;
      l_cs_input_tab(l).initial_pickup_date	  := p_source_header_tab(j).ship_date;
      l_cs_input_tab(l).ultimate_dropoff_date	  := p_source_header_tab(j).arrival_date;
      l_cs_input_tab(l).fob_code		  := p_source_header_tab(j).fob_code;
      l_cs_input_tab(l).transit_time		  := p_source_header_tab(j).delivery_lead_time;

      l := l+1;

      <<next_pass>>
       null;
    END LOOP;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_ACS_PKG.START_ACS',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --

    FTE_ACS_PKG.GET_ROUTING_RESULTS(   p_format_cs_tab		 => l_cs_input_tab,
			               p_entity			 => 'PSEUDO_DLVY',
			               p_messaging_yn		 => 'Y',
			               p_caller			 => 'ORDER_MGMT',
				       x_cs_output_tab		 => l_cs_output_tab,
		                       x_cs_output_message_tab	 => l_cs_output_message_tab,
			               x_return_message		 => l_return_message,
			               x_return_status		 => l_return_status);

    --
    -- The engine returns the formatted results
    --
    IF ((l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS OR l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) AND
	(l_cs_output_tab.COUNT > 0)) THEN
		--
		--  Return the results - We have rule id
		--  Ship method is returned internally from the engine.
		--
		x_result_tab := l_cs_output_tab;
    ELSE
	    x_return_status  := WSH_UTIL_CORE.G_RET_STS_WARNING;
	    FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NO_CS_RESULT');
	    wsh_util_core.add_message(x_return_status);
	    x_return_message := FND_MESSAGE.GET;
    END IF;

    --
    -- Return to the calling API
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

   EXCEPTION
     WHEN OTHERS THEN
        l_error_code := SQLCODE;
        l_error_text := SQLERRM;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM FTE_PROCESS_REQUESTS.FORMAT_CS_CALL IS ' ||L_ERROR_TEXT  );
        END IF;
        --

        WSH_UTIL_CORE.default_handler('FTE_PROCESS_REQUESTS.FORMAT_CS_CALL');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        x_return_message := l_error_text;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
  --
  END FORMAT_CS_CALL;



-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                PROCESS_LINES					      --
-- TYPE:                PROCEDURE                                             --
--                                                                            --
-- PARAMETERS (IN):							      --
--		        p_source_line_tab		IN OUT NOCOPY	      --
--			       FTE_PROCESS_REQUESTS.fte_source_line_tab       --
--			p_source_header_tab		IN OUT NOCOPY	      --
--			       FTE_PROCESS_REQUESTS.fte_source_header_tab     --
--			p_source_type			IN		      --
--								VARCHAR2      --
--			p_action			IN		      --
--								VARCHAR2      --
--			x_source_line_rates_tab		OUT NOCOPY	      --
--			       FTE_PROCESS_REQUESTS.fte_source_line_rates_tab --
--			x_source_header_rates_tab	OUT NOCOPY	      --
--			      FTE_PROCESS_REQUESTS.fte_source_header_rates_tab--
--			x_return_status			OUT NOCOPY	      --
--								VARCHAR2      --
--			x_msg_count			OUT NOCOPY	      --
--								NUMBER	      --
--			x_msg_data			OUT NOCOPY	      --
--								VARCHAR2      --
--  									      --
-- DESCRIPTION:								      --
--									      --
-- main procedure that will take in a table of source line inputs	      --
-- and consolidate them based on grouping rules and for each consolidation    --
-- call cs engine wrapper, lane search, rating, as required by p_action	      --
--									      --
-- CHANGE LOG								      --
-- ----------								      --
-- [2003/02/05][PACK I][ABLUNDEL][BUG: 2769793]				      --
-- Freight terms on the order line was getting nulled out as		      --
-- the engine was returning null. Only change the freight term		      --
-- if one exists							      --
--									      --
-- 2003/06/01 Pack J, xizhang added action GET_GROUP and GET_RATE_CHOICE      --
--                            added OUT parameter x_source_header_rates_tab   --
--									      --
-- -------------------------------------------------------------------------- --
  PROCEDURE Process_Lines(p_source_line_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_tab,
			  p_source_header_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_header_tab,
			  p_source_type			IN		VARCHAR2,
			  p_action			IN		VARCHAR2,
			  x_source_line_rates_tab	OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
			  x_source_header_rates_tab	OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
		       	  x_return_status		OUT NOCOPY	VARCHAR2,
		       	  x_msg_count			OUT NOCOPY	NUMBER,
			  x_msg_data			OUT NOCOPY	VARCHAR2) IS

  l_orig_delivery_time		NUMBER;
  l_transit_time		NUMBER;
  l_transit_ship_method		VARCHAR2(30);
  l_session_id			NUMBER;
  l_transit_status		VARCHAR2(1);

  l_cs_transit_min		NUMBER;
  l_cs_transit_max		NUMBER;

  l_con_id	PLS_INTEGER;
  l_no_results	VARCHAR2(1) := 'Y';

  l_source_line_rates_tab	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab;
  l_source_header_rates_tab	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab;
  l_request_id         NUMBER;

  l_status	VARCHAR2(1);
  l_msg_count	NUMBER := 0;
  l_msg_data	VARCHAR2(200);

  l_ship_method_meaning VARCHAR2(80);
  l_org_name		VARCHAR2(80);
  l_carrier_name	VARCHAR2(360);
  l_freight_code 	VARCHAR2(230);
  l_rule_name		VARCHAR2(80);

  --R12 Glog Integration
  l_otm_installed       VARCHAR2(1);
  l_result_consolidation_id_tab         WSH_NEW_DELIVERY_ACTIONS.TableNumbers;
  l_result_carrier_id_tab               WSH_NEW_DELIVERY_ACTIONS.TableNumbers;
  l_result_service_level_tab            WSH_NEW_DELIVERY_ACTIONS.TableVarchar30;
  l_result_mode_of_transport_tab        WSH_NEW_DELIVERY_ACTIONS.TableVarchar30;
  l_result_freight_term_tab             WSH_NEW_DELIVERY_ACTIONS.TableVarchar30;
  l_result_transit_time_min_tab         WSH_NEW_DELIVERY_ACTIONS.TableNumbers;
  l_result_transit_time_max_tab         WSH_NEW_DELIVERY_ACTIONS.TableNumbers;
  l_ship_method_code_tab                WSH_NEW_DELIVERY_ACTIONS.TableVarchar30;

  --R12 - Routing Rules Engine
  l_result_tab		FTE_ACS_PKG.FTE_CS_RESULT_TAB_TYPE;
  l_return_message	VARCHAR2(2000);

  CURSOR get_session_id IS
  SELECT mrp_atp_schedule_temp_s.nextVal
  FROM   dual;

  CURSOR get_ship_method_meaning(p_ship_method_code VARCHAR2) IS
  SELECT ship_method_meaning
  FROM   wsh_carrier_services
  WHERE  ship_method_code = p_ship_method_code;

  CURSOR get_ship_method_meaning2(p_carrier_id NUMBER, p_mode VARCHAR2, p_service VARCHAR2) IS
  SELECT ship_method_meaning
  FROM   wsh_carrier_services
  WHERE  carrier_id = p_carrier_id AND
         mode_of_transport = p_mode AND
         service_level = p_service;

  CURSOR get_generic_sm(p_mode VARCHAR2, p_service VARCHAR2, p_org_id NUMBER) IS
  SELECT wcs.ship_method_code
  FROM   wsh_org_carrier_services wocs,
         wsh_carrier_services     wcs,
         wsh_carriers             wc
  WHERE  wcs.service_level= p_service AND
         wcs.mode_of_transport= p_mode AND
         wcs.enabled_flag       = 'Y' AND
         wcs.carrier_service_id = wocs.carrier_service_id AND
         wocs.organization_id   = p_org_id AND
         wocs.enabled_flag      = 'Y' AND
         wcs.carrier_id         = wc.carrier_id AND
         nvl(wc.generic_flag, 'N') = 'Y';

CURSOR get_generic_sm_on_mod(p_mode VARCHAR2,  p_org_id NUMBER) IS
  SELECT wcs.ship_method_code
  FROM   wsh_org_carrier_services wocs,
         wsh_carrier_services     wcs,
         wsh_carriers             wc
  WHERE
         wcs.mode_of_transport = p_mode AND
         wcs.enabled_flag       = 'Y' AND
         wcs.carrier_service_id = wocs.carrier_service_id AND
         wocs.organization_id   = p_org_id AND
         wocs.enabled_flag      = 'Y' AND
         wcs.carrier_id         = wc.carrier_id AND
         nvl(wc.generic_flag, 'N') = 'Y';

CURSOR get_generic_sm_on_ser( p_service VARCHAR2, p_org_id NUMBER) IS
  SELECT wcs.ship_method_code
  FROM   wsh_org_carrier_services wocs,
         wsh_carrier_services     wcs,
         wsh_carriers             wc
  WHERE  wcs.service_level = p_service AND
         wcs.enabled_flag       = 'Y' AND
         wcs.carrier_service_id = wocs.carrier_service_id AND
         wocs.organization_id   = p_org_id AND
         wocs.enabled_flag      = 'Y' AND
         wcs.carrier_id         = wc.carrier_id AND
         nvl(wc.generic_flag, 'N') = 'Y';

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_LINES';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_TYPE',P_SOURCE_TYPE);
	    WSH_DEBUG_SV.log(l_module_name,'P_ACTION',P_ACTION);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        /* R12 Glog Integration */
        -- determine if OTM is installed
        l_otm_installed:=NULL;
        l_otm_installed:=WSH_UTIL_CORE.GC3_Is_Installed;
        IF ((l_otm_installed IS NOT NULL) AND (l_otm_installed='Y'))
        THEN
                l_otm_installed:='Y';
        ELSE
                l_otm_installed:='N';
        END IF;

        IF((p_action IS NOT NULL) AND (p_action = 'GET_ESTIMATE_RATE'))
        THEN
                l_otm_installed:='N';
        END IF;

	IF (p_source_line_tab.COUNT < 1) THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NO_SOURCE_LINES');
	    x_msg_count := l_msg_count + 1;
	    x_msg_data := FND_MESSAGE.GET;
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR returned ' || x_msg_data);
	        WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    --
	    RETURN;
	END IF;

        IF (p_action = 'GET_RATE_CHOICE'
            OR p_action = 'GET_ESTIMATE_RATE')    -- FTE J FTE rate estimate
        THEN

	  -- this action requires group being passed in
	  IF (p_source_header_tab.COUNT < 1) THEN

	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    FND_MESSAGE.SET_NAME('FTE', 'FTE_PRC_RATE_CHOICE_ERR1');
	    x_msg_count := l_msg_count + 1;
	    x_msg_data := FND_MESSAGE.GET;
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR returned ' || x_msg_data);
	        WSH_DEBUG_SV.pop(l_module_name);
	    END IF;
	    --
	    RETURN;

	  ELSE -- p_source_header_tab.COUNT = 1

            IF (l_otm_installed = 'N') THEN

	      IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_FREIGHT_RATING_PUB.GET_FREIGHT_COSTS',WSH_DEBUG_SV.C_PROC_LEVEL);
	      END IF;
	      FTE_FREIGHT_RATING_PUB.Get_Freight_Costs(p_api_version             => 1,
						     p_source_line_tab 		 => p_source_line_tab,
                               			     p_source_header_tab         => p_source_header_tab,
                               			     p_source_type               => p_source_type,
		                                     p_action                    => p_action,
                               			     x_source_line_rates_tab     => l_source_line_rates_tab,
                               			     x_source_header_rates_tab   => l_source_header_rates_tab,
                               			     x_request_id                => l_request_id,
                               			     x_return_status             => l_status,
                               			     x_msg_count                 => l_msg_count,
                               			     x_msg_data                  => l_msg_data);
            ELSE
	      IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'currency for choose ship method is '||p_source_header_tab(p_source_header_tab.FIRST).currency);
	      END IF;
              WSH_OTM_RIQ_XML.CALL_OTM_FOR_OM(
                        x_source_line_tab              => p_source_line_tab,
                        x_source_header_tab            => p_source_header_tab,
                        p_source_type                  => p_source_type,
                        p_action                       => p_action,
                        x_source_line_rates_tab        => l_source_line_rates_tab,
                        x_source_header_rates_tab      => l_source_header_rates_tab,
                        x_result_consolidation_id_tab  => l_result_consolidation_id_tab,
                        x_result_carrier_id_tab        => l_result_carrier_id_tab,
                        x_result_service_level_tab     => l_result_service_level_tab,
                        x_result_mode_of_transport_tab => l_result_mode_of_transport_tab,
                        x_result_freight_term_tab      => l_result_freight_term_tab,
                        x_result_transit_time_min_tab  => l_result_transit_time_min_tab,
                        x_result_transit_time_max_tab  => l_result_transit_time_max_tab,
                        x_ship_method_code_tab         => l_ship_method_code_tab,
                        x_return_status                => l_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data);
            END IF;

            IF (l_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	      x_source_line_rates_tab   := l_source_line_rates_tab;
	      x_source_header_rates_tab := l_source_header_rates_tab;
            END IF;

	    x_return_status := l_status;
	    x_msg_count     := l_msg_count;
  	    x_msg_data      := l_msg_data;

	  END IF; -- p_source_header_tab.COUNT = 1

	ELSE -- p_action <> 'GET_RATE_CHOICE'

	-- consolidate the lines and sum up weight and volume if not already consolidated
	IF (p_source_header_tab.COUNT = 0) THEN
	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'p_source_header_tab.COUNT = 0');
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_SOURCE_LINE_CONSOLIDATION.CONSOLIDATE_LINES',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    FTE_SOURCE_LINE_CONSOLIDATION.Consolidate_Lines(p_source_line_tab,
							    p_source_header_tab,
							    p_action,
							    l_status,
							    l_msg_count,
							    l_msg_data);

	    --
	    -- Debug Statements
	    --
	    IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'-------- Consolidations -----------');
		IF (p_source_header_tab.COUNT > 0) THEN
		    FOR zz IN p_source_header_tab.FIRST..p_source_header_tab.LAST LOOP
			WSH_DEBUG_SV.logmsg(l_module_name,'*********************************');
			WSH_DEBUG_SV.log(l_module_name, 'consolidation_id', p_source_header_tab(zz).consolidation_id);
			WSH_DEBUG_SV.log(l_module_name, 'total_weight', p_source_header_tab(zz).total_weight);
			WSH_DEBUG_SV.log(l_module_name, 'weight_uom_code', p_source_header_tab(zz).weight_uom_code);
			WSH_DEBUG_SV.log(l_module_name, 'total_volume', p_source_header_tab(zz).total_volume);
			WSH_DEBUG_SV.log(l_module_name, 'volume_uom_code', p_source_header_tab(zz).volume_uom_code);
		    END LOOP;
		ELSE
		    WSH_DEBUG_SV.logmsg(l_module_name, 'FTE_SOURCE_LINE_CONSOLIDATION.Consolidate_Lines resulted in no consolidations');
		END IF;
		WSH_DEBUG_SV.logmsg(l_module_name,'-------- End Consolidations -----------');
	    END IF;
	END IF;

	IF (p_source_header_tab.COUNT = 0 OR
	    l_status is null OR
            l_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

	    IF (l_status is not null) THEN
	    	x_return_status := l_status;
	    ELSE
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    END IF;
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
	-- Do carrier selection for each consolidation if consolidated successfully
	-- and action is C or B
	IF (p_source_header_tab.COUNT > 0 AND l_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    AND (p_action = 'C' OR p_action = 'B')) THEN

          IF (l_otm_installed = 'N') THEN
	    FORMAT_CS_CALL( p_source_header_tab     => p_source_header_tab,
	 		   p_source_line_tab	    => p_source_line_tab,
			   x_result_tab		    => l_result_tab,
			   x_return_message         => l_return_message,
			   x_return_status          => l_status);
            -- l_return_message is not used below, so assign it to l_msg_data
            l_msg_data := substrb(l_return_message, 1, 200);

          ELSE

            WSH_OTM_RIQ_XML.CALL_OTM_FOR_OM(
                x_source_line_tab              => p_source_line_tab,
                x_source_header_tab            => p_source_header_tab,
                p_source_type                  => p_source_type,
                p_action                       => 'C',
                x_source_line_rates_tab        => l_source_line_rates_tab,
                x_source_header_rates_tab      => l_source_header_rates_tab,
                x_result_consolidation_id_tab  => l_result_consolidation_id_tab,
                x_result_carrier_id_tab        => l_result_carrier_id_tab,
                x_result_service_level_tab     => l_result_service_level_tab,
                x_result_mode_of_transport_tab => l_result_mode_of_transport_tab,
                x_result_freight_term_tab      => l_result_freight_term_tab,
                x_result_transit_time_min_tab  => l_result_transit_time_min_tab,
                x_result_transit_time_max_tab  => l_result_transit_time_max_tab,
                x_ship_method_code_tab         => l_ship_method_code_tab,
                x_return_status                => l_status,
                x_msg_count                    => l_msg_count,
                x_msg_data                     => l_msg_data);

	    IF l_debug_on THEN
	      WSH_DEBUG_SV.log(l_module_name,'x_return_status from call_otm', l_status);
	      WSH_DEBUG_SV.log(l_module_name,'x_msg_count from call_otm', l_msg_count);
	      WSH_DEBUG_SV.log(l_module_name,'x_msg_data from call_otm', l_msg_data);
            END IF;

            /*  R12 Glog Integration
                format_cs_call's signature is changed in R12 to return
                l_result_tab instead of 8 individual result tables,
                and the subsequent flow is based on the new return type
                so need to convert

                1) output parameters  l_result_consolidation_id_tab,
                                      l_result_carrier_id_tab,
                                      l_result_service_level_tab,
                                      l_result_mode_of_transport_tab,
                                      l_result_freight_term_tab,
                                      l_result_transit_time_min_tab,
                                      l_result_transit_time_max_tab,
                                      l_ship_method_code_tab
                   to l_result_tab

                2) l_msg_data is changed to l_return_message,
                   but l_msg_data rather than l_return_message is still used
                   below, so won't change it
            */

            IF (l_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	      IF l_debug_on THEN
	        WSH_DEBUG_SV.log(l_module_name,'l_result_tab.count',l_result_tab.count);
	        WSH_DEBUG_SV.log(l_module_name,'l_result_consolidation_id_tab.count',l_result_consolidation_id_tab.count);
	      END IF;

              FOR i IN l_result_consolidation_id_tab.FIRST..l_result_consolidation_id_tab.LAST LOOP
                l_result_tab(i).delivery_id        := l_result_consolidation_id_tab(i);
                l_result_tab(i).carrier_id         := l_result_carrier_id_tab(i);
                l_result_tab(i).service_level      := l_result_service_level_tab(i);
                l_result_tab(i).mode_of_transport  := l_result_mode_of_transport_tab(i);
                l_result_tab(i).freight_terms_code := l_result_freight_term_tab(i);
                l_result_tab(i).min_transit_time   := l_result_transit_time_min_tab(i);
                l_result_tab(i).max_transit_time   := l_result_transit_time_max_tab(i);
                l_result_tab(i).ship_method_code   := l_ship_method_code_tab(i);
                l_result_tab(i).result_type        := 'RANK'; -- need to be populated
              END LOOP;

	      IF l_debug_on THEN
	        WSH_DEBUG_SV.log(l_module_name,'l_result_tab.count',l_result_tab.count);
                FOR i IN l_result_tab.FIRST..l_result_tab.LAST LOOP
	          WSH_DEBUG_SV.log(l_module_name,'l_result_tab.delivery_id',l_result_tab(i).delivery_id);
                END LOOP;
	      END IF;

            END IF;

          END IF; -- if (l_otm_installed)

	   IF (l_status is not null AND l_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name, 'Populating CS results into consolidation table');
		END IF;

		-- populate the CS results into the consolidation table
		FOR i IN p_source_header_tab.FIRST..p_source_header_tab.LAST LOOP

--		    FOR j IN l_result_consolidation_id_tab.FIRST..l_result_consolidation_id_tab.LAST LOOP
		    FOR j IN l_result_tab.FIRST..l_result_tab.LAST LOOP

--			IF (p_source_header_tab(i).consolidation_id = l_result_consolidation_id_tab(j)) THEN
--			Consolidation id is being passed as delivery id
			IF (p_source_header_tab(i).consolidation_id = l_result_tab(j).delivery_id) THEN

			   --
			   -- If Result type is 'RANK' then copy.
			   --	else throw message.
			   -- EXIT;

			   IF (l_result_tab(j).result_type<>'RANK') THEN

				  l_no_results := 'N';
				  FND_MESSAGE.SET_NAME('WSH','WSH_FTE_CS_MULTILEG');
                                  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			      	  p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				  -- p_source_header_tab(i).message_data := FND_MESSAGE.GET;
                                  FND_MSG_PUB.ADD;

				  IF l_debug_on THEN
				        WSH_DEBUG_SV.logmsg(l_module_name,'Multileg results returned');
				  END IF;

			   --
			   -- Here we are looping over the output results table. The results are sorted by
			   -- sequence.The moment we find the first record.We copy the values and EXIT.
			   --

			   ELSIF (l_result_tab(j).result_type='RANK') THEN

				    l_no_results := 'N';
				    p_source_header_tab(i).ship_method_code  := l_result_tab(j).ship_method_code;

				    p_source_header_tab(i).carrier_id	     := l_result_tab(j).carrier_id;
				    p_source_header_tab(i).service_level     := l_result_tab(j).service_level;
			            p_source_header_tab(i).mode_of_transport := l_result_tab(j).mode_of_transport;

				    --
			            -- [2003/02/05][PACK I][ABLUNDEL][BUG: 2769793]
			            -- Freight terms on the order line was getting nulled out as
			            -- the engine was returning null. Only change the freight term
			            -- if one exists
				    --
--			   	    IF (l_result_freight_term_tab(j) is not null) THEN
--				       p_source_header_tab(i).freight_terms := l_result_freight_term_tab(j);
--		                    END IF;

				    IF (l_result_tab(j).freight_terms_code IS NOT NULL) THEN
					p_source_header_tab(i).freight_terms := l_result_tab(j).freight_terms_code;
				    END IF;

				    IF l_debug_on THEN
					WSH_DEBUG_SV.logmsg(l_module_name, '----------------------------------------');
				    	WSH_DEBUG_SV.logmsg(l_module_name, 'Added ship method, carrier, service, mode, freight terms for consolidation_id = ' || p_source_header_tab(i).consolidation_id);
				    END IF;

				    l_orig_delivery_time := p_source_header_tab(i).delivery_lead_time;  -- save for later
--				    l_cs_transit_min := l_result_transit_time_min_tab(j);
--				    l_cs_transit_max := l_result_transit_time_max_tab(j);

				    l_cs_transit_min :=  l_result_tab(j).min_transit_time;
				    l_cs_transit_max :=  l_result_tab(j).max_transit_time;

				    -- bug 2768725
	                            -- get rule name only if it exists
--		                    IF (l_rule_name_tab.EXISTS(j)) THEN
--				       l_rule_name := l_rule_name_tab(j);
--				    END IF;

				    l_rule_name := l_result_tab(j).rule_name;

--				    IF (l_result_transit_time_max_tab(j) is not null) THEN
--				    	p_source_header_tab(i).delivery_lead_time := l_result_transit_time_max_tab(j);
--				    END IF;

				    IF (l_result_tab(j).max_transit_time IS NOT NULL) THEN
					p_source_header_tab(i).delivery_lead_time := l_result_tab(j).max_transit_time;
				    END IF;

--				    IF l_debug_on THEN
--				    	WSH_DEBUG_SV.logmsg(l_module_name, 'Obtained rule name and lead times for consolidation_id = ' || p_source_header_tab(i).consolidation_id);
--				    END IF;
--

				    IF (p_source_header_tab(i).carrier_id is null) THEN

					    IF l_debug_on THEN
						WSH_DEBUG_SV.logmsg(l_module_name, 'carrier_id is null');
					    END IF;

					    -- check to see if generic carrier
					    -- (as generic carriers can have just service level or mode)
					    IF (p_source_header_tab(i).service_level is not null AND
                        p_source_header_tab(i).mode_of_transport is not null) THEN

                OPEN get_generic_sm(p_source_header_tab(i).mode_of_transport,p_source_header_tab(i).service_level,
                             p_source_header_tab(i).ship_from_org_id);

                FETCH get_generic_sm INTO p_source_header_tab(i).ship_method_code;
                CLOSE get_generic_sm;
					    ELSIF (p_source_header_tab(i).service_level is  null AND
            						p_source_header_tab(i).mode_of_transport is not null) THEN

                OPEN get_generic_sm_on_mod(p_source_header_tab(i).mode_of_transport,
                             p_source_header_tab(i).ship_from_org_id);

                FETCH get_generic_sm_on_mod INTO p_source_header_tab(i).ship_method_code;
                CLOSE get_generic_sm_on_mod;
					    ELSIF (p_source_header_tab(i).service_level is not null AND
            						p_source_header_tab(i).mode_of_transport is null) THEN

                  OPEN get_generic_sm_on_ser(p_source_header_tab(i).service_level,
                                                     p_source_header_tab(i).ship_from_org_id);

                  FETCH get_generic_sm_on_ser INTO p_source_header_tab(i).ship_method_code;
                  CLOSE get_generic_sm_on_ser;
					    ELSE
						-- no carrier selection results at all
                                                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				    	    	p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				    	    	FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NO_CS_RESULT');
				    	    	p_source_header_tab(i).message_data := FND_MESSAGE.GET;
					    	IF l_debug_on THEN
						    WSH_DEBUG_SV.log(l_module_name, 'message_data', p_source_header_tab(i).message_data);
					    	END IF;
              END IF; -- no carrier servoce
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Gneric Ship Method Derived', p_source_header_tab(i).ship_method_code);
              END IF;

						-- error: need to set up generic carrier
						IF (p_source_header_tab(i).ship_method_code is null) THEN

						    l_org_name := WSH_UTIL_CORE.Get_Org_Name(p_source_header_tab(i).ship_from_org_id);

                                                    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			    	    		    p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			    	    	            FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NO_GENERIC_CARRIER');
						    FND_MESSAGE.SET_TOKEN('ORG_NAME', l_org_name);
				    	    	    -- p_source_header_tab(i).message_data := FND_MESSAGE.GET;
                                                    FND_MSG_PUB.ADD;

					    	    IF l_debug_on THEN
						    	WSH_DEBUG_SV.log(l_module_name, 'message_data', p_source_header_tab(i).message_data);
					    	    END IF;
						END IF;



				    		-- result from CS, but no valid ship method assigned to org
				    ELSIF (p_source_header_tab(i).carrier_id is not null AND
					   p_source_header_tab(i).service_level is not null AND
					   p_source_header_tab(i).mode_of_transport is not null AND
					   p_source_header_tab(i).ship_method_code is null) THEN

					       IF l_debug_on THEN
						   WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR result from CS, but no valid ship method assigned to org');
					       END IF;

                                               x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
					       p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;

					       OPEN get_ship_method_meaning2( p_source_header_tab(i).carrier_id,
									      p_source_header_tab(i).mode_of_transport,
									      p_source_header_tab(i).service_level);
		 			       FETCH get_ship_method_meaning2 INTO l_ship_method_meaning;
		 			       CLOSE get_ship_method_meaning2;

					       l_org_name := WSH_UTIL_CORE.Get_Org_Name(p_source_header_tab(i).ship_from_org_id);
			    		       FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NO_SHIP_METHOD');
					       FND_MESSAGE.SET_TOKEN('SHIP_METHOD', l_ship_method_meaning);
					       FND_MESSAGE.SET_TOKEN('RULE_NAME', l_rule_name);
					       FND_MESSAGE.SET_TOKEN('ORG_NAME', l_org_name);
				    	       -- p_source_header_tab(i).message_data := FND_MESSAGE.GET;
                                               FND_MSG_PUB.ADD;

			 		       IF l_debug_on THEN
						 WSH_DEBUG_SV.log(l_module_name, 'message_data', p_source_header_tab(i).message_data);
					       END IF;

						-- have carrier, but not others, incomplete ship method setup
				     ELSIF (p_source_header_tab(i).ship_method_code is null) THEN

					       IF l_debug_on THEN
						  WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR incomplete ship method setup');
				 	       END IF;

                                                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
						p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
						WSH_CARRIERS_GRP.Get_Carrier_Name(p_source_header_tab(i).carrier_id, l_carrier_name, l_freight_code);
				    		FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_INCOMPLETE_SHIP_METHOD');
						FND_MESSAGE.SET_TOKEN('RULE_NAME', l_rule_name);
						FND_MESSAGE.SET_TOKEN('CARRIER_NAME', l_carrier_name);
				    		-- p_source_header_tab(i).message_data := FND_MESSAGE.GET;
                                                FND_MSG_PUB.ADD;

						IF l_debug_on THEN
							WSH_DEBUG_SV.log(l_module_name, 'message_data', p_source_header_tab(i).message_data);
						END IF;
				      END IF;  -- end checking for errors

				    	-- if have ship_method must mean have everything, continue
				      IF (p_source_header_tab(i).ship_method_code is not null) THEN

					    p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
				   	    -- get ship method, and transit time from transit times table
					    OPEN get_session_id;
				            FETCH get_session_id INTO l_session_id;
				            CLOSE get_session_id;

					    l_transit_ship_method := p_source_header_tab(i).ship_method_code;

					    --
					    -- Debug Statements
					    --
					    IF l_debug_on THEN
					        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit MSC_ATP_PROC.ATP_SHIPPING_LEAD_TIME',WSH_DEBUG_SV.C_PROC_LEVEL);
						WSH_DEBUG_SV.log(l_module_name,'session_id', l_session_id);
						WSH_DEBUG_SV.log(l_module_name,'ship_from_location_id', p_source_header_tab(i).ship_from_location_id);
						WSH_DEBUG_SV.log(l_module_name,'ship_to_site_id', p_source_header_tab(i).ship_to_site_id);
						WSH_DEBUG_SV.log(l_module_name,'original_ship_method', l_transit_ship_method);
					    END IF;
					    --
					    MSC_ATP_PROC.ATP_Shipping_Lead_Time(p_source_header_tab(i).ship_from_location_id,
										p_source_header_tab(i).ship_to_site_id,
										l_session_id,
										l_transit_ship_method,
										l_transit_time,
										l_transit_status);

					    IF l_debug_on THEN
						WSH_DEBUG_SV.logmsg(l_module_name, 'Results from MSC_ATP_PROC.ATP_SHIPPING_LEAD_TIME:');
						WSH_DEBUG_SV.log(l_module_name, 'ship_method', l_transit_ship_method);
						WSH_DEBUG_SV.log(l_module_name, 'transit_time', l_transit_time);
						WSH_DEBUG_SV.log(l_module_name, 'status', l_transit_status);
					    END IF;

			  	            -- make sure ship method returned from transit times table matches
				            -- that returned from CS, else error
					    IF (l_transit_status = FND_API.G_RET_STS_ERROR OR
						l_transit_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

						IF l_debug_on THEN
						    WSH_DEBUG_SV.logmsg(l_module_name, 'MSC_ATP_PROC.ATP_SHIPPING_LEAD_TIM returned ' || l_transit_status);
						END IF;
						p_source_header_tab(i).status := l_transit_status;
						-- continue, end of this iteration of loop
					        -- ship method returned by ATP is different from CS ship method
					    ELSIF (l_transit_status = FND_API.G_RET_STS_SUCCESS AND
		  				   l_transit_ship_method is not null AND
						   l_transit_ship_method <> p_source_header_tab(i).ship_method_code) THEN

						IF l_debug_on THEN
						    WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR ship method returned by ATP is different from CS ship method');
						END IF;

                                                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   		    	    	p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
						OPEN get_ship_method_meaning(p_source_header_tab(i).ship_method_code);
						FETCH get_ship_method_meaning INTO l_ship_method_meaning;
						CLOSE get_ship_method_meaning;

						IF (l_cs_transit_min is null) THEN
				    	    	    FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NOMATCH_SHIP_METHOD');
						    FND_MESSAGE.SET_TOKEN('SHIP_METHOD', l_ship_method_meaning);
				    	    	    -- p_source_header_tab(i).message_data := FND_MESSAGE.GET;
                                                    FND_MSG_PUB.ADD;
						ELSE
			    		    	    FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NOMATCH_SHIP_METHOD_2');
						    FND_MESSAGE.SET_TOKEN('SHIP_METHOD', l_ship_method_meaning);
						    FND_MESSAGE.SET_TOKEN('FTE_MIN_TRANSIT_TIME', l_cs_transit_min);
						    FND_MESSAGE.SET_TOKEN('FTE_MAX_TRANSIT_TIME', l_cs_transit_max);
				    	    	    -- p_source_header_tab(i).message_data := FND_MESSAGE.GET;
                                                    FND_MSG_PUB.ADD;
						END IF;

						IF l_debug_on THEN
						    WSH_DEBUG_SV.log(l_module_name, 'message_data', p_source_header_tab(i).message_data);
						END IF;
						-- continue, end of this iteration of loop

						-- make sure transit time (from TT) is between min and max
						-- transit time of FTE (from CS)
					   ELSIF ( p_source_header_tab(i).scheduled_flag = 'Y' AND
						   l_transit_time is not null AND
						   NOT (l_transit_time between nvl(l_cs_transit_min, 0)
						   and nvl(l_cs_transit_max, 999))) THEN
						-- since ATP transit time falls outside FTE range
						-- set return lead time to be FTE's min
						p_source_header_tab(i).delivery_lead_time := l_cs_transit_min;

						IF l_debug_on THEN
						    WSH_DEBUG_SV.logmsg(l_module_name, 'WARNING ATP transit time falls outside FTE range. Setting return lead time to be FTE min');
						END IF;

						-- set warning message
   				    	    	p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_WARNING;

						OPEN get_ship_method_meaning(p_source_header_tab(i).ship_method_code);
						FETCH get_ship_method_meaning INTO l_ship_method_meaning;
						CLOSE get_ship_method_meaning;

						FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_CS_TT_DISCREPANCY');
						FND_MESSAGE.SET_TOKEN('ATP_TRANSIT_TIME', l_transit_time);
						FND_MESSAGE.SET_TOKEN('SHIP_METHOD', l_ship_method_meaning);
						FND_MESSAGE.SET_TOKEN('FTE_MIN_TRANSIT_TIME', l_cs_transit_min);
						FND_MESSAGE.SET_TOKEN('FTE_MAX_TRANSIT_TIME', l_cs_transit_max);
						FND_MESSAGE.SET_TOKEN('RULE_NAME', l_rule_name);
			    	    		-- p_source_header_tab(i).message_data := FND_MESSAGE.GET;
                                                FND_MSG_PUB.ADD;

						IF l_debug_on THEN
						    WSH_DEBUG_SV.log(l_module_name, 'message_data', p_source_header_tab(i).message_data);
						END IF;
						-- continue, end of this iteration of loop
					    END IF;

					    -- populate returning delivery lead time with that of TT's if TT
					    -- is not null
					    IF (l_transit_time is not null AND
						(l_transit_time between nvl(l_cs_transit_min, 0)
						 and nvl(l_cs_transit_max, 999))) THEN
				    		p_source_header_tab(i).delivery_lead_time := l_transit_time;
					    END IF;

					    -- see if transit time from TT or CS is greater than
					    -- existing on OM line, if so, error; always check
					    -- only perform check if om's delivery lead time is not null or greater than 0
		    	    		    IF (p_source_header_tab(i).scheduled_flag = 'Y' AND
					    	l_orig_delivery_time is not null AND l_orig_delivery_time > 0 AND
					    	p_source_header_tab(i).delivery_lead_time is not null AND
					    	p_source_header_tab(i).delivery_lead_time > l_orig_delivery_time) THEN

						IF l_debug_on THEN
						    WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR OM lead time not null and greater than 0 (scheduled) and transit time to be returned by FTE process_lines is greater than exisiting on OM');
						END IF;

                                                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
					    	p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
					    	FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_CS_TRANSIT_LARGER');
						OPEN get_ship_method_meaning(p_source_header_tab(i).ship_method_code);
						FETCH get_ship_method_meaning INTO l_ship_method_meaning;
						CLOSE get_ship_method_meaning;
				    		FND_MESSAGE.SET_TOKEN('CS_TRANSIT_TIME', p_source_header_tab(i).delivery_lead_time);
				    		FND_MESSAGE.SET_TOKEN('SHIP_METHOD', l_ship_method_meaning);
						FND_MESSAGE.SET_TOKEN('RULE_NAME', l_rule_name);
				    		FND_MESSAGE.SET_TOKEN('OM_TRANSIT_TIME', l_orig_delivery_time);
			    	    		-- p_source_header_tab(i).message_data := FND_MESSAGE.GET;
                                                FND_MSG_PUB.ADD;

						IF l_debug_on THEN
						    WSH_DEBUG_SV.log(l_module_name, 'message_data', p_source_header_tab(i).message_data);
						END IF;
					    END IF; -- end mandatory OM line delivery lead time check against CS/TT

				END IF; -- end have ship method

			  END IF;  --end checking if we have rank only.
			-- We have found a matching group. Exit out of inner loop.
			EXIT;
		 END IF; -- end finding a matching consolidation id
	     END LOOP; -- end looping thru all result consolidations

             IF (l_no_results = 'Y') THEN  -- if no results for this consolidation, error
                        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			p_source_header_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NO_CS_RESULT');
			p_source_header_tab(i).message_data := FND_MESSAGE.GET;
	      END IF;
	END LOOP;

		-- populate the CS results from consolidation table to line output table
	FOR i IN p_source_line_tab.FIRST..p_source_line_tab.LAST LOOP

		    l_con_id := p_source_line_tab(i).consolidation_id;
		    p_source_line_tab(i).ship_method_code := p_source_header_tab(l_con_id).ship_method_code;
		    p_source_line_tab(i).carrier_id  := p_source_header_tab(l_con_id).carrier_id;
		    p_source_line_tab(i).service_level := p_source_header_tab(l_con_id).service_level;
		    p_source_line_tab(i).mode_of_transport := p_source_header_tab(l_con_id).mode_of_transport;
		    p_source_line_tab(i).freight_terms := p_source_header_tab(l_con_id).freight_terms;
		    p_source_line_tab(i).delivery_lead_time := p_source_header_tab(l_con_id).delivery_lead_time;
		    p_source_line_tab(i).status := p_source_header_tab(l_con_id).status;
		    p_source_line_tab(i).message_data := p_source_header_tab(l_con_id).message_data;

		    IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name, '-------- SOURCE LINE OUTPUT--------');
			WSH_DEBUG_SV.log(l_module_name, 'source_line_id', p_source_line_tab(i).source_line_id);
			WSH_DEBUG_SV.log(l_module_name, 'source_header_id', p_source_line_tab(i).source_header_id);
			WSH_DEBUG_SV.log(l_module_name, 'consolidation_id', p_source_line_tab(i).consolidation_id);
			WSH_DEBUG_SV.log(l_module_name, 'ship_from_org_id', p_source_line_tab(i).ship_from_org_id);
			WSH_DEBUG_SV.log(l_module_name, 'ship_from_location_id', p_source_line_tab(i).ship_from_location_id);
			WSH_DEBUG_SV.log(l_module_name, 'ship_to_site_id', p_source_line_tab(i).ship_to_site_id);
			WSH_DEBUG_SV.log(l_module_name, 'ship_to_location_id', p_source_line_tab(i).ship_to_location_id);
			WSH_DEBUG_SV.log(l_module_name, 'customer_id', p_source_line_tab(i).customer_id);
			WSH_DEBUG_SV.log(l_module_name, 'inventory_item_id', p_source_line_tab(i).inventory_item_id);
			WSH_DEBUG_SV.log(l_module_name, 'source_quantity', p_source_line_tab(i).source_quantity);
			WSH_DEBUG_SV.log(l_module_name, 'source_quantity_uom', p_source_line_tab(i).source_quantity_uom);
			WSH_DEBUG_SV.log(l_module_name, 'ship_date', p_source_line_tab(i).ship_date);
			WSH_DEBUG_SV.log(l_module_name, 'arrival_date', p_source_line_tab(i).arrival_date);
			WSH_DEBUG_SV.log(l_module_name, 'scheduled_flag', p_source_line_tab(i).scheduled_flag);
			WSH_DEBUG_SV.log(l_module_name, 'intmed_ship_to_site_id', p_source_line_tab(i).intmed_ship_to_site_id);
			WSH_DEBUG_SV.log(l_module_name, 'intmed_ship_to_loc_id', p_source_line_tab(i).intmed_ship_to_loc_id);
			WSH_DEBUG_SV.log(l_module_name, 'fob_code', p_source_line_tab(i).fob_code);
			WSH_DEBUG_SV.log(l_module_name, 'weight', p_source_line_tab(i).weight);
			WSH_DEBUG_SV.log(l_module_name, 'weight_uom_code', p_source_line_tab(i).weight_uom_code);
			WSH_DEBUG_SV.log(l_module_name, 'volume', p_source_line_tab(i).volume);
			WSH_DEBUG_SV.log(l_module_name, 'volume_uom_code', p_source_line_tab(i).volume_uom_code);
			WSH_DEBUG_SV.log(l_module_name, 'ship_method_code', p_source_line_tab(i).ship_method_code);
			WSH_DEBUG_SV.log(l_module_name, 'carrier_id', p_source_line_tab(i).carrier_id);
			WSH_DEBUG_SV.log(l_module_name, 'service_level', p_source_line_tab(i).service_level);
			WSH_DEBUG_SV.log(l_module_name, 'mode_of_transport', p_source_line_tab(i).mode_of_transport);
			WSH_DEBUG_SV.log(l_module_name, 'freight_terms', p_source_line_tab(i).freight_terms);
			WSH_DEBUG_SV.log(l_module_name, 'delivery_lead_time', p_source_line_tab(i).delivery_lead_time);
			WSH_DEBUG_SV.log(l_module_name, 'status', p_source_line_tab(i).status);
			WSH_DEBUG_SV.log(l_module_name, 'message_data', p_source_line_tab(i).message_data);
		    END IF;
		END LOOP;

              -- if it failed with any of the above validation
              IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

                FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
                IF l_debug_on THEN
                  FND_MESSAGE.SET_TOKEN('LOGFILE',WSH_DEBUG_SV.g_Dir||'/'||WSH_DEBUG_SV.g_File);
                ELSE
                  FND_MESSAGE.SET_TOKEN('LOGFILE','');
                END IF;
                FND_MSG_PUB.ADD;

                FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NO_CS_RESULT');
                FND_MSG_PUB.ADD;

	        IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'return_status is changed from '||l_status||' to '||x_return_status||' after getting ship method.',WSH_DEBUG_SV.C_PROC_LEVEL);
	    	  WSH_DEBUG_SV.pop(l_module_name);
	        END IF;

                RETURN;
              END IF;

	    -- format cs call had warnings (no results at all), put error in each line
	    ELSIF (l_status is not null AND l_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS; -- overall status is success
		x_msg_data := l_msg_data;

		FOR i IN p_source_line_tab.FIRST..p_source_line_tab.LAST LOOP
		    p_source_line_tab(i).status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		    FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NO_CS_RESULT');
		    p_source_line_tab(i).message_data := FND_MESSAGE.GET;
		END LOOP;

	    	--
	    	-- Debug Statements
	    	--
	    	IF l_debug_on THEN
	    	    WSH_DEBUG_SV.pop(l_module_name);
	    	END IF;
	    	--
	    	RETURN;

	    -- format cs call had errors or unexpected errors
	    ELSE
	    	IF l_debug_on THEN
	    	    WSH_DEBUG_SV.log(l_module_name, 'error_return_status', l_status);
	    	    WSH_DEBUG_SV.log(l_module_name, 'error_return_status', l_msg_data);
	    	END IF;
		x_return_status := l_status;
		x_msg_data := l_msg_data;
		IF (x_return_status is null) THEN
		    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		END IF;

		FOR i IN p_source_line_tab.FIRST..p_source_line_tab.LAST LOOP
	    	IF l_debug_on THEN
	    	    WSH_DEBUG_SV.log(l_module_name, 'i is', to_char(i));
	    	END IF;
		    p_source_line_tab(i).status := x_return_status;
		    p_source_line_tab(i).message_data := x_msg_data;
		END LOOP;

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


	-- if action is R or B, do rating call
	IF (p_source_header_tab.COUNT > 0 AND l_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    AND (p_action = 'R' OR p_action = 'B')) THEN

            IF (l_otm_installed ='N') THEN
	      IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_FREIGHT_RATING_PUB.GET_FREIGHT_COSTS',WSH_DEBUG_SV.C_PROC_LEVEL);
	      END IF;
	      FTE_FREIGHT_RATING_PUB.Get_Freight_Costs(
						     p_api_version               => 1,
						     p_source_line_tab 		 => p_source_line_tab,
                               			     p_source_header_tab         => p_source_header_tab,
                               			     p_source_type               => p_source_type,
		                                     p_action                    => p_action,
                               			     x_source_line_rates_tab     => l_source_line_rates_tab,
                               			     x_source_header_rates_tab   => l_source_header_rates_tab,
                               			     x_request_id                => l_request_id,
                               			     x_return_status             => l_status,
                               			     x_msg_count                 => l_msg_count,
                               			     x_msg_data                  => l_msg_data);
            ELSE
	      IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'currency for get rates is '||p_source_header_tab(p_source_header_tab.FIRST).currency);
	      END IF;
              WSH_OTM_RIQ_XML.CALL_OTM_FOR_OM(
                        x_source_line_tab              => p_source_line_tab,
                        x_source_header_tab            => p_source_header_tab,
                        p_source_type                  => p_source_type,
                        p_action                       => 'R',
                        x_source_line_rates_tab        => l_source_line_rates_tab,
                        x_source_header_rates_tab      => l_source_header_rates_tab,
                        x_result_consolidation_id_tab  => l_result_consolidation_id_tab,
                        x_result_carrier_id_tab        => l_result_carrier_id_tab,
                        x_result_service_level_tab     => l_result_service_level_tab,
                        x_result_mode_of_transport_tab => l_result_mode_of_transport_tab,
                        x_result_freight_term_tab      => l_result_freight_term_tab,
                        x_result_transit_time_min_tab  => l_result_transit_time_min_tab,
                        x_result_transit_time_max_tab  => l_result_transit_time_max_tab,
                        x_ship_method_code_tab         => l_ship_method_code_tab,
                        x_return_status                => l_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data);
            END IF;

            IF (l_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	      x_source_line_rates_tab   := l_source_line_rates_tab;
	      x_source_header_rates_tab := l_source_header_rates_tab;
            END IF;

	    x_return_status := l_status;
	    x_msg_count     := l_msg_count;
  	    x_msg_data      := l_msg_data;

	END IF;

	END IF; -- p_action <> 'GET_RATE_CHOICE'
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
END Process_Lines;


-- FOR BACKWARD (I) COMPATIBILITY ONLY
-- THE FOLLOWING BODY IS STUBBED OUT IN THIS BRANCH

PROCEDURE Process_Lines(p_source_line_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_tab,
			p_source_header_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_header_tab,
			p_source_type			IN		VARCHAR2,
		        p_action			IN		VARCHAR2,
			p_rating_parameters_tab		IN		FTE_PROCESS_REQUESTS.fte_rating_parameters_tab DEFAULT FTE_MISS_RATING_PARAMETERS_TAB,
			p_source_line_rates_tab		OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
		       	x_return_status			OUT NOCOPY	VARCHAR2,
		       	x_msg_count			OUT NOCOPY	NUMBER,
			x_msg_data			OUT NOCOPY	VARCHAR2)
IS
BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
END Process_Lines;


END FTE_PROCESS_REQUESTS;

/
