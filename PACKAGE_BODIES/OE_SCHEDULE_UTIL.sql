--------------------------------------------------------
--  DDL for Package Body OE_SCHEDULE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SCHEDULE_UTIL" AS
/* $Header: OEXUSCHB.pls 120.54.12010000.68 2012/10/04 04:31:06 rahujain ship $ */


/*-----------------------------------------------------------
CONSTANTS and Forward declarations
------------------------------------------------------------*/
G_PKG_NAME             CONSTANT     VARCHAR2(30):='OE_SCHEDULE_UTIL';
G_OVERRIDE_FLAG        VARCHAR2(1)  := 'N';
G_ATP_CHECK_SESSION_ID NUMBER;
G_BINARY_LIMIT         CONSTANT  NUMBER := OE_GLOBALS.G_BINARY_LIMIT; --7827737

/*-- 3288805 -- */ -- moved to spec.
--G_HEADER_ID        NUMBER       := null;
--G_DATE_TYPE        VARCHAR2(30) := null;

--G_ATP_TBL          OE_ATP.atp_tbl_type; -- 2434807 - moved to package spec.

-- INVCONV below procedure not used now because of OPM inventory convergence
/*PROCEDURE get_process_query_quantities
  (   p_org_id       IN  NUMBER
   ,  p_item_id      IN  NUMBER
   ,  p_line_id      IN  NUMBER
, x_on_hand_qty OUT NOCOPY NUMBER

, x_avail_to_reserve OUT NOCOPY NUMBER

  ) ; */

-- Added for ER 6110708
PROCEDURE VALIDATE_ITEM_SUBSTITUTION
(
p_new_inventory_item_id   IN NUMBER,
p_old_inventory_item_id   IN NUMBER,
p_new_ship_from_org_id    IN NUMBER,
p_old_ship_from_org_id    IN NUMBER,
p_old_shippable_flag      IN VARCHAR2
);

/*--------------------------------------------------------
PROCEDURE Print_Time

--------------------------------------------------------*/

PROCEDURE Print_Time(p_msg   IN  VARCHAR2)
IS
  l_time    VARCHAR2(100);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  l_time := to_char (new_time (sysdate, 'PST', 'EST'),
                                 'DD-MON-YY HH24:MI:SS');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  P_MSG || ': '|| L_TIME , 1 ) ;
  END IF;
END Print_Time;

--- Start 2434807 ---
/*--------------------------------------------------------------------------
Procedure Name : Get_Atp_Table_Count
Description    : This procedure returns the count of record in g_atp_tbl
                 along with the contents in the table.
--------------------------------------------------------------------------*/
PROCEDURE Get_Atp_Table_Count(p_atp_tbl  OUT NOCOPY OE_ATP.Atp_Tbl_Type,
                              p_atp_tbl_cnt  OUT  NOCOPY NUMBER)
IS
BEGIN
   p_atp_tbl_cnt := g_atp_tbl.count;
   p_atp_tbl := g_atp_tbl;
END Get_Atp_Table_Count;
--- End 2434807 --


/*--------------------------------------------------------------------------
Procedure Name : Get_Session_Id
Description    : This procedure returns the session_id which will be
                 passed to MRP's ATP API.
--------------------------------------------------------------------------*/
FUNCTION Get_Session_Id
RETURN number
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  SELECT mrp_atp_schedule_temp_s.nextval
  INTO   MRP_SESSION_ID
  from dual;

  return MRP_SESSION_ID;
EXCEPTION
  WHEN OTHERS THEN
    return 0;
END Get_Session_Id;

/*--------------------------------------------------------------------------
Procedure Name : Get_MRP_Session_Id
Description    : This procedure returns the MRP_session_id which will be
                 Used in the pld.
--------------------------------------------------------------------------*/
FUNCTION Get_MRP_Session_Id
RETURN number
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  return MRP_SESSION_ID;
EXCEPTION
   WHEN OTHERS THEN
        return 0;
END Get_MRP_Session_Id;

/*--------------------------------------------------------------------------
Function Name : Get_ATP_CHECK_Session_Id
Description    : This procedure returns the ATP_CHECK_session_id which will be
                 Used in the pld.
--------------------------------------------------------------------------*/
FUNCTION Get_ATP_CHECK_Session_Id
RETURN number
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  return G_ATP_CHECK_SESSION_ID;
EXCEPTION
   WHEN OTHERS THEN
        return 0;
END Get_ATP_CHECK_Session_Id;

FUNCTION Validate_ship_method
(p_new_ship_method IN VARCHAR2,
 p_old_ship_method IN VARCHAR2,
 p_ship_from_org_id IN NUMBER)
RETURN BOOLEAN
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_count NUMBER := 0;
BEGIN

  IF l_debug_level > 0 THEN
      oe_debug_pub.add('Entering Validate_ship_method',1);
      oe_debug_pub.add('p_new_ship_method ' || p_new_ship_method,1);
      oe_debug_pub.add('p_old_ship_method ' || p_old_ship_method,1);
  END IF;

  IF NOT OE_GLOBALS.Equal(p_new_ship_method,
                          p_old_ship_method)  THEN

   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509' THEN

        SELECT count(*)
        INTO   l_count
        FROM   wsh_carrier_services wsh,
               wsh_org_carrier_services wsh_org
        WHERE  wsh_org.organization_id    = p_ship_from_org_id
        AND  wsh.carrier_service_id       = wsh_org.carrier_service_id
        AND  wsh.ship_method_code         = p_new_ship_method
        AND  wsh_org.enabled_flag         = 'Y';

   ELSE

        SELECT count(*)
        INTO l_count
        FROM    wsh_carrier_ship_methods
        WHERE   ship_method_code = p_new_ship_method
        AND   organization_id = p_ship_from_org_id;

   END IF;

       IF l_debug_level > 0 THEN
         oe_debug_pub.add('l_count ' || l_count,1);
       END IF;

       IF l_count  = 0 THEN
          RETURN FALSE;
       END IF;

 END IF;


 RETURN TRUE;

EXCEPTION

  WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'oe_schedule_util.validate_ship_method'
            );
        END IF;
        RETURN FALSE;

END Validate_ship_method;
-- Pack J
/*--------------------------------------------------------------------------
PROCEDURE Name : validate_with_LAD
Description    : This API will check schedule ship date or schedule arrival date
                 with latest acceptable date and raise error/warning based on flag
-------------------------------------------------------------------------- */
PROCEDURE validate_with_LAD
( p_header_id IN NUMBER
 ,p_latest_acceptable_date IN DATE
 ,p_schedule_ship_date     IN DATE
 ,p_schedule_arrival_date  IN DATE
)
IS
  l_order_date_type_code  VARCHAR2(20);
  l_return_status  BOOLEAN := FALSE;
  l_lad_flag        VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING VALIDATE_WITH_LAD WITH LAD FLAG ' , 1 ) ;
   END IF;
   l_order_date_type_code := NVL(Get_Date_Type(p_header_id),'SHIP');

   -- To check violation of LAD when parameter set to - Ignore LAD
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CHECKING FOR LAD ' , 1 ) ;
   END IF;
   l_lad_flag := Oe_Sys_Parameters.Value('LATEST_ACCEPTABLE_DATE_FLAG');
   IF l_lad_flag = 'I' THEN
      IF ((l_order_date_type_code = 'SHIP'
        AND p_schedule_ship_date
                            > p_latest_acceptable_date)
      OR (l_order_date_type_code = 'ARRIVAL'
        AND p_schedule_arrival_date
                            > p_latest_acceptable_date)) THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LAD VIOLATED ' , 1 ) ;
         END IF;
         Fnd_Message.set_name('ONT','ONT_SCH_LAD_VIOLATE');
         Oe_Msg_Pub.Add;
      END IF;
   /* -- 3349770 this will be only validated when user enters manually.
   ELSIF l_lad_flag = 'H' THEN
      IF ((l_order_date_type_code = 'SHIP'
        AND p_schedule_ship_date
                           > p_latest_acceptable_date)
      OR (l_order_date_type_code = 'ARRIVAL'
        AND p_schedule_arrival_date
                            > p_latest_acceptable_date)) THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'SCHEDULE DATE EXCEEDS LAD ' , 1 ) ;
           END IF;
           Fnd_Message.set_name('ONT','ONT_SCH_LAD_SCH_FAILED');
           Oe_Msg_Pub.Add;
           RAISE FND_API.G_EXC_ERROR;
      END IF;
   */
   END IF;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING VALIDATE_WITH_LAD' , 1 ) ;
   END IF;
END validate_with_LAD;
-- End Pack J
/*--------------------------------------------------------------------------
Procedure Name : Insert_Mandatory_Components
Description    : This procedure is called from the form side, when the user
                 clicks on global availability button and the item to check
                 global availability is an ATO Model. We insert the mandatory
                 components in MRP_ATP_SCHEDULE_TEMP for global availability.
--------------------------------------------------------------------------*/
Procedure Insert_Mandatory_Components
(p_order_number           IN  NUMBER,
p_ato_line_id             IN  NUMBER,
p_customer_name           IN  VARCHAR2,
p_customer_location       IN  VARCHAR2,
p_arrival_set_name        IN  VARCHAR2,
p_ship_set_name           IN  VARCHAR2,
p_ship_set_id             IN  NUMBER,
p_requested_ship_date     IN  DATE,
p_requested_arrival_date  IN  DATE,
p_session_id              IN  NUMBER,
p_instance_id             IN  NUMBER,
p_insert_code             IN  NUMBER,
x_return_status OUT NOCOPY VARCHAR2

)
IS
l_model_line_rec          OE_ORDER_PUB.line_rec_type;
l_model_rec               MRP_ATP_PUB.ATP_Rec_Typ;
l_smc_rec                 MRP_ATP_PUB.ATP_Rec_Typ;
l_ship_set                VARCHAR2(30);
lTableName                VARCHAR2(30);
lMessageName              VARCHAR2(30);
lErrorMessage             VARCHAR2(2000);
l_result                  NUMBER := 1;

l_scenario_id             NUMBER := -1;
l_line_id                 NUMBER;
l_header_id               NUMBER;
l_ato_line_id             NUMBER;
l_inventory_item_id       NUMBER;
l_ordered_item            VARCHAR2(2000);
l_sold_to_org_id          NUMBER;
l_ship_to_org_id          NUMBER;
l_ship_from_org_id        NUMBER;
l_quantity_ordered        NUMBER;
l_uom_code                VARCHAR2(3);
l_latest_acceptable_date  DATE;
l_line_number             NUMBER;
l_shipment_number         NUMBER;
l_option_number           NUMBER;
l_delivery_lead_time      NUMBER;
l_promise_date            DATE;
l_project_id              NUMBER;
l_task_id                 NUMBER;
l_ship_method             VARCHAR2(30) := null;
l_demand_class            VARCHAR2(30) := null;
l_ship_set_id             NUMBER;
l_arrival_set_id          NUMBER;
l_ship_method_text        VARCHAR2(80);
l_project_number          NUMBER;
l_task_number             NUMBER;
l_st_atp_lead_time        NUMBER := 0;
l_order_number            NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


   IF NOT(OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
   AND  MSC_ATP_GLOBAL.GET_APS_VERSION = 10 ) THEN

      SAVEPOINT insert_mand_comp;

--      l_model_line_rec := OE_LINE_UTIL.Query_Row(p_ato_line_id);

    OE_Line_Util.Query_Row(p_line_id  => p_ato_line_id,
                                 x_line_rec => l_model_line_rec);

       l_st_atp_lead_time :=
          Get_Lead_Time
            (p_ato_line_id      => l_model_line_rec.ato_line_id,
             p_ship_from_org_id => l_model_line_rec.ship_from_org_id);

      l_model_rec.Inventory_Item_Id := MRP_ATP_PUB.number_arr
                            (l_model_line_rec.Inventory_Item_Id);

      l_model_rec.Source_Organization_Id := MRP_ATP_PUB.number_arr
                            (l_model_line_rec.ship_from_org_id);

      l_model_rec.Identifier := MRP_ATP_PUB.number_arr
                            (l_model_line_rec.line_id);

      l_model_rec.Calling_Module := MRP_ATP_PUB.number_arr
                            (660);

      l_model_rec.Customer_Id := MRP_ATP_PUB.number_arr
                            (l_model_line_rec.sold_to_org_id);

      l_model_rec.Customer_Site_Id := MRP_ATP_PUB.number_arr
                            (l_model_line_rec.ship_to_org_id);

      l_model_rec.Destination_Time_Zone := MRP_ATP_PUB.char30_arr
                            (null);

      l_model_rec.Quantity_Ordered := MRP_ATP_PUB.number_arr
                            (l_model_line_rec.ordered_quantity);

      l_model_rec.Quantity_UOM := MRP_ATP_PUB.char3_arr
                            (l_model_line_rec.order_quantity_uom);

      l_model_rec.Earliest_Acceptable_Date := MRP_ATP_PUB.date_arr
                            (l_model_line_rec.Earliest_Acceptable_Date);

      l_model_rec.Requested_Ship_Date := MRP_ATP_PUB.date_arr
                            (l_model_line_rec.request_date);

      l_model_rec.Requested_Arrival_Date := MRP_ATP_PUB.date_arr
                            (l_model_line_rec.request_date);

      l_model_rec.Latest_Acceptable_Date := MRP_ATP_PUB.date_arr
                            (l_model_line_rec.Latest_Acceptable_Date);

      l_model_rec.Delivery_Lead_Time := MRP_ATP_PUB.number_arr
                            (l_model_line_rec.Delivery_Lead_Time);
      l_model_rec.Atp_lead_Time := MRP_ATP_PUB.number_arr
                            (l_st_atp_lead_time);

      l_model_rec.Freight_Carrier := MRP_ATP_PUB.char30_arr
                            (l_model_line_rec.Freight_Carrier_Code);

      l_model_rec.Ship_Method := MRP_ATP_PUB.char30_arr
                            (null);

      l_model_rec.Demand_Class := MRP_ATP_PUB.char30_arr
                            (l_model_line_rec.Demand_Class_Code);

      l_model_rec.Ship_Set_Name := MRP_ATP_PUB.char30_arr
                            (l_model_line_rec.ship_set_id);

      l_model_rec.Arrival_Set_Name := MRP_ATP_PUB.char30_arr
                            (l_model_line_rec.arrival_set_id);

      l_model_rec.Override_Flag := MRP_ATP_PUB.char1_arr
                            (null);

      l_model_rec.Ship_Date := MRP_ATP_PUB.date_arr
                            (null);

      l_model_rec.Available_Quantity := MRP_ATP_PUB.number_arr
                            (null);

      l_model_rec.Requested_Date_Quantity := MRP_ATP_PUB.number_arr
                            (null);

      l_model_rec.Group_Ship_Date := MRP_ATP_PUB.date_arr
                            (null);

      l_model_rec.Group_Arrival_Date := MRP_ATP_PUB.date_arr
                            (null);

      l_model_rec.Vendor_Id := MRP_ATP_PUB.number_arr
                            (null);

      l_model_rec.Vendor_Site_Id := MRP_ATP_PUB.number_arr
                            (null);

      l_model_rec.Insert_Flag := MRP_ATP_PUB.number_arr
                            (null);

      l_model_rec.Error_Code := MRP_ATP_PUB.number_arr
                            (null);

      l_model_rec.Message := MRP_ATP_PUB.char2000_arr
                            (null);

      l_model_rec.Action  := MRP_ATP_PUB.number_arr
                            (null);

      l_order_number := Get_order_number(l_model_line_rec.header_id);

      l_model_rec.Order_number  := MRP_ATP_PUB.number_arr
                            (l_order_number);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  '1.. CALLING CTO GET_BOM_MANDATORY_COMPS' , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
      END IF;

      BEGIN
      l_result  :=  CTO_CONFIG_ITEM_PK.GET_MANDATORY_COMPONENTS
                      (p_ship_set           => l_model_rec,
                       p_organization_id    => null,
                       p_inventory_item_id  => null,
                       x_smc_rec            => l_smc_rec,
                       xErrorMessage        => lErrorMessage,
                       xMessageName         => lMessageName,
                       xTableName           => lTableName);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  '1. AFTER CALLING CTO API : ' || L_RESULT , 0.5 ) ; -- debug level changed to 0.5 for bug 13435459
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'COUNT IS: ' || L_SMC_REC.INVENTORY_ITEM_ID.COUNT , 1 ) ;
      END IF;

      EXCEPTION
         WHEN OTHERS THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'CTO API RETURNED AN UNEXPECTED ERROR' ) ;
              END IF;
              l_result := 0;
      END;

      IF l_result = 1 AND
         l_smc_rec.Identifier.count >= 1 THEN

                              IF l_debug_level  > 0 THEN
                                  oe_debug_pub.add(  'SMC COUNT IS : ' || L_SMC_REC.IDENTIFIER.COUNT , 1 ) ;
                              END IF;

         FOR J IN 1..l_smc_rec.Identifier.count LOOP
             l_line_id                 := l_smc_rec.Identifier(J);
             l_header_id               := l_model_line_rec.header_id;
             l_ato_line_id             := l_model_line_rec.ato_line_id;
             l_inventory_item_id       := l_smc_rec.Inventory_Item_Id(J);
             l_ordered_item            := null;
             l_sold_to_org_id          := l_model_line_rec.sold_to_org_id;
             l_ship_to_org_id          := l_model_line_rec.ship_to_org_id;
             l_ship_from_org_id        := l_model_line_rec.ship_from_org_id;
             l_demand_class            := l_model_line_rec.demand_class_code;
             l_quantity_ordered        := l_smc_rec.Quantity_Ordered(J);
             l_uom_code                := l_smc_rec.Quantity_UOM(J);
             l_latest_acceptable_date  :=
                                 l_model_line_rec.latest_acceptable_date;
             l_line_number             := l_model_line_rec.line_number;
             l_shipment_number         := l_model_line_rec.line_number;
             l_option_number           := l_model_line_rec.option_number;
             l_delivery_lead_time      := l_model_line_rec.delivery_lead_time;
             l_promise_date            := l_model_line_rec.promise_date;
             l_project_id              := l_model_line_rec.project_id;
             l_task_id                 := l_model_line_rec.task_id;
             l_ship_method             := l_model_line_rec.shipping_method_code;
             l_arrival_set_id          := l_model_line_rec.arrival_set_id;

             l_ship_method_text        := l_ship_method;
             l_project_number          := l_project_id;
             l_task_number             := l_task_id;

             IF l_inventory_item_id is not null AND
                l_ship_from_org_id is not null
             THEN
                BEGIN

                  SELECT concatenated_segments
                  INTO  l_ordered_item
                  FROM  mtl_system_items_vl
                  WHERE inventory_item_id = l_inventory_item_id
                  AND organization_id = l_ship_from_org_id;

                EXCEPTION
                  WHEN OTHERS THEN
                     null;
                END;

             END IF;


            INSERT INTO MRP_ATP_SCHEDULE_TEMP
            (INVENTORY_ITEM_ID,
          SR_INSTANCE_ID,
             SOURCE_ORGANIZATION_ID,
             CUSTOMER_ID,
             CUSTOMER_SITE_ID,
             DESTINATION_TIME_ZONE,
             QUANTITY_ORDERED,
             UOM_CODE,
             REQUESTED_SHIP_DATE,
             REQUESTED_ARRIVAL_DATE,
             LATEST_ACCEPTABLE_DATE,
             DELIVERY_LEAD_TIME,
             FREIGHT_CARRIER,
             INSERT_FLAG,
             SHIP_METHOD,
             DEMAND_CLASS,
             SHIP_SET_NAME,
             SHIP_SET_ID,
             ARRIVAL_SET_NAME,
             ARRIVAL_SET_ID,
             ATP_LEAD_TIME,
             OVERRIDE_FLAG,
             SESSION_ID,
             ORDER_HEADER_ID,
             ORDER_LINE_ID,
             INVENTORY_ITEM_NAME,
             SOURCE_ORGANIZATION_CODE,
             ORDER_LINE_NUMBER,
             SHIPMENT_NUMBER,
             OPTION_NUMBER,
             PROMISE_DATE,
             CUSTOMER_NAME,
             CUSTOMER_LOCATION,
             OLD_LINE_SCHEDULE_DATE,
             OLD_SOURCE_ORGANIZATION_CODE,
             CALLING_MODULE,
             ACTION,
             STATUS_FLAG,
             SCENARIO_ID,
             ORDER_NUMBER,
             OLD_SOURCE_ORGANIZATION_ID,
             OLD_DEMAND_CLASS,
             PROJECT_ID,
             TASK_ID,
             PROJECT_NUMBER,
             TASK_NUMBER,
             SHIP_METHOD_TEXT
             )
            VALUES
            (l_inventory_item_id,
             p_instance_id,
             null,
             l_sold_to_org_id, -- CUSTOMER_ID
             l_ship_to_org_id, -- CUSTOMER_SITE_ID
             null,  -- DESTINATION_TIME_ZONE
             l_quantity_ordered,
             l_uom_code,
             p_requested_ship_date,
             p_requested_arrival_date,
             l_latest_acceptable_date,
             l_delivery_lead_time,
             null, -- FREIGHT_CARRIER,
             p_insert_code,
             l_ship_method,
             l_demand_class,
             p_ship_set_name,
             p_ship_set_id,
             p_arrival_set_name,
             l_arrival_set_id,
             l_st_atp_lead_time,
             null, -- OVERRIDE_FLAG
             p_session_id,
             l_header_id,
             l_line_id,
             l_ordered_item, -- l_INVENTORY_ITEM_NAME,
             null, -- l_SOURCE_ORGANIZATION_CODE,
             l_line_number,
             l_shipment_number,
             l_option_number,
             l_promise_date,
             p_customer_name,
             p_customer_location,
             null, -- l_OLD_LINE_SCHEDULE_DATE,
             null, -- l_OLD_SOURCE_ORGANIZATION_CODE,
             null, -- l_CALLING_MODULE,
             100,
             4, -- l_STATUS_FLAG,
             l_scenario_id,
             p_order_number,
             l_ship_from_org_id,
             l_demand_class,
             l_project_id,
             l_task_id,
             l_project_number,
             l_task_number,
             l_ship_method_text
             );

         END LOOP;
      END IF;

   END IF; -- GOP Code control
   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT insert_mand_comp;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Insert_Mandatory_Components;

/*--------------------------------------------------------------------------
Procedure Name : Update_PO
Description    : This procedure is called whenever there is a change to
                 schedule_ship_date on an internal order. PO has a callback
                 we need to call to notify them of this change.
--------------------------------------------------------------------------*/

Procedure Update_PO(p_schedule_ship_date       IN DATE,
                    p_source_document_id       IN VARCHAR2,
                    p_source_document_line_id  IN VARCHAR2)
IS
po_result    BOOLEAN;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_SCHEDULE_UTIL.UPDATE_PO' , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
  END IF;

  -- Call po if internal req and quantity is changed

  IF p_source_document_line_id IS NOT NULL THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'DATE ' || P_SCHEDULE_SHIP_DATE , 2 ) ;
       END IF;

       po_result := po_supply.po_req_supply(
                       p_docid         => p_source_document_id,
                       p_lineid        => p_source_document_line_id,
                       p_shipid        => p_source_document_line_id,
                       p_action        => 'Update_Req_Line_Date',
                       p_recreate_flag => FALSE,
                       p_qty           => null,
                       p_receipt_date  => p_schedule_ship_date);
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_SCHEDULE_UTIL.UPDATE_PO' , 0.5 ) ;   -- debug level changed to 0.5 for bug 13435459
  END IF;

EXCEPTION
    WHEN OTHERS THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXCEPTION IN UPDATE_PO' , 2 ) ;
         END IF;
END Update_PO;

/*---------------------------------------------------------------------
Function Name : Within_Rsv_Time_Fence
Description   : The function returns:
                TRUE:  If the Schedule_Ship_Date is within the
                       time fence of the system date. The time fence
                       is defined in the profile option
                       ONT_RESERVATION_TIME_FENCE.
                FALSE: If the Schedule_Ship_Date is note within the
                       time fence of the system date.
                The date part of the dates (and not the time) are compared
                to return the value.

                If schedule_date - SYSDATE < reservation_time_fence
                we will return TRUE, else will return FALSE
--------------------------------------------------------------------- */
Function Within_Rsv_Time_Fence(p_schedule_ship_date IN DATE,
                p_org_id IN NUMBER) --4689197
RETURN BOOLEAN
IS
  l_rsv_time_fence_profile VARCHAR2(30);
  l_rsv_time_fence         NUMBER;
  l_time_to_ship           NUMBER;
  l_sysdate                DATE;
  l_schedule_ship_date     DATE;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  l_rsv_time_fence_profile :=
         Oe_Sys_Parameters.Value('ONT_RESERVATION_TIME_FENCE', p_org_id);

  BEGIN
    l_rsv_time_fence := to_number(l_rsv_time_fence_profile);
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IGNORING RESERVATION TIME FENCE' , 1 ) ;
      END IF;
      l_rsv_time_fence := null;
  END;

  l_sysdate            := trunc(SYSDATE);
  l_schedule_ship_date := trunc(p_schedule_ship_date);

  l_time_to_ship := to_number(l_schedule_ship_date -l_sysdate);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_TIME_TO_SHIP ' || L_TIME_TO_SHIP , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_RSV_TIME_FENCE ' || L_RSV_TIME_FENCE , 1 ) ;
  END IF;

/* Commented the following code to fix the bug 3109349

  IF l_time_to_ship < 0 THEN
    -- We don't know what this means. Schedule ship date is already
    -- past due. So we will not reserve any inventory for this line.
     RETURN FALSE;
  ELSIF l_time_to_ship <= l_rsv_time_fence THEN
*/

  IF l_time_to_ship <= l_rsv_time_fence THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

END Within_Rsv_Time_Fence;
/*---------------------------------------------------------------------
Function Name : SMC_OVERRIDDEN
Description   : This function retuns true if one of the line in a smc model
                is overridden. This will be used in procedure load_mrp_request.

-----------------------------------------------------------------------*/
Function SMC_OVERRIDDEN(p_top_model_line_id IN NUMBER)
RETURN BOOLEAN
IS
 l_overridden VARCHAR2(1) := 'N';
BEGIN

   SELECT 'Y'
   INTO   l_overridden
   FROM   oe_order_lines_all
   WHERE  top_model_line_id = p_top_model_line_id
   AND    open_flag = 'Y'
   AND    override_atp_date_code = 'Y'
   AND    rownum < 2;

   IF l_overridden = 'Y' THEN
      RETURN TRUE;
   ELSE
     RETURN FALSE;
   END IF;

EXCEPTION
 WHEN OTHERS THEN

   RETURN FALSE;
END SMC_OVERRIDDEN;
/*---------------------------------------------------------------------
Function Name : SET_OVERRIDDEN
Description   : This function retuns true if one of the line in a set
                is overridden. This will be used in log_set_request procedure.

-----------------------------------------------------------------------*/
Function SET_OVERRIDDEN(p_header_id      IN NUMBER
                       ,p_ship_set_id    IN NUMBER
                       ,p_arrival_set_id IN NUMBER)
RETURN BOOLEAN
IS
 l_overridden VARCHAR2(1) := 'N';
BEGIN



   SELECT 'Y'
   INTO   l_overridden
   FROM   oe_order_lines_all
   WHERE  header_id = p_header_id
   AND    (ship_set_id = p_ship_set_id
   OR     arrival_set_id = p_arrival_set_id)
   AND    override_atp_date_code = 'Y'
   AND    rownum < 2;

   IF l_overridden = 'Y' THEN
      RETURN TRUE;
   ELSE
     RETURN FALSE;
   END IF;

EXCEPTION
 WHEN OTHERS THEN

   RETURN FALSE;
END SET_OVERRIDDEN;
/*---------------------------------------------------------------------
Procedure Name : Reserve_line
Description    : This API calls Inventory's APIs to reserve.
--------------------------------------------------------------------- */

Procedure Reserve_line
( p_line_rec              IN  OE_ORDER_PUB.Line_Rec_Type
 ,p_quantity_to_reserve   IN  NUMBER
 ,p_quantity2_to_reserve   IN  NUMBER  DEFAULT NULL -- INVCONV
 ,p_rsv_update            IN  BOOLEAN DEFAULT FALSE
,x_return_status OUT NOCOPY VARCHAR2)

IS
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(2000);
l_reservation_rec     inv_reservation_global.mtl_reservation_rec_type;
l_quantity_reserved   NUMBER;
l_quantity2_reserved   NUMBER;  -- INVCONV
l_rsv_id              NUMBER;
l_reservable_type     NUMBER;
l_dummy_sn            inv_reservation_global.serial_number_tbl_type;
l_buffer              VARCHAR2(2000);

l_substitute_flag BOOLEAN; -- Added for ER 6110708

-- subinventory
l_revision_code NUMBER;
l_lot_code      NUMBER;
l_serial_code   NUMBER;
l_do_partial_reservation  VARCHAR2(1) := FND_API.G_FALSE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING RESERVE LINE :' || P_QUANTITY_TO_RESERVE , 1 ) ;
         oe_debug_pub.add(  'ENTERING RESERVE LINE qty2 :' || P_QUANTITY2_TO_RESERVE , 1 ) ;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT RESERVABLE_TYPE
   INTO   l_reservable_type
   FROM   MTL_SYSTEM_ITEMS
   WHERE  INVENTORY_ITEM_ID = p_line_rec.inventory_item_id
   AND    ORGANIZATION_ID = p_line_rec.ship_from_org_id;

   IF l_reservable_type = 1 THEN

       --Bug 13082802
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'BEFORE FULFILLED QTY CHECK' , 2 ) ;
       END IF;

       IF (p_line_rec.fulfilled_quantity is not null)
          AND (p_line_rec.fulfilled_quantity <> FND_API.G_MISS_NUM) THEN

         -- The line is Fulfilled. Cannot reserve it
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE FULFILLED, CANNOT RESERVE LINE. FULFILLED QTY:' || p_line_rec.fulfilled_quantity , 1 ) ;
         END IF;

         FND_MESSAGE.SET_NAME('ONT','OE_RSV_LINE_FULFILLED');
         OE_MSG_PUB.Add;

         RAISE FND_API.G_EXC_ERROR;

       END IF;
       --Bug 13082802

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'L_QTY_TO_RESERVE : ' || P_QUANTITY_TO_RESERVE , 3 ) ;
       END IF;
       --newsub check if item is under lot/revision/serial control
       IF  p_line_rec.subinventory is not null
       AND p_line_rec.subinventory <> FND_API.G_MISS_CHAR THEN
           BEGIN
              SELECT revision_qty_control_code, lot_control_code,
                     serial_number_control_code
              INTO   l_revision_code, l_lot_code,
                     l_serial_code
              FROM   mtl_system_items
              WHERE  inventory_item_id = p_line_rec.inventory_item_id
              AND    organization_id   = p_line_rec.ship_from_org_id;

           EXCEPTION
               WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                fnd_message.set_name('ONT', 'OE_INVALID_ITEM_WHSE');
                OE_MSG_PUB.Add;
           END;

           IF l_revision_code = 2
           OR l_lot_code = 2
           THEN
              -- 2 == YES
              FND_MESSAGE.SET_NAME('ONT', 'OE_SUBINV_NOT_ALLOWED');
              OE_MSG_PUB.Add;
              IF  p_line_rec.Schedule_action_code =  OESCH_ACT_RESERVE THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 x_return_status     := FND_API.G_RET_STS_SUCCESS;
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'BEFORE RETURN' , 3 ) ;
                 END IF;
                 RETURN;
              END IF;

           END IF;
       END IF;
       --end newsub




       Load_INV_Request
       ( p_line_rec              => p_line_rec
       , p_quantity_to_reserve   => p_quantity_to_reserve
       , p_quantity2_to_reserve   => p_quantity2_to_reserve -- INVCONV
       , x_reservation_rec       => l_reservation_rec);

       -- Call INV with action = RESERVE

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CALLING INVS CREATE_RESERVATION' , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
       END IF;
       -- Pack J
       -- Check for partial reservation flag
       IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
         AND Oe_Sys_Parameters.Value('PARTIAL_RESERVATION_FLAG') = 'Y' THEN
         l_do_partial_reservation := FND_API.G_TRUE;
       END IF;
       l_quantity2_reserved :=NULL;

       /* Added the below code for ER 6110708 */
       IF OE_SCHEDULE_UTIL.OESCH_ITEM_IS_SUBSTITUTED = 'Y' THEN
         l_substitute_flag := TRUE;
       ELSE
         l_substitute_flag := FALSE;
       END IF;
       /* End of code changes for ER 6110708 */

        IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'before  CREATE RESERVATION ',  1 ) ;
         oe_debug_pub.add(  ' qty2 = ' || l_reservation_rec.secondary_reservation_quantity , 1 ) ;
         oe_debug_pub.add(  ' uom2 = ' || l_reservation_rec.secondary_uom_code , 1 ) ;


         END IF;

       -- p_partial_rsv_exists will be TRUE if reservation get increased
       inv_reservation_pub.create_reservation
       (
        p_api_version_number        => 1.0
      , p_init_msg_lst              => FND_API.G_TRUE
      , x_return_status             => x_return_status
      , x_msg_count                 => l_msg_count
      , x_msg_data                  => l_msg_data
      , p_rsv_rec                   => l_reservation_rec
      , p_serial_number             => l_dummy_sn
      , x_serial_number             => l_dummy_sn
      , p_partial_reservation_flag  => l_do_partial_reservation  --FND_API.G_FALSE --Pack J
      , p_force_reservation_flag    => FND_API.G_FALSE
      , p_validation_flag           => FND_API.G_TRUE
      , x_quantity_reserved         => l_quantity_reserved
      , x_secondary_quantity_reserved  => l_quantity2_reserved -- INVCONV
      , x_reservation_id            => l_rsv_id
      , p_partial_rsv_exists        => p_rsv_update
      , p_substitute_flag           => l_substitute_flag  -- Added for ER 6110708
      );

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  '2. AFTER CALLING CREATE RESERVATION' || X_RETURN_STATUS , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
      END IF;

      -- Bug No:2097933
      -- If the Reservation was succesfull we set
      -- the package variable to "Y".
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
         OESCH_PERFORMED_RESERVATION := 'Y';
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         -- 4091185
         -- Messages are being handled in exceptions block
         -- oe_msg_pub.transfer_msg_stack;
         -- l_msg_count:=OE_MSG_PUB.COUNT_MSG;
         -- for I in 1..l_msg_count loop
         --     l_msg_data := OE_MSG_PUB.Get(I,'F');
         --     IF l_debug_level  > 0 THEN
         --         oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
         --     END IF;
         -- end loop;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          -- 4091185
          oe_msg_pub.transfer_msg_stack(p_type => 'WARNING');
          l_msg_count:=OE_MSG_PUB.COUNT_MSG;
          for I in 1..l_msg_count loop
              l_msg_data := OE_MSG_PUB.Get(I,'F');
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
              END IF;
          end loop;
          IF p_line_rec.Schedule_action_code = OESCH_ACT_RESERVE THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSE
             x_return_status := FND_API.G_RET_STS_SUCCESS;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'UNABLE TO RESERVE' , 2 ) ;
             END IF;
          END IF;

       END IF;

   END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER CALLING INVS CREATE_RESERVATION' || X_RETURN_STATUS , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
     END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     oe_msg_pub.transfer_msg_stack;
     l_msg_count:=OE_MSG_PUB.COUNT_MSG;
     for I in 1..l_msg_count loop
        l_msg_data := OE_MSG_PUB.Get(I,'F');
        -- 4091185
        -- oe_msg_pub.transfer_msg_stack has already added messages.
        -- oe_msg_pub.add_text(l_msg_data);
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INV : ' || L_MSG_DATA , 2 ) ;
        END IF;
     end loop;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Reserve_line'
       );
    END IF;

END Reserve_Line;
/*---------------------------------------------------------------------
Procedure Name : Unreserve_Line
Description    : This API calls Inventory's APIs to Unreserve. It first
                 queries the reservation records, and then calls
                 delete_reservations until the p_quantity_to_unreserve
                 is satisfied.
--------------------------------------------------------------------- */

Procedure Unreserve_Line
( p_line_rec              IN  OE_ORDER_PUB.Line_Rec_Type
 ,p_old_ship_from_org_id IN NUMBER DEFAULT NULL -- 6628134
 ,p_quantity_to_unreserve IN  NUMBER
 ,p_quantity2_to_unreserve IN  NUMBER  DEFAULT NULL -- INVCONV
,x_return_status OUT NOCOPY VARCHAR2)

IS
  l_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
  l_rsv_new_rec           inv_reservation_global.mtl_reservation_rec_type;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(240);
  l_rsv_id                NUMBER;
  l_rsv_tbl               inv_reservation_global.mtl_reservation_tbl_type;
  l_count                 NUMBER;
  l_dummy_sn              inv_reservation_global.serial_number_tbl_type;
  l_qty_to_unreserve      NUMBER;
  l_source_code           VARCHAR2(40) := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
  l_sales_order_id        NUMBER;
  l_x_error_code          NUMBER;
  l_lock_records          VARCHAR2(1);
  l_sort_by_req_date      NUMBER ;
  l_buffer                VARCHAR2(2000);

   l_quantity2_to_UNreserve NUMBER; -- INVCONV

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING UNRESERVE LINE' , 3 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'QUANTITY TO UNRESERVE : ' || P_QUANTITY_TO_UNRESERVE , 3 ) ;
            oe_debug_pub.add(  'QUANTITY2 TO UNRESERVE : ' || P_QUANTITY2_TO_UNRESERVE , 3 ) ;
  END IF;

  /* Bug 6335352
     OM will handle Resevrations both before and after Shipping Interface is done.
  IF nvl(p_line_rec.shipping_interfaced_flag,'N') = 'Y' THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LINE HAS BEEN SHIPPING INTERFACED' , 3 ) ;
     END IF;
     goto end_of_loop;
  END IF;
  */
  -- Start 2595661
  --  All codes except shipping interface check have been moved to Procedure Do_Unreserve

  l_quantity2_to_UNreserve := p_quantity2_to_UNreserve; -- INVCONV
  IF p_quantity2_to_UNreserve = 0 -- INVCONV
        then
          l_quantity2_to_UNreserve := null;
  END IF;

  Do_Unreserve
        ( p_line_rec               => p_line_rec
        , p_quantity_to_unreserve  => p_quantity_to_unreserve
        , p_quantity2_to_unreserve  => l_quantity2_to_unreserve -- INVCONV
        , p_old_ship_from_org_id    => p_old_ship_from_org_id -- 6628134
        , x_return_status          => x_return_status);
  -- End 2595661

  <<end_of_loop>>

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING UNRESERVE_LINES' , 3 ) ;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Unreserve_line'
       );
    END IF;

END Unreserve_Line;



/* ---------------------------------------------------------------
FUNCTION  : Valid_Set_Addition
Description: This function is called to make sure the model/kit which is
             getting added to set should not have lines overridden for
             differenr dates.
 ---------------------------------------------------------------*/
FUNCTION Valid_Set_Addition(p_top_model_line_id IN NUMBER ,
                            p_set_type          IN VARCHAR2)
RETURN BOOLEAN
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_count       NUMBER := 0;
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'p_top_model_line_id :' || p_top_model_line_id , 2 ) ;
       oe_debug_pub.add(  'p_set_type :' || P_SET_TYPE , 2 ) ;
   END IF;


   IF p_set_type = 'SHIP_SET' THEN

     SELECT count(a.line_id)
     INTO   l_count
     FROM oe_order_lines_all a,
          oe_order_lines_all b
     WHERE a.top_model_line_id = p_top_model_line_id
     AND a.top_model_line_id = b.top_model_line_id
     AND a.override_atp_date_code = 'Y'
     AND b.override_atp_date_code = 'Y'
     AND a.schedule_ship_date <> b.schedule_ship_date;

   ELSIF p_set_type = 'ARRIVAL_SET' THEN

     SELECT count(a.line_id)
     INTO   l_count
     FROM oe_order_lines_all a,
          oe_order_lines_all b
     WHERE a.top_model_line_id = p_top_model_line_id
     AND a.top_model_line_id = b.top_model_line_id
     AND a.override_atp_date_code = 'Y'
     AND b.override_atp_date_code = 'Y'
     AND a.schedule_arrival_date <> b.schedule_arrival_date;

   END IF;

   IF l_debug_level  > 0 THEN
    oe_debug_pub.add('count: ' || l_count,2);
   END IF;
   IF l_count = 0 THEN

      RETURN TRUE;

   ELSE

      RETURN FALSE;

   END IF;
EXCEPTION

  WHEN OTHERS THEN

   IF l_debug_level  > 0 THEN
    oe_debug_pub.add('return false from Valid_Set_Addition');
   END IF;
    RETURN FALSE;

END Valid_Set_Addition;
/* ---------------------------------------------------------------
FUNCTION  : Set_Attr_Matched
Description: This function is called to compare set and line record
             for set attributes. This will help in avoiding additional call
             to MRP if the line is scheduled for a same set attributes.
 ---------------------------------------------------------------*/
FUNCTION Set_Attr_Matched(p_set_ship_from_org_id IN NUMBER ,
                          p_line_ship_from_org_id IN NUMBER,
                          p_set_ship_to_org_id IN NUMBER,
                          p_line_ship_to_org_id IN NUMBER,
                          p_set_schedule_ship_date IN DATE,
                          p_line_schedule_ship_date IN DATE,
                          p_set_arrival_date IN DATE,
                          p_line_arrival_date IN DATE,
                          p_set_shipping_method_code IN VARCHAR2,
                          p_line_shipping_method_code IN VARCHAR2,
                          p_set_type IN VARCHAR2)
RETURN BOOLEAN
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_SET_TYPE :' || P_SET_TYPE , 2 ) ;
       oe_debug_pub.add(  'P_LINE_SHIP_FROM_ORG_ID :' || P_LINE_SHIP_FROM_ORG_ID , 2 ) ;
       oe_debug_pub.add(  'P_SET_SHIP_FROM_ORG_ID :' || P_SET_SHIP_FROM_ORG_ID , 2 ) ;
       oe_debug_pub.add(  'P_LINE_SHIP_TO_ORG_ID :' || P_LINE_SHIP_TO_ORG_ID , 2 ) ;
       oe_debug_pub.add(  'P_SET_SHIP_TO_ORG_ID :' || P_SET_SHIP_TO_ORG_ID , 2 ) ;
       oe_debug_pub.add(  'P_LINE_SCHEDULE_SHIP_DATE :' || P_LINE_SCHEDULE_SHIP_DATE , 2 ) ;
       oe_debug_pub.add(  'P_SET_SCHEDULE_SHIP_DATE :' || P_SET_SCHEDULE_SHIP_DATE , 2 ) ;
       oe_debug_pub.add(  'P_LINE_ARRIVAL_DATE :' || P_LINE_ARRIVAL_DATE , 2 ) ;
       oe_debug_pub.add(  'P_SET_ARRIVAL_DATE :' || P_SET_ARRIVAL_DATE , 2 ) ;
   END IF;

   IF (p_set_type = 'SHIP_SET' AND
       p_line_ship_from_org_id  = p_set_ship_from_org_id   AND
       p_line_ship_to_org_id     = p_set_Ship_To_Org_Id     AND
       p_line_schedule_ship_date = p_set_schedule_ship_date) THEN

/* Modified the above line and added followinf 7 lines to fix the bug 3393033 */
      IF NVL(fnd_profile.value('ONT_SHIP_METHOD_FOR_SHIP_SET'),'N') = 'Y' THEN
       -- 3878494
       IF  OE_GLOBALS.equal(p_line_shipping_method_code,p_set_shipping_method_code) THEN
           RETURN TRUE;
       END IF;
      ELSE -- profile
       RETURN TRUE;
      END IF;

/* Modified the following line to fix the bug 3393033 */
   ELSIF (p_set_type = 'ARRIVAL_SET' AND
       p_line_ship_to_org_id     = p_set_ship_to_org_id     AND
       p_line_arrival_date       = p_set_arrival_date) THEN

       RETURN TRUE;

   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING CAMPARE ATTR' , 3 ) ;
   END IF;
   RETURN FALSE;

EXCEPTION

  WHEN OTHERS THEN

   IF l_debug_level  > 0 THEN
    oe_debug_pub.add('return false from debug');
   END IF;
    RETURN FALSE;

END Set_Attr_Matched;

-- 4026758
/* ----------------------------------------------------------------------
Procedure Log_Delete_Set_Request
Set_id will be deleted
1. When the line gets removed from the set.
2. When the line gets deleted, which is part of the set.
3. When line gets cancelled.
-------------------------------------------------------------------------*/
Procedure Log_Delete_Set_Request
(p_header_id IN NUMBER,
 p_line_id   IN NUMBER,
 p_set_id    IN NUMBER,
 x_return_status OUT NOCOPY VARCHAR2)

IS
l_set_type   VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ENTERING LOG DELETE SET REQUEST' || P_SET_ID , 1 );
   END IF;

   SELECT set_type
   INTO l_set_type
   FROM oe_sets
   WHERE  set_id = p_set_id;

   OE_delayed_requests_Pvt.log_request(
   p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
   p_entity_id              => p_line_id,
   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
   p_requesting_entity_id   => p_line_id,
   p_request_type           => OE_GLOBALS.G_DELETE_SET,
   p_param1                 => p_set_id,
   p_param2                 => p_header_id,
   p_param3                 => l_set_type,
   x_return_status          => x_return_status);
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING LOG DELETE SET REQUEST '||x_return_status , 1 ) ;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Log_Delete_Set_Request');
        END IF;
END Log_Delete_Set_Request;

/* ----------------------------------------------------------------------
Procedure Log_Set_Request
1. Set will populate set id when set name is populated by user.
2. log delayed request when a line is added to set.
3. Log delayed request when scheduling related attribute changed on
   on the line which belong to set.
3. Execute all delayed requests at once.

 Need to take care logging delyed request when action is passed on the
 line. Action can be passed by scheduling workflow or order import call.

  If the line is part of ato model/line  or SMC  model then log group request.
  Other wise log a schedule or reschedule delayed request.

-------------------------------------------------------------------------*/
Procedure Log_Set_Request
(p_line_rec       IN OE_ORDER_PUB.Line_rec_type,
 p_old_line_rec   IN OE_ORDER_PUB.Line_rec_type,
 p_sch_action     IN VARCHAR2,
 p_caller         IN VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2)

IS
l_group_request        BOOLEAN;
l_action               VARCHAR2(30);
l_schedule_ship_date    DATE := Null;
l_schedule_arrival_date DATE := Null;
l_param1               NUMBER;
l_ship_to_org_id       NUMBER := Null;
l_ship_from_org_id     NUMBER := Null;
l_entity_type          VARCHAR2(30);

l_set_schedule_ship_date    DATE;
l_set_schedule_arrival_date DATE;
l_set_ship_to_org_id        NUMBER;
l_set_ship_from_org_id      NUMBER;
l_set_status                VARCHAR2(1);
l_set_type                  VARCHAR2(30);
l_matched                   BOOLEAN := FALSE;
l_param12                   VARCHAR2(1);
l_shipping_method_code      VARCHAR2(30);
/* Added the following 1 line to fix the bug 2740480 */
l_push_logic                VARCHAR2(1) := 'N';
/* Added the following 1 line to fix the bug 3393033 */
l_set_shipping_method_code      VARCHAR2(30);

-- 2391781
l_cascade_line_id           NUMBER := NULL;
l_line_id                   NUMBER := NULL;

l_order_date_type_code      VARCHAR2(30);
--
--3314157
l_operation         VARCHAR2(30);
--3344843
l_diff_res_qty              NUMBER;
l_qty_to_reserve            NUMBER;
l_qty_to_unreserve          NUMBER;
l_index                     NUMBER;
l_line_id_mod               NUMBER;  --7827737
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

 -- If set does not exists, the the first time the lines are getting added
 -- to set. Do a group schedule. Other wise log a delayed request based on
 -- ato or smc.
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING LOG SET REQUEST' || P_LINE_REC.SHIP_SET_ID , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
   END IF;
 BEGIN


/* Removed ship_method_code from the following select , to fix the bug 2916814 */

  Select schedule_ship_date,ship_to_org_id,ship_from_org_id,
         schedule_arrival_date,shipping_method_code,
         set_status, set_type
  Into   l_schedule_ship_date,l_ship_to_org_id,l_ship_from_org_id,
         l_schedule_arrival_date,l_shipping_method_code,
         l_set_status, l_set_type
  From   oe_sets
  Where  set_id = nvl(p_line_rec.ship_set_id,p_line_rec.arrival_set_id);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SET SCHEDULE DATE'|| L_SCHEDULE_SHIP_DATE , 1 ) ;
   END IF;
 EXCEPTION
   WHEN OTHERS THEN
     l_schedule_ship_date := null;
 END;

 l_set_schedule_ship_date    := l_schedule_ship_date;
 l_set_schedule_arrival_date := l_schedule_arrival_date;
 l_set_ship_to_org_id        := l_ship_to_org_id;
 l_set_ship_from_org_id      := l_ship_from_org_id;
 l_set_shipping_method_code  := l_shipping_method_code;

 IF l_schedule_ship_date is null
 AND NVL(fnd_profile.value('ONT_SET_FOR_EACH_LINE'),'N') = 'Y'
 AND  p_line_rec.schedule_status_code is null
 AND  l_set_status = 'T'  THEN

  l_action :=  OESCH_ACT_SCHEDULE;

    -- 4188166
    -- Log request if no request logged for the set id. Also remember ship_to_org_id
    -- and ship_from_org_id for  cascading
    IF NOT OE_Delayed_Requests_PVT.Check_for_Request
    (   p_entity_code  =>OE_GLOBALS.G_ENTITY_LINE
    ,   p_entity_id    =>nvl(p_line_rec.ship_set_id,p_line_rec.arrival_set_id)
    ,   p_request_type =>OE_GLOBALS.G_GROUP_SET)  THEN

      OE_delayed_requests_Pvt.log_request(
      p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
      p_entity_id              => nvl(p_line_rec.ship_set_id,p_line_rec.arrival_set_id),
      p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
      p_requesting_entity_id   => p_line_rec.line_id,
      p_request_type           => OE_GLOBALS.G_GROUP_SET,
      p_param1                 => l_set_type,
      p_param2                 => p_line_rec.header_id,
      p_param3                 => p_line_rec.line_id,
      p_param4                 => p_line_rec.top_model_line_id,
      x_return_status          => x_return_status);
   END IF;


  GOTO END_PROCESS;

 END IF;

 IF l_schedule_ship_date is null
 OR p_line_rec.schedule_action_code is not null
 THEN
  --  Log a group request.
/*
   IF p_line_rec.schedule_status_code is not null THEN --2369951

     oe_debug_pub.add('1 Setting schedule line',2);

     l_schedule_ship_date    := p_line_rec.schedule_ship_date;
     l_schedule_arrival_date := p_line_rec.schedule_arrival_date;
     l_ship_from_org_id      := p_line_rec.ship_from_org_id;
     l_ship_to_org_id        := p_line_rec.ship_to_org_id;

     l_action := OESCH_ACT_RESCHEDULE;

   ELSE
     oe_debug_pub.add('1 Setting group schedule',2);
     l_group_request := TRUE;
     l_action := OESCH_ACT_SCHEDULE;
   END IF;
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  '1 SETTING GROUP SCHEDULE' , 2 ) ;
   END IF;
   l_group_request := TRUE;
   l_action := OESCH_ACT_RESCHEDULE;



 ELSIF OE_GLOBALS.Equal(p_line_rec.ship_set_id,
                        p_old_line_rec.ship_set_id)
 AND   OE_GLOBALS.Equal(p_line_rec.arrival_set_id,
                        p_old_line_rec.arrival_set_id)
 AND   p_line_rec.schedule_status_code is not null
 THEN

   -- some attribute changed in the line which belongs to set.
   -- Log group request.
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '2 SETTING GROUP SCHEDULE' , 2 ) ;
    END IF;
    l_group_request := TRUE;
    l_action := OESCH_ACT_RESCHEDULE;
    l_order_date_type_code :=
            NVL(Get_Date_Type(p_line_rec.header_id), 'SHIP'); -- 2920081

     --User has changed some attribute on the set.
     --Log a group request and send the changed information to
     --deleyed request.


    IF l_ship_from_org_id is not null THEN
       IF NOT OE_GLOBALS.Equal(p_line_rec.ship_from_org_id,
                               p_old_line_rec.ship_from_org_id)
       THEN
          l_ship_from_org_id := p_line_rec.ship_from_org_id;
       END IF;
    END IF;

    IF l_ship_to_org_id is not null THEN
       IF NOT OE_GLOBALS.Equal(p_line_rec.ship_to_org_id,
                               p_old_line_rec.ship_to_org_id)
       THEN
          l_ship_to_org_id := p_line_rec.ship_to_org_id;
       END IF;
    END IF;

    IF l_schedule_ship_date is not null THEN

       IF NOT OE_GLOBALS.Equal(p_line_rec.request_date,
                               p_old_line_rec.request_date)
       AND NOT SET_OVERRIDDEN(p_header_id => p_line_rec.header_id
                             ,p_ship_set_id => p_line_rec.ship_set_id
                             ,p_arrival_set_id => p_line_rec.arrival_set_id)
       THEN
          IF l_order_date_type_code ='SHIP'
          THEN -- 2920081
             --Bug 6057897
             --Request date change should be considered for doing re-scheudling of the set based on the parameter
             IF NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_REQUEST_DATE_FLAG'),'Y') = 'Y'
             THEN
                l_schedule_ship_date := p_line_rec.request_date;
             END IF;
          ELSE
             IF NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_REQUEST_DATE_FLAG'),'Y') = 'Y'
             THEN
                l_schedule_arrival_date := p_line_rec.request_date;
             END IF;
          END IF;
         -- l_schedule_ship_date := p_line_rec.request_date;
       END IF;

       IF NOT OE_GLOBALS.Equal(p_line_rec.schedule_ship_date,
                               p_old_line_rec.schedule_ship_date)
       THEN
          l_schedule_ship_date := p_line_rec.schedule_ship_date;
       END IF;
    END IF;

    IF l_schedule_arrival_date is not null THEN

       IF p_line_rec.arrival_set_id is not null
       AND NOT OE_GLOBALS.Equal(p_line_rec.request_date,
                                p_old_line_rec.request_date)
       AND NOT SET_OVERRIDDEN(p_header_id      => p_line_rec.header_id
                             ,p_ship_set_id    => p_line_rec.ship_set_id
                             ,p_arrival_set_id => p_line_rec.arrival_set_id)
       THEN
          IF l_order_date_type_code ='SHIP'
          THEN -- 2920081
             --Bug 6057897
             --Request date change should be considered for doing re-scheudling of the set based on the parameter
             IF NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_REQUEST_DATE_FLAG'),'Y') = 'Y'
             THEN
                l_schedule_ship_date := p_line_rec.request_date;
             END IF;
          ELSE
             IF NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_REQUEST_DATE_FLAG'),'Y') = 'Y'
             THEN
                l_schedule_arrival_date := p_line_rec.request_date;
             END IF;
          END IF;
        --l_schedule_arrival_date := p_line_rec.request_date;
       END IF;

       IF NOT OE_GLOBALS.Equal(p_line_rec.schedule_arrival_date,
                               p_old_line_rec.schedule_arrival_date)
       THEN
          l_schedule_arrival_date := p_line_rec.schedule_arrival_date;
       END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.shipping_method_code ,
                               p_old_line_rec.shipping_method_code )
    THEN
          l_shipping_method_code := p_line_rec.shipping_method_code ;
    END IF;


    -- 2391781,2787962
    -- Warehouse change only for arrival set

    IF  (NOT OE_GLOBALS.Equal(p_line_rec.ship_from_org_id,
                              p_old_line_rec.ship_from_org_id) AND
         (NVL(p_line_rec.ship_model_complete_flag,'N') = 'Y' OR
          p_line_rec.ato_line_id is not null) AND
          p_line_rec.arrival_set_id is not null)
    OR  NOT OE_GLOBALS.Equal(p_line_rec.request_date,
                             p_old_line_rec.request_date)
    THEN

       IF  NVL(p_line_rec.ship_model_complete_flag,'N') = 'Y'
       OR  NVL(p_line_rec.top_model_line_id ,-99) = p_line_rec.line_id
       THEN

          l_cascade_line_id := p_line_rec.top_model_line_id;
          IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Going to Log Cascade warehouse for SMC Model',2);
          END IF;

       ELSIF p_line_rec.ato_line_id is not null
       AND   NOT(p_line_rec.ato_line_id = p_line_rec.line_id
       AND   p_line_rec.item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                           OE_GLOBALS.G_ITEM_OPTION,
					   OE_GLOBALS.G_ITEM_INCLUDED)) --9775352
       THEN

          IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Going to Log Cascade warehouse for ato Model',2);
          END IF;

          l_cascade_line_id := p_line_rec.ato_line_id;

       ELSIF p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS THEN
          l_cascade_line_id := p_line_rec.line_id;
       END IF;
    END IF;
    -- 2391781, 2787962


 ELSE

  --   Log a request based on the type of the line.


    IF  ((p_line_rec.ato_line_id is not null AND
         NOT (p_line_rec.ato_line_id = p_line_rec.line_id AND
              p_line_rec.item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                            OE_GLOBALS.G_ITEM_OPTION,
					    OE_GLOBALS.G_ITEM_INCLUDED))) --9775352
    OR  (p_line_rec.line_id = p_line_rec.top_model_line_id))
    AND  NOT (OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
         AND  MSC_ATP_GLOBAL.GET_APS_VERSION = 10 )
    THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '3 SETTING GROUP SCHEDULE' , 2 ) ;
    END IF;

/* Added the following 1 line to fix the bug 2740480 */
     l_push_logic := 'Y';

     l_group_request := TRUE;
     l_action := OESCH_ACT_RESCHEDULE;
     -- Scheduling action would be reschedule.

    ELSE

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '4 SCHEDULE LINE' , 2 ) ;
    END IF;
     /*changes for bug 6719457*/
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'Checking if Group_Schedule delayed request already exists for the line' , 2 ) ;
    END IF;

      IF OE_Delayed_Requests_PVT.Check_for_Request
     (   p_entity_code  =>OE_GLOBALS.G_ENTITY_ALL
     ,   p_entity_id    =>p_line_rec.line_id
     ,   p_request_type =>OE_GLOBALS.G_GROUP_SCHEDULE)  THEN

        l_group_request := TRUE;
     ELSE
          l_group_request := FALSE;
     END IF;

 /*Changes for bug 6719457*/

     -- scheduling action would be schedule or re-schedule
     -- based on the scheduling status.

     IF p_line_rec.schedule_status_code is not null THEN
        l_action := OESCH_ACT_RESCHEDULE;
     ELSE
        l_action := OESCH_ACT_SCHEDULE;
     END IF;

     -- scheduling action would be schedule or re-schedule
     -- based on the scheduling status.

    END IF;

 END IF;

 IF p_line_rec.arrival_set_id is not null THEN
    l_param1      := p_line_rec.arrival_set_id;
    l_entity_type := OESCH_ENTITY_ARRIVAL_SET;
 ELSE
     l_param1      := p_line_rec.ship_set_id;
     l_entity_type := OESCH_ENTITY_SHIP_SET;
 END IF;


 -- Store the old inventory item to pass it to
 -- MRP during rescheduling the scheduled item.

 IF NOT OE_GLOBALS.Equal(p_line_rec.inventory_item_id,
                         p_old_line_rec.inventory_item_id)
 AND p_line_rec.schedule_status_code IS NOT NULL THEN

  l_line_id_mod := MOD(p_line_rec.line_id,G_BINARY_LIMIT); --7827737
 -- OE_Item_Tbl(p_line_rec.line_id).line_id --7827737
  --                  := p_line_rec.line_id;

  OE_Item_Tbl(l_line_id_mod).line_id  --7827737
                   := p_line_rec.line_id;

  --OE_Item_Tbl(p_line_rec.line_id).inventory_item_id  --7827737
  --                  := p_old_line_rec.inventory_item_id;

  OE_Item_Tbl(l_line_id_mod).inventory_item_id --7827737
                   := p_old_line_rec.inventory_item_id;
 END IF;
 -- 3384975
 l_param12 := 'N';

 -- set the variable 12 when scheduling attributes changed on a
 -- scheduled line.
 --- 3344843 Also set when reserved quantity changed

 IF  (p_line_rec.schedule_status_code is NOT NULL
  AND (Schedule_Attribute_Changed(p_line_rec     => p_line_rec,
                                p_old_line_rec => p_old_line_rec)
   OR  p_line_rec.ordered_quantity <> p_old_line_rec.ordered_quantity
   OR  NOT OE_GLOBALS.Equal(p_line_rec.override_atp_date_code,
                             p_old_line_rec.override_atp_date_code)
   OR NOT OE_GLOBALS.Equal(p_line_rec.reserved_quantity,
                           p_old_line_rec.reserved_quantity)))
   OR  p_line_rec.schedule_action_code is not null
 THEN

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(' Schedule Action Code '||p_line_rec.schedule_action_code,1);
       oe_debug_pub.add(  'SET L PARAM 12' , 4 ) ;
    END IF;
    l_param12 := 'Y';

 END IF;


 IF l_group_request THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE LOGGING G_GROUP_SCHEDULE' , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
    END IF;
    -- Log group set. which will execute a group schedule.
   /* -- 3384975 moved out of l_group_request check
    l_param12 := 'N';

    -- set the variable 12 when scheduling attributes changed on a
    -- scheduled line.
    --- 3344843 Also set when reserved quantity changed

    IF  p_line_rec.schedule_status_code is NOT NULL
    AND (Schedule_Attribute_Changed(p_line_rec     => p_line_rec,
                                    p_old_line_rec => p_old_line_rec)
    OR  p_line_rec.ordered_quantity <> p_old_line_rec.ordered_quantity
    OR  NOT OE_GLOBALS.Equal(p_line_rec.override_atp_date_code,
                             p_old_line_rec.override_atp_date_code)
    OR NOT OE_GLOBALS.Equal(p_line_rec.reserved_quantity,
                           p_old_line_rec.reserved_quantity))
    THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SET L PARAM 12' , 4 ) ;
       END IF;
       l_param12 := 'Y';

    END IF;
   */
    --for bug 3314157
    IF OE_QUOTE_UTIL.G_COMPLETE_NEG='Y'
    THEN
       l_operation:=OE_GLOBALS.G_OPR_CREATE;
    ELSE
       l_operation:= p_line_rec.operation;
    END IF;
    -- 3586151 OE_GLOBALS.G_ENTITY_LINE is replaced by OE_GLOBALS.G_ENTITY_ALL for p_entity_code to execute at the end.
    OE_delayed_requests_Pvt.log_request
     (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,  --OE_GLOBALS.G_ENTITY_LINE,
      p_entity_id              => p_line_rec.line_id,
      p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
      p_requesting_entity_id   => p_line_rec.line_id,
      p_request_type           => OE_GLOBALS.G_GROUP_SCHEDULE,
      p_param1                 => l_param1,
      p_param2                 => p_line_rec.header_id,
      p_param3                 => l_action,
      p_param4                 => p_old_line_rec.ship_from_org_id,
      p_param5                 => p_old_line_rec.ship_to_org_id,
      p_date_param1            => p_old_line_rec.schedule_ship_date,
      p_date_param2            => p_old_line_rec.schedule_arrival_date,
      p_date_param3            => p_old_line_rec.request_date,
      p_date_param4            => l_schedule_ship_date,
      p_date_param5            => l_schedule_arrival_date,
      p_param6                 => p_old_line_rec.ship_set_id,
      p_param7                 => p_old_line_rec.arrival_set_id,
      p_param8                 => l_entity_type,
      p_param9                 => l_ship_to_org_id,
      p_param10                => l_ship_from_org_id,
      p_param11                => nvl(l_shipping_method_code,p_line_rec.shipping_method_code),
/* removed param11 to fix the bug 2916814 */
      p_param12                => l_param12,
/* Added the following 1 line to fix the bug 2740480 */
      p_param13                => l_push_logic,
    /*REplaced  p_line_rec.operation with l_operation as a fix for bug 3314157*/
      p_param14                => l_operation,
      x_return_status          => x_return_status);


   -- 2391781
   IF l_cascade_line_id IS NOT NULL
   THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Logging cascade warehouse / Request date ' , 4 ) ;
      END IF;
      OE_delayed_requests_Pvt.log_request
         (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
          p_entity_id              => l_cascade_line_id,
          p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
          p_requesting_entity_id   => l_cascade_line_id,
          p_request_type           => OE_GLOBALS.G_CASCADE_SCH_ATTRBS,
          p_param1                 => NVL(p_line_rec.arrival_set_id,
                                          p_line_rec.ship_set_id),
          p_param2                 => p_line_rec.ship_from_org_id,
          p_date_param1            => p_line_rec.request_date,
          x_return_status          => x_return_status);


   END IF;
   -- 2391781



 ELSE

    -- Log schedule or reschedule based on the action.

    -- See of the line is scheduled and getting added to set with
    -- same scheduling and set attributes, avoid logging the request.
    -- 3384975 Override_atp_date_code check added

    IF p_line_rec.schedule_status_code IS NOT NULL AND
    NOT Schedule_Attribute_Changed(p_line_rec     => p_line_rec,
                                   p_old_line_rec => p_old_line_rec)
    AND     OE_GLOBALS.Equal(p_line_rec.override_atp_date_code,
                             p_old_line_rec.override_atp_date_code)
    AND p_line_rec.ordered_quantity = p_old_line_rec.ordered_quantity
    AND (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD OR
        nvl(p_line_rec.model_remnant_flag,'N') = 'Y') THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ARRIVAL_SET_ID : ' || P_LINE_REC.ARRIVAL_SET_ID || ':' || P_LINE_REC.SHIP_SET_ID , 2 ) ;
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OLD SHIP DATE ' || P_OLD_LINE_REC.SCHEDULE_SHIP_DATE , 2 ) ;
        END IF;
        --- 3344843 Put to old set if set attribs match and there is no change in reserve quantity.
        IF Set_Attr_Matched
           (p_set_ship_from_org_id    => l_set_ship_from_org_id ,
            p_line_ship_from_org_id   => p_line_rec.ship_from_org_id,
            p_set_ship_to_org_id      => l_set_ship_to_org_id ,
            p_line_ship_to_org_id     => p_line_rec.ship_to_org_id ,
            p_set_schedule_ship_date  => l_set_schedule_ship_date ,
            p_line_schedule_ship_date => p_line_rec.schedule_ship_date,
            p_set_arrival_date        => l_set_schedule_arrival_date,
            p_line_arrival_date       => p_line_rec.schedule_arrival_date,
            p_line_shipping_method_code => p_line_rec.shipping_method_code ,
            p_set_shipping_method_code => l_set_shipping_method_code ,
            p_set_type                => l_entity_type)
          AND OE_GLOBALS.Equal(p_line_rec.reserved_quantity,
           p_old_line_rec.reserved_quantity) THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ONLY SCHEDULED LINE IS GETTING INTO OLD SET' , 2 ) ;
             END IF;
             l_matched := TRUE;
             -- Since we are not logging delayed request, we will update the
             -- ship method if it does not match.

/* Commented the following code to fix the bug 2916814

            IF NOT OE_GLOBALS.EQUAL(p_line_rec.shipping_method_code,
                                    l_shipping_method_code) THEN

               BEGIN

                Update oe_order_lines_all
                Set shipping_method_code = l_shipping_method_code
                where header_id = p_line_rec.header_id
                and line_id = p_line_rec.line_id;
              EXCEPTION
                WHEN OTHERS THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               END;
            END IF;

    */

        END IF; -- compare.

    END IF;  -- not null

    IF NOT l_matched THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE LOGGING G_SCHEDULE_LINE' , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
    END IF;

     l_line_id := p_line_rec.line_id;

     IF (OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
     AND MSC_ATP_GLOBAL.GET_APS_VERSION = 10 ) THEN

         l_line_id := Nvl(p_line_rec.ato_line_id,p_line_rec.line_id);
     END IF;

     OE_delayed_requests_Pvt.log_request
     (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
      p_entity_id              => l_line_id,
      p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
      p_requesting_entity_id   => p_line_rec.line_id,
      p_request_type           => OE_GLOBALS.G_SCHEDULE_LINE,
      p_param1                 => l_param1,
      p_param2                 => p_line_rec.header_id,
      p_param3                 => l_action,
      p_param4                 => p_old_line_rec.ship_from_org_id,
      p_param5                 => p_old_line_rec.ship_to_org_id,
      p_param6                 => p_old_line_rec.ship_set_id,
      p_param7                 => p_old_line_rec.arrival_set_id,
      p_param8                 => l_entity_type,
      p_param9                 => l_ship_to_org_id,
      p_param10                => l_ship_from_org_id,
      p_param11                => l_set_shipping_method_code,
      p_param12                => l_param12,
/* commented the above line to fix the bug 2916814 */
      p_date_param1            => p_old_line_rec.schedule_ship_date,
      p_date_param2            => p_old_line_rec.schedule_arrival_date,
      p_date_param3            => p_old_line_rec.request_date,
      p_date_param4            => l_schedule_ship_date,
      p_date_param5            => l_schedule_arrival_date,
      x_return_status          => x_return_status);

    END IF;


 END IF;
    --3344843 Storing the change in reserve quantity
    l_diff_res_qty := nvl(p_line_rec.reserved_quantity, 0) -
                    nvl(p_old_line_rec.reserved_quantity, 0);
-- INVCONV may need changes here for sets

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RES QTY DIFF '|| L_DIFF_RES_QTY , 1 ) ;
    END IF;
    IF l_diff_res_qty <> 0 THEN
       IF l_diff_res_qty > 0 THEN
          l_qty_to_reserve   := l_diff_res_qty;
          l_qty_to_unreserve := null;
       ELSIF l_diff_res_qty < 0 THEN
          l_qty_to_unreserve := 0 - l_diff_res_qty;
       END IF;


       l_qty_to_reserve
         := NVL(p_old_line_rec.reserved_quantity,0) + l_diff_res_qty;
       l_qty_to_unreserve
         := p_old_line_rec.reserved_quantity;
       --l_index          := p_line_rec.line_id;  --7827737
        l_index        :=MOD(p_line_rec.line_id,G_BINARY_LIMIT);--7827737
       IF l_qty_to_reserve is not NULL OR
             l_qty_to_unreserve  is not NULL THEN

          Oe_Config_Schedule_Pvt.OE_Reservations_Tbl(l_index).entity_id
                           := p_line_rec.top_model_line_id;
          Oe_Config_Schedule_Pvt.OE_Reservations_Tbl(l_index).line_id
                           := p_line_rec.line_id;
          Oe_Config_Schedule_Pvt.OE_Reservations_Tbl(l_index).qty_to_reserve
                           := l_qty_to_reserve;
          Oe_Config_Schedule_Pvt.OE_Reservations_Tbl(l_index).qty_to_unreserve
                           := l_qty_to_unreserve;
       END IF;
    END IF;

 <<END_PROCESS>>

 IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING LOG SET REQUEST' , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
 END IF;

 --If the scheduling action is not null then system should execute the delyed request.

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Log_Set_Request');
        END IF;
END Log_Set_Request;

/*-----------------------------------------------------------------------------
Procedure Name : Schedule_Attribute_Changed
Description    : This function returns TRUE is scheduling attribute is changed
                 on a line. This is required for rescheduling.
----------------------------------------------------------------------------- */


FUNCTION Schedule_Attribute_Changed
( p_line_rec     IN Oe_Order_Pub.line_rec_type
, p_old_line_rec IN Oe_Order_Pub.line_rec_type)
RETURN BOOLEAN
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF NOT OE_GLOBALS.Equal(p_line_rec.SHIP_FROM_ORG_ID,
                           p_old_line_rec.SHIP_FROM_ORG_ID)
    THEN
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.SUBINVENTORY,
                           p_old_line_rec.SUBINVENTORY)
    THEN
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.SHIP_TO_ORG_ID,
                           p_old_line_rec.SHIP_TO_ORG_ID)
    THEN
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.DEMAND_CLASS_CODE,
                           p_old_line_rec.DEMAND_CLASS_CODE)
    THEN
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.SCHEDULE_SHIP_DATE,
                           p_old_line_rec.SCHEDULE_SHIP_DATE)
    THEN
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.SCHEDULE_ARRIVAL_DATE,
                           p_old_line_rec.SCHEDULE_ARRIVAL_DATE)
    THEN
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.SHIPPING_METHOD_CODE,
                           p_old_line_rec.SHIPPING_METHOD_CODE)
    THEN
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.REQUEST_DATE,
                           p_old_line_rec.REQUEST_DATE)
    THEN
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.DELIVERY_LEAD_TIME,
                           p_old_line_rec.DELIVERY_LEAD_TIME)
    THEN
       RETURN TRUE;
    END IF;


    IF NOT OE_GLOBALS.Equal(p_line_rec.inventory_item_id,
                            p_old_line_rec.inventory_item_id)
    THEN
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.order_quantity_uom,
                            p_old_line_rec.order_quantity_uom)
    THEN
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.sold_to_org_id,
                            p_old_line_rec.sold_to_org_id)
    THEN
       RETURN TRUE;
    END IF;


    RETURN FALSE;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURNING FALSE ' , 3 ) ;
    END IF;

EXCEPTION

   WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Schedule_Attribute_Changed');
        END IF;
END Schedule_Attribute_Changed;

/*-----------------------------------------------------------------------
-- BUG 1955004
Procedure Name : Inactive_Demand_Scheduling
Description    : This procedure is invoked when it is desired to bypass
                 the call to ATP for SCHEDULING.  It is primarily written
                 for the new Scheduling Levels of FOUR and FIVE, which are
                 'Inactive Demand with Reservations' and 'Inactive Demand
                 without Reservations'.  This procedure will act on four
                 fields - schedule_ship_date, schedule_arrival_date,
                 visible_demand_flag, and schedule_status_code.
------------------------------------------------------------------------*/
PROCEDURE Inactive_Demand_Scheduling
( p_x_old_line_rec  IN OE_ORDER_PUB.line_rec_type
, p_x_line_rec    IN OUT NOCOPY OE_ORDER_PUB.line_rec_type
, p_sch_action      IN VARCHAR2 := NULL
, x_return_status OUT NOCOPY VARCHAR2

) IS

l_sch_action           VARCHAR2(30) := p_sch_action;
l_order_date_type_code VARCHAR2(30);

l_return_status   VARCHAR2(1);  -- Added for IR ISO Tracking bug 7667702
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING INACTIVE_DEMAND_SCHEDULING' , 1 ) ;
  END IF;
  X_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_sch_action is NULL THEN
    L_sch_action := p_x_line_rec.schedule_action_code;
  END IF;

  l_order_date_type_code :=
            NVL(Get_Date_Type(p_x_line_rec.header_id), 'SHIP');


  IF l_sch_action = OESCH_ACT_SCHEDULE OR
     l_sch_action = OESCH_ACT_RESCHEDULE OR
     l_sch_action = OESCH_ACT_REDEMAND OR
     l_sch_action = OESCH_ACT_DEMAND OR
     (l_sch_action = OESCH_ACT_RESERVE AND
      p_x_line_rec.schedule_status_code IS NULL) THEN
    -- set the data accordingly.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INACTIVE DEMAND - GOING TO SCHEDULE' , 1 ) ;
    END IF;

    IF l_order_date_type_code = 'SHIP' THEN
      IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_ship_date,
                              p_x_old_line_rec.schedule_ship_date) AND
         p_x_line_rec.schedule_ship_date IS NOT NULL AND
         p_x_line_rec.schedule_ship_date <> FND_API.G_MISS_DATE THEN
         -- If the user provides a ship_date, or changes the existing, use it
         -- DOO Sch Integration
         IF NVL(p_x_line_rec.bypass_sch_flag,'N') ='N'
	    OR p_x_line_rec.bypass_sch_flag = FND_API.G_MISS_CHAR THEN --14043008
            p_x_line_rec.schedule_arrival_date := p_x_line_rec.schedule_ship_date;
         END IF;

      ELSIF NOT OE_GLOBALS.Equal(p_x_line_rec.request_date,
                                 p_x_old_line_rec.request_date) AND
         p_x_line_rec.request_date IS NOT NULL AND
         p_x_line_rec.request_date <> FND_API.G_MISS_DATE THEN
           -- if the user changed request date, use it
           -- DOO Sch Integration
           IF NVL(p_x_line_rec.bypass_sch_flag,'N') ='N'
	     OR p_x_line_rec.bypass_sch_flag = FND_API.G_MISS_CHAR THEN --14043008
             p_x_line_rec.schedule_ship_date := p_x_line_rec.request_date;
             p_x_line_rec.schedule_arrival_date := p_x_line_rec.request_date;
           END IF;

      ELSE
        --  dates have not changed, so use whichever is not null, ship first
         -- DOO Sch Integration
         IF NVL(p_x_line_rec.bypass_sch_flag,'N') ='N'
	  OR p_x_line_rec.bypass_sch_flag = FND_API.G_MISS_CHAR THEN --14043008
            IF p_x_line_rec.schedule_ship_date IS NOT NULL THEN
              p_x_line_rec.schedule_arrival_date := p_x_line_rec.schedule_ship_date;
            ELSE
              p_x_line_rec.schedule_ship_date := p_x_line_rec.request_date;
              p_x_line_rec.schedule_arrival_date := p_x_line_rec.request_date;
            END IF;
          END IF;
      END IF;

    ELSE -- Arrival

      IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_arrival_date,
                              p_x_old_line_rec.schedule_arrival_date) AND
         p_x_line_rec.schedule_arrival_date IS NOT NULL AND
         p_x_line_rec.schedule_arrival_date <> FND_API.G_MISS_DATE THEN
           -- If the user provides a arrival_date, or changes the existing, use it
           -- DOO Sch Integration
           IF NVL(p_x_line_rec.bypass_sch_flag,'N') ='N'
	   OR p_x_line_rec.bypass_sch_flag = FND_API.G_MISS_CHAR THEN --14043008
             p_x_line_rec.schedule_ship_date := p_x_line_rec.schedule_arrival_date;
           END IF;

      ELSIF NOT OE_GLOBALS.Equal(p_x_line_rec.request_date,
                                 p_x_old_line_rec.request_date) AND
         p_x_line_rec.request_date IS NOT NULL AND
         p_x_line_rec.request_date <> FND_API.G_MISS_DATE THEN
           -- if the user changed request date, use it
            -- DOO Sch Integration
            IF NVL(p_x_line_rec.bypass_sch_flag,'N') ='N'
	    OR p_x_line_rec.bypass_sch_flag = FND_API.G_MISS_CHAR THEN --14043008

              p_x_line_rec.schedule_ship_date := p_x_line_rec.request_date;
              p_x_line_rec.schedule_arrival_date := p_x_line_rec.request_date;
            END IF;

      ELSE
        --  dates have not changed, so use whichever is not null, ship first
        -- DOO Sch Integration
        IF Nvl(p_x_line_rec.bypass_sch_flag, 'N') = 'N'
	OR p_x_line_rec.bypass_sch_flag = FND_API.G_MISS_CHAR THEN --14043008
          IF p_x_line_rec.schedule_arrival_date IS NOT NULL THEN
            -- it is arrival date type, so use the arrival date provided to set ship
            p_x_line_rec.schedule_ship_date := p_x_line_rec.schedule_arrival_date;
          ELSE
            -- if user does not provide a date, use request date
            p_x_line_rec.schedule_ship_date := p_x_line_rec.request_date;
            p_x_line_rec.schedule_arrival_date := p_x_line_rec.request_date;
          END IF;
        END IF;
       END IF;
    END IF;

    -- we want this line scheduled, but not visible for demand
    p_x_line_rec.visible_demand_flag := 'N';
    p_x_line_rec.schedule_status_code := OESCH_STATUS_SCHEDULED;
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
       -- Promise date setup
       Promise_Date_for_Sch_Action
            (p_x_line_rec => p_x_line_rec
            ,p_sch_action => l_sch_action
            ,P_header_id  => p_x_line_rec.header_id);
    END IF;

  ELSIF l_sch_action = OESCH_ACT_UNSCHEDULE OR
        L_sch_action = OESCH_ACT_UNDEMAND THEN
    -- we are unscheduling

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INACTIVE DEMAND - GOING TO UNSCHEDULE' , 1 ) ;
    END IF;

    P_x_line_rec.schedule_ship_date := NULL;
    P_x_line_rec.schedule_arrival_date := NULL;
    p_x_line_rec.visible_demand_flag := NULL;
    p_x_line_rec.schedule_status_code := NULL;

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
       -- Promise date setup
       Promise_Date_for_Sch_Action
            (p_x_line_rec => p_x_line_rec
            ,p_sch_action => l_sch_action
            ,P_header_id  => p_x_line_rec.header_id);
    END IF;
  ELSE
  -- We should not have any other actions here.
  -- If we do, it is an error.
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

/* IR ISO Tracking bug 7667702: IR ISO Change Management Begins */

-- This code is hooked for IR ISO project, where if the schedule ship/
-- arrival date is changed and MRP is not installed then a delayed request is
-- logged to call the PO_RCO_Validation_GRP.Update_ReqChange_from_SO
-- API from Purchasing, responsible for conditionally updating the Need By
-- Date column in internal requisition line. This will be done based on
-- PO profile 'POR: Sync up Need by date on IR with OM' set to YES

-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc


    IF (p_x_line_rec.order_source_id = 10) AND
       (
        ((p_x_old_line_rec.schedule_ship_date IS NOT NULL) AND
          NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_ship_date,p_x_old_line_rec.schedule_ship_date))
       OR
        ((p_x_old_line_rec.schedule_arrival_date IS NOT NULL) AND
          NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_arrival_date,p_x_old_line_rec.schedule_arrival_date))
       )  THEN

       IF NOT OE_Internal_Requisition_Pvt.G_Update_ISO_From_Req
         AND NOT OE_SALES_CAN_UTIL.G_IR_ISO_HDR_CANCEL THEN

         IF FND_PROFILE.VALUE('POR_SYNC_NEEDBYDATE_OM') = 'YES' THEN

           IF l_debug_level > 0 THEN
             oe_debug_pub.add(' Logging G_UPDATE_REQUISITION delayed request for date change');
           END IF;

           -- Log a delayed request to update the change in Schedule Ship Date to
           -- Requisition Line. This request will be logged only if the change is
           -- not initiated from Requesting Organization, and it is not a case of
           -- Internal Sales Order Full Cancellation. It will even not be logged
           -- Purchasing profile option does not allow update of Need By Date when
           -- Schedule Ship Date changes on internal sales order line

           OE_delayed_requests_Pvt.log_request
           ( p_entity_code            => OE_GLOBALS.G_ENTITY_LINE
           , p_entity_id              => p_x_line_rec.line_id
           , p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE
           , p_requesting_entity_id   => p_x_line_rec.line_id
           , p_request_unique_key1    => p_x_line_rec.header_id  -- Order Hdr_id
           , p_request_unique_key2    => p_x_line_rec.source_document_id -- Req Hdr_id
           , p_request_unique_key3    => p_x_line_rec.source_document_line_id -- Req Line_id
           , p_date_param1            => p_x_line_rec.schedule_arrival_date
           -- Note: p_date_param1 is used for both Schedule_Ship_Date and
           -- Schedule_Arrival_Date, as while executing G_UPDATE_REQUISITION delayed
           -- request via OE_Process_Requisition_Pvt.Update_Internal_Requisition,
           -- it can expect change with respect to Ship or Arrival date. Thus, will
           -- not raise any issues.
           , p_request_type           => OE_GLOBALS.G_UPDATE_REQUISITION
           , x_return_status          => l_return_status
           );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;

         ELSE
           IF NOT OE_Schedule_GRP.G_ISO_Planning_Update THEN
             IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Need By Date is not allowed to update. Updating MTL_Supply only',5);
             END IF;

             OE_SCHEDULE_UTIL.Update_PO(p_x_line_rec.schedule_arrival_date,
                p_x_line_rec.source_document_id,
                p_x_line_rec.source_document_line_id);
           END IF;
         END IF;

       END IF;
     END IF; -- Order_Source_id

/* ============================= */
/* IR ISO Change Management Ends */

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN -- Added for IR ISO Tracking bug 7667702
      x_return_status :=  FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN

    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN

      OE_MSG_PUB.Add_Exc_Msg
      (G_PKG_NAME,
       'Inactive_Demand_Scheduling');
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inactive_Demand_Scheduling;
-- END 1955004

/*-----------------------------------------------------------------------
Procedure Name : Initialize_mrp_record
Description    : This procedure create l_count records each for each table
                 in the record of tables of MRP's p_atp_rec.
------------------------------------------------------------------------*/
Procedure Initialize_mrp_record
( p_x_atp_rec IN  OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ
 ,l_count     IN  NUMBER)
IS
 l_return_status           VARCHAR2(1);
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXTENDING THE TABLE BY ' || L_COUNT , 5 ) ;
  END IF;
/*
  p_x_atp_rec.Inventory_Item_Id.extend(l_count);
  p_x_atp_rec.Source_Organization_Id.extend(l_count);
  p_x_atp_rec.Identifier.extend(l_count);
  p_x_atp_rec.Order_Number.extend(l_count);
  p_x_atp_rec.Calling_Module.extend(l_count);
  p_x_atp_rec.Customer_Id.extend(l_count);
  p_x_atp_rec.Customer_Site_Id.extend(l_count);
  p_x_atp_rec.Destination_Time_Zone.extend(l_count);
  p_x_atp_rec.Quantity_Ordered.extend(l_count);
  p_x_atp_rec.Quantity_UOM.extend(l_count);
  p_x_atp_rec.Requested_Ship_Date.extend(l_count);
  p_x_atp_rec.Requested_Arrival_Date.extend(l_count);
  p_x_atp_rec.Earliest_Acceptable_Date.extend(l_count);
  p_x_atp_rec.Latest_Acceptable_Date.extend(l_count);
  p_x_atp_rec.Delivery_Lead_Time.extend(l_count);
  p_x_atp_rec.Atp_Lead_Time.extend(l_count);
  p_x_atp_rec.Freight_Carrier.extend(l_count);
  p_x_atp_rec.Ship_Method.extend(l_count);
  p_x_atp_rec.Demand_Class.extend(l_count);
  p_x_atp_rec.Ship_Set_Name.extend(l_count);
  p_x_atp_rec.Arrival_Set_Name.extend(l_count);
  p_x_atp_rec.Override_Flag.extend(l_count);
  p_x_atp_rec.Action.extend(l_count);
  p_x_atp_rec.ship_date.extend(l_count);
  p_x_atp_rec.Available_Quantity.extend(l_count);
  p_x_atp_rec.Requested_Date_Quantity.extend(l_count);
  p_x_atp_rec.Group_Ship_Date.extend(l_count);
  p_x_atp_rec.Group_Arrival_Date.extend(l_count);
  p_x_atp_rec.Vendor_Id.extend(l_count);
  p_x_atp_rec.Vendor_Site_Id.extend(l_count);
  p_x_atp_rec.Insert_Flag.extend(l_count);
  p_x_atp_rec.Error_Code.extend(l_count);
  p_x_atp_rec.Message.extend(l_count);
  p_x_atp_rec.Old_Source_Organization_Id.extend(l_count);
  p_x_atp_rec.Old_Demand_Class.extend(l_count);
  p_x_atp_rec.oe_flag.extend(l_count);
  -- Added below attributes to fix bug 1912138.
  p_x_atp_rec.ato_delete_flag.extend(l_count);
  p_x_atp_rec.attribute_01.extend(l_count);
  p_x_atp_rec.attribute_05.extend(l_count);
  p_x_atp_rec.substitution_typ_code.extend(l_count);
  p_x_atp_rec.old_inventory_item_id.extend(l_count);
*/

  IF   OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
  AND  MSC_ATP_GLOBAL.GET_APS_VERSION = 10 THEN

   MSC_ATP_GLOBAL.EXTEND_ATP
    (p_atp_tab       => p_x_atp_rec,
     p_index         => l_count,
     x_return_status => l_return_status);

  ELSE

    MSC_SATP_FUNC.Extend_ATP
    (p_atp_tab       => p_x_atp_rec,
     p_index         => l_count,
     x_return_status => l_return_status);

  END IF;


EXCEPTION

   WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Initialize_mrp_record');
        END IF;
END Initialize_mrp_record;
/*--------------------------------------------------------------------
Procedure Name : Load_MRP_request
Description    :
  This procedure loads the MRP record or tables to be passed
  to MRP's API from the OM's table of records of order lines.

  If line line to be passed to MRP is an ATO model, we call
  CTO's GET_MANDATORY_COMPONENTS API to get the mandatory
  components, and we pass them along with the ATO model to MRP.
-------------------------------------------------------------------- */
Procedure Load_MRP_request
( p_line_rec           IN  OE_ORDER_PUB.line_rec_type
 ,p_old_line_rec       IN  OE_ORDER_PUB.line_rec_type
 ,p_sch_action         IN  VARCHAR2 := NULL
 ,p_mrp_calc_sd        IN  VARCHAR2
 ,p_type_code          IN  VARCHAR2
 ,p_order_number       IN  NUMBER
 ,p_partial_set        IN  BOOLEAN := FALSE
 ,p_config_line_id     IN  NUMBER  := NULL
 ,p_part_of_set        IN  VARCHAR2 DEFAULT 'N' -- 4405004
 ,p_index              IN OUT NOCOPY NUMBER
 ,x_atp_rec            IN OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ)
IS
  I                   NUMBER := p_index;
  l_insert_flag       NUMBER;
  l_oe_flag           VARCHAR2(1);
  l_inv_ctp           VARCHAR2(240);
  l_explode           BOOLEAN;
  l_st_atp_lead_time  NUMBER;
  l_st_ato_line_id    NUMBER;
  l_ship_set          VARCHAR2(30);
  l_arrival_set       VARCHAR2(30);
  l_action_code       VARCHAR2(30);
  l_action            NUMBER;
  l_organization_id   NUMBER;
  l_inventory_item_id NUMBER;
  l_result            NUMBER := 1;

  l_model_rec         MRP_ATP_PUB.ATP_Rec_Typ;
  l_smc_rec           MRP_ATP_PUB.ATP_Rec_Typ;

  lTableName          VARCHAR2(30);
  lMessageName        VARCHAR2(30);
  lErrorMessage       VARCHAR2(2000);
  l_line_id_mod       NUMBER ; --7827737

  l_model_override_atp_date_code VARCHAR2(30);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
Begin

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_SCHEDULE_UTIL.LOAD_MRP_REQUEST' , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('------------Load MRP Table-----------',1);
  END IF;

    IF l_action_code <> OESCH_ACT_ATP_CHECK THEN
       G_ATP_CHECK_Session_Id := Null;
    END IF;

    IF p_sch_action IS NULL THEN
        l_action_code := p_line_rec.schedule_action_code;
    ELSE
        l_action_code := p_sch_action;
    END IF;

    IF nvl(p_mrp_calc_sd,'N') = 'Y' THEN
      l_insert_flag   := 1;
    ELSE
      l_insert_flag   := 0;
    END IF;

    x_atp_rec.atp_lead_time(I)   := 0;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Line Id              : ' || p_line_rec.line_id,3);
    END IF;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Schedule Action      : ' || l_action_code,3);
    END IF;

/*
    IF p_line_rec.source_document_type_id = 10 THEN
      oe_debug_pub.add('It is an internal order ',3);
      l_oe_flag := 'Y';

      IF (p_line_rec.schedule_ship_date IS NOT NULL AND
          p_line_rec.schedule_ship_date <> FND_API.G_MISS_DATE ) OR
         (p_line_rec.schedule_arrival_date IS NOT NULL AND
          p_line_rec.schedule_arrival_date <> FND_API.G_MISS_DATE ) THEN

          oe_debug_pub.add('No changes to date as it has been passed',3);
      ELSE
          oe_debug_pub.add('Pass the request date as arrival date',3);

          x_atp_rec.Requested_ship_Date(I)  := null;
          x_atp_rec.Requested_arrival_Date(I) := p_line_rec.request_date;

      END IF;

      x_atp_rec.attribute_01(I) := p_line_rec.source_document_id;

    ELSE

      oe_debug_pub.add('It is not an internal order ',3);
      l_oe_flag := 'N';

    END IF;

    x_atp_rec.oe_flag(I) := l_oe_flag;
    oe_debug_pub.add('OE Flag is : '||x_atp_rec.oe_flag(I),3);
*/

    IF p_line_rec.arrival_set_id is null
    THEN
      l_arrival_set := p_line_rec.arrival_set;
    ELSE
      l_arrival_set := nvl(p_line_rec.arrival_set,to_char(p_line_rec.arrival_set_id));
    END IF;

    IF  p_line_rec.ship_set_id is null
    THEN
      l_ship_set := p_line_rec.ship_set;
    ELSE
      l_ship_set := nvl(p_line_rec.ship_set,to_char(p_line_rec.ship_set_id));
    END IF;

    IF l_arrival_set = FND_API.G_MISS_CHAR THEN
       l_arrival_set := Null;
    END IF;
    IF l_ship_set = FND_API.G_MISS_CHAR THEN
       l_ship_set := Null;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP_SET : ' || L_SHIP_SET , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ARRIVAL SET : ' || L_ARRIVAL_SET , 3 ) ;
    END IF;


/*      IF (p_line_rec.ship_from_org_id = FND_API.G_MISS_NUM) THEN
            p_line_rec.ship_from_org_id := null;
        END IF;
        IF (p_old_line_rec.ship_from_org_id = FND_API.G_MISS_NUM) THEN
            p_old_line_rec.ship_from_org_id := null;
        END IF;
*/
/*

        IF NOT OE_GLOBALS.Equal(p_line_rec.ship_from_org_id,
                                p_old_line_rec.ship_from_org_id) OR
               (p_line_rec.re_source_flag = 'N')
*/

    x_atp_rec.Inventory_Item_Id(I)         := p_line_rec.inventory_item_id;

    IF (p_line_rec.ship_from_org_id IS NOT NULL) THEN
      x_atp_rec.Source_Organization_Id(I)
                      := p_line_rec.ship_from_org_id;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SHIP FROM : ' || P_LINE_REC.SHIP_FROM_ORG_ID , 3 ) ;
      END IF;

    ELSE
      x_atp_rec.Source_Organization_Id(I) := null;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SHIP FROM IS NULL ' , 3 ) ;
      END IF;
    END IF;

    x_atp_rec.Identifier(I)                := p_line_rec.line_id;
    x_atp_rec.Order_Number(I)              := p_order_number;
    x_atp_rec.Calling_Module(I)            := 660;
    x_atp_rec.Customer_Id(I)               := p_line_rec.sold_to_org_id;
    x_atp_rec.Customer_Site_Id(I)          := p_line_rec.ship_to_org_id;
    x_atp_rec.Destination_Time_Zone(I)     := p_line_rec.item_type_code;
    x_atp_rec.Quantity_Ordered(I)          := p_line_rec.ordered_quantity;
    x_atp_rec.Quantity_UOM(I)              := p_line_rec.order_quantity_uom;
    x_atp_rec.Earliest_Acceptable_Date(I)  := null;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'A1 : ' || P_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'A2 : ' || P_OLD_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
    END IF;

    -- Start 2691579 --
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
       IF  (p_line_rec.operation = OE_GLOBALS.G_OPR_DELETE)
       AND (p_line_rec.ato_line_id IS NOT NULL AND
       NOT (p_line_rec.ato_line_id = p_line_rec.line_id AND
            p_line_rec.item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                          OE_GLOBALS.G_ITEM_OPTION,
					  OE_GLOBALS.G_ITEM_INCLUDED))) THEN --9775352
          x_atp_rec.ato_delete_flag(I) := 'Y';
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ATO DELETE FLAG : '
                             || x_atp_rec.ato_delete_flag(I) , 1 ) ;
          END IF;
       END IF;
    END IF;
    -- End 2691579 --

/* Commented the following condition to fix the bug 2823868 */
/* The problem is that if someone has set order date type as arrival
   and the puts the line in a ship set , then p_line_rec.ship_set_id will be not null
   so the schedule_ship_date will be passed to the atp record, where as arrival_date should have
   passed to the arrival record */
/*
    IF p_line_rec.arrival_set_id is not null THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'T1' , 1 ) ;
      END IF;
      IF p_line_rec.schedule_action_code = OESCH_ACT_ATP_CHECK THEN
         x_atp_rec.Requested_Arrival_Date(I) :=
                                 p_line_rec.request_date;

      ELSE
        x_atp_rec.Requested_Arrival_Date(I) :=
                               p_line_rec.schedule_arrival_date;
      END IF;
      x_atp_rec.Requested_Ship_Date(I)    := null;

    ELSIF  p_line_rec.ship_set_id is not null THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'T2' , 1 ) ;
      END IF;
      IF p_line_rec.schedule_action_code = OESCH_ACT_ATP_CHECK THEN
         x_atp_rec.Requested_Ship_Date(I)    :=
                               p_line_rec.request_date;
      ELSE
         x_atp_rec.Requested_Ship_Date(I)    :=
                               p_line_rec.schedule_ship_date;
      END IF;
      x_atp_rec.Requested_Arrival_Date(I) := null;
*/

    IF (p_type_code = 'ARRIVAL') THEN

      -- If user changes schedule_arrival_date then schedule based
      -- on the arrival_date. Otherwise look for the change in request date.
      -- If user changed request date, schedule based on the request
      -- date. Otherwise if the scheduling is happening because of
      -- some other changes, use nvl on arrival_date and request_dates.

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'T3' , 1 ) ;
      END IF;

      IF p_line_rec.schedule_action_code = OESCH_ACT_ATP_CHECK THEN
         x_atp_rec.Requested_Arrival_Date(I) :=
                                 p_line_rec.request_date;

      ELSE

       IF  p_line_rec.schedule_status_code is not null
       AND p_line_rec.ship_model_complete_flag = 'Y'
       AND smc_overridden(p_line_rec.top_model_line_id) THEN

           x_atp_rec.Requested_Arrival_Date(I) :=
                     p_line_rec.schedule_arrival_date;

       ELSE -- not overridden.

        IF NOT OE_GLOBALS.Equal(p_line_rec.schedule_arrival_date,
                                p_old_line_rec.schedule_arrival_date) AND
           p_line_rec.schedule_arrival_date IS NOT NULL AND
           p_line_rec.schedule_arrival_date <> FND_API.G_MISS_DATE
        THEN
           x_atp_rec.Requested_Arrival_Date(I) :=
                     p_line_rec.schedule_arrival_date;

        ELSIF NOT OE_GLOBALS.Equal(p_line_rec.request_date,
                                 p_old_line_rec.request_date) AND
            p_line_rec.request_date IS NOT NULL AND
            p_line_rec.request_date <> FND_API.G_MISS_DATE AND
            nvl(p_line_rec.override_atp_date_code,'N') = 'N' AND
            --Bug 6057897
            --Added the below condition to prevent rescheduling based on request date, if scheduling is triggered due to
            --some other changes. For example change in Order quantity will trigger scheduling, but request date change
            --should not be honoured.
            NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_REQUEST_DATE_FLAG'),'Y') = 'Y'
        THEN
            x_atp_rec.Requested_Arrival_Date(I) :=
                       p_line_rec.request_date;
        ELSE
            x_atp_rec.Requested_Arrival_Date(I) :=
             nvl(p_line_rec.schedule_arrival_date,p_line_rec.request_date);
        END IF;
       END IF; --  overridden
      END IF; --atp

      x_atp_rec.Requested_Ship_Date(I)    := null;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'REQ ARR DATE : ' ||X_ATP_REC.REQUESTED_ARRIVAL_DATE ( I ) , 3 ) ;
      END IF;

    ELSE
      -- If user changes schedule_ship_date then schedule based
      -- on the ship_date. Otherwise look for the change in request date.
      -- If user changed request date, schedule based on the request
      -- date. Otherwise if the scheduling is happening because of
      -- some other changes, use nvl on schedule_ship and request_dates.

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'T4' , 1 ) ;
      END IF;
      IF p_line_rec.schedule_action_code = OESCH_ACT_ATP_CHECK THEN
         x_atp_rec.Requested_Ship_Date(I)    :=
                               p_line_rec.request_date;
      ELSE
       IF  p_line_rec.schedule_status_code is not null
       AND p_line_rec.ship_model_complete_flag = 'Y'
       AND smc_overridden(p_line_rec.top_model_line_id) THEN

           x_atp_rec.Requested_Ship_Date(I) :=
                          p_line_rec.schedule_ship_date;
       ELSE -- Not overridden

        IF NOT OE_GLOBALS.Equal(p_line_rec.schedule_ship_date,
                                p_old_line_rec.schedule_ship_date) AND
           p_line_rec.schedule_ship_date IS NOT NULL AND
           p_line_rec.schedule_ship_date <> FND_API.G_MISS_DATE
        THEN
          x_atp_rec.Requested_Ship_Date(I) :=
                          p_line_rec.schedule_ship_date;

        ELSIF NOT OE_GLOBALS.Equal(p_line_rec.request_date,
                                   p_old_line_rec.request_date) AND
              p_line_rec.request_date IS NOT NULL AND
              p_line_rec.request_date <> FND_API.G_MISS_DATE AND
              nvl(p_line_rec.override_atp_date_code,'N') = 'N' AND
              --Bug 6057897
              NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_REQUEST_DATE_FLAG'),'Y') = 'Y'
        THEN
          x_atp_rec.Requested_Ship_Date(I) :=
                        p_line_rec.request_date;
        ELSE
          x_atp_rec.Requested_Ship_Date(I)    :=
           nvl(p_line_rec.schedule_ship_date,p_line_rec.request_date);

        END IF; -- sch ship date changed.
       END IF; -- Overridden
      END IF; --Atp

      x_atp_rec.Requested_Arrival_Date(I)  := null;
                                     IF l_debug_level  > 0 THEN
                                         oe_debug_pub.add(  'REQ SHIP DATE : ' || X_ATP_REC.REQUESTED_SHIP_DATE ( I ) , 3 ) ;
                                     END IF;

    END IF;


    IF p_partial_set THEN

      -- If the line is part of a set and we are rescheduling it
      -- just by itself, we should not let MRP change the date.
      -- Thus we will pass null Latest_Acceptable_Date

      x_atp_rec.Latest_Acceptable_Date(I)  := null;
    ELSE

      x_atp_rec.Latest_Acceptable_Date(I)  :=
                       p_line_rec.latest_acceptable_date;
    END IF;

                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'LATEST ACCEPTABLE DATE :' || X_ATP_REC.LATEST_ACCEPTABLE_DATE ( I ) , 1 ) ;
                            END IF;

    x_atp_rec.Delivery_Lead_Time(I)     := Null;
    --x_atp_rec.Delivery_Lead_Time(I)     := p_line_rec.delivery_lead_time;
                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'DELIVERYLEAD TIME :' || X_ATP_REC.DELIVERY_LEAD_TIME ( I ) , 1 ) ;
                            END IF;
    x_atp_rec.Freight_Carrier(I)        := null;
    x_atp_rec.Ship_Method(I)            := p_line_rec.shipping_method_code;
    x_atp_rec.Demand_Class(I)           := p_line_rec.demand_class_code;
    x_atp_rec.Ship_Set_Name(I)          := l_ship_set;
    x_atp_rec.Arrival_Set_Name(I)       := l_arrival_set;
    -- 4405004
    x_atp_rec.part_of_set(I)            := p_part_of_set;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'PART OF SET FLAG :' || X_ATP_REC.part_of_set( I ) , 1 ) ;
    END IF;

    IF G_OVERRIDE_FLAG = 'Y' THEN
      x_atp_rec.Override_Flag(I)     := 'Y';
    ELSE
      IF l_action_code <> OESCH_ACT_ATP_CHECK THEN
        x_atp_rec.Override_Flag(I)     := p_line_rec.override_atp_date_code;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OVERRIDE_FLAG :' || X_ATP_REC.OVERRIDE_FLAG ( I ) , 1 ) ;
      END IF;
    END IF;

    x_atp_rec.Ship_Date(I)              := null;
    x_atp_rec.Available_Quantity(I)     := null;
    x_atp_rec.Requested_Date_Quantity(I) := null;
    x_atp_rec.Group_Ship_Date(I)        := null;
    x_atp_rec.Group_Arrival_Date(I)     := null;
    x_atp_rec.Vendor_Id(I)              := null;
    x_atp_rec.Vendor_Site_Id(I)         := null;
    x_atp_rec.Insert_Flag(I)            := l_insert_flag;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INSERT FLAG IN ATP_REC : '||X_ATP_REC.INSERT_FLAG ( I ) , 3 ) ;
    END IF;
    x_atp_rec.Error_Code(I)             := null;
    x_atp_rec.Message(I)                := null;


    IF p_line_rec.source_document_type_id = 10 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IT IS AN INTERNAL ORDER ' , 3 ) ;
      END IF;
      l_oe_flag := 'Y';

      IF (p_line_rec.schedule_ship_date IS NOT NULL AND
          p_line_rec.schedule_ship_date <> FND_API.G_MISS_DATE ) OR
         (p_line_rec.schedule_arrival_date IS NOT NULL AND
          p_line_rec.schedule_arrival_date <> FND_API.G_MISS_DATE ) THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NO CHANGES TO DATE AS IT HAS BEEN PASSED' , 3 ) ;
          END IF;
      ELSE
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'PASS THE REQUEST DATE AS ARRIVAL DATE' , 3 ) ;
          END IF;

          x_atp_rec.Requested_ship_Date(I)  := null;
          x_atp_rec.Requested_arrival_Date(I) := p_line_rec.request_date;

      END IF;

      x_atp_rec.attribute_01(I) := p_line_rec.source_document_id;

    ELSE

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IT IS NOT AN INTERNAL ORDER ' , 3 ) ;
      END IF;
      l_oe_flag := 'N';

    END IF;

    x_atp_rec.oe_flag(I) := l_oe_flag;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OE FLAG IS : '||X_ATP_REC.OE_FLAG ( I ) , 3 ) ;
    END IF;

                             IF l_debug_level  > 0 THEN
                                 oe_debug_pub.add(  'REQUEST SHIP DATE : ' || TO_CHAR ( X_ATP_REC.REQUESTED_SHIP_DATE ( I ) , 'DD-MON-RR:HH:MM:SS' ) , 3 ) ;
                             END IF;
                             IF l_debug_level  > 0 THEN
                                 oe_debug_pub.add(  'REQUEST ARRIVAL DATE : ' || TO_CHAR ( X_ATP_REC.REQUESTED_ARRIVAL_DATE ( I ) , 'DD-MON-RR:HH:MM:SS' ) , 3 ) ;
                             END IF;

    IF (l_action_code = OE_SCHEDULE_UTIL.OESCH_ACT_ATP_CHECK) THEN
      x_atp_rec.Action(I)                    := 100;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'MRP ACTION: ' || X_ATP_REC.ACTION ( I ) , 3 ) ;
      END IF;
    ELSIF (l_action_code = OE_SCHEDULE_UTIL.OESCH_ACT_DEMAND) OR
          (l_action_code = OE_SCHEDULE_UTIL.OESCH_ACT_SCHEDULE)
    THEN
      x_atp_rec.Action(I)                    := 110;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'MRP ACTION: ' || X_ATP_REC.ACTION ( I ) , 3 ) ;
      END IF;
    ELSIF (l_action_code = OE_SCHEDULE_UTIL.OESCH_ACT_REDEMAND) OR
          (l_action_code = OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE)
    THEN
      x_atp_rec.Action(I)                     := 120;
      x_atp_rec.Old_Source_Organization_Id(I) :=
                          p_old_line_rec.ship_from_org_id;
      x_atp_rec.Old_Demand_Class(I)           :=
                          p_old_line_rec.demand_class_code;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'MRP ACTION: ' || X_ATP_REC.ACTION ( I ) , 3 ) ;
      END IF;
    ELSIF (l_action_code = OE_SCHEDULE_UTIL.OESCH_ACT_UNDEMAND)
    THEN
      x_atp_rec.Action(I)                    := 120;
      x_atp_rec.Quantity_Ordered(I)          := 0;
      x_atp_rec.Old_Source_Organization_Id(I) :=
                            p_old_line_rec.ship_from_org_id;
      x_atp_rec.Old_Demand_Class(I)           :=
                            p_old_line_rec.demand_class_code;

      /*L.G. OPM bug 1828340 jul 19,01*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'MRP ACTION: ' || X_ATP_REC.ACTION ( I ) , 3 ) ;
      END IF;
      -- Bug3361870 (commenting this piece of code. Not required)
     /*  IF INV_GMI_RSV_BRANCH.Process_Branch   -- INVCONV - delete this
         (p_organization_id => p_old_line_rec.ship_from_org_id)
      THEN
        Update oe_order_lines_all
        Set ordered_quantity = 0,
            ordered_quantity2 = 0
        Where line_id=p_old_line_rec.line_id;
      END IF; */
    END IF; -- action=**

IF OE_SCH_CONC_REQUESTS.g_conc_program = 'Y' THEN -- 9108353
    -- Schords (R12 Project #6403)
    IF p_line_rec.ship_model_complete_flag = 'N' AND
       p_line_rec.top_model_line_id IS NOT NULL AND
       (p_line_rec.ato_line_id IS NULL OR
        p_line_rec.ato_line_id <> p_line_rec.top_model_line_id) AND
       p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_INCLUDED THEN

       l_line_id_mod := MOD(p_line_rec.line_id,G_BINARY_LIMIT); --7827737
       --IF NOT OE_SCH_CONC_REQUESTS.included_processed(p_line_rec.line_id) THEN
       IF NOT OE_SCH_CONC_REQUESTS.included_processed(l_line_id_mod) THEN -- 9108353
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INCLUDED PROCESSED : ' || p_line_rec.line_id, 3 ) ;
          END IF;
          --5166476

          --OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(p_line_rec.line_id) := 'Y';
          OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_id_mod) :='Y';--7827737
          --OE_SCH_CONC_REQUESTS.g_process_records := OE_SCH_CONC_REQUESTS.g_process_records + 1;
       END IF;
    ELSE
       l_line_id_mod := MOD(p_line_rec.line_id,G_BINARY_LIMIT); --7827737
       IF OE_SCH_CONC_REQUESTS.g_recorded = 'N' THEN -- 5166476
          --5166476

          --OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(p_line_rec.line_id) := 'Y';
          OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_id_mod) := 'Y';--7827737
          --OE_SCH_CONC_REQUESTS.g_process_records
          --       := OE_SCH_CONC_REQUESTS.g_process_records + 1;
       END IF;
    END IF;
END IF; -- 9108353

    -- storing in local var to assing action to ato mandatory components
    -- to fix bug 1947539.

    l_action := x_atp_rec.Action(I);
    x_atp_rec.atp_lead_time(I)   := 0;
    IF p_line_rec.ato_line_id is not null AND
       p_line_rec.line_id <> p_line_rec.ato_line_id
    THEN

      -- This lines is a ato option or class.
      -- Set the atp_lead_time for it.

      IF p_line_rec.ato_line_id = l_st_ato_line_id
      THEN
        x_atp_rec.atp_lead_time(I)   := l_st_atp_lead_time;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ATO LEAD TIME IS ' || L_ST_ATP_LEAD_TIME , 3 ) ;
        END IF;
      ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING GET_LEAD_TIME' , 3 ) ;
        END IF;
        l_st_atp_lead_time :=
                     Get_Lead_Time
                     (p_ato_line_id      => p_line_rec.ato_line_id,
                      p_ship_from_org_id => p_line_rec.ship_from_org_id);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER CALLING GET_LEAD_TIME' , 3 ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LEAD TIME: ' || L_ST_ATP_LEAD_TIME , 3 ) ;
        END IF;

        x_atp_rec.atp_lead_time(I)   := l_st_atp_lead_time;
        l_st_ato_line_id := p_line_rec.ato_line_id;
      END IF;
    END IF;

    -- Item Substitution Code.

   -- Sunbstitution will be supported only for
   -- Standard not ATO item.
   -- Before booking
   -- Non internal order item
   -- Not on split line

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ITEM_TYPE_CODE :' || P_LINE_REC.ITEM_TYPE_CODE , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ATO_LINE_ID :' || P_LINE_REC.ATO_LINE_ID , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BOOKED_FLAG :' || P_LINE_REC.BOOKED_FLAG , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE_SET_ID :' || P_LINE_REC.LINE_SET_ID , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SOURCE_DOCUMENT_TYPE_ID :' || P_LINE_REC.SOURCE_DOCUMENT_TYPE_ID , 1 ) ;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.inventory_item_id,
                            p_old_line_rec.inventory_item_id)
    AND p_line_rec.schedule_status_code is NOT NULL THEN

     l_line_id_mod := MOD(p_line_rec.line_id,G_BINARY_LIMIT); --7827737

     --IF OE_Item_Tbl.EXISTS(p_line_rec.line_id) THEN
     IF OE_Item_Tbl.EXISTS(l_line_id_mod) THEN    --7827737
        x_atp_rec.old_inventory_item_id(I) :=
                     OE_Item_Tbl(l_line_id_mod).inventory_item_id;   --7827737
                     --OE_Item_Tbl(p_line_rec.line_id).inventory_item_id;
        --OE_Item_Tbl.DELETE(p_line_rec.line_id);
        OE_Item_Tbl.DELETE(l_line_id_mod);  --7827737
     ELSE
        x_atp_rec.old_inventory_item_id(I) :=
                                      p_old_line_rec.inventory_item_id;
    END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OLD_ITEM ID :' || X_ATP_REC.OLD_INVENTORY_ITEM_ID ( I ) , 1 ) ;
     END IF;
    END IF;

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN

    --  Bug fix 2331427
     IF   p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD
     AND  p_line_rec.ato_line_id is null
     AND  ( NVL(p_line_rec.booked_flag,'N') = 'N' OR
            ( NVL(p_line_rec.booked_flag,'N') = 'Y' and
              NOT INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => p_line_rec.ship_from_org_id) and
              NVL(p_line_rec.reserved_quantity, 0) = 0  -- ER 6110708 Do not allow item substitutions for Booked lines if line is reserved
            )
          ) -- Modified for ER 6110708, allow item substitution for Booked Lines also, but do not allow for OPM after Booking
     AND  p_line_rec.line_set_id is null
     AND  nvl(p_line_rec.source_document_type_id,-99) <> 10
     THEN
        --  Set substution code to 1 when OM can allow substitution on th
        -- line. For atp check get the values from MRP to show the substitute
        -- item details by setting req_item_detail_flag to 1.

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE IS MARKED FOR SUBSTITUTION' , 1 ) ;
        END IF;
         x_atp_rec.substitution_typ_code(I) := 1;
         IF l_action_code = OESCH_ACT_ATP_CHECK THEN
            x_atp_rec.req_item_detail_flag(I) := 1;
         ELSE
           x_atp_rec.req_item_detail_flag(I) := 2;
         END IF;

     ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE IS NOT MARKED FOR SUBSTITUTION' , 1 ) ;
        END IF;
         x_atp_rec.substitution_typ_code(I) := 4;
         x_atp_rec.req_item_detail_flag(I) := 2;

     END IF;

    END IF;

    IF   OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
    AND  MSC_ATP_GLOBAL.GET_APS_VERSION = 10 THEN

      IF l_debug_level  > 0 THEN
       Oe_debug_pub.add('Do not explode SMC records',2);
      END IF;

      x_atp_rec.Included_item_flag(I)  := 1;
      x_atp_rec.top_model_line_id(I)   := p_line_rec.top_model_line_id;
      x_atp_rec.ato_model_line_id(I)   := p_line_rec.ato_line_id;
      x_atp_rec.parent_line_id(I)      := p_line_rec.link_to_line_id;
      x_atp_rec.validation_org(I)      :=
                  OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
      x_atp_rec.component_code(I)      :=  p_line_rec.component_code;
      x_atp_rec.component_sequence_id(I) := p_line_rec.component_sequence_id;
      x_atp_rec.line_number(I) :=
          OE_ORDER_MISC_PUB.GET_CONCAT_LINE_NUMBER(p_line_rec.line_id);


      IF(p_line_rec.ato_line_id IS NOT NULL AND
      NOT (p_line_rec.ato_line_id = p_line_rec.line_id AND
           p_line_rec.item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                         OE_GLOBALS.G_ITEM_OPTION,
					 OE_GLOBALS.G_ITEM_INCLUDED))) THEN --9775352

         x_atp_rec.config_item_line_id(I) := p_config_line_id ;

      END IF;

    ELSE

    l_inv_ctp :=  fnd_profile.value('INV_CTP');

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INV_CTP : '||L_INV_CTP , 3 ) ;
    END IF;


    IF p_line_rec.ato_line_id = p_line_rec.line_id AND
       (p_line_rec.item_type_code in ('MODEL','CLASS') OR
       (p_line_rec.item_type_code in ('STANDARD','OPTION','INCLUDED') AND --9775352
        l_inv_ctp = '5')) THEN

       l_explode := TRUE;
       -- Added this code to fix bug 1998613.
       IF p_line_rec.schedule_status_code is not null
          AND nvl(p_line_rec.ordered_quantity,0) <
                  p_old_line_rec.ordered_quantity
          AND p_old_line_rec.reserved_quantity > 0
          AND NOT Schedule_Attribute_Changed(p_line_rec     => p_line_rec,
                                             p_old_line_rec => p_old_line_rec)
          THEN

            IF l_debug_level  > 0 THEN
             oe_debug_pub.add('ONLY ORDERED QTY GOT REDUCED,NO EXPLOSION',3);
            END IF;
             l_explode := FALSE;

       END IF;
       IF l_explode THEN
    -- If the line scheduled is an ATO Model, call ATO's API
    -- to get the Standard Mandatory Components

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('ATO ITEM TYPE: '||P_LINE_REC.ITEM_TYPE_CODE,3);
        END IF;

        IF  p_line_rec.item_type_code = 'STANDARD' AND
            x_atp_rec.ship_set_name(I) is NULL THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ASSIGNING SHIP SET FOR ATO ITEM ' , 3 ) ;
            END IF;
            x_atp_rec.Ship_Set_Name(I)          := p_line_rec.ato_line_id;

        END IF;

        IF p_line_rec.item_type_code = 'STANDARD' THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'ASSIGNING WAREHOUSE AND ITEM ' , 3 ) ;
           END IF;
           l_organization_id := p_line_rec.ship_from_org_id;
           l_inventory_item_id := p_line_rec.inventory_item_id;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('WAREHOUSE/ITEM : '||L_ORGANIZATION_ID||'/' ||L_INVENTORY_ITEM_ID,3 ) ;
           END IF;

        ELSE

          l_organization_id := NULL;
        l_inventory_item_id := NULL;
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('WAREHOUSE/ITEM : '||L_ORGANIZATION_ID||'/' ||L_INVENTORY_ITEM_ID,3);
           END IF;

  END IF;

        --Load Model Rec to pass to ATO's API
        --Load Model Rec to pass to ATO's API

        l_model_rec.Inventory_Item_Id := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Inventory_Item_Id(I));

        l_model_rec.Source_Organization_Id := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Source_Organization_Id(I));

        l_model_rec.Identifier := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Identifier(I));

        l_model_rec.Calling_Module := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Calling_Module(I));

        l_model_rec.Customer_Id := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Customer_Id(I));

        l_model_rec.Customer_Site_Id := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Customer_Site_Id(I));

        l_model_rec.Destination_Time_Zone := MRP_ATP_PUB.char30_arr
                            (x_atp_rec.Destination_Time_Zone(I));

        l_model_rec.Quantity_Ordered := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Quantity_Ordered(I));

        l_model_rec.Quantity_UOM := MRP_ATP_PUB.char3_arr
                            (x_atp_rec.Quantity_UOM(I));

        l_model_rec.Earliest_Acceptable_Date := MRP_ATP_PUB.date_arr
                            (x_atp_rec.Earliest_Acceptable_Date(I));

        l_model_rec.Requested_Ship_Date := MRP_ATP_PUB.date_arr
                            (x_atp_rec.Requested_Ship_Date(I));

        l_model_rec.Requested_Arrival_Date := MRP_ATP_PUB.date_arr
                            (x_atp_rec.Requested_Arrival_Date(I));

        l_model_rec.Latest_Acceptable_Date := MRP_ATP_PUB.date_arr
                            (x_atp_rec.Latest_Acceptable_Date(I));

        l_model_rec.Delivery_Lead_Time := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Delivery_Lead_Time(I));

        l_model_rec.Atp_lead_Time := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Atp_lead_Time(I));

        l_model_rec.Freight_Carrier := MRP_ATP_PUB.char30_arr
                            (x_atp_rec.Freight_Carrier(I));

        l_model_rec.Ship_Method := MRP_ATP_PUB.char30_arr
                            (x_atp_rec.Ship_Method(I));

        l_model_rec.Demand_Class := MRP_ATP_PUB.char30_arr
                            (x_atp_rec.Demand_Class(I));

        l_model_rec.Ship_Set_Name := MRP_ATP_PUB.char30_arr
                            (x_atp_rec.Ship_Set_Name(I));

        l_model_rec.Arrival_Set_Name := MRP_ATP_PUB.char30_arr
                            (x_atp_rec.Arrival_Set_Name(I));

        l_model_rec.Override_Flag := MRP_ATP_PUB.char1_arr
                            (x_atp_rec.Override_Flag(I));

        l_model_rec.Ship_Date := MRP_ATP_PUB.date_arr
                            (x_atp_rec.Ship_Date(I));

        l_model_rec.Available_Quantity := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Available_Quantity(I));

        l_model_rec.Requested_Date_Quantity := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Requested_Date_Quantity(I));

        l_model_rec.Group_Ship_Date := MRP_ATP_PUB.date_arr
                            (x_atp_rec.Group_Ship_Date(I));

        l_model_rec.Group_Arrival_Date := MRP_ATP_PUB.date_arr
                            (x_atp_rec.Group_Arrival_Date(I));

        l_model_rec.Vendor_Id := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Vendor_Id(I));

        l_model_rec.Vendor_Site_Id := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Vendor_Site_Id(I));

        l_model_rec.Insert_Flag := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Insert_Flag(I));

        l_model_rec.Error_Code := MRP_ATP_PUB.number_arr
                            (x_atp_rec.Error_Code(I));

        l_model_rec.Message := MRP_ATP_PUB.char2000_arr
                            (x_atp_rec.Message(I));

        l_model_rec.Action  := MRP_ATP_PUB.number_arr
                            (x_atp_rec.action(I));

        l_model_rec.order_number  := MRP_ATP_PUB.number_arr
                            (x_atp_rec.order_number(I));

        IF x_atp_rec.Old_Source_Organization_Id.Exists(I) THEN
           l_model_rec.Old_Source_Organization_Id := MRP_ATP_PUB.number_arr
                               (x_atp_rec.Old_Source_Organization_Id(I));
        END IF;

        IF x_atp_rec.Old_Demand_Class.Exists(I) THEN
           l_model_rec.Old_Demand_Class  :=
                         MRP_ATP_PUB.char30_arr(x_atp_rec.Old_Demand_Class(I));
        END IF;

        BEGIN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  '2.. CALLING CTO GET_BOM_MANDATORY_COMPS' , 0.5 ) ; -- debug level changed to 0.5 for bug 13435459
             END IF;

             l_result := CTO_CONFIG_ITEM_PK.GET_MANDATORY_COMPONENTS
                         (p_ship_set           => l_model_rec,
                          p_organization_id    => l_organization_id,
                          p_inventory_item_id  => l_inventory_item_id,
                          x_smc_rec            => l_smc_rec,
                          xErrorMessage        => lErrorMessage,
                          xMessageName         => lMessageName,
                          xTableName           => lTableName);

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  '2..AFTER CALLING CTO API : ' || L_RESULT , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
             END IF;

        EXCEPTION
            WHEN OTHERS THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'CTO API RETURNED AN UNEXPECTED ERROR' ) ;
                END IF;
                l_result := 0;
        END;

        IF l_result = 1 AND
           l_smc_rec.Identifier.count >= 1 THEN
                              IF l_debug_level  > 0 THEN
                                  oe_debug_pub.add(  'SMC COUNT IS : ' || L_SMC_REC.IDENTIFIER.COUNT , 1 ) ;
                              END IF;

           Initialize_mrp_record(p_x_atp_rec => x_atp_rec,
                                 l_count   => l_smc_rec.Identifier.count);

           FOR J IN 1..l_smc_rec.Identifier.count LOOP
            I := I + 1;
            -- Added atp_lead_time, order Number to fix bug 1560461.
            x_atp_rec.atp_lead_time(I)   := 0;
            x_atp_rec.oe_flag(I) := l_oe_flag;

           -- As part of the bug fix 2910899, OM will indicate and remember the
           -- Standard Madatory record positions using vendor_name. This will be
           -- used in the load_results procedure to bypass the SMC records.

            x_atp_rec.vendor_name(I) := 'SMC';
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'OE FLAG IS : '||X_ATP_REC.OE_FLAG ( I ) , 3 ) ;
                 oe_debug_pub.add(  'SMC  : '|| I || ' iden :' ||
                                l_smc_rec.Identifier(J) , 3 ) ;
            END IF;

            x_atp_rec.Inventory_Item_Id(I)      := l_smc_rec.Inventory_Item_Id(J);
            x_atp_rec.Source_Organization_Id(I) :=
                                       l_smc_rec.Source_Organization_Id(J);

            x_atp_rec.Identifier(I)             := l_smc_rec.Identifier(J);
            x_atp_rec.Order_Number(I)           := p_order_number;
            x_atp_rec.Calling_Module(I)         := l_smc_rec.Calling_Module(J);
            x_atp_rec.Customer_Id(I)            := l_smc_rec.Customer_Id(J);
            x_atp_rec.Customer_site_Id(I)       := l_smc_rec.Customer_site_Id(J);
            x_atp_rec.Destination_Time_Zone(I)  :=
                                       l_smc_rec.Destination_Time_Zone(J);
            x_atp_rec.Quantity_Ordered(I)       := l_smc_rec.Quantity_Ordered(J);
            x_atp_rec.Quantity_UOM(I)           := l_smc_rec.Quantity_UOM(J);
            x_atp_rec.Earliest_Acceptable_Date(I) :=
                                       l_smc_rec.Earliest_Acceptable_Date(J);
            x_atp_rec.Requested_Ship_Date(I)    :=
                                       l_smc_rec.Requested_Ship_Date(J);
            x_atp_rec.Requested_Arrival_Date(I) :=
                                       l_smc_rec.Requested_Arrival_Date(J);
            x_atp_rec.Latest_Acceptable_Date(I) :=
                                       l_smc_rec.Latest_Acceptable_Date(J);
            x_atp_rec.Delivery_Lead_Time(I)     :=
                                       l_smc_rec.Delivery_Lead_Time(J);
            x_atp_rec.Freight_Carrier(I)        :=
                                       l_smc_rec.Freight_Carrier(J);
            x_atp_rec.Ship_Method(I)            :=
                                       l_smc_rec.Ship_Method(J);
            x_atp_rec.Demand_Class(I)           :=
                                       l_smc_rec.Demand_Class(J);
            x_atp_rec.Ship_Set_Name(I)          :=
                                       l_smc_rec.Ship_Set_Name(J);
            x_atp_rec.Arrival_Set_Name(I)       :=
                                       l_smc_rec.Arrival_Set_Name(J);
            x_atp_rec.Override_Flag(I)          :=
                                       l_smc_rec.Override_Flag(J);
            x_atp_rec.Ship_Date(I)              :=
                                       l_smc_rec.Ship_Date(J);
            x_atp_rec.Available_Quantity(I)     :=
                                       l_smc_rec.Available_Quantity(J);
            x_atp_rec.Requested_Date_Quantity(I):=
                                       l_smc_rec.Requested_Date_Quantity(J);
            x_atp_rec.Group_Ship_Date(I)        :=
                                       l_smc_rec.Group_Ship_Date(J);
            x_atp_rec.Group_Arrival_Date(I)     :=
                                       l_smc_rec.Group_Arrival_Date(J);
            x_atp_rec.Vendor_Id(I)              :=
                                       l_smc_rec.Vendor_Id(J);
            x_atp_rec.Vendor_Site_Id(I)         :=
                                       l_smc_rec.Vendor_Site_Id(J);
            x_atp_rec.Insert_Flag(I)            :=
                                       l_smc_rec.Insert_Flag(J);
            x_atp_rec.atp_lead_time(I)           :=
                                       l_smc_rec.atp_lead_time(J);
            x_atp_rec.Error_Code(I)  := l_smc_rec.Error_Code(J);
            x_atp_rec.Message(I)     := l_smc_rec.Message(J);
            x_atp_rec.Action(I)      := l_action;

            x_atp_rec.Old_Source_Organization_Id(I) :=
                          l_smc_rec.Old_Source_Organization_Id(J);
            x_atp_rec.Old_Demand_Class(I)           :=
                          l_smc_rec.Old_Demand_Class(J);

            -- Schords (R12 Project #6403)
            OE_SCH_CONC_REQUESTS.g_process_records := OE_SCH_CONC_REQUESTS.g_process_records + 1;
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INCLUDED TO PROCESSED : ' , 3 ) ;
            END IF;

           END LOOP;
        END IF; -- Identifier count is greater than 1.
       END IF; -- l_explode.
    END IF;  -- Need to explode smc.

    END IF; -- Code control
    P_index := I;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

     Raise FND_API.G_EXC_ERROR;
   WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Load_MRP_request');
        END IF;

End Load_MRP_request;

/*--------------------------------------------------------------------
Procedure Name : Load_MRP_request_from_rec
Description    :
  This procedure loads the MRP record or tables to be passed
  to MRP's API from the OM's table of records of order lines.

  If line line to be passed to MRP is an ATO model, we call
  CTO's GET_MANDATORY_COMPONENTS API to get the mandatory
  components, and we pass them along with the ATO model to MRP.
-------------------------------------------------------------------- */
Procedure Load_MRP_request_from_rec
( p_line_rec           IN  OE_ORDER_PUB.Line_rec_Type
 ,p_old_line_rec       IN  OE_ORDER_PUB.Line_rec_Type
 ,p_sch_action         IN  VARCHAR2 := NULL
,x_mrp_atp_rec OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ)

IS
  l_mrp_calc_sd       VARCHAR2(240);
  l_type_code         VARCHAR2(30);
  l_order_number      NUMBER;
  l_index             NUMBER := 1;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  l_mrp_calc_sd :=  fnd_profile.value('MRP_ATP_CALC_SD');

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'MRP_ATP_CALC_SD : '||L_MRP_CALC_SD , 3 ) ;
  END IF;

  l_type_code    := Get_Date_Type(p_line_rec.header_id);
  l_order_number := Get_Order_Number(p_line_rec.header_id);


    IF p_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_CONFIG THEN

       Initialize_mrp_record
       (p_x_atp_rec => x_mrp_atp_rec,
        l_count     => 1);


      Load_MRP_request
      ( p_line_rec       => p_line_rec
       ,p_old_line_rec   => p_old_line_rec
       ,p_sch_action     => p_sch_action
       ,p_mrp_calc_sd    => l_mrp_calc_sd
       ,p_type_code      => l_type_code
       ,p_order_number   => l_order_number
       ,p_index          => l_index
       ,x_atp_rec        => x_mrp_atp_rec);

    END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

     Raise FND_API.G_EXC_ERROR;

   WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Log_Set_Request');
        END IF;

END Load_MRP_request_from_rec;

/*--------------------------------------------------------------------
Procedure Name : Load_MRP_request_from_tbl
Description    :
  This procedure loads the MRP record or tables to be passed
  to MRP's API from the OM's table of records of order lines.

  If line line to be passed to MRP is an ATO model, we call
  CTO's GET_MANDATORY_COMPONENTS API to get the mandatory
  components, and we pass them along with the ATO model to MRP.

-------------------------------------------------------------------- */
Procedure Load_MRP_request_from_tbl
( p_line_tbl           IN  OE_ORDER_PUB.Line_Tbl_Type
 ,p_old_line_tbl       IN  OE_ORDER_PUB.Line_Tbl_Type
 ,p_partial_set        IN  BOOLEAN := FALSE
 ,p_sch_action         IN  VARCHAR2 := NULL
 ,p_part_of_set        IN  VARCHAR2 DEFAULT 'N' -- 4405004
,x_mrp_atp_rec OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ)

IS
  l_mrp_calc_sd       VARCHAR2(240);
  l_type_code         VARCHAR2(30);
  l_order_number      NUMBER;
  l_index             NUMBER := 0;
  l_config_count      NUMBER := 0;
  l_config_line_id    NUMBER;
  l_ato_line_id       NUMBER := -999;

  -- BUG 1955004
  l_inactive_demand_count NUMBER:= 0;
  l_scheduling_level_code VARCHAR2(30);
  l_line_id_mod       NUMBER;   --7827737

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING LOAD_MRP_REQUEST_FROM_TBL' , 1 ) ;
  END IF;
  l_mrp_calc_sd :=  fnd_profile.value('MRP_ATP_CALC_SD');

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'MRP_ATP_CALC_SD : '||L_MRP_CALC_SD , 3 ) ;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'COUNT OF NEW ' || P_LINE_TBL.COUNT , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'COUNT OF NEW ' || P_OLD_LINE_TBL.COUNT , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'FIRST ' || P_LINE_TBL.FIRST ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LAST ' || P_LINE_TBL.LAST ) ;
  END IF;

  l_type_code    := Get_Date_Type(p_line_tbl(1).header_id);
  l_order_number := Get_Order_Number(p_line_tbl(1).header_id);

  -- When config line is created on the model, we should not extend the
  -- ato table for config line, since we do not pass config line to MRP.

  IF p_sch_action = OESCH_ACT_RESCHEDULE OR
     p_sch_action = OESCH_ACT_UNSCHEDULE OR
     p_sch_action = OESCH_ACT_ATP_CHECK THEN
     FOR  cnt IN 1..p_line_tbl.count LOOP

        IF p_line_tbl(cnt).item_type_code = OE_GLOBALS.G_ITEM_CONFIG THEN

          l_config_count := l_config_count + 1;

        END IF;

     END LOOP;
  END IF;

   --BUG 1955004
  IF p_sch_action <> OESCH_ACT_ATP_CHECK THEN
  -- loop through the records to identify which need to bypass scheduling

    FOR I in 1..p_line_tbl.count LOOP

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'HEADER_ID IS : ' || P_LINE_TBL ( I ) .HEADER_ID ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE_TYPE_ID IS : ' || P_LINE_TBL ( I ) .LINE_TYPE_ID ) ;
      END IF;

      l_scheduling_level_code := Get_Scheduling_Level(p_line_tbl(I).header_id,
                                                   P_line_tbl(I).line_type_id);

      IF l_scheduling_level_code IS NULL THEN
         l_scheduling_level_code := SCH_LEVEL_THREE;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SCHEDULING LEVEL IS : ' || L_SCHEDULING_LEVEL_CODE ) ;
      END IF;

      --3763015
      IF l_scheduling_level_code = SCH_LEVEL_FOUR OR
         l_scheduling_level_code = SCH_LEVEL_FIVE  OR
         NVL(fnd_profile.value('ONT_BYPASS_ATP'),'N') = 'Y' OR
          Nvl(p_line_tbl(i).bypass_sch_flag, 'N') = 'Y' THEN  -- for DOO Integration

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INACTIVE DEMAND LINE , LINE_ID = ' || P_LINE_TBL.LAST ) ;
         END IF;

         l_line_id_mod :=MOD(p_line_tbl(I).line_id,G_BINARY_LIMIT); --7827737

         --OE_inactive_demand_tbl(p_line_tbl(I).line_id).line_id:=
         --                       P_line_tbl(I).line_id;
         OE_inactive_demand_tbl(l_line_id_mod).line_id:=
                                 P_line_tbl(I).line_id;              --7827737
         --OE_inactive_demand_tbl(p_line_tbl(I).line_id).scheduling_level_code:=
         --                       l_scheduling_level_code;
         OE_inactive_demand_tbl(l_line_id_mod).scheduling_level_code:=
                           l_scheduling_level_code;              --7827737

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INACTIVE DEMAND LINE' ) ;
         END IF;
                        IF l_debug_level  > 0 THEN
                           -- oe_debug_pub.add(  'LINE_ID = ' || OE_INACTIVE_DEMAND_TBL ( P_LINE_TBL ( I ) .LINE_ID ) .LINE_ID ) ;
                            oe_debug_pub.add(  'LINE_ID = ' || OE_INACTIVE_DEMAND_TBL (L_LINE_ID_MOD ) .LINE_ID ); --7827737;
                        END IF;
                        IF l_debug_level  > 0 THEN
                            --oe_debug_pub.add(  'SCHEDULING_LEVEL_CODE =' || OE_INACTIVE_DEMAND_TBL ( P_LINE_TBL ( I ) .LINE_ID ) .SCHEDULING_LEVEL_CODE ) ;
                            oe_debug_pub.add(  'SCHEDULING_LEVEL_CODE =' || OE_INACTIVE_DEMAND_TBL (L_LINE_ID_MOD ) .SCHEDULING_LEVEL_CODE ) ; --7827737
                        END IF;

         l_inactive_demand_count := l_inactive_demand_count + 1;

       END IF;

    END LOOP;
  END IF;
  --END 1955004

  Initialize_mrp_record
  (p_x_atp_rec  => x_mrp_atp_rec,
   l_count      => p_line_tbl.count - l_config_count - l_inactive_demand_count);  -- 1955004 added last minus

  FOR  cnt IN 1..p_line_tbl.count LOOP

    IF p_line_tbl(cnt).item_type_code <> OE_GLOBALS.G_ITEM_CONFIG THEN

       --1955004
      --IF OE_inactive_demand_tbl.EXISTS(p_line_tbl(cnt).line_id) THEN
       IF  OE_inactive_demand_tbl.EXISTS(MOD(p_line_tbl(cnt).line_id,G_BINARY_LIMIT))
        THEN --7827737
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SKIPPING LOAD_MRP_REQUEST BECAUSE INACTIVE DEMAND LINE' ) ;
          END IF;
        NULL; -- skip this record
      ELSE
      --END 1955004

      IF l_config_count > 0
      AND p_line_tbl(cnt).ato_line_id is not null
      AND p_line_tbl(cnt).ato_line_id <> l_ato_line_id
      AND NOT(p_line_tbl(cnt).ato_line_id = p_line_tbl(cnt).line_id
          AND (p_line_tbl(cnt).item_type_code = OE_GLOBALS.G_ITEM_STANDARD
          OR   p_line_tbl(cnt).item_type_code = OE_GLOBALS.G_ITEM_OPTION
	  OR p_line_tbl(cnt).item_type_code = OE_GLOBALS.G_ITEM_INCLUDED)) --9775352
      THEN

          l_ato_line_id := p_line_tbl(cnt).ato_line_id;


          BEGIN

            Select line_id
            Into   l_config_line_id
            From   oe_order_lines_all
            Where  ato_line_id = p_line_tbl(cnt).ato_line_id
            And    item_type_code = 'CONFIG';

          EXCEPTION

            WHEN Others THEN

              l_config_line_id := Null;

          END;

      END IF;

      l_index := l_index + 1;

      Load_MRP_request
      ( p_line_rec       => p_line_tbl(cnt)
       ,p_old_line_rec   => p_old_line_tbl(cnt)
       ,p_sch_action     => p_sch_action
       ,p_mrp_calc_sd    => l_mrp_calc_sd
       ,p_type_code      => l_type_code
       ,p_order_number   => l_order_number
       ,p_partial_set    => p_partial_set
       ,p_config_line_id => l_config_line_id
       ,p_part_of_set    => p_part_of_set --4405004
       ,p_index          => l_index
       ,x_atp_rec        => x_mrp_atp_rec);

      END IF; -- 1955004 check for inactive_demand
    END IF;

  END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING LOAD_MRP_REQUEST_FROM_TBL' , 1 ) ;
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     Raise FND_API.G_EXC_ERROR;

   WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Load_MRP_request_from_tbl');
        END IF;
END Load_MRP_request_from_tbl;

/*--------------------------------------------------------------------------
Procedure Name : Load_Results_from_rec
Description    : This API loads the results from MRP's ATP_REC_TYPE to
                 OM's order line. It also populates OM's ATP Table which
                 is used to display the ATP results on the client side.
                 We ignore the mandatory components which we passed to MRP
                 while loading the results.
-------------------------------------------------------------------------- */
Procedure Load_Results_from_rec
( p_atp_rec         IN  MRP_ATP_PUB.ATP_Rec_Typ
, p_x_line_rec      IN  OUT NOCOPY OE_ORDER_PUB.line_rec_type
, p_index           IN  NUMBER := 1
, p_sch_action      IN  VARCHAR2 := NULL
, p_config_exists   IN  VARCHAR2 := 'N'
, p_partial_set     IN BOOLEAN := FALSE
, x_return_status OUT NOCOPY VARCHAR2)

IS
J                  NUMBER := p_index;
atp_count          NUMBER := 1;
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_explanation      VARCHAR2(80);
l_type_code        VARCHAR2(30);
l_ship_set_name    VARCHAR2(30);
l_arrival_set_name VARCHAR2(30);
l_arrival_date     DATE := NULL;
l_sch_action       VARCHAR2(30) := p_sch_action;
l_organization_id  NUMBER;
l_inventory_item   VARCHAR2(2000);
l_order_date_type_code VARCHAR2(30);
l_return_status   VARCHAR2(1);  -- Added for IR ISO CMS Project
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_old_ship_from_org_id  number; -- Added for ER 6110708
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '2. ENTERING LOAD_RESULTS_FROM_REC' , 1 ) ;
  END IF;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  IF l_sch_action is NULL THEN
     l_sch_action := p_x_line_rec.schedule_action_code;
  END IF;

  atp_count := g_atp_tbl.count + 1;
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('-----------------Loading MRP Result---------------',1);
     oe_debug_pub.add( 'MRP COUNT IS ' || P_ATP_REC.ERROR_CODE.COUNT , 1 ) ;
     oe_debug_pub.add(  'SCHEDULE ACTION CODE ' || L_SCH_ACTION , 1 ) ;
  END IF;

     -- Check for the MRP data. If MRP is not returning any data, then
     -- raise an error.

     IF p_atp_rec.error_code.count = 0 THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'MRP HAS RETURNED ANY DATA' , 1 ) ;
        END IF;

        FND_MESSAGE.SET_NAME('ONT','OE_SCH_ATP_ERROR');
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END IF;
     -- 4504197
     l_order_date_type_code :=
            NVL(Get_Date_Type(p_x_line_rec.header_id), 'SHIP');

     -- 4535580 Start
     IF p_atp_rec.error_code(J) <> -99  THEN --5673809
      --  p_atp_rec.error_code(J) <> 150  THEN

        -- Populate the inventory_item_id from atp record so that, if there is any
        -- substitution, then substitution item will come into inventory_item_id
        g_atp_tbl(atp_count).request_item_id     := p_x_line_rec.inventory_item_id;
        g_atp_tbl(atp_count).inventory_item_id   := p_atp_rec.inventory_item_id(J);
        g_atp_tbl(atp_count).ordered_quantity    := p_x_line_rec.ordered_quantity;
        g_atp_tbl(atp_count).order_quantity_uom  := p_x_line_rec.order_quantity_uom;
        g_atp_tbl(atp_count).request_date        := p_x_line_rec.request_date;
        g_atp_tbl(atp_count).ship_from_org_id    :=
                    p_atp_rec.Source_Organization_Id(J);
        g_atp_tbl(atp_count).subinventory_code := p_x_line_rec.subinventory; --11777419
        g_atp_tbl(atp_count).qty_on_request_date :=
                    p_atp_rec.Requested_Date_Quantity(J);
        g_atp_tbl(atp_count).ordered_qty_Available_Date :=
                    p_atp_rec.Ship_Date(J);
        g_atp_tbl(atp_count).qty_on_available_date  :=
                    p_atp_rec.Available_Quantity(J);
        --4504197
        IF l_order_date_type_code = 'SHIP' THEN
           g_atp_tbl(atp_count).group_available_date  :=
                    p_atp_rec.group_ship_date(J);
        ELSIF p_atp_rec.group_arrival_date(J) is not null THEN
           g_atp_tbl(atp_count).group_available_date  :=
                    p_atp_rec.group_arrival_date(J);
        END IF;

        -- Display Values
        g_atp_tbl(atp_count).line_id         := p_x_line_rec.line_id;
        g_atp_tbl(atp_count).header_id       := p_x_line_rec.header_id;
        g_atp_tbl(atp_count).line_number     := p_x_line_rec.line_number;
        g_atp_tbl(atp_count).shipment_number := p_x_line_rec.shipment_number;
        g_atp_tbl(atp_count).option_number   := p_x_line_rec.option_number;
        g_atp_tbl(atp_count).component_number := p_x_line_rec.component_number;
        g_atp_tbl(atp_count).item_input      := p_x_line_rec.ordered_item;
        g_atp_tbl(atp_count).error_message   := l_explanation;
        --4772886
        g_atp_tbl(atp_count).org_id := p_x_line_rec.org_id;

        IF p_x_line_rec.ship_set_id is not null THEN
           BEGIN
              SELECT SET_NAME
              INTO l_ship_set_name
              FROM OE_SETS
              WHERE set_id = p_x_line_rec.ship_set_id;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 l_ship_set_name := null;
           END;
        END IF;
        IF p_x_line_rec.arrival_set_id is not null THEN
           BEGIN
              SELECT SET_NAME
              INTO l_arrival_set_name
              FROM OE_SETS
              WHERE set_id = p_x_line_rec.arrival_set_id;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 l_arrival_set_name := null;
           END;
        END IF;

        g_atp_tbl(atp_count).ship_set    := l_ship_set_name;
        g_atp_tbl(atp_count).arrival_set := l_arrival_set_name;

        IF p_atp_rec.inventory_item_id(J) <> p_x_line_rec.inventory_item_id  THEN

           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SUBSTITUTION OCCURED' , 1 ) ;
              oe_debug_pub.add(  'SUB ITEM :' || P_ATP_REC.INVENTORY_ITEM_ID ( J ) , 1 ) ;
              oe_debug_pub.add(  'ORIG ITEM :' || P_ATP_REC.REQUEST_ITEM_ID ( J ) , 1 ) ;
              oe_debug_pub.add(  'ORIG NAME :' || P_ATP_REC.REQUEST_ITEM_NAME ( J ) , 1 ) ;
              oe_debug_pub.add(  'ORIG REQ_ITEM_REQ_DATE_QTY :'|| P_ATP_REC.REQ_ITEM_REQ_DATE_QTY ( J ) , 1 ) ;
              oe_debug_pub.add(  'ORIG REQ_ITEM_AVAILABLE_DATE_QTY :' || P_ATP_REC.REQ_ITEM_AVAILABLE_DATE ( J ) , 1 ) ;
              oe_debug_pub.add(  'ORIG REQ_ITEM_AVAILABLE_DATE :' || P_ATP_REC.REQ_ITEM_AVAILABLE_DATE ( J ) , 1 ) ;

              oe_debug_pub.add(  'SUB QTY_ON_REQUEST_DATE :'|| P_ATP_REC.REQUESTED_DATE_QUANTITY ( J ) , 1 ) ;
              oe_debug_pub.add(  'SUB ORDERED_QTY_AVAILABLE_DATE :' || P_ATP_REC.SHIP_DATE ( J ) , 1 ) ;
              oe_debug_pub.add(  'SUB QTY_ON_AVAILABLE_DATE :' || P_ATP_REC.AVAILABLE_QUANTITY ( J ) , 1 ) ;
           END IF;

              --g_atp_tbl(atp_count).request_item_id
               --                    := p_atp_rec.request_item_id(J);
           g_atp_tbl(atp_count).Request_item_name
                                   := p_atp_rec.request_item_name(J);
           g_atp_tbl(atp_count).req_item_req_date_qty
                                   := p_atp_rec.req_item_req_date_qty(J);
           g_atp_tbl(atp_count).req_item_available_date_qty
                                   := p_atp_rec.req_item_available_date_qty(J);
           g_atp_tbl(atp_count).req_item_available_date
                                   := p_atp_rec.req_item_available_date(J);
           g_atp_tbl(atp_count).substitute_flag := 'Y';
           g_atp_tbl(atp_count).substitute_item_name
                                    := p_atp_rec.inventory_item_name(J);
        ELSE
           g_atp_tbl(atp_count).substitute_flag := 'N';
        END IF;

        l_organization_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
           --parameter change made below to fix bug 2819093
        OE_ID_TO_VALUE.Ordered_Item
            (p_Item_Identifier_type  => p_x_line_rec.item_identifier_type
            ,p_inventory_item_id     => p_x_line_rec.inventory_item_id
            ,p_organization_id       => l_organization_id
            ,p_ordered_item_id       => p_x_line_rec.ordered_item_id
            ,p_sold_to_org_id        => p_x_line_rec.sold_to_org_id
            ,p_ordered_item          => p_x_line_rec.ordered_item
            ,x_ordered_item          => g_atp_tbl(atp_count).Ordered_item_name
            ,x_inventory_item        => l_inventory_item);

        OE_ID_TO_VALUE.Ordered_Item
            (p_Item_Identifier_type => 'INT'
            ,p_inventory_item_id    => p_atp_rec.inventory_item_id(J)
            ,p_organization_id      => l_organization_id
            ,p_ordered_item_id      => Null
            ,p_sold_to_org_id       => Null
            ,p_ordered_item         => Null
            ,x_ordered_item         => g_atp_tbl(atp_count).Substitute_item_name
            ,x_inventory_item       => l_inventory_item);

     END IF;
     -- 4535580 End

     IF p_atp_rec.error_code(J) <> 0 AND
        l_sch_action <>   OESCH_ACT_ATP_CHECK AND
        p_atp_rec.error_code(J) <> -99  AND -- Multi org changes.
        p_atp_rec.error_code(J) <> 150 -- to fix bug 1880166

     THEN

        -- Schords (R12 Project #6403)
        --5166476
        IF OE_SCH_CONC_REQUESTS.g_recorded = 'N' THEN
           --OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(p_x_line_rec.line_id) := 'N';
          OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(MOD(p_x_line_rec.line_id,G_BINARY_LIMIT)):='N';--7827737
           OE_SCH_CONC_REQUESTS.g_recorded :='Y';
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ERROR FROM MRP: ' || P_ATP_REC.ERROR_CODE ( J ) , 1 ) ;
        END IF;
        IF p_atp_rec.error_code(J) = 80 THEN

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_SOURCE');
             OE_MSG_PUB.Add;

        ELSE

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SCHEDULING FAILED' , 1 ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  P_ATP_REC.ERROR_CODE ( J ) , 1 ) ;
            END IF;

            OE_MSG_PUB.set_msg_context(
             p_entity_code                 => 'LINE'
             ,p_entity_id                  => p_x_line_rec.line_id
             ,p_header_id                  => p_x_line_rec.header_id
             ,p_line_id                    => p_x_line_rec.line_id
             ,p_order_source_id            => p_x_line_rec.order_source_id
             ,p_orig_sys_document_ref      => p_x_line_rec.orig_sys_document_ref
             ,p_orig_sys_document_line_ref => p_x_line_rec.orig_sys_line_ref
             ,p_orig_sys_shipment_ref      => p_x_line_rec.orig_sys_shipment_ref
             ,p_change_sequence            => p_x_line_rec.change_sequence
             ,p_source_document_type_id    => p_x_line_rec.source_document_type_id
             ,p_source_document_id         => p_x_line_rec.source_document_id
             ,p_source_document_line_id    => p_x_line_rec.source_document_line_id );

            l_explanation := null;

            select meaning
            into l_explanation
            from mfg_lookups where
            lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
            and lookup_code = p_atp_rec.error_code(J) ;
            --4535580
            g_atp_tbl(atp_count).error_message   := l_explanation;

            IF p_atp_rec.error_code(J) = 19 THEN
             -- This error code is given for those lines which are
             -- in a group and whose scheduling failed due to some other lines.
             -- We do not want to give this out as a message.
             null;
            ELSIF OESCH_PERFORM_GRP_SCHEDULING = 'N'  THEN

             -- Flag OESCH_PERFORM_GRP_SCHEDULING is set to 'N' when
             -- scheduling is called from delayed request to schedule
             -- a line being inserted into a set. If there is an error,
             -- we will be trying to schedule the whole set again, so
             -- we should not display this error message.
             null;
            -- Commenting Code to fix the Bug-2487471
            /*  ELSIF p_atp_rec.Ship_Set_Name(J) is not null OR
                  p_atp_rec.Arrival_Set_Name(J) is not null THEN

             -- This line belongs to a scheduling group. We do not want
             -- to give out individual messages for each line. We will store
             -- them in atp_tbl which can be displayed by the user.
             null;
           */
            ELSIF p_partial_set THEN
               -- This call is made by schedule_set_lines procedure.
               -- No need to set the message here. Caller will take care
               -- of setting the message in this scenario.
               Null;
            ELSE
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'ADDING MESSAGE TO THE STACK' , 1 ) ;
              END IF;
              -- 4558018
              IF  p_atp_rec.Ship_Date(J) IS NOT NULL THEN
                 FND_MESSAGE.SET_NAME('ONT','ONT_SCH_FAILED_WITH_DATE');
                 FND_MESSAGE.SET_TOKEN('EXPLANATION',l_explanation);
                 FND_MESSAGE.SET_TOKEN('NEXT_DATE',p_atp_rec.Ship_Date(J));

              ELSE
                 FND_MESSAGE.SET_NAME('ONT','OE_SCH_OE_ORDER_FAILED');
                 FND_MESSAGE.SET_TOKEN('EXPLANATION',l_explanation);
              END IF;
              OE_MSG_PUB.Add;
            END IF;
        END IF; -- 80

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING ERROR' , 1 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;



     ELSE

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LOADING ATP RECORD' , 1 ) ;
            oe_debug_pub.add(  P_ATP_REC.SOURCE_ORGANIZATION_ID ( 1 ) , 1 ) ;

            oe_debug_pub.add(  'ERROR CODE : ' || P_ATP_REC.ERROR_CODE ( J ) , 1 ) ;
        END IF;
        -- Muti org changes.
      IF (p_atp_rec.error_code(J) <> -99 ) THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  '3. ERROR CODE : ' || P_ATP_REC.ERROR_CODE ( J ) , 1 ) ;
            oe_debug_pub.add(  '3. J : ' || J , 3 ) ;
            oe_debug_pub.add(  '3. IDENTIFIER : ' || P_ATP_REC.IDENTIFIER ( J ) , 1 ) ;
            oe_debug_pub.add(  '3. ITEM : ' || P_ATP_REC.INVENTORY_ITEM_ID ( J ) , 1 ) ;
        END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  '3.REQUEST SHIP DATE :' || TO_CHAR ( P_ATP_REC.REQUESTED_SHIP_DATE ( J ) , 'DD-MON-RR:HH:MI:SS' ) , 1 ) ;
              oe_debug_pub.add(  '3.REQUEST ARRIVAL DATE :' || P_ATP_REC.REQUESTED_ARRIVAL_DATE ( J ) , 1 ) ;
              oe_debug_pub.add(  '3.SHIP DATE :' || TO_CHAR ( P_ATP_REC.SHIP_DATE ( J ) , 'DD-MON-RR:HH:MI:SS' ) , 1 ) ;
              oe_debug_pub.add(  '3.ARRIVAL DATE :' || TO_CHAR ( P_ATP_REC.ARRIVAL_DATE ( J ) , 'DD-MON-RR:HH:MI:SS' ) , 1 ) ;
              oe_debug_pub.add(  '3.LEAD TIME :' || P_ATP_REC.DELIVERY_LEAD_TIME ( J ) , 1 ) ;
              oe_debug_pub.add(  '3.LEAD TIME :' || P_ATP_REC.DELIVERY_LEAD_TIME ( J ) , 1 ) ;
              oe_debug_pub.add(  '3.GROUP SHIP DATE :' || P_ATP_REC.GROUP_SHIP_DATE ( J ) , 1 ) ;
              oe_debug_pub.add(  '3.GROUP ARRIVAL DATE :' || P_ATP_REC.GROUP_ARRIVAL_DATE ( J ) , 1 ) ;
         END IF;

        IF l_sch_action = OESCH_ACT_ATP_CHECK THEN

           l_explanation := null;

           IF (p_atp_rec.error_code(J) <> 0) THEN

              BEGIN
                 select meaning
                 into l_explanation
                 from mfg_lookups where
                 lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
                 and lookup_code = p_atp_rec.error_code(J) ;

                 g_atp_tbl(atp_count).error_message   := l_explanation;
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'EXPLANATION IS : ' || L_EXPLANATION , 1 ) ;
                 END IF;

              /*   IF p_atp_rec.error_code(J) = 150 THEN -- to fix bug 1880166.
                    OE_MSG_PUB.add_text(l_explanation);
                 END IF;
              */ -- 2393433.
              EXCEPTION
                 WHEN OTHERS THEN
                   Null;
              END;

           END IF;

           -- Populate the inventory_item_id from atp record so that, if there is any
           -- substitution, then substitution item will come into inventory_item_id
           g_atp_tbl(atp_count).request_item_id     := p_x_line_rec.inventory_item_id;
           g_atp_tbl(atp_count).inventory_item_id   := p_atp_rec.inventory_item_id(J);
           g_atp_tbl(atp_count).ordered_quantity    := p_x_line_rec.ordered_quantity;
           g_atp_tbl(atp_count).order_quantity_uom  := p_x_line_rec.order_quantity_uom;
           g_atp_tbl(atp_count).request_date        := p_x_line_rec.request_date;
           g_atp_tbl(atp_count).ship_from_org_id    :=
                    p_atp_rec.Source_Organization_Id(J);
           g_atp_tbl(atp_count).subinventory_code := p_x_line_rec.subinventory; --11777419
           g_atp_tbl(atp_count).qty_on_request_date :=
                    p_atp_rec.Requested_Date_Quantity(J);
           g_atp_tbl(atp_count).ordered_qty_Available_Date :=
                    p_atp_rec.Ship_Date(J);
           g_atp_tbl(atp_count).qty_on_available_date  :=
                    p_atp_rec.Available_Quantity(J);
           --4504197
           IF l_order_date_type_code = 'SHIP' THEN
              g_atp_tbl(atp_count).group_available_date  :=
                    p_atp_rec.group_ship_date(J);
           ELSIF p_atp_rec.group_arrival_date(J) is not null THEN
             g_atp_tbl(atp_count).group_available_date  :=
                    p_atp_rec.group_arrival_date(J);
           END IF;

           -- Display Values
           g_atp_tbl(atp_count).line_id         := p_x_line_rec.line_id;
           g_atp_tbl(atp_count).header_id       := p_x_line_rec.header_id;
           g_atp_tbl(atp_count).line_number     := p_x_line_rec.line_number;
           g_atp_tbl(atp_count).shipment_number := p_x_line_rec.shipment_number;
           g_atp_tbl(atp_count).option_number   := p_x_line_rec.option_number;
           g_atp_tbl(atp_count).component_number := p_x_line_rec.component_number;
           g_atp_tbl(atp_count).item_input      := p_x_line_rec.ordered_item;
           g_atp_tbl(atp_count).error_message   := l_explanation;
           --4772886
           g_atp_tbl(atp_count).org_id  := p_x_line_rec.org_id;

           IF p_x_line_rec.ship_set_id is not null THEN
             BEGIN
                SELECT SET_NAME
                INTO l_ship_set_name
                FROM OE_SETS
                WHERE set_id = p_x_line_rec.ship_set_id;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_ship_set_name := null;
             END;
           END IF;

           IF p_x_line_rec.arrival_set_id is not null THEN
             BEGIN
                SELECT SET_NAME
                INTO l_arrival_set_name
                FROM OE_SETS
                WHERE set_id = p_x_line_rec.arrival_set_id;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_arrival_set_name := null;
             END;
           END IF;

           g_atp_tbl(atp_count).ship_set    := l_ship_set_name;
           g_atp_tbl(atp_count).arrival_set := l_arrival_set_name;

           IF p_atp_rec.inventory_item_id(J) <> p_x_line_rec.inventory_item_id
           THEN

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'SUBSTITUTION OCCURED' , 1 ) ;
                  oe_debug_pub.add(  'SUB ITEM :' || P_ATP_REC.INVENTORY_ITEM_ID ( J ) , 1 ) ;
                  oe_debug_pub.add(  'ORIG ITEM :' || P_ATP_REC.REQUEST_ITEM_ID ( J ) , 1 ) ;
                  oe_debug_pub.add(  'ORIG NAME :' || P_ATP_REC.REQUEST_ITEM_NAME ( J ) , 1 ) ;
                  oe_debug_pub.add(  'ORIG REQ_ITEM_REQ_DATE_QTY :'|| P_ATP_REC.REQ_ITEM_REQ_DATE_QTY ( J ) , 1 ) ;
                  oe_debug_pub.add(  'ORIG REQ_ITEM_AVAILABLE_DATE_QTY :' || P_ATP_REC.REQ_ITEM_AVAILABLE_DATE ( J ) , 1 ) ;
                  oe_debug_pub.add(  'ORIG REQ_ITEM_AVAILABLE_DATE :' || P_ATP_REC.REQ_ITEM_AVAILABLE_DATE ( J ) , 1 ) ;

                  oe_debug_pub.add(  'SUB QTY_ON_REQUEST_DATE :'|| P_ATP_REC.REQUESTED_DATE_QUANTITY ( J ) , 1 ) ;
                  oe_debug_pub.add(  'SUB ORDERED_QTY_AVAILABLE_DATE :' || P_ATP_REC.SHIP_DATE ( J ) , 1 ) ;
                  oe_debug_pub.add(  'SUB QTY_ON_AVAILABLE_DATE :' || P_ATP_REC.AVAILABLE_QUANTITY ( J ) , 1 ) ;
              END IF;


              --g_atp_tbl(atp_count).request_item_id
               --                    := p_atp_rec.request_item_id(J);
              g_atp_tbl(atp_count).Request_item_name
                                   := p_atp_rec.request_item_name(J);
              g_atp_tbl(atp_count).req_item_req_date_qty
                                   := p_atp_rec.req_item_req_date_qty(J);
              g_atp_tbl(atp_count).req_item_available_date_qty
                                   := p_atp_rec.req_item_available_date_qty(J);
              g_atp_tbl(atp_count).req_item_available_date
                                   := p_atp_rec.req_item_available_date(J);
              g_atp_tbl(atp_count).substitute_flag := 'Y';

              g_atp_tbl(atp_count).substitute_item_name
                                      := p_atp_rec.inventory_item_name(J);
           ELSE
             g_atp_tbl(atp_count).substitute_flag := 'N';
           END IF;

           l_organization_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
           --parameter change made below to fix bug 2819093
           OE_ID_TO_VALUE.Ordered_Item
            (p_Item_Identifier_type  => p_x_line_rec.item_identifier_type
            ,p_inventory_item_id     => p_x_line_rec.inventory_item_id
            ,p_organization_id       => l_organization_id
            ,p_ordered_item_id       => p_x_line_rec.ordered_item_id
            ,p_sold_to_org_id        => p_x_line_rec.sold_to_org_id
            ,p_ordered_item          => p_x_line_rec.ordered_item
            ,x_ordered_item          => g_atp_tbl(atp_count).Ordered_item_name
            ,x_inventory_item        => l_inventory_item);

           OE_ID_TO_VALUE.Ordered_Item
            (p_Item_Identifier_type => 'INT'
            ,p_inventory_item_id    => p_atp_rec.inventory_item_id(J)
            ,p_organization_id      => l_organization_id
            ,p_ordered_item_id      => Null
            ,p_sold_to_org_id       => Null
            ,p_ordered_item         => Null
            ,x_ordered_item         => g_atp_tbl(atp_count).Substitute_item_name
            ,x_inventory_item       => l_inventory_item);



        END IF; -- Check for ATP.
      END IF; --Check for -99.

      IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
         l_sch_action <> OESCH_ACT_ATP_CHECK
      THEN
        -- code fix for 3502139
        OE_MSG_PUB.set_msg_context(
         p_entity_code                 => 'LINE'
         ,p_entity_id                  => p_x_line_rec.line_id
         ,p_header_id                  => p_x_line_rec.header_id
         ,p_line_id                    => p_x_line_rec.line_id
         ,p_order_source_id            => p_x_line_rec.order_source_id
         ,p_orig_sys_document_ref      => p_x_line_rec.orig_sys_document_ref
         ,p_orig_sys_document_line_ref => p_x_line_rec.orig_sys_line_ref
         ,p_orig_sys_shipment_ref      => p_x_line_rec.orig_sys_shipment_ref
         ,p_change_sequence            => p_x_line_rec.change_sequence
         ,p_source_document_type_id    => p_x_line_rec.source_document_type_id
         ,p_source_document_id         => p_x_line_rec.source_document_id
         ,p_source_document_line_id    => p_x_line_rec.source_document_line_id );
        -- code fix for 3502139
        --8731703 : Code moved from Call_MRP_ATP
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  '6378240 : inserted the line_id into temp table '||p_x_line_rec.line_id ||'  ' ||p_x_line_rec.schedule_action_code);
         END IF;
         BEGIN
            insert into oe_schedule_lines_temp
                   (LINE_ID ,
                    SCHEDULE_ACTION_CODE)
              values(p_x_line_rec.line_id,p_x_line_rec.schedule_action_code);
         EXCEPTION
            WHEN OTHERS THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  '6378240 : INSERT ERROR ');
              END IF;
         END;
         --  8731703 end
        IF l_sch_action = OESCH_ACT_DEMAND
        OR l_sch_action = OESCH_ACT_SCHEDULE
        THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LOADING RESULTS OF SCHEDULE' , 1 ) ;
              oe_debug_pub.add(  '1.REQUEST SHIP DATE :' || TO_CHAR ( P_ATP_REC.REQUESTED_SHIP_DATE ( J ) , 'DD-MON-RR:HH:MI:SS' ) , 1 ) ;
             oe_debug_pub.add(  '1.REQUEST ARRIVAL DATE :' || P_ATP_REC.REQUESTED_ARRIVAL_DATE ( J ) , 1 ) ;
             oe_debug_pub.add(  '1.SHIP DATE :' || TO_CHAR ( P_ATP_REC.SHIP_DATE ( J ) , 'DD-MON-RR:HH:MI:SS' ) , 1 ) ;
             oe_debug_pub.add(  '1.ARRIVAL DATE :' || TO_CHAR ( P_ATP_REC.ARRIVAL_DATE ( J ) , 'DD-MON-RR:HH:MI:SS' ) , 1 ) ;
             oe_debug_pub.add(  '1.LEAD TIME :' || P_ATP_REC.DELIVERY_LEAD_TIME ( J ) , 1 ) ;
             oe_debug_pub.add(  '1.GROUP SHIP DATE :' || P_ATP_REC.GROUP_SHIP_DATE ( J ) , 1 ) ;
             oe_debug_pub.add(  '1.GROUP ARRIVAL DATE :' || P_ATP_REC.GROUP_ARRIVAL_DATE ( J ) , 1 ) ;
          END IF;

          l_old_ship_from_org_id := p_x_line_rec.ship_from_org_id; -- Added for ER 6110708

          p_x_line_rec.ship_from_org_id      :=
                                p_atp_rec.Source_Organization_Id(J);

          -- If the item subtitution occurs on the line then populate
          -- new inventory item from atp record and also populate
          -- Original inventory items.

          IF p_atp_rec.inventory_item_id(J)  <>  p_x_line_rec.inventory_item_id THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'SCH: ITEM HAS BEEN SUBSTITUTED' , 1 ) ;
             END IF;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'NEW INVENTORY ITEM :' || P_ATP_REC.INVENTORY_ITEM_ID ( J ) , 1 ) ;
             END IF;

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_ITEM_CHANGE');
             FND_MESSAGE.SET_TOKEN('OLDITEM',p_x_line_rec.ordered_item);
             FND_MESSAGE.SET_TOKEN('NEWITEM', p_atp_rec.inventory_item_name(J));
             OE_MSG_PUB.Add;

             -- Added below call for ER 6110708
             IF nvl(p_x_line_rec.booked_flag, 'N') = 'Y' THEN
               VALIDATE_ITEM_SUBSTITUTION
               (
                 p_new_inventory_item_id => p_atp_rec.inventory_item_id(J),
                 p_old_inventory_item_id => p_x_line_rec.inventory_item_id,
                 p_old_ship_from_org_id => l_old_ship_from_org_id,
                 p_new_ship_from_org_id => p_atp_rec.Source_Organization_Id(J),
                 p_old_shippable_flag => p_x_line_rec.shippable_flag
               );
             END IF;

             IF  p_x_line_rec.Original_Inventory_Item_Id is null
             THEN
                p_x_line_rec.Original_Inventory_Item_Id
                             := p_x_line_rec.Inventory_Item_id;
                p_x_line_rec.Original_item_identifier_Type
                             := p_x_line_rec.item_identifier_type;
                p_x_line_rec.Original_ordered_item_id
                             := p_x_line_rec.ordered_item_id;
                p_x_line_rec.Original_ordered_item
                             := p_x_line_rec.ordered_item;

             END IF;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ORIGINAL ITEM :' || P_X_LINE_REC.INVENTORY_ITEM_ID , 2 ) ;
             END IF;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'SUB ITEM :' || P_ATP_REC.INVENTORY_ITEM_ID ( J ) , 2 ) ;
             END IF;
             p_x_line_rec.inventory_item_id
                             := p_atp_rec.inventory_item_id(J);
             p_x_line_rec.item_identifier_type := 'INT';

             -- This variable is to track that the Item is being Substituted by Scheduling and not being changed manully by user.
             OE_SCHEDULE_UTIL.OESCH_ITEM_IS_SUBSTITUTED := 'Y';  -- Added for ER 6110708.
          END IF; -- inv changed.

          IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN


             IF p_atp_rec.group_ship_date(J) IS NOT NULL
             THEN
                p_x_line_rec.schedule_ship_date := p_atp_rec.group_ship_date(J);
             ELSE
                p_x_line_rec.schedule_ship_date  := p_atp_rec.ship_date(J);
             END IF;

             IF p_atp_rec.group_arrival_date(J) IS NOT NULL THEN
                p_x_line_rec.schedule_arrival_date := p_atp_rec.group_arrival_date(J);
             ELSE
                p_x_line_rec.schedule_arrival_date := p_atp_rec.arrival_date(J);

             END IF;

          ELSE
            p_x_line_rec.schedule_ship_date  := p_atp_rec.ship_date(J);

            p_x_line_rec.schedule_arrival_date  :=
                                    p_atp_rec.ship_date(J) +
                                    nvl(p_atp_rec.delivery_lead_time(J),0);

            IF p_atp_rec.group_arrival_date(J) IS NOT NULL
            THEN
              p_x_line_rec.schedule_arrival_date :=
                                      p_atp_rec.group_arrival_date(J);
              p_x_line_rec.schedule_ship_date :=
                  p_x_line_rec.schedule_arrival_date -
                  nvl(p_atp_rec.delivery_lead_time(J),0);

            END IF;

            IF p_atp_rec.group_ship_date(J) IS NOT NULL
            THEN
              p_x_line_rec.schedule_ship_date := p_atp_rec.group_ship_date(J);
              p_x_line_rec.schedule_arrival_date  :=
                                      p_x_line_rec.schedule_ship_date +
                                      nvl(p_atp_rec.delivery_lead_time(J),0);

            END IF;
          END IF;
          IF p_atp_rec.ship_method(J) IS NOT NULL THEN
             p_x_line_rec.shipping_method_code  := p_atp_rec.ship_method(J);
          END IF;

          p_x_line_rec.delivery_lead_time  := p_atp_rec.delivery_lead_time(J);
          p_x_line_rec.mfg_lead_time       := p_atp_rec.atp_lead_time(J);
          p_x_line_rec.schedule_status_code  := OESCH_STATUS_SCHEDULED;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'BEFORE ATTRIBUTE 05' , 5 ) ;
          END IF;

        -- bug fix 1965182/1925326
          IF p_atp_rec.attribute_05.COUNT > 0 THEN
             IF p_atp_rec.attribute_05(J) IS NULL THEN
                IF p_config_exists = 'N' THEN
                   p_x_line_rec.visible_demand_flag   := 'Y';
                ELSE
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'INSIDE CONFIG EXISTS' , 3 ) ;
                   END IF;
                END IF;

             ELSIF p_atp_rec.attribute_05(J) = 'N' THEN
               p_x_line_rec.visible_demand_flag   := 'N';
             ELSIF p_atp_rec.attribute_05(J) = 'Y' THEN
               p_x_line_rec.visible_demand_flag   := 'Y';
             END IF;
          ELSE
             IF p_config_exists = 'N' THEN
              p_x_line_rec.visible_demand_flag   := 'Y';
             ELSE
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'CONFIG EXISTS' , 3 ) ;
              END IF;
             END IF;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'AFTER ATTRIBUTE 05' , 5 ) ;
          END IF;

          -- We had set the ship_set and arrival_set (which are value
          -- fields) to the set name values for calling MRP purpose.
          -- Setting these back to null since sets defaulting logic
          -- gets fired if these values are populated.

          IF  p_x_line_rec.ship_set_id IS NOT NULL
          AND p_x_line_rec.ship_set_id <> FND_API.G_MISS_NUM THEN
             p_x_line_rec.ship_set     := null;
          END IF;

          IF  p_x_line_rec.arrival_set_id IS NOT NULL
          AND p_x_line_rec.arrival_set_id <> FND_API.G_MISS_NUM THEN
             p_x_line_rec.arrival_set  := null;
          END IF;

          -- Pack J
          -- Promise Date setup with Schedule date
          IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
             -- Check for LAD violation
             Validate_with_LAD
                ( p_header_id              => p_x_line_rec.header_id
                 ,p_latest_acceptable_date => p_x_line_rec.latest_acceptable_date
                 ,p_schedule_ship_date     => p_x_line_rec.schedule_ship_date
                 ,p_schedule_arrival_date  => p_x_line_rec.schedule_arrival_date);
             -- Promise Date setup
             Promise_Date_for_Sch_Action
                  (p_x_line_rec => p_x_line_rec
                  ,p_sch_action => l_sch_action
                  ,P_header_id  => p_x_line_rec.header_id);

             -- Firm Demand Flag.
             IF  nvl(p_x_line_rec.firm_demand_flag,'N') = 'N'
             AND Oe_Sys_Parameters.Value('FIRM_DEMAND_EVENTS') = 'SCHEDULE' THEN
                 p_x_line_rec.firm_demand_flag := 'Y';

             END IF;
          END IF;

          -- Adding code to trap if mrp is returning success and not
          -- returning correct data to OM.
          IF p_x_line_rec.schedule_ship_date is null
          OR p_x_line_rec.schedule_arrival_date is null THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'SCH: MRP HAS NOT RETURNING VALID SHIP DATE' , 2 ) ;
                 oe_debug_pub.add(  'SCH: Shedule ship date ' ||
                                               p_x_line_rec.schedule_ship_date , 2 ) ;
                 oe_debug_pub.add(  'SCH: Schedule Arr Date' ||
                                               p_x_line_rec.schedule_arrival_date , 2 ) ;
             END IF;
             FND_MESSAGE.SET_NAME('ONT','OE_SCH_ATP_ERROR');
             OE_MSG_PUB.Add;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

        ELSIF l_sch_action = OESCH_ACT_REDEMAND OR
              l_sch_action = OESCH_ACT_RESCHEDULE
        THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LOAD THE RESULT OF RESCHEDULE' , 3 ) ;
             oe_debug_pub.add(  '2.REQUEST SHIP DATE :' || P_ATP_REC.REQUESTED_SHIP_DATE ( J ) , 3 ) ;
             oe_debug_pub.add(  '2.REQUEST ARRIVAL DATE :' || P_ATP_REC.REQUESTED_ARRIVAL_DATE ( J ) , 3 ) ;
             oe_debug_pub.add(  '2.SHIP DATE :' || TO_CHAR ( P_ATP_REC.SHIP_DATE ( J ) , 'DD-MON-RR:HH:MI:SS' ) , 3 ) ;
             oe_debug_pub.add(  '2.ARRIVAL DATE :' || TO_CHAR ( P_ATP_REC.ARRIVAL_DATE ( J ) , 'DD-MON-RR:HH:MI:SS' ) , 3 ) ;
             oe_debug_pub.add(  '2.LEAD TIME :' || P_ATP_REC.DELIVERY_LEAD_TIME ( J ) , 3 ) ;
             oe_debug_pub.add(  '2.GROUP SHIP DATE :' || P_ATP_REC.GROUP_SHIP_DATE ( J ) , 3 ) ;
             oe_debug_pub.add(  '2.GROUP ARRIVAL DATE :' || P_ATP_REC.GROUP_ARRIVAL_DATE ( J ) , 3 ) ;
          END IF;

          l_old_ship_from_org_id := p_x_line_rec.ship_from_org_id; -- Added for ER 6110708

          p_x_line_rec.ship_from_org_id :=
                                  p_atp_rec.Source_Organization_Id(J);


          -- If the item subtitution occurs on the line then populate
          -- new inventory item from atp record and also populate
          -- Original inventory items.

          IF p_atp_rec.inventory_item_id(J)  <>  p_x_line_rec.inventory_item_id
          THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'RSCH: ITEM HAS BEEN SUBSTITUTED' , 1 ) ;
                 oe_debug_pub.add(  'RSCH NEW INVENTORY ITEM :' || P_ATP_REC.INVENTORY_ITEM_ID ( J ) , 1 ) ;
             END IF;

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_ITEM_CHANGE');
             FND_MESSAGE.SET_TOKEN('OLDITEM',p_x_line_rec.ordered_item);
             FND_MESSAGE.SET_TOKEN('NEWITEM', p_atp_rec.inventory_item_name(J));
             OE_MSG_PUB.Add;

             -- Added below call for ER 6110708
             IF nvl(p_x_line_rec.booked_flag, 'N') = 'Y' THEN
               VALIDATE_ITEM_SUBSTITUTION
               (
                 p_new_inventory_item_id => p_atp_rec.inventory_item_id(J),
                 p_old_inventory_item_id => p_x_line_rec.inventory_item_id,
                 p_old_ship_from_org_id => l_old_ship_from_org_id,
                 p_new_ship_from_org_id => p_atp_rec.Source_Organization_Id(J),
                 p_old_shippable_flag => p_x_line_rec.shippable_flag
               );
             END IF;

             IF  p_x_line_rec.Original_Inventory_Item_Id is null
             THEN
                p_x_line_rec.Original_Inventory_Item_Id
                             := p_x_line_rec.Inventory_Item_id;
                p_x_line_rec.Original_item_identifier_Type
                             := p_x_line_rec.item_identifier_type;
                p_x_line_rec.Original_ordered_item_id
                             := p_x_line_rec.ordered_item_id;
                p_x_line_rec.Original_ordered_item
                             := p_x_line_rec.ordered_item;

             END IF;
             p_x_line_rec.inventory_item_id
                             := p_atp_rec.inventory_item_id(J);
             p_x_line_rec.item_identifier_type := 'INT';

             -- This variable is to track that the Item is being Substituted by Scheduling and not being changed manully by user.
             OE_SCHEDULE_UTIL.OESCH_ITEM_IS_SUBSTITUTED := 'Y';  -- Added for ER 6110708.
          END IF; -- inv changed.


          IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN


             IF p_atp_rec.group_ship_date(J) IS NOT NULL
             THEN
                p_x_line_rec.schedule_ship_date := p_atp_rec.group_ship_date(J);
             ELSE
                p_x_line_rec.schedule_ship_date  := p_atp_rec.ship_date(J);
             END IF;

             IF p_atp_rec.group_arrival_date(J) IS NOT NULL THEN
                p_x_line_rec.schedule_arrival_date := p_atp_rec.group_arrival_date(J);
             ELSE
                p_x_line_rec.schedule_arrival_date := p_atp_rec.arrival_date(J);

             END IF;
          ELSE
             p_x_line_rec.schedule_ship_date := p_atp_rec.ship_date(J);

             p_x_line_rec.schedule_arrival_date  :=
                                  p_atp_rec.ship_date(J) +
                                  nvl(p_atp_rec.delivery_lead_time(J),0);


             IF p_atp_rec.group_arrival_date(J) IS NOT NULL
             THEN
               p_x_line_rec.schedule_arrival_date :=
                                       p_atp_rec.group_arrival_date(J);
               p_x_line_rec.schedule_ship_date :=
                   p_x_line_rec.schedule_arrival_date -
                   nvl(p_atp_rec.delivery_lead_time(J),0);

             END IF;

             IF p_atp_rec.group_ship_date(J) IS NOT NULL
             THEN
               p_x_line_rec.schedule_ship_date := p_atp_rec.group_ship_date(J);
               p_x_line_rec.schedule_arrival_date  :=
                                    p_x_line_rec.schedule_ship_date +
                                    nvl(p_atp_rec.delivery_lead_time(J),0);

             END IF;

          END IF;

          IF p_atp_rec.ship_method(J) IS NOT NULL THEN
             p_x_line_rec.shipping_method_code  := p_atp_rec.ship_method(J);
          END IF;

          p_x_line_rec.delivery_lead_time  := p_atp_rec.delivery_lead_time(J);
          p_x_line_rec.mfg_lead_time       := p_atp_rec.atp_lead_time(J);

          -- When a new option is added to scheduled SMC/SET OM will
          -- call MRP with action re-schedule. So, for the new line we need to
          -- assign the following values.

          -- Status assignment will be done after promise date setup call
          --p_x_line_rec.schedule_status_code  := OESCH_STATUS_SCHEDULED;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RSCH BEFORE ATTRIBUTE 05' , 5 ) ;
          END IF;
        -- bug fix 1965182/1925326
          IF p_atp_rec.attribute_05.COUNT > 0 THEN
             IF p_atp_rec.attribute_05(J) IS NULL THEN
                IF p_config_exists = 'N' THEN
                   p_x_line_rec.visible_demand_flag   := 'Y';
                ELSE
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'INSIDE CONFIG EXISTS' , 3 ) ;
                   END IF;
                END IF;

             ELSIF p_atp_rec.attribute_05(J) = 'N' THEN
               p_x_line_rec.visible_demand_flag   := 'N';
             ELSIF p_atp_rec.attribute_05(J) = 'Y' THEN
               p_x_line_rec.visible_demand_flag   := 'Y';
             END IF;
          ELSE
             IF p_config_exists = 'N' THEN
              p_x_line_rec.visible_demand_flag   := 'Y';
             ELSE
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'CONFIG EXISTS' , 3 ) ;
              END IF;
             END IF;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RSCH AFTER ATTRIBUTE 05' , 5 ) ;
          END IF;

          IF (p_x_line_rec.ordered_quantity = 0)
          THEN
            -- Bug 2101332. On a cancelled line, keeping
            -- warehouse is not a harm.
            -- p_x_line_rec.ship_from_org_id   := null;
            p_x_line_rec.schedule_ship_date    := null;
            p_x_line_rec.schedule_arrival_date := null;
            p_x_line_rec.schedule_status_code  := null;
            p_x_line_rec.visible_demand_flag   := 'N';
            p_x_line_rec.override_atp_date_code := null;
          END IF;

          -- We had set the ship_set and arrival_set (which are value
          -- fields) to the set name values for calling MRP purpose.
          -- Setting these back to null since sets defaulting logic
          -- gets fired if these values are populated.

          IF  p_x_line_rec.ship_set_id IS NOT NULL
          AND p_x_line_rec.ship_set_id <> FND_API.G_MISS_NUM THEN
              p_x_line_rec.ship_set     := null;
          END IF;

          IF  p_x_line_rec.arrival_set_id IS NOT NULL
          AND p_x_line_rec.arrival_set_id <> FND_API.G_MISS_NUM THEN
              p_x_line_rec.arrival_set  := null;
          END IF;

          IF p_x_line_rec.top_model_line_id = p_x_line_rec.line_id THEN

                           IF l_debug_level  > 0 THEN
                               oe_debug_pub.add(  'STORE ARRIVAL_DATE ' || P_X_LINE_REC.SCHEDULE_ARRIVAL_DATE , 2 ) ;
                           END IF;
             l_arrival_date := p_x_line_rec.schedule_arrival_date;

          END IF;
          -- Pack J
          -- Promise Date setup with Schedule date
          IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
             -- Check for LAD violation
             Validate_with_LAD
                ( p_header_id              => p_x_line_rec.header_id
                 ,p_latest_acceptable_date => p_x_line_rec.latest_acceptable_date
                 ,p_schedule_ship_date     => p_x_line_rec.schedule_ship_date
                 ,p_schedule_arrival_date  => p_x_line_rec.schedule_arrival_date);
             -- Promise date setup
             Promise_Date_for_Sch_Action
                  (p_x_line_rec => p_x_line_rec
                  ,p_sch_action => l_sch_action
                  ,P_header_id  => p_x_line_rec.header_id);

             -- Firm Demand Flag.
             IF  nvl(p_x_line_rec.firm_demand_flag,'N') = 'N'
             AND Oe_Sys_Parameters.Value('FIRM_DEMAND_EVENTS') = 'SCHEDULE' THEN
                 p_x_line_rec.firm_demand_flag := 'Y';

             END IF;
          END IF;
          IF p_x_line_rec.ordered_quantity > 0 THEN
             p_x_line_rec.schedule_status_code  := OESCH_STATUS_SCHEDULED;
          END IF;

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'RSCH: PROMISE DATE '||p_x_line_rec.promise_date , 2 ) ;
          END IF;


          -- Adding code to trap if mrp is returning success and not
          -- returning correct data to OM.
          IF (p_x_line_rec.schedule_ship_date is null
          OR  p_x_line_rec.schedule_arrival_date is null)
          AND p_x_line_rec.ordered_quantity > 0 THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'RSCH: MRP HAS NOT RETURNING VALID DATE' , 2 ) ;
             END IF;
             FND_MESSAGE.SET_NAME('ONT','OE_SCH_ATP_ERROR');
             OE_MSG_PUB.Add;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

        ELSIF l_sch_action = OESCH_ACT_UNDEMAND
        THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'RR2:Load the results of undemand: '
                                            || P_X_LINE_REC.RE_SOURCE_FLAG , 1 ) ;
          END IF;
          --  Commented for bug 7692055
          -- We will not clear ship_from_org
          /*
          --bug 2921202
          if p_x_line_rec.ordered_quantity > 0 then
           IF p_x_line_rec.re_source_flag='Y' or
             p_x_line_rec.re_source_flag is null THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'SETTING SHIP FROM TO NULL' , 1 ) ;
               END IF;
               p_x_line_rec.ship_from_org_id      := null;
           END IF;
          end if;
          */
          p_x_line_rec.schedule_ship_date    := null;
          p_x_line_rec.schedule_arrival_date := null;
          p_x_line_rec.schedule_status_code  := null;
          p_x_line_rec.visible_demand_flag   := null;

          -- We had set the ship_set and arrival_set (which are value
          -- fields) to the set name values for calling MRP purpose.
          -- Setting these back to null since sets defaulting logic
          -- gets fired if these values are populated.

          IF  p_x_line_rec.ship_set_id IS NOT NULL
          AND p_x_line_rec.ship_set_id <> FND_API.G_MISS_NUM THEN
              p_x_line_rec.ship_set     := null;
          END IF;

          IF  p_x_line_rec.arrival_set_id IS NOT NULL
          AND p_x_line_rec.arrival_set_id <> FND_API.G_MISS_NUM THEN
              p_x_line_rec.arrival_set  := null;
          END IF;

          -- BUG 1282873
          IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN

            -- Unscheduling a line will also clear the Override Atp flag
             p_x_line_rec.override_atp_date_code := Null;
          END IF;
          -- END 1282873
          -- 3345776
          IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
             -- Promise date setup
             Promise_Date_for_Sch_Action
                  (p_x_line_rec => p_x_line_rec
                  ,p_sch_action => l_sch_action
                  ,P_header_id  => p_x_line_rec.header_id);
          END IF;

        END IF;

/*** Moved the below code for bug #8205242 from procedure Load_Results_From_Tbl
     to procedure Load_Results_from_Rec ***/

/* 7576948: IR ISO Change Management Begins */

-- This code is hooked for IR ISO project, where if the schedule ship
-- date is changed as a result of MRP call then a delayed request is
-- logged to call the PO_RCO_Validation_GRP.Update_ReqChange_from_SO
-- API from Purchasing, responsible for conditionally updating the Need By
-- Date column in internal requisition line. This will be done based on
-- PO profile 'POR: Sync up Need by date on IR with OM' set to YES

-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc

    IF l_debug_level > 0 THEN
      oe_debug_pub.add(' Source Type for the order line is : '||p_x_line_rec.order_source_id,5);
      oe_debug_pub.add(' Line_id : '||p_x_line_rec.line_id,5);
      oe_debug_pub.add(' Header_id : '||p_x_line_rec.header_id,5);
      oe_debug_pub.add(' Source Document id : '||p_x_line_rec.source_document_id,5);
      oe_debug_pub.add(' Src Doc Line_id : '||p_x_line_rec.source_document_line_id,5);
      oe_debug_pub.add(' Schedule Arrival Date : '||p_x_line_rec.schedule_arrival_date,5);
    END IF;

    IF p_x_line_rec.order_source_id = 10 THEN
       IF NOT OE_Internal_Requisition_Pvt.G_Update_ISO_From_Req
         AND NOT OE_SALES_CAN_UTIL.G_IR_ISO_HDR_CANCEL THEN
         IF FND_PROFILE.VALUE('POR_SYNC_NEEDBYDATE_OM') = 'YES' THEN
         -- Modified for IR ISO Tracking bug 7667702

         IF l_debug_level > 0 THEN
           oe_debug_pub.add(' Logging G_UPDATE_REQUISITION delayed request for date change',5);
         END IF;

         -- Log a delayed request to update the change in Schedule Ship Date to
         -- Requisition Line. This request will be logged only if the change is
         -- not initiated from Requesting Organization, and it is not a case of
         -- Internal Sales Order Full Cancellation. It will even not be logged
         -- Purchasing profile option does not allow update of Need By Date when
         -- Schedule Ship Date changes on internal sales order line

         OE_delayed_requests_Pvt.log_request
         ( p_entity_code            => OE_GLOBALS.G_ENTITY_LINE
         , p_entity_id              => p_x_line_rec.line_id
         , p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE
         , p_requesting_entity_id   => p_x_line_rec.line_id
         , p_request_unique_key1    => p_x_line_rec.header_id  -- Order Hdr_id
         , p_request_unique_key2    => p_x_line_rec.source_document_id -- Req Hdr_id
         , p_request_unique_key3    => p_x_line_rec.source_document_line_id -- Req Line_id
         , p_date_param1            => p_x_line_rec.schedule_arrival_date -- schedule_ship_date
-- Note: p_date_param1 is used for both Schedule_Ship_Date and
-- Schedule_Arrival_Date, as while executing G_UPDATE_REQUISITION delayed
-- request via OE_Process_Requisition_Pvt.Update_Internal_Requisition,
-- it can expect change with respect to Ship or Arrival date. Thus, will
-- not raise any issues.
         , p_request_type           => OE_GLOBALS.G_UPDATE_REQUISITION
         , x_return_status          => l_return_status
         );

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         ELSE -- Added for IR ISO Tracking bug 7667702
           IF NOT OE_Schedule_GRP.G_ISO_Planning_Update THEN
             IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Need By Date is not allowed to update. Updating MTL_Supply only',5);
             END IF;

             OE_SCHEDULE_UTIL.Update_PO(p_x_line_rec.schedule_arrival_date,
                p_x_line_rec.source_document_id,
                p_x_line_rec.source_document_line_id);
           END IF;
         END IF;

       END IF;
     END IF; -- Order_Source_id

/* ============================= */
/* IR ISO Change Management Ends */


      END IF; -- Return Status.
     END IF; -- Main If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'VALUE OF THE INDEX ' || J , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING LOAD_RESULTS_FROM_REC' || X_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Load_Results_from_rec'
            );
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR IN LOAD_RESULTS_FROM_REC' , 1 ) ;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Load_Results_from_rec;


/*--------------------------------------------------------------------------
Procedure Name : Load_Results_from_Tbl
Description    : This API loads the results from MRP's ATP_REC_TYPE to
                 OM's order line. It also populates OM's ATP Table which
                 is used to display the ATP results on the client side.
                 We ignore the mandatory components which we passed to MRP
                 while loading the results.

                 Added parameter p_old_line_tbl to support bug 1955004
                 for call to Inactive_Demand_Scheduling()
-------------------------------------------------------------------------- */
Procedure Load_Results_from_tbl
( p_atp_rec         IN MRP_ATP_PUB.ATP_Rec_Typ
, p_old_line_tbl    IN OE_ORDER_PUB.line_tbl_type
, p_x_line_tbl      IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type
, p_sch_action      IN VARCHAR2 := NULL
, p_partial         IN BOOLEAN := FALSE
, p_partial_set     IN BOOLEAN := FALSE
, x_return_status OUT NOCOPY VARCHAR2)

IS
J                 NUMBER := 1;
K                 NUMBER := 1;
l_sch_action      VARCHAR2(30) := p_sch_action;
l_old_ato_line_id NUMBER := -99;
l_old_set_id      VARCHAR2(30) := -99;
l_new_set_id      VARCHAR2(30) := -99;
l_config_exists   VARCHAR2(1) := 'N';
l_line_id_mod     NUMBER ;    --7827737;


l_return_status   VARCHAR2(1);  -- Added for IR ISO CMS Project
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_raise_error     BOOLEAN := FALSE;
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING LOAD_RESULTS_FROM_TBL' , 1 ) ;
  END IF;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  IF l_sch_action is NULL THEN
     l_sch_action := p_x_line_tbl(1).schedule_action_code;
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('-----------------Loading MRP Result From Tbl---------------',1);
      oe_debug_pub.add(  'Loading mrp results' , 1 ) ;
      oe_debug_pub.add(  'Mrp count is ' || P_ATP_REC.ERROR_CODE.COUNT , 1 ) ;
      oe_debug_pub.add(  'Line count is ' || P_X_LINE_TBL.COUNT , 1 ) ;
      oe_debug_pub.add(  'Scheduling action ' || L_SCH_ACTION , 1 ) ;
  END IF;

  g_atp_tbl.delete;

  FOR I in 1..p_x_line_tbl.count LOOP
   l_line_id_mod := MOD(p_x_line_tbl(I).line_id,G_BINARY_LIMIT); --7827737
   l_config_exists := 'N'; --Bug 13777961: Re-initialize the variable

    -- BUG 1955004
    --IF OE_inactive_demand_tbl.EXISTS(p_x_line_tbl(I).line_id) THEN
    IF OE_inactive_demand_tbl.EXISTS(l_line_id_mod) THEN  --7827737

       -- we know this is line has an inactive demand scheduling level

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING INACTIVE_DEMAND_SCHEDULING FROM LOAD_RESULTS_FROM_TBL' , 1 ) ;
        END IF;
        Inactive_demand_scheduling(p_x_old_line_rec => p_old_line_tbl(I)
                                  ,p_x_line_rec => p_x_line_tbl(I)
                                  ,p_sch_action =>  L_SCH_ACTION  --14097050
                                  ,x_return_status => x_return_status);

        --OE_inactive_demand_tbl.DELETE(p_x_line_tbl(I).line_id);
        OE_inactive_demand_tbl.DELETE(l_line_id_mod);  --7827737
        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    ELSE
     -- END 1955004

     IF p_x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_CONFIG THEN

        -- The config item might be a part of the table since query
        -- of  group of lines returns back the config item too. But
        -- we did not pass this item to MRP (in load_mrp_request). Thus
        -- we will bypass this record out here too.

        -- Since we don't pass config line to MRP we need populate schedule date
        -- on config from Model line. This is to fix bug1576412.

        -- We need populate the model record scheduling values
        -- on the config line.

        K := 1;
        WHILE K <= p_atp_rec.error_code.count LOOP


         -- code has been changed to fix bug 2314594.
         IF p_x_line_tbl(I).ato_line_id = p_atp_rec.Identifier(K) THEN
            EXIT;
         END IF;
         K := K +1;

        END LOOP;

        IF l_sch_action =  OESCH_ACT_RESCHEDULE
          AND NVL(p_x_line_tbl(I).ordered_quantity,0) > 0 THEN -- 3907522

        -- Modified this part to fix bug 1900085.
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'UPDATING CONFIG LINE ' || P_X_LINE_TBL ( I ) .LINE_ID , 1 ) ;
           END IF;

           IF p_atp_rec.group_ship_date(k) IS NOT NULL
           THEN
              p_x_line_tbl(I).schedule_ship_date := p_atp_rec.group_ship_date(k);
           ELSE
              p_x_line_tbl(I).schedule_ship_date  := p_atp_rec.ship_date(k);
           END IF;

           IF p_atp_rec.group_arrival_date(k) IS NOT NULL THEN
              p_x_line_tbl(I).schedule_arrival_date := p_atp_rec.group_arrival_date(k);
           ELSE
              p_x_line_tbl(I).schedule_arrival_date := p_atp_rec.arrival_date(k);

           END IF;

           p_x_line_tbl(I).delivery_lead_time := p_atp_rec.delivery_lead_time(k);

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'Config schedule ' || P_X_LINE_TBL(I).SCHEDULE_SHIP_DATE , 2 ) ;
             oe_debug_pub.add(  'Config arrival ' || P_X_LINE_TBL(I).SCHEDULE_ARRIVAL_DATE , 2 ) ;
          END IF;
        END IF;

        --4052648
        IF l_sch_action =  OESCH_ACT_UNSCHEDULE THEN
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'CLEARING SCHEDULE INFORMATION FOR CONFIG LINE ' , 2 ) ;
           END IF;
           p_x_line_tbl(I).schedule_ship_date    := null;
           p_x_line_tbl(I).schedule_arrival_date := null;
           p_x_line_tbl(I).schedule_status_code  := null;
           p_x_line_tbl(I).visible_demand_flag   := null;

           IF  p_x_line_tbl(I).ship_set_id IS NOT NULL
           AND p_x_line_tbl(I).ship_set_id <> FND_API.G_MISS_NUM THEN
              p_x_line_tbl(I).ship_set     := null;
           END IF;

           IF  p_x_line_tbl(I).arrival_set_id IS NOT NULL
           AND p_x_line_tbl(I).arrival_set_id <> FND_API.G_MISS_NUM THEN
              p_x_line_tbl(I).arrival_set  := null;
           END IF;

           -- Unscheduling a line will also clear the Override Atp flag
           p_x_line_tbl(I).override_atp_date_code := Null;
        END IF;

     ELSE

      IF p_x_line_tbl(I).ato_line_id is not null
      AND p_x_line_tbl(I).ato_line_id <> l_old_ato_line_id
      THEN

        l_old_ato_line_id := p_x_line_tbl(I).ato_line_id;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'Check for config on line ' || P_X_LINE_TBL ( I ) .ATO_LINE_ID , 1 ) ;
        END IF;
        BEGIN

          Select 'Y'
          Into   l_config_exists
          From   oe_order_lines_all
          Where  header_id = p_x_line_tbl(I).header_id
          And    ato_line_id = p_x_line_tbl(I).ato_line_id
          And    item_type_code = OE_GLOBALS.G_ITEM_CONFIG;

        EXCEPTION
              WHEN OTHERS THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'NO CONFIG EXISTS FOR ATO ' , 1 ) ;
               END IF;
               l_config_exists := 'N';
        END;

      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Load results line_id ' || P_X_LINE_TBL ( I ) .LINE_ID , 1 ) ;
          oe_debug_pub.add(  'Index ' || J , 1 ) ;
      END IF;


      IF  l_sch_action = OESCH_ACT_ATP_CHECK
      AND OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
      AND MSC_ATP_GLOBAL.GET_APS_VERSION = 10
      AND p_x_line_tbl(I).ato_line_id is not null
      AND p_x_line_tbl(I).ato_line_id <> p_x_line_tbl(I).line_id  THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'Do not call load_results for options/calsss');
        END IF;

      ELSE

        Load_Results_from_rec(p_atp_rec       => p_atp_rec,
                              p_x_line_rec    => p_x_line_tbl(I),
                              p_sch_action    => l_sch_action,
                              p_index         => J,
                              p_config_exists => l_config_exists,
                              p_partial_set   => p_partial_set,
                              x_return_status => x_return_status);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'After call to load_results_from_rec' || J  || x_return_status, 1 ) ;
        END IF;

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'UNEXP ERROR LINE ' || P_X_LINE_TBL ( I ) .LINE_ID , 1 ) ;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        -- This code is required, if user performing scheduling action
        -- from header or using multi selected lines, system has to
        -- commit those lines which went through scheduling fine.
        -- Ignore other records.

           l_new_set_id := NVL(p_atp_rec.ship_set_name(J),
                              NVL(p_atp_rec.arrival_set_name(J),-99));

           IF l_old_set_id <> l_new_set_id
--           AND p_atp_rec.error_code(J) = 19
           AND NOT p_partial_set  THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'Before setting message for: ' || P_ATP_REC.ERROR_CODE(J) , 2 ) ;
            END IF;

             l_old_set_id := l_new_set_id;
             FND_MESSAGE.SET_NAME('ONT','OE_SCH_GROUP_MEMBER_FAILED');
             OE_MSG_PUB.Add;


           END IF;
           IF p_partial THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'SET OPERATION TO NONE' , 1 ) ;
              END IF;
              p_x_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
              x_return_status := FND_API.G_RET_STS_SUCCESS;
           ELSE
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'EXP ERROR LINE ' || P_X_LINE_TBL ( I ) .LINE_ID , 1 ) ;
              END IF;
              l_raise_error := TRUE;
              --RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
      END IF; -- GOP Code
     END IF;


     -- As part of the bug fix 2910899, OM will indicate and remember the
     -- Standard Madatory record positions using vendor_name. This will be
     -- used in the load_results procedure to bypass the SMC records.
     -- Increment and skip the smc records.

     IF I < p_x_line_tbl.count AND
        p_x_line_tbl(I).item_type_code <> 'CONFIG' AND
        J < p_atp_rec.Identifier.count  THEN
         J := J + 1;
         IF (nvl(p_atp_rec.vendor_name(J),'N') = 'SMC')
         THEN

            WHILE (nvl(p_atp_rec.vendor_name(J),'N') = 'SMC')
            LOOP
              IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SMC  : '|| J  , 3 ) ;
              END IF;
               J := J + 1;
         IF p_atp_rec.identifier.count < J THEN
         GOTO END_ATP_WHILE;
         END IF;
            END LOOP;

      << END_ATP_WHILE >>
      NULL;

         END IF;
     END IF;
     -- End of increment and skip.

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OPERATION : ' || P_X_LINE_TBL ( I ) .OPERATION , 1 ) ;
  END IF;

    END IF; -- for new IF statement for BUG 1955004

/* 7576948: IR ISO Change Management Begins */

/* Commented for bug #8205242

-- This code is hooked for IR ISO project, where if the schedule ship
-- date is changed as a result of MRP call then a delayed request is
-- logged to call the PO_RCO_Validation_GRP.Update_ReqChange_from_SO
-- API from Purchasing, responsible for conditionally updating the Need By
-- Date column in internal requisition line. This will be done based on
-- PO profile 'POR: Sync up Need by date on IR with OM' set to YES

-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc


    IF (p_x_line_tbl(i).order_source_id = 10) AND
       (
        ((p_old_line_tbl(i).schedule_ship_date IS NOT NULL) AND
          NOT OE_GLOBALS.Equal(p_x_line_tbl(i).schedule_ship_date,p_old_line_tbl(i).schedule_ship_date))
       OR
        ((p_old_line_tbl(i).schedule_arrival_date IS NOT NULL) AND
          NOT OE_GLOBALS.Equal(p_x_line_tbl(i).schedule_arrival_date,p_old_line_tbl(i).schedule_arrival_date))
       )  THEN

       IF NOT OE_Internal_Requisition_Pvt.G_Update_ISO_From_Req
         AND NOT OE_SALES_CAN_UTIL.G_IR_ISO_HDR_CANCEL THEN
         -- AND FND_PROFILE.VALUE('POR_SYNC_NEEDBYDATE_OM') = 'YES' THEN
         IF FND_PROFILE.VALUE('POR_SYNC_NEEDBYDATE_OM') = 'YES' THEN
         -- Modified for IR ISO Tracking bug 7667702

         IF l_debug_level > 0 THEN
           oe_debug_pub.add(' Logging G_UPDATE_REQUISITION delayed request for date change');
         END IF;

         -- Log a delayed request to update the change in Schedule Ship Date to
         -- Requisition Line. This request will be logged only if the change is
         -- not initiated from Requesting Organization, and it is not a case of
         -- Internal Sales Order Full Cancellation. It will even not be logged
         -- Purchasing profile option does not allow update of Need By Date when
         -- Schedule Ship Date changes on internal sales order line

         OE_delayed_requests_Pvt.log_request
         ( p_entity_code            => OE_GLOBALS.G_ENTITY_LINE
         , p_entity_id              => p_x_line_tbl(i).line_id
         , p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE
         , p_requesting_entity_id   => p_x_line_tbl(i).line_id
         , p_request_unique_key1    => p_x_line_tbl(i).header_id  -- Order Hdr_id
         , p_request_unique_key2    => p_x_line_tbl(i).source_document_id -- Req Hdr_id
         , p_request_unique_key3    => p_x_line_tbl(i).source_document_line_id -- Req Line_id
         , p_date_param1            => p_x_line_tbl(i).schedule_arrival_date -- schedule_ship_date
-- Note: p_date_param1 is used for both Schedule_Ship_Date and
-- Schedule_Arrival_Date, as while executing G_UPDATE_REQUISITION delayed
-- request via OE_Process_Requisition_Pvt.Update_Internal_Requisition,
-- it can expect change with respect to Ship or Arrival date. Thus, will
-- not raise any issues.
         , p_request_type           => OE_GLOBALS.G_UPDATE_REQUISITION
         , x_return_status          => l_return_status
         );

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         ELSE -- Added for IR ISO Tracking bug 7667702
           IF NOT OE_Schedule_GRP.G_ISO_Planning_Update THEN
             IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Need By Date is not allowed to update. Updating MTL_Supply only',5);
             END IF;

             OE_SCHEDULE_UTIL.Update_PO(p_x_line_tbl(i).schedule_arrival_date,
                p_x_line_tbl(i).source_document_id,
                p_x_line_tbl(i).source_document_line_id);
           END IF;
         END IF;

       END IF;
     END IF; -- Order_Source_id

*/

/* ============================= */
/* IR ISO Change Management Ends */


  END LOOP;
  IF l_raise_error THEN

     RAISE FND_API.G_EXC_ERROR;

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING LOAD_RESULTS_FROM_TBL' , 1 ) ;
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Load_Results_from_tbl'
            );
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR IN LOAD_RESULTS_FROM_TBL' , 1 ) ;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Load_Results_from_tbl;

Procedure Display_Sch_Errors
( p_atp_rec         IN  MRP_ATP_PUB.ATP_Rec_Typ
, p_line_tbl        IN  OE_ORDER_PUB.line_tbl_type
                        := OE_ORDER_PUB.G_MISS_LINE_TBL
, p_line_id         IN  NUMBER DEFAULT NULL)

IS

J                 NUMBER := 1;
l_old_set_id      Varchar2(30) := -99;
l_new_set_id      Varchar2(30) := -99;
l_explanation     VARCHAR2(240);
l_order_source_id          NUMBER;
l_orig_sys_document_ref    VARCHAR2(50);
l_orig_sys_line_ref        VARCHAR2(50);
l_orig_sys_shipment_ref    VARCHAR2(50);
l_change_sequence          VARCHAR2(50);
l_source_document_id       NUMBER;
l_source_document_line_id  NUMBER;
l_source_document_type_id  NUMBER;
l_header_id                NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING DISPLAY_SCH_ERRORS' , 1 ) ;
    END IF;

IF p_atp_rec.error_code.count > 0 THEN

 IF p_line_id is not null THEN


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SCHEDULING FAILED WITH ERROR CODE: ' || P_LINE_ID ) ;
    END IF;

    IF p_line_id <> FND_API.G_MISS_NUM THEN
       select order_source_id, orig_sys_document_ref, orig_sys_line_ref,
              orig_sys_shipment_ref, change_sequence, source_document_id,
              source_document_line_id, source_document_type_id, header_id
       into l_order_source_id, l_orig_sys_document_ref, l_orig_sys_line_ref,
            l_orig_sys_shipment_ref, l_change_sequence, l_source_document_id,
            l_source_document_line_id, l_source_document_type_id, l_header_id
       from oe_order_lines
       where line_id = p_line_id;
     END IF;

     OE_MSG_PUB.set_msg_context(
       p_entity_code                => 'LINE'
      ,p_entity_id                  => p_line_id
      ,p_header_id                  => l_header_id
      ,p_line_id                    => p_line_id
      ,p_orig_sys_document_ref      => l_orig_sys_document_ref
      ,p_orig_sys_document_line_ref => l_orig_sys_line_ref
      ,p_orig_sys_shipment_ref      => l_orig_sys_shipment_ref
      ,p_change_sequence            => l_change_sequence
      ,p_source_document_id         => l_source_document_id
      ,p_source_document_line_id    => l_source_document_line_id
      ,p_order_source_id            => l_order_source_id
      ,p_source_document_type_id    => l_source_document_type_id);

     IF p_atp_rec.error_code(J) = 80 THEN

        FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_SOURCE');
        OE_MSG_PUB.Add;
        l_explanation := null;

     ELSIF p_atp_rec.error_code(J) <> 0 THEN

        select meaning
        into l_explanation
        from mfg_lookups where
        lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
        and lookup_code = p_atp_rec.error_code(J) ;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ADDING MESSAGE TO THE STACK' , 1 ) ;
        END IF;
        FND_MESSAGE.SET_NAME('ONT','OE_SCH_OE_ORDER_FAILED');
        FND_MESSAGE.SET_TOKEN('EXPLANATION',l_explanation);
        OE_MSG_PUB.Add;

      ELSE

        FND_MESSAGE.SET_NAME('ONT','OE_SCH_ATP_ERROR');
        OE_MSG_PUB.Add;
      END IF;


 ELSE

  FOR I in 1..p_line_tbl.count LOOP

   IF p_line_tbl(I).Item_type_code <> 'CONFIG' THEN

     l_new_set_id := NVL(p_atp_rec.ship_set_name(J),
                     NVL(p_atp_rec.arrival_set_name(J),-99));

     IF l_old_set_id <> l_new_set_id
     AND p_atp_rec.error_code(J) = 19 THEN

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Before setting message for: ' || P_ATP_REC.ERROR_CODE ( J ) , 2 ) ;
      END IF;

      l_old_set_id := l_new_set_id;
      FND_MESSAGE.SET_NAME('ONT','OE_SCH_GROUP_MEMBER_FAILED');
      OE_MSG_PUB.Add;

     ELSIF p_atp_rec.error_code(J) <> 0
     AND   p_atp_rec.error_code(J) <> 19 THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SCHEDULING FAILED WITH ERROR CODE:'||P_ATP_REC.ERROR_CODE ( J ) , 1 ) ;
      END IF;


          OE_MSG_PUB.set_msg_context(
           p_entity_code                => 'LINE'
          ,p_entity_id                  => p_line_tbl(I).line_id
          ,p_header_id                  => p_line_tbl(I).header_id
          ,p_line_id                    => p_line_tbl(I).line_id
          ,p_order_source_id            => p_line_tbl(I).order_source_id
          ,p_orig_sys_document_ref      => p_line_tbl(I).orig_sys_document_ref
          ,p_orig_sys_document_line_ref => p_line_tbl(I).orig_sys_line_ref
          ,p_orig_sys_shipment_ref      => p_line_tbl(I).orig_sys_shipment_ref
          ,p_change_sequence            => p_line_tbl(I).change_sequence
          ,p_source_document_type_id    => p_line_tbl(I).source_document_type_id
          ,p_source_document_id         => p_line_tbl(I).source_document_id
          ,p_source_document_line_id    => p_line_tbl(I).source_document_line_id);

          IF p_atp_rec.error_code(J) = 80 THEN

            FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_SOURCE');
            OE_MSG_PUB.Add;
            l_explanation := null;

          ELSE
            select meaning
            into l_explanation
            from mfg_lookups where
            lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
            and lookup_code = p_atp_rec.error_code(J) ;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ADDING MESSAGE TO THE STACK' , 1 ) ;
            END IF;
            FND_MESSAGE.SET_NAME('ONT','OE_SCH_OE_ORDER_FAILED');
            FND_MESSAGE.SET_TOKEN('EXPLANATION',l_explanation);
            OE_MSG_PUB.Add;


          END IF;
      END IF;

   -- Increment and skip the smc records.
      IF I < p_line_tbl.count AND
         p_line_tbl(I).item_type_code <> 'CONFIG' AND
         J < p_atp_rec.Identifier.count  THEN

          J := J + 1;
          IF (p_line_tbl(I).line_id = p_atp_rec.Identifier(J))
          THEN

            WHILE (p_atp_rec.Identifier(J) = p_line_tbl(I).line_id)
            LOOP
                J := J + 1;
              IF p_atp_rec.identifier.count < J THEN
                GOTO END_ATP_WHILE;
              END IF;
            END LOOP;

          << END_ATP_WHILE >>
          NULL;

         END IF;
      END IF;
    END IF;
  END LOOP;
 END IF; -- p_line

END IF;

End Display_Sch_Errors;

/*---------------------------------------------------------------------
Procedure Name : Call_MRP_ATP
Description    : Create and call MRP API.
--------------------------------------------------------------------- */

Procedure Call_MRP_ATP
( p_x_line_rec       IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type
 ,p_old_line_rec     IN OE_ORDER_PUB.Line_Rec_Type
,x_return_status OUT NOCOPY VARCHAR2)

IS
l_msg_count               NUMBER;
l_session_id              NUMBER := 0;
l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
l_out_mrp_atp_rec         MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
l_mrp_msg_data            VARCHAR2(200);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING CALL MRP ATP' , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
   END IF;

-- BUG 1955004
 -- 3763015
 IF (sch_cached_sch_level_code = SCH_LEVEL_FOUR OR
    sch_cached_sch_level_code = SCH_LEVEL_FIVE OR
    NVL(fnd_profile.value('ONT_BYPASS_ATP'),'N') = 'Y')  OR
    Nvl(p_x_line_rec.bypass_sch_flag, 'N') = 'Y'  THEN -- DOO Integration
    -- this is an inactive demand line.

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'THIS IS A SINGLE INACTIVE DEMAND LINE' , 1 ) ;
   END IF;

   Inactive_Demand_Scheduling(p_x_old_line_rec => p_old_line_rec
                            ,p_x_line_rec     => p_x_line_rec
                            ,x_return_status  => x_return_status);

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF  x_return_status = FND_API.G_RET_STS_ERROR THEN
          Display_sch_errors(p_atp_rec => l_mrp_atp_rec,
                             p_line_id => p_x_line_rec.line_id);
          RAISE FND_API.G_EXC_ERROR;
   END IF;

 ELSE

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ELSE CALL FOR CALL MRP ATP' , 1 ) ;
   END IF;
-- END 1955004

   Load_MRP_request_from_rec
       ( p_line_rec              => p_x_line_rec
       , p_old_line_rec          => p_old_line_rec
       , x_mrp_atp_rec             => l_mrp_atp_rec);


   IF l_mrp_atp_rec.error_code.count > 0 THEN
      l_session_id := Get_Session_Id;

      -- Call ATP

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  '1. CALLING MRP API WITH SESSION ID '||L_SESSION_ID , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
       END IF;
      /* 8731703: Code moved to Load_Results_From_rec
      -- Added the following 10  lines to fix the bug 6378240
       oe_debug_pub.add(  '6378240 : inserted the line_id into temp table '||p_x_line_rec.line_id ||'  ' ||p_x_line_rec.schedule_action_code);
     BEGIN
       insert into oe_schedule_lines_temp
                   (LINE_ID ,
                    SCHEDULE_ACTION_CODE)
              values(p_x_line_rec.line_id,p_x_line_rec.schedule_action_code);
     EXCEPTION
         WHEN OTHERS THEN
                  oe_debug_pub.add(  '6378240 : INSERT ERROR ');
     END;
     */


       MRP_ATP_PUB.Call_ATP
              (  p_session_id             =>  l_session_id
               , p_atp_rec                =>  l_mrp_atp_rec
               , x_atp_rec                =>  l_out_mrp_atp_rec
               , x_atp_supply_demand      =>  l_atp_supply_demand
               , x_atp_period             =>  l_atp_period
               , x_atp_details            =>  l_atp_details
               , x_return_status          =>  x_return_status
               , x_msg_data               =>  l_mrp_msg_data
               , x_msg_count              =>  l_msg_count);

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  '3. AFTER CALLING MRP_ATP_PUB.CALL_ATP' || X_RETURN_STATUS , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
      END IF;

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF  x_return_status = FND_API.G_RET_STS_ERROR THEN
          IF p_x_line_rec.schedule_action_code <> OESCH_ACT_ATP_CHECK THEN
             Display_sch_errors(p_atp_rec => l_out_mrp_atp_rec,
                                p_line_id => p_x_line_rec.line_id);
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

       Load_Results_from_rec(p_atp_rec       => l_out_mrp_atp_rec,
                             p_x_line_rec    => p_x_line_rec,
                             x_return_status => x_return_status);

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

   END IF; -- Mrp count.
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING CALL ATP' , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
   END IF;

  END IF;  -- for new IF statement added for 1955004

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Call_MRP_ATP');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Call_MRP_ATP;
PROCEDURE Cascade_Override_atp
 (p_line_rec IN     OE_ORDER_PUB.line_rec_type)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING CASCADE_OVERRIDE_ATP ' , 1 ) ;
   END IF;

    IF   p_line_rec.ato_line_id IS NOT NULL AND
    NOT (p_line_rec.ato_line_id = p_line_rec.line_id AND
         p_line_rec.item_type_code = 'OPTION') THEN

       UPDATE OE_ORDER_LINES_ALL
       SET    override_atp_date_code = Null
       WHERE  header_id = p_line_rec.header_id
       AND    ato_line_id = p_line_rec.ato_line_id;

    ELSIF  p_line_rec.item_type_code = 'CLASS'
       OR  p_line_rec.item_type_code = 'MODEL'
       OR  p_line_rec.item_type_code = 'KIT'
    THEN

       UPDATE OE_ORDER_LINES_ALL
       SET    override_atp_date_code = Null
       WHERE  header_id = p_line_rec.header_id
       AND    link_to_line_id  = p_line_rec.line_id
       AND    item_type_code = 'INCLUDED';

    END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING CASCADE_OVERRIDE_ATP ' , 1 ) ;
   END IF;
EXCEPTION

   WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Cascade Override Atp');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Cascade_Override_atp;
/*---------------------------------------------------------------------
Procedure Name : Query_Qty_Tree
Description    : Queries the On-Hand and Available to Reserve
                 quantites by calling INV's
                 inv_quantity_tree_pub.query_quantities.
                 The quantities are given at the highest level (Item, Org
                 combination).
--------------------------------------------------------------------- */
Procedure Query_Qty_Tree(p_org_id            IN NUMBER,
                         p_item_id           IN NUMBER,
                         p_line_id           IN NUMBER DEFAULT NULL,
                         p_sch_date          IN DATE DEFAULT NULL,
--                         p_grade_code        IN VARCHAR2 DEFAULT NULL, -- INVCONV NOT NEEDED NOW
                         x_on_hand_qty OUT NOCOPY NUMBER,
                         x_avail_to_reserve OUT NOCOPY NUMBER,
                         x_on_hand_qty2 OUT NOCOPY NUMBER, -- INVCONV
                         x_avail_to_reserve2 OUT NOCOPY NUMBER ,-- INVCONV
                         p_subinventory_code  IN VARCHAR2 DEFAULT NULL --11777419
                         )

IS
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_qoh                     NUMBER;
  l_rqoh                    NUMBER;
  l_qr                      NUMBER;
  l_qs                      NUMBER;
  l_att                     NUMBER;
  l_atr                     NUMBER;

  l_sqoh                     NUMBER; -- INVCONV
  l_srqoh                    NUMBER; -- INVCONV
  l_sqr                      NUMBER; -- INVCONV
  l_sqs                      NUMBER; -- INVCONV
  l_satt                     NUMBER; -- INVCONV
  l_satr                     NUMBER; -- INVCONV


  l_msg_index               number;
  l_lot_control_flag        BOOLEAN;
  l_lot_control_code        NUMBER;
  l_org_id                  NUMBER;


  -- added by fabdi 03/May/2001
--  l_process_flag      VARCHAR2(1) := FND_API.G_FALSE; -- INVCONV
--  l_ic_item_mst_rec         GMI_RESERVATION_UTIL.ic_item_mst_rec; -- INVCONV
  -- end fabdi

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING QUERY_QTY_TREE ' , 0.5 ) ; -- debug level changed to 0.5 for bug 13435459
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ORG IS : ' || P_ORG_ID , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ITEM IS : ' || P_ITEM_ID , 1 ) ;
      oe_debug_pub.add(  'Sub inventory IS : ' || p_subinventory_code , 1 ) ; --11777419
  END IF;
  -- added by fabdi 03/May/2001
/*  IF NOT INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => p_org_id) -- INVCONV remove OPM stuff
  THEN
  l_process_flag := FND_API.G_FALSE;
  ELSE
  l_process_flag := FND_API.G_TRUE;
  END IF;

  IF l_process_flag = FND_API.G_TRUE
  THEN

        GMI_RESERVATION_UTIL.Get_OPM_item_from_Apps
        ( p_organization_id          =>  p_org_id
        , p_inventory_item_id        =>  p_item_id
        , x_ic_item_mst_rec          =>  l_ic_item_mst_rec
        , x_return_status            =>  l_return_status
        , x_msg_count                =>  l_msg_count
        , x_msg_data                 =>  l_msg_data);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
           FND_MESSAGE.SET_NAME('GMI','GMI_ERROR');
           FND_MESSAGE.SET_TOKEN('BY_PROC',
                            'GMI_Reservation_Util.Get_OPM_item_from_Apps');
           FND_MESSAGE.SET_TOKEN('WHERE','OE_SCHEDULE_UTIL');
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        get_process_query_quantities ( p_org_id => p_org_id,
                                       p_item_id =>  l_ic_item_mst_rec.item_id,
                                       p_line_id => p_line_id,
                                       x_on_hand_qty => l_qoh,
                                       x_avail_to_reserve => l_atr
                                      );

  -- end fabdi
  ELSE   */

  BEGIN
     -- Added code to fix bug 2111470
    IF p_org_id is null THEN
       l_org_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
    END IF;

    SELECT msi.lot_control_code
    INTO   l_lot_control_code
    FROM   mtl_system_items msi
    WHERE  msi.inventory_item_id = p_item_id
    AND    msi.organization_id   = nvl(p_org_id,l_org_id);

    IF l_lot_control_code = 2 THEN
       l_lot_control_flag := TRUE;
    ELSE
       l_lot_control_flag := FALSE;
    END IF;

  EXCEPTION
   WHEN OTHERS THEN
   l_lot_control_flag := FALSE;
  END;

  -- Bug 2259553.
  --inv_quantity_tree_pvt.clear_quantity_cache;
    inv_quantity_tree_pvt.mark_all_for_refresh
  (  p_api_version_number  => 1.0
   , p_init_msg_lst        => FND_API.G_TRUE
   , x_return_status       => l_return_status
   , x_msg_count           => l_msg_count
   , x_msg_data            => l_msg_data
   );

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         oe_msg_pub.transfer_msg_stack;
         l_msg_count:=OE_MSG_PUB.COUNT_MSG;
         for I in 1..l_msg_count loop
             l_msg_data := OE_MSG_PUB.Get(I,'F');
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
             END IF;
         end loop;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          oe_msg_pub.transfer_msg_stack;
          l_msg_count:=OE_MSG_PUB.COUNT_MSG;
          for I in 1..l_msg_count loop
              l_msg_data := OE_MSG_PUB.Get(I,'F');
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
              END IF;
          end loop;
          RAISE FND_API.G_EXC_ERROR;
  END IF;


  inv_quantity_tree_pub.query_quantities
    (  p_api_version_number      => 1.0
     , x_return_status           => l_return_status
     , x_msg_count               => l_msg_count
     , x_msg_data                => l_msg_data
     , p_organization_id         => p_org_id
     , p_inventory_item_id       => p_item_id
     , p_tree_mode               => 2
     , p_is_revision_control     => false
     , p_is_lot_control          => l_lot_control_flag
     , p_lot_expiration_date     => nvl(p_sch_date,sysdate)
     , p_is_serial_control       => false
     , p_grade_code              => NUll  -- INVCONV      NOT NEEDED NOW
     , p_revision                => null
     , p_lot_number              => null
     , p_subinventory_code       => p_subinventory_code    --null --11777419
     , p_locator_id              => null
     , x_qoh                     => l_qoh
     , x_rqoh                    => l_rqoh
     , x_qr                      => l_qr
     , x_qs                      => l_qs
     , x_att                     => l_att
     , x_atr                     => l_atr
     , x_sqoh                    => l_sqoh        -- INVCONV
     , x_srqoh                   => l_srqoh       -- INVCONV
     , x_sqr                     => l_sqr         -- INVCONV
     , x_sqs                     => l_sqs         -- INVCONV
     , x_satt                    => l_satt        -- INVCONV
     , x_satr                    => l_satr        -- INVCONV
     );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING QUERY_QUANTITIES' , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
  END IF;
 -- END IF; INVCONV
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RR: L_QOH ' || L_QOH , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RR: L_QOH ' || L_ATR , 1 ) ;
  END IF;

  x_on_hand_qty      := l_qoh;
  x_avail_to_reserve := l_atr;

  x_on_hand_qty2      := l_sqoh; -- INVCONV
  x_avail_to_reserve2 := l_satr; -- INVCONV

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING QUERY_QTY_TREE ' , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
  END IF;

EXCEPTION

   WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Query_Qty_Tree');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Qty_Tree;
/*---------------------------------------------------------------------
Procedure Name : Action ATP
Description    : This procedure is called to perform atp_check on a single
                 line
--------------------------------------------------------------------- */
Procedure Action_ATP
(p_x_line_rec     IN OUT NOCOPY OE_ORDER_PUB.line_rec_type,
 p_old_line_rec   IN  OE_ORDER_PUB.line_rec_type,
x_return_status OUT NOCOPY VARCHAR2)

IS
l_msg_count               NUMBER;
l_mrp_msg_data            VARCHAR2(2000);
--l_session_id              NUMBER := 0;
--l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
--l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
--l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
--l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
l_on_hand_qty             NUMBER;
l_avail_to_reserve        NUMBER;
l_on_hand_qty2             NUMBER; -- INVCONV
l_avail_to_reserve2        NUMBER; -- INVCONV


-- l_process_flag            VARCHAR2(1) := FND_API.G_FALSE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level; --INVCONV
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING ACTION ATP ' || P_X_LINE_REC.SCHEDULE_ACTION_CODE , 1 ) ;
   END IF;

     -- Call MRP API

   Call_MRP_ATP(p_x_line_rec    => p_x_line_rec,
                p_old_line_rec  => p_old_line_rec,
                x_return_status => x_return_status);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'AFTER CALLING MRP API: ' || X_RETURN_STATUS , 2 ) ;
   END IF;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

  /* Load_Mrp_Request_From_Rec
      ( p_line_rec        => p_x_line_rec
      , p_old_line_rec    => p_old_line_rec
      , x_mrp_atp_rec     => l_mrp_atp_rec);

   IF l_mrp_atp_rec.error_code.count > 0 THEN

     l_session_id := Get_Session_Id;

     G_ATP_CHECK_session_id := l_session_id;
     -- Call ATP

     IF l_debug_level > 0 THEN
      oe_debug_pub.add('1. Calling MRP API with session id '||l_session_id,0.5);  -- debug level changed to 0.5 for bug 13435459
     END IF;

     MRP_ATP_PUB.Call_ATP
         ( p_session_id          =>  l_session_id
          , p_atp_rec            =>  l_mrp_atp_rec
          , x_atp_rec            =>  l_mrp_atp_rec
          , x_atp_supply_demand  =>  l_atp_supply_demand
          , x_atp_period         =>  l_atp_period
          , x_atp_details        =>  l_atp_details
          , x_return_status      =>  x_return_status
          , x_msg_data           =>  l_mrp_msg_data
          , x_msg_count          =>  l_msg_count);

     IF l_debug_level > 0 THEN
       oe_debug_pub.add('5. After Calling MRP_ATP_PUB.Call_ATP' ||
                                              x_return_status,0.5);   -- debug level changed to 0.5 for bug 13435459
     END IF;
     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     Load_Results_from_rec(p_atp_rec        => l_mrp_atp_rec,
                           p_x_line_rec     => p_x_line_rec,
                           x_return_status  => x_return_status);

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
     END IF;

   END IF; -- Mrp count.
  */
     -- We also need to pass back on-hand qty and available_to_reserve
     -- qties while performing ATP. Getting these values from inventory.

     FOR K IN 1..g_atp_tbl.count LOOP
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING QUERY_QTY_TREE' , 1 ) ;
        END IF;
        Query_Qty_Tree(p_org_id     => g_atp_tbl(K).ship_from_org_id,
                       p_item_id    => g_atp_tbl(K).inventory_item_id,
                       p_line_id    => g_atp_tbl(K).line_id,
                       p_sch_date   => nvl(g_atp_tbl(K).group_available_date,
                                       g_atp_tbl(K).ordered_qty_Available_Date),
                       x_on_hand_qty      => l_on_hand_qty,
                       x_avail_to_reserve => l_avail_to_reserve,
                       x_on_hand_qty2      => l_on_hand_qty2, -- INVCONV
                       x_avail_to_reserve2 => l_avail_to_reserve2, -- INVCONV
                       p_subinventory_code => g_atp_tbl(K).subinventory_code --11777419
                      );

       /*  --  added by fabdi 03/May/2001  NOT NEEDED NOW FOR OPM INVENTORY CONVERGENCE INVCONV
        IF NOT INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id
                                           => g_atp_tbl(K).ship_from_org_id)
        THEN
             l_process_flag := FND_API.G_FALSE;
        ELSE
             l_process_flag := FND_API.G_TRUE;
        END IF;

        IF l_process_flag = FND_API.G_TRUE
        THEN
          g_atp_tbl(K).on_hand_qty          := l_on_hand_qty;
          g_atp_tbl(K).available_to_reserve := l_avail_to_reserve;
          g_atp_tbl(K).QTY_ON_REQUEST_DATE  := l_avail_to_reserve;
                                                 -- Available field in ATP

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_ON_HAND_QTY' || L_ON_HAND_QTY ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_AVAIL_TO_RESERVE' || L_AVAIL_TO_RESERVE ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'AVAILABLE ' || L_AVAIL_TO_RESERVE ) ;
          END IF;
        ELSE   */  --  INVCONV

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SUBSTITUTE_FLAG :' || G_ATP_TBL ( K ) .SUBSTITUTE_FLAG , 1 ) ;
          END IF;
          IF g_atp_tbl(K).substitute_flag = 'N' THEN
             g_atp_tbl(K).on_hand_qty          := l_on_hand_qty;
             g_atp_tbl(K).available_to_reserve := l_avail_to_reserve;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'L_ON_HAND_QTY' || L_ON_HAND_QTY ) ;
             END IF;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'L_AVAIL_TO_RESERVE' || L_AVAIL_TO_RESERVE ) ;
             END IF;
          ELSE
             g_atp_tbl(K).sub_on_hand_qty          := l_on_hand_qty;
             g_atp_tbl(K).sub_available_to_reserve := l_avail_to_reserve;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'SUB L_ON_HAND_QTY' || L_ON_HAND_QTY ) ;
             END IF;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'SUB L_AVAIL_TO_RESERVE' || L_AVAIL_TO_RESERVE ) ;
             END IF;

             Query_Qty_Tree
                  (p_org_id     => g_atp_tbl(K).ship_from_org_id,
                   p_item_id    => g_atp_tbl(K).request_item_id,
                   p_line_id    => g_atp_tbl(K).line_id,
                   p_sch_date   => g_atp_tbl(K).req_item_available_date,
                   x_on_hand_qty      => l_on_hand_qty,
                   x_avail_to_reserve => l_avail_to_reserve,
                   x_on_hand_qty2      => l_on_hand_qty2, -- INVCONV
                   x_avail_to_reserve2 => l_avail_to_reserve2 -- INVCONV
                   );
             g_atp_tbl(K).on_hand_qty          := l_on_hand_qty;
             g_atp_tbl(K).available_to_reserve := l_avail_to_reserve;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'L_ON_HAND_QTY' || L_ON_HAND_QTY ) ;
             END IF;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'L_AVAIL_TO_RESERVE' || L_AVAIL_TO_RESERVE ) ;
             END IF;
          END IF;
        -- END IF; -- INVCONV
        -- end fabdi

     END LOOP;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING ACTION ATP' || X_RETURN_STATUS , 1 ) ;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Action_ATP');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Action_ATP;
/*---------------------------------------------------------------------
Procedure Name : Action_Schedule
Description    : This procedure is called from Process_Request proecudure
                 to perform the action of SCHEDULE or RESERVE on the line.
--------------------------------------------------------------------- */
Procedure Action_Schedule
(p_x_line_rec     IN OUT NOCOPY OE_ORDER_PUB.line_rec_type,
 p_old_line_rec   IN  OE_ORDER_PUB.line_rec_type,
 p_sch_action     IN  VARCHAR2,
 p_qty_to_reserve IN  NUMBER := Null,
 x_return_status OUT NOCOPY VARCHAR2)

IS
l_msg_count               NUMBER;
--l_session_id              NUMBER := 0;
--l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
--l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
--l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
--l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
l_mrp_msg_data            VARCHAR2(200);
l_old_reserved_quantity   NUMBER;
l_qty_to_reserve          NUMBER;

l_old_reserved_quantity2   NUMBER; -- INVCONV
l_qty2_to_reserve          NUMBER := null;  -- INVCONV

l_p_qty2_to_reserve          NUMBER := null;  -- INVCONV

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ENTERING ACTION SCHEDULE' , 1 ) ;
 END IF;

l_p_qty2_to_reserve := p_x_line_rec.reserved_quantity2; -- Bug#8501046

  IF (p_x_line_rec.schedule_status_code is null)
  THEN

    -- The line is not scheduled, so go ahead and schedule the line
    -- Create MRP record from the line record with the action of schedule
    -- The result of the request should be in x_request_rec

    -- Setting the action to schedule since first we need to schedule the line.
    -- Will reset the action to what is actually was after calling MRP.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SCHEDULING FROM ACTION SCHEDULE' , 1 ) ;
    END IF;
    p_x_line_rec.schedule_action_code := OESCH_ACT_SCHEDULE;

/*
    Load_MRP_Request_from_rec
          ( p_line_rec              => p_x_line_rec
          , p_old_line_rec          => p_old_line_rec
          , x_mrp_atp_rec               => l_mrp_atp_rec);

   oe_debug_pub.add('Action Schedule Count is ' ||
                       l_mrp_atp_rec.error_code.count,1);

   -- We are adding this so that we will not call MRP when
   -- table count is 0.

   IF l_mrp_atp_rec.error_code.count > 0 THEN


    l_session_id := Get_Session_Id;

   IF l_debug_level > 0 THEn
    oe_debug_pub.add('1. Calling MRP API with session id '||l_session_id,0.5);   -- debug level changed to 0.5 for bug 13435459
   END IF;

    MRP_ATP_PUB.Call_ATP
            (  p_session_id             =>  l_session_id
             , p_atp_rec                =>  l_mrp_atp_rec
             , x_atp_rec                =>  l_mrp_atp_rec
             , x_atp_supply_demand      =>  l_atp_supply_demand
             , x_atp_period             =>  l_atp_period
             , x_atp_details            =>  l_atp_details
             , x_return_status          =>  x_return_status
             , x_msg_data               =>  l_mrp_msg_data
             , x_msg_count              =>  l_msg_count);

   IF l_debug_level>0 THEN
     oe_debug_pub.add('1. After Calling MRP_ATP_PUB.Call_ATP' ||
                                              x_return_status,0.5);  -- debug level changed to 0.5 for bug 13435459
   END IF;
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            oe_debug_pub.add('Error is' || l_mrp_msg_data,1);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          --Display_Sch_Errors;
          Display_sch_errors(p_atp_rec => l_mrp_atp_rec,
                             p_line_id => p_x_line_rec.line_id);
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    Load_Results_from_rec
                (p_atp_rec         => l_mrp_atp_rec,
                 p_x_line_rec      => p_x_line_rec,
                 x_return_status   => x_return_status);

    END IF; -- Check for MRP count.
*/



    Call_MRP_ATP(p_x_line_rec    => p_x_line_rec,
                p_old_line_rec  => p_old_line_rec,
                x_return_status => x_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'X_RETURN_STATUS ' || X_RETURN_STATUS , 1 ) ;
    END IF;
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'UNEXPECTED ERROR FROM ' , 1 ) ;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'RR: L2' , 1 ) ;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Reloading p_x_line_rec from l_out_line_tbl since the record
    -- in the table is the one which is demanded.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RR: L3' , 1 ) ;
    END IF;
    p_x_line_rec.schedule_action_code := p_sch_action;

  END IF; /* If schedule_status_code is null */

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RR: L4' , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SCH_CACHED_SCH_LEVEL_CODE ' || SCH_CACHED_SCH_LEVEL_CODE , 1 ) ;
  END IF;

  IF (p_sch_action = OESCH_ACT_RESERVE)
      OR (p_sch_action = OESCH_ACT_SCHEDULE AND
         (sch_cached_sch_level_code = SCH_LEVEL_THREE OR
          -- BUG 1955004
          sch_cached_sch_level_code = SCH_LEVEL_FOUR OR
          -- END 1955004
          sch_cached_sch_level_code is null) AND
          Within_Rsv_Time_Fence(p_x_line_rec.schedule_ship_date, p_x_line_rec.org_id)) OR --4689197
     (p_qty_to_reserve is not null)
  THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SCHEDULING IN ACTION_SCHEDULE' , 1 ) ;
    END IF;

    -- Assigning reserved_quantity to 0 if MISS_NUM, to fix the bug 1384831

    l_old_reserved_quantity := p_old_line_rec.reserved_quantity;
    l_old_reserved_quantity2 := nvl(p_old_line_rec.reserved_quantity2,0); -- INVCONV

    IF p_old_line_rec.reserved_quantity = FND_API.G_MISS_NUM THEN

       l_old_reserved_quantity := 0;

    END IF;
        IF p_old_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM THEN -- INVCONV
       l_old_reserved_quantity2 := 0;
    END IF;

    IF nvl(p_x_line_rec.shippable_flag,'N') = 'Y'
    THEN
      -- Create INV record from the line to reserve

      IF p_qty_to_reserve is null THEN
         l_qty_to_reserve := p_x_line_rec.ordered_quantity -
                           nvl(l_old_reserved_quantity,0);


      ELSE
         l_qty_to_reserve := p_qty_to_reserve;
      END IF;

      IF l_p_qty2_to_reserve is null or
             l_p_qty2_to_reserve = FND_API.G_MISS_NUM THEN -- INVCONV
      -- KYH BUG 4245418 BEGIN
      -- =====================
      -- l_qty2_to_reserve := nvl(p_x_line_rec.ordered_quantity2, 0)  -      -- need to test if this falls over
      --                   nvl(l_old_reserved_quantity2,0);
      -- It is dangerous to compute secondary quantity to reserve based on
      -- ordered_quantity2 minus reserved_quantity2 as above.
      -- This is because ordered_quantity 2 always reflects a standard conversion from ordered_quantity
      -- whereas reserved_quantity2 may be the result of one or more lot specific calculations
      -- Combining values from these different conversion rates may not give the correct result.
      -- Better to compute the secondary to reserve by converting l_qty_to_reserve
         IF p_x_line_rec.ordered_quantity_uom2 is not null and
                        p_x_line_rec.ordered_quantity_uom2 <> FND_API.G_MISS_CHAR THEN
           -- Only invoke the conversion for dual tracked items
           --Bug#8501046,Checked the scenario using default and non-default both types for lot-specific conversion as well and the formula works fine.
 	            l_qty2_to_reserve := nvl(p_x_line_rec.ordered_quantity2, 0)- nvl(l_old_reserved_quantity2,0);       --bug 7675494
 	            /*IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'DUAL Tracked quantity so convert the qty to reserve ' || l_qty_to_reserve , 1 ) ;
           END IF;
           l_qty2_to_reserve    := inv_convert.inv_um_convert(
                                   item_id                      => p_x_line_rec.inventory_item_id
                                 , lot_number                   => NULL
                                 , organization_id              => p_x_line_rec.ship_from_org_id
                                 , PRECISION                    => 5
                                 , from_quantity                => l_qty_to_reserve
                                 , from_unit                    => p_x_line_rec.order_quantity_uom
                                 , to_unit                      => p_x_line_rec.ordered_quantity_uom2
                                 , from_name                    => NULL -- from uom name
                                 , to_name                      => NULL -- to uom name
                                 );
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'After UOM conversion the secondary to reserve is  ' || l_qty2_to_reserve , 1 ) ;
           END IF;

           IF l_qty2_to_reserve = -99999 THEN
             -- conversion failed
             FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR'); -- INVCONV
             OE_MSG_PUB.ADD;
             IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'ERROR on UOM conversion to Secondary UOM which is '||p_x_line_rec.ordered_quantity_uom2 , 1 ) ;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
           END IF; */
         END IF;
      -- KYH BUG 4245418 END
      ELSE
         l_qty2_to_reserve := l_p_qty2_to_reserve;
      END IF;
      IF l_qty2_to_reserve = 0 -- INVCONV
         THEN
                    l_qty2_to_reserve := NULL;
      END IF;


      IF l_qty_to_reserve > 0 THEN

         -- Since we are calling schedule line from post write.
         -- line is posted to db. we do not need to skip the code.
     --    IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
            -- We cannot create a reservation currently if the line is
            -- being created (since the lines is yet not in the database,
            -- and there is a validation done with this line id when we
            -- call INV API.). We will populate the reserved quantity on
            -- the line record, and in the post-write procedure (in OEXULINB),
            -- we will perform the reservation.

            --l_out_line_rec.schedule_status_code := OESCH_STATUS_SCHEDULED;
      --        p_x_line_rec.reserved_quantity    := l_qty_to_reserve;

       --  ELSE
             IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'QTY TO RESERVE ' || L_QTY_TO_RESERVE , 2 ) ;
                     oe_debug_pub.add(  'QTY2 TO RESERVE ' || L_QTY2_TO_RESERVE , 2 ) ;
       END IF;


             Reserve_Line
              ( p_line_rec              => p_x_line_rec
              , p_quantity_to_reserve   => l_qty_to_reserve
              , p_quantity2_to_reserve   => l_qty2_to_reserve -- INVCONV
              , x_return_status         => x_return_status);

        -- END IF; -- Operation on the line is create or not

      ELSE

         p_x_line_rec.reserved_quantity :=
                                  p_old_line_rec.reserved_quantity;

           p_x_line_rec.reserved_quantity2 :=
                                  p_old_line_rec.reserved_quantity2; -- INVCONV

           IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'p_old_line_rec.reserved_quantity ' || p_old_line_rec.reserved_quantity , 2 ) ;
                     oe_debug_pub.add(  'p_old_line_rec.reserved_quantity2 ' || p_old_line_rec.reserved_quantity2 , 2 ) ;
       END IF;

      END IF; -- l_qty_to_reserve
    END IF; -- If shippable Flag = Y

  END IF; /* If reservation needs to be performed */


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING ACTION SCHEDULE: ' || X_RETURN_STATUS , 1 ) ;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Action_Schedule');
        END IF;

END Action_Schedule;
/*---------------------------------------------------------------------
Procedure Name : Action_UnSchedule
Description    : This procedure is called from Process_Request proecudure
                 to perform the action of UNSCHEDULE or UNRESERVE on the line.
--------------------------------------------------------------------- */

Procedure Action_UnSchedule
(p_old_line_rec  IN  OE_ORDER_PUB.line_rec_type,
 p_sch_action    IN  VARCHAR2,
 p_x_line_rec    IN OUT NOCOPY OE_ORDER_PUB.line_rec_type,
x_return_status OUT NOCOPY VARCHAR2)

IS

l_msg_count               NUMBER;
--l_msg_data                VARCHAR2(2000);
--l_session_id              NUMBER := 0;
--l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
--l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
--l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
--l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
l_mrp_msg_data            VARCHAR2(200);
l_qty_to_unreserve        NUMBER;
l_qty2_to_unreserve        NUMBER; -- INVCONV
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING ACTION_UNSCHEDULE ' , 1 ) ;
     END IF;

     -- shipping_interfaced_flag
     IF (p_old_line_rec.reserved_quantity is not null AND
         p_old_line_rec.reserved_quantity <> FND_API.G_MISS_NUM)
     THEN

        -- Call INV API to delete the reservations on  the line.

        l_qty_to_unreserve := p_old_line_rec.reserved_quantity;
        l_qty2_to_unreserve := p_old_line_rec.reserved_quantity2; -- INCONV
        IF l_qty2_to_unreserve = 0 -- INVCONV
         THEN
          l_qty2_to_unreserve := NULL;
        END IF;

        Unreserve_Line
            ( p_line_rec               => p_old_line_rec
            , p_quantity_to_unreserve  => l_qty_to_unreserve
            , p_quantity2_to_unreserve  => l_qty2_to_unreserve
            , x_return_status          => x_return_status);

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
        END IF;

     END IF;

     -- If the action was unreserve, we do not need to unschedule the line.
     -- Thus we will check for this condition before unscheduling.

     IF p_sch_action <> OESCH_ACT_UNRESERVE THEN

       -- Create MRP record with action of UNDEMAND.

       p_x_line_rec.schedule_action_code := OESCH_ACT_UNDEMAND;

 /*
      Load_MRP_Request_from_rec
          ( p_line_rec              => p_x_line_rec
          , p_old_line_rec          => p_old_line_rec
          , x_mrp_atp_rec             => l_mrp_atp_rec);

      IF l_mrp_atp_rec.error_code.count > 0 THEN

        l_session_id := Get_Session_Id;

        -- Call ATP
       IF l_debug_level > 0 THEn
        oe_debug_pub.add('1. Calling MRP API with session id '||l_session_id,0.5);  -- debug level changed to 0.5 for bug 13435459
       END IF;

        MRP_ATP_PUB.Call_ATP
          ( p_session_id             =>  l_session_id
          , p_atp_rec                =>  l_mrp_atp_rec
          , x_atp_rec                =>  l_mrp_atp_rec
          , x_atp_supply_demand      =>  l_atp_supply_demand
          , x_atp_period             =>  l_atp_period
          , x_atp_details            =>  l_atp_details
          , x_return_status          =>  x_return_status
          , x_msg_data               =>  l_mrp_msg_data
          , x_msg_count              =>  l_msg_count);
       IF l_debug_level > 0 THEN
         oe_debug_pub.add('2. After Calling MRP_ATP_PUB.Call_ATP' ||
                                              x_return_status,0.5);   -- debug level changed to 0.5 for bug 13435459
       END IF;

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           --Display_Sch_Errors;
           Display_sch_errors(p_atp_rec => l_mrp_atp_rec,
                              p_line_id => p_x_line_rec.line_id);
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        Load_Results_from_rec
                    (p_atp_rec         => l_mrp_atp_rec,
                     p_x_line_rec      => p_x_line_rec,
                     x_return_status   => x_return_status);

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; -- MRP Count.

 */


        Call_MRP_ATP(p_x_line_rec    => p_x_line_rec,
                     p_old_line_rec  => p_old_line_rec,
                     x_return_status => x_return_status);

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AFTER CALLING MRP API: ' || X_RETURN_STATUS , 2 ) ;
       END IF;

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    -- If the action performed is UNSCHEDULE, then the reserved quantity is now     -- null.
    p_x_line_rec.reserved_quantity    := null;
    p_x_line_rec.reserved_quantity2   := null; -- INVCONV


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING ACTION_UNSCHEDULE ' , 1 ) ;
  END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Action_UnSchedule');
        END IF;

END Action_UnSchedule;

/*---------------------------------------------------------------------
Procedure Name : Action_Undemand
Description    : This procedure is called from SCHEDULE LINE proecudure
                 to perform the UNDEMAD on the line when an item is changed.
--------------------------------------------------------------------- */

Procedure Action_Undemand
(p_old_line_rec  IN  OE_ORDER_PUB.line_rec_type,
x_return_status OUT NOCOPY VARCHAR2)


IS
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(2000);
l_session_id              NUMBER := 0;
l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
l_out_mrp_atp_rec         MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
-- Bug 1955004
l_scheduling_level_code   VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTERING ACTION_UNDEMAND' , 1 ) ;
      END IF;

   --BUG 1955004
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CHECKING SCHEDULING LEVEL...' , 1 ) ;
   END IF;
   l_scheduling_level_code := Get_Scheduling_Level(p_old_line_rec.header_id,
                                                   p_old_line_rec.line_type_id);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_SCHEDULING_LEVEL_CODE : ' || L_SCHEDULING_LEVEL_CODE , 1 ) ;
   END IF;
   -- 3763015
   IF (l_scheduling_level_code = SCH_LEVEL_FOUR OR
    l_scheduling_level_code = SCH_LEVEL_FIVE OR
    NVL(fnd_profile.value('ONT_BYPASS_ATP'),'N') = 'Y') OR
    Nvl(p_old_line_rec.bypass_sch_flag, 'N') = 'Y' THEN -- DOO Integration
    -- this is an inactive demand line.

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IT IS AN INACTIVE DEMAND LINE' , 1 ) ;
      END IF;
      NULL;
   ELSE
   --END 1955004

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'STD ACTION_UNDEMAND ACTION' , 1 ) ;
      END IF;

      -- Create MRP record with action of UNDEMAND.

      Load_MRP_Request_from_rec
          ( p_line_rec      => p_old_line_rec
          , p_old_line_rec  => p_old_line_rec
          , p_sch_action    => OESCH_ACT_UNDEMAND
          , x_mrp_atp_rec   => l_mrp_atp_rec);

      IF l_mrp_atp_rec.error_code.count > 0 THEN

        l_session_id := Get_Session_Id;

        -- Call ATP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  '4. CALLING MRP API WITH SESSION ID '||L_SESSION_ID , 1 ) ;
        END IF;

        MRP_ATP_PUB.Call_ATP
          ( p_session_id             =>  l_session_id
          , p_atp_rec                =>  l_mrp_atp_rec
          , x_atp_rec                =>  l_out_mrp_atp_rec
          , x_atp_supply_demand      =>  l_atp_supply_demand
          , x_atp_period             =>  l_atp_period
          , x_atp_details            =>  l_atp_details
          , x_return_status          =>  x_return_status
          , x_msg_data               =>  l_msg_data
          , x_msg_count              =>  l_msg_count);

                                              IF l_debug_level  > 0 THEN
                                                  oe_debug_pub.add(  '4. AFTER CALLING MRP_ATP_PUB.CALL_ATP' || X_RETURN_STATUS , 1 ) ;
                                              END IF;

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           --Display_Sch_Errors;
           Display_sch_errors(p_atp_rec => l_out_mrp_atp_rec,
                              p_line_id => p_old_line_rec.line_id);
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF; -- MRP count.
     END IF;  -- For new IF statement for 1955004

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING ACTION_UNDEMAND' , 1 ) ;
      END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Action_Undemand');
        END IF;

END Action_Undemand;

/*---------------------------------------------------------------------
Procedure Name : Action_Reserve
Description    : This procedure is called from Process_Request proecudure
--------------------------------------------------------------------- */
Procedure Action_Reserve
(p_x_line_rec     IN  OUT NOCOPY OE_ORDER_PUB.line_rec_type,
 p_old_line_rec   IN  OE_ORDER_PUB.line_rec_type,
x_return_status OUT NOCOPY VARCHAR2)

IS
l_old_reserved_qty     NUMBER :=nvl(p_old_line_rec.reserved_quantity,0);
l_changed_reserved_qty NUMBER;
l_qty_to_reserve       NUMBER;
--
l_old_reserved_qty2     NUMBER :=nvl(p_old_line_rec.reserved_quantity2,0); -- INVCONV
l_changed_reserved_qty2 NUMBER; -- INVCONV
l_qty2_to_reserve       NUMBER; -- INVCONV


l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ENTERING ACTION RESERVE ' ) ;
 END IF;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- When only subinventory changed on the line. Need Scheduling
 -- Will pass line action as reserve. We will unreserve and reserve
 -- the line for new subinventory.

 -- shipping_interfaced_flag.
  -- 4653097
 IF (NOT OE_GLOBALS.Equal(p_x_line_rec.subinventory,
                         p_old_line_rec.subinventory)
   OR NOT OE_GLOBALS.Equal(p_x_line_rec.project_id,
                         p_old_line_rec.project_id)
   OR NOT OE_GLOBALS.Equal(p_x_line_rec.task_id,
                         p_old_line_rec.task_id))
 AND l_old_reserved_qty > 0
 AND NVL(p_x_line_rec.shipping_interfaced_flag,'N') = 'N'
 THEN

    IF p_old_line_rec.reserved_quantity2 = 0 -- INVCONV
       then
     l_qty2_to_reserve := NULL;

    END IF;

    Unreserve_Line
    (p_line_rec              => p_old_line_rec,
     p_quantity_to_unreserve => p_old_line_rec.reserved_quantity,
     p_quantity2_to_unreserve => l_qty2_to_reserve, -- INVCONV
     x_return_status         => x_return_status);

     l_old_reserved_qty := 0;
     l_old_reserved_qty2 := 0; -- INVCONV
     -- Start Added for bug 2470416
     -- To set the Cascading_Request_Logged to True
     -- which will trigger the form to requery

     OE_GLOBALS.G_CASCADING_REQUEST_LOGGED :=TRUE;
     -- End Added for bug 2470416

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER DELETING THE RESERVATION' , 3 ) ;
    END IF;
 END IF;

 IF nvl(p_x_line_rec.shippable_flag,'N') = 'Y'
 THEN
    -- 3239619 / 3362461 / 3456052 Convert the old reserve qty as per new UOM if not same.
    IF NOT OE_GLOBALS.Equal(p_old_line_rec.order_quantity_uom,p_x_line_rec.order_quantity_uom)
      AND l_old_reserved_qty > 0 THEN
    l_old_reserved_qty := INV_CONVERT.INV_UM_CONVERT(item_id   =>p_old_line_rec.inventory_item_id,
                                      precision    =>5,
                                      from_quantity=>l_old_reserved_qty,
                                      from_unit    => p_old_line_rec.order_quantity_uom,
                                      to_unit      => p_x_line_rec.order_quantity_uom,
                                      from_name    => NULL,
                                      to_name      => NULL
                                      );
    END IF;
    l_changed_reserved_qty   := l_old_reserved_qty -
                                nvl(p_x_line_rec.reserved_quantity,0);
    l_changed_reserved_qty2   := nvl(l_old_reserved_qty2, 0)  -
                                nvl(p_x_line_rec.reserved_quantity2,0); -- INVCONV
    IF l_changed_reserved_qty2 = 0 -- INVCONV
     THEN
        l_changed_reserved_qty2 := NULL;
    END IF;

    -- shipping_interfaced_flag
    IF l_changed_reserved_qty > 0 THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RESERVED QUANTITY HAS DECREASED' , 1 ) ;
       END IF;

       -- No need to pass old record. Since this is a change
       -- due to quantity.
       -- Start 2595661
       IF (nvl(p_x_line_rec.shipping_interfaced_flag,'N') = 'Y'
           AND NOT Get_Pick_Status(p_x_line_rec.line_id) ) THEN

          Do_Unreserve
                ( p_line_rec               => p_x_line_rec
                , p_quantity_to_unreserve  => l_changed_reserved_qty
                , p_quantity2_to_unreserve  => l_changed_reserved_qty2 -- INVCONV
                , p_old_ship_from_org_id    => p_old_line_rec.ship_from_org_id --5024936
                , x_return_status          => x_return_status);
       ELSE
       -- End 2595661

          Unreserve_Line
               ( p_line_rec              => p_x_line_rec
               , p_quantity_to_unreserve => l_changed_reserved_qty
               , p_quantity2_to_unreserve => l_changed_reserved_qty2 -- INVCONV
               , x_return_status         => x_return_status);
       END IF;  --2595661

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;


    ELSIF l_changed_reserved_qty < 0 THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RESERVED QUANTITY HAS INCREASED' , 1 ) ;
       END IF;

       -- Make sure reservation qty should not be more than
       -- Ordered qty.

       IF p_x_line_rec.reserved_quantity > p_x_line_rec.ordered_quantity
       THEN

          l_qty_to_reserve := p_x_line_rec.ordered_quantity -
                              l_old_reserved_qty;

       ELSE

          l_qty_to_reserve := p_x_line_rec.reserved_quantity -
                             l_old_reserved_qty;

       END IF;
       IF p_x_line_rec.reserved_quantity2 > p_x_line_rec.ordered_quantity2 -- INVCONV
       THEN

          l_qty2_to_reserve := nvl(p_x_line_rec.ordered_quantity2, 0) -
                              nvl(l_old_reserved_qty2, 0);

       ELSE

          l_qty2_to_reserve := nvl(p_x_line_rec.reserved_quantity2, 0) -
                             nvl(l_old_reserved_qty2, 0) ;

       END IF;
       IF l_qty2_to_reserve = 0 -- INVCONV
         THEN
          l_qty2_to_reserve := null;
       end if;


       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'QTY TO RESERVE ' || L_QTY_TO_RESERVE , 2 ) ;
                     oe_debug_pub.add(  'QTY2 TO RESERVE ' || L_QTY2_TO_RESERVE , 2 ) ;
       END IF;

       IF l_qty_to_reserve > 0
       THEN




          Reserve_Line
          ( p_line_rec             => p_x_line_rec
          , p_quantity_to_reserve  => l_qty_to_reserve
          , p_quantity2_to_reserve  => l_qty2_to_reserve -- INVCONV
          , p_rsv_update           => TRUE  -- Going to increase reservation
          , x_return_Status        => x_return_status);

       END IF;

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF; -- end of reserved_quantity change code

 END IF; -- Check for shippable flag.
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'EXITING ACTION RESERVE ' ) ;
 END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Action_Reserve');
        END IF;
END Action_Reserve;

/*---------------------------------------------------------------------
Procedure Name : Action_Reschedule
Description    : This procedure is called from Process_Request proecudure
--------------------------------------------------------------------- */
Procedure Action_Reschedule
(p_x_line_rec     IN OUT NOCOPY OE_ORDER_PUB.line_rec_type,
 p_old_line_rec   IN  OE_ORDER_PUB.line_rec_type,
x_return_status OUT NOCOPY VARCHAR2,

x_reserve_later OUT NOCOPY VARCHAR2)

IS
l_re_reserve_flag      VARCHAR2(1) := 'Y';
l_old_reserved_qty     NUMBER := nvl(p_old_line_rec.reserved_quantity,0);
l_qty_to_reserve       NUMBER;
l_changed_reserved_qty NUMBER;
l_qty_to_unreserve     NUMBER;
-- INVCONV
l_old_reserved_qty2     NUMBER := nvl(p_old_line_rec.reserved_quantity2,0);
l_qty2_to_reserve       NUMBER;
l_changed_reserved_qty2 NUMBER;
l_qty2_to_unreserve     NUMBER;



l_reservation_rec      inv_reservation_global.mtl_reservation_rec_type;
l_rsv_tbl              inv_reservation_global.mtl_reservation_tbl_type;
l_sales_order_id       NUMBER;
l_x_error_code         NUMBER;
l_lock_records         VARCHAR2(1);
l_sort_by_req_date     NUMBER ;
l_count                NUMBER;
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_dummy_sn             inv_reservation_global.serial_number_tbl_type;
l_buffer               VARCHAR2(2000);
l_rsv_update           BOOLEAN :=FALSE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
/*OPM BEGIN Bug 2794760
====================*/
-- l_item_rec         OE_ORDER_CACHE.item_rec_type; -- OPM  -- INVCONV Not needed now because of OPM inventory convergence
/*OPM End Bug 2794760
====================*/
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_reserve_later := 'N';
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING ACTION_RESCHEDULE ' || P_X_LINE_REC.OPEN_FLAG , 1 ) ;
    END IF;

    IF (p_old_line_rec.reserved_quantity is not null)
    THEN

      -- Added this part of code to fix bug 1797109.
      -- Unreserve only when one of the below mentioned, attrubutes
      -- changes, in other case simply re-schedule the line.
      --During the fix l_re_reserve_flag is introduced.

-- shipping_interfaced_flag
--      l_re_reserve_flag := 'N';
      --4653097
      IF
         -- Bug 6335352
         -- Commenting the below line
         -- nvl(p_x_line_rec.shipping_interfaced_flag,'N') = 'N' AND
        (NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,
                                p_old_line_rec.inventory_item_id)
        OR NOT OE_GLOBALS.Equal(p_x_line_rec.subinventory,
                                p_old_line_rec.subinventory)
        OR NOT OE_GLOBALS.Equal(p_x_line_rec.order_quantity_uom,
                                p_old_line_rec.order_quantity_uom)
        OR NOT OE_GLOBALS.Equal(p_x_line_rec.ship_from_org_id,
                                p_old_line_rec.ship_from_org_id)
        OR NOT OE_GLOBALS.Equal(p_x_line_rec.project_id,
                                p_old_line_rec.project_id)
        OR NOT OE_GLOBALS.Equal(p_x_line_rec.task_id,
                                p_old_line_rec.task_id)) THEN

 --         l_re_reserve_flag := 'Y';
          -- Call INV to delete the old reservations

          IF p_old_line_rec.reserved_quantity2 = 0 -- INVCONV
           THEN
              l_qty2_to_unreserve := NULL;
          END IF;

          Unreserve_Line
             (p_line_rec              => p_old_line_rec,
              p_quantity_to_unreserve => p_old_line_rec.reserved_quantity,
              p_quantity2_to_unreserve => l_qty2_to_unreserve , -- INVCONV
              x_return_status         => x_return_status);
          l_old_reserved_qty := 0;
          l_old_reserved_qty2 := 0; -- INVCONV
      END IF;
    END IF;


    -- If the scheduling is happening due to inventory item change.
    -- We should call MRP twice. First time we should call the with
    -- Undemand for old item. Second call would be redemand.

    IF NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,
                            p_old_line_rec.inventory_item_id)
    THEN

        Action_undemand(p_old_line_rec  => p_old_line_rec,
                        x_return_status => x_return_status);

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;


     -- If the rescheduling is happening for order change then
     -- Undmand the line, else redemand.

     IF p_x_line_rec.ordered_quantity > 0 THEN
        p_x_line_rec.schedule_action_code := OESCH_ACT_REDEMAND;
     ELSE
        p_x_line_rec.schedule_action_code := OESCH_ACT_UNDEMAND;
     END IF;

     Call_MRP_ATP(p_x_line_rec    => p_x_line_rec,
                  p_old_line_rec  => p_old_line_rec,
                  x_return_status => x_return_status);

     --4161641
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'X_RETURN_STATUS ' || X_RETURN_STATUS , 1 ) ;
     END IF;
     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UNEXPECTED ERROR FROM MRP CALL ' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ACTION RESCHEDULE : ERROR FROM MRP CALL' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Item has been substituted by MRP. Remove any old reservation
     -- on old item. Since reservation cannot be made without posting
     -- the new item to db postpone the reservation on new item to
     -- process_request.

     IF nvl(p_x_line_rec.shipping_interfaced_flag,'N') = 'N'
     AND NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,
                              p_old_line_rec.inventory_item_id)
     THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SUB: REMOVE THE RESERVATION ON OLD LINE' , 1 ) ;
       END IF;

       IF l_old_reserved_qty > 0 THEN

          IF p_old_line_rec.reserved_quantity2 = 0 -- INVCONV
           THEN
              l_qty2_to_unreserve := NULL;
          END IF;


          Unreserve_Line
             (p_line_rec              => p_old_line_rec,
              p_quantity_to_unreserve => p_old_line_rec.reserved_quantity,
              p_quantity2_to_unreserve => l_qty2_to_unreserve, -- INVCONV
              x_return_status         => x_return_status);

          l_old_reserved_qty := 0;
          l_old_reserved_qty2 := 0; -- INVCONV
       END IF;

       IF  (p_x_line_rec.reserved_quantity is NOT NULL OR
            Within_Rsv_Time_Fence(p_x_line_rec.schedule_ship_date, p_x_line_rec.org_id)) --4689197
       AND (sch_cached_sch_level_code = SCH_LEVEL_THREE  OR
            -- BUG 1955004
            sch_cached_sch_level_code = SCH_LEVEL_FOUR OR
            -- END 1955004
            sch_cached_sch_level_code is null)
       AND  l_old_reserved_qty = 0
       THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SUB: SETTING RESERVE LATER FLAG' , 3 ) ;
         END IF;
         x_reserve_later := 'Y';
       END IF;

       RETURN;
     END IF;

     IF nvl(p_x_line_rec.shippable_flag,'N') = 'Y'
     THEN

       IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_ship_date,
                               p_old_line_rec.schedule_ship_date)
          AND OE_GLOBALS.Equal(p_x_line_rec.ship_from_org_id, -- 5178175
                               p_old_line_rec.ship_from_org_id)
       AND l_old_reserved_qty > 0
       AND p_x_line_rec.ordered_quantity > 0
       THEN


         l_reservation_rec.reservation_id := fnd_api.g_miss_num;

         l_sales_order_id
                     := Get_mtl_sales_order_id(p_old_line_rec.header_id);
         l_reservation_rec.demand_source_header_id  := l_sales_order_id;
         l_reservation_rec.demand_source_line_id    := p_old_line_rec.line_id;
         l_reservation_rec.organization_id  := p_old_line_rec.ship_from_org_id;


         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'RSCH: CALLING INVS QUERY_RESERVATION ' , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
         END IF;
         inv_reservation_pub.query_reservation
           ( p_api_version_number       => 1.0
           , p_init_msg_lst              => fnd_api.g_true
           , x_return_status             => x_return_status
           , x_msg_count                 => l_msg_count
           , x_msg_data                  => l_msg_data
           , p_query_input               => l_reservation_rec
           , x_mtl_reservation_tbl       => l_rsv_tbl
           , x_mtl_reservation_tbl_count => l_count
           , x_error_code                => l_x_error_code
           , p_lock_records              => l_lock_records
           , p_sort_by_req_date          => l_sort_by_req_date
           );

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER CALLING INVS QUERY_RESERVATION: ' || X_RETURN_STATUS , 0.5 ) ; -- debug level changed to 0.5 for bug 13435459
          END IF;

         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

                                       IF l_debug_level  > 0 THEN
                                           oe_debug_pub.add(  'RESERVATION RECORD COUNT IS: ' || L_RSV_TBL.COUNT , 1 ) ;
                                       END IF;

         -- Let's get the total reserved_quantity
         FOR K IN 1..l_rsv_tbl.count LOOP

          l_reservation_rec := l_rsv_tbl(K);
          l_reservation_rec.requirement_date := p_x_line_rec.schedule_ship_date;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RSCH: CALLING INVS UPDATE RESERVATION ' , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
          END IF;
          inv_reservation_pub.update_reservation
            ( p_api_version_number        => 1.0
            , p_init_msg_lst              => fnd_api.g_true
            , x_return_status             => x_return_status
            , x_msg_count                 => l_msg_count
            , x_msg_data                  => l_msg_data
            , p_original_rsv_rec          => l_rsv_tbl(k)
            , p_to_rsv_rec                => l_reservation_rec
            , p_original_serial_number    => l_dummy_sn -- no serial contorl
            , p_to_serial_number          => l_dummy_sn -- no serial control
            , p_validation_flag           => fnd_api.g_true
            , p_over_reservation_flag     => 2 -- 4715544
            );

           IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER CALLING INVS UPDATE_RESERVATION: ' || X_RETURN_STATUS , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
           END IF;

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 IF l_msg_data is not null THEN
                    fnd_message.set_encoded(l_msg_data);
                    l_buffer := fnd_message.get;
                    oe_msg_pub.add_text(p_message_text => l_buffer);
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'ERROR : '|| L_BUFFER , 1 ) ;
                    END IF;
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
          END IF;
         END LOOP;

       END IF; -- Ship date has changed

          -- End code for bug 2126165.

        -- Inv code expect the item to be available in database before
        -- making reservation. If the reservation is being made due to
        -- change in inventory_item_id, we will move the reservation
        -- call to post_write. -- 1913263.

        -- pre-write scheduling call has been moved to post write.
        -- we can perform reservation right here for item change.

    /*    IF NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,
                                p_old_line_rec.inventory_item_id)
        THEN

             oe_debug_pub.add('No re-reserve due to item change',1);
             RETURN;
        END IF;
  */
        -- 4316272
        IF  (nvl(p_x_line_rec.reserved_quantity, 0) > 0 OR
             Within_Rsv_Time_Fence(p_x_line_rec.schedule_ship_date,
				   p_x_line_rec.org_id))
        AND (sch_cached_sch_level_code = SCH_LEVEL_THREE  OR
            -- BUG 1955004
            sch_cached_sch_level_code = SCH_LEVEL_FOUR OR
            -- END 1955004
             sch_cached_sch_level_code is null)
        AND  l_old_reserved_qty = 0
        THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RESERVING IN ACTION_RESCHEDULE' ) ;
       END IF;

          -- Old reservation does not exists on the line.
          -- create a new reservation.
          -- (Post Pack J)Create Reservation if within reservation time fence
          -- 4316272 Removed redundant condition.
          IF (nvl(p_x_line_rec.reserved_quantity,0) >
                 p_x_line_rec.ordered_quantity)
          OR nvl(p_x_line_rec.reserved_quantity,0) = 0
          OR (nvl(p_x_line_rec.reserved_quantity,0) <
                     p_x_line_rec.ordered_quantity
            AND OE_SYS_PARAMETERS.value('PARTIAL_RESERVATION_FLAG',p_x_line_rec.org_id) = 'Y') THEN
             l_qty_to_reserve := p_x_line_rec.ordered_quantity;

          ELSE
             l_qty_to_reserve := p_x_line_rec.reserved_quantity;
          END IF;

         -- Bug 6335352
         -- Added the below code
         IF NOT OE_GLOBALS.EQUAL(p_x_line_rec.order_quantity_uom, p_old_line_rec.order_quantity_uom) THEN
           IF p_x_line_rec.ordered_quantity > p_x_line_rec.reserved_quantity AND
              Within_Rsv_Time_Fence(p_x_line_rec.schedule_ship_date, p_x_line_rec.org_id) THEN
                l_qty_to_reserve := p_x_line_rec.ordered_quantity;
           ELSIF p_x_line_rec.ordered_quantity < p_x_line_rec.reserved_quantity THEN
               l_qty_to_reserve := p_x_line_rec.ordered_quantity;
           END IF;
         END IF;

      IF (nvl(p_x_line_rec.reserved_quantity2,0) >   -- INVCONV
                 nvl(p_x_line_rec.ordered_quantity2, 0) )
          OR nvl(p_x_line_rec.reserved_quantity2,0) = 0
          --OR (OE_SYS_PARAMETERS.value('PARTIAL_RESERVATION_FLAG') = 'Y'
          OR Within_Rsv_Time_Fence(p_x_line_rec.schedule_ship_date, p_x_line_rec.org_id) --4689197
          THEN
             l_qty2_to_reserve := nvl(p_x_line_rec.ordered_quantity2, 0);
          ELSE
             l_qty2_to_reserve := nvl(p_x_line_rec.reserved_quantity2, 0);
          END IF;
          IF l_qty2_to_reserve = 0 -- INVCONV
            THEN
            l_qty2_to_reserve := NULL;
          END IF;

          IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'QTY TO RESERVE ' || L_QTY_TO_RESERVE , 2 ) ;
                     oe_debug_pub.add(  'QTY2 TO RESERVE ' || L_QTY2_TO_RESERVE , 2 ) ;
       END IF;


          Reserve_Line
          ( p_line_rec             => p_x_line_rec
          , p_quantity_to_reserve  => l_qty_to_reserve
          , p_quantity2_to_reserve  => l_qty2_to_reserve -- INVCONV
          , x_return_Status        => x_return_status);


        ELSIF l_old_reserved_qty > 0 THEN

           --If ordered qty is not changed on the line, take care of the
           --reservation changes.

          IF  OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,
                               p_old_line_rec.ordered_quantity)
          AND NOT OE_GLOBALS.Equal(p_x_line_rec.reserved_quantity,
                                   l_old_reserved_qty)
          THEN
             Action_reserve(p_x_line_rec    => p_x_line_rec,
                            p_old_line_rec  => p_old_line_rec,
                            x_return_status => x_return_status);
             -- reserved qty has changed during rescheduling process.

          ELSE -- Ordered qty has changed on the line.


           l_changed_reserved_qty   := l_old_reserved_qty -
                                       p_x_line_rec.reserved_quantity;
                 l_changed_reserved_qty2   := nvl(l_old_reserved_qty2, 0) -   -- INVCONV
                                       nvl(p_x_line_rec.reserved_quantity2,0);
           IF l_changed_reserved_qty2 = 0 -- INVCONV
            THEN
                 l_changed_reserved_qty2 := NULL;
           END IF;

           IF  p_x_line_rec.ordered_quantity  >=  p_x_line_rec.reserved_quantity
           THEN
            -- Ordered qty is greater than res qty. Take care of reservation
            -- changes if any.

            IF l_changed_reserved_qty > 0 THEN

               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'RESERVED QUANTITY HAS DECREASED' , 1 ) ;
               END IF;

                -- No need to pass old record. Since this is a change
                -- due to quantity.
                Unreserve_Line
                ( p_line_rec              => p_x_line_rec
                , p_quantity_to_unreserve => l_changed_reserved_qty
                , p_quantity2_to_unreserve => l_changed_reserved_qty2 -- INVCONV
                , x_return_status         => x_return_status);

                IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
            /* -- Moved to the last part of If-elsif check
            -- Pack J
            -- Call reserve_line if partial flag is set to 'Yes' and
            --ordered quantity is greater than reserved quantity.
            ELSIF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
                 --AND OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,
                 --                  p_old_line_rec.ordered_quantity)
                 AND p_x_line_rec.ordered_quantity >NVL(p_x_line_rec.reserved_quantity,0)
                 AND OE_SYS_PARAMETERS.value('PARTIAL_RESERVATION_FLAG') = 'Y'
                 AND Within_Rsv_Time_Fence(p_x_line_rec.schedule_ship_date) THEN
                   l_qty_to_reserve :=
                      p_x_line_rec.ordered_quantity - NVL(p_x_line_rec.reserved_quantity,0);
                   l_qty2_to_reserve :=
                      nvl(p_x_line_rec.ordered_quantity2, 0) - NVL(p_x_line_rec.reserved_quantity2,0); -- INVCONV
                 -- Setting rsv_update flag to TRUE if reservation exists
                 IF NVL(p_x_line_rec.reserved_quantity,0) > 0 THEN
                 -- Going to update the reservation
                    l_rsv_update := TRUE;
                 END IF;
                 Reserve_Line
                  ( p_line_rec              => p_x_line_rec
                  , p_quantity_to_reserve   => l_qty_to_reserve
                  , p_quantity2_to_reserve   => l_qty2_to_reserve -- INVCONV
                  , p_rsv_update            => l_rsv_update
                  , x_return_status         => x_return_status);
            */

            ELSIF l_changed_reserved_qty < 0 THEN

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'RESERVED QUANTITY HAS INCREASED' , 1 ) ;
              END IF;

              l_qty_to_reserve := p_x_line_rec.reserved_quantity -
                                  l_old_reserved_qty;

                            l_qty2_to_reserve := NVL(p_x_line_rec.reserved_quantity2,0) -   -- INVCONV
                                  nvl(l_old_reserved_qty2, 0);

              IF l_qty2_to_reserve = 0 THEN -- INVCONV
                l_qty2_to_reserve := null;
              end if;
              IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'QTY TO RESERVE ' || L_QTY_TO_RESERVE , 2 ) ;
                     oe_debug_pub.add(  'QTY2 TO RESERVE ' || L_QTY2_TO_RESERVE , 2 ) ;
       END IF;


              Reserve_Line
              ( p_line_rec             => p_x_line_rec
              , p_quantity_to_reserve  => l_qty_to_reserve
              , p_quantity2_to_reserve  => l_qty2_to_reserve -- INVCONV
              , p_rsv_update           => TRUE
              , x_return_Status        => x_return_status);

              IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

            /* -- Begin Bug 2794760    -- INVCONV take out OPM code
            ELSIF   (OE_Line_Util.Process_Characteristics
                    (p_x_line_rec.inventory_item_id
                    ,p_x_line_rec.ship_from_org_id
                    ,l_item_rec) AND
                    p_x_line_rec.ordered_quantity > p_old_line_rec.ordered_quantity AND
                    l_changed_reserved_qty = 0 AND
                    (NVL(p_x_line_rec.reserved_quantity,0) > 0 OR
                     Within_Rsv_Time_Fence(p_x_line_rec.schedule_ship_date)))  THEN

                    OE_DEBUG_PUB.ADD('OPM Only - Reserved Quantity should also Increase',1);

              l_qty_to_reserve := p_x_line_rec.ordered_quantity - l_old_reserved_qty;

              Reserve_Line
              ( p_line_rec             => p_x_line_rec
              , p_quantity_to_reserve  => l_qty_to_reserve
              , p_rsv_update           => TRUE
              , x_return_Status        => x_return_status);

              IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
            -- END Bug 2794760   */


            -- Post Pack J
            -- Call reserve_line if ordered quantity is greater than reserved quantity.
            ELSIF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
                 --AND OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,
                 --                  p_old_line_rec.ordered_quantity)
                 AND p_x_line_rec.ordered_quantity >NVL(p_x_line_rec.reserved_quantity,0)
                 --AND OE_SYS_PARAMETERS.value('PARTIAL_RESERVATION_FLAG') = 'Y'
                 AND Within_Rsv_Time_Fence(p_x_line_rec.schedule_ship_date, p_x_line_rec.org_id) THEN --4689197
                   l_qty_to_reserve :=
                      p_x_line_rec.ordered_quantity - NVL(p_x_line_rec.reserved_quantity,0);
                -- KYH BUG 4245418 BEGIN
                -- =====================
                -- l_qty2_to_reserve :=   -- INVCONV
                --    nvl(p_x_line_rec.ordered_quantity2, 0) - NVL(p_x_line_rec.reserved_quantity2,0);
                -- It is dangerous to compute secondary quantity to reserve based on
                -- ordered_quantity2 minus reserved_quantity2 as above.
                -- This is because ordered_quantity2 always reflects a standard conversion from ordered_quantity
                -- whereas reserved_quantity2 may be the result of one or more lot specific calculations
                -- Combining values from these different conversion rates may not give the correct result.
                -- Better to compute the secondary to reserve by converting l_qty_to_reserve
                   IF p_x_line_rec.ordered_quantity_uom2 is not null and
                     p_x_line_rec.ordered_quantity_uom2 <> FND_API.G_MISS_CHAR THEN
                     -- Only invoke the conversion for dual tracked items
                     IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'DUAL Tracked quantity so convert the qty to reserve ' || l_qty_to_reserve , 1 ) ;
                     END IF;
                     l_qty2_to_reserve    := inv_convert.inv_um_convert(
                                          item_id                      => p_x_line_rec.inventory_item_id
                                        , lot_number                   => NULL
                                        , organization_id              => p_x_line_rec.ship_from_org_id
                                        , PRECISION                    => 5
                                        , from_quantity                => l_qty_to_reserve
                                        , from_unit                    => p_x_line_rec.order_quantity_uom
                                        , to_unit                      => p_x_line_rec.ordered_quantity_uom2
                                        , from_name                    => NULL -- from uom name
                                        , to_name                      => NULL -- to uom name
                                        );
                     IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'After UOM conversion the secondary to reserve is  ' || l_qty2_to_reserve , 1 ) ;
                     END IF;

                     IF l_qty2_to_reserve = -99999 THEN
                       -- conversion failed
                       FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR'); -- INVCONV
                       OE_MSG_PUB.ADD;
                       IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'ERROR on UOM conversion to Secondary UOM which is '||p_x_line_rec.ordered_quantity_uom2 , 1 ) ;
                       END IF;
                       RAISE FND_API.G_EXC_ERROR;
                     END IF;
                   END IF;
                -- KYH BUG 4245418 END

               IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'p_x_line_rec.ordered_quantity ' || p_x_line_rec.ordered_quantity , 2 ) ;
                                        oe_debug_pub.add(  'p_x_line_rec.reserved_quantity ' || p_x_line_rec.reserved_quantity , 2 ) ;

                         oe_debug_pub.add(  'p_x_line_rec.ordered_quantity2 ' || p_x_line_rec.ordered_quantity2 , 2 ) ;
                                        oe_debug_pub.add(  'p_x_line_rec.reserved_quantity2 ' || p_x_line_rec.reserved_quantity2 , 2 ) ;
                        END IF;


                   IF l_qty2_to_reserve = 0 THEN -- INVCONV
                            l_qty2_to_reserve := null;
                     end if;


                 -- Setting rsv_update flag to TRUE if reservation exists
                 IF NVL(p_x_line_rec.reserved_quantity,0) > 0 THEN
                 -- Going to update the reservation
                    l_rsv_update := TRUE;
                 END IF;

                 IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'QTY TO RESERVE ' || L_QTY_TO_RESERVE , 2 ) ;
                     oe_debug_pub.add(  'QTY2 TO RESERVE ' || L_QTY2_TO_RESERVE , 2 ) ;
       END IF;



                 Reserve_Line
                  ( p_line_rec              => p_x_line_rec
                  , p_quantity_to_reserve   => l_qty_to_reserve
                  , p_quantity2_to_reserve   => l_qty2_to_reserve
                  , p_rsv_update            => l_rsv_update
                  , x_return_status         => x_return_status);

            END IF; -- end of reserved_quantity change code

           ELSE

            -- Order qty is less than res qty. That means, we are
            -- need to unreserve the extra qty. However, that extra res
            -- may not exists in reservation table.
            -- For example Orderes qty is getting updated as 10 to 9
            -- and reservation qty from 9 to 12. In this case we do not
            -- need any res changes. To deal this, check the old reservation
            -- with the new ordered qty.

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ORDERED QTY IS GREATER THAN RES QTY' , 1 ) ;
            END IF;

           IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,
                        p_old_line_rec.ordered_quantity) THEN --for bug 12378904

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'OLD Ordered QTY Not Equal to New Ordered QTY' , 1 ) ;
            END IF;


	    l_qty_to_unreserve := l_old_reserved_qty -
                                  p_x_line_rec.ordered_quantity;

            l_qty2_to_unreserve := nvl(l_old_reserved_qty2, 0) -   -- INVCONV
                                  nvl(p_x_line_rec.ordered_quantity2, 0);
            IF l_qty2_to_unreserve = 0 THEN -- INVCONV
                l_qty2_to_unreserve := null;
            end if;
            IF l_qty_to_unreserve > 0 THEN
               /* Unreserve_Line
               ( p_line_rec              => p_x_line_rec
               , p_quantity_to_unreserve => l_qty_to_unreserve
               , p_quantity2_to_unreserve => l_qty2_to_unreserve -- INVCONV
               , x_return_status         => x_return_status);
               */
              -- Start 13906710
              IF (nvl(p_x_line_rec.shipping_interfaced_flag,'N') = 'Y'
                  AND NOT Get_Pick_Status(p_x_line_rec.line_id) ) THEN
              --unreserve the line if it's not picked
                  Do_Unreserve
                        ( p_line_rec               => p_x_line_rec
                        , p_quantity_to_unreserve  => l_qty_to_unreserve --l_changed_reserved_qty Bug 14110600
                        , p_quantity2_to_unreserve  => l_qty2_to_unreserve --l_changed_reserved_qty2-- INVCONV
                        , p_old_ship_from_org_id    =>p_old_line_rec.ship_from_org_id
                        , x_return_status          => x_return_status);

              ELSIF nvl(p_x_line_rec.shipping_interfaced_flag,'N') = 'N' THEN
              --unreserve the line only if it's not interfaced to WSH
                  Unreserve_Line
                      ( p_line_rec              => p_x_line_rec
                      , p_quantity_to_unreserve => l_qty_to_unreserve --l_changed_reserved_qty Bug 14110600
                      , p_quantity2_to_unreserve => l_qty2_to_unreserve --l_changed_reserved_qty2 --INVCONV
                      , x_return_status         => x_return_status);
              END IF;
              --End 13906710

               IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

            END IF; -- reserved_quantity same, ordered_quantity changed
           END IF ; --for bug 12378904
           END IF; -- Order qty > reserve qty.
          END IF; -- Order qty and res qty changes.
        END IF; -- Need reservation changes.
     END IF; -- Shippable flag.

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Action_Reschedule');
        END IF;
END Action_Reschedule;

/*-----------------------------------------------------------------------------
Procedure Name : Load_INV_Request
Description    : This procedure loads the INV's record structure which
                 we will pass to INV for reservation purpose.
                 We need to pass to INV the idenfier for OM demand.
                 We pass the constant INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_OE
                 for all OM Order Lines except Internal Orders.
                 For Internal Orders we pass
                 INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INTERNAL_ORD
                 as the identifier.
----------------------------------------------------------------------------- */
Procedure Load_INV_Request
( p_line_rec                 IN  Oe_Order_Pub.Line_Rec_Type
, p_quantity_to_reserve      IN  NUMBER
, p_quantity2_to_reserve      IN  NUMBER DEFAULT NULL
, x_reservation_rec OUT NOCOPY Inv_Reservation_Global.Mtl_Reservation_Rec_Type)

IS
l_source_code          VARCHAR2(40) := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
l_sales_order_id       NUMBER;
l_subinventory         VARCHAR2(10);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

l_quantity2_to_reserve NUMBER; --INVCONV
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING LOAD INV REQUEST' , 1 ) ;
   END IF;

   x_reservation_rec                      := null;
   x_reservation_rec.reservation_id       := fnd_api.g_miss_num; -- cannot know
   x_reservation_rec.requirement_date     := p_line_rec.schedule_ship_date;
   x_reservation_rec.organization_id      := p_line_rec.ship_from_org_id;
   x_reservation_rec.inventory_item_id    := p_line_rec.inventory_item_id;

   IF p_line_rec.source_document_type_id = 10 THEN

      -- This is an internal order line. We need to give
      -- a different demand sourc2e type for these lines.

      x_reservation_rec.demand_source_type_id    :=
              INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INTERNAL_ORD;
                                                 -- intenal order

   ELSE

      x_reservation_rec.demand_source_type_id    :=
             INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_OE; -- order entry

   END IF;


     -- Get demand_source_header_id from mtl_sales_orders

     l_sales_order_id := Get_mtl_sales_order_id(p_line_rec.HEADER_ID);

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_SALES_ORDER_ID' || L_SALES_ORDER_ID , 1 ) ;
     END IF;

     IF p_line_rec.subinventory = FND_API.G_MISS_CHAR THEN
        l_subinventory := NULL;
     ELSE
        l_subinventory := p_line_rec.subinventory;
     END IF;

     x_reservation_rec.demand_source_header_id := l_sales_order_id;
     x_reservation_rec.demand_source_line_id   := p_line_rec.line_id;
     x_reservation_rec.reservation_uom_code    := p_line_rec.order_quantity_uom;
     x_reservation_rec.reservation_quantity    := p_quantity_to_reserve;
     x_reservation_rec.supply_source_type_id   :=
             INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INV;
     x_reservation_rec.subinventory_code       := l_subinventory;
     /* OPM 02/JUN/00 send process attributes into the reservation -- INVCONV - no longer using attributes
     =============================================================
     x_reservation_rec.attribute1  := p_line_rec.preferred_grade;
     x_reservation_rec.secondary_reservation_quantity   := p_line_rec.ordered_quantity2;
     x_reservation_rec.secondary_uom_code    := p_line_rec.ordered_quantity_uom2;
     x_reservation_rec.attribute3  := p_line_rec.ordered_quantity_uom2;

      OPM 02/JUN/00 END
    ====================*/
    --- diff between  x_reservation_rec.reservation_quantity    and x_reservation_rec.primary_reservation_quantity
    -- INVCONV

      IF p_quantity2_to_reserve = 0 -- INVCONV
        then
         l_quantity2_to_reserve := null;
       ELSE

        l_quantity2_to_reserve := p_quantity2_to_reserve;
       END IF;



     x_reservation_rec.secondary_reservation_quantity   := l_quantity2_to_reserve;
     x_reservation_rec.secondary_uom_code               := p_line_rec.ordered_quantity_uom2;
     --4653097
     IF p_line_rec.project_id IS NOT NULL THEN
        x_reservation_rec.project_id := p_line_rec.project_id;
     END IF;
     IF p_line_rec.task_id IS NOT NULL THEN
        x_reservation_rec.task_id := p_line_rec.task_id;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'p_quantity2_to_reserve = ' || p_quantity2_to_reserve , 1 ) ;
         oe_debug_pub.add(  'p_line_rec.ordered_quantity_uom2 = ' || p_line_rec.ordered_quantity_uom2 , 1 ) ;
     END IF;


   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING LOAD INV REQUEST' , 1 ) ;
   END IF;
EXCEPTION

   WHEN NO_DATA_FOUND THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'WHEN OTHERS OF LOAD INV REQUEST' , 1 ) ;
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_INV_Request;

PROCEDURE Set_Auto_sch_flag_for_batch(p_header_id IN NUMBER)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
                                        IF l_debug_level  > 0 THEN
                                            oe_debug_pub.add(  'ENTERING PROCEDURE SET_AUTO_SCH_FLAG_FOR_BATCH: ' || OESCH_AUTO_SCH_FLAG , 1 ) ;
                                        END IF;

    IF OESCH_AUTO_SCHEDULE_PROFILE = 'Y' THEN
       Set_Auto_Sch_Flag('Y');
    ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LOAD HEADER : ' || P_HEADER_ID , 2 ) ;
     END IF;
     OE_Order_Cache.Load_Order_Header(p_header_id);
     OE_ORDER_CACHE.Load_order_type(OE_ORDER_CACHE.g_header_rec.order_type_id);
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'ORDER TYPE ID : ' || OE_ORDER_CACHE.G_ORDER_TYPE_REC.ORDER_TYPE_ID , 2 ) ;
                     END IF;
     IF nvl(OE_ORDER_CACHE.g_order_type_rec.auto_scheduling_flag,'N') = 'Y' THEN
       Set_Auto_Sch_Flag('Y');
     ELSE
       Set_Auto_Sch_Flag('N');
     END IF;
    END IF;

                                IF l_debug_level  > 0 THEN
                                    oe_debug_pub.add(  'EXITING PROCEDURE SET_AUTO_SCH_FLAG_FOR_BATCH: ' || OESCH_AUTO_SCH_FLAG , 1 ) ;
                                END IF;
END Set_Auto_sch_flag_for_batch;
FUNCTION Get_Scheduling_Level( p_header_id IN NUMBER,
                               p_line_type_id IN NUMBER)
RETURN VARCHAR2
IS
l_scheduling_level_code  VARCHAR2(30) := null;
l_line_type              VARCHAR2(80) := null;
l_order_type             VARCHAR2(80) := null;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_SCHEDULING_LEVEL: ' || P_HEADER_ID||'/'||P_LINE_TYPE_ID , 1 ) ;
  END IF;

  IF p_line_type_id = sch_cached_line_type_id
  THEN

     sch_cached_sch_level_code := sch_cached_sch_level_code_line;
     RETURN sch_cached_sch_level_code;

  END IF;

  IF p_line_type_id IS NOT NULL THEN
   SELECT name, scheduling_level_code
   INTO   l_line_type,l_scheduling_level_code
   FROM   oe_transaction_types
   WHERE  transaction_type_id = p_line_type_id AND
            transaction_type_code = 'LINE';
  END IF;

  IF  l_scheduling_level_code IS NOT NULL THEN

      sch_cached_line_type_id   := p_line_type_id;
      sch_cached_sch_level_code := l_scheduling_level_code;
      sch_cached_sch_level_code_line := l_scheduling_level_code;
      sch_cached_line_type      := l_line_type;
      RETURN l_scheduling_level_code;

  END IF;

  IF p_header_id = sch_cached_header_id
  THEN

     sch_cached_sch_level_code := sch_cached_sch_level_code_head;
     RETURN sch_cached_sch_level_code;

  END IF;
  SELECT /* MOAC_SQL_CHANGE*/ name, scheduling_level_code
  INTO   l_order_type,l_scheduling_level_code
  FROM   oe_order_types_v ot, oe_order_headers_all h
  WHERE  h.header_id     = p_header_id AND
         h.order_type_id =  ot.order_type_id;

  sch_cached_header_id      := p_header_id;
  sch_cached_sch_level_code := l_scheduling_level_code;
  sch_cached_sch_level_code_head := l_scheduling_level_code;
  sch_cached_order_type     := l_order_type;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING GET_SCHEDULING_LEVEL' , 1 ) ;
  END IF;
  RETURN l_scheduling_level_code;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NO DATA FOUND GET_SCHEDULING_LEVEL' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Scheduling_Level;


/*---------------------------------------------------------------
Handle_External_Lines
----------------------------------------------------------------*/
PROCEDURE Handle_External_Lines
( p_x_line_rec  IN OUT NOCOPY   OE_ORDER_PUB.line_rec_type)
IS

  l_line_tbl              OE_ORDER_PUB.line_tbl_type;
  l_old_line_tbl          OE_ORDER_PUB.line_tbl_type;
  l_line_rec              OE_ORDER_PUB.line_rec_type
                          := OE_Order_Pub.G_MISS_LINE_REC;
  l_control_rec           OE_GLOBALS.control_rec_type;
  l_index                 NUMBER;
  l_return_status         VARCHAR2(1);

  CURSOR ato_options IS
  SELECT line_id
  FROM   oe_order_lines
  WHERE  top_model_line_id = p_x_line_rec.top_model_line_id
  AND    ato_line_id       = p_x_line_rec.ato_line_id
  AND    open_flag = 'Y'
  AND    source_type_code = 'EXTERNAL';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'UPDATE SHIP DATE , EXTERNAL '|| P_X_LINE_REC.LINE_ID , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
  END IF;

  IF p_x_line_rec.ship_from_org_id is NULL THEN
    FND_MESSAGE.SET_NAME('ONT','OE_SCH_ATO_WHSE_REQD');
    OE_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF  p_x_line_rec.schedule_ship_date is NULL THEN
    p_x_line_rec.schedule_ship_date := p_x_line_rec.request_date;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SHIP DATE '|| P_X_LINE_REC.SCHEDULE_SHIP_DATE , 1 ) ;
  END IF;

  l_index := 0;
  l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;

  IF p_x_line_rec.ato_line_id is NULL OR
     p_x_line_rec.top_model_line_id is NULL
  THEN

    l_index := l_index + 1;

    l_line_rec.line_id            := p_x_line_rec.line_id;
    l_line_rec.schedule_ship_date := p_x_line_rec.schedule_ship_date;

    l_line_tbl(l_index) := l_line_rec;
  ELSE

    FOR ato_rec in ato_options
    LOOP

      l_index := l_index + 1;
      l_line_rec.line_id            := ato_rec.line_id;
      l_line_rec.schedule_ship_date := p_x_line_rec.schedule_ship_date;

      l_line_tbl(l_index) := l_line_rec;

    END LOOP;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ATO EXTERNAL '|| P_X_LINE_REC.ATO_LINE_ID , 1 ) ;
    END IF;
  END IF;


  OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
  OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING PROCESS ORDER' , 1 ) ;
  END IF;

  OE_Order_PVT.Lines
  ( p_validation_level            => FND_API.G_VALID_LEVEL_NONE
   ,p_control_rec                 => l_control_rec
   ,p_x_line_tbl                  => l_line_tbl
   ,p_x_old_line_tbl              => l_old_line_tbl
   ,x_return_status               => l_return_status);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SCH RETURN_STATUS IS ' || L_RETURN_STATUS , 1 ) ;
   END IF;

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   OE_Order_PVT.Process_Requests_And_Notify
   ( p_process_requests    => TRUE
    ,p_notify              => TRUE
    ,p_line_tbl            => l_line_tbl
    ,p_old_line_tbl        => l_old_line_tbl
    ,x_return_status       => l_return_status);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  '1 SCH RETURN_STATUS IS ' || L_RETURN_STATUS , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
   END IF;

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'UI CASCADE FLAG SET TO TRUE' , 4 ) ;
   END IF;

   OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
   OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HANDLE_EXTERNAL_LINES ERROR '|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Handle_External_Lines;


/*----------------------------------------------------------------
PROCEDURE Schedule_line
Description:
  This procedure will be called from
   oe_line_util.pre_write
   **
   **

  Parameter:
  p_caller         => Internal/External.

  If the call is being made by process order then it is called as
  internal. In all other cases it is external.

  If the value is set to True that means (oe_line_util) it is a
  recursive call and pass appropriate value to process and notify.

  This will be set to external from workflow and grp call. If it is set
  external execute request then and there.

  The procedure checks if we need to perform any scheduling action
  and then branches the code acoording to the type of sch request.

  Added new call to Handle_External_Lines for config dropshipments.
-----------------------------------------------------------------*/
Procedure Schedule_line
( p_old_line_rec       IN  OE_ORDER_PUB.line_rec_type,
  p_x_line_rec         IN  OUT NOCOPY OE_ORDER_PUB.line_rec_type,
  p_caller             IN  VARCHAR2 := SCH_INTERNAL,
x_return_status OUT NOCOPY VARCHAR2 )

IS
  l_old_line_rec         OE_ORDER_PUB.line_rec_type;
  l_sales_order_id       NUMBER;
  l_need_sch             BOOLEAN;
  l_line_action          VARCHAR2(30) := Null;
  l_auto_sch             VARCHAR2(1)  := Null;
  l_old_rsv_qty          NUMBER;
  l_old_rsv_qty2          NUMBER; -- INVCONV
  l_index                NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_auto_schedule_sets   VARCHAR2(1):='Y' ; --4241385
  l_set_id               NUMBER ;	    --4241385
  l_set_exists           BOOLEAN;	    --4241385
  l_set_scheduled        BOOLEAN ;	    --4241385
  --


BEGIN

   Print_Time('Entering ** OE_SCHEDULE_UTIL.Schedule_Line ');
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Entering ** OE_SCHEDULE_UTIL.Schedule_Line ',0.5);  -- Added for bug 13435459
      oe_debug_pub.add('---- Old Record ---- ',1);
      OE_DEBUG_PUB.ADD ( 'LINE ID : '||P_OLD_LINE_REC.LINE_ID , 1 ) ;
      oe_debug_pub.add(  'ATO LINE ID : '||P_OLD_LINE_REC.ATO_LINE_ID , 1 ) ;
      oe_debug_pub.add(  'ORDERED QTY : '||P_OLD_LINE_REC.ORDERED_QUANTITY , 1 ) ;
      oe_debug_pub.add(  'SHIP FROM : '||P_OLD_LINE_REC.SHIP_FROM_ORG_ID , 1 ) ;
      oe_debug_pub.add(  'SUBINVENTORY : '||P_OLD_LINE_REC.SUBINVENTORY , 1 ) ;
      oe_debug_pub.add(  'SCH SHIP DATE: '||P_OLD_LINE_REC.SCHEDULE_SHIP_DATE , 1 ) ;
      oe_debug_pub.add(  'SCH ARR DATE : '||P_OLD_LINE_REC.SCHEDULE_ARRIVAL_DATE , 1 ) ;
      oe_debug_pub.add(  'SHIP SET ID : '||P_OLD_LINE_REC.SHIP_SET_ID , 1 ) ;
      oe_debug_pub.add(  'ARR SET ID : '||P_OLD_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
      oe_debug_pub.add(  'ACTION : '||P_OLD_LINE_REC.SCHEDULE_ACTION_CODE , 1 ) ;
      oe_debug_pub.add(  'STATUS : '||P_OLD_LINE_REC.SCHEDULE_STATUS_CODE , 1 ) ;
      oe_debug_pub.add(  'RES QUANTITY : '||P_OLD_LINE_REC.RESERVED_QUANTITY , 1 ) ;
      oe_debug_pub.add(  'RES QUANTITY2 : '||P_OLD_LINE_REC.RESERVED_QUANTITY2 , 1 ) ;
      oe_debug_pub.add(  'OVERRIDE ATP : '||P_OLD_LINE_REC.OVERRIDE_ATP_DATE_CODE , 1 ) ;
      oe_debug_pub.add(  ' ' , 1 ) ;
      oe_debug_pub.add('---- New Record ----',1);
      OE_DEBUG_PUB.ADD ( 'LINE ID : '||P_X_LINE_REC.LINE_ID , 1 ) ;
      oe_debug_pub.add(  'ATO LINE ID : '||P_X_LINE_REC.ATO_LINE_ID , 1 ) ;
      oe_debug_pub.add(  'ORDERED QTY : '||P_X_LINE_REC.ORDERED_QUANTITY , 1 ) ;
      oe_debug_pub.add(  'SHIP FROM : '||P_X_LINE_REC.SHIP_FROM_ORG_ID , 1 ) ;
      oe_debug_pub.add(  'SUBINVENTORY : '||P_X_LINE_REC.SUBINVENTORY , 1 ) ;
      oe_debug_pub.add(  'SCH SHIP DATE: '||P_X_LINE_REC.SCHEDULE_SHIP_DATE , 1 ) ;
      oe_debug_pub.add(  'SCH ARR DATE : '||P_X_LINE_REC.SCHEDULE_ARRIVAL_DATE , 1 ) ;
      oe_debug_pub.add(  'SHIP SET ID : '||P_X_LINE_REC.SHIP_SET_ID , 1 ) ;
      oe_debug_pub.add(  'ARR SET ID : '||P_X_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
      oe_debug_pub.add(  'ACTION : '||P_X_LINE_REC.SCHEDULE_ACTION_CODE , 1 ) ;
      oe_debug_pub.add(  'STATUS : '||P_X_LINE_REC.SCHEDULE_STATUS_CODE , 1 ) ;
      oe_debug_pub.add(  'RES QTY : '||P_X_LINE_REC.RESERVED_QUANTITY , 1 ) ;
      oe_debug_pub.add(  'RES QTY2 : '||P_X_LINE_REC.RESERVED_QUANTITY2 , 1 ) ;
      oe_debug_pub.add(  'OPERATION : '||P_X_LINE_REC.OPERATION , 1 ) ;
      oe_debug_pub.add(  'OESCH_AUTO_SCH_FLAG : '||OESCH_AUTO_SCH_FLAG , 1 ) ;
      oe_debug_pub.add(  'OVERRIDE ATP : '||P_X_LINE_REC.OVERRIDE_ATP_DATE_CODE , 1 ) ;
      oe_debug_pub.add(  ' ' , 1 ) ;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_old_line_rec := p_old_line_rec;

   IF p_x_line_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
      p_x_line_rec.ship_from_org_id := null;
   END IF;
   IF  p_old_line_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
      l_old_line_rec.ship_from_org_id := null;
   END IF;


   IF p_x_line_rec.schedule_status_code is not null THEN

      l_sales_order_id := Get_mtl_sales_order_id(p_x_line_rec.HEADER_ID);

      IF l_old_line_rec.reserved_quantity is null THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RR1: L_OLD_LINE_REC.RESERVED_QUANTITY IS NULL' , 1 ) ;
         END IF;
      ELSIF l_old_line_rec.reserved_quantity = FND_API.G_MISS_NUM THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RR2: L_OLD_LINE_REC.RESERVED_QUANTITY IS MISSING' , 1 ) ;
         END IF;
      END IF;

      --l_old_line_rec.reserved_quantity :=
      --     OE_LINE_UTIL.Get_Reserved_Quantity
      --     (p_header_id   => l_sales_order_id,
      --      p_line_id     => p_x_line_rec.line_id,
      --      p_org_id      => p_x_line_rec.ship_from_org_id);

      -- INVCONV

      IF l_old_line_rec.reserved_quantity2 is null THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RR1: L_OLD_LINE_REC.RESERVED_QUANTITY2 IS NULL' , 1 ) ;
         END IF;
      ELSIF l_old_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RR2: L_OLD_LINE_REC.RESERVED_QUANTITY2 IS MISSING' , 1 ) ;
         END IF;
      END IF;

      --l_old_line_rec.reserved_quantity2 :=
      --    OE_LINE_UTIL.Get_Reserved_Quantity2
      --    (p_header_id   => l_sales_order_id,
      --     p_line_id     => p_x_line_rec.line_id,
      --     p_org_id      => p_x_line_rec.ship_from_org_id);

      -- INVCONV - MERGED CALLS     FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

      OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                           ,p_line_id   => p_x_line_rec.line_id
                                           --Bug 6335352  ,p_org_id    => p_x_line_rec.ship_from_org_id
                                           ,p_org_id    => l_old_line_rec.ship_from_org_id
                                           ,p_order_quantity_uom => l_old_line_rec.order_quantity_uom
                                           ,x_reserved_quantity =>  l_old_line_rec.reserved_quantity
                                           ,x_reserved_quantity2 => l_old_line_rec.reserved_quantity2
                                           );


   ELSE
      l_old_line_rec.reserved_quantity := null;
      l_old_line_rec.reserved_quantity2 := null; -- INVCONV
   END IF;


   IF l_old_line_rec.reserved_quantity = 0
   THEN
      -- Currently setting the reserved quantity to null if it is zero.
      l_old_line_rec.reserved_quantity := null;
   END IF;

   IF l_old_line_rec.reserved_quantity2 = 0 -- INVCONV
   THEN
      -- Currently setting the reserved quantity2 to null if it is zero.
      l_old_line_rec.reserved_quantity2 := null;
   END IF;

   --By Achaubey for Bug 3239619/3362461/3456052
   -- Old reserve qty quired based on old UOM. Convert it if old UOM is not same as new UOM
   --Bug 6335352
   --This conversion is not required now, as we are passing old_line_rec.order_quantity_uon to Get_Reserved_Quantities API
   /*
   IF l_old_line_rec.reserved_quantity > 0  THEN
      l_old_rsv_qty := l_old_line_rec.reserved_quantity; -- This qty is as per old UOM
      IF NOT OE_GLOBALS.Equal(l_old_line_rec.order_quantity_uom,p_x_line_rec.order_quantity_uom) THEN
         l_old_rsv_qty := INV_CONVERT.INV_UM_CONVERT(item_id      =>l_old_line_rec.inventory_item_id,
                                                     precision    =>5,
                                                     from_quantity=>l_old_line_rec.reserved_quantity,
                                                     from_unit    => l_old_line_rec.order_quantity_uom,    --old uom
                                                     to_unit      => p_x_line_rec.order_quantity_uom,  --new uom
                                                     from_name    => NULL,
                                                     to_name      => NULL
                                                     );
      END IF;
   END IF;
   */

  -- Bug 6335352 starts
  IF p_x_line_rec.reserved_quantity = FND_API.G_MISS_NUM
  THEN
     -- Converting missing to old value
     IF NOT OE_GLOBALS.Equal(l_old_line_rec.order_quantity_uom,p_x_line_rec.order_quantity_uom)
     AND nvl(l_old_line_rec.reserved_quantity, 0) > 0
     THEN
              p_x_line_rec.reserved_quantity := INV_CONVERT.INV_UM_CONVERT
                                                (item_id =>l_old_line_rec.inventory_item_id,
                                                 precision =>5,
                                                 from_quantity=>l_old_line_rec.reserved_quantity,
                                                 from_unit => l_old_line_rec.order_quantity_uom,    --old uom
                                                 to_unit => p_x_line_rec.order_quantity_uom,  --new uom
                                                 from_name => NULL,
                                                 to_name => NULL
                                                );
     ELSE
       -- p_x_line_rec.reserved_quantity := l_old_rsv_qty;
       p_x_line_rec.reserved_quantity := l_old_line_rec.reserved_quantity;
     END IF;
  END IF;
  -- Bug 6335352 ends

   IF l_old_line_rec.reserved_quantity2 > 0  THEN -- INVCONV
      l_old_rsv_qty2 := l_old_line_rec.reserved_quantity2; -- INVCONV
   END IF;

   IF p_x_line_rec.reserved_quantity = FND_API.G_MISS_NUM
   THEN
      -- Converting missing to old value
      p_x_line_rec.reserved_quantity := l_old_rsv_qty;
      -- p_x_line_rec.reserved_quantity := l_old_line_rec.reserved_quantity;
   END IF;

   IF p_x_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM -- INVCONV
   THEN
      -- Converting missing to old value
      p_x_line_rec.reserved_quantity2 := l_old_rsv_qty2;
      -- p_x_line_rec.reserved_quantity := l_old_line_rec.reserved_quantity;
   END IF;


   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OLD RES QTY :' || L_OLD_LINE_REC.RESERVED_QUANTITY , 1 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NEW RES QTY :' || P_X_LINE_REC.RESERVED_QUANTITY , 1 ) ;
   END IF;

   ------------ reserved qty and miss num handling done ----------

   IF p_x_line_rec.source_type_code = 'EXTERNAL' AND
      p_x_line_rec.schedule_ship_date is NOT NULL AND
      NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_ship_date,
                           p_old_line_rec.schedule_ship_date) AND
      p_x_line_rec.ato_line_id is NOT NULL
   THEN
      Handle_External_Lines
         (p_x_line_rec   => p_x_line_rec);
   END IF;

   -- Item substitution code
   -- Clear original attributes when item is changed by user
   -- on a scheduled line. On an unscheduled substituted item
   -- original item will cleared in pre-write code.

   IF  NOT OE_GLOBALS.Equal(p_x_line_rec.Inventory_Item_Id,
                            p_old_line_rec.Inventory_Item_Id)
      AND p_x_line_rec.schedule_status_code is not null
      AND p_x_line_rec.item_relationship_type is null
   THEN
      oe_debug_pub.add('SL: clearing out the original item fields') ;
      p_x_line_rec.Original_Inventory_Item_Id    := Null;
      p_x_line_rec.Original_item_identifier_Type := Null;
      p_x_line_rec.Original_ordered_item_id      := Null;
      p_x_line_rec.Original_ordered_item         := Null;


   END IF;

   -- Set auto scheduling flag for batch calls.


   IF OE_GLOBALS.G_UI_FLAG THEN

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UI IS SET' , 1 ) ;
      END IF;
   ELSE

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UI IS NOT SET' , 1 ) ;
      END IF;
   END IF;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SOURCE :' || P_X_LINE_REC.SOURCE_DOCUMENT_TYPE_ID , 1 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OPR :' || P_X_LINE_REC.OPERATION , 1 ) ;
   END IF;

   IF  NOT OE_GLOBALS.G_UI_FLAG
      AND NOT (nvl(p_x_line_rec.source_document_type_id,-99) = 2)
      AND OE_CONFIG_UTIL.G_CONFIG_UI_USED = 'N'
      -- QUOTING change - set auto scheduling flag for complete negotiation step
      AND (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
           OR OE_Quote_Util.G_COMPLETE_NEG = 'Y'
           )
   THEN --2998550 added check for G_CONFIG_UI_USED to set flag for batch

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE SETTING AUTO SCHEDULING FLAG FOR BATCH' , 1 ) ;
      END IF;

      Set_Auto_sch_flag_for_batch(p_x_line_rec.header_id);

   ELSE
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ELSE SETTING AUTO SCHEDULING FLAG FOR' , 1 ) ;
      END IF;
   END IF;

   -- 4026758
   IF (NOT OE_GLOBALS.Equal(p_x_line_rec.ship_set_id,
                            p_old_line_rec.ship_set_id)
       AND p_old_line_rec.ship_set_id IS NOT NULL)
      OR (NOT OE_GLOBALS.Equal(p_x_line_rec.arrival_set_id,
                               p_old_line_rec.arrival_set_id)
          AND p_old_line_rec.arrival_set_id IS NOT NULL)
      OR ( ( p_x_line_rec.arrival_set_id is not null
             OR p_x_line_rec.ship_set_id is not null)
           AND p_x_line_rec.ordered_quantity = 0) THEN
      -- Line is being removed from  set.


   --bug5631508
    --Record the set history before deleting it

    OE_AUDIT_HISTORY_PVT.RECORD_SET_HISTORY(p_header_id   => p_x_line_rec.header_id,
					    p_line_id     => p_x_line_rec.line_id,
					    p_set_id      => nvl(l_old_line_rec.ship_set_id,l_old_line_rec.arrival_set_id),
					    x_return_status => x_return_status);

    IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER Inserting data in OE_SETS_HISTORY table ' || x_return_status , 1 ) ;
    END IF;

      Log_Delete_Set_Request
         (p_header_id   => p_x_line_rec.header_id,
          p_line_id     => p_x_line_rec.line_id,
          p_set_id      => nvl(l_old_line_rec.ship_set_id,l_old_line_rec.arrival_set_id),
          x_return_status => x_return_status);
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER LOGGING DELETE SETS DELAYED REQUEST IN SCHEDULE LINE' || X_RETURN_STATUS , 1 ) ;
      END IF;
   END IF;

   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
      AND   NOT OE_GLOBALS.Equal(l_old_line_rec.firm_demand_flag,
                                 p_x_line_rec.firm_demand_flag)
      AND  p_x_line_rec.operation = 'UPDATE' THEN

      IF p_x_line_rec.ship_model_complete_flag = 'Y'
      THEN
         Update oe_order_lines_all
            Set firm_demand_flag = p_x_line_rec.firm_demand_flag
            Where top_model_line_id = p_x_line_rec.top_model_line_id;

         OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
      ELSIF p_x_line_rec.ato_line_id is not null
            AND   NOT(p_x_line_rec.ato_line_id =p_x_line_rec.line_id
                      AND   p_x_line_rec.item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                                            OE_GLOBALS.G_ITEM_OPTION,
							    OE_GLOBALS.G_ITEM_INCLUDED)) --9775352
      THEN

         Update oe_order_lines_all
            Set firm_demand_flag = p_x_line_rec.firm_demand_flag
            Where ato_line_id = p_x_line_rec.ato_line_id;

         OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
      END IF;
   END IF; -- Code


   l_need_sch :=  Need_Scheduling(p_line_rec         => p_x_line_rec,
                                  p_old_line_rec     => l_old_line_rec,
                                  x_line_action      => l_line_action,
                                  x_auto_sch         => l_auto_sch);

   IF not(l_need_sch) THEN

      IF NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_SHIP_METHOD_FLAG'),'Y')  = 'N'
         AND NOT OE_GLOBALS.Equal(p_x_line_rec.shipping_method_code,
                                  l_old_line_rec.shipping_method_code)
         AND fnd_profile.value('ONT_SHIP_METHOD_FOR_SHIP_SET') = 'Y'
      THEN

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SHIPPING_METHOD CHANGED , CASCADE' , 4 ) ;
         END IF;

         oe_delayed_requests_pvt.log_request(
                                             p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
                                             p_entity_id              => p_x_line_rec.line_id,
                                             p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                                             p_requesting_entity_id   => p_x_line_rec.line_id,
                                             p_request_type           => OE_GLOBALS.G_CASCADE_SHIP_SET_ATTR,
                                             p_param1                 => p_x_line_rec.header_id,
                                             p_param2                 => p_x_line_rec.ship_set_id,
                                             p_param3                 => p_x_line_rec.shipping_method_code,
                                             x_return_status          => x_return_status);


      END IF;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SCHEDULING NOT REQUIRED' , 1 ) ;
      END IF;
      RETURN;
   END IF;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SCHEDULING LINE_ACTION :' || L_LINE_ACTION , 1 ) ;
   END IF;

   -- 5223953 - Versioning and reason not required for system-driven changes.
   IF p_caller = SCH_EXTERNAL THEN
      p_x_line_rec.change_reason := 'SYSTEM';
   END IF;

   ------------ need scheduling and resource flag done ----------

   <<RE_VALIDATE>>

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING OE_SCHEDULE_UTIL.VALIDATE LINE' , 1 ) ;
   END IF;

   Validate_Line(p_line_rec      => p_x_line_rec,
                 p_old_line_rec  => l_old_line_rec,
                 p_sch_action    => l_line_action,
                 p_caller        => SCH_INTERNAL,
                 x_return_status => x_return_status);

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN

      -- When header preference is set and if line is failing
      -- in validation clear the line from set and do not fail the call
      -- so that line can be saved. -- 2404401.
      IF (p_x_line_rec.ship_set_id is not null
          OR p_x_line_rec.arrival_set_id is not null)
         AND p_x_line_rec.operation = oe_globals.g_opr_create
         AND (p_x_line_rec.top_model_line_id = p_x_line_rec.line_id
              OR   p_x_line_rec.top_model_line_id IS NULL) THEN

         OE_Order_Cache.Load_Order_Header(p_x_line_rec.header_id);
         IF OE_ORDER_CACHE.g_header_rec.customer_preference_set_code = 'SHIP' OR
            OE_ORDER_CACHE.g_header_rec.customer_preference_set_code = 'ARRIVAL'
         THEN

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'VALIDATION FAILED FOR SET' , 2 ) ;
            END IF;
            BEGIN

               OE_ORDER_UTIL.Update_Global_Picture
                  (p_Upd_New_Rec_If_Exists => False,
                   p_old_line_rec  => p_old_line_rec,
                   p_line_rec      => p_x_line_rec,
                   p_line_id       => p_x_line_rec.line_id,
                   x_index         => l_index,
                   x_return_status => x_return_status);

               IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'After update global pic: UNEXP ERRORED OUT' , 1 ) ;
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'After update global pic : ERRORED OUT' , 1 ) ;
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

               IF l_index is not NULL THEN
                  --update Global Picture directly
                  OE_ORDER_UTIL.g_line_tbl(l_index).ship_set_id := Null;
                  OE_ORDER_UTIL.g_line_tbl(l_index).arrival_set_id  := Null;
                  OE_ORDER_UTIL.g_line_tbl(l_index).ship_set := Null;
                  OE_ORDER_UTIL.g_line_tbl(l_index).arrival_set := Null;
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'GLOBAL SHIP_set is : ' || OE_ORDER_UTIL.G_LINE_TBL (L_INDEX).line_id , 1 ) ;
                  END IF;
               END IF; /*l_index is not null check*/

               Update oe_order_lines_all
                  Set arrival_set_id = Null,
                  ship_set_id    = Null
                  Where Line_id = p_x_line_rec.line_id;

               p_x_line_rec.arrival_set_id := Null;
               p_x_line_rec.ship_set_id := Null;

               -- Change the status since we do not want to fail
               -- line to get saved .
               x_return_status := FND_API.G_RET_STS_SUCCESS;

               IF nvl(p_x_line_rec.override_atp_date_code,'N') = 'Y'
                  OR p_x_line_rec.schedule_ship_date is not null
                  OR p_x_line_rec.schedule_arrival_date is not null THEN

                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'VALIDATION FAILED re-validate' , 2 ) ;
                  END IF;

                  GOTO RE_VALIDATE;

               END IF;
            END;
         END IF; -- preference

      --12888703
      ELSIF (p_x_line_rec.ship_set_id is not null
          OR p_x_line_rec.arrival_set_id is not null)
         AND p_x_line_rec.operation = oe_globals.g_opr_update
         AND NVL(oe_sys_parameters.Value('ONT_AUTO_SCH_SETS',p_x_line_rec.org_id),'Y') = 'N' THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         oe_schedule_util.OESCH_SET_SCHEDULING := 'N';
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Add Line to set without schedule as Auto Schedule Set is set to No' , 1 ) ;
         END IF;

      END IF; -- ship set id
      IF l_auto_sch = 'Y' THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'VALIDATION FAILED WHILE AUTO SCH' , 1 ) ;
         END IF;
         -- Change the status since we do not want to fail
         -- line to get saved .
         x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;
      RETURN;
   END IF;


   ------------ here starts the branch based on groups ----------
   -- If rescheduling happening due change of the inventory item,
   -- if it is belong to group undemand the item before logging a
   -- request.After logging a request, we will not have visibility
   -- to old data.

   IF  l_line_action = OESCH_ACT_RESCHEDULE
      AND NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,
                               p_old_line_rec.inventory_item_id)
      AND (p_x_line_rec.ship_set_id is NOT NULL OR
           p_x_line_rec.arrival_set_id is NOT NULL OR
              (nvl(p_x_line_rec.model_remnant_flag, 'N') = 'N' AND
               p_x_line_rec.top_model_line_id is NOT NULL))
   THEN

      IF l_old_line_rec.reserved_quantity is not null
      THEN
         -- Call INV API to delete the reservations on  the line.
         -- shipping_interfaced_flag
         Unreserve_Line
         ( p_line_rec               => l_old_line_rec
           , p_quantity_to_unreserve  => l_old_line_rec.reserved_quantity
           , p_quantity2_to_unreserve  => l_old_line_rec.reserved_quantity2 -- INVCONV
           , x_return_status          => x_return_status);

         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      Action_Undemand(p_old_line_rec   => l_old_line_rec,
                      x_return_status  => x_return_status);


   END IF; -- Undemand.

   -- Breaking the link. Since, if line belong to set may not require to
   -- log a sets request, might require group_scheduling since they are belong
   -- to Model.

   IF nvl(p_x_line_rec.override_atp_date_code,'N') = 'N' AND
      nvl(p_old_line_rec.override_atp_date_code,'N') = 'Y'
      AND p_x_line_rec.top_model_line_id is not null THEN

      Cascade_override_atp(p_line_rec => p_x_line_rec);

   END IF;

   IF (p_x_line_rec.ship_set_id is NOT NULL OR
       p_x_line_rec.arrival_set_id is NOT NULL)
      AND p_x_line_rec.ordered_quantity > 0
      AND l_line_action <> OESCH_ACT_RESERVE  THEN -- remnant??

      /* 4241385 start of auto schedule sets ER changes */

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Get the set details' , 1 ) ;
       END IF;
           IF p_x_line_rec.ship_set_id is NOT NULL THEN

	      l_set_id:= p_x_line_rec.ship_set_id ;
	   ELSIF p_x_line_rec.arrival_set_id is NOT NULL THEN

	      l_set_id:= p_x_line_rec.arrival_set_id ;
	   END IF ;

           get_set_details(p_set_id =>l_set_id
	                 ,x_set_exists=>l_set_exists
			 ,x_set_scheduled=>l_set_scheduled);
           l_auto_schedule_sets := NVL(oe_sys_parameters.Value('ONT_AUTO_SCH_SETS',p_x_line_rec.org_id),'Y');
           IF l_set_exists THEN

	      IF l_set_scheduled
	      OR Get_Auto_Sch_Flag='Y'
	      OR l_auto_schedule_sets='Y'
	      OR (p_x_line_rec.schedule_ship_Date IS NOT NULL )
	      OR (p_x_line_rec.schedule_arrival_Date IS NOT NULL )
	      OR (p_x_line_rec.reserved_quantity>0 )
	      OR (P_X_LINE_REC.SCHEDULE_ACTION_CODE = 'SCHEDULE')
              OR (NVL(P_X_LINE_REC.BOOKED_FLAG,'N')='Y' --10088102
	        AND l_auto_schedule_sets='Y') -- 12642790
	      THEN
		  IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'Set exists and is scheduled.' , 1 ) ;
                  END IF;
	             Log_Set_Request
		       (p_line_rec      => p_x_line_rec,
		        p_old_line_rec  => l_old_line_rec,
		        p_sch_action    => l_line_action,
		        p_caller        => p_caller,
		        x_return_status => x_return_status);
		     IF l_auto_schedule_sets = 'N' THEN --13958294
                     --10064449: Delayed request need to be executed now.
                     OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
                        (p_entity_code   => OE_GLOBALS.G_ENTITY_ALL --OE_GLOBALS.G_ENTITY_LINE  -- 12642790
                        ,p_delete        => FND_API.G_TRUE
                        ,x_return_status => x_return_status );


                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'After calling request for entity ' || X_RETURN_STATUS , 1 ) ;
                     END IF;

                     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

                     OE_Order_PVT.Process_Requests_And_Notify
                       ( x_return_status       => x_return_status);

                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  '1 RETURN_STATUS IS ' || X_RETURN_STATUS , 1 ) ;
                     END IF;

                     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;


                    --End 10064449
		  END IF ; --13958294
	          IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'AFTER LOGGING SETS DELAYED REQUEST ' || X_RETURN_STATUS , 1 ) ;
	          END IF;
	      ELSE --set is not scheduled. Do not log request.
		  IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'scheduling is not required. So Skip' , 1 ) ;
                  END IF;
	      END IF ; --set scheduled.

	   ELSE --set does not exist. That means new set.
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add('set does not exist.get the system parameter value' ,1 ) ;
              END IF;

	      IF l_auto_schedule_sets = 'Y' --parameter is yes
              OR Get_Auto_Sch_Flag='Y'
	      OR (p_x_line_rec.schedule_ship_Date IS NOT NULL )
	      OR (p_x_line_rec.schedule_arrival_Date  IS NOT NULL )
	      OR (p_x_line_rec.reserved_quantity>0 )
	      OR (P_X_LINE_REC.SCHEDULE_ACTION_CODE = 'SCHEDULE')
	      THEN --4241385 tools ->Auto schedule is yes
	          IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'NEW SCHEDULING SETS RELATED' , 1 ) ;
		  END IF;
		     Log_Set_Request
		      (p_line_rec      => p_x_line_rec,
		       p_old_line_rec  => l_old_line_rec,
		       p_sch_action    => l_line_action,
		       p_caller        => p_caller,
		       x_return_status => x_return_status);
		  IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'AFTER LOGGING SETS DELAYED REQUEST ' || X_RETURN_STATUS , 1 ) ;
		  END IF;
	       ELSE --auto schedule is not required.
		  IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'Need not log delayed request.' ) ;
		  END IF;
	       END IF ;

	   END IF ;--set exists check.
/*End of Auto Schedule Sets ER Changes */

   -- ELSIF nvl(p_x_line_rec.model_remnant_flag, 'N') = 'N'
   --Begin bug fix for bug#6153528
    ELSIF ( nvl(p_x_line_rec.model_remnant_flag, 'N') = 'N' or
          ( nvl(p_x_line_rec.model_remnant_flag, 'N') = 'Y' and p_x_line_rec.ato_line_id is not null)
          )
   --End bug fix for bug#6153528
         AND   p_x_line_rec.top_model_line_id is NOT NULL
         AND   l_line_action <> OESCH_ACT_RESERVE
   THEN


      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NEW SCHEDULING CONFIG RELATED' , 1 ) ;
      END IF;

      OE_CONFIG_SCHEDULE_PVT.Log_Config_Sch_Request
         ( p_line_rec       => p_x_line_rec
           ,p_old_line_rec   => l_old_line_rec
           ,p_sch_action     => l_line_action
           ,p_caller         => p_caller
           ,x_return_status  => x_return_status);

   ELSE
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NEW SCHEDULING STANDARD LINE ' , 1 ) ;
      END IF;

      Process_request( p_old_line_rec   => l_old_line_rec,
                       p_caller         => p_caller,
                       p_x_line_rec     => p_x_line_rec,
                       p_sch_action     => l_line_action,
                       x_return_status  => x_return_status);
   END IF; -- Group, parent and independent


   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SCH SHIP DATE ' || P_X_LINE_REC.SCHEDULE_SHIP_DATE , 5 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SCH ARR DATE ' || P_X_LINE_REC.SCHEDULE_ARRIVAL_DATE , 5 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SHIP_FROM ' || P_X_LINE_REC.SHIP_FROM_ORG_ID , 5 ) ;
   END IF;

   Print_Time('Exiting schedule_line');
   IF l_debug_level > 0 THEN
     oe_debug_pub.add('Exiting schedule_line',0.5);  -- Added debug for bug 13435459
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'G_EXC_ERROR IN SCHEDULE_LINE' , 1 ) ;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'G_EXC__UNEXP_ERROR IN SCHEDULE_LINE' , 1 ) ;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OTHERS IN SCHEDULE_LINE'|| SQLERRM , 1 ) ;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
                ,'Schedule_line');
      END IF;

END Schedule_line;


/*---------------------------------------------------------------------
Function Name  : Need_Scheduling
Description    : This API will return to the calling process if scheduling
                 needs to be performed on the line or not.

The output param x_line_action,
  can be used as a guideline to decide
  the scheduling action on a line.
  NOTE: 1) The value of x_line_action should be ignored if this
           function returns false.
        2) More than 1 attributes can have a change, however this
           procedure returns TRUE as soon as first in the code
           is found to be changed.

For a line which is not scheduled, entering following
attributes will result in scheduling:
  schedule_ship_date
  schedue_arrival_date
  reserved_quantity


Cases which need more explaination have comments inside code.
-- We do not schedule service lines.
-- We do not schedule OTA lines. (Changed as per bug 7392538)
-- we will not do scheduling for lines with source_type=EXTERNAL
-- We should not perform scheduling if the line is already scheduled
--------------------------------------------------------------------- */
FUNCTION Need_Scheduling
(p_line_rec           IN OE_ORDER_PUB.line_rec_type,
 p_old_line_rec       IN OE_ORDER_PUB.line_rec_type,
x_line_action OUT NOCOPY VARCHAR2,

x_auto_sch OUT NOCOPY VARCHAR2

 )
RETURN BOOLEAN
IS
  l_order_date_type_code   VARCHAR2(30):='';
  l_request_date_flag      VARCHAR2(1) := 'Y';
  l_shipping_method_flag   VARCHAR2(1) := 'Y';
/* 6663462 Added the following 3 variables for the Delayed Scheduling feature */
  l_delayed_schedule       VARCHAR2(1) := NVL(fnd_profile.value('ONT_DELAY_SCHEDULING'),'N') ;
  l_index                  NUMBER := 0;
  l_return_status          VARCHAR2(1);
  l_auto_schedule_sets     VARCHAR2(1):='Y'; --4241385
  l_set_exists             BOOLEAN ;	     --4241385
  l_set_scheduled          BOOLEAN ;	     --4241385



--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 --4241385. get the sys param value.
 l_auto_schedule_sets := nvl(oe_sys_parameters.Value('ONT_AUTO_SCH_SETS',p_line_rec.org_id),'Y');
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING NEED SCHEDULING' , 1 ) ;
   END IF;

   x_line_action := Null;
   x_auto_sch    := 'N';

   -- QUOTING changes - return FALSE for lines in negotiation phase.
   IF p_line_rec.transaction_phase_code = 'N' THEN
       RETURN FALSE;
   END IF;

   IF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE) THEN
       RETURN FALSE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N1 NOT A SERVICE LINE' , 1 ) ;
   END IF;
   IF p_line_rec.line_category_code =  'RETURN' THEN
       RETURN FALSE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N01 NOT A RETURN LINE' , 1 ) ;
   END IF;
 -- bug 7392538 changes start here
 -- Issue Discription
 -- The function call to OE_OTA_UTIL.Is_OTA_Line has been
 -- commented out due to bug 7385681. The issue here was that
 -- if a class line had UOM in ENR or EVT then this function
 -- call did not allow the class to be scheduled. Hence the
 -- workflow of any included item inside this class always left
 -- the LINE_SCHEDULING activity in the workflow with the result
 -- as INCOMPLETE and got stuck.
 -- The new behavior replicated the manual scheduling behavior.
/*
   IF OE_OTA_UTIL.Is_OTA_Line(p_line_rec.order_quantity_uom)
   THEN
      RETURN FALSE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N2 NOT A OTA ITEM' , 1 ) ;
   END IF;
 */

   -- If a config item is deleted, we do not need to call scheduling.
   -- Config Item can be deleted only through delink API. While delinking,
   -- CTO team takes care of updating the demand picture for the
   -- configuration. If a config item is getting created,
   -- we do not need to call scheduling.

   IF p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG AND
      (p_line_rec.operation = OE_GLOBALS.G_OPR_DELETE OR
       p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE )
   THEN
      RETURN FALSE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N3 NOT CONFIG WITH DELETE AND CREATE OPR' , 1 ) ;
   END IF;

   -- Check to see if this line is a new line which has been created
   -- due to the split action. If yes, then do not schedule it, since we
   -- have already scheduled the line before.

   IF (p_line_rec.split_from_line_id is not null) AND
      (p_line_rec.split_from_line_id <> FND_API.G_MISS_NUM) AND
      (p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE)
   THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'THIS IS A NEW LINE CREATED THRU SPLIT' , 1 ) ;
      END IF;
      RETURN FALSE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N4 NOT A SPLIT LINE' , 1 ) ;
   END IF;

   -- Check to see if this line is the one which is getting split.
   -- If it is, then return FALSE, since this line is already rescheduled.
   IF (p_line_rec.split_action_code = 'SPLIT') THEN
       IF  (p_line_rec.schedule_status_code is not null) AND
           (p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE)
       THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'THIS LINE IS BEING SPLIT' , 1 ) ;
           END IF;
           RETURN FALSE;
       END IF;
   END IF;

/*
   IF (p_line_rec.split_action_code = 'SPLIT') THEN
      oe_debug_pub.add('This is a split action',1);
      RETURN FALSE;
   END IF;
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N5 NOT A SPLIT PARENT' , 1 ) ;
   END IF;


   IF  p_line_rec.source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL
   AND p_line_rec.schedule_status_code is null
   THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UNSCHEDULED EXTERNAL LINE' , 1 ) ;
        END IF;
        RETURN FALSE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N6 NOT A DROP SHIP LINE' , 1 ) ;
   END IF;

   If (p_line_rec.schedule_status_code is null) AND
      ((p_line_rec.schedule_action_code = OESCH_ACT_UNSCHEDULE) OR
      (p_line_rec.schedule_action_code = OESCH_ACT_UNDEMAND) OR
      (p_line_rec.schedule_action_code = OESCH_ACT_UNRESERVE))
   THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'INVALID SCH ACTION ' , 1 ) ;
       END IF;
       FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
       OE_MSG_PUB.Add;
       RETURN FALSE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N7 NOT AN INVALID SCH ACTION' , 1 ) ;
   END IF;

   x_line_action := OESCH_ACT_SCHEDULE;

   IF p_line_rec.schedule_status_code is null
   THEN

     IF  p_line_rec.source_type_code = OE_GLOBALS.G_SOURCE_INTERNAL
     AND p_old_line_rec.source_type_code =  OE_GLOBALS.G_SOURCE_EXTERNAL
     AND p_line_rec.schedule_ship_date IS NOT NULL THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXTERNAL -> INTERNAL WITH SHIP DATE' , 4 ) ;
        END IF;
        RETURN TRUE;

     END IF;


     IF NOT OE_GLOBALS.Equal(p_line_rec.schedule_ship_date,
                             p_old_line_rec.schedule_ship_date)
     THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SCH_SHIP_DATE IS CHANGED , SCHEDULE' , 4 ) ;
        END IF;
        RETURN TRUE;
     END IF;

     IF NOT OE_GLOBALS.Equal(p_line_rec.schedule_arrival_date,
                             p_old_line_rec.schedule_arrival_date)
     THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SCH_ARR_DATE IS CHANGED , SCHEDULE' , 4 ) ;
        END IF;
        RETURN TRUE;
     END IF;
     --14634073: Customer has changed request date after entering schedule ship/Arrival date
     IF (p_line_rec.schedule_arrival_date IS NOT NULL OR
           p_line_rec.schedule_ship_date IS NOT NULL) AND
        NOT OE_GLOBALS.Equal(p_line_rec.request_date,
                            p_old_line_rec.request_date) THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'REQUEST DATE IS ALSO CHANGED , UPDATE SCHEDULE' , 4 ) ;
        END IF;
        RETURN TRUE;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NEW RESERVED QTY' || P_LINE_REC.RESERVED_QUANTITY ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OLD RESERVED QTY' || P_OLD_LINE_REC.RESERVED_QUANTITY ) ;
     END IF;

     IF NOT OE_GLOBALS.Equal(p_line_rec.reserved_quantity,
                             p_old_line_rec.reserved_quantity)
     THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RESERVED QTY ENTERED , SCHEDULE' , 4 ) ;
        END IF;
        RETURN TRUE;
     END IF;

     IF  NOT OE_GLOBALS.Equal(p_line_rec.ship_set_id,
                              p_old_line_rec.ship_set_id)
     AND p_line_rec.ship_set_id IS NOT NULL
     THEN
        --4241385
        get_set_details(p_set_id =>p_line_rec.ship_set_id
	                 ,x_set_exists=>l_set_exists
			 ,x_set_scheduled=>l_set_scheduled);

        IF l_auto_schedule_sets = 'Y'
	OR l_set_scheduled
        OR (NVL(p_line_rec.booked_flag,'N')='Y'  AND  l_auto_schedule_sets = 'Y') THEN --10088102 --12888703
        --4241385
	    IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE IS BEING ADDED TO SHIP SET' , 4 ) ;
            END IF;
            RETURN TRUE;
	END IF ;  --4241385
     END IF;

     IF  NOT OE_GLOBALS.Equal(p_line_rec.arrival_Set_id,
                              p_old_line_rec.arrival_Set_id)
     AND  p_line_rec.arrival_set_id IS NOT NULL
     THEN
         --4241385
        get_set_details(p_set_id =>p_line_rec.arrival_set_id
	                 ,x_set_exists=>l_set_exists
			 ,x_set_scheduled=>l_set_scheduled);

        IF l_auto_schedule_sets = 'Y'
	   OR l_set_scheduled
            OR (NVL(p_line_rec.booked_flag,'N')='Y' AND  l_auto_schedule_sets = 'Y') THEN --10088102 --12888703
         --4241385
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE IS BEING ADDED TO ARRIVAL SET' , 4 ) ;
            END IF;
            RETURN TRUE;
	END IF ;  --4241385
     END IF;

  END IF;


   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(p_line_rec.booked_flag,1);
       oe_debug_pub.add(  'N8' , 1 ) ;
   END IF;

   -- QUOTING changes - trigger auto-scheduling if call is from
   -- complete negotiation
   IF ((p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
        OR OE_Quote_Util.G_COMPLETE_NEG = 'Y')
       AND OESCH_AUTO_SCH_FLAG = 'Y') THEN

         IF (p_line_rec.top_model_line_id is null OR
             p_line_rec.top_model_line_id = FND_API.G_MISS_NUM) AND
             p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD
         THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'AUTO SCHEDULE IS TRUE' , 4 ) ;
                oe_debug_pub.add(  '6663462 : Delay Scheduling : ' || l_delayed_schedule , 4 ) ;

            END IF;
            --8728176 : log request if OM: Bypass ATP is set to 'No'
            IF l_delayed_schedule = 'N' OR
               NVL(fnd_profile.value('ONT_BYPASS_ATP'),'N') ='Y' THEN
              x_auto_sch := 'Y';
              RETURN TRUE;
            ELSE
                OE_delayed_requests_Pvt.log_request(
                 p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                 p_entity_id              => p_line_rec.header_id,
                 p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                 p_requesting_entity_id   => p_line_rec.header_id,
                 p_request_type           => OE_GLOBALS.G_DELAYED_SCHEDULE,
                 x_return_status          => l_return_status);
                 l_index := OE_SCHEDULE_UTIL.OE_Delayed_Schedule_line_tbl.count;
                 OE_SCHEDULE_UTIL.OE_Delayed_Schedule_line_tbl(l_index+1) := p_line_rec;
                 oe_debug_pub.add(  '6663462  : logging delayed scheduling req for header_id ' || OE_SCHEDULE_UTIL.OE_Delayed_Schedule_line_tbl(l_index+1).header_id, 1 ) ;
            END IF;

         END IF;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N9 AFTER AUTO SCHEDULE CHECK' , 1 ) ;
   END IF;

   IF  p_line_rec.schedule_status_code is NULL AND
       p_line_rec.schedule_action_code is NULL AND
       OESCH_AUTO_SCH_FLAG = 'N'
   THEN
      x_line_action := Null;
      RETURN FALSE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N10' , 1 ) ;
   END IF;

   IF p_line_rec.schedule_status_code = OESCH_STATUS_SCHEDULED AND
      p_line_rec.schedule_action_code = OESCH_ACT_SCHEDULE
   THEN
      x_line_action := Null;
      RETURN FALSE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N11' , 1 ) ;
   END IF;

   IF (p_line_rec.schedule_action_code is not null)
   THEN
      x_line_action := p_line_rec.schedule_action_code;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SCH ACTION CODE '|| P_LINE_REC.SCHEDULE_ACTION_CODE , 4 ) ;
      END IF;
      RETURN TRUE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N12 AFTER ACTION CHECK' , 1 ) ;
   END IF;
   -------------- Starts already scheduled line part ------

   -- We should avoid calling scheduling when user changes values
   -- of the below attributes on the unscheduled lines. The code
   -- below is valid only for scheduled lines.

  IF p_line_rec.schedule_status_code is NOT NULL THEN

    x_line_action := OESCH_ACT_RESCHEDULE;

      -- Bug 12735226
      IF  p_line_rec.source_type_code =  OE_GLOBALS.G_SOURCE_EXTERNAL
      THEN
        x_line_action := OESCH_ACT_UNSCHEDULE;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'Source type  CHANGED , UNSCHEDULE' , 4 ) ;
        END IF;
        RETURN TRUE;
      END IF;
      -- Bug 12735226

    IF NOT OE_GLOBALS.Equal(p_line_rec.schedule_ship_date,
                            p_old_line_rec.schedule_ship_date)
    THEN
      -- On a scheduled line, if user is clearing schedule_ship_date
      -- treat is as inschedule.
      IF  p_line_rec.schedule_ship_date is null
--      AND p_line_rec.ship_set_id is null
--      AND p_line_rec.arrival_set_id is null
      THEN
         x_line_action := OESCH_ACT_UNSCHEDULE;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SCH_SHIP_DATE CHANGED , RESCHEDULE' , 4 ) ;
      END IF;
      RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.schedule_arrival_date,
                            p_old_line_rec.schedule_arrival_date)
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SCH_ARR_DATE CHANGED , RESCHEDULE' , 4 ) ;
      END IF;
      IF p_line_rec.schedule_arrival_date is null
      AND p_line_rec.ship_set_id is null
      AND p_line_rec.arrival_set_id is null THEN
         x_line_action := OESCH_ACT_UNSCHEDULE;
      END IF;
      RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.ship_from_org_id,
                            p_old_line_rec.ship_from_org_id)
    THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SHIP_FROM_ORG CHANGED , RESCHEDULE' , 4 ) ;
       END IF;
       RETURN TRUE;
    END IF;


    IF NOT OE_GLOBALS.Equal(p_line_rec.ordered_quantity,
                            p_old_line_rec.ordered_quantity)
    THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ORD QTY CHANGED , RESCHEDULE' , 4 ) ;
       END IF;
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.order_quantity_uom,
                            p_old_line_rec.order_quantity_uom)
    THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ORDER QTY UOM CHANGED , RESCHEDULE' , 4 ) ;
       END IF;
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.request_date,
                            p_old_line_rec.request_date)
    THEN
       -- Pack J
       --- Return True only if Request date parameter value is set to 'Yes'
       IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
          l_request_date_flag :=
                    NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_REQUEST_DATE_FLAG'),'Y');
       END IF;

       -- This code has been added to avoid re-scheduling the line when request date is changed
       -- on a scheduled and overridden line. -- 3524314

       IF OE_GLOBALS.Equal(p_line_rec.override_atp_date_code,
                           p_old_line_rec.override_atp_date_code)
       AND nvl(p_line_rec.override_atp_date_code,'N') = 'Y' THEN
          l_request_date_flag := 'N';
       END IF;

       IF l_request_date_flag = 'Y' THEN

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'REQ_DATE CHANGED , RESCHEDULE' , 4 ) ;
          END IF;
          RETURN TRUE;
       END IF;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.shipping_method_code,
                            p_old_line_rec.shipping_method_code)
    THEN
       -- Pack J
       -- Return True if Ship method parameter value set to 'Yes'.
       IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
         l_shipping_method_flag :=
                        NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_SHIP_METHOD_FLAG'),'Y');
       END IF;
       IF l_shipping_method_flag = 'Y' THEN

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SHIPPING_METHOD CHANGED , RESCHEDULE' , 4 ) ;
          END IF;
          RETURN TRUE;
       END IF;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.delivery_lead_time,
                            p_old_line_rec.delivery_lead_time)
    THEN
      BEGIN
        select order_date_type_code
        into l_order_date_type_code
        from oe_order_headers_all
        where header_id =  p_line_rec.header_id;

        IF l_order_date_type_code  = 'ARRIVAL' THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'DEL LEAD TIME CHANGED , RESCHEDULE' , 4 ) ;
           END IF;
           RETURN TRUE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.demand_class_code,
                            p_old_line_rec.demand_class_code)
    THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'DEMAND_CLASS CHANGED , RESCHEDULE' , 4 ) ;
       END IF;
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.ship_to_org_id,
                            p_old_line_rec.ship_to_org_id)
    THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SHIP_TO_ORG CHANGED , RESCHEDULE' , 4 ) ;
       END IF;
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.sold_to_org_id,
                           p_old_line_rec.sold_to_org_id)
    THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SOLD_TO_ORG CHANGED , RESCHEDULE' , 4 ) ;
       END IF;
       RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.inventory_item_id,
                             p_old_line_rec.inventory_item_id)
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INV ITEM ID CHANGED , RESCHEDULE' , 4 ) ;
        END IF;
        RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.ship_set_id,
                             p_old_line_rec.ship_set_id)
       AND p_line_rec.ship_set_id IS NOT NULL
    THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE IS BEING ADDED TO SHIP SET' , 4 ) ;
        END IF;
        RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.arrival_set_id,
                             p_old_line_rec.arrival_set_id)
       AND p_line_rec.arrival_set_id IS NOT NULL
    THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE IS BEING ADDED TO ARRIVAL SET' , 4 ) ;
        END IF;
        RETURN TRUE;
    END IF;

      -- BUG 1282873
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
      IF  NOT OE_GLOBALS.Equal(p_line_rec.override_atp_date_code,
                               p_old_line_rec.override_atp_date_code) THEN
         -- This line was previously scheduled with the Override ATP Flag set
         -- but it is now not set.  Must re-schedule the line
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OVERRIDE ATP UNCHECKED , RESCHEDULE' , 1 ) ;
         END IF;
         Return TRUE;
      END IF;
    END IF;
     -- END 1282873

    -- Changing the source type on a scheduled line.
    -- We should unschedule the line
    IF p_line_rec.source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL AND
       NOT OE_GLOBALS.Equal(p_line_rec.source_type_code,
                            p_old_line_rec.source_type_code)
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SOURCE TYPE MADE EXTERNAL , UNSCHEDULE' , 4 ) ;
        END IF;
        x_line_action := OESCH_ACT_UNSCHEDULE;
        RETURN TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_line_rec.reserved_quantity,
                            p_old_line_rec.reserved_quantity)
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RESERVED QTY CHANGED , RESERVE' , 4 ) ;
        END IF;
        x_line_action := OESCH_ACT_RESERVE;
        RETURN TRUE;
    END IF;

    -- subinventory changes require only the change
    --reservation. If reservation does not exists for the
    --line no action required here.

    -- Do not move this code
    IF  NOT OE_GLOBALS.Equal(p_line_rec.subinventory,
                             p_old_line_rec.subinventory)
    AND p_old_line_rec.reserved_quantity > 0
    THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SUBINVENTORY CHANGED , RESCHEDULE' , 4 ) ;
       END IF;
       x_line_action := OESCH_ACT_RESERVE;
       RETURN TRUE;
    END IF;
    --4653097:Start
    IF  NOT OE_GLOBALS.Equal(p_line_rec.project_id,
                             p_old_line_rec.project_id)
    AND p_old_line_rec.reserved_quantity > 0
    THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'PROJECT CHANGED , RESCHEDULE' , 4 ) ;
       END IF;
       x_line_action := OESCH_ACT_RESERVE;
       RETURN TRUE;
    END IF;

    IF  NOT OE_GLOBALS.Equal(p_line_rec.task_id,
                             p_old_line_rec.task_id)
    AND p_old_line_rec.reserved_quantity > 0
    THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'TASK CHANGED , RESCHEDULE' , 4 ) ;
       END IF;
       x_line_action := OESCH_ACT_RESERVE;
       RETURN TRUE;
    END IF;
    --4653097 :End
  END IF; -- Check for schedule_status_code not NULL.

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'N13' , 1 ) ;
  END IF;
  RETURN FALSE;


EXCEPTION

  WHEN OTHERS THEN
    x_line_action := Null;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Need_Scheduling'
       );
    END IF;

END Need_Scheduling;


/*---------------------------------------------------------------------
Procedure Name : Validate_Line
Description    : Validates a line before scheduling.
                 It will make sure the required attributes are the
                 there on the line.
                 Only standard lines can be scheduled.Service lines
                 return lines cannot be scheduled.
                 IF the profile OE:Schedule Line on Hold is set to 'Y'
                 we will perform scheduling on lines on hold. If it is
                 set to 'N', we will not perform scheduling.
--------------------------------------------------------------------- */
Procedure Validate_Line
(p_line_rec      IN OE_ORDER_PUB.Line_Rec_Type,
 p_old_line_rec  IN OE_ORDER_PUB.Line_Rec_Type,
 p_sch_action    IN VARCHAR2,
 p_caller        IN VARCHAR2 := SCH_EXTERNAL,
x_return_status OUT NOCOPY VARCHAR2)

IS
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_result                 Varchar2(30);
  l_scheduling_level_code  VARCHAR2(30) := NULL;
  l_type_code              VARCHAR2(30);
  l_out_return_status      VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
  l_org_id                 NUMBER;
  l_bill_seq_id            NUMBER;
  l_make_buy               NUMBER;
  l_config_id              NUMBER;
  l_org_code               VARCHAR2(30);
  l_order_date_type_code   VARCHAR2(30) := null; -- Bug-2371760
  l_auth_to_override_atp   VARCHAR2(3) := NULL; -- BUG 1282873
  l_override               NUMBER;  -- BUG 1282873
  l_set_rec                OE_ORDER_CACHE.set_rec_type;
  l_found                  VARCHAR2(1) :='N';  --Bug 2746497
  l_overridden             VARCHAR2(1) :='N';  --Bug 2716220
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

                                   IF l_debug_level  > 0 THEN
                                       oe_debug_pub.add(  '..ENTERING OE_SCHEDULE_UTIL.VALIDATE_LINE :' || P_SCH_ACTION , 1 ) ;
                                   END IF;
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   -- If the quantity on the line is missing or null and if
   -- the user is trying to performing scheduling, it is an error

   IF ((p_old_line_rec.ordered_quantity is null OR
        p_old_line_rec.ordered_quantity = FND_API.G_MISS_NUM) AND
         (p_line_rec.ordered_quantity is null OR
          p_line_rec.ordered_quantity = FND_API.G_MISS_NUM)) THEN

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_MISSING_QUANTITY');
             OE_MSG_PUB.Add;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'E1' , 1 ) ;
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   -- If the quantity on the line is zero(which is different from
   -- missing)  and if the user is trying to performing scheduling,
   -- it is an error

   IF (((p_old_line_rec.ordered_quantity is null OR
         p_old_line_rec.ordered_quantity = FND_API.G_MISS_NUM OR
         p_old_line_rec.ordered_quantity = 0) AND
         p_line_rec.ordered_quantity = 0) AND
         (nvl(p_line_rec.cancelled_flag,'N') = 'N')) THEN

         IF  p_sch_action is not null
         AND p_caller = SCH_INTERNAL  THEN

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_ZERO_QTY');
             OE_MSG_PUB.Add;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'E2' , 1 ) ;
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;


   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE CANCEL CHECK ' || X_RETURN_STATUS , 2 ) ;
   END IF;
   -- If the line is cancelled, scheduling is not allowed.

   IF (p_line_rec.cancelled_flag = 'Y' AND
       p_caller = SCH_INTERNAL) THEN

          IF p_line_rec.schedule_action_code is not null THEN

             -- The line is cancelled. Cannot perform scheduling
             -- on it.

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_LINE_FULLY_CANCELLED');
             OE_MSG_PUB.Add;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'E3' , 1 ) ;
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;
   END IF;

   -- If the line is shipped, scheduling is not allowed.

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE SHIPPIED QTY CHECK ' || X_RETURN_STATUS , 2 ) ;
   END IF;
   IF (p_line_rec.shipped_quantity is not null) AND
        (p_line_rec.shipped_quantity <> FND_API.G_MISS_NUM) THEN

         IF p_sch_action is not null THEN

             -- The line is cancelled. Cannot perform scheduling
             -- on it.

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_LINE_SHIPPED');
             OE_MSG_PUB.Add;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'E4' , 1 ) ;
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;
   END IF;
/* --Commenting for Bug 13082802
IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE FULFILLED QTY CHECK ' || X_RETURN_STATUS , 2 ) ;
   END IF;
--Added for bug 6873122
   IF (p_line_rec.fulfilled_quantity is not null) AND
        (p_line_rec.fulfilled_quantity <> FND_API.G_MISS_NUM) THEN

         IF p_sch_action is not null THEN

             -- The line is Fulfilled. Cannot perform scheduling
             -- on it.

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_LINE_FULFILLED');
             OE_MSG_PUB.Add;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'E4.1' , 1 ) ;
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;
   END IF;
--Added for bug 6873122
--Commenting for Bug 13082802 */
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE RESERVED QTY CHECK ' || X_RETURN_STATUS , 2 ) ;
   END IF;
   -- Check to see if the reserved quantity is changed and is more
   -- than the ordered quantity. This should not be allowed.
   IF NOT OE_GLOBALS.Equal(p_old_line_rec.reserved_quantity,
                             p_line_rec.reserved_quantity)
   THEN
        -- Reserved Quantity has changed
       IF (p_line_rec.ordered_quantity < p_line_rec.reserved_quantity)
       AND OE_GLOBALS.Equal(p_old_line_rec.order_quantity_uom, p_line_rec.order_quantity_uom) --Bug 6335352
       THEN

         FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_MORE_ORD_QTY');
         OE_MSG_PUB.Add;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'E5' , 1 ) ;
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       -- after changing reserved qty, trying to unschedule or unreserve
       -- dose not make sense.
       IF (p_sch_action = OESCH_ACT_UNSCHEDULE OR
           p_sch_action = OESCH_ACT_UNRESERVE) AND
           (p_line_rec.reserved_quantity is not null) THEN

           FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_QTY_CHG_NOT_ALLOWED');
           OE_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'E6' , 1 ) ;
           END IF;
       END IF;
   END IF;

IF NOT OE_GLOBALS.Equal(p_old_line_rec.reserved_quantity2, -- INVCONV
                             p_line_rec.reserved_quantity2)
   THEN
        -- Reserved Quantity2 has changed
       IF (p_line_rec.ordered_quantity2 < p_line_rec.reserved_quantity2)
       THEN

         FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_MORE_ORD_QTY');
         OE_MSG_PUB.Add;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'E5a' , 1 ) ;
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       -- after changing reserved qty, trying to unschedule or unreserve
       -- dose not make sense.
       IF (p_sch_action = OESCH_ACT_UNSCHEDULE OR
           p_sch_action = OESCH_ACT_UNRESERVE) AND
           (p_line_rec.reserved_quantity2 is not null) THEN

           FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_QTY_CHG_NOT_ALLOWED');
           OE_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'E6A' , 1 ) ;
           END IF;
       END IF;
   END IF;



   -- Check to see if the ordered quantity and reserved quantity
   -- both have changed and if the ordered quantity is less than
   -- the reserved quantity. This should not be allowed.

   IF NOT OE_GLOBALS.Equal(p_old_line_rec.ordered_quantity,
                           p_line_rec.ordered_quantity)
   THEN
        -- Ordered Quantity has changed
       IF NOT OE_GLOBALS.Equal(p_old_line_rec.reserved_quantity,
                               p_line_rec.reserved_quantity)
          AND OE_GLOBALS.Equal(p_old_line_rec.order_quantity_uom, p_line_rec.order_quantity_uom) -- Bug 6335352
       THEN
         IF (p_line_rec.ordered_quantity < p_line_rec.reserved_quantity)
         THEN

           FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_MORE_ORD_QTY');
           OE_MSG_PUB.Add;

           x_return_status := FND_API.G_RET_STS_ERROR;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'E7' , 1 ) ;
           END IF;
         END IF;
       END IF;
   END IF;

    IF NOT OE_GLOBALS.Equal(p_old_line_rec.ordered_quantity2, -- INVCONV
                           p_line_rec.ordered_quantity2)
   THEN
        -- Ordered Quantity has changed
       IF NOT OE_GLOBALS.Equal(p_old_line_rec.reserved_quantity2,
                               p_line_rec.reserved_quantity2)
       THEN
         IF (p_line_rec.ordered_quantity2 < p_line_rec.reserved_quantity2)
         THEN

           FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_MORE_ORD_QTY');
           OE_MSG_PUB.Add;

           x_return_status := FND_API.G_RET_STS_ERROR;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'E7A' , 1 ) ;
           END IF;
         END IF;
       END IF;
   END IF;


   -- If the order quantity uom on the line is missing or null
   -- and if the user is trying to performing scheduling,
   -- it is an error

   IF (p_line_rec.order_quantity_uom is null OR
       p_line_rec.order_quantity_uom = FND_API.G_MISS_CHAR) THEN

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_MISSING_UOM');
             OE_MSG_PUB.Add;

             x_return_status := FND_API.G_RET_STS_ERROR;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'E8' , 1 ) ;
             END IF;
   END IF;

   -- If the item on the line is missing or null and if the user
   -- is trying to performing scheduling, it is an error

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CHECKING THE ITEM....' , 1 ) ;
   END IF;

   IF (p_line_rec.inventory_item_id is null OR
       p_line_rec.inventory_item_id = FND_API.G_MISS_NUM) THEN

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_MISSING_ITEM');
             OE_MSG_PUB.Add;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'E9' , 1 ) ;
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   -- If the request_date on the line is missing or null and
   -- if the user is trying to performing scheduling,
   -- it is an error

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CHECKING THE REQUEST DATE....' , 1 ) ;
   END IF;
   IF (p_line_rec.request_date is null OR
          p_line_rec.request_date = FND_API.G_MISS_DATE) THEN

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_MISSING_REQUEST_DATE');
             OE_MSG_PUB.Add;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'E10' , 1 ) ;
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
   -- 3763015
   IF NVL(fnd_profile.value('ONT_BYPASS_ATP'),'N') = 'Y' OR
         Nvl(p_line_rec.bypass_sch_flag, 'N') = 'Y' THEN --- DOO Integration Changes

      -- An item with this profile set  MUST have a warehouse
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CHECKING THAT LINE HAS A WAREHOUSE...' , 1 ) ;
      END IF;
      IF (p_line_rec.ship_from_org_id is null OR
          p_line_rec.ship_from_org_id = FND_API.G_MISS_NUM) THEN
          FND_MESSAGE.SET_NAME('ONT','ONT_SCH_BYPASS_MISS_WSH');
          OE_MSG_PUB.Add;

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ERROR BYPASS' , 1 ) ;
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   END IF;

   -- If the line belongs to a set, you cannot unschedule the line
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CHECKING FOR SET VALIDATIONS....' , 1 ) ;
   END IF;
   IF ((p_line_rec.ship_set_id is not null AND
        p_line_rec.ship_set_id <> FND_API.G_MISS_NUM) OR
       (p_line_rec.arrival_set_id is not null AND
        p_line_rec.arrival_set_id <> FND_API.G_MISS_NUM)) AND
         (p_sch_action = OESCH_ACT_UNDEMAND OR
          p_sch_action = OESCH_ACT_UNSCHEDULE)
          THEN

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_CANNOT_UNSCH_SET');
             OE_MSG_PUB.Add;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'E11' , 1 ) ;
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;


   -- Bug 2434132.
   -- Reducing the qty should be allowed and not increasing the qty.
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CHECKING FOR HOLDS....'||p_sch_action , 1 ) ;
   END IF;
   IF  Oe_Sys_Parameters.Value('ONT_SCHEDULE_LINE_ON_HOLD') = 'N'
   AND (p_sch_action = OESCH_ACT_SCHEDULE OR
        p_sch_action = OESCH_ACT_RESERVE OR
        (p_sch_action = OESCH_ACT_RESCHEDULE AND
         p_line_rec.schedule_status_code is Null) OR
       (p_line_rec.schedule_status_code is not null AND
        Schedule_Attribute_Changed(p_line_rec     => p_line_rec,
                                   p_old_line_rec => p_old_line_rec)) OR
       (p_line_rec.schedule_status_code is not null AND
        p_line_rec.ordered_quantity > p_old_line_rec.ordered_quantity))

   THEN

        -- Since the profile is set to NO, we should not schedule
        -- the line if the line is on hold.

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING CHECK HOLDS' , 1 ) ;
        END IF;

        OE_Holds_PUB.Check_Holds
                 (   p_api_version       => 1.0
                 ,   p_init_msg_list     => FND_API.G_FALSE
                 ,   p_commit            => FND_API.G_FALSE
                 ,   p_validation_level  => FND_API.G_VALID_LEVEL_FULL
                 ,   x_return_status     => l_out_return_status
                 ,   x_msg_count         => l_msg_count
                 ,   x_msg_data          => l_msg_data
                 ,   p_line_id           => p_line_rec.line_id
                 ,   p_header_id           => p_line_rec.header_id
                 ,   p_hold_id           => NULL
                 ,   p_entity_code       => NULL
                 ,   p_entity_id         => NULL
                 ,   x_result_out        => l_result
                 );

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER CALLING CHECK HOLDS: ' || L_OUT_RETURN_STATUS , 1 ) ;
        END IF;


        IF (l_out_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF l_out_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSE
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF (l_result = FND_API.G_TRUE) THEN
            FND_MESSAGE.SET_NAME('ONT','OE_SCH_LINE_ON_HOLD');
            OE_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
   END IF;

   -- Check to see what scheduling level is allowed to be performed
   -- on this line. If the action requested is not allowed for the
   -- scheduling action, error out.

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CHECKING SCHEDULING LEVEL...' , 1 ) ;
   END IF;
   l_scheduling_level_code := Get_Scheduling_Level(p_line_rec.header_id,
                                                   p_line_rec.line_type_id);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_SCHEDULING_LEVEL_CODE : ' || L_SCHEDULING_LEVEL_CODE , 1 ) ;
   END IF;

--BUG 1955004
   -- Checking if transaction type is using a
   --Repair Item Shipping Scheduling Level
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CHECKING IF LINE HAS REPAIR ITEM SHIPPING SCHEDULING LEVEL...' , 1 ) ;
   END IF;

   IF (l_scheduling_level_code = SCH_LEVEL_FOUR
       OR l_scheduling_level_code = SCH_LEVEL_FIVE) THEN

     -- An item with this scheduling level MUST have a warehouse
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CHECKING THAT LINE HAS A WAREHOUSE...' , 1 ) ;
    END IF;
    IF (p_line_rec.ship_from_org_id is null OR
        p_line_rec.ship_from_org_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.SET_NAME('ONT','OE_SCH_INACTIVE_MISS_WSH');
        FND_MESSAGE.SET_TOKEN('LTYPE',
                       nvl(sch_cached_line_type,'0'));
        OE_MSG_PUB.Add;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'E11.1' , 1 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

     -- An item with this schedling level MUST be a Standard
     -- Item, and NOT be a part of an ATO
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CHECKING THAT IT IS A STANDARD ITEM...' , 1 ) ;
     END IF;
     IF (p_line_rec.item_type_code <> 'STANDARD'
         OR p_line_rec.ato_line_id is not null) THEN

        FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_INACTIVE_STD_ONLY');
        FND_MESSAGE.SET_TOKEN('LTYPE',
                       nvl(sch_cached_line_type,'0'));
        OE_MSG_PUB.Add;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'E11.2' , 1 ) ;
        END IF;
        X_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- An item with this scheduling level MUST NOT be part
      -- of ANY set
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CHECKING FOR NO SETS...' , 1 ) ;
      END IF;
      /* Commenting for Standalone project.
      -- We will now allow standard lines into sets.
      IF (p_line_rec.ship_set_id is not null OR
          P_line_rec.arrival_set_id is not null)THEN

        FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_INACTIVE_STD_ONLY');
        FND_MESSAGE.SET_TOKEN('LTYPE',
                       nvl(sch_cached_line_type,'0'));
        OE_MSG_PUB.Add;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'E11.3' , 1 ) ;
        END IF;
        X_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      */
   END IF;
-- END 1955004

   -- 3763015
   IF (l_scheduling_level_code is not null
   AND l_scheduling_level_code <> SCH_LEVEL_THREE)
   OR NVL(fnd_profile.value('ONT_BYPASS_ATP'),'N') = 'Y'
   OR Nvl(p_line_rec.bypass_sch_flag, 'N') = 'Y' THEN -- DOO Integration related.
        IF l_scheduling_level_code = SCH_LEVEL_ONE THEN
           IF p_sch_action = OESCH_ACT_SCHEDULE OR
              p_sch_action = OESCH_ACT_RESERVE OR
             (p_line_rec.schedule_status_code is  null AND
             (p_line_rec.schedule_ship_date is NOT NULL OR
              p_line_rec.schedule_arrival_date is NOT NULL))
            THEN

              FND_MESSAGE.SET_NAME('ONT','OE_SCH_ACTION_NOT_ALLOWED');
              FND_MESSAGE.SET_TOKEN('ACTION',
                       nvl(p_sch_action,OESCH_ACT_SCHEDULE));
              FND_MESSAGE.SET_TOKEN('ORDER_TYPE',
                       nvl(sch_cached_line_type,sch_cached_order_type));
              OE_MSG_PUB.Add;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'E12' , 1 ) ;
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
        ELSE
           IF l_scheduling_level_code = SCH_LEVEL_TWO OR
              -- BUG 1955004
              l_scheduling_level_code = SCH_LEVEL_FIVE
              -- Level Five and Two cannot have Reservations performed
              -- END 1955004
           THEN
           -- 2766876
           IF (NVL(p_line_rec.reserved_quantity,0) > 0
           AND p_sch_action = OESCH_ACT_SCHEDULE)
           OR p_sch_action = OESCH_ACT_RESERVE THEN
              FND_MESSAGE.SET_NAME('ONT','OE_SCH_ACTION_NOT_ALLOWED');
              FND_MESSAGE.SET_TOKEN('ACTION',
                        nvl(p_sch_action,OESCH_ACT_RESERVE));
              FND_MESSAGE.SET_TOKEN('ORDER_TYPE',
                        nvl(sch_cached_line_type,sch_cached_order_type));
              OE_MSG_PUB.Add;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'E13' , 1 ) ;
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
        END IF;
           --BUG 1955004
          -- 3763015
          IF l_scheduling_level_code = SCH_LEVEL_FOUR OR
             l_scheduling_level_code = SCH_LEVEL_FIVE OR
             NVL(fnd_profile.value('ONT_BYPASS_ATP'),'N') = 'Y'  OR
             Nvl(p_line_rec.bypass_sch_flag, 'N') = 'Y'  -- DOO Integration.
          THEN
            IF p_sch_action = OESCH_ACT_ATP_CHECK THEN
            -- levels Four and Five CANNOT have ATP Performed
              FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_ACTION_NOT_ALLOWED');
              FND_MESSAGE.SET_TOKEN('ACTION',
                          (nvl(p_sch_action, OESCH_ACT_ATP_CHECK)));
              FND_MESSAGE.SET_TOKEN('ORDER_TYPE',
                        nvl(sch_cached_line_type,sch_cached_order_type));
              OE_MSG_PUB.Add;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('p_line_rec.bypass_sch_flag: ' ||
                                     Nvl(p_line_rec.bypass_sch_flag, 'N'), 1);
                                              -- Debug during DOO Integration.
                  oe_debug_pub.add(  'E13.1' , 1 ) ;
              END IF;
              X_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END IF;
        --END 1955004
       END IF;
   END IF;

   -- For DOO Integration (Bug 11896152)
   IF Nvl(p_line_rec.bypass_sch_flag, 'N') = 'Y'  AND
                            NOT Oe_Genesis_Util.G_INCOMING_FROM_DOO
   THEN
      DECLARE
        l_explanation VARCHAR2(80);
      BEGIN
        SELECT  meaning INTO l_explanation
        FROM    oe_lookups
        WHERE   lookup_type = 'SCH_FAIL_REASONS'
        AND     lookup_code = 'EXT_SCH_DOO';

        Fnd_Message.Set_Name('ONT', 'OE_SCH_OE_ORDER_FAILED');
        Fnd_Message.Set_Token('EXPLANATION', l_explanation);
        Oe_Msg_Pub.ADD;

        l_explanation := NULL;
      EXCEPTION
        WHEN OTHERS THEN
          IF l_debug_level > 0 THEN
            oe_debug_pub.ADD('E13.2 Exception section....',1);
          END IF;
      END;

     IF l_debug_level > 0 THEN
       Oe_Debug_Pub.Add ( 'E13.2', 1);
     END IF;

     x_return_status := Fnd_Api.G_Ret_Sts_Error;

   END IF;
   -- End: bug 11896152

   IF nvl(p_line_rec.shipping_interfaced_flag,'N') = 'Y'
   AND (((p_sch_action  = OESCH_ACT_RESERVE OR
          p_sch_action  = OESCH_ACT_RESCHEDULE) AND
          p_old_line_rec.reserved_quantity >
          nvl(p_line_rec.reserved_quantity,0) AND
          Get_Pick_Status(p_line_rec.line_id)) OR
         (p_sch_action  = OESCH_ACT_UNRESERVE AND
          Get_Pick_Status(p_line_rec.line_id)))
   THEN  -- 2595661

       -- Reservation qty cannot be reduced when line is
       -- interfaced to wsh. Give a message here tell the user we are
       -- not unreserving. Added code here to fix bug 2038201.

       FND_MESSAGE.SET_NAME('ONT','OE_SCH_UNRSV_NOT_ALLOWED');
       OE_MSG_PUB.Add;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'E14' , 1 ) ;
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;

   END IF;

   -- following 2 checks are only for ato's

   IF p_line_rec.ato_line_id is not null AND
      NOT(p_line_rec.ato_line_id = p_line_rec.line_id AND
          p_line_rec.item_type_code IN ( OE_GLOBALS.G_ITEM_OPTION,
                                         OE_GLOBALS.G_ITEM_STANDARD,
					 OE_GLOBALS.G_ITEM_INCLUDED)) --9775352
   THEN

     IF   OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
   AND  MSC_ATP_GLOBAL.GET_APS_VERSION = 10 THEN

       IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Warehouse Validation is not rqd',1);
       END IF;
     ELSE

      IF p_line_rec.ship_from_org_id is NULL AND
        p_sch_action  = OE_SCHEDULE_UTIL.OESCH_ACT_SCHEDULE
      THEN

       FND_MESSAGE.SET_NAME('ONT','OE_SCH_ATO_WHSE_REQD');
       OE_MSG_PUB.Add;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'E15' , 1 ) ;
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;

      END IF;
     END IF; -- Gop code level
     IF (p_sch_action  = OE_SCHEDULE_UTIL.OESCH_ACT_RESERVE
     OR  p_sch_action  = OE_SCHEDULE_UTIL.OESCH_ACT_UNRESERVE)
     AND p_line_rec.schedule_status_code is null
     THEN

       FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_NO_CONFIG');
       OE_MSG_PUB.Add;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'E16' , 1 ) ;
       END IF;
       -- code fix for 3300528
       -- no need for returning error in this case
       --IF nvl(p_line_rec.ship_model_complete_flag,'N') = 'N' THEN
       --   x_return_status := FND_API.G_RET_STS_ERROR;
       --END IF;
       -- code fix for 3300528
     END IF;
     /* 4171389:  Reservations cannot be placed for config items if order
      * is not booked.
      */
     IF p_sch_action  = OE_SCHEDULE_UTIL.OESCH_ACT_RESERVE
        AND p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG
        AND p_line_rec.booked_flag <> 'Y'
     THEN
        FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
        OE_MSG_PUB.Add;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'E16.0' , 1 );
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   -- code fix for 3300528
   -- a message has to be given when the user tries to reserve PTO models and classes
   ELSIF nvl(p_line_rec.shippable_flag,'N') = 'N'
     AND  ( p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_RESERVE
       OR p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_UNRESERVE)
       AND p_line_rec.schedule_status_code IS NULL
   THEN
     FND_MESSAGE.SET_NAME('ONT','ONT_SCH_NOT_RESERVABLE');
     OE_MSG_PUB.Add;
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'E16.1' , 1 ) ;
     END IF;
     -- code fix for 3300528
   END IF; -- part of ato

   -- Added for 3451987
   IF NVL(FND_PROFILE.VALUE('ONT_SCH_ATO_ITEM_WO_BOM'), 'N') = 'N' THEN
      -- Added this part of validation to fix bug 2051855
      IF p_line_rec.ato_line_id = p_line_rec.line_id
         AND p_line_rec.item_type_code in ('STANDARD','OPTION','INCLUDED') --9775352
         AND  fnd_profile.value('INV_CTP') = '5'THEN

         l_org_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');

         -- Added code to fix bug 2156268
         BEGIN

            SELECT planning_make_buy_code
            INTO   l_make_buy
            FROM   mtl_system_items
            WHERE  inventory_item_id = p_line_rec.inventory_item_id
            AND    ORGANIZATION_ID = nvl(p_line_rec.ship_from_org_id,
                                            l_org_id);

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_make_buy := 1;
         END;

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'L_MAKE_BUY' || L_MAKE_BUY , 2 );
         END IF;

         IF nvl(l_make_buy,1) <> 2 THEN
            BEGIN
               -- Modified code to fix bug 2307501.
               SELECT BILL_SEQUENCE_ID
               INTO   l_bill_seq_id
               FROM   BOM_BILL_OF_MATERIALS
               WHERE  ORGANIZATION_ID = nvl(p_line_rec.ship_from_org_id,
                                            l_org_id)
               AND    ASSEMBLY_ITEM_ID = p_line_rec.inventory_item_id
               AND    ALTERNATE_BOM_DESIGNATOR IS NULL;

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'NO BILL IS DEFINED' , 2 ) ;
                  END IF;
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'E17' , 1 ) ;
                  END IF;
                  FND_MESSAGE.SET_NAME('ONT','OE_BOM_NO_BILL_IN_SHP_ORG');
                  FND_MESSAGE.SET_TOKEN('ITEM',p_line_rec.ordered_item);

                  -- Bug 2367743  Start
                  Select ORGANIZATION_CODE
                  Into   l_org_code
                  From   Inv_Organization_Info_v   --ORG_ORGANIZATION_DEFINITIONS
                  Where  ORGANIZATION_ID = NVL(p_line_rec.ship_from_org_id,l_org_id);
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'ORGANIZATION CODE:'||L_ORG_CODE , 2 ) ;
                  END IF;
                  FND_MESSAGE.SET_TOKEN('ORG',l_org_code);
                  -- Bug 2367743 End

                  OE_MSG_PUB.Add;
                  x_return_status := FND_API.G_RET_STS_ERROR;

               WHEN OTHERS THEN
                  Null;
            END;
         END IF;
      END IF;
   END IF; -- ONT_SCH_ATO_ITEM_WO_BOM = 'N'

/* Duplicate validation to E14. Bug 2312341
   IF  nvl(p_line_rec.shipping_interfaced_flag, 'N') = 'Y'
   AND (p_sch_action = OESCH_ACT_RESERVE
   OR   p_sch_action = OESCH_ACT_RESCHEDULE)
   AND p_old_line_rec.reserved_quantity >
       p_line_rec.reserved_quantity
   THEN

      -- Added code here to fix bug 2038201.
      oe_debug_pub.add('E18',1);
      FND_MESSAGE.SET_NAME('ONT','OE_SCH_UNRSV_NOT_ALLOWED');
      OE_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

   END IF;
*/
   IF (p_sch_action = OESCH_ACT_UNSCHEDULE)
   AND (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
        p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
        p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
        p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_INCLUDED)
   AND  NOT(OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
   AND  MSC_ATP_GLOBAL.GET_APS_VERSION = 10 )

   THEN
     -- This action is not allowed on an ATO configuration if the config
     -- item is created.

     BEGIN
        SELECT line_Id
        INTO   l_config_id
        FROM   OE_ORDER_LINES_ALL
        WHERE  header_id = p_line_rec.header_id
        AND   (ato_line_id =p_line_rec.ato_line_id OR
              (top_model_line_id = p_line_rec.top_model_line_id AND
               Ship_model_complete_flag = 'Y'))
        AND    item_type_code = 'CONFIG';

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'E19' , 1 ) ;
      END IF;
      FND_MESSAGE.SET_NAME('ONT','OE_SCH_UNSCH_CONFIG_EXISTS');
      OE_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             null;
        WHEN TOO_MANY_ROWS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'E19 TOO MANY ROWS' , 1 ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT','OE_SCH_UNSCH_CONFIG_EXISTS');
          OE_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;

     END;

   END IF; /* If action was unschedule */

 -- Start Bug-2371760
 -- Change in Schedule Ship/Arrival Date is not allowed
 -- when Order Date Type is specified.
/*
 OE_DEBUG_PUB.Add('Checking for Order date Type - Arrival');

 IF NOT OE_GLOBALS.Equal(p_line_rec.schedule_ship_date,
                            p_old_line_rec.schedule_ship_date)
    THEN
       -- If the Order Type is ARRIVAL, the user is not
       -- allowed to change the schedule ship date

       l_order_date_type_code    := Get_Date_Type(p_line_rec.header_id);

       IF nvl(l_order_date_type_code,'SHIP') = 'ARRIVAL' THEN

          FND_MESSAGE.SET_NAME('ONT','OE_SCH_INV_SHP_DATE');
          OE_MSG_PUB.Add;

          OE_DEBUG_PUB.Add('E20 Order date Type - Arrival');
          x_return_status := FND_API.G_RET_STS_ERROR;

       END IF;


    END IF;

   OE_DEBUG_PUB.Add('Checking for Order date Type - Ship');

    IF NOT OE_GLOBALS.Equal(p_line_rec.schedule_arrival_date,
                            p_old_line_rec.schedule_arrival_date)
    THEN

       -- If the Order Type is SHIP (or null), the user is not
       -- allowed to change the schedule arrival date

       l_order_date_type_code    := Get_Date_Type(p_line_rec.header_id);

       IF nvl(l_order_date_type_code,'SHIP') = 'SHIP' THEN

          FND_MESSAGE.SET_NAME('ONT','OE_SCH_INV_ARR_DATE');
          OE_MSG_PUB.Add;

          OE_DEBUG_PUB.Add('E21 Order date Type - Ship');

          x_return_status := FND_API.G_RET_STS_ERROR;

       END IF;
   END IF;

 -- End Bug-2371760
 */
   -- BUG 1282873
   IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
     l_auth_to_override_atp :=
         NVL(FND_PROFILE.VALUE('ONT_OVERRIDE_ATP'), 'N');

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ONT_OVERRIDE_ATP' || L_AUTH_TO_OVERRIDE_ATP , 3 ) ;
    END IF;
    IF l_auth_to_override_atp = 'N' THEN

       IF  NOT OE_GLOBALS.Equal(p_line_rec.override_atp_date_code,
                                p_old_line_rec.override_atp_date_code)
       THEN

          -- only authorized users have authority to update the
          -- Overide ATP Field
          FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_OVER_ATP_NO_AUTH');
          OE_MSG_PUB.Add;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'E22 INVALID AUTOTIZE' ) ;
          END IF;
                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'USER DOES NOT HAVE AUTHORITY TO CHANGE THE OVERRIDE ATP FIELD' , 1 ) ;
                            END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;

       END IF;


       IF p_line_rec.schedule_status_code IS NOT NULL THEN

          IF NVL(p_line_rec.override_atp_date_code, 'N') = 'Y' AND
             (Schedule_Attribute_Changed(p_line_rec => p_line_rec
                                        ,p_old_line_rec => p_old_line_rec) OR
          NVL(p_line_rec.ordered_quantity, 0) > p_old_line_rec.ordered_quantity)

          THEN

           -- only authorized users have authority to update scheduling attributes
           -- on an overridden line
             FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_OVER_ATP_NO_AUTH_MOD');
             OE_MSG_PUB.Add;
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'E23 USER DOES NOT HAVE AUTHORITY TO UPDATE SCHEDULE ATTRIBUTES' , 1 ) ;
                  END IF;
             X_return_status := FND_API.G_RET_STS_ERROR;

          END IF;

          IF NVL(p_line_rec.override_atp_date_code, 'N') = 'Y' AND
             (p_sch_action = OESCH_ACT_UNDEMAND OR
              P_sch_action = OESCH_ACT_UNSCHEDULE) THEN
             -- Only Authorized users have authority to unschedule an overriddenline
             FND_MESSAGE.SET_NAME('ONT','OE_SCH_OVER_ATP_NO_AUTH_UNCHK');
             OE_MSG_PUB.Add;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'E24 GENERAL USER CANNOT UNSCHEDULE AN OVERRIDDEN LINE' , 1 ) ;
             END IF;
             X_return_status := FND_API.G_RET_STS_ERROR;

          END IF;
          -- Start 2746497
          IF NVL(p_line_rec.override_atp_date_code, 'N') = 'N' AND
             NVL(p_line_rec.ship_model_complete_flag,'N') = 'Y' AND
             (Schedule_Attribute_Changed(p_line_rec => p_line_rec
                                       ,p_old_line_rec => p_old_line_rec) OR
             NVL(p_line_rec.ordered_quantity, 0) > p_old_line_rec.ordered_quantity)
          THEN
               BEGIN
                      SELECT  'Y' INTO l_found
                      FROM   oe_order_lines
                      WHERE  top_model_line_id = p_line_rec.top_model_line_id
                      AND override_atp_date_code = 'Y'
                      AND rownum <2;
               EXCEPTION
                   WHEN OTHERS THEN
                        NULL;
               END;
               IF l_found = 'Y' THEN
                  FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_OVER_ATP_NO_AUTH_MOD');
                  OE_MSG_PUB.Add;
                  X_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
          END IF;
          -- End 2746497


          IF (p_line_rec.ship_set_id IS NOT NULL OR
             p_line_rec.arrival_set_id IS NOT NULL) AND
             (Schedule_Attribute_Changed(p_line_rec => p_line_rec
                                       ,p_old_line_rec => p_old_line_rec) OR
             NVL(p_line_rec.ordered_quantity, 0) > p_old_line_rec.ordered_quantity)
          THEN

             l_override := 0;


             SELECT count('x')
             INTO   l_override
             FROM   oe_order_lines_all
             WHERE  header_id = p_line_rec.header_id
             AND    (ship_set_id = p_line_rec.ship_set_id
             OR     arrival_set_id = p_line_rec.arrival_set_id)
             AND    override_atp_date_code = 'Y';

             IF l_override > 0 THEN

               -- only authorized users have authority to update scheduling
               -- attributes in a set with an overridden line
               FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_OVER_ATP_NO_AUTH_SET');
               OE_MSG_PUB.Add;
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'E25 USER DOES NOT HAVE AUTHORITY TO UPDATE SCHEDULE ATTRIBUTES ON A SET WITH AN OVERRIDDEN LINE' , 1 ) ;
               END IF;
               X_return_status := FND_API.G_RET_STS_ERROR;

             END IF; -- l_override > 0
          END IF; -- ship and arrival not null
       END IF;  -- schedule_status_code IS NOT NULL
    END IF; -- overide_atp = N

    IF ((p_line_rec.ship_set_id IS NOT NULL AND
        NOT oe_globals.equal(p_line_rec.ship_set_id,
                             p_old_line_rec.ship_set_id))  OR
       (p_line_rec.arrival_set_id IS NOT NULL AND
        NOT oe_globals.equal(p_line_rec.arrival_set_id,
                            p_old_line_rec.arrival_set_id))) THEN

       l_set_rec := OE_ORDER_CACHE.Load_Set
                  (nvl(p_line_rec.arrival_set_id,p_line_rec.ship_set_id));
       IF NVL(p_line_rec.override_atp_date_code, 'N') = 'Y' THEN

        IF  l_set_rec.ship_from_org_id is not null
        AND NOT Set_Attr_Matched
           (p_set_ship_from_org_id      => l_set_rec.ship_from_org_id ,
            p_line_ship_from_org_id     => p_line_rec.ship_from_org_id,
            p_set_ship_to_org_id        => l_set_rec.ship_to_org_id ,
            p_line_ship_to_org_id       => p_line_rec.ship_to_org_id ,
            p_set_schedule_ship_date    => l_set_rec.schedule_ship_date ,
            p_line_schedule_ship_date   => p_line_rec.schedule_ship_date,
            p_set_arrival_date          => l_set_rec.schedule_arrival_date,
            p_line_arrival_date         => p_line_rec.schedule_arrival_date,
            p_set_shipping_method_code  => l_set_rec.shipping_method_code ,
            p_line_shipping_method_code => p_line_rec.shipping_method_code,
            p_set_type                  => l_set_rec.set_type) THEN

          -- General users can only add new lines to the set provided the new
          -- lines can be scheduled for the schedule ship date of the set AND
          -- Authorized users cannot add an overridden line if the schedule
          -- ship date soes not match the set

          FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_OVER_ATP_NO_AUTH_SET');
          OE_MSG_PUB.Add;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'E26 UNABLE TO ADD THE LINE TO THE SET' , 1 ) ;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;

        -- 2716220
        ELSIF p_line_rec.ship_set_id is not null
--          AND p_line_rec.schedule_status_code is not null THEN
        THEN
           BEGIN
              SELECT 'Y'
              INTO   l_overridden
              FROM   oe_order_lines_all
              WHERE  header_id = p_line_rec.header_id
              AND    line_id <> p_line_rec.line_id
              AND    ship_set_id = p_line_rec.ship_set_id
              AND    override_atp_date_code = 'Y'
              AND    schedule_ship_date <> p_line_rec.schedule_ship_date
              AND    rownum < 2;
           EXCEPTION
              WHEN OTHERS THEN
                 NULL;
           END;
        ELSIF p_line_rec.arrival_set_id is not null
 --         AND p_line_rec.schedule_status_code is not null THEN
        THEN
           BEGIN
              SELECT 'Y'
              INTO   l_overridden
              FROM   oe_order_lines_all
              WHERE  header_id = p_line_rec.header_id
              AND    line_id <> p_line_rec.line_id
              AND    arrival_set_id = p_line_rec.arrival_set_id
              AND    override_atp_date_code = 'Y'
              AND    schedule_arrival_date <> p_line_rec.schedule_arrival_date
              AND    rownum < 2;
           EXCEPTION
              WHEN OTHERS THEN
                 NULL;
           END;

        END IF; -- ship from
        IF l_overridden = 'Y' THEN
        --3517527 set_status check commented
        --  IF l_set_rec.set_status <> 'T' THEN
           FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_OVER_ATP_NO_AUTH_SET');
           OE_MSG_PUB.Add;
        --  END IF;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'E27 UNABLE TO ADD THE line TO THE SET' , 1 ) ;
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

       END IF; -- override

        -- If a non smc model or kit has lines that are overridden for
        -- different dates, stop adding the model to set.

       IF p_line_rec.top_model_line_id = p_line_rec.line_id
       AND nvl(p_line_rec.ship_model_complete_flag,'N') = 'N'
       AND p_line_rec.ato_line_id is null THEN

          IF NOT Valid_Set_Addition
             (p_top_model_line_id  => p_line_rec.top_model_line_id,
              p_set_type           => l_set_rec.set_type) THEN

           FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_OVER_ATP_NO_AUTH_SET');
           OE_MSG_PUB.Add;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'E28 UNABLE TO ADD THE Model TO THE SET' , 1 ) ;
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;

          END IF; -- valid
       END IF; -- top model
    END IF; -- ship set.

  END IF; -- pack I check
  --END 1282873
  -- Pack J
  -- Honoring Latest Acceptable Date
  -- 3940632 : Dates truncated prior to comparison.
  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

      l_order_date_type_code := NVL(Get_Date_Type(p_line_rec.header_id), 'SHIP');
      IF  (p_sch_action = OESCH_ACT_SCHEDULE
          OR (p_sch_action = OESCH_ACT_RESERVE
             AND p_line_rec.schedule_status_code IS NULL)
          OR p_sch_action = OESCH_ACT_RESCHEDULE)
         AND OE_SYS_PARAMETERS.value ('LATEST_ACCEPTABLE_DATE_FLAG') = 'H'
         AND NVL(p_line_rec.override_atp_date_code, 'N') = 'N'

 --Bug 6400995
         --Honoring of LAD should be done only when updating/creating lines and not while cancelling
         AND nvl(p_line_rec.cancelled_flag,'N') = 'N'

     THEN

         IF trunc(NVL(p_line_rec.latest_acceptable_date,p_line_rec.request_date))
                                                       < trunc(p_line_rec.request_date) THEN
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add ('E29 Request date exceeds Latest Acceptable Date',1);
            END IF;
            FND_MESSAGE.SET_NAME('ONT','ONT_SCH_REQUEST_EXCEED_LAD');
            OE_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         ELSIF ((l_order_date_type_code = 'SHIP'
            AND trunc(NVL(p_line_rec.schedule_ship_date,p_line_rec.request_date))
                           >  trunc(NVL(p_line_rec.latest_acceptable_date,p_line_rec.request_date)))
          OR (l_order_date_type_code = 'ARRIVAL'
            AND trunc(NVL(p_line_rec.schedule_arrival_date, p_line_rec.request_date))
                          >  trunc(NVL(p_line_rec.latest_acceptable_date,p_line_rec.request_date)))) THEN
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('E30 Schedule date exceeds Latest Acceptable Date',1);
           END IF;
           FND_MESSAGE.SET_NAME('ONT','ONT_SCH_LAD_SCH_FAILED');
           OE_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
         -- 3894212
         IF ((p_line_rec.ship_set_id IS NOT NULL AND
           NOT oe_globals.equal(p_line_rec.ship_set_id,
                             p_old_line_rec.ship_set_id))  OR
            (p_line_rec.arrival_set_id IS NOT NULL AND
           NOT oe_globals.equal(p_line_rec.arrival_set_id,
                            p_old_line_rec.arrival_set_id))) THEN

            l_set_rec := OE_ORDER_CACHE.Load_Set
                  (nvl(p_line_rec.arrival_set_id,p_line_rec.ship_set_id));

            IF ((l_order_date_type_code = 'SHIP'
               AND trunc(l_set_rec.schedule_ship_date)
                           >  trunc(NVL(p_line_rec.latest_acceptable_date,p_line_rec.request_date)))
               OR (l_order_date_type_code = 'ARRIVAL'
               AND trunc(l_set_rec.schedule_arrival_date)
                          >  trunc(NVL(p_line_rec.latest_acceptable_date,p_line_rec.request_date))))
               AND l_set_rec.schedule_arrival_date IS NOT NULL
               AND l_set_rec.schedule_ship_date IS NOT NULL THEN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('E30.1 Schedule date exceeds Latest Acceptable Date',1);
               END IF;
               FND_MESSAGE.SET_NAME('ONT','ONT_SCH_LAD_SCH_FAILED');
               OE_MSG_PUB.Add;
               x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
         END IF;
         --
      END IF;
   END IF;
 -- End Pack J
    -- 3288838 --
    -- 3361753 subinventory check added
   l_found := 'N';
   --4653097
   IF nvl(p_line_rec.shipping_interfaced_flag,'N') = 'Y'
    AND p_sch_action = OESCH_ACT_RESERVE
    AND OE_GLOBALS.Equal(p_old_line_rec.subinventory,
                         p_line_rec.subinventory)
    AND OE_GLOBALS.Equal(p_old_line_rec.project_id,
                         p_line_rec.project_id)
    AND OE_GLOBALS.Equal(p_old_line_rec.task_id,
                         p_line_rec.task_id) THEN
      BEGIN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('Before checking for Staged/Closed deliveries', 1);
         END IF;

         SELECT 'Y'
         INTO   l_found
         FROM   WSH_DELIVERY_DETAILS
         WHERE  SOURCE_LINE_ID = p_line_rec.line_id
         AND    SOURCE_CODE = 'OE'
         AND    RELEASED_STATUS IN ('Y', 'C');

         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('Staged/Closed deliveries exist for the line', 3);
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         WHEN TOO_MANY_ROWS THEN
            l_found :='Y';
      END;
      IF l_found = 'Y' THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('E31 Reservation(s) cannot be created.  The line has been pick confirmed/staged',1);
         END IF;
         FND_MESSAGE.SET_NAME('ONT','ONT_SCH_RSV_FAILURE_STAGED');
         OE_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  '..EXITING OE_SCHEDULE_UTIL.VALIDATE_LINE WITH ' || X_RETURN_STATUS , 1 ) ;
  END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Validate_Line');
        END IF;
END Validate_Line;
/*---------------------------------------------------------------------
Procedure Name : Process_Request
Description    : This procedure is called from the Schedule_Line procedure
                 to schedule a SINGLE LINE (a set or a parent line  is scheduled
                 in different procedure). The single line could be a part
                 of the set which is getting scheduled independently
                 (because there was not change in the set related attribute),
                 or it could be just a simple standard line which does not
                 belong to any set.

--------------------------------------------------------------------- */
Procedure Process_request(p_old_line_rec  IN OE_ORDER_PUB.line_rec_type,
                          p_x_line_rec    IN OUT NOCOPY OE_ORDER_PUB.line_rec_type,
                          p_caller        IN VARCHAR2,
                          p_sch_action    IN VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2)

IS
l_update_flag    VARCHAR2(1):= FND_API.G_TRUE;
l_orig_line_rec  OE_ORDER_PUB.line_rec_type;
l_reserve_later  VARCHAR2(1) := 'N';
l_qty_to_reserve NUMBER;
l_qty2_to_reserve NUMBER; -- INVCONV
--Bug 12641867
l_shipping_interfaced_flag VARCHAR2(1);
l_firm_demand_flag   VARCHAR2(1);
l_lock_control   NUMBER;
--End Bug 12641867

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS; --Bug 5343902
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_SCHEDULE_UTIL.PROCESS_REQUEST' , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OESCH_AUTO_SCH_FLAG : ' || OESCH_AUTO_SCH_FLAG , 1 ) ;
  END IF;

-- need to retain orig record to call process order.

  l_orig_line_rec := p_x_line_rec;
  x_return_status   := FND_API.G_RET_STS_SUCCESS;

  IF p_sch_action  = OESCH_ACT_SCHEDULE THEN

    -- Based on the p_sch_action  and schedule_status_code call action_schedule.

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NEW' || P_X_LINE_REC.SCHEDULE_SHIP_DATE ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OLD' || P_OLD_LINE_REC.SCHEDULE_SHIP_DATE ) ;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OLD AD ' || P_OLD_LINE_REC.SCHEDULE_ARRIVAL_DATE , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NEW AD ' || P_OLD_LINE_REC.SCHEDULE_ARRIVAL_DATE , 1 ) ;
     END IF;

     /* Added code for bug 5343902 */
    IF nvl(p_x_line_rec.model_remnant_flag, 'N')  = 'Y' AND
       p_x_line_rec.item_type_code in ('KIT', 'CLASS','MODEL')  AND
       p_x_line_rec.explosion_date IS NULL
    THEN
      oe_debug_pub.add('Remnant ' || p_x_line_rec.item_type_code || ', Calling Process_Included_Items', 5);

      l_return_status := OE_CONFIG_UTIL.Process_Included_Items
                         (p_line_id   => p_x_line_rec.line_id,
                          p_freeze    => FALSE);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

       oe_debug_pub.add('After calling Process_Included_Items', 5);
    END IF;
    /* End of code changes for bug 5343902 */

     Action_Schedule(p_x_line_rec     => p_x_line_rec,
                     p_old_line_rec   => p_old_line_rec,
                     p_sch_action     => OESCH_ACT_SCHEDULE,
                     p_qty_to_reserve => p_x_line_rec.reserved_quantity,
                     x_return_status  => x_return_status);

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER ACTION SCHEDULE : ' || X_RETURN_STATUS , 1 ) ;
     END IF;

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN

/* Added two extra conditions in the following if condition to fix the Bug 2894100 */

         IF  OESCH_AUTO_SCH_FLAG = 'Y'
         AND p_x_line_rec.schedule_ship_date is null
         AND p_x_line_rec.schedule_arrival_date is null
         -- QUOTING changes - check for complete negotiation also
         -- as it can trigger auto-scheduling
         AND (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
              OR OE_Quote_Util.G_COMPLETE_NEG = 'Y'
             )
         THEN
         -- We donot want to error out the insert if autoscheduling
         -- failed. So we will return success. We also do not want to
         -- do any update, so we will set the l_update_flag to FALSE.

            l_update_flag     := FND_API.G_FALSE;
            x_return_status   := FND_API.G_RET_STS_SUCCESS;

         ELSE

            RAISE FND_API.G_EXC_ERROR;

         END IF;
     END IF;

  ELSIF p_sch_action  = OESCH_ACT_RESCHEDULE THEN

IF NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,
                            p_old_line_rec.inventory_item_id)
     AND p_x_line_rec.source_type_code = 'EXTERNAL' THEN -- 7139462

        p_x_line_rec.schedule_action_code := OESCH_ACT_UNSCHEDULE;

        Action_UnSchedule(p_x_line_rec    => p_x_line_rec,
                        p_old_line_rec  => p_old_line_rec,
                        p_sch_action    => OESCH_ACT_UNSCHEDULE,
                        x_return_status => x_return_status);
        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
 ELSE
       Action_Reschedule(p_x_line_rec    => p_x_line_rec,
                         p_old_line_rec  => p_old_line_rec,
                         x_return_status => x_return_status,
                         x_reserve_later => l_reserve_later);

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
END IF;

  ELSIF p_sch_action  = OESCH_ACT_RESERVE THEN

     -- If some one has passes action as reserve on a
     -- unscheduled line
     IF p_x_line_rec.schedule_status_code IS NULL THEN

        Action_Schedule(p_x_line_rec     => p_x_line_rec,
                        p_old_line_rec   => p_old_line_rec,
                        p_sch_action     => OESCH_ACT_RESERVE,
                        p_qty_to_reserve => p_x_line_rec.reserved_quantity,
                        x_return_status  => x_return_status);

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

     ELSE

        Action_reserve(p_x_line_rec    => p_x_line_rec,
                       p_old_line_rec  => p_old_line_rec,
                       x_return_status => x_return_status);

        l_update_flag := FND_API.G_FALSE;

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;


     END IF;


  ELSIF p_sch_action   = OESCH_ACT_UNRESERVE
  THEN

    -- Setting update flag to false, so that schedule_line does not
    -- process_order as unreserving does not cause any line attributes
    -- to change.

    l_update_flag := FND_API.G_FALSE;

    -- We should never use this action unless the
    -- old_status is reserved .

     IF (p_old_line_rec.reserved_quantity is not null AND
         p_old_line_rec.reserved_quantity <> FND_API.G_MISS_NUM)
     THEN
    -- shipping_interfaced_flag
       Unreserve_Line
        (p_line_rec              => p_old_line_rec,
         p_quantity_to_unreserve => p_old_line_rec.reserved_quantity,
         p_quantity2_to_unreserve => p_old_line_rec.reserved_quantity2, -- INVCONV
         x_return_status         => x_return_status);

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

     ELSE
       FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
       OE_MSG_PUB.Add;
       l_update_flag := FND_API.G_FALSE;
     END IF;


  -- schedule_action_code -->  OESCH_ACT_UNDEMAND

  ELSIF p_sch_action  = OESCH_ACT_UNDEMAND
  THEN
     IF p_x_line_rec.Schedule_status_code IS NOT NULL THEN

        Action_UnSchedule(p_x_line_rec    => p_x_line_rec,
                          p_old_line_rec  => p_old_line_rec,
                          p_sch_action    => OESCH_ACT_UNDEMAND,
                          x_return_status => x_return_status);

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

     ELSE
       FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
       OE_MSG_PUB.Add;
       l_update_flag := FND_API.G_FALSE;
     END IF;

  ELSIF p_sch_action  = OESCH_ACT_UNSCHEDULE THEN
     -- When action is passed as unschedule.
     -- Or if the line's source type is being changed from INTERNAL to
     -- EXTERNAL, and the old line was scheduled, we need to unschedule it.

      p_x_line_rec.schedule_action_code := OESCH_ACT_UNSCHEDULE;
      Action_UnSchedule(p_x_line_rec    => p_x_line_rec,
                        p_old_line_rec  => p_old_line_rec,
                        p_sch_action    => OESCH_ACT_UNSCHEDULE,
                        x_return_status => x_return_status);

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

  END IF; -- Main If.

  IF l_update_flag = FND_API.G_TRUE
  THEN
/*
     Call_Process_Order(p_old_line_rec    => p_old_line_rec,
                        p_x_line_rec      => p_x_line_rec,
                        p_write_to_db     => p_write_to_db,
                        p_caller          => p_caller,
                        x_return_status   => x_return_status);
*/

     --Bug 12641867
     IF p_x_line_rec.ato_line_id IS NOT NULL
      AND p_x_line_rec.item_type_code = 'STANDARD'
      AND nvl(p_x_line_rec.booked_flag, 'N') = 'Y'
      AND p_sch_action  IN (OESCH_ACT_RESCHEDULE,OESCH_ACT_RESERVE) THEN

        SELECT shipping_interfaced_flag,firm_demand_flag,lock_control
        INTO l_shipping_interfaced_flag,l_firm_demand_flag,l_lock_control
        FROM OE_ORDER_LINES_ALL
        WHERE LINE_ID=p_x_line_rec.line_id;

        p_x_line_rec.shipping_interfaced_flag := l_shipping_interfaced_flag;
        p_x_line_rec.firm_demand_flag := l_firm_demand_flag;
        p_x_line_rec.lock_control := l_lock_control;

     END IF;
     --End Bug 12641867

     Process_Line (p_old_line_rec    => l_orig_line_rec,
                   p_x_line_rec      => p_x_line_rec,
                   p_caller          => p_caller,
                   x_return_status   => x_return_status);

                                        IF l_debug_level  > 0 THEN
                                            oe_debug_pub.add(  'AFTER CALLING CALL_PROCESS_ORDER :' || X_RETURN_STATUS , 1 ) ;
                                        END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_reserve_later = 'Y' THEN
                                 IF l_debug_level  > 0 THEN
                                     oe_debug_pub.add(  'RESERVE THE NEW ITEM: ' || P_X_LINE_REC.INVENTORY_ITEM_ID , 1 ) ;
                                 END IF;
        IF p_x_line_rec.shippable_flag = 'Y' THEN


          IF (nvl(p_x_line_rec.reserved_quantity,0) >
                 p_x_line_rec.ordered_quantity)
          OR nvl(p_x_line_rec.reserved_quantity,0) = 0
          THEN
             l_qty_to_reserve := p_x_line_rec.ordered_quantity;
          ELSE
             l_qty_to_reserve := p_x_line_rec.reserved_quantity;
          END IF;

                    IF (nvl(p_x_line_rec.reserved_quantity2,0) >   -- INVCONV
                 nvl(p_x_line_rec.ordered_quantity2,0) )
          OR nvl(p_x_line_rec.reserved_quantity2,0) = 0
          THEN
             l_qty2_to_reserve := p_x_line_rec.ordered_quantity2;
          ELSE
             l_qty2_to_reserve := p_x_line_rec.reserved_quantity2;
          END IF;

          IF l_qty2_to_reserve = 0 THEN -- INVCONV
                l_qty2_to_reserve := null;
          end if;

          IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'QTY TO RESERVE ' || L_QTY_TO_RESERVE , 2 ) ;
                     oe_debug_pub.add(  'QTY2 TO RESERVE ' || L_QTY2_TO_RESERVE , 2 ) ;
       END IF;


          Reserve_Line
          ( p_line_rec             => p_x_line_rec
          , p_quantity_to_reserve  => l_qty_to_reserve
          , p_quantity2_to_reserve  => l_qty2_to_reserve -- INVCONV
          , x_return_Status        => x_return_status);


        END IF; -- Shippable flag
      END IF; -- reserve later

  END IF; -- update flag

  -- If schedule date has change, we need to call PO callback function
  -- to indicate the change.

  -- IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND --3888871
  IF p_x_line_rec.source_document_type_id = 10 AND --3888871
     NOT OE_GLOBALS.EQUAL(p_x_line_rec.schedule_arrival_date,
                          p_old_line_rec.schedule_arrival_date)
  THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PASSING SCHEDULE_ARRIVAL_DATE TO PO ' , 3 ) ;
     END IF;
     Update_PO(p_x_line_rec.schedule_arrival_date,
               p_x_line_rec.source_document_id,
               p_x_line_rec.source_document_line_id);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER PO CALL BACK' , 3 ) ;
     END IF;
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'EXITING OE_SCHEDULE_UTIL.PROCESS_REQUEST: ' || X_RETURN_STATUS , 1 ) ;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Process_request'
       );
    END IF;

END Process_request;

/*-----------------------------------------------------------------------------
Procedure Name : Get_Lead_Time
Description    : This function returns the manufacturing lead team for ATO
                 Options and Classes. While performing ATP, and scheduling
                 for an ATO configuration, we just don't have to check
the availability of the items, we also need to find out nocopy

                 the amount of time it takes to build those items.
                 This procedure gives the time it takes to build the ATO.
                 It is standard formula which is used. The value is derived
                 from the ATO model. Thus all options for a given model
                 will have the same Lead Time.
----------------------------------------------------------------------------- */
FUNCTION Get_Lead_Time
( p_ato_line_id      IN NUMBER
, p_ship_from_org_id IN NUMBER)
RETURN NUMBER
IS
l_model_ordered_quantity  NUMBER := 0;
l_model_order_qty_uom     NUMBER := 0;
primary_model_qty         NUMBER := 0;
st_lead_time              NUMBER := 0;
db_full_lead_time         NUMBER := 0;
db_fixed_lead_time        NUMBER := 0;
db_variable_lead_time     NUMBER := 0;
db_primary_uom_code       VARCHAR2(3);
db_model_item_id          NUMBER := 0;
db_line_unit_code         VARCHAR2(3);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_LEAD_TIME' , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ATO LINE IS ' || P_ATO_LINE_ID , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SHIP FROM IS ' || P_SHIP_FROM_ORG_ID , 1 ) ;
  END IF;

  SELECT     NVL ( MSI.FULL_LEAD_TIME , 0 )
             , NVL ( MSI.FIXED_LEAD_TIME , 0 )
             , NVL ( MSI.VARIABLE_LEAD_TIME , 0 )
             , MSI.PRIMARY_UOM_CODE
             , NVL ( OL.INVENTORY_ITEM_ID , 0 )
             , OL.order_quantity_uom
             , OL.ordered_quantity
  INTO       db_full_lead_time
             , db_fixed_lead_time
             , db_variable_lead_time
             , db_primary_uom_code
             , db_model_item_id
             , db_line_unit_code
             , primary_model_qty
  FROM    MTL_SYSTEM_ITEMS MSI
          , OE_ORDER_LINES OL
  WHERE   MSI.INVENTORY_ITEM_ID  = OL.INVENTORY_ITEM_ID
  AND     MSI.ORGANIZATION_ID    = p_ship_from_org_id
  AND     OL.LINE_ID             = p_ato_line_id ;


  -- Get the model quantity in primary UOM

  -- Set the Lead time

  st_lead_time :=  ceil( nvl(db_fixed_lead_time,0) + nvl(db_variable_lead_time,0)
                         * nvl(primary_model_qty,0));

  IF nvl(db_full_lead_time,0) > nvl(st_lead_time,0) THEN
     st_lead_time := ceil(db_full_lead_time);
  END IF;

  RETURN st_lead_time;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 0;
   WHEN OTHERS THEN
        RETURN 0;
END Get_Lead_Time;


/*-----------------------------------------------------------------------------
Procedure Name : Get_Date_Type
Description    : This procedure returns the date type of the order.
                 The date type could be SHIP or ARRIVAl or null. Null
                 value is treated at SHIP in the scheduling code.
-----------------------------------------------------------------------------*/

FUNCTION Get_Date_Type
( p_header_id      IN NUMBER)
RETURN VARCHAR2
IS
l_order_date_type_code   VARCHAR2(30) := null;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF p_header_id <> nvl(G_HEADER_ID,0) THEN
       BEGIN
          SELECT order_date_type_code
          INTO   l_order_date_type_code
          FROM   oe_order_headers
          WHERE  header_id = p_header_id;

          G_HEADER_ID := p_header_id;
          G_DATE_TYPE := l_order_date_type_code;
       EXCEPTION
          WHEN OTHERS THEN
               RETURN null;
       END;
   ELSE
       l_order_date_type_code := G_DATE_TYPE;
   END IF;

   RETURN l_order_date_type_code;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END Get_Date_Type;

/*--------------------------------------------------------------------------
Procedure Name : Get_Order_Number
Description    : This procedure returns the order_number from the header
        record, which we will pass to the MRP API.
--------------------------------------------------------------------------*/
FUNCTION Get_Order_Number(p_header_id in number)
RETURN NUMBER
IS
l_order_number NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_ORDER_NUMBER: ' || P_HEADER_ID , 1 ) ;
  END IF;

  IF p_header_id is not null AND p_header_id  <> FND_API.G_MISS_NUM
  THEN
     BEGIN
        select order_number
        into l_order_number
        from oe_order_headers
        where header_id = p_header_id;
     EXCEPTION
        WHEN OTHERS THEN
             RETURN null;
     END;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ORDER NUMBER : ' || L_ORDER_NUMBER ) ;
  END IF;
  RETURN l_order_number;
EXCEPTION
   WHEN OTHERS THEN
        RETURN null;
END Get_Order_Number;

/*--------------------------------------------------------------------------
Procedure Name : Get_mtl_sales_order_id
Description    : This funtion returns the SALES_ORDER_ID (frm mtl_sales_orders)
                 for a given heeader_id.
                 Every header in oe_order_headers_all will have a record
                 in MTL_SALES_ORDERS. The unique key to get the sales_order_id
                 from mtl_sales_orders is
                 Order_Number
                 Order_Type (in base language)
                 OM:Source Code profile option (stored as ont_source_code).

                 The above values are stored in a flex in MTL_SALES_ORDERS.
                 SEGMENT1 : stores the order number
                 SEGMENT2 : stores the order type
                 SEGMENT3 : stores the ont_source_code value

-------------------------------------------------------------------------- */
FUNCTION Get_mtl_sales_order_id(p_header_id IN NUMBER,
                                p_order_type_id IN NUMBER DEFAULT NULL)
RETURN NUMBER
IS
l_source_code              VARCHAR2(40) := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
l_sales_order_id           NUMBER := 0;
l_order_type_name          VARCHAR2(80);
l_order_type_id            NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING GET_MTL_SALES_ORDER_ID' , 2 ) ;
   END IF;
   -- 3748723
   IF p_order_type_id IS NULL THEN

      IF OE_Order_Cache.g_header_rec.order_type_id IS NOT NULL
      AND OE_Order_Cache.g_header_rec.header_id = p_header_id THEN  --Bug4683211

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'From Header Cache ' , 2 ) ;
         END IF;
         l_order_type_id := OE_Order_Cache.g_header_rec.order_type_id;
      ELSE

         BEGIN
            SELECT order_type_id
            INTO   l_order_type_id
            FROM   oe_order_headers_all
            WHERE  header_id = p_header_id;
         EXCEPTION
            WHEN OTHERS THEN
               RAISE;
         END;
      END IF;
   ELSE
      l_order_type_id:=p_order_type_id;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ORDER TYPE ID :' || L_ORDER_TYPE_ID , 2 ) ;
   END IF;

   --3748723
   IF l_order_type_id = oe_schedule_util.sch_cached_mtl_order_type_id AND
      oe_schedule_util.sch_cached_mtl_order_type_name IS NOT NULL THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'From order_type_id_Cache ' , 2 ) ;
      END IF;
      l_order_type_name := oe_schedule_util.sch_cached_mtl_order_type_name;
   ELSE
      BEGIN
         SELECT NAME
         INTO   l_order_type_name
         FROM   OE_TRANSACTION_TYPES_TL
         WHERE  TRANSACTION_TYPE_ID = l_order_type_id
         AND    language = (select language_code
                            from fnd_languages
                            where installed_flag = 'B');
         oe_schedule_util.sch_cached_mtl_order_type_name := l_order_type_name;
 --Begin Bug#6719001
         oe_schedule_util.sch_cached_mtl_order_type_id := l_order_type_id;
         --End Bug#6719001
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ORDER TYPE: ' || L_ORDER_TYPE_NAME , 2 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SOURCE CODE: ' || L_SOURCE_CODE , 2 ) ;
   END IF;

   --3748723
   IF l_order_type_name = oe_schedule_util.sch_cached_mtl_order_type_name AND
      l_source_code = oe_schedule_util.sch_cached_mtl_source_code AND
      p_header_id = oe_schedule_util.sch_cached_mtl_header_id THEN

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CACHED SALES_ORDER_ID ' || oe_schedule_util.sch_cached_mtl_sales_order_id , 2 ) ;
      END IF;

      RETURN oe_schedule_util.sch_cached_mtl_sales_order_id;
   ELSE
      SELECT S.SALES_ORDER_ID
      INTO l_sales_order_id
      FROM MTL_SALES_ORDERS S,
           OE_ORDER_HEADERS_ALL H
      WHERE S.SEGMENT1 = TO_CHAR(H.ORDER_NUMBER)
      AND S.SEGMENT2 = l_order_type_name
      AND S.SEGMENT3 = l_source_code
      AND H.HEADER_ID = p_header_id;
      --3748723
      oe_schedule_util.sch_cached_mtl_header_id := p_header_id;
      oe_schedule_util.sch_cached_mtl_source_code :=l_source_code;
      oe_schedule_util.sch_cached_mtl_sales_order_id := l_sales_order_id;
      oe_schedule_util.sch_cached_mtl_order_type_id := l_order_type_id;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_SALES_ORDER_ID' || L_SALES_ORDER_ID , 2 ) ;
   END IF;

   RETURN l_sales_order_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  '2. L_SALES_ORDER_ID IS 0' , 2 ) ;
       END IF;
       RETURN 0;
    WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  '2. L_SALES_ORDER_ID IS 0' , 2 ) ;
       END IF;
       RETURN 0;
END Get_mtl_sales_order_id;
/*--------------------------------------------------------------------------
Procedure Name : Insert_Into_Mtl_Sales_Orders
Description    : This API creates a record in MTL_SALES_ORDERS for a given
                 order header.
                 Every header in oe_order_headers_all will have a record
                 in MTL_SALES_ORDERS. The unique key to get the sales_order_id
                 from mtl_sales_orders is
                 Order_Number
                 Order_Type (in base language)
                 OM:Source Code profile option (stored as ont_source_code).

                 The above values are stored in a flex in MTL_SALES_ORDERS.
                 SEGMENT1 : stores the order number
                 SEGMENT2 : stores the order type
                 SEGMENT3 : stores the ont_source_code value

-------------------------------------------------------------------------- */
Procedure Insert_Into_Mtl_Sales_Orders
( p_header_rec       IN  OE_ORDER_PUB.header_rec_type)
IS
l_order_type_name          VARCHAR2(80);
l_source_code              VARCHAR2(40) := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
l_sales_order_id           NUMBER;
l_msg_data                 VARCHAR2(2000);
l_msg_count                NUMBER;
l_return_status            VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING INSERT_INTO_MTL_SALES_ORDERS' , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
  END IF;

  BEGIN
  -- Fix for bug#1078323: the order type name should be selected in
  -- the base language
     SELECT NAME
     INTO l_order_type_name
     FROM OE_TRANSACTION_TYPES_TL
     WHERE TRANSACTION_TYPE_ID = p_header_rec.order_type_id
     AND language = (select language_code
                     from fnd_languages
                     where installed_flag = 'B');
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING INVS CREATE_SALESORDER' , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ORDER TYPE: ' || L_ORDER_TYPE_NAME , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SOURCE CODE: ' || L_SOURCE_CODE , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ORDER NUMBER : ' || P_HEADER_REC.ORDER_NUMBER , 1 ) ;
  END IF;

  inv_salesorder.create_salesorder
      ( p_api_version_number        => 1.0,
        p_segment1                  => p_header_rec.order_number,
        p_segment2                  => l_order_type_name,
        p_segment3                  => l_source_code,
        p_validation_date           => p_header_rec.creation_date,
        x_salesorder_id             => l_sales_order_id,
        x_message_data              => l_msg_data,
        x_message_count             => l_msg_count,
        x_return_status             => l_return_status);


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_MSG_COUNT ' || L_MSG_COUNT , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RETURN STATUS ' || L_RETURN_STATUS , 1 ) ;
  END IF;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       oe_msg_pub.transfer_msg_stack;
       l_msg_count:=OE_MSG_PUB.COUNT_MSG;
       FOR I in 1..l_msg_count LOOP
          l_msg_data := OE_MSG_PUB.Get(I,'F');
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
          END IF;
       END LOOP;

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       oe_msg_pub.transfer_msg_stack;
       l_msg_count:=OE_MSG_PUB.COUNT_MSG;
       FOR I in 1..l_msg_count LOOP
          l_msg_data := OE_MSG_PUB.Get(I,'F');
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
          END IF;
       END LOOP;
       RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING INSERT_INTO_MTL_SALES_ORDERS' , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
  END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Into_Mtl_Sales_Orders'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Into_Mtl_Sales_Orders;


/*---------------------------------------------------------------------
Procedure Name : call_process_order
Description    : This process is called after scheduling is performed
                 on the line and the result needs to be verified and/or
                 updated to the database.
--------------------------------------------------------------------- */
Procedure call_process_order
( p_x_old_line_tbl      IN  OUT NOCOPY OE_ORDER_PUB.line_tbl_type
, p_x_line_tbl          IN  OUT NOCOPY OE_ORDER_PUB.line_tbl_type
, p_control_rec         IN  OE_GLOBALS.control_rec_type
, p_caller              IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2)

IS
is_set_recursion        VARCHAR2(1) := 'Y';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING CALL_PROCESS_ORDER' , 1 ) ;
    END IF;

    OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
    OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING PROCESS ORDER' , 1 ) ;
    END IF;

     -- Set global set recursive flag
     -- The global flag to supress the sets logic to fire in
     -- get set id api in lines
    IF NOT oe_set_util.g_set_recursive_flag  THEN
       is_set_recursion := 'N';
       oe_set_util.g_set_recursive_flag := TRUE;
    END IF;

    --  Call OE_Order_PVT.Process_order

    OE_Order_PVT.Lines
    (p_validation_level            => FND_API.G_VALID_LEVEL_NONE,
     p_control_rec                 => p_control_rec,
     p_x_line_tbl                  => p_x_line_tbl,
     p_x_old_line_tbl              => p_x_old_line_tbl,
     x_return_status               => x_return_status);

    -- unset global set recursive flag
    -- The global flag to supress the sets logic to
    -- fire in get set id api in lines

    IF is_set_recursion  = 'N' THEN
       is_set_recursion := 'Y';
       oe_set_util.g_set_recursive_flag := FALSE;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SCH: AFTER CALLING PROCESS ORDER' , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'X_RETURN_STATUS IS ' || X_RETURN_STATUS , 1 ) ;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RR: UNEXP ERRORED OUT' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RR: ERRORED OUT' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
    OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

     -- Resetting the variable after the Process Order API Call.
     OE_SCHEDULE_UTIL.OESCH_ITEM_IS_SUBSTITUTED := 'N';  -- Added for ER 6110708

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING CALL PROCESS ORDER' , 1 ) ;
    END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Call_Process_Order'
            );
        END IF;
END call_process_order;

/*---------------------------------------------------------------------
Procedure Name : Process_Group_of_Lines
Description    : This process is called after scheduling is performed
                 on the line and the result needs to be verified and/or
                 updated to the database.
--------------------------------------------------------------------- */
Procedure Process_Group_of_Lines
( p_x_old_line_tbl      IN  OUT NOCOPY OE_ORDER_PUB.line_tbl_type
, p_x_line_tbl          IN  OUT NOCOPY OE_ORDER_PUB.line_tbl_type
, p_caller              IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2)

IS
l_process_requests BOOLEAN;
I                  NUMBER;
l_index            NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING PROCESS_GROUP_OF_LINES' , 1 ) ;
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT Process_Group_of_Lines;
    I := p_x_line_tbl.FIRST;
    WHILE I IS NOT NULL LOOP
     BEGIN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OPERATION : ' || P_X_LINE_TBL ( I ) .OPERATION , 1 ) ;
      END IF;
      IF p_x_line_tbl(I).operation <> OE_GLOBALS.G_OPR_NONE
      THEN
         Process_Line (p_old_line_rec    => p_x_old_line_tbl(I),
                       p_x_line_rec      => p_x_line_tbl(I),
                       p_caller          => p_caller,
                       p_call_prn        => FALSE,
                       x_return_status   => x_return_status);

         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'RR: UNEXP ERRORED OUT' , 1 ) ;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'RR: ERRORED OUT' , 1 ) ;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF p_x_line_tbl(I).top_model_line_id = p_x_line_tbl(I).line_id
         THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'CLEAR THE CACHED TOP MODEL RECORD' , 1 ) ;
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'MODEL LINE: '|| P_X_LINE_TBL ( I ) .LINE_ID , 1 ) ;
           END IF;
           OE_Order_Cache.Clear_Top_Model_Line(p_key => p_x_line_tbl(I).line_id);
         END IF;

      ELSIF  nvl(p_x_line_tbl(I).open_flag,'Y') = 'N' THEN


         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'BEFORE DOING DIRECT UPDATE IN GROUP' , 1 ) ;
         END IF;

         p_x_line_tbl(I).last_update_date := SYSDATE;
         p_x_line_tbl(I).last_updated_by := FND_GLOBAL.USER_ID;
         p_x_line_tbl(I).last_update_login := FND_GLOBAL.LOGIN_ID;
         p_x_line_tbl(I).lock_control := p_x_line_tbl(I).lock_control + 1;

   -- added for notification framework
   --check code release level first. Notification framework is at Pack H level
      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
        -- calling notification framework to get index position
        OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                    p_old_line_rec => p_x_old_line_tbl(I),
                    p_line_rec =>p_x_line_tbl(I),
                    p_line_id => p_x_line_tbl(I).line_id,
                    x_index => l_index,
                    x_return_status => x_return_status);
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_SCHEDULE_UTIL.PROCESS_GROUP_OF_LINE IS: ' || X_RETURN_STATUS ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'GLOBAL PICTURE INDEX IS: ' || L_INDEX , 1 ) ;
          END IF;

         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'RR: UNEXP ERRORED OUT' , 1 ) ;
              END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'RR: ERRORED OUT' , 1 ) ;
             END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      IF l_index is not NULL THEN
          --update Global Picture directly
           OE_ORDER_UTIL.g_line_tbl(l_index).ship_from_org_id := p_x_line_tbl(I).ship_from_org_id;
           OE_ORDER_UTIL.g_line_tbl(l_index).schedule_ship_date := p_x_line_tbl(I).schedule_ship_date;
           OE_ORDER_UTIL.g_line_tbl(l_index).schedule_arrival_date := p_x_line_tbl(I).schedule_arrival_date;
           OE_ORDER_UTIL.g_line_tbl(l_index).delivery_lead_time    := p_x_line_tbl(I).delivery_lead_time;
           OE_ORDER_UTIL.g_line_tbl(l_index).mfg_lead_time         := p_x_line_tbl(I).mfg_lead_time;
           OE_ORDER_UTIL.g_line_tbl(l_index).shipping_method_code   := p_x_line_tbl(I).shipping_method_code;
           OE_ORDER_UTIL.g_line_tbl(l_index).schedule_status_code  := p_x_line_tbl(I).schedule_status_code;
           OE_ORDER_UTIL.g_line_tbl(l_index).visible_demand_flag    := p_x_line_tbl(I).visible_demand_flag;
           OE_ORDER_UTIL.g_line_tbl(l_index).latest_acceptable_date := p_x_line_tbl(I).latest_acceptable_date;
           OE_ORDER_UTIL.g_line_tbl(l_index).last_update_date       := p_x_line_tbl(I).last_update_date;
           OE_ORDER_UTIL.g_line_tbl(l_index).last_updated_by        := p_x_line_tbl(I).last_updated_by;
           OE_ORDER_UTIL.g_line_tbl(l_index).last_update_login      := p_x_line_tbl(I).last_update_login;
           OE_ORDER_UTIL.g_line_tbl(l_index).lock_control           := p_x_line_tbl(I).lock_control;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'GLOBAL SHIP_FROM_ORG_ID IS: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_INDEX ) .SHIP_FROM_ORG_ID , 1 ) ;
           END IF;
        END IF; /*l_index is not null check*/
      END IF;  /*code_release_level*/

         UPDATE OE_ORDER_LINES
         SET
          ship_from_org_id           = p_x_line_tbl(I).ship_from_org_id
         ,schedule_ship_date         = p_x_line_tbl(I).schedule_ship_date
         ,schedule_arrival_date      = p_x_line_tbl(I).schedule_arrival_date
         ,delivery_lead_time         = p_x_line_tbl(I).delivery_lead_time
         ,mfg_lead_time              = p_x_line_tbl(I).mfg_lead_time
         ,shipping_method_code       = p_x_line_tbl(I).shipping_method_code
         ,schedule_status_code       = p_x_line_tbl(I).schedule_status_code
         ,visible_demand_flag        = p_x_line_tbl(I).visible_demand_flag
         ,latest_acceptable_date     = p_x_line_tbl(I).latest_acceptable_date
         ,Original_Inventory_Item_Id
                              = p_x_line_tbl(I).Original_Inventory_Item_Id
         ,Original_item_identifier_Type
                              = p_x_line_tbl(I).Original_item_identifier_Type
         ,Original_ordered_item_id   = p_x_line_tbl(I).Original_ordered_item_id
         ,Original_ordered_item      = p_x_line_tbl(I).Original_ordered_item
         ,last_update_date           = p_x_line_tbl(I).last_update_date
         ,last_updated_by            = p_x_line_tbl(I).last_updated_by
         ,last_update_login          = p_x_line_tbl(I).last_update_login
         ,lock_control               = p_x_line_tbl(I).lock_control
         WHERE LINE_ID = p_x_line_tbl(I).line_id;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER DOING DIRECT UPDATE' , 1 ) ;
         END IF;
      END IF;

     END;
     I := p_x_line_tbl.NEXT(I);
    END LOOP;

   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
    IF p_caller  = SCH_INTERNAL THEN
        l_process_requests := FALSE;
    ELSE
        l_process_requests := TRUE;
    END IF;

    OE_Order_PVT.Process_Requests_And_Notify
    ( p_process_requests        => l_process_requests
    , p_notify                  => FALSE
    , p_line_tbl                => p_x_line_tbl
    , p_old_line_tbl            => p_x_old_line_tbl
    , x_return_status           => x_return_status
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SCH: AFTER CALLING PROCESS REQUEST' , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'X_RETURN_STATUS IS ' || X_RETURN_STATUS , 1 ) ;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RR: UNEXP ERRORED OUT' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RR: ERRORED OUT' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

 ELSE  /*pre pack H*/
     -- Do not process delayed requests if this was a recursive
     -- call (e.g. from oe_line_util.pre_write_process)

    IF p_caller  = SCH_INTERNAL THEN
        l_process_requests := FALSE;
    ELSE
        l_process_requests := TRUE;
    END IF;

    OE_Order_PVT.Process_Requests_And_Notify
    ( p_process_requests        => l_process_requests
    , p_notify                  => TRUE
    , p_line_tbl                => p_x_line_tbl
    , p_old_line_tbl            => p_x_old_line_tbl
    , x_return_status           => x_return_status
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SCH: AFTER CALLING PROCESS REQUEST' , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'X_RETURN_STATUS IS ' || X_RETURN_STATUS , 1 ) ;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RR: UNEXP ERRORED OUT' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RR: ERRORED OUT' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
 END IF; /*code_release_level*/


    OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
    OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESS GROUP ' || OESCH_PERFORM_SCHEDULING , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING PROCESS GROUP OF LINES' , 1 ) ;
    END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        x_return_status := FND_API.G_RET_STS_ERROR;
        ROLLBACK TO SAVEPOINT Process_Group_of_lines;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO SAVEPOINT Process_Group_of_lines;

    WHEN OTHERS THEN

        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO SAVEPOINT Process_Group_of_lines;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Call_Process_Order'
            );
        END IF;
END Process_Group_of_Lines;


/*---------------------------------------------------------------------
Procedure Name : Process_Line
Description    : This process is called after scheduling is performed
                 on the line and the result needs to be verified and/or
                 updated to the database.

New code :  If the warehouse is changed on the line due to scheduling
            we will follow older approch. If warehouse is not changed ont
            the line then call security based on the operation. Call new API
            for clear-dep and defaulting. Based on  the output from the new api
            either call process order or do a direct update.
            p_call_prn is call process_request and notify.
--------------------------------------------------------------------- */
Procedure Process_Line
( p_old_line_rec        IN  OE_ORDER_PUB.line_rec_type
, p_x_line_rec          IN  OUT NOCOPY OE_ORDER_PUB.line_rec_type
, p_caller              IN  VARCHAR2
, p_call_prn            IN  BOOLEAN := TRUE
, x_return_status OUT NOCOPY VARCHAR2)

IS
l_process_requests      BOOLEAN;
l_line_tbl              OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl          OE_ORDER_PUB.line_tbl_type;
l_sec_result            NUMBER;
l_order_type_id         NUMBER := OE_Order_Cache.g_header_rec.order_type_id;
l_control_rec           OE_GLOBALS.control_rec_type;
l_src_attr_tbl          OE_GLOBALS.NUMBER_Tbl_Type;
l_index                 NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING PROCESS_LINE' , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_CALLER ' || P_CALLER , 1 ) ;
    END IF;

    /* Start Audit Trail */
    --Added is_mass_change condition for bug 4911340
    IF NOT OE_GLOBALS.G_UI_FLAG AND OE_MASS_CHANGE_PVT.IS_MASS_CHANGE = 'F' THEN
      p_x_line_rec.change_reason := 'SYSTEM';
    END IF;

   -- p_x_line_rec.change_comments := 'Scheduling Action';
    /* End Audit Trail */

   -- When warehouse is changed on the line then call process_order.

   IF nvl(p_x_line_rec.open_flag,'Y') = 'N' THEN

                                   IF l_debug_level  > 0 THEN
                                       oe_debug_pub.add(  'DIRECT UPDATE FOR A CANCELLED LINE' || P_X_LINE_REC.LINE_ID , 1 ) ;
                                   END IF;

         p_x_line_rec.last_update_date := SYSDATE;
         p_x_line_rec.last_updated_by := FND_GLOBAL.USER_ID;
         p_x_line_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
         p_x_line_rec.lock_control := p_x_line_rec.lock_control + 1;

         UPDATE OE_ORDER_LINES
         SET
          ship_from_org_id           = p_x_line_rec.ship_from_org_id
         ,schedule_ship_date         = p_x_line_rec.schedule_ship_date
         ,schedule_arrival_date      = p_x_line_rec.schedule_arrival_date
         ,delivery_lead_time         = p_x_line_rec.delivery_lead_time
         ,mfg_lead_time              = p_x_line_rec.mfg_lead_time
         ,shipping_method_code       = p_x_line_rec.shipping_method_code
         ,schedule_status_code       = p_x_line_rec.schedule_status_code
         ,visible_demand_flag        = p_x_line_rec.visible_demand_flag
         ,Original_Inventory_Item_Id = p_x_line_rec.Original_Inventory_Item_Id
         ,Original_item_identifier_Type
                                 = p_x_line_rec.Original_item_identifier_Type
         ,Original_ordered_item_id   = p_x_line_rec.Original_ordered_item_id
         ,Original_ordered_item      = p_x_line_rec.Original_ordered_item
         ,latest_acceptable_date     = p_x_line_rec.latest_acceptable_date
         ,override_atp_date_code     = p_x_line_rec.override_atp_date_code
         ,firm_demand_flag           = p_x_line_rec.firm_demand_flag
         ,earliest_ship_date         = p_x_line_rec.earliest_ship_date
         ,last_update_date           = p_x_line_rec.last_update_date
         ,last_updated_by            = p_x_line_rec.last_updated_by
         ,last_update_login          = p_x_line_rec.last_update_login
         ,lock_control               = p_x_line_rec.lock_control
         WHERE LINE_ID = p_x_line_rec.line_id;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER DOING DIRECT UPDATE ON A CANCELLED LINE' , 1 ) ;
         END IF;

   ELSIF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_from_org_id,
                           p_old_line_rec.ship_from_org_id)
   OR    NOT OE_GLOBALS.Equal(p_x_line_rec.ship_to_org_id,
                           p_old_line_rec.ship_to_org_id)
   OR    NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,
                           p_old_line_rec.inventory_item_id)
   THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'WAREHOUSE/SHIP TO HAS CHANGED ON THE LINE CALLING PO' , 1 ) ;
    END IF;

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.check_security       := TRUE;

    l_control_rec.write_to_DB          := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    l_old_line_tbl(1) := p_old_line_rec;
    l_line_tbl(1)     := p_x_line_rec;

    -- We are doing this since we are calling the po from post write.

    l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;

    Call_Process_Order(p_x_old_line_tbl  => l_old_line_tbl,
                       p_x_line_tbl      => l_line_tbl,
                       p_control_rec     => l_control_rec,
                       p_caller          => p_caller,
                       x_return_status   => x_return_status);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   ELSE -- warehouse is not changed on the line.

      IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IT IS UPDATE , CALL SECURITY' ) ;
        END IF;

        IF p_caller = 'INTERNAL' THEN      -- 5999034
           p_x_line_rec.change_reason := 'SYSTEM';
        END IF;


        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';

        OE_Line_Security.Attributes
                ( p_line_rec        => p_x_line_rec
                , p_old_line_rec    => p_old_line_rec
                , x_result          => l_sec_result
                , x_return_status   => x_return_status
                );

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER SECURITY CALL' || X_RETURN_STATUS , 1 ) ;
        END IF;

         -- if operation on any attribute is constrained
        IF l_sec_result = OE_PC_GLOBALS.YES THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'CONSTRAINT FOUND' , 4 ) ;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; -- operation update.

      --Value of the G_ATTR_UPDATED_BY_DEF will be set in defaulting
      -- We will re-set the value, before calling.
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'N';

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OLD SHIP :' || P_OLD_LINE_REC.SCHEDULE_SHIP_DATE , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NEW SHIP :' || P_X_LINE_REC.SCHEDULE_SHIP_DATE , 1 ) ;
      END IF;

     IF NOT OE_GLOBALS.Equal(trunc(p_x_line_rec.schedule_ship_date),     -- 5999034
                              trunc(p_old_line_rec.schedule_ship_date))

      THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SHIP_DATE HAS CHANGED ON THE LINE' , 1 ) ;
       END IF;
       l_src_attr_tbl(1) := OE_LINE_UTIL.G_SCHEDULE_SHIP_DATE;

       OE_Line_Util_Ext.Clear_Dep_And_Default
          ( p_src_attr_tbl    => l_src_attr_tbl,
            p_x_line_rec      => p_x_line_rec,
            p_old_line_rec    => p_old_line_rec);
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AFTER CALLING CLEAR_DEP_AND_DEFAULT' , 1 ) ;
       END IF;

      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DIRECT/PO ' || OE_GLOBALS.G_ATTR_UPDATED_BY_DEF , 1 ) ;
      END IF;
      IF OE_GLOBALS.G_ATTR_UPDATED_BY_DEF = 'Y' THEN


         l_control_rec.controlled_operation := TRUE;
         l_control_rec.change_attributes    := TRUE;

         l_control_rec.clear_dependents     := FALSE;
         l_control_rec.default_attributes   := FALSE;
         l_control_rec.check_security       := FALSE;

         l_control_rec.write_to_DB          := TRUE;
         l_control_rec.validate_entity      := TRUE;
         l_control_rec.process              := FALSE;

         --  Instruct API to retain its caches

         l_control_rec.clear_api_cache      := FALSE;
         l_control_rec.clear_api_requests   := FALSE;

         l_old_line_tbl(1) := p_old_line_rec;
         l_line_tbl(1)     := p_x_line_rec;

         -- We are doing this since we are calling the po from post write.

         l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;

         Call_Process_Order(p_x_old_line_tbl  => l_old_line_tbl,
                            p_x_line_tbl      => l_line_tbl,
                            p_control_rec     => l_control_rec,
                            p_caller          => p_caller,
                            x_return_status   => x_return_status);

         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      ELSE
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' DEFAULTING HAS NOT CHANGED ANY THING' , 1 ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'BEFORE CALLING LOG_SCHEDULING REQUESTS' , 1 ) ;
         END IF;

         OE_MSG_PUB.set_msg_context
         (p_entity_code                => 'LINE'
         ,p_entity_id                  => p_x_line_rec.line_id
         ,p_header_id                  => p_x_line_rec.header_id
         ,p_line_id                    => p_x_line_rec.line_id
         ,p_orig_sys_document_ref      => p_x_line_rec.orig_sys_document_ref
         ,p_orig_sys_document_line_ref => p_x_line_rec.orig_sys_line_ref
         ,p_orig_sys_shipment_ref      => p_x_line_rec.orig_sys_shipment_ref
         ,p_change_sequence            => p_x_line_rec.change_sequence
         ,p_source_document_id         => p_x_line_rec.source_document_id
         ,p_source_document_line_id    => p_x_line_rec.source_document_line_id
         ,p_order_source_id            => p_x_line_rec.order_source_id
         ,p_source_document_type_id    => p_x_line_rec.source_document_type_id);

         OE_LINE_UTIL.Log_Scheduling_Requests
         (p_x_line_rec    => p_x_line_rec
         ,p_old_line_rec  => p_old_line_rec
         ,p_caller        => p_caller
         ,p_order_type_id => l_order_type_id
         ,x_return_status => x_return_status);

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER CALLING LOG_SCHEDULING REQUESTS' || X_RETURN_STATUS , 1 ) ;
         END IF;

         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'BEFORE DOING DIRECT UPDATE' , 1 ) ;
         END IF;
         IF NOT validate_ship_method (p_x_line_rec.shipping_method_code,
                                  p_old_line_rec.shipping_method_code,
                                  p_x_line_rec.ship_from_org_id) THEN

           p_x_line_rec.shipping_method_code := Null;
           p_x_line_rec.freight_carrier_code := Null;
         END IF;

         -- Start 2806483
         IF (p_x_line_rec.shipping_method_code IS NOT NULL
         AND p_x_line_rec.shipping_method_code <> FND_API.G_MISS_CHAR)
         AND NOT OE_GLOBALS.EQUAL(p_x_line_rec.shipping_method_code
                                 ,p_old_line_rec.shipping_method_code)
         THEN

            p_x_line_rec.freight_carrier_code :=
                    OE_Default_Line.Get_Freight_Carrier(p_line_rec => p_x_line_rec,
                                                        p_old_line_rec => p_old_line_rec);
         END IF;
         -- End 2806483

         p_x_line_rec.last_update_date := SYSDATE;
         p_x_line_rec.last_updated_by := FND_GLOBAL.USER_ID;
         p_x_line_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
         p_x_line_rec.lock_control := p_x_line_rec.lock_control + 1;

         -- Pack J: Promise Date is added to the update to reflect any change to promise date
         UPDATE OE_ORDER_LINES
         SET
          ship_from_org_id           = p_x_line_rec.ship_from_org_id
         ,schedule_ship_date         = p_x_line_rec.schedule_ship_date
         ,schedule_arrival_date      = p_x_line_rec.schedule_arrival_date
         ,delivery_lead_time         = p_x_line_rec.delivery_lead_time
         ,mfg_lead_time              = p_x_line_rec.mfg_lead_time
         ,shipping_method_code       = p_x_line_rec.shipping_method_code
         ,schedule_status_code       = p_x_line_rec.schedule_status_code
         ,visible_demand_flag        = p_x_line_rec.visible_demand_flag
         ,Original_Inventory_Item_Id = p_x_line_rec.Original_Inventory_Item_Id
         ,Original_item_identifier_Type
                                  = p_x_line_rec.Original_item_identifier_Type
         ,Original_ordered_item_id   = p_x_line_rec.Original_ordered_item_id
         ,Original_ordered_item      = p_x_line_rec.Original_ordered_item
         ,latest_acceptable_date     = p_x_line_rec.latest_acceptable_date
         ,override_atp_date_code     = p_x_line_rec.override_atp_date_code
         ,freight_carrier_code       = p_x_line_rec.freight_carrier_code
         ,firm_demand_flag           = p_x_line_rec.firm_demand_flag
         ,earliest_ship_date         = p_x_line_rec.earliest_ship_date
         ,promise_date               = p_x_line_rec.promise_date
         ,last_update_date           = p_x_line_rec.last_update_date
         ,last_updated_by            = p_x_line_rec.last_updated_by
         ,last_update_login          = p_x_line_rec.last_update_login
         ,lock_control               = p_x_line_rec.lock_control
         WHERE LINE_ID = p_x_line_rec.line_id;  --2806483 Added Fright_carrier_code

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER DOING DIRECT UPDATE' , 1 ) ;
         END IF;

      END IF; -- OE_GLOBALS.G_ATTR_UPDATED_BY_DEF.
   END IF; -- warehouse is changed.

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RR: UNEXP ERRORED OUT' , 1 ) ;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RR: ERRORED OUT' , 1 ) ;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF l_line_tbl.count = 0 THEN

      l_old_line_tbl(1) := p_old_line_rec;
      l_line_tbl(1)     := p_x_line_rec;

       -- We are doing this since we are calling the po from post write.

      l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;


   END IF;

   -- added for notification framework
   --check code release level first. Notification framework is at Pack H level

   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN

        -- calling notification framework to get index position
        OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>True,--changed for bug 8737932
                    p_old_line_rec => p_old_line_rec,
                    p_line_rec =>p_x_line_rec,
                    p_line_id => p_x_line_rec.line_id,
                    x_index => l_index,
                    x_return_status => x_return_status);
                           IF l_debug_level  > 0 THEN
                               oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_SCHEDULE_UTIL.PROCESS_LINE IS: ' || X_RETURN_STATUS ) ;
                           END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'GLOBAL PICTURE INDEX IS: ' || L_INDEX , 1 ) ;
        END IF;

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'RR: UNEXP ERRORED OUT' , 1 ) ;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'RR: ERRORED OUT' , 1 ) ;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_index is not NULL THEN
          --update Global Picture directly
          OE_ORDER_UTIL.g_line_tbl(l_index).ship_from_org_id := p_x_line_rec.ship_from_org_id;
          OE_ORDER_UTIL.g_line_tbl(l_index).schedule_ship_date := p_x_line_rec.schedule_ship_date;
          OE_ORDER_UTIL.g_line_tbl(l_index).schedule_arrival_date := p_x_line_rec.schedule_arrival_date;
          OE_ORDER_UTIL.g_line_tbl(l_index).delivery_lead_time    := p_x_line_rec.delivery_lead_time;
          OE_ORDER_UTIL.g_line_tbl(l_index).mfg_lead_time         := p_x_line_rec.mfg_lead_time;
          OE_ORDER_UTIL.g_line_tbl(l_index).shipping_method_code   := p_x_line_rec.shipping_method_code;
          OE_ORDER_UTIL.g_line_tbl(l_index).schedule_status_code  := p_x_line_rec.schedule_status_code;
          OE_ORDER_UTIL.g_line_tbl(l_index).visible_demand_flag    := p_x_line_rec.visible_demand_flag;
          OE_ORDER_UTIL.g_line_tbl(l_index).latest_acceptable_date := p_x_line_rec.latest_acceptable_date;
          OE_ORDER_UTIL.g_line_tbl(l_index).last_update_date       := p_x_line_rec.last_update_date;
          OE_ORDER_UTIL.g_line_tbl(l_index).last_updated_by        := p_x_line_rec.last_updated_by;
          OE_ORDER_UTIL.g_line_tbl(l_index).last_update_login      := p_x_line_rec.last_update_login;
          OE_ORDER_UTIL.g_line_tbl(l_index).lock_control           := p_x_line_rec.lock_control;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'GLOBAL SHIP_FROM_ORG_ID IS: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_INDEX ) .SHIP_FROM_ORG_ID , 1 ) ;
          END IF;
        END IF; /*l_index is not null check*/

    -- Do not execute delayed request if it is a internal call.
    -- call (e.g. from oe_line_util.post_write_process)

    IF p_call_prn THEN

      IF p_caller = SCH_INTERNAL THEN
          l_process_requests := FALSE;
      ELSE
          l_process_requests := TRUE;
      END IF;

      OE_Order_PVT.Process_Requests_And_Notify
      ( p_process_requests        => l_process_requests
      , p_notify                  => FALSE
      , p_line_tbl                => l_line_tbl
      , p_old_line_tbl            => l_old_line_tbl
      , x_return_status           => x_return_status);


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SCH: AFTER CALLING PROCESS REQUEST AND NOTIFY' , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'X_RETURN_STATUS IS ' || X_RETURN_STATUS , 1 ) ;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RR: UNEXP ERRORED OUT' , 1 ) ;
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RR: ERRORED OUT' , 1 ) ;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF;
  ELSE /*pre pack H*/

    -- Do not execute delayed request if it is a internal call.
    -- call (e.g. from oe_line_util.post_write_process)

    IF p_call_prn THEN

      IF p_caller = SCH_INTERNAL THEN
          l_process_requests := FALSE;
      ELSE
          l_process_requests := TRUE;
      END IF;

      OE_Order_PVT.Process_Requests_And_Notify
      ( p_process_requests        => l_process_requests
      , p_notify                  => TRUE
      , p_line_tbl                => l_line_tbl
      , p_old_line_tbl            => l_old_line_tbl
      , x_return_status           => x_return_status);


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SCH: AFTER CALLING PROCESS REQUEST AND NOTIFY' , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'X_RETURN_STATUS IS ' || X_RETURN_STATUS , 1 ) ;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RR: UNEXP ERRORED OUT' , 1 ) ;
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RR: ERRORED OUT' , 1 ) ;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;
 END IF; /*code_release_level*/
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING PROCESS_LINE ' , 1 ) ;
    END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Line'
            );
        END IF;
END Process_Line;
/*--------------------------------------------------------
PROCEDURE ATP_Check

--------------------------------------------------------*/
Procedure ATP_Check
         ( p_old_line_rec       IN  OE_ORDER_PUB.line_rec_type,
           p_x_line_rec         IN  OUT NOCOPY OE_ORDER_PUB.line_rec_type,
           p_validate           IN  VARCHAR2 := FND_API.G_TRUE,
x_atp_tbl OUT NOCOPY OE_ATP.atp_tbl_type,

x_return_status OUT NOCOPY VARCHAR2

           )
IS

  -- BUG 1955004
  l_scheduling_level_code VARCHAR2(30);
  -- END 1955004

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING ATP_CHECK ' , 2 ) ;
     END IF;
  -- Since we are not calling need scheduling from here

   g_atp_tbl.Delete;

   IF p_validate = FND_API.G_TRUE THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE CALLING VALIDATE LINE' , 2 ) ;
      END IF;
      Validate_Line(p_line_rec      => p_x_line_rec,
                    p_old_line_rec  => p_old_line_rec,
                    p_sch_action    => p_x_line_rec.schedule_action_code,
                    x_return_status => x_return_status);

   END IF;

  -- BUG 1955004
  l_scheduling_level_code := Get_Scheduling_Level(p_x_line_rec.header_id,
                                                   p_x_line_rec.line_type_id);

  IF l_scheduling_level_code IS NULL THEN

     l_scheduling_level_code := SCH_LEVEL_THREE;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SCHEDULING_LEVEL_CODE IS:' || L_SCHEDULING_LEVEL_CODE , 2 ) ;
  END IF;
  -- 3763015
  IF l_scheduling_level_code <> SCH_LEVEL_FOUR AND
     l_scheduling_level_code <> SCH_LEVEL_FIVE AND
     NVL(fnd_profile.value('ONT_BYPASS_ATP'),'N') = 'N' AND
     (Nvl(p_x_line_rec.bypass_sch_flag, 'N') = 'N'
     OR p_x_line_rec.bypass_sch_flag = FND_API.G_MISS_CHAR ) THEN --14043008
    -- FOUR and FIVE CANNOT have ATP Performed
    -- validation may be off, so we we need to double-check here
   --END 1955004

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE CALLING ACTION_ATP ' , 2 ) ;
   END IF;
   Action_ATP(p_x_line_rec    => p_x_line_rec,
              p_old_line_rec  => p_old_line_rec,
              x_return_status => x_return_status);



   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'AFTER CALLING ACTION_ATP ' || X_RETURN_STATUS , 2 ) ;
   END IF;
   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR FROM ' , 1 ) ;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RR: L2' , 1 ) ;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

    x_atp_tbl := g_atp_tbl;

   END IF;  -- for new IF check added for 1955004

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING ATP_CHECK ' , 2 ) ;
    END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          OE_MSG_PUB.Add_Exc_Msg
          (   G_PKG_NAME
          ,   'ATP_Check'
          );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END ATP_Check;

/*--------------------------------------------------------
PROCEDURE Multi_ATP_Check

--------------------------------------------------------*/
PROCEDURE Multi_ATP_Check
         ( p_old_line_tbl       IN  OE_ORDER_PUB.line_tbl_type,
           p_x_line_tbl         IN  OUT NOCOPY OE_ORDER_PUB.line_tbl_type,
x_atp_tbl OUT NOCOPY OE_ATP.atp_tbl_type,

x_return_status OUT NOCOPY VARCHAR2

           )
IS
l_msg_count               NUMBER;
l_mrp_msg_data            VARCHAR2(2000);
l_session_id              NUMBER := 0;
l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
l_out_mrp_atp_rec         MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
l_on_hand_qty             NUMBER;
l_avail_to_reserve        NUMBER;
l_on_hand_qty2             NUMBER; -- INVCONV
l_avail_to_reserve2        NUMBER; -- invconv
l_process_flag            VARCHAR2(1) := FND_API.G_FALSE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING MULTI ATP_CHECK ' , 2 ) ;
   END IF;

   g_atp_tbl.Delete;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE CALLING LOAD_MRP_TBL ' , 2 ) ;
   END IF;

   Load_MRP_request_from_tbl
       ( p_line_tbl      => p_x_line_tbl
        ,p_old_line_tbl  => p_old_line_tbl
        ,p_sch_action    => OESCH_ACT_ATP_CHECK
        ,x_mrp_atp_rec   => l_mrp_atp_rec);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'AFTER CALLING LOAD_MRP_TBL ' , 2 ) ;
   END IF;

   IF l_mrp_atp_rec.error_code.count > 0 THEN


     l_session_id := Get_Session_Id;
     G_ATP_CHECK_session_id := l_session_id;

     -- Call ATP

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CALLING MRP API WITH SESSION ID '||L_SESSION_ID , 0.5 ) ; -- debug level changed to 0.5 for bug 13435459
     END IF;

     MRP_ATP_PUB.Call_ATP
        ( p_session_id             =>  l_session_id
        , p_atp_rec                =>  l_mrp_atp_rec
        , x_atp_rec                =>  l_out_mrp_atp_rec
        , x_atp_supply_demand      =>  l_atp_supply_demand
        , x_atp_period             =>  l_atp_period
        , x_atp_details            =>  l_atp_details
        , x_return_status          =>  x_return_status
        , x_msg_data               =>  l_mrp_msg_data
        , x_msg_count              =>  l_msg_count);

     IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' AFTER CALLING MRP_ATP_PUB.CALL_ATP ' || X_RETURN_STATUS , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
     END IF;

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
/*     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR; */
     END IF;

   END IF;  -- Moved the end of the if here becausw we want to call Load_Results
             -- with a count of 0 because of bug 1955004

     Load_Results_from_tbl(p_atp_rec        => l_out_mrp_atp_rec,
                           p_old_line_tbl   => p_old_line_tbl,  -- Added new parameter to support 1955004
                           p_x_line_tbl     => p_x_line_tbl,
                           x_return_status  => x_return_status);

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER CALLING ACTION_ATP ' || X_RETURN_STATUS , 2 ) ;
     END IF;

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
     END IF;

   -- END IF; -- MRP count.  Moved this end if per 1955004 above

     -- We also need to pass back on-hand qty and available_to_reserve
     -- qties while performing ATP. Getting these values from inventory.

     FOR K IN 1..g_atp_tbl.count LOOP
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING QUERY_QTY_TREE' , 1 ) ;
        END IF;
        Query_Qty_Tree(p_org_id           => g_atp_tbl(K).ship_from_org_id,
                       p_item_id          => g_atp_tbl(K).inventory_item_id,
                       p_line_id          => g_atp_tbl(K).line_id,
                       p_sch_date     => nvl(g_atp_tbl(K).group_available_date,
                                       g_atp_tbl(K).ordered_qty_Available_Date),
                       x_on_hand_qty      => l_on_hand_qty,
                       x_avail_to_reserve => l_avail_to_reserve,
                       x_on_hand_qty2      => l_on_hand_qty2, -- INVCONV
                       x_avail_to_reserve2 => l_avail_to_reserve2, -- INVCONV
                       p_subinventory_code => g_atp_tbl(K).subinventory_code --11777419
                       );


        --  added by fabdi 03/May/2001
        IF NOT INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id
                                              => g_atp_tbl(K).ship_from_org_id)
        THEN
           l_process_flag := FND_API.G_FALSE;
        ELSE
           l_process_flag := FND_API.G_TRUE;
        END IF;

        IF l_process_flag = FND_API.G_TRUE
        THEN
          g_atp_tbl(K).on_hand_qty          := l_on_hand_qty;
          g_atp_tbl(K).available_to_reserve := l_avail_to_reserve;
        -- g_atp_tbl(K).QTY_ON_REQUEST_DATE  := l_avail_to_reserve;
        -- Above line commented for bug 11658607 as it was a wrong assignment  -- Available field in ATP

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_ON_HAND_QTY' || L_ON_HAND_QTY ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_AVAIL_TO_RESERVE' || L_AVAIL_TO_RESERVE ) ;
          END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AVAILABLE ' || L_AVAIL_TO_RESERVE ) ;
         END IF;
        ELSE
          IF g_atp_tbl(K).substitute_flag = 'N' THEN
             g_atp_tbl(K).on_hand_qty          := l_on_hand_qty;
             g_atp_tbl(K).available_to_reserve := l_avail_to_reserve;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'L_ON_HAND_QTY' || L_ON_HAND_QTY ) ;
             END IF;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'L_AVAIL_TO_RESERVE' || L_AVAIL_TO_RESERVE ) ;
             END IF;
          ELSE
             g_atp_tbl(K).sub_on_hand_qty          := l_on_hand_qty;
             g_atp_tbl(K).sub_available_to_reserve := l_avail_to_reserve;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'SUB L_ON_HAND_QTY' || L_ON_HAND_QTY ) ;
             END IF;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'SUB L_AVAIL_TO_RESERVE' || L_AVAIL_TO_RESERVE ) ;
             END IF;

             Query_Qty_Tree
                  (p_org_id           => g_atp_tbl(K).ship_from_org_id,
                   p_item_id          => g_atp_tbl(K).request_item_id,
                   p_line_id          => g_atp_tbl(K).line_id,
                   p_sch_date         => g_atp_tbl(K).req_item_available_date,
                   x_on_hand_qty      => l_on_hand_qty,
                   x_avail_to_reserve => l_avail_to_reserve,
                   x_on_hand_qty2      => l_on_hand_qty2, -- INVCONV
                   x_avail_to_reserve2 => l_avail_to_reserve2 -- INVCONV
                       );

             g_atp_tbl(K).on_hand_qty          := l_on_hand_qty;
             g_atp_tbl(K).available_to_reserve := l_avail_to_reserve;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'L_ON_HAND_QTY' || L_ON_HAND_QTY ) ;
             END IF;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'L_AVAIL_TO_RESERVE' || L_AVAIL_TO_RESERVE ) ;
             END IF;
          END IF; -- Substitution.
        END IF;
        -- end fabdi

     END LOOP;


    x_atp_tbl := g_atp_tbl;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING MULTI ATP_CHECK ' , 2 ) ;
    END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'MULTI_ATP_Check'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Multi_ATP_Check;

Procedure Delete_Row(p_line_id      IN NUMBER)
IS
l_line_rec               OE_ORDER_PUB.line_rec_type;
l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_sales_order_id         NUMBER;
l_ato_exists             VARCHAR2(1);
l_request_search_rslt    BOOLEAN;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_SCHEDULE_UTIL.DELETE_ROW' , 1 ) ;
  END IF;
  OE_Line_Util.Query_Row(p_line_id    => p_line_id,
                         x_line_rec   => l_line_rec);

  /* Fix for bug 2643593, reservations to be removed only for
     shippable line */

  IF nvl(l_line_rec.shippable_flag,'N') = 'Y' THEN

    l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id
                                              (l_line_rec.HEADER_ID);


     -- INVCONV - MERGED CALLS   FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

     OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                              ,p_line_id   => l_line_rec.line_id
                                              ,p_org_id    => l_line_rec.ship_from_org_id
                                              ,x_reserved_quantity =>  l_line_rec.reserved_quantity
                                              ,x_reserved_quantity2 => l_line_rec.reserved_quantity2
                                                                                            );

    /*l_line_rec.reserved_quantity :=
              OE_LINE_UTIL.Get_Reserved_Quantity
                 (p_header_id   => l_sales_order_id,
                  p_line_id     => l_line_rec.line_id,
                  p_org_id      => l_line_rec.ship_from_org_id);
    l_line_rec.reserved_quantity2 :=           -- INVCONV
              OE_LINE_UTIL.Get_Reserved_Quantity2
                 (p_header_id   => l_sales_order_id,
                  p_line_id     => l_line_rec.line_id,
                  p_org_id      => l_line_rec.ship_from_org_id);   */

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'after Get_Reserved_Quantities, l_line_rec.reserved_quantity2 = ' ||  l_line_rec.reserved_quantity2, 1 ) ;
             END IF;



  END IF;

  IF l_line_rec.reserved_quantity is not null
  THEN
    -- Call INV to delete the old reservations
    -- shipping_interfaced_flag

       IF l_line_rec.reserved_quantity2 = 0 -- INVCONV
        THEN
          l_line_rec.reserved_quantity2 := NULL;
       END IF;


       Unreserve_Line
        (p_line_rec              => l_line_rec,
         p_quantity_to_unreserve => l_line_rec.reserved_quantity,
         p_quantity2_to_unreserve => l_line_rec.reserved_quantity2, -- INVCONV
         x_return_status         => l_return_status);
  END IF;
  -- 4026758
  IF l_line_rec.ship_set_id IS NOT NULL
     OR l_line_rec.arrival_set_id IS NOT NULL THEN
     -- Line is with a set.

     Log_Delete_Set_Request
       (p_header_id   => l_line_rec.header_id,
        p_line_id     => l_line_rec.line_id,
        p_set_id      => nvl(l_line_rec.ship_set_id,l_line_rec.arrival_set_id),
        x_return_status => l_return_status);
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER LOGGING DELETE SETS DELAYED REQUEST ' || L_RETURN_STATUS , 1 ) ;
     END IF;

  --bug#5631508
   IF L_RETURN_STATUS=FND_API.G_RET_STS_SUCCESS then

	OE_AUDIT_HISTORY_PVT.DELETE_SET_HISTORY( p_line_id     => l_line_rec.line_id, x_return_status => l_return_status);

	 IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  'AFTER DELETE_SET_HISTORY ' || l_return_status , 1 ) ;
	 END IF;

    END IF;

  END IF;



  IF l_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_CONFIG THEN


   IF   OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
   AND  MSC_ATP_GLOBAL.GET_APS_VERSION = 10
   AND  l_line_rec.ato_line_id IS NOT NULL
   AND  l_line_rec.ato_line_id <> l_line_rec.line_id THEN

     BEGIN

     Select 'Y'
       Into l_ato_exists
     From oe_order_lines_all
     Where line_id = l_line_rec.ato_line_id;
     EXCEPTION

       WHEN OTHERS THEN

      l_ato_exists := 'N';

     END;
     IF l_ato_exists = 'Y' THEN

      l_request_search_rslt :=
          OE_Delayed_Requests_PVT.Check_For_Request
          (p_entity_code    => OE_GLOBALS.G_ENTITY_LINE,
           p_entity_id      => l_line_rec.ato_line_id,
           p_request_type   => OE_GLOBALS.G_SCHEDULE_ATO);


        IF l_request_search_rslt THEN
             Return;
        END IF;

    -- Log request.
        OE_Delayed_Requests_Pvt.Log_Request
       (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
        p_entity_id              => l_line_rec.ato_line_id,
        p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
        p_requesting_entity_id   => l_line_rec.line_id,
        p_request_type           => OE_GLOBALS.G_SCHEDULE_ATO,
        p_param1               => OE_Schedule_Util.OESCH_ACT_RESCHEDULE,
        p_param2                 => l_line_rec.top_model_line_id,
        p_param3                 => l_line_rec.ship_from_org_id,
        p_param4                 => l_line_rec.ship_to_org_id,
        p_param5                 => l_line_rec.shipping_method_code,
        p_param6                 => l_line_rec.demand_class_code,
        p_param7                 => l_line_rec.ship_from_org_id,
        p_param8                 => l_line_rec.demand_class_code,
        p_param11                => l_line_rec.override_atp_date_code,
        p_date_param1            => l_line_rec.request_date,
        p_date_param2            => l_line_rec.schedule_ship_date,
        p_date_param3            => l_line_rec.schedule_arrival_date,
        p_date_param4            => l_line_rec.request_date,
        p_date_param5            => l_line_rec.schedule_ship_date,
        p_date_param6            => l_line_rec.schedule_arrival_date,
        p_param12                => 'DELETE',
        p_param14                => l_line_rec.ship_set_id,
        p_param13                => l_line_rec.arrival_set_id,
        p_param15              => l_line_rec.ship_model_complete_flag,
        p_param25                => l_line_rec.header_id,
        x_return_status          => l_return_status);

    END IF; -- Exists


   ELSE -- Not an ato child

     -- Start 2691579
     l_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'Operation '||l_line_rec.operation , 1 ) ;
     END IF;
     -- End 2691579

     Action_Undemand(p_old_line_rec  => l_line_rec,
                     x_return_status => l_return_status);

   END IF; -- GOP CODE LEVEL

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_SCHEDULE_UTIL.DELETE_ROW' , 1 ) ;
  END IF;
EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_row'
            );
        END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Delete_Row;
/*---------------------------------------------------------------------
Procedure Name : Transfer_reservation
Description    : This API calls Inventory's APIs to Transfer_reservation.
--------------------------------------------------------------------- */

Procedure Transfer_reservation
( p_rsv_rec              IN  inv_reservation_global.mtl_reservation_rec_type
 ,p_quantity_to_transfer IN  NUMBER
 ,p_quantity2_to_transfer IN  NUMBER DEFAULT 0
 ,p_line_to_transfer     IN  NUMBER
,x_return_status OUT NOCOPY VARCHAR2)

IS
l_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(240);
l_rsv_id              NUMBER;
l_dummy_sn            inv_reservation_global.serial_number_tbl_type;
l_buffer              VARCHAR2(2000);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
                                    IF l_debug_level  > 0 THEN
                                        oe_debug_pub.add(  'ENTERING TRANSFER_RESERVATION LINE :' || P_QUANTITY_TO_TRANSFER , 1 ) ;
                                        oe_debug_pub.add(  'TRANSFER_RESERVATION LINE qty2 :' || P_QUANTITY2_TO_TRANSFER , 1 ) ;
                                    END IF;
                             IF l_debug_level  > 0 THEN
                                 oe_debug_pub.add(  'TOTAL RESERVATION ON THE LINE :' || P_RSV_REC.RESERVATION_QUANTITY , 1 ) ;
                                                                 oe_debug_pub.add(  'TOTAL RESERVATION qty2 ON THE LINE :' || P_RSV_REC.SECONDARY_RESERVATION_QUANTITY , 1 ) ;
                             END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' LINE :' || P_LINE_TO_TRANSFER , 1 ) ;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_rsv_rec := p_rsv_rec;
   l_rsv_rec.reservation_id := fnd_api.g_miss_num;
   l_rsv_rec.demand_source_line_id := p_line_to_transfer;
   --- Start 2346233 --
   --l_rsv_rec.reservation_quantity :=  p_quantity_to_transfer;
   --l_rsv_rec.primary_reservation_quantity := fnd_api.g_miss_num;
   l_rsv_rec.primary_reservation_quantity :=  p_quantity_to_transfer;
   l_rsv_rec.secondary_reservation_quantity :=  p_quantity2_to_transfer; -- INVCONV

   l_rsv_rec.reservation_quantity := fnd_api.g_miss_num;
   l_rsv_rec.secondary_reservation_quantity := fnd_api.g_miss_num; -- INVCONV
   --- End 2346233 --

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CALLING INVS TRANSFER RESERVATION' , 1 ) ;
   END IF;

   inv_reservation_pub.Transfer_reservation
   ( p_api_version_number        => 1.0
   , p_init_msg_lst              => FND_API.G_TRUE
   , x_return_status             => x_return_status
   , x_msg_count                 => l_msg_count
   , x_msg_data                  => l_msg_data
   , p_original_rsv_rec          => p_rsv_rec
   , p_to_rsv_rec                => l_rsv_rec
   , p_original_serial_number    => l_dummy_sn
   , p_to_serial_number          => l_dummy_sn
   , p_validation_flag           => FND_API.G_FALSE
   , x_to_reservation_id         => l_rsv_id);

                                             IF l_debug_level  > 0 THEN
                                                 oe_debug_pub.add(  '2. AFTER CALLING TRANSFER RESERVATION' || X_RETURN_STATUS , 1 ) ;
                                             END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
   END IF;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      oe_msg_pub.transfer_msg_stack;
      l_msg_count:=OE_MSG_PUB.COUNT_MSG;
      for I in 1..l_msg_count loop
         l_msg_data := OE_MSG_PUB.Get(I,'F');
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
         END IF;
      end loop;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      oe_msg_pub.transfer_msg_stack;
      l_msg_count:=OE_MSG_PUB.COUNT_MSG;
      for I in 1..l_msg_count loop
          l_msg_data := OE_MSG_PUB.Get(I,'F');
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
          END IF;
      end loop;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

                                          IF l_debug_level  > 0 THEN
                                              oe_debug_pub.add(  'EXITING TRANSFER RESERVATION' || X_RETURN_STATUS , 1 ) ;
                                          END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     oe_msg_pub.transfer_msg_stack;
     l_msg_count:=OE_MSG_PUB.COUNT_MSG;
     for I in 1..l_msg_count loop
        l_msg_data := OE_MSG_PUB.Get(I,'F');
        oe_msg_pub.add_text(l_msg_data);
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INV : ' || L_MSG_DATA , 2 ) ;
        END IF;
     end loop;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Transfer_reservation'
       );
    END IF;

END Transfer_reservation;

PROCEDURE Set_Auto_Sch_Flag
(p_value_from_user  IN VARCHAR2 := FND_API.G_MISS_CHAR)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_VALUE_FROM_USER ' || P_VALUE_FROM_USER , 1 ) ;
    END IF;
    OESCH_AUTO_SCH_FLAG := p_value_from_user;
END Set_Auto_Sch_Flag;

--Bug 5948059
FUNCTION Get_Auto_Sch_Flag
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'In Get_Auto_Sch_Flag' ) ;
        oe_debug_pub.add(  'OESCH_AUTO_SCH_FLAG: '||OESCH_AUTO_SCH_FLAG);
    END IF;
    RETURN (OESCH_AUTO_SCH_FLAG);
END;
/* Function find line

  This is be used to find the line in the pl/sql table.
*/
FUNCTION Find_line( p_x_line_tbl  IN OE_ORDER_PUB.Line_Tbl_Type,
                    p_line_id     IN  NUMBER)
Return BOOLEAN
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING FIND_LINE: ' || P_LINE_ID , 1 ) ;
  END IF;
  IF p_x_line_tbl.count > 0 THEN --8706868
    FOR J IN 1..p_x_line_tbl.count LOOP

      IF p_line_id = p_x_line_tbl(J).line_id THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' LINE EXISTS IN THE TABLE' , 1 ) ;
         END IF;

         RETURN TRUE;
      END IF;
   END LOOP;
 END IF; -- 8706868
 RETURN FALSE;

END Find_line;

/*PROCEDURE PROCESS_SPLIT
  This procedure will be used to call mrp with appropriate records:
  If the ato model is part of SMC, then Whome smc model will be called
  If the ato model is part of set, then whole set information will
  be passed to MRP and so on */

PROCEDURE PROCESS_SPLIT
(p_x_line_tbl  IN  OE_ORDER_PUB.Line_Tbl_Type,
 x_return_status OUT NOCOPY VARCHAR2)

IS
l_line_tbl              OE_ORDER_PUB.line_tbl_type;
l_local_line_tbl        OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl          OE_ORDER_PUB.line_tbl_type; -- 8706868
l_mrp_line_tbl          OE_ORDER_PUB.line_tbl_type; -- 8706868
l_non_mrp_line_tbl      OE_ORDER_PUB.line_tbl_type; -- 8706868
l_old_mrp_line_tbl          OE_ORDER_PUB.line_tbl_type; -- 8706868
l_order_date_type_code  VARCHAR2(20); -- 8706868
l_rsv_update            BOOLEAN :=FALSE; --8706868
K                       NUMBER;
I                       NUMBER;
L                       NUMBER := 0;
M                       NUMBER := 0;
l_ato_line_id           NUMBER;
l_entity                VARCHAR2(30);

-- MRP API variables
l_session_id            NUMBER := 0;
l_mrp_atp_rec           MRP_ATP_PUB.ATP_Rec_Typ;
l_out_mtp_atp_rec       MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_supply_demand     MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period            MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details           MRP_ATP_PUB.ATP_Details_Typ;
mrp_msg_data            VARCHAR2(200);
l_on_hand_qty           NUMBER;
l_avail_to_reserve      NUMBER;
l_out_atp_tbl           OE_ATP.atp_tbl_type;
l_found                 BOOLEAN := FALSE;
l_buffer                VARCHAR2(2000);
l_msg_count             NUMBER;
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_set_rec               OE_ORDER_CACHE.set_rec_type;
l_sales_order_id        NUMBER; --8706868
l_need_scheduling       BOOLEAN :=FALSE; --8706868

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING PROCESS SPLIT'||p_x_line_tbl.count , 1 ) ;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   K := 0;

   --l_line_tbl := p_x_line_tbl;

   FOR I IN 1..p_x_line_tbl.count LOOP

    IF NOT find_line(p_x_line_tbl => l_line_tbl,
                     p_line_id    => p_x_line_tbl(I).line_id)
    THEN
     -- 8988079 : Restrict shipped lines
     IF p_x_line_tbl(I).schedule_status_code is not null
      AND p_x_line_tbl(I).shipped_quantity is null
      AND p_x_line_tbl(I).fulfilled_quantity IS NULL THEN -- 2680748 to restrict unscheduled lines

        l_order_date_type_code := NVL(oe_schedule_util.Get_Date_Type(p_x_line_tbl(I).header_id),'SHIP'); -- 8706868
        IF p_x_line_tbl(I).arrival_set_id is not null THEN

           OE_Set_Util.Query_Set_Rows(p_set_id   => p_x_line_tbl(I).arrival_set_id,
                                 x_line_tbl => l_local_line_tbl);

           l_set_rec := OE_ORDER_CACHE.Load_Set
                         (p_x_line_tbl(I).arrival_set_id);

           FOR L IN 1..l_local_line_tbl.count LOOP

              K := K +1;
              l_line_tbl(K) := l_local_line_tbl(L);
              --8706868
               IF NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).request_date
                       ,l_line_tbl(K).request_date)  AND
                   p_x_line_tbl(I).split_by <>'SYSTEM' AND --10253393
		   NVL(p_x_line_tbl(I).SPLIT_REQUEST_DATE,'N') = 'Y' THEN  -- 10278858
                  --l_order_date_type_code := NVL(oe_schedule_util.Get_Date_Type(l_line_tbl(K).header_id),'SHIP');
                  IF NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_REQUEST_DATE_FLAG'),'Y') = 'Y' THEN --12833832
                     IF l_order_date_type_code = 'SHIP' THEN
                       -- Its a scheduled line. Reschedule with new date
                        l_line_tbl(K).schedule_ship_date := p_x_line_tbl(I).request_date;
                     ELSE
                        l_line_tbl(K).schedule_arrival_date :=p_x_line_tbl(I).request_date;
                     END IF;
                  END IF;
                  l_line_tbl(K).request_date := p_x_line_tbl(I).request_date;
               END IF;
               IF p_x_line_tbl(I).ship_from_org_id IS NOT NULL AND
                  p_x_line_tbl(I).ship_from_org_id <> fnd_api.G_MISS_NUM AND
                  NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).ship_from_org_id
                                      ,l_line_tbl(K).ship_from_org_id) AND
		  NVL(p_x_line_tbl(I).SPLIT_SHIP_FROM,'N') = 'Y' THEN -- 10278858
                  -- Unreserve the line as warehouse being chabged and reservation is there.
 	          l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id(l_line_tbl(K).HEADER_ID);
		       OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                           ,p_line_id   => l_line_tbl(K).line_id
                                           ,p_org_id    => l_line_tbl(K).ship_from_org_id
                                           ,p_order_quantity_uom => l_line_tbl(K).order_quantity_uom
                                           ,x_reserved_quantity =>  l_line_tbl(K).reserved_quantity
                                           ,x_reserved_quantity2 => l_line_tbl(K).reserved_quantity2
                                           );
                      IF NVL(l_line_tbl(K).reserved_quantity,0) >0  THEN
		         OE_SCHEDULE_UTIL.Unreserve_Line
                                 (p_line_rec              => l_line_tbl(K),
                                  p_quantity_to_unreserve => l_line_tbl(K).reserved_quantity,
                                  p_quantity2_to_unreserve =>l_line_tbl(K).reserved_quantity2 , -- INVCONV
                                  x_return_status         => l_return_status);
                        l_line_tbl(K).reserved_quantity :=0;
			l_line_tbl(K).reserved_quantity2 :=0;
			oe_schedule_util.oe_split_rsv_tbl(MOD(l_line_tbl(K).line_id,G_BINARY_LIMIT)).line_id :=l_line_tbl(K).line_id;
                      END IF;

                  l_line_tbl(K).ship_from_org_id := p_x_line_tbl(I).ship_from_org_id;
               END IF;
	       IF p_x_line_tbl(I).ship_to_org_id IS NOT NULL AND
                  p_x_line_tbl(I).ship_to_org_id <> fnd_api.G_MISS_NUM AND
                  NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).ship_to_org_id
                                      ,l_line_tbl(K).ship_to_org_id) AND
	          NVL(p_x_line_tbl(I).SPLIT_SHIP_TO,'N') = 'Y' THEN -- 10278858
                  l_line_tbl(K).ship_to_org_id := p_x_line_tbl(I).ship_to_org_id;
               END IF;
	       IF l_line_tbl(K).line_id = p_x_line_tbl(I).line_id THEN
  	          l_line_tbl(K).operation := p_x_line_tbl(I).operation;
               ELSE
                  l_line_tbl(K).operation := oe_globals.g_opr_update;
               END IF;
              --8706868
              l_line_tbl(K).schedule_action_code :=
                           OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE;
              l_line_tbl(K).arrival_set := l_set_rec.set_name;

           END LOOP;

           l_local_line_tbl.delete;

        ELSIF p_x_line_tbl(I).ship_set_id is not null THEN


           OE_Set_Util.Query_Set_Rows(p_set_id   => p_x_line_tbl(I).ship_set_id,
                                 x_line_tbl => l_local_line_tbl);

           l_set_rec := OE_ORDER_CACHE.Load_Set
                         (p_x_line_tbl(I).ship_set_id);
           FOR L IN 1..l_local_line_tbl.count LOOP

              K := K +1;
              l_line_tbl(K) := l_local_line_tbl(L);
              --8706868
               IF NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).request_date
                       ,l_line_tbl(K).request_date) AND
		       NVL(p_x_line_tbl(I).SPLIT_REQUEST_DATE,'N') = 'Y' THEN --10278858
                  --l_order_date_type_code := NVL(oe_schedule_util.Get_Date_Type(l_line_tbl(K).header_id),'SHIP');
                  IF NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_REQUEST_DATE_FLAG'),'Y') = 'Y' THEN --12833832
                     IF l_order_date_type_code = 'SHIP' THEN
                        -- Its a scheduled line. Reschedule with new date
                        l_line_tbl(K).schedule_ship_date := p_x_line_tbl(I).request_date;
                     ELSE
                        l_line_tbl(K).schedule_arrival_date :=p_x_line_tbl(I).request_date;
                     END IF;
                  END IF;
                  l_line_tbl(K).request_date := p_x_line_tbl(I).request_date;
               END IF;
               IF p_x_line_tbl(I).ship_from_org_id IS NOT NULL AND
                  p_x_line_tbl(I).ship_from_org_id <> fnd_api.G_MISS_NUM AND
                  NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).ship_from_org_id
                                      ,l_line_tbl(K).ship_from_org_id) AND
	          NVL(p_x_line_tbl(I).SPLIT_SHIP_FROM,'N') = 'Y' THEN -- 10278858
                  -- Unreserve the line as warehouse being chabged and reservation is there.
 	          l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id(l_line_tbl(K).HEADER_ID);
		       OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                           ,p_line_id   => l_line_tbl(K).line_id
                                           ,p_org_id    => l_line_tbl(K).ship_from_org_id
                                           ,p_order_quantity_uom => l_line_tbl(K).order_quantity_uom
                                           ,x_reserved_quantity =>  l_line_tbl(K).reserved_quantity
                                           ,x_reserved_quantity2 => l_line_tbl(K).reserved_quantity2
                                           );
                      IF NVL(l_line_tbl(K).reserved_quantity,0) >0  THEN
		         OE_SCHEDULE_UTIL.Unreserve_Line
                                 (p_line_rec              => l_line_tbl(K),
                                  p_quantity_to_unreserve => l_line_tbl(K).reserved_quantity,
                                  p_quantity2_to_unreserve =>l_line_tbl(K).reserved_quantity2 , -- INVCONV
                                  x_return_status         => l_return_status);
                        l_line_tbl(K).reserved_quantity :=0;
			l_line_tbl(K).reserved_quantity2 :=0;
			oe_schedule_util.oe_split_rsv_tbl(MOD(l_line_tbl(K).line_id,G_BINARY_LIMIT)).line_id :=l_line_tbl(K).line_id;
                      END IF;
                  l_line_tbl(K).ship_from_org_id := p_x_line_tbl(I).ship_from_org_id;
               END IF;
	       IF p_x_line_tbl(I).ship_to_org_id IS NOT NULL AND
                  p_x_line_tbl(I).ship_to_org_id <> fnd_api.G_MISS_NUM AND
                  NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).ship_to_org_id
                                      ,l_line_tbl(K).ship_to_org_id) AND
 	          NVL(p_x_line_tbl(I).SPLIT_SHIP_TO,'N') = 'Y' THEN -- 10278858
                  l_line_tbl(K).ship_to_org_id := p_x_line_tbl(I).ship_to_org_id;
               END IF;
	       IF l_line_tbl(K).line_id = p_x_line_tbl(I).line_id THEN
  	          l_line_tbl(K).operation := p_x_line_tbl(I).operation;
               ELSE
                  l_line_tbl(K).operation := oe_globals.g_opr_update;
               END IF;
              --8706868
              l_line_tbl(K).schedule_action_code :=
                           OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE;

              l_line_tbl(K).ship_set := l_set_rec.set_name;
           END LOOP;

           l_local_line_tbl.delete;

        ELSIF p_x_line_tbl(I).ship_model_complete_flag ='Y'
             AND   nvl(p_x_line_tbl(I).model_remnant_flag,'N') = 'N' THEN


           OE_Config_Util.Query_Options
           (p_top_model_line_id => p_x_line_tbl(I).top_model_line_id,
            x_line_tbl          => l_local_line_tbl);


           FOR L IN 1..l_local_line_tbl.count LOOP

              K := K +1;
              l_line_tbl(K) := l_local_line_tbl(L);
                /*
               IF NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).request_date
                       ,l_line_tbl(K).request_date) THEN
                  --l_order_date_type_code := NVL(oe_schedule_util.Get_Date_Type(l_line_tbl(K).header_id),'SHIP');
                  IF l_order_date_type_code = 'SHIP' THEN
                     -- Its a scheduled line. Reschedule with new date
                     l_line_tbl(K).schedule_ship_date := p_x_line_tbl(I).request_date;
                  ELSE
                     l_line_tbl(K).schedule_arrival_date :=p_x_line_tbl(I).request_date;
                  END IF;
                  l_line_tbl(K).request_date := p_x_line_tbl(I).request_date;
               END IF;
               IF p_x_line_tbl(I).ship_from_org_id IS NOT NULL AND
                  p_x_line_tbl(I).ship_from_org_id <> fnd_api.G_MISS_NUM AND
                  NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).ship_from_org_id
                                      ,l_line_tbl(K).ship_from_org_id)THEN
                  -- Unreserve the line as warehouse being chabged and reservation is there.
 	          l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id(l_line_tbl(K).HEADER_ID);
		       OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                           ,p_line_id   => l_line_tbl(K).line_id
                                           ,p_org_id    => l_line_tbl(K).ship_from_org_id
                                           ,p_order_quantity_uom => l_line_tbl(K).order_quantity_uom
                                           ,x_reserved_quantity =>  l_line_tbl(K).reserved_quantity
                                           ,x_reserved_quantity2 => l_line_tbl(K).reserved_quantity2
                                           );
                      IF l_line_tbl(K).reserved_quantity is not null THEN
		         OE_SCHEDULE_UTIL.Unreserve_Line
                                 (p_line_rec              => l_line_tbl(K),
                                  p_quantity_to_unreserve => l_line_tbl(K).reserved_quantity,
                                  p_quantity2_to_unreserve =>l_line_tbl(K).reserved_quantity2 , -- INVCONV
                                  x_return_status         => l_return_status);
                        l_line_tbl(K).reserved_quantity :=0;
			l_line_tbl(K).reserved_quantity2 :=0;
                      END IF;
                  l_line_tbl(K).ship_from_org_id := p_x_line_tbl(I).ship_from_org_id;
               END IF;
	       IF p_x_line_tbl(I).ship_to_org_id IS NOT NULL AND
                  p_x_line_tbl(I).ship_to_org_id <> fnd_api.G_MISS_NUM AND
                  NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).ship_to_org_id
                                      ,l_line_tbl(K).ship_to_org_id)THEN
                  l_line_tbl(K).ship_to_org_id := p_x_line_tbl(I).ship_to_org_id;
               END IF;
	       IF l_line_tbl(K).line_id = p_x_line_tbl(I).line_id THEN
  	          l_line_tbl(K).operation := p_x_line_tbl(I).operation;
               ELSE
                  l_line_tbl(K).operation := oe_globals.g_opr_update;
               END IF;
              */
              l_line_tbl(K).schedule_action_code :=
                           OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE;
              l_line_tbl(K).ship_set := p_x_line_tbl(I).top_model_line_id;
              l_line_tbl(K).operation := p_x_line_tbl(I).operation; --Bug 14106410

           END LOOP;

           l_local_line_tbl.delete;

        ELSIF p_x_line_tbl(I).ato_line_id is not null
             AND   p_x_line_tbl(I).item_type_code <> 'STANDARD'
             AND   nvl(p_x_line_tbl(I).model_remnant_flag,'N') = 'N' THEN

            Begin

               Select ato_line_id
               Into   l_ato_line_id
               From   oe_order_lines_all
               Where  line_id = p_x_line_tbl(I).line_id;
            EXCEPTION

               WHEN OTHERS THEN

                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END;

            OE_Config_Util.Query_ATO_Options
            (p_ato_line_id => l_ato_line_id,
            x_line_tbl    => l_local_line_tbl);


            FOR L IN 1..l_local_line_tbl.count LOOP

               K := K +1;
               l_line_tbl(K) := l_local_line_tbl(L);
               /*
               IF NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).request_date
                       ,l_line_tbl(K).request_date) THEN
                  --l_order_date_type_code := NVL(oe_schedule_util.Get_Date_Type(l_line_tbl(K).header_id),'SHIP');
                  IF l_order_date_type_code = 'SHIP' THEN
                     -- Its a scheduled line. Reschedule with new date
                     l_line_tbl(K).schedule_ship_date := p_x_line_tbl(I).request_date;
                  ELSE
                     l_line_tbl(K).schedule_arrival_date :=p_x_line_tbl(I).request_date;
                  END IF;
                  l_line_tbl(K).request_date := p_x_line_tbl(I).request_date;
               END IF;
               IF p_x_line_tbl(I).ship_from_org_id IS NOT NULL AND
                  p_x_line_tbl(I).ship_from_org_id <> fnd_api.G_MISS_NUM AND
                  NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).ship_from_org_id
                                      ,l_line_tbl(K).ship_from_org_id)THEN
                  -- Unreserve the line as warehouse being chabged and reservation is there.
 	          l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id(l_line_tbl(K).HEADER_ID);
		       OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                           ,p_line_id   => l_line_tbl(K).line_id
                                           ,p_org_id    => l_line_tbl(K).ship_from_org_id
                                           ,p_order_quantity_uom => l_line_tbl(K).order_quantity_uom
                                           ,x_reserved_quantity =>  l_line_tbl(K).reserved_quantity
                                           ,x_reserved_quantity2 => l_line_tbl(K).reserved_quantity2
                                           );
                      IF l_line_tbl(K).reserved_quantity is not null THEN
		         OE_SCHEDULE_UTIL.Unreserve_Line
                                 (p_line_rec              => l_line_tbl(K),
                                  p_quantity_to_unreserve => l_line_tbl(K).reserved_quantity,
                                  p_quantity2_to_unreserve =>l_line_tbl(K).reserved_quantity2 , -- INVCONV
                                  x_return_status         => l_return_status);
                        l_line_tbl(K).reserved_quantity :=0;
			l_line_tbl(K).reserved_quantity2 :=0;
                      END IF;
                  l_line_tbl(K).ship_from_org_id := p_x_line_tbl(I).ship_from_org_id;
               END IF;
	       IF p_x_line_tbl(I).ship_to_org_id IS NOT NULL AND
                  p_x_line_tbl(I).ship_to_org_id <> fnd_api.G_MISS_NUM AND
                  NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).ship_to_org_id
                                      ,l_line_tbl(K).ship_to_org_id)THEN
                  l_line_tbl(K).ship_to_org_id := p_x_line_tbl(I).ship_to_org_id;
               END IF;
	       IF l_line_tbl(K).line_id = p_x_line_tbl(I).line_id THEN
  	          l_line_tbl(K).operation := p_x_line_tbl(I).operation;
               ELSE
                  l_line_tbl(K).operation := oe_globals.g_opr_update;
               END IF;
               */
               l_line_tbl(K).schedule_action_code :=
                           OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE;
               l_line_tbl(K).ship_set := l_ato_line_id;
               l_line_tbl(K).operation := p_x_line_tbl(I).operation; --Bug 14106410

           END LOOP;

           l_local_line_tbl.delete;


        ELSE

           K := K +1;
           l_line_tbl(K) := p_x_line_tbl(I);
           l_line_tbl(K).schedule_action_code :=
                        OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE;


        END IF;
      ELSE --10072873
	 K := K +1;
         l_line_tbl(K) := p_x_line_tbl(I);
      END IF;  -- 2680748

    END IF; -- line is not part of the local table.
   END LOOP;
   IF l_line_tbl.count > 0 THEN
      null;
   ELSE
      l_line_tbl :=p_x_line_tbl;
   END IF;
   l_old_line_tbl  := l_line_tbl; --8706868
   FOR I IN 1..p_x_line_tbl.count LOOP
     IF p_x_line_tbl(I).item_type_code = 'MODEL' OR
        p_x_line_tbl(I).item_type_code = 'KIT' THEN --OR
      -- p_x_line_tbl(I).ship_set_id is not null OR
      -- p_x_line_tbl(I).arrival_set_id is not null THEN

         FOR J in 1..l_line_tbl.count LOOP
            IF (p_x_line_tbl(I).line_id = l_line_tbl(J).TOP_MODEL_LINE_ID) AND
	    l_line_tbl(J).LINE_ID <> l_line_tbl(J).TOP_MODEL_LINE_ID AND
	    (p_x_line_tbl(I).ship_set_id IS NULL OR p_x_line_tbl(I).arrival_set_id IS NULL) THEN
	 --   OR ((p_x_line_tbl(I).ship_set_id = l_line_tbl(J).ship_set_id OR
	 --    p_x_line_tbl(I).arrival_set_id = l_line_tbl(J).arrival_set_id) AND
	 --    l_line_tbl(J).TOP_MODEL_LINE_ID IS NULL) THEN
	     --8706868
             --10253393: Assign the request date if its not a system split
               IF NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).request_date
                       ,l_line_tbl(J).request_date) AND
		       p_x_line_tbl(I).request_date IS NOT NULL AND --10072873
                       p_x_line_tbl(I).split_by <>'SYSTEM' AND  --10253393
		       NVL(p_x_line_tbl(I).SPLIT_REQUEST_DATE,'N') = 'Y' THEN  -- 10278858
                  IF l_line_tbl(J).schedule_ship_date is NOT NULL AND
                      NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_REQUEST_DATE_FLAG'),'Y') = 'Y' THEN --12833832
                     l_order_date_type_code := NVL(oe_schedule_util.Get_Date_Type(l_line_tbl(J).header_id),'SHIP');
                     IF l_order_date_type_code = 'SHIP' THEN
                     -- Its a scheduled line. Reschedule with new date
                        l_line_tbl(J).schedule_ship_date := p_x_line_tbl(I).request_date;
                     ELSE
                        l_line_tbl(J).schedule_arrival_date :=p_x_line_tbl(I).request_date;
                     END IF;
                  END IF;
                  l_line_tbl(J).request_date := p_x_line_tbl(I).request_date;
               END IF;
               IF p_x_line_tbl(I).ship_from_org_id IS NOT NULL AND
                  p_x_line_tbl(I).ship_from_org_id <> fnd_api.G_MISS_NUM AND
                  NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).ship_from_org_id
                                      ,l_line_tbl(J).ship_from_org_id) AND
	          NVL(p_x_line_tbl(I).SPLIT_SHIP_FROM,'N') = 'Y' THEN -- 10278858
                   -- Unreserve the line as warehouse being chabged and reservation is there.
		    IF l_line_tbl(J).schedule_ship_date is NOT NULL then  --9662817
		  --  AND l_line_tbl(J).operation = oe_globals.g_opr_update  THEN
		       l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id(l_line_tbl(J).HEADER_ID);
		       BEGIN
		       OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                           ,p_line_id   => l_line_tbl(J).line_id
                                           ,p_org_id    => l_line_tbl(J).ship_from_org_id
                                           ,p_order_quantity_uom => l_line_tbl(J).order_quantity_uom
                                           ,x_reserved_quantity =>  l_line_tbl(J).reserved_quantity
                                           ,x_reserved_quantity2 => l_line_tbl(J).reserved_quantity2
                                           );
                      EXCEPTION
 		        WHEN OTHERS THEN
                         l_line_tbl(J).reserved_quantity :=0;
			 l_line_tbl(J).reserved_quantity2 :=0;
                      END;
                      IF NVL(l_line_tbl(J).reserved_quantity,0) >0  THEN
		         OE_SCHEDULE_UTIL.Unreserve_Line
                                 (p_line_rec              => l_line_tbl(J),
                                  p_quantity_to_unreserve => l_line_tbl(J).reserved_quantity,
                                  p_quantity2_to_unreserve =>l_line_tbl(J).reserved_quantity2 , -- INVCONV
                                  x_return_status         => l_return_status);
                        l_line_tbl(J).reserved_quantity :=0;
			l_line_tbl(J).reserved_quantity2 :=0;
			oe_schedule_util.oe_split_rsv_tbl(MOD(l_line_tbl(J).line_id,G_BINARY_LIMIT)).line_id :=l_line_tbl(J).line_id;
                      END IF;

		  END IF;
		  l_line_tbl(J).ship_from_org_id := p_x_line_tbl(I).ship_from_org_id;
		  l_line_tbl(J).subinventory:= null;
               END IF;
	       IF p_x_line_tbl(I).ship_to_org_id IS NOT NULL AND
                  p_x_line_tbl(I).ship_to_org_id <> fnd_api.G_MISS_NUM AND
                  NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).ship_to_org_id
                                      ,l_line_tbl(J).ship_to_org_id) AND
		  NVL(p_x_line_tbl(I).SPLIT_SHIP_TO,'N') = 'Y' THEN -- 10278858
				      oe_debug_pub.add(  'Next for 4');
                  l_line_tbl(J).ship_to_org_id := p_x_line_tbl(I).ship_to_org_id;
               END IF;
	       IF l_line_tbl(J).line_id = p_x_line_tbl(I).line_id THEN
  	          l_line_tbl(J).operation := p_x_line_tbl(I).operation;
               ELSE
                  l_line_tbl(J).operation := oe_globals.g_opr_update;
		  oe_debug_pub.add(  'Next for 10');
               END IF;
	       IF l_line_tbl(J).schedule_ship_date is NOT NULL THEN
	         l_line_tbl(J).schedule_action_code :=
                           OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE;
                 l_need_scheduling := TRUE;
		 oe_debug_pub.add(  'Next for 14');
               END IF;
	       --8706868
            END IF;
	 END LOOP;
    END IF; --Model check
   END LOOP;

--   G_OVERRIDE_FLAG := 'N'; -- 8706868 -- 'Y';
   l_old_line_tbl  := l_line_tbl; --8706868
   IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'LINE COUNT '||l_line_tbl.count,1);
   END IF;
   IF l_line_tbl.count > 0  THEN
      FOR I in 1..l_line_tbl.count LOOP
         --10038568 restrict return lines.
	 --10208311 do not check shipped Qty and Fulfilled qty if its a system split
         IF ((l_line_tbl(I).shipped_quantity is null AND -- 9465045
            l_line_tbl(I).fulfilled_quantity IS NULL) OR --10072873
	    l_line_tbl(I).split_by = 'SYSTEM') AND
            l_line_tbl(I).source_type_code = OE_GLOBALS.G_SOURCE_INTERNAL AND
            l_line_tbl(I).item_type_code <> OE_GLOBALS.G_ITEM_SERVICE AND
            l_line_tbl(I).line_category_code <>  'RETURN' AND
            l_line_tbl(I).schedule_ship_date IS NOT NULL AND
            (Nvl(l_line_tbl(I).bypass_sch_flag, 'N') = 'N' --DOO Integraton
             OR l_line_tbl(I).bypass_sch_flag =FND_API.G_MISS_CHAR) THEN -- 13392107
	    L := L+1;
	    l_mrp_line_tbl(L):=l_line_tbl(I);
            --11694571
            -- If its a user split and there is change to split attributes then
            -- reschedule in override mode.
            IF l_line_tbl(I).split_by = 'USER' AND
              (NVL(l_line_tbl(I).SPLIT_REQUEST_DATE,'N') = 'N' OR
                (NVL(l_line_tbl(I).SPLIT_REQUEST_DATE,'N') = 'Y' AND
                 NVL(OE_SYS_PARAMETERS.value('RESCHEDULE_REQUEST_DATE_FLAG'),'Y') = 'N')) AND --12833832
              NVL(l_line_tbl(I).SPLIT_SHIP_FROM,'N') = 'N' AND
              NVL(l_line_tbl(I).SPLIT_SHIP_TO,'N') = 'N' THEN

              l_mrp_line_tbl(L).override_atp_date_code := 'Y';
            END IF;

	    l_old_mrp_line_tbl(L):=l_line_tbl(I); --10072873
	    l_mrp_line_tbl(L).schedule_action_code :=
                           OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE;
	    l_need_scheduling := TRUE;
	    IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'MRP Line Id '||l_line_tbl(I).line_id,1);
	      oe_debug_pub.add(  'Req date '||l_line_tbl(I).request_date,1);
	      oe_debug_pub.add(  'Ship From '||l_line_tbl(I).ship_from_org_id,1);
            END IF;
	 ELSE
            M:= M+1;
	    l_non_mrp_line_tbl(M):=l_line_tbl(I);
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NON MRP Line Id '||l_line_tbl(I).line_id,1);
	      oe_debug_pub.add(  'Req date '||l_line_tbl(I).request_date,1);
	      oe_debug_pub.add(  'Ship From '||l_line_tbl(I).ship_from_org_id,1);
            END IF;
	 END IF;
      END LOOP;
      L :=0;
      /*
      FOR I in 1..l_old_line_tbl.count LOOP
          IF l_old_line_tbl(I).schedule_ship_date IS NOT NULL THEN
	     L:=L+1;
             l_old_mrp_line_tbl(L):=l_old_line_tbl(I);
	  END IF;
      END LOOP;
      */
      IF l_need_scheduling = TRUE THEN
        -- 8706868
        --Validate the line info
	--10208311 no need to call validate_group if its a system split
         IF l_line_tbl(1).split_by = 'SYSTEM' THEN
            l_return_status := FND_API.G_RET_STS_SUCCESS;
         ELSE
            OE_GROUP_SCH_UTIL.Validate_Group
             (p_x_line_tbl      => l_mrp_line_tbl,
              p_sch_action      => OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE,
              p_validate_action => 'COMPLETE',
              x_return_status   => l_return_status);


            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  ' AFTER VALIDATE_GROUP : '||l_return_status,1);
            END IF;
        END IF;
        IF l_return_status = FND_API.G_RET_STS_SUCCESS
                          AND l_mrp_line_tbl.count > 0 THEN --12757660

           IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SPLIT BEFORE CALLING LOAD_MRP_REQUEST' , 2 ) ;
           END IF;

           Load_MRP_request_from_tbl
           ( p_line_tbl          => l_mrp_line_tbl --l_line_tbl
            ,p_old_line_tbl      => l_old_mrp_line_tbl --l_old_line_tbl --8706868
            ,p_sch_action        => OESCH_ACT_RESCHEDULE
            ,x_mrp_atp_rec       => l_mrp_atp_rec);

           l_session_id := Get_Session_Id;

           -- Call ATP
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'COUNT IS ' || L_MRP_ATP_REC.ERROR_CODE.COUNT , 1 ) ;
           END IF;

           -- We are adding this so that we will not call MRP when
           -- table count is 0.

           IF l_mrp_atp_rec.error_code.count > 0 THEN

              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'SPLIT CALLING MRP API WITH SESSION ID '||L_SESSION_ID , 0.5 ) ;  -- debug level changed to 0.5 for bug 13435459
              END IF;

              MRP_ATP_PUB.Call_ATP
              (  p_session_id             =>  l_session_id
               , p_atp_rec                =>  l_mrp_atp_rec
               , x_atp_rec                =>  l_out_mtp_atp_rec
               , x_atp_supply_demand      =>  l_atp_supply_demand
               , x_atp_period             =>  l_atp_period
               , x_atp_details            =>  l_atp_details
               , x_return_status          =>  l_return_status
               , x_msg_data               =>  mrp_msg_data
               , x_msg_count              =>  l_msg_count);


             IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'SPLIT. AFTER CALLING MRP_ATP_PUB.CALL_ATP' || L_RETURN_STATUS ,0.5 ) ; -- debug level changed to 0.5 for bug 13435459
             END IF;

             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
             --10338643
             IF NVL(l_mrp_line_tbl(1).split_by,'USER') <> 'SYSTEM' THEN

                Load_Results_from_tbl
                (p_atp_rec        => l_out_mtp_atp_rec,
                 p_old_line_tbl   => l_old_mrp_line_tbl, --l_old_line_tbl,-- l_line_tbl, -- 8706868
                 p_x_line_tbl     => l_mrp_line_tbl, --l_line_tbl,
                 x_return_status  => l_return_status);
                --11694571
                FOR I in 1..l_mrp_line_tbl.count LOOP
                   l_mrp_line_tbl(I).override_atp_date_code := l_old_mrp_line_tbl(I).override_atp_date_code;
                   l_mrp_line_tbl(I).operation := oe_globals.g_opr_update; --14350185:MRP might return different warehouse or date
                END LOOP;

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
                END IF;
             --8706868
             END IF;
	     oe_config_schedule_pvt.Save_Sch_Attributes
                  ( p_x_line_tbl     => l_mrp_line_tbl
                   ,p_old_line_tbl   => l_old_mrp_line_tbl
                   ,p_sch_action     => OESCH_ACT_RESCHEDULE
                   ,p_caller         => OE_SCHEDULE_UTIL.SCH_EXTERNAL
                   ,x_return_status  => l_return_status);

             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
             END IF;
           END IF; -- MRP count check.
         END IF;
       END IF; -- need scheduling
       IF l_non_mrp_line_tbl.count >1 THEN
         l_local_line_tbl.delete;
	 l_local_line_tbl := l_non_mrp_line_tbl;
	 oe_config_schedule_pvt.Save_Sch_Attributes
                  ( p_x_line_tbl     => l_non_mrp_line_tbl --l_line_tbl
                   ,p_old_line_tbl   => l_local_line_tbl --l_line_tbl -- l_old_line_tbl
                   ,p_sch_action     => OESCH_ACT_RESCHEDULE
                   ,p_caller         => OE_SCHEDULE_UTIL.SCH_EXTERNAL
                   ,x_return_status  => l_return_status);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
       END IF;
   END IF; -- line count.

   G_OVERRIDE_FLAG := 'N';

   x_return_status := l_return_status;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING PROCESS SPLIT' , 1 ) ;
  END IF;
EXCEPTION
  -- 8706868
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'PROCESS_SPLIT'
            );
        END IF;

END PROCESS_SPLIT;

/*--------------------------------------------------------------------
Procedure Name : Split_Scheduling
Description    : The split API calls this procedure with a table of record.
                 There is an update line (the line which is getting split)
                 and multiple insert lines (new lines created due to the split).
                 We need to do the following:

                 For scheduling
                 -------------
                 On the updated line: Reschedule the line.
                 On the inserted lines: Schedule the lines.

                 For reservation
                 ---------------
                 If the split is due to shipping, we need to update the
                 reservations (whichever exist) to the new line which
                 got created.

                 If the split is due to the user splitting, there could be
                 multiple records created due to the split. We should update
                 the old reservation to reflect the change in qty for the
                 original line, and create new reservations for the new lines
                 which got created.


---------------------------------------------------------------------- */


Procedure SPLIT_SCHEDULING
( p_x_line_tbl         IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type
, x_return_status OUT NOCOPY VARCHAR2)

IS
l_rsv_qty               NUMBER := 0;
l_header_id             NUMBER;
l_line_id               NUMBER;
l_sales_order_id        NUMBER;
l_qty_to_retain         NUMBER;
l_x_error_code          NUMBER;
l_lock_records          VARCHAR2(1);
l_sort_by_req_date      NUMBER;
continue_loop           BOOLEAN;
K                       NUMBER;
J                       NUMBER;
l_reserved_quantity     NUMBER;
l_msg_count             NUMBER;
l_query_rsv_rec         inv_reservation_global.mtl_reservation_rec_type;
l_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
l_rsv_tbl               inv_reservation_global.mtl_reservation_tbl_type;
l_msg_data              VARCHAR2(240);
l_count                 NUMBER;
l_available_qty         NUMBER := 0;
--- 2346233 --
l_ordered_quantity      NUMBER;
l_rsv_qty_primary       NUMBER :=0;

-- INVCONV
l_reserved_quantity2     NUMBER;
l_ordered_quantity2      NUMBER;
l_rsv_qty_secondary      NUMBER :=0;
l_qty2_to_retain         NUMBER;
l_rsv_qty2               NUMBER := 0;
l_available_qty2         NUMBER := 0;
l_do_reservation         BOOLEAN :=FALSE; -- 8706868
l_line_found             BOOLEAN := FALSE; -- 8706868
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '31. ENTERING SPLIT_SCHEDULING' , 1 ) ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'PICTURE SENT ' , 1 ) ;
  END IF;

  FOR I IN 1..p_x_line_tbl.count LOOP
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE ID ' || P_X_LINE_TBL ( I ) .LINE_ID , 1 ) ;
          oe_debug_pub.add(  'SPLIT ID ' || P_X_LINE_TBL ( I ) .SPLIT_FROM_LINE_ID , 1 ) ;
          oe_debug_pub.add(  'SPLIT ACTION ' || P_X_LINE_TBL ( I ) .SPLIT_ACTION_CODE , 1 ) ;
          oe_debug_pub.add(  'OPERATIONS ' || P_X_LINE_TBL ( I ) .OPERATION , 1 ) ;
      END IF;
  END LOOP;
  IF p_x_line_tbl(1).split_by = 'SYSTEM' THEN
     G_OVERRIDE_FLAG     := 'Y';
  ELSE
     G_OVERRIDE_FLAG     := 'N'; --'Y'; --8706868
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'COUNT IS :' || P_X_LINE_TBL.COUNT , 1 ) ;
  END IF;

  process_split(p_x_line_tbl => p_x_line_tbl,
                x_return_status => x_return_status);

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN --8706868
  -- get the latest picture.9662817
 FOR I in 1..p_x_line_tbl.count LOOP
       IF p_x_line_tbl(I).item_type_code <> 'STANDARD' THEN --AND
          --p_x_line_tbl(I).schedule_status_code is not null THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE: ' || P_X_LINE_TBL ( I ) .LINE_ID , 1 ) ;
          END IF;
          SELECT schedule_ship_date,schedule_arrival_date,ship_from_org_id
          INTO p_x_line_tbl(I).schedule_ship_date,p_x_line_tbl(I).schedule_arrival_date,
               p_x_line_tbl(I).ship_from_org_id
          FROM OE_ORDER_LINES_ALL
          WHERE line_id=p_x_line_tbl(I).line_id;
       END IF;
  END LOOP;
  FOR I in 1..p_x_line_tbl.count LOOP
  /* --9615081
       IF p_x_line_tbl(I).item_type_code <> 'STANDARD' THEN --AND
          --p_x_line_tbl(I).schedule_status_code is not null THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE: ' || P_X_LINE_TBL ( I ) .LINE_ID , 1 ) ;
          END IF;
          SELECT schedule_ship_date,schedule_arrival_date,ship_from_org_id
          INTO p_x_line_tbl(I).schedule_ship_date,p_x_line_tbl(I).schedule_arrival_date,p_x_line_tbl(I).ship_from_org_id
          FROM OE_ORDER_LINES_ALL
          WHERE line_id=p_x_line_tbl(I).line_id;
       END IF;
       */
       IF p_x_line_tbl(I).operation = OE_GLOBALS.G_OPR_UPDATE AND
          p_x_line_tbl(I).schedule_status_code is not null AND
          p_x_line_tbl(I).split_action_code = 'SPLIT' THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SPLITTING SCHEDULING' , 1 ) ;
              oe_debug_pub.add(  'SPLITTING SCHEDULING FOR LINE: ' || P_X_LINE_TBL ( I ) .LINE_ID , 1 ) ;
          END IF;

          -- Only play with reservation if the line is not interfaced with
          -- shipping. Otherwise shipping will take care of transferring
          -- reservations.

          IF  (p_x_line_tbl(I).shipped_quantity is null)
          AND (nvl(p_x_line_tbl(I).shipping_interfaced_flag, 'N') = 'N')
	  AND (nvl(p_x_line_tbl(I).shippable_flag,'N') = 'Y')
          THEN

             -- We have updated the demand picture in MRP with the split.
             -- Now let's update the reservation picture.

             --      l_query_rsv_rec                := null;
             l_query_rsv_rec.reservation_id := fnd_api.g_miss_num;
             l_sales_order_id
                       := Get_mtl_sales_order_id(p_x_line_tbl(I).header_id);
             l_query_rsv_rec.demand_source_header_id  := l_sales_order_id;
             l_query_rsv_rec.demand_source_line_id    := p_x_line_tbl(I).line_id;

             -- 02-jun-2000 mpetrosi added org_id to query_reservation start
             l_query_rsv_rec.organization_id := p_x_line_tbl(I).ship_from_org_id;
             -- 02-jun-2000 mpetrosi added org_id to query_reservation end


             IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'CALLING INVS QUERY_RESERVATION ' , 1 ) ;
             END IF;

             inv_reservation_pub.query_reservation
              ( p_api_version_number       => 1.0
              , p_init_msg_lst              => fnd_api.g_true
              , x_return_status             => x_return_status
              , x_msg_count                 => l_msg_count
              , x_msg_data                  => l_msg_data
              , p_query_input               => l_query_rsv_rec
              , x_mtl_reservation_tbl       => l_rsv_tbl
              , x_mtl_reservation_tbl_count => l_count
              , x_error_code                => l_x_error_code
              , p_lock_records              => l_lock_records
              , p_sort_by_req_date          => l_sort_by_req_date
              );

             IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'AFTER CALLING INVS QUERY_RESERVATION: ' || X_RETURN_STATUS , 1 ) ;
             END IF;

             IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
             IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RESERVATION RECORD COUNT IS: ' || L_RSV_TBL.COUNT , 1 ) ;
             END IF;

             -- Let's get the total reserved_quantity
             l_reserved_quantity := 0;
             -- INVCONV
             l_reserved_quantity2 := 0;

             FOR K IN 1..l_rsv_tbl.count LOOP
              -- Start 2346233 --
/*               l_reserved_quantity := l_reserved_quantity +
                                       l_rsv_tbl(K).reservation_quantity;
*/

                l_reserved_quantity := l_reserved_quantity + l_rsv_tbl(K).primary_reservation_quantity;
                        l_reserved_quantity2 := l_reserved_quantity2 + l_rsv_tbl(K).secondary_reservation_quantity; -- INVCONV
                -- End 2346233 --
             END LOOP;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'RESERVED QUANTITY : ' || L_RESERVED_QUANTITY , 1 ) ;
                 oe_debug_pub.add(  'RESERVED QUANTITY2 : ' || L_RESERVED_QUANTITY2 , 1 ) ;
             END IF;
             -- We should process reservation logic only when reservation qty exists
             -- and parent line order qty is less than total reserved qty. If parent
             -- ordered qty is greter or equal to total reserved qty, we do not need
             -- transfer any reservations.

             -- Start 2346233 --
             IF  l_reserved_quantity > 0 THEN
                IF NOT OE_GLOBALS.Equal(p_x_line_tbl(I).order_quantity_uom,
                                       l_rsv_tbl(1).primary_uom_code) THEN
                   l_ordered_quantity :=
                        INV_CONVERT.INV_UM_CONVERT( item_id       => p_x_line_tbl(I).inventory_item_id,
                                                    precision     => 5,
                                                    from_quantity =>p_x_line_tbl(I).ordered_quantity,
                                                    from_unit     =>p_x_line_tbl(I).order_quantity_uom,
                                                    to_unit       =>l_rsv_tbl(1).primary_uom_code,
                                                    from_name     =>NULL,
                                                    to_name       =>NULL
                                                   );

                ELSE
                   l_ordered_quantity := p_x_line_tbl(I).ordered_quantity;
                END IF;
                l_ordered_quantity2 := p_x_line_tbl(I).ordered_quantity2; -- INVCONV
             END IF;

/*             IF   l_reserved_quantity > 0
            AND  p_x_line_tbl(I).ordered_quantity < l_reserved_quantity
            THEN */
             IF   l_reserved_quantity > 0
               AND  l_ordered_quantity < l_reserved_quantity
             THEN
               ---- End 2346233 ---

               -- There can be 2 kinds of splits. One where the user split,
               -- in which case, the reservations have to split if line is not
               -- shipping interfaced. WSH interfaced line will be taken careby WSH.
               -- System split happens when shipping occurs partially.
               -- In that case, the remaining reservations are trasferred to the
               -- new line. This will be taken care by shipping code.

               -- l_qty_to_retain is to retain in the reservation record.
               -- l_available_qty is reamining qty that can be transferred.

               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'USER INITIATED SPLIT' , 1 ) ;
               END IF;

               --- Start 2346233 --
               -- l_qty_to_retain := p_x_line_tbl(I).ordered_quantity;
               l_qty_to_retain := l_ordered_quantity;
               l_qty2_to_retain := l_ordered_quantity2; -- INVCONV
               --- End 2346233 --

/*               need OPM branching  -- Don't branch now  INVCONV
               IF NOT INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => p_x_line_tbl(I).ship_from_org_id) THEN */
               J:= 1;
               FOR K IN 1..l_rsv_tbl.count LOOP
                  IF l_qty_to_retain > 0 THEN

                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'L_QTY_TO_RETAIN ' || L_QTY_TO_RETAIN , 1 ) ;
                     END IF;
                         ---- Start 2346233 ---
                     IF l_rsv_tbl(K).primary_reservation_quantity <= l_qty_to_retain
                     THEN
                        l_qty_to_retain := l_qty_to_retain -
                                          l_rsv_tbl(K).primary_reservation_quantity;
                        l_qty2_to_retain := nvl(l_qty2_to_retain, 0) -
                                          nvl(l_rsv_tbl(K).secondary_reservation_quantity, 0); -- INVCONV
/*
                      IF l_rsv_tbl(K).reservation_quantity <= l_qty_to_retain
                      THEN
                         l_qty_to_retain := l_qty_to_retain -
                                          l_rsv_tbl(K).reservation_quantity;
*/
                      ---- End 2346233 ---

                       IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'BEFORE DELETE ' || K || '/' || L_RSV_TBL ( K ) .RESERVATION_QUANTITY , 1 ) ;
                          oe_debug_pub.add(  'BEFORE DELETE Primary ' || K || '/' || L_RSV_TBL ( K ) .PRIMARY_RESERVATION_QUANTITY , 1 ) ;
                       END IF;
                       l_rsv_tbl.delete(K);
                     END IF;

                  END IF; -- l_qty_to_retain.

               END LOOP;

               K := l_rsv_tbl.first;
               continue_loop := TRUE;
               l_rsv_rec := l_rsv_tbl(k);
               WHILE K IS NOT NULL LOOP
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'IN THE BEGINING OF THE LOOP K ' || K , 1 ) ;
                  END IF;
                  IF l_qty_to_retain = 0 THEN
                     l_rsv_rec := l_rsv_tbl(k);
                  END IF;

                  WHILE J <= p_x_line_tbl.count AND continue_loop
                  LOOP
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'IN THE BEGINING OF THE LOOP J ' || J , 1 ) ;
                     END IF;
                     IF p_x_line_tbl(J).operation =
                                        OE_GLOBALS.G_OPR_CREATE AND
                        p_x_line_tbl(J).split_from_line_id =
                                         p_x_line_tbl(I).line_id AND
                         p_x_line_tbl(J).ship_from_org_id =
                                         p_x_line_tbl(I).ship_from_org_id    --8706868
                     THEN
                         continue_loop := FALSE;
                         l_rsv_qty := p_x_line_tbl(J).ordered_quantity;
                         l_rsv_qty2 := p_x_line_tbl(J).ordered_quantity2; -- INVCONV
                         ---- Start 2346233 ---
                         IF NOT OE_GLOBALS.Equal(p_x_line_tbl(J).order_quantity_uom,
                                                 l_rsv_rec.primary_uom_code) THEN
                            l_rsv_qty_primary :=
                              INV_CONVERT.INV_UM_CONVERT( item_id       => p_x_line_tbl(J).inventory_item_id,
                                                          precision     => 5,
                                                          from_quantity =>p_x_line_tbl(J).ordered_quantity,
                                                          from_unit     =>p_x_line_tbl(J).order_quantity_uom,
                                                          to_unit       =>l_rsv_rec.primary_uom_code,
                                                          from_name     =>NULL,
                                                          to_name       =>NULL
                                                        );

                         ELSE
                            l_rsv_qty_Primary := p_x_line_tbl(J).ordered_quantity;
                         END IF;
                         l_rsv_qty_secondary := p_x_line_tbl(J).ordered_quantity2; -- INVCONV
                         ---- End 2346233 ---

                         IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'FOUND NEW RECORD ' || P_X_LINE_TBL ( J ) .LINE_ID || '/' ||L_RSV_QTY , 1 ) ;
                         END IF;
                         l_line_id :=  p_x_line_tbl(J).line_id;
                         J := J +1;
                     ELSE
                         J := J + 1;
                     END IF;
                 END LOOP;

                   IF l_rsv_qty > 0  THEN
                     --- Start 2346233 --
/*                      l_available_qty := l_rsv_rec.reservation_quantity -
                                                    l_qty_to_retain;  */
                     l_available_qty := l_rsv_rec.primary_reservation_quantity -
                                        l_qty_to_retain;
                                         l_available_qty2 := nvl(l_rsv_rec.secondary_reservation_quantity, 0) -
                                        nvl(l_qty2_to_retain, 0) ;  -- INVCONV
                     IF l_available_qty2 = 0
                      THEN
                      l_available_qty2 := NULL;
                     END IF;





                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'L_RSV_QTY_PRIMARY' || l_rsv_qty_primary , 1 ) ;
                     END IF;

                     -- IF  l_rsv_qty <= l_available_qty  THEN
                     IF  l_rsv_qty_primary <= l_available_qty  THEN

                     --- End 2346233 --

                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'AVAILABLE MORE THAN NEEDED' || L_AVAILABLE_QTY , 1 ) ;
                       END IF;
                       -- Transfer full l_rsv_qty.
                       Transfer_Reservation
                       (p_rsv_rec              => l_rsv_rec,
                        p_quantity_to_transfer => l_rsv_qty,
                        p_quantity2_to_transfer => l_rsv_qty2, -- INVCONV
                        p_line_to_transfer     => l_line_id,
                        x_return_status        => x_return_status);
                        --- Start 2346233 --
/*                         l_rsv_rec.reservation_quantity := l_rsv_rec.reservation_quantity -
                                                         l_rsv_qty;
                        -- l_qty_to_retain := l_qty_to_retain + l_rsv_qty;
                        l_available_qty := l_rsv_rec.reservation_quantity -
                                                        l_qty_to_retain; */
                        l_rsv_rec.primary_reservation_quantity :=
                                l_rsv_rec.primary_reservation_quantity - l_rsv_qty_primary;
                        l_available_qty := l_rsv_rec.primary_reservation_quantity - l_qty_to_retain;
                        l_rsv_qty_primary := 0;
                                                -- INVCONV
                                                l_rsv_rec.secondary_reservation_quantity :=
                                nvl(l_rsv_rec.secondary_reservation_quantity,0) - nvl(l_rsv_qty_secondary,0 );

                        IF l_rsv_rec.secondary_reservation_quantity = 0 -- INVCONV
                          THEN
                           l_rsv_rec.secondary_reservation_quantity := NULL;
                        END IF;

                        l_available_qty2 := l_rsv_rec.secondary_reservation_quantity - l_qty2_to_retain;

                        IF l_available_qty2 = 0 -- INVCONV
                          THEN
                           l_available_qty2 := NULL;
                        END IF;


                        l_rsv_qty_secondary := 0;


                        --- End 2346233 --

                       l_rsv_qty := 0;
		       l_line_found := TRUE; -- 8706868
                       l_rsv_qty2 := 0; -- INVCONV
                       continue_loop := TRUE;
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'AVAILABLE QTY ' || L_AVAILABLE_QTY , 1 ) ;
                       END IF;


                       -- Start 2346233 --
                       --IF l_rsv_rec.reservation_quantity = l_qty_to_retain THEN
                       -- Bug 5014710
                       IF round(l_rsv_rec.primary_reservation_quantity,5) = round(l_qty_to_retain,5) THEN
                       -- End 2346233 --
                          K := l_rsv_tbl.next(K);
                          l_available_qty := 0;
                          l_qty_to_retain := 0;
                          l_available_qty2 := 0; -- INVCONV
                          l_qty2_to_retain := 0; -- INVCONV

                       END IF;
                     ELSE
                           -- Transfer remaining
                       Transfer_Reservation
                       (p_rsv_rec               =>l_rsv_rec,
                        p_quantity_to_transfer  =>l_available_qty,
                        p_quantity2_to_transfer =>l_available_qty2, -- INVCONV
                        p_line_to_transfer     =>l_line_id,
                        x_return_status        =>x_return_status);

                        l_rsv_qty := l_rsv_qty - l_available_qty;
                        l_available_qty := 0;
                        l_qty_to_retain := 0;
		        l_line_found := TRUE; -- 12317262

                        -- INVCONV
                        l_rsv_qty2 := nvl(l_rsv_qty2, 0) - nvl(l_available_qty2, 0); -- INVCONV
                        l_available_qty2 := 0;
                        l_qty2_to_retain := 0;

                        K := l_rsv_tbl.next(K);
                      END IF;
                    ELSE
		       K := l_rsv_tbl.next(K); -- 8706868

                    END IF; -- l_rsv_qty > 0
                  -- END LOOP;
                 END LOOP; -- K loop.
		 --8706868
                 IF l_rsv_qty = 0  AND not l_line_found THEN
                    l_available_qty := l_rsv_rec.primary_reservation_quantity - l_qty_to_retain;
                    l_available_qty2 := nvl(l_rsv_rec.secondary_reservation_quantity, 0) -
                                        nvl(l_qty2_to_retain, 0) ;  -- INVCONV
                    IF l_available_qty2 = 0  THEN
                       l_available_qty2 := NULL;
                    END IF;
                END IF;

		 --8706868 : Unreserve remaining extra qty.
                 IF L_AVAILABLE_QTY > 0 THEN
		    Do_Unreserve
                     ( p_line_rec               => p_x_line_tbl(I)
                     , p_quantity_to_unreserve  => L_AVAILABLE_QTY
                     , p_quantity2_to_unreserve  => l_available_qty2
                     , p_old_ship_from_org_id    => p_x_line_tbl(I).ship_from_org_id
                    , x_return_status          => x_return_status);

		 END IF;
/*                 ELSE  if OPM -- INVCONV  - don;t need this branch cos no OPM now .
                 J:= 1;
                 -- Bug 3330925 (getting rid of continue_loop)
                 -- continue_loop := TRUE;
                 WHILE J <= p_x_line_tbl.count -- AND continue_loop
                 LOOP
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'IN THE BEGINING OF THE LOOP J TO FIND THE SPLITTED LINE ' || J , 1 ) ;
                   END IF;


                   IF p_x_line_tbl(J).operation =
                                      OE_GLOBALS.G_OPR_CREATE AND
                      p_x_line_tbl(J).split_from_line_id =
                                       p_x_line_tbl(I).line_id
                   THEN
                       -- continue_loop := FALSE;
                       l_rsv_qty := p_x_line_tbl(J).ordered_quantity;
                                         IF l_debug_level  > 0 THEN
                                             oe_debug_pub.add(  'FOUND NEW RECORD ' || P_X_LINE_TBL ( J ) .LINE_ID || '/' ||L_RSV_QTY , 1 ) ;
                                         END IF;
                       l_line_id :=  p_x_line_tbl(J).line_id;

                       -- Begin Bug 3330925
                       IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'CALLING GMI SPLIT_TRANS_FROM_OM ' ) ;
                       END IF;
                       GMI_RESERVATION_UTIL.split_trans_from_OM
                         ( p_old_source_line_id     => p_x_line_tbl(I).line_id,
                           p_new_source_line_id     => l_line_id,
                           p_qty_to_split           => p_x_line_tbl(I).ordered_quantity,
                           p_qty2_to_split          => p_x_line_tbl(I).ordered_quantity2,
                           x_return_status          => x_return_status,
                           x_msg_count              => l_msg_count,
                           x_msg_data               => l_msg_data
                         );
                       -- End Bug 3330925

                       J := J +1;
                   ELSE
                       J := J + 1;
                   END IF;
                 END LOOP; -- J loop

                 -- Bug3330925 (moved this within the Loop above)
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'CALLING GMI SPLIT_TRANS_FROM_OM ' ) ;
                 END IF;
                 GMI_RESERVATION_UTIL.split_trans_from_OM
                     ( p_old_source_line_id     => p_x_line_tbl(I).line_id,
                       p_new_source_line_id     => l_line_id,
                       p_qty_to_split           => p_x_line_tbl(I).ordered_quantity,
                       p_qty2_to_split          => p_x_line_tbl(I).ordered_quantity2,
                       x_return_status          => x_return_status,
                       x_msg_count              => l_msg_count,
                       x_msg_data               => l_msg_data
                      );
               END IF; --  OPM branching */   -- INVCONV - not needed  now
            --8706868
            ELSIF l_reserved_quantity = 0 AND
	         Within_Rsv_Time_Fence(p_x_line_tbl(I).schedule_ship_date,
                                 p_x_line_tbl(I).org_id)  AND
    	        (sch_cached_sch_level_code = SCH_LEVEL_THREE  OR
                 sch_cached_sch_level_code = SCH_LEVEL_FOUR OR
                 sch_cached_sch_level_code is null) THEN
               Reserve_Line
                ( p_line_rec             => p_x_line_tbl(I)
                , p_quantity_to_reserve  => nvl(p_x_line_tbl(I).ordered_quantity, 0)
                , p_quantity2_to_reserve  => nvl(p_x_line_tbl(I).ordered_quantity2, 0) -- INVCONV
                , x_return_Status        => x_return_status);
            END IF;  -- l_reserved_quantity > 0
	    -- 8706868
         ELSIF nvl(p_x_line_tbl(I).shipping_interfaced_flag, 'N') = 'Y' AND
 	         OE_SCHEDULE_UTIL.oe_split_rsv_tbl.count > 0 THEN

	    IF  OE_SCHEDULE_UTIL.oe_split_rsv_tbl.EXISTS
                         (MOD(p_x_line_tbl(I).line_id,G_BINARY_LIMIT)) AND
                 (p_x_line_tbl(I).shipped_quantity is null) AND
                 Within_Rsv_Time_Fence(p_x_line_tbl(I).schedule_ship_date,
                                 p_x_line_tbl(I).org_id)  AND
    	        (sch_cached_sch_level_code = SCH_LEVEL_THREE  OR
                 sch_cached_sch_level_code = SCH_LEVEL_FOUR OR
                 sch_cached_sch_level_code is null) THEN
               Reserve_Line
                ( p_line_rec             => p_x_line_tbl(I)
                , p_quantity_to_reserve  => nvl(p_x_line_tbl(I).ordered_quantity, 0)
                , p_quantity2_to_reserve  => nvl(p_x_line_tbl(I).ordered_quantity2, 0) -- INVCONV
                , x_return_Status        => x_return_status);
           END IF;
       END IF; --  shipped_quantity is null
    --8706868
    ELSIF p_x_line_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE AND
          p_x_line_tbl(I).schedule_status_code is not null AND
	  nvl(p_x_line_tbl(I).shippable_flag,'N') = 'Y' AND
	  (p_x_line_tbl(I).shipped_quantity is null) AND
           Within_Rsv_Time_Fence(p_x_line_tbl(I).schedule_ship_date,
                                p_x_line_tbl(I).org_id)  AND
	   (sch_cached_sch_level_code = SCH_LEVEL_THREE  OR
            sch_cached_sch_level_code = SCH_LEVEL_FOUR OR
             sch_cached_sch_level_code is null) THEN

	     l_do_reservation := FALSE;
	     IF (nvl(p_x_line_tbl(I).shipping_interfaced_flag, 'N') = 'N') THEN
                l_do_reservation := TRUE;
             ELSIF (nvl(p_x_line_tbl(I).shipping_interfaced_flag, 'N') = 'Y') THEN
                -- Do reservation if parent warehouse is different from child warehouse or
		-- parent line is in table oe_schedule_util.oe_split_rsv_tbl
		IF OE_SCHEDULE_UTIL.oe_split_rsv_tbl.count > 0 THEN
		   IF OE_SCHEDULE_UTIL.oe_split_rsv_tbl.EXISTS
                         (MOD(p_x_line_tbl(I).split_from_line_id,G_BINARY_LIMIT)) THEN
                      l_do_reservation := TRUE;
                   END IF;
                ELSE
		   FOR K in 1..p_x_line_tbl.count LOOP
		      IF p_x_line_tbl(I).split_from_line_id =p_x_line_tbl(K).line_id AND
		         p_x_line_tbl(I).ship_from_org_id <> p_x_line_tbl(K).ship_from_org_id THEN
                        l_do_reservation := TRUE;
			EXIT;
                      END IF;
		   END LOOP;
		END IF;
	     END IF;
	     --10208311 Check for reservation only if its a USER split
	     IF l_do_reservation AND
                NVL(p_x_line_tbl(I).split_by,'USER') <> 'SYSTEM' THEN
                -- First check it it already has the reservation
                l_query_rsv_rec.reservation_id := fnd_api.g_miss_num;
                l_sales_order_id
                       := Get_mtl_sales_order_id(p_x_line_tbl(I).header_id);
                l_query_rsv_rec.demand_source_header_id  := l_sales_order_id;
                l_query_rsv_rec.demand_source_line_id    := p_x_line_tbl(I).line_id;
                l_query_rsv_rec.organization_id := p_x_line_tbl(I).ship_from_org_id;

                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'CALLING INVS QUERY_RESERVATION ' , 1 ) ;
                END IF;

                inv_reservation_pub.query_reservation
                  ( p_api_version_number       => 1.0
                  , p_init_msg_lst              => fnd_api.g_true
                  , x_return_status             => x_return_status
                  , x_msg_count                 => l_msg_count
                  , x_msg_data                  => l_msg_data
                  , p_query_input               => l_query_rsv_rec
                  , x_mtl_reservation_tbl       => l_rsv_tbl
                  , x_mtl_reservation_tbl_count => l_count
                  , x_error_code                => l_x_error_code
                  , p_lock_records              => l_lock_records
                  , p_sort_by_req_date          => l_sort_by_req_date
                 );
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'AFTER CALLING INVS QUERY_RESERVATION: ' || X_RETURN_STATUS , 1 ) ;
                END IF;

                IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
                END IF;
                IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'RESERVATION RECORD COUNT IS: ' || L_RSV_TBL.COUNT , 1 ) ;
                END IF;
                IF l_rsv_tbl.count = 0 THEN
                   Reserve_Line
                   ( p_line_rec             => p_x_line_tbl(I)
                   , p_quantity_to_reserve  => nvl(p_x_line_tbl(I).ordered_quantity, 0)
                   , p_quantity2_to_reserve  => nvl(p_x_line_tbl(I).ordered_quantity2, 0) -- INVCONV
                   , x_return_Status        => x_return_status);
               END IF;
          END IF;
      END IF; -- If operation on the line was UPDATE

    END LOOP; -- Main Loop.
  END IF; -- 8706868
  G_OVERRIDE_FLAG     := 'N';
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SCHEDULING RESULTS OF THE LINES: ' , 1 ) ;
  END IF;


  FOR I IN 1..p_x_line_tbl.count LOOP
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LINE ID : ' || P_X_LINE_TBL ( I ) .LINE_ID , 1 ) ;
         oe_debug_pub.add(  'SCHEDULE STATUS : ' || P_X_LINE_TBL ( I ) .SCHEDULE_STATUS_CODE , 1 ) ;
      END IF;
  END LOOP;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING SPLIT_SCHEDULING WITH ' || X_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Split_Scheduling'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END SPLIT_SCHEDULING;

/*------------------------------------------------------------
Procedure Schedule_Split_Lines
p_param1    => p_x_line_tbl(I).schedule_status_code,
p_param2    => p_x_line_tbl(I).arrival_set_id,
p_param3    => p_x_line_tbl(I).ship_set_id,
p_param4    => p_x_line_tbl(I).ship_model_complete_flag,
p_param5    => p_x_line_tbl(I).model_remnant_flag,
p_param6    => p_x_line_tbl(I).top_model_line_id,
p_param7    => p_x_line_tbl(I).ato_line_id,
p_param8    => p_x_line_tbl(I).item_type_code,
p_param9    => p_x_line_tbl(I).source_type_code,

This procedure will be called from OEXVREQB.pls.This procedure will process
the scheduling for the system split records.

OM will log delayed request named split_schedule from post_line_process
of oe_line_util to fix the bug 2913742.

From now on split scheduling will not be used for system splits. This API will
take care of scheduling the system split records.


-------------------------------------------------------------*/
Procedure Schedule_Split_Lines
( p_sch_set_tbl     IN  OE_ORDER_PUB.request_tbl_type
, x_return_status   OUT NOCOPY VARCHAR2)
IS
l_line_tbl           OE_ORDER_PUB.line_Tbl_Type;
l_line_rec           OE_ORDER_PUB.Line_Rec_Type;
BEGIN

  oe_debug_pub.add('Entering Schedule_Split_Lines',1);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR I in 1..p_sch_set_tbl.count LOOP

   IF p_sch_set_tbl(I).param2 IS NOT NULL
   OR p_sch_set_tbl(I).param3 IS NOT NULL
   OR (p_sch_set_tbl(I).param4 = 'Y'
   AND nvl(p_sch_set_tbl(I).param5,'N') = 'N')
   OR (p_sch_set_tbl(I).param7 IS NOT NULL
   AND p_sch_set_tbl(I).param8 <> 'STANDARD'
   AND nvl(p_sch_set_tbl(I).param5,'N') = 'N'
   AND p_sch_set_tbl(I).param9 = OE_GLOBALS.G_SOURCE_INTERNAL  --added for bug 12757660
                           ) THEN -- 4421848: added remnant flag check

   oe_debug_pub.add('Belongs to Set',2);
   l_line_tbl(I).line_id                  := p_sch_set_tbl(I).entity_id;
   l_line_tbl(I).schedule_status_code     := p_sch_set_tbl(I).param1;
   l_line_tbl(I).arrival_set_id           := p_sch_set_tbl(I).param2;
   l_line_tbl(I).ship_set_id              := p_sch_set_tbl(I).param3;
   l_line_tbl(I).ship_model_complete_flag := p_sch_set_tbl(I).param4;
   l_line_tbl(I).model_remnant_flag       := p_sch_set_tbl(I).param5;
   l_line_tbl(I).top_model_line_id        := p_sch_set_tbl(I).param6;
   l_line_tbl(I).ato_line_id              := p_sch_set_tbl(I).param7;
   l_line_tbl(I).item_type_code           := p_sch_set_tbl(I).param8;

   ELSE
    -- Standard or independent line.
   oe_debug_pub.add('Independent or remnant line',2);

    OE_Line_Util.Query_Row(p_line_id  => p_sch_set_tbl(I).entity_id,
                           x_line_rec => l_line_rec);

    l_line_tbl(I) := l_line_rec;


   END IF;
  END LOOP;

  G_OVERRIDE_FLAG     := 'Y';

  oe_debug_pub.add(  'COUNT IS :' || l_line_tbl.COUNT , 1 ) ;

  process_split(p_x_line_tbl => l_line_tbl,
                x_return_status => x_return_status);

  G_OVERRIDE_FLAG     := 'N';
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_Split_Lines'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
End Schedule_Split_Lines;

/*--------------------------------------------------------------------------
Procedure Name : Update_Results_from_backlog_wb
Description    : This procedure is called from the backlog's scheduler's
                 workbenck and the Supply Chain ATP form, after the user
                 has performed some scheduling in their form. They call
                 this API to update the results of scheduling on the order
                 lines table.
                 For the purpose of this call, we have created a new table type
                 mrp_line_tbl_type, which is table of mrp_line_rec_type.
                 This record is created with only those fields whose values
                 we can get back from MRP's form. We take the field values
                 from this record and update the lines information in
                 oe_order_lines table.
-------------------------------------------------------------------------- */
Procedure Update_Results_from_backlog_wb
( p_mrp_line_tbl  IN  mrp_line_tbl_type
, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR2)

IS
/*
l_line_rec                  OE_ORDER_PUB.line_rec_type;
I                           NUMBER;
l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count                 NUMBER := 0;
l_msg_data                  VARCHAR2(2000) := null;
l_control_rec               OE_GLOBALS.control_rec_type;
l_line_tbl                  OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl              OE_ORDER_PUB.line_tbl_type;
l_file_val                  VARCHAR2(80);
*/
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   -- (4735196) This api is obsoleted.
   --Use OE_SCHEDULE_GRP.Update_Scheduling_Results instead.
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'This API is not supported ' , 1 ) ;
    END IF;
   /*
     fnd_profile.put('OE_DEBUG_LOG_DIRECTORY','/sqlcom/outbound/dom1151');

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING UPDATE_RESULTS_FROM_BACKLOG_WB' , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COUNT IS: ' || P_MRP_LINE_TBL.COUNT , 1 ) ;
    END IF;
    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.default_attributes   := TRUE;
    l_control_rec.check_security       := TRUE;

    l_control_rec.write_to_DB          := TRUE;
    l_control_rec.validate_entity      := TRUE;

    l_control_rec.process              := TRUE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    FOR I in 1..p_mrp_line_tbl.count LOOP

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RR: LINE ID ' || P_MRP_LINE_TBL ( I ) .LINE_ID , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RR: SCHEDULE_SHIP_DATE ' || P_MRP_LINE_TBL ( I ) .SCHEDULE_SHIP_DATE , 1 ) ;
  END IF;

        l_line_rec        := OE_Order_Pub.G_MISS_LINE_REC;
        l_line_rec.line_id               := p_mrp_line_tbl(I).line_id;
        l_line_rec.schedule_ship_date    :=
                                  p_mrp_line_tbl(I).schedule_ship_date;
        l_line_rec.schedule_arrival_date :=
                                  p_mrp_line_tbl(I).schedule_arrival_date;
        l_line_rec.ship_from_org_id      :=
                                  p_mrp_line_tbl(I).ship_from_org_id;
        l_line_rec.shipping_method_code  :=
                                  p_mrp_line_tbl(I).ship_method_code;
        l_line_rec.schedule_status_code    :=
                                  OESCH_STATUS_SCHEDULED;
  -- Start Audit Trail
  l_line_rec.change_reason := 'SYSTEM';
  --  l_line_rec.change_comments := 'Scheduling Action';
  -- End Audit Trail
        l_line_rec.visible_demand_flag   := 'Y';
        l_line_rec.operation             := OE_GLOBALS.G_OPR_UPDATE;
        l_line_tbl(I)                    := l_line_rec;
    END LOOP;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE COUNT IS: ' || L_LINE_TBL.COUNT , 1 ) ;
    END IF;
    OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
    OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BKL: CALLING PROCESS ORDER' , 1 ) ;
    END IF;


    --  Call OE_Order_PVT.Process_order

    OE_Order_PVT.Lines
    (p_validation_level    => FND_API.G_VALID_LEVEL_NONE,
     p_control_rec         => l_control_rec,
     p_x_line_tbl          => l_line_tbl,
     p_x_old_line_tbl      => l_old_line_tbl,
     x_return_status       => l_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BKL: AFTER CALLING PROCESS ORDER' , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_RETURN_STATUS IS ' || L_RETURN_STATUS , 1 ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RR: UNEXP ERRORED OUT' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RR: ERRORED OUT' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

-- code fix for 3502139
-- call Process_Requests_And_Notify to execute the delayed requests
    OE_ORDER_PVT.Process_Requests_And_Notify
    (
    x_return_status => l_return_status
    );
-- code fix for 3502139

-- Added the following code to fix the bug 3105070

    FOR I in 1..l_line_tbl.count LOOP
      IF l_line_tbl(I).source_document_type_id = 10        AND
         NOT OE_GLOBALS.EQUAL(l_line_tbl(I).schedule_arrival_date,
                          l_old_line_tbl(I).schedule_arrival_date)

      THEN
        oe_debug_pub.add(  'PASSING SCHEDULE_ARRIVAL_DATE TO PO ' , 3 ) ;
         Update_PO(l_line_tbl(I).schedule_arrival_date,
                   l_line_tbl(I).source_document_id,
                   l_line_tbl(I).source_document_line_id);
        oe_debug_pub.add(  'AFTER PO CALL BACK' , 3 ) ;
      END IF;
   END LOOP ;

 -- End of the code added to fix the bug 3105070

    OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
    OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

    x_return_status := l_return_status;
    x_msg_count     := l_msg_count;
    x_msg_data      := l_msg_data;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING UPDATE_RESULTS_FROM_BACKLOG_WB' , 1 ) ;
    END IF;
    OE_DEBUG_PUB.Debug_Off;
 */
   NULL;
   x_msg_data := 'This API is not supported';
   RAISE FND_API.G_EXC_ERROR;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        /*
        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        */
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_line'
            );
        END IF;
END Update_Results_from_backlog_wb;
/*-----------------------------------------------------+
 | Name        :   Post_Forms_Commit                   |
 | Parameters  :                                       |
 |                                                     |
 | Description :   This Procedure is called from       |
 |                 OEOXOEFRM.pld POST_FORMS_COMMIT     |
 |                 This Procedure was added for        |
 |                 Bug: 2097933.                       |
 |                 With this procedure we check if     |
 |                 there is sufficient Qty for         |
 |                 Reservation just before we are      |
 |                 Committing the line.                |
 |         If there is no sufficient Qty for   |
 |         reservation then the Inventory      |
 |         populates a pl-sql table. Before    |
 |                 commit we check if the pl-sql table |
 |         is NOT Null or not.             |
 +-----------------------------------------------------*/

Procedure Post_Forms_Commit
(x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2) IS

l_return_status VARCHAR2(100);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(500);
l_failed_rsv_temp_tbl INV_RESERVATION_GLOBAL.mtl_failed_rsv_tbl_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '*** INSIDE THE POST_FORMS_COMMIT ***' , 1 ) ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check for Performed Reservation Start
  IF OESCH_PERFORMED_RESERVATION = 'Y' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' BEFORE CALLING THE INV FOR DO_CHECK_FOR_COMMIT' , 1 ) ;
    END IF;
    INV_RESERVATION_PVT.Do_Check_For_Commit
        (p_api_version_number  => 1.0
        ,p_init_msg_lst        => FND_API.G_FALSE
        ,x_return_status       => l_return_status
        ,x_msg_count           => l_msg_count
        ,x_msg_data            => l_msg_data
        ,x_failed_rsv_temp_tbl => l_failed_rsv_temp_tbl);

                                           IF l_debug_level  > 0 THEN
                                               oe_debug_pub.add(  'AFTER CALLING THE INV FOR DO_CHECK_FOR_COMMIT : ' || L_RETURN_STATUS , 1 ) ;
                                           END IF;

  -- We need to find out if the Reservation has failed
    IF l_failed_rsv_temp_tbl.count > 0 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' THE RESERVATION PROCESS HAS FAILED ' , 1 ) ;
      END IF;
      FND_MESSAGE.SET_NAME('ONT','OE_SCH_RSV_FAILURE');
      OE_MSG_PUB.Add;
    END IF;

    -- Error Handling Start
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INSIDE UNEXPECTED ERROR' , 1 ) ;
      END IF;
      OE_MSG_PUB.Transfer_Msg_Stack;
      l_msg_count   := OE_MSG_PUB.COUNT_MSG;

      FOR I IN 1..l_msg_count LOOP
        l_msg_data :=  OE_MSG_PUB.Get(I,'F');

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
        END IF;
      END LOOP;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' INSIDE EXPECTED ERROR' , 1 ) ;
      END IF;
      OE_MSG_PUB.Transfer_Msg_Stack;
      l_msg_count   := OE_MSG_PUB.COUNT_MSG;

      FOR I IN 1..l_msg_count LOOP
        l_msg_data :=  OE_MSG_PUB.Get(I,'F');
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
        END IF;
      END LOOP;
      RAISE FND_API.G_EXC_ERROR;

    END IF;
  --Error Handling End

    OESCH_PERFORMED_RESERVATION := 'N';

  -- Check for Performed Reservation End
  END IF;

    --  Get message count and data

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '*** BEFORE EXITING POST_FORMS_COMMIT ***' , 1 ) ;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
 --   OESCH_PERFORMED_RESERVATION := 'N';

    x_return_status := FND_API.G_RET_STS_ERROR;

    --  Get message count and data

    oe_msg_pub.count_and_get
     (   p_count                       => x_msg_count
     ,   p_data                        => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--    OESCH_PERFORMED_RESERVATION := 'N';
    IF OE_MSG_PUB.Check_Msg_Level
        (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME , 'Post_Forms_Commit');
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    --  Get message count and data

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data);


END Post_Forms_Commit;

-- added by fabdi 03/May/2001 - For process ATP
/*--------------------------------------------------------------------------
Procedure Name : get_process_query_quantities
Description : This precedure works out nocopy the on_hand_qty and avail_to_reserve

quanties to display in the same ATP window for process inventory only. The procedure
takes into account grade controlled items and displays inventory result for a particular
grade as well a total sum if grade is null.
This procedure is called from Query_Qty_Tree only
--------------------------------------------------------------------------
-- INVCONV  - not used now     cos of OPM inventory convergence
PROCEDURE get_process_query_quantities
  (   p_org_id       IN  NUMBER
   ,  p_item_id      IN  NUMBER
   ,  p_line_id      IN  NUMBER
, x_on_hand_qty OUT NOCOPY NUMBER

, x_avail_to_reserve OUT NOCOPY NUMBER

  ) IS

 l_commitedsales_qty     NUMBER;
 l_commitedprod_qty     NUMBER;
 l_onhand_order_qty     NUMBER;
 l_grade_ctl    NUMBER;
 l_grade    VARCHAR2(4);

 -- main cursor (with total sum)
 CURSOR c_onhand_qty(p_organisation_id number, p_itemid number) IS
 SELECT sum(s.onhand_order_qty), sum(s.COMMITTEDSALES_QTY), sum(s.COMMITTEDPROD_QTY)
 FROM ic_summ_inv s
 WHERE s.item_id = p_itemid AND
 s.whse_code = (Select wh.whse_code
                from ic_whse_mst wh
                where wh.MTL_ORGANIZATION_ID = p_organisation_id);

 -- cursor (with single grade sum)
 CURSOR c_onhand_qty2(p_organisation_id number, p_itemid number) IS
 SELECT s.onhand_order_qty, s.COMMITTEDSALES_QTY, s.COMMITTEDPROD_QTY
 FROM ic_summ_inv s
 WHERE s.item_id = p_itemid AND
 s.whse_code = (Select wh.whse_code
                from ic_whse_mst wh
                where wh.MTL_ORGANIZATION_ID = p_organisation_id) AND
 s.qc_grade =  (SELECT preferred_grade
               FROM oe_order_lines
               WHERE line_id = p_line_id);


 -- Grade ctl cursor
 CURSOR c_grade_ctl(p_item_id number) IS
 SELECT grade_ctl
 FROM ic_item_mst
 WHERE item_id = p_item_id;

 Cursor c_get_grade (p_line_id number) IS
 SELECT preferred_grade
 FROM oe_order_lines
 WHERE line_id = p_line_id;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INSIDE GET_PROCESS_QUERY_QUANTITIES ' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_LINE_ID - IN GET_PROCESS_QUERY_QUANTITIES IS: '|| P_LINE_ID ) ;
    END IF;

    OPEN c_grade_ctl(p_item_id);
    OPEN c_get_grade(p_line_id);
    FETCH c_grade_ctl into l_grade_ctl;
    FETCH c_get_grade into l_grade;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'GRADE OF ITEM IS '|| L_GRADE ) ;
    END IF;

     IF (l_grade_ctl > 0 AND l_grade is NOT NULL) THEN
        -- Grade ctl item
        OPEN c_onhand_qty2(p_org_id, p_item_id);
        FETCH c_onhand_qty2 into l_onhand_order_qty, l_commitedsales_qty, l_commitedprod_qty;
        if c_onhand_qty2%NOTFOUND then
                CLOSE c_onhand_qty2;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  ' ( 2 ) NO DATA FOUND FOR ITEM '|| P_ITEM_ID || ' ORG_ID '|| P_ORG_ID ) ;
                END IF;
                x_on_hand_qty := 0;
                x_avail_to_reserve := 0;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'POCESS X_ON_HAND_QTY IS: '|| X_ON_HAND_QTY ) ;
                END IF;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'PROCESS X_AVAIL_TO_RESERVE IS: '|| X_AVAIL_TO_RESERVE ) ;
                END IF;
                return;
        end if;
        CLOSE c_onhand_qty2;

     ELSE
        -- non grade ctl item
        OPEN c_onhand_qty(p_org_id, p_item_id);
        FETCH c_onhand_qty into l_onhand_order_qty, l_commitedsales_qty, l_commitedprod_qty;
        if c_onhand_qty%NOTFOUND then
                CLOSE c_onhand_qty;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  ' ( 1 ) NO DATA FOUND FOR ITEM '|| P_ITEM_ID || ' ORG_ID '|| P_ORG_ID ) ;
                END IF;
                x_on_hand_qty := 0;
                x_avail_to_reserve := 0;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'POCESS X_ON_HAND_QTY IS: '|| X_ON_HAND_QTY ) ;
                END IF;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'PROCESS X_AVAIL_TO_RESERVE IS: '|| X_AVAIL_TO_RESERVE ) ;
                END IF;
                return;
        end if;
        CLOSE c_onhand_qty;
     END IF;
   CLOSE c_grade_ctl;
   CLOSE c_get_grade;

   -- Quantity Calculations
   x_on_hand_qty := l_onhand_order_qty;
   x_avail_to_reserve :=  l_onhand_order_qty - (l_commitedsales_qty + l_commitedprod_qty);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'POCESS X_ON_HAND_QTY IS: '|| X_ON_HAND_QTY ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'PROCESS X_AVAIL_TO_RESERVE IS: '|| X_AVAIL_TO_RESERVE ) ;
   END IF;
END get_process_query_quantities; */
-- end fabdi
-- Start  2595661
/*
   FUNCTION Name - GET_PICK_STATUS
   Description - To get the pick status of a particular line
                This will return true if a single or more line with released_status in ('S','Y','C')
*/
FUNCTION Get_Pick_Status (p_line_id IN NUMBER) RETURN BOOLEAN
IS
  l_Pick_Status   VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   SELECT  '1'
   INTO  l_Pick_status
   FROM  WSH_DELIVERY_DETAILS
   WHERE  SOURCE_CODE = 'OE'
   AND  SOURCE_LINE_ID = p_line_id
   AND  RELEASED_STATUS IN ('S','Y','C');

   RETURN (TRUE);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       RETURN (FALSE);
   WHEN TOO_MANY_ROWS THEN
       RETURN (TRUE);
   WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.ADD('Error message in Get_Pick_Status : '||substr(sqlerrm,1,100),1);

      END IF;
      RETURN (FALSE);
END Get_Pick_Status;

PROCEDURE Do_Unreserve (p_line_rec             IN  OE_ORDER_PUB.Line_Rec_Type
                       ,p_quantity_to_unreserve IN  NUMBER
                       ,p_quantity2_to_unreserve IN  NUMBER -- INVCONV
                       ,p_old_ship_from_org_id   IN  NUMBER DEFAULT NULL -- 5024936
                       ,x_return_status         OUT NOCOPY VARCHAR2)
IS
  l_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
  l_rsv_new_rec           inv_reservation_global.mtl_reservation_rec_type;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(240);
  l_rsv_id                NUMBER;
  l_rsv_tbl               inv_reservation_global.mtl_reservation_tbl_type;
  l_count                 NUMBER;
  l_dummy_sn              inv_reservation_global.serial_number_tbl_type;
  l_qty_to_unreserve      NUMBER;
  l_source_code           VARCHAR2(40) := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
  l_sales_order_id        NUMBER;
  l_x_error_code          NUMBER;
  l_lock_records          VARCHAR2(1);
  l_sort_by_req_date      NUMBER ;
  l_buffer                VARCHAR2(2000);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING DO_UNRESERVE' , 3 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'QUANTITY TO UNRESERVE :' || P_QUANTITY_TO_UNRESERVE , 3 ) ;
  END IF;

  -- If the quantity to unreserve is passed and null or missing, we do not
  -- need to go throug this procedure.

  -- 2746991
  --IF p_quantity_to_unreserve is null OR
  IF NVL(p_quantity_to_unreserve,0) = 0 OR
     p_quantity_to_unreserve = FND_API.G_MISS_NUM THEN
     goto end_of_loop;
  END IF;

  IF p_line_rec.source_document_type_id = 10 THEN

     -- This is an internal order line. We need to give
     -- a different demand source type for these lines.

     l_rsv_rec.demand_source_type_id        :=
          INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INTERNAL_ORD;
          -- intenal order
  ELSE
     l_rsv_rec.demand_source_type_id        :=
          INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_OE;
          -- order entry
  END IF;


  -- Get demand_source_header_id from mtl_sales_orders

  l_sales_order_id := Get_mtl_sales_order_id(p_line_rec.HEADER_ID);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_SALES_ORDER_ID' || L_SALES_ORDER_ID , 3 ) ;
  END IF;

  l_rsv_rec.demand_source_header_id  := l_sales_order_id;
  l_rsv_rec.demand_source_line_id    := p_line_rec.line_id;
  -- 02-jun-2000 mpetrosi added org_id to query_reservation start
  --5024936
  IF p_old_ship_from_org_id IS NOT NULL THEN
     l_rsv_rec.organization_id := p_old_ship_from_org_id;
  ELSE
     l_rsv_rec.organization_id := p_line_rec.ship_from_org_id;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SHIP FROM ORG ' || l_rsv_rec.organization_id , 3 ) ;
  END IF;

  inv_reservation_pub.query_reservation
  ( p_api_version_number        => 1.0
  , p_init_msg_lst              => fnd_api.g_true
  , p_query_input               => l_rsv_rec
  , p_cancel_order_mode         => INV_RESERVATION_GLOBAL.G_CANCEL_ORDER_YES
  , p_lock_records              => l_lock_records
  , p_sort_by_req_date          => l_sort_by_req_date
  , x_mtl_reservation_tbl       => l_rsv_tbl
  , x_mtl_reservation_tbl_count => l_count
  , x_error_code                => l_x_error_code
  , x_return_status             => x_return_status
  , x_msg_count                 => l_msg_count
  , x_msg_data                  => l_msg_data);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '3. AFTER QUERY RESERVATION'||X_RETURN_STATUS , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
  END IF;
  IF l_rsv_tbl.count > 0 THEN --Bug 8644811 : Proceed only if there is any record in the table
     -- Start 2346233
     -- l_qty_to_unreserve      := p_quantity_to_unreserve;
     IF NOT OE_GLOBALS.Equal(p_line_rec.order_quantity_uom,l_rsv_tbl(1).primary_uom_code ) THEN
        l_qty_to_unreserve :=  INV_CONVERT.INV_UM_CONVERT( item_id       => p_line_rec.inventory_item_id,
                                                        precision     => 5,
                                                        from_quantity =>p_quantity_to_unreserve,
                                                        from_unit     =>p_line_rec.order_quantity_uom,
                                                        to_unit       =>l_rsv_tbl(1).primary_uom_code,
                                                        from_name     =>NULL,
                                                        to_name       =>NULL
                                                      );
     ELSE
        -- Bug 6335352
        /* Added below condition specifically for SET processing and when UOM is changed to Primary UOM
        Sets are processed using Delayed Requests. By the time delayed request executes, the ordered quantity in line
        gets updated, but reservation is still for the original UOM (non-primary). So unreservation in this case
        will be done using primary reservation quantity
        */
        IF l_rsv_tbl(1).primary_reservation_quantity > p_quantity_to_unreserve
          AND NOT oe_globals.equal(p_line_rec.order_quantity_uom,l_rsv_tbl(1).reservation_uom_code)
        THEN
           l_qty_to_unreserve      := l_rsv_tbl(1).primary_reservation_quantity ;
        ELSE
           l_qty_to_unreserve      := p_quantity_to_unreserve;
        END IF;
     END IF;
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'QUANTITY TO UNRESERVE :' || l_QTY_TO_UNRESERVE , 3 ) ;
     END IF;
     -- End 2346233


     FOR I IN 1..l_rsv_tbl.COUNT LOOP

        l_rsv_rec := l_rsv_tbl(I);
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RESERVED QTY : ' || L_RSV_REC.RESERVATION_QUANTITY , 1 ) ;
           oe_debug_pub.add(  'QTY TO UNRESERVE: ' || L_QTY_TO_UNRESERVE , 1 ) ;
        END IF;

        --Start 2346233
       /*
       IF (l_rsv_rec.reservation_quantity <= l_qty_to_unreserve)
       THEN
       */
       IF (l_rsv_rec.primary_reservation_quantity <= l_qty_to_unreserve) THEN
          -- End 2346233

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CALLING INVS DELETE_RESERVATION' , 3 ) ;
          END IF;
          inv_reservation_pub.delete_reservation
          ( p_api_version_number      => 1.0
          , p_init_msg_lst            => fnd_api.g_true
          , x_return_status           => x_return_status
          , x_msg_count               => l_msg_count
          , x_msg_data                => l_msg_data
          , p_rsv_rec                 => l_rsv_rec
          , p_serial_number           => l_dummy_sn
          );

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER CALLING INVS DELETE_RESERVATION: ' || X_RETURN_STATUS , 1 ) ;
          END IF;

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            oe_msg_pub.transfer_msg_stack;
            l_msg_count:=OE_MSG_PUB.COUNT_MSG;
            FOR I in 1..l_msg_count LOOP
               l_msg_data := OE_MSG_PUB.Get(I,'F');
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
               END IF;
           END LOOP;

           RAISE FND_API.G_EXC_ERROR;
          END IF;

          --Start 2346233
          /*
          l_qty_to_unreserve := l_qty_to_unreserve -
                            l_rsv_rec.reservation_quantity;
          */
          l_qty_to_unreserve := l_qty_to_unreserve -
                            l_rsv_rec.primary_reservation_quantity;
          -- End 2346233


          IF (l_qty_to_unreserve <= 0) THEN
            goto end_of_loop;
          END IF;

       ELSE -- res rec qty > l_qty_to_unreserve
          l_rsv_new_rec                              := l_rsv_rec;
          -- Start 2346233
          /*
          l_rsv_new_rec.reservation_quantity         :=

          l_rsv_rec.reservation_quantity - l_qty_to_unreserve ;
          l_rsv_new_rec.primary_reservation_quantity := fnd_api.g_miss_num;
          */
          l_rsv_new_rec.primary_reservation_quantity :=
            l_rsv_rec.primary_reservation_quantity - l_qty_to_unreserve ;
          l_rsv_new_rec.reservation_quantity := fnd_api.g_miss_num;
          -- End 2346233

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OLD QTY : ' || L_RSV_REC.RESERVATION_QUANTITY , 3 ) ;
             oe_debug_pub.add(  'NEW QTY : ' || L_RSV_NEW_REC.RESERVATION_QUANTITY , 3 ) ;
          END IF;

          -- INVCONV
          /* OPM 14/SEP/00 send process attributes into the reservation
          =============================================================*
          IF INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => p_line_rec.ship_from_org_id)    -- OPM 2645605
          then */

  --       l_rsv_new_rec.attribute1     := p_line_rec.preferred_grade;

          -- 13928724
          IF p_line_rec.ordered_quantity2 < p_line_rec.reserved_quantity2 THEN
            l_rsv_new_rec.secondary_reservation_quantity   := p_line_rec.ordered_quantity2; -- INVCONV
          ELSE
            l_rsv_new_rec.secondary_reservation_quantity   := p_line_rec.reserved_quantity2;
          END IF;
          l_rsv_new_rec.secondary_uom_code               := p_line_rec.ordered_quantity_uom2;
 --       l_rsv_new_rec.attribute2     := p_line_rec.ordered_quantity2;
  --      l_rsv_new_rec.attribute3     := p_line_rec.ordered_quantity_uom2;

          --  END IF; INVCONV

          /* OPM 14/SEP/00 END
          ====================*/


          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING INVS UPDATE_RESERVATION: ' , 3 ) ;
          END IF;
          inv_reservation_pub.update_reservation
          ( p_api_version_number        => 1.0
          , p_init_msg_lst              => fnd_api.g_true
          , p_original_rsv_rec          => l_rsv_rec
          , p_to_rsv_rec                => l_rsv_new_rec
          , p_original_serial_number    => l_dummy_sn -- no serial contorl
          , p_to_serial_number          => l_dummy_sn -- no serial control
          , p_validation_flag           => fnd_api.g_true
          , x_return_status             => x_return_status
          , x_msg_count                 => l_msg_count
          , x_msg_data                  => l_msg_data);

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER INVS UPDATE_RESERVATION: ' || X_RETURN_STATUS , 1 ) ;
          END IF;

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
             oe_msg_pub.transfer_msg_stack;
             l_msg_count:=OE_MSG_PUB.COUNT_MSG;
             for I in 1..l_msg_count loop
                l_msg_data := OE_MSG_PUB.Get(I,'F');
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
                END IF;
             end loop;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          l_qty_to_unreserve := 0;
          goto end_of_loop;

        END IF;
     END LOOP;
  ELSE
     IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Nothing to unreserve' , 3 ) ;
     END IF;
  END IF; -- 8644811
  <<end_of_loop>>
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING DO_UNRESERVE' , 3 ) ;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Do_Unreserve'
       );
    END IF;

END Do_Unreserve;
-- End  2595661
-- Pack J
/*--------------------------------------------------------------------------
Procedure Name : Promise_Date_for_Sch_Action
Description    : This API checks Promise date setup flag and based of Order
                 date type code and scheduling action sets the promise date
                 with schedule ship date/schedule arrival date.
-------------------------------------------------------------------------- */
PROCEDURE Promise_Date_for_Sch_Action
(p_x_line_rec IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type,
 p_sch_action IN VARCHAR2,
 P_header_id  IN NUMBER DEFAULT NULL)
IS
  CURSOR order_header_id IS
  SELECT header_id
  FROM oe_order_lines_all
  WHERE line_id = p_x_line_rec.line_id;

  l_promise_date_flag  VARCHAR2(2);
  l_order_date_type_code VARCHAR2(15);
  l_header_id  NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING PROMISE_DATE_FOR_SCH_ACTION ' , 3 ) ;
   END IF;
   IF p_header_id IS NULL THEN
      -- Heade id not provided.
      OPEN order_header_id;
      FETCH order_header_id INTO l_header_id;
      CLOSE order_header_id;
   ELSE
      l_header_id := p_header_id;
   END IF;
   l_order_date_type_code := NVL(oe_schedule_util.Get_Date_Type(l_header_id),'SHIP');
   l_promise_date_flag := Oe_Sys_Parameters.Value('PROMISE_DATE_FLAG');
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'PROMISE DATE FLAG: '||l_promise_date_flag , 3 ) ;
      oe_debug_pub.add(  'STATUS CODE : '||p_x_line_rec.schedule_status_code , 3 ) ;
   END IF;
   IF (l_promise_date_flag ='FS'
      AND ((p_sch_action = OESCH_ACT_DEMAND
       OR p_sch_action = OESCH_ACT_SCHEDULE)
      OR (p_sch_action = OESCH_ACT_RESCHEDULE
       AND p_x_line_rec.schedule_status_code IS NULL  --4496187
       and Nvl(p_x_line_rec.cancelled_flag,'N')='N' ))) --12980916
     OR (l_promise_date_flag ='S'
     AND (p_sch_action = OESCH_ACT_DEMAND
      OR p_sch_action = OESCH_ACT_SCHEDULE
      OR p_sch_action = OESCH_ACT_REDEMAND
      OR p_sch_action = OESCH_ACT_RESCHEDULE))THEN

       IF l_order_date_type_code = 'SHIP' THEN
          p_x_line_rec.promise_date := p_x_line_rec.schedule_ship_date;
       ELSE
          p_x_line_rec.promise_date := p_x_line_rec.schedule_arrival_date;
       END IF;
   ELSIF l_promise_date_flag ='S'
     AND (p_sch_action = OESCH_ACT_UNSCHEDULE
      OR p_sch_action = OESCH_ACT_UNDEMAND) THEN --3345776
      -- Promise date setup is schedule ship date/ arrival date
      -- Clearing the promise date for unscheduling
      p_x_line_rec.promise_date := Null;
   END IF;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING PROMISE_DATE_FOR_SCH_ACTION ' , 3 ) ;
   END IF;
END Promise_Date_for_Sch_Action;

PROCEDURE Global_atp(p_line_id IN NUMBER)
IS
     l_header_id               NUMBER;
     l_order_number            NUMBER;
     l_line_id                 NUMBER;
     l_inventory_item_id       NUMBER;
     l_sold_to_org_id          NUMBER;
     l_ship_to_org_id          NUMBER;
     l_ship_from_org_id        NUMBER;
     l_quantity_ordered        NUMBER;
     l_uom_code                VARCHAR2(3);
     l_requested_ship_date     DATE  := null;
     l_requested_arrival_date  DATE  := null;
     l_delivery_lead_time      NUMBER;
     l_latest_acceptable_date  DATE  := null;
     l_freight_carrier         VARCHAR2(30) := null;
     l_ship_method             VARCHAR2(30) := null;
     l_demand_class            VARCHAR2(30) := null;
     l_ship_set_name           VARCHAR2(30) := null;
     l_arrival_set_name        VARCHAR2(30) := null;
     l_order_date_type_code    VARCHAR2(30) := null;
     l_session_id              NUMBER;
     l_scenario_id             NUMBER := -1;
     l_order_header_id         NUMBER;
     l_order_line_id           NUMBER;
     l_valid                   BOOLEAN := TRUE;
     l_instance_id             NUMBER;
     result                    BOOLEAN;
     l_project_id              NUMBER;
     l_task_id                 NUMBER;
     l_project_number          NUMBER;
     l_task_number             NUMBER;
     l_ship_method_text        VARCHAR2(80);
     l_line_number             NUMBER;
     l_shipment_number         NUMBER;
     l_option_number           NUMBER;
     l_promise_date            DATE;
     l_request_date            DATE;
     l_customer_name           VARCHAR2(50) := null;
     l_customer_location       VARCHAR2(40) := null;
     l_ship_set_id             NUMBER := null;
     l_ship_set_id_1           NUMBER := null;
     l_arrival_set_id          NUMBER := null;
     l_ato_line_id             NUMBER := null;
     l_top_model_line_id       NUMBER := null;
     l_smc_flag                VARCHAR2(1) := null;
     l_ordered_item            VARCHAR2(2000);
     l_return_status           VARCHAR2(1);
     l_insert_code             NUMBER;
     l_insert_flag             VARCHAR2(240);
     p_arrival_set_id          NUMBER;
     p_ship_set_id             NUMBER;
     p_top_model_line_id       NUMBER;
     p_ato_line_id             NUMBER;
     l_st_ato_line_id          NUMBER;
     l_atp_lead_time           NUMBER := 0;
     l_st_atp_lead_time        NUMBER := 0;
     l_item_type_code          VARCHAR2(30);
     l_ato_model_line_id       NUMBER;
     l_conc_line_number        VARCHAR2(30);
     l_config_line_id          NUMBER;
     l_component_code          VARCHAR2(1000);
     l_component_sequence_id   NUMBER;
     l_link_to_line_id         NUMBER;

     CURSOR set_lines(p_header_id         IN NUMBER,
                      p_line_id           IN NUMBER,
                      p_arrival_set_id    IN NUMBER,
                      p_ship_set_id       IN NUMBER,
                      p_top_model_line_id IN NUMBER,
                      p_ato_line_id       IN NUMBER)
     IS
     SELECT line_id,
            header_id,
            inventory_item_id,
            ordered_item,
            sold_to_org_id,
            ship_to_org_id,
            ship_from_org_id,
            demand_class_code,
            ordered_quantity,
            order_quantity_uom,
            latest_acceptable_date,
            line_number,
            shipment_number,
            option_number,
            delivery_lead_time,
            request_date,
            promise_date,
            project_id,
            task_id,
            shipping_method_code,
            ship_set_id,
            arrival_set_id,
            link_to_line_id,
            ato_line_id,
            item_type_code,
            top_model_line_id,
            component_sequence_id,
            component_code
     FROM OE_ORDER_LINES_ALL
     where header_id = p_header_id AND
          (arrival_set_id = p_arrival_set_id OR
           ship_set_id = p_ship_set_id OR
           top_model_line_id = p_top_model_line_id OR
           ato_line_id = p_ato_line_id) AND
           line_id <> p_line_id AND
           item_type_code <> 'CONFIG';

BEGIN

           BEGIN
              SELECT header_id,
                     inventory_item_id,
                     ordered_item,
                     sold_to_org_id,
                     ship_to_org_id,
                     ship_from_org_id,
                     demand_class_code,
                     ordered_quantity,
                     order_quantity_uom,
                     latest_acceptable_date,
                     line_number,
                     shipment_number,
                     option_number,
                     ship_model_complete_flag,
                     top_model_line_id,
                     ato_line_id,
                     delivery_lead_time,
                     request_date,
                     promise_date,
                     project_id,
                     task_id,
                     shipping_method_code,
                     ship_set_id,
                     arrival_set_id,
                     item_type_code,
                     link_to_line_id,
                     component_code,
                     component_sequence_id
              INTO l_header_id,
                   l_inventory_item_id,
                   l_ordered_item,
                   l_sold_to_org_id,
                   l_ship_to_org_id,
                   l_ship_from_org_id,
                   l_demand_class,
                   l_quantity_ordered,
                   l_uom_code,
                   l_latest_acceptable_date,
                   l_line_number,
                   l_shipment_number,
                   l_option_number,
                   l_smc_flag,
                   l_top_model_line_id,
                   l_ato_line_id,
                   l_delivery_lead_time,
                   l_request_date,
                   l_promise_date,
                   l_project_id,
                   l_task_id,
                   l_ship_method,
                   l_ship_set_id,
                   l_arrival_set_id,
                   l_item_type_code,
                   l_link_to_line_id,
                   l_component_code,
                   l_component_sequence_id
              FROM oe_order_lines_all
              WHERE line_id = p_line_id;

              l_line_id := p_line_id;

              SELECT ORDER_NUMBER ,ORDER_DATE_TYPE_CODE
              INTO   l_order_number,l_order_date_type_code
              FROM   oe_order_headers
              WHERE  header_id=l_header_id;

              IF l_order_date_type_code = 'ARRIVAL' THEN
                 l_requested_arrival_date := l_request_date;
                 IF l_requested_arrival_date is null THEN
                    l_requested_arrival_date := SYSDATE;
                 END IF;
                 l_requested_ship_date := null;
              ELSE
                 l_requested_ship_date := l_request_date;
                 IF l_requested_ship_date is null THEN
                    l_requested_ship_date := SYSDATE;
                 END IF;
                 l_requested_arrival_date := null;
              END IF;


           EXCEPTION
               WHEN OTHERS THEN
                    l_valid := FALSE;
           END;


        IF l_valid THEN

            -- Get the lead time for ATO options
            IF l_ato_line_id is not null AND
               l_line_id <> l_ato_line_id
            THEN

              -- This lines is a ato option or class. Set the atp_lead_time
              -- for it.

              IF l_ato_line_id = l_st_ato_line_id THEN
                  l_atp_lead_time       := l_st_atp_lead_time;
              ELSE
                  l_st_atp_lead_time :=
                      OE_SCHEDULE_UTIL.Get_Lead_Time
                         (p_ato_line_id      => l_ato_line_id,
                          p_ship_from_org_id => l_ship_from_org_id);
                  l_atp_lead_time  := l_st_atp_lead_time;

                  l_st_ato_line_id := l_ato_line_id;
              END IF;
            ELSE
               l_atp_lead_time          :=0;
            END IF;

            -- Get the display values which need to be passed to MRP

            l_project_number    := l_project_id;
            l_task_number       := l_task_id;
            l_ship_method_text  := l_ship_method;

            IF l_sold_to_org_id is not null
            THEN
               BEGIN
                  SELECT NAME
                  INTO l_customer_name
                  FROM OE_SOLD_TO_ORGS_V
                  WHERE organization_id = l_sold_to_org_id;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     l_customer_name     := null;
               END;
            END IF;

            IF l_ship_to_org_id is not null
            THEN
               BEGIN
                  SELECT NAME
                  INTO l_customer_location
                  FROM OE_SHIP_TO_ORGS_V
                  WHERE organization_id = l_ship_to_org_id;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     l_customer_location := null;
               END;
            END IF;

            IF l_ship_set_id is not null
            THEN
               l_ship_set_id_1 := l_ship_set_id;
               BEGIN
                  SELECT SET_NAME
                  INTO l_ship_set_name
                  FROM OE_SETS
                  WHERE set_id = l_ship_set_id;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     l_ship_set_name := null;
               END;
            ELSE
               IF nvl(l_smc_flag,'N') = 'Y' THEN
                  l_ship_set_id_1 := l_top_model_line_id;
               ELSIF l_ato_line_id is not null THEN
                 IF  NOT(OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
                         AND  MSC_ATP_GLOBAL.GET_APS_VERSION = 10) THEN
                     l_ship_set_id_1 := l_ato_line_id;
                 END IF;
               END IF;
            END IF;

            IF l_arrival_set_id is not null
            THEN
               BEGIN
                  SELECT SET_NAME
                  INTO l_arrival_set_name
                  FROM OE_SETS
                  WHERE set_id = l_arrival_set_id;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     l_arrival_set_name := null;
               END;
            END IF;
-- Pack-J changes
            IF l_ato_line_id is not null AND
            NOT (l_ato_line_id = l_line_id AND
                 l_item_type_code in ('STANDARD','OPTION','INCLUDED')) --9775352
            THEN

                 l_ato_model_line_id := l_ato_line_id;

                 BEGIN

                   Select line_id
                   Into   l_config_line_id
                   From   oe_order_lines_all
                   Where  ato_line_id = l_line_id
                   And    item_type_code = 'CONFIG';

                 EXCEPTION
                   WHEN OTHERS THEN
                    l_config_line_id := Null;
                 END;
            ELSE
               l_link_to_line_id   := Null;
               l_ato_model_line_id := Null;
               l_config_line_id    := Null;
            END IF;

            l_conc_line_number :=
                   OE_ORDER_MISC_PUB.GET_CONCAT_LINE_NUMBER(l_line_id);

            l_session_id := Get_Session_Id;

         SELECT instance_id
            INTO l_instance_id
            FROM mrp_ap_apps_instances;

            l_insert_flag :=  fnd_profile.value('MRP_ATP_CALC_SD');

            IF nvl(l_insert_flag,'N') = 'Y' THEN
               l_insert_code   := 1;
            ELSE
               l_insert_code   := 2;
            END IF;

            -- Insert into mrp_atp_schedule_temp table

            INSERT INTO MRP_ATP_SCHEDULE_TEMP
            (INVENTORY_ITEM_ID,
          SR_INSTANCE_ID,
             SOURCE_ORGANIZATION_ID,
             CUSTOMER_ID,
             CUSTOMER_SITE_ID,
             DESTINATION_TIME_ZONE,
             QUANTITY_ORDERED,
             UOM_CODE,
             REQUESTED_SHIP_DATE,
             REQUESTED_ARRIVAL_DATE,
             LATEST_ACCEPTABLE_DATE,
             DELIVERY_LEAD_TIME,
             FREIGHT_CARRIER,
             INSERT_FLAG,
             SHIP_METHOD,
             DEMAND_CLASS,
             SHIP_SET_NAME,
             SHIP_SET_ID,
             ARRIVAL_SET_NAME,
             ARRIVAL_SET_ID,
             OVERRIDE_FLAG,
             SESSION_ID,
             ORDER_HEADER_ID,
             ORDER_LINE_ID,
             INVENTORY_ITEM_NAME,
             SOURCE_ORGANIZATION_CODE,
             ORDER_LINE_NUMBER,
             SHIPMENT_NUMBER,
             OPTION_NUMBER,
             PROMISE_DATE,
             CUSTOMER_NAME,
             CUSTOMER_LOCATION,
             OLD_LINE_SCHEDULE_DATE,
             OLD_SOURCE_ORGANIZATION_CODE,
             CALLING_MODULE,
             ACTION,
             STATUS_FLAG,
             SCENARIO_ID,
             ATP_LEAD_TIME,
             ORDER_NUMBER,
             OLD_SOURCE_ORGANIZATION_ID,
             OLD_DEMAND_CLASS,
             PROJECT_ID,
             TASK_ID,
             PROJECT_NUMBER,
             TASK_NUMBER,
             SHIP_METHOD_TEXT,
             TOP_MODEL_LINE_ID,
             ATO_MODEL_LINE_ID,
             PARENT_LINE_ID,
             VALIDATION_ORG,
             COMPONENT_SEQUENCE_ID,
             COMPONENT_CODE,
             INCLUDED_ITEM_FLAG,
             LINE_NUMBER,
             CONFIG_ITEM_LINE_ID
             )
            VALUES
            (l_inventory_item_id,
             l_instance_id,
             l_ship_from_org_id,  --null -- Bug 2913742
             l_sold_to_org_id, -- CUSTOMER_ID
             l_ship_to_org_id, -- CUSTOMER_SITE_ID
             null,  -- DESTINATION_TIME_ZONE
             l_quantity_ordered,
             l_uom_code,
             l_requested_ship_date,
             l_requested_arrival_date,
             l_latest_acceptable_date,
             l_delivery_lead_time,
             l_freight_carrier,
             l_insert_code,
             l_ship_method,
             l_demand_class,
             l_ship_set_name,
             l_ship_set_id_1,
             l_arrival_set_name,
             l_arrival_set_id,
             null, -- OVERRIDE_FLAG
             l_session_id,
             l_header_id,
             l_line_id,
             l_ordered_item, -- l_INVENTORY_ITEM_NAME,
             null, -- l_SOURCE_ORGANIZATION_CODE,
             l_line_number,
             l_shipment_number,
             l_option_number,
             l_promise_date,
             l_customer_name,
             l_customer_location,
             null, -- l_OLD_LINE_SCHEDULE_DATE,
             null, -- l_OLD_SOURCE_ORGANIZATION_CODE,
             null, -- l_CALLING_MODULE,
             100,
             4, -- l_STATUS_FLAG,
             l_scenario_id,
             l_atp_lead_time,
             l_order_number,
             l_ship_from_org_id,
             l_demand_class,
             l_project_id,
             l_task_id,
             l_project_number,
             l_task_number,
             l_ship_method_text,
             l_top_model_line_id,
             l_ato_model_line_id,
             l_link_to_line_id,
             OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'),
             l_component_sequence_id,
             l_component_code,
             1 , --l_included_item_flag
             l_conc_line_number,
             l_config_line_id
             );

             IF (l_ship_set_id is not null OR
                l_arrival_set_id is not null OR
                nvl(l_smc_flag,'N') = 'Y' OR
                l_ato_line_id is not null) THEN

                --p_line_id := l_line_id;
                -- IF the line being passed to MRP is in a Ship Set,
                -- or arrival set, we should get the remaining lines
                -- of the set and pass them to MRP too.

                IF l_arrival_set_id is not null THEN
                   p_arrival_set_id    := l_arrival_set_id;
                   p_ship_set_id       := null;
                   p_top_model_line_id := null;
                   p_ato_line_id       := null;

                   OPEN set_lines(p_header_id         => l_header_id,
                                  p_line_id           => p_line_id,
                                  p_arrival_set_id    => p_arrival_set_id,
                                  p_ship_set_id       => p_ship_set_id,
                                  p_top_model_line_id => p_top_model_line_id,
                                  p_ato_line_id       => p_ato_line_id);

                ELSIF l_ship_set_id is not null THEN

                   p_arrival_set_id    := null;
                   p_ship_set_id       := l_ship_set_id;
                   p_top_model_line_id := null;
                   p_ato_line_id       := null;

                   OPEN set_lines(p_header_id         => l_header_id,
                                  p_line_id           => p_line_id,
                                  p_arrival_set_id    => p_arrival_set_id,
                                  p_ship_set_id       => p_ship_set_id,
                                  p_top_model_line_id => p_top_model_line_id,
                                  p_ato_line_id       => p_ato_line_id);

                ELSIF l_smc_flag is not null THEN
                   p_arrival_set_id    := null;
                   p_ship_set_id       := null;
                   p_top_model_line_id := l_top_model_line_id;
                   p_ato_line_id       := null;

                   OPEN set_lines(p_header_id         => l_header_id,
                                  p_line_id           => p_line_id,
                                  p_arrival_set_id    => p_arrival_set_id,
                                  p_ship_set_id       => p_ship_set_id,
                                  p_top_model_line_id => p_top_model_line_id,
                                  p_ato_line_id       => p_ato_line_id);

                ELSIF l_ato_line_id is not null THEN
                   p_arrival_set_id    := null;
                   p_ship_set_id       := null;
                   p_top_model_line_id := null;
                   p_ato_line_id       := l_ato_line_id;

                   OPEN set_lines(p_header_id         => l_header_id,
                                  p_line_id           => p_line_id,
                                  p_arrival_set_id    => p_arrival_set_id,
                                  p_ship_set_id       => p_ship_set_id,
                                  p_top_model_line_id => p_top_model_line_id,
                                  p_ato_line_id       => p_ato_line_id);
                END IF;
                LOOP
                   FETCH set_lines
                   INTO l_line_id,
                        l_header_id,
                        l_inventory_item_id,
                        l_ordered_item,
                        l_sold_to_org_id,
                        l_ship_to_org_id,
                        l_ship_from_org_id,
                        l_demand_class,
                        l_quantity_ordered,
                        l_uom_code,
                        l_latest_acceptable_date,
                        l_line_number,
                        l_shipment_number,
                        l_option_number,
                        l_delivery_lead_time,
                        l_request_date,
                        l_promise_date,
                        l_project_id,
                        l_task_id,
                        l_ship_method,
                        l_ship_set_id,
                        l_arrival_set_id,
                        l_link_to_line_id,
                        l_ato_line_id, -- 3730998
                        l_item_type_code,
                        l_top_model_line_id,
                        l_component_sequence_id,
                        l_component_code;
                   EXIT WHEN set_lines%NOTFOUND;


                   l_project_number    := l_project_id;
                   l_task_number       := l_task_id;
                   l_ship_method_text  := l_ship_method;

                   IF l_sold_to_org_id is not null
                   THEN
                      BEGIN
                         SELECT NAME
                         INTO l_customer_name
                         FROM OE_SOLD_TO_ORGS_V
                         WHERE organization_id = l_sold_to_org_id;
                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            l_customer_name     := null;
                      END;
                   END IF;

                   IF l_ship_to_org_id is not null
                   THEN
                      BEGIN
                         SELECT NAME
                         INTO l_customer_location
                         FROM OE_SHIP_TO_ORGS_V
                         WHERE organization_id = l_ship_to_org_id;
                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            l_customer_location := null;
                      END;
                   END IF;

                   IF l_ship_set_id is not null
                   THEN
                      BEGIN
                         SELECT SET_NAME
                         INTO l_ship_set_name
                         FROM OE_SETS
                         WHERE set_id = l_ship_set_id;
                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            l_ship_set_name := null;
                      END;
                   END IF;

                   IF l_arrival_set_id is not null
                   THEN
                      BEGIN
                         SELECT SET_NAME
                         INTO l_arrival_set_name
                         FROM OE_SETS
                         WHERE set_id = l_arrival_set_id;
                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            l_arrival_set_name := null;
                      END;
                   END IF;

                   IF l_order_date_type_code = 'ARRIVAL' THEN
                      l_requested_arrival_date := l_request_date;
                      IF l_requested_arrival_date is null THEN
                         l_requested_arrival_date := SYSDATE;
                      END IF;
                      l_requested_ship_date := null;
                   ELSE
                      l_requested_ship_date := l_request_date;
                      IF l_requested_ship_date is null THEN
                         l_requested_ship_date := SYSDATE;
                      END IF;
                      l_requested_arrival_date := null;
                   END IF;

                   -- Pack-J changes
                   IF l_ato_line_id is not null AND
                   NOT (l_ato_line_id = l_line_id AND
                        l_item_type_code in ('STANDARD','OPTION','INCLUDED'))
			--9775352
                   THEN

                        l_ato_model_line_id := l_ato_line_id;

                        BEGIN

                          Select line_id
                          Into   l_config_line_id
                          From   oe_order_lines_all
                          Where  ato_line_id = l_line_id
                          And    item_type_code = 'CONFIG';

                        EXCEPTION
                          WHEN OTHERS THEN
                           l_config_line_id := Null;
                        END;
                   ELSE
                      l_link_to_line_id   := Null;
                      l_ato_model_line_id := Null;
                      l_config_line_id    := Null;
                   END IF;

                   l_conc_line_number :=
                          OE_ORDER_MISC_PUB.GET_CONCAT_LINE_NUMBER(l_line_id);


                   -- Insert into mrp_atp_schedule_temp table

                   INSERT INTO MRP_ATP_SCHEDULE_TEMP
                   (INVENTORY_ITEM_ID,
                 SR_INSTANCE_ID,
                    SOURCE_ORGANIZATION_ID,
                    CUSTOMER_ID,
                    CUSTOMER_SITE_ID,
                    DESTINATION_TIME_ZONE,
                    QUANTITY_ORDERED,
                    UOM_CODE,
                    REQUESTED_SHIP_DATE,
                    REQUESTED_ARRIVAL_DATE,
                    LATEST_ACCEPTABLE_DATE,
                    DELIVERY_LEAD_TIME,
                    FREIGHT_CARRIER,
                    INSERT_FLAG,
                    SHIP_METHOD,
                    DEMAND_CLASS,
                    SHIP_SET_NAME,
                    SHIP_SET_ID,
                    ARRIVAL_SET_NAME,
                    ARRIVAL_SET_ID,
                    OVERRIDE_FLAG,
                    SESSION_ID,
                    ORDER_HEADER_ID,
                    ORDER_LINE_ID,
                    INVENTORY_ITEM_NAME,
                    SOURCE_ORGANIZATION_CODE,
                    ORDER_LINE_NUMBER,
                    SHIPMENT_NUMBER,
                    OPTION_NUMBER,
                    PROMISE_DATE,
                    CUSTOMER_NAME,
                    CUSTOMER_LOCATION,
                    OLD_LINE_SCHEDULE_DATE,
                    OLD_SOURCE_ORGANIZATION_CODE,
                    CALLING_MODULE,
                    ACTION,
                    STATUS_FLAG,
                    SCENARIO_ID,
                    ATP_LEAD_TIME,
                    ORDER_NUMBER,
                    OLD_SOURCE_ORGANIZATION_ID,
                    OLD_DEMAND_CLASS,
                    PROJECT_ID,
                    TASK_ID,
                    PROJECT_NUMBER,
                    TASK_NUMBER,
                    SHIP_METHOD_TEXT,
                    TOP_MODEL_LINE_ID,
                    ATO_MODEL_LINE_ID,
                    PARENT_LINE_ID,
                    VALIDATION_ORG,
                    COMPONENT_SEQUENCE_ID,
                    COMPONENT_CODE,
                    INCLUDED_ITEM_FLAG,
                    LINE_NUMBER,
                    CONFIG_ITEM_LINE_ID
                    )
                   VALUES
                   (l_inventory_item_id,
                    l_instance_id,
                    l_ship_from_org_id,  --null -- Bug 2913742
                    l_sold_to_org_id, -- CUSTOMER_ID
                    l_ship_to_org_id, -- CUSTOMER_SITE_ID
                    null,  -- DESTINATION_TIME_ZONE
                    l_quantity_ordered,
                    l_uom_code,
                    l_requested_ship_date,
                    l_requested_arrival_date,
                    l_latest_acceptable_date,
                    l_delivery_lead_time,
                    l_freight_carrier,
                    l_insert_code,
                    l_ship_method,
                    l_demand_class,
                    l_ship_set_name,
                    l_ship_set_id_1,
                    l_arrival_set_name,
                    l_arrival_set_id,
                    null, -- OVERRIDE_FLAG
                    l_session_id,
                    l_header_id,
                    l_line_id,
                    l_ordered_item, -- l_INVENTORY_ITEM_NAME,
                    null, -- l_SOURCE_ORGANIZATION_CODE,
                    l_line_number,
                    l_shipment_number,
                    l_option_number,
                    l_promise_date,
                    l_customer_name,
                    l_customer_location,
                    null, -- l_OLD_LINE_SCHEDULE_DATE,
                    null, -- l_OLD_SOURCE_ORGANIZATION_CODE,
                    null, -- l_CALLING_MODULE,
                    100,
                    4, -- l_STATUS_FLAG,
                    l_scenario_id,
                    l_atp_lead_time,
                    l_order_number,
                    l_ship_from_org_id,
                    l_demand_class,
                    l_project_id,
                    l_task_id,
                    l_project_number,
                    l_task_number,
                    l_ship_method_text,
                    l_top_model_line_id,
                    l_ato_model_line_id,
                    l_link_to_line_id,
                    OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'),
                    l_component_sequence_id,
                    l_component_code,
                    1 , --l_included_item_flag
                    l_conc_line_number,
                    l_config_line_id
                    );


                END LOOP;
             END IF;

        END IF; /* l_valid */

EXCEPTION
  WHEN OTHERS THEN

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Global_ATP'
       );
    END IF;

END Global_ATP;


Procedure Cascade_Ship_Set_Attr
( p_request_rec     IN  OE_Order_Pub.Request_Rec_Type
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

l_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl        OE_ORDER_PUB.line_tbl_type;
l_control_rec         OE_GLOBALS.control_rec_type;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(2000);
BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING Cascade Set Attr ' , 1 ) ;
      oe_debug_pub.add(  'Header_id  ' || p_request_rec.param1 , 2 ) ;
      oe_debug_pub.add(  'Ship_Set_id  ' || p_request_rec.param2 , 2 ) ;
      oe_debug_pub.add(  'Shipping Method  ' || p_request_rec.param3 , 2 ) ;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

     Oe_Config_Schedule_Pvt.Query_Set_Lines
        (p_header_id     => p_request_rec.param1,
         p_ship_set_id   => p_request_rec.param2,
         p_sch_action    => 'UI_ACTION',
         x_line_tbl      => l_line_tbl,
         x_return_status  => x_return_status);

     l_old_line_tbl := l_line_tbl;

     FOR I IN 1..l_line_tbl.count LOOP

       l_line_tbl(I).shipping_method_code := p_request_rec.param3;
       l_line_tbl(I).operation := OE_GLOBALS.G_OPR_UPDATE;

     END LOOP;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'Before calling Process Order from cascade ' , 2 ) ;
    END IF;
    Call_Process_Order(p_x_old_line_tbl  => l_old_line_tbl,
                       p_x_line_tbl      => l_line_tbl,
                       p_control_rec     => l_control_rec,
                       p_caller          => 'SCH_INTERNAL',
                       x_return_status   => x_return_status);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'After calling Po : '  || x_return_status, 2 ) ;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    OE_Order_PVT.Process_Requests_And_Notify
    ( p_process_requests        => TRUE
    , p_notify                  => FALSE
    , p_line_tbl                => l_line_tbl
    , p_old_line_tbl            => l_old_line_tbl
    , x_return_status           => x_return_status);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'After calling PRN: '  || x_return_status, 2 ) ;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OE_Set_Util.Update_Set
        (p_Set_Id                   => p_request_rec.param2,
         p_Shipping_Method_Code     => p_request_rec.param3,
         X_Return_Status            => x_return_status,
         x_msg_count                => l_msg_count,
         x_msg_data                 => l_msg_data
        );

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Exiting Cascade Set Attr ' , 1 ) ;
   END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Cascade_Ship_set_attr'
       );
    END IF;

END Cascade_Ship_set_attr;

/* Added the following 2 procedures to fix the bug 6378240  */

/*---------------------------------------------------------------------
Procedure Name : MRP_ROLLBACK
Description    : Call MRP API to rollback the changes as the changes
                 on the line are being rollbacked.
                 Added this procedure to fix the bugs 6015417 , 6053872
--------------------------------------------------------------------- */

Procedure MRP_ROLLBACK
( p_line_id IN NUMBER
 ,p_schedule_action_code IN VARCHAR2
 ,x_return_status OUT NOCOPY VARCHAR2)

IS
l_msg_count               NUMBER;
l_session_id              NUMBER := 0;
l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
l_out_mrp_atp_rec         MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
l_mrp_msg_data            VARCHAR2(200);
l_old_line_rec            OE_Order_Pub.Line_Rec_Type;
l_new_line_rec            OE_Order_Pub.Line_Rec_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING CALL MRP ROLLBACK' , 1 ) ;
   END IF;

      OE_Line_Util.Query_Row(p_line_id  => p_line_id,
                             x_line_rec => l_old_line_rec);
      l_old_line_rec.schedule_action_code := p_schedule_action_code ;
      -- l_old_line_rec.schedule_action_code := OE_SCHEDULE_UTIL.OESCH_ACT_UNSCHEDULE;
   l_new_line_rec := l_old_line_rec;
   Load_MRP_request_from_rec
       ( p_line_rec              => l_new_line_rec
       , p_old_line_rec          => l_old_line_rec
       , x_mrp_atp_rec             => l_mrp_atp_rec);


   IF l_mrp_atp_rec.error_code.count > 0 THEN
      l_session_id := Get_Session_Id;

      -- Call ATP

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  '1. CALLING MRP API WITH SESSION ID '||L_SESSION_ID , 0.5 ) ; -- debug level changed to 0.5 for bug 13435459
       END IF;

       MRP_ATP_PUB.Call_ATP
              (  p_session_id             =>  l_session_id
               , p_atp_rec                =>  l_mrp_atp_rec
               , x_atp_rec                =>  l_out_mrp_atp_rec
               , x_atp_supply_demand      =>  l_atp_supply_demand
               , x_atp_period             =>  l_atp_period
               , x_atp_details            =>  l_atp_details
               , x_return_status          =>  x_return_status
               , x_msg_data               =>  l_mrp_msg_data
               , x_msg_count              =>  l_msg_count);

       IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  '3. AFTER CALLING MRP_ATP_PUB.CALL_ATP' || X_RETURN_STATUS , 0.5 ) ; -- debug level changed to 0.5 for bug 13435459
       END IF;

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF  x_return_status = FND_API.G_RET_STS_ERROR THEN
             Display_sch_errors(p_atp_rec => l_out_mrp_atp_rec,
                                p_line_id => p_line_id);
             RAISE FND_API.G_EXC_ERROR;
       END IF;

       Load_Results_from_rec(p_atp_rec       => l_out_mrp_atp_rec,
                             p_x_line_rec    => l_new_line_rec,
                             x_return_status => x_return_status);

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

   END IF; -- Mrp count.
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING CALL MRP ROLLBACK ' , 1 ) ;
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

/*
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'MRP_ROLLBACK');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
*/
END MRP_ROLLBACK;

Procedure CALL_MRP_ROLLBACK
( x_return_status OUT NOCOPY VARCHAR2)

IS

l_status VARCHAR2(1);
CURSOR C1 is
select line_id , schedule_action_code
from oe_schedule_lines_temp;

BEGIN

 oe_debug_pub.add(  '6015417,6053872 : in call_mrp_rollback  ');
 for rec in C1 loop
       oe_debug_pub.add(  '6015417,6053872 : line_id  '||rec.line_id ||'  ' ||rec.schedule_action_code);
       if rec.schedule_action_code = 'SCHEDULE' then
           MRP_ROLLBACK
            ( p_line_id  =>  rec.line_id
             ,p_schedule_action_code  =>  OESCH_ACT_UNSCHEDULE
             ,x_return_status    => l_status);
           --8731703
             IF OE_SCH_CONC_REQUESTS.g_conc_program = 'Y' THEN
                OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(rec.line_id) := 'N';
             END IF;
        end if;
 end loop;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

/*
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Call_MRP_ROLLBACK');
        END IF;
*/
END CALL_MRP_ROLLBACK;

/* Added the following to fix the bug 6663462 */


Procedure DELAYED_SCHEDULE_LINES
( x_return_status OUT NOCOPY VARCHAR2)

IS

l_status VARCHAR2(1);
j        NUMBER;
i        NUMBER := 0 ;
l_atp_tbl OE_ATP.Atp_Tbl_Type;
l_return_status   VARCHAR2(1);
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(2000);
l_line_tbl                OE_ORDER_PUB.Line_tbl_type;
l_old_line_tbl            OE_ORDER_PUB.Line_tbl_type;
l_line_rec OE_Order_PUB.Line_Rec_Type; --Bug 8652339
BEGIN
  oe_debug_pub.add(  '6663462 : in schedule_delayed_lines ');

  --Bug 8652339 : Initialize l_line_tbl from OE_ORDER_LINES_ALL table
  --using OE_LINE_UTIL.QUERY_ROW instead of following.
  --l_line_tbl := OE_SCHEDULE_UTIL.OE_Delayed_Schedule_line_tbl;
  for j in 1..OE_SCHEDULE_UTIL.OE_Delayed_Schedule_line_tbl.count loop

    BEGIN

       oe_line_util.query_row(p_line_id => OE_SCHEDULE_UTIL.OE_Delayed_Schedule_line_tbl(j).line_id
                              ,x_line_rec => l_line_rec
                          );
       i := i + 1 ;
       l_line_tbl(i) := l_line_rec;

    EXCEPTION

/* added the exception handler to fix the bug 11814008  */

      WHEN NO_DATA_FOUND THEN
        NULL;

    END;
  end loop;

  l_old_line_tbl := l_line_tbl;
  for j in 1..l_line_tbl.count LOOP
       oe_debug_pub.add(  ' 6663462  : line_id   '|| l_line_tbl(j).line_id );
       l_line_tbl(j).operation := OE_GLOBALS.G_OPR_UPDATE; --6715950
  end loop;
  oe_debug_pub.add(  ' 6663462  : calling process group ' );
  IF l_line_tbl.count > 0 THEN

     Oe_Config_Schedule_Pvt.Process_Group
       (p_x_line_tbl     => l_line_tbl
       ,p_old_line_tbl   => l_old_line_tbl
       ,p_caller         => 'UI_ACTION'
       ,p_sch_action     => 'SCHEDULE'
       ,p_partial        => TRUE
       ,x_return_status  => x_return_status);

     OE_SCHEDULE_UTIL.OE_Delayed_Schedule_line_tbl.delete;

  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END DELAYED_SCHEDULE_LINES ;

/*----------------------------------------------------------------------------------
* PROCEDURE IS_ITEM_SUBSTITUTED
* Added for ER 6110708. This API will be used for Item Substituted Validation template.
* ------------------------------------------------------------------------------------*/
PROCEDURE IS_ITEM_SUBSTITUTED
(
  p_application_id    IN  NUMBER
, p_entity_short_name   IN  VARCHAR2
, p_validation_entity_short_name  IN  VARCHAR2
, p_validation_tmplt_short_name IN  VARCHAR2
, p_record_set_short_name     IN  VARCHAR2
, p_scope             IN  VARCHAR2
, x_result_out OUT NOCOPY NUMBER

)
IS
BEGIN

  IF OE_SCHEDULE_UTIL.OESCH_ITEM_IS_SUBSTITUTED = 'Y' THEN
    x_result_out := 1;
  ELSE
    x_result_out := 0;
  END IF;

END IS_ITEM_SUBSTITUTED;

/*-----------------------------------------------------------------------------------
 * PROCEDURE IS_LINE_PICKED
 * Added for ER 6110708. This API will be used for Not Picked Validation template.
 * ----------------------------------------------------------------------------------*/
PROCEDURE IS_LINE_PICKED
(
  p_application_id    IN  NUMBER
, p_entity_short_name   IN  VARCHAR2
, p_validation_entity_short_name  IN  VARCHAR2
, p_validation_tmplt_short_name IN  VARCHAR2
, p_record_set_short_name     IN  VARCHAR2
, p_scope             IN  VARCHAR2
, x_result_out OUT NOCOPY NUMBER

)
IS

  CURSOR C_IS_LINE_PICKED
  IS
  SELECT PICK_STATUS
  FROM   WSH_DELIVERY_LINE_STATUS_V
  WHERE  SOURCE_CODE = 'OE'
  AND    SOURCE_LINE_ID = OE_LINE_SECURITY.g_record.line_id
  AND    PICK_STATUS NOT IN ('N', 'R', 'X', 'B'); --Added 'B', (Backordered Status) for bug 8521082

  l_pick_status VARCHAR2(1);

BEGIN

  OPEN C_IS_LINE_PICKED;
  FETCH C_IS_LINE_PICKED into l_pick_status;

  /* If there is atleast one delivery for the current line which is not having the pick status of N,R and X,
     that means the delivery has been picked atleast once by Pick Release program. The delivery has gone past the Picking at least once.
  */
  IF C_IS_LINE_PICKED%FOUND THEN
    x_result_out := 1;
  ELSE
    x_result_out := 0;
  END IF;

  CLOSE C_IS_LINE_PICKED;

END IS_LINE_PICKED;

/*----------------------------------------------------------------------------------
 * PROCEDURE VALIDATE_ITEM_SUBSTITUTION
 * Added for ER 6110708. This API will validate the new substitute item before
 * calling process order api.
 * ---------------------------------------------------------------------------------*/
PROCEDURE VALIDATE_ITEM_SUBSTITUTION
(
p_new_inventory_item_id   IN NUMBER,
p_old_inventory_item_id   IN NUMBER,
p_new_ship_from_org_id    IN NUMBER,
p_old_ship_from_org_id    IN NUMBER,
p_old_shippable_flag      IN VARCHAR2
)
IS
  l_shippable_flag  varchar2(1);
BEGIN
   BEGIN
      SELECT shippable_item_flag
      INTO   l_shippable_flag
      FROM   MTL_SYSTEM_ITEMS
      WHERE  INVENTORY_ITEM_ID = p_new_inventory_item_id
      AND    ORGANIZATION_ID = p_new_ship_from_org_id;

      IF l_shippable_flag <> p_old_shippable_flag THEN
           oe_debug_pub.add(  'Item substitution cannot happen between shippable and non-shippable items' , 5 ) ;
           Fnd_Message.set_name('ONT','OE_SCH_LOOP_SHP_NONSHP');
           Oe_Msg_Pub.Add;
           OE_SCHEDULE_UTIL.OESCH_ITEM_IS_SUBSTITUTED := 'N';
           RAISE FND_API.G_EXC_ERROR;
      END IF;
   END;
END VALIDATE_ITEM_SUBSTITUTION;

/*----------------------------------------------------------------------------------
 * PROCEDURE res_against_req_po
 * Added for ER 9224462. This API will validate if there are any reservations of a
 * line against a REQ or PO. If it has, p_result will return 1, else return 0.
 * This API has standard signature as required by Processing Constraints framework,
 * for API based Validation template. Based on this API a Validation template will
 * be created.
 * ---------------------------------------------------------------------------------*/
PROCEDURE res_against_req_po
( p_application_id               IN NUMBER,
  p_entity_short_name            in VARCHAR2,
  p_validation_entity_short_name in VARCHAR2,
  p_validation_tmplt_short_name  in VARCHAR2,
  p_record_set_tmplt_short_name  in VARCHAR2,
  p_scope                        in VARCHAR2,
  p_result                       OUT NOCOPY NUMBER )
IS
l_return_status        VARCHAR2(1);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_reservation_rec      inv_reservation_global.mtl_reservation_rec_type;
l_rsv_tbl              inv_reservation_global.mtl_reservation_tbl_type;
l_count                NUMBER;
l_x_error_code         NUMBER;
l_lock_records         VARCHAR2(1);
l_sort_by_req_date     NUMBER;

l_ordered_quantity NUMBER := -1;
l_reserved_quantity    NUMBER := 0;

BEGIN

If p_validation_entity_short_name = 'LINE' Then

  oe_debug_pub.add('Getting Reservation Details:');
  oe_debug_pub.add('Header :'||OE_LINE_SECURITY.g_record.header_id);
  oe_debug_pub.add('Line :'||OE_LINE_SECURITY.g_record.line_id);

  l_reservation_rec.reservation_id := fnd_api.g_miss_num;
  l_reservation_rec.demand_source_header_id :=
             oe_schedule_util.Get_mtl_sales_order_id(OE_LINE_SECURITY.g_record.header_id);
  l_reservation_rec.demand_source_line_id := OE_LINE_SECURITY.g_record.line_id;
  l_reservation_rec.organization_id  := OE_LINE_SECURITY.g_record.ship_from_org_id;

  inv_reservation_pub.query_reservation
           ( p_api_version_number        => 1.0
           , p_init_msg_lst              => fnd_api.g_true
           , x_return_status             => l_return_status
           , x_msg_count                 => l_msg_count
           , x_msg_data                  => l_msg_data
           , p_query_input               => l_reservation_rec
           , x_mtl_reservation_tbl       => l_rsv_tbl
           , x_mtl_reservation_tbl_count => l_count
           , x_error_code                => l_x_error_code
           , p_lock_records              => l_lock_records
           , p_sort_by_req_date          => l_sort_by_req_date
           );


  oe_debug_pub.add('After Querying Reservations');

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    oe_debug_pub.add('Error Code :'||l_x_error_code);
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    oe_debug_pub.add('Error Code :'||l_x_error_code);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  oe_debug_pub.add('Total Number of Reservation Records:'||l_rsv_tbl.count);

  FOR K IN 1..l_rsv_tbl.count LOOP
    oe_debug_pub.add('Supply_source '||k||' :'||l_rsv_tbl(K).supply_source_type_id);
    oe_debug_pub.add('Demand_source '||k||' :'||l_rsv_tbl(K).demand_source_type_id);
    IF l_rsv_tbl(K).supply_source_type_id IN (1,17) THEN
       	p_result := 1; --Return 1;
    	oe_debug_pub.add('There is some Qty Reserved against Req/Purchase Order. Return Value from Validation Pkg :'||p_result);
    	return;
    END IF;
  END LOOP;

  p_result := 0; --Return 0;
  oe_debug_pub.add('There are no reservations against Req/Purchase Order. Return Value from Validation Pkg :'||p_result);

END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    oe_debug_pub.add('Unexpected Error'||l_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    oe_debug_pub.add('Expected Error'||l_msg_data);
END res_against_req_po;

/*4241385*/
/*----------------------------------------------------------------------------------
 * PROCEDURE GET_SET_DETAILS
 * Added for ER 4241385. This API will take set_id as the input parameter and return
 whether the set exists or not (new set, or exisitng set) and if the set exisits,
 whether it is scheduled or not.
 * ---------------------------------------------------------------------------------*/
PROCEDURE get_set_details
  (
    p_set_id IN NUMBER ,
    x_set_exists OUT NOCOPY BOOLEAN ,
    x_set_scheduled OUT NOCOPY BOOLEAN )
                                IS
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_ship_date DATE ;
  l_arrival_date DATE ;
BEGIN
    IF l_debug_level >0 THEN
      oe_debug_pub.ADD('in get_Set_details-set_id is:'||p_set_id);
    END IF ;
	SELECT schedule_ship_date,
               schedule_arrival_date
        INTO   l_ship_date,
               l_arrival_date
        FROM oe_sets
        WHERE set_id=p_set_id;

        x_set_exists     := TRUE ;
           IF l_ship_date   IS NULL
	   AND l_arrival_date IS NULL THEN
                 x_set_scheduled:= FALSE ;
           ELSE
                 x_set_scheduled:= TRUE ;
           END IF ;
  --check the debug level commands.
              IF l_debug_level >0 THEN
                 IF x_set_exists THEN
                   oe_debug_pub.ADD('set exists');
                    IF x_set_scheduled THEN
                       oe_debug_pub.ADD('set is scheduled');
                    ELSE
                        oe_debug_pub.ADD('set is not scheduled.');
                     END IF ;
                 END IF ;
              END IF ;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  x_set_exists    := FALSE;
  IF l_debug_level >0 THEN
    oe_debug_pub.ADD('in no data found exception. set does not exists');
  END IF ;
WHEN OTHERS THEN
  IF l_debug_level >0 THEN
    oe_debug_pub.ADD('error in get_set_details:'||SQLERRM,5);
  END IF ;
END get_set_details ;
/*4241385*/
END OE_SCHEDULE_UTIL;

/
