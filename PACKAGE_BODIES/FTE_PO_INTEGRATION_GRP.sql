--------------------------------------------------------
--  DDL for Package Body FTE_PO_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_PO_INTEGRATION_GRP" AS
/* $Header: FTEGPOIB.pls 120.7 2006/05/31 19:11:17 schennal noship $ */
/*
-- Global constants
-- +======================================================================+
--   Procedure :
--         FTE-PO Integration Package
--         GET_ESTIMATED_RATES uses to get the estimated rates based on the given shipment header id
--         This API will not call any Rating or Re-rating API internally
--         It will get only pre-rated information from wsh_freight_cost table
--         and pro-rate the container rates whereever it is necessary
--   Description:
--    Getting the rates are divided into 3 sections.
--     1. Find all deliveries are not rated or partially rated or re-rate required.
--        All corresponding receipt lines will have the rate zero since they are not valid or no rates
--     2. Non-matched receipts w/ Delivery
--        we need to sum up the rates against all po lines of the
--        shipment header and pro-rated to all receipt lines
--        based on the qty at receipt
--        step-1. Find the shipment header has a match delivery or not
--        step-2. if there is a match, go to main-step-3 for matching receipt rates
--        step-3  if there is a mismatch, find all corresponding po lines for the given shipment header id
--                from wdd/rcv and get the rates from wfc tables
--            (by calling  get_rcv_shipment_lines API)
--     3. Matched Receipts w/ Delivery (it means you can have a receipt line id
--        at WDD level and Shipment header id at WND
--        --Get the detail rates for TL, LTL, Parcel, etc..  for  non packed items
--        --Get all contaner rates for TL, LTL, and Parcel, etc  for packed items.
--             for LTL, the rates are  stored at detail level, no need of pro-rating
--             for Non-LTL, the rates needs to be pro-rated based on the qty
--   Inputs:
--     rate input parameters ( self explained )
--   Output:
--       Table of Receipt Lines w/ cost, currency,vendor id, vendor site id,return status and message text
--       Status, and messages data
--   Return Status within the Table as follows:-
--       Value of RETURN_STATUS can be S- Success, W- Warning, Error, and U- Unhandled Exception.
--       Value of MESSAGE_TEXT will be a translated message as follows:
--       1.	Rate is available (if RETURN_STATUS is S)
--       2.	Rate is not available (if RETURN_STATUS is W)
--       3.	Currency conversion failed (if RETURN_STATUS is E)
--       4.	Standard Oracle Error / Program Error (if RETURN_STATUS is U)
--Note: Rate are not available could be due to the following reason
--       1.	One of the Delivery leg is not rated
--      2.	Rates on one of the Delivery Leg is Dirty (REQUIRED_REPRICE FLAG is set to Y)
-- Proration logic of the distribution of container level cost to the container contents
--For ex: Total Cost at Container Level is $100.00 (Net Wt - 100 LBS)
-- ITEM NAME	NET WT	 RATE DISTRIBUTED
-- ITEM-A	50 LBS	(50/105 * 100) = $47.62
-- ITEM-B	30 LBS	(30/105 * 100) = $28.57
-- ITEM-C	25 LBS	(25/105 * 100) = $23.81
-- Item Total	105 LBS	$100.00

-- +======================================================================+
*/
/* TBD list
--Compare with Shipped qty rather than total receipt qty in case of non-matching case.
--Input can be receipt line id rather than receipt header id
--Output needs to make to the PO_RCV_CHARGES table structure for the future support.

*/
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_PO_INTEGRATION_GRP';
/* This API will be called only if the shipment does not match with receipts
   and WDD does not contain rcv_shipment_line_id
This procedure will be used to get all receipt shipment lines and recd qty
 for the given shipment header id, po line id, po line location id
 Prorate the cost at po line location level to each receipt lines based on the qty
*/

PROCEDURE get_rcv_shipment_lines ( x_return_status           OUT NOCOPY VARCHAR2,
                               P_SHIPMENT_HEADER_ID      IN  VARCHAR2,
                               P_PO_LINE_ID              IN  NUMBER,
                               P_PO_LINE_LOCATION_ID     IN  NUMBER,
                               P_TOTAL_COST              IN  NUMBER,
                               P_SHIP_QTY_UOM            IN  VARCHAR2,
                               P_SHIP_QTY                IN  NUMBER,
                               X_RCV_SHIP_LINES_TABLE    OUT NOCOPY FTE_PO_INTEGRATION_GRP.fte_number_table,
                               X_RCV_SHIP_COST_TABLE     OUT NOCOPY FTE_PO_INTEGRATION_GRP.fte_number_table);
--
l_receipt_lines_rec FTE_PO_INTEGRATION_GRP.FTE_RECEIPT_LINE_REC;
l_receipt_lines_tab FTE_PO_INTEGRATION_GRP.FTE_RECEIPT_LINES_TAB;

l_debug_on BOOLEAN;
l_debugfile     varchar2(2000);

PROCEDURE GET_ESTIMATED_RATES(
      p_init_msg_list           IN  VARCHAR2,
      p_api_version_number      IN  NUMBER,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      x_return_status           OUT NOCOPY VARCHAR2,
      p_shipment_header_id      IN  NUMBER,
      x_receipt_lines_tab      OUT NOCOPY FTE_PO_INTEGRATION_GRP.FTE_RECEIPT_LINES_TAB)
IS

/* find all deliveries for matching or non-matching shipments*/
cursor  c_get_deliveries(l_shipment_header_id number) IS
select wnd.delivery_id,'Y' RATE_AVAILABLE_FLAG, 'Y' MATCHING_FLAG
           FROM  WSH_NEW_DELIVERIES WND
          WHERE  WND.RCV_SHIPMENT_HEADER_ID = l_shipment_header_id
            AND  WND.RCV_SHIPMENT_HEADER_ID is not null
union
select distinct wda.DELIVERY_ID, 'Y' RATE_AVAILABLE_FLAG,'N' MATCHING_FLAG
       from WSH_DELIVERY_ASSIGNMENTS_V wda,
            wsh_delivery_details wdd,
            rcv_shipment_lines rsl
 where wda.delivery_detail_id=wdd.delivery_detail_id
   and wdd.rcv_shipment_line_id is null
   and rsl.shipment_header_id = l_shipment_header_id
   AND rsl.po_line_location_id = wdd.PO_SHIPMENT_LINE_ID
   and rsl.po_line_id = wdd.source_line_id
   and rsl.po_header_id = wdd.source_header_id
   and wdd.source_code = 'PO'
   and wda.delivery_id is not null
   and exists
   (
       select shipment_header_id
       from wsh_inbound_txn_history
       where shipment_header_id = rsl.shipment_header_id
       AND status = 'PENDING_MATCHING'
           AND transaction_type = 'RECEIPT'
   );

/* find all deliveries for no rates or partial rates for all deliveries for the given rcv ship header id  */

cursor  c_get_no_rates_del IS
select distinct tmp.delivery_id
           FROM  fte_estimate_rates_del_temp tmp,
                 WSH_DELIVERY_LEGS wdl
          WHERE  tmp.DELIVERY_ID = WDL.DELIVERY_ID
            AND (  NVL(WDL.REPRICE_REQUIRED,'N')  = 'Y'
                   OR NOT EXISTS
                   (SELECT WFC.DELIVERY_LEG_ID
                  FROM  WSH_FREIGHT_COSTS WFC
                  WHERE WFC.DELIVERY_LEG_ID = WDL.DELIVERY_LEG_ID
                    AND WDL.DELIVERY_LEG_ID IS NOT NULL
                    AND WFC.LINE_TYPE_CODE = 'SUMMARY'
                    AND WFC.CHARGE_SOURCE_CODE= 'PRICING_ENGINE'
                    AND WFC.TOTAL_AMOUNT is not null)) ;

--output table variable
l_del_table  FTE_PO_INTEGRATION_GRP.fte_number_table;
l_rate_available_table  FTE_PO_INTEGRATION_GRP.fte_varchar3_table;
l_matching_table  FTE_PO_INTEGRATION_GRP.fte_varchar3_table;
l_del_count  NUMBER;
l_no_rate_del_count  NUMBER;
l_NR_count  NUMBER;


/* find all receipts for those receipt lines where there is no rates available or
  partial rates available or available rates needs to re-rated */
-- fte_estimate_rates_del_temp contain the delivery list for the given shipment header id
cursor c_get_receipts_no_rates IS
select distinct wdd.vendor_id,
       wdd.ship_from_site_id vendor_site_id,
       wdd.source_line_id,
       wdd.po_shipment_line_id,
       wdd.rcv_shipment_line_id
 FROM  WSH_DELIVERY_DETAILS  WDD,
       WSH_DELIVERY_ASSIGNMENTS_V WDA2,
       fte_estimate_rates_del_temp tmp
WHERE  WDA2.delivery_detail_id = wdd.delivery_detail_id
AND tmp.RATE_AVAILABLE_FLAG = 'N' and tmp.MATCHING_FLAG = 'Y'
AND wda2.delivery_id = tmp.delivery_id
UNION
select distinct wdd.vendor_id,
       wdd.ship_from_site_id vendor_site_id,
       wdd.source_line_id,
       wdd.po_shipment_line_id,
       rsl.shipment_line_id
 FROM  WSH_DELIVERY_DETAILS  WDD,
       WSH_DELIVERY_ASSIGNMENTS_V WDA,
       rcv_shipment_lines rsl,
       fte_estimate_rates_del_temp tmp2
WHERE  WDA.delivery_detail_id = wdd.delivery_detail_id
AND rsl.po_line_location_id = wdd.PO_SHIPMENT_LINE_ID
and rsl.po_line_id = wdd.source_line_id
and wdd.source_code = 'PO'
and wda.delivery_id is not null
AND tmp2.RATE_AVAILABLE_FLAG = 'N'
AND tmp2.MATCHING_FLAG = 'N'
AND wda.delivery_id = tmp2.delivery_id;

/* This following query returns all delivery lines along with the receipt lines and the cost associated
for the given Parameters - Shipment Header Id
Line Type code ( "SUMMARY" or "PRICE" )
Mode of Transport is devided into three. 1. TL and 2. LTL, 3. NON-TL-LTL
For TL Mode, rates are stores at SUMMARY ( line type code ) and others stored at PRICE (line type code)

--If the rates are in multiple currencies or the currency from WFC is different from WDD,
need to convert into WDD Currency and sum of the cost as output
-- This query will be returned all loose items ( all modes ) and packed items for LTL since packed items are rated
*/
cursor c_get_receipts_detail_rates(l_shipment_header_id number ) IS

SELECT WDD.VENDOR_ID,
       WDD.SHIP_FROM_SITE_ID VENDOR_SITE_ID,
       WDD.SOURCE_LINE_ID,
       WDD.PO_SHIPMENT_LINE_ID,
       WDD.RCV_SHIPMENT_LINE_ID,
       WDD.CURRENCY_CODE PO_CURRENCY_CODE,
       WFC.CURRENCY_CODE,
       WDD.REQUESTED_QUANTITY_UOM,
       sum(nvl(wdd.received_quantity, nvl(wdd.shipped_quantity,
                NVL(wdd.picked_quantity, wdd.requested_quantity)))) TOTAL_SHIP_QTY,
       SUM(TOTAL_AMOUNT) TOTAL_COST
FROM   WSH_NEW_DELIVERIES WND,
       WSH_DELIVERY_LEGS WDL,
       WSH_FREIGHT_COSTS WFC,
       WSH_DELIVERY_DETAILS  WDD,
       WSH_DELIVERY_ASSIGNMENTS_V WDA,
       WSH_TRIPS WT,
       WSH_TRIP_STOPS WTS1,
       WSH_TRIP_STOPS WTS2,
       fte_estimate_rates_del_temp tmp
WHERE  WND.DELIVERY_ID = WDL.DELIVERY_ID
AND    WDA.DELIVERY_ID = WND.DELIVERY_ID
AND    WDD.DELIVERY_DETAIL_ID=WDA.DELIVERY_DETAIL_ID
AND    WDL.DELIVERY_LEG_ID=WFC.DELIVERY_LEG_ID
AND    WND.DELIVERY_ID = WFC.DELIVERY_ID
AND    WDD.DELIVERY_DETAIL_ID=WFC.DELIVERY_DETAIL_ID
--AND    WND.RCV_SHIPMENT_HEADER_ID IS NOT NULL
-- For only those deliveries has rates
AND  tmp.delivery_id =WND.DELIVERY_ID
AND  tmp.RATE_AVAILABLE_FLAG = 'Y'
AND    WDD.CONTAINER_FLAG='N'       -- only loosed items
-- For LTL, get all items including packed items, for others only loose items
-- since LTL rates are done at low level detail level as well.
AND    ( WT.MODE_OF_TRANSPORT= 'LTL' or (WT.MODE_OF_TRANSPORT <> 'LTL' AND WDA.PARENT_DELIVERY_DETAIL_ID is NULL))
AND    WFC.DELIVERY_DETAIL_ID IS NOT NULL      -- only detail level rate
-- Line Type Code is SUMMARY for TL(TRUCK),  PRICE for Non-TL
AND    ((WFC.LINE_TYPE_CODE = 'SUMMARY' and WT.MODE_OF_TRANSPORT = 'TRUCK')
        OR
       (WFC.LINE_TYPE_CODE = 'PRICE' and WT.MODE_OF_TRANSPORT <> 'TRUCK'))
AND    WFC.CHARGE_SOURCE_CODE= 'PRICING_ENGINE'  -- Only FTE charge
AND    WTS1.STOP_ID = WDL.PICK_UP_STOP_ID
AND    WTS2.STOP_ID =  WDL.DROP_OFF_STOP_ID
AND    WT.TRIP_ID = WTS1.TRIP_ID
AND    WT.TRIP_ID = WTS2.TRIP_ID

GROUP BY
       WDD.VENDOR_ID,
       WDD.SHIP_FROM_SITE_ID ,
       WDD.SOURCE_LINE_ID,
       WDD.PO_SHIPMENT_LINE_ID,
       WDD.RCV_SHIPMENT_LINE_ID,
       WDD.CURRENCY_CODE,
       WFC.CURRENCY_CODE,
       WDD.REQUESTED_QUANTITY_UOM;

/* Get all container level rates for the given shipment header and excluded delivery list
 This query return only for non-LTL rates since LTL rates are already rated at detail level.
Container Level rates will be pro-rated to the detail level based on the net qty (total of all item qty)
 --TL - SUMMARY, Non-TL - SUMMARY / PRICE
*/
cursor c_get_container_rates(l_shipment_header_id number) IS
SELECT WDD.DELIVERY_DETAIL_ID PARENT_CONTAINER_ID,
       WDD.CURRENCY_CODE PO_CURRENCY_CODE,
       WFC.CURRENCY_CODE,
       SUM(TOTAL_AMOUNT) TOTAL_COST
FROM   WSH_NEW_DELIVERIES WND,
       WSH_DELIVERY_LEGS WDL,
       WSH_FREIGHT_COSTS WFC,
       WSH_DELIVERY_DETAILS  WDD,
       WSH_DELIVERY_ASSIGNMENTS_V WDA,
       WSH_TRIPS WT,
       WSH_TRIP_STOPS WTS1,
       WSH_TRIP_STOPS WTS2,
       fte_estimate_rates_del_temp tmp
WHERE  WND.DELIVERY_ID = WDL.DELIVERY_ID
AND    WDA.DELIVERY_ID = WND.DELIVERY_ID
AND    WDD.DELIVERY_DETAIL_ID=WDA.DELIVERY_DETAIL_ID
AND    WDL.DELIVERY_LEG_ID=WFC.DELIVERY_LEG_ID
AND    WND.DELIVERY_ID = WFC.DELIVERY_ID
AND    WDD.DELIVERY_DETAIL_ID=WFC.DELIVERY_DETAIL_ID
--AND    WND.RCV_SHIPMENT_HEADER_ID IS NOT NULL
-- For only those deliveries has rates
AND  tmp.delivery_id =WND.DELIVERY_ID
AND  tmp.RATE_AVAILABLE_FLAG = 'Y'
AND    WDD.CONTAINER_FLAG='Y' -- Only container item
AND    WDA.PARENT_DELIVERY_DETAIL_ID IS NULL   -- only top level items.
AND    WFC.DELIVERY_DETAIL_ID IS NOT NULL      -- only detail level rate
AND    WFC.LINE_TYPE_CODE in ('SUMMARY','PRICE') -- Only Summary rate at the container
AND    WFC.CHARGE_SOURCE_CODE= 'PRICING_ENGINE'
AND    WTS1.STOP_ID = WDL.PICK_UP_STOP_ID
AND    WTS2.STOP_ID =  WDL.DROP_OFF_STOP_ID
AND    WT.TRIP_ID = WTS1.TRIP_ID
AND    WT.TRIP_ID = WTS2.TRIP_ID
-- Since LTL rates are already calculated at detail level, no need to pro-rate again at detail level.
AND    WT.MODE_OF_TRANSPORT <>'LTL'
AND    ((WT.MODE_OF_TRANSPORT = 'TRUCK' and WFC.LINE_TYPE_CODE = 'SUMMARY')
         OR
        (WT.MODE_OF_TRANSPORT <> 'TRUCK' and WFC.LINE_TYPE_CODE in ('SUMMARY','PRICE')) )
GROUP BY
       WDD.DELIVERY_DETAIL_ID,
       WDD.CURRENCY_CODE,
       WFC.CURRENCY_CODE ;

/* Get all container items ( nested ) for a given parent del-detail id
--Not used for this release since items never packed in nested container for I/B shipments (not supported)
cursor c_get_container_contents ( l_parent_delivery_detail_id number ) IS
SELECT WDD.DELIVERY_DETAIL_ID,
       WDD.VENDOR_ID,
       WDD.SOURCE_LINE_ID,
       WDD.SHIP_FROM_SITE_ID,
       WDD.PO_SHIPMENT_LINE_ID,
       WDD.RCV_SHIPMENT_LINE_ID,
       WDD.CURRENCY_CODE,
       WDD.NET_WEIGHT,
       WDD.WEIGHT_UOM_CODE
FROM WSH_DELIVERY_DETAILS WDD
WHERE
  WDD.CONTAINER_FLAG='N'
  AND EXISTS
 (SELECT 1 FROM  WSH_DELIVERY_ASSIGNMENTS_V WDA
  WHERE WDD.DELIVERY_DETAIL_ID = WDA.DELIVERY_DETAIL_ID
  START WITH WDA.DELIVERY_DETAIL_ID = l_parent_delivery_detail_id
  CONNECT BY PRIOR WDA.DELIVERY_DETAIL_ID = WDA.PARENT_DELIVERY_DETAIL_ID)
*/
-- Since all I/B shipments are packed only one level container, no need of the above query..kept the query for future usage
-- Avoiding connect by prior usage due to performance reason and not required as of now (with current functionality)
-- Need to to pro-rate the rate from container level to the detail level based on the net qty

cursor c_get_container_contents ( l_parent_delivery_detail_id number ) IS
SELECT WDD.DELIVERY_DETAIL_ID,
       WDD.VENDOR_ID,
       WDD.SHIP_FROM_SITE_ID,
       WDD.SOURCE_LINE_ID,
       WDD.PO_SHIPMENT_LINE_ID,
       WDD.RCV_SHIPMENT_LINE_ID,
       WDD.CURRENCY_CODE,
       WDD.INVENTORY_ITEM_ID,
       WDD.NET_WEIGHT,
       WDD.WEIGHT_UOM_CODE
FROM WSH_DELIVERY_DETAILS WDD,
     WSH_DELIVERY_ASSIGNMENTS_V WDA
WHERE WDD.DELIVERY_DETAIL_ID = WDA.DELIVERY_DETAIL_ID
and WDA.PARENT_DELIVERY_DETAIL_ID = l_parent_delivery_detail_id;


-- Declare local variables

i number ;
j number ;
k number ;
l_index number;

l_total_net_qty number ;
l_cont_contents_found_flag VARCHAR2(1);
l_no_rates_delivery_flag VARCHAR2(1);
l_rates_delivery_flag VARCHAR2(1);
l_delivery_exist_flag VARCHAR2(1);
l_delivery_list varchar2(2000);
l_no_rates_delivery_list varchar2(2000);
l_net_weight number ;
l_first_uom_code varchar2(3);

l_return_status  VARCHAR2(1);
l_number_of_warnings NUMBER := 0;
l_number_of_errors NUMBER := 0;
l_msg_data VARCHAR2(4000);
-- Out parameter variables

l_message varchar2(1000);
l_loop_counter number;
l_rcv_count number ;

--Get RCV shipment Lines out variables
l_RCV_SHIP_LINES_TABLE   FTE_PO_INTEGRATION_GRP.fte_number_table;
l_RCV_SHIP_COST_TABLE    FTE_PO_INTEGRATION_GRP.fte_number_table;

-- Container level rates variable
l_CNT_parent_cont_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_CNT_po_corrency_code_table FTE_PO_INTEGRATION_GRP.fte_varchar15_table;
l_CNT_wfc_corrency_code_table FTE_PO_INTEGRATION_GRP.fte_varchar15_table;
l_CNT_total_cost_table FTE_PO_INTEGRATION_GRP.fte_number_table;

-- Container Contents Level Rates variables
l_DET_vendor_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_DET_vendor_site_id_table  FTE_PO_INTEGRATION_GRP.fte_number_table;
l_DET_po_line_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_DET_po_line_loc_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_DET_rcv_ship_line_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_DET_po_corrency_code_table FTE_PO_INTEGRATION_GRP.fte_varchar15_table;
l_DET_wfc_corrency_code_table FTE_PO_INTEGRATION_GRP.fte_varchar15_table;
l_DET_total_cost_table FTE_PO_INTEGRATION_GRP.fte_number_table;

--Container contents variables (store the values from the above query )

l_CC_delivery_detail_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_CC_vendor_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_CC_vendor_site_id_table  FTE_PO_INTEGRATION_GRP.fte_number_table;
l_CC_po_line_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_CC_po_line_loc_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_CC_rcv_ship_line_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_CC_po_corrency_code_table FTE_PO_INTEGRATION_GRP.fte_varchar15_table;
l_CC_item_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_CC_net_wt_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_CC_uom_code_table FTE_PO_INTEGRATION_GRP.fte_varchar3_table;

-- Cursor parameters
l_mode varchar2(20);
l_line_type_code varchar2(20);

l_delivery_list_table FTE_PO_INTEGRATION_GRP.fte_number_table;

-- Rates variables (all rates)
l_vendor_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_vendor_site_id_table  FTE_PO_INTEGRATION_GRP.fte_number_table;
l_po_line_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_po_line_loc_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_rcv_ship_line_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_po_corrency_code_table FTE_PO_INTEGRATION_GRP.fte_varchar15_table;
l_wfc_corrency_code_table FTE_PO_INTEGRATION_GRP.fte_varchar15_table;
l_ship_qty_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_ship_qty_uom_table FTE_PO_INTEGRATION_GRP.fte_varchar3_table;
l_total_cost_table FTE_PO_INTEGRATION_GRP.fte_number_table;

-- NR - No rates list variables
l_NR_vendor_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_NR_vendor_site_id_table  FTE_PO_INTEGRATION_GRP.fte_number_table;
l_NR_po_line_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_NR_po_line_loc_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_NR_rcv_ship_line_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;

-- Exception variables

e_validation_error EXCEPTION;
--

l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'GET_ESTIMATED_RATES';
--
BEGIN
  SAVEPOINT  FTE_PO_INTEGRATION_GRP;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  --
  --
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
     FND_MSG_PUB.initialize;
  END IF;
  --
  --
  --  Initialize API return status to success
  x_return_status         := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  x_msg_count             := 0;
  x_msg_data              := '';

  -- Debug
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     fnd_profile.get('WSH_DEBUG_LOG_DIRECTORY',l_debugfile);
     l_debugfile := l_debugfile||'/'||WSH_DEBUG_SV.g_file;

     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'Begin of the process ',l_debugfile);
     WSH_DEBUG_SV.log(l_module_name,'Shipment Header id ',p_shipment_header_id);
  END IF;
  --
  -- initialize variables and tables
  l_receipt_lines_tab.delete;
  x_receipt_lines_tab.delete;

  -- find all deliveries (matching and mismatching shipments)
  OPEN c_get_deliveries(p_shipment_header_id);
  FETCH c_get_deliveries BULK COLLECT
      INTO l_del_table,l_rate_available_table,l_matching_table;
  l_del_count := l_del_table.count ;
  WSH_DEBUG_SV.log(l_module_name,'Total deliveries found for the given header id : ',l_del_count);
  l_delivery_exist_flag := 'N';
  l_no_rate_del_count := 0;
  --
  IF l_del_count > 0 then
     --{
     l_delivery_exist_flag := 'Y';
     FORALL j IN 1..l_del_count
     INSERT INTO fte_estimate_rates_del_temp(DELIVERY_ID,RATE_AVAILABLE_FLAG,MATCHING_FLAG)
     VALUES (l_del_table(j),l_rate_available_table(j),l_matching_table(j));

     -- find all deliveries for no rates or partial rates (matching and mismatching shipments)
     OPEN c_get_no_rates_del;
     FETCH c_get_no_rates_del BULK COLLECT
         INTO l_del_table;
     l_no_rate_del_count := l_del_table.count ;
     WSH_DEBUG_SV.log(l_module_name,'Total deliveries, which have no rates: ',l_no_rate_del_count);
     --
     --Updating those deliveries with RATE_AVAILABLE_FLAG ='N'
     IF l_no_rate_del_count > 0 then
        FORALL j IN 1..l_no_rate_del_count
        UPDATE fte_estimate_rates_del_temp
        SET RATE_AVAILABLE_FLAG ='N'
        WHERE DELIVERY_ID = l_del_table(j);
     END IF;
     --}
  ELSE
    -- No record found for the given rcv header id
    FND_MESSAGE.SET_NAME('FTE','FTE_EC_NO_DATA_FOUND');
    FND_MESSAGE.SET_TOKEN('LOG_FILE',l_debugfile);
    raise e_validation_error;
  END IF;
  --
  -- Get all Rates ( except LTL) Cotainer Level Rates
  --
  OPEN c_get_container_rates(p_shipment_header_id);
  --dbms_output.put_line('after open cursor c_get_container_rates for CNT Rates');
  FETCH c_get_container_rates BULK COLLECT
      INTO l_CNT_parent_cont_id_table,
           l_CNT_po_corrency_code_table,
           l_CNT_wfc_corrency_code_table,
           l_CNT_total_cost_table;
  close c_get_container_rates;
  --dbms_output.put_line('after close cursor c_get_container_rates for CNT Rates'||l_CNT_parent_cont_id_table.COUNT);
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'cursor c_get_container_rates - All Rates except LTL - number '||
                      'of records found: ', l_CNT_parent_cont_id_table.COUNT);
  END IF;
  --
  --
  -- Get all Container Contents for the given Container Parent Container
  --
  l_cont_contents_found_flag := 'N';
  i := 1;
  j := 1;
  k := 1;
  --dbms_output.put_line('validating  l_CNT_parent_cont_id_table.COUNT > 0 ');
  IF l_CNT_parent_cont_id_table.COUNT > 0 THEN
  --{
     --
     --dbms_output.put_line('validated  l_CNT_parent_cont_id_table.COUNT > 0 ');
     -- For each container, get all contents , total the net qty of the contents, pro-rate the cost to each contents
     i := l_CNT_parent_cont_id_table.FIRST;
     WHILE i is not NULL
     LOOP
     --{
         OPEN c_get_container_contents(l_CNT_parent_cont_id_table(i));
         FETCH c_get_container_contents BULK COLLECT
             INTO l_CC_delivery_detail_table,
                  l_CC_vendor_id_table,
                  l_CC_vendor_site_id_table,
                  l_CC_po_line_id_table,
                  l_CC_po_line_loc_id_table,
                  l_CC_rcv_ship_line_id_table,
                  l_CC_po_corrency_code_table,
                  l_CC_item_id_table,
                  l_CC_net_wt_table,
                  l_CC_uom_code_table;
         close c_get_container_contents;
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'cursor c_get_container_contents - number '||
                             'of records found: ', l_CC_delivery_detail_table.COUNT);
         END IF;
         -- Initializing the net wt for each container
         l_total_net_qty := 0;
         -- Get the total net wt for each container in case net qty at container level does not match with
         -- the total net qty of the contents.
         j := l_CC_delivery_detail_table.FIRST;
         WHILE j is not NULL
         LOOP
         --{
             l_cont_contents_found_flag := 'Y';
             --
             -- Need to convert the Uom code into the 1st UOM to total the net qty for the prorating.
             -- in case of different uom in different container content items
             --
             IF j = 1 then
                l_first_uom_code := l_CC_uom_code_table(j);
             END IF;
             -- Convert the uom if different from the 1st UOM
             IF l_first_uom_code <> l_CC_uom_code_table(j) and nvl(l_CC_net_wt_table(j),0) > 0 then
                l_CC_net_wt_table(j) := WSH_WV_UTILS.Convert_Uom (l_CC_uom_code_table(j),
                                                                  l_first_uom_code,
                                                                  l_CC_net_wt_table(j),
                                                                  l_CC_item_id_table(j));
             END IF;
             -- Total
             l_total_net_qty := l_total_net_qty + nvl(l_CC_net_wt_table(j),0) ;
             --
             j := l_CC_delivery_detail_table.next(j);
         --}
         END LOOP;-- End of WHILE j is not NULL
         IF l_total_net_qty <= 0 then
            WSH_DEBUG_SV.log(l_module_name,'Total net Qty for the contents of the Container id  '||l_CNT_parent_cont_id_table(i) ||
                             ' s zero '||l_total_net_qty);
         END IF;
         --VALIDATION CHECK
         IF l_CNT_total_cost_table(i) > 0 and l_total_net_qty <= 0 then
         --{
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Total Cost at the container level is ',l_CNT_total_cost_table(i));
               WSH_DEBUG_SV.log(l_module_name,'Total net Qty for the contents of the Container id  ',l_CNT_parent_cont_id_table(i) ||
                             ' s zero '||l_total_net_qty);
            END IF;
            --dbms_output.put_line('Total Qty of the container contents is zero ');
            FND_MESSAGE.SET_NAME('FTE','FTE_EC_MISSING_DETAIL_NET_QTY');
            FND_MESSAGE.SET_TOKEN('LOG_FILE',l_debugfile);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            raise e_validation_error;
         --}
         END IF;
         j := l_CC_delivery_detail_table.FIRST;
         WHILE j is not NULL
         LOOP
         --{
           -- Prorate the Total Cost into detail contents based on the net wt at the line item level.
           -- Proration logic of the distribution of container level cost to the container contents
           --For ex: Total Cost at Container Level is $100.00 (Net Wt - 100 LBS)
           -- ITEM NAME	NET WT	RATE DISTRIBUTED
           -- ITEM-A	50 LBS	(50/105 * 100) = $47.62
           -- ITEM-B	30 LBS	(30/105 * 100) = $28.57
           -- ITEM-C	25 LBS	(25/105 * 100) = $23.81
           -- Item Total	105 LBS	$100.00
           --
           -- Calcualte the cost at item level
           -- Store all container contents rates here  (except LTL )
           --
           IF l_total_net_qty > 0 then
              l_DET_total_cost_table(k) := (l_CC_net_wt_table(j)/l_total_net_qty) * l_CNT_total_cost_table(i);
              --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Total cost for the rcv shipment line '||l_CC_rcv_ship_line_id_table(j)||' Cost-'
                            ||l_DET_total_cost_table(k) || ' '||l_CNT_wfc_corrency_code_table(i));
              END IF;
              IF l_CC_po_corrency_code_table(j) <> l_CNT_wfc_corrency_code_table(i) then
              --{
                 l_DET_total_cost_table(k) :=GL_CURRENCY_API.convert_amount (
                                x_from_currency     => l_CNT_wfc_corrency_code_table(i),
                                x_to_currency       => l_CC_po_corrency_code_table(j),
                                x_conversion_date   => sysdate,
                                x_amount            => l_DET_total_cost_table(k));
                IF l_debug_on THEN
                --{
                   WSH_DEBUG_SV.log(l_module_name,'Total cost for the delivery detail after conversion '
                            ||l_DET_total_cost_table(k)||' '||l_CC_po_corrency_code_table(j));
                --}
                END IF;
              --}
              END IF;
              --}
           ELSE
           --{
              -- Assiging the cost as zero since the total container qty is zero
              l_DET_total_cost_table(k) := 0;
           --}
           END IF;
           --Store the remaining attributes at detail level
           l_DET_vendor_id_table(k) :=  l_CC_vendor_id_table(j);
           l_DET_vendor_site_id_table(k)  := l_CC_vendor_site_id_table(j);
           l_DET_po_line_id_table(k) := l_CC_po_line_id_table(j);
           l_DET_po_line_loc_id_table(k) := l_CC_po_line_loc_id_table(j);
           l_DET_rcv_ship_line_id_table(k) := l_CC_rcv_ship_line_id_table(j);
           l_DET_po_corrency_code_table(k) := l_CC_po_corrency_code_table(j);
           -- Added this since po and wfc currency are same since
           -- it is converted at the time of total cost calc.
           l_DET_wfc_corrency_code_table(k) := l_CC_po_corrency_code_table(j);
           --
           j := l_CC_delivery_detail_table.next(j);
           k := k+ 1; --increment by 1 to store next item
         --}
         END LOOP; -- End of WHILE j is not NULL
         -- End of l_CC_delivery_detail_table
         i := l_CNT_parent_cont_id_table.next(i);
         -- Go to the next container
     --}
     END LOOP;
     --End of l_CNT_parent_cont_id_table table processing
     --End of all container level rating pro-rated to the line level
  --}
  END IF; --End of container rates and allocation to the detail
  --  Get all receipts that do not have any rates or partial rates or invalid rate (re-rate required)
  l_NR_count := 0;
  IF l_no_rate_del_count > 0 THEN
     OPEN c_get_receipts_no_rates;
     FETCH c_get_receipts_no_rates BULK COLLECT
           INTO l_NR_vendor_id_table,
                l_NR_vendor_site_id_table,
                l_NR_po_line_id_table,
                l_NR_po_line_loc_id_table,
                l_NR_rcv_ship_line_id_table;
     close c_get_receipts_no_rates;
     l_NR_count := l_NR_rcv_ship_line_id_table.COUNT;
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'cursor c_get_receipts_no_rates - number '||
                            'of records found: ', l_NR_count);
     END IF;
  END IF;
  --
  --dbms_output.put_line('Building Output Table ');
  -- Building Output Table for Non-Rates receipts
   -- Storing all receipt lines, which do not have any rates or partial rates or dirty rates
   -- Cost is zero for this case.
   l_message := FND_MESSAGE.Get_String('FTE', 'FTE_EC_NO_RATES_AVAILABLE');
   --dbms_output.put_line('Message Rate not found '||l_message);
   -- Purge the table before storing receipt lines and cost
   l_rcv_ship_lines_table.delete;
   l_rcv_ship_cost_table.delete;
   l_no_rates_delivery_flag := 'N';
   --
   IF l_NR_count > 0 THEN
   --{ If there is any shipment lines with no rates
      l_no_rates_delivery_flag := 'Y';
      j := l_NR_rcv_ship_line_id_table.FIRST ;
      WHILE j is not null
      LOOP
      --{
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Storing the following info w/ zero cost ');
           WSH_DEBUG_SV.log(l_module_name,'p_shipment_header_id : ',p_shipment_header_id);
           WSH_DEBUG_SV.log(l_module_name,'rcv shipment line id : ',l_NR_rcv_ship_line_id_table(j));
           WSH_DEBUG_SV.log(l_module_name,'l_NR_po_line_id_table(j) : ',l_NR_po_line_id_table(j));
           WSH_DEBUG_SV.log(l_module_name,'l_NR_po_line_loc_id_table(j) : ',l_NR_po_line_loc_id_table(j));
           WSH_DEBUG_SV.log(l_module_name,'VENDOR_ID ',l_NR_vendor_id_table(j));
           WSH_DEBUG_SV.log(l_module_name,'VENDOR_SITE_ID ',l_NR_vendor_site_id_table(j));
           WSH_DEBUG_SV.log(l_module_name,'status','W');
           WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
        END IF;
        --PL/SQL table is building with the index of RCV Shipment Line Id
        i := l_NR_rcv_ship_line_id_table(j);
        l_receipt_lines_tab(i).RCV_SHIPMENT_LINE_ID := l_NR_rcv_ship_line_id_table(j);
        l_receipt_lines_tab(i).VENDOR_ID := l_NR_vendor_id_table(j);
        l_receipt_lines_tab(i).VENDOR_SITE_ID := l_NR_vendor_site_id_table(j);
        l_receipt_lines_tab(i).CURRENCY_CODE := null;
        l_receipt_lines_tab(i).TOTAL_COST := 0;
        l_receipt_lines_tab(i).RETURN_STATUS := 'W';
        l_receipt_lines_tab(i).MESSAGE_TEXT  := l_message;

        j := l_NR_rcv_ship_line_id_table.next(j);
      --}
      END LOOP; --End of WHILE j is not NULL
   --}
   END IF; --End of  l_NR_po_line_id_table.COUNT > 0 validation
   --
   --dbms_output.put_line('End of No-Rates lines building, if any ');
   --
  -- Rates will be calculated by Either Matched Receipts and WDD / Mismatched

  -- Mismatched CASE - Could not match the Receipt with Delivery Lines
  -- Get the Rates for all PO lines for the given Shipment Header ( Mismatched Receipts/Shipments)
  -- Get the Net Qty of all po lines
  -- Distribute the the Rates based on the net qty of each receipt line

  -- Matched CASE - Matched the Receipts w/ Delivery Lines
  -- Get only  TL Rates (only loose items)
  --dbms_output.put_line('get receipt detail rates for shipment header id '||p_shipment_header_id);
  --
  OPEN c_get_receipts_detail_rates(p_shipment_header_id);
  --dbms_output.put_line('after open cursor c_get_receipts_detail_rates for Rates');
  FETCH c_get_receipts_detail_rates BULK COLLECT
     INTO l_vendor_id_table,
          l_vendor_site_id_table,
          l_po_line_id_table,
          l_po_line_loc_id_table,
          l_rcv_ship_line_id_table,
          l_po_corrency_code_table,
          l_wfc_corrency_code_table,
          l_ship_qty_uom_table,
          l_ship_qty_table,
          l_total_cost_table;
  close c_get_receipts_detail_rates;
  --dbms_output.put_line('after close cursor c_get_receipts_detail_rates for Rates '||l_rcv_ship_line_id_table.COUNT);
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'cursor c_get_receipts_detail_rates - Rates - number '||
                      'of records found: ', l_rcv_ship_line_id_table.COUNT);
  END IF;
  -- Validating that if there are rates exist for all modes or container
  -- if l_vendor_id_table.count = 0 means there no rates availble for non-packed items except LTL
  -- l_CNT_parent_cont_id_table.count = 0  means there is no rates available for packed items

  if l_vendor_id_table.count = 0 and l_CNT_parent_cont_id_table.count = 0 then
  --{
     --dbms_output.put_line('Delivery w/ rates not found for shipment header id '||p_shipment_header_id);
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
     l_number_of_warnings := l_number_of_warnings + 1;
     FND_MESSAGE.SET_NAME('FTE','FTE_EC_RATES_NOT_AVAILABLE');
     FND_MESSAGE.SET_TOKEN('LOG_FILE',l_debugfile);
     raise e_validation_error;
  --}
  end if;
  l_message := FND_MESSAGE.Get_String('FTE', 'FTE_EC_RATES_AVAILABLE');
  --
  --dbms_output.put_line('No of Rates lines '|| l_rcv_ship_line_id_table.count );
  l_loop_counter := 1;
  FOR l_loop_counter IN 1..2
  LOOP
  --{
     --
     -- loop counter = 1 for all modes rating except the container detail rating
     -- loop counter = 2 for Container Detail rating
     --
     -- Assign the Container Detail Ratings to the same PL/SQL columns for the processing rather than seperate loop
     IF l_loop_counter = 2 then
        l_vendor_id_table := l_DET_vendor_id_table;
        l_vendor_site_id_table := l_DET_vendor_site_id_table;
        l_rcv_ship_line_id_table := l_DET_rcv_ship_line_id_table;
        l_po_corrency_code_table := l_DET_po_corrency_code_table;
        l_wfc_corrency_code_table := l_DET_wfc_corrency_code_table ;
        l_total_cost_table := l_DET_total_cost_table;
        --dbms_output.put_line('No of packed items -Rates lines '|| l_rcv_ship_line_id_table.count );
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'LOOP Counter 1. All modes, 2. Container Detail ',l_loop_counter );
        WSH_DEBUG_SV.log(l_module_name,'No of records to process : ',l_rcv_ship_line_id_table.COUNT );
     END IF;
     j := l_rcv_ship_line_id_table.FIRST;
     WHILE j is NOT NULL
     LOOP
     --{
       --dbms_output.put_line('Within Loop ');
       -- Building the Output table with the index id as RCV Shipment Line Id
       --i := l_rcv_ship_line_id_table(j);
       --Converting the Curency if the pos currency is different from rated curency
       -- and if the cost > 0
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Process for RCV Shipment Line : ',l_rcv_ship_line_id_table(j) );
           WSH_DEBUG_SV.log(l_module_name,'Compare Currencies PO currency  : ',l_po_corrency_code_table(j) );
           WSH_DEBUG_SV.log(l_module_name,'Compare Currencies Rate currency  : ',l_wfc_corrency_code_table(j));
           WSH_DEBUG_SV.log(l_module_name,'Total Cost for conversion  : ',l_total_cost_table(j));
        END IF;
        --dbms_output.put_line('Compare currency code '||l_po_corrency_code_table(j)||' and '||l_wfc_corrency_code_table(j));
       IF (l_po_corrency_code_table(j) <> l_wfc_corrency_code_table(j)) AND
          nvl(l_total_cost_table(j),0) > 0 then
       --{
          --dbms_output.put_line('Converting currency code ');
          l_total_cost_table(j) :=GL_CURRENCY_API.convert_amount(
                                             l_wfc_corrency_code_table(j),
                                             l_po_corrency_code_table(j),
                                             SYSDATE,
                                             'Corporate',
                                             l_total_cost_table(j)
                                            );
       --}
       END IF;
       --dbms_output.put_line('Before purging RCV Tables ');
       l_rcv_ship_lines_table.delete;
       l_rcv_ship_cost_table.delete;
       --dbms_output.put_line('After purging RCV Tables ');
       -- Validating that shipment is matched or not
       -- If the rcv shipment line is NULL, the shipment line is not matched
       -- Need to call get_rcv_shipment_lines and pro-rated cost for each rcv shipment lines
       if l_rcv_ship_line_id_table(j) is null then
       --{
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Calling get_rcv_shipment_lines API since RCV Shipment Line id is NULL : ',l_rcv_ship_line_id_table(j) );
              WSH_DEBUG_SV.log(l_module_name,'Calling Parameters - P_PO_LINE_ID : ',l_po_line_id_table(j) );
              WSH_DEBUG_SV.log(l_module_name,'Calling Parameters - P_PO_LINE_LOCATION_ID : ',l_po_line_loc_id_table(j) );
              WSH_DEBUG_SV.log(l_module_name,'Calling Parameters - P_TOTAL_COST : ',l_total_cost_table(j) );
              WSH_DEBUG_SV.log(l_module_name,'Calling Parameters - P_SHIP_QTY : ',l_ship_qty_table(j) );
              WSH_DEBUG_SV.log(l_module_name,'Calling Parameters - P_SHIP_QTY_UOM : ',l_ship_qty_uom_table(j) );
           END IF;
           --dbms_output.put_line('RCV shipment line id is null, calling get_rcv_shipment_lines API to get the receipt lines');
           -- get all rcv shipment lines for the given po line id and po line location id
           get_rcv_shipment_lines (x_return_status  => x_return_status,
                               P_SHIPMENT_HEADER_ID  =>p_shipment_header_id,
                               P_PO_LINE_ID          =>l_po_line_id_table(j),
                               P_PO_LINE_LOCATION_ID =>l_po_line_loc_id_table(j),
                               P_TOTAL_COST           =>l_total_cost_table(j),
                               P_SHIP_QTY_UOM         =>l_ship_qty_uom_table(j),
                               P_SHIP_QTY             =>l_ship_qty_table(j),
                               X_RCV_SHIP_LINES_TABLE =>l_rcv_ship_lines_table,
                               X_RCV_SHIP_COST_TABLE  =>l_rcv_ship_cost_table);
           if x_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS then
              --dbms_output.put_line('error while calling get_rcv_shipment_lines API');
              FND_MESSAGE.SET_NAME('FTE','FTE_EC_ERROR_SHP_LN_API');
              FND_MESSAGE.SET_TOKEN('LOG_FILE',l_debugfile);
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Error after Calling get_rcv_shipment_lines API Status : ',x_return_status );
              END IF;
              raise e_validation_error;
           end if;
           --
       --}
       else
       --{
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'store the one is matched into RCV_SHIP_LINES_TABLE ',l_rcv_ship_line_id_table(j));
          END IF;
          --dbms_output.put_line('RCV shipment line is not null ');
          -- These are the matching receipts, store the one is matched into RCV_SHIP_LINES_TABLE, RCV_SHIP_COST_TABLE
          l_rcv_ship_lines_table(1) := l_rcv_ship_line_id_table(j);
          l_rcv_ship_cost_table(1) := l_total_cost_table(j);
          --dbms_output.put_line('After storing shipment line and cost ');
       --}
       end if; --end of l_rcv_ship_line_id_table(j) is null
       --
       --dbms_output.put_line('validate l_rcv_ship_lines_table.COUNT > 0 ');
       --
       k := l_rcv_ship_lines_table.FIRST;
       WHILE k is not NULL
       LOOP
       --{
         i := l_rcv_ship_lines_table(k);
         --dbms_output.put_line(' Rcv Shipment Line id '||i);
         IF l_receipt_lines_tab.EXISTS(i) then
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Rcv Shipment Line id -Status ',l_receipt_lines_tab(i).RETURN_STATUS);
               WSH_DEBUG_SV.log(l_module_name,'Rcv Shipment Line id does exist and Existing cost from other deliveries ',l_receipt_lines_tab(i).TOTAL_COST);
               WSH_DEBUG_SV.log(l_module_name,'New Cost from this delivery for the same Rcv Shipment Line id ',l_rcv_ship_cost_table(k));
            END IF;
            IF l_receipt_lines_tab(i).RETURN_STATUS ='S' THEN
               l_receipt_lines_tab(i).TOTAL_COST := nvl(l_receipt_lines_tab(i).TOTAL_COST,0) + nvl(l_rcv_ship_cost_table(k),0);
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Rcv Shipment Line id does exist and added the cost',l_rcv_ship_cost_table(k));
               END IF;
            ELSE
               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'One of the Delivery does not have the valid rate against the same Rcv Shipment Line id, '||
                                   ' so the rate against this receipt line is incorrect and set to zero ',l_receipt_lines_tab(i).TOTAL_COST);
               END IF;
            END IF;
         ELSE
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Storing output table for id ',i);
               WSH_DEBUG_SV.log(l_module_name,'Vendor Id ',l_vendor_id_table(j));
               WSH_DEBUG_SV.log(l_module_name,'vendor site id ',l_vendor_site_id_table(j));
               WSH_DEBUG_SV.log(l_module_name,'rcv id ',l_RCV_SHIP_LINES_TABLE(k));
               WSH_DEBUG_SV.log(l_module_name,'cost ',l_RCV_SHIP_COST_TABLE(k));
               WSH_DEBUG_SV.log(l_module_name,'currency code ',l_po_corrency_code_table(j));
               WSH_DEBUG_SV.log(l_module_name,'status','S');
               WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
            END IF;
            --
            l_receipt_lines_rec.VENDOR_ID := l_vendor_id_table(j);
            l_receipt_lines_rec.VENDOR_SITE_ID := l_vendor_site_id_table(j);
            l_receipt_lines_rec.RCV_SHIPMENT_LINE_ID := l_RCV_SHIP_LINES_TABLE(k);
            l_receipt_lines_rec.CURRENCY_CODE := l_po_corrency_code_table(j);
            l_receipt_lines_rec.TOTAL_COST := l_RCV_SHIP_COST_TABLE(k);
            l_receipt_lines_rec.RETURN_STATUS := 'S';
            l_receipt_lines_rec.MESSAGE_TEXT  := l_message;

            --dbms_output.put_line(' End of Storing output table ');

            l_receipt_lines_tab(i) := l_receipt_lines_rec;

            --dbms_output.put_line(' After Storing output table ');

         --}
         END IF; --End of l_receipt_lines_tab.EXIST
           k := l_rcv_ship_lines_table.next(k);
         --
       --}
       END LOOP; -- End of WHILE k is not NULL
       --
       j := l_rcv_ship_line_id_table.next(j);
        --
     --}
     END LOOP; -- End of WHILE j is not NULL
  --}
  END LOOP; -- End of l_loop_counter IN 1..2
  --Storing the variable to the output table x_receipt_lines_tab
  --
  x_receipt_lines_tab := l_receipt_lines_tab;
  --
  -- End of building the output table - X_RECEIPT_LINES_TAB
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,' --End of process --After Storing output table x_receipt_lines_tab--- ');
  end if;
   /* this last secton is for testing only and this will be removed after the UT */
    --dbms_output.put_line(' Total receipt lines '||x_receipt_lines_tab.COUNT);
/*
    i := x_receipt_lines_tab.FIRST ;
    j := 1;
    WHILE j <= x_receipt_lines_tab.COUNT
    LOOP
        insert into FTE_RECEIPT_LINE_RECORDS
        values
        ( x_receipt_lines_tab(i).VENDOR_ID,
          x_receipt_lines_tab(i).VENDOR_SITE_ID,
          x_receipt_lines_tab(i).RCV_SHIPMENT_LINE_ID,
          x_receipt_lines_tab(i).CURRENCY_CODE,
          x_receipt_lines_tab(i).TOTAL_COST,
          x_receipt_lines_tab(i).RETURN_STATUS,
          x_receipt_lines_tab(i).MESSAGE_TEXT );
          i := x_receipt_lines_tab.NEXT(i);
       j := j+1;
    END LOOP;
    COMMIT;
*/
-- clearing the cache after each call.
delete from fte_estimate_rates_del_temp;
  /* end of temporary section to be removed after UT */
    --dbms_output.put_line(' just before calling api_post_call ');
    wsh_util_core.api_post_call(
            p_return_status    =>x_return_status,
            x_num_warnings     =>l_number_of_warnings,
            x_num_errors       =>l_number_of_errors,
            p_msg_data         =>l_msg_data);
    --dbms_output.put_line(' just after calling api_post_call ');
    IF l_number_of_errors > 0
    THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_number_of_warnings > 0
    THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;

    FND_MSG_PUB.Count_And_Get
       (
        p_count  => x_msg_count,
        p_data  =>  x_msg_data,
        p_encoded => FND_API.G_FALSE
       );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO FTE_PO_INTEGRATION_GRP;
             x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE
                  );
             IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
             END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO FTE_PO_INTEGRATION_GRP;
             x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE
                  );
             IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
             END IF;
       WHEN  e_validation_error THEN
             ROLLBACK TO FTE_PO_INTEGRATION_GRP;
             WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
             FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE
                  );
             IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
             END IF;
       WHEN  OTHERS then
             ROLLBACK TO FTE_PO_INTEGRATION_GRP;
             WSH_DEBUG_SV.logmsg(l_module_name,'End of process with error : '||sqlerrm);
             --dbms_output.put_line('Unhandled Exception '||sqlerrm );
             wsh_util_core.default_handler('FTE_PO_INTEGRATION_GRP.GET_ESTIMATED_RATES');
             x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
             WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
             FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE
                  );
             IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
             END IF;
             -- will be removed
END GET_ESTIMATED_RATES;

/*----------------------------------------------------------------------------------------------
    This procedure will be used to get all corresponding Receipt Shipment Lines for the given
   Shipment Header, PO Line id, PO Line location id since
   rcv_shipment_line_id is not populated in WDD due to mismatching receipts against the shipment
   -- Once you get all receipts, will be pro-rated the total cost at po line location level to
   -- all receipts based on the qty
   Input Parameters
       -
       P_SHIPMENT_HEADER_ID   - Shipment header id
       P_PO_LINE_ID           - Po Line ID
       P_PO_LINE_LOCATION_ID  - Po Line location id
       P_TOTAL_COST           - Total Cost at this level to distribute to all receipts based on the qty received
  Out parameters
       X_RCV_SHIP_LINES_TABLE  - Table of receipts
       X_RCV_SHIP_COST_TABLE   - Cost associated to each receipts

-----------------------------------------------------------------------------------------------*/
/* This API will be called only if the shipment does not match with receipts
   and WDD does not contain rcv_shipment_line_id
This procedure will be used to get all receipt shipment lines and recd qty
 for the given shipment header id, po line id, po line location id
 Prorate the cost at po line location level to each receipt lines based on the qty
*/

PROCEDURE get_rcv_shipment_lines ( x_return_status           OUT NOCOPY VARCHAR2,
                               P_SHIPMENT_HEADER_ID      IN  VARCHAR2,
                               P_PO_LINE_ID              IN  NUMBER,
                               P_PO_LINE_LOCATION_ID     IN  NUMBER,
                               P_TOTAL_COST              IN  NUMBER,
                               P_SHIP_QTY_UOM            IN  VARCHAR2,
                               P_SHIP_QTY                IN  NUMBER,
                               X_RCV_SHIP_LINES_TABLE    OUT NOCOPY FTE_PO_INTEGRATION_GRP.fte_number_table,
                               X_RCV_SHIP_COST_TABLE     OUT NOCOPY FTE_PO_INTEGRATION_GRP.fte_number_table) IS

-- Need to verify the item id and qty uom (or unit of measure )
-- get the item id from wdd instead of rsl since it will be same for the same po line location id
-- Get all receipt shipment lines from RCV_SHIPMENT_LINES for the given po_line_id and po_line_location_id
cursor c_get_rcv_shipment_lines (l_shipment_header_id number, l_po_line_id number, l_po_line_loc_id number) IS
select shipment_line_id,
       item_id,
       quantity_received,
       unit_of_measure,
       0 total_cost
from   rcv_shipment_lines
where  shipment_header_id = l_shipment_header_id
  and  po_line_id = l_po_line_id
  and  po_line_location_id = l_po_line_loc_id;

l_total_net_qty number;
--l_debug_on BOOLEAN;
l_uom_code varchar2(3);
l_uom varchar2(25);
h number;

e_validation_error EXCEPTION;

l_item_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_qty_table FTE_PO_INTEGRATION_GRP.fte_number_table;
l_uom_code_table FTE_PO_INTEGRATION_GRP.fte_varchar25_table;
l_rcv_ship_line_id_table FTE_PO_INTEGRATION_GRP.fte_number_table;

l_sub_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'GET_RCV_SHIPMENT_LINES';
--
BEGIN
  --dbms_output.put_line('You are calling GET_RCV_SHIPMENT_LINES API');
/* Moved to global variable
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL
  THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
*/
  OPEN c_get_rcv_shipment_lines(P_SHIPMENT_HEADER_ID,P_PO_LINE_ID,P_PO_LINE_LOCATION_ID);
  FETCH c_get_rcv_shipment_lines BULK COLLECT
      INTO x_rcv_ship_lines_table,
           l_item_id_table,
           l_qty_table,
           l_uom_code_table,
           x_rcv_ship_cost_table;
  close c_get_rcv_shipment_lines;
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_sub_module_name,'cursor c_get_rcv_shipment_lines - number '||
                            'of records found: ', x_rcv_ship_lines_table.COUNT);
  END IF;
  IF nvl(P_SHIP_QTY,0) <= 0 then
     WSH_DEBUG_SV.logmsg(l_sub_module_name,'Total Ship Qty for the PO Line'||p_po_line_id||'-'||P_PO_LINE_LOCATION_ID||
     ' zero qty '||l_total_net_qty);
     --dbms_output.put_line('Total Ship Qty is zero ');
     FND_MESSAGE.SET_NAME('FTE','FTE_EC_SHIP_QTY_ZERO');
    -- x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     --dbms_output.put_line('Total Ship Qty for the given po line id, po line location id is zero ');
  --   raise e_validation_error;
  END IF;
  --  Only if P_TOTAL_COST is > 0 and Ship Qty > 0, distribute the cost to all receipts, otherwise just return all receipts with zero cost
  --
  IF nvl(P_TOTAL_COST,0) > 0 and nvl(P_SHIP_QTY,0) > 0 then
  --{
      -- Initializing the net wt
      l_total_net_qty := P_SHIP_QTY;
      l_uom_code := null;
      l_uom := null;
      --Total Recept qty is replaced with Total Shipment Qty from Shipment lines since Rec qty may not match with Ship.Qty
      --and Total cost needs to be distributed as given below
      h := x_rcv_ship_lines_table.FIRST ;
      WHILE h IS NOT NULL
      LOOP
      --{
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_sub_module_name,'Rct Qty / UOM ',l_qty_table(h)||l_uom_code_table(h));
         END IF;
         -- get the uom code for the given unit of measure
         if l_uom_code_table(h) is not null and (P_SHIP_QTY_UOM <> l_uom_code_table(h)) then
            l_uom := l_uom_code_table(h);
            select uom_code into l_uom_code from MTL_UNITS_OF_MEASURE
            where UNIT_OF_MEASURE = l_uom;
         end if;
         -- Prorate the Total Cost into all receipt lines
         -- Proration logic of the distribution of po line level cost to all related receipts
         -- Proration logic is based on the total shipments qty versus each rec.qty
         --For ex: Total Cost at Po Line loc level is $100.00 (Net Wt - 100 LBS)
           -- Receipt#   QTY 	RATE DISTRIBUTED
           -- Receipt-1	50 EA 	(50/105 * 100) = $47.62
           -- Receipt-2	30 EA	(30/105 * 100) = $28.57
           -- Receipt-3	25 EA	(25/105 * 100) = $23.81
           -- Receipt   Total	105 EA	$100.00
           --
        -- Calculate the cost at each receipt level
        -- Converting UOMs between Shipped Qty and Recd Qty, if different
        IF (P_SHIP_QTY_UOM <> l_uom_code) and nvl(l_qty_table(h),0) > 0 then
           -- Need to verify on this conversion
           l_qty_table(h) := WSH_WV_UTILS.Convert_Uom (l_uom_code,
                                                          P_SHIP_QTY_UOM,
                                                          l_qty_table(h),
                                                          l_item_id_table(h));
        END IF;
        --
        --
        x_rcv_ship_cost_table(h) := (l_qty_table(h)/P_SHIP_QTY) * p_total_cost;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_sub_module_name,'Rct Qty / Converted UOM ',l_qty_table(h)||l_uom_code);
           WSH_DEBUG_SV.log(l_sub_module_name,'Cost allocated for receipt line ',x_rcv_ship_lines_table(h)||
                            ' Qty= '||l_qty_table(h)|| ' / '||l_total_net_qty|| '  Cost is '||x_rcv_ship_cost_table(h));
        END IF;
        --
        h := x_rcv_ship_lines_table.NEXT(h);
      --}
      END LOOP; --End of x_rcv_ship_lines_table Table
  --}
  END IF; -- nvl(P_TOTAL_COST,0) > 0
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   --
  --dbms_output.put_line('End of getting rcv shipment lines for the non-matching shipments ');

  EXCEPTION
       WHEN  e_validation_error THEN
           null;
       WHEN no_data_found then
            WSH_DEBUG_SV.log(l_sub_module_name,'Could not find the UOM Code for the Rct Qty UOM ',l_qty_table(h)||l_uom);
            WSH_DEBUG_SV.log(l_sub_module_name,'Pls query the UOM table to verify the Unit of Measure exist or not',l_uom);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       WHEN others then
        wsh_util_core.default_handler('FTE_PO_INTEGRATION_GRP.GET_RCV_SHIPMENT_LINES API');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --dbms_output.put_line('Unhandled Exception '||sqlerrm );
END GET_RCV_SHIPMENT_LINES;

END FTE_PO_INTEGRATION_GRP;

/
