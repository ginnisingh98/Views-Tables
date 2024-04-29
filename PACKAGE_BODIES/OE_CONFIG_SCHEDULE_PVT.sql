--------------------------------------------------------
--  DDL for Package Body OE_CONFIG_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CONFIG_SCHEDULE_PVT" AS
/* $Header: OEXVCSCB.pls 120.12.12010000.7 2009/09/02 09:30:55 rmoharan ship $ */

--  Global constant holding the package name
G_PKG_NAME      CONSTANT    VARCHAR2(30):='Oe_Config_Schedule_Pvt';
G_BINARY_LIMIT  CONSTANT    NUMBER := OE_GLOBALS.G_BINARY_LIMIT;  --7827737;

/*--------------------------------------------------------------
Forward Declarations
---------------------------------------------------------------*/
PROCEDURE Print_Time(p_msg   IN  VARCHAR2);

PROCEDURE Call_Mrp
( p_x_line_tbl        IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_old_line_tbl      IN  OE_Order_Pub.Line_Tbl_Type
 ,p_sch_action        IN  VARCHAR2
 ,p_partial           IN  BOOLEAN := FALSE
 ,p_partial_set       IN  BOOLEAN := FALSE
 ,p_part_of_set       IN  VARCHAR2 DEFAULT 'N' -- 4405004
 ,x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Handle_Unreserve
( p_x_line_tbl       IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_old_line_tbl     IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_post_process     IN  VARCHAR2 DEFAULT FND_API.G_FALSE
 ,x_return_status    OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Reserve_Group
( p_x_line_tbl       IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_sch_action       IN VARCHAR2);

PROCEDURE Unreserve_group
( p_line_tbl    IN OE_Order_Pub.Line_Tbl_Type
 ,p_sch_action  IN VARCHAR2 := 'X');

Procedure Validate_Group_Request
( p_line_rec      IN  OE_Order_PUB.Line_Rec_Type
 ,p_request_type  IN  VARCHAR2
 ,p_sch_action    IN  VARCHAR2
 ,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Is_Group_Scheduled
( p_line_tbl     IN  OE_Order_Pub.Line_Tbl_Type
 ,p_caller       IN  VARCHAR2 := 'X'
 ,x_result       OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE Get_Reservations
( p_line_rec          IN  OE_Order_Pub.Line_Rec_Type
 ,x_reservation_qty  OUT NOCOPY /* file.sql.39 change */ NUMBER
 ,x_reservation_qty2  OUT NOCOPY /* file.sql.39 change */ NUMBER -- INCONV
 );

PROCEDURE Log_Attribute_Changes
(p_line_rec           IN  OE_Order_PUB.Line_Rec_Type
,p_old_line_rec       IN  OE_Order_PUB.Line_Rec_Type
,x_unreserve_flag     OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

--temp, just for testing
PROCEDURE Call_ATP
( p_atp_rec    IN  MRP_ATP_PUB.ATP_Rec_Typ
 ,x_atp_rec    OUT NOCOPY /* file.sql.39 change */ MRP_ATP_PUB.ATP_Rec_Typ);


PROCEDURE Validate_And_Assign_Sch_Params
( p_request_rec      IN OE_Order_Pub.Request_Rec_Type
 ,p_x_line_rec       IN OUT NOCOPY OE_Order_Pub.Line_Rec_Type
 ,p_x_old_line_rec   IN OUT NOCOPY OE_Order_Pub.Line_Rec_Type);

PROCEDURE Get_Included_Items_To_Sch
( p_x_line_tbl      IN OUT NOCOPY OE_Order_PUB.line_tbl_type
 ,p_x_old_line_tbl  IN OUT NOCOPY OE_Order_PUB.line_tbl_type
 ,p_request_tbl     IN OUT NOCOPY OE_Order_PUB.request_tbl_type
 ,p_in_index        IN OUT NOCOPY /* file.sql.39 change */ NUMBER
 ,p_req_index       IN NUMBER);

-- this is temp, to be moved to oexuschb.pls
PROCEDURE Call_Security_And_Defaulting
( p_x_line_rec    IN  OUT NOCOPY OE_ORDER_PUB.line_rec_type
 ,p_old_line_rec  IN  OE_ORDER_PUB.line_rec_type
 ,x_direct_update OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Handle_Direct_Update
( p_x_line_rec    IN  OUT NOCOPY OE_ORDER_PUB.line_rec_type
 ,p_old_line_rec  IN  OE_ORDER_PUB.line_rec_type
 ,p_caller        IN  VARCHAR2);


FUNCTION  Check_for_Request( p_set_id IN  NUMBER,
                             p_ato_line_id IN NUMBER)
RETURN BOOLEAN
IS
 K       NUMBER;
BEGIN

   oe_debug_pub.add('Entering Procedure Check_for_Request in Package OE_Delayed_
Requests_Pvt');


   K         := OE_Delayed_Requests_PVT.G_Delayed_Requests.FIRST;

   WHILE K is not null
   LOOP

      IF (OE_Delayed_Requests_PVT.G_Delayed_Requests(K).request_type =
                     OE_GLOBALS.G_GROUP_SCHEDULE
      OR  (OE_Delayed_Requests_PVT.G_Delayed_Requests(K).request_type =
                     OE_GLOBALS.G_SCHEDULE_LINE
      AND OE_Delayed_Requests_PVT.G_Delayed_Requests(K).entity_id = p_ato_line_id))
      AND OE_Delayed_Requests_PVT.G_Delayed_Requests(K).param1 = p_set_id
      THEN
          RETURN TRUE;

       END IF;

       K :=  OE_Delayed_Requests_PVT.G_Delayed_Requests.NEXT(K);

   END LOOP;

   RETURN FALSE;
EXCEPTION
   WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
     OE_MSG_PUB.Add_Exc_Msg
       (G_PKG_NAME
        ,'CheckForRequest');
      END IF;
      RETURN FALSE;

End Check_For_Request;
/*---------------------------------------------------------
PROCEDURE Log_Config_Sch_Request

a) ATO model/options
SMC can have ATO    : in this case, the req will be for SMC
NONSMC can have ATO : in this case, the req will be for ATO
top level ATO       : in this case, the req will be for ATO

b) Scheduling parameters=>
1. request_date         : reschedule
2. schedule_ship_date   : reschedule
3. schedule_arrival_date: reschedule
4. ordered_quantity     : unreserve of decrease, reschedule
5. order_quantity_uom   : if std, unreserve, reschedule, reserve*
6. reserved_quantity    : unreserve, reserve
7. inventory_item_id    : unreserve, undemand, demand new, reserve*
8. ship_from_org_id     : unreserve, reschedule, reserve
9. ship_to_org_id       : reschedule
10. shipping_method_code: reschedule
11. demand_class_code   : reschedule
12. planning_priority   : reschedule*
13. delivery_lead_time  : reschedule*

* means can not be changed for a configuration,
not to worry for now.

so ordered_quantity, reserved_quantity and ship_from change
results in more than scheduling/rescheduling.

c) We do not expect any exception raised in this API,
only unexpected errors can come.

d) The p_sch_action is obtained from need_scheduling,
it can have,

  SCHEDULE
  UNSCHEDULE
  RESCHEDULE : any of the sch attibs changed. does not tell
               how many, which
  RESERVE    : only indicates that there is a change
               in reserved qty, does not tell increase
               or decrease.

 apart from the p_sch_action, we use the log_attrib_changes
 procedure to get any scheduling co action.

e) In case of SMCPTO models,
1) The p_sch_action of RESERVE on a pre scheduled line means
that none of the other sch attribs changed. If any of the
other attrib changes ex: ordered_quantity along with
reserved quantity, the p_sch_action will be RESCHEDULE.
Thus, on a pre scheduled line whe action RESERVE comes,
we just process the change and not log a request in
oe_schedule_util.process_request itself.
any other attrib change is sending all the lines to mrp.

2) unschedule, unreserve can not come at the same time
   of re/schedule. Only reschedule and schedule can come
   together, due to options window/configurator changes.

f)FOR ATO, since we are overwriting the requests:
Spoke with Navneet about Schedule and Reschedule
coming together in case of ATO. He suggest that
if a group is scheduled, always send RESCHEDULE,
even if the line is getting added is not yet
scheduled. **ato_line_id may not be correct on class lines.

old values needed for rescheduling:
  1.ship_from_org_id
  2.demand_class_code
  3.request_date,
  4.schedule_ship_date,
  5.schedule_arrival_date
  6.ato_delete_flag : in case of deletes of ato options.

g)
Make sure that for smc, the l_res_change_flag is not
overwritten by some other rescheduling change.

pto_ato_nonui can not get overwritten by a value other
that Y if once set to Y becasue all records will
satisfy the condition whcih sets it.

e) if the caller is EXTERNAL i.e wf, the action
   can be only SCHEDULE.

 Changes have been made to pass override flag to schedule_nonsmc and
 schedule_ato delayed request
----------------------------------------------------------*/

PROCEDURE Log_Config_Sch_Request
( p_line_rec       IN  OE_Order_PUB.Line_Rec_Type
 ,p_old_line_rec   IN  OE_Order_PUB.Line_Rec_Type
 ,p_sch_action     IN  VARCHAR2
 ,p_caller         IN  VARCHAR2 := OE_SCHEDULE_UTIL.SCH_INTERNAL
 ,x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_sch_action             VARCHAR2(30);
  l_unreserve_flag            VARCHAR2(1);
  l_pto_ato_nonui          VARCHAR2(1) := 'N';
  l_model_sch_status_code  VARCHAR2(30);
  l_model_ship_from        NUMBER;
  l_model_demand_class     VARCHAR2(30);
  l_model_ship_date        DATE;
  l_model_arrival_date     DATE;
  l_model_request_date     DATE;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING LOG_CONFIG_SCH_REQUEST' , 3 ) ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- the validate config flag is set to N in all 3 procedures
  -- 1. Cascade_Changes
  -- 2. Validate_Configuration
  -- 3. Modify_Included_Items.

  IF OE_Config_Pvt.OECFG_VALIDATE_CONFIG = 'N' AND
     OE_CONFIG_UTIL.G_CONFIG_UI_USED = 'N'
  THEN
    IF p_line_rec.item_type_code = 'INCLUDED' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INC ITEM: CASCADE/MODIFY_INC_ITEMS CALL ' , 3 ) ;
      END IF;
      RETURN;
    END IF;

    IF p_line_rec.ship_model_complete_flag = 'Y' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SMC VALIDATE CFG CHANGES' , 3 ) ;
      END IF;
      RETURN;
    END IF;

    IF p_line_rec.ato_line_id is not NULL AND
       p_line_rec.ato_line_id = p_line_rec.top_model_line_id THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PURE ATO VALIDATE CFG CHANGES' , 3 ) ;
      END IF;
      RETURN;
    END IF;
  END IF;


  l_sch_action := p_sch_action;

  IF p_sch_action = OE_Schedule_Util.OESCH_ACT_SCHEDULE AND
     (p_line_rec.ato_line_id is not null OR
      p_line_rec.ship_model_complete_flag = 'Y')
  THEN
    -- we do not want to query for nonsmc

    SELECT schedule_status_code, ship_from_org_id,
           demand_class_code, schedule_ship_date,
           schedule_arrival_date, request_date
    INTO   l_model_sch_status_code, l_model_ship_from,
           l_model_demand_class, l_model_ship_date,
           l_model_arrival_date, l_model_request_date
    FROM   oe_order_lines
    WHERE  line_id = p_line_rec.top_model_line_id;

    IF l_model_sch_status_code is NOT NULL THEN
      l_sch_action := OE_Schedule_Util.OESCH_ACT_RESCHEDULE;
    END IF;

  END IF;
  --------- done l_sch_action and return part -----------------


  -- log Reservation / ord qty changes
  IF  (p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE OR
       NOT OE_GLOBALS.EQUAL(p_line_rec.reserved_quantity,
                            p_old_line_rec.reserved_quantity)) AND
      p_line_rec.top_model_line_id <> nvl(p_line_rec.ato_line_id, -1)

  THEN
    Log_Attribute_Changes
    (p_line_rec           => p_line_rec
    ,p_old_line_rec       => p_old_line_rec
    ,x_unreserve_flag     => l_unreserve_flag);
  END IF;


  -- ato_line_id can be incorrect rarely

  IF OE_Config_Util.G_Config_UI_Used = 'N' AND
       p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
       p_line_rec.ship_model_complete_flag = 'N' AND
       p_line_rec.ato_line_id is not NULL
  THEN
    IF p_line_rec.item_type_code = 'CLASS' OR
       p_line_rec.top_model_line_id <> p_line_rec.ato_line_id THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SETTING PTO_ATO_NONUI TO Y' , 3 ) ;
      END IF;
      l_pto_ato_nonui := 'Y';
    END IF;
  END IF;


  -------------------- SMC PTO log req -----------------------

  IF p_line_rec.ship_model_complete_flag = 'Y' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LOGGING REQ TO SCHEDULE_SMC' , 3 ) ;
    END IF;

    -- 4052648 : Parameters p_param14 - 17 are added
    OE_Delayed_Requests_Pvt.Log_Request
    (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
     p_entity_id              => p_line_rec.top_model_line_id,
     p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
     p_requesting_entity_id   => p_line_rec.line_id,
     p_request_type           => OE_GLOBALS.G_SCHEDULE_SMC,
     p_param1                 => l_sch_action,
     p_param2                 => p_line_rec.top_model_line_id,
     p_param3                 => p_line_rec.ship_from_org_id,
     p_param4                 => p_line_rec.ship_to_org_id,
     p_param5                 => p_line_rec.shipping_method_code,
     p_param6                 => p_line_rec.demand_class_code,
     p_param7                 => nvl(p_old_line_rec.ship_from_org_id,
                                     l_model_ship_from),
     p_param8                 => nvl(p_old_line_rec.demand_class_code,
                                     l_model_demand_class),
     p_param14                => p_old_line_rec.ship_to_org_id,
     p_param15                => p_old_line_rec.shipping_method_code,
     p_param16                => p_old_line_rec.planning_priority,
     p_param17                => p_old_line_rec.delivery_lead_time,
     p_param24                => l_unreserve_flag, -- res changes**
     p_param25                => p_line_rec.header_id,
     p_date_param1            => p_line_rec.request_date,
     p_date_param2            => p_line_rec.schedule_ship_date,
     p_date_param3            => p_line_rec.schedule_arrival_date,
     p_date_param4            => nvl(p_old_line_rec.request_date,
                                     l_model_request_date),
     p_date_param5            => nvl(p_old_line_rec.schedule_ship_date,
                                     l_model_ship_date),
     p_date_param6            => nvl(p_old_line_rec.schedule_arrival_date,
                                     l_model_arrival_date),
     x_return_status          => x_return_status);


  -------------------- ATO log req -----------------------

  ELSIF p_line_rec.ato_line_id IS NOT NULL AND
        NOT (p_line_rec.ato_line_id = p_line_rec.line_id AND
             p_line_rec.item_type_code = 'OPTION') THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LOGGING REQ TO SCHEDULE_ATO' , 3 ) ;
    END IF;

    -- 4052648 : Parameters p_param14 - 17 are added
    OE_Delayed_Requests_Pvt.Log_Request
    (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
     p_entity_id              => p_line_rec.ato_line_id,
     p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
     p_requesting_entity_id   => p_line_rec.line_id,
     p_request_type           => OE_GLOBALS.G_SCHEDULE_ATO,
     p_param1                 => l_sch_action,
     p_param2                 => p_line_rec.top_model_line_id,
     p_param3                 => p_line_rec.ship_from_org_id,
     p_param4                 => p_line_rec.ship_to_org_id,
     p_param5                 => p_line_rec.shipping_method_code, -- not req.
     p_param6                 => p_line_rec.demand_class_code, -- not req.
     p_param7                 => nvl(p_old_line_rec.ship_from_org_id,
                                     l_model_ship_from),
     p_param8                 => nvl(p_old_line_rec.demand_class_code,
                                     l_model_demand_class),
     p_param9                 => l_pto_ato_nonui,
     p_param11                => p_line_rec.override_atp_date_code,
     p_param14                => p_old_line_rec.ship_to_org_id,
     p_param15                => p_old_line_rec.shipping_method_code,
     p_param16                => p_old_line_rec.planning_priority,
     p_param17                => p_old_line_rec.delivery_lead_time,
     p_date_param1            => p_line_rec.request_date,
     p_date_param2            => p_line_rec.schedule_ship_date,
     p_date_param3            => p_line_rec.schedule_arrival_date,
     p_date_param4            => nvl(p_old_line_rec.request_date,
                                     l_model_request_date),
     p_date_param5            => nvl(p_old_line_rec.schedule_ship_date,
                                     l_model_ship_date),
     p_date_param6            => nvl(p_old_line_rec.schedule_arrival_date,
                                     l_model_arrival_date),
     x_return_status          => x_return_status);



  -------------------- NON SMC log req -----------------------

  ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LOGGING REQ TO SCHEDULE_NONSMC' , 3 ) ;
    END IF;

     -- 4052648 : Parameters p_param14 - 17 are added
   OE_Delayed_Requests_Pvt.Log_Request
    (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
     p_entity_id              => p_line_rec.line_id,
     p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
     p_requesting_entity_id   => p_line_rec.line_id,
     p_request_type           => OE_GLOBALS.G_SCHEDULE_NONSMC,
     p_param1                 => l_sch_action,
     p_param2                 => p_line_rec.top_model_line_id,
     p_param3                 => p_line_rec.ship_from_org_id,
     p_param4                 => p_line_rec.ship_to_org_id,
     p_param5                 => p_line_rec.shipping_method_code,
     p_param6                 => p_line_rec.demand_class_code,
     p_param7                 => p_old_line_rec.ship_from_org_id,
     p_param8                 => p_old_line_rec.demand_class_code,
     p_param9                 => l_pto_ato_nonui,
     p_param10                => 'Y',
     p_param11                => p_line_rec.override_atp_date_code,
     p_param14                => p_old_line_rec.ship_to_org_id,
     p_param15                => p_old_line_rec.shipping_method_code,
     p_param16                => p_old_line_rec.planning_priority,
     p_param17                => p_old_line_rec.delivery_lead_time,
     p_param24                => l_unreserve_flag, -- res changes**
     p_param25                => p_line_rec.header_id,
     p_date_param1            => p_line_rec.request_date,
     p_date_param2            => p_line_rec.schedule_ship_date,
     p_date_param3            => p_line_rec.schedule_arrival_date,
     p_date_param4            => p_old_line_rec.request_date,
     p_date_param5            => p_old_line_rec.schedule_ship_date,
     p_date_param6            => p_old_line_rec.schedule_arrival_date,
     x_return_status          => x_return_status);

  END IF;


  IF p_caller = OE_SCHEDULE_UTIL.SCH_EXTERNAL THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLER IS EXTERNAL' , 1 ) ;
    END IF;

    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
    (p_entity_code   => OE_GLOBALS.G_ENTITY_LINE
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

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING LOG_CONFIG_SCH_REQUEST '|| X_RETURN_STATUS , 3 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LOG_CONFIG_SCH_REQUEST ERROR '|| SQLERRM , 1 ) ;
    END IF;

    Delete_Attribute_Changes
    (p_entity_id => p_line_rec.top_model_line_id);

    RAISE;
END Log_Config_Sch_Request;



/*-----------------------------------------------------------
PROCEDURE Log_Attribute_Changes

This procedure can be used to save what key sch. params are
changed so that the sch action in not simply
SCHEDULE/RESCHEDULE, but needs some addtional work like
RESERVE/UNRESERVE.

Please note that the order of attribute change check is
very important because we are overwriting
x_qty_to_reserve and x_qty_to_unreserve.
------------------------------------------------------------*/
PROCEDURE Log_Attribute_Changes
(p_line_rec           IN  OE_Order_PUB.Line_Rec_Type
,p_old_line_rec       IN  OE_Order_PUB.Line_Rec_Type
,x_unreserve_flag     OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_diff_res_qty       NUMBER;
  l_qty_to_reserve     NUMBER;
  l_qty_to_unreserve   NUMBER;
  l_index              NUMBER;
  I                    NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING LOG_ATTRIBUTE_CHANGES' , 3 ) ;
  END IF;

  x_unreserve_flag := 'N';
  --l_index          := p_line_rec.line_id;
  l_index          := MOD(p_line_rec.line_id,G_BINARY_LIMIT);  --7827737
  -- 1. ordered qty
  IF NOT OE_GLOBALS.Equal(p_line_rec.ordered_quantity,
                          p_old_line_rec.ordered_quantity)
  THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NEW ORD QTY '|| P_LINE_REC.ORDERED_QUANTITY , 4 ) ;
    END IF;

    IF nvl(p_old_line_rec.reserved_quantity, 0) >
           p_line_rec.ordered_quantity
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'MAY NEED TO UNRESERVE' , 4 ) ;
      END IF;
      l_qty_to_unreserve
      := p_old_line_rec.reserved_quantity - p_line_rec.ordered_quantity;
    END IF;

    x_unreserve_flag := 'Y';

  END IF;


  -- 2. reserved qty
  l_diff_res_qty := nvl(p_line_rec.reserved_quantity, 0) -
                    nvl(p_old_line_rec.reserved_quantity, 0);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RES QTY DIFF '|| L_DIFF_RES_QTY , 1 ) ;
  END IF;

  IF l_diff_res_qty > 0 THEN
    l_qty_to_reserve   := l_diff_res_qty;
    l_qty_to_unreserve := null;
  ELSIF l_diff_res_qty < 0 THEN
    l_qty_to_unreserve := 0 - l_diff_res_qty;
  END IF;


  -- 3. ship from org
  IF NOT OE_GLOBALS.Equal(p_line_rec.ship_from_org_id,
                          p_old_line_rec.ship_from_org_id)
  THEN

    IF p_old_line_rec.ship_from_org_id is NOT NULL THEN
      x_unreserve_flag := 'Y';
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OLD SFROM '||P_OLD_LINE_REC.SHIP_FROM_ORG_ID , 4 ) ;
      END IF;
    END IF;

    l_qty_to_reserve
      := p_old_line_rec.reserved_quantity + l_diff_res_qty;
    l_qty_to_unreserve
      := p_old_line_rec.reserved_quantity;
  END IF;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  P_LINE_REC.LINE_ID || '.'|| L_QTY_TO_RESERVE , 3 ) ;
  END IF;

  IF l_qty_to_reserve is not NULL OR
     l_qty_to_unreserve  is not NULL THEN

    OE_Reservations_Tbl(l_index).entity_id
                           := p_line_rec.top_model_line_id;
    OE_Reservations_Tbl(l_index).line_id
                           := p_line_rec.line_id;
    OE_Reservations_Tbl(l_index).qty_to_reserve
                           := l_qty_to_reserve;
    OE_Reservations_Tbl(l_index).qty_to_unreserve
                           := l_qty_to_unreserve;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RES ' || OE_RESERVATIONS_TBL ( L_INDEX ) .QTY_TO_RESERVE , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTITY_ID '|| OE_RESERVATIONS_TBL ( L_INDEX ) .ENTITY_ID , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE_ID ' || OE_RESERVATIONS_TBL ( L_INDEX ) .LINE_ID , 3 ) ;
    END IF;

    IF l_qty_to_unreserve is NOT NULL THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNRES '||OE_RESERVATIONS_TBL ( L_INDEX ) .QTY_TO_UNRESERVE , 3 ) ;
      END IF;
      x_unreserve_flag := 'Y';
    END IF;

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING LOG_ATTRIBUTE_CHANGES '||X_UNRESERVE_FLAG , 3 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LOG_ATTRIBUTE_CHANGES ERROR '|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Log_Attribute_Changes;


/*------------------------------------------------------------
PROCEDURE Delete_Attribute_Changes

This procedure can be used to clean up the global table
where we store the reservations related informtion.

Use in the exceptions handlers of log_config_sch_requests
and schedule_smc, schedule_nonsmc.
------------------------------------------------------------*/
PROCEDURE Delete_Attribute_Changes
(p_entity_id   NUMBER := -1)
IS
  I    NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING DELETE_ATTRIBUTE_CHANGES '|| P_ENTITY_ID , 3 ) ;
  END IF;

  IF p_entity_id = -1 THEN
    OE_Reservations_Tbl.DELETE;
    RETURN;
  END IF;

  I := OE_Reservations_Tbl.FIRST;

  WHILE I is not NULL
  LOOP
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '---- LINE '|| OE_RESERVATIONS_TBL ( I ) .LINE_ID ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'QTY_TO_RES '|| OE_RESERVATIONS_TBL ( I ) .QTY_TO_RESERVE ) ;
    END IF;

    IF OE_Reservations_Tbl(I).entity_id = p_entity_id THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DELETING '|| I , 3 ) ;
      END IF;
      OE_Reservations_Tbl.DELETE(I);
    END IF;

    I := OE_Reservations_Tbl.NEXT(I);
  END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING LOG_ATTRIBUTE_CHANGES' , 3 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DELETE_ATTRIBUTE_CHANGES ERROR '|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Delete_Attribute_Changes;


/*------------------------------------------------------------
PROCEDURE Schedule_SMC

Dexcription:

  Since this is a PTO model, we need to take care of included
  items.

  The possible actions to come here are,
  SCHEDULE/RESERVE : query all options and bunch up all the lines
                     pass to mrp.
  Note: action of RESERVE comes only if the reserved quantity
        is changed on an unscheduled line or a scheduled line.
        Note that for RESERVE to come, none of the other
        sch. attributes are changed otherwise the action becomes
        SCHEDULE or RESCHEDULE respectively. We will not even
        log a delayed request for the scheduled line if only
        reserved quantity changes, control will not come here.

  UNSCHEDULE: query and work on all options
  RESCHEDULE: query and work on all options.

  If action is RESCHEDULE, we may need to do
  unreserve/reserve depending on the change in the sch. attribs.

  We do not need undemand/redemand because, change of
  inventory_item is not allowed on configurations.

  *may not always need to reschedule all lines.
  *reserved quantity can be changed and diff on all lines.

  Since RESCHEDULE with ship_from/reservation changed is a
  special case and required some complicated logic,
  it is handled in a seperate procedure.

  if lines are added to a scheduled smc, we will have to pass all
  lines in the smc: we have to honour the latest_accetable_date
  i.e. if we pass only the new lines iwth clearinf lates-acc_date,
  the insert itself can fail if sch fails. If larest_acc
  is present, all lines will get pushed. Let us not
  complicate the code for not so common case.
  the action itself will be made RESCHEDULE in above case.

  latest_acceptable_date if null, mrp can not give nay dates
  other than passed.
-------------------------------------------------------------*/
PROCEDURE Schedule_SMC
( p_request_rec    IN  OE_Order_Pub.Request_Rec_Type
 ,x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_count                NUMBER := 0;
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
  l_line_tbl             OE_ORDER_PUB.line_tbl_type;
  l_old_line_tbl         OE_Order_PUB.line_tbl_type;
  l_control_rec          OE_GLOBALS.control_rec_type;
  I                      NUMBER;
  l_send_cancel_lines    VARCHAR2(1); -- 2882255
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  Print_Time('entering Schedule_SMC ' || p_request_rec.entity_id);

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- 2882255
  IF p_request_rec.param1 = Oe_Schedule_Util.OESCH_ACT_SCHEDULE
   OR p_request_rec.param1 = Oe_Schedule_Util.OESCH_ACT_DEMAND THEN
     l_send_cancel_lines := 'N';
  ELSE
     l_send_cancel_lines := 'Y';
  END IF;
  --
  BEGIN

    Query_Set_Lines
    ( p_header_id         => p_request_rec.param25
     ,p_model_line_id     => p_request_rec.entity_id
     ,p_sch_action        => p_request_rec.param1
     ,p_send_cancel_lines => l_send_cancel_lines  --'Y' 2885522
     ,x_line_tbl          => l_line_tbl
     ,x_return_status     => x_return_status);


    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_old_line_tbl := l_line_tbl;

    I := l_line_tbl.FIRST;
    WHILE I is NOT NULL
    LOOP
      Validate_And_Assign_Sch_Params
      ( p_request_rec     => p_request_rec
       ,p_x_line_rec      => l_line_tbl(I)
       ,p_x_old_line_rec  => l_old_line_tbl(I));
      I := l_line_tbl.NEXT(I);
    END LOOP;

    ------------- setting attributes done -------------------

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING PROCESS_GROUP IN SMC' , 3 ) ;
    END IF;

    Process_Group
    (p_x_line_tbl       => l_line_tbl
    ,p_old_line_tbl     => l_old_line_tbl
    ,p_sch_action       => p_request_rec.param1
    ,p_handle_unreserve => p_request_rec.param24
    ,x_return_status    => x_return_status);

  EXCEPTION
    WHEN OTHERS THEN
      Delete_Attribute_Changes
      (p_entity_id => p_request_rec.entity_id);

      RAISE;
  END;

  Print_Time('leaving Schedule_SMC ' || p_request_rec.entity_id);
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNEXP ERROR IN SCHEDULE_SMC' , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN FND_API.G_EXC_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXC ERROR IN SCHEDULE_SMC' , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR IN SCHEDULE_SMC '|| SQLERRM , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
        ,'Schedule_SMC'
            );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Schedule_SMC;


/*------------------------------------------------------------
PROCEDURE Schedule_ATO
Description:

  In case of ATO we always need to call MRP with the
  entire group. This is a CTO's requirement.

  Action RESERVE and UNRESERVE is not allowed on ATO's.
  Action UNSCHEDULE is not allowed on ATO's if config
  item is created.

  getting mandatory components is done in load_mrp.

  we are explicitly overwrite some values to all the
  lines in the queried line_tbl, because scheduling
  will make sure that these values are same on all
  the lines of an ato configuration.
  these columns are:
    1) ship_from_org_id
    2) ship_to_org_id
    3) request_date
    4) schedule_ship_date
    5) schedule_arrival_date

 NOTE:
 The l_old_line_tbl is not doing any role in this proceudre.
 It is passed only so that we pass it on the oe_order_pvt.lines
 and avoid lines procedure querying all the same lines again.
 This is same with Schedule_SMC and Schedule_NONSMC also.
 Also we do not do any setting on the l_control_rec.

 The old values of ship_from and demand_class saved in the
 delayed_request are going to be the same on all the ato
 options hance not passed on the old_line_tbl to
 re/call_mrp. Thus saving looping through the
 table.

 Since you can not reserve/unreserve ato, all the actions
 'SCHEDULE''UNSCHEDULE''RESCHEDULE', will be processed
 by calling call_mrp only.
-------------------------------------------------------------*/
PROCEDURE Schedule_ATO
( p_request_rec    IN  OE_Order_Pub.Request_Rec_Type
 ,x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_line_tbl        OE_ORDER_PUB.line_tbl_type;
  l_old_line_tbl    OE_Order_PUB.line_tbl_type;
  I                 NUMBER;
  l_send_cancel_lines VARCHAR2(1); -- 2882255
  l_request           VARCHAR2(8) := 'ATO';
  l_request_search_rslt BOOLEAN;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  Print_Time('Entering Schedule_ATO ' || p_request_rec.entity_id);
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- 2882255
  IF p_request_rec.param1 = Oe_Schedule_Util.OESCH_ACT_SCHEDULE
   OR p_request_rec.param1 = Oe_Schedule_Util.OESCH_ACT_DEMAND THEN
     l_send_cancel_lines := 'N';
  ELSE
     l_send_cancel_lines := 'Y';
  END IF;
  --

  IF p_request_rec.param12 = 'DELETE' THEN

    IF p_request_rec.param13 is not null
    OR p_request_rec.param14 is not null THEN

       IF Check_For_Request
       (p_set_id => nvl(p_request_rec.param13,p_request_rec.param14),
        p_ato_line_id => p_request_rec.entity_id)
       THEN

          l_request := 'NONE';
          RETURN;

       ELSE -- check


          l_request := 'SET';

          IF p_request_rec.param13 is not null  THEN

              Oe_Config_Schedule_Pvt.Query_Set_Lines
               (p_header_id      => p_request_rec.param25,
                p_arrival_set_id => p_request_rec.param13,
                p_sch_action     => p_request_rec.param1,
                x_line_tbl       => l_line_tbl,
                x_return_status  => x_return_status);

            ELSIF p_request_rec.param14 is  not null  THEN

               Oe_Config_Schedule_Pvt.Query_Set_Lines
                 (p_header_id     => p_request_rec.param25,
                  p_ship_set_id   => p_request_rec.param14,
                  p_sch_action    => p_request_rec.param1,
                  x_line_tbl      => l_line_tbl,
                  x_return_status  => x_return_status);

         END IF; -- 13,14

        END IF; -- Check

     ELSIF p_request_rec.param15 = 'Y' THEN

       l_request_search_rslt :=
        OE_Delayed_Requests_PVT.Check_For_Request
        (p_entity_code    => OE_GLOBALS.G_ENTITY_LINE,
         p_entity_id      => p_request_rec.param2,
         p_request_type   => OE_GLOBALS.G_SCHEDULE_SMC);

        IF l_request_search_rslt THEN
             l_request := 'NONE';
             Return;
        END IF;

         l_request := 'SMC';
         Query_Set_Lines
        ( p_header_id         => p_request_rec.param25
         ,p_model_line_id     => p_request_rec.param2
         ,p_sch_action        => p_request_rec.param1
         ,p_send_cancel_lines => l_send_cancel_lines  --'Y' 2885522
         ,x_line_tbl          => l_line_tbl
         ,x_return_status     => x_return_status);



     END IF; -- Param 13,14,15

  END IF; -- Delete

  IF l_request = 'ATO' THEN
    OE_Config_Util.Query_ATO_Options
    ( p_ato_line_id       => p_request_rec.entity_id
     ,p_send_cancel_lines => l_send_cancel_lines  --'Y' 2882255
     --,p_source_type       => OE_Globals.G_SOURCE_INTERNAL --3998413
     ,x_line_tbl          => l_line_tbl);
  END IF;

  l_old_line_tbl := l_line_tbl;

  I := l_line_tbl.FIRST;
  WHILE I is NOT NULL
  LOOP

    Validate_And_Assign_Sch_Params
    ( p_request_rec     => p_request_rec
     ,p_x_line_rec      => l_line_tbl(I)
     ,p_x_old_line_rec  => l_old_line_tbl(I));

    I := l_line_tbl.NEXT(I);
  END LOOP;


  Process_Group
  (p_x_line_tbl     => l_line_tbl
  ,p_old_line_tbl   => l_old_line_tbl
  ,p_sch_action     => p_request_rec.param1
  ,p_caller         => 'SCHEDULE_ATO'
  ,x_return_status  => x_return_status);

  Print_Time('Exiting Schedule_ATO');

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNEXP ERROR IN SCHEDULE_ATO' , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN FND_API.G_EXC_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXC ERROR IN SCHEDULE_ATO' , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR IN SCHEDULE_ATO '|| SQLERRM , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
        ,'Schedule_ATO'
            );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Schedule_ATO;


/*------------------------------------------------------------
PROCEDURE Schedule_NONSMC

We will consolidate the Schedule_NONSMC requests in such a
way that the p_request_tbl will have all request_recs with
same scheduling action. Thus, within 1 nonsmc model if
action of reschedule comes on couple of lines and action
unschedule comes on few lines, there will be 2 groups
and this procedure will get executed twice.

The assumption here is, there is a good chance that we get
only 1 action type in 1 process_order call on the nonsmc
lines. In a rare case if more thatn 1 action comes together,
we handle them seperately.

Note: ATO witing nonSMC will be handled by the Schedule_ATO
delayed request and should never come here.
-------------------------------------------------------------*/
PROCEDURE Schedule_NONSMC
( p_request_tbl     IN  OUT NOCOPY OE_Order_PUB.request_tbl_type
 ,p_res_changes     IN  VARCHAR2 := 'N'
 ,x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_line_tbl        OE_ORDER_PUB.line_tbl_type;
  l_old_line_tbl    OE_Order_PUB.line_tbl_type;
  l_inc_items_tbl   OE_Order_PUB.line_tbl_type;
  J                 NUMBER := 0;
  L                 NUMBER := 0;
  I                 NUMBER;
  l_sales_order_id  NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  Print_Time('entering schedule_nonsmc ' || p_request_tbl.COUNT);

  BEGIN

    I := p_request_tbl.FIRST;
    WHILE I is not NULL
    LOOP
      IF p_request_tbl(I).param10 = 'Y' THEN

        J := J + 1;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE ' || P_REQUEST_TBL ( I ) .ENTITY_ID , 3 ) ;
        END IF;

        l_line_tbl(J).line_id := 0;

        OE_Line_Util.Query_Row
        ( p_line_id         => p_request_tbl(I).entity_id
         ,x_line_rec        => l_line_tbl(J));

        IF l_line_tbl(J).schedule_status_code is not null AND
           l_line_tbl(J).shippable_flag = 'Y' THEN

          IF l_sales_order_id is NULL THEN
            l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id
                                (l_line_tbl(J).header_id);
          END IF;

          l_line_tbl(J).reserved_quantity :=
               OE_LINE_UTIL.Get_Reserved_Quantity
               (p_header_id   => l_sales_order_id,
                p_line_id     => l_line_tbl(J).line_id,
                p_org_id      => l_line_tbl(J).ship_from_org_id);
        END IF;

        IF l_line_tbl(J).reserved_quantity = FND_API.G_MISS_NUM THEN
          l_line_tbl(J).reserved_quantity := 0;
        END IF;

        l_old_line_tbl(J) := l_line_tbl(J);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING VALIDATE_AND_ASSIGN_SCH_PARAMS' , 3 ) ;
        END IF;

        Validate_And_Assign_Sch_Params
        ( p_request_rec       => p_request_tbl(I)
         ,p_x_line_rec        => l_line_tbl(J)
         ,p_x_old_line_rec    => l_old_line_tbl(J));


        IF l_line_tbl(J).item_type_code in ('MODEL', 'CLASS', 'KIT')
        THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'CALLING GET_INCLUDED_ITEMS_TO_SCH' , 3 ) ;
          END IF;

          Get_Included_Items_To_Sch
          ( p_x_line_tbl      => l_line_tbl
           ,p_x_old_line_tbl  => l_old_line_tbl
           ,p_request_tbl     => p_request_tbl
           ,p_in_index        => J
           ,p_req_index       => I);

        END IF;

      ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ALREADY PROCESSED INC ITEM' , 3 ) ;
        END IF;
      END IF;

      I := p_request_tbl.NEXT(I);

    END LOOP;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_REQUEST_TBL ( 1 ) .PARAM1||' '||P_REQUEST_TBL ( 1 ) .PARAM24 , 3 ) ;
    END IF;

    Process_Group
    (p_x_line_tbl       => l_line_tbl
    ,p_old_line_tbl     => l_old_line_tbl
    ,p_sch_action       => p_request_tbl(1).param1
    ,p_handle_unreserve => p_res_changes
    ,x_return_status    => x_return_status);

  EXCEPTION
    WHEN OTHERS THEN
      Delete_Attribute_Changes
      (p_entity_id => p_request_tbl(1).entity_id);

      RAISE;
  END;

  Print_Time('leaving schedule_nonsmc');
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNEXP ERROR IN SCHEDULE_NONSMC' , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN FND_API.G_EXC_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXC ERROR IN SCHEDULE_NONSMC' , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS IN SCHEDULE_NONSMC '|| SQLERRM , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
        ,'Schedule_NONSMC'
            );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Schedule_NONSMC;


/*----------------------------------------------------------
Procedure Get_Included_Items_To_Sch
This procedure is used to get the included items
in case of scheduling a non SMC model.

Bug 2463742: call to log_attribute_changes for INCLUDED item
if it is rescheduled because of change on the parent.
-----------------------------------------------------------*/
PROCEDURE Get_Included_Items_To_Sch
( p_x_line_tbl      IN OUT NOCOPY OE_Order_PUB.line_tbl_type
 ,p_x_old_line_tbl  IN OUT NOCOPY OE_Order_PUB.line_tbl_type
 ,p_request_tbl     IN OUT NOCOPY OE_Order_PUB.request_tbl_type
 ,p_in_index        IN OUT NOCOPY /* file.sql.39 change */ NUMBER
 ,p_req_index       IN NUMBER)
IS
  l_inc_items_tbl   OE_Order_PUB.line_tbl_type;
  L                 NUMBER := 0;
  l_done            BOOLEAN;
  l_unreserve_flag  VARCHAR2(1);
  l_send_cancel_lines VARCHAR2(1);  -- 2882255
  l_return_status   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_INCLUDED_ITEMS_TO_SCH' , 3 ) ;
  END IF;

  -- 2882255
  IF p_request_tbl(p_req_index).param1 = Oe_Schedule_Util.OESCH_ACT_SCHEDULE
   OR p_request_tbl(p_req_index).param1 = Oe_Schedule_Util.OESCH_ACT_DEMAND THEN
     l_send_cancel_lines := 'N';
  ELSE
     l_send_cancel_lines := 'Y';
  END IF;
  --

  Query_Set_Lines
  ( p_header_id         => p_x_line_tbl(p_in_index).header_id
   ,p_link_to_line_id   => p_x_line_tbl(p_in_index).line_id
   ,p_sch_action        => p_request_tbl(p_req_index).param1
   ,p_send_cancel_lines => l_send_cancel_lines  -- 'Y' 2882255
   ,x_line_tbl          => l_inc_items_tbl
   ,x_return_status     => l_return_status);

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_inc_items_tbl.COUNT > 0 THEN

    FOR K in l_inc_items_tbl.FIRST..l_inc_items_tbl.LAST
    LOOP

      p_in_index := p_in_index + 1;
      p_x_line_tbl(p_in_index)     := l_inc_items_tbl(K);
      p_x_old_line_tbl(p_in_index) := l_inc_items_tbl(K);
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  K||'INC ITEM '||P_X_LINE_TBL ( P_IN_INDEX ) .LINE_ID , 4 ) ;
      END IF;

      l_done := FALSE;

      L := p_request_tbl.FIRST;
      WHILE L is not NULL AND NOT l_done
      LOOP
        IF p_request_tbl(L).entity_id = l_inc_items_tbl(K).line_id
        THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  L || ' USER CHANGED INC ITEM '|| P_IN_INDEX , 5 ) ;
          END IF;

          Validate_And_Assign_Sch_Params
          ( p_request_rec       => p_request_tbl(L) -- imp use L
           ,p_x_line_rec        => p_x_line_tbl(p_in_index)
           ,p_x_old_line_rec    => p_x_old_line_tbl(p_in_index));

          p_request_tbl(L).param10 := 'N';
          l_done := TRUE;
        END IF;

        L := p_request_tbl.NEXT(L);
      END LOOP;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LOOPED THRU REQ TBL '|| L , 3 ) ;
      END IF;

      IF NOT l_done THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  P_REQ_INDEX||' USER CHANGED PARENT '||P_IN_INDEX , 5 ) ;
        END IF;

        Validate_And_Assign_Sch_Params
        ( p_request_rec       => p_request_tbl(p_req_index) -- imp req_index
         ,p_x_line_rec        => p_x_line_tbl(p_in_index)
         ,p_x_old_line_rec    => p_x_old_line_tbl(p_in_index));

        IF p_request_tbl(p_req_index).param1 =
               OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE THEN
          Log_Attribute_Changes
          (p_line_rec           => p_x_line_tbl(p_in_index)
          ,p_old_line_rec       => p_x_old_line_tbl(p_in_index)
          ,x_unreserve_flag     => l_unreserve_flag);
        END IF;

      END IF;

    END LOOP; -- over the inc_tbl

  END IF; -- if inc tbl count > 0

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING GET_INCLUDED_ITEMS_TO_SCH' , 3 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GET_INCLUDED_ITEMS_TO_SCH '|| SQLERRM , 1 ) ;
  END IF;
  RAISE;
END Get_Included_Items_To_Sch;

/*----------------------------------------------------------
PROCEDURE Process_Group

a) This procedure will be used when caller sets all the
sch. attribs on all the lines of a group and now
wants to perform any of the following actions on
all the lines:

 p_sch_action will be,
  1) SCHEDULE   : also need to check the reservation time fence
  2) UNSCHEDULE : also need to unreserve if reqd.
  3) RESERVE    : need to schedule if lines are not prescheduled.
  4) UNRESERVE  : only unreserve(what about time fence)

b) Current major callers are schedule_multi_selected_lines
and schedule_order APIs and schedule_smc, schedule_ato,
schedule_nonsmc APIs, schedule_sets.

c) The reserved_quantity column should be populated
on the line records by the caller.
reserve_group API is smart enough to look at the sch level,
time fence, shippable_flag, user enterd values etc.

d) The call to save_sch_attribs will try to save lines call
in some cases,
ex: ordered_qty changes and sch. success
    new lines addtion to a scheduled grp.

e) the p_partial and p_partial_set parameters are used for
ui and sets caller.

f) the call to reserve_group is moved after the
   process_order call, because of the inv change,
   they need correct warehouse on the line.
---------------------------------------------------------*/
PROCEDURE Process_Group
( p_x_line_tbl       IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_old_line_tbl     IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_sch_action       IN  VARCHAR2
 ,p_caller           IN  VARCHAR2 := 'X'
 ,p_handle_unreserve IN  VARCHAR2 := 'N'
 ,p_partial          IN  BOOLEAN := FALSE
 ,p_partial_set      IN  BOOLEAN := FALSE
 ,p_part_of_set      IN  VARCHAR2 DEFAULT 'N' -- 4405004
 ,x_return_status    OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_control_rec     OE_GLOBALS.control_rec_type;
  l_sch_action      VARCHAR2(30);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  Print_Time('entering Process_Group');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_UNSCHEDULE OR
     p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_UNRESERVE
  THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNRESERVING...' , 3 ) ;
    END IF;

    Unreserve_group(p_line_tbl    => p_x_line_tbl
                   ,p_sch_action  => p_sch_action); -- 2595661

    IF  p_sch_action = OE_Schedule_Util.OESCH_ACT_UNSCHEDULE
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NOW UNSCHEDULING...' , 3 ) ;
      END IF;

      Call_Mrp
      ( p_x_line_tbl        => p_x_line_tbl
       ,p_old_line_tbl      => p_old_line_tbl
       ,p_sch_action        => p_sch_action
       ,x_return_status     => x_return_status);
    END IF;

  ELSE ---------- action is sch or resch or reserve.-----

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SCH ACTION IS '|| P_SCH_ACTION , 3 ) ;
    END IF;

    IF p_sch_action = OE_Schedule_Util.OESCH_ACT_RESERVE THEN
      l_sch_action := OE_Schedule_Util.OESCH_ACT_SCHEDULE;
    ELSE
      l_sch_action := p_sch_action;
    END IF;

    IF p_sch_action = OE_Schedule_Util.OESCH_ACT_RESCHEDULE AND
       (p_handle_unreserve = 'Y' OR
        p_caller = 'SET')
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  '1 CALLING HANDLE_UNRESERVE' , 4 ) ;
      END IF;

      Handle_Unreserve
      (p_x_line_tbl     => p_x_line_tbl
      ,p_old_line_tbl   => p_old_line_tbl
      ,x_return_status  => x_return_status);

    END IF;

    Call_Mrp
    ( p_x_line_tbl        => p_x_line_tbl
     ,p_old_line_tbl      => p_old_line_tbl
     ,p_sch_action        => l_sch_action
     ,p_partial           => p_partial
     ,p_partial_set       => p_partial_set
     ,p_part_of_set       => p_part_of_set --4405004
     ,x_return_status     => x_return_status);


    -- Additing additional Unreserve call as part of item substitution
    -- Project. If the item has been replaced by MRP during re-scheduling
    -- process then unreserve the reservation on old item.

    IF p_sch_action = OE_Schedule_Util.OESCH_ACT_RESCHEDULE AND
       p_caller = 'SET'
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  '2 CALLING HANDLE_UNRESERVE' , 4 ) ;
      END IF;

      Handle_Unreserve
      (p_x_line_tbl     => p_x_line_tbl
      ,p_old_line_tbl   => p_old_line_tbl
      ,p_post_process   => FND_API.G_TRUE
      ,x_return_status  => x_return_status);

    END IF;

  END IF; ------- end if action = unsch or unres -----


  IF p_sch_action <> OE_SCHEDULE_UTIL.OESCH_ACT_UNRESERVE THEN

    Save_Sch_Attributes
    ( p_x_line_tbl     => p_x_line_tbl
     ,p_old_line_tbl   => p_old_line_tbl
     ,p_sch_action     => p_sch_action
     ,p_caller         => OE_SCHEDULE_UTIL.SCH_EXTERNAL
     ,x_return_status  => x_return_status);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NO NEED TO CALL LINES' , 3 ) ;
    END IF;
  END IF;


  IF p_caller     <> 'SCHEDULE_ATO' AND
     p_sch_action <> OE_Schedule_Util.OESCH_ACT_UNSCHEDULE AND
     p_sch_action <> OE_Schedule_Util.OESCH_ACT_UNRESERVE
  THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING RESERVE_GROUP NOW ' , 3 ) ;
    END IF;

    Reserve_Group
    ( p_x_line_tbl        => p_x_line_tbl
     ,p_sch_action        => p_sch_action);
  END IF;

  Print_Time('leaving Process_Group');

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    IF p_caller <> 'UI_ACTION' AND
       p_caller <> 'SCHEDULE_ATO'
    THEN
      Delete_Attribute_Changes
      (p_entity_id => nvl(nvl(p_x_line_tbl(1).arrival_set_id,
                              p_x_line_tbl(1).ship_set_id),
                          p_x_line_tbl(1).top_model_line_id));

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXC ERROR IN PROCESS_GROUP' , 1 ) ;
      END IF;
    END IF;

    -- do not raise, caller wants to handle: sets
    --RAISE FND_API.G_EXC_ERROR;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
        ,'Process_Group'
            );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Process_Group;


/*----------------------------------------------------------------
PROCEDURE Call_Mrp

The code is same irrespective of action SCHEDULE or UNSCHEDULE
or RESCHEDULE.

Aswin confirmed that once I pass p_sch_action to load_mrp
and load_results, I do not have to pass schedule_action_code
on individual lines. This is so that I can avoid looping
through the line_tbl just to set the schedule_action_code.

Procedure has been modified to fix the bipass calling MRP code
for inactive demand project.1955004
-----------------------------------------------------------------*/
PROCEDURE Call_Mrp
( p_x_line_tbl        IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_old_line_tbl      IN  OE_Order_Pub.Line_Tbl_Type
 ,p_sch_action        IN  VARCHAR2
 ,p_partial           IN  BOOLEAN := FALSE
 ,p_partial_set       IN  BOOLEAN := FALSE
 ,p_part_of_set       IN  VARCHAR2 DEFAULT 'N' --4405004
 ,x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_session_id           NUMBER := 0;
  l_mrp_atp_rec          MRP_ATP_PUB.ATP_Rec_Typ;
  l_out_mtp_atp_rec      MRP_ATP_PUB.ATP_Rec_Typ;
  l_atp_supply_demand    MRP_ATP_PUB.ATP_Supply_Demand_Typ;
  l_atp_period           MRP_ATP_PUB.ATP_Period_Typ;
  l_atp_details          MRP_ATP_PUB.ATP_Details_Typ;
  l_msg_data             VARCHAR2(200);
  l_msg_count            NUMBER;
  l_mrp_called		     BOOLEAN := FALSE;
  l_line_id_mod          NUMBER ; --7827737
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  Print_Time('entering Call_Mrp');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OE_Schedule_Util.Load_MRP_request_from_tbl
  ( p_line_tbl           => p_x_line_tbl
   ,p_old_line_tbl       => p_old_line_tbl
   ,p_sch_action         => p_sch_action
   ,p_partial_set        => p_partial_set
   ,p_part_of_set        => p_part_of_set  --4405004
   ,x_mrp_atp_rec        => l_mrp_atp_rec);


  -- 1955004 modified statement below from = to >
  -- removed return and end if to encompass code to add an else clause
  IF l_mrp_atp_rec.error_code.count > 0 THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NEED TO CALL MRP , > 0 COUNT' , 1 ) ;
    END IF;


  l_session_id := OE_SCHEDULE_UTIL.Get_Session_Id;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SESSION ID IN CALL_MRP ' || L_SESSION_ID , 2 ) ;
  END IF;

  Print_Time('calling mrps atp api');

  MRP_ATP_PUB.Call_ATP
  ( p_session_id             =>  l_session_id
   ,p_atp_rec                =>  l_mrp_atp_rec
   ,x_atp_rec                =>  l_out_mtp_atp_rec
   ,x_atp_supply_demand      =>  l_atp_supply_demand
   ,x_atp_period             =>  l_atp_period
   ,x_atp_details            =>  l_atp_details
   ,x_return_status          =>  x_return_status
   ,x_msg_data               =>  l_msg_data
   ,x_msg_count              =>  l_msg_count);

   l_mrp_called := TRUE;

   Print_Time('After MRPs ATP API: ' || x_return_status);

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN

    OE_SCHEDULE_UTIL.Display_sch_errors
    (p_atp_rec  => l_out_mtp_atp_rec,
     p_line_tbl => p_x_line_tbl);

   END IF;

  END IF; -- Moved for 1955004

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- the call to MRP was successful, so load the results

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING LOAD_RESULTS' , 1 ) ;
    END IF;

    OE_Schedule_Util.Load_Results_from_tbl
    ( p_atp_rec        => l_out_mtp_atp_rec
    , p_old_line_tbl   => p_old_line_tbl   -- 1955004
    , p_x_line_tbl     => p_x_line_tbl
    , p_sch_action     => p_sch_action
    , p_partial        => p_partial
    , p_partial_set    => p_partial_set
    , x_return_status  => x_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER LOAD_RESULTS: ' || X_RETURN_STATUS , 1 ) ;
    END IF;

  ELSE
    IF l_out_mtp_atp_rec.error_code.count = 0  AND
       l_mrp_called THEN
       -- we were expecting some date from MRP, but did not get any

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'MRP HAS NOT RETURNED ANY DATA' , 1 ) ;
      END IF;

      FND_MESSAGE.SET_NAME('ONT','OE_SCH_ATP_ERROR');
      OE_MSG_PUB.Add;

     END IF;

     -- New Code for 1955004
     IF OE_SCHEDULE_UTIL.OE_inactive_demand_tbl.count > 0 THEN
     -- even though MRP did not have anything, we have some
     -- Inactive Demand Rows to process

      FOR I in 1.. p_x_line_tbl.count LOOP

      l_line_id_mod := MOD(p_x_line_tbl(I).line_id,G_BINARY_LIMIT); --7827737

        IF OE_SCHEDULE_UTIL.OE_inactive_demand_tbl.EXISTS
                                 (l_line_id_mod) THEN   --7827737
                                 --(p_x_line_tbl(I).line_id) THEN
        -- we know this line has an inactive demand scheduling level

                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'CALLING INACTIVE_DEMAND_SCHEDULING FROM ELSE IN CALL_MRP' , 1 ) ;
                            END IF;

          OE_SCHEDULE_UTIL.Inactive_demand_scheduling
              (p_x_old_line_rec => p_old_line_tbl(I)
              ,p_x_line_rec     => p_x_line_tbl(I)
              ,x_return_status  => x_return_status);

          OE_SCHEDULE_UTIL.OE_inactive_demand_tbl.DELETE
                             (l_line_id_mod) ;   --7827737
                             --(p_x_line_tbl(I).line_id);

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

        ELSE
        -- this row must have been a part of the Call_ATP call that
        -- failed, so set the operator flag.

          p_x_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;

        END IF;

     END LOOP;

   END IF;

  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  Print_Time('leaving Call_Mrp');

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALL_MRP ERROR' || SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Call_Mrp;


/*----------------------------------------------------------------
PROCEDURE Unreserve_group
Note: I am not querying the reserved_qty, it should be set on
the lines records.

This procedure is called from 2 places,
1) process_group, if unschedule or unreserve action.
2) handle_res_changes: called for ship_from change,

we should log the qty to reserve in the reservation_tbl,
does not afftect 1st caller and is used later in
reserve_group.
-----------------------------------------------------------------*/
PROCEDURE Unreserve_group
( p_line_tbl    IN OE_Order_Pub.Line_Tbl_Type
 ,p_sch_action  IN VARCHAR2 := 'X')
IS
  l_return_status  VARCHAR2(1);
  I                NUMBER;
  l_line_id_mod    NUMBER ; --7827737
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  Print_Time('entering Unreserve_group');

  I := p_line_tbl.FIRST;
  WHILE I is not NULL
  LOOP
    l_line_id_mod := MOD(p_line_tbl(I).line_id,G_BINARY_LIMIT); --7827737
    IF p_line_tbl(I).reserved_quantity > 0 AND
       p_line_tbl(I).reserved_quantity is NOT NULL THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  P_LINE_TBL ( I ) .LINE_ID||'UNRESERVE ' ||P_LINE_TBL ( I ) .RESERVED_QUANTITY , 3 ) ;
       END IF;
       -- Start 2595661
       IF nvl(p_line_tbl(I).shipping_interfaced_flag,'N') = 'Y' THEN
         IF ( (p_sch_action = OE_Schedule_Util.OESCH_ACT_UNRESERVE
            OR p_sch_action = OE_Schedule_Util.OESCH_ACT_RESCHEDULE) -- 6628134
            AND NOT oe_schedule_util.Get_Pick_Status(p_line_tbl(I).line_id) ) THEN

            OE_SCHEDULE_UTIL.Do_Unreserve
                 ( p_line_rec               => p_line_tbl(I)
                 , p_quantity_to_unreserve  => p_line_tbl(I).reserved_quantity
                 , p_quantity2_to_unreserve => NVL(p_line_tbl(I).reserved_quantity2, 0)    -- INVCONV
                 , x_return_status          => l_return_status);
        END IF;
       ELSE
       -- End 2595661

        OE_SCHEDULE_UTIL.Unreserve_Line
            ( p_line_rec               => p_line_tbl(I)
             ,p_quantity_to_unreserve  => p_line_tbl(I).reserved_quantity
             ,p_quantity2_to_unreserve  => nvl(p_line_tbl(I).reserved_quantity2, 0) -- INVCONV
             ,x_return_status          => l_return_status);
       END IF; -- 2595661

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF p_sch_action = OE_Schedule_Util.OESCH_ACT_RESCHEDULE THEN

       -- IF NOT OE_Reservations_Tbl.EXISTS(p_line_tbl(I).line_id) OR
        --   OE_Reservations_Tbl(p_line_tbl(I).line_id).qty_to_reserve
         --  is NULL
        IF NOT OE_Reservations_Tbl.EXISTS(l_line_id_mod) OR --7827737
        OE_Reservations_Tbl(l_line_id_mod).qty_to_reserve
        is NULL
        THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'ADDING REC TO RES TBL' , 2 ) ;
          END IF;

          IF p_line_tbl(I).arrival_set_id is NOT NULL THEN
            --OE_Reservations_Tbl(p_line_tbl(I).line_id).entity_id
            OE_Reservations_Tbl(l_line_id_mod).entity_id    --7827737
                            := p_line_tbl(I).arrival_set_id;

          ELSIF p_line_tbl(I).ship_set_id is NOT NULL THEN
            --OE_Reservations_Tbl(p_line_tbl(I).line_id).entity_id
            OE_Reservations_Tbl(l_line_id_mod).entity_id  --7827737
                            := p_line_tbl(I).ship_set_id;

          ELSIF p_line_tbl(I).top_model_line_id is NOT NULL THEN
            --OE_Reservations_Tbl(p_line_tbl(I).line_id).entity_id
            OE_Reservations_Tbl(l_line_id_mod).entity_id  --7827737
                            := p_line_tbl(I).top_model_line_id;

          END IF;

          --OE_Reservations_Tbl(p_line_tbl(I).line_id).line_id
          OE_Reservations_Tbl(l_line_id_mod).line_id   --7827737
                             := p_line_tbl(I).line_id;

          -- this is only so that we can avoid reservation for CMS.
          -- note the change in get_reservation api.
          --OE_Reservations_Tbl(p_line_tbl(I).line_id).qty_to_unreserve
          OE_Reservations_Tbl(l_line_id_mod).qty_to_unreserve   --7827737
                               := p_line_tbl(I).reserved_quantity;

          IF p_line_tbl(I).ordered_quantity > p_line_tbl(I).reserved_quantity
          THEN
            --OE_Reservations_Tbl(p_line_tbl(I).line_id).qty_to_reserve
            OE_Reservations_Tbl(l_line_id_mod).qty_to_reserve  --7827737
                               := p_line_tbl(I).reserved_quantity;
          ELSE
            --OE_Reservations_Tbl(p_line_tbl(I).line_id).qty_to_reserve
            OE_Reservations_Tbl(l_line_id_mod).qty_to_reserve    --7827737
                               := p_line_tbl(I).ordered_quantity;
          END IF;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RES ' || OE_RESERVATIONS_TBL ( P_LINE_TBL ( I ) .LINE_ID ) .QTY_TO_RESERVE , 3 ) ;
          END IF;
        END IF;

      END IF; -- action = reschedule

    END IF; -- res qty > 0

    I := p_line_tbl.NEXT(I);

  END LOOP;

  Print_Time('leaving Unreserve_group');

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNRESERVE_GROUP ERROR' || SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Unreserve_group;


/*----------------------------------------------------------------
PROCEDURE Reserve_Group

This procedure is mainly used when action is plain
SCHEDULE or RESERVE. If the action is RESCHEDULE,
we may follow different route if unreserve, ship_from etc.
comes into picture, for normal reschedule, we still check
the reservation time fence etc.

The order is:
check the scheduling level
if level ok,
  check the oe_reservation_tbl,
  if record exist, get value.
  check the the time fence, if within, reserve.
end if;

Note: Do not call this procedure if the p_sch_action
is UNSCHEDULE or UNRESERVE

**You may want to make the p_line_tbl IN and copy it
to local variable since we are assigning some values to
reserved_quantity whcih may or may not get reserved.
or use l_old_reserved_quantity  logic.

p_sch_action is just a hint.
-----------------------------------------------------------------*/
PROCEDURE Reserve_Group
( p_x_line_tbl       IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_sch_action       IN VARCHAR2)
IS
  l_return_status           VARCHAR2(1);
  l_do_reserve              BOOLEAN;
  l_sch_level               VARCHAR2(30);
  l_scheduled_grp           NUMBER;
  l_reservation_qty         NUMBER;
  l_reservation_qty2        NUMBER; -- INVCONV
  I                         NUMBER;
    l_rsv_update              BOOLEAN := FALSE;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  Print_Time('entering Reserve_Group ' || p_sch_action);

  I := p_x_line_tbl.FIRST;
  WHILE I is not NULL
  LOOP

    OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => p_x_line_tbl(I).line_id
         ,p_header_id                   => p_x_line_tbl(I).header_id
         ,p_line_id                     => p_x_line_tbl(I).line_id
         ,p_orig_sys_document_ref       => p_x_line_tbl(I).orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => p_x_line_tbl(I).orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => p_x_line_tbl(I).orig_sys_shipment_ref
         ,p_change_sequence             => p_x_line_tbl(I).change_sequence
         ,p_source_document_id          => p_x_line_tbl(I).source_document_id
         ,p_source_document_line_id     => p_x_line_tbl(I).source_document_line_id
         ,p_order_source_id             => p_x_line_tbl(I).order_source_id
         ,p_source_document_type_id     => p_x_line_tbl(I).source_document_type_id);

    l_reservation_qty := 0;
    l_reservation_qty2 := 0; -- INVCONV

    IF nvl(p_x_line_tbl(I).shippable_flag, 'N') = 'Y' AND
           p_x_line_tbl(I).ordered_quantity > 0 AND
           p_x_line_tbl(I).Item_type_code <> 'CONFIG' AND
       nvl(p_x_line_tbl(I).schedule_status_code, 'X') =
           OE_SCHEDULE_UTIL.OESCH_STATUS_SCHEDULED
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'WORKING ON LINE '|| P_X_LINE_TBL ( I ) .LINE_ID , 3 ) ;
      END IF;

      l_sch_level := OE_SCHEDULE_UTIL.Get_Scheduling_Level
                     (p_x_line_tbl(I).header_id,
                      p_x_line_tbl(I).line_type_id);


      IF nvl(l_sch_level, OE_Schedule_Util.SCH_LEVEL_THREE) =
             OE_Schedule_Util.SCH_LEVEL_THREE
        OR l_sch_level = OE_Schedule_Util.SCH_LEVEL_FOUR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SCH LEVEL ALLOWS FOR RESERVATION' , 3 ) ;
        END IF;

        Get_Reservations( p_line_rec        => p_x_line_tbl(I)
                         ,x_reservation_qty => l_reservation_qty
                         ,x_reservation_qty2 => l_reservation_qty2 -- INVCONV
                         );

        IF l_reservation_qty = 0 THEN
           -- no user change

          IF p_x_line_tbl(I).reserved_quantity = 0 THEN

            IF p_sch_action = OE_Schedule_Util.OESCH_ACT_RESERVE OR
               OE_SCHEDULE_UTIL.Within_Rsv_Time_Fence
               (p_x_line_tbl(I).schedule_ship_date, p_x_line_tbl(I).org_id) THEN --4689197

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'RESERVE '||P_X_LINE_TBL ( I ) .ORDERED_QUANTITY , 3 ) ;
                  oe_debug_pub.add(  'RESERVE 2 '||P_X_LINE_TBL ( I ) .ORDERED_QUANTITY2 , 3 ) ; -- INVCONV
              END IF;
              l_reservation_qty := p_x_line_tbl(I).ordered_quantity;
              l_reservation_qty2 := p_x_line_tbl(I).ordered_quantity2; -- INVCONV

            END IF;

          --Post Pack J
          -- If partial reservation falg is Yes and line have some reservation
          -- Reserve the remaining quantity.
          --ELSIF Oe_Sys_Parameters.Value('PARTIAL_RESERVATION_FLAG') = 'Y'
            ELSIF oe_schedule_util.Within_Rsv_Time_Fence(p_x_line_tbl(I).schedule_ship_date, p_x_line_tbl(I).org_id) THEN --4689197
             IF  nvl(p_x_line_tbl(I).ordered_quantity,0) > nvl(p_x_line_tbl(I).reserved_quantity,0) THEN -- INVCONV
             		l_reservation_qty := nvl(p_x_line_tbl(I).ordered_quantity,0) - nvl(p_x_line_tbl(I).reserved_quantity,0);
             END IF;
             IF  nvl(p_x_line_tbl(I).ordered_quantity2,0) > nvl(p_x_line_tbl(I).reserved_quantity2,0) THEN -- INVCONV
             		l_reservation_qty2 := nvl(p_x_line_tbl(I).ordered_quantity2,0) - nvl(p_x_line_tbl(I).reserved_quantity2,0);
             END IF;


             l_rsv_update := TRUE;
             IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'RESERVE QUANTITY'||P_X_LINE_TBL(I).RESERVED_QUANTITY , 3 ) ;
                  oe_debug_pub.add('Qunatity to reserve :'||l_reservation_qty,3);
                  oe_debug_pub.add(  'RESERVE QUANTITY2'||P_X_LINE_TBL(I).RESERVED_QUANTITY2 , 3 ) ; -- INVCONV
                  oe_debug_pub.add('Quantity to reserve :'||l_reservation_qty2,3);

              END IF;



          ELSE
            -- you do not want to overwrite previously supplied value,
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ALREADY RESERVED '||P_X_LINE_TBL ( I ) .RESERVED_QUANTITY , 3 ) ;
            END IF;
          END IF;

        -- Post Pack J
        -- Send the full order quantity for reservation if partial reservation flag is 'Yes'.
        ELSIF l_reservation_qty > 0
          --AND Oe_Sys_Parameters.Value('PARTIAL_RESERVATION_FLAG') = 'Y'
          AND oe_schedule_util.Within_Rsv_Time_Fence(p_x_line_tbl(I).schedule_ship_date, p_x_line_tbl(I).org_id) THEN --4689197
           l_reservation_qty := p_x_line_tbl(I).ordered_quantity;
           l_reservation_qty2 := p_x_line_tbl(I).ordered_quantity2; -- INVCONV
        END IF; -- reservation_aty = 0

      ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SCH LEVEL DOES NOT ALLOW RESERVATION' , 3 ) ;
        END IF;
      END IF; -- level check

      IF l_reservation_qty > 0 THEN
        p_x_line_tbl(I).reserved_quantity := l_reservation_qty;
        p_x_line_tbl(I).reserved_quantity2 := l_reservation_qty2;  -- INVCONV

        OE_SCHEDULE_UTIL.Reserve_Line
        ( p_line_rec               => p_x_line_tbl(I)
         ,p_quantity_to_Reserve    => p_x_line_tbl(I).reserved_quantity
         ,p_quantity2_to_Reserve    => p_x_line_tbl(I).reserved_quantity2 -- INVCONV
         ,p_rsv_update             => l_rsv_update
         ,x_return_status          => l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RESERVE LINE EXPECTED ERROR , IGNORE' , 1 ) ;
          END IF;
        END IF;

      END IF; -- do reserve

    END IF; -- if shippable
    I := p_x_line_tbl.NEXT(I);
  END LOOP;

  Print_Time('leaving Reserve_Group ' ||l_return_status);
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RESERVE_GROUP ERROR ' || SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Reserve_Group;


/*---------------------------------------------------------------
PROCEDURE Get_Reservations
to get the reserved quantity, if manually entered on any lines.

we will come here, only if the action is not schedule.
Thus, if user has explicitly give a reserved_quantity,
we will have an entry in the OE_Reservations_Tbl.
If an entry does not exist, the old reserved quantity in
the p_x_line_rec is nulled OUT since we do not want to reserve
a quantity whcih is already reserved.

Note that setting the x_reservation_qty to -1 is done so
that we do not perform any reservations on this line.
This will happen if the line is interfaced to shipping
and
1) ship_from_org is changed on the line
2) manually reduced the reserved qty.
---------------------------------------------------------------*/
PROCEDURE Get_Reservations
( p_line_rec         IN  OE_Order_Pub.Line_Rec_Type
 ,x_reservation_qty  OUT NOCOPY /* file.sql.39 change */ NUMBER
 ,x_reservation_qty2  OUT NOCOPY /* file.sql.39 change */ NUMBER  -- INVCONV
 )
IS
l_line_id_mod      NUMBER;  --7827737
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_RESERVATIONS ' , 3 ) ;
  END IF;
  l_line_id_mod :=MOD(p_line_rec.line_id,G_BINARY_LIMIT); --7827737

  --IF OE_Reservations_Tbl.EXISTS(p_line_rec.line_id)
  IF OE_Reservations_Tbl.EXISTS(l_line_id_mod)   --7827737
  THEN
    --x_reservation_qty := OE_Reservations_Tbl(p_line_rec.line_id).qty_to_reserve;
    --x_reservation_qty2 := OE_Reservations_Tbl(p_line_rec.line_id).qty2_to_reserve;
   x_reservation_qty := OE_Reservations_Tbl(l_line_id_mod).qty_to_reserve;--7827737
   x_reservation_qty2 := OE_Reservations_Tbl(l_line_id_mod).qty2_to_reserve;--7827737

    -- Added below IF for bug 6335352
    IF p_line_rec.ordered_quantity < x_reservation_qty THEN
      x_reservation_qty := p_line_rec.ordered_quantity;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RES VALUE '|| X_RESERVATION_QTY , 3 ) ;
    END IF;

    /* Commented the below for bug 6335352
    IF p_line_rec.shipping_interfaced_flag = 'Y' AND
       OE_Reservations_Tbl(p_line_rec.line_id).qty_to_unreserve
       is NOT NULL
    THEN
      x_reservation_qty := -1;
      x_reservation_qty2 := -1; -- INVCONV
    END IF;
    */

    --OE_Reservations_Tbl.DELETE(p_line_rec.line_id);
    OE_Reservations_Tbl.DELETE(l_line_id_mod);  --7827737
  ELSE
    x_reservation_qty := 0;
  END IF; -- if entry exists in res tbl

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  P_LINE_REC.LINE_ID || ' LEAVING..'|| X_RESERVATION_QTY , 3 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR IN GET_RESERVATIONS '|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Get_Reservations;


/*----------------------------------------------------------------
PROCEDURE Handle_Unreserve
Description:

since the query_set_lines give current reserved_qty,
we only need to give the old_ship_from in case
of ship_from_change.

Logic:

if ship_from_changed,
  set old ordered_quantity
  old_ship_from is already set.
  call unscheule_group.

if only res_qty / unreserved qty changed,
  set qty_to_res and qty_to_unres and calll res_grp/unres-grp.
  then call normal call_mrp.

should the log_attribute_changes be modified to work on
the entire group, no cascade changes is modified.

Post Process parameter has been introduced to take care of
deleting the reservation on old item if item has been changed
on a line as part of item substitution.


Unreserve_Group does not care about the ordered_quantity.
-----------------------------------------------------------------*/
PROCEDURE Handle_Unreserve
( p_x_line_tbl       IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_old_line_tbl     IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_post_process     IN  VARCHAR2 DEFAULT FND_API.G_FALSE
 ,x_return_status    OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_qty      NUMBER;
  l_qty2     NUMBER; -- INVCONV
  I          NUMBER;
  l_line_id_mod    NUMBER; --7827737
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  Print_Time('entering Handle_Unreserve');

  IF p_post_process = FND_API.G_TRUE THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING POST PROCESS' , 1 ) ;
    END IF;
    I := p_x_line_tbl.FIRST;
    WHILE I is NOT NULL
    LOOP

     IF nvl(p_x_line_tbl(I).shipping_interfaced_flag,'N') = 'N'
     AND NOT OE_GLOBALS.Equal(p_x_line_tbl(I).inventory_item_id,
                              p_old_line_tbl(I).inventory_item_id)
     AND p_old_line_tbl(I).reserved_quantity > 0 THEN

        OE_SCHEDULE_UTIL.Unreserve_Line
        (p_line_rec              => p_old_line_tbl(I),
         p_quantity_to_unreserve => p_old_line_tbl(I).reserved_quantity,
         p_quantity2_to_unreserve => p_old_line_tbl(I).reserved_quantity2, -- INVCONV
         x_return_status         => x_return_status);

     END IF;

    I := p_x_line_tbl.NEXT(I);
    END LOOP;

    RETURN;
  END IF; -- Post Process.

  IF (p_x_line_tbl(1).ship_model_complete_flag = 'Y' OR
      p_x_line_tbl(1).ship_set_id is not NULL OR
      p_x_line_tbl(1).arrival_set_id is not NULL) AND
     p_x_line_tbl(1).ship_from_org_id <> p_old_line_tbl(1).ship_from_org_id
  THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNRESERVING...' , 3 ) ;
    END IF;
    Unreserve_group
    ( p_line_tbl      => p_old_line_tbl
     ,p_sch_action    => OE_Schedule_Util.OESCH_ACT_RESCHEDULE);

    RETURN;
  END IF;


  --------- handle the ordered qty etc. change -----------------
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ORDERED QTY ETC. CHANGES ' , 1 ) ;
  END IF;

  I := p_x_line_tbl.FIRST;
  WHILE I is NOT NULL
  LOOP

    l_qty := 0;
    l_line_id_mod := MOD(p_x_line_tbl(I).line_id,G_BINARY_LIMIT); --7827737

    --IF OE_Reservations_Tbl.EXISTS(p_x_line_tbl(I).line_id) AND
     --  OE_Reservations_Tbl(p_x_line_tbl(I).line_id).qty_to_unreserve
     --  is not NULL THEN
    IF OE_Reservations_Tbl.EXISTS(l_line_id_mod) AND   --7827737
     OE_Reservations_Tbl(l_line_id_mod).qty_to_unreserve
     is not NULL THEN

      l_qty := OE_Reservations_Tbl
               (l_line_id_mod).qty_to_unreserve; --7827737
               --(p_x_line_tbl(I).line_id).qty_to_unreserve;
      l_qty2 := OE_Reservations_Tbl -- INVCONV
                (l_line_id_mod).qty2_to_unreserve;  --7827737
               --(p_x_line_tbl(I).line_id).qty2_to_unreserve;


      --OE_Reservations_Tbl.DELETE(p_x_line_tbl(I).line_id);
    ELSIF p_x_line_tbl(I).ordered_quantity<p_x_line_tbl(I).reserved_quantity
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ELSIF CHANGE'|| P_X_LINE_TBL ( I ) .LINE_ID , 3 ) ;
      END IF;

      l_qty := p_x_line_tbl(I).reserved_quantity -
               p_x_line_tbl(I).ordered_quantity;
			l_qty2 := p_x_line_tbl(I).reserved_quantity2 -    -- INVCONV
               p_x_line_tbl(I).ordered_quantity2;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  L_QTY||' UNRESERVE '||P_X_LINE_TBL ( I ) .LINE_ID , 3 ) ;
        oe_debug_pub.add(  L_QTY2||' UNRESERVE 2'||P_X_LINE_TBL ( I ) .LINE_ID , 3 ) ;
    END IF;

    IF l_qty > 0 THEN
      OE_SCHEDULE_UTIL.Unreserve_Line
      ( p_line_rec               => p_x_line_tbl(I)
       ,p_old_ship_from_org_id   => p_old_line_tbl(I).ship_from_org_id --6628134
       ,p_quantity_to_unreserve  => l_qty
       ,p_quantity2_to_unreserve  => l_qty2 -- INVCONV
       ,x_return_status          => x_return_status);
    END IF;

    I := p_x_line_tbl.NEXT(I);
  END LOOP;

  Print_Time('leaving Handle_Unreserve');
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HANDLE_UNRESERVE ERROR' || SQLERRM , 1 ) ;
    END IF;
    RAISE;

END Handle_Unreserve;


/*-----------------------------------------------------------
PROCEDURE Validate_And_Assign_Sch_Params

Do I need to check caller to not do the ship_set assignment
for nonsmc? what if I assing line's own line_id.
Changes have been made as part of override atp project to
cascade override flag from model/class and kits to its included
items. Changes are also made to cascade override flag on ato model.
------------------------------------------------------------*/
PROCEDURE Validate_And_Assign_Sch_Params
( p_request_rec      IN OE_Order_Pub.Request_Rec_Type
 ,p_x_line_rec       IN OUT NOCOPY OE_Order_Pub.Line_Rec_Type
 ,p_x_old_line_rec   IN OUT NOCOPY OE_Order_Pub.Line_Rec_Type)
IS
  l_return_status  VARCHAR2(1);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '--------ENTERING VALIDATE_AND_ASSIGN' , 1 ) ;
  END IF;

/* 3533565 Validation will be done after cascading
  OE_Schedule_Util.Validate_Line
  ( p_line_rec      => p_x_line_rec
   ,p_old_line_rec  => p_x_old_line_rec
   ,p_sch_action    => p_request_rec.param1
   ,x_return_status => l_return_status);


  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
*/
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '-------ENTITY ' || P_REQUEST_REC.ENTITY_ID , 4 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '-------LINE ' || P_X_LINE_REC.LINE_ID , 4 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '-------ACTION ' || P_REQUEST_REC.PARAM1 , 4 ) ;
  END IF;

  p_x_line_rec.operation             := OE_GLOBALS.G_OPR_UPDATE;
  p_x_line_rec.change_reason         := 'SYSTEM';
  p_x_line_rec.change_comments       := 'Scheduling Action';
  p_x_line_rec.schedule_action_code  := p_request_rec.param1;
  p_x_line_rec.ship_from_org_id      := p_request_rec.param3;
  p_x_line_rec.ship_to_org_id        := p_request_rec.param4;

  --IF condition added for Bug 3524944
  IF p_x_line_rec.open_flag = 'Y' THEN
     p_x_line_rec.shipping_method_code  := p_request_rec.param5;
  END IF;

  p_x_line_rec.demand_class_code     := p_request_rec.param6;
  p_x_line_rec.request_date          := p_request_rec.date_param1;
  p_x_line_rec.schedule_ship_date    := p_request_rec.date_param2;
  p_x_line_rec.schedule_arrival_date := p_request_rec.date_param3;

  -- 3533565
  OE_Schedule_Util.Validate_Line
  ( p_line_rec      => p_x_line_rec
   ,p_old_line_rec  => p_x_old_line_rec
   ,p_sch_action    => p_request_rec.param1
   ,x_return_status => l_return_status);


  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_request_rec.request_type <> OE_GLOBALS.G_SCHEDULE_NONSMC
  AND NOT (p_request_rec.request_type = OE_GLOBALS.G_SCHEDULE_ATO
  AND      OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
  AND      MSC_ATP_GLOBAL.GET_APS_VERSION = 10 )

  THEN
    p_x_line_rec.ship_set            := p_request_rec.entity_id;
  END IF;

  -- 4052648: Assign old values for ato model for unschedule action
  IF p_request_rec.param1 = OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE
  OR (p_request_rec.param1 = OE_SCHEDULE_UTIL.OESCH_ACT_UNSCHEDULE
     AND p_x_line_rec.ato_line_id IS NOT NULL)
     -- bug 2427280 AND p_x_old_line_rec.schedule_status_code is NOT NULL
  THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ASSIGN OLD VALUES '|| P_REQUEST_REC.PARAM7 , 3 ) ;
    END IF;
    p_x_old_line_rec.ship_from_org_id      := p_request_rec.param7;
    p_x_old_line_rec.demand_class_code     := p_request_rec.param8;
    p_x_old_line_rec.request_date          := p_request_rec.date_param4;
    p_x_old_line_rec.schedule_ship_date    := p_request_rec.date_param5;
    p_x_old_line_rec.schedule_arrival_date := p_request_rec.date_param6;
    --4052648
    p_x_old_line_rec.ship_to_org_id        := p_request_rec.param14;
    p_x_old_line_rec.shipping_method_code  := p_request_rec.param15;
    p_x_old_line_rec.planning_priority     := p_request_rec.param16;
    p_x_old_line_rec.delivery_lead_time    := p_request_rec.param17;
  END IF;

  -- BUG 1282873
  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ASSIGN OVERRIDE FLAG' , 3 ) ;
     END IF;
     IF  (p_x_line_rec.ato_line_id is not null AND
     NOT (p_x_line_rec.ato_line_id = p_x_line_rec.line_id AND
          p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION)) THEN

      IF  p_x_line_rec.ship_model_complete_flag = 'Y'
      AND nvl(p_x_line_rec.override_atp_date_code,'N') = 'N'   THEN

          BEGIN


            Select override_atp_date_code
            Into   p_x_line_rec.override_atp_date_code
            From   oe_order_lines_all
            Where  header_id = p_x_line_rec.header_id
            And    ato_line_id = p_x_line_rec.ato_line_id
            And    override_atp_date_code = 'Y'
            AND    rownum < 2;

          EXCEPTION
            WHEN OTHERS THEN
             Null;

          END;
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'OVERRIDE_ATP_DATE_CODE :' || P_X_LINE_REC.OVERRIDE_ATP_DATE_CODE || P_X_LINE_REC.LINE_ID , 3 ) ;
                      END IF;

      ELSIF NVL(p_request_rec.param11,'N') = 'Y' THEN

         p_x_line_rec.override_atp_date_code := p_request_rec.param11;

      END IF;

     ELSIF p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_INCLUDED THEN


    -- 2722692
--      IF p_x_line_rec.ship_model_complete_flag = 'Y'
      IF nvl(p_x_line_rec.override_atp_date_code,'N') = 'N' THEN

        BEGIN


         Select override_atp_date_code
         Into   p_x_line_rec.override_atp_date_code
         From   oe_order_lines_all
         Where  header_id = p_x_line_rec.header_id
         And    line_id = p_x_line_rec.link_to_line_id;

        EXCEPTION
         WHEN OTHERS THEN
             Null;

        END;

                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  '2 OVERRIDE_ATP_DATE_CODE :' || P_X_LINE_REC.OVERRIDE_ATP_DATE_CODE , 3 ) ;
                      END IF;

      ELSIF p_x_line_rec.link_to_line_id = p_request_rec.entity_id
      AND   nvl(p_request_rec.param11,'N') = 'Y'  THEN

         p_x_line_rec.override_atp_date_code := p_request_rec.param11;

      END IF;
     END IF;

  END IF;  -- Check for Pack I
  -- END 1282873

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING VALIDATE_AND_ASSIGN_SCH_PARAMS' , 3 ) ;
  END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ERROR VALIDATE_AND_ASSIGN_SCH_PARAMS '|| SQLERRM , 1 ) ;
   END IF;
   RAISE;
END Validate_And_Assign_Sch_Params;


/*----------------------------------------------------------
PROCEDURE Save_Sch_Attributes
Call lines only for those lines where there is
a change.

many of the lines could be sent to mrp because they are part of
a group, but not all of them will have a change in sch attribs.
ex: line added to a scheduled smc, only that line should
be passed to process_order if all other lines have same
dates and sch attribs after call to mrp.

call security if the line has change.
call defaulting to see if we need to call process_order.
if we do not need, set the operation to NONE and do a direct
update.
-----------------------------------------------------------*/
PROCEDURE Save_Sch_Attributes
( p_x_line_tbl    IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_old_line_tbl  IN  OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 ,p_sch_action    IN  VARCHAR2
 ,p_caller        IN  VARCHAR2
 ,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  I                   NUMBER;
  l_line_id           VARCHAR2(1);
  l_call_po           VARCHAR2(1) := 'N';
  l_direct_update     VARCHAR2(1) := 'N';
  l_process_requests  BOOLEAN;
  l_redo_security_check VARCHAR2(1) := 'N';
  l_control_rec       OE_GLOBALS.control_rec_type;
  l_orig_old_line_rec OE_Order_PUB.Line_Rec_Type; --3144917

  l_po_NeedByDate_Update   VARCHAR2(10); -- Added for IR ISO CMS project
  l_return_status          VARCHAR2(1); -- Added for IR ISO CMS project

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING SAVE_SCH '|| P_X_LINE_TBL.COUNT , 1 ) ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

 /*Initiliazed the x_return_status for bug 7555835. Since x_return_status is not initialized
  in the begining of the API,In certain flows, like when only schedule ship date is changed,
   it is not getting initialized at all. Due to this, this API is returning return status as null.
  So the caller is erroring out, as ther processing is checked based on the return status. */

  I := p_x_line_tbl.FIRST;
  WHILE I is NOT NULL
  LOOP

    IF p_x_line_tbl(I).operation = OE_GLOBALS.G_OPR_NONE THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OPERATION IS NONE '|| P_X_LINE_TBL ( I ) .LINE_ID , 3 ) ;
      END IF;
      goto end_of_loop;
    END IF;

    p_x_line_tbl(I).ship_set      := null;
    p_old_line_tbl(I).ship_set    := null; -- 3878491

    --Added the below IF condition for bug 4587506
    --Added IS_MASS_CHANGE condition for bug 4911340
    IF NOT OE_GLOBALS.G_UI_FLAG AND OE_MASS_CHANGE_PVT.IS_MASS_CHANGE = 'F' THEN
      p_x_line_tbl(I).change_reason := 'SYSTEM';
    END IF;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'GET THE OLD DATA' , 3 ) ;
    END IF;

    l_orig_old_line_rec :=  p_old_line_tbl(I) ;  --3144917

/* Commented the following sql as in case of group
   scheduling dates would have already been updated on line
   but reservations need to be called. Bug 2801597 */

  /*Uncommented the sql for Bug 3144917 */

    -- 4052648 : Do not query for action - UNSCHEDULE
    IF p_sch_action <> OE_SCHEDULE_UTIL.OESCH_ACT_UNSCHEDULE THEN

       SELECT request_date, schedule_ship_date,
              schedule_arrival_date,
              ship_from_org_id, ship_to_org_id,
              shipping_method_code, demand_class_code,
              planning_priority, delivery_lead_time
       INTO   p_old_line_tbl(I).request_date,
              p_old_line_tbl(I).schedule_ship_date,
              p_old_line_tbl(I).schedule_arrival_date,
              p_old_line_tbl(I).ship_from_org_id,
              p_old_line_tbl(I).ship_to_org_id,
              p_old_line_tbl(I).shipping_method_code,
              p_old_line_tbl(I).demand_class_code,
              p_old_line_tbl(I).planning_priority,
              p_old_line_tbl(I).delivery_lead_time
       FROM   oe_order_lines
       WHERE  line_id = p_x_line_tbl(I).line_id;

    END IF;-- 4052648

    IF p_x_line_tbl(I).open_flag = 'N' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE IS CLOSED '||P_X_LINE_TBL ( I ) .LINE_ID , 3 ) ;
      END IF;
      p_x_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_X_LINE_TBL ( I ) .SHIPPING_METHOD_CODE , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_OLD_LINE_TBL ( I ) .SHIPPING_METHOD_CODE , 3 ) ;
    END IF;
      goto direct_update;
    END IF;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_X_LINE_TBL ( I ) .REQUEST_DATE , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_OLD_LINE_TBL ( I ) .REQUEST_DATE , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_X_LINE_TBL ( I ) .SCHEDULE_SHIP_DATE , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_OLD_LINE_TBL ( I ) .SCHEDULE_SHIP_DATE , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_X_LINE_TBL ( I ) .SCHEDULE_ARRIVAL_DATE , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_OLD_LINE_TBL ( I ) .SCHEDULE_ARRIVAL_DATE , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_X_LINE_TBL ( I ) .SHIP_FROM_ORG_ID , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_OLD_LINE_TBL ( I ) .SHIP_FROM_ORG_ID , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_X_LINE_TBL ( I ) .SHIP_TO_ORG_ID , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_OLD_LINE_TBL ( I ) .SHIP_TO_ORG_ID , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_X_LINE_TBL ( I ) .SHIPPING_METHOD_CODE , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_OLD_LINE_TBL ( I ) .SHIPPING_METHOD_CODE , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_X_LINE_TBL ( I ) .DEMAND_CLASS_CODE , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_OLD_LINE_TBL ( I ) .DEMAND_CLASS_CODE , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(P_X_LINE_TBL( I ).Earliest_Ship_Date , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(P_X_LINE_TBL( I ).Firm_Demand_Flag , 3 ) ;
    END IF;


    IF p_sch_action = OE_Schedule_Util.OESCH_ACT_RESCHEDULE THEN
      IF NOT OE_GLOBALS.Equal(p_x_line_tbl(I).request_date,
                              p_old_line_tbl(I).request_date) OR

         NOT OE_GLOBALS.Equal(p_x_line_tbl(I).schedule_ship_date,
                              p_old_line_tbl(I).schedule_ship_date) OR

         NOT OE_GLOBALS.Equal(p_x_line_tbl(I).schedule_arrival_date,
                              p_old_line_tbl(I).schedule_arrival_date) OR

         NOT OE_GLOBALS.Equal(p_x_line_tbl(I).ship_from_org_id,
                              p_old_line_tbl(I).ship_from_org_id) OR

         NOT OE_GLOBALS.Equal(p_x_line_tbl(I).ship_to_org_id,
                              p_old_line_tbl(I).ship_to_org_id) OR

         NOT OE_GLOBALS.Equal(p_x_line_tbl(I).shipping_method_code,
                        p_old_line_tbl(I).shipping_method_code) OR

         NOT OE_GLOBALS.Equal(p_x_line_tbl(I).demand_class_code,
                        p_old_line_tbl(I).demand_class_code) OR

         NOT OE_GLOBALS.Equal(p_x_line_tbl(I).planning_priority,
                        p_old_line_tbl(I).planning_priority) OR

         NOT OE_GLOBALS.Equal(p_x_line_tbl(I).delivery_lead_time,
                        p_old_line_tbl(I).delivery_lead_time) OR

         NOT OE_GLOBALS.Equal(p_x_line_tbl(I).inventory_item_id,
                        p_old_line_tbl(I).inventory_item_id)
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'THERE IS A CHANGE '|| P_X_LINE_TBL ( I ) .LINE_ID , 3 ) ;
        END IF;
      ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NO CHANGE '|| P_X_LINE_TBL ( I ) .LINE_ID , 3 ) ;
        END IF;
        p_x_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
        goto direct_update;
      END IF;
    END IF; -- end if reschedule


    ------------- do security and defaulting -------------

    Call_Security_And_Defaulting
    (p_x_line_rec    => p_x_line_tbl(I)
    ,p_old_line_rec  => p_old_line_tbl(I)
    ,x_direct_update => l_direct_update);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add( 'operation action ' || oe_line_security.g_operation_action  , 1 ) ;
    END IF;

    IF oe_line_security.g_operation_action is not null THEN
       l_call_po := 'Y';
       l_direct_update := 'N';
       l_redo_security_check := 'Y';
    END IF;

    IF l_direct_update = 'Y' THEN
      p_x_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
    END IF;

    <<direct_update>>
    IF p_x_line_tbl(I).operation = OE_GLOBALS.G_OPR_NONE THEN
      Handle_Direct_Update
      ( p_x_line_rec    => p_x_line_tbl(I)
       ,p_old_line_rec  => p_old_line_tbl(I)
       ,p_caller        => p_caller);

      IF p_x_line_tbl(I).top_model_line_id = p_x_line_tbl(I).line_id
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CLEAR MODEL CACHE: '||P_X_LINE_TBL ( I ) .LINE_ID , 1 ) ;
        END IF;
        OE_Order_Cache.Clear_Top_Model_Line
        (p_key => p_x_line_tbl(I).line_id);
      END IF;
    ELSE
      l_call_po := 'Y';
    END IF;


    IF p_sch_action = OE_Schedule_Util.OESCH_ACT_RESCHEDULE THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'MAY UPDATE RESERN '|| P_X_LINE_TBL ( I ) .LINE_ID , 3 ) ;
      END IF;
      Update_Reservation
     ( p_line_rec      => p_x_line_tbl(I)
      ,p_old_line_rec  => l_orig_old_line_rec --3144917
      ,x_return_status => x_return_status);

    END IF;

    <<end_of_loop>>

/* Loop Back*/
    IF nvl(p_x_line_tbl(I).open_flag,'Y') = 'Y' AND
     p_x_line_tbl(I).source_document_type_id = 10        AND
     NOT OE_GLOBALS.EQUAL(p_x_line_tbl(I).schedule_arrival_date,
                          p_old_line_tbl(I).schedule_arrival_date)

    THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PASSING SCHEDULE_ARRIVAL_DATE TO PO ' , 3 ) ;
      END IF;

-- Bug ##7576948: For IR ISO CMS Project
-- The below code is commented for IR ISO project because we no more
-- required to call PO_Supply.PO_Req_Supply API to just update the
-- MTL_Supply record for the corresponding internal requisition line
-- We now be calling PO_RCO_Validation_GRP.Update_ReqChange_from_SO
-- Purchasing product new API to update both the internal requisition
-- line and the MTL_Supply. This will be achieved via the logging of
-- a new delayed request of type OE_Globals.G_UPDATE_REQUISITION, which
-- is added as part of this project
--
/*
      OE_SCHEDULE_UTIL.Update_PO(p_x_line_tbl(I).schedule_arrival_date,
                p_x_line_tbl(I).source_document_id,
                p_x_line_tbl(I).source_document_line_id);
*/
--
-- This delayed request will be logged only if global OE_Internal_Requisi
-- tion_Pvt.G_Update_ISO_From_Req set to FALSE. If this global is TRUE
-- then it means, the change requests for quantity/date or cancellation
-- request is initiated by internal requisition user, in which case, it is
-- not required to log the delayed request for updating the change to the
-- requesting organization. System will also check that global OE_SALES_CAN
-- _UTIL.G_IR_ISO_HDR_CANCEL, and will log a delayed request only if it is
-- FALSE. If this global is TRUE then signifies that it is a case of full
-- internal sales order header cancellation. Thus, in the event of full
-- order cancellation, we only need to inform Purchasing about the
-- cancellation. There is no need to provide specific line level information.
-- Additionally, while logging a delayed request specific to Schedule Arrival
-- Date change, system will ensure that it should be allowed via Purchasing
-- profile 'POR: Sync Up Need By date on IR with OM'.
--
-- Moreover, it should be noted that if the current procedure is triggered
-- for the changes initiated from Planning Workbench or DRP in ASCP, then
-- the two globals G_Update_ISO_From_Req and G_IR_ISO_HDR_CANCEL should be
-- FALSE
--
-- While logging the delayed request, we will log it for Order Header or
-- Order Line entity, while Entity id will be the Header_id or Line_id
-- respectively. In addition to this, we will even pass Unique_Params value
-- to make this request very specific to Requisition Header or Requisition
-- Line.
--
-- Please refer to following delayed request params with their meaning
-- useful while logging the delayed request -
--
-- P_entity_code        Entity for which delayed request has to be logged.
--                      In this project it can be OE_Globals.G_Entity_Line
--                      or OE_Globals.G_Entity_Header
-- P_entity_id          Primary key of the entity record. In this project,
--                      it can be Order Line_id or Header_id
-- P_requesting_entity_code Which entity has requested this delayed request to
--                          be logged! In this project it will be OE_Globals.
--                          G_Entity_Line or OE_Globals.G_Entity_Header
-- P_requesting_entity_id       Primary key of the requesting entity. In this
--                              project, it is Line_id or Header_id
-- P_request_type       Indicates which business logic (or which procedure)
--                      should be executed. In this project, it is OE_Global
--                      s.G_UPDATE_REQUISITION
-- P_request_unique_key1        Additional argument in form of parameters.
--                              In this project, it will denote the Sales Order
--                              Header id
-- P_request_unique_key2        Additional argument in form of parameters.
--                              In this project, it will denote the Requisition
--                              Header id
-- P_request_unique_key3        Additional argument in form of parameters. In
--                              this project, it will denote the Requistion Line
--                              id
-- P_param1     Additional argument in form of parameters. In this project, it
--              will denote net change in order quantity with respective single
--              requisition line. If it is greater than 0 then it is an increment
--              in the quantity, while if it is less than 0 then it is a decrement
--              in the ordered quantity. If it is 0 then it indicates there is no
--              change in ordered quantity value
-- P_param2     Additional argument in form of parameters. In this project, it
--              will denote whether internal sales order is cancelled or not. If
--              it is cancelled then respective Purchasing api will be called to
--              trigger the requisition header cancellation. It accepts a value of
--              Y indicating requisition header has to be cancelled.
-- P_param3     Additional argument in form of parameters. In this project, it
--              will denote the number of sales order lines cancelled while order
--              header is (Full/Partial) cancelled.
-- p_date_param1        Additional date argument in form of parameters. In this
--                      project, it will denote the change in Schedule Ship/Arrival Date
--                      with to respect to single requisition line.
-- P_Long_param1        Additional argument in form of parameters. In this project,
--                      it will store all the sales order line_ids, which are getting
--                      cancelled while order header gets cancelled (Full/Partial).
--                      These Line_ids will be separated by a delimiter comma ','
--
-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc
--

      l_po_NeedByDate_Update := NVL(FND_PROFILE.VALUE('POR_SYNC_NEEDBYDATE_OM'),'NO');

      IF l_debug_level > 0 THEN
        oe_debug_pub.add(' Need By Date update is allowed ? '||l_po_NeedByDate_Update);
      END IF;

      IF NOT OE_Internal_Requisition_Pvt.G_Update_ISO_From_Req
         AND NOT OE_SALES_CAN_UTIL.G_IR_ISO_HDR_CANCEL THEN -- AND
        -- l_po_NeedByDate_Update = 'YES' THEN
        IF l_po_NeedByDate_Update = 'YES' THEN -- IR ISO Tracking bug 7667702

        -- Log a delayed request to update the change in Schedule Arrival Date to
        -- Requisition Line. This request will be logged only if the change is
        -- not initiated from Requesting Organization, and it is not a case of
        -- Internal Sales Order Full Cancellation. It will even not be logged
        -- Purchasing profile option does not allow update of Need By Date when
        -- Schedule Ship Date changes on internal sales order line

        OE_delayed_requests_Pvt.log_request
         ( p_entity_code            => OE_GLOBALS.G_ENTITY_LINE
         , p_entity_id              => p_x_line_tbl(I).line_id
         , p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE
         , p_requesting_entity_id   => p_x_line_tbl(I).line_id
         , p_request_unique_key1    => p_x_line_tbl(I).header_id  -- Order Hdr_id
         , p_request_unique_key2    => p_x_line_tbl(I).source_document_id -- Req Hdr_id
         , p_request_unique_key3    => p_x_line_tbl(I).source_document_line_id -- Req Line_id
         , p_date_param1            => p_x_line_tbl(I).schedule_arrival_date
         , p_request_type           => OE_GLOBALS.G_UPDATE_REQUISITION
         , x_return_status          => l_return_status
         );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;


        ELSE -- Added for IR ISO Tracking bug 7667702
          IF l_debug_level > 0 THEN
            oe_debug_pub.add(' Need By Date is not allowed to update. Updating MTL_Supply only',5);
          END IF;

          OE_SCHEDULE_UTIL.Update_PO(p_x_line_tbl(I).schedule_arrival_date,
                p_x_line_tbl(I).source_document_id,
                p_x_line_tbl(I).source_document_line_id);
        END IF;

      END IF;

/* ============================= */
/* IR ISO Change Management Ends */

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER PO CALL BACK' , 3 ) ;
      END IF;
    END IF;

    I := p_x_line_tbl.NEXT(I);

  END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '------- DONE WITH DIRECT UPDATES IF ANY' , 1 ) ;
  END IF;

  ------------------- call process order -------------------

  IF l_call_po = 'Y' THEN

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.default_attributes   := TRUE;
    IF l_redo_security_check = 'N' THEN
     l_control_rec.check_security       := FALSE;
    ELSE
     l_control_rec.check_security       := TRUE;
    END IF;

    l_control_rec.write_to_DB          := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    OE_Schedule_Util.Call_Process_Order
    ( p_x_old_line_tbl  => p_old_line_tbl
     ,p_x_line_tbl      => p_x_line_tbl
     ,p_control_rec     => l_control_rec
     ,p_caller          => p_caller
     ,x_return_status   => x_return_status);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_caller = OE_Schedule_Util.SCH_INTERNAL THEN
      l_process_requests := FALSE;
    ELSE
      l_process_requests := TRUE;
    END IF;

    OE_Order_PVT.Process_Requests_And_Notify
    ( p_process_requests        => l_process_requests
     ,p_notify                  => TRUE
     ,p_line_tbl                => p_x_line_tbl
     ,p_old_line_tbl            => p_old_line_tbl
     ,x_return_status           => x_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PRN RETURN_STATUS ' || X_RETURN_STATUS , 1 ) ;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING SAVE_SCH_ATTRIBURES' , 1 ) ;
  END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ERROR SAVE_SCH_ATTRIBUTES '|| SQLERRM , 1 ) ;
   END IF;
   RAISE;
END Save_Sch_Attributes;


/*-----------------------------------------------------------
PROCEDURE Call_Security_And_Defaulting

This procedure is used to call security and defaulting
and to decide if we need to make a process_order call
for the scheduling attributes or not.
------------------------------------------------------------*/
PROCEDURE Call_Security_And_Defaulting
( p_x_line_rec    IN  OUT NOCOPY OE_ORDER_PUB.line_rec_type
 ,p_old_line_rec  IN  OE_ORDER_PUB.line_rec_type
 ,x_direct_update OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_sec_result            NUMBER;
  l_src_attr_tbl          OE_GLOBALS.NUMBER_Tbl_Type;
  l_return_status         VARCHAR2(1);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING SECURITY_AND_DEFAULTING ' , 2 ) ;
  END IF;

  x_direct_update := 'N';

  OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
  OE_Line_Security.Attributes
  ( p_line_rec        => p_x_line_rec
   ,p_old_line_rec    => p_old_line_rec
   ,x_result          => l_sec_result
   ,x_return_status   => l_return_status );

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER SECURITY CALL' || L_RETURN_STATUS , 1 ) ;
  END IF;

  -- if operation on any attribute is constrained
  IF l_sec_result = OE_PC_GLOBALS.YES THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CONSTRAINT FOUND' , 4 ) ;
     END IF;
     RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_from_org_id,
                          p_old_line_rec.ship_from_org_id) OR
     NOT OE_GLOBALS.Equal(p_x_line_rec.ship_to_org_id,
                          p_old_line_rec.ship_to_org_id) OR
     NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,
                          p_old_line_rec.inventory_item_id)

  THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP FROM/TO/ITEM CHANGED ON LINE CALL PO' , 1 ) ;
    END IF;
  ELSE
    OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'N';

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OLD SHIP :' || P_OLD_LINE_REC.SCHEDULE_SHIP_DATE , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NEW SHIP :' || P_X_LINE_REC.SCHEDULE_SHIP_DATE , 1 ) ;
    END IF;
    --8706868
    IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_ship_date,
                            p_old_line_rec.schedule_ship_date)
       OR NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_arrival_date,
                            p_old_line_rec.schedule_arrival_date)

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
          oe_debug_pub.add(  'DEFAULT ' || OE_GLOBALS.G_ATTR_UPDATED_BY_DEF , 1 ) ;
      END IF;

      IF OE_GLOBALS.G_ATTR_UPDATED_BY_DEF = 'N' THEN
        x_direct_update := 'Y';
      END IF;

    END IF;
  END IF; -- ship from/ship to change

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '------LEAVING SECURITY/DEF '|| X_DIRECT_UPDATE , 1 ) ;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALL_SECURITY_AND_DEFAULTING '|| SQLERRM , 1 ) ;
    END IF;
    OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
    RAISE;
END Call_Security_And_Defaulting;


/*-------------------------------------------------------------------
PROCEDURE Handle_Direct_Update
--------------------------------------------------------------------*/
PROCEDURE Handle_Direct_Update
( p_x_line_rec    IN  OUT NOCOPY OE_ORDER_PUB.line_rec_type
 ,p_old_line_rec  IN  OE_ORDER_PUB.line_rec_type
 ,p_caller        IN  VARCHAR2)
IS
  l_order_type_id   NUMBER := OE_Order_Cache.g_header_rec.order_type_id;
  l_return_status   VARCHAR2(1);
  l_index            NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING HANDLE_DIRECT_UPDATE' , 1 ) ;
  END IF;

  OE_MSG_PUB.set_msg_context
  ( p_entity_code                => 'LINE'
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
  ( p_x_line_rec    => p_x_line_rec
   ,p_old_line_rec  => p_old_line_rec
   ,p_caller        => p_caller
   ,p_order_type_id => l_order_type_id
   ,x_return_status => l_return_status);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'AFTER LOG_SCHEDULING REQS' || L_RETURN_STATUS , 1 ) ;
   END IF;

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE DOING DIRECT UPDATE' , 1 ) ;
   END IF;

   IF NOT OE_SCHEDULE_UTIL.validate_ship_method
               (p_x_line_rec.shipping_method_code,
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

   -- Pack J -Promise Date added to reflect changes
   UPDATE OE_ORDER_LINES
   SET ship_from_org_id           = p_x_line_rec.ship_from_org_id
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
      ,Firm_Demand_Flag           = p_x_line_rec.Firm_Demand_Flag
      ,earliest_ship_date         = p_x_line_rec.Earliest_ship_date
      ,promise_date               = p_x_line_rec.promise_date
      ,last_update_date           = SYSDATE
      ,last_updated_by            = FND_GLOBAL.USER_ID
      ,last_update_login          = FND_GLOBAL.LOGIN_ID
      ,lock_control               = p_x_line_rec.lock_control + 1
   WHERE LINE_ID = p_x_line_rec.line_id;   -- 2806483 Added fright_carrier_code
   --2792869
   -- added for notification framework
   --check code release level first. Notification framework is at Pack H level

   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN

      -- calling notification framework to get index position
      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                    p_old_line_rec => p_old_line_rec,
                    p_line_rec =>p_x_line_rec,
                    p_line_id => p_x_line_rec.line_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_SCHEDULE_UTIL.PROCESS_LINE IS: ' || L_RETURN_STATUS ) ;
         oe_debug_pub.add(  'GLOBAL PICTURE INDEX IS: ' || L_INDEX , 1 ) ;
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
     END IF;  /*code_release_level*/

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'LEAVING HANDLE DIRECT UPDATE' , 1 ) ;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HANDLE_DIRECT_UPDATE ERROR '|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Handle_Direct_Update;


/*---------------------------------------------------------------
PROCEDURE Update_Reservation
This procedure should be used to update the reservation record
with new schedule ship date, after a call to RESCHEDULE.
---------------------------------------------------------------*/

PROCEDURE Update_Reservation
( p_line_rec      IN  OE_Order_Pub.Line_Rec_Type
 ,p_old_line_rec  IN  OE_Order_Pub.Line_Rec_Type
 ,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_rsv_rec          inv_reservation_global.mtl_reservation_rec_type;
  l_rsv_tbl          inv_reservation_global.mtl_reservation_tbl_type;
  l_dummy_sn         inv_reservation_global.serial_number_tbl_type;
  l_sales_order_id   NUMBER;
  l_lock_records     VARCHAR2(1);
  l_sort_by_req_date NUMBER;
  l_buffer           VARCHAR2(2000);
  l_msg_data         VARCHAR2(2000);
  l_msg_count        NUMBER;
  l_error_code       NUMBER;
  l_count            NUMBER;
  I                  NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  Print_Time('entering Update_Reservation');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF OE_GLOBALS.Equal(p_line_rec.schedule_ship_date,
                      p_old_line_rec.schedule_ship_date) OR
     p_line_rec.schedule_ship_date IS NULL OR -- bug 3542464
     p_line_rec.reserved_quantity <= 0 OR
     p_line_rec.ordered_quantity = 0
  THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NO NEED TO UPDATE OR NO RESERVN' , 3 ) ;
    END IF;
    RETURN;
  END IF;

  l_rsv_rec.reservation_id := fnd_api.g_miss_num;

  l_sales_order_id  := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id
                      (p_line_rec.header_id);

  l_rsv_rec.demand_source_header_id := l_sales_order_id;
  l_rsv_rec.demand_source_line_id   := p_line_rec.line_id;
  l_rsv_rec.organization_id         := p_line_rec.ship_from_org_id;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RSCH: CALLING INVS QUERY_RESERVATION ' , 1 ) ;
  END IF;

  Inv_Reservation_Pub.Query_Reservation
  ( p_api_version_number        => 1.0
  , p_init_msg_lst              => fnd_api.g_true
  , x_return_status             => x_return_status
  , x_msg_count                 => l_msg_count
  , x_msg_data                  => l_msg_data
  , p_query_input               => l_rsv_rec
  , x_mtl_reservation_tbl       => l_rsv_tbl
  , x_mtl_reservation_tbl_count => l_count
  , x_error_code                => l_error_code
  , p_lock_records              => l_lock_records
  , p_sort_by_req_date          => l_sort_by_req_date );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER INVS QUERY_RESERVATION: ' || X_RETURN_STATUS , 1 ) ;
  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RESERVATION REC COUNT: ' || L_RSV_TBL.COUNT , 1 ) ;
  END IF;

  I := l_rsv_tbl.FIRST;
  WHILE I is not NULL
  LOOP

    l_rsv_rec := l_rsv_tbl(I);
    l_rsv_rec.requirement_date := p_line_rec.schedule_ship_date;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RSCH: CALLING UPDATE RESERVATION '|| I , 1 ) ;
    END IF;

    Inv_Reservation_Pub.Update_Reservation
    ( p_api_version_number        => 1.0
    , p_init_msg_lst              => fnd_api.g_true
    , x_return_status             => x_return_status
    , x_msg_count                 => l_msg_count
    , x_msg_data                  => l_msg_data
    , p_original_rsv_rec          => l_rsv_tbl(I)
    , p_to_rsv_rec                => l_rsv_rec
    , p_original_serial_number    => l_dummy_sn -- no serial contorl
    , p_to_serial_number          => l_dummy_sn -- no serial control
    , p_validation_flag           => fnd_api.g_true
    , p_over_reservation_flag     => 2 ); -- Added this for 4715544

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER UPDATE_RESERVATION: '||X_RETURN_STATUS , 1 ) ;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      IF l_msg_data is not null THEN

        OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => p_line_rec.line_id
         ,p_header_id                   => p_line_rec.header_id
         ,p_line_id                     => p_line_rec.line_id
         ,p_orig_sys_document_ref       => p_line_rec.orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => p_line_rec.orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => p_line_rec.orig_sys_shipment_ref
         ,p_change_sequence             => p_line_rec.change_sequence
         ,p_source_document_id          => p_line_rec.source_document_id
         ,p_source_document_line_id     => p_line_rec.source_document_line_id
         ,p_order_source_id             => p_line_rec.order_source_id
         ,p_source_document_type_id     => p_line_rec.source_document_type_id);

        fnd_message.set_encoded(l_msg_data);
        l_buffer := fnd_message.get;
        oe_msg_pub.add_text(p_message_text => l_buffer);
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ERROR : '|| L_BUFFER , 1 ) ;
        END IF;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    I := l_rsv_tbl.NEXT(I);
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_RESERVATION ERROR '|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Update_Reservation;


/*---------------------------------------------------------------
Procedure : Query_Set_Lines
Description:
  This procedure will query the lines belonging to the group
  identified by the i/p **_id parameter.
  It will create the included items, if they are not already
  exploded. will obtain and set the reserved quantity of the
  included items.

Note: The order of if, elsif is importatnt, we want to give
priority of the query as follows:
  1.Arrival_Set
  2.Ship_Set
  3.Model

Right now, I am not making the cursor parameterized, because
even if all 3 parameters are passed, the cursor is going to
result in correct selection, ex: if model_line_id and ship_set_id
both are set, all lines selected by 1st part are subset of lines
selected by 2nd part.
---------------------------------------------------------------*/
Procedure Query_Set_Lines
(p_header_id         IN NUMBER,
 p_ship_set_id       IN NUMBER  := FND_API.G_MISS_NUM,
 p_arrival_set_id    IN NUMBER  := FND_API.G_MISS_NUM,
 p_model_line_id     IN NUMBER  := FND_API.G_MISS_NUM,
 p_link_to_line_id   IN NUMBER  := FND_API.G_MISS_NUM,
 p_sch_action        IN VARCHAR2,
 p_send_cancel_lines IN VARCHAR2 := 'N',
 x_line_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type,
 x_return_status     OUT NOCOPY VARCHAR2)
IS
  l_sales_order_id      NUMBER;
  l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_sch_gloabl_value    VARCHAR2(1);
  I                     NUMBER;

  CURSOR inc_parents is
    SELECT line_id
    FROM   oe_order_lines
    WHERE  item_type_code IN ('MODEL', 'CLASS', 'KIT')
    AND    ato_line_id is NULL
    AND    explosion_date is NULL
    AND    header_id = p_header_id
    AND    ((top_model_line_id =  p_model_line_id)
    OR    (ship_set_id = p_ship_set_id)
    OR    (arrival_set_id = p_arrival_set_id)
    OR    (line_id = p_link_to_line_id));

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  Print_Time('Entering Query_Set_Lines '|| p_sch_action);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_link_to_line_id <> FND_API.G_MISS_NUM AND
     (p_ship_set_id    <> FND_API.G_MISS_NUM OR
      p_arrival_set_id <> FND_API.G_MISS_NUM OR
      p_model_line_id  <> FND_API.G_MISS_NUM )
  THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INCORRECT IN PARAMETERS' , 1 ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF nvl(p_sch_action, 'A' ) <> OE_Schedule_Util.OESCH_ACT_UNSCHEDULE
     AND
     nvl(p_sch_action, 'A' ) <> OE_Schedule_Util.OESCH_ACT_UNRESERVE
  THEN

    l_sch_gloabl_value := OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING;
    OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
    OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CHECK IF II ITEMS REQ.' , 3 ) ;
    END IF;

    FOR parentrec in inc_parents
    LOOP
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALL II_ITEMS'|| PARENTREC.LINE_ID , 3 ) ;
      END IF;
      l_return_status := OE_CONFIG_UTIL.Process_Included_Items
                         (p_line_id   => parentrec.line_id,
                          p_freeze    => FALSE);


      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

    OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := l_sch_gloabl_value;
    OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
  END IF;


  IF p_arrival_set_id <> FND_API.G_MISS_NUM THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ARRIVAL SET ID '|| P_ARRIVAL_SET_ID , 3 ) ;
    END IF;

    OE_Set_Util.Query_Set_Rows
    (p_set_id   => p_arrival_set_id,
     x_line_tbl => x_line_tbl);

  ELSIF p_ship_set_id <> FND_API.G_MISS_NUM THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP SET ID '|| P_SHIP_SET_ID , 3 ) ;
    END IF;

    OE_Set_Util.Query_Set_Rows
    (p_set_id   => p_ship_set_id,
     x_line_tbl => x_line_tbl);

  ELSIF p_model_line_id <> FND_API.G_MISS_NUM THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_TOP_MODEL_LINE_ID '|| P_MODEL_LINE_ID , 3 ) ;
    END IF;

    OE_Config_Util.Query_Options
    (p_top_model_line_id => p_model_line_id,
     p_send_cancel_lines => p_send_cancel_lines,
     p_source_type       => OE_Globals.G_SOURCE_INTERNAL,
     x_line_tbl          => x_line_tbl);

  ELSIF p_link_to_line_id <> FND_API.G_MISS_NUM THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_LINK_TO_LINE_ID '|| P_LINK_TO_LINE_ID , 3 ) ;
    END IF;

    OE_Config_Util.Query_Included_Items
    (p_line_id           => p_link_to_line_id,
     p_send_cancel_lines => p_send_cancel_lines,
     p_source_type       => OE_Globals.G_SOURCE_INTERNAL,
     x_line_tbl          => x_line_tbl);

  END IF;

  IF x_line_tbl.count > 0 THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NO. OF LINES '|| X_LINE_TBL.COUNT , 3 ) ;
    END IF;
    l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id
                        (p_header_id);
  END IF;

  I := x_line_tbl.FIRST;
  WHILE I is not NULL
  LOOP
    IF x_line_tbl(I).schedule_status_code is not null THEN

    -- INVCONV - MERGED CALLS	 FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

     OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                              ,p_line_id   => x_line_tbl(I).line_id
                                              ,p_org_id    => x_line_tbl(I).ship_from_org_id
                                              ,x_reserved_quantity =>  x_line_tbl(I).reserved_quantity
                                              ,x_reserved_quantity2 => x_line_tbl(I).reserved_quantity2
																							);

      /*x_line_tbl(I).reserved_quantity :=
             OE_LINE_UTIL.Get_Reserved_Quantity
             (p_header_id   => l_sales_order_id,
              p_line_id     => x_line_tbl(I).line_id,
              p_org_id      => x_line_tbl(I).ship_from_org_id);
 			x_line_tbl(I).reserved_quantity2 :=   -- INVCONV
             OE_LINE_UTIL.Get_Reserved_Quantity2
             (p_header_id   => l_sales_order_id,
              p_line_id     => x_line_tbl(I).line_id,
              p_org_id      => x_line_tbl(I).ship_from_org_id); */

    END IF;


    IF x_line_tbl(I).reserved_quantity is NULL OR
       x_line_tbl(I).reserved_quantity = FND_API.G_MISS_NUM
    THEN
      x_line_tbl(I).reserved_quantity := 0;
    ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE '|| X_LINE_TBL ( I ) .LINE_ID , 4 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RES QTY '|| X_LINE_TBL ( I ) .RESERVED_QUANTITY , 4 ) ;
      END IF;
    END IF;

    IF x_line_tbl(I).reserved_quantity2 is NULL OR -- INVCONV
       x_line_tbl(I).reserved_quantity2 = FND_API.G_MISS_NUM
    THEN
      x_line_tbl(I).reserved_quantity2 := 0;
    ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE '|| X_LINE_TBL ( I ) .LINE_ID , 4 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RES QTY2 '|| X_LINE_TBL ( I ) .RESERVED_QUANTITY2 , 4 ) ;
      END IF;
    END IF;

    I := x_line_tbl.NEXT(I);
  END LOOP;

  Print_Time('Exiting Query_Set_Lines');

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
   OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
   OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
   IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXC ERROR IN Query_Set_Lines' , 1 ) ;
   END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN OTHERS THEN

   OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
   OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
     OE_MSG_PUB.Add_Exc_Msg
     ( G_PKG_NAME
     ,'Query_Set_Lines'
            );
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Set_Lines;


/*-----------------------------------------------------------
may be I will replace my individual queries by this api
in future.
------------------------------------------------------------*/
PROCEDURE Query_Config_Attributes
( p_line_id      IN  NUMBER
 ,p_sch_attibs   IN  VARCHAR2 := 'N'
 ,x_line_rec     OUT NOCOPY /* file.sql.39 change */ OE_Order_Pub.Line_Rec_Type)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'QUERY CA LINE_ID '|| P_LINE_ID , 1 ) ;
  END IF;
  SELECT ATO_LINE_ID
        ,BOOKED_FLAG
        ,COMPONENT_CODE
        ,COMPONENT_NUMBER
        ,COMPONENT_SEQUENCE_ID
        ,CONFIG_HEADER_ID
        ,CONFIG_REV_NBR
        ,CONFIGURATION_ID
        ,CREATION_DATE
        ,EXPLOSION_DATE
        ,HEADER_ID
        ,ITEM_TYPE_CODE
        ,LINE_ID
        ,LINE_NUMBER
        ,LINK_TO_LINE_ID
        ,OPEN_FLAG
        ,OPTION_NUMBER
        ,ORDERED_QUANTITY
        ,ORDER_QUANTITY_UOM
        ,ORDERED_ITEM
        ,SHIPPABLE_FLAG
        ,SHIP_MODEL_COMPLETE_FLAG
        ,SPLIT_FROM_LINE_ID
        ,MODEL_REMNANT_FLAG
        ,TOP_MODEL_LINE_ID
        ,UPGRADED_FLAG
        ,LOCK_CONTROL
  INTO
         x_line_rec.ATO_LINE_ID
        ,x_line_rec.BOOKED_FLAG
        ,x_line_rec.COMPONENT_CODE
        ,x_line_rec.COMPONENT_NUMBER
        ,x_line_rec.COMPONENT_SEQUENCE_ID
        ,x_line_rec.CONFIG_HEADER_ID
        ,x_line_rec.CONFIG_REV_NBR
        ,x_line_rec.CONFIGURATION_ID
        ,x_line_rec.CREATION_DATE
        ,x_line_rec.EXPLOSION_DATE
        ,x_line_rec.HEADER_ID
        ,x_line_rec.ITEM_TYPE_CODE
        ,x_line_rec.LINE_ID
        ,x_line_rec.LINE_NUMBER
        ,x_line_rec.LINK_TO_LINE_ID
        ,x_line_rec.OPEN_FLAG
        ,x_line_rec.OPTION_NUMBER
        ,x_line_rec.ORDERED_QUANTITY
        ,x_line_rec.ORDER_QUANTITY_UOM
        ,x_line_rec.ORDERED_ITEM
        ,x_line_rec.SHIPPABLE_FLAG
        ,x_line_rec.SHIP_MODEL_COMPLETE_FLAG
        ,x_line_rec.SPLIT_FROM_LINE_ID
        ,x_line_rec.MODEL_REMNANT_FLAG
        ,x_line_rec.TOP_MODEL_LINE_ID
        ,x_line_rec.UPGRADED_FLAG
        ,x_line_rec.LOCK_CONTROL
    FROM  OE_ORDER_LINES
    WHERE LINE_ID = P_LINE_ID;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR IN QUERY_CONFIG_ATTRIBUTES '|| SQLERRM , 2 ) ;
    END IF;
    RAISE;
END Query_Config_Attributes;


/*---------------------------------------------------------------
Procedure Validate_Group_Request

           This procedure is written for the validation of group request
           that is passed in.

SCHEDULE_ATO:
  You cannot schedule a ATO model without a warehouse.
  reserve/unreserve and unscheudle whe config item present
  is not allowed on ATO's.

SCHEDULE SMC:
SCHEDULE NONSMC:


With cto change order project, we no longer need to check that
if CONFIG item is created and not allow UNSCHEDULE.

Also the validate item warehouse in OEXLLINB.pls will take
care of checking the warehouse on the ATO options, so we
do not need that check.

****Not used anymore.
 ---------------------------------------------------------------*/
Procedure Validate_Group_Request
( p_line_rec      IN  OE_Order_PUB.Line_Rec_Type
 ,p_request_type  IN  VARCHAR2
 ,p_sch_action    IN  VARCHAR2
 ,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_return_status       VARCHAR2(1);
  l_num_id              NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING VALIDATE_GROUP_REQUEST' , 1 ) ;
  END IF;

  OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => p_line_rec.line_id
         ,p_header_id                   => p_line_rec.header_id
         ,p_line_id                     => p_line_rec.line_id
         ,p_orig_sys_document_ref       => p_line_rec.orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => p_line_rec.orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => p_line_rec.orig_sys_shipment_ref
         ,p_change_sequence             => p_line_rec.change_sequence
         ,p_source_document_id          => p_line_rec.source_document_id
         ,p_source_document_line_id     => p_line_rec.source_document_line_id
         ,p_order_source_id             => p_line_rec.order_source_id
         ,p_source_document_type_id     => p_line_rec.source_document_type_id);

  IF p_request_type = 'SCHEDULE_ATO' THEN

    SELECT ship_from_org_id
    INTO   l_num_id
    FROM   oe_order_lines
    WHERE  line_id = p_line_rec.ato_line_id;

    IF l_num_id is NULL AND
       p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_SCHEDULE
    THEN

      FND_MESSAGE.SET_NAME('ONT','OE_SCH_ATO_WHSE_REQD');
      OE_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

      RETURN;

    END IF;


    IF (p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_RESERVE) OR
       (p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_UNRESERVE)
    THEN

      FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_NO_CONFIG');
      OE_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

      RETURN;

    END IF;

  END IF;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING VALIDATE_GROUP_REQUEST' , 1 ) ;
  END IF;
END Validate_Group_Request;


/*-------------------------------------------------------------
Call_ATP
Temporary call.
--------------------------------------------------------------*/
PROCEDURE Call_ATP
( p_atp_rec    IN  MRP_ATP_PUB.ATP_Rec_Typ
 ,x_atp_rec    OUT NOCOPY /* file.sql.39 change */ MRP_ATP_PUB.ATP_Rec_Typ)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING CALL_ATP' , 1 ) ;
  END IF;

  x_atp_rec := p_atp_rec;

  FOR I IN 1..x_atp_rec.Action.LAST
  LOOP
    x_atp_rec.Ship_Date(I)          :=  x_atp_rec.Requested_Ship_Date(I);
    x_atp_rec.Group_Ship_Date(I)    :=  x_atp_rec.Requested_Ship_Date(I);
    x_atp_rec.Group_arrival_date(I) :=  x_atp_rec.Requested_Ship_Date(I);
    x_atp_rec.Source_Organization_ID(I)      :=  204;
  END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING CALL_ATP' , 1 ) ;
  END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ERROR IN CALL ATP '|| SQLERRM , 1 ) ;
   END IF;
   RAISE;
END;


/*----------------------------------------------------------
PROCEDURE Is_Group_Scheduled

values of x_result,
 0  not scheduled
 1  some lines scheduled
 2  all lines scheduled

****not used
-----------------------------------------------------------*/
PROCEDURE Is_Group_Scheduled
( p_line_tbl     IN  OE_Order_Pub.Line_Tbl_Type
 ,p_caller       IN  VARCHAR2 := 'X'
 ,x_result       OUT NOCOPY /* file.sql.39 change */ NUMBER)
IS
  l_unscheduled_line  VARCHAR2(1) := 'N';
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF p_caller = 'UI_ACTION' THEN

    x_result := 0;

    FOR I in p_line_tbl.FIRST..p_line_tbl.LAST
    LOOP
      IF p_line_tbl(I).schedule_status_code is NOT NULL THEN
        x_result := 2;
      ELSE
        l_unscheduled_line := 'Y';
      END IF;
    END LOOP;

    IF l_unscheduled_line = 'Y' AND x_result = 2 THEN
      x_result := 1;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'MULTI GRP '|| X_RESULT , 3 ) ;
    END IF;

  ELSE
    IF p_line_tbl(p_line_tbl.FIRST).schedule_status_code is NULL
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NOT SCHEDULED SINGLE GRP' , 3 ) ;
      END IF;
      x_result := 0;
    ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SCHEDULED SINGLE GRP' , 3 ) ;
      END IF;
      x_result := 2;
    END IF;
  END IF;

END Is_Group_Scheduled;


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


END OE_CONFIG_SCHEDULE_PVT;

/
