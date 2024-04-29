--------------------------------------------------------
--  DDL for Package Body WSH_OTM_RIQ_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_OTM_RIQ_XML" as
/* $Header: WSHGLRXB.pls 120.5.12010000.3 2008/08/22 14:32:03 anvarshn ship $ */

 --
 G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_OTM_RIQ_XML';
 --
	--XPATH expressions
	--Status Code
	G_XPATH_SM_STATUS_PREFIX CONSTANT VARCHAR2(200):='/RemoteQueryReply/OrderRoutingRuleReply';
	G_XPATH_RIQ_STATUS_PREFIX CONSTANT VARCHAR2(200):='/RemoteQueryReply/RIQQueryReply';

	G_XPATH_STATUS_CODE CONSTANT VARCHAR2(200):='/RemoteQueryStatus/RemoteQueryStatusCode/text()';
	--Status Message
	G_XPATH_STATUS_MESSAGE CONSTANT VARCHAR2(200):='/RemoteQueryStatus/RemoteQueryStatusMessage/text()';
	--Log messages
	G_XPATH_MESSAGES CONSTANT VARCHAR2(200):='/RemoteQueryStatus/TransactionReport/IntegrationLogMessage/IMessageText';
	--Selects one option for the Choose Ship Method Action
	G_XPATH_SM_OPTION CONSTANT VARCHAR2(200):='/RemoteQueryReply/RIQQueryReply/RIQResult';
	--Gets the result for the Get Freight Cost action
	G_XPATH_FREIGHT_COST_RESULT CONSTANT VARCHAR2(200):='/RemoteQueryReply/RIQQueryReply/RIQResult';
	--Gets the result for the Get Ship Method action
	G_XPATH_GET_SM_RESULT CONSTANT VARCHAR2(200):='/RemoteQueryReply/OrderRoutingRuleReply';

	G_XPATH_SM_OPTION_PREFIX CONSTANT VARCHAR2(200):='/RIQResult';
	G_XPATH_FREIGHT_COST_PREFIX CONSTANT VARCHAR2(200):='/RIQResult';
	G_XPATH_GET_SM_PREFIX CONSTANT VARCHAR2(200):='/OrderRoutingRuleReply';


	G_XPATH_CARRIER  CONSTANT VARCHAR2(200):='/ServiceProviderGid/Gid/Xid/text()';
	G_XPATH_MODE  CONSTANT VARCHAR2(200):='/TransportModeGid/Gid/Xid/text()';
	G_XPATH_SERVICE_LEVEL  CONSTANT VARCHAR2(200):='/RateServiceGid/Gid/Xid/text()';
	G_XPATH_FREIGHT_TERMS CONSTANT  VARCHAR2(200):='/PaymentMethodCodeGid/Gid/Xid/text()';
	G_XPATH_TRANSIT_TIME  CONSTANT VARCHAR2(200):='/TransitTime/Duration/DurationValue/text()';
	G_XPATH_TRANSIT_TIME_UOM  CONSTANT VARCHAR2(200):='/TransitTime/Duration/DurationUOMGid/Gid/Xid/text()';
	G_XPATH_COST_SUMMARY  CONSTANT VARCHAR2(200):='/Cost/FinancialAmount/MonetaryAmount/text()';
	G_XPATH_COST_SUMMARY_CURRENCY  CONSTANT VARCHAR2(200):='/Cost/FinancialAmount/GlobalCurrencyCode/text()';
	G_XPATH_COST_DETAILS  CONSTANT VARCHAR2(200):='/CostDetails';
	G_XPATH_COST_DETAIL_TYPE  CONSTANT VARCHAR2(200):='/CostType/text()';

	G_CARRIER_PREFIX CONSTANT VARCHAR2(4):='CAR-';
	G_CARRIER_PREFIX_LENGTH CONSTANT NUMBER:=LENGTH(G_CARRIER_PREFIX);
	G_ORG_LOCATION_PREFIX CONSTANT VARCHAR2(4):='ORG-';
	G_CUST_LOCATION_PREFIX CONSTANT VARCHAR2(4):='CUS-';
	G_LOCATION_SEPERATOR CONSTANT VARCHAR2(1):='-';
	--TODO old NS map
	G_GLOG_NS_MAP CONSTANT VARCHAR2(200):='xmlns="http://glog.com"';
	G_OTM_NS_MAP CONSTANT VARCHAR2(200):='xmlns="http://xmlns.oracle.com/apps/otm"';

	g_carrier_freight_codes WSH_NEW_DELIVERY_ACTIONS.TableVarchar30;
	g_carrier_generic_flags WSH_NEW_DELIVERY_ACTIONS.TableVarchar3;

	g_state_region_type CONSTANT NUMBER:=1;
	g_price_cost_type_id NUMBER;
	g_domain_name VARCHAR2(50);
	g_servlet_uri VARCHAR2(4000) := NULL;
	g_user_name VARCHAR2(101);
	g_password VARCHAR2(128);
	g_timezone_code VARCHAR2(50);
	g_global_time_class VARCHAR2(30);
	g_xml_namespace_map VARCHAR2(200);
	/*Bug7329859*/
        g_source_line_tab_temp FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_TAB;
        /*Bug7329859*/

TYPE WSH_UOM_MAP_TAB IS TABLE OF VARCHAR2(30)
INDEX BY VARCHAR2(30);
	g_EBS_to_OTM_UOM_map WSH_UOM_MAP_TAB;
	g_OTM_to_EBS_UOM_map WSH_UOM_MAP_TAB;

TYPE WSH_SM_REC IS RECORD(
	id	NUMBER,
	summary_rate NUMBER,
	base_rate NUMBER,
	charge_rate NUMBER,
	carrier_id NUMBER,
	mode_of_transport VARCHAR2(30),
	service_level VARCHAR2(30),
	freight_terms VARCHAR2(30),
	transit_time NUMBER,
	transit_time_UOM VARCHAR2(30),
	ship_method_code VARCHAR2(30)
);
TYPE WSH_SM_TAB IS TABLE OF WSH_SM_REC
INDEX BY VARCHAR2(30);

--ECO 5516007 ,FP(5573379) to R12
-- Forward Declaration
PROCEDURE DERIVE_RIQ_DATES
  (x_source_line_tab   IN OUT NOCOPY FTE_PROCESS_REQUESTS.fte_source_line_tab,
   x_source_header_tab IN OUT NOCOPY FTE_PROCESS_REQUESTS.fte_source_header_tab,
   x_return_status        OUT NOCOPY VARCHAR2);

--ECO 5516007, FP(5573379)  to R12
--=========================================================================
-- Procedure:   DERIVE_RIQ_DATES
-- Description: Derive the Ship Date and Arrival Date for the Order Lines
--              and Order Header, based on the Order Date Type.
--
-- Usage:
-- 1. When OM calls OTM to determine the rates(Rate Inquiry), this API is
--    called to ensure the appropriate dates are being passed to OTM.
--    (Calling Procedure: Call_otm_for_om)
--
-- Assumption: x_source_line_tab and x_source_header_tab have been populated
--             by the calling APIs.
--             The Input Header Tab does not necessarily correspond to a
--             single Order Header. Within a single order, we can have cases
--             like : a) 2 Order Lines with different Ship From
--             b) 2 Order Lines with different Ship To
--             c) 2 Order Lines with different Set of Scheduled Dates,
--              all the above are examples of cases where 1 order can
--             have multiple headers.
--
--=========================================================================
PROCEDURE DERIVE_RIQ_DATES
  (x_source_line_tab   IN OUT NOCOPY FTE_PROCESS_REQUESTS.fte_source_line_tab,
   x_source_header_tab IN OUT NOCOPY FTE_PROCESS_REQUESTS.fte_source_header_tab,
   x_return_status        OUT NOCOPY VARCHAR2) AS

  -- Cursor declaration Section

  -- Cursor to derive the Order Header Date Type
  CURSOR c_get_order_date_type_csr (p_header_id IN NUMBER) IS
  SELECT NVL(order_date_type_code,'SHIP')
    FROM oe_order_headers_all
   WHERE header_id = p_header_id ;

  -- Cursor to derive the Order Line Date Type
  -- Ship Date should be greatest of Sysdate and Schedule Ship Date
  -- Arrival Date should be greatest of Sysdate and Schedule Arrival Date
  -- If Schedule Ship Date/Arrival Date are not specified, use request date
  -- If Order Date Type is not 'ARRIVAL', then arrival date is treated as Null
  -- Also select schedule_ship_date and schedule_arrival_date
  --
  CURSOR c_get_line_dates_csr (p_order_date_type IN VARCHAR2, p_line_id IN NUMBER ) IS
  SELECT GREATEST(SYSDATE, NVL(schedule_ship_date, request_date)) ship_date,
         DECODE(p_order_date_type,
                'ARRIVAL',GREATEST(SYSDATE, NVL(schedule_arrival_date, request_date)),
                NULL) arrival_date,
         schedule_ship_date,
         schedule_arrival_date
    FROM oe_order_lines_all
   WHERE line_id = p_line_id;

  -- End of Cursor declaration Section

  -- Variable declaration Section
  l_line_index            NUMBER;
  l_header_index          NUMBER;
  l_order_date_type       OE_ORDER_HEADERS_ALL.ORDER_DATE_TYPE_CODE%TYPE;
  l_ship_date             OE_ORDER_LINES_ALL.SCHEDULE_SHIP_DATE%TYPE;
  l_arrival_date          OE_ORDER_LINES_ALL.SCHEDULE_ARRIVAL_DATE%TYPE;
  l_schedule_ship_date    OE_ORDER_LINES_ALL.SCHEDULE_SHIP_DATE%TYPE;
  l_schedule_arrival_date OE_ORDER_LINES_ALL.SCHEDULE_ARRIVAL_DATE%TYPE;

  l_debug_on              BOOLEAN;
  l_module_name           CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DERIVE_RIQ_DATES';

  -- End of Variable declaration Section

BEGIN

  -- Debug Logic
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'x_source_line_tab.COUNT',x_source_line_tab.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'x_source_header_tab.COUNT',x_source_header_tab.COUNT);
  END IF;

  -- Initialize the Procedure Specific Variables
  l_header_index  := 0;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF (x_source_header_tab.COUNT > 0 AND x_source_line_tab.COUNT > 0) THEN--{
    l_header_index := x_source_header_tab.FIRST;
    LOOP--{

      -- Initialize the variable for re-use across headers
      l_order_date_type       := 'N';
      l_ship_date             := NULL;
      l_arrival_date          := NULL;
      l_schedule_ship_date    := NULL;
      l_schedule_arrival_date := NULL;
      l_line_index            := 0;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'========= New Header for Lines ======');
        WSH_DEBUG_SV.log(l_module_name,'Initialized Order Date Type :',l_order_date_type);
        WSH_DEBUG_SV.log(l_module_name,'Consolidation Id :',x_source_header_tab(l_header_index).consolidation_id);
      END IF;

      l_line_index := x_source_line_tab.FIRST;
      LOOP--{

      -- Find matching header and line, using consolidation_id
      -- All the lines in a header correspond to same order_date_type,
      -- so just determine date type for each header using 1st line
      -- Still need to use the update the Ship/Arrival Dates for other
      -- order lines(as of now Order Header is used to derive the dates
      -- being passed to OTM)
      --
      IF x_source_line_tab(l_line_index).consolidation_id =
           x_source_header_tab(l_header_index).consolidation_id THEN --{

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,
                           'x_source_line_tab('||l_line_index||').source_header_id',
                           x_source_line_tab(l_line_index).source_header_id);
          WSH_DEBUG_SV.log(l_module_name,
                           'Line Consolidation Id :',
                           x_source_line_tab(l_line_index).consolidation_id);
        END IF;

        IF l_order_date_type = 'N' THEN--{
          -- Derive Order Header Information
          OPEN  c_get_order_date_type_csr
                (p_header_id => x_source_line_tab(l_line_index).source_header_id);
          FETCH c_get_order_date_type_csr INTO l_order_date_type;
          CLOSE c_get_order_date_type_csr;
          -- The variable is flagged as the variable l_order_date_type will be set to
          -- SHIP or ARRIVAL, so as not to process for this set again

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Actual order date type',l_order_date_type);
            WSH_DEBUG_SV.log(l_module_name,
                             'x_source_line_tab('||l_line_index||').source_line_id',
                             x_source_line_tab(l_line_index).source_line_id);
            WSH_DEBUG_SV.log(l_module_name,
                             'x_source_line_tab('||l_line_index||').ship_date - before changes',
                             x_source_line_tab(l_line_index).ship_date);
            WSH_DEBUG_SV.log(l_module_name,
                             'x_source_line_tab('||l_line_index||').arrival_date - before changes',
                             x_source_line_tab(l_line_index).arrival_date);
          END IF;

          -- Derive Order Line Information
          OPEN  c_get_line_dates_csr
                (p_order_date_type => l_order_date_type,
                 p_line_id         => x_source_line_tab(l_line_index).source_line_id);
          FETCH c_get_line_dates_csr
           INTO l_ship_date, l_arrival_date,
                l_schedule_ship_date, l_schedule_arrival_date;
          CLOSE c_get_line_dates_csr;

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Order Line Ship Date ',l_ship_date);
            WSH_DEBUG_SV.log(l_module_name,'Order Line Arrival Date ',l_arrival_date);
            WSH_DEBUG_SV.log(l_module_name,'Order Line Schedule Ship Date ',l_schedule_ship_date);
            WSH_DEBUG_SV.log(l_module_name,'Order Line Schedule Arrival Date ',l_schedule_arrival_date);
          END IF;

          -- For Date Type of Arrival, when the line is not scheduled, pass the arrival date
          -- and ship date should be NULL
          IF l_order_date_type = 'ARRIVAL' AND l_schedule_arrival_date is NULL THEN
            l_ship_date := null;
          END IF;

          -- If Ship_Date is same as Arrival_Date, mark Arrival_Date as Null
          IF l_ship_date = l_arrival_date THEN
            l_arrival_date := NULL;
          END IF;
        END IF;--} -- for 1st Order line, get the l_ship_date and l_arrival_date

        -- Need to update all the Order lines, without recalculating dates above
        -- use the same values
        x_source_line_tab(l_line_index).ship_date    := l_ship_date;
        x_source_line_tab(l_line_index).arrival_date := l_arrival_date;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,
                           'x_source_line_tab('||l_line_index||').ship_date - after changes ',
                           x_source_line_tab(l_line_index).ship_date);
          WSH_DEBUG_SV.log(l_module_name,
                           'x_source_line_tab('||l_line_index||').arrival_date - after changes ',
                           x_source_line_tab(l_line_index).arrival_date);
        END IF;
      END IF;--}

      EXIT WHEN l_line_index >= x_source_line_tab.LAST;
      l_line_index := x_source_line_tab.NEXT(l_line_index);
      END LOOP; --} -- loop for lines

      -- Setting the Ship and Arrival Date for the Header
      -- Header is created based on the grouping criterias including
      -- Scheduled Dates of Lines, Ship From/To and other criterias
      -- As the inside loop is for Lines, ensure the call for header is
      -- in the header loop
      x_source_header_tab(l_header_index).ship_date    := l_ship_date;
      x_source_header_tab(l_header_index).arrival_date := l_arrival_date;

      -- Print Header Information outside the Loop for Order Lines
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,
                         'x_source_header_tab('||l_header_index||').ship_date after changes ',
                         x_source_header_tab(l_header_index).ship_date);
        WSH_DEBUG_SV.log(l_module_name,
                         'x_source_header_tab('||l_header_index||').arrival_date after changes ',
                         x_source_header_tab(l_header_index).arrival_date);
        WSH_DEBUG_SV.logmsg(l_module_name,'=====================================');
      END IF;

      EXIT WHEN l_header_index >= x_source_header_tab.LAST;
      l_header_index := x_source_header_tab.NEXT(l_header_index);
    END LOOP;--} -- loop for header

  END IF;--} -- x_source_header_tab and x_source_line_tab are populated

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF c_get_order_date_type_csr%ISOPEN THEN
      CLOSE c_get_order_date_type_csr;
    END IF;

    IF c_get_line_dates_csr%ISOPEN THEN
      CLOSE c_get_line_dates_csr;
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_OTM_RIQ_XML.DERIVE_RIQ_DATES',l_module_name);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.logmsg(l_module_name,
                          'Unexpected error has occured in derive_riq_dates. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

END DERIVE_RIQ_DATES;
-- End of ECO 5516007, FP to R12
--=========================================================================


PROCEDURE print_CLOB(
	p_clob IN CLOB,
	x_return_status  OUT NOCOPY VARCHAR2)
  IS

	i NUMBER;
	l_amt NUMBER;
	l_pos NUMBER;
	l_buffer         VARCHAR2(32767);
	l_length NUMBER;
	l_return_status VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'print_CLOB';

BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;





	IF (l_debug_on AND p_clob IS NOT NULL)
	THEN
		l_amt:= 32000;
		l_pos:= 1;
		l_length:=DBMS_LOB.GETLENGTH(p_clob);

		WSH_DEBUG_SV.log(l_module_name,'Length',l_length);

		WHILE(l_length > 0)
		LOOP

			IF (l_length < l_amt)
			THEN

				l_amt:=l_length;

			END IF;

			dbms_lob.read (p_clob, l_amt, l_pos, l_buffer);

			WSH_DEBUG_SV.log(l_module_name, l_buffer);

			l_length:=l_length-l_amt;
			l_pos := l_pos + l_amt;
		END LOOP;


	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.print_CLOB',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END print_CLOB;



PROCEDURE print_source_line_tab (
p_source_line_tab  IN FTE_PROCESS_REQUESTS.fte_source_line_tab,
x_return_status  OUT NOCOPY VARCHAR2)
  IS

	i NUMBER;
	l_return_status VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'print_source_line_tab';

BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;




	i := p_source_line_tab.FIRST;
	IF ((i IS NOT NULL) AND (l_debug_on))
	THEN
	WSH_DEBUG_SV.log(l_module_name,'-----------BEGIN Source Line Tab -------------');
	LOOP
	WSH_DEBUG_SV.log(l_module_name,'i := '||i);

	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).source_type ',p_source_line_tab(i).source_type);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).source_header_id ',p_source_line_tab(i).source_header_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).source_line_id ',p_source_line_tab(i).source_line_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).ship_from_org_id ',p_source_line_tab(i).ship_from_org_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).ship_from_location_id ',p_source_line_tab(i).ship_from_location_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).ship_to_site_id ',p_source_line_tab(i).ship_to_site_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).ship_to_location_id ',p_source_line_tab(i).ship_to_location_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).customer_id ',p_source_line_tab(i).customer_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).inventory_item_id ',p_source_line_tab(i).inventory_item_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).source_quantity ',p_source_line_tab(i).source_quantity);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).source_quantity_uom ',p_source_line_tab(i).source_quantity_uom);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).ship_date ',p_source_line_tab(i).ship_date);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).arrival_date ',p_source_line_tab(i).arrival_date);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).delivery_lead_time ',p_source_line_tab(i).delivery_lead_time);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).scheduled_flag ',p_source_line_tab(i).scheduled_flag);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).order_set_type ',p_source_line_tab(i).order_set_type);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).order_set_id ',p_source_line_tab(i).order_set_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).intmed_ship_to_site_id ',p_source_line_tab(i).intmed_ship_to_site_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).intmed_ship_to_loc_id ',p_source_line_tab(i).intmed_ship_to_loc_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).carrier_id ',p_source_line_tab(i).carrier_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).ship_method_flag ',p_source_line_tab(i).ship_method_flag);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).ship_method_code ',p_source_line_tab(i).ship_method_code);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).freight_carrier_code ',p_source_line_tab(i).freight_carrier_code);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).service_level ',p_source_line_tab(i).service_level);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).mode_of_transport ',p_source_line_tab(i).mode_of_transport);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).freight_terms ',p_source_line_tab(i).freight_terms);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).fob_code ',p_source_line_tab(i).fob_code);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).weight  ',p_source_line_tab(i).weight );
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).weight_uom_code ',p_source_line_tab(i).weight_uom_code);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).volume  ',p_source_line_tab(i).volume );
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).volume_uom_code ',p_source_line_tab(i).volume_uom_code);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).freight_rating_flag ',p_source_line_tab(i).freight_rating_flag);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).freight_rate ',p_source_line_tab(i).freight_rate);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).freight_rate_currency ',p_source_line_tab(i).freight_rate_currency);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).status  ',p_source_line_tab(i).status );
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).message_data ',p_source_line_tab(i).message_data);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).consolidation_id ',p_source_line_tab(i).consolidation_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).override_ship_method ',p_source_line_tab(i).override_ship_method);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).currency ',p_source_line_tab(i).currency);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).currency_conversion_type ',p_source_line_tab(i).currency_conversion_type);


	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).origin_country ',p_source_line_tab(i).origin_country);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).origin_state ',p_source_line_tab(i).origin_state);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).origin_city ',p_source_line_tab(i).origin_city);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).origin_zip ',p_source_line_tab(i).origin_zip);

	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).destination_country ',p_source_line_tab(i).destination_country);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).destination_state ',p_source_line_tab(i).destination_state);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).destination_city ',p_source_line_tab(i).destination_city);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).destination_zip ',p_source_line_tab(i).destination_zip);

	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).distance ',p_source_line_tab(i).distance);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).distance_uom ',p_source_line_tab(i).distance_uom);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).vehicle_item_id ',p_source_line_tab(i).vehicle_item_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_line_tab(i).commodity_category_id ',p_source_line_tab(i).commodity_category_id);


	WSH_DEBUG_SV.log(l_module_name,'------------------------');

	EXIT WHEN (i >= p_source_line_tab.LAST);
	i := p_source_line_tab.NEXT(i);
	END LOOP;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.print_source_line_tab',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END print_source_line_tab;

PROCEDURE print_source_header_tab (
	p_source_header_tab IN FTE_PROCESS_REQUESTS.fte_source_header_tab,
	x_return_status  OUT NOCOPY VARCHAR2)
IS
	i NUMBER;
	l_return_status VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'print_source_header_tab';

BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;




	i := p_source_header_tab.FIRST;
	IF ((i IS NOT NULL) AND (l_debug_on)) THEN
	WSH_DEBUG_SV.log(l_module_name,'-----------BEGIN Source Header Tab -------------');
	LOOP
	WSH_DEBUG_SV.log(l_module_name,'i ',i);

	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).consolidation_id ',p_source_header_tab(i).consolidation_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).ship_from_org_id ',p_source_header_tab(i).ship_from_org_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).ship_from_location_id ',p_source_header_tab(i).ship_from_location_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).ship_to_location_id ',p_source_header_tab(i).ship_to_location_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).ship_to_site_id ',p_source_header_tab(i).ship_to_site_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).customer_id ',p_source_header_tab(i).customer_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).ship_date ',p_source_header_tab(i).ship_date);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).arrival_date ',p_source_header_tab(i).arrival_date);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).delivery_lead_time ',p_source_header_tab(i).delivery_lead_time);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).scheduled_flag ',p_source_header_tab(i).scheduled_flag);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).total_weight ',p_source_header_tab(i).total_weight);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).weight_uom_code ',p_source_header_tab(i).weight_uom_code);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).total_volume ',p_source_header_tab(i).total_volume);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).volume_uom_code ',p_source_header_tab(i).volume_uom_code);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).ship_method_code ',p_source_header_tab(i).ship_method_code);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).carrier_id ',p_source_header_tab(i).carrier_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).service_level ',p_source_header_tab(i).service_level);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).mode_of_transport ',p_source_header_tab(i).mode_of_transport);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).freight_terms ',p_source_header_tab(i).freight_terms);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).status  ',p_source_header_tab(i).status );
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).message_data ',p_source_header_tab(i).message_data);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).enforce_lead_time ',p_source_header_tab(i).enforce_lead_time);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).currency ',p_source_header_tab(i).currency);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).currency_conversion_type ',p_source_header_tab(i).currency_conversion_type);

	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).origin_country ',p_source_header_tab(i).origin_country);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).origin_state ',p_source_header_tab(i).origin_state);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).origin_city ',p_source_header_tab(i).origin_city);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).origin_zip ',p_source_header_tab(i).origin_zip);


	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).destination_country ',p_source_header_tab(i).destination_country);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).destination_state ',p_source_header_tab(i).destination_state);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).destination_city ',p_source_header_tab(i).destination_city);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).destination_zip ',p_source_header_tab(i).destination_zip);

	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).distance ',p_source_header_tab(i).distance);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).distance_uom ',p_source_header_tab(i).distance_uom);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).vehicle_item_id ',p_source_header_tab(i).vehicle_item_id);
	WSH_DEBUG_SV.log(l_module_name,'l_source_header_tab(i).commodity_category_id ',p_source_header_tab(i).commodity_category_id);


	WSH_DEBUG_SV.log(l_module_name,'------------------------');


	EXIT WHEN (i >= p_source_header_tab.LAST);
	i := p_source_header_tab.NEXT(i);
	END LOOP;
	END IF;


	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.print_source_header_tab',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END print_source_header_tab;


PROCEDURE print_rates_tab (
	p_source_line_rates_tab IN FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
	p_source_header_rates_tab IN FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
	x_return_status         OUT NOCOPY  VARCHAR2)
   IS
	i NUMBER;
	l_return_status VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'print_rates_tab';

BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;



	i := p_source_line_rates_tab.FIRST;
	IF (i IS NOT NULL) THEN
	WSH_DEBUG_SV.log(l_module_name,'-----------BEGIN Source Line Rates Tab -------------');
	LOOP
	WSH_DEBUG_SV.log(l_module_name,'I',i);
	WSH_DEBUG_SV.log(l_module_name,'source_line_id',p_source_line_rates_tab(i).source_line_id);
	WSH_DEBUG_SV.log(l_module_name,'cost_type_id',p_source_line_rates_tab(i).cost_type_id);
	WSH_DEBUG_SV.log(l_module_name,'line_type_code',p_source_line_rates_tab(i).line_type_code);
	WSH_DEBUG_SV.log(l_module_name,'cost_type',p_source_line_rates_tab(i).cost_type);
	WSH_DEBUG_SV.log(l_module_name,'cost_sub_type',p_source_line_rates_tab(i).cost_sub_type);
	WSH_DEBUG_SV.log(l_module_name,'priced_quantity',p_source_line_rates_tab(i).priced_quantity);
	WSH_DEBUG_SV.log(l_module_name,'priced_uom',p_source_line_rates_tab(i).priced_uom);
	WSH_DEBUG_SV.log(l_module_name,'unit_price',p_source_line_rates_tab(i).unit_price);
	WSH_DEBUG_SV.log(l_module_name,'base_price',p_source_line_rates_tab(i).base_price);
	WSH_DEBUG_SV.log(l_module_name,'adjusted_unit_price',p_source_line_rates_tab(i).adjusted_unit_price);
	WSH_DEBUG_SV.log(l_module_name,'adjusted_price',p_source_line_rates_tab(i).adjusted_price);
	WSH_DEBUG_SV.log(l_module_name,'currency',p_source_line_rates_tab(i).currency);
	WSH_DEBUG_SV.log(l_module_name,'consolidation_id',p_source_line_rates_tab(i).consolidation_id);
	WSH_DEBUG_SV.log(l_module_name,'lane_id',p_source_line_rates_tab(i).lane_id);
	WSH_DEBUG_SV.log(l_module_name,'carrier_id',p_source_line_rates_tab(i).carrier_id);
	WSH_DEBUG_SV.log(l_module_name,'carrier_freight_code',p_source_line_rates_tab(i).carrier_freight_code);
	WSH_DEBUG_SV.log(l_module_name,'service_level',p_source_line_rates_tab(i).service_level);
	WSH_DEBUG_SV.log(l_module_name,'mode_of_transport',p_source_line_rates_tab(i).mode_of_transport);
	WSH_DEBUG_SV.log(l_module_name,'ship_method_code',p_source_line_rates_tab(i).ship_method_code);
	WSH_DEBUG_SV.log(l_module_name,'------------------------');

	EXIT WHEN (i >= p_source_line_rates_tab.LAST);
	i := p_source_line_rates_tab.NEXT(i);
	END LOOP;
	END IF;

	WSH_DEBUG_SV.log(l_module_name,'-----------BEGIN Source header Rates Tab -------------');

	i := p_source_header_rates_tab.FIRST;
	IF (i IS NOT NULL) THEN
	LOOP
	WSH_DEBUG_SV.log(l_module_name,'I',i);
	WSH_DEBUG_SV.log(l_module_name,'consolidation_id',p_source_header_rates_tab(i).consolidation_id);
	WSH_DEBUG_SV.log(l_module_name,'lane_id',p_source_header_rates_tab(i).lane_id);
	WSH_DEBUG_SV.log(l_module_name,'carrier_id',p_source_header_rates_tab(i).carrier_id);
	WSH_DEBUG_SV.log(l_module_name,'carrier_freight_code',p_source_header_rates_tab(i).carrier_freight_code);
	WSH_DEBUG_SV.log(l_module_name,'service_level',p_source_header_rates_tab(i).service_level);
	WSH_DEBUG_SV.log(l_module_name,'mode_of_transport',p_source_header_rates_tab(i).mode_of_transport);
	WSH_DEBUG_SV.log(l_module_name,'ship_method_code',p_source_header_rates_tab(i).ship_method_code);
	WSH_DEBUG_SV.log(l_module_name,'cost_type_id',p_source_header_rates_tab(i).cost_type_id);
	WSH_DEBUG_SV.log(l_module_name,'cost_type',p_source_header_rates_tab(i).cost_type);
	WSH_DEBUG_SV.log(l_module_name,'price',p_source_header_rates_tab(i).price);
	WSH_DEBUG_SV.log(l_module_name,'currency',p_source_header_rates_tab(i).currency);
	WSH_DEBUG_SV.log(l_module_name,'transit_time',p_source_header_rates_tab(i).transit_time);
	WSH_DEBUG_SV.log(l_module_name,'transit_time_uom',p_source_header_rates_tab(i).transit_time_uom);
	WSH_DEBUG_SV.log(l_module_name,'first_line_index',p_source_header_rates_tab(i).first_line_index);
	WSH_DEBUG_SV.log(l_module_name,'------------------------');

	EXIT WHEN (i >= p_source_header_rates_tab.LAST);
	i := p_source_header_rates_tab.NEXT(i);
	END LOOP;
	END IF;
	WSH_DEBUG_SV.log(l_module_name,'----   END Source header Rates Tab ------- ');

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.print_rates_tab',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END print_rates_tab;



PROCEDURE print_CS_Results(
	p_result_consolidation_id_tab  IN WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	p_result_carrier_id_tab        IN WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	p_result_service_level_tab     IN WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	p_result_mode_of_transport_tab IN WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	p_result_freight_term_tab      IN WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	p_result_transit_time_min_tab	IN WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	p_result_transit_time_max_tab	IN WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	p_ship_method_code_tab         IN WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_return_status         OUT NOCOPY  VARCHAR2)
   IS
	i NUMBER;
	l_return_status VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'print_CS_Results';

BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;



	i := p_result_consolidation_id_tab.FIRST;
	IF (i IS NOT NULL) THEN
	WSH_DEBUG_SV.log(l_module_name,'-----------BEGIN CS Results -------------');
	LOOP
	WSH_DEBUG_SV.log(l_module_name,'I',i);
	WSH_DEBUG_SV.log(l_module_name,'consol_id',p_result_consolidation_id_tab(i));
	IF (p_result_carrier_id_tab.EXISTS(i))
	THEN
		WSH_DEBUG_SV.log(l_module_name,'carrier_id',p_result_carrier_id_tab(i));
	END IF;
	IF (p_result_service_level_tab.EXISTS(i))
	THEN
		WSH_DEBUG_SV.log(l_module_name,'service_level',p_result_service_level_tab(i));
	END IF;

	IF (p_result_mode_of_transport_tab.EXISTS(i))
	THEN
		WSH_DEBUG_SV.log(l_module_name,'mode_of_transport',p_result_mode_of_transport_tab(i));
	END IF;

	IF (p_result_freight_term_tab.EXISTS(i))
	THEN
		WSH_DEBUG_SV.log(l_module_name,'freight_term',p_result_freight_term_tab(i));
	END IF;

	IF (p_result_transit_time_min_tab.EXISTS(i))
	THEN
		WSH_DEBUG_SV.log(l_module_name,'transit_time_min',p_result_transit_time_min_tab(i));
	END IF;


	IF (p_result_transit_time_max_tab.EXISTS(i))
	THEN
		WSH_DEBUG_SV.log(l_module_name,'transit_time_max',p_result_transit_time_max_tab(i));
	END IF;

	IF (p_ship_method_code_tab.EXISTS(i))
	THEN
		WSH_DEBUG_SV.log(l_module_name,'ship_method_code',p_ship_method_code_tab(i));
	END IF;


	WSH_DEBUG_SV.log(l_module_name,'------------------------');

	EXIT WHEN (i >= p_result_consolidation_id_tab.LAST);
	i := p_result_consolidation_id_tab.NEXT(i);
	END LOOP;
	END IF;

	WSH_DEBUG_SV.log(l_module_name,'----   END CS Results ------- ');

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.print_rates_tab',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END print_CS_Results;


FUNCTION  Convert_Carrier_Ouput(
	p_carrier IN VARCHAR2) RETURN NUMBER
	IS

	l_carrier_prefix VARCHAR2(4);
	l_carrier VARCHAR2(30);
	l_carrier_id NUMBER;
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Convert_Carrier_Ouput';

BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	l_carrier_id:=NULL;



	IF ((p_carrier IS NOT NULL) AND (LENGTH(p_carrier) > 4)AND (LENGTH(p_carrier) < 34))
	THEN
		l_carrier_prefix:=SUBSTR(p_carrier,1,4);
		IF(l_carrier_prefix = G_CARRIER_PREFIX)
		THEN
			l_carrier:=SUBSTR(p_carrier,5);
			l_carrier_id:=TO_NUMBER(l_carrier);
		END IF;
	END IF;

	IF l_debug_on THEN

		WSH_DEBUG_SV.pop(l_module_name);
	END IF;

	RETURN l_carrier_id;

	--
	EXCEPTION

	WHEN others THEN

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	RETURN NULL;
	--

END Convert_Carrier_Ouput;


FUNCTION  Convert_To_Number(
	p_string IN VARCHAR2) RETURN NUMBER
	IS
	l_number NUMBER;
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Convert_To_Number';

BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	l_number:=NULL;

	l_number := TO_NUMBER(p_string);

	IF l_debug_on THEN

		WSH_DEBUG_SV.pop(l_module_name);
	END IF;

	RETURN l_number;

	--
	EXCEPTION

	WHEN others THEN

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	RETURN NULL;
	--

END Convert_To_Number;

--WSH_UTIL_VALIDATE.Validate_Carrier accepts carrier name not id

PROCEDURE Validate_Carrier(
	p_carrier_id IN NUMBER,
	x_return_status			OUT NOCOPY	VARCHAR2)
IS
	l_carrier_id NUMBER;

	l_return_status VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Carrier';

CURSOR c_check_carrier(c_carrier_id IN NUMBER)
IS
SELECT carrier_id
FROM WSH_CARRIERS
WHERE carrier_id= c_carrier_id;

BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_carrier_id:=NULL;

	IF(p_carrier_id IS NOT NULL)
	THEN
		OPEN c_check_carrier(p_carrier_id);
		FETCH c_check_carrier INTO l_carrier_id;
		CLOSE c_check_carrier;

	END IF;

	IF (l_carrier_id IS NULL)
	THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Validate_Carrier',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END Validate_Carrier;


PROCEDURE Validate_Look_Up_NoCase(
	p_lookup_code IN VARCHAR2,
	p_lookup_type IN VARCHAR2,
	x_lookup_code OUT NOCOPY VARCHAR2,
	x_return_status			OUT NOCOPY	VARCHAR2)
IS
	l_code VARCHAR2(30);

	l_return_status VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Look_Up_NoCase';

-- fixed in R12, select from fnd_lookup_values not from oe_lookups
-- cause WSH_SERVICE_LEVELS, WSH_MODE_OF_TRANSPORT are not defined in oe_lookup

CURSOR c_check_lookup(c_lookup_code IN VARCHAR2)
IS
  SELECT lookup_code
    FROM fnd_lookup_values
   WHERE lookup_type = p_lookup_type
     AND UPPER(lookup_code) = UPPER(c_lookup_code)
     AND nvl(start_date_active,SYSDATE) <= SYSDATE
     AND nvl(end_date_active,SYSDATE)   >= SYSDATE
     AND enabled_flag = 'Y'
     AND view_application_id in (660,665);

BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
                wsh_debug_sv.log(l_module_name, 'lookup_code', p_lookup_code);
                wsh_debug_sv.log(l_module_name, 'lookup_type', p_lookup_type);
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_code:=NULL;

	IF(p_lookup_code IS NOT NULL)
	THEN
		OPEN c_check_lookup(p_lookup_code);
		FETCH c_check_lookup INTO l_code;
		CLOSE c_check_lookup;

	END IF;

	x_lookup_code:=l_code;

	IF (l_code IS NULL)
	THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Validate_Look_Up_NoCase',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END Validate_Look_Up_NoCase;



PROCEDURE Get_OTM_To_EBS_UOM(
	p_uom IN VARCHAR2,
	p_uom_class IN VARCHAR2,
	x_uom OUT NOCOPY VARCHAR2,
	x_return_status			OUT NOCOPY	VARCHAR2)
	IS

	CURSOR c_get_EBS_UOM(c_uom_class IN VARCHAR2,c_uom IN VARCHAR2)
	IS
	SELECT uom_code
	FROM MTL_UNITS_OF_MEASURE
	WHERE uom_class=c_uom_class
	AND nvl(disable_date, sysdate) >= SYSDATE
	AND attribute15=c_uom;

	CURSOR c_check_uom(c_uom_class IN VARCHAR2, c_uom IN VARCHAR2)
	IS
	SELECT UOM_CODE
	FROM mtl_units_of_measure
	WHERE uom_code = c_uom
	AND nvl(disable_date, sysdate) >= SYSDATE
	AND uom_class = c_uom_class;


	l_uom VARCHAR2(30);

	l_return_status VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_OTM_To_EBS_UOM';


BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;



	l_uom:=NULL;
	IF(p_uom IS NOT NULL)
	THEN

		IF (g_OTM_to_EBS_UOM_map.EXISTS(p_uom))
		THEN
			l_uom:=g_OTM_to_EBS_UOM_map(p_uom);

		ELSE


			OPEN c_check_uom(p_uom_class,p_uom);
			FETCH c_check_uom INTO l_uom;
			CLOSE c_check_uom;

			IF(l_uom IS NULL)
			THEN

				OPEN c_get_EBS_UOM(p_uom_class,p_uom);
				FETCH c_get_EBS_UOM INTO l_uom;
				CLOSE c_get_EBS_UOM;
			END IF;

			g_OTM_to_EBS_UOM_map(p_uom):=l_uom;

		END IF;
	END IF;

	x_uom:=l_uom;

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Get_OTM_To_EBS_UOM',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END Get_OTM_To_EBS_UOM;



PROCEDURE Get_EBS_To_OTM_UOM(
	p_uom IN VARCHAR2,
	x_uom OUT NOCOPY VARCHAR2,
	x_return_status			OUT NOCOPY	VARCHAR2)
	IS

	CURSOR c_get_OTM_UOM(c_uom IN VARCHAR2)
	IS
	SELECT attribute15
	FROM MTL_UNITS_OF_MEASURE
	WHERE uom_code=c_uom
	AND nvl(disable_date, sysdate) >= SYSDATE;

	l_uom VARCHAR2(30);

	l_return_status VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_EBS_To_OTM_UOM';


BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;



	l_uom:=NULL;
	IF(p_uom IS NOT NULL)
	THEN

		IF (g_EBS_to_OTM_UOM_map.EXISTS(p_uom))
		THEN
			l_uom:=g_EBS_to_OTM_UOM_map(p_uom);

		ELSE

			OPEN c_get_OTM_UOM(p_uom);
			FETCH c_get_OTM_UOM INTO l_uom;
			CLOSE c_get_OTM_UOM;

			IF (l_uom IS NULL)
			THEN
				l_uom:=p_uom;
			END IF;
			g_EBS_to_OTM_UOM_map(p_uom):=l_uom;

		END IF;
	END IF;

	x_uom:=l_uom;

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Get_EBS_To_OTM_UOM',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END Get_EBS_To_OTM_UOM;


PROCEDURE Get_Carrier_Info(
	p_carrier_id IN NUMBER,
	x_generic OUT NOCOPY VARCHAR2,
	x_carrier_freight_code OUT NOCOPY VARCHAR2,
	x_return_status			OUT NOCOPY	VARCHAR2)
	IS

   CURSOR c_get_carrier_info (c_carrier_id VARCHAR2) IS
   SELECT freight_code,generic_flag
   FROM   wsh_carriers
   WHERE carrier_id = c_carrier_id;

	l_carrier_freight_code VARCHAR2(30);
	l_generic_carrier VARCHAR2(1);

	l_return_status VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Carrier_Info';

BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF((g_carrier_freight_codes.EXISTS(p_carrier_id)) AND (g_carrier_generic_flags.EXISTS(p_carrier_id)))
	THEN
		x_generic:=g_carrier_generic_flags(p_carrier_id);
		x_carrier_freight_code:=g_carrier_freight_codes(p_carrier_id);
	ELSE

		OPEN c_get_carrier_info(p_carrier_id);
		FETCH c_get_carrier_info INTO l_carrier_freight_code,l_generic_carrier;
		CLOSE c_get_carrier_info;

		g_carrier_freight_codes(p_carrier_id):=l_carrier_freight_code;
		g_carrier_generic_flags(p_carrier_id):=l_generic_carrier;

		x_generic:=l_generic_carrier;
		x_carrier_freight_code:=l_carrier_freight_code;

	END IF;





	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Get_Carrier_Info',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END Get_Carrier_Info;


PROCEDURE Sort(
	x_source_header_rates_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_RATES_TAB,
	x_return_status			OUT NOCOPY	VARCHAR2)
	IS

	CURSOR c_sort(c_tab IN WSH_OTM_RIQ_SORT_TAB)
	IS
	SELECT position
	FROM TABLE (CAST (c_tab AS WSH_OTM_RIQ_SORT_TAB))
	ORDER BY numberValue;

	i NUMBER;
	j NUMBER;
	l_count NUMBER;

	l_sort_tab WSH_OTM_RIQ_SORT_TAB;
	l_sort_rec WSH_OTM_RIQ_SORT_REC;
	l_index_tab WSH_NEW_DELIVERY_ACTIONS.TableNumbers;
	l_out_tab FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_RATES_TAB;

	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Sort';
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
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_count:=x_source_header_rates_tab.COUNT;

	IF (l_count > 0)
	THEN

		l_sort_rec:= NEW WSH_OTM_RIQ_SORT_REC();
		l_sort_tab:= NEW WSH_OTM_RIQ_SORT_TAB(l_sort_rec);
		j:=l_sort_tab.FIRST;
		l_sort_tab.EXTEND(l_count-1,j);

		--l_sort_tab now has l_count unitialized records
		i:=x_source_header_rates_tab.FIRST;
		WHILE(i IS NOT NULL)
		LOOP
			l_sort_tab(j).position:=i;
			l_sort_tab(j).numberValue:=x_source_header_rates_tab(i).price;

			j:=l_sort_tab.NEXT(j);
			i:=x_source_header_rates_tab.NEXT(i);
		END LOOP;

		OPEN c_sort(l_sort_tab);
		FETCH c_sort BULK COLLECT INTO l_index_tab;
		CLOSE c_sort;

		--Use sorted index to copy sorted results
		i:=l_index_tab.FIRST;
		WHILE (i IS NOT NULL)
		LOOP
			l_out_tab(i):=x_source_header_rates_tab(l_index_tab(i));

			i:=l_index_tab.NEXT(i);
		END LOOP;

		x_source_header_rates_tab.DELETE;

		--Copy to output
		x_source_header_rates_tab:=l_out_tab;

		l_out_tab.DELETE;
		l_index_tab.DELETE;
		l_sort_tab.DELETE;

	END IF;
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Sort',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Sort;


PROCEDURE Validate_Transit_Time(
	x_transit_time IN OUT NOCOPY NUMBER,
	x_transit_time_uom IN OUT NOCOPY VARCHAR2,
	x_return_status	OUT NOCOPY	VARCHAR2)
IS


	l_transit_time NUMBER;
	l_transit_time_uom VARCHAR(3);

	l_return_status VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Transit_Time';

BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_transit_time:=NULL;
	l_transit_time_uom:=NULL;

	IF ((x_transit_time IS NOT NULL) AND (x_transit_time_uom IS NOT NULL) AND (g_global_time_class IS NOT NULL))
	THEN


		Get_OTM_To_EBS_UOM(
			p_uom=>x_transit_time_uom,
			p_uom_class=>g_global_time_class,
			x_uom=>l_transit_time_uom,
			x_return_status=>l_return_status);
		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Get_OTM_To_EBS_UOM Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;


		IF (l_transit_time_uom IS NOT NULL)
		THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.log(l_module_name,'time UOM Code valid',x_transit_time_uom);
			END IF;

			l_transit_time:=x_transit_time;
		ELSE
			IF l_debug_on THEN
				WSH_DEBUG_SV.log(l_module_name,'Invalid time UOM Code',x_transit_time_uom);
			END IF;
			l_transit_time:=NULL;
			l_transit_time_uom:=NULL;

		END IF;

	END IF;

	x_transit_time:=l_transit_time;
	x_transit_time_uom:=l_transit_time_uom;



	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Validate_Transit_Time',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END Validate_Transit_Time;


PROCEDURE Get_Ship_Method_Code(
	p_org_id IN NUMBER,
	p_carrier_id IN NUMBER,
	p_mode	IN VARCHAR2,
	p_service_level IN VARCHAR2,
	x_ship_method_code OUT NOCOPY VARCHAR2,
	x_return_status			OUT NOCOPY	VARCHAR2)

	IS

   CURSOR c_get_ship_method_code (c_carrier_id VARCHAR2, c_mode_of_trans VARCHAR2, c_service_level VARCHAR2, c_org_id NUMBER) IS
   SELECT a.ship_method_code
   FROM wsh_carrier_services a, wsh_org_carrier_services b
   WHERE a.carrier_service_id = b.carrier_service_id
     AND b.organization_id = c_org_id
     AND b.enabled_flag = 'Y'
     AND a.enabled_flag = 'Y'
     AND a.mode_of_transport = c_mode_of_trans
     AND UPPER(a.service_level) = UPPER(c_service_level)
     AND a.carrier_id = c_carrier_id;

	l_ship_method_code VARCHAR2(30);
	l_return_status VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Ship_Method_Code';

BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_ship_method_code:=NULL;
	IF(p_carrier_id IS NOT NULL AND p_mode IS NOT NULL AND p_service_level IS NOT NULL)
	THEN

		OPEN c_get_ship_method_code(p_carrier_id,p_mode,p_service_level,p_org_id);
		FETCH c_get_ship_method_code INTO l_ship_method_code;
		CLOSE c_get_ship_method_code;
	END IF;
	IF(l_ship_method_code IS NULL)
	THEN
		x_ship_method_code:=NULL;
		x_return_status := FND_API.G_RET_STS_ERROR;
	ELSE
		x_ship_method_code:=l_ship_method_code;
	END IF;



	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Get_Ship_Method_Code',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END Get_Ship_Method_Code;


--For the source location pass in the location id and the org id
--For the destination location pass in location id and the customer id

PROCEDURE Get_Location_Info(
	p_location_id IN NUMBER,
	p_org_id IN NUMBER,
	p_customer_id IN NUMBER,
	x_location_xid IN OUT NOCOPY VARCHAR2,
	x_location_domain IN OUT NOCOPY VARCHAR2,
	x_postal_code IN OUT NOCOPY VARCHAR2,
	x_city IN OUT NOCOPY VARCHAR2,
	x_province_code IN OUT NOCOPY VARCHAR2,
	x_country_code IN OUT NOCOPY VARCHAR2,
	x_country_domain IN OUT NOCOPY VARCHAR2,
	x_corporation_xid IN OUT NOCOPY VARCHAR2,
	x_corporation_domain IN OUT NOCOPY VARCHAR2,
	x_return_status			OUT NOCOPY	VARCHAR2) IS


l_postal_code VARCHAR2(60);
l_city VARCHAR2(100);
l_state VARCHAR2(100);
l_country_code VARCHAR2(3);
l_state_code VARCHAR2(30);

CURSOR c_get_state_code(p_location_id IN NUMBER)
IS

SELECT r.state_code
FROM  WSH_REGION_LOCATIONS rl ,WSH_REGIONS r
WHERE rl.location_id=p_location_id
	AND rl.region_type=g_state_region_type
	AND rl.region_id = r.region_id;
/*
CURSOR c_get_loc_info(p_location_id IN NUMBER)
IS
SELECT wl.postal_code,wl.city,wl.state, ft.iso_territory_code
FROM	WSH_LOCATIONS wl, FND_TERRITORIES ft
WHERE
	wl.wsh_location_id=p_location_id
	AND wl.country=ft.territory_code;
*/
CURSOR c_get_cus_loc_info(p_location_id IN NUMBER)
IS
SELECT hz.postal_code, hz.city,hz.state,ft.iso_territory_code
FROM HZ_LOCATIONS hz,FND_TERRITORIES ft
WHERE
	hz.location_id=p_location_id
	AND hz.country=ft.territory_code;


CURSOR c_get_org_loc_info(p_location_id IN NUMBER)
IS
SELECT hr.postal_code, hr.town_or_city,hr.region_2,ft.iso_territory_code
FROM HR_LOCATIONS_ALL hr,FND_TERRITORIES ft
WHERE
	hr.location_id=p_location_id
	AND hr.country=ft.territory_code;

	l_return_status VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Location_Info';

BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
		WSH_DEBUG_SV.log(l_module_name, 'p_location_id', p_location_id);
		WSH_DEBUG_SV.log(l_module_name, 'p_org_id', p_org_id);
		WSH_DEBUG_SV.log(l_module_name, 'p_customer_id', p_customer_id);
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;


	IF((p_location_id IS NOT NULL) AND ((p_org_id IS NOT NULL) OR (p_customer_id IS NOT NULL)))
	THEN

		IF (p_org_id IS NOT NULL)
		THEN
			OPEN c_get_org_loc_info(p_location_id);
			FETCH c_get_org_loc_info INTO l_postal_code,l_city,l_state,l_country_code;
			CLOSE c_get_org_loc_info;

		ELSE

			OPEN c_get_cus_loc_info(p_location_id);
			FETCH c_get_cus_loc_info INTO l_postal_code,l_city,l_state,l_country_code;
			CLOSE c_get_cus_loc_info;

		END IF;

		OPEN c_get_state_code(p_location_id);
		FETCH c_get_state_code INTO l_state_code;
		CLOSE c_get_state_code;

		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'l_postal_code',l_postal_code);
			WSH_DEBUG_SV.log(l_module_name,'l_city',l_city);
			WSH_DEBUG_SV.log(l_module_name,'l_state',l_state);
			WSH_DEBUG_SV.log(l_module_name,'l_country_code',l_country_code);

		END IF;

		IF NOT(l_postal_code IS NULL AND l_city IS NULL AND l_state IS NULL AND l_state_code IS NULL AND l_country_code IS NULL)
		THEN


			IF(p_org_id IS NOT NULL)
			THEN
				x_location_domain:=g_domain_name;
				x_location_xid:=G_ORG_LOCATION_PREFIX||p_org_id||G_LOCATION_SEPERATOR||p_location_id;
				--x_location_xid:='ORG-'||p_location_id;
				x_corporation_domain:=g_domain_name;
				x_corporation_xid:=G_ORG_LOCATION_PREFIX||p_org_id;

			ELSIF(p_customer_id IS NOT NULL)
			THEN
				x_location_domain:=g_domain_name;
				x_location_xid:=G_CUST_LOCATION_PREFIX||p_customer_id||G_LOCATION_SEPERATOR||p_location_id;
				x_corporation_domain:=g_domain_name;
				x_corporation_xid:=G_CUST_LOCATION_PREFIX||p_customer_id;
			END IF;

			x_postal_code:=l_postal_code;
			x_city:=l_city;

			IF ((l_state_code IS NOT NULL) AND (LENGTH(l_state_code)= 2))
			THEN
				x_province_code:=l_state_code;
			ELSIF ((l_state IS NOT NULL) AND (LENGTH(l_state)= 2))
			THEN
				x_province_code:=l_state;
			ELSE
				x_province_code:=NULL;
			END IF;

			IF(l_country_code IS NOT NULL)
			THEN
				--Country code domain is PUBLIC do not specify
				--x_country_domain:=g_domain_name;
				x_country_code:=l_country_code;

			END IF;




		ELSE
			x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	ELSE
		x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;


	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION
	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Get_Location_Info',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END Get_Location_Info;



PROCEDURE Format_Line_Input_For_Xml(
	x_source_header_xml_rec		IN OUT NOCOPY WSH_OTM_RIQ_HEADER_REC,
	p_source_header_rec		IN	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_REC,
	p_source_line_tab		IN FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_TAB,
	p_source_type			IN		VARCHAR2,
	p_action			IN		VARCHAR2,
	x_source_line_tab IN OUT NOCOPY WSH_OTM_RIQ_LINE_TAB,
	x_return_status			OUT NOCOPY	VARCHAR2) IS


	CURSOR c_item_dimensions(c_inv_item_id IN NUMBER,c_org_id IN NUMBER) IS
   SELECT unit_length,unit_width,unit_height,dimension_uom_code
   FROM   mtl_system_items
   WHERE  inventory_item_id = c_inv_item_id AND organization_id=c_org_id;

	l_line_rec WSH_OTM_RIQ_LINE_REC;
	i	NUMBER;
	j	NUMBER;
	l_length NUMBER;
	l_width NUMBER;
	l_height NUMBER;
	l_dim_uom VARCHAR2(30);
	l_otm_dim_uom VARCHAR2(30);

        l_line_tab      WSH_UTIL_CORE.Id_Tab_Type;
        l_all_lines_tab WSH_UTIL_CORE.Id_Tab_Type;
        l_dummy         NUMBER;

	l_debug_on BOOLEAN;
	l_return_status VARCHAR2(1);
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Format_Line_Input_For_Xml';

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
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_line_rec:= NEW WSH_OTM_RIQ_LINE_REC();
	x_source_line_tab.DELETE;

	i:=p_source_line_tab.FIRST;
	j:=i;
	WHILE(i IS NOT NULL)
	LOOP
		IF((p_source_line_tab(i).consolidation_id IS NOT NULL )
		AND (p_source_header_rec.consolidation_id IS NOT NULL)
		AND (p_source_line_tab(i).consolidation_id = p_source_header_rec.consolidation_id))
		THEN
			x_source_line_tab.EXTEND;
			x_source_line_tab(j):=NEW WSH_OTM_RIQ_LINE_REC();

			--Dummy Value for LineNumber
			x_source_line_tab(j).LineNumber:=j;

			--Weight
			x_source_line_tab(j).Weight:=p_source_line_tab(i).weight;
			IF (x_source_line_tab(j).Weight IS NULL)
			THEN
				x_source_line_tab(j).Weight:=0;
			END IF;

			Get_EBS_To_OTM_UOM(
				p_uom=>p_source_line_tab(i).weight_uom_code,
				x_uom=>x_source_line_tab(j).WeightUOM,
				x_return_status=>l_return_status);
			IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
				 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
				IF l_debug_on
				THEN
					WSH_DEBUG_SV.log(l_module_name,'Get_EBS_To_OTM_UOM Weight Failed');
				END IF;
				raise FND_API.G_EXC_ERROR;
			END IF;


			--UOM Domain is public do not specify
			--x_source_line_tab(j).WeightUOMDomain:=g_domain_name;

			--Volume
			x_source_line_tab(j).Volume:=p_source_line_tab(i).volume;
			IF (x_source_line_tab(j).Volume IS NULL)
			THEN
				x_source_line_tab(j).Volume:=0;
			END IF;


			Get_EBS_To_OTM_UOM(
				p_uom=>p_source_line_tab(i).volume_uom_code,
				x_uom=>x_source_line_tab(j).VolumeUOM,
				x_return_status=>l_return_status);
			IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
				 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
				IF l_debug_on
				THEN
					WSH_DEBUG_SV.log(l_module_name,'Get_EBS_To_OTM_UOM Volume Failed');
				END IF;
				raise FND_API.G_EXC_ERROR;
			END IF;


			--UOM Domain is public do not specify
			--x_source_line_tab(j).VolumeUOMDomain:=g_domain_name;

			--Item

			IF ((p_source_line_tab(i).inventory_item_id IS NOT NULL)
			AND (p_source_line_tab(i).ship_from_org_id IS NOT NULL))
			THEN
				x_source_line_tab(j).ItemId:=p_source_line_tab(i).ship_from_org_id||'-'||
					p_source_line_tab(i).inventory_item_id;
				x_source_line_tab(j).ItemOrgId:=p_source_line_tab(i).ship_from_org_id;

			END IF;


			IF (x_source_line_tab(j).ItemId IS NOT NULL)
			THEN
				x_source_line_tab(j).ItemDomain:=x_source_header_xml_rec.domain;
			END IF;

			--Item Dimensions

			IF((x_source_line_tab(j).ItemId IS NOT NULL) AND (x_source_line_tab(j).ItemOrgId IS NOT NULL))
			THEN
				l_length:=NULL;
				l_width:=NULL;
				l_height:=NULL;
				l_dim_uom:=NULL;
				l_otm_dim_uom:=NULL;

				OPEN c_item_dimensions(p_source_line_tab(i).inventory_item_id,p_source_line_tab(i).ship_from_org_id);
				FETCH c_item_dimensions INTO l_length,l_width,l_height,l_dim_uom;
				CLOSE c_item_dimensions;


				Get_EBS_To_OTM_UOM(
					p_uom=>l_dim_uom,
					x_uom=>l_otm_dim_uom,
					x_return_status=>l_return_status);
				IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
					 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
					IF l_debug_on
					THEN
						WSH_DEBUG_SV.log(l_module_name,'Get_EBS_To_OTM_UOM Dim Failed');
					END IF;
					raise FND_API.G_EXC_ERROR;
				END IF;
				IF l_debug_on
				THEN
					WSH_DEBUG_SV.log(l_module_name,'Length',l_length);
					WSH_DEBUG_SV.log(l_module_name,'Width',l_width);
					WSH_DEBUG_SV.log(l_module_name,'Height',l_height);
					WSH_DEBUG_SV.log(l_module_name,'DimUOM',l_dim_uom);
					WSH_DEBUG_SV.log(l_module_name,'OTMDimUOM',l_otm_dim_uom);
				END IF;

				IF ((l_otm_dim_uom IS NOT NULL) AND ((l_length IS NOT NULL) AND (l_width IS NOT NULL) AND (l_height IS NOT NULL)))
				THEN
					x_source_line_tab(j).Length:=l_length;
					x_source_line_tab(j).Width:=l_width;
					x_source_line_tab(j).Height:=l_height;

					x_source_line_tab(j).LengthUOM:=l_otm_dim_uom;
					x_source_line_tab(j).WidthUOM:=l_otm_dim_uom;
					x_source_line_tab(j).HeightUOM:=l_otm_dim_uom;

					--UOM Domain is public do not specify
					--x_source_line_tab(j).LengthUOMDomain:=g_domain_name;
					--x_source_line_tab(j).WidthUOMDomain:=g_domain_name;
					--x_source_line_tab(j).HeightUOMDomain:=g_domain_name;


				END IF;

			END IF;

                        -- Custom hook to override line level attributes
                        l_line_tab(1) := p_source_line_tab(i).source_line_id;
                        l_all_lines_tab(l_all_lines_tab.COUNT + 1) := l_line_tab(1);
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'Line id : '||l_line_tab(1)
                                  ||' x_source_line_tab(j).Weight : '||x_source_line_tab(j).Weight
                                  ||' x_source_line_tab(j).Volume : '||x_source_line_tab(j).Volume
                                  ||' x_source_line_tab(j).Length : '||x_source_line_tab(j).Length
                                  ||' x_source_line_tab(j).Height : '||x_source_line_tab(j).Height
                                  ||' x_source_line_tab(j).Width  : '||x_source_line_tab(j).Width);
                           WSH_DEBUG_SV.logmsg(l_module_name,'Calling WSH_CUSTOM_PUB.Override_RIQ_XML_Attributes') ;
                        END IF;
                        WSH_CUSTOM_PUB.Override_RIQ_XML_Attributes (
                                       p_line_id_tab   => l_line_tab,
                                       x_weight        => x_source_line_tab(j).Weight,
                                       x_volume        => x_source_line_tab(j).Volume,
                                       x_length        => x_source_line_tab(j).Length,
                                       x_height        => x_source_line_tab(j).Height,
                                       x_width         => x_source_line_tab(j).Width,
                                       x_return_status =>l_return_status );
                        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                           IF l_debug_on THEN
                              WSH_DEBUG_SV.log(l_module_name,'WSH_CUSTOM_PUB.Override_RIQ_XML_Attribute Failed');
                           END IF;
                           RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,' x_source_line_tab(j).Weight : '
                                  ||x_source_line_tab(j).Weight
                                  ||' x_source_line_tab(j).Volume : '||x_source_line_tab(j).Volume
                                  ||' x_source_line_tab(j).Length : '||x_source_line_tab(j).Length
                                  ||' x_source_line_tab(j).Height : '||x_source_line_tab(j).Height
                                  ||' x_source_line_tab(j).Width  : '||x_source_line_tab(j).Width);
                        END IF;

                        -- Checking if all dimensions and OTM dimension UOM are present
                        IF l_otm_dim_uom IS NULL OR x_source_line_tab(j).Length IS NULL
                        OR x_source_line_tab(j).Height IS NULL OR x_source_line_tab(j).Width IS NULL THEN
                           x_source_line_tab(j).Length    := NULL;
                           x_source_line_tab(j).Height    := NULL;
                           x_source_line_tab(j).Width     := NULL;
                           x_source_line_tab(j).LengthUOM := NULL;
                           x_source_line_tab(j).WidthUOM  := NULL;
                           x_source_line_tab(j).HeightUOM := NULL;
                        END IF;

			j:=j+1;
		END IF;
		i:=p_source_line_tab.NEXT(i);
	END LOOP;

        -- Custom hook to override header level attributes
        l_dummy  := NULL;
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'No of Order Lines : '||l_all_lines_tab.COUNT
                                ||' x_source_header_xml_rec.TotalWeight : '||x_source_header_xml_rec.TotalWeight
                                ||' x_source_header_xml_rec.TotalVolume : '||x_source_header_xml_rec.TotalVolume);
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling WSH_CUSTOM_PUB.Override_RIQ_XML_Attributes');
        END IF;
        WSH_CUSTOM_PUB.Override_RIQ_XML_Attributes (
                       p_line_id_tab   => l_all_lines_tab,
                       x_weight        => x_source_header_xml_rec.TotalWeight,
                       x_volume        => x_source_header_xml_rec.TotalVolume,
                       x_length        => l_dummy,
                       x_height        => l_dummy,
                       x_width         => l_dummy,
                       x_return_status => l_return_status );
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'WSH_CUSTOM_PUB.Override_RIQ_XML_Attribute Failed');
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, ' x_source_header_xml_rec.TotalWeight : '
                              ||x_source_header_xml_rec.TotalWeight
                              ||' x_source_header_xml_rec.TotalVolume : '||x_source_header_xml_rec.TotalVolume);
        END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Format_Line_Input_For_Xml',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END Format_Line_Input_For_Xml;


PROCEDURE Format_Header_Input_For_Xml(
	p_source_header_tab		IN	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_TAB,
	p_source_type			IN		VARCHAR2,
	p_action			IN		VARCHAR2,
	x_source_header_tab IN OUT NOCOPY WSH_OTM_RIQ_HEADER_TAB,
	x_return_status			OUT NOCOPY	VARCHAR2) IS


	CURSOR  c_SM_Components(c_shp_mthd_cd VARCHAR2)
	IS
	SELECT carrier_id, mode_of_transport,service_level
	FROM   wsh_carrier_services
	WHERE  ship_method_code = c_shp_mthd_cd;


	l_carrier_freight_code VARCHAR2(30);
	l_generic_carrier VARCHAR2(1);
	i NUMBER;
	l_carrier_id NUMBER;
	l_mode VARCHAR2(30);
	l_service_level VARCHAR2(30);

	l_header_rec WSH_OTM_RIQ_HEADER_REC;
        /*Bug7329859*/
	j NUMBER;
        l_customer_id NUMBER;
        /*Bug7329859*/
	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FORMAT_HEADER_INPUT_FOR_XML';

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
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	x_source_header_tab.DELETE;
	x_source_header_tab.EXTEND(p_source_header_tab.COUNT);
	l_header_rec:=NEW WSH_OTM_RIQ_HEADER_REC();

	--Initialize fields that will be common to all header records

	--ShipUnitCount hardcoded to 1
	l_header_rec.ShipUnitCount:=1;

	--Dummy value for ShipUnitGid
	l_header_rec.ShipUnitGid:='Q';


	IF (p_action = 'GET_RATE_CHOICE')
	THEN
		l_header_rec.RIQRequestType:='AllOptions';
		l_header_rec.Perspective:='B';
		l_header_rec.UseRIQRoute:='N';

	ELSIF(p_action = 'R')
	THEN
		l_header_rec.RIQRequestType:='LowestCost';
		l_header_rec.Perspective:='B';
		l_header_rec.UseRIQRoute:='N';

	ELSIF(p_action = 'C')
	THEN
		l_header_rec.GetFreightCost:='N';

	ELSIF(p_action = 'B')
	THEN
		l_header_rec.GetFreightCost:='Y';

	END IF;




	l_header_rec.domain:=g_domain_name;
	--Transmission Type

	l_header_rec.TransmissionType:='QUERY';

	IF ((g_user_name IS NULL) OR (g_password IS NULL))
	THEN
		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'User/Pwd is null');
			WSH_DEBUG_SV.log(l_module_name,'user',g_user_name);
			WSH_DEBUG_SV.log(l_module_name,'pwd',g_password);
		END IF;

		RAISE FND_API.G_EXC_ERROR;

	END IF;

	l_header_rec.UserName:=g_user_name;
	l_header_rec.Passwd:=g_password;



	--Use the same index as header
	i:=p_source_header_tab.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		l_carrier_id:=p_source_header_tab(i).carrier_id;
		l_mode:=p_source_header_tab(i).mode_of_transport;
		l_service_level:=p_source_header_tab(i).service_level;


		IF (p_source_header_tab(i).ship_method_code is not null)
		AND (l_carrier_id is null OR l_mode is null OR l_service_level is null)
		THEN
			OPEN c_SM_Components(p_source_header_tab(i).ship_method_code);
			FETCH c_SM_Components INTO l_carrier_id,l_mode,l_service_level;
			CLOSE c_SM_Components;



		END IF;


		x_source_header_tab(i):=l_header_rec;

		--Source Location

		Get_Location_Info(
		p_location_id=>p_source_header_tab(i).ship_from_location_id,
		p_org_id=>p_source_header_tab(i).ship_from_org_id,
		p_customer_id=>NULL,
		x_location_xid=>x_source_header_tab(i).SourceLocationId,
		x_location_domain=>x_source_header_tab(i).SourceLocationDomain,
		x_postal_code=>x_source_header_tab(i).SourcePostalCode,
		x_city=>x_source_header_tab(i).SourceCity,
		x_province_code=>x_source_header_tab(i).SourceProvinceCode,
		x_country_code=>x_source_header_tab(i).SourceCountryCode,
		x_country_domain=>x_source_header_tab(i).SourceCountryDomain,
		x_corporation_xid=>x_source_header_tab(i).SourceCorporationId,
		x_corporation_domain=>x_source_header_tab(i).SourceCorporationDomain,
		x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Source Location Get Info Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;



		--Destination Location
		/*Bug7329859 If customer_id is NULL in header rec then getting it from line rec with same consolidation id */
		l_customer_id := p_source_header_tab(i).customer_id;
                IF l_customer_id IS NULL THEN
                    j:=g_source_line_tab_temp.FIRST;
                    WHILE(j IS NOT NULL)
	            LOOP
                         IF((g_source_line_tab_temp(j).consolidation_id IS NOT NULL )
	                 AND (p_source_header_tab(i).consolidation_id IS NOT NULL)
		         AND (g_source_line_tab_temp(j).consolidation_id = p_source_header_tab(i).consolidation_id))
		         THEN
                             l_customer_id := g_source_line_tab_temp(j).customer_id;
                             EXIT;
                         END IF;
                         j:=g_source_line_tab_temp.NEXT(j);
                   END LOOP;
                 END IF;
                /*Bug7329859*/

		Get_Location_Info(
		p_location_id=>p_source_header_tab(i).ship_to_location_id,
		p_org_id=>NULL,
		p_customer_id=>l_customer_id, --Bug7329859
		x_location_xid=>x_source_header_tab(i).DestLocationId,
		x_location_domain=>x_source_header_tab(i).DestLocationDomain,
		x_postal_code=>x_source_header_tab(i).DestPostalCode,
		x_city=>x_source_header_tab(i).DestCity,
		x_province_code=>x_source_header_tab(i).DestProvinceCode,
		x_country_code=>x_source_header_tab(i).DestCountryCode,
		x_country_domain=>x_source_header_tab(i).DestCountryDomain,
		x_corporation_xid=>x_source_header_tab(i).DestCorporationId,
		x_corporation_domain=>x_source_header_tab(i).DestCorporationDomain,
		x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN

			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Dest Location Get Info Failed');
			END IF;

			raise FND_API.G_EXC_ERROR;
		END IF;

		--Dates
		IF (p_source_header_tab(i).ship_date IS NOT NULL)
		THEN
			x_source_header_tab(i).AvailableByDate:=TO_CHAR(p_source_header_tab(i).ship_date,'YYYYMMDDHH24MISS');
			IF (g_timezone_code IS NOT NULL)
			THEN
				x_source_header_tab(i).AvailableByTimezoneCode:=g_timezone_code;
				--TZ Domain is PUBLIC domain do not specify
				--x_source_header_tab(i).AvailableByTZDomain:=g_domain_name;
			END IF;

		END IF;

		IF (p_source_header_tab(i).arrival_date IS NOT NULL)
		THEN
			x_source_header_tab(i).DeliveryByDate:=TO_CHAR(p_source_header_tab(i).arrival_date,'YYYYMMDDHH24MISS');
			IF( g_timezone_code IS NOT NULL)
			THEN

				x_source_header_tab(i).DeliveryByTimezoneCode:=g_timezone_code;
				--TZ Domain is PUBLIC domain do not specify
				--x_source_header_tab(i).DeliveryByTZDomain:=g_domain_name;
			END IF;
		END IF;



		--Carrier

		--Handle Generic carrier
		IF ((p_action = 'GET_RATE_CHOICE') OR (p_action = 'R'))
		THEN
			IF (l_carrier_id is not null)
			THEN

				Get_Carrier_Info(
					p_carrier_id=>l_carrier_id,
					x_generic=>l_generic_carrier,
					x_carrier_freight_code=>l_carrier_freight_code,
					x_return_status=>l_return_status);

				IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
					 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
					IF l_debug_on
					THEN
						WSH_DEBUG_SV.log(l_module_name,'Dest Location Get Info Failed');
					END IF;
					raise FND_API.G_EXC_ERROR;
				END IF;


				IF (l_generic_carrier = 'Y')
				THEN
					l_carrier_id:=NULL;
				END IF;

			END IF;
		END IF;

		IF(l_carrier_id IS NOT NULL)
		THEN
			x_source_header_tab(i).ServiceProviderId:=G_CARRIER_PREFIX||l_carrier_id;

		END IF;

		IF (x_source_header_tab(i).ServiceProviderId IS NOT NULL)
		THEN
			x_source_header_tab(i).ServiceProviderDomain:=g_domain_name;
		END IF;

		--Mode
		IF(l_mode IS NOT NULL)
		THEN
			x_source_header_tab(i).ModeOfTransportCode:=l_mode;
			x_source_header_tab(i).ModeOfTransportDomain:=g_domain_name;

		END IF;

		--Service Level
		IF (l_service_level IS NOT NULL)
		THEN
			x_source_header_tab(i).RateServiceDomain:=g_domain_name;
			x_source_header_tab(i).RateServiceCode:=l_service_level;

		END IF;


		--Freight Terms
		IF(p_source_header_tab(i).freight_terms IS NOT NULL)
		THEN

			x_source_header_tab(i).PaymentMethodDomain:=g_domain_name;
			x_source_header_tab(i).PaymentMethodCode:=p_source_header_tab(i).freight_terms;

		END IF;


		--Total Weight
		x_source_header_tab(i).TotalWeight:=p_source_header_tab(i).total_weight;
		IF (x_source_header_tab(i).TotalWeight IS NULL)
		THEN
			x_source_header_tab(i).TotalWeight:=0;
		END IF;


		Get_EBS_To_OTM_UOM(
			p_uom=>p_source_header_tab(i).weight_uom_code,
			x_uom=>x_source_header_tab(i).TotalWeightUOM,
			x_return_status=>l_return_status);
		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'Get_EBS_To_OTM_UOM Weight Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;


		--UOM Domain is public do not specify
		--x_source_header_tab(i).TotalWeightUOMDomain:=g_domain_name;

		--Total Volume
		x_source_header_tab(i).TotalVolume:=p_source_header_tab(i).total_volume;
		IF (x_source_header_tab(i).TotalVolume IS NULL)
		THEN
			x_source_header_tab(i).TotalVolume:=0;
		END IF;


		Get_EBS_To_OTM_UOM(
			p_uom=>p_source_header_tab(i).volume_uom_code,
			x_uom=>x_source_header_tab(i).TotalVolumeUOM,
			x_return_status=>l_return_status);
		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'Get_EBS_To_OTM_UOM Volume Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;


		--UOM Domain is public do not specify
		--x_source_header_tab(i).TotalVolumeUOMDomain:=g_domain_name;



		i:=p_source_header_tab.NEXT(i);
	END LOOP;

	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.FORMAT_HEADER_INPUT_FOR_XML',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END FORMAT_HEADER_INPUT_FOR_XML;






PROCEDURE Create_RIQ_XML(
	p_source_line_tab IN WSH_OTM_RIQ_LINE_TAB,
	p_source_header_rec IN WSH_OTM_RIQ_HEADER_REC,
	p_source_type			IN		VARCHAR2,
	p_action			IN		VARCHAR2,
	x_xml_input IN OUT NOCOPY XMLTYPE,
	x_return_status			OUT NOCOPY	VARCHAR2) IS

	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_RIQ_XML';


	CURSOR c_Choose_SM_XML(c_header_rec IN WSH_OTM_RIQ_HEADER_REC,c_line_tab IN WSH_OTM_RIQ_LINE_TAB)
	IS
	SELECT 	XMLELEMENT("Transmission",
	XMLFOREST(
		XMLFOREST(
			c_header_rec.TransmissionType AS "TransmissionType",
			c_header_rec.UserName AS "UserName",
			c_header_rec.Passwd AS "Password"
		) AS "TransmissionHeader",

		XMLELEMENT("GLogXMLElement",
			XMLELEMENT("RemoteQuery",
				XMLELEMENT("RIQQuery",
					XMLConcat(

						XMLELEMENT("RIQRequestType",
							c_header_rec.RIQRequestType
						),
						XMLElement("SourceAddress",
							XMLForest(
								XMLFOREST(
									c_header_rec.SourceCity AS "City",
									c_header_rec.SourceProvinceCode AS "ProvinceCode",
									c_header_rec.SourcePostalCode AS "PostalCode",
									XMLFOREST(
										XMLFOREST(
											c_header_rec.SourceCountryDomain AS "DomainName",
											c_header_rec.SourceCountryCode AS "Xid"
										) AS "Gid"
									) AS "CountryCode3Gid",
									XMLELEMENT("Gid",
										XMLFOREST(
											c_header_rec.SourceLocationDomain AS "DomainName",
											c_header_rec.SourceLocationId AS "Xid"
										)
									) AS "LocationGid"
								) AS "MileageAddress",
								XMLFOREST(
									XMLFOREST(
										c_header_rec.SourceLocationDomain AS "DomainName",
										c_header_rec.SourceCorporationId AS "Xid"
									) AS "Gid"
								) AS "CorporationGid"
							)
						),
						XMLElement("DestAddress",
							XMLForest(

								XMLFOREST(
									c_header_rec.DestCity AS "City",
									c_header_rec.DestProvinceCode AS "ProvinceCode",
									c_header_rec.DestPostalCode AS "PostalCode",
									XMLFOREST(
										XMLFOREST(
											c_header_rec.DestCountryDomain AS "DomainName",
											c_header_rec.DestCountryCode AS "Xid"
										) AS "Gid"
									) AS "CountryCode3Gid",

									XMLELEMENT("Gid",
										XMLFOREST(
											c_header_rec.DestLocationDomain AS "DomainName",
											c_header_rec.DestLocationId AS "Xid"
										)

									) AS "LocationGid"
								) AS "MileageAddress",
								XMLFOREST(
									XMLFOREST(
										c_header_rec.DestLocationDomain AS "DomainName",
										c_header_rec.DestCorporationId AS "Xid"
									) AS "Gid"
								) AS "CorporationGid"
							)
						),
						XMLFOREST(
							XMLFOREST(
								c_header_rec.AvailableByDate AS "AvailableDate",
								XMLFOREST(
									XMLFOREST(
										c_header_rec.AvailableByTZDomain AS "DomainName",
										c_header_rec.AvailableByTimeZoneCode AS "Xid"
									) AS "Gid"
								) AS "TimeZoneGid"
							) AS "AvailableBy"
						),
						XMLFOREST(
							XMLFOREST(
								c_header_rec.DeliveryByDate AS "DeliveryByDate",

								XMLFOREST(
									XMLFOREST(
										c_header_rec.DeliveryByTZDomain AS "DomainName",
										c_header_rec.DeliveryByTimeZoneCode AS "Xid"
									) AS "Gid"
								) AS "TimeZoneGid"
							) AS "DeliveryBy"
						),
						XMLELEMENT("Perspective",
							c_header_rec.Perspective
						),
						XMLELEMENT("UseRIQRoute",
							c_header_rec.UseRIQRoute
						),
						XMLAgg(
							XMLELEMENT("ShipUnit",
								XMLFOREST(

									XMLFOREST(
										XMLFOREST(
											c_header_rec.ShipUnitGid AS "Xid"
										) AS "Gid"

									) AS "ShipUnitGid",

									XMLFOREST(
										XMLFOREST(
											e.weight AS "WeightValue",
											XMLFOREST(
												XMLFOREST(
													e.weightUOMDomain AS "DomainName",
													e.weightUOM AS "Xid"
												) AS "Gid"
											) AS "WeightUOMGid"

										) AS "Weight",
										XMLFOREST(
											e.volume AS "VolumeValue",
											XMLFOREST(
												XMLFOREST(
													e.volumeUOMDomain AS "DomainName",
													e.volumeUOM AS "Xid"
												) AS "Gid"
											) AS "VolumeUOMGid"
										) AS "Volume"
									) AS "WeightVolume",
									XMLFOREST(
										XMLFOREST(
											e.Length AS "LengthValue",
											XMLFOREST(
												XMLFOREST(
													e.lengthUOMDomain AS "DomainName",
													e.lengthUOM AS "Xid"
												) AS "Gid"
											) AS "LengthUOMGid"
										) AS "Length",
										XMLFOREST(
											e.width AS "WidthValue",
											XMLForest(
												XMLFOREST(
													e.widthUOMDomain AS "DomainName",
													e.widthUOM AS "Xid"
												) AS "Gid"

											) AS "WidthUOMGid"
										) AS "Width",
										XMLFOREST(
											e.height AS "HeightValue",
											XMLFOREST(
												XMLFOREST(
													e.heightUOMDomain AS "DomainName",
													e.heightUOM AS "Xid"
												) AS "Gid"
											) AS "HeightUOMGid"
										) AS "Height"
									) AS "LengthWidthHeight",

									XMLFOREST(
										XMLFOREST(
											XMLFOREST(
												XMLFOREST(
													e.ItemDomain AS "DomainName",
													e.ItemId AS "Xid"
												) AS "Gid"
											) AS "PackagedItemGid"
										) AS "PackagedItemRef",
										e.LineNumber AS "LineNumber"
									) AS "ShipUnitContent",
									c_header_rec.ShipUnitCount AS "ShipUnitCount"
								)
							)
						)
					)
				)
			)
		) AS "TransmissionBody"
	)
	)
	FROM TABLE(CAST(c_line_tab AS WSH_OTM_RIQ_LINE_TAB )) e;




	CURSOR c_Get_Freight_Rates_XML(c_header_rec IN WSH_OTM_RIQ_HEADER_REC,c_line_tab IN WSH_OTM_RIQ_LINE_TAB)
	IS

	SELECT
	XMLELEMENT("Transmission",
	XMLFOREST(
		XMLFOREST(
			c_header_rec.TransmissionType AS "TransmissionType",
			c_header_rec.UserName AS "UserName",
			c_header_rec.Passwd AS "Password"
		) AS "TransmissionHeader",

		XMLELEMENT("GLogXMLElement",
			XMLELEMENT("RemoteQuery",
				XMLELEMENT("RIQQuery",
					XMLConcat(

						XMLELEMENT("RIQRequestType",
							c_header_rec.RIQRequestType
						),
						XMLElement("SourceAddress",
							XMLForest(
								XMLFOREST(
									c_header_rec.SourceCity AS "City",
									c_header_rec.SourceProvinceCode AS "ProvinceCode",
									c_header_rec.SourcePostalCode AS "PostalCode",
									XMLFOREST(
										XMLFOREST(
											c_header_rec.SourceCountryDomain AS "DomainName",
											c_header_rec.SourceCountryCode AS "Xid"
										) AS "Gid"
									) AS "CountryCode3Gid",
									XMLELEMENT("Gid",
										XMLFOREST(
											c_header_rec.SourceLocationDomain AS "DomainName",
											c_header_rec.SourceLocationId AS "Xid"
										)
									) AS "LocationGid"
								) AS "MileageAddress",
								XMLFOREST(
									XMLFOREST(
										c_header_rec.SourceLocationDomain AS "DomainName",
										c_header_rec.SourceCorporationId AS "Xid"
									) AS "Gid"
								) AS "CorporationGid"
							)
						),
						XMLElement("DestAddress",
							XMLForest(

								XMLFOREST(
									c_header_rec.DestCity AS "City",
									c_header_rec.DestProvinceCode AS "ProvinceCode",
									c_header_rec.DestPostalCode AS "PostalCode",
									XMLFOREST(
										XMLFOREST(
											c_header_rec.DestCountryDomain AS "DomainName",
											c_header_rec.DestCountryCode AS "Xid"
										) AS "Gid"
									) AS "CountryCode3Gid",
									XMLELEMENT("Gid",
										XMLFOREST(
											c_header_rec.DestLocationDomain AS "DomainName",
											c_header_rec.DestLocationId AS "Xid"
										)

									) AS "LocationGid"
								) AS "MileageAddress",
								XMLFOREST(
									XMLFOREST(
										c_header_rec.DestLocationDomain AS "DomainName",
										c_header_rec.DestCorporationId AS "Xid"
									) AS "Gid"
								) AS "CorporationGid"
							)
						),

						XMLFOREST(
							XMLFOREST(
								XMLFOREST(
									c_header_rec.ModeOfTransportDomain AS "DomainName",
									c_header_rec.ModeOfTransportCode AS "Xid"

								) AS "Gid"
							) AS "TransportModeGid"
						),
						XMLFOREST(
							XMLFOREST(
								XMLFOREST(
									c_header_rec.ServiceProviderDomain AS "DomainName",
									c_header_rec.ServiceProviderId AS "Xid"

								) AS "Gid"
							) AS "ServiceProviderGid"
						),
						XMLFOREST(
							XMLFOREST(
								XMLFOREST(
									c_header_rec.RateServiceDomain AS "DomainName",
									c_header_rec.RateServiceCode AS "Xid"

								) AS "Gid"
							) AS "RateServiceGid"
						),
						XMLFOREST(
							XMLFOREST(
								c_header_rec.AvailableByDate AS "AvailableDate",
								XMLFOREST(
									XMLFOREST(
										c_header_rec.AvailableByTZDomain AS "DomainName",
										c_header_rec.AvailableByTimeZoneCode AS "Xid"
									) AS "Gid"
								) AS "TimeZoneGid"
							) AS "AvailableBy"
						),
						XMLFOREST(
							XMLFOREST(
								c_header_rec.DeliveryByDate AS "DeliveryByDate",

								XMLFOREST(
									XMLFOREST(
										c_header_rec.DeliveryByTZDomain AS "DomainName",
										c_header_rec.DeliveryByTimeZoneCode AS "Xid"
									) AS "Gid"
								) AS "TimeZoneGid"
							) AS "DeliveryBy"
						),
						XMLELEMENT("Perspective",
							c_header_rec.Perspective
						),
						XMLELEMENT("UseRIQRoute",
							c_header_rec.UseRIQRoute
						),

						XMLAgg(
							XMLELEMENT("ShipUnit",
								XMLFOREST(

									XMLFOREST(
										XMLFOREST(
											c_header_rec.ShipUnitGid AS "Xid"
										) AS "Gid"

									) AS "ShipUnitGid",

									XMLFOREST(
										XMLFOREST(
											e.weight AS "WeightValue",
											XMLFOREST(
												XMLFOREST(
													e.weightUOMDomain AS "DomainName",
													e.weightUOM AS "Xid"
												) AS "Gid"
											) AS "WeightUOMGid"

										) AS "Weight",
										XMLFOREST(
											e.volume AS "VolumeValue",
											XMLFOREST(
												XMLFOREST(
													e.volumeUOMDomain AS "DomainName",
													e.volumeUOM AS "Xid"
												) AS "Gid"
											) AS "VolumeUOMGid"
										) AS "Volume"
									) AS "WeightVolume",
									XMLFOREST(
										XMLFOREST(
											e.Length AS "LengthValue",
											XMLFOREST(
												XMLFOREST(
													e.lengthUOMDomain AS "DomainName",
													e.lengthUOM AS "Xid"
												) AS "Gid"
											) AS "LengthUOMGid"
										) AS "Length",
										XMLFOREST(
											e.width AS "WidthValue",
											XMLForest(
												XMLFOREST(
													e.widthUOMDomain AS "DomainName",
													e.widthUOM AS "Xid"
												) AS "Gid"

											) AS "WidthUOMGid"
										) AS "Width",
										XMLFOREST(
											e.height AS "HeightValue",
											XMLFOREST(
												XMLFOREST(
													e.heightUOMDomain AS "DomainName",
													e.heightUOM AS "Xid"
												) AS "Gid"
											) AS "HeightUOMGid"
										) AS "Height"
									) AS "LengthWidthHeight",
									XMLFOREST(
										XMLFOREST(
											XMLFOREST(
												XMLFOREST(
													e.ItemDomain AS "DomainName",
													e.ItemId AS "Xid"
												) AS "Gid"
											) AS "PackagedItemGid"
										) AS "PackagedItemRef",
										e.LineNumber AS "LineNumber"
									) AS "ShipUnitContent",

									c_header_rec.ShipUnitCount AS "ShipUnitCount"
								)
							)
						)
					)
				)
			)
		) AS "TransmissionBody"
	)
	)
	FROM TABLE(CAST(c_line_tab AS WSH_OTM_RIQ_LINE_TAB )) e;



	CURSOR c_Get_SM_XML(c_header_rec IN WSH_OTM_RIQ_HEADER_REC,c_line_tab IN WSH_OTM_RIQ_LINE_TAB)
	IS
	SELECT
	XMLELEMENT("Transmission",
	XMLFOREST(
		XMLFOREST(
			c_header_rec.TransmissionType AS "TransmissionType",
			c_header_rec.UserName AS "UserName",
			c_header_rec.Passwd AS "Password"
		) AS "TransmissionHeader",

		XMLELEMENT("GLogXMLElement",
			XMLELEMENT("RemoteQuery",
				XMLELEMENT("OrderRoutingRuleQuery",
					XMLConcat(

						XMLElement("SourceAddress",
							XMLForest(
								XMLFOREST(
									c_header_rec.SourceCity AS "City",
									c_header_rec.SourceProvinceCode AS "ProvinceCode",
									c_header_rec.SourcePostalCode AS "PostalCode",
									XMLFOREST(
										XMLFOREST(
											c_header_rec.SourceCountryDomain AS "DomainName",
											c_header_rec.SourceCountryCode AS "Xid"
										) AS "Gid"
									) AS "CountryCode3Gid",

									XMLELEMENT("Gid",
										XMLFOREST(
											c_header_rec.SourceLocationDomain AS "DomainName",
											c_header_rec.SourceLocationId AS "Xid"
										)
									) AS "LocationGid"
								) AS "MileageAddress",
								XMLFOREST(
									XMLFOREST(
										c_header_rec.SourceLocationDomain AS "DomainName",
										c_header_rec.SourceCorporationId AS "Xid"
									) AS "Gid"
								) AS "CorporationGid"
							)
						),
						XMLElement("DestAddress",
							XMLForest(

								XMLFOREST(
									c_header_rec.DestCity AS "City",
									c_header_rec.DestProvinceCode AS "ProvinceCode",
									c_header_rec.DestPostalCode AS "PostalCode",
									XMLFOREST(
										XMLFOREST(
											c_header_rec.DestCountryDomain AS "DomainName",
											c_header_rec.DestCountryCode AS "Xid"
										) AS "Gid"
									) AS "CountryCode3Gid",
									XMLELEMENT("Gid",
										XMLFOREST(
											c_header_rec.DestLocationDomain AS "DomainName",
											c_header_rec.DestLocationId AS "Xid"
										)

									) AS "LocationGid"
								) AS "MileageAddress",
								XMLFOREST(
									XMLFOREST(
										c_header_rec.DestLocationDomain AS "DomainName",
										c_header_rec.DestCorporationId AS "Xid"
									) AS "Gid"
								) AS "CorporationGid"
							)
						),

						XMLFOREST(
							c_header_rec.AvailableByDate AS "EstDepartureDate"
						),

						XMLFOREST(
							c_header_rec.DeliveryByDate AS "EstArrivalDate"
						),
						XMLFOREST(
							XMLFOREST(
								c_header_rec.TotalWeight AS "WeightValue",
								XMLFOREST(
									XMLFOREST(
										c_header_rec.TotalWeightUOMDomain AS "DomainName",
										c_header_rec.TotalWeightUOM AS "Xid"
									) AS "Gid"
								) AS "WeightUOMGid"

							) AS "Weight"
						),
						XMLFOREST(
							XMLFOREST(
								c_header_rec.TotalVolume AS "VolumeValue",
								XMLFOREST(
									XMLFOREST(
										c_header_rec.TotalVolumeUOMDomain AS "DomainName",
										c_header_rec.TotalVolumeUOM AS "Xid"
									) AS "Gid"
								) AS "VolumeUOMGid"
							) AS "Volume"
						),
						XMLFOREST(
							XMLFOREST(
								XMLFOREST(
									c_header_rec.PaymentMethodDomain AS "DomainName",
									c_header_rec.PaymentMethodCode AS "Xid"
								) AS "Gid"
							) AS "PaymentMethodCodeGid"
						)
					)
				)
			)
		) AS "TransmissionBody"
	)
	)
	FROM TABLE(CAST(c_line_tab AS WSH_OTM_RIQ_LINE_TAB )) e;



BEGIN

	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF (p_action IS NOT NULL)
	THEN
		IF (p_action = 'GET_RATE_CHOICE')
		THEN
			OPEN c_Choose_SM_XML(p_source_header_rec,p_source_line_tab);
			FETCH c_Choose_SM_XML INTO x_xml_input;
			CLOSE c_Choose_SM_XML;

		ELSIF ((p_action = 'C') OR (p_action = 'B'))
		THEN

			OPEN c_Get_SM_XML(p_source_header_rec,p_source_line_tab);
			FETCH c_Get_SM_XML INTO x_xml_input;
			CLOSE c_Get_SM_XML;


		ELSIF (p_action ='R')
		THEN

			OPEN c_Get_Freight_Rates_XML(p_source_header_rec,p_source_line_tab);
			FETCH c_Get_Freight_Rates_XML INTO x_xml_input;
			CLOSE c_Get_Freight_Rates_XML;

		END IF;


	END IF;




	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Create_RIQ_XML',l_module_name);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--

END Create_RIQ_XML;

PROCEDURE Fetch_XML_Match(
	p_xml IN XMLTYPE,
	p_xpath IN VARCHAR2,
	x_xml_seq OUT NOCOPY XMLSequenceType,
	x_return_status			OUT NOCOPY	VARCHAR2)
	IS
	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Fetch_XML_Match';


	CURSOR c_extract(C_XML_IN IN XMLTYPE,C_XPATH IN VARCHAR2)
	IS
	SELECT XMLSEQUENCE(EXTRACT(C_XML_IN,C_XPATH,g_xml_namespace_map)) XML
	FROM DUAL;

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
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	OPEN c_extract(p_xml,p_xpath);
	FETCH c_extract INTO x_xml_seq;
	CLOSE c_extract;



	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Fetch_XML_Match',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Fetch_XML_Match;



PROCEDURE Check_Response_Status(
	p_xpath_prefix IN VARCHAR2,
	p_xml_output IN XMLTYPE,
	x_return_status OUT NOCOPY	VARCHAR2)
	IS

	i NUMBER;
	l_xml_seq XMLSequenceType;
	l_status_code VARCHAR2(30);
	l_status_message VARCHAR2(32000);
	l_log_message VARCHAR2(32000);
	l_tmp_xml XMLTYPE;
	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Check_Response_Status';

        l_prev_xml_namespace_map VARCHAR2(200) := NULL;

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
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF l_debug_on
	THEN
		WSH_DEBUG_SV.log(l_module_name,'prefix:',p_xpath_prefix);
		WSH_DEBUG_SV.log(l_module_name,'code:',G_XPATH_STATUS_CODE);
	END IF;


	l_status_code:=NULL;
	l_tmp_xml:=p_xml_output.extract(p_xpath_prefix||G_XPATH_STATUS_CODE,g_xml_namespace_map);

	IF (l_tmp_xml IS NULL)
	THEN
		--Try again incase message is using other NS(TODO)
                l_prev_xml_namespace_map := g_xml_namespace_map;
		g_xml_namespace_map:=G_OTM_NS_MAP;
		l_tmp_xml:=p_xml_output.extract(p_xpath_prefix||G_XPATH_STATUS_CODE,g_xml_namespace_map);

	END IF;

	IF (l_tmp_xml IS NULL)
	THEN
		--Try again incase message did not contain name space
		g_xml_namespace_map:=NULL;
		l_tmp_xml:=p_xml_output.extract(p_xpath_prefix||G_XPATH_STATUS_CODE,g_xml_namespace_map);

	END IF;

	IF (l_tmp_xml IS NOT NULL)
	THEN
		l_status_code:=l_tmp_xml.getStringVal();
		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'OTM Status code',l_status_code);
		END IF;
        ELSE
          -- Now g_xml_namespace_map is NULL, so revert it back to the original
          g_xml_namespace_map := l_prev_xml_namespace_map;
	END IF;

	IF ((l_status_code IS NULL) OR (l_status_code <> 'SUCCESS'))
	THEN

		x_return_status:=FND_API.G_RET_STS_ERROR;

		IF l_debug_on
		THEN
			--Log status code
			WSH_DEBUG_SV.log(l_module_name,'OTM Status code',l_status_code,WSH_DEBUG_SV.C_EXCEP_LEVEL);

			l_status_message:=NULL;
			l_tmp_xml:=p_xml_output.extract(p_xpath_prefix||G_XPATH_STATUS_MESSAGE,g_xml_namespace_map);
	                IF (l_tmp_xml IS NULL) THEN
		          --Try again incase message is using other NS(TODO)
		          g_xml_namespace_map:=G_OTM_NS_MAP;
		          l_tmp_xml:=p_xml_output.extract(p_xpath_prefix||G_XPATH_STATUS_MESSAGE,g_xml_namespace_map);
	                END IF;

	                IF (l_tmp_xml IS NULL) THEN
		          --Try again incase message did not contain name space
		          g_xml_namespace_map:=NULL;
		          l_tmp_xml:=p_xml_output.extract(p_xpath_prefix||G_XPATH_STATUS_MESSAGE,g_xml_namespace_map);
	                END IF;
			IF (l_tmp_xml IS NOT NULL)
			THEN
				l_status_message:=l_tmp_xml.getStringVal();
				--Log status message
				WSH_DEBUG_SV.log(l_module_name,'OTM Status message',l_status_message,WSH_DEBUG_SV.C_EXCEP_LEVEL);
                        ELSE
                          -- Now g_xml_namespace_map is NULL, so revert it back to the original
                          g_xml_namespace_map := l_prev_xml_namespace_map;
			END IF;

			Fetch_XML_Match(
				p_xml=>p_xml_output,
				p_xpath=>p_xpath_prefix||G_XPATH_MESSAGES,
				x_xml_seq=>l_xml_seq,
				x_return_status=>l_return_status);

			IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
				 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
				IF l_debug_on
				THEN

					WSH_DEBUG_SV.log(l_module_name,'Fetch_XML_Match Failed');
				END IF;

				raise FND_API.G_EXC_ERROR;
			END IF;

			i:=l_xml_seq.FIRST;
			WHILE (i IS NOT NULL)
			LOOP
				l_log_message:=l_xml_seq(i).getStringVal();
				--Log status message
				WSH_DEBUG_SV.log(l_module_name,'OTM message',l_log_message,WSH_DEBUG_SV.C_EXCEP_LEVEL);

				i:=l_xml_seq.NEXT(i);

			END LOOP;
		END IF;

	END IF;


	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Check_Response_Status',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Check_Response_Status;

PROCEDURE Extract_Single_Cost(
  p_xml           IN  XMLTYPE,
  p_xpath_prefix  IN  VARCHAR2,
  p_currency      IN  VARCHAR2,
  x_cost          OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2) IS

  l_negative VARCHAR2(1);
  l_tmp_xml XMLTYPE;
  l_return_status   VARCHAR2(1);
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Extract_Single_Cost';

  l_cost_summary VARCHAR2(200);
  l_currency VARCHAR2(30);
  l_rate NUMBER;

  l_currency_conversion_type VARCHAR2(30) := NULL;

  -- Bug 5886042
  -- currency conversion_type in the error message should be
  -- user_conversion_type

  l_user_conv_type           VARCHAR2(30) := NULL;

  CURSOR c_get_user_conv_type(p_curr_conv_type varchar2) IS
  SELECT user_conversion_type
    FROM gl_daily_conversion_types
   WHERE conversion_type = p_curr_conv_type;
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

  x_cost := NULL;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_cost_summary:=NULL;
  l_currency:=NULL;

  l_tmp_xml:=p_xml.extract(p_xpath_prefix||G_XPATH_COST_SUMMARY,g_xml_namespace_map);
  IF (l_tmp_xml IS NOT NULL)
  THEN
    l_cost_summary:=l_tmp_xml.getStringVal();
  END IF;

  l_tmp_xml:=p_xml.extract(p_xpath_prefix||G_XPATH_COST_SUMMARY_CURRENCY,g_xml_namespace_map);
  IF (l_tmp_xml IS NOT NULL)
  THEN
    l_currency:=l_tmp_xml.getStringVal();
  END IF;

  l_rate:=Convert_To_Number(l_cost_summary);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_currency',l_currency);
    WSH_DEBUG_SV.log(l_module_name,'p_currency',p_currency);
    WSH_DEBUG_SV.log(l_module_name,'l_cost_summary',l_cost_summary);
    WSH_DEBUG_SV.log(l_module_name,'l_rate',l_rate);
  END IF;

  IF((l_currency IS NOT NULL) AND (p_currency IS NOT NULL) AND
     (l_rate IS NOT NULL))
  THEN

    IF (l_currency <> p_currency )
    THEN
      --Block to catch any exceptions thrown
      BEGIN
        --FOr discount rates may be negative flip it to ensure that
        -- it doesnt interfere with any negative value returned from the
        --currency conversion API that indicates a failure
        l_negative:='N';
        IF(l_rate < 0)
        THEN
          l_negative:='Y';
          l_rate:=l_rate *-1;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'negative:l_rate',l_rate);
          END IF;
        END IF;
        wsh_util_core.get_currency_conversion_type(
                      x_curr_conv_type => l_currency_conversion_type,
                      x_return_status  => l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'x_curr_conv_type',l_currency_conversion_type);
          WSH_DEBUG_SV.log(l_module_name,'x_return_status',l_return_status);
        END IF;

        if (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) then
          l_rate:=GL_CURRENCY_API.convert_amount(
                        x_from_currency   => l_currency,
                        x_to_currency     => p_currency,
                        x_conversion_date => SYSDATE,
                        x_conversion_type => l_currency_conversion_type,
                        x_amount          => l_rate
          );
        else
          raise FND_API.G_EXC_ERROR;
        end if;

      EXCEPTION
        WHEN OTHERS THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected exception occurred while getting the conversion type or converting the amount');
          END IF;
          raise FND_API.G_EXC_ERROR;
      END;

      IF (l_negative='Y' AND l_rate IS NOT NULL AND l_rate > 0)
      THEN
        l_rate:=l_rate *-1;
      END IF;

      -- l_negative <> 'Y' is added not to error out discount amount
      IF((l_rate IS NULL) OR (l_rate < 0 AND l_negative <> 'Y'))
      THEN
        raise FND_API.G_EXC_ERROR;
      END IF;

    END IF;

  END IF;

  x_cost:=l_rate;

  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
    WSH_DEBUG_SV.log(l_module_name,'x_cost',x_cost);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    -- l_return_status is set from wsh_util_core.get_currency_conversion_type
    -- if it's success, gl_currency_api.convert_amount failed
    -- otherwise, error message is already set in the api, so no need to set it
    if (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) then

      -- Bug 5886042
      -- currency conversion_type in the error message should be
      -- user_conversion_type
      BEGIN
        OPEN c_get_user_conv_type(l_currency_conversion_type);
        FETCH c_get_user_conv_type INTO l_user_conv_type;
        CLOSE c_get_user_conv_type;
      EXCEPTION
        WHEN OTHERS THEN
          l_user_conv_type := l_currency_conversion_type;
          IF c_get_user_conv_type%ISOPEN THEN
            CLOSE c_get_user_conv_type;
          END IF;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred while getting the user currency conversion type');
            WSH_DEBUG_SV.log(l_module_name, 'l_currency_conversion_type', l_currency_conversion_type);
          END IF;
      END;

      IF c_get_user_conv_type%ISOPEN THEN
        CLOSE c_get_user_conv_type;
      END IF;
      --

      fnd_message.set_name('WSH', 'WSH_CURR_CONV_ERROR');
      fnd_message.set_token('FROM_CURR', l_currency);
      fnd_message.set_token('TO_CURR', p_currency);
      fnd_message.set_token('CONV_TYPE', l_user_conv_type);
      wsh_util_core.add_message(x_return_status);
    end if;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.log(l_module_name,'l_currency',l_currency);
      WSH_DEBUG_SV.log(l_module_name,'p_currency',p_currency);
      WSH_DEBUG_SV.log(l_module_name,'l_cost_summary',l_cost_summary);
      WSH_DEBUG_SV.log(l_module_name,'l_rate',l_rate);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;

  WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Extract_Single_Cost',l_module_name);
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
 END Extract_Single_Cost;



PROCEDURE Extract_Rate(
	p_xml	IN 	XMLTYPE,
	p_xpath_prefix IN VARCHAR2,
	p_currency IN VARCHAR2,
	x_summary_rate OUT NOCOPY NUMBER,
	x_base_rate OUT NOCOPY NUMBER,
	x_charge_rate OUT NOCOPY NUMBER,
	x_return_status	OUT NOCOPY	VARCHAR2)
	IS

	i NUMBER;
	l_xml_seq XMLSequenceType;
	l_tmp_xml XMLTYPE;
	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Extract_Rate';

	l_cost_type VARCHAR2(30);
	l_rate_detail NUMBER;
	l_summary_rate NUMBER;
	l_base_rate NUMBER;
	l_charge	NUMBER;


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
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	Extract_Single_Cost(
		p_xml=>p_xml,
		p_xpath_prefix=>p_xpath_prefix,
		p_currency=>p_currency,
		x_cost=>l_summary_rate,
		x_return_status=>l_return_status);

	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Extract_Single_Cost Failed');
		END IF;

		raise FND_API.G_EXC_ERROR;
	END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'After Extract_Single_Cost, Summary Rate:'||l_summary_rate);
        END IF;


	IF(l_summary_rate IS NULL) THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'x_summary_rate null');
		END IF;
		raise FND_API.G_EXC_ERROR;
	END IF;



	Fetch_XML_Match(
		p_xml=>p_xml,
		p_xpath=>p_xpath_prefix||G_XPATH_COST_DETAILS,
		x_xml_seq=>l_xml_seq,
		x_return_status=>l_return_status);

	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Fetch_XML_Match Failed');
		END IF;

		raise FND_API.G_EXC_ERROR;
	END IF;

	--Initialize base and charge to 0
	l_base_rate:=0;
	l_charge:=0;

	i:=l_xml_seq.FIRST;
	WHILE (i IS NOT NULL)
	LOOP

		l_cost_type:=NULL;

		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,l_xml_seq(i).getStringVal());
			WSH_DEBUG_SV.log(l_module_name,G_XPATH_COST_DETAILS||G_XPATH_COST_DETAIL_TYPE);
		END IF;


		l_tmp_xml:=l_xml_seq(i).extract(G_XPATH_COST_DETAILS||G_XPATH_COST_DETAIL_TYPE,g_xml_namespace_map);
		IF (l_tmp_xml IS NOT NULL)
		THEN
			l_cost_type:=l_tmp_xml.getStringVal();
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'l_cost_type',l_cost_type);
			END IF;
		END IF;

		l_rate_detail:=NULL;
		Extract_Single_Cost(
			p_xml=>l_xml_seq(i),
			p_xpath_prefix=>G_XPATH_COST_DETAILS,
			p_currency=>p_currency,
			x_cost=>l_rate_detail,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Extract_Single_Cost Failed');
			END IF;

			raise FND_API.G_EXC_ERROR;
		END IF;

		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'l_rate_detail',l_rate_detail);
		END IF;


		IF((l_rate_detail IS NOT NULL) AND (l_cost_type IS NOT NULL))
		THEN
			IF (l_cost_type = 'B')
			THEN
				l_base_rate:=l_base_rate+l_rate_detail;
			ELSIF (l_cost_type = 'D')
			THEN
			--Include discount into the base rate
			--OTM returns discount as -ve
				l_base_rate:=l_base_rate+l_rate_detail;

			ELSE
			--A charge is present
				l_charge:=l_charge+l_rate_detail;

			END IF;

		END IF;

		i:=l_xml_seq.NEXT(i);

	END LOOP;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_summary_rate',l_summary_rate);
          WSH_DEBUG_SV.log(l_module_name,'l_base_rate',l_base_rate);
          WSH_DEBUG_SV.log(l_module_name,'l_charge',l_charge);
        END IF;


	--l_charge:=l_summary_rate-l_base_rate;
	IF((l_charge < 0) OR (l_summary_rate < 0) OR (l_base_rate < 0))
	THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'Negative rates');
				WSH_DEBUG_SV.log(l_module_name,'l_summary_rate',l_summary_rate);
				WSH_DEBUG_SV.log(l_module_name,'l_base_rate',l_base_rate);
				WSH_DEBUG_SV.log(l_module_name,'l_charge',l_charge);
			END IF;

			raise FND_API.G_EXC_ERROR;


	END IF;

	x_summary_rate:=l_summary_rate;
	x_base_rate:=l_base_rate;
	x_charge_rate:=l_charge;

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_summary_rate',x_summary_rate);
		WSH_DEBUG_SV.log(l_module_name,'x_base_rate',x_base_rate);
		WSH_DEBUG_SV.log(l_module_name,'x_charge_rate',x_charge_rate);
	END IF;



	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Extract_Rate',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Extract_Rate;


PROCEDURE Extract_Ship_Method(
	p_xml	IN 	XMLTYPE,
	p_xpath_prefix IN VARCHAR2,
	p_action IN VARCHAR2,
	x_carrier_id OUT NOCOPY NUMBER,
	x_mode OUT NOCOPY VARCHAR2,
	x_service_level OUT NOCOPY VARCHAR2,
	x_freight_terms_code OUT NOCOPY VARCHAR2,
	x_transit_time OUT NOCOPY NUMBER,
	x_transit_time_UOM OUT NOCOPY VARCHAR2,
	x_return_status			OUT NOCOPY	VARCHAR2)
	IS

	l_tmp_xml XMLTYPE;
	l_carrier_prefix VARCHAR2(30);

	l_carrier VARCHAR2(50);
	l_carrier_id NUMBER;
	l_mode VARCHAR2(50);
	l_service_level VARCHAR2(50);
	l_freight_terms_code VARCHAR2(30);
	l_transit_time_string VARCHAR2(30);
	l_transit_time NUMBER;
	l_transit_time_uom VARCHAR2(30);

	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Extract_Ship_Method';



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
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF l_debug_on
	THEN

		WSH_DEBUG_SV.log(l_module_name,'l_xml',p_xml.getStringVal());
		WSH_DEBUG_SV.log(l_module_name,'XML Done');
		WSH_DEBUG_SV.log(l_module_name,'xp:',p_xpath_prefix||G_XPATH_CARRIER);
	END IF;

	l_tmp_xml:=p_xml.extract(p_xpath_prefix||G_XPATH_CARRIER,g_xml_namespace_map);
	IF (l_tmp_xml IS NOT NULL)
	THEN
		l_carrier_id:=Convert_Carrier_Ouput(l_tmp_xml.getStringVal());

	END IF;

	l_tmp_xml:=p_xml.extract(p_xpath_prefix||G_XPATH_MODE,g_xml_namespace_map);
	IF (l_tmp_xml IS NOT NULL)
	THEN
		l_mode:=l_tmp_xml.getStringVal();

	END IF;

	l_tmp_xml:=p_xml.extract(p_xpath_prefix||G_XPATH_SERVICE_LEVEL,g_xml_namespace_map);
	IF (l_tmp_xml IS NOT NULL)
	THEN
		l_service_level:=l_tmp_xml.getStringVal();

	END IF;

	l_tmp_xml:=p_xml.extract(p_xpath_prefix||G_XPATH_FREIGHT_TERMS,g_xml_namespace_map);
	IF (l_tmp_xml IS NOT NULL)
	THEN
		l_freight_terms_code:=l_tmp_xml.getStringVal();

	END IF;

	l_tmp_xml:=p_xml.extract(p_xpath_prefix||G_XPATH_TRANSIT_TIME,g_xml_namespace_map);

	IF (l_tmp_xml IS NOT NULL)
	THEN
		l_transit_time_string:=l_tmp_xml.getStringVal();
		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'l_transit_time_string',l_transit_time_string);
		END IF;

		IF (l_transit_time_string IS NOT NULL)
		THEN
			l_transit_time:=Convert_To_Number(l_transit_time_string);
		END IF;

		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'l_transit_time',l_transit_time);
		END IF;


	END IF;

	l_tmp_xml:=p_xml.extract(p_xpath_prefix||G_XPATH_TRANSIT_TIME_UOM,g_xml_namespace_map);
	IF (l_tmp_xml IS NOT NULL)
	THEN
		l_transit_time_uom:=l_tmp_xml.getStringVal();
		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'l_transit_time_uom',l_transit_time_uom);
		END IF;


	END IF;


	IF ((l_mode IS NOT NULL) AND (LENGTH(l_mode) > 30))
	THEN
		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'Mode length > 30 truncating');
			WSH_DEBUG_SV.log(l_module_name,'l_mode',l_mode);
		END IF;

		l_mode:=SUBSTR(l_mode,1,30);

	END IF;

	IF ((l_service_level IS NOT NULL) AND (LENGTH(l_service_level) > 30))
	THEN
		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'Service Level length > 30 truncating');
			WSH_DEBUG_SV.log(l_module_name,'l_service_level',l_service_level);
		END IF;

		l_service_level:=SUBSTR(l_service_level,1,30);

	END IF;



	x_carrier_id:=l_carrier_id;
	x_mode:=l_mode;
	x_service_level:=l_service_level;
	x_freight_terms_code:=l_freight_terms_code;

	IF((l_transit_time IS NOT NULL) AND (l_transit_time_uom IS NOT NULL) AND (LENGTH(l_transit_time_uom)<=3))
	THEN
		x_transit_time:=l_transit_time;
		x_transit_time_UOM:=l_transit_time_uom;

	END IF;


	IF l_debug_on
	THEN

		WSH_DEBUG_SV.log(l_module_name,'l_carrier_id',x_carrier_id);
		WSH_DEBUG_SV.log(l_module_name,'l_mode',x_mode);
		WSH_DEBUG_SV.log(l_module_name,'l_service_level',x_service_level);
		WSH_DEBUG_SV.log(l_module_name,'l_freight_terms_code',x_freight_terms_code);
		WSH_DEBUG_SV.log(l_module_name,'x_transit_time',x_transit_time);
		WSH_DEBUG_SV.log(l_module_name,'x_transit_time_UOM',x_transit_time_uom);

	END IF;

	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Extract_Ship_Method',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END Extract_Ship_Method;


PROCEDURE Populate_Get_SM_Result(
	p_source_header_rec		IN	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_REC,
	p_carrier_id IN NUMBER,
	p_mode IN VARCHAR2,
	p_service_level IN VARCHAR2,
	p_freight_terms_code IN VARCHAR2,
	p_transit_time IN NUMBER,
	p_transit_time_UOM IN VARCHAR2,
	x_result_consolidation_id_tab  IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_carrier_id_tab        IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_service_level_tab     IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_mode_of_transport_tab IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_freight_term_tab      IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_transit_time_min_tab	IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_transit_time_max_tab	IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_ship_method_code_tab         IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_return_status			OUT NOCOPY	VARCHAR2)

	IS
	l_freight_terms_code VARCHAR2(30);
	i NUMBER;
	l_ship_method_code VARCHAR2(30);
	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Populate_Get_SM_Result';

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
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	i:=x_result_consolidation_id_tab.LAST;
	IF (i IS NULL)
	THEN
		i:=1;
	ELSE
		i:=i+1;
	END IF;

	x_result_consolidation_id_tab(i):=p_source_header_rec.consolidation_id;

	Validate_Carrier(
		p_carrier_id=>p_carrier_id,
		x_return_status=>l_return_status);
	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Validate_Carrier Failed');
		END IF;
		x_result_carrier_id_tab(i):=NULL;

	ELSE
		x_result_carrier_id_tab(i):=p_carrier_id;
	END IF;





	Validate_Look_Up_NoCase(
		p_lookup_type=>'WSH_SERVICE_LEVELS',
		p_lookup_code=>p_service_level,
		x_lookup_code=>x_result_service_level_tab(i),
		x_return_status=>l_return_status);
	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Validate WSH_SERVICE_LEVELS Failed');
		END IF;

	END IF;


	--p_freight_terms_code is an INOUT parameter to Validate_Freight_terms
	l_freight_terms_code:=p_freight_terms_code;

	Validate_Look_Up_NoCase(
		p_lookup_type=>'FREIGHT_TERMS',
		p_lookup_code=>l_freight_terms_code,
		x_lookup_code=>x_result_freight_term_tab(i),
		x_return_status=>l_return_status);
	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Validate FREIGHT_TERMS Failed');
		END IF;
	END IF;


	Validate_Look_Up_NoCase(
		p_lookup_type=>'WSH_MODE_OF_TRANSPORT',
		p_lookup_code=>p_mode,
		x_lookup_code=>x_result_mode_of_transport_tab(i),
		x_return_status=>l_return_status);
	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Validate WSH_MODE_OF_TRANSPORT Failed');
		END IF;

	END IF;


	x_result_transit_time_min_tab(i):=NULL;

	x_result_transit_time_max_tab(i):=NULL;

	Get_Ship_Method_Code(
		p_org_id=>p_source_header_rec.ship_from_org_id,
		p_carrier_id=>p_carrier_id,
		p_mode=>p_mode,
		p_service_level=>p_service_level,
		x_ship_method_code=>l_ship_method_code,
		x_return_status=>l_return_status);

	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Get_Ship_Method_Code Failed');
		END IF;
		x_ship_method_code_tab(i):=NULL;

	ELSE
		x_ship_method_code_tab(i):=l_ship_method_code;
	END IF;



	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Populate_Get_SM_Result',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Populate_Get_SM_Result;


PROCEDURE Allocate_rates(
	p_summary_rate IN NUMBER,
	p_base_price IN NUMBER,
	p_charge IN NUMBER,
	p_source_header_rates_rec	IN FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_RATES_REC,
	p_source_header_rec		IN	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_REC,
	p_source_line_tab		IN FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_TAB,
	x_source_line_rates_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_RATES_TAB,
	x_return_status			OUT NOCOPY	VARCHAR2)
IS
	i	NUMBER;
	j	NUMBER;
	k	NUMBER;
	l_number_of_lines NUMBER;

	l_fraction NUMBER;
	l_base_price NUMBER;
	l_charge NUMBER;
	l_line_rate_rec FTE_PROCESS_REQUESTS.fte_source_line_rates_rec;

	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Allocate_rates';

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
	x_return_status := FND_API.G_RET_STS_SUCCESS;




	--FTE_SOURCE_LINE_CONSOLIDATION ensures that total weight in the header rec and weight in the line rec are in the same UOM

	--Index of the start of line rates;
	j:=p_source_header_rates_rec.first_line_index;

	i:=p_source_line_tab.FIRST;
	WHILE(i IS NOT NULL)
	LOOP



		IF((p_source_line_tab(i).consolidation_id IS NOT NULL)
		AND (p_source_header_rec.consolidation_id IS NOT NULL)
		AND (p_source_header_rec.consolidation_id = p_source_line_tab(i).consolidation_id))
		THEN


			l_fraction:=0;
			IF ((p_source_header_rec.total_weight IS NOT NULL)
			AND (p_source_line_tab(i).weight IS NOT NULL))
			THEN


				IF (p_source_header_rec.total_weight > 0)
				THEN
					l_fraction:=p_source_line_tab(i).weight/p_source_header_rec.total_weight;
				END IF;

				l_base_price:=p_base_price*l_fraction;
				l_charge:=p_charge*l_fraction;

				IF l_debug_on THEN

					WSH_DEBUG_SV.log(l_module_name,'j',j);
				END IF;

				--Init new line rate rec
				x_source_line_rates_tab(j):=l_line_rate_rec;


				x_source_line_rates_tab(j).source_line_id:=p_source_line_tab(i).source_line_id;

				x_source_line_rates_tab(j).cost_type_id   := g_price_cost_type_id;

				x_source_line_rates_tab(j).line_type_code := 'PRICE';

				x_source_line_rates_tab(j).cost_type      := 'FTEPRICE';
				x_source_line_rates_tab(j).cost_sub_type  := 'PRICE';



				x_source_line_rates_tab(j).priced_quantity:= p_source_line_tab(i).source_quantity;
				x_source_line_rates_tab(j).priced_uom     := p_source_line_tab(i).source_quantity_uom;



				IF ((x_source_line_rates_tab(j).priced_quantity IS NULL) OR (x_source_line_rates_tab(j).priced_quantity = 0))
				THEN
					x_source_line_rates_tab(j).adjusted_unit_price    := l_base_price;   -- adjusted unit price
					x_source_line_rates_tab(j).adjusted_price    := l_base_price ;   -- adjusted unit price (including discount)

				ELSE
					x_source_line_rates_tab(j).adjusted_unit_price    := (l_base_price)/(x_source_line_rates_tab(j).priced_quantity) ;   -- adjusted unit price
					x_source_line_rates_tab(j).adjusted_price    := l_base_price ;   -- adjusted unit price (including discount)

				END IF;
            x_source_line_rates_tab(j).currency := p_source_header_rates_rec.currency;

				x_source_line_rates_tab(j).unit_price     := x_source_line_rates_tab(j).adjusted_unit_price;
				x_source_line_rates_tab(j).base_price     := x_source_line_rates_tab(j).adjusted_price;

				x_source_line_rates_tab(j).consolidation_id := p_source_header_rec.consolidation_id;
				x_source_line_rates_tab(j).lane_id := p_source_header_rates_rec.lane_id;
				x_source_line_rates_tab(j).carrier_id := p_source_header_rates_rec.carrier_id;
				x_source_line_rates_tab(j).carrier_freight_code := p_source_header_rates_rec.carrier_freight_code;
				x_source_line_rates_tab(j).service_level := p_source_header_rates_rec.service_level;
				x_source_line_rates_tab(j).mode_of_transport := p_source_header_rates_rec.mode_of_transport;
				x_source_line_rates_tab(j).ship_method_code := p_source_header_rates_rec.ship_method_code;


				j:=j+1;


				IF l_debug_on THEN

					WSH_DEBUG_SV.log(l_module_name,'p_charge',p_charge);
				END IF;


				--Insert a charge rec only if charge > 0
				IF ((p_charge IS NOT NULL) AND (p_charge > 0))
				THEN

					IF l_debug_on THEN

						WSH_DEBUG_SV.log(l_module_name,'Creating Charge line');
					END IF;

					--Init new line rate rec
					x_source_line_rates_tab(j):=l_line_rate_rec;


					x_source_line_rates_tab(j).source_line_id := p_source_line_tab(i).source_line_id;
					x_source_line_rates_tab(j).cost_type_id   := NULL; -- fix this
					x_source_line_rates_tab(j).line_type_code := 'CHARGE';
					x_source_line_rates_tab(j).cost_type      := 'FTECHARGE';
					x_source_line_rates_tab(j).cost_sub_type  := NULL;
					x_source_line_rates_tab(j).priced_quantity    := p_source_line_tab(i).source_quantity;
					x_source_line_rates_tab(j).priced_uom     := p_source_line_tab(i).source_quantity_uom;

					IF ((x_source_line_rates_tab(j).priced_quantity IS NULL) OR (x_source_line_rates_tab(j).priced_quantity = 0))
					THEN
						x_source_line_rates_tab(j).adjusted_unit_price    := l_charge;   -- adjusted unit price
						x_source_line_rates_tab(j).adjusted_price    := l_charge ;   -- adjusted unit price (including discount)

					ELSE
						x_source_line_rates_tab(j).adjusted_unit_price    := (l_charge)/(x_source_line_rates_tab(j).priced_quantity) ;   -- adjusted unit price
						x_source_line_rates_tab(j).adjusted_price    := l_charge;   -- adjusted unit price (including discount)

					END IF;


					x_source_line_rates_tab(j).unit_price     := x_source_line_rates_tab(j).adjusted_unit_price;
					x_source_line_rates_tab(j).base_price     := x_source_line_rates_tab(j).adjusted_price;

		    x_source_line_rates_tab(j).currency := p_source_header_rates_rec.currency;

					x_source_line_rates_tab(j).consolidation_id := p_source_header_rec.consolidation_id;
					x_source_line_rates_tab(j).lane_id := p_source_header_rates_rec.lane_id;
					x_source_line_rates_tab(j).carrier_id := p_source_header_rates_rec.carrier_id;
					x_source_line_rates_tab(j).carrier_freight_code := p_source_header_rates_rec.carrier_freight_code;
					x_source_line_rates_tab(j).service_level := p_source_header_rates_rec.service_level;
					x_source_line_rates_tab(j).mode_of_transport := p_source_header_rates_rec.mode_of_transport;
					x_source_line_rates_tab(j).ship_method_code := p_source_header_rates_rec.ship_method_code;



					j:=j+1;
				END IF;

			END IF;

		END IF;
		i:=p_source_line_tab.NEXT(i);
	END LOOP;

	--If total_weight is 0 distribute charges equally to all lines
	IF ((p_source_header_rec.total_weight IS NULL) OR (p_source_header_rec.total_weight =0))
	THEN

		IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_module_name,'total weight is or null');
		END IF;

		l_number_of_lines:=(j-p_source_header_rates_rec.first_line_index)/2;
		l_fraction:=1/l_number_of_lines;
		l_base_price:=p_base_price*l_fraction;
		l_charge:=p_charge*l_fraction;

		j:=p_source_header_rates_rec.first_line_index;
		WHILE(j IS NOT NULL)
		LOOP
			IF (x_source_line_rates_tab(j).cost_sub_type='PRICE')
			THEN
				x_source_line_rates_tab(j).unit_price:=l_base_price;
				x_source_line_rates_tab(j).base_price:=l_base_price;
				x_source_line_rates_tab(j).adjusted_unit_price:=l_base_price;
				x_source_line_rates_tab(j).adjusted_price:=l_base_price;

			ELSE

				x_source_line_rates_tab(j).unit_price:=l_charge;
				x_source_line_rates_tab(j).base_price:=l_charge;
				x_source_line_rates_tab(j).adjusted_unit_price:=l_charge;
				x_source_line_rates_tab(j).adjusted_price:=l_charge;


			END IF;

			j:=x_source_line_rates_tab.NEXT(j);
		END LOOP;

	END IF;


	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Allocate_rates',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Allocate_rates;



PROCEDURE Populate_Get_FC_Result(
	p_summary_rate IN NUMBER,
	p_base_rate IN NUMBER,
	p_charge_rate IN NUMBER,
	p_transit_time IN NUMBER,
	p_transit_time_UOM IN VARCHAR2,
	p_source_header_rec		IN	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_REC,
	p_source_line_tab		IN FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_TAB,
	x_source_line_rates_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_RATES_TAB,
	x_source_header_rates_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_RATES_TAB,
	x_return_status			OUT NOCOPY	VARCHAR2)
	IS

	i	NUMBER;
	j	NUMBER;
	k	NUMBER;
	l_generic_carrier VARCHAR2(1);
	l_carrier_freight_code VARCHAR2(30);

	l_source_header_rates_rec FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_RATES_REC;

	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Populate_Get_FC_Result';

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
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--i is the source header rates tab index
	i:=x_source_header_rates_tab.LAST;
	IF (i IS NULL)
	THEN
		i:=1;
	ELSE
		i:=i+1;
	END IF;

	--j is the source line rates tab index
	j:=x_source_line_rates_tab.LAST;
	IF (j IS NULL)
	THEN
		j:=1;
	ELSE
		j:=j+1;
	END IF;

	--Init source header rates rec
	x_source_header_rates_tab(i):=l_source_header_rates_rec;

	x_source_header_rates_tab(i).consolidation_id := p_source_header_rec.consolidation_id;
	--No real Lane id, fake lane id
	x_source_header_rates_tab(i).lane_id := i;
	x_source_header_rates_tab(i).carrier_id := p_source_header_rec.carrier_id;

	--Get carrier freight code

	IF (x_source_header_rates_tab(i).carrier_id IS NOT NULL)
	THEN

		Get_Carrier_Info(
			p_carrier_id=>x_source_header_rates_tab(i).carrier_id,
			x_generic=>l_generic_carrier,
			x_carrier_freight_code=>l_carrier_freight_code,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'Dest Location Get Info Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;
		x_source_header_rates_tab(i).carrier_freight_code := l_carrier_freight_code;
	END IF;



	x_source_header_rates_tab(i).service_level := p_source_header_rec.service_level;
	x_source_header_rates_tab(i).mode_of_transport := p_source_header_rec.mode_of_transport;
	x_source_header_rates_tab(i).ship_method_code := p_source_header_rec.ship_method_code;
	x_source_header_rates_tab(i).cost_type_id := null;
	x_source_header_rates_tab(i).cost_type := 'SUMMARY';
	x_source_header_rates_tab(i).price := p_summary_rate;
	x_source_header_rates_tab(i).currency := p_source_header_rec.currency;
	x_source_header_rates_tab(i).transit_time := p_transit_time;
	x_source_header_rates_tab(i).transit_time_uom := p_transit_time_UOM;
	x_source_header_rates_tab(i).first_line_index := j;


	Allocate_rates(
		p_summary_rate=>p_summary_rate,
		p_base_price=>p_base_rate,
		p_charge=>p_charge_rate,
		p_source_header_rates_rec=>x_source_header_rates_tab(i),
		p_source_header_rec=>p_source_header_rec,
		p_source_line_tab=>p_source_line_tab,
		x_source_line_rates_tab=>x_source_line_rates_tab,
		x_return_status=>l_return_status);

	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Allocate_rates Failed');
		END IF;

		raise FND_API.G_EXC_ERROR;
	END IF;


	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Populate_Get_FC_Result',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Populate_Get_FC_Result;



PROCEDURE Populate_Choose_SM_Result(
	p_carrier_id IN NUMBER,
	p_mode IN VARCHAR2,
	p_service_level IN VARCHAR2,
	p_freight_terms_code IN VARCHAR2,
	p_transit_time IN NUMBER,
	p_transit_time_UOM IN VARCHAR2,
	p_summary_rate IN NUMBER,
	p_base_rate IN NUMBER,
	p_charge_rate IN NUMBER,
	p_ship_method_code IN VARCHAR2,
	p_source_header_rec		IN	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_REC,
	p_source_line_tab		IN FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_TAB,
	x_source_line_rates_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_RATES_TAB,
	x_source_header_rates_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_RATES_TAB,
	x_return_status			OUT NOCOPY	VARCHAR2)
	IS
	i	NUMBER;
	j	NUMBER;
	k	NUMBER;
	l_source_header_rates_rec FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_RATES_REC;
	l_generic_carrier VARCHAR2(1);
	l_carrier_freight_code VARCHAR2(30);

	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Populate_Choose_SM_Result';

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
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	--i is the source header rates tab index
	i:=x_source_header_rates_tab.LAST;
	IF (i IS NULL)
	THEN
		i:=1;
	ELSE
		i:=i+1;
	END IF;

	--j is the source line rates tab index
	j:=x_source_line_rates_tab.LAST;
	IF (j IS NULL)
	THEN
		j:=1;
	ELSE
		j:=j+1;
	END IF;




	--If no SM Code then do not populate results for this carrier/mode/service level

	IF (p_ship_method_code IS NOT NULL)
	THEN

		--Init source header rates rec
		x_source_header_rates_tab(i):=l_source_header_rates_rec;

		x_source_header_rates_tab(i).consolidation_id := p_source_header_rec.consolidation_id;
		--No real Lane id, fake lane id
		x_source_header_rates_tab(i).lane_id := i;
		x_source_header_rates_tab(i).carrier_id := p_carrier_id;

		--Get carrier freight code

		IF (x_source_header_rates_tab(i).carrier_id IS NOT NULL)
		THEN
			l_carrier_freight_code:=NULL;

			Get_Carrier_Info(
				p_carrier_id=>x_source_header_rates_tab(i).carrier_id,
				x_generic=>l_generic_carrier,
				x_carrier_freight_code=>l_carrier_freight_code,
				x_return_status=>l_return_status);

			IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
				 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
				IF l_debug_on
				THEN
					WSH_DEBUG_SV.log(l_module_name,'Get_Carrier_Info Failed');
				END IF;
				raise FND_API.G_EXC_ERROR;
			END IF;
			x_source_header_rates_tab(i).carrier_freight_code := l_carrier_freight_code;
		END IF;


		x_source_header_rates_tab(i).ship_method_code:=p_ship_method_code;

		x_source_header_rates_tab(i).service_level := p_service_level;
		x_source_header_rates_tab(i).mode_of_transport := p_mode;




		x_source_header_rates_tab(i).cost_type_id := null;
		x_source_header_rates_tab(i).cost_type := 'SUMMARY';
		x_source_header_rates_tab(i).price := p_summary_rate;
		x_source_header_rates_tab(i).currency := p_source_header_rec.currency;
		x_source_header_rates_tab(i).transit_time := p_transit_time;
		x_source_header_rates_tab(i).transit_time_uom := p_transit_time_UOM;
		x_source_header_rates_tab(i).first_line_index := j;


		Allocate_rates(
			p_summary_rate=>p_summary_rate,
			p_base_price=>p_base_rate,
			p_charge=>p_charge_rate,
			p_source_header_rates_rec=>x_source_header_rates_tab(i),
			p_source_header_rec=>p_source_header_rec,
			p_source_line_tab=>p_source_line_tab,
			x_source_line_rates_tab=>x_source_line_rates_tab,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Allocate_rates Failed');
			END IF;

			raise FND_API.G_EXC_ERROR;
		END IF;
	ELSE
		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'Ignoring this Choose Ship Method result');
			WSH_DEBUG_SV.log(l_module_name,'p_carrier_id',p_carrier_id);
			WSH_DEBUG_SV.log(l_module_name,'p_mode',p_mode);
			WSH_DEBUG_SV.log(l_module_name,'p_service_level',p_service_level);

		END IF;


	END IF;

	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Populate_Choose_SM_Result',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Populate_Choose_SM_Result;



PROCEDURE Handle_Get_SM_Response(
	p_xml_output IN XMLTYPE,
	p_source_type			IN		VARCHAR2,
	p_action			IN		VARCHAR2,
	x_source_header_rec		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_REC,
	x_result_consolidation_id_tab  IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_carrier_id_tab        IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_service_level_tab     IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_mode_of_transport_tab IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_freight_term_tab      IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_transit_time_min_tab	IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_transit_time_max_tab	IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_ship_method_code_tab         IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_return_status			OUT NOCOPY	VARCHAR2)
	IS

	i NUMBER;
	l_xml_seq XMLSequenceType;
	l_carrier_id NUMBER;
	l_mode VARCHAR2(30);
	l_service_level VARCHAR2(30);
	l_freight_terms VARCHAR2(30);
	l_transit_time NUMBER;
	l_transit_time_UOM VARCHAR2(30);
	l_tmp_xml XMLTYPE;

	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Handle_Get_SM_Response';



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
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF l_debug_on
	THEN
		WSH_DEBUG_SV.log(l_module_name,'p_xml_output',p_xml_output.getStringVal());
		WSH_DEBUG_SV.log(l_module_name,'xpath:',G_XPATH_GET_SM_RESULT);
	END IF;

	Fetch_XML_Match(
		p_xml=>p_xml_output,
		p_xpath=>G_XPATH_GET_SM_RESULT,
		x_xml_seq=>l_xml_seq,
		x_return_status=>l_return_status);
	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Fetch_XML_Match Failed');
		END IF;

		raise FND_API.G_EXC_ERROR;
	END IF;

	i:=l_xml_seq.FIRST;

	IF (i  IS NOT NULL)
	THEN

		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'l_xml_seq(i)',l_xml_seq(i).getStringVal());
			WSH_DEBUG_SV.log(l_module_name,'xpath prefix:',G_XPATH_GET_SM_PREFIX);
		END IF;


		Extract_Ship_Method(
			p_xml=>l_xml_seq(i),
			p_xpath_prefix=>G_XPATH_GET_SM_PREFIX,
			p_action=>p_action,
			x_carrier_id=>l_carrier_id,
			x_mode=>l_mode,
			x_service_level=>l_service_level,
			x_freight_terms_code=>l_freight_terms,
			x_transit_time=>l_transit_time,
			x_transit_time_UOM=>l_transit_time_uom,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Extract_Ship_Method Failed');
			END IF;

			raise FND_API.G_EXC_ERROR;
		END IF;





		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'l_carrier_id',l_carrier_id);
			WSH_DEBUG_SV.log(l_module_name,'l_mode',l_mode);
			WSH_DEBUG_SV.log(l_module_name,'l_service_level',l_service_level);
			WSH_DEBUG_SV.log(l_module_name,'l_freight_terms',l_freight_terms);
			WSH_DEBUG_SV.log(l_module_name,'l_transit_time',l_transit_time);
			WSH_DEBUG_SV.log(l_module_name,'l_transit_time_uom',l_transit_time_uom);

		END IF;


		Populate_Get_SM_Result(
			p_source_header_rec=>x_source_header_rec,
			p_carrier_id=>l_carrier_id,
			p_mode=>l_mode,
			p_service_level=>l_service_level,
			p_freight_terms_code=>l_freight_terms,
			p_transit_time=>l_transit_time,
			p_transit_time_UOM=>l_transit_time_uom,
			x_result_consolidation_id_tab=>x_result_consolidation_id_tab,
			x_result_carrier_id_tab=>x_result_carrier_id_tab,
			x_result_service_level_tab=>x_result_service_level_tab,
			x_result_mode_of_transport_tab=>x_result_mode_of_transport_tab,
			x_result_freight_term_tab=>x_result_freight_term_tab,
			x_result_transit_time_min_tab=>x_result_transit_time_min_tab,
			x_result_transit_time_max_tab=>x_result_transit_time_max_tab,
			x_ship_method_code_tab=>x_ship_method_code_tab,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Populate_Get_SM_Result Failed');
			END IF;

			raise FND_API.G_EXC_ERROR;
		END IF;

	ELSE
		IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_module_name,'Path does not exist',G_XPATH_GET_SM_RESULT);

		END IF;
		raise FND_API.G_EXC_ERROR;


	END IF;

	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Handle_Get_SM_Response',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Handle_Get_SM_Response;


PROCEDURE Handle_Get_FC_Response(
	p_xml_output IN XMLTYPE,
	p_source_type			IN		VARCHAR2,
	p_action			IN		VARCHAR2,
	p_source_header_rec		IN FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_REC,
	p_source_line_tab		IN FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_TAB,
	x_source_line_rates_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_RATES_TAB,
	x_source_header_rates_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_RATES_TAB,
	x_return_status			OUT NOCOPY	VARCHAR2)
	IS

	l_summary_rate NUMBER;
	l_base_rate NUMBER;
	l_charge_rate NUMBER;
	l_tmp_xml XMLTYPE;

	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Handle_Get_FC_Response';

        CURSOR c_get_currency(p_source_header_id number) IS
        SELECT transactional_curr_code
        FROM oe_order_headers_all
        WHERE header_id = p_source_header_id;

        l_currency_code OE_ORDER_HEADERS_ALL.TRANSACTIONAL_CURR_CODE%TYPE := NULL;

        -- exceptions related to getting currency_code from order table
        ORDER_NO_HEADER_ID_ERROR EXCEPTION;
        ORDER_NO_CURR_ERROR      EXCEPTION;

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
                WSH_DEBUG_SV.log(l_module_name,'p_source_line_tab.count',p_source_line_tab.count);
                WSH_DEBUG_SV.log(l_module_name,'p_source_line_tab(p_source_line_tab.FIRST).source_header_id',
                p_source_line_tab(p_source_line_tab.FIRST).source_header_id);
                WSH_DEBUG_SV.log(l_module_name,'p_source_header_rec.currency',p_source_header_rec.currency);
	END IF;
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_source_header_rec.currency IS NOT NULL THEN
           l_currency_code := p_source_header_rec.currency;
        ELSE
           IF (p_source_line_tab(p_source_line_tab.FIRST).source_header_id IS NULL) THEN
             raise ORDER_NO_HEADER_ID_ERROR;
           END IF;
	   IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'fetching c_get_currency');
           END IF;

           OPEN c_get_currency(p_source_line_tab(p_source_line_tab.FIRST).source_header_id);
           FETCH c_get_currency INTO l_currency_code;
           CLOSE c_get_currency;

	   IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name, 'after fetch:', l_currency_code);
           END IF;

           IF (l_currency_code IS NULL) THEN
             raise ORDER_NO_CURR_ERROR;
           END IF;

        END IF;

	l_tmp_xml:=p_xml_output.extract(G_XPATH_FREIGHT_COST_RESULT,g_xml_namespace_map);
	IF (l_tmp_xml IS NOT NULL)
	THEN

		Extract_Rate(
			p_xml=>l_tmp_xml,
			p_xpath_prefix=>G_XPATH_FREIGHT_COST_PREFIX,
			p_currency=> l_currency_code,
			x_summary_rate=>l_summary_rate,
			x_base_rate=>l_base_rate,
			x_charge_rate=>l_charge_rate,
			x_return_status=>l_return_status);
		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Extract_Ship_Method Failed');
			END IF;

			raise FND_API.G_EXC_ERROR;
		END IF;

		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'l_summary_rate',l_summary_rate);
			WSH_DEBUG_SV.log(l_module_name,'l_base_rate',l_base_rate);
			WSH_DEBUG_SV.log(l_module_name,'l_charge_rate',l_charge_rate);
		END IF;



		Populate_Get_FC_Result(
			p_summary_rate=>l_summary_rate,
			p_base_rate=>l_base_rate,
			p_charge_rate=>l_charge_rate,
			p_transit_time=>NULL,
			p_transit_time_UOM=>NULL,
			p_source_header_rec=>p_source_header_rec,
			p_source_line_tab=>p_source_line_tab,
			x_source_line_rates_tab=>x_source_line_rates_tab,
			x_source_header_rates_tab=>x_source_header_rates_tab,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Populate_Get_FC_Result Failed');
			END IF;

			raise FND_API.G_EXC_ERROR;
		END IF;
	ELSE

		IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_module_name,'Path does not exist',G_XPATH_FREIGHT_COST_RESULT);

		END IF;
		raise FND_API.G_EXC_ERROR;
	END IF;
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION
	WHEN ORDER_NO_HEADER_ID_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Order Header Id is null',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:ORDER_NO_HEADER_ID_ERROR');
		END IF;

	WHEN ORDER_NO_CURR_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Transactional Curr Code is not defined for the order.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:ORDER_NO_CURR_ERROR');
		END IF;

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Handle_Get_FC_Response',l_module_name);
                -- in case the exception occured while working on
                -- cursor c_get_currency
                IF c_get_currency%ISOPEN THEN
                  CLOSE c_get_currency;
                END IF;
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Handle_Get_FC_Response;

PROCEDURE Handle_Choose_SM_Response(
	p_xml_output IN XMLTYPE,
	p_source_type			IN		VARCHAR2,
	p_action			IN		VARCHAR2,
	p_source_header_rec		IN FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_REC,
	p_source_line_tab		IN FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_TAB,
	x_source_line_rates_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_RATES_TAB,
	x_source_header_rates_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_RATES_TAB,
	x_return_status			OUT NOCOPY	VARCHAR2)
	IS

	l_SM_failure VARCHAR2(1);
	l_summary_rate NUMBER;
	l_base_rate NUMBER;
	l_charge_rate NUMBER;

	l_carrier_id NUMBER;
	l_mode VARCHAR2(30);
	l_service_level VARCHAR2(30);
	l_freight_terms VARCHAR2(30);
	l_transit_time NUMBER;
	l_transit_time_UOM VARCHAR2(30);

	i NUMBER;
	l_xml_seq XMLSequenceType;
	l_sm_tab WSH_SM_TAB;
	l_sm_rec_empty WSH_SM_REC;
	l_sm_rec WSH_SM_REC;
	l_sm_rec_hash WSH_SM_REC;
	l_sm_rec_i WSH_SM_REC;
	l_sm_i VARCHAR2(30);
	l_ship_method_code VARCHAR2(30);

	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Handle_Choose_SM_Response';



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
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	Fetch_XML_Match(
		p_xml=>p_xml_output,
		p_xpath=>G_XPATH_SM_OPTION,
		x_xml_seq=>l_xml_seq,
		x_return_status=>l_return_status);

	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Fetch_XML_Match Failed');
		END IF;

		raise FND_API.G_EXC_ERROR;
	END IF;


	i:=l_xml_seq.FIRST;
	WHILE (i IS NOT NULL)
	LOOP
		l_SM_failure:='N';
		l_sm_rec:=l_sm_rec_empty;

		Extract_Ship_Method(
			p_xml=>l_xml_seq(i),
			p_xpath_prefix=>G_XPATH_SM_OPTION_PREFIX,
			p_action=>p_action,
			x_carrier_id=>l_sm_rec.carrier_id,
			x_mode=>l_sm_rec.mode_of_transport,
			x_service_level=>l_sm_rec.service_level,
			x_freight_terms_code=>l_sm_rec.freight_terms,
			x_transit_time=>l_sm_rec.transit_time,
			x_transit_time_UOM=>l_sm_rec.transit_time_uom,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'Extract_Ship_Method Failed');
			END IF;
			l_SM_failure:='Y';

			--raise FND_API.G_EXC_ERROR;


		END IF;

		IF ((l_sm_rec.carrier_id IS NULL) OR (l_sm_rec.mode_of_transport IS NULL) OR (l_sm_rec.service_level IS NULL))
		THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'Missing a Ship Method component');
			END IF;
			l_SM_failure:='Y';
		END IF;



		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'l_sm_rec.carrier_id',l_sm_rec.carrier_id);
			WSH_DEBUG_SV.log(l_module_name,'l_sm_rec.mode_of_transport',l_sm_rec.mode_of_transport);
			WSH_DEBUG_SV.log(l_module_name,'l_sm_rec.service_level',l_sm_rec.service_level);
			WSH_DEBUG_SV.log(l_module_name,'l_sm_rec.freight_terms',l_sm_rec.freight_terms);
			WSH_DEBUG_SV.log(l_module_name,'l_sm_rec.transit_time',l_sm_rec.transit_time);
			WSH_DEBUG_SV.log(l_module_name,'l_sm_rec.transit_time_uom',l_sm_rec.transit_time_uom);

		END IF;

		IF(l_SM_failure='N')
		THEN
			Get_Ship_Method_Code(
				p_org_id=>p_source_header_rec.ship_from_org_id,
				p_carrier_id=>l_sm_rec.carrier_id,
				p_mode=>l_sm_rec.mode_of_transport,
				p_service_level=>l_sm_rec.service_level,
				x_ship_method_code=>l_sm_rec.ship_method_code,
				x_return_status=>l_return_status);

			IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
				 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN

				IF l_debug_on
				THEN
					WSH_DEBUG_SV.log(l_module_name,'Get_Ship_Method_Code Failed');

				END IF;
				l_SM_failure:='Y';
			END IF;

			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'l_sm_rec.ship_method_code',l_sm_rec.ship_method_code);
			END IF;

		END IF;

		IF(l_SM_failure='N')
		THEN
			Extract_Rate(
				p_xml=>l_xml_seq(i),
				p_xpath_prefix=>G_XPATH_SM_OPTION_PREFIX,
				p_currency=>p_source_header_rec.currency,
				x_summary_rate=>l_sm_rec.summary_rate,
				x_base_rate=>l_sm_rec.base_rate,
				x_charge_rate=>l_sm_rec.charge_rate,
				x_return_status=>l_return_status);
			IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
				 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
				IF l_debug_on
				THEN
					WSH_DEBUG_SV.log(l_module_name,'Extract_Rate Failed');
				END IF;

				raise FND_API.G_EXC_ERROR;
			END IF;


			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'l_sm_rec.summary_rate',l_sm_rec.summary_rate);
				WSH_DEBUG_SV.log(l_module_name,'l_sm_rec.base_rate',l_sm_rec.base_rate);
				WSH_DEBUG_SV.log(l_module_name,'l_sm_rec.charge_rate',l_sm_rec.charge_rate);
			END IF;


			Validate_Transit_Time(
				x_transit_time=>l_sm_rec.transit_time,
				x_transit_time_uom=>l_sm_rec.transit_time_uom,
				x_return_status=>l_return_status);
			IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
				 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
				IF l_debug_on
				THEN
					WSH_DEBUG_SV.log(l_module_name,'Validate_Transit_Time Failed');

				END IF;
			END IF;

			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'l_sm_rec.transit_time',l_sm_rec.transit_time);
				WSH_DEBUG_SV.log(l_module_name,'l_sm_rec.transit_time_uom',l_sm_rec.transit_time_uom);
			END IF;




			IF(l_sm_rec.ship_method_code IS NOT NULL)
			THEN
				IF(l_SM_tab.EXISTS(l_sm_rec.ship_method_code))
				THEN

					l_sm_rec_hash:=l_SM_tab(l_sm_rec.ship_method_code);

					IF (l_sm_rec.summary_rate < l_sm_rec_hash.summary_rate)
					THEN

						l_SM_tab(l_sm_rec.ship_method_code):=l_sm_rec;

					END IF;
				ELSE


					l_SM_tab(l_sm_rec.ship_method_code):=l_sm_rec;

				END IF;

			END IF;

		END IF;
		i:=l_xml_seq.NEXT(i);

	END LOOP;


	l_sm_i:=l_SM_tab.FIRST;
	WHILE(l_sm_i IS NOT NULL)
	LOOP
		l_sm_rec_i:=l_SM_tab(l_sm_i);

		Populate_Choose_SM_Result(
			p_carrier_id=>l_sm_rec_i.carrier_id,
			p_mode=>l_sm_rec_i.mode_of_transport,
			p_service_level=>l_sm_rec_i.service_level,
			p_freight_terms_code=>l_sm_rec_i.freight_terms,
			p_transit_time=>l_sm_rec_i.transit_time,
			p_transit_time_UOM=>l_sm_rec_i.transit_time_uom,
			p_summary_rate=>l_sm_rec_i.summary_rate,
			p_base_rate=>l_sm_rec_i.base_rate,
			p_charge_rate=>l_sm_rec_i.charge_rate,
			p_ship_method_code=>l_sm_rec_i.ship_method_code,
			p_source_header_rec=>p_source_header_rec,
			p_source_line_tab=>p_source_line_tab,
			x_source_line_rates_tab=>x_source_line_rates_tab,
			x_source_header_rates_tab=>x_source_header_rates_tab,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'Populate_Choose_SM_Result Failed');
			END IF;

			raise FND_API.G_EXC_ERROR;
		END IF;

		l_sm_i:=l_SM_tab.NEXT(l_sm_i);

	END LOOP;

	--Sort header by rates

	Sort(
		x_source_header_rates_tab=>x_source_header_rates_tab,
		x_return_status=>l_return_status);

	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Sort Failed');
		END IF;

		raise FND_API.G_EXC_ERROR;
	END IF;

	IF (x_source_header_rates_tab.COUNT = 0)
	THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'No Valid results for Choos Ship Method');
		END IF;


		raise FND_API.G_EXC_ERROR;

	END IF;

	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Handle_Choose_SM_Response',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Handle_Choose_SM_Response;


PROCEDURE	Parse_RIQ_Output_XML(
	p_xml_output IN XMLTYPE,
	p_source_type			IN		VARCHAR2,
	p_action			IN		VARCHAR2,
	x_source_header_rec		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_REC,
	x_source_line_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_TAB,
	x_source_line_rates_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_RATES_TAB,
	x_source_header_rates_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_RATES_TAB,
	x_result_consolidation_id_tab  IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_carrier_id_tab        IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_service_level_tab     IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_mode_of_transport_tab IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_freight_term_tab      IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_transit_time_min_tab	IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_transit_time_max_tab	IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_ship_method_code_tab         IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_return_status			OUT NOCOPY	VARCHAR2)
	IS

	l_xpath_status_prefix VARCHAR2(200);
	l_return_status   VARCHAR2(1);
	l_debug_on BOOLEAN;
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Parse_RIQ_Output_XML';



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
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF(p_xml_output IS NOT NULL)
	THEN
		--g_xml_namespace_map:=p_xml_output.getNameSpace();
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Namespace',g_xml_namespace_map);
		END IF;


	END IF;

	IF((p_action IS NOT NULL) AND (p_action='C'))
	THEN
		l_xpath_status_prefix:=G_XPATH_SM_STATUS_PREFIX;
	ELSE
		l_xpath_status_prefix:=G_XPATH_RIQ_STATUS_PREFIX;
	END IF;


	Check_Response_Status(
		p_xpath_prefix=>l_xpath_status_prefix,
		p_xml_output=>p_xml_output,
		x_return_status=>l_return_status);
	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Check_Response_Status Failed');
		END IF;

		raise FND_API.G_EXC_ERROR;
	END IF;



	IF (p_action =  'GET_RATE_CHOICE')
	THEN
		Handle_Choose_SM_Response(
			p_xml_output=>p_xml_output,
			p_source_type=>p_source_type,
			p_action=>p_action,
			p_source_header_rec=>x_source_header_rec,
			p_source_line_tab=>x_source_line_tab,
			x_source_line_rates_tab=>x_source_line_rates_tab,
			x_source_header_rates_tab=>x_source_header_rates_tab,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Handle_Choose_SM_Response Failed');
			END IF;

			raise FND_API.G_EXC_ERROR;
		END IF;


	ELSIF(p_action='R')
	THEN
		 Handle_Get_FC_Response(
			p_xml_output=>p_xml_output,
			p_source_type=>p_source_type,
			p_action=>p_action,
			p_source_header_rec=>x_source_header_rec,
			p_source_line_tab=>x_source_line_tab,
			x_source_line_rates_tab=>x_source_line_rates_tab,
			x_source_header_rates_tab=>x_source_header_rates_tab,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Handle_Get_FC_Response Failed');
			END IF;

			raise FND_API.G_EXC_ERROR;
		END IF;


	ELSIF (p_action= 'C')
	THEN

		Handle_Get_SM_Response(
			p_xml_output=>p_xml_output,
			p_source_type=>p_source_type,
			p_action=>p_action,
			x_source_header_rec=>x_source_header_rec,
			x_result_consolidation_id_tab=>x_result_consolidation_id_tab,
			x_result_carrier_id_tab=>x_result_carrier_id_tab,
			x_result_service_level_tab=>x_result_service_level_tab,
			x_result_mode_of_transport_tab=>x_result_mode_of_transport_tab,
			x_result_freight_term_tab=>x_result_freight_term_tab,
			x_result_transit_time_min_tab=>x_result_transit_time_min_tab,
			x_result_transit_time_max_tab=>x_result_transit_time_max_tab,
			x_ship_method_code_tab=>x_ship_method_code_tab,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Handle_Get_FC_Response Failed');
			END IF;

			raise FND_API.G_EXC_ERROR;
		END IF;


	END IF;



	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Parse_RIQ_Output_XML',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Parse_RIQ_Output_XML;

PROCEDURE Init_Globals(
		x_return_status			OUT NOCOPY	VARCHAR2)
IS

	CURSOR c_get_global_time_class
	IS
	SELECT gu_time_class
	FROM WSH_GLOBAL_PARAMETERS;

	CURSOR c_get_price_cost_type_id
	IS
	SELECT freight_cost_type_id
	FROM WSH_FREIGHT_COST_TYPES
	WHERE name='PRICE' AND freight_cost_type_code='FTEPRICE';
	l_return_status   VARCHAR2(1);

	--
	l_debug_on BOOLEAN;

	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Init_Globals';
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
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--Clean up cache
	g_carrier_freight_codes.DELETE;
	g_carrier_generic_flags.DELETE;

	g_price_cost_type_id:=NULL;

	OPEN c_get_price_cost_type_id;
	FETCH c_get_price_cost_type_id INTO g_price_cost_type_id;
	CLOSE c_get_price_cost_type_id;

	g_domain_name:=FND_PROFILE.Value('WSH_OTM_DOMAIN_NAME');

        --Servlet URI, raise the same message as in WSHGLHUB.pls
	g_servlet_uri := FND_PROFILE.VALUE('WSH_OTM_SERVLET_URI');

	--User/Pwd, raise the same message as in WSHGLHUB.pls
	g_user_name:=FND_PROFILE.Value('WSH_OTM_USER_ID');
	g_password:=FND_PROFILE.Value('WSH_OTM_PASSWORD');

	IF ((g_servlet_uri IS NULL) OR (g_user_name IS NULL) OR (g_password IS NULL)) THEN--{

	  IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'OTM Servlet URI ',g_servlet_uri);
	    WSH_DEBUG_SV.log(l_module_name,'user ',g_user_name);
	    WSH_DEBUG_SV.log(l_module_name,'password ',g_password);
	  END IF;

	  IF g_servlet_uri IS NULL THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_PROFILE_NOT_SET_ERR');
            FND_MESSAGE.SET_TOKEN('PRF_NAME',fnd_message.get_string('WSH','WSH_OTM_SERVLET_URI'));
            FND_MSG_PUB.ADD;
          END IF;

          IF g_user_name IS NULL THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_PROFILE_NOT_SET_ERR');
            FND_MESSAGE.SET_TOKEN('PRF_NAME',fnd_message.get_string('WSH','WSH_OTM_USER_ID'));
            FND_MSG_PUB.ADD;
          END IF;

          IF g_password IS NULL THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_PROFILE_NOT_SET_ERR');
            FND_MESSAGE.SET_TOKEN('PRF_NAME',fnd_message.get_string('WSH','WSH_OTM_PASSWORD'));
            FND_MSG_PUB.ADD;
          END IF;

	  RAISE FND_API.G_EXC_ERROR;
        END IF;--}

	--Time Zone
	g_timezone_code:=FND_TIMEZONES.get_server_timezone_code;

	OPEN c_get_global_time_class;
	FETCH c_get_global_time_class INTO g_global_time_class;
	CLOSE c_get_global_time_class;

	g_xml_namespace_map:=G_GLOG_NS_MAP;


	g_EBS_to_OTM_UOM_map.DELETE;
	g_OTM_to_EBS_UOM_map.DELETE;

	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Init_Globals',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Init_Globals;


PROCEDURE Clear_Globals(
	x_return_status			OUT NOCOPY	VARCHAR2)
IS
	l_return_status   VARCHAR2(1);

	--
	l_debug_on BOOLEAN;

	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Clear_Globals';
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
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--Clean up cache
	g_carrier_freight_codes.DELETE;
	g_carrier_generic_flags.DELETE;


	g_EBS_to_OTM_UOM_map.DELETE;
	g_OTM_to_EBS_UOM_map.DELETE;

	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Clear_Globals',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Clear_Globals;


PROCEDURE Process_One_Header(
	x_source_line_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_TAB,
	x_source_header_rec		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_REC,
	x_source_header_rec_xml		IN OUT NOCOPY	WSH_OTM_RIQ_HEADER_REC,
	p_source_type			IN		VARCHAR2,
	p_action			IN		VARCHAR2,
	x_source_line_rates_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_RATES_TAB,
	x_source_header_rates_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_RATES_TAB,
	x_result_consolidation_id_tab  IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_carrier_id_tab        IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_service_level_tab     IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_mode_of_transport_tab IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_freight_term_tab      IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_transit_time_min_tab	IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_transit_time_max_tab	IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_ship_method_code_tab         IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_return_status			OUT NOCOPY	VARCHAR2)
IS
        j NUMBER; -- Bug 6810844
	i NUMBER;
	l_source_header_tab_xml WSH_OTM_RIQ_HEADER_TAB;
	l_source_line_tab_xml WSH_OTM_RIQ_LINE_TAB;
	l_xmlCLOB CLOB;
	l_xml_input XMLTYPE;
	l_xml_output XMLTYPE;
	l_total_header_count NUMBER;
	l_failed_header_count NUMBER;

	l_return_status   VARCHAR2(1);
	l_msg_count       NUMBER := 0;
	l_msg_data        VARCHAR2(2000);

	--
	l_debug_on BOOLEAN;

	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_One_Header';
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
	x_return_status := FND_API.G_RET_STS_SUCCESS;


		l_source_line_tab_xml:= NEW WSH_OTM_RIQ_LINE_TAB();
		--Get a new line table for each header
		l_source_line_tab_xml.DELETE;

		Format_Line_Input_For_Xml(
			x_source_header_xml_rec=>x_source_header_rec_xml,
			p_source_header_rec=>x_source_header_rec,
			p_source_line_tab=>x_source_line_tab,
			p_source_type=>p_source_type,
			p_action=>p_action,
			x_source_line_tab=>l_source_line_tab_xml,
			x_return_status=>l_return_status);

		-- Bug 6175042: Updating x_source_header_rec and x_source_line_tab weights and volumes.
                x_source_header_rec.total_weight := x_source_header_rec_xml.totalweight;
                x_source_header_rec.total_volume := x_source_header_rec_xml.totalvolume;

		-- Bug 6810844: assigning the weight and volume of lines for the corresponding consolidation id.
		i:=x_source_line_tab.FIRST;
	        j:=i;
	        WHILE(i IS NOT NULL)
	        LOOP
                  IF ((x_source_line_tab(i).consolidation_id IS NOT NULL )
                       AND (x_source_header_rec.consolidation_id IS NOT NULL)
                       AND (x_source_line_tab(i).consolidation_id = x_source_header_rec.consolidation_id)) THEN

		     x_source_line_tab(i).weight := l_source_line_tab_xml(j).weight;
                     x_source_line_tab(i).volume := l_source_line_tab_xml(j).volume;
                     j:= j+1;

		  END IF;
		  i:=x_source_line_tab.NEXT(i);
                END LOOP;

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Format_Line_Input_For_Xml Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;

		END IF;


		--Create XML Input for 1 header and the lines associated with it
		Create_RIQ_XML(
			p_source_line_tab=>l_source_line_tab_xml,
			p_source_header_rec=>x_source_header_rec_xml,
			p_source_type=>p_source_type,
			p_action=>p_action,
			x_xml_input=>l_xml_input,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Create_RIQ_XML Failed');
			END IF;

			raise FND_API.G_EXC_ERROR;

		END IF;


		IF l_debug_on
		THEN

			print_CLOB(p_CLOB=>l_xml_input.getClobVal(),
				x_return_status=>l_return_status);

			IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
				 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
				IF l_debug_on
				THEN
					WSH_DEBUG_SV.log(l_module_name,'print_CLOB Failed');
				END IF;

				raise FND_API.G_EXC_ERROR;
			END IF;
		END IF;



		--Invoke the OTM Web Service get the response

		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Calling POST_REQUEST_TO_OTM');
		END IF;


		WSH_OTM_HTTP_UTL.POST_REQUEST_TO_OTM (
			p_request=>l_xml_input,
			x_response=>l_xmlCLOB,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'POST_REQUEST_TO_OTM Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;

		END IF;

		IF ((l_xmlCLOB IS  NULL) OR (DBMS_LOB.GETLENGTH(l_xmlCLOB) <= 0))
		THEN

			IF l_debug_on
			THEN

				WSH_DEBUG_SV.log(l_module_name,'Returned CLOB is invalid');
			END IF;
			raise FND_API.G_EXC_ERROR;

		END IF;


		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'After Calling POST_REQUEST_TO_OTM');
		END IF;


		IF l_debug_on
		THEN

			print_CLOB(p_CLOB=>l_xmlCLOB,
				x_return_status=>l_return_status);

			IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
				 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
				IF l_debug_on
				THEN
					WSH_DEBUG_SV.log(l_module_name,'print_CLOB Failed');
				END IF;

				raise FND_API.G_EXC_ERROR;
			END IF;
		END IF;

		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Before creating XMLType');
		END IF;


		l_xml_output:=NEW XMLTYPE(l_xmlCLOB);

		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'After creating XMLType');
		END IF;


		Parse_RIQ_Output_XML(
			p_xml_output=>l_xml_output,
			p_source_type=>p_source_type,
			p_action=>p_action,
			x_source_header_rec=>x_source_header_rec,
			x_source_line_tab=>x_source_line_tab,
			x_source_line_rates_tab=>x_source_line_rates_tab,
			x_source_header_rates_tab=>x_source_header_rates_tab,
			x_result_consolidation_id_tab=>x_result_consolidation_id_tab,
			x_result_carrier_id_tab=>x_result_carrier_id_tab,
			x_result_service_level_tab=>x_result_service_level_tab,
			x_result_mode_of_transport_tab=>x_result_mode_of_transport_tab,
			x_result_freight_term_tab=>x_result_freight_term_tab,
			x_result_transit_time_min_tab=>x_result_transit_time_min_tab,
			x_result_transit_time_max_tab=>x_result_transit_time_max_tab,
			x_ship_method_code_tab=>x_ship_method_code_tab,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'Parse_RIQ_Output_XML Failed');
			END IF;

			raise FND_API.G_EXC_ERROR;

		END IF;




		--Perform any freeing up of xmltype/CLOB resources


	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

	WHEN others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		wsh_util_core.default_handler('WSH_OTM_RIQ_XML.Process_One_Header',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
 END Process_One_Header;


PROCEDURE	CALL_OTM_FOR_OM(
	x_source_line_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_TAB,
	x_source_header_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_TAB,
	p_source_type			IN		VARCHAR2,
	p_action			IN		VARCHAR2,
	x_source_line_rates_tab		OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_RATES_TAB,
	x_source_header_rates_tab	OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_RATES_TAB,
	x_result_consolidation_id_tab  IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_carrier_id_tab        IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_service_level_tab     IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_mode_of_transport_tab IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_freight_term_tab      IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_transit_time_min_tab	IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_transit_time_max_tab	IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_ship_method_code_tab         IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2)
IS

	i NUMBER;
	l_source_header_tab_xml WSH_OTM_RIQ_HEADER_TAB;

	l_total_header_count NUMBER;
	l_failed_header_count NUMBER;

	l_return_status   VARCHAR2(1);
	l_msg_count       NUMBER := 0;
	l_msg_data        VARCHAR2(2000);

        --OTM R12 Org-Specific
        l_param_info       WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
        l_gc3_is_installed VARCHAR2(1);

	--
	l_debug_on BOOLEAN;

	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALL_OTM_FOR_OM';
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
	x_return_status := FND_API.G_RET_STS_SUCCESS;

        FND_MSG_PUB.initialize;

        --ECO 5516007 changes start, FP(5573379) to R12
        -- Ensure the Ship Date and Arrival Dates are populated appropriately
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling derive_riq_dates');
        END IF;

        derive_riq_dates
          (x_source_line_tab   => x_source_line_tab,
           x_source_header_tab => x_source_header_tab,
           x_return_status     => l_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after call to DERIVE_RIQ_DATES ', x_return_status );
        END IF;

        -- Handle Return Status for Error or Unexpected error.
        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                               WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          -- standard error raising, as used in this API
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        --ECO 5516007 changes end, FP to R12
        /*Bug7329859 storing x_source_line_tab in a global table to use in API Format_Header_Input_For_Xml*/
        g_source_line_tab_temp.DELETE;
        g_source_line_tab_temp := x_source_line_tab;

	IF (l_debug_on)
	THEN
		print_source_line_tab (
			p_source_line_tab=>x_source_line_tab,
			x_return_status=>l_return_status);
		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'print_source_line_tab Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;

		print_source_header_tab (
			p_source_header_tab=>x_source_header_tab,
			x_return_status=>l_return_status);
		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'print_source_header_tab Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;

	END IF;

	Init_Globals(
		x_return_status=>l_return_status);
	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'Init_Globals Failed');
		END IF;
		raise FND_API.G_EXC_ERROR;
	END IF;


	l_source_header_tab_xml:= NEW WSH_OTM_RIQ_HEADER_TAB();


	Format_Header_Input_For_Xml(
		p_source_header_tab=>x_source_header_tab,
		p_source_type=>p_source_type,
		p_action=>p_action,
		x_source_header_tab=>l_source_header_tab_xml,
		x_return_status=>l_return_status);

	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN

			WSH_DEBUG_SV.log(l_module_name,'Format_Header_Input_For_Xml Failed');
		END IF;

		raise FND_API.G_EXC_ERROR;
	END IF;

	l_failed_header_count:=0;
	l_total_header_count:=l_source_header_tab_xml.COUNT;
	i:=l_source_header_tab_xml.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
           --OTM R12 Org-Specific start . Added the check l_param_info.otm_enabled = 'Y and
           --the corresponding ELSE part.
           IF (nvl(l_param_info.organization_id,FND_API.G_MISS_NUM) <>
                 x_source_header_tab(i).ship_from_org_id) THEN --{
             WSH_SHIPPING_PARAMS_PVT.Get(
                  p_organization_id => x_source_header_tab(i).ship_from_org_id,
                  x_param_info      => l_param_info,
                  x_return_status   => l_return_status);

             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'After call to WSH_SHIPPING_PA'||
                            'RAMS_PVT.Get l_return_status ',l_return_status);
               WSH_DEBUG_SV.log(l_module_name,'Ship param not defined for org',
                                x_source_header_tab(i).ship_from_org_id);
             END IF;
             IF (l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                     WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
               RAISE FND_API.G_EXC_ERROR;
             END IF;
           END IF; --}
           --OTM R12 End

           IF l_param_info.otm_enabled = 'Y' THEN --{  --OTM R12 Org-Specific. Added the check
		Process_One_Header(
			x_source_line_tab=>x_source_line_tab,
			x_source_header_rec=>x_source_header_tab(i),
			x_source_header_rec_xml=>l_source_header_tab_xml(i),
			p_source_type=>p_source_type,
			p_action=>p_action,
			x_source_line_rates_tab=>x_source_line_rates_tab,
			x_source_header_rates_tab=>x_source_header_rates_tab,
			x_result_consolidation_id_tab=>x_result_consolidation_id_tab,
			x_result_carrier_id_tab=>x_result_carrier_id_tab,
			x_result_service_level_tab=>x_result_service_level_tab,
			x_result_mode_of_transport_tab=>x_result_mode_of_transport_tab,
			x_result_freight_term_tab=>x_result_freight_term_tab,
			x_result_transit_time_min_tab=>x_result_transit_time_min_tab,
			x_result_transit_time_max_tab=>x_result_transit_time_max_tab,
			x_ship_method_code_tab=>x_ship_method_code_tab,
			x_return_status=>l_return_status);

		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'Process_One_Header Failed');
			END IF;
			l_failed_header_count:=l_failed_header_count+1;
			--raise FND_API.G_EXC_ERROR;
		END IF;
           ELSE --OTM R12 Org-Specific. Added the else part.
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'OTM not enabled for organzation', x_source_header_tab(i).ship_from_org_id);
                END IF;
                l_failed_header_count:=l_failed_header_count+1;
           END IF; --}
           i:=l_source_header_tab_xml.NEXT(i);
	END LOOP;


	--Perform any post processing on the output

	Clear_Globals(
		x_return_status=>l_return_status);
	IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
		 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
		IF l_debug_on
		THEN
			WSH_DEBUG_SV.log(l_module_name,'Clear_Globals Failed');
		END IF;
		raise FND_API.G_EXC_ERROR;
	END IF;

	IF (l_debug_on)
	THEN


		print_source_line_tab (
			p_source_line_tab=>x_source_line_tab,
			x_return_status=>l_return_status);
		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'print_source_line_tab Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;

		print_source_header_tab (
			p_source_header_tab=>x_source_header_tab,
			x_return_status=>l_return_status);
		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'print_source_header_tab Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;


		print_rates_tab (
			p_source_line_rates_tab=>x_source_line_rates_tab,
			p_source_header_rates_tab=>x_source_header_rates_tab,
			x_return_status=>l_return_status);
		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'print_source_header_tab Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;

		print_CS_Results(
			p_result_consolidation_id_tab=>x_result_consolidation_id_tab,
			p_result_carrier_id_tab=>x_result_carrier_id_tab,
			p_result_service_level_tab=>x_result_service_level_tab,
			p_result_mode_of_transport_tab=>x_result_mode_of_transport_tab,
			p_result_freight_term_tab=>x_result_freight_term_tab,
			p_result_transit_time_min_tab=>x_result_transit_time_min_tab,
			p_result_transit_time_max_tab=>x_result_transit_time_max_tab,
			p_ship_method_code_tab=>x_ship_method_code_tab,
			x_return_status=>l_return_status);
		IF((l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND
			 (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
			IF l_debug_on
			THEN
				WSH_DEBUG_SV.log(l_module_name,'print_CS_Results Failed');
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;



	END IF;


	IF (l_failed_header_count = l_total_header_count)
	THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
		IF l_debug_on
		THEN
			FND_MESSAGE.SET_TOKEN('LOGFILE',WSH_DEBUG_SV.g_Dir||'/'||WSH_DEBUG_SV.g_File);
		ELSE
			FND_MESSAGE.SET_TOKEN('LOGFILE','');
		END IF;

		FND_MSG_PUB.ADD;
		IF (p_action IS NOT NULL AND p_action='C')
		THEN
			FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NO_CS_RESULT');
		ELSE
			FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_MUL_OMDEL_FL');
		END IF;

		FND_MSG_PUB.ADD;
	ELSIF (l_failed_header_count = 0)
	THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	ELSE    -- partial failure
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
		IF l_debug_on
		THEN
			FND_MESSAGE.SET_TOKEN('LOGFILE',WSH_DEBUG_SV.g_Dir||'/'||WSH_DEBUG_SV.g_File);
		ELSE
			FND_MESSAGE.SET_TOKEN('LOGFILE','');
		END IF;

		FND_MSG_PUB.ADD;
		IF (p_action IS NOT NULL AND p_action='C')
		THEN
			FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NO_CS_RESULT_W');
		ELSE
			FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_MUL_OMDEL_SUC_W');
		END IF;

		FND_MSG_PUB.ADD;

		IF l_debug_on
		THEN
		  WSH_DEBUG_SV.log(l_module_name, l_failed_header_count||' shipments out of '||l_total_header_count||' shipments failed.');
		END IF;
	END IF;




        FND_MSG_PUB.Count_And_Get
        (
	    p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
        );
	IF l_debug_on
	THEN
		WSH_DEBUG_SV.log(l_module_name,'x_msg_count',x_msg_count);
		WSH_DEBUG_SV.log(l_module_name,'x_msg_data',x_msg_data);
	END IF;


	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
		FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
		IF l_debug_on
		THEN
			FND_MESSAGE.SET_TOKEN('LOGFILE',WSH_DEBUG_SV.g_Dir||'/'||WSH_DEBUG_SV.g_File);
		ELSE
			FND_MESSAGE.SET_TOKEN('LOGFILE','');
		END IF;
		FND_MSG_PUB.ADD;
		IF (p_action IS NOT NULL AND p_action='C')
		THEN
			FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NO_CS_RESULT');
		ELSE
			FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_MUL_OMDEL_FL');
		END IF;
		FND_MSG_PUB.ADD;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		(
			p_count =>  x_msg_count,
			p_data  =>  x_msg_data,
			p_encoded => FND_API.G_FALSE
		);

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.log(l_module_name,'x_msg_count',x_msg_count);
			WSH_DEBUG_SV.log(l_module_name,'x_msg_data',x_msg_data);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
		END IF;

  WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
		IF l_debug_on
		THEN
			FND_MESSAGE.SET_TOKEN('LOGFILE',WSH_DEBUG_SV.g_Dir||'/'||WSH_DEBUG_SV.g_File);
		ELSE
			FND_MESSAGE.SET_TOKEN('LOGFILE','');
		END IF;
		FND_MSG_PUB.ADD;
		IF (p_action IS NOT NULL AND p_action='C')
		THEN
			FND_MESSAGE.SET_NAME('FTE', 'FTE_SEL_NO_CS_RESULT');
		ELSE
			FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RATE_MUL_OMDEL_FL');
		END IF;

		FND_MSG_PUB.ADD;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		(
			p_count =>  x_msg_count,
			p_data  =>  x_msg_data,
			p_encoded => FND_API.G_FALSE
		);
		--wsh_util_core.default_handler('WSH_OTM_RIQ_XML.CALL_OTM_FOR_OM',l_module_name);
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'x_msg_count',x_msg_count);
		WSH_DEBUG_SV.log(l_module_name,'x_msg_data',x_msg_data);

		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END CALL_OTM_FOR_OM;


END WSH_OTM_RIQ_XML;

/
