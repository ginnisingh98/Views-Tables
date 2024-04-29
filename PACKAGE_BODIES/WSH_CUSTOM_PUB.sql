--------------------------------------------------------
--  DDL for Package Body WSH_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CUSTOM_PUB" as
/* $Header: WSHCSPBB.pls 120.2.12010000.5 2010/02/25 15:53:05 sankarun ship $ */
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_CUSTOM_PUB';
--
--  Procedure:		Delivery_Name
--  Parameters:		All Attributes of a Delivery Record
--  Description:	This procedure will create a delivery. It will
--			return to the use the delivery_id and name (if
--			not provided as a parameter.
--

  FUNCTION Delivery_Name
		(
		 p_delivery_id		IN	NUMBER,
		 p_delivery_info	IN	WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type
		) RETURN VARCHAR2 IS

  BEGIN

    RETURN (to_char(p_delivery_id));

  END Delivery_Name;

  FUNCTION Trip_Name
		(
		 p_trip_id  IN NUMBER,
		 p_trip_info IN wsh_trips_pvt.trip_rec_type
		)  RETURN VARCHAR2 IS
  BEGIN
	RETURN (to_char(p_trip_id));
  END Trip_Name;

--
--  Function:           Run_PR_SMC_SS_Parallel
--  Description:        This function is designed for the user to
--                      customize the running of Pick Release for Ship Sets and SMCs
--                      in parallel with Regular Items.
--                      If this is set to 'Y', then Ship Sets/SMCs are not given a
--                      priority over Regular Items. This can lead to scenarios where
--                      Ship Sets/SMCs are backordered while Regular Items are picked.
--                      Oracle Default: Ship Sets/SMCs are not run in Parallel
--                      Function Default: 'N'
--

FUNCTION Run_PR_SMC_SS_Parallel RETURN VARCHAR2
IS

BEGIN
    	  RETURN 'N';
END Run_PR_SMC_SS_Parallel;


--
--  Function:           Credit_Check_Details_Option
--  Description:        This function is designed for the user to
--                      customize credit checking for details.
--                      By default, credit check will be done for all details ('A')
--                      If the credit check is to be run only for Non-Backordered details,
--                      then this is set to 'R'.
--                      If the credit check is to be run only for Backordered details,
--                      then this is set to 'B'.
--                      Oracle Default: Credit check for all details.
--                      Function Default: 'A'
--

FUNCTION Credit_Check_Details_Option RETURN VARCHAR2
IS

BEGIN
    	  RETURN 'A';
END Credit_Check_Details_Option;

--Added as a part of bugfix 4995478
--  Procedure:  	ui_location_code
--  Parameters:

   -- 1. p_location_type 'HR' stands for internal location
   --    p_location_type 'HZ' Stands for external location
   -- 2. p_party_site_numberTbl corresponds to party_site_number in HZ tables (External location)
   -- 3. p_location_codeTbl corresponds to Location_code in HR tables (Internal location)
   -- 4. p_address_1Tbl/2Tbl corresponds to address1/2 in HZ table and address_line_1/2 in HR table.
   -- 5. p_cityTbl corresponds to city in HZ table and town_or_city in HR table.
   -- 6. p_stateTbl corresponds to state in HZ table  region_2 in HR table
   -- 7. p_provinceTbl corresponds to province in HZ table and region3 in HR table
   -- 8. p_countyTbl corresponds to region1 in HR table
   -- 9. p_postal_codeTbl and p_countryTbl corresponds to postal_code and country in HZ/HR table
   --10. For p_location_type 'HR', p_party_site_numberTbl  will be passed as NULL and
     --  for p_location_type 'HZ', p_location_codeTbl will be passed as NULL.

 -- Description :
 -- 1) The procedure is designed for the user to customize the location (ui_location_code) information
 --- displayed in Shipping Forms.
 -- 2) All required parameter are passed for external and internal location.
 -- 3)To use this procedure user has to set the value of PL/SQL variable
 -- x_use_custom_ui_location to 'Y'.
 -- 4) The function must not return more than 500 characters(or 500 bytes in multi-byte character set).
 -- Please use substrb function to limit the total length and/or each individual component length..
 --5) For custom changes to take affect,user has to run 'Import Shipping Location' Concurrent Program.

PROCEDURE ui_location_code (
                p_location_type           IN  VARCHAR2,
		p_location_idTbl          IN  WSH_LOCATIONS_PKG.ID_Tbl_Type,
    	        p_address_1Tbl            IN  WSH_LOCATIONS_PKG.Address_Tbl_Type,
                p_address_2Tbl            IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
		p_countryTbl              IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
		p_stateTbl                IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
                p_provinceTbl             IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
                p_countyTbl               IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
               	p_cityTbl                 IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
                p_postal_codeTbl          IN  WSH_LOCATIONS_PKG.Address_Tbl_Type ,
		p_party_site_numberTbl    IN  WSH_LOCATIONS_PKG.LocationCode_Tbl_Type,
                p_location_codeTbl        IN  WSH_LOCATIONS_PKG.LocationCode_Tbl_Type,
                x_use_custom_ui_location  OUT NOCOPY VARCHAR2,
	        x_custom_ui_loc_codeTbl   OUT NOCOPY WSH_LOCATIONS_PKG.LocationCode_Tbl_Type
                    ) IS
     l_sqlcode   NUMBER;
     l_sqlerr    VARCHAR2(2000);
BEGIN

 x_use_custom_ui_location := 'N';
 ---Sample code start--
/*
IF p_location_type = 'HZ' THEN

  FOR i IN p_location_idTbl.FIRST..p_location_idTbl.LAST
    LOOP
     x_custom_ui_loc_codeTbl(i) := substrb((p_party_site_numberTbl(i)||' : '||p_address_1Tbl(i)||'-'||p_address_2Tbl(i)||'-'||p_cityTbl(i)||'-'||nvl(p_stateTbl(i),p_provinceTbl(i))||'-'|| p_postal_codeTbl(i)||'-'||p_countryTbl(i)),1,500);
    END LOOP;
ELSIF p_location_type = 'HR' THEN

 FOR i IN p_location_idTbl.FIRST..p_location_idTbl.LAST
  LOOP
   x_custom_ui_loc_codeTbl(i) := substrb((p_location_codeTbl(i)||' : '||p_address_1Tbl(i)||'-'||p_address_2Tbl(i)||'-'||p_cityTbl(i)||'-'||p_stateTbl(i)||'-'|| p_postal_codeTbl(i)||'-'||p_countryTbl(i)),1,500);
  END LOOP;
END IF;

EXCEPTION
WHEN others THEN
     l_sqlcode := SQLCODE;
     l_sqlerr  := SQLERRM;
     WSH_UTIL_CORE.printmsg('In the Others Exception of WSH_CUSTOM_PUB.ui_location_code');
     WSH_UTIL_CORE.printmsg(l_sqlcode);
     WSH_UTIL_CORE.printmsg(l_sqlerr);
 ---Sample code end --
 */
END ui_location_code;



-- CUSTOMIZE THE PROCEDURE
PROCEDURE Shipped_Lines(
           p_source_header_id in number,
           p_source_code      in varchar2,
           p_contact_type     in varchar2,
           p_contact_id       in number,
           p_last_notif_date  in date,
           p_shipped          out NOCOPY  boolean,
           p_shipped_lines    out NOCOPY  varchar2) IS

CURSOR c_shipped_lines(
	   p_source_header_id in number,
	   p_source_code      in varchar2,
	   p_contact_type     in varchar2,
	   p_contact_id       in number,
	   p_last_notif_date  in date) is
SELECT
msi.segment1,
msi.description,
lpad(to_char(wnd.initial_pickup_date,'MM/DD/YYYY'),12),
wnd.waybill,
sum(nvl(wdd.shipped_quantity,0))
FROM
wsh_delivery_details wdd,
wsh_delivery_assignments wda,
wsh_new_deliveries wnd,
mtl_system_items msi
WHERE wdd.delivery_detail_id = wda.delivery_detail_id
AND   wda.delivery_id = wnd.delivery_id
AND   wnd.status_code in ('IT','CL')
AND   wnd.initial_pickup_date > p_last_notif_date
AND   wdd.inventory_item_id = msi.inventory_item_id
AND   wdd.organization_id = msi.organization_id
AND   wdd.source_header_id = p_source_header_id
AND   wdd.source_code = p_source_code
AND   nvl(wnd.shipment_direction, 'O') IN ('O','IO')  --J Inbound Logistics jckwok
AND   decode(p_contact_type,
	   'SHIP_TO',wdd.ship_to_contact_id,
	   'SOLD_TO',wdd.sold_to_contact_id,
	   wdd.customer_id) = p_contact_id
GROUP BY
wdd.source_header_number,
wdd.source_header_type_id,
wdd.source_line_id,
wdd.inventory_item_id,
msi.segment1,
msi.description,
wdd.src_requested_quantity,
wnd.initial_pickup_date,
wnd.waybill
HAVING
sum(nvl(wdd.shipped_quantity,0)) > 0;

l_shipped boolean;
l_shipped_lines varchar2(32750);
l_part_number varchar2(40);
l_part_desc   varchar2(240);
l_ship_qty number;
l_ship_date varchar2(12);
l_waybill varchar2(30);

BEGIN


--                                           123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	l_shipped_lines :=                   '                                                      Quantites';
     l_shipped_lines := l_shipped_lines|| fnd_global.newline;
	l_shipped_lines := l_shipped_lines|| 'Part Number         Part Description                  Ship      Date Shipped Waybill     ';
	l_shipped_lines := l_shipped_lines|| fnd_global.newline;
	l_shipped_lines := l_shipped_lines|| '------------------- --------------------------------- --------- ------------ ------------';

     l_shipped := FALSE;
	open c_shipped_lines(p_source_header_id, p_source_code, p_contact_type, p_contact_id, p_last_notif_date);
	LOOP
	  fetch c_shipped_lines
	  into  l_part_number,
             l_part_desc,
             l_ship_date,
             l_waybill,
             l_ship_qty;
       exit when c_shipped_lines%NOTFOUND;
	  l_shipped := TRUE;

	  l_shipped_lines := l_shipped_lines|| fnd_global.newline;
	  l_shipped_lines := l_shipped_lines
					 || rpad(substr(l_part_number,1,19)     ,19) ||' '
					 || rpad(substr(l_part_desc,1,33)       ,33) ||' '
					 || lpad(substr(to_char(l_ship_qty),1,9),9)  ||' '
					 || rpad(substr(l_ship_date,1,12)       ,12) ||' '
					 || rpad(substr(l_waybill,1,12)         ,12);
     END LOOP;
	close c_shipped_lines;

	p_shipped := l_shipped;
	if (l_shipped) then
	  p_shipped_lines := l_shipped_lines;
	else
	  p_shipped_lines := NULL;
	end if;

	return;
END Shipped_Lines;

-- CUSTOMIZE THE PROCEDURE
PROCEDURE Backordered_Lines(
           p_source_header_id in number,
           p_source_code      in varchar2,
           p_contact_type     in varchar2,
           p_contact_id       in number,
           p_last_notif_date  in date,
           p_backordered      out NOCOPY  boolean,
           p_backordered_lines    out NOCOPY  varchar2) IS
CURSOR c_backordered_lines(
	   p_source_header_id in number,
	   p_source_code      in varchar2,
	   p_contact_type     in varchar2,
	   p_contact_id       in number,
	   p_last_notif_date  in date) is
SELECT
msi.segment1,
msi.description,
sum(nvl(wdd.requested_quantity,0))
FROM
wsh_delivery_details wdd,
wsh_delivery_assignments wda,
wsh_new_deliveries wnd,
mtl_system_items msi
WHERE wdd.delivery_detail_id = wda.delivery_detail_id
AND   wdd.date_scheduled < sysdate
--AND   wdd.date_scheduled > p_last_notif_date
--AND   wdd.released_status != 'C'
AND   wda.delivery_id = wnd.delivery_id (+)
AND   nvl(wnd.status_code,'XX') not in ('IT','CL')
AND   wdd.inventory_item_id = msi.inventory_item_id
AND   wdd.organization_id = msi.organization_id
AND   wdd.source_header_id = p_source_header_id
AND   wdd.source_code = p_source_code
AND   nvl(wdd.line_direction, 'O') IN ('O','IO')  --J Inbound Logistics jckwok
AND   decode(p_contact_type,
	   'SHIP_TO',wdd.ship_to_contact_id,
	   'SOLD_TO',wdd.sold_to_contact_id,
	   wdd.customer_id) = p_contact_id
GROUP BY
wdd.source_header_number,
wdd.source_header_type_id,
wdd.source_line_id,
wdd.inventory_item_id,
msi.segment1,
msi.description,
wdd.src_requested_quantity
HAVING
sum(nvl(wdd.requested_quantity,0)) > 0;

l_backordered boolean;
l_backordered_lines varchar2(32750);
l_part_number varchar2(40);
l_part_desc   varchar2(240);
l_backorder_qty number;

BEGIN
--                                                 12345678901234567890123456789012345678901234567890123456789012345678901234567890
	l_backordered_lines :=                       '                                                      Quantity';
	l_backordered_lines := l_backordered_lines|| fnd_global.newline;
	l_backordered_lines := l_backordered_lines|| 'Part Number         Part Description                  Backordered';
	l_backordered_lines := l_backordered_lines|| fnd_global.newline;
	l_backordered_lines := l_backordered_lines|| '------------------- --------------------------------- -----------';

	l_backordered := FALSE;
	open c_backordered_lines(p_source_header_id, p_source_code, p_contact_type, p_contact_id, p_last_notif_date);
	LOOP
	  fetch c_backordered_lines
	  into  l_part_number,
	        l_part_desc,
	        l_backorder_qty;
	  exit when c_backordered_lines%NOTFOUND;
	  l_backordered := TRUE;

	  l_backordered_lines := l_backordered_lines|| fnd_global.newline;
	  l_backordered_lines := l_backordered_lines
						|| rpad(substr(l_part_number,1,19)          ,19) ||' '
						|| rpad(substr(l_part_desc,1,33)            ,33) ||' '
						|| lpad(substr(to_char(l_backorder_qty),1,11),11);
	END LOOP;
	close c_backordered_lines;

	p_backordered := l_backordered;
	if (l_backordered) then
	  p_backordered_lines := l_backordered_lines ;
	else
	  p_backordered_lines := NULL;
	end if;

END Backordered_Lines ;

-- CUSTOMIZE THIS PROCEDURE
PROCEDURE Start_Workflow(
           p_source_header_id in  number,
		 p_source_code      in  varchar2,
		 p_contact_type     in  varchar2,
		 p_contact_id       in  number,
		 p_result           out NOCOPY  boolean) IS
BEGIN
	p_result := FALSE;
END Start_Workflow;

--PROCEDURE calculate_tp_dates
--Based on different parameters from OM, customers can customize their
--calculation of the TP dates (Earliest/Latest Ship Dates and Earliest/Latest Delivery Dates).
--These will be then used for population at the delivery detail level and will
--get propogated upto container or delivery levels at action points such as
--assign/pack etc.
--NOTE : x_modified out parameter must be returned as 'Y' in order to use this
--customized calculation

PROCEDURE calculate_tp_dates(
              p_source_line_id NUMBER,
              p_source_code IN     VARCHAR2,
              x_earliest_pickup_date OUT NOCOPY DATE,
              x_latest_pickup_date OUT NOCOPY DATE,
              x_earliest_dropoff_date OUT NOCOPY DATE,
              x_latest_dropoff_date OUT NOCOPY DATE,
              x_modified            OUT NOCOPY VARCHAR2
              ) IS

l_earliest_pickup_date  DATE;
l_latest_pickup_date    DATE;
l_earliest_dropoff_date DATE;
l_latest_dropoff_date   DATE;

BEGIN
    --x_modified must be changed to 'Y' if you're customizing this procedure
    --to calculate dates on your own
    x_modified:='N';
    x_earliest_pickup_date :=l_earliest_pickup_date;
    x_latest_pickup_date   :=l_latest_pickup_date;
    x_earliest_dropoff_date:=l_earliest_dropoff_date;
    x_latest_dropoff_date  :=l_latest_dropoff_date;

END calculate_tp_dates;

-- Procedure Override_RIQ_XML_Attributes
-- Provides a way to override the attributes: Weight, Volume, Item Dimensions: Length, Width and Height
-- for any of the following RIQ actions:
-- 1) Choose Ship Method
-- 2) Get Ship Method
-- 3) Get Ship Method and Rates
-- 4) Get Freight Rates
-- All the attributes values should be Non-Negative.
-- For the Header Level (Consolidation), p_line_id_tab will have more than 1
-- record containing all the order line_ids that have been consolidated at the header level
-- The only attributes that can be overridden at the Header Level are Weight and Volume.
-- For the Line Level/Ship Unit Level, p_line_id_tab will have only 1 record
-- with the order line_id and all the attributes can be overridden.
-- For Item Dimensions values to be sent as part of RIQ XML, the OTM Item Dimension UOM must be defined
-- and the Item Dimensions (Length, Width and Height) should all have valid values.
PROCEDURE Override_RIQ_XML_Attributes(
              p_line_id_tab IN WSH_UTIL_CORE.Id_Tab_Type,
              x_weight      IN OUT NOCOPY NUMBER,
              x_volume      IN OUT NOCOPY NUMBER,
              x_length      IN OUT NOCOPY NUMBER,
              x_height      IN OUT NOCOPY NUMBER,
              x_width       IN OUT NOCOPY NUMBER,
              x_return_status OUT NOCOPY VARCHAR2
              ) IS

BEGIN

   -- Initializing API return status to Success, please do not change this
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- p_line_tab contains the Order Line_id(s) from oe_order_lines_all table
   -- This can be used to derive the corresponding line level information

   /* Sample Code : Please ensure that values are passed correctly back to caller
   -- Header Level (p_line_id_tab contains all the order line_ids that are consolidated)
   IF p_line_id_tab.COUNT > 1 THEN
       x_weight :=
       x_volume :=

   -- Line Level for a specific order line_id
   ELSIF p_line_id_tab.COUNT = 1 THEN
       x_weight :=
       x_volume :=
       x_length :=
       x_height :=
       x_width  :=

   END IF;
   */

EXCEPTION
  WHEN others THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
END Override_RIQ_XML_Attributes;

-- Bug 7131800
FUNCTION Cancel_Unpicked_Details_At_ITS(
                  p_source_header_id    IN  NUMBER,
                  p_source_line_id      IN  NUMBER,
                  p_source_line_set_id  IN  NUMBER,
                  p_remain_details_id   IN WSH_UTIL_CORE.Id_Tab_Type
               ) RETURN VARCHAR2 IS
l_debug_on BOOLEAN;
l_cancel_flag  VARCHAR2(1):= 'Y';  -- default Value is to Cancel (old Behaviour)
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' ||G_PKG_NAME || '.' ||'Cancel_Unpicked_Details_At_ITS';
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
        WSH_DEBUG_SV.log(l_module_name,'p_source_line_id ', p_source_line_id);
        WSH_DEBUG_SV.log(l_module_name,'p_source_line_set_id ', p_source_line_set_id);
        WSH_DEBUG_SV.log(l_module_name,'p_source_header_id ', p_source_header_id);
    END IF;
    --
    --  { Section to be Modified by Customers

         l_cancel_flag := 'Y';

    --  } End Section to be Modified by Customers

---
IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'l_cancel_flag ', l_cancel_flag);
   WSH_DEBUG_SV.pop(l_module_name);
END IF;

RETURN (l_cancel_flag);

END Cancel_Unpicked_Details_At_ITS;

-- Standalone Project - Start
-- This Procedure is the Custom Hook provided to Customers to return default values.
-- Purpose :    Customer should set default values for Order Type, Price List,
--              Payment Term and Currency Code.
-- Parameters:  x_order_type_id   -  Order Type
--           :  x_price_list_id   -  Price List
--           :  x_payment_term_id -  Payment Term
--           :  x_currency_code   -  Currency Code
PROCEDURE Get_Standalone_WMS_Defaults (
              p_transaction_id   IN         NUMBER,
              x_order_type_id    OUT NOCOPY NUMBER,
              x_price_list_id    OUT NOCOPY NUMBER,
              x_payment_term_id  OUT NOCOPY NUMBER,
              x_currency_code    OUT NOCOPY VARCHAR2 )
IS
   l_order_type_id    NUMBER;
   l_price_list_id    NUMBER;
   l_payment_term_id  NUMBER;
   l_currency_code    VARCHAR2(15);

   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' ||G_PKG_NAME || '.' ||'Get_Standalone_WMS_Defaults';
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
       WSH_DEBUG_SV.log(l_module_name, 'p_transaction_id', p_transaction_id);
   END IF;
   --

   --  { Section to be Modified by Customers

        l_order_type_id   := null;
        l_price_list_id   := null;
        l_payment_term_id := null;
        l_currency_code   := null;

   --  } End Section to be Modified by Customers

   x_order_type_id   := l_order_type_id;
   x_price_list_id   := l_price_list_id;
   x_payment_term_id := l_payment_term_id;
   x_currency_code   := l_currency_code;

   ---
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_order_type_id ', l_order_type_id);
      WSH_DEBUG_SV.log(l_module_name,'l_price_list_id ', l_price_list_id);
      WSH_DEBUG_SV.log(l_module_name,'l_payment_term_id ', l_payment_term_id);
      WSH_DEBUG_SV.log(l_module_name,'l_currency_code ', l_currency_code);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
END Get_Standalone_WMS_Defaults;

-- This Procedure is the Custom Hook provided to Customers to handle post process
-- of Shipment Request processing.
-- If there are any errors then this custom API should rollback to savepoint
-- Post_Process_Shipment_Request.
-- API should not issue ROLLBACK without Savepoint Post_Process_Shipment_Request.
PROCEDURE Post_Process_Shipment_Request (
              p_transaction_id  IN         NUMBER,
              x_return_status   OUT NOCOPY VARCHAR2 )
IS
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' ||G_PKG_NAME || '.' ||'Post_Process_Shipment_Request';
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
       WSH_DEBUG_SV.log(l_module_name, 'p_transaction_id', p_transaction_id);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   SAVEPOINT Post_Process_Shipment_Request;

   --  { Section to be Modified by Customers

   --  } End Section to be Modified by Customers

   ---
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO Post_Process_Shipment_Request;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Post_Process_Shipment_Request;

-- Standalone Project - End

-- 8424489
-- Function Name: Dsno_Output_File_Prefix
-- Purpose :
--       This function is the custom hook provided for customers to customize
--       DSNO output file name. Value returned from this custom function will
--       be used as prefix for DSNO output file name to be generated
--
--       DEFAULT RETURN VALUE IS => DSNO
--
-- Parameters:
--       p_trip_stop_id   - Trip Stop Id for which ITS/Outbound Trigerring process is being submitted
--       p_doc_number     - Document Number suffixed to DSNO output file name
--       p_dsno_file_ext  - File Extension for DSNO output file to be generated
--                          Parameter value will be NULL, if Profile 'WSH: DSNO Output File Extension'
--                          (WSH_DSNO_OUTPUT_FILE_EXT) is NOT set.
-- Return:
--       If value returned is NULL then DSNO will be prefixed for DSNO Output Filename
--       Return value should be VARCHAR2. While customizing customer should take care that length of
--       "return value || p_doc_number || '.' || p_dsno_file_ext" is NOT greater than 30 Characters.
--       Example:
--           Return Value    => CUSTOM_FILE_NAME
--           p_doc_number    => 123456789
--           p_dsno_file_ext => txt
--           DSNO Output File Name => CUSTOM_FILE_NAME123456789.txt
--           length(CUSTOM_FILE_NAME123456789.txt) should not be greater than 30 Characters.
--
FUNCTION Dsno_Output_File_Prefix(
              p_trip_stop_id        IN  NUMBER,
              p_doc_number          IN  NUMBER,
              p_dsno_file_ext       IN  VARCHAR2 ) RETURN VARCHAR2
IS
   l_dsno_file_prefix VARCHAR2(30);

   --
   l_debug_on       BOOLEAN;
   l_module_name    CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Dsno_Output_File_Prefix';
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
      WSH_DEBUG_SV.log(l_module_name,'p_trip_stop_id', p_trip_stop_id);
      WSH_DEBUG_SV.log(l_module_name,'p_doc_number', p_doc_number);
      WSH_DEBUG_SV.log(l_module_name,'p_dsno_file_ext', p_dsno_file_ext);
   END IF;
   --

   --  { Section to be Modified by Customers

        l_dsno_file_prefix := 'DSNO';

   --  } End Section to be Modified by Customers

   -- Make sure that
   -- length( l_dsno_file_prefix || to_char(p_doc_number) || '.' || p_dsno_file_ext ) <= 30;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_dsno_file_prefix', l_dsno_file_prefix);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --

   RETURN l_dsno_file_prefix;
EXCEPTION
   WHEN OTHERS THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Inside Exception', sqlerrm);
         WSH_DEBUG_SV.log(l_module_name,'l_dsno_file_prefix', l_dsno_file_prefix);
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN l_dsno_file_prefix;
END Dsno_Output_File_Prefix;


 -- TPW - Distributed Organization Changes - Start
 -- Procedure Name: Shipment_Batch_Group_Criteria
 -- Purpose :
 --       This procedure is the custom hook provided for customers to customize
 --       grouping criteria for Shipment Batches to be generated.
 --
 --       Possible return values for all parameter is either 'Y' or 'N'
 --         1) If NULL value is returned then it will be treated as 'Y'
 --         2) If value returned is other than Y/N then it will be treated as 'N'
 --
 --       By Default value for all Grouping criteria is set to 'Y'.
 --
 -- Parameters:
 --       x_grp_by_invoice_to_site      -  Group By Invoice To Site
 --       x_grp_by_deliver_to_site      -  Group By Deliver To Site
 --       x_grp_by_ship_to_contact      -  Group By Ship To Contact
 --       x_grp_by_invoice_to_contact   -  Group By Invoice To Contact
 --       x_grp_by_deliver_to_contact   -  Group By Deliver To Contact
 --       x_grp_by_ship_method          -  Group By Ship Method Code
 --       x_grp_by_freight_terms        -  Group By Freight Terms
 --       x_grp_by_fob_code             -  Group By FOB Code
 --       x_grp_by_within_order         -  Group Lines Within(Y)/Across(N) Sales Order
 --
 PROCEDURE Shipment_Batch_Group_Criteria(
               x_grp_by_invoice_to_site     OUT NOCOPY VARCHAR2,
               x_grp_by_deliver_to_site     OUT NOCOPY VARCHAR2,
               x_grp_by_ship_to_contact     OUT NOCOPY VARCHAR2,
               x_grp_by_invoice_to_contact  OUT NOCOPY VARCHAR2,
               x_grp_by_deliver_to_contact  OUT NOCOPY VARCHAR2,
               x_grp_by_ship_method         OUT NOCOPY VARCHAR2,
               x_grp_by_freight_terms       OUT NOCOPY VARCHAR2,
               x_grp_by_fob_code            OUT NOCOPY VARCHAR2,
               x_grp_by_within_order        OUT NOCOPY VARCHAR2 )
 IS
    l_grp_by_invoice_to_site     VARCHAR2(1);
    l_grp_by_deliver_to_site     VARCHAR2(1);
    l_grp_by_ship_to_contact     VARCHAR2(1);
    l_grp_by_invoice_to_contact  VARCHAR2(1);
    l_grp_by_deliver_to_contact  VARCHAR2(1);
    l_grp_by_ship_method         VARCHAR2(1);
    l_grp_by_freight_terms       VARCHAR2(1);
    l_grp_by_fob_code            VARCHAR2(1);
    l_grp_by_within_order        VARCHAR2(1);
    --
    l_debug_on       BOOLEAN;
    l_module_name    CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Shipment_Batch_Group_Criteria';
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
    END IF;
    --

    --  { Section to be Modified by Customers

         l_grp_by_invoice_to_site     := 'Y';
         l_grp_by_deliver_to_site     := 'Y';
         l_grp_by_ship_to_contact     := 'Y';
         l_grp_by_invoice_to_contact  := 'Y';
         l_grp_by_deliver_to_contact  := 'Y';
         l_grp_by_ship_method         := 'Y';
         l_grp_by_freight_terms       := 'Y';
         l_grp_by_fob_code            := 'Y';
         l_grp_by_within_order        := 'Y';

    --  } End Section to be Modified by Customers

    x_grp_by_invoice_to_site     := l_grp_by_invoice_to_site;
    x_grp_by_deliver_to_site     := l_grp_by_deliver_to_site;
    x_grp_by_ship_to_contact     := l_grp_by_ship_to_contact;
    x_grp_by_invoice_to_contact  := l_grp_by_invoice_to_contact;
    x_grp_by_deliver_to_contact  := l_grp_by_deliver_to_contact;
    x_grp_by_ship_method         := l_grp_by_ship_method;
    x_grp_by_freight_terms       := l_grp_by_freight_terms;
    x_grp_by_fob_code            := l_grp_by_fob_code;
    x_grp_by_within_order        := l_grp_by_within_order;

    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
 EXCEPTION
    WHEN OTHERS THEN
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Inside Exception', sqlerrm);
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
 END Shipment_Batch_Group_Criteria;

 -- TPW - Distributed Organization Changes - End

END WSH_CUSTOM_PUB;

/
