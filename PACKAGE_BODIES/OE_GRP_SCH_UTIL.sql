--------------------------------------------------------
--  DDL for Package Body OE_GRP_SCH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_GRP_SCH_UTIL" AS
/* $Header: OEXVGRPB.pls 120.3 2005/08/05 07:54:27 kmuruges noship $ */

G_PKG_NAME      CONSTANT    VARCHAR2(30):='OE_GRP_SCH_UTIL';

PROCEDURE Query_Lines
(   p_header_id      IN NUMBER,
    x_line_tbl		 IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type);

Procedure Validate_Group_Request
(p_group_req_rec IN  OE_GRP_SCH_UTIL.Sch_Group_Rec_Type
,x_return_status OUT NOCOPY VARCHAR2);


Procedure Validate_Warehouse
(p_line_tbl         IN  OE_ORDER_PUB.line_tbl_type
,p_ship_from_org_id IN  NUMBER
,x_return_status OUT NOCOPY VARCHAR2);


/*--------------------------------------------------------------------
Procedure Name : Delink_Required
Description    : ** Currently not used **
---------------------------------------------------------------------*/
FUNCTION Delink_Required(p_line_rec IN OE_ORDER_PUB.line_rec_type)
RETURN BOOLEAN
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   RETURN TRUE;
END Delink_Required;
/*--------------------------------------------------------------------
Procedure Name : Validate_Line
---------------------------------------------------------------------*/
Procedure Validate_Line(p_line_rec      IN OE_ORDER_PUB.Line_Rec_Type,
                        p_old_line_rec  IN OE_ORDER_PUB.Line_Rec_Type,
x_return_status OUT NOCOPY VARCHAR2)

IS
l_return_status          VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_result                 Varchar2(30);
l_scheduling_level_code  VARCHAR2(30) := NULL;
l_out_return_status      VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
l_type_code              VARCHAR2(30);
l_org_id                 NUMBER;
l_bill_seq_id            NUMBER;
l_make_buy               NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  '..ENTERING OE_GRP_SCH_UTIL.VALIDATE_LINE' , 1 ) ;
   END IF;

   -- If the quantity on the line is missing or null and if
   -- the user is trying to performing scheduling, it is an error

   IF ((p_old_line_rec.ordered_quantity is null OR
        p_old_line_rec.ordered_quantity = FND_API.G_MISS_NUM) AND
         (p_line_rec.ordered_quantity is null OR
          p_line_rec.ordered_quantity = FND_API.G_MISS_NUM)) THEN

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_MISSING_QUANTITY');
             OE_MSG_PUB.Add;
             l_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   -- If the quantity on the line is zero(which is different from
   -- missing)  and if the user is trying to performing scheduling,
   -- it is an error

   IF (((p_old_line_rec.ordered_quantity is null OR
         p_old_line_rec.ordered_quantity = FND_API.G_MISS_NUM OR
         p_old_line_rec.ordered_quantity = 0) AND
         p_line_rec.ordered_quantity = 0) AND
         (nvl(p_line_rec.cancelled_flag,'N') = 'N')) THEN

         IF p_line_rec.schedule_action_code is not null THEN

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_ZERO_QTY');
             OE_MSG_PUB.Add;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'E2' , 1 ) ;
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
         END IF;

   END IF;

   -- If the line is shipped, scheduling is not allowed.

   IF (p_line_rec.shipped_quantity is not null) AND
        (p_line_rec.shipped_quantity <> FND_API.G_MISS_NUM) THEN

         IF p_line_rec.schedule_action_code is not null THEN

             -- The line is cancelled. Cannot perform scheduling
             -- on it.

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_LINE_SHIPPED');
             OE_MSG_PUB.Add;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'OE_SCH_LINE_SHIPPED' , 1 ) ;
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;

         END IF;
   END IF;

   -- Check to see if the reserved quantity is changed and is more
   -- than the ordered quantity. This should not be allowed.

   IF NOT OE_GLOBALS.Equal(p_old_line_rec.reserved_quantity,
                             p_line_rec.reserved_quantity)
   THEN
        -- Reserved Quantity has changed
       IF (p_line_rec.ordered_quantity < p_line_rec.reserved_quantity)
       THEN

         FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_MORE_ORD_QTY');
         OE_MSG_PUB.Add;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'E4' , 1 ) ;
         END IF;
         l_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       -- after changing reserved qty, trying to unschedule or unreserve
       -- dose not make sense.
       IF (p_line_rec.schedule_action_code =
                           OE_ORDER_SCH_UTIL.OESCH_ACT_UNSCHEDULE OR
           p_line_rec.schedule_action_code =
                          OE_ORDER_SCH_UTIL.OESCH_ACT_UNRESERVE) AND
           (p_line_rec.reserved_quantity is not null) THEN

           FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_QTY_CHG_NOT_ALLOWED');
           OE_MSG_PUB.Add;
           l_return_status := FND_API.G_RET_STS_ERROR;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'E5' , 1 ) ;
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
       THEN
         IF (p_line_rec.ordered_quantity < p_line_rec.reserved_quantity)
         THEN

           FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_MORE_ORD_QTY');
           OE_MSG_PUB.Add;

           l_return_status := FND_API.G_RET_STS_ERROR;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'E6' , 1 ) ;
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

             l_return_status := FND_API.G_RET_STS_ERROR;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'E7' , 1 ) ;
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

             l_return_status := FND_API.G_RET_STS_ERROR;
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
             l_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   -- If the line belongs to a set, you cannot unschedule the line
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CHECKING FOR SET VALIDATIONS....' , 1 ) ;
   END IF;
   IF ((p_line_rec.ship_set_id is not null AND
         p_line_rec.ship_set_id <> FND_API.G_MISS_NUM) AND
         (p_line_rec.schedule_action_code =
                           OE_ORDER_SCH_UTIL.OESCH_ACT_UNDEMAND OR
          p_line_rec.schedule_action_code =
                           OE_ORDER_SCH_UTIL.OESCH_ACT_UNSCHEDULE))
          THEN

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_OE_ORDER_FAILED');
             OE_MSG_PUB.Add;

             l_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CHECKING FOR HOLDS....' , 1 ) ;
   END IF;
   --IF FND_PROFILE.VALUE('ONT_SCHEDULE_LINE_ON_HOLD') = 'N' AND
     IF oe_sys_parameters.value ('ONT_SCHEDULE_LINE_ON_HOLD') = 'N' AND --moac
        (p_line_rec.schedule_action_code =
                              OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE OR
          p_line_rec.schedule_action_code =
                              OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE OR
          (p_line_rec.schedule_status_code is not null AND
           OE_ORDER_SCH_UTIL.Schedule_Attribute_Changed
                                     (p_line_rec     => p_line_rec,
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
            l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

   END IF;

   -- Check to see what scheduling level is allowed to be performed
   -- on this line. If the action requested is not allowed for the
   -- scheduling action, error out.

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CHECKING SCHEDULING LEVEL...' , 1 ) ;
   END IF;
   l_scheduling_level_code := OE_ORDER_SCH_UTIL.Get_Scheduling_Level
                                        (p_line_rec.header_id,
										 p_line_rec.line_type_id);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_SCHEDULING_LEVEL_CODE : ' || L_SCHEDULING_LEVEL_CODE , 1 ) ;
   END IF;

   IF l_scheduling_level_code is not null THEN
        IF l_scheduling_level_code = OE_ORDER_SCH_UTIL.SCH_LEVEL_ONE THEN
           IF p_line_rec.schedule_action_code =
                                    OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE OR
              p_line_rec.schedule_action_code =
                                    OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE OR
             (p_line_rec.schedule_status_code is  null AND
             (p_line_rec.schedule_ship_date is NOT NULL OR
              p_line_rec.schedule_arrival_date is NOT NULL))
            THEN

              FND_MESSAGE.SET_NAME('ONT','OE_SCH_ACTION_NOT_ALLOWED');
              FND_MESSAGE.SET_TOKEN('ACTION',
                       nvl(p_line_rec.schedule_action_code,
                                         OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE));
              FND_MESSAGE.SET_TOKEN('ORDER_TYPE',
                       nvl(oe_order_sch_util.sch_cached_line_type,
                           oe_order_sch_util.sch_cached_order_type));
              OE_MSG_PUB.Add;
              l_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
        ELSIF l_scheduling_level_code = OE_ORDER_SCH_UTIL.SCH_LEVEL_TWO THEN
           -- Changes for Bug-2497354
           -- Changed the IF condition for bug 2681047
           IF p_line_rec.reserved_quantity > 0 AND
              p_line_rec.reserved_quantity <> FND_API.G_MISS_NUM AND
              p_line_rec.reserved_quantity IS NOT NULL THEN

              FND_MESSAGE.SET_NAME('ONT','OE_SCH_ACTION_NOT_ALLOWED');
              FND_MESSAGE.SET_TOKEN('ACTION',
                        nvl(p_line_rec.schedule_action_code,
                                 OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE));
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'RESERVED QUANTITY IS GREATER THAN ZERO' ) ;
              END IF;
              OE_MSG_PUB.Add;
              l_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

           IF p_line_rec.schedule_action_code =
                                 OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE THEN
              FND_MESSAGE.SET_NAME('ONT','OE_SCH_ACTION_NOT_ALLOWED');
              FND_MESSAGE.SET_TOKEN('ACTION',
                        nvl(p_line_rec.schedule_action_code,
                                 OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE));
              FND_MESSAGE.SET_TOKEN('ORDER_TYPE',
                        nvl(oe_order_sch_util.sch_cached_line_type,
                            oe_order_sch_util.sch_cached_order_type));
              OE_MSG_PUB.Add;
              l_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
        END IF;
   END IF;

  -- Added this part of validation to fix bug 2051855
   IF p_line_rec.ato_line_id = p_line_rec.line_id AND
     p_line_rec.item_type_code in ('STANDARD','OPTION') THEN

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
        oe_debug_pub.add(  'L_MAKE_BUY' || L_MAKE_BUY , 2 ) ;
    END IF;

    IF nvl(l_make_buy,1) <> 2 THEN
     BEGIN

/* added the condition to check for the warehouse entered in the lines block */
/* This is done to fix the bug 2692235 */

      SELECT BILL_SEQUENCE_ID
      INTO   l_bill_seq_id
      FROM   BOM_BILL_OF_MATERIALS
      WHERE  ORGANIZATION_ID = nvl(p_line_rec.ship_from_org_id,l_org_id)
      AND    ASSEMBLY_ITEM_ID = p_line_rec.inventory_item_id
      AND    ALTERNATE_BOM_DESIGNATOR IS NULL;

     EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NO BILL IS DEFINED' , 2 ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_BOM_NO_BILL_IN_VAL_ORG');
         FND_MESSAGE.SET_TOKEN('ITEM',nvl(p_line_rec.ordered_item,p_line_rec.inventory_item_id));
         FND_MESSAGE.SET_TOKEN('ORG',l_org_id);
         OE_MSG_PUB.Add;
         l_return_status := FND_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN
         Null;
     END;
    END IF;
   END IF;

   x_return_status := l_return_status;

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  '..EXITING OE_GRP_SCH_UTIL.VALIDATE_LINE WITH ' || L_RETURN_STATUS , 1 ) ;
                        END IF;
END Validate_Line;

/*-------------------------------------------------------------------
Procedure Name : Group_Schedule
Description    : This procedure will take in a request for a group and
                 will query up all the records for the group and perform
                 the group request on the records.
                 The groups could be:
                     Order
                     Configuration
                     ATO
                     Ship Set
                     Arrival Set
                 The action to be performed could be
                     Demand
                     Reserve
                     ATP_Check
                     Cancel
                     UnDemand
                     UnReserve
                     UnSchedule

--------------------------------------------------------------------- */

Procedure Group_Schedule(p_group_req_rec         IN  OE_GRP_SCH_UTIL.Sch_Group_Rec_Type
,x_atp_tbl OUT NOCOPY OE_ATP.Atp_Tbl_Type

,x_return_status OUT NOCOPY Varchar2)

IS
l_return_status VARCHAR2(1);

l_atp_tbl       OE_ATP.Atp_Tbl_Type;
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING GROUP SCHEDULE' , 1 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTITY :' || P_GROUP_REQ_REC.ENTITY_TYPE , 1 ) ;
   END IF;
   SAVEPOINT group_schedule;

   Validate_Group_Request(p_group_req_rec => p_group_req_rec,
                          x_return_status => l_return_status);

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF  (p_group_req_rec.entity_type =
        OE_ORDER_SCH_UTIL.OESCH_ENTITY_ATO_CONFIG)
   THEN
     Schedule_ATO(p_group_req_rec => p_group_req_rec,
                  x_atp_tbl         => l_atp_tbl,
                  x_return_status => l_return_status);

    x_atp_tbl := l_atp_tbl;
   ELSIF (p_group_req_rec.entity_type =
          OE_ORDER_SCH_UTIL.OESCH_ENTITY_ORDER) OR
         (p_group_req_rec.entity_type =
          OE_ORDER_SCH_UTIL.OESCH_ENTITY_LINE)
   THEN
    Schedule_Order(p_header_id     => p_group_req_rec.header_id,
                   p_sch_action    => p_group_req_rec.action,
                   p_entity_type   => p_group_req_rec.entity_type,
                   p_line_id       => p_group_req_rec.line_id,
                   x_atp_tbl       => l_atp_tbl,
                   x_return_status => l_return_status,
                   x_msg_count     => l_msg_count,
                   x_msg_data      => l_msg_data);

    x_atp_tbl := l_atp_tbl;

   ELSIF (p_group_req_rec.entity_type =
          OE_ORDER_SCH_UTIL.OESCH_ENTITY_SMC)
   THEN
    Schedule_Set(p_group_req_rec   => p_group_req_rec,
                 x_atp_tbl         => l_atp_tbl,
                 x_return_status   => l_return_status);

    x_atp_tbl := l_atp_tbl;
   ELSIF (p_group_req_rec.entity_type =
          OE_ORDER_SCH_UTIL.OESCH_ENTITY_SHIP_SET) OR
         (p_group_req_rec.entity_type =
          OE_ORDER_SCH_UTIL.OESCH_ENTITY_ARRIVAL_SET)
   THEN
    Schedule_Set(p_group_req_rec => p_group_req_rec,
                 x_atp_tbl       => l_atp_tbl,
                 x_return_status => l_return_status);

    x_atp_tbl := l_atp_tbl;
   END IF;

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING GROUP SCHEDULE' , 1 ) ;
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
            ,   'Group_Schedule'
            );
        END IF;
END Group_Schedule;

/* ---------------------------------------------------------------
Procedure Schedule_Order
This procedure is responsible for scheduling the whole order.
An order can consists of many lines and each line can be within a group.
We plan to schedule in the following way:
1. Schedule standard lines  and non smc PTO options
   (not in any set) independently.
2. Schedule ATO (not in any other set) Options together.
3. Schedule PTO-SMC (not in any other set) Options together.
4. Schedule PTO-SMC (not in any other set) Options together.
4. Schedule Ship set (not in any arrival set) together.
4. Schedule Arrival set together.
 ---------------------------------------------------------------*/
Procedure Schedule_Order(p_header_id       IN  NUMBER,
                         p_sch_action      IN  VARCHAR2,
                         p_entity_type     IN  VARCHAR2,
                         p_line_id         IN  NUMBER,
x_atp_tbl OUT NOCOPY OE_ATP.Atp_Tbl_Type,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2)

IS
l_old_line_rec            OE_ORDER_PUB.line_rec_type;
--l_out_line_rec            OE_ORDER_PUB.line_rec_type;
l_out_atp_rec             OE_ATP.atp_rec_type;
l_out_atp_tbl             OE_ATP.atp_tbl_type;
l_line_rec                OE_ORDER_PUB.line_rec_type;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(2000);

l_control_rec             OE_GLOBALS.control_rec_type;
l_line_tbl                OE_ORDER_PUB.line_tbl_type;
l_header_out_rec          OE_Order_PUB.Header_Rec_Type;
l_header_rec              OE_Order_PUB.Header_Rec_Type;
l_line_out_tbl            OE_Order_PUB.Line_Tbl_Type;
l_header_adj_out_tbl      OE_Order_PUB.Header_Adj_Tbl_Type;
l_header_scredit_out_tbl  OE_Order_PUB.Header_Scredit_Tbl_Type;
l_line_adj_out_tbl        OE_Order_PUB.Line_Adj_Tbl_Type;
l_line_scredit_out_tbl    OE_Order_PUB.Line_Scredit_Tbl_Type;
l_lot_serial_out_tbl      OE_Order_PUB.Lot_Serial_Tbl_Type;
l_action_request_out_tbl  OE_Order_PUB.Request_Tbl_Type;
l_new_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_out_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_group_req_rec           OE_GRP_SCH_UTIL.Sch_Group_Rec_Type;

l_arrival_set_id            NUMBER;
l_ato_line_id               NUMBER;
l_demand_class_code         VARCHAR2(30);
l_delivery_lead_time        NUMBER;
l_freight_carrier_code      VARCHAR2(30);
l_header_id                 NUMBER;
l_inventory_item_id         NUMBER;
l_invoice_to_org_id         NUMBER;
l_item_type_code            VARCHAR2(30);
l_ordered_item              VARCHAR2(2000);
l_line_id                   NUMBER;
l_ordered_quantity          NUMBER;
l_order_quantity_uom        VARCHAR2(3);
l_request_date              DATE;
l_schedule_ship_date        DATE;
l_schedule_arrival_date     DATE;
l_ship_from_org_id          NUMBER;
l_ship_model_complete_flag  VARCHAR2(1);
l_ship_set_id               NUMBER;
l_ship_to_org_id            NUMBER;
l_schedule_status_code      VARCHAR2(30);
l_shipping_method_code      VARCHAR2(30);
l_sold_to_org_id            NUMBER;
l_top_model_line_id         NUMBER;

atp_count                   NUMBER;
I                           NUMBER;

processed_ship_set          number_arr;
processed_arrival_set       number_arr;
processed_pto_smc           number_arr;
processed_ato               number_arr;

ship_set_count              NUMBER := 0;
arrival_set_count           NUMBER := 0;
pto_smc_count               NUMBER := 0;
ato_count                   NUMBER := 0;


CURSOR standard_lines IS
   SELECT arrival_set_id,
          ato_line_id,
          demand_class_code,
          delivery_lead_time,
          freight_carrier_code,
          header_id,
          inventory_item_id,
          invoice_to_org_id,
          item_type_code,
          ordered_item,
          line_id,
          ordered_quantity,
          order_quantity_uom,
          request_date,
          schedule_ship_date,
          schedule_arrival_date,
          ship_from_org_id,
          ship_model_complete_flag,
          ship_set_id,
          ship_to_org_id,
          schedule_status_code,
          shipping_method_code,
          sold_to_org_id,
          top_model_line_id
   FROM oe_order_lines
   WHERE header_id = p_header_id
   AND item_type_code <> OE_GLOBALS.G_ITEM_INCLUDED;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_GRP_SCH_UTIL.SCHEDULE_ORDER' , 1 ) ;
  END IF;

  /* Bug :2222360 */
  IF p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INSIDE ATP CHECK SAVEPOINT' ) ;
    END IF;
    SAVEPOINT ATP_CHECK;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_HEADER_ID : ' || P_HEADER_ID , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_SCH_ACTION: ' || P_SCH_ACTION , 1 ) ;
  END IF;

--  l_line_tbl := Query_Lines(p_header_id => p_header_id);

  Query_Lines(p_header_id  =>  p_header_id,
              x_line_tbl   =>  l_line_tbl);

  atp_count := 1;
  I := 1;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NO. OF LINES TO SCHEDULE: ' || L_LINE_TBL.COUNT , 1 ) ;
  END IF;

  l_arrival_set_id  := null;
  l_ship_set_id     := null;
  ship_set_count    := 0;
  arrival_set_count := 0;

  FOR line_index IN 1..l_line_tbl.count
  LOOP
   BEGIN

      SAVEPOINT SCHEDULE_ORDER;
      OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_tbl(line_index).line_id
         ,p_header_id                   => l_line_tbl(line_index).header_id
         ,p_line_id                     => l_line_tbl(line_index).line_id
         ,p_orig_sys_document_ref       =>
                                l_line_tbl(line_index).orig_sys_document_ref
         ,p_orig_sys_document_line_ref  =>
                                l_line_tbl(line_index).orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => l_line_tbl(line_index).orig_sys_shipment_ref
         ,p_change_sequence             => l_line_tbl(line_index).change_sequence
         ,p_source_document_id          =>
                                l_line_tbl(line_index).source_document_id
         ,p_source_document_line_id     =>
                                l_line_tbl(line_index).source_document_line_id
         ,p_order_source_id             =>
                                l_line_tbl(line_index).order_source_id
         ,p_source_document_type_id     =>
                                l_line_tbl(line_index).source_document_type_id);

      -- Added code to fix bug 1778701.
     IF l_line_tbl(line_index).line_category_code = 'RETURN' THEN


        --Ingnore return lines to schedule.

        goto end_loop;

     END IF;

     IF (l_line_tbl(line_index).item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
        l_line_tbl(line_index).item_type_code = OE_GLOBALS.G_ITEM_OPTION) AND
        l_line_tbl(line_index).ato_line_id <>
                          l_line_tbl(line_index).line_id AND
        (l_line_tbl(line_index).ship_model_complete_flag = 'Y' OR
         l_line_tbl(line_index).ato_line_id is not null) AND
        (p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE   OR
         p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_UNSCHEDULE OR
         p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK) THEN

        -- Skipping this option line since it will be picked up when the
        -- model is scheduled.
        goto end_loop;

     END IF;

     l_line_rec     := l_line_tbl(line_index);
     l_old_line_rec := l_line_rec;

     -- Code has been modified to fix bug 1873099.
--     IF p_sch_action <> OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE THEN
       IF p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE OR
          p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_UNSCHEDULE OR
          p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK OR
         (p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE AND
                l_line_rec.schedule_status_code is null) THEN

        -- We want to skip a line belonging to a set only if the action
        -- is SCHEDULE,ATP or UNSCHEDULE. We do not want to skip if the
        -- action is RESERVE or UNRESERVE, since then, we will treat the
        -- line independently.

        IF l_line_rec.arrival_set_id is not null THEN
           -- Check to see if this set is already processed. If yes, then
           -- go to the end.
           FOR c IN 1..processed_arrival_set.count LOOP
              IF l_line_rec.arrival_set_id = processed_arrival_set(c)
              THEN
                  -- This set has been processed.
                  goto end_loop;
              END IF;
           END LOOP;

           -- If the line could not find it's arrival set id in the
           -- processed_arrival_set, it has not been processed. Let's add the
           -- set_id to the table and process the set.

           arrival_set_count := arrival_set_count + 1;
           processed_arrival_set(arrival_set_count) :=
                                 l_line_rec.arrival_set_id;

        ELSIF l_line_rec.ship_set_id is not null THEN
           -- Check to see if this set is already processed. If yes, then
           -- go to the end.
           FOR c IN 1..processed_ship_set.count LOOP
              IF l_line_rec.ship_set_id = processed_ship_set(c)
              THEN
                  -- This set has been processed.
                  goto end_loop;
              END IF;
           END LOOP;

           -- If the line could not find it's ship set id in the
           -- processed_ship_set, it has not been processed. Let's add the
           -- set_id to the table and process the set.

           ship_set_count := ship_set_count + 1;
           processed_ship_set(ship_set_count) := l_line_rec.ship_set_id;
        ELSIF nvl(l_line_rec.ship_model_complete_flag,'N') = 'Y' THEN
           -- Check to see if this set is already processed. If yes, then
           -- go to the end.
           pto_smc_count := processed_pto_smc.count;
           IF pto_smc_count > 0 THEN
              FOR c IN 1..processed_pto_smc.count LOOP
                 IF l_line_rec.top_model_line_id = processed_pto_smc(c)
                 THEN
                     -- This set has been processed.
                     goto end_loop;
                 END IF;
              END LOOP;
           END IF;

           -- If the line could not find it's top model line id in the
           -- processed_pto_smc, it has not been processed. Let's add the
           -- top_model_line_id to the table and process the set.

           pto_smc_count := pto_smc_count + 1;
           processed_pto_smc(pto_smc_count) := l_line_rec.top_model_line_id;
        ELSIF l_line_rec.ato_line_id is not null THEN
           -- Check to see if this set is already processed. If yes, then
           -- go to the end.
           ato_count := processed_ato.count;
           IF ato_count > 0 THEN
              FOR c IN 1..processed_ato.count LOOP
                 IF l_line_rec.ato_line_id = processed_ato(c)
                 THEN
                     -- This set has been processed.
                     goto end_loop;
                 END IF;
              END LOOP;
           END IF;

           -- If the line could not find it's ATO Line id in the
           -- processed_ato set, it has not been processed. Let's add the
           -- set_id to the table and process the set.

           ato_count := ato_count + 1;
           processed_ato(ato_count) := l_line_rec.ato_line_id;

        END IF;
     END IF; /* Action is not Reserve */

     IF (l_line_rec.ship_set_id is not null OR
        l_line_rec.arrival_set_id is not null OR
        l_line_rec.ship_model_complete_flag = 'Y' OR
        (l_line_rec.ato_line_id = l_line_rec.line_id AND
         l_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_STANDARD AND
         l_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_OPTION)) AND
        (p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE OR
         p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_UNSCHEDULE OR
         p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK OR
         (p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE AND
                     l_line_rec.schedule_status_code is null ) )
     THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SCHEDULING A GROUP ' , 1 ) ;
         END IF;
         l_line_rec.schedule_action_code := p_sch_action;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SO: CREATING GROUP_REQUEST' , 1 ) ;
         END IF;

         OE_ORDER_SCH_UTIL.Create_Group_Request
          (  p_line_rec      => l_line_rec
           , p_old_line_rec  => l_line_rec
           , x_group_req_rec => l_group_req_rec
           , x_return_status => l_return_status
          );

         -- Line belongs to a group. Needs to be scheduled in a group.

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SO: CALLING GROUP_SCHEDULE: ' || L_RETURN_STATUS , 1 ) ;
         END IF;

         Group_Schedule
           ( p_group_req_rec     => l_group_req_rec
            ,x_atp_tbl           => l_out_atp_tbl
            ,x_return_status     => l_return_status);

                                       IF l_debug_level  > 0 THEN
                                           oe_debug_pub.add(  'SO: AFTER CALLING GROUP_SCHEDULE' || L_RETURN_STATUS , 1 ) ;
                                       END IF;

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         FOR J IN 1..l_out_atp_tbl.count
         LOOP
            x_atp_tbl(atp_count) := l_out_atp_tbl(J);
            atp_count := atp_count + 1;
         END LOOP;

     ELSE

         l_line_rec.schedule_action_code     := p_sch_action;
         l_line_rec.operation                := OE_GLOBALS.G_OPR_UPDATE;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SCHEDULING LINE: ' || L_LINE_REC.LINE_ID , 1 ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ITEM TYPE IS : ' || L_LINE_REC.ITEM_TYPE_CODE , 1 ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' ' , 1 ) ;
         END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'GRP: CALLING SCHEDULE LINE' , 1 ) ;
         END IF;

         OE_ORDER_SCH_UTIL.Schedule_line
             ( p_old_line_rec  => l_old_line_rec
              ,p_write_to_db   => FND_API.G_TRUE
              ,p_x_line_rec      => l_line_rec
              ,x_atp_tbl       => l_out_atp_tbl
              ,x_return_status => l_return_status);

                                  IF l_debug_level  > 0 THEN
                                      oe_debug_pub.add(  'GRP:AFTER CALLING SCHEDULE LINE: ' || L_RETURN_STATUS , 1 ) ;
                                  END IF;

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Load the ATP table which could have more records than 1 since
         -- included items got scheduled.

         FOR J IN 1..l_out_atp_tbl.count
         LOOP
            x_atp_tbl(atp_count) := l_out_atp_tbl(J);
            atp_count := atp_count + 1;
         END LOOP;

         I := I + 1;

     END IF;

     <<end_loop>>
     null;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            -- We do not want to error our the whole order if a line
            -- did not schedule.

            ROLLBACK TO SCHEDULE_ORDER;
            null;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            ROLLBACK TO SCHEDULE_ORDER;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            ROLLBACK TO SCHEDULE_ORDER;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Schedule_Order'
                );
            END IF;
   END;
  END LOOP;

  oe_msg_pub.count_and_get
     (  p_count                       => x_msg_count
       ,p_data                        => x_msg_data
     );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'COUNT IS ' || X_MSG_COUNT , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_GRP_SCH_UTIL.SCHEDULE_ORDER' , 1 ) ;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Bug :2222360 */
  IF p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INSIDE ATP CHECK ROLLBACK' ) ;
    END IF;
    ROLLBACK TO ATP_CHECK;
    OE_Delayed_Requests_Pvt.Clear_Request
      (x_return_status => l_return_status);

  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        oe_msg_pub.count_and_get
           (  p_count                       => x_msg_count
             ,p_data                        => x_msg_data
           );
        /* Bug :2222360 */
        IF p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INSIDE ATP CHECK ROLLBACK' ) ;
           END IF;
           ROLLBACK TO ATP_CHECK;
           OE_Delayed_Requests_Pvt.Clear_Request
              (x_return_status => l_return_status);
        END IF;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        oe_msg_pub.count_and_get
           (  p_count                       => x_msg_count
             ,p_data                        => x_msg_data
           );

        /* Bug :2222360 */
        IF p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INSIDE ATP CHECK ROLLBACK' ) ;
           END IF;
           ROLLBACK TO ATP_CHECK;
            OE_Delayed_Requests_Pvt.Clear_Request
              (x_return_status => l_return_status);
        END IF;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        /* Bug :2222360 */
        IF p_sch_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INSIDE ATP CHECK ROLLBACK' ) ;
           END IF;
           ROLLBACK TO ATP_CHECK;
           OE_Delayed_Requests_Pvt.Clear_Request
              (x_return_status => l_return_status);
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_Order'
            );
        END IF;

        oe_msg_pub.count_and_get
           (  p_count                       => x_msg_count
             ,p_data                        => x_msg_data
           );

END Schedule_Order;
/* ---------------------------------------------------------------
Procedure Schedule_ATO
 ---------------------------------------------------------------*/

Procedure Schedule_ATO(p_group_req_rec IN  OE_GRP_SCH_UTIL.Sch_Group_Rec_Type,
x_atp_tbl OUT NOCOPY OE_ATP.Atp_Tbl_Type,

x_return_status OUT NOCOPY VARCHAR2)

IS
l_line_id         NUMBER;
l_atp_tbl         OE_ATP.atp_tbl_type;
l_line_rec        OE_ORDER_PUB.line_rec_type;
l_config_line_rec OE_ORDER_PUB.line_rec_type;
l_option_rec      OE_ORDER_PUB.line_rec_type;
l_option_tbl      OE_ORDER_PUB.line_tbl_type;
l_old_option_tbl  OE_ORDER_PUB.line_tbl_type;
l_old_line_rec    OE_ORDER_PUB.line_rec_type;
l_out_line_rec    OE_ORDER_PUB.line_rec_type;
l_model_line_rec  OE_ORDER_PUB.line_rec_type;
l_out_atp_rec     OE_ATP.atp_rec_type;
l_return_status   VARCHAR2(1);
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(2000);
l_action          VARCHAR2(30) := NULL;
-- For calling process order.
l_control_rec             OE_GLOBALS.control_rec_type;
l_line_tbl                OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_header_out_rec          OE_Order_PUB.Header_Rec_Type;
l_header_rec              OE_Order_PUB.Header_Rec_Type;
l_line_out_tbl            OE_Order_PUB.Line_Tbl_Type;
l_header_adj_out_tbl      OE_Order_PUB.Header_Adj_Tbl_Type;
l_header_scredit_out_tbl  OE_Order_PUB.Header_Scredit_Tbl_Type;
l_line_adj_out_tbl        OE_Order_PUB.Line_Adj_Tbl_Type;
l_line_scredit_out_tbl    OE_Order_PUB.Line_Scredit_Tbl_Type;
l_lot_serial_out_tbl      OE_Order_PUB.Lot_Serial_Tbl_Type;
l_action_request_out_tbl  OE_Order_PUB.Request_Tbl_Type;
l_Header_Adj_Att_tbl      OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl    OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
l_Header_price_Att_tbl    OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
l_Line_Price_Att_tbl      OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl        OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl      OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;

l_component_ratio         NUMBER;
l_model_quantity_chg      NUMBER;
l_ato_model_quantity      NUMBER;
l_config_id               NUMBER;
l_ato_line_id             NUMBER;
l_ship_set_id             NUMBER := null;
l_arrival_set_id          NUMBER := null;
l_cancelled_flag          VARCHAR2(1) := 'N';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING SCHEDULE_ATO' , 1 ) ;
  END IF;

  l_line_id := p_group_req_rec.line_id;

  -- Query the ATO line Id,Ship Set Id and Arrival Set Id from the line.

  SELECT ato_line_id , ship_set_id, arrival_set_id
  INTO l_ato_line_id,l_ship_set_id,l_arrival_set_id
  FROM oe_order_lines_all
  WHERE line_id = l_line_id;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'WAREHOUSE IS ' || P_GROUP_REQ_REC.SHIP_FROM_ORG_ID , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LINE ID IS : ' || L_LINE_ID , 1 ) ;
  END IF;

  --l_model_line_rec := Oe_line_Util.Query_Row(p_line_id => l_line_id);

  OE_Line_Util.Query_Row(p_line_id  => l_ato_line_id,
                         x_line_rec => l_model_line_rec);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CHECKING WAREHOUSE' , 1 ) ;
  END IF;

  -- Check to see if a warehouse is specified on the line. You need a
  -- warehouse to schedule an ATO

  IF l_model_line_rec.ship_from_org_id is NULL AND
     (p_group_req_rec.action = OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE OR
     p_group_req_rec.action = OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE) THEN

     -- You cannot schedule a ATO model without a warehouse. So flag
     -- an error.

     FND_MESSAGE.SET_NAME('ONT','OE_SCH_ATO_WHSE_REQD');
     OE_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;

  END IF;

  IF (p_group_req_rec.action = OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE) OR
     (p_group_req_rec.action = OE_ORDER_SCH_UTIL.OESCH_ACT_UNRESERVE)
  THEN
     -- This action is not allowed on an ATO configuration.
     FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_NO_CONFIG');
     OE_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;

  END IF; /* If action was reserve or unreserve */

  IF (p_group_req_rec.action = OE_ORDER_SCH_UTIL.OESCH_ACT_UNSCHEDULE)
  THEN
     -- This action is not allowed on an ATO configuration if the config
     -- item is created.
     BEGIN
        SELECT line_Id
        INTO l_config_id
        FROM OE_ORDER_LINES_ALL
        WHERE ato_line_id=l_model_line_rec.line_id
        AND top_model_line_id =l_model_line_rec.top_model_line_id
        AND item_type_code = 'CONFIG';

        FND_MESSAGE.SET_NAME('ONT','OE_SCH_UNSCH_CONFIG_EXISTS');
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             null;
     END;

  END IF; /* If action was unschedule */

  -- Query All the lines that belong to this ATO Group
--  l_line_tbl     := OE_CONFIG_UTIL.Query_ATO_Options
--                           (l_model_line_rec.ato_line_id);
/*
     IF l_model_line_rec.ordered_quantity = 0 THEN
        l_cancelled_flag := 'Y';
        oe_debug_pub.add('SCH: Setting cancelled flag to Y',1);
     ELSE
        l_cancelled_flag := 'N';
     END IF;
*/
     l_cancelled_flag := 'Y';

	OE_Config_Util.Query_ATO_Options
            (p_ato_line_id => l_model_line_rec.ato_line_id,
             p_send_cancel_lines => l_cancelled_flag,
             x_line_tbl    => l_line_tbl);

  -- If the group request has passed a new warehouse, validate the group
  -- with the new warehouse.

  IF (p_group_req_rec.ship_from_org_id is not null) THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CALLING VALIDATE_WAREHOUSE' , 1 ) ;
       END IF;

       Validate_Warehouse
       (p_line_tbl         => l_line_tbl
       ,p_ship_from_org_id => p_group_req_rec.ship_from_org_id
       ,x_return_status    => l_return_status);

                                             IF l_debug_level  > 0 THEN
                                                 oe_debug_pub.add(  'AFTER CALLING VALIDATE_WAREHOUSE: ' || L_RETURN_STATUS , 1 ) ;
                                             END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       END IF;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NO. OF LINES: ' || L_LINE_TBL.COUNT , 1 ) ;
  END IF;
  l_old_line_tbl := l_line_tbl;

  FOR  I IN 1..l_old_line_tbl.count LOOP

      IF l_old_line_tbl(1).schedule_status_code is null THEN

         l_old_line_tbl(I).schedule_ship_date := null;
         l_old_line_tbl(I).schedule_arrival_date := null;
         l_old_line_tbl(I).arrival_set_id := null;
         l_old_line_tbl(I).ship_set_id := null;
      ELSE

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SETTING OLD TO OLD DATES ' , 1 ) ;
         END IF;
         IF p_group_req_rec.old_schedule_ship_date is not null THEN
            l_old_line_tbl(I).schedule_ship_date :=
                              p_group_req_rec.old_schedule_ship_date;
         END IF;
         IF p_group_req_rec.old_schedule_arrival_date is not null THEN
            l_old_line_tbl(I).schedule_arrival_date :=
                              p_group_req_rec.old_schedule_arrival_date;
         END IF;
         IF p_group_req_rec.old_ship_from_org_id is not null THEN

            l_old_line_tbl(I).ship_from_org_id :=
                               p_group_req_rec.old_ship_from_org_id;
         END IF;
         -- Populating old dates to fix bug 2194475.
         IF p_group_req_rec.old_request_date is not null THEN

            l_old_line_tbl(I).request_date :=
                               p_group_req_rec.old_request_date;
         END IF;
         l_old_line_tbl(I).ship_set_id    := p_group_req_rec.old_ship_set_number;
         l_old_line_tbl(I).arrival_set_id := p_group_req_rec.old_arrival_set_number;
      END IF;

  END LOOP;

/*  IF p_group_req_rec.old_schedule_ship_date is not null OR
     p_group_req_rec.old_schedule_arrival_date is not null THEN

    oe_debug_pub.add('Schedule date has changed',1);
    oe_debug_pub.add('Setting Old to old dates ',1);
    FOR  I IN 1..l_old_line_tbl.count LOOP
         IF p_group_req_rec.old_schedule_ship_date is not null THEN
            l_old_line_tbl(I).schedule_ship_date :=
                              p_group_req_rec.old_schedule_ship_date;
         END IF;
         IF p_group_req_rec.old_schedule_arrival_date is not null THEN
            l_old_line_tbl(I).schedule_arrival_date :=
                              p_group_req_rec.old_schedule_arrival_date;
         END IF;
    END LOOP;
  END IF;

  IF l_old_line_tbl.count >= 1 AND
     l_old_line_tbl(1).schedule_status_code is null THEN

    FOR  I IN 1..l_old_line_tbl.count LOOP
         l_old_line_tbl(I).schedule_ship_date := null;
         l_old_line_tbl(I).schedule_arrival_date := null;
         l_old_line_tbl(I).arrival_set_id := null;
         l_old_line_tbl(I).ship_set_id := null;
    END LOOP;

  END IF;
*/

  -- Set the request on the line the lines of the ATO Group

  IF p_group_req_rec.old_quantity <> p_group_req_rec.quantity
  THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'MODEL QUANTITY HAS CHANGED' , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'MODEL OLD QUANTITY ' || P_GROUP_REQ_REC.OLD_QUANTITY , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'MODEL QUANTITY ' || P_GROUP_REQ_REC.QUANTITY , 1 ) ;
     END IF;
     l_ato_model_quantity := p_group_req_rec.old_quantity;
     l_model_quantity_chg := p_group_req_rec.quantity -
                             p_group_req_rec.old_quantity;
  END IF;

  -- If the group action is schedule on a scheduled group, changing the same
  -- to reschedule, otherwise respect group action value.

  IF l_model_line_rec.schedule_status_code is not null
  AND p_group_req_rec.action = OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE
  THEN
     l_action := OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;
  ELSE

     IF p_group_req_rec.action is not null THEN
        l_action := p_group_req_rec.action;
     ELSE
        l_action := OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;
     END IF;

  END IF;

  FOR I IN 1..l_line_tbl.count LOOP
    l_line_rec := l_line_tbl(I);

/*    IF p_group_req_rec.action is not null THEN
         l_line_rec.schedule_action_code := p_group_req_rec.action;
    ELSE
         l_line_rec.schedule_action_code :=
                     OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;
    END IF;
*/
    l_line_rec.schedule_action_code := l_action;
    l_line_rec.ship_set := l_line_rec.ato_line_id;
    l_line_rec.ship_set_id := l_ship_set_id;
    l_line_rec.arrival_set_id := l_arrival_set_id;

    -- If there is a change to the model quantity,
    -- cascade the Quantity Change to all the Options

    IF p_group_req_rec.old_quantity <> p_group_req_rec.quantity THEN
         l_component_ratio := l_line_rec.ordered_quantity/l_ato_model_quantity;
         l_line_rec.ordered_quantity := l_component_ratio *
                                        p_group_req_rec.quantity;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW QTY: ' || L_LINE_REC.ORDERED_QUANTITY , 1 ) ;
         END IF;
    END IF;

    IF (p_group_req_rec.ship_from_org_id is not null) THEN
        l_line_rec.ship_from_org_id := p_group_req_rec.ship_from_org_id;
    END IF;
    IF (p_group_req_rec.ship_to_org_id is not null) THEN
        l_line_rec.ship_to_org_id := p_group_req_rec.ship_to_org_id;
    END IF;
    IF (p_group_req_rec.request_date is not null) THEN
        l_line_rec.schedule_ship_date := p_group_req_rec.request_date;
        l_line_rec.request_date := p_group_req_rec.request_date;
    END IF;
    IF (p_group_req_rec.schedule_ship_date is not null) THEN
        l_line_rec.schedule_ship_date := p_group_req_rec.schedule_ship_date;
    END IF;
    IF (p_group_req_rec.schedule_arrival_date is not null) THEN
        l_line_rec.schedule_arrival_date := p_group_req_rec.schedule_arrival_date;
    END IF;

    l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    l_line_tbl(I) := l_line_rec;
    l_line_rec := OE_ORDER_PUB.G_MISS_LINE_REC;

  END LOOP;

  -- Added a code to fix bug 2275374.
  FOR I IN 1..l_line_tbl.count LOOP

    Validate_line(p_line_rec      => l_line_tbl(I),
                  p_old_line_rec  => l_old_line_tbl(I),
                  x_return_status => l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                   IF l_debug_level  > 0 THEN
                                       oe_debug_pub.add(  'ATO: AFTER VALIDATE LINE UN EXP ERROR' || L_LINE_TBL ( I ) .LINE_ID , 1 ) ;
                                   END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
                                   IF l_debug_level  > 0 THEN
                                       oe_debug_pub.add(  'ATO: AFTER VALIDATE LINE EXP ERROR' || L_LINE_TBL ( I ) .LINE_ID , 1 ) ;
                                   END IF;
    END IF;

  END LOOP;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ATO: CALLING PROCESS_SET_OF_LINES' , 1 ) ;
  END IF;

  Process_set_of_lines( p_old_line_tbl  => l_old_line_tbl,
                        x_atp_tbl       => l_atp_tbl,
                        p_x_line_tbl      => l_line_tbl,
                        x_return_status => l_return_status);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ATO: AFTER CALLING PROCESS_SET_OF_LINES' , 1 ) ;
  END IF;

  x_atp_tbl := l_atp_tbl;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING SCHEDULE_ATO' , 1 ) ;
  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_ATO'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Schedule_ATO;

/* ---------------------------------------------------------------
Procedure : Schedule_SMC
Description: ** Currently Not Used **
 ---------------------------------------------------------------*/
Procedure Schedule_SMC(p_group_req_rec IN  OE_GRP_SCH_UTIL.Sch_Group_Rec_Type,
x_return_status OUT NOCOPY VARCHAR2)

IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   null;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_SMC'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Schedule_SMC;

/* ---------------------------------------------------------------
Procedure : Query_Set_Lines
Description:
 ---------------------------------------------------------------*/
Procedure Query_Set_Lines
( p_header_id       IN NUMBER,
 p_entity_type      VARCHAR2,
 p_ship_set_id      NUMBER,
 p_arrival_set_id   NUMBER,
 p_line_id          NUMBER,
 x_line_tbl         IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type)
IS
l_line_rec            OE_Order_PUB.Line_Rec_Type;
l_line_tbl            OE_Order_PUB.Line_Tbl_Type;
l_set_line_tbl        OE_Order_PUB.Line_Tbl_Type;
l_ii_line_tbl         OE_Order_PUB.Line_Tbl_Type;
K                     NUMBER := 0;
J                     NUMBER := 0;
orig_count            NUMBER;
l_sales_order_id      NUMBER;
l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_old_recursion_mode   VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING QUERY_SET_LINES' , 1 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTITY IS ' || P_ENTITY_TYPE , 1 ) ;
   END IF;

   IF p_entity_type = OE_ORDER_SCH_UTIL.OESCH_ENTITY_SHIP_SET THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING QUERY_SET_ROWS FOR: ' || P_SHIP_SET_ID , 1 ) ;
      END IF;

      OE_Set_Util.Query_Set_Rows(p_set_id   => p_ship_set_id,
                                 x_line_tbl => l_set_line_tbl);

   ELSIF p_entity_type = OE_ORDER_SCH_UTIL.OESCH_ENTITY_ARRIVAL_SET THEN
                                            IF l_debug_level  > 0 THEN
                                                oe_debug_pub.add(  'CALLING QUERY_SET_ROWS FOR: ' || P_ARRIVAL_SET_ID , 1 ) ;
                                            END IF;

         OE_Set_Util.Query_Set_Rows(p_set_id   => p_arrival_set_id,
                                    x_line_tbl => l_set_line_tbl);

   END IF;

   IF p_entity_type = OE_ORDER_SCH_UTIL.OESCH_ENTITY_SMC
   THEN
	OE_Config_Util.Query_Options(p_top_model_line_id => p_ship_set_id,
                                     p_send_cancel_lines => 'Y',
                                     x_line_tbl          => l_set_line_tbl);
   END IF;


   -- Loop through the queried records, assign to out table. And also explode the
   -- included items for model,class and kit.

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ORIGINAL COUNT ' || L_SET_LINE_TBL.COUNT , 1 ) ;
   END IF;

 -- removed extra looping to explode included items and populate reservation
 -- quantity, that way we can improve performance of this procedure and also
 -- we can fix bug 1868706.

   J := 0;
   FOR I IN 1..l_set_line_tbl.count LOOP

       IF I = 1 THEN
           l_sales_order_id := OE_ORDER_SCH_UTIL.Get_mtl_sales_order_id
                                              (l_set_line_tbl(1).HEADER_ID);
       END IF;

       IF l_set_line_tbl(I).item_type_code <> OE_GLOBALS.G_ITEM_INCLUDED THEN
          J := J + 1;
          x_line_tbl(J) := l_set_line_tbl(I);

          IF x_line_tbl(J).schedule_status_code is not null THEN
             x_line_tbl(J).reserved_quantity :=
                OE_LINE_UTIL.Get_Reserved_Quantity
                      (p_header_id   => l_sales_order_id,
                       p_line_id     => x_line_tbl(J).line_id,
                       p_org_id      => x_line_tbl(J).ship_from_org_id);
          END IF;
          IF  x_line_tbl(J).reserved_quantity = FND_API.G_MISS_NUM
          OR  x_line_tbl(J).reserved_quantity IS NULL THEN
                x_line_tbl(J).reserved_quantity := 0;
          END IF;

        -- Get the included items for every line which is a model, class, kit

          IF (x_line_tbl(J).ato_line_id is null) AND
             (x_line_tbl(J).item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
              x_line_tbl(J).item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
              x_line_tbl(J).item_type_code = OE_GLOBALS.G_ITEM_KIT) THEN

          -- Calling Process_Included_Items. This procedure
          -- will take care of exploding and updating the picture
          -- of included_items in the oe_order_lines table.

            l_old_recursion_mode := OE_GLOBALS.G_RECURSION_MODE;
            -- OE_GLOBALS.G_RECURSION_MODE := 'Y';

                              IF l_debug_level  > 0 THEN
                                  oe_debug_pub.add(  'CALLING PROCESS_INCLUDED_ITEMS FOR ITEM: ' || X_LINE_TBL ( J ) .INVENTORY_ITEM_ID ) ;
                              END IF;

            l_return_status := OE_CONFIG_UTIL.Process_Included_Items
                                 (p_line_rec  => x_line_tbl(J),
                                  p_freeze    => FALSE);

            -- OE_GLOBALS.G_RECURSION_MODE :=  l_old_recursion_mode;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'AFTER CALLING PROCESS_INCLUDED_ITEMS ' , 1 ) ;
            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

	    OE_Config_Util.query_included_items(
	                    p_line_id	        => x_line_tbl(J).line_id,
                            p_send_cancel_lines => 'Y',
                            x_line_tbl          => l_ii_line_tbl);

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'MERGING INCLUDED ITEM TABLE WITH LINE TABLE' , 1 ) ;
            END IF;

          -- Merge the Included Item table to the line table
            FOR K IN 1..l_ii_line_tbl.count LOOP
                J := J+1;
                x_line_tbl(J) := l_ii_line_tbl(K);
                IF x_line_tbl(J).schedule_status_code is not null THEN
                    x_line_tbl(J).reserved_quantity :=
                         OE_LINE_UTIL.Get_Reserved_Quantity
                            (p_header_id   => l_sales_order_id,
                             p_line_id     => x_line_tbl(J).line_id,
                             p_org_id      => x_line_tbl(J).ship_from_org_id);
                END IF;
                IF  x_line_tbl(J).reserved_quantity = FND_API.G_MISS_NUM
                OR  x_line_tbl(J).reserved_quantity IS NULL THEN
                    x_line_tbl(J).reserved_quantity := 0;
                END IF;
            END LOOP; -- Merge loop

          END IF; -- Explode included items.



       END IF; -- Included Items.
   END LOOP;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SIZE OF NEW TABLE IS: ' || X_LINE_TBL.COUNT , 1 ) ;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING QUERY_SET_LINES' , 1 ) ;
   END IF;


EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Set_Lines'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Set_Lines;

/* ---------------------------------------------------------------
Procedure : Validate_Set_Attributes
Description: ** Currently not used **
 ---------------------------------------------------------------*/
Procedure  Validate_Set_Attributes
(p_entity_type   IN VARCHAR2,
p_line_tbl       IN OE_ORDER_PUB.line_tbl_type,
x_return_status OUT NOCOPY VARCHAR2) IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
END Validate_Set_Attributes;

/* ---------------------------------------------------------------
Procedure : Schedule_Set
Description:
 ---------------------------------------------------------------*/
Procedure Schedule_Set(p_group_req_rec IN  OE_GRP_SCH_UTIL.Sch_Group_Rec_Type,
x_atp_tbl OUT NOCOPY OE_ATP.Atp_Tbl_Type,

x_return_status OUT NOCOPY VARCHAR2)

IS
l_line_tbl                    OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl                OE_ORDER_PUB.line_tbl_type;
l_new_line_tbl                OE_ORDER_PUB.line_tbl_type;
l_included_items_tbl          OE_ORDER_PUB.line_tbl_type;
l_line_rec                    OE_ORDER_PUB.line_rec_type;
l_old_line_rec                OE_ORDER_PUB.line_rec_type;
l_new_line_rec                OE_ORDER_PUB.line_rec_type;
l_atp_tbl                     OE_ATP.atp_tbl_type;
l_Ship_From_Org_Id            NUMBER := null;
l_Ship_To_Org_Id              NUMBER := null;
l_Schedule_Ship_Date          DATE   := null;
l_Schedule_Arrival_Date       DATE   := null;
l_Freight_Carrier_Code        VARCHAR2(30) := null;
l_Shipping_Method_Code        VARCHAR2(30) := null;
l_shipment_priority_code      VARCHAR2(30) := null;
l_return_status               VARCHAR2(1);
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(2000);
l_new_quantity                NUMBER;
l_old_quantity                NUMBER;
l_quantity                    NUMBER;
J                             NUMBER;
l_config_id                   NUMBER;
l_set_rec                     OE_ORDER_CACHE.set_rec_type;
l_set_name                    VARCHAR2(30);
l_set_id                      NUMBER := null;
l_action                      VARCHAR2(30) := Null;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING SCHEDULE_SET' , 1 ) ;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING QUERY_SET_LINES' , 1 ) ;
  END IF;

  Query_Set_Lines
    (p_header_id      => p_group_req_rec.header_id,
     p_entity_type    => p_group_req_rec.entity_type,
     p_ship_set_id    => p_group_req_rec.ship_set_number,
     p_arrival_set_id => p_group_req_rec.arrival_set_number,
     p_line_id        => p_group_req_rec.line_id,
     x_line_tbl       => l_line_tbl);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING QUERY_SET_LINES' , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'COUNT IS ' || L_LINE_TBL.COUNT , 1 ) ;
  END IF;

  -- Added this part of validation to fix bug 2411889.

  IF  p_group_req_rec.action = OE_ORDER_SCH_UTIL.OESCH_ACT_UNSCHEDULE
  AND p_group_req_rec.entity_type = OE_ORDER_SCH_UTIL.OESCH_ENTITY_SMC
  AND l_line_tbl(1).schedule_status_code is not null
  THEN
     -- This action is not allowed on an ATO configuration if the config
     -- item is created.
     BEGIN
        SELECT line_Id
        INTO l_config_id
        FROM OE_ORDER_LINES_ALL
        WHERE top_model_line_id = l_line_tbl(1).top_model_line_id
        AND item_type_code = 'CONFIG';

        FND_MESSAGE.SET_NAME('ONT','OE_SCH_UNSCH_CONFIG_EXISTS');
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             null;
        WHEN TOO_MANY_ROWS THEN
         FND_MESSAGE.SET_NAME('ONT','OE_SCH_UNSCH_CONFIG_EXISTS');
         OE_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
     END;

  END IF; /* If action was unschedule */

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER THE VALIDATION' , 1 ) ;
  END IF;

  l_old_line_tbl := l_line_tbl;

  -- If any of the lines is a model or class, get it's included items.

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'COUNT IS ' || L_LINE_TBL.COUNT , 1 ) ;
  END IF;

  FOR  I IN 1..l_old_line_tbl.count LOOP

       IF l_old_line_tbl(1).schedule_status_code is null THEN

         l_old_line_tbl(I).schedule_ship_date := null;
         l_old_line_tbl(I).schedule_arrival_date := null;
         l_old_line_tbl(I).ship_set_id := null;
         l_old_line_tbl(I).arrival_set_id := null;

       ELSE
         l_old_line_tbl(I).ship_set_id :=
                              p_group_req_rec.old_ship_set_number;
         l_old_line_tbl(I).arrival_set_id :=
                              p_group_req_rec.old_arrival_set_number;

/* commented the following lines to fix the bug 2605588
         IF p_group_req_rec.old_schedule_ship_date is not null THEN
            l_old_line_tbl(I).schedule_ship_date :=
                              p_group_req_rec.old_schedule_ship_date;
         END IF;
         IF p_group_req_rec.old_schedule_arrival_date is not null THEN
            l_old_line_tbl(I).schedule_arrival_date :=
                              p_group_req_rec.old_schedule_arrival_date;
         END IF;
*/
         IF p_group_req_rec.old_ship_from_org_id is not null THEN

            l_old_line_tbl(I).ship_from_org_id :=
                               p_group_req_rec.old_ship_from_org_id;
         END IF;
         -- Populating old dates to fix bug 2194237.
/* commented the following lines to fix the bug 2605588
         IF p_group_req_rec.old_request_date is not null THEN

            l_old_line_tbl(I).request_date :=
                               p_group_req_rec.old_request_date;
         END IF;
*/


       END IF;

  END LOOP;
  -- If the group action is schedule on a scheduled group, changing the same
  -- to reschedule, otherwise respect group action value.
  IF l_line_tbl.count > 0 THEN

     IF l_line_tbl(1).schedule_status_code is not null
     AND p_group_req_rec.action = OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE
     THEN
        l_action := OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;
     ELSE

        IF p_group_req_rec.action is not null THEN
           l_action := p_group_req_rec.action;
        ELSE
           l_action := OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;
        END IF;

     END IF;

  END IF;

  IF p_group_req_rec.entity_type = OE_ORDER_SCH_UTIL.OESCH_ENTITY_SMC OR
     p_group_req_rec.entity_type = OE_ORDER_SCH_UTIL.OESCH_ENTITY_SHIP_SET THEN

       IF p_group_req_rec.entity_type =
                    OE_ORDER_SCH_UTIL.OESCH_ENTITY_SHIP_SET
       THEN
            l_set_rec := OE_ORDER_CACHE.Load_Set
                                        (p_group_req_rec.ship_set_number);
            l_set_name := l_set_rec.set_name;
            l_set_id   := l_set_rec.set_id;
       ELSE
            l_set_name := p_group_req_rec.ship_set_number;
       END IF;

       FOR I IN 1..l_line_tbl.count LOOP

           l_line_rec := l_line_tbl(I);

           l_line_rec.ship_set :=  l_set_name;

        /*   IF p_group_req_rec.action is not null THEN
             l_line_rec.schedule_action_code := p_group_req_rec.action;
           ELSE
             l_line_rec.schedule_action_code :=
                     OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;
           END IF;*/

           l_line_rec.schedule_action_code := l_action;

           IF (p_group_req_rec.ship_to_org_id is not null) THEN
                 l_line_rec.ship_to_org_id := p_group_req_rec.ship_to_org_id;
           END IF;

           IF (p_group_req_rec.ship_from_org_id is not null) THEN
                 l_line_rec.ship_from_org_id :=
                                    p_group_req_rec.ship_from_org_id;
           END IF;

           IF (p_group_req_rec.request_date is not null) THEN
                 l_line_rec.schedule_ship_date :=
                                    p_group_req_rec.request_date;
                 l_line_rec.request_date :=
                             p_group_req_rec.request_date;
           END IF;

           IF (p_group_req_rec.schedule_ship_date is not null) THEN
                 l_line_rec.schedule_ship_date :=
                                    p_group_req_rec.schedule_ship_date;
           END IF;

           IF (p_group_req_rec.schedule_arrival_date is not null) THEN
                 l_line_rec.schedule_arrival_date :=
                                    p_group_req_rec.schedule_arrival_date;
           END IF;

           l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
           l_line_tbl(I) := l_line_rec;

       END LOOP;
  END IF; /* Ship Set */

  IF p_group_req_rec.entity_type =
               OE_ORDER_SCH_UTIL.OESCH_ENTITY_ARRIVAL_SET THEN

       l_set_rec := OE_ORDER_CACHE.Load_Set(p_group_req_rec.arrival_set_number);
       l_set_name := l_set_rec.set_name;
       l_set_id   := l_set_rec.set_id;

       FOR I IN 1..l_line_tbl.count LOOP
             l_line_rec := l_line_tbl(I);
             l_line_rec.arrival_set :=  l_set_name;
        --     l_line_rec.schedule_action_code := p_group_req_rec.action;
             l_line_rec.schedule_action_code := l_action;

             IF (p_group_req_rec.ship_to_org_id is not null) THEN
                 l_line_rec.ship_to_org_id :=
                             p_group_req_rec.ship_to_org_id;
             END IF;

             IF (p_group_req_rec.request_date is not null) THEN
                 l_line_rec.schedule_arrival_date :=
                             p_group_req_rec.request_date;
                 l_line_rec.request_date :=
                             p_group_req_rec.request_date;
             END IF;

             IF (p_group_req_rec.schedule_arrival_date is not null) THEN
                 l_line_rec.schedule_arrival_date :=
                             p_group_req_rec.schedule_arrival_date;
             END IF;

             l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
             l_line_tbl(I) := l_line_rec;

       END LOOP;
  END IF;


  -- Added a code to fix bug 2275374.
  FOR I IN 1..l_line_tbl.count LOOP

    Validate_line(p_line_rec      => l_line_tbl(I),
                  p_old_line_rec  => l_old_line_tbl(I),
                  x_return_status => l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                   IF l_debug_level  > 0 THEN
                                       oe_debug_pub.add(  'ATO: AFTER VALIDATE LINE UN EXP ERROR' || L_LINE_TBL ( I ) .LINE_ID , 1 ) ;
                                   END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
                                   IF l_debug_level  > 0 THEN
                                       oe_debug_pub.add(  'ATO: AFTER VALIDATE LINE EXP ERROR' || L_LINE_TBL ( I ) .LINE_ID , 1 ) ;
                                   END IF;
    END IF;

  END LOOP;
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING PROCESS_SET_OF_LINES' , 1 ) ;
  END IF;

  Process_set_of_lines( p_old_line_tbl  => l_old_line_tbl,
                        x_atp_tbl       => l_atp_tbl,
                        p_x_line_tbl      => l_line_tbl,
                        x_return_status => l_return_status);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING PROCESS_SET_OF_LINES' , 1 ) ;
  END IF;

  x_atp_tbl := l_atp_tbl;
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_set_id is not null THEN
     -- If scheduling set suceeded, then the result of scheduling
     -- have been updated to the database. Will query one of the lines
     -- of the set to see the change is set attributes so that we can
     -- update the set itself.

     l_old_line_rec := l_old_line_tbl(1);
--     l_new_line_rec := OE_Line_Util.Query_Row
--                         (p_line_id => l_old_line_rec.line_id);

	 OE_Line_Util.Query_Row( p_line_id   =>  l_old_line_rec.line_id,
							 x_line_rec  =>  l_new_line_rec);

     -- Update the set attributes.

    l_ship_from_org_id      := l_new_line_rec.ship_from_org_id;
    l_ship_to_org_id        := l_new_line_rec.ship_to_org_id;
    l_schedule_ship_date    := l_new_line_rec.schedule_ship_date;
    l_schedule_arrival_date := l_new_line_rec.schedule_arrival_date;
    l_shipping_method_code  := l_new_line_rec.shipping_method_code;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING UPDATE SET' ) ;
    END IF;

    OE_Set_Util.Update_Set
        (p_Set_Id                   => l_set_id,
         p_Ship_From_Org_Id         => l_Ship_From_Org_Id,
         p_Ship_To_Org_Id           => l_Ship_To_Org_Id,
         p_Schedule_Ship_Date       => l_Schedule_Ship_Date,
         p_Schedule_Arrival_Date    => l_Schedule_Arrival_Date,
         p_Freight_Carrier_Code     => l_Freight_Carrier_Code,
         p_Shipping_Method_Code     => l_Shipping_Method_Code,
         p_shipment_priority_code   => l_shipment_priority_code,
         X_Return_Status            => l_return_status,
         x_msg_count                => l_msg_count,
         x_msg_data                 => l_msg_data
        );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER CALLING UPDATE SET' ) ;
    END IF;

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING SCHEDULE_SET' , 1 ) ;
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
            ,   'Schedule_Set'
            );
        END IF;
END Schedule_Set;


/* ---------------------------------------------------------------
FUNCTION  : Compare_set_attr
Description: This function is called to compare set and line record
             for set attributes. This will help in avoiding additional call
             to MRP if the line is scheduled for a same set attributes.
 ---------------------------------------------------------------*/
FUNCTION Compare_Set_Attr(p_set_ship_from_org_id IN NUMBER ,
                          p_line_ship_from_org_id IN NUMBER,
                          p_set_ship_to_org_id IN NUMBER,
                          p_line_ship_to_org_id IN NUMBER,
                          p_set_schedule_ship_date IN DATE,
                          p_line_schedule_ship_date IN DATE,
                          p_set_arrival_date IN DATE,
                          p_line_arrival_date IN DATE,
                          p_set_type IN VARCHAR2)
RETURN BOOLEAN
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_SET_TYPE :' || P_SET_TYPE , 2 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_LINE_SHIP_FROM_ORG_ID :' || P_LINE_SHIP_FROM_ORG_ID , 2 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_SET_SHIP_FROM_ORG_ID :' || P_SET_SHIP_FROM_ORG_ID , 2 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_LINE_SHIP_TO_ORG_ID :' || P_LINE_SHIP_TO_ORG_ID , 2 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_SET_SHIP_TO_ORG_ID :' || P_SET_SHIP_TO_ORG_ID , 2 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_LINE_SCHEDULE_SHIP_DATE :' || P_LINE_SCHEDULE_SHIP_DATE , 2 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_SET_SCHEDULE_SHIP_DATE :' || P_SET_SCHEDULE_SHIP_DATE , 2 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_LINE_ARRIVAL_DATE :' || P_LINE_ARRIVAL_DATE , 2 ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_SET_ARRIVAL_DATE :' || P_SET_ARRIVAL_DATE , 2 ) ;
   END IF;
   IF (p_set_type = 'SHIP_SET' AND
       p_line_ship_from_org_id  = p_set_ship_from_org_id   AND
       p_line_ship_to_org_id     = p_set_Ship_To_Org_Id     AND
       p_line_schedule_ship_date = p_set_schedule_ship_date)
   OR (p_set_type = 'ARRIVAL_SET' AND
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

    oe_msg_pub.add('return false from debug');
    RETURN FALSE;

END Compare_Set_Attr;


/* ---------------------------------------------------------------
Procedure  : Schedule_set_of_lines
Description: This procedure is exlusivley called from the Sets APIs
             when there is a request to schedule lines which are a
             part of a set.
 ---------------------------------------------------------------*/

Procedure Schedule_set_of_lines
                (p_old_line_tbl   IN  OE_ORDER_PUB.line_tbl_type,
                 p_x_line_tbl       IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type,
x_return_status OUT NOCOPY VARCHAR2)

IS
l_atp_tbl             OE_ATP.ATP_Tbl_Type;
l_line_rec            OE_ORDER_PUB.line_rec_type;
l_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_grp_line_tbl        OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl        OE_ORDER_PUB.line_tbl_type;
l_ii_line_tbl         OE_ORDER_PUB.line_tbl_type;
l_return_status       VARCHAR2(1);
K                     NUMBER := 0;
J                     NUMBER := 0;
l_old_recursion_mode  VARCHAR2(1);
l_old_perform         VARCHAR2(1);
l_sales_order_id      NUMBER;
l_need_reschedule     VARCHAR2(1);
l_entity_type         VARCHAR2(30);
l_log_msg             VARCHAR2(1) := 'Y';
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(2000);
l_option_exists       NUMBER;    -- Bug - 2287767
l_option_search       NUMBER;    -- Bug - 2287767
l_set_rec             OE_ORDER_CACHE.set_rec_type;
l_can_bypass          BOOLEAN := TRUE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING SCHEDULE_SET_OF_LINES' , 1 ) ;
   END IF;

   -- This procedure is called from the SETS api. The sets API has taken
   -- care of of validation that needed to be done for the lines
   -- to be scheduled together. i.e It has made sure that all the scheduling
   -- attributes are sames across the line. We will just pass the request to
   -- Process_Set_of_lines for scheduling. I am introducing this procedure
   -- in between sets and Process_set_of_lines, just for the sake that if
   -- we need to add some SET Api specific logic, then we can add that here.

   -- Let's first validate the lines passed to us. We will validate
   -- the attributes that we need for scheduling.

   -- To fix the bug 2431390, adding this logic to see if the line attributes
   -- matches with set attributes. If they matches then we can bypass scheduling

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_x_line_tbl(1).arrival_set_id is not null OR
      p_x_line_tbl(1).ship_set_id IS NOT NULL THEN
      l_set_rec := OE_ORDER_CACHE.Load_Set
        (nvl(p_x_line_tbl(1).arrival_set_id,p_x_line_tbl(1).ship_set_id));
   ELSE
      l_set_rec := Null;
      IF  p_x_line_tbl(1).arrival_set IS not null  THEN
       l_set_rec.set_type := 'SHIP_SET';
      ELSIF p_x_line_tbl(1).ship_set IS NOT NULL THEN
       l_set_rec.set_type := 'ARRIVAL_SET';
      END IF;
   END IF;


   IF p_x_line_tbl.count = 1 THEN

      IF p_x_line_tbl(1).schedule_status_code IS NOT NULL AND
         NOT OE_ORDER_SCH_UTIL.Schedule_Attribute_Changed
                   (p_line_rec =>  p_x_line_tbl(1),
                    p_old_line_rec => p_old_line_tbl(1)) AND
         (p_x_line_tbl(1).item_type_code = OE_GLOBALS.G_ITEM_STANDARD OR
          nvl(p_x_line_tbl(1).model_remnant_flag,'N') = 'Y') THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'ARRIVAL_SET_ID : ' || P_X_LINE_TBL ( 1 ) .ARRIVAL_SET_ID || ':' || P_X_LINE_TBL ( 1 ) .SHIP_SET_ID , 2 ) ;
          END IF;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OLD SHIP DATE ' || P_OLD_LINE_TBL ( 1 ) .SCHEDULE_SHIP_DATE , 2 ) ;
          END IF;
          IF l_set_rec.ship_from_org_id is null
          OR l_set_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ONLY SCHEDULED LINE IS GETTING INTO NEW SET' , 2 ) ;
             END IF;
             GOTO END_PROCESS;

          ELSE

           IF Compare_Set_Attr
           (p_set_ship_from_org_id    => l_set_rec.ship_from_org_id ,
            p_line_ship_from_org_id   => p_x_line_tbl(1).ship_from_org_id,
            p_set_ship_to_org_id      => l_set_rec.ship_to_org_id ,
            p_line_ship_to_org_id     => p_x_line_tbl(1).ship_to_org_id ,
            p_set_schedule_ship_date  => l_set_rec.schedule_ship_date ,
            p_line_schedule_ship_date => p_x_line_tbl(1).schedule_ship_date,
            p_set_arrival_date        => l_set_rec.schedule_arrival_date,
            p_line_arrival_date       => p_x_line_tbl(1).schedule_arrival_date,
            p_set_type                => l_set_rec.set_type) THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ONLY SCHEDULED LINE IS GETTING INTO OLD SET' , 2 ) ;
             END IF;
             GOTO END_PROCESS;

           END IF; -- compare.

          END IF;  -- set date is null/not null.


      END IF;  -- not null

   ELSE

    FOR I IN 1..p_x_line_tbl.count LOOP

       IF p_x_line_tbl(I).schedule_status_code IS NULL OR
          OE_ORDER_SCH_UTIL.Schedule_Attribute_Changed
                   (p_line_rec =>  p_x_line_tbl(I),
                    p_old_line_rec => p_old_line_tbl(I)) OR
         (p_x_line_tbl(I).item_type_code <> OE_GLOBALS.G_ITEM_STANDARD AND
          nvl(p_x_line_tbl(I).model_remnant_flag,'N') = 'N') THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'UNABLE TO BYPASS' , 2 ) ;
          END IF;
          l_can_bypass := FALSE;
          EXIT;

       END IF;

       IF ((l_set_rec.ship_from_org_id is not null AND
            l_set_rec.ship_from_org_id <> FND_API.G_MISS_NUM) AND
           Compare_Set_Attr
           (p_set_ship_from_org_id    => l_set_rec.ship_from_org_id ,
            p_line_ship_from_org_id   => p_x_line_tbl(I).ship_from_org_id,
            p_set_ship_to_org_id      => l_set_rec.ship_to_org_id ,
            p_line_ship_to_org_id     => p_x_line_tbl(I).ship_to_org_id ,
            p_set_schedule_ship_date  => l_set_rec.schedule_ship_date ,
            p_line_schedule_ship_date => p_x_line_tbl(I).schedule_ship_date,
            p_set_arrival_date        => l_set_rec.schedule_arrival_date,
            p_line_arrival_date       => p_x_line_tbl(I).schedule_arrival_date,
            p_set_type                => l_set_rec.set_type)) OR
          ((l_set_rec.ship_from_org_id is null OR
            l_set_rec.ship_from_org_id =  FND_API.G_MISS_NUM) AND
           Compare_Set_Attr
           (p_set_ship_from_org_id    => p_x_line_tbl(1).ship_from_org_id ,
            p_line_ship_from_org_id   => p_x_line_tbl(I).ship_from_org_id,
            p_set_ship_to_org_id      => p_x_line_tbl(1).ship_to_org_id ,
            p_line_ship_to_org_id     => p_x_line_tbl(I).ship_to_org_id ,
            p_set_schedule_ship_date  => p_x_line_tbl(1).schedule_ship_date ,
            p_line_schedule_ship_date => p_x_line_tbl(I).schedule_ship_date,
            p_set_arrival_date        => p_x_line_tbl(1).schedule_arrival_date,
            p_line_arrival_date       => p_x_line_tbl(I).schedule_arrival_date,
            p_set_type                => l_set_rec.set_type)) THEN

            l_can_bypass := TRUE;

       END IF;



    END LOOP;

    IF l_can_bypass THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ALL LINES MATCH WITH SET DATES , BYPASS MRP CALL' , 2 ) ;
       END IF;
       GOTO END_PROCESS;

    END IF;
   END IF; -- count

   -- Added arrival set to if stmt to fix bug 2527834.
   l_need_reschedule := 'N';
   FOR I IN 1..p_x_line_tbl.count LOOP
   BEGIN
     IF I =1 AND
        (p_x_line_tbl(I).ship_set_id is not null OR
         p_x_line_tbl(I).arrival_set_id is not null) THEN
          OE_ORDER_SCH_UTIL.OESCH_PERFORM_GRP_SCHEDULING := 'N';
          l_log_msg := 'N';
     END IF;
       IF ((p_x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_INCLUDED AND
             nvl(p_x_line_tbl(I).model_remnant_flag,'N') = 'N') OR
              p_x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_SERVICE) THEN

           -- Service items cannot be scheduled, so we will skip them.
           -- Included items will be picked up by their parent, so we will
           -- skip them.
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LINE IS A SERVICE OR INCLUDED ITEM' , 1 ) ;
           END IF;

       ELSIF (nvl(p_x_line_tbl(I).source_type_code,'INTERNAL') = 'INTERNAL')
       THEN
          OE_ORDER_SCH_UTIL.Validate_Line
             (p_line_rec           => p_x_line_tbl(I),
              p_old_line_rec       => p_old_line_tbl(I),
              x_return_status      => l_return_status);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;

         IF p_x_line_tbl(I).schedule_status_code is not null THEN
            l_need_reschedule := 'Y';
         END IF;

          K := K + 1;
          l_line_tbl(K)     := p_x_line_tbl(I);
          l_old_line_tbl(K) := p_old_line_tbl(I);

          IF (p_x_line_tbl(I).ato_line_id is null) AND
              nvl(p_x_line_tbl(I).model_remnant_flag,'N') <> 'Y' AND
             (p_x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
              p_x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
              p_x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_KIT) THEN

            -- Calling Process_Included_Items. This procedure
            -- will take care of exploding and updating the picture
            -- of included_items in the oe_order_lines table.

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'CALLING PROCESS_INCLUDED_ITEMS ' , 1 ) ;
            END IF;

            l_old_recursion_mode := OE_GLOBALS.G_RECURSION_MODE;
            -- OE_GLOBALS.G_RECURSION_MODE := 'Y';

            -- Bug 2304287
            l_old_perform := OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING;
            OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';

            l_return_status := OE_CONFIG_UTIL.Process_Included_Items
                                 (p_line_rec  => p_x_line_tbl(I),
                                  p_freeze    => FALSE);

            -- OE_GLOBALS.G_RECURSION_MODE :=  l_old_recursion_mode;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'AFTER CALLING PROCESS_INCLUDED_ITEMS ' , 1 ) ;
            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            OE_Config_Util.Query_Included_Items
                          (p_line_id  => p_x_line_tbl(I).line_id,
                           x_line_tbl => l_ii_line_tbl);

            OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := l_old_perform;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'MERGING INCLUDED ITEM TABLE WITH LINE TABLE' , 1 ) ;
            END IF;

            -- Merge the Included Item table to the line table
            FOR J IN 1..l_ii_line_tbl.count LOOP
                K := K+1;
                l_line_tbl(k)           := l_ii_line_tbl(J);
                l_old_line_tbl(K)       := l_ii_line_tbl(J);
                l_line_tbl(k).operation := OE_GLOBALS.G_OPR_UPDATE;
                l_line_tbl(k).schedule_action_code :=
                                      OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;
                l_line_tbl(k).ship_set :=
                                      p_x_line_tbl(I).ship_set;
                l_line_tbl(k).ship_set_id :=
                                      p_x_line_tbl(I).ship_set_id;
                -- bug fix for 2344800.
                l_line_tbl(k).arrival_set :=
                                      p_x_line_tbl(I).arrival_set;
                l_line_tbl(k).arrival_set_id :=
                                      p_x_line_tbl(I).arrival_set_id;
                l_line_tbl(k).schedule_ship_date :=
                                      p_x_line_tbl(I).schedule_ship_date;
                l_line_tbl(k).schedule_arrival_date :=
                                      p_x_line_tbl(I).schedule_arrival_date;
            END LOOP;
          END IF;
       ELSE
          /* Line is a Externally sourced line. We will not included
             it in the set */

         FND_MESSAGE.SET_NAME('ONT','OE_DS_SET_INS_FAILED');
         FND_MESSAGE.SET_TOKEN('LINE',p_x_line_tbl(I).line_number);
         OE_MSG_PUB.Add;

       END IF;

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            -- We do not want to error our the all lines due to an error
            -- in one of the lines. We will just not included the line
            -- in the set.

            null;

        WHEN OTHERS THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;
   END LOOP;

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'CALLING PROCESS_SET_OF_LINES WITH : ' || L_LINE_TBL.COUNT , 1 ) ;
                     END IF;

   -- Added this part of code to populate reserved qty to
   -- fix bug 1874169.

   FOR I IN 1..l_line_tbl.count LOOP

     IF I = 1 THEN

      l_sales_order_id := OE_ORDER_SCH_UTIL.Get_mtl_sales_order_id
                                           (l_line_tbl(1).HEADER_ID);
     END IF;
   -- If any of the lines are previously scheduled, then pass
   -- action as reschedule to MRP.

     IF l_need_reschedule = 'Y' THEN
      l_line_tbl(I).schedule_action_code :=
                    OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;
     END IF;

     IF l_line_tbl(I).schedule_status_code is not null THEN
        l_line_tbl(I).reserved_quantity :=
              OE_LINE_UTIL.Get_Reserved_Quantity
                 (p_header_id   => l_sales_order_id,
                  p_line_id     => l_line_tbl(I).line_id,
                  p_org_id      => l_line_tbl(I).ship_from_org_id);
        l_old_line_tbl(I).reserved_quantity := l_line_tbl(I).reserved_quantity;
     END IF;
     IF  l_line_tbl(I).reserved_quantity = FND_API.G_MISS_NUM
     OR  l_line_tbl(I).reserved_quantity IS NULL THEN
         l_liNe_tbl(I).reserved_quantity := 0;
     END IF;
     IF  l_old_line_tbl(I).reserved_quantity = FND_API.G_MISS_NUM
     OR  l_old_line_tbl(I).reserved_quantity IS NULL THEN
         l_old_line_tbl(I).reserved_quantity := 0;
     END IF;
   END LOOP;


   IF l_line_tbl.count > 0 THEN
      Process_set_of_lines(p_old_line_tbl  => l_old_line_tbl,
                           p_write_to_db   => FND_API.G_FALSE,
                           x_atp_tbl       => l_atp_tbl,
                           p_x_line_tbl    => l_line_tbl,
                           p_log_msg       => l_log_msg,
                           x_return_status => x_return_status);

   END IF;

   -- Added code to fix bug 1899651.
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'AFTER PROCESS SET_OF_LINES ' || X_RETURN_STATUS , 1 ) ;
   END IF;
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'WELCOME TO AUTO PUSH GROUP ' || L_LINE_TBL.COUNT , 1 ) ;
      END IF;
      IF fnd_profile.value('ONT_AUTO_PUSH_GRP_DATE') = 'Y'
      AND (l_line_tbl(1).arrival_set_id is not null OR
           l_line_tbl(1).ship_set_id is not null) THEN

         OE_ORDER_SCH_UTIL.OESCH_PERFORM_GRP_SCHEDULING := 'Y';

        -- Derive the entity id.
         IF l_line_tbl(1).arrival_set_id is not null THEN

            l_entity_type := OE_ORDER_SCH_UTIL.OESCH_ENTITY_ARRIVAL_SET;

         ELSIF l_line_tbl(1).ship_set_id is not null THEN

            l_entity_type := OE_ORDER_SCH_UTIL.OESCH_ENTITY_SHIP_SET;

         END IF;

         -- Call query set lines to query old lines from db.

         Query_Set_Lines
         (p_header_id      => Null,
          p_entity_type    => l_entity_type,
          p_ship_set_id    => l_line_tbl(1).ship_set_id,
          p_arrival_set_id => l_line_tbl(1).arrival_set_id,
          p_line_id        => Null,
          x_line_tbl       => l_grp_line_tbl);

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'AFTER QUERY SETS :' || L_GRP_LINE_TBL.COUNT , 1 ) ;
          END IF;
          IF l_grp_line_tbl.count > 0 THEN
             IF l_need_reschedule = 'N' THEN

                -- These line are getting scheduled first time.
                -- Since we are passing lines which are scheduled earlier
                -- change schedule action code.

                FOR I in 1..l_line_tbl.count LOOP

                  l_line_tbl(I).schedule_action_code :=
                                OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;

                END LOOP;

             END IF;

             J := l_line_tbl.count;

             FOR I in 1..l_grp_line_tbl.count LOOP

              -- J := J + 1;

              -- Populate correct schedule action code
              -- Populate old and new line table.
              -- Search for Option in the Line table ,if it does not exists
              -- then add it. Bug - 2287767
               l_option_exists := 0;
               FOR l_option_search in 1..J LOOP
                 IF l_grp_line_tbl(I).line_id =
                          l_line_tbl(l_option_search).line_id THEN
                       l_option_exists := 1;
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'OPTION ALREADY EXISTS IN THE LINE TABLE' ) ;
                 END IF;
                 EXIT;
                 END IF;
                END LOOP;

                 IF l_option_exists = 0 THEN       -- Bug - 2287767
                   --2319050.
                   J := J + 1;
                   l_line_tbl(J) := l_grp_line_tbl(I);
                   l_line_tbl(J).schedule_action_code :=
                                OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;

                   l_line_tbl(J).operation := OE_GLOBALS.G_OPR_UPDATE;

                   l_old_line_tbl(J) := l_grp_line_tbl(I);
                 END IF;
             END LOOP;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'BEFORE CALLING PROCESS SET ' || L_LINE_TBL.COUNT , 1 ) ;
             END IF;
             Process_set_of_lines(p_old_line_tbl  => l_old_line_tbl,
                                  p_write_to_db   => FND_API.G_FALSE,
                                  x_atp_tbl       => l_atp_tbl,
                                  p_x_line_tbl    => l_line_tbl,
                                  x_return_status => x_return_status);

             IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN


                 OE_Set_Util.Update_Set
                     (p_Set_Id                   => nvl(l_line_tbl(1).arrival_set_id,
                                                        l_line_tbl(1).ship_set_id),
                      p_Ship_From_Org_Id         => l_line_tbl(1).Ship_From_Org_Id,
                      p_Ship_To_Org_Id           => l_line_tbl(1).Ship_To_Org_Id,
                      p_Schedule_Ship_Date       => l_line_tbl(1).Schedule_Ship_Date,
                      p_Schedule_Arrival_Date    => l_line_tbl(1).Schedule_Arrival_Date,
                      p_Freight_Carrier_Code     => l_line_tbl(1).Freight_Carrier_Code,
                      p_Shipping_Method_Code     => l_line_tbl(1).Shipping_Method_Code,
                      p_shipment_priority_code   => l_line_tbl(1).shipment_priority_code,
                      X_Return_Status            => x_return_status,
                      x_msg_count                => l_msg_count,
                      x_msg_data                 => l_msg_data
                     );

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'AFTER CALLING UPDATE SET' ) ;
                 END IF;

             END IF;
          END IF; -- l_grp_count.
      ELSE
        IF l_log_msg = 'N' THEN
          FND_MESSAGE.SET_NAME('ONT','OE_SCH_GROUP_MEMBER_FAILED');
          OE_MSG_PUB.Add;
        END IF;
      END IF; -- Push group
   END IF; -- Return Status is error.

   OE_ORDER_SCH_UTIL.OESCH_PERFORM_GRP_SCHEDULING := 'Y';
   p_x_line_tbl := l_line_tbl;
   <<END_PROCESS>>
   null;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING SCHEDULE_SET_OF_LINES' , 1 ) ;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

       OE_ORDER_SCH_UTIL.OESCH_PERFORM_GRP_SCHEDULING := 'Y';
       x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       OE_ORDER_SCH_UTIL.OESCH_PERFORM_GRP_SCHEDULING := 'Y';

    WHEN OTHERS THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       OE_ORDER_SCH_UTIL.OESCH_PERFORM_GRP_SCHEDULING := 'Y';

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_set_of_lines'
            );
        END IF;

END Schedule_set_of_lines;

/* ---------------------------------------------------------------
Procedure:   Process_set_of_lines
Description:
 ---------------------------------------------------------------*/

Procedure Process_set_of_lines
           ( p_old_line_tbl  IN  OE_ORDER_PUB.line_tbl_type
                                := OE_ORDER_PUB.G_MISS_LINE_TBL,
            p_write_to_db   IN  VARCHAR2 := FND_API.G_TRUE,
x_atp_tbl OUT NOCOPY OE_ATP.Atp_Tbl_Type,

            p_x_line_tbl      IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type,
            p_log_msg       IN VARCHAR2 := 'Y',
x_return_status OUT NOCOPY VARCHAR2)

IS
l_line_tbl                OE_ORDER_PUB.line_tbl_type;
l_x_line_tbl              OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_out_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
l_out_mtp_atp_rec         MRP_ATP_PUB.ATP_Rec_Typ;
l_out_atp_table           OE_ATP.ATP_Tbl_Type;
l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
l_return_status           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_data                VARCHAR2(2000);
l_msg_count               NUMBER;
mrp_msg_data              VARCHAR2(200);
l_session_id              NUMBER := 0;
l_schedule_action_code    VARCHAR2(30);
l_avail_to_reserve        NUMBER;
l_on_hand_qty             NUMBER;
l_msg_index               NUMBER;
l_reset_action            VARCHAR2(1) := 'N';
l_schedule_level          VARCHAR2(30) := null;

l_reservation_rec         inv_reservation_global.mtl_reservation_rec_type;
l_query_rsv_rec           inv_reservation_global.mtl_reservation_rec_type;
l_rsv_tbl                 inv_reservation_global.mtl_reservation_tbl_type;
l_dummy_sn                inv_reservation_global.serial_number_tbl_type;
l_quantity_reserved       NUMBER;
l_qty_to_reserve          NUMBER;
l_rsv_id                  NUMBER;
l_buffer                  VARCHAR2(2000);

l_old_line_tbl1           OE_ORDER_PUB.line_tbl_type;
l_out_line_tbl1           OE_ORDER_PUB.line_tbl_type;
K                         NUMBER := 0;
M                         NUMBER := 0;
N                         NUMBER := 0;
l_process_requests        BOOLEAN;
TYPE char1 IS TABLE OF VARCHAR2(1) index by Binary_integer;
l_re_reserve_flag         char1;
l_reservable_type         NUMBER;
-- added by fabdi 03/May/2001
l_process_flag	          VARCHAR2(1) := FND_API.G_FALSE;
-- end fabdi
l_sales_order_id          NUMBER;
l_x_error_code            NUMBER;
l_lock_records            VARCHAR2(1);
l_sort_by_req_date        NUMBER;
l_count                   NUMBER;

-- subinventory
l_revision_code NUMBER;
l_lot_code      NUMBER;
l_serial_code   NUMBER;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING PROCESS_SET_OF_LINES' , 1 ) ;
   END IF;

   l_line_tbl             := p_x_line_tbl;
   l_old_line_tbl         := p_old_line_tbl;

   -- If the action is unreserve, we should unreserve what is reserved

   IF l_line_tbl(1).schedule_action_code =
                    OE_ORDER_SCH_UTIL.OESCH_ACT_UNRESERVE OR
      l_line_tbl(1).schedule_action_code =
                    OE_ORDER_SCH_UTIL.OESCH_ACT_UNSCHEDULE THEN

      FOR J IN 1..l_line_tbl.count LOOP
         IF l_old_line_tbl(J).reserved_quantity > 0 AND
            nvl(l_line_tbl(J).shipping_interfaced_flag, 'N') = 'N' THEN

             /*OE_ORDER_SCH_UTIL.Unreserve_Line
             ( p_line_rec               => l_old_line_tbl(J)
             , p_quantity_to_unreserve  => l_old_line_tbl(J).reserved_quantity
             , x_return_status          => l_return_status); */ -- INVCONV TO COPMPILE

             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          ELSE
            -- Added for Bug-2319081
               IF l_line_tbl(J).schedule_action_code =
                               OE_ORDER_SCH_UTIL.OESCH_ACT_UNRESERVE
               AND  nvl(l_line_tbl(J).shipping_interfaced_flag, 'N') = 'Y' THEN

                  FND_MESSAGE.SET_NAME('ONT','OE_SCH_UNRSV_NOT_ALLOWED');
                  OE_MSG_PUB.Add;
               END IF;
          END IF;
      END LOOP;
      l_out_line_tbl := l_line_tbl;
      IF l_line_tbl(1).schedule_action_code =
                    OE_ORDER_SCH_UTIL.OESCH_ACT_UNRESERVE
      THEN
         -- To fix bug 1895086.
         l_schedule_action_code := l_line_tbl(1).schedule_action_code;
         goto end_processing;
      END IF;
   END IF;

   -- If the action is reschedule, we should unreserve what is reserved
   -- for the line before redemanding.

   IF l_line_tbl(1).schedule_action_code =
                    OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE THEN
      FOR J IN 1..l_line_tbl.count LOOP

        l_re_reserve_flag(j) := 'N';
           IF l_line_tbl(J).item_type_code <> OE_GLOBALS.G_ITEM_CONFIG AND
              nvl(l_line_tbl(J).shipping_interfaced_flag, 'N') = 'N' THEN
              -- We do not want to unreserve config item while rescheduling.
              -- Unreserve only if there is any change in the warehouse.
              -- Inventory changes are not allowed for model/option/classes.
              -- For subinventory changes system will not log group request
              -- Modified code to fix bug 1894284.
              IF NOT OE_GLOBALS.Equal(l_line_tbl(j).ship_from_org_id,
                                      l_old_line_tbl(j).ship_from_org_id) THEN
                   IF l_old_line_tbl(J).reserved_quantity > 0 THEN
                       /*OE_ORDER_SCH_UTIL.Unreserve_Line
                       ( p_line_rec               => l_old_line_tbl(J)
                       , p_quantity_to_unreserve  => l_old_line_tbl(J).reserved_quantity
                       , x_return_status          => l_return_status); */ -- INVCONV

                       l_line_tbl(j).reserved_quantity := 0;
                       l_re_reserve_flag(j) := 'Y';
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'L_RE_RESERVE_FLAG :' || J || L_RE_RESERVE_FLAG ( J ) , 1 ) ;
                       END IF;

                   END IF; -- Reserved qty.
              END IF; -- ship from change.

              -- If group request is logged due to change in the ordered qty.
              -- Will compare the reserved qty and ordered qty and if the reserved
              -- qty is higher than ordered qty, we will unreserve the difference.
              -- If the ordered qty is increased, we will not increase the
              -- reservation.

              IF l_line_tbl(j).ordered_quantity <
                          nvl(l_line_tbl(j).reserved_quantity,0) THEN

                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'CALLING UNRESERVE FOR DIFFERENCE' , 1 ) ;
                  END IF;
                  /*OE_ORDER_SCH_UTIL.Unreserve_Line
                  ( p_line_rec               => l_line_tbl(J)
                  , p_quantity_to_unreserve  => l_line_tbl(J).reserved_quantity -
                                                l_line_tbl(j).ordered_quantity
                  , x_return_status          => l_return_status); */ -- INVCONV

                  l_line_tbl(j).reserved_quantity := l_line_tbl(j).ordered_quantity;
              END IF;
           END IF;


        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
        END IF;

      END LOOP;
      l_out_line_tbl := l_line_tbl;
   END IF;

   l_schedule_action_code := l_line_tbl(1).schedule_action_code;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SCHEDULE ACTION IS : ' || L_SCHEDULE_ACTION_CODE , 1 ) ;
   END IF;


    -- When User reserves the group lines without scheduling, changes the status to
    -- Schedule and call MRP and change the status back to reserve and call inv.

    IF l_line_tbl(1).schedule_action_code =
				OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE
       AND l_line_tbl(1).schedule_status_code is null THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  ' GRP SCHEDULE ACTION IS : ' || L_SCHEDULE_ACTION_CODE , 1 ) ;
       END IF;
	  l_reset_action := 'Y';

	 FOR J IN 1..l_line_tbl.count LOOP

	  l_line_tbl(j).schedule_action_code := OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;

	 END LOOP;
    END IF; -- Reserve.

   -- Do not call scheduling is action is reserve and line already scheduled.

   IF  l_schedule_action_code = OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE
   AND l_line_tbl(1).schedule_status_code is NOT NULL
   THEN

     Null;

   ELSE

     OE_ORDER_SCH_UTIL.Load_MRP_Request
     ( p_line_tbl              => l_line_tbl
     , p_old_line_tbl          => l_old_line_tbl
     , x_atp_table             => l_mrp_atp_rec);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER CALLING LOAD_MRP_REQUEST' , 1 ) ;
    END IF;

    -- Added if stmt to fix bug 2162690.
    IF l_mrp_atp_rec.error_code.count > 0 THEN
       l_session_id := OE_ORDER_SCH_UTIL.Get_Session_Id;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CALLING MRPS ATP API ' || L_SESSION_ID , 1 ) ;
       END IF;

       MRP_ATP_PUB.Call_ATP
       ( p_session_id             =>  l_session_id
       , p_atp_rec                =>  l_mrp_atp_rec
       , x_atp_rec                =>  l_out_mtp_atp_rec
       , x_atp_supply_demand      =>  l_atp_supply_demand
       , x_atp_period             =>  l_atp_period
       , x_atp_details            =>  l_atp_details
       , x_return_status          =>  l_return_status
       , x_msg_data               =>  mrp_msg_data
       , x_msg_count              =>  l_msg_count);

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AFTER CALLING MRPS ATP API: ' || L_RETURN_STATUS , 1 ) ;
       END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'GRP1: CALLING LOAD_RESULTS' , 1 ) ;
       END IF;

       OE_ORDER_SCH_UTIL.Load_Results
        ( p_atp_table             => l_out_mtp_atp_rec
        , p_x_line_tbl              => l_line_tbl
        , x_atp_tbl               => l_out_atp_table
        , x_return_status         => l_return_status);

                                             IF l_debug_level  > 0 THEN
                                                 oe_debug_pub.add(  'GRP1: AFTER CALLING LOAD_RESULTS: ' || L_RETURN_STATUS , 1 ) ;
                                             END IF;

        x_atp_tbl       := l_out_atp_table;
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF; -- MRP count.

 --  Code has been moved up to fix bug 2408551.

    IF l_debug_level  > 0 THEN
oe_debug_pub.add( '----- AFTER PRINTING OUT NOCOPY TABLE -----' , 1 ) ;

    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' ' , 1 ) ;
    END IF;


    IF NOT OE_GLOBALS.Equal(l_schedule_action_code,
                            OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK) AND
       NOT OE_GLOBALS.Equal(l_schedule_action_code,
                            OE_ORDER_SCH_UTIL.OESCH_ACT_UNRESERVE) AND
       p_write_to_db = FND_API.G_TRUE THEN

       -- Turning off Perform Scheduling Flag Before calling
       -- this procedure since this procedure is calling Process Order
       -- which in turn will call scheduling if this flag is not turned off.

       OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';

                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'L_LINE_TBL.SHIP_FROM_ORG_ID' || L_LINE_TBL ( 1 ) .SHIP_FROM_ORG_ID ) ;
                         END IF;
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'L_LINE_TBL.SCHEDULE_SHIP_DATE' || L_LINE_TBL ( 1 ) .SCHEDULE_SHIP_DATE ) ;
                         END IF;
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'L_LINE_TBL.SCHEDULE_STATUS_CODE' || L_LINE_TBL ( 1 ) .SCHEDULE_STATUS_CODE ) ;
                         END IF;
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'L_LINE_TBL.INVENTORY_ITEM_ID' || L_LINE_TBL ( 1 ) .INVENTORY_ITEM_ID ) ;
                         END IF;

       -- Set the status of the lines to update

       K := 1;
       FOR I IN 1..l_line_tbl.count LOOP

          IF nvl(l_line_tbl(I).open_flag,'Y') = 'Y' THEN

             l_out_line_tbl1(K) := l_line_tbl(I);
             l_out_line_tbl1(K).operation := OE_GLOBALS.G_OPR_UPDATE;
             l_old_line_tbl1(K) := p_old_line_tbl(I);

             K := K + 1;

          END IF;

       END LOOP;


       -- Setting g_set_recursive_flag related flag to TRUE, since
       -- we do not want any set related changes to take place in this
       -- call to process order.

       OE_SET_UTIL.g_set_recursive_flag := TRUE;
       IF l_out_line_tbl1.count >= 1 THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NOW CALLING OE_ORDER_SCH_UTIL.UPDATE_LINE_RECORD' , 1 ) ;
        END IF;

        OE_ORDER_SCH_UTIL.Update_line_record
        ( p_line_tbl      => l_old_line_tbl1
        , p_x_new_line_tbl  => l_out_line_tbl1
        , p_write_to_db   => p_write_to_db
	   , p_recursive_call => FND_API.G_FALSE
        , x_return_status => l_return_status);

                                          IF l_debug_level  > 0 THEN
                                              oe_debug_pub.add(  'AFTER CALLING UPDATE_LINE_RECORD: ' || L_RETURN_STATUS , 1 ) ;
                                          END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Do not process delayed requests if this was a recursive
         -- call (e.g. from oe_line_util.pre_write_process)
            l_process_requests := TRUE;

	    OE_Order_PVT.Process_Requests_And_Notify
	    ( p_process_requests        => l_process_requests
	    , p_notify                  => TRUE
	    , p_line_tbl                => l_out_line_tbl1
	    , p_old_line_tbl            => l_old_line_tbl1
	    , x_return_status           => l_return_status
	    );

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;


       END IF;


       -- Resetting g_set_recursive_flag related flag to FALSE

       OE_SET_UTIL.g_set_recursive_flag := FALSE;

       -- Fix for bug 2898623
       M := l_out_line_tbl1.FIRST;
       N := l_line_tbl.FIRST;

       WHILE M IS NOT NULL LOOP
         BEGIN
           WHILE N IS NOT NULL LOOP
             BEGIN
               IF l_line_tbl(N).line_id = l_out_line_tbl1(M).line_id THEN
                 l_line_tbl(N) := l_out_line_tbl1(M);
               ELSE
                 EXIT;
               END IF;
             END;
           N := l_line_tbl.NEXT(N);
           END LOOP;
         END;
       M := l_out_line_tbl1.NEXT(M);
       END LOOP;
       -- Fix for bug 2898623 ends

      -- Resetting the Flag Back

      OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

    END IF; -- Call po

    -- No reservation is required.
    -- Modified  if stmt and added atp_check to fix bug 1936990.
    IF l_line_tbl(1).schedule_action_code =
                   OE_ORDER_SCH_UTIL.OESCH_ACT_UNSCHEDULE OR
       l_line_tbl(1).schedule_action_code =
                   OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK

    THEN
         goto end_processing;
    END IF;

   END IF; -- Reserve MRP.

    -- If user action is reserve then reset the action code in line level.
    -- If the user action is Reserve, then call reservation for reserving the line.


     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' GRP RES CALL INV ' , 1 ) ;
     END IF;

     FOR J IN 1..l_line_tbl.count LOOP

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE TO RESERVE ' || L_LINE_TBL ( J ) .LINE_ID , 1 ) ;
       END IF;

        IF l_reset_action = 'Y' THEN

           l_line_tbl(j).schedule_action_code := l_schedule_action_code;

        END IF;

        IF  l_line_tbl(j).shippable_flag = 'Y'
        AND l_line_tbl(j).ordered_quantity > 0
        AND l_line_tbl(j).Item_type_code <> OE_GLOBALS.G_ITEM_CONFIG  THEN

           SELECT RESERVABLE_TYPE
           INTO   l_reservable_type
           FROM   MTL_SYSTEM_ITEMS
           WHERE  INVENTORY_ITEM_ID = l_line_tbl(j).inventory_item_id
           AND    ORGANIZATION_ID = l_line_tbl(j).ship_from_org_id;

           IF l_reservable_type = 1 THEN

            l_schedule_level :=
            OE_ORDER_SCH_UTIL.Get_Scheduling_Level(l_line_tbl(j).header_id,
                                                   l_line_tbl(j).line_type_id);


            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ACTION :' || L_LINE_TBL ( J ) .SCHEDULE_ACTION_CODE , 1 ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'QTY :' || L_LINE_TBL ( J ) .RESERVED_QUANTITY , 1 ) ;
            END IF;

            IF ((l_line_tbl(j).schedule_action_code =
                                OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE
            OR ((l_schedule_level = OE_ORDER_SCH_UTIL.SCH_LEVEL_THREE OR
                 l_schedule_level is NULL) AND
                 OE_ORDER_SCH_UTIL.Within_Rsv_Time_Fence
                     (l_line_tbl(j).schedule_ship_date)))
            AND nvl(l_line_tbl(j).reserved_quantity,0) = 0)

            OR  (l_line_tbl(j).schedule_action_code =
                            OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE AND
                  Nvl(l_re_reserve_flag(j),'N') = 'Y')
            THEN
            --newsub check if item is under lot/revision/serial control
              IF l_line_tbl(j).subinventory is not null
               AND l_line_tbl(j).subinventory <> FND_API.G_MISS_CHAR THEN
               BEGIN
                 SELECT revision_qty_control_code, lot_control_code,
                        serial_number_control_code
                 INTO l_revision_code, l_lot_code, l_serial_code
                 FROM mtl_system_items
                 WHERE inventory_item_id = l_line_tbl(j).inventory_item_id
                 AND   organization_id   = l_line_tbl(j).ship_from_org_id;

               EXCEPTION
                    WHEN OTHERS THEN
                    l_return_status := FND_API.G_RET_STS_ERROR;
                    fnd_message.set_name('ONT', 'OE_INVALID_ITEM_WHSE');
                    OE_MSG_PUB.Add;
               END;


               IF l_revision_code = 2 OR l_lot_code = 2 THEN
               -- 2 == YES
                     fnd_message.set_name('ONT', 'OE_SUBINV_NOT_ALLOWED');
                     OE_MSG_PUB.Add;
                     IF l_line_tbl(j).schedule_action_code =
                                OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE THEN
                         l_return_status := FND_API.G_RET_STS_ERROR;
                         RAISE FND_API.G_EXC_ERROR;
                     ELSE
                         -- We should not fail the transaction, if we are
                         -- not able to reserve the line.
                         l_line_tbl(j).reserved_quantity := null;
                         l_return_status := FND_API.G_RET_STS_SUCCESS;
                         GOTO NO_RESERVATION;
                     END IF;
               END IF;
              END IF;
            --end newsub


                                       IF l_debug_level  > 0 THEN
                                           oe_debug_pub.add(  'GRP RES: RESERVED_QUANTITY ' || L_LINE_TBL ( J ) .ORDERED_QUANTITY , 1 ) ;
                                       END IF;

              l_line_tbl(j).reserved_quantity := l_line_tbl(j).ordered_quantity;

              OE_ORDER_SCH_UTIL.Load_INV_Request
              ( p_line_rec              => l_line_tbl(j)
              , p_quantity_to_reserve   => l_line_tbl(j).ordered_quantity
              , x_reservation_rec       => l_reservation_rec);

               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'GRP RES AFTER CALLING LOAD INV' , 1 ) ;
               END IF;

             -- Call INV with action = RESERVE

             inv_reservation_pub.create_reservation
               ( p_api_version_number          => 1.0
                , p_init_msg_lst              => FND_API.G_TRUE
                , x_return_status             => l_return_status
                , x_msg_count                 => l_msg_count
                , x_msg_data                  => l_msg_data
                , p_rsv_rec                   => l_reservation_rec
                , p_serial_number             => l_dummy_sn
                , x_serial_number             => l_dummy_sn
                , p_partial_reservation_flag  => FND_API.G_FALSE
                , p_force_reservation_flag    => FND_API.G_FALSE
                , p_validation_flag           => FND_API.G_TRUE
                , x_quantity_reserved         => l_quantity_reserved
                , x_reservation_id            => l_rsv_id
                );

                                              IF l_debug_level  > 0 THEN
                                                  oe_debug_pub.add(  'GRP RES AFTER CALLING CREATE RESERVATION' || L_RETURN_STATUS , 1 ) ;
                                              END IF;

	      -- Bug No:2097933
              -- If the Reservation was succesfull we set
              -- the package variable to "Y".
              IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
	        OE_ORDER_SCH_UTIL.OESCH_PERFORMED_RESERVATION := 'Y';
              END IF;

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
              END IF;

             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                l_line_tbl(j).reserved_quantity := null;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                IF l_msg_data is not null THEN
                   fnd_message.set_encoded(l_msg_data);
                   l_buffer := fnd_message.get;
                   oe_msg_pub.add_text(p_message_text => l_buffer);
                END IF;

                l_line_tbl(j).reserved_quantity := null;

                IF l_line_tbl(j).schedule_action_code =
                                OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE
                THEN
                      RAISE FND_API.G_EXC_ERROR;

                ELSE


                 -- We should not fail the transaction, if we are
                 -- not able to reserve the line.
                  l_return_status := FND_API.G_RET_STS_SUCCESS;

                END IF;

            END IF; -- return status
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'GRP RES AFTER CALLING INVS CREATE_RESERVATION' , 1 ) ;
            END IF;


--           l_line_tbl(j).reserved_quantity := l_quantity_reserved;
        END IF;  -- Reservable condition.
       END IF; -- l_reservable_type
      END IF;  -- Check for shippable flag.


      -- Adding code to fix bug 2126165.

      IF  l_line_tbl(j).schedule_action_code =
                            OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE
      AND  NOT OE_GLOBALS.Equal(l_line_tbl(j).schedule_ship_date,
                              l_old_line_tbl(j).schedule_ship_date)
      AND l_old_line_tbl(j).reserved_quantity > 0
      AND l_old_line_tbl(j).reserved_quantity <> FND_API.G_MISS_NUM
      AND Nvl(l_re_reserve_flag(j),'N') = 'N'
      THEN


        l_query_rsv_rec.reservation_id := fnd_api.g_miss_num;

        l_sales_order_id
                   := OE_ORDER_SCH_UTIL.Get_mtl_sales_order_id(l_old_line_tbl(j).header_id);
        l_query_rsv_rec.demand_source_header_id  := l_sales_order_id;
        l_query_rsv_rec.demand_source_line_id    := l_old_line_tbl(j).line_id;

        -- 02-jun-2000 mpetrosi added org_id to query_reservation start
        l_query_rsv_rec.organization_id  := l_old_line_tbl(j).ship_from_org_id;
        -- 02-jun-2000 mpetrosi added org_id to query_reservation end


        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RSCH: CALLING INVS QUERY_RESERVATION ' , 1 ) ;
        END IF;

        inv_reservation_pub.query_reservation
              ( p_api_version_number       => 1.0
              , p_init_msg_lst              => fnd_api.g_true
              , x_return_status             => l_return_status
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
                                 oe_debug_pub.add(  'AFTER CALLING INVS QUERY_RESERVATION: ' || L_RETURN_STATUS , 1 ) ;
                             END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

                                          IF l_debug_level  > 0 THEN
                                              oe_debug_pub.add(  'RESERVATION RECORD COUNT IS: ' || L_RSV_TBL.COUNT , 1 ) ;
                                          END IF;

            -- Let's get the total reserved_quantity
        FOR M IN 1..l_rsv_tbl.count LOOP

           l_reservation_rec := l_rsv_tbl(M);
           l_reservation_rec.requirement_date := l_line_tbl(j).schedule_ship_date;

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'RSCH: CALLING INVS UPDATE RESERVATION ' , 1 ) ;
           END IF;
           inv_reservation_pub.update_reservation
               ( p_api_version_number        => 1.0
               , p_init_msg_lst              => fnd_api.g_true
               , x_return_status             => l_return_status
               , x_msg_count                 => l_msg_count
               , x_msg_data                  => l_msg_data
               , p_original_rsv_rec          => l_rsv_tbl(M)
               , p_to_rsv_rec                => l_reservation_rec
               , p_original_serial_number    => l_dummy_sn -- no serial contorl
               , p_to_serial_number          => l_dummy_sn -- no serial control
               , p_validation_flag           => fnd_api.g_true
               );

                               IF l_debug_level  > 0 THEN
                                   oe_debug_pub.add(  'AFTER CALLING INVS UPDATE_RESERVATION: ' || L_RETURN_STATUS , 1 ) ;
                               END IF;

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
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

      END IF;

      -- End code for bug 2126165.
      <<NO_RESERVATION>>
        null;
    END LOOP;

    l_reset_action := 'N';

-- Moved up to fix bug 1936990.
   <<end_processing>>
    -- Get the on-hand and available_to_reserve quantities if you are
    -- performing ATP.

   IF l_line_tbl(1).schedule_action_code =
                          OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK THEN

       FOR K IN 1..l_out_atp_table.count LOOP

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'CALLING QUERY_QTY_TREE' , 1 ) ;
          END IF;

   -- added fabdi 03/May/2001
   -- added p_line_id - AS DEFAULT for process atp to work

   -- passing additional parameter p_sch_date to fix bug 2111470.
          /*OE_ORDER_SCH_UTIL.Query_Qty_Tree  -- INVCONV - COMMENTED OUT FOR COMPILES

               (p_org_id           => l_out_atp_table(K).ship_from_org_id,
                p_item_id          => l_out_atp_table(K).inventory_item_id,
                p_line_id          => l_out_atp_table(K).line_id,
                p_sch_date         =>
                      nvl(l_out_atp_table(K).group_available_date,
                          l_out_atp_table(K).ordered_qty_Available_Date),
                x_on_hand_qty      => l_on_hand_qty,
                x_avail_to_reserve => l_avail_to_reserve); */
   -- added fabdi 03/May/2001
        IF NOT INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => l_out_atp_table(K).ship_from_org_id)
        THEN
		l_process_flag := FND_API.G_FALSE;
        ELSE
		l_process_flag := FND_API.G_TRUE;
        END IF;
        IF l_process_flag = FND_API.G_TRUE
        THEN

        	l_out_atp_table(K).on_hand_qty          := l_on_hand_qty;
        	l_out_atp_table(K).available_to_reserve := l_avail_to_reserve;
                l_out_atp_table(K).QTY_ON_REQUEST_DATE := l_avail_to_reserve; -- This is Available field in ATP

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'L_ON_HAND_QTY ' || L_ON_HAND_QTY ) ;
                END IF;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'L_AVAIL_TO_RESERVE ' || L_AVAIL_TO_RESERVE ) ;
                END IF;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'ORDERED_QUANTITY ' || L_AVAIL_TO_RESERVE ) ;
                END IF;
        else
        	l_out_atp_table(K).on_hand_qty          := l_on_hand_qty;
        	l_out_atp_table(K).available_to_reserve := l_avail_to_reserve;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'L_ON_HAND_QTY' || L_ON_HAND_QTY ) ;
                END IF;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'L_AVAIL_TO_RESERVE' || L_AVAIL_TO_RESERVE ) ;
                END IF;
        end if;
   -- end fabdi

       END LOOP;

   END IF;

   FOR I IN 1..l_line_tbl.count LOOP


                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'LINE_ID :' || L_LINE_TBL ( I ) .LINE_ID , 20 ) ;
                          END IF;
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'ORDER_QUANTITY :' || L_LINE_TBL ( I ) .ORDERED_QUANTITY , 20 ) ;
                          END IF;
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'SCHEDULE_SHIP_DATE :' || L_LINE_TBL ( I ) .SCHEDULE_SHIP_DATE , 20 ) ;
                          END IF;
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'SCHEDULE_ARRIVAL_DATE :' || L_LINE_TBL ( I ) .SCHEDULE_ARRIVAL_DATE , 20 ) ;
                          END IF;
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'SHIP_FROM_ORG_ID :' || L_LINE_TBL ( I ) .SHIP_FROM_ORG_ID , 20 ) ;
                          END IF;
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'SCHEDULE_STATUS_CODE :' || L_LINE_TBL ( I ) .SCHEDULE_STATUS_CODE , 20 ) ;
                          END IF;
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'RESERVED_QUANTITY :' || L_LINE_TBL ( I ) .RESERVED_QUANTITY , 20 ) ;
                          END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  ' ' , 20 ) ;
       END IF;

    END LOOP;
/*
   oe_debug_pub.add('----- After Printing OUT Table -----',1);
   oe_debug_pub.add(' ',1);

   IF NOT OE_GLOBALS.Equal(l_schedule_action_code,
                           OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK) AND
      NOT OE_GLOBALS.Equal(l_schedule_action_code,
                           OE_ORDER_SCH_UTIL.OESCH_ACT_UNRESERVE) AND
      p_write_to_db = FND_API.G_TRUE THEN

       -- Turning off Perform Scheduling Flag Before calling
       -- this procedure since this procedure is calling Process Order
       -- which in turn will call scheduling if this flag is not turned off.

       OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';

       oe_debug_pub.add('l_line_tbl.ship_from_org_id' ||
                         l_line_tbl(1).ship_from_org_id);
       oe_debug_pub.add('l_line_tbl.schedule_ship_date' ||
                         l_line_tbl(1).schedule_ship_date);
       oe_debug_pub.add('l_line_tbl.schedule_status_code' ||
                         l_line_tbl(1).schedule_status_code);
       oe_debug_pub.add('l_line_tbl.inventory_item_id' ||
                         l_line_tbl(1).inventory_item_id);

       -- Set the status of the lines to update

       K := 1;
       FOR I IN 1..l_line_tbl.count LOOP

          IF nvl(l_line_tbl(I).open_flag,'Y') = 'Y' THEN

             l_out_line_tbl1(K) := l_line_tbl(I);
             l_out_line_tbl1(K).operation := OE_GLOBALS.G_OPR_UPDATE;
             l_old_line_tbl1(K) := p_old_line_tbl(I);

             K := K + 1;

          END IF;

       END LOOP;


       -- Setting g_set_recursive_flag related flag to TRUE, since
       -- we do not want any set related changes to take place in this
       -- call to process order.

       OE_SET_UTIL.g_set_recursive_flag := TRUE;
       IF l_out_line_tbl1.count >= 1 THEN

        oe_debug_pub.add('Now Calling OE_ORDER_SCH_UTIL.Update_line_record',1);

        OE_ORDER_SCH_UTIL.Update_line_record
        ( p_line_tbl      => l_old_line_tbl1
        , p_x_new_line_tbl  => l_out_line_tbl1
        , p_write_to_db   => p_write_to_db
	   , p_recursive_call => FND_API.G_FALSE
        , x_return_status => l_return_status);

        oe_debug_pub.add('After Calling Update_line_record: ' ||
                                          l_return_status,1);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Do not process delayed requests if this was a recursive
         -- call (e.g. from oe_line_util.pre_write_process)
            l_process_requests := TRUE;

	    OE_Order_PVT.Process_Requests_And_Notify
	    ( p_process_requests        => l_process_requests
	    , p_notify                  => TRUE
	    , p_line_tbl                => l_out_line_tbl1
	    , p_old_line_tbl            => l_old_line_tbl1
	    , x_return_status           => l_return_status
	    );

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;


       END IF;


       -- Resetting g_set_recursive_flag related flag to FALSE

       OE_SET_UTIL.g_set_recursive_flag := FALSE;

       p_x_line_tbl := l_out_line_tbl1;
      -- Resetting the Flag Back

      OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';


   ELSE
     oe_debug_pub.add('Assigning l_out_table to x_line_tbl',1);
     p_x_line_tbl := l_line_tbl;
   END IF;
*/
   p_x_line_tbl := l_line_tbl;
   x_atp_tbl       := l_out_atp_table;
   x_return_status := l_return_status;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'PASSING BACK ' || L_OUT_ATP_TABLE.COUNT || ' LINES' || P_X_LINE_TBL.COUNT , 1 ) ;
   END IF;
                               IF l_debug_level  > 0 THEN
                                   oe_debug_pub.add(  'EXITING PROCESS_SET_OF_LINES WITH: ' || L_RETURN_STATUS , 1 ) ;
                               END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      IF p_log_msg = 'Y' THEN
        FND_MESSAGE.SET_NAME('ONT','OE_SCH_GROUP_MEMBER_FAILED');
        OE_MSG_PUB.Add;
      END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_set_of_lines'
            );
        END IF;

END Process_set_of_lines;

/* ---------------------------------------------------------------
Procedure  : Line_In_Sch_Group
Description: This procedure is written for the validation
             template Schedule Group. It will return 1 if the
             line is line has belongs to any of the scheduling groups.

 ---------------------------------------------------------------*/

Procedure Line_In_Sch_Group
(p_application_id               in number,
p_entity_short_name            in varchar2,
p_validation_entity_short_name in varchar2,
p_validation_tmplt_short_name  in varchar2,
p_record_set_short_name        in varchar2,
p_scope                        in varchar2,
x_result out nocopy number)

IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  x_result :=  0;
END;

/* -------------------------------------------------------------------
FUNCTION: Query Lines is used to get all the lines we need
          to scheduled an order. We are not using the line utility
          because we want to sort the table in a particular format.
 ------------------------------------------------------------------- */
PROCEDURE Query_Lines
(   p_header_id      IN NUMBER,
    x_line_tbl		 IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
)
IS
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
--l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_org_id                      NUMBER;

CURSOR l_line_csr IS
    SELECT LINE_ID
    FROM    OE_ORDER_LINES_ALL
    WHERE
    HEADER_ID = p_header_id
    AND item_type_code <> OE_GLOBALS.G_ITEM_INCLUDED
    ORDER BY arrival_set_id,ship_set_id,line_number,shipment_number,nvl(option_number,-1);

  -- Added nvl stmt to fix bug 1937881.
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING QUERY LINES' , 1 ) ;
    END IF;

    --  Loop over fetched records

    FOR c2 IN l_line_csr LOOP

        OE_Line_Util.Query_Row( p_line_id  => c2.line_id
                               ,x_line_rec => l_line_rec );

        x_line_tbl(x_line_tbl.COUNT + 1) := l_line_rec;

        --Removed extra assignmnet to fix bug 1612399.

    END LOOP;


    --  Return fetched table
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_GRP_SCH_UTIL.QUERY_LINES' , 1 ) ;
    END IF;

--    RETURN l_line_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Lines;

/* ---------------------------------------------------------------
Procedure :Validate_Group_Request
           This procedure is written for the validation of group request
           that is passed in.

 ---------------------------------------------------------------*/
Procedure Validate_Group_Request
(p_group_req_rec IN  OE_GRP_SCH_UTIL.Sch_Group_Rec_Type
,x_return_status OUT NOCOPY VARCHAR2)

IS
l_return_status VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING VALIDATE_GROUP_REQUEST' , 1 ) ;
    END IF;

    -- Currently, we do not allow unscheduling a line, if it belongs
    -- to a user defined set (ship or arrival set).

    IF (p_group_req_rec.entity_type =
       OE_ORDER_SCH_UTIL.OESCH_ENTITY_SHIP_SET) OR
       (p_group_req_rec.entity_type =
        OE_ORDER_SCH_UTIL.OESCH_ENTITY_ARRIVAL_SET) THEN

        IF (p_group_req_rec.action =
                       OE_ORDER_SCH_UTIL.OESCH_ACT_UNSCHEDULE ) OR
           (p_group_req_rec.action =
                       OE_ORDER_SCH_UTIL.OESCH_ACT_UNDEMAND ) THEN

           -- You cannot unschedule a set. This is an invalid action on
           -- the group.

           FND_MESSAGE.SET_NAME('ONT','OE_SCH_CANNOT_UNSCH_SET');
           OE_MSG_PUB.Add;
           l_return_status := FND_API.G_RET_STS_ERROR;

        END IF;
    END IF;

    x_return_status := l_return_status;
                                      IF l_debug_level  > 0 THEN
                                          oe_debug_pub.add(  'EXITING VALIDATE_GROUP_REQUEST WITH: ' || L_RETURN_STATUS , 1 ) ;
                                      END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' ' , 1 ) ;
    END IF;

END Validate_Group_Request;

/* ---------------------------------------------------------------
Procedure :Validate_Warehouse
           This procedure is written for the validation of group request
           that is passed in.

 ---------------------------------------------------------------*/
Procedure Validate_Warehouse
(p_line_tbl         IN  OE_ORDER_PUB.line_tbl_type
,p_ship_from_org_id IN  NUMBER
,x_return_status OUT NOCOPY VARCHAR2)

IS
l_line_number       NUMBER;
l_dummy             VARCHAR2(10);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   FOR I in 1..p_line_tbl.count LOOP

       l_line_number := p_line_tbl(I).line_number;

       SELECT 'VALID'
       INTO   l_dummy
       FROM   MTL_SYSTEM_ITEMS
       WHERE  INVENTORY_ITEM_ID = p_line_tbl(I).inventory_item_id
       AND    ORGANIZATION_ID   = p_ship_from_org_id;

   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;

         FND_MESSAGE.SET_NAME('ONT','OE_SCH_GRP_WHSE_INVALID');
         OE_MSG_PUB.Add;

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         FND_MESSAGE.SET_NAME('ONT','OE_SCH_GRP_WHSE_INVALID');
         FND_MESSAGE.SET_TOKEN('LINE',l_line_number);
         OE_MSG_PUB.Add;

END Validate_Warehouse;

/* ---------------------------------------------------------------
Procedure :Sch_Multi_selected_lines
           This procedure is called when lines are multi-selected and
           scheduling action is performed.

 ---------------------------------------------------------------*/
Procedure Sch_Multi_selected_lines
(p_line_list     IN  VARCHAR2,
p_line_count     IN  NUMBER,
p_action         IN  VARCHAR2,
x_atp_tbl OUT NOCOPY OE_ATP.Atp_Tbl_Type,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2)

IS
j                      Integer;
initial                Integer;
nextpos                Integer;
l_record_ids           VARCHAR2(2000) := p_line_list || ',';
l_line_id              NUMBER;
l_line_tbl             OE_ORDER_PUB.line_tbl_type;
l_option_tbl           OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl         OE_ORDER_PUB.line_tbl_type;
l_new_line_tbl         OE_ORDER_PUB.line_tbl_type;
l_line_rec             OE_ORDER_PUB.line_rec_type;
l_group_req_rec        OE_GRP_SCH_UTIL.Sch_Group_Rec_Type;
l_out_atp_tbl          OE_ATP.atp_tbl_type;
l_return_status        VARCHAR2(1);
--l_out_line_rec         OE_ORDER_PUB.line_rec_type;
l_old_line_rec         OE_ORDER_PUB.line_rec_type;
atp_count              NUMBER;
line_count             NUMBER := 0;
option_count           NUMBER;
l_option_exists        NUMBER;   -- Bug-2287767
l_option_search        NUMBER;   -- Bug-2287767
I                      NUMBER;
l_out_return_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

processed_arrival_set  number_arr;
processed_ship_set     number_arr;
processed_pto_model    number_arr;
processed_pto_smc      number_arr;
processed_ato          number_arr;

arrival_set_count      NUMBER := 0;
ship_set_count         NUMBER := 0;
pto_smc_count          NUMBER := 0;
ato_count              NUMBER := 0;

l_top_model_line_id    NUMBER;
pto_model_count        NUMBER := 0;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GG: ENTERING SCH_MULTI_SELECTED_LINES' , 1 ) ;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LINE COUNT IS: ' || P_LINE_COUNT , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ACTION IS: ' || P_ACTION , 1 ) ;
  END IF;

  /* Bug :2222360 */
  IF p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INSIDE ATP CHECK SAVEPOINT' ) ;
    END IF;
    SAVEPOINT ATP_CHECK;
  ELSE
    SAVEPOINT SCH_ACTION;
  END IF;

  j := 1;
  initial := 1;
  nextpos := INSTR(l_record_ids,',',1,j) ;

  FOR I IN 1..p_line_count LOOP


      l_line_id := to_number(substr(l_record_ids,initial, nextpos-initial));
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE_ID : ' || L_LINE_ID , 1 ) ;
      END IF;

      initial := nextpos + 1.0;
      j := j + 1.0;
      nextpos := INSTR(l_record_ids,',',1,j) ;

--      l_line_rec := OE_LINE_UTIL.Query_Row
--         (   p_line_id                     => l_line_id
--         );

	  OE_Line_Util.Query_Row
		   (   p_line_id      => l_line_id,
			   x_line_rec     => l_line_rec);


      IF l_line_rec.ato_line_id = l_line_rec.line_id AND
         l_line_rec.top_model_line_id <> l_line_rec.line_id THEN

         -- We want to skip the options under a Model, if the model
         -- has been selected for scheduling

          IF pto_model_count > 0 THEN
             FOR P in 1..pto_model_count LOOP
                 IF l_line_rec.top_model_line_id =
                                     processed_pto_model(pto_model_count)
                 THEN
                    goto end_loop_1;
                 END IF;
             END LOOP;
          END IF;

          -- Could not find the parent line processed.
          line_count := line_count + 1;
          l_line_tbl(line_count) := l_line_rec;
      ELSE
         line_count := line_count + 1;
         l_line_tbl(line_count) := l_line_rec;
      END IF;

      IF l_line_tbl(line_count).item_type_code = OE_GLOBALS.G_ITEM_MODEL AND
         l_line_tbl(line_count).ato_line_id is null AND
         nvl(l_line_tbl(line_count).ship_model_complete_flag,'N') = 'N' THEN

         l_top_model_line_id := l_line_tbl(line_count).top_model_line_id;

         pto_model_count := pto_model_count + 1;
         processed_pto_model(pto_model_count) :=
                                      l_line_rec.top_model_line_id;

         -- When a model is selected for scheduling, all the options
         -- under it should also get scheduled. Query all the options
         -- needed for the scheduling.

--         l_option_tbl := OE_CONFIG_UTIL.Query_Options
--                                    (l_top_model_line_id);

		OE_Config_Util.Query_Options
                         (p_top_model_line_id  => l_top_model_line_id,
			  x_line_tbl           => l_option_tbl);

         FOR option_count in 1..l_option_tbl.count LOOP
             IF l_option_tbl(option_count).item_type_code <>
                                        OE_GLOBALS.G_ITEM_INCLUDED THEN
                IF l_option_tbl(option_count).line_id <>
                                             l_top_model_line_id THEN
                 -- Search for Option in the Line table, if the option does
                 -- not Exist in the table then add it to the table.
                 -- Bug - 2287767.
                l_option_exists := 0;
                  FOR l_option_search in 1..line_count LOOP
                    IF  l_option_tbl(option_count).line_id =
                                 l_line_tbl(l_option_search).line_id THEN
                      l_option_exists := 1;
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'OPTION ALREADY EXISTS IN LINE TABLE' ) ;
                      END IF;
                      EXIT;
                    END IF;
                   END LOOP;
                    IF l_option_exists = 0 THEN     -- Bug - 2287767
                       line_count := line_count + 1;
                       l_line_tbl(line_count) := l_option_tbl(option_count);
                    END IF;
                END IF;
             END IF;
         END LOOP;

      END IF;
  <<end_loop_1>>
  null;
  END LOOP;

  -- l_line_tbl consists the lines we need to schedule.

  atp_count  := 1;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LINES TO PROCESS : ' || L_LINE_TBL.COUNT , 1 ) ;
  END IF;

  FOR line_index IN 1..l_line_tbl.count
  LOOP
  BEGIN

     SAVEPOINT SCH_LINE;
      -- Added code to fix bug 1778701.
     IF l_line_tbl(line_index).line_category_code = 'RETURN' THEN

         -- Ignore return lines.
         goto end_loop;

     END IF;


     l_line_rec     := l_line_tbl(line_index);
     l_old_line_rec := l_line_rec;

     IF p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE OR
        p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_UNSCHEDULE OR
        p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK OR
        (p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE AND
                l_line_rec.schedule_status_code is null) THEN

        -- We want to skip a line belonging to a set only if the action
        -- is SCHEDULE,ATP or UNSCHEDULE. We do not want to skip if the
        -- action is RESERVE or UNRESERVE, since then, we will treat the
        -- line independently.

        IF l_line_rec.arrival_set_id is not null THEN
           -- Check to see if this set is already processed. If yes, then
           -- go to the end.
           arrival_set_count := processed_arrival_set.count;
           IF arrival_set_count > 0 THEN
              FOR c IN 1..processed_arrival_set.count LOOP
                 IF l_line_rec.arrival_set_id = processed_arrival_set(c)
                 THEN
                     -- This set has been processed.
                     goto end_loop;
                 END IF;
              END LOOP;
           END IF;

           -- If the line could not find it's arrival set id in the
           -- processed_arrival_set, it has not been processed. Let's add the
           -- set_id to the table and process the set.

           arrival_set_count := Arrival_set_count + 1;
           processed_arrival_set(arrival_set_count) :=
                                      l_line_rec.arrival_set_id;
        ELSIF l_line_rec.ship_set_id is not null THEN
           -- Check to see if this set is already processed. If yes, then
           -- go to the end.
           ship_set_count := processed_ship_set.count;
           IF ship_set_count > 0 THEN
              FOR c IN 1..processed_ship_set.count LOOP
                 IF l_line_rec.ship_set_id = processed_ship_set(c)
                 THEN
                     -- This set has been processed.
                     goto end_loop;
                 END IF;
              END LOOP;
           END IF;

           -- If the line could not find it's ship set id in the
           -- processed_ship_set, it has not been processed. Let's add the
           -- set_id to the table and process the set.

           ship_set_count := ship_set_count + 1;
           processed_ship_set(ship_set_count) := l_line_rec.ship_set_id;
        ELSIF nvl(l_line_rec.ship_model_complete_flag,'N') = 'Y' THEN
           -- Check to see if this set is already processed. If yes, then
           -- go to the end.
           pto_smc_count := processed_pto_smc.count;
           IF pto_smc_count > 0 THEN
              FOR c IN 1..processed_pto_smc.count LOOP
                 IF l_line_rec.top_model_line_id = processed_pto_smc(c)
                 THEN
                     -- This set has been processed.
                     goto end_loop;
                 END IF;
              END LOOP;
           END IF;

           -- If the line could not find it's top model line id in the
           -- processed_pto_smc, it has not been processed. Let's add the
           -- top_model_line_id to the table and process the set.

           pto_smc_count := pto_smc_count + 1;
           processed_pto_smc(pto_smc_count) := l_line_rec.top_model_line_id;
        ELSIF l_line_rec.ato_line_id is not null THEN
           -- Check to see if this set is already processed. If yes, then
           -- go to the end.
           ato_count := processed_ato.count;
           IF ato_count > 0 THEN
              FOR c IN 1..processed_ato.count LOOP
                 IF l_line_rec.ato_line_id = processed_ato(c)
                 THEN
                     -- This set has been processed.
                     goto end_loop;
                 END IF;
              END LOOP;
           END IF;

           -- If the line could not find it's ATO Line id in the
           -- processed_ato set, it has not been processed. Let's add the
           -- set_id to the table and process the set.

           ato_count := ato_count + 1;
           processed_ato(ato_count) := l_line_rec.ato_line_id;
        END IF;
     END IF; /* Action is not reserve */

     IF (l_line_rec.ship_set_id is not null OR
        l_line_rec.arrival_set_id is not null OR
        l_line_rec.ship_model_complete_flag = 'Y' OR
        (l_line_rec.ato_line_id is not null AND
         NOT (l_line_rec.line_id = l_line_rec.ato_line_id AND
              l_line_rec.item_type_code IN( OE_GLOBALS.G_ITEM_STANDARD,
                                           OE_GLOBALS.G_ITEM_OPTION)))) AND
        (p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE OR
         p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_UNSCHEDULE OR
         p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK OR
         ((p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_UNRESERVE OR
           p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE ) AND
           l_line_rec.ship_model_complete_flag = 'Y'))
     THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SCHEDULING A GROUP ' , 1 ) ;
         END IF;
         l_line_rec.schedule_action_code := p_action;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SM: CREATING GROUP_REQUEST' , 1 ) ;
         END IF;

         OE_ORDER_SCH_UTIL.Create_Group_Request
          (  p_line_rec      => l_line_rec
           , p_old_line_rec  => l_line_rec
           , x_group_req_rec => l_group_req_rec
           , x_return_status => l_return_status
          );

          /* Bug 2270426 */
          IF (p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE OR
              p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_UNRESERVE)
          AND  l_line_rec.ship_model_complete_flag = 'Y'
          AND  (l_line_rec.arrival_set_id is not null OR
                l_line_rec.ship_set_id is not null) THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'INSIDE RESERVE , SMC AND SET' ) ;
            END IF;
            l_group_req_rec.entity_type       := OE_ORDER_SCH_UTIL.OESCH_ENTITY_SMC;
            l_group_req_rec.ship_set_number   := l_line_rec.top_model_line_id;

          END IF;

         -- Line belongs to a group. Needs to be scheduled in a group.


         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SM: CALLING GRP_SCHEDULE: ' || L_RETURN_STATUS , 1 ) ;
         END IF;

         Group_Schedule
           ( p_group_req_rec     => l_group_req_rec
            ,x_atp_tbl           => l_out_atp_tbl
            ,x_return_status     => l_return_status);

                                       IF l_debug_level  > 0 THEN
                                           oe_debug_pub.add(  'SM: AFTER CALLING GROUP_SCHEDULE: ' || L_RETURN_STATUS , 1 ) ;
                                       END IF;

         FOR J IN 1..l_out_atp_tbl.count
         LOOP
            x_atp_tbl(atp_count) := l_out_atp_tbl(J);
            atp_count := atp_count + 1;
         END LOOP;

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             l_out_return_status := FND_API.G_RET_STS_ERROR;
             ROLLBACK TO SCH_LINE;
         END IF;


     ELSE

        -- The line will come here, if it is a standard line not
        -- belong to any group, or if the action on it is RESERVE
        -- or UNRESERVE (and it does belong to a group).

         l_line_rec.schedule_action_code     := p_action;
         l_line_rec.operation                := OE_GLOBALS.G_OPR_UPDATE;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SCHEDULING LINE: ' || L_LINE_REC.LINE_ID , 1 ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ITEM TYPE IS : ' || L_LINE_REC.ITEM_TYPE_CODE , 1 ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' ' , 1 ) ;
         END IF;


         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'GRP2: CALLING SCHEDULE LINE' , 1 ) ;
         END IF;

         OE_ORDER_SCH_UTIL.Schedule_line
             ( p_old_line_rec  => l_old_line_rec
              ,p_write_to_db   => FND_API.G_TRUE
              ,p_x_line_rec      => l_line_rec
              ,x_atp_tbl       => l_out_atp_tbl
              ,x_return_status => l_return_status);

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             l_out_return_status := FND_API.G_RET_STS_ERROR;
             ROLLBACK TO SCH_LINE;
         END IF;

                                  IF l_debug_level  > 0 THEN
                                      oe_debug_pub.add(  'GRP2:AFTER CALLING SCHEDULE LINE' || L_RETURN_STATUS , 1 ) ;
                                  END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'COUNT OF ATP IS : ' || L_OUT_ATP_TBL.COUNT , 1 ) ;
         END IF;
         -- Load the ATP table which could have more records than 1 since
         -- included items got scheduled.


         FOR J IN 1..l_out_atp_tbl.count
         LOOP
            x_atp_tbl(atp_count) := l_out_atp_tbl(J);
            atp_count := atp_count + 1;
         END LOOP;

     END IF;

     <<end_loop>>
     null;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        -- The line did not get scheduled, which is ok, since an error
        -- message would have captured the error.
         ROLLBACK TO SCH_LINE;
        null;
  END;

  END LOOP;

  --  Set return status.

  /*
  IF l_out_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  */

  --  x_return_status := l_out_return_status;
  -- Returning success, even if there were errors (unexpected errors will
  -- be raised and taken care of). This is because we do not want to rollback
  -- since the successful lines should get committed.

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  Get message count and data

  oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

   /* Bug :2222360 */
  IF p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INSIDE ATP CHECK ROLLBACK' ) ;
    END IF;
    ROLLBACK TO ATP_CHECK;
    OE_Delayed_Requests_Pvt.Clear_Request
    (x_return_status => l_return_status);
  END IF;

                                           IF l_debug_level  > 0 THEN
                                               oe_debug_pub.add(  'EXITING SCH_MULTI_SELECTED_LINES WITH: ' || L_OUT_RETURN_STATUS , 1 ) ;
                                           END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        /* Bug :2222360 */
        IF p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INSIDE ATP CHECK ROLLBACK' ) ;
          END IF;
          ROLLBACK TO ATP_CHECK;
          OE_Delayed_Requests_Pvt.Clear_Request
           (x_return_status => l_return_status);
        ELSE
          ROLLBACK TO SCH_ACTION;
        END IF;


        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        /* Bug :2222360 */
        IF p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INSIDE ATP CHECK ROLLBACK' ) ;
          END IF;
          ROLLBACK TO ATP_CHECK;
          OE_Delayed_Requests_Pvt.Clear_Request
           (x_return_status => l_return_status);
        ELSE
           ROLLBACK TO SCH_ACTION;
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        /* Bug :2222360 */
        IF p_action = OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INSIDE ATP CHECK ROLLBACK' ) ;
          END IF;
          ROLLBACK TO ATP_CHECK;
          OE_Delayed_Requests_Pvt.Clear_Request
           (x_return_status => l_return_status);
        ELSE
          ROLLBACK TO SCH_ACTION;
        END IF;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sch_Multi_selected_lines'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Sch_Multi_selected_lines;


END OE_GRP_SCH_UTIL;


/
