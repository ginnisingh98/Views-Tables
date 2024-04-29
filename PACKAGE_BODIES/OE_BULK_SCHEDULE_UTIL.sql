--------------------------------------------------------
--  DDL for Package Body OE_BULK_SCHEDULE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BULK_SCHEDULE_UTIL" AS
/* $Header: OEBUSCHB.pls 120.2.12010000.4 2008/11/18 13:37:58 smusanna ship $ */


G_PKG_NAME         CONSTANT     VARCHAR2(30):='OE_BULK_SCHEDULE_UTIL';


G_INSERT_FLAG      NUMBER;
G_HEADER_ID        NUMBER       := null;
G_DATE_TYPE        VARCHAR2(30) := null;

TYPE Schedule_Error_Rec_Type IS RECORD
(line_index           NUMBER
,error_code           NUMBER
);

TYPE Schedule_Error_Tbl_Type IS TABLE OF Schedule_Error_Rec_Type
INDEX BY BINARY_INTEGER;

G_SCH_ERROR_TBL         Schedule_Error_Tbl_Type;

-- BYPASS ATP
PROCEDURE Inactive_Demand_Scheduling
( p_line_rec    IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
, x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE Insert_Error_Messages
(p_line_rec                 IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
)
IS
  l_no_source_msg             VARCHAR2(2000);
  l_sch_error_msg             VARCHAR2(2000);
  l_index                     NUMBER;
  l_error_code                NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

 ---------------------------------------------------------------------
 -- For order lines that failed scheduling:
 -- Insert Error Messages
 ---------------------------------------------------------------------
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ERROR COUNT :'||G_SCH_ERROR_TBL.COUNT ) ;
 END IF;

 l_no_source_msg := FND_MESSAGE.GET_STRING('ONT','OE_SCH_NO_SOURCE');
 l_sch_error_msg := FND_MESSAGE.GET_STRING('ONT','OE_BULK_SCH_FAILED');

 -- Error codes of 0,-99,150 should be ignored
 -- Error code of 19 indicates that this is a line in an SMC set where
 -- one of the other lines in the set could not be scheduled.
 -- Need not insert a message as message will be populated for
 -- the lines that failed.

 FOR I IN 1..G_SCH_ERROR_TBL.COUNT LOOP
     l_index := G_SCH_ERROR_TBL(I).line_index;
     l_error_code := G_SCH_ERROR_TBL(I).error_code;
     INSERT INTO OE_PROCESSING_MSGS
     ( request_id ,entity_code ,entity_ref ,entity_id ,header_id, line_id
     ,order_source_id ,original_sys_document_ref
     ,original_sys_document_line_ref ,orig_sys_shipment_ref ,change_sequence
     ,attribute_code ,creation_date ,created_by ,last_update_date
     ,last_updated_by ,last_update_login
     ,program_application_id ,program_id,program_update_date
     ,process_activity ,notification_flag ,type
     ,message_source_code ,language
     ,message_text
     ,transaction_id
    )
    SELECT
     OE_Bulk_Order_PVT.G_REQUEST_ID,'LINE' ,NULL
     ,p_line_rec.line_id(l_index)
     ,p_line_rec.header_id(l_index)
     ,p_line_rec.line_id(l_index)
     ,p_line_rec.order_source_id(l_index)
     ,p_line_rec.orig_sys_document_ref(l_index)
     ,p_line_rec.orig_sys_line_ref(l_index)
     ,p_line_rec.orig_sys_shipment_ref(l_index)
     ,p_line_rec.change_sequence(l_index)
     ,NULL, sysdate, FND_GLOBAL.USER_ID ,sysdate
     ,FND_GLOBAL.USER_ID ,FND_GLOBAL.CONC_LOGIN_ID
     ,660 ,NULL ,NULL
     ,NULL ,NULL ,NULL
     ,'C' ,USERENV('LANG')
     ,decode(l_error_code,80,l_no_source_msg
                      , l_sch_error_msg||m.meaning)
     ,OE_MSG_ID_S.NEXTVAL
    FROM MFG_LOOKUPS m
    WHERE l_error_code NOT IN (0,-99,150,19)
       AND m.lookup_code(+) = l_error_code
       AND m.lookup_type(+) = 'MTL_DEMAND_INTERFACE_ERRORS';
  END LOOP;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNEXP ERROR , INSERT_ERROR_MESSAGE' ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , INSERT_ERROR_MESSAGES' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Insert_Error_Messages'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Insert_Error_Messages;

--BYPASS ATP
PROCEDURE Inactive_Demand_Scheduling
( p_line_rec    IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
, x_return_status OUT NOCOPY VARCHAR2
)
IS
l_order_date_type_code VARCHAR2(30);
l_promise_date_flag    VARCHAR2(2);
I  NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING INACTIVE_DEMAND_SCHEDULING' , 1 ) ;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   FOR I IN 1..p_line_rec.line_id.count
   LOOP
      oe_bulk_msg_pub.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => p_line_rec.line_id(I)
         ,p_header_id                   => p_line_rec.header_id(I)
         ,p_line_id                     => p_line_rec.line_id(I)
         ,p_orig_sys_document_ref       => p_line_rec.orig_sys_document_ref(I)
         ,p_orig_sys_document_line_ref  => p_line_rec.orig_sys_line_ref(I)
         ,p_source_document_id          => NULL
         ,p_source_document_line_id     => NULL
         ,p_order_source_id             => p_line_rec.order_source_id(I)
         ,p_source_document_type_id     => NULL );

      l_order_date_type_code :=
            NVL(Get_Date_Type(p_line_rec.header_id(I)), 'SHIP');
      IF l_order_date_type_code = 'SHIP' THEN
         IF p_line_rec.schedule_ship_date(I) IS NOT NULL AND
            p_line_rec.schedule_ship_date(I) <> FND_API.G_MISS_DATE THEN
            -- If the user provides a ship_date, or changes the existing, use it
            p_line_rec.schedule_arrival_date(I) :=
                                            p_line_rec.schedule_ship_date(I);

         ELSE
           -- if the user changed request date, use it
           p_line_rec.schedule_ship_date(I) := p_line_rec.request_date(I);
           p_line_rec.schedule_arrival_date(I) := p_line_rec.request_date(I);
         END IF;
      ELSE -- Arrival
         IF p_line_rec.schedule_arrival_date(I) IS NOT NULL AND
            p_line_rec.schedule_arrival_date(I) <> FND_API.G_MISS_DATE THEN
            -- If the user provides a arrival_date, or changes the existing, use it
            p_line_rec.schedule_ship_date(I) :=
                                            p_line_rec.schedule_arrival_date(I);
         ELSE
           -- if the user changed request date, use it
           p_line_rec.schedule_ship_date(I) := p_line_rec.request_date(I);
           p_line_rec.schedule_arrival_date(I) := p_line_rec.request_date(I);
         END IF;
      END IF;
      -- we want this line scheduled, but not visible for demand
      p_line_rec.visible_demand_flag(I) := 'N';
      p_line_rec.schedule_status_code(I) := 'SCHEDULED';
      /*
      -- Latest Acceptable date violation check (Set to Ignore)
      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
         IF OE_SYS_PARAMETERS.value('LATEST_ACCEPTABLE_DATE_FLAG')='I' THEN
            IF ((l_order_date_type_code = 'SHIP'
              AND p_line_rec.schedule_ship_date(I)
                            > p_line_rec.latest_acceptable_date(I))
              OR (l_order_date_type_code = 'ARRIVAL'
             AND p_line_rec.schedule_arrival_date(I)
                            > p_line_rec.latest_acceptable_date(I))) THEN
               FND_MESSAGE.SET_NAME('ONT','ONT_SCH_LAD_VIOLATE');
               OE_BULK_MSG_PUB.Add;
            END IF;
         END IF;
         -- Get the Promise date flag
         l_promise_date_flag := Oe_sys_Parameters.Value('PROMISE_DATE_FLAG');
         -- Set the Promise date with schedule ship date
         IF l_promise_date_flag IN('FS','S') THEN
            IF l_order_date_type_code = 'SHIP'
             AND p_line_rec.schedule_ship_date(I) IS NOT NULL THEN
              p_line_rec.promise_date(I) := p_line_rec.schedule_ship_date(I);
            ELSIF l_order_date_type_code = 'ARRIVAL'
             AND p_line_rec.schedule_arrival_date(I) IS NOT NULL THEN
              p_line_rec.promise_date(I) := p_line_rec.schedule_arrival_date(I);
            END IF;
         ELSIF l_promise_date_flag IN('FR','R') THEN -- Set the Promise date with Request Date
            p_line_rec.promise_date(I) := p_line_rec.request_date(I);
         END IF;
         IF Oe_Sys_Parameters.Value('FIRM_DEMAND_EVENTS') = 'SCHEDULE' THEN
           p_line_rec.firm_demand_flag(I)   := 'Y';
         END IF;
      END IF;
      */
   END LOOP;

END Inactive_Demand_Scheduling;

PROCEDURE Extend_MRP_Rec
(p_count                    IN NUMBER
,p_x_atp_rec                IN OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  p_x_atp_rec.Inventory_Item_Id.extend(p_count);
  p_x_atp_rec.Source_Organization_Id.extend(p_count);
  p_x_atp_rec.Identifier.extend(p_count);
  p_x_atp_rec.Order_Number.extend(p_count);
  p_x_atp_rec.Calling_Module.extend(p_count);
  p_x_atp_rec.Customer_Id.extend(p_count);
  p_x_atp_rec.Customer_Site_Id.extend(p_count);
  p_x_atp_rec.Destination_Time_Zone.extend(p_count);
  p_x_atp_rec.Quantity_Ordered.extend(p_count);
  p_x_atp_rec.Quantity_UOM.extend(p_count);
  p_x_atp_rec.Requested_Ship_Date.extend(p_count);
  p_x_atp_rec.Requested_Arrival_Date.extend(p_count);
  p_x_atp_rec.Earliest_Acceptable_Date.extend(p_count);
  p_x_atp_rec.Latest_Acceptable_Date.extend(p_count);
  p_x_atp_rec.Delivery_Lead_Time.extend(p_count);
  p_x_atp_rec.Atp_Lead_Time.extend(p_count);
  p_x_atp_rec.Freight_Carrier.extend(p_count);
  p_x_atp_rec.Ship_Method.extend(p_count);
  p_x_atp_rec.Demand_Class.extend(p_count);
  p_x_atp_rec.Ship_Set_Name.extend(p_count);
  p_x_atp_rec.Arrival_Set_Name.extend(p_count);
  p_x_atp_rec.Override_Flag.extend(p_count);
  p_x_atp_rec.Action.extend(p_count);
  p_x_atp_rec.ship_date.extend(p_count);
  p_x_atp_rec.Available_Quantity.extend(p_count);
  p_x_atp_rec.Requested_Date_Quantity.extend(p_count);
  p_x_atp_rec.Group_Ship_Date.extend(p_count);
  p_x_atp_rec.Group_Arrival_Date.extend(p_count);
  p_x_atp_rec.Vendor_Id.extend(p_count);
  p_x_atp_rec.Vendor_Site_Id.extend(p_count);
  p_x_atp_rec.Insert_Flag.extend(p_count);
  p_x_atp_rec.Error_Code.extend(p_count);
  p_x_atp_rec.Message.extend(p_count);
  p_x_atp_rec.Old_Source_Organization_Id.extend(p_count);
  p_x_atp_rec.Old_Demand_Class.extend(p_count);
  p_x_atp_rec.oe_flag.extend(p_count);
  p_x_atp_rec.ato_delete_flag.extend(p_count);
  p_x_atp_rec.attribute_01.extend(p_count);
  p_x_atp_rec.attribute_05.extend(p_count);
  p_x_atp_rec.substitution_typ_code.extend(p_count); --BUG 4494602
  p_x_atp_rec.req_item_detail_flag.extend(p_count);  --BUG 4494602
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNEXP ERROR , EXTEND_MRP_REC' ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , EXTEND_MRP_REC' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Extend_MRP_Rec'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Extend_MRP_Rec;

FUNCTION Get_Lead_Time
(
 p_ato_index      IN NUMBER
,p_line_rec       IN OE_WSH_BULK_GRP.LINE_REC_TYPE

)
RETURN NUMBER
IS
l_model_ordered_quantity  NUMBER := 0;
l_model_order_qty_uom     NUMBER := 0;
primary_model_qty         NUMBER := 0;
st_lead_time              NUMBER := 0;
db_full_lead_time         NUMBER := 0;
db_fixed_lead_time        NUMBER := 0;
db_variable_lead_time     NUMBER := 0;
--db_primary_uom_code       VARCHAR2(3);
--db_model_item_id          NUMBER := 0;
--db_line_unit_code         VARCHAR2(3);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_org_id  NUMBER;
l_c_index NUMBER;

BEGIN

 IF l_debug_level > 0 THEN
    oe_debug_pub.add('Entering OE_BULK_SCHEDULE_UTIL.Get_Lead_Time');

    oe_debug_pub.add(  'ATO LINE IS ' ||
                         p_line_rec.line_id(p_ato_index) , 1 ) ;

    oe_debug_pub.add(  'SHIP FROM IS ' ||
                          p_line_rec.ship_from_org_id(p_ato_index), 1 ) ;
  END IF;

  l_org_id := nvl(p_line_rec.ship_from_org_id(p_ato_index),
                   OE_BULK_ORDER_PVT.G_ITEM_ORG);

  l_c_index := OE_BULK_CACHE.Load_Item
                    (p_key1 => p_line_rec.inventory_item_id(p_ato_index)
                    ,p_key2 => l_org_id
                    ,p_default_attributes => 'Y');


  db_full_lead_time :=  OE_BULK_CACHE.G_ITEM_TBL(l_c_index).full_lead_time;
  db_fixed_lead_time := OE_BULK_CACHE.G_ITEM_TBL(l_c_index).fixed_lead_time;
  db_variable_lead_time :=
                     OE_BULK_CACHE.G_ITEM_TBL(l_c_index).variable_lead_time;
  primary_model_qty := p_line_rec.ordered_quantity(p_ato_index);

  st_lead_time :=  ceil( nvl(db_fixed_lead_time,0) +
                                      nvl(db_variable_lead_time,0)
                         * nvl(primary_model_qty,0));
  IF nvl(db_full_lead_time,0) > nvl(st_lead_time,0) THEN
     st_lead_time := ceil(db_full_lead_time);
  END IF;

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Exiting OE_BULK_SCHEDULE_UTIL.Get_Lead_Time');
     oe_debug_pub.add('Return st_lead_time :'|| st_lead_time);
  END IF;

  RETURN st_lead_time;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF l_debug_level > 0 THEN
        oe_debug_pub.add('Exiting OE_BULK_SCHEDULE_UTIL.Get_Lead_Time');
        oe_debug_pub.add('No Data Found, Return value = 0 ');
      END IF;

      RETURN 0;
   WHEN OTHERS THEN
      IF l_debug_level > 0 THEN
        oe_debug_pub.add('Exiting OE_BULK_SCHEDULE_UTIL.Get_Lead_Time');
        oe_debug_pub.add('OTHERS, Return value = 0 ');
      END IF;

      RETURN 0;
END Get_Lead_Time;


PROCEDURE Add_MRP_Rec
(p_line_index               IN NUMBER
,p_curr_ato_index           IN NUMBER
,p_header_index             IN NUMBER
,p_atp_index                IN NUMBER
,p_line_rec                 IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
,p_header_rec               IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
,p_x_atp_rec                IN OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level > 0 THEN
    oe_debug_pub.add('Entering OE_BULK_SCHEDULE_UTIL.Add_MRP_Rec');
 END IF;

  p_x_atp_rec.substitution_typ_code(p_atp_index) := 4;  --BUG 4494602
  p_x_atp_rec.req_item_detail_flag(p_atp_index) := 2;   --BUG 4494602

  p_x_atp_rec.Inventory_Item_Id(p_atp_index)      :=
              p_line_rec.inventory_item_id(p_line_index);
  p_x_atp_rec.Source_Organization_Id(p_atp_index) :=
              p_line_rec.ship_from_org_id(p_line_index);
  p_x_atp_rec.Identifier(p_atp_index)             :=
              p_line_rec.line_id(p_line_index);
--  p_x_atp_rec.Order_Number(p_atp_index)           :=
--             p_header_rec.order_number(p_header_index);
  p_x_atp_rec.Calling_Module(p_atp_index)         := 660;
  p_x_atp_rec.Customer_Id(p_atp_index)            :=
              p_line_rec.sold_to_org_id(p_line_index);
  p_x_atp_rec.Customer_Site_Id(p_atp_index)       :=
              p_line_rec.ship_to_org_id(p_line_index);
  p_x_atp_rec.Destination_Time_Zone(p_atp_index)  :=
              p_line_rec.item_type_code(p_line_index); -- Destination_Time_Zone
  p_x_atp_rec.Quantity_Ordered(p_atp_index)       :=
              p_line_rec.ordered_quantity(p_line_index);
  p_x_atp_rec.Quantity_UOM(p_atp_index)           :=
              p_line_rec.order_quantity_uom(p_line_index);

  if p_header_rec.order_date_type_code(p_header_index) = 'ARRIVAL' then
    p_x_atp_rec.Requested_Arrival_Date(p_atp_index) :=
                nvl(p_line_rec.schedule_arrival_date(p_line_index),p_line_rec.request_date(p_line_index));
    if p_line_rec.ship_model_complete_flag(p_line_index) = 'Y' then
       p_x_atp_rec.Arrival_Set_Name(p_atp_index) :=
           p_line_rec.top_model_line_id(p_line_index);
    end if;
  else
    p_x_atp_rec.Requested_Ship_Date(p_atp_index) :=
                nvl(p_line_rec.schedule_ship_date(p_line_index),p_line_rec.request_date(p_line_index));
    if p_line_rec.ship_model_complete_flag(p_line_index) = 'Y' then
       p_x_atp_rec.Ship_Set_Name(p_atp_index) :=
           p_line_rec.top_model_line_id(p_line_index);
    end if;
  end if;

  p_x_atp_rec.Latest_Acceptable_Date(p_atp_index) := p_line_rec.latest_acceptable_date(p_line_index);
  p_x_atp_rec.Atp_Lead_Time(p_atp_index) := 0;         -- ATP_Lead_Time;
  p_x_atp_rec.Ship_Method(p_atp_index) :=    p_line_rec.shipping_method_code(p_line_index);
  p_x_atp_rec.Demand_Class(p_atp_index) :=  p_line_rec.demand_class_code(p_line_index);
  p_x_atp_rec.Action(p_atp_index) := 110;       -- Action (OESCH_ACT_SCHEDULE)
  p_x_atp_rec.Insert_Flag(p_atp_index) := G_INSERT_FLAG;    -- Insert_Flag
  p_x_atp_rec.oe_flag(p_atp_index) :='N';


  IF p_line_rec.ato_line_id(p_line_index) IS NOT NULL  AND
     p_line_rec.ato_line_id(p_line_index) <> p_line_rec.line_id(p_line_index)
  THEN

     p_x_atp_rec.atp_lead_time(p_atp_index) :=
              Get_Lead_Time(
                 p_ato_index         => p_curr_ato_index,
                 p_line_rec          => p_line_rec
               );
  END IF;

  IF p_line_rec.top_model_line_id(p_line_index) IS NOT NULL THEN

     p_x_atp_rec.Included_item_flag(p_atp_index)  := 1;
     p_x_atp_rec.top_model_line_id(p_atp_index)   :=
                p_line_rec.top_model_line_id(p_line_index);
     p_x_atp_rec.ato_model_line_id(p_atp_index)   :=
                p_line_rec.ato_line_id(p_line_index);
     p_x_atp_rec.parent_line_id(p_atp_index)      :=
                p_line_rec.link_to_line_id(p_line_index);
     p_x_atp_rec.validation_org(p_atp_index)      :=
     OE_BULK_ORDER_PVT.G_ITEM_ORG;
     p_x_atp_rec.component_code(p_atp_index)      :=
                p_line_rec.component_code(p_line_index);
     p_x_atp_rec.component_sequence_id(p_atp_index) :=
                p_line_rec.component_sequence_id(p_line_index);
     p_x_atp_rec.line_number(p_atp_index) :=
                p_line_rec.line_number(p_line_index)||'.'||
                p_line_rec.shipment_number(p_line_index)||'.'||
                p_line_rec.option_number(p_line_index)||'.'||
                p_line_rec.component_number(p_line_index);

  END IF;
   IF l_debug_level > 0 THEN
     oe_debug_pub.add('Exiting OE_BULK_SCHEDULE_UTIL.Add_MRP_Rec');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNEXP ERROR , ADD_MRP_REC' ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , ADD_MRP_REC' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Add_MRP_Rec'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Add_MRP_Rec;


PROCEDURE Load_MRP_Request
(p_line_rec                 IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
,p_header_rec               IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
,p_x_atp_rec                IN OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ
,p_x_atp_line_map_rec       IN OUT NOCOPY OE_WSH_BULK_GRP.T_NUM
)
IS
  I                         NUMBER := 1;
  J                         NUMBER := 1;
  K                         NUMBER := 1;
  l_line_count              NUMBER;
  l_header_count            NUMBER;
  l_ii_index                NUMBER;
  l_ii_last_index           NUMBER;
  l_curr_ato_index          NUMBER; --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  l_return_status          VARCHAR2(10);
  l_result                 BOOLEAN;
BEGIN
   IF l_debug_level > 0 THEN
    oe_debug_pub.add('Entering OE_BULK_SCHEDULE_UTIL.Load_MRP_Request');
 END IF;

 -- p_x_atp_line_map_rec stores the mapping of index positions
 -- of order line in the MRP rec.
 -- For e.g. p_x_atp_line_map_rec(2) = 5 indicates that
 -- order line at index position 5 in p_line_rec is stored
 -- at index position 2 in p_x_atp_rec

 p_x_atp_line_map_rec.DELETE;
--commented out for bug3675870
/* Extend_MRP_Rec(p_count => OE_BULK_ORDER_PVT.G_SCH_COUNT
               ,p_x_atp_rec => p_x_atp_rec
               );*/

       --for bug 3675870
	MSC_SATP_FUNC.Extend_Atp(p_atp_tab=>p_x_atp_rec,
                                 x_return_status => l_return_status,
				 p_index => OE_BULK_ORDER_PVT.G_SCH_COUNT);
     if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        oe_debug_pub.add('Error while extending ATP record');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     end if ;
 p_x_atp_line_map_rec.extend(OE_BULK_ORDER_PVT.G_SCH_COUNT);

 IF nvl(FND_PROFILE.VALUE('MRP_ATP_CALC_SD'),'N') = 'Y' THEN
    G_INSERT_FLAG := 1;
 ELSE
    G_INSERT_FLAG := 0;
 END IF;

 l_line_count := p_line_rec.line_id.count;
 l_header_count := p_line_rec.header_id.count;

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'LINE COUNT :'||L_LINE_COUNT ) ;
 END IF;
 <<START_OF_LOOP>>
 WHILE I <= l_line_count
       AND p_line_rec.item_type_code(I) <> 'INCLUDED'
 LOOP

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'I :'||I ) ;
       oe_debug_pub.add(  'J :'||J ) ;
   END IF;

   -- Line is NOT eligible for scheduling
   IF p_line_rec.schedule_status_code(I) IS NULL THEN
      I := I+1;
      GOTO START_OF_LOOP;
   END IF;

   -- Find index position of this line's header in p_header_rec
   /* No longer needed as the header_index is populated on p_line_rec
   WHILE K <= l_header_count LOOP
     IF p_header_rec.header_id(K) = p_line_rec.header_id(I) THEN
       EXIT;
     END IF;
     K := K+1;
   END LOOP;
 */
  k := p_line_rec.header_index(I);

-- Add check here for HOLDS if the profile option schedule lines on hold is
   -- False.

   IF OE_BULK_ORDER_PVT.G_SCHEDULE_LINE_ON_HOLD = 'N' AND
      p_line_rec.item_type_code(I) <> 'STANDARD'
   THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'Calling check for holds :'||J ) ;
   END IF;
       l_result := OE_Bulk_Holds_PVT.Check_For_Holds(
          p_header_id => p_line_rec.header_id(I),
          p_line_id => p_line_rec.line_id(I),
          p_line_index => I,
          p_header_index => K,
          p_top_model_line_index => p_line_rec.top_model_line_index(I),
          p_ship_model_complete_flag => p_line_rec.ship_model_complete_flag(I),
          p_ato_line_index => p_line_rec.ato_line_index(I),
          p_ii_parent_line_index => NULL
          );
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add('After Calling check for holds ');
   END IF;

 -- If found on hold then do not schedule the line.
       IF l_result THEN

           -- Check if the current line has included items and mark them to be
           -- not scheduled.

           IF p_line_rec.item_type_code(I) In ('MODEL', 'CLASS') AND
              p_line_rec.ii_start_index(I) IS NOT NULL   THEN

               l_ii_last_index := p_line_rec.ii_start_index(I)
                              + p_line_rec.ii_count(I) - 1;
               l_ii_index := p_line_rec.ii_start_index(I);

               -- loop over included items for this line
               WHILE l_ii_index <= l_ii_last_index LOOP

                   IF p_line_rec.schedule_status_code(l_ii_index) IS NOT NULL
                   THEN
                       p_line_rec.schedule_status_code(l_ii_index) := NULL;
                   END IF;
                   l_ii_index := l_ii_index + 1;
               END LOOP;
           END IF;
           p_line_rec.schedule_status_code(I) := NULL;
           I := I+1;
           GOTO START_OF_LOOP;
       END IF;

   END IF;

   l_curr_ato_index := p_line_rec.ato_line_index(I);

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'The current ATO index is:'||l_curr_ato_index ) ;
 END IF;

-- line should not be scheduled if
   -- any included item is on hold
   IF p_line_rec.item_type_code(I) IN ( 'KIT', 'CLASS', 'MODEL')
      AND p_line_rec.schedule_status_code(I) = 'II_ON_HOLD'
   THEN
      -- Clear out the schedule status on kit line but
      -- go on to add mrp records for included items that
      -- are not on hold in this kit
      p_line_rec.schedule_status_code(I) := NULL;
   ELSE
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Calling add_mrp_rec ') ;
 END IF;
      Add_MRP_Rec(p_line_index => I
               ,p_curr_ato_index => l_curr_ato_index
               ,p_header_index => K
               ,p_atp_index  => J
               ,p_line_rec   => p_line_rec
               ,p_header_rec => p_header_rec
               ,p_x_atp_Rec  => p_x_atp_rec
               );
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add('After add_mrp_rec ') ;
 END IF;
      p_x_atp_line_map_rec(J) := I;
      J := J+1;
   END IF;

   IF p_line_rec.item_type_code(I) In ('KIT', 'MODEL', 'CLASS') AND
      p_line_rec.ii_start_index(I) IS NOT NULL   THEN

      l_ii_last_index := p_line_rec.ii_start_index(I)
                              + p_line_rec.ii_count(I) - 1;
      l_ii_index := p_line_rec.ii_start_index(I);
  -- loop over included items for this kit
      WHILE l_ii_index <= l_ii_last_index LOOP
        -- only add included items that need to be scheduled.
        -- For non-SMCs, schedule status for iis on hold will be null
        -- , all other lines should be scheduled

        IF p_line_rec.schedule_status_code(l_ii_index) IS NOT NULL THEN

           l_result := FALSE;

           -- If Schedule Lines on holds is False then
           IF OE_BULK_ORDER_PVT.G_SCHEDULE_LINE_ON_HOLD = 'N' THEN

            -- Call check for holds
              l_result := OE_Bulk_Holds_PVT.Check_For_Holds(
              p_header_id => p_line_rec.header_id(l_ii_index),
              p_line_id => p_line_rec.line_id(l_ii_index),
              p_line_index => l_ii_index,
              p_header_index => K,
              p_top_model_line_index =>
                              p_line_rec.top_model_line_index(l_ii_index),
              p_ship_model_complete_flag =>
                              p_line_rec.ship_model_complete_flag(l_ii_index),
              p_ato_line_index => NULL,
              p_ii_parent_line_index => I
              );
           END IF;

           -- If found on hold then do not schedule the line.
           IF l_result THEN
               p_line_rec.schedule_status_code(I) := NULL;
           ELSE
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add('calling add_mrp_rec for II ') ;
 END IF;

 Add_MRP_Rec(
                p_line_index => l_ii_index
               ,p_curr_ato_index => l_curr_ato_index
               ,p_header_index => K
               ,p_atp_index  => J
               ,p_line_rec   => p_line_rec
               ,p_header_rec => p_header_rec
               ,p_x_atp_Rec  => p_x_atp_rec
               );
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add('After calling add_mrp_rec for II ') ;
 END IF;
               p_x_atp_line_map_rec(J) := l_ii_index;
               J := J+1;
            END IF;
        END IF; -- IF p_line_rec.schedule_status_code(
        l_ii_index := l_ii_index + 1;
      END LOOP;

   END IF; -- End IF for KITS

   I := I+1;

 END LOOP; -- End of loop over line record

 If l_debug_level > 0 THEN
   oe_debug_pub.add('Exiting OE_BULK_SCHEDULE_UTIL.Load_MRP_Request');
 END IF;


EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    oe_debug_pub.add('Unexp Error, Load_MRP_Request');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    oe_debug_pub.add('Others Error, Load_MRP_Request');
    oe_debug_pub.add(substr(sqlerrm,1,240));
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Load_MRP_Request'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Load_MRP_Request;

PROCEDURE Update_Line_Rec
(p_line_index               IN NUMBER
,p_atp_index                IN NUMBER
,p_line_rec                 IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
,p_x_atp_rec                IN OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ
)
IS
l_time_to_ship NUMBER;
l_c_index                NUMBER;
l_on_generic_hold        BOOLEAN := FALSE;
l_on_booking_hold        BOOLEAN := FALSE;
l_on_scheduling_hold     BOOLEAN := FALSE;
l_error_index            NUMBER;
l_promise_date_flag      VARCHAR2(2);
l_order_date_type_code   VARCHAR2(30);
l_hold_ii_flag           VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_line_rec_for_hold	  OE_Order_PUB.Line_Rec_Type;  --ER#7479609
l_header_rec_for_hold     OE_Order_PUB.Header_Rec_Type;  --ER#7479609
BEGIN

  if l_debug_level > 0 then

  oe_debug_pub.add('Line Index :'||p_line_index);
  oe_debug_pub.add('ATP Index :'||p_atp_index);
  oe_debug_pub.add('Ship Set :'||p_x_atp_rec.ship_set_name(p_atp_index));
  oe_debug_pub.add('Error Code :'||p_x_atp_rec.error_code(p_atp_index));

  end if;

  --bug5880565
 oe_bulk_msg_pub.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => p_line_rec.line_id(p_line_index)
         ,p_header_id                   => p_line_rec.header_id(p_line_index)
         ,p_line_id                     => p_line_rec.line_id(p_line_index)
         ,p_orig_sys_document_ref       => p_line_rec.orig_sys_document_ref(p_line_index)
         ,p_orig_sys_document_line_ref  => p_line_rec.orig_sys_line_ref(p_line_index)
         ,p_source_document_id          => NULL
         ,p_source_document_line_id     => NULL
         ,p_order_source_id             => p_line_rec.order_source_id(p_line_index)
         ,p_source_document_type_id     => NULL );



  -- NOTE: Changes to OPM fields due to Ship From update
  -- or Changes to Tax Date due to Schedule Ship Date update
  -- are not done here as BULK does not support OPM or Tax Calculation

  IF p_x_atp_rec.error_code(p_atp_index) IN (0,-99,150) THEN

     -- Update warehouse if ATP check returns a different warehouse
     IF nvl(p_line_rec.ship_from_org_id(p_line_index),-1)
       <> nvl(p_x_atp_rec.source_organization_id(p_atp_index),-1)
     THEN
        p_line_rec.ship_from_org_id(p_line_index)      := p_x_atp_rec.source_organization_id(p_atp_index);
        /*ER#7479609 start
        OE_Bulk_Holds_PVT.Evaluate_Holds(
           p_header_id          => p_line_rec.header_id(p_line_index),
           p_line_id            => p_line_rec.line_id(p_line_index),
           p_line_number        => p_line_rec.line_number(p_line_index),
           p_sold_to_org_id     => p_line_rec.sold_to_org_id(p_line_index),
           p_inventory_item_id  => p_line_rec.inventory_item_id(p_line_index),
           p_ship_from_org_id   => p_line_rec.ship_from_org_id(p_line_index),
           p_invoice_to_org_id  => p_line_rec.invoice_to_org_id(p_line_index),
           p_ship_to_org_id     => p_line_rec.ship_to_org_id(p_line_index),
           p_top_model_line_id  => p_line_rec.top_model_line_id(p_line_index),
           p_ship_set_name      => NULL,
           p_arrival_set_name   => NULL,
           p_check_only_warehouse_holds => TRUE,
           p_on_generic_hold    => l_on_generic_hold,
           p_on_booking_hold    => l_on_booking_hold,
           p_on_scheduling_hold => l_on_scheduling_hold
           );
         ER#7479609 end*/

            --ER#7479609 start
            BEGIN
            SELECT order_type_id
            INTO l_header_rec_for_hold.order_type_id
            FROM OE_ORDER_HEADERS_ALL
            WHERE header_id=p_line_rec.header_id(p_line_index);
            EXCEPTION
            WHEN OTHERS THEN
              l_header_rec_for_hold.order_type_id := NULL;
            END;

            l_line_rec_for_hold.header_id := p_line_rec.header_id(p_line_index);
            l_line_rec_for_hold.line_id := p_line_rec.line_id(p_line_index);
            l_line_rec_for_hold.line_number := p_line_rec.line_number(p_line_index);
            l_line_rec_for_hold.sold_to_org_id := p_line_rec.sold_to_org_id(p_line_index);
            l_line_rec_for_hold.inventory_item_id := p_line_rec.inventory_item_id(p_line_index);
            l_line_rec_for_hold.ship_from_org_id := p_line_rec.ship_from_org_id(p_line_index);
            l_line_rec_for_hold.invoice_to_org_id := p_line_rec.invoice_to_org_id(p_line_index);
            l_line_rec_for_hold.ship_to_org_id := p_line_rec.ship_to_org_id(p_line_index);
            l_line_rec_for_hold.top_model_line_id := p_line_rec.top_model_line_id(p_line_index);
            l_line_rec_for_hold.price_list_id := p_line_rec.price_list_id(p_line_index);
            l_line_rec_for_hold.creation_date := to_char(sysdate,'DD-MON-RRRR');
            l_line_rec_for_hold.shipping_method_code := p_line_rec.shipping_method_code(p_line_index);
            l_line_rec_for_hold.deliver_to_org_id := p_line_rec.deliver_to_org_id(p_line_index);
            l_line_rec_for_hold.source_type_code := p_line_rec.source_type_code(p_line_index);
            l_line_rec_for_hold.line_type_id := p_line_rec.line_type_id(p_line_index);
            l_line_rec_for_hold.payment_term_id := p_line_rec.payment_term_id(p_line_index);
            l_line_rec_for_hold.created_by := NVL(FND_GLOBAL.USER_ID, -1);


             OE_Bulk_Holds_PVT.Evaluate_Holds(
		p_header_rec  => l_header_rec_for_hold,
		p_line_rec    => l_line_rec_for_hold,
		p_on_generic_hold  => l_on_generic_hold,
		p_on_booking_hold  => l_on_booking_hold,
		p_on_scheduling_hold => l_on_scheduling_hold
		);
            --ER#7479609 end
        -- Also cache EDI attributes for the new ship from
        l_c_index := OE_Bulk_Cache.Load_Ship_From
                        (p_key => p_line_rec.ship_from_org_id(p_line_index)
                        );
     END IF;

    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
             IF p_x_atp_rec.group_ship_date(p_atp_index) IS NOT NULL
             THEN
                p_line_rec.schedule_ship_date(p_line_index) := p_x_atp_rec.group_ship_date(p_atp_index);
             ELSE
                p_line_rec.schedule_ship_date(p_line_index)  := p_x_atp_rec.ship_date(p_atp_index);
             END IF;

             IF p_x_atp_rec.group_arrival_date(p_atp_index) IS NOT NULL THEN
                p_line_rec.schedule_arrival_date(p_line_index) := p_x_atp_rec.group_arrival_date(p_atp_index);
             ELSE
                p_line_rec.schedule_arrival_date(p_line_index) := p_x_atp_rec.arrival_date(p_atp_index);
             END IF;
    ELSE
     -- Group_ship_date/group_arrival_date - use these also!
     if p_x_atp_rec.ship_set_name(p_atp_index) is not null then
       p_line_rec.schedule_ship_date(p_line_index) := p_x_atp_rec.group_ship_date(p_atp_index);
       p_line_rec.schedule_arrival_date(p_line_index) := p_x_atp_rec.group_ship_date(p_atp_index)
                                   + nvl(p_x_atp_rec.delivery_lead_time(p_atp_index),0);
     elsif p_x_atp_rec.arrival_set_name(p_atp_index) is not null then
       p_line_rec.schedule_ship_date(p_line_index) := p_x_atp_rec.group_arrival_date(p_atp_index)
                                   - nvl(p_x_atp_rec.delivery_lead_time(p_atp_index),0);
       p_line_rec.schedule_arrival_date(p_line_index) := p_x_atp_rec.group_arrival_date(p_atp_index);
     else
       p_line_rec.schedule_ship_date(p_line_index) := p_x_atp_rec.ship_date(p_atp_index);
       p_line_rec.schedule_arrival_date(p_line_index) := p_x_atp_rec.ship_date(p_atp_index)
                                   + nvl(p_x_atp_rec.delivery_lead_time(p_atp_index),0);
     end if;
    END IF;
    -- Pack J
    -- Latest Acceptable date violation check (Set to Ignore)
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
      IF OE_SYS_PARAMETERS.value('LATEST_ACCEPTABLE_DATE_FLAG')='I' THEN
         l_order_date_type_code := NVL(Get_Date_Type(p_line_rec.header_id(p_line_index)),'SHIP');
         IF ((l_order_date_type_code = 'SHIP'
           AND p_line_rec.schedule_ship_date(p_line_index)
                            > p_line_rec.latest_acceptable_date(p_line_index))
           OR (l_order_date_type_code = 'ARRIVAL'
           AND p_line_rec.schedule_arrival_date(p_line_index)
                            > p_line_rec.latest_acceptable_date(p_line_index))) THEN
            FND_MESSAGE.SET_NAME('ONT','ONT_SCH_LAD_VIOLATE');
            OE_BULK_MSG_PUB.Add;
         END IF;
      END IF;

       -- Get the Promise date flag
       l_promise_date_flag := Oe_sys_Parameters.Value('PROMISE_DATE_FLAG');
       -- Set the Promise date with schedule ship date
       IF l_promise_date_flag IN('FS','S') THEN
          IF l_order_date_type_code = 'SHIP'
            AND p_line_rec.schedule_ship_date(p_line_index) IS NOT NULL THEN
             p_line_rec.promise_date(p_line_index) := p_line_rec.schedule_ship_date(p_line_index);
          ELSIF l_order_date_type_code = 'ARRIVAL'
            AND p_line_rec.schedule_arrival_date(p_line_index) IS NOT NULL THEN
             p_line_rec.promise_date(p_line_index) := p_line_rec.schedule_arrival_date(p_line_index);
          END IF;
       ELSIF l_promise_date_flag IN('FR','R') THEN -- Set the Promise date with Request Date
          p_line_rec.promise_date(p_line_index) := p_line_rec.request_date(p_line_index);
       END IF;
    END IF;

     p_line_rec.delivery_lead_time(p_line_index)     := p_x_atp_rec.delivery_lead_time(p_atp_index);
     p_line_rec.mfg_lead_time(p_line_index)          := p_x_atp_rec.atp_lead_time(p_atp_index);
     p_line_rec.shipping_method_code(p_line_index)   := nvl(p_x_atp_rec.ship_method(p_atp_index),
                                                            p_line_rec.shipping_method_code(p_line_index));
     p_line_rec.schedule_status_code(p_line_index)   := 'SCHEDULED';

     IF Oe_Sys_Parameters.Value('FIRM_DEMAND_EVENTS') = 'SCHEDULE'
     AND OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
         p_line_rec.firm_demand_flag(p_line_index)   := 'Y';
     END IF;

     -- Bug 2737274
     -- Check if attribute_05 exists as the attribute may not be available
     -- on out ATP rec from the MRP call.
     -- Without the exists check, error 'subscript beyond count' can result
     IF p_x_atp_rec.attribute_05.EXISTS(p_atp_index) THEN
       p_line_rec.visible_demand_flag(p_line_index)    := nvl(p_x_atp_rec.attribute_05(p_atp_index),'Y');
     ELSE
       p_line_rec.visible_demand_flag(p_line_index)    := 'Y';
     END IF;

     --p_line_rec.last_update_date(p_line_index)      := sysdate;
     --p_line_rec.last_updated_by(p_line_index)       := FND_GLOBAL.USER_ID;
     --p_line_rec.last_update_login(p_line_index)     := FND_GLOBAL.LOGIN_ID;
     p_line_rec.lock_control(p_line_index)          := (p_line_rec.lock_control(p_line_index) + 1);

    IF OE_BULK_ORDER_PVT.G_RESERVATION_TIME_FENCE IS NOT NULL THEN
      -- If ship date is within reservation time fence, populate a message
      l_time_to_ship := to_number(trunc(p_line_rec.schedule_ship_date(p_line_index)) - trunc(SYSDATE));

      BEGIN
       IF l_time_to_ship < 0 THEN
          NULL;
       ELSIF l_time_to_ship <= to_number(OE_BULK_ORDER_PVT.G_RESERVATION_TIME_FENCE) THEN
          FND_MESSAGE.SET_NAME('ONT','OE_BULK_NOT_SUPP_RSV');
          OE_BULK_MSG_PUB.Add;
       END IF;
      EXCEPTION
       WHEN OTHERS THEN
          NULL;
      END;
    END IF; --reservation time fence
  ELSE

     -- Extend_Sch_Error_Rec
     l_error_index := G_SCH_ERROR_TBL.COUNT + 1;
     G_SCH_ERROR_TBL(l_error_index).line_index := p_line_index;
     G_SCH_ERROR_TBL(l_error_index).error_code
              := p_x_atp_rec.error_code(p_atp_index);
     p_line_rec.schedule_status_code(p_line_index) := null;
     p_line_rec.schedule_arrival_date(p_line_index) := null;
     p_line_rec.schedule_ship_date(p_line_index) := null;

     IF p_line_rec.item_type_code(p_line_index) = 'INCLUDED' THEN
        p_line_rec.schedule_status_code
             (p_line_rec.parent_line_index(p_line_index)) := null;
        p_line_rec.schedule_arrival_date
             (p_line_rec.parent_line_index(p_line_index)) := null;
        p_line_rec.schedule_ship_date
             (p_line_rec.parent_line_index(p_line_index)) := null;
     END IF;

  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNEXP ERROR , Update_Line_Rec' ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , Update_Line_Rec' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Update_Line_Rec'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Update_Line_Rec;

PROCEDURE Update_MRP_Results
(p_x_atp_rec                IN OUT NOCOPY MRP_ATP_PUB.ATP_Rec_Typ
,p_line_rec                 IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
,p_x_atp_line_map_rec       IN OUT NOCOPY OE_WSH_BULK_GRP.T_NUM
)
IS
  J                           NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

 G_SCH_ERROR_TBL.DELETE;

 --------------------------------------------------------------
 -- UPDATE lines global for successfully scheduled lines
 --------------------------------------------------------------
 FOR J IN p_x_atp_rec.Identifier.FIRST..p_x_atp_rec.Identifier.LAST
 LOOP

    Update_Line_Rec(p_line_index => p_x_atp_line_map_rec(J)
                        ,p_atp_index  => J
                        ,p_line_rec   => p_line_rec
                        ,p_x_atp_Rec  => p_x_atp_rec
                        );

 END LOOP;

 -- Return if all lines were successfully scheduled

 IF (G_SCH_ERROR_TBL.COUNT = 0) THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURNING AS ALL LINES WERE SUCCESSFUL' ) ;
     END IF;
     RETURN;
 END IF;


 ---------------------------------------------------------------------
 -- For order lines that failed scheduling:
 -- Insert Error Messages
 ---------------------------------------------------------------------
 Insert_Error_Messages(p_line_rec);

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNEXP ERROR , UPDATE_MRP_RESULTS' ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , UPDATE_MRP_RESULTS' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Update_MRP_Results'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Update_MRP_Results;


---------------------------------------------------------------------
-- PROCEDURE Schedule_Orders
--
-- This procedure schedules all lines eligible for auto-scheduling
-- in this order import batch.
-- Scheduling updates are done directly on the line record.
---------------------------------------------------------------------

PROCEDURE Schedule_Orders
        (p_line_rec            IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
        ,p_header_rec          IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
        ,x_return_status       OUT NOCOPY VARCHAR2)
IS
l_msg_text                VARCHAR2(2000);
l_msg_count               NUMBER;
l_session_id              NUMBER := 0;
l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
l_x_mrp_atp_rec           MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
l_mrp_msg_data            VARCHAR2(200);
l_start_time              NUMBER;
l_end_time                NUMBER;
l_atp_line_map_rec        OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM();
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  ------------------------------------------------------------------
  -- Before calling this procedure, it is assumed that all the lines
  -- in the batch went through entity validation. During entity
  -- validation, lines that were eligible for scheduling AND passed
  -- scheduling validations would have been marked with
  -- schedule_status_code of 'TO_BE_SCHEDULED'.
  -- Even holds evaluation is done at the time of entity validation
  -- (OEBLLINB.pls) and if line is eligible for a generic hold and
  -- profile OM:Schedule Lines on Hold is set to 'No', then the
  -- above schedule status would not be set.
  -------------------------------------------------------------------
  --- BYPASS ATP call
  IF NVL(fnd_profile.value('ONT_BYPASS_ATP'),'N') = 'Y' THEN
     -- this is an inactive demand line.

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'THIS IS INACTIVE DEMAND LINE' , 1 ) ;
     END IF;
     Inactive_Demand_Scheduling(
               p_line_rec     => p_line_rec
              ,x_return_status  => x_return_status);

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF  x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

  ELSE -- Existing code
     -------------------------------------------------------------------
     -- (1) Load Request Rec to call the MRP API
     -------------------------------------------------------------------
     Load_MRP_Request(p_line_rec
                     ,p_header_rec
                     ,l_mrp_atp_rec
                     ,l_atp_line_map_rec
                     );

IF l_mrp_atp_rec.identifier.count = 0
  OR l_mrp_atp_rec.inventory_item_id(1) IS NULL THEN
      IF l_debug_level > 0 THEN
          oe_debug_pub.add('No lines to schedule');
      END IF;
     RETURN;
  END IF;


     -------------------------------------------------------------------
     -- (2) Call the MRP API
     -------------------------------------------------------------------

     SELECT mrp_atp_schedule_temp_s.nextval
     INTO   l_session_id
     FROM dual;

     -- Bug 2721165 =>
     -- x_atp_rec in call_atp spec was changed to an out nocopy parameter
     -- hence same local variable cannot be assigned to both p_atp_rec
     -- and x_atp_rec. Created new variable l_x_mrp_atp_rec to be used
     -- for x_atp_rec.

     -- Bug 5640601 =>
     -- Selecting hsecs from v$times is changed to execute only when debug
     -- is enabled, as hsec is used for logging only when debug is enabled.
     IF l_debug_level > 0 THEN
        SELECT hsecs INTO l_start_time from v$timer;
     END IF;
     MRP_ATP_PUB.Call_ATP
              (  p_session_id             =>  l_session_id
               , p_atp_rec                =>  l_mrp_atp_rec
               , x_atp_rec                =>  l_x_mrp_atp_rec
               , x_atp_supply_demand      =>  l_atp_supply_demand
               , x_atp_period             =>  l_atp_period
               , x_atp_details            =>  l_atp_details
               , x_return_status          =>  x_return_status
               , x_msg_data               =>  l_mrp_msg_data
               , x_msg_count              =>  l_msg_count);

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '3. AFTER CALL_ATP , STATUS:' ||X_RETURN_STATUS , 1 ) ;
     -- Bug 5640601 =>
     -- Selecting hsecs from v$times is changed to execute only when debug
     -- is enabled, as hsec is used for logging only when debug is enabled.
        SELECT hsecs INTO l_end_time from v$timer;
     END IF;

     FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in MRP Call is (sec) '||((l_end_time-l_start_time)/100));

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


     -------------------------------------------------------------------
     -- (3) Update Order Lines with Results from the MRP call
     -------------------------------------------------------------------
     Update_MRP_Results(l_x_mrp_atp_rec
                    ,p_line_rec
                    ,l_atp_line_map_rec
                    );

   END IF;
   IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'Exiting SCHEDULE_ORDERS' ) ;
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNEXP ERROR , SCHEDULE_ORDERS' ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , SCHEDULE_ORDERS' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Schedule_Orders'
       );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Schedule_Orders;
-- Pack J
/*-----------------------------------------------------------------------------
Function Name : Get_Date_Type
Description    : This function returns the date type of the order.
                 The date type could be SHIP or ARRIVAl or null. Null
                 value will be treated as SHIP in the scheduling code.
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


END OE_BULK_SCHEDULE_UTIL;

/
